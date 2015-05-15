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
                   bstLoading,
                   bstDone);

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
    tmrBrowserLoading: TTimer;
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
    procedure tmrBrowserLoadingTimer(Sender: TObject);
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
    fBrowserState : TBrowserState;
    fBrowserStartTick : int64;

  protected
    procedure DoNavigationError(ASender: TObject;
                                const pDisp: IDispatch;
                                var URL: OleVariant;
                                var Frame: OleVariant;
                                var StatusCode: OleVariant;
                                var Cancel: WordBool);
    procedure DoWebBrowserDocumentComplete(ASender: TObject;
                                           const pDisp: IDispatch;
                                           var URL: OleVariant);

    procedure UpdateClientStringGrid(aClients : TStringGrid; aClientNameWidth, aSelectClientsCount, aVisibleRowCount : integer);
    procedure UpdateClientErrorsStringGrid(aClientErrors : TStringGrid; aClientErrorWidth, aClientErrorsCount, aVisibleRowCount : integer);
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
    procedure UpdateDataSelection();
    function UpdateFirmControls() : boolean;
    procedure UpdateSignInControls(aBusySigningIn : Boolean);
    procedure UpdateProgressControls();
    procedure UpdateCompleteControls();
    procedure TryNavToPageUpdateCache();
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
function RunCashBookMigrationWizard(w_PopupParent: Forms.TForm;  aSelectClients : TStringList): boolean;
const
  ThisMethodName = 'RunCashBookMigrationWizard';
var
  Wizard : TFrmCashBookMigrationWiz;
begin
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
  fBrowserState := bstNone;
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
  sError : string;
  InvalidPass : boolean;

begin
  Assert(OldStepID in [mtMin..mtMax], 'DoBeforeMoveToStep.OldStepID out of range');
  Assert(NewStepID in [mtMin..mtMax], 'DoBeforeMoveToStep.NewStepID out of range');

  MovingForward := GetOrderArrayPos(NewStepID) > GetOrderArrayPos(OldStepId);

  case OldStepID of
    mtOverview : begin
      fBrowserState := bstNone;
      BKOverviewWebBrowser.OnNavigateError := nil;
      BKOverviewWebBrowser.Stop;
    end;
    mtCheckList : begin
      fBrowserState := bstNone;
      BKChecklistWebBrowser.OnNavigateError := nil;
      BKChecklistWebBrowser.Stop;
    end;
  end;

  if MovingForward then
  begin
    case OldStepID of
      mtSelectData : begin
        // Actual login
        if MinutesBetween(fSignInTime, now()) > 1 then
        begin
          if not MigrateCashbook.Login(fEmail, fPassword, sError, InvalidPass) then
          begin
            ShowConnectionError(sError);
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
procedure TFrmCashBookMigrationWiz.DoNavigationError(ASender: TObject;
  const pDisp: IDispatch; var URL, Frame, StatusCode: OleVariant;
  var Cancel: WordBool);
begin
  if fBrowserState = bstNavigating then
  begin
    fBrowserState := bstLoading;
    fBrowserStartTick := GetTickCount();

    case fCurrentStepID of
      mtOverview : begin
        BKOverviewWebBrowser.Stop;
        BKOverviewWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookStartCacheFileName);
      end;
      mtCheckList : begin
        BKChecklistWebBrowser.Stop;
        BKChecklistWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookDetailCacheFileName);
      end;
    end;
  end
  else
  begin
    tmrBrowserLoading.Enabled := false;
    fBrowserState := bstNone;
    case fCurrentStepID of
      mtOverview : BKOverviewWebBrowser.Stop;
      mtCheckList : BKChecklistWebBrowser.Stop;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.DoWebBrowserDocumentComplete(ASender: TObject; const pDisp: IDispatch; var URL: OleVariant);
var
  ExpectedURL : string;
begin
  if fBrowserState = bstNavigating then
  begin
    case fCurrentStepID of
      mtOverview : begin
        case AdminSystem.fdFields.fdCountry of
          whNewZealand: ExpectedURL := Globals.PRACINI_NZCashMigrationURLOverview1;
          whAustralia : ExpectedURL := Globals.PRACINI_AUCashMigrationURLOverview1;
        end;
      end;
      mtCheckList : begin
        case AdminSystem.fdFields.fdCountry of
          whNewZealand: ExpectedURL := Globals.PRACINI_NZCashMigrationURLOverview2;
          whAustralia : ExpectedURL := Globals.PRACINI_AUCashMigrationURLOverview2;
        end;
      end;
    end;

    if ExpectedURL <> URL then
    begin
      fBrowserState := bstLoading;
      fBrowserStartTick := GetTickCount();

      case fCurrentStepID of
        mtOverview : begin
          BKOverviewWebBrowser.Stop;
          BKOverviewWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookStartCacheFileName);
        end;
        mtCheckList : begin
          BKChecklistWebBrowser.Stop;
          BKChecklistWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookDetailCacheFileName);
        end;
      end;
    end
    else
      fBrowserState := bstDone;
  end
  else
  begin
    tmrBrowserLoading.Enabled := false;
    fBrowserState := bstNone;
    case fCurrentStepID of
      mtOverview : BKOverviewWebBrowser.Stop;
      mtCheckList : BKChecklistWebBrowser.Stop;
    end;
  end;
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
      begin
        fBrowserState := bstNavigating;
        fBrowserStartTick := GetTickCount();
        tmrBrowserLoading.enabled := true;
        TryNavToPageUpdateCache();
      end;
    end;
    mtCheckList : begin
      UpdateControls();

      fBrowserState := bstNavigating;
      fBrowserStartTick := GetTickCount();
      tmrBrowserLoading.enabled := true;
      TryNavToPageUpdateCache();
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
procedure TFrmCashBookMigrationWiz.ShowConnectionError(aError: string);
var
  SupportNumber : string;
begin
  SupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ];
  HelpfulErrorMsg('Could not connect to migration service, please try again later. ' +
                  'If problem persists please contact ' + SHORTAPPNAME + ' support ' + SupportNumber + '.',
                  0, false, aError, true);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.SignIn;
var
  sError: string;
  OldCursor: TCursor;
  InvalidPass : boolean;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  UpdateSignInControls(true);
  try
    // Actual login
    if not MigrateCashbook.Login(edtEmail.Text, edtPassword.Text, sError, InvalidPass) then
    begin
      Screen.Cursor := OldCursor;

      if InvalidPass then
        HelpfulWarningMsg(sError, 0)
      else
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
procedure TFrmCashBookMigrationWiz.tmrBrowserLoadingTimer(Sender: TObject);
var
  BrowserReadyState : TOleEnum;
begin
  if fBrowserState in [bstNone, bstDone] then
  begin
    tmrBrowserLoading.Enabled := false;
    Exit;
  end;

  if (GetTickCount() < (fBrowserStartTick + BROWSER_TIME_OUT)) then
    Exit;

  case fCurrentStepID of
    mtOverview  : BrowserReadyState := BKOverviewWebBrowser.BrowserReadyState;
    mtCheckList : BrowserReadyState := BKChecklistWebBrowser.BrowserReadyState;
  else
    begin
      tmrBrowserLoading.Enabled := false;
      Exit;
    end;
  end;

  case BrowserReadyState of
    READYSTATE_UNINITIALIZED : begin
      tmrBrowserLoading.Enabled := false;
      fBrowserState := bstNone;
      Exit;
    end;
    READYSTATE_LOADING : begin
      if fBrowserState = bstNavigating then
      begin
        fBrowserState := bstLoading;
        fBrowserStartTick := GetTickCount();

        case fCurrentStepID of
          mtOverview : begin
            BKOverviewWebBrowser.Stop;
            BKOverviewWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookStartCacheFileName);
          end;
          mtCheckList : begin
            BKChecklistWebBrowser.Stop;
            BKChecklistWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookDetailCacheFileName);
          end;
        end;
      end
      else
      begin
        tmrBrowserLoading.Enabled := false;
        fBrowserState := bstNone;
        case fCurrentStepID of
          mtOverview : BKOverviewWebBrowser.Stop;
          mtCheckList : BKChecklistWebBrowser.Stop;
        end;
        Exit;
      end;
      
    end;
    READYSTATE_LOADED, READYSTATE_INTERACTIVE, READYSTATE_COMPLETE : begin
      tmrBrowserLoading.Enabled := false;
      fBrowserState := bstDone;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.TryNavToPageUpdateCache();
var
  URL : string;
begin
  case fCurrentStepID of
    mtOverview : begin
      BKOverviewWebBrowser.Stop;
      BKOverviewWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookStartCacheFileName);
    end;
    mtCheckList : begin
      BKChecklistWebBrowser.Stop;
      BKChecklistWebBrowser.LoadFromFile(Globals.HtmlCache + CashBookDetailCacheFileName);
    end;
  end;

  {case fCurrentStepID of
    mtOverview : begin
      case AdminSystem.fdFields.fdCountry of
        whNewZealand: URL := Globals.PRACINI_NZCashMigrationURLOverview1;
        whAustralia : URL := Globals.PRACINI_AUCashMigrationURLOverview1;
      end;
      BKOverviewWebBrowser.OnNavigateError := DoNavigationError;
      BKOverviewWebBrowser.OnDocumentComplete := DoWebBrowserDocumentComplete;
      BKOverviewWebBrowser.NavigateToURL(URL);
    end;
    mtCheckList : begin
      case AdminSystem.fdFields.fdCountry of
        whNewZealand: URL := Globals.PRACINI_NZCashMigrationURLOverview2;
        whAustralia : URL := Globals.PRACINI_AUCashMigrationURLOverview2;
      end;
      BKChecklistWebBrowser.OnNavigateError := DoNavigationError;
      BKChecklistWebBrowser.OnDocumentComplete := DoWebBrowserDocumentComplete;
      BKChecklistWebBrowser.NavigateToURL(URL);
    end;
  end; }
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

      fBrowserState := bstNavigating;
      fBrowserStartTick := GetTickCount();
      tmrBrowserLoading.enabled := true;
      TryNavToPageUpdateCache();
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
    btnSignIn.Caption := 'Sign Out';
    btnNext.Default := true;
    btnSignIn.Default := false;

    if cmbSelectFirm.Visible then
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

