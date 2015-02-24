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
  CashbookMigrationRestData;

type
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
    btnForgotPassword: TButton;
    btnSignUp: TButton;
    btnSignIn: TButton;
    pnlFirm: TPanel;
    Label6: TLabel;
    cmbSelectFirm: TComboBox;
    tabSelectData: TTabSheet;
    pnlSelectData: TPanel;
    chkBankFeed: TCheckBox;
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
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    pnlCashbookComplete: TPanel;
    pnlCashbookErrors: TPanel;
    lblClientCompleteAmount: TLabel;
    lblCashbookMigrated: TLabel;
    lblCashbookLoginLink: TLabel;
    lblClientError: TLabel;
    lstClientErrors: TListBox;
    lblClientErrorSupport: TLabel;
    procedure btnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnSignInClick(Sender: TObject);
    procedure cmbSelectFirmChange(Sender: TObject);
    procedure chkChartofAccountClick(Sender: TObject);
    procedure chkAcceptAgreementClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnForgotPasswordClick(Sender: TObject);
    procedure btnSignUpClick(Sender: TObject);
    procedure edtEmailChange(Sender: TObject);

  private
    fCurrentStepID: integer;
    fSignedIn : Boolean;
    fFirmSelected : Boolean;

    fSelectClients : TStringList;
    fClientErrors  : TStringList;
    fSelectedData  : TSelectedData;
    fFirms : TFirms;

    fMigrationStatus : TMigrationStatus;

  protected
    procedure DoMigrationProgress(aCurrentFile : integer;
                                  aTotalFiles : integer;
                                  aPercentOfCurrentFile : integer);

    procedure SignIn();
    procedure SignOut();
    procedure ShowConnectionError(aError : string);

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
    function UpdateFirmControls() : boolean;
    procedure UpdateSignInControls(aBusySigningIn : Boolean);
    procedure UpdateProgressControls();
    procedure UpdateCompleteControls();

  public
    constructor Create(AOwner: tComponent); override;
    destructor Destroy; override;

    property SelectClients : TStringList read fSelectClients write fSelectClients;
  end;

  //----------------------------------------------------------------------------
  function RunCashBookMigrationWizard(aSelectClients : TStringList) : boolean;

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
  WarningMoreFrm;

const
  UnitName = 'CashBookMigrationWiz';

  CASHBOOK_DASHBOARD_NAME = 'Cashbook Dashboard';

  mtOverview           = 1; mtMin = 1;
  mtCheckList          = 2;
  mtMYOBCredentials    = 3;
  mtSelectData         = 4;
  mtProgress           = 5;
  mtCompleteMigration  = 6; mtMax = 6;

  StepTitles: array[mtMin..mtMax] of string = (
    'Overview',
    'Overview',
    'MYOB Credentials',
    'Data Selection',
    'Migration Progress',
    'Complete'
  );

  StepDescriptions: array[mtMin..mtMax] of string = (
    'Congratulations for opting to migrate your selected accounts from Practice to ' + BRAND_CASHBOOK_NAME + '. ' +
    'Please ensure your clients are ready to migrate by checking the following:',
    'Before we begin please note:',
    'Sign into your my.MYOB account',
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
function RunCashBookMigrationWizard(aSelectClients : TStringList): boolean;
var
  Wizard : TFrmCashBookMigrationWiz;
begin
  Wizard := TFrmCashBookMigrationWiz.Create(Application.MainForm); // FormCreate
  try
    Wizard.SelectClients := aSelectClients;
    result := (Wizard.ShowModal = mrOK);
  finally
    FreeAndNil(Wizard);
  end;
end;

//------------------------------------------------------------------------------
constructor TFrmCashBookMigrationWiz.Create(AOwner: tComponent);
begin
  inherited Create(AOwner);

  fClientErrors := TStringList.Create;
  fFirms := TFirms.create();
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
procedure TFrmCashBookMigrationWiz.btnSignUpClick(Sender: TObject);
var
  link : string;
begin
  link := PRACINI_DefaultCashbookSignupURL;

  if length(link) = 0 then
    exit;

  ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.btnForgotPasswordClick(Sender: TObject);
var
  link : string;
begin
  link := PRACINI_DefaultCashbookForgotPasswordURL;

  if length(link) = 0 then
    exit;

  ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
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

begin
  Assert(OldStepID in [mtMin..mtMax], 'DoBeforeMoveToStep.OldStepID out of range');
  Assert(NewStepID in [mtMin..mtMax], 'DoBeforeMoveToStep.NewStepID out of range');

  MovingForward := GetOrderArrayPos(NewStepID) > GetOrderArrayPos(OldStepId);

  if MovingForward then
  begin
    case OldStepID of
      mtSelectData : begin
        fSelectedData.Bankfeeds := true;
        fSelectedData.ChartOfAccount := chkChartofAccount.checked;
        fSelectedData.ChartOfAccountBalances := chkBalances.checked;
        fSelectedData.NonTransferedTransactions := chkTransactions.checked;

        if DebugMe then
        begin
          LogUtil.LogMsg(lmDebug, UnitName, 'Bank Feeds : ' + BooltoYesNo(fSelectedData.Bankfeeds));
          LogUtil.LogMsg(lmDebug, UnitName, 'Chart Of Account : ' + BooltoYesNo(fSelectedData.ChartOfAccount));
          LogUtil.LogMsg(lmDebug, UnitName, 'Chart Of Account Balances : ' + BooltoYesNo(fSelectedData.ChartOfAccountBalances));
          LogUtil.LogMsg(lmDebug, UnitName, 'Non Transfered Transactions : ' + BooltoYesNo(fSelectedData.NonTransferedTransactions));
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
  btnSignIn.Enabled := (length(edtEmail.Text) > 0);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.DoAfterMoveToStep;
begin
  Assert(fCurrentStepID in [mtMin..mtMax], 'DoAfterMoveToStep.CurrentStepID out of range');

  fCurrentStepID := PageControl1.ActivePage.Tag;

  //update titles
  lblTitle.Caption := StepTitles[fCurrentStepID];
  lblDescription.Caption := StepDescriptions[fCurrentStepID];

  case fCurrentStepID of
    mtMYOBCredentials : begin
      {$IFDEF DEBUG}
        edtEmail.Text := 'cashbook@gmail.com';
        edtPassword.Text := 'password1';
      {$ENDIF}

      UpdateSignInControls(false);
      UpdateControls();
    end;

    mtSelectData : begin
      chkChartofAccount.SetFocus;
      UpdateControls();
    end;

    mtProgress: begin
      UpdateProgressControls();
      DoMigrateCashbook();
      MoveToNextStep();
    end;

    mtCompleteMigration : begin
      UpdateCompleteControls();
    end;
  else
    UpdateControls();
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
procedure TFrmCashBookMigrationWiz.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  iResult: integer;
begin
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
procedure TFrmCashBookMigrationWiz.ShowConnectionError(aError: string);
var
  SupportNumber : string;
begin
  SupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ];
  HelpfulErrorMsg('Could not connect to migration service, please try again later. ' +
                  'If problem persists please contact ' + SHORTAPPNAME + ' support. ' + SupportNumber,
                  0, false, aError, true);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.SignIn;
var
  sError: string;
  OldCursor: TCursor;
  Firms: TFirms;
  SupportNumber : string;
begin
  // Basic check
  if (edtEmail.text = '') or (edtPassword.text = '')  then
  begin
    HelpfulWarningMsg('Your Username and/or Password is invalid. Please try again.',0);
    edtEmail.SetFocus;
    Exit;
  end;

  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  UpdateSignInControls(true);
  try
    // Actual login
    if not MigrateCashbook.Login(edtEmail.Text, edtPassword.Text, sError) then
    begin
      Screen.Cursor := OldCursor;
      ShowConnectionError(sError);
      UpdateSignInControls(false);
      edtEmail.SetFocus;
      exit;
    end;

    // Get firms
    if not MigrateCashbook.GetFirms(fFirms, sError) then
    begin
      Screen.Cursor := OldCursor;
      ShowConnectionError(sError);
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
procedure TFrmCashBookMigrationWiz.InitialiseStep(StepID: integer);
var
  dtMonthEnding: TDateTime;
  Overview1URL : string;
  Overview2URL : string;
begin
  // Phase 1 don't navigate to URL's

  case StepID of
    mtOverview:
    begin
      {case AdminSystem.fdFields.fdCountry of
        whNewZealand: Overview1URL := Globals.PRACINI_NZCashMigrationURLOverview1;
        whAustralia : Overview1URL := Globals.PRACINI_AUCashMigrationURLOverview1;
      end;

      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, 'OverView Tab 1, Navigate to : ' + Overview1URL);

      BKOverviewWebBrowser.Navigate(Overview1URL);}

      if not CloseClient() then
      begin

      end;
    end;
    {mtChecklist:
    begin
      case AdminSystem.fdFields.fdCountry of
        whNewZealand: Overview2URL := Globals.PRACINI_NZCashMigrationURLOverview2;
        whAustralia : Overview2URL := Globals.PRACINI_AUCashMigrationURLOverview2;
      end;

      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, 'OverView Tab 2, Navigate to : ' + Overview2URL);

      BKChecklistWebBrowser.Navigate(Overview2URL);
    end;}
  end;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.IsLastStep: boolean;
begin
  Result := (fCurrentStepID =  TabOrderArray[High(TabOrderArray)]);
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
    fMigrationStatus := MigrateCashbook.MigrateClients(fSelectClients, fSelectedData, fClientErrors);
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

  if (fCurrentStepID <> mtMYOBCredentials) then
  begin
    btnNext.Default := false;
    btnSignIn.Default := true;
  end;
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.UpdateFirmControls: boolean;
var
  FirmIndex : integer;
begin
  Result := false;
  // No firms?
  if (fFirms.Count = 0) then
  begin
    HelpfulWarningMsg('No firms available.',0);
    edtEmail.SetFocus;
    exit;
  end
  else
  if (fFirms.Count = 1) then
  begin
    lblSingleFirm.Visible := true;
    cmbSelectFirm.Visible := false;

    fFirmSelected := true;
    lblSingleFirm.Caption := fFirms[0].Name;
    fSelectedData.FirmId := fFirms[0].ID;
  end
  else
  begin
    lblSingleFirm.Visible := false;
    cmbSelectFirm.Visible := true;
    fFirmSelected := false;

    cmbSelectFirm.Clear();
    for FirmIndex := 0 to fFirms.Count-1 do
    begin
      cmbSelectFirm.Items.Add(fFirms[FirmIndex].Name);
    end;
  end;
  Result := true;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.UpdateSignInControls(aBusySigningIn : Boolean);
begin
  btnForgotPassword.enabled := not (fSignedIn or aBusySigningIn);
  btnSignUp.enabled         := not (fSignedIn or aBusySigningIn);
  edtEmail.Enabled          := not (fSignedIn or aBusySigningIn);
  edtPassword.Enabled       := not (fSignedIn or aBusySigningIn);
  lblEmail.Enabled          := not (fSignedIn or aBusySigningIn);
  lblPassword.Enabled       := not (fSignedIn or aBusySigningIn);

  if edtEmail.Enabled then
    edtEmail.setfocus();

  btnSignIn.enabled := not aBusySigningIn;
  pnlFirm.Visible := fSignedIn;

  if fSignedIn then
  begin
    btnSignIn.Caption := 'Sign Out';
    btnNext.Default := true;
    btnSignIn.Default := false;

    if cmbSelectFirm.Items.Count > 1 then
      cmbSelectFirm.SetFocus();
  end
  else
  begin
    btnSignIn.Caption := 'Sign In';
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
procedure TFrmCashBookMigrationWiz.UpdateCompleteControls();
var
  ErrorIndex : integer;
  TotalClients : integer;
  SupportNumber : string;
  WindowTitle : string;
begin
  TotalClients := fSelectClients.Count;

  btnCancel.Caption := 'Done';
  btnCancel.ModalResult := mrYes;
  btnCancel.Enabled := true;
  btnCancel.Visible := true;

  lstClientErrors.Clear;
  for ErrorIndex := 0 to fClientErrors.Count-1 do
  begin
    lstClientErrors.AddItem(fClientErrors.Strings[ErrorIndex], nil);
  end;

  lblClientCompleteAmount.Caption :=
    Format('%d client(s) and their data are now being created in ' + BRAND_CASHBOOK_NAME + '.', [TotalClients]);

  lblCashbookLoginLink.Caption :=
    Format('You can log into %s here', [CASHBOOK_DASHBOARD_NAME]);

  if lstClientErrors.Count > 0 then
  begin
    SupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ];
    lblClientError.Caption := Format('The following %d client(s) could not be migrated.', [lstClientErrors.Count]);
    lblClientErrorSupport.Caption := Format('Please contact ' + SHORTAPPNAME + ' support if the problems persist : %s', [SupportNumber]);
  end;

  WindowTitle := 'Congratulations and welcome to ' + BRAND_CASHBOOK_NAME;
  case fMigrationStatus of
    mgsSuccess : begin
      lblDescription.Caption := WindowTitle;
      pnlCashbookComplete.Visible := true;
      pnlCashbookErrors.Visible   := false;
      pnlCashbookComplete.Align   := alClient;

      lblClientCompleteAmount.Top := 20;
      lblCashbookLoginLink.Top := 20 + trunc(pnlCashbookComplete.Height/4);
      lblCashbookMigrated.Top := 20 + trunc((pnlCashbookComplete.Height/4)*2);
    end;
    mgsPartial : begin
      lblDescription.Caption := WindowTitle;
      pnlCashbookComplete.Visible := true;
      pnlCashbookErrors.Visible   := true;
      pnlCashbookComplete.Align   := alTop;
      pnlCashbookErrors.Align     := alClient;
    end;
    mgsFailure : begin
      lblDescription.Caption := 'We could not migrate your client(s)';
      pnlCashbookComplete.Visible := false;
      pnlCashbookErrors.Visible   := true;
      pnlCashbookErrors.Align     := alClient;
    end;
  end;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.

