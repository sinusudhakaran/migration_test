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
  Controls, StdCtrls, Globals, RzButton, Menus, bkProduct, ovctable,
  ovctchdr, VirtualTrees, RzGroupBar;

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
  function SelectionColor: integer;
  function GridHEADER : integer;

  function GroupBackGroundStartColor: Integer;
  function GroupBackGroundStopColor: Integer;

  function BannerColor: Integer;
  function BannerTextColor: Integer;
  function TobBarStartColor: Integer;
  function TopBarStopColor: Integer;
  function TopTitleColor: Integer;
  function BankLinkColor: Integer;
  function BankLinkHighlightColor: Integer;
  function BankLinkNearWhiteColor: Integer;

  procedure InitialiseGraphicsAndColors( CanvasHandleToTest : hDC);

  function LoginScreenBanner: TPicture;
  function SplashScreenBanner: TPicture;
  function TopBannerImage: TPicture;
  function DownloadDiskImageBanner: TPicture;
  function ProductIcon32x32: TPicture;
  function ProductIcon16x16: TPicture;
  function ReportLogo: TPicture;

  procedure StyleMainBannerLogo(Image: TImage);
  procedure StyleMainBannerCustomLogo(Image: TImage);
  procedure StyleTopBannerRightImage(Image: TImage);
  procedure StyleMainBannerPanel(Panel: TRzPanel);
  procedure StyleLoginImage(Image: TImage);
  procedure StyleLoginBannerPanel(Panel: TPanel);
  procedure StyleLoginVersionText(VersionLabel: TLabel);
  procedure StyleBannerText(Text: TLabel);
  procedure StyleBConnectBannerPanel(Panel: TPanel);
  procedure StyleBConnectBannerImage(Image: TImage);
  procedure StyleBooksBackgroundLogo(Image: TImage);
  procedure StyleBooksBackgroundImage(Image: TImage);
  procedure StyleBooksClientName(ClientName: TLabel);
  procedure StyleBooksVersionLabel(VersionLabel: TLabel);
  procedure StyleSimpleUIBannerPanel(Panel: TRzPanel);
  procedure StyleSimpleUILeftBannerImage(Image: TImage);
  procedure StyleSimpleUIRightBannerImage(Image: TImage);
  procedure StyleBankLinkButton(Button: TRzToolButton);
  procedure StyleECFHOnlineMenuItem(MenuItem: TMenuItem);
  procedure StyleNewClientWizardLogo(Image: TImage);
  procedure StyleTransRangeText(TransRangeLabel: TLabel);
  procedure StyleFinalizedText(FinalizedText: TLabel);
  procedure StyleBudgetStartText(StartText: TLabel);
  procedure StyleBudgetAllExclusiveText(AllExclusiveText: TLabel);
  procedure StyleBudgetReminderNote(ReminderNoteText: TLabel);
  procedure StyleAltRowColor(var aLineColor : integer);
  procedure StyleTableHeading(aTableHeader: TOvcTCColHead);
  procedure StyleGroupBar(aGroupBar : TRzGroupBar);

  procedure StyleSelectionColor(aStringTree : TVirtualStringTree);
  procedure StyleOvcTableGrid(aOVCTable: TOvcTable);

  function AddAltKeySymbol(aInString : string; aPos : integer) : string;

  function BrandName: string;
  function ProductOnlineName: String;
  function BooksProductName: String;
  function NotesProductName: String;
  function NotesOnlineProductName: String;
  function BConnectName: String;
  function PracticeProductName: String;

const

  // From Banklink Brandiguide.pdf
  // R: 0, G:157, B: 160   Makes :
  BKHICOLOR_TEAL      = $00A09D00;
  //was BKHICOLOR_TEAL = $009F9B00;  //banklink teal coding,dissect etc
  BKCOLOR_TEAL        = $00808000;

  BKHICOLOR_LOGOBLUE  = $009A5B00;  //banklink LOGO Blue
  BKCOLOR_LOGOBLUE    = $00800000;  //banklink LOGO Blue

  BKSIMPLEUI_FRAME_COLOR = $00464646;
  DATA_LED_OUTLINE       = $00D6D6D6;

  ProcessCornerRadius = 5;

implementation

uses
  WinUtils,
  ImagesFrm,
  ThirdPartyHelper,
  bkConst;

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

  SELECTED_CELL        = $00995A00;
  BUDGET_COLOR_ROW     = $00F0F0F0;
  Grid_HEADER          = $00EAEAEA;

  DATA_LED_NODATA      = $00FFFFFF;
  DATA_LED_AVAILABLE   = $0053D1D1;
  DATA_LED_UNCODED     = $002644CE;
  DATA_LED_CODED       = $004CA258;
  DATA_LED_FINALIZED   = $00A28E4C;
  DATA_LED_TRANSFERRED = $0088396C;

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
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := DATA_LED_TRANSFERRED;
  end
  else
  begin
    Result := clWebPurple;
  end;
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

function SelectionColor: integer;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
    Result := SELECTED_CELL
  else
    Result := clHighLight;
end;

function GridHEADER : integer;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
    Result := Grid_HEADER
  else
    Result := clGray;
end;

function BannerColor: Integer;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := RGB(255, 255, 255);
  end
  else
  begin
    Result := MainFormBackgroundColor;
  end;
end;

function BannerTextColor: Integer;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := RGB(0, 55, 122);
  end
  else
  begin
    Result := clWhite;
  end;
end;

function TobBarStartColor: Integer;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
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
  if TProduct.ProductBrand = btMYOBBankLink then
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
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := BannerTextColor;
  end
  else
  begin
   if Is256Color then
      Result := clWhite
   else
      Result :=  BKCOLOR_LOGOBLUE {BKHICOLOR_LOGOBLUE};
  end;
end;

function BankLinkColor: Integer;
begin
  Result := $009A5B00;
end;

function BankLinkHighlightColor: Integer;
begin
  Result := $00CA8B00;
end;

function BankLinkNearWhiteColor: Integer;
begin
  Result := $00E9D8C0;
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
  if TProduct.ProductBrand = btMYOBBankLink then
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
  if TProduct.ProductBrand = btMYOBBankLink then
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
  if TProduct.ProductBrand = btMYOBBankLink then
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
  if TProduct.ProductBrand = btMYOBBankLink then
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

function ProductIcon32x32: TPicture;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := AppImages.imgBankstreamIcon.Picture;
  end
  else
  begin
    Result := AppImages.imgBankLinkB.Picture;
  end;
end;

function ProductIcon16x16: TPicture;
begin
  Result := AppImages.imgBankstreamIcon16x16.Picture;
end;

function ReportLogo: TPicture;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Result := AppImages.imgReports.Picture;
  end
  else
  begin
    Result := AppImages.imgBankLinkLogoWhiteBkgnd.Picture;
  end;
end;

procedure StyleMainBannerLogo(Image: TImage);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Image.Visible := True;
    Image.Margins.Top := 0;
    Image.Margins.Bottom := 0;
    Image.Center := True;
    Image.Proportional := False;
    Image.Picture := TopBannerImage;
    Image.Align := alRight;
  end
  else
  begin
    Image.Picture := TopBannerImage;
  end;
end;

procedure StyleMainBannerCustomLogo(Image: TImage);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Image.Visible := True;
    Image.Align := alLeft;
    Image.Proportional := True;
    Image.Center := True;
    Image.Margins.Top := 0;
    Image.Margins.Bottom := 0;
  end
  else
  begin
    Image.Transparent := True;
    Image.Picture := CodingBanner;
  end;
end;

procedure StyleTopBannerRightImage(Image: TImage);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    StyleMainBannerLogo(Image);
  end
  else
  begin
    Image.Picture := CodingBanner;
  end;
end;

function BrandName: string;
begin
  Result := BRAND_FULL_NAME;
end;

function ProductOnlineName: String;
begin
  Result := BRAND_ONLINE;
end;

function PracticeProductName: String;
begin
  Result := BRAND_PRACTICE;
end;

procedure StyleMainBannerPanel(Panel: TRzPanel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Panel.Color := BannerColor;
    Panel.VisualStyle := vsClassic;
    Panel.Height := 40;
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
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Image.AutoSize := True;
    Image.Align := alLeft;
  end;

  Image.Picture := LoginScreenBanner;
end;

procedure StyleLoginBannerPanel(Panel: TPanel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Panel.ParentBackground := False;
    Panel.Color := BannerColor;
  end;
end;

procedure StyleLoginVersionText(VersionLabel: TLabel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    VersionLabel.Font.Color := BannerTextColor;
  end;
end;

procedure StyleBConnectBannerPanel(Panel: TPanel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    StyleLoginBannerPanel(Panel);
  end;
end;

procedure StyleBannerText(Text: TLabel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Text.Font.Color := BannerTextColor;
  end;  
end;

procedure StyleBConnectBannerImage(Image: TImage);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Image.Margins.Top := 0;
    Image.Margins.Bottom := 0;
    Image.Margins.Left := 0;
    Image.Margins.Right := 0;
    Image.Proportional := False;
    Image.Center := True;
    Image.Visible := True;
    Image.Align := alLeft;
  end;
end;

procedure StyleBooksBackgroundLogo(Image: TImage);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Image.visible := false;
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
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Image.Picture := AppImages.imgMainBackground.Picture;
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
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    ClientName.Font.Color := BankLinkColor;
    ClientName.Font.Size  := 15;
  end;
end;

procedure StyleBooksVersionLabel(VersionLabel: TLabel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    VersionLabel.Font.Color := BannerTextColor;
  end;
end;

procedure StyleSimpleUIBannerPanel(Panel: TRzPanel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    StyleMainBannerPanel(Panel);
  end
  else
  begin
    Panel.GradientColorStart := clWhite;
    Panel.GradientColorStop  := clGray;
  end;
end;

procedure StyleSimpleUILeftBannerImage(Image: TImage);
begin
  StyleMainBannerLogo(Image); 
end;

procedure StyleSimpleUIRightBannerImage(Image: TImage);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Image.Visible := False;
  end
  else
  begin
   Image.Transparent := True;
   Image.Picture := ClientBanner;
  end;
end;

procedure StyleBankLinkButton(Button: TRzToolButton);
begin
  Button.Caption := ProductOnlineName;

  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Button.ImageIndex := 34;
  end;
end;

procedure StyleECFHOnlineMenuItem(MenuItem: TMenuItem);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    MenuItem.ImageIndex := 34;
  end;
end;

procedure StyleNewClientWizardLogo(Image: TImage);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    Image.Left := 13;
    Image.Top := 54;
    Image.Width := 180;
    Image.Height := 35;
    Image.Stretch := false;
    Image.Picture := AppImages.ImgLogoMedium.Picture;
  end
  else
  begin
    Image.Picture := ProductIcon32x32;
  end;
end;

procedure StyleTransRangeText(TransRangeLabel: TLabel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    TransRangeLabel.Font.Color := BannerTextColor;
  end
  else
  begin
    TransRangeLabel.Font.Color := clWhite;
  end;
end;

procedure StyleFinalizedText(FinalizedText: TLabel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    FinalizedText.Font.Color := BannerTextColor;
  end
  else
  begin
    FinalizedText.Font.Color := clWhite;
  end;
end;

procedure StyleBudgetStartText(StartText: TLabel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    StartText.Font.Color := BannerTextColor;
  end
  else
  begin
    StartText.Font.Color := clWhite;
  end;  
end;

procedure StyleBudgetAllExclusiveText(AllExclusiveText: TLabel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    AllExclusiveText.Font.Color := BannerTextColor;
  end
  else
  begin
    AllExclusiveText.Font.Color := clWhite;
  end;
end;

procedure StyleBudgetReminderNote(ReminderNoteText: TLabel);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    ReminderNoteText.Font.Color := BannerTextColor;
  end
  else
  begin
    ReminderNoteText.Font.Color := clWhite;
  end;
end;

procedure StyleOvcTableGrid(aOVCTable: TOvcTable);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    aOVCTable.Colors.ActiveFocused := SELECTED_CELL;
    aOVCTable.Colors.ActiveFocusedText := clWhite;
    aOVCTable.Colors.Locked := GridHEADER;
    aOVCTable.Colors.LockedText := clBlack;
  end;
end;

procedure StyleTableHeading(aTableHeader: TOvcTCColHead);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    aTableHeader.Color := Grid_HEADER;
    aTableHeader.SortArrowColor := clblack;
    aTableHeader.SortArrowFillColor := clblack;
  end;
end;


procedure StyleGroupBar(aGroupBar : TRzGroupBar);
var
  GroupIndex : integer;
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    aGroupBar.GradientColorStart := BankLinkColor;
    aGroupBar.GradientColorStop  := BankLinkColor;

    for GroupIndex := 0 to aGroupBar.GroupCount - 1 do
    begin
      aGroupBar.Groups[GroupIndex].CaptionColorStart := BankLinkNearWhiteColor;
      aGroupBar.Groups[GroupIndex].CaptionColorStop  := BankLinkNearWhiteColor;
      aGroupBar.Groups[GroupIndex].CaptionFont.Color := BankLinkColor;
      aGroupBar.Groups[GroupIndex].CaptionHotColor   := BankLinkColor;

      aGroupBar.Groups[GroupIndex].Font.Color     := BankLinkColor;
      aGroupBar.Groups[GroupIndex].SelectionColor := BankLinkColor;
      aGroupBar.Groups[GroupIndex].ItemHotColor   := BankLinkColor;
    end;
  end
  else
  begin
    aGroupBar.GradientColorStop := bkBranding.GroupBackGroundStopColor;
    aGroupBar.GradientColorStart := bkBranding.GroupBackGroundStartColor;
  end;
end;

procedure StyleAltRowColor(var aLineColor : integer);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
    aLineColor := BUDGET_COLOR_ROW
  else
    aLineColor := BKCOLOR_CREAM;
end;

procedure StyleSelectionColor(aStringTree : TVirtualStringTree);
begin
  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    aStringTree.Colors.SelectionRectangleBlendColor  := SELECTED_CELL;
    aStringTree.Colors.SelectionRectangleBorderColor := SELECTED_CELL;
    aStringTree.Colors.FocusedSelectionColor         := SELECTED_CELL;
    aStringTree.Colors.FocusedSelectionBorderColor   := SELECTED_CELL;
  end;
end;

function AddAltKeySymbol(aInString : string; aPos : integer) : string;
const
  AT_ALT_SYMBOL = '&';
begin
  if aPos > 1 then
    Result := leftstr(aInString, (aPos-1)) + AT_ALT_SYMBOL + Rightstr(aInString, Length(aInString) - (aPos-1))
  else
    Result := AT_ALT_SYMBOL + Rightstr(aInString, Length(aInString) - (aPos-1));
end;

function BooksProductName: String;
begin
  Result := BRAND_BOOKS;
end;

function NotesProductName: String;
begin
  Result := BRAND_NOTES;
end;

function NotesOnlineProductName: String;
begin
  Result := BRAND_NOTES_ONLINE;
end;

function BConnectName: String;
begin
  Result := BRAND_SECURE;
end;

initialization
  Is256Color := false;
  BrandingImageSet := imOther;
  //look for branding dll

end.

