// Reports for mail merge
unit rptMailMerge;

interface

uses ReportDefs, Classes;

procedure DoMergePrintReport( Dest : TReportDest; Task, DateGenerate, DateFollow, SourceDoc, DestDoc: string; Codes: TStrings);
procedure DoMergeEMailReport( Dest : TReportDest; Task, Desc, DateGenerate, DateFollow: string; Codes: TStrings);

implementation

uses
   ReportTypes,
   ReportImages,
   NewReportObj, NewReportUtils, Globals, RepCols, SYDEFS, ClientDetailCacheObj;

var
  Clients: TStrings;

// Detail clients that have been included in the mail merge (print) report
procedure ListPrintedClients(Sender : TObject);
var
  cfRec: pClient_File_Rec;
  i: Integer;
begin
  with TBKReport(Sender) do
  begin
    for i := 0 to Pred(Clients.Count) do
    begin
      cfRec := pClient_File_rec(Clients.Objects[i]);
      with ClientDetailsCache do
      begin
        Load(cfRec^.cfLRN);
        PutString(Clients[i]);
        PutString(Name);
        RenderDetailLine;
      end;
    end;
  end;
end;

// Generate mail merge (print) summary report
procedure DoMergePrintReport( Dest : TReportDest; Task, DateGenerate, DateFollow, SourceDoc, DestDoc: string; Codes: TStrings);
var
   Job : TBKReport;
   cLeft: Double;
Begin
   if Dest = rdNone then Dest := rdScreen;
   CreateReportImageList;
   Job := TBKReport.Create(ReportTypes.rptOther);
   Clients := TStringList.Create;
   try
     Clients.Assign(Codes);
     Job.LoadReportSettings(UserPrintSettings,Report_List_Names[ REPORT_MAILMERGE_PRINT]);
     Job.IsAdmin := True;
     //Add Headers
     AddJobHeader(Job,siTitle,'MAIL MERGE (PRINT) SUMMARY REPORT',true);


     if DateFollow <> '' then
       AddJobHeader(Job,siSubTitle,'Generated on: ' + DateGenerate + ', Reminder on: ' + DateFollow,true)
     else
       AddJobHeader(Job,siSubTitle,'Generated on: ' + DateGenerate,true);

     AddJobHeader(Job,siSubTitle,'',true);

     if Task <> '' then
        AddJobHeader(Job,siSubTitle,'Task created: ' + Task,True,jtLeft);

     AddJobHeader(Job,siSubTitle,'Using document: ' + SourceDoc,True,jtLeft);
     AddJobHeader(Job,siSubTitle,'Saved to: ' + DestDoc,True,jtLeft);

     cLeft := GCLeft;
     AddColAuto( Job,cLeft,   10, gCGap, 'Code', jtLeft);
     AddColAuto( Job,cLeft,   60, gcGap, 'Client Name', jtLeft);

     //Add Footers
     AddCommonFooter(Job);

     Job.OnBKPrint := ListPrintedClients;
     Job.Generate( Dest);
   finally
     Clients.Free;
     Job.Free;
     DestroyReportImageList;
   end;
end;

// Detail clients that have been included in the mail merge (email) report
procedure ListEmailedClients(Sender : TObject);
var
  cfRec: pClient_File_Rec;
  i: Integer;
begin
  with TBKReport(Sender) do
  begin
    for i := 0 to Pred(Clients.Count) do
    begin
      cfRec := pClient_File_rec(Clients.Objects[i]);
      with ClientDetailsCache do
      begin
        Load(cfRec^.cfLRN);
        PutString(Clients[i]);
        PutString(Name);
        if Email_Address = '' then
        begin
          PutString('<no email address>');
          PutString('FAILED');
        end
        else
        begin
          PutString(Email_Address);
          PutString('MERGED');
        end;
        RenderDetailLine;
      end;
    end;
  end;
end;

// Generate mail merge (email) summary report
procedure DoMergeEMailReport( Dest : TReportDest; Task, Desc, DateGenerate, DateFollow: string; Codes: TStrings);
var
   Job : TBKReport;
   cLeft: Double;
Begin
   if Dest = rdNone then Dest := rdScreen;
   CreateReportImageList;
   Job := TBKReport.Create(ReportTypes.rptOther);
   Clients := TStringList.Create;
   try
     Clients.Assign(Codes);
     Job.LoadReportSettings(UserPrintSettings,Report_List_Names[ REPORT_MAILMERGE_EMAIL]);

     //Add Headers
     AddJobHeader(Job,siTitle,'MAIL MERGE (EMAIL) SUMMARY REPORT',true);
     AddJobHeader(Job,siSubTitle,Desc,true);
     if DateFollow <> '' then
       AddJobHeader(Job,siSubTitle,'Generated on: ' + DateGenerate + ', Reminder on: ' + DateFollow,true)
     else
       AddJobHeader(Job,siSubTitle,'Generated on: ' + DateGenerate,true);

     AddJobHeader(Job,siSubTitle,'',true);

     if Task <> '' then begin
//        Job.RenderTextLine('Task created: ' + Task); No render engine exists at this stage!
        AddJobHeader(Job,siSubTitle,'Task created: ' + Task,true);
        AddJobHeader(Job,siSubTitle,'',true);
     end;

     cLeft := gCLeft;
     AddColAuto( Job,cLeft,   10, gCGap, 'Client Code', jtLeft);
     AddColAuto( Job,cLeft,   28, gCGap,'Client Name', jtLeft);
     AddColAuto( Job,cLeft,   40, gCGap,'Email Address', jtLeft);
     AddColAuto( Job,cLeft,   14, gCGap,'Status', jtLeft);

     //Add Footers
     AddCommonFooter(Job);

     Job.OnBKPrint := ListEmailedClients;
     Job.Generate( Dest);
   finally
    Clients.Free;
    Job.Free;
    DestroyReportImageList;
   end;
end;

end.



