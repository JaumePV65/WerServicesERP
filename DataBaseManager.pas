unit DatabaseManager;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.SyncObjs, System.DateUtils,Variants,
  Logger, Config,
  // UniDAC components
  Uni, UniProvider, InterBaseUniProvider, DBAccess, DB;

type
  TDatabaseErrorEvent = procedure(const AError: string) of object;

  // Pool de connexions
  TConnectionPool = class
  private
    FConnections: TList<TUniConnection>;
    FAvailableConnections: TQueue<TUniConnection>;
    FCriticalSection: TCriticalSection;
    FConfig: TDatabaseConfig;
    FLogger: TLogger;
    FMaxPoolSize: Integer;
    FCurrentSize: Integer;

    function CreateNewConnection: TUniConnection;

  public
    constructor Create(AConfig: TDatabaseConfig; ALogger: TLogger; AMaxPoolSize: Integer = 10);
    destructor Destroy; override;

    function GetConnection: TUniConnection;
    procedure ReleaseConnection(AConnection: TUniConnection);
    function GetPoolStatus: string;
  end;

  TDatabaseManager = class
  private
    FConfig: TAppConfig;
    FLogger: TLogger;
    FConnectionPool: TConnectionPool;
    FConnected: Boolean;
    FOnError: TDatabaseErrorEvent;
    FInterBaseProvider: TInterBaseUniProvider;

    procedure ConfigureProvider;
    function TestConnectionInternal(AConnection: TUniConnection): Boolean;
    procedure HandleDatabaseError(const AContext: string; E: Exception);

  public
    constructor Create(AConfig: TAppConfig; ALogger: TLogger);
    destructor Destroy; override;

    // Mètodes principals
    procedure Initialize;
    procedure Finalize;
    procedure Connect;
    procedure Disconnect;

    // Mètodes de connexió
    function GetConnection: TUniConnection;
    procedure ReleaseConnection(AConnection: TUniConnection);
    function IsConnected: Boolean;
    function TestConnection: Boolean;

    // Mètodes d'utilitat
    function ExecuteQuery(const ASQL: string): TUniQuery;
    function ExecuteScalar(const ASQL: string): Variant;
    procedure ExecuteCommand(const ASQL: string);
    function GetTableList: TStringList;
    function GetDatabaseInfo: string;

    // Transaccions
    function StartTransaction: TUniConnection;
    procedure CommitTransaction(AConnection: TUniConnection);
    procedure RollbackTransaction(AConnection: TUniConnection);

    property OnError: TDatabaseErrorEvent read FOnError write FOnError;
    property ConnectionPool: TConnectionPool read FConnectionPool;
  end;

implementation

{ TConnectionPool }

uses uUtilidades;

constructor TConnectionPool.Create(AConfig: TDatabaseConfig; ALogger: TLogger; AMaxPoolSize: Integer);
begin
  inherited Create;
  FConfig := AConfig;
  FLogger := ALogger;
  FMaxPoolSize := AMaxPoolSize;
  FCurrentSize := 0;

  FConnections := TList<TUniConnection>.Create;
  FAvailableConnections := TQueue<TUniConnection>.Create;
  FCriticalSection := TCriticalSection.Create;

  FLogger.Info('Pool de connexions creat amb mida màxima: %d', [FMaxPoolSize]);
end;

destructor TConnectionPool.Destroy;
var
  Connection: TUniConnection;
begin
  FCriticalSection.Enter;
  try
    // Tancar totes les connexions
    for Connection in FConnections do
    begin
      try
        if Connection.Connected then
          Connection.Disconnect;
        Connection.Free;
      except
        on E: Exception do
          FLogger.Error('Error tancant connexió del pool: %s', [E.Message]);
      end;
    end;

    FConnections.Clear;
    FAvailableConnections.Clear;

  finally
    FCriticalSection.Leave;
  end;

  FreeAndNil(FConnections);
  FreeAndNil(FAvailableConnections);
  FreeAndNil(FCriticalSection);

  FLogger.Info('Pool de connexions finalitzat');
  inherited Destroy;
end;

function TConnectionPool.CreateNewConnection: TUniConnection;
begin
  Result := TUniConnection.Create(nil);
  try
    // Configurar connexió
    Result.ProviderName := 'InterBase';
    Result.Server := FConfig.Server;
    Result.Port := FConfig.Port;
    Result.Database := FConfig.Database;
    Result.Username := StrDecrypt(FConfig.Username);
    Result.Password := StrDecrypt(FConfig.Password);

   // Opcions específiques per Firebird
    Result.SpecificOptions.Values['SQLDialect'] := '3';
    Result.SpecificOptions.Values['ClientLibrary'] := 'fbclient.dll';
    Result.SpecificOptions.Values['Charset'] := FConfig.CharSet;

//    // Per als timeouts, usar propietats generals de UniDAC:
//    Result.LoginTimeout := FConfig.ConnectionTimeout;
    // Connectar
    Result.Connect;

    FLogger.Debug('Nova connexió creada al pool');

  except
    on E: Exception do
    begin
      FLogger.Error('Error creant connexió: %s', [E.Message]);
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

function TConnectionPool.GetConnection: TUniConnection;
begin
  Result := nil;

  FCriticalSection.Enter;
  try
    // Intentar obtenir una connexió disponible
    if FAvailableConnections.Count > 0 then
    begin
      Result := FAvailableConnections.Dequeue;
      FLogger.Trace('Connexió obtinguda del pool (disponibles: %d)', [FAvailableConnections.Count]);
    end
    else if FCurrentSize < FMaxPoolSize then
    begin
      // Crear nova connexió si no hem arribat al màxim
      Result := CreateNewConnection;
      FConnections.Add(Result);
      Inc(FCurrentSize);
      FLogger.Debug('Nova connexió creada (pool: %d/%d)', [FCurrentSize, FMaxPoolSize]);
    end
    else
    begin
      // Pool ple, esperar que s'alliberi una connexió
      FLogger.Warning('Pool de connexions ple (%d), esperant...', [FMaxPoolSize]);
      // Aquí podríem implementar timeout o espera
      raise Exception.Create('Pool de connexions ple');
    end;

    // Verificar que la connexió està activa
    if Assigned(Result) and not Result.Connected then
    begin
      try
        Result.Connect;
      except
        on E: Exception do
        begin
          FLogger.Error('Error reconnectant: %s', [E.Message]);
          FConnections.Remove(Result);
          Dec(FCurrentSize);
          FreeAndNil(Result);
          raise;
        end;
      end;
    end;

  finally
    FCriticalSection.Leave;
  end;
end;

procedure TConnectionPool.ReleaseConnection(AConnection: TUniConnection);
begin
  if not Assigned(AConnection) then
    Exit;

  FCriticalSection.Enter;
  try
    if AConnection.Connected then
    begin
      // Retornar la connexió al pool
      FAvailableConnections.Enqueue(AConnection);
      FLogger.Trace('Connexió retornada al pool (disponibles: %d)', [FAvailableConnections.Count]);
    end
    else
    begin
      // Connexió no vàlida, eliminar-la del pool
      FConnections.Remove(AConnection);
      Dec(FCurrentSize);
      AConnection.Free;
      FLogger.Debug('Connexió invàlida eliminada del pool (pool: %d/%d)', [FCurrentSize, FMaxPoolSize]);
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

function TConnectionPool.GetPoolStatus: string;
begin
  FCriticalSection.Enter;
  try
    Result := Format('Pool: %d/%d connexions, %d disponibles',
      [FCurrentSize, FMaxPoolSize, FAvailableConnections.Count]);
  finally
    FCriticalSection.Leave;
  end;
end;

{ TDatabaseManager }

constructor TDatabaseManager.Create(AConfig: TAppConfig; ALogger: TLogger);
begin
  inherited Create;
  FConfig := AConfig;
  FLogger := ALogger;
  FConnected := False;

  // Crear provider InterBase/Firebird
  FInterBaseProvider := TInterBaseUniProvider.Create(nil);

  FLogger.Info('DatabaseManager creat');
end;

destructor TDatabaseManager.Destroy;
begin
  Finalize;
  FreeAndNil(FInterBaseProvider);
  FLogger.Info('DatabaseManager destruït');
  inherited Destroy;
end;

procedure TDatabaseManager.ConfigureProvider;
begin
  // Configurar provider global per InterBase/Firebird
//  FInterBaseProvider.HomePath := ''; // Detectar automàticament
//  FInterBaseProvider.ClientLibrary := 'fbclient.dll';

  FLogger.Debug('Provider InterBase configurat');
end;

procedure TDatabaseManager.Initialize;
begin
  try
    FLogger.Info('Inicialitzant gestor de base de dades...');

    // Configurar provider
    ConfigureProvider;

    // Crear pool de connexions
    FConnectionPool := TConnectionPool.Create(
      FConfig.DatabaseConfig,
      FLogger,
      FConfig.DatabaseConfig.PoolSize
    );

    // Connectar
    Connect;

    FLogger.Info('Gestor de base de dades inicialitzat correctament');

  except
    on E: Exception do
    begin
      HandleDatabaseError('Initialize', E);
      raise;
    end;
  end;
end;

procedure TDatabaseManager.Finalize;
begin
  try
    FLogger.Info('Finalitzant gestor de base de dades...');

    Disconnect;

    if Assigned(FConnectionPool) then
      FreeAndNil(FConnectionPool);

    FLogger.Info('Gestor de base de dades finalitzat');

  except
    on E: Exception do
      HandleDatabaseError('Finalize', E);
  end;
end;

procedure TDatabaseManager.Connect;
var
  TestConnection: TUniConnection;
begin
  try
    FLogger.Info('Connectant a la base de dades %s:%d/%s',
      [FConfig.DatabaseConfig.Server, FConfig.DatabaseConfig.Port, FConfig.DatabaseConfig.Database]);

    // Provar connexió inicial
    TestConnection := FConnectionPool.GetConnection;
    try
      if TestConnectionInternal(TestConnection) then
      begin
        FConnected := True;
        FLogger.Info('Connexió a base de dades establerta correctament');
        FLogger.Info(FConnectionPool.GetPoolStatus);
      end
      else
        raise Exception.Create('Test de connexió fallit');

    finally
      FConnectionPool.ReleaseConnection(TestConnection);
    end;

  except
    on E: Exception do
    begin
      FConnected := False;
      HandleDatabaseError('Connect', E);
      raise;
    end;
  end;
end;

procedure TDatabaseManager.Disconnect;
begin
  try
    if FConnected then
    begin
      FLogger.Info('Desconnectant de la base de dades...');
      FConnected := False;

      // El pool es tancarà automàticament al destructor

      FLogger.Info('Desconnexió de base de dades completada');
    end;
  except
    on E: Exception do
      HandleDatabaseError('Disconnect', E);
  end;
end;

function TDatabaseManager.GetConnection: TUniConnection;
begin
  if not FConnected then
    raise Exception.Create('Base de dades no connectada');

  Result := FConnectionPool.GetConnection;
end;

procedure TDatabaseManager.ReleaseConnection(AConnection: TUniConnection);
begin
  FConnectionPool.ReleaseConnection(AConnection);
end;

function TDatabaseManager.IsConnected: Boolean;
begin
  Result := FConnected and Assigned(FConnectionPool);
end;

function TDatabaseManager.TestConnection: Boolean;
var
  Connection: TUniConnection;
begin
  Result := False;

  try
    if not FConnected then
    begin
      FLogger.Warning('Test de connexió: BD no connectada');
      Exit;
    end;

    Connection := GetConnection;
    try
      Result := TestConnectionInternal(Connection);

      if Result then
        FLogger.Debug('Test de connexió: OK')
      else
        FLogger.Warning('Test de connexió: FALLIT');

    finally
      ReleaseConnection(Connection);
    end;

  except
    on E: Exception do
    begin
      FLogger.Error('Error en test de connexió: %s', [E.Message]);
      Result := False;
    end;
  end;
end;

function TDatabaseManager.TestConnectionInternal(AConnection: TUniConnection): Boolean;
var
  Query: TUniQuery;
begin
  Result := False;

  if not Assigned(AConnection) or not AConnection.Connected then
    Exit;

  Query := TUniQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.SQL.Text := 'SELECT 1 FROM RDB$DATABASE';
    Query.Open;
    Result := not Query.IsEmpty;
    Query.Close;
  except
    on E: Exception do
    begin
      FLogger.Error('Error en test SQL: %s', [E.Message]);
      Result := False;
    end;
  end;

  FreeAndNil(Query);
end;

function TDatabaseManager.ExecuteQuery(const ASQL: string): TUniQuery;
var
  Connection: TUniConnection;
begin
  if not FConnected then
    raise Exception.Create('Base de dades no connectada');

  Connection := GetConnection;

  Result := TUniQuery.Create(nil);
  try
    Result.Connection := Connection;
    Result.SQL.Text := ASQL;
    Result.Open;

    FLogger.Trace('Query executada: %s', [ASQL]);

  except
    on E: Exception do
    begin
      ReleaseConnection(Connection);
      FreeAndNil(Result);
      HandleDatabaseError('ExecuteQuery', E);
      raise;
    end;
  end;

  // Nota: La connexió es retornarà quan es tanqui el query
end;

function TDatabaseManager.ExecuteScalar(const ASQL: string): Variant;
var
  Query: TUniQuery;
begin
  Query := ExecuteQuery(ASQL);
  try
    if not Query.IsEmpty then
      Result := Query.Fields[0].Value
    else
      Result := Null;
  finally
    ReleaseConnection(Query.Connection);
    Query.Free;
  end;
end;

procedure TDatabaseManager.ExecuteCommand(const ASQL: string);
var
  Connection: TUniConnection;
  Query: TUniQuery;
begin
  if not FConnected then
    raise Exception.Create('Base de dades no connectada');

  Connection := GetConnection;
  try
    Query := TUniQuery.Create(nil);
    try
      Query.Connection := Connection;
      Query.SQL.Text := ASQL;
      Query.ExecSQL;

      FLogger.Trace('Comanda executada: %s', [ASQL]);

    finally
      Query.Free;
    end;
  finally
    ReleaseConnection(Connection);
  end;
end;

function TDatabaseManager.GetTableList: TStringList;
var
  Query: TUniQuery;
begin
  Result := TStringList.Create;

  Query := ExecuteQuery(
    'SELECT RDB$RELATION_NAME FROM RDB$RELATIONS ' +
    'WHERE RDB$RELATION_TYPE = 0 AND RDB$SYSTEM_FLAG = 0 ' +
    'ORDER BY RDB$RELATION_NAME'
  );

  try
    while not Query.Eof do
    begin
      Result.Add(Trim(Query.FieldByName('RDB$RELATION_NAME').AsString));
      Query.Next;
    end;
  finally
    ReleaseConnection(Query.Connection);
    Query.Free;
  end;
end;

function TDatabaseManager.GetDatabaseInfo: string;
var
  Query: TUniQuery;
  TableCount: Integer;
  Version: string;
begin
  try
    // Obtenir versió de Firebird
    Query := ExecuteQuery('SELECT RDB$GET_CONTEXT(''SYSTEM'', ''ENGINE_VERSION'') as VERSION FROM RDB$DATABASE');
    try
      Version := Query.FieldByName('VERSION').AsString;
    finally
      ReleaseConnection(Query.Connection);
      Query.Free;
    end;

    // Comptar taules
    Query := ExecuteQuery('SELECT COUNT(*) as TABLE_COUNT FROM RDB$RELATIONS WHERE RDB$RELATION_TYPE = 0 AND RDB$SYSTEM_FLAG = 0');
    try
      TableCount := Query.FieldByName('TABLE_COUNT').AsInteger;
    finally
      ReleaseConnection(Query.Connection);
      Query.Free;
    end;

    Result := Format(
      'Base de dades: %s' + sLineBreak +
      'Servidor: %s:%d' + sLineBreak +
      'Versió Firebird: %s' + sLineBreak +
      'Nombre de taules: %d' + sLineBreak +
      'Pool de connexions: %s',
      [FConfig.DatabaseConfig.Database,
       FConfig.DatabaseConfig.Server, FConfig.DatabaseConfig.Port,
       Version,
       TableCount,
       FConnectionPool.GetPoolStatus]
    );

  except
    on E: Exception do
    begin
      Result := 'Error obtenint informació de la base de dades: ' + E.Message;
      HandleDatabaseError('GetDatabaseInfo', E);
    end;
  end;
end;

function TDatabaseManager.StartTransaction: TUniConnection;
begin
  Result := GetConnection;
  Result.StartTransaction;
  FLogger.Trace('Transacció iniciada');
end;

procedure TDatabaseManager.CommitTransaction(AConnection: TUniConnection);
begin
  if Assigned(AConnection) and AConnection.InTransaction then
  begin
    AConnection.Commit;
    FLogger.Trace('Transacció confirmada');
  end;
  ReleaseConnection(AConnection);
end;

procedure TDatabaseManager.RollbackTransaction(AConnection: TUniConnection);
begin
  if Assigned(AConnection) and AConnection.InTransaction then
  begin
    AConnection.Rollback;
    FLogger.Trace('Transacció cancel·lada');
  end;
  ReleaseConnection(AConnection);
end;

procedure TDatabaseManager.HandleDatabaseError(const AContext: string; E: Exception);
var
  ErrorMsg: string;
begin
  ErrorMsg := Format('Error BD en %s: %s', [AContext, E.Message]);
  FLogger.Error(ErrorMsg);

  if Assigned(FOnError) then
    FOnError(ErrorMsg);
end;

end.
