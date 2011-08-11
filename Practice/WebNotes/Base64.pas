unit Base64;
//------------------------------------------------------------------------------
{
   Title: Base64

   Description:

        Base 64 Encoding and Decoding for
           1) Byte Array
           2) SLA1 Hash used by Indy10

   Author: Ralph Austen

   Remarks:
}
//------------------------------------------------------------------------------

interface
uses
  Sysutils,
  IdHash;

Type
  TByteArray = Array of Byte;
  TByteArr20 = Array[0..19] of Byte;

procedure B64Encode(const ByteArr : TByteArray; var OutStr : string); Overload;
procedure B64Encode(const Hash160 : T5x4LongWordRecord; var OutStr : string); Overload;

procedure B64Decode(const S: string; var ByteArr : TByteArray); Overload;
procedure B64Decode(const S: string; var Hash160 : T5x4LongWordRecord); Overload;

{******************************************************************************}
{******************************************************************************}
implementation

const
  B64Table= 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

//------------------------------------------------------------------------------
procedure B64Encode(const ByteArr : TByteArray; var OutStr : string);
var
  i: integer;
  InBuf: array[0..2] of byte;
  OutBuf: array[0..3] of char;
begin
  SetLength(OutStr,((Length(ByteArr)+2) div 3)*4);
  for i:= 1 to ((Length(ByteArr)+2) div 3) do
  begin
    if Length(ByteArr)< (i*3) then
      Move(ByteArr[(i-1)*3],InBuf,Length(ByteArr)-(i-1)*3)
    else
      Move(ByteArr[(i-1)*3],InBuf,3);
    OutBuf[0]:= B64Table[((InBuf[0] and $FC) shr 2) + 1];
    OutBuf[1]:= B64Table[(((InBuf[0] and $03) shl 4) or ((InBuf[1] and $F0) shr 4)) + 1];
    OutBuf[2]:= B64Table[(((InBuf[1] and $0F) shl 2) or ((InBuf[2] and $C0) shr 6)) + 1];
    OutBuf[3]:= B64Table[(InBuf[2] and $3F) + 1];
    Move(OutBuf,OutStr[(i-1)*4+1],4);
  end;
  if (Length(ByteArr) mod 3)= 1 then
  begin
    OutStr[Length(OutStr)-1]:= '=';
    OutStr[Length(OutStr)]:= '=';
  end
  else if (Length(ByteArr) mod 3)= 2 then
    OutStr[Length(OutStr)]:= '=';
end;

//------------------------------------------------------------------------------
procedure B64Encode(const Hash160 : T5x4LongWordRecord; var OutStr : string);
var
  ByteArr : TByteArray;
  ByteIndex : integer;
begin
  Setlength(ByteArr, 20);
  for ByteIndex := 0 to 19 do
  begin
    ByteArr[ByteIndex] := TByteArr20(Hash160)[ByteIndex];
  end;

  B64Encode(ByteArr, OutStr);
end;

//------------------------------------------------------------------------------
procedure B64Decode(const S: string; var ByteArr : TByteArray);
var
  i: integer;
  InBuf: array[0..3] of byte;
  OutBuf: array[0..2] of byte;
  ByteIndex : integer;
begin
  ByteIndex := 0;
  if (Length(S) mod 4)<> 0 then
    raise Exception.Create('Base64: Incorrect string format');
  SetLength(ByteArr,((Length(S) div 4)-1)*3);
  for i:= 1 to ((Length(S) div 4)-1) do
  begin
    Move(S[(i-1)*4+1],InBuf,4);
    if (InBuf[0]> 64) and (InBuf[0]< 91) then
      Dec(InBuf[0],65)
    else if (InBuf[0]> 96) and (InBuf[0]< 123) then
      Dec(InBuf[0],71)
    else if (InBuf[0]> 47) and (InBuf[0]< 58) then
      Inc(InBuf[0],4)
    else if InBuf[0]= 43 then
      InBuf[0]:= 62
    else
      InBuf[0]:= 63;
    if (InBuf[1]> 64) and (InBuf[1]< 91) then
      Dec(InBuf[1],65)
    else if (InBuf[1]> 96) and (InBuf[1]< 123) then
      Dec(InBuf[1],71)
    else if (InBuf[1]> 47) and (InBuf[1]< 58) then
      Inc(InBuf[1],4)
    else if InBuf[1]= 43 then
      InBuf[1]:= 62
    else
      InBuf[1]:= 63;
    if (InBuf[2]> 64) and (InBuf[2]< 91) then
      Dec(InBuf[2],65)
    else if (InBuf[2]> 96) and (InBuf[2]< 123) then
      Dec(InBuf[2],71)
    else if (InBuf[2]> 47) and (InBuf[2]< 58) then
      Inc(InBuf[2],4)
    else if InBuf[2]= 43 then
      InBuf[2]:= 62
    else
      InBuf[2]:= 63;
    if (InBuf[3]> 64) and (InBuf[3]< 91) then
      Dec(InBuf[3],65)
    else if (InBuf[3]> 96) and (InBuf[3]< 123) then
      Dec(InBuf[3],71)
    else if (InBuf[3]> 47) and (InBuf[3]< 58) then
      Inc(InBuf[3],4)
    else if InBuf[3]= 43 then
      InBuf[3]:= 62
    else
      InBuf[3]:= 63;
    OutBuf[0]:= (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $03);
    OutBuf[1]:= (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $0F);
    OutBuf[2]:= (InBuf[2] shl 6) or (InBuf[3] and $3F);
    Move(OutBuf,ByteArr[(i-1)*3],3);
  end;
  if Length(S)<> 0 then
  begin
    Move(S[Length(S)-3],InBuf,4);
    if InBuf[2]= 61 then
    begin
      if (InBuf[0]> 64) and (InBuf[0]< 91) then
        Dec(InBuf[0],65)
      else if (InBuf[0]> 96) and (InBuf[0]< 123) then
        Dec(InBuf[0],71)
      else if (InBuf[0]> 47) and (InBuf[0]< 58) then
        Inc(InBuf[0],4)
      else if InBuf[0]= 43 then
        InBuf[0]:= 62
      else
        InBuf[0]:= 63;
      if (InBuf[1]> 64) and (InBuf[1]< 91) then
        Dec(InBuf[1],65)
      else if (InBuf[1]> 96) and (InBuf[1]< 123) then
        Dec(InBuf[1],71)
      else if (InBuf[1]> 47) and (InBuf[1]< 58) then
        Inc(InBuf[1],4)
      else if InBuf[1]= 43 then
        InBuf[1]:= 62
      else
        InBuf[1]:= 63;
      OutBuf[0]:= (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $03);

      ByteArr[ByteIndex] := OutBuf[0];
      inc(ByteIndex);
      //Result:= Result + char(OutBuf[0]);
    end
    else if InBuf[3]= 61 then
    begin
      if (InBuf[0]> 64) and (InBuf[0]< 91) then
        Dec(InBuf[0],65)
      else if (InBuf[0]> 96) and (InBuf[0]< 123) then
        Dec(InBuf[0],71)
      else if (InBuf[0]> 47) and (InBuf[0]< 58) then
        Inc(InBuf[0],4)
      else if InBuf[0]= 43 then
        InBuf[0]:= 62
      else
        InBuf[0]:= 63;
      if (InBuf[1]> 64) and (InBuf[1]< 91) then
        Dec(InBuf[1],65)
      else if (InBuf[1]> 96) and (InBuf[1]< 123) then
        Dec(InBuf[1],71)
      else if (InBuf[1]> 47) and (InBuf[1]< 58) then
        Inc(InBuf[1],4)
      else if InBuf[1]= 43 then
        InBuf[1]:= 62
      else
        InBuf[1]:= 63;
      if (InBuf[2]> 64) and (InBuf[2]< 91) then
        Dec(InBuf[2],65)
      else if (InBuf[2]> 96) and (InBuf[2]< 123) then
        Dec(InBuf[2],71)
      else if (InBuf[2]> 47) and (InBuf[2]< 58) then
        Inc(InBuf[2],4)
      else if InBuf[2]= 43 then
        InBuf[2]:= 62
      else
        InBuf[2]:= 63;
      OutBuf[0]:= (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $03);
      OutBuf[1]:= (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $0F);

      //Result:= Result + char(OutBuf[0]) + char(OutBuf[1]);
      ByteArr[ByteIndex] := OutBuf[0];
      inc(ByteIndex);
      ByteArr[ByteIndex] := OutBuf[1];
      inc(ByteIndex);
    end
    else
    begin
      if (InBuf[0]> 64) and (InBuf[0]< 91) then
        Dec(InBuf[0],65)
      else if (InBuf[0]> 96) and (InBuf[0]< 123) then
        Dec(InBuf[0],71)
      else if (InBuf[0]> 47) and (InBuf[0]< 58) then
        Inc(InBuf[0],4)
      else if InBuf[0]= 43 then
        InBuf[0]:= 62
      else
        InBuf[0]:= 63;
      if (InBuf[1]> 64) and (InBuf[1]< 91) then
        Dec(InBuf[1],65)
      else if (InBuf[1]> 96) and (InBuf[1]< 123) then
        Dec(InBuf[1],71)
      else if (InBuf[1]> 47) and (InBuf[1]< 58) then
        Inc(InBuf[1],4)
      else if InBuf[1]= 43 then
        InBuf[1]:= 62
      else
        InBuf[1]:= 63;
      if (InBuf[2]> 64) and (InBuf[2]< 91) then
        Dec(InBuf[2],65)
      else if (InBuf[2]> 96) and (InBuf[2]< 123) then
        Dec(InBuf[2],71)
      else if (InBuf[2]> 47) and (InBuf[2]< 58) then
        Inc(InBuf[2],4)
      else if InBuf[2]= 43 then
        InBuf[2]:= 62
      else
        InBuf[2]:= 63;
      if (InBuf[3]> 64) and (InBuf[3]< 91) then
        Dec(InBuf[3],65)
      else if (InBuf[3]> 96) and (InBuf[3]< 123) then
        Dec(InBuf[3],71)
      else if (InBuf[3]> 47) and (InBuf[3]< 58) then
        Inc(InBuf[3],4)
      else if InBuf[3]= 43 then
        InBuf[3]:= 62
      else
        InBuf[3]:= 63;
      OutBuf[0]:= (InBuf[0] shl 2) or ((InBuf[1] shr 4) and $03);
      OutBuf[1]:= (InBuf[1] shl 4) or ((InBuf[2] shr 2) and $0F);
      OutBuf[2]:= (InBuf[2] shl 6) or (InBuf[3] and $3F);
      //Result:= Result + Char(OutBuf[0]) + Char(OutBuf[1]) + Char(OutBuf[2]);

      ByteArr[ByteIndex] := OutBuf[0];
      inc(ByteIndex);
      ByteArr[ByteIndex] := OutBuf[1];
      inc(ByteIndex);
      ByteArr[ByteIndex] := OutBuf[2];
      inc(ByteIndex);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure B64Decode(const S: string; var Hash160 : T5x4LongWordRecord);
var
  ByteArr : TByteArray;
  ByteIndex : integer;
begin
  B64Decode(S, ByteArr);
  for ByteIndex := 0 to 19 do
    TByteArr20(Hash160)[ByteIndex] := ByteArr[ByteIndex];
end;

end.

 
 

