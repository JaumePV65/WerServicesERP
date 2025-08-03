unit U6bdnlib01;

{
   Nombre       : U6bdnlib01.pas
   Descripción  : Libreria de funciones de caracter general
   Fecha        : 01/01/99
   Ult. Rev.    :
 ControlaMarges
}


interface
uses Controls, SysUtils, Forms, dialogs, uBigIntsV3,
     windows,Jpeg,graphics,db,ExtCtrls,variants,GraphUtil,pngimage,
     Registry, ShellAPI,System.Classes,dateutils,Math;

     //DBAccess,MemDS, Uni,ppCtrls

function  Secs(vhorari:string ):longword;
function  ElapsedTime( hIni,hFin:string):string;
function  Secs2TStr(vSecs:longword):string;
function  LTStr2Secs(LTStr:string):longWord;
function  Secs2LTStr(vSecs:longword):string; overload;
function  Secs2LTStr(vSecs:double):string; overload;
function  Modulo(x,y:longword):longword;overload;
function  Modulo(x,y:double):double;overload;
function  NetNum(cadena:string):string;
function  strToken(var S: String; Seperator: Char): String;
function  strTokenCount(S: String; Seperator: Char): Integer;
function  strTokenCnt(S: String; Seperator: Char): Integer;
function  strTokenAt(const S:String; Seperator: Char; At: Integer): String;
function  FechaQueryIB(modo:byte;fecha:TDateTime):string;
function  ProcDig(var num:longint):string;
function  NumLletCat(num:longint):string;
function  NumLletCas(ValNum: double):string;
function  NomDatCat(data:TdateTime):string;
function  NomDatCas(data:TdateTime):string;
function  ImportReb(Import:double; const divisa:string):string;
function  CalcDigCtrl(var dc:string;ce,co,cc:string):boolean;
//function  NewCodInt(Tabla,Campo:string;BaseDatos:TUniConnection):integer;
//function  NumReg(Tabla,SqlWhere:string;BaseDatos:TUniConnection):LongInt;
function  TreuHora(data:TDateTime):TDateTime;
function  DiaSemStr            (Dia:integer):string;
function  DiaSemNom            (d:TDateTime):string;
function  DiaSemNum            (d:TDateTime):integer;
function  EscNumIB(Num:extended;dec:integer=2):string;
procedure PressAButton(h : THandle);
procedure EnvDlbClick(h : THandle);
function  NumNeg(n:double):boolean;
function  Tnany(d:TDateTime):integer;
function  EsNum(s:string):boolean;
function  EsNumF(s:string):boolean;
function  CnvNumF(s:string):double;
function  IsChAlphaS(C : Char) : Boolean;
 {-Returns true if Ch is an alpha}
function  VerificaNif(var nif:string;onif:string):boolean;
function  CalcLletraNif(var Lletra:string;nif:string):boolean;
function  RoundFloat(num:double;dec:integer=2):double;
function  iCreateFormat(iMaxChars, iDecimal: integer;
                      lZeroEnded: Boolean = False;LSepMill:Boolean=True): string;
function  ParListSql(llista,Camp:string):string;
function  VerifPatro(cadena,patro:string):boolean;

function  DesformateaNum(const Num:string;const SepMiles:string='.'):string;
Function  EsDecimal(v:double):boolean;
Function  CarregaWeb(handle:THandle;const Pag:string):LongWord;
Function  CarregaMail(handle:THandle;const Mail:string):LongWord;
procedure PulsaTecla(h : THandle;vc:integer);
function  OmpleString(caracter:char;Longitud:integer):string;
function  xEval(x,y:Extended):boolean;
Function  RevisarData(d:TDateTime):string;
Function  RevisarDataHora(d:TDateTime;Dialect:integer=0):string;
function  ControlaMarges(const camp:string;amplada:integer):string;
function  Pta2Euro(ptas:double;dec:integer=2):double;
procedure LoadJPEGFromRes(TheJPEG : string;ThePicture : TPicture);
Function  ExtraeNombFichero(f:string):string;
function  ReadKey              (Root: HKey; Key, Str: string): string;
function  IsDirectory          (const DirName: string): Boolean;
Function  NomFitxerSenseExt    (fitxer : string) : string;
Function  IncrementarMes       (Mes:integer):integer;
Function  DecrementarMes       (Mes:integer):integer;
Function  SiValLFloat(Cond:Boolean;op1,op2:double):double;
Function  SiValLogic(Cond:Boolean;op1,op2:boolean):boolean;
Function  SiValLogicClr(Cond:Boolean;clr1,clr2:TColor):TColor;
Function  SiValLogFloat(b:boolean;numd,numd2:double):double;
Function  SiValStr(i:integer;txt1,txt2:string):string;
Function  SiValLogStr(b:boolean;txt1,txt2:string):string;
Function  CnvNum(s:string):integer;
Function  SiValLInt(Cond:Boolean;op1,op2:integer):Integer;
function  emailValido(CONST Value: String): boolean;
Function  RevisarDataH         (d:TDateTime;Dialect:integer=0):string; //amb hora


//No funciona!!
function  ValidaDCSS(Numero:string):boolean;

Function  IBBoolean(cmp:string):boolean;
Function  BooleanIB(cmp:boolean):string;

function  LletCatalEur(numero:double):string;
function  ProcDigMasc(var num:longint):string;
function  NumLletCatEur(num:longint):string;
function  PartDecimal(decimal:string):integer;
//procedure CarregaImatgeRB(var TheQuery : TUniQuery; var Image : TppImage;
//                          FieldName : String);
//procedure CarregaImatge(var TheQuery : TUniQuery; var Image : TImage;
//                          FieldName : String);
//procedure CarregaImatgePNG(var TheQuery : TUniQuery;
//                         var Image : TImage;
//                          FieldName : String);
function  NetCadDeSimb(cadena:string;Tbl:string='-/.,-@#"\_'''):string;
Function  DigitoNIFCIF(var Digito:string;Const sNC:string;Msj:boolean=False):integer;
Function  CalcularNIF(l:longWord):string;
Function  CalcularCIF(cn:string):string;
Procedure AlertaSonora(Txt:string);
function  CnvNumIB(const Num:string):string;
function  strTokenFin(const S:String; Seperator: Char): String;
function  TornaPartEPartD(var partI,partD:longint;tarifa:double):boolean;
function  CnvSimbolDec(num:double;modus:char='1'):string;
function  CnvSimbolDecS(num:string;modus:char='1'):string;
function  CnvNumFN(s:string):double;
function  CnvNumData(s:string):TDate;
Function  HtmlColor            (txt,color:string;Negrita:boolean=False;ColorFondo:string=''):string;
Function  HtmlNegrita          (txt:string):string;
Function  HtmlFont             (txt,Font,color:string):string;
Function  HtmlRellenaColor     (txt,color:string):string;
function  HTMLNeteja           (Html:string):string;
function  HtmlJust             (Html:string;Modus:char='E'):string;
function  TECL_CtrlDown        (): Boolean;
function  TECL_ShiftDown       (): Boolean;
function  TECL_AltDown         ():Boolean;
Function  ObtDirTemporalWindows():string;
Function  ObtPosUltimCar       (Cadena:string):integer;
Function  TornarXmlAttr        (attr:olevariant;Vlfdt:string=''):string;
Function  TornarXmlAttrDta     (attr:olevariant;Vlfdt:TDateTime=0):TdateTime;
Function  obtStrColor          (txtCol:string):Tcolor;
procedure NetejarCuaTeclat     ();
procedure NetejarCuaRatoli     ();
Function  RetornaMes           (Fecha:TDateTime):integer;
Function  RetornaDia           (Fecha:TDateTime):integer;
Function  ValidarHora          (H:string):boolean;
Function  HoraValida           (hora:string):boolean;
Function  ProgramaExternPresent(Nom:string):boolean;
Function  obtWebAColor         (txtCol:string):Tcolor;
Function  ControlIBAN          (const Cuenta, Pais: string): string;
Function  BrowseURL            (const URL: string) : boolean;
Function  BrowseURLII          (const URL: string) : boolean;
Function  RevisaFormatHora     (hora:string;SinSeg:boolean=FALSE):string;
function  EsNumero             (s:char):boolean;
function  Ord_bdn              (s:string;idx:integer):longint;
function  SiEsUltCarTreu       (busquem:char;Cadena:string):string;
function  BinToInt             (Value: string): Integer;
function  TxtAFloat            (txt:string):Extended;
function  NetajarItem          (item:string):string;
Function  RevData              (d:TDateTime):string;
function  CopiarStrngLst       (var Org,Dst:TStringList):boolean;
function  Sgn                  (X: Extended): Integer;
function  RoundDn              (X: Extended): Extended;
function  Fix                  (X: Extended): Extended;
function  RoundDnX             (X: Extended): Extended;
function  RoundUpX             (X: Extended): Extended;
function  RoundX               (X: Extended): Extended;
function  RoundNExtend         (x: Extended; d: Integer): Extended;
Function  CopiarReg            (Org, Dst: TDataSet):boolean;
Function  ObtNomCognoms        (var Nom,Cognoms:string;Filiacio:string;
                                Separador:string=','):boolean;
Function  EsFormModal          (frm: TCustomForm) : boolean;
Function  Invertirsigne        (valor:double):double;
Function  IncreMinutos         (Hora:string;Minuts:integer):string;
Function  EvaluarMides         (Resultat,Inicial:string;Mida:integer):string;
Function  ForzarZero           (const valor:string):string;
Function  MinutsaMiliseg       (Min:integer):cardinal;
Procedure DeleteFiles          (APath, AFileSpec: string);
//Procedure DelFilesMatchPattern (const Directory, Pattern: string);
function  HtmlToStr            (strHTML: string): string;
function EXE_FileDescription: String;
function EXE_LegalCopyright: String;
function EXE_DateOfRelease: String; // Proprietary
function EXE_ProductVersion: String;
function EXE_FileVersion: String;
function GetFileModDate(filename : string) : TDateTime;
Function DateTimeDiff(Start, Stop : TDateTime) : int64;
const
  kMascFloat = '###,###,##0.00;-###,###,##0.00;#';

var
  LanguageStr:string;

implementation

//uses Umdt;

uses messages; //ststrs,QRPRNTR
 {
    Convierte un valor hora (HH:MM:SS)  a segundos
  }
function Secs(vhorari:string ):longword;
Var
  Hor,Min,Sec,Msec:word;
  vh:TDateTime;

begin

  vh:=StrToTime(vhorari);
  DecodeTime(vh,Hor,Min,Sec,Msec);
  Result:=(Hor* 3600) + (Min * 60) + Sec;
end;

{
  Calcula el tiempo transcurido entre dos variables de formato tiempo <=24 Horas
}
function ElapsedTime( hIni,hFin:string):string;
begin
  if StrToInt(NetNum(hFin)) < StrToInt(NetNum(hIni)) then
     Result:= Secs2TStr(86400+(Secs(hFin)-Secs(hIni)))
  else
     Result:=Secs2TStr(Secs(hFin)-Secs(hIni));
end;

{
  Devuelve una cadena de formato tiempo <=24 a partir de segundos
}

function Secs2TStr(vSecs:longword):string;
var
  valor:longword;
  cadena:string;
begin
  valor:= modulo( (vSecs div 3600),24); //Horas
  cadena:=format('%4.2d',[valor]);
  valor:= modulo( (vSecs div 60),60); //Minutos
  cadena:=cadena+format(':%2.2d',[valor]);
  valor:= modulo( vSecs,60); //Segundos
  cadena:=cadena+format(':%2.2d',[valor]);
  result:=Cadena;
end;
{
  Convierte Segundos a formato tiempo > 24 horas

  ejem:   Secs2LTStr(445560) -> '123:45:60'
}
function Secs2LTStr(vSecs:longword):string;overload;
var
  valor:longword;
  cadena:string;
begin
  valor:= (vSecs div 3600); //Horas
  cadena:=format('%d',[valor]);
  valor:= modulo( (vSecs div 60),60); //Minutos
  cadena:=cadena+format(':%2.2d',[valor]);
  valor:= modulo( vSecs,60); //Segundos
  cadena:=cadena+format(':%2.2d',[valor]);
  result:=Cadena;
end;

function Secs2LTStr(vSecs:double):string; overload;
var
  valor:double;
  cadena:string;
begin
  valor:= trunc(vSecs / 3600); //Horas
  cadena:=format('%.0f',[valor]);
  valor:= modulo( (vSecs / 60),60); //Minutos
  cadena:=cadena+formatfloat(':00',valor); //format(':%2.0f',[valor]);

  valor:= modulo( vSecs,60); //Segundos
  cadena:=cadena+formatfloat(':00',valor); //format(':%0.2f',[valor]);
  result:=Cadena;
end;
{
  Convierte un cadena en formato tiempo > 24 horas en segundos
     LTStr2Secs('123:45:60') --> 445560
}
function LTStr2Secs(LTStr:string):longWord;
var
  x,y:integer;
begin
  Result:=0;
  x:=StrTokenCnt(LTStr,':')+1;
  if x > 0 then
    begin
       For y:=1 To X do
         begin
            case y-1 of
             0: Result:= StrToInt(StrTokenAt(LTStr,':',y-1)) * 3600;
             1: Result:=Result+ StrToInt(StrTokenAt(LTStr,':',y-1)) * 60 ;
             2: Result:=Result+StrToInt(StrTokenAt(LTStr,':',y-1));
            end;
            Application.ProcessMessages;
         end;
    end;
end;

function Modulo(x,y:longword):longword;overload;
begin
  result:=x-(x div y)*y;
end;

function Modulo(x,y:double):double;overload;
begin
  result:=x-trunc(x / y)*y;
end;

{
  Limpia una cadena de cualquier valor que no sea numérico
}
function NetNum(cadena:string):string;
var
 pos,long:integer;
begin
 long:=Length(cadena);
 pos:=1;
 Result:='';
 if long > 0 then
 begin
    While pos <= long do
    begin
      if (cadena[pos] in ['0','1','2','3','4','5','6','7','8','9']) then
         Result:=Result+cadena[pos];
      application.ProcessMessages;
      inc(pos);
    end;
 end else Result:=cadena;
end;

{
  Devuelve el numero de apariciones de un separador dentro de una cadena
}
function  strTokenCnt(S: String; Seperator: Char): Integer;
var
  x:integer;
begin
 Result:=0;
 for x:=1 to length(s) do
 begin
   if s[x-1] = Seperator then Inc(Result);
   application.ProcessMessages;
 end;
end;

{
 Devuelve el primer valor que precede al primer separador
}
function strToken(var S: String; Seperator: Char): String;
var
  I               : Word;
begin
  I:=Pos(Seperator,S);
  if I<>0 then
  begin
    Result:=System.Copy(S,1,I-1);
    System.Delete(S,1,I);
  end else
  begin
    Result:=S;
    S:='';
  end;
end;

{
  No utilizar
}
function strTokenCount(S: String; Seperator: Char): Integer;
begin
  Result:=0;
  while StrToken(S,Seperator)<>'' do Inc(Result);
end;

{
  Devuelve el valor que precede al numero de separador especificado
}
function strTokenAt(const S:String; Seperator: Char; At: Integer): String;
var
  j,i: Integer;
begin
  Result:='';
  j := 1;
  i := 0;
  while (i<=At ) and (j<=Length(S)) do
  begin
    if S[j]=Seperator then
       Inc(i)
    else if i = At then
       Result:=Result+S[j];
    Inc(j);
  end;
end;


{
  Modo 0: Fecha Inicial
       1: Fecha Final
}
function FechaQueryIB(modo:byte;fecha:TDateTime):string;
begin
// if modo=1 then
//  result:=FormatDateTime('mm/dd/yyyy 23:59:59',fecha)
// else
//  result:=FormatDateTime('mm/dd/yyyy 00:00:00',fecha);
// Result:= FormatDateTime('mm/dd/yyyy',fecha);

 if modo=1 then
  result:=format(' Cast(''%s'' as TimeStamp ) ',[FormatDateTime('mm/dd/yyyy 23:59:59',fecha)])
 else
  result:=format(' Cast(''%s'' as TimeStamp ) ',[FormatDateTime('mm/dd/yyyy 00:00:00',fecha)]);

end;

{
  Devuelve el valor numérico es letras: idioma Catalán
}
function NumLletCat(num:longint):string;
var
 numero,nummil,numuni,centena,decena:longint;
 nommil,nomcen,nomdec,nomuni,nom_imp,guion:string;
begin
   guion:= '----------------------------------------'+
           '----------------------------------------';
   numero  := num;
   nummil  := numero div 1000;  //INT(numero/1000)
   numuni  := numero-nummil*1000;
   centena := numuni div 100; //INT(numuni/100)
   decena  := numuni-centena*100;
   nomcen  := ' ';
   nomcen  :=ProcDig(centena);
   nomdec  := ' ';
   nomdec:=ProcDig(decena);
   case centena of
      0 :  nomuni:=TRIM(nomdec);
      1 :  nomuni:=TRIM('CENT '+nomdec);
    else   nomuni:=TRIM(nomcen+'-CENTES '+nomdec)
   end;
   centena := nummil div 100; //INT(nummil/100)
   decena  := nummil-centena*100;
   nomcen  := ' ';
   nomcen  :=ProcDig(centena);
   nomdec  := ' ';
   nomdec  :=ProcDig(decena);
   case centena of
      0 :  nommil:=TRIM(nomdec);
      1 :  nommil:=TRIM('CENT '+nomdec);
    else   nommil:=TRIM(nomcen+'-CENTES '+nomdec);
   end;
   if nummil = 0 then nom_imp := TRIM(nomuni)
   else if nummil = 1 then nom_imp := TRIM('MIL '+nomuni)
        else  nom_imp := TRIM(nommil+' MIL '+nomuni);
   nom_imp := TRIM(nom_imp)+' '+copy(guion,1,61-length(nom_imp));
  result:=nom_imp;
end;

function ProcDig(var num:longint):string;
var
  nom_num,nom_dig,nom_dec:string;
  unidad,decena:longint;
begin
nom_dig := 'UNA    DUES   TRES   QUATRE CINC   SIS    '+
           'SET    VUIT   NOU    DEU    ONCE   DOTZE  '+
           'TRETZE CATORZEQUINZE SETZE  DISSET DIVUIT '+
           'DINOU  VINT   ';

nom_dec := 'VINT-I   TRENTA   QUARANTA CINQUANTASEIXANTA '+
           'SETANTA  VUITANTA NORANTA';

if num <= 20 then
   if num=0 then  nom_num :=''
   else
     begin
      nom_num := copy(nom_dig,(num-1)*7+1,7);
      nom_num := TRIM(nom_num);
     end
else
  begin
    decena := num div 10;
    unidad := num-decena*10;
    nom_num := TRIM(copy(nom_dec,(decena-2)*9+1,9));
    if unidad <> 0 then
       if num < 30 then  nom_num := nom_num+'-'+TRIM(copy(nom_dig,(unidad-1)*7+1,7))
       else nom_num := nom_num+' '+TRIM(copy(nom_dig,(unidad-1)*7+1,7));
  end;
  result:=nom_num;
end;

{
Devuelve el valor numérico es letras: idioma Castellano
}
function NumLletCas(ValNum: double):string;
const
 Unidades: Array [1..9] of string[7] = ('una','dos','tres','cuatro','cinco',
                                        'seis','siete','ocho','nueve');
 Decenas: Array [1..9] of string[10] = ('diez','veinte','treinta','cuarenta',
                                        'cincuenta','sesenta','setenta',
                                        'ochenta','noventa');
 Centenas: Array [1..9] of string[12] = ('cien','doscient','trescient',
                                         'cuatrocient','quinient','seiscient',
                                         'setecient','ochocient','novecient');
var
 inicio,resul : integer;
 tros,uni,dec,texto,cadena,guion : string;
 numero:double;
 sortir:boolean;
begin
 guion:= '----------------------------------------'+
         '----------------------------------------';
 inicio:=1;
 resul:=0;
 sortir:=true;
 texto:='';
 numero:=ValNum;
 cadena:=Format('%9.0f',[numero]);
 While sortir Do
 begin
   tros:=copy(cadena,inicio,3);
   if  Trim(tros)= '' then tros:='0';
   if StrToInt(tros) = 0 then
   begin
      if inicio=7 then break;
      if inicio < 4 then inicio:=4
      else inicio:=7;
      continue;
   end;
   resul:= StrToInt(tros) DIV 100;  // centenas
   if resul <> 0 then
   begin
      case resul of
        1 : begin
             if  StrToInt(tros) = 100 then texto:=texto+'cien '
                     else texto:=texto+'ciento ';
            end;
        9 : if inicio=1 then texto:=texto+'novecientos '
            else texto:=texto+'novecientas ';
      else
          if inicio < 4 then  texto:=texto+Centenas[resul]+'os '
          else texto:=texto+Centenas[resul]+'as ';
      end;
   end;
   resul:=StrToInt(copy(tros,2,2)) DIV 10; // decenas
   if resul <> 0 then
     begin
        dec:=copy(tros,2,2);
        uni:=copy(tros,3,1);
        case StrToInt(dec) of
           11 : texto:=texto+'once ';
           12 : texto:=texto+'doce ';
           13 : texto:=texto+'trece ';
           14 : texto:=texto+'catorce ';
           15 : texto:=texto+'quince ';
           16 : texto:=texto+'dieciséis ';
           17 : texto:=texto+'diecisiete ';
           18 : texto:=texto+'dieciocho ';
           19 : texto:=texto+'diecinueve ';
           21..29: if StrToInt(uni) = 0 then texto:=texto+'veinti '+' '
                   else texto:=texto+'veinti '+Unidades[StrToInt(uni)]+' ';
        else
          if StrToInt(uni)=0 then texto:=texto+Decenas[StrToInt(copy(dec,1,1))]+' '
          else texto:=texto+Decenas[StrToInt(copy(dec,1,1))]+' y '+Unidades[StrToInt(uni)]+' ';
        end;
     end
   else begin
          uni:=copy(tros,3,1);
          if uni='1' then
            begin
               if inicio=7 then texto:=texto+'uno '
               else texto:=texto+'un ';
            end
          else
            begin
               if uni='0' then texto:=texto+' '
               else texto:=texto+' '+Unidades[StrToInt(uni)]+' ';
            end;

  end;
  // Escribe millones o miles  y pasa al siguiente miembro
  case inicio of
     1: begin
          if texto='un' then texto:=texto+'millón '
          else texto:=texto+'millones ';
          inicio:=4;
        end;
     4: begin
          if (copy(TrimLeft(texto),1,3)='un ') and (copy(TrimLeft(texto),1,6) <> 'un mill' ) then
             texto:='mil '
          else texto:=texto+'mil ';
          inicio:=7;
        end;
     7: Sortir:=False;
  end;
 end;
 Trim(texto);
 Texto:=UpperCase(Texto[1])+copy(texto,2,length(texto)-1);
 Result:=Trim(Texto)+' '+copy(guion,1,61-length(Texto));
end;

function NomDatCat(data:TdateTime):string;
var
 mesos,nommes:string;
 Year, Month, Day: Word;
begin
 DecodeDate(data, Year, Month, Day);
 mesos := 'GENER   FEBRER  MARÇ    ABRIL   MAIG    JUNY    '+
          'JULIOL  AGOST   SETEMBREOCTUBRE NOVEMBREDESEMBRE';
 nommes:= Trim(copy(mesos,((Month-1)*8)+1,8));
 if Month in [4,5] then nommes:='D'' '+nommes
 else nommes:='DE '+nommes;

 nommes:=IntToStr(Day)+' '+nommes+' DE '+IntToStr(year);
 Result:=nommes;
end;

function NomDatCas(data:TdateTime):string;
var
 mesos,nommes:string;
 Year, Month, Day: Word;
begin
 DecodeDate(data, Year, Month, Day);
 mesos := 'Enero     Febrero   Marzo     Abril     Mayo      Junio     '+
          'Julio     Agosto    SeptiembreOctubre   Noviembre Diciembre ';
 nommes:= Trim(copy(mesos,((Month-1)*10)+1,10));
 nommes:=IntToStr(Day)+' de '+nommes+' de '+IntToStr(year);
 Result:=nommes;
end;

function ImportReb(Import:double; const divisa:string):string;
var
 Tmp:string;
begin
 if divisa='P' then Tmp:='***'+FloatToStr(Import)+' Ptas.'
 else Tmp:='***'+FloatToStr(Import)+' Euros';
 Result:=Tmp;
end;

{
  Calcula los dígitos de control de una cuenta bancaria según el algoritmo
  proporcionado por el CSB.

  dc -> contentra los dos digitos de control (1= validación entidad-oficina,
                                              2= validación número de cuenta)
  ce -> código de entidad (obligatorio 4 caracteres (complementar a ceros))
  co -> código de oficina (obligatorio 4 caracteres (complementar a ceros))
  cc -> número de cuenta  (obligatorio 10 caracteres (complementar a ceros))

  Si ce,co o cc esta vacio devuleve False.
}
function CalcDigCtrl(var dc:string;ce,co,cc:string):boolean;
var
  vr: array[1..10] of integer;
  dc1,dc2:integer;
  x,y:integer;
  tmp:longint;
  ctmp:string;
begin
  vr[ 1]:= 6;  vr[ 2]:= 3;  vr[ 3]:= 7; vr[ 4]:= 9; vr[ 5]:=10;
  vr[ 6]:= 5;  vr[ 7]:= 8;  vr[ 8]:= 4; vr[ 9]:= 2; vr[10]:= 1;
  if (length(ce) = 0) or (length(co)=0) or (length(cc)=0) then
     result:=False
  else
    begin
        // Calcula 1 DC
        ctmp:=ce+co;
        y:=9;
        tmp:=0;
        for x:=1 to 8 do
        begin
           dec(y);
           tmp:=tmp + StrToInt(copy(ctmp,x,1)) * vr[y];
        end;
        dc1:= 11 - (tmp mod 11);
        if dc1 = 10 then dc1:=1;
        if dc1 = 11 then dc1:=0;
        // Calcula 2 DC
        ctmp:=cc;
        y:=11;
        tmp:=0;
        for x:=1 to 10 do
        begin
           dec(y);
           tmp:=tmp + CnvNum(copy(ctmp,x,1)) * vr[y];
        end;
        dc2:= 11 - (tmp mod 11);
        if dc2 = 10 then dc2:=1;
        if dc2 = 11 then dc2:=0;
        dc:=IntToStr(dc1)+IntToStr(dc2);
        Result:=True;
    end;
end;

//function NewCodInt(Tabla,Campo:string;BaseDatos:TUniConnection):integer;
//var
//  Query:TUniQuery;
//  StrSql: string;
//begin
//  Query:= TUniQuery.Create(nil);
//  Try
//     Query.Connection:=BaseDatos;
//     StrSql := format('SELECT MAX(%s) FROM %s',[Campo,Tabla]);
//     Query.SQL.Clear;
//     Query.SQL.Add(StrSql);
//     Query.Open;
//     if Query.Fields[0].IsNull then
//        Result := 1
//     else
//        Result := Query.Fields[0].Value + 1;
//     Query.Close;
//  Finally
//    Query.Free;
//  End;
//end;
//
//function NumReg(Tabla,SqlWhere:string;BaseDatos:TUniConnection):LongInt;
//var
//  Query:TUniQuery;
//  StrSql: string;
//begin
//  Query:= TUniQuery.Create(nil);
//  Try
//     Query.Connection:=BaseDatos;
//     if SqlWhere <> '' then
//       StrSql := format('SELECT COUNT(*) FROM %s %s ',[Tabla,SqlWhere])
//     else
//       StrSql := format('SELECT COUNT(*) FROM %s; ',[Tabla]);
//
//     Query.SQL.Clear;
//     Query.SQL.Add(StrSql);
//     Query.open;
//     Result:= Query.Fields[0].AsInteger;
//     Query.Close;
//  Finally
//    Query.Free;
//  End;
//end;

function TreuHora(data:TDateTime):TDateTime;
 begin
   Result:=StrToDateTime(FormatDateTime('dd/mm/yyyy',data));
 end;

function DiaSemStr(Dia:integer):string;
begin
  Case Dia of
      1: Result:='Diumenge';
      2: Result:='Dilluns';
      3: Result:='Dimarts';
      4: Result:='Dimecres';
      5: Result:='Dijous';
      6: Result:='Divendres';
      7: Result:='Dissabte';
  end;
end;

Function DiaSemNom(d:TDateTime):string;
begin
  Case DayOfWeek(d) of
      1: Result:='Diumenge';
      2: Result:='Dilluns';
      3: Result:='Dimarts';
      4: Result:='Dimecres';
      5: Result:='Dijous';
      6: Result:='Divendres';
      7: Result:='Dissabte';
  end;
end;

function DiaSemNum(d:TDateTime):integer;
begin
  Case DayOfWeek(d) of
      1: Result:=7; //Domingo
      2: Result:=1; //Lunes
      3: Result:=2; //Martes
      4: Result:=3; //Miércoles
      5: Result:=4; //Jueves
      6: Result:=5; //Viernes
      7: Result:=6  //Sábado
      else Result:=0;
  end;
end;


function  EscNumIB(Num:extended;dec:integer=2):string;
var
 Tmp:string;
 p:integer;
begin
 if dec=2 then
   Tmp:=FormatFloat('0.00',Num)
 else
   Tmp:=FormatFloat(iCreateFormat(8+dec,dec,False,False),Num);
 p:=pos(',',Tmp);
 if p > 0 then Tmp[p]:='.';
 Result:=Tmp;
end;

{ Importada de NK}
function iCreateFormat(iMaxChars, iDecimal: integer;
                      lZeroEnded: Boolean = False;LSepMill:Boolean=True): string;
var
  i: integer;
  cTmpFormat: string;
begin
  Result := EmptyStr;
  if iDecimal <> 0 then
  begin
    cTmpFormat := '0';
    cTmpFormat := cTmpFormat + '.';
    for i := 0 to Pred(iDecimal) do
      cTmpFormat := cTmpFormat + '0';
  end (*if*)
  else if lZeroEnded then
    cTmpFormat := '0'
  else
    cTmpFormat := '#';
  for i := 1 to Pred(iMaxChars - iDecimal) do
  begin
    if LSepMill then
      begin
       if (i mod 3 = 0) then
         cTmpFormat := ',' + cTmpFormat;
     end;
    cTmpFormat := '#' + cTmpFormat;
  end (*for*);
  Result := cTmpFormat;
end (*CreateFormat*);

procedure PressAButton(h : THandle);
begin
  PostMessage(h, WM_LBUTTONDOWN, 0, 0);
  PostMessage(h, WM_LBUTTONUP, 0, 0);
end;

procedure EnvDlbClick(h : THandle);
begin
  PostMessage(h, WM_MBUTTONDBLCLK, 0, 0);
end;

function NumNeg(n:double):boolean;
begin
  if (n - abs(n) <> 0) then Result:=True
  else Result:=False;
end;

function Tnany(d:TDateTime):integer;
var
   Year, Month, Day: Word;
begin
  DecodeDate(d, Year, Month, Day);
  Result:=year;
end;

function EsNum(s:string):boolean;
var
 n:integer;
begin
Result:=True;
 try
  n:=StrToInt(s);
 except
  Result:=False;
 end;
end;

function EsNumF(s:string):boolean;
var
 n:double;
begin
Result:=True;
 try
  n:=StrToFloat(s);
 except
  Result:=False;
 end;
end;

function CnvNumF(s:string):double;
begin
result:=StrToFloatDef(s,0);
{ try
  result:=StrToFloat(s);
 except
  Result:=0;
 end;}
end;

function IsChAlphaS(C : Char) : Boolean;
 {-Returns true if Ch is an alpha}
begin
{$IFDEF WIN32}
  Result := Windows.IsCharAlpha(C);
{$ELSE}
  Result := WinProcs.IsCharAlpha(C);
{$ENDIF}
end;
{
function VerificaNif(var nif:string;onif:string):boolean;
function TeLletra(nif:string):boolean;
var
 l:integer;
 c:string;
begin
  Result:=False;
  l:=length(nif);
  if IsChAlphaS(nif[1]) or IsChAlphaS(nif[l]) then
    begin
      if (IsChAlphaS(nif[1]) and IsChAlphaS(nif[l])) then Result:=True // extranger
      else
         begin
           if IsChAlphaS(nif[1]) then  // societats
             begin
               if nif[1] in ['A','B','C','D','E','F','G','H','J','N','P','Q','R','S','U','V','W','X','Y']  then Result:=True
               else Result:=False;
             end
           else
             begin
               if CalcLletraNif(c,copy(nif,1,l-1)) then
                  begin
                     if c=nif[l] then Result:=True
                     else
                        begin
                          ShowMessage(format('La lletra hauria d''esser [%s]',
                                     [c]));
                          Result:=False;
                        end;
                  end
               else result:=False;
             end;
         end;
    end
  else Result:=False;
end;
var
 n:integer;
 tmp:string;
 Seguir:boolean;
begin
 Result:=False;
 tmp:='';
 nif:='-1';
 Seguir:=False;

    for n:=1 to length(onif) do
     begin
        application.ProcessMessages;
        if onif[n]='-' then continue;
        if onif[n]=',' then continue;
        if onif[n]='.' then continue;
        if onif[n]='/' then continue;
        if onif[n]='_' then continue;
        if onif[n]=' ' then continue;
        tmp:=tmp+onif[n];
     end;

     if length(tmp) < 9 then Result:=False
     else
        begin
          if length(tmp) > 9 then
            begin
              tmp:=copy(tmp,1,9);
            end
          else Result:=True;
        end;

     if TeLletra(tmp) then Result:=True
     else Result:=False;

     if Result then nif:=tmp
     else nif:='-1';

end; }

function CalcLletraNif(var Lletra:string;nif:string):boolean;
var
 num:integer;
 Lletres:string;
begin
 Result:=False;
 // DNI - ((DNI div 23) * 23).
 Lletres:='TRWAGMYFPDXBNJZSQVHLCKE';
 if trim(nif)<> '' then
  begin
    if EsNum(trim(nif)) then
      begin
        if length(trim(nif)) = 8 then
          begin
           num:=StrToInt(trim(nif));
           Lletra:=Lletres[(num mod 23)+1 ];
           Result:=True;
          end;
      end;
  end;
end;

{function RoundFloat(num:double;dec:integer=2):double;
var
 n:extended;
begin
 if num=0 then Result:=0
 else
  begin
    n:=power(10,dec);
    //Result:=StrToFloat(FormatFloat(kMascFloat,num));
    Result:=trunc( ((num)*n ) + 0.5)/n;
  end;
end;}
{function RoundFloat(num:double;dec:integer=2):double;
var
 Tmp:string;
 p:integer;
begin
 if dec=2 then
   Tmp:=FormatFloat('0.00',Num)
 else
   Tmp:=FormatFloat(iCreateFormat(8+dec,dec,False,False),Num);
 Result:=StrToFloat(tmp);
end;}
{function RoundFloat(num:double;dec:integer=2):double;
 Function Ajustar(tmp:string):double;
 var
  i,l:integer;
  s:string;
  d:double;
 begin
  result:=0;
  s:=FormatFloat('0.000',StrToFloat(tmp));
  i:=pos(',',s);
  if i > 0 then
   begin
     l:=length(copy(s,i+1, length(s)-i));
     if l = 3 then
       begin
         if s[length(s)]='5' then result:= 0.01;
       end;
   end;
 end;
var
 Tmp:string;
 ajuste:double;
begin
 if dec=2 then
   begin
     tmp:=FloatToStr(Num);
     ajuste:=Ajustar(tmp);
   end else ajuste:=0;
 if dec=2 then
//   Tmp:=FormatFloat('0.00',Num)
     Tmp:=FormatFloat('0.00',StrToFloat(FloatToStr(Num)))
 else
   Tmp:=FormatFloat(iCreateFormat(8+dec,dec,False,False),Num);
   
Result:=StrToFloat(tmp)+ajuste;
end;  }
function RoundFloat(num:double;dec:integer=2):double;
 Function Ajustar(tmp:string):double;
 var
  i,l:integer;
  s:string;
  d,d2:double;
 begin
  result:=0;
  s:=FormatFloat('0.0000',StrToFloat(tmp));
  i:=pos(',',s);
  if i > 0 then
   begin
     l:=length(copy(s,i+1, length(s)-i));
     if l >= 3 then
       begin
         //if s[length(s)]='5' then result:= 0.01;
         if s[i+3]='5' then result:= 0.01;
       end;
   end;
  if result > 0 then
   begin
      //d2:=StrToFloat((FormatFloat(iCreateFormat(8+2,2,False,False),Num)));
     d2:=StrToFloat((FormatFloat(iCreateFormat(8+2,2,False,False), StrToFloat(FloatToStr(Num))) ));
    // d2:=StrToFloat(FormatFloat('0.00',StrToFloat(FloatToStr(Num))));
    if d2 < 0 then
     d:=StrToFloat(copy(s,1,i+2))- result
    else
     d:=StrToFloat(copy(s,1,i+2))+ result;
     if d2=d then result:=0;
   end;

 end;
var
 Tmp:string;
 ajuste:double;
begin
 if num <> 0 then
   begin
     if dec=2 then
       begin
         tmp:=FloatToStr(Num);
         ajuste:=Ajustar(tmp);
       end else ajuste:=0;
     if dec=2 then
    //   Tmp:=FormatFloat('0.00',Num)
         Tmp:=FormatFloat('0.00',StrToFloat(FloatToStr(Num)))
     else
        Tmp:=FormatFloat(iCreateFormat(8+dec,dec,False,False),StrToFloat(FloatToStr(Num)) );
      // Tmp:=FormatFloat(iCreateFormat(8+dec,dec,False,False),Num);

       if num < 0 then
         Result:=StrToFloat(tmp)- ajuste
       else
         Result:=StrToFloat(tmp)+ ajuste;
  end
 else
  result:=0;
end;

function ParListSql(llista,Camp:string):string;
var
 x,y,p:integer;
 s,sa,sb:string;
 l,la:TStringList;
begin
  l:=TStringList.create;
  la:=TStringList.create;
  Try
   x:=StrTokenCnt(llista,',')+1;
   For y:=1 To X do
     begin
       s:=StrTokenAt(llista,',',y-1);
       p:=pos('-',s);
       if p=0  then l.add(s)
       else
         begin
            if la.Count > 0 then
               s:= format(' or (%s >= %s and %s <= %s )',
                       [camp,copy(s,1,p-1),
                        camp,copy(s,p+1,length(s)-p) ])
            else
               s:= format(' (%s >= %s and %s <= %s )',
                       [camp,copy(s,1,p-1),
                        camp,copy(s,p+1,length(s)-p) ]);


            la.Add(s);
         end;
       Application.ProcessMessages;
     end;
   s:='';
   for x:=0 to l.count-1 do
    begin
      if x=1 then s:=s+',';
      s:=s+ l[x];
     Application.ProcessMessages;
    end;

   for x:=0 to la.count-1 do
    begin
      sa:=sa+ la[x];
     Application.ProcessMessages;
    end;
   Finally
    la.Free;
    l.Free;
   End;
 if trim(s) = '' then sb:=''
 else
   begin
      if trim(sa) = '' then
        sb:=format(' %s IN (%s)',[camp,s])
      else sb:=format(' %s IN (%s) or ',[camp,s]);
   end;
 result:=format(' (  %s  %s  ) ',[sb,sa]);
end;

function VerifPatro(cadena,patro:string):boolean;
var
 x:integer;
begin
 result:=True;
 if trim(cadena) = '' then result:=false
 else
   begin
     for x:=1 to length(cadena) do
      begin
        if pos(cadena[x],patro) = 0 then
          begin
            result:=False;
            break;
          end;
        application.ProcessMessages;
      end;
   end;
end;

function DesformateaNum(const Num:string;const SepMiles:string='.'):string;
var
 x:integer;
 tmp:string;
begin
 tmp:='';
 Result:=Num;
 for x:=1 to length(num) do
 begin
   if Num[x] = SepMiles then continue
   else tmp:=tmp+num[x]
 end;
 Result:=tmp;
end;

Function EsDecimal(v:double):boolean;
begin
   if (v - int(v)) = 0 then Result:=False
   else Result:=True;
end;

Function CarregaWeb(handle:THandle;const Pag:string):LongWord;
var
 cadena:string;
begin
  cadena:=pag;
  cadena:=StringReplace(pag, 'http:\\','',[rfReplaceAll, rfIgnoreCase]);
  cadena:='HTTP:\\'+trim(cadena);
  result:=shellexecute(handle,'open',PCHAR(cadena),nil,nil,sw_show);
end;

Function CarregaMail(handle:THandle;const Mail:string):LongWord;
var
 cadena:string;
begin
  cadena:=Mail;
  cadena:=StringReplace(Mail, 'mailto:','',[rfReplaceAll, rfIgnoreCase]);
  cadena:='mailto:'+trim(cadena);
  result:=shellexecute(handle,'open',PCHAR(cadena),nil,nil,sw_show);
end;

procedure PulsaTecla(h : THandle;vc:integer);
begin
 PostMessage(h, WM_KEYDOWN , vc, 0);
 PostMessage(h, WM_KEYUP , vc, 0);
end;

function OmpleString(caracter:char;Longitud:integer):string;
begin
 Result := StringOfChar(caracter, Longitud);
end;

function  xEval(x,y:Extended):boolean;
begin
  if (x+int(y))/2 = x then result:=True
  else result:=False;
end;

function RevisarData(d:TDateTime):string;
var
 s:string;
begin
 if d = 0 then Result:='null'
 else
   begin
     s:=format('cast(''%s'' as date)',
     [FormatDateTime('mm/dd/yyyy',d)]);
     result:=s;
   end;
end;

function RevisarDataHora(d:TDateTime;Dialect:integer=0):string;
var
 s:string;
begin
 if d = 0 then Result:='null'
 else
   begin
     if Dialect=3 then
      begin
        s:=format('cast(''%s'' as TimeStamp )',
         [FormatDateTime('mm/dd/yyyy hh:nn:ss',d)]);
         result:=s;
      end
     else
      begin
         s:=format('cast(''%s'' as date)',
         [FormatDateTime('mm/dd/yyyy hh:nn:ss',d)]);
         result:=s;
      end;
   end;
end;

function ControlaMarges(const camp:string;amplada:integer):string;
begin
if (trim(camp)='') or (amplada <= 0 ) then result:=camp
else
 begin
   if length(camp)<= amplada then result:=Camp
   else
    begin
      result:=copy(camp,1,amplada);
    end;
 end;
end;

function Pta2Euro(ptas:double;dec:integer=2):double;
begin
   result:=RoundFloat(ptas/166.386,dec);
end;

procedure LoadJPEGFromRes(TheJPEG : string;ThePicture : TPicture);
var
  ResHandle : THandle;
  MemHandle : THandle;
  MemStream : TMemoryStream;
  ResPtr    : PByte;
  ResSize   : Longint;
  JPEGImage : TJPEGImage;
begin
  ResHandle := FindResource(hInstance, PChar(TheJPEG), 'JPG');
  MemHandle := LoadResource(hInstance, ResHandle);
  ResPtr    := LockResource(MemHandle);
  MemStream := TMemoryStream.Create;
  JPEGImage := TJPEGImage.Create;
  ResSize := SizeOfResource(hInstance, ResHandle);
  if  ResSize > 0 then
   begin
     MemStream.SetSize(ResSize);
     MemStream.Write(ResPtr^, ResSize);
     FreeResource(MemHandle);
     MemStream.Seek(0, 0);
     JPEGImage.LoadFromStream(MemStream);
     ThePicture.Assign(JPEGImage);
   end
  else FreeResource(MemHandle);
  JPEGImage.Free;
  MemStream.Free;
end;
Function ExtraeNombFichero(f:string):string;
var
  p:integer;
begin
    if trim(f) = '' then result:=f
    else
      begin
        p:=pos('.',f);
        if p=0 then result:=f
        else result:=copy(f,1,p-1);
      end;
end;

// This function read from the system's registry...
// -----------------------------------------------------------------------------
// WARNING !!!                                                                 -
// Don't use TRegistry.OpenKey before it open a key for Read/Write access,     -
// and in a machine when the user haven't the registry write permission failed -
// -----------------------------------------------------------------------------

function ReadKey(Root: HKey; Key, Str: string): string;
var
  Reg: HKey;
  Size: Integer;
  DataType: Integer;
begin
  if (Key <> '') and (Key[1] = '\') then
    Delete(Key, 1, 1);
  if RegOpenKeyEx(Root, PChar(Key), 0, KEY_READ, Reg) = ERROR_SUCCESS then
  begin
    if RegQueryValueEx(Reg, PChar(Str), nil,
      @DataType, nil, @Size) = ERROR_SUCCESS then
    begin
      SetLength(result, Size);
      RegQueryValueEx(Reg, PChar(Str), nil, @DataType, PByte(PChar(result)), @Size);
      // Cut the last #0 char...
      Result := Copy(Result, 1, Length(Result) - 1);
    end
    else
      Result := '';
    RegCloseKey(Reg);
  end;
end;

{$IFDEF __XEIII}

{$ELSE}

{$ENDIF}

Function RevisarDataH(d:TDateTime;Dialect:integer=0):string; //amb hora
var
 s:string;
begin
 if d = 0 then Result:='null'
 else
   begin
     if Dialect=3 then
      begin
        s:=format('cast(''%s'' as TimeStamp )',
         [FormatDateTime('mm/dd/yyyy hh:nn:ss',d)]);
         result:=s;
      end
     else
      begin
         s:=format('cast(''%s'' as date)',
         [FormatDateTime('mm/dd/yyyy hh:nn:ss',d)]);
         result:=s;
      end;
   end;
end;


//Valida DCSS
//Se trata de una cifra de 11 dígitos para el caso de las cuentas de cotización de empresas, y de 12 dígitos en el caso del número de un trabajador.
//Los dos últimos dígitos constituyen los dígitos de control.
//Estas dos ultimas cifras del número completo, debe ser el resto
//de dividir todo el número exceptuando los dos ultimos digitos,
//que son los de control entre 97.

//No funciona!!

function ValidaDCSS(Numero:string):boolean;
 var
   Limpio : string;
   i      : integer;
//   uno, dos: integer;
//   dos: integer;
   uno,dos    : real;

 begin
   {El numero de la seguridad social debe entrarse con este
    formato:
            28/1234567/40
    o bien:
            28/12345678/40
    En función de que se trate del numero de una empresa
    o del numero de un trabajador.
    }
    Limpio:='';
    for i:=1 to Length(Numero) do
      if Numero[i] in ['0'..'9'] then Limpio:=Limpio+Numero[i];

    {Si no tiene 11 ó 12 digitos, no es válido}
    if (Length(Limpio)=11) or (Length(Limpio)=12) then
    begin
        {Result:= StrToInt( copy(Limpio,1,Length(Limpio)-2) )
                 mod 97 =
                 StrToInt( copy(Limpio,Length(Limpio)-1,2) );
        }
        Result:=( Uno - Trunc(Uno/97) *97)=Dos;

    end
      else Result:=FALSE;

 end;

Function IBBoolean(cmp:string):boolean;
begin
 if trim(cmp)='' then result:=False
 else
  begin
    if uppercase(cmp)='T' then result:=True
    else result:=False;
  end;
end;

Function  BooleanIB(cmp:boolean):string;
begin
 if cmp then result:='T'
 else result:='F';
end;

function  CnvNum(s:string):integer;
begin
 {
 try
  result:=StrToInt(s);
 except
  Result:=0;
 end;}
 result:=StrToIntDef(s,0);
end;

Function SiValStr(i:integer;txt1,txt2:string):string;
begin
 result:='';
 case i of
   0: result:=Txt1;
   1: result:=Txt2;
 end;
end;
Function  SiValLogStr(b:boolean;txt1,txt2:string):string;
begin
 result:='';
 if b then  result:=Txt1
 else  result:=Txt2;
end;

Function  SiValLogFloat(b:boolean;numd,numd2:double):double;
begin
 result:=0;
 if b then  result:=numd
 else  result:=numd2;
end;

Function  SiValLogic(Cond:Boolean;op1,op2:boolean):boolean;
begin
  result:=False;
  if Cond then result:=op1
  else result:=op2;
end;

Function  SiValLogicClr(Cond:Boolean;clr1,clr2:TColor):TColor;
begin
  result:=clr1;
  if Cond then result:=clr1
  else result:=clr2;
end;


Function  SiValLFloat(Cond:Boolean;op1,op2:double):double;
begin
  result:=0;
  if Cond then result:=op1
  else result:=op2;
end;

Function  SiValLInt(Cond:Boolean;op1,op2:integer):Integer;
begin
  result:=0;
  if Cond then result:=op1
  else result:=op2;
end;

//{}funció que obté la part decimal d'una xifra treient el " 0, " .
function PartDecimal(decimal:string):integer;
Var
  xifra:double;
  s:string;
begin
       xifra:=abs(StrToFloaT(decimal));//treu signe
       if length(decimal) < 4 then
        decimal:=formatfloat('###,###,##0.00;0',xifra)//omple amb zeros
       else
        decimal:=FloatToStr(xifra);
        s:= copy(decimal,3,2);//pren les xifres q hi ha després de la coma o el punt
      Result:=StrToInt(s);
end;           

//{PASSA Una xifra en Euros a lletres(negatives,més gran d'un milió,)}
function NumLletCatEur(num:longint):string;
var
 n:integer;
 cadena:string;
 numero,nummili,nummiliuni,nummil,numuni,centena,decena:longint;
 nommil,nommili,nomcen,nomdec,nomuni,nom_imp,guion,signe:string;
begin
   guion:= '----------------------------------------'+
           '----------------------------------------';
   //Si és negatiu...
   if num < 0 then
     begin
       cadena:=IntToStr(num);
       n:=length(cadena);
       signe:='MENYS';
       cadena:=copy(cadena,2,n);
       num:=StrToInt(cadena);
     end
   else
     signe:='';
   numero := num;
   nummili    := numero div 1000000;
   nummiliuni := numero - nummili*1000000;
   nummil  := nummiliuni div 1000;  //INT(numero/1000)
   numuni  := nummiliuni-nummil*1000;
   centena := numuni div 100; //INT(numuni/100)
   decena  := numuni-centena*100;
   nomcen  := ' ';
   nomcen  :=ProcDigMasc(centena);
   nomdec  := ' ';
   nomdec:=ProcDigMasc(decena);

   if decena = 0  then  nomdec  := ' ';  //Afegit 21/12/2009  si no 100 -> posava CENT ZERO EUROS

     case centena of
        0 :  nomuni:=TRIM(nomdec);
        1 :  nomuni:=TRIM('CENT '+nomdec);
      else   nomuni:=TRIM(nomcen+'-CENTS '+nomdec)
     end;
   centena := nummil div 100; //INT(nummil/100)
   decena  := nummil-centena*100;
   nommili := ProcDigMasc(nummili);
   nomcen  := ' ';
   nomcen  :=ProcDigMasc(centena);
   nomdec  := ' ';
   nomdec  :=ProcDigMasc(decena);
   case centena of
      0 :  nommil:=TRIM(nomdec);
      1 :  nommil:=TRIM('CENT '+nomdec);
    else   nommil:=TRIM(nomcen+'-CENTS '+nomdec);
   end;
  if nummili = 0 then
    begin
     if nummil = 0 then nom_imp := TRIM(nomuni)
     else if nummil = 1 then nom_imp := TRIM('MIL '+nomuni)
        else  nom_imp := TRIM(nommil+' MIL '+nomuni);
    end
  else if nummili = 1 then nom_imp := TRIM('UN '+'MILIO '+nommil+' MIL '+nomuni)
       else if nummili = 2 then nom_imp := TRIM('DOS '+'MILIONS'+nommil+' MIL '+nomuni)
        else  nom_imp := TRIM(nommili+' MILIONS '+nommil+' MIL '+nomuni);

//   nom_imp := signe+' '+TRIM(nom_imp)+' '+copy(guion,1,61-length(nom_imp));
  nom_imp := signe+' '+TRIM(nom_imp)+' '; //posar Euros
  result:=nom_imp;
end;
function  LletCatalEur(numero:double):string;
Var
  s,dig1:string;
  inteur,fraceur:longint;
  numint,numfrac:double;
begin
  //part sencera        
   numint:=INT(numero);
   s:=FloatToStr(numint);        
   inteur:=StrToInt(s);        
   //part fraccionaria        
   numfrac:=FRAC(StrToFloat(formatfloat('##0.00;-##0.00;0',numero)));
   s:=FloatToStr(numfrac);        
   if s <> '0' then        
    begin        
      fraceur:=PartDecimal(s);        
      dig1:= copy(s,3,1);//pren el 1er. dígit per separt per si és ZERO        
      if dig1='0' then //primer dígit =0
        Result:= NumLletCatEur(inteur)+'EUROS'+' amb '+' ZERO '+
                          NumLletCatEur(fraceur)+'-----'
      else
        Result:= NumLletCatEur(inteur)+'EUROS'+' amb '+
                          NumLletCatEur(fraceur)+'-----';        
    end        
   else        
     Result  := NumLletCatEur(inteur)+'EUROS -----';
end;
//MASCULÍ (EUROS)
function ProcDigMasc(var num:longint):string;
var
  nom_num,nom_dig,nom_dec:string;
  unidad,decena:longint;
begin
 nom_dig := 'UN     DOS    TRES   QUATRE CINC   SIS    '+
            'SET    VUIT   NOU    DEU    ONZE   DOTZE  '+
            'TRETZE CATORZEQUINZE SETZE  DISSET DIVUIT '+
            'DINOU  VINT  ';
 nom_dec := 'VINT-I   TRENTA   QUARANTA CINQUANTASEIXANTA '+
            'SETANTA  VUITANTA NORANTA';

 if num <= 20 then
   if num=0 then  nom_num :='ZERO'
   else
     begin
      nom_num := copy(nom_dig,(num-1)*7+1,7);
      nom_num := TRIM(nom_num);
     end
 else
  begin
    decena := num div 10;
    unidad := num-decena*10;
    nom_num := TRIM(copy(nom_dec,(decena-2)*9+1,9));
    if unidad <> 0 then
       if num < 30 then  nom_num := nom_num+'-'+TRIM(copy(nom_dig,(unidad-1)*7+1,7))
       else nom_num := nom_num+' '+TRIM(copy(nom_dig,(unidad-1)*7+1,7));
  end;
  result:=nom_num;
end;
//procedure CarregaImatgeRB(var TheQuery : TUniQuery;
//                         var Image : TppImage;
//                          FieldName : String);
//var
//    JPeg : TJPegImage;
//  BS   : TBlobStream;
//begin
//
//  if not TBlobField(TheQuery.FieldByName(FieldName)).IsNull then  //is there a picture?
//    begin
//      JPeg := TJpegImage.Create;
//      BS := TBlobStream.Create(TBlobField(TheQuery.FieldByName(FieldName)),bmRead);
//      JPeg.LoadFromStream(BS);
//      //JPeg.SaveToFile('H:\bustia\publiH.jpg');
//      image.picture.Assign(JPeg);
//      JPeg.FREE;
//      BS.Free;
//      Image.visible := true;
//    end
//  else
//    begin
//      Image.Picture.Bitmap.Assign(Nil);  //there is no Image
//      Image.visible := false;
//    end;
//
// end;
//
// procedure CarregaImatge(var TheQuery : TUniQuery;
//                         var Image : TImage;
//                          FieldName : String);
//var
//    JPeg : TJPegImage;
//  BS   : TBlobStream;
//begin
//
//  if not TBlobField(TheQuery.FieldByName(FieldName)).IsNull then  //is there a picture?
//    begin
//      JPeg := TJpegImage.Create;
//      BS := TBlobStream.Create(TBlobField(TheQuery.FieldByName(FieldName)),bmRead);
//      JPeg.LoadFromStream(BS);
//      //JPeg.SaveToFile('H:\bustia\publiH.jpg');
//      image.picture.Assign(JPeg);
//      JPeg.FREE;
//      BS.Free;
//      Image.visible := true;
//    end
//  else
//    begin
//      Image.Picture.Bitmap.Assign(Nil);  //there is no Image
//      Image.visible := false;
//    end;
//
// end;
//
//
// procedure CarregaImatgePNG(var TheQuery : TUniQuery;
//                         var Image : TImage;
//                          FieldName : String);
//var
//  _PNG : TPNGObject;
//  BS   : TBlobStream;
//begin
//
//  if not TBlobField(TheQuery.FieldByName(FieldName)).IsNull then  //is there a picture?
//    begin
//      _PNG := TPNGObject.Create;
//      BS := TBlobStream.Create(TBlobField(TheQuery.FieldByName(FieldName)),bmRead);
//      _PNG.LoadFromStream(BS);
//      image.picture.Assign(_PNG);
//      _PNG.FREE;
//      BS.Free;
//      Image.visible := true;
//    end
//  else
//    begin
//      Image.Picture.Bitmap.Assign(Nil);  //there is no Image
//      Image.visible := false;
//    end;
//
// end;

 // ['-/.,-@#''"\_]
function NetCadDeSimb(cadena:string;Tbl:string='-/.,-@#"\_'''):string;
var
 p,long:integer;
begin
 long:=Length(cadena);
 p:=1;
 Result:='';
 if long > 0 then
 begin
    While p <= long do
    begin
     if (pos(cadena[p],Tbl) = 0) then  Result:=Result+cadena[p];
      application.ProcessMessages;
      inc(p);
    end;
 end else Result:=cadena;
end;

Function CalcularNIF(l:longWord):string;
begin
  result:=copy('TRWAGMYFPDXBNJZSQVHLCKE', (l Mod 23) + 1, 1);
end;
 {
  Si devuelve 1 Ok, cualquier otro caso err
}
Function DigitoNIFCIF(var Digito:string;Const sNC:string;Msj:boolean=False):integer;
Const
 kOk        =  1;
 kBuit      =  0;
 kErrLng    = -1;
 kErrLletra = -2;
 kLletraCIF = 'ABCDEFGHJKLMNPQRSUVW';
 kNCBuit    = '¡NIF - CIF no pot estar buit!';
 kNCErrLng  = ' [NIF/CIF] Longitud incorrecte!';
 kNCErrLng1 = ' [NIF/CIF] Longitud incorrecte. Ha d''haver 8 dígits.!';
 kNCErrLng2 = ' [NIF/CIF]  Longitud incorrecte. Ha d''haver 7 dígits.!';
 kNCErrLng3 = ' [NIF/CIF]  Longitud incorrecte. Ha d''haver 7 dígits.!';
 kNCErrLlet = ' La primera lletra no correspón a un CIF!';
var
 s,tmp:string;
begin
 Digito:='';
 if trim(sNC)= '' then
  begin
    if Msj then ShowMessage(kNCBuit);
    result:=kBuit;
  end
 else result:=kOk;

 if result  > 0 then
  begin
    s:=UpperCase(sNC);
    s:=NetCadDeSimb(s,'-,./_ ');
    if length(s) < 8 then
     begin
      if Msj then ShowMessage(kNCErrLng);
      result:=kErrLng;
     end;
  end;

 if result  > 0 then
  begin
    if EsNum(s[1]) then
       begin
         tmp:=Uppercase(copy(s,1,8));
         tmp:=NetCadDeSimb(tmp,'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ');
         if length(tmp) = 8  then
          Digito:=CalcularNIF(StrToInt(copy(s,1,8))) // NIF
         else
          begin
           if Msj then ShowMessage(kNCErrLng1);
           result:=kErrLng;
          end;
       end
    else
     begin
       if s[1] in ['X','Y'] then // NIE
         begin
           tmp:=Uppercase(copy(s,2,7));
           tmp:=NetCadDeSimb(tmp,'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ');
           if length(tmp) = 7  then
             begin
               if s[1] = 'X' then
                  Digito:=CalcularNIF(StrToInt('0'+copy(s,2,7))) // NIE
               else
                  Digito:=CalcularNIF(StrToInt('1'+copy(s,2,7))) // NIE
             end
           else
            begin
             if Msj then ShowMessage(kNCErrLng2);
             result:=kErrLng;
            end;
         end
       else
         begin
            if pos(s[1],kLletraCIF) <> 0 then
             begin
              tmp:=Uppercase(copy(s,2,6));
              tmp:=NetCadDeSimb(tmp,'ABCDEFGHIJKLMNÑOPQRSTUVWXYZ');
              if length(tmp) = 6  then
                 Digito:=CalcularCIF(s) // CIF
              else
               begin
                if Msj then ShowMessage(kNCErrLng3);
                result:=kErrLng;
               end;
             end
            else
              begin
                if Msj then ShowMessage(kNCErrLlet);
                result:= kErrLletra;
              end;
         end;
     end;
  end;
end;
Function CalcularCIF(cn:string):string;
 Function SumNum(n:integer):integer;
 var
  s:string;
 begin
  if n > 9 then
   begin
    s:=IntToStr(n);
    result:= StrToInt(s[1]) + StrToInt(s[2]);
   end else result:=n;
 end;
 Function obtNum(i:integer; const kA,cn:string):integer;
 begin
   result:= StrToInt(cn[ strToInt(kA[i])+1]);
 end;
const
 kA='246';
 kB='1357';
var
 i:integer;
 A,B,C:integer;
begin
 A:=0;B:=0;
 for i:= 1 to length(kA) do
 begin
   A:=A+ obtNum(i,kA,cn);
 end;
 for i:= 1 to length(kb) do
 begin
   B:=B+ SumNum(obtNum(i,kB,cn) * 2);
 end;
 C:=A+B;
 C:= 10 - (C Mod 10);
 IF C = 10 then result:='0J'
 else result:=IntToStr(C)+Chr(C + 64);
end;


function VerificaNif(var nif:string;onif:string):boolean;
function VerifaIntermedios(nif:string):boolean;
var
 l,x:integer;
begin
 Result:=True;
 l:= length(nif);
 for x:=2 to l-1 do
 begin
  if IsChAlphaS(nif[x]) then
   begin
     Result:=False;
     break;
   end;
  Application.ProcessMessages;
 end;
end;
function TeLletra(nif:string;msj:boolean=True):boolean;
Const
 kOk       =  1;
 kBuit     =  0;
 kErrLng   = -1;
 kErrLletra= -2;
 kLletraCIF= 'ABCDEFGHJKLMNPQRSUVW';
 kNCBuit   = '¡NIF - CIF no puede estar vacío!';
 kNCErrLng = '¡Longitud incorrecta!';
 kNCErrLlet= 'La primera lletra no correspond a un CIF';
 kNCErrDLlet='La darrera lletra es incorrecta!';
 kDigCtrlErr='Dígit de control erroni!';
var
 l:integer;
 c,Digito:string;
begin
  Result:=False;
  l:=length(nif);
  if IsChAlphaS(nif[1]) or IsChAlphaS(nif[l]) then
    begin
      result:=True;
      if (IsChAlphaS(nif[1]) and IsChAlphaS(nif[l])) then
        begin
          if VerifaIntermedios(nif) then
            Result:=True // Podría ser
          else Result:=False;
        end;
     if result then     
         begin
           if IsChAlphaS(nif[1]) then  // societats
             begin
               if nif[1] in ['A','B','C','D','E','F','G','H','J','N','P','Q','R','S','U','V','W','X','Y'] then
                 begin
                   //Comprovar Lletra/Número Final
                     if nif[1] in ['X','Y'] then // NIE
                       begin
                         if nif[1] = 'X' then
                           Digito:=CalcularNIF(StrToInt('0'+copy(nif,2,7))) // NIE
                         else
                           Digito:=CalcularNIF(StrToInt('1'+copy(nif,2,7))); // NIE
                         if nif[l] = Digito then
                           Result:=True
                         else
                           begin
                            if Msj then ShowMessage(kNCErrDLlet);
                             result:=False;
                           end;
                       end
                     else
                      begin
                       if pos(nif[1],kLletraCIF) <> 0 then
                         begin
                           Digito:=CalcularCIF(nif); // CIF
                           if (nif[l] = Digito[1]) or
                              (nif[l] = Digito[2]) then
                             result:= True
                           else
                            begin
                               if Msj then
                                 ShowMessage(kDigCtrlErr);
                               result:= False;
                            end;   
                           
                         end
                       else
                          begin
                           if Msj then
                              ShowMessage(kNCErrLlet);
                           result:= False;
                          end;
                      end;

                 end
               else Result:=False;
             end
           else
             begin
               if CalcLletraNif(c,copy(nif,1,l-1)) then
                  begin
                     if c=nif[l] then Result:=True
                     else Result:=False;
                  end
               else result:=False;
             end;
         end;
    end
  else Result:=False;
end;
var
 n:integer;
 tmp:string;
begin
 Result:=False;
 tmp:='';
 nif:='-1';

    for n:=1 to length(onif) do
     begin
        application.ProcessMessages;
        if onif[n]='-' then continue;
        if onif[n]=',' then continue;
        if onif[n]='.' then continue;
        if onif[n]='/' then continue;
        if onif[n]='_' then continue;
        if onif[n]=' ' then continue;
        tmp:=tmp+onif[n];
     end;

     if length(tmp) < 9 then Result:=False
     else
        begin
          if length(tmp) > 9 then
            begin
              tmp:=copy(tmp,1,9);
            end
          else Result:=True;
        end;
     if Result then
       begin
        if trim(tmp) <> '' then
          begin
           if TeLletra(tmp) then Result:=True
           else Result:=False;
          end else Result:=False;
       end;

     if Result then nif:=tmp
     else nif:='-1';
end;

Procedure AlertaSonora(Txt:string);
begin
    messagebeep($ff00);
    messagebeep($ffff);
    messagebeep($be12);
    ShowMessage(Txt);
end;
function  CnvNumIB(const Num:string):string;
var
 Tmp:string;
 p:integer;
begin
 if trim(num) = '' then result:='0'
 else
  begin
    Tmp:=num;
    p:=pos(',',Tmp);
    if p > 0 then Tmp[p]:='.';
    Result:=Tmp;
  end;
end;

function strTokenFin(const S:String; Seperator: Char): String;
var
  i :Integer;
  ok:boolean;
begin
  Result:='';
  i := 0;
  ok:= False;
  while (i<=Length(S)) do
  begin
    if S[i]=Seperator then
      begin
       ok:=True;
       Inc(i);
      end;
    if ok then Result:=Result+S[i];
    Inc(i);
  end;
end;
function TornaPartEPartD(var partI,partD:longint;tarifa:double):boolean;
var
  Preu:double;
  s,fmt:string;
  numint,numfrac,xifra,xifraTxc:double;
begin
  if tarifa > 0 then
   begin

      xifra:= Roundfloat(tarifa);

      //part entera
      numint:=INT(xifra);
      s:=FloatToStr(numint);
      partI:=StrToInt(s);


      //part decimal
      numfrac:=Frac(xifra);
      s:=FloatToStr(Roundfloat(numfrac));
      partD:=PartDecimal(s);

      result:=true;
   end
  else
   begin
      partI:= 0;
      partD:= 0;
      result:=false;
   end;

end;
{ Modus 1 Europa a USA
  Modus 2 USA  a Europa }
function  CnvSimbolDec(num:double;modus:char='1'):string;
var
 ntmp:string;
 p:integer;
 sepdecI:string;
 sepdecF:char;
begin
 result:='0';
 if num <> 0 then
  begin
     ntmp:= FloatToStr(num);
     case modus of
       '1': begin
               sepdecI:=',';
               sepdecF:='.';
            end;
       else begin
               sepdecI:='.';
               sepdecF:=',';
            end;
     end;
     p:= pos(sepdecI,ntmp);
     if p <= 0 then result:=ntmp
       else
          begin
            ntmp[p]:=sepdecF;
            result:=ntmp;
          end;
  end;
end;
function  CnvSimbolDecS(num:string;modus:char='1'):string;
var
 p:integer;
 sepdecI:string;
 sepdecF:char;
begin
 result:='0';
 if trim(num) <> '' then
  begin   
     case modus of
       '1': begin
               sepdecI:=',';
               sepdecF:='.';
            end;
       else begin
               sepdecI:='.';
               sepdecF:=',';
            end;
     end;
     p:= pos(sepdecI,num);
     if p <= 0 then result:=num
       else
          begin
            num[p]:=sepdecF;
            result:=num;
          end;
  end;
end;
function CnvNumFN(s:string):double;
begin
 if trim(s)<>'' then
  s:=CnvSimbolDecS(s,'2');
 result:=StrToFloatDef(s,0);
 {
 try
  result:=StrToFloat(s);
 except
  Result:=0;
 end;}
end;

function  CnvNumData(s:string):TDate;
begin
 try
  result:=StrToDate(s);
 except
  Result:=0;
 end;
end;

Function HtmlColor(txt,color:string;Negrita:boolean=False;ColorFondo:string=''):string;
var
 fnd:string;
begin
 if Negrita then result:=HtmlNegrita(txt)
 else result:=txt;

 if trim(ColorFondo) = '' then fnd:=''
 else fnd:= format(' bgcolor="%s" ',[ColorFondo]);

 result:=format('<FONT %s color="%s"  >%s</FONT>',[fnd,color,result]);
end;

Function HtmlRellenaColor(txt,color:string):string;
begin
 result:=format('<FONT bgcolor="%s">%s</FONT>',[color,txt]);
end;

Function HtmlNegrita(txt:string):string;
begin
 result:=format('<B>%s</B>',[txt]);
end;

Function HtmlFont(txt,Font,color:string):string;
begin
  result:=format('<FONT face="%s" color="%s">%s</FONT>',[Font,color,txt]);
end;

function  HTMLNeteja (Html:string):string;
var
  TIni, TFin, TLong: integer;
begin
  TIni := Pos( '<', Html);      // Busco el primer <

  while (TIni > 0) do begin     // mientras haya < en Html
    TFin := Pos('>', Html);     // encuentro el >
    TLong := TFin - TIni + 1;
    Delete(Html, TIni, TLong);  // borro el tag
    TIni:= Pos( '<', Html);     // busco el sigiente <
    Application.ProcessMessages;
  end;

  Result := Html;                
end;

// [E]squerra [C]entrat [D]reta
function HtmlJust(Html:string;Modus:char='E'):string;
var
 Metode:string;
begin
 case Modus of
   'E','e': Metode:= 'left';
   'C','c': Metode:= 'center';
   'D','d': Metode:= 'right';
   else
     Metode:= 'left';
 end;
 result:=Format('<P align="%s">%s</P>',[Metode,Html]);
end;

function TECL_CtrlDown(): Boolean;
var
   State : TKeyboardState;
begin
   GetKeyboardState(State) ;
   Result := ((State[vk_Control] And 128) <> 0) ;
end;

function TECL_ShiftDown(): Boolean;
var
   State : TKeyboardState;
begin
   GetKeyboardState(State) ;
   Result := ((State[vk_Shift] and 128) <> 0) ;
end;

function TECL_AltDown():Boolean;
var
   State : TKeyboardState;
begin
   GetKeyboardState(State) ;
   Result := ((State[vk_Menu] and 128) <> 0) ;
end;

function emailValido(CONST Value: String): boolean;
  function CheckAllowed(CONST s: String): boolean;
  var i: Integer;
  begin
  Result:= False; 
  FOR i:= 1 TO Length(s) DO // illegal char in s -> no valid address
  IF NOT (s[i] IN ['a'..'z','A'..'Z','0'..'9','_','-','.']) THEN Exit; 
  Result:= true; 
  end;
var
  i,len: Integer; 
  namePart, serverPart: String; 
begin // of IsValidEmail
  Result:= False;
  if trim(Value) <> '' then
    begin
       i:= Pos('@', Value);
       IF (i=0) OR (Pos('..',Value) > 0) THEN Exit;
       namePart:= Copy(Value, 1, i - 1);
       serverPart:= Copy(Value,i+1,Length(Value));
       len:=Length(serverPart);
       // must have dot and at least 3 places from end, 2 places from begin
       IF (len<4) OR
          (Pos('.',serverPart)=0) OR
          (serverPart[1]='.') OR
          (serverPart[len]='.') OR
          (serverPart[len-1]='.') THEN Exit;
       Result:= CheckAllowed(namePart) AND CheckAllowed(serverPart);
   end;
end;

Function ObtDirTemporalWindows():string;
var
   lng: DWORD;
   thePath: string;
begin
  SetLength(thePath, MAX_PATH) ;
  lng := GetTempPath(MAX_PATH, PChar(thePath)) ;
  SetLength(thePath, lng) ;
  result:= thePath;
end;

Function  ObtPosUltimCar(Cadena:string):integer;
begin
  if trim(cadena) = '' then
    result:=0
  else
    result:= length(cadena);
end;

Function  TornarXmlAttr(attr:olevariant;Vlfdt:string=''):string;
begin
  if attr = Null then
     result:= Vlfdt
  else result:= attr;
end;

Function  TornarXmlAttrDta(attr:olevariant;Vlfdt:TDateTime=0):TdateTime;
begin
  if attr = Null then
     result:= Vlfdt
  else
    begin
      if trim(Attr)='' then
         result:= Vlfdt
      else
         result:= attr;
    end;
end;

Function obtStrColor(txtCol:string):Tcolor;
 Function CnvStrColor(clr:string):TColor;
 begin
 try
  result:=StringToColor(txtCol);
 except
  Result:=0;
 end;
 end;
begin
  if trim(txtCol) = '' then result:=0
  else
    result:=CnvStrColor(txtCol);
end;

procedure NetejarCuaTeclat();
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, WM_KEYFIRST, WM_KEYLAST,
    PM_REMOVE or PM_NOYIELD) do;
end;

procedure NetejarCuaRatoli();
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, WM_MOUSEFIRST, WM_MOUSELAST,
    PM_REMOVE or PM_NOYIELD) do;
end;

Function  RetornaMes(Fecha:TDateTime):integer;
var
 mes:string;
begin
 result:=0;
 mes:=formatdatetime('mm',Fecha);
 if EsNum(mes) then result:=StrToInt(mes);
end;

Function  RetornaDia(Fecha:TDateTime):integer;
var
 mes:string;
begin
 result:=0;
 mes:=formatdatetime('dd',Fecha);
 if EsNum(mes) then result:=StrToInt(mes);
end;

Function ValidarHora(H:string):boolean;
begin
   try
    StrToTime(H);
    Result := True;
  except
    Result := False;
  end;
end;

function HoraValida(hora:string):boolean;
Var
  Hor,Min,Sec:string;
begin
  if length(trim(hora))< 8 then result:=false
  else
  begin
     Hor:=copy(trim(hora),1,2);
     Min:=copy(trim(hora),4,2);
     Sec:=copy(trim(hora),7,2);
     if (strToInt(Hor) > 23 ) or
        (strToInt(Min) > 59 ) or
        (strToInt(Sec) > 59)  then
        result:=false
     else
        result:=true;
  end;
end;

Function ProgramaExternPresent(Nom:string):boolean;
var
 Handle:hWnd;
begin
  result:=False;
// {$IFDEF __XEIII}
    Handle := FindWindow(NIL,PWideChar(Nom));
// {$ELSE}
//    Handle := FindWindow(NIL,PAnsiChar(Nom));
// {$ENDIF}

  if Handle > 0 then
    result:=True;
end;

Function obtWebAColor(txtCol:string):Tcolor;
begin
  if trim(txtCol) = '' then result:=0
  else
    result:=WebColorStrToColor(txtCol);
end;

function ControlIBAN(const Cuenta, Pais: string): string;
var
  i, j: integer;
  m: int64;
  l: TInteger;
  t: string;
  s: string;

  function LetterToDigit(const C: Char): string;
  const
    a: char = 'A';
  var
    d: byte;
  begin
    result := C;
    if C in ['A'..'Z'] then
    begin
      d := (byte(C) - byte(a)) + 10;
      result := IntToStr(d);
    end;
  end;

begin
  l := TInteger.Create;
  try
    t := Cuenta + Pais + '00';
    s := '';
    j := Length(t);
    for i := 1 to j do
      s := s + LetterToDigit(t[i]);
    l.Assign(s);
    l.Modulo(97);
    l.ConvertToInt64(m);
    i := 98 - m;
    result := IntToStr(i);
    if i < 10 then result := '0' + result;
  finally
    l.Free;
  end;
end;

Function BrowseURL(const URL: string) : boolean;
var
   Browser: string;
begin
   Result := True;
   Browser := '';
   with TRegistry.Create do
   try
     RootKey := HKEY_CLASSES_ROOT;
     Access := KEY_QUERY_VALUE;
//     if OpenKey('\htmlfile\shell\open\command', False) then
     if OpenKey('\http\shell\open\command', False) then
       Browser := ReadString('') ;
     CloseKey;
   finally
     Free;
   end;
   if Browser = '' then
   begin
     Result := False;
     Exit;
   end;
   Browser := Copy(Browser, Pos('"', Browser) + 1, Length(Browser)) ;
   Browser := Copy(Browser, 1, Pos('"', Browser) - 1) ;
   ShellExecute(0, 'open', PChar(Browser), PChar(URL), nil, SW_SHOW) ;
end;

Function BrowseURLII(const URL: string) : boolean;
begin
   Result := True;
   ShellExecute(0, 'open', PChar(URL), nil,nil, SW_NORMAL) ;
end;

function IsDirectory(const DirName: string): Boolean;
  function IsFlagSet(const Flags, Mask: Integer): Boolean;
  begin
    Result := Mask = (Flags and Mask);
  end;
var
  Attr: Integer;  // directory's file attributes
begin
  Attr := SysUtils.FileGetAttr(DirName);
  Result := (Attr <> -1) and IsFlagSet(Attr, SysUtils.faDirectory);
end;

Function NomFitxerSenseExt(fitxer : string) : string;
var
  i : integer;
  nomFit : string;
begin
  nomFit := '';
  for i := 1 to Length (fitxer) - Length (ExtractFileExt (fitxer)) do
    nomFit := nomFit + fitxer[i];
  result := nomFit;
end;

function RevisaFormatHora(hora:string;SinSeg:boolean=FALSE):string;
var
 s,f:string;
 l,x:integer;
 begin
     // Elimina caracter sobrants
     s:='';
     f:=hora;
     l:=length(f);

     for x:=1 to l do
       begin
         if EsNumero(f[x]) then s:=s+f[x];
         application.ProcessMessages;
       end;
     if not SinSeg then
       begin  // con segundos
         // Crea cadena hora
         l:=length(s);
         if l > 6 then l:=6;
         case l of
          1,2: begin  // Nomes minus
                 if l > 1 then
                    hora:='00:'+s+':00'
                 else
                    hora:='00:0'+s+':00';
               end;
          3,4: begin  // Hores i minuts
                if l > 3 then
                    hora:=copy(s,1,2)+':'+copy(s,3,2)+':00'
                 else
                    hora:='0'+copy(s,1,1)+':'+copy(s,2,2)+':00';
               end;
          5,6: begin  // Hores minuts i segons
                if l > 5 then
                    hora:=copy(s,1,2)+':'+copy(s,3,2)+':'+
                    copy(s,5,2)
                 else
                    hora:=copy(s,1,2)+':'+copy(s,3,2)+':0'+
                    copy(s,5,1);
               end;
         end;
       end
     else
       begin
         l:=length(s);
         if l > 4 then l:=4;
         case l of
          1,2: begin  // Horas
                 if l > 1 then
                    begin
                      if cnvnum(s)<24 then
                         hora:=s+':00'
                      else
                         hora:='0'+copy(s,1,1)+':'+copy(s,2,1)+'0' ;
                    end
                 else
                   hora:='0'+s+':00';
               end;
          3,4: begin  // Hores i minuts
                if l > 3 then
                    hora:=copy(s,1,2)+':'+copy(s,3,2)
                 else
                   begin
                     if cnvnum(copy(s,1,2))<24 then
                       hora:=copy(s,1,2)+':'+copy(s,3,1)+'0'
                     else
                       hora:='0'+copy(s,1,1)+':'+copy(s,2,2);
                   end;
               end;
          end;
       end;
    result:=hora;
end;

function EsNumero(s:char):boolean;
var
  n:integer;
begin
    if s  in ['0','1','2','3','4','5','6','7','8','9'] then Result:=True
    else Result:=False;
end;

function  Ord_bdn(s:string;idx:integer):longint;
begin
 result:= ord(ansistring(s)[idx]);
end;

function  SiEsUltCarTreu(busquem:char;Cadena:string):string;
var
 s:string;
 P:integer;
begin
 result:= Cadena;
 s:= trim(cadena);
 p:= ObtPosUltimCar(s);
 if p > 0 then
  begin
     if s[p] = busquem then
      begin
       s[p]:= #32;
       result:= trim(s);
      end;
  end;
end;

function BinToInt(Value: string): Integer;
var
  i, iValueSize: Integer;
begin
  Result := 0;
  iValueSize := Length(Value);
  for i := iValueSize downto 1 do
   begin
    if Value[i] = '1' then
        Result := Result + (1 shl (iValueSize - i));
    Application.ProcessMessages;
   end;
end;

function  TxtAFloat(txt:string):Extended;
begin
 Result:=StrToFloat(DesformateaNum(Txt));
end;

function  NetajarItem(item:string):string;
var
 s:string;
 p:integer;
begin
  result:= item;
  s:= Trim(item);
  if s <> '' then
   begin
     p:= pos(#9,s);
     if p > 0 then
       result:= copy(s,1,p-1);
   end;
end;

Function  RevData(d:TDateTime):string;
var
 s:string;
begin
 if d = 0 then Result:='null'
 else
   begin
     s:=format(' ''%s'' ',[FormatDateTime('mm/dd/yyyy',d)]);
     result:=s;
   end;
end;

Function CopiarStrngLst(var Org,Dst:TStringList):boolean;
var
 i:integer;
begin
  result:=False;
  if (Org <> nil) and (Dst <> nil) then
   begin
     for i := 0 to Org.Count -1  do
      begin
        Dst.Add(Org[i]);
        Application.ProcessMessages;
      end;
     if Dst.Count = Org.Count then
       result:= True;
   end;

end;

function RoundUp(X: Extended): Int64;
const
  RoundUpCW: Word = $1B32; // same as Default8087CW, except round up
var
  OldCW: Word;
begin
  OldCW := Default8087CW;
  try
    Set8087CW(RoundUpCW);
    Result := Round(X);
  finally
    Set8087CW(OldCW);
  end;
end;

function Sgn(X: Extended): Integer;
{ Retorna -1, 0 or 1 de acordo com o sinal do argumento }
begin
  if X < 0 then
    Result := -1
  else
    if X = 0 then
      Result := 0
    else
      Result := 1;
end;

//function RoundUp(X: Extended): Extended;
//
//{ Retorna o primeiro inteiro maior que ou igual a um
//
//  dado número em valor absoluto (o sinal e preservado).
//
//  RoundUp(3,3) = 4    RoundUp(-3,3) = -4 }
//
//begin
//  Result := Int(X) + Sgn(Frac(X));
//
//end;

function RoundDn(X: Extended): Extended;

{ Retorna o primeiro inteiro menor que ou

  igual a um dado número em  valor absoluto (o sinal é preservado).

  RoundDn(3,7) = 3    RoundDn(-3,7) = -3

begin
  Result := Int(X);

end;

function RoundN(X: Extended): Extended;

{ Arredonda um número "normalmente": caso a parte de fração
  seja >= 0,5 o número será arredondado “para cima” (ver RoundUp)
  caso contrário, se a parte de fração for < 0,5, o
  número será arredondado “para baixo” (ver RoundDn).
  RoundN(3,5) = 4     RoundN(-3,5) = -4

  RoundN(3,1) = 3     RoundN(-3,1) = -3 }

begin
  (*
  if Abs(Frac(X)) >= 0.5 then

    Result := RoundUp(X)

  else
    Result := RoundDn(X);

  *)
    Result := Int(X) + Int(Frac(X) * 2);

end;

function Fix(X: Extended): Extended;

{ Retorna o primeiro inteiro menor que ou

  igual a um dado número.

  Int(3,7) = 3          Int(-3,7) = -3

  Fix(3,7) = 3          Fix(-3,1) = -4 }

begin
  if (X >= 0) or (Frac(X) = 0) then

    Result := Int(X)

  else
    Result := Int(X) - 1;

end;

function RoundDnX(X: Extended): Extended;

{ Retorna o primeiro inteiro menor que ou

  igual a um dado número.

  RoundDnX(3,7) = 3     RoundDnX(-3,7) = -3

  RoundDnX(3,7) = 3     RoundDnX(-3,1) = -4 }

begin
  Result := Fix(X);

end;


function RoundUpX(X: Extended): Extended;

{ Retorna o primeiro inteiro maior que ou

  igual a um dado número.

  RoundUpX(3,1) = 4     RoundUpX(-3,7) = -3 }

begin
  Result := Fix(X) + Abs(Sgn(Frac(X)))

end;

function RoundX(X: Extended): Extended;

{ Arredonda o número "normalmente", porém levando em conta o sinal:
  se a parte de fração for >= 0,5, o número

  será arredondado “para cima” (ver RoundUpX)

  caso contrario, se a parte de fração for < 0,5,

  o número será arredondado “para baixo” (ver RoundDnX).

  RoundX(3,5) = 4     RoundX(-3,5) = -3 }

begin
  (*
  if Abs(Frac(X)) >= 0,5 then

    Result := RoundUpX(X)

  else
    Result := RoundDnX(X);

  *)
    Result := Fix(X + 0.5);

end;

function RoundNExtend(x: Extended; d: Integer): Extended;

{ RoundN(123,456, 0) = 123,00

  RoundN(123,456, 2) = 123,46

  RoundN(123456, -3) = 123000 }

const
  t: array [0..12] of int64 = (1, 10, 100, 1000, 10000, 100000,
    1000000, 10000000, 100000000, 1000000000, 10000000000,
    100000000000, 1000000000000);

begin
  if Abs(d) > 12 then

    raise ERangeError.Create('RoundN: Value must be in -12..12');

  if d = 0 then

    Result := Int(x) + Int(Frac(x) * 2)

  else

    if d > 0 then

    begin

      x := x * t[d];

      Result := (Int(x) + Int(Frac(x) * 2)) / t[d];

    end

    else

    begin  // d < 0

      x := x / t[-d];

      Result := (Int(x) + Int(Frac(x) * 2)) * t[-d];

    end;
end;


Function  IncrementarMes(Mes:integer):integer;
begin
  result:= Mes;
  Mes:=Mes+1;
  if Mes > 12 then
    result:= 1
  else
    result:=Mes;
end;

Function  DecrementarMes(Mes:integer):integer;
begin
  result:= Mes;
  Mes:=Mes-1;
  if Mes <= 0 then
    result:= 12
  else
    result:=Mes;
end;

Function CopiarReg(Org, Dst: TDataSet):boolean;
var Ind:longint;
    SField, DField: TField;
begin
  result:=True;
  for Ind:=0 to Org.FieldCount - 1 do
   begin
     SField := Org.Fields[ Ind ];
     DField := Dst.FindField( SField.FieldName );
     if (DField <> nil) and (DField.FieldKind = fkData) and
        not DField.ReadOnly then
        if (SField.DataType = ftString) or
           (SField.DataType = DField.DataType) then
           DField.AsString := SField.AsString
        else
           DField.Assign( SField )
   end;
end;

 Function ObtNomCognoms(var Nom,Cognoms:string;Filiacio:string;Separador:string=','):boolean;
 var
  p,i:integer;
  s:string;
 begin
  result:=False;
  s:=UpperCase(Trim(Filiacio));
  Nom:='';Cognoms:='';
  if s <> '' then
    begin
     if s='CONTADO' then
       begin
         Cognoms:= s;
         result:=True;
       end
     else
       begin
        p:=AnsiPos(Separador,s);
        if p > 0 then
         begin
           Cognoms:= trim(copy(s,1,p-1));
           Nom    := trim(copy(s,p+1,length(s)-p));
           result:=True;
         end
        else
         begin
           if not ((AnsiPos(' SL',s) > 0) or
//              (AnsiPos(' SA.',s) > 0) or
              (AnsiPos(' SA ',s) > 0) or
              (AnsiPos(' SAL ',s) > 0) or
              (AnsiPos(' SLL ',s) > 0) or
              (AnsiPos(' SCP',s) > 0) or
//              (AnsiPos(' S.A',s) > 0) or
//              (AnsiPos(' S.L',s) > 0) or
//              (AnsiPos('S.C.P',s) > 0) or
              (AnsiPos('.',s) > 0) )  then
             begin
               p:=0;
               for i := length(s) Downto 1 do
               begin
                 if s[i]= #32 then
                   begin
                     p:=i;
                     Break;
                   end;
               end;
               if p > 0 then
                 begin
                    Cognoms:= trim(copy(s,1,p-1));
                    Nom    := trim(copy(s,p+1,length(s)-p));
                    result:=True;
                 end;

             end;
         end;
       end;
    end;
 end;

 function EsFormModal(frm: TCustomForm) : boolean;
 begin
   Result := false;
   if Assigned(frm) then
     Result := (fsModal in frm.FormState);
 end;

Function  InvertirSigne(valor:double):double;
begin
 result:= valor;
 if valor <> 0 then
  begin
    if valor > 0 then
      result:= - Abs(valor)
    else
      result:= Abs(valor);
  end;
end;

Function IncreMinutos(Hora:string;Minuts:integer):string;
var
  D : TDateTime;
begin
  result:=Hora;
  if (trim(hora) <> '') and (length(Hora)=5) then
    begin
       D:= StrToDateTime(format('%s %s',[formatDatetime('dd/mm/yyyy',Date()),Hora]));
       D:=IncMinute(D, Minuts);
       result:=formatdatetime('hh:nn',d);
    end;
end;

/// Pensat per solventar problema de parametres firebid
Function EvaluarMides(Resultat,Inicial:string;Mida:integer):string;
begin
 result:= Resultat;
 if length(Resultat) > Mida  then
   begin
     if length(Inicial) = Mida then
         result:= Inicial
     else
       begin
         if length(Inicial) > Mida then
            result:= copy(Inicial,1,Mida)
         else
           begin
             result:=  Inicial+'%';
           end;
       end;
   end;
end;

Function ForzarZero(const valor:string):string;
begin
  result:=valor;
  if Trim(valor) = '' then
    result:='0';
  if result <> '0' then
    begin
      if not EsNumF(valor) then
         result:='0';
    end;
end;

Function  MinutsaMiliseg(Min:integer):cardinal;
begin
  result:= Min*60*1000;
end;

Procedure DeleteFiles(APath, AFileSpec: string);
var
  lSearchRec:TSearchRec;
  lPath:string;
begin
  lPath := IncludeTrailingPathDelimiter(APath);

  if FindFirst(lPath+AFileSpec,faAnyFile,lSearchRec) = 0 then
  begin
    try
      repeat
        SysUtils.DeleteFile(lPath+lSearchRec.Name);
      until SysUtils.FindNext(lSearchRec) <> 0;
    finally
      SysUtils.FindClose(lSearchRec);  // Free resources on successful find
    end;
  end;
end;

//Procedure DelFilesMatchPattern(const Directory, Pattern: string);
//  var FileName: string;
//begin
//  for FileName in TDirectory.GetFiles(Directory, Pattern) do TFile.Delete(FileName);
//end;

function HtmlToStr(strHTML: string): string;
var
  P: INTEGER;
  InTag: Boolean;
  s : STRING[4];
begin
     P := 1;
     Result := '';
     InTag := False;
     repeat
           // get the next four chars
           s := COPY(strHTML, P, 4);
          // Do carriage returns
          if (CompareText('<br>', s) = 0) or (CompareText('</p>', s) = 0) then
          begin
               Result := Result + #13#10;
               INC(P, 4)
          end
          else
          begin
               // Just add text to the result
               case strHTML[P] of
                 '<': InTag := True;
                 '>': InTag := False;
                 #13, #10: Result := Result + #32;  // Add a space
               else
                 if not InTag then
                 begin
                      if NOT((strHTML[P] in [#9, #32]) and (strHTML[P+1] in [#10, #13, #32, #9, '<'])) then
                           Result := Result + strHTML[P]; // Add character to result
                 end;
               end;
          end;
          Inc(P);
     until (P > LENGTH(strHTML));
     {convert system characters}
     Result := StringReplace(Result, '&quot;', '"',  [rfReplaceAll]);
     Result := StringReplace(Result, '&nbsp;', ' ',  [rfReplaceAll]);
     Result := StringReplace(Result, '&pound;', '£',  [rfReplaceAll]);
     Result := StringReplace(Result, '&euro;', '€',  [rfReplaceAll]);
     Result := StringReplace(Result, '&#8212;', '—',  [rfReplaceAll]);
     Result := StringReplace(Result, '&apos;', '''', [rfReplaceAll]);
     Result := StringReplace(Result, '&gt;',   '>',  [rfReplaceAll]);
     Result := StringReplace(Result, '&lt;',   '<',  [rfReplaceAll]);
     Result := StringReplace(Result, '&amp;',  '&',  [rfReplaceAll]);
     {here you may add another symbols from RFC if you need}
end;

function GetVersionInfo(AIdent: String): String;

type
  TLang = packed record
    Lng, Page: WORD;
  end;

  TLangs = array [0 .. 10000] of TLang;

  PLangs = ^TLangs;

var
  BLngs: PLangs;
  BLngsCnt: Cardinal;
  BLangId: String;
  RM: TMemoryStream;
  RS: TResourceStream;
  BP: PChar;
  BL: Cardinal;
  BId: String;

begin
  // Assume error
  Result := '';

  RM := TMemoryStream.Create;
  try
    // Load the version resource into memory
    RS := TResourceStream.CreateFromID(HInstance, 1, RT_VERSION);
    try
      RM.CopyFrom(RS, RS.Size);
    finally
      FreeAndNil(RS);
    end;

    // Extract the translations list
    if not VerQueryValue(RM.Memory, '\\VarFileInfo\\Translation', Pointer(BLngs), BL) then
      Exit; // Failed to parse the translations table
    BLngsCnt := BL div sizeof(TLang);
    if BLngsCnt <= 0 then
      Exit; // No translations available

    // Use the first translation from the table (in most cases will be OK)
    with BLngs[0] do
      BLangId := IntToHex(Lng, 4) + IntToHex(Page, 4);

    // Extract field by parameter
    BId := '\\StringFileInfo\\' + BLangId + '\\' + AIdent;
    if not VerQueryValue(RM.Memory, PChar(BId), Pointer(BP), BL) then
      Exit; // No such field

    // Prepare result
    Result := BP;
  finally
    FreeAndNil(RM);
  end;
end;

function EXE_FileDescription: String;
begin
  Result := GetVersionInfo('FileDescription');
end;

function EXE_LegalCopyright: String;
begin
  Result := GetVersionInfo('LegalCopyright');
end;

function EXE_DateOfRelease: String;
begin
  Result := GetVersionInfo('DateOfRelease');
end;

function EXE_ProductVersion: String;
begin
  Result := GetVersionInfo('ProductVersion');
end;

function EXE_FileVersion: String;
begin
  Result := GetVersionInfo('FileVersion');
end;

function GetFileModDate(filename : string) : TDateTime;
var
   F : TSearchRec;
begin
   FindFirst(filename,faAnyFile,F);
   Result := F.TimeStamp;
   //if you really wanted an Int, change the return type and use this line:
   //Result := F.Time;
   // FindClose(F);
end;

Function DateTimeDiff(Start, Stop : TDateTime) : int64;
var TimeStamp : TTimeStamp;
begin
  TimeStamp := DateTimeToTimeStamp(Stop - Start);
  Dec(TimeStamp.Date, TTimeStamp(DateTimeToTimeStamp(0)).Date);
  Result := (TimeStamp.Date*24*60*60)+(TimeStamp.Time div 1000);
  Result := Result div 60;
end;

end.


