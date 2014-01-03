unit RptContractorPayee;

interface

uses
   ReportDefs, UBatchBase;

procedure DoTaxablePaymentsReport(Destination : TReportDest; RptBatch :TReportBase = nil);

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
  TaxablePaymentsRptDlg, MoneyDef,
  RptParams,
  PayeeObj, clObj32, balist32, trxList32, bkbaio, bktxio, bkdsio, stdate, bkconst,
  GSTCalc32,
  ForexHelpers,
  UserReportSettings,
  Graphics,
  Variants;

type
  TTaxablePaymentsReport = class(TBKReport)
  public
    params : TPayeeParameters;

    function ShowPayeeOnReport( aPayeeNo : integer) : boolean;
  end;

  PPayeeData = ^TPayeeData;
  TPayeeData = record
    Payee: TPayee;
    NoABNWithholdingTax: Money;
    TotalGST: Money;
    GrossAmount: Money;
  end;

function FindABNAccountCode: String;
var
  Index: Integer;
begin
  for Index := 0 to Length(MyClient.clFields.clBAS_Field_Number) - 1 do
  begin
    if MyClient.clFields.clBAS_Field_Number[Index] = bfW4 then
    begin
      Result := MyClient.clFields.clBAS_Field_Account_Code[Index];

      Break; 
    end;
  end;
end;
  
procedure SumPayeeTotals(Params: TPayeeParameters; var PayeeDataList: array of TPayeeData);

  function GetPayeeData(PayeeNumber: Integer): PPayeeData;
  var
    Index: Integer;
  begin
    Result := nil;
    
    for Index := 0 to Length(PayeeDataList) - 1 do
    begin
      if PayeeDataList[Index].Payee.pdNumber = PayeeNumber then
      begin
        Result := @PayeeDataList[Index];

        Break;
      end;
    end;
  end;

var
  AccountIndex: Integer;
  TransactionIndex: Integer;
  BankAccount: TBank_Account;
  PayeeData: PPayeeData;
  Transaction: pTransaction_Rec;
  Dissection: pDissection_Rec;
  ABNAccount: String;
begin
  ABNAccount := FindABNAccountCode;

  for AccountIndex := 0 to MyClient.clBank_Account_List.ItemCount -1 do
  begin
    BankAccount := MyClient.clBank_Account_List.Bank_Account_At( AccountIndex );

    for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount -1 do
    begin
      Transaction := BankAccount.baTransaction_List.Transaction_At(TransactionIndex);

      if (Transaction^.txDate_Effective >= Params.FromDate) and (Transaction^.txDate_Effective <= Params.ToDate ) then
      begin
        //is a payee number assigned to the transaction
        if (Transaction^.txPayee_Number <> 0 ) then
        begin
          PayeeData := GetPayeeData(Transaction^.txPayee_Number);

          if (Transaction^.txFirst_Dissection <> nil) then
          begin
            //see if dissection lines should be part of total
            Dissection := Transaction^.txFirst_Dissection;

            while Dissection <> nil do
            begin
              PayeeData.TotalGST := PayeeData.TotalGST + Dissection.dsGST_Amount;

              if (ABNAccount <> '') and (Dissection.dsAccount = ABNAccount) then
              begin
                PayeeData.NoABNWithholdingTax := PayeeData.NoABNWithholdingTax + (Dissection^.Local_Amount * -1);
              end
              else
              begin
                PayeeData.GrossAmount := PayeeData.GrossAmount + Dissection^.Local_Amount;
              end;

              Dissection := Dissection^.dsNext;
            end;          
          end
          else
          begin
            if Assigned(PayeeData) then
            begin
              PayeeData.TotalGST := PayeeData.TotalGST + Transaction.txGST_Amount;

              if (ABNAccount <> '') and (Transaction.txAccount = ABNAccount) then
              begin
                PayeeData.NoABNWithholdingTax := PayeeData.NoABNWithholdingTax + (Transaction^.Local_Amount * -1);
              end
              else
              begin
                PayeeData.GrossAmount := PayeeData.GrossAmount + Transaction^.Local_Amount;
              end;
            end;          
          end;
        end
        else
        begin
          if (Transaction^.txFirst_Dissection <> nil) then
          begin
             //see if dissection lines should be part of total
            Dissection := Transaction^.txFirst_Dissection;

            while Dissection <> nil do
            begin
              if (Dissection^.dsPayee_Number <> 0 ) then
              begin
                PayeeData := GetPayeeData(Dissection^.dsPayee_Number);
                
                if Assigned(PayeeData) then
                begin
                  PayeeData.TotalGST := PayeeData.TotalGST + Dissection^.dsGST_Amount;

                  if (ABNAccount <> '') and (Dissection.dsAccount = ABNAccount) then
                  begin
                    PayeeData.NoABNWithholdingTax := PayeeData.NoABNWithholdingTax + (Dissection^.Local_Amount * -1);
                  end
                  else
                  begin
                    PayeeData.GrossAmount := PayeeData.GrossAmount + Dissection^.Local_Amount;
                  end;
                end;
              end;

              Dissection := Dissection^.dsNext;
            end;          
          end;        
        end;
      end;
    end;
  end; //with transaction^
end;

procedure DetailedTaxablePaymentsDetail(Sender : TObject);

  procedure RenderPayeeTransactions(Payee: TPayee);
    
    function SumABN(Transaction: pTransaction_Rec; ABNAccountCode: String): Money;
    var
      Dissection: pDissection_Rec;
    begin
      Result := 0;

      if ABNAccountCode <> '' then
      begin
        Dissection := Transaction.txFirst_Dissection;

        while Dissection <> nil do
        begin
          if (Dissection.dsAccount = ABNAccountCode) then
          begin
            Result := Result + Dissection.Local_Amount;
          end;

          Dissection := Dissection.dsNext;
        end;
      end;
    end;

    procedure WrapNarration(Notes: string);
    const
      NARRATION_COLUMN = 3;

    var
      j, ColWidth, OldWidth : Integer;
      NotesList  : TStringList;
      MaxNotesLines: Integer;
    begin
      with TTaxablePaymentsReport(Sender), params do
      begin
       if WrapColumnText then
         MaxNotesLines := 10
       else
         MaxNotesLines := 1;

       if (Notes = '') then
       begin
         SkipColumn;
       end
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
             begin
               NoteSList.Delete(j);
             end
             else
             begin
               Inc(j);
             end;
           end;

           if NotesList.Count = 0 then
           begin
             SkipColumn;

             Exit;
           end;

           j := 0;

           repeat
             ColWidth := RenderEngine.RenderColumnWidth(NARRATION_COLUMN, NotesList[j]);

             if (ColWidth < Length(NotesList[j])) then
             begin
               //line needs to be split
               OldWidth := ColWidth; //store

               while (ColWidth > 0) and (NotesList[j][ColWidth] <> ' ') do
               begin
                 Dec(ColWidth);
               end;

               if (ColWidth = 0) then
               begin
                 ColWidth := OldWidth; //unexpected!
               end;
               
               NotesList.Insert(j + 1, Copy(NotesList[j], ColWidth + 1, Length(NotesList[j]) - ColWidth + 1));

               NotesList[j] := Copy(NotesList[j], 1, ColWidth);
             end;

             PutString(NotesList[ j]);

             Inc(j);

             //decide if need to call renderDetailLine
             if (j < notesList.Count) and (j < MaxNotesLines) then
             begin
               SkipColumn;
               SkipColumn;
               SkipColumn;

               RenderDetailLine(False);

               SkipColumn;
               SkipColumn;
               SkipColumn;
             end;
           until (j >= NotesList.Count) or (j >= MaxNotesLines);
         finally
           NotesList.Free;
         end;
       end;
    end;
  end;
  
  var
    BankAccount: TBank_Account;
    Transaction: pTransaction_Rec;
    Dissection: pDissection_Rec;
    ABNAccountCode: String;
    BankIndex: Integer;
    TransactionIndex: Integer;
    TransGSTAmount: Money;
    Reference: String;
    ChartAccount: pAccount_Rec;
    ABNAmount: Money;
  begin
    ABNAccountCode := FindABNAccountCode;
    
    with TTaxablePaymentsReport(Sender)  do
    begin
      for BankIndex := 0 to MyClient.clBank_Account_List.ItemCount - 1 do
      begin
        BankAccount := MyClient.clBank_Account_List.Bank_Account_At(BankIndex);

        for TransactionIndex := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
        begin
          Transaction := BankAccount.baTransaction_List.Transaction_At(TransactionIndex);

          if (Transaction.txDate_Effective >= Params.FromDate) and (Transaction.txDate_Effective <= Params.ToDate) then
          begin
            if Transaction.txFirst_Dissection <> nil then
            begin
              Dissection := Transaction.txFirst_Dissection;

              while Dissection <> nil do
              begin
                if (Transaction.txPayee_Number = Payee.pdNumber) or (Dissection.dsPayee_Number = Payee.pdNumber) then
                begin
                  PutString(bkDate2Str(Transaction.txDate_Effective));

                  if Dissection.dsReference > '' then
                  begin
                    PutString(Dissection.dsReference);
                  end
                  else
                  begin
                    PutString(Format('/%s', [IntToStr(Dissection.dsSequence_No)]));
                  end;
                         
                  PutString(Dissection.dsAccount);

                  if TTaxablePaymentsReport(Sender).Params.WrapColumnText then
                  begin
                    WrapNarration(Dissection.dsGL_Narration);
                  end
                  else
                  begin
                    PutString(Dissection.dsGL_Narration);
                  end;

                  if Dissection.dsAccount = ABNAccountCode then
                  begin
                    PutMoney(Dissection.Local_Amount * -1);
                    PutMoney(Dissection.dsGST_Amount);

                    SkipColumn;
                  end
                  else
                  begin
                    SkipColumn;

                    PutMoney(Dissection.dsGST_Amount);
                    PutMoney(Dissection.Local_Amount);
                  end;
                  
                  RenderDetailLine;
                end;
                
                Dissection := Dissection.dsNext;
              end;
            end
            else
            begin
              if Transaction.txPayee_Number = Payee.pdNumber then
              begin
                PutString(bkDate2Str(Transaction.txDate_Effective));

                PutString(GetFormattedReference(Transaction));

                PutString(Transaction.txAccount);

                if TTaxablePaymentsReport(Sender).Params.WrapColumnText then
                begin
                  WrapNarration(Transaction.txGL_Narration);
                end
                else
                begin
                  PutString(Transaction.txGL_Narration);
                end;

                if Transaction.txAccount = ABNAccountCode then
                begin
                  PutMoney(Transaction.Local_Amount * -1);
                  PutMoney(Transaction.txGST_Amount);

                  SkipColumn;
                end
                else
                begin
                  SkipColumn;

                  PutMoney(Transaction.txGST_Amount);
                  PutMoney(Transaction.Local_Amount);
                end;

                RenderDetailLine;              
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  
var
  i,b,t : LongInt;
  Payee: TPayee;
  Index: Integer;
begin
  with TTaxablePaymentsReport(Sender)  do
  begin
    //see if this payee should be included on the report
    for Index := 0 to MyClient.clPayee_List.ItemCount - 1 do
    begin  
      Payee := MyClient.clPayee_List.Payee_At(Index); 

      if Payee.pdFields.pdContractor and ShowPayeeOnReport(Payee.pdFields.pdNumber) then
      begin
        RenderTitleLine(Payee.pdFields.pdName+ ' (' + IntToStr(Payee.pdFields.pdNumber) + ')');

        RenderPayeeTransactions(Payee);

        RenderDetailSubTotal('');
      end;
    end;

    RenderDetailGrandTotal(''); 
  end; 
end;

procedure WriteColumnValue(Report: TBKReport; ColumnId: Integer; Value: Variant);
begin
  {Column < then 7 are all text columns.  The remaining are money columns}
  if ColumnId < 7 then
  begin
    Report.PutString(Value);
  end
  else
  begin
    Report.PutMoney(Value, False);
  end;
end;

procedure TaxablePaymentsDetail(Sender : TObject);
var
  i,b,t : LongInt;
  PayeeDataList: array of TPayeeData;
  PayeeData: TPayeeData;
  Payee: TPayee;
  Index: Integer;
  RecordLines: TBKReportRecordLines;
Begin
  with TTaxablePaymentsReport(Sender)  do
  begin
    SetLength(PayeeDataList, MyClient.clPayee_List.ItemCount);

    for Index := 0 to MyClient.clPayee_List.ItemCount - 1 do
    begin
      PayeeDataList[Index].Payee := MyClient.clPayee_List.Payee_At(Index);
      PayeeDataList[Index].NoABNWithholdingTax := 0;
      PayeeDataList[Index].TotalGST := 0;
      PayeeDataList[Index].GrossAmount := 0; 
    end;

    SumPayeeTotals(Params, PayeeDataList);

    RecordLines := TBKReportRecordLines.Create(TTaxablePaymentsReport(Sender), WriteColumnValue);

    //see if this payee should be included on the report
    for i := 0 to Length(PayeeDataList) -1 do
    begin
      Payee := PayeeDataList[I].Payee;

      if Payee.pdFields.pdContractor and ShowPayeeOnReport(Payee.pdFields.pdNumber) then
      begin
        PayeeData := PayeeDataList[I];

        RecordLines.BeginUpdate;
                                      
        RecordLines.AddColumnText(0, Payee.pdFields.pdABN, Params.WrapColumnText);
        RecordLines.AddColumnText(1, Payee.pdFields.pdPhone_Number, Params.WrapColumnText);
        RecordLines.AddColumnText(2, Payee.pdFields.pdName, Params.WrapColumnText);
        RecordLines.AddColumnText(3, Payee.pdFields.pdSurname, Params.WrapColumnText);
        RecordLines.AddColumnText(4, Payee.pdFields.pdGiven_Name, Params.WrapColumnText);
        RecordLines.AddColumnText(5, Payee.pdFields.pdOther_Name, Params.WrapColumnText);
        RecordLines.AddColumnText(6, [Payee.pdFields.pdAddress, Payee.pdFields.pdTown, Format('%s %s',[Payee.pdFields.pdState, Payee.pdFields.pdPost_Code])], Params.WrapColumnText);
        RecordLines.AddColumnValue(7, PayeeData.NoABNWithholdingTax);
        RecordLines.AddColumnValue(8, PayeeData.TotalGST);
        RecordLines.AddColumnValue(9, PayeeData.GrossAmount);

        RecordLines.EndUpdate;

        {Create a seperating blank line}
        RenderTextLine('');
      end;
    end;
  end;
end;

procedure GenerateDetailedTaxablePaymentsReport(Dest: TReportDest; Job: TTaxablePaymentsReport);
var
  CLeft : Double;
begin
  Job.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_Taxable_Payments_Detailed]);
         
  Job.UserReportSettings.s7Temp_Font_Scale_Factor := 1.0;
    
  //Add Headers
  AddCommonHeader(Job);

  AddJobHeader(Job,siTitle,'Taxable Payments Report (Detailed)',true);
  AddjobHeader(Job,siSubTitle, Format('For the period from %s to %s', [bkdate2Str(Job.Params.Fromdate), bkDate2Str(Job.Params.ToDate)]), True);
  AddjobHeader(Job,siSubTitle,'',True);

  CLeft  := GcLeft;

  AddColAuto(Job, cLeft, 8, Gcgap,'Date', jtLeft);
  AddColAuto(Job, cLeft, 8, Gcgap,'Reference', jtLeft);
  AddColAuto(Job, cLeft, 10,Gcgap,'Account', jtLeft);
  AddColAuto(Job, cLeft, 34, Gcgap,'Narration', jtLeft);
  AddFormatColAuto(Job,cLeft,14, Gcgap,'No ABN Withholding Tax',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
  AddFormatColAuto(Job,cLeft,12, Gcgap,'Total GST',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
  AddFormatColAuto(Job,cLeft,14, Gcgap,'Gross Amount Paid (including GST and any tax withheld)',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);

  //Add Footers
  AddCommonFooter(Job);

  Job.OnBKPrint := DetailedTaxablePaymentsDetail;

  Job.Columns.WrapCaptions := True;

  Job.Generate(Dest,Job.params);
end;

procedure GenerateSummaryTaxablePaymentsReport(Dest: TReportDest; Job: TTaxablePaymentsReport);
var
  CLeft : Double;
begin
  Job.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_Taxable_Payments]);
         
  Job.UserReportSettings.s7Temp_Font_Scale_Factor := 0.9;
  Job.UserReportSettings.s7Orientation := BK_LANDSCAPE;
    
  //Add Headers
  AddCommonHeader(Job);

  AddJobHeader(Job,siTitle,'Taxable Payments Report (Summarised)',true);
  AddjobHeader(Job,siSubTitle, Format('For the period from %s to %s', [bkdate2Str(Job.Params.Fromdate), bkDate2Str(Job.Params.ToDate)]), True);
  AddjobHeader(Job,siSubTitle,'',True);

  CLeft  := GcLeft;

  AddColAuto(Job,cLeft,      7,Gcgap,'ABN', jtLeft);
  AddColAuto(Job,cLeft,      6,Gcgap,'Payee Phone', jtLeft);
  AddColAuto(Job,cLeft,      15,Gcgap,'Payee Name', jtLeft);
  AddColAuto(Job,cLeft,      18,Gcgap,'Payee Surname', jtLeft);
  AddColAuto(Job,cLeft,      9,Gcgap,'Given Name', jtLeft);
  AddColAuto(Job,cLeft,      9,Gcgap,'Other Name', jtLeft);
  AddColAuto(Job,cLeft,      14,Gcgap,'Payee Address', jtLeft);
  AddFormatColAuto(Job,cLeft,7,Gcgap,'No ABN Withholding Tax',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
  AddFormatColAuto(Job,cLeft,7,Gcgap,'Total GST',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);
  AddFormatColAuto(Job,cLeft,8,Gcgap,'Gross Amount Paid (including GST and any tax withheld)',jtRight,'#,##0.00;(#,##0.00);-', MyClient.FmtMoneyStrBrackets, true);

  //Add Footers
  AddCommonFooter(Job);

  Job.OnBKPrint := TaxablePaymentsDetail;

  Job.Columns.WrapCaptions := True;

  Job.Generate(Dest,Job.params);
end;

procedure DoTaxablePaymentsReport(Destination : TReportDest; RptBatch: TReportBase = nil);
var
   Job   : TTaxablePaymentsReport;
   Params : TPayeeParameters;
   ISOCodes: string;
begin
 //set defaults

  Params := TPayeeParameters.Create(ord(Report_Taxable_Payments), MyClient,Rptbatch,DYear);

  with params do
  begin
    try
      Params.FromDate := 0;
      Params.ToDate := 0;

      repeat
        if not GetPRParameters(Params) then
        begin
          Exit;
        end;

        if RunBtn = BTN_SAVE then
        begin
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

        //Check Forex - this won't stop the report running if there are missing exchange rates
        MyClient.HasExchangeRates(ISOCodes, params.FromDate, params.ToDate, True, True);

        Job := TTaxablePaymentsReport.Create(rptOther);
        try
          //set parameters
          Job.Params := Params;
                 
          if SummaryReport then
          begin
            GenerateSummaryTaxablePaymentsReport(Destination, Job);
          end
          else
          begin
            GenerateDetailedTaxablePaymentsReport(Destination, Job);
          end;
        finally
          Job.Free;
        end;

        //Destination := rdNone;
      until Params.RunExit(Destination);
    finally
      Params.Free;
    end;
  end;
end;
{ TTaxablePaymentsReport }

function TTaxablePaymentsReport.ShowPayeeOnReport(aPayeeNo: integer): boolean;
var
  i : integer;
begin
  Result := True;

  if Params.ShowAllCodes then
  begin
    Exit;
  end
  else
  begin
    with params do
    begin
      for i := Low( RangesArray) to High( RangesArray) do
      begin
        with RangesArray[i] do
        begin
          if ( ToCode <> 0) then
          begin
            if ( aPayeeNo >= FromCode) and ( aPayeeNo <= ToCode) then
            begin
              Exit;
            end;
          end
          else
          begin
            if ( FromCode <> 0) and ( FromCode = aPayeeNo) then
            begin
              //special case, if only a from code is specified then match
              //on the specific code
              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

  Result := False;
end;

end.
