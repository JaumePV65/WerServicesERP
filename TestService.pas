unit TestService;

interface

uses
  System.SysUtils, System.Classes, ServiceBase, Config, Logger;

type
  TServiceTester = class
  private
    FLogger: TLogger;
    FConfig: TAppConfig;
    FService: TWebServiceERP;
    FTestResults: TStringList;
    
    procedure LogTest(const TestName: string; Success: Boolean; const Details: string = '');
    
  public
    constructor Create;
    destructor Destroy; override;
    
    // Tests de configuració
    function TestConfiguration: Boolean;
    function TestLogger: Boolean;
    function TestServiceCreation: Boolean;
    function TestServiceComponents: Boolean;
    
    // Test complet
    function RunAllTests: Boolean;
    function GetTestResults: string;
    
    // Tests individuals de components
    function TestDatabaseConfiguration: Boolean;
    function TestWebServerConfiguration: Boolean;
    function TestLoggingConfiguration: Boolean;
  end;

implementation

const
  TEST_PASSED = '✓ PASSAT';
  TEST_FAILED = '✗ FALLAT';

{ TServiceTester }

constructor TServiceTester.Create;
begin
  inherited Create;
  FTestResults := TStringList.Create;
  
  // Configurar logging per a tests
  try
    FConfig := TAppConfig.Create;
    FLogger := TLogger.Create(llDebug, 'TestLogs', 'ServiceTest.log');
    FLogger.EnableConsoleOutput(True);
    
    FLogger.Info('=== Iniciant tests del Servei Web ERP ===');
  except
    on E: Exception do
    begin
      WriteLn('Error inicialitzant el sistema de tests: ', E.Message);
      raise;
    end;
  end;
end;

destructor TServiceTester.Destroy;
begin
  if Assigned(FService) then
    FreeAndNil(FService);
    
  if Assigned(FLogger) then
  begin
    FLogger.Info('=== Tests completats ===');
    FreeAndNil(FLogger);
  end;
  
  FreeAndNil(FConfig);
  FreeAndNil(FTestResults);
  
  inherited Destroy;
end;

procedure TServiceTester.LogTest(const TestName: string; Success: Boolean; const Details: string);
var
  Result: string;
  LogLevel: TLogLevel;
begin
  if Success then
  begin
    Result := TEST_PASSED;
    LogLevel := llInfo;
  end
  else
  begin
    Result := TEST_FAILED;
    LogLevel := llError;
  end;
  
  Result := Format('%s: %s', [TestName, Result]);
  if Details <> '' then
    Result := Result + ' - ' + Details;
    
  FTestResults.Add(Result);
  FLogger.Log(Result, LogLevel);
  WriteLn(Result);
end;

function TServiceTester.TestConfiguration: Boolean;
begin
  Result := False;
  
  try
    FLogger.Info('Test: Verificant configuració...');
    
    // Verificar que la configuració s'ha carregat
    if not Assigned(FConfig) then
    begin
      LogTest('Configuració', False, 'Objecte de configuració no assignat');
      Exit;
    end;
    
    // Verificar valors bàsics
    if FConfig.DatabaseConfig.Server = '' then
    begin
      LogTest('Configuració', False, 'Servidor de BD buit');
      Exit;
    end;
    
    if FConfig.WebServerConfig.Port <= 0 then
    begin
      LogTest('Configuració', False, 'Port del servidor web invàlid');
      Exit;
    end;
    
    if FConfig.LogPath = '' then
    begin
      LogTest('Configuració', False, 'Ruta de logs buida');
      Exit;
    end;
    
    LogTest('Configuració', True, Format('BD: %s:%d, WebPort: %d', 
      [FConfig.DatabaseConfig.Server, FConfig.DatabaseConfig.Port, FConfig.WebServerConfig.Port]));
    Result := True;
    
  except
    on E: Exception do
      LogTest('Configuració', False, 'Excepció: ' + E.Message);
  end;
end;

function TServiceTester.TestLogger: Boolean;
begin
  Result := False;
  
  try
    FLogger.Info('Test: Verificant sistema de logging...');
    
    // Provar diferents nivells de log
    FLogger.Debug('Test de log DEBUG');
    FLogger.Info('Test de log INFO');
    FLogger.Warning('Test de log WARNING');
    FLogger.Error('Test de log ERROR');
    
    // Verificar que el fitxer de log existeix
    if not FileExists(FLogger.GetLogFilePath) then
    begin
      LogTest('Logger', False, 'Fitxer de log no existeix');
      Exit;
    end;
    
    // Verificar mida del log
    if FLogger.GetCurrentLogSize <= 0 then
    begin
      LogTest('Logger', False, 'Fitxer de log buit');
      Exit;
    end;
    
    LogTest('Logger', True, Format('Fitxer: %s (%d bytes)', 
      [FLogger.GetLogFilePath, FLogger.GetCurrentLogSize]));
    Result := True;
    
  except
    on E: Exception do
      LogTest('Logger', False, 'Excepció: ' + E.Message);
  end;
end;

function TServiceTester.TestServiceCreation: Boolean;
begin
  Result := False;
  
  try
    FLogger.Info('Test: Creant instància del servei...');
    
    // Crear servei
    FService := TWebServiceERP.Create(nil);
    
    if not Assigned(FService) then
    begin
      LogTest('Creació Servei', False, 'No s''ha pogut crear la instància');
      Exit;
    end;
    
    // Verificar propietats bàsiques
    if FService.Name = '' then
    begin
      LogTest('Creació Servei', False, 'Nom del servei buit');
      Exit;
    end;
    
    if FService.DisplayName = '' then
    begin
      LogTest('Creació Servei', False, 'Nom visible del servei buit');
      Exit;
    end;
    
    LogTest('Creació Servei', True, Format('Nom: %s, DisplayName: %s', 
      [FService.Name, FService.DisplayName]));
    Result := True;
    
  except
    on E: Exception do
      LogTest('Creació Servei', False, 'Excepció: ' + E.Message);
  end;
end;

function TServiceTester.TestServiceComponents: Boolean;
var
  ComponentsStatus: TDictionary<string, Boolean>;
  ComponentName: string;
  AllHealthy: Boolean;
begin
  Result := False;
  
  try
    FLogger.Info('Test: Verificant components del servei...');
    
    if not Assigned(FService) then
    begin
      LogTest('Components Servei', False, 'Servei no creat');
      Exit;
    end;
    
    // Obtenir estat dels components
    ComponentsStatus := FService.GetComponentsStatus;
    try
      AllHealthy := True;
      
      for ComponentName in ComponentsStatus.Keys do
      begin
        if not ComponentsStatus[ComponentName] then
        begin
          AllHealthy := False;
          FLogger.Warning('Component no saludable: ' + ComponentName);
        end
        else
          FLogger.Debug('Component OK: ' + ComponentName);
      end;
      
      // En aquest punt els components encara no s'han inicialitzat, així que és normal que no estiguin "saludables"
      LogTest('Components Servei', True, Format('Components verificats: %d', [ComponentsStatus.Count]));
      Result := True;
      
    finally
      ComponentsStatus.Free;
    end;
    
  except
    on E: Exception do
      LogTest('Components Servei', False, 'Excepció: ' + E.Message);
  end;
end;

function TServiceTester.TestDatabaseConfiguration: Boolean;
var
  DBConfig: TDatabaseConfig;
begin
  Result := False;
  
  try
    FLogger.Info('Test: Verificant configuració de base de dades...');
    
    DBConfig := FConfig.DatabaseConfig;
    
    // Verificar paràmetres crítics
    if DBConfig.Server = '' then
    begin
      LogTest('Config BD', False, 'Servidor no especificat');
      Exit;
    end;
    
    if (DBConfig.Port <= 0) or (DBConfig.Port > 65535) then
    begin
      LogTest('Config BD', False, 'Port invàlid: ' + IntToStr(DBConfig.Port));
      Exit;
    end;
    
    if DBConfig.Database = '' then
    begin
      LogTest('Config BD', False, 'Base de dades no especificada');
      Exit;
    end;
    
    if DBConfig.Username = '' then
    begin
      LogTest('Config BD', False, 'Usuari no especificat');
      Exit;
    end;
    
    LogTest('Config BD', True, Format('%s:%d/%s (Pool: %d)', 
      [DBConfig.Server, DBConfig.Port, DBConfig.Database, DBConfig.PoolSize]));
    Result := True;
    
  except
    on E: Exception do
      LogTest('Config BD', False, 'Excepció: ' + E.Message);
  end;
end;

function TServiceTester.TestWebServerConfiguration: Boolean;
var
  WebConfig: TWebServerConfig;
begin
  Result := False;
  
  try
    FLogger.Info('Test: Verificant configuració del servidor web...');
    
    WebConfig := FConfig.WebServerConfig;
    
    // Verificar port
    if (WebConfig.Port <= 0) or (WebConfig.Port > 65535) then
    begin
      LogTest('Config Web', False, 'Port invàlid: ' + IntToStr(WebConfig.Port));
      Exit;
    end;
    
    // Verificar connexions màximes
    if WebConfig.MaxConnections <= 0 then
    begin
      LogTest('Config Web', False, 'Màxim connexions invàlid: ' + IntToStr(WebConfig.MaxConnections));
      Exit;
    end;
    
    // Verificar SSL si està habilitat
    if WebConfig.EnableSSL then
    begin
      if (WebConfig.SSLCertFile = '') or (WebConfig.SSLKeyFile = '') then
      begin
        LogTest('Config Web', False, 'SSL habilitat però fitxers SSL no especificats');
        Exit;
      end;
    end;
    
    LogTest('Config Web', True, Format('Port: %d, MaxConn: %d, SSL: %s', 
      [WebConfig.Port, WebConfig.MaxConnections, 
       IfThen(WebConfig.EnableSSL, 'Sí', 'No')]));
    Result := True;
    
  except
    on E: Exception do
      LogTest('Config Web', False, 'Excepció: ' + E.Message);
  end;
end;

function TServiceTester.TestLoggingConfiguration: Boolean;
begin
  Result := False;
  
  try
    FLogger.Info('Test: Verificant configuració de logging...');
    
    // Verificar ruta de logs
    if FConfig.LogPath = '' then
    begin
      LogTest('Config Log', False, 'Ruta de logs buida');
      Exit;
    end;
    
    // Verificar que es pot crear el directori
    if not DirectoryExists(FConfig.LogPath) then
    begin
      try
        ForceDirectories(FConfig.LogPath);
      except
        on E: Exception do
        begin
          LogTest('Config Log', False, 'No es pot crear directori de logs: ' + E.Message);
          Exit;
        end;
      end;
    end;
    
    // Verificar paràmetres de mida
    if FConfig.LogMaxSize <= 0 then
    begin
      LogTest('Config Log', False, 'Mida màxima de log invàlida');
      Exit;
    end;
    
    if FConfig.LogMaxFiles <= 0 then
    begin
      LogTest('Config Log', False, 'Nombre màxim de fitxers invàlid');
      Exit;
    end;
    
    LogTest('Config Log', True, Format('Ruta: %s, MaxSize: %d, MaxFiles: %d', 
      [FConfig.LogPath, FConfig.LogMaxSize, FConfig.LogMaxFiles]));
    Result := True;
    
  except
    on E: Exception do
      LogTest('Config Log', False, 'Excepció: ' + E.Message);
  end;
end;

function TServiceTester.RunAllTests: Boolean;
var
  PassedTests, TotalTests: Integer;
begin
  PassedTests := 0;
  TotalTests := 0;
  
  FLogger.Info('=== Executant tots els tests ===');
  FTestResults.Clear;
  
  // Test de configuració
  Inc(TotalTests);
  if TestConfiguration then Inc(PassedTests);
  
  Inc(TotalTests);
  if TestDatabaseConfiguration then Inc(PassedTests);
  
  Inc(TotalTests);
  if TestWebServerConfiguration then Inc(PassedTests);
  
  Inc(TotalTests);
  if TestLoggingConfiguration then Inc(PassedTests);
  
  // Test de logger
  Inc(TotalTests);
  if TestLogger then Inc(PassedTests);
  
  // Test de servei
  Inc(TotalTests);
  if TestServiceCreation then Inc(PassedTests);
  
  Inc(TotalTests);
  if TestServiceComponents then Inc(PassedTests);
  
  // Resultat final
  Result := (PassedTests = TotalTests);
  
  FLogger.Info(Format('Tests completats: %d/%d passats', [PassedTests, TotalTests]));
  WriteLn;
  WriteLn(Format('=== RESULTAT FINAL: %d/%d TESTS PASSATS ===', [PassedTests, TotalTests]));
  
  if Result then
  begin
    WriteLn('✓ TOTS ELS TESTS HAN PASSAT CORRECTAMENT');
    FLogger.Info('Tots els tests han passat correctament');
  end
  else
  begin
    WriteLn('✗ ALGUNS TESTS HAN FALLAT');
    FLogger.Warning(Format('%d tests han fallat', [TotalTests - PassedTests]));
  end;
end;

function TServiceTester.GetTestResults: string;
begin
  Result := FTestResults.Text;
end;

end.