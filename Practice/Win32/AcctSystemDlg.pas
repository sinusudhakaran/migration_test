unit AcctSystemDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Buttons,
  Software,
  ExtCtrls,
  OsFont,
  SelectBusinessFrm;

type
  TdlgAcctSystem = class(TForm)
    gbxAccounting: TGroupBox;
    lblFrom: TLabel;                     
    eFrom: TEdit;                                                                               
    eTo: TEdit;
    lblSaveTo: TLabel;                                                        
    btnFromFolder: TSpeedButton;
    btnToFolder: TSpeedButton;
    btnCheckBankManID: TButton;
    Label1: TLabel;
    Label2: TLabel;
    cmbSystem: TComboBox;
    eMask: TEdit;
    chkLockChart: TCheckBox;
    btnSetBankpath: TButton;
    pnlMASLedgerCode: TPanel;
    btnMasLedgerCode: TSpeedButton;
    edtExtractID: TEdit;
    chkUseCustomLedgerCode: TCheckBox;
    gbxTaxInterface: TGroupBox;
    Label5: TLabel;
    Label8: TLabel;
    lblTaxLedger: TLabel;
    eTaxLedger: TEdit;
    edtSaveTaxTo: TEdit;
    cmbTaxInterface: TComboBox;
    btnTaxFolder: TSpeedButton;
    gbxWebExport: TGroupBox;
    Label4: TLabel;
    cmbWebFormats: TComboBox;
    gbType: TGroupBox;
    lblLoadDefaults: TLabel;
    rbAccounting: TRadioButton;
    rbSuper: TRadioButton;
    GBExtract: TGroupBox;
    cbExtract: TComboBox;
    ckExtract: TCheckBox;
    Label3: TLabel;
    pnlControls: TPanel;
    btndefault: TButton;
    btnOk: TButton;
    btnCancel: TButton;
    Shape1: TShape;
    btnConnectBGL: TButton;
    lblBGL360FundName: TLabel;
    btnConnectMYOB: TButton;
    lblFirmName: TLabel;
    lblPLClientName: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnFromFolderClick(Sender: TObject);
    procedure btnToFolderClick(Sender: TObject);
    procedure cmbSystemChange(Sender: TObject);
    procedure cmbTaxInterfaceChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnTaxFolderClick(Sender: TObject);
    procedure btnCheckBankManIDClick(Sender: TObject);
    procedure eFromChange(Sender: TObject);
    procedure chkUseCustomLedgerCodeClick(Sender: TObject);
    procedure btnMasLedgerCodeClick(Sender: TObject);
    procedure btnSetBankpathClick(Sender: TObject);
    procedure rbAccountingClick(Sender: TObject);
    procedure btndefaultClick(Sender: TObject);
    procedure ckExtractClick(Sender: TObject);
    procedure cmbWebFormatsChange(Sender: TObject);
    procedure pnlBGLConnectClick(Sender: TObject);
    procedure btnConnectBGLClick(Sender: TObject);
    procedure btnConnectMYOBClick(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
    AutoRefreshFlag : Boolean;
    fAlternateID : string;
    InSetup: Boolean;
    WebFormatChanged : Boolean;

    FInWizard: Boolean;
    FOldLoadFrom : String;
    FOldWebExportFormat: Byte;
    FOldID: string;
    FOldName: string;
    FOldAccountingSystem : Byte;

//DN Not required    BGLServerNoSignRequired : Boolean;
    procedure ShowBankLinkOnlineConfirmation;
    function VerifyForm : boolean;
    procedure FillSystemList;
    procedure DoReBranding;
    procedure SetupInitialSystem(aInWizard:Boolean);
  protected
    procedure UpdateActions; override;
  public
    { Public declarations }
    function Execute(var AutoRefreshDone : Boolean; InWizard: Boolean = False) : boolean;
  end;

function EditAccountingSystem(w_PopupParent: TForm; var AutoRefreshDone : Boolean; ContextID : Integer; InWizard: Boolean = False) : boolean;

//------------------------------------------------------------------------------
implementation

{$R *.DFM}

uses
  BulkExtractFrm,
  Admin32,
  ComObj,
  ComboUtils,
  BKHelp,
  globals,
  glConst,
  bkconst,
  imagesfrm,
  LogUtil,
  updatemf,
  InfoMoreFrm,
  WarningMoreFrm,
  ErrorMoreFrm,
  YesNoDlg,
  SyDefs,
  Import32,
  bkXPThemes,
  ShellUtils,
  XPAUtils,
  Sol6_Const,
  Select_Mas_GlFrm,
  Registry,
  myobao_utils,
  BKDEFS,
  clObj32,
  WinUtils,
  DesktopSuper_Utils,
  BankLinkOnlineServices,
  BlopiServiceFacade,
  BanklinkOnlineSettingsFrm,
  bkBranding,
  bkProduct,
  uBGLServer,
  INISettings,
  FundListSelectionFrm,
  Files,
  SimpleFund,
  myMYOBSignInFrm,
  PracticeLedgerObj,
  bkContactInformation,
  CashbookMigrationRestData,
  AuditMgr,
  ipsHTTPS,
  AppMessages;

const
  UnitName = 'AcctSystemDlg';
  NO_DEFAULT_SYSTEM = 'No defaults were loaded because a default %s system has not been set up.';

var
  DebugMe                 : boolean = false;
  DebugGenericCommsErrors : boolean = false;
//------------------------------------------------------------------------------
procedure TdlgAcctSystem.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);

   FInWizard := False;
   
   btnFromFolder.Glyph := ImagesFrm.AppImages.imgFindStates.Picture.Bitmap;
   ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnToFolder.Glyph);
   ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnMasLedgerCode.Glyph);
   ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnTaxFolder.Glyph);

   //btnCheckBankManID.Top := eTo.Top;
   //btnCheckBankManID.Left := eTo.Left;

   eMask.MaxLength := BKCONST.MaxBK5CodeLen;

   DoReBranding();

   SetUpHelp;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.pnlBGLConnectClick(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.rbAccountingClick(Sender: TObject);
begin
   if not assigned(AdminSystem) then
      Exit; // why would it not be...
   if Insetup then
      Exit;

   FillSystemlist;
   if rbaccounting.Checked then
      ComboUtils.SetComboIndexByIntObject(AdminSystem.fdFields.fdAccounting_System_Used, cmbSystem)
   else
      ComboUtils.SetComboIndexByIntObject(AdminSystem.fdFields.fdSuperfund_System, cmbSystem);

   cmbSystemChange(nil);
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   cmbSystem.Hint   :=
                    'Select the main accounting system used for this client|'+
                    'Select the main accounting system used for this client';
   eMask.Hint       :=
                    'Enter the Account Code Mask used for client|'+
                    'Enter the Account Code Mask used for client';
   chkLockChart.Hint   :=
                    'Lock the Chart of Accounts|'+
                    'If the Chart is locked then it cannot be refreshed from your accounting system';
   eFrom.Hint       :=
                    'Enter a directory path or filename to refresh the client''s Chart of Accounts from|'+
                    'Enter a directory path or filename to refresh the client''s Chart of Accounts from';
   eTo.Hint         :=
                    'Enter a directory path to Extract Data to|'+
                    'Enter a directory path  to Extract Data to';
   eTaxLedger.Hint  :=
                    'Enter the Tax Ledger Code used by your Account System for this Client';
end;

procedure TdlgAcctSystem.SetupInitialSystem(aInWizard:Boolean);
var
  LCLRec: pClient_File_Rec;
  i : Integer;
begin
  InSetup := True;
  try
    FInWizard := aInWizard;
    WebFormatChanged := false;
    okPressed := false;
    AutoRefreshFlag := False;
    cmbSystem.Items.Clear;
    if Assigned(AdminSystem) then
    begin
      RefreshAdmin;
      if CanBulkExtract then begin
         GBExtract.Visible := True;
         LCLRec := AdminSystem.fdSystem_Client_File_List.FindCode(MyClient.clFields.clCode);
         if Assigned(lCLRec) then begin
            // Fill in the details
            CkExtract.Checked := FillExtractorComboBox(cbExtract, LCLRec.cfBulk_Extract_Code, False);
         end else begin
            CkExtract.Checked := FillExtractorComboBox(cbExtract, MyClient.clFields.clTemp_FRS_Job_To_Use, False);
         end;
      end else
         GBExtract.Visible := False;

      btnDefault.Visible := True;
    end
    else
    begin
      btnDefault.Visible := False;
      GBExtract.Visible := False;
    end;
    with MyClient.clFields do
    begin
      Insetup := true;
      cmbWebFormats.Clear;
      for i := wfMin to wfMax do
      begin
        if (wfNames[i] = BRAND_NOTES_ONLINE) then
        begin
          if (UseBankLinkOnline and
              ProductConfigService.OnLine and
              ProductConfigService.IsNotesOnlineEnabled) or
              (MyClient.clFields.clWeb_Export_Format = wfWebNotes) then
          begin
            if not ExcludeFromWebFormatList(clCountry, i) then
              cmbWebFormats.Items.AddObject(wfNames[i], TObject(i));
          end;
        end
        else
        begin
          if not ExcludeFromWebFormatList(clCountry, i) then
            cmbWebFormats.Items.AddObject(wfNames[i], TObject(i));
        end;
      end;

      if clWeb_Export_Format = 255 then
         clWeb_Export_Format := wfDefault;

      case clCountry of
       whNewZealand :
         begin
            gbxTaxInterface.Visible := False;
            gbType.Visible := False;

            FillSystemList;

            if clAccounting_System_Used in [snMin..snMax] then begin
               ComboUtils.SetComboIndexByIntObject(claccounting_system_used, cmbSystem);
            end else
               ComboUtils.SetComboIndexByIntObject(snOther, cmbSystem);

            cmbTaxInterface.Items.AddObject( tsNames[ tsMin], TObject( tsMin));
            cmbTaxInterface.ItemIndex := 0;
            edtSaveTaxTo.Text         := '';
         end;

       whAustralia :
         begin
            if assigned(AdminSystem)
            and AdminSystem.DualAccountingSystem then begin
               gbType.Visible := True;
               if software.IsSuperFund(whAustralia,clAccounting_System_Used) then begin
                  rbSuper.Checked := True;
                  ActiveControl := rbSuper;
               end
               else begin
                  rbAccounting.Checked := True;
                  ActiveControl := rbAccounting;
               end;
            end else
               gbType.Visible := False;
            FillSystemList;

            if clAccounting_System_Used in [saMin..saMax] then begin
               ComboUtils.SetComboIndexByIntObject(claccounting_system_used, cmbSystem);
            end else
               ComboUtils.SetComboIndexByIntObject(snOther, cmbSystem);

            gbxTaxInterface.Visible  := True;

            for i := tsMin to tsMax do begin
              cmbTaxInterface.Items.AddObject( tsNames[ tsSortOrder[i]], TObject( tsSortOrder[i]));
            end;
            cmbTaxInterface.ItemIndex := 0;
            ComboUtils.SetComboIndexByIntObject( clTax_Interface_Used, cmbTaxInterface);

            edtSaveTaxTo.Text    := clSave_Tax_Files_To;
            eTaxLedger.Text      := clTax_Ledger_Code;
            eTaxLedger.Visible   := clTax_Interface_Used = tsBAS_Sol6ELS;
            lblTaxLedger.Visible := clTax_Interface_Used = tsBAS_Sol6ELS;
         end;

       whUK :
         begin
            gbxTaxInterface.Visible := False;
            gbType.Visible := False;

            for i := suMin to suMax do begin
              if (not Software.ExcludeFromAccSysList(clCountry, i)) or ( i = claccounting_system_used) then
                cmbSystem.items.AddObject(suNames[i], TObject( i ) );
            end;
            cmbSystem.ItemIndex := suOther;
            if clAccounting_System_Used in [suMin..suMax] then begin
               for i := 0 to ( cmbSystem.Items.Count - 1 ) do begin
                  if ( Integer( cmbSystem.Items.Objects[i] ) = claccounting_system_used ) then begin
                     cmbSystem.ItemIndex := i;
                  end;
               end;
            end;

            cmbTaxInterface.Items.AddObject( tsNames[ tsMin], TObject( tsMin));
            cmbTaxInterface.ItemIndex := 0;
            edtSaveTaxTo.Text         := '';
         end;
      end; {case}
      cmbSystemChange(nil);
      if (cmbWebFormats.ItemIndex < 0) then
        ComboUtils.SetComboIndexByIntObject(MyClient.clFields.clWeb_Export_Format, cmbWebFormats);

      //If the client is on notes but the practice is not only then they shouldn't be able to change the web export format off notes.
      if MyClient.clFields.clWeb_Export_Format = wfWebNotes then
      begin
        if not Assigned(AdminSystem) then
         cmbWebFormats.Enabled := False;
      end;

      chkLockChart.Checked := clChart_Is_Locked;
      chkUseCustomLedgerCode.Checked := clUse_Alterate_ID_for_extract;
      if clUse_Alterate_ID_for_extract then
      begin
        edtExtractID.text := clAlternate_Extract_ID;
        fAlternateID := clAlternate_Extract_ID;
        edtExtractID.Enabled := true;
        btnMasLedgerCode.Enabled := true;
      end
      else
      begin
        edtExtractID.text := clCode;
        edtExtractID.Enabled := false;
        btnMasLedgerCode.Enabled := false;
      end;

      eMask.text  := clAccount_Code_Mask;
      eFrom.Text  := clLoad_Client_Files_From;
      eTo.text    := clSave_Client_Files_To;

      FOldLoadFrom := '';
      FOldID := '';
      FOldName := '';
      
      if IsMYOBLedger(clCountry, clAccounting_System_Used) then
      begin
        FOldID := MyClient.clExtra.cemyMYOBClientIDSelected;
        FOldName := MyClient.clExtra.cemyMYOBClientNameSelected;
      end
      else if (clCountry = whAustralia) and (clAccounting_System_Used = saBGL360) then
        FOldID := MyClient.clExtra.ceBGLFundIDSelected
      else
        FOldLoadFrom := clLoad_Client_Files_From;        
    end;
  finally
    InSetup := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.UpdateActions;
begin
  inherited;
  cbExtract.Enabled := ckExtract.Checked;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btnOkClick(Sender: TObject);
begin
  okPressed := true;
  close;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btnCancelClick(Sender: TObject);
begin
  if Assigned(MyClient) and IsMYOBLedger(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used) then
  begin
    MyClient.clFields.clAccounting_System_Used := FOldAccountingSystem;
    MyClient.clExtra.cemyMYOBClientIDSelected := FOldID;
    MyClient.clExtra.cemyMYOBClientNameSelected := FOldName;
  end;
  
  OkPressed := false;
  close;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btnFromFolderClick(Sender: TObject);
var
  Path : string;
  AcctSystem : integer;
  result : integer;
begin
  //is the accounting system APS
  with cmbSystem do
  begin
    AcctSystem := Integer( Items.Objects[ ItemIndex ] );
  end;

  //if interface specifc action then
  //  browse using interface
  //else
  //  using standard file interface
  if Software.IsPA7Interface( MyClient.clFields.clCountry, AcctSystem) then
  begin
    Path := eFrom.Text;
    result := GetXPALedgerPath( Path);
    case result of
      bkXPA_COM_Refresh_Supported_User_Cancelled :
        Exit;
      bkXPA_COM_Refresh_Supported_User_Selected_Ledger :
      begin
        eFrom.Text := Path;
        Exit;
      end;
    end;
  end
  else
  if Software.IsXPA8Interface( MyClient.clFields.clCountry, AcctSystem) then
  begin
    Path := eFrom.Text;
    result := GetXPALedgerPath( Path);
    case result of
      bkXPA_COM_Refresh_Supported_User_Selected_Ledger :
        eFrom.Text := Path;
      bkXPA_COM_Refresh_NotSupported :
        HelpfulErrorMsg( 'Could not access the list of ' + bkConst.snNames[ snXPA] +
                         ' ledgers.  Please ensure the correct software is installed.', 0);
    end;
    //Dont browse folders, need to exit
    Exit;
  end
  else
  if Software.CanUseMYOBAO_DLL_Refresh( MyClient.clFields.clCountry, AcctSystem) then
  begin
    //can use bclink.dll to get a list of account ledgers

    Path := ExtractFileName(ExcludeTrailingBackslash(eFrom.Text));
    result := GetMYOBLedgerPath( Path);
    case result of
      bkMYOBAO_COM_Refresh_Supported_User_Selected_Ledger :
      begin
        eFrom.Text := Path;
      end;
      bkMYOBAO_COM_Refresh_AccessDenied :
        HelpfulErrorMsg( 'Could not access the list of ' + GetMYOBAO_Name(MyClient.clFields.clCountry) +
                         ' ledgers.  Access Denied.', 0);
      bkMYOBAO_COM_Refresh_NotSupported :
        HelpfulErrorMsg( 'Could not access the list of ' + GetMYOBAO_Name(MyClient.clFields.clCountry) +
                         ' ledgers.  Please ensure the correct software is installed.', 0);
    end;
    Exit;
  end
  else
  if Software.IsSol6_COM_Interface( MyClient.clFields.clCountry, AcctSystem) then
  begin
    //can use bclink.dll to get a list of account ledgers
    Path := ExtractFileName( eFrom.Text);
    result := SelectMAS_GL_Path( Path, INI_SOL6_SYSTEM_PATH);
    case result of
      bkS6_COM_Refresh_Supported_User_Selected_Ledger :
      begin
        eFrom.Text := Path;
      end;
      bkS6_COM_Refresh_NotSupported :
        HelpfulErrorMsg( 'Could not access the list of ' + GetMYOBAO_Name(MyClient.clFields.clCountry) +
                         ' ledgers.  Please ensure the correct software is installed.', 0);
    end;
    Exit;
  end;


  Path := eFrom.Text;
  if BrowseFolder( Path, 'Select the Folder to Load Chart From' ) then
     eFrom.Text := Path;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btnToFolderClick(Sender: TObject);
var
  Path : string;
  AcctSystem : integer;
  result : integer;
begin
  with cmbSystem do
  begin
    AcctSystem := Integer( Items.Objects[ ItemIndex ] );
  end;
  //if interface specifc action then
  //  browse using interface
  //else
  //  using standard file interface
  if Software.IsXPA8Interface( MyClient.clFields.clCountry, AcctSystem) then
  begin
    Path := eTo.Text;
    result := GetXPALedgerPath( Path);
    case result of
      bkXPA_COM_Refresh_Supported_User_Selected_Ledger :
        eTo.Text := Path;
      bkXPA_COM_Refresh_NotSupported :
        HelpfulErrorMsg( 'Could not access the list of ' + bkConst.snNames[ snXPA] +
                         ' ledgers.  Please ensure the correct software is installed.', 0);
    end;

    Exit;
  end;

  Path := eTo.Text;
  if BrowseFolder( Path, 'Select the Folder to Save Entries To' ) then
     eTo.Text := Path;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.cmbSystemChange(Sender: TObject);
var
  SelectedSystem : integer;
  BGLServer: TBGLServer;
  OldCursor : TCursor;

  procedure SetSaveToField(Value: Boolean);
  begin
    lblSaveTo.Enabled := Value;
    eTo.Enabled := Value;
    btnToFolder.Enabled := Value;
  end;

  procedure SetCanRefresh(Value: Boolean);
  begin
    lblFrom.Enabled := Value;
    eFrom.Enabled   := Value;
    btnFromFolder.Enabled := Value;
  end;
  
begin
  if Assigned(Sender)
  and Insetup then
    Exit;

  if cmbSystem.ItemIndex < 0 then
    Exit;

  SelectedSystem := Integer( cmbSystem.Items.Objects[ cmbSystem.ItemIndex ] );

  SetCanRefresh(Software.CanRefreshChart(MyClient.clFields.clCountry, SelectedSystem));
  SetSaveToField(Software.UseSaveToField(MyClient.clFields.clCountry, SelectedSystem));

  btnCheckBankManID.Visible := Software.CanUseMYOBAO_DLL_Refresh( MyClient.clFields.clCountry, SelectedSystem);

  //check current bank path variable
  if Software.IsMYOBAO_7( MyClient.clFields.clCountry, SelectedSystem) and WinUtils.IsWin2000_or_later then
  begin
   //only show button if is not set or is different
   btnSetBankpath.Visible := not myobao_utils.BankPathIsSet;
  end
  else
   btnSetBankPath.Visible := false;

  if Software.IsSol6_COM_Interface( MyClient.clFields.clCountry, SelectedSystem) then
  begin
   if not pnlMASLedgerCode.visible then begin
     Self.Height := Self.Height + pnlMASLedgerCode.Height;
     gbxAccounting.Height := gbxAccounting.Height + pnlMASLedgerCode.Height;
     pnlMASLedgerCode.visible := true;
   end;
  end
  else
  begin
   if pnlMASLedgerCode.visible then begin
     gbxAccounting.Height := gbxAccounting.Height - pnlMASLedgerCode.Height;
     Self.Height := Self.Height - pnlMASLedgerCode.Height;
     pnlMASLedgerCode.visible := false;
   end;
  end;
//DN BGL360- UI changes  lblFrom.Visible := (SelectedSystem <> saBGL360);
//DN BGL360- UI changes    eFrom.Visible := lblFrom.Visible;
//DN BGL360- UI changes    btnFromFolder.Visible := lblFrom.Visible;
  eFrom.Visible := (not((SelectedSystem in [saBGL360]) or IsMYOBLedger(MyClient.clFields.clCountry, SelectedSystem))); //DN BGL360- UI changes

  btnFromFolder.Visible := eFrom.Visible; //DN BGL360- UI changes

  btnConnectBGL.Visible := (SelectedSystem = saBGL360);
  btnConnectBGL.Enabled := ( Assigned( AdminSystem) or AdminExists );
  lblBGL360FundName.Visible := btnConnectBGL.Visible;
  lblBGL360FundName.Enabled := btnConnectBGL.Enabled;

  btnConnectMYOB.Visible := IsMYOBLedger(MyClient.clFields.clCountry, SelectedSystem);
  btnConnectMYOB.Enabled := ( Assigned( AdminSystem) or AdminExists );
  lblSaveTo.Visible := (not btnConnectMYOB.Visible);
  eTo.Visible := lblSaveTo.Visible;
  btnToFolder.Visible := lblSaveTo.Visible;
  lblPLClientName.Visible := btnConnectMYOB.Visible;

  //lblFirmName.Visible := btnConnectMYOB.Visible;
  if SelectedSystem = saBGL360 then
  begin
  //DN Not required    BGLServerNoSignRequired := True;
    btnConnectBGL.Caption := 'BGL Sign in';
    btnConnectBGL.Hint    := 'Sign in and select a Fund to refresh the client''s Chart of Accounts from';
    lblBGL360FundName.Caption := '';
    lblBGL360FundName.Font.Color := clWindowText;
    BGLServer := TBGLServer.Create(Nil,
                        DecryptAToken(Globals.PRACINI_BGL360_Client_ID,Globals.PRACINI_Random_Key),
                        DecryptAToken(Globals.PRACINI_BGL360_Client_Secret,Globals.PRACINI_Random_Key),
                        Globals.PRACINI_BGL360_API_URL);
    try
      if Assigned(AdminSystem) then
      begin
        // Get all BGL values from client file and
        BGLServer.Set_Auth_Tokens(AdminSystem.fdFields.fdBGLAccessToken,
                  AdminSystem.fdFields.fdBGLTokenType,
                  AdminSystem.fdFields.fdBGLRefreshToken,
                  AdminSystem.fdFields.fdBGLTokenExpiresAt);
//DN Authentication logic flow does not work
        if BGLServer.CheckTokensExist then
          if BGLServer.CheckForAuthentication then begin
            btnConnectBGL.Caption := 'Fund';
            btnConnectBGL.Hint    := 'Select a Fund to refresh the client''s Chart of Accounts from';
          end;
//DN Not required        else
//DN Not required          BGLServerNoSignRequired := False;

        if Trim(MyClient.clExtra.ceBGLFundNameSelected) <> '' then begin
          lblBGL360FundName.Caption := MyClient.clExtra.ceBGLFundNameSelected ;
          lblBGL360FundName.Font.Color := clWindowText;
        end
        else begin
          lblBGL360FundName.Caption := 'No Fund selected';
          lblBGL360FundName.Font.Color := clRed;
        end;
      end;
    finally
      FreeAndNil(BGLServer);
    end;
  end
  else if IsMYOBLedger(MyClient.clFields.clCountry, SelectedSystem) then
  begin
    OldCursor := Screen.Cursor;
    try
      Screen.Cursor := crHourGlass;
      if not (CheckFormyMYOBTokens) then
        btnConnectMYOB.Caption := 'MYOB Login'
      else
        btnConnectMYOB.Caption := 'MYOB Client';

      lblFirmName.Caption := 'No Firm selected';
      lblFirmName.Font.Color := clRed;
      if (Assigned(AdminSystem) and (Trim(AdminSystem.fdFields.fdmyMYOBFirmName)<>'')) then
      begin
        lblFirmName.Caption := 'MYOB Firm: ' + AdminSystem.fdFields.fdmyMYOBFirmName;
        lblFirmName.Font.Color := clWindowText;
      end;

      lblPLClientName.Caption := 'No Client selected';
      lblPLClientName.Font.Color := clRed;

      if Trim(MyClient.clExtra.cemyMYOBClientNameSelected) <> '' then
      begin
        lblPLClientName.Caption := 'MYOB Client: '+ MyClient.clExtra.cemyMYOBClientNameSelected;
        lblPLClientName.Font.Color := clWindowText;
      end;
    finally
      Screen.Cursor := OldCursor;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TdlgAcctSystem.Execute(var AutoRefreshDone : Boolean; InWizard: Boolean = False) : boolean;
var
  i : integer;
  S, sName : String;
  LCLRec: pClient_File_Rec;
  NotesId : TBloGuid;
  BlopiClientDetails: TBloClientReadDetail;
  OffLineSubscription : TBloArrayOfguid;
  SubIndex : integer;
  NewID : string;
  RefreshYourChart: Boolean;
begin
  LCLRec := nil;

  SetupInitialSystem(InWizard);
  with MyClient.clFields do
  begin
    Self.ClientHeight := gbxWebExport.Top + 96;
    FOldAccountingSystem := clAccounting_System_Used;
    //*****************
    Self.ShowModal;
    //*****************
    if okPressed then
    begin

      with cmbSystem do begin
        clAccounting_System_Used := Integer( Items.Objects[ ItemIndex ] );
      end;

        if CanRefreshChart( clCountry, clAccounting_System_Used ) then
        begin
          // Set Dialog Question
          if ( FOldLoadFrom = '' ) then begin
            S := 'Do you want to Load the Chart now?';
          end
          else begin
            S := 'You have changed the Folder where the Chart is Loaded From.'#13+
                 'Do you want to Refresh the Chart now?';
          end;

          if (((clCountry = whAustralia) and (clAccounting_System_Used = saBGL360)) or
              (IsMYOBLedger(clCountry, clAccounting_System_Used))) then
          begin
            clLoad_Client_Files_From := '';
            FOldLoadFrom := '';
            if (clCountry = whAustralia) and (clAccounting_System_Used = saBGL360) then
            begin
              NewID := MyClient.clExtra.ceBGLFundIDSelected;
              sName := 'Fund';
            end
            else if IsMYOBLedger(clCountry, clAccounting_System_Used) then
            begin
              NewID := MyClient.clExtra.cemyMYOBClientIDSelected;
              sName := 'Client';
            end;

            if ( FOldID = '' ) then
              S := 'Do you want to Load the Chart now?'
            else
              S := 'You have changed the ' + sName + ' where the Chart is Loaded From.'#13+
                   'Do you want to Refresh the Chart now?';

            RefreshYourChart := ( Trim(NewID) <> '' ) and
                                ( Trim(NewId) <> Trim(FOldID) );

            if RefreshYourChart then
            begin
              if (IsMYOBLedger(clCountry, clAccounting_System_Used)) then
              begin
                RefreshYourChart := CheckFormyMYOBTokens;

                if not RefreshYourChart then
                begin
                  HelpfulErrorMsg('Refresh Chart can not be done.',
                      0, false, 'Refresh Chart can not be done due to invalid access tokens. Need a sign in to MYOB again to fix the problem', true);

                  if DebugMe then
                    LogUtil.LogMsg(lmDebug, UnitName, 'Refresh Chart failed due to invalid access tokens. Need a sign in to MYOB again.');
                  Exit;
                end;

                if PracticeLedger.LoadingCOAForTheFirstTime then
                begin
                  {No confirmation asked. Force refresh COA}
                  S := 'This will automatically update your chart of accounts and GST setup. ' +
                  'You will need to check some of your settings after this change. Do you want to continue?';
                  if (AskYesNo('Change accounting system', S, DLG_YES, 0 ) = DLG_YES ) then
                  begin
                    Import32.RefreshChart; // Practice Ledger
                    PracticeLedger.LoadingCOAForTheFirstTime := False;
                    AutoRefreshFlag := True;
                  end
                  else
                  begin
                    clAccounting_System_Used := FOldAccountingSystem;
                    MyClient.clExtra.cemyMYOBClientIDSelected := FOldID;
                    MyClient.clExtra.cemyMYOBClientNameSelected := FOldName;

                    Execute(AutoRefreshDone, InWizard);
                  end;
                end
                else if (AskYesNo( 'Refresh Chart', S, DLG_YES, 0 ) = DLG_YES ) then // normal flow
                begin
                  Import32.RefreshChart;
                  AutoRefreshFlag := True;
                end;
              end
              else if (AskYesNo( 'Refresh Chart', S, DLG_YES, 0 ) = DLG_YES ) then
              begin
                RefreshChart; // BGL 360
                AutoRefreshFlag := True;
              end;
            end;

            clLoad_Client_Files_From := Trim( eFrom.text);
          end
          else
          begin
            clLoad_Client_Files_From := Trim( eFrom.text);
            if ( clLoad_Client_Files_From <> '' ) and
                ( clLoad_Client_Files_From <> FOldLoadFrom ) and
                 ( AskYesNo( 'Refresh Chart', S, DLG_YES, 0 ) = DLG_YES ) then
            begin
              Import32.RefreshChart;
              AutoRefreshFlag := True;
            end;
          end;
        end
        else begin
           clLoad_Client_Files_From := '';
        end;
        clChart_Is_Locked           := chkLockChart.Checked;
        clAccount_Code_Mask         := eMask.text;
        // Only the directory for BGL 360, could add other systems to this as well

        clSave_Client_Files_To      := Trim( eTo.text);
        clAlternate_Extract_ID      := Trim(edtExtractID.Text);
        clUse_Alterate_ID_for_extract := chkUseCustomLedgerCode.Checked;
        clTax_Ledger_Code           := eTaxLedger.Text;
        clTax_Interface_Used := ComboUtils.GetComboCurrentIntObject( cmbTaxInterface);
        if clWeb_Export_Format <> ComboUtils.GetComboCurrentIntObject(cmbWebFormats) then
        begin
          FOldWebExportFormat := clWeb_Export_Format;
          clWeb_Export_Format := ComboUtils.GetComboCurrentIntObject(cmbWebFormats);

          //Only update the web export format on blopi, if blopi is available and the client is not read-only.
          if UseBankLinkOnline and not MyClient.clFields.clFile_Read_Only then
          begin
            if MyClient.Opened then
            begin
              if (not FInWizard) and (clWeb_Export_Format = wfWebNotes) and (FOldWebExportFormat <> wfWebNotes) then
              begin
                HelpfulInfoMsg('You have selected to use ' + bkBranding.NotesProductName + ' Online for this client. Please confirm the ' + bkBranding.ProductOnlineName + ' details for this client', 0);

                EditBanklinkOnlineSettings(Self, True, True, True);
              end;

              BlopiClientDetails := ProductConfigService.GetClientDetailsWithCode(MyClient.clFields.clCode);

              if Assigned(BlopiClientDetails) then
              begin
                try
                  if not ProductConfigService.UpdateClientNotesOption(BlopiClientDetails, clWeb_Export_Format) then
                  begin
                    clWeb_Export_Format := FOldWebExportFormat;
                  end;
                finally
                  FreeAndNil(BlopiClientDetails);
                end;
              end
              else
              begin
                // If notes is unticked and there are offline values
                if MyClient.clExtra.ceOnlineValuesStored then
                begin
                  SetLength(OffLineSubscription, MyClient.clExtra.ceOnlineSubscriptionCount);
                  for SubIndex := 1 to MyClient.clExtra.ceOnlineSubscriptionCount do
                    OffLineSubscription[SubIndex-1] := MyClient.clExtra.ceOnlineSubscription[SubIndex];

                  NotesId := ProductConfigService.GetNotesId;
                  if clWeb_Export_Format = wfWebNotes then
                  begin
                    ProductConfigService.AddItemToArrayGuid(OffLineSubscription, NotesId)
                  end
                  else
                  begin
                    ProductConfigService.RemoveItemFromArrayGuid(OffLineSubscription, NotesId);
                  end;

                  MyClient.clExtra.ceOnlineSubscriptionCount := length(OffLineSubscription);
                  for SubIndex := 1 to MyClient.clExtra.ceOnlineSubscriptionCount do
                    MyClient.clExtra.ceOnlineSubscription[SubIndex] := OffLineSubscription[SubIndex-1];
                end;
              end;
            end;
          end;
        end;

        S := Trim( edtSaveTaxTo.Text);
        if ( clTax_Interface_Used = tsNone) or ( S = '') then
          clSave_Tax_Files_To      := ''
        else
          clSave_Tax_Files_To      := IncludeTrailingPathDelimiter( S);

        if GBExtract.Visible then begin
           LoadAdminSystem(True,'BulkExtract');
           try
              LCLRec := AdminSystem.fdSystem_Client_File_List.FindCode(MyClient.clFields.clCode);
              if Assigned(lCLRec) then begin
                 if CkExtract.Checked then
                    LCLRec.cfBulk_Extract_Code :=  GetComboBoxExtractorCode(CBExtract)
                 else
                    LCLRec.cfBulk_Extract_Code := '';
              end else begin
                 // New Client use ?
                 // use clTemp_FRS_Job_To_Use as a temp. holder
                 if CkExtract.Checked then
                    clTemp_FRS_Job_To_Use := GetComboBoxExtractorCode(CBExtract)
                 else
                    clTemp_FRS_Job_To_Use := '';
              end;
           finally
              if Assigned(LCLRec) then
                 SaveAdminSystem
              else
                 UnlockAdmin;
           end;
         end;


        UpdateMenus;
     end;
   end;
   result := okPressed;
   FOldAccountingSystem := 0;;
end;

//------------------------------------------------------------------------------
function EditAccountingSystem(w_PopupParent: TForm; var AutoRefreshDone: Boolean; ContextID : Integer; InWizard: Boolean = False) : boolean;
var
   Mydlg : TdlgAcctSystem;
begin
   MyDlg := TdlgAcctSystem.Create(Application.MainForm);
   try
     MyDlg.PopupParent := w_PopupParent;
     MyDlg.PopupMode := pmExplicit;

      BKHelpSetUp(MyDlg, ContextID);
      result := MyDlg.Execute(AutoRefreshDone, InWizard);
      AutoRefreshDone := MyDlg.AutoRefreshFlag;
   finally
      Mydlg.Free;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.cmbTaxInterfaceChange(Sender: TObject);
//set the default directory if the directory is currently blank
var
  CurrType : integer;
begin
  CurrType := ComboUtils.GetComboCurrentIntObject( cmbTaxInterface);

  case CurrType of
    tsBAS_XML, tsBAS_MYOB, tsBAS_HANDI,
    tsElite_XML, tsBAS_APS_XML :
      edtSaveTaxTo.Text := 'XML\';
    tsBAS_Sol6ELS :
      edtSaveTaxTo.Text := 'ELS\';
  else
    edtSaveTaxTo.Text := '';
  end;
  eTaxLedger.Visible := CurrType = tsBAS_Sol6ELS;
  lblTaxLedger.Visible := CurrType = tsBAS_Sol6ELS;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.cmbWebFormatsChange(Sender: TObject);
begin
  WebFormatChanged := True;
  if (ComboUtils.GetComboCurrentIntObject(cmbWebFormats) = wfWebNotes) then
  begin
    ShowBankLinkOnlineConfirmation;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.DoReBranding;
begin
  btnCheckBankManId.Caption := 'Set &' + BRAND_SHORT_NAME + ' ID';
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.ShowBankLinkOnlineConfirmation;
var
  aMsg : String;
begin
  if not MyClient.Opened then
  begin
    aMsg := 'You have selected to use ' + bkBranding.NotesProductName + ' Online for this client. ' +
            'Please confirm the ' + bkBranding.ProductOnlineName + ' details for this client. ' +
            #13#10 + #13#10 +
            'The ' + bkBranding.ProductOnlineName + ' settings for this client will be displayed ' +
            'at the end of this wizard.';

    HelpfulInfoMsg(aMsg, 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.FillSystemList;
var
  i: Integer;
begin
  cmbSystem.items.Clear;

  with MyClient.clFields do
  begin
    case clCountry of
      whNewZealand : begin
         for i := snMin to snMax do begin
          if (not Software.ExcludeFromAccSysList( clCountry, i)) or ( i = claccounting_system_used) then
             cmbSystem.items.AddObject(snNames[i], TObject( i ) );
        end;
      end;

      whAustralia : begin
        if GBType.Visible then begin
          for i := saMin to saMax do begin
             if ((not Software.ExcludeFromAccSysList(clCountry, i)) or ( i = claccounting_system_used))
             and (Software.IsSuperFund(whAustralia,I) = RBSuper.Checked )then
               cmbSystem.items.AddObject(saNames[i], TObject( i ) );
          end;
        end else begin
          for i := saMin to saMax do begin
             if (not Software.ExcludeFromAccSysList(clCountry, i)) or ( i = claccounting_system_used) then
               cmbSystem.items.AddObject(saNames[i], TObject( i ) );
          end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if OkPressed then
  begin
    CanClose := VerifyForm;

    // Check WebNotes
    if (CanClose) and
       (ComboUtils.GetComboCurrentIntObject(cmbWebFormats) = wfWebNotes) and
       (not MyClient.Opened) then
    begin
      if not WebFormatChanged then
        ShowBankLinkOnlineConfirmation;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TdlgAcctSystem.VerifyForm: boolean;
const
  ThisMethodName = 'VerifyForm';
var
  Path : string;
  aMSg : string;
  CurrType : integer;
begin
  result := False;

  //alternate id
  if ( chkUseCustomLedgerCode.Checked) and ( Trim(edtExtractID.text) = '') then
  begin
    HelpfulWarningMsg( 'You must specify a Ledger Code to use', 0);
    exit;
  end;

  //tax invoice dir
  CurrType := ComboUtils.GetComboCurrentIntObject( cmbTaxInterface);
  if ( CurrType <> -1) and ( not( CurrType = tsNone)) then
  begin
    Path := Trim( edtSaveTaxTo.Text);
    if ( Path <> '') then
    begin
      Path := IncludeTrailingPathDelimiter(Path);

      //make sure the current directory is the bK5 one
      SetCurrentDir( DATADIR);
      if not DirectoryExists( Path) then
      begin
        if YesNoDlg.AskYesNo( 'Export Tax File To',
           'The "Export Tax File To" directory you have specified does not exist. Do you want to create it?',
           DLG_YES, 0) = DLG_YES then
        begin
          if not CreateDir(Path) then
          begin
            aMsg := 'Unable To Create Directory ' + Path;
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' - ' + aMsg );
            HelpfulWarningMsg(aMsg, 0);
            edtSaveTaxTo.SetFocus;
            Exit;
          end;
        end else
        begin
          edtSaveTaxTo.SetFocus;
          Exit;
        end;
      end;
    end;
  end;

  //No superfund selected
  if rbSuper.Checked and (cmbSystem.ItemIndex = -1) then begin
    if cmbSystem.CanFocus then
      cmbSystem.SetFocus;
    aMsg := 'Please select a superfund system';
    HelpfulWarningMsg(aMsg, 0);
    Exit;
  end;

  // Check WebNotes
  if (ComboUtils.GetComboCurrentIntObject(cmbWebFormats) = wfWebNotes) then
  begin
    if (MyClient.clFields.clClient_EMail_Address = '')
    or (MyClient.clFields.clContact_Name = '') then
    begin
      if FInWizard then
      begin
        aMsg := Format( 'The Web Export Format for this client is set to %s. ' +
                          #13#10#13#10 + 'If you want to keep this setting, please go back to Client Details and enter a Contact Name and an Email address, or change the Web Export Format before clicking OK',
                          [bkBranding.NotesOnlineProductName]);
      end
      else
      begin
        aMsg := Format( 'Web export to %s requires both an Email address and a contact name' +
                        #13#10 + 'Please update the Client Details before selecting this option',
                        [bkBranding.NotesOnlineProductName]);
      end;
      
      HelpfulWarningMsg(aMsg, 0);
      Exit;
    end;
  end;

  Result := True;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btnTaxFolderClick(Sender: TObject);
var
  test : string;
begin
  test := edtSaveTaxTo.Text;

  if BrowseFolder( test, 'Select the Default Folder for exporting Tax File to' ) then
    edtSaveTaxTo.Text := test;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btnCheckBankManIDClick(Sender: TObject);
//check that the bank man id in the save to field is set
var
  Ledger : string;
begin
  Ledger := Trim( ExtractFileName( ExcludeTrailingBackslash(eFrom.Text)));
  myobao_utils.CheckBankManID( Ledger, MyClient.clFields.clCode);
end;

procedure TdlgAcctSystem.btnConnectBGLClick(Sender: TObject);
var
  BGLServer: TBGLServer;
  FundFrm : TFundSelectionFrm;
begin
  BGLServer:= TBGLServer.Create(Nil,
                      DecryptAToken(Globals.PRACINI_BGL360_Client_ID,Globals.PRACINI_Random_Key),
                      DecryptAToken(Globals.PRACINI_BGL360_Client_Secret,Globals.PRACINI_Random_Key),
                      Globals.PRACINI_BGL360_API_URL);
  FundFrm := TFundSelectionFrm.Create(Nil);
  try
    if Assigned(AdminSystem) then
    begin
      // Get all BGL values from client file and
      BGLServer.Set_Auth_Tokens(AdminSystem.fdFields.fdBGLAccessToken,
                AdminSystem.fdFields.fdBGLTokenType,
                AdminSystem.fdFields.fdBGLRefreshToken,
                AdminSystem.fdFields.fdBGLTokenExpiresAt);
     //DN Not required      if (BGLServerNoSignRequired or BGLServer.CheckForAuthentication) then
      if (BGLServer.CheckForAuthentication) then
      begin
        BGLServer.Get_FundList;
        if BGLServer.FundList.Count > 0  then
        begin
          FundFrm.FundListJSON := BGLServer.FundList;
          FundFrm.SelectedFundID := MyClient.clExtra.ceBGLFundIDSelected;
          if ((FundFrm.ShowModal = mrOk) and (Trim(FundFrm.SelectedFundID) <> '')) then
          begin
            btnConnectBGL.Caption := 'Fund';
            btnConnectBGL.Hint    := 'Select a Fund to refresh the client''s Chart of Accounts from';
            if MyClient.clExtra.ceBGLFundIDSelected <> FundFrm.SelectedFundID then
            begin
              MyClient.clExtra.ceBGLFundIDSelected := FundFrm.SelectedFundID;
              MyClient.clExtra.ceBGLFundNameSelected := FundFrm.SelectedFundName;
              lblBGL360FundName.Caption := '';
              if Trim(MyClient.clExtra.ceBGLFundNameSelected) <> '' then begin
                lblBGL360FundName.Caption := MyClient.clExtra.ceBGLFundNameSelected;
                lblBGL360FundName.Font.Color := clWindowText;
              end;
//DN #89797-BGL360: Crash selecting a Fund in the Setup New Client Wizard             SaveClient(false);
            end;
          end;
        end
        else
          HelpfulErrorMsg( 'Unable to retrieve the fund list from BGL. ' +
            'Please try again later.', 0 );
      end
      else
        HelpfulErrorMsg( 'BGL Authentication failed. Please try again.', 0 );
    end;
  finally
    FreeAndNil(BGLServer);
    FreeAndNil(FundFrm);
  end;
end;

procedure TdlgAcctSystem.btnConnectMYOBClick(Sender: TObject);
var
  SignInFrm : TmyMYOBSignInForm;
  OldCursor: TCursor;
  SaveBusiness : Boolean;
  SelectBusinessFrm : TSelectBusinessForm;
  liErrorCode : integer;
  lsErrorDescription : string;
begin
  if not Assigned(AdminSystem) then
    Exit;

  if Trim(AdminSystem.fdFields.fdmyMYOBFirmID) = '' then
  begin
    if (not CurrUser.IsAdminUser) then // not admin user
    begin
      HelpfulErrorMsg(errNoMYOBFirmSelection, 0);
      Exit;
    end;
  end;

  SaveBusiness := False;
  SignInFrm := TmyMYOBSignInForm.Create(Nil);
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    if ( ((not CheckFormyMYOBTokens) or
      ((Trim(AdminSystem.fdFields.fdmyMYOBFirmID) = '') and
      (CurrUser.CanAccessAdmin and
      (not CurrUser.HasRestrictedAccess)))) ) or ( DebugGenericCommsErrors ) then
    begin
      SignInFrm.FormShowType := fsSignIn;
      SignInFrm.ShowFirmSelection := False;
      SignInFrm.ValidateClientAgainstFirm := True;

      if ((Trim(AdminSystem.fdFields.fdmyMYOBFirmID) = '') and
      (CurrUser.CanAccessAdmin and
      (not CurrUser.HasRestrictedAccess))) then
      begin
        SignInFrm.ShowFirmSelection := True;
      end;

      if (SignInFrm.ShowModal = mrOK) then
      begin
        if ((Trim(AdminSystem.fdFields.fdmyMYOBFirmID) = '') and
          (CurrUser.CanAccessAdmin and
          (not CurrUser.HasRestrictedAccess))) then
        begin
          // Save Firm for admin user
          Screen.Cursor := crHourGlass;
          try
            if LoadAdminSystem(true, 'TdlgAdminOptions.SaveSettingsToAdmin' ) then
            with AdminSystem.fdFields do
            begin
               fdmyMYOBFirmID := SignInFrm.SelectedID;
               fdmyMYOBFirmName := SignInFrm.SelectedName;

               //*** Flag Audit ***
               SystemAuditMgr.FlagAudit(arSystemOptions);

               SaveAdminSystem;
            end;
            UpdateMF.UpdateSystemMenus;
          finally
            Screen.Cursor := OldCursor;
          end;
        end;
      end;
    end
    else if not PracticeLedger.MYOBUserHasAccesToFirm
      (AdminSystem.fdFields.fdmyMYOBFirmID, True)then
    begin
      Screen.Cursor := OldCursor;
      HelpfulWarningMsg( errMYOBCredential, 0 );
      PracticeLedger.ResetMyMYOBUserDetails;
      Exit;
    end;

    if ((CheckFormyMYOBTokens) and (Trim(AdminSystem.fdFields.fdmyMYOBFirmID) <> '')) then
    begin
      SelectBusinessFrm := TSelectBusinessForm.Create(Self);
      try
        // Get Businesses
        Screen.Cursor := crHourGlass;
        try
          if ((PracticeLedger.Businesses.Count = 0) and
             (not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID ,
                    ltPracticeLedger,PracticeLedger.Businesses, liErrorCode,
                    lsErrorDescription))) then
          begin
            Screen.Cursor := OldCursor;
            HelpfulErrorMsg( PracticeLedger.ReturnGenericErrorMessage( liErrorCode ), 0 );
            Exit;
          end;
        finally
          Screen.Cursor := OldCursor;
        end;
        if (PracticeLedger.Businesses.Count = 0) then
        begin
          HelpfulWarningMsg('There are no Ledgers available. Please create a MYOB Ledger to continue.', 0);
          Exit;
        end
        else if SelectBusinessFrm.ShowModal = mrOk then
        begin
          {If no business is setup already , load GST template.}
          if ((Trim(MyClient.clExtra.cemyMYOBClientIDSelected) = '') and
              (Trim(MyClient.clExtra.cemyMYOBClientNameSelected)= ''))
              {or
              (MyClient.clExtra.cemyMYOBClientIDSelected <> SelectBusinessFrm.SelectedBusinessID)} then
            PracticeLedger.LoadingCOAForTheFirstTime := True; // this setting will load default MYOB Ledger GST template
          MyClient.clExtra.cemyMYOBClientIDSelected := SelectBusinessFrm.SelectedBusinessID;
          MyClient.clExtra.cemyMYOBClientNameSelected := SelectBusinessFrm.SelectedBusinessName;

          SaveBusiness := True;
        end;
      finally
        FreeAndNil(SelectBusinessFrm);
      end;
    end;

    if SaveBusiness then
    begin
      if Trim(MyClient.clExtra.cemyMYOBClientNameSelected) <> '' then
      begin
        lblPLClientName.Caption := MyClient.clExtra.cemyMYOBClientNameSelected;
      end;
      //SaveClient(false); Disabled due to Crash selecting a client in the Setup New Client Wizard
    end;

    lblFirmName.Caption := 'No Firm selected';
    if (Assigned(AdminSystem) and (Trim(AdminSystem.fdFields.fdmyMYOBFirmName)<>'')) then
      lblFirmName.Caption := 'MYOB Firm: ' + AdminSystem.fdFields.fdmyMYOBFirmName;

    lblPLClientName.Caption := 'No Client selected';
    if Trim(MyClient.clExtra.cemyMYOBClientNameSelected) <> '' then
    begin
      lblPLClientName.Caption := 'MYOB Client: '+ MyClient.clExtra.cemyMYOBClientNameSelected;
      lblPLClientName.Font.Color := clWindowText;
    end;

    if not (CheckFormyMYOBTokens) then
      btnConnectMYOB.Caption := 'MYOB Login'
    else
      btnConnectMYOB.Caption := 'MYOB Client';
  finally
    FreeAndNil(SignInFrm);
    Screen.Cursor := OldCursor;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btndefaultClick(Sender: TObject);
  //-------------------------
  procedure LoadSuper;
  begin
    cmbSystem.ItemIndex := cmbSystem.Items.IndexOfObject(TObject(AdminSystem.fdFields.fdSuperfund_System));
    eMask.Text := AdminSystem.fdFields.fdSuperfund_Code_Mask;
    eFrom.Text := AdminSystem.fdFields.fdLoad_Client_Super_Files_From;
    eTo.Text   := AdminSystem.fdFields.fdSave_Client_Super_Files_To;
  end;
  //-------------------------
  procedure LoadAccounting;
  begin
    cmbSystem.ItemIndex := cmbSystem.Items.IndexOfObject(TObject(AdminSystem.fdFields.fdAccounting_System_Used));
    eMask.Text := AdminSystem.fdFields.fdAccount_Code_Mask;
    eFrom.Text := AdminSystem.fdFields.fdLoad_Client_Files_From;
    eTo.Text   := AdminSystem.fdFields.fdSave_Client_Files_To;
  end;

  procedure LoadWebFormat;
  begin
    cmbWebFormats.ItemIndex := cmbWebFormats.Items.IndexOfObject(TObject(AdminSystem.fdFields.fdWeb_Export_Format));
  end;

begin
  if not Assigned(AdminSystem) then
    Exit;
  if InSetup then
    Exit;

  if gbType.Visible then begin
    // Have a Dual system
    if rbSuper.Checked then
      LoadSuper
    else
      LoadAccounting
  end else begin
    if AdminSystem.fdFields.fdAccounting_System_Used = asNone then
      loadsuper
    else
      LoadAccounting
  end;
  LoadWebFormat;

  if CanBulkExtract then
  begin
    if AdminSystem.fdFields.fdBulk_Export_Code > '' then
      ckExtract.Checked := BulkExtractFrm.SelectExtractor(AdminSystem.fdFields.fdBulk_Export_Code,cbExtract)
    else
      ckExtract.Checked := False;
  end;

  cmbSystemChange(nil);
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.eFromChange(Sender: TObject);
begin
  btnCheckBankManID.Enabled := (Trim(eFrom.Text) <> '');
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.chkUseCustomLedgerCodeClick(Sender: TObject);
begin
  edtExtractID.Enabled := chkUseCustomLedgerCode.Checked;
  btnMasLedgerCode.Enabled := edtExtractID.Enabled;

  if not chkUseCustomLedgerCode.Checked then
  begin
    FAlternateID := edtExtractID.Text;
    edtExtractid.Text := MyClient.clFields.clCode
  end
  else
    edtExtractID.Text := FAlternateID;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.ckExtractClick(Sender: TObject);
begin
  if ckExtract.Checked then
  begin
    if cbExtract.ItemIndex < 0 then
    begin
      if AdminSystem.fdFields.fdBulk_Export_Code > '' then
        BulkExtractFrm.SelectExtractor(AdminSystem.fdFields.fdBulk_Export_Code,cbExtract)
      else
        cbExtract.ItemIndex := 0;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btnMasLedgerCodeClick(Sender: TObject);
var
  LedgerCode : string;
  LedgerPath : string;
  AcctSystem : integer;
  result : integer;
begin
  //is the accounting system APS
  with cmbSystem do
  begin
    AcctSystem := Integer( Items.Objects[ ItemIndex ] );
  end;
  if Software.IsSol6_COM_Interface( MyClient.clFields.clCountry, AcctSystem) then
  begin
    //can use bclink.dll to get a list of account ledgers
    LedgerCode := edtExtractID.text;
    LedgerPath := '';
    result := SelectMAS_GL_Code( LedgerCode, LedgerPath, INI_SOL6_SYSTEM_PATH);
    case result of
      bkS6_COM_Refresh_Supported_User_Selected_Ledger :
      begin
        edtExtractID.Text := LedgerCode;
        if eFrom.Text = '' then
          eFrom.Text := LedgerPath;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAcctSystem.btnSetBankpathClick(Sender: TObject);
begin
  MYOBAO_Utils.SetBankPath;
end;

initialization
begin
  DebugMe := DebugUnit(UnitName);
  DebugGenericCommsErrors := DebugUnit('DebugGenericCommsErrors');
end;

end.
