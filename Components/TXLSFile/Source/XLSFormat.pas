unit XLSFormat;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    Rev history:
    2003-08-28   Fix: xlAutomatic constant is a Word number
    2004-06-01   Fix: Width conversion methods improved
    2004-12-24   Fix: Height conversion methods improved
    2005-11-08   Fix: Width conversion methods improved         
    2008-01-16   Fix: Width conversion methods improved for small values

-----------------------------------------------------------------}

interface
uses Classes, Graphics, SysUtils, Windows, XLSBase;

type
  TXLColorIndex = 1..58;

  TCellHAlignment =
    (xlHAlignGeneral,
     xlHAlignLeft,
     xlHAlignCenter,
     xlHAlignRight,
     xlHAlignFill,
     xlHAlignJustify,
     xlHAlignCenterAcrossSelection
     );

  TCellVAlignment =
    (xlVAlignTop,
     xlVAlignCenter,
     xlVAlignBottom,
     xlVAlignJustify);

  TCellRotation = Byte;

  TCellBorderIndex =
   (xlBorderLeft,
    xlBorderRight,
    xlBorderTop,
    xlBorderBottom,
    xlBorderAll);

  TXLBorderStyle =
   (bsNone,
    bsThin,
    bsMedium,
    bsDashed,
    bsDotted,
    bsThick,
    bsDouble,
    bsHair,
    bsMediumDashed,
    bsDashDot,
    bsMediumDashDot,
    bsDashDotDot,
    bsMediumDashDotDot,
    bsSlantedDashDot);

  TXLPattern = (
    xlPatternNone ,
    xlPatternSolid ,
    xlPatternGray50 ,
    xlPatternGray75 ,
    xlPatternGray25 ,
    xlPatternHorizontal ,
    xlPatternVertical,
    xlPatternDown,
    xlPatternUp,
    xlPatternCrissCross,
    xlPatternChecker,
    xlPatternLightHorizontal,
    xlPatternLightVertical,
    xlPatternLightDown,
    xlPatternLightUp,
    xlPatternGrid,
    xlPatternSemiGray75,
    xlPatternGray16,
    xlPatternGray8);

  TXLFontUnderlineStyle =
   (xlFontUnderlineNone,
    xlFontUnderlineSingle,
    xlFontUnderlineDouble,
    xlFontUnderlineSingleAcc,
    xlFontUnderlineDoubleAcc);

  TXLFontSSStyle =
   (xlFontSSNone,
    xlFontSSSuper,
    xlFontSSSub);

  {page setup parameters}
  TXLSPageOrientation = (xlLandscape, xlPortrait);
  TXLSPrintOrder = (xlDownOver, xlOverDown);

  {paper size}
  TXLPaperSize = (
    xlPaperDefault,            
    xlPaperLetter,             // Letter (8-1/2 in. x 11 in.)
    xlPaperLetterSmall,        // Letter Small (8-1/2 in. x 11 in.)
    xlPaperTabloid,            // Tabloid (11 in. x 17 in.)
    xlPaperLedger,             // Ledger (17 in. x 11 in.)
    xlPaperLegal,              // Legal (8-1/2 in. x 14 in.)
    xlPaperStatement,          // Statement (5-1/2 in. x 8-1/2 in.)
    xlPaperExecutive,          // Executive (7-1/2 in. x 10-1/2 in.)
    xlPaperA3,                 // A3 (297 mm x 420 mm)
    xlPaperA4,                 // A4 (210 mm x 297 mm)
    xlPaperA4Small,            // A4 Small (210 mm x 297 mm)
    xlPaperA5,                 // A5 (148 mm x 210 mm)
    xlPaperB4,                 // B4 (250 mm x 354 mm)
    xlPaperB5,                 // B5 (182 mm x 257 mm)
    xlPaperFolio,              // Folio (8-1/2 in. x 13 in.)
    xlPaperQuarto,             // Quarto (215 mm x 275 mm)
    xlPaper10x14,              // 10 in. x 14 in.
    xlPaper11x17,              // 11 in. x 17 in.
    xlPaperNote,               // Note (8-1/2 in. x 11 in.)
    xlPaperEnvelope9,          // Envelope #9 (3-7/8 in. x 8-7/8 in.)
    xlPaperEnvelope10,         // Envelope #10 (4-1/8 in. x 9-1/2 in.)
    xlPaperEnvelope11,         // Envelope #11 (4-1/2 in. x 10-3/8 in.)
    xlPaperEnvelope12,         // Envelope #12 (4-1/2 in. x 11 in.)
    xlPaperEnvelope14,         // Envelope #14 (5 in. x 11-1/2 in.)
    xlPaperCsheet,             // C size sheet
    xlPaperDsheet,             // D size sheet
    xlPaperEsheet,             // E size sheet
    xlPaperEnvelopeDL,         // Envelope DL (110 mm x 220 mm)
    xlPaperEnvelopeC3,         // Envelope C3 (324 mm x 458 mm)
    xlPaperEnvelopeC4,         // Envelope C4 (229 mm x 324 mm)
    xlPaperEnvelopeC5,         // Envelope C5 (162 mm x 229 mm)
    xlPaperEnvelopeC6,         // Envelope C6 (114 mm x 162 mm)
    xlPaperEnvelopeC65,        // Envelope C65 (114 mm x 229 mm)
    xlPaperEnvelopeB4,         // Envelope B4 (250 mm x 353 mm)
    xlPaperEnvelopeB5,         // Envelope B5 (176 mm x 250 mm)
    xlPaperEnvelopeB6,         // Envelope B6 (176 mm x 125 mm)
    xlPaperEnvelopeItaly,      // Envelope (110 mm x 230 mm)
    xlPaperEnvelopeMonarch,    // Envelope Monarch (3-7/8 in. x 7-1/2 in.)
    xlPaperEnvelopePersonal,   // Envelope (3-5/8 in. x 6-1/2 in.)
    xlPaperFanfoldUS,          // U.S. Standard Fanfold (14-7/8 in. x 11 in.)
    xlPaperFanfoldStdGerman,   // German Standard Fanfold (8-1/2 in. x 12 in.)
    xlPaperFanfoldLegalGerman  // German Legal Fanfold (8-1/2 in. x 13 in.)
   ); 

const
  {font underline style constants}
  XLFontUnderlineStyles: array [TXLFontUnderlineStyle] of Byte =
    ($00, $01, $02, $21, $22);

  {text rotation constants}
  xlRotationNone = 0;
  xlRotationTextVerticalCharHorizontal = 255;
  xlRotation45Up = 45;
  xlRotation45Down = 90 + 45;
  xlRotationVerticalUp = 90;
  xlRotationVerticalDown = 180;

  {color indexes}
  xlColorNone           =       58;
  xlColorAuto           =       57;
  
  xlColorBlack    	=	1;
  xlColorWhite   	=	2;
  xlColorRed	        =	3;
  xlColorLightGreen	=	4;
  xlColorBlue   	=	5;
  xlColorYellow	        =	6;
  xlColorVioletRed	=	7;
  xlColorTurquois	=	8;  
  xlColorDarkRed	=	9;
  xlColorGreen		=	10;
  xlColorDarkBlue	=	11;
  xlColorBrownGreen	=	12;
  xlColorViolet		=	13;
  xlColorBlueGreen	=	14;
  xlColorGray25		=	15;
  xlColorGrey25		=	15;
  xlColorGray50		=	16;
  xlColorGrey50		=	16;
  xlColorBlueViolet	=	17;
  xlColorCherry2	=	18;
  xlColorIvory		=	19;
  xlColorLightTurquois	=	20;
  xlColorDarkViolet	=	21;
  xlColorCoral		=	22;
  xlColorCornFlower	=	23;
  xlColorPastelSky	=	24;
  xlColorDarkBlue2	=	25;
  xlColorVioletRed2	=	26;
  xlColorYellow2	=	27;
  xlColorTurquos2	=	28;
  xlColorViolet2	=	29;
  xlColorDarkRed2	=	30;
  xlColorBlueGreen2	=	31;
  xlColorBlue2		=	32;
  xlColorSky		=	33;
  xlColorPaleTurquois	=	34;
  xlColorPaleGreen	=	35;
  xlColorLightYellow	=	36;
  xlColorPaleSky	=	37;
  xlColorRose		=	38;
  xlColorLilac		=	39;
  xlColorLightBrown	=	40;
  xlColorDarkSky	=	41;
  xlColorDarkTurquois	=	42;
  xlColorGrass		=	43;
  xlColorGold		=	44;
  xlColorLightOrange	=	45;
  xlColorOrange		=	46;
  xlColorDarkBlueGray2	=	47;
  xlColorDarkBlueGrey2	=	47;  
  xlColorGray40		=	48;
  xlColorGrey40		=	48;  
  xlColorDarkBlueGray	=	49;
  xlColorDarkBlueGrey	=	49;  
  xlColorEmerald	=	50;
  xlColorDarkGreen	=	51;
  xlColorOlive		=	52;
  xlColorBrown		=	53;
  xlColorCherry		=	54;
  xlColorIndigo		=	55;
  xlColorGray80		=	56;
  xlColorGrey80		=	56;

  xlBuiltinStyles: array[0..5] of byte = (4,7,0,5,3,6);

  {page setup: page start number}
  xlAutomatic = Word($FFFF);

  xlColWidthMult = 256;  { = (stored column width) / (internal column width)}
  xlRowHeightMult = 20;  { = (stored row height) / (internal row height)}

  xlWidthToPix_SmallFonts = 7;  { = ( Width in Pixels / Excel internal width )when small fonts used }
  xlWidthToPix_LargeFonts = 9;  { = ( Width in Pixels / Excel internal width )when large fonts used }

  xlWidthToPix_AdditionPx_SmallFonts = 5;
  xlWidthToPix_AdditionPx_LargeFonts = 7;

  xlWidthToPix_Rate_SmallFonts = 0.0834;
  xlWidthToPix_Rate_LargeFonts = 0.0626;

  xlPixToHeight_SmallFonts = 0.75;
  xlPixToHeight_LargeFonts = 0.6;


function XLSColorIndexToFileColorIndex(C: TXLColorIndex): word;
function FileColorIndexToXLSColorIndex(C: Word): TXLColorIndex;

function XLSLineStyleToPenStyle(S: TXLBorderStyle): TPenStyle;
function XLSLineStyleWidth(S: TXLBorderStyle): byte;
function TextAlignmentToXLSCellHAlignment(A: TAlignment): TCellHAlignment;

function ColorToXLSColorIndex(C: TColor): TXLColorIndex;
function RGBToColor(RGB: Integer): TColor;
function XLSColorIndexToColorRGB(C: TXLColorIndex): Integer;
function ColorRGBToXLSColorIndex(RGB: Integer): TXLColorIndex;
function ColorRGBToRGBHexString(RGB: Integer): AnsiString;

function PixToXLSWidth(Size: Double): Double;
function XLSWidthToPix(Size: Double): Double;
function XLSWidthToStoredWidth(Size: Double): Integer;
function XLSWidthToStoredWidthXLSX(Size: Double): Double;
function StoredWidthToXLSWidth(Size: Integer): Double;
function PixToXLSHeight(Size: Double): Double;
function XLSHeightToPix(Size: Double): Double;

function CmToInches(Value: Double): Double;
function InchesToCm(Value: Double): Double;

{font size}
function FontSizeToXLSRowHeight(FontSize: Integer): Integer;

var
  PixelsPerInch: Integer;
  xlDefaultColumnWidthPx: Integer; //= 64;
  xlDefaultRowHeightPx: Integer;   //= 17;

  xlWidthToPix: Integer;
  xlPixToHeight: Double;

  xlWidthToPix_AdditionPx: Integer;
  xlWidthToPix_Rate: Double;

var
  XLSColorIndexToColorMap : array[TXLColorIndex] of Integer =
  {B G R}
 ($000000 ,
  $FFFFFF ,
  $0000FF ,
  $00FF00 ,
  $FF0000 ,
  $00FFFF ,
  $FF00FF ,
  $FFFF00 ,
  $000080 ,
  $008000 ,
  $800000 ,
  $008080 ,
  $800080 ,
  $808000 ,
  $C0C0C0 ,
  $808080 ,
  $FF9999 ,
  $663399 ,
  $CCFFFF ,
  $FFFFCC ,
  $660066 ,
  $8080FF ,
  $CC6600 ,
  $FFCCCC ,
  $800000 ,
  $FF00FF ,
  $00FFFF ,
  $FFFF00 ,
  $800080 ,
  $000080 ,
  $808000 ,
  $FF0000 ,
  $FFCC00 ,
  $FFFFCC ,
  $CCFFCC ,
  $99FFFF ,
  $FFCC99 ,
  $CC99FF ,
  $FF99CC ,
  $99CCFF ,
  $FF6633 ,
  $CCCC33 ,
  $00CC99 ,
  $00CCFF ,
  $0099FF ,
  $0066FF ,
  $996666 ,
  $969696 ,
  $663300 ,
  $669933 ,
  $003300 ,
  $003333 ,
  $003399 ,
  $663399 ,
  $993333 ,
  $333333 ,
  $000000, // not used
  $000000  // not used
  ) ;
  
implementation

var
  DC: HDC;  { used for PixelsPerInch, see initialization }

function XLSColorIndexToFileColorIndex(C: TXLColorIndex): word;
begin
  result:= C + 7;
end;

function FileColorIndexToXLSColorIndex(C: Word): TXLColorIndex;
begin
  if  (C >= Low(TXLColorIndex) + 7)
  and (C <= High(TXLColorIndex) + 7) then
    result:= C - 7
  else
    result:= xlColorBlack;  
end;

function XLSLineStyleToPenStyle(S: TXLBorderStyle): TPenStyle;
begin
  case S of
    bsThin,
    bsMedium,
    bsThick,
    bsHair ,
    bsDouble          : result:= psSolid;
    bsDashed,
    bsMediumDashed    : result:= psDash;
    bsDotted          : result:= psDot;
    bsDashDot,
    bsMediumDashDot,
    bsSlantedDashDot  : result:= psDashDot;
    bsDashDotDot,
    bsMediumDashDotDot: result:= psDashDotDot;
    else                result:= psClear;
  end;
end;

function XLSLineStyleWidth(S: TXLBorderStyle): byte;
begin
  case S of
    bsThin,
    bsMedium,
    bsHair,
    bsDashed,
    bsDotted,
    bsDashDot,
    bsSlantedDashDot,
    bsDashDotDot      : result:= 1;
    bsThick,
    bsDouble,
    bsMediumDashed,
    bsMediumDashDot,
    bsMediumDashDotDot: result:= 2;
    else                result:= 1;
  end;
end;

function ColorToXLSColorIndex(C: TColor): TXLColorIndex;
{
  We have only XLSColorIndex-To-RGB mapping.
  We must find "closest" XLS color by given RGB.
  For comparing two colors we use the following metrics :
  r(R,G,B) = sqrt(R*R + G*G + B*B)
}

  function RGBMetrics(C1, C2: Longint): Longint;
  var
    R1,R2,G1,G2,B1,B2: Byte;
  begin
    R1:= (C1 shr 16) and $FF;
    G1:= (C1 shr 8)  and $FF;
    B1:= (C1)        and $FF;
    R2:= (C2 shr 16) and $FF;
    G2:= (C2 shr 8)  and $FF;
    B2:= (C2)        and $FF;
    result:= round(sqrt(
      (R1-R2)*(R1-R2) + (G1-G2)*(G1-G2) + (B1-B2)*(B1-B2)
    ));
  end;

var
  ClosestI, I: TXLColorIndex;
  ClosestM, M: Longint;
  LRGB: Longint;
begin
  LRGB:= ColorToRGB(C);
  ClosestI:= Low(TXLColorIndex);
  ClosestM:= $FFFFFF;
  for I:= Low(TXLColorIndex) to High(TXLColorIndex) do
  begin
    M:= RGBMetrics(XLSColorIndexToColorMap[I], LRGB);
    if M < ClosestM then
    begin
      ClosestM:= M;
      ClosestI:= I;
    end;
  end;
  result:= ClosestI;
end;

function TextAlignmentToXLSCellHAlignment(A: TAlignment): TCellHAlignment;
begin
  case A of
    taLeftJustify  : result:= xlHAlignLeft;
    taRightJustify : result:= xlHAlignRight;
    else             result:= xlHAlignCenter;
  end;
end;

function PixToXLSWidth(Size: Double): Double;
begin
  {column width in pixels -> excel column width}
  if Size > 11 then
    Result:= (Size - xlWidthToPix_AdditionPx)/xlWidthToPix
  else
    Result:= Size * xlWidthToPix_Rate;
end;

function XLSWidthToPix(Size: Double): Double;
begin
  {excel column width -> column width in pixels}
  if Size >= 1 then
    Result:= Size * xlWidthToPix + xlWidthToPix_AdditionPx
  else
    Result:= Size / xlWidthToPix_Rate;
end;

function XLSWidthToStoredWidth(Size: Double): Integer;
begin
  Result:= round((XLSWidthToPix(Size) / xlWidthToPix) * xlColWidthMult);
end;

function XLSWidthToStoredWidthXLSX(Size: Double): Double;
begin
  Result:= PixToXLSWidth((XLSWidthToPix(Size) + xlWidthToPix_AdditionPx));
end;

function StoredWidthToXLSWidth(Size: Integer): Double;
begin
  Result:= PixToXLSWidth( Size * 1.00 / xlColWidthMult * xlWidthToPix);
end;

function PixToXLSHeight(Size: Double): Double;
begin
  {row height in pixels -> excel row height}
  Result:= (Size * xlPixToHeight);
end;

function XLSHeightToPix(Size: Double): Double;
begin
  {excel row height -> row height in pixels}
  Result:= (Size / xlPixToHeight);
end;

function RGBToColor(RGB: Integer): TColor;
begin
  Result:= RGB;
end;

function XLSColorIndexToColorRGB(C: TXLColorIndex): Integer;
begin
  result:= XLSColorIndexToColorMap[C];
end;

function ColorRGBToRGBHexString(RGB: Integer): AnsiString;
begin
  Result:= AnsiString(IntToHex(RGB, 6));
  {Now we have B-G-R representation. Swap B and R.}
  Result:= Copy(Result, 5, 2) + Copy(Result, 3, 2) + Copy(Result, 1, 2);
end;

function ColorRGBToXLSColorIndex(RGB: Integer): TXLColorIndex;
begin
  result:= ColorToXLSColorIndex(RGBToColor(RGB));
end;

function CmToInches(Value: Double): Double;
begin
  result:= Value / 2.5;
end;

function InchesToCm(Value: Double): Double;
begin
  result:= Value * 2.5;
end;

function FontSizeToXLSRowHeight(FontSize: Integer): Integer;
begin
  if FontSize < 10 then
    Result:= round(1.275 * 10)
  else
    Result:= round(1.275 * FontSize);
end;


initialization
  { find PixelsPerInch }
  DC := GetDC(0);
  PixelsPerInch := GetDeviceCaps(DC, LOGPIXELSY);
  ReleaseDC(0, DC);

  { find default size }
  if PixelsPerInch = 96 then
  begin
    { small fonts }
    xlDefaultColumnWidthPx := 64;
    xlDefaultRowHeightPx   := 17;
  end
  else
  begin
    { large fonts }
    xlDefaultColumnWidthPx := 80;
    xlDefaultRowHeightPx   := 22;
  end;

  { find width and height translation rates }
  if PixelsPerInch = 96 then
  begin
    { small fonts }
    xlWidthToPix:= xlWidthToPix_SmallFonts;
    xlWidthToPix_AdditionPx:= xlWidthToPix_AdditionPx_SmallFonts;
    xlWidthToPix_Rate:= xlWidthToPix_Rate_SmallFonts;
    xlPixToHeight:= xlPixToHeight_SmallFonts;

  end
  else
  begin
    { large fonts }
    xlWidthToPix:= xlWidthToPix_LargeFonts;
    xlWidthToPix_AdditionPx:= xlWidthToPix_AdditionPx_LargeFonts;
    xlWidthToPix_Rate:= xlWidthToPix_Rate_LargeFonts;
    xlPixToHeight:= xlPixToHeight_LargeFonts;
  end;

end.
