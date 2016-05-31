unit AdminOptionsDlg;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  ReportTypes,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Mask, RzEdit, RzSpnEdt, StdCtrls, ComCtrls, Buttons,
  ExtDlgs, ovcbase, ovcef, ovcpb, ovcnf, ReportDefs, NewReportObj,
  NewReportUtils, upgClientCommon, OmniXML, Tabs, RzCmboBx, AuditMgr,
  OSFont, ovcpf, CheckLst;



type
  TdlgAdminOptions = class(TForm)
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    pcOptions: TPageControl;
    tsExporting: TTabSheet;
    tsGeneral: TTabSheet;
    ckBulkExport: TCheckBox;
    pnlCSVEXtract: TPanel;
    Label2: TLabel;
    chkAutoPrintSchRepSummary: TCheckBox;
    tsAdvanced: TTabSheet;
    lh3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lh4: TLabel;
    Label8: TLabel;
    rsMinLogSize: TRzSpinEdit;
    rsMaxLogSize: TRzSpinEdit;
    rsSecToWait: TRzSpinEdit;
    edtLogBackupsDir: TEdit;
    lh1: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    lh2: TLabel;
    Bevel4: TBevel;
    btnBackupDir: TSpeedButton;
    btnRestoreDefaults: TButton;
    lblBackupDefault: TLabel;
    tsInterfaces: TTabSheet;
    Label12: TLabel;
    edtLoginBitmap: TEdit;
    lh5: TLabel;
    Bevel6: TBevel;
    btnBrowseLOBitmap: TSpeedButton;
    chkCopyNarrationDissection: TCheckBox;
    chkAutoLogin: TCheckBox;
    tsSmartLink: TTabSheet;
    lh7: TLabel;
    Bevel10: TBevel;
    Label24: TLabel;
    edtFingertipsURL: TEdit;
    lblSQLIP: TLabel;
    edtSQL_IP: TEdit;
    Label25: TLabel;
    rsFingertipsTimeout: TRzSpinEdit;
    tsUpdates: TTabSheet;
    btnCheckForUpdates: TButton;
    tsLinks: TTabSheet;
    lh8: TLabel;
    Bevel12: TBevel;
    btnInstallUpdates: TButton;
    Label32: TLabel;
    OpenPictureDlg: TOpenPictureDialog;
    cbBulkExport: TComboBox;
    pInstitute: TPanel;
    edtInstListLink: TEdit;
    LBLInstitutionList: TLabel;
    pTop: TPanel;
    Bevel11: TBevel;
    lh9: TLabel;
    PGst: TPanel;
    edtGST101Link: TEdit;
    LBLGSTReturn: TLabel;
    POnline: TPanel;
    eOnlineLink: TEdit;
    lOnline: TLabel;
    PInterfaceOptions: TPanel;
    lh6: TLabel;
    Bevel5: TBevel;
    PQty: TPanel;
    chkExtractQty: TCheckBox;
    lblDP1: TLabel;
    rsDP: TRzSpinEdit;
    lbldp2: TLabel;
    PSol6: TPanel;
    chkXlonSorting: TCheckBox;
    PPA: TPanel;
    chkMultiPA: TCheckBox;
    PPA2: TPanel;
    chkPAJournals: TCheckBox;
    PmaxChar: TPanel;
    Label20: TLabel;
    rsMaxNarration: TRzSpinEdit;
    PZero: TPanel;
    chkZeroAmounts: TCheckBox;
    Panel1: TPanel;
    btnReportPwd: TButton;
    chkReportPwd: TCheckBox;
    pnlCESFont: TPanel;
    Button1: TButton;
    btnReset: TButton;
    cbSize: TRzComboBox;
    cbceFont: TRzFontComboBox;
    chkRetrieve: TCheckBox;
    chkUsage: TCheckBox;
    rsAutoSaveTime: TRzSpinEdit;
    chkDissectedNarration: TCheckBox;
    chkIgnoreQuantity: TCheckBox;
    lblAutoSaveTime: TLabel;
    Label18: TLabel;
    Label31: TLabel;
    ShapeBorder: TShape;
    tsBGL360: TTabSheet;
    lblLoginClientID: TLabel;
    lblLoginSecret: TLabel;
    edtBGLClientID: TEdit;
    edtBGLSecret: TEdit;
    pnlMYOBConnect: TPanel;
    lblFirmName: TLabel;
    btnConnectMYOB: TButton;
    btnForceAuthorisationRefresh: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnBackupDirClick(Sender: TObject);
    procedure btnRestoreDefaultsClick(Sender: TObject);
    procedure ckBulkExportClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnBrowseLOBitmapClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rsAutoSaveTimeChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCheckForUpdatesClick(Sender: TObject);
    procedure btnInstallUpdatesClick(Sender: TObject);
    procedure chkExtractQtyClick(Sender: TObject);
    procedure btnReportPwdClick(Sender: TObject);
    procedure chkReportPwdClick(Sender: TObject);
    procedure btnTestreportClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure cbSizeChange(Sender: TObject);
    procedure cbceFontChange(Sender: TObject);
    procedure eDate1Change(Sender: TObject);
    procedure eDate1DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnConnectMYOBClick(Sender: TObject);
    procedure btnForceAuthorisationRefreshClick(Sender: TObject);
  private

    HeaderFooterChanged : Boolean;
    ReportPassword: string;
    CESFont: TFont;
    TaxChanged: Boolean;
    FFirmChanged : Boolean;
    FFirmID : string;
    FFirmName : string;
    procedure LoadSettingsFromINI;
    procedure LoadSettingsFromAdmin;

    procedure SaveSettingsToINI;
    procedure SaveSettingsToAdmin;

    procedure UpdateControlsOnForm;
    function  VerifyForm : boolean;

    function  InstListLinkChanged: Boolean;

    procedure UpdateFontLabel;

    procedure CheckOpportunisticLocking;
    procedure DoRebranding();

    { Private declarations }
  protected
    procedure UpdateActions; override;
  public
    { Public declarations }
  end;

  function UpdateAdminOptions : boolean;

//******************************************************************************
implementation

uses
  UpdateMF,
  BulkExtractFrm,
  GLConst,
  bkXPThemes,
  OmniXMLUtils,
  WinUtils,
  admin32,
  BKCONST,
  BKHelp,
  genUtils,
  globals,
  inisettings,
  imagesfrm,
  PrintMgrObj,
  ReportImages,
  shellutils,
  software,
  SYDEFS,
  SYSOBJ32,
  ErrorMoreFrm,
  InfoMoreFrm,
  WarningMoreFrm,
  YesNoDlg,
  upgConstants,
  UpgradeHelper,
  LockUtils,
  //ReportStylesDlg,
  ChangePwdDlg,
  EnterPwdDlg,
  bkdateutils,
  Registry,
  StrUtils,
  LOGUTIL,
  bkBranding,
  bkProduct,
  myMYOBSignInFrm,
  PracticeLedgerObj,
  Files;

{$R *.dfm}



// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateAdminOptions : boolean;
//assumes that the admin system has been loaded
var
  AdminOptions : TdlgAdminOptions;
  LockFileInfo: TStrings;
  SecsToWait: Integer;
begin
  result := false;
  RefreshAdmin;

  Assert( Assigned( AdminSystem), 'UpdateAdminOptions - No Admin System Loaded');

  LockFileInfo := TStringList.Create;
  try
    SecsToWait := PRACINI_TicksToWaitForAdmin div 1000;
    if not FileLocking.ObtainLock(ltAdminOptions, SecsToWait) then
    begin
      try
         LockFileInfo.LoadFromFile(Globals.DataDir + ADMIN_OPTIONS_LOCK);
      except
         LockFileInfo.Text := 'Unknown';
      end;
      HelpfulWarningMsg('The System Options cannot be accessed at this time because another user is changing them.'#13#13 +
        'User: ' + LockFileInfo.Text, 0);
      exit;
    end
    else
    begin
      if Globals.CurrUser.FullName <> '' then
        LockFileInfo.Text := Globals.CurrUser.FullName
      else
        LockFileInfo.Text := Globals.CurrUser.Code;
      LockFileInfo.SaveToFile(Globals.DataDir + ADMIN_OPTIONS_LOCK);
    end;
  finally
    LockFileInfo.Free;
  end;

  AdminOptions := TdlgAdminOptions.Create(Application.MainForm);
  with AdminOptions do begin
    try
      LoadSettingsFromINI;
      LoadSettingsFromAdmin;
      UpdateControlsOnForm;

      //****************************
      if ShowModal = mrOK then begin
      //****************************
         //ini settings
         SaveSettingstoINI;
         //admin
         SaveSettingsToAdmin;
      end;
    finally
      Free;
      FileLocking.ReleaseLock(ltAdminOptions);
      DeleteFile(Globals.DataDir + ADMIN_OPTIONS_LOCK);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminOptions.btnBackupDirClick(Sender: TObject);
var
  test : string;
begin
  test := Trim( edtLogBackupsDir.Text);
  if test = '' then
    test := Globals.LogFileBackupDir;

  if BrowseFolder( test, 'Select the folder for log file backups' ) then
  begin
    Test := GenUtils.AddSlash( Trim( Test));
    if lowercase(Test) = lowercase(Globals.LogFileBackupDir) then
      Test := '';
    edtLogBackupsDir.Text := test;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminOptions.FormCreate(Sender: TObject);

begin
  HeaderFooterChanged := False;
  bkXPThemes.ThemeForm( Self);
  BKHelpSetUp(Self, BKH_System_Options);

  lh1.Font.Name := Font.name;
  lh2.Font.Name := Font.name;
  lh3.Font.Name := Font.name;
  lh4.Font.Name := Font.name;
  lh5.Font.Name := Font.name;
  lh6.Font.Name := Font.name;
  lh7.Font.Name := Font.name;
  lh8.Font.Name := Font.name;
  lh9.Font.Name := Font.name;

  CESFont := TFont.Create;
  CESFont.Name := 'Courier';
  CESFont.Size := 9;

  pcOptions.ActivePage := tsGeneral;
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnBackupDir.Glyph);
  ImagesFrm.AppImages.Maintain.GetBitmap(MAINTAIN_PREVIEW_BMP,btnBrowseLOBitmap.Glyph);


  lblBackupDefault.Caption := '(default is ' + Globals.LogFileBackupDir + ')';

  chkXlonSorting.Caption   := '&Use advanced chart code sorting for ' + BKCONST.saNames[ saXlon] + ' clients';
  chkMultiPA.Caption       := '&Allow multiple accounts to be exported for ''' + BKCONST.saNames[ saOmicom] + ''' clients';
  chkPAJournals.Caption    := '&Extract Journals using Journal Tag for ''' + BKCONST.saNames[ saOmicom] + ''' clients. ( PA 7 or later)';
  tsExporting.TabVisible   := BulkExtractFrm.CouldBulkExtract;
  // UK is required to enter passwords for all users
  if (AdminSystem.fdFields.fdCountry = whUK) then
  begin
    chkAutoLogin.Visible               := False;
    chkAutoLogin.Checked               := False;
    Panel1.Top                         := Panel1.Top - 29;
    AdminSystem.fdFields.fdForce_Login := True;
  end;

  DoReBranding();
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminOptions.LoadSettingsFromAdmin;

begin

  with AdminSystem.fdFields do begin
    ckBulkExport.Checked  := fdBulk_Export_Enabled ;

    BulkExtractFrm.FillExtractorComboBox(cbBulkExport,fdBulk_Export_Code);
    //cmbPurge.ItemIndex := fdExpire_Client_Entries;


    chkAutoLogin.Checked := not fdForce_Login;
    edtLoginBitmap.Text := Trim(fdLogin_Bitmap_Filename);
    chkAutoPrintSchRepSummary.Checked := fdAuto_Print_Sched_Rep_Summary;
    chkIgnoreQuantity.Checked := fdIgnore_Quantity_In_Download;
    chkDissectedNarration.Checked := fdReplace_Narration_With_Payee;
    chkUsage.Checked := fdCollect_Usage_Data;
    chkRetrieve.Checked := fdAuto_Retrieve_New_Transactions;

    //report password
    ReportPassword := Adminsystem.fdFields.fdSystem_Report_Password;
    chkReportPwd.Checked := ReportPassword <> '';



    // CES Font
    if fdCoding_Font = '' then
       fdCoding_Font := DefaultCESFontString;
    StrToFont(fdCoding_Font,CESFont);
    UpdateFontLabel;

  end;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAdminOptions.LoadSettingsFromINI;
begin
  tsBGL360.TabVisible := ((CurrUser.Code = SuperUserCode) and
  Assigned(AdminSystem) and
  (AdminSystem.fdFields.fdCountry = whAustralia));

  //general tab settings
  chkCopyNarrationDissection.Checked  := (Globals.PRACINI_CopyNarrationDissection);
  rsAutoSaveTime.IntValue             := (Globals.PRACINI_AutoSaveTime);
  rsAutoSaveTimeChange(rsAutoSaveTime);
  // Reports

  //advance tab settings
  rsMinLogSize.IntValue               := (Globals.PRACINI_MinLogFileSize);
  rsMaxLogSize.IntValue               := (Globals.PRACINI_MaxLogFileSize);
  edtLogBackupsDir.Text               := (Globals.PRACINI_LogBackupDir);
  rsSecToWait.IntValue                := Round(Globals.PRACINI_TicksToWaitForAdmin / 1000);

  //interface tab settings
  chkXlonSorting.Checked              := Globals.PRACINI_UseXLonChartOrder;
  chkExtractQty.Checked               := Globals.PRACINI_ExtractQuantity;
  rsDP.IntValue                       := Globals.PRACINI_ExtractDecimalPlaces;
  chkZeroAmounts.Checked              := Globals.PRACINI_ExtractZeroAmounts;
  chkMultiPA.Checked                  := Globals.PRACINI_ExtractMultipleAccountsToPA;
  chkPAJournals.Checked               := Globals.PRACINI_ExtractJournalsAsPAJournals;
  rsMaxNarration.IntValue             := Adminsystem.fdFields.fdMaximum_Narration_Extract;

  //link tab settings
   //hide the GST Controls for Australia as only valid for New Zealand
  //tsLinks.TabVisible := (AdminSystem.fdFields.fdCountry = whNewZealand);
  PGST.Visible := (AdminSystem.fdFields.fdCountry = whNewZealand);
  edtGST101Link.Text                  := (Globals.PRACINI_GST101Link);

  case AdminSystem.fdFields.fdCountry of
    whNewZealand: edtInstListLink.Text := Globals.PRACINI_InstListLinkNZ;
    whAustralia : edtInstListLink.Text := Globals.PRACINI_InstListLinkAU;
    whUK        : edtInstListLink.Text := Globals.PRACINI_InstListLinkUK;
  end;

   // Could hide and or make disabled, Comes from Webservice...
  lOnline.Caption := format('&%s',[bkBranding.ProductOnlineName]);
  EOnlineLink.Text := PRACINI_OnlineLink;



{$IFDEF SMARTLINK}
  //Smartlink specific settings
  edtFingertipsURL.Text := Globals.PRACINI_FingerTipsURL;
  edtSQL_IP.Text        := Globals.PRACINI_FingertipsSQL_IP;
  rsFingertipsTimeout.IntValue := Globals.PRACINI_FingertipsTimeout;
{$ELSE}
  tsSmartLink.tabVisible := False;
{$ENDIF}
  //BGL client id and secret
  edtBGLClientID.Text := DecryptAToken(PRACINI_BGL360_Client_ID, PRACINI_Random_Key);
  edtBGLSecret.Text := DecryptAToken(PRACINI_BGL360_Client_Secret, PRACINI_Random_Key);
end;

procedure TdlgAdminOptions.SaveSettingsToAdmin;
//returns true if admin settings changed
var
  SettingsChanged : boolean;
  ExportType     : string;
  UpdatesPending : boolean;
  UpdateServer   : string;

 
begin
  //set temp variables

  ExportType := BulkExtractFrm.GetComboBoxExtractorCode(cbBulkExport);


  UpdatesPending := btnInstallUpdates.Visible;

  //see if anything has changed
  with AdminSystem.fdFields do
  begin
    if rsMaxNarration.IntValue = 0 then
      rsMaxNarration.IntValue := 200;

    SettingsChanged := (ckBulkExport.Checked <> fdBulk_Export_Enabled) or
                       (ExportType <> fdBulk_Export_Code) or
                       (chkAutoLogin.Checked <> not fdForce_Login) or
                       (edtLoginBitmap.Text <> fdLogin_Bitmap_Filename) or
                       (chkAutoPrintSchRepSummary.Checked <> fdAuto_Print_Sched_Rep_Summary) or
                       (chkIgnoreQuantity.Checked <> fdIgnore_Quantity_In_Download) or
                       (chkDissectedNarration.Checked <> fdReplace_Narration_With_Payee) or
                       (chkUsage.Checked <> fdCollect_Usage_Data) or
                       (chkRetrieve.Checked <> fdAuto_Retrieve_New_Transactions) or
                       (rsMaxNarration.IntValue <> fdMaximum_Narration_Extract) or
                       (UpdatesPending <> AdminSystem.fdFields.fdUpdates_Pending) or
                       (ReportPassword <> AdminSystem.fdFields.fdSystem_Report_Password) or
                       (FontToStr(CESFont) <> AdminSystem.fdFields.fdCoding_Font) or
                       (TaxChanged) or (FFirmChanged);
                       //(cmbPurge.ItemIndex <> fdExpire_Client_Entries);
  end;
  //save new admin system if changed
  if SettingsChanged then begin
     if LoadAdminSystem(true, 'TdlgAdminOptions.SaveSettingsToAdmin' ) then
       with AdminSystem.fdFields do
       begin
         fdBulk_Export_Enabled := ckBulkExport.Checked;
         fdBulk_Export_Code    := ExportType;

         fdUpdates_Pending    := UpdatesPending;
         fdUpdate_Server_For_Offsites := UpdateServer;
         //fdExpire_Client_Entries := cmbPurge.ItemIndex;

         //display header/footer flags


         fdLogin_Bitmap_Filename := edtLoginBitmap.Text;
         fdForce_Login := not chkAutoLogin.Checked;
         fdAuto_Print_Sched_Rep_Summary := chkAutoPrintSchRepSummary.Checked;
         fdIgnore_Quantity_In_Download := chkIgnoreQuantity.Checked;
         fdReplace_Narration_With_Payee := chkDissectedNarration.Checked;
         fdCollect_Usage_Data := chkUsage.Checked;
         fdAuto_Retrieve_New_Transactions := chkRetrieve.Checked;
         fdmyMYOBFirmID := FFirmID;
         fdmyMYOBFirmName := FFirmName;

         if rsMaxNarration.IntValue = 0 then
           fdMaximum_Narration_Extract := 200
         else
           fdMaximum_Narration_Extract := rsMaxNarration.IntValue;
         fdSystem_Report_Password := ReportPassword;
         fdCoding_Font := FontToStr(CESFont);

         //*** Flag Audit ***
         SystemAuditMgr.FlagAudit(arSystemOptions);

         SaveAdminSystem;
       end;
     UpdateMF.UpdateSystemMenus;
  end;
end;

function  TdlgAdminOptions.InstListLinkChanged: Boolean;
begin
  case AdminSystem.fdFields.fdCountry of
    whNewZealand: result := (edtInstListLink.Text <> Globals.PRACINI_InstListLinkNZ);
    whAustralia : result := (edtInstListLink.Text <> Globals.PRACINI_InstListLinkAU);
    whUK        : result := (edtInstListLink.Text <> Globals.PRACINI_InstListLinkUK);
  else
    Result := false;
  end;
end;

procedure TdlgAdminOptions.SaveSettingsToINI;
//returns true if ini settings changed
var
  BackupDir       : String;
  SettingsChanged : Boolean;
  TicksToWait     : Integer;

begin
  BackupDir   := GenUtils.AddSlash( Trim( edtLogBackupsDir.Text));
  TicksToWait := rsSecToWait.IntValue * 1000;

  SettingsChanged := (chkCopyNarrationDissection.Checked <> Globals.PRACINI_CopyNarrationDissection) or
                     (rsAutoSaveTime.IntValue <> Globals.PRACINI_AutoSaveTime) or
                     (rsMinLogSize.IntValue <> Globals.PRACINI_MinLogFileSize) or
                     (rsMaxLogSize.IntValue <> Globals.PRACINI_MaxLogFileSize) or
                     (BackupDir             <> Globals.PRACINI_LogBackupDir) or
                     (TicksToWait           <> Globals.PRACINI_TicksToWaitForAdmin) or
                     (chkXlonSorting.Checked <> Globals.PRACINI_UseXLonChartOrder) or
                     (chkMultiPA.Checked    <> Globals.PRACINI_ExtractMultipleAccountsToPA) or
                     (chkPAJournals.checked <> Globals.PRACINI_ExtractJournalsAsPAJournals) or
                     (chkExtractQty.Checked <> Globals.PRACINI_ExtractQuantity) or
                     (rsDP.IntValue         <> Globals.PRACINI_ExtractDecimalPlaces) or
                     (edtGST101Link.Text    <> Globals.PRACINI_GST101Link) or
                     (EOnlineLink.Text      <> Globals.PRACINI_OnlineLink) or
                     (chkZeroAmounts.Checked <> Globals.PRACINI_ExtractZeroAmounts) or
                     (edtBGLSecret.Text <> Globals.PRACINI_BGL360_Client_Secret) or
                     (edtBGLClientID.Text <> Globals.PRACINI_BGL360_Client_ID);

                     (InstListLinkChanged) {or
                     (cbUseStyles.Checked   <> Globals.PRACINI_UseReportStyles)}
{$IFNDEF SmartLink}
;
{$ELSE}
                     or
                     (edtSQL_IP.Text <> Globals.PRACINI_FingertipsSQL_IP) or
                     (rsFingertipsTimeout.IntValue <> Globals.PRACINI_FingertipsTimeout) or
                     (edtFingertipsURL.Text <> Globals.PRACINI_FingertipsURL);
{$ENDIF}

  if SettingsChanged then begin
   if LoadAdminSystem(true, 'TdlgAdminOptions.SaveSettingsToINI' ) then
   begin
    // Write some to pracinin and db so that offsites can use the settings to
    Globals.PRACINI_CopyNarrationDissection  := chkCopyNarrationDissection.Checked;
    AdminSystem.fdFields.fdCopy_Dissection_Narration := chkCopyNarrationDissection.Checked;
    Globals.PRACINI_AutoSaveTime             := rsAutoSaveTime.IntValue;
    Globals.PRACINI_MinLogFileSize           := rsMinLogSize.IntValue;
    Globals.PRACINI_MaxLogFileSize           := rsMaxLogSize.IntValue;
    Globals.PRACINI_LogBackupDir             := BackupDir;
    Globals.PRACINI_TicksToWaitForAdmin      := TicksToWait;
    Globals.PRACINI_UseXLonChartOrder        := chkXlonSorting.checked;
    AdminSystem.fdFields.fdUse_Xlon_Chart_Order := chkXlonSorting.checked;
    Globals.PRACINI_ExtractMultipleAccountsToPA := chkMultiPA.Checked;
    AdminSystem.fdFields.fdExtract_Multiple_Accounts_PA := chkMultiPA.Checked;
    Globals.PRACINI_ExtractJournalsAsPAJournals := chkPAJournals.Checked;
    AdminSystem.fdFields.fdExtract_Journal_Accounts_PA := chkPAJournals.Checked;
    Globals.PRACINI_ExtractQuantity          := chkExtractQty.checked;
    AdminSystem.fdFields.fdExtract_Quantity := chkExtractQty.checked;
    Globals.PRACINI_ExtractDecimalPlaces    := rsDP.IntValue;
    Globals.PRACINI_ExtractZeroAmounts      := chkZeroAmounts.Checked;
    Adminsystem.fdFields.fdExtract_Quantity_Decimal_Places := rsDP.IntValue;
{$IFDEF SmartLink}
    Globals.PRACINI_FingertipsURL           := edtFingertipsURL.text;
    Globals.PRACINI_FingertipsSQL_IP        := edtSQL_IP.Text;
    Globals.PRACINI_FingertipsTimeout       := rsFingertipsTimeout.IntValue;
{$ENDIF}
    Globals.PRACINI_GST101Link              := edtGST101Link.Text;
    Globals.PRACINI_OnlineLink              := EOnlineLink.Text;

    case AdminSystem.fdFields.fdCountry of
      whNewZealand: Globals.PRACINI_InstListLinkNZ := edtInstListLink.Text;
      whAustralia : Globals.PRACINI_InstListLinkAU := edtInstListLink.Text;
      whUK        : Globals.PRACINI_InstListLinkUK := edtInstListLink.Text;
    end;

   // BGL configs storing encrpted values in system ini file
   Globals.PRACINI_BGL360_Client_ID := EncryptAToken(edtBGLClientID.Text,PRACINI_Random_Key);
   Globals.PRACINI_BGL360_Client_Secret := EncryptAToken(edtBGLSecret.Text, PRACINI_Random_Key);

    //*** Flag Audit ***
    SystemAuditMgr.FlagAudit(arSystemOptions);

    SaveAdminSystem;
    WritePracticeINI_WithLock;
   end
   else
    HelpfulErrorMsg('Unable to Update System Options.  Admin System cannot be loaded',0);
  end
end;


function TdlgAdminOptions.VerifyForm: boolean;
var
  TestDir : string;
  //aMsg    : string;
  Size    : integer;

  procedure FocusMessage(Control: TWinControl; Page: tTabSheet; Msg: String);
  begin
     pcOptions.ActivePage := Page;
     Control.SetFocus;
     HelpfulWarningMsg( Msg, 0);
  end;


begin
  result := false;

  //general tab

  //export tab


  //advance tab
  //min log size < max log size
  Size := rsMaxLogSize.IntValue - rsMinLogSize.IntValue;
  if Size < 100 then begin
     FocusMessage(rsMaxLogSize,tsAdvanced,
            'The maximum log file size must be at least 100K greater than the '+
            'minimum log file size.');
     Exit;
  end;

  //log dir exists unless blank
  TestDir := Trim( edtLogBackupsDir.Text);
  if TestDir <> '' then begin
    TestDir := GenUtils.AddSlash( TestDir);
    if not DirectoryExists(TestDir) then begin
       FocusMessage(edtLogBackupsDir,tsAdvanced,
             'The Backup directory that you have selected cannot be found.');
       Exit;
    end;
  end;


  // Still here...
  Result := true;
end;

procedure TdlgAdminOptions.btnRestoreDefaultsClick(Sender: TObject);
begin
  //advance tab settings
  rsMinLogSize.IntValue               := Globals.DEFAULT_MIN_LOG_KB;
  rsMaxLogSize.IntValue               := Globals.DEFAULT_MAX_LOG_KB;
  edtLogBackupsDir.Text               := Globals.DEFAULT_LOG_BACKUP_DIR;
  rsSecToWait.IntValue                := Globals.DEFAULT_SECS_TO_WAIT_FOR_ADMIN;
  edtLoginBitmap.Text                 := '';
  //cmbPurge.ItemIndex                  := 0;
end;

procedure TdlgAdminOptions.btnTestreportClick(Sender: TObject);
begin
//   ReportStylesDlg.SetupStyles;
end;

procedure TdlgAdminOptions.Button1Click(Sender: TObject);
begin
  CheckOpportunisticLocking;
end;

procedure TdlgAdminOptions.btnResetClick(Sender: TObject);
begin
  StrToFont(DefaultCESFontString,CESFont);
  UpdateFontLabel;
end;

procedure TdlgAdminOptions.btnReportPwdClick(Sender: TObject);
var
  f: TdlgChangePwd;
begin
  f := TdlgChangePwd.Create(Self);
  if SuperUserLoggedIn then
    f.CurrentPassword := ''
  else
    f.CurrentPassword := ReportPassword;
  if f.ShowModal = mrOk then
  begin
    ReportPassword := f.NewPassword;
  end;
  if ReportPassword = '' then
  begin
    chkReportPwd.Checked := False;
    self.chkReportPwdClick(Sender);
  end;
  f.Free;
end;

procedure TdlgAdminOptions.cbceFontChange(Sender: TObject);
begin
   CESFont.Name := cbCEFont.FontName;
   UpdateFontLabel;
end;

procedure TdlgAdminOptions.cbSizeChange(Sender: TObject);
begin
  CESFont.Size := StrToInt(cbSize.Text);
  cbCEFont.FontSize := CESFont.Size;
  UpdateFontLabel;
end;

procedure TdlgAdminOptions.CheckOpportunisticLocking;

  function AppendMessage(const CurrentMsg, NewMsg: String): String;
  begin
    if CurrentMsg <> '' then
    begin
      Result := CurrentMsg + #10#13 + NewMsg;
    end
    else
    begin
      Result := NewMsg;
    end;
  end;
  
var
  Msg: String;
begin
  if GetClientRequestOpsLockEnabled then
  begin
    Msg := AppendMessage(Msg, '- Request Opportunistic Locking is enabled.');

    LogUtil.LogMsg(lmInfo, 'AdminOptionsDlg', 'Request Opportunistic Locking is enabled');
  end
  else
  begin
    Msg := AppendMessage(Msg, '- Request Opportunistic Locking is disabled.');

    LogUtil.LogMsg(lmInfo, 'AdminOptionsDlg', 'Request Opportunistic Locking is disabled');
  end;

  if GetServerGrantOpsLockEnabled then
  begin
    Msg := AppendMessage(Msg, '- Grant Opportunistic Locking is enabled.');

    LogUtil.LogMsg(lmInfo, 'AdminOptionsDlg', 'Grant Opportunistic Locking is enabled');
  end
  else
  begin
    Msg := AppendMessage(Msg, '- Grant Opportunistic Locking requests is disabled.');

    LogUtil.LogMsg(lmInfo, 'AdminOptionsDlg', 'Grant Opportunistic Locking requests is disabled');
  end;

  if IsWindowsVista then
  begin
    if GetServerSMB2Enabled then
    begin
      Msg := AppendMessage(Msg, '- SMB2 is enabled.');
      
      LogUtil.LogMsg(lmInfo, 'AdminOptionsDlg', 'SMB2 is enabled');
    end
    else
    begin
      Msg := AppendMessage(Msg, '- SMB2 is disabled.');

      LogUtil.LogMsg(lmInfo, 'AdminOptionsDlg', 'SMB2 is disabled');
    end;
  end;

  HelpfulInfoMsg(Msg, 0);
end;

procedure TdlgAdminOptions.ckBulkExportClick(Sender: TObject);
begin
  UpdateControlsOnForm;
end;

procedure TdlgAdminOptions.DoRebranding;
begin
  chkUsage.Caption := 'Allow ' + bkBranding.BrandName + ' to collect software &usage information';
  lOnline.Caption := BRAND_ONLINE;
end;

procedure TdlgAdminOptions.chkExtractQtyClick(Sender: TObject);
begin
  lblDP1.Visible := chkExtractQty.Checked;
  lblDP2.Visible := chkExtractQty.Checked;
  rsDP.Visible := chkExtractQty.Checked;
end;

procedure TdlgAdminOptions.chkReportPwdClick(Sender: TObject);
begin
  btnReportPwd.Enabled := chkReportPwd.Checked;
  if chkReportPwd.Checked and (ReportPassword = '') then
    btnReportPwdClick(Sender);
  if (not chkReportPwd.Checked) and (ReportPassword <> '') then
  begin
    if (AdminSystem.fdFields.fdSystem_Report_Password <> '') and
       (not SuperUserLoggedIn) and
       (not EnterPwdDlg.EnterPassword( 'Statements and Download Documents',
                                     ReportPassword,
                                     0,
                                     pwdNormal,
                                     pwdHidePassword )) then
    begin
      HelpfulErrorMsg( 'A valid password is required to change this setting.', 0);
      chkReportPwd.Checked := true;
    end
    else
      ReportPassword := '';
  end;
end;

procedure TdlgAdminOptions.eDate1Change(Sender: TObject);
begin
    TaxChanged := true;
end;

procedure TdlgAdminOptions.eDate1DblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);               
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;

procedure TdlgAdminOptions.UpdateControlsOnForm;
var
  o : TBkCommonUpgrader;
begin
  //export tab
  cbBulkExport.Enabled := ckBulkExport.Checked;

  with AdminSystem.fdFields do
  begin
    //sol 6
    Psol6.Visible       := (fdCountry = whAustralia) and (fdAccounting_System_Used = saXlon);
    //aps options
    PPA.Visible := Software.IsPA7Interface( fdCountry, fdAccounting_System_Used );  //XPA8 assumes multiple accounts
    PPA2.Visible := Software.IsPA7Interface( fdCountry, fdAccounting_System_Used )
                 or Software.IsXPA8Interface( fdCountry, fdAccounting_System_Used );
  end;

  //determine if should show the Install Updates button
  if btnInstallUpdates.Visible then
  begin
    //load dll and test for updates
    o := TBkCommonUpgrader.Create;
    try
{$IFDEF SmartLink}
      btnInstallUpdates.visible := o.UpdatesPending( PChar(ShortAppName), 0, aidSmartLink);
{$ELSE}
      btnInstallUpdates.visible := o.UpdatesPending( PChar(ShortAppName), 0, aidBK5_Practice);
{$ENDIF}
    finally
      o.Free;
    end;
  end;
end;

procedure TdlgAdminOptions.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if Modalresult = mrOK then
    CanClose := VerifyForm;
end;

procedure TdlgAdminOptions.btnBrowseLOBitmapClick(Sender: TObject);
var
  TempFilename : string;
  Ext          : string;
begin
  with OpenPictureDlg do
  begin
    FileName := ExtractFileName(edtLoginBitmap.text);
    InitialDir := ExtractFilePath(edtLoginBitmap.text);
    Filter := 'All (*.jpg;*.jpeg;*.bmp;)|*.jpg;*.jpeg;*.bmp;|JPEG Image File (*.jpg)|*.jpg|JPEG Image File (*.jpeg)|*.jpeg|Bitmaps (*.bmp)|*.bmp';

    if Execute then
    begin
      TempFilename := Filename;
      Ext          := LowerCase( ExtractFileExt( TempFilename));

      if ( Ext = '.jpg') or ( Ext = '.jpeg') or ( Ext = '.bmp') then
      begin
        edtLoginBitmap.text := TempFilename;
      end
      else
      begin
        //if not a known format then ignore it
        HelpfulWarningMsg( 'The file you selected in not a recognised format.', 0);
      end;
    end;
  end;
end;




procedure TdlgAdminOptions.updateActions;
begin
  inherited;
end;

procedure TdlgAdminOptions.FormDestroy(Sender: TObject);
begin
   CESFont.Free;
end;

procedure TdlgAdminOptions.rsAutoSaveTimeChange(Sender: TObject);
begin
  if (TRzSpinEdit(Sender).Value = 0) then
    lblAutoSaveTime.Caption := 'minutes (OFF)'
  else
    lblAutoSaveTime.Caption := 'minutes';
end;

procedure TdlgAdminOptions.FormShow(Sender: TObject);
begin
  FFirmChanged := False;
  pcOptions.ActivePage := tsGeneral;
  btnReportPwd.Enabled := chkReportPwd.Checked;

  lblFirmName.Visible := False;
  lblFirmName.Caption := '';

  if Assigned(AdminSystem) then
  begin
    FFirmID := AdminSystem.fdFields.fdmyMYOBFirmID;
    FFirmName := AdminSystem.fdFields.fdmyMYOBFirmName;
  end;

  if not (CheckFormyMYOBTokens) then
    btnConnectMYOB.Caption := 'MYOB Login'
  else
  begin
    btnConnectMYOB.Caption := 'Select MYOB Firm';

    if Assigned(AdminSystem) then
    begin
      if Trim(AdminSystem.fdFields.fdmyMYOBFirmName) = '' then
        lblFirmName.Caption := 'No firm selected for MYOB Ledger Export'
      else
        lblFirmName.Caption := 'Firm selected for MYOB Ledger Export: '+ AdminSystem.fdFields.fdmyMYOBFirmName;
        
      lblFirmName.Visible := True;
    end;
  end;
end;

function CountUsersLoggedIn( aAdminSystem : TSystemObj; var UserList : string) : integer;
var
  i : integer;
  c : integer;
  pUser : pUser_Rec;
begin
  UserList := '';
  c := 0;
  for i := aAdminSystem.fdSystem_User_List.First to aAdminSystem.fdSystem_User_List.Last do
  begin
    pUser := aAdminSystem.fdSystem_User_List.User_At(i);
    if pUser.usLogged_In then
    begin
      c := c + 1;
      //dont add current user to list of users logged in
      if pUser.usCode <> CurrUser.Code then
      begin
        if pUser.usName <> '' then
          UserList := UserList + pUser.usName + #13
        else
          UserList := UserList + pUser.usCode + #13;
      end;
    end;
  end;
  result := c;
end;


procedure TdlgAdminOptions.btnCheckForUpdatesClick(Sender: TObject);
var
  Upgrader : TBkCommonUpgrader;
  Major, Minor, Release, Build : word;
  Action : integer;
  ConfigStr : string;
  s : string;
  InstallResult : integer;
begin
  //get version info
  WinUtils.GetBuildInfo( Major, Minor, Release, Build);
  //construct config str which allows us to pass in all of the proxy/fw settings
    //proxy/firewall
  ConfigStr := upgClientCommon.ConstructConfigXml( INI_BCTimeout,
                                                   INI_BCUseWinInet,
                                                   INI_BCUseProxy,
                                                   INI_BCProxyHost,
                                                   INI_BCProxyPort,
                                                   INI_BCProxyUsername,
                                                   INI_BCProxyPassword,
                                                   INI_BCProxyAuthMethod,
                                                   INI_BCFirewallHost <> '',
                                                   INI_BCFirewallHost,
                                                   INI_BCFirewallPort,
                                                   INI_BCFirewallType,
                                                   INI_BCFirewallUseAuth,
                                                   INI_BCFirewallUsername,
                                                   INI_BCFirewallPassword);

  Upgrader := TBkCommonUpgrader.Create;
  try
    //Upgrader.LoadShadowDll := false;  //turn this off for debugging
{$IFDEF SmartLink}
    action := Upgrader.CheckForUpdates( PChar(Globals.SHORTAPPNAME), Self.Handle, aidSmartLink, Major, Minor, Release, Build, '', AdminSystem.fdFields.fdCountry, PChar( ConfigStr));
{$ELSE}
    action := Upgrader.CheckForUpdates( PChar(Globals.SHORTAPPNAME), Self.Handle, aidBK5_Practice, Major, Minor, Release, Build, '', AdminSystem.fdFields.fdCountry, PChar( ConfigStr));
{$ENDIF}



    case action of
      uaUnableToLoad : HelpfulErrorMsg( 'Unable to load Upgrader', 0);

      uaInstallPending : begin
        //see if can upgrade now ie. no other users in system
        //reload admin system to get current # of users
        LoadAdminSystem( false, 'CountUsers');

        if CountUsersLoggedIn(AdminSystem, s) > 1 then
        begin
          btnInstallUpdates.Visible := true;
          HelpfulInfoMsg( 'Updates have been downloaded but cannot be installed at this time. '#13#13+
                          'The following users are logged in to ' + ShortAppName + ':'#13#13 +
                          s, 0);
        end
        else
        if AskYesNo( 'Update ' + shortappname, 'Updates have been downloaded, do you want to install them now?', dlg_yes, 0) = dlg_yes then
        begin
          UpgradeHelper.WriteInstallUpdatesLock;

          //install updates
{$IFDEF SmartLink}
          InstallResult := Upgrader.InstallUpdates( PChar(ShortAppName), Self.Handle, aidSmartLink, ifCloseIfRequired, 0);
{$ELSE}
          InstallResult := Upgrader.InstallUpdates( PChar(ShortAppName), Self.Handle, aidBK5_Practice, ifCloseIfRequired, 0);
{$ENDIF}
          case InstallResult of
            uaCloseCallingApp :
            begin
               Globals.ApplicationMustShutdownForUpdate := true;
               Modalresult := mrOK;
            end;
            uaUnableToLoad : ShowMessage('Load failed');
          end;

          if InstallResult <> uaCloseCallingApp then
            UpgradeHelper.ClearInstallUpdatesLock;
        end
        else
        begin
          //if users doesn't want to upgrade now set a flag telling this dialog
          //to test if updates are pending next time this dialog is openned
          btnInstallUpdates.Visible := true;
        end;
      end;
    end;
  finally
    Upgrader.Free;
  end;
end;

procedure TdlgAdminOptions.btnConnectMYOBClick(Sender: TObject);
var
  SignInFrm : TmyMYOBSignInForm;
  OldCursor: TCursor;
begin
  SignInFrm := TmyMYOBSignInForm.Create(Nil);
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if (not CheckFormyMYOBTokens) then
    begin
      SignInFrm.FormShowType := fsSignIn;
      //FFirmID := '';
//      /FFirmName := '';
    end
    else
    begin
      SignInFrm.FormShowType := fsSelectFirm;
      if ( Trim(FFirmID) = '' ) then begin
        SignInFrm.FormShowType := fsSignIn;
      end
      else
      begin
        if ( PracticeLedger.CountEligibleFirms(True) <= 0  ) then // There was no entitlement for any firms
        begin
          Screen.Cursor := OldCursor;
          PracticeLedger.ResetMyMYOBUserDetails;
          SignInFrm.FormShowType := fsSignIn;
          HelpfulErrorMsg( errMYOBCredential, 0 );
        end;
      end;
    end;

    SignInFrm.SelectedID := FFirmID;
    SignInFrm.SelectedName := FFirmName;

    SignInFrm.ShowFirmSelection := True;
    if ((SignInFrm.ShowModal = mrOK) and (Assigned(AdminSystem)) and
        (Trim(SignInFrm.SelectedID) <> Trim(FFirmID))) then
    begin
      FFirmChanged := True;
      FFirmID := SignInFrm.SelectedID;
      FFirmName := SignInFrm.SelectedName;
      NeedToClearMYOBClient := True;
      if Assigned(MyClient) then
      begin
        NeedToClearMYOBClient := False;
        MyClient.clExtra.cemyMYOBClientIDSelected := '';
        MyClient.clExtra.cemyMYOBClientNameSelected := '';
        if Assigned(PracticeLedger) then
          PracticeLedger.Businesses.Clear;

        SaveClient(false);
      end;
    end;

    if Trim(FFirmName) = '' then
      lblFirmName.Caption := 'No firm selected for MYOB Ledger Export'
    else
      lblFirmName.Caption := 'Firm selected for MYOB Ledger Export: '+ FFirmName;
    lblFirmName.Visible := True;

    if not (CheckFormyMYOBTokens) then
      btnConnectMYOB.Caption := 'MYOB Login'
    else
      btnConnectMYOB.Caption := 'Select MYOB Firm';
  finally
    FreeAndNil(SignInFrm);
    Screen.Cursor := OldCursor;
  end;
end;

procedure TdlgAdminOptions.btnForceAuthorisationRefreshClick(Sender: TObject);
begin
//  Clear out the BGL Tokens and force the user to re-authenticate
  AdminSystem.fdFields.fdBGLAccessToken    := '';
  AdminSystem.fdFields.fdBGLRefreshToken   := '';
  AdminSystem.fdFields.fdBGLTokenType      := '';
  AdminSystem.Save;

  HelpfulInfoMsg( 'BGL authorisation has been refreshed.', 0 );
  LogUtil.LogMsg(lmInfo, 'AdminOptionsDlg', 'BGL authorisation has been refreshed.');

//  AdminSystem.fdFields.fdBGLTokenExpiresAt := StrToDateTime('1900');
end;

procedure TdlgAdminOptions.btnInstallUpdatesClick(Sender: TObject);
var
  UserList : string;
  UserCount : integer;
  Upgrader : TBkCommonUpgrader;
  InstallResult : integer;
begin
  //recheck users that are logged in
  if AskYesNo( 'Install Updates', 'Install updates now?', dlg_yes, 0) <> dlg_yes then
    Exit;

  LoadAdminSystem( true, 'InstallUpdates');

  UserCount := CountUsersLoggedIn( AdminSystem, UserList);
  if UserCount > 1 then
  begin
    Admin32.UnlockAdmin;
    HelpfulInfoMsg( 'Cannot install updates at this time. '#13#13+
                          'The following users are logged in to ' + ShortAppName + ':'#13#13 +
                          UserList, 0);
  end
  else
  begin
    Upgrader := TBkCommonUpgrader.Create;
    try
      UpgradeHelper.WriteInstallUpdatesLock;

      //install updates
{$IFDEF SmartLink}
      InstallResult := Upgrader.InstallUpdates( PChar(ShortAppName), 0, aidSmartLink, ifCloseIfRequired, 0);
{$ELSE}
      InstallResult := Upgrader.InstallUpdates( PChar(ShortAppName), 0, aidBK5_Practice, ifCloseIfRequired, 0);
{$ENDIF}
      case InstallResult of
        uaCloseCallingApp :
        begin
           Globals.ApplicationMustShutdownForUpdate := true;
           Modalresult := mrOK;
        end;
        uaUnableToLoad : ShowMessage('Load failed');
      end;

      if InstallResult <> uaCloseCallingApp then
        UpgradeHelper.ClearInstallUpdatesLock;
    finally
      UnlockAdmin;
      Upgrader.Free;
    end;
  end;
end;

procedure TdlgAdminOptions.UpdateFontLabel;
var S: string;
    I: Integer;
begin
  pnlCESFont.Font.Assign(CESFont);
  //pnlCESFont.Caption := CESFont.Name + ' ' + IntToStr(CESFont.Size) + 'pt';
  cbceFont.FontName := CESFont.Name;
  S := intToStr(CESFont.Size);
  I := cbSize.Items.IndexOf(S);
  if I <0 then
     cbSize.ItemIndex := cbSize.Items.Add(S)
  else
     cbSize.ItemIndex := I;
end;


end.
