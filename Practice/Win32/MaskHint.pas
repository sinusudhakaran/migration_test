unit MaskHint;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  Mask;

type
  TMaskHint = class
  private
    function GetTextWidth(aText: string; aFont: TFont) : integer;
    procedure GetTextWidthAndHeight(aText: string; aFont: TFont; var aTextWidth, aTextHeight : integer);
    function GetMaskTypeArray(aMask : string) : string;
    procedure GetStartAndEndfromCurrentPos(aMaskTypeArr : String; aCurPos : integer;
                                           var aStartPos, aEndPos: integer);
    procedure GetRGBfromColor(aColor: TColor; var aRed, aGreen, aBlue: Byte);
    procedure GetColorFromRGB(aRed, aGreen, aBlue: Byte; var aColor: TColor);
    function GetMaskMessage(aMaskChar : string) : string;
  public
    function  RemovedMaskBsbFromAccountNumber(aAccountNumber : string; aMaskBsb: string) : string;
    function  RemoveUnusedCharsFromAccNumber(aAccountNumber : string) : string;
    function  BlendColors(aFirstColor, aSecondColor : TColor; aPercent: Single) : TColor;
    procedure DrawMaskHint(alblHint : TLabel; aMaskEdit: TMaskEdit;
                           aBackColor, aLineColor, aFontColor, aHintColor, aShadowColor: TColor;
                           aHintGapHeight : integer);
  end;

implementation

uses
  strutils,
  maskutils,
  math;

const
  MESG_MskAlpha       = 'A-Z,a-z';
  MESG_MskAlphaOpt    = 'A-Z,a-z (optional)';
  MESG_MskAlphaNum    = 'A-Z,a-z,0-9';
  MESG_MskAlphaNumOpt = 'A-Z,a-z,0-9 (optional)';
  MESG_MskAscii       = 'Any characters';
  MESG_MskAsciiOpt    = 'Any characters (optional)';
  MESG_MskNumeric     = '0-9, no plus or minus';
  MESG_MskNumericOpt  = '0-9, no plus or minus (optional)';
  MESG_MskNumSymOpt   = '0-9, plus or minus';

{ TMaskHint }
//------------------------------------------------------------------------------
function TMaskHint.GetTextWidth(aText: string; aFont: TFont) : integer;
var
  tmpBmp : TBitmap;
begin
  tmpBmp := TBitmap.Create;
  try
    tmpBmp.Canvas.Font.Assign(aFont);
    Result := tmpBmp.Canvas.TextWidth(aText);
  finally
    FreeAndNil(tmpBmp);
  end;
end;

//------------------------------------------------------------------------------
procedure TMaskHint.GetTextWidthAndHeight(aText: string; aFont: TFont; var aTextWidth, aTextHeight : integer);
var
  tmpBmp : TBitmap;
begin
  tmpBmp := TBitmap.Create;
  try
    tmpBmp.Canvas.Font.Assign(aFont);
    aTextWidth := tmpBmp.Canvas.TextWidth(aText);
    aTextHeight := tmpBmp.Canvas.TextHeight(aText);
  finally
    FreeAndNil(tmpBmp);
  end;
end;

//------------------------------------------------------------------------------
function TMaskHint.RemovedMaskBsbFromAccountNumber(aAccountNumber: string; aMaskBsb: string): string;
begin
  if length(aMaskBsb) = 0 then
  begin
    Result := aAccountNumber;
    Exit;
  end;

  Result := RightStr(aAccountNumber, Length(aAccountNumber)-Length(aMaskBsb));
end;

//------------------------------------------------------------------------------
function TMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber: string): string;
var
  CurChar : char;
  index : integer;
begin
  Result := '';
  for index := 1 to length(aAccountNumber) do
  begin
    CurChar := aAccountNumber[index];

    if ((CurChar >= 'a') and (CurChar <='z')) or
       ((CurChar >= 'A') and (CurChar <='Z')) or
       ((CurChar >= '0') and (CurChar <='9')) or
       (CurChar = '.') then
      Result := Result + aAccountNumber[index];
  end;
end;

//------------------------------------------------------------------------------
function TMaskHint.GetMaskMessage(aMaskChar : string) : string;
begin
  if aMaskChar = mMskAlpha then
    Result := MESG_MskAlpha
  else if aMaskChar = mMskAlphaOpt then
    Result := MESG_MskAlphaOpt
  else if aMaskChar = mMskAlphaNum then
    Result := MESG_MskAlphaNum
  else if aMaskChar = mMskAlphaNumOpt then
    Result := MESG_MskAlphaNumOpt
  else if aMaskChar = mMskAscii then
    Result := MESG_MskAscii
  else if aMaskChar = mMskAsciiOpt then
    Result := MESG_MskAsciiOpt
  else if aMaskChar = mMskNumeric then
    Result := MESG_MskNumeric
  else if aMaskChar = mMskNumericOpt then
    Result := MESG_MskNumericOpt
  else if aMaskChar = mMskNumSymOpt then
    Result := MESG_MskNumSymOpt
  else
    Result := '';
end;

//------------------------------------------------------------------------------
function TMaskHint.GetMaskTypeArray(aMask: string): string;
var
  MaskIndex : integer;
  CurrentStr : string;
begin
  Result := '';
  CurrentStr := '';

  for MaskIndex := 1 to length(aMask) do
  begin
    case MaskGetCharType(aMask, MaskIndex) of
      mcNone :            CurrentStr := '';
      mcLiteral :         CurrentStr := 'T';
      mcIntlLiteral :     CurrentStr := 'I';
      mcDirective :       CurrentStr := '';
      mcMask, mcMaskOpt : CurrentStr := midstr(aMask, MaskIndex, 1);
      mcFieldSeparator :  CurrentStr := 'S';
      mcField :           CurrentStr := 'F';
    end;

    Result := Result + CurrentStr;
  end;
end;

//------------------------------------------------------------------------------
procedure TMaskHint.GetStartAndEndfromCurrentPos(aMaskTypeArr: String; aCurPos: integer;
                                                 var aStartPos, aEndPos: integer);
var
  CurrChar : string;
  CurrIndex : integer;
begin
  // Start Pos
  CurrChar := midstr(aMaskTypeArr, aCurPos, 1);
  CurrIndex := aCurPos-1;
  while (CurrIndex > 0) and
        (CurrChar = midstr(aMaskTypeArr, CurrIndex, 1)) do
  begin
    CurrChar := midstr(aMaskTypeArr, CurrIndex, 1);
    CurrIndex := CurrIndex-1;
  end;
  aStartPos := CurrIndex + 1;

  // End Pos
  CurrChar := midstr(aMaskTypeArr, aCurPos, 1);
  CurrIndex := aCurPos+1;
  while (CurrIndex <= length(aMaskTypeArr)) and
        (CurrChar = midstr(aMaskTypeArr, CurrIndex, 1)) do
  begin
    CurrChar := midstr(aMaskTypeArr, CurrIndex, 1);
    CurrIndex := CurrIndex+1;
  end;
  CurrIndex := CurrIndex - 1;
  if CurrIndex > length(aMaskTypeArr) then
    CurrIndex := length(aMaskTypeArr);

  aEndPos := CurrIndex;
end;

//------------------------------------------------------------------------------
procedure TMaskHint.GetRGBfromColor(aColor: TColor; var aRed, aGreen, aBlue: Byte);
var
  Color : LongInt;
begin
  Color := ColorToRGB(aColor);
  aRed   := GetRValue(Color);
  aGreen := GetGValue(Color);
  aBlue  := GetBValue(Color);
end;

//------------------------------------------------------------------------------
procedure TMaskHint.GetColorFromRGB(aRed, aGreen, aBlue: Byte; var aColor: TColor);
begin
  aColor := RGB(aRed, aGreen, aBlue);
end;

//------------------------------------------------------------------------------
function TMaskHint.BlendColors(aFirstColor, aSecondColor: TColor; aPercent: Single): TColor;
var
  Red1, Green1, Blue1: Byte;
  Red2, Green2, Blue2: Byte;
begin
  GetRGBfromColor(aFirstColor, Red1, Green1, Blue1);
  GetRGBfromColor(aSecondColor, Red2, Green2, Blue2);

  Red1   := trunc(Red1 * aPercent) + trunc(Red2 * (1-aPercent));
  Green1 := trunc(Green1 * aPercent) + trunc(Green2 * (1-aPercent));
  Blue1  := trunc(Blue1 * aPercent) + trunc(Blue2 * (1-aPercent));

  GetColorFromRGB(Red1, Green1, Blue1, Result);

  GetRGBfromColor(Result, Red1, Green1, Blue1);

  GetColorFromRGB(Red1, Green1, Blue1, Result);
end;

//------------------------------------------------------------------------------
procedure TMaskHint.DrawMaskHint(alblHint : TLabel; aMaskEdit: TMaskEdit;
                                 aBackColor, aLineColor, aFontColor, aHintColor, aShadowColor: TColor;
                                 aHintGapHeight : integer);
const
  SHADOW_PIXEL_DIFF = 2;
  HINT_TEXT_BORDER_WIDTH = 3;
var
  MaskCursorStrPos : integer;
  StartPos, EndPos : integer;
  MaskStrPix, MaskEndPix : integer;

  HintTextWidth, HintTextHeight : integer;
  HintTextTop, HintTextLeft : integer;
  HintBoxTop, HintBoxLeft, HintBoxBottom, HintBoxRight : integer;
  SingleSidePixDiff : integer;

  CurrMaskChar : string;
  HelpMessage : string;
  Mask, EditedMask, MaskTypeStr : string;

  //----------------------------------------------------------------------------
  procedure DrawHintWindow(aCanvas: TCanvas;
                           aLeft,aTop,aRight,aBottom : integer;
                           aPointHeight, aPoint1X, aPoint2X : integer;
                           aLineColor, aFillColor : TColor;
                           aAddShadow : Boolean);
  Const
    POINT_SIDE_WIDTH = 3;
  var
    Point1X1, Point1X2 : integer;
    Point2X1, Point2X2 : integer;
    PointBottom : integer;
  begin
    aCanvas.Pen.Color   := aLineColor;
    aCanvas.Brush.Color := aFillColor;

    // Point 1
    Point1X1 := aPoint1X - POINT_SIDE_WIDTH;
    Point1X2 := aPoint1X + POINT_SIDE_WIDTH;
    if Point1X1 < aLeft then
    begin
      Point1X2 := Point1X2 + (aLeft-Point1X1);
      Point1X1 := Point1X1 + (aLeft-Point1X1);
    end;

    // Point 2
    Point2X1 := aPoint2X - POINT_SIDE_WIDTH;
    Point2X2 := aPoint2X + POINT_SIDE_WIDTH;
    if Point2X1 < aLeft then
    begin
      Point2X2 := Point2X2 + (aLeft-Point2X1);
      Point2X1 := Point2X1 + (aLeft-Point2X1);
    end;

    if aAddShadow then
    begin
      aLeft   := aLeft   + SHADOW_PIXEL_DIFF;
      aTop    := aTop    + SHADOW_PIXEL_DIFF;
      aRight  := aRight  + SHADOW_PIXEL_DIFF;
      aBottom := aBottom + SHADOW_PIXEL_DIFF;

      aPoint1X := aPoint1X + SHADOW_PIXEL_DIFF;
      aPoint2X := aPoint2X + SHADOW_PIXEL_DIFF;

      Point1X1 := Point1X1 + SHADOW_PIXEL_DIFF;
      Point1X2 := Point1X2 + SHADOW_PIXEL_DIFF;
      Point2X1 := Point2X1 + SHADOW_PIXEL_DIFF;
      Point2X2 := Point2X2 + SHADOW_PIXEL_DIFF;
    end;

    PointBottom := aBottom + aPointHeight;

    aCanvas.Polyline([Point(aLeft, aBottom),
                      Point(aLeft, aTop),
                      Point(aRight, aTop),
                      Point(aRight, aBottom),
                      Point(Point2X2, aBottom),
                      Point(aPoint2X, PointBottom),
                      Point(Point2X1, aBottom),
                      Point(Point1X2, aBottom),
                      Point(aPoint1X, PointBottom),
                      Point(Point1X1, aBottom),
                      Point(aLeft, aBottom)]);

    aCanvas.FloodFill(aLeft + (aRight div 2), aTop + (aBottom div 2), aLineColor, fsBorder);
  end;

  //----------------------------------------------------------------------------
  procedure TextOut(aCanvas: TCanvas; aLeft, aTop : integer; aMessage : string; aColor : TColor);
  begin
    aCanvas.Pen.Color := aColor;
    aCanvas.TextOut(aLeft, aTop, aMessage);
  end;

begin
  // Initlise Variables
  MaskCursorStrPos := aMaskEdit.SelStart + 1;
  Mask             := aMaskEdit.EditMask;
  EditedMask       := aMaskEdit.EditText;
  alblHint.Font    := Screen.HintFont;

  // Set Label to be directly above Mask
  alblHint.Top  := aMaskEdit.Top - alblHint.Height;
  alblHint.Left := aMaskEdit.Left + 2;
  alblHint.Repaint;

  // Get Mask Hint Message
  MaskTypeStr      := GetMaskTypeArray(Mask);
  CurrMaskChar     := midstr(MaskTypeStr, MaskCursorStrPos, 1);
  HelpMessage      := GetMaskMessage(CurrMaskChar);

  // Get Mask Start and End X pixel positions
  GetStartAndEndfromCurrentPos(MaskTypeStr, MaskCursorStrPos, StartPos, EndPos);
  MaskStrPix := GetTextWidth(leftstr(EditedMask, StartPos-1), aMaskEdit.Font);
  MaskEndPix := GetTextWidth(leftstr(EditedMask, EndPos), aMaskEdit.Font) + 2;

  if (MaskStrPix = MaskEndPix) or
     (HelpMessage = '') then
  begin
    HelpMessage := '';
  end
  else
  begin
    // Get Pixel Width and Height using message and font
    GetTextWidthandHeight(HelpMessage, alblHint.Font, HintTextWidth, HintTextHeight);

    // Get Differance between mask and hint size for one side and then adjust
    SingleSidePixDiff := trunc(((HintTextWidth + (HINT_TEXT_BORDER_WIDTH*2)) - (MaskEndPix - MaskStrPix))/2);
    HintBoxLeft := MaskStrPix - SingleSidePixDiff;
    HintBoxRight := HintBoxLeft + HintTextWidth + (HINT_TEXT_BORDER_WIDTH*2);

    // Adjust if less that Zero
    if HintBoxLeft < 0 then
    begin
      HintBoxRight := HintBoxRight - HintBoxLeft;
      HintBoxLeft := 0;
    end;

    // Set other Hint Sizes
    HintBoxBottom := alblHint.Height - aHintGapHeight;
    HintBoxTop    := HintBoxBottom - (HINT_TEXT_BORDER_WIDTH*2) - HintTextHeight;
    HintTextTop  := HintBoxTop + HINT_TEXT_BORDER_WIDTH;
    HintTextLeft := HintBoxLeft + HINT_TEXT_BORDER_WIDTH;

    // Draw the Hint
    alblHint.Repaint;
    DrawHintWindow(alblHint.Canvas, HintBoxLeft, HintBoxTop, HintBoxRight, HintBoxBottom,
                   8, MaskStrPix, MaskEndPix, aShadowColor, aShadowColor, true);
    DrawHintWindow(alblHint.Canvas, HintBoxLeft, HintBoxTop, HintBoxRight, HintBoxBottom,
                   8, MaskStrPix, MaskEndPix, aLineColor, aHintColor, false);
    TextOut(alblHint.Canvas, HintTextLeft, HintTextTop, HelpMessage, aFontColor);
  end;
end;

end.
