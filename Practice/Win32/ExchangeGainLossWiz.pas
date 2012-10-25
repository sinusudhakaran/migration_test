unit ExchangeGainLossWiz;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, clObj32, TSMask, Grids_ts, TSGrid,
  BKDEFS, MoneyDef, baObj32, BKConst, Buttons,
  bkXPThemes, chList32,
  Math,
  OSFont,
  ExchangeGainLoss;


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
    memWarnings: TMemo;
    imgLine1: TImage;
    imgLine2: TImage;
    tgBalances: TtsGrid;
    pnlAdjustmentsFooter: TPanel;
    pnlAdjustmentsHeader: TPanel;
    lblAmountRemText: TLabel;
    lblAmountRemaining: TLabel;
    Label4: TLabel;
    tbsMonth: TTabSheet;
    lblAdjDate: TLabel;
    cmbMonth: TComboBox;
    lblMonthLine1: TLabel;
    lblMonthLine2: TLabel;
    lblMonthLine3: TLabel;
    lblMonth: TLabel;
    lblNoMonthEndings: TLabel;
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
    procedure cmbMonthDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    fClient: TClientObj;
    fCurrentStepID: integer;
    fMonths: TMonthEndings;

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
    destructor Destroy; override;

    { The month index as stored in cmbMonth.Items.Objects
      Note: the month endings are stored in reverse order, so can not use
      cmbMonth.ItemIndex. }
    function  GetMonthIndexFrom(const aIndex: integer): integer;
    function  GetSelectedMonthIndex: integer;
    property  SelectedMonthIndex: integer read GetSelectedMonthIndex;
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
  ForexHelpers,
  WarningMoreFrm;

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

{------------------------------------------------------------------------------}
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

{------------------------------------------------------------------------------}
function RunExchangeGainLossWizard(aClient : TClientObj): boolean;
var
  Wizard : TwizExchangeGainLoss;
  HasWarnings : boolean;
  ErrorMsg : string;
  i: integer;
begin
  Wizard := TwizExchangeGainLoss.Create(Application.MainForm); // FormCreate
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
      memWarnings.Text := ErrorMsg;
      lblContinue.Visible := not HasWarnings;

      // Buttons
      btnNext.Enabled := not HasWarnings;
      btnBack.Enabled := false;

      // Obtain month endings
      if not HasWarnings then
      begin
        // Create here because in the constructor/FormCreate there's no fClient yet
        fMonths := TMonthEndings.Create(fClient);
        fMonths.ObtainMonthEndings;

        // Add to combo box in REVERSE order
        for i := fMonths.Count-1 downto 0 do
        begin
          cmbMonth.AddItem('', TObject(i));
        end;

        // Enable/disable month combobox and warnings
        cmbMonth.Enabled := (fMonths.Count > 0);
        lblNoMonthEndings.Visible := not cmbMonth.Enabled;

        // Select the earliest month (or last in the list really)
        if cmbMonth.Enabled then
          cmbMonth.ItemIndex := cmbMonth.Items.Count-1;
      end;

      // Cancelled?
      result := (ShowModal = mrOK);
      if not result then
        exit;
    end;
  finally
    FreeAndNil(Wizard);
  end;
end;

{------------------------------------------------------------------------------}
destructor TwizExchangeGainLoss.Destroy;
begin
  FreeAndNil(fMonths);

  inherited; // LAST
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.FormCreate(Sender: TObject);
var
  i: integer;
  iNewItemHeight: integer;
begin
  // Setup
  lblAmountRemaining.Font.Style := [fsBold];
  lblTitle.Font.Name := Font.Name;
  memWarnings.Font.Style := [fsBold];
  tgbalances.HeadingFont := Font;
  lblNoMonthEndings.Font.Style := [fsBold];
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
    Assert(PageControl1.Pages[i].Tag <> 0, 'FormCreate: PageControl.Tag value not assigned');

  { Fonts get resized at runtime, and as a result the OnDrawItem leaves out the
    bottom bit. The Rect for drawing is also smaller because OnDrawItem takes
    some pixels off the top/bottom, so we need to compensate for that as well.
  }
  iNewItemHeight := 6 + cmbMonth.Canvas.TextHeight('Wg');
  cmbMonth.ItemHeight := Max(cmbMonth.ItemHeight, iNewItemHeight);
end;

{------------------------------------------------------------------------------}
function TwizExchangeGainLoss.GetMonthIndexFrom(const aIndex: integer): integer;
begin
  if (aIndex = -1) then
    result := -1
  else
    result := integer(cmbMonth.Items.Objects[aIndex]);
end;

{------------------------------------------------------------------------------}
function TwizExchangeGainLoss.GetSelectedMonthIndex: integer;
begin
  result := GetMonthIndexFrom(cmbMonth.ItemIndex);
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // ALT-M
  if (fCurrentStepID = stMonth) and (Shift = [ssAlt]) and (Key = Ord('M')) then
  begin
    if cmbMonth.CanFocus then
      cmbMonth.SetFocus;
  end;
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.btnNextClick(Sender: TObject);
begin
  if CanMoveToNextStep(fCurrentStepID) then begin
    CompleteStep(fCurrentStepID);
    if HasNextStep(fCurrentStepID) then
      MoveToStep(NextStep(fCurrentStepID));
  end;
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.btnBackClick(Sender: TObject);
begin
  if HasPreviousStep(fCurrentStepID) then
    MoveToStep(PrevStep(fCurrentStepID));
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.MoveToStep(StepID: integer);
//called from the Back and Next Buttons
var
  Cancel : boolean;
  NewStepID : integer;
  ToWelcomePage: boolean;
begin
  Assert(StepID in [stMin..stMax], 'Step No out of range');
  NewStepID := StepID;

  //save settings on current page before moving
  Cancel := false;
  DoBeforeMoveToStep(fCurrentStepID, NewStepID, Cancel);
  if Cancel then
    Exit;

  // The welcome page is a special page
  ToWelcomePage := (NewStepID = stWelcome);
  pnlWelcome.Visible := ToWelcomePage;
  pnlWizard.Visible := not ToWelcomePage;

  PageControl1.ActivePage := FindPage(NewStepID);

  DoAfterMoveToStep;
end;

{------------------------------------------------------------------------------}
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

{------------------------------------------------------------------------------}
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

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.DoBeforeMoveToStep(OldStepID : integer; var NewStepID : integer; var Cancel : boolean);
//gives us an opportunity to save information on the current tab
var
  MovingForward : boolean;
  sErrors: string;
begin
  Assert(OldStepID in [stMin..stMax], 'DoBeforeMoveToStep.OldStepID out of range');
  Assert(NewStepID in [stMin..stMax], 'DoBeforeMoveToStep.NewStepID out of range');

  MovingForward := GetOrderArrayPos(NewStepID) > GetOrderArrayPos(OldStepId);

  if MovingForward then
  begin
    case OldStepID of
      stMonth:
      begin
        // Validation error?
        if not fMonths.ValidateMonthEnding(SelectedMonthIndex, sErrors) then
        begin
          HelpfulWarningMsg(sErrors, 0);

          Cancel := true;

          Exit;
        end;
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

{------------------------------------------------------------------------------}
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

  // Initial focus per page
  case fCurrentStepID of
    stMonth:
      // If months available
      if cmbMonth.CanFocus then
        cmbMonth.SetFocus
      else if btnCancel.CanFocus then
        btnCancel.SetFocus; // So we can handle the enter key
    else
    begin
      // Set focus for first button
      if btnNext.CanFocus then
        btnNext.SetFocus
      else if btnCancel.CanFocus then
        btnCancel.SetFocus;
    end;
  end;
end;

{------------------------------------------------------------------------------}
function TwizExchangeGainLoss.HasNextStep(StepID: integer): boolean;
begin
  result := NextStep(StepID) <> StepID;
end;

{------------------------------------------------------------------------------}
function TwizExchangeGainLoss.HasPreviousStep(StepID: integer): boolean;
begin
  result := PrevStep(StepID) <> StepID;
end;

{------------------------------------------------------------------------------}
function TwizExchangeGainLoss.FindPage(StepID: integer): TTabSheet;
var
  i : integer;
begin
  result := PageControl1.ActivePage;

  for i := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[i].Tag = StepID then
      result := PageControl1.Pages[i];
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.tgBalancesInvalidMaskValue(Sender: TObject;
  DataCol, DataRow: Integer; var Accept: Boolean);
begin
  // TODO
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.tgBalancesCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
begin
  // TODO
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.tgBalancesStartCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
begin
  // TODO
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.tgBalancesKeyPress(Sender: TObject;
  var Key: Char);
begin
  // TODO
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.tgBalancesEndCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
begin
  // TODO
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.tgBalancesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  // TODO
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  iResult: integer;
begin
  // Next/Finish button?
  if (ModalResult = mrOK) then
    exit;

  // Specific overrides where there is no "are you sure?" question
  case fCurrentStepID of
    stWelcome:
      exit;
    stMonth:
      if not cmbMonth.Enabled then
        exit;
  end;

  // Not sure?
  iResult := AskYesNo(
    'Exit ' + Self.Caption,
    'Are you sure that you want to exit the Exchange Gain/Loss wizard? '#13 +
    'Any information you have entered will be lost.',
    Dlg_No, 0);
  if (iResult = DLG_No) then
    CanClose := false;
end;

{------------------------------------------------------------------------------}
function TwizExchangeGainLoss.StepAvailable(StepID : integer) : boolean;
//used by next and prev to determine if this step can be used
begin
  result := True;
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.InitialiseStep(StepID: integer);
begin
end;

{------------------------------------------------------------------------------}
function TwizExchangeGainLoss.CompleteStep(StepID: integer): boolean;
begin
  result := true;
end;

{------------------------------------------------------------------------------}
function TwizExchangeGainLoss.CanMoveToNextStep(StepID: integer): boolean;
begin
  // Normally okay
  result := true;

  if (fCurrentStepID = stMonth) and not cmbMonth.Enabled then
    result := false;
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.UpdateButtons;
begin
  btnNext.Enabled := CanMoveToNextStep(fCurrentStepID) and HasNextStep(fCurrentStepID);
  btnBack.Enabled := HasPreviousStep(fCurrentStepID);
end;

{------------------------------------------------------------------------------}
procedure TwizExchangeGainLoss.cmbMonthDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  iMonthIndex: integer;
  Image: TImage;
  sValue: string;
begin
  ASSERT((0 <= Index) and (Index < cmbMonth.Items.Count));
  ASSERT(Assigned(cmbMonth.Canvas));

  // This line draws the actual bitmap
  iMonthIndex := GetMonthIndexFrom(Index);
  with fMonths[iMonthIndex], cmbMonth.Canvas do
  begin
    // This ensures the correct highlite color is used
    FillRect(Rect);

    // Month
    sValue := FormatDateTime('mmm', Date);
    TextOut(Rect.Left+6, Rect.Top+1, sValue);

    // Year
    sValue := IntToStr(Year);
    TextOut(Rect.Left+40, Rect.Top+1, sValue);

    // Locked/Transferred
    if Finalised and Transferred then
      Image := AppImages.imgTickLock
    else if Finalised then
      Image := AppImages.imgLock
    else if Transferred then
      Image := AppImages.imgTick
    else
      Image := nil;

    // Month status (optional)
    if Assigned(Image) then
      Draw(Rect.Left+80, Rect.Top+1, Image.Picture.Bitmap);

    // Already Run (optional)
    if AlreadyRun then
      TextOut(Rect.Left+110, Rect.Top+1, 'Already Run');
  end;
end;


end.

