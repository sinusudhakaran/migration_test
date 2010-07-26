unit RptPayee;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Payee Reports
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ReportDefs,UBatchBase;

procedure DoPayeeSpendingReport(Destination : TReportDest; RptBatch :TReportBase = nil);

//******************************************************************************
implementation

uses
  ReportTypes,
  Classes,
  SysUtils,
  NewReportObj,
  RepCols,
  Globals,
  bkDefs,
  baObj32,
  GenUtils,
  NewReportUtils,
  bkDateUtils,
  PayeeLookupFrm,
  PayeeRepDlg, MoneyDef,
  RptParams,
  PayeeObj, clObj32, balist32, trxList32, bkbaio, bktxio, bkdsio, stdate, bkconst;

type
   TPayeeSpendingReport = class(TBKReport)
   private
     Bank_Account : TBank_Account;
     Transaction  : pTransaction_Rec;
     Payee        : TPayee;
     Dissection   : pDissection_Rec;
     Account      : pAccount_Rec;
   public
     params : TPayeeParameters;
     function ShowPayeeOnReport( aPayeeNo : integer) : boolean;
   end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SpendingDetail(Sender : TObject);
var
  i,b,t : LongInt;
Begin
   with TPayeeSpendingReport(Sender), params, Client, clFields  do
   begin
     //calculate totals by cycling through all transaction in the specified
     //date range
     with clPayee_List do
       for i := First to Last do
         Payee_At(i).pdFields.pdTotal := 0;

     with clBank_Account_List do
     begin
       for B := 0 to Pred( itemCount ) do
       begin
          Bank_Account := Bank_Account_At( B );
          with Bank_Account, baTransaction_List do For T := 0 to Pred( itemCount ) do Begin
             Transaction := Transaction_At( T );
             With Transaction^ do If ( txDate_Effective >=Fromdate ) and ( txDate_Effective <=Todate ) then begin
                //is a payee number assigned to the transaction
                if ( txPayee_Number<>0 ) then begin
                   Payee := clPayee_List.Find_Payee_Number(txPayee_Number);
                   if Assigned( Payee ) then
                     Payee.pdFields.pdTotal := Payee.pdFields.pdTotal + txAmount;
                end
                else begin
                   if ( txFirst_Dissection <> nil) then begin
                      //see if dissection lines should be part of total
                      Dissection := txFirst_Dissection;
                      while Dissection <> nil do begin
                         if ( Dissection^.dsPayee_number <> 0) then begin
                            Payee := clPayee_List.Find_Payee_Number( Dissection^.dsPayee_Number );
                            if Assigned( Payee ) then
                              Payee.pdFields.pdTotal := Payee.pdFields.pdTotal + Dissection^.dsAmount;
                         end;
                         Dissection := Dissection^.dsNext;
                      end;
                   end;
                end;
             end; //with transaction^
          end;
       end;
     end;

     //see if this payee should be included on the report
     for i := MyClient.clPayee_List.First to MyClient.clPayee_List.Last do
     begin
       Payee := MyClient.clPayee_List.Payee_At( i);
       if ShowPayeeOnReport( Payee.pdFields.pdNumber) then
       begin
         PutString( Payee.pdFields.pdName);
         PutCurrency( Payee.pdFields.pdNumber);
         PutMoney( Payee.pdFields.pdTotal);
         RenderDetailLine;
       end;
     end;
     RenderDetailGrandTotal('');
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DetailedSpendingDetail(Sender : TObject);
Var
   i           : LongInt;
   Report      : TPayeeSpendingReport;

   procedure PutNarration(Notes: string);
   var
     j, ColWidth, OldWidth : Integer;
     ColsToSkip : integer;
     NotesList  : TStringList;
     MaxNotesLines: Integer;
   begin
     with Report, params do
     begin
      if WrapNarration then
         MaxNotesLines := 10
      else
         MaxNotesLines := 1;
      if (Notes = '') then
         SkipColumn
      else
      begin
        NotesList := TStringList.Create;
        try
          NotesList.Text := Notes;
          // Remove blank lines
          j := 0;
          while j < NotesList.Count do
          begin
            if NotesList[j] = '' then
              NoteSList.Delete(j)
            else
              Inc(j);
          end;
          if NotesList.Count = 0 then
          begin
            SkipColumn;
            Exit;
          end;
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
            if ( j < notesList.Count)
            and ( j < MaxNotesLines) then
            begin
              RenderDetailLine(False);
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
  end;

   Procedure DoPayee;
   Var
      NameRendered, SubTotalRendered : Boolean;
      T, B        : LongInt;
      IncludeAllDissectionLines : Boolean;
      Ref : string;
      TR: PTransaction_Rec;
      DR, D: PDissection_Rec;
      PSDate, PEDate: Integer;
      PeriodTotal: Money;
      LPayee : Integer;
      Transaction_List: TTransaction_List;
      dy, m, y: Integer;
    Trans: pTransaction_Rec;
   Begin
      Transaction_List := TTransaction_List.Create( NIL, NIL );
      try
      NameRendered := False;
      with Report, params, Client, clFields, Payee do
      Begin
         With clBank_Account_List do
         Begin
            For B := 0 to Pred( itemCount ) do
            Begin
               Bank_Account := Bank_Account_At( B );
               With Bank_Account, baTransaction_List do For T := 0 to Pred( itemCount ) do
               Begin
                  Transaction := Transaction_At( T );
                  If ( Transaction^.txDate_Effective >=Fromdate) and ( Transaction^.txDate_Effective <=Todate) then
                  begin
                    TR := Bank_Account.baTransaction_List.New_Transaction;
                    with Transaction^ do
                    begin
                      TR.txType                  := txType;
                      TR.txDate_Presented        := txDate_Presented;
                      TR.txDate_Effective        := txDate_Effective;
                      TR.txAmount                := txAmount;
                      TR.txGST_Class             := txGST_Class;
                      TR.txGST_Amount            := txGST_Amount;
                      TR.txHas_Been_Edited       := txHas_Been_Edited;
                      TR.txQuantity              := txQuantity;
                      TR.txCheque_Number         := txCheque_Number;
                      TR.txReference             := txReference;
                      TR.txAnalysis              := txAnalysis;
                      TR.txOrigBB                := txOrigBB;
                      TR.txOther_Party           := txOther_Party;
                      TR.txParticulars           := txParticulars;
                      TR.txGL_Narration          := txGL_Narration;
                      TR.txAccount               := txAccount;
                      TR.txCoded_By              := txCoded_By;
                      TR.txPayee_Number          := txPayee_Number;
                      TR.txLocked                := txLocked;
                      TR.txGST_Has_Been_Edited   := txGST_Has_Been_Edited;
                      TR.txUPI_State             := txUPI_State;
                      TR.txNotes                 := txNotes;
                      TR.txTax_Invoice_Available := txTax_Invoice_Available;
                      //copy dissections
                      if txFirst_Dissection <> nil then
                      begin
                         D := txFirst_Dissection;
                         if TR.txPayee_Number = 0 then
                            LPayee := D.dsPayee_Number
                         else
                            lPayee := 0;
                         while D <> nil do
                         begin
                            if LPayee <> 0 then
                              if LPayee <> D.dsPayee_Number then
                                 lPayee := 0;
                            DR := bkdsio.New_Dissection_Rec;
                            DR.dsAccount         := D.dsAccount;
                            DR.dsReference       := D.dsReference;
                            DR.dsAmount          := D.dsAmount;
                            DR.dsGST_Class       := D.dsGST_Class;
                            DR.dsGST_Amount      := D.dsGST_Amount;
                            DR.dsQuantity        := D.dsQuantity;
                            DR.dsGL_Narration    := D.dsGL_Narration;
                            DR.dsHas_Been_Edited := D.dsHas_Been_Edited;
                            DR.dsGST_Has_Been_Edited := D.dsGST_Has_Been_Edited;
                            DR.dsPayee_Number    := D.dsPayee_Number;
                            DR.dsNotes           := D.dsNotes;


                            trxlist32.AppendDissection( TR, DR);
                            D := D.dsNext;
                         end;
                         if lPayee <> 0 then TR.txPayee_Number :=  lPayee;
                      end;
                    end;
                    Transaction_List.Insert_Transaction_Rec(TR);
                  end;
               end;
            end;
         end;

        SubTotalRendered := False;
        PeriodTotal := 0;
        // First period end date will be report start + period
        PSDate := FromDate;
        PEDate := IncDate(PSDate, 0, ShowTotals, 0);
        StDatetoDMY(PEDate, dy, m, y);
        PEDate := DMYToStDate(DaysInMonth(m, y, Epoch), m, y, Epoch);
        if (ShowTotals > -1) and (Transaction_List.ItemCount > 0) then
        begin
          Trans := Transaction_List.Transaction_At(0);
            // check the first date...
          while Trans^.txDate_Effective > PEDate do begin
            PSDate := IncDate(PEDate, 1, 0, 0);
            PEDate := IncDate(PSDate, 0, ShowTotals, 0);
            StDatetoDMY(PEDate, dy, m, y);
            PEDate := DMYToStDate(DaysInMonth(m, y, Epoch), m, y, Epoch);
          end;
          if PEDate > ToDate then
            PEDate := ToDate;
        end;
        For T := 0 to Pred(Transaction_List.ItemCount) do
        begin
          Transaction := Transaction_List.Transaction_At( T );
          Assert(Transaction <> nil);
          With Transaction^ do begin
             if NameRendered and (ShowTotals > -1) and (txDate_Effective > PEDate) then // show total for this period, start new period
             begin
              RenderColumnLine(2);
              PutString(bkDate2Str( PSDate) + ' - ' + bkDate2Str( PEDate));
              PutString('Sub Total');
              PutMoneyDontAdd(PeriodTotal);
              SkipColumn;
              SkipColumn;
              SkipColumn;
              RenderDetailLine(True,siSectiontotal);
              RenderTextLine('');
              SubTotalRendered := True;
              PeriodTotal := 0;
             end;
             //move period forward even if we didn't have transactions to render a total for in the previous period
             //case 8597
             if (ShowTotals > -1) and (txDate_Effective > PEDate) then
             begin
                // move period forward so this trx is within it
                while txDate_Effective > PEDate do
                begin
                  PSDate := IncDate(PEDate, 1, 0, 0);
                  PEDate := IncDate(PSDate, -1, ShowTotals + 1, 0);
                end;
                if PEDate > ToDate then
                  PEDate := ToDate;
             end;
             //see if transaction is dissected
             If txFirst_Dissection<>NIL then Begin
                if ( txPayee_Number = pdNumber) then
                   IncludeAllDissectionLines := true
                else
                   IncludeAllDissectionLines := false;

                //show main transaction if all lines are coded to payee
                if IncludeAllDissectionLines then begin
                   if (not NameRendered) then
                   begin
                     RenderTitleLine(pdName + ' (' + IntToStr(pdNumber) + ')');
                     NameRendered := True;
                   end;
                   PutString( bkDate2Str( txDate_Effective ) );
                   PutString( GetFormattedReference( Transaction));

                   PutMoney( txAmount );
                   SkipColumn;
                   SkipColumn;
                   SkipColumn;
                   RenderDetailLine;
                   PeriodTotal := PeriodTotal + txAmount;
                   SubTotalRendered := False;
                end;

                Dissection := txFirst_Dissection;
                While ( Dissection<>NIL ) do With Dissection^ do
                Begin
                   if IncludeAllDissectionLines or ( dsPayee_Number = pdNumber) then
                   begin
                      if (not NameRendered) then
                      begin
                        RenderTitleLine(pdName + ' (' + IntToStr(pdNumber) + ')');
                        NameRendered := True;
                      end;
                      PutString( bkDate2Str( txDate_Effective ) );

                      if dsReference > '' then
                         Ref := dsReference
                      else
                         Ref := '/' + IntToStr( dsSequence_No );

                      PutString( REF );

                      if IncludeAllDissectionLines then
                         //amount will have been added above
                         PutMoneyDontAdd( dsAmount )
                      else
                      begin
                         PutMoney( dsAmount);
                         PeriodTotal := PeriodTotal + dsAmount;
                      end;

                      PutString( dsAccount );
                      Account := clChart.FindCode( dsAccount );
                      If Account<>NIL then PutString(Copy( Account^.chAccount_Description, 1, 20 ) )
                        else SkipColumn;

                      PutNarration( dsGL_Narration);
                      RenderDetailLine;
                      SubTotalRendered := False;
                   end;
                   Dissection := dsNext;
                end;
             end
             else
             begin
                //transaction is not dissected, see if assigned to this payee
                if txPayee_Number = pdNumber then begin
                   if (not NameRendered) then
                   begin
                     RenderTitleLine(pdName + ' (' + IntToStr(pdNumber) + ')');
                     NameRendered := True;
                   end;
                   PutString( bkDate2Str( txDate_Effective ) );
                   PutString( GetFormattedReference( Transaction));
                   PutMoney( txAmount );
                   PutString( txAccount );
                   Account := clChart.FindCode( txAccount );
                   If Account<>NIL then PutString(Copy( Account^.chAccount_Description, 1, 20 ) )
                    else SkipColumn;
                   PutNarration( txGL_Narration);
                   RenderDetailLine;
                   PeriodTotal := PeriodTotal + txAmount;
                   SubTotalRendered := False;
                end;
             end;
          end;
        end;
        if NameRendered
          and (ShowTotals > -1)
          and (not SubTotalRendered) then begin
           RenderColumnLine(2);
           if PEDate > ToDate then
             PEDate := ToDate;
           PutString(bkDate2Str( PSDate) + ' - ' + bkDate2Str( PEDate));
           PutString('Sub Total');
           PutMoneyDontAdd(PeriodTotal);
           SkipColumn;
           SkipColumn;
           SkipColumn;
           RenderDetailLine(True,siSectiontotal);
           RenderTextLine('');
        end;
        if (NameRendered) then
          RenderDetailSubTotal(pdName, True, False, 'Total');
      end;

      finally
         Transaction_List.Free;
      end;
   end;

begin
   Report := TPayeeSpendingReport(Sender);
   with Report do
   begin
     //see if this payee should be included on the report
     for i := MyClient.clPayee_List.First to MyClient.clPayee_List.Last do
     begin
       Payee := MyClient.clPayee_List.Payee_At( i);
       if ShowPayeeOnReport( Payee.pdFields.pdNumber) then
       begin
         DoPayee;
       end;
     end;

     RenderDetailGrandTotal('Grand Total');
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GenerateDetailedPayeeSpendingReport( Dest : TReportDest; Job : TPayeeSpendingReport);
var CLeft : Double;
begin
  Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_PAYEE_SPENDING_DETAILED]);

  //Add Headers
  AddCommonHeader(Job);

  AddJobHeader(Job,siTitle,'DETAILED SPENDING BY PAYEE',true);
  AddjobHeader(Job,siSubTitle,'For the period from ' +
                         bkdate2Str( Job.Params.Fromdate) + ' to '+
                         bkDate2Str( Job.Params.ToDate),true);
  AddjobHeader(Job,siSubTitle,'',True);

  CLeft  := GcLeft;
  if Job.Params.ShowTotals > -1 then begin
    AddColAuto(Job,cLeft,      17.0,Gcgap,'Date', jtLeft);
    AddColAuto(Job,cLeft,      11.0,Gcgap,'Reference', jtLeft);
    AddFormatColAuto(Job,cLeft,14.0,Gcgap,'Amount',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
    AddColAuto(Job,Cleft,      10.0,Gcgap,'Account', jtRight);
    AddColAuto(Job,cLeft,      20.0,Gcgap,'', jtLeft);
    AddColAuto(Job,cLeft,       0.0,Gcgap,'Narration', jtLeft);
  end
  else
  begin
    AddColAuto(Job,cLeft,       8.5,Gcgap,'Date', jtLeft);
    AddColAuto(Job,cLeft,      11.5,Gcgap,'Reference', jtLeft);
    AddFormatColAuto(Job,cLeft,14.0,Gcgap,'Amount',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
    AddColAuto(Job,cLeft,      10.0,Gcgap,'Account', jtRight);
    AddColAuto(Job,cLeft,      20.0,Gcgap ,'', jtLeft);
    AddColAuto(Job,cLeft,       0.0,Gcgap,'Narration', jtLeft);
  end;

  //Add Footers
  AddCommonFooter(Job);

  Job.OnBKPrint := DetailedSpendingDetail;
  Job.Generate(Dest,Job.params);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GenerateSummaryPayeeSpendingReport( Dest : TReportDest; Job : TPayeeSpendingReport);
var cLeft: Double;
begin
  Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_PAYEE_SPENDING]);

  //Add Headers
  AddCommonHeader(Job);

  AddJobHeader(Job,siTitle,'SUMMARISED SPENDING BY PAYEE',true);
  AddjobHeader(Job,siSubTitle,'For the period from ' +
                                  bkdate2Str( Job.Params.FromDate) + ' to '+
                                  bkDate2Str( Job.Params.ToDate),true);

  {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
  cLeft := GcLeft;
  AddColAuto(Job,cLeft,      35,GcGap,'Name', jtLeft);
  AddFormatColAuto(Job,cLeft,10,GcGap,'Payee No',jtRight,'##','',false);
  AddFormatColAuto(Job,cLeft,20,GcGap,'Amount',jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets, true);

  //Add Footers
  AddCommonFooter(Job);

  Job.OnBKPrint := SpendingDetail;
  Job.Generate(Dest,Job.params);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoPayeeSpendingReport(Destination : TReportDest; RptBatch :TReportBase = nil);
//report can be printed in detailed or summary style
var
   Job   : TPayeeSpendingReport;
   Params : TPayeeParameters;
begin
   //set defaults

   Params := TPayeeParameters.Create(ord(Report_Payee_Spending), MyClient,Rptbatch,DYear);
   with params do try
      Params.FromDate := 0;
      Params.ToDate := 0;

      repeat
        if not GetPRParameters(Params) then
           exit;

        if RunBtn = BTN_SAVE then begin
          SaveNodeSettings;
          Exit;
        end;


        {if (Destination = rdNone)
        or Batchsetup then}
        case RunBtn of
          BTN_PRINT   : Destination := rdPrinter;
          BTN_PREVIEW : Destination := rdScreen;
          BTN_FILE    : Destination := rdFile;
        else
           Destination := rdAsk;
        end;

        Job := TPayeeSpendingReport.Create(rptOther);;
        try
          //set parameters
          Job.Params := Params;

          if SummaryReport then
             GenerateSummaryPayeeSpendingReport( Destination, Job)
          else
             GenerateDetailedPayeeSpendingReport( Destination, Job);

        finally
          Job.Free;
        end;

        //Destination := rdNone;
      until Params.RunExit(Destination);

   finally
      Params.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TPayeeSpendingReport }

function TPayeeSpendingReport.ShowPayeeOnReport( aPayeeNo : integer): boolean;
var
  i : integer;
begin
  result := true;

  if Params.ShowAllCodes then
    exit
  else
  with params do begin
    for i := Low( RangesArray) to High( RangesArray) do
    begin
      with RangesArray[i] do
      begin
        if ( ToCode <> 0) then
        begin
          if ( aPayeeNo >= FromCode) and ( aPayeeNo <= ToCode) then
            Exit;
        end
        else
          if ( FromCode <> 0) and ( FromCode = aPayeeNo) then
            //special case, if only a from code is specified then match
            //on the specific code
            Exit;
      end;
    end;
  end;

  result := false;
end;

end.
