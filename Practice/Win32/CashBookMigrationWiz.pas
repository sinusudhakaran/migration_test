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
  RzPrgres;

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
    Image1: TImage;
    Bevel2: TBevel;
    PageControl1: TPageControl;
    tabOverview: TTabSheet;
    BKOverviewWebBrowser: TBKWebBrowser;
    tabMYOBCredentials: TTabSheet;
    pnlLogin: TPanel;
    Label4: TLabel;
    edtUser: TEdit;
    edtPassword: TEdit;
    Label5: TLabel;
    btnResetPassword: TButton;
    btnSignup: TButton;
    btnLogin: TButton;
    pnlFirm: TPanel;
    Label6: TLabel;
    cmbSelectFirm: TComboBox;
    tabSelectData: TTabSheet;
    pnlSelectData: TPanel;
    chkCreateCashBook: TCheckBox;
    chkBankFeed: TCheckBox;
    chkChartofAccount: TCheckBox;
    chkBalances: TCheckBox;
    chkTransactions: TCheckBox;
    tabTermsAndConditions: TTabSheet;
    tabProgress: TTabSheet;
    pnlProgress: TPanel;
    tabComplete: TTabSheet;
    pnlTabButtonHider: TPanel;
    lblProgressTitle: TLabel;
    lblFirstProgress: TLabel;
    prgFirstProgress: TRzProgressBar;
    Label1: TLabel;
    Label2: TLabel;
    lRead: TLabel;
    chkAcceptAgreement: TCheckBox;
    pnlWebBrowser: TPanel;
    BKTermsWebBrowser: TBKWebBrowser;
    procedure btnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnLoginClick(Sender: TObject);
    procedure cmbSelectFirmChange(Sender: TObject);
    procedure chkChartofAccountClick(Sender: TObject);
    procedure chkAcceptAgreementClick(Sender: TObject);

  private
    fClient: TClientObj;
    fCurrentStepID: integer;
    fMonths: TMonthEndings;
    MonthEndStr: string;
    fLoggedIn : Boolean;
    fFirmSelected : Boolean;
    fTermsAndConditionsAccepted : Boolean;

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
    procedure UpdateControls;
    function IsLastStep : boolean;

  public
    destructor Destroy; override;
  end;

  function RunCashBookMigrationWizard() : boolean;

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
  WarningMoreFrm,
  CashbookMigration;

const
  mtOverview           = 1; mtMin = 1;
  mtMYOBCredentials    = 2;
  mtSelectData         = 3;
  mtTermsAndConditions = 4;
  mtProgress           = 5;
  mtCompleteMigration  = 6; mtMax = 6;

  StepTitles: array[mtMin..mtMax] of string = (
    'Overview',
    'MYOB Credentials',
    'Select Data',
    'Terms and conditions',
    'Migration Progress',
    'Complete'
  );

  StepDescriptions: array[mtMin..mtMax] of string = (
    'Desc 1',
    'Desc 2',
    'Desc 3',
    'Desc 4',
    'Desc 5',
    'Desc 6'
  );

  TabOrderArray: array [mtMin..mtMax] of byte = (
    mtOverview,
    mtMYOBCredentials,
    mtSelectData,
    mtTermsAndConditions,
    mtProgress,
    mtCompleteMigration
  );


//------------------------------------------------------------------------------
function RunCashBookMigrationWizard(): boolean;
var
  Wizard : TFrmCashBookMigrationWiz;
begin
  Wizard := TFrmCashBookMigrationWiz.Create(Application.MainForm); // FormCreate
  try
    result := (Wizard.ShowModal = mrOK);
  finally
    FreeAndNil(Wizard);
  end;
end;

//------------------------------------------------------------------------------
destructor TFrmCashBookMigrationWiz.Destroy;
begin
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
  tabMYOBCredentials.Tag := mtMYOBCredentials;
  tabSelectData.Tag := mtSelectData;
  tabTermsAndConditions.Tag := mtTermsAndConditions;
  tabProgress.Tag := mtProgress;
  tabComplete.Tag := mtCompleteMigration;
  for i := 0 to Pred(PageControl1.PageCount) do
    Assert(PageControl1.Pages[i].Tag <> 0, 'FormCreate: PageControl.Tag value not assigned');

  PageControl1.ActivePageIndex := 0;

  fLoggedIn := false;
  fFirmSelected := false;
  fTermsAndConditionsAccepted := false;

  DoAfterMoveToStep;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.btnLoginClick(Sender: TObject);
begin
  if (edtUser.text = '') or (edtPassword.text = '')  then
  begin
    HelpfulWarningMsg('Your Username and/or Password is invalid.  Please try again.',0);
    edtUser.SetFocus;
    Exit;
  end;

  fLoggedIn := true;

  UpdateControls();
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.chkChartofAccountClick(Sender: TObject);
begin
  chkBalances.Visible := (chkChartofAccount.Checked);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.cmbSelectFirmChange(Sender: TObject);
begin
  fFirmSelected := (cmbSelectFirm.ItemIndex > -1);

  UpdateControls();
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.btnNextClick(Sender: TObject);
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
procedure TFrmCashBookMigrationWiz.DoBeforeMoveToStep(OldStepID : integer; var NewStepID : integer; var Cancel : boolean);
//gives us an opportunity to save information on the current tab
var
  MovingForward : boolean;
begin
  Assert(OldStepID in [mtMin..mtMax], 'DoBeforeMoveToStep.OldStepID out of range');
  Assert(NewStepID in [mtMin..mtMax], 'DoBeforeMoveToStep.NewStepID out of range');

  MovingForward := GetOrderArrayPos(NewStepID) > GetOrderArrayPos(OldStepId);

  if MovingForward then
  begin
    {case OldStepID of
      {stMonth:
      begin
        {// Validation error?
        if not fMonths.ValidateMonthEnding(SelectedMonthIndex, sErrors) then
        begin
          HelpfulWarningMsg(sErrors, 0);
          Cancel := true;
          Exit;
        end;

        // Already run?
        if fMonths[SelectedMonthIndex].AlreadyRun then
        begin
          iContinue := AskYesNo(MonthEndingAlreadyRunTitle, MonthEndingAlreadyRunWarning, dlg_Yes, 0);
          if (iContinue <> dlg_Yes) then
          begin
            Cancel := true;
            Exit;
          end;
        end;
      end;
    end;  }
  end;

  //save existing
  CompleteStep(OldStepId);

  //now prepare for moving to new step,
  //allows us to initialise
  if MovingForward then
    InitialiseStep(NewStepId);
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.DoAfterMoveToStep;
var
  HTMLString : string;
begin
  Assert(fCurrentStepID in [mtMin..mtMax], 'DoAfterMoveToStep.CurrentStepID out of range');

  fCurrentStepID := PageControl1.ActivePage.Tag;

  //update titles
  lblTitle.Caption := StepTitles[fCurrentStepID];
  lblDescription.Caption := StepDescriptions[fCurrentStepID];

  UpdateControls;

  case fCurrentStepID of
    mtProgress : MigrateCashbook.PostDataToCashBook();
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
    'Are you sure that you want to exit the Cashbook Migration wizard? '#13 +
    'Any information you have entered will be lost.',
    Dlg_No, 0);
  if (iResult = DLG_No) then
    CanClose := false;
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
begin
  {case StepID of
    stPost:
    begin
      dtMonthEnding := fMonths[SelectedMonthIndex].MonthEndingDate;
      MonthEndStr := FormatDateTime('dd/mm/yy', dtMonthEnding);
      lblMonthEnding.Caption := FormatDateTime('dd/mm/yyyy', dtMonthEnding) + '.';
      PopulateGrid;
    end;
  end; }
end;

//------------------------------------------------------------------------------
function TFrmCashBookMigrationWiz.IsLastStep: boolean;
begin
  Result := (fCurrentStepID =  TabOrderArray[High(TabOrderArray)]);
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
    mtMYOBCredentials : Result := (fLoggedIn and fFirmSelected);
    mtTermsAndConditions : Result := (fTermsAndConditionsAccepted);
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmCashBookMigrationWiz.chkAcceptAgreementClick(Sender: TObject);
begin
  fTermsAndConditionsAccepted := (chkAcceptAgreement.Checked);

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
  case fCurrentStepID of
    mtMYOBCredentials : begin
      pnlFirm.Visible := fLoggedIn;
    end;
  end;

  if IsLastStep then
  begin
    btnNext.Caption := '&Yes';
    btnNext.ModalResult := mrYes;
    btnNext.Enabled := true;

    btnCancel.Caption := '&No';
    btnCancel.ModalResult := mrNo;
    btnCancel.Enabled := true;

    btnBack.Visible := false;
  end
  else
  begin
    btnNext.Enabled := CanMoveToNextStep(fCurrentStepID) and HasNextStep(fCurrentStepID);
    btnBack.Enabled := HasPreviousStep(fCurrentStepID);
  end;
end;

end.

