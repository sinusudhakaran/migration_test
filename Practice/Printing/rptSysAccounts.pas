// Make a report that shows what is currently visible Maintain System Accounts
unit rptSysAccounts;

interface

uses ReportDefs, SysAccountsfme;

procedure DoSysAccount(Dest : TReportDest; fromFrame: TfmeSysAccounts);

implementation

uses
  CMFilterForm,
  ReportToCanvas,
  ReportTypes,
  Rptparams, Classes, sysUtils, Windows, NewReportObj, Globals, NewReportUtils, RepCols,
  VirtualTrees, InfoMoreFrm, ShellAPI, PrintDestDlg, bkConst, UserReportSettings,
  Graphics, VirtualTreeHandler, Math, bkBranding;

type
  TSysAccReport = class(TBKReport)
  public
    fromFrame: TfmeSysAccounts;
  end;

procedure GetMaxWidths(Sender:TObject);
var
  gc,rc: integer;
  aNode : pVirtualNode;
  NodeData : TSABaseItem;
  ReportW,
  AvailW: Integer;
  PrecentWidth,
  Gap,
  GLeft: Double;


const Margin = 20; //Absolute report and Column marging
begin
  if TSysAccReport(Sender).fromFrame.AccountList.Count = 0 then
     Exit; // Nothing To Print

  with TSysAccReport(Sender) do begin

     // Make the columns
     Columns.Freeall;

     RenderEngine.SetItemStyle(siHeading);

     with fromFrame.AccountTree.Header do
     for gc := 0 to Columns.Count - 1 do
     with Columns[Columns.ColumnFromPosition(gc)] do
     if coVisible in Options then begin
        // Add the column with the initial width
        AddJobColumn(TSysAccReport(Sender),0,0,Text,AlignmentToJustification(Alignment )).Width := RenderEngine.GetTextLength(Text);
     end;

     // Check the rest of the Text..
     RenderEngine.SetItemStyle(siDetail);
     aNode := FromFrame.AccountTree.GetFirst;
     while assigned(aNode) do begin
        NodeData := TSABaseItem(FromFrame.AccountList.GetNodeItem(aNode));

        if Assigned(NodeData) then begin
           if Assigned(NodeData.SysAccount) then begin
              rc := -1;//Report Column
              with fromFrame.AccountTree do
              for gc := 0 to Header.Columns.Count - 1 do
                 with Header.Columns[Header.Columns.ColumnFromPosition(gc)] do
                 if coVisible in Options then begin
                    inc(rc);
                    // Update the column width
                    Columns.Report_Column_At(rc).Width := max( Columns.Report_Column_At(rc).Width, RenderEngine.GetTextLength(NodeData.GetTagText(Tag)));
                 end;
           end;

        end;
        aNode := FromFrame.AccountTree.GetNext(aNode)
     end; //While

     // Now adjust all the column withs...
     // First get the reportwidth
     ReportW := Margin;
     for rc := 0 to Columns.ItemCount - 1 do
        Inc(ReportW, Columns.Report_Column_At(rc).Width + margin);
     // Work out whats available
     AvailW := RenderEngine.GetPrintableWidth;

     if ReportW >= AvailW then begin
        // have to Scale..
        gc :=  ReportW + Round((Columns.ItemCount * gcGap * ReportW * 2) /100) ;
        Gap := Trunc((AvailW / gc) * 10) / 10; // Lacal var for easy debug
        UserReportSettings.s7Temp_Font_Scale_Factor := Gap;
     end else begin
        UserReportSettings.s7Temp_Font_Scale_Factor :=  1.0;
     end;
        Gap := gcGap;
        PrecentWidth := 100.0 - GCLeft - (Columns.ItemCount - 1) * Gap;
        GLeft := GCLeft;
        // Redisribute the columns
        for rc := 0 to Columns.ItemCount - 2 do
           with Columns.Report_Column_At(rc) do begin
              LeftPercent := GLeft;
              WidthPercent := ((width + Margin)  *  PrecentWidth) / ReportW;
              GLeft := GLeft + WidthPercent + Gap;
           end;

        with Columns.Report_Column_At(Columns.ItemCount - 1) do begin
           LeftPercent := GLeft;
           WidthPercent := 100 - LeftPercent;
        end;

  end; //with sender
end;

procedure ListSysAccDetail(Sender:TObject);
var
  c: integer;
  aNode : pVirtualNode;
  NodeData : TSABaseItem;
begin
  if TSysAccReport(Sender).FromFrame.AccountList.Count = 0 then
     exit; // nothing to do...

  with TSysAccReport(Sender) do begin
     aNode := FromFrame.AccountTree.GetFirst;
     while assigned(aNode) do begin
        NodeData := TSABaseItem(FromFrame.AccountList.GetNodeItem(aNode));

        if Assigned(NodeData) then begin
           if Assigned(NodeData.SysAccount) then begin
              with fromFrame.AccountTree.Header do
              for c := 0 to Columns.Count - 1 do
                 with Columns[Columns.ColumnFromPosition(c)] do
                 if coVisible in Options then begin
                    PutString(NodeData.GetTagText(Tag));
                 end;
              RenderDetailLine;
           end else begin
              // Must be a Group Title.
              RenderTitleLine(NodeData.Title);
           end;
        end;
        aNode := FromFrame.AccountTree.GetNext(aNode)
     end; //While

  end; //with sender
end;




procedure DoSysAccount(Dest : TReportDest; fromFrame: TfmeSysAccounts);
var
   Job: TSysAccReport;
   btn: Integer;
   lParams: TRptParameters;

   procedure AddFilterTitles;
   var Title: string;

   begin
      case FromFrame.cbFilter.ItemIndex of
        cbf_All        : Exit;
        cbf_Attached   : AddJobHeader(Job,siSubTitle,'Attached accounts only',true);
        cbf_New        : AddJobHeader(Job,siSubTitle,'New accounts only',true);
        cbf_Unattached : AddJobHeader(Job,siSubTitle,'Unattached accounts only',true);
        cbf_Deleted    : AddJobHeader(Job,siSubTitle,'Marked as Deleted accounts only',true);
        cbf_Inactive   : AddJobHeader(Job,siSubTitle,'Inactive accounts only',true);
        cbf_Provisional: AddJobHeader(Job,siSubTitle,'Provisional accounts only',true);
        else begin
             Title :=  FromFrame.Include.GetFilterText;
             if Title > '' then
                AddJobHeader(Job,siSubTitle, Title,true);

        end;
      end;

   end;
begin
   if not AreThereAnyPrinters then
   begin
     HelpfulInfoMsg('You must setup a Windows Printer before running any Reports.  '+
                    SHORTAPPNAME+' will now take you to the Windows Printers Folder.  '+
                    'You can then select Add Printer to add a printer for windows to use.',0);
     ShellExecute(0, 'open', 'control.exe', 'printers', nil, SW_NORMAL);
     exit;
   end;

   lParams := TRptParameters.Create(ord(Report_System_Accounts),MyClient,nil);

   try repeat
      if Dest = rdAsk then
         if SimpleSelectReportDest(Report_List_Names[Report_System_Accounts], btn, 0) then
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

      Job := TSysAccReport.Create(ReportTypes.rptOther);
      try
         Job.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_System_Accounts]);
         Job.UserReportSettings.s7Temp_Font_Scale_Factor := 1.0;// Gets recalculated, So dont use the saved one
         Job.fromFrame := FromFrame;
         Job.IsAdmin := True;

         // First find out how much space is needed for the name column
         Job.OnBKPrint := GetMaxWidths;

         if Dest = rdFile then begin
            Job.Generate(Dest, nil, False);
            Job.FileIsSet:= True;
            if (Job.FileDest = -1) then // user cancelled
               exit;
         end else begin
            Job.Generate( {Dest} rdScreen, nil, False);
            Job.FileIsSet:= True;
         end;

         //Add Headers

         AddJobHeader(Job,siTitle,REPORT_LIST_NAMES[Report_System_Accounts] + ' as at ' + FormatDateTime('dd/mm/yy', Date),true);
         AddFilterTitles;
         AddJobHeader(Job,siSubTitle,'',true);


         AddCommonFooter(Job);
         Job.OnBKPrint := ListSysAccDetail;
         Job.Generate(Dest,lParams);


      finally
        Job.Free;
      end;
      Dest := rdAsk; //Ask again...
   until lParams.RunExit(rdScreen);
   finally
      lParams.Free;
   end;
end;

end.
