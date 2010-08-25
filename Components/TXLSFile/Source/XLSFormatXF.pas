unit XLSFormatXF;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    Rev history:
    2004-10-22   TVirtualXFTable class 
    2004-12-26   Add: cell indent
    2007-01-20   Add: TVirtualXFTable.DefaultIndex
    2008-03-06   Add: Locked

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses XLSFormat, XLSBase, Unicode, VDataTable;

{$IFDEF XLF_D3}
type
  Longword = Cardinal;
{$ENDIF}

type
  {TXFData - XF record data}
  TXFData = packed record
    FontIndex: Word;
    FormatIndex: Word;
    HAlign: TCellHAlignment;
    VAlign: TCellVAlignment;
    Rotation: TCellRotation;
    Wrap: Boolean;
    FillPattern: TXLPattern;
    FgColor: TXLColorIndex;
    BgColor: TXLColorIndex;
    Merge: Boolean;
    Indent: Byte;
    {border colors}
    LeftBorderColor: TXLColorIndex;
    RightBorderColor: TXLColorIndex;
    TopBorderColor: TXLColorIndex;
    BottomBorderColor: TXLColorIndex;
    {border styles}
    LeftBorderStyle: TXLBorderStyle;
    RightBorderStyle: TXLBorderStyle;
    TopBorderStyle: TXLBorderStyle;
    BottomBorderStyle: TXLBorderStyle;
    {style XF}
    StyleXF: Boolean;
    Locked: Boolean;
  end;
  PXFData = ^TXFData;

  {TVirtualXFTable}
  TVirtualXFTable = class
  private
    FDataTable: TVirtualDataTable;
    FXFData: TXFData;
    FDefaultBuffer: AnsiString;    
    FBuffer: AnsiString;
    FDefaultIndex: Integer;
    function GetCount: Integer;
    function GetXF(Index: Integer): PXFData;
  public
    constructor Create;
    destructor Destroy; override;
    function LoadXFToBuffer(const AIndex: Integer): PXFData;
    function ClearBuffer: PXFData;
    function SaveChangedBuffer: Integer;
    function SaveChangedBufferWithDuplicates: Integer;
    procedure Clear;
    procedure UpdateDefaultIndex;
    property DefaultIndex: Integer read FDefaultIndex;
    property Count: Integer read GetCount;
    property XF[Index: Integer]: PXFData read GetXF;
  end;

function IsXFDataEmpty(const XFData: PXFData): Boolean;
procedure InitXFData(const APXFData: PXFData);
function GetXFStringFromXFData(const AXFData: PXFData): AnsiString;
procedure GetXFDataFromXFString(const AXFString: AnsiString; var APXFData: PXFData);
function GetXLSXFillStringFromXFData(const AXFData: PXFData): AnsiString;
function GetXLSXBorderStringFromXFData(const AXFData: PXFData): AnsiString;
function GetXLSXXFStringFromXFData(const AXFData: PXFData;
  const ABorderIndex: Integer;
  const AFillIndex: Integer;
  const AFormatIndex: Integer): AnsiString;
  
const
  DefaultStyleXFData: array[1..20] of Byte = ($00, $00, $00, $00, $F5, $FF, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $20 );
  DefaultCellXFData:  array[1..20] of Byte = ($00, $00, $00, $00, $01, $00, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $20 );

  DefaultExStyleXFData_1: array[1..20] of Byte = ($01, $00, $2C, $00, $F5, $FF, $20, $00, $00, $F8, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $20 );
  DefaultExStyleXFData_2: array[1..20] of Byte = ($01, $00, $2A, $00, $F5, $FF, $20, $00, $00, $F8, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $20 );
  DefaultExStyleXFData_3: array[1..20] of Byte = ($01, $00, $09, $00, $F5, $FF, $20, $00, $00, $F8, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $20 );
  DefaultExStyleXFData_4: array[1..20] of Byte = ($01, $00, $2B, $00, $F5, $FF, $20, $00, $00, $F8, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $20 );
  DefaultExStyleXFData_5: array[1..20] of Byte = ($01, $00, $29, $00, $F5, $FF, $20, $00, $00, $F8, $00, $00, $00, $00, $00, $00, $00, $00, $C0, $20 );

implementation

uses SysUtils;

type
  PWord = ^Word;
  PByte = ^Byte;
  PDWord = ^Longword;

function GetXFStringFromXFData(const AXFData: PXFData): AnsiString;
var
  HAlign, VAlign: Word;
  Locked, StyleXF: Word;
  BgColor, FgColor, Temp: Word;
  ParentComp: Word;
  ParentInd: Word;
  Wrap: Word;
  FillPattern: LongWord;
  Merge: Word;
  Rotation: Word;
  BordStyles: Word;
  BordColors: LongWord;
  Indent: Byte;
begin
  SetLength(Result, 20);
  FillChar(Result[1], 20, 0);

  PWORD(@Result[1])^:= AXFData^.FontIndex;
  PWORD(@Result[3])^:= AXFData^.FormatIndex;

  HAlign     := Word(AXFData^.HAlign);
  VAlign     := Word(AXFData^.VAlign);
  if AXFData^.Wrap then Wrap:= 1 else Wrap:= 0;
  FillPattern:= LongWord(AXFData^.FillPattern);
  FgColor    := AXFData^.FGColor;
  BgColor    := AXFData^.BGColor;
  if AXFData^.Locked then Locked := 1 else Locked:= 0;
  if AXFData^.StyleXF then StyleXF:= 1 else StyleXF:= 0;
  if StyleXF = 1 then ParentInd:= $0fff else ParentInd:= 0; // ParentXFInd;
  if AXFData^.Merge then Merge:= 1 else Merge:= 0;
  Rotation   := AXFData^.Rotation;
  Indent     := AXFData^.Indent;

  BordStyles:= 0;
  BordColors:= 0;
  if AXFData^.LeftBorderStyle <> bsNone then
  begin
    BordStyles:= BordStyles or Word(AXFData^.LeftBorderStyle);
    BordColors:= BordColors or XLSColorIndexToFileColorIndex(AXFData^.LeftBorderColor);
  end;
  if AXFData^.RightBorderStyle <> bsNone then
  begin
    BordStyles:= BordStyles or (Word(AXFData^.RightBorderStyle) shl 4);
    BordColors:= BordColors or (XLSColorIndexToFileColorIndex(AXFData^.RightBorderColor) shl 7);
  end;
  if AXFData^.TopBorderStyle <> bsNone then
  begin
    BordStyles:= BordStyles or (Word(AXFData^.TopBorderStyle) shl 8);
    BordColors:= BordColors or (XLSColorIndexToFileColorIndex(AXFData^.TopBorderColor) shl 16);
  end;
  if AXFData^.BottomBorderStyle <> bsNone then
  begin
    BordStyles:= BordStyles or (Word(AXFData^.BottomBorderStyle) shl 12);
    BordColors:= BordColors or (XLSColorIndexToFileColorIndex(AXFData^.BottomBorderColor) shl 23);
  end;

  PWORD(@Result[11])^:= BordStyles;
  PDWORD(@Result[13])^:= BordColors;

  PWORD(@result[5])^:= (ParentInd shl 4) or Locked or (StyleXF shl 2);
  PWORD(@result[7])^:= HAlign or (VAlign shl 4) or (Wrap shl 3) or (Rotation shl 8);
  PWORD(@result[9])^:= (Merge shl 5) or (Indent and $F);
  PDWORD(@result[15])^:= PDWORD(@result[15])^  or (FillPattern shl 26);
  if FillPattern = LongWord(xlPatternSolid) then
  begin
    Temp:= FgColor;
    FgColor:= BgColor;
    BgColor:= Temp;
  end;

  PWORD(@result[19])^:= XLSColorIndexToFileColorIndex(FgColor) or
                       (XLSColorIndexToFileColorIndex(BgColor) shl 7);

  ParentComp:= 1; 
  PWORD(@result[9])^:= PWORD(@result[9])^ or (ParentComp shl 10);

end;

procedure InitXFData(const APXFData: PXFData);
begin
  with APXFData^ do
  begin
    FontIndex:= 0;
    FormatIndex:= 0;
    HAlign:= xlHAlignGeneral;
    VAlign:= xlVAlignBottom;
    Rotation:= xlRotationNone;
    Wrap:= False;
    FillPattern:= xlPatternNone;
    FgColor:= xlColorAuto;
    BgColor:= xlColorNone;
    Merge:= False;
    Indent:= 0;
    Locked:= True;
    StyleXF:= False;

    {border colors}
    LeftBorderColor:= xlColorNone;
    RightBorderColor:= xlColorNone;
    TopBorderColor:= xlColorNone;
    BottomBorderColor:= xlColorNone;

    {border styles}
    LeftBorderStyle:= bsNone;
    RightBorderStyle:= bsNone;
    TopBorderStyle:= bsNone;
    BottomBorderStyle:= bsNone;
  end;
end;

function IsXFDataEmpty(const XFData: PXFData): Boolean;
begin
  Result:= (XFData^.FormatIndex = 0 )
       and (XFData^.Wrap = False)
       and (XFData^.FillPattern = xlPatternNone)
       and (XFData^.Merge = False )
       and (XFData^.Indent = 0)
       and (XFData^.Locked = True)
       and (XFData^.LeftBorderStyle = bsNone)
       and (XFData^.RightBorderStyle = bsNone)
       and (XFData^.TopBorderStyle = bsNone)
       and (XFData^.BottomBorderStyle = bsNone)
end;

procedure GetXFDataFromXFString(const AXFString: AnsiString; var APXFData: PXFData);
var
  W: Word;
  D: Longword;
begin
  W:= PWord(@AXFString[1])^;
  APXFData^.FontIndex:= W;
  W:= PWord(@AXFString[3])^;
  APXFData^.FormatIndex:= W;

  W:= PWord(@AXFString[5])^;
  if (W and $0001) = 0 then APXFData^.Locked:= False else APXFData^.Locked:= True;
  if (W and $0004) = 0 then APXFData^.StyleXF:= False else APXFData^.StyleXF:= True;

  W:= PWord(@AXFString[7])^;
  APXFData^.HAlign:= TCellHAlignment(W and $0007);
  if ((W and $0008) shr 3) = 0 then APXFData^.Wrap:= False else APXFData^.Wrap:= True;
  APXFData^.VAlign:= TCellVAlignment((W and $0070) shr 4);
  APXFData^.Rotation:= Byte((W and $FF00) shr 8);

  APXFData^.Merge:= False;

  W:= PWord(@AXFString[9])^;
  APXFData^.Indent:= Byte(W and $0F);

  {border styles}
  W:= PWord(@AXFString[11])^;
  APXFData^.LeftBorderStyle:= TXLBorderStyle(W and $000F);
  APXFData^.RightBorderStyle:= TXLBorderStyle((W and $00F0) shr 4);
  APXFData^.TopBorderStyle:= TXLBorderStyle((W and $0F00) shr 8);
  APXFData^.BottomBorderStyle:= TXLBorderStyle((W and $F000) shr 12);

  {border colors}
  W:= PWord(@AXFString[13])^;
  APXFData^.LeftBorderColor:= FileColorIndexToXLSColorIndex(W and $007F);
  APXFData^.RightBorderColor:= FileColorIndexToXLSColorIndex((W and $3F80) shr 7);

  D:= PDWord(@AXFString[15])^;
  APXFData^.TopBorderColor:= FileColorIndexToXLSColorIndex(D and $007F);
  APXFData^.BottomBorderColor:= FileColorIndexToXLSColorIndex((D and $3F80) shr 7);

  {fill pattern}
  APXFData^.FillPattern:= TXLPattern((D and $FC000000) shr 26);

  {fill pattern colors}
  W:= PWord(@AXFString[19])^;
  if APXFData^.FillPattern = xlPatternSolid then
  begin
    APXFData^.BgColor:= FileColorIndexToXLSColorIndex(W and $007F);
    APXFData^.FgColor:= FileColorIndexToXLSColorIndex((W and $3F80) shr 7);
  end
  else
  begin
    APXFData^.FgColor:= FileColorIndexToXLSColorIndex(W and $007F);
    APXFData^.BgColor:= FileColorIndexToXLSColorIndex((W and $3F80) shr 7);
  end;
end;

function GetXLSXFillStringFromXFData(const AXFData: PXFData): AnsiString;
  function FillPatternToString(const Pattern: TXLPattern): AnsiString;
  begin
    case AXFData^.FillPattern of
      xlPatternNone            : Result:= 'none';
      xlPatternSolid           : Result:= 'solid';
      xlPatternGray50          : Result:= 'mediumGray';
      xlPatternGray75          : Result:= 'darkGray';
      xlPatternGray25          : Result:= 'lightGray';
      xlPatternHorizontal      : Result:= 'darkHorizontal';
      xlPatternVertical        : Result:= 'darkVertical';
      xlPatternDown            : Result:= 'darkDown';
      xlPatternUp              : Result:= 'darkUp';
      xlPatternCrissCross      : Result:= 'darkGrid';
      xlPatternChecker         : Result:= 'darkTrellis';
      xlPatternLightHorizontal : Result:= 'lightHorizontal';
      xlPatternLightVertical   : Result:= 'lightVertical';
      xlPatternLightDown       : Result:= 'lightDown';
      xlPatternLightUp         : Result:= 'lightUp';
      xlPatternGrid            : Result:= 'lightGrid';
      xlPatternSemiGray75      : Result:= 'lightTrellis';
      xlPatternGray16          : Result:= 'gray125'; 
      xlPatternGray8           : Result:= 'gray0625';
      else                       Result:= 'none';
    end;
  end;
var
  BgColorTag, FgColorTag: AnsiString;
begin
  { Pattern }
  Result:= '<fill><patternFill patternType="' + FillPatternToString(AXFData^.FillPattern) + '">';

  { Colors }
  if ( AXFData^.FillPattern <> xlPatternNone ) then
  begin
    if ( AXFData^.FillPattern = xlPatternSolid ) then
    begin
      BgColorTag:= 'fgColor';
      FgColorTag:= 'bgColor';
    end
    else
    begin
      BgColorTag:= 'bgColor';
      FgColorTag:= 'fgColor';
    end;

    if ( AXFData^.FgColor <> xlColorAuto ) and ( AXFData^.FillPattern <> xlPatternSolid ) then
      Result:= Result + '<' + FgColorTag + ' rgb="' + 'FF'
             + ColorRGBToRGBHexString(XLSColorIndexToColorRGB(AXFData^.FgColor)) + '" />';
    if ( AXFData^.BgColor <> xlColorNone ) then
      Result:= Result + '<' + BgColorTag + ' rgb="' + 'FF'
             + ColorRGBToRGBHexString(XLSColorIndexToColorRGB(AXFData^.BgColor)) + '" />';
  end;
  
  Result:= Result + '</patternFill></fill>';
end;

function GetXLSXBorderStringFromXFData(const AXFData: PXFData): AnsiString;
  function BorderStyleToSTring(const BorderStyle: TXLBorderStyle): AnsiString;
  begin
    case BorderStyle of
      bsThin              : Result:= 'thin';
      bsMedium            : Result:= 'medium';
      bsDashed            : Result:= 'dashed';
      bsDotted            : Result:= 'dotted';
      bsThick             : Result:= 'thick';
      bsDouble            : Result:= 'double';
      bsHair              : Result:= 'hair';
      bsMediumDashed      : Result:= 'mediumDashed';
      bsDashDot           : Result:= 'dashDot';
      bsMediumDashDot     : Result:= 'mediumDashDot';
      bsDashDotDot        : Result:= 'dashDotDot';
      bsMediumDashDotDot  : Result:= 'mediumDashDotDot';
      bsSlantedDashDot    : Result:= 'slantDashDot';
      else                  Result:= 'none';
    end;
  end;

begin
  Result:= '<border>';

  if ( AXFData^.LeftBorderStyle <> bsNone ) then
  begin
    Result:= Result + '<left style="' + BorderStyleToSTring(AXFData^.LeftBorderStyle) + '">';
    Result:= Result + '<color rgb="' + 'FF'
      + ColorRGBToRGBHexString(XLSColorIndexToColorRGB(AXFData^.LeftBorderColor)) + '" />';
    Result:= Result + '</left>';  
  end
  else
    Result:= Result + '<left />';

  if ( AXFData^.RightBorderStyle <> bsNone ) then
  begin
    Result:= Result + '<right style="' + BorderStyleToSTring(AXFData^.RightBorderStyle) + '">';
    Result:= Result + '<color rgb="' + 'FF'
      + ColorRGBToRGBHexString(XLSColorIndexToColorRGB(AXFData^.RightBorderColor)) + '" />';
    Result:= Result + '</right>';
  end
  else
    Result:= Result + '<right />';

  if ( AXFData^.TopBorderStyle <> bsNone ) then
  begin
    Result:= Result + '<top style="' + BorderStyleToSTring(AXFData^.TopBorderStyle) + '">';
    Result:= Result + '<color rgb="' + 'FF'
      + ColorRGBToRGBHexString(XLSColorIndexToColorRGB(AXFData^.TopBorderColor)) + '" />';
    Result:= Result + '</top>';
  end
  else
    Result:= Result + '<top />';

  if ( AXFData^.BottomBorderStyle <> bsNone ) then
  begin
    Result:= Result + '<bottom style="' + BorderStyleToSTring(AXFData^.BottomBorderStyle) + '">';
    Result:= Result + '<color rgb="' + 'FF'
      + ColorRGBToRGBHexString(XLSColorIndexToColorRGB(AXFData^.BottomBorderColor)) + '" />';
    Result:= Result + '</bottom>';
  end
  else
    Result:= Result + '<bottom />';

  Result:= Result + '</border>';
end;

function GetXLSXXFStringFromXFData(const AXFData: PXFData;
  const ABorderIndex: Integer;
  const AFillIndex: Integer;
  const AFormatIndex: Integer): AnsiString;
var
 AlignString: AnsiString;
begin
  Result:= '<xf '
      + 'numFmtId="' + AnsiString(IntToStr(AFormatIndex)) + '" '
      + 'fontId="' + AnsiString(IntToStr(AXFData^.FontIndex)) + '" '
      + 'fillId="' + AnsiString(IntToStr(AFillIndex)) + '" '
      + 'borderId="' + AnsiString(IntToStr(ABorderIndex)) + '" '
      + 'xfId="0"';

  { Alignment, rotation, indent }
  AlignString:= '';
  if (AXFData.HAlign <> xlHAlignGeneral) then
  begin
    AlignString:= AlignString + ' horizontal="';
    case AXFData.HAlign of
      xlHAlignLeft                  : AlignString:= AlignString + 'left';
      xlHAlignCenter                : AlignString:= AlignString + 'center';
      xlHAlignRight                 : AlignString:= AlignString + 'right';
      xlHAlignFill                  : AlignString:= AlignString + 'fill';
      xlHAlignJustify               : AlignString:= AlignString + 'justify';
      xlHAlignCenterAcrossSelection : AlignString:= AlignString + 'centerContinuous';
    end;
    AlignString:= AlignString + '"';
  end;
  if (AXFData.VAlign <> xlVAlignBottom) then
  begin
    AlignString:= AlignString + ' vertical="';
    case AXFData.VAlign of
      xlVAlignTop     : AlignString:= AlignString + 'top';
      xlVAlignCenter  : AlignString:= AlignString + 'center';
      xlVAlignJustify : AlignString:= AlignString + 'justify';
    end;
    AlignString:= AlignString + '"';    
  end;
  if (AXFData.Rotation <> 0) then
    AlignString:= AlignString + ' textRotation="' + AnsiString(IntToStr(AXFData.Rotation)) + '"';
  if (AXFData.Indent > 0) then
    AlignString:= AlignString + ' indent="' + AnsiString(IntToStr(AXFData.Indent)) + '"';

  if (AXFData.FontIndex <> 0) then Result:= Result + ' applyFont="1"';
  if (AFillIndex <> 0) then Result:= Result + ' applyFill="1"';
  if (ABorderIndex <> 0) then Result:= Result + ' applyBorder="1"';
  if (AlignString <> '') then Result:= Result + ' applyAlignment="1"';

  Result:= Result + '>';
  if (AlignString <> '') then
   Result:= Result + '<alignment ' + AlignString + '/>';
  Result:= Result + '</xf>';
end;

{TVirtualXFTable}
constructor TVirtualXFTable.Create;
begin
  FDataTable:= TVirtualDataTable.Create;

  { Initialize XF table with default XF }
  ClearBuffer;
  SaveChangedBuffer;

  { Set default index and find default buffer }
  FDefaultIndex:= 0;
  LoadXFToBuffer(FDefaultIndex);
  FDefaultBuffer:= FBuffer;
end;

destructor TVirtualXFTable.Destroy;
begin
  FDataTable.Destroy;
  inherited;
end;

function TVirtualXFTable.ClearBuffer: PXFData;
begin
  FBuffer:= '';
  InitXFData(@FXFData);
  Result:= @FXFData;
end;

procedure TVirtualXFTable.Clear;
begin
  FDataTable.Clear;
  ClearBuffer;
end;

function TVirtualXFTable.GetCount: Integer;
begin
  Result:= FDataTable.Count;
end;

function TVirtualXFTable.GetXF(Index: Integer): PXFData;
begin
  Result:= LoadXFToBuffer(Index);
end;

function TVirtualXFTable.LoadXFToBuffer(const AIndex: Integer): PXFData;
begin
  FBuffer:= FDataTable.Item[AIndex];
  Move(FBuffer[1], FXFData, SizeOf(TXFData));
  Result:= @FXFData;
end;

function TVirtualXFTable.SaveChangedBuffer: Integer;
var
  NewBuffer: AnsiString;
begin
  SetLength(NewBuffer, SizeOf(TXFData));
  Move(FXFData, NewBuffer[1], SizeOf(TXFData));
  Result:= FDataTable.ChangeItem(FBuffer, NewBuffer);
end;

function TVirtualXFTable.SaveChangedBufferWithDuplicates: Integer;
var
  NewBuffer: AnsiString;
begin
  SetLength(NewBuffer, SizeOf(TXFData));
  Move(FXFData, NewBuffer[1], SizeOf(TXFData));
  Result:= FDataTable.AddItemWithDuplicates(NewBuffer);
end;

procedure TVirtualXFTable.UpdateDefaultIndex;
begin
  { find FDefaultBuffer }
  FDefaultIndex:= FDataTable.FindItem(FDefaultBuffer);
  if (FDefaultIndex < 0 ) then
  begin
    ClearBuffer;
    FDefaultIndex:= SaveChangedBuffer;
  end;
end;

end.
