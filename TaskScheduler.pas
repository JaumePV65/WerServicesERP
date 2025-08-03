unit TaskScheduler;

interface

uses
  System.SysUtils, System.Classes, Logger, Config;

type
  TTaskSchedulerErrorEvent = procedure(const AError: string) of object;

  TTaskScheduler = class
  private
    FConfig: TAppConfig;
    FLogger: TLogger;
    FDatabaseManager: TObject;
    FRunning: Boolean;
    FOnError: TTaskSchedulerErrorEvent;
  public
    constructor Create(AConfig: TAppConfig; ALogger: TLogger; ADatabaseManager: TObject);
    destructor Destroy; override;
    
    procedure Start;
    procedure Stop;
    procedure Pause;
    procedure Resume;
    
    function IsRunning: Boolean;
    
    property OnError: TTaskSchedulerErrorEvent read FOnError write FOnError;
  end;

implementation

constructor TTaskScheduler.Create(AConfig: TAppConfig; ALogger: TLogger; ADatabaseManager: TObject);
begin
  inherited Create;
  FConfig := AConfig;
  FLogger := ALogger;
  FDatabaseManager := ADatabaseManager;
  FRunning := False;
end;

destructor TTaskScheduler.Destroy;
begin
  Stop;
  inherited Destroy;
end;

procedure TTaskScheduler.Start;
begin
  FLogger.Info('Iniciant programador de tasques...');
  FRunning := True;
  FLogger.Info('Programador de tasques iniciat');
end;

procedure TTaskScheduler.Stop;
begin
  if FRunning then
  begin
    FLogger.Info('Aturant programador de tasques...');
    FRunning := False;
    FLogger.Info('Programador de tasques aturat');
  end;
end;

procedure TTaskScheduler.Pause;
begin
  FLogger.Info('Programador de tasques pausat');
end;

procedure TTaskScheduler.Resume;
begin
  FLogger.Info('Programador de tasques continuat');
end;

function TTaskScheduler.IsRunning: Boolean;
begin
  Result := FRunning;
end;

end.