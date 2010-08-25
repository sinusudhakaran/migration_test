unit rptOffsite;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Offsite Client Reports
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ReportDefs;

   procedure DoOffsiteDownloadLog(Dest : TReportDest);

//******************************************************************************
implementation
uses
   ReportTypes,
   NewReportObj,
   repcols,
   bkdefs,
   globals,
   bkDateUtils,
   SysUtils,
   NewReportUtils,
   clObj32,
   stDatest;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DownloadLogDetail(Sender : TObject);
var
   i : integer;
begin
  with TBKReport(Sender), MyClient do
  begin
     with clDisk_Log do
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
procedure DoOffsiteDownloadLog(Dest : TReportDest);
var
  Job : TBKReport;
  cLeft: Double;
begin
  Job := TBKReport.Create(ReportTypes.rptOther);
  try
    //construct report
    Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_DOWNLOAD_LOG_OFFSITE]);

    //Add Headers
    AddCommonHeader(Job);
    AddJobHeader(Job,siTitle,'DOWNLOAD LOG',true);
    AddJobHeader(Job,siSubTitle,'',true);

    cLeft := gCLeft;
    AddColAuto(Job,cLeft, 40.0,gCGap,'Download ID',jtLeft);
    AddColAuto(Job,cLeft, 13.0,gCGap,'Date',jtLeft);
    AddColAuto(Job,cLeft, 12.8,gCGap,'Accounts',jtRight);

    AddFormatColAuto(Job,cLeft,12.3,gCGap,'Entries',jtRight,'0','0',True);

    //Add Footers
    AddCommonFooter(Job);

    Job.OnBKPrint := DownloadLogDetail;
    Job.Generate( Dest);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
