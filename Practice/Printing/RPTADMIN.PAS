unit rptAdmin;
//------------------------------------------------------------------------------
{
   Title:

   Description: Admin System Reports

   Author:

   Remarks:

   Last Reviewed : 22 May 2003 by MH

}
//------------------------------------------------------------------------------

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Admin System Reports
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
   bkHelp,ReportDefs, Scheduled, Classes, SchedRepUtils, TSGrid, ListChargesDlg;

procedure DoDownloadReport(var Dest : TReportDest);

procedure DoSummarisedDownloadReport(var Dest : TReportDest);

procedure DoReportsDue(var Dest : TReportDest; srOptions : TSchReportOptions);

procedure DoListAdminBankAccounts(NonActiveOnly : Boolean; var Dest : TReportDest;
                                  ProvisionalOnly : Boolean = false);

procedure DoClientsByStaffMember(var Dest : TReportDest);

procedure DoClientReportOptions(var Dest : TReportDest);

procedure DoDownloadLog(var Dest : TReportDest);

procedure DoClientStatusReport(var Dest : TReportDest);

Procedure DoClientFileAccessControl(var Dest : TReportDest );

procedure DoListAdminCharges(var Dest : TReportDest; Data: TtsGrid; ExportType:
          Byte; ExportDate: string; IsIncreasedCharges: Boolean);

procedure DoListCharges(var Dest : TReportDest; Data: TChargesList; ExportType:
          Byte; ExportDate: string);

procedure PrintTasksForClient(ClientCode : string; var Dest : TReportDest; aTaskList : TList);

procedure PrintTasksForMultipleClients(ClientCodes: string; Dest: TReportDest);

procedure DoGroupList(var Dest : TReportDest);

procedure DoClientTypelistList(var Dest : TReportDest);

procedure DoCodingOptimisationReport(var Dest : TReportDest);

procedure DoSystemAuditReport(var Dest : TReportDest);

procedure DoClientAuditReport(var Dest : TReportDest);

//******************************************************************************
implementation
uses
   Software,
   csDefs,
   CodingStatsList32,
   stBase,
   StTree,
   ReportTypes,
   NewReportObj,
   repcols,
   bkdefs,
   globals,
   PrintMgrObj,
   sydefs,
   Admin32,
   eCollect,
   files,
   sycfio,
   bkDateUtils,
   SysUtils,
   NewReportUtils,
   clObj32,
   LogUtil,
   bkUtil32,
   bkConst,
   InfoMorefrm,
   ArchUtil32,
   stDate,
   stDatest,
   YesNoDlg,
   malloc,
   baObj32,
   PrintDestDlg,
   StatusReportRangeDlg,
   CodingOptimisationReportRangeDlg,
   AuditReportOptionsDlg,
   GenUtils,
   ErrorMoreFrm,
   CaUtils,
   Merge32,
   Progress,
   glConst,
   RptDateUtils,
   DownloadReportOptionsDlg,
   ListAdminAccountsDlg, SysObj32, SysDList32, cfList32,
   ToDoListUnit, ExportChargesFrm, WinUtils, Forms, ClientHomePageFrm,
   ShellAPI,
   Windows,
   ReportImages,
   ClientSelectFme,
   AuditMgr;

type
   //Client status record for whats due list
   TClientDueRec = record
     cdCode                   : String[8];
     cdName                   : String[60];
     cdUser_Responsible       : Integer;
     cdUser_Name              : String[60];
     cdGroup                  : Integer;
     cdClient_Type            : Integer;
     cdReporting_Period       : Integer;
     cdReportsToSend          : Integer;
     cdDestination            : Integer;
     cdFileStatus             : Integer;
     cdUnprintedLastMonth     : Boolean;
   end;
   pClientDueRec = ^TClientDueRec;

   //Code, Name, Date From, Date To, Coding Inc'd, Chart Inc'd, Payee Inc'd, Destination

   TToDoList = class( TExtdCollection )
      procedure FreeItem( Item : Pointer ); override;
      function  CD_Rec_At( Index : Longint ) : pClientDueRec;
   end;

   TAdminBankAccountsReport = class (TBKReport)
   protected
      AccountsList : TStringList;
      IncludeDeletedAccounts : boolean;
      NotActiveSince : Integer;
      ProvisionalOnly : boolean;
   end;

   TReportsDueReport = class( TBKReport)
   protected
      ReportOptions : TSchReportOptions;
      ToDoList  : TToDoList;
   end;

   //Client Status Info for period
   TCSPeriodInfo = record
      piTrxCount         : integer;
      piTransferableCount: integer;
      piTransferredCount : integer;
      piFinalisedCount   : integer;
      piCodedCount       : integer;
   end;

   //Client status record for status list
   TClientStatusRec = record
      csCode             : String[ 8];
      csName             : String[ 60];
      csFileStatus       : string[ 2];
      csPeriodInfo       : Array[0..11] of TCSPeriodInfo;
      csStaffMember      : string[60];
      csLastAccessedDate : integer;
   end;
   pClientStatusRec = ^TClientStatusRec;

   //list of all client status records for report
   TClientStatusList = class( TExtdCollection)
      procedure FreeItem(Item : pointer); override;
      function  CS_Rec_At(Index : integer) : pClientStatusRec;
   protected
      PeriodFromDates    : Array[0..11] of Integer;
      PeriodToDates      : Array[0..11] of Integer;
   end;

   TClientStatusReport = class( TBKReport)
   protected
      ReportOptions      : TStatusRepOptions;
      MonthsToShow       : integer;
      CSList             : TClientStatusList;
   end;

   TAccountBasedReport = class( TBKReport)
   protected
      IncludeDeletedAccounts : boolean;
      IncludeAllAccounts     : boolean;
      IncludeActive          : boolean;
      IncludeInactive        : boolean;
      IncludeNew             : boolean;
      IncludeNotReceived     : boolean;
      IncludeUnallocated     : boolean;
      //InactiveSince          : Integer;
   end;

   TTaskListReport = class( TBKReport)
   protected
      TaskList : TList;
   end;

   TAllTaskListReport = class (TBKReport)
   protected
      ClientList: TStringList;
   end;

   TAdminChargesReport = class (TBKReport)
   protected
      Data : TtsGrid;
      ChargesList : TChargesList;
      ExportType: Byte;
      IsIncreasedCharges: Boolean;
   end;

   PCodingOptimisationRec = ^TCodingOptimisationRec;
   TCodingOptimisationRec = record
     ClientLRN           : Integer;
     ClientCode          : string[8];
     ClientName          : string[60];
     StaffMember         : string[60];
     Group               : integer;
     ClientType          : string[60];
     MemorisationCount   : integer;
     AnalysisCount       : integer;
     PayeeCount          : integer;
     ManualCount         : integer;
     MasterMemCount      : integer;
     ManSuperCount       : integer;
     UnCodedCount        : integer;
     NotesCount          : integer;
     DateRange           : TDateRange;
   end;

   TCodingOptimisationReport = class(TBKReport)
   protected
     ReportOptions      : TCodingOptimisationOptions;
     MonthsToShow       : integer;
     ClientList         : TList;
     procedure ClearClientList;
   public
     constructor Create;
     destructor Destroy; override;
   end;

   TAuditReport = class(TBKReport)
   protected
     ReportOptions      : TAuditReportOptions;
     ClientList         : TList;
     procedure ClearClientList;
   public
     constructor Create; 
     destructor Destroy; override;
   end;

const
  UnitName = 'RPTADMIN';
  FORMAT_AMOUNT = '#,##0.00;(#,##0.00)';
  FORMAT_AMOUNT_TOTAL = '$#,##0.00;$(#,##0.00)';

var
   DebugMe : boolean = false;
   ProvisionalReport : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddAdminHeader(Job : TBKReport);
begin
   AddCommonHeader(Job,AdminSystem.fdFields.fdPractice_Name_for_Reports);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure GroupDetail (Sender: TObject);
var I: Integer;
    ll: TStringList;
begin
   with TBKReport(Sender) do begin
      ll := TStringList.Create;
      try
         with AdminSystem, fdSystem_Group_List do
            for i := 0 to Pred(itemCount) do
               with Group_At(i)^ do
                  ll.AddObject(Uppercase(grName),TObject(Group_At(i)));
         ll.Sort;
         for I := 0 to ll.Count - 1 do
            with pGroup_Rec(ll.Objects[I])^ do begin
               PutString( grName);
               RenderDetailLine;
            end;
      finally
         ll.Free;
      end;
   end;
end;

procedure DoGroupList(var Dest : TReportDest);
var
  Job: TBKReport;
  cLeft: Double;
begin
  Job := TBKReport.Create(rptOther);
  try
    //Set Options

    Job.IsAdmin                := True;
    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[List_Groups]);

    {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'List Groups',true);

    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := GCLeft;
    AddColAuto(Job,cLeft,60,GcGap,'Group',jtLeft);

    AddCommonFooter(Job);

    Job.OnBKPrint := GroupDetail;
    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;




// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ClientTypeDetail (Sender : TObject);
var I: Integer;
    ll: TStringList;
begin
   with TBKReport( Sender ) do begin
      ll := TStringList.Create;
      try
         with AdminSystem, fdSystem_Client_Type_List do
           for i := 0 to Pred(itemCount) do
              with Client_Type_At(i)^ do
                ll.AddObject(Uppercase(ctName),TObject(Client_Type_At(i)));
         ll.Sort;
         for I := 0 to ll.Count - 1 do
            with pClient_Type_Rec(ll.Objects[I])^ do begin
              PutString(ctName);
              RenderDetailLine;
            end;
      finally
         LL.Free;
      end;
   end;
end;

procedure DoClientTypelistList(var Dest : TReportDest);
var
  Job: TBKReport;
  cLeft: Double;
begin
  Job := TBKReport.Create(rptOther);
  try
    //Set Options

    Job.IsAdmin                := True;
    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[List_Client_Types]);

    {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'List Client Types',true);

    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := GCLeft;
    AddColAuto(Job,cLeft,60,GcGap,'Client Type',jtLeft);

    AddCommonFooter(Job);

    Job.OnBKPrint := ClientTypeDetail;
    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RenderFilesDownloaded(Sender : TObject; ColumnCount : Integer);
var
  Count : integer;
  OnDate : integer;
  i, j : integer;
  dl : pSystem_Disk_Log_Rec;
begin
  Count  := 0;
  OnDate := 0;
  for i := AdminSystem.fdSystem_Disk_Log.First to AdminSystem.fdSystem_Disk_Log.Last do begin
    dl := AdminSystem.fdSystem_Disk_Log.Disk_Log_At(i);
    if dl.dlWas_In_Last_Download then begin
      Inc( Count);
      OnDate := dl^.dlDate_Downloaded;
    end;
  end;

  with TBKReport( Sender ) do begin
    RenderTitleLine( 'Files Downloaded');
    if Count > 0 then begin
      RenderTextLine( inttostr( Count) + ' files downloaded on ' + bkDate2Str( OnDate));
    end;
    for i := AdminSystem.fdSystem_Disk_Log.First to AdminSystem.fdSystem_Disk_Log.Last do begin
      dl := AdminSystem.fdSystem_Disk_Log.Disk_Log_At(i);
      if dl.dlWas_In_Last_Download then begin
        SkipColumn;
        PutString( dl.dlDisk_ID);
        for j := 2 to ColumnCount do
          PutString('');
        RenderDetailLine;
      end;
    end;
    RenderTextLine('');
    RenderRuledLine;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DownloadReportDetail(Sender : TObject);
var
  i           : integer;
  Count       : integer;
  NotReceivedCount    : integer;  //not received in last download
  MarkedAsDeletedCount    : integer;  //marked as deleted
  S           : string;
begin
  with TAccountBasedReport(Sender), AdminSystem, AdminSystem.fdSystem_Bank_Account_List do
  begin
    if IncludeAllAccounts then begin
      //All Accounts Section
      Count := 0;
      NotReceivedCount := 0;
      MarkedAsDeletedCount := 0;

      RenderTitleLine('ALL ACCOUNTS');

      for i := 0 to Pred(ItemCount) do with System_Bank_Account_At(i)^ do begin
         inc(Count);
         if ( sbMark_As_Deleted) then inc( MarkedAsDeletedCount);

         //skip account if not including deleted accounts
         if ( not IncludeDeletedAccounts) and ( sbMark_As_Deleted) then
            Continue;

         if not(sbAccount_Type in [sbtData, sbtProvisional]) then
         begin
          Dec(Count);
          Continue;
         end;

         //render account number
         S := sbAccount_Number;

         if not sbWas_On_Latest_Disk then begin
            S := S + ' (*)';
            Inc( NotReceivedCount);
         end;
         if sbMark_As_Deleted then
            S := S + ' (**)';
         PutString( S);

         //Account Name
         S := sbAccount_Name;
         if IsForexCode(fdFields.fdCountry,sbCurrency_Code) then
            S := format('%s (%s)',[S,sbCurrency_Code]);
         PutString(S);

         if sbWas_On_Latest_Disk then begin
            PutString(bkDate2Str(sbFrom_Date_This_Month));
            PutString(bkDate2Str(sbTo_Date_This_Month));
            PutInteger(sbNo_of_Entries_This_Month);
         end
         else begin
            SkipColumn;
            SkipColumn;
            SkipColumn;
         end;
         RenderDetailLine;
      end;
      RenderTextLine('');

      if Count > 1 then begin
         RenderTextLine(Format('There are %d accounts in your %s database.',[Count, SHORTAPPNAME]));
      end
      else begin
         if Count = 1 then
            RenderTextLine(Format('There is one account in your %s database.',[SHORTAPPNAME]))
         else
            RenderTextLine(Format('There are no accounts in your %s database.',[SHORTAPPNAME]));
      end;

      if NotReceivedCount > 0 then
         RenderTextLine('(*) = Account not received in last download');
      if MarkedAsDeletedCount > 0 then
         if IncludeDeletedAccounts then
            RenderTextLine('(**) = Account marked as deleted')
         else
            RenderTextLine( inttostr( MarkedAsDeletedCount) + ' account(s) were not shown because they are marked as deleted');
    end;

    //New Accounts Section
    if IncludeNew then begin
      Count := 0;
      RenderTitleLine('NEW ACCOUNTS');
      for i := 0 to Pred(ItemCount) do with System_Bank_Account_At(i)^ do begin
         if sbNew_This_Month then begin
            PutString(sbAccount_Number);
            PutString(sbAccount_Name);
            PutString(bkDate2Str(sbFrom_Date_This_Month));
            PutString(bkDate2Str(sbTo_Date_This_Month));
            PutInteger(sbNo_of_Entries_This_Month);
            RenderDetailLine;
            inc(Count);
         end;
      end;
      RenderTextLine('');

      if Count > 1 then
      RenderTextLine(Format('There were %d new accounts received in this download.',[Count]))
      else begin
         if Count = 1 then
            RenderTextLine('There was one new account received in this download.')
         else
            RenderTextLine('There were no new accounts received in this download.');
      end;
    end;

    //Active Accounts   - on disk and have entries
    if IncludeActive then begin
      Count := 0;
      MarkedAsDeletedCount := 0;

      RenderTitleLine('ACTIVE ACCOUNTS');
      for i := 0 to Pred(ItemCount) do with System_Bank_Account_At(i)^ do begin
         if (sbWas_On_Latest_Disk and (sbNo_of_Entries_This_Month > 0)) then begin
            inc(Count);
            if ( sbMark_As_Deleted) then inc( MarkedAsDeletedCount);

            //skip account if not including deleted accounts
            if ( not IncludeDeletedAccounts) and ( sbMark_As_Deleted) then
               Continue;

            //render account number
            S := sbAccount_Number;
            if sbMark_As_Deleted then S := S + ' (**)';
            PutString( S);
            PutString(sbAccount_Name);
            PutString(bkDate2Str(sbFrom_Date_This_Month));
            PutString(bkDate2Str(sbTo_Date_This_Month));
            PutInteger(sbNo_of_Entries_This_Month);
            RenderDetailLine;
         end;
      end;
      RenderTextLine('');

      if Count > 1 then
         RenderTextLine(Format('There were %d active accounts received in this download.',[Count]))
      else begin
         if Count = 1 then
            RenderTextLine('There was one active account received in this download.')
         else
            RenderTextLine('There were no active accounts received in this download.');
      end;
      if MarkedAsDeletedCount > 0 then
         if IncludeDeletedAccounts then
            RenderTextLine('(**) = Account marked as deleted')
         else
            RenderTextLine( inttostr( MarkedAsDeletedCount) + ' account(s) were not shown because they are marked as deleted');
    end;

    //Inactive Accounts   - on disk but no entries
    if IncludeInactive then begin
      Count := 0;
      MarkedAsDeletedCount := 0;

      RenderTitleLine('INACTIVE ACCOUNTS');
      RenderTextLine('(The following accounts were received in the last download but did not have any transactions)');

      for i := 0 to Pred(ItemCount) do with System_Bank_Account_At(i)^ do begin
         if (sbWas_On_Latest_Disk and (sbNo_of_Entries_This_Month = 0)) then begin
            inc(Count);
            if ( sbMark_As_Deleted) then inc( MarkedAsDeletedCount);

            //skip account if not including deleted accounts
            if ( not IncludeDeletedAccounts) and ( sbMark_As_Deleted) then
               Continue;

            //render account number
            S := sbAccount_Number;
            if sbMark_As_Deleted then S := S + ' (**)';
            PutString( S);
            PutString(sbAccount_Name);
            PutString(bkDate2Str(sbFrom_Date_This_Month));
            PutString(bkDate2Str(sbTo_Date_This_Month));
            PutInteger(sbNo_of_Entries_This_Month);
            RenderDetailLine;
         end;
      end;
      RenderTextLine('');

      if Count > 1 then
         RenderTextLine(Format('There were %d inactive accounts received in this download.',[Count]))
      else begin
         if Count = 1 then
            RenderTextLine('There was one inactive account received in this download.')
         else
            RenderTextLine('There were no inactive accounts received in this download.');
      end;
      if MarkedAsDeletedCount > 0 then
         if IncludeDeletedAccounts then
            RenderTextLine('(**) = Account marked as deleted')
         else
            RenderTextLine( inttostr( MarkedAsDeletedCount) + ' account(s) were not shown because they are marked as deleted');
    end;

    //No Data Received
    if IncludeNotReceived then begin
      MarkedAsDeletedCount := 0;

      RenderTitleLine('NO DATA RECEIVED FOR THE FOLLOWING ACCOUNTS');
      for i := 0 to Pred(ItemCount) do with System_Bank_Account_At(i)^ do begin
          if (not sbWas_On_Latest_Disk) and (sbAccount_Type = sbtData) then begin
             if ( sbMark_As_Deleted) then inc( MarkedAsDeletedCount);

             //skip account if not including deleted accounts
             if ( not IncludeDeletedAccounts) and ( sbMark_As_Deleted) then
                Continue;

            S := sbAccount_Number;
            if sbMark_As_Deleted then S := S + ' (**)';
            PutString( S);

            PutString(sbAccount_Name);
            PutString(bkDate2Str(sbFrom_Date_This_Month));
            PutString(bkDate2Str(sbTo_Date_This_Month));
            PutInteger(sbNo_of_Entries_This_Month);
            RenderDetailLine;
         end;
      end;
      RenderTextLine('');

      RenderTextLine('Note: These accounts may have been deleted from the ' + SHORTAPPNAME + ' service.');
      if MarkedAsDeletedCount > 0 then
         if IncludeDeletedAccounts then
            RenderTextLine('(**) = Account marked as deleted')
         else
            RenderTextLine( inttostr( MarkedAsDeletedCount) + ' account(s) were not shown because they are marked as deleted');
    end;

    //Unallocated Accounts - Attach_required still true
    if IncludeUnallocated then begin
      Count := 0;
      MarkedAsDeletedCount := 0;

      RenderTitleLine('UNALLOCATED ACCOUNTS');
      for i := 0 to Pred(ItemCount) do with System_Bank_Account_At(i)^ do begin
         if sbAttach_Required then begin
            inc(Count);
            if ( sbMark_As_Deleted) then inc( MarkedAsDeletedCount);
            //skip account if not including deleted accounts
            if ( not IncludeDeletedAccounts) and ( sbMark_As_Deleted) then
               Continue;

            S := sbAccount_Number;
            if sbMark_As_Deleted then S := S + ' (**)';
            PutString( S);

            PutString(sbAccount_Name);
            PutString(bkDate2Str(sbFrom_Date_This_Month));
            PutString(bkDate2Str(sbTo_Date_This_Month));
            PutInteger(sbNo_of_Entries_This_Month);
            RenderDetailLine;
         end;
      end;
      RenderTextLine('');

      if Count > 1 then
      RenderTextLine(Format('There are %d unallocated accounts.',[Count]))
      else begin
         if Count = 1 then
            RenderTextLine('There is one unallocated account.')
         else
            RenderTextLine('There are no unallocated accounts.');
      end;
      if MarkedAsDeletedCount > 0 then
         if IncludeDeletedAccounts then
            RenderTextLine('(**) = Account marked as deleted')
         else
            RenderTextLine( inttostr( MarkedAsDeletedCount) + ' account(s) were not shown because they are marked as deleted');
    end;

    //display download report
    RenderFilesDownloaded(Sender, 4);

  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoDownloadReport(var Dest : TReportDest);
var
  Job           : TAccountBasedReport;
  ButtonPressed : integer;
  Opt: integer;
  HideDeleted: boolean;
  cLeft: Double;
begin
  Opt := AdminSystem.fdFields.fdDownload_Report_Options;
  HideDeleted := AdminSystem.fdFields.fdDownload_Report_Hide_Deleted;

  if not UpdateDownloadReportOptions( 'Download Report', ButtonPressed) then begin
     Dest := rdNone;
     exit;
  end;
  case ButtonPressed of
     BTN_PRINT    : Dest := rdPrinter;
     BTN_PREVIEW  : Dest := rdScreen;
     BTN_FILE     : Dest := rdFile;
  else
     Dest := rdScreen;
  end;

  //see if options changed, update and save if changed
  if ( Opt <> AdminSystem.fdFields.fdDownload_Report_Options) or
     ( HideDeleted <> AdminSystem.fdFields.fdDownload_Report_Hide_Deleted) then
  begin
    Opt := AdminSystem.fdFields.fdDownload_Report_Options;
    HideDeleted := AdminSystem.fdFields.fdDownload_Report_Hide_Deleted;

    if LoadAdminSystem( True, 'DoDownloadReport') then
    begin
      AdminSystem.fdFields.fdDownload_Report_Options := Opt;
      AdminSystem.fdFields.fdDownload_Report_Hide_Deleted := HideDeleted;
      SaveAdminSystem;
    end;
  end;

  Job := TAccountBasedReport.Create(rptOther);
  try
    //Set Options
    Opt := AdminSystem.fdFields.fdDownload_Report_Options;
    Job.IncludeDeletedAccounts := not AdminSystem.fdFields.fdDownload_Report_Hide_Deleted;
    Job.IncludeAllAccounts     := (Opt = 0) or (Opt and optAllAccounts = optAllAccounts);
    Job.IncludeActive          := (Opt = 0) or (Opt and optActive = optActive);
    Job.IncludeInactive        := (Opt = 0) or (Opt and optInactive = optInactive);
    Job.IncludeNew             := (Opt = 0) or (Opt and optNew = optNew);
    Job.IncludeNotReceived     := (Opt = 0) or (Opt and optNotReceived = optNotReceived);
    Job.IncludeUnallocated     := (Opt = 0) or (Opt and optUnallocated = optUnallocated);
    Job.IsAdmin                := True;
    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_DOWNLOAD]);

    {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'DOWNLOAD REPORT',true);

    if not Job.IncludeDeletedAccounts then
       AddJobHeader( Job,SiSubtitle, 'excludes accounts marked as deleted', true);
    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := GCLeft;
    AddColAuto(Job,cLeft,25.6,GcGap,'Account No',jtLeft);
    AddColAuto(Job,cLeft,31.3,GcGap,'Account Name',jtLeft);
    AddColAuto(Job,cLeft, 9.2,GcGap,'From',jtLeft);
    AddColAuto(Job,cLeft,10.3,GcGap,'To',jtLeft);
    AddColAuto(Job,cLeft, 9.7,GcGap,'Trx',jtLeft);

    AddCommonFooter(Job);

    Job.OnBKPrint := DownloadReportDetail;
    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TToDoList }
function TToDoList.CD_Rec_At(Index: Integer): pClientDueRec;
begin
  Result := At( Index );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TToDoList.FreeItem(Item: Pointer);
begin
  //do nothing.. items should never be freed as they are owned by the admin system
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure WhatsDueDetail(Sender : TObject);
const
  ThisMethodName = 'WhatsDueDetail';

  procedure PrintClient(Sender : TObject; CDRec : pClientDueRec);
  var
    DateFrom,
    DateTo : integer;
    Value  : String;
  begin
    with TReportsDueReport(Sender) do
    begin
      with CDRec^ do
      begin
        DateTo   := AdminSystem.fdFields.fdPrint_Reports_Up_To;
        DateFrom := Get_Reporting_Period_Start_Date( DateTo, cdReporting_Period );
        Value := cdCode;
        if (not (cdFileStatus = bkConst.fsNormal)) then
          Value := Value + '*';
        if cdUnprintedLastMonth then
          Value := Value + '#';
        PutString(Value);
        PutString(cdName);
        PutString(bkDate2Str(DateFrom));
        PutString(bkdate2Str(DateTo));

        if ( cdReportsToSend and srsCoding) = srsCoding then
          PutString('Yes')
        else
          PutString('');

        if ( cdReportsToSend and srsChart) = srsChart then
          PutString('Yes')
        else
          PutString('');

        if ( cdReportsToSend and srsPayee) = srsPayee then
          PutString('Yes')
        else
          PutString('');

        if ( cdReportsToSend and srsJob) = srsJob then
          PutString('Yes')
        else
          PutString('');

        if AdminSystem.fdFields.fdSort_Reports_By <> srsoStaffMember then
          PutString(cdUser_Name);

        case cdDestination of
          srdNone: SkipColumn;
          srdPrinted: PutString( 'Printer');
          srdEmail: PutString( 'E-Mail');
          srdFax: PutString( 'Fax');
          srdECoding: PutString( glConst.ECODING_APP_NAME);
          srdCSVExport: PutString( 'CSV Export');
          srdWebX: PutString(glConst.WEBX_GENERIC_APP_NAME);
          srdCheckOut: PutString('BankLink Books');
          srdBusinessProducts: PutString('Business Prod');
        else
          SkipColumn;
        end;

        RenderDetailLine;

      end;
    end;
  end;

  procedure PrintClientsForUser(Sender : TObject; StaffLRN : integer);
  var
    i : integer;
    CDRec : pClientDueRec;
  begin
    with TReportsDueReport(Sender) do
    begin
      for i := 0 to Pred(ToDoList.ItemCount) do
      begin
        CDRec := ToDoList.CD_Rec_At(i);
        if CDRec^.cdUser_Responsible = StaffLRN then
          PrintClient(Sender, CDRec);
      end;
    end;
  end;

  procedure PrintClientsForGroup(Sender: TObject; GroupLRN: integer);
  var
    I: Integer;
    CDRec: pClientDueRec;
    Report: TReportsDueReport;
  begin
    Report := TReportsDueReport(Sender);
    for I := 0 to Report.ToDoList.ItemCount - 1 do
    begin
      CDRec := Report.ToDoList.CD_Rec_At(i);
      if CDRec^.cdGroup = GroupLRN then
        PrintClient(Sender, CDRec);
    end;
  end;

  procedure PrintClientsForClientType(Sender: TObject; ClientTypeLRN: integer);
  var
    I: Integer;
    CDRec: pClientDueRec;
    Report: TReportsDueReport;
  begin
    Report := TReportsDueReport(Sender);
    for I := 0 to Report.ToDoList.ItemCount - 1 do
    begin
      CDRec := Report.ToDoList.CD_Rec_At(i);
      if CDRec^.cdClient_Type = ClientTypeLRN then
        PrintClient(Sender, CDRec);
    end;
  end;

var
  i,j,k : integer;
  CDRec : pClientDueRec;
  pGroup: pGroup_Rec;
  pClientType: pClient_Type_Rec;
begin //WhatsDueDetail
  if DebugMe then
     LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  with TReportsDueReport(Sender) do
  begin
    //We dont expect and further reloads of the admin system after this point.  This means that the
    //CFRec pointers can be safely used.
    UpdateAppStatus( 'Preparing Report', '', 75);

    case AdminSystem.fdFields.fdSort_Reports_By of
      srsoStaffMember:
      begin
         //cycle thru client who have a staff member assigned
        for i := 0 to Pred( AdminSystem.fdSystem_User_List.ItemCount) do
           with AdminSystem.fdSystem_User_List.User_At(i)^ do
           begin
             //see if any clients for this staff member
             j := 0;
             while (j < ToDoList.ItemCount)
               and (ToDoList.CD_Rec_At(j)^.cdUser_Responsible <> usLRN) do
                  Inc(j);

             if (j < ToDoList.ItemCount) then
             begin
               RenderTitleLine(usCode+' : '+usName);
               PrintClientsForUser(Sender, usLRN);
             end;
           end;

        //now print for clients with no staff member assigned
        j := 0;
        while (j < ToDoList.ItemCount)
          and (ToDoList.CD_Rec_At(j)^.cdUser_Responsible <> 0) do
             Inc(j);

        if (j < ToDoList.ItemCount) then
        begin
          RenderTitleLine('NOT YET ALLOCATED');
          PrintClientsForUser(Sender, 0);
        end;
        //now print for clients with unknown staff member assigned
        j := 0;
        while (j < ToDoList.ItemCount)
          and (ToDoList.CD_Rec_At(j)^.cdUser_Responsible <> -1) do
             Inc(j);

        if (j < ToDoList.ItemCount) then
        begin
          RenderTitleLine('ALLOCATED TO UNKNOWN STAFF MEMBERS');
          PrintClientsForUser(Sender, -1);
        end;
      end;
      srsoGroup:
      begin
        //cycle through clients with groups assigned
        for i := 0 to AdminSystem.fdSystem_Group_List.ItemCount - 1 do
        begin
          pGroup := AdminSystem.fdSystem_Group_List.Group_At(i);
          for j := 0 to ToDoList.ItemCount - 1 do
          begin
            if ToDoList.CD_Rec_At(j)^.cdGroup = pGroup.grLRN then
            begin
              RenderTitleLine(pGroup^.grName);
              PrintClientsForGroup(Sender, pGroup^.grLRN);
              break;
            end;
          end;
        end;

        //now print for clients with no groups assigned
        for j := 0 to ToDoList.ItemCount - 1 do
        begin
          if ToDoList.CD_Rec_At(j).cdGroup = 0 then
          begin
            RenderTitleLine('NOT YET ALLOCATED');
            PrintClientsForGroup(Sender, 0);
            break;
          end;
        end;
      end;
      srsoClientType:
      begin
        for i := 0 to AdminSystem.fdSystem_Client_Type_List.ItemCount - 1 do
        begin
          pClientType := AdminSystem.fdSystem_Client_Type_List.Client_Type_At(i);
          for j := 0 to ToDoList.ItemCount - 1 do
          begin
            if ToDoList.CD_Rec_At(j)^.cdClient_Type = pClientType.ctLRN then
            begin
              RenderTitleLine(pClientType^.ctName);
              PrintClientsForClientType(Sender, pClientType^.ctLRN);
              break;
            end;
          end;
        end;
                //now print for clients with no groups assigned
        for j := 0 to ToDoList.ItemCount - 1 do
        begin
          if ToDoList.CD_Rec_At(j).cdClient_Type = 0 then
          begin
            RenderTitleLine('NOT YET ALLOCATED');
            PrintClientsForClientType(Sender, 0);
            break;
          end;
        end;
      end
      else //client order
        for i := 0 to Pred(ToDoList.ItemCount) do begin
          CDRec := ToDoList.CD_Rec_At(i);
          PrintClient(Sender, CDRec);
        end;
    end;
    i := 0;
    j := 0;
    k := 0;
    while (i < ToDoList.ItemCount)
      and (j = 0) do begin
         CDRec := ToDoList.CD_Rec_At(i);
         if (CDRec^.cdFileStatus = bkConst.fsNormal) then
            Inc(i)
         else
            j := 1;
         if CDRec^.cdUnprintedLastMonth then
           inc(k);
       end;

    if (j = 1)
    or (k > 0) then
      RenderTextLine('');

    if (j = 1) then
       RenderTextLine('* Reports may not be generated for these clients, they are currently checked out, off-site, or open.')
    else if k > 0 then
       RenderTextLine('# These clients have unprinted transactions from the previous month - these transactions are automatically included.');
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoReportsDue(var Dest : TReportDest; srOptions : TSchReportOptions);
const
  ThisMethodName = 'DoReportsDue';
var
  Job : TReportsDueReport;
  //SortByStaffMember : boolean;
  DoMe      : boolean;
  i : Integer;
  cKey1,
  cKey2     : string;
  sKey1,
  sKey2     : string;
  pUser     : pUser_Rec;
  CFRec     : pClient_File_Rec;
  pCD       : pClientDueRec;
  TempClientList : TStringList;
  ButtonPressed : integer;
  UserRec   : pUser_Rec;
  UnprintedLastMonth : Boolean;
  EarliestDate: Integer;
  cLeft: Double;
  SortBy: Integer;
  pGroup: pGroup_Rec;
  SortByName: string;
  pClientType : PClient_Type_Rec;
  GroupRec: pGroup_Rec;
  ClientTypeRec: pClient_Type_Rec;
begin
  if AdminSystem.fdFields.fdPrint_Reports_Up_To = 0 then begin
     HelpfulInfoMsg('You must do a download before running this report',0);
     exit;
  end;
  if Assigned(MyClient) then
    CloseClientHomePage;

  if ( Dest = rdAsk) then begin
     //ask user for destination, allow to set options
     if SimpleSelectReportDest(Report_List_Names[ REPORT_WHATSDUE], ButtonPressed) then begin
        case ButtonPressed of
           BTN_PRINT    : Dest := rdPrinter;
           BTN_PREVIEW  : Dest := rdScreen;
           BTN_FILE     : Dest := rdFile;
        else
           Dest := rdScreen;
        end;
     end
     else begin
        Dest := rdNone;
        exit;
     end;
  end;

  ShowClientNameOnReportStatus := true;

  Job := TReportsDueReport.Create(rptOther);
  try
    Job.IsAdmin := True;
    SortBy := AdminSystem.fdFields.fdSort_Reports_By;
    if SortBy = srsoClientCode then
    begin
      cKey1 := srOptions.srFromCode;
      cKey2 := srOptions.srToCode + 'þ';

      sKey1 := '';
      sKey2 := 'þ';
    end
    else
    begin
     cKey1 := '';
     cKey2 := 'þ';

     sKey1 := Trim( srOptions.srFromCode);
     sKey2 := Trim( srOptions.srToCode) + 'þ';
    end;

    Job.ToDoList := TToDoList.Create;
    try
      Application.BringToFront;
      Application.ProcessMessages;
      TempClientList := TStringList.Create;
      try
        //build a temporary list of client codes to use.  ScheduledReportsDue may reload the admin system
        for i := 0 to Pred(AdminSystem.fdSystem_Client_File_List.ItemCount) do begin
          CFRec := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
          //see if client is in selected range
          if (SortBy <> srsoClientCode) or
             (((CFRec^.cfFile_Code >= cKey1) and ( CFRec^.cfFile_Code <= cKey2) and (srOptions.srCodeSelection.Count = 0)) or
              ((srOptions.srCodeSelection.IndexOf(CFRec^.cfFile_Code) > -1))) then
            TempClientList.AddObject( CFRec^.cfFile_Code, TObject( 0)); //flagged false
        end;
        Application.BringToFront;
        Application.ProcessMessages;
        //now see if should include the client in the list of clients for whom reports are due
        EarliestDate := 0;
        for i := 0 to ( TempClientList.Count - 1) do
        begin
          CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( TempClientList.Strings[ i]);
          if Assigned( CFRec) then
          begin
            case SortBy of
              srsoStaffMember:
                begin
                  //see if client belongs to a staff member that is in range
                  //see what user code is for staff member assigned to this client
                  DoMe  := false;
                  pUser := AdminSystem.fdSystem_User_List.FindLRN( CFRec^.cfUser_Responsible);
                  if Assigned( pUser) then
                     DoMe := (( pUser.usCode >= sKey1) and ( pUser.usCode <= sKey2) and (srOptions.srCodeSelection.Count = 0)) or
                             (srOptions.srCodeSelection.IndexOf(pUser.usCode) > -1)
                  else
                  begin
                     //no user record exists,  see if should include unallocated clients.
                     //If the to code is blank then we include unallocated clients
                     if ( sKey2 = 'þ') and ((srOptions.srCodeSelection.Count = 0) or (srOptions.srCodeSelection.IndexOf(' ') > -1)) then
                        DoMe := true;
                  end;
                end;
              srsoGroup:
                begin
                  DoMe := false;
                  pGroup := AdminSystem.fdSystem_Group_List.FindLRN(CFRec.cfGroup_LRN);

                  if Assigned ( pGroup) then
                  begin
                    SortByName := UpperCase(pGroup.grName);
                    DoMe := ((SortByName >= sKey1) and (SortByName <= sKey2) and (srOptions.srCodeSelection.Count = 0)) or
                            (srOptions.srCodeSelection.IndexOf(SortByName) > -1)
                  end
                  else
                  begin
                    if (sKey2 = 'þ') and ((srOptions.srCodeSelection.Count = 0) or (srOptions.srCodeSelection.IndexOf(' ') > -1)) then
                      DoMe := true;
                  end;
                end;
              srsoClientType:
                begin
                  DoMe := false;
                  pClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(CFRec.cfClient_Type_LRN);

                  if Assigned ( pClientType) then
                  begin
                    SortByName := UpperCase(pClientType.ctName);
                    DoMe := ((SortByName >= sKey1) and (SortByName <= sKey2) and (srOptions.srCodeSelection.Count = 0)) or
                            (srOptions.srCodeSelection.IndexOf(SortByName) > -1)
                  end
                  else
                  begin
                    if (sKey2 = 'þ') and ((srOptions.srCodeSelection.Count = 0) or (srOptions.srCodeSelection.IndexOf(' ') > -1)) then
                      DoMe := true;
                  end;
                end
              else //ClientCode (selected above)
                DoMe := true;
            end;
            if TempClientList.Count > 50 then
              UpdateAppStatus( 'Processing Scheduled Reports Clients...',CFRec.cfFile_Code,(i/TempClientList.Count)*100);
            if DoMe then
            begin
              //see if reports are due.  May Cause Reloading of Admin System
              if Scheduled.ScheduledReportsDue(cfRec, srOptions, UnprintedLastMonth, EarliestDate) then
                //Flag the client as needing reports
                if UnprintedLastMonth then
                  TempClientList.Objects[ i] := TObject( 2) //flagged true and has some from last month
                else
                  TempClientList.Objects[ i] := TObject( 1); //flagged true
            end;
          end;
        end;

       if ((EarliestDate < AdminSystem.fdFields.fdPrint_Reports_From) or (AdminSystem.fdFields.fdPrint_Reports_From = 0)) and
           LoadAdminSystem(true, ThisMethodName + ThisMethodName) then
       begin
         AdminSystem.fdFields.fdPrint_Reports_From := EarliestDate;
         SaveAdminSystem;
       end;

        //now load the ToDo list with TempClientList clients
        for i := 0 to ( TempClientList.Count - 1) do
        begin
           if (Integer( TempClientList.Objects[ i]) = 1) or (Integer( TempClientList.Objects[ i]) = 2) then //flagged true
           begin
              CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( TempClientList.Strings[ i]);
              if Assigned(CFRec) then
              begin
                SafeGetMem( pCD, SizeOf( TClientDueRec));  //will be freed when result list destroyed
                FillChar( pCD^, SizeOf( TClientDueRec), #0);
                pCD^.cdCode  := CFRec^.cfFile_Code;
                pCD^.cdName  := CFRec^.cfFile_Name;

                pCD^.cdUser_Responsible := CFRec^.cfUser_Responsible;
                if pCD^.cdUser_Responsible <> 0 then
                begin
                  UserRec :=  AdminSystem.fdSystem_User_List.FindLRN(CFRec^.cfUser_Responsible);
                  if (Assigned(UserRec)) then
                    pCD^.cdUser_Name := UserRec^.usName
                  else
                    pCD^.cdUser_Responsible := -1;
                end;

                pCD^.cdGroup := CFRec^.cfGroup_LRN;
                if pCD^.cdGroup <> 0 then
                begin
                  GroupRec := AdminSystem.fdSystem_Group_List.FindLRN(pCD^.cdGroup);
                  if not Assigned(GroupRec) then
                    pCD^.cdGroup := 0;
                end;

                pCD^.cdClient_Type := CFRec^.cfClient_Type_LRN;
                if pCD^.cdClient_Type <> 0 then
                begin
                  ClientTypeRec := AdminSystem.fdSystem_Client_Type_List.FindLRN(pCD^.cdClient_Type);
                  if not Assigned(ClientTypeRec) then
                    pCD^.cdClient_Type := 0;
                end;

                pCD^.cdReporting_Period := GetReportingPeriodToUse( CFRec^.cfReporting_Period,
                                                                    CFRec^.cfReport_Start_Date,
                                                                    CFRec^.cfLast_Print_Reports_Up_To,
                                                                    AdminSystem.fdFields.fdPrint_Reports_Up_To,
                                                                    srOptions.srPrintAll);
                pCD^.cdDestination := CFRec^.cfSchd_Rep_Method;
                pCD^.cdReportsToSend := CFRec^.cfSched_Rep_Reports_To_Send;
                pCD^.cdFileStatus := CFRec^.cfFile_Status;
                pCD^.cdUnprintedLastMonth := (Integer( TempClientList.Objects[ i]) = 2);
                Job.ToDoList.Insert(pCD);
              end;
           end;
        end;
      finally
        TempClientList.Free;
        ClearStatus;
        ResetProcessWorkingSet;
        Application.BringToFront;
        Application.ProcessMessages;
      end;

      if (Job.ToDoList.ItemCount = 0) then
        HelpfulInfoMsg('There are no Scheduled Reports due.',0)
      else
      begin
        //construct report
        Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_WHATSDUE]);

        {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
        AddAdminHeader(Job);
        AddJobHeader(Job,SiTitle,'LIST REPORTS DUE',true);
        AddJobHeader(Job,siSubTitle,'',true);

        cLeft := GcLeft;
        AddColAuto(Job,cLeft, 9.0,GcGap,'Client Code',jtLeft);
        AddColAuto(Job,cLeft,30.0,GcGap,'Name',jtLeft);
        AddColAuto(Job,cLeft, 9.0,GcGap,'From',jtLeft);
        AddColAuto(Job,cLeft, 9.0,GcGap,'To',jtLeft);

        if (AdminSystem.fdFields.fdSort_Reports_By = srsoStaffMember) then
        begin
          AddColAuto(Job,cLeft,10.0,GcGap,'Coding',jtLeft);
          AddColAuto(Job,cLeft,8.0,GcGap,'Chart',jtLeft);
          AddColAuto(Job,cLeft,8.0,GcGap,'Payees',jtLeft);
          AddColAuto(Job,cLeft,6.0,GcGap,'Jobs',jtLeft);
        end
        else
        begin
          AddColAuto(Job,cLeft,6.0,GcGap,'Coding',jtLeft);
          AddColAuto(Job,cLeft,4.0,GcGap,'Chart',jtLeft);
          AddColAuto(Job,cLeft,4.0,GcGap,'Payees',jtLeft);
          AddColAuto(Job,cLeft,4.0,GcGap,'Jobs',jtLeft);
          AddColAuto(Job,cLeft,10,GcGap,'Staff Member', jtLeft);
        end;
        AddColAuto(Job,cLeft,9.9,GcGap,'Send To',jtLeft);

        AddCommonFooter(Job);

        Job.OnBKPrint := WhatsDueDetail;
        Job.ReportOptions := srOptions;
        Job.Generate( Dest);
      end;
    finally
      Job.ToDoList.Free;
      ClearStatus;
    end;
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure ClientsByStaffMemberDetail(Sender : TObject);
//print for each staff member, then print those not allocated
//page break between each
var
   HasForeignFiles : boolean;

   function  UserHasClients(StaffLRN : integer) : boolean;
   var
      i : integer;
      cfRec : pClient_File_Rec;
   begin
      result := false;
      //check that client files exist with this user code, 0 = no allocated
      if StaffLRN >= 0 then begin
         With AdminSystem.fdSystem_Client_File_List do begin
           for i := 0 to Pred(ItemCount) do begin
             cfRec := Client_File_At(i);
             if cfRec^.cfClient_Type = ctProspect then Continue; // Skip prospects
             if (cfRec^.cfUser_Responsible = StaffLRN) and (not cfRec^.cfForeign_File) then begin
                result := true;
                exit;
             end;
           end;
         end;
      end;

      //if looking for client files with unknown staff members, or foreign files
      //SPECIAL CASE ***
      if StaffLRN = -1 then begin
         with AdminSystem.fdSystem_Client_File_List do begin
            for i := 0 to Pred(ItemCount) do begin
               cfRec := Client_File_At( i);
               if cfRec^.cfClient_Type = ctProspect then Continue; // Skip prospects
               if ((cfRec^.cfUser_Responsible > 0) and
                  (AdminSystem.fdSystem_User_List.FindLRN( cfRec^.cfUser_Responsible) = nil)) or
                  ( cfRec^.cfForeign_File)
               then begin
                  Result := true;
                  Exit;
               end;
            end;
         end;
      end;
   end;

   procedure PrintClientsFor(StaffLRN : integer);
   var
     i : integer;
     cfRec : pClient_File_Rec;
   begin
      With TBKReport(Sender), AdminSystem.fdSystem_Client_File_List do begin
        for i := 0 to Pred(ItemCount) do begin
          cfRec := Client_File_At(i);
          if cfRec^.cfClient_Type = ctProspect then Continue; // Skip prospects
          if ( StaffLRN >= 0) then begin
             if (cfRec^.cfUser_Responsible = StaffLRN) and ( not cfRec^.cfForeign_File) then begin
                PutString(cfRec^.cfFile_Code);
                PutString(cfRec^.cfFile_Name);
                RenderDetailLine;
                Continue;
             end;
          end;

          //SPECIAL CASE ***
          if ( StaffLRN = -1) then begin
             //print unallocated then client files with unknown staff plus foreign files
             if (( cfRec^.cfUser_Responsible > 0) and
                ( AdminSystem.fdSystem_User_List.FindLRN( cfRec^.cfUser_Responsible) = nil)) or
                ( cfRec^.cfForeign_File)
             then begin
                if cfRec^.cfForeign_File then begin
                   PutString(cfRec^.cfFile_Code + ' *');
                   HasForeignFiles := true;
                end
                else
                   PutString(cfRec^.cfFile_Code);

                PutString(cfRec^.cfFile_Name);
                RenderDetailLine;
                Continue;
             end;
          end;
        end;
      end;
   end;

var
   i : integer;
   FirstPage : boolean;
begin
  FirstPage := true;  //stops it printing a blank page at the end

  with TBKReport(Sender), AdminSystem do
  begin
     with fdSystem_User_List do
        for i := 0 to Pred(itemCount) do
           with User_At(i)^ do begin
              if UserHasClients(usLRN) then begin
                 if not FirstPage then
                    ReportNewPage;
                 RenderTitleLine('CLIENTS FOR '+usCode+' : '+usName);
                 PrintClientsFor(usLRN);
                 FirstPage := false;
              end;
           end;

     //Now print unallocated clients
     if UserHasClients(0) then begin
        if not FirstPage then
           ReportNewPage;
        RenderTitleLine('CLIENTS NOT YET ALLOCATED');
        PrintClientsFor(0);
        FirstPage := false;
     end;

     //Now print client with unknown staff members
     HasForeignFiles := false;

     if UserHasClients( -1) then begin
        if not FirstPage then
           ReportNewPage;
        RenderTitleLine('CLIENTS ALLOCATED TO UNKNOWN STAFF MEMBERS');
        PrintClientsFor( -1);
        if HasForeignFiles then begin
           RenderTextLine('');
           RenderTextLine('* indicates that the client belongs to another admin system');
        end;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure DoClientsByStaffMember(var Dest : TReportDest);
var
  Job : TBKReport;
  cLeft: Double;
begin
  Job := TBKReport.Create(rptOther);
  try
    Job.IsAdmin := True;
    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_CLIENTS_BY_STAFF]);

    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'LIST CLIENTS BY STAFF MEMBER',true);
     AddJobHeader(Job,siSubTitle,'',true); 
    cLeft := GCLeft;
    AddColAuto(Job,cLeft,15.0,gCgap,'Code',jtLeft);
    AddColAuto(Job,cLeft,80.0,GcGap,'Name',jtLeft);

    AddCommonFooter(Job);

    Job.OnBKPrint := ClientsByStaffMemberDetail;
    Job.Generate(Dest);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure ClientReportOptionsDetail(Sender : TObject);
var
   i : integer;
   pUser : pUser_Rec;
begin
   with TBKReport(Sender), AdminSystem do
   begin
      with fdSystem_Client_File_List do
         for i := 0 to Pred(itemCount) do with Client_File_At(i)^ do begin

            // Skip prospects
            if Client_File_At(i)^.cfClient_Type = ctProspect then Continue;

            PutString(cfFile_Code);
            PutString(cfFile_Name);

            //Find staff member
            if cfUser_Responsible <> 0 then begin
               pUser := fdSystem_User_List.FindLRN(cfUser_Responsible);
               if Assigned(pUser) then begin
                  //If the users full name has not been entered then just show the users login code
                  if pUser^.usName = '' then
                     PutString(pUser^.usCode)
                  else
                     PutString(pUser^.usName);
               end
               else
                  SkipColumn;
            end
            else
               SkipColumn;

            //Report Options
            PutString(stDatetoDateString('NNN',cfReport_Start_Date,true));

            if cfReporting_Period in [roMin..roMax] then
              PutString(roNames[cfReporting_Period])
            else
              SkipColumn;

            if cfSchd_Rep_Method in [srdMin..srdMax] then
              PutString(srdNames[cfSchd_Rep_Method])
            else
              SkipColumn;            

            RenderDetailLine;
         end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure DoClientReportOptions(var Dest : TReportDest);
var
  Job : TBKReport;
  cLeft: Double;
begin
  Job := TBKReport.Create(rptOther);
  try
    Job.IsAdmin := True;
    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_CLIENT_REPORT_OPT]);

    {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'LIST CLIENT REPORT OPTIONS',true);
    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := GCLeft;
    AddColAuto(Job,cLeft, 9.5,Gcgap,'Code',jtLeft);
    AddColAuto(Job,cLeft,30.8,Gcgap,'Name',jtLeft);
    AddColAuto(Job,cLeft,19.6,Gcgap,'Staff Member',jtLeft);
    AddColAuto(Job,cLeft, 7.8,Gcgap,'Starts',jtLeft);
    AddColAuto(Job,cLeft,20.0,Gcgap,'Reporting Frequency',jtLeft);
    AddColAuto(Job,cLeft,20.0,Gcgap,'Destination',jtLeft);

    AddCommonFooter(Job);

    Job.OnBKPrint := ClientReportOptionsDetail;

    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DownloadLogDetail(Sender : TObject);
var
   i : integer;
begin
  with TBKReport(Sender), AdminSystem do
  begin
     with fdSystem_Disk_Log do
        for i := 0 to Pred(itemCount) do with Disk_Log_At(i)^ do begin
           PutString(dlDisk_ID);
           PutString(bkDate2Str(dlDate_Downloaded));
           PutInteger(dlNo_of_Accounts);
           PutCurrency(dlNo_of_Entries);

           RenderDetailLine;
        end;

     RenderDetailGrandTotal('');
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoDownloadLog(var Dest : TReportDest);
var
  Job : TBKReport;
  cLeft: Double;
begin
  Job := TBKReport.Create(rptOther);
  try
    Job.IsAdmin := True;  
    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_DOWNLOAD_LOG]);

    {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'DOWNLOAD LOG',true);
    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := GCLeft;
    AddColAuto(Job,cLeft,40.0,Gcgap,'Download ID',jtLeft);
    AddColAuto(Job,cLeft,13.0,Gcgap,'Date',jtLeft);
    AddColAuto(Job,cLeft,12.8,Gcgap,'Accounts',jtRight);

    AddFormatColAuto(Job,cLeft,12.3,GCGap,'Entries',jtRight,'0','0',True);
    AddCommonFooter(Job);

    Job.OnBKPrint := DownloadLogDetail;

    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   structure
      BankAccounts : TStringList

      when add bank account add an TStringList as the object also.  This list
      will hold the client codes;

   initialise structure

   read all bank accounts storing in TStringList

   read each client
     find the bank account and add the client code to that bank accounts list of clients

   update attach required flag in admin system from collected data

   print report
     print first line for each account.  skip client column if no clients
     print the additional client codes on subsequent lines.

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure LoadUpdateAdminBankAccounts( AccountList : TStringList; Provisional : boolean );
const
   ThisMethodName = 'LoadUpdateAdminBankAccounts';
var
   NewList : TStringList;
   i       : integer;
   FoundAt     : integer;
   sb          : pSystem_Bank_Account_Rec;
   am          : pClient_Account_Map_Rec;
   pf          : pClient_File_Rec;
   AccountType : integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   AccountList.Clear;
   if Provisional
    then AccountType := sbtProvisional
    else AccountType := sbtData;

   //add bank accounts to list with a tstring list to hold the client names
   with AdminSystem.fdSystem_Bank_Account_List do begin
      for i := 0 to Pred(ItemCount) do begin
         if System_Bank_Account_At(i).sbAccount_Type <> AccountType then Continue;
         NewList := TStringList.Create;
         // And add all clients from the client account map
         am := AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(System_Bank_Account_At(i)^.sbLRN);
         while Assigned(am) do
         begin
           pf := AdminSystem.fdSystem_Client_File_List.FindLRN(am^.amClient_LRN);
           if Assigned(pf) then
             NewList.Add(pf.cfFile_Code);
           am := AdminSystem.fdSystem_Client_Account_Map.FindNextClient(System_Bank_Account_At(i)^.sbLRN);
         end;
         AccountList.AddObject( System_Bank_Account_At(i)^.sbAccount_Number,NewList);
      end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Updating Attach_Required flags');
   //IMPORTANT -------------------------------------
   //Now update the un-attached flags for each account in the admin system.
   if LoadAdminSystem(true,ThisMethodName) then begin
      with AdminSystem.fdSystem_Bank_Account_List do
         for i := 0 to Pred(ItemCount) do begin
            sb := System_Bank_Account_At(i);
            if sb.sbAccount_Type <> AccountType then Continue;
            if AccountList.Find(sb^.sbAccount_Number,FoundAt) then begin
               sb^.sbAttach_Required := TStringList( AccountList.Objects[FoundAt]).Count = 0;
            end;
         end;
      SaveAdminSystem;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure ListAdminBankDetail (Sender : TObject);
var
  i,j          : integer;
  EntriesFrom,
  EntriesTo,
  NumEntries   : integer;
  ClientsList  : TStringList;
  AAL_Index    : integer;          //AdminAccountList_Index
  S            : string;
  HasDeletedAccounts : boolean;
  AccountType : integer;
begin
  if ProvisionalReport
    then AccountType := sbtProvisional
    else AccountType := sbtData;

  HasDeletedAccounts := false;
  with TAdminBankAccountsReport(Sender), AdminSystem do
  begin
     for i := 0 to Pred(fdSystem_Bank_Account_List.ItemCount) do
        with fdSystem_Bank_Account_List.System_Bank_Account_At(i)^ do begin
           //see if should include this account
           if (( not IncludeDeletedAccounts) and ( sbMark_As_Deleted)) or (sbAccount_Type <> AccountType) then
              Continue;

           if NotActiveSince <> 0 then begin
              if sbLast_Entry_Date  >= NotActiveSince then
                 continue; // still active..
              if Not sbWas_On_Latest_Disk then
                 continue; // Already 'deleted'

              if sbAccount_Type <> AccountType then
                 continue; // as a minimum was not in last down-load
           end;

           //construct account no, * means marked as deleted
           S := sbAccount_Number;
           if sbMark_As_Deleted then begin
              S := S + ' *';
              HasDeletedAccounts := true;
           end;
           PutString( S);
           PutString( sbAccount_Name);
           if Adminsystem.HasMultiCurrency then
              PutString(sbCurrency_Code);

           //look for account in admin account list to see what clients are attached
           ClientsList := nil;
           AAL_Index := AccountsList.IndexOf(sbAccount_Number);
           if AAL_Index > -1 then begin
              ClientsList := TStringList( AccountsList.Objects[AAL_Index] );

              if ClientsList.Count < 1 then
                 SkipColumn
              else
                 PutString( ClientsList[0] );
           end
           else
              SkipColumn;

           if NotActiveSince = 0 then begin
              //retrieve bank accounts information from the archive
              GetArchiveInfo(sbLRN,NumEntries,EntriesFrom,EntriesTo);

              PutString(bkDate2Str(EntriesFrom));
              PutString(bkDate2Str(EntriesTo));
              PutString(IntToStr(NumEntries));              
           end else begin

              PutString(bkDate2Str(sbLast_Entry_Date))
           end;


           RenderDetailLine;

           //Render other client code if there are any
           if Assigned(ClientsList) and ( ClientsList.Count > 1 ) then
              for j := 1 to Pred(ClientsList.Count) do begin
                 SkipColumn;  //account number
                 SkipColumn;  //account name
                 if Adminsystem.HasMultiCurrency then
                    SkipColumn;  //Currency

                 PutString( ClientsList[j] );

                 SkipColumn;  //entries from
                 SkipColumn;  //entries to
                 SkipColumn;  //num of entries

                 RenderDetailLine;
              end;
        end;  //for/with

     if HasDeletedAccounts then begin
        RenderTextLine('');
        RenderTextLine(' * = Account marked as deleted');
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure DoListAdminBankAccounts(NonActiveOnly : Boolean; var Dest : TReportDest;
                                  ProvisionalOnly : Boolean = false);
var
  Job               : TAdminBankAccountsReport;
  AdminAccountsList : TstringList;
  i                 : integer;
  Options           : TlaReportOptions;
  ButtonPressed     : integer;
  cLeft: Double;
  function maketitle : string;
  begin
     if ProvisionalOnly then
        result := Report_List_Names[REPORT_PROV_ACCOUNTS]
     else if NonActiveOnly then
        result := Report_List_Names[REPORT_ADMIN_INACTIVE_ACCOUNTS]
     else
        result := Report_List_Names[REPORT_ADMIN_ACCOUNTS]
  end;

begin
  DumpClientAccountMapToFile;
  FillChar(Options,sizeof(Options),0);
  repeat
     if not GetListAdminAccountOptions(maketitle ,NonActiveOnly, Options, ButtonPressed) then begin
        Dest := rdNone;
        exit;
     end;
     case ButtonPressed of
        BTN_PRINT    : Dest := rdPrinter;
        BTN_PREVIEW  : Dest := rdScreen;
        BTN_FILE     : Dest := rdFile;
     else
        Dest := rdScreen;
     end;

     AdminAccountsList := TStringList.Create;
     try
        LoadUpdateAdminBankAccounts(AdminAccountsList, ProvisionalOnly);

        Job := TAdminBankAccountsReport.Create(rptOther);
        try
           Job.IsAdmin := True;
           Job.IncludeDeletedAccounts := Options.IncludeDeleted;
           Job.NotActiveSince := Options.NotActiveSince;

           //construct report
           Job.LoadReportSettings(UserPrintSettings,maketitle);

           {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
           AddAdminHeader(Job);
           AddJobHeader(Job,SiTitle,maketitle,true);

           if not Job.IncludeDeletedAccounts then
              AddJobHeader( Job, SiSubTitle, '(excludes accounts marked as deleted)', true);

           if Job.NotActiveSince <> 0 Then begin
              AddJobHeader( Job, SiSubTitle, 'Accounts with No transactions since ' +
                          Date2Str(Job.NotActiveSince,'dd nnn yyyy'), true);
           end;
           AddJobHeader(Job,siSubTitle,'',true);

           cLeft := GcLeft;
           AddColAuto( Job,cLeft,18.6,GcGap,'Account No'   ,jtLeft );
           AddColAuto( Job,cLeft,30.0,GcGap,'Account Name' ,jtLeft );

           if Adminsystem.HasMultiCurrency then
               AddColAuto( Job,cLeft,8,GcGap,'Currency'  ,jtLeft );

           AddColAuto( Job,cLeft,12.5,GcGap,'Client Code'  ,jtLeft );
           if Job.NotActiveSince = 0 then begin
              AddColAuto( Job,cLeft,10.0,GcGap,'Entries From' ,jtLeft );
              AddColAuto( Job,cLeft,10.0,GcGap,'Entries To'   ,jtLeft );
              AddColAuto( Job,cLeft, 8.0,GcGap,'No of Entries',jtRight);
           end else begin
              AddColAuto( Job,cLeft,10.0,GcGap,'Last Entry' ,jtLeft );
           end;

           AddCommonFooter(Job);

           ProvisionalReport := ProvisionalOnly;
           Job.OnBKPrint := ListAdminBankDetail;
           Job.AccountsList := AdminAccountsList;

           Job.Generate( Dest);
        finally
           Job.Free;
        end;

     finally
        //free each of the objects in the list
        for i := 0 to Pred(AdminAccountsList.Count) do
           TStringList( AdminAccountsList.Objects[i] ).Free;
        AdminAccountsList.Free;
     end;
  until False;
end;

//------------------------------------------------------------------------------
Function TransIsCoded(const aClient : TClientObj; const T : pTransaction_Rec ): Boolean;
//special version since normal IsCoded works on the myClient object
Var
   OK    : Boolean;
   DS    : pDissection_Rec;
Begin
   With aClient, T^ do begin
      If txFirst_Dissection <> nil then begin
         OK := TRUE;
         DS := txFirst_Dissection;
         while ( DS<>NIL ) and OK do With DS^, clFields do begin
            OK := clChart.CanCodeTo( dsAccount );
            //check CA systems GST Range
            if IsCASystems( aClient) and (not CASystemsGSTOK( aClient, dsGST_Class)) then ok := false;
            DS := dsNext;
         end;
      end
      else with clfields do begin
         OK := clChart.CanCodeTo( txAccount );
         //check CA Systems GST Range}
         if IsCASystems( aClient) and (not CASystemsGSTOK( aClient, txGST_Class)) then ok := false;
      end;
      result := OK;
   end;
end;
//------------------------------------------------------------------------------
function SortClientsByStaffMember(Item1, Item2: Pointer): Integer;
var
   UCode1 : String[ 10];
   UCode2 : String[ 10];
   CCode1 : String[ 10];
   CCode2 : String[ 10];
   pUser  : pUser_Rec;
begin
   //get user codes, if not user code then sort to end
   pUser := AdminSystem.fdSystem_User_List.FindLRN( pClient_File_Rec( Item1)^.cfUser_Responsible);
   if Assigned( pUser) then
      UCode1 := pUser^.usCode
   else begin
      UCode1 := 'þ';
   end;
   pUser := AdminSystem.fdSystem_User_List.FindLRN( pClient_File_Rec( Item2)^.cfUser_Responsible);
   if Assigned( pUser) then
      UCode2 := pUser^.usCode
   else begin
      UCode2 := 'þ';
   end;
   CCode1 := pClient_File_Rec( Item1)^.cfFile_Code;
   CCode2 := pClient_File_Rec( Item2)^.cfFile_Code;
   //compare user codes
   result := StrCompare( UCode1, UCode2);
   if result = 0 then
      //user code is the same so now sort on client code
      result := StrCompare( CCode1, CCode2);
end;
//------------------------------------------------------------------------------

procedure QueryClients(ReportOptions: TStatusRepOptions; aResultList : TClientStatusList);
//populates the results list with client status records.  Parameters for query are provided
//in ReportOptions
var
   aClient      : TClientObj;
   i,k        : integer;
   pUser        : pUser_Rec;
   MonthsToShow : integer;
   d,m,y        : integer;
   ba           : TBank_Account;
   pT           : pTransaction_Rec;
   b,t          : integer;
   pCS          : pClientStatusRec;
   pCF          : pClient_File_Rec;

   cKey1,
   cKey2        : string[10];
   sKey1,
   sKey2        : string[10];
   ClientList   : TList;
   IncludeClient: Boolean;

   ClientCodeList : TStringList;
begin
   DateDiff( ReportOptions.soDateFrom, ReportOptions.soDateTo, d, m, y);
   MonthsToShow := m + 1;

   //Load month dates into periods
   for i := 0 to Pred( MonthsToShow) do begin
      StDateToDMY( IncDate( ReportOptions.soDateFrom, 0, i, 0), d, m, y);
      aResultList.PeriodFromDates[ i] := DMYToSTDate( 1, m, y, BKDATEEPOCH);
      aResultList.PeriodToDates[ i]   := DMYToSTDate( DaysInMonth( m,y,BKDATEEPOCH), m,y, BKDATEEPOCH);
   end;

   if ReportOptions.soByStaffMember then begin
      cKey1 := '';
      cKey2 := 'þ';
      sKey1 := Trim( ReportOptions.soFromCode);
      sKey2 := Trim( ReportOptions.soToCode) + 'þ';
   end
   else begin
      cKey1 := ReportOptions.soFromCode;
      cKey2 := ReportOptions.soToCode + 'þ';
      sKey1 := '';
      sKey2 := 'þ';
   end;

   //build list of clients for report, we first build a list of pointers
   //that we can sort into staff member order
   ClientList := TList.Create;
   try
      for i := 0 to Pred( AdminSystem.fdSystem_Client_File_List.itemCount) do
      begin
         pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At( i);
         IncludeClient := false;
         if pCF^.cfClient_Type = ctProspect then Continue; // Skip prospects
         with pCF^ do
         begin
            if (( cfFile_Code >= cKey1) and ( cfFile_Code <= cKey2)) then
            begin
               if ReportOptions.soByStaffMember then
               begin
                  //see what user code is for staff member assigned to this client
                  pUser := AdminSystem.fdSystem_User_List.FindLRN( cfUser_Responsible);
                  if Assigned( pUser) then
                     IncludeClient := ( pUser.usCode >= sKey1) and ( pUser.usCode <= sKey2)
                  else
                  begin
                     //no user record exists,  see if should include unallocated clients.
                     //If the to code is blank then we include unallocated clients
                     if ( sKey2 = 'þ') then IncludeClient := true;
                  end;
               end
               else
               begin
                  IncludeClient := true;
               end;
            end;
         end;
         if IncludeClient then
            ClientList.Add( pCF);
      end;

      //Client list will be in client order, if byStaffMember then need to sort
      if ReportOptions.soByStaffMember then
         ClientList.Sort( SortClientsByStaffMember);

      //admin system may be reloaded so take codes from the list and add
      //to a string list
      ClientCodeList := TStringList.Create;
      try
        for i := 0 to Pred(ClientList.Count) do
        begin
          ClientCodeList.Add( pClient_File_Rec( ClientList[i])^.cfFile_Code);
        end;
        //now free the clientcodelist so that we don't use the pointers
        ClientList.Free;
        ClientList := nil;

        //now search through client codes, loaded from admin system
        for i := 0 to Pred(ClientCodeList.Count) do
        begin
           pCF := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCodeList[i]);
           if Assigned( pCF) then
           begin
             with PCF^ do begin
               UpdateAppStatus('Reading Client',cfFile_Code,( i / ClientCodeList.Count * 100 ));
               //create a client status record
               SafeGetMem( pCS, SizeOf( TClientStatusRec));  //will be freed when result list destroyed
               FillChar( pCS^, SizeOf( TClientStatusRec), #0);
               pCS^.csCode  := cfFile_Code;
               pCS^.csName  := cfFile_Name;
               //load client file and work out status
               if cfFile_Status in [ bkConst.fsNormal, fsOpen, fsCheckedOut] then begin
                  OpenAClientForRead( cfFile_Code, aClient);
                  if Assigned(aClient) then begin
                     try
                        //merge in any transaction in admin system
                        SyncClientToAdmin(aClient, true,true,False,false,false,false);    //!! causes admin system to be reloaded
                        //count transactions
                        with aClient.clBank_Account_List do
                        begin
                           for b := 0 to Pred( ItemCount) do
                           begin
                              ba := Bank_Account_At(b);
                              for t := 0 to Pred( ba.baTransaction_List.ItemCount) do
                              begin
                                 pT := ba.baTransaction_List.Transaction_At(t);
                                 //see if in date range for report
                                 if ( pT^.txDate_Effective >= ReportOptions.soDateFrom) and
                                    ( pT^.txDate_Effective <= ReportOptions.soDateTo) then
                                    begin
                                    //find period for this transaction
                                    for k := 0 to Pred( MonthsToShow) do begin
                                        if ( pT^.txDate_Effective >= aResultList.PeriodFromDates[ k]) and
                                           ( pT^.txDate_Effective <= aResultList.PeriodToDates[ k]) then
                                           begin
                                           with pCS^.csPeriodInfo[ k] do
                                           begin
                                              Inc( piTrxCount);
                                              if not( ba.baFields.baAccount_Type in BKCONST.NonTransferringJournalsSet) then
                                              begin
                                                 Inc( piTransferableCount);
                                                 if ( pT^.txDate_Transferred > 0) then
                                                    Inc( piTransferredCount);
                                              end;
                                              if pT^.txLocked then
                                                 Inc( piFinalisedCount);
                                              if TransIsCoded( aClient, pT) then
                                                 Inc( piCodedCount);
                                           end;
                                           //trans will not fit into any other periods
                                           //so break loop
                                           Break;
                                        end;
                                    end;
                                 end;
                              end;
                           end;
                        end;
                        //set file status
                        Case cfFile_Status of
                           fsOpen       : pCS^.csFileStatus := 'O';
                           fsCheckedOut : pCS^.csFileStatus := '*';
                        end;
                        //see if client is flagged for offsite downloads. If so
                      //mark as offsite.
                        if ( aClient.clFields.clDownload_From <> dlAdminsystem) then
                           pCS^.csFileStatus := '**';

                        pCS^.csLastAccessedDate := pCF^.cfDate_Last_Accessed;
                     finally
                        aClient.Free;
                        aClient := nil;
                     end;
                  end
                  else begin
                     //file is open or normal but cant load
                     pCS^.csFileStatus := '?';
                  end;
               end
               else begin
                  //file cannot be openned because it is offsite
                  Case cfFile_Status of
                     fsOffsite    : pCS^.csFileStatus := '**';
                  end;
               end;
               //Find staff member
               if cfUser_Responsible <> 0 then begin
                  pUser := AdminSystem.fdSystem_User_List.FindLRN(cfUser_Responsible);
                  if Assigned(pUser) then begin
                     //If the users full name has not been entered then just show the users login code
                     if pUser^.usName = '' then
                        pCS^.csStaffMember := pUser^.usCode
                     else
                        pCS^.csStaffMember := pUser^.usName;
                  end
               end;
               //Add client status record to results list
               aResultList.Insert( pCS);
             end;   //with pCF^
           end;   //if assigned
        end;
      finally
        ClientCodeList.Free;
      end;
   finally
      ClearStatus;
      ClientList.Free;
   end;
end;                                   
//------------------------------------------------------------------------------

Procedure ClientStatusReportDetail(Sender : TObject);
var
   i,j   : integer;
   s     : string;
   pCS   : pClientStatusRec;
begin
   with TClientStatusReport(Sender), AdminSystem do begin
      //cycle thru results list output data
      for i := 0 to Pred( CSList.ItemCount) do begin
         pCS := CSList.CS_Rec_At( i);
         with pCS^ do begin
            PutString( csFileStatus);
            PutString( csCode);
            PutString( csName);
            for j := 0 to Pred( MonthsToShow) do begin
               S := '';
               with csPeriodInfo[ j] do begin
                  if piTrxCount = 0 then
                     S := ''
                  else begin
                     if ( piCodedCount = piTrxCount) then
                        S := S + 'C'
                     else
                     if ( piCodedCount > 0) then  //partially coded
                        S := S + '%'
                     else
                        S := S + '+';

                     if ( piTrxCount = piFinalisedCount) then
                        S := S + 'F';

                     if ( piTransferableCount = piTransferredCount) then
                        S := S + 'T';

                     //show if data available but nothing complete
                     if S = '' then
                        S := '+';
                  end;
               end;
               PutString( S);
            end;

            if csLastAccessedDate > 0 then
              PutString(bkDate2Str( csLastAccessedDate))
            else
              SkipColumn;

            PutString( csStaffMember);
            RenderDetailLine;
            RenderRuledLine;
         end;
      end;
   end;
end;
//------------------------------------------------------------------------------

procedure DoClientStatusReport(var Dest : TReportDest);
// note:  A maximum of 12 mths including the start month can be shown.  This
//        is enforced by the dialog
var
   Job            : TClientStatusReport;
   StatusRepRange : TStatusRepOptions;
   Btn            : integer;
   d,m,y          : integer;
   mDiff          : integer;
   pd             : integer;
   cLeft          : double;
   S1             : string;
   ResultsList    : TClientStatusList;
begin
   //ask user for date and and sorting/filter options.
   FillChar(StatusRepRange, SizeOf(StatusRepRange),0);
   StDateToDMY( CurrentDate, d, m, y);
   //calculate month end date for last month
   StatusRepRange.soDateTo := DMYtoStDate( 1, m, y, BkDateEpoch) - 1;
   StatusRepRange.soDateFrom := bkDateUtils.GetYearStartDate(StatusRepRange.soDateTo);
   repeat
   if ( Dest in [rdNone, rdAsk]) then begin
      if StatusReportRangeDlg.GetStatusReportRange( StatusRepRange, Btn) then begin
         case Btn of
            BTN_PRINT    : Dest := rdPrinter;
            BTN_PREVIEW  : Dest := rdScreen;
            BTN_FILE     : Dest := rdFile;
         else
            Dest := rdScreen;
         end;
      end
      else begin
         Dest := rdNone;
         exit;
      end;
   end;

   //create and file list of results for printing, this means that this is done
   //before print/preview.
   ResultsList := TClientStatusList.create;
   try
      //build results list
      QueryClients( StatusRepRange, ResultsList);

      //now generate report
      Job := TClientStatusReport.Create(rptOther);
      try
         Job.IsAdmin := True;
         //construct report
         Job.LoadReportSettings(UserPrintSettings,Report_List_Names[ REPORT_CLIENT_STATUS]);

         {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
         AddAdminHeader(Job);

         AddJobHeader( Job,siTitle, 'CLIENT STATUS REPORT', true);
         AddJobHeader( Job,siSubTitle, 'for the period ' +
                                           StDatetoDateString('nnn yyyy', StatusRepRange.soDateFrom, true) +
                                           ' to ' +
                                           StDatetoDateString('nnn yyyy', StatusRepRange.soDateTo, true),
                                           true);
         AddJobHeader( Job, siSubTitle, '', true);

         CLeft := GCLeft;
         AddColAuto( Job, cLeft,  1.5,gCgap, '', jtCenter);
         AddColAuto( Job, cLeft,  8.0,gCgap, 'Code', jtLeft);
         AddColAuto( Job, cLeft, 14.0,gCgap, 'Client Name', jtLeft);

         DateDiff( StatusRepRange.soDateFrom, StatusRepRange.soDateTo, d, m, y);
         mDiff := m;
         for Pd := 0 to mDiff do begin
            S1 := StDatetoDateString('nnn yy', IncDate( StatusRepRange.soDateFrom, 0 , Pd, 0), false);
            AddColAuto( Job, cLeft, 4, GcGap, s1,jtLeft);
         end;
         AddColAuto( Job, cLeft, 6,GcGap, 'Accessed', jtLeft);
         AddColAuto( Job, cLeft, 9.5,GcGap, 'Staff Member', jtLeft);

         //add legend
         AddJobFooter( Job,siFootNote, 'O = Open     * = Checked Out     ** = ' + BKBOOKSNAME + '     ? = Missing     + = Uncoded      % = Partially Coded      C = Fully Coded      F = Finalised      T = Transferred', true);
         AddCommonFooter(Job);

         Job.OnBKPrint    := ClientStatusReportDetail;
         Job.CSList       := ResultsList;
         Job.MonthsToShow := mDiff + 1;  //add one because mdiff zero if only one mth
         Job.Generate( Dest);
      finally
         Job.Free;
      end;
   finally
      ResultsList.Free;
   end;
   Dest := rdAsk;
   until False;
end;

//------------------------------------------------------------------------------
{ TClientStatusList }

function TClientStatusList.CS_Rec_At(Index: integer): pClientStatusRec;
begin
   result := At( Index);
end;
//------------------------------------------------------------------------------

procedure TClientStatusList.FreeItem(Item: pointer);
begin
   SafeFreeMem( Item, SizeOf( TClientStatusRec));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure ClientFileAccessControlDetail(Sender : TObject);
//print for each staff member, then print those not allocated
//page break between each
Var
  cNo       : Integer;
  uNo       : Integer;
  pCF       : pClient_File_Rec;
  pUS       : pUser_Rec;
  FirstFile : boolean;
Begin
  With TBKReport( Sender ) do Begin
    RenderTitleLine( 'The following users have access to all client files' );
    RenderTextLine( '' );

    With AdminSystem.fdSystem_User_List do
    Begin
      For uNo := 0 to Pred( ItemCount ) do
      Begin
        pUS := User_At( uNo );
        If ( not AdminSystem.fdSystem_File_Access_List.Restricted_User( pUS.usLRN ) ) then
        Begin
          PutString( pUS.usCode );
          PutString( pUS.usName );

          if pUS.usSystem_Access then
             PutString( ustNames[ustSystem]) //'System'
          else if pUS.usIs_Remote_User then
             PutString( ustNames[ustRestricted]) //'Restricted'
          else
             PutString( ustNames[ustNormal]); //'Normal';

          PutString( 'ALL');
          SkipColumn;
          RenderDetailLine;
        end;
      end;
    end;

    RenderTitleLine( 'The following users have access to selected client files only' );
    RenderTextLine( '' );

    With AdminSystem.fdSystem_User_List do
    Begin
      For uNo := 0 to Pred( ItemCount ) do
      Begin
        pUS := User_At( uNo );
        If AdminSystem.fdSystem_File_Access_List.Restricted_User( pUS.usLRN ) then
        Begin
          PutString( pUS.usCode );
          PutString( pUS.usName );

          if pUS.usSystem_Access then
             PutString( ustNames[ustSystem]) //'System'
          else if pUS.usIs_Remote_User then
             PutString( ustNames[ustRestricted]) //'Restricted'
          else
             PutString( ustNames[ustNormal]); //'Normal';

          FirstFile := false;

          With AdminSystem.fdSystem_Client_File_List do
          Begin
            For cNo := 0 to Pred( ItemCount ) do
            Begin
              pCF := Client_File_At( cNo );
              If AdminSystem.fdSystem_File_Access_List.Allow_Access( pUS.usLRN, pCF.cfLRN ) then
              Begin
                 if not FirstFile then begin
                    FirstFile := true;
                    PutString( pCF.cfFile_Code);
                    PutString( pCF.cfFile_Name);
                    RenderDetailLine;
                 end
                 else begin
                    SkipColumn;
                    SkipColumn;
                    SkipColumn;
                    PutString( pCF.cfFile_Code);
                    PutString( pCF.cfFile_Name);
                    RenderDetailLine;
                 end;
              end;
            end;
          end;

          if not FirstFile then begin
             PutString( '<none>');
             SkipColumn;
             RenderDetailLine;
          end;
        end;
      end;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure DoClientFileAccessControl(var Dest : TReportDest );
var
  Job : TBKReport;
  cLeft: Double;
begin
  Job := TBKReport.Create(rptOther);
  try
    Job.IsAdmin := True;  
    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[ Report_File_Access_Control  ]);

    {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'CLIENT FILE ACCESS REPORT',true );
    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := GcLeft;
    AddColAuto(Job,cLeft,15.0,gcgap,'User',jtLeft);
    AddColAuto(Job,cLeft,24.0,gcgap,'Name',jtLeft);
    AddColAuto(Job,cLeft,19.0,gcgap,'Access Level',jtLeft);
    AddColAuto(Job,cLeft,10.0,gcgap,'Has Access to',jtLeft);
    AddColAuto(Job,cLeft,27.0,gcgap,'', jtLeft);

    AddCommonFooter(Job);

    Job.OnBKPrint := ClientFileAccessControlDetail;

    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SummarisedDownloadReportDetail( Sender : TObject);
var
  i     : integer;
  cActiveAccounts    : integer;
  cInactiveAccounts  : integer;
  cNewAccounts       : integer;
  TransFrom,
  TransTo           : integer;
  cDeletedAccounts   : integer;

begin
  RenderFilesDownloaded(Sender, 1);

  with TBKReport( Sender ) do begin
    RenderTitleLine( 'Accounts Received');

    //total up accounts
    cActiveAccounts     := 0;
    cInactiveAccounts   := 0;
    cNewAccounts        := 0;
    cDeletedAccounts    := 0;

    TransFrom          := MaxInt;
    TransTo            := 0;

    with AdminSystem.fdSystem_Bank_Account_List do begin
      for i := 0 to Pred(ItemCount) do with System_Bank_Account_At(i)^ do begin
        if sbAccount_Type <> sbtData then Continue;
        if sbWas_On_Latest_Disk then begin
          if ( sbNo_Of_Entries_This_Month > 0) then
            Inc( cActiveAccounts)
          else
            Inc( cInactiveAccounts);

          if ( sbNew_This_Month) then
            Inc( cNewAccounts);
        end
        else
          Inc(cDeletedAccounts);

        //see dates
        if ( sbFrom_Date_This_Month > 0) and ( sbFrom_Date_This_Month < TransFrom) then
          TransFrom := sbFrom_Date_This_Month;

        if ( sbTo_Date_This_Month > TransTo) then
          TransTo   := sbTo_Date_This_Month;
      end;
    end;

    //render accumulators
    PutString( 'Accounts with transactions');
    PutCurrency( cActiveAccounts);
    RenderDetailLine;

    PutString( 'Accounts with no transactions');
    PutCurrency( cInActiveAccounts);
    RenderDetailLine;
    RenderDetailSubTotal( 'Total Accounts Downloaded');

    RenderTextLine( 'Including:');

    PutString( 'New Accounts');
    PutInteger( cNewAccounts);
    RenderDetailLine;

    RenderTextLine('');

    PutString('Transactions dated');
    if ( TransFrom > 0) and ( TransTo > 0) then
      PutString( bkDate2Str( TransFrom) + ' - ' + bkDate2Str( TransTo))
    else
      SkipColumn;
    RenderDetailLine;

    RenderRuledLine;

    if cDeletedAccounts > 0 then begin
      RenderTextLine('');
      PutString('Deleted Accounts (Accounts not received in this download)');
      PutCurrency( cDeletedAccounts);
      RenderDetailLine;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoSummarisedDownloadReport(var Dest : TReportDest);
var
  Job : TBKReport;
  cLeft: Double;
begin
  Job := TBKReport.Create(rptOther);
  try
    Job.IsAdmin := True;

    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_SUMMARY_DOWNLOAD]);

    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'DOWNLOAD SUMMARY REPORT',true);
    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := gCLeft;
    AddColAuto(Job,cLeft,        40.0,gcgap,'',jtLeft);
    AddFormatColAuto(Job,cLeft,15.0,gcGap,'',jtRight,'0','0',True);

    AddCommonFooter(Job);

    Job.OnBKPrint := SummarisedDownloadReportDetail;
    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;

procedure AddOverdueTaskFootnote(Job: TBKReport);
begin
  AddJobFooter(Job, siFootNote, '* Task is overdue.', true);
  AddJobFooter(Job, siFootnote, ' ',true);
end;

procedure AddTaskToReport(Job:TBKReport; Task: pClientToDoItem; IncludeClosedInfo: Boolean);
var
  ExtraLines: TStringList;
  s : string;
  j: integer;
begin
  ExtraLines := TStringList.Create;
  try
    Job.PutString(bkDate2Str(Task^.tdDate_Entered));
    Job.PutString(Task.tdEntered_By);

    s := Task.tdDescription;

    Job.WrapText(Job.CurrDetail.Count, s, ExtraLines); // wrap action

    if Task.tdReminderDate <> 0 then
    begin
       S := bkDate2Str( Task.tdReminderDate);
       if ( Task.tdReminderDate < StDate.CurrentDate)
        and ( Task.tdDate_Completed = 0) then
          S := S + ' *';
       Job.PutString( S);
    end
    else
      Job.SkipColumn;

    if IncludeClosedInfo then
    begin
      if Task.tdDate_Completed <> 0 then
      begin
         Job.PutString( 'Y');
         Job.PutString( bkDate2Str( Task.tdDate_Completed));
      end
      else
      begin
         Job.SkipColumn;
         Job.SkipColumn;
      end;
    end;

    Job.RenderDetailLine(False);
    while ExtraLines.Count > 0 do
    begin
       for j := 0 to 5 do
          if j = 2 then
          begin
            Job.PutString(ExtraLines[0]);
            ExtraLines.Delete(0);
          end
          else
            Job.SkipColumn;
       Job.RenderDetailLine(False);
    end; // while
    Job.NewDetail;
  finally
    ExtraLines.Free;
  end;
end;

function ClientHasOverDueTasks(Code: string): boolean;
var
  ClientsToDoList: TClientToDoList;
  sysClientRec: pClient_File_Rec;
begin
  Result := false;
  sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode(Code);
  if not Assigned(sysClientRec) then
    Exit;
  ClientsToDoList := TClientToDoList.Create(sysClientRec.cfLRN);
  try
    if ClientsToDoList.OverdueCount > 0 then
      Result := true;
  finally
    ClientsToDoList.Free;
  end;
end;

procedure AllTaskListReportDetail(Sender: TObject);
var
  ClientCode: string;
  AllTaskReport: TAllTaskListReport;
  ClientIndex: Integer;
  sysClientRec: pClient_File_Rec;
  ClientsToDoList: TClientToDoList;
  ClientHeadingString: String;
  TaskIndex: Integer;
  Task: pClientToDoItem;
begin
  AllTaskReport := TAllTaskListReport(Sender);
  for ClientIndex := 0 to AllTaskReport.ClientList.Count - 1 do
  begin
    ClientCode := AllTaskReport.ClientList[ClientIndex];
    //get client object
    sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
    if not Assigned(sysClientRec) then
      Exit;

    ClientsToDoList := TClientToDoList.Create( sysClientRec^.cfLRN);
    try
      if ClientsToDoList.PendingCount = 0 then
        Continue;
      ClientHeadingString := Format('%s - %s',[sysClientRec^.cfFile_Code, sysClientRec^.cfFile_Name]);
      AllTaskReport.RenderTitleLine(ClientHeadingString);
      for TaskIndex := 0 to ClientsToDoList.Count - 1 do
      begin
        Task := ClientsToDoList.ToDoItemAt(TaskIndex);
        if Task.tdDate_Completed <> 0 then
          Continue;
        AddTaskToReport(AllTaskReport, Task, false);
      end;
    finally
      ClientsToDoList.Free;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TaskListReportDetail( Sender : TObject);
var
  i : integer;
  pTask : pClientToDoItem;
  Job: TTaskListReport;
begin
  Job := TTaskListReport(Sender);
  for i := 0 to Job.TaskList.Count - 1 do
  begin
    pTask := Job.TaskList.Items[ i];
    AddTaskToReport(Job, pTask, true);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ContainsOverdueTasks(List: TList): boolean;
var
  I: Integer;
  pTask : pClientToDoItem;
begin
  Result := false;
  for I := 0 to List.Count - 1 do
  begin
    pTask := List[I];
    if (pTask.tdReminderDate <> 0) and ( pTask.tdDate_Completed = 0) and ( pTask.tdReminderDate < StDate.CurrentDate) then
    begin
      Result := true;
      break;
    end;
  end;
end;

procedure PrintTasksForMultipleClients(ClientCodes: string; Dest: TReportDest);
var
  Btn: Integer;
  Job: TAllTaskListReport;
  ClientList: TStringList;
  cLeft: Double;
  I: Integer;
begin
  if not AreThereAnyPrinters then
  begin
    HelpfulInfoMsg('You must setup a Windows Printer before running any Reports.  '+
                  SHORTAPPNAME+' will now take you to the Windows Printers Folder.  '+
                  'You can then select Add Printer to add a printer for windows to use.',0);
    ShellExecute(0, 'open', 'control.exe', 'printers', nil, SW_NORMAL);
    exit;
  end;

  repeat
    if Dest = rdAsk then
      if SimpleSelectReportDest(Report_List_Names[Report_AllTasksDue], Btn, 0) then
      begin
        case Btn of
           BTN_PRINT    : Dest := rdPrinter;
           BTN_PREVIEW  : Dest := rdScreen;
           BTN_FILE     : Dest := rdFile;
           else
              Dest := rdScreen;
        end;
      end
      else
        exit;

    CreateReportImageList;
    Job := TAllTaskListReport.Create(rptOther);
    ClientList := TStringList.Create;
    try
      //construct report

      Job.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_AllTasksDue]);
      Job.FileFormats := [ffCSV, ffFixedWidth, ffExcel, ffPDF,ffRtf];
      AddAdminHeader(Job);
      AddJobHeader(Job,siTitle,'TASKS REPORT',true);
      AddJobHeader(Job,siSubTitle,'',true);

      cLeft := gCleft;
      AddColAuto(Job,cLeft,  8.0,gcgap,'Entered',jtLeft);
      AddColAuto(Job,cLeft, 17.0,gcgap,'Entered By',jtLeft);
      AddColAuto(Job,cLeft, 66.0,gcgap,'Description',jtLeft);
      AddColAuto(Job,cLeft,  8.0,gcgap,'Reminder',jtLeft);

      ClientList.Delimiter := '~';
      ClientList.DelimitedText := ClientCodes;
      for I := 0 to ClientList.Count - 1 do
      begin
        if ClientHasOverDueTasks(ClientList[I]) then
        begin
          AddOverdueTaskFootnote(Job);
          Break;
        end;
      end;
      
      AddCommonFooter(Job);
      Job.ClientList  := ClientList;
      Job.OnBKPrint := AllTaskListReportDetail;
      Job.Generate( Dest);
    finally
      DestroyReportImageList;
      ClientList.Free;
      Job.Free;
    end;
    Dest := rdAsk;
  until false; //repeat until they push the cancelbutton, because they might want to preview, and then print
end;


procedure PrintTasksForClient( ClientCode : string;var Dest : TReportDest; aTaskList : TList);
//print the provided task list for this client
var
  Job : TTaskListReport;
  pCFRec : pClient_File_Rec;
  ButtonPressed : integer;
  cLeft: Double;
begin
  pCFRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
  if not Assigned( pCFRec) then
    exit;

  if ( Dest = rdAsk) then begin
     //ask user for destination, allow to set options
     if SimpleSelectReportDest(Report_List_Names[ Report_TasksDueForClient], ButtonPressed) then begin
        case ButtonPressed of
           BTN_PRINT    : Dest := rdPrinter;
           BTN_PREVIEW  : Dest := rdScreen;
           BTN_FILE     : Dest := rdFile;
        else
           Dest := rdScreen;
        end;
     end
     else begin
        Dest := rdNone;
        exit;
     end;
  end;

  CreateReportImageList;
  Job := TTaskListReport.Create(rptOther);
  try
    //construct report

    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_TasksDueForClient]);
    Job.FileFormats := [ffCSV, ffFixedWidth, ffExcel, ffPDF,ffRtf];
    
    AddAdminHeader(Job);
    AddJobHeader(Job,siTitle,'TASKS REPORT',true);
    AddJobHeader(Job,siSubTitle, pCFRec^.cfFile_Code + ' : ' + pCFRec^.cfFile_Name, true);
    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := gCleft;
    AddColAuto(Job,cLeft,  8.0,gcgap,'Entered',jtLeft);
    AddColAuto(Job,cLeft, 17.0,gcgap,'Entered By',jtLeft);
    AddColAuto(Job,cLeft, 50.0,gcgap,'Description',jtLeft);
    AddColAuto(Job,cLeft,  8.0,gcgap,'Reminder',jtLeft);
    AddColAuto(Job,cLeft,  8.0,gcgap,'Closed',jtCenter);
    AddColAuto(Job,cLeft,  8.0,gcgap,'Date Closed',jtLeft);
    if ContainsOverdueTasks(aTaskList) then
      AddOverdueTaskFootnote(Job);
    AddCommonFooter(Job);

    Job.TaskList  := aTaskList;
    Job.OnBKPrint := TaskListReportDetail;
    Job.Generate( Dest);
  finally
    DestroyReportImageList;
    Job.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ListAdminCharges(Sender: TObject);
var
  i: Integer;
begin
  with TAdminChargesReport(Sender) do
  begin
    for i := 1 to Data.Rows do
    begin
      PutString(Data.Cell[colPractice, i]);
      PutString(Data.Cell[colAcctNo, i]);
      PutString(Data.Cell[colAcctName, i]);
      PutString(Data.Cell[colFileCode, i]);
      PutString(Data.Cell[colCostCode, i]);
      if ExportType = xcAPS then
      begin
        PutString(Data.Cell[colClientID, i]);
        PutString(Data.Cell[colMatterID, i]);
      end
      else if ExportType = xcMYOB then
      begin
        PutString(Data.Cell[colAssignment, i]);
        PutString(Data.Cell[colDisbursement, i]);
      end
      else if ExportType in [xcMYOBAO,xcHandi] then
        PutString(Data.Cell[colAssignment, i]);

      PutMoney(Data.Cell[colOriginalCharge, i] * 100);
      if IsIncreasedCharges then
        PutMoney(Data.Cell[colIncreasedCharge, i] * 100);
      RenderDetailLine;
    end;
  end;
end;

procedure DoListAdminCharges(var Dest : TReportDest; Data: TtsGrid; ExportType: Byte; ExportDate: string; IsIncreasedCharges: Boolean);
var
  Job: TAdminChargesReport;
  Btn: Integer;
  w: Integer;
  cLeft: Double;
begin
  if Dest = rdAsk then
  begin
    if SimpleSelectReportDest(Report_List_Names[REPORT_CHARGES], Btn, BKH_List_Charges ) then
    begin
       case Btn of
          BTN_PRINT    : Dest := rdPrinter;
          BTN_PREVIEW  : Dest := rdScreen;
          BTN_FILE     : Dest := rdFile;
       else
          Dest := rdScreen;
       end;
    end
    else begin
       Dest := rdNone;
       exit;
    end;
  end;
  Job := TAdminChargesReport.Create(rptOther);
  try
    Job.FileFormats := [ffPDF];
    Job.IsAdmin := True;
    Job.Data := Data;
    Job.ExportType := ExportType;
    Job.IsIncreasedCharges := IsIncreasedCharges;
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_CHARGES]);
    AddAdminHeader(Job);

    AddJobHeader(Job, siTitle , 'EXPORT CHARGES', true);
    AddJobHeader(Job, siSubTitle, 'in ' + ExportDate, true);
    AddJobHeader(Job, SiSubTitle, '', false);

    w := 0;
    case ExportType of // spare space
      xcMYOB:
        begin
          if IsIncreasedCharges then
            w := -6
          else
            w := 2;
        end;
      xcOther:
        begin
          if IsIncreasedCharges then
            w := 17
          else
            w := 25;
        end;
      xcMYOBAO:
        begin
          if IsIncreasedCharges then
            w := 7
          else
            w := 15;
        end;
    end;

    cLeft := gCleft;
    AddColAuto(Job,cLeft,   9.0,Gcgap,BCONNECTShort + ' Code', jtLeft );
    AddColAuto(Job,cLeft,  16.0,Gcgap,Data.Col[colAcctNo].Heading, jtLeft );
    AddColAuto(Job,cLeft,  18.0 + w,Gcgap,Data.Col[colAcctName].Heading, jtLeft );
    AddColAuto(Job,cLeft,  8.0,Gcgap,Data.Col[colFileCode].Heading, jtLeft );
    if ExportType in [xcMYOBAO, xcHandi] then
      AddColAuto(Job,cLeft,  9.0,Gcgap,Data.Col[colCostCode].Heading, jtLeft )
    else
      AddColAuto(Job,cLeft,  8.0,Gcgap,Data.Col[colCostCode].Heading, jtLeft );

    if ExportType = xcAPS then // Nobody heard of a case statement ??
    begin
      if IsIncreasedCharges then
      begin
        AddColAuto(Job,cLeft, 10.0,Gcgap,Data.Col[colClientID].Heading, jtLeft );
        AddColAuto(Job,cLeft, 10.0,Gcgap,Data.Col[colMatterID].Heading, jtLeft );
      end
      else
      begin
        AddColAuto(Job,cLeft, 14.0,Gcgap,Data.Col[colClientID].Heading, jtLeft );
        AddColAuto(Job,cLeft, 13.0,Gcgap,Data.Col[colMatterID].Heading, jtLeft );
      end;
    end
    else if ExportType = xcMYOB then
    begin
      AddColAuto(Job,cLeft, 12.0,Gcgap,Data.Col[colAssignment].Heading, jtLeft );
      AddColAuto(Job,cLeft, 14.0,Gcgap,Copy(Data.Col[colDisbursement].Heading, 1, 17), jtLeft );
    end
    else if ExportType in [xcMYOBAO,xcHandi] then
      AddColAuto(Job,cLeft, 10.0,Gcgap,Data.Col[colAssignment].Heading, jtLeft );


    if IsIncreasedCharges then
    begin
      AddColAuto(Job,cLeft, 7,Gcgap,'Original', jtRight);
      AddColAuto(Job,cLeft, 7,Gcgap,'Increased', jtRight);
    end
    else
      AddColAuto(Job,cLeft, 7,Gcgap,Data.Col[colOriginalCharge].Heading, jtRight);

    AddCommonFooter(Job);

    Job.OnBKPrint := ListAdminCharges;
    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ListCharges(Sender: TObject);
var
  i: Integer;
  Line: TStringList;
  ExtraCharges: string;
begin
  with TAdminChargesReport(Sender) do
  begin
    if ChargesList.Count = 0 then Exit;

    for i := 1 to ChargesList.Count do
    begin
      ExtraCharges := '';
      Line := ChargesList.Lines[i - 1];
      PutString(Line[colListChargesPractice]);
      PutString(Line[colListChargesAcctNo]);
      PutString(Line[colListChargesAcctName]);
      PutString(Line[colListChargesFileCode]);
      PutString(Line[colListChargesCostCode]);

      case ExportType of
        xcAPS:
          begin
            PutString(Line[colListChargesClientID]);
            PutString(Line[colListChargesMatterID]);
          end;
        xcMYOB:
          begin
            PutString(Line[colListChargesAssignment]);
            PutString(Line[colListChargesDisbursement]);
          end;
        xcMYOBAO,xcHandi:
          begin
            PutString(Line[colListChargesAssignment]);
          end;
      end;

      PutMoney(StrToFloat(Line[colListChargesCharge]) * 100);
      if (UpperCase(Line[colListChargesNew]) = 'YES') and
         (UpperCase(Line[colListChargesLoadCharge]) = 'YES') then
        ExtraCharges := Format('%s*', [ExtraCharges]);;
      if (UpperCase(Line[colListChargesOffsiteCharge]) = 'YES') then
        ExtraCharges := Format('%s+', [ExtraCharges]);;
      PutString(ExtraCharges);
      RenderDetailLine;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoListCharges(var Dest : TReportDest; Data: TChargesList; ExportType:
  Byte; ExportDate: string);
var
  Job: TAdminChargesReport;
  Btn: Integer;
  cLeft: Double;
begin
  if Dest = rdAsk then
  begin
    if SimpleSelectReportDest(Report_List_Names[REPORT_CHARGES], Btn, BKH_List_Charges ) then
    begin
       case Btn of
          BTN_PRINT    : Dest := rdPrinter;
          BTN_PREVIEW  : Dest := rdScreen;
          BTN_FILE     : Dest := rdFile;
       else
          Dest := rdScreen;
       end;
    end
    else begin
       Dest := rdNone;
       exit;
    end;
  end;
  Job := TAdminChargesReport.Create(rptOther);
  try
    Job.FileFormats := [ffPDF];
    Job.IsAdmin := True;
    Job.Data := nil;
    Job.ChargesList := Data;
    Job.ExportType := ExportType;
    Job.IsIncreasedCharges := False;
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_CHARGES]);

    AddAdminHeader(Job);
    AddJobHeader(Job, siTitle , 'LIST CHARGES', true);
    AddJobHeader(Job, siSubTitle, 'in ' + ExportDate, true);
    AddJobHeader(Job, SiSubTitle, '', false);

    cLeft := gCleft;
    AddColAuto(Job, cLeft, 10.0, Gcgap, BCONNECTShort + ' Code', jtLeft);
    AddColAuto(Job, cLeft, 14.0, Gcgap, 'Account No', jtLeft);

    case ExportType of
      xcOther:
        begin
          AddColAuto(Job, cLeft, 42.0, Gcgap, 'Account Name', jtLeft);
          AddColAuto(Job, cLeft, 12.0, Gcgap, 'File Code', jtLeft);
          AddColAuto(Job, cLeft, 12.0, Gcgap, 'Cost Code', jtLeft);
        end;
      xcAPS:
        begin
          AddColAuto(Job, cLeft, 30.0, Gcgap, 'Account Name', jtLeft);
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'File Code', jtLeft);
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'Cost Code', jtLeft);
          AddColAuto(Job, cLeft,  8.0, Gcgap, 'Client ID', jtLeft);
          AddColAuto(Job, cLeft,  8.0, Gcgap, 'Matter ID', jtLeft);
        end;
      xcMYOB:
        begin
          AddColAuto(Job, cLeft, 25.0, Gcgap, 'Account Name', jtLeft);
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'File Code', jtLeft);
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'Cost Code', jtLeft);
          AddColAuto(Job, cLeft, 12.0, Gcgap, 'Assignment', jtLeft);
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'Disbursement', jtLeft);
        end;
      xcMYOBAO:
        begin
          AddColAuto(Job, cLeft, 35.0, Gcgap, 'Account Name', jtLeft);
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'Client ID', jtLeft );
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'Work Code', jtLeft );
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'Job Code', jtLeft);
        end;
      xcHandi:
        begin
          AddColAuto(Job, cLeft, 30.0, Gcgap, 'Account Name', jtLeft);
          AddColAuto(Job, cLeft, 15.0, Gcgap, 'Entity Code', jtLeft );
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'Activity Code', jtLeft );
          AddColAuto(Job, cLeft, 10.0, Gcgap, 'Cost Code', jtLeft);
        end;
    end;

    AddFormatColAuto(Job, cleft, 7.0, Gcgap, 'Charges', jtRight,
                     FORMAT_AMOUNT, FORMAT_AMOUNT_TOTAL, True);
    AddColAuto(Job, cLeft,  1.0, Gcgap, '', jtLeft);

    AddJobFooter(Job, siFootNote, '* Includes account load fee.', True, jtLeft);
    AddJobFooter(Job, siFootNote, '+ Includes Books Secure fee.', True, jtLeft);
    AddCommonFooter(Job);

    Job.OnBKPrint := ListCharges;
    Job.Generate(Dest);
  finally
    Job.Free;
  end;
end;

function SortByClient(Item1, Item2: pointer): integer;
begin
  Result := CompareText(TCodingOptimisationRec(Item1^).ClientCode,
                           TCodingOptimisationRec(Item2^).ClientCode);
end;

function SortByStaff(Item1, Item2: pointer): integer;
begin
  Result := CompareText(TCodingOptimisationRec(Item1^).StaffMember,
                           TCodingOptimisationRec(Item2^).StaffMember);
  if Result = 0 then
     Result := SortByClient(Item1, Item2);
end;

function SortByGroup(Item1, Item2: pointer): integer;
begin
  Result := (TCodingOptimisationRec(Item1^).Group -
             TCodingOptimisationRec(Item2^).Group);
  if Result = 0 then
     Result := SortByClient(Item1, Item2);
end;

function SortByType(Item1, Item2: pointer): integer;
begin
  Result := CompareText(TCodingOptimisationRec(Item1^).ClientType,
             TCodingOptimisationRec(Item2^).ClientType);
  if Result = 0 then
     Result := SortByClient(Item1, Item2);
end;

(* * )
 ///  Client File version
procedure GetCodingOptimisationCounts(AOptions: TCodingOptimisationOptions;
  ClientList: TList);
var
  i, b, t: integer;
  pCF: pClient_File_Rec;
  CodingOptRec: PCodingOptimisationRec;
  aClient: TClientObj;
  ba:  TBank_Account;
  pT: pTransaction_Rec;
begin
  //Select clients that meet options
  for i := 0 to Pred( AdminSystem.fdSystem_Client_File_List.itemCount) do begin
    pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
    if AOptions.ClientInSelection(pCF) then begin
      OpenAClientForRead(pCF.cfFile_Code, aClient);
      if Assigned(aClient) then begin
        try
          //Merge in any transaction in admin system
          SyncClientToAdmin(aClient, true,False,False,false,false,false); //!! causes admin system to be reloaded
          SafeGetMem(CodingOptRec, SizeOf(TCodingOptimisationRec));
          ClientList.Add(CodingOptRec);
          CodingOptRec^.ClientCode := aClient.clFields.clCode;
          CodingOptRec^.ClientName := aClient.clFields.clName;
          CodingOptRec^.StaffMember := aClient.clFields.clStaff_Member_Name;
          CodingOptRec^.Group := aClient.clFields.clGroup_LRN;
          CodingOptRec^.ClientType := aClient.clFields.clFile_Type;
          CodingOptRec^.MemorisationCount := 0;
          CodingOptRec^.AnalysisCount := 0;
          CodingOptRec^.PayeeCount := 0;
          CodingOptRec^.ManualCount := 0;
          //Iterate bank accounts
          for b := 0 to Pred(aClient.clBank_Account_List.ItemCount) do begin
            ba := aClient.clBank_Account_List.Bank_Account_At(b);
            //Iterate transactions
            for t := 0 to Pred(ba.baTransaction_List.ItemCount) do begin
              pT := ba.baTransaction_List.Transaction_At(t);
              //see if in date range for report
              if AOptions.TxnInSelection(pT) then begin
                //Count coding methods
                case pT^.txCoded_By  of
                  //cbNotCoded:           : (Not cosed)
                  cbManual              : Inc(CodingOptRec^.ManualCount);
                  cbMemorisedC          : Inc(CodingOptRec^.MemorisationCount);
                  cbAnalysis            : Inc(CodingOptRec^.AnalysisCount);
                  cbManualPayee         : Inc(CodingOptRec^.PayeeCount);
                  cbAutoPayee           : Inc(CodingOptRec^.PayeeCount);
                  cbMemorisedM          : Inc(CodingOptRec^.MemorisationCount);
                  cbECodingManual       : Inc(CodingOptRec^.ManualCount);
                  cbECodingManualPayee  : Inc(CodingOptRec^.PayeeCount);
                  cbCodeIT              : Inc(CodingOptRec^.ManualCount);
                  cbManualSuper         : Inc(CodingOptRec^.ManualCount);
                  //cbImported            : (Not used)
                end;
              end;
            end;
          end;
        finally
          aClient.Free;
          aClient := nil;
        end;
      end;
    end;
  end;
  //Sort
  if ClientList.Count > 0 then begin
    case AOptions.ClientSelectOptions.ReportSort of
      rsClient        : ClientList.Sort(SortByClient);
      rsByStaffMember : ClientList.Sort(SortByStaff);
      rsGroup         : ClientList.Sort(SortByGroup);
      rsClientType    : ClientList.Sort(SortByType);
    end;
  end;
end;
(* *)

/// Codingstat version
(* *)

// Iteration Function
function GetClientCounts(Container: TstContainer; Node: TstNode; OtherData: Pointer): Boolean; far;
var
  LCStat: pCoding_Statistics_Rec;
  LCRec: PCodingOptimisationRec;
begin
  LCStat := pCoding_Statistics_Rec(Node.Data);
  LCRec := PCodingOptimisationRec(OtherData);
  if (LCStat.csClient_LRN = LCRec.ClientLRN) // Client I am after
  and (LCStat.csMonth >= LCRec.DateRange.FromDate) //In the range..
  and (LCStat.csMonth <= LCRec.DateRange.ToDate) then begin
      // Ok then Add the Stats to the Record
      Inc(LCRec.MemorisationCount, LCStat.csMemorization_Count);
      Inc(LCRec.AnalysisCount,     LCStat.csAnalysis_Count);
      Inc(LCRec.PayeeCount,        LCStat.csPayee_Count);
      Inc(LCRec.ManualCount,       LCStat.csManual_Count);
      Inc(LCRec.MasterMemCount,    LCStat.csMaster_Mem_Count);
      Inc(LCRec.ManSuperCount,     LCStat.csMan_Super_Count);
      Inc(LCRec.UncodedCount,      LCStat.csUncoded_Count);
      Inc(LCRec.NotesCount,        LCStat.csNotes_Count);
  end;
  Result := True;
end;

procedure GetCodingOptimisationCounts(AOptions: TCodingOptimisationOptions;
  ClientList: TList);
var
  i: integer;
  pCF: pClient_File_Rec;
  CodingOptRec: PCodingOptimisationRec;
  User: pUser_Rec;
  pClientType: pClient_Type_Rec;
begin
  //Select clients that meet options
  CodingStatsManager.Refresh;
  for i := 0 to Pred( AdminSystem.fdSystem_Client_File_List.itemCount) do begin
    pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
    // Do my onw pre testing first..
    if pCF.cfFile_Status in [fsOffsite, fsError] then
       Continue;
    if pcf.cfArchived
    or pcf.cfForeign_File then
       Continue;

      

    if AOptions.ClientInSelection(pCF) then begin
       //This client is in the report, Make a New record;
       SafeGetMem(CodingOptRec, SizeOf(TCodingOptimisationRec));
       ClientList.Add(CodingOptRec);
       // Fill it in..
       CodingOptRec.ClientLRN := PCF.cfLRN;
       CodingOptRec.ClientCode := pCF.cfFile_Code;
       CodingOptRec.ClientName := pCF.cfFile_Name;
       CodingOptRec.DateRange := MakeDateRange(AOptions.DateFrom,AOptions.DateTo);

       with AdminSystem.fdSystem_User_List do begin
          User := FindLRN(pCF.cfUser_Responsible );
          if Assigned(User) then begin
             if User^.usName > '' then
                CodingOptRec^.StaffMember := User^.usName
             else
                CodingOptRec^.StaffMember := User^.usCode;
          end else
             CodingOptRec^.StaffMember := '';
       end;
       CodingOptRec.Group := pCF.cfGroup_LRN;
       pClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(pCF.cfClient_Type_LRN);
       if Assigned(pClientType) then // Sort it by name..
          CodingOptRec.ClientType := pClientType.ctName
       else
          CodingOptRec.ClientType := 'ZZ'; //At the bottom...

       // Clear the counts
       CodingOptRec.MemorisationCount := 0;
       CodingOptRec.AnalysisCount := 0;
       CodingOptRec.PayeeCount := 0;
       CodingOptRec.ManualCount := 0;
       CodingOptRec.UnCodedCount := 0;
       CodingOptRec.NotesCount := 0;
       CodingOptRec.ManSuperCount := 0;
       CodingOptRec.MasterMemCount := 0;

       //Iterate The Coding Stats
       CodingStatsManager.ClientStats.StatTree.Iterate(GetClientCounts,True,CodingOptRec);

    end;
  end;
  //Sort
  if ClientList.Count > 0 then begin
    case AOptions.ClientSelectOptions.ReportSort of
      rsClient        : ClientList.Sort(SortByClient);
      rsByStaffMember : ClientList.Sort(SortByStaff);
      rsGroup         : ClientList.Sort(SortByGroup);
      rsClientType    : ClientList.Sort(SortByType);
    end;
  end;
end;
 (* *)

function GetPercentageStr(AValue, ATotal: integer): string;
var
  Percentage: Double;
begin
 Result := '';
 if (AValue <> 0) and (ATotal <> 0) then begin
   Percentage := (AValue/ATotal) * 100;
   Result := Format('%0.0f%%', [Percentage])
 end;
end;

function GetPercentage(AValue, ATotal: integer): integer;
begin
 Result := 0;
 if (AValue <> 0) and (ATotal <> 0) then
   Result := Round((AValue/ATotal) * 1000000);
end;

procedure CodingOptimisationReportDetail(Sender : TObject);
var
  i: integer;
  Report: TCodingOptimisationReport;
  CodingOptRec: TCodingOptimisationRec;
  TotalTxns: integer;
  MemTotal, AnalysisTotal, PayeeTotal, ManualTotal, MasterMemTotal, ManSuperTotal,
  NotesTotal, TxnTotal: integer;
  TempPercent, OtherPercent: integer;
begin
  MemTotal := 0;
  AnalysisTotal := 0;
  PayeeTotal := 0;
  ManualTotal := 0;
  TxnTotal := 0;
  MasterMemTotal := 0;
  ManSuperTotal := 0;
  NotesTotal := 0;

  Report := TCodingOptimisationReport(Sender);
  //For each client print coding method totals (Mem, Analysis, Payee, Manual)
  for i := 0 to Pred(Report.ClientList.Count) do begin
    CodingOptRec := TCodingOptimisationRec(Report.ClientList.Items[i]^);
    TotalTxns := CodingOptRec.ManualCount
               + CodingOptRec.PayeeCount
               + CodingOptRec.MemorisationCount
               + CodingOptRec.AnalysisCount
               + CodingOptRec.MasterMemCount
               + CodingOptRec.ManSuperCount
               + CodingOptRec.UnCodedCount
               + CodingOptRec.NotesCount;

    Report.PutString(CodingOptRec.ClientCode);
    Report.PutString(CodingOptRec.ClientName);
    Report.PutString(CodingOptRec.StaffMember);

    //Totals
    MemTotal      := MemTotal + CodingOptRec.MemorisationCount;
    AnalysisTotal := AnalysisTotal + CodingOptRec.AnalysisCount;
    PayeeTotal    := PayeeTotal + CodingOptRec.PayeeCount;
    ManualTotal   := ManualTotal + CodingOptRec.ManualCount;
    MasterMemTotal := MasterMemTotal + CodingOptRec.MasterMemCount;
    ManSuperTotal := ManSuperTotal + CodingOptRec.ManSuperCount;
    NotesTotal    := NotesTotal + CodingOptRec.NotesCount;

    TxnTotal      := TxnTotal + TotalTxns;
    //Percentages
    if (TotalTxns <> 0) then begin
       OtherPercent := 0;
       // Memorization
       TempPercent := GetPercentage(CodingOptRec.MemorisationCount, TotalTxns);
       OtherPercent := OtherPercent + Round(TempPercent/10000);
       Report.PutQuantity(TempPercent);

       // Master Memorization
       TempPercent := GetPercentage(CodingOptRec.MasterMemCount, TotalTxns);
       OtherPercent := OtherPercent + Round(TempPercent/10000);
       Report.PutQuantity(TempPercent);


       case AdminSystem.fdFields.fdCountry of
        whNewZealand : begin
               //Analysis, NZ Only
               TempPercent := GetPercentage(CodingOptRec.AnalysisCount, TotalTxns);
               OtherPercent := OtherPercent + Round(TempPercent/10000);
               Report.PutQuantity(TempPercent);
           end;

        whAustralia : begin
               //Superfund, AU Only
               TempPercent := GetPercentage(CodingOptRec.ManSuperCount, TotalTxns);
               OtherPercent := OtherPercent + Round(TempPercent/10000);
               Report.PutQuantity(TempPercent);
           end;
       end;


       // Payee
       TempPercent := GetPercentage(CodingOptRec.PayeeCount, TotalTxns);
       OtherPercent := OtherPercent + Round(TempPercent/10000);
       Report.PutQuantity(TempPercent);

       // Notes
       TempPercent := GetPercentage(CodingOptRec.NotesCount, TotalTxns);
       OtherPercent := OtherPercent + Round(TempPercent/10000);
       Report.PutQuantity(TempPercent);

        // Manual
       TempPercent := GetPercentage(CodingOptRec.ManualCount, TotalTxns);
       OtherPercent := OtherPercent + Round(TempPercent/10000);
       Report.PutQuantity(TempPercent);

       TempPercent := (100 - OtherPercent) * 10000;
       //Manual is what's leftover so they add to 100%
       Report.PutQuantity(TempPercent);
    end else begin
       Report.PutString('-');
       Report.PutString('-');
       Report.PutString('-');
       Report.PutString('-');
       Report.PutString('-');
       Report.PutString('-');
       Report.PutString('-');
    end;
    Report.RenderDetailLine;
  end;
  //Redo totals as percentages
  Report.ClearAllTotals;
  Report.PutString('');
  Report.PutString('');
  Report.PutString('');

  OtherPercent := 0;
  // Mems
  TempPercent := (GetPercentage(MemTotal, TxnTotal) div 100);
  OtherPercent := OtherPercent + Round(TempPercent/100);
  Report.PutMoneyTotal(TempPercent);

  // Master Mems
  TempPercent := (GetPercentage(MasterMemTotal, TxnTotal) div 100);
  OtherPercent := OtherPercent + Round(TempPercent/100);
  Report.PutMoneyTotal(TempPercent);

  case AdminSystem.fdFields.fdCountry of
     whNewZealand : begin
          TempPercent := (GetPercentage(AnalysisTotal, TxnTotal) div 100);
          OtherPercent := OtherPercent + Round(TempPercent/100);
          Report.PutMoneyTotal(TempPercent);
     end;
     whAustralia : begin
          TempPercent := (GetPercentage(ManSuperTotal, TxnTotal) div 100);
          OtherPercent := OtherPercent + Round(TempPercent/100);
          Report.PutMoneyTotal(TempPercent);
     end;
  end;

  // Payee
  TempPercent := (GetPercentage(PayeeTotal, TxnTotal) div 100);
  OtherPercent := OtherPercent + Round(TempPercent/100);
  Report.PutMoneyTotal(TempPercent);

  // Notes
  TempPercent := (GetPercentage(NotesTotal, TxnTotal) div 100);
  OtherPercent := OtherPercent + Round(TempPercent/100);
  Report.PutMoneyTotal(TempPercent);

  // Manual
  TempPercent := (GetPercentage(ManualTotal, TxnTotal) div 100);
  OtherPercent := OtherPercent + Round(TempPercent/100);
  Report.PutMoneyTotal(TempPercent);

  //Uncoded is what's leftover so they add to 100%
  TempPercent := (100 - OtherPercent) * 100;
  Report.PutMoneyTotal(TempPercent);


  Report.RenderDetailGrandTotal('');
end;

procedure DoCodingOptimisationReport(var Dest : TReportDest);
var
  CodingOptimisationOptions: TCodingOptimisationOptions;
  d, m, y: integer;
  Job: TCodingOptimisationReport;
  CLeft: Double;
begin
  CodingOptimisationOptions := TCodingOptimisationOptions.Create;
  try
      //calculate month end date for last month
     StDateToDMY(CurrentDate, d, m, y);
     CodingOptimisationOptions.DateTo := DMYtoStDate( 1, m, y, BKDATEEPOCH) - 1;
     CodingOptimisationOptions.DateFrom := GetYearStartDate(CodingOptimisationOptions.DateTo);

     while Dest = rdNone do begin
       CodingOptimisationOptions.Destination := rdNone;

       if GetCodingOptimisationReportRange(CodingOptimisationOptions) then
           Dest := CodingOptimisationOptions.Destination;

      //Exit report  
      if Dest = rdNone then
        Exit;

      //Generate report
      Job := TCodingOptimisationReport.Create;
      try
        //build results list
        GetCodingOptimisationCounts(CodingOptimisationOptions, Job.ClientList);

        Job.IsAdmin := True;
        //construct report
        Job.LoadReportSettings(UserPrintSettings, Report_List_Names[ REPORT_CODING_OPTIMISATION]);

        {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
        AddAdminHeader(Job);

        AddJobHeader(Job, siTitle, 'CODING OPTIMISATION REPORT', true);
        AddJobHeader(Job, siSubTitle, 'for the period ' +
                                      StDatetoDateString('nnn yyyy', CodingOptimisationOptions.DateFrom, true) +
                                      ' to ' +
                                      StDatetoDateString('nnn yyyy', CodingOptimisationOptions.DateTo, true),
                                      true);
        AddJobHeader( Job, siSubTitle, '', true);
        CLeft := GCLeft;
        AddColAuto( Job, cLeft, 10.0,gCgap, 'Client', jtLeft).CaptionLine2 := 'Code';
        AddColAuto( Job, cLeft, 26.0,gCgap, 'Client', jtLeft).CaptionLine2 := 'Name';
        AddColAuto( Job, cLeft, 15.0,gCgap, 'Assigned', jtLeft).CaptionLine2 := 'To';

        AddFormatColAuto( Job, cLeft, 7.0, GCGap, '', jtRight, '0%', '0%', True).CaptionLine2 := 'Mem';
        AddFormatColAuto( Job, cLeft, 7.0, GCGap, 'Master', jtRight, '0%', '0%', True).CaptionLine2  := 'Mem';

        case AdminSystem.fdFields.fdCountry of
        whNewZealand :
           AddFormatColAuto( Job, cLeft, 7.0, GCGap, '', jtRight, '0%', '0%', True).CaptionLine2 := 'Analysis';
        whAustralia :
           AddFormatColAuto( Job, cLeft, 7.0, GCGap, 'Super', jtRight, '0%', '0%', True).CaptionLine2 := 'Fund';
        end;

        AddFormatColAuto( Job, cLeft, 7.0, GCGap, '', jtRight, '0%', '0%', True).CaptionLine2 := 'Payee';

        AddFormatColAuto( Job, cLeft, 7.0, GCGap, '', jtRight, '0%', '0%', True).CaptionLine2 := 'Notes';

        AddFormatColAuto( Job, cLeft, 7.0, GCGap, '', jtRight, '0%', '0%', True).CaptionLine2 := 'Manual';

        AddFormatColAuto( Job, cLeft, 7.0, GCGap, 'Un-', jtRight, '0%', '0%', True).CaptionLine2 := 'Coded';

        AddCommonFooter(Job);

        Job.OnBKPrint := CodingOptimisationReportDetail;

        Job.Generate(Dest);
      finally
        Job.Free;
      end;
    Dest := rdNone;
    end;
  finally
    CodingOptimisationOptions.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TCodingOptimisationReport }

procedure TCodingOptimisationReport.ClearClientList;
var
  i: integer;
begin
  for i := 0 to Pred(ClientList.Count) do
    FreeMem(ClientList.Items[i]);
end;

constructor TCodingOptimisationReport.Create;
begin
  inherited Create(rptOther);
  ClientList := TList.Create;
end;

destructor TCodingOptimisationReport.Destroy;
begin
  ClearClientList;
  ClientList.Free;
  inherited;
end;

{Audit reports}

procedure AuditReportDetail(Sender : TObject);
var
  i, j : integer;
  Report: TAuditReport;
  AuditRecord: TAudit_Trail_Rec;
  AuditFields: TStringList;
  Values: string;
  PrintAuditRec: Boolean;
begin
  Report := TAuditReport(Sender);
  AuditFields := TStringList.Create;
  try
    AuditFields.StrictDelimiter := True;
    AuditFields.Delimiter := VALUES_DELIMITER;
    for i := 0 to Pred(AdminSystem.fAuditTable.AuditRecords.ItemCount) do begin
      AuditRecord := AdminSystem.fAuditTable.AuditRecords.Audit_At(i);

      //Date selection
      if (stDate.DateTimeToStDate(AuditRecord.atDate_Time) < Report.ReportOptions.DateFrom) or
         (stDate.DateTimeToStDate(AuditRecord.atDate_Time) > Report.ReportOptions.DateTo) then
         Continue;

      //Transaction selection
      case Report.ReportOptions.AuditSelection of
        byAll: PrintAuditRec := True;
        byTransactionType: PrintAuditRec := (Report.ReportOptions.TransactionType = AuditRecord.atTransaction_Type) or
                                            (Report.ReportOptions.TransactionType = atAll);
        byTransactionID  : PrintAuditRec := (Report.ReportOptions.TransactionID = AuditRecord.atRecord_ID);
      end;

      //Output
      if PrintAuditRec then begin
        Report.PutString(SystemAuditMgr.AuditTypeToStr(AuditRecord.atTransaction_Type));
        Report.PutString(IntToStr(AuditRecord.atRecord_ID));
        Report.PutString(aaNames[AuditRecord.atAudit_Action]);
        Report.PutString(AuditRecord.atUser_Code);
        Report.PutString(FormatDateTime('dd/MM/yyyy hh:mm:ss', AuditRecord.atDate_Time));

        Report.RenderDetailLine;

        Values := '';
        SystemAuditMgr.GetValues(AuditRecord, Values);
        AuditFields.DelimitedText := Values;
        for j := 0 to AuditFields.Count - 1 do
          Report.RenderTextLine('        ' + AuditFields[j]);
      end;
    end;
  finally
    AuditFields.Free;
  end;
end;

procedure DoSystemAuditReport(var Dest : TReportDest);
var
  AuditReportOptions: TAuditReportOptions;
  Job: TAuditReport;
  CLeft: Double;
begin
  AuditReportOptions := TAuditReportOptions.Create;
  try
     //Set valid date range
     AuditReportOptions.DateFrom := MinValidDate;
     AuditReportOptions.DateTo := MaxValidDate;
     if AdminSystem.fAuditTable.AuditRecords.ItemCount > 0 then begin
       AuditReportOptions.DateFrom :=
         DateTimeToStDate(AdminSystem.fAuditTable.AuditRecords.Audit_At(AdminSystem.fAuditTable.AuditRecords.First).atDate_Time);
       AuditReportOptions.DateTo :=
         DateTimeToStDate(AdminSystem.fAuditTable.AuditRecords.Audit_At(AdminSystem.fAuditTable.AuditRecords.Last).atDate_Time);
     end;


     AuditReportOptions.AuditReportType := arSystem;

     while Dest = rdNone do begin
       AuditReportOptions.Destination := rdNone;

       if GetAuditReportOptions(AuditReportOptions) then
         Dest := AuditReportOptions.Destination;

      //Exit report
      if Dest = rdNone then
        Exit;

      //Generate report
      Job := TAuditReport.Create;
      try
        Job.IsAdmin := True;
        //construct report
        Job.LoadReportSettings(UserPrintSettings, Report_List_Names[ REPORT_SYSTEM_AUDIT]);

        {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
        AddAdminHeader(Job);

        AddJobHeader(Job, siTitle, 'SYSTEM AUDIT REPORT', true);
        AddJobHeader(Job, siSubTitle, 'From ' +
                                      StDatetoDateString('dd/MM/yyyy', AuditReportOptions.DateFrom, true) +
                                      ' to ' +
                                      StDatetoDateString('dd/MM/yyyy', AuditReportOptions.DateTo, true),
                                      true);
        case AuditReportOptions.AuditSelection of
          byTransactionType: AddJobHeader(Job, siSubTitle, 'Transaction Type - ' +
                                          SystemAuditMgr.AuditTypeToStr(AuditReportOptions.TransactionType), true);
          byTransactionID  : AddJobHeader(Job, siSubTitle, 'Transaction ID - ' +
                                          IntToStr(AuditReportOptions.TransactionID), true);
        end;
        AddJobHeader( Job, siSubTitle, '', true);

        CLeft := GCLeft;
        AddColAuto( Job, cLeft, 20.0,gCgap, 'Transaction Type', jtLeft);
        AddColAuto( Job, cLeft, 15.0,gCgap, 'Transaction ID', jtLeft);
        AddColAuto( Job, cLeft, 15.0,gCgap, 'Audit Action', jtLeft);
        AddColAuto( Job, cLeft, 10.0,gCgap, 'User Code', jtLeft);
        AddColAuto( Job, cLeft, 40.0,gCgap, 'Date/Time', jtLeft);

        AddCommonFooter(Job);

        Job.OnBKPrint := AuditReportDetail;
        Job.ReportOptions := AuditReportOptions;
        Job.Generate(Dest);
      finally
        Job.Free;
      end;
    Dest := rdNone;
    end;
  finally
    AuditReportOptions.Free;
  end;
end;

procedure ClientAuditReportDetail(Sender : TObject);
var
  i, j : integer;
  Report: TAuditReport;
  AuditRecord: TAudit_Trail_Rec;
  AuditFields: TStringList;
  Values: string;
  PrintAuditRec: Boolean;
  TempClientFile: TClientObj;
begin
  Report := TAuditReport(Sender);

  TempClientFile := nil;
  OpenAClient(Report.ReportOptions.ClientCode, TempClientFile , True, True);
  if Assigned(TempClientFile) then try
    AuditFields := TStringList.Create;
    try
      AuditFields.StrictDelimiter := True;
      AuditFields.Delimiter := VALUES_DELIMITER;
      for i := 0 to Pred(TempClientFile.FAuditTable.AuditRecords.ItemCount) do begin
        AuditRecord := TempClientFile.fAuditTable.AuditRecords.Audit_At(i);

        //Date selection
        if (stDate.DateTimeToStDate(AuditRecord.atDate_Time) < Report.ReportOptions.DateFrom) or
           (stDate.DateTimeToStDate(AuditRecord.atDate_Time) > Report.ReportOptions.DateTo) then
           Continue;

        //Transaction selection
        case Report.ReportOptions.AuditSelection of
          byAll: PrintAuditRec := True;
          byTransactionType: PrintAuditRec := (Report.ReportOptions.TransactionType = AuditRecord.atTransaction_Type) or
                                              (Report.ReportOptions.TransactionType = atAll);
          byTransactionID  : PrintAuditRec := (Report.ReportOptions.TransactionID = AuditRecord.atRecord_ID);
        end;

        //Output
        if PrintAuditRec then begin
          Report.PutString(ClientAuditMgr.AuditTypeToStr(AuditRecord.atTransaction_Type));
          Report.PutString(IntToStr(AuditRecord.atRecord_ID));
          Report.PutString(aaNames[AuditRecord.atAudit_Action]);
          Report.PutString(AuditRecord.atUser_Code);
          Report.PutString(FormatDateTime('dd/MM/yyyy hh:mm:ss', AuditRecord.atDate_Time));

          Report.RenderDetailLine;

          Values := '';
          ClientAuditMgr.GetValues(AuditRecord, Values);
          AuditFields.DelimitedText := Values;
          for j := 0 to AuditFields.Count - 1 do
            Report.RenderTextLine('        ' + AuditFields[j]);
        end;
      end;
    finally
      AuditFields.Free;
    end;
  finally
    CloseAClient(TempClientFile);
  end;
end;

procedure DoClientAuditReport(var Dest : TReportDest);
var
  AuditReportOptions: TAuditReportOptions;
  Job: TAuditReport;
  CLeft: Double;
begin
  AuditReportOptions := TAuditReportOptions.Create;
  try
     //Set valid date range
     AuditReportOptions.DateFrom := MinValidDate;
     AuditReportOptions.DateTo := MaxValidDate;
     if AdminSystem.fAuditTable.AuditRecords.ItemCount > 0 then begin
       AuditReportOptions.DateFrom :=
         DateTimeToStDate(AdminSystem.fAuditTable.AuditRecords.Audit_At(AdminSystem.fAuditTable.AuditRecords.First).atDate_Time);
       AuditReportOptions.DateTo :=
         DateTimeToStDate(AdminSystem.fAuditTable.AuditRecords.Audit_At(AdminSystem.fAuditTable.AuditRecords.Last).atDate_Time);
     end;

     AuditReportOptions.AuditReportType := arClient;

     while Dest = rdNone do begin
       AuditReportOptions.Destination := rdNone;

       if GetAuditReportOptions(AuditReportOptions) then
         Dest := AuditReportOptions.Destination;

      //Exit report
      if Dest = rdNone then
        Exit;

      //Generate report
      Job := TAuditReport.Create;
      try
        Job.IsAdmin := True;
        //construct report
        Job.LoadReportSettings(UserPrintSettings, Report_List_Names[ REPORT_CLIENT_AUDIT]);

        {Add Headers: Job, Alignment, Font Factor, Caption, DoNewLine }
        AddAdminHeader(Job);

        AddJobHeader(Job, siTitle, 'CLIENT FILE AUDIT REPORT', true);
        AddJobHeader(Job, siSubTitle, 'From ' +
                                      StDatetoDateString('dd/MM/yyyy', AuditReportOptions.DateFrom, true) +
                                      ' to ' +
                                      StDatetoDateString('dd/MM/yyyy', AuditReportOptions.DateTo, true),
                                      true);
        case AuditReportOptions.AuditSelection of
          byTransactionType: AddJobHeader(Job, siSubTitle, 'Transaction Type - ' +
                                          SystemAuditMgr.AuditTypeToStr(AuditReportOptions.TransactionType), true);
          byTransactionID  : AddJobHeader(Job, siSubTitle, 'Transaction ID - ' +
                                          IntToStr(AuditReportOptions.TransactionID), true);
        end;
        AddJobHeader( Job, siSubTitle, '', true);

        CLeft := GCLeft;
        AddColAuto( Job, cLeft, 20.0,gCgap, 'Transaction Type', jtLeft);
        AddColAuto( Job, cLeft, 15.0,gCgap, 'Transaction ID', jtLeft);
        AddColAuto( Job, cLeft, 15.0,gCgap, 'Audit Action', jtLeft);
        AddColAuto( Job, cLeft, 10.0,gCgap, 'User Code', jtLeft);
        AddColAuto( Job, cLeft, 40.0,gCgap, 'Date/Time', jtLeft);

        AddCommonFooter(Job);

        Job.OnBKPrint := ClientAuditReportDetail;
        Job.ReportOptions := AuditReportOptions;
        Job.Generate(Dest);
      finally
        Job.Free;
      end;
    Dest := rdNone;
    end;
  finally
    AuditReportOptions.Free;
  end;
end;

{ TAuditReport }

procedure TAuditReport.ClearClientList;
begin
  inherited Create(rptOther);
  ClientList := TList.Create;
end;

constructor TAuditReport.Create;
begin
  inherited Create(rptOther);
  ClientList := TList.Create;
end;

destructor TAuditReport.Destroy;
begin
  ClearClientList;
  ClientList.Free;
  inherited;
end;

initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
