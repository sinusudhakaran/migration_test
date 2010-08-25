unit XLSStrUtil;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0
-----------------------------------------------------------------}

interface

uses SysUtils, Unicode, XLSBase;

{$I XLSFile.inc}

{$IFDEF XLF_D3}
type
  TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

function StringReplace(const S, OldPattern, NewPattern: AnsiString; Flags: TReplaceFlags): AnsiString;
{$ENDIF}

function SetStringDataItem(const StringData: AnsiString; const ItemKey: AnsiString; const ItemValue: AnsiString): AnsiString;
function GetStringDataItem(const StringData: AnsiString; const ItemKey: AnsiString): AnsiString;

{ UTF-8 functions }
type
  XLSUTF8String = type AnsiString;
  PXLSUTF8String = ^XLSUTF8String;

{ PChar/PWideChar Unicode <-> UTF8 conversion }
function XLSUnicodeToUtf8(Dest: PAnsiChar; MaxDestBytes: Cardinal; Source: PWideChar; SourceChars: Cardinal): Cardinal; 
function XLSUtf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PAnsiChar; SourceBytes: Cardinal): Cardinal; 
{ WideString <-> UTF8 conversion }
function XLSUTF8Encode(const WS: WideString): XLSUTF8String;
function XLSUTF8Decode(const S: XLSUTF8String): WideString;
{ Ansi <-> UTF8 conversion }
function XLSAnsiToUtf8(const S: AnsiString): XLSUTF8String;
function XLSUtf8ToAnsi(const S: XLSUTF8String): AnsiString;

function AnsiStringUpperCase(const AString: AnsiString): AnsiString;
function AnsiStringLowerCase(const AString: AnsiString): AnsiString;


implementation

{$IFDEF XLF_D3}
function StringReplace(const S, OldPattern, NewPattern: AnsiString; Flags: TReplaceFlags): AnsiString;
var
  SearchStr, Patt, NewStr: AnsiString;
  Offset: Integer;
begin
  if rfIgnoreCase in Flags then
  begin
    SearchStr := AnsiUpperCase(S);
    Patt := AnsiUpperCase(OldPattern);
  end else
  begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := AnsiPos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then
    begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;
{$ENDIF}

const
  STRPAK_SIGN = AnsiString(#$FF#00#$FF#99);

function SetStringDataItem(const StringData: AnsiString; const ItemKey: AnsiString;
  const ItemValue: AnsiString): AnsiString;
var
  StrPos: Integer;
  BeforeBuffer, AfterBuffer, Buffer: AnsiString;
  AddData: AnsiString;
begin
  if (ItemValue = '') then
    AddData:= ''
  else
    AddData:= STRPAK_SIGN + ItemKey + STRPAK_SIGN + ItemValue + STRPAK_SIGN;

  StrPos:= Pos(STRPAK_SIGN + ItemKey + STRPAK_SIGN, StringData);
  if (StrPos <= 0) then
  begin
    Result:= StringData + AddData;
    Exit;
  end;

  BeforeBuffer:= Copy(StringData, 1, StrPos - 1);

  Buffer:= Copy(StringData, StrPos + 2 * Length(STRPAK_SIGN) + Length(ItemKey), Length(StringData));
  StrPos:= Pos(STRPAK_SIGN, Buffer);
  if (StrPos <= 0) then
  begin
    {incorrect string data}
    Result:= '';
    Exit;
  end;

  AfterBuffer:= Copy(Buffer, StrPos + Length(STRPAK_SIGN), Length(Buffer));
  Result:= BeforeBuffer + AddData + AfterBuffer;
end;

function GetStringDataItem(const StringData: AnsiString; const ItemKey: AnsiString): AnsiString;
var
  StrPos: Integer;
  Buffer: AnsiString;
begin
  Result:= '';
  StrPos:= Pos(STRPAK_SIGN + ItemKey + STRPAK_SIGN, StringData);
  if (StrPos <= 0) then Exit;

  Buffer:= Copy(StringData, StrPos + 2* Length(STRPAK_SIGN) + Length(ItemKey), Length(StringData));
  StrPos:= Pos(STRPAK_SIGN, Buffer);
  if (StrPos <= 0) then Exit;

  Buffer:= Copy(Buffer, 1, StrPos - 1);
  Result:= Buffer;
end;

// UnicodeToUtf8(4):
// MaxDestBytes includes the null terminator (last char in the buffer will be set to null)
// Function result includes the null terminator.
// Nulls in the source data are not considered terminators - SourceChars must be accurate

function XLSUnicodeToUtf8(Dest: PAnsiChar; MaxDestBytes: Cardinal; Source: PWideChar; SourceChars: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Cardinal;
begin
  Result := 0;
  if Source = nil then Exit;
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceChars) and (count < MaxDestBytes) do
    begin
      c := Cardinal(Source[i]);
      Inc(i);
      if c <= $7F then
      begin
        Dest[count] := AnsiChar(c);
        Inc(count);
      end
      else if c > $7FF then
      begin
        if count + 3 > MaxDestBytes then
          break;
        Dest[count] := AnsiChar($E0 or (c shr 12));
        Dest[count+1] := AnsiChar($80 or ((c shr 6) and $3F));
        Dest[count+2] := AnsiChar($80 or (c and $3F));
        Inc(count,3);
      end
      else //  $7F < Source[i] <= $7FF
      begin
        if count + 2 > MaxDestBytes then
          break;
        Dest[count] := AnsiChar($C0 or (c shr 6));
        Dest[count+1] := AnsiChar($80 or (c and $3F));
        Inc(count,2);
      end;
    end;
    if count >= MaxDestBytes then count := MaxDestBytes-1;
    Dest[count] := #0;
  end
  else
  begin
    while i < SourceChars do
    begin
      c := Integer(Source[i]);
      Inc(i);
      if c > $7F then
      begin
        if c > $7FF then
          Inc(count);
        Inc(count);
      end;
      Inc(count);
    end;
  end;
  Result := count+1;  // convert zero based index to byte count
end;

function XLSUtf8ToUnicode(Dest: PWideChar; MaxDestChars: Cardinal; Source: PAnsiChar; SourceBytes: Cardinal): Cardinal;
var
  i, count: Cardinal;
  c: Byte;
  wc: Cardinal;
begin
  if Source = nil then
  begin
    Result := 0;
    Exit;
  end;
  Result := Cardinal(-1);
  count := 0;
  i := 0;
  if Dest <> nil then
  begin
    while (i < SourceBytes) and (count < MaxDestChars) do
    begin
      wc := Cardinal(Source[i]);
      Inc(i);
      if (wc and $80) <> 0 then
      begin
        wc := wc and $3F;
        if i > SourceBytes then Exit;           // incomplete multibyte char
        if (wc and $20) <> 0 then
        begin
          c := Byte(Source[i]);
          Inc(i);
          if (c and $C0) <> $80 then  Exit;     // malformed trail byte or out of range char
          if i > SourceBytes then Exit;         // incomplete multibyte char
          wc := (wc shl 6) or (c and $3F);
        end;
        c := Byte(Source[i]);
        Inc(i);
        if (c and $C0) <> $80 then Exit;       // malformed trail byte

        Dest[count] := WideChar((wc shl 6) or (c and $3F));
      end
      else
        Dest[count] := WideChar(wc);
      Inc(count);
    end;
	if count >= MaxDestChars then count := MaxDestChars-1;
	Dest[count] := #0;
  end
  else
  begin
	while (i <= SourceBytes) do
	begin
	  c := Byte(Source[i]);
	  Inc(i);
	  if (c and $80) <> 0 then
	  begin
		if (c and $F0) = $F0 then Exit;  // too many bytes for UCS2
		if (c and $40) = 0 then Exit;    // malformed lead byte
		if i > SourceBytes then Exit;         // incomplete multibyte char

		if (Byte(Source[i]) and $C0) <> $80 then Exit;  // malformed trail byte
		Inc(i);
		if i > SourceBytes then Exit;         // incomplete multibyte char
		if ((c and $20) <> 0) and ((Byte(Source[i]) and $C0) <> $80) then Exit; // malformed trail byte
		Inc(i);
	  end;
	  Inc(count);
	end;
  end;
  Result := count+1;
end;

function XLSUtf8Encode(const WS: WideString): XLSUTF8String;
var
  L: Integer;
  Temp: XLSUTF8String;
begin
  Result := '';
  if WS = '' then Exit;
  SetLength(Temp, Length(WS) * 3); // SetLength includes space for null terminator

  L := XLSUnicodeToUtf8(PAnsiChar(Temp), Length(Temp)+1, PWideChar(WS), Length(WS));
  if L > 0 then
    SetLength(Temp, L-1)
  else
    Temp := '';
  Result := Temp;
end;

function XLSUtf8Decode(const S: XLSUTF8String): WideString;
var
  L: Integer;
  Temp: WideString;
begin
  Result := '';
  if S = '' then Exit;
  SetLength(Temp, Length(S));

  L := XLSUtf8ToUnicode(PWideChar(Temp), Length(Temp)+1, PAnsiChar(S), Length(S));
  if L > 0 then
    SetLength(Temp, L-1)
  else
    Temp := '';
  Result := Temp;
end;

function XLSAnsiToUtf8(const S: AnsiString): XLSUTF8String;
begin
  Result := XLSUtf8Encode(WideString(S));
end;

function XLSUtf8ToAnsi(const S: XLSUTF8String): AnsiString;
begin
  Result := AnsiString(XLSUtf8Decode(S));
end;

function AnsiStringUpperCase(const AString: AnsiString): AnsiString;
var
  S, Buff: AnsiString;
  I: Integer;
begin
  S:= AString;
  for I:= 1 to Length(S) do
    if S[I] <> #0 then
    begin
      Buff:= S[I];
      Buff:= AnsiStrUpper(PAnsiChar(Buff));
      S[I]:= Buff[1];
    end;
  Result:= S;
end;

function AnsiStringLowerCase(const AString: AnsiString): AnsiString;
var
  S, Buff: AnsiString;
  I: Integer;
begin
  S:= AString;
  for I:= 1 to Length(S) do
    if S[I] <> #0 then
    begin
      Buff:= S[I];
      Buff:= AnsiStrLower(PAnsiChar(Buff));
      S[I]:= Buff[1];
    end;
  Result:= S;    
end;

end.
