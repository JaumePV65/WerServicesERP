unit WebServer;

interface

uses
  System.SysUtils, System.Classes, Logger, Config;

type
  TWebServerErrorEvent = procedure(const AError: string) of object;

  TWebServer = class
  private
    FConfig: TAppConfig;
    FLogger: TLogger;
    FDatabaseManager: TObject;
    FRunning: Boolean;
    FOnError: TWebServerErrorEvent;
  public
    constructor Create(AConfig: TAppConfig; ALogger: TLogger; ADatabaseManager: TObject);
    destructor Destroy; override;
    
    procedure Start;
    procedure Stop;
    procedure Pause;
    procedure Resume;
    
    function IsRunning: Boolean;
    
    property OnError: TWebServerErrorEvent read FOnError write FOnError;
  end;

implementation

constructor TWebServer.Create(AConfig: TAppConfig; ALogger: TLogger; ADatabaseManager: TObject);
begin
  inherited Create;
  FConfig := AConfig;
  FLogger := ALogger;
  FDatabaseManager := ADatabaseManager;
  FRunning := False;
end;

destructor TWebServer.Destroy;
begin
  Stop;
  inherited Destroy;
end;

procedure TWebServer.Start;
begin
  FLogger.Info('Iniciant servidor web...');
  FRunning := True;
  FLogger.Info('Servidor web iniciat al port %d', [FConfig.WebServerConfig.Port]);
end;

procedure TWebServer.Stop;
begin
  if FRunning then
  begin
    FLogger.Info('Aturant servidor web...');
    FRunning := False;
    FLogger.Info('Servidor web aturat');
  end;
end;

procedure TWebServer.Pause;
begin
  FLogger.Info('Servidor web pausat');
end;

procedure TWebServer.Resume;
begin
  FLogger.Info('Servidor web continuat');
end;

function TWebServer.IsRunning: Boolean;
begin
  Result := FRunning;
end;

end.