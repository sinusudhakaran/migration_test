unit RptTrialBalance;
//------------------------------------------------------------------------------
{
   Title:       Trial Balance Report

   Description:

   Author:      Matthew Hopkins  Jun 2002

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  ReportDefs, clObj32,uBatchBase,RptParams;

  procedure DoTrialBalance( Destination : TReportDest; RptBatch : TReportBase = nil );

  procedure VerifyPreConditions( aClient : TClientObj; var ErrorMsg : string);

//******************************************************************************
implementation

uses
  ReportTypes,
  AccountInfoObj,
  baObj32,
  baUtils,
  bk5Except,
  bkconst,
  bkDateUtils,
  bkdefs,
  CalculateAccountTotals,
  chList32,
  DATEDEF,
  glConst,
  globals,
  MoneyDef,
  NewReportObj,
  NewReportUtils,
  PeriodUtils,
  repcols,
  SignUtils,
  stDateSt,
  sysUtils,
  InfoMoreFrm,
  glObj32,
  ForexHelpers;

type
  TTrialBalanceReport = class( TBKReport)
  private
    RptParameters : TRptParameters;
  end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TrialBalanceDetail(Sender : TObject);

  function FindBankAccountByExchangeGainLossCode(const AccountCode: String): TBank_Account;
  var
    Index: Integer;
  begin
    Result := nil;
    
    for Index := 0 to MyClient.clBank_Account_List.ItemCount - 1 do
    begin
      if MyClient.clBank_Account_List.Bank_Account_At(Index).baFields.baExchange_Gain_Loss_Code = AccountCode then
      begin
        Result := MyClient.clBank_Account_List.Bank_Account_At(Index);

        Exit;
      end;
    end;
  end;
  
var
  i             : integer;
  pAcct         : pAccount_Rec;
  AccountInfo   : TAccountInformation;
  mYTD          : Money;
  s             : string;
begin
  with TTrialBalanceReport(Sender) ,MyClient, MyClient.clFields do begin

    AccountInfo := TAccountInformation.Create( Myclient);
    try
      AccountInfo.UseBudgetIfNoActualData     := False;
      AccountInfo.LastPeriodOfActualDataToUse := clFields.clTemp_FRS_Last_Actual_Period_To_Use;
      AccountInfo.UseBaseAmounts              := IsForeignCurrencyClient;

      for i := 0 to Pred( RptParameters.Chart.ItemCount) do
      begin
        mYTD := 0;

        pAcct := RptParameters.Chart.Account_At( i);

        AccountInfo.AccountCode   := pAcct.chAccount_Code;
        mYTD  := AccountInfo.ClosingBalanceActualOrBudget( clTemp_FRS_Last_Period_To_Show );

        if ( mYTD <> 0) then begin
          if clFRS_Print_Chart_Codes then
            s := pAcct^.chAccount_Code + ' ' + pAcct^.chAccount_Description
          else
            s := pAcct^.chAccount_Description;

          PutString(s);

          if SignOf( mYTD) = Debit then begin
            PutMoney( Abs(mYTD));
            SkipColumn;
            PutMoney( mYTD);
          end
          else begin
            SkipColumn;
            PutMoney( Abs(mYTD));
            PutMoney( mYTD);
          end;
          RenderDetailLine;
        end;
      end;
    finally
      AccountInfo.Free;
    end;

    RenderDetailGrandTotal('Total');
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetGSTString(aClient : TClientObj) : string;
//returns a string as to whether the report is gst inclusive or exclusive,
//depends on if the client uses GST
begin
   if aClient.clFields.clGST_Inclusive_Cashflow then
      result := '(Incl ' + aClient.TaxSystemNameUC + ')'
   else
      result := '';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoTrialBalance( Destination : TReportDest; RptBatch : TReportBase = nil );
var
  Job    : TTrialBalanceReport;
  S      : string;
  Params : TRptParameters;
  CLeft : Double;
  FromDate, ToDate: integer;
  ISOCodes: string;
begin
  //set defaults for calculate account totals

  with MyClient.clFields do begin
    //set persistent client variables
      //clGST_Inclusive_Cashflow set by dialog
      //clReporting_Year_Starts set by dialog
      clFRS_Reporting_Period_Type          := frpMonthly;

    //now save temporary client variables
      clTemp_FRS_Account_Totals_Cash_Only  := false;
      clTemp_FRS_Division_To_Use           := 0;
      clTemp_FRS_Job_To_Use                := '';
      clTemp_FRS_Budget_To_Use             := '';
      clTemp_FRS_Budget_To_Use_Date        := -1;
      clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
      //clTemp_FRS_Last_Period_To_Show  set by dialog
      //clTemp_FRS_Last_Actual_Period_To_Use set by dialog
  end;

  //check assertions for fields that are set by user
  with MyClient.clFields do begin
    //Persistant Fields
    Assert( clReporting_Year_Starts > 0, 'clReporting_Year_Starts > 0');
    //Non-persistant fields
    Assert( clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]], 'clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]]');
    Assert( clTemp_FRS_Last_Actual_Period_To_Use <= clTemp_FRS_Last_Period_To_Show, 'clTemp_FRS_Last_Actual_Period_To_Use <= clTemp_FRS_Last_Period_To_Show');
  end;

  //Check Forex
  FromDate := MyClient.clFields.clTemp_Period_Details_This_Year[1].Period_Start_Date;
  ToDate := MyClient.clFields.clTemp_Period_Details_This_Year[MyClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_End_Date;
  if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, True) then begin
    HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
    Exit;
  end;

  //get totals
  CalculateAccountTotals.AddAutoContraCodes( MyClient);
  try
    FlagAllAccountsForUse(MyClient);
    CalculateAccountTotals.CalculateAccountTotalsForClient(MyClient, True, nil, -1, False, True);
    Params := TRptParameters.Create(ord(Report_TrialBalance),MyClient,RptBatch,dPeriod);

    Params.FromDate := FromDate;
    Params.ToDate := ToDate;

    Job := TTrialBalanceReport.Create(rptOther);
    try
      Job.RptParameters := Params;
      Job.LoadReportSettings( UserPrintSettings,Params.MakeRptName(Report_List_Names[REPORT_TRIALBALANCE]));

      //Add Headers
      AddCommonHeader(Job);

      with MyClient.clFields do begin
        S := StDateToDateString('NNN yyyy', clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date, true)
      end;
      AddJobHeader(Job,siTitle, 'TRIAL BALANCE REPORT ' + GetGSTString(MyClient) + ' as at ' + S, true);
      AddJobHeader(Job,siSubTitle,'',true);

      {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
      cLeft := gCLeft;
      AddColAuto( Job,       cLeft, 30, gcGap,'Account', jtLeft);
      AddFormatColAuto( Job, cLeft, 20, gcGap,'Debit',  jtRight, MyClient.FmtMoneyStrBracketsNoSymbol, MyClient.FmtMoneyStrBrackets, true);
      AddFormatColAuto( Job, cLeft, 20, gcGap,'Credit',  jtRight, MyClient.FmtMoneyStrBracketsNoSymbol, MyClient.FmtMoneyStrBrackets, true);
      AddFormatColAuto( Job, cLeft, 20, gcGap,'Total',  jtRight, MyClient.FmtMoneyStrBracketsNoSymbol, MyClient.FmtMoneyStrBrackets, true);

      //Add Footers
      AddCommonFooter(Job);

      Job.OnBKPrint := TrialBalanceDetail;
      Job.Generate( Destination, Params );
    finally
      Job.Free;
      Params.Free;
    end;
  finally
    CalculateAccountTotals.RemoveAutoContraCodes( MyClient);
  end;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure VerifyPreConditions( aClient : TClientObj; var ErrorMsg : string);
//there are no longer any preconditions that need to be satified.  The reports
//will automatically add contra accounts where needed
begin
  ErrorMsg := '';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
