unit XLSFormatStr;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    Rev history:
    2004-04-09  FormatByIfmt property added
    2004-12-12  More built-in formats added    
    2004-12-13  Add functions now return an index of an added item
    2008-03-24  Format is WideString
    2008-06-11  FormatValueAsString, GetLocalizedBuiltInFormat added
    2008-12-06  IfmtIsUserDefined added

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, XLSBase, XLSStrUtil, SysUtils;

type
  TNumberFormat = packed record
    ifmt: Word;
    FormatString: WideString;
  end;
  PNumberFormat = ^TNumberFormat;

  TFormatStrings = class
  protected
    FMaxIfmt: Word;
    FFormats: TList;
    function GetFormat(I: Integer): TNumberFormat;
    function GetFormatsCount: Integer;
    function GetFormatByIfmt(Ifmt: Word): WideString;
    function GetIndexByIfmt(Ifmt: Word): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    function AddFormat(const AFmt: WideString): Integer;
    function AddFormatAndIfmt(const AFmt: WideString; const AIfmt: Word): Integer;
    property Formats[Ind: Integer]: TNumberFormat read GetFormat; default;
    property FormatByIfmt[Ifmt: Word]: WideString read GetFormatByIfmt;
    property IndexByIfmt[Ifmt: Word]: Integer read GetIndexByIfmt;
    property FormatsCount: Integer read GetFormatsCount;
  end;

const
  xlBuiltinFormatsCount = 36;

  xlBuiltinFormats: array [0..xlBuiltinFormatsCount-1] of byte =
    ($00, $01, $02, $03, $05, $06, $07, $08, $09, $0a,
     $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $14,
     $15, $16, $2a, $29, $2c, $2b,
     $04, $25, $26, $27, $28, $2d, $2e, $2f, $30, $31);

  xlBuiltinFormatsStr: array[0..xlBuiltinFormatsCount-1] of AnsiString = (
    {00}  'General',
    {01}  '0',
    {02}  '0.00',
    {03}  '#,##0',
    {04}  '($#,##0_);($#,##0)',
    {05}  '($#,##0_);[Red]($#,##0)',
    {06}  '($#,##0.00_);($#,##0.00)',
    {07}  '($#,##0.00_);[Red]($#,##0.00)',
    {08}  '0%',
    {09}  '0.00%',
    {10}  '0.00E+00',
    {11}  '# ?/?'   ,
    {12}  '# ??/??' ,
    {13}  'mm/dd/yy'  ,
    {14}  'dd-mmm-yy',
    {15}  'dd-mmm'   ,
    {16}  'mmm-yy'  ,
    {17}  'h:mm AM/PM',
    {18}  'h:mm:ss AM/PM',
    {19}  'h:mm'   ,
    {20}  'h:mm:ss',
    {21}  'mm/dd/yy h:mm',
    {22}  '_($* #,##0_);_($* (#,##0);_($* "-"_);_(@_)',
    {23}  '_(* #,##0_);_(* (#,##0);_(* "-"_);_(@_)',
    {24}  '_($* #,##0.00_);_($* (#,##0.00);_($* "-"??_);_(@_)',
    {25}  '_(* #,##0.00_);_(* (#,##0.00);_(* "-"??_);_(@_)',
    {26}  '#,##0.00',
    {27}  '(#,##0_);(#,##0)',
    {28}  '(#,##0_);[Red](#,##0)',
    {29}  '(#,##0.00_);(#,##0.00)',
    {30}  '(#,##0.00_);[Red](#,##0.00)',
    {31}  'mm:ss',
    {32}  '[h]:mm:ss',
    {33}  'mm:ss.0',
    {34}  '##0.0E+0',
    {35}  '@'
    );

function BuiltinFormatIfmtToIndex(const Ifmt: Word): Integer;
function BuiltinFormatIfmtToBaseType(const Ifmt: Word): AnsiString;
function FormatToBaseType(const WS: WideString): AnsiString;
  function XLSFormatStrToFormatStr(const WS: WideString): WideString;
function FormatValueAsString(const AValue: Variant; const Ifmt: Word;
  const AFormat: WideString): WideString;
function GetLocalizedBuiltInFormat(const Ifmt: Word): WideString;
function IfmtIsUserDefined(const Ifmt: Word): Boolean;

implementation

uses Unicode
{$IFDEF XLF_D6}
   , Variants
{$ENDIF}
   ;

function BuiltinFormatIfmtToIndex(const Ifmt: Word): Integer;
var
  I: Integer;
begin
  Result:= -1;
  for I:= 0 to xlBuiltinFormatsCount - 1 do
    if Word(xlBuiltinFormats[I]) = Ifmt then
    begin
      result:= I;
      Break;
    end;
end;

function BuiltinFormatIfmtToBaseType(const Ifmt: Word): AnsiString;
{ returns base type name:
  general - if ifmt is General
  double - if ifmt defines double-number format
  date - if ifmt defines date format
}
begin
  case Ifmt of
    $0  : Result:= 'general';

    $01,
    $02,
    $03,
    $04,
    $05,
    $06,
    $07,
    $08,
    $09,
    $0a,
    $0b,
    $0c,
    $0d,
    $25,
    $26,
    $27,
    $28,
    $29,
    $2a,
    $2b,
    $2c,
    $30  : Result:= 'double';

    $0e,
    $0f,
    $10,
    $11,
    $12,
    $13,
    $14,
    $15,
    $16,
    $2d,
    $2e,
    $2f  : Result:= 'date';

    $31  : Result:= 'text';

    else  Result:= '';
  end;
end;

function IfmtIsUserDefined(const Ifmt: Word): Boolean;
begin
  Result:= (Ifmt >= $a4);
end;

function FormatToBaseType(const WS: WideString): AnsiString;
var
  LWS: WideString;
  I: Integer;
begin
  LWS:= WS;

  { remove locale number in [] braces }  
  I:= Pos(WideString('[$'), LWS);
  if I = 1 then
  begin
    I:= Pos(']', LWS);
    if I > 0 then
      LWS:= Copy(LWS, I + 1, Length(LWS) - I);
  end;

  { find base type }
  if (LWS = '') then Result:= 'general'
  else if WideStringLowerCase(LWS) = 'general' then Result:= 'general'
  else if LWS = '@' then Result:= 'text'
  else if WideStringLowerCase(LWS) = 'mm:ss.0' then Result:= 'date'
  else
    if ((pos('#', LWS) > 0) or (pos('0', LWS) > 0)) then
      if ((pos(',', LWS) > 0) or (pos('.', LWS) > 0)) then
        Result:= 'double'
      else
        Result:= 'integer'
    else
      Result:= 'date';
end;

function XLSFormatStrToFormatStr(const WS: WideString): WideString;
var
  I: Integer;
begin
  Result:= WS;

  { remove locale number in [] braces }  
  I:= Pos(WideString('[$'), Result);
  if I = 1 then
  begin
    I:= Pos(']', Result);
    if I > 0 then
      Result:= Copy(Result, I + 1, Length(Result) - I);
  end;

  { remove chars after ;}
  I:= pos(';', Result);
  if I > 0 then
    Result:= Copy(Result, 1, I - 1)
  else
    Result:= Result;

  { general type }  
  if WideStringLowerCase(Result) = 'general' then Result:= '';

  { replace some chars for Delphi formatting procedures }
  { minutes -> nn }
  Result:= WideStringReplace(Result, 'h:mm', 'h:nn');
  { long month name }
  Result:= WideStringReplace(Result, 'mmmmm', 'mmmm');

  { remove currently non-used chars }
  Result:= WideStringReplace(Result, '_-', ' ');
  Result:= WideStringReplace(Result, '_', ' ');
  Result:= WideStringReplace(Result, '(', '');
  Result:= WideStringReplace(Result, ')', '');
  Result:= WideStringReplace(Result, '\', '');
  Result:= WideStringReplace(Result, '-*', '');
  Result:= WideStringReplace(Result, '*', '');
end;

function FormatValueAsString(const AValue: Variant; const Ifmt: Word;
  const AFormat: WideString): WideString;
var
  I, ValueType: Integer;
  Format: WideString;
  Value: Variant;
  BaseType: AnsiString;

  function GetFraction(const AValue: Double; const FractionMask: AnsiString): AnsiString;
  var
    Nom, Denom: Integer;
    F: Double;
    I: Integer;
    MaxDenom, ADenom: Integer;
    Delta, MinDelta: Double;
  begin
    Result:= '';

    F:= Frac(AValue);
    if (F = 0) then Exit;

    { if mask contains explicit denominator }
    if Pos(AnsiString('?'), FractionMask) = 0 then
    begin
      Denom:= StrToInt(String(FractionMask));
    end
    else
    begin
      Denom:= 2;

      { Use brute force algorithm for finding nominator and denominator.
        Using such exotic formats will imply overheads. }
      if      (FractionMask = '?')   then MaxDenom:= 9
      else if (FractionMask = '??')  then MaxDenom:= 99
      else if (FractionMask = '???') then MaxDenom:= 999
      else MaxDenom:= 9;

      MinDelta:= 2 * F;
      for I:= MaxDenom downto 1 do
      begin
        ADenom:= I;
        Delta:= Abs(F - 1.0 * Round(F * ADenom) / ADenom);
        if (Delta <= MinDelta) then
        begin
          Denom:= ADenom;
          MinDelta:= Delta;
        end;
      end;
    end;

    Nom:= Round(F * Denom);

    if (Nom = 0) then
      Result:= ''
    else
      Result:= AnsiString(IntToStr(Nom)) + '/' + AnsiString(IntToStr(Denom));
  end;
  
  function FormatDateAsString(const AValue: TDateTime): WideString;
  var
    y, m, d: Word;
    h, min, s, ms: Word;
    I: Integer;
    {$IFDEF XLF_D3}
    DaysSinceFirstDate: Comp;    
    {$ELSE}
    DaysSinceFirstDate: Int64;
    {$ENDIF}
  begin
    { Prepare format for FormatDateTime function }

    { remove chars after ;}
    I:= pos(';', Format);
    if I > 0 then
      Format:= Copy(Format, 1, I - 1);

    { remove currently non-used chars }
    Format:= WideStringReplace(Format, '_-', ' ');
    Format:= WideStringReplace(Format, '_', ' ');
    Format:= WideStringReplace(Format, '\', '');
    Format:= WideStringReplace(Format, '-*', '');
    Format:= WideStringReplace(Format, '*', '');

    { minutes -> nn }
    Format:= WideStringReplace(Format, ':mm', ':nn');
    { .0 -> zzz}
    Format:= WideStringReplace(Format, '.0', '.z');

    { Special cases }
    DecodeDate(AValue, y, m, d);
    DecodeTime(AValue, h, min, s, ms);
    DaysSinceFirstDate:= Trunc(AValue);

    { mmmmm -> first char of month name }
    Format:= WideStringReplace(Format
             , 'mmmmm'
             , '"' + SysUtils.LongMonthNames[m][1] + '"');

    { [h] -> hours since 1900/1/1 }
    Format:= WideStringReplace(Format
             , '[h]'
    {$IFDEF XLF_D3}
             , '"' + FormatFloat('#', DaysSinceFirstDate * 24 + h) + '"');
    {$ELSE}
             , '"' + IntToStr(DaysSinceFirstDate * 24 + h) + '"');
    {$ENDIF}

    { [mm] -> minutes since 1900/1/1 }
    Format:= WideStringReplace(Format
             , '[mm]'
    {$IFDEF XLF_D3}
             , '"' + FormatFloat('#', DaysSinceFirstDate * 24 * 60 + h * 60 + min) + '"');
    {$ELSE}
             , '"' + IntToStr(DaysSinceFirstDate * 24 * 60 + h * 60 + min) + '"');
    {$ENDIF}

    { [ss] -> seconds since 1900/1/1 }
    Format:= WideStringReplace(Format
             , '[ss]'
    {$IFDEF XLF_D3}
             , '"' + FormatFloat('#', DaysSinceFirstDate * 24 * 60 * 60 + h * 60 * 60 + min * 60 + s) + '"');
    {$ELSE}
             , '"' + IntToStr(DaysSinceFirstDate * 24 * 60 * 60 + h * 60 * 60 + min * 60 + s) + '"');
    {$ENDIF}

    { Get result }
    Result:= FormatDateTime(Format, AValue);
  end;

  function FormatNumberAsString(const AValue: Double): WideString;
  var
    D: Double;
    I: Integer;
    FractionMask: AnsiString;
    BlindCurrency, Currency: AnsiString;
  begin
    D:= AValue;
    if (Format = '') then
    begin
      Result:= FloatToStr(D);
      Exit;
    end;

    { Is percent format ? }
    if (Copy(Format, Length(Format), 1) = '%') then
    begin
      Format:= WideStringReplace(Format, '%', '"%"');
      D:= D * 100;
    end;

    { Get proper format for positive or negative number }
    if (D >= 0) then
    begin
      I:= pos(';', Format);
      if I > 0 then
        Format:= Copy(Format, 1, I - 1);
    end
    else
    begin
      { negative }
      I:= pos(';', Format);
      if I > 0 then
      begin
        Format:= Copy(Format, I + 1, Length(Format) - I);
        I:= pos(';', Format);
        if I > 0 then
          Format:= Copy(Format, 1, I - 1);
      end;
      { if format contains braces () then don't show minus sign }
      if ( (Pos('(', Format) > 0) and (Pos(')', Format) > 0)) then
        D:= D * (-1);
    end;

    { remove blind currency symbols }
    Currency:= AnsiString(SysUtils.CurrencyString);
    BlindCurrency:= '';
    for I:= 1 to Length(Currency) do
      BlindCurrency:= BlindCurrency + '_' + Currency[I];
    Format:= WideStringReplace(Format, WideSTring(BlindCurrency), ' ');

    { remove currently non-used chars }
    Format:= WideStringReplace(Format, '_-', '');
    Format:= WideStringReplace(Format, '_(', '');
    Format:= WideStringReplace(Format, '_)', '');    
    Format:= WideStringReplace(Format, '_', '   '); // 3 spaces
    Format:= WideStringReplace(Format, '\', '');
    Format:= WideStringReplace(Format, '-*', '');
    Format:= WideStringReplace(Format, '*', '');
    Format:= WideStringReplace(Format, '( (', '(');

    { if format contains only one brace, them remove it }
    if ( (Pos('(', Format) > 0) and (Pos(')', Format) = 0)) then
      Format:= WideStringReplace(Format, '(', '');
    if ( (Pos('(', Format) = 0) and (Pos(')', Format) > 0)) then
      Format:= WideStringReplace(Format, ')', '');


    { remove colors }
    I:= Pos('[', Format);
    while (I = 1) do
    begin
      I:= Pos(']', Format);
      if I > 0 then
        Format:= Copy(Format, I + 1, Length(Format) - I);

      I:= Pos('[', Format);        
    end;

    { calculate fractional part }
    I:= Pos(WideString('?/'), Format);
    if (I > 0) then
    begin
      FractionMask:= Copy(AnsiString(Format), I + 2, Length(Format) - I);
      I:= Pos(AnsiSTring(' '), FractionMask + ' ');
      FractionMask:= Copy(FractionMask, 1,  I - 1);

      Format:= WideStringReplace(
                 Format
               , WideString('?/' + FractionMask)
               , WideString('"' + GetFraction(D, FractionMask) + '"'));
      Format:= WideStringReplace(Format, '?', '');
    end;

    { get result }
    Result:= FormatFloat(Format, D);
  end;

begin
  Result:= '';

  if   VarIsEmpty(AValue)
    or VarIsNull(AValue) then Exit;
  
  ValueType:= VarType(AValue);

  { If value is string or boolean, then return result }
  case ValueType of
    xfVarString:
      begin
        Result:= StringToWideString(AnsiString(AValue));
        Exit;
      end;
    xfVarOleStr,
    xfVarUString:
      begin
        Result:= WideString(AValue);
        Exit;
      end;
    xfVarBoolean:
      begin
        if (AValue = True) then Result:= 'TRUE' else Result:= 'FALSE';
        Exit;
      end;
  end;

  { Other types require more work }
  Format:= AFormat;
  Value:= AValue;

  { if format is not specified, get localized builtin format }
  if (Format = '') then
    Format:= GetLocalizedBuiltInFormat(Ifmt);

  { remove locale number in [] braces }
  I:= Pos(WideString('[$'), Format);
  if I = 1 then
  begin
    I:= Pos(']', Format);
    if I > 0 then
      Format:= Copy(Format, I + 1, Length(Format) - I);
  end;

  { Get base type from format }
  BaseType:= FormatToBaseType(Format);

  { Simple formats }
  if ((BaseType = 'general') or (BaseType = 'text')) then
    Format:= '';

  { If value is date, but format is not date, get default date format }
  if (ValueType = xfVarDate) and (BaseType <> 'date') then
  begin
    Format:= SysUtils.ShortDateFormat;
    BaseType:= 'date';
  end;

  { Process date format }
  if (BaseType = 'date') then
  begin
    Result:= FormatDateAsString(Value);
    Exit;
  end;

  { Process numeric format }
  Result:= FormatNumberAsString(Value);

end;

function GetLocalizedBuiltInFormat(const Ifmt: Word): WideString;

  function GetCurrencyFormat: WideString;
  var
    Precision: Byte;
    CurrencyFormat, NegCurrencyFormat: Byte;
    Currency: WideString;
    BaseFormat, PositiveFormat, NegativeFormat: WideString;
    NegFormatContainsBraces: Boolean;
  begin
    { Get precision }
    case Ifmt of
      $05, $06, $2a, $29: Precision:= 0;
      else Precision:= SysUtils.CurrencyDecimals;
    end;

    { Get local formats }
    CurrencyFormat:= SysUtils.CurrencyFormat;
    NegCurrencyFormat:= SysUtils.NegCurrFormat;
    Currency:= '"' + WideString(SysUtils.CurrencyString) + '"';
    NegFormatContainsBraces:= NegCurrencyFormat in [0, 4, 14, 15];

    { Get base format }
    BaseFormat:= '#,##0';
    if Precision >0 then
      BaseFormat:= BaseFormat + '.' + StringOfChar('0', Precision);

    { Get positive format }
    case CurrencyFormat of
      0: PositiveFormat:= Currency + BaseFormat + '_';
      1: PositiveFormat:= BaseFormat + Currency + '_';
      2: PositiveFormat:= Currency + ' ' + BaseFormat + '_';
      3: PositiveFormat:= BaseFormat + ' ' + Currency + '_';
    end;

    if    NegFormatContainsBraces
      and (Ifmt in [$2a, $29, $2b, $2c])
      then
      PositiveFormat:= '_(' + PositiveFormat + ')';

    { Get negative format }
    case NegCurrencyFormat of
      0: NegativeFormat:= '(' + Currency + BaseFormat + ')';
      1: NegativeFormat:= '-' + Currency + BaseFormat;
      2: NegativeFormat:= Currency + '-' + BaseFormat;
      3: NegativeFormat:= Currency + BaseFormat + '-';
      4: NegativeFormat:= '(' + BaseFormat + Currency + ')';
      5: NegativeFormat:= '-' + BaseFormat + Currency;
      6: NegativeFormat:= BaseFormat + '-' + Currency;
      7: NegativeFormat:= BaseFormat + Currency + '-';
      8: NegativeFormat:= '-' + BaseFormat + ' ' + Currency;
      9: NegativeFormat:= '-' + Currency + ' ' + BaseFormat;
     10: NegativeFormat:= BaseFormat + ' ' + Currency + '-';
     11: NegativeFormat:= Currency + ' ' + BaseFormat + '-';
     12: NegativeFormat:= Currency + ' -' + BaseFormat;
     13: NegativeFormat:= BaseFormat + '- ' + Currency;
     14: NegativeFormat:= '(' + Currency + ' ' + BaseFormat + ')';
     15: NegativeFormat:= '(' + BaseFormat + ' ' + Currency + ')';
    end;

    if NegFormatContainsBraces then
      NegativeFormat:= '(' + NegativeFormat + ')';

    Result:= PositiveFormat + ';' + NegativeFormat;  
  end;

  function GetAccountingFormat: WideString;
  var
    Precision: Byte;  
    BaseFormat: WideString;
    NegCurrencyFormat: Byte;
    NegFormatContainsBraces: Boolean;
  begin
    { Get precision }
    case Ifmt of
      $25, $26: Precision:= 0;
      else Precision:= SysUtils.CurrencyDecimals;
    end;

    { Get base format }
    BaseFormat:= '#,##0';
    if Precision >0 then
      BaseFormat:= BaseFormat + '.' + StringOfChar('0', Precision);

    { Find if braces required }
    NegCurrencyFormat:= SysUtils.NegCurrFormat;
    NegFormatContainsBraces:= NegCurrencyFormat in [0, 4, 14, 15];

    if NegFormatContainsBraces then
      Result:= '(' + BaseFormat + '_);(' + BaseFormat + ')'
    else
      Result:= BaseFormat + '_;' + BaseFormat;
  end;

var
  Index: Integer;  
begin
  Result:= '';
  
  case Ifmt of
     { common }
     $00,
     $01,
     $02,
     $03,
     $04,
     $09,
     $0a,
     $0b,
     $0c,
     $0d,
     $0f,
     $10,
     $11,
     $12,
     $13,
     $14,
     $15,
     $2d,
     $2e,
     $2f,
     $30,
     $31 :
       begin
         Index:= BuiltinFormatIfmtToIndex(Ifmt);
         if Index >=0 then
           Result:= WideString(xlBuiltinFormatsStr[Index]);

         { localize date separator these date formats }
         if Ifmt in [$0f, $10, $11] then
           Result:=  WideStringReplace(Result, '-', SysUtils.DateSeparator);
       end;

     { currency }
     $05, $06, $07, $08, $29, $2a, $2b, $2c:
       Result:= GetCurrencyFormat;

     { dates }      
     $0e :
       Result:= ShortDateFormat;
     $16 :
       Result:= ShortDateFormat + ' ' + ShortTimeFormat;

     { accounting }
     $25, $26, $27, $28 :
       Result:= GetAccountingFormat;
  end;
end;


{TFormatStrings}
constructor TFormatStrings.Create;
var
  I: Integer;
  P: PNumberFormat;
begin
  FFormats:= TList.Create;
  FMaxIfmt:= 0;
  
  for I:= 0 to xlBuiltinFormatsCount - 1 do
  begin
    New(P);
    P^.FormatString:= WideString(xlBuiltinFormatsStr[I]);
    P^.ifmt:= xlBuiltinFormats[I];
    FFormats.Add(P);

    if P^.ifmt > FMaxIfmt then FMaxIfmt:= P^.ifmt;
  end;
end;

destructor TFormatStrings.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FFormats.Count - 1 do
    Dispose(PNumberFormat(FFormats[I]));
  FFormats.Destroy;
  inherited;
end;

function TFormatStrings.GetFormat(I: Integer): TNumberFormat;
begin
  result:= PNumberFormat(FFormats[I])^;
end;

function TFormatStrings.GetFormatsCount: Integer;
begin
  result:= FFormats.Count;
end;

function TFormatStrings.AddFormat(const AFmt: WideString): Integer;
var
  P: PNumberFormat;
begin
  New(P);
  P^.FormatString:= AFmt;

  {find new ifmt}
  FMaxIfmt:= FMaxIfmt + 1;
  // $a4 is the starting ifmt for user's custom formats
  if FMaxIfmt < $a4 then FMaxIfmt:= $a4;
  P^.ifmt:= FMaxIfmt;
  
  FFormats.Add(P);
  Result:= FFormats.Count - 1;
end;

function TFormatStrings.AddFormatAndIfmt(const AFmt: WideString; const AIfmt: Word): Integer;
var
  P: PNumberFormat;
  Index: Integer;
begin
  {if ifmt is already exists - replace format string with new}
  Index:= GetIndexByIfmt(AIfmt);
  if (Index >=0) then
  begin
    PNumberFormat(FFormats[Index])^.FormatString:= AFmt;
    Result:= Index;
  end
  else
  begin
    New(P);
    P^.ifmt:= AIfmt;
    P^.FormatString:= AFmt;
    FFormats.Add(P);

    if AIfmt > FMaxIfmt then FMaxIfmt:= AIfmt;

    Result:= FFormats.Count - 1;    
 end;
end;

function TFormatStrings.GetFormatByIfmt(Ifmt: Word): WideString;
var
  I: Integer;
begin
  Result:= '';
  for I:= 0 to FFormats.Count - 1 do
    if PNumberFormat(FFormats[I])^.ifmt = Ifmt then
    begin
      Result:= PNumberFormat(FFormats[I])^.FormatString;
      Break;
    end;
end;

function TFormatStrings.GetIndexByIfmt(Ifmt: Word): Integer;
var
  I: Integer;
begin
  Result:= -1;
  for I:= 0 to FFormats.Count - 1 do
    if PNumberFormat(FFormats[I])^.ifmt = Ifmt then
    begin
      Result:= I;
      Break;
    end;
end;

end.
