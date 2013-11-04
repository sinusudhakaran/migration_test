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
    procedure DrawAntialisedLine(Canvas: TCanvas; const AX1, AY1, AX2, AY2: real; const LineColor: TColor);
    function GetTextWidth(aText : string; aFont : TFont) : integer;
    function GetMaskTypeArray(aMask : string) : string;
    procedure GetStartAndEndfromCurrentPos(aMaskTypeArr : String; aCurPos : integer;
                                           var aStartPos, aEndPos: integer);
    procedure GetRGBfromColor(aColor: TColor; var aRed, aGreen, aBlue: Byte);
    procedure GetColorFromRGB(aRed, aGreen, aBlue: Byte; var aColor: TColor);
    function GetMaskMessage(aMaskChar : string) : string;
  public
    function  BlendColors(aFirstColor, aSecondColor : TColor; aPercent: Single) : TColor;
    procedure DrawMaskHint(aLblLine, aLblHint : TLabel; aMaskEdit : TMaskEdit;
                           aBackColor, aLineColor, aFontColor : TColor);
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
procedure TMaskHint.DrawAntialisedLine(Canvas: TCanvas; const AX1, AY1, AX2, AY2: real; const LineColor: TColor);
var
  swapped: boolean;

  procedure plot(const x, y, c: real);
  var
    resclr: TColor;
  begin
    if swapped then
      resclr := Canvas.Pixels[round(y), round(x)]
    else
      resclr := Canvas.Pixels[round(x), round(y)];
    resclr := RGB(round(GetRValue(resclr) * (1-c) + GetRValue(LineColor) * c),
                  round(GetGValue(resclr) * (1-c) + GetGValue(LineColor) * c),
                  round(GetBValue(resclr) * (1-c) + GetBValue(LineColor) * c));
    if swapped then
      Canvas.Pixels[round(y), round(x)] := resclr
    else
      Canvas.Pixels[round(x), round(y)] := resclr;
  end;

  function rfrac(const x: real): real; inline;
  begin
    rfrac := 1 - frac(x);
  end;

  procedure swap(var a, b: real);
  var
    tmp: real;
  begin
    tmp := a;
    a := b;
    b := tmp;
  end;

var
  x1, x2, y1, y2, dx, dy, gradient, xend, yend, xgap, xpxl1, ypxl1,
  xpxl2, ypxl2, intery: real;
  x: integer;

begin

  x1 := AX1;
  x2 := AX2;
  y1 := AY1;
  y2 := AY2;

  dx := x2 - x1;
  dy := y2 - y1;
  swapped := abs(dx) < abs(dy);
  if swapped then
  begin
    swap(x1, y1);
    swap(x2, y2);
    swap(dx, dy);
  end;
  if x2 < x1 then
  begin
    swap(x1, x2);
    swap(y1, y2);
  end;

  gradient := dy / dx;

  xend := round(x1);
  yend := y1 + gradient * (xend - x1);
  xgap := rfrac(x1 + 0.5);
  xpxl1 := xend;
  ypxl1 := floor(yend);
  plot(xpxl1, ypxl1, rfrac(yend) * xgap);
  plot(xpxl1, ypxl1 + 1, frac(yend) * xgap);
  intery := yend + gradient;

  xend := round(x2);
  yend := y2 + gradient * (xend - x2);
  xgap := frac(x2 + 0.5);
  xpxl2 := xend;
  ypxl2 := floor(yend);
  plot(xpxl2, ypxl2, rfrac(yend) * xgap);
  plot(xpxl2, ypxl2 + 1, frac(yend) * xgap);

  for x := round(xpxl1) + 1 to round(xpxl2) - 1 do
  begin
    plot(x, floor(intery), rfrac(intery));
    plot(x, floor(intery) + 1, frac(intery));
    intery := intery + gradient;
  end;

end;

//------------------------------------------------------------------------------
function TMaskHint.GetTextWidth(aText: string; aFont: TFont): integer;
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
  while (CurrIndex < length(aMaskTypeArr)) and
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
procedure TMaskHint.DrawMaskHint(aLblLine, aLblHint : TLabel; aMaskEdit: TMaskEdit;
                                 aBackColor, aLineColor, aFontColor: TColor);
var
  MaskCursorStrPos : integer;
  StartPos, EndPos : integer;
  MaskStrPix, MaskEndPix : integer;
  HintPixWidth, SingleSidePixDiff : integer;

  TextStrPix, TextEndPix : integer;
  CurrMaskChar : string;
  HelpMessage : string;
  Mask, EditedMask, MaskTypeStr : string;
  index : integer;

  procedure DrawLine(TopX, TopY, BottomX, BottomY : integer );
  begin
    DrawAntialisedLine(aLblLine.Canvas, TopX, 0, TopX, TopY, aLineColor);
    DrawAntialisedLine(aLblLine.Canvas, TopX, TopY, BottomX, BottomY, aLineColor);
    DrawAntialisedLine(aLblLine.Canvas, BottomX, BottomY, BottomX, 28, aLineColor);

    //aLblLine.Canvas.MoveTo(TopX, 0);
    //aLblLine.Canvas.LineTo(TopX, TopY);
    //aLblLine.Canvas.LineTo(BottomX, BottomY);
    //aLblLine.Canvas.LineTo(BottomX, 25);
  end;

begin
  MaskCursorStrPos := aMaskEdit.SelStart + 1;
  Mask             := aMaskEdit.EditMask;
  EditedMask       := aMaskEdit.EditText;
  MaskTypeStr      := GetMaskTypeArray(Mask);
  CurrMaskChar     := midstr(MaskTypeStr, MaskCursorStrPos, 1);
  HelpMessage      := GetMaskMessage(CurrMaskChar);

  GetStartAndEndfromCurrentPos(MaskTypeStr, MaskCursorStrPos, StartPos, EndPos);

  MaskStrPix := GetTextWidth(leftstr(EditedMask, StartPos-1), aMaskEdit.Font);
  MaskEndPix := GetTextWidth(leftstr(EditedMask, EndPos), aMaskEdit.Font);

  aLblLine.Top := aMaskEdit.Top + aMaskEdit.Height;
  aLblLine.Repaint;

  aLblHint.Font.Color := aFontColor;
  aLblHint.Caption := HelpMessage;

  if (MaskStrPix = MaskEndPix) or
     (aLblHint.Caption = '') then
  begin
    aLblHint.Caption := '';
  end
  else
  begin
    //Adjustments
    MaskStrPix := MaskStrPix + 2;
    MaskEndPix := MaskEndPix + 4;

    HintPixWidth := GetTextWidth(HelpMessage, aLblHint.Font);
    SingleSidePixDiff := trunc((HintPixWidth - (MaskEndPix - MaskStrPix))/2);

    TextStrPix := MaskStrPix - SingleSidePixDiff;
    TextEndPix := TextStrPix + HintPixWidth;
    if TextStrPix < 0 then
    begin
      TextEndPix := TextEndPix - TextStrPix;
      TextStrPix := 0;
    end;

    //Adjustments
    TextEndPix := TextEndPix + 4;

    aLblHint.Top := aLblLine.Top + 12;
    aLblHint.Left := aLblLine.Left + TextStrPix + 2;

    aLblLine.Repaint;
    {aLblLine.Canvas.Pen.Width := 3;
    aLblLine.Canvas.Pen.Color := BlendColors(aLineColor, aBackColor, 0.1);
    DrawLine(MaskStrPix, 3, TextStrPix, 12);
    DrawLine(MaskEndPix, 3, TextEndPix, 12);

    aLblLine.Canvas.Pen.Width := 2;
    aLblLine.Canvas.Pen.Color := BlendColors(aLineColor, aBackColor, 0.3);
    DrawLine(MaskStrPix, 3, TextStrPix, 12);
    DrawLine(MaskEndPix, 3, TextEndPix, 12);}

    aLblLine.Canvas.Pen.Width := 1;
    aLblLine.Canvas.Pen.Color := aLineColor;
    DrawLine(MaskStrPix, 3, TextStrPix, 12);
    DrawLine(MaskEndPix, 3, TextEndPix, 12);
  end;
end;

end.
