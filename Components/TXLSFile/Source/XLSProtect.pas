unit XLSProtect;

{-----------------------------------------------------------------
    SM Software, 2000-2009

    TXLSFile v.4.0

    Data protection
-----------------------------------------------------------------}

interface

{$I XLSFile.inc}

uses Classes, XLSBase;

{$IFDEF XLF_D3}
type
  Longword = Cardinal;
{$ENDIF}

type
  UINT4 = LongWord;

  PArray4UINT4 = ^TArray4UINT4;
  TArray4UINT4 = array[0..3] of UINT4;
  PArray2UINT4 = ^TArray2UINT4;
  TArray2UINT4 = array[0..1] of UINT4;
  PArray16Byte = ^TArray16Byte;
  TArray16Byte = array[0..15] of Byte;
  PArray64Byte = ^TArray64Byte;
  TArray64Byte = array[0..63] of Byte;

  PByteArray = ^TByteArray;
  TByteArray = array[0..0] of Byte;

  PUINT4Array = ^TUINT4Array;
  TUINT4Array = array[0..0] of UINT4;

  PMD5Digest = ^TMD5Digest;
  TMD5Digest = record
    case Integer of
      0: (A, B, C, D: UINT4);
      1: (v: array[0..15] of Byte);
  end;

  PMD5Context = ^TMD5Context;
  TMD5Context = record
    state: TArray4UINT4;
    count: TArray2UINT4;
    buffer: TArray64Byte;
  end;

  TRC4Key = packed record
    State: array[0..255] of Byte;
    x: Byte;
    y: Byte;
  end;

const
  BIFF8_REKEY_BLOCK = $400;
  BIFF8_BOOKPROTECT_CRYPTPASSWORD = 'VelvetSweatshop';

  { Sheet protection flags (a set bit specifies that the action is allowed)}
  BIFF8_SHEETPROTECT_ALLOW_EDITOBJECTS    = Word($0001); // Edit objects
  BIFF8_SHEETPROTECT_ALLOW_EDITSCEN       = Word($0002); // Edit scenarios
  BIFF8_SHEETPROTECT_ALLOW_FORMATCELL     = Word($0004); // Change cell formatting
  BIFF8_SHEETPROTECT_ALLOW_FORMATCOLUMNS  = Word($0008); // Change column formatting
  BIFF8_SHEETPROTECT_ALLOW_FORMATROWS     = Word($0010); // Change row formatting
  BIFF8_SHEETPROTECT_ALLOW_INSCOLUMNS     = Word($0020); // Insert columns
  BIFF8_SHEETPROTECT_ALLOW_INSROWS        = Word($0040); // Insert rows
  BIFF8_SHEETPROTECT_ALLOW_INSHLINKS      = Word($0080); // Insert hyperlinks
  BIFF8_SHEETPROTECT_ALLOW_DELCOLUMNS     = Word($0100); // Delete columns
  BIFF8_SHEETPROTECT_ALLOW_DELROWS        = Word($0200); // Delete rows
  BIFF8_SHEETPROTECT_ALLOW_SELECTLOCKED   = Word($0400); // Select locked cells
  BIFF8_SHEETPROTECT_ALLOW_SORT           = Word($0800); // Sort a cell range
  BIFF8_SHEETPROTECT_ALLOW_EDITFILTERS    = Word($1000); // Edit auto filters
  BIFF8_SHEETPROTECT_ALLOW_EDITPIVOTS     = Word($2000); //  Edit PivotTables
  BIFF8_SHEETPROTECT_ALLOW_SELECTUNLOCKED = Word($4000); // Select unlocked cells
  BIFF8_SHEETPROTECT_DEFAULT              = Word($4400);
  
{ Sheet protection }
function XLSProtectGetPasswordHash(const Password: AnsiString): Word;

{ BIFF8 file protection }
function BIFF8ProtectVerifyPassword(Password: WideString;
  DocID: TArray16Byte; Salt: TArray64Byte; HashedSalt: TArray16Byte;
  var valDigest: TMD5Digest): Boolean;
procedure BIFF8ProtectMakeKey(Block: UINT4; var Key: TRC4Key; var valDigest: TMD5Digest);
procedure BIFF8ProtectRC4Transform(Buffer: PAnsiChar; BufferLen: Integer; var Key: TRC4Key);
procedure BIFF8ProtectPrepareCrypt(const Password: WideString;
  var DocID: TArray16Byte; var Salt: TArray64Byte; var HashedSalt: TArray16Byte;
  var valDigest: TMD5Digest);
procedure BIFF8ProtectCryptBlock(InData: Pointer; OutData: Pointer;
  BlockNum: Integer; var Key: TRC4Key; var Digest: TMD5Digest);


implementation
uses SysUtils, ActiveX;

{ MD5 }
const
  S11 = 7;
  S12 = 12;
  S13 = 17;
  S14 = 22;
  S21 = 5;
  S22 = 9;
  S23 = 14;
  S24 = 20;
  S31 = 4;
  S32 = 11;
  S33 = 16;
  S34 = 23;
  S41 = 6;
  S42 = 10;
  S43 = 15;
  S44 = 21;

{ Helper functions }
function _F(x, y, z: UINT4): UINT4;
begin
  Result := (((x) and (y)) or ((not x) and (z)));
end;

function _G(x, y, z: UINT4): UINT4;
begin
  Result := (((x) and (z)) or ((y) and (not z)));
end;

function _H(x, y, z: UINT4): UINT4;
begin
  Result := ((x) xor (y) xor (z));
end;

function _I(x, y, z: UINT4): UINT4;
begin
  Result := ((y) xor ((x) or (not z)));
end;

function ROTATE_LEFT(x, n: UINT4): UINT4;
begin
  Result := (((x) shl (n)) or ((x) shr (32 - (n))));
end;

procedure FF(var a: UINT4; b, c, d, x, s, ac: UINT4);
begin
  a := a + _F(b, c, d) + x + ac;
  a := ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure GG(var a: UINT4; b, c, d, x, s, ac: UINT4);
begin
  a := a + _G(b, c, d) + x + ac;
  a := ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure HH(var a: UINT4; b, c, d, x, s, ac: UINT4);
begin
  a := a + _H(b, c, d) + x + ac;
  a := ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure II(var a: UINT4; b, c, d, x, s, ac: UINT4);
begin
  a := a + _I(b, c, d) + x + ac;
  a := ROTATE_LEFT(a, s);
  a := a + b;
end;

procedure MD5Decode(Output: PUINT4Array; Input: PByteArray; Len: LongWord);
var
  i, j: LongWord;
begin
  j := 0;
  i := 0;
  while j < Len do
  begin
    Output[i] := UINT4(input[j]) or (UINT4(input[j + 1]) shl 8) or
      (UINT4(input[j + 2]) shl 16) or (UINT4(input[j + 3]) shl 24);
    Inc(j, 4);
    Inc(i);
  end;
end;

procedure MD5_memcpy(Output: PByteArray; Input: PByteArray; Len: LongWord);
begin
  Move(Input^, Output^, Len);
end;

procedure MD5_memset(Output: PByteArray; Value: Integer; Len: LongWord);
begin
  FillChar(Output^, Len, Byte(Value));
end;

procedure MD5Transform(State: PArray4UINT4; Buffer: PArray64Byte);
var
  a, b, c, d: UINT4;
  x: array[0..15] of UINT4;
begin
  a := State[0];
  b := State[1];
  c := State[2];
  d := State[3];
  MD5Decode(PUINT4Array(@x), PByteArray(Buffer), 64);

  FF(a, b, c, d, x[0], S11, Longword($D76AA478));
  FF(d, a, b, c, x[1], S12, Longword($E8C7B756));
  FF(c, d, a, b, x[2], S13, Longword($242070DB));
  FF(b, c, d, a, x[3], S14, Longword($C1BDCEEE));
  FF(a, b, c, d, x[4], S11, Longword($F57C0FAF));
  FF(d, a, b, c, x[5], S12, Longword($4787C62A));
  FF(c, d, a, b, x[6], S13, Longword($A8304613));
  FF(b, c, d, a, x[7], S14, Longword($FD469501));
  FF(a, b, c, d, x[8], S11, Longword($698098D8));
  FF(d, a, b, c, x[9], S12, Longword($8B44F7AF));
  FF(c, d, a, b, x[10], S13, Longword($FFFF5BB1));
  FF(b, c, d, a, x[11], S14, Longword($895CD7BE));
  FF(a, b, c, d, x[12], S11, Longword($6B901122));
  FF(d, a, b, c, x[13], S12, Longword($FD987193));
  FF(c, d, a, b, x[14], S13, Longword($A679438E));
  FF(b, c, d, a, x[15], S14, Longword($49B40821));

  GG(a, b, c, d, x[1], S21, Longword($F61E2562));
  GG(d, a, b, c, x[6], S22, Longword($C040B340));
  GG(c, d, a, b, x[11], S23, Longword($265E5A51));
  GG(b, c, d, a, x[0], S24, Longword($E9B6C7AA));
  GG(a, b, c, d, x[5], S21, Longword($D62F105D));
  GG(d, a, b, c, x[10], S22, Longword($2441453));
  GG(c, d, a, b, x[15], S23, Longword($D8A1E681));
  GG(b, c, d, a, x[4], S24, Longword($E7D3FBC8));
  GG(a, b, c, d, x[9], S21, Longword($21E1CDE6));
  GG(d, a, b, c, x[14], S22, Longword($C33707D6));
  GG(c, d, a, b, x[3], S23, Longword($F4D50D87));

  GG(b, c, d, a, x[8], S24, Longword($455A14ED));
  GG(a, b, c, d, x[13], S21, Longword($A9E3E905));
  GG(d, a, b, c, x[2], S22, Longword($FCEFA3F8));
  GG(c, d, a, b, x[7], S23, Longword($676F02D9));
  GG(b, c, d, a, x[12], S24, Longword($8D2A4C8A));

  HH(a, b, c, d, x[5], S31, Longword($FFFA3942));
  HH(d, a, b, c, x[8], S32, Longword($8771F681));
  HH(c, d, a, b, x[11], S33, Longword($6D9D6122));
  HH(b, c, d, a, x[14], S34, Longword($FDE5380C));
  HH(a, b, c, d, x[1], S31, Longword($A4BEEA44));
  HH(d, a, b, c, x[4], S32, Longword($4BDECFA9));
  HH(c, d, a, b, x[7], S33, Longword($F6BB4B60));
  HH(b, c, d, a, x[10], S34, Longword($BEBFBC70));
  HH(a, b, c, d, x[13], S31, Longword($289B7EC6));
  HH(d, a, b, c, x[0], S32, Longword($EAA127FA));
  HH(c, d, a, b, x[3], S33, Longword($D4EF3085));
  HH(b, c, d, a, x[6], S34, Longword($4881D05));
  HH(a, b, c, d, x[9], S31, Longword($D9D4D039));
  HH(d, a, b, c, x[12], S32, Longword($E6DB99E5));
  HH(c, d, a, b, x[15], S33, Longword($1FA27CF8));
  HH(b, c, d, a, x[2], S34, Longword($C4AC5665));

  II(a, b, c, d, x[0], S41, Longword($F4292244));
  II(d, a, b, c, x[7], S42, Longword($432AFF97));
  II(c, d, a, b, x[14], S43, Longword($AB9423A7));
  II(b, c, d, a, x[5], S44, Longword($FC93A039));
  II(a, b, c, d, x[12], S41, Longword($655B59C3));
  II(d, a, b, c, x[3], S42, Longword($8F0CCC92));
  II(c, d, a, b, x[10], S43, Longword($FFEFF47D));
  II(b, c, d, a, x[1], S44, Longword($85845DD1));
  II(a, b, c, d, x[8], S41, Longword($6FA87E4F));
  II(d, a, b, c, x[15], S42, Longword($FE2CE6E0));
  II(c, d, a, b, x[6], S43, Longword($A3014314));
  II(b, c, d, a, x[13], S44, Longword($4E0811A1));
  II(a, b, c, d, x[4], S41, Longword($F7537E82));
  II(d, a, b, c, x[11], S42, Longword($BD3AF235));
  II(c, d, a, b, x[2], S43, Longword($2AD7D2BB));
  II(b, c, d, a, x[9], S44, Longword($EB86D391));

  Inc(State[0], a);
  Inc(State[1], b);
  Inc(State[2], c);
  Inc(State[3], d);

  MD5_memset(PByteArray(@x), 0, SizeOf(x));
end;

procedure MD5Init(var Context: TMD5Context);
begin
  FillChar(Context, SizeOf(Context), 0);
  Context.state[0] := Longword($67452301);
  Context.state[1] := Longword($EFCDAB89);
  Context.state[2] := Longword($98BADCFE);
  Context.state[3] := Longword($10325476);
end;

procedure MD5Update(var Context: TMD5Context; Input: PByteArray; InputLen:
  LongWord);
var
  i, index, partLen: LongWord;

begin
  index := LongWord((context.count[0] shr 3) and $3F);
  Inc(Context.count[0], UINT4(InputLen) shl 3);
  if Context.count[0] < UINT4(InputLen) shl 3 then
    Inc(Context.count[1]);
  Inc(Context.count[1], UINT4(InputLen) shr 29);
  partLen := 64 - index;
  if inputLen >= partLen then
  begin
    MD5_memcpy(PByteArray(@Context.buffer[index]), Input, PartLen);
    MD5Transform(@Context.state, @Context.buffer);
    i := partLen;
    while i + 63 < inputLen do
    begin
      MD5Transform(@Context.state, PArray64Byte(@Input[i]));
      Inc(i, 64);
    end;
    index := 0;
  end
  else
    i := 0;
  MD5_memcpy(PByteArray(@Context.buffer[index]), PByteArray(@Input[i]), inputLen
    - i);
end;

{ Sheet protection }
function XLSProtectGetPasswordHash(const Password: AnsiString): Word;
var
  Hash: Word;
  B: Word;
  CharIndex, CharCount: Word;
begin
  {
  [C ]hash = 0 ;char_index = 0 ;char_count = character count of password
  [D ]char = character from password with index char_index {left-to-right,0 is
     leftmost character
  [E ]char_index = char_index +1
  [F ]rotate the lower 15 bits of AnsiChar left by char_index bits
  [G ]hash = hash XOR char
  [H ]IF char_index <char_count THEN JUMP [D])
  [I ]RETURN hash XOR char_count XOR CE4BH
  }

  Hash:= 0;
  CharCount:= Length(Password);

  { max password length is 15}
  if (CharCount > 15) then
    raise Exception.Create('Sheet protection password must have 0-15 characters.');

  for CharIndex:= 1 to CharCount do
  begin
    B:= Byte(Password[CharIndex]) and $00FF;
    B:= ((B shl CharIndex) and $7FFF) or ((B shr (15 - CharIndex)) and $7FFF);
    Hash:= Hash xor B;
  end;

  Result:= Hash xor CharCount xor $CE4B;
end;

{ RC4 }
type
  PByte = ^Byte;

procedure SwapByte(a, b: PByte);
var
  x: Byte;
begin
  x:= a^;
  Move(b^, a^, 1);
  Move(x, b^, 1);
end;

procedure PrepareKey (KeyData: PAnsiChar; KeyDataLen: Integer; var Key: TRC4Key);
var
  Index1, Index2: Integer;
  Counter: Integer;
begin
  for Counter:= 0 to 255 do
    Key.State[Counter] := Counter;

  Key.x:= 0;
  Key.y:= 0;
  Index1 := 0;
  Index2 := 0;

  for Counter:= 0 to 255 do
  begin
    Index2:= (Byte((KeyData + Index1)^) + Key.State[Counter] + Index2) mod 256;
    SwapByte(@(Key.State[Counter]), @(Key.State[Index2]));
    Index1:= (Index1 + 1) mod KeyDataLen;
  end;
end;

procedure BIFF8ProtectRC4Transform(Buffer: PAnsiChar; BufferLen: Integer; var Key: TRC4Key);
var
  x, y: Byte;
  xorIndex: Byte;
  Counter: Integer;
begin
  x:= Key.x;
  y:= Key.y;

  for Counter:= 0 to BufferLen - 1 do
  begin
    x := (x + 1) mod 256;
    y := (Key.State[x] + y) mod 256;
    SwapByte(@(Key.State[x]), @(Key.State[y]));

    xorIndex := (Key.State[x] + Key.State[y]) mod 256;

    (Buffer + Counter)^:= AnsiChar(Byte((Buffer + Counter)^) xor (Key.State[xorIndex]));
  end;

  Key.x:= x;
  Key.y:= y;
end;


{ Crypto functions }
procedure MD5StoreDigest(var mdContext: TMD5Context; var mdDigest: TMD5Digest);
var
  i, ii: UINT4;
begin
  ii:= 0;
  for i:= 0 to 3 do
  begin
    mdDigest.v[ii]:= Byte(mdContext.State[i] and $FF);
    mdDigest.v[ii + 1]:= Byte(( mdContext.State[i] shr 8 ) and $FF);
    mdDigest.v[ii + 2]:= Byte(( mdContext.State[i] shr 16 ) and $FF);
    mdDigest.v[ii + 3]:= Byte(( mdContext.State[i] shr 24 ) and $FF);

    ii:= ii + 4;
  end;
end;

procedure BIFF8ProtectMakeKey(Block: UINT4; var Key: TRC4Key; var valDigest: TMD5Digest);
var
  mdContext: TMD5Context;
  mdDigest: TMD5Digest;
  pwarray : TArray64Byte;
begin
  FillChar(pwarray[0], 64, 0);
  Move(valDigest, pwarray[0], 5);

  pwarray[5] := Byte(block and $FF);
  pwarray[6] := Byte((block shr 8) and $FF);
  pwarray[7] := Byte((block shr 16) and $FF);
  pwarray[8] := Byte((block shr 24) and $FF);
  pwarray[9] := $80;
  pwarray[56] := $48;

  MD5Init(mdContext);
  MD5Update(mdContext, @pwarray[0], 64);

  MD5StoreDigest(mdContext, mdDigest);
  PrepareKey(@mdDigest.v[0], 16, Key);
end;

procedure ExpandPw(Password: WideString; var pwarray: TArray64Byte);
var
  Len, I: Integer;
  B: Byte;
begin
  FillChar(pwarray[0], 64, 0);

  Len:= Length(Password);

  if (Len > 15) then
    raise Exception.Create('File protection password must have 0-15 characters.');
    
  for I:= 0 to Len - 1 do
  begin
    B:= Byte((PAnsiChar(@Password[I + 1]) + 1)^);
    pwarray[2 * I + 1]:= B;
    B:= Byte((PAnsiChar(@Password[I + 1]))^);
    pwarray[2 * I ]:= B;
  end;

  pwarray[2 * Len] := $80;
  pwarray[56] := Byte( (Len and $FF) shl 4);
end;

function BIFF8ProtectVerifyPassword(Password: WideString;
  DocID: TArray16Byte;
  Salt: TArray64Byte;
  HashedSalt: TArray16Byte;
  var valDigest: TMD5Digest): Boolean;
var
  pwarray: TArray64Byte;
  mdContext1, mdContext2: TMD5Context;
  mdDigest1, mdDigest2: TMD5Digest;
  Key: TRC4Key;
  Offset, KeyOffset: Integer;
  ToCopy: Integer;
  valContext: TMD5Context;
begin
  ExpandPw(Password, pwarray);

  MD5Init(mdContext1);
  MD5Update(mdContext1, @pwarray[0], 64);
  MD5StoreDigest(mdContext1, mdDigest1);

  Offset := 0;
  KeyOffset:= 0;
  ToCopy:= 5;

  MD5Init(valContext);

  while (Offset <> 16) do
  begin
    if ((64 - offset) < 5) then
      ToCopy:= 64 - Offset;

    Move(mdDigest1.v[KeyOffset], pwarray[Offset], ToCopy);
    Offset:= Offset + ToCopy;

    if (Offset = 64) then
    begin
      MD5Update(valContext, @pwarray[0], 64);
      KeyOffset:= ToCopy;
      ToCopy:= 5 - ToCopy;
      Offset:= 0;
      Continue;
    end;

    KeyOffset := 0;
    ToCopy:= 5;
    Move(DocID[0], pwarray[Offset], 16);
    Offset:= Offset + 16;
  end;

  pwarray[16] := $80;
  FillChar(pwarray[17], 47, 0);
  pwarray[56] := $80;
  pwarray[57] := $0A;

  MD5Update(valContext, @pwarray[0], 64);
  MD5StoreDigest(valContext, valDigest);

  // Generate 40-bit RC4 key from 128-bit hashed password 
  BIFF8ProtectMakeKey(0, Key, valDigest);

  BIFF8ProtectRC4Transform(@salt[0], 16, Key);
  BIFF8ProtectRC4Transform(@hashedsalt[0], 16, Key);

  salt[16] := $80;
  FillChar(salt[17], 47, 0);
  salt[56] := $80;

  MD5Init(mdContext2);
  MD5Update(mdContext2, @salt[0], 64);
  MD5StoreDigest(mdContext2, mdDigest2);

  Result:= CompareMem(@mdDigest2, @hashedsalt[0], 16);
end;

procedure BIFF8ProtectPrepareCrypt(const Password: WideString;
  var DocID: TArray16Byte; var Salt: TArray64Byte; var HashedSalt: TArray16Byte;
  var valDigest: TMD5Digest);
var
  G: TGUID;

  pwarray: TArray64Byte;
  mdContext1, mdContext2: TMD5Context;
  mdDigest1, mdDigest2: TMD5Digest;
  Key: TRC4Key;
  Offset, KeyOffset: Integer;
  ToCopy: Integer;
  valContext: TMD5Context;
  LSalt: TArray64Byte;
begin
  { Create DocID, salt }
  CoCreateGuid(G);

  FillChar(Salt[0], 64, 0);
  Move(G, DocID[0], 16);
  Move(G, Salt[0], 16);

  FillChar(HashedSalt[0], 16, 0);
  Move(Salt[0], LSalt[0], 64);

  { Make HashedSalt, Digest }
  ExpandPw(Password, pwarray);

  MD5Init(mdContext1);
  MD5Update(mdContext1, @pwarray[0], 64);
  MD5StoreDigest(mdContext1, mdDigest1);

  Offset := 0;
  KeyOffset:= 0;
  ToCopy:= 5;

  MD5Init(valContext);

  while (Offset <> 16) do
  begin
    if ((64 - offset) < 5) then
      ToCopy:= 64 - Offset;

    Move(mdDigest1.v[KeyOffset], pwarray[Offset], ToCopy);
    Offset:= Offset + ToCopy;

    if (Offset = 64) then
    begin
      MD5Update(valContext, @pwarray[0], 64);
      KeyOffset:= ToCopy;
      ToCopy:= 5 - ToCopy;
      Offset:= 0;
      Continue;
    end;

    KeyOffset := 0;
    ToCopy:= 5;
    Move(DocID[0], pwarray[Offset], 16);
    Offset:= Offset + 16;
  end;

  pwarray[16] := $80;
  FillChar(pwarray[17], 47, 0);
  pwarray[56] := $80;
  pwarray[57] := $0A;

  MD5Update(valContext, @pwarray[0], 64);
  MD5StoreDigest(valContext, valDigest);

  // Generate 40-bit RC4 key from 128-bit hashed password
  BIFF8ProtectMakeKey(0, Key, valDigest);

  BIFF8ProtectRC4Transform(@LSalt[0], 16, Key);

  LSalt[16] := $80;
  FillChar(LSalt[17], 47, 0);
  LSalt[56] := $80;

  MD5Init(mdContext2);
  MD5Update(mdContext2, @LSalt[0], 64);
  MD5StoreDigest(mdContext2, mdDigest2);

  Move(mdDigest2, HashedSalt[0], 16);

  BIFF8ProtectRC4Transform(@HashedSalt[0], 16, Key);
end;

procedure BIFF8ProtectCryptBlock(InData: Pointer; OutData: Pointer;
  BlockNum: Integer; var Key: TRC4Key; var Digest: TMD5Digest);
var
  Buff: array[0..15] of Byte;
  Offset: Integer;
begin
  FillChar(OutData^, BIFF8_REKEY_BLOCK, 0);

  BIFF8ProtectMakeKey(BlockNum, Key, Digest);

  Offset:= 0;
  while (Offset < BIFF8_REKEY_BLOCK - 1) do
  begin
    FillChar(Buff[0], 16, 0);

    Move((PAnsiChar(InData) + Offset)^, Buff[0], 16);
    BIFF8ProtectRC4Transform(@Buff[0], 16, Key);
    Move(Buff[0], (PAnsiChar(OutData) + Offset)^, 16);
    Offset:= Offset + 16;
  end;
end;
  

end.
