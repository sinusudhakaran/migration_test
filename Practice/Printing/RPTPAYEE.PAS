unit RptPayee;

//------------------------------------------------------------------------------
interface

uses
  ReportDefs,
  UBatchBase,
  RepCols,
  baObj32,
  bkDefs,
  PayeeObj,
  PayeeRepDlg,
  trxList32,
  NewReportObj;

type
  //----------------------------------------------------------------------------
  TPayeeSpendingReport = class(TBKReport)
  private
  protected
    procedure PutNarration(Notes: string);
    procedure FillTempTransactionList(var aTranList : TTransaction_List);
    procedure CalcPeriodStartandEndDates(aTranList : TTransaction_List;
                                         var aPeriodStartDate, aPeriodEndDate : Integer);
    procedure DoPayee(aPayee : TPayee);

    procedure SpendingDetail();
    procedure DetailedSpendingDetail();
  public
    Params : TPayeeParameters;

    procedure GenerateDetailedPayeeSpendingReport(aDest : TReportDest);
    procedure GenerateSummaryPayeeSpendingReport(aDest : TReportDest);

    function ShowPayeeOnReport( aPayeeNo : integer) : boolean;
  end;

//------------------------------------------------------------------------------
procedure DoPayeeSpendingReport(aDestination : TReportDest; aRptBatch : TReportBase = nil);

//------------------------------------------------------------------------------
implementation

uses
  ReportTypes,
  Classes,
  SysUtils,
  Globals,
  GenUtils,
  NewReportUtils,
  bkDateUtils,
  PayeeLookupFrm,
  MoneyDef,
  RptParams,
  clObj32,
  bktxio,
  balist32,
  bkbaio,
  bkdsio,
  stdate,
  bkconst;

//------------------------------------------------------------------------------
procedure DoPayeeSpendingReport(aDestination : TReportDest; aRptBatch : TReportBase = nil);
var
  Job   : TPayeeSpendingReport;
  Params : TPayeeParameters;
  ISOCodes: string;
begin
  Params := TPayeeParameters.Create(ord(Report_Payee_Spending), MyClient, aRptBatch, DYear);

  try
    Params.FromDate := 0;
    Params.ToDate := 0;

    repeat
      if not GetPRParameters(Params) then
        exit;

      if Params.RunBtn = BTN_SAVE then
      begin
        Params.SaveNodeSettings;
        Exit;
      end;

      case Params.RunBtn of
        BTN_PRINT   : aDestination := rdPrinter;
        BTN_PREVIEW : aDestination := rdScreen;
        BTN_FILE    : aDestination := rdFile;
        BTN_EMAIL   : aDestination := rdEmail;
      else
        aDestination := rdAsk;
      end;

      //Check Forex - this won't stop the report running if there are missing exchange rates
      MyClient.HasExchangeRates(ISOCodes, Params.FromDate, Params.ToDate, True, True);

      Job := TPayeeSpendingReport.Create(rptOther);;
      try
        //set parameters
        Job.Params := Params;

        if Params.SummaryReport then
          Job.GenerateSummaryPayeeSpendingReport(aDestination)
        else
          Job.GenerateDetailedPayeeSpendingReport(aDestination);

      finally
        FreeAndNil(Job);
      end;

    until Params.RunExit(aDestination);

  finally
    FreeAndNil(Params);
  end;
end;

//------------------------------------------------------------------------------
// TPayeeSpendingReport
//------------------------------------------------------------------------------
procedure TPayeeSpendingReport.GenerateDetailedPayeeSpendingReport(aDest : TReportDest);
var
  CLeft : Double;
begin
  LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_PAYEE_SPENDING_DETAILED]);

  //Add Headers
  AddCommonHeader(Self);

  AddJobHeader(Self, siTitle, 'DETAILED SPENDING BY PAYEE', true);
  AddjobHeader(Self, siSubTitle, 'For the period from ' +
                         bkdate2Str( Params.Fromdate) + ' to '+
                         bkDate2Str( Params.ToDate),true);
  AddjobHeader(Self,siSubTitle,'',True);

  CLeft  := GcLeft;

  if Params.NetandGstAmounts then
  begin
    if Params.ShowTotals > -1 then
    begin
      AddColAuto(Self,cLeft,      14.0,2,'Date', jtLeft);
      AddColAuto(Self,cLeft,      10.0,2,'Reference', jtLeft);
      AddColAuto(Self,cLeft,      13.0,2,'Narration', jtLeft);
      AddColAuto(Self,Cleft,      21.0,2,'Account', jtLeft);
      AddFormatColAuto(Self,cLeft,10.0,2,'$ Gross',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
      AddFormatColAuto(Self,cLeft,10.0,2,'$ GST',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
      AddFormatColAuto(Self,cLeft,0.0,2,'$ Net',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
    end
    else
    begin
      AddColAuto(Self,cLeft,      8.5,2,'Date', jtLeft);
      AddColAuto(Self,cLeft,      10.0,2,'Reference', jtLeft);
      AddColAuto(Self,cLeft,      13.0,2,'Narration', jtLeft);
      AddColAuto(Self,Cleft,      26.5,2,'Account', jtLeft);
      AddFormatColAuto(Self,cLeft,10.0,2,'$ Gross',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
      AddFormatColAuto(Self,cLeft,10.0,2,'$ GST',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
      AddFormatColAuto(Self,cLeft,0.0,2,'$ Net',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
    end;
  end
  else
  begin
    if Params.ShowTotals > -1 then
    begin
      AddColAuto(Self,cLeft,      17.0,Gcgap,'Date', jtLeft);
      AddColAuto(Self,cLeft,      11.0,Gcgap,'Reference', jtLeft);
      AddFormatColAuto(Self,cLeft,14.0,Gcgap,'Amount',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
      AddColAuto(Self,Cleft,      10.0,Gcgap,'Account', jtRight);
      AddColAuto(Self,cLeft,      20.0,Gcgap,'', jtLeft);
      AddColAuto(Self,cLeft,       0.0,Gcgap,'Narration', jtLeft);
    end
    else
    begin
      AddColAuto(Self,cLeft,       8.5,Gcgap,'Date', jtLeft);
      AddColAuto(Self,cLeft,      11.5,Gcgap,'Reference', jtLeft);
      AddFormatColAuto(Self,cLeft,14.0,Gcgap,'Amount',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
      AddColAuto(Self,cLeft,      10.0,Gcgap,'Account', jtRight);
      AddColAuto(Self,cLeft,      20.0,Gcgap ,'', jtLeft);
      AddColAuto(Self,cLeft,       0.0,Gcgap,'Narration', jtLeft);
    end;
  end;

  //Add Footers
  AddCommonFooter(Self);

  Self.OnBKPrintEx := DetailedSpendingDetail;
  Generate(aDest, Params);
end;

//------------------------------------------------------------------------------
procedure TPayeeSpendingReport.GenerateSummaryPayeeSpendingReport(aDest : TReportDest);
var
  cLeft: Double;
begin
  LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_PAYEE_SPENDING]);

  //Add Headers
  AddCommonHeader(Self);

  AddJobHeader(Self,siTitle,'SUMMARISED SPENDING BY PAYEE',true);
  AddjobHeader(Self,siSubTitle,'For the period from ' +
                                  bkdate2Str( Params.FromDate) + ' to '+
                                  bkDate2Str( Params.ToDate),true);

  {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
  cLeft := GcLeft;

  if Params.NetandGstAmounts then
  begin
    AddColAuto(Self,cLeft,      35,GcGap,'Name', jtLeft);
    AddFormatColAuto(Self,cLeft,11,5,'Payee No',jtRight,'##','',false);
    AddFormatColAuto(Self,cLeft,13,5,'$ Gross',jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets, true);
    AddFormatColAuto(Self,cLeft,13,5,'$ GST',jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets, true);
    AddFormatColAuto(Self,cLeft,13,GcGap,'$ Net',jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets, true);
  end
  else
  begin
    AddColAuto(Self,cLeft,      35,GcGap,'Name', jtLeft);
    AddFormatColAuto(Self,cLeft,10,GcGap,'Payee No',jtRight,'##','',false);
    AddFormatColAuto(Self,cLeft,20,GcGap,'Amount',jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets, true);
  end;

  //Add Footers
  AddCommonFooter(Self);

  Self.OnBKPrintEx := SpendingDetail;
  Generate(aDest, Params);
end;

//------------------------------------------------------------------------------
procedure TPayeeSpendingReport.PutNarration(Notes: string);
var
  NoteIndex, ColWidth, OldWidth : Integer;
  ColsToSkip : integer;
  NotesList  : TStringList;
  MaxNotesLines: Integer;
begin
  if Params.WrapNarration then
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
      for NoteIndex := NotesList.Count-1 downto 0 do
        if NotesList[NoteIndex] = '' then
          NoteSList.Delete(NoteIndex);

      if NotesList.Count = 0 then
      begin
        SkipColumn;
        Exit;
      end;

      ColsToSkip := CurrDetail.Count;

      NoteIndex := 0;
      repeat
        ColWidth := RenderEngine.RenderColumnWidth(CurrDetail.Count, NotesList[NoteIndex]);

        if (ColWidth < Length(NotesList[NoteIndex])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store

          while (ColWidth > 0) and (NotesList[NoteIndex][ColWidth] <> ' ') do
            Dec(ColWidth);

          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!

          NotesList.Insert(NoteIndex + 1,
                           Copy(NotesList[NoteIndex],
                           ColWidth + 1,
                           Length(NotesList[NoteIndex]) - ColWidth + 1));

          NotesList[NoteIndex] := Copy(NotesList[NoteIndex], 1, ColWidth);
        end;

        PutString( NotesList[NoteIndex]);
        Inc(NoteIndex);
        //decide if need to call renderDetailLine
        if (NoteIndex < notesList.Count) and
           (NoteIndex < MaxNotesLines) then
        begin
          RenderDetailLine(False);
          //skip all other fields (reuse ColWidth)
          for ColWidth := 1 to ColsToSkip do
            SkipColumn;
        end;
      until ( NoteIndex >= NotesList.Count) or ( NoteIndex >= MaxNotesLines);

    finally
      FreeAndNil(NotesList);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TPayeeSpendingReport.FillTempTransactionList(var aTranList : TTransaction_List);
var
  BankAccIndex : integer;
  BankAccList : TBank_Account_List;

  TranIndex : integer;
  ReadTranList : TTransaction_List;

  pTranRec : pTransaction_Rec;
  pNewTranRec : pTransaction_Rec;

  pDisRec : pDissection_Rec;
  pNewDisRec : pDissection_Rec;

  PayeeNum : Integer;
begin
  BankAccList := params.Client.clBank_Account_List;
  for BankAccIndex := BankAccList.First to BankAccList.Last do
  begin
    ReadTranList := BankAccList.Bank_Account_At(BankAccIndex).baTransaction_List;

    for TranIndex := ReadTranList.First to ReadTranList.Last do
    begin
      pTranRec := ReadTranList.Transaction_At(TranIndex);

      If (pTranRec^.txDate_Effective >= Params.Fromdate) and
         (pTranRec^.txDate_Effective <= Params.Todate) then
      begin
        pNewTranRec := aTranList.New_Transaction;

        pNewTranRec^.txType                  := pTranRec^.txType;
        pNewTranRec^.txDate_Presented        := pTranRec^.txDate_Presented;
        pNewTranRec^.txDate_Effective        := pTranRec^.txDate_Effective;
        pNewTranRec^.txAmount                := pTranRec^.txAmount;
        pNewTranRec^.txTemp_Base_Amount      := pTranRec^.txTemp_Base_Amount;
        pNewTranRec^.txGST_Class             := pTranRec^.txGST_Class;
        pNewTranRec^.txGST_Amount            := pTranRec^.txGST_Amount;
        pNewTranRec^.txHas_Been_Edited       := pTranRec^.txHas_Been_Edited;
        pNewTranRec^.txQuantity              := pTranRec^.txQuantity;
        pNewTranRec^.txCheque_Number         := pTranRec^.txCheque_Number;
        pNewTranRec^.txReference             := pTranRec^.txReference;
        pNewTranRec^.txAnalysis              := pTranRec^.txAnalysis;
        pNewTranRec^.txOrigBB                := pTranRec^.txOrigBB;
        pNewTranRec^.txOther_Party           := pTranRec^.txOther_Party;
        pNewTranRec^.txParticulars           := pTranRec^.txParticulars;
        pNewTranRec^.txGL_Narration          := pTranRec^.txGL_Narration;
        pNewTranRec^.txAccount               := pTranRec^.txAccount;
        pNewTranRec^.txCoded_By              := pTranRec^.txCoded_By;
        pNewTranRec^.txPayee_Number          := pTranRec^.txPayee_Number;
        pNewTranRec^.txLocked                := pTranRec^.txLocked;
        pNewTranRec^.txGST_Has_Been_Edited   := pTranRec^.txGST_Has_Been_Edited;
        pNewTranRec^.txUPI_State             := pTranRec^.txUPI_State;
        pNewTranRec^.txNotes                 := pTranRec^.txNotes;
        pNewTranRec^.txTax_Invoice_Available := pTranRec^.txTax_Invoice_Available;

        pDisRec := pTranRec.txFirst_Dissection;
        if pDisRec <> nil then
        begin
          if pNewTranRec^.txPayee_Number = 0 then
            PayeeNum := pDisRec^.dsPayee_Number
          else
            PayeeNum := 0;

          while pDisRec <> nil do
          begin
            if PayeeNum <> 0 then
              if PayeeNum <> pDisRec^.dsPayee_Number then
                PayeeNum := 0;

            pNewDisRec := bkdsio.New_Dissection_Rec;
            pNewDisRec^.dsAccount          := pDisRec^.dsAccount;
            pNewDisRec^.dsReference        := pDisRec^.dsReference;
            pNewDisRec^.dsAmount           := pDisRec^.dsAmount;
            pNewDisRec^.dsTemp_Base_Amount := pDisRec^.dsTemp_Base_Amount;
            pNewDisRec^.dsGST_Class        := pDisRec^.dsGST_Class;
            pNewDisRec^.dsGST_Amount       := pDisRec^.dsGST_Amount;
            pNewDisRec^.dsQuantity         := pDisRec^.dsQuantity;
            pNewDisRec^.dsGL_Narration     := pDisRec^.dsGL_Narration;
            pNewDisRec^.dsHas_Been_Edited  := pDisRec^.dsHas_Been_Edited;
            pNewDisRec^.dsGST_Has_Been_Edited := pDisRec^.dsGST_Has_Been_Edited;
            pNewDisRec^.dsPayee_Number     := pDisRec^.dsPayee_Number;
            pNewDisRec^.dsNotes            := pDisRec^.dsNotes;


            trxlist32.AppendDissection( pNewTranRec, pNewDisRec);
            pDisRec := pDisRec.dsNext;
          end;
          if PayeeNum <> 0 then
            pNewTranRec^.txPayee_Number := PayeeNum;
        end;
        aTranList.Insert_Transaction_Rec(pNewTranRec, False);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TPayeeSpendingReport.CalcPeriodStartandEndDates(aTranList : TTransaction_List;
                                                          var aPeriodStartDate, aPeriodEndDate : Integer);
var
  Day, Month, Year: Integer;
  pTranRec : pTransaction_Rec;
begin
  // First period end date will be report start + period
  aPeriodStartDate := Params.FromDate;
  aPeriodEndDate := IncDate(aPeriodStartDate, 0, Params.ShowTotals, 0);
  StDatetoDMY(aPeriodEndDate, Day, Month, Year);
  aPeriodEndDate := DMYToStDate(DaysInMonth(Month, Year, Epoch), Month, Year, Epoch);
  if (Params.ShowTotals > -1) and (aTranList.ItemCount > 0) then
  begin
    pTranRec := aTranList.Transaction_At(0);
      // check the first date...
    while (pTranRec^.txDate_Effective > aPeriodEndDate) do
    begin
      aPeriodStartDate := IncDate(aPeriodEndDate, 1, 0, 0);
      aPeriodEndDate := IncDate(aPeriodStartDate, 0, Params.ShowTotals, 0);
      StDatetoDMY(aPeriodEndDate, Day, Month, Year);
      aPeriodEndDate := DMYToStDate(DaysInMonth(Month, Year, Epoch), Month, Year, Epoch);
    end;
    if aPeriodEndDate > Params.ToDate then
      aPeriodEndDate := Params.ToDate;
  end;
end;

//------------------------------------------------------------------------------
procedure TPayeeSpendingReport.DoPayee(aPayee : TPayee);
var
  NameRendered : Boolean;
  SubTotalRendered : Boolean;
  IncludeAllDissectionLines : Boolean;
  Reference : string;
  AccDescStr : string;

  PeriodGST    : Money;
  PeriodTotal  : Money;

  PeriodStartDate : Integer;
  PeriodEndDate : Integer;

  TranList : TTransaction_List;
  TranIndex : integer;

  pAccRec : pAccount_Rec;
  pTranRec : pTransaction_Rec;
  pDisRec : pDissection_Rec;

  //----------------------------------------------------------------------------
  procedure RenderName();
  begin
    if (not NameRendered) then
    begin
      RenderTitleLine(aPayee.pdName + ' (' + IntToStr(aPayee.pdNumber) + ')');
      NameRendered := True;
    end;
  end;

  //----------------------------------------------------------------------------
  procedure RenderAmountLine(aPeriodStartDate, aPeriodEndDate : integer;
                             aName : string; aAmount : Money;
                             aAccount, aAccDesc, aNarration : string;
                             aPutMoneyDontAdd : boolean);
  begin
    if aPeriodEndDate = 0 then
      PutString(bkDate2Str( aPeriodStartDate))
    else
      PutString(bkDate2Str( aPeriodStartDate) + ' - ' + bkDate2Str( aPeriodEndDate));
    PutString(aName);

    if aPutMoneyDontAdd then
      PutMoneyDontAdd(aAmount)
    else
      PutMoney(aAmount);

    if aAccount = '' then
      SkipColumn
    else
      PutString(aAccount);

    if aAccDesc = '' then
      SkipColumn
    else
      PutString(aAccDesc);

    if aNarration = '' then
      SkipColumn
    else
      PutNarration(aNarration);
  end;

  //----------------------------------------------------------------------------
  procedure RenderAmountLinewithGST(aPeriodStartDate, aPeriodEndDate : integer;
                                    aName, aNarration, aAccount, aAccDesc : string;
                                    aPeriodGST, aPeriodTotal : Money;
                                    aPutMoneyDontAdd : boolean);
  begin
    if aPeriodEndDate = 0 then
      PutString(bkDate2Str( aPeriodStartDate))
    else
      PutString(bkDate2Str( aPeriodStartDate) + ' - ' + bkDate2Str( aPeriodEndDate));

    PutString(aName);

    if aNarration = '' then
      SkipColumn
    else
      PutNarration(aNarration);

    if aAccount = '' then
      SkipColumn
    else
      PutString(aAccount + ' ' + aAccDesc);

    if aPutMoneyDontAdd then
    begin
      PutMoneyDontAdd(aPeriodTotal);
      PutMoneyDontAdd(aPeriodGST);
      PutMoneyDontAdd(aPeriodTotal-aPeriodGST);
    end
    else
    begin
      PutMoney(aPeriodTotal);
      PutMoney(aPeriodGST);
      PutMoney(aPeriodTotal-aPeriodGST);
    end;
  end;

  //----------------------------------------------------------------------------
  procedure AddToTotals(aPeriodGST, aPeriodTotal : Money);
  begin
    PeriodGST    := PeriodGST    + aPeriodGST;
    PeriodTotal  := PeriodTotal  + aPeriodTotal;
  end;
Begin
  TranList := TTransaction_List.Create( NIL, NIL, NIL );
  try
    FillTempTransactionList(TranList);

    CalcPeriodStartandEndDates(TranList, PeriodStartDate, PeriodEndDate);

    SubTotalRendered := False;
    NameRendered := False;
    PeriodGST := 0;
    PeriodTotal := 0;

    for TranIndex := 0 to Pred(TranList.ItemCount) do
    begin
      pTranRec := TranList.Transaction_At(TranIndex);

      // show total for this period, start new period
      if (NameRendered) and
         (Params.ShowTotals > -1) and
         (pTranRec^.txDate_Effective > PeriodEndDate) then
      begin
        RenderColumnLine(2);

        if params.NetandGstAmounts then
          RenderAmountLinewithGST(PeriodStartDate, PeriodEndDate,
                                  'Sub Total', '', '', '',
                                  PeriodGST , PeriodTotal, true)
        else
          RenderAmountLine(PeriodStartDate, PeriodEndDate, 'Sub Total',
                           PeriodTotal, '', '', '', true);

        RenderDetailLine(True, siSectiontotal);
        RenderTextLine('');
        SubTotalRendered := True;
        PeriodGST := 0;
        PeriodTotal := 0;
      end;

      //move period forward even if we didn't have transactions to render a total for in the previous period
      //case 8597
      if (Params.ShowTotals > -1) and
         (pTranRec^.txDate_Effective > PeriodEndDate) then
      begin
        // move period forward so this trx is within it
        while (pTranRec^.txDate_Effective > PeriodEndDate) do
        begin
          PeriodStartDate := IncDate(PeriodEndDate, 1, 0, 0);
          PeriodEndDate := IncDate(PeriodStartDate, -1, Params.ShowTotals + 1, 0);
        end;
        if PeriodEndDate > Params.ToDate then
          PeriodEndDate := Params.ToDate;
      end;

      //see if transaction is dissected
      If (pTranRec^.txFirst_Dissection <> nil) then
      begin
        if (pTranRec.txPayee_Number = aPayee.pdNumber) then
          IncludeAllDissectionLines := true
        else
          IncludeAllDissectionLines := false;

        //show main transaction if all lines are coded to payee
        if IncludeAllDissectionLines then
        begin
          RenderName();

          if params.NetandGstAmounts then
            RenderAmountLinewithGST(PeriodStartDate, 0,
                                    GetFormattedReference(pTranRec), '', '', '',
                                    pTranRec^.txGST_Amount , pTranRec^.txTemp_Base_Amount, false)
          else
            RenderAmountLine(PeriodStartDate, 0, GetFormattedReference(pTranRec),
                             pTranRec^.txTemp_Base_Amount, '', '', '', false);

          RenderDetailLine;

          AddToTotals(pTranRec^.txGST_Amount, pTranRec^.txTemp_Base_Amount);

          SubTotalRendered := False;
        end;

        pDisRec := pTranRec^.txFirst_Dissection;
        while (pDisRec <> nil) do
        begin
          if (IncludeAllDissectionLines) or
             (pDisRec^.dsPayee_Number = aPayee.pdNumber) then
          begin
            RenderName();

            if pDisRec^.dsReference > '' then
              Reference := pDisRec^.dsReference
            else
              Reference := '/' + IntToStr( pDisRec^.dsSequence_No );

            AccDescStr := '';
            pAccRec := Params.client.clChart.FindCode(pDisRec^.dsAccount);
            If (pAccRec <> nil) then
              AccDescStr := Copy(pAccRec^.chAccount_Description, 1, 20 );

            if params.NetandGstAmounts then
              RenderAmountLinewithGST(pTranRec^.txDate_Effective, 0,
                                      Reference, pDisRec^.dsGL_Narration, pDisRec^.dsAccount, AccDescStr,
                                      pDisRec^.dsGST_Amount, pDisRec^.dsTemp_Base_Amount,
                                      IncludeAllDissectionLines)
            else
              RenderAmountLine(pTranRec^.txDate_Effective, 0, Reference,
                               pDisRec^.dsTemp_Base_Amount, pDisRec^.dsGL_Narration,
                               pDisRec^.dsAccount, AccDescStr, IncludeAllDissectionLines);

            if not IncludeAllDissectionLines then
              AddToTotals(pDisRec^.dsGST_Amount, pDisRec^.dsTemp_Base_Amount);

            RenderDetailLine;
            SubTotalRendered := False;
          end;
          pDisRec := pDisRec^.dsNext;
        end;
      end
      else
      begin
        //transaction is not dissected, see if assigned to this payee
        if pTranRec^.txPayee_Number = aPayee.pdNumber then
        begin
          RenderName();

          AccDescStr := '';
          pAccRec := Params.client.clChart.FindCode(pTranRec^.txAccount);
          If (pAccRec <> nil) then
            AccDescStr := Copy( pAccRec^.chAccount_Description, 1, 20 );

          if params.NetandGstAmounts then
            RenderAmountLinewithGST(pTranRec^.txDate_Effective, 0,
                                    GetFormattedReference(pTranRec), pTranRec^.txGL_Narration, pTranRec^.txAccount, AccDescStr,
                                    pTranRec^.txGST_Amount, pTranRec^.txTemp_Base_Amount,
                                    false)
          else
            RenderAmountLine(pTranRec^.txDate_Effective, 0, GetFormattedReference(pTranRec),
                             pTranRec^.txTemp_Base_Amount, pTranRec^.txGL_Narration,
                             pTranRec^.txAccount, AccDescStr, false);

          RenderDetailLine;

          AddToTotals(pTranRec^.txGST_Amount, pTranRec^.txTemp_Base_Amount);

          SubTotalRendered := False;
        end;
      end;
    end;
    if (NameRendered) and
       (Params.ShowTotals > -1) and
       (not SubTotalRendered) then
    begin
      RenderColumnLine(2);

      if PeriodEndDate > Params.ToDate then
        PeriodEndDate := Params.ToDate;

      if params.NetandGstAmounts then
        RenderAmountLinewithGST(PeriodStartDate, PeriodEndDate,
                                'Sub Total', '', '', '',
                                PeriodGST , PeriodTotal, true)
      else
        RenderAmountLine(PeriodStartDate, PeriodEndDate, 'Sub Total',
                         PeriodTotal, '', '', '', true);

      RenderDetailLine(True,siSectiontotal);
      RenderTextLine('');
    end;
    if (NameRendered) then
      RenderDetailSubTotal(aPayee.pdName, True, False, 'Total');
  finally
    TranList.free;
  end;
end;

//------------------------------------------------------------------------------
procedure TPayeeSpendingReport.SpendingDetail();
var
  PayeeIndex : integer;
  PayeeList : TPayee_List;
  Payee : TPayee;

  BankAccIndex : integer;
  BankAccList : TBank_Account_List;

  TranIndex : integer;
  TranList : TTransaction_List;

  pTranRec : pTransaction_Rec;
  pDisRec : pDissection_Rec;

  GSTTotal : Array of Money;
begin
  BankAccList := params.Client.clBank_Account_List;
  PayeeList   := params.Client.clPayee_List;

  Setlength(GSTTotal, PayeeList.ItemCount);
  // Initilize all payee totals to zero
  for PayeeIndex := PayeeList.First to PayeeList.Last do
  begin
    PayeeList.Payee_At(PayeeIndex).pdFields.pdTotal := 0;
    GSTTotal[PayeeIndex] := 0;
  end;

  // Calculate Payee totals using transaction and disections
  for BankAccIndex := BankAccList.First to BankAccList.Last do
  begin
    TranList := BankAccList.Bank_Account_At(BankAccIndex).baTransaction_List;

    for TranIndex := TranList.First to TranList.Last do
    begin
      pTranRec := TranList.Transaction_At(TranIndex);

      if ( pTranRec^.txDate_Effective >= Params.Fromdate ) and
         ( pTranRec^.txDate_Effective <= Params.Todate ) then
      begin
        //is a payee number assigned to the transaction
        if ( pTranRec^.txPayee_Number <> 0 ) then
        begin
          Payee := PayeeList.Find_Payee_Number_and_Index(pTranRec^.txPayee_Number, PayeeIndex);

          if Assigned(Payee) then
          begin
            Payee.pdFields.pdTotal := Payee.pdFields.pdTotal + pTranRec^.txTemp_Base_Amount;
            GSTTotal[PayeeIndex] := GSTTotal[PayeeIndex] + pTranRec^.txGST_Amount;
          end;
        end
        else
        begin
          pDisRec := pTranRec^.txFirst_Dissection;
          if (pDisRec <> nil) then
          begin
            while pDisRec <> nil do
            begin
              if ( pDisRec^.dsPayee_number <> 0) then
              begin
                Payee := PayeeList.Find_Payee_Number( pDisRec^.dsPayee_Number );

                if Assigned( Payee ) then
                begin
                  Payee.pdFields.pdTotal := Payee.pdFields.pdTotal + pDisRec^.dsTemp_Base_Amount;
                  GSTTotal[PayeeIndex] := GSTTotal[PayeeIndex] + pDisRec^.dsGST_Amount;
                end;
              end;
              pDisRec := pDisRec^.dsNext;
            end;
          end;
        end;
      end;
    end;
  end;

  for PayeeIndex := PayeeList.First to PayeeList.Last do
  begin
    Payee := PayeeList.Payee_At(PayeeIndex);
    if ShowPayeeOnReport( Payee.pdFields.pdNumber) then
    begin
      if params.NetandGstAmounts then
      begin
        PutString(Payee.pdFields.pdName);
        PutCurrency(Payee.pdFields.pdNumber);
        PutMoney(Payee.pdFields.pdTotal);
        PutMoney(GSTTotal[PayeeIndex]);
        PutMoney(Payee.pdFields.pdTotal - GSTTotal[PayeeIndex]);
        RenderDetailLine;
      end
      else
      begin
        PutString(Payee.pdFields.pdName);
        PutCurrency(Payee.pdFields.pdNumber);
        PutMoney(Payee.pdFields.pdTotal);
        RenderDetailLine;
      end;
    end;
  end;
  RenderDetailGrandTotal('');

  Setlength(GSTTotal, 0);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TPayeeSpendingReport.DetailedSpendingDetail();
var
  PayeeIndex : LongInt;
  Payee : TPayee;
begin
  //see if this payee should be included on the report
  for PayeeIndex := MyClient.clPayee_List.First to MyClient.clPayee_List.Last do
  begin
    Payee := MyClient.clPayee_List.Payee_At(PayeeIndex);
    if ShowPayeeOnReport(Payee.pdFields.pdNumber) then
    begin
      DoPayee(Payee);
    end;
  end;

  RenderDetailGrandTotal('Grand Total');
end;

//------------------------------------------------------------------------------
function TPayeeSpendingReport.ShowPayeeOnReport(aPayeeNo : integer) : boolean;
var
  RangeIndex : integer;
  PayeeRange : TPayeeRange;
begin
  result := true;

  if Params.ShowAllCodes then
    exit
  else
  begin
    for RangeIndex := Low(Params.RangesArray) to High(Params.RangesArray) do
    begin
      PayeeRange := Params.RangesArray[RangeIndex];

      if (PayeeRange.ToCode <> 0) then
      begin
        if (aPayeeNo >= PayeeRange.FromCode) and
           (aPayeeNo <= PayeeRange.ToCode) then
          Exit;
      end
      else
        //special case, if only a from code is specified then match
        //on the specific code
        if ( PayeeRange.FromCode <> 0) and ( PayeeRange.FromCode = aPayeeNo) then
          Exit;
    end;
  end;

  result := false;
end;

end.
