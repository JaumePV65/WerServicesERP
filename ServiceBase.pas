unit ServiceBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs, System.Threading,
  System.Generics.Collections, System.SyncObjs, System.DateUtils,
  System.TypInfo, System.StrUtils,
  Logger, Config, WebServer, DatabaseManager, TaskScheduler;

type
  // Enumeració d'estats del servei
  TServiceStatus = (ssStarting, ssRunning, ssStopping, ssStopped, ssError);
  
  // Event handlers per al servei
  TServiceEvent = procedure(const AMessage: string) of object;
  TServiceStatusEvent = procedure(AStatus: TServiceStatus; const AMessage: string) of object;

  TWebServiceERP = class(TService)
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceShutdown(Sender: TService);
  private
    FStatus: TServiceStatus;
    FWebServer: TWebServer;
    FDatabaseManager: TDatabaseManager;
    FTaskScheduler: TTaskScheduler;
    FLogger: TLogger;
    FConfig: TAppConfig;
    FServiceThread: TThread;
    FCriticalSection: TCriticalSection;
    FShutdownEvent: TEvent;
    
    // Events
    FOnServiceEvent: TServiceEvent;
    FOnStatusChange: TServiceStatusEvent;
    
    procedure SetStatus(AStatus: TServiceStatus; const AMessage: string = '');
    procedure InitializeComponents;
    procedure FinalizeComponents;
    procedure LogServiceEvent(const AMessage: string; ALevel: TLogLevel = llInfo);
    function GetServiceInfo: string;
    procedure HandleException(E: Exception; const AContext: string);
    
    // Mètodes per a la comunicació entre components
    procedure OnWebServerError(const AError: string);
    procedure OnDatabaseError(const AError: string);
    procedure OnTaskSchedulerError(const AError: string);
    
  protected
    function DoStop: Boolean; override;
    function DoPause: Boolean; override;
    function DoContinue: Boolean; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetServiceController: TServiceController; override;
    // Propietats públiques
    property Status: TServiceStatus read FStatus;
    property ServiceInfo: string read GetServiceInfo;
    
    // Events públics
    property OnServiceEvent: TServiceEvent read FOnServiceEvent write FOnServiceEvent;
    property OnStatusChange: TServiceStatusEvent read FOnStatusChange write FOnStatusChange;
    
    // Mètodes públics per al control del servei
    function IsHealthy: Boolean;
    function GetComponentsStatus: TDictionary<string, Boolean>;
    procedure RestartComponent(const AComponentName: string);
    
    class function GetServiceDisplayName: string;
    class function GetServiceName: string;
    class function GetServiceDescription: string;
  end;

  // Thread principal del servei
  TServiceMainThread = class(TThread)
  private
    FService: TWebServiceERP;
    FShutdownEvent: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(AService: TWebServiceERP; AShutdownEvent: TEvent);
  end;

var
  WebServiceERP: TWebServiceERP;

implementation

{$R *.dfm}

const
  SERVICE_NAME = 'WebServiceERP_6BDN';
  SERVICE_DISPLAY_NAME = 'Servei Web ERP. (6BDN)';
  SERVICE_DESCRIPTION = 'Servei web per a la gestió d''ERP (6BDN)';
  
  // Intervals de temps (en mil·lisegons)
  MAIN_LOOP_INTERVAL = 1000;      // 1 segon
  HEALTH_CHECK_INTERVAL = 30000;  // 30 segons
  COMPONENT_RESTART_DELAY = 5000; // 5 segons

{ TWebServiceERP }

constructor TWebServiceERP.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  
  // Configuració bàsica del servei
  Name := SERVICE_NAME;
  DisplayName := SERVICE_DISPLAY_NAME;
  
  // Inicialització d'objectes
  FCriticalSection := TCriticalSection.Create;
  FShutdownEvent := TEvent.Create(nil, True, False, '');
  FStatus := ssStopped;
  
  // Inicialització de components base
  try
    FConfig := TAppConfig.Create;
    FLogger := TLogger.Create(FConfig.LogLevel, FConfig.LogPath);
    
    LogServiceEvent('Servei creat correctament', llInfo);
  except
    on E: Exception do
    begin
      SetStatus(ssError, 'Error en la creació del servei: ' + E.Message);
      raise;
    end;
  end;
end;

destructor TWebServiceERP.Destroy;
begin
  LogServiceEvent('Destruint servei...', llInfo);
  
  FinalizeComponents;
  
  FreeAndNil(FShutdownEvent);
  FreeAndNil(FCriticalSection);
  FreeAndNil(FLogger);
  FreeAndNil(FConfig);
  
  inherited Destroy;
end;

procedure TWebServiceERP.ServiceStart(Sender: TService; var Started: Boolean);
begin
  Started := False;
  
  try
    SetStatus(ssStarting, 'Iniciant servei...');
    LogServiceEvent('Iniciant servei Web ERP', llInfo);
    
    // Inicialitzar components
    InitializeComponents;
    
    // Crear i iniciar el thread principal
    FServiceThread := TServiceMainThread.Create(Self, FShutdownEvent);
    
    SetStatus(ssRunning, 'Servei iniciat correctament');
    LogServiceEvent('Servei iniciat correctament', llInfo);
    
    Started := True;
    
  except
    on E: Exception do
    begin
      HandleException(E, 'ServiceStart');
      Started := False;
    end;
  end;
end;

procedure TWebServiceERP.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Stopped := DoStop;
end;

procedure TWebServiceERP.ServicePause(Sender: TService; var Paused: Boolean);
begin
  Paused := DoPause;
end;

procedure TWebServiceERP.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  Continued := DoContinue;
end;

procedure TWebServiceERP.ServiceExecute(Sender: TService);
begin
  // El bucle principal s'executa al thread separat
  // Aquí només esperem fins que el servei sigui aturat
  while not Terminated do
  begin
    ServiceThread.ProcessRequests(False);
    Sleep(100);
  end;
end;

procedure TWebServiceERP.ServiceShutdown(Sender: TService);
begin
  LogServiceEvent('Apagada del sistema detectada', llWarning);
  DoStop;
end;

function TWebServiceERP.DoStop: Boolean;
begin
  Result := False;
  
  try
    SetStatus(ssStopping, 'Aturant servei...');
    LogServiceEvent('Aturant servei...', llInfo);
    
    // Senyalitzar als threads que s'han d'aturar
    if Assigned(FShutdownEvent) then
      FShutdownEvent.SetEvent;
    
    // Esperar que el thread principal acabi
    if Assigned(FServiceThread) then
    begin
       FServiceThread.Terminate;
       FShutdownEvent.SetEvent;  // Senyalitzar que pari
       FServiceThread.WaitFor;   // Esperar sense timeout
       FreeAndNil(FServiceThread);
    end;
    
    // Finalitzar components
    FinalizeComponents;
    
    SetStatus(ssStopped, 'Servei aturat correctament');
    LogServiceEvent('Servei aturat correctament', llInfo);
    
    Result := True;
    
  except
    on E: Exception do
    begin
      HandleException(E, 'DoStop');
      Result := False;
    end;
  end;
end;

function TWebServiceERP.DoPause: Boolean;
begin
  Result := False;
  
  try
    LogServiceEvent('Pausant servei...', llInfo);
    
    // Pausar components si tenen aquesta capacitat
    if Assigned(FWebServer) then
      FWebServer.Pause;
      
    if Assigned(FTaskScheduler) then
      FTaskScheduler.Pause;
    
    LogServiceEvent('Servei pausat', llInfo);
    Result := True;
    
  except
    on E: Exception do
    begin
      HandleException(E, 'DoPause');
      Result := False;
    end;
  end;
end;

function TWebServiceERP.GetServiceController: TServiceController;
begin
  Result := nil; // Per mode consola no necessitem controller
end;

function TWebServiceERP.DoContinue: Boolean;
begin
  Result := False;
  
  try
    LogServiceEvent('Continuant servei...', llInfo);
    
    // Continuar components
    if Assigned(FWebServer) then
      FWebServer.Resume;
      
    if Assigned(FTaskScheduler) then
      FTaskScheduler.Resume;
    
    LogServiceEvent('Servei continuat', llInfo);
    Result := True;
    
  except
    on E: Exception do
    begin
      HandleException(E, 'DoContinue');
      Result := False;
    end;
  end;
end;

procedure TWebServiceERP.InitializeComponents;
var
 I,MaxTables:integer;
begin
  LogServiceEvent('Inicialitzant components...', llInfo);
  
  try
    // Inicialitzar gestor de base de dades
    FDatabaseManager := TDatabaseManager.Create(FConfig, FLogger);
    FDatabaseManager.OnError := OnDatabaseError;
    FDatabaseManager.Initialize;
    LogServiceEvent('=== PROVA DE CONNEXIÓ FIREBIRD ===', llInfo);

    // Prova 1: Informació de la BD
    try
      LogServiceEvent('Informació de la base de dades:', llInfo);
      LogServiceEvent(FDatabaseManager.GetDatabaseInfo, llInfo);
    except
      on E: Exception do
        LogServiceEvent('Error obtenint info BD: ' + E.Message, llError);
    end;

    // Prova 2: Llistar taules
    try
      var TableList := FDatabaseManager.GetTableList;
      try
        LogServiceEvent(Format('Nombre total de taules: %d', [TableList.Count]), llInfo);
        LogServiceEvent('Primeres taules:', llInfo);
        MaxTables := 4;
        if TableList.Count - 1 < 4 then
          MaxTables := TableList.Count - 1;
        for I := 0 to MaxTables do
          LogServiceEvent('  - ' + TableList[I], llInfo);
        if TableList.Count > 5 then
          LogServiceEvent(Format('  ... i %d taules més', [TableList.Count - 5]), llInfo);
      finally
        TableList.Free;
      end;
    except
      on E: Exception do
        LogServiceEvent('Error llistant taules: ' + E.Message, llError);
    end;

    LogServiceEvent('=== FI PROVA CONNEXIÓ ===', llInfo);
    
    // Inicialitzar servidor web
    FWebServer := TWebServer.Create(FConfig, FLogger, FDatabaseManager);
    FWebServer.OnError := OnWebServerError;
    FWebServer.Start;
    
    // Inicialitzar programador de tasques
    FTaskScheduler := TTaskScheduler.Create(FConfig, FLogger, FDatabaseManager);
    FTaskScheduler.OnError := OnTaskSchedulerError;
    FTaskScheduler.Start;
    
    LogServiceEvent('Components inicialitzats correctament', llInfo);
    
  except
    on E: Exception do
    begin
      LogServiceEvent('Error inicialitzant components: ' + E.Message, llError);
      FinalizeComponents;
      raise;
    end;
  end;
end;

procedure TWebServiceERP.FinalizeComponents;
begin
  LogServiceEvent('Finalitzant components...', llInfo);
  
  try
    // Aturar components en ordre invers
    if Assigned(FTaskScheduler) then
    begin
      FTaskScheduler.Stop;
      FreeAndNil(FTaskScheduler);
    end;
    
    if Assigned(FWebServer) then
    begin
      FWebServer.Stop;
      FreeAndNil(FWebServer);
    end;
    
    if Assigned(FDatabaseManager) then
    begin
      FDatabaseManager.Finalize;
      FreeAndNil(FDatabaseManager);
    end;
    
    LogServiceEvent('Components finalitzats', llInfo);
    
  except
    on E: Exception do
      LogServiceEvent('Error finalitzant components: ' + E.Message, llError);
  end;
end;

procedure TWebServiceERP.SetStatus(AStatus: TServiceStatus; const AMessage: string);
begin
  FCriticalSection.Enter;
  try
    FStatus := AStatus;
    
    if Assigned(FOnStatusChange) then
      FOnStatusChange(AStatus, AMessage);
      
    if AMessage <> '' then
      LogServiceEvent(AMessage, llInfo);
      
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TWebServiceERP.LogServiceEvent(const AMessage: string; ALevel: TLogLevel);
begin
  if Assigned(FLogger) then
    FLogger.Log(AMessage, ALevel);
    
  if Assigned(FOnServiceEvent) then
    FOnServiceEvent(AMessage);
end;

function TWebServiceERP.GetServiceInfo: string;
var
  ComponentsStatus: TDictionary<string, Boolean>;
  Key: string;
begin
  Result := Format('Servei: %s' + sLineBreak +
                   'Estat: %s' + sLineBreak +
                   'Temps d''execució: %s' + sLineBreak +
                   'Components:' + sLineBreak,
                   [SERVICE_DISPLAY_NAME, 
                    GetEnumName(TypeInfo(TServiceStatus), Ord(FStatus)),
                    FormatDateTime('dd/mm/yyyy hh:nn:ss', Now)]);
                    
  ComponentsStatus := GetComponentsStatus;
  try
    for Key in ComponentsStatus.Keys do
    begin
      Result := Result + Format('  - %s: %s' + sLineBreak, 
                               [Key, 
                                IfThen(ComponentsStatus[Key], 'Actiu', 'Inactiu')]);
    end;
  finally
    ComponentsStatus.Free;
  end;
end;

function TWebServiceERP.IsHealthy: Boolean;
var
  ComponentsStatus: TDictionary<string, Boolean>;
  Status: Boolean;
begin
  Result := (FStatus = ssRunning);
  
  if Result then
  begin
    ComponentsStatus := GetComponentsStatus;
    try
      for Status in ComponentsStatus.Values do
      begin
        if not Status then
        begin
          Result := False;
          Break;
        end;
      end;
    finally
      ComponentsStatus.Free;
    end;
  end;
end;

function TWebServiceERP.GetComponentsStatus: TDictionary<string, Boolean>;
begin
  Result := TDictionary<string, Boolean>.Create;
  
  Result.Add('Base de Dades', Assigned(FDatabaseManager) and FDatabaseManager.IsConnected);
  Result.Add('Servidor Web', Assigned(FWebServer) and FWebServer.IsRunning);
  Result.Add('Programador de Tasques', Assigned(FTaskScheduler) and FTaskScheduler.IsRunning);
end;

procedure TWebServiceERP.RestartComponent(const AComponentName: string);
begin
  LogServiceEvent('Reiniciant component: ' + AComponentName, llWarning);
  
  try
    if SameText(AComponentName, 'WebServer') and Assigned(FWebServer) then
    begin
      FWebServer.Stop;
      Sleep(COMPONENT_RESTART_DELAY);
      FWebServer.Start;
    end
    else if SameText(AComponentName, 'DatabaseManager') and Assigned(FDatabaseManager) then
    begin
      FDatabaseManager.Disconnect;
      Sleep(COMPONENT_RESTART_DELAY);
      FDatabaseManager.Connect;
    end
    else if SameText(AComponentName, 'TaskScheduler') and Assigned(FTaskScheduler) then
    begin
      FTaskScheduler.Stop;
      Sleep(COMPONENT_RESTART_DELAY);
      FTaskScheduler.Start;
    end;
    
    LogServiceEvent('Component reiniciat: ' + AComponentName, llInfo);
    
  except
    on E: Exception do
      HandleException(E, 'RestartComponent: ' + AComponentName);
  end;
end;

procedure TWebServiceERP.HandleException(E: Exception; const AContext: string);
var
  ErrorMsg: string;
begin
  ErrorMsg := Format('Error en %s: %s', [AContext, E.Message]);
  LogServiceEvent(ErrorMsg, llError);
  SetStatus(ssError, ErrorMsg);
end;

procedure TWebServiceERP.OnWebServerError(const AError: string);
begin
  LogServiceEvent('Error del servidor web: ' + AError, llError);
  // Implementar lògica de recuperació automàtica si cal
end;

procedure TWebServiceERP.OnDatabaseError(const AError: string);
begin
  LogServiceEvent('Error de base de dades: ' + AError, llError);
  // Implementar lògica de reconnexió automàtica si cal
end;

procedure TWebServiceERP.OnTaskSchedulerError(const AError: string);
begin
  LogServiceEvent('Error del programador de tasques: ' + AError, llError);
  // Implementar lògica de recuperació automàtica si cal
end;

class function TWebServiceERP.GetServiceDisplayName: string;
begin
  Result := SERVICE_DISPLAY_NAME;
end;

class function TWebServiceERP.GetServiceName: string;
begin
  Result := SERVICE_NAME;
end;

class function TWebServiceERP.GetServiceDescription: string;
begin
  Result := SERVICE_DESCRIPTION;
end;

{ TServiceMainThread }

constructor TServiceMainThread.Create(AService: TWebServiceERP; AShutdownEvent: TEvent);
begin
  FService := AService;
  FShutdownEvent := AShutdownEvent;
  inherited Create(False);
end;

procedure TServiceMainThread.Execute;
var
  LastHealthCheck: TDateTime;
begin
  LastHealthCheck := Now;
  
  while not Terminated do
  begin
    try
      // Verificar si hem de parar
      if FShutdownEvent.WaitFor(MAIN_LOOP_INTERVAL) = wrSignaled then
        Break;
        
      // Verificació de salut periòdica
      if SecondsBetween(Now, LastHealthCheck) >= (HEALTH_CHECK_INTERVAL div 1000) then
      begin
        if not FService.IsHealthy then
        begin
          FService.LogServiceEvent('Verificació de salut fallida - components no saludables', llWarning);
          // Aquí es podria implementar lògica de recuperació automàtica
        end;
        LastHealthCheck := Now;
      end;
      
      // Aquí es poden afegir altres tasques periòdiques
      
    except
      on E: Exception do
        FService.HandleException(E, 'ServiceMainThread.Execute');
    end;
  end;
end;

end.