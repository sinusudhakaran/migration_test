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
  maskutils;

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
  TextStrPix, TextEndPix : integer;
  CurrMaskChar : string;
  HelpMessage : string;
  Mask, EditedMask, MaskTypeStr : string;

  procedure DrawLine(TopX, TopY, BottomX, BottomY : integer );
  begin
    aLblLine.Canvas.MoveTo(TopX, 0);
    aLblLine.Canvas.LineTo(TopX, TopY);
    aLblLine.Canvas.LineTo(BottomX, BottomY);
    aLblLine.Canvas.LineTo(BottomX, 25);
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
  aLblLine.Canvas.Pen.Color := aLineColor;

  aLblHint.Font.Color := aFontColor;
  aLblHint.Caption := HelpMessage;

  if MaskStrPix = MaskEndPix then
  begin
    aLblHint.Caption := '';
  end
  else
  begin
    MaskStrPix := MaskStrPix + 2;
    MaskEndPix := MaskEndPix + 4;

    TextEndPix := GetTextWidth(HelpMessage, aLblHint.Font);
    TextStrPix := trunc((aLblLine.Width - TextEndPix) / 2);
    TextEndPix := TextStrPix + TextEndPix + 3;
    TextStrPix := TextStrPix - 3;

    if MaskStrPix < TextStrPix then
    begin
      TextEndPix := TextEndPix - (TextStrPix - MaskStrPix);
      TextStrPix := MaskStrPix;
    end;
    

    aLblHint.Top := aLblLine.Top + 12;
    aLblHint.Left := aLblLine.Left + TextStrPix + 4;

    aLblLine.Repaint;
    aLblLine.Canvas.Pen.Color := aLineColor;
    DrawLine(MaskStrPix, 3, TextStrPix, 12);
    DrawLine(MaskEndPix, 3, TextEndPix, 12);
  end;
end;

end.
