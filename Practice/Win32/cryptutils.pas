Unit Cryptutils;
//------------------------------------------------------------------------------
{
   Title:       Password Encryption and Description Utilities

   Description:

   Remarks:     MAX STRING SIZE = 16 chars

                Accepts a hex string for decrypting, returns plain text
                Accepts a plain text string for encrypting, returns a hex string

   Author:      Matthew Hopkins  Nov 2001

}
//------------------------------------------------------------------------------

interface

type
   Str16        = string[16];

  function EncryptPass16(BFKey: string; PlainText: Str16) : string;
  function DecryptPass16(BFKey: string; Encrypted: string) : Str16;

//******************************************************************************
implementation
uses
   Blowunit,
   Cryptcon;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
type
   TCryptoArray = array [0..127] Of Char;
   Str2         = string[2];

const
   PadChar      = #170;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function B2H( B : Byte ): Str2;
Const
   H : Array[ 0..$F ] of Char = '0123456789ABCDEF';
Begin
   B2H := H[ B shr 4 ] + H[ B and $0F ];
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function H2B( HexPair : Str2) : Byte;
const
   HexChars = '0123456789ABCDEF';
var
   H, L : SmallInt;
begin
   result := 0;
   if length( HexPair) <> 2 then
      Exit;

   L := Pos( HexPair[2], HexChars) -1;
   H := Pos( HexPair[1], HexChars) -1;

   if ( L = -1) or ( H = -1) then
      result := 0
   else
      result := L + H * 16;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DecryptPass16(BFKey: string; Encrypted: string) : Str16;
//copy string to buffer, only seems to handle up to 16 char string
var
   InArray   : TCryptoArray;
   OutArray  : TCryptoArray;
   BlowFish2 : TBlowFish;
   Len,i     : integer;
   S         : string;
begin
   Result := '';
   if Encrypted = '' then exit;
   //determine length of hex string, must be even number of bytes
   Len := Length( Encrypted);
   if Len mod 2 <> 0 then
      Exit;
   Len := Len div 2;
   //convert hex string to byte array
   FillChar(InArray, Sizeof(InArray), #0);
   FillChar(OutArray, Sizeof(OutArray), #0);
   for i := 0 to Pred( Len) do
      InArray[ i] := Chr( H2B( Copy( Encrypted, (i * 2) +1 , 2)));
   //decrypt
   BlowFish2 := TBlowFish.Create(Nil);
   try
      with BlowFish2 do begin
         CipherMode    := ECBMode;
         Key           := BFKey;
         InputType     := SourceByteArray;
         InputLength   := Len;
         pInputArray   := @InArray;
         pOutputArray  := @OutArray;
         DecipherData(false);
      end;
      S := OutArray;
   finally
      BlowFish2.Free;
   end;
   //extract password from string
   i := Pos( PadChar, S);
   if i > 0 then
      S := Copy( S, 0, i - 1);
   result := S;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EncryptPass16(BFKey: string; PlainText: Str16) : string;
//encrypt the plain text password using blowfish.
//pad password out to 16 characters if shorter by adding #170 '¬'
//return a plain text string which represents hex values
var
   InArray   : TCryptoArray;
   OutArray  : TCryptoArray;
   BlowFish2 : TBlowFish;

   PaddedPassword : string;
   i         : integer;
   len       : integer;
begin
   Result := '';
   if PlainText = '' then exit;
   //pad password
   PaddedPassword := PlainText;
   While Length( PaddedPassword) < 16 do
      PaddedPassword := PaddedPassword + #170;
   //encrypt
   FillChar(InArray, Sizeof(InArray), #0);
   FillChar(OutArray, Sizeof(OutArray), #0);
   for i := 1 to Length( PaddedPassword) do
      InArray[ i - 1] := PaddedPassword[ i];
   BlowFish2 := TBlowFish.Create(Nil);
   try
      with BlowFish2 do begin
         CipherMode    := ECBMode;
         Key           := BFKey;
         InputType     := SourceByteArray;
         InputLength   := Length(PaddedPassword);
         pInputArray   := @InArray;
         pOutputArray  := @OutArray;
         EncipherData(false);
         //encrypted data will now be in OutArray
         //convert to hex string
         result := '';
         Len := length( PaddedPassword);
         for i := 0 to Pred( Len) do begin
            result := result + B2H( Byte( OutArray[ i]));
         end;
      end;
   finally
      BlowFish2.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
End.
