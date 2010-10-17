unit UFlxNumberFormat;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface
uses SysUtils,
  {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} variants,{$IFEND}{$ENDIF} //Delphi 6 or above
     UFlxMessages, Math;

  function XlsFormatValue(const V: variant; const Format: Widestring; var Color: Integer): Widestring;
  function XlsFormatValue1904(const V: variant; const Format: Widestring; const Dates1904: boolean; var Color: Integer): Widestring;
  function HasXlsDateTime(const Format: Widestring; var HasDate, HasTime: boolean): boolean;
/////////////////////////////////////////////////////////////////////////////////
implementation
type
  TResultCondition = record
    SupressNeg: Boolean;
    SupressNegComp: Boolean;
    Complement: Boolean;
    Assigned: boolean;
  end;

  TResultConditionArray = Array of TResultCondition;

var
  RegionalSet : TFormatSettings; //Must be global so it is not freed when we point to it.

procedure CheckRegionalSettings(const Format: WideString; var RegionalCulture: PFormatSettings; var p: integer; var TextOut: WideString; const Quote: Boolean);
var
  StartCurr: integer;
  v: WideString;
  StartStr: integer;
  EndStr: integer;
  Len: integer;
  Offset: integer;
  i: integer;
  digit: Char;
  Result: integer;
  FormatLength: integer;
begin
  FormatLength := Length(Format);
  if p - 1 >= (FormatLength - 3) then
    exit;

  if copy(Format, p, 2) = '[$' then  //format is [$Currency-Locale]
  begin
    p:= p + 2;
    StartCurr := p;  //Currency
    while (Format[p] <> '-') and (Format[p] <> ']') do
    begin
      Inc(p);
      if p - 1 >= FormatLength then  //no tag found.
        exit;
    end;

    if (p - StartCurr) > 0 then
    begin
      if Quote then
        TextOut := TextOut + '"';

      v := copy(Format, StartCurr, p - StartCurr);
      if Quote then
        StringReplace(v, '"', '"\""', [rfReplaceAll]);

      TextOut := TextOut + v;
      if Quote then
        TextOut := TextOut + '"';

    end;

    if Format[p] <> '-' then
    begin
      Inc(p);
      exit;  //no culture info.
    end;

    Inc(p);
    StartStr := p;
    while (p <= FormatLength) and (Format[p] <> ']') do
    begin
      begin
        Inc(p);
      end;
    end;
    if p <= FormatLength then  //We actually found a close tag
    begin
      EndStr := p;
      Inc(p);  //add the ']' char.
      Len := Math.Min(4, EndStr - StartStr);
      Result := 0;  //to avoid issues with non existing tryparse we will convert from hexa directly.
      Offset := 0;
      for i := EndStr - 1 downto EndStr - Len do
      begin
        if (Format[i]) >=#255 then exit; //cannot parse
        digit := UpCase(char(Format[i]));
        if (digit >= '0') and (digit <= '9') then
        begin
          Result:= Result + ((integer(digit) - integer('0')) shl Offset);
          Offset:= Offset + 4;
          continue;
        end;

        if (digit >= 'A') and (digit <= 'F') then
        begin
          Result:= Result + (((10 + integer(digit)) - integer('A')) shl Offset);
          Offset:= Offset + 4;
          continue;
        end;

        exit;  //Cannot parse.
      end;

      if Result < 0 then
        exit;

      try
        GetLocaleFormatSettings(Result, RegionalSet);
        RegionalCulture := @RegionalSet;
      except
      begin
         //We could not create the culture, so we will continue with the existing one.
       end;
      end;
    end;

  end;

end;

function GetResultCondition(const aSupressNeg: Boolean; const aSupressNegComp: Boolean; const aComplement: Boolean; const aAssigned: Boolean): TResultCondition;
begin
  Result.SupressNeg := aSupressNeg;
  Result.SupressNegComp := aSupressNegComp;
  Result.Complement := aComplement;
  Result.Assigned := aAssigned;
end;

function FindFrom(const wc: WideChar; const w: WideString; const p: integer): integer;
begin
  Result:=pos(wc, copy(w, p, Length(w)))
end;

function GetconditionNumber(const Format: WideString; const p: integer; out HasErrors: Boolean): Extended;
var
  p2: integer;
  number: WideString;
begin
  HasErrors := true;
  p2 := FindFrom(']', Format, p + 1) - 1;
  if p2 < 0 then
    begin Result := 0; exit; end;

  number := copy(Format, p + 1, p2);
  Result := 0;
  HasErrors := not TryStrToFloatInvariant(number, Result);
end;

function EvalCondition(const Format: WideString; const position: integer; const V: Double; out ResultValue: Boolean; out SupressNegativeSign: Boolean; out SupressNegativeSignComp: Boolean): Boolean;
var
  HasErrors: Boolean;
  c: Double;
begin
  SupressNegativeSign := false;
  SupressNegativeSignComp := false;
  ResultValue := false;
  if (position + 2) >= Length(Format) then  //We need at least a sign and a bracket.
    begin Result := false; exit; end;

  case Format[1 + position] of
  '=':
    begin
      begin
        c := GetconditionNumber(Format, position + 1, HasErrors);
        if HasErrors then
          begin Result := false; exit; end;

        ResultValue := V = c;
        SupressNegativeSign := true;
        SupressNegativeSignComp := false;
        begin Result := true; exit; end;
      end;
    end;
  '<':
    begin
      begin
        if Format[1 + position + 1] = '=' then
        begin
          c := GetconditionNumber(Format, position + 2, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V <= c;
          if c <= 0 then
            SupressNegativeSign := true else
            SupressNegativeSign := false;

          SupressNegativeSignComp := true;
          begin Result := true; exit; end;
        end;

        if Format[1 + position + 1] = '>' then
        begin
          c := GetconditionNumber(Format, position + 2, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V <> c;
          SupressNegativeSign := false;
          SupressNegativeSignComp := true;
          begin Result := true; exit; end;
        end;

        begin
          c := GetconditionNumber(Format, position + 1, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V < c;
          if c <= 0 then
            SupressNegativeSign := true else
            SupressNegativeSign := false;

          SupressNegativeSignComp := true;
          begin Result := true; exit; end;
        end;
      end;
    end;
  '>':
    begin
      begin
        if Format[1 + position + 1] = '=' then
        begin
          c := GetconditionNumber(Format, position + 2, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V >= c;
          if c <= 0 then
            SupressNegativeSignComp := true else
            SupressNegativeSignComp := false;

          SupressNegativeSign := false;
          begin Result := true; exit; end;
        end;

        begin
          c := GetconditionNumber(Format, position + 1, HasErrors);
          if HasErrors then
            begin Result := false; exit; end;

          ResultValue := V > c;
          if c <= 0 then
            SupressNegativeSignComp := true else
            SupressNegativeSignComp := false;

          SupressNegativeSign := false;
          begin Result := true; exit; end;
        end;
      end;
    end;
  end;
  Result := false;
end;

function GetNegativeSign(const Conditions: TResultConditionArray; const SectionCount: integer; var TargetedSection: integer; const V: Double): Boolean;
var
  NullCount: integer;
  CompCount: integer;
  Comp: TResultCondition;
  i: integer;
begin
  if TargetedSection < 0 then
  begin
    if (not Conditions[0].Assigned) and (((V > 0) or (SectionCount <= 1)) or ((V = 0) and (SectionCount <= 2))) then
    begin
      TargetedSection := 0;
      begin Result := false; exit; end;  //doesn't matter.
    end;

    if (not Conditions[1].Assigned) and ((V < 0) or (SectionCount <= 2)) then
    begin
      TargetedSection := 1;
      if (SectionCount = 2) and (Conditions[0].Assigned) then
        begin Result := Conditions[0].SupressNegComp; exit; end;

      begin Result := true; exit; end;
    end;

    if (not Conditions[2].Assigned) then
      TargetedSection := 2 else
      TargetedSection := 3;

    begin Result := false; exit; end;
  end;

  if Conditions[TargetedSection].Assigned then
  begin
    Result := Conditions[TargetedSection].SupressNeg; exit;
  end;

  NullCount := 0;  //Find Complement, if any
  CompCount := 0;
  Comp := GetResultCondition(false, false, false, false);
  for i := 0 to SectionCount - 1 do
  begin
    if Conditions[i].Assigned then
    begin
      Assert(Conditions[i].Complement);
      Inc(CompCount);
      if CompCount > 1 then
        begin Result := false; exit; end;

      Comp := Conditions[i];
    end
    else
    begin
      Inc(NullCount);
      if NullCount > 1 then
        begin Result := false; exit; end;

    end;

  end;

  if Comp.Assigned then
    begin Result := Comp.SupressNegComp; exit; end;

  Result := false;
end;


function GetSections(const Format: WideString; const V: Double; out TargetedSection: integer; out SectionCount: integer; out SupressNegativeSign: Boolean): WideStringArray;
var
  InQuote: Boolean;
  Conditions: TResultConditionArray;
  CurrentSection: integer;
  StartSection: integer;
  i: integer;
  TargetsThis: Boolean;
  SupressNegs: Boolean;
  SupressNegsComp: Boolean;
  FormatLength: Integer;
begin
  InQuote := false;
  SetLength (Result, 4);
  for i:= 0 to Length(Result) - 1 do Result[i] := '';
  SetLength (Conditions, 4);
  for i:= 0 to Length(Conditions) - 1 do Conditions[i] := GetResultCondition(false, false, false, false);
  CurrentSection := 0;
  StartSection := 0;
  TargetedSection := -1;
  i := 0;

  FormatLength := Length(Format);
  while i < FormatLength do
  begin
      if Format[1 + i] = '"' then
      begin
        InQuote := not InQuote;
      end;

      if InQuote then
      begin
        Inc(i);
        continue;  //escaped characters inside a quote like \" are not valid.
      end;

      if Format[1 + i] = '\' then
      begin
        i:= i + 2;
        continue;
      end;

      if Format[1 + i] = '[' then
      begin
        if (i + 2) < FormatLength then
        begin
          if EvalCondition(Format, i + 1, V, TargetsThis, SupressNegs, SupressNegsComp) then
          begin
            Conditions[CurrentSection] := GetResultCondition(SupressNegs, SupressNegsComp, not TargetsThis, true);
            if TargetedSection < 0 then
            begin
              if TargetsThis then
              begin
                TargetedSection := CurrentSection;
              end;

            end;

          end;

        end;

         //Quotes inside brackets are not quotes. So we need to process the full bracket.
        while (i < FormatLength) and (Format[1 + i] <> ']') do
        begin
          Inc(i)
        end;
        Inc(i);
        continue;
      end;

      if Format[1 + i] = ';' then
      begin
        if i > StartSection then
          Result[CurrentSection] := copy(Format, StartSection + 1, i - StartSection);

        Inc(CurrentSection);
        SectionCount := CurrentSection;
        if CurrentSection >= Length(Result) then
        begin
          SupressNegativeSign := GetNegativeSign(Conditions, SectionCount, TargetedSection, V);
          exit;
        end;

        StartSection := i + 1;
      end;

      Inc(i);
  end;

  if i > StartSection then
    Result[CurrentSection] := copy(Format, StartSection + 1, i - StartSection + 1);

  Inc(CurrentSection);
  SectionCount := CurrentSection;
  SupressNegativeSign := GetNegativeSign(Conditions, SectionCount, TargetedSection, V);
end;

function GetSection(const Format: WideString; const V: Double; out SectionMatches: Boolean; out SupressNegativeSign: Boolean): WideString;
var
  TargetedSection: integer;
  SectionCount: integer;
  Sections: WideStringArray;
begin
  SectionMatches := true;
  Sections := GetSections(Format, V, TargetedSection, SectionCount, SupressNegativeSign);
  if TargetedSection >= SectionCount then
  begin
    SectionMatches := false;  //No section matches condition. This has changed in Excel 2007, older versions would show an empty cell here, and Excel 2007 displays "####". We will use Excel2007 formatting.
    begin Result := ''; exit; end;
  end;

  if Sections[TargetedSection] = null then
    Result := '' else
    Result := Sections[TargetedSection];

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
var
  FormatLength: integer;
begin
  FormatLength := Length(Format);
  if p>FormatLength then exit;
  if (ord(Format[p])<255) and (char(Format[p]) in[' ','$','(',')','!','^','&','''','´','~','{','}','=','<','>']) then
    begin
      TextOut:=TextOut+Format[p];
      inc(p);
      exit;
    end;

  if (Format[p]='\') or (Format[p]='*')then
    begin
      if p<FormatLength then TextOut:=TextOut+Format[p+1];
      inc(p,2);
      exit;
    end;

  if Format[p]='_' then
    begin
      if p<FormatLength then TextOut:=TextOut+' ';
      inc(p,2);
      exit;
    end;

  if Format[p]='"' then
  begin
    inc(p);
    while (p<=FormatLength) and (Format[p]<>'"') do
    begin
      TextOut:=TextOut+Format[p];
      inc(p);
    end;
    if p<=FormatLength then inc(p);
  end;
end;

procedure CheckDate(var RegionalCulture: PFormatSettings; const V: Variant; const Format: widestring; const Dates1904: boolean; var p: integer;
var TextOut: widestring; var LastHour: boolean;var HasDate, HasTime: boolean);
const
  DateTimeChars=['C','D','W','M','Q','Y','H','N','S','T','A','P','/',':','.','\'];
  DChars=['C','D','Y'];
  TChars=['H','N','S'];
var
  Fmt: string;
  FormatLength: integer;
begin
  FormatLength := Length(Format);
  Fmt:='';
  while (p<=FormatLength) and (ord(Format[p])<255) and (Upcase(char(Format[p])) in DateTimeChars) do
  begin
    if (Format[p] = '\') then inc(p);
    if p > FormatLength then exit;

    if (p > 2) and (Format[p] = '/') and (p + 2 <= FormatLength)
    and ((Format[p-1] = 'M') or (Format[p-1] = 'm'))
    and ((Format[p-2] = 'A') or (Format[p-2] = 'a'))
    and ((Format[p+1] = 'P')  or (Format[p+1] = 'p'))
    and ((Format[p+2] = 'M')  or (Format[p+2] = 'm')) then
    begin             //AM/PM, must be changed to AMPM
      HasTime := true;
      Fmt:=Fmt + 'PM';
      inc (p, 3);
      continue;
    end;


    if (UpCase(Char(Format[p])) in DChars)or
       (not LastHour and (UpCase(Char(Format[p]))='M')) then HasDate:=true;
    if (UpCase(Char(Format[p])) in TChars)or
       (LastHour and (UpCase(Char(Format[p]))='M')) then HasTime:=true;

    if (UpCase(Char(Format[p]))='H') then LastHour:=true;
    if LastHour and (UpCase(Char(Format[p]))='M') then
    begin
      while (p<=FormatLength) and (UpCase(Char(Format[p]))='M') do
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

  EnsureAMPM(RegionalCulture);

  if Fmt<>'' then TextOut:=TextOut+TryFormatDateTime1904(Fmt,v, Dates1904, RegionalCulture^);
end;

procedure CheckNumber( V: Variant; const NegateValue: Boolean; const wFormat: widestring; var p: integer; var TextOut: widestring);
const
  NumberChars=['0','#','.',',','e','E','+','-','%','\'];
var
  Fmt: string;
  Format : string;
  FormatLength: integer;
begin
  Format := wFormat;
  FormatLength := Length(Format);
  Fmt:='';
  while (p<=FormatLength) and (ord(wFormat[p])<255) and (Format[p] in NumberChars) do
  begin
    if Format[p]='%' then V:=V*100;
    if (Format[p] = '\') then inc(p);
    if (p <= FormatLength) then
    begin
      Fmt:=Fmt+Format[p];
      inc(p);
    end;
  end;

  if (NegateValue) and (v < 0) then v := -v;
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


function FormatNumber(const V: Variant; const NegateValue: Boolean; const Format: WideString; const Dates1904: boolean; var Color: integer;var HasDate, HasTime: boolean): WideString;
var
  p, p1: integer;
  LastHour: boolean;
  FormatLength: integer;
  RegionalCulture: PFormatSettings;
begin
  FormatLength := Length(Format);

  RegionalCulture := GetDefaultLocaleFormatSettings;
  CheckColor(Format, Color, p);
  Result:='';  LastHour:=false;
  while p<=FormatLength do
  begin
    p1:=p;
    CheckRegionalSettings(Format, RegionalCulture, p, Result, false);
    CheckOptional(V, Format, p, Result);
    CheckLiteral (V, Format, p, Result);
    CheckDate    (RegionalCulture, V, Format, Dates1904, p, Result, LastHour, HasDate, HasTime);
    CheckNumber  (V, NegateValue, Format, p, Result);
    if p1=p then //not found
    begin
      if (NegateValue and V < 0) then Result := -V  //Format number is always called with a numeric arg
      else Result:=V;
      exit;
    end;
  end;
end;

function FormatText(const V:Variant; Format: WideString; var Color: integer):Widestring;
var
  SectionCount: integer;
  ts: integer;
  SupressNegativeSign: Boolean;
  Sections: WideStringArray;
  p: integer;
  p1: integer;
  FormatLength: integer;
  NewColor: integer;
begin
  FormatLength := Length(Format);

   //Numbers/dates and text formats can't be on the same format string. It is a number XOR a date XOR a text
  Sections := GetSections(Format, 0, ts, SectionCount, SupressNegativeSign);
  if SectionCount < 4 then
  begin
    Format := Sections[0];
    if (Pos('@', Format) <= 0) then  //everything is ignored here.
      begin
        NewColor:=Color;
        CheckColor(Format, NewColor, p);
        if (p > Length(Format)) or (UpperCase(copy(Format, p, length(Format))) = 'GENERAL')
            then Color := NewColor; //Excel only uses the color if the format is empty or has an "@".
        Result := v;
        exit;
      end;
  end
  else
  begin
    Format := Sections[3];
  end;

  CheckColor(Format, Color, p);
  Result:='';
  while p<=FormatLength do
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

function XlsFormatValueEx(const V: variant; Format: Widestring; const Dates1904: boolean; var Color: Integer;var HasDate, HasTime: boolean): Widestring;
var
  SectionMatches: Boolean;
  SupressNegativeSign: Boolean;
  FormatSection: WideString;
begin
  HasDate:=false;
  HasTime:=false;
  if Format='' then  //General
  begin
    Result:=v;
    exit;
  end;

  //This is slow. We will do it in checkdate.
  //Format:=StringReplaceSkipQuotes(Format,'AM/PM','AMPM'); //Format AMPM is equivalent to AM/PM on delphi

  case VarType(V) of
    varByte,
    varSmallint,
    varInteger,
    varSingle,
    varDouble,
   {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} varInt64,{$IFEND}{$ENDIF} //Delphi 6 or above
    varCurrency : begin
                    FormatSection := GetSection(Format, V, SectionMatches, SupressNegativeSign);
                    if not SectionMatches then  //This is Excel2007 way. Older version would show an empty cell.
                    begin Result := '###################'; exit; end;

                    if Pos('[$-F800]', UpperCase(FormatSection)) > 0 then  //This means format with long date from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime1904(LongDateFormat, V, Dates1904);
                      HasDate := true;
                      exit;
                    end;
                    if Pos('[$-F400]', UpperCase(FormatSection)) > 0 then  //This means format with long hour from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime1904(LongTimeFormat, V, Dates1904);
                      HasTime := true;
                      exit;
                    end;

                    Result := FormatNumber(V, SupressNegativeSign, FormatSection, Dates1904, Color, HasDate, HasTime);
                  end;
    varDate     : begin
                    FormatSection := GetSection(Format, V, SectionMatches, SupressNegativeSign);
                    if not SectionMatches then  //This is Excel2007 way. Older version would show an empty cell.
                    begin Result := '###################'; exit; end;

                    if Pos('[$-F800]', UpperCase(FormatSection)) > 0 then  //This means format with long date from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime1904(LongDateFormat, V, Dates1904);
                      HasDate := true;
                      exit;
                    end;
                    if Pos('[$-F400]', UpperCase(FormatSection)) > 0 then  //This means format with long hour from regional settings. This is new on Excel 2002
                    begin
                      Result := TryFormatDateTime1904(LongTimeFormat, V, Dates1904);
                      HasTime := true;
                      exit;
                    end;

                    if V<0 then Result:='###################' else //Negative dates are shown this way
                    Result := FormatNumber(V, SupressNegativeSign, FormatSection, Dates1904, Color, HasDate, HasTime);
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
  Result:=XlsFormatValueEx(V, Format, false, Color, HasDate, HasTime);
end;

function XlsFormatValue1904(const V: variant; const Format: Widestring; const Dates1904: boolean; var Color: Integer): Widestring;
var
  HasDate, HasTime: boolean;
begin
  Result:=XlsFormatValueEx(V, Format, Dates1904, Color, HasDate, HasTime);
end;

function HasXlsDateTime(const Format: Widestring; var HasDate, HasTime: boolean): boolean;
var
  Color: integer;
begin
  XlsFormatValueEx(10, Format, false, Color, HasDate, HasTime);
  Result:=HasDate or HasTime;
end;

end.
