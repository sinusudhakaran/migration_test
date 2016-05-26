unit CashBookMigrationWiz;

//------------------------------------------------------------------------------
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
  ComCtrls,
  clObj32,
  TSMask,
  Grids_ts,
  TSGrid,
  BKDEFS,
  MoneyDef,
  baObj32,
  BKConst,
  Buttons,
  bkXPThemes,
  chList32,
  Math,
  OSFont,
  ExchangeGainLoss,
  GainLossFrm,
  OleCtrls,
  SHDocVw,
  BKWebBrowser,
  RzPrgres,
  CashbookMigration,
  CashbookMigrationRestData,
  VirtualTrees,
  Grids;

type
  //----------------------------------------------------------------------------
  TBrowserState = (bstNone,
                   bstNavigating,
                   bstDoneNavigating,
                   bstLoading,
                   bstDoneLoading,
                   bstError);

  //----------------------------------------------------------------------------
  TFrmCashBookMigrationWiz = class(TForm)
    pnlButtons: TPanel;
    btnBack: TButton;
    btnNext: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    pnlWizard: TPanel;
    pnlTabTitle: TPanel;
    lblTitle: TLabel;
    lblDescription: TLabel;
    Bevel2: TBevel;
    PageControl1: TPageControl;
    tabOverview: TTabSheet;
    BKOverviewWebBrowser: TBKWebBrowser;
    tabMYOBCredentials: TTabSheet;
    pnlLogin: TPanel;
    lblEmail: TLabel;
    edtEmail: TEdit;
    edtPassword: TEdit;
    lblPassword: TLabel;
    btnSignIn: TButton;
    pnlFirm: TPanel;
    Label6: TLabel;
    cmbSelectFirm: TComboBox;
    tabSelectData: TTabSheet;
    pnlSelectData: TPanel;
    chkChartofAccount: TCheckBox;
    chkBalances: TCheckBox;
    chkTransactions: TCheckBox;
    tabProgress: TTabSheet;
    pnlProgress: TPanel;
    tabComplete: TTabSheet;
    pnlTabButtonHider: TPanel;
    lblProgressTitle: TLabel;
    lblClientFiles: TLabel;
    prgClientFiles: TRzProgressBar;
    tabCheckList: TTabSheet;
    BKChecklistWebBrowser: TBKWebBrowser;
    lblSingleFirm: TLabel;
    lblBankfeeds3: TLabel;
    lblMems1: TLabel;
    pnlCashbookComplete: TPanel;
    pnlCashbookErrors: TPanel;
    lblClientCompleteAmount: TLabel;
    lblCashbookMigrated: TLabel;
    lblCashbookLoginLink: TLabel;
    lblClientError: TLabel;
    lblClientErrorSupport: TLabel;
    lblForgotPassword: TLabel;
    lblBankfeeds1: TLabel;
    radMove: TRadioButton;
    radCopy: TRadioButton;
    lblBankfeeds2: TLabel;
    lblBankfeeds4: TLabel;
    stgSelectedClients: TStringGrid;
    CheckBox1: TCheckBox;
    stgClientsMigrated: TStringGrid;
    lblYuoCanCheckYourStatus: TLabel;
    lblMoreInfoOnErros: TLabel;
    stgClientErrors: TStringGrid;
    procedure btnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnSignInClick(Sender: TObject);
    procedure cmbSelectFirmChange(Sender: TObject);
    procedure chkChartofAccountClick(Sender: TObject);
    procedure chkAcceptAgreementClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtEmailChange(Sender: TObject);
    procedure lblForgotPasswordClick(Sender: TObject);
    procedure lblCashbookLoginLinkClick(Sender: TObject);
    procedure radCopyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

  private
    fCurrentStepID: integer;
    fSignedIn : Boolean;
    fFirmSelected : Boolean;
    fEmail : string;
    fPassword : string;

    fSelectClients : TStringList;
    fClientErrors  : TStringList;
    fSelectedData  : TSelectedData;
    fFirms : TFirms;
    fSignInTime : TDateTime;
    fNumErrorClients : integer;

    fMigrationStatus : TMigrationStatus;

    fBrowser1Loaded : Boolean;
    fBrowser2Loaded : Boolean;

  protected
    procedure UpdateClientStringGrid(aClients : TStringGrid; aClientNameWidth, aSelectClientsCount, aVisibleRowCount : integer);
    procedure UpdateClientErrorsStringGrid(aClientErrors : TStringGrid; aClientErrorWidth, aClientErrorsCount, aVisibleRowCount : integer);
    procedure DoMigrationProgress(aCurrentFile : integer;
                                  aTotalFiles : integer;
                                  aPercentOfCurrentFile : integer);

    procedure SignIn();
    procedure SignOut();

    // Wizard steps
    function  GetOrderArrayPos(ForStepID : integer) : integer;
    function  FindPage(StepID : integer) : TTabSheet;
    procedure MoveToStep(StepID : integer);
    function  NextStep(StepID : integer) : integer;
    function  PrevStep(StepID : integer) : integer;
    function  HasPreviousStep(StepID : integer) : boolean;
    function  HasNextStep(StepID : integer) : boolean;
    procedure DoBeforeMoveToStep(OldStepID : integer; var NewStepID : integer; var Cancel : boolean);
    procedure DoAfterMoveToStep;
    function  StepAvailable(StepID : integer) : boolean;
    procedure InitialiseStep(StepID : integer);
    function  CompleteStep(StepID : integer) : boolean;
    function  CanMoveToNextStep(StepID : integer) : boolean;
    procedure FinishWizard;

    procedure MoveToNextStep();

    function  IsLastStep : boolean;
    procedure DoMigrateCashbook();

    procedure UpdateControls;
    procedure UpdateDataSelection();
    function UpdateFirmControls() : boolean;
    procedure UpdateSignInControls(aBusySigningIn : Boolean);
    procedure UpdateProgressControls();
    procedure UpdateCompleteControls();

    procedure TryNavToOverview();
    procedure TryNavToCheckList();
  public
    constructor Create(AOwner: tComponent); override;
    destructor Destroy; override;

    property SelectClients : TStringList read fSelectClients write fSelectClients;
  end;

  //----------------------------------------------------------------------------
  function RunCashBookMigrationWizard(w_PopupParent: Forms.TForm; aSelectClients : TStringList) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  AccountInfoObj,
  AccountLookupFrm,
  bktxio,
  bkdsio,
  BKHelp,
  bkMaskUtils,
  bkDateUtils,
  CalculateAccountTotals,
  ErrorMoreFrm,
  GenUtils,
  Globals,
  GSTCalc32,
  ImagesFrm,
  jnlUtils32,
  TrialBalanceOptionsDlg,
  TrxList32,
  OpeningBalancesDlg,
  ProfitAndLossOptionsDlg,
  Reports,
  ReportDefs,
  SignUtils,
  WinUtils,
  YesNoDlg,
  CountryUtils,
  ForexHelpers,
  InfoMoreFrm,
  LogUtil,
  ShellAPI,
  bkContactInformation,
  Files,
  DateUtils,
  SYDefs,
  CashbookWarningFrm,
  WarningMoreFrm;

const
  UnitName = 'CashBookMigrationWiz';

  BROWSER_TIME_OUT = 5000;
  CASHBOOK_DASHBOARD_NAME = 'Cashbook Dashboard';

  mtOverview           = 1; mtMin = 1;
  mtCheckList          = 2;
  mtMYOBCredentials    = 3;
  mtSelectData         = 4;
  mtProgress           = 5;
  mtCompleteMigration  = 6; mtMax = 6;

  StepTitles: array[mtMin..mtMax] of string = (
    'Step 1 of 4 : Before you start',
    'Step 2 of 4 : Migration details',
    'Step 3 of 4 : MYOB Credentials',
    'Step 4 of 4 : Data Selection',
    'Migration Progress',
    'Complete'
  );

  StepDescriptions: array[mtMin..mtMax] of string = (
    'You have chosen to migrate the following client files from MYOB BankLink Practice to ' + BRAND_CASHBOOK_NAME + '.',
    '',
    'Login to your MYOB account',
    'What would you like to migrate to ' + BRAND_CASHBOOK_NAME + '?',
    '',
    ''
  );

  TabOrderArray: array [mtMin..mtMax] of byte = (
    mtOverview,
    mtCheckList,
    mtMYOBCredentials,
    mtSelectData,
    mtProgress,
    mtCompleteMigration
  );

var
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
function RunCashBookMigrationWizard(w_PopupParent: Forms.TForm;  aSelectClients : TStringList): boolean;
const
  ThisMethodName = 'RunCashBookMigrationWizard';
var
  Wizard : TFrmCashBookMigrationWiz;
  sError : string;
begin
  if Assigned(MYClient) then
  begin
    sError := 'You have client file ' + MYClient.clFields.clCode + ' open. Please close before proceeding with the Cashbook migration.' ;
    HelpfulWarningMsg(sError, 0);
    LogUtil.LogMsg(lmDebug, UnitName, sError);
    Exit;
  end;
  
  MigrateCashbook.MarkSelectedClients(ord(fsOpen), aSelectClients);
  try
    Wizard := TFrmCashBookMigrationWiz.Create(Application.MainForm); // FormCreate
    try
      Wizard.PopupParent   := w_PopupParent;
      Wizard.PopupMode     := pmExplicit;
      Wizard.SelectClients := aSelectClients;
      BKHelpSetUp(Wizard, BKH_Migrating_a_client_from_COMPANY_NAME1_PRODUCT_PRACTICE_to_COMPANY_NAME1_Essentials_Cashbook);

      result := (Wizard.ShowModal = mrOK);

    finally
      FreeAndNil(Wizard);
    end;
  finally
    MigrateCashbook.MarkSelectedClients(ord(fsNormal), aSelectClients);
  end;
end;

//------------------------------------------------------------------------------
constructor TFrmCashBookMigrationWiz.Create(AOwner: tComponent);
begin
  inherited Create(AOwner);

  fClientErrors := TStringList.Create;
  fNumErrorClients := 0;

  fFirms := TFirms.create();
  fBrowser1Loaded := false;
  fBrowser2Loaded := false;
  fSelectedData.DoMoveRatherThanCopy := true;
end;

//------------------------------------------------------------------------------
destructor TFrmCashBookMigrationWiz.Destroy;
begin
  BKOverviewWebBrowser.Stop;
  BKChecklistWebBrowser.Stop;

  FreeAndNil(fFirms);

  fClientErrors.Clear;
  FreeAndNil(fClientErrors);

  inherited; // LAST
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.FormCreate(Sender: TObject);
var
  i: integer;
begin
  // Setup
  lblTitle.Font.Name := Font.Name;
  bkXPThemes.ThemeForm(Self);

  // Start with the welcome screen (which is a panel over the Pages)
  fCurrentStepID := mtOverview;

  // WORKAROUND: for partially visible tabs (from Year/End balance wizard)
  pnlTabButtonHider.Left := 0;
  pnlTabButtonHider.BevelOuter := bvNone;

  // Setup Page Tags
  tabOverview.Tag := mtOverview;
  tabCheckList.Tag := mtCheckList;
  tabMYOBCredentials.Tag := mtMYOBCredentials;
  tabSelectData.Tag := mtSelectData;
  tabProgress.Tag := mtProgress;
  tabComplete.Tag := mtCompleteMigration;
  for i := 0 to Pred(PageControl1.PageCount) do
    Assert(PageControl1.Pages[i].Tag <> 0, 'FormCreate: PageControl.Tag value not assigned');

  PageControl1.ActivePageIndex := 0;

  fSignedIn := false;
  fFirmSelected := false;
  edtEmail.Text := '';

  DoAfterMoveToStep;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.FormShow(Sender: TObject);
begin
  InitialiseStep(mtOverview);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.btnSignInClick(Sender: TObject);
begin
  if not fSignedIn then
    SignIn()
  else
    SignOut();
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.chkChartofAccountClick(Sender: TObject);
begin
  chkBalances.enabled := (chkChartofAccount.Checked);
  chkTransactions.enabled := (chkChartofAccount.Checked);
  if not chkChartofAccount.Checked then
  begin
    chkBalances.checked := false;
    chkTransactions.checked := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.cmbSelectFirmChange(Sender: TObject);
begin
  fFirmSelected := (cmbSelectFirm.ItemIndex > -1);

  if fFirmSelected then
    fSelectedData.FirmId := fFirms[cmbSelectFirm.ItemIndex].ID;

  UpdateControls();
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.btnNextClick(Sender: TObject);
begin
  MoveToNextStep;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.btnBackClick(Sender: TObject);
begin
  if HasPreviousStep(fCurrentStepID) then
    MoveToStep(PrevStep(fCurrentStepID));
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.GetOrderArrayPos(ForStepID : integer) : integer;
var
  sNo : integer;
begin
  result := -1;
  for sNo := mtMin to mtMax do
    if TabOrderArray[sNo] = ForStepID then
      result := sNo;

  Assert(result > -1, 'GetOrderArrayPos.Step not found in list');
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.MoveToNextStep;
begin
  if CanMoveToNextStep(fCurrentStepID) then
  begin
    CompleteStep(fCurrentStepID);
    if HasNextStep(fCurrentStepID) then
      MoveToStep(NextStep(fCurrentStepID))
    else
      FinishWizard;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.MoveToStep(StepID: integer);
//called from the Back and Next Buttons
var
  Cancel : boolean;
  NewStepID : integer;
begin
  Assert(StepID in [mtMin..mtMax], 'Step No out of range');
  NewStepID := StepID;

  //save settings on current page before moving
  Cancel := false;
  DoBeforeMoveToStep(fCurrentStepID, NewStepID, Cancel);
  if Cancel then
    Exit;

  PageControl1.ActivePage := FindPage(NewStepID);

  DoAfterMoveToStep;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.NextStep(StepID: integer): integer;
var
  CurrPosInArray : integer;
  Found          : boolean;
begin
  Assert(StepID in [mtMin..mtMax], 'NextStep.Old Step out of range');

  CurrPosInArray := GetOrderArrayPos(StepID);

  //cycle thru list trying to find next valid step
  Found := false;
  while (CurrPosInArray in [mtMin..mtMax]) and (not Found) do
  begin
    Inc(CurrPosInArray);
    if CurrPosInArray in [mtMin..mtMax] then
      Found := StepAvailable(TabOrderArray[CurrPosInArray]);
  end;

  //return step if found, otherwise don't move
  if Found then
    result := TabOrderArray[CurrPosInArray]
  else
    result := StepID;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.PrevStep(StepID: integer): integer;
var
  sNo : integer;
  CurrPosInArray : integer;
  Found : boolean;
begin
  Assert(StepID in [mtMin..mtMax], 'PrevStep.Old Step out of range');

  CurrPosInArray := -1;
  for sNo := mtMin to mtMax do
    if TabOrderArray[sNo] = StepID then
      CurrPosInArray := sNo;

  Assert(CurrPosInArray > -1, 'Current Step not found in list');

  //cycle thru list trying to find next valid step
  Found := false;
  while (CurrPosInArray in [mtMin..mtMax]) and (not Found) do
  begin
    Dec(CurrPosInArray);
    if CurrPosInArray in [mtMin..mtMax] then
      Found := StepAvailable(TabOrderArray[CurrPosInArray]);
  end;

  //return step if found, otherwise don't move
  if Found then
    result := TabOrderArray[CurrPosInArray]
  else
    result := StepID;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.radCopyClick(Sender: TObject);
begin
  fSelectedData.DoMoveRatherThanCopy := radMove.Checked;
end;

//------------------------------------------------------------------------------
//gives us an opportunity to save information on the current tab
procedure TFrmCashBookMigrationWiz.DoBeforeMoveToStep(OldStepID : integer; var NewStepID : integer; var Cancel : boolean);

  //----------------------------------------------------------------------------
  function BooltoYesNo(aValue : boolean) : string;
  begin
    if aValue then
      Result := 'Yes'
    else
      Result := 'No'
  end;

var
  MovingForward : boolean;
  liErrorCode : integer;
  lsErrorDescription : string;
  InvalidPass : boolean;

begin
  Assert(OldStepID in [mtMin..mtMax], 'DoBeforeMoveToStep.OldStepID out of range');
  Assert(NewStepID in [mtMin..mtMax], 'DoBeforeMoveToStep.NewStepID out of range');

  MovingForward := GetOrderArrayPos(NewStepID) > GetOrderArrayPos(OldStepId);

  if MovingForward then
  begin
    case OldStepID of
      mtSelectData : begin
        // Actual login
        if MinutesBetween(fSignInTime, now()) > 1 then
        begin
          if not MigrateCashbook.Login(fEmail, fPassword, liErrorCode, lsErrorDescription, InvalidPass) then
          begin
            HelpfulErrorMsg( MigrateCashbook.ReturnGenericErrorMessage( liErrorCode ), 0 );
            Cancel := true;
            exit;
          end;
        end;

        fSelectedData.Bankfeeds := true;
        fSelectedData.ChartOfAccount := chkChartofAccount.checked;
        fSelectedData.ChartOfAccountBalances := chkBalances.checked;
        fSelectedData.NonTransferedTransactions := chkTransactions.checked;
        fSelectedData.DoMoveRatherThanCopy := radmove.Checked;

        if DebugMe then
        begin
          LogUtil.LogMsg(lmDebug, UnitName, 'Bank Feeds : ' + BooltoYesNo(fSelectedData.Bankfeeds));
          LogUtil.LogMsg(lmDebug, UnitName, 'Chart Of Account : ' + BooltoYesNo(fSelectedData.ChartOfAccount));
          LogUtil.LogMsg(lmDebug, UnitName, 'Chart Of Account Balances : ' + BooltoYesNo(fSelectedData.ChartOfAccountBalances));
          LogUtil.LogMsg(lmDebug, UnitName, 'Non Transferred Transactions : ' + BooltoYesNo(fSelectedData.NonTransferedTransactions));
        end;
      end;
      mtMYOBCredentials :
      begin
        if DebugMe then
          LogUtil.LogMsg(lmDebug, UnitName, 'Selected FirmId : ' + fSelectedData.FirmId);
      end;
    end;
  end;

  //save existing
  CompleteStep(OldStepId);

  //now prepare for moving to new step,
  //allows us to initialise
  if MovingForward then
    InitialiseStep(NewStepId);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.DoMigrationProgress(aCurrentFile, aTotalFiles, aPercentOfCurrentFile : integer);
var
  FileBusywith : integer;
begin
  FileBusywith := aCurrentFile + 1;
  if FileBusywith > aTotalFiles then
    FileBusywith := aTotalFiles;

  prgClientFiles.TotalParts := aTotalFiles * 100;
  prgClientFiles.PartsComplete := (aCurrentFile * 100) + aPercentOfCurrentFile;
  lblClientFiles.Caption := inttostr(FileBusywith) + ' of ' + inttostr(aTotalFiles);
  Application.ProcessMessages;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.edtEmailChange(Sender: TObject);
begin
  btnSignIn.Enabled := ((length(edtEmail.Text) > 0) and (length(edtPassword.Text) > 0));
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.DoAfterMoveToStep;
var
  OldStep : integer;
begin
  Assert(fCurrentStepID in [mtMin..mtMax], 'DoAfterMoveToStep.CurrentStepID out of range');

  OldStep := fCurrentStepID;
  fCurrentStepID := PageControl1.ActivePage.Tag;

  //update titles
  lblTitle.Caption := StepTitles[fCurrentStepID];
  lblDescription.Caption := StepDescriptions[fCurrentStepID];

  case fCurrentStepID of
    mtOverview : begin
      UpdateControls();

      if OldStep = mtCheckList then
        TryNavToOverview();
    end;
    mtCheckList : begin
      UpdateControls();

      TryNavToCheckList();
    end;

    mtMYOBCredentials : begin
      {$IFDEF DEBUG}
        edtEmail.Text := 'cashbook@gmail.com';
        edtPassword.Text := 'password1';
      {$ENDIF}

      UpdateSignInControls(false);
      UpdateControls();
    end;

    mtSelectData : begin
      if fSelectedData.DoMoveRatherThanCopy then
        radMove.SetFocus
      else
        radCopy.SetFocus;

      UpdateControls();
    end;

    mtProgress: begin

      EnableMenuItem( GetSystemMenu( handle, False ),SC_CLOSE, MF_BYCOMMAND or MF_GRAYED );
      Try
        UpdateProgressControls();
        DoMigrateCashbook();
      Finally
        EnableMenuItem( GetSystemMenu( handle, False ), SC_CLOSE, MF_BYCOMMAND or MF_ENABLED );
      End;

      MoveToNextStep();
    end;

    mtCompleteMigration : begin
      UpdateCompleteControls();
    end;
  end;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.HasNextStep(StepID: integer): boolean;
begin
  result := NextStep(StepID) <> StepID;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.HasPreviousStep(StepID: integer): boolean;
begin
  result := (PrevStep(StepID) <> StepID) and
            not (IsLastStep);
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.FindPage(StepID: integer): TTabSheet;
var
  i : integer;
begin
  result := PageControl1.ActivePage;

  for i := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[i].Tag = StepID then
      result := PageControl1.Pages[i];
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if fCurrentStepID = mtProgress then
    Action := caNone;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  iResult: integer;
begin
  if fCurrentStepID = mtProgress then
  begin
    CanClose := false;
    Exit;
  end;

  // Next/Finish button?
  if (ModalResult = mrOK) then
    exit;

  if IsLastStep then
    Exit;

  // Not sure?
  iResult := AskYesNo(
    'Exit ' + Self.Caption,
    'Are you sure that you want to exit the ' + BRAND_CASHBOOK_NAME + ' Migration wizard? '+ #13#13 +
    'Any information you have entered will be lost.',
    Dlg_No, 0);
  if (iResult = DLG_No) then
    CanClose := false;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.SignIn;
var
  liErrorCode : integer;
  lsErrorDescription: string;
  OldCursor: TCursor;
  InvalidPass : boolean;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  UpdateSignInControls(true);
  try
    // Actual login
    if not MigrateCashbook.Login(edtEmail.Text, edtPassword.Text, liErrorCode,
             lsErrorDescription, InvalidPass) then
    begin
      Screen.Cursor := OldCursor;

      if InvalidPass then
        HelpfulWarningMsg(lsErrorDescription, 0)
      else
        HelpfulErrorMsg( MigrateCashbook.ReturnGenericErrorMessage( liErrorCode ), 0 );

      UpdateSignInControls(false);
      edtEmail.SetFocus;
      exit;
    end;

    // Get firms
    if not MigrateCashbook.GetFirms(fFirms, liErrorCode, lsErrorDescription) then
    begin
      Screen.Cursor := OldCursor;
      HelpfulErrorMsg( MigrateCashbook.ReturnGenericErrorMessage( liErrorCode ), 0 );
      UpdateSignInControls(false);
      edtEmail.SetFocus;
      exit;
    end;
  finally
    Screen.Cursor := OldCursor;
  end;

  if not UpdateFirmControls() then
    Exit;

  fSignedIn := true;
  fSignInTime := now();
  fEmail := edtEmail.text;
  fPassword := edtPassword.text;

  UpdateSignInControls(false);
  UpdateControls();
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.SignOut;
begin
  fSignedIn := false;
  UpdateSignInControls(false);
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.StepAvailable(StepID : integer) : boolean;
//used by next and prev to determine if this step can be used
begin
  result := True;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.TryNavToOverview;
begin
  if fBrowser1Loaded then
    Exit;

  fBrowser1Loaded := true;

  if fileExists(Globals.HtmlCache + CashBookStartCacheFileName) then
    BKOverviewWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookStartCacheFileName)
  else
    LogUtil.LogMsg( lmError, UnitName, 'Error loading file : ' +
                    Globals.HtmlCache + CashBookStartCacheFileName + ', file not found.');
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.TryNavToCheckList;
begin
  if fBrowser2Loaded then
    Exit;

  fBrowser2Loaded := true;

  if fileExists(Globals.HtmlCache + CashBookDetailCacheFileName) then
    BKChecklistWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookDetailCacheFileName)
  else
    LogUtil.LogMsg( lmError, UnitName, 'Error loading file : ' +
                    Globals.HtmlCache + CashBookDetailCacheFileName + ', file not found.');
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.InitialiseStep(StepID: integer);
begin
  inherited;

  case StepID of
    mtOverview:
    begin
      UpdateControls;
      btnNext.SetFocus;

      UpdateClientStringGrid(stgSelectedClients, 592, SelectClients.Count, 4);

      TryNavToOverview();
    end;
    mtSelectData :
    begin
      UpdateDataSelection();
    end;
  end;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.IsLastStep: boolean;
begin
  Result := (fCurrentStepID =  TabOrderArray[High(TabOrderArray)]);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.lblCashbookLoginLinkClick(Sender: TObject);
var
  link : string;
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  try
    if AdminSystem.fdFields.fdCountry = whAustralia then
      link := PRACINI_DefaultCashbookLoginAUURL
    else
      link := PRACINI_DefaultCashbookLoginNZURL;

    if length(link) = 0 then
      exit;

    ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
  finally
    Screen.Cursor := OldCursor;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.lblForgotPasswordClick(Sender: TObject);
var
  link : string;
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  try
    link := PRACINI_DefaultCashbookForgotPasswordURL;

    if length(link) = 0 then
      exit;

    ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
  finally
    Screen.Cursor := OldCursor;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.DoMigrateCashbook;
var
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  MigrateCashbook.OnProgressEvent := DoMigrationProgress;
  try
    fClientErrors.Clear;
    fMigrationStatus := MigrateCashbook.MigrateClients(fSelectClients, fSelectedData, fClientErrors, fNumErrorClients);
  finally
    MigrateCashbook.OnProgressEvent := nil;
    Screen.Cursor := OldCursor;
  end;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.CompleteStep(StepID: integer): boolean;
begin
  result := true;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.CanMoveToNextStep(StepID: integer): boolean;
begin
  // Normally okay
  result := true;

  case fCurrentStepID of
    mtMYOBCredentials : Result := (fSignedIn and fFirmSelected);
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.chkAcceptAgreementClick(Sender: TObject);
begin
  UpdateControls();
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.FinishWizard;
begin
  //PostGainlossEntries;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.UpdateControls;
begin
  btnNext.Enabled := CanMoveToNextStep(fCurrentStepID) and HasNextStep(fCurrentStepID);
  btnBack.Enabled := HasPreviousStep(fCurrentStepID);

  if (fCurrentStepID = mtMYOBCredentials) and
     (not btnNext.Enabled) then
  begin
    btnNext.Default := false;
    btnSignIn.Default := true;
  end
  else
  begin
    btnNext.Default := true;
    btnSignIn.Default := false;
  end;

  BKOverviewWebBrowser.Height := 227;
  BKOverviewWebBrowser.Width  := 723;
  BKChecklistWebBrowser.Height := 347;
  BKChecklistWebBrowser.Width  := 723;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.UpdateDataSelection;
begin
  lblBankfeeds1.Caption := 'Bank Feeds';
  radMove.Caption       := 'Move Bank feeds to ' + BRAND_CASHBOOK_NAME;
  lblBankfeeds2.Caption := 'They will be deleted from ' + BRAND_FULL_PRACTICE + '.';
  radCopy.Caption       := 'Copy Bank feeds to ' + BRAND_CASHBOOK_NAME;
  lblBankfeeds3.Caption := 'Bank feeds will continue to work in ' + BRAND_FULL_PRACTICE +
                           ', and you will be charged for both bank feeds.' ;
  lblBankfeeds4.Caption     := 'You can request to have your bank feed deleted from ' +
                               BRAND_FULL_PRACTICE + ' at any time.';

  chkChartofAccount.Caption := 'Chart of Accounts';
  chkBalances.Caption       := 'Chart of Account balances';
  chkTransactions.Caption   := 'Non-transferred transaction data';

  lblMems1.Caption          := 'Memorisations - you can add these manually as ''Rules'' in ' +
                               BRAND_CASHBOOK_NAME + '.';;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.UpdateFirmControls: boolean;
var
  FirmIndex : integer;
  MaxTextWidth : integer;
  AddToSides : integer;
begin
  Result := false;
  // No firms?
  if (fFirms.Count = 0) then
  begin
    fSignedIn := false;
    UpdateSignInControls(false);
    HelpfulWarningMsg('You do not have permission to setup ' + BRAND_CASHBOOK_NAME + ' clients. ' +
                      'Please contact your Partner Manager.' ,0);
    edtEmail.SetFocus;
    exit;
  end
  else
  if (fFirms.Count = 1) then
  begin
    lblSingleFirm.Visible := true;
    cmbSelectFirm.Visible := false;

    fFirmSelected := true;
    lblSingleFirm.Caption := StringReplace(fFirms[0].Name, '&', '&&', [rfReplaceAll]);;
    fSelectedData.FirmId := fFirms[0].ID;
  end
  else
  begin
    lblSingleFirm.Visible := false;
    cmbSelectFirm.Visible := true;
    fFirmSelected := false;
    cmbSelectFirm.clear;

    MaxTextWidth := 0;
    for FirmIndex := 0 to fFirms.Count-1 do
    begin
      cmbSelectFirm.Items.Add(fFirms[FirmIndex].Name);

      if cmbSelectFirm.Canvas.TextWidth(fFirms[FirmIndex].Name) > MaxTextWidth then
        MaxTextWidth := cmbSelectFirm.Canvas.TextWidth(fFirms[FirmIndex].Name);
    end;

    MaxTextWidth := trunc(MaxTextWidth * 1.275);

    cmbSelectFirm.Left := 230;
    cmbSelectFirm.Width := 254;
    if MaxTextWidth > cmbSelectFirm.Width then
    begin
      if MaxTextWidth > 700 then
        MaxTextWidth := 700;

      AddToSides := trunc((MaxTextWidth - cmbSelectFirm.Width)/2);

      cmbSelectFirm.Left := cmbSelectFirm.Left - AddToSides;
      cmbSelectFirm.Width := cmbSelectFirm.Width + (AddToSides*2);
    end;
  end;
  Result := true;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.UpdateSignInControls(aBusySigningIn : Boolean);
begin
  lblForgotPassword.visible := not (fSignedIn or aBusySigningIn);
  edtEmail.Enabled          := not (fSignedIn or aBusySigningIn);
  edtPassword.Enabled       := not (fSignedIn or aBusySigningIn);
  lblEmail.Enabled          := not (fSignedIn or aBusySigningIn);
  lblPassword.Enabled       := not (fSignedIn or aBusySigningIn);

  if edtEmail.Enabled then
    edtEmail.setfocus();

  btnSignIn.enabled := (not aBusySigningIn) and
                       (length(edtEmail.Text) > 0) and
                       (length(edtPassword.Text) > 0);

  pnlFirm.Visible := fSignedIn;

  if (fSignedIn) and (not aBusySigningIn) then
  begin
    btnSignIn.Caption := 'Logout';
    btnNext.Default := true;
    btnSignIn.Default := false;

    if cmbSelectFirm.Visible then
      cmbSelectFirm.SetFocus();
  end
  else
  begin
    btnSignIn.Caption := 'Login';
    btnNext.Default := false;
    btnSignIn.Default := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.UpdateProgressControls;
begin
  btnBack.visible := false;
  btnNext.visible := false;
  btnCancel.visible := false;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.UpdateClientStringGrid(aClients : TStringGrid; aClientNameWidth, aSelectClientsCount, aVisibleRowCount : integer);
var
  Client: pClient_File_Rec;
  SelIndex : integer;
begin
  aClients.ColCount := 2;
  aClients.ColWidths[0] := 110;

  aClients.RowCount := aSelectClientsCount+1;
  aClients.Cells[0, 0] := 'Code';
  aClients.Cells[1, 0] := 'Name';
  for SelIndex := 1 to aSelectClientsCount do
  begin
    Client := AdminSystem.fdSystem_Client_File_List.FindCode(SelectClients.Strings[SelIndex-1]);
    aClients.Cells[0, SelIndex] := Client^.cfFile_Code;
    aClients.Cells[1, SelIndex] := Client^.cfFile_Name;
  end;

  if aSelectClientsCount > aVisibleRowCount then
    aClients.ColWidths[1] := aClientNameWidth
  else
    aClients.ColWidths[1] := aClientNameWidth + 17;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.UpdateClientErrorsStringGrid(aClientErrors : TStringGrid; aClientErrorWidth, aClientErrorsCount, aVisibleRowCount : integer);
var
  SelIndex : integer;
begin
  aClientErrors.ColCount := 1;

  aClientErrors.RowCount := aClientErrorsCount+1;
  aClientErrors.Cells[0, 0] := 'Error';

  for SelIndex := 1 to aClientErrorsCount do
    aClientErrors.Cells[0, SelIndex] := fClientErrors.Strings[SelIndex-1];

  if aClientErrorsCount > aVisibleRowCount then
    aClientErrors.ColWidths[0] := aClientErrorWidth
  else
    aClientErrors.ColWidths[0] := aClientErrorWidth + 17;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.UpdateCompleteControls();
var
  TotalClients : integer;
  SupportNumber : string;
  WindowTitle : string;
begin
  TotalClients := fSelectClients.Count;

  btnNext.Default := false;
  btnCancel.Default := true;
  btnCancel.Caption := 'Done';
  btnCancel.ModalResult := mrYes;
  btnCancel.Enabled := true;
  btnCancel.Visible := true;

  lblCashbookLoginLink.Caption :=
    Format('You can log into %s here', [CASHBOOK_DASHBOARD_NAME]);

  if fNumErrorClients > 0 then
  begin
    if fMigrationStatus = mgsPartial then
      UpdateClientErrorsStringGrid(stgClientErrors, 660, fClientErrors.Count, 5)
    else
      UpdateClientErrorsStringGrid(stgClientErrors, 660, fClientErrors.Count, 13);

    SupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ];
    lblClientError.Caption := Format('The following %d client(s) could not be migrated.', [fNumErrorClients]);
    lblClientErrorSupport.Caption := Format('Please contact ' + SHORTAPPNAME + ' support if the problems persist : %s', [SupportNumber]);
  end;

  lblYuoCanCheckYourStatus.Caption := BRAND_CASHBOOK_NAME + '.';

  WindowTitle := 'Congratulations and welcome to ' + BRAND_CASHBOOK_NAME;

  case fMigrationStatus of
    mgsSuccess : begin
      lblClientCompleteAmount.Caption := 'The following clients are now being created in ' + BRAND_CASHBOOK_NAME + '.';

      stgClientsMigrated.Visible := true;
      UpdateClientStringGrid(stgClientsMigrated, 550, SelectClients.Count, 9);

      lblDescription.Caption := WindowTitle;
      pnlCashbookComplete.Visible := true;
      pnlCashbookErrors.Visible   := false;
      pnlCashbookComplete.Align   := alClient;

      lblClientCompleteAmount.Top := 16;
      stgClientsMigrated.Top := 36;
      stgClientsMigrated.Height := 205;
      lblCashbookLoginLink.Top := 275;
      lblCashbookMigrated.Top := 300;
      lblYuoCanCheckYourStatus.Top := 325;
    end;
    mgsPartial : begin
      lblClientCompleteAmount.Caption :=
        Format('%d client(s) are now being created in ' + BRAND_CASHBOOK_NAME + '.', [TotalClients-fNumErrorClients]);

      stgClientsMigrated.Visible := false;
      lblDescription.Caption := WindowTitle;
      pnlCashbookComplete.Visible := true;
      pnlCashbookErrors.Visible   := true;
      pnlCashbookComplete.Align   := alTop;
      pnlCashbookErrors.Align     := alClient;

      lblClientCompleteAmount.Top := 16;
      lblCashbookLoginLink.Top := 65;
      lblCashbookMigrated.Top := 90;
      lblYuoCanCheckYourStatus.Top := 115;
    end;
    mgsFailure : begin
      lblDescription.Caption := 'We could not migrate your client(s)';
      pnlCashbookComplete.Visible := false;
      pnlCashbookErrors.Visible   := true;
      pnlCashbookErrors.Align     := alClient;
    end;
  end;

  if (fSelectedData.DoMoveRatherThanCopy) and
     (MigrateCashbook.HasProvisionalAccountsAndMoved) and
     (fMigrationStatus in [mgsSuccess, mgsPartial]) then
  begin
    ShowCashbookWarning(self, MigrateCashbook.ProvisionalAccounts);
  end;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.

