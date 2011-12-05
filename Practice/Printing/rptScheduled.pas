unit RptScheduled;
//------------------------------------------------------------------------------
{
   Title:

   Description:  Header pages for Scheduled Reports

   Author:

   Remarks:

   Last Reviewed: 22 May 2003 by MH
                  20 May 2003 by MH
}
//------------------------------------------------------------------------------
interface

uses
  ReportDefs,
  PrintMgrObj,
  Scheduled,
  SchedRepUtils;

procedure DoClientHeader(Destination : TReportDest; FromDate, ToDate : integer; Settings : TPrintManagerObj);
procedure DoStaffHeaderPage(Destination : TReportDest; aLRN : integer; Settings : TPrintManagerObj);
procedure DoGroupHeaderPage(Destination: TReportDest; aLRN: integer; Settings : TPrintManagerObj);
procedure DoClientTypeHeaderPage(Destination: TReportDest; aLRN: integer; Settings : TPrintManagerObj);

procedure DoScheduleReportsSummary( Dest          : TReportDest;
                                    PrintSettings : TPrintManagerObj;
                                    SrOptions     : TSchReportOptions);

//******************************************************************************
implementation

uses
   ReportTypes,
   Classes,
   NewReportObj,
   RepCols,
   NewReportUtils,
   glConst,
   Globals,
   bkDateUtils,
   Admin32,
   syDefs,
   bkDefs,
   bkconst,
   SysUtils, SysObj32, usrlist32;

type
   THeaderReport = class(TBKReport)
   public
     d1,d2 : integer;
   end;

   TSchdSummaryReport = class( TBKReport)
   public
      ReportParam : TSchReportOptions;
   end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ClientDetail(Sender : TObject);
var
   pCF     : pClient_File_Rec;
   pUser   : pUser_Rec;
begin
  with THeaderReport(Sender), MyClient.clFields, AdminSystem do
  begin
     RenderRuledLine;
     RenderTextLine('');
     RenderTitleLine('Client Details');

     //the spacing and indentation for the client details is formatted for
     //insertion into a windowed envelope

     RenderTextLine('');
     RenderTextLine('');
     RenderTextLine('');
     RenderTextLine('                  ' + clName);
     RenderTextLine('                  ' + clAddress_L1);
     RenderTextLine('                  ' + clAddress_L2);
     RenderTextLine('                  ' + clAddress_L3);
     RenderTextLine('');
     if ( Trim( clContact_Name) <> '') then
     begin
       if Trim(clSalutation) <> '' then
         RenderTextLine('                  ' + 'Attn:  ' + clSalutation + ' ' + clContact_Name)
       else
         RenderTextLine('                  ' + 'Attn:  ' + clContact_Name);
     end
     else
       RenderTextLine('');
     RenderTextLine('');
     RenderTextLine('');
     RenderTextLine('');
     if ( Trim( clPhone_No) <> '') then
        RenderTextLine('Phone : '+ clPhone_No);
     if ( Trim( clMobile_No) <> '') then
        RenderTextLine('Mobile : '+ clMobile_No);
     if ( Trim( clFax_No) <> '') then
       RenderTextLine('Fax : '+ clFax_No);
     if ( Trim( clClient_EMail_Address) <> '') then
        RenderTextLine('E-Mail : ' + clClient_EMail_Address);
     if ( Trim( clClient_CC_EMail_Address) <> '') then
        RenderTextLine('E-Mail CC: ' + clClient_CC_EMail_Address);

     RenderRuledLine;
     RenderTextLine('');

     //mjch sep 2001 changed so that SendReports to is no longer used
     pCF := fdSystem_Client_File_List.FindCode(clCode);
     if Assigned(pCF) then begin
        pUser := fdSystem_User_List.FindLRN(pCF^.cfUser_Responsible);
        if Assigned(pUser) then
           RenderTextLine('The staff member responsible for this client is: '+ pUser.usName+' ('+pUser.usCode+')');
           RenderTextLine('');
     end;

     RenderTextLine('The following report(s) are included:');
     RenderTextLine('');

     if clSend_Coding_Report then begin
       RenderTextLine('CODING REPORT from '+bkDate2Str(d1)+' to '+bkDate2Str(d2));
       RenderTextLine('');
     end;

     if clSend_Chart_of_Accounts then begin
       RenderTextLine('CHART OF ACCOUNTS');
       RenderTextLine('');
     end;

     if clSend_Payee_List then  begin
       RenderTextLine('PAYEE LIST');
       RenderTextLine('');
     end;

     if MyClient.clExtra.ceSend_Job_List then begin
       RenderTextLine('JOB LIST');
       RenderTextLine('');
     end;

     if (clScheduled_Client_Note_Message <> '') or
        (fdFields.fdSched_Rep_Header_Message <> '') then
     begin
       //render cover pages notes
       RenderTextLine('Notes:');

       if (clScheduled_Client_Note_Message <> '') then
       begin
         RenderTextLine('');
         RenderMemo( clScheduled_Client_Note_Message);
       end;

       if (fdFields.fdSched_Rep_Header_Message <> '') then
       begin
         //render header pages notes
         RenderTextLine('');
         RenderMemo( fdFields.fdSched_Rep_Header_Message);
       end;
     end;
  end; //with
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoClientHeader(Destination : TReportDest; FromDate, ToDate : integer; Settings : TPrintManagerObj);
var
  Job : THeaderReport;
begin
  Job := THeaderReport.Create(ReportTypes.rptOther);
  try
    Job.d1 := FromDate;
    Job.d2 := ToDate;
    Job.OnBKPrint := ClientDetail;

    //construct report
    Job.LoadReportSettings(Settings,Report_List_Names[REPORT_CLIENT_HEADER]);

    //Add Headers
    AddCommonHeader(Job);
    AddJobHeader(Job,SiTitle,'Client Header Page', true);

    //Add Footers
    AddCommonFooter(Job);

    Job.Generate( Destination);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure StaffHeaderDetail(Sender : TObject);
var
   i       : integer;
   StaffLRN : integer;
   pCF    : pClient_File_Rec;
begin
  with THeaderReport(Sender), MyClient.clFields, AdminSystem do
  begin
     StaffLRN := d1;

     RenderRuledLine;
     RenderTextLine('Reports will be generated for the following client(s):');
     RenderTextLine('');

     for i := 0 to Pred(fdSystem_Client_File_List.Itemcount) do begin
       pCF := fdSystem_Client_File_List.Client_File_At(i);
       with pCF^ do begin
         if (cfUser_Responsible = StaffLRN) and cfReports_Due then
         begin
           PutString(cfFile_Code);
           PutString(cfFile_Name);
           RenderDetailLine;
         end;
       end;
     end;
     RenderTextLine('');
     RenderRuledLine;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GroupHeaderDetail(Sender : TObject);
var
  HeaderReport: THeaderReport;
  i       : integer;
  GroupLRN : integer;
  pCF    : pClient_File_Rec;
begin
  HeaderReport := THeaderReport(Sender);
  GroupLRN := HeaderReport.d1;
  HeaderReport.RenderTextLine('Reports will be generated for the following client(s):');
  HeaderReport.RenderTextLine('');

  for i := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount - 1 do
  begin
    pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
    if (pCF^.cfGroup_LRN = GroupLRN) and pCF^.cfReports_Due then
    begin
      HeaderReport.PutString(pCF^.cfFile_Code);
      HeaderReport.PutString(pCF^.cfFile_Name);
      HeaderReport.RenderDetailLine;
    end;
  end;
  HeaderReport.RenderTextLine('');
  HeaderReport.RenderRuledLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ClientTypeHeaderDetail(Sender : TObject);
var
  HeaderReport: THeaderReport;
  i       : integer;
  ClientTypeLRN : integer;
  pCF    : pClient_File_Rec;
begin
  HeaderReport := THeaderReport(Sender);
  ClientTypeLRN := HeaderReport.d1;
  HeaderReport.RenderTextLine('Reports will be generated for the following client(s):');
  HeaderReport.RenderTextLine('');

  for i := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount - 1 do
  begin
    pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At(i);
    if (pCF^.cfClient_Type_LRN = ClientTypeLRN) and pCF^.cfReports_Due then
    begin
      HeaderReport.PutString(pCF^.cfFile_Code);
      HeaderReport.PutString(pCF^.cfFile_Name);
      HeaderReport.RenderDetailLine;
    end;
  end;
  HeaderReport.RenderTextLine('');
  HeaderReport.RenderRuledLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoClientTypeHeaderPage(Destination: TReportDest; aLRN: integer; Settings : TPrintManagerObj);
var
  Job: THeaderReport;
  pClientType: pClient_Type_Rec;
  cLeft: Double;
begin
  Job := THeaderReport.Create(ReportTypes.rptOther);
  try
    Job.d1 := aLRN;  //using the date from variable to store the LRN
    pClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(aLRN);
    if not Assigned(pClientType) then
      Exit;

    Job.OnBKPrint := ClientTypeHeaderDetail;

    //construct report
    Job.LoadReportSettings(Settings,Report_List_Names[Report_Sort_Header]);

    AddJobHeader(Job,jtLeft,0.8, 'DATE  <DATE>',false);
    AddJobHeader(Job,jtRight,0.8,'PAGE  <PAGE>',true);
    AddJobHeader(Job,siTitle,'Client Type Header Page', true);
    AddJobHeader(Job,siSubTitle, pClientType.ctName ,true);

    CLeft := GCLeft;
    AddColAuto(Job,CLeft,20,gCGap,'',jtLeft);
    AddColAuto(Job,CLeft,70,gCGap,'',jtLeft);

    Job.Generate( Destination);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoGroupHeaderPage(Destination: TReportDest; aLRN: integer; Settings : TPrintManagerObj);
var
  Job: THeaderReport;
  pGroup: pGroup_Rec;
  cLeft: Double;
begin
  Job := THeaderReport.Create(ReportTypes.rptOther);
  try
    Job.d1 := aLRN;  //using the date from variable to store the LRN
    pGroup := AdminSystem.fdSystem_Group_List.FindLRN(aLRN);
    if not Assigned(pGroup) then
      Exit;

    Job.OnBKPrint := GroupHeaderDetail;

    //construct report
    Job.LoadReportSettings(Settings,Report_List_Names[Report_Sort_Header]);

    AddJobHeader(Job,jtLeft,0.8, 'DATE  <DATE>',false);
    AddJobHeader(Job,jtRight,0.8,'PAGE  <PAGE>',true);
    AddJobHeader(Job,siTitle,'Group Header Page', true);
    AddJobHeader(Job,siSubTitle, pGroup.grName ,true);

    CLeft := GCLeft;
    AddColAuto(Job,CLeft,20,gCGap,'',jtLeft);
    AddColAuto(Job,CLeft,70,gCGap,'',jtLeft);

    Job.Generate( Destination);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoStaffHeaderPage(Destination : TReportDest; aLRN : integer; Settings : TPrintManagerObj);
var
  Job: THeaderReport;
  pUser: pUser_Rec;
  cLeft: Double;
begin
  Job := THeaderReport.Create(ReportTypes.rptOther);
  try
    Job.d1 := aLRN;  //using the date from variable to store the LRN

    with AdminSystem do
    begin
      pUser := fdSystem_User_List.FindLRN(aLRN);
      if not Assigned(pUser) then exit;
    end;

    Job.OnBKPrint := StaffHeaderDetail;

    //construct report
    Job.LoadReportSettings(Settings,Report_List_Names[Report_Sort_Header]);

    AddJobHeader(Job,jtLeft,0.8, 'DATE  <DATE>',false);
    AddJobHeader(Job,jtRight,0.8,'PAGE  <PAGE>',true);
    AddJobHeader(Job,siTitle,'Staff Member Header Page', true);
    AddJobHeader(Job,siSubTitle,pUser.usName+' ('+pUser.usCode+')',true);


    CLeft := GCLeft;
    AddColAuto(Job,CLeft,20,gCGap,'',jtLeft);
    AddColAuto(Job,CLeft,70,gCGap,'',jtLeft);

    Job.Generate( Destination);
  finally
    Job.Free;
  end;
end;

//------------------------------------------------------------------------------
// SummaryRepDetailStaff
//   Sender : TSchdSummaryReport
//
// print for each staff member, then print those not allocated
//
procedure SummaryRepDetailStaff(Sender : TObject);
var
  UnprintedLastMonth: Boolean;
  TitleLinePrinted: boolean;
  LastClientCode: string;

  function HasClientsToPrint( StaffLRN : integer) : boolean;
  //----------------------------------------------------------------------------
  //
  // HasClientsToPrint
  //   StaffLRN : Staff member user ID
  //
  // Returns true if there are sched rep summary records for this staff id
  //
  var
    CurrRec : pSchdRepSummaryRec;
    i : integer;
  begin
    result := false;
    //loop over each client and bank account in the list
    with TSchdSummaryReport(Sender) do
    begin
      for i := 0 to ReportParam.srSummaryInfoList.Count - 1 do
      begin
        CurrRec := pSchdRepSummaryRec(ReportParam.srSummaryInfoList[i]);
        if (StaffLRN = CurrRec^.UserResponsible) then
        begin
          result := true;
          exit;
        end;
      end;
    end;
  end;

  //----------------------------------------------------------------------------
  //
  // PrintAccountsFor
  //   StaffLRN : Staff member user ID
  //   StaffCode : Staff member text to display
  //   Completed : Print accounts that have or have not been completed
  //
  // Print all accounts for each client assigned to the staff member specified
  //
  procedure PrintAccountsFor(StaffLRN : Integer; StaffCode : String; Completed : Boolean);
  var
    i : integer;
    LastCode : String; //last client code displayed
    FirstLine : Boolean; //first line of the clients bank accounts
    DisplayUser : Boolean; //display the staffcode text
    PrintRecord : Boolean;
    CurrRec : pSchdRepSummaryRec;
    pSB : pSystem_Bank_Account_Rec;
  begin
    LastCode := '';
    DisplayUser := True;
    with TSchdSummaryReport(Sender) do
    begin
      //loop over each client and bank account in the list
      for i := 0 to ReportParam.srSummaryInfoList.Count - 1 do
      begin
        CurrRec := pSchdRepSummaryRec(ReportParam.srSummaryInfoList[i]);
        if (Completed) then
          PrintRecord := ((CurrRec^.UserResponsible = StaffLRN) and (CurrRec^.Completed))
        else
          PrintRecord := (not CurrRec^.Completed) and (CurrRec^.AccountNo <> CUSTOM_DOCUMENT);

        if (PrintRecord) then
        begin
          //the staff member matches the user responsible for the client
          if (DisplayUser) then
          begin
            RenderTitleLine(StaffCode);
            DisplayUser := False;
          end;

          if (LastCode <> CurrRec^.ClientCode) then
          begin
            LastCode := CurrRec^.ClientCode;
            if CurrRec^.TxLastMonth then
            begin
              PutString(LastCode + '#');
              UnprintedLastMonth := True;
            end
            else
              PutString(LastCode);
            FirstLine := True;
          end
          else begin
            SkipColumn;
            FirstLine := False;
          end;
          PutString(CurrRec^.AccountNo);

          //get account name
          pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode(CurrRec^.AccountNo);
          if Assigned( pSB) then
             PutString( pSB^.sbAccount_Name)
          else
             SkipColumn;

          if FirstLine then
             PutString( '(' + inttostr(CurrRec^.AcctsPrinted) + ' of ' + inttostr(CurrRec^.AcctsFound) + ')')
          else
             SkipColumn;

          PutString( BkDate2Str(CurrRec^.PrintedFrom));
          PutString( BkDate2Str(CurrRec^.PrintedTo));

          //sent by
          if Completed and FirstLine then
          begin
            //only display on the first line for completed items.
            case CurrRec^.SendBy of
               rdEmail           : PutString( 'E-Mail');
               rdPrinter         : PutString( 'Printer');
               rdEcoding         : PutString( glConst.ECODING_APP_NAME);
               rdWebX            : PutString( WEBX_GENERIC_APP_NAME);
               rdScreen          : PutString( 'Preview');
               rdFax             : PutString( 'Fax');
               rdCSVExport       : PutString( 'CSV Export');
               rdCheckOut        : PutString( 'BankLink Books');
               rdBusinessProduct : PutString( 'Business Prod');
            else
               SkipColumn;
            end;
          end
          else
            SkipColumn;

          RenderDetailLine;
        end;
      end;
    end;
  end;

var
  i : Integer;
  pCF : pClient_File_Rec;
  pUSer : pUser_Rec;
  CurrRec : pSchdRepSummaryRec;
begin
  UnprintedLastMonth := False;
  with TSchdSummaryReport(Sender) do
  begin
    //go through and set the user responsible field, this is done here so that
    //we can pick up any clients with invalid staff member LRNS
    for i := 0 to ReportParam.srSummaryInfoList.Count - 1 do
    begin
      CurrRec := pSchdRepSummaryRec(ReportParam.srSummaryInfoList[i]);
      CurrRec.UserResponsible := 0;

      pCF := AdminSystem.fdSystem_Client_File_List.FindCode(CurrRec^.ClientCode);
      if Assigned( pCF) then
      begin
        if pCF^.cfUser_Responsible <> 0 then
        begin
          pUser := AdminSystem.fdSystem_User_List.FindLRN( pCF^.cfUser_Responsible);
          if Assigned( pUser) then
            CurrRec.UserResponsible := pUser.usLRN
          else
            CurrRec.UserResponsible := -1;
        end
      end;
    end;

    //loop over the user list
    with AdminSystem.fdSystem_User_List do
      for i := 0 to ItemCount - 1 do
        with User_At(i)^ do
          if HasClientsToPrint( usLRN) then
            PrintAccountsFor(usLRN, usCode+' : '+usName, True);


    if HasClientsToPrint( 0) then
      PrintAccountsFor(0, 'Not yet allocated', True);

    if HasClientsToPrint( -1) then
      PrintAccountsFor(-1, 'Allocated to unknown staff members', True);

    PrintAccountsFor(0, 'Reports for the following clients were not generated due to errors', False);

    //List clients that failed to output custom documents
    LastClientCode := '';
    for i := 0 to ReportParam.srSummaryInfoList.Count - 1 do begin
      CurrRec := pSchdRepSummaryRec(ReportParam.srSummaryInfoList[i]);
      if (not CurrRec^.Completed) and (CurrRec^.AccountNo = CUSTOM_DOCUMENT) then begin
        if (not TitleLinePrinted) then
        begin
          RenderTitleLine('Custom documents for the following clients were not generated because they no longer exist');
          TitleLinePrinted := False;
        end;

        if (LastClientCode <> CurrRec^.ClientCode) then
        begin
          LastClientCode := CurrRec^.ClientCode;
          if CurrRec^.TxLastMonth then
          begin
            PutString(LastClientCode + '#');
            UnprintedLastMonth := True;
          end
          else
            PutString(LastClientCode);
        end
        else begin
          SkipColumn;
        end;
        SkipColumn; //Account number
        SkipColumn; //Account name
        SkipColumn; //From
        SkipColumn; //To
        SkipColumn; //Generated
        SkipColumn; //Staff
        SkipColumn; //Sent by
        RenderDetailLine;
      end;
    end;

    if UnprintedLastMonth then
    begin
      RenderTextLine('');
      RenderTextLine('# These clients have unprinted transactions from the previous month - these transactions are automatically included.');
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure SummaryRepDetailClient(Sender : TObject);
Type
  TRptSections = (rpsSent, rpsError, rptNoCustDoc, rpsNotesOnlineError,
                  rpsCiCoOnlineError, rptEmailOnlineError);
var
  SumInfoIndex : integer;
  RptSections  : TrptSections;
  CurrRec : pSchdRepSummaryRec;
  LastCode : string;
  FirstLine: boolean;
  PrintRecord : Boolean;
  UnprintedLastMonth: Boolean;
  pCF     : pClient_File_Rec;
  pUser   : pUser_Rec;
  pSB     : pSystem_Bank_Account_Rec;
  SchSumRpt : TSchdSummaryReport;
begin
  UnprintedLastMonth := False;

  SchSumRpt := TSchdSummaryReport(Sender);

  // Go through differant sections of the Report showing data if found
  for RptSections := low(TRptSections) to high(TRptSections) do
  begin
    LastCode := '';

    // Goes through each account
    for SumInfoIndex := 0 to Pred( SchSumRpt.ReportParam.srSummaryInfoList.Count) do
    begin
       CurrRec := pSchdRepSummaryRec( SchSumRpt.ReportParam.srSummaryInfoList[SumInfoIndex]);

       case RptSections of
         rpsSent :
           PrintRecord := CurrRec^.Completed;
         rpsError :
           PrintRecord := (not CurrRec^.Completed)
                      and (CurrRec^.AccountNo <> CUSTOM_DOCUMENT)
                      and not (CurrRec^.SendBy in [rdBankLinkOnline, rdWebX]);
         rptNoCustDoc :
           PrintRecord := (not CurrRec^.Completed)
                      and (CurrRec^.AccountNo = CUSTOM_DOCUMENT)
                      and not (CurrRec^.SendBy in [rdBankLinkOnline, rdWebX]);
         rpsNotesOnlineError :
           PrintRecord := (not CurrRec^.Completed)
                      and (CurrRec^.SendBy = rdWebX);
         rpsCiCoOnlineError :
           PrintRecord := (not CurrRec^.Completed)
                      and (CurrRec^.SendBy = rdBankLinkOnline)
                      and (not CurrRec^.EmailSendFail);
         rptEmailOnlineError :
           PrintRecord := (not CurrRec^.Completed)
                      and (CurrRec^.SendBy = rdBankLinkOnline)
                      and (CurrRec^.EmailSendFail);
       end;

       if (PrintRecord) then
       begin
         if (LastCode = '') then
         begin
           case RptSections of
             rpsError :
               SchSumRpt.RenderTitleLine('Reports for the following clients were not generated due to errors');
             rptNoCustDoc :
               SchSumRpt.RenderTitleLine('Custom documents for the following clients were not generated because they no longer exist');
             rpsNotesOnlineError :
               SchSumRpt.RenderTitleLine('BankLink Notes Online data for the following clients were not generated due to errors');
             rpsCiCoOnlineError  :
               SchSumRpt.RenderTitleLine('BankLink Books files to be sent via BankLink Online for the following clients were not generated due to errors');
             rptEmailOnlineError :
               SchSumRpt.RenderTitleLine('Emails for the following BankLink Online clients were not generated due to errors');
           end;
         end;

         if ( CurrRec^.ClientCode <> LastCode) then begin
           if CurrRec^.TxLastMonth then
           begin
             SchSumRpt.PutString( CurrRec^.ClientCode + '#');
             UnprintedLastMonth := True;
           end
           else
             SchSumRpt.PutString( CurrRec^.ClientCode);
           LastCode  := CurrRec^.ClientCode;
           FirstLine := true;
         end
         else begin
           SchSumRpt.SkipColumn;
           FirstLine := false;
         end;

         if (CurrRec^.AccountNo <> CUSTOM_DOCUMENT) then begin
           SchSumRpt.PutString( CurrRec^.AccountNo);

           //get account name
           pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( CurrRec^.AccountNo);
           if Assigned( pSB) then
              SchSumRpt.PutString( pSB^.sbAccount_Name)
           else
              SchSumRpt.SkipColumn;

           if FirstLine then
              SchSumRpt.PutString( '(' + inttostr( CurrRec^.AcctsPrinted) + ' of ' + inttostr( CurrRec^.AcctsFound) + ')')
           else
              SchSumRpt.SkipColumn;

           SchSumRpt.PutString( BkDate2Str( CurrRec^.PrintedFrom));
           SchSumRpt.PutString( BkDate2Str( CurrRec^.PrintedTo));

           if FirstLine then begin
              //get staff member code
              with AdminSystem do begin
                 pCF   := fdSystem_Client_File_List.FindCode( CurrRec^.ClientCode);
                 if Assigned(pCF) then begin
                    pUser := fdSystem_User_List.FindLRN(pCF^.cfUser_Responsible);
                 end else
                   pUser := nil;
                 if Assigned(pUser) and Assigned(pCF) then
                    SchSumRpt.PutString( pUser^.usCode)
                 else
                    SchSumRpt.SkipColumn;
              end;
           end
           else
              SchSumRpt.SkipColumn;

           //sent by
           if (RptSections = rpsSent) and FirstLine then
           begin
             //only display on the first line for completed items.
             case CurrRec^.SendBy of
                rdEmail           : SchSumRpt.PutString('E-Mail');
                rdPrinter         : SchSumRpt.PutString('Printer');
                rdEcoding         : SchSumRpt.PutString(glConst.ECODING_APP_NAME);
                rdWebX            : SchSumRpt.PutString(WEBX_GENERIC_APP_NAME);
                rdScreen          : SchSumRpt.PutString('Preview');
                rdFax             : SchSumRpt.PutString('Fax');
                rdCSVExport       : SchSumRpt.PutString('CSV Export');
                rdCheckOut        : SchSumRpt.PutString('BankLink Books (Email)');
                rdBankLinkOnline  : SchSumRpt.PutString('BankLink Books (via Online)');
                rdBusinessProduct : SchSumRpt.PutString('Business Prod');
             else
                SchSumRpt.SkipColumn;
             end;
           end
           else
              SchSumRpt.SkipColumn;
         end else begin
           SchSumRpt.SkipColumn; //Account number
           SchSumRpt.SkipColumn; //Account name
           SchSumRpt.SkipColumn; //From
           SchSumRpt.SkipColumn; //To
           SchSumRpt.SkipColumn; //Generated
           SchSumRpt.SkipColumn; //Staff
           SchSumRpt.SkipColumn; //Sent by
         end;

         SchSumRpt.RenderDetailLine;
       end;
    end;
  end;
  if UnprintedLastMonth then
  begin
    SchSumRpt.RenderTextLine('');
    SchSumRpt.RenderTextLine('# These clients have unprinted transactions from the previous month - these transactions are automatically included.');
  end;
end;
//------------------------------------------------------------------------------

procedure DoScheduleReportsSummary( Dest          : TReportDest;
                                    PrintSettings : TPrintManagerObj;
                                    SrOptions     : TSchReportOptions);
var
  Job : TSchdSummaryReport;
  CLeft: Double;
begin
  if srOptions.srSummaryInfoList.Count = 0 then exit;

  Job := TSchdSummaryReport.Create(ReportTypes.rptOther);
  try
    Job.ReportParam := SrOptions;
    Job.IsAdmin := True;
    //construct report
    Job.LoadReportSettings( PrintSettings, Report_List_Names[ Report_Schd_Rep_Summary]);

    AddCommonHeader(Job,AdminSystem.fdFields.fdPractice_Name_for_Reports);

    AddJobHeader(Job,SiTitle, 'SCHEDULED REPORTS SUMMARY', true);
    AddJobHeader(Job,SiTitle, '', true);

    cLeft := GCLeft;
    if AdminSystem.fdFields.fdSort_Reports_By = srsoStaffMember then
    begin
      Job.OnBKPrint := SummaryRepDetailStaff;

      AddColAuto( Job, cLeft, 9,    gCGap, 'Client Code',    jtLeft);
      AddColAuto( Job, cLeft, 17.5, gCGap, 'Account Number', jtLeft);
      AddColAuto( Job, cLeft, 31.5, gCGap, 'Account Name',   jtLeft);
      AddColAuto( Job, cLeft, 9,    gCGap, 'Generated',      jtLeft);
      AddColAuto( Job, cLeft, 7,    gCGap, 'From',           jtLeft);
      AddColAuto( Job, cLeft, 7,    gCGap, 'To',             jtLeft);
      AddColAuto( Job, cLeft, 10.5, gCGap, 'Sent To',        jtLeft);
    end else
    begin
      Job.OnBKPrint := SummaryRepDetailClient;

      AddColAuto( Job, cLeft, 9,    gCGap, 'Client Code' ,   jtLeft);
      AddColAuto( Job, cLeft, 17.5, gCGap, 'Account Number', jtLeft);
      AddColAuto( Job, cLeft, 21.5, gCGap, 'Account Name',   jtLeft);
      AddColAuto( Job, cLeft, 9,    gCGap, 'Generated',      jtLeft);
      AddColAuto( Job, cLeft, 7,    gCGap, 'From',           jtLeft);
      AddColAuto( Job, cLeft, 7,    gCGap, 'To',             jtLeft);
      AddColAuto( Job, cLeft, 10,   gCGap, 'Staff Member',   jtLeft);
      AddColAuto( Job, cLeft, 10.5, gCGap, 'Sent To',        jtLeft);
    end;
    AddCommonFooter(Job);
    Job.Generate(Dest);
  finally
    Job.Free;
  end;
end;

//------------------------------------------------------------------------------

end.
