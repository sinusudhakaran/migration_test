unit About;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ShellAPI, RzBckgnd, jpeg,
  OsFont;

type
  TfrmAbout = class(TForm)
    btnClose: TButton;
    btnEULA: TButton;
    DebugLabel: TLabel;
    imgAbout: TImage;
    lblCode: TLabel;
    lblCopyright: TLabel;
    lblCountry: TLabel;
    lblCountry1: TLabel;
    lblCountry2: TLabel;
    lblDir: TLabel;
    lblEmail: TLabel;
    lblEmailTo: TLabel;
    lblForSupport: TLabel;
    lblPh1: TLabel;
    lblPh2: TLabel;
    lblServer: TLabel;
    lblTitle: TLabel;
    lblUser: TLabel;
    lblVersion: TLabel;
    lblWebPage: TLabel;
    lblWinVer: TLabel;
    pnlBankLink: TPanel;
    pnlDetails: TPanel;
    pnlGraphic: TPanel;
    btnEULA2: TButton;
    pnlBankstream: TPanel;
    Label1: TLabel;
    lblBankstreamPh1: TLabel;
    lblBankstreamEmailTo: TLabel;
    lblBankstreamWebpage: TLabel;
    lblBankstreamEmail: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnEULAClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lblEmailToClick(Sender: TObject);
    procedure lblWebPageClick(Sender: TObject);
    procedure lblBankstreamWebpageClick(Sender: TObject);
    procedure lblBankstreamEmailToClick(Sender: TObject);
  private
    { Private declarations }
    ShellCommand_Web : string;
  public
    { Public declarations }
  end;

var
  frmAbout: TfrmAbout;

//******************************************************************************
implementation
{$R *.DFM}
uses
   bkProduct,
   bkConst,
   GlobalCache,
   Globals,
   winutils,
   mimeUtils,
   bkUtil32,
   BKDEFS, upgConstants, LicenseDlg, ThirdPartyHelper,
   bkUrls,
   bkContactInformation, bkBranding;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAbout.FormCreate(Sender: TObject);
var
   WebSiteAddress : string;

   ContactName    : string;
   ContactPhone   : string;
   ContactEmail   : string;

begin
   Caption := 'About ' + ShortAppName;

   SetHyperlinkFont(lblEmailTo.Font);
   SetHyperlinkFont(lblWebPage.Font);
   SetHyperlinkFont(lblBankstreamEmailTo.Font);
   SetHyperlinkFont(lblBankstreamWebPage.Font);


//   lblWinVer.Font.Color := clHighLight;
//   lblUser.Font.Color := clHighLight;
//   lblDir.Font.Color := clHighLight;
//   lblCode.Font.Color := clHighLight;
//   lblserver.Font.Color := clHighLight;

   lblTitle.caption := APPTITLE + ' ' + WinUtils.GetAppYearVersionStr;
   lblVersion.Caption := Format('Version %s', [VersionInfo.GetAppVersionStr]);
   {$IfDef madExcept}
   lblVersion.Caption := lblVersion.Caption + ' [Debug]';
   {$ENDIF}
   lblWinVer.Caption  := WinUtils.GetWinVer;

   lblCopyright.Caption := VersionInfo.LegalCopyright;
//   lblCopyrightName.Caption := COPYRIGHTNAME;

   lblUser.caption      := Format('User Code: %s', [GlobalCache.cache_Current_Username]);
   lblDir.caption       := Format('%s Folder: %s', [SHORTAPPNAME, Uppercase(GLOBALS.DataDir)]);
   lblDir.Hint          := Uppercase(GLOBALS.DataDir);



   if (not Assigned(AdminSystem)) and Assigned(MyClient) then
   begin
    {if MyClient.clFields.clUpdate_Server <> '' then
      lblServer.Caption := 'Update server is ' + MyClient.clFields.clUpdate_Server
    else }
    if MyClient.clFields.clCountry = whAustralia then
      lblServer.Caption := Format('Update Server: %s', [TUrls.DefaultAUCatalogServer])
    else
    if MyClient.clFields.clCountry = whUK then
      lblServer.Caption := Format('Update Server: %s', [TUrls.DefaultUKCatalogServer])
    else
      lblServer.Caption := Format('Update Server: %s', [TUrls.DefaultNZCatalogServer]);
   end
   else
    lblServer.Visible := False;

   if Assigned(AdminSystem) then
     lblCode.Caption := Format('Practice Code: %s', [AdminSystem.fdFields.fdBankLink_Code])
   else
     lblCode.Visible := False;

   lblCountry1.caption  := '';
   lblCountry2.caption  := '';
   lblPh1.caption       := '';
   lblBankstreamPh1.Caption  := '';
   lblPh2.caption       := '';
   lblCountry.caption   := '';



   lblWebPage.Caption   := '';
   ShellCommand_Web     := '';
   lblBankstreamWebPage.Caption   := '';
   lblEmailTo.Caption     := '';
   lblBankstreamEmailTo.Caption := '';


   lblTitle.Font.Name := self.Font.Name;
   lblCountry.Font.Name := self.Font.Name;
   //does admin system exist.. show banklink contact details
   if Assigned( AdminSystem) and ( not CurrUser.HasRestrictedAccess) then begin
      //webpage
      if AdminSystem.fdFields.fdCountry in [ whMin..whMax ] then
      Begin
        lblCountry.Caption  := whShortNames[ AdminSystem.fdFields.fdCountry ];
        lblWebPage.Caption  := TUrls.WebSites[ AdminSystem.fdFields.fdCountry ];
        lblBankstreamWebPage.Caption  := TUrls.WebSites[ AdminSystem.fdFields.fdCountry ];
        ShellCommand_Web    := TUrls.WebSiteURLs[ AdminSystem.fdFields.fdCountry ];
        lblCountry1.caption := whNames[ AdminSystem.fdFields.fdCountry ];
        lblPh1.caption      := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ];
        lblBankstreamPh1.Caption := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ];
      end
      else
      begin
         lblWebPage.visible := false;
         lblbankstreamWebPage.Visible := False;
      end;
   end
   else
   begin
     if ThirdPartyDLLDetected and ( ThirdPartySupportName <> '') then
     begin
       //always display third party contact details
       lblCountry1.caption := ThirdPartySupportName;
       lblPh1.caption      := ThirdPartySupportPhone;
       lblEmailTo.caption  := ThirdPartySupportEmail;
       lblWebPage.caption  := ThirdPartySupportWebsite;

       lblBankstreamPh1.caption      := ThirdPartySupportPhone;
       lblBankstreamEmailTo.caption  := ThirdPartySupportEmail;
       lblBankstreamWebPage.caption  := ThirdPartySupportWebsite;
     end
     else
     //no admin system, show contact details for the accountant
     if Assigned( MyClient) then
     begin
        //show the correct contact details for this client
        GetPracticeContactDetails( MyClient, ContactName, ContactPhone, ContactEmail, WebsiteAddress);
        if ContactName = '' then
          ContactName := 'Your Accountant';

        //update details
        lblCountry1.Caption  := ContactName;
        lblPh1.Caption       := ContactPhone;

        lblBankstreamPh1.caption      := ContactPhone;

        //show practice details as well unless the practice is the contact
        if ContactName <> MyClient.clFields.clPractice_Name then
        begin
          lblCountry2.Caption := MyClient.clFields.clPractice_Name;
          lblPh2.Caption      := MyClient.clFields.clPractice_Phone;
        end;

        //restricted users cannot launch shell commands so dont show email or
        //web site
        if ( not CurrUser.HasRestrictedAccess) then
        begin
          //show web site address
          lblWebPage.Caption := Trim( WebsiteAddress);
          lblBankstreamWebPage.Caption := Trim( WebsiteAddress);
          ShellCommand_Web := LowerCase( WebSiteAddress);
          //show email address
          lblEmailTo.Caption := ContactEmail;
          lblBankstreamEmailTo.Caption := ContactEmail;
        end;
     end
     else begin
       //No admin system, no client file loaded
       lblCountry1.caption := 'Your Accountant';
     end;
   end;
                                                   
   lblWebPage.Visible := ( lblWebPage.Caption <> '');  
   lblEmailTo.Visible   := ( lblEmailTo.Caption <> '');
   lblEmail.Visible := lblEmailTo.Visible;

   lblBankstreamWebPage.Visible := ( lblBankstreamWebPage.Caption <> '');
   lblBankstreamEmailTo.Visible   := ( lblBankstreamEmailTo.Caption <> '');
   lblBankstreamEmail.Visible := lblBankstreamEmailTo.Visible;
{$IFDEF FullDebugMode}
   DebugLabel.Caption := 'FastMM DEBUG MODE';
{$ENDIF}
{$IFDEF SafeDebugMode}
   DebugLabel.Caption := 'SafeMM DEBUG MODE';
{$ENDIF}
  lblForSupport.Font.Style := lblForSupport.Font.Style + [fsBold];

  if TProduct.ProductBrand = btMYOBBankLink then
  begin
    btnEULA2.Visible := True;
    pnlGraphic.Visible := False;
    Width := Width - pnlGraphic.Width;
    pnlBankLink.Visible := True;
  end
  else
  begin
    pnlBankLink.Visible := False;
  end;
  pnlBankstream.Visible := (not pnlBankLink.Visible);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAbout.btnCloseClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAbout.lblWebPageClick(Sender: TObject);
begin
   if ShellCommand_Web <> '' then
      ShellExecute(0, 'open', PChar( ShellCommand_Web), nil, nil, SW_NORMAL);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAbout.FormShow(Sender: TObject);
begin
  if bkBranding.Is256Color then
    pnlGraphic.Visible := false
  else
  begin
    pnlGraphic.Color := bkBranding.MainFormBackgroundColor;
    imgAbout.Picture := bkBranding.AboutImage;
  end;

  if (not Assigned( AdminSystem)) and (bkBranding.BrandingImageSet <> imDLL) and Assigned( MyClient) then
  begin
    //show the custom logo if there is one
    if MyClient.clFields.clPractice_Logo <> '' then
    begin
       MimeUtils.DecodePictureFromString( MyClient.clFields.clPractice_Logo,  imgAbout.Picture);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAbout.lblBankstreamEmailToClick(Sender: TObject);
var
  Command : String;
begin
  if lblBankstreamEmailTo.caption <> '' then
  begin
    Command := 'mailto:' + lblBankstreamEmailTo.Caption;
    ShellExecute(0, 'open', PChar( Command), nil, nil, SW_NORMAL);
  end;
end;

procedure TfrmAbout.lblBankstreamWebpageClick(Sender: TObject);
begin
   if ShellCommand_Web <> '' then
      ShellExecute(0, 'open', PChar( ShellCommand_Web), nil, nil, SW_NORMAL);
end;

procedure TfrmAbout.lblEmailToClick(Sender: TObject);
var
  Command : String;
begin
  if lblEmailTo.caption <> '' then
  begin
    Command := 'mailto:' + lblEmailTo.Caption;
    ShellExecute(0, 'open', PChar( Command), nil, nil, SW_NORMAL);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAbout.btnEULAClick(Sender: TObject);
var
  f: TDlgLicense;
begin
  f := TDlgLicense.Create(Self);
  try
    f.About := True;
    f.ShowModal;
  finally
    f.Free;
  end;
end;

end.

