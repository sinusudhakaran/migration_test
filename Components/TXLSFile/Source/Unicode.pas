unit Unicode;

{-----------------------------------------------------------------
    SM Software, 2000-2009

    TXLSFile v.4.0

    Unicode related functions
-----------------------------------------------------------------}

interface

uses XLSBase;

{  Def.
   String - ANSI string
   Sparsed String - String with characters interleaved with 0-bytes
   SST String - String where 1st byte is the Unicode-flag (1 - Unicode, 0 - non-Unicode)
   ANSI WideString - WideString stored in String buffer
}

function IsSparsedString(var S: AnsiString): Boolean;
function SparseString(var S: AnsiString): AnsiString;
function CompressString(var S: AnsiString): AnsiString;

function StringToSSTString(const S: AnsiString): AnsiString;
function SSTStringToWideString(const S: AnsiString): WideString;
function WideStringToSSTString(const WS: WideString): AnsiString;
function WideStringToANSIWideString(const WS: WideString): AnsiString;
function StringToANSIWideString(const S: AnsiString): AnsiString;
function ANSIWideStringToString(const S: AnsiString): AnsiString;
function ANSIWideStringToWideString(const S: AnsiString): WideString;
function StringToWideString(const S: AnsiString): WideString;

function WideStringReplace(const WS, OldPattern, NewPattern: WideString): WideString;
function WideStringUpperCase(const WS: WideString): WideString;
function WideStringLowerCase(const WS: WideString): WideString;

{$IFDEF OLE_XLSFile}
threadvar CodePageForConversions: Integer;
{$ELSE}
var CodePageForConversions: Integer;
{$ENDIF}

implementation
uses Windows, SysUtils;

{ Internal functions }
function StringToWideChar_CodePage(const Source: AnsiString; Dest: PWideChar;
  DestSize: Integer): PWideChar;
begin
  Dest[MultiByteToWideChar(CodePageForConversions, 0, PAnsiChar(Source), Length(Source),
    Dest, DestSize - 1)] := #0;
  Result := Dest;
end;

procedure WideCharLenToStrVar_CodePage(Source: PWideChar; SourceLen: Integer;
  var Dest: AnsiString);
var
  DestLen: Integer;
  Buffer: array[0..2047] of AnsiChar;
begin
  if SourceLen = 0 then
    Dest := ''
  else
    if SourceLen < SizeOf(Buffer) div 2 then
      SetString(Dest, Buffer, WideCharToMultiByte(CodePageForConversions, 0,
        Source, SourceLen, Buffer, SizeOf(Buffer), nil, nil))
    else
    begin
      DestLen := WideCharToMultiByte(CodePageForConversions, 0, Source, SourceLen,
        nil, 0, nil, nil);
      SetString(Dest, nil, DestLen);
      WideCharToMultiByte(CodePageForConversions, 0, Source, SourceLen, Pointer(Dest),
        DestLen, nil, nil);
    end;
end;

function WideCharLenToString_CodePage(Source: PWideChar; SourceLen: Integer): AnsiString;
begin
  WideCharLenToStrVar_CodePage(Source, SourceLen, Result);
end;

function SparseString(var S: AnsiString): AnsiString;
var
  Index: Integer;
begin
  Result:= '';
  for Index:= 1 to Length(S) do
    Result:= Result + S[Index] + #0;
end;

function CompressString(var S: AnsiString): AnsiString;
var
  Index: Integer;
begin
  Result:= '';
  for Index:= 1 to Length(S) div 2 do
    Result:= Result + S[2 * Index - 1];
end;

function IsSparsedString(var S: AnsiString): Boolean;
var
  Index, Len: Integer;
begin
  Result:= True;

  Len:= Length(S);
  Index:= 2;
  while Index < Len do
  begin
    if S[Index] <> #0 then
    begin
      Result:= False;
      Break;
    end;

    Index:= Index + 2;
  end;
end;

{ Exported functions }
function StringToSSTString(const S: AnsiString): AnsiString;
var
  Buffer: AnsiString;
  BufferLen: Integer;
begin
  BufferLen:= Length(S) * 2 + 2;
  SetLength(Buffer, BufferLen);
  FillChar(Buffer[1], BufferLen, 0);
  StringToWideChar_CodePage(S, @Buffer[1], BufferLen);

  if IsSparsedString(Buffer) then
    Result:= AnsiChar(0) + S
  else
    Result:= AnsiChar(1) + Copy(Buffer, 1, BufferLen - 2);
end;

function WideStringToSSTString(const WS: WideString): AnsiString;
begin
  SetLength(Result, Length(WS) * 2 + 1);
  Result[1]:= #1;
  if Length(WS) > 0 then
    Move(WS[1], Result[2], Length(WS) * 2);
end;

function WideStringToANSIWideString(const WS: WideString): AnsiString;
begin
  SetLength(Result, Length(WS) * 2);
  if Length(WS) > 0 then
    Move(WS[1], Result[1], Length(WS) * 2);
end;

function SSTStringToWideString(const S: AnsiString): WideString;
begin
  if Length(S) = 0 then Exit;
  if S[1] <> #1 then Exit;
  SetLength(Result, (Length(S) - 1) div 2);
  if (Length(S) - 1) > 0 then
    Move(S[2], Result[1], (Length(S) - 1));
end;

function StringToANSIWideString(const S: AnsiString): AnsiString;
var
  BufferLen: integer;
begin
  BufferLen:= Length(S) * 2 + 2;
  SetLength(Result, BufferLen);
  FillChar(Result[1], BufferLen, 0);
  StringToWideChar_CodePage(S, @Result[1], BufferLen);
  Result:= Copy(Result, 1, Length(Result) - 2);
end;

function ANSIWideStringToString(const S: AnsiString): AnsiString;
begin
  if Length(S) > 0 then
    Result:= WideCharLenToString_CodePage(PWideChar(@S[1]), Length(S) div 2)
  else
    Result:= '';
end;

function ANSIWideStringToWideString(const S: AnsiString): WideString;
begin
  SetLength(Result, Length(S) div 2);
  if Length(S) > 0 then
    Move(S[1], Result[1], Length(S));
end;

function StringToWideString(const S: AnsiString): WideString;
var
  Len: Integer;
begin
  if S = '' then
    Result := ''
  else
  begin
    Len := MultiByteToWideChar(CodePageForConversions, 0, PAnsiChar(S), -1, nil, 0);

    if Len > 1 then
    begin
      SetLength(Result, Len - 1);
      MultiByteToWideChar(CodePageForConversions, 0, PAnsiChar(S), -1, PWideChar(Result), Len);
    end
    else
      Result := '';
  end;
end;

function WideStringReplace(const WS, OldPattern, NewPattern: WideString): WideString;
var
  SearchStr, Patt, NewStr: WideString;
  Offset: Integer;
begin
  SearchStr := WS;
  Patt := OldPattern;

  NewStr := WS;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := Pos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;

function WideStringUpperCase(const WS: WideString): WideString;
var
  S, Buff: AnsiString;
  I: Integer;
begin
  S:= WideStringToANSIWideString(WS);
  for I:= 1 to Length(S) do
    if S[I] <> #0 then
    begin
      Buff:= S[I];
      Buff:= AnsiStrUpper(PAnsiChar(Buff));
      S[I]:= Buff[1];
    end;  
  Result:= ANSIWideStringToWideString(S);
end;

function WideStringLowerCase(const WS: WideString): WideString;
var
  S, Buff: AnsiString;
  I: Integer;
begin
  S:= WideStringToANSIWideString(WS);
  for I:= 1 to Length(S) do
    if S[I] <> #0 then
    begin
      Buff:= S[I];
      Buff:= AnsiStrLower(PAnsiChar(Buff));
      S[I]:= Buff[1];
    end;
  Result:= ANSIWideStringToWideString(S);
end;

end.
