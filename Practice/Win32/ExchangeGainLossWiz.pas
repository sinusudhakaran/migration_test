unit ExchangeGainLossWiz;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, clObj32, TSMask, Grids_ts, TSGrid,
  BKDEFS, MoneyDef, baObj32, BKConst, Buttons,
  bkXPThemes, chList32,
  OSFont;


type
  TwizExchangeGainLoss = class(TForm)
    pnlButtons: TPanel;
    btnBack: TButton;
    btnNext: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    pnlWelcome: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblLine1: TLabel;
    lblLine2: TLabel;
    lblContinue: TLabel;
    Panel4: TPanel;
    Image2: TImage;
    pnlWizard: TPanel;
    pnlTabTitle: TPanel;
    lblTitle: TLabel;
    lblDescription: TLabel;
    Image1: TImage;
    pnlTabButtonHider: TPanel;
    PageControl1: TPageControl;
    tbsPost: TTabSheet;
    Bevel2: TBevel;
    pnlWarnings: TPanel;
    WarningBmp: TImage;
    Label3: TLabel;
    lblWarnings: TLabel;
    imgLine1: TImage;
    imgLine2: TImage;
    tgBalances: TtsGrid;
    pnlAdjustmentsFooter: TPanel;
    pnlAdjustmentsHeader: TPanel;
    lblAmountRemText: TLabel;
    lblAmountRemaining: TLabel;
    Label4: TLabel;
    tbsMonth: TTabSheet;
    lblWellDone: TLabel;
    lblAdjDate: TLabel;
    lblFinishNote: TLabel;
    procedure btnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure tgBalancesInvalidMaskValue(Sender: TObject; DataCol,
      DataRow: Integer; var Accept: Boolean);
    procedure tgBalancesCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgBalancesStartCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgBalancesKeyPress(Sender: TObject; var Key: Char);
    procedure tgBalancesEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tgBalancesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    fClient: TClientObj;
    fCurrentStepID: integer;

    // Wizard steps
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
    procedure UpdateButtons;
  public
    { Public declarations }
  end;

  function RunExchangeGainLossWizard(aClient : TClientObj) : boolean;

//******************************************************************************
implementation

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
  ExchangeGainLoss,
  GenUtils,
  Globals,
  GSTCalc32,
  ImagesFrm,
  jnlUtils32,
  TrialBalanceOptionsDlg,
  TrxList32,
  OpeningBalancesDlg,
  ProfitAndLossOptionsDlg,
  SignUtils,
  WinUtils,
  YesNoDlg,
  CountryUtils,
  ForexHelpers;

{$R *.dfm}

const
  stWelcome  = 0; stMin = 0;
  stMonth    = 1;
  stPost     = 2; stMax = 2;

const
  StepTitles: array[stMin..stMax] of string = (
    'Welcome',
    'Select Month',
    'Post Exchange Gains/Losses'
  );

  StepDescriptions: array[stMin..stMax] of string = (
    'Calculate Exchange Gain/Loss Wizard',
    'Choose the month you want to create the difference on exchange postings for.',
    'Review and post the amounts to complete the wizard.'
  );

const
  TabOrderArray: array [stMin..stMax] of byte = (
    stWelcome,
    stMonth,
    stPost
  );

function GetOrderArrayPos(ForStepID : integer) : integer;
var
  sNo : integer;
begin
  result := -1;
  for sNo := stMin to stMax do
    if TabOrderArray[sNo] = ForStepID then
      result := sNo;

  Assert(result > -1, 'GetOrderArrayPos.Step not found in list');
end;

function RunExchangeGainLossWizard(aClient : TClientObj): boolean;
var
  Wizard : TwizExchangeGainLoss;
  HasWarnings : boolean;
  ErrorMsg : string;
begin
  Wizard := TwizExchangeGainLoss.Create(Application.MainForm);
  try
    with Wizard do
    begin
       BKHelpSetup(Wizard, BKH_Calculate_exchange_gain_or_loss);

      fClient := aClient;

      // Validate bank accounts
      ValidateExchangeGainLoss(fClient, ErrorMsg);
      HasWarnings := (ErrorMsg <> '');

      // Display warnings (if there are any)
      pnlWarnings.Visible := HasWarnings;
      lblWarnings.Caption := ErrorMsg;
      lblContinue.Visible := not HasWarnings;

      // Buttons
      btnNext.Enabled := not HasWarnings;
      btnBack.Enabled := false;

      // Cancelled?
      result := (ShowModal = mrOK);
      if not result then
        exit;
    end;
  finally
    FreeAndNil(Wizard);
  end;
end;

procedure TwizExchangeGainLoss.FormCreate(Sender: TObject);
var
  i : integer;
begin
  // Setup
  lblAmountRemaining.Font.Style := [fsBold];
  lblTitle.Font.Name := Font.Name;
  lblWarnings.Font.Style := [fsBold];
  tgbalances.HeadingFont := Font;
  bkXPThemes.ThemeForm(Self);

  // Start with the welcome screen (which is a panel over the Pages)
  fCurrentStepID := stWelcome;
  pnlWizard.Visible := false;
  pnlWizard.Align := alClient;
  pnlWelcome.Visible := true;
  pnlWelcome.Align := alClient;

  // Increase the width if there's space
  if (Screen.WorkAreaWidth > 640) then
    Width := 760;

  // WORKAROUND: for partially visible tabs (from Year/End balance wizard)
  pnlTabButtonHider.Left := 0;
  pnlTabButtonHider.BevelOuter := bvNone;

  // Setup Page Tags
  tbsMonth.Tag := stMonth;
  tbsPost.Tag := stPost;
  for i := 0 to Pred(PageControl1.PageCount) do
    Assert(PageControl1.Pages[i].Tag <> 0, 'FormCreate Tag value not assigned');
end;

procedure TwizExchangeGainLoss.btnNextClick(Sender: TObject);
begin
  if CanMoveToNextStep(fCurrentStepID) then begin
    CompleteStep(fCurrentStepID);
    if HasNextStep(fCurrentStepID) then
      MoveToStep(NextStep(fCurrentStepID));
  end;
end;

procedure TwizExchangeGainLoss.btnBackClick(Sender: TObject);
begin
  if HasPreviousStep(fCurrentStepID) then
    MoveToStep(PrevStep(fCurrentStepID));
end;

procedure TwizExchangeGainLoss.MoveToStep(StepID: integer);
//called from the Back and Next Buttons
var
  Cancel : boolean;
  NewStepID : integer;
begin
  Assert(StepID in [stMin..stMax], 'Step No out of range');
  NewStepID := StepID;

  //save settings on current page before moving
  Cancel := false;
  DoBeforeMoveToStep(fCurrentStepID, NewStepID, Cancel);
  if Cancel then
    Exit;

  case NewStepID of
    stWelcome : begin
      pnlWizard.Visible := False;
      pnlWelcome.Visible := True;
    end;
  else
    begin
      PageControl1.ActivePage := FindPage(NewStepID);
    end;
  end;

  DoAfterMoveToStep;
end;

function TwizExchangeGainLoss.NextStep(StepID: integer): integer;
var
  CurrPosInArray : integer;
  Found          : boolean;
begin
  Assert(StepID in [stMin..stMax], 'NextStep.Old Step out of range');

  CurrPosInArray := GetOrderArrayPos(StepID);

  //cycle thru list trying to find next valid step
  Found := false;
  while (CurrPosInArray in [stMin..stMax]) and (not Found) do begin
    Inc(CurrPosInArray);
    if CurrPosInArray in [stMin..stMax] then
      Found := StepAvailable(TabOrderArray[CurrPosInArray]);
  end;

  //return step if found, otherwise don't move
  if Found then
    result := TabOrderArray[CurrPosInArray]
  else
    result := StepID;
end;

function TwizExchangeGainLoss.PrevStep(StepID: integer): integer;
var
  sNo : integer;
  CurrPosInArray : integer;
  Found : boolean;
begin
  Assert(StepID in [stMin..stMax], 'PrevStep.Old Step out of range');

  CurrPosInArray := -1;
  for sNo := stMin to stMax do
    if TabOrderArray[sNo] = StepID then
      CurrPosInArray := sNo;

  Assert(CurrPosInArray > -1, 'Current Step not found in list');

  //cycle thru list trying to find next valid step
  Found := false;
  while (CurrPosInArray in [stMin..stMax]) and (not Found) do begin
    Dec(CurrPosInArray);
    if CurrPosInArray in [stMin..stMax] then
      Found := StepAvailable(TabOrderArray[CurrPosInArray]);
  end;

  //return step if found, otherwise don't move
  if Found then
    result := TabOrderArray[CurrPosInArray]
  else
    result := StepID;
end;

procedure TwizExchangeGainLoss.DoBeforeMoveToStep(OldStepID : integer; var NewStepID : integer; var Cancel : boolean);
//gives us an opportunity to save information on the current tab
var
  MovingForward : boolean;
begin
  Assert(OldStepID in [stMin..stMax], 'DoBeforeMoveToStep.OldStepID out of range');
  Assert(NewStepID in [stMin..stMax], 'DoBeforeMoveToStep.NewStepID out of range');

  MovingForward := GetOrderArrayPos(NewStepID) > GetOrderArrayPos(OldStepId);

  //save existing
  CompleteStep(OldStepId);

  //now prepare for moving to new step,
  //allows us to initialise
  if MovingForward then
    InitialiseStep(NewStepId);
end;

procedure TwizExchangeGainLoss.DoAfterMoveToStep;
var
  IsLastStep : boolean;
begin
  Assert(fCurrentStepID in [stMin..stMax], 'DoAfterMoveToStep.CurrentStepID out of range');

  //update current step no
  if pnlWelcome.Visible  then
    fCurrentStepID := stWelcome
  else
    fCurrentStepID := PageControl1.ActivePage.Tag;

  //update titles
  lblTitle.Caption := StepTitles[fCurrentStepID];
  lblDescription.Caption := StepDescriptions[fCurrentStepID];

  //set up buttons
  IsLastStep := (fCurrentStepID =  TabOrderArray[High(TabOrderArray)]);

  UpdateButtons;

  if IsLastStep then begin
    btnNext.Caption := '&Finish';
    btnNext.ModalResult := mrOK;
    btnNext.Enabled := true;
  end
  else begin
    btnNext.Caption := '&Next >';
    btnNext.ModalResult := mrNone;
  end;

  //now do after move events for specific steps
  case fCurrentStepID of
    stMonth:
    begin
    end;
  end;
end;

function TwizExchangeGainLoss.HasNextStep(StepID: integer): boolean;
begin
  result := NextStep(StepID) <> StepID;
end;

function TwizExchangeGainLoss.HasPreviousStep(StepID: integer): boolean;
begin
  result := PrevStep(StepID) <> StepID;
end;

function TwizExchangeGainLoss.FindPage(StepID: integer): TTabSheet;
var
  i : integer;
begin
  result := PageControl1.ActivePage;

  for i := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[i].Tag = StepID then
      result := PageControl1.Pages[i];
end;

procedure TwizExchangeGainLoss.tgBalancesInvalidMaskValue(Sender: TObject;
  DataCol, DataRow: Integer; var Accept: Boolean);
begin
  // TODO
end;

procedure TwizExchangeGainLoss.tgBalancesCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
begin
  // TODO
end;

procedure TwizExchangeGainLoss.tgBalancesStartCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
begin
  // TODO
end;

procedure TwizExchangeGainLoss.tgBalancesKeyPress(Sender: TObject;
  var Key: Char);
begin
  // TODO
end;

procedure TwizExchangeGainLoss.tgBalancesEndCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
begin
  // TODO
end;

procedure TwizExchangeGainLoss.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult <> mrOK) and (fCurrentStepID <> stWelcome) then begin
    if AskYesNo('Exit ' + Self.Caption,
                'Are you sure that you want to exit the Exchange Gain/Loss wizard? '#13 +
                'Any information you have entered will be lost.',
                Dlg_No, 0) = DLG_No then
      CanClose := false;
  end;
end;

procedure TwizExchangeGainLoss.tgBalancesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  // TODO
end;

function TwizExchangeGainLoss.StepAvailable(StepID : integer) : boolean;
//used by next and prev to determine if this step can be used
begin
  // TODO: some sort of check if it's allowed, etc
  result := True;
end;

procedure TwizExchangeGainLoss.InitialiseStep(StepID: integer);
begin
  // TODO
end;

function TwizExchangeGainLoss.CompleteStep(StepID: integer): boolean;
begin
  // TODO
  result := true;
  case StepID of
    stWelcome:
    begin
      pnlWelcome.Visible := False;
      pnlWizard.Visible := True;
    end;
  end;
end;

function TwizExchangeGainLoss.CanMoveToNextStep(StepID: integer): boolean;
begin
  // TODO
  result := true;
end;

procedure TwizExchangeGainLoss.UpdateButtons;
begin
  // TODO
  btnNext.Enabled := CanMoveToNextStep(fCurrentStepID) and HasNextStep(fCurrentStepID);
  btnBack.Enabled := HasPreviousStep(fCurrentStepID);
end;

end.

