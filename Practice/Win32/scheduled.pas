Unit scheduled;
//------------------------------------------------------------------------------
{
   Title:       Scheduled reports unit

   Description:

   Remarks:     Determine which clients are due for scheduled reports by
                reading the admin system and client files if needed.

                FlagClientsWithReports due is called to set a flag in admin system
                the admin system is then loaded and these flags are reloaded then
                saved.

                Generating scheduled reports for a client involves

                Opening the client file for reading
                Synchronising the client to the admin system ( to get all trx)
                Generating the reports ( working on myClient object)
                Close client without saving.

                !! Nov 00 - Only accounts that exist in the admin system will
                            be printed on the scheduled coding report.

                            This is because there is nowhere to store the date
                            of the last transaction printed for accounts which
                            are not part of the admin system.

                            This includes Journals and Temporary accounts.

                !! Known Issues:

                Scheduled Reports due will returns clients that should be due,
                however the list will be incorrect if that client does not have any
                bank accounts, that exist in the admin system, to print.  This will
                only happen if Print All has been selected, or printing for previous
                periods.

                The Date_Of_Last_Transaction_Printed setting in the admin system
                is set on a per account basis, rather than a per client basis.  This
                will cause problems if the account is attached to more than one client
                that uses schedule reporting.

                There is a minor chance that some transactions may be missed from
                the coding report if the are on the same date as the date of the
                last transaction printed.  This would not normally occur because
                usually send ALL data for a particular account.


   Author:      Matthew

   Scheduled:   Used by PrintScheduledDlg, MainFrm, Reports, RptAdmin

   Last Reviewed: 22 May 2003  MH
                  19 May 2003  MH

}
//------------------------------------------------------------------------------

{

  Basic flow is as follows (see individual methods for additional comments)

PrintScheduledReports
---------------------
  Initialise
	Get Options (show the dialog)
	CALL FlagClientsWithReportsDue
	Set flag for clients that are due
	Client-Account Map - reset 'Temp Last Date' to 0
	CALL PrintReportsByStaffMember OR PrintReportsByClient
		CALL ProcessClient for each due client
			CALL DoScheduledReportsForClient or DoExportScheduledECodingFile etc depending on SR method
      Move 'Temp Last Date' to 'Permanent Last Date' in Client-Account Map if succesful (email clients are done later as they have not yet been sent even tho they have been generated)
	Send Emails
	Preview summary report (if required)
	If summary rec indicates the client was all successful then move 'Temp Last Date' to 'Permanent Last Date' in Client-Account Map for email clients
	Clean up


FlagClientsWithReportsDue
-------------------------
	Loop through client/staff list, only include those in selected range if user chose range or selection
	CALL ScheduledReportsDue
	Flag client as due and/or having unprinted txns last month
	If txns unprinted last month then set AdminSystem fdPrint_Reports_From to this date -
     (this will be the actual start date that is required in order to include all unprinted txns from this month and last month for all clients
      if no txns last month then this will be always zero)

ScheduledReportsDue
-------------------
	Tests to see if we need to include the client
	Work out if there are unprinted transaction this month
	Work out if there are unprinted transactions last month
 	(see code for full comments)

DoScheduledReportsForClient
---------------------------
If fdPrint_Reports_From is set then srTrxFromDate will be this value
srDisplayFromDate will be the start date as selected by the user - this is displayed on reports -
(Reason: fdPrint_Reports_From is the earliest possible date across all clients so we don't want to show that same value on every client as not every client is likely to have the same earliest date)
srTrxToDate is always the report ending date. FogBugz #7263 asks for this to be fixed to show the 'correct' date per client.

}

Interface

uses
  sydefs, classes, reportdefs, SchedRepUtils;

  Procedure PrintScheduledReports;
  procedure AddSummaryRec(ClientCode : String; srOptions : TSchReportOptions;
            Dest : TReportDest; IsCompleted: Boolean; AAccountNo: string = '');

  Function  ScheduledReportsDue(aSysClient :pClient_File_Rec; Options : TSchReportOptions;
      var UnPrintedLastMonth: Boolean; var EarliestDate: Integer) : boolean;

const
  CUSTOM_DOCUMENT = 'Custom Document';

//******************************************************************************
implementation

uses
  WebNotesDataUpload,
  WarningMoreFrm,
  LockUtils,
  Forms,
  Globals,
  usageUtils,
  PrintScheduledDlg,
  AutoCode32,
  ovcDate,
  baObj32,
  bkUtil32,
  MoneyDef,
  bkDateUtils,
  GlobalCache,
  updatemf,
  bkconst,
  InfoMoreFrm,
  ErrorMoreFrm,
  Reports,
  files,
  SendEmail,
  NNWFax,
  Merge32,
  SysUtils,
  LogUtil,
  StatusFrm,
  ToDoHandler,
  Progress,
  PracticeLogo,
  Bk5Except,
  Admin32,
  ArchUtil32,
  clObj32,
  BNotesInterface,
  glConst,
  MailFrm,
  YesNoDlg,
  RptDateUtils, BKDEFS, BaList32, SysObj32, SBAList32, trxList32,
  ReportImages, cfList32, usrlist32, PrintMgrObj, WinUtils, WebXOffice,
  ClientUtils, BusinessProductsExport, Windows, ClientHomePageFrm, ClientManagerFrm,
  Math, UBatchBase, grpList32, ctypelist32;

Const
   UnitName = 'SCHEDULED';
   SchReportsRunning : Boolean = false;

Var
   DebugMe : boolean = false;
   EmailList : TList;
   EncodedLogoString : string = '';
   FaxErrors: Integer;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function ItemInRange(ReportSelectionOption: Integer; FromCode: String; ToCode: String; Selections: TStringList; ItemCode: string): Boolean;
begin
  Result := (ReportSelectionOption = srslAll) or
            ((ReportSelectionOption = srslRange) and (FromCode <= ItemCode) and (ItemCode <= ToCode) ) or
            ((ReportSelectionOption = srslSelection) and (Selections.IndexOf(ItemCode) > -1) );
end;

Function UseUnallocated(ReportSelectionOption: Integer; ToCode: String; Selections: TStringList): Boolean;
begin
  Result := (ReportSelectionOption = srslAll) or
            ((ReportSelectionOption = srslRange) and (ToCode =  'þ')) or
            ((ReportSelectionOption = srslSelection) and ((Selections.Count = 0) or (Selections.IndexOf(' ') > -1) ))
end;

function ShowTransLastMonth(aClient: TClientObj; srOptions : TSchReportOptions): boolean;
begin
  Result := (aClient.clFields.clReporting_Period = roSendEveryMonth) and
            (srOptions.srTrxFromDate <> srOptions.srDisplayFromDate) and
            (not aClient.clFields.clCheckOut_Scheduled_Reports) and
            (not aClient.clExtra.ceOnline_Scheduled_Reports);
end;

function PrepareEmailOutbox( Path : string) : boolean;
// make sure the directory exists and is empty
// used by:  Print Scheduled Reports
var
   SearchRec  : TSearchRec;
   Found      : longint;
begin
   result := false;

   if DirectoryExists( Path) then begin
      //clear contents of current directory
      Found := FindFirst(Path + '*.*', faAnyFile, SearchRec);
      try
         while Found = 0 Do Begin
            SysUtils.DeleteFile( Path + SearchRec.Name);
            Found := FindNext(SearchRec);
         end;
      finally
         SysUtils.FindClose(SearchRec);
      end;
   end
   else begin
     //directory not there, create a new directory
     if not CreateDir(Path) then begin
       Exit;
     end;
   end;
   result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function PrepareCSVExportDir( Path : string) : boolean;
//make sure that the csv export directory exists
begin
  result := false;
  if not DirectoryExists( Path) then
  begin
    if not CreateDir( Path) then
    begin
      //directory could not be created
      Exit;
    end;
  end
  else
  begin
    //clean up an practice.csv file that is still there
    SysUtils.DeleteFile( Path + AdminSystem.fdFields.fdBankLink_Code + '.CSV');
  end;

  Result := true;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SendReportsViaEmail(srOptions : TSchReportOptions) : boolean;


begin
   UpdateAppStatus('Sending Reports via E-mail','',-1, ProcessMessages_On);
   //disable main form so that menus and toolbars can't be used
   DisableMainForm;
   try
      Result := SendSceduledEmail(EmailList, srOptions);
   finally
      EnableMainForm;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  ScheduledReportsDue( aSysClient : pClient_File_Rec;
                               Options : TSchReportOptions;
                               var UnPrintedLastMonth: Boolean;
                               var EarliestDate: Integer) : boolean;

// used by: Flag Clients With Reports Due, RPTADMIN.Whats Due Detail
// parameters: aSysClient        - current client object being used
//             NextMthStartDate  - start date of next month
//             Option            - from, to, print all, update admin
//
// method:
//
// Tries to see if the start date of the next month is also the start date of the
// next Reporting period for the client.  If this is true we are at the end of a
// reporting period for the client.
//
// This is done by moving the clients Report Start Date forward/backward by the
// number of months in the period setting ( ie 2mths, 6mths) until to matches
// the NextMthStartDate.  If it does match then reports are due.
//
// Once the reporting period has been checked
//
// A temporary client file must then be opened to determine which accounts are
// attached to the client and if they have any NEW transactions to print from this month
// or from top-ups from the previous month
//
// Assumptions:  NextMthStartDate will be a first of month date.  This is normally taken
//                  from the fdFields.fdPrint_Reports_Up_To date, which is an EOM date.
//                  This date is the incremented by one day to set it to a BOM date.
//
//               cfReport_Start_Date is a first of the month date
//
const
  ThisMethodName = 'ScheduledReportsDue';
var
  TempClient     : TClientObj;
  RptStartDate   : Integer;
  RptEndDate     : Integer;
  RptPrintAllForThisClient, TxIsIncluded : boolean;
  AdminBA        : pSystem_Bank_Account_Rec;
  I              : Integer;
  T              : Integer;
  ClientCode     : string;
  RptPeriodToUse : byte;
  BA             : TBank_Account;
  LastDate, LastMonth, ReportMonth, LastDateForPrevMonthTest: Integer;
//  ClientDest     : byte;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Admin Client Code ' + aSysClient.cfFile_Code);
  Result := False;
  UnprintedLastMonth := False;
  try
    With aSysClient^ do
    Begin { Do we need to print this client? }
      If ( cfFile_Password <> '' ) and (not cfSchd_Rep_Method in [srdCheckOut, srdOnline]) then exit;  // We don't print any password protected files.
      If ( cfReport_Start_Date<=0 ) then exit; // No report start date, so don't print.
      If cfForeign_File then exit;             // There is no data for foreign files.
      If not ( cfReporting_Period in [ roSendEveryMonth..roSendEveryTwoMonthsMonth ] ) then exit; // No reporting period set up.

      If not RptDateUtils.Is_In_Reporting_Period( AdminSystem.fdFields.fdPrint_Reports_Up_To, cfReport_Start_Date, cfReporting_Period ) then
         exit; // The client's reporting period doesn't match our period end date.

      // set the reporting period dates
      RptPeriodToUse := GetReportingPeriodToUse( cfReporting_Period,
                                                 cfReport_Start_Date,
                                                 cfLast_Print_Reports_Up_To,
                                                 AdminSystem.fdFields.fdPrint_Reports_Up_To,
                                                 Options.srPrintAll);

      RptEndDate    := AdminSystem.fdFields.fdPrint_Reports_Up_To;
      RptStartDate  := Get_Reporting_Period_Start_Date( RptEndDate, RptPeriodToUse );
      //the only time that the reporting period will be different is when it has been
      //overriden by Get Reporting Period To Use, this will happen if the period is MMQ or MQ
      RptPrintAllForThisClient := Options.srPrintAll or (( RptPeriodToUse <> cfReporting_Period) and (cfReporting_Period <> roSendEveryTwoMonthsMonth));

      ClientCode    := cfFile_Code;

      //check that the client will actually be included in this run, the user
      //can select which clients to include so make sure that the destination
      //for this client matches a selected destination
      with AdminSystem.fdFields do
      begin
        if not (( fdSched_Rep_Include_Email and ( cfSchd_Rep_Method = srdEmail)) or
                ( fdSched_Rep_Include_Printer and ( cfSchd_Rep_Method = srdPrinted)) or
                ( fdSched_Rep_Include_Fax and ( cfSchd_Rep_Method = srdFax)) or
                ( fdSched_Rep_Include_ECoding and ( cfSchd_Rep_Method = srdECoding)) or
                ( fdSched_Rep_Include_WebX and ( cfSchd_Rep_Method = srdWebX)) or
                ( fdSched_Rep_Include_CheckOut and ( cfSchd_Rep_Method = srdCheckOut)) or
                ( fdSched_Rep_Include_Online and ( cfSchd_Rep_Method = srdOnline)) or
                ( fdSched_Rep_Include_Business_Products and ( cfSchd_Rep_Method = srdBusinessProducts)) or
                ( fdSched_Rep_Include_CSV_Export and ( cfSchd_Rep_Method = srdCSVExport))) then
          Exit;
      end;
    end;

     //Open the client file and bring in any new transactions to determine whether there are any
     //transactions to print
     OpenAClientForRead( ClientCode, TempClient );

     if not Assigned( TempClient ) then exit; // Couldn't open the file
     Try
       If ( TempClient.clFields.clMagic_Number <> AdminSystem.fdFields.fdMagic_Number ) then
          exit; // Not from this Admin System
       If ( TempClient.clFields.clDownload_From <> dlAdminSystem ) then
          exit; // File downloads data directly.

       //If this is a bnotes file then read the entry selection criteria from
       //the bnotes settings
       with TempClient.clFields do
       begin
         if clECoding_Export_Scheduled_Reports or clWebX_Export_Scheduled_Reports then
           clScheduled_Coding_Report_Entry_Selection := clECoding_Entry_Selection;

         if clCSV_Export_Scheduled_Reports or clBusiness_Products_Scheduled_Reports then
           clScheduled_Coding_Report_Entry_Selection := esAllEntries;
       end;

       // Bring in any new transactions, MH - Not sure what the time hit will be,
       //                                     need to investigate.
       SyncClientToAdmin( TempClient, True, True, False, True ); //<<- May cause reloading of admin system

       with TempClient.clBank_Account_List do
       begin
         for i := 0 to Pred( ItemCount ) do
         begin
           BA := Bank_Account_At( i );
           with BA do
           begin
              If baFields.baAccount_Type <> btBank then Continue; // Not a Bank Account

              AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( baFields.baBank_Account_Number );
              If not Assigned( AdminBA ) then Continue; // Couldn't find this account in the Admin System
              if Pos(ba.baFields.baBank_Account_Number + ',', TempClient.clFields.clExclude_From_Scheduled_Reports) > 0 then Continue;
              AutoCodeEntries(TempClient, BA,AllEntries, RptStartDate, RptEndDate); //Options.srTrxFromDate,Options.srTrxToDate);
              // Check the last date from the client-account map (date sched rep was run up to)
              LastDate := ClientUtils.GetLastPrintedDate(TempClient.clFields.clCode, AdminBA.sbLRN);
              // If it's zero then this client has never had SR run before - so we need
              // all txns from this month (the test later on is for 'greater than' - so we
              // need to set back a day from the report start date)
              if LastDate = 0 then
                LastDateForPrevMonthTest := IncDate(RptStartDate, -1, 0, 0)
              // If SR has not been run for more than a month then we only go back
              // a maximum of one month
              else if GetMonthsBetween(LastDate, RptStartDate) > 1 then
                LastDateForPrevMonthTest := IncDate(GetFirstDayOfMonth(IncDate(RptStartDate, 0, -1, 0)), -1, 0, 0)
              // otherwise we just use the date directly from the map
              else
                LastDateForPrevMonthTest := LastDate;
              // Get report month and last month numbers for later comparison
              ReportMonth := GetMonthNumber(RptStartDate);
              if GetLastDayOfMonth(LastDate)= LastDate then
                LastMonth := ReportMonth
              else
                LastMonth := GetMonthNumber(LastDate);
              //Bank Account found and transactions are merged.
              //See if account has transactions within the report range to be printed
              //The see if have already been printed, or if we are reprinting.
              With baTransaction_List do For T := 0 to Pred( ItemCount ) do With Transaction_At( T )^ do
              Begin
                 If ( CompareDates( txDate_Effective, RptStartDate, RptEndDate ) = Within ) then
                 Begin
                    If RptPrintAllForThisClient then
                    Begin
                      //Check if the coding report is for uncoded entries only
                      case TempClient.clFields.clScheduled_Coding_Report_Entry_Selection of
                        esAllEntries  : Result := True;
                        esUncodedOnly : Result := BkUtil32.IsUncoded( TempClient, Transaction_At( T));
                      end;

                      if Result then // ok to exit - we have txns to print
                        exit
                      else // check the rest of the txns
                        Continue;
                    end;
                    If (not Result) and ( txDate_Effective > LastDate ) then // we have a new txn to print - printing NEW only
                    Begin
                      //Only printing clients with 'New' transactions
                      //Check if the coding report is for uncoded entries only
                      case TempClient.clFields.clScheduled_Coding_Report_Entry_Selection of
                        esAllEntries  : Result := True;
                        esUncodedOnly : Result := BkUtil32.IsUncoded( TempClient, Transaction_At( T));
                      end;
                      // ok we now have a new txn to print BUT we may still need to carry on to check for
                      // unprinted txns from the previous month
                      // We can exit only if:
                      // - report month and previous month are the same (i.e. no check required)
                      // - we already know we have unprinted txns from the previous month
                      // - client is not monthly (currently only does 'previous month' checks for monthly clients)
                      if Result and ((ReportMonth = LastMonth) or UnprintedLastMonth or (TempClient.clFields.clReporting_Period <> roSendEveryMonth)) then
                        exit;
                    end;
                 end
                 // txn date is not within report range, so check to see if it
                 // is unprinted from last month
                 // - only applies for NEW txn setting for monthly clients
                 // - txn date is greater than the previous month last date and less than actual report start date
                 // - check out clients include all txn anyway so this is irrelevant for them
                 // - its not an unpresented item
                 else if (not RptPrintAllForThisClient) and (TempClient.clFields.clReporting_Period = roSendEveryMonth) and
                         (txDate_Effective > LastDateForPrevMonthTest) and (txDate_Effective < RptStartDate) and
                         (not (txUPI_State in [upUPC, upUPD, upUPW])) and
                         (not TempClient.clFields.clCheckOut_Scheduled_Reports) and
                         (not TempClient.clExtra.ceOnline_Scheduled_Reports) then // are there some old unprinted txs
                 begin
                   TxIsIncluded := False;
                   case TempClient.clFields.clScheduled_Coding_Report_Entry_Selection of
                        esAllEntries  : TxIsIncluded := True;
                        esUncodedOnly : TxIsIncluded := BkUtil32.IsUncoded( TempClient, Transaction_At( T));
                   end;
                   if TxIsIncluded then
                   begin
                     // Work out the earliest date of an unprinted txn
                     if (txDate_Effective < EarliestDate) or (EarliestDate = 0) then
                       EarliestDate := txDate_Effective;
                     UnprintedLastMonth := True;
                     Result := True;
                   end;                                 
                 end;
              end;
           end;
         end;
       end;
     Finally
       TempClient.Free;
       TempClient := NIL;
     end;
  finally
     if DebugMe and Result then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Result=True' );
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function FlagClientsWithReportsDue( Options : TSchReportOptions; ClientsList : TStringList; var UnprintedLastMonth: Boolean) : Longint;
// Parameters:
// Options  : list of scheduled report options such as range parameters
//          : Clients list.  A TStringList of all the client codes.  If reports are due for a client
//                           the object value for an item will be set to 1, else 0
//
// used by:  Print Scheduled Reports
//
// calls ScheduledReportsDue function to set flag.  This may result in the
// clients file having to be opened.  Determine if client file is in selected
// range before trying to open it.
//
// Note: Scheduled Reports Due function reloads the admin system
const
   ThisMethodName = 'FlagClientsWithReportsDue';
Var
   i      : longint;
   FCount : longint;
   ClientInRange : boolean;
   pUser         : pUser_Rec;
   pGroup        : pGroup_Rec;
   pClientType   : pClient_Type_Rec;
   fKey1, fKey2  : string[10];  //filter key1/2 from/to
   pSysClient    : pClient_File_Rec;
   EarliestDate  : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   FCount := 0;

   fKey1 := Options.srFromCode;
   fKey2 := Options.srToCode + 'þ';

   try
    EarliestDate := 0;
    for i := 0 to (ClientsList.Count - 1) do begin
      if ClientsList.Count > 50 then
        UpdateAppStatus( 'Processing Scheduled Reports Clients...',ClientsList.Strings[ i],(i/ClientsList.Count)*100);
      pSysClient := AdminSystem.fdSystem_Client_File_List.FindCode( ClientsList.Strings[ i]);
      if Assigned( pSysClient) then begin
         with pSysClient^ Do begin
            //----------------------------
            //determine if the client is in the selected range, ie by staff member or client
            if ( Options.srFromCode = '') and ( Options.srToCode = '') and (Options.srCodeSelection.Count = 0) then
               ClientInRange := true  //no filter applied
            else
            begin
              case AdminSystem.fdFields.fdSort_Reports_By of
                srsoStaffMember:
                  begin
                    //get staff member code for this client
                    pUser := AdminSystem.fdSystem_User_List.FindLRN( cfUser_Responsible);
                    if Assigned( pUser) then begin
                       if (Options.srCodeSelection.Count > 0) then
                         ClientInRange := Options.srCodeSelection.IndexOf(pUser.usCode) > -1
                       else
                         ClientInRange := ( pUser^.usCode >= fKey1) and ( pUser^.usCode <= fKey2);
                    end
                    else begin
                       //only include unallocated clients if the To Code is blank, or if selected
                       ClientInRange := ( Options.srToCode = '') and
                           ((Options.srCodeSelection.Count = 0) or (Options.srCodeSelection.IndexOf(' ') > -1));
                    end;
                  end;
                srsoGroup:
                  begin
                    pGroup := AdminSystem.fdSystem_Group_List.FindLRN(cfGroup_LRN);
                    if Assigned(pGroup) then
                       ClientInRange := ItemInRange(AdminSystem.fdFields.fdSort_Reports_Option, fKey1, fKey2, Options.srCodeSelection, UpperCase(pGroup^.grName))
                    else
                      ClientInRange := UseUnAllocated(AdminSystem.fdFields.fdSort_Reports_Option, fKey2, Options.srCodeSelection);
                  end;
                srsoClientType:
                  begin
                    pClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(cfClient_Type_LRN);
                    if Assigned(pClientType) then
                      ClientInRange := ItemInRange(AdminSystem.fdFields.fdSort_Reports_Option, fKey1, fKey2, Options.srCodeSelection, UpperCase(pClientType^.ctName))
                    else
                      ClientInRange := UseUnAllocated(AdminSystem.fdFields.fdSort_Reports_Option, fKey2, Options.srCodeSelection);
                  end
                else //default of Client
                begin
                  //see if client code is in range
                  if Options.srCodeSelection.Count > 0 then
                    ClientInRange := Options.srCodeSelection.IndexOf(cfFile_Code) > -1
                  else
                    ClientInRange := ( cfFile_Code >= fKey1) and ( cfFile_Code <= fKey2);
                end;
              end;
            end;
            //------------------------------

            //only see if reports are due for clients which are in the selected range
            if ClientInRange then
              if ScheduledReportsDue( pSysClient, Options, UnPrintedLastMonth, EarliestDate) then begin //<<-- will update admin system
                if UnprintedLastMonth then
                  ClientsList.Objects[ i] := TObject( 2) //flagged true and has some from last month
                else
                  ClientsList.Objects[ i] := TObject( 1); //flagged true
                Inc( FCount);
              end;

         end // with pSysClient
      end;
    end;
    if ((EarliestDate < AdminSystem.fdFields.fdPrint_Reports_From) or (AdminSystem.fdFields.fdPrint_Reports_From = 0)) and
        LoadAdminSystem(true, ThisMethodName + ThisMethodName) then
    begin // Reset printing from date if we have txns from last month in order to include them
      AdminSystem.fdFields.fdPrint_Reports_From := EarliestDate;
      SaveAdminSystem;
    end;
   finally
     ClearStatus;
     ResetProcessWorkingSet;
     Application.BringToFront;
     Application.ProcessMessages;
   end;
   Result := FCount;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoScheduledReportsForClient(const OutputDest: TReportDest; var srOptions : TSchReportOptions) : Boolean;
//
// OutputDest = rdScreen    [ Preview button pressed ]
// OutputDest = rdPrinter   [ Print button pressed ]
//
// Actually generates the relevant reports.  The reports are generated for the
// global MyClient object.
// Returns true if all due reports were printed for the client

// used by :  Process Client
const
   ThisMethodName = 'DoScheduledReportsForClient';
Var
  ClientDest : TReportDest;
  EmailInfo : TClientEmailInfo;
  RptPeriodToUse : byte;
  pCF : pClient_File_Rec;
  LastAddedMail: Integer;

  function GetOutputDest: TReportDest;
  begin
     if OutputDest in [rdScreen, rdNone, rdAsk] then
        Result := rdScreen
     else
        Result :=  ClientDest;
  end;

begin { DoScheduledReportsForClient }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Assert( OutputDest in [ rdPrinter, rdScreen ] );

   result := false;
   LastAddedMail := -1;
   if (not (Assigned(MyClient) and Assigned(AdminSystem))) or
      StatusFrm.Status_Cancel_Pressed then begin
      exit
   end;

   With MyClient, clFields, AdminSystem.fdFields Do
   Begin
      //make sure something is selected for this client
      if not (clSend_Coding_Report or clSend_Chart_of_Accounts
              or clSend_Payee_List or clExtra.ceSend_Job_List) then begin
         exit;
      end;

      If not ( clReporting_Period in [ roSendEveryMonth .. roSendEveryTwoMonthsMonth ] ) then exit;

      Assert( clECoding_Export_Scheduled_Reports = false,
              'DoScheduledReport called with ECoding Client');

      Assert( clCSV_Export_Scheduled_Reports = false,
              'DoScheduledReport called with CSV Export Client');

      //check if client should be included.  exit if ..
      //1) only email and is not a email client or
      //2) email not included and is an email client

      //This is checked here rather than in the ScheduleReportsDue routine
      //so that we dont have to read ALL clients while checks reports due
      //Better design would be to put Email Scheduled Reports flag into admin
      //client file record!

      If ( clEMail_Scheduled_Reports ) then
         ClientDest := rdEMail
      else
      If ( clFax_Scheduled_Reports ) then
         ClientDest := rdFax
      else
      If ( clCheckOut_Scheduled_Reports ) then
         ClientDest := rdCheckOut
      else
      If ( clExtra.ceOnline_Scheduled_Reports ) then
         ClientDest := rdBankLinkOnline
      else
      If ( clBusiness_Products_Scheduled_Reports ) then
         ClientDest := rdBusinessProduct
      else
         ClientDest := rdPrinter;

      Case ClientDest of
         rdPrinter : If not fdSched_Rep_Include_Printer then exit;
         rdFax     : If not fdSched_Rep_Include_Fax then exit;
         rdEMail   : If not fdSched_Rep_Include_Email then exit;
         rdECoding : if not fdSched_Rep_Include_ECoding then exit;
         rdWebX    : if not fdSched_Rep_Include_WebX then exit;
         rdCheckOut: if not fdSched_Rep_Include_CheckOut then exit;
         rdBankLinkOnline : if not fdSched_Rep_Include_Online then exit;
         rdBusinessProduct: if not fdSched_Rep_Include_Business_Products then exit;
      end;

      // set the reporting period dates
      pCF := AdminSystem.fdSystem_Client_File_List.FindCode( clCode);
      RptPeriodToUse  := GetReportingPeriodToUse( clReporting_Period,
                                                  clReport_Start_Date,
                                                  pCF^.cfLast_Print_Reports_Up_To,
                                                  fdPrint_Reports_Up_To,
                                                  srOptions.srPrintAll );

      srOptions.srTrxFromDate := Get_Reporting_Period_Start_Date( fdPrint_Reports_Up_To, RptPeriodToUse );
      srOptions.srDisplayFromDate := Get_Reporting_Period_Start_Date( fdPrint_Reports_Up_To, RptPeriodToUse );
      srOptions.srTrxToDate   := fdPrint_Reports_Up_To;
      //the only time that the reporting period will be different is when it has been
      //overriden by Get Reporting Period To Use, this will happen if the period is MMQ or MQ
      srOptions.srPrintAllForThisClient := srOptions.srPrintAll or ( RptPeriodToUse <> clReporting_Period);
      if not srOptions.srPrintAllForThisClient then
         UpdateSRStartDate(MyClient, srOptions);

      if DebugMe then begin
         LogUtil.LogMsg( lmDebug, UnitName, 'Printing Schd Reports from ' +
                                            bkDate2Str( srOptions.srTrxFromDate ) +
                                            ' to ' +
                                            bkDate2Str( srOptions.srTrxToDate))
      end;


      //check to see if this is an email client, if it is then redirect the output
      //to email IF current destination is printer, otherwise use current destination

      if GetOutputDest in [rdEMail, rdCheckOut, rdBankLinkOnline, rdBusinessProduct{, dECoding}] then
      Begin
         //Create an email info record for this client.  It will be used later when the
         //emails are actually begin sent.
         EmailInfo := TClientEmailInfo.Create;
         with EmailInfo do
         begin
            EmailInfo.DateFrom := srOptions.srTrxFromDate;
            EmailInfo.DateTo   := srOptions.srTrxToDate;
            EmailType          := EMAIL_MESSAGE;
            ClientCode         := clCode;
            EmailAddress       := Trim( clClient_EMail_Address);
            CCEmailAddress     := Trim( clClient_CC_EMail_Address);
            ECodingFilename    := '';
            ClientMessage      := MyClient.clFields.clScheduled_Client_Note_Message;
            AttachmentList     := MyClient.clFields.clScheduled_File_Attachments;
         end;
         LastAddedMail := EmailList.Add( EmailInfo);
         //change the destination to email for specified reports
      end else
         Emailinfo := nil;

      //------------------------------------------------------------------------
      //                Do all the Output actions
      //------------------------------------------------------------------------

      //**********************   Printed Header page  **************************
      //Only print if we go to the printer, not the Preview
      if (GetOutputDest = rdPrinter)
      and fdPrint_Client_Header_Page then
         DoScheduledReport(REPORT_CLIENT_HEADER, GetOutputDest, srOptions);

      if StatusFrm.Status_Cancel_Pressed then
         exit;

      if GetOutputDest = rdFax then begin
         // The syquence is a bit different, so the Fax header page  is send first.
         if clSend_Coding_Report then begin
            Result := DoScheduledFax( REPORT_CODING, ClientDest, srOptions);
            if not result then begin
               Inc(FaxErrors);
               // Add error summary entry
               AddSummaryRec(clCode, srOptions, ClientDest, False);
               Exit;
            end;
         end;
      end;

      if StatusFrm.Status_Cancel_Pressed then
         exit;

      //********************** Client Custom Document  *************************
      if clextra.ceSend_Custom_Documents
      and (clextra.ceSend_Custom_Documents_List[1] > '') then begin
         srOptions.srCustomDocGUID := clextra.ceSend_Custom_Documents_List[1];
         if DoScheduledReport(REPORT_CUSTOM_DOCUMENT, GetOutputDest, srOptions) then begin
            if assigned(Emailinfo) then
               EmailInfo.AddAttachment(srOptions.srAttachment)
         end else
            AddSummaryRec(clCode, srOptions, ClientDest, False, CUSTOM_DOCUMENT);
      end;


      //****************** Destination Custom Document  ************************
      case ClientDest of
         rdFax: if Boolean(AdminSystem.fdFields.fdSched_Rep_Fax_Custom_Doc)
                and (AdminSystem.fdFields.fdSched_Rep_Fax_Custom_Doc_GUID > '') then begin
                    srOptions.srCustomDocGUID := AdminSystem.fdFields.fdSched_Rep_Fax_Custom_Doc_GUID;
                    if not DoScheduledReport(REPORT_CUSTOM_DOCUMENT, GetOutputDest, srOptions) then
                       AddSummaryRec(clCode, srOptions, ClientDest, False, CUSTOM_DOCUMENT);
                end;
         rdPrinter : if Boolean(AdminSystem.fdFields.fdSched_Rep_Print_Custom_Doc)
                and (AdminSystem.fdFields.fdSched_Rep_Print_Custom_Doc_GUID > '') then begin
                    srOptions.srCustomDocGUID := AdminSystem.fdFields.fdSched_Rep_Print_Custom_Doc_GUID;
                    if not DoScheduledReport(REPORT_CUSTOM_DOCUMENT, GetOutputDest, srOptions) then
                       AddSummaryRec(clCode, srOptions, ClientDest, False, CUSTOM_DOCUMENT);
                end;
         rdEMail : if Boolean(AdminSystem.fdFields.fdSched_Rep_Email_Custom_Doc)
                and (AdminSystem.fdFields.fdSched_Rep_Email_Custom_Doc_GUID > '') then begin
                    srOptions.srCustomDocGUID := AdminSystem.fdFields.fdSched_Rep_Email_Custom_Doc_GUID;
                    if DoScheduledReport(REPORT_CUSTOM_DOCUMENT, GetOutputDest, srOptions) then begin
                       if assigned(Emailinfo) then
                         EmailInfo.AddAttachment(srOptions.srAttachment)
                    end else
                       AddSummaryRec(clCode, srOptions, ClientDest, False, CUSTOM_DOCUMENT);
                end;
         //rdECoding :  handled separate
         //rdCheckOut:
      end;

      If StatusFrm.Status_Cancel_Pressed then
           exit;

      if GetOutputDest = rdFax then begin
         // Finish of the fax bits
         if (clSend_Chart_of_Accounts)
         and (clChart.ItemCount > 0) then
            DoScheduledFax(REPORT_LIST_CHART, ClientDest, srOptions);

         If StatusFrm.Status_Cancel_Pressed then
           exit;

         if (clSend_Payee_List)
         and (clPayee_List.ItemCount > 0) then
            DoScheduledFax( REPORT_LIST_PAYEE, ClientDest, srOptions);

         if (clExtra.ceSend_Job_List)
         and (clJobs.ItemCount > 0) then
            DoScheduledFax( REPORT_LIST_JOBS, ClientDest, srOptions);

      end else begin
        // Do the Non Fax Bits
        // First actula have to do the coding report
        if clSend_Coding_Report then begin
          Result := DoScheduledReport(REPORT_CODING, GetOutputDest, srOptions);
          if not result then
          begin // #1817 - do not email if it failed
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : Failed to generate scheduled report for ' + clCode);
            if LastAddedMail <> - 1 then
              EMailList.Delete(LastAddedMail);
            Exit;
          end;
        end;

        if StatusFrm.Status_Cancel_Pressed then
          exit;

        if (clSend_Chart_of_Accounts)
        and (clChart.ItemCount > 0) then
           DoScheduledReport(REPORT_LIST_CHART, GetOutputDest, srOptions);

        if StatusFrm.Status_Cancel_Pressed then
          exit;

        if (clSend_Payee_List) and (clPayee_List.ItemCount > 0) then
            DoScheduledReport( REPORT_LIST_PAYEE, GetOutputDest, srOptions);

        if (clExtra.ceSend_Job_List) and (clJobs.ItemCount > 0) then
            DoScheduledReport( REPORT_LIST_JOBS, GetOutputDest, srOptions);

      end;


   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end; { DoScheduledReportsForClient }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ReplaceQuotesAndCommas( sOrig : ShortString) : ShortString;
//replaces double quotes with space and commas with fullstop
var
  i : integer;
begin
  for i := 1 to length( sOrig) do
  begin
    if (sOrig[i] = '"') then
      sOrig[i] := ' '
    else if ( sOrig[i] = ',') then
      sOrig[i] := '.';
  end;
  result := sOrig;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 (*
function DoExportScheduledToCSV(const aClient : TClientObj; const OutputDest: TReportDest; var srOptions : TSchReportOptions) : boolean;
//if called with Dest = rdScreen then reports will be previewed,
//otherwise CSV file will be created
//assume that export directory will have been created and verified by now
const
  ThisMethodName = 'DoExportScheduledToCSV';
var
  CSVFile          : TextFile;
  CSVBuffer        : array[ 1..8192 ] of Byte;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  function IncludeThisAccount( BA : TBank_Account) : boolean;
  begin
    result := ( BA.baFields.baAccount_Type in [btBank]);
  end;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  procedure CSVWrite( aAccountNo        : ShortString;
                     aEffDate           : integer;
                     aTransType         : byte;
                     aReference         : ShortString;
                     aAnalysis          : ShortString;
                     aAmount            : Money;
                     aOtherParty        : ShortString;
                     aParticulars       : ShortString;
                     aGSTAmount         : Money;
                     aGSTClass          : integer;
                     aQuantity          : Money;
                     aCode              : ShortString;
                     aNarration         : ShortString;
                     aContraCode        : ShortString;
                     aClientCode        : ShortString;
                     var CurrentBalance : Money);
  begin
    Write( CSVFile, '"',aAccountNo,         '",');
    Write( CSVFile, '"',bkDateUtils.Date2Str( aEffDate, 'dd/mm/yyyy'), '",');
    Write( CSVFile, '"',aTransType,         '",');
    Write( CSVFile, '"',ReplaceQuotesAndCommas( aReference),         '",');
    Write( CSVFile, '"',ReplaceQuotesAndCommas( aAnalysis),          '",');
    Write( CSVFile, '"',FormatFloat('0.00', aAmount/ 100),       '",');
    Write( CSVFile, '"',ReplaceQuotesAndCommas( aOtherParty),        '",');
    Write( CSVFile, '"',ReplaceQuotesAndCommas( aParticulars),       '",');
    with MyClient.clFields do
    begin { Convert our internal representation into the code }
      if ( aGSTClass in [ 1..MAX_GST_CLASS ] ) then
      Begin
        write( CSVFile, '"',FormatFloat('0.00', aGSTAmount/ 100),'",' );
        write( CSVFile, '"',clGST_Class_Codes[ aGSTClass] , '",' );
      end
      else
      begin
        write( CSVFile,   '"0.00",' ); { No GST Class }
        write( CSVFile, '"",' ); { No GST Amount }
      end;
    end;
    Write( CSVFile, '"',FormatFloat('0.0000', aQuantity/10000), '",');
    Write( CSVFile, '"',aCode,              '",');
    Write( CSVFile, '"',ReplaceQuotesAndCommas( aNarration),         '",');
    Write( CSVFile, '"',aContraCode,        '",');
    Write( CSVFile, '"',aClientCode,        '",');
    //write out the running balance
    if CurrentBalance <> Unknown then
    begin
      CurrentBalance := CurrentBalance + aAmount;
      Write( CSVFile, '"', FormatFloat('0.00', CurrentBalance / 100), '"');
    end
    else
      Write( CSVFile, '"0.00"');

    Writeln( CSVFile);
  end;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
var
  acNo             : integer;
  BA               : TBank_Account;
  AdminBA          : pSystem_Bank_Account_Rec;
  T                : pTransaction_Rec;
  TNo              : integer;
  D                : pDissection_Rec;
  FirstT           : pTransaction_Rec;

  CSVFilename      : string;
  CSVExportPath    : string;
  CreateNewFile    : boolean;

  NewSummaryRec    : pSchdRepSummaryRec;
  FirstSummaryRec  : pSchdRepSummaryRec;
  AccountsFound    : integer;
  AccountsExported : integer;
  FirstEntryDate   : integer;
  LastEntryDate    : integer;
  EntriesCount     : integer;
  EntriesForThisAccount : integer;
  TransTotal       : Money;
  CurrLineBal      : Money;
  LastDate         : Integer;
  aMsg             : string;

  FirstEntryDateForClient : integer;
  LastEntryDateForClient  : integer;

  SkipTransaction  : boolean;
  RptPeriodToUse   : byte;
  pCF : pClient_File_Rec;
begin
  result := false;
  Assert( OutputDest in [ rdPrinter, rdScreen ], 'ExportToCSV.OutputDest in [ rdPrinter, rdScreen ]');
  if (not (Assigned( aClient) and Assigned(AdminSystem))) or StatusFrm.Status_Cancel_Pressed then
  begin
     exit
  end;

  With aClient, clFields, AdminSystem.fdFields Do
  Begin
    if not fdSched_Rep_Include_CSV_Export then
      exit;
    If not ( clReporting_Period in [ roSendEveryMonth .. roSendEveryTwoMonthsMonth ] ) then
      exit;

    // set the reporting period dates
    pCF := AdminSystem.fdSystem_Client_File_List.FindCode( clCode);
    RptPeriodToUse := GetReportingPeriodToUse( clReporting_Period,
                                               clReport_Start_Date,
                                               pCF^.cfLast_Print_Reports_Up_To,
                                               fdPrint_Reports_Up_To,
                                               srOptions.srPrintAll);

    srOptions.srTrxFromDate := Get_Reporting_Period_Start_Date( fdPrint_Reports_Up_To, RptPeriodToUse );
    srOptions.srDisplayFromDate := Get_Reporting_Period_Start_Date( fdPrint_Reports_Up_To, RptPeriodToUse );
    srOptions.srTrxToDate   := fdPrint_Reports_Up_To;
    //the only time that the reporting period will be different is when it has been
    //overriden by Get Reporting Period To Use, this will happen if the period is MMQ or MQ
    srOptions.srPrintAllForThisClient := srOptions.srPrintAll or ( RptPeriodToUse <> clReporting_Period);
    if not srOptions.srPrintAllForThisClient then
       UpdateSRStartDate(AClient, srOptions);

    if DebugMe then
    begin
       LogUtil.LogMsg( lmDebug, UnitName, 'Exporting to CSV file from ' +
                                          bkDate2Str( srOptions.srTrxFromDate) +
                                          ' to ' +
                                          bkDate2Str( srOptions.srTrxToDate) +
                                          ' for ' + clCode);
    end;

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // For a Preview, set the ClientDest to rdScreen }
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    If ( OutputDest <> rdPrinter ) then
    begin
      DoScheduledReport(REPORT_CODING, rdScreen, srOptions);

      If StatusFrm.Status_Cancel_Pressed then
      begin
        Exit;
      end;
    end
    else
    begin
       //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       //                BEGIN EXPORTING TO CSV EXPORT FILE
       //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       //construct csv filename
       //CSVExportPath := Trim(fdCSV_Export_Path);
       if CSVExportPath = '' then
         CSVExportPath := Globals.CSVExportDefaultDir;

       CSVFilename := '';
       if fdCSV_Export_Type = 0 then  //combined file
       begin
         //export to combined file, file name is practice code
         CSVFileName := CSVExportPath + fdBankLink_Code + '.csv';
         //see if file exists, if already there then will add to
         CreateNewFile  := not BKFileExists( CSVFilename);
       end
       else
       begin
         //export to individual file, file name is client code
         CSVFilename    := CSVExportPath + clCode + '.csv';
         CreateNewFile  := true;
       end;

       try
         AssignFile( CSVFile, CSVFilename);
         SetTextBuf( CSVFile, CSVBuffer );
         if CreateNewFile then
         begin
           Rewrite( CSVFile );
           Writeln( CSVFile, '"Account Number","Date","Type","Reference",' +
                             '"Analysis","Amount","Other Party","Particulars",'+
                             '"GST Amount","GST Class","Quantity","Code",'+
                             '"Narration","Contra","ClientCode","Closing Balance"' );
         end
         else
         begin
           Append( CSVFile);
         end;

         try
           // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
           //write transactions out to file
           AccountsFound       := 0;
           AccountsExported    := 0;
           EntriesCount        := 0;
           FirstSummaryRec     := nil;
           FirstEntryDateForClient := MaxInt;
           LastEntryDateForClient  := 0;

           //export for each bank account
           for acNo := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
           begin
             BA := aClient.clBank_Account_List.Bank_Account_At(acNo);
             //auto code all entries before exporting
             AutoCode32.AutoCodeEntries( aClient, BA, AllEntries, srOptions.srTrxFromDate, srOptions.srTrxToDate);

             FirstEntryDate := MaxInt;
             LastEntryDate  := 0;
             EntriesForThisAccount := 0;            

             if IncludeThisAccount( BA) then
             begin
               BA.baFields.baTemp_Include_In_Scheduled_Coding_Report := False;
               BA.baFields.baTemp_New_Date_Last_Trx_Printed          := 0;  //this value is written back
                                                                            //to admin in ProcessClient()
               AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( BA.BaFields.baBank_Account_Number);
               if Assigned( AdminBA) then
               begin
                 Inc( AccountsFound);                 

                 if srOptions.srPrintAllForThisClient then
                   BA.baFields.baTemp_Date_Of_Last_Trx_Printed := 0
                 else
                 begin
                   LastDate := ClientUtils.GetLastPrintedDate(aClient.clFields.clCode, AdminBA.sbLRN);
                   if LastDate = 0 then
                     BA.baFields.baTemp_Date_Of_Last_Trx_Printed := IncDate(srOptions.srDisplayFromDate, -1, 0, 0)
                   else if GetMonthsBetween(LastDate, srOptions.srDisplayFromDate) > 1 then
                     BA.baFields.baTemp_Date_Of_Last_Trx_Printed := IncDate(GetFirstDayOfMonth(IncDate(srOptions.srDisplayFromDate, 0, -1, 0)), -1, 0, 0)
                   else
                     BA.baFields.baTemp_Date_Of_Last_Trx_Printed := LastDate;
                 end;
               end
               else
               begin
                 //account cannot be found in admin, see date so nothing exported
                 BA.baFields.baTemp_Date_Of_Last_Trx_Printed := MaxInt;
               end;

               //Find the first transaction that will be printed and
               //calculate the closing balance of the account prior to that transaction
               CurrLineBal := Unknown;
               FirstT      := nil;
               TransTotal  := 0;
               if BA.baFields.baCurrent_Balance <> Unknown then
               begin
                 for TNo := Ba.baTransaction_List.First to BA.baTransaction_List.Last do
                 begin
                   T := BA.baTransaction_List.Transaction_At( TNo);
                   //see if transaction is outside date range or earlier than last printed date
                   if ( ( T.txDate_Effective >= srOptions.srTrxFromDate) and
                        ( T.txDate_Effective <= srOptions.srTrxToDate) and
                        ( T.txDate_Effective > BA.baFields.baTemp_Date_Of_Last_Trx_Printed) and
                        (not IsUPCFromPreviousMonth(T.txDate_Effective, T.txUPI_State, srOptions.srDisplayFromDate))) then
                   begin
                     //transaction list is sorted in effect date or so first entry found
                     //will be the first to print
                     FirstT := T;
                   end;

                   //if we have found the starting point then add up transaction
                   //amounts from this point on
                   if Assigned( FirstT) then
                     TransTotal := TransTotal + T^.txAmount;
                 end;
                 //the balance prior to the first transaction will be
                 //the closing balance less the total above
                 CurrLineBal := Ba.baFields.baCurrent_Balance - TransTotal;
               end;

               //NOW begin exporting transactions
               for TNo := Ba.baTransaction_List.First to BA.baTransaction_List.Last do
               begin
                 T := BA.baTransaction_List.Transaction_At( TNo);
                 SkipTransaction := False;

                 //see if transaction is outside date range or earlier than last printed date
                 if ( ( T.txDate_Effective >= srOptions.srTrxFromDate) and
                      ( T.txDate_Effective <= srOptions.srTrxToDate) and
                      ( T.txDate_Effective > BA.baFields.baTemp_Date_Of_Last_Trx_Printed) and
                       (not IsUPCFromPreviousMonth(T.txDate_Effective, T.txUPI_State, srOptions.srDisplayFromDate))) then
                 begin
                   //transaction is in range
                   if T.txDate_Effective < FirstEntryDate then
                     FirstEntryDate := T.txDate_Effective;

                   if T.txDate_Effective > LastEntryDate then
                     LastEntryDate  := T.txDate_Effective;

                   BA.baFields.baTemp_New_Date_Last_Trx_Printed := T.txDate_Effective;
                   BA.baFields.baTemp_Include_In_Scheduled_Coding_Report := True;
                 end
                 else
                 begin
                   //transaction is out of range
                   SkipTransaction := True;
                 end;

                 if not SkipTransaction then
                 begin
                   if T^.txFirst_Dissection = nil then
                   begin
                     //export transaction
                     CSVWrite( BA.baFields.baBank_Account_Number,
                               T^.txDate_Effective,
                               T^.txType,
                               T^.txReference,
                               T^.txAnalysis,
                               T^.txAmount,
                               T^.txOther_Party,
                               T^.txParticulars,
                               T^.txGST_Amount,
                               T^.txGST_Class,
                               T^.txQuantity,
                               T^.txAccount,
                               T^.txGL_Narration,
                               BA.baFields.baContra_Account_Code,
                               aClient.clFields.clCode,
                               CurrLineBal);
                   end
                   else
                   begin
                     //transaction is dissected, export each line of the dissectin
                     D := T^.txFirst_Dissection;
                     while ( D <> nil) do
                     begin
                       CSVWrite( BA.baFields.baBank_Account_Number,
                                 T^.txDate_Effective,
                                 T^.txType,
                                 T^.txReference,
                                 T^.txAnalysis,
                                 D^.dsAmount,
                                 T^.txOther_Party,
                                 T^.txParticulars,
                                 D^.dsGST_Amount,
                                 D^.dsGST_Class,
                                 D^.dsQuantity,
                                 D^.dsAccount,
                                 D^.dsGL_Narration,
                                 BA.baFields.baContra_Account_Code,
                                 aClient.clFields.clCode,
                                 CurrLineBal);
                       D := D^.dsNext;
                     end;
                   end;
                   Inc( EntriesCount);
                   Inc( EntriesForThisAccount);
                 end;
               end; //for each transaction

               //need to add summary account info for each account printed
               if (EntriesForThisAccount > 0) and (srOptions.srSummaryInfoList <> nil) then
               begin
                 Inc( AccountsExported);
                 GetMem( NewSummaryRec, SizeOf( TSchdRepSummaryRec));
                 with NewSummaryRec^ do
                 begin
                   ClientCode     := aClient.clFields.clCode;
                   AccountNo      := BA.baFields.baBank_Account_Number;
                   PrintedFrom    := FirstEntryDate;
                   PrintedTo      := LastEntryDate;

                   AcctsPrinted   := 0;  //these will be filled at the end
                   AcctsFound     := 0;

                   UserResponsible := 0;  //will be filled in during summary report
                   TxLastMonth    := False;
                   Completed      := True;
                 end;
                 srOptions.srSummaryInfoList.Add( NewSummaryRec);

                 if FirstSummaryRec = nil then
                 begin
                   FirstSummaryRec := NewSummaryRec;
                 end;

                 if FirstEntryDate < FirstEntryDateForClient then
                   FirstEntryDateForClient := FirstEntryDate;

                 if LastEntryDate > LastEntryDateForClient then
                   LastEntryDateForClient  := LastEntryDate;
               end;
             end;
           end; //for each bank account

           //now update first rec details
           if Assigned( FirstSummaryRec) then
           begin
             FirstSummaryRec.AcctsPrinted := AccountsExported;
             FirstSummaryRec.AcctsFound   := AccountsFound;
             FirstSummaryRec.SendBy       := rdCSVExport;
             result := True;
           end;
         finally
           CloseFile( CSVFile);
         end;
         //file written ok
         Result := True;
       except
         on E : Exception do
         begin
           LogUtil.LogError( unitname, 'Export failed for ' + clCode + ' to ' +
                             CSVFilename + ' [' + E.Message + ']');
           exit;
         end;
       end;

       if Result then
       begin
         aMsg := 'Exported entries for ' + clCode + ' to ' + CSVFilename + ' ' +
                inttostr( EntriesCount) + ' entries ';

         if EntriesCount > 0 then
           aMsg := aMsg + 'from ' + bkDate2Str( FirstEntryDateForClient) +
                          ' to ' + bkDate2Str( LastEntryDateForClient);

         LogUtil.LogMsg( lmInfo, unitname, aMsg);
       end;
    end; //if exporting
  end;  // with aClient, adminsystem...
end;
*)
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoExportScheduledCheckOutFile(const aClient : TClientObj; const OutputDest: TReportDest;
  var srOptions : TSchReportOptions) : boolean;
//if called with Dest = rdScreen then reports will be previewed,
//otherwise checkout

const
  ThisMethodName = 'DoExportScheduledCheckOutFile';
Var
  EmailInfo : TClientEmailInfo;
  BA: TBank_Account;
  T: pTransaction_Rec;
  Included: Boolean;
  i, j, AcctsPrinted, AcctsTotal: Integer;
  NewSummaryRec, FirstSummaryRec: pSchdRepSummaryRec;
  pCF: pClient_File_Rec;
  RptPeriodToUse: byte;
  User: Integer;
begin
  Assert( OutputDest in [ rdPrinter, rdScreen ], 'DoExportScheduledCheckOutFile.OutputDest in [ rdPrinter, rdScreen ]');
  Result := False;
  FirstSummaryRec := nil;
  pCF := AdminSystem.fdSystem_Client_File_List.FindCode( aclient.clFields.clCode);
  With aClient, clFields, AdminSystem.fdFields Do
   Begin
      If not ( clReporting_Period in [ roSendEveryMonth .. roSendEveryTwoMonthsMonth ] ) then exit;

      // set the reporting period dates
      RptPeriodToUse  := GetReportingPeriodToUse( clReporting_Period,
                                                  clReport_Start_Date,
                                                  pCF^.cfLast_Print_Reports_Up_To,
                                                  fdPrint_Reports_Up_To,
                                                  srOptions.srPrintAll);
      User := pCF^.cfUser_Responsible;

      srOptions.srTrxFromDate := Get_Reporting_Period_Start_Date( fdPrint_Reports_Up_To, RptPeriodToUse );
      srOptions.srDisplayFromDate := Get_Reporting_Period_Start_Date( fdPrint_Reports_Up_To, RptPeriodToUse );
      srOptions.srTrxToDate   := fdPrint_Reports_Up_To;
      //the only time that the reporting period will be different is when it has been
      //overriden by Get Reporting Period To Use, this will happen if the period is MMQ or MQ
      srOptions.srPrintAllForThisClient := srOptions.srPrintAll or ( RptPeriodToUse <> clReporting_Period);
      if not srOptions.srPrintAllForThisClient then
         UpdateSRStartDate(AClient, srOptions);

      if DebugMe then begin
         LogUtil.LogMsg( lmDebug, UnitName, 'CheckOut file from ' +
                                            bkDate2Str( srOptions.srTrxFromDate ) +
                                            ' to ' +
                                            bkDate2Str( srOptions.srTrxToDate))
      end;
  end;
  If ( OutputDest <> rdPrinter ) then
  begin
     //previewing reports for client
    if pCF.cfFile_Password <> '' then
    begin
      for i := 0 to Pred(aClient.clBank_Account_List.ItemCount) do
      begin
        BA := aClient.clBank_Account_List.Bank_Account_At(i);
        if BA.baFields.baAccount_Type <> btBank then Continue;
        GetMem( NewSummaryRec, SizeOf( TSchdRepSummaryRec));
        with NewSummaryRec^ do
        begin
          ClientCode     := aClient.clFields.clCode;
          AccountNo      := BA.baFields.baBank_Account_Number;
          PrintedFrom    := srOptions.srDisplayFromDate;
          PrintedTo      := srOptions.srTrxToDate;
          AcctsPrinted   := 0;
          AcctsFound     := 0;
          UserResponsible := User;
          if aClient.clFields.clCheckOut_Scheduled_Reports then
            SendBy       := rdCheckOut
          else if aClient.clExtra.ceOnline_Scheduled_Reports then
            SendBy       := rdBankLinkOnline;
          TxLastMonth    := ShowTransLastMonth(aClient, srOptions);
          Completed      := False;
        end;
        if FirstSummaryRec = nil then
          FirstSummaryRec := NewSummaryRec;
        srOptions.srSummaryInfoList.Add( NewSummaryRec);
      end;
      exit;
    end;
    DoScheduledReport(REPORT_CODING, rdScreen, srOptions);
    Result := True;
  end else
  begin // Check out the client file
   try
    //Override cleint file rec send method with client file sceduled report destination
    if aClient.clExtra.ceOnline_Scheduled_Reports then
      pCF.cfFile_Transfer_Method := ftmOnline;

    if SendClient(aClient.clFields.clCode, EMailOutboxDir, pCF.cfFile_Transfer_Method) then
    begin
      IncUsage('Check Out (Scheduled)');
      Result := True;
      // Add email
      EmailInfo := TClientEmailInfo.Create;
      with EmailInfo do
      begin
        if srOptions.srSendViaBankLinkOnline then
          EmailType := EMAIL_BANKLINK_ONLINE
        else
          EmailType := EMAIL_CHECKOUT;

        ClientCode      := aClient.clFields.clCode;
        EmailAddress    := Trim( aClient.clFields.clClient_EMail_Address);
        CCEmailAddress  := Trim( aClient.clFields.clClient_CC_EMail_Address);
        ECodingFilename := aClient.clFields.clCode + FILEEXTN;
        ClientMessage   := aClient.clFields.clScheduled_Client_Note_Message;
        AttachmentList  := aClient.clFields.clScheduled_File_Attachments;
      end;

       // Try the Custom Documents
       if aClient.clextra.ceSend_Custom_Documents
       and (aClient.clextra.ceSend_Custom_Documents_List[1] > '') then begin
          srOptions.srCustomDocGUID := aClient.clextra.ceSend_Custom_Documents_List[1];
          if DoScheduledReport(REPORT_CUSTOM_DOCUMENT, rdEmail, srOptions) then
             EmailInfo.AddAttachment(srOptions.srAttachment)
          else
             AddSummaryRec(aClient.clFields.clCode, srOptions, rdEcoding, False, CUSTOM_DOCUMENT);
       end;

       if Boolean(AdminSystem.fdFields.fdSched_Rep_Books_Custom_Doc)
       and (AdminSystem.fdFields.fdSched_Rep_Books_Custom_Doc_GUID > '') then begin
          srOptions.srCustomDocGUID := AdminSystem.fdFields.fdSched_Rep_Books_Custom_Doc_GUID;
          if DoScheduledReport(REPORT_CUSTOM_DOCUMENT, rdEmail, srOptions) then
             EmailInfo.AddAttachment(srOptions.srAttachment)
          else
             AddSummaryRec(aClient.clFields.clCode, srOptions, rdEcoding, False, CUSTOM_DOCUMENT);
       end;



      EmailList.Add( EmailInfo);
      // Add summary reports
      AcctsPrinted := 0;
      AcctsTotal := 0;
      for i := 0 to Pred(aClient.clBank_Account_List.ItemCount) do
      begin
        Included := False;
        BA := aClient.clBank_Account_List.Bank_Account_At(i);
        if BA.baFields.baAccount_Type <> btBank then Continue;
        for j := BA.baTransaction_List.Last downto BA.baTransaction_List.First do
        begin
          T := BA.baTransaction_List.Transaction_At(j);
          Included := False;
          //see if transaction is outside date range or earlier than last printed date
          if ( ( T.txDate_Effective >= srOptions.srTrxFromDate) and
               ( T.txDate_Effective <= srOptions.srTrxToDate) and
               ( T.txDate_Effective > BA.baFields.baTemp_Date_Of_Last_Trx_Printed) and
                (not IsUPCFromPreviousMonth(T.txDate_Effective, T.txUPI_State, srOptions.srDisplayFromDate))) then
          begin
            Inc(AcctsPrinted);
            Included := True;
            BA.baFields.baTemp_Include_In_Scheduled_Coding_Report := True;
            BA.baFields.baTemp_New_Date_Last_Trx_Printed := T.txDate_Effective;
            Break;
          end;
        end;
        if Included then
        begin
          GetMem( NewSummaryRec, SizeOf( TSchdRepSummaryRec));
          with NewSummaryRec^ do
          begin
            ClientCode     := aClient.clFields.clCode;
            AccountNo      := BA.baFields.baBank_Account_Number;
            PrintedFrom    := srOptions.srDisplayFromDate;
            PrintedTo      := srOptions.srTrxToDate;
            AcctsPrinted   := 0; // changed at end
            AcctsFound     := 0; // changed at end
            UserResponsible := User;
            //SendBy         := rdCheckOut;
            if aClient.clFields.clCheckOut_Scheduled_Reports then
              SendBy       := rdCheckOut
            else if aClient.clExtra.ceOnline_Scheduled_Reports then
              SendBy       := rdBankLinkOnline;
            TxLastMonth    := ShowTransLastMonth(aClient, srOptions);
            Completed      := True;
          end;
          if FirstSummaryRec = nil then
            FirstSummaryRec := NewSummaryRec;
          srOptions.srSummaryInfoList.Add( NewSummaryRec);
        end;
        Inc(AcctsTotal);
      end;
      //now update first rec details
      if Assigned( FirstSummaryRec) then
      begin
        FirstSummaryRec.AcctsPrinted := AcctsPrinted;
        FirstSummaryRec.AcctsFound   := AcctsTotal;
      end;
    end
    else
      Result := False;
   finally
    StatusSilent := False;
   end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoExportScheduledECodingFile(const aClient : TClientObj; const OutputDest: TReportDest;
  var srOptions : TSchReportOptions; const Destination: TReportDest) : boolean;
//if called with Dest = rdScreen then reports will be previewed,
//otherwise Ecoding file will be created

const
  ThisMethodName = 'DoExportScheduledECodingFile';
Var
  EmailInfo : TClientEmailInfo;
  ecFilename       : string;
  eCount           : integer;

  TempSummaryInfoList : TList;
  i                : integer;
  RptPeriodToUse   : byte;
  pCF              : pClient_File_Rec;
  NewSummaryRec: pSchdRepSummaryRec;
  Bank_Account: TBank_Account;
  NextNo: Integer;
  NotifyClient: Boolean;
begin
   Assert( OutputDest in [ rdPrinter, rdScreen ], 'ExportToECoding.OutputDest in [ rdPrinter, rdScreen ]');

   result := false;
   if (not (Assigned( aClient) and Assigned(AdminSystem))) or
      StatusFrm.Status_Cancel_Pressed then begin
      exit
   end;

   With aClient, clFields, AdminSystem.fdFields Do
   Begin
      if (not fdSched_Rep_Include_ECoding) and (Destination = rdECoding) then exit;
      if (not fdSched_Rep_Include_WebX) and (Destination = rdWebX) then exit;
      If not ( clReporting_Period in [ roSendEveryMonth .. roSendEveryTwoMonthsMonth ] ) then exit;

      // set the reporting period dates
      pCF := AdminSystem.fdSystem_Client_File_List.FindCode( clCode);
      RptPeriodToUse  := GetReportingPeriodToUse( clReporting_Period,
                                                  clReport_Start_Date,
                                                  pCF^.cfLast_Print_Reports_Up_To,
                                                  fdPrint_Reports_Up_To,
                                                  srOptions.srPrintAll);

      srOptions.srTrxFromDate := Get_Reporting_Period_Start_Date( fdPrint_Reports_Up_To, RptPeriodToUse );
      srOptions.srDisplayFromDate := Get_Reporting_Period_Start_Date( fdPrint_Reports_Up_To, RptPeriodToUse );
      srOptions.srTrxToDate   := fdPrint_Reports_Up_To;
      //the only time that the reporting period will be different is when it has been
      //overriden by Get Reporting Period To Use, this will happen if the period is MMQ or MQ
      srOptions.srPrintAllForThisClient := srOptions.srPrintAll or ( RptPeriodToUse <> clReporting_Period);

      if not srOptions.srPrintAllForThisClient then
         UpdateSRStartDate(AClient, srOptions);
      if DebugMe then begin
         LogUtil.LogMsg( lmDebug, UnitName, 'Exporting ECoding file from ' +
                                            bkDate2Str( srOptions.srTrxFromDate ) +
                                            ' to ' +
                                            bkDate2Str( srOptions.srTrxToDate))
      end;


      //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      // For a Preview, set the ClientDest to rdScreen }
      //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      If ( OutputDest <> rdPrinter ) then begin
         //previewing reports for client
         clScheduled_Coding_Report_Entry_Selection := clECoding_Entry_Selection;
         clScheduled_Coding_Report_Print_TI        := clECoding_Dont_Show_TaxInvoice;

         DoScheduledReport(REPORT_CODING, rdScreen, srOptions);

         Result := True;

      end else begin
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         //                BEGIN EXPORTING TO ECODING FILE
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

         //construct bnotes file name
         //sort out default filename
         NextNo   := aClient.clFields.clECoding_Last_File_No + 1;
         if Destination = rdWebX then begin
            case aClient.clFields.clWeb_Export_Format of
              wfWebX : ecFilename := WebXOffice.GetWebXDataPath(WEBX_EXPORT_FOLDER) +
                          aClient.clFields.clCode + '_' +
                          inttostr( NextNo) +
                          '.' + WEBX_DEFAULT_EXTN;
              else ecFilename := '';
            end;

         end else
            ecFilename :=  EmailOutBoxDir +  aClient.clFields.clCode + '_' +
                          inttostr( NextNo ) +
                          '.' + glConst.ECODING_DEFAULT_EXTN;

         TempSummaryInfoList := TList.Create;
         try
            try
               if Destination = rdWebX then begin

                 //--------------------  WEBEX --------------------------------

                 // If no format then its an error - log it and fail
                 case aClient.clFields.clWeb_Export_Format of
                 wfNone : begin
                   ecount := 0;
                   // Work out which bank accounts had reports due so we can
                   // report them in the failed section of the reports summary
                   for i := 0 to Pred(aClient.clBank_Account_List.ItemCount) do
                   begin
                     Bank_Account := aClient.clBank_Account_List.Bank_Account_At( i );
                     if (Bank_Account.baFields.baAccount_Type <> btBank) then Continue;
                     if AdminSystem.fdSystem_Bank_Account_List.FindCode(Bank_Account.baFields.baBank_Account_Number ) = nil then Continue;
                     if WebXOffice.IsBankAccountInScheduledReport(aClient, Bank_Account,
                            srOptions.srPrintAllForThisClient, srOptions.srTrxFromDate,
                            srOptions.srTrxToDate, srOptions.srDisplayFromDate) then
                     begin
                       Inc(eCount);
                       GetMem( NewSummaryRec, Sizeof(TSchdRepSummaryRec));
                       with NewSummaryRec^ do begin
                          ClientCode         := aClient.clFields.clCode;
                          AccountNo          := Bank_Account.baFields.baBank_Account_Number;
                          PrintedFrom        := srOptions.srTrxFromDate;
                          PrintedTo          := srOptions.srTrxToDate;
                          AcctsPrinted       := 0;
                          AcctsFound         := 0; // Will be updated at the end once we know!
                          SendBy             := rdWebX;
                          UserResponsible    := 0;
                          TxLastMonth        := ShowTransLastMonth(aClient, srOptions);
                          Completed          := False;
                       end;
                       srOptions.srSummaryInfoList.Add(NewSummaryRec);
                     end;
                   end;
                   // Now update the account count now it is known
                   for i := 0 to Pred(srOptions.srSummaryInfoList.Count) do
                    if pSchdRepSummaryRec(srOptions.srSummaryInfoList[i]).ClientCode = aClient.clFields.clCode then
                      pSchdRepSummaryRec(srOptions.srSummaryInfoList[i]).AcctsFound := eCount;
                   eCount := 0;
                   LogUtil.LogMsg( lmInfo, unitname, 'ERROR Exporting to Web: No Web Export Format is set for client ' +
                    aClient.clFields.clCode + '. The Web Export Format can be set by choosing Accounting System from the Other Functions menu.' );
                 end;

                 wfWebX : begin
                   eCount := WebXOffice.ExportAccount(aClient, AdminSystem, ecFilename,
                                                      srOptions.srTrxFromDate, srOptions.srTrxToDate, nil,
                                                      True, TempSummaryInfoList, srOptions.srPrintAllForThisClient, nil,
                                                      srOptions.srDisplayFromDate);
                    result := eCount > 0;
                  end;

                 wfWebNotes : begin
                    Result := ExportWebNotesFile( aClient,
                                                  srOptions.srTrxFromDate, srOptions.srTrxToDate,
                                                  eCount,
                                                  ecFilename, // EmailMessage
                                                  NotifyClient,
                                                  True, // Is Scheduled
                                                  srOptions.srPrintAllForThisClient,
                                                  TempSummaryInfoList,
                                                  nil,
                                                  srOptions.srDisplayFromDate);
                    end;

                 end;
               end
               else
                 //--------------------  BNotes --------------------------------
                 result := BNotesInterface.GenerateBNotesFile( aClient, ecFilename,
                                                                 srOptions.srTrxFromDate,
                                                                 srOptions.srTrxToDate,
                                                                 eCount,
                                                                 true,
                                                                 AdminSystem,
                                                                 srOptions.srPrintAllForThisClient,
                                                                 TempSummaryInfoList,
                                                                 EncodedLogoString, nil,
                                                                 srOptions.srDisplayFromDate);
            except
               on E : Exception do begin
                  LogUtil.LogError( unitname, 'Generate failed ' + ecFilename +
                                    ' [' + E.Message + ']');
                  exit;
               end;
            end;

            if Result then begin
               LogUtil.LogMsg( lmInfo, unitname, 'Generated ' + ecFilename + ' ' +
                                                 inttostr( eCount) + ' entries');
               Inc( aClient.clFields.clECoding_Last_File_No);

               // WebXOffice will be responsible for emails
               if (Destination = rdECoding)
               or ( (Destination = rdWebX)
                    and (aClient.clFields.clWeb_Export_Format = wfWebNotes)
                    and NotifyClient ) then
               begin
                 //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                 //Create an email info record for this client.  It will be used later when the
                 //emails are actually being sent.

                 EmailInfo := TClientEmailInfo.Create;
                 with EmailInfo do
                 begin

                   ClientCode      := clCode;
                   EmailAddress    := Trim( clClient_EMail_Address);
                   CCEmailAddress  := Trim( clClient_CC_EMail_Address);

                   ClientMessage   := MyClient.clFields.clScheduled_Client_Note_Message;

                   if (Destination = rdWebX)
                   and (aClient.clFields.clWeb_Export_Format = wfWebNotes) then begin
                      EmailType := EMAIL_WEBNOTES;
                      ECodingFilename := '';

                      ClientMessage := ClientMessage + ecFilename; //EmailMessage
                   end else begin
                       EmailType := EMAIL_ECODING;
                       ECodingFilename := ExtractFileName( ecFilename);
                   end;

                   AttachmentList  := MyClient.clFields.clScheduled_File_Attachments;
                   DateFrom        := BkNull2St(srOptions.srTrxFromDate);
                   DateTo          := BkNull2St(srOptions.srTrxToDate);
                 end;
                 EmailList.Add( EmailInfo);
               end else
                 EmailInfo := nil;

               //now that we know the export was succesful we can added the summary items to
               //the main summary list
               for i := 0 to Pred( TempSummaryInfoList.Count) do begin
                  srOptions.srSummaryInfoList.Add( TempSummaryInfoList.Items[ i]);
                  //now set to nil so that is not freed below
                  TempSummaryInfoList.Items[ i] := nil;
               end;

               // Try the Custom Documents
               if Assigned(EmailInfo) then begin

                  if clextra.ceSend_Custom_Documents
                  and (clextra.ceSend_Custom_Documents_List[1] > '') then begin
                     srOptions.srCustomDocGUID := clextra.ceSend_Custom_Documents_List[1];

                     if DoScheduledReport(REPORT_CUSTOM_DOCUMENT, rdEmail, srOptions) then
                        EmailInfo.AddAttachment(srOptions.srAttachment)
                     else
                        AddSummaryRec(clCode, srOptions, rdEcoding, False, CUSTOM_DOCUMENT);
                  end;

                  if (Destination = rdWebX)
                  and (aClient.clFields.clWeb_Export_Format = wfWebNotes) then begin

                     if Boolean(AdminSystem.fdFields.fdSched_Rep_WebNotes_Custom_Doc)
                     and (AdminSystem.fdFields.fdSched_Rep_WebNotes_Custom_Doc_GUID > '') then begin
                        srOptions.srCustomDocGUID := AdminSystem.fdFields.fdSched_Rep_WebNotes_Custom_Doc_GUID;

                        if DoScheduledReport(REPORT_CUSTOM_DOCUMENT, rdEmail, srOptions) then
                           EmailInfo.AddAttachment(srOptions.srAttachment)
                        else
                           AddSummaryRec(clCode, srOptions, rdEcoding, False, CUSTOM_DOCUMENT);
                     end;

                  end else begin
                     // Must be BNotes...
                     if Boolean(AdminSystem.fdFields.fdSched_Rep_Notes_Custom_Doc)
                     and (AdminSystem.fdFields.fdSched_Rep_Notes_Custom_Doc_GUID > '') then begin
                        srOptions.srCustomDocGUID := AdminSystem.fdFields.fdSched_Rep_Notes_Custom_Doc_GUID;

                        if DoScheduledReport(REPORT_CUSTOM_DOCUMENT, rdEmail, srOptions) then
                           EmailInfo.AddAttachment(srOptions.srAttachment)
                        else
                           AddSummaryRec(clCode, srOptions, rdEcoding, False, CUSTOM_DOCUMENT);
                     end;

                  end;
               end;


               //Add Tasks
               if LoadAdminSystem(true, ThisMethodName) then
               begin
                 if Destination = rdWebX then
                    case aClient.clFields.clWeb_Export_Format of
                    wfWebX : AddAutomaticToDoItem( aClient.clFields.clCode,
                                   ttyExportWeb,
                                   Format( ToDoMsg_Acclipse,
                                           [ bkDate2Str( srOptions.srTrxFromDate),
                                             bkDate2Str( srOptions.srTrxToDate),
                                             bkDate2Str(CurrentDate)
                                           ]),
                                   0, NextNo);
                    wfWebNotes : AddAutomaticToDoItem( aClient.clFields.clCode,
                                   ttyExportWeb,
                                   Format( ToDoMsg_Webnotes,
                                           [ bkDate2Str( srOptions.srTrxFromDate),
                                             bkDate2Str( srOptions.srTrxToDate),
                                             bkDate2Str(CurrentDate)
                                           ]),
                                   0, NextNo)
                    end
                  else
                    AddAutomaticToDoItem( aClient.clFields.clCode,
                                   ttyExportBNotes,
                                   Format( ToDoMsg_ManualECoding,
                                           [ bkDate2Str( srOptions.srTrxFromDate),
                                             bkDate2Str( srOptions.srTrxToDate),
                                             bkDate2Str(CurrentDate)
                                           ]),
                                   0, NextNo);
                 SaveAdminSystem();
               end;
            end;
         finally
            //clear all items in summary list
            for i := 0 to Pred( TempSummaryInfoList.Count ) do begin
                if TempSummaryInfoList.Items[ i ] <> nil then begin
                   //dont free mem if have been added to main summary list
                   FreeMem( pSchdRepSummaryRec(TempSummaryInfoList.Items[ i ]), SizeOf(TSchdRepSummaryRec));
                end;
            end;
            TempSummaryInfoList.Free;
         end;
      end;  //if Generating ecoding file...
   end;  // with aClient, adminsystem...
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function ProcessClient(ClientCode: string; Dest: TReportDest; srOptions : TSchReportOptions) : boolean;
// Opens the client file, Synchronises it with the admin system ( so that all transactions
// are retreived), then calls scheduled reports routine which operates on the MyClient file.
//
// used by:  Print Reports by Staff Member, Print Reports by Client
Const
  ThisMethodName = 'ProcessClient';
var
  AdminBA               : pSystem_Bank_Account_Rec;
  i                     : integer;
  AdminUpdateRequired   : boolean;
  ReportsDoneOK         : boolean;
  GeneratingECodingFile : boolean;
  DestString            : string;
  ClientDest            : TReportDest;
  pCFRec                : pClient_File_Rec;
  StartDate             : Integer;
  InvalidEmail          : Boolean;
begin
   if DebugMe then begin
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' begins')
   end;

   Result := false;

   if DebugMe then begin
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Opening Client ' + ClientCode)
   end;
   UpdateAppStatus('Reading Client',ClientCode,0, ProcessMessages_On);

   OpenAClientForRead(ClientCode, MyClient);
   if not Assigned(MyClient) then begin
      exit;
   end;

   pCFRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
   if (pCFRec.cfFile_Status in [fsNormal, fsOpen]) and
        ((not MyClient.clFields.clCheckOut_Scheduled_Reports) or
         (MyClient.clFields.clCheckOut_Scheduled_Reports and (pCFRec.cfFile_Status = fsNormal))) and
        ((not MyClient.clExtra.ceOnline_Scheduled_Reports) or
         (MyClient.clExtra.ceOnline_Scheduled_Reports and (pCFRec.cfFile_Status = fsNormal))) then
   begin
     //initialise client specific values in srOptions
     srOptions.srTrxFromDate := 0;
     srOptions.srTrxToDate   := 0;                 
     srOptions.srPrintAllForThisClient := false;
     srOptions.srSendViaBankLinkOnline := MyClient.clExtra.ceOnline_Scheduled_Reports;

     try
        GeneratingECodingFile := (MyClient.clFields.clECoding_Export_Scheduled_Reports or
                                  MyClient.clFields.clWebX_Export_Scheduled_Reports or
                                  MyClient.clFields.clBusiness_Products_Scheduled_Reports)
                                  and ( Dest = rdPrinter);

        //see if is a normal reports client, or a ecoding client
        if not GeneratingECodingFile then begin
           //---------------------------------------------------------------------
           //merge new data in temp copy of client file
           SyncClientToAdmin(MyClient, true, True, False, True);

           if MyClient.clFields.clECoding_Export_Scheduled_Reports then
             ReportsDoneOK := DoExportScheduledECodingFile( MyClient, Dest, srOptions, rdECoding)
           else
           {if MyClient.clFields.clCSV_Export_Scheduled_Reports then
             ReportsDoneOK := DoExportScheduledToCSV( MyClient, Dest, srOptions)
           else}
           if MyClient.clFields.clWebX_Export_Scheduled_Reports then
             ReportsDoneOK := DoExportScheduledECodingFile( MyClient, Dest, srOptions, rdWebX)
           else
           if MyClient.clFields.clCheckOut_Scheduled_Reports then
             ReportsDoneOK := DoExportScheduledCheckOutFile( MyClient, Dest, srOptions)
           else if MyClient.clExtra.ceOnline_Scheduled_Reports then
             //BankLink Online
             ReportsDoneOK := DoExportScheduledCheckOutFile( MyClient, Dest, srOptions)
           else
             ReportsDoneOK := DoScheduledReportsForClient(Dest, srOptions);

           //---------------------------------------------------------------------
        end
        else begin
           //---------------------------------------------------------------------
           //ecoding clients must be handled differently because the file MUST
           //be saved after the export is done.  Because of this we must RE-OPEN
           //the file normally
           MyClient.Free;
           MyClient := nil;
           BatchReports.XMLString := ''; 

           //now must reopen the client file and update admin
           OpenAClient( ClientCode, MyClient, TRUE);
           if assigned( MyClient) then begin
              //merge new data
              SyncClientToAdmin( MyClient, TRUE, True, False, True);
              //generate eCoding file
              if MyClient.clFields.clWebX_Export_Scheduled_Reports then
                ReportsDoneOK := DoExportScheduledECodingFile( MyClient, Dest, srOptions, rdWebX)
              else if MyClient.clFields.clBusiness_Products_Scheduled_Reports then
                ReportsDoneOK := DoExportScheduledBusinessProduct( MyClient, Dest, srOptions, EmailList)
              else
                ReportsDoneOK := DoExportScheduledECodingFile( MyClient, Dest, srOptions, rdECoding);
              //will close and save the client file
           end
           else begin
             //open the client file readonly so we can access MyClient
             OpenAClientForRead(ClientCode, MyClient);
             if Assigned(MyClient) then
             begin
               try
                 AddSummaryRec(ClientCode, srOptions, Dest, False);
               finally
                 MyClient.Free;
                 MyClient := nil;
                 BatchReports.XMLString := ''; 
               end;
             end;
             // Add a message to say could not generate
             if not Assigned(MyClient) then
              LogUtil.LogMsg( lmError, Unitname, 'Could not open client ' + ClientCode)
             else if MyClient.clFields.clBusiness_Products_Scheduled_Reports then
              LogUtil.LogMsg( lmError, Unitname, 'Could not open client ' + ClientCode +
                                                  ' for Business Products export')
             else
              LogUtil.LogMsg( lmError, Unitname, 'Could not open client ' + ClientCode +
                                                  ' for Ecoding export');
             Exit;
           end;
           //---------------------------------------------------------------------
        end;
        
        ClientDest := rdPrinter;
        if ReportsDoneOK then
        begin
          //now figure out the client destination
          if ( Dest = rdPrinter) then
          begin
            ClientDest := rdPrinter;

            if MyClient.clFields.clEmail_Scheduled_Reports then
              ClientDest := rdEmail
            else
            if MyClient.clFields.clFax_Scheduled_Reports then
              ClientDest := rdFax
            else
            if MyClient.clFields.clECoding_Export_Scheduled_Reports then
              ClientDest := rdECoding
            else
            if MyClient.clFields.clWebX_Export_Scheduled_Reports then
              ClientDest := rdWebX
            else
            if MyClient.clFields.clCSV_Export_Scheduled_Reports then
              ClientDest := rdCSVExport
            else
            if MyClient.clFields.clCheckOut_Scheduled_Reports then
              ClientDest := rdCheckOut
            else
            if MyClient.clFields.clBusiness_Products_Scheduled_Reports then
              ClientDest := rdBusinessProduct;

            //log where the transaction were generated to
            DestString := '';
            case ClientDest of
               rdPrinter   : DestString := 'Printer';
               rdFax       : DestString := 'Fax';
               rdEmail     : DestString := 'Email';
               rdECoding   : DestString := glConst.ECODING_APP_NAME;
               rdWebX      : case MyClient.clFields.clWeb_Export_Format of
                                 wfNone : DestString :=  '';
                                 wfWebX :  DestString := glConst.WEBX_APP_NAME;
                                 wfWebNotes :  DestString := WebNotesName;
                             end;
               rdCSVExport : DestString := 'CSV Export';
               rdCheckOut  : DestString := BKBOOKSNAME;
               rdBankLinkOnline : DestString := BANKLINK_ONLINE_NAME;
               rdBusinessProduct: DestString := 'Business Prod';
            end;
          end;
        end;

        InvalidEmail := (MyClient.clFields.clEmail_Scheduled_Reports or
                        MyClient.clFields.clECoding_Export_Scheduled_Reports or
                        MyClient.clFields.clCheckOut_Scheduled_Reports or
                        MyClient.clFields.clBusiness_Products_Scheduled_Reports)
                   and
                       ((MyClient.clFields.clClient_EMail_Address = ''));

        //see if admin system needs updating for this client
        if ReportsDoneOK then begin
           //all reports succesfully printed, update admin if needed
           if ( Dest = rdPrinter) and ( srOptions.srUpdateAdmin) then begin
              //first determine if admin needs updating, this is to avoid unnecessary
              //updates of the admin system
              AdminUpdateRequired := false;
              with MyClient.clBank_Account_List do
                 for i := 0 to Pred( ItemCount) do with Bank_Account_At(i) do begin
                    //see if account was included, and if any new trx were printed
                    //if so the admin system needs updating
                    if ( baFields.baTemp_Include_In_Scheduled_Coding_Report and
                       ( baFields.baTemp_New_Date_Last_Trx_Printed <> 0)) then
                    begin
                       AdminUpdateRequired := not InvalidEmail;
                    end;
                 end;

              if AdminUpdateRequired then begin
                 //need to update admin so obtain lock
                 if LoadAdminSystem( true, ThisMethodName +' '+ ClientCode) then begin
                    pCFRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);

                    with MyClient.clBank_Account_List do
                       for i := 0 to Pred( ItemCount) do with Bank_Account_At(i) do begin
                          if ( baFields.baTemp_Include_In_Scheduled_Coding_Report and
                               ( baFields.baTemp_New_Date_Last_Trx_Printed <> 0)) then
                          begin
                             //update the date of last printed trx in admin system
                             // We used to always update it here, but now we update only
                             // when we know for sure that it is successful - emails may
                             // fail at a later stage when sending them, so anything to be emailed
                             // will be updated later.
                             // If email not required, can update now
                             AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( baFields.baBank_Account_Number);
                             if Assigned(AdminBA) then
                             begin
                               ClientUtils.SetTempPrintedDate(ClientCode, AdminBA.sbLRN, baFields.baTemp_New_Date_Last_Trx_Printed);
                               if ClientDest in [rdPrinter,rdFax,rdWebX,rdCSVExport,rdBusinessProduct] then // update immediately
                                 ClientUtils.SetLastPrintedDate(ClientCode, AdminBA.sbLRN)
                             end;
                             if Assigned( pCFRec) then begin
                               pCFRec.cfDate_Of_Last_Entry_Printed := baFields.baTemp_New_Date_Last_Trx_Printed;
                               pCFRec.cfLast_Print_Reports_Up_To := AdminSystem.fdFields.fdPrint_Reports_Up_To;
                             end;
                          end;
                       end;



                    //write updated admin system
                    SaveAdminSystem;
                 end;
              end;
           end;
        end; //if reports ok and assigned

        //see if we need to save or close the current file
        if GeneratingECodingFile then begin
           if ReportsDoneOK then begin
              Files.DoClientSave( TRUE, MyClient);
           end
           else begin
              //mark as closed but don't save, no file was generated
              Files.AbandonAClient( MyClient);
           end;
        end;

        //log progress to file
        if ReportsDoneOK then begin
           //now figure out the client destination
           if ( Dest = rdPrinter) and ( DestString <> '') then
           begin
             // show correct start date per client
             StartDate := srOptions.srDisplayFromDate;
             for i := 0 to Pred(srOptions.srSummaryInfoList.Count) do
             begin
               if (pSchdRepSummaryRec(srOptions.srSummaryInfoList[i]).ClientCode = MyClient.clFields.clCode) then
                StartDate := Min(StartDate, pSchdRepSummaryRec(srOptions.srSummaryInfoList[i]).PrintedFrom);
             end;
             LogUtil.LogMsg( lmInfo, Unitname, 'Reports for ' + MyClient.clFields.clCode +
                                               ' generated to ' + DestString +
                                               ' for ' + bkDate2Str( StartDate) +
                                               ' to ' + bkDate2Str( srOptions.srTrxToDate));
           end;
        end;

        //find all occurances of this client in the list
        //count backwards because the the current client is at the end of the list
        i := srOptions.srSummaryInfoList.Count-1;
        while (i >= 0) and (pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[i]).ClientCode = ClientCode) do
        begin
          if pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[i]).AccountNo <> CUSTOM_DOCUMENT then
            pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[i]).Completed := ReportsDoneOK;
          Dec(i);
        end;

        Result := true;
     finally
        MyClient.Free; //abandon changes
        MyClient := Nil;
        BatchReports.XMLString := ''; 
     end { try };
   end else
   begin
     //not fsopen and not fsnormal
     AddSummaryRec(ClientCode, srOptions, Dest, False);

     MyClient.Free; //abandon changes
     MyClient := Nil;
     BatchReports.XMLString := ''; 
   end;

   if DebugMe then begin
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ends')
   end;
end; { ProcessClient }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddSummaryRec(ClientCode : String; srOptions : TSchReportOptions;
          Dest : TReportDest; IsCompleted: Boolean; AAccountNo: string = '');
var
  pCFRec                : pClient_File_Rec;
  RptPeriodToUse        : Byte;
  NewSummaryRec         : pSchdRepSummaryRec;
begin
  //set the reporting period dates
  pCFRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
  RptPeriodToUse  := GetReportingPeriodToUse( MyClient.clFields.clReporting_Period,
                                              MyClient.clFields.clReport_Start_Date,
                                              pCFRec^.cfLast_Print_Reports_Up_To,
                                              AdminSystem.fdFields.fdPrint_Reports_Up_To,
                                              srOptions.srPrintAll);
  GetMem( NewSummaryRec, SizeOf( TSchdRepSummaryRec));
  with NewSummaryRec^ do
  begin
    ClientCode     := pCFRec.cfFile_Code;
    AccountNo      := AAccountNo;
    PrintedFrom    := Get_Reporting_Period_Start_Date(
      AdminSystem.fdFields.fdPrint_Reports_Up_To, RptPeriodToUse );
    PrintedTo      := AdminSystem.fdFields.fdPrint_Reports_Up_To;
    AcctsPrinted   := 0;
    AcctsFound     := 0;
    SendBy         := Dest;
    UserResponsible := pCFRec.cfUser_Responsible;
    TxLastMonth    := ShowTransLastMonth(MyClient, srOptions);
    Completed      := IsCompleted;
  end;
  srOptions.srSummaryInfoList.Add(NewSummaryRec);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure PrintReportsByClientType(Dest: TReportDest; srOptions : TSchReportOptions);
//Prints reports grouped by their Client Type
//Used by: Print Scheduled Reports
const
  ThisMethodName = 'PrintReportsByClientType';
var
  ClientTypeList: tSystem_Client_Type_List;
  ClientType: pClient_Type_Rec;
  UpperClientTypeName: string;
  ClientTypesWithReports: TStringList;
  UnallocatedClients: TStringList;
  ClientTypeClientsWithReports: TStringList;
  ClientTypeIndex: Integer;
  ReportSelectionOption: Integer;
  ClientTypeFrom: string;
  ClientTypeTo: string;
  ClientList: tSystem_Client_File_List;
  ClientIndex: Integer;
  Client: pClient_File_Rec;
  ClientsToPrint: TStringList;
begin
  //Get List of Groups

  ReportSelectionOption := AdminSystem.fdFields.fdSort_Reports_Option;
  ClientTypeFrom := Trim(srOptions.srFromCode);
  ClientTypeTo := Trim(srOptions.srToCode) + 'þ';
  ClientTypeList := AdminSystem.fdSystem_Client_Type_List;
  ClientTypesWithReports := TStringList.Create;
  UnallocatedClients := TStringList.Create;
  try
    ClientList := AdminSystem.fdSystem_Client_File_List;

    for ClientTypeIndex := 0 to ClientTypeList.ItemCount - 1 do
    begin
      ClientType := ClientTypeList.Client_Type_At(ClientTypeIndex);
      UpperClientTypeName := UpperCase(ClientType^.ctName);
      //check if Group is a valid group to check
      if ItemInRange(ReportSelectionOption, ClientTypeFrom, ClientTypeTo, srOptions.srCodeSelection, UpperClientTypeName) then
      begin
        //Group is selected, find valid clients
        //Create list to hold valid reports. Get's attached to the Group if there any found
        //Gets recreated for every group
        ClientTypeClientsWithReports := TStringList.Create;
        for ClientIndex := 0 to ClientList.ItemCount - 1 do
        begin
          Client := ClientList.Client_File_At(ClientIndex);
          if (Client^.cfClient_Type_LRN = ClientType.ctLRN) and (Client^.cfReports_Due) then
            ClientTypeClientsWithReports.Add(Client^.cfFile_Code);
        end;

        if ClientTypeClientsWithReports.Count > 0 then           //Need to print this group
          ClientTypesWithReports.AddObject(ClientType^.ctName, ClientTypeClientsWithReports);
      end;
    end;

    //now look to see if we should be looking at clients with no groups as well
    if UseUnallocated(ReportSelectionOption, ClientTypeTo, srOptions.srCodeSelection) then
    begin
       for ClientIndex := 0 to ClientList.ItemCount - 1 do
       begin
         Client := ClientList.Client_File_At(ClientIndex);
         if (Client^.cfClient_Type_LRN = 0) and (Client^.cfReports_Due) then
          UnallocatedClients.Add(Client^.cfFile_Code);
       end;
    end;      

    //Now we have all the Clients we need to print, actually print them
    for ClientTypeIndex := 0 to ClientTypesWithReports.Count - 1 do
    begin
      ClientType := AdminSystem.fdSystem_Client_Type_List.FindName(ClientTypesWithReports[ClientTypeIndex]);
      if not Assigned(ClientType) then
        continue;

      if AdminSystem.fdFields.fdPrint_Client_Type_Header_Page then
      begin
        //only print client if reports are due for that Group
        //reuse UserLRN for GroupLRN
        srOptions.srUserLRN := ClientType^.ctLRN;
        DoScheduledReport(Report_Client_Type_Header, Dest, srOptions);
      end;

      if StatusFrm.Status_Cancel_Pressed then
        Exit;

      ClientsToPrint := TStringList(ClientTypesWithReports.Objects[ClientTypeIndex]);
      for ClientIndex := 0 to ClientsToPrint.Count - 1 do
      begin
        StatusFrm.Status_Cancel_Pressed := false;
        //process client will cause a refresh of admin system
        if not ProcessClient( ClientsToPrint[ClientIndex], Dest, srOptions ) then
           //client code not be processed
           LogUtil.LogMsg(lmInfo, UnitName, 'Client ' + ClientsToPrint[ClientIndex]+ ' skipped.');

        if StatusFrm.Status_Cancel_Pressed then begin
           exit
        end;
      end;
    end;

    //Now do Unallocated Clients
    for ClientIndex := 0 to UnallocatedClients.Count - 1 do
    begin
      StatusFrm.Status_Cancel_Pressed := false;
      //process client will cause a refresh of admin system
      if not ProcessClient( UnallocatedClients[ClientIndex], Dest, srOptions ) then
         //client code not be processed
         LogUtil.LogMsg(lmInfo, UnitName, 'Client ' + UnallocatedClients[ClientIndex]+ ' skipped.');

      if StatusFrm.Status_Cancel_Pressed then begin
         exit
      end;
    end;

  finally
    for ClientTypeIndex := 0 to ClientTypesWithReports.Count - 1 do
      TStringList(ClientTypesWithReports.Objects[ClientTypeIndex]).Free;
    ClientTypesWithReports.Free;
    UnallocatedClients.Free;
    StatusFrm.Status_Cancel_Visible := false;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure PrintReportsByGroup(Dest: TReportDest; srOptions : TSchReportOptions);
//Prints reports grouped by their group
//Used by: Print Scheduled Reports
const
  ThisMethodName = 'PrintReportsByGroup';
var
  GroupList: tSystem_Group_List;
  Group: pGroup_Rec;
  UpperGroupName: string;
  GroupsWithReports: TStringList;
  UnallocatedClients: TStringList;
  GroupClientsWithReports: TStringList;
  GroupIndex: Integer;
  ReportSelectionOption: Integer;
  GroupFrom: string;
  GroupTo: string;
  ClientList: tSystem_Client_File_List;
  ClientIndex: Integer;
  Client: pClient_File_Rec;
  ClientsToPrint: TStringList;
begin
  //Get List of Groups

  ReportSelectionOption := AdminSystem.fdFields.fdSort_Reports_Option;
  GroupFrom := Trim(srOptions.srFromCode);
  GroupTo := Trim(srOptions.srToCode) + 'þ';
  GroupList := AdminSystem.fdSystem_Group_List;
  GroupsWithReports := TStringList.Create;
  UnallocatedClients := TStringList.Create;
  try
    ClientList := AdminSystem.fdSystem_Client_File_List;

    for GroupIndex := 0 to GroupList.ItemCount - 1 do
    begin
      Group := GroupList.Group_At(GroupIndex);
      UpperGroupName := UpperCase(Group^.grName);
      //check if Group is a valid group to check
      if ItemInRange(ReportSelectionOption, GroupFrom, GroupTo, srOptions.srCodeSelection, UpperGroupName) then
      begin
        //Group is selected, find valid clients
        //Create list to hold valid reports. Get's attached to the Group if there any found
        //Gets recreated for every group
        GroupClientsWithReports := TStringList.Create;
        for ClientIndex := 0 to ClientList.ItemCount - 1 do
        begin
          Client := ClientList.Client_File_At(ClientIndex);
          if (Client^.cfGroup_LRN = Group.grLRN) and (Client^.cfReports_Due) then
            GroupClientsWithReports.Add(Client^.cfFile_Code);
        end;

        if GroupClientsWithReports.Count > 0 then           //Need to print this group
          GroupsWithReports.AddObject(Group^.grName, GroupClientsWithReports);
      end;
    end;

    //now look to see if we should be looking at clients with no groups as well
    if UseUnallocated(ReportSelectionOption, GroupTo, srOptions.srCodeSelection) then
    begin
       for ClientIndex := 0 to ClientList.ItemCount - 1 do
       begin
         Client := ClientList.Client_File_At(ClientIndex);
         if (Client^.cfGroup_LRN = 0) and (Client^.cfReports_Due) then
          UnallocatedClients.Add(Client^.cfFile_Code);
       end;
    end;      

    //Now we have all the Clients we need to print, actually print them
    for GroupIndex := 0 to GroupsWithReports.Count - 1 do
    begin
      Group := AdminSystem.fdSystem_Group_List.FindName(GroupsWithReports[GroupIndex]);
      if not Assigned(Group) then
        continue;

      if AdminSystem.fdFields.fdPrint_Group_Header_Page then
      begin
        //only print client if reports are due for that Group
        //reuse UserLRN for GroupLRN
        srOptions.srUserLRN := Group^.grLRN;
        DoScheduledReport(Report_Group_Header, Dest, srOptions);
      end;

      if StatusFrm.Status_Cancel_Pressed then
        Exit;

      ClientsToPrint := TStringList(GroupsWithReports.Objects[GroupIndex]);
      for ClientIndex := 0 to ClientsToPrint.Count - 1 do
      begin
        StatusFrm.Status_Cancel_Pressed := false;
        //process client will cause a refresh of admin system
        if not ProcessClient( ClientsToPrint[ClientIndex], Dest, srOptions ) then
           //client code not be processed
           LogUtil.LogMsg(lmInfo, UnitName, 'Client ' + ClientsToPrint[ClientIndex]+ ' skipped.');

        if StatusFrm.Status_Cancel_Pressed then begin
           exit
        end;
      end;
    end;

    //Now do Unallocated Clients
    for ClientIndex := 0 to UnallocatedClients.Count - 1 do
    begin
      StatusFrm.Status_Cancel_Pressed := false;
      //process client will cause a refresh of admin system
      if not ProcessClient( UnallocatedClients[ClientIndex], Dest, srOptions ) then
         //client code not be processed
         LogUtil.LogMsg(lmInfo, UnitName, 'Client ' + UnallocatedClients[ClientIndex]+ ' skipped.');

      if StatusFrm.Status_Cancel_Pressed then begin
         exit
      end;
    end;

  finally
    for GroupIndex := 0 to GroupsWithReports.Count - 1 do
      TStringList(GroupsWithReports.Objects[GroupIndex]).Free;
    GroupsWithReports.Free;
    UnallocatedClients.Free;
    StatusFrm.Status_Cancel_Visible := false;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure PrintReportsbyStaffMember(Dest: TReportDest; srOptions : TSchReportOptions);
//
//Build a list of staff members with clients that need to be printed
//For each staff member add a list of clients
//Add unallocated staff member and add unallocated client to it
//Process clients
// used by:  Print Scheduled Reports
const
  ThisMethodName = 'PrintReportsbyStaffMember';
Var
  i,
  j           : Integer;
  uKey1,
  uKey2       : string[10];
  pUser       : pUser_Rec;
  CurrCodes   : TStringList;
  StaffList   : TStringList;
  Unallocated : TStringList;
//  ClientDest : TReportDest;
//  PrintOK : Boolean;
begin
   uKey1 := srOptions.srFromCode;
   uKey2 := srOptions.srToCode + 'þ';

   StatusFrm.Status_Cancel_Visible := true;
   StaffList := TStringList.Create;
   Unallocated := TStringList.Create;
   try
      StaffList.Clear;
      Unallocated.Clear;

      With AdminSystem Do begin
         //first build a list of staff members with clients who need reports
         For i := 0 to Pred(fdSystem_User_List.ItemCount) Do begin
            With fdSystem_User_List.User_At(i)^ Do begin
               if ((usCode >= uKey1) and (usCode <= uKey2) and (srOptions.srCodeSelection.Count = 0)) or
                  (srOptions.srCodeSelection.IndexOf(usCode) > -1) then
               begin
                  //make sure this current client list point is nil
                  CurrCodes := nil;
                  //look thru client file list to find users with this staff member
                  For j := 0 to Pred(fdSystem_Client_File_List.ItemCount) Do begin
                     With fdSystem_Client_File_List.Client_File_At(j)^ Do begin
                        if (cfUser_Responsible = usLRN) and ( cfReports_Due ) then begin
                           //Add to list of clients for this staff member,  if no list
                           //exists create one
                           if not Assigned( CurrCodes) then begin
                              CurrCodes := TStringList.Create;
                              CurrCodes.Clear;
                           end;
                           CurrCodes.Add( cfFile_Code);
                        end
                     end
                  end;
                  //if current codes list has something in it then add the staff member
                  //and client list
                  if assigned( CurrCodes) then begin
                     StaffList.AddObject( usCode, CurrCodes);
                  end;
               end;
            end;
         end;

         //Now build list for unallocated clients
         //only check for unallocated client if no end code has been specified.
         //this stops the unallocted clients printing if you only select one staff member
         if (srOptions.srToCode = '') and ((srOptions.srCodeSelection.Count = 0) or (srOptions.srCodeSelection.IndexOf(' ') > -1)) then
         begin
            for j := 0 to Pred(fdSystem_Client_File_List.ItemCount) do begin
               with fdSystem_Client_File_List.Client_File_At(j)^ do
               begin
                 if cfReports_Due then
                 begin
                   if ( cfUser_Responsible = 0 ) then
                     Unallocated.Add( cfFile_Code)
                   else
                   begin
                     //check that user is known if assigned
                     pUser := AdminSystem.fdSystem_User_List.FindLRN( cfUser_Responsible);
                     if not Assigned( pUser) then
                       Unallocated.Add( cfFile_Code);
                   end;
                 end;
               end;
            end;
         end;
      end; //with admin system

      //have now built lists so begin processing the staff members and client files
      //now have a list of staff members to work with, find a list of clients with that staff code
      For i := 0 to Pred(StaffList.Count) Do begin
         With AdminSystem Do begin
            //find the staff member again - admin may have been reloaded
            pUser := fdSystem_User_List.FindCode(StaffList[i]);
            if not Assigned(pUser) then begin
               Continue
            end;
            //do header page
            if fdFields.fdPrint_Staff_Member_Header_Page then begin
              //only print client if reports are due for that client
              srOptions.srUserLRN := pUser.usLRN;
              DoScheduledReport(REPORT_STAFF_MEMBER_HEADER, Dest, srOptions);
            end;

            if StatusFrm.Status_Cancel_Pressed then begin
               exit
            end;
         end;

         //process list of clients
         CurrCodes := TStringList( StaffList.Objects[ i]);
         For j := 0 to Pred(CurrCodes.Count) Do begin
            StatusFrm.Status_Cancel_Pressed := false;
            //process client will cause a refresh of admin system
            if not ProcessClient( CurrCodes[j], Dest, srOptions ) then begin
               //client code not be processed
               LogUtil.LogMsg(lmInfo, UnitName, 'Client ' + CurrCodes[j] + ' skipped.');
            end;

            if StatusFrm.Status_Cancel_Pressed then begin
               exit
            end;
         end;
      end; //cycle thru list of staff members

      //now print for unallocated clients
      if srOptions.srToCode = '' then begin
         //process list of unallocated clients
         For j := 0 to Pred(Unallocated.Count) Do begin
            StatusFrm.Status_Cancel_Pressed := false;
            if not ProcessClient(Unallocated[j], Dest, srOptions) then begin
               //client code not be processed
               LogUtil.LogMsg(lmInfo, UnitName, 'Client ' + Unallocated[j] + ' skipped.');
            end;
            if StatusFrm.Status_Cancel_Pressed then begin
               exit
            end;
         end;
      end;
   finally
      //destroy unallocated list
      Unallocated.Free;
      //destroy staff member list and attached codes lists
      for i := 0 to Pred( StaffList.Count) do begin
         TStringList( StaffList.Objects[ i]).Free;
      end;
      StaffList.Free;
      StatusFrm.Status_Cancel_Visible := false;
   end;
end; { PrintReportsbyStaffMember }
//------------------------------------------------------------------------------

Procedure PrintReportsByClient(Dest: TReportDest; srOptions : TSchReportOptions);
// used by: Print Scheduled Reports
Var
  i         : Integer;
  cKey1,
  cKey2     : string[10];
  CodesList : TStringList;
begin { PrintReportsByClient }
   cKey1 := srOptions.srFromCode;
   cKey2 := srOptions.srToCode + 'þ';

   Status_Cancel_Visible := true;
   CodesList := TStringList.Create;
   Try
      //load valid codes into a list incase admin system is reloaded at any time
      With AdminSystem.fdSystem_Client_File_List Do begin
         For i := 0 to Pred(ItemCount) Do begin
            With Client_File_At(i)^ Do begin
               if ((((cfFile_Code >= cKey1) and (cfFile_Code <= cKey2) and (srOptions.srCodeSelection.Count = 0))) or
                   (srOptions.srCodeSelection.IndexOf(cfFile_Code) > -1)) and
                    cfReports_Due then begin
                  CodesList.Add(cfFile_Code)
               end
            end
         end
      end;

      //cycle thru strings list processing codes
      For i := 0 to Pred(CodesList.Count) Do begin
         Status_Cancel_Pressed := false;
         if not ProcessClient(CodesList[i], Dest, srOptions) then begin
            //client code not be processed
            LogUtil.LogMsg(lmInfo, UnitName, 'Client ' + CodesList[i] + ' skipped.');
         end { not ProcessClient(CodesList[i], Dest) };

         if Status_Cancel_Pressed then begin
            exit
         end;
      end { for i };
   Finally
      Status_Cancel_Visible := false;
      CodesList.Free;
   end { try };
end; { PrintReportsByClient }
//------------------------------------------------------------------------------

Procedure PrintScheduledReports;
//used by:  Main Form
//
const
   ThisMethodName = 'PrintScheduledReports';
Var
   btnPressed     : Integer;
   Dest           : TReportDest;
   i, j           : integer;
   aMsg           : string;
   ReportOptions  : TSchReportOptions;
   SummaryRecList : TList;

   TempClientsList : TStringList;
   cfRec          : pClient_File_Rec;

   TurnOffEmail   : boolean;
   TurnOffCSVExport : boolean;
   UpdateAdmin: Boolean;
   Path           : string;
   AccountsPrinted : Integer;
   ClientsCompleted : Integer;
   ClientsInError : Integer;
   lKeepPrintOption, UnprintedLastMonth : Boolean;
   AdminBA: pSystem_Bank_Account_Rec;
   pm: pClient_Account_Map_Rec;
   LockFileInfo : TStringList;
begin
   FaxErrors := 0;
   //According to some users system logs it may be possible to set off
   //scheduled reporting more than once.  This could be because Application.ProcessMessages
   //is called during printing.
   if SchReportsRunning then exit;

   if Assigned(MyClient) then
     CloseClientHomePage;

   LockFileInfo := TStringList.Create;
   try
      if not LockUtils.ObtainLock(ltScheduledReport, PRACINI_TicksToWaitForAdmin div 1000) then
      begin
         try
            LockFileInfo.LoadFromFile(Globals.DataDir + SCHEDULED_LOCK);
         except
            LockFileInfo.Text := 'Unknown';
         end;
         HelpfulWarningMsg('You cannot run scheduled reports at this time because another user is running them.'#13#13
            + 'User: ' + LockFileInfo.Text , 0);
         exit;
      end else begin
         if Globals.CurrUser.FullName <> '' then
            LockFileInfo.Text := Globals.CurrUser.FullName
         else
            LockFileInfo.Text := Globals.CurrUser.Code;
         LockFileInfo.SaveToFile(Globals.DataDir + SCHEDULED_LOCK);
      end;
   finally
      LockFileInfo.Free;
   end;

   ReportOptions.srCodeSelection := TStringList.Create;
   try

     if not GetScheduleOptions( ReportOptions, btnPressed) then begin
        exit
     end;

     if not( btnPressed in [BTN_PRINT, BTN_PREVIEW]) then begin
        exit
     end;

     //make sure all relative paths are relative to data dir after browse
     SysUtils.SetCurrentDir( Globals.DataDir);

     LogUtil.LogMsg( lmInfo, UnitName, 'PREPARING SCHEDULED REPORTS');
     UpdateAppStatus( 'Preparing Scheduled Reports...', '', 37, ProcessMessages_On);

     //need to prevent the printer dialog appearing when reports are sent to printer
     lKeepPrintOption := false;
     if Assigned(CurrUser) then begin
        LKeepPrintOption := CurrUser.ShowPrinterDialog;
        CurrUser.ShowPrinterDialog := False;
     end;

     try
        ClientManagerFrm.DisableClientManager;
        Admin32.RefreshAdmin;

        //make sure dest directories are available
        TurnOffCSVExport := False;
        TurnOffEmail     := False;

        //make sure emailOutbox dir is set up and emptied
        //if cant create it then ask user what to do
        Path := EmailOutboxDir;
        if not PrepareEmailOutbox( Path) then
        begin
          ClearStatus;
          aMsg := 'Unable to create directory ' + Path + '. Reports sent via E-mail will not be sent.'#13#13+
                  'Do you wish to continue?';
          if YesNoDlg.AskYesNo( 'Unable to create directory',
                                aMsg, DLG_NO, 0) <> DLG_YES then
            Exit;

          //turn off email reports
          TurnOffEmail := true;
        end;
          (*
        //make sure csv extract dir available
        Path := Trim( AdminSystem.fdFields.fdCSV_Export_Path);
        if Path = '' then
          Path := Globals.CSVExportDefaultDir;

        if not PrepareCSVExportDir( Path) then
        begin
          ClearStatus;
          aMsg := 'Unable to create directory ' + Path + '. Reports exported to CSV file will not be included.'#13+
                  'Check the directory to use, in System Options Exporting'#13#13 +
                  'Do you wish to continue?';

          if YesNoDlg.AskYesNo( 'Unable to create directory',
                                aMsg, DLG_NO, 0) <> DLG_YES then
            Exit;

          //turn off csv export
          TurnOffCSVExport := True;
        end;
            *)
        TempClientsList := TStringList.Create;
        try
           //load all clients into the clients due list, this will be passed to the flag routine.
           with AdminSystem.fdSystem_Client_File_List do begin
              for i := 0 to Pred(ItemCount) do with Client_File_At(i)^ do
                 TempClientsList.AddObject( cfFile_Code, TObject( 0));
           end;

           //Set admin flag and see how many reports are due
           if not( FlagClientsWithReportsDue( ReportOptions, TempClientsList, UnprintedLastMonth) > 0) then begin
              ClearStatus;
              aMsg := 'There are no Scheduled Reports due.';
              HelpfulInfoMsg( aMsg, 0);
              LogMsg( lmInfo, Unitname, aMsg);
              exit;
           end;

           //Update the flags in the admin system and save the admin system
           if LoadAdminSystem(true, ThisMethodName + '.Set Reports Due Flag') then begin
               //make sure directories were created above, turn off clients
               //if user decided to continue
               if TurnOffEmail then
               begin
                 AdminSystem.fdFields.fdSched_Rep_Include_Email := false;
                 AdminSystem.fdFields.fdSched_Rep_Include_ECoding := false;
               end;

               if TurnOffCSVExport then
               begin
                 AdminSystem.fdFields.fdSched_Rep_Include_CSV_Export := False;
               end;

               //reset all to false
               with AdminSystem.fdSystem_Client_File_List do begin
                  for i := 0 to Pred(ItemCount) do with Client_File_At(i)^ do
                     cfReports_Due := false;
               end;
               //now re-set flags for clients who are due
               for i := 0 to Pred( TempClientsList.Count) do begin
                  if (Integer( TempClientsList.Objects[ i]) = 1) or (Integer( TempClientsList.Objects[ i]) = 2) then begin
                     cfRec := AdminSystem.fdSystem_Client_File_List.FindCode( TempClientsList[ i]);
                     if Assigned( cfRec) then
                        cfRec^.cfReports_Due := true;
                  end;
               end;
               //now reset flags for temp last date in the client account map
               for i := 0 to Pred(AdminSystem.fdSystem_Client_Account_Map.ItemCount) do
               begin
                pm := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i);
                pm.amTemp_Last_Date_Printed := 0;
               end;
               SaveAdminSystem;
            end
            else begin
               ClearStatus;
               HelpfulErrorMsg('Unable to update Admin Settings.  Cannot Print reports.',0);
               exit;
            end;
        finally
           TempClientsList.Free;
        end;

        //cache the encoded practice logo so that can embed in bnotes files
        if Assigned( Globals.AdminSystem) then
          EncodedLogoString := PracticeLogo.EncodePracticeLogo( AdminSystem.fdFields.fdPractice_Logo_Filename)
        else
          EncodedLogoString := '';

        //clients due flags set and report settings loaded, now begin printed.
        if btnPressed = BTN_PRINT then begin
           Dest := rdPrinter;
           LogUtil.LogMsg( lmInfo, UnitName, 'PRINT SCHEDULED REPORTS STARTED');
        end
        else begin
           Dest := rdScreen;
           LogUtil.LogMsg( lmInfo, UnitName, 'PREVIEW SCHEDULED REPORTS STARTED');
        end;
        if ReportOptions.srPrintAll then
           LogUtil.LogMsg( lmInfo, UnitName, 'ALL TRANSACTIONS up to ' + BkDate2Str(AdminSystem.fdFields.fdPrint_Reports_Up_To))
        else
           LogUtil.LogMsg( lmInfo, UnitName, 'NEW TRANSACTIONS ONLY up to ' + BkDate2Str(AdminSystem.fdFields.fdPrint_Reports_Up_To));

        Status_Cancel_Pressed := false;
        SchReportsRunning := true;

        //reload the images used on the coding report header/footer
        CreateReportImageList;
        try
          //LoadReportImageList;

          EmailList := TList.Create;
          try
            SummaryRecList := TList.Create;
            try
               //Assign Info List
               ReportOptions.srSummaryInfoList := SummaryRecList;
               //admin system will have been refreshed by GetScheduleOptions //Print/Preview

               //Generate the reports...
               //load the fax prs here so that we dont have to load it for each
               //client
               if AdminSystem.fdFields.fdSched_Rep_Include_Fax then
                 FaxPrintSettings := TPrintManagerObj.Create
               else
                 FaxPrintSettings := nil;

               try
                 if Assigned( FaxPrintSettings) then
                 begin
                   //will have been created above if faxing is being used
                   FaxPrintSettings.FileName := DATADIR + SCHEDULED_FAX_ID + USERPRINTEXTN;
                   FaxPrintSettings.Open;
                 end;

                 //----------------- G E N E R A T E   T H E   R E P O R T S -----
                 case AdminSystem.fdFields.fdSort_Reports_By of
                   srsoStaffMember: PrintReportsbyStaffMember(Dest, ReportOptions);
                   srsoGroup: PrintReportsByGroup(Dest, ReportOptions);
                   srsoClientType: PrintReportsByClientType(Dest, ReportOptions);
                   else PrintReportsByClient(Dest, ReportOptions);
                 end;
                 //---------------------------------------------------------------

               finally
                 if Assigned( FaxPrintSettings) then
                 begin
                   FaxPrintSettings.Free;
                   FaxPrintSettings := nil;
                 end;
               end;

               //see if any items added to list
               if ((Dest = rdPrinter) or (Dest = rdCheckOut) or (Dest = rdBusinessProduct)) and (EmailList.Count > 0) then begin
                  LogUtil.LogMsg( lmInfo, UnitName, 'Email Scheduled Reports Started');
                  StatusFrm.Status_Cancel_Visible := true;
                  try
                    //need to send email
                    SendReportsViaEmail(ReportOptions); //Email
                  finally
                    StatusFrm.Status_Cancel_Visible := false;
                  end;
               end;

               //preview the summary report by default, can select to print automatically in bk5prac.ini
               if not AdminSystem.fdFields.fdAuto_Print_Sched_Rep_Summary then
                 DoScheduledReport( Report_Schd_Rep_Summary, rdScreen, ReportOptions)
               else
                 DoScheduledReport( Report_Schd_Rep_Summary, Dest, ReportOptions);
            finally
              AccountsPrinted := SummaryRecList.Count;
              ClientsCompleted := 0;
              ClientsInError := 0;
              aMsg := ''; //last client code
              UpdateAdmin := False;
              if ( Dest = rdPrinter) and ( ReportOptions.srUpdateAdmin) then
              begin
                if LoadAdminSystem( true, ThisMethodName) then
                  UpdateAdmin := True;
              end;
              for i := 0 to SummaryRecList.Count - 1 do
              begin
                if (pSchdRepSummaryRec(SummaryRecList.Items[i])^.Completed) then
                begin
                  // update last date                     
                  if UpdateAdmin then
                  begin
                    AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( pSchdRepSummaryRec(SummaryRecList.Items[i])^.AccountNo);
                    if Assigned( AdminBA) then
                      ClientUtils.SetLastPrintedDate(pSchdRepSummaryRec(SummaryRecList.Items[i])^.ClientCode, AdminBA.sbLRN);
                  end;
                  if (pSchdRepSummaryRec(SummaryRecList.Items[i])^.ClientCode <> aMsg) then
                    Inc(ClientsCompleted);
                end
                else if (pSchdRepSummaryRec(SummaryRecList.Items[i])^.ClientCode <> aMsg) then
                  Inc(ClientsInError);
                aMsg := pSchdRepSummaryRec(SummaryRecList.Items[i])^.ClientCode;
                //clear all items in summary list
                FreeMem( pSchdRepSummaryRec(SummaryRecList.Items[ i ]), SizeOf(TSchdRepSummaryRec));
              end;
              if UpdateAdmin then
                SaveAdminSystem;
              SummaryRecList.Free;
            end;
          finally
            //clear all items in list
            for i := 0 to Pred( EmailList.Count ) do
              TClientEmailInfo(EmailList.Items[ i ]).Free;
            EmailList.Free;
            for j := bpMin to bpMax do //clean up business products files
              DeleteFiles(EmailOutboxDir + '*' + bpFileExtn[j]);
            DeleteFiles(EmailOutboxDir + '*.pdf');// Custom Documents
          end;
        finally
          DestroyReportImageList;
        end;
     finally
        ClearStatus;
        ClientManagerFrm.EnableClientManager;
        SchReportsRunning := false;
        UpdateName;
        UpdateMenus;
        If Assigned(CurrUser) then
           CurrUser.ShowPrinterDialog := LKeepPrintOption;
     end;

     if StatusFrm.Status_Cancel_Pressed then begin
       aMsg := 'Scheduled Reports stopped by user.';
     end
     else begin
       if FaxErrors > 0 then
         aMsg := 'Scheduled Reports completed but there were some Fax errors.' + #13
       else
         aMsg := 'Scheduled Reports completed.' + #13;
       if (AccountsPrinted = 0) then
         aMsg := aMsg + 'There were no reports to generate.'
       else
       begin
         aMsg := aMsg + #13#10 + IntToStr(ClientsCompleted) +
           ' client(s) were generated successfully.';
         if (ClientsInError > 0) then
           aMsg := aMsg + #13#10 + IntToStr(ClientsInError) +
             ' client(s) returned errors.';
       end;
     end;
     HelpfulInfoMsg( aMsg, 0);
     LogUtil.LogMsg( lmInfo, UnitName, Uppercase( aMsg));
   finally
     FreeAndNil(ReportOptions.srCodeSelection);
     LockUtils.ReleaseLock(ltScheduledReport);
     Sysutils.DeleteFile(Globals.DataDir + SCHEDULED_LOCK);
   end;
end; { PrintScheduledReports }

//------------------------------------------------------------------------------

Initialization
   DebugMe := DebugUnit(UnitName);
end.

