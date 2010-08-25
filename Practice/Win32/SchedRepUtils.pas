unit SchedRepUtils;

interface

uses
   baObj32,
   ReportDefs,
   Classes,
   clobj32;

const
   EMAIL_MESSAGE = 0;
   EMAIL_ECODING = 1;
   EMAIL_CHECKOUT = 2;
   EMAIL_WEBNOTES = 3;
   EMAIL_BUSINESS_PRODUCT = 4;

type
   //this record is passed into most of the routines used in schedule reports.
   //the routines do not use all of the variable but only use the variables
   //relevant to the routine.
   TSchReportOptions = record
      //User Options
      // 'from' code when using a range
      srFromCode     : string;
      // 'to' code when using a range
      srToCode       : string;
      // list of codes when using a selection
      srCodeSelection: TStringList;
      // true = print all transaction regardless of date
      // false = print new txns only
      srPrintAll     : boolean;
      //Internal Values
      // set automatically in PrintScheduledDlg when printing, indicates if admin update required for last date
      // false for list reportsdue, otherwise true
      srUpdateAdmin  : boolean;
      // list of TSchdRepSummaryRec's filled by coding report
      srSummaryInfoList: TList;
      //used by PrintByStaffMember - User LRN for current staff member when printing header page
      srUserLRN      : integer;
      // for doing a test fax
      srTestFaxNumber : string[20];
      srTestFaxRecip : string[20];
      srTestCoverpageFilename : string[128];

      //Client Specific Values
      // The minimum date for which to display transactions
      // Could be based on:
      // - calculated based on the user selected month and the client reporting period
      // - may be reset back to a date in the previous month if there are txns unprinedt from that month
      srTrxFromDate  : integer;  //will be filled in by DoScheduledReportsForClient
      // The maximum date for which to display transactions
      // Will always be based on the user selected month
      srTrxToDate    : integer;  //will be filled in by DoScheduledReportsForClient
      srPrintAllForThisClient : boolean; //in most cases this will be the same as the srPrintAll
                                         //unless the client is setup for MMQ or MQ reporting
      // This is the date which will be shown on the report - it is never modified for unprinted txns from previous month
      // The date printed on the report always shows the user selection date, rather than the actual txn date range
      srDisplayFromDate : integer; // date for report display

      // If any Custom document, put the GUID here
      srCustomDocGUID: string;
      // if Its printed to an attachment, put it here
      srAttachment: string;
   end;

   //This record hold the individual lines for the Schedule Reports Summary Report.
   //The items are inserted into the SummaryInfo list by the coding report and
   //used by the Summary Report object
   pSchdRepSummaryRec = ^TSchdRepSummaryRec;
   TSchdRepSummaryRec = record
     ClientCode    : string[10];
     AccountNo     : string[20];
     PrintedFrom   : integer;
     PrintedTo     : integer;
     AcctsPrinted  : integer;
     AcctsFound    : integer;
     SendBy        : TReportDest;
     UserResponsible : Integer;
     Completed     : Boolean;
     TxLastMonth   : Boolean;
   end;

   TClientEmailInfo = class(Tobject)
   public
     EmailType     : Integer;
     ClientCode    : string[10];
     EmailAddress  : string[80];
     CCEmailAddress  : string[255];
     ECodingFilename : string[ 128];
     ClientMessage  : String;
     AttachmentList : string;
     DateFrom       : integer;
     DateTo         : integer;
     procedure AddAttachment(Value: string);
   end;

function GetReportingPeriodToUse( Reporting_Period : byte;
                                  ReportStartDate : integer;
                                  LastDatePrinted : integer;
                                  PrintUpToDate : integer;
                                  PrintAllSelected : boolean) : byte;
function IsUPCFromPreviousMonth(TxnDate: Integer; UPI: Integer; D3: Integer): Boolean;                                  

procedure UpdateSRStartDate(AClient: TClientObj; var srOptions : TSchReportOptions);




implementation

uses
   bkConst,
   stDate,
   bkdateutils,
   ClientUtils,
   Math,
   Globals,
   SyDefs;


function GetReportingPeriodToUse( Reporting_Period : byte;
                                  ReportStartDate : integer;
                                  LastDatePrinted : integer;
                                  PrintUpToDate : integer;
                                  PrintAllSelected : boolean) : byte;
//used to decide if we should override the specified reporting period with a new
//period.  This is done when the reporting period is variable, ie Month, Month, Quarter
var
  Day, Month, Year : integer;
  D2, M2, Y2 : integer;
begin
  result := Reporting_Period;

  if not ( Reporting_Period in [ roSendEveryMonthQuarter, roSendEveryMonthTwoMonths, roSendEveryTwoMonthsMonth ]) then
    exit
  else
  begin
    if (not PrintAllSelected) and (Reporting_Period <> roSendEveryTwoMonthsMonth) then
    begin
      //only print quarter/two month range if date of last entry printed is not in
      //the same month as the Print Up To Date
      if LastDatePrinted > 0 then
      begin
        StDateToDMY( PrintUpToDate, D2, M2, Y2);
        StDateToDMY( LastDatePrinted, Day, Month, Year);

        if ( M2 = Month) and ( Y2 = Year) then
          //just print for this month as we have already printed the two/three
          //month run
          exit;
      end;
    end;
  end;

  //now see if this is a quarter or second month.  If it is then we override the
  //period to be a two or three month period
  case Reporting_Period of
    roSendEveryMonthQuarter:
      begin
        DateDiff(ReportStartDate, PrintUpToDate, Day, Month, Year);

        if ( ReportStartDate < PrintUpToDate) then
          //need to add one because the end of the current month to the beginning
          //of the next is 0 months, 1 day and not 1 month as we would expect.
          Inc(Month);

        if ((Month mod 3) = 0) then
          result := roSendEveryThreeMonths;

      end;
    roSendEveryMonthTwoMonths:
      begin
        DateDiff(ReportStartDate, PrintUpToDate, Day, Month, Year);

        if ( ReportStartDate < PrintUpToDate) then
          //need to add one because the end of the current month to the beginning
          //of the next is 0 months, 1 day and not 1 month as we would expect.
          Inc(Month);

        if ((Month mod 2) = 0) then
          result := roSendEveryTwoMonths;
      end;
    roSendEveryTwoMonthsMonth:
      begin
        DateDiff(ReportStartDate, PrintUpToDate, Day, Month, Year);

        if ( ReportStartDate < PrintUpToDate) then
          //need to add one because the end of the current month to the beginning
          //of the next is 0 months, 1 day and not 1 month as we would expect.
          Inc(Month);

        if ((Month mod 3) = 0) then
          result := roSendEveryMonth
        else
          result := roSendEveryTwoMonths;
      end;
  end;
end;

function IsUPCFromPreviousMonth(TxnDate: Integer; UPI: Integer; D3: Integer): Boolean;
var
  ReportMonth, TxnMonth: Integer;
begin
  // User-selected report month
  ReportMonth := GetMonthNumber(D3);
  // Month of this txn
  TxnMonth := GetMonthNumber(TxnDate);
  // If its an unpresented item from the previous month then we don't want to include it
  Result := (TxnMonth = (ReportMonth - 1)) and (UPI in [upUPC, upUPD, upUPW]);
end;



procedure UpdateSRStartDate(AClient: TClientObj; var srOptions : TSchReportOptions);
var acno: Integer;
    BA: TBank_Account;
    AdminBA: pSystem_Bank_Account_Rec;
    LastDate: Integer;
    FirstPosibleDate : Integer;
    T: Integer;
begin


      FirstPosibleDate := MaxInt;
      for acNo := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
         BA := aClient.clBank_Account_List.Bank_Account_At( acNo);

         if BA.baFields.baAccount_Type in [ btBank] then begin

            //access the admin system and read date_of_last_transaction_printed.
            AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( BA.baFields.baBank_Account_Number);
            if Assigned( AdminBA) then begin
               if Pos(ba.baFields.baBank_Account_Number + ',', aClient.clFields.clExclude_From_Scheduled_Reports) > 0 then
                  Continue;

               LastDate := ClientUtils.GetLastPrintedDate(aClient.clFields.clCode, AdminBA.sbLRN);

               if LastDate = 0 then
                  continue; // This account can't help us..

               if GetMonthsBetween(LastDate, srOptions.srTrxFromDate ) > 1 then
                  // More than a whole month missing ... Dont go too far back
                  LastDate := GetFirstDayOfMonth(IncDate(srOptions.srTrxFromDate, 0, -1, 0))
               else
                  inc(LastDate);
               //So LastDate is now the first available new date
               //Thats fine, but do I actually have any data for that...
               for T := 0 to BA.baTransaction_List.last do
                  with ba.baTransaction_List.Transaction_At(T)^ do
                     if (txDate_Effective >= LastDate)
                     and(txDate_Effective <= SROptions.srTrxToDate)
                     and(not IsUPCFromPreviousMonth(txDate_Effective, txUPI_State, srOptions.srDisplayFromDate))
                     and(txDate_Transferred = 0) then begin
                        LastDate := txDate_Effective;
                        Break; // one is enough (They are in date order)..
                     end;
               FirstPosibleDate := Min(FirstPosibleDate, LastDate); // For this account
            end;
         end;
      end;
      if FirstPosibleDate < srOptions.srTrxFromDate then
          srOptions.srTrxFromDate := FirstPosibleDate;
end;

{ TClientEmailInfo }

procedure TClientEmailInfo.AddAttachment(Value: string);
begin
   if Value = '' then
      Exit;
   if AttachmentList > '' then
      AttachmentList := AttachmentList + ',';
   AttachmentList := AttachmentList + Value
end;

end.
 