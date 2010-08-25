unit bkBranding;
//------------------------------------------------------------------------------
{
   Title:         Branding Unit

   Description:   Holds all branding constants etc

   Author:        Matthew Hopkins  March 2005

   Remarks:       holds vars for colors, graphics, titles used in banklink
                  split from globals to make rebranding easier

   Revisions:

}
//------------------------------------------------------------------------------

interface
uses
  Windows, Graphics;

type
  TImageSet = ( imPractice, imBooks, imOther);

var
  Is256Color : boolean;
  MainFormBackgroundColor : TColor;
  AlternateCodingLineColor : TColor;
  HeaderBackgroundColor : TColor;
  GSTAlternateLineColor : TColor;
  BrandingImageSet : TImageSet;

  function CodingBanner : TPicture;
  function BannerLogo : TPicture;
  function BackgroundImage : TPicture;
  function AboutImage : TPicture;

  function ColorNoData: Integer;
  function TextNoData: string;
  function ColorDownloaded: Integer;
  function TextDownloaded: string;
  function ColorUncoded: Integer;
  function TextUncoded: string;
  function ColorCoded: Integer;
  function TextCoded: string;
  function ColorTransferred: Integer;
  function TextTransferred: string;
  function ColorFinalised: Integer;
  function TextFinalised: string;
  function ColorCodingPeriod: Integer;
  function ColorFinancialYear: Integer;

  function GroupBackGroundStartColor: Integer;
  function GroupBackGroundStopColor: Integer;

  function TobBarStartColor: Integer;
  function TopBarStopColor: Integer;
  function TopTitleColor: Integer;

  procedure InitialiseGraphicsAndColors( CanvasHandleToTest : hDC);

const

  // From Banklink Brandiguide.pdf
  // R: 0, G:157, B: 160   Makes :
  BKHICOLOR_TEAL      = $00A09D00;
  //was BKHICOLOR_TEAL = $009F9B00;  //banklink teal coding,dissect etc
  BKCOLOR_TEAL        = $00808000;

  BKHICOLOR_LOGOBLUE  = $009A5B00;  //banklink LOGO Blue
  BKCOLOR_LOGOBLUE    = $00800000;  //banklink LOGO Blue

  ProcessCornerRadius = 5;

implementation

uses
  WinUtils, ImagesFrm;

const
  BKHICOLOR_BLUE      = $00F5EDDE;  //alt line col for coding, dissect etc

  BKHICOLOR_GREEN     = $00EAFFEF;  //gst alternate line color
  BKCOLOR_GREEN       = clLtGray;

  BKHICOLOR_LTPINK    = $00F3F2FF;
  BKHICOLOR_MIDPINK   = $00E2DFFF;

  BKCOLOR_CODING      = $00A0E0FE;
  BKHICOLOR_CODING    = $00A0E0FE;

  BKCOLOR_FINANCIAL   = $00FBF2A0;
  BKHICOLOR_FINANCIAL = $00FBF2A0;


procedure InitialiseGraphicsAndColors( CanvasHandleToTest : hDC);
begin
  Is256Color := WinUtils.GetScreenColors( CanvasHandleToTest) <= 256;
  //Is256Color := true;

  {$IFDEF SmartLink}
  if Is256Color then
  begin
    MainFormBackgroundColor := clMaroon;
    AlternateCodingLineColor := BKHICOLOR_LTPINK;
    HeaderBackgroundColor := clMaroon;
    GSTAlternateLineColor := BKCOLOR_GREEN;
  end
  else
  begin
    MainFormBackgroundColor := clMaroon;
    AlternateCodingLineColor := BKHICOLOR_LTPINK;
    HeaderBackgroundColor := clMaroon;
    GSTAlternateLineColor := BKHICOLOR_GREEN;
  end;
  {$ELSE}
  if Is256Color then
  begin
    MainFormBackgroundColor := BKCOLOR_TEAL;
    AlternateCodingLineColor := BKCOLOR_GREEN;
    HeaderBackgroundColor := BKCOLOR_TEAL;
    GSTAlternateLineColor := BKCOLOR_GREEN;
  end
  else
  begin
    MainFormBackgroundColor := BKHICOLOR_TEAL;
    AlternateCodingLineColor := BKHICOLOR_BLUE;
    HeaderBackgroundColor := BKHICOLOR_TEAL;
    GSTAlternateLineColor := BKHICOLOR_GREEN;
  end;
  {$ENDIF}
end;

function CodingBanner : TPicture;
begin
{$IFDEF SmartLink}
  if Is256Color then
    result := AppImages.imgBannerRight256.Picture
  else
    result := AppImages.imgBannerRightHiColor.Picture;
{$ELSE}
  if BrandingImageSet = imPractice then
  begin

    if Is256Color then
      result := AppImages.imgBannerRight256.Picture
    else
      result := AppImages.imgBannerRightHiColor.Picture;
  end
  else
  begin
    if Is256Color then
      result := AppImages.imgBooksBanner_256.Picture
    else
      result := AppImages.imgBooksBanner_HiColor.Picture;
  end;
{$ENDIF}
end;

function BannerLogo : TPicture;
begin
  if Is256Color then
    result := AppImages.imgBankLinkLogo256.Picture
  else
    result := AppImages.imgBankLinkLogoHiColor.Picture;
end;

function BackgroundImage : TPicture;
begin
  {$IFDEF SmartLink}
  //no background image for SmartLink
  result := nil;
  {$ELSE}
  if BrandingImageSet = imPractice then
    result := AppImages.imgBackgroundImage.Picture
  else
    result := AppImages.imgBackgroundImage_Books.Picture;
  {$ENDIF}
end;

function AboutImage : TPicture;
begin
  if Is256Color then
    result := nil //AppImages.imgAbout256.Picture
  else
{$IFDEF SmartLink}
    result := AppImages.imgAboutHiColor.Picture;
{$ELSE}
    if BrandingImageSet = imPractice then
      result := AppImages.imgAboutHiColor.Picture
    else
      result := AppImages.imgAboutHiColor_Books.picture;
{$ENDIF}
end;

function ColorNoData: Integer;
begin
  if Is256Color then
    Result := clWhite
  else
    Result := clWhite;
end;

function TextNoData: string;
begin
  Result := Chr(429);
end;

function ColorDownloaded: Integer;
begin
  if Is256Color then
    Result := clYellow
  else
    Result := clYellow;
end;

function TextDownloaded: string;
begin
  Result := 'A';   //Available
end;

function ColorUncoded: Integer;
begin
   //Result := ClRed;

  if Is256Color then
    Result := clRed
  else
    Result := clWebOrangeRed;

end;

function TextUncoded: string;
begin
  Result := 'U';
end;

function ColorCoded: Integer;
begin
//  Result := clGreen;

  if Is256Color then
    Result := clGreen
  else
    Result :=  clWebLawnGreen;

end;

function TextCoded: string;
begin
  Result := 'C';
end;

function ColorTransferred: Integer;
begin
  Result := clWebPurple;
  {
  if Is256Color then
    Result := clYellow
  else
    //Result := clWebYellow;
    Result :=  clWebLightPink;
   }
end;

function TextTransferred: string;
begin
  Result := 'T';
end;

function ColorFinalised: Integer;
begin
  Result := clWebDodgerBlue;
  {
  if Is256Color then
    Result := clAqua
  else
    Result := clWebSkyBlue;
    }
end;

function TextFinalised: string;
begin
  Result := 'F';
end;

function ColorCodingPeriod: Integer;
begin
  if Is256Color then
    Result := BKCOLOR_CODING
  else
    Result := BKHICOLOR_CODING;
end;


function ColorFinancialYear: Integer;
begin
  if Is256Color then
    Result := BKCOLOR_FINANCIAL
  else
    Result := BKHICOLOR_FINANCIAL;
end;

function TobBarStartColor: Integer;
begin
  if Is256Color then
    Result := MainFormBackgroundColor
  else
    Result := clWhite;
end;

function TopBarStopColor: Integer;
begin
   Result := MainFormBackgroundColor;
end;

function TopTitleColor: Integer;
begin
   if Is256Color then
      Result := clWhite
   else
      Result :=  BKCOLOR_LOGOBLUE {BKHICOLOR_LOGOBLUE};
end;


function GroupBackGroundStartColor: Integer;
begin
  if Is256Color then
      Result := clltGray
   else
      Result := 16777194;  
     // Result := $00FFFB4A;
  //Result := clWhite ;
  //Result := IniColor('Back Color Start',14412523);
end;

function GroupBackGroundStopColor: Integer;
begin
   if Is256Color then
      Result := clltGray
   else
      Result := BKHICOLOR_TEAL;
   //Result := IniColor('Back Color Stop',10525952);
end;

initialization
  Is256Color := false;
  BrandingImageSet := imOther;


end.
