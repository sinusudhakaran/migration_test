unit UFlxNumberFormat;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface
uses SysUtils,
  {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} variants,{$IFEND}{$ENDIF} //Delphi 6 or above
     UFlxMessages, Math;

  function XlsFormatValue(const V: variant; const Format: Widestring; var Color: Integer): Widestring;
  function HasXlsDateTime(const Format: Widestring; var HasDate, HasTime: boolean): boolean;
/////////////////////////////////////////////////////////////////////////////////
implementation

function FindFrom(const wc: WideChar; const w: WideString; const p: integer): integer;
begin
  Result:=pos(wc, copy(w, p, Length(w)))
end;

function Section(const Index: byte; const Format: Widestring; var SectionExists: boolean):Widestring;
//split the 4 sections of a format string
var
  i: integer;
  aPos, TotalPos: integer;
begin
  aPos:=1; TotalPos:=1;
  for i:=0 to Index-1 do
    if aPos>0 then
    begin
      aPos:=FindFrom(';',Format, TotalPos);
      inc(TotalPos, aPos);
    end;

  SectionExists:=aPos>0;
  if not SectionExists then TotalPos:=1;
  Result:=copy(Format,TotalPos, FindFrom(';',Format+';', TotalPos)-1);
end;

//we include this so we don't need to use graphics
const
  clBlack = $000000;
  clGreen = $008000;
  clRed = $0000FF;
  clYellow = $00FFFF;
  clBlue = $FF0000;
  clFuchsia = $FF00FF;
  clAqua = $FFFF00;
  clWhite = $FFFFFF;


procedure CheckColor(const Format: Widestring; var Color: integer; var p: integer);
var
  s: string;
  IgnoreIt: boolean;
begin
  p:=1;
  if (Length(Format)>0) and (Format[1]='[') and (pos(']', Format)>0) then
  begin
    IgnoreIt:=false;
    s:=copy(Format,2,pos(']', Format)-2);
    if s = 'Black'  then Color:=clBlack else
    if s = 'Cyan'   then Color:=clAqua else
    if s = 'Blue'   then Color:=clBlue else
    if s = 'Green'  then Color:=clGreen else
    if s = 'Magenta'then Color:=clFuchsia else
    if s = 'Red'    then Color:=clRed else
    if s = 'White'  then Color:=clWhite else
    if s = 'Yellow' then Color:=clYellow
    else IgnoreIt:=true;

    if not IgnoreIt then p:= Pos(']', Format)+1;
  end;
end;

procedure CheckOptional(const V: Variant; const Format: widestring; var p: integer; var TextOut: widestring);
var
  p2, p3: integer;
begin
  if p>Length(Format) then exit;
  if Format[p]='[' then
  begin
    p2:=FindFrom(']', Format, p);
    if (p<Length(Format))and(Format[p+1]='$') then //currency
    begin
      p3:=FindFrom('-', Format+'-', p);
      TextOut:=TextOut + copy(Format, p+2, min(p2,p3)-3);
    end;
    Inc(p, p2);
  end;
end;

procedure CheckLiteral(const V: Variant; const Format: widestring; var p: integer; var TextOut: widestring);
begin
  if p>Length(Format) then exit;
  if (ord(Format[p])<255) and (char(Format[p]) in[' ','$','(',')','!','^','&','''','´','~','{','}','=','<','>']) then
    begin
      TextOut:=TextOut+Format[p];
      inc(p);
      exit;
    end;

  if (Format[p]='\') or (Format[p]='*')then
    begin
      if p<Length(Format) then TextOut:=TextOut+Format[p+1];
      inc(p,2);
      exit;
    end;

  if Format[p]='_' then
    begin
      if p<Length(Format) then TextOut:=TextOut+' ';
      inc(p,2);
      exit;
    end;

  if Format[p]='"' then
  begin
    inc(p);
    while (p<=Length(Format)) and (Format[p]<>'"') do
    begin
      TextOut:=TextOut+Format[p];
      inc(p);
    end;
    if p<=Length(Format) then inc(p);
  end;
end;

procedure CheckDate(const V: Variant; const Format: widestring; var p: integer; var TextOut: widestring; var LastHour: boolean;var HasDate, HasTime: boolean);
const
  DateTimeChars=['C','D','W','M','Q','Y','H','N','S','T','A','P','/',':','.'];
  DChars=['C','D','Y'];
  TChars=['H','N','S'];
var
  Fmt: string;
begin
  Fmt:='';
  while (p<=Length(Format)) and (ord(Format[p])<255) and (Upcase(char(Format[p])) in DateTimeChars) do
  begin
    if (UpCase(Char(Format[p])) in DChars)or
       (not LastHour and (UpCase(Char(Format[p]))='M')) then HasDate:=true;
    if (UpCase(Char(Format[p])) in TChars)or
       (LastHour and (UpCase(Char(Format[p]))='M')) then HasTime:=true;

    if (UpCase(Char(Format[p]))='H') then LastHour:=true;
    if LastHour and (UpCase(Char(Format[p]))='M') then
    begin
      while (p<=Length(Format)) and (UpCase(Char(Format[p]))='M') do
      begin
        Fmt:=Fmt+'n';
        inc(p);
      end;
      LastHour:=false;
    end else
    begin
      Fmt:=Fmt+Format[p];
      inc(p);
    end;
  end;

  if Fmt<>'' then TextOut:=TextOut+TryFormatDateTime(Fmt,v);
end;

procedure CheckNumber( V: Variant; const Format: widestring; var p: integer; var TextOut: widestring);
const
  NumberChars=['0','#','.',',','e','E','+','-','%'];
var
  Fmt: string;
begin
  Fmt:='';
  while (p<=Length(Format)) and (ord(Format[p])<255) and (char(Format[p]) in NumberChars) do
  begin
    if Format[p]='%' then V:=V*100;
    Fmt:=Fmt+Format[p];
    inc(p);
  end;

  if Fmt<>'' then TextOut:=TextOut+FormatFloat(Fmt,v);
end;

procedure CheckText(const V: Variant; const Format: widestring; var p: integer; var TextOut: widestring);
begin
  if p>Length(Format) then exit;
  if Format[p]='@' then
  begin
    TextOut:=TextOut+v;
    inc(p);
  end;
end;


function FormatNumber(const V: Variant; const Format: WideString; var Color: integer;var HasDate, HasTime: boolean): WideString;
var
  p, p1: integer;
  LastHour: boolean;
begin
  CheckColor(Format, Color, p);
  Result:='';  LastHour:=false;
  while p<=Length(Format) do
  begin
    p1:=p;
    CheckOptional(V, Format, p, Result);
    CheckLiteral (V, Format, p, Result);
    CheckDate    (V, Format, p, Result, LastHour, HasDate, HasTime);
    CheckNumber  (V, Format, p, Result);
    if p1=p then //not found
    begin
      Result:=V;
      exit;
    end;
  end;
end;

function FormatText(const V:Variant; Format: WideString; var Color: integer):Widestring;
var
  SectionExists: boolean;
  p, p1: integer;
begin
  Format:=Section(3, Format, SectionExists);
  if not SectionExists and (Pos('@', Format)=0) then
  begin
    Result:=v;
    exit;
  end;

  CheckColor(Format, Color, p);
  Result:='';
  while p<=Length(Format) do
  begin
    p1:=p;
    CheckOptional(V, Format, p, Result);
    CheckLiteral (V, Format, p, Result);
    CheckText    (V, Format, p, Result);
    if p1=p then //not found
    begin
      Result:=V;
      exit;
    end;
  end;
end;

function XlsFormatValueEx(const V: variant; Format: Widestring; var Color: Integer;var HasDate, HasTime: boolean): Widestring;
var
  SectionExists: boolean;
  Sec2, Sec3: integer;
begin
  HasDate:=false;
  HasTime:=false;
  if Format='' then  //General
  begin
    Result:=v;
    exit;
  end;

  Format:=StringReplaceSkipQuotes(Format,'AM/PM','AMPM'); //Format AMPM is equivalent to AM/PM on delphi

  Sec2:=FindFrom(';', Format, 1);
  if Sec2>0 then Sec3:=FindFrom(';', Format, Sec2+1)else Sec3:=0;
  case VarType(V) of
    varByte,
    varSmallint,
    varInteger,
    varSingle,
    varDouble,
   {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} varInt64,{$IFEND}{$ENDIF} //Delphi 6 or above
    varCurrency : begin
                    if Pos('[$-F800]', UpperCase(Format)) > 0 then  //This means format with long date from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime(LongDateFormat, V);
                      exit;
                    end;
                    if Pos('[$-F400]', UpperCase(Format)) > 0 then  //This means format with long hour from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime(LongTimeFormat, V);
                      exit;
                    end;

                    if (V>0) or ((V<0) and (Sec2<=0))or ((V=0) and (Sec3<=0)) then Result:=FormatNumber(V, Section(0,Format,SectionExists), Color, HasDate, HasTime) else
                    if V<0 then Result:=FormatNumber(-V, Section(1,Format,SectionExists), Color, HasDate, HasTime) else
                    Result:=FormatNumber(V, Section(2,Format,SectionExists), Color, HasDate, HasTime);
                    Assert(SectionExists,'Format section must exist');
                  end;
    varDate     : begin
                    if Pos('[$-F800]', UpperCase(Format)) > 0 then  //This means format with long date from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime(LongDateFormat, V);
                      exit;
                    end;
                    if Pos('[$-F400]', UpperCase(Format)) > 0 then  //This means format with long hour from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime(LongTimeFormat, V);
                      exit;
                    end;

                    if (V>0)or ((V<0) and (Sec2<=0))or ((V=0) and (Sec3<=0)) then Result:=FormatNumber(V, Section(0,Format,SectionExists), Color, HasDate, HasTime) else
                    if V<0 then Result:='###################' else //Negative dates are shown this way
                    Result:=FormatNumber(V, Section(2,Format,SectionExists), Color, HasDate, HasTime);
                    Assert(SectionExists,'Format section must exist');
                  end;
    varOleStr,
    varStrArg,
    varString   : Result:=FormatText(V,Format, Color);

    varBoolean	: if V then Result:=TxtTrue else Result:=TxtFalse;

    else Result:=V;
  end; //case
end;

function XlsFormatValue(const V: variant; const Format: Widestring; var Color: Integer): Widestring;
var
  HasDate, HasTime: boolean;
begin
  Result:=XlsFormatValueEx(V, Format, Color, HasDate, HasTime);
end;

function HasXlsDateTime(const Format: Widestring; var HasDate, HasTime: boolean): boolean;
var
  Color: integer;
begin
  XlsFormatValueEx(10, Format, Color, HasDate, HasTime);
  Result:=HasDate or HasTime;
end;

end.
