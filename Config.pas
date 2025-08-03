unit Config;

interface

uses
  System.SysUtils, System.Classes, System.IniFiles, System.IOUtils,
  Winapi.Windows, System.Variants, System.NetEncoding, System.TypInfo,
  System.StrUtils, Logger;

type
  // Nivells de logging (duplicat per evitar dependència circular)
  //TLogLevel = (llTrace, llDebug, llInfo, llWarning, llError, llFatal);

  // Configuració de la base de dades
  TDatabaseConfig = record
    Server: string;
    Port: Integer;
    Database: string;
    Username: string;
    Password: string;
    CharSet: string;
    ConnectionTimeout: Integer;
    CommandTimeout: Integer;
    PoolSize: Integer;
  end;

  // Configuració del servidor web
  TWebServerConfig = record
    Port: Integer;
    MaxConnections: Integer;
    Timeout: Integer;
    EnableSSL: Boolean;
    SSLCertFile: string;
    SSLKeyFile: string;
    AllowCORS: Boolean;
    CORSOrigins: string;
  end;

  // Configuració de PrestaShop
  TPrestaShopConfig = record
    BaseURL: string;
    APIKey: string;
    Timeout: Integer;
    MaxRetries: Integer;
    RetryDelay: Integer;
  end;

  // Configuració PHP
  TPHPConfig = record
    PHPPath: string;
    ScriptsPath: string;
    MaxExecutionTime: Integer;
    MemoryLimit: string;
  end;

  // Configuració de l'aplicació de transport
  TTransportConfig = record
    APIEndpoint: string;
    APIKey: string;
    SyncInterval: Integer;
    MaxRetries: Integer;
  end;

  TAppConfig = class
  private
    FConfigFile: string;
    FIniFile: TIniFile;

    // Seccions de configuració
    FDatabaseConfig: TDatabaseConfig;
    FWebServerConfig: TWebServerConfig;
    FPrestaShopConfig: TPrestaShopConfig;
    FPHPConfig: TPHPConfig;
    FTransportConfig: TTransportConfig;

    // Configuració general
    FLogLevel: TLogLevel;
    FLogPath: string;
    FLogMaxSize: Int64;
    FLogMaxFiles: Integer;
    FServiceName: string;
    FServiceDisplayName: string;

    // Configuració de tasques
    FMaintenanceSchedule: string;
    FBackupSchedule: string;
    FSyncSchedule: string;

    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure CreateDefaultConfig;
    procedure ValidateConfiguration;

    // Mètodes per llegir configuració amb valors per defecte
    function ReadString(const Section, Key, Default: string): string;
    function ReadInteger(const Section, Key: string; Default: Integer): Integer;
    function ReadBool(const Section, Key: string; Default: Boolean): Boolean;
    function ReadInt64(const Section, Key: string; Default: Int64): Int64;

    // Mètodes per escriure configuració
    procedure WriteString(const Section, Key, Value: string);
    procedure WriteInteger(const Section, Key: string; Value: Integer);
    procedure WriteBool(const Section, Key: string; Value: Boolean);
    procedure WriteInt64(const Section, Key: string; Value: Int64);

    // Encriptació simple per a contrasenyes
    function EncryptPassword(const Password: string): string;
    function DecryptPassword(const EncryptedPassword: string): string;

  public
    constructor Create(const AConfigFile: string = '');
    destructor Destroy; override;

    // Mètodes públics
    procedure ReloadConfiguration;
    procedure SaveCurrentConfiguration;
    function GetConfigurationSummary: string;
    procedure SetDefaultValues;

    // Propietats de configuració de BD
    property DatabaseConfig: TDatabaseConfig read FDatabaseConfig write FDatabaseConfig;

    // Propietats de configuració del servidor web
    property WebServerConfig: TWebServerConfig read FWebServerConfig write FWebServerConfig;

    // Propietats de configuració de PrestaShop
    property PrestaShopConfig: TPrestaShopConfig read FPrestaShopConfig write FPrestaShopConfig;

    // Propietats de configuració PHP
    property PHPConfig: TPHPConfig read FPHPConfig write FPHPConfig;

    // Propietats de configuració de transport
    property TransportConfig: TTransportConfig read FTransportConfig write FTransportConfig;

    // Propietats generals
    property LogLevel: TLogLevel read FLogLevel write FLogLevel;
    property LogPath: string read FLogPath write FLogPath;
    property LogMaxSize: Int64 read FLogMaxSize write FLogMaxSize;
    property LogMaxFiles: Integer read FLogMaxFiles write FLogMaxFiles;
    property ServiceName: string read FServiceName write FServiceName;
    property ServiceDisplayName: string read FServiceDisplayName write FServiceDisplayName;

    // Propietats de programació de tasques
    property MaintenanceSchedule: string read FMaintenanceSchedule write FMaintenanceSchedule;
    property BackupSchedule: string read FBackupSchedule write FBackupSchedule;
    property SyncSchedule: string read FSyncSchedule write FSyncSchedule;

    // Ruta del fitxer de configuració
    property ConfigFile: string read FConfigFile;
  end;

// Funció auxiliar per formatejar bytes
function FormatBytes(Bytes: Int64): string;

implementation

const
  // Noms de seccions de configuració
  SECTION_DATABASE = 'Database';
  SECTION_WEBSERVER = 'WebServer';
  SECTION_PRESTASHOP = 'PrestaShop';
  SECTION_PHP = 'PHP';
  SECTION_TRANSPORT = 'Transport';
  SECTION_LOGGING = 'Logging';
  SECTION_SERVICE = 'Service';
  SECTION_SCHEDULE = 'Schedule';

  // Clau simple per a l'encriptació (en producció usar algo més segur)
  ENCRYPTION_KEY = 'WebServiceERP2024';

  // Valors per defecte
  DEFAULT_CONFIG_FILE = 'WebServiceERP.ini';
  DEFAULT_LOG_PATH = 'Logs';
  DEFAULT_LOG_MAX_SIZE = 10 * 1024 * 1024; // 10MB
  DEFAULT_LOG_MAX_FILES = 10;

{ TAppConfig }

constructor TAppConfig.Create(const AConfigFile: string);
begin
  inherited Create;

  // Determinar la ruta del fitxer de configuració
  if AConfigFile <> '' then
    FConfigFile := AConfigFile
  else
    FConfigFile := TPath.Combine(ExtractFilePath(ParamStr(0)), DEFAULT_CONFIG_FILE);

  // Crear el directori si no existeix
  ForceDirectories(ExtractFilePath(FConfigFile));

  // Crear fitxer INI
  FIniFile := TIniFile.Create(FConfigFile);

  // Si no existeix el fitxer, crear configuració per defecte
  if not FileExists(FConfigFile) then
    CreateDefaultConfig;

  // Carregar configuració
  LoadConfiguration;

  // Validar configuració
  ValidateConfiguration;
end;

destructor TAppConfig.Destroy;
begin
  if Assigned(FIniFile) then
  begin
    FIniFile.UpdateFile; // Assegurar que es guarden els canvis
    FreeAndNil(FIniFile);
  end;

  inherited Destroy;
end;

procedure TAppConfig.LoadConfiguration;
begin
  // Configuració de base de dades
  FDatabaseConfig.Server := ReadString(SECTION_DATABASE, 'Server', 'localhost');
  FDatabaseConfig.Port := ReadInteger(SECTION_DATABASE, 'Port', 3050);
  FDatabaseConfig.Database := ReadString(SECTION_DATABASE, 'Database', 'EMPRESA.FDB');
  FDatabaseConfig.Username := ReadString(SECTION_DATABASE, 'Username', 'SYSDBA');
  FDatabaseConfig.Password := DecryptPassword(ReadString(SECTION_DATABASE, 'Password', EncryptPassword('masterkey')));
  FDatabaseConfig.CharSet := ReadString(SECTION_DATABASE, 'CharSet', 'UTF8');
  FDatabaseConfig.ConnectionTimeout := ReadInteger(SECTION_DATABASE, 'ConnectionTimeout', 30);
  FDatabaseConfig.CommandTimeout := ReadInteger(SECTION_DATABASE, 'CommandTimeout', 300);
  FDatabaseConfig.PoolSize := ReadInteger(SECTION_DATABASE, 'PoolSize', 10);

  // Configuració del servidor web
  FWebServerConfig.Port := ReadInteger(SECTION_WEBSERVER, 'Port', 8080);
  FWebServerConfig.MaxConnections := ReadInteger(SECTION_WEBSERVER, 'MaxConnections', 100);
  FWebServerConfig.Timeout := ReadInteger(SECTION_WEBSERVER, 'Timeout', 30);
  FWebServerConfig.EnableSSL := ReadBool(SECTION_WEBSERVER, 'EnableSSL', False);
  FWebServerConfig.SSLCertFile := ReadString(SECTION_WEBSERVER, 'SSLCertFile', '');
  FWebServerConfig.SSLKeyFile := ReadString(SECTION_WEBSERVER, 'SSLKeyFile', '');
  FWebServerConfig.AllowCORS := ReadBool(SECTION_WEBSERVER, 'AllowCORS', True);
  FWebServerConfig.CORSOrigins := ReadString(SECTION_WEBSERVER, 'CORSOrigins', '*');

  // Configuració de PrestaShop
  FPrestaShopConfig.BaseURL := ReadString(SECTION_PRESTASHOP, 'BaseURL', '');
  FPrestaShopConfig.APIKey := DecryptPassword(ReadString(SECTION_PRESTASHOP, 'APIKey', ''));
  FPrestaShopConfig.Timeout := ReadInteger(SECTION_PRESTASHOP, 'Timeout', 60);
  FPrestaShopConfig.MaxRetries := ReadInteger(SECTION_PRESTASHOP, 'MaxRetries', 3);
  FPrestaShopConfig.RetryDelay := ReadInteger(SECTION_PRESTASHOP, 'RetryDelay', 5);

  // Configuració PHP
  FPHPConfig.PHPPath := ReadString(SECTION_PHP, 'PHPPath', 'php.exe');
  FPHPConfig.ScriptsPath := ReadString(SECTION_PHP, 'ScriptsPath', 'Scripts');
  FPHPConfig.MaxExecutionTime := ReadInteger(SECTION_PHP, 'MaxExecutionTime', 300);
  FPHPConfig.MemoryLimit := ReadString(SECTION_PHP, 'MemoryLimit', '256M');

  // Configuració de transport
  FTransportConfig.APIEndpoint := ReadString(SECTION_TRANSPORT, 'APIEndpoint', '');
  FTransportConfig.APIKey := DecryptPassword(ReadString(SECTION_TRANSPORT, 'APIKey', ''));
  FTransportConfig.SyncInterval := ReadInteger(SECTION_TRANSPORT, 'SyncInterval', 300);
  FTransportConfig.MaxRetries := ReadInteger(SECTION_TRANSPORT, 'MaxRetries', 3);

  // Configuració de logging
  FLogLevel := TLogLevel(ReadInteger(SECTION_LOGGING, 'LogLevel', Ord(llInfo)));
  FLogPath := ReadString(SECTION_LOGGING, 'LogPath', DEFAULT_LOG_PATH);
  FLogMaxSize := ReadInt64(SECTION_LOGGING, 'LogMaxSize', DEFAULT_LOG_MAX_SIZE);
  FLogMaxFiles := ReadInteger(SECTION_LOGGING, 'LogMaxFiles', DEFAULT_LOG_MAX_FILES);

  // Configuració del servei
  FServiceName := ReadString(SECTION_SERVICE, 'ServiceName', 'WebServiceERP');
  FServiceDisplayName := ReadString(SECTION_SERVICE, 'ServiceDisplayName', 'Servei Web ERP');

  // Configuració de programació de tasques
  FMaintenanceSchedule := ReadString(SECTION_SCHEDULE, 'MaintenanceSchedule', '0 2 * * *'); // Cada dia a les 2:00
  FBackupSchedule := ReadString(SECTION_SCHEDULE, 'BackupSchedule', '0 1 * * 0'); // Cada diumenge a la 1:00
  FSyncSchedule := ReadString(SECTION_SCHEDULE, 'SyncSchedule', '*/15 * * * *'); // Cada 15 minuts
end;

procedure TAppConfig.SaveConfiguration;
begin
  // Configuració de base de dades
  WriteString(SECTION_DATABASE, 'Server', FDatabaseConfig.Server);
  WriteInteger(SECTION_DATABASE, 'Port', FDatabaseConfig.Port);
  WriteString(SECTION_DATABASE, 'Database', FDatabaseConfig.Database);
  WriteString(SECTION_DATABASE, 'Username', FDatabaseConfig.Username);
  WriteString(SECTION_DATABASE, 'Password', EncryptPassword(FDatabaseConfig.Password));
  WriteString(SECTION_DATABASE, 'CharSet', FDatabaseConfig.CharSet);
  WriteInteger(SECTION_DATABASE, 'ConnectionTimeout', FDatabaseConfig.ConnectionTimeout);
  WriteInteger(SECTION_DATABASE, 'CommandTimeout', FDatabaseConfig.CommandTimeout);
  WriteInteger(SECTION_DATABASE, 'PoolSize', FDatabaseConfig.PoolSize);

  // Configuració del servidor web
  WriteInteger(SECTION_WEBSERVER, 'Port', FWebServerConfig.Port);
  WriteInteger(SECTION_WEBSERVER, 'MaxConnections', FWebServerConfig.MaxConnections);
  WriteInteger(SECTION_WEBSERVER, 'Timeout', FWebServerConfig.Timeout);
  WriteBool(SECTION_WEBSERVER, 'EnableSSL', FWebServerConfig.EnableSSL);
  WriteString(SECTION_WEBSERVER, 'SSLCertFile', FWebServerConfig.SSLCertFile);
  WriteString(SECTION_WEBSERVER, 'SSLKeyFile', FWebServerConfig.SSLKeyFile);
  WriteBool(SECTION_WEBSERVER, 'AllowCORS', FWebServerConfig.AllowCORS);
  WriteString(SECTION_WEBSERVER, 'CORSOrigins', FWebServerConfig.CORSOrigins);

  // Configuració de PrestaShop
  WriteString(SECTION_PRESTASHOP, 'BaseURL', FPrestaShopConfig.BaseURL);
  WriteString(SECTION_PRESTASHOP, 'APIKey', EncryptPassword(FPrestaShopConfig.APIKey));
  WriteInteger(SECTION_PRESTASHOP, 'Timeout', FPrestaShopConfig.Timeout);
  WriteInteger(SECTION_PRESTASHOP, 'MaxRetries', FPrestaShopConfig.MaxRetries);
  WriteInteger(SECTION_PRESTASHOP, 'RetryDelay', FPrestaShopConfig.RetryDelay);

  // Configuració PHP
  WriteString(SECTION_PHP, 'PHPPath', FPHPConfig.PHPPath);
  WriteString(SECTION_PHP, 'ScriptsPath', FPHPConfig.ScriptsPath);
  WriteInteger(SECTION_PHP, 'MaxExecutionTime', FPHPConfig.MaxExecutionTime);
  WriteString(SECTION_PHP, 'MemoryLimit', FPHPConfig.MemoryLimit);

  // Configuració de transport
  WriteString(SECTION_TRANSPORT, 'APIEndpoint', FTransportConfig.APIEndpoint);
  WriteString(SECTION_TRANSPORT, 'APIKey', EncryptPassword(FTransportConfig.APIKey));
  WriteInteger(SECTION_TRANSPORT, 'SyncInterval', FTransportConfig.SyncInterval);
  WriteInteger(SECTION_TRANSPORT, 'MaxRetries', FTransportConfig.MaxRetries);

  // Configuració de logging
  WriteInteger(SECTION_LOGGING, 'LogLevel', Ord(FLogLevel));
  WriteString(SECTION_LOGGING, 'LogPath', FLogPath);
  WriteInt64(SECTION_LOGGING, 'LogMaxSize', FLogMaxSize);
  WriteInteger(SECTION_LOGGING, 'LogMaxFiles', FLogMaxFiles);

  // Configuració del servei
  WriteString(SECTION_SERVICE, 'ServiceName', FServiceName);
  WriteString(SECTION_SERVICE, 'ServiceDisplayName', FServiceDisplayName);

  // Configuració de programació de tasques
  WriteString(SECTION_SCHEDULE, 'MaintenanceSchedule', FMaintenanceSchedule);
  WriteString(SECTION_SCHEDULE, 'BackupSchedule', FBackupSchedule);
  WriteString(SECTION_SCHEDULE, 'SyncSchedule', FSyncSchedule);

  // Forçar escriptura al disc
  FIniFile.UpdateFile;
end;

procedure TAppConfig.CreateDefaultConfig;
begin
  SetDefaultValues;
  SaveConfiguration;
end;

procedure TAppConfig.SetDefaultValues;
begin
  // Configuració de base de dades per defecte
  FDatabaseConfig.Server := 'localhost';
  FDatabaseConfig.Port := 3050;
  FDatabaseConfig.Database := 'EMPRESA.FDB';
  FDatabaseConfig.Username := 'SYSDBA';
  FDatabaseConfig.Password := 'masterkey';
  FDatabaseConfig.CharSet := 'UTF8';
  FDatabaseConfig.ConnectionTimeout := 30;
  FDatabaseConfig.CommandTimeout := 300;
  FDatabaseConfig.PoolSize := 10;

  // Configuració del servidor web per defecte
  FWebServerConfig.Port := 8080;
  FWebServerConfig.MaxConnections := 100;
  FWebServerConfig.Timeout := 30;
  FWebServerConfig.EnableSSL := False;
  FWebServerConfig.SSLCertFile := '';
  FWebServerConfig.SSLKeyFile := '';
  FWebServerConfig.AllowCORS := True;
  FWebServerConfig.CORSOrigins := '*';

  // Configuració de PrestaShop per defecte
  FPrestaShopConfig.BaseURL := '';
  FPrestaShopConfig.APIKey := '';
  FPrestaShopConfig.Timeout := 60;
  FPrestaShopConfig.MaxRetries := 3;
  FPrestaShopConfig.RetryDelay := 5;

  // Configuració PHP per defecte
  FPHPConfig.PHPPath := 'php.exe';
  FPHPConfig.ScriptsPath := 'Scripts';
  FPHPConfig.MaxExecutionTime := 300;
  FPHPConfig.MemoryLimit := '256M';

  // Configuració de transport per defecte
  FTransportConfig.APIEndpoint := '';
  FTransportConfig.APIKey := '';
  FTransportConfig.SyncInterval := 300;
  FTransportConfig.MaxRetries := 3;

  // Configuració de logging per defecte
  FLogLevel := llInfo;
  FLogPath := DEFAULT_LOG_PATH;
  FLogMaxSize := DEFAULT_LOG_MAX_SIZE;
  FLogMaxFiles := DEFAULT_LOG_MAX_FILES;

  // Configuració del servei per defecte
  FServiceName := 'WebServiceERP';
  FServiceDisplayName := 'Servei Web ERP';

  // Configuració de programació per defecte
  FMaintenanceSchedule := '0 2 * * *';    // Cada dia a les 2:00
  FBackupSchedule := '0 1 * * 0';         // Cada diumenge a la 1:00
  FSyncSchedule := '*/15 * * * *';        // Cada 15 minuts
end;

procedure TAppConfig.ValidateConfiguration;
var
  ErrorList: TStringList;
begin
  ErrorList := TStringList.Create;
  try
    // Validar configuració de BD
    if FDatabaseConfig.Server = '' then
      ErrorList.Add('El servidor de base de dades no pot estar buit');

    if (FDatabaseConfig.Port < 1) or (FDatabaseConfig.Port > 65535) then
      ErrorList.Add('El port de la base de dades ha d''estar entre 1 i 65535');

    if FDatabaseConfig.Database = '' then
      ErrorList.Add('El nom de la base de dades no pot estar buit');

    if FDatabaseConfig.Username = '' then
      ErrorList.Add('L''usuari de la base de dades no pot estar buit');

    // Validar configuració del servidor web
    if (FWebServerConfig.Port < 1) or (FWebServerConfig.Port > 65535) then
      ErrorList.Add('El port del servidor web ha d''estar entre 1 i 65535');

    if FWebServerConfig.MaxConnections < 1 then
      ErrorList.Add('El màxim de connexions ha de ser almenys 1');

    // Validar SSL si està habilitat
    if FWebServerConfig.EnableSSL then
    begin
      if (FWebServerConfig.SSLCertFile = '') or not FileExists(FWebServerConfig.SSLCertFile) then
        ErrorList.Add('El fitxer de certificat SSL no existeix o no està especificat');

      if (FWebServerConfig.SSLKeyFile = '') or not FileExists(FWebServerConfig.SSLKeyFile) then
        ErrorList.Add('El fitxer de clau SSL no existeix o no està especificat');
    end;

    // Validar ruta PHP si està especificada
    if (FPHPConfig.PHPPath <> '') and not FileExists(FPHPConfig.PHPPath) then
      ErrorList.Add('L''executable PHP no existeix a la ruta especificada: ' + FPHPConfig.PHPPath);

    // Validar directori de scripts PHP
    if (FPHPConfig.ScriptsPath <> '') and not DirectoryExists(FPHPConfig.ScriptsPath) then
      ErrorList.Add('El directori d''scripts PHP no existeix: ' + FPHPConfig.ScriptsPath);

    // Validar ruta de logs
    if FLogPath <> '' then
    begin
      try
        ForceDirectories(FLogPath);
      except
        on E: Exception do
          ErrorList.Add('No es pot crear el directori de logs: ' + FLogPath + ' - ' + E.Message);
      end;
    end;

    // Si hi ha errors, llançar excepció
    if ErrorList.Count > 0 then
      raise Exception.Create('Errors de configuració:' + sLineBreak + ErrorList.Text);

  finally
    ErrorList.Free;
  end;
end;

function TAppConfig.ReadString(const Section, Key, Default: string): string;
begin
  Result := FIniFile.ReadString(Section, Key, Default);
end;

function TAppConfig.ReadInteger(const Section, Key: string; Default: Integer): Integer;
begin
  Result := FIniFile.ReadInteger(Section, Key, Default);
end;

function TAppConfig.ReadBool(const Section, Key: string; Default: Boolean): Boolean;
begin
  Result := FIniFile.ReadBool(Section, Key, Default);
end;

function TAppConfig.ReadInt64(const Section, Key: string; Default: Int64): Int64;
var
  StrValue: string;
begin
  StrValue := FIniFile.ReadString(Section, Key, IntToStr(Default));
  try
    Result := StrToInt64(StrValue);
  except
    Result := Default;
  end;
end;

procedure TAppConfig.WriteString(const Section, Key, Value: string);
begin
  FIniFile.WriteString(Section, Key, Value);
end;

procedure TAppConfig.WriteInteger(const Section, Key: string; Value: Integer);
begin
  FIniFile.WriteInteger(Section, Key, Value);
end;

procedure TAppConfig.WriteBool(const Section, Key: string; Value: Boolean);
begin
  FIniFile.WriteBool(Section, Key, Value);
end;

procedure TAppConfig.WriteInt64(const Section, Key: string; Value: Int64);
begin
  FIniFile.WriteString(Section, Key, IntToStr(Value));
end;

function TAppConfig.EncryptPassword(const Password: string): string;
var
  I: Integer;
  Key: string;
begin
  // Encriptació XOR simple (per a producció, usar algo més segur com AES)
  Key := ENCRYPTION_KEY;
  Result := '';

  for I := 1 to Length(Password) do
  begin
    Result := Result + Chr(Ord(Password[I]) xor Ord(Key[((I - 1) mod Length(Key)) + 1]));
  end;

  // Codificar en base64 per a emmagatzematge
  Result := TNetEncoding.Base64.Encode(Result);
end;

function TAppConfig.DecryptPassword(const EncryptedPassword: string): string;
var
  I: Integer;
  Key: string;
  DecodedPassword: string;
begin
  if EncryptedPassword = '' then
  begin
    Result := '';
    Exit;
  end;

  try
    // Decodificar de base64
    DecodedPassword := TNetEncoding.Base64.Decode(EncryptedPassword);

    // Desencriptar amb XOR
    Key := ENCRYPTION_KEY;
    Result := '';

    for I := 1 to Length(DecodedPassword) do
    begin
      Result := Result + Chr(Ord(DecodedPassword[I]) xor Ord(Key[((I - 1) mod Length(Key)) + 1]));
    end;
  except
    // Si hi ha error en la desencriptació, retornar valor original
    Result := EncryptedPassword;
  end;
end;

procedure TAppConfig.ReloadConfiguration;
begin
  LoadConfiguration;
  ValidateConfiguration;
end;

procedure TAppConfig.SaveCurrentConfiguration;
begin
  SaveConfiguration;
end;

function TAppConfig.GetConfigurationSummary: string;
var
  SSLText, CORSText: string;
begin
  if FWebServerConfig.EnableSSL then
    SSLText := 'Sí'
  else
    SSLText := 'No';

  if FWebServerConfig.AllowCORS then
    CORSText := 'Sí'
  else
    CORSText := 'No';

  Result := Format(
    'Configuració del Servei Web ERP' + sLineBreak +
    '================================' + sLineBreak +
    'Fitxer de configuració: %s' + sLineBreak +
    sLineBreak +
    'Base de Dades:' + sLineBreak +
    '  Servidor: %s:%d' + sLineBreak +
    '  Base de dades: %s' + sLineBreak +
    '  Usuari: %s' + sLineBreak +
    '  Conjunt de caràcters: %s' + sLineBreak +
    '  Pool de connexions: %d' + sLineBreak +
    sLineBreak +
    'Servidor Web:' + sLineBreak +
    '  Port: %d' + sLineBreak +
    '  Màxim connexions: %d' + sLineBreak +
    '  SSL habilitat: %s' + sLineBreak +
    '  CORS habilitat: %s' + sLineBreak +
    sLineBreak +
    'PrestaShop:' + sLineBreak +
    '  URL base: %s' + sLineBreak +
    '  Timeout: %d segons' + sLineBreak +
    '  Màxim reintents: %d' + sLineBreak +
    sLineBreak +
    'PHP:' + sLineBreak +
    '  Ruta executable: %s' + sLineBreak +
    '  Ruta scripts: %s' + sLineBreak +
    '  Temps màxim execució: %d segons' + sLineBreak +
    sLineBreak +
    'Logging:' + sLineBreak +
    '  Nivell: %s' + sLineBreak +
    '  Ruta: %s' + sLineBreak +
    '  Mida màxima: %s' + sLineBreak +
    '  Màxim fitxers: %d' + sLineBreak,
    [
      FConfigFile,
      FDatabaseConfig.Server, FDatabaseConfig.Port,
      FDatabaseConfig.Database,
      FDatabaseConfig.Username,
      FDatabaseConfig.CharSet,
      FDatabaseConfig.PoolSize,
      FWebServerConfig.Port,
      FWebServerConfig.MaxConnections,
      SSLText,
      CORSText,
      FPrestaShopConfig.BaseURL,
      FPrestaShopConfig.Timeout,
      FPrestaShopConfig.MaxRetries,
      FPHPConfig.PHPPath,
      FPHPConfig.ScriptsPath,
      FPHPConfig.MaxExecutionTime,
      GetEnumName(TypeInfo(TLogLevel), Ord(FLogLevel)),
      FLogPath,
      FormatBytes(FLogMaxSize),
      FLogMaxFiles
    ]
  );
end;

// Funció auxiliar per formatejar bytes
function FormatBytes(Bytes: Int64): string;
const
  KB = 1024;
  MB = KB * 1024;
  GB = MB * 1024;
begin
  if Bytes >= GB then
    Result := Format('%.2f GB', [Bytes / GB])
  else if Bytes >= MB then
    Result := Format('%.2f MB', [Bytes / MB])
  else if Bytes >= KB then
    Result := Format('%.2f KB', [Bytes / KB])
  else
    Result := Format('%d bytes', [Bytes]);
end;

end.
