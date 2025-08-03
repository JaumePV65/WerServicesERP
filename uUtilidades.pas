unit uUtilidades;
{

   // 07/02/99  Se modifica MostrarModal, ae añade un parámetro que indica el tipo de orden
                que genera la petición de visualizar el dialogo.
}


interface

uses Classes, SysUtils; //U6bdnlib01,Controls,Forms,dialogs,Windows

  function Cifrar(mje: string): string;
  function Descifrar(mjec: string): string;
  procedure CRCInversoUpdate(data: byte; var crc: Word);
  function CalcularCRCInverso(Cadena: string): Word;
  function TestBit(B: Byte; Pos: Byte): Boolean;
  function SetBit(B: Byte; Pos: Byte; Val: Boolean): Byte;
  function CodificaString(strFormatoDestino: string;
                          strFormatoOrigen: string;
                          strOrigen: string): string;
  function HorasAMinutos(Horas: string): integer;
  function DuracionAMinutos(Duracion: string): integer;
  function ReemplazarSubcadena(Texto: string;
                               Encontrar: string;
                               Reemplazar: string): string;
  function StrEncrypt(Str: string;Key:string=''): string;
  function StrDecrypt(Str: string;Key:string=''): string;
  function _StrEncrypt(Str, Key: string): string;
  function _StrDecrypt(Str, Key: string): string;

 Const 
  kcntrsny         = 'FQAAADzHZBl9JpETaM1wUAVwn8opbNJDMOzPAR9QP9KnqHJO';
  kcntrsnyA        = 'winloradbvpz';
  kcntrsnyB        = 'akjgllbujiqr';
  kcntrsnyC        = 'lqvdloakjgll';
  kcntrsnyD        = 'kzshafaaaaaa';
  TxtPassWordSat   = 'ywjñetzbsñmw';
  TxtPassWordSatII = 'xihsisdñusñz';
  TxtLocaliza      = 'nsdzmroarmzl';
  TxtUsr1          = 'uxñebmñxrpgx';
  TxtUsr2          = 'vjkikngbtuof';
  TxtPasAccBD1     = 'igcqwpzbsvff';
  TxtPasAccBD2     = 'xñspbkñxrpgx';
  TxtUsrBD         = 'xihvcssvlmgf';
  TxtNovaVer       = 'qczusianoxsm';
  TxtAuxAlt        = 'heyrbkvovkog';

implementation

uses Mime,uAes; //U6bdnlib01

const
  // Constantes para el algoritmo de encriptación
  dimK    =  3;
  dimM    =  4;
  NumSim  = 27;
  LngMje  =  6;
  LngMjeC = 12;



  // Alfabeto utilizado en la encriptación
  alfabeto:  array [0..NumSim-1] of char =
    ('a','b','c','d','e','f','g','h','i','j',
     'k','l','m','n','ñ','o','p','q','r','s',
     't','u','v','w','x','y','z');

  // Tabla de consulta para polinomio $A001 inverso
  TablaCRC: array[0..255] of Word = (
    $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
    $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
    $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
    $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
    $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
    $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
    $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
    $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
    $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
    $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
    $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
    $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
    $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
    $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
    $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
    $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
    $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
    $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
    $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
    $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
    $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
    $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
    $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
    $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
    $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
    $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
    $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
    $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
    $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
    $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
    $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
    $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040
  );

type
  // Tipos de arrays usados en la encriptación
  TipoK = array [0..dimK-1,0..dimK-1] of SmallInt;
  TipoM = array [0..dimK-1,0..dimM-1] of SmallInt;

const
  // Matriz de encriptación
  k: TipoK  = ( (2,18,3),(5,7,11),(9,14,20) );
  // Matriz inversa de la matriz de encriptación
  kk: TipoK = ( (20,3,21),(13,20,10),(17,13,16) );

// Auxiliar para el cifrado
procedure biyeccion(mje: PChar; var m: TipoM);
var
  i,j: SmallInt;
  c,r: SmallInt;
begin
  i := 0;
  j := 0;
  while i < LngMje do begin
    c := Ord(mje[i]) div NumSim;
    r := Ord(mje[i]) mod NumSim;
    m[(j mod dimK), (j div dimK)] := c;
    m[((j+1) mod dimK), ((j+1) div dimK)] := r;
    i := i + 1;
    j := j + 2;
  end;
end;

// Auxiliar para el cifrado
procedure biyeccion2(mje: PChar; var m: TipoM);
var
  i,j: SmallInt;
begin
  for i := 0 to LngMjeC - 1 do begin
    for j := 0 to NumSim - 1 do begin
      if alfabeto[j] = mje[i] then begin
        m[(i mod dimK), (i div dimK)] := j;
        break;
      end;
    end;
  end;
end;

// Auxiliar para el cifrado
procedure mje_cifrado(var mje: string; c: TipoM);
var
  i: SmallInt;
begin
  for i := 0 to LngMjeC - 1 do begin
     mje[i+1] := alfabeto[c[(i mod dimK), (i div dimK)]];
  end;
end;

// Auxiliar para el cifrado
procedure mje_cifrado2(var mje: string; c: TipoM);
var
  i,j: SmallInt;
begin
  i := 0;
  j := 0;
  while i < LngMje do begin
    mje[i+1] := Chr(NumSim * c[(j mod dimK), (j div dimK)] + c[((j+1) mod dimK), ((j+1) div dimK)]);
    i := i + 1;
    j := j + 2;
  end;
end;

// Auxiliar para el cifrado
procedure producto(MK: TipoK; MM: TipoM; var MC: TipoM);
var
  i,j,k: SmallInt;
begin

  for i := 0 to dimK-1 do begin
    for j := 0 to dimM-1 do begin
      MC[i,j] := 0;
      for k := 0 to dimK-1 do begin
        MC[i,j] := MC[i,j] + MK[i,k]*MM[k,j];
      end;
      MC[i,j] := MC[i,j] mod NumSim;
    end;
  end;
end;

{*-----------------------------------------------------------------*\
|      nombre - Cifrar                                              |
| descripcion - Codifica una cadena de longitud 6 en una cadena     |
|               de longitud 12                                      |
|  parametros - mje: cadena a codificar                             |
|     retorna - El mje codificado                                   |
\*-----------------------------------------------------------------*}
function Cifrar(mje: string): string;
var
  mjec: string;
  m: TipoM;
  c: TipoM;
begin
  mjec := 'xxxxxxxxxxxx';

  biyeccion(PChar(mje), m);
  producto(k,m,c);
  mje_cifrado(mjec, c);

  Result := mjec;
end;

{*-----------------------------------------------------------------*\
|      nombre - Descifrar                                           |
| descripcion - Decodifica una cadena de longitud 12 en la cadena   |
|               original de longitud 6                              |
|  parametros - mjec: cadena a decodificar                          |
|     retorna - El mje decodificado                                 |
\*-----------------------------------------------------------------*}
function Descifrar(mjec: string): string;
var
  mje: string;
  m: TipoM;
  c: TipoM;
begin
  mje  := '123456';

  biyeccion2(PChar(mjec), m);
  producto(kk,m,c);
  mje_cifrado2(mje, c);
  Result := mje;
end;

{*-----------------------------------------------------------------*\
|      nombre - CRCupdate                                           |
| descripcion - Calcula el CRC16 inverso                            |
|  parametros - data: byte actual del mensaje                       |
|               crc: cálculo actual del crc                         |
\*-----------------------------------------------------------------*}

procedure  CRCInversoUpdate(data: byte; var crc: Word);
begin
  crc := (crc shr 8) xor TablaCRC[byte(crc) xor data];
end;

// Calcula el código de control de una cadena basado en CRC32 inverso
function CalcularCRCInverso(Cadena: string): Word;
var
  n: integer;
  crc: Word;
begin
  crc := 0;
  for n := 1 to Length(Cadena) do begin
    CRCInversoUpdate(ord(Cadena[n]), crc);
  end;
  Result := crc;
end;



{*-----------------------------------------------------------------*\
|      nombre - TestBit                                             |
| descripcion - Comprueba si está a 1 o a 0 un bit de un byte       |
|  parametros - B: el byte sobre el que se realiza el test          |
|               Pos: posición del bit a comprobar, siendo 0 el      |
|                    bit de peso más bajo y 1 el de peso más alto   |
|     retorna - True si el bit está a 1, False si está a 0          |
\*-----------------------------------------------------------------*}

function TestBit(B: Byte; Pos: Byte): Boolean;
var
  mascara: Byte;
begin
  mascara := $01;
  if pos > 0 then
    mascara := mascara shl Pos;
  if (B and mascara) > 0 then
     Result := True
  else
     Result:=False;
end;

{*-----------------------------------------------------------------*\
|      nombre - SetBit                                              |
| descripcion - Pone a 1 o a 0 un bit de un byte                    |
|  parametros - B: el byte sobre el que se actua                    |
|               Pos: posición del bit sobre el que se actua, siendo |
|                    0 el bit de peso más bajo y 1 el de peso más   |
|                    alto                                           |
|               Val: True si el bit se ha de poner a 1,             |
|                    False si el bit se ha de poner a 0             |
|     retorna - El byte B, con el bit modificado                    |
\*-----------------------------------------------------------------*}

function SetBit(B: Byte; Pos: Byte; Val: Boolean): Byte;
var
  mascara: Byte;
begin
  if TestBit(B,Pos) <> Val then begin
    mascara:= $01;
    if Pos > 0 then mascara := mascara shl Pos;
    Result := B xor mascara;
  end else Result := B;
end;

{*-----------------------------------------------------------------*\
|      nombre - CodificaString                                      |
| descripcion - Codifica el string destino según el formato destino |
|               a partir del string origen y del formato origen     |
|  parametros - strFormatoDestino: formato destino                  |
|               strFormatoOrigen:  formato origen                   |
|               strOrigen:         string origen                    |
|     retorna - El string codificado                                |
\*-----------------------------------------------------------------*}

function CodificaString(strFormatoDestino: string;
                        strFormatoOrigen: string;
                        strOrigen: string): string;
var
  strDestino: string;

  PosOrigen: integer;
  PosFormatoOrigen: integer;

  PosPatron: integer;
  Patron: string;
begin
  Patron := '1';
  PosOrigen := 1;
  PosFormatoOrigen := 1;

  // Inicializa el string destino
  SetLength(strDestino, Length(strFormatoDestino));
  // Copia en Destino el formato del destino
  strDestino := strFormatoDestino;

  // Recorre la cadena de formato origen
  while PosFormatoOrigen <= Length(strFormatoOrigen) do begin
    // Toma el siguiente carácter patrón del formato origen
    Patron[1] := strFormatoOrigen[PosFormatoOrigen];
    PosFormatoOrigen := PosFormatoOrigen + 1;
    // y lo busca en el formato destino
    PosPatron := Pos(Patron, strFormatoDestino);
    if PosPatron = 0 then begin
      // si no lo encuentra pasamos nos saltamos el valor correspondiente del origen
      PosOrigen := PosOrigen + 1;
    end else begin
      // si lo encuentra:
      // sustituimos el patrón del destino por el valor correspondiente del origen
      strDestino[PosPatron] := strOrigen[PosOrigen];
      PosPatron := PosPatron + 1;
      PosOrigen := PosOrigen + 1;

      // Mientras el patrón se repita en el origen
      while Patron[1] = strFormatoOrigen[PosFormatoOrigen] do begin
        // si también se repite en el destino
        if Patron[1] = strFormatoDestino[PosPatron] then begin
          // sustituimos el patrón del destino por el valor correspondiente del origen
          strDestino[PosPatron] := strOrigen[PosOrigen];
          PosPatron := PosPatron + 1;
        end;
        PosFormatoOrigen := PosFormatoOrigen + 1;
        PosOrigen := PosOrigen + 1;
      end;
    end;
  end;
  Result := strDestino;
end;

{*-----------------------------------------------------------------*\
|      nombre - HorasAMinutos                                       |
| descripcion - hhnn a #minutos                                     |
|  parametros -                                                     |
|     retorna -                                                     |
\*-----------------------------------------------------------------*}

function HorasAMinutos(Horas: string): integer;
begin
  Result := StrToInt(Copy(Horas,1,2))*60 + StrToInt(Copy(Horas,3,2));
end;

{*-----------------------------------------------------------------*\
|      nombre - DuracionAMinutos                                    |
| descripcion - ddddhhnn a #minutos                                 |
|  parametros -                                                     |
|     retorna -                                                     |
\*-----------------------------------------------------------------*}

function DuracionAMinutos(Duracion: string): integer;
begin
  Result := StrToInt(Copy(Duracion,1,4))*24*60 +
            StrToInt(Copy(Duracion,5,2))*60 +
            StrToInt(Copy(Duracion,7,2));
end;

{*-----------------------------------------------------------------*\
|      nombre - ReemplazarSubcadena                                 |
| descripcion - Reemplaza una subcadena a todo lo largo de un string|
|  parametros -                                                     |
|     retorna -                                                     |
\*-----------------------------------------------------------------*}

function ReemplazarSubcadena(Texto: string;
                             Encontrar: string;
                             Reemplazar: string): string;
var
  p: integer;
  LngTexto: integer;
  LngEncontrar: integer;
  LngReemplazar: integer;
begin
  LngTexto := Length(Texto);
  LngEncontrar := Length(Encontrar);
  LngReemplazar := Length(Reemplazar);
  p := Pos(Encontrar, Texto);
  while p > 0 do begin
    if p > 1 then begin
      Texto := Copy(Texto, 1, p-1) + Reemplazar + Copy(Texto, p+LngEncontrar, LngTexto);
    end else begin
      Texto := Reemplazar + Copy(Texto, LngEncontrar+1, LngTexto);
    end;
    LngTexto := LngTexto - LngEncontrar + LngReemplazar;
    p := Pos(Encontrar, Texto);
  end;

  Result := Texto;
end;


function StrEncrypt(Str: string;Key:string=''): string;
var
 strK:string;
begin
  if trim(key) <> '' then
     strK:= Key
  else
     strK:=  Descifrar(kcntrsnyA)+
             Descifrar(kcntrsnyB)+
             Descifrar(kcntrsnyC)+
             Descifrar(kcntrsnyD);

  result:= _StrEncrypt(Str,strK);

end;

function StrDecrypt(Str: string;Key:string=''): string;
var
 strK:string;
begin
  if trim(key) <> '' then
     strK:= Key
  else
     strK:=  Descifrar(kcntrsnyA)+
             Descifrar(kcntrsnyB)+
             Descifrar(kcntrsnyC)+
             Descifrar(kcntrsnyD);

  result:= _StrDecrypt(Str,strK);
end;

// Solo se usa como maximo los primeros 16 caracteres de Key
procedure KeyToAESKey(var Key: string; var AESKey: TAESKey);
  var
    SizeKey, SizeAESKey: Integer;
 begin
    FillChar(AESKey, Sizeof(TAESKey), 0);

    SizeKey := Length(Key) * SizeOf(Char);
    SizeAESKey := SizeOf(TAESKey);

    if SizeKey > SizeAESKey then
      Move(PChar(Key)^, AESKey, SizeAESKey)
    else
      Move(PChar(Key)^, AESKey, SizeKey);
  end;

function _StrEncrypt(Str, Key: string): string;
var
  Src: TStringStream;
  Dst: TMemoryStream;
  Size: Integer;
  AESKey: TAESKey;
  ExpandedKey: TAESExpandedKey;
begin
  Result := EmptyStr;
  Src := TStringStream.Create(Str);
  try
    Dst := TMemoryStream.Create;
    try
      KeyToAESKey(Key, AESKey);
      AESExpandKey(ExpandedKey, AESKey);
      // Guardamos el tamaño del texto original
      Size := Src.Size;
      Dst.WriteBuffer(Size, Sizeof(Size));
      // Ciframos el texto
      AESEncryptStreamECB(Src, Dst, ExpandedKey);{}
      // Lo codificamos a base64
      Result := MIMEEncode(Dst.Memory, Dst.Size);{
      //Result := BinToStr(Dst.Memory, Dst.Size);{}
    finally
      Dst.Free;
    end;
  finally
    Src.Free;
  end;
end;


function _StrDecrypt(Str, Key: string): string;
var
  Src: TMemoryStream;
  Dst: TStringStream;
  Size: Integer;
  AESKey: TAESKey;
  ExpandedKey: TAESExpandedKey;
  ADiscard: Integer;
begin
  Result := EmptyStr;
  Dst := TStringStream.Create(Str);
  try
    KeyToAESKey(Key, AESKey);
    AESExpandKey(ExpandedKey, AESKey);{}
    Src := MIMEDeCode(Str, ADiscard);
    try
      Src.Position := 0;
      // Leemos el tamaño del texto
      Src.ReadBuffer(Size, Sizeof(Size));
      AESDecryptStreamECB(Src, Dst, ExpandedKey);
      Dst.Size := Size;
      Result := Dst.DataString;
    finally
      Src.Free;
    end;
  finally
    Dst.Free;
  end;
end;


end.
