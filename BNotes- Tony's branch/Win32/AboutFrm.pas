unit AboutFrm;
//------------------------------------------------------------------------------
{
   Title:       About Screen

   Description:

   Remarks:

   Author:      Matthew Hopkins Aug 2001

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  BaseFrm, ExtCtrls, StdCtrls, RzBckgnd, ecObj, jpeg;

type
  TfrmAbout = class(TfrmBase)
    pnlGraphic: TPanel;
    img256color: TImage;
    imgLogo: TImage;
    lblTitle: TLabel;
    lblCopyrightDate: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    lblCountry: TLabel;
    Label3: TLabel;
    lblContactName: TLabel;
    lblContactNumber: TLabel;
    lblContactWebSite: TLabel;
    lblVersion: TLabel;
    Bevel1: TBevel;
    lblWinVer: TLabel;
    lblContactEmail: TLabel;
    btnClose: TButton;
    lblAppDir: TLabel;
    Label4: TLabel;
    lblCurrFile: TLabel;
    lblSaveDir: TLabel;
    Label5: TLabel;
    lblServer: TLabel;
    procedure FormShow(Sender: TObject);
    procedure lblContactEmailClick(Sender: TObject);
    procedure lblContactWebSiteClick(Sender: TObject);
  private
    { Private declarations }
    MyClientFile : TECClient;
  public
    { Public declarations }
  end;

  procedure ShowAbout(aClient : TECClient); //ShowAbout(ClientCountry : integer; currFilename : string);

//******************************************************************************

implementation

{$R *.DFM}

uses
  ShellAPI,
  ecGlobalConst,
  ecColors,
  winutils,
  bkConst, ImagesFrm, INISettings, upgConstants;

const
  COPYRIGHTNAME = 'BankLink Limited';

procedure ShowAbout(aClient : TECClient);
begin
  with TFrmAbout.Create(nil) do
  begin
    try
      MyClientFile := aClient;
      ShowModal;
    finally
      Free;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmAbout.FormShow(Sender: TObject);
begin
  inherited;
  Caption := 'About ' + ecGlobalConst.APP_TITLE;

  if Assigned(MyClientFile) then
  begin
    case MyClientFile.ecFields.ecCountry of
       whNewZealand : lblCountry.Caption := 'NZ';
       whAustralia  : lblCountry.Caption := 'AU';
    else
       lblCountry.Caption := '';
    end;
  end else
    lblCountry.Caption := '';

  lblAppDir.Caption     := ExtractFilePath( Application.ExeName);
  if Assigned(MyClientFile) then
  begin
    lblSaveDir.Caption    := INI_DefaultFileLocation; // GetTempDir( ExtractFilePath(MyClientFile.ecFields.ecFilename));
    lblCurrFile.caption   := MyClientFile.ecFields.ecFilename;
    {if MyClientFile.ecFields.ecUpdate_Server <> '' then
      lblServer.Caption := MyClientFile.ecFields.ecUpdate_Server
    else} if MyClientFile.ecFields.ecCountry = whAustralia then
      lblServer.Caption := DefaultAUCatalogServer
    else
      lblServer.Caption := DefaultNZCatalogServer;
  end else
  begin
    lblSaveDir.Caption    := '';
    lblCurrFile.caption   := '';
    lblServer.Caption     := '';
  end;

  //NTD : branding logo
  if (AppImages.imgLogo.Picture.Width > 0) then
  begin
    Img256Color.Visible := False;
    ImgLogo.Picture := AppImages.imgLogo.Picture;
    ImgLogo.Visible := True;
  end else
  begin
    Img256Color.Visible := True;
    ImgLogo.Visible := True;
    ImgLogo.Picture := AppImages.imgPictureLogo.Picture;
    ImgLogo.Stretch := True;
  end;

  lblTitle.Caption := ecGlobalConst.APP_NAME + ' ' + GetAppYearVersionStr;
  lblVersion.Caption := 'Version ' + WinUtils.GetAppVersionStr;
  lblCopyrightDate.Caption := 'Copyright © 2000 - 2009 ' + COPYRIGHTNAME;
  lblWinVer.Caption  := WinUtils.GetWinVer;

  if Assigned(MyClientFile) then
  begin
    if (MyClientFile.ecFields.ecContact_Person <> '') then
      lblContactName.Caption := MyClientFile.ecFields.ecContact_Person
    else
      lblContactName.Caption := MyClientFile.ecFields.ecPractice_Name;

    lblContactNumber.Caption := MyClientFile.ecFields.ecContact_Phone_Number;
    lblContactEmail.Caption := MyClientFile.ecFields.ecContact_EMail_Address;
    lblContactWebSite.Caption := MyClientFile.ecFields.ecPractice_Web_Site;
  end else
  begin
    lblContactName.Caption := '';
    lblContactNumber.Caption := '';
    lblContactEmail.Caption := '';
    lblContactWebSite.Caption := '';
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmAbout.lblContactEmailClick(Sender: TObject);
var
  Command : String;
begin
  if lblContactEmail.Caption <> '' then
  begin
    Command := 'mailto:' + lblContactEmail.Caption;
    ShellExecute(0, 'open', PChar( Command), nil, nil, SW_NORMAL);
  end;
end;
procedure TfrmAbout.lblContactWebSiteClick(Sender: TObject);
begin
  if (lblContactWebSite.Caption <> '') then
    ShellExecute(0, 'open', PChar(lblContactWebSite.Caption), nil, nil, SW_NORMAL);
end;

end.
