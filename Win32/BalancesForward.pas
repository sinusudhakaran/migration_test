unit BalancesForward;
//------------------------------------------------------------------------------
{
   Title:       Balances Forward Routines


   Description: Provides all routines required to roll forward the closing balances
                from last year into the opening balances for the new financial year

   Author:      Matthew Hopkins  Jul 2002

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
  clObj32;

procedure VerifyPreconditions( const aClient : TClientObj; var ErrorMsg : string);
procedure SetupParameters( const aClient : TClientObj);

//******************************************************************************
implementation
uses
  CountryUtils,
  baObj32,
  bkConst,
  bkDateUtils,
  bkDefs,
  glConst,
  jnlUtils32,
  MoneyDef,
  PeriodUtils,
  SysUtils, OpeningBalancesDlg;

procedure VerifyPreconditions( const aClient : TClientObj; var ErrorMsg : string);
//checks that all of the preconditions for the report are met.  Error Msg
//will be empty if there are no errors.

//A rollover cannot be done if the any of the following are true
//
//  - No opening balance figures exist
//  - There are missing GST contras
//  - There are missing Bank Account contras
//  - Theres are uncoded entries
var
  ErrorNo        : integer;

  procedure AddToErrorMsg( NewMsg : string);
  begin
    if ErrorNo > 0 then
      ErrorMsg := ErrorMsg + #13;

    Inc( ErrorNo);

    ErrorMsg := ErrorMsg + inttostr( ErrorNo) + ')  ' + NewMsg + #13;
  end;

var
  pT     : pTransaction_Rec;
  pD     : pDissection_Rec;
  pAcct  : pAccount_Rec;
  Ba     : TBank_Account;
  i      : integer;
  Found  : Boolean;
  Valid  : Boolean;
  GSTClassIsUsed : Boolean;
  Total          : Money;
begin
  ErrorMsg := '';
  ErrorNo  := 0;

  //check that period covered is valid
  if (aClient.clFields.clFinancial_Year_Starts <= aClient.clFields.clLast_Financial_Year_Start) then begin
    ErrorMsg := 'You have not moved the Financial Year Start Date forward.  The current ' +
                'financial year is (' +
                bkDate2Str( aClient.clFields.clLast_Financial_Year_Start) + ' - ' +
                bkDate2Str( aClient.clFields.clFinancial_Year_Starts) + ')';
    Exit;
  end;

  //see if an opening balance journal exists, if so make sure it still balances
  //the user may have deleted accounts, or changed report groups
  Total := 0;
  with aClient.clBank_Account_List do
    for i := 0 to Pred( ItemCount) do begin
      Ba := Bank_Account_At(i);
      if ( Ba.baFields.baAccount_Type = btOpeningBalances) then begin
        pT := GetJournalFor( Ba, aClient.clFields.clFinancial_Year_Starts);
        if Assigned( pT) then begin
          //jnl found, make sure it balances
          pD := pT^.txFirst_Dissection;
          while pD <> nil do begin
            pAcct := aClient.clChart.FindCode( pD^.dsAccount);
            if Assigned( pAcct) and (pAcct^.chAccount_Type in BKCONST.BalanceSheetReportGroupsSet) then
            begin
              Total := Total + pD^.dsAmount;
            end;
            pD := pD.dsNext;
          end;
        end;
      end;
    end;

  if (Total <> 0) then begin
    AddToErrorMsg( 'The Opening Balance figures as at ' + bkDate2Str( aClient.clFields.clFinancial_Year_Starts) +
                   ' are out of balance');
  end;

  //check that all gst contras are specified
  Found := true;
  Valid := true;
  for i := 1 to Max_GST_Class do begin
    GSTClassIsUsed := (aClient.clFields.clGST_Class_Codes[ i] <> '') and
                      (aClient.clFields.clGST_Class_Names[ i] <> '');
    if GSTClassIsUsed then begin
      if (aClient.clFields.clGST_Account_Codes[ i] = '') then begin
        //no contra specifed
        Found := false;
      end
      else begin
        //contra specified, see if links to a valid account
        if not Assigned( aClient.clChart.FindCode( aClient.clFields.clGST_Account_Codes[ i])) then
          Valid := false;
      end;
   end;
  end;

  if not Found then
    AddToErrorMsg(Localise(aClient.clFields.clCountry,'Some GST Classes do not have a GST Control Account assigned to them'));

  if not Valid then
    AddToErrorMsg(Localise(aClient.clFields.clCountry, 'Some GST Classes have an invalid GST Control Account assigned to them'));

  //check that all bank accounts contras are specified
  Found := true;
  Valid := true;

  for i := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
    Ba := aClient.clBank_Account_List.Bank_Account_At(i);
    if ( Ba.baFields.baAccount_Type = btBank) then begin
      if ( Ba.baFields.baContra_Account_Code = '') then begin
        Found := false;
      end
      else begin
        //contra code specified, make sure is valid
        if not Assigned( aClient.clChart.FindCode( Ba.baFields.baContra_Account_Code)) then
          Valid := false;
      end;
    end;
  end;

  if not Found then
    AddToErrorMsg('Some Bank Accounts do not have a Bank Account Contra Code assigned to them');

  if not Valid then
    AddToErrorMsg('Some Bank Accounts have an invalid Bank Account Contra Code assigned to them');

  //check there are no uncoded or invalidly coded entries
  PeriodUtils.LoadPeriodDetailsIntoArray( aClient, aClient.clFields.clTemp_FRS_From_Date,
                                          aClient.clFields.clTemp_FRS_To_Date,
                                          false,
                                          frpCustom,
                                          aClient.clFields.clTemp_Period_Details_This_Year);

  Found := false;
  for i := 1 to aClient.clFields.clTemp_FRS_Last_Period_To_Show do
    if aClient.clFields.clTemp_Period_Details_This_Year[ i].HasUncodedEntries then
      Found := true;

  if Found then
    AddToErrorMsg('There are Uncoded or Invalidly Coded Entries in the Financial Year (' +
                bkDate2Str( aClient.clFields.clTemp_FRS_From_Date) + ' - ' +
                bkDate2Str( aClient.clFields.clTemp_FRS_To_Date) + ')');

  if not ValidateOpeningBalances(aClient, aClient.clFields.clLast_Financial_Year_Start) then
    AddtoErrorMsg('You have amounts posted to non-balance sheet accounts in the Opening Balances for ' + bkDate2Str(aClient.clFields.clLast_Financial_Year_Start));
end;

procedure SetupParameters( const aClient : TClientObj);
begin
  //the from and to dates for the totals should be set to the last financial start date
  //and the day before the new financial year
  aClient.clFields.clFRS_Reporting_Period_Type := frpCustom;
  aClient.clFields.clTemp_FRS_From_Date        := aClient.clFields.clLast_Financial_Year_Start;
  aClient.clFields.clTemp_FRS_To_Date          := aClient.clFields.clFinancial_Year_Starts - 1;
  aClient.clFields.clTemp_FRS_Last_Period_To_Show := 1;
  aClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use := 1;
  aClient.clFields.clReporting_Year_Starts     := aClient.clFields.clLast_Financial_Year_Start;
  aClient.clFields.clTemp_FRS_Budget_To_Use    := '';
  aClient.clFields.clTemp_FRS_Budget_To_Use_Date := -1;  
  aClient.clFields.clTemp_FRS_Division_To_Use  := 0;
  aClient.clFields.clTemp_FRS_Job_To_Use := ''; 
  aClient.clFields.clTemp_FRS_Account_Totals_Cash_Only          := False;
  aClient.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual    := False;
  aClient.clFields.clGST_Inclusive_Cashflow    := False;
end;

end.
