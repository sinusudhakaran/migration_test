unit BalancesForwardWiz;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:
           Preconditions :
             All transactions MUST be coded
             All contra accounts MUST be specified
             All contra accounts MUST be valid accounts

           Steps :

           Verify that preconditions are meet

           Check to see if opening balances already entered

           Confirm/Adjust Closing Balances for all accounts

           Allow Printing of year end reports

           Nominate Accounts for Current Years Earnings to be placed into

           Finished
}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, clObj32, TSMask, Grids_ts, TSGrid,
  BKDEFS, MoneyDef, baObj32, BKConst, Buttons,
  bkXPThemes, chList32,
  OSFont;


type
   TAdjustmentRec = record
     Account      : pAccount_Rec;
     CurrentBal   : Money;
     AdjustedBal  : Money;
     Difference   : Money;
   end;

   TAdjInfoArray = Array of TAdjustmentRec;

   TEarningsRec = record
     Account    : BK5CodeStr;
     Amount     : Money;
   end;

   TEarningsArray = Array of TEarningsRec;

type
  TwizBalancesForward = class(TForm)
    pnlButtons: TPanel;
    btnBack: TButton;
    btnNext: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    pnlWelcome: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblAdjust: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Panel4: TPanel;
    Image2: TImage;
    pnlWizard: TPanel;
    pnlTabTitle: TPanel;
    lblTitle: TLabel;
    lblDescription: TLabel;
    Image1: TImage;
    pnlTabButtonHider: TPanel;
    PageControl1: TPageControl;
    tbsAdjustments: TTabSheet;
    tbsCurrentEarnings: TTabSheet;
    Bevel2: TBevel;
    pnlWarnings: TPanel;
    WarningBmp: TImage;
    Label3: TLabel;
    lblWarnings: TLabel;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    tsMaskDefs1: TtsMaskDefs;
    tgBalances: TtsGrid;
    pnlAdjustmentsFooter: TPanel;
    pnlAdjustmentsHeader: TPanel;
    lblAmountRemText: TLabel;
    lblAmountRemaining: TLabel;
    Label4: TLabel;
    tbsReports: TTabSheet;
    tbsOpeningBalancesFound: TTabSheet;
    lblOpeningBalancesFound: TLabel;
    rbReplaceOpeningBalances: TRadioButton;
    rbLeaveOpeningBalances: TRadioButton;
    lblReplaceNote: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    lblReportYearStart: TLabel;
    tgEarnings: TtsGrid;
    Panel1: TPanel;
    Panel2: TPanel;
    lblCurrentYearsEarningsAmt: TLabel;
    lblEarningsRemText: TLabel;
    lblEarningsRemaining: TLabel;
    tbsFinshed: TTabSheet;
    lblWellDone: TLabel;
    tbsCreateOpening: TTabSheet;
    lblAddOpeningBalances: TLabel;
    rbAddedOpeningBalances: TRadioButton;
    rbNoOpeningBalances: TRadioButton;
    lblAdjDate: TLabel;
    edtHiddenEdit: TEdit;
    btnChart: TSpeedButton;
    lblFinishNote: TLabel;
    chkEditOpening: TCheckBox;
    Image6: TImage;
    procedure btnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
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
    procedure tgEarningsCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgEarningsEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgEarningsStartCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure tgEarningsInvalidMaskValue(Sender: TObject; DataCol,
      DataRow: Integer; var Accept: Boolean);
    procedure tgEarningsKeyPress(Sender: TObject; var Key: Char);
    procedure tgEarningsCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; ByUser: Boolean);
    procedure tgEarningsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnChartClick(Sender: TObject);
    procedure tgEarningsKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    ThisClient               : TClientObj;
    AdjustmentInfoArray      : TAdjInfoArray;
    EarningsArray            : TEarningsArray;
    CurrentYearsEarnings     : Money;
    RemovingMask             : boolean;
    HasWarnings              : boolean;
    ExistingOBFound          : boolean;
    OverwriteBalances        : boolean;
    ManuallyAddBalances      : boolean;

    YE_Journal_Account       : TBank_Account;
    TempYEAdjustment         : pTransaction_Rec;
    Existing_YE_Adjustment   : pTransaction_Rec;

    CurrentStepID            : integer;
    CurrencySymbol           : string;
    procedure LoadAdjustments;
    procedure SaveAdjustmentsToTempJournal;
    procedure DisplayAdjustments;
    function  GetAmountRemaining : Money;
    procedure UpdateBalanceRemaining;
    procedure SetupAdjustmentsGrid;

    procedure UpdateCYAmountRemaining;
    function  GetCYAmountRemaining : Money;
    procedure CalculateCurrentYearsEarnings;
    procedure SetupEarningsGrid;

    procedure SaveOpeningBalances;

    function  FindPage( StepID : integer) : TTabSheet;
    procedure MoveToStep( StepID : integer);
    function  NextStep( StepID : integer) : integer;
    function  PrevStep( StepID : integer) : integer;
    function  HasPreviousStep( StepID : integer) : boolean;
    function  HasNextStep( StepID : integer) : boolean;
    procedure DoBeforeMoveToStep( OldStepID : integer; var NewStepID : integer; var Cancel : boolean);
    procedure DoAfterMoveToStep;

    function  StepAvailable( StepID : integer) : boolean;
    procedure InitialiseStep( StepID : integer);
    function  CompleteStep( StepID : integer) : boolean;

    function  CanMoveToNextStep( StepID : integer) : boolean;
    procedure UpdateButtons;

    procedure DoAccountLookup;
  public
    { Public declarations }
  end;

  function RunBalancesForwardWizard(aClient : TClientObj) : boolean;

//******************************************************************************
implementation

uses
  AccountInfoObj,
  AccountLookupFrm,
  BalancesForward,
  BalanceSheetOptionsDlg,
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
  ForexHelpers;

{$R *.dfm}

const
  //Adjustments Grid Columns
  ColAccount     = 1;
  ColDesc        = 2;
  ColBalance     = 3;
  ColSign        = 4;
  ColAdjBalance  = 5;
  ColAdjSign     = 6;
  ColMovement    = 7;
  ColReportGroup = 8;

  //Retained P & L grid columns
  ColEarningsAccount = 1;
  ColEarningsDesc    = 2;
  ColEarningsAmount  = 3;
  ColEarningsSign    = 4;

const
  stMin = 0;

  stWelcomePage              = 0;
  stOverwriteOpeningBalances = 1;
  stYearEndAdjustments       = 2;
  stPrintFinancialReports    = 3;
  stCreateOpening            = 4;
  stAssignRetainedPL         = 5;
  stFinished                 = 6;

  stMax = 6;

const
  StepTitles : Array[ stMin..stMax] of string =
                (
                  'Welcome',
                  'Overwrite Existing Opening Balances?',
                  'Adjust Year End Balances',
                  'Print Year End Reports',
                  'Add Opening Balances for New Financial Year?',
                  'Allocate Current Years Earnings',
                  'Finished'
                );
  StepDescriptions : Array[ stMin..stMax] of string =
                (
                  'Welcome',
                  'Opening Balances have already been entered for the new financial year. ',
                  'You may now adjust the year end balances for your accounts.',
                  'You may now print the following year end reports.',
                  'You may now select whether Opening Balances should be automatically added to the new financial year.',
                  'You must now allocate your Current Years Earnings to your Retained P&L account(s).',
                  'You have completed the Year End Balances Wizard.'
                );

const
  MaxEarningsLines = 50;

const
  TabOrderArray : Array [ stMin..stMax] of byte =
                  (
                     stWelcomePage,
                     stYearEndAdjustments,
                     stPrintFinancialReports,
                     stOverwriteOpeningBalances,
                     stCreateOpening,
                     stAssignRetainedPL,
                     stFinished
                  );

function GetOrderArrayPos( ForStepID : integer) : integer;
var
  sNo : integer;
begin
  result := -1;
  for sNo := stMin to stMax do
    if TabOrderArray[ sNo] = ForStepID then
      result := sNo;

  Assert( result > -1, 'GetOrderArrayPos.Step not found in list');
end;

function EarningsFilter(const pAcct : pAccount_Rec) : boolean;
begin
  result := pAcct.chAccount_Type in BKConst.BalanceSheetReportGroupsSet;
end;

function DrCr2Real( Value : Money; aSign : TSign) : Money;
begin
  if SignOf( Value) = aSign then
    Result := Abs(Value)
  else
    Result := -1 * Abs(Value);
end;

function RunBalancesForwardWizard( aClient : TClientObj) : boolean;
var
  frmBalancesForward : TwizBalancesForward;
  ErrorMsg : string;
  OBFound  : boolean;
begin
  //setup parameters
  BalancesForward.SetupParameters( aClient);
  //check preconditions
  BalancesForward.VerifyPreconditions( aClient, ErrorMsg);
  //check if opening balances already exist
  OBFound := CheckForOpeningBalance( aClient, aClient.clFields.clFinancial_Year_Starts);

  result := false;
  frmBalancesForward := TwizBalancesForward.Create(Application.MainForm);
  with frmBalancesForward do begin
    try
      BKHelpSetup(frmBalancesForward, BKH_Chapter_15_Year_End_Balances);
      OverwriteBalances        := True;
      ManuallyAddBalances      := False;
      ExistingOBFound          := OBFound;
      HasWarnings              := ErrorMsg <> '';
      ThisClient               := aClient;
      CurrencySymbol           := ThisClient.CurrencySymbol;

      //Use all bank accounts for this client
      CalculateAccountTotals.FlagAllAccountsForUse( ThisClient);

      //load adjustments
      if not HasWarnings then begin
        LoadAdjustments;
        //display adjustments
        DisplayAdjustments;
        UpdateBalanceRemaining;
      end;
      //update welcome screen
      lblAdjust.Caption := 'Adjust Closing Balances for year ' +
                           bkDate2Str( ThisClient.clFields.clLast_Financial_Year_Start) + ' to ' +
                           bkDate2Str( ThisClient.clFields.clFinancial_Year_Starts - 1);

      lblWellDone.Caption := 'By completing the Year End Balances Wizard, you have:';

      //display any warnings
      lblWarnings.Caption := ErrorMsg;
      pnlWarnings.Visible := HasWarnings;

      btnNext.Enabled     := not HasWarnings;
      btnBack.Enabled     := false;

      if ShowModal = mrOK then begin
        //save year end adjustments
        //the year end adjustments journal has already been saved, set pointer to
        //nil so that it is not deleted in the clean up
        TempYEAdjustment := nil;
        //free existing journal, if there was one, as we are keeping the new jnl
        if Assigned( Existing_YE_Adjustment) then begin
          TrxList32.Dispose_Transaction_Rec( Existing_YE_Adjustment);
          Existing_YE_Adjustment := nil;
        end;
        //remove empty journals
        if Assigned( YE_Journal_Account) then
          RemoveJnlAccountIfEmpty( ThisClient, YE_Journal_Account);

        //generate opening balance journal if required
        if (not ManuallyAddBalances ) and (OverwriteBalances) then
          SaveOpeningBalances;
        //now show the opening balances if the user has requested it
        // #3753 - still must save them
        OpeningBalancesDlg.EditOpeningBalances( ThisClient, SAVE_BAL_ONLY);
        if chkEditOpening.Checked then
          OpeningBalancesDlg.EditOpeningBalances( ThisClient);
      end
      else begin
        //need to clean up any opening balances or year end adjustments
        if Assigned( YE_Journal_Account) then begin
          //remove the temp journal if not keeping
          if Assigned( TempYEAdjustment) then
            YE_Journal_Account.baTransaction_List.DelFreeItem( TempYEAdjustment);
          //replace the pre existing journal
          if Assigned( Existing_YE_Adjustment) then begin
            YE_Journal_Account.baTransaction_List.Insert_Transaction_Rec( Existing_YE_Adjustment);
          end;
          //remove empty journals
          RemoveJnlAccountIfEmpty( ThisClient, YE_Journal_Account);
        end;
      end;
      //set back to monthly, reset reporting year starts
      ThisClient.clFields.clFRS_Reporting_Period_Type := frpMonthly;
      ThisClient.clFields.clReporting_Year_Starts     := ThisClient.clFields.clFinancial_Year_Starts;
    finally
      Free;
    end;
  end;
end;

procedure TwizBalancesForward.btnNextClick(Sender: TObject);
begin
  if CanMoveToNextStep( CurrentStepID) then begin
    CompleteStep( CurrentStepID);
    if HasNextStep( CurrentStepID) then
      MoveToStep( NextStep( CurrentStepID));
  end;
end;

procedure TwizBalancesForward.FormCreate(Sender: TObject);
var
  i : integer;
begin
  lblAmountRemaining.Font.Style := [fsBold];
  lblEarningsRemaining.Font.Style := [fsBold];
  rbReplaceOpeningBalances.Font.Style := [fsBold];
  rbLeaveOpeningBalances.Font.Style := [fsBold];

  lblTitle.Font.Name := Font.Name;
  lblWarnings.Font.Style := [fsBold];

  tgbalances.HeadingFont := Font;
  tgEarnings.HeadingFont := Font;
  bkXPThemes.ThemeForm(Self);
  CurrentStepID := stWelcomePage;   //initial step is the Welcome Screen
  pnlWizard.Visible  := false;
  pnlWizard.Align    := alClient;
  pnlWelcome.Visible := true;
  pnlWelcome.Align   := alClient;

  if Screen.WorkAreaWidth > 640 then
    Self.Width := 760;

  pnlTabButtonHider.Left       := 0;
  pnlTabButtonHider.BevelOuter := bvNone;

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,btnChart.Glyph);

  tbsAdjustments.Tag          := stYearEndAdjustments;
  tbsCurrentEarnings.Tag      := stAssignRetainedPL;
  tbsReports.Tag              := stPrintFinancialReports;
  tbsOpeningBalancesFound.Tag := stOverwriteOpeningBalances;
  tbsFinshed.Tag              := stFinished;
  tbsCreateOpening.Tag        := stCreateOpening;

  for i := 0 to Pred( PageControl1.PageCount) do
    Assert( PageControl1.Pages[i].Tag <> 0, 'FormCreate Tag value not assigned');

  SetupAdjustmentsGrid;
  SetupEarningsGrid;

  TempYEAdjustment   := nil;
  YE_Journal_Account := nil;
end;

procedure TwizBalancesForward.Button1Click(Sender: TObject);
begin
  ThisClient.clFields.clReporting_Year_Starts := ThisClient.clFields.clLast_Financial_Year_Start;
  TrialBalanceOptionsDlg.UpdateTrialBalanceReportOptions(ThisClient);
end;

procedure TwizBalancesForward.Button2Click(Sender: TObject);
begin
  ThisClient.clFields.clReporting_Year_Starts := ThisClient.clFields.clLast_Financial_Year_Start;
  ProfitAndLossOptionsDlg.UpdateProfitAndLossReportOptions( ThisClient);
end;

procedure TwizBalancesForward.Button3Click(Sender: TObject);
begin
  ThisClient.clFields.clReporting_Year_Starts := ThisClient.clFields.clLast_Financial_Year_Start;
  BalanceSheetOptionsDlg.UpdateBalanceSheetOptions( ThisClient);
end;

procedure TwizBalancesForward.LoadAdjustments;
//if an existing journal is found the journal should be deleted from the journal
//account, the trial balance figures can then be loaded normally.  The adjustment
//journal should be used to populate the adjustments column

//if no existing journal is found then load the current balance into the current
//balance col, other columns should be 0.

//Figures should be presented as Dr or Cr
var
  pJournal_Line      : pDissection_Rec;
  pAcct              : pAccount_Rec;
  i                  : integer;
  AccountInfo        : TAccountInformation;
  FChart: TCustomSortChart;
begin
  //set up temp array
  SetLength( AdjustmentInfoArray, ThisClient.clChart.ItemCount);
  for i := Low(AdjustmentInfoArray) to High(AdjustmentInfoArray) do begin
    with AdjustmentInfoArray[i] do begin
      Account       := nil;
      CurrentBal    := 0;
      AdjustedBal   := 0;
      Difference    := 0;
    end;
  end;

  //load sorted chart codes
  FChart := TCustomSortChart.Create(nil);
  try
    FChart.CopyChart(MyClient.clChart);
    if UseXlonSort then
      FChart.Sort(XlonCompare);
    for i := 0 to Pred( FChart.ItemCount) do begin
      pAcct := FChart.Account_At(i);
      pAcct.chTemp_Money_Value := 0;
      AdjustmentInfoArray[i].Account := pAcct;
    end;
   finally
     FreeAndNil(FChart);
   end;

  //load any pre-existing year end journal
  YE_Journal_Account      := nil;
  Existing_YE_Adjustment  := nil;
  With ThisClient.clBank_Account_List do For i := 0 to Pred( itemCount ) do
    With Bank_Account_At( i ) do
      If baFields.baAccount_Type = btYearEndAdjustments then {found it}
        YE_Journal_Account := Bank_Account_At( i );

  if Assigned( YE_Journal_Account) then begin
    //account exists, see if journal exists on date
    Existing_YE_Adjustment := jnlUtils32.GetJournalFor( YE_Journal_Account, ThisClient.clFields.clFinancial_Year_Starts - 1);
    if Assigned( Existing_YE_Adjustment) then begin
      //load totals into tmp values in chart
      pJournal_Line := Existing_YE_Adjustment^.txFirst_Dissection;
      while ( pJournal_Line <> nil) do begin
        pAcct := ThisClient.clChart.FindCode( pJournal_Line.dsAccount);
        if Assigned( pAcct) then begin
          pAcct.chTemp_Money_Value := pAcct.chTemp_Money_Value + pJournal_Line.dsAmount;
        end;
        pJournal_Line := pJournal_Line.dsNext;
      end;

      //now load values from chart into adjustment rec
      for i := Low(AdjustmentInfoArray) to High(AdjustmentInfoArray) do begin
        AdjustmentInfoArray[i].Difference := AdjustmentInfoArray[i].Account.chTemp_Money_Value;
      end;
    end;
  end;

  //remove the journal from the list so that it is not included in the closing
  //balances
  if Assigned( YE_Journal_Account) and Assigned( Existing_YE_Adjustment) then begin
    YE_Journal_Account.baTransaction_List.Delete( Existing_YE_Adjustment);
  end;

  //calculate closing balances
  //all of the client parameters will have been loaded already so we should just
  //be able to call the calculate routine
  CalculateAccountTotals.CalculateAccountTotalsForClient( ThisClient);

  //now load actual values into the array
  AccountInfo := TAccountInformation.Create( ThisClient);
  try
    AccountInfo.UseBudgetIfNoActualData     := False;

    for i := Low(AdjustmentInfoArray) to High(AdjustmentInfoArray) do begin
      AccountInfo.AccountCode := AdjustmentInfoArray[i].Account.chAccount_Code;
      AccountInfo.LastPeriodOfActualDataToUse := AccountInfo.HighestPeriod;

      AdjustmentInfoArray[i].CurrentBal := AccountInfo.ClosingBalanceActualOrBudget(AccountInfo.HighestPeriod);
    end;
  finally
    AccountInfo.Free;
  end;

  //calculate adjusted amounts
  for i := Low(AdjustmentInfoArray) to High(AdjustmentInfoArray) do begin
    AdjustmentInfoArray[i].AdjustedBal := AdjustmentInfoArray[i].CurrentBal + AdjustmentInfoArray[i].Difference;
  end;

  //correct sign on balancess
  for i := Low(AdjustmentInfoArray) to High(AdjustmentInfoArray) do begin
    pAcct := AdjustmentInfoArray[i].Account;

    //current balance
    if SignOf( AdjustmentInfoArray[i].CurrentBal ) = ExpectedSign( pAcct.chAccount_Type) then
      AdjustmentInfoArray[i].CurrentBal      := Abs( AdjustmentInfoArray[i].CurrentBal)
    else
      AdjustmentInfoArray[i].CurrentBal      := -1 * Abs( AdjustmentInfoArray[i].CurrentBal);

    //adjusted balance
    if SignOf( AdjustmentInfoArray[i].AdjustedBal ) = ExpectedSign( pAcct.chAccount_Type) then
      AdjustmentInfoArray[i].AdjustedBal     := Abs( AdjustmentInfoArray[i].AdjustedBal)
    else
      AdjustmentInfoArray[i].AdjustedBal     := -1 * Abs( AdjustmentInfoArray[i].AdjustedBal);

    //no need to change the sign of the difference as this will not have dr/cr
    //show the actual amount

//    if SignOf( AdjustmentInfoArray[i].Difference ) = ExpectedSign( pAcct.chAccount_Type) then
//      AdjustmentInfoArray[i].Difference      := Abs( AdjustmentInfoArray[i].Difference)
//    else
//      AdjustmentInfoArray[i].Difference      := -1 * Abs( AdjustmentInfoArray[i].Difference);
  end;
end;

procedure TwizBalancesForward.SaveAdjustmentsToTempJournal;
//saves the adjustments into the temp journal pointer
var
  TempAmount         : Money;
  pJournalLine      : pDissection_Rec;
  pAccount           : pAccount_Rec;
  i                  : integer;
begin
  //find the year end adjustment account
  YE_Journal_Account := nil;
  With ThisClient.clBank_Account_List do For i := 0 to Pred( itemCount ) do
     With Bank_Account_At( i ) do
        If baFields.baAccount_Type = btYearEndAdjustments then {found it}
           YE_Journal_Account := Bank_Account_At( i );

  if YE_Journal_Account = nil then begin
     //there is no journal account currently, so create one
     YE_Journal_Account := TBank_Account.Create(ThisClient);
     With YE_Journal_Account.baFields do Begin
        baBank_Account_Number   := btNames[ btYearEndAdjustments ];
        baBank_Account_Name     := btNames[ btYearEndAdjustments ];
        baCurrent_Balance       := 0;
        baAccount_Type          := btYearEndAdjustments;
        baDesktop_Super_Ledger_ID := -1;
        baCurrency_Code         := ThisClient.clExtra.ceLocal_Currency_Code;
     end;
     ThisClient.clBank_Account_List.Insert(YE_Journal_Account);
  end;

  //find the opening balance journal for this date
  TempYEAdjustment := jnlUtils32.GetJournalFor( YE_Journal_Account, ThisClient.clFields.clFinancial_Year_Starts - 1);
  //If no transaction exists on this date the create a new one to be dissected
  If TempYEAdjustment = nil then
    TempYEAdjustment := NewJournalFor( ThisClient, YE_Journal_Account, ThisClient.clFields.clFinancial_Year_Starts - 1);

  //Clear current dissection lines
  TrxList32.Dump_Dissections( TempYEAdjustment );

  //change temp amounts so that the sign is correct
  //+ve amounts should take the expected sign, -ve amounts take reversed sign
  for i := Low(AdjustmentInfoArray) to High(AdjustmentInfoArray) do begin
     pAccount   := AdjustmentInfoArray[i].Account;

     TempAmount := AdjustmentInfoArray[i].Difference;

//     if TempAmount < 0 then begin
//       TempAmount := SetSign( TempAmount, ReverseSign( ExpectedSign( pAccount.chAccount_Type)));
//     end
//     else if AdjustmentInfoArray[i].AdjustedBal > 0 then begin
//       TempAmount := SetSign( TempAmount, ExpectedSign( pAccount.chAccount_Type));
//     end;

     if TempAmount <> 0 then begin
        //need to write a dissection line for this account
        pJournalLine        :=  New_Dissection_Rec;
        with pJournalLine^ do begin
          dsTransaction         := TempYEAdjustment;
          dsAccount             := pAccount.chAccount_Code;
          dsAmount              := TempAmount;
          dsPayee_Number        := 0;
          dsGST_Class           := pAccount.chGST_Class;
          //The GST for opening balance and year end journals MUST be zero, set this and
          //set edit flag if not already zero
          dsGST_Amount          := GSTCalc32.CalculateGSTForClass( ThisClient,
                                                                   TempYEAdjustment.txDate_Effective,
//                                                                   dsAmount,
                                                                   Local_Amount,
                                                                   pAccount.chGST_Class);
          if ( dsGST_Amount <> 0) then begin
            dsGST_Amount := 0;
            dsGST_Has_Been_Edited := True;
          end;
          dsQuantity            := 0;
          dsGL_Narration        := '';
          dsHas_Been_Edited     := true;
          dsJournal_Type        := jtNormal;
          dsSF_Member_Account_ID:= -1;
          dsSF_Fund_ID          := -1;
          TrxList32.AppendDissection( TempYEAdjustment, pJournalLine, ThisClient.ClientAuditMgr );
        end;
     end;
  end;

  if TempYEAdjustment^.txFirst_Dissection <> nil then begin
    TempYEAdjustment^.txCoded_By := cbManual;
    TempYEAdjustment^.txAccount  := 'DISSECT';
    TempYEAdjustment^.txAmount   := 0;
  end
  else begin
    //there are no lines in the journal so delete it
    YE_Journal_Account.baTransaction_List.DelFreeItem( TempYEAdjustment);
    TempYEAdjustment := nil;
  end;
end;

procedure TwizBalancesForward.CalculateCurrentYearsEarnings;
//calculate the current years earnings an stores it in var CurrentYearsEarnings
//the value is "sign corrected" so if the sign of the amount is the same
//as the expected sign for the account it will appear as a +ve number
var
  pAcct : pAccount_Rec;
  i     : integer;
  AccountInfo : TAccountInformation;
begin
  //need to reset all of the financial parameters as these may have changed
  //when the reports were being printed
  BalancesForward.SetupParameters( ThisClient);
  //recalculate account totals, calling add contras will add the contra code
  //for retained p&l.  No other contras should be added as one of the preconditions
  //for doing the balance forward is that all contras are specified by the user
  CalculateAccountTotals.AddAutoContraCodes( ThisClient);
  try
    CalculateAccountTotals.CalculateAccountTotalsForClient( ThisClient);
    //calculate retained p & l
    CalculateAccountTotals.CalculateCurrentEarnings( ThisClient);

    //find the retained p & l account
    CurrentYearsEarnings := 0;
    for i := 0 to Pred( ThisClient.clChart.ItemCount) do begin
      pAcct := ThisClient.clChart.Account_At(i);
      if pAcct.chAccount_Type = atCurrentYearsEarnings then begin
        //update the private variable for the form
        AccountInfo := TAccountInformation.Create( ThisClient);
        try
          AccountInfo.UseBudgetIfNoActualData     := False;
          AccountInfo.AccountCode                 := pAcct.chAccount_Code;
          AccountInfo.LastPeriodOfActualDataToUse := AccountInfo.HighestPeriod;

          CurrentYearsEarnings := CurrentYearsEarnings + AccountInfo.YTD_ActualOrBudget( AccountInfo.HighestPeriod);
        finally
          AccountInfo.Free;
        end;
      end;
    end;
  finally
    CalculateAccountTotals.RemoveAutoContraCodes( ThisClient);
  end;
  
  CurrentYearsEarnings := CurrentYearsEarnings;
end;

procedure TwizBalancesForward.MoveToStep(StepID: integer);
//called from the Back and Next Buttons
var
  Cancel : boolean;
  NewStepID : integer;
begin
  Assert( StepID in [ stMin..stMax], 'Step No out of range');
  NewStepID := StepID;

  //save settings on current page before moving
  Cancel := false;
  DoBeforeMoveToStep( CurrentStepID, NewStepID, Cancel);
  if Cancel then
    Exit;

  case NewStepID of
    stWelcomePage : begin
      pnlWizard.Visible  := False;
      pnlWelcome.Visible := True;
    end;
  else
    begin
      //default processings
      PageControl1.ActivePage := FindPage( NewStepID);
      //check to see which page is currently showing
      if (PageControl1.ActivePage = tbsAdjustments) or
        (PageControl1.ActivePage = tbsCurrentEarnings) then
        //this stops the focus jumping from the grid if the enter key is held down
        btnNext.Default := False
      else
        btnNext.Default := True;
    end;
  end;

  DoAfterMoveToStep;
end;

function TwizBalancesForward.NextStep(StepID: integer): integer;
var
  CurrPosInArray : integer;
  Found          : boolean;
begin
  Assert( StepID in [ stMin..stMax], 'NextStep.Old Step out of range');

  CurrPosInArray := GetOrderArrayPos( StepID);

  //cycle thru list trying to find next valid step
  Found := false;
  while (CurrPosInArray in [stMin..stMax]) and ( not Found) do begin
    Inc( CurrPosInArray);
    if CurrPosInArray in [stMin..stMax] then
      Found := StepAvailable( TabOrderArray[ CurrPosInArray]);
  end;

  //return step if found, otherwise don't move
  if Found then
    result := TabOrderArray[ CurrPosInArray]
  else
    result := StepID;
end;

function TwizBalancesForward.PrevStep(StepID: integer): integer;
var
  sNo : integer;
  CurrPosInArray : integer;
  Found : boolean;
begin
  Assert( StepID in [ stMin..stMax], 'PrevStep.Old Step out of range');

  CurrPosInArray := -1;
  for sNo := stMin to stMax do
    if TabOrderArray[ sNo] = StepID then
      CurrPosInArray := sNo;

  Assert( CurrPosInArray > -1, 'Current Step not found in list');

  //cycle thru list trying to find next valid step
  Found := false;
  while (CurrPosInArray in [stMin..stMax]) and ( not Found) do begin
    Dec( CurrPosInArray);
    if CurrPosInArray in [stMin..stMax] then
      Found := StepAvailable( TabOrderArray[ CurrPosInArray]);
  end;

  //return step if found, otherwise don't move
  if Found then
    result := TabOrderArray[ CurrPosInArray]
  else
    result := StepID;
end;

procedure TwizBalancesForward.DoBeforeMoveToStep( OldStepID : integer; var NewStepID : integer; var Cancel : boolean);
//gives us an opportunity to save information on the current tab
var
  MovingForward : boolean;
begin
  Assert( OldStepID in [ stMin..stMax], 'DoBeforeMoveToStep.OldStepID out of range');
  Assert( NewStepID in [ stMin..stMax], 'DoBeforeMoveToStep.NewStepID out of range');

  MovingForward := GetOrderArrayPos( NewStepID) > GetOrderArrayPos( OldStepId);

  //save existing
  CompleteStep( OldStepId);

  //now prepare for moving to new step,
  //allows us to initialise
  if MovingForward then
    InitialiseStep( NewStepId);
end;

procedure TwizBalancesForward.DoAfterMoveToStep;
var
  IsLastStep : boolean;
begin
  Assert( CurrentStepID in [ stMin..stMax], 'DoAfterMoveToStep.CurrentStepID out of range');

  //update current step no
  if pnlWelcome.Visible  then
    CurrentStepID := stWelcomePage
  else
    CurrentStepID := PageControl1.ActivePage.Tag;

  //update titles
  lblTitle.Caption       := StepTitles[ CurrentStepID];
  lblDescription.Caption := StepDescriptions[ CurrentStepID];

  //set up buttons
  IsLastStep := ( CurrentStepID =  TabOrderArray[ High(TabOrderArray)]);

  UpdateButtons;

  if IsLastStep then begin
    btnNext.Caption := '&Finished';
    btnNext.ModalResult := mrOK;
    btnNext.Enabled     := true;
  end
  else begin
    btnNext.Caption := '&Next >';
    btnNext.ModalResult := mrNone;
  end;

  //now do after move events for specific steps
  case CurrentStepID of
    stYearEndAdjustments : begin
      DisplayAdjustments;
      UpdateBalanceRemaining;
    end;
  end;
end;

function TwizBalancesForward.HasNextStep(StepID: integer): boolean;
begin
  result := NextStep( StepID) <> StepID;
end;

function TwizBalancesForward.HasPreviousStep(StepID: integer): boolean;
begin
  result := PrevStep( StepID) <> StepID;
end;

procedure TwizBalancesForward.btnBackClick(Sender: TObject);
begin
  if HasPreviousStep( CurrentStepID) then
    MoveToStep( PrevStep( CurrentStepID));
end;

function TwizBalancesForward.FindPage(StepID: integer): TTabSheet;
var
  i : integer;
begin
  result := PageControl1.ActivePage;

  for i := 0 to PageControl1.PageCount - 1 do
    if PageControl1.Pages[i].Tag = StepID then
      result := PageControl1.Pages[i];
end;

procedure TwizBalancesForward.FormDestroy(Sender: TObject);
begin
  SetLength( AdjustmentInfoArray, 0);
  SetLength( EarningsArray, 0);
end;

procedure TwizBalancesForward.DisplayAdjustments;
begin
  tgBalances.BeginUpdate;
  try
    tgBalances.Rows := High( AdjustmentInfoArray) + 1;
  finally
    tgBalances.EndUpdate;
  end;
  tgBalances.Refresh;

  lblAdjDate.Caption := 'Balances as at ' + bkDate2Str( ThisClient.clFields.clFinancial_Year_Starts - 1);
end;

procedure TwizBalancesForward.SetupAdjustmentsGrid;
begin
  tgBalances.Col[ colBalance].ReadOnly          := True;
end;

procedure TwizBalancesForward.tgBalancesInvalidMaskValue(Sender: TObject;
  DataCol, DataRow: Integer; var Accept: Boolean);
begin
   if DataCol = ColAdjBalance then begin
      //need to allow the user to exit the cell when value is blank
      if tgBalances.CurrentCell.Value = '' then begin
         tgBalances.CurrentCell.Value := '0.00';
         Accept := true;
      end;
   end;
end;

procedure TwizBalancesForward.tgBalancesCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
var
   pAccount : pAccount_Rec;
begin
   pAccount := AdjustmentInfoArray[ DataRow - 1].Account;

   Value := '';
   case DataCol of
      ColAccount      : Value := pAccount.chAccount_Code;
      ColDesc         : Value := pAccount.chAccount_Description;
      ColBalance      :
        if pAccount.chPosting_Allowed then begin
          Value := MakeAmountNoComma( AdjustmentInfoArray[ DataRow -1].CurrentBal);
        end;
      ColAdjBalance   : begin
        if pAccount.chPosting_Allowed then begin
          //if this is the currently edited cell then display without brackets
          if ( DataCol = tgBalances.CurrentDataCol) and ( DataRow = tgBalances.CurrentDataRow) then
            Value := FormatFloat( '0.00', AdjustmentInfoArray[ DataRow -1].AdjustedBal/100)
          else
            Value := MakeAmountNoComma( AdjustmentInfoArray[ DataRow -1].AdjustedBal);

          //highlight value if changed
          if (AdjustmentInfoArray[ DataRow -1].AdjustedBal = AdjustmentInfoArray[ DataRow -1].CurrentBal) then begin
            tgBalances.CellParentFont[ DataCol, DataRow] := true;
            tgBalances.CellColor[ DataCol, DataRow]      := clNone;
          end
          else begin
            tgBalances.CellParentFont[ DataCol, DataRow] := false;
            tgBalances.CellFont[ DataCol, DataRow].color := clBlue;
          end;
        end;
      end;

      ColMovement     :
        if pAccount.chPosting_Allowed then begin
          if AdjustmentInfoArray[ DataRow -1].Difference <> 0 then
            Value := MakeAmountNoComma( AdjustmentInfoArray[ DataRow -1].Difference);
        end;

      ColSign, ColAdjSign  :
      begin
        case ExpectedSign( pAccount.chAccount_Type) of
                           Debit : Value   := 'Dr';
                           Credit : Value  := 'Cr';
        else
          Value := '';
        end;
      end;

      ColReportGroup  : Value := Localise(ThisClient.clFields.clCountry,
                                          bkconst.atNames[ pAccount.chAccount_Type]);
   end;
end;

procedure TwizBalancesForward.UpdateBalanceRemaining;
var
   Rem : Money;
begin
   Rem := -GetAmountRemaining;
   if Rem > 0 then begin
      lblAmountRemText.Font.Color := clRed;
      lblAmountRemText.Caption    := 'Amount remaining to be assigned: ';
      lblAmountRemaining.caption  := CurrencySymbol + MakeAmount( Abs(Rem)) + ' Dr';
   end
   else if Rem < 0 then begin
      lblAmountRemText.Font.Color := clRed;
      lblAmountRemText.Caption    := 'Amount remaining to be assigned: ';
      lblAmountRemaining.caption  := CurrencySymbol + MakeAmount( Abs(Rem)) + ' Cr';
   end
   else begin
      lblAmountRemText.Font.Color := clGreen;
      lblAmountRemText.Caption    := 'The account totals are balanced.';
      lblAmountRemaining.caption  := '';
   end;

   UpdateButtons;
end;

function TwizBalancesForward.GetAmountRemaining: Money;
var
   Total    : Money;
   Dr_Total : Money;
   Cr_Total : Money;
   Value    : Money;
   i        : integer;
begin
   //Add up the totals to see how much is remaining
   //Need to change to sign of the amount depending of whether or not the
   //report group is a dr or cr account
   Total    := 0;
   Dr_Total := 0;
   Cr_Total := 0;

   with ThisClient.clChart do begin
      for i := Low( AdjustmentInfoArray) to High( AdjustmentInfoArray) do begin
         Value := AdjustmentInfoArray[i].AdjustedBal;

         if ExpectedSign( AdjustmentInfoArray[i].Account.chAccount_Type) = Debit then
            Dr_Total := Dr_Total + Value
         else
            Cr_Total := Cr_Total + Value;

         if ExpectedSign( AdjustmentInfoArray[i].Account.chAccount_Type) = Credit then
            Value := - Value;

         Total := Total + Value;
      end;
   end;
   result := Total;
end;

procedure TwizBalancesForward.tgBalancesStartCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
var
  pAccount : pAccount_Rec;
begin
  pAccount := AdjustmentInfoArray[ DataRow - 1].Account;
  if not ( pAccount.chPosting_Allowed) then begin
    Cancel := true;
  end;
end;

procedure TwizBalancesForward.tgBalancesKeyPress(Sender: TObject;
  var Key: Char);
var
  DataCol     : integer;
  DataRow     : integer;
  Rem         : money;
  pAccount    : pAccount_Rec;
  Value       : money;

  sValue      : string;
  dValue      : Double;
begin
  DataCol := tgBalances.CurrentDataCol;
  DataRow := tgBalances.CurrentDataRow;

  if DataCol = ColAdjBalance then begin
    //complete the amount
    if Key = '=' then begin
      Key := #0;
      //get pointer to current account
      pAccount := AdjustmentInfoArray[ DataRow - 1].Account;

      //calculate amount remaining, need to remove current item
      Rem := -1 * GetAmountRemaining;
      Value := AdjustmentInfoArray[DataRow - 1].AdjustedBal;
      if ExpectedSign( pAccount.chAccount_Type) = Credit then
         Value := - Value;
      Rem := Rem + Value;

      //now calculate sign needed
      if SignOf( Rem) = ExpectedSign( pAccount^.chAccount_Type) then
         Rem := Abs(Rem)
      else
         Rem := -1 * Abs(Rem);

      //apply
      tgBalances.CurrentCell.Value := FormatFloat( '0.00', Money2Double( Rem));
      tgBalances.EndEdit( false);
      tgBalances.CurrentDataRow := tgBalances.CurrentDataRow + 1;
    end;

    if Key = '+' then begin
      //copy the original amount across
      Key := #0;
      Value := AdjustmentInfoArray[ DataRow - 1].CurrentBal;
      //apply
      tgBalances.CurrentCell.Value := FormatFloat( '0.00', Money2Double( Value));
      tgBalances.EndEdit( false);
      tgBalances.CurrentDataRow := tgBalances.CurrentDataRow + 1;
    end;

    if Key = '-' then
    begin
      sValue := tgBalances.CurrentCell.Value;

      //process the user pressing '-' key
      //if whole cell is selcted then clear and allow minus
      if tgBalances.CurrentCell.SelLength = Length( sValue) then
        tgBalances.CurrentCell.Value := ''
      else
      begin
        //cell is only partially selected
        if (sValue = '') then
          dValue := 0.00
        else
        begin
          if (sValue[1] = '(') and (sValue[length(sValue)] = ')') then
          begin
            //remove brackets and replace with minus so that fits mask
            sValue :='-' + Copy(sValue,2,Length(sValue)-2);
          end;
          dValue := StrToFloatDef(sValue ,0.0);
        end;

        if (dValue <> 0.00) then
        begin
          dValue := -1 * dValue;
          tgBalances.CurrentCell.Value := FormatFloat( '0.00', dValue);
        end;
      end;
    end;
  end;
end;

procedure TwizBalancesForward.tgBalancesEndCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
var
   sValue : string;
   dValue : Double;

   mCurrentAmount : Money;
   mNewAmount     : Money;  
   mDifference    : Money;

   DefaultSign    : TSign;
begin
   case DataCol of
      ColAdjBalance : begin
         sValue := tgBalances.CurrentCell.Value;
         if sValue = '' then
            sValue := '0.00';
         dValue := StrToFloatDef( sValue , 0.0);
         AdjustmentInfoArray[DataRow - 1].AdjustedBal := Double2Money( dValue);

         //now figure out the difference, need to change both current and actual
         //back to real figures
         mCurrentAmount := AdjustmentInfoArray[ DataRow - 1].CurrentBal;
         mNewAmount     := AdjustmentInfoArray[ DataRow - 1].AdjustedBal;
         mDifference    := mNewAmount - mCurrentAmount;

         //get the default sign for the account
         DefaultSign := ExpectedSign( AdjustmentInfoArray[ DataRow - 1].Account.chAccount_Type);

         //now remove dr.cr and get the real sign
         if mDifference < 0 then
           begin
             //set acutal amount to opposite sign
             mDifference := SetSign( mDifference, ReverseSign( DefaultSign));
           end
         else
           begin
             //set amount to expected sign for account
             mDifference := SetSign( mDifference, DefaultSign);
           end;

         AdjustmentInfoArray[ DataRow - 1].Difference := mDifference;
      end;
   else
      Cancel := true;
   end;

   tgBalances.RowInvalidate( tgBalances.DisplayRownr[ DataRow]);
   UpdateBalanceRemaining;
end;

procedure TwizBalancesForward.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if (ModalResult <> mrOK) and (CurrentStepID <> stWelcomePage) then begin
    if AskYesNo( 'Exit ' + Self.Caption,
                 'Are you sure that you want to exit the Year End Balances wizard? '#13 +
                 'Any information you have entered will be lost.',
                 Dlg_No, 0) = DLG_No then
      CanClose := false;
  end;
end;

procedure TwizBalancesForward.tgBalancesKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Shift = [ssCtrl]) and ( Key = 77) then begin //Ctrl + M
    if Self.WindowState = wsMaximized then
      Self.WindowState := wsNormal
    else
      Self.WindowState := wsMaximized;
  end;
end;

procedure TwizBalancesForward.SetupEarningsGrid;
var
  i : integer;
begin
  tgEarnings.Col[ colEarningsDesc].ReadOnly          := True;
  tgEarnings.BeginUpdate;
  try
    tgEarnings.Rows  := MaxEarningsLines;

    SetLength( EarningsArray, MaxEarningsLines);

    for i := Low( EarningsArray) to High( EarningsArray) do begin
      EarningsArray[i].Account := '';
      EarningsArray[i].Amount  := 0;
    end;
  finally
    tgEarnings.EndUpdate;
  end;

  tgEarnings.Col[ colEarningsAccount].MaxLength      := BKConst.MaxBK5CodeLen;
end;

procedure TwizBalancesForward.tgEarningsCellLoaded(Sender: TObject;
  DataCol, DataRow: Integer; var Value: Variant);
var
  pAccount : pAccount_Rec;
  Code     : string;
begin
  Code     := Trim( EarningsArray[DataRow - 1].Account);
  pAccount := ThisClient.clChart.FindCode( Code);
  Value    := '';

  case DataCol of
    ColEarningsAccount : Value := Code;

    ColEarningsDesc    : begin
      if Assigned( pAccount) then
        Value := pAccount.chAccount_Description;
    end;

    ColEarningsAmount : begin
      if Assigned( pAccount) then
      begin
        if ( DataCol = tgEarnings.CurrentDataCol) and ( DataRow = tgEarnings.CurrentDataRow) then
           Value := FormatFloat( '0.00', EarningsArray[ DataRow - 1].Amount/100)
         else
           Value := MakeAmountNoComma( EarningsArray[ DataRow - 1].Amount);
      end;
    end;

    ColEarningsSign : begin
      if Assigned( pAccount) then begin
        case ExpectedSign( pAccount.chAccount_Type) of
          Debit : Value := 'Dr';
          Credit : Value  := 'Cr';
        end;
      end;
    end;
  end;
end;

procedure TwizBalancesForward.tgEarningsEndCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
var
  sValue : string;
  dValue : Double;
  Code   : string;
  pAcct  : pAccount_Rec;
  AutoAmount : Money;
begin
  case DataCol of
    ColEarningsAccount : begin
      //Must assign a valid account code
      Code  := Trim(tgEarnings.CurrentCell.Value);
      pAcct := ThisClient.clChart.FindCode( Code);
      if (Assigned( pAcct) and (pAcct.chAccount_Type in BKConst.BalanceSheetReportGroupsSet))
        or ( Code = '') then
      begin
        EarningsArray[ DataRow -1].Account := Code;

        //auto fill amount if blank
        if Assigned( pAcct) then begin
          if EarningsArray[ DataRow -1].Amount = 0 then begin
            AutoAmount := GetCYAmountRemaining;
            if SignOf( AutoAmount) <> ExpectedSign( pAcct.chAccount_Type) then
              AutoAmount := -Abs( AutoAmount)
            else
              AutoAmount := Abs( AutoAmount);

            EarningsArray[ DataRow -1].Amount := AutoAmount;
          end;
        end
        else
          EarningsArray[ DataRow -1].Amount := 0;
      end
      else begin
        Cancel := true;
        WinUtils.ErrorSound;
      end;
    end;

    ColEarningsAmount : begin
      sValue := tgEarnings.CurrentCell.Value;
      if sValue = '' then
        sValue := '0.00';
      dValue := StrToFloatDef( sValue , 0.0);
      EarningsArray[DataRow - 1].Amount := Double2Money( dValue);
    end;
  else
    Cancel := true;
  end;

  tgEarnings.RowInvalidate( tgEarnings.DisplayRownr[ DataRow]);
  UpdateCYAmountRemaining;
end;

function TwizBalancesForward.GetCYAmountRemaining: Money;
var
   Total    : Money;
   Value    : Money;
   i        : integer;
   pAccount : pAccount_Rec;
begin
   //Add up the totals to see how much is remaining
   //Need to change to sign of the amount depending of whether or not the
   //report group is a dr or cr account
   Total    := CurrentYearsEarnings;

   with ThisClient.clChart do begin
      for i := Low( EarningsArray) to High( EarningsArray) do begin
         pAccount := FindCode( EarningsArray[i].Account);
         if Assigned( pAccount) then begin
           Value := EarningsArray[i].Amount;

           if ExpectedSign(pAccount.chAccount_Type) = Credit then
              Value := - Value;
         end
         else
           Value := 0;

         Total := Total - Value;
      end;
   end;
   result := Total;
end;

procedure TwizBalancesForward.UpdateCYAmountRemaining;
var
   Rem : Money;
begin
   Rem := GetCYAmountRemaining;
   if Rem > 0 then begin
      lblEarningsRemText.Font.Color := clRed;
      lblEarningsRemText.Caption    := 'Amount remaining to be assigned: ';
      lblEarningsRemaining.caption  := CurrencySymbol + MakeAmount( Abs(Rem)) + ' Dr';
   end
   else if Rem < 0 then begin
      lblEarningsRemText.Font.Color := clRed;
      lblEarningsRemText.Caption    := 'Amount remaining to be assigned: ';
      lblEarningsRemaining.caption  := CurrencySymbol + MakeAmount( Abs(Rem)) + ' Cr';
   end
   else begin
      lblEarningsRemText.Font.Color := clGreen;
      lblEarningsRemText.Caption    := 'The account totals are balanced.';
      lblEarningsRemaining.caption  := '';
   end;

   UpdateButtons;
end;


procedure TwizBalancesForward.tgEarningsStartCellEdit(Sender: TObject;
  DataCol, DataRow: Integer; var Cancel: Boolean);
var
  pAccount : pAccount_Rec;
  Code     : string;
begin
  Code     := EarningsArray[DataRow - 1].Account;
  pAccount := ThisClient.clChart.FindCode( Code);

  //only allow the account col to be edited
  if DataCol <> ColEarningsAccount then
    Cancel   := not Assigned( pAccount);
end;

procedure TwizBalancesForward.tgEarningsInvalidMaskValue(Sender: TObject;
  DataCol, DataRow: Integer; var Accept: Boolean);
begin
   if DataCol = ColEarningsAmount then begin
      //need to allow the user to exit the cell when value is blank
      if tgEarnings.CurrentCell.Value = '' then begin
         tgEarnings.CurrentCell.Value := '0.00';
         Accept := true;
      end;
   end;
end;

procedure TwizBalancesForward.tgEarningsKeyPress(Sender: TObject;
  var Key: Char);
var
  DataCol     : integer;
  DataRow     : integer;
  Rem         : money;
  pAccount    : pAccount_Rec;
  Value       : money;

  Percentage  : double;
  sPercent    : string;

  sValue      : string;
  dValue      : Double;
begin
  DataCol := tgEarnings.CurrentDataCol;
  DataRow := tgEarnings.CurrentDataRow;

  //get pointer to current account
  pAccount := ThisClient.clChart.FindCode( EarningsArray[ DataRow - 1].Account);
  if not Assigned( pAccount) then
    Exit;

  if DataCol = ColEarningsAmount then begin
    //complete the amount
    if Key = '=' then begin
      Key := #0;

      //calculate amount remaining, need to remove current item
      Rem := GetCYAmountRemaining;
      Value := EarningsArray[DataRow - 1].Amount;
      if ExpectedSign( pAccount.chAccount_Type) = Credit then
         Value := - Value;
      Rem := Rem + Value;

      //now calculate sign needed
      Rem := DrCr2Real( Rem, ExpectedSign( pAccount^.chAccount_Type));

      //apply
      tgEarnings.CurrentCell.Value := FormatFloat( '0.00', Money2Double( Rem));
      tgEarnings.EndEdit( false);
      tgEarnings.CurrentDataRow := tgEarnings.CurrentDataRow + 1;
    end;

    if Key = '+' then begin
      //copy the original amount across
      Key := #0;

    end;

    if Key in ['%','/'] then begin
      Key := #0;

      sPercent := tgEarnings.CurrentCell.Value;
      //percentage of total
      Percentage := StrToFloatDef( sPercent, 0);
      //check that the percentage value make sense
      if ( Percentage <= 0.0 ) or ( Percentage > 100.0) then exit;

      Value := CurrentYearsEarnings * (Percentage / 100.0);
      Value := DrCr2Real( Value, ExpectedSign( pAccount^.chAccount_Type));

      //store amount, then recalc amount remaining
      EarningsArray[ DataRow -1].Amount := Value;
      Rem := GetCYAmountRemaining;
      if Abs(Rem) < 5 then begin
        Value := Value - DrCr2Real( Rem, ExpectedSign( pAccount^.chAccount_Type));
      end;

      //apply
      tgEarnings.CurrentCell.Value := FormatFloat( '0.00', Money2Double( Value));
      tgEarnings.EndEdit( false);
      tgEarnings.CurrentDataRow := tgEarnings.CurrentDataRow + 1;
      tgEarnings.CurrentDataCol := ColEarningsAccount;
    end;

    if Key = '-' then
    begin
      sValue := tgEarnings.CurrentCell.Value;

      //process the user pressing '-' key
      //if whole cell is selcted then clear and allow minus
      if tgEarnings.CurrentCell.SelLength = Length( sValue) then
        tgEarnings.CurrentCell.Value := ''
      else
      begin
        //cell is only partially selected
        if (sValue = '') then
          dValue := 0.00
        else
        begin
          if (sValue[1] = '(') and (sValue[length(sValue)] = ')') then
          begin
            //remove brackets and replace with minus so that fits mask
            sValue :='-' + Copy(sValue,2,Length(sValue)-2);
          end;
          dValue := StrToFloatDef(sValue ,0.0);
        end;

        if (dValue <> 0.00) then
        begin
          dValue := -1 * dValue;
          tgEarnings.CurrentCell.Value := FormatFloat( '0.00', dValue);
        end;
      end;
    end;
  end;
end;

procedure TwizBalancesForward.tgEarningsCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; ByUser: Boolean);
//event is called when value of current cell changes
//a hidden edit box is used here so that the existing mask code can be used
var
  Code : ShortString;
begin
  if (not ByUser) or ( DataCol <> colEarningsAccount) then
    Exit;

  Code := tgEarnings.CurrentCell.Value;
  if ThisClient.clChart.CanPressEnterNow( Code) then begin
    //move right
    tgEarnings.CurrentCell.Value := Code;
    tgEarnings.EndEdit( false);
    tgEarnings.CurrentDataCol := colEarningsAmount;
  end
  else begin
    //check to see if a mask character should be added to the code
    edtHiddenEdit.Text := Code;
    bkMaskUtils.CheckForMaskChar(edtHiddenEdit,RemovingMask);
    if edtHiddenEdit.Text <> Code then begin
      tgEarnings.CurrentCell.Value := edtHiddenEdit.Text;
      tgEarnings.CurrentCell.SelStart := Length(edtHiddenEdit.Text);
    end;
  end;
end;

procedure TwizBalancesForward.tgEarningsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if tgEarnings.CurrentDataCol = ColEarningsAccount then begin
    //check for lookup key
    if ( Key = VK_F2) then begin
      DoAccountLookup;
    end;
  end;
end;

procedure TwizBalancesForward.DoAccountLookup;
var
  Code : string;
begin
  if tgEarnings.CurrentDataCol <> ColEarningsAccount then
    tgEarnings.CurrentDataCol := ColEarningsAccount;

  Code := tgEarnings.CurrentCell.Value;
  if PickAccount(Code, EarningsFilter) then begin
    tgEarnings.CurrentCell.Value := Code;
    tgEarnings.EndEdit( false);
    tgEarnings.CurrentDataCol := colEarningsAmount;
  end;
end;

procedure TwizBalancesForward.btnChartClick(Sender: TObject);
begin
  DoAccountLookup;
end;

procedure TwizBalancesForward.SaveOpeningBalances;
var
  OpeningBalancesAccount : TBank_Account;
  OpeningBalanceRec      : pTransaction_Rec;
  pJournalLine           : pDissection_Rec;
  pAcct                  : pAccount_Rec;
  i                      : integer;
  AccountInfo            : TAccountInformation;
  Total                  : Money;
  Amount                 : Money;
begin
  //clear any existing opening balance
  //find the open balance journal account
  OpeningBalancesAccount := nil;
  With ThisClient.clBank_Account_List do For i := 0 to Pred( itemCount ) do
     With Bank_Account_At( i ) do
        If baFields.baAccount_Type = btOpeningBalances then {found it}
           OpeningBalancesAccount := Bank_Account_At( i );

  if OpeningBalancesAccount = nil then begin
     //there is no journal account currently, so create one
     OpeningBalancesAccount := TBank_Account.Create(ThisClient);
     With OpeningBalancesAccount.baFields do Begin
        baBank_Account_Number   := btNames[ btOpeningBalances ];
        baBank_Account_Name     := btNames[ btOpeningBalances ];
        baCurrent_Balance       := 0;
        baAccount_Type          := btOpeningBalances;
        baDesktop_Super_Ledger_ID := -1;        
        baCurrency_Code         := ThisClient.clExtra.ceLocal_Currency_Code;
     end;
     ThisClient.clBank_Account_List.Insert(OpeningBalancesAccount);
  end;

  //find the opening balance journal for this date
  OpeningBalanceRec := jnlUtils32.GetJournalFor( OpeningBalancesAccount, ThisClient.clFields.clFinancial_Year_Starts);
  //If no transaction exists on this date the create a new one to be dissected
  If OpeningBalanceRec = nil then
    OpeningBalanceRec := NewJournalFor( ThisClient, OpeningBalancesAccount, ThisClient.clFields.clFinancial_Year_Starts);

  //Clear current dissection lines
  TrxList32.Dump_Dissections( OpeningBalanceRec );

  //clear temp value in chart
  for i := 0 to Pred( ThisClient.clChart.ItemCount ) do begin
    ThisClient.clChart.Account_At( i).chTemp_Money_Value := 0;
  end;
  Total := 0;
  //load closing balances
  //need to reset all of the financial parameters as these may have changed
  //when the reports were being printed
  BalancesForward.SetupParameters( ThisClient);
  //recalculate account totals
  CalculateAccountTotals.CalculateAccountTotalsForClient( ThisClient);
  for i := 0 to Pred( ThisClient.clChart.ItemCount) do begin
    pAcct := ThisClient.clChart.Account_At(i);
    if pAcct.chAccount_Type in BKConst.BalanceSheetReportGroupsSet then begin
      //update the temp money variable
      AccountInfo := TAccountInformation.Create( ThisClient);
      try
        AccountInfo.UseBudgetIfNoActualData     := False;
        AccountInfo.AccountCode                 := pAcct.chAccount_Code;
        AccountInfo.LastPeriodOfActualDataToUse := AccountInfo.HighestPeriod;
        // Question: why not use .YTD_ActualOrBudget as per calculation in CalculateCurrentYearsEarnings
        pAcct.chTemp_Money_Value := AccountInfo.ClosingBalanceActualOrBudget(AccountInfo.HighestPeriod);
        Total := Total + pAcct.chTemp_Money_Value;
      finally
        AccountInfo.Free;
      end;
    end;
  end;

  //load current years earnings distribution
  for i := 0 to Pred(tgEarnings.Rows) do begin
    if (EarningsArray[i].Account <> '') and ( EarningsArray[i].Amount <> 0) then begin
      pAcct := ThisClient.clChart.FindCode( EarningsArray[i].Account);
      //only valid accounts can be entered
      Assert( pAcct <> nil, 'SaveOpeningBalances.Invalid Account found');

      Amount := DrCr2Real( EarningsArray[i].Amount, ExpectedSign( pAcct.chAccount_Type));
      pAcct.chTemp_Money_Value := pAcct.chTemp_Money_Value + Amount;
      //add to total
      Total := Total + Amount;
    end;
  end;

  //check that total is zero
  Assert( Total = 0, 'SaveOpeningBalances.Balance is not zero ' + MakeAmount( Total));

  // Store dissection lines
  for i := 0 to Pred( ThisClient.clChart.ItemCount ) do begin
    pAcct := ThisClient.clChart.Account_At( i);
    if pAcct.chTemp_Money_Value <> 0 then begin
      //need to write a dissection line for this account
      pJournalLine        :=  New_Dissection_Rec;
      with pJournalLine^ do begin
        dsTransaction         := OpeningBalanceRec;
        dsAccount             := pAcct.chAccount_Code;
        dsAmount              := pAcct.chTemp_Money_Value;
        dsPayee_Number        := 0;
        dsGST_Class           := pAcct.chGST_Class;
        //The GST for opening balance and year end journals MUST be zero, set this and
        //set edit flag if not already zero
        dsGST_Amount          := GSTCalc32.CalculateGSTForClass( ThisClient,
                                                                 OpeningBalanceRec.txDate_Effective,
//                                                                 dsAmount,
                                                                 Local_Amount,
                                                                 pAcct.chGST_Class);
        if ( dsGST_Amount <> 0) then begin
          dsGST_Amount := 0;
          dsGST_Has_Been_Edited := True;
        end;
        dsQuantity            := 0;
        dsGL_Narration        := '';
        dsHas_Been_Edited     := true;
        dsJournal_Type        := jtNormal;
        TrxList32.AppendDissection( OpeningBalanceRec, pJournalLine );
      end;
    end;
  end;

  if OpeningBalanceRec^.txFirst_Dissection <> nil then begin
    OpeningBalanceRec^.txCoded_By := cbManual;
    OpeningBalanceRec^.txAccount  := 'DISSECT';
    OpeningBalanceRec^.txAmount   := 0;
  end
  else begin
    //there are no lines in the journal so delete it
    OpeningBalancesAccount.baTransaction_List.DelFreeItem( OpeningBalanceRec);
    OpeningBalanceRec := nil;
  end;

  RemoveJnlAccountIfEmpty( ThisClient, OpeningBalancesAccount);
end;

function TwizBalancesForward.StepAvailable(StepID : integer) : boolean;
//used by next and prev to determine if this step can be used
begin
  case StepID of
    stAssignRetainedPL :         result := OverwriteBalances and (not ManuallyAddBalances);
    stCreateOpening :            result := not ExistingOBFound;
    stOverwriteOpeningBalances : result := ExistingOBFound;
  else
    result := True;
  end;
end;

procedure TwizBalancesForward.InitialiseStep(StepID: integer);
var
  aCaption : string;
begin
  case StepID of
    stOverwriteOpeningBalances : begin
      lblOpeningBalancesFound.Caption := 'Opening Balances have already been entered on ' +
                                         bkDate2Str(ThisClient.clFields.clFinancial_Year_Starts) +
                                         '.  What do you want to do?';

      lblReplaceNote.Caption := 'Note:  The Closing Balances for the year ending ' +
                             bkDate2Str(ThisClient.clFields.clFinancial_Year_Starts -1 ) +
                             ' may not match the Opening Balances for the year starting ' +
                             bkDate2Str(ThisClient.clFields.clFinancial_Year_Starts)+ '.';

      rbReplaceOpeningBalances.Checked := true;
      rbLeaveOpeningBalances.Checked   := false;
    end;

    stYearEndAdjustments : begin

    end;

    stPrintFinancialReports : begin
      ThisClient.clFields.clFRS_Reporting_Period_Type := frpYearly;
      lblReportYearStart.Caption := 'The Reporting Year Start Date for the following reports is ' +
                                    bkDate2Str( ThisClient.clFields.clReporting_Year_Starts);
    end;

    stCreateOpening : begin
      lblAddOpeningBalances.Caption := 'Do you want to automatically add Opening Balances for the year starting ' +
                                       bkDate2Str(ThisClient.clFields.clFinancial_Year_Starts) +
                                       ' ?';
    end;

    stAssignRetainedPL : begin
      //calculate the retained P&L amount
      CalculateCurrentYearsEarnings;
      lblCurrentYearsEarningsAmt.Caption := ShortAppName + ' has calculated the Current Years Earnings at ' +
                                            CurrencySymbol +
                                            MakeAmountNoComma( -CurrentYearsEarnings);
      UpdateCYAmountRemaining;
    end;

    stFinished : begin
      chkEditOpening.Visible := False;
      chkEditOpening.Checked := False;
      //show finish note
      aCaption := 'Confirmed your closing balances for the year ending ' +
                  bkDate2Str(ThisClient.clFields.clFinancial_Year_Starts -1 ) + '.'#13#13;

      if Assigned( TempYEAdjustment) then
        aCaption := aCaption + 'Created a Year End Adjustments Journal on ' +
                    bkDate2Str(ThisClient.clFields.clFinancial_Year_Starts -1 ) + '.'#13#13;

      if (OverwriteBalances or ( not ExistingOBFound)) and ( not ManuallyAddBalances) then begin
        aCaption := aCaption +
                    'Allocated the current years earning to your selected retained profit ' +
                    'and loss account(s).  ' +
                    'The closing balances of all Balance Sheet accounts have been rolled forward to '+
                    'become the opening balances for the year starting ' +
                    bkDate2Str(ThisClient.clFields.clFinancial_Year_Starts)+ '.  ' +
                    'During this process the opening balances of the Income and ' +
                    'Expense accounts have been set to zero.';

        chkEditOpening.Visible := true;
      end;
      lblFinishNote.Caption := aCaption;
    end;
  end;
end;

function TwizBalancesForward.CompleteStep(StepID: integer): boolean;
begin
  result := true;
  //clean up or save values when leaving old step
  case StepID of
    stWelcomePage : begin
      pnlWelcome.Visible := False;
      pnlWizard.Visible  := True;
    end;

    stOverwriteOpeningBalances : begin
      OverwriteBalances  := rbReplaceOpeningBalances.Checked;
    end;

    stYearEndAdjustments : begin
      SaveAdjustmentsToTempJournal;
      Self.WindowState := wsNormal;
    end;

    stCreateOpening : begin
      ManuallyAddBalances := rbNoOpeningBalances.Checked;
    end;

    stAssignRetainedPL : begin

    end;

    stFinished : begin

    end;
  end;
end;

function TwizBalancesForward.CanMoveToNextStep(StepID: integer): boolean;
begin
  result := true;
  case StepID of
    stYearEndAdjustments : begin
      tgBalances.EndEdit( false);
      if GetAmountRemaining <> 0 then begin
        result := false;
      end;
    end;

    stAssignRetainedPL : begin
      tgEarnings.EndEdit( false);
      if GetCYAmountRemaining <> 0 then begin
        result := false;
      end;
    end;
  end;
end;

procedure TwizBalancesForward.UpdateButtons;
begin
  btnNext.Enabled := CanMoveToNextStep( CurrentStepID) and HasNextStep( CurrentStepID);
  btnBack.Enabled := HasPreviousStep( CurrentStepID);
end;

procedure TwizBalancesForward.tgEarningsKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  Code : string;
begin
  if tgEarnings.CurrentDataCol = ColEarningsAccount then begin
    //check to see if user is trying to remove the mask character
    if ( Key = VK_BACK ) then begin
      Code := tgEarnings.CurrentCell.Value;
      //check to see if a mask character should be added to the code
      edtHiddenEdit.Text := Code;
      if not ThisClient.clChart.CodeIsThere(edtHiddenEdit.Text) then
        bkMaskUtils.CheckRemoveMaskChar(edtHiddenEdit,RemovingMask);
      if edtHiddenEdit.Text <> Code then begin
        tgEarnings.CurrentCell.Value := edtHiddenEdit.Text;
        tgEarnings.CurrentCell.SelStart := Length(edtHiddenEdit.Text);
      end;
    end;
  end;
end;

end.

