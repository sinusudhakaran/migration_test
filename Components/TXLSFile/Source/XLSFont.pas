unit XLSFont;

{-----------------------------------------------------------------
    SM Software, 2000-2004

    TXLSFile v.4.0

    Rev history:
    2004-07-26  Add: TVirtualFontTable class added
    2004-08-14  Add: Unicode font names support added
    2006-08-21  Add: GetTextSize added

-----------------------------------------------------------------}

interface
uses XLSBase, XLSFormat, Unicode, VDataTable, Windows;

type
  {TFontData}
  TFontData = packed record
    Bold: Boolean;
    Italic: Boolean;
    Underline: Boolean;
    StrikeOut: Boolean;
    UnderlineStyle: TXLFontUnderlineStyle;
    SSStyle: TXLFontSSStyle;
    ColorIndex: TXLColorIndex;
    Height: Word;
    Name: array[1..100] of WideChar;
  end;

  PFontData = ^TFontData;

  {TVirtualFontTable}
  TVirtualFontTable = class
  private
    FDataTable: TVirtualDataTable;
    FFontData: TFontData;
    FBuffer: AnsiString;
    function GetCount: Integer;
    function GetFont(Index: Integer): PFontData;
  public
    constructor Create;
    destructor Destroy; override;
    function LoadFontToBuffer(const AIndex: Integer): PFontData;
    function ClearBuffer: PFontData;
    function SaveChangedBuffer: Integer;
    function SaveChangedBufferWithDuplicates: Integer;
    procedure Clear;
    property Count: Integer read GetCount;
    property Font[Index: Integer]: PFontData read GetFont;
  end;

procedure InitFontData(const APFontData: PFontData);

{ functions to create/parse font biff string }
function GetFontString(
    ABold: Boolean;
    AItalic: Boolean;
    AUnderline: Boolean;
    AStrikeOut: Boolean;
    AUnderlineStyle: TXLFontUnderlineStyle;
    ASSStyle: TXLFontSSStyle;
    AName: WideString;
    AColorIndex: TXLColorIndex;
    AHeight: Word
    ): AnsiString;

function GetFontStringFromFontData(const APFontData: PFontData): AnsiString;
function GetXLSXFontStringFromFontData(const APFontData: PFontData): AnsiString;
procedure GetFontDataFromFontString(const AFontString: AnsiString; var APFontData: PFontData);

{ functions to work with TFontData.Name property }
function GetFontDataNameAsString(const AFontData: PFontData): WideString;
procedure SetFontDataNameAsString(const AFontData: PFontData; AValue: WideString);

{ text size functions }
function GetTextSize(const AText: WideString;
                     const AFontIndex: Integer;
                     const AFontTable: TVirtualFontTable
                     ): TSize;

implementation
uses
    SysUtils
  , XLSStrUtil;

type
  PWord = ^Word;
  PByte = ^Byte;

const
  DefaultFontName: WideString = 'Arial';

procedure InitFontData(const APFontData: PFontData);
begin
  with APFontData^ do
  begin
    Bold:= False;
    Italic:= False;
    Underline:= False;
    StrikeOut:= False;
    UnderlineStyle:= xlFontUnderlineNone;
    SSStyle:= xlFontSSNone;
    FillChar(Name[1], SizeOf(Name), 0);
    Move(DefaultFontName[1], Name[1], Length(DefaultFontName) * 2);

    ColorIndex:= xlColorAuto;
    Height:= 10;
  end;
end;

function GetFontString(
    ABold: Boolean;
    AItalic: Boolean;
    AUnderline: Boolean;
    AStrikeOut: Boolean;
    AUnderlineStyle: TXLFontUnderlineStyle;
    ASSStyle: TXLFontSSStyle;
    AName: WideString;
    AColorIndex: TXLColorIndex;
    AHeight: Word
    ): AnsiString;
var
  Temp: Word;
  FUnderlineStyle: TXLFontUnderlineStyle;
begin
  SetLength(Result, 15);

  PWORD(@result[1])^:= AHeight * 20;
  Temp:= 0;
  if AItalic then Temp:= Temp or $02;
  if AStrikeOut then Temp:= Temp or $08;
  PWORD(@result[3])^:= Temp;

  PWORD(@result[5])^:= XLSColorIndexToFileColorIndex(AColorIndex);
  if ABold then Temp:= $2bc else Temp:= $190;
  PWORD(@result[7])^:= Temp;

  PWORD(@result[9])^:= Byte(ASSStyle);

  if AUnderline and (AUnderlineStyle = xlFontUnderlineNone) then
    FUnderlineStyle:= xlFontUnderlineSingle
  else
    FUnderlineStyle:= AUnderlineStyle;

  PByte(@result[11])^:= XLFontUnderlineStyles[FUnderlineStyle];
  { font family FF_DONTCARE }
  PByte(@result[12])^:= 0;
  { charset DEFAULT_CHARSET }
  PByte(@result[13])^:= 1;
  PByte(@result[14])^:= 0;

  PByte(@result[15])^:= Length(AName);
  SetLength(result, 16);
  PByte(@result[16])^:= 1;

  result:= result + WideStringToANSIWideString(AName);
end;

function GetFontStringFromFontData(const APFontData: PFontData): AnsiString;
begin
  Result:= GetFontString(
    APFontData^.Bold,
    APFontData^.Italic,
    APFontData^.Underline,
    APFontData^.StrikeOut,
    APFontData^.UnderlineStyle,
    APFontData^.SSStyle,
    WideString(PWideChar(@APFontData^.Name[1])),
    APFontData^.ColorIndex,
    APFontData^.Height);
end;


procedure GetFontDataFromFontString(const AFontString: AnsiString; var APFontData: PFontData);
var
  B: Byte;
  W: Word;
  FontNameLen: Byte;
begin
  InitFontData(APFontData);

  {height}
  W:= PWord(@AFontString[1])^;
  APFontData^.Height:= round(W / 20.0);

  {options}
  W:= PWord(@AFontString[3])^;
  APFontData^.Italic:= ((W and $02) > 0);
  APFontData^.StrikeOut:= ((W and $08) > 0);

  {color index}
  W:= PWord(@AFontString[5])^;
  APFontData^.ColorIndex:= FileColorIndexToXLSColorIndex(W);

  {bold}
  W:= PWord(@AFontString[7])^;
  APFontData^.Bold:= (W = $2bc);

  {SSStyle}
  W:= PWord(@AFontString[9])^;
  APFontData^.SSStyle:= TXLFontSSStyle(W);

  {underline}
  B:= PByte(@AFontString[11])^;
  APFontData^.UnderlineStyle:= TXLFontUnderlineStyle(B);
  APFontData.Underline:= (B > 0);

  {font name length}
  FontNameLen:= PByte(@AFontString[15])^;

  {font unicode flag}
  B:= PByte(@AFontString[16])^;

  {font name}
  FillChar(APFontData^.Name[1], SizeOf(APFontData^.Name), 0);
  if ((B and $01) = $01) then
    Move(AFontString[17], APFontData^.Name[1], FontNameLen * 2)
  else
    Move(AFontString[17], APFontData^.Name[1], FontNameLen);
end;

function GetXLSXFontStringFromFontData(const APFontData: PFontData): AnsiString;
var
  S: AnsiString;
  WS: WideString;
begin
  Result:= '<font>';

  {height}
  Result:= Result + '<sz val="' + AnsiString(IntToStr(APFontData^.Height)) + '" />';

  {options (bold, italic, underline)}
  if APFontData^.Bold then Result:= Result + '<b />';
  if APFontData^.Italic then Result:= Result + '<i />';
  if APFontData^.Underline then
  begin
    Result:= Result + '<u';
    case APFontData^.UnderlineStyle of
      xlFontUnderlineDouble    : Result:= Result + ' val="double"';
      xlFontUnderlineSingleAcc : Result:= Result + ' val="singleAccounting"';
      xlFontUnderlineDoubleAcc : Result:= Result + ' val="doubleAccounting"';
    end;
    Result:= Result + ' />';
  end;
  if APFontData^.StrikeOut then Result:= Result + '<strike />';

  {ss style}
  if (APFontData^.SSStyle = xlFontSSSuper) then Result:= Result + '<vertAlign val="superscript" />';
  if (APFontData^.SSStyle = xlFontSSSub) then Result:= Result + '<vertAlign val="subscript" />';

  {color}
  Result:= Result + '<color rgb="' + 'FF'
         + ColorRGBToRGBHexString(XLSColorIndexToColorRGB(APFontData^.ColorIndex)) + '" />';

  {name}
  WS:= GetFontDataNameAsString(APFontData);
  S:= XLSUTF8Encode(WS);
  Result:= Result + '<name val="' + S + '" />';

  Result:= Result + '</font>';
end;

{ functions to work with TFontData.Name property }
function GetFontDataNameAsString(const AFontData: PFontData): WideString;
begin
  Result:= WideString(PWideChar(@(AFontData^.Name[1])));
end;

procedure SetFontDataNameAsString(const AFontData: PFontData; AValue: WideString);
begin
  FillChar(AFontData^.Name[1], SizeOf(AFontData^.Name), 0);
  Move(AValue[1], AFontData^.Name[1], Length(AValue) * 2);
end;

{GetTextSize}
function GetTextSize(const AText: WideString;
                     const AFontIndex: Integer;
                     const AFontTable: TVirtualFontTable
                     ): TSize;
var
  LogFont: TLogFontW;
  APFontData: PFontData;
  SaveFont, NewFont: HFont;
  DC: HDC;
  ScreenLogPixels: Integer;
  FontName: WideString;
  ATextLength: Integer;
begin
  ATextLength:= Length(AText);
  if (ATextLength = 0) then
  begin
    Result.cx:= 0;
    Result.cy:= 0;
    Exit;
  end;

  APFontData:=  AFontTable.Font[AFontIndex];
  FontName:= GetFontDataNameAsString(APFontData);

  DC:= GetDC(0);
  try
    ScreenLogPixels := GetDeviceCaps(DC, LOGPIXELSY);
    SetGraphicsMode( DC, GM_ADVANCED );

    { Init LogFont }
    LogFont.lfHeight := -round((APFontData^.Height * ScreenLogPixels ) / 72);
    LogFont.lfWidth := 0;
    LogFont.lfEscapement := 0;
    LogFont.lfOrientation := 0;
    if APFontData^.Bold then LogFont.lfWeight := FW_BOLD else LogFont.lfWeight := FW_NORMAL;
    if APFontData^.Italic then LogFont.lfItalic := 1 else LogFont.lfItalic := 0;
    if APFontData^.Underline then LogFont.lfUnderline:= 1 else LogFont.lfUnderline:= 0;
    if APFontData^.StrikeOut then LogFont.lfStrikeOut:= 1 else LogFont.lfStrikeOut:= 0;
    LogFont.lfCharSet:= DEFAULT_CHARSET;

    FillChar(LogFont.lfFaceName[0], Length(LogFont.lfFaceName) * 2, 0);
    Move(FontName[1], LogFont.lfFaceName[0], Length(FontName) * 2);
    LogFont.lfQuality := DEFAULT_QUALITY;

    if LogFont.lfOrientation <> 0 then
      LogFont.lfOutPrecision := OUT_TT_ONLY_PRECIS
    else
      LogFont.lfOutPrecision := OUT_DEFAULT_PRECIS;

    LogFont.lfClipPrecision := CLIP_DEFAULT_PRECIS;
    LogFont.lfPitchAndFamily := DEFAULT_PITCH;

    { create font }
    NewFont:= CreateFontIndirectW(LogFont);

    { find text size }
    SaveFont := SelectObject(DC, NewFont);
    Windows.GetTextExtentPoint32W(DC, PWideChar(AText), Length(AText), Result);

    SelectObject(DC, SaveFont);
    DeleteObject(NewFont);    
  finally
    ReleaseDC(0, DC);
  end;
end;

{TVirtualFontTable}
constructor TVirtualFontTable.Create;
begin
  FDataTable:= TVirtualDataTable.Create;

  { Initialize font table with default font }
  FBuffer:= '';
  InitFontData(@FFontData);
  SaveChangedBuffer;
end;

destructor TVirtualFontTable.Destroy;
begin
  FDataTable.Destroy;
  inherited;
end;

procedure TVirtualFontTable.Clear;
begin
  FDataTable.Clear;
  ClearBuffer;
end;

function TVirtualFontTable.GetCount: Integer;
begin
  Result:= FDataTable.Count;
end;

function TVirtualFontTable.GetFont(Index: Integer): PFontData;
begin
  Result:= LoadFontToBuffer(Index);
end;

function TVirtualFontTable.LoadFontToBuffer(const AIndex: Integer): PFontData;
begin
  FBuffer:= FDataTable.Item[AIndex];
  Move(FBuffer[1], FFontData, SizeOf(TFontData));
  Result:= @FFontData;
end;

function TVirtualFontTable.SaveChangedBuffer: Integer;
var
  NewBuffer: AnsiString;
begin
  SetLength(NewBuffer, SizeOf(TFontData));
  Move(FFontData, NewBuffer[1], SizeOf(TFontData));
  Result:= FDataTable.ChangeItem(FBuffer, NewBuffer);
end;

function TVirtualFontTable.SaveChangedBufferWithDuplicates: Integer;
var
  NewBuffer: AnsiString;
begin
  SetLength(NewBuffer, SizeOf(TFontData));
  Move(FFontData, NewBuffer[1], SizeOf(TFontData));
  Result:= FDataTable.AddItemWithDuplicates(NewBuffer);
end;

function TVirtualFontTable.ClearBuffer: PFontData;
begin
  FBuffer:= '';
  InitFontData(@FFontData);
  Result:= @FFontData;
end;

end.
