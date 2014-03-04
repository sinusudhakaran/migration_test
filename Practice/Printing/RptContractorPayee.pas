unit RptContractorPayee;

//------------------------------------------------------------------------------
interface

uses
  ReportDefs,
  UBatchBase;

//------------------------------------------------------------------------------
procedure DoTaxablePaymentsReport(Destination : TReportDest; RptBatch :TReportBase = nil);

//------------------------------------------------------------------------------
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
  TaxablePaymentsRptDlg,
  MoneyDef,
  RptParams,
  PayeeObj,
  clObj32,
  balist32,
  trxList32,
  bkbaio,
  bktxio,
  bkdsio,
  stdate,
  bkconst,
  GSTCalc32,
  ForexHelpers,
  UserReportSettings,
  Graphics,
  Variants,
  ATOFixedWidthFileExtract,
  CountryUtils,
  WebUtils,
  BaUtils,
  DateUtils,
  ATOExportMandatoryDataDlg,
  LogUtil,
  InfoMoreFrm,
  YesNoDlg;

const
  UnitName = 'RptContractorPayee';

type
  //----------------------------------------------------------------------------
  TTaxablePaymentsReport = class(TBKReport)
  protected
    function ValidateATOMandatoryData() : boolean;
  public
    params : TPayeeParameters;
    procedure DoATOExtractCode(aFileName : string);
    function ShowPayeeOnReport( aPayeeNo : integer) : boolean;
  end;

  //----------------------------------------------------------------------------
  PPayeeData = ^TPayeeData;
  TPayeeData = record
    Payee: TPayee;
    NoABNWithholdingTax: Money;
    TotalGST: Money;
    GrossAmount: Money;
  end;

//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
procedure SumPayeeTotals(Params: TPayeeParameters; var PayeeDataList: array of TPayeeData);

  //----------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
procedure DetailedTaxablePaymentsDetail(Sender : TObject);

  //----------------------------------------------------------------------------
  procedure RenderPayeeTransactions(Payee: TPayee);

    //--------------------------------------------------------------------------
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

    //--------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
procedure DoTaxablePaymentsReport(Destination : TReportDest; RptBatch: TReportBase = nil);
var
  Job      : TTaxablePaymentsReport;
  Params   : TPayeeParameters;
  ISOCodes : string;
  ATODefaultFileName : string;
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
          Params.CustomFileFormats.Clear;

          if Assigned(AdminSystem) then
          begin
            ATODefaultFileName := 'TPAR_' + MyClient.clFields.clCode + '_' +
                                  Date2Str(GetYearEndDate(MyClient.clFields.clReport_Start_Date), 'dd-mm-yyyy');
            Params.CustomFileFormats.AddCustomFormat('ATO Extract','ATO Extact File (C01)',ATODefaultFileName,'.C01',Job.DoATOExtractCode, true);
          end;

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

//------------------------------------------------------------------------------
function TTaxablePaymentsReport.ValidateATOMandatoryData(): boolean;
var
  ErrorStrings : TArrOfStr;
  PayerABN : string;
  PayerBranch : string;
  PayeeIndex : integer;
  Payee : TPayee;

  //----------------------------------------------------------------------------
  procedure AddError(aError : string);
  begin
    SetLength(ErrorStrings, Length(ErrorStrings) + 1);
    ErrorStrings[High(ErrorStrings)] := aError;
  end;

begin
  SetLength(ErrorStrings,0);

  // Supplier Data
  if (Length(AdminSystem.TPR_Supplier_Detail.As_pRec.srABN) < 11) then
    AddError('Supplier {ABN Number} from System | Practice Details | TPR Supplier Details');

  if (Length(AdminSystem.fdFields.fdPractice_Name_for_Reports) = 0) then
    AddError('Supplier {Name} from System | Practice Details | Details');

  if (Length(AdminSystem.TPR_Supplier_Detail.As_pRec.srContactName) = 0) then
    AddError('Supplier {Contact Name} from Other Functions | Client Details | TPR Payer Details');

  if (Length(AdminSystem.TPR_Supplier_Detail.As_pRec.srContactPhone) = 0) then
    AddError('Supplier {Contact Phone} from Other Functions | Client Details | TPR Payer Details');

  if (Length(AdminSystem.TPR_Supplier_Detail.As_pRec.srStreetAddress1) = 0) then
    AddError('Supplier {Street Address} from System | Practice Details | TPR Supplier Details');

  if (Length(AdminSystem.TPR_Supplier_Detail.As_pRec.srSuburb) = 0) then
    AddError('Supplier {Town/Suburb} from System | Practice Details | TPR Supplier Details');

  if (AdminSystem.TPR_Supplier_Detail.As_pRec.srStateId < MAX_STATE) and
     (Length(AdminSystem.TPR_Supplier_Detail.As_pRec.srPostCode) = 0) then
    AddError('Supplier {Postcode} from System | Practice Details | TPR Supplier Details');

  if (AdminSystem.TPR_Supplier_Detail.As_pRec.srStateId = MAX_STATE) and
     (Length(AdminSystem.TPR_Supplier_Detail.As_pRec.srCountry) = 0) then
    AddError('Supplier {Country} from System | Practice Details | TPR Supplier Details');

  // Payer Data
  SplitABNandBranchFromGSTNumber(MyClient.clFields.clGST_Number,
                                 PayerABN,
                                 PayerBranch);
  if (Length(PayerABN) < 11) then
    AddError('Payer {Australian Business No} from Other Functions | GST Set Up | Details');

  if (Length(MyClient.clFields.clName) = 0) then
    AddError('Payer {Client Name} from Other Functions | Client Details');

  if (Length(MyClient.clTPR_Payee_Detail.As_pRec.prAddressLine1) = 0) then
    AddError('Payer {Street Address} from Other Functions | Client Details | TPR Payer Details');

  if (Length(MyClient.clTPR_Payee_Detail.As_pRec.prSuburb) = 0) then
    AddError('Payer {Town/Suburb} from Other Functions | Client Details | TPR Payer Details');

  if (MyClient.clTPR_Payee_Detail.As_pRec.prStateId < MAX_STATE) and
     (Length(MyClient.clTPR_Payee_Detail.As_pRec.prPostCode) = 0) then
    AddError('Payer {Postcode} from Other Functions | Client Details | TPR Payer Details');

  if (MyClient.clTPR_Payee_Detail.As_pRec.prStateId = MAX_STATE) and
     (Length(MyClient.clTPR_Payee_Detail.As_pRec.prCountry) = 0) then
    AddError('Payer {Country} from Other Functions | Client Details | TPR Payer Details');

  // Payee Data
  for PayeeIndex := 0 to MyClient.clPayee_List.ItemCount - 1 do
  begin
    Payee := MyClient.clPayee_List.Payee_At(PayeeIndex);

    if (not Payee.pdFields.pdIsIndividual) and
       (Length(Payee.pdFields.pdBusinessName) = 0) then
      AddError('Payee No.' + inttostr(Payee.pdFields.pdNumber) + ': {Business Name} from Other Functions | Payees');

    if (Payee.pdFields.pdIsIndividual) and
       (Length(Payee.pdFields.pdGiven_Name) = 0) then
      AddError('Payee No.' + inttostr(Payee.pdFields.pdNumber) + ': {Given Name} from Other Functions | Payees');

    if (Payee.pdFields.pdIsIndividual) and
       (Length(Payee.pdFields.pdSurname) = 0) then
      AddError('Payee No.' + inttostr(Payee.pdFields.pdNumber) + ': {Surname} from Other Functions | Payees');

    if (Length(Payee.pdFields.pdAddress) = 0) then
      AddError('Payee No.' + inttostr(Payee.pdFields.pdNumber) + ': {Address} from Other Functions | Payees');

    if (Length(Payee.pdFields.pdTown) = 0) then
      AddError('Payee No.' + inttostr(Payee.pdFields.pdNumber) + ': {Town} from Other Functions | Payees');

    if (Payee.pdFields.pdStateId < MAX_STATE) and
       (Length(Payee.pdFields.pdPost_Code) = 0) then
      AddError('Payee No.' + inttostr(Payee.pdFields.pdNumber) + ': {Postcode} from Other Functions | Payees');

    if (Payee.pdFields.pdStateId = MAX_STATE) and
       (Payee.pdFields.pdCountry = '') then
      AddError('Payee No.' + inttostr(Payee.pdFields.pdNumber) + ': {Country} from Other Functions | Payees');
  end;

  Result := (Length(ErrorStrings) = 0);
  if not Result then
    ShowATOWarnings(ErrorStrings);
end;

//------------------------------------------------------------------------------
procedure TTaxablePaymentsReport.DoATOExtractCode(aFileName : string);
Const
  RUN_TYPE = 'T';
  ThisMethodName = 'DoATOExtractCode';
var
  ATOExtract : TATOFixedWidthFileExtract;
  PayeeIndex : integer;
  Payee : TPayee;
  SupplierStateCode : string;
  SupplierStateDesc : string;
  PayerABN : string;
  PayerBranch : string;
  PayerStateCode : string;
  PayerStateDesc : string;
  EndOfReportDate : TDateTime;
  PayeeDataList: array of TPayeeData;
  PayerContactName : string;
  PayerContactPhone : string;
  PayerContactEmail : string;
  Msg : string;
  PayeeAmendmentIndicator : char;
begin
  ATOExtract := TATOFixedWidthFileExtract.create();
  try
    if not ValidateATOMandatoryData() then
      Exit;

    PayeeAmendmentIndicator := 'O';
    if not MyClient.clTPR_Payee_Detail.As_pRec.prFirstTimeTPRATOExtractDone then
    begin
      if AskYesNo('ATO Extract', 'Has the TPAR already been lodged with the ATO for this period?', DLG_NO, 0) = DLG_YES then
        PayeeAmendmentIndicator := 'A';
    end;

    ATOExtract.OpenATOFile(aFileName);
    try
      // Pre Calculated Values
      //------------------------------------------------------------------------
      EndOfReportDate := StDateToDateTime(Params.ToDate);
      GetAustraliaStateFromIndex(AdminSystem.TPR_Supplier_Detail.As_pRec.srStateId,
                                 SupplierStateCode,
                                 SupplierStateDesc);
      SplitABNandBranchFromGSTNumber(MyClient.clFields.clGST_Number,
                                     PayerABN,
                                     PayerBranch);
      GetAustraliaStateFromIndex(MyClient.clTPR_Payee_Detail.As_pRec.prStateId,
                                 PayerStateCode,
                                 PayerStateDesc);
      // Work Out Totals for Payees
      SetLength(PayeeDataList, MyClient.clPayee_List.ItemCount);
      for PayeeIndex := 0 to MyClient.clPayee_List.ItemCount - 1 do
      begin
        PayeeDataList[PayeeIndex].Payee := MyClient.clPayee_List.Payee_At(PayeeIndex);
        PayeeDataList[PayeeIndex].NoABNWithholdingTax := 0;
        PayeeDataList[PayeeIndex].TotalGST := 0;
        PayeeDataList[PayeeIndex].GrossAmount := 0;
      end;
      SumPayeeTotals(Params, PayeeDataList);

      if MyClient.clTPR_Payee_Detail.As_pRec.prUsePracticeTPRSupplierDetails then
      begin
        PayerContactName  := AdminSystem.TPR_Supplier_Detail.As_pRec.srContactName;
        PayerContactPhone := AdminSystem.TPR_Supplier_Detail.As_pRec.srContactPhone;
        PayerContactEmail := AdminSystem.fdFields.fdPractice_EMail_Address;
      end
      else
      begin
        PayerContactName  := MyClient.clFields.clContact_Name;
        PayerContactPhone := MyClient.clFields.clPhone_No;
        PayerContactEmail := MyClient.clFields.clCustom_Contact_EMail_Address;
      end;

      // Report Data Write
      //------------------------------------------------------------------------
      ATOExtract.WriteSupplierDataRecord1(AdminSystem.TPR_Supplier_Detail.As_pRec.srABN,
                                          RUN_TYPE,
                                          EndOfReportDate);
      ATOExtract.WriteSupplierDataRecord2(AdminSystem.fdFields.fdPractice_Name_for_Reports,
                                          AdminSystem.TPR_Supplier_Detail.As_pRec.srContactName,
                                          AdminSystem.TPR_Supplier_Detail.As_pRec.srContactPhone,
                                          '', // Supplier fax number not used
                                          AdminSystem.fdFields.fdBankLink_Code);
      ATOExtract.WriteSupplierDataRecord3(AdminSystem.TPR_Supplier_Detail.As_pRec.srStreetAddress1,
                                          AdminSystem.TPR_Supplier_Detail.As_pRec.srStreetAddress2,
                                          AdminSystem.TPR_Supplier_Detail.As_pRec.srSuburb,
                                          SupplierStateCode,
                                          AdminSystem.TPR_Supplier_Detail.As_pRec.srPostCode,
                                          CountryText(AdminSystem.fdFields.fdCountry),
                                          '',  // Supplier Postal Address not used
                                          '',  //      |
                                          '',  //      |
                                          '',  //      |
                                          '',  //    \ |/
                                          '',  //     \/
                                          AdminSystem.fdFields.fdPractice_EMail_Address);
      ATOExtract.WritePayerIdentityDataRecord(PayerABN,
                                              PayerBranch,
                                              YearOf(EndOfReportDate),
                                              MyClient.clFields.clName,
                                              MyClient.clTPR_Payee_Detail.As_pRec.prTradingName,
                                              MyClient.clTPR_Payee_Detail.As_pRec.prAddressLine1,
                                              MyClient.clTPR_Payee_Detail.As_pRec.prAddressLine2,
                                              MyClient.clTPR_Payee_Detail.As_pRec.prSuburb,
                                              PayerStateCode,
                                              MyClient.clTPR_Payee_Detail.As_pRec.prPostCode,
                                              MyClient.clTPR_Payee_Detail.As_pRec.prCountry,
                                              PayerContactName,
                                              PayerContactPhone,
                                              MyClient.clFields.clFax_No,
                                              PayerContactEmail);
      ATOExtract.WriteSoftwareDataRecord(BRAND_FULL_PRACTICE);

      for PayeeIndex := 0 to MyClient.clPayee_List.ItemCount - 1 do
      begin
        Payee := MyClient.clPayee_List.Payee_At(PayeeIndex);

        // only process contractor payees
        if not Payee.pdFields.pdContractor then
          continue;

        ATOExtract.WritePayeeDataRecord(Payee.pdFields.pdABN,
                                        Payee.pdFields.pdSurname,
                                        Payee.pdFields.pdGiven_Name,
                                        Payee.pdFields.pdOther_Name,
                                        Payee.pdFields.pdBusinessName,
                                        Payee.pdFields.pdTradingName,
                                        Payee.pdFields.pdAddress,
                                        Payee.pdFields.pdAddressLine2,
                                        Payee.pdFields.pdTown,
                                        Payee.pdFields.pdState,
                                        Payee.pdFields.pdPost_Code,
                                        Payee.pdFields.pdCountry,
                                        Payee.pdFields.pdPhone_Number,
                                        Payee.pdFields.pdInstitutionBSB,
                                        Payee.pdFields.pdInstitutionAccountNumber,
                                        trunc(PayeeDataList[PayeeIndex].GrossAmount),
                                        trunc(PayeeDataList[PayeeIndex].NoABNWithholdingTax),
                                        trunc(PayeeDataList[PayeeIndex].TotalGST),
                                        PayeeAmendmentIndicator);
      end;

      ATOExtract.WriteFileTotalDataRecord;
    finally
      ATOExtract.CloseATOFile();
    end;
  finally
    FreeAndNil(ATOExtract);
  end;

  MyClient.clTPR_Payee_Detail.As_pRec.prFirstTimeTPRATOExtractDone := false;
  Msg := SysUtils.Format( 'ATO extract saved to ''%s''.',[ aFileName ] );
  LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
  HelpfulInfoMsg( Msg, 0 );
end;

//------------------------------------------------------------------------------
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
