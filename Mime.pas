//*****************************************************************//
//                                                                 //
//  MIME Base64 Encode/Decode Routines                             //
//  Copyright© BrandsPatch LLC                                     //
//  http://www.explainth.at                                        //
//                                                                 //
//  All Rights Reserved                                            //
//                                                                 //
//  Permission is granted to use, modify and redistribute          //
//  the code in this Delphi unit on the condition that this        //
//  notice is retained unchanged.                                  //
//                                                                 //
//                                                                 //
//  BrandsPatch declines all responsibility for any losses,        //
//  direct or indirect, that may arise  as a result of using       //
//  this code.                                                     //
//                                                                 //
//*****************************************************************//
unit Mime;

interface

uses SysUtils,Classes; //Windows

type EMimeError = class(Exception);
     TMimeBytes = array[1..MAXINT] of Byte;
     PMimeBytes = ^TMimeBytes;

function MIMEEncode(P:PMimeBytes;ASize:Integer):String;
function MIMEDeCode(ACode:String;var ADiscard:Integer):TMemoryStream;

implementation

type TMimeChars = array[0..63] of Char;
     TMimeMasks = array[1..3] of Byte;

const MimeChars:TMimeChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
      //array best for encoding purposes
      MimeCodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
      //constant string best for decoding purposes
      BankMasks:TMimeMasks = ($03,$0F,$3F);
      //mask to isolate unused bits to bank for later use
      N1:TMimeMasks = ($FC,$F0,$C0);
      //mask to isolate bits to use immediately
      N2:TMimeMasks = ($02,$04,$06);
      {how much right shift to apply to bits for immediate use?
       Given we use the most siginficant bits a shift is ALWAYS
       required - with the first byte because we pick 6 such bits
       and with the subsequent bytes because the bank occupies
       the most significant position}
      N3:TMimeMasks = ($04,$02,0);
      {the banked bits must be shifted left so they are in the
       right position to be combined with bits picked up from the
       next data byte}
      Pads:TMimeMasks = (0,2,1);
      _BMC = 'Invalid Mime Code';

function MIMEEncode(P:PMimeBytes;ASize:Integer):String;
var i,k,ndx,Bank,AOffset:Integer;
    APad:String;

  procedure BuildCode;
  var j:Integer;
  begin
    for j:=1 to 3 do
    begin
      k:=AOffset + j;
      ndx:=(Bank or (P^[k] and N1[j]) shr N2[j]);
      {normally Delphi optimization will get rid of this
       intermediate variable}
      Result:=Format('%s%s',[Result,MimeChars[ndx]]);
      Bank:=(P^[k] and BankMasks[j]) shl N3[j];
      {This is how codes are generated from data bytes

      a. We take the 6 most significant bits from the
         first data byte
      b. We bank the remaining 2 bits for later use.
      c. We take 4 bits from the second byte and combine
         with the 2 banked bits. Note that the banked bits
         become the most significant bits. We bank the remaing
         4 bits from the second bit
      d. We take 2 bits from the third byte and combine
         with the 4 banked bits. Once again, the banked bits
         become the most significant bits

         ANDing with BankMasks helps us locate the bits to bank
         We shift them immediately so they are the most sigificant
         when they are ORd later.

         ANDing with N1 helps us identify the bits to use from the
         current data byte. However, these bits may need to be shifted
         down since it is the bits from the bank that are most significant
         SHRing with N2 helps do this
      }
    end;
    if (k <= ASize) then Result:=Format('%s%s',[Result,MimeChars[Bank]]);
  end;

begin
  SetLength(Result,0);
  i:=Pads[1 + ASize mod 3];
  APad:=StringOfChar('=',i);
  //null string if ASize is a multiple of 3
  //= if ASize is 1 short of a multiple of 3
  //== if ASize is 2 short of a multiple of 3

  try
    for k:=1 to i do P^[ASize + k]:=0;
    {/pad the data.
    ***NOTE***

    You must ensure that P is large enough to allow
    upto two additional bytes to be written.
    }
    inc(ASize,i);

    i:=ASize;AOffset:=0;//we start encoding P^ from offset zero
    while (i > 0) do
    begin
      Bank:=0;
      BuildCode;
      dec(i,3);
      inc(AOffset,3);
    end;
  except on E:Exception do raise EMimeError.Create(E.Message) end;

  i:=Length(APad);
  if (i > 0) then Delete(Result,Length(Result) - i + 1,i);
  {The result at this point may contain terminating A characters
   coming from the padding bytes. We must discard these since there
   is no way to distinguish between real As - those arising from
   true 0 bytes in the original data - and padding As

   1 orphaned byte - data length of 4,7 etc - results in two
   bytes of padding. The resulting three bytes will generate
   two true code characters and two padding As.

   2 orphaned bytes - data length 5, 8 etc - result in one
   byte of padding. The resulting three bytes will generate
   three true code characters and one padding A.

   Can't make sense of the number of true code bytes?
   Think about this

   Writing one true data character requires 6 + 2 bits, i.e. 2 bytes
   }
  Result:=Result + APad;
  {having discarded padding As we repace them with an equivalent
   number of = signs}
end;

function MIMEDeCode(ACode:String;var ADiscard:Integer):TMemoryStream;
var i,ALen,AData:Integer;
    ABytes:array[0..2] of Byte absolute AData;
begin
  Result:=TMemoryStream.Create;

  ALen:=Length(ACode);
  case ALen of
    0:ADiscard:=0;
    1:ADiscard:=ord(ACode[1] = '=');
    //these two cases should not normally occur
    else case ACode[ALen - 1] of
           '=':if (ACode[ALen] = '=') then ADiscard:=2 else raise EMimeError.Create(_BMC);
           //ACode[ALen - 1] is = and ACode[ALen] is not is not leagal
           else ADiscard:=ord(ACode[ALen] = '=');
         end;
  end;

  if (ADiscard > 0) then
  begin
    Delete(ACode,ALen - ADiscard + 1,ADiscard);
    //remove the padding indicators
    ACode:=ACode + StringOfChar('A',ADiscard);
    //replace them with the 0 byte MIME code - always A
  end;

  inc(ALen,ADiscard);
  for i:=ALen downto 1 do if (Pos(ACode[i],MimeCodes) = 0) then Delete(ACode,i,1);
  //strip out anything that is not a legal MIME code

  i:=1;
  while (i <= ALen) do
  begin
    AData:=Pos(ACode[i + 3],MimeCodes) - 1 + 
           (Pos(ACode[i + 2],MimeCodes) - 1) shl 6 +
           (Pos(ACode[i + 1],MimeCodes) - 1) shl 12 +
           (Pos(ACode[i],MimeCodes) - 1) shl 18;
    {Each code character represents 6 bits in the original data.
     We pick sets of four such characters and rebuild 3 bytes,
     24 bits of those original data.}
    Result.WriteBuffer(ABytes[2],1);
    Result.WriteBuffer(ABytes[1],1);
    Result.WriteBuffer(ABytes[0],1);
    {Having done so, we write the data back. A complication -
     the order in which we have rebuilt the data is back to
     front. Here we are fixing this by simply writing the
     three individual bytes separately in correct order. Other
     solutions do exist - in our view, not worth implementing}
    inc(i,4);
  end;
  Result.Position:=0;
end;

end.
