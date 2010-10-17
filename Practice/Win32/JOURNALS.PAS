//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unit Journals;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
 baobj32;

procedure EnterJournal(Account_Type : integer; ForDate : Integer = 0);
function GetJournalAccount(Account_Type : integer) : tBank_Account;
procedure ViewJournals(Account_Type : integer);

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
uses
   Forms,
   UpdateMF,
   globals,
   bkdefs,
   bkHelp,
   JournalDlg,
   ovcDate,
   bkDateUtils,
   CodingFrm,
   SelectJournalDlg,
   Controls,
   CodeDateDlg,
   bktxio,
   bkConst,
   ApplicationUtils,
   jnlutils32,
   CountryUtils,
   InfoMoreFrm;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetJournalAccount(Account_Type : integer) : tBank_Account;
begin
  if Assigned(MyClient) then begin

     Result := MyClient.clBank_Account_List.Get_Journal_Account(Account_Type);

     if Result = nil then // Not in the list..
        Result := MyClient.clBank_Account_List.New_Journal_Account(Account_Type);// Try to Add
  end else
     Result := nil;      
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure EnterJournal(Account_Type : integer; ForDate : Integer = 0);
//Allows the user to select a journal and begin entering details for it.
//The Journal type is passed into this procedure, normal by selecting an item
//from the main menu.  If an Account for this journal type does not exist then
//a new account is created.  If the is no existing transaction on the data selected
//by the user then a new transaction is created to dissect.
//
//Journal lines are stored as a dissection.  There should only be one transaction
//per date for the Journal Account in question.
var
  bank_Account : tBank_Account;
  Transaction  : pTransaction_Rec;
  DR: TDateRange;
  h: Integer;
  JA: Integer;
  procedure CodeRange;
  begin
     ApplicationUtils.DisableMainForm;
     try
         CodeTheseEntries(DR.Fromdate, DR.ToDate ,bank_Account, [CC_GotoFirstUncoded]);
         //Client.clFields.clPeriod_Start_Date := DR.FromDate;
         //Client.clFields.clPeriod_End_Date := DR.ToDate;
     finally
        ApplicationUtils.EnableMainForm;
        ApplicationUtils.MakeMainFormForeground;
     end;

  end;
var
  HideViewButton : boolean;
begin
  if not Assigned(myClient) then
     Exit;

   //check that this journal account exists
   CloseAllCodingForms; // Has to be before GetJournalAccount, because it may remove the account (if Empty)
   Bank_Account := GetJournalAccount(Account_Type);
   if not Assigned(Bank_Account) then
      Exit;



   case Account_Type of
     btCashJournals :  h := BKH_Cash_journals;
     btAccrualJournals :  h := BKH_Accrual_journals;
     btGSTJournals : h := BKH_GST_journals;
     btStockJournals :  h := BKH_Stock_Adjustment_Journals;
     btYearEndAdjustments : h := BKH_Year_end_adjustment_journals;
     else  h := 0;
   end;
   Transaction := nil;
   HideViewButton := (Globals.Active_UI_Style = UIS_Simple);

   case SelectJournal( Account_Type, Bank_Account, ForDate,Transaction,JA, h,False) of
      mrRetry : begin // View Month...
         Dr := GetMonthDateRange(ForDate);
         CodeRange;
      end;
      mrOk : begin
         EditJournalEntry(Bank_Account, Transaction, Account_Type, 0, JA);
         JnlUtils32.RemoveJnlAccountIfEmpty(MyClient, Bank_Account);

         if not(Globals.Active_UI_Style = UIS_Simple) then
         begin
           Dr := GetMonthDateRange(ForDate);
           if HasJournalsInMonth(Bank_Account,DR) then
              CodeRange;
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ViewJournals(Account_Type : integer);
var
  DR : TDateRange;
  bank_Account : tBank_Account;

  procedure CodeRange;
  begin
     ApplicationUtils.DisableMainForm;
     try
       CodeTheseEntries(DR.Fromdate, DR.ToDate ,bank_Account, [CC_GotoFirstUncoded]);
     finally
        ApplicationUtils.EnableMainForm;
        ApplicationUtils.MakeMainFormForeground;
     end;
  end;

begin
  //use current coding range as default
  DR.FromDate := gCodingDateFrom;
  DR.ToDate   := gCodingDateTo;

  if not Assigned(myClient) then
     Exit;

  //check that this journal account exists
  CloseAllCodingForms; // Has to be before GetJournalAccount, because it may remove the account (if Empty)
  Bank_Account := GetJournalAccount(Account_Type);
  if not Assigned(Bank_Account) then
    Exit;


  //prompt user for date range
  if CodeDateDlg.EnterDateRange( 'Select Date Range', 'Please select a date range to view journal entries from.', DR.FromDate , DR.ToDate, 0, false, false) then
  begin
    //check if there are any journals in this range
    if HasJournalsInMonth( Bank_Account, DR) then
      CodeRange
    else
      HelpfulInfoMsg('There are no journal entries in this date range.',0);
  end;
end;

end.
