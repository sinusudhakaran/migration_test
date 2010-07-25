// Make a report that shows what is currently visible in the client manager
unit rptClientManager;


interface

uses ReportDefs, ClientLookupFme, Math;

procedure DoClientManagerReport(Dest : TReportDest; CM: TfmeClientLookup; Title: string);

implementation

uses
  ReportTypes,
  Classes, sysUtils, Windows, NewReportObj, Globals, NewReportUtils, RepCols,
  VirtualTrees, InfoMoreFrm, ShellAPI, PrintDestDlg, bkConst, UserReportSettings,
  Graphics, bkBranding, ReportImages;

type
  TClientManagerReport = class(TBKReport)
  public
    CM: TfmeClientLookup;
    NameW, ActionW, StatusW, TotalW: Integer;
  end;

procedure GetMaxWidths(Sender:TObject);
var
  i, j, MaxN, MaxA, MaxS : integer;
  aNode : pVirtualNode;
  NodeData : pTreeData;
  s: WideString;
  c: TClientLookupCol;
begin
  if TClientManagerReport(Sender).CM.vtClients.TotalCount = 0 then exit;
  MaxN := 0;
  MaxA := 0;
  MaxS := 0;
  with TClientManagerReport(Sender) do
  begin
    TotalW := RenderEngine.GetPrintableWidth;
    aNode := nil;
    for i := 0 to Pred(CM.vtClients.TotalCount) do
    begin
      if Assigned(aNode) then
        aNode := CM.vtClients.GetNext(aNode)
      else
        aNode := CM.vtClients.GetFirst;
      if Assigned(aNode) then
      begin
        NodeData := CM.vtClients.GetNodeData(aNode);
        if NodeData.tdNodeType = ntClient then
        begin
          for j := 0 to Pred(CM.ColumnCount) do
          begin
            c := CM.GetColumnIDByPosition(j);
            if not CM.GetColumnVisibility(c) then Continue;
            CM.vtClientsGetTextEx(CM.vtClients, aNode, j, ttNormal, c, true, s);
            if c = cluName then
              MaxN := Max(MaxN, RenderEngine.GetTextLength(s))
            else if c = cluAction then
              MaxA := Max(MaxA, RenderEngine.GetTextLength(s))
            else if c = cluStatus then
              MaxS := Max(MaxS, RenderEngine.GetTextLength(s))
          end;
        end;
      end;
      NameW := MaxN + 10;
      ActionW := MaxA + 10;
      StatusW := MaxS + 10;
    end;
  end;
end;

procedure ListCMDetail(Sender:TObject);
var
  i, j : integer;
  aNode : pVirtualNode;
  NodeData : pTreeData;
  s: WideString;
  ExtraLines: TStringList;
  c: TClientLookupCol;
begin
  if TClientManagerReport(Sender).CM.vtClients.TotalCount = 0 then exit;
  ExtraLines := TStringList.Create;
  try
    with TClientManagerReport(Sender) do
    begin
      aNode := nil;
      for i := 0 to Pred(CM.vtClients.TotalCount) do
      begin
        if Assigned(aNode) then
          aNode := CM.vtClients.GetNext(aNode)
        else
          aNode := CM.vtClients.GetFirst;
        if Assigned(aNode) then
        begin
          NodeData := CM.vtClients.GetNodeData(aNode);
          if NodeData.tdNodeType = ntClient then
          begin
            for j := 0 to Pred(CM.ColumnCount) do
            begin
              c := CM.GetColumnIDByPosition(j);
              if not CM.GetColumnVisibility(c) then
                 Continue;
              CM.vtClientsGetTextEx(CM.vtClients, aNode, j, ttNormal, c, true, s);
              if c = cluAction then
                WrapText(CurrDetail.Count, s, ExtraLines) // wrap action
              else
                PutString(s);
            end; // for
            RenderDetailLine(False);
            while ExtraLines.Count > 0 do
            begin
              for j := 0 to Pred(CM.ColumnCount) do
              begin
                c := CM.GetColumnIDByPosition(j);
                if not CM.GetColumnVisibility(c) then
                   Continue;
                if c = cluAction then begin
                   PutString(ExtraLines[0]);
                   ExtraLines.Delete(0);
                end else
                   SkipColumn;
              end; // for
              RenderDetailLine(False);
            end; // while
            NewDetail;
          end // ntClient
          else // ntGroup
          begin
            RenderTextLine('');
            CM.vtClientsGetText(CM.vtClients, aNode, Ord(cluCode), ttNormal, s);
            RenderTitleLine(s);
          end; // ntGroup
        end; // asigned(aNode)
      end; // for
    end; // with
  finally
    ExtraLines.Free;
  end; // try
end;



procedure DoClientManagerReport(Dest : TReportDest; CM: TfmeClientLookup; Title: string);
const
  // variable column min widths
  NAME_MIN = 7;
  ACTION_MIN = 7;
  STATUS_MIN = 10;
var
   Job : TClientManagerReport;
   c: TClientLookupCol;
   left: Double;
   ActionVisible, NameVisible, StatusVisible, AssignedVisible, ShowLegend: Boolean;
   Btn, i, spare, CodeWidth, NameWidth, ProcessingWidth, ActionWidth, ReminderDateWidth,
   StatusWidth, AssignedToWidth, ReportingPeriodWidth, SendByWidth,
   AccessWidth, GroupWidth, ClientTypeWidth, GSTDueWidth: Integer;
   Col: TReportColumn;
   F: TFont;
begin
   ShowLegend := False;
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
         if SimpleSelectReportDest(Report_List_Names[REPORT_CLIENTMANAGER], Btn, 0) then
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

      CodeWidth := 7; // min
      NameWidth := NAME_MIN;
      ProcessingWidth := 9; // min
      ActionWidth := ACTION_MIN;
      ReminderDateWidth := 4; // min
      StatusWidth := STATUS_MIN;
      AssignedToWidth := 8;
      ReportingPeriodWidth := 14; // min
      SendByWidth := 7; // min
      AccessWidth := 5; // min
      GroupWidth := 5; // min
      ClientTypeWidth := 6; // min
      GSTDueWidth := 7;

      Job := TClientManagerReport.Create(ReportTypes.rptOther);
      try
         CreateReportImageList;
         Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_CLIENTMANAGER]);
         Job.UserReportSettings.s7Orientation := BK_LANDSCAPE;
         Job.CM := CM;
         Job.IsAdmin := True;

         // First find out how much space is needed for each column
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
         AddJobHeader(Job,siTitle,REPORT_LIST_NAMES[REPORT_CLIENTMANAGER] + ' as at ' + FormatDateTime('dd/mm/yy', Date),true);
         with AddJobHeader(Job,siSubTitle,Title,true) do begin
            WrapTextOn := True;
         end;
         AddJobHeader(Job,siSubTitle,'',true);
         //Do we have spare space to allocate? Add up the invisible columns
         spare := 0;
         for i := 0 to Pred(CM.ColumnCount) do
         begin
            c := CM.GetColumnIDByPosition(i);
            if CM.GetColumnVisibility(c) then
               Continue;
            case c of
            cluCode: spare := spare + CodeWidth + 1;
            cluName: spare := spare + NameWidth + 1;
            cluProcessing: spare := spare + ProcessingWidth + 1;
            cluNextGSTDue: spare := spare + GSTDueWidth + 1;
            cluAction: spare := spare + ActionWidth + 1;
            cluReminderDate: spare := spare + ReminderDateWidth + 1;
            cluStatus: spare := spare + StatusWidth + 1;
            cluUser: spare := spare + AssignedtoWidth + 1;
            cluReportingPeriod: spare := spare + ReportingPeriodWidth + 1;
            cluSendBy: spare := spare + SendByWidth + 1;
            cluLastAccessed : spare := spare + AccessWidth + 1;
            cluGroup : spare := spare + GroupWidth + 1;
            cluClientType : spare := spare + ClientTypeWidth + 1;
            end;
         end;

         if spare > 0 then // allocate the spare space to the stretchable columns
         begin
            ActionVisible := CM.GetColumnVisibility(cluAction);
            NameVisible := CM.GetColumnVisibility(cluName);
            StatusVisible := CM.GetColumnVisibility(cluStatus);
            AssignedVisible := CM.GetColumnVisibility(cluUser);

            if ActionVisible then
            begin
               if NameVisible or StatusVisible or AssignedVisible then
               begin
                  ActionWidth := ActionWidth + (spare div 2);
                  spare := spare div 2;
               end
               else
               begin
                  Actionwidth := ActionWidth + spare;
                  spare := 0;
               end;
               if Round((Job.TotalW * ActionWidth)/100) > Job.ActionW then
                  ActionWidth := Round((Job.ActionW * 100) / Job.TotalW);
               if ActionWidth < ACTION_MIN then
                  ActionWidth := ACTION_MIN;
            end;

            if NameVisible then
            begin
               if StatusVisible and AssignedVisible then
               begin
                  NameWidth := NameWidth + (spare div 3);
                  spare := spare - (spare div 3);
               end
               else if StatusVisible or AssignedVisible then
               begin
                  NameWidth := NameWidth + (spare div 2);
                  spare := spare div 2;
               end
               else
               begin
                  NameWidth := NameWidth + spare;
                  spare := 0;
               end;

               if Round((Job.TotalW * NameWidth)/100) > Job.NameW then
                  NameWidth := Round((Job.NameW * 100) / Job.TotalW);
               if NameWidth < NAME_MIN then
                  NameWidth := NAME_MIN;
            end;

            if StatusVisible then
            begin
               if AssignedVisible then
               begin
                  StatusWidth := StatusWidth + (spare div 2);
                  spare := spare div 2;
               end
               else
               begin
                  StatusWidth := StatusWidth + spare;
                  spare := 0;
               end;
               if Round((Job.TotalW * StatusWidth)/100) > Job.StatusW then
                  StatusWidth := Round((Job.StatusW * 100) / Job.TotalW);
               if StatusWidth < STATUS_MIN then
                  StatusWidth := STATUS_MIN;
            end;

            if AssignedVisible then
               AssignedToWidth := AssignedToWidth + spare;
         end;

         //Build the columns
         left := gCleft;
         for i := 0 to Pred(CM.ColumnCount) do begin
            c := CM.GetColumnIDByPosition(i);
            if not CM.GetColumnVisibility(c) then
               Continue;
            case c of
        cluCode:
          begin
            AddColAuto(Job,left,CodeWidth,GcGap,CM.GetColumnCaption(c), jtLeft); // fixed width - minimum
          end;
        cluName:
          begin
            AddColAuto(Job,left,NameWidth,GcGap,CM.GetColumnCaption(c), jtLeft);
          end;
        cluProcessing:
          begin
            Col := AddColAuto(Job,left,ProcessingWidth,GcGap,CM.GetColumnCaption(c), jtLeft); // fixed width - minimum
            F := TFont.Create;
            Job.ReportStyle.Items[siDetail].AssignTo(F);
            F.Name := 'Courier New'; // Need a fixed width font...
            Col.CustomFont := F;
            ShowLegend := True;
          end;
        cluNextGSTDue:
          begin
            AddColAuto(Job, left, GSTDueWidth, GcGap, CM.GetColumnCaption(c), jtLeft);
          end;
        cluAction:
          begin
            AddColAuto(Job,left,ActionWidth,GcGap,CM.GetColumnCaption(c), jtLeft);
          end;
        cluReminderDate:
          begin
            AddColAuto(Job,left,ReminderDateWidth,GcGap,'Remind', jtLeft); // fixed width - minimum
          end;
        cluStatus:
          begin
            AddColAuto(Job,left,StatusWidth,GcGap,CM.GetColumnCaption(c), jtLeft);
          end;
        cluUser:
          begin
            AddColAuto(Job,left,AssignedToWidth,GcGap,CM.GetColumnCaption(c), jtLeft);
          end;
        cluGroup:
          begin
            AddColAuto(Job,left,GroupWidth,GcGap,CM.GetColumnCaption(c), jtLeft);
          end;
        cluClientType:
          begin
            AddColAuto(Job,left,ClientTypeWidth,GcGap,CM.GetColumnCaption(c), jtLeft);
          end;
        cluReportingPeriod:
          begin
            AddColAuto(Job,left,ReportingPeriodWidth,GcGap,CM.GetColumnCaption(c), jtLeft); // fixed width - minimum
          end;
        cluSendBy:
          begin
            AddColAuto(Job,left,SendByWidth,GcGap,CM.GetColumnCaption(c), jtLeft); // fixed width - minimum
          end;
        cluLastAccessed:
          begin
            AddColAuto(Job,left,AccessWidth,GcGap,'Accessed', jtLeft); // fixed width - minimum
          end;
          end;
        end;


        //Add Footers
        if ShowLegend then begin
           AddJobFooter(Job,siFootNote,      'Legend:      ' +
              bkBranding.TextNoData +       ' No Data      ' +
              bkBranding.TextDownloaded + ' Available      '     +
              bkBranding.TextUncoded +      ' Uncoded      ' +
              bkBranding.TextCoded +          ' Coded      ' +
              bkBranding.TextFinalised +  ' Finalised      ' +
              bkBranding.TextTransferred + ' Transferred'
                 ,True);
           AddJobFooter(Job,siFootNote,'',True);
        end;
        AddCommonFooter(Job);

        Job.OnBKPrint := ListCMDetail;
        Job.Generate(Dest);

      finally
         DestroyReportImageList;
         Job.Free;
      end;
      Dest := rdAsk;
   until False;
end;

end.
