unit Optionsfrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//allows the user to set workstation specific options that are stored
//in the ini file
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Cryptcon, Blowunit, OvcBase, OvcEF, OvcPB,
  OvcNF, Mask, RzEdit, RzSpnEdt, Buttons, rzCmboBx,
  OsFont;

type
  TfrmOptions = class(TForm)
    PageControl1: TPageControl;
    tsToolbar: TTabSheet;
    Panel1: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    chkCaptions: TCheckBox;
    tsEmail: TTabSheet;
    Panel2: TPanel;
    Panel3: TPanel;
    rbMAPI: TRadioButton;
    rbSMTP: TRadioButton;
    Label1: TLabel;
    chkAuthentication: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    chkMAPI: TCheckBox;
    Label4: TLabel;
    Label5: TLabel;
    eSMTP: TEdit;
    eAccountName: TEdit;
    eSMTPPassword: TEdit;
    eProfileName: TEdit;
    eMAPIPassword: TEdit;
    Label6: TLabel;
    eReturn: TEdit;
    chkShowHint: TCheckBox;
    Label7: TLabel;
    nTimeout: TOvcNumericField;
    OvcController1: TOvcController;
    chkShowCodeHint: TCheckBox;
    Label18: TLabel;
    rsAutoSaveTime: TRzSpinEdit;
    lblAutoSaveTime: TLabel;
    tsBackup: TTabSheet;
    rbBackup_auto: TRadioButton;
    rbBackup_prompt: TRadioButton;
    rbBackup_donothing: TRadioButton;
    Label9: TLabel;
    pnlBackupOptions: TPanel;
    Label8: TLabel;
    edtBackupDir: TEdit;
    btnFolder: TSpeedButton;
    chkOverwrite: TCheckBox;
    lblNarration: TLabel;
    rsMaxNarration: TRzSpinEdit;
    CBShowPrintOption: TCheckBox;
    chkCheckout: TCheckBox;
    tsLinks: TTabSheet;
    tsFiles: TTabSheet;
    gbTRFfiles: TGroupBox;
    lblClickOnBNotes: TLabel;
    gbWebPages: TGroupBox;
    Label10: TLabel;
    Egst101: TEdit;
    btnConfigureInternet: TButton;
    rbOpenTRFwithHandler: TRadioButton;
    rbOpenTRFwithBNotes: TRadioButton;
    lblFont: TLabel;
    btnReset: TButton;
    pnlCESFont: TPanel;
    chkExtendedMAPI: TCheckBox;
    cbceFont: TRzFontComboBox;
    cbSize: TRzComboBox;
    Label11: TLabel;
    chkUseSSL: TCheckBox;
    edtPortNo: TEdit;
    pnlUIStyle: TPanel;
    lblUIStyle: TLabel;
    Label12: TLabel;
    rbGUIStandard: TRadioButton;
    rbGUISimple: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rbMAPIClick(Sender: TObject);
    procedure chkMAPIClick(Sender: TObject);
    procedure chkAuthenticationClick(Sender: TObject);
    procedure btnResetColumnsClick(Sender: TObject);
    procedure chkShowHintClick(Sender: TObject);
    procedure rsAutoSaveTimeChange(Sender: TObject);
    procedure rbBackup_donothingClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure btnFolderClick(Sender: TObject);
    procedure btnConfigureInternetClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure chkExtendedMAPIClick(Sender: TObject);
    procedure cbSizeChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbceFontChange(Sender: TObject);
  private
    { Private declarations }
    CESFont: TFont;
    ExtendedMapiRegistered : boolean;
    procedure SetEnabledState;
    procedure UpdateFontLabel;
  public
    { Public declarations }
  end;

  procedure ShowOptions;

//******************************************************************************
implementation
{$R *.DFM}

uses
  madUtils,
  registryutils,
  Admin32,
  ComObj,
  Variants,
  bkXPThemes,
  bkHelp,
  bkConst,
  ImagesFrm,
  LogUtil,
  Globals,
  glConst,
  MainFrm,
  ShellUtils,
  WinUtils,
  ErrorMorefrm,
  UpdateMF,
  UpgradeHelper, BKDEFS, GenUtils, NewReportUtils;

const
  Unitname = 'OptionsFrm';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  CESFont := TFont.Create;
  SetpasswordFont(eMAPIPassword);
  SetpasswordFont(eSMTPPassword);
{$IFDEF SmartBooks}
   chkCaptions.Visible := false;
   chkShowCodeHint.Visible := false;
{$ENDIF}
   SetUpHelp;

   ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFolder.Glyph);

   if Assigned( CurrUser) then begin
      tsEmail.TabVisible := not CurrUser.HasRestrictedAccess;
   end;
end;

procedure TfrmOptions.FormDestroy(Sender: TObject);
begin
   CESFont.Free;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.FormShow(Sender: TObject);
var OutPortNo: Integer;
begin
   PageControl1.ActivePage := tsToolbar;
   BKHelpSetUp( Self, BKHelp.BKH_The_BankLink_Menu_Bar);

   if INI_Mail_Type = SMTP_MAIL then
   begin
    rbMAPI.Checked := false;
    rbSMTP.Checked := true;
   end
   else
   begin
    rbMAPI.Checked := true;
    rbSMTP.Checked := false;
   end;

   chkCaptions.checked := INI_ShowToolbarCaptions;
   chkShowHint.checked := INI_ShowFormHints;
   cbShowPrintOption.Checked := INI_ShowPrintOptions;
   {$IFNDEF SmartBooks}
   chkShowCodeHint.Checked := INI_ShowCodeHints;
   {$ENDIF}
   chkCheckout.Checked :=  INI_AllowCheckOut;
   rsAutoSaveTime.IntValue := INI_AutoSaveTime;
   rsAutoSaveTimeChange(rsAutoSaveTime);

   rbGUIStandard.Checked := (INI_UI_STYLE = UIS_Standard);
   rbGUISimple.checked   := (INI_UI_STYLE = UIS_Simple);

   chkMAPI.Checked     := INI_MAPI_Default;
   eProfileName.Text   := INI_MAPI_Profile;
   eMapiPassword.Text  := INI_MAPI_Password;
   eSMTP.Text          := INI_SMTP_Server;
   chkAuthentication.Checked := INI_SMTP_Auth;
   eAccountName.Text   := INI_SMTP_Account;
   eSmtpPassword.Text  := INI_SMTP_Password;
   eReturn.text        := INI_SMTP_From;
   nTimeOut.AsInteger  := INI_INTERNET_TIMEOUT;
   if TryStrToInt(INI_SMTP_PortNo,OutPortNo) then
    edtPortNo.Text := INI_SMTP_PortNo;
   chkUseSSL.Checked   := INI_SMTP_UseSSL;
   if INI_MAPI_UseExtended then
   begin
     //if already checked then assume is registered, this will avoid
     //registering every time the form is loaded
     ExtendedMapiRegistered := true;
     chkExtendedMAPI.Checked := true;
   end
   else
     chkExtendedMAPI.Checked := false;

   rbBackup_donothing.Checked := false;
   rbBackup_prompt.Checked    := false;
   rbBackup_auto.Checked := false;
   case INI_BackupLevel of
     0 : rbBackup_donothing.Checked := true;
     1 : rbBackup_prompt.Checked := true;
     2 : rbBackup_auto.Checked := true;
   else
     rbBackup_donothing.Checked := true;
   end;
   chkoverwrite.checked := INI_BackupOverwrite;
   edtBackupDir.Text := INI_BackupDir;
   rsMaxNarration.IntValue := INI_MAX_EXTRACT_NARRATION_LENGTH;
   if INI_Coding_Font = '' then  // Should not need this
      INI_Coding_Font := DefaultCESFontString;
   StrToFont(INI_Coding_Font,CESFont);
   UpdateFontLabel;

   //fill links tab
   Egst101.Text := PRACINI_GST101Link;

   //fill file assocation tab
   if tsFiles.TabVisible then
   begin
      gbTRFfiles.Caption := glConst.ECoding_App_Name + ' files';
      lblClickOnBNotes.Caption := 'When I click on a ' + glConst.ECODING_APP_NAME + ' file';
      rbOpenTRFwithHandler.Caption := '&Ask me whether to open it in ' +
                                     SHORTAPPNAME + ' or ' +
                                     glConst.ECODING_APP_NAME;
      rbOpenTRFwithBNotes.Caption := 'O&pen it with ' + glConst.ECODING_APP_NAME;

      case GetTRFAssociation of
        AS_BNotes     : rbOpenTRFwithBNotes.Checked := true;
        AS_TRFHandler : rbOpenTRFwithHandler.Checked := true;
      end;
    end;

   SetEnabledState;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   chkCaptions.Hint :=
                    'Show toolbar buttons captions|'+
                    'Display the names of the toolbar buttons';
   chkShowHint.Hint :=
                    'Show helpful hints|'+
                    'Show hints when you hover over an item';
   chkShowCodeHint.Hint :=
                    'Show chart code hints|'+
                    'Show chart code hints in Code Entries Screen';
   cbShowPrintoption.Hint :=
                    'Always show printer options before printing|' +
                    'Always show printer options before printing';

   chkCheckout.Hint :=
                    'Allow Check out|'+
                    'Allow files to be checked out';
   rsAutoSaveTime.Hint :=
                    'Set the time delay between auto saves|'+
                    'Set the time delay between auto saving the client';
//   btnResetColumns.Hint   :=
//                    'Reset the default column widths|'+
//                    'Reset the default column widths in the Code Entries Screen';
   rbMAPI.Hint      :=
                    'Select this to send E-mail using MAPI Mail (eg Outlook)|'+
                    'Use a MAPI compliant mail program such as OutLook to send E-mail';
   chkMAPI.Hint     :=
                    'Check this to use the Default MAPI Profile|'+
                    'Check this to use the Default MAPI profile when logging in to your MAPI client';
   eProfileName.Hint :=
                    'Enter a MAPI Profile name|'+
                    'Enter a MAPI profile name to login to MAPI with';
   eMAPIPassword.Hint :=
                    'Enter the password for the above profile|'+
                    'Enter a password for the MAPI profile specified above';
   rbSMTP.Hint      :=
                    'Select this to send E-mail using an Internet Mail Server|'+
                    'Use an Internet Mail Server to send E-mail';
   eSMTP.Hint       :=
                    'Enter the address of your Internet Mail SMTP Server|'+
                    'Enter the address of your Internet Mail SMTP Server';
   eReturn.Hint     :=
                    'Enter your Return E-mail Address|'+
                    'Enter your Return Address to appear on all E-mail sent';
   chkAuthentication.Hint :=
                    'Check this if your mail server requires a user name|'+
                    'Check this if your mail server requires you to enter a user name';
   eAccountName.Hint :=
                    'Enter an Account Name to use when logging in|'+
                    'Enter an Account Name to use when logging in';
   eSMTPPAssword.Hint :=
                    'Enter an additional Password|'+
                    'Enter a password for your additional login';
   nTimeOut.Hint      :=
                    'Enter how many seconds to wait before disconnecting|' +
                    'Enter how many seconds to wait for a response from the server before disconnecting';

   rsMaxNarration.Hint :=
                    'Set the maximum number of characters to extract from the narration|'+
                    'Set the maximum number of characters to extract from the narration';

   eGST101.Hint := 'URL for the IRD''s online GST101 form';

   edtPortNo.Hint := 'Enter Port Number|Enter Port Number';

   chkUseSSL.Hint := 'Use SSL|Use SSL';

   BKHelpSetup( Self, 0);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.btnOkClick(Sender: TObject);
var OutPortNo: Integer;
begin
  {toolbars}
  INI_ShowToolbarCaptions := chkCaptions.checked;
  INI_ShowFormHints       := chkShowHint.Checked;

{$IFNDEF SmartBooks}
  INI_ShowCodeHints       := chkShowCodeHint.Checked;
  with frmMain do begin
    SetToolBarCaptionState( INI_ShowToolbarCaptions );
  end;
{$ENDIF}
  INI_AllowCheckOut := chkCheckout.Checked;
  INI_AutoSaveTime  := rsAutoSaveTime.IntValue;

  {email}
  if rbMAPI.Checked then
    INI_Mail_Type := MAPI_MAIL
  else
    INI_Mail_Type := SMTP_MAIL;

  INI_SMTP_Server   := eSMTP.Text;
  INI_SMTP_Auth     := chkAuthentication.Checked;
  INI_SMTP_Account  := eAccountName.Text;
  INI_SMTP_Password := eSMTPPassword.Text;
  INI_SMTP_From     := eReturn.Text;

  INI_MAPI_Default  := chkMAPI.Checked;
  INI_MAPI_Profile  := eProfileName.text;
  INI_MAPI_Password := eMAPIPassword.text;
  INI_MAPI_UseExtended := chkExtendedMAPI.Checked;

  INI_INTERNET_TIMEOUT := nTimeOut.AsInteger;
  if TryStrToInt(edtPortNo.Text,OutPortNo) then
  INI_SMTP_PortNo      := edtPortNo.Text;
  INI_SMTP_UseSSL      := chkUseSSL.Checked;

  INI_BackupDir := IncludeTrailingPathDelimiter(Trim( edtBackupDir.Text));
  INI_BackupOverwrite := chkOverwrite.Checked;
  INI_BackupLevel := 0;
  if rbBackup_prompt.Checked then
    INI_BackupLevel := 1;
  if rbBackup_auto.Checked then
    INI_BackupLevel := 2;

  INI_Coding_Font := FontToStr(CESFont);

  if rsMaxNarration.IntValue = 0 then
    INI_MAX_EXTRACT_NARRATION_LENGTH := 200
  else
    INI_MAX_EXTRACT_NARRATION_LENGTH := rsMaxNarration.IntValue;

  if (chkCheckout.Visible) then
  begin
    UpdateSystemMenus;
    UpdateMenus;
  end;

  if CBShowPrintOption.Visible then
  if  INI_ShowPrintOptions <> CBShowPrintOption.Checked then begin
     INI_ShowPrintOptions := CBShowPrintOption.Checked;
     if Assigned(CurrUser) then
        CurrUser.ShowPrinterDialog := INI_ShowPrintOptions;
  end;

  if tsFiles.TabVisible and rbOpenTRFwithBNotes.Enabled then
  begin
    if rbOpenTRFwithBNotes.Checked then
      SetTRFAssociation( as_BNotes);
    if rbOpenTRFwithHandler.Checked then
      SetTRFAssociation( as_TRFHandler);
  end;

  if rbGUISimple.Checked then
    INI_UI_STYLE := UIS_SIMPLE
  else
    INI_UI_STYLE := UIS_STANDARD;

  //links tab
  PRACINI_GST101Link := Egst101.Text;
  SetMadEmailOptions;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.SetEnabledState;
var
  state : boolean;
begin
   {mapi panel}
   state :=rbMAPI.checked;
   chkMAPI.enabled := state;
   chkExtendedMAPI.Enabled := state;

   state := state and not chkMAPI.Checked;
   label4.enabled        := state;
   label5.enabled        := state;

   eMAPIPassword.Enabled := state;
   eProfileName.Enabled  := state;

   {smtp panel}
   State := rbSMTP.Checked;
   label1.enabled            := state;
   eSMTP.Enabled             := state;
   chkAuthentication.enabled := state;
   chkUseSSL.enabled         := state;
   label6.enabled            := state;
   label11.enabled           := state;
   eReturn.enabled           := state;
   nTimeout.enabled          := state;
   edtPortNo.enabled         := state;
   label7.enabled            := state;


   State := state and chkAuthentication.Checked;

   label2.enabled := state;
   label3.enabled := state;
   eAccountName.enabled  := state;

   eSMTPPassword.enabled := state;

   //set state in file associations tab
   if tsFiles.TabVisible then
   begin
     state := RegistryUtils.CanOpenEditClassesKey( regStr_trfFile);

     rbOpenTRFwithBNotes.Enabled := state;
     rbOpenTRFwithHandler.Enabled := state;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.rbMAPIClick(Sender: TObject);
begin
  SetEnabledState;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.chkMAPIClick(Sender: TObject);
begin
   if chkMAPI.Checked then
   begin
     eProfileName.text := '';
     eMAPIPassword.text := '';
   end;

   SetEnabledState;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.cbceFontChange(Sender: TObject);
begin
   CESFont.Name := cbCEFont.FontName;
   UpdateFontLabel;
end;

procedure TfrmOptions.cbSizeChange(Sender: TObject);
begin
  CESFont.Size := StrToInt(cbSize.Text);
  cbCEFont.FontSize := CESFont.Size;
  UpdateFontLabel;
end;

procedure TfrmOptions.chkAuthenticationClick(Sender: TObject);
begin
   if not chkAuthentication.Checked then
   begin
     eAccountName.text := '';
     eSMTPPassword.text := '';
   end;

   SetEnabledState;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.chkExtendedMAPIClick(Sender: TObject);
var
  sMsg : string;
begin
  //make sure extended mapi dll is registered
  if chkExtendedMAPI.Checked then
  begin
     if not ExtendedMapiRegistered then
     begin
       if not WinUtils.RegisterOCX( Globals.ExecDir + Globals.ExtendedMapiDllName) then
       begin
         sMsg := 'Error enabling Extended MAPI [ ' + IntToStr(Windows.GetLastError)  + '] ';
         HelpfulErrorMsg( sMsg, 0);
         chkExtendedMapi.checked := false;
       end
       else
       begin
         ExtendedMapiRegistered := true;
         LogUtil.LogMsg(LogUtil.lmInfo, UnitName, 'Extended MAPI enabled ' + Globals.ExtendedMapiDllName);
       end;
     end;
  end
  else
  begin
    //could unregister it but not really any need
    //UnRegisterOCX( Globals.ExecDir + Globals.ExtendedMapiDllName);
    ExtendedMapiRegistered := false;
  end;
  //
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.btnResetClick(Sender: TObject);
begin
  StrToFont(DefaultCESFontString,CESFont);
  cbceFont.SelectedFont := CESFont;
  UpdateFontLabel;
end;

procedure TfrmOptions.btnResetColumnsClick(Sender: TObject);
begin
//  btnResetColumns.SetFocus;
//  ResetCodingColumns;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmOptions.chkShowHintClick(Sender: TObject);
begin
   INI_ShowFormHints := chkShowHint.Checked;
   Self.ShowHint    := INI_ShowFormHints;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ShowOptions;
var
  MyDlg : TfrmOptions;
begin
  MyDlg := TFrmOptions.Create(Application.MainForm);
  try
    if Assigned(AdminSystem) then begin
      MyDlg.Label18.Visible           := False;
      MyDlg.rsAutoSaveTime.Visible    := False;
      MyDlg.lblAutoSaveTime.Visible   := False;
      MyDlg.chkCheckout.Visible       := False;
      MyDlg.tsBackup.TabVisible       := False;
      MyDlg.lblNarration.Visible      := False;
      MyDlg.rsMaxNarration.Visible    := False;
      MyDlg.CBShowPrintOption.Visible := False;
      Mydlg.tsLinks.TabVisible        := False;
      MyDlg.btnConfigureInternet.Visible := false;
      MyDlg.cbceFont.Visible := False;
      MyDlg.cbSize.Visible := False;
      MyDlg.btnReset.Visible := False;
      MyDlg.lblFont.Visible := False;
      MyDlg.pnlCESFont.Visible := False;
      MyDlg.pnlUIStyle.Visible := false;
    end
    else
    begin
      //hide links tab if not NZ
      if assigned( myClient) then
      begin
        if ( myClient.clFields.clCountry <> whNewZealand) then
          MyDlg.tsLinks.TabVisible := false;
      end
      else
      begin
        //no client, guess from users country code
        if (WinUtils.GetDefaultCountryCode = '61') then
          MyDlg.tsLinks.TabVisible := false;
      end;
    end;

    //only show the file association tab if relevant
    //both the trf handler and bnotes need to be installed, otherwise the user
    //gets to choose irrelevant options
    myDlg.tsFiles.TabVisible := TRFHandlerInstalled and BNotesInstalled and (Pos('Vista', WinUtils.GetWinVer) = 0);

    //****************
    MyDlg.ShowModal;
    //****************


  finally
    MyDlg.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.rsAutoSaveTimeChange(Sender: TObject);
begin
  if (TRzSpinEdit(Sender).Value = 0) then
    lblAutoSaveTime.Caption := 'minutes (OFF)'
  else
    lblAutoSaveTime.Caption := 'minutes';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmOptions.rbBackup_donothingClick(Sender: TObject);
begin
  pnlBackupOptions.Visible := not rbBackup_doNothing.Checked;
end;

procedure TfrmOptions.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tsEmail then
    BKHelpSetUp( Self, BKHelp.BKH_E_mailing_from_within_BankLink)
  else
  if PageControl1.ActivePage = tsToolbar then
    BKHelpSetUp( Self, BKHelp.BKH_The_BankLink_Menu_Bar)
  else
  if PageControl1.ActivePage = tsBackup then
    BKHelpSetUp( Self, BKHelp.BKH_Backing_up_and_restoring_BankLink_Books_files)
  else
    BKHelpSetUp( Self, 0);
end;



procedure TfrmOptions.btnFolderClick(Sender: TObject);
var
  test : string;
begin
  test := edtBackupDir.Text;

  if BrowseFolder( test, 'Select a folder to backup this file to' ) then
    edtBackupDir.Text := test;
end;


procedure TfrmOptions.btnConfigureInternetClick(Sender: TObject);
var
  EditUpdateServer : boolean;
begin
  EditUpdateServer := ( AdminSystem = nil) and ( MyClient <> nil);

  UpgradeHelper.EditInternetSettings( EditUpdateServer);
end;

procedure TfrmOptions.UpdateFontLabel;
var S: string;
    I: Integer;
begin
  pnlCESFont.Font.Assign(CESFont);
  cbceFont.FontName := CESFont.Name;
  S := intToStr(CESFont.Size);
  I := cbSize.Items.IndexOf(S);
  if I <0 then
     cbSize.ItemIndex := cbSize.Items.Add(S)
  else
     cbSize.ItemIndex := I;
end;

end.

