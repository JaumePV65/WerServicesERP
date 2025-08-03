program WebServiceERP;

{$APPTYPE CONSOLE}

uses
  Vcl.SvcMgr,
  System.SysUtils,
  System.Win.ComObj,
  Winapi.Windows,
  Winapi.WinSvc,
  ServiceBase in 'ServiceBase.pas' {WebServiceERP: TService},
  Logger in 'Logger.pas',
  Config in 'Config.pas',
  WebServer in 'WebServer.pas',
  DatabaseManager in 'DataBaseManager.pas',
  TaskScheduler in 'TaskScheduler.pas',
  uUtilidades in 'uUtilidades.pas';

{$R *.RES}

const
  // Paràmetres de línia de comandes
  PARAM_INSTALL = '/install';
  PARAM_UNINSTALL = '/uninstall';
  PARAM_START = '/start';
  PARAM_STOP = '/stop';
  PARAM_DEBUG = '/debug';
  PARAM_CONSOLE = '/console';
  PARAM_HELP = '/?';

// Procediment per mostrar l'ajuda
procedure ShowHelp;
begin
  WriteLn('Servei Web ERP - Sistema de gestió d''ERP amb integració web');
  WriteLn('');
  WriteLn('Ús: WebServiceERP.exe [paràmetre]');
  WriteLn('');
  WriteLn('Paràmetres disponibles:');
  WriteLn('  /install    - Instal·la el servei');
  WriteLn('  /uninstall  - Desinstal·la el servei');
  WriteLn('  /start      - Inicia el servei');
  WriteLn('  /stop       - Atura el servei');
  WriteLn('  /debug      - Executa en mode debug (consola)');
  WriteLn('  /console    - Executa com aplicació de consola');
  WriteLn('  /?          - Mostra aquesta ajuda');
  WriteLn('');
  WriteLn('Si no s''especifica cap paràmetre, s''executa com a servei de Windows.');
  WriteLn('');
end;

// Procediment per instal·lar el servei
function InstallService: Boolean;
var
  SCManager: SC_HANDLE;
  Service: SC_HANDLE;
  ServicePath: string;
begin
  Result := False;

  try
    WriteLn('Instal·lant servei...');

    SCManager := OpenSCManager(nil, nil, SC_MANAGER_CREATE_SERVICE);
    if SCManager = 0 then
    begin
      WriteLn('Error: No es pot obrir el gestor de serveis');
      Exit;
    end;

    try
      ServicePath := ParamStr(0);

      Service := CreateService(
        SCManager,
        PChar(TWebServiceERP.GetServiceName),
        PChar(TWebServiceERP.GetServiceDisplayName),
        SERVICE_ALL_ACCESS,
        SERVICE_WIN32_OWN_PROCESS,
        SERVICE_AUTO_START,
        SERVICE_ERROR_NORMAL,
        PChar(ServicePath),
        nil, nil, nil, nil, nil
      );

      if Service = 0 then
      begin
        if GetLastError = ERROR_SERVICE_EXISTS then
          WriteLn('El servei ja està instal·lat')
        else
          WriteLn('Error instal·lant el servei. Codi d''error: ', GetLastError);
      end
      else
      begin
        CloseServiceHandle(Service);
        WriteLn('Servei instal·lat correctament');
        WriteLn('Nom del servei: ', TWebServiceERP.GetServiceName);
        WriteLn('Nom visible: ', TWebServiceERP.GetServiceDisplayName);
        Result := True;
      end;
    finally
      CloseServiceHandle(SCManager);
    end;
  except
    on E: Exception do
      WriteLn('Excepció instal·lant servei: ', E.Message);
  end;
end;

// Procediment per desinstal·lar el servei
function UninstallService: Boolean;
var
  SCManager: SC_HANDLE;
  Service: SC_HANDLE;
  //ServiceStatus: TServiceStatus;
 ServiceStatus: SERVICE_STATUS;
begin
  Result := False;

  try
    WriteLn('Desinstal·lant servei...');

    SCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
    if SCManager = 0 then
    begin
      WriteLn('Error: No es pot obrir el gestor de serveis');
      Exit;
    end;

    try
      Service := OpenService(SCManager, PChar(TWebServiceERP.GetServiceName), STANDARD_RIGHTS_REQUIRED);
      if Service = 0 then
      begin
        if GetLastError = ERROR_SERVICE_DOES_NOT_EXIST then
          WriteLn('El servei no està instal·lat')
        else
          WriteLn('Error obrint el servei. Codi d''error: ', GetLastError);
      end
      else
      begin
        try
          // Intentar aturar el servei primer
          ControlService(Service, SERVICE_CONTROL_STOP, ServiceStatus);
          Sleep(2000); // Esperar que s'aturi

          if DeleteService(Service) then
          begin
            WriteLn('Servei desinstal·lat correctament');
            Result := True;
          end
          else
            WriteLn('Error desinstal·lant el servei. Codi d''error: ', GetLastError);
        finally
          CloseServiceHandle(Service);
        end;
      end;
    finally
      CloseServiceHandle(SCManager);
    end;
  except
    on E: Exception do
      WriteLn('Excepció desinstal·lant servei: ', E.Message);
  end;
end;

// Procediment per iniciar el servei
function StartService: Boolean;
var
  SCManager: SC_HANDLE;
  Service: SC_HANDLE;
 lpServiceArgVectors: LPCWSTR;
begin
  Result := False;

  try
    WriteLn('Iniciant servei...');

    SCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
    if SCManager = 0 then
    begin
      WriteLn('Error: No es pot obrir el gestor de serveis');
      Exit;
    end;

    try
      Service := OpenService(SCManager, PChar(TWebServiceERP.GetServiceName), SERVICE_START);
      if Service = 0 then
      begin
        WriteLn('Error obrint el servei. Codi d''error: ', GetLastError);
      end
      else
      begin
        try
        lpServiceArgVectors := nil;
        if Winapi.WinSvc.StartService(Service, 0, lpServiceArgVectors) then
          begin
            WriteLn('Servei iniciat correctament');
            Result := True;
          end
          else
          begin
            if GetLastError = ERROR_SERVICE_ALREADY_RUNNING then
              WriteLn('El servei ja s''està executant')
            else
              WriteLn('Error iniciant el servei. Codi d''error: ', GetLastError);
          end;
        finally
          CloseServiceHandle(Service);
        end;
      end;
    finally
      CloseServiceHandle(SCManager);
    end;
  except
    on E: Exception do
      WriteLn('Excepció iniciant servei: ', E.Message);
  end;
end;

// Procediment per aturar el servei
function StopService: Boolean;
var
  SCManager: SC_HANDLE;
  Service: SC_HANDLE;
  ServiceStatus:  Winapi.WinSvc.SERVICE_STATUS;
begin
  Result := False;

  try
    WriteLn('Aturant servei...');

    SCManager := OpenSCManager(nil, nil, SC_MANAGER_CONNECT);
    if SCManager = 0 then
    begin
      WriteLn('Error: No es pot obrir el gestor de serveis');
      Exit;
    end;

    try
      Service := OpenService(SCManager, PChar(TWebServiceERP.GetServiceName), SERVICE_STOP);
      if Service = 0 then
      begin
        WriteLn('Error obrint el servei. Codi d''error: ', GetLastError);
      end
      else
      begin
        try
          if ControlService(Service, SERVICE_CONTROL_STOP, ServiceStatus) then
          begin
            WriteLn('Servei aturat correctament');
            Result := True;
          end
          else
          begin
            if GetLastError = ERROR_SERVICE_NOT_ACTIVE then
              WriteLn('El servei no s''està executant')
            else
              WriteLn('Error aturant el servei. Codi d''error: ', GetLastError);
          end;
        finally
          CloseServiceHandle(Service);
        end;
      end;
    finally
      CloseServiceHandle(SCManager);
    end;
  except
    on E: Exception do
      WriteLn('Excepció aturant servei: ', E.Message);
  end;
end;

// Procediment per executar en mode debug/consola
procedure RunInConsoleMode(DebugMode: Boolean);
var
  Service: TWebServiceERP;
  Logger: TLogger;
  Config: TAppConfig;
  Started: Boolean;
  Stopped: Boolean;
begin
  WriteLn('=== Servei Web ERP - Mode Consola ===');
  WriteLn('');

  if DebugMode then
    WriteLn('Executant en mode DEBUG')
  else
    WriteLn('Executant en mode CONSOLA');

  WriteLn('Premeu Ctrl+C o tanqueu la finestra per aturar el servei');
  WriteLn('');

  try
    // Crear configuració i logger
    Config := TAppConfig.Create;
    try
      Logger := TLogger.Create(llDebug, Config.LogPath); // Mode debug sempre amb nivell debug
      SetMainLogger(Logger);

      try
        // Crear i inicialitzar servei
        Service := TWebServiceERP.Create(nil);
        try
          // Iniciar servei
          Started := False;
          Service.ServiceStart(Service, Started);

          if Started then
          begin
            WriteLn('Servei iniciat correctament en mode consola');
            WriteLn('Premeu Enter per aturar...');

            // Esperar entrada de l'usuari
            ReadLn;

            // Aturar servei
            WriteLn('Aturant servei...');
            Service.ServiceStop(Service, Stopped);
            if Stopped then
                WriteLn('Servei aturat')
            else
                WriteLn('Error aturant el servei');
          end
          else
            WriteLn('Error iniciant el servei');

        finally
          Service.Free;
        end;
      finally
        SetMainLogger(nil);
        Logger.Free;
      end;
    finally
      Config.Free;
    end;
  except
    on E: Exception do
    begin
      WriteLn('Error executant en mode consola: ', E.Message);
      ExitCode := 1;
    end;
  end;
end;

// Punt d'entrada principal
begin
  try
    // Verificar paràmetres de línia de comandes
    if ParamCount > 0 then
    begin
      if SameText(ParamStr(1), PARAM_HELP) then
      begin
        ShowHelp;
        Exit;
      end
      else if SameText(ParamStr(1), PARAM_INSTALL) then
      begin
        if InstallService then
          ExitCode := 0
        else
          ExitCode := 1;
        Exit;
      end
      else if SameText(ParamStr(1), PARAM_UNINSTALL) then
      begin
        if UninstallService then
          ExitCode := 0
        else
          ExitCode := 1;
        Exit;
      end
      else if SameText(ParamStr(1), PARAM_START) then
      begin
        if StartService then
          ExitCode := 0
        else
          ExitCode := 1;
        Exit;
      end
      else if SameText(ParamStr(1), PARAM_STOP) then
      begin
        if StopService then
          ExitCode := 0
        else
          ExitCode := 1;
        Exit;
      end
      else if SameText(ParamStr(1), PARAM_DEBUG) then
      begin
        RunInConsoleMode(True);
        Exit;
      end
      else if SameText(ParamStr(1), PARAM_CONSOLE) then
      begin
        RunInConsoleMode(False);
        Exit;
      end
      else
      begin
        WriteLn('Paràmetre desconegut: ', ParamStr(1));
        WriteLn('Useu /? per veure l''ajuda');
        ExitCode := 1;
        Exit;
      end;
    end;

    // Si no hi ha paràmetres, executar com a servei normal
    if not Application.DelayInitialize or Application.Installing then
      Application.Initialize;

    //Application.CreateForm(TWebServiceERP, WebServiceERP);
    Application.Run;

  except
    on E: Exception do
    begin
      WriteLn('Error crític: ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
