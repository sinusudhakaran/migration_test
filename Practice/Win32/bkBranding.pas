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
  Windows, Graphics, StrUtils, SysUtils, ExtCtrls, RzPanel, RzCommon,
  Controls, StdCtrls, Globals, RzButton, Menus;

type
  TImageSet = ( imPractice, imBooks, imOther, imDLL);

var
  Is256Color : boolean;
  MainFormBackgroundColor : TColor;
  AlternateCodingLineColor : TColor;
  HeaderBackgroundColor : TColor;
  GSTAlternateLineColor : TColor;
  BrandingImageSet : TImageSet;

  function ClientBanner : TPicture;
  function CodingBanner : TPicture;
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

  function BannerColor: Integer;
  function TobBarStartColor: Integer;
  function TopBarStopColor: Integer;
  function TopTitleColor: Integer;
  
  procedure InitialiseGraphicsAndColors( CanvasHandleToTest : hDC);

  function LoginScreenBanner: TPicture;
  function SplashScreenBanner: TPicture;
  function TopBannerImage: TPicture;
  function DownloadDiskImageBanner: TPicture;
  function BankstreamLogo: TPicture;

  procedure StyleTopLeftImage(Image: TImage);
  procedure StyleTopRightImage(Image: TImage);
  procedure StyleMainBannerPanel(Panel: TRzPanel);
  procedure StyleLoginImage(Image: TImage);
  procedure StyleLoginBannerPanel(Panel: TPanel);
  procedure StyleLoginVersionText(VersionLabel: TLabel);
  procedure StyleBConnectBannerPanel(Panel: TPanel);
  procedure StyleBConnectBannerImage(Image: TImage);
  procedure StyleBooksBackgroundLogo(Image: TImage);
  procedure StyleBooksBackgroundImage(Image: TImage);
  procedure StyleBooksClientName(ClientName: TLabel);
  procedure StyleBooksVersionLabel(VersionLabel: TLabel);
  procedure StyleSimpleUIBannerPanel(Panel: TRzPanel);
  procedure StyleSimpleUIRightBannerImage(Image: TImage);
  procedure StyleBankLinkButton(Button: TRzToolButton);
  procedure StyleECFHOnlineMenuItem(MenuItem: TMenuItem);


  function ProductName: String;
  function ProductLiveName: String;
  function BKBooksProductName: String;
  function ECodingDisplayName: String;
  function NotesOnlineProductName: String;
  function BConnectName: String;

  function Rebrand(Value: String): String;

  function GetProductBrand: TBrandType;
  
const

  // From Banklink Brandiguide.pdf
  // R: 0, G:157, B: 160   Makes :
  BKHICOLOR_TEAL      = $00A09D00;
  //was BKHICOLOR_TEAL = $009F9B00;  //banklink teal coding,dissect etc
  BKCOLOR_TEAL        = $00808000;

  BKHICOLOR_LOGOBLUE  = $009A5B00;  //banklink LOGO Blue
  BKCOLOR_LOGOBLUE    = $00800000;  //banklink LOGO Blue

  BKSIMPLEUI_FRAME_COLOR = $00464646;

  ProcessCornerRadius = 5;

implementation

uses
  WinUtils, ImagesFrm, ThirdPartyHelper, bkConst;

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

function GetProductBrand: TBrandType;
begin
  Result := ProductBrand;
end;

procedure InitialiseGraphicsAndColors( CanvasHandleToTest : hDC);
begin
  Is256Color := WinUtils.GetScreenColors( CanvasHandleToTest) <= 256;
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
end;

function ClientBanner : TPicture;
begin
  if BrandingImageSet = imPractice then
  begin
     if Is256Color then
        result := AppImages.imgBannerRight256.Picture
     else
        result := AppImages.imgBannerRightHiColor.Picture;
     exit;
  end;

  //use the coding banner from third party dll if set
  if BrandingImageSet = imDLL then
  begin
    if ThirdPartyHelper.ThirdPartyBannerLogo <> nil then
    begin
      result := ThirdPartyHelper.ThirdPartyBannerLogo;
      exit;
    end
  end;

  //default to books
  if Is256Color then
    result := AppImages.imgBooksBanner_256.Picture
  else
    result := AppImages.imgBooksBanner_HiColor.Picture;
end;


function CodingBanner : TPicture;
begin
  if BrandingImageSet = imPractice then
  begin
     if Is256Color then
        result := AppImages.imgBannerRight256.Picture
     else
        result := AppImages.imgBannerRightHiColor.Picture;
     exit;
  end;

  //use the coding banner from third party dll if set
  if BrandingImageSet = imDLL then
  begin
    if ThirdPartyHelper.ThirdPartyCodingLogo <> nil then
    begin
      result := ThirdPartyHelper.ThirdPartyCodingLogo;
      exit;
    end
  end;

  //default to books
  if Is256Color then
    result := AppImages.imgBooksBanner_256.Picture
  else
    result := AppImages.imgBooksBanner_HiColor.Picture;
end;

function BackgroundImage : TPicture;
begin
  if BrandingImageSet = imPractice then
    result := AppImages.imgBackgroundImage.Picture
  else
    result := AppImages.imgBackgroundImage_Books.Picture;
end;

function AboutImage : TPicture;
begin
  result := nil;
  if Is256Color then
    exit;

  if BrandingImageSet = imPractice then
  begin
    result := AppImages.imgAboutHiColor.Picture;
    exit;
  end;

  //use the coding banner from third party dll if set
  if (BrandingImageSet = imDLL) and (ThirdPartyHelper.ThirdPartyAboutLogo <> nil) then
  begin
    result := ThirdPartyHelper.ThirdPartyAboutLogo;
    exit;
  end;

  result := AppImages.imgAboutHiColor_Books.picture;
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
end;

function TextTransferred: string;
begin
  Result := 'T';
end;

function ColorFinalised: Integer;
begin
  Result := clWebDodgerBlue;
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

function BannerColor: Integer;
begin
  if GetProductBrand = btBankstream then
  begin
    Result := RGB(0,55,122);
  end
  else
  begin
    Result := MainFormBackgroundColor;
  end;
end;

function TobBarStartColor: Integer;
begin
  if GetProductBrand = btBankstream then
  begin
    Result := BannerColor;
  end
  else
  begin
    if Is256Color then
      Result := MainFormBackgroundColor
    else
      Result := clWhite;
  end;
end;

function TopBarStopColor: Integer;
begin
  if GetProductBrand = btBankstream then
  begin
    Result := BannerColor;
  end
  else
  begin
    Result := MainFormBackgroundColor;
  end;
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
end;

function GroupBackGroundStopColor: Integer;
begin
   if Is256Color then
      Result := clltGray
   else
      Result := BKHICOLOR_TEAL;
end;

function LoginScreenBanner: TPicture;
begin
  if GetProductBrand = btBankstream then
  begin
    Result := AppImages.imgBankstreamLogin.Picture;
  end
  else
  begin
    Result := AppImages.imgLogin.Picture;
  end;
end;

function SplashScreenBanner: TPicture;
begin
  if GetProductBrand = btBankstream then
  begin
    Result := AppImages.imgBankstreamLogin.Picture;
  end
  else
  begin
    Result := AppImages.imgBankstreamLogin.Picture;
  end;
end;

function TopBannerImage: TPicture;
begin
  if GetProductBrand = btBankstream then
  begin
    Result := AppImages.imgClientHomePageLogo.Picture;
  end
  else
  begin
    Result := AppImages.imgLogo.Picture;
  end;
end;

function DownloadDiskImageBanner: TPicture;
begin
  if GetProductBrand = btBankstream then
  begin
    if Is256Color then
    begin
      Result := AppImages.imgDownloadBankstreamLogo.Picture;
    end
    else
    begin
      Result := AppImages.imgDownloadBankstreamLogo.Picture;
    end;
  end
  else
  begin
    if Is256Color then
    begin
      Result := AppImages.imgBankLinkLogo256.Picture;
    end
    else
    begin
      Result := AppImages.imgBankLinkLogoHiColor.Picture;
    end;
  end;
end;

function BankstreamLogo: TPicture;
begin
  if GetProductBrand = btBankstream then
  begin
    Result := AppImages.imgBankstreamIcon.Picture;
  end
  else
  begin
    Result := AppImages.imgBankLinkB.Picture;
  end;
end;

procedure StyleTopLeftImage(Image: TImage);
begin
  if GetProductBrand = btBankstream then
  begin
    Image.Margins.Top := 0;
    Image.Margins.Bottom := 0;
    Image.Margins.Left := 0;
    Image.Margins.Right := 0;
    Image.Proportional := False;
    Image.Center := True;
    Image.Visible := True;
    Image.Align := alRight;
  end;

  Image.Picture := TopBannerImage;
end;

procedure StyleTopRightImage(Image: TImage);
begin
  if GetProductBrand = btBankstream then
  begin
    Image.Visible := False;
    Image.Margins.Top := 0;
    Image.Margins.Bottom := 0;
    Image.Center := True;
    Image.Align := alLeft;
  end
  else
  begin
    Image.Transparent := True;
    Image.Picture := CodingBanner;
  end;
end;

function ProductName: String;
begin
  if GetProductBrand = btBankstream then
  begin
    Result := 'Bankstream';
  end
  else
  begin
    Result := 'BankLink';
  end;
end;

function ProductLiveName: String;
begin
  Result := Format('%s Online', [ProductName]);
end;

procedure StyleMainBannerPanel(Panel: TRzPanel);
begin
  if GetProductBrand = btBankstream then
  begin
    Panel.Color := BannerColor;
    Panel.VisualStyle := vsClassic;
  end
  else
  begin
    Panel.Height := CodingBanner.Height;
    Panel.GradientColorStart := clWhite;
    Panel.GradientColorStop := BannerColor;
  end;
end;

procedure StyleLoginImage(Image: TImage);
begin
  if GetProductBrand = btBankstream then
  begin
    Image.AutoSize := True;
    Image.Align := alRight;
  end;

  Image.Picture := LoginScreenBanner;
end;

procedure StyleLoginBannerPanel(Panel: TPanel);
begin
  if GetProductBrand = btBankstream then
  begin
    Panel.ParentBackground := False;
    Panel.Color := BannerColor;
  end;
end;

procedure StyleLoginVersionText(VersionLabel: TLabel);
begin
  if GetProductBrand = btBankstream then
  begin
    VersionLabel.Align := alLeft;
  end;
end;

procedure StyleBConnectBannerPanel(Panel: TPanel);
begin
  if GetProductBrand = btBankstream then
  begin
    StyleLoginBannerPanel(Panel);
  end;
end;

procedure StyleBConnectBannerImage(Image: TImage);
begin
  if GetProductBrand = btBankstream then
  begin
    Image.Margins.Top := 0;
    Image.Margins.Bottom := 0;
    Image.Margins.Left := 0;
    Image.Margins.Right := 0;
    Image.Proportional := False;
    Image.Center := True;
    Image.Visible := True;
    Image.Align := alRight;
  end;
end;

procedure StyleBooksBackgroundLogo(Image: TImage);
begin
  if GetProductBrand = btBankstream then
  begin
    Image.Picture := AppImages.imgMainBackgroundLogo.Picture;
  end
  else
  begin
    if Is256Color then
      Image.Picture := AppImages.imgBankLinkLogo256.Picture
    else
      Image.Picture := AppImages.imgBankLinkLogoHiColor.Picture;
  end;  
end;

procedure StyleBooksBackgroundImage(Image: TImage);
begin
  if GetProductBrand = btBankstream then
  begin
    Image.Visible := False;
  end
  else
  begin
    if ( bkBranding.BackgroundImage <> nil) then
    begin
      Image.Picture := BackgroundImage;
    end;
  end;
end;

procedure StyleBooksClientName(ClientName: TLabel);
begin
  if GetProductBrand = btBankstream then
  begin
    ClientName.Color := BannerColor;
  end;
end;

procedure StyleBooksVersionLabel(VersionLabel: TLabel);
begin
  if GetProductBrand = btBankstream then
  begin
    VersionLabel.Font.Color := BannerColor;
  end;
end;

procedure StyleSimpleUIBannerPanel(Panel: TRzPanel);
begin
  if GetProductBrand = btBankstream then
  begin
    StyleMainBannerPanel(Panel);
  end
  else
  begin
    Panel.GradientColorStart := clWhite;
    Panel.GradientColorStop  := clGray;
  end;
end;

procedure StyleSimpleUIRightBannerImage(Image: TImage);
begin
  if GetProductBrand = btBankstream then
  begin
    bkBranding.StyleTopRightImage(Image);
  end
  else
  begin
   Image.Transparent := True;
   Image.Picture := ClientBanner;
  end;
end;

procedure StyleBankLinkButton(Button: TRzToolButton);
begin
  Button.Caption := ProductName;

  if GetProductBrand = btBankstream then
  begin
    Button.ImageIndex := 34;
  end;
end;

procedure StyleECFHOnlineMenuItem(MenuItem: TMenuItem);
begin
  if GetProductBrand = btBankstream then
  begin
    MenuItem.ImageIndex := 34;
  end;
end;

function BKBooksProductName: String;
begin
  Result := Format('%s Books', [ProductName]);
end;

function ECodingDisplayName: String;
begin
  Result := Format('%s Notes', [ProductName]);
end;

function NotesOnlineProductName: String;
begin
  Result := Format('%s Notes Online', [ProductName]);
end;
function Rebrand(Value: String): String;
begin
  Result := AnsiReplaceText(Value, 'BankLink', ProductName);
end;

function BConnectName: String;
begin
  Result := Format('%s Secure', [ProductName]);
end;

initialization
  Is256Color := false;
  BrandingImageSet := imOther;
  //look for branding dll

end.
