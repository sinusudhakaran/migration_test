// Make a report that shows what is currently visible in the client home page
unit rptHome;

interface

uses ReportDefs, ClientHomePageItems;

procedure DoHomeReport(Dest : TReportDest; Home: TCHPBaseList);

implementation

uses
  ReportTypes,
  Rptparams, Classes, sysUtils, Windows, NewReportObj, Globals, NewReportUtils, RepCols,
  VirtualTrees, InfoMoreFrm, ShellAPI, PrintDestDlg, bkConst, UserReportSettings,
  Graphics, VirtualTreeHandler, Math, bkBranding;

type
  THomeReport = class(TBKReport)
  public
    Home: TCHPBaseList;
    NameW, TotalW: Integer;
  end;

procedure GetMaxWidths(Sender:TObject);
var
  i, MaxN : integer;
  aNode : pVirtualNode;
  NodeData : TTreeBaseItem;
  s: WideString;
begin
  if THomeReport(Sender).Home.Count = 0 then exit;
  MaxN := 0;
  with THomeReport(Sender) do
  begin
    TotalW := RenderEngine.GetPrintableWidth;
    NameW := 30;
    aNode := nil;
    for i := 0 to Pred(Home.Count) do
    begin
      if Assigned(aNode) then
        aNode := Home.Tree.GetNext(aNode)
      else
        aNode := Home.Tree.GetFirst;
      if Assigned(aNode) then
      begin
        NodeData := Home.GetNodeItem(aNode);
        if NodeData is TCHEmptyJournal then
          s := TCHEmptyJournal(NodeData).GetTagText(CHPT_Text)
        else if NodeData is TCHJournalItem then
          s := TCHJournalItem(NodeData).GetTagText(CHPT_Text)
        else if NodeData is TCHAccountItem then
          s := TCHAccountItem(NodeData).GetTagText(CHPT_Text)
        else if NodeData is TCHBASPeriodItem then
          s := TCHBASPeriodItem(NodeData).GetTagText(CHPT_Text)
        else if NodeData is TCHGSTPeriodItem then
          s := TCHGSTPeriodItem(NodeData).GetTagText(CHPT_Text)
        else if NodeData is TCHForeignItem then
          s := TCHForeignItem(NodeData).GetTagText(CHPT_Text);
             
        MaxN := Max(MaxN, RenderEngine.GetTextLength(s));
      end;
      NameW := MaxN + 20;
    end;
  end;
end;

procedure ListHomeDetail(Sender:TObject);
var
  i, j : integer;
  aNode : pVirtualNode;
  NodeData : TTreeBaseItem;
  IsGroup, LinesPrinted: Boolean;
  s, c: string;
  Lines, Split: TStringList;
begin
  if THomeReport(Sender).Home.Count = 0 then
     exit; // nothing to do...
  with THomeReport(Sender) do begin
     aNode := nil;
     for i := 0 to Pred(Home.Count) do begin
        IsGroup := False;
        if Assigned(aNode) then
          aNode := Home.Tree.GetNext(aNode)
        else
           aNode := Home.Tree.GetFirst;
        if Assigned(aNode) then begin
           NodeData := Home.GetNodeItem(aNode);
           if NodeData is TCHEmptyJournal then begin
              // Just a 'Place holder for Journal
              PutString(TCHEmptyJournal(NodeData).GetTagText(CHPT_Text));
              PutString('------------');
              SkipColumn;
              SkipColumn;
           end else if NodeData is TCHJournalItem then begin
              // Journal with data
              PutString(TCHJournalItem(NodeData).GetTagText(CHPT_Text));
              PutString(TCHJournalItem(NodeData).GetTagText(CHPT_Report_Processing));
              PutString(TCHAccountItem(NodeData).GetTagText(CHPT_Period));
              SkipColumn;
           end else if NodeData is TCHAccountItem then begin
              //Bank account
              PutString(TCHAccountItem(NodeData).GetTagText(CHPT_Text));
              PutString(TCHAccountItem(NodeData).GetTagText(CHPT_Report_Processing));
              PutString(TCHAccountItem(NodeData).GetTagText(CHPT_Period));
              PutString(TCHAccountItem(NodeData).GetTagText(CHPT_Balance));
           end else if NodeData is TCHBASPeriodItem then begin
              // Bas period
              PutString(TCHBASPeriodItem(NodeData).GetTagText(CHPT_Text));
              PutString(TCHBASPeriodItem(NodeData).GetTagText(CHPT_Report_Processing));
              SkipColumn;
              SkipColumn;
           end else if NodeData is TCHGSTPeriodItem then begin
              PutString(TCHGSTPeriodItem(NodeData).GetTagText(CHPT_Text));
              PutString(TCHGSTPeriodItem(NodeData).GetTagText(CHPT_Report_Processing));
              SkipColumn;
              SkipColumn;
           end else if NodeData is TCHForeignItem then begin
              // Foreign Exchange
              PutString(TCHForeignItem(NodeData).GetTagText(CHPT_Text));
              PutString(TCHForeignItem(NodeData).GetTagText(CHPT_Report_Processing));
              PutString(TCHForeignItem(NodeData).GetTagText(CHPT_Period));
              SkipColumn;
           end else if NodeData is TCHYearItem then
              // not currently showing (Used for the header)
              IsGroup := True
           else begin
              RenderTitleLine(NodeData.Title);
              IsGroup := True;
           end;
           if not IsGroup then
              RenderDetailLine;
        end; // asigned(aNode)
    end; // for
    // Add notes
    Lines := TStringList.Create;
    Split := TStringList.Create;
    try
      for i := Low(MyClient.clFields.clNotes) to High(MyClient.clFields.clNotes) do
        s := s + MyClient.clFields.clNotes[i];
      Lines.Text := s;
      RenderTextLine('');
      if s <> '' then
        RenderTitleLine('Notes');
      for i := 0 to Pred(Lines.Count) do
      begin
        s := Lines[i];
        if RenderEngine.GetTextLength(s) > TotalW then
        begin
          c := '';
          LinesPrinted := False;
          while RenderEngine.GetTextLength(s) > TotalW do
          begin
            c := Copy(s, Length(s), 1) + c;
            s := Copy(s, 1, Length(s) - 1);
            if RenderEngine.GetTextLength(s) <= TotalW then
            begin
              // go back to the last word
              j := Length(s);
              while Length(s) > 0 do
              begin
                if s[j] = ' ' then
                begin
                  RenderTextLine(s);
                  LinesPrinted := True;
                  s := c;
                  c := '';
                  Break;
                end
                else
                begin
                  c := Copy(s, Length(s), 1) + c;
                  s := Copy(s, 1, Length(s) - 1);
                end;
                Dec(j);
              end;
              if not LinesPrinted then
                RenderTextLine(c);
            end;
          end;
          RenderTextLine(s);
        end
        else
          RenderTextLine(s);
      end;
    finally
      Lines.Free;
      Split.Free;
    end;
  end; // with
end;

procedure DoHomeReport(Dest : TReportDest; Home: TCHPBaseList);
var
   Job : THomeReport;
   NameWidth, btn: Integer;
   Left: Double;
   Col: TReportColumn;
   F: TFont;
   lParams: TRptParameters;
begin
   if not AreThereAnyPrinters then
   begin
     HelpfulInfoMsg('You must setup a Windows Printer before running any Reports.  '+
                    SHORTAPPNAME+' will now take you to the Windows Printers Folder.  '+
                    'You can then select Add Printer to add a printer for windows to use.',0);
     ShellExecute(0, 'open', 'control.exe', 'printers', nil, SW_NORMAL);
     exit;
   end;

   lParams := TRptParameters.Create(ord(REPORT_CLIENTHOME),MyClient,nil);

   try repeat
      if Dest = rdAsk then
         if SimpleSelectReportDest(Report_List_Names[REPORT_CLIENTHOME], btn, 0) then
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

      Job := THomeReport.Create(ReportTypes.rptOther);
      try
         Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_CLIENTHOME]);
         Job.Home := Home;
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


         NameWidth := Round((Job.NameW * 100) / Job.TotalW);
         if NameWidth > 50 then // always leave room for the other columns
            NameWidth := 50;

         //Add Headers
         AddCommonHeader(Job);
         AddJobHeader(Job,siTitle,REPORT_LIST_NAMES[REPORT_CLIENTHOME] + ' as at ' + FormatDateTime('dd/mm/yy', Date),true);
         AddJobHeader(Job,siSubTitle,'',true);

         //Add columns
         Left := GcLeft;
         AddColAuto(Job,Left,NameWidth,GcGap,Home.Tree.Header.Columns[0].Text, jtLeft);
         Col := AddColAuto(Job,Left,15,GcGap,Home.DateRangeStr, jtLeft);

         F := TFont.Create;
         Job.ReportStyle.Items[siDetail].AssignTo(F);
         F.Name := 'Courier New'; // Need a fixed width font...
         Col.CustomFont := F;

         AddColAuto(Job,Left,15,GcGap,Home.Tree.Header.Columns[2].Text, jtLeft);
         AddColAuto(Job,Left,15,Gcgap,Home.Tree.Header.Columns[3].Text, jtLeft);


         //Add Footers
         AddJobFooter(Job,siFootnote,    'Legend:      ' +
            bkBranding.TextNoData +      ' No Data      ' +
            bkBranding.TextUncoded +     ' Uncoded      ' +
            bkBranding.TextCoded +       ' Coded      ' +
            bkBranding.TextFinalised +   ' Finalised      ' +
            bkBranding.TextTransferred + ' Transferred      ' +
            bkBranding.TextDownloaded +  ' Downloaded', True);
         AddJobFooter(Job,siFootnote,'',True);
         AddCommonFooter(Job);

         Job.OnBKPrint := ListHomeDetail;
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
