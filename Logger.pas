unit Logger;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Threading,
  System.Generics.Collections, System.SyncObjs, System.DateUtils,
  System.StrUtils, System.TypInfo,
  Winapi.Windows;

type
  // Nivells de logging
  TLogLevel = (llTrace, llDebug, llInfo, llWarning, llError, llFatal);

  // Event handler per a notificacions de log
  TLogEvent = procedure(const AMessage: string; ALevel: TLogLevel; ATimestamp: TDateTime) of object;

  // Configuració del logger
  TLoggerConfig = record
    MaxFileSize: Int64;      // Mida màxima del fitxer en bytes
    MaxFiles: Integer;       // Nombre màxim de fitxers de backup
    LogLevel: TLogLevel;     // Nivell mínim de logging
    EnableConsole: Boolean;  // Si s'ha de mostrar també per consola
    EnableEvents: Boolean;   // Si s'han d'enviar events
    AsyncLogging: Boolean;   // Si el logging ha de ser asíncron
  end;

  TLogger = class
  private
    FLogPath: string;
    FLogFileName: string;
    FCurrentLogFile: string;
    FConfig: TLoggerConfig;
    FLogStream: TFileStream;
    FCriticalSection: TCriticalSection;
    FLogQueue: TQueue<string>;
    FLogThread: TThread;
    FShutdownEvent: TEvent;
    FOnLogEvent: TLogEvent;

    procedure InitializeLogFile;
    procedure CheckLogRotation;
    procedure RotateLogFiles;
    function FormatLogMessage(const AMessage: string; ALevel: TLogLevel; ATimestamp: TDateTime): string;
    function GetLogLevelString(ALevel: TLogLevel): string;
    procedure WriteToFile(const AFormattedMessage: string);
    procedure WriteToConsole(const AFormattedMessage: string; ALevel: TLogLevel);
    procedure ProcessLogQueue;

  public
    constructor Create(ALogLevel: TLogLevel = llInfo; const ALogPath: string = 'Logs';
                      const ALogFileName: string = '');
    destructor Destroy; override;

    // Mètodes principals de logging
    procedure Log(const AMessage: string; ALevel: TLogLevel = llInfo); overload;
    procedure Log(const AFormat: string; const AArgs: array of const; ALevel: TLogLevel = llInfo); overload;
    procedure LogException(E: Exception; const AContext: string = '');

    // Mètodes de conveniència per a cada nivell
    procedure Trace(const AMessage: string); overload;
    procedure Trace(const AFormat: string; const AArgs: array of const); overload;
    procedure Debug(const AMessage: string); overload;
    procedure Debug(const AFormat: string; const AArgs: array of const); overload;
    procedure Info(const AMessage: string); overload;
    procedure Info(const AFormat: string; const AArgs: array of const); overload;
    procedure Warning(const AMessage: string); overload;
    procedure Warning(const AFormat: string; const AArgs: array of const); overload;
    procedure Error(const AMessage: string); overload;
    procedure Error(const AFormat: string; const AArgs: array of const); overload;
    procedure Fatal(const AMessage: string); overload;
    procedure Fatal(const AFormat: string; const AArgs: array of const); overload;

    // Mètodes de configuració
    procedure SetLogLevel(ALevel: TLogLevel);
    procedure SetMaxFileSize(ASize: Int64);
    procedure SetMaxFiles(ACount: Integer);
    procedure EnableConsoleOutput(AEnable: Boolean);
    procedure EnableAsyncLogging(AEnable: Boolean);

    // Mètodes d'informació
    function GetCurrentLogSize: Int64;
    function GetLogFilePath: string;
    function IsLevelEnabled(ALevel: TLogLevel): Boolean;

    // Events
    property OnLogEvent: TLogEvent read FOnLogEvent write FOnLogEvent;
  end;

  // Thread per al logging asíncron
  TLoggerThread = class(TThread)
  private
    FLogger: TLogger;
    FShutdownEvent: TEvent;
  protected
    procedure Execute; override;
  public
    constructor Create(ALogger: TLogger; AShutdownEvent: TEvent);
  end;

  // Funció global per accedir al logger principal
  function MainLogger: TLogger;
  procedure SetMainLogger(ALogger: TLogger);

implementation

var
  GMainLogger: TLogger = nil;

const
  LOG_LEVEL_STRINGS: array[TLogLevel] of string = (
    'TRACE', 'DEBUG', 'INFO ', 'WARN ', 'ERROR', 'FATAL'
  );

  LOG_LEVEL_COLORS: array[TLogLevel] of Word = (
    FOREGROUND_INTENSITY,                                           // TRACE - Gris
    FOREGROUND_BLUE or FOREGROUND_INTENSITY,                       // DEBUG - Blau
    FOREGROUND_GREEN or FOREGROUND_BLUE or FOREGROUND_RED,         // INFO - Blanc
    FOREGROUND_GREEN or FOREGROUND_RED or FOREGROUND_INTENSITY,    // WARNING - Groc
    FOREGROUND_RED or FOREGROUND_INTENSITY,                        // ERROR - Vermell
    BACKGROUND_RED or FOREGROUND_INTENSITY                         // FATAL - Vermell amb fons
  );

  DEFAULT_MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB
  DEFAULT_MAX_FILES = 10;
  QUEUE_PROCESS_INTERVAL = 100; // 100ms

{ TLogger }

constructor TLogger.Create(ALogLevel: TLogLevel; const ALogPath: string; const ALogFileName: string);
begin
  inherited Create;

  // Configuració per defecte
  FConfig.LogLevel := ALogLevel;
  FConfig.MaxFileSize := DEFAULT_MAX_FILE_SIZE;
  FConfig.MaxFiles := DEFAULT_MAX_FILES;
  FConfig.EnableConsole := True;
  FConfig.EnableEvents := True;
  FConfig.AsyncLogging := True;

  // Configurar rutes
  FLogPath := ALogPath;
  if ALogFileName <> '' then
    FLogFileName := ALogFileName
  else
    FLogFileName := 'WebServiceERP_' + FormatDateTime('yyyymmdd', Now) + '.log';

  FCurrentLogFile := TPath.Combine(FLogPath, FLogFileName);

  // Crear objectes de sincronització
  FCriticalSection := TCriticalSection.Create;
  // CORRECCIÓ: TEvent.Create amb paràmetres correctes per Delphi 10.4
  FShutdownEvent := TEvent.Create(nil, True, False, '');
  FLogQueue := TQueue<string>.Create;

  // Inicialitzar fitxer de log
  InitializeLogFile;

  // Crear thread de logging asíncron si està habilitat
  if FConfig.AsyncLogging then
    FLogThread := TLoggerThread.Create(Self, FShutdownEvent);

  // Log inicial
  Log('Logger inicialitzat - Nivell: %s, Fitxer: %s',
      [GetLogLevelString(FConfig.LogLevel), FCurrentLogFile], llInfo);
end;

destructor TLogger.Destroy;
begin
  Log('Tancant logger...', llInfo);

  // Aturar thread asíncron
  if Assigned(FLogThread) then
  begin
    FShutdownEvent.SetEvent;
    FLogThread.Terminate;
    FLogThread.WaitFor;
    FreeAndNil(FLogThread);
  end;

  // Processar qualsevol missatge pendent
  ProcessLogQueue;

  // Alliberar recursos
  FreeAndNil(FLogStream);
  FreeAndNil(FLogQueue);
  FreeAndNil(FShutdownEvent);
  FreeAndNil(FCriticalSection);

  inherited Destroy;
end;

procedure TLogger.InitializeLogFile;
begin
  // Crear directori si no existeix
  if not DirectoryExists(FLogPath) then
    ForceDirectories(FLogPath);

  // Obrir o crear fitxer de log
  try
    if FileExists(FCurrentLogFile) then
      FLogStream := TFileStream.Create(FCurrentLogFile, fmOpenWrite or fmShareDenyNone)
    else
      FLogStream := TFileStream.Create(FCurrentLogFile, fmCreate or fmShareDenyNone);

    // Posicionar al final del fitxer
    FLogStream.Seek(0, soEnd);

  except
    on E: Exception do
    begin
      // Si no podem crear el fitxer, usar el directori temporal
      FLogPath := TPath.GetTempPath;
      FCurrentLogFile := TPath.Combine(FLogPath, FLogFileName);
      FLogStream := TFileStream.Create(FCurrentLogFile, fmCreate or fmShareDenyNone);

      WriteToConsole(Format('No s''ha pogut crear el fitxer de log a la ubicació original. Usant: %s',
                           [FCurrentLogFile]), llWarning);
    end;
  end;
end;

procedure TLogger.CheckLogRotation;
begin
  if (FLogStream.Size > FConfig.MaxFileSize) then
    RotateLogFiles;
end;

procedure TLogger.RotateLogFiles;
var
  I: Integer;
  OldFile, NewFile: string;
  BaseFileName, Extension: string;
begin
  try
    // Tancar fitxer actual
    FreeAndNil(FLogStream);

    // Extreure nom base i extensió
    BaseFileName := TPath.GetFileNameWithoutExtension(FCurrentLogFile);
    Extension := TPath.GetExtension(FCurrentLogFile);

    // Moure fitxers existents
    for I := FConfig.MaxFiles - 1 downto 1 do
    begin
      OldFile := TPath.Combine(FLogPath, Format('%s.%d%s', [BaseFileName, I, Extension]));
      NewFile := TPath.Combine(FLogPath, Format('%s.%d%s', [BaseFileName, I + 1, Extension]));

      if FileExists(OldFile) then
      begin
        if FileExists(NewFile) then
          System.SysUtils.DeleteFile(NewFile);
          //DeleteFile(NewFile);
        RenameFile(OldFile, NewFile);
      end;
    end;

    // Moure fitxer actual al .1
    NewFile := TPath.Combine(FLogPath, Format('%s.1%s', [BaseFileName, Extension]));
    if FileExists(NewFile) then
      System.SysUtils.DeleteFile(NewFile);
      //DeleteFile(NewFile);
    RenameFile(FCurrentLogFile, NewFile);

    // Crear nou fitxer
    FLogStream := TFileStream.Create(FCurrentLogFile, fmCreate or fmShareDenyNone);

    Log('Rotació de logs completada', llInfo);

  except
    on E: Exception do
    begin
      // Si falla la rotació, intentar crear nou fitxer
      if not Assigned(FLogStream) then
      begin
        try
          FLogStream := TFileStream.Create(FCurrentLogFile, fmCreate or fmShareDenyNone);
        except
          // Si tot falla, deshabilitar logging a fitxer
          FConfig.EnableConsole := True;
        end;
      end;
    end;
  end;
end;

function TLogger.FormatLogMessage(const AMessage: string; ALevel: TLogLevel; ATimestamp: TDateTime): string;
begin
  Result := Format('[%s] [%s] [%d] %s%s',
    [FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', ATimestamp),
     GetLogLevelString(ALevel),
     GetCurrentThreadId,
     AMessage,
     sLineBreak]);
end;

function TLogger.GetLogLevelString(ALevel: TLogLevel): string;
begin
  Result := LOG_LEVEL_STRINGS[ALevel];
end;

procedure TLogger.WriteToFile(const AFormattedMessage: string);
var
  MessageBytes: TBytes;
begin
  if Assigned(FLogStream) then
  begin
    try
      MessageBytes := TEncoding.UTF8.GetBytes(AFormattedMessage);
      FLogStream.WriteBuffer(MessageBytes[0], Length(MessageBytes));

      // Verificar si cal rotar els fitxers
      CheckLogRotation;
    except
      on E: Exception do
      begin
        // Si hi ha error escrivint al fitxer, intentar mostrar per consola
        WriteToConsole(Format('Error escrivint al log: %s - Missatge original: %s',
                             [E.Message, AFormattedMessage]), llError);
      end;
    end;
  end;
end;

procedure TLogger.WriteToConsole(const AFormattedMessage: string; ALevel: TLogLevel);
var
  ConsoleHandle: THandle;
  OriginalAttributes: Word;
  ConsoleInfo: TConsoleScreenBufferInfo;
begin
  if not FConfig.EnableConsole then
    Exit;

  try
    ConsoleHandle := GetStdHandle(STD_OUTPUT_HANDLE);
    if ConsoleHandle <> INVALID_HANDLE_VALUE then
    begin
      // CORRECCIÓ: Obtenir atributs originals correctament
      if GetConsoleScreenBufferInfo(ConsoleHandle, ConsoleInfo) then
      begin
        OriginalAttributes := ConsoleInfo.wAttributes;

        // CORRECCIÓ: Usar SetConsoleTextAttribute correctament
        SetConsoleTextAttribute(ConsoleHandle, LOG_LEVEL_COLORS[ALevel]);
        Write(AFormattedMessage);

        // Restaurar color original
        SetConsoleTextAttribute(ConsoleHandle, OriginalAttributes);
      end
      else
        Write(AFormattedMessage);
    end
    else
      Write(AFormattedMessage);
  except
    // Si hi ha error amb la consola, simplement escriure sense colors
    Write(AFormattedMessage);
  end;
end;

procedure TLogger.ProcessLogQueue;
var
  Message: string;
begin
  FCriticalSection.Enter;
  try
    while FLogQueue.Count > 0 do
    begin
      Message := FLogQueue.Dequeue;
      WriteToFile(Message);
    end;
  finally
    FCriticalSection.Leave;
  end;
end;

procedure TLogger.Log(const AMessage: string; ALevel: TLogLevel);
var
  FormattedMessage: string;
  Timestamp: TDateTime;
begin
  // Verificar si el nivell està habilitat
  if not IsLevelEnabled(ALevel) then
    Exit;

  Timestamp := Now;
  FormattedMessage := FormatLogMessage(AMessage, ALevel, Timestamp);

  // Enviar event si està habilitiat
  if FConfig.EnableEvents and Assigned(FOnLogEvent) then
  begin
    try
      FOnLogEvent(AMessage, ALevel, Timestamp);
    except
      // Ignorar errors en els event handlers
    end;
  end;

  // Escriure a consola si està habilitat
  if FConfig.EnableConsole then
    WriteToConsole(FormattedMessage, ALevel);

  // Escriure a fitxer
  if FConfig.AsyncLogging then
  begin
    // Afegir a la cua per al thread asíncron
    FCriticalSection.Enter;
    try
      FLogQueue.Enqueue(FormattedMessage);
    finally
      FCriticalSection.Leave;
    end;
  end
  else
  begin
    // Escriure directament al fitxer
    WriteToFile(FormattedMessage);
  end;
end;

procedure TLogger.Log(const AFormat: string; const AArgs: array of const; ALevel: TLogLevel);
begin
  Log(Format(AFormat, AArgs), ALevel);
end;

procedure TLogger.LogException(E: Exception; const AContext: string);
var
  Message: string;
begin
  if AContext <> '' then
    Message := Format('Excepció en %s: %s (%s)', [AContext, E.Message, E.ClassName])
  else
    Message := Format('Excepció: %s (%s)', [E.Message, E.ClassName]);

  Log(Message, llError);

  // Si hi ha stack trace disponible, afegir-lo
  {$IFDEF DEBUG}
  if E.StackTrace <> '' then
    Log('Stack Trace: ' + E.StackTrace, llError);
  {$ENDIF}
end;

procedure TLogger.Trace(const AMessage: string);
begin
  Log(AMessage, llTrace);
end;

procedure TLogger.Trace(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llTrace);
end;

procedure TLogger.Debug(const AMessage: string);
begin
  Log(AMessage, llDebug);
end;

procedure TLogger.Debug(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llDebug);
end;

procedure TLogger.Info(const AMessage: string);
begin
  Log(AMessage, llInfo);
end;

procedure TLogger.Info(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llInfo);
end;

procedure TLogger.Warning(const AMessage: string);
begin
  Log(AMessage, llWarning);
end;

procedure TLogger.Warning(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llWarning);
end;

procedure TLogger.Error(const AMessage: string);
begin
  Log(AMessage, llError);
end;

procedure TLogger.Error(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llError);
end;

procedure TLogger.Fatal(const AMessage: string);
begin
  Log(AMessage, llFatal);
end;

procedure TLogger.Fatal(const AFormat: string; const AArgs: array of const);
begin
  Log(AFormat, AArgs, llFatal);
end;

procedure TLogger.SetLogLevel(ALevel: TLogLevel);
var
  StatusText: string;
begin
  FConfig.LogLevel := ALevel;
  if ALevel = llTrace then StatusText := 'TRACE'
  else if ALevel = llDebug then StatusText := 'DEBUG'
  else if ALevel = llInfo then StatusText := 'INFO'
  else if ALevel = llWarning then StatusText := 'WARNING'
  else if ALevel = llError then StatusText := 'ERROR'
  else StatusText := 'FATAL';

  Log('Nivell de log canviat a: %s', [StatusText], llInfo);
end;

procedure TLogger.SetMaxFileSize(ASize: Int64);
begin
  FConfig.MaxFileSize := ASize;
  Log('Mida màxima de fitxer de log canviada a: %d bytes', [ASize], llInfo);
end;

procedure TLogger.SetMaxFiles(ACount: Integer);
begin
  FConfig.MaxFiles := ACount;
  Log('Nombre màxim de fitxers de log canviat a: %d', [ACount], llInfo);
end;

procedure TLogger.EnableConsoleOutput(AEnable: Boolean);
var
  StatusText: string;
begin
  FConfig.EnableConsole := AEnable;
  if AEnable then
    StatusText := 'habilitada'
  else
    StatusText := 'deshabilitada';
  Log('Sortida per consola %s', [StatusText], llInfo);
end;

procedure TLogger.EnableAsyncLogging(AEnable: Boolean);
var
  StatusText: string;
begin
  // Si estem canviant el mode, procesar la cua actual
  if FConfig.AsyncLogging and not AEnable then
    ProcessLogQueue;

  FConfig.AsyncLogging := AEnable;
  if AEnable then
    StatusText := 'habilitat'
  else
    StatusText := 'deshabilitat';
  Log('Logging asíncron %s', [StatusText], llInfo);
end;

function TLogger.GetCurrentLogSize: Int64;
begin
  if Assigned(FLogStream) then
    Result := FLogStream.Size
  else
    Result := 0;
end;

function TLogger.GetLogFilePath: string;
begin
  Result := FCurrentLogFile;
end;

function TLogger.IsLevelEnabled(ALevel: TLogLevel): Boolean;
begin
  Result := ALevel >= FConfig.LogLevel;
end;

{ TLoggerThread }

constructor TLoggerThread.Create(ALogger: TLogger; AShutdownEvent: TEvent);
begin
  FLogger := ALogger;
  FShutdownEvent := AShutdownEvent;
  inherited Create(False);
end;

procedure TLoggerThread.Execute;
begin
  while not Terminated do
  begin
    // Esperar interval o senyal de parada
    if FShutdownEvent.WaitFor(QUEUE_PROCESS_INTERVAL) = wrSignaled then
      Break;

    // Processar cua de missatges
    try
      FLogger.ProcessLogQueue;
    except
      on E: Exception do
      begin
        // En cas d'error, escriure directament a la consola per evitar bucles infinits
        WriteLn('Error en LoggerThread: ', E.Message);
      end;
    end;
  end;

  // Processar qualsevol missatge pendent abans de sortir
  try
    FLogger.ProcessLogQueue;
  except
    // Ignorar errors al tancar
  end;
end;

{ Funcions globals }

function MainLogger: TLogger;
begin
  Result := GMainLogger;
end;

procedure SetMainLogger(ALogger: TLogger);
begin
  GMainLogger := ALogger;
end;

// Neteja al finalitzar
initialization

finalization
  if Assigned(GMainLogger) then
    FreeAndNil(GMainLogger);

end.
