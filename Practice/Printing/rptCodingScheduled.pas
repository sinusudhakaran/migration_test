unit rptCodingScheduled;
//------------------------------------------------------------------------------
{
   Title:       Coding Report for Schedule Reports

   Description: Produces same format output to standard coding report, however
                there are numerous differences in how it works

   Remarks:     Only bank accounts which can be found in the admin system are
                included in this report.

                Only bank accounts with transactions are printed

                The report adds records to a SummaryReportList which is
                used to print the Scheduled Reports Summary.  This list is
                accessed thru the TSchReportOptions type.

                The accounts and entries are traversed before actually printing
                them so that we can determine which accounts will be printed.
                The Summary List is populated at this time.



   Author:      modified - Matthew Hopkins Nov 2000

   Last Reviewed: 20 May 2003 by MH

}
//------------------------------------------------------------------------------
interface
uses
   ReportDefs, PrintMgrObj, Scheduled, FaxParametersObj, SchedRepUtils,
   NewReportObj, RepCols, BAObj32, CodingRepDlg, Classes, SysUtils, TravList,
   BKReportColumnManager;

type
   TScheduledCodingReport = class(TBKReport)
   private
     D1,D2,D3           : integer;
     ColAmt,Col1,Col2   : TReportColumn;
     Style,
     SortMethod,
     Include,
     LeaveLines         : byte;
     RuleLine           : boolean;
     ScheduledRptParams : TSchReportOptions;  //provides access to SummaryList and PrintAll
     SentTo             : TReportDest;
     PrintingEntry : Boolean;
     CurrentBankAccount : TBank_Account;
     AccountTitle : Boolean;
     WrapNarration: Boolean;
     FirstAccountPrinted: Boolean;
     NarrationColIdx, NotesColIdx: Integer;
     FSettings: TCodingReportSettings;
   protected
      procedure PutNotes( Notes : string);
      procedure PutNarrationNotes(Narration, Notes : string);
      function SplitLine(ColIdx: Integer; var TextList: TStringList) : Integer;
   public
      procedure BKPrint;  override;
      procedure AfterNewPage(DetailPending : Boolean);  override;
      property ReportSettings: TCodingReportSettings read FSettings;
   end;

   TTravManagerForVerify = class(TTravManager)
   public
      FirstEntryDate  : integer;
      LastEntryDate   : integer;
      AccountsPrinted : integer;
      AccountsFound   : integer;
      ScheduledRptParams     : TSchReportOptions; //provides access to SummaryList and PrintAll
      FirstSummaryInfoRec : pSchdRepSummaryRec;
      ReportJob         : TBKReport;
   end;

function DoScheduledCodingReport( Destination : TReportDest;
                                   SrOptions   : TSchReportOptions;
                                   Settings    : TPrintManagerObj;
                                   FaxParams : TFaxParameters = nil) : boolean;

//******************************************************************************
implementation

uses
  TransactionUtils,
  ReportTypes,
  RptParams,
  Graphics,
  Types,
  bkdefs,
  globals,
  bkconst,
  ovcDate,
  stDateSt,
  moneydef,
  bkDateUtils,
  GenUtils,
  infoMoreFrm,
  AutoCode32,
  NewReportUtils,
  sydefs,
  ClientUtils,
  ToDoHandler,
  Admin32,
  RenderEngineObj,
  RptCoding,
  bkProduct;

const
  TaxInvBoxEmpty = '[  ]';
  TaxInvBoxTicked = '[x]';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_EnterAccount(Sender : TObject);
var
  Mgr : TTravManagerWithNewReport;
  Rpt : TScheduledCodingReport;
  s : string;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TScheduledCodingReport( Mgr.ReportJob );

   With MyClient, MyClient.clFields, Mgr, Rpt, Mgr.ReportJob, Mgr.Bank_Account do
   Begin
      //exit if dont need to print this account
      if (not baFields.baTemp_Include_In_Scheduled_Coding_Report) or
         (Pos(baFields.baBank_Account_Number + ',', clExclude_From_Scheduled_Reports) > 0) then exit;

      If (NumOfAccounts > 0) and TScheduledCodingReport(Mgr.ReportJob).FirstAccountPrinted then
      Begin
         If (ReportTypeParams.NewPageforAccounts) then
          ReportNewPage
         else
         begin
          RenderTextLine('');
          RenderTextLine('');
         end;                                         
      end;
      TScheduledCodingReport(Mgr.ReportJob).FirstAccountPrinted := True;
      if (not TScheduledCodingReport(Mgr.ReportJob).AccountTitle) then
      begin
        S := baFields.baBank_Account_Number + ' : '+AccountName;
        RenderTitleLine(S);
        TScheduledCodingReport(Mgr.ReportJob).AccountTitle := True;
      end;

      // Set the currency symbol
      if Assigned(Col1) then
        Col1.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;
      if Assigned(Col2) then
        Col2.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;
      if Assigned(ColAmt) then
        ColAmt.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;

      CRTotal := 0;
      DRTotal := 0;
   end;
   TScheduledCodingReport(Mgr.ReportJob).CurrentBankAccount := Mgr.Bank_Account;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_ExitAccount(Sender : TObject);
//on exit bank account
var
  Mgr : TTravManagerWithNewReport;
  Rpt : TScheduledCodingReport;
  NettTotal : Currency;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TScheduledCodingReport( Mgr.ReportJob );

   With MyClient, MyClient.clFields, Mgr, Rpt, Mgr.ReportJob, Mgr.Bank_Account do
   Begin
      //exit if dont need to print this account
      if (not baFields.baTemp_Include_In_Scheduled_Coding_Report) or
         (Pos(baFields.baBank_Account_Number + ',', clExclude_From_Scheduled_Reports) > 0) then exit;

      if clScheduled_Coding_Report_Rule_Line then
        RenderRuledLine;

      // Set the currency symbol
      if Assigned(ColAmt) then
        ColAmt.TotalFormat := Mgr.Bank_Account.FmtMoneyStrBrackets;

      RenderDetailSubTotal('');
      If clScheduled_Coding_Report_Style in [ rsTwoColumn, rsTwoColumnWithNotes] then
      Begin
         NettTotal := DRTotal + CRTotal;
         If NettTotal > 0 then
            C1.SubTotal := NettTotal/100
         else
            C2.SubTotal := NettTotal/100;
         RenderDetailSubTotal('');
      end;
      TScheduledCodingReport(Mgr.ReportJob).CurrentBankAccount := nil;
      TScheduledCodingReport(Mgr.ReportJob).AccountTitle := False;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_EnterDissect(Sender : Tobject);
var
  Mgr : TTravManagerWithNewReport;
  i, NotesLines, NarrationLines, SpaceForRuledLines : integer;
  entry: TStringList;
  NotesCol, NarrationCol: Integer;
  lNotes: string;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   With MyClient, MyClient.clFields, Mgr, Mgr.ReportJob, Mgr.Bank_Account, Mgr.Transaction^, Mgr.Dissection^ do
   Begin
      //exit if dont need to print this account
      if (not baFields.baTemp_Include_In_Scheduled_Coding_Report) or
         (Pos(baFields.baBank_Account_Number + ',', clExclude_From_Scheduled_Reports) > 0) then exit;

      //check that transaction should be included
      if not ((( txDate_Effective > baFields.baTemp_Date_Of_Last_Trx_Printed) and (not IsUPCFromPreviousMonth(txDate_Effective, txUPI_State, TScheduledCodingReport(Mgr.ReportJob).D3)))
               or ( TScheduledCodingReport( Mgr.ReportJob).ScheduledRptParams.srPrintAllForThisClient)) then begin
         exit;
      end;

      TScheduledCodingReport(Mgr.ReportJob).PrintingEntry := False;
      if clScheduled_Coding_Report_Rule_Line then
      begin
        if (clScheduled_Coding_Report_Sort_Order = csAccountCode) or
           (IsAJournalAccount) then
          RenderRuledLine
        else
          RenderRuledLine(psDot);
      end;

      //update temp value which will be used later to update admin system
      if txDate_Effective > baFields.baTemp_New_Date_Last_Trx_Printed then
         baFields.baTemp_New_Date_Last_Trx_Printed := txDate_Effective;

     // Do not allow spanning pages in dissections - if not enough room then start new page (#1733)
     NotesCol := TScheduledCodingReport(Mgr.ReportJob).NotesColIdx;
     NarrationCol := TScheduledCodingReport(Mgr.ReportJob).NarrationColIdx;
     entry := TStringList.Create;
     try
       lNotes := GetFullNotes(Mgr.Dissection);
       if (LNotes <> '')
       and (NotesCol > -1)
       and ((clCoding_Report_Style = rsTwoColumnWithNotes)
            or (clCoding_Report_Style = rsStandardWithNotes)) then begin
          entry.Text := LNotes;
          NotesLines := TScheduledCodingReport(Mgr.ReportJob).SplitLine(NotesCol, entry);
       end else
          NotesLines := 0;

       if (dsGL_Narration <> '') and (NarrationCol > -1)  then
       begin
         entry.Text := dsGL_Narration;
         NarrationLines := TScheduledCodingReport(Mgr.ReportJob).SplitLine(NarrationCol, entry);
       end
       else
         NarrationLines := 0;
       if (NarrationLines > 0) or (NotesLines > 0) then
       begin
         if clCoding_Report_Rule_Line then
           SpaceForRuledLines := clCoding_Report_Blank_Lines + 1
         else
           SpaceForRuledLines := clCoding_Report_Blank_Lines;
         if NotesLines > NarrationLines then
           RequireLines(NotesLines + SpaceForRuledLines)
         else
           RequireLines(NarrationLines + SpaceForRuledLines);
       end;
     finally
       entry.Free;
     end;

      Case clScheduled_Coding_Report_Style of
         rsStandard, rsStandardWithNotes :
            Case clCountry of
               whNewZealand :
                  Begin
                     PutString( bkDate2Str( txDate_Effective ) );
                     SkipColumn;
                     PutString(' /'+inttostr(dsSequence_No));
                     SkipColumn;
                     PutString( dsAccount );

                     if SortType = csAccountCode then
                       PutMoney( dsAmount)
                     else
                       PutMoneyDontAdd( dsAmount );

                      if clScheduled_Coding_Report_Print_TI then
                      begin
                        if txTax_Invoice_Available then
                          PutString( TaxInvBoxTicked)
                        else
                          PutString( TaxInvBoxEmpty);
                      end;

                     if clScheduled_Coding_Report_Show_OP then
                        SkipColumn;

                    if clScheduled_Coding_Report_Style = rsStandardWithNotes then
                      TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(dsGL_Narration, GetFullNotes(Mgr.Dissection))
                    else
                      TScheduledCodingReport( Mgr.ReportJob).PutNotes( dsGL_Narration);
                  end;
               whAustralia,
               whUK :
                  Begin
                     PutString( bkDate2Str( txDate_Effective ) );
                     PutString(' /'+inttostr(dsSequence_No));
                     PutString( dsAccount );

                     if SortType = csAccountCode then
                       PutMoney( dsAmount)
                     else
                       PutMoneyDontAdd( dsAmount );

                     if clScheduled_Coding_Report_Print_TI then begin
                       if txTax_Invoice_Available then
                         PutString( TaxInvBoxTicked)
                       else
                         PutString( TaxInvBoxEmpty);

                       if dsGST_Amount <> 0 then
                         PutMoney( dsGST_Amount)
                       else
                         SkipColumn;
                     end;

                    if clScheduled_Coding_Report_Style = rsStandardWithNotes then
                      TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(dsGL_Narration,GetFullNotes(Mgr.Dissection))
                    else
                      TScheduledCodingReport( Mgr.ReportJob).PutNotes( dsGL_Narration);
                  end;
            end; { of Case clCountry }
         rsTwoColumn, rsTwoColumnWithNotes :
            Case clCountry of
               whNewZealand :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));
                     SkipColumn;
                     PutString(' /'+inttostr(dsSequence_No));
                     SkipColumn;
                     PutString( dsAccount );
                     If dsAmount >= 0 then
                     Begin
                        if SortType = csAccountCode then
                          PutMoney( dsAmount)
                        else
                          PutMoneyDontAdd( dsAmount );
                        SkipColumn;
                     end
                     else
                     Begin
                        SkipColumn;
                        if SortType = csAccountCode then
                          PutMoney( dsAmount)
                        else
                          PutMoneyDontAdd( dsAmount );
                     end;
                     if clScheduled_Coding_Report_Print_TI then
                     begin
                       if txTax_Invoice_Available then
                         PutString( TaxInvBoxTicked)
                       else
                         PutString( TaxInvBoxEmpty);
                     end;
                     if clScheduled_Coding_Report_Show_OP then
                        SkipColumn;

                    if clScheduled_Coding_Report_Style = rsTwoColumnWithNotes then
                      TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(dsGL_Narration, GetFullNotes(Mgr.Dissection))
                    else
                      TScheduledCodingReport( Mgr.ReportJob).PutNotes( dsGL_Narration);
                  end;
               whAustralia,
               whUK :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));
                     PutString(' /'+inttostr(dsSequence_No));
                     PutString( dsAccount );
                     If dsAmount >= 0 then
                     Begin
                        if SortType = csAccountCode then
                          PutMoney( dsAmount)
                        else
                           PutMoneyDontAdd( dsAmount );
                        SkipColumn;
                     end
                     else
                     Begin
                        SkipColumn;
                        if SortType = csAccountCode then
                          PutMoney( dsAmount)
                        else
                          PutMoneyDontAdd( dsAmount );
                     end;

                     if clScheduled_Coding_Report_Print_TI then begin
                       if txTax_Invoice_Available then
                         PutString( TaxInvBoxTicked)
                       else
                         PutString( TaxInvBoxEmpty);

                       if dsGST_Amount <> 0 then
                         PutMoney( dsGST_Amount)
                       else
                         SkipColumn;
                     end;

                    if clScheduled_Coding_Report_Style = rsTwoColumnWithNotes then
                      TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(dsGL_Narration, GetFullNotes(Mgr.Dissection))
                    else
                      TScheduledCodingReport( Mgr.ReportJob).PutNotes( dsGL_Narration);
                  end;
            end; { of Case clCountry }
         rsCustom:
            TScheduledCodingReport(Mgr.ReportJob).FSettings.ColManager.OutputColumns(Mgr.ReportJob, Mgr);
      end; { of Case clScheduled_Coding_Report_Style }
      RenderDetailLine;

      for i := 1 to clScheduled_Coding_Report_Blank_Lines do RenderTextLine( '');

      //need to add the amounts here if sort order is by account because
      //enter entry routine not called for dissection entries if sort order
      //is csAccountCode
      if SortType = csAccountCode then begin
        if dsAmount >=0 then
           DRTotal := DRTotal + dsAmount
        else
           CRTotal := CRTotal + dsAmount;
      end;
   end; {with}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_EnterEntry(Sender: TObject);
var
  Mgr : TTravManagerWithNewReport;
  i, NotesLines, NarrationLines, SpaceForRuledLines : integer;
  entry: TStringList;
  NotesCol, NarrationCol: Integer;
  lNotes: string;
  Params: TCodingReportSettings;
begin
   Params := TCodingReportSettings.Create(ord(REPORT_CODING), MyClient, nil);
   Mgr := TTravManagerWithNewReport(Sender);
   With MyClient, MyClient.clFields, Mgr, Mgr.ReportJob, Mgr.Bank_Account, Mgr.Transaction^ do
   Begin
      //exit if dont need to print this account
      if (not baFields.baTemp_Include_In_Scheduled_Coding_Report) or
         (Pos(baFields.baBank_Account_Number + ',', clExclude_From_Scheduled_Reports) > 0) then exit;

      //check that transaction should be included
      if not ((( txDate_Effective > baFields.baTemp_Date_Of_Last_Trx_Printed) and (not IsUPCFromPreviousMonth(txDate_Effective, txUPI_State, TScheduledCodingReport(Mgr.ReportJob).D3)))
               or ( TScheduledCodingReport( Mgr.ReportJob).ScheduledRptParams.srPrintAllForThisClient)) then begin
         exit;
      end;
     TScheduledCodingReport(Mgr.ReportJob).PrintingEntry := True;
     If clScheduled_Coding_Report_Rule_Line then RenderRuledLine;

     if clScheduled_Coding_Report_Rule_Line then
       RequireLines(clScheduled_Coding_Report_Blank_Lines+2)
     else
       RequireLines(clScheduled_Coding_Report_Blank_Lines+1);

     // Do not allow spanning pages - if not enough room then start new page (#1733)
     entry := TStringList.Create;
     NotesCol := TScheduledCodingReport(Mgr.ReportJob).NotesColIdx;
     NarrationCol := TScheduledCodingReport(Mgr.ReportJob).NarrationColIdx;
     try
        lnotes := GetFullNotes(Mgr.Transaction);
        if (lNotes <> '')
        and (NotesCol > -1)
        and ((clCoding_Report_Style = rsTwoColumnWithNotes)
             or (clCoding_Report_Style = rsStandardWithNotes)) then begin
           entry.Text := lNotes;
           NotesLines := TScheduledCodingReport(Mgr.ReportJob).SplitLine(NotesCol, entry);
        end else
           NotesLines := 0;

       if (txGL_Narration <> '') and (NarrationCol > -1) then
       begin
         entry.Text := txGL_Narration;
         NarrationLines := TScheduledCodingReport(Mgr.ReportJob).SplitLine(NarrationCol, entry);
       end
       else
         NarrationLines := 0;
       if (NarrationLines > 0) or (NotesLines > 0) then
       begin
         if clCoding_Report_Rule_Line then
           SpaceForRuledLines := clCoding_Report_Blank_Lines + 1
         else
           SpaceForRuledLines := clCoding_Report_Blank_Lines;
         if NotesLines > NarrationLines then
           RequireLines(NotesLines + SpaceForRuledLines)
         else
           RequireLines(NarrationLines + SpaceForRuledLines);
       end;
     finally
       entry.Free;
     end;

      //update temp value which will be used later to update admin system
      if txDate_Effective > baFields.baTemp_New_Date_Last_Trx_Printed then
         baFields.baTemp_New_Date_Last_Trx_Printed := txDate_Effective;

      Case clScheduled_Coding_Report_Style of
         rsStandard, rsStandardWithNotes :
            Case clCountry of
               whNewZealand :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));
                     PutInteger(txType);
                     PutString( GetFormattedReference( Mgr.Transaction));
                     PutString(trim(txAnalysis));
                     PutString( txAccount );
                     PutMoney( txAmount );
                     if clScheduled_Coding_Report_Print_TI then
                     begin
                       if txTax_Invoice_Available then
                         PutString( TaxInvBoxTicked)
                       else
                         PutString( TaxInvBoxEmpty);
                     end;

                     if clScheduled_Coding_Report_Show_OP then begin
                        if ReverseFieldOrder then
                        begin
                           PutString(txParticulars);
                           PutString(txOther_Party);
                           if clScheduled_Coding_Report_Style = rsStandardWithNotes then
                             TScheduledCodingReport( Mgr.ReportJob).PutNotes(GetFullNotes(Mgr.Transaction));
                        end
                        else
                        begin
                           PutString(txOther_Party);
                           if clScheduled_Coding_Report_Style = rsStandardWithNotes then
                             TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(txParticulars, GetFullNotes(Mgr.Transaction))
                           else
                             TScheduledCodingReport( Mgr.ReportJob).PutNotes( txParticulars);
                        end;
                     end else
                     begin
                        if clScheduled_Coding_Report_Style = rsStandardWithNotes then
                          TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(txGL_Narration, GetFullNotes(Mgr.Transaction))
                        else
                          TScheduledCodingReport( Mgr.ReportJob).PutNotes( txGL_Narration);
                     end;
                  end;
               whAustralia,
               whUK :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));
                     PutString( GetFormattedReference( Mgr.Transaction));
                     PutString( txAccount );
                     PutMoney( txAmount );

                     if clScheduled_Coding_Report_Print_TI then begin
                        if txTax_Invoice_Available then
                          PutString( TaxInvBoxTicked)
                        else
                          PutString( TaxInvBoxEmpty);

                        if txGST_Amount <> 0 then
                           PutMoney( txGST_Amount)
                        else
                           SkipColumn;
                     end;

                    if clScheduled_Coding_Report_Style = rsStandardWithNotes then
                      TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(txGL_Narration, GetFullNotes(Mgr.Transaction))
                    else
                      TScheduledCodingReport( Mgr.ReportJob).PutNotes( txGL_Narration);
                  end;
            end; { of Case fdCountry }
         rsTwoColumn, rsTwoColumnWithNotes :
            Case clCountry of
               whNewZealand :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));
                     PutInteger(txType);
                     PutString( GetFormattedReference( Mgr.Transaction));
                     PutString(Trim(txAnalysis));
                     PutString( txAccount );
                     If txAmount >= 0 then
                     Begin
                        PutMoney( txAmount );
                        SkipColumn;
                     end
                     else
                     Begin
                        SkipColumn;
                        PutMoney( txAmount );
                     end;
                     if clScheduled_Coding_Report_Print_TI then
                     begin
                       if txTax_Invoice_Available then
                         PutString( TaxInvBoxTicked)
                       else
                         PutString( TaxInvBoxEmpty);
                     end;
                     if clScheduled_Coding_Report_Show_OP then begin
                        if ReverseFieldOrder then
                        begin
                          PutString(txParticulars);
                          PutString(txOther_Party);
                          if clScheduled_Coding_Report_Style = rsTwoColumnWithNotes then
                            TScheduledCodingReport( Mgr.ReportJob).PutNotes(GetFullNotes(Mgr.Transaction));
                        end
                        else
                        begin
                          PutString(txOther_Party);
                          if clScheduled_Coding_Report_Style = rsTwoColumnWithNotes then
                            TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(txParticulars, GetFullNotes(Mgr.Transaction))
                          else
                            TScheduledCodingReport( Mgr.ReportJob).PutNotes( txParticulars);
                        end;
                     end else
                     begin
                       if clScheduled_Coding_Report_Style = rsTwoColumnWithNotes then
                         TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(txGL_Narration, GetFullNotes(Mgr.Transaction))
                       else
                         TScheduledCodingReport( Mgr.ReportJob).PutNotes( txGL_Narration);
                     end;
                  end;
               whAustralia,
               whUK :
                  Begin
                     PutString(bkDate2Str(txDate_Effective));
                     PutString( GetFormattedReference( Mgr.Transaction));
                     PutString( txAccount );
                     If txAmount >= 0 then
                     Begin
                        PutMoney( txAmount );
                        SkipColumn;
                     end
                     else
                     Begin
                        SkipColumn;
                        PutMoney( txAmount );
                     end;

                     if clScheduled_Coding_Report_Print_TI then begin
                        if txTax_Invoice_Available then
                          PutString( TaxInvBoxTicked)
                        else
                          PutString( TaxInvBoxEmpty);

                        if txGST_Amount <> 0 then
                           PutMoney( txGST_Amount)
                        else
                           SkipColumn;
                     end;

                     if clScheduled_Coding_Report_Style = rsTwoColumnWithNotes then
                       TScheduledCodingReport( Mgr.ReportJob).PutNarrationNotes(txGL_Narration, GetFullNotes(Mgr.Transaction))
                     else
                       TScheduledCodingReport( Mgr.ReportJob).PutNotes( txGL_Narration);
                  end;
            end; { of Case fdCountry }
         rsCustom:
            TScheduledCodingReport(Mgr.ReportJob).FSettings.ColManager.OutputColumns(Mgr.ReportJob, Mgr);
      end; { of Case clScheduled_Coding_Report_Style }

      If txAmount >=0 then
         DRTotal := DRTotal + txAmount
      else
         CRTotal := CRTotal + txAmount;

      if Params.RuleLineBetweenColumns then
        RenderAllVerticalColumnLines; //detail line          
      
      RenderDetailLine;
      For i := 1 to clScheduled_Coding_Report_Blank_Lines do RenderTextLine( '');
   end; {with}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CR_ExitEntry(Sender :TObject);
var
   Mgr : TTravManagerWithNewReport;
begin
   Mgr := TTravManagerWithNewReport(Sender);
   With MyClient, MyClient.clFields, Mgr, Mgr.ReportJob, Mgr.Bank_Account do begin
      //exit if dont need to print this account
      if (not baFields.baTemp_Include_In_Scheduled_Coding_Report) or
         (Pos(baFields.baBank_Account_Number + ',', clExclude_From_Scheduled_Reports) > 0) then exit;

      //check that transaction should be included
      if not ((( Mgr.Transaction^.txDate_Effective > baFields.baTemp_Date_Of_Last_Trx_Printed) and
               (not IsUPCFromPreviousMonth(Mgr.Transaction^.txDate_Effective, Mgr.Transaction^.txUPI_State, TScheduledCodingReport(Mgr.ReportJob).D3)))
               or ( TScheduledCodingReport( Mgr.ReportJob).ScheduledRptParams.srPrintAllForThisClient)) then begin
         exit;
      end;
   end;
end;
//------------------------------------------------------------------------------

procedure Verify_EnterAccount( Sender : TObject);
// determine if account can be found in admin system.
// set accumulators that are used for the Summary Report Lines
// set clear temporary flags in the client bank accounts
var
   Mgr : TTravManagerForVerify;
   AdminBA : pSystem_Bank_Account_Rec;
   LastDate: Integer;
begin
   Mgr := TTravManagerForVerify( Sender);

   with Mgr.Bank_Account do begin
      baFields.baTemp_Include_In_Scheduled_Coding_Report := false;
      baFields.baTemp_New_Date_Last_Trx_Printed := 0;  //this value will be written in admin sytem
                                                       //see Scheduled.ProcessClient()
      Mgr.FirstEntryDate := MaxInt;
      Mgr.LastEntryDate  := 0;

      //access the admin system and read date_of_last_transaction_printed.
      AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( baFields.baBank_Account_Number);
      if Assigned( AdminBA) then begin
         Inc( Mgr.AccountsFound);

         if Mgr.ScheduledRptParams.srPrintAllForThisClient then
            //set date so that all transactions will be included
            baFields.baTemp_Date_Of_Last_Trx_Printed := 0
         else
         begin
           LastDate := ClientUtils.GetLastPrintedDate(MyClient.clFields.clCode, AdminBA.sbLRN);
           if LastDate = 0 then
             baFields.baTemp_Date_Of_Last_Trx_Printed := IncDate(Mgr.ScheduledRptParams.srDisplayFromDate, -1, 0, 0)
           else if GetMonthsBetween(LastDate, Mgr.ScheduledRptParams.srDisplayFromDate) > 1 then
             baFields.baTemp_Date_Of_Last_Trx_Printed := IncDate(GetFirstDayOfMonth(IncDate(Mgr.ScheduledRptParams.srDisplayFromDate, 0, -1, 0)), -1, 0, 0)
           else
             baFields.baTemp_Date_Of_Last_Trx_Printed := LastDate;
         end;
      end
      else begin
         //this account does not exist in the admin sytem, set date so that
         //no valid entries will ever be found
         baFields.baTemp_Date_Of_Last_Trx_Printed := MaxInt;
      end;
   end;
end;
//------------------------------------------------------------------------------

procedure Verify_EnterEntry( Sender : TObject);
//need to establish that there are entries to print
//also establish what date range will be printed.  this is for the summary report
//date to compare against will be set to 0 if including all, or Max Int if
//admin account not found.  this is used to determine if some, all, or none of the
//entries are printed.
var
   Mgr : TTravManagerForVerify;

begin
   Mgr := TTravManagerForVerify( Sender);
   With MyClient, MyClient.clFields, Mgr.Bank_Account, Mgr.Transaction^ do begin
      //set true if transaction found
      if ((txDate_Effective > baFields.baTemp_Date_Of_Last_Trx_Printed) and (not IsUPCFromPreviousMonth(txDate_Effective, txUPI_State, TScheduledCodingReport(Mgr.ReportJob).D3))) and
         (Pos(baFields.baBank_Account_Number + ',', clExclude_From_Scheduled_Reports) = 0) then begin
         baFields.baTemp_Include_In_Scheduled_Coding_Report := true;

         if txDate_Effective < Mgr.FirstEntryDate then
            Mgr.FirstEntryDate := txDate_Effective;

         if txDate_Effective > Mgr.LastEntryDate then
            Mgr.LastEntryDate  := txDate_Effective;
      end;
   end;
end;
//------------------------------------------------------------------------------
procedure Verify_ExitAccount( Sender : TObject);
//update the accumulators and add a new summary report record if the current
//accounts will be printed.
var
  Mgr : TTravManagerForVerify;
  NewSummaryRec : pSchdRepSummaryRec;
  i: Integer;
  Duplicate : Boolean;
begin
   Mgr := TTravManagerForVerify( Sender);

   with Mgr.Bank_Account do begin
      if baFields.baTemp_Include_In_Scheduled_Coding_Report and
         (Pos(baFields.baBank_Account_Number + ',', MyClient.clFields.clExclude_From_Scheduled_Reports) = 0) then begin
         // do not add duplicates #2326
         Duplicate := False;
         for i := 0 to Pred(Mgr.ScheduledRptParams.srSummaryInfoList.Count) do
         begin
           NewSummaryRec := Mgr.ScheduledRptParams.srSummaryInfoList[i];
           if (NewSummaryRec.ClientCode = MyClient.clFields.clCode) and
              (NewSummaryRec.AccountNo = baFields.baBank_Account_Number) then
           begin
              Duplicate := True;
              Break;
           end;
         end;
         if not Duplicate then
         begin
           Inc( Mgr.AccountsPrinted);
           //account will be included so add info for summary
           //create a summary record and add it to the list
           GetMem( NewSummaryRec, Sizeof( TSchdRepSummaryRec));
           with NewSummaryRec^ do begin
              ClientCode         := MyClient.clFields.clCode;
              AccountNo          := baFields.baBank_Account_Number;
              PrintedFrom        := Mgr.FirstEntryDate;
              PrintedTo          := Mgr.LastEntryDate;
              AcctsPrinted       := Mgr.AccountsPrinted;
              AcctsFound         := Mgr.AccountsFound;
              SendBy             := rdNone;
              UserResponsible    := 0;
              Completed          := False;
              TxLastMonth        := (MyClient.clFields.clReporting_Period = roSendEveryMonth) and
                                    (Mgr.FirstEntryDate < TScheduledCodingReport( Mgr.ReportJob).ScheduledRptParams.srDisplayFromDate) and
                                    (not MyClient.clFields.clCheckOut_Scheduled_Reports) and
                                    (not MyClient.clExtra.ceOnline_Scheduled_Reports);
           end;
           Mgr.ScheduledRptParams.srSummaryInfoList.Add( NewSummaryRec);
           //store a pointer to the first record so that we can update it with the
           //accounts printed and accounts found values.
           if Mgr.FirstSummaryInfoRec = nil then
              Mgr.FirstSummaryInfoRec := NewSummaryRec;
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
//
// PutNotes
//
// Outputs Notes column but wraps text onto multiple lines if need be.
//
procedure TScheduledCodingReport.PutNotes(Notes: string);
var
  j, ColWidth, OldWidth : Integer;
  ColsToSkip : integer;
  NotesList  : TStringList;
  MaxNotesLines: Integer;
begin
  if WrapNarration then
    MaxNotesLines := 10
  else
    MaxNotesLines := 1;
  if (Notes = '') then
    SkipColumn
  else
  begin
    NotesList  := TStringList.Create;
    try
      NotesList.Text := Notes;
      ColsToSkip := CurrDetail.Count;
      j := 0;
      repeat
        ColWidth := RenderEngine.RenderColumnWidth(CurrDetail.Count, NotesList[ j]);
        if (ColWidth < Length(NotesList[j])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store
          while (ColWidth > 0) and (NotesList[j][ColWidth] <> ' ') do
            Dec(ColWidth);
          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!
          NotesList.Insert(j + 1, Copy(NotesList[j], ColWidth + 1, Length(NotesList[j]) - ColWidth + 1));
          NotesList[j] := Copy(NotesList[j], 1, ColWidth);
        end;
        PutString( NotesList[ j]);
        Inc( j);
        //decide if need to call renderDetailLine
        if ( j < notesList.Count) and ( j < MaxNotesLines) then
        begin
          RenderDetailLine;
          //skip all other fields (reuse ColWidth)
          for ColWidth := 1 to ColsToSkip do
            SkipColumn;
        end;
      until ( j >= NotesList.Count) or ( j >= MaxNotesLines);
    finally
       NotesList.Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// PutNarrationNotes
//
// Outputs Narration and Notes columns but wraps text onto multiple lines
// if need be.
//
procedure TScheduledCodingReport.PutNarrationNotes(Narration, Notes : string);
const
  MaxLinesAllowed = 10;
var
  NotesList : TStringList;
  NarrList : TStringList;
  NoteLines, NarrLines : Integer;
  MaxLines : Integer;
  ColsToSkip, i, j : Integer;
begin
  NarrList := TStringList.Create;
  NotesList := TStringList.Create;
  try
    ColsToSkip := CurrDetail.Count;
    NarrList.Text := Narration;
    NotesList.Text := Notes;
    NarrLines := SplitLine(CurrDetail.Count, NarrList);
    NoteLines := SplitLine(CurrDetail.Count, NotesList);

    if (NarrLines > 1) and (not WrapNarration) then
      NarrLines := 1;
    if (NoteLines > 1) and (not WrapNarration) then
      NoteLines := 1;

    MaxLines := NarrLines;
    if (NoteLines > NarrLines) then
      MaxLines := NoteLines;
    if (MaxLines > MaxLinesAllowed) then
      MaxLines := MaxLinesAllowed;

    if (MaxLines = 0) then
    begin
      SkipColumn;
      SkipColumn;
    end else
    begin
      for i := 0 to MaxLines-1 do
      begin
        if (i < NarrLines) then
          PutString(NarrList[i])
        else
          SkipColumn;
        if (i < NoteLines) then
          PutString(NotesList[i])
        else
          SkipColumn;
        if (i < MaxLines-1) then
        begin
          RenderDetailLine(False);
          j := ColsToSkip;
          while (j > 0) do
          begin
            SkipColumn;
            Dec(j);
          end;
        end;
      end;
    end;
  finally
    NotesList.Free;
    NarrList.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TScheduledCodingReport.SplitLine(ColIdx: Integer; var TextList: TStringList) : Integer;
const
  MaxLines = 10;
var
  j, ColWidth, OldWidth : Integer;
begin
  if (TextList.Count = 0) then
    Result := 0
  else
  begin
      j := 0;
      repeat
        ColWidth := RenderEngine.RenderColumnWidth(ColIdx, TextList[ j]);
        if (ColWidth < Length(TextList[j])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store
          while (ColWidth > 0) and (TextList[j][ColWidth] <> ' ') do
            Dec(ColWidth);
          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!
          TextList.Insert(j + 1, Copy(TextList[j], ColWidth + 1, Length(TextList[j]) - ColWidth + 1));
          TextList[j] := Copy(TextList[j], 1, ColWidth);
        end;
        Inc( j);
      until ( j >= TextList.Count) or ( j >= MaxLines);
      Result := TextList.Count;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TScheduledCodingReport.BKPrint;
var
   TravMgr : TTravManagerWithNewReport;
   VerifyTravMgr : TTravManagerForVerify;
   NettTotal : currency;
begin
  //first establish which accounts should be printed
  //traverse each account settings a flag for that account if a transaction is
  //found to print that is within correct date range

  //this is done even if all transactions are being included so that we
  //only print accounts which have transactions
  PrintingEntry := True;

  VerifyTravMgr := TTravManagerForVerify.Create;
  try
    VerifyTravMgr.Clear;
    VerifyTravMgr.SortType          := SortMethod; //csDateEffective;
    Case MyClient.clFields.clScheduled_Coding_Report_Entry_Selection of
       esAllEntries   : VerifyTravMgr.SelectionCriteria := TravList.twAllEntries;
       esUncodedOnly  : VerifyTravMgr.SelectionCriteria := TravList.twAllUncoded;
    end;
    VerifyTravMgr.OnEnterAccount    := Verify_EnterAccount;
    VerifyTravMgr.OnEnterEntry      := Verify_EnterEntry;
    VerifyTravMgr.OnExitAccount     := Verify_ExitAccount;

    with VerifyTravMgr do begin
       ScheduledRptParams         := Self.ScheduledRptParams;
       //initialise accumulators which will be used to track how many accounts
       //were printed out of those found in the admin system.
       AccountsPrinted     := 0;
       AccountsFound       := 0;
       FirstSummaryInfoRec := nil;
       ReportJob := Self;

       TraverseAllAccounts( Self.D1, Self.D2, BKCONST.TransferringJournalsSet);  //Self refers to report object!!!

       //update the first line now that we know the final values
       if FirstSummaryInfoRec <> nil then begin
          FirstSummaryInfoRec^.AcctsPrinted := AccountsPrinted;
          FirstSummaryInfoRec^.AcctsFound   := AccountsFound;
          FirstSummaryInfoRec^.SendBy       := Self.SentTo;
       end;
    end;
  finally
     VerifyTravMgr.Free;
  end;

  //Now create report
  TravMgr := TTravManagerWithNewReport.Create;
  try
     TravMgr.Clear;
     TravMgr.SortType          := SortMethod; //csDateEffective;
     TravMgr.ReportJob         := Self;

     Case MyClient.clFields.clScheduled_Coding_Report_Entry_Selection of
        esAllEntries   : TravMgr.SelectionCriteria := TravList.twAllEntries;        //twAllNewEntries;
        esUncodedOnly  : TravMgr.SelectionCriteria := TravList.twAllUncoded;        //twAllNewUncodedEntries;
     end;

     TravMgr.OnEnterAccount    := CR_EnterAccount;
     TravMgr.OnExitAccount     := CR_ExitAccount;
     TravMgr.OnEnterEntry      := CR_EnterEntry;
     TravMgr.OnExitEntry       := CR_ExitEntry;
     TravMgr.OnEnterDissection := CR_EnterDissect;
     TravMgr.C1                := Col1;
     TravMgr.C2                := Col2;

     TravMgr.TraverseAllAccounts( D1, D2, BKCONST.TransferringJournalsSet);

     with TravMgr do
     begin
       If MyClient.clFields.clScheduled_Coding_Report_Style in [ rsTwoColumn, rsTwoColumnWithNotes] then
       Begin
          DRTotal := C1.GrandTotal; C1.GrandTotal := 0;
          CRTotal := C2.GrandTotal; C2.GrandTotal := 0;
          NettTotal := DRTotal + CRTotal;
          If NettTotal > 0 then
             C1.GrandTotal := NettTotal/100
          else
             C2.GrandTotal := NettTotal/100;
       end;
     end;

     If ( TravMgr.NumOfAccounts > 1 ) and PRACINI_Reports_GrandTotal then RenderDetailGrandTotal('');
  finally
    TravMgr.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function DoScheduledCodingReport( Destination : TReportDest;
                                   SrOptions   : TSchReportOptions;
                                   Settings    : TPrintManagerObj;
                                   FaxParams : TFaxParameters = nil) : boolean;
const
  ThisMethodName = 'DoScheduledCodingReport';
// returns a result for faxed reports only
var
    D1,D2,D3 : integer;

  Function HasNewEntriesToPrint( B : TBank_Account ) : Boolean;
   Var
      T : LongInt;
      NewEntries : Boolean;
   Begin
      NewEntries := FALSE;
      With B.baTransaction_List do For T := 0 to Pred( itemCount ) do
         With Transaction_At( T )^ do
            If ( txDate_Effective >= D1 ) and
               ( txDate_Effective <= D2 ) and
               ( not IsUPCFromPreviousMonth(txDate_Effective, txUPI_State, D3)) and
               ( txDate_Transferred = 0 ) then
            Begin
               NewEntries := TRUE;
               Break;
            end;
      HasNewEntriesToPrint := NewEntries;
   end;

   Function HasEntries( B : TBank_Account ) : Boolean;
   Var
      T : LongInt;
      Entries : Boolean;
   Begin
      Entries := FALSE;
      With B.baTransaction_List do For T := 0 to Pred( itemCount ) do
         With Transaction_At( T )^ do
            If ( txDate_Effective >= D1 ) and
               ( txDate_Effective <= D2 ) and
               ( not IsUPCFromPreviousMonth(txDate_Effective, txUPI_State, D3)) then
            Begin
               Entries := TRUE;
               Break;
            end;
      HasEntries := Entries;
   end;

var
   Job : TScheduledCodingReport;
   s : string;
   cLeft, cGap : double;
   ClientHasNewEntriesToPrint,
   ClientHasEntries : boolean;
   i : integer;
   B : TBank_Account;
   UserSelectedOrientation : byte;
   Params: TCodingReportSettings;
   FORMAT_AMOUNT : String;
   FORMAT_AMOUNT2 : String;
   j : integer;
   ShowVatFootnote : boolean;
begin
   result := false;

   ClientHasNewEntriesToPrint := FALSE;
   ClientHasEntries           := FALSE;

   d1 := SrOptions.srTrxFromDate;
   d2 := SrOptions.srTrxToDate;
   d3 := srOptions.srDisplayFromDate;

   //Auto Code Entries
   with MyClient.clBank_Account_List do begin
      for i := 0 to Pred( itemCount ) do begin
         AutoCodeEntries(MyClient, Bank_Account_At(i),AllEntries,d1,d2);
         TBank_account(Bank_Account_At(i)).HasExchangeRates(d1, d2, True);
      end;
   end;

   //-----------------------------------------
   //verify that there are entries to print
   with MyClient.clBank_Account_List do begin
      for i := 0 to Pred( itemCount ) do begin
         B := Bank_Account_At( i );
         ClientHasEntries := ClientHasEntries or HasEntries( B );
         ClientHasNewEntriesToPrint := ClientHasNewEntriesToPrint or HasNewEntriesToPrint( B );
      end;
   end;

   If ( not ClientHasEntries ) then begin
      exit;
   end;

   If ( not ClientHasNewEntriesToPrint ) then begin
      { There are no untransferred entries in the date range FromDate..ToDate }
      exit;
   end;

   //-----------------------------------------
   //Create Report
   Job := TScheduledCodingReport.Create(ReportTypes.RptCoding);
   Params := TCodingReportSettings.Create(ord(REPORT_CODING), MyClient, nil);

   try
     with MyClient, MyClient.clFields do begin
       Params.Scheduled := True;
       Job.LoadReportSettings(Settings,Report_List_Names[REPORT_CODING]);
       Job.ReportTitle := Job.ReportTitle + ' - ' + clCode;

       //AddCodingHeader(Job);

       //Add Headers
       AddCommonHeader(Job);

       S := 'FROM ';
       If D1=0 then
          S := S + 'FIRST'
       else
          S := S + bkDate2Str( srOptions.srDisplayFromDate );
       S := S + ' TO ';
       If D2=MaxLongInt then
          S := S + 'LAST'
       else
          S := S + bkDate2Str( D2 );

       AddJobHeader(Job,siTitle,'CODING REPORT '+S, true);

       S := 'BY '+ UpperCase(csNames[clScheduled_Coding_Report_Sort_Order]);

       Case clScheduled_Coding_Report_Entry_Selection of
          esAllEntries   : S := S + ', ALL ENTRIES';
          esUncodedOnly  : S := S + ', UNCODED/INVALIDLY CODED ENTRIES';
       end;
       AddJobHeader(Job,SiSubTitle,S, true);

       FORMAT_AMOUNT  := MyClient.FmtMoneyStrBracketsNoSymbol;
       FORMAT_AMOUNT2 := MyClient.FmtMoneyStrBrackets;

       {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
       CLeft      := GcLeft;
       CGap       := GcGap;
       Job.ColAmt := nil;
       Job.Col1   := nil;
       Job.Col2   := nil;

       //make sure report style is in range
       if not clScheduled_Coding_Report_Style in [ rsMin..rsMax] then
         clScheduled_Coding_Report_Style := rsStandard;

       Case clScheduled_Coding_Report_Style of
          rsStandard :
          begin
             Case clCountry of
                whNewZealand :
                   Begin
                      AddColAuto(Job,cleft,7.0  ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cLeft,2.5  ,cGap,'No',jtRight);
                      AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,12.0 ,cGap,'Analysis',jtLeft);
                      AddColAuto(Job,cleft,9.0  ,cGap,'Code To',jtLeft);
                      Job.ColAmt := AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then
                        AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                      if clScheduled_Coding_Report_Show_OP then begin
                        AddColAuto(Job,cleft,18.0 ,cGap,'Other Party',jtLeft);
                        AddColAuto(Job,cleft,13.0 ,cGap,'Particulars',jtLeft);
                      end
                      else
                         AddColAuto( Job,cLeft, 31.0, cGap, 'Transaction Details', jtLeft);
                   end;
                whAustralia :
                   Begin
                      AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,9.0,cGap,'Code To',jtLeft);
                      Job.ColAmt := AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then begin
                         AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                         AddFormatColAuto( Job, cLeft, 9, cGap, 'GST Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                      end;
                      AddColAuto(Job,cLeft,36,cGap, 'Transaction Details',jtLeft);
                   end;
                 whUk :
                   Begin
                      AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cleft,13.0 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,9.0,cGap,'Code To',jtLeft);
                      Job.ColAmt := AddFormatColAuto(Job,cleft,12,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then begin
                         AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                         if MyClient.HasForeignCurrencyAccounts then
                           AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT (GBP)*', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false)
                         else
                           AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                      end;
                      AddColAuto(Job,cLeft,36,cGap, 'Transaction Details',jtLeft);
                   end;
             end; { of Case clCountry }
          end;

          rsStandardWithNotes :
          begin
             cGap := 0.8;
             Case clCountry of
                whNewZealand :
                   Begin
                      AddColAuto(Job,cleft,7.0  ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cLeft,1.8  ,cGap,'No',jtRight);
                      AddColAuto(Job,cleft,9.75 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,9.0 ,cGap,'Analysis',jtLeft);
                      AddColAuto(Job,cleft,6.0  ,cGap,'Code To',jtLeft);
                      Job.ColAmt := AddFormatColAuto(Job,cleft,9,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then
                        AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                      if clScheduled_Coding_Report_Show_OP then begin
                         AddColAuto(Job,cleft,13.0 ,cGap,'Other Party',jtLeft);
                         AddColAuto(Job,cleft,10.0 ,cGap,'Particulars',jtLeft);
                      end
                      else
                         AddColAuto( Job,cLeft, 24.0, cGap, 'Narration', jtLeft);
                      AddColAuto( Job, cLeft, 27, cGap, 'Notes', jtLeft);
                   end;
                whAustralia :
                   Begin
                      AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cleft,9.75 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,6.0,cGap,'Code To',jtLeft);
                      Job.ColAmt := AddFormatColAuto(Job,cleft,9,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then begin
                         AddColAuto(Job, cLeft, 5.5, cGap, 'Tax Inv', jtCenter);
                         AddFormatColAuto( Job, cLeft, 6.75, cGap, 'GST Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                      end;
                      AddColAuto(Job,cLeft,23,cGap, 'Narration',jtLeft);
                      AddColAuto( Job, cLeft, 27, cGap, 'Notes', jtLeft);
                   end;
                 whUK :
                   Begin
                      AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cleft,9.75 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,6.0,cGap,'Code To',jtLeft);
                      Job.ColAmt := AddFormatColAuto(Job,cleft,9,cGap,'Amount',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then begin
                         AddColAuto(Job, cLeft, 5.5, cGap, 'Tax Inv', jtCenter);
                         if MyClient.HasForeignCurrencyAccounts then
                           AddFormatColAuto( Job, cLeft, 6.75, cGap, 'VAT (GBP)*', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false)
                         else
                           AddFormatColAuto( Job, cLeft, 6.75, cGap, 'VAT Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                      end;
                      AddColAuto(Job,cLeft,23,cGap, 'Narration',jtLeft);
                      AddColAuto( Job, cLeft, 27, cGap, 'Notes', jtLeft);
                   end;

             end; { of Case clCountry }
          end;

          rsTwoColumn :
          begin
              Case clCountry of
                whNewZealand :
                   Begin
                      AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cLeft,2.5,cGap,'No',jtRight);
                      AddColAuto(Job,cleft,9.6 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,9.6 ,cGap,'Analysis',jtLeft);
                      AddColAuto(Job,cleft,9,cGap,'Code To',jtLeft);
                      Job.Col1 := AddFormatColAuto(Job,cLeft,11.5,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      Job.Col2 := AddFormatColAuto(Job,cLeft,11.5,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then
                        AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                      if clScheduled_Coding_Report_Show_OP then begin
                         AddColAuto(Job,cleft,15.4,cGap,'Other Party',jtLeft);
                         AddColAuto(Job,cleft,9.6 ,cGap,'Particulars',jtLeft);
                      end
                      else
                         AddColAuto( Job,cLeft, 25.0, cGap, 'Narration', jtLeft);
                   end;
                whAustralia :
                   Begin
                      AddColAuto(Job,cleft,8.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cleft,14.0 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,9,cGap,'Code To',jtLeft);
                      Job.Col1 := AddFormatColAuto(Job,cLeft,11,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      Job.Col2 := AddFormatColAuto(Job,cLeft,11,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then begin
                         AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                         AddFormatColAuto( Job, cLeft, 9, cGap, 'GST Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                      end;
                      AddColAuto(Job,cLeft,26 ,cGap, 'Narration',jtLeft);
                   end;
                 whUK :
                   Begin
                      AddColAuto(Job,cleft,8.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cleft,14.0 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,9,cGap,'Code To',jtLeft);
                      Job.Col1 := AddFormatColAuto(Job,cLeft,11,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      Job.Col2 := AddFormatColAuto(Job,cLeft,11,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then begin
                        AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                        if MyClient.HasForeignCurrencyAccounts then
                          AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT (GBP)*', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false)
                        else
                          AddFormatColAuto( Job, cLeft, 9, cGap, 'VAT Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                      end;
                      AddColAuto(Job,cLeft,26 ,cGap, 'Narration',jtLeft);
                   end;
             end; { of Case clCountry }
          end;

          rsTwoColumnWithNotes    :
          begin
             CGap     := 0.8;
             Case clCountry of
                whNewZealand :
                   Begin
                      AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cLeft,1.8,cGap,'No',jtRight);
                      AddColAuto(Job,cleft,7.2 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,7.2 ,cGap,'Analysis',jtLeft);
                      AddColAuto(Job,cleft,6,cGap,'Code To',jtLeft);
                      Job.Col1 := AddFormatColAuto(Job,cLeft,8.5,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      Job.Col2 := AddFormatColAuto(Job,cLeft,8.5,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then
                        AddColAuto(Job, cLeft, 6.0, cGap, 'Tax Inv', jtCenter);
                      if clScheduled_Coding_Report_Show_OP then begin
                         AddColAuto(Job,cleft,12.5,cGap,'Other Party',jtLeft);
                         AddColAuto(Job,cleft,7.0 ,cGap,'Particulars',jtLeft);
                      end
                      else
                         AddColAuto( Job,cLeft, 19.5, cGap, 'Transaction Details', jtLeft);
                      AddColAuto( Job, cLeft, 27.5, cGap, 'Notes', jtLeft);
                   end;
                whAustralia :
                   Begin
                      AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cleft,11.0 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,6,cGap,'Code To',jtLeft);
                      Job.Col1 := AddFormatColAuto(Job,cLeft,8.25,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      Job.Col2 := AddFormatColAuto(Job,cLeft,8.25,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then begin
                         AddColAuto(Job, cLeft, 5.5, cGap, 'Tax Inv', jtCenter);
                         AddFormatColAuto( Job, cLeft, 6.7, cGap, 'GST Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                      end;
                      AddColAuto(Job,cLeft,19.5 ,cGap, 'Transaction Details',jtLeft);
                      AddColAuto( Job, cLeft,22, cGap, 'Notes', jtLeft);
                   end;
                whUK :
                   Begin
                      AddColAuto(Job,cleft,7.0 ,cGap,'Date', jtLeft);
                      AddColAuto(Job,cleft,11.0 ,cGap,'Reference',jtLeft);
                      AddColAuto(Job,cleft,6,cGap,'Code To',jtLeft);
                      Job.Col1 := AddFormatColAuto(Job,cLeft,8.25,cGap,'Withdrawals',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      Job.Col2 := AddFormatColAuto(Job,cLeft,8.25,cGap,'Deposits',jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2,true);
                      if clScheduled_Coding_Report_Print_TI then begin
                        AddColAuto(Job, cLeft, 5.5, cGap, 'Tax Inv', jtCenter);
                        if MyClient.HasForeignCurrencyAccounts then
                          AddFormatColAuto( Job, cLeft, 6.7, cGap, 'VAT (GBP)*', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false)
                        else
                          AddFormatColAuto( Job, cLeft, 6.7, cGap, 'VAT Amt', jtRight,FORMAT_AMOUNT,FORMAT_AMOUNT2, false);
                      end;
                      AddColAuto(Job,cLeft,19.5 ,cGap, 'Transaction Details',jtLeft);
                      AddColAuto( Job, cLeft,22, cGap, 'Notes', jtLeft);
                   end;
             end; { of Case clCountry }
          end;
          rsCustom:
          begin
            //Load custom coding report params
            Params.LoadCustomReportXML(MyClient.clExtra.ceScheduled_Custom_CR_XML);
            Params.CustomReport := True;
            Job.FSettings := Params;
            //Portrait or landscape
            Job.UserReportSettings.s7Orientation := Job.FSettings.ColManager.Orientation;
            //Finally add columns to the report
            Params.ColManager.AddReportColumns(Job);

            // Find the amount column (similar code from rptCoding)
            j := -1;
            for i := 0 to Pred(Job.FSettings.ColManager.Count) do begin
              if Job.FSettings.ColManager.Columns[i].OutputCol then begin
                Inc(j); // is in the report..
                case Job.FSettings.ColManager.Columns[i].DataToken of
                  tktxAmount:
                    Job.ColAmt := Job.Columns.Report_Column_At(j);
                end;
              end;
            end;

          end;
       end; { of Case clScheduled_Coding_Report_Style }

       // See which column contains notes and narrations
       Job.NarrationColIdx := -1;
       Job.NotesColIdx := -1;
       ShowVatFootnote := false;
       for i := 0 to Pred(Job.Columns.ItemCount) do
       begin
        if TReportColumn(Job.Columns.Report_Column_At(i)).Caption = 'Notes' then
          Job.NotesColIdx := i
        else if TReportColumn(Job.Columns.Report_Column_At(i)).Caption = 'Transaction Details' then
          Job.NarrationColIdx := i
        else if TReportColumn(Job.Columns.Report_Column_At(i)).Caption = 'VAT (GBP)*' then
          ShowVatFootnote := true;
       end;

       if clScheduled_Coding_Report_Print_TI then
         AddJobFooter( Job,siFootNote, '( Tax Inv = Tax Invoice  [x] = Available )', true);

       if ShowVatFootnote then
         AddJobFooter( Job, siFootNote, '* Please ensure that you indicate a currency for any VAT amounts recorded for this account.', true);

       //AddCodingFooter(Job);
       //Add Footers
       AddCommonFooter(Job);

       Job.d1 := D1;
       Job.d2 := D2;
       Job.d3 := D3;
       Job.ScheduledRptParams := SrOptions;

       Job.Style      := clScheduled_Coding_Report_Style;
       Job.SortMethod := clScheduled_Coding_Report_Sort_Order;
       Job.Include    := clScheduled_Coding_Report_Entry_Selection;
       Job.LeaveLines := clScheduled_Coding_Report_Blank_Lines;
       Job.RuleLine   := clScheduled_Coding_Report_Rule_Line;
       Job.WrapNarration := clScheduled_Coding_Report_Wrap_Narration;
       Job.SentTo     := Destination;

       //store user report setting for report orientation.  this allows the user
       //to pick the orientation for standard coding reports (without notes) but
       //allows us to force reports with notes to be landscape
       UserSelectedOrientation := Job.UserReportSettings.s7Orientation;
       try
         if clScheduled_Coding_Report_Style in [rsStandardWithNotes, rsTwoColumnWithNotes] then
         begin
           //landscape, override the user setting
           Job.UserReportSettings.s7Orientation := 1;
         end;

         if ( Destination = rdEmail) then
         begin
            //special case for scheduled reports.  Don't want the user to be asked
            //what file name to use
            case clEmail_Report_Format of
              rfCSV :
                Result := Job.GenerateToFile( EmailOutboxDir + clCode + '.CDC', rfCSV, Params);
              rfFixedWidth :
                Result := Job.GenerateToFile( EmailOutboxDir + clCode + '.COD', rfFixedWidth,Params);
              rfPDF :
                Result := Job.GenerateToFile( EmailOutboxDir + clCode + '.CDP', rfPDF, Params);
              rfExcel :
                Result := Job.GenerateToFile( EmailOutboxDir + clCode + '.CDX', rfExcel, Params);
            end;
         end
         else
         if ( Destination = rdFax) then
         begin
           result := Job.GenerateToFax( FaxParams, AdminSystem.fdFields.fdSched_Rep_Fax_Transport, Params)
         end
         else
         begin
           Job.Generate(Destination,Params);
           Result := True;
         end;
       finally
         Job.UserReportSettings.s7Orientation := UserSelectedOrientation;
       end;

       if Destination <> rdScreen then
       begin
         if LoadAdminSystem(true, ThisMethodName) then
         begin
            AddAutomaticToDoItem( clCode,
                              ttyCodingReport,
                              Format( ToDoMsg_ManualCodingReport,
                                     [ bkDate2Str( D1 ), bkDate2Str( D2 ),
                                     bkDate2Str(CurrentDate)]
                                    )
                              );
            SaveAdminSystem();
         end;
       end;

     end; {with MyClient}
   finally
    Job.Free;
    Params.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// AfterNewPage
//
// Parameters :
// DetailPending : Indicates that there is a detail line to be rendered
//                 immediately after thepage header.
//
procedure TScheduledCodingReport.AfterNewPage(DetailPending : Boolean);
var
  s : String;
begin
  AccountTitle := False;
  if (Assigned(CurrentBankAccount)) then
  begin
    //render the acccount details at the top of each page
    s := CurrentBankAccount.baFields.baBank_Account_Number + ' : '+CurrentBankAccount.AccountName;
    RenderTitleLine(s);
    AccountTitle := True;
  end;
  if (DetailPending) and (MyClient.clFields.clScheduled_Coding_Report_Rule_Line) then
  begin
    //render a ruled line before the pending detail is rendered
    if (PrintingEntry) then
      RenderRuledLine
    else
    begin
      if (MyClient.clFields.clScheduled_Coding_Report_Sort_Order = csAccountCode) or
         (Assigned(CurrentBankAccount) and (CurrentBankAccount.IsAJournalAccount)) then
        RenderRuledLine
      else
        RenderRuledLine(psDot);
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

