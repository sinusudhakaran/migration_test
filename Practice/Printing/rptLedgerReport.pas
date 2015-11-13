unit rptLedgerReport;

//------------------------------------------------------------------------------
interface

uses
  ReportDefs,
  LedgerRepDlg,
  rptParams,
  NewReportObj,
  PrintMgrObj,
  OvcDate,
  moneydef,
  Classes,
  UBatchBase,
  travList;

type
  // allows the ledger report manager to keep track of additional totals
  //----------------------------------------------------------------------------
  TListLedgerTMgr = class(TTravManagerWithNewReport)
  public
    Name : string;
    Quantities      : boolean;
    BankContraType, GSTContraType : byte; // used when printing contra entries
    ContraCodePrinted : string;
    LastValidCode: string; // last VALID code printed
    //following are used in the list ledger summary
    AccountTotalGross   : Money;
    AccountTotalTax     : Money;
    AccountTotalNet     : Money;
    AccountTotalQuantity: Money;
    AccountHasActivity  : Boolean;
    //Superfund summary fields
    SuperTotalImputed_Credit: Money;
    SuperTotalTax_Free_Dist: Money;
    SuperTotalTax_Exempt_Dist: Money;
    SuperTotalTax_Deferred_Dist: Money;
    SuperTotalTFN_Credits: Money;
    SuperTotalForeign_Income: Money;
    SuperTotalForeign_Tax_Credits: Money;
    SuperTotalCapital_Gains_Indexed: Money;
    SuperTotalCapital_Gains_Disc: Money;
    SuperTotalCapital_Gains_Other: Money;
    SuperTotalOther_Expenses: Money;
    SuperTotalCGT_Date: Money;
    SuperTotalFranked: Money;
    SuperTotalUnFranked: Money;
    SuperTotalInterest: Money;
    SuperTotalCapital_Gains_Foreign_Disc: Money;
    SuperTotalRent: Money;
    SuperTotalSpecial_Income: Money;
    SuperTotalOther_Tax_Credit: Money;
    SuperTotalNon_Resident_Tax: Money;
    SuperTotalForeign_Capital_Gains_Credit: Money;

    SuperTotalOther_Income                         : Money;
    SuperTotalOther_Trust_Deductions               : Money;
    SuperTotalCGT_Concession_Amount                : Money;
    SuperTotalCGT_ForeignCGT_Before_Disc           : Money;
    SuperTotalCGT_ForeignCGT_Indexation            : Money;
    SuperTotalCGT_ForeignCGT_Other_Method          : Money;
    SuperTotalCGT_TaxPaid_Indexation               : Money;
    SuperTotalCGT_TaxPaid_Other_Method             : Money;
    SuperTotalOther_Net_Foreign_Income             : Money;
    SuperTotalCash_Distribution                    : Money;
    SuperTotalAU_Franking_Credits_NZ_Co            : Money;
    SuperTotalNon_Res_Witholding_Tax               : Money;
    SuperTotalLIC_Deductions                       : Money;
    SuperTotalNon_Cash_CGT_Discounted_Before_Discount : Money;
    SuperTotalNon_Cash_CGT_Indexation              : Money;
    SuperTotalNon_Cash_CGT_Other_Method            : Money;
    SuperTotalNon_Cash_CGT_Capital_Losses          : Money;
    SuperTotalShare_Consideration                  : Money;
    SuperTotalShare_Brokerage                      : Money;
    SuperTotalShare_GST_Amount                     : Money;

    procedure ClearSuper;
  end;

  //decends from the base BK report object
  //----------------------------------------------------------------------------
  TListLedgerReport = class(TBKReport)
  protected
    procedure PutWrapped(aNarration: string;
                         aGSTClass: Byte;
                         aGross: Comp;
                         aGST: Comp;
                         aNet: Comp;
                         aQty: Comp;
                         aAvg: Currency;
                         aNotes: string);
  public
    Params : TLRParameters;
    DoneSubTotal: Boolean;               // has displayed subtotals line
    SplitCode: string;                   // Used to re-print the code title if a page splits it up
    function ShowCodeOnReport( aCode : string; var aCodeSelected : boolean) : boolean;
    procedure BKPrint;  override;
    procedure AfterNewPage(aDetailPending : Boolean);  override;
  end;

  //----------------------------------------------------------------------------
  function CalcAverage(aNet, aQty : currency) : currency;

  //----------------------------------------------------------------------------
  procedure GenerateSummaryListLedgerReport(aDest : TReportDest; aJob : TListLedgerReport);

  //----------------------------------------------------------------------------
  procedure DoListLedgerReport(aDest : TReportDest;
                  aRptBatch : TReportBase = nil);

//------------------------------------------------------------------------------
implementation

uses
  Software,
  StDateSt,
  ReportTypes,
  repcols,
  bkdefs,
  glConst,
  globals,
  ladefs,
  bkconst,
  GSTCalc32,
  bkhelp,
  signUtils,
  sysutils,
  baobj32,
  bkDateUtils,
  Admin32,
  GenUtils,
  BAUtils,
  NewReportUtils,
  InfoMoreFrm,
  BasUtils,
  mxfiles32,
  TransactionUtils,
  clObj32,
  CustomHeadingsListObj,
  chList32,
  ECollect,
  mxList32,
  PayeeObj,
  AccountInfoObj,
  BKUtil32,
  calculateAccountTotals,
  WarningMoreFrm,
  ForexHelpers,
  glList32,
  glObj32;

const
  QUANTITY_FORMAT = '#,##0.0000;(#,##0.0000);-';
  NUMBER_FORMAT = '#,##0.00;(#,##0.00);-';
  BAL_FORMAT = '#,##0.00 "OD ";#,##0.00 "IF "; ';
  NullCode = '<NULLCODE>';

  DATE_CAPTION = 'Date';
  REFERENCE_CAPTION = 'Reference';
  //NET_AMOUNT_CAPTION = 'Net Amount';
  DESCRIPTION_CAPTION = 'Description';
  NARRATION_CAPTION = 'Narration';

var
  NET_AMOUNT_CAPTION : String;

//------------------------------------------------------------------------------
function HasExchangeGainLossEntries(const aCode: String; aParams: TLRParameters): Boolean;
var
  Index: Integer;
  BankAccount: TBank_Account;
begin
  Result := False;

  if IsForeignCurrencyClient then
  begin
    for Index := 0 to MyClient.clBank_Account_List.ItemCount - 1 do
    begin
      BankAccount := MyClient.clBank_Account_List.Bank_Account_At(Index);

      if BankAccount.baFields.baExchange_Gain_Loss_Code = aCode then
      begin
        if Length(BankAccount.baExchange_Gain_Loss_List.GetEntriesPostedBetween(aParams.FromDate, aParams.ToDate)) > 0  then
        begin
          Result := True;

          Exit;
        end;
      end;
    end;
  end;
end;

// Takes a value and quantity and returns a unit price
//------------------------------------------------------------------------------
function CalcAverage(aNet, aQty : currency) : currency;
begin
  if aQty <> 0.0 then
  begin
    result := aNet/aQty;

    //the avg should have the same sign as the quantity.  For normal
    //cases the qty and net value will have the same sign, so consequently
    //the avg will have the same sign.
    result := SetSign_Curr( result, SignOf( aQty));
  end
  else
    result := 0;
end;

//decide if we need to print a title for the current code
//------------------------------------------------------------------------------
procedure TListLedgerReport.AfterNewPage(aDetailPending : Boolean);
begin
  if SplitCode <> '' then
    RenderTitleLine(SplitCode);
end;

// Is current bank account selected in the Advanced tab
// Returns True if selected
//------------------------------------------------------------------------------
function IsBankAccountIncluded(aReportJob: TBkReport; aMgr: TListLedgerTMgr): Boolean;
var
  AccIndex : Integer;
  BankAcc : TBank_Account;
  LRParams : TLRParameters;
begin
  Result := False;

  LRParams := TListLedgerReport(aReportJob).Params;

  for AccIndex := 0 to Pred(LRParams.AccountList.Count) do
  begin
    BankAcc := TBank_Account(LRParams.AccountList[AccIndex]);
    if (BankAcc.baFields.baBank_Account_Number = aMgr.Bank_Account.baFields.baBank_Account_Number) then
    begin
      Result := True;
      Break;
    end;
  end;

  if (LRParams.IncludeNonTransferring and
     (aMgr.Bank_Account.baFields.baAccount_Type in BKConst.NonTrfJournalsLedgerSet)) then
    Result := True;
end;

// Is the given Code used as a bank contra in any bank account that is included
// Returns index into BA list, or -1 if not a contra
//------------------------------------------------------------------------------
function IsABankContra(aCode: string; aStart: Integer; aReportJob: TBKReport): Integer;
var
  BankAcc: TBank_Account;
  TransRec : pTransaction_Rec;
  CltAccIndex, ParamAccIndex, TransIndex: Integer;
  LRParams : TLRParameters;
begin
  Result := -1;
  if aCode = '' then
    Exit;

  LRParams := TListLedgerReport(aReportJob).Params;

  for CltAccIndex := aStart to Pred(LRParams.Client.clBank_Account_List.ItemCount) do
  begin
    BankAcc := LRParams.Client.clBank_Account_List.Bank_Account_At(CltAccIndex);
    if (BankAcc.baFields.baContra_Account_Code = aCode) and
       (not (BankAcc.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
    begin
      // Is this account included
      for ParamAccIndex := 0 to Pred(LRParams.AccountList.Count) do
      begin
        if LRParams.AccountList[ParamAccIndex] = BankAcc then
        begin
          // Does this account have any transactions coded within the report dates
          for TransIndex := 0 to Pred(BankAcc.baTransaction_List.ItemCount) do
          begin
            TransRec := BankAcc.baTransaction_List.Transaction_At(TransIndex);
            if (TransRec.txDate_Effective >= LRParams.FromDate) and
               (TransRec.txDate_Effective <= LRParams.Todate) then
            begin
              Result := CltAccIndex;
              exit;
            end;
          end;
        end;
      end;
    end;
  end;
end;

// Does a given transaction use a given GST class
//------------------------------------------------------------------------------
function DoesTxUseGSTClass(aClient : TClientObj; aClassId: string; aTransRec: pTransaction_Rec): Boolean;
var
  DissRec: pDissection_Rec;
begin
  Result := False;

  // check mainline
  if (aTransRec.txGST_Class in [ 1..MAX_GST_CLASS ]) and
     (aClient.clFields.clGST_Class_Codes[aTransRec.txGST_Class] = aClassId) and
     (aTransRec.txGST_Amount <> 0) then
  begin
    Result := True;
    Exit;
  end;

  // check dissection lines
  DissRec := aTransRec.txFirst_Dissection;

  while DissRec <> nil do
  begin
    if (DissRec.dsGST_Class in [ 1..MAX_GST_CLASS ]) and
       (aClient.clFields.clGST_Class_Codes[DissRec.dsGST_Class] = aClassId) and
       (DissRec.dsGST_Amount <> 0) then
    begin
      Result := True;
      Exit;
    end;
    DissRec := DissRec.dsNext;
  end;
end;

// Is the given Code used as a GST control account
// Returns index into GST rates list, or -1 if not a control account
//------------------------------------------------------------------------------
function IsAGSTContra(aCode: string; aStart: Integer; aReportJob: TBKReport): Integer;
var
  CltAccIndex, ParamAccIndex, TransIndex: Integer;
  BankAcc  : TBank_Account;
  TransRec : pTransaction_Rec;
  LRParams : TLRParameters;
begin
  Result := -1;
  if aCode = '' then
    Exit;

  LRParams := TListLedgerReport(aReportJob).Params;

  for CltAccIndex := aStart to High(LRParams.Client.clFields.clGST_Account_Codes) do
  begin
    if LRParams.Client.clFields.clGST_Account_Codes[CltAccIndex] = aCode then
    begin
      // Is this GST class used in any included bank account
      for ParamAccIndex := 0 to Pred(LRParams.AccountList.Count) do
      begin
        BankAcc := LRParams.AccountList[ParamAccIndex];
        // Are there any txns using this gst class within the report dates
        for TransIndex := 0 to Pred(BankAcc.baTransaction_List.ItemCount) do
        begin
          TransRec := BankAcc.baTransaction_List.Transaction_At(TransIndex);
          if (TransRec.txDate_Effective >= LRParams.Fromdate) and
             (TransRec.txDate_Effective <= LRParams.Todate) and
             DoesTxUseGSTClass(LRParams.Client, LRParams.Client.clFields.clGST_Class_Codes[CltAccIndex], TransRec) then
          begin
            Result := CltAccIndex;
            Exit;
          end;
        end;
      end;

      // ...or in non-trf journals if they are to be included
      if LRParams.IncludeNonTransferring then
      begin
        for ParamAccIndex := 0 to Pred(LRParams.Client.clBank_Account_List.ItemCount) do
        begin
          BankAcc := LRParams.Client.clBank_Account_List.Bank_Account_At(ParamAccIndex);
          if BankAcc.baFields.baAccount_Type in BKConst.NonTrfJournalsLedgerSet then
          begin
            // Are there any txns using this gst class within the report dates
            for TransIndex := 0 to Pred(BankAcc.baTransaction_List.ItemCount) do
            begin
              TransRec := BankAcc.baTransaction_List.Transaction_At(TransIndex);
              if (TransRec.txDate_Effective >= LRParams.Fromdate) and
                 (TransRec.txDate_Effective <= LRParams.Todate) and
                 DoesTxUseGSTClass(LRParams.Client, LRParams.Client.clFields.clGST_Class_Codes[CltAccIndex], TransRec) then
              begin
                Result := CltAccIndex;
                Exit;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

// Is the given Code required to be used as a contra (bank or gst) in the current report
// Returns true if there are contras for the given code
//------------------------------------------------------------------------------
function IsThisAContraCode(aCode: string; aReportJob: TBKReport): Boolean;
var
  LRParams : TLRParameters;
begin
  LRParams := TListLedgerReport(aReportJob).Params;

  Result :=
    ((LRParams.BankContra > Byte(bcNone)) and
     (IsABankContra(aCode, 0, aReportJob) > -1))
    or
    ((LRParams.GSTContra > Byte(gcNone)) and
     (IsAGSTContra(aCode, Low(LRParams.Client.clFields.clGST_Account_Codes), aReportJob) > -1))
end;

// To get an opening balance for an invalid code there are no actual op bals -
// we just calculate movement from the financial year start
//------------------------------------------------------------------------------
function GetOpeningBalanceForInvalidCode(aClient : TClientObj; aCode: string; aFromDate: Integer): Money;
//Must be net amount !!!
var
  BankAcc  : TBank_Account;
  TransRec : pTransaction_Rec;
  CltAccIndex, TransIndex, fromDate, toDate: Integer;
  Curr_Dissect : pDissection_Rec;
  finDay, finMonth, finYear: Integer;
  fromDay, fromMonth, fromYear: Integer;
begin
  Result := 0;

  // Add all movement between financial year start and day prior to report start
  fromDate := aClient.clFields.clTemp_FRS_From_Date;
  toDate := aClient.clFields.clTemp_FRS_To_Date;

  //handle special case where report is being run from fin year start date
  StDatetoDMY(aClient.clFields.clFinancial_Year_Starts, finDay, finMonth, finYear);
  StDatetoDMY(aFromDate, fromDay, fromMonth, fromYear);
  if (finDay = fromDay) and (finMonth = fromMonth) then
  begin
    result := 0;
    exit;
  end;

  //with aClient.clBank_Account_List do
  for CltAccIndex := 0 to Pred(aClient.clBank_Account_List.ItemCount) do // Loop each bank account
  begin
    BankAcc := aClient.clBank_Account_List.Bank_Account_At(CltAccIndex);
    for TransIndex := 0 to Pred(BankAcc.baTransaction_List.ItemCount) do // loop each transaction
    begin
      TransRec := BankAcc.baTransaction_List.Transaction_At(TransIndex);

      if (TransRec.txDate_Effective >= fromDate) and (TransRec.txDate_Effective <= toDate) then
      begin
        if (TransRec.txAccount = aCode) then
        begin
          Result := Result + ( TransRec.txTemp_Base_Amount - TransRec.txGST_Amount)
        end
        else
        if (TransRec.txFirst_Dissection <> nil) then
        begin
          Curr_Dissect := TransRec.txFirst_Dissection;

          while Curr_Dissect <> nil do
          begin
            if Curr_Dissect.dsAccount = aCode then
              Result := Result + ( Curr_Dissect.dsTemp_Base_Amount - Curr_Dissect.dsGST_Amount);
            Curr_Dissect := Curr_Dissect.dsNext;
          end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function GetOpeningBalanceAmount(aClient : tClientObj; aCode: string): Money;
var
  AccountInfo: TAccountInformation;
  Bal: Money;
  finDay, finMonth, finYear: Integer;
  startDay, startMonth, startYear: Integer;
begin
  AccountInfo := TAccountInformation.Create( aClient);
  try
    AccountInfo.UseBudgetIfNoActualData     := False;
    AccountInfo.LastPeriodOfActualDataToUse := aClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode := aCode;
    AccountInfo.UseBaseAmounts := True;
    StDatetoDMY(aClient.clFields.clFinancial_Year_Starts, finDay, finMonth, finYear);
    StDatetoDMY(aClient.clFields.clTemp_FRS_To_Date, startDay, startMonth, startYear);

    // If start date = financial year start then just get opening bal
    if (finDay = startDay) and (finMonth = startMonth) then
      Bal := AccountInfo.OpeningBalanceActualOrBudget(1)
    else
      // else opening bal at last financial year start + movement up to previous day
      Bal := AccountInfo.ClosingBalanceActualOrBudget(1);
  finally
    AccountInfo.Free;
  end;

  Result := Bal;
end;

// Print mainline txn within a contra code
//------------------------------------------------------------------------------
procedure LGR_Contra_PrintEntry(aSender : TObject);
var
  Code : Bk5CodeStr;
  Ref  : string[20];
  Mgr  : TListLedgerTMgr;
  Avg  : Currency;
  Net  : Money;
  Qty  : Money;
  GSTControlAccount, Notes: string;
  RptClient : TClientObj;
  TranRec : tTransaction_Rec;
  Params : TLRParameters;
begin
  Mgr := TListLedgerTMgr(aSender);
  TranRec := Mgr.Transaction^;
  Params := TListLedgerReport(Mgr.ReportJob).Params;
  RptClient := Params.Client;
  Code := TranRec.txAccount;

  //get GST control account if we need to display gst contras
  if (Mgr.GSTContraType > Byte(gcNone)) and
     (TranRec.txGst_Class in [ 1..MAX_GST_CLASS ]) then
    GSTControlAccount := RptClient.clFields.clGST_Account_Codes[TranRec.txGst_Class]
  else
    GSTControlAccount := '';

  //is bank account included in this report?
  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
    exit;

  //does this transaction need to be handled? only if:
  //it is coded to the handled acount
  //the bank account it belongs to has this account as the contra
  //its GST class has this account as the control account
  //Skip dissections, they are handled in a seperate method
  if ((Mgr.ContraCodePrinted <> TranRec.txAccount) and
      (Mgr.ContraCodePrinted <> Mgr.Bank_Account.baFields.baContra_Account_Code) and
      (Mgr.ContraCodePrinted <> GSTControlAccount)) or
     (TranRec.txAccount = DISSECT_DESC) then
    exit;

  // #2608 - do not show transactions with $0 GST in the contra section unless coded to this account
  if (GSTControlAccount = Mgr.ContraCodePrinted) and
     (TranRec.txGST_Amount = 0) and
     (TranRec.txAccount <> GSTControlAccount) then
    exit;

  // #2861 - do not show contras for journals (but show GST)
  if (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet) and
     (Mgr.ContraCodePrinted <> GSTControlAccount) and
     (Mgr.ContraCodePrinted <> Code) and
     (Code <> Mgr.Bank_Account.baFields.baContra_Account_Code) then
    exit;

  // for detailed reports...

  //if we only want bank contra totals then add this txn
  if (Mgr.BankContraType = Byte(bcTotal)) and
     (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
     (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) and
     (TranRec.txTemp_Base_Amount <> 0) and (not Params.SummaryReport) then
  begin
    Mgr.AccountTotalGross := Mgr.AccountTotalGross + (-TranRec.txTemp_Base_Amount);
    Mgr.AccountHasActivity := True;
  end;

  //if we only want gst contra totals then add this txn
  if (Mgr.GSTContraType = Byte(gcTotal)) and
     (Mgr.ContraCodePrinted = GSTControlAccount) and
     (TranRec.txGST_Amount <> 0) and (not Params.SummaryReport) then
  begin
    Mgr.AccountTotalTax := Mgr.AccountTotalTax + (-TranRec.txGST_Amount);
    Mgr.AccountTotalNet := Mgr.AccountTotalNet + TranRec.txGST_Amount;
    Mgr.AccountHasActivity := True;
  end;

  //print contra entries if requested
  //note: txn may be printed twice (actual entry and contra) if its coded to this account

  //normal txn
  if (Mgr.ContraCodePrinted = TranRec.txAccount) then
  begin
    if Params.SummaryReport then
    begin
      Mgr.AccountTotalGross    := Mgr.AccountTotalGross + TranRec.txTemp_Base_Amount;
      Mgr.AccountTotalTax      := Mgr.AccountTotalTax   + TranRec.txGST_Amount;
      Mgr.AccountTotalNet      := Mgr.AccountTotalNet   + ( TranRec.txTemp_Base_Amount - TranRec.txGST_Amount);
      Mgr.AccountTotalQuantity := Mgr.AccountTotalQuantity + TranRec.txQuantity;
      Mgr.AccountHasActivity   := (TranRec.txTemp_Base_Amount <> 0) or (TranRec.txGST_Amount <> 0);
    end
    else
    begin
      Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ));

      Ref := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
      Mgr.ReportJob.PutString( Ref );

      If Mgr.Quantities then
      begin
        Net := TranRec.txTemp_Base_Amount - TranRec.txGST_Amount;
        Qty := TranRec.txQuantity;
        Avg := calcAverage(Net/100,Qty/10000);
      end
      else
      begin
        Qty := 0;
        Avg := 0;
      end;
      if Params.ShowNotes then
        Notes := GetFullNotes(Mgr.Transaction)
      else
        Notes := '';

      TListLedgerReport(Mgr.ReportJob).PutWrapped(GetNarration(Mgr.Transaction,
                                                               Mgr.Bank_Account.baFields.baAccount_Type),
                                                  TranRec.txGST_Class,
                                                  TranRec.txTemp_Base_Amount,
                                                  TranRec.txGST_Amount,
                                                  TranRec.txTemp_Base_Amount - TranRec.txGST_Amount,
                                                  Qty,
                                                  Avg,
                                                  Notes);

      Mgr.ReportJob.RenderDetailLine;
      Mgr.AccountHasActivity := True;
    end;
  end;

  //bank contra
  if (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
     (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
  begin
    if Params.SummaryReport then
    begin
      Mgr.AccountTotalGross := Mgr.AccountTotalGross + (-TranRec.txTemp_Base_Amount);
      Mgr.AccountTotalNet   := Mgr.AccountTotalNet + (-TranRec.txTemp_Base_Amount);
      Mgr.AccountHasActivity := TranRec.txTemp_Base_Amount <> 0;
    end
    else if (Mgr.BankContraType = Byte(bcAll)) then
    begin
      Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ));

      Ref := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type );
      Mgr.ReportJob.PutString( Ref );

      if Params.ShowNotes then
        Notes := GetFullNotes(Mgr.Transaction)
      else
        Notes := '';

      TListLedgerReport(Mgr.ReportJob).PutWrapped(GetNarration(Mgr.Transaction,
                                                               Mgr.Bank_Account.baFields.baAccount_Type),
                                                  TranRec.txGST_Class,
                                                  -TranRec.txTemp_Base_Amount,
                                                  0,
                                                  -TranRec.txTemp_Base_Amount,
                                                  0,
                                                  0,
                                                  Notes);

      Mgr.ReportJob.RenderDetailLine;
      Mgr.AccountHasActivity := True;
    end;
  end;

  //GST contra
  if (Mgr.ContraCodePrinted = GSTControlAccount) then
  begin
    if Params.SummaryReport then
    begin
      Mgr.AccountTotalTax    := Mgr.AccountTotalTax   + (-TranRec.txGST_Amount);
      Mgr.AccountTotalNet    := Mgr.AccountTotalNet   + TranRec.txGST_Amount;
      Mgr.AccountHasActivity := TranRec.txGST_Amount <> 0;
    end
    else if (Mgr.GSTContraType = Byte(gcAll)) then
    begin
      Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ));

      Ref := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
      Mgr.ReportJob.PutString( Ref );

      if Params.ShowNotes then
        Notes := GetFullNotes(Mgr.Transaction)
      else
        Notes := '';

      TListLedgerReport(Mgr.ReportJob).PutWrapped(GetNarration(Mgr.Transaction,
                                                               Mgr.Bank_Account.baFields.baAccount_Type),
                                                  TranRec.txGST_Class,
                                                  0,
                                                  -TranRec.txGST_Amount,
                                                  TranRec.txGST_Amount,
                                                  0,
                                                  0,
                                                  Notes);

      Mgr.ReportJob.RenderDetailLine;
      Mgr.AccountHasActivity := True;
    end;
  end;
end;

// Print dissected txn within a contra code
//------------------------------------------------------------------------------
procedure LGR_Contra_PrintDissect(aSender : Tobject);
var
  Code  : Bk5CodeStr;
  Ref    : string[20];
  Mgr : TListLedgerTMgr;
  Avg : Currency;
  Net : Money;
  Qty : Money;
  GSTControlAccount, Notes, Narration: string;
  RptClient : TClientObj;
  TranRec : tTransaction_Rec;
  DissRec : tDissection_Rec;
  Params : TLRParameters;
begin
  Mgr := TListLedgerTMgr(aSender);
  TranRec := Mgr.Transaction^;
  DissRec := Mgr.Dissection^;
  Params := TListLedgerReport(Mgr.ReportJob).Params;
  RptClient := Params.Client;
  Code := DissRec.dsAccount;

  //get GST control account if we need to display gst contras
  if (Mgr.GSTContraType > Byte(gcNone)) and
     (DissRec.dsGst_Class in [ 1..MAX_GST_CLASS ]) then
    GSTControlAccount := RptClient.clFields.clGST_Account_Codes[DissRec.dsGst_Class]
  else
    GSTControlAccount := '';

  //is bank account included in this report?
  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
    Exit;

  //does this dissection line need to be handled? only if:
  //it is coded to the handled acount
  //the bank account it belongs to has this account as the contra
  //its GST class has this account as the control account
  if (Mgr.ContraCodePrinted <> DissRec.dsAccount) and
     (Mgr.ContraCodePrinted <> Mgr.Bank_Account.baFields.baContra_Account_Code) and
     (Mgr.ContraCodePrinted <> GSTControlAccount) then
    exit;

  // #2608 - do not show transactions with $0 GST in the contra section unless coded to this account
  if (GSTControlAccount = Mgr.ContraCodePrinted) and
     (DissRec.dsGST_Amount = 0) and
     (DissRec.dsAccount <> GSTControlAccount) then
    exit;

  // #2861 - do not show contras for journals (but show GST)
  if (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet) and
     (Mgr.ContraCodePrinted <> GSTControlAccount) and
     (Mgr.ContraCodePrinted <> Code) and
     (Code <> Mgr.Bank_Account.baFields.baContra_Account_Code) then
    exit;

  // for detailed reports...

  //if we only want bank contra totals then add this line
  if (Mgr.BankContraType = Byte(bcTotal)) and
     (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
     (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) and         
     (DissRec.dsTemp_Base_Amount <> 0) and (not Params.SummaryReport) then
  begin
    Mgr.AccountTotalGross := Mgr.AccountTotalGross + (-DissRec.dsTemp_Base_Amount);
    Mgr.AccountHasActivity := True;
  end;

  //if we only want gst contra totals then add this txn
  if (Mgr.GSTContraType = Byte(gcTotal)) and
     (Mgr.ContraCodePrinted = GSTControlAccount) and
     (DissRec.dsGST_Amount <> 0) and
     (not Params.SummaryReport) then
  begin
    Mgr.AccountTotalTax := Mgr.AccountTotalTax + (-DissRec.dsGST_Amount);
    Mgr.AccountTotalNet := Mgr.AccountTotalNet + DissRec.dsGST_Amount;
    Mgr.AccountHasActivity := True;
  end;

  //print contra entries if requested
  //note: txn may be printed twice (actual entry and contra) if its coded to this account
                                                       
  //normal txn
  if (Mgr.ContraCodePrinted = DissRec.dsAccount) then
  begin
    if Params.SummaryReport then
    begin
      Mgr.AccountTotalGross    := Mgr.AccountTotalGross + DissRec.dsTemp_Base_Amount;
      Mgr.AccountTotalTax      := Mgr.AccountTotalTax   + DissRec.dsGST_Amount;
      Mgr.AccountTotalNet      := Mgr.AccountTotalNet   + ( DissRec.dsTemp_Base_Amount - DissRec.dsGST_Amount);
      Mgr.AccountTotalQuantity := Mgr.AccountTotalQuantity + DissRec.dsQuantity;
      Mgr.AccountHasActivity   := (DissRec.dsTemp_Base_Amount <> 0) or (DissRec.dsGST_Amount <> 0);
    end
    else
    begin
      if Mgr.Bank_Account.IsAJournalAccount then
        Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ))
      else
        Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ) + ' [D]');

      if length(DissRec.dsReference) > 0 then
        Ref := DissRec.dsReference
      else
        Ref := GetFormattedReference( Mgr.Transaction,
                                     Mgr.Bank_Account.baFields.baAccount_Type);

      Mgr.ReportJob.PutString( Ref );

      If Mgr.Quantities then
      begin
        //qty is shown as +ve as long as signs match
        Net := DissRec.dsTemp_Base_Amount - DissRec.dsGST_Amount;
        Qty := DissRec.dsQuantity;
        Avg := calcAverage(Net/100,Qty/10000);
      end
      else
      begin
        Qty := 0;
        Avg := 0;
      end;

      if Params.ShowNotes then
        Notes := GetFullNotes(Mgr.Dissection)
      else
        Notes := '';

      Narration :=  GetNarration(Mgr.Dissection, Mgr.Bank_Account.baFields.baAccount_Type);

      TListLedgerReport(Mgr.ReportJob).PutWrapped(Narration,
                                                  DissRec.dsGST_Class,
                                                  DissRec.dsTemp_Base_Amount,
                                                  DissRec.dsGST_Amount,
                                                  DissRec.dsTemp_Base_Amount - DissRec.dsGST_Amount,
                                                  Qty,
                                                  Avg,
                                                  Notes);

      Mgr.ReportJob.RenderDetailLine;
    end;
    Mgr.AccountHasActivity := True;
  end;

  //bank contra
  if (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
     (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
  begin
    if Params.SummaryReport then
    begin
      Mgr.AccountTotalGross  := Mgr.AccountTotalGross + (-DissRec.dsTemp_Base_Amount);
      Mgr.AccountTotalNet    := Mgr.AccountTotalNet + (-DissRec.dsTemp_Base_Amount);
      Mgr.AccountHasActivity := DissRec.dsTemp_Base_Amount <> 0;
    end
    else if (Mgr.BankContraType = Byte(bcAll)) then
    begin
      if Mgr.Bank_Account.IsAJournalAccount then
        Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ))
      else
        Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ) + ' [D]');

      Ref := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
      Mgr.ReportJob.PutString( Ref );

      if Params.ShowNotes then
        Notes := GetFullNotes(Mgr.Dissection)
      else
        Notes := '';

      Narration :=  GetNarration(Mgr.Dissection, Mgr.Bank_Account.baFields.baAccount_Type);

      TListLedgerReport(Mgr.ReportJob).PutWrapped(Narration,
                                                  DissRec.dsGST_Class,
                                                  -DissRec.dsTemp_Base_Amount,
                                                  0,
                                                  -DissRec.dsTemp_Base_Amount,
                                                  0,
                                                  0,
                                                  Notes);

      Mgr.ReportJob.RenderDetailLine;
      Mgr.AccountHasActivity := True;
    end;
  end;

  //GST contra
  if (Mgr.ContraCodePrinted = GSTControlAccount) then // gst contra txn
  begin
    if Params.SummaryReport then
    begin
      Mgr.AccountTotalTax    := Mgr.AccountTotalTax + (-DissRec.dsGST_Amount);
      Mgr.AccountTotalNet    := Mgr.AccountTotalNet + DissRec.dsGST_Amount;
      Mgr.AccountHasActivity := DissRec.dsGST_Amount <> 0;
    end
    else if (Mgr.GSTContraType = Byte(gcAll)) then
    begin
      Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ));

      Ref := GetFormattedReference(Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
      Mgr.ReportJob.PutString( Ref );

      if Params.ShowNotes then
        Notes := GetFullNotes(Mgr.Dissection)
      else
        Notes := '';

      Narration :=  GetNarration(Mgr.Dissection, Mgr.Bank_Account.baFields.baAccount_Type);

      TListLedgerReport(Mgr.ReportJob).PutWrapped(Narration,
                                                  DissRec.dsGST_Class,
                                                  0,
                                                  -DissRec.dsGST_Amount,
                                                  DissRec.dsGST_Amount,
                                                  0,
                                                  0,
                                                  Notes);

      Mgr.ReportJob.RenderDetailLine;
      Mgr.AccountHasActivity := True;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure LGR_Contra_PrintExchangeGainLoss(aSender : TObject);
var
  Code    : Bk5CodeStr;
  Mgr     : TListLedgerTMgr;
  Notes   : string;
  Account : pAccount_Rec;
  Params  : TLRParameters;
begin
  Mgr  := TListLedgerTMgr(aSender);
  Code := Mgr.ExchangeGainLossEntry.glAccount;

  Params := TListLedgerReport(Mgr.ReportJob).Params;

  //is bank account included in this report?
  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
    Exit;

  //print contra entries if requested
  //note: txn may be printed twice (actual entry and contra) if its coded to this account
  if (Mgr.BankContraType = Byte(bcTotal)) and
     (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
     (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) and
     (Mgr.ExchangeGainLossEntry.glAmount <> 0) and
     (not Params.SummaryReport) then
  begin
    Mgr.AccountTotalGross := Mgr.AccountTotalGross + (-Mgr.ExchangeGainLossEntry.glAmount);
    Mgr.AccountHasActivity := True;
  end;

  //bank contra
  if (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
     (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
  begin
    Account := Params.Chart.FindCode(Code);

    if Assigned(Account) then
    begin
      if Params.SummaryReport then
      begin
        Mgr.AccountTotalGross  := Mgr.AccountTotalGross + (-Mgr.ExchangeGainLossEntry.glAmount);
        Mgr.AccountTotalNet    := Mgr.AccountTotalNet + (-Mgr.ExchangeGainLossEntry.glAmount);
        Mgr.AccountHasActivity := Mgr.ExchangeGainLossEntry.glAmount <> 0;
      end
      else if (Mgr.BankContraType = Byte(bcAll)) then
      begin
        Mgr.ReportJob.PutString( bkDate2Str ( Mgr.ExchangeGainLossEntry.glDate ));

        Mgr.ReportJob.PutString(Account.chAccount_Code);

        TListLedgerReport(Mgr.ReportJob).PutWrapped(Account.chAccount_Description,
                                                    0,
                                                    -Mgr.ExchangeGainLossEntry.glAmount,
                                                    0,
                                                    -Mgr.ExchangeGainLossEntry.glAmount,
                                                    0,
                                                    0,
                                                    Notes);

        Mgr.ReportJob.RenderDetailLine;

        Mgr.AccountHasActivity := True;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure PrintSummaryListLedgerLine( aMgr : TListLedgerTMgr; aCode : BK5CodeStr; aJob: TBKReport);
var
  AccRec : pAccount_Rec;
  Avg    : Currency;
  Report : TListLedgerReport;
  ReportParams: TLRParameters;
begin
  Report := TListLedgerReport(aJob);
  ReportParams := Report.Params;

  if ReportParams.ShowSuperDetails then
  begin
    ReportParams.ColManager.Code := aCode;
    ReportParams.ColManager.OutputColumns(Report, aMgr);
    Report.RenderDetailLine;
    aMgr.ClearSuper;
  end
  else
  begin
    if aCode = '' then
    begin
      Report.PutString('Uncoded');
      if not ReportParams.ShowBalances then
        Report.SkipColumn;
    end
    else
    begin
      if ReportParams.ShowBalances then
        Report.PutString('MOVEMENT')
      else
      begin
        Report.PutString( aCode);
        AccRec := ReportParams.Chart.FindCode( aCode);
        if Assigned( AccRec ) then
          Report.PutString( AccRec^.chAccount_Description)
        else
          Report.PutString( 'INVALID CODE');
      end;
    end;

    if ReportParams.GrossGST then
    begin
      Report.PutMoney( aMgr.AccountTotalGross);
      Report.PutMoney( aMgr.AccountTotalTax);
    end;

    Report.PutMoney( aMgr.AccountTotalNet);

    if aMgr.Quantities then
    begin
      //qty is shown as +ve as long as signs match
      Report.PutQuantity( aMgr.AccountTotalQuantity);
      Avg := calcAverage(aMgr.AccountTotalNet/100, aMgr.AccountTotalQuantity/10000);
      Report.PutCurrency( Avg);
    end;

    Report.RenderDetailLine;
  end;
end;

// Print the bank and gst contra entries
//------------------------------------------------------------------------------
function DoContras(aReportJob: TBKReport; aCode: string) : boolean;
//parameters:
//   ReportJob : pointer to the list ledger report object
//   Code : Contra code to process
//
//   Result : returns true if contra has activity
var
  ContraTravMgr : TListLedgerTMgr;
  IsBankContra, IsGSTContra: Boolean;
  BankContra, GSTContra: Integer;
  BankContraType, GstContraType: Byte;
  Params : TLRParameters;
begin
  Params := TListLedgerReport(aReportJob).Params;

  result := false;

  //are bank contras needed in this report for this code
  BankContra := IsABankContra(aCode, 0, aReportJob);
  BankContraType := Params.BankContra;
  IsBankContra := (BankContraType > Byte(bcNone)) and
                  (BankContra > -1);
  //are gst contras needed in this report for this code
  GSTContra := IsAGSTContra(aCode, Low(Params.Client.clFields.clGST_Account_Codes), aReportJob);
  GstContraType := Params.GSTContra;
  IsGSTContra := (GstContraType > Byte(gcNone)) and
                 (GSTContra > -1);
  //we will have to look at every transaction again to find transactions with
  //bank accounts with this contra and to find gst contras
  if IsBankContra or IsGSTContra then
  begin
    ContraTravMgr := TListLedgerTMgr.Create;
    try
      ContraTravMgr.Name := 'Contra Trav Mgr';
      ContraTravMgr.Clear;
      ContraTravMgr.SortType             := csDateEffective; // Date order within the contra code
      ContraTravMgr.SelectionCriteria    := TravList.twAllEntries;
      ContraTravMgr.ReportJob            := aReportJob;
      ContraTravMgr.AccountTotalGross    := 0;
      ContraTravMgr.AccountTotalTax      := 0;
      ContraTravMgr.AccountTotalNet      := 0;
      ContraTravMgr.AccountTotalQuantity := 0;
      ContraTravMgr.AccountHasActivity   := false;
      ContraTravMgr.LastCodePrinted      := NullCode;
      ContraTravMgr.ContraCodePrinted    := aCode;
      ContraTravMgr.Quantities           := Params.ShowQuantity;
      ContraTravMgr.BankContraType       := BankContraType;
      ContraTravMgr.GSTContraType        := GstContraType;
      ContraTravMgr.OnEnterEntry         := LGR_Contra_PrintEntry;
      ContraTravMgr.OnEnterDissection    := LGR_Contra_PrintDissect;
      ContraTravMgr.OnEnterExchangeGainLoss := LGR_Contra_PrintExchangeGainLoss;

      ContraTravMgr.TraverseAllEntries(Params.fromdate, Params.Todate);

      if Params.Summaryreport then
      begin
        //display contra code summary line
        PrintSummaryListLedgerLine(ContraTravMgr, aCode, TListLedgerReport(aReportJob));
        TListLedgerReport(aReportJob).DoneSubTotal := True;
      end
      else
      begin
        //if we are displaying totals, just add a single line entry
        if Params.ShowSuperDetails then
        begin
          if IsBankContra and ContraTravMgr.AccountHasActivity and (BankContraType = Byte(bcTotal)) then
          begin
            Params.ColManager.IsBankContra := IsBankContra;
            Params.ColManager.OutputColumns(aReportJob, ContraTravMgr);
            aReportJob.RenderDetailLine;
          end;
          if IsGSTContra and ContraTravMgr.AccountHasActivity and (GstContraType = Byte(gcTotal)) then
          begin
            Params.ColManager.IsGSTContra := IsGSTContra;
            Params.ColManager.OutputColumns(aReportJob, ContraTravMgr);
            aReportJob.RenderDetailLine;
          end;
          //Reset contra falgs
          Params.ColManager.IsBankContra := False;
          Params.ColManager.IsGSTContra := False;
        end
        else
        begin
          if IsBankContra and ContraTravMgr.AccountHasActivity and (BankContraType = Byte(bcTotal)) then
          begin
            aReportJob.PutString('');
            aReportJob.PutString('CONTRA');
            aReportJob.PutString('MOVEMENT');

            if Params.GrossGST then
            begin
              aReportJob.PutString('');
              aReportJob.PutMoney(ContraTravMgr.AccountTotalGross);
              aReportJob.PutMoney(0);
            end;
            aReportJob.PutMoney(ContraTravMgr.AccountTotalGross);

            If ContraTravMgr.Quantities then
            begin
              aReportJob.PutQuantity(0);
              aReportJob.PutCurrency(0);
            end;

            if Params.ShowNotes then
              aReportJob.PutString('');
            aReportJob.RenderDetailLine;
          end;

          if IsGSTContra and ContraTravMgr.AccountHasActivity and (GstContraType = Byte(gcTotal)) then
          begin
            aReportJob.PutString('');
            aReportJob.PutString('CONTRA');
            aReportJob.PutString('MOVEMENT');

            if Params.GrossGST then
            begin
              aReportJob.PutString('');
              aReportJob.PutMoney(0);
              aReportJob.PutMoney(ContraTravMgr.AccountTotalTax);
            end;

            aReportJob.PutMoney(ContraTravMgr.AccountTotalNet);

            If ContraTravMgr.Quantities then
            begin
              aReportJob.PutQuantity(0);
              aReportJob.PutCurrency(0);
            end;

            if Params.ShowNotes then
              aReportJob.PutString('');
            aReportJob.RenderDetailLine;
          end;
        end;

        if ContraTravMgr.AccountHasActivity then
        begin
          // Note DO NOT clear subtotals - we need them to calculate closing bal
          aReportJob.RenderDetailSubTotal('', False, True);
          TListLedgerReport(aReportJob).DoneSubTotal := True;
          Result := true;
        end;
      end;
    finally
      ContraTravMgr.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure ReportLedgerOpeningBalance(aCode: string; aReportJob: TBKReport; aNewLine: Boolean; aIsValidCode: Boolean = True);
var
  aCol : TReportColumn;
  rptColIndex : Integer;
  Params : TLRParameters;
begin
  Params := TListLedgerReport(aReportJob).Params;

  for rptColIndex := 0 to Pred(aReportJob.Columns.ItemCount) do
  begin
    aCol := aReportJob.Columns.Report_Column_At(rptColIndex);

    if aCol.Caption = DATE_CAPTION then
    begin
      aReportJob.PutString(bkDate2Str(Params.Fromdate));
    end
    else if aCol.Caption = NET_AMOUNT_CAPTION then // Add txn amounts to opening bal
    begin
      if aIsValidCode then
        aReportJob.PutMoney(GetOpeningBalanceAmount(Params.Client, aCode), False)
      else
        aReportJob.PutMoney(GetOpeningBalanceForInvalidCode(Params.Client, aCode, Params.Fromdate), False);
    end
    else if (aCol.Caption = NARRATION_CAPTION) or
            (aCol.Caption = DESCRIPTION_CAPTION) then
    begin
      aReportJob.PutString('Opening Balance');
    end
    else
      aReportJob.SkipColumn;
  end;

  aReportJob.RenderDetailLine;
  aReportJob.ClearSubTotals;

  if aNewLine then
    aReportJob.RenderTextLine(' ');
end;

//------------------------------------------------------------------------------
procedure ReportLedgerClosingBalance(aCode: string; aReportJob: TBKReport; aNewLine: Boolean; aIsValidCode: Boolean = True);
var
  aCol : TReportColumn;
  rptColIndex : Integer;
  Params : TLRParameters;
begin
  Params := TListLedgerReport(aReportJob).Params;

  for rptColIndex := 0 to Pred(aReportJob.Columns.ItemCount) do
  begin
    if (aReportJob.Columns.Report_Column_At(rptColIndex).Caption = NET_AMOUNT_CAPTION) and
       (Params.Summaryreport) then
    begin
      aReportJob.RenderColumnLine(rptColIndex);
      Break;
    end;
  end;

  if aNewLine then
    aReportJob.RenderTextLine(' ');

  for rptColIndex := 0 to Pred(aReportJob.Columns.ItemCount) do
  begin
    aCol := aReportJob.Columns.Report_Column_At(rptColIndex);

    if aCol.Caption = DATE_CAPTION then
      aReportJob.PutString(bkDate2Str(Params.Todate))
    else if aCol.Caption = NET_AMOUNT_CAPTION then // Add txn amounts to opening bal
    begin
      if aIsValidCode then
        aReportJob.PutMoney(((GetOpeningBalanceAmount(Params.Client, aCode)/100) + aCol.SubTotal)*100, False)
      else
        aReportJob.PutMoney(((GetOpeningBalanceForInvalidCode(Params.Client, aCode, Params.Fromdate)/100) + aCol.SubTotal)*100, False);
    end
    else if (aCol.Caption = NARRATION_CAPTION) or
            (aCol.Caption = DESCRIPTION_CAPTION) then
    begin
      if Params.SpanYear then
        aReportJob.PutString('Closing Balance *')
      else
        aReportJob.PutString('Closing Balance');
    end
    else
      aReportJob.SkipColumn;
  end;
  aReportJob.RenderDetailLine;
end;

//------------------------------------------------------------------------------
function OutputClosingBalances(aCode: Bk5CodeStr; aTravMgr: TListLedgerTMgr; aReport:TListLedgerReport; aReportParams: TLRParameters): boolean;
var
  AccRec : pAccount_Rec;
  OKToPrint : boolean;
  RenderStr : string;
  IsValidCode, IsContras: boolean;
  LegRpt : TListLedgerReport;
  CodeSelected : boolean;
begin
  Result := True;

  IsValidCode := Assigned(aReportParams.Chart.FindCode(aCode));
  LegRpt := TListLedgerReport(aReport);

  //code has changed, handle closing balance
  if aCode <> aTravMgr.LastCodePrinted then
  begin
    // end last code
    if aTravMgr.LastCodePrinted <> NullCode then
    begin
      if not LegRpt.DoneSubTotal then // avoid duplicate subtotals
        aReport.RenderDetailSubTotal('', False, True);
      // Show closing balance if requested
      if aReportParams.ShowBalances and
         (aTravMgr.LastCodePrinted <> '') then
        ReportLedgerClosingBalance(aTravMgr.LastCodePrinted,
                                   aReport,
                                   aTravMgr.AccountHasActivity,
                                   (aTravMgr.LastCodePrinted = aTravMgr.LastValidCode));
      // Need subtotals to calculate closing bal so do not clear during the subtotal printing
      // only safe to clear once closing balances have been printed
      LegRpt.ClearSubTotals;
      LegRpt.DoneSubTotal := False;
    end;
    LegRpt.SplitCode := '';

    //handle in between codes
    // Show inactive codes and contras if requested (that are between last code and this code)
    if (aTravMgr.LastCodePrinted = NullCode) or
       (aTravMgr.LastValidCode = NullCode) then
      AccRec := aReportParams.Chart.FindNextCode('', False) // finds first code
    else if aTravMgr.LastCodePrinted <> aTravMgr.LastValidCode then
      AccRec := aReportParams.Chart.FindNextCode(aTravMgr.LastValidCode, False)
    else
      AccRec := aReportParams.Chart.FindNextCode(aTravMgr.LastCodePrinted, False);

    // Some conditions to handle invalid codes
    OKToPrint := ((not IsValidCode) and
                  Assigned(AccRec) and
                  (AccRec^.chAccount_Code < aCode)) or // this code is invalid but next valid code is less than this one - need to show it
                 ((not IsValidCode) and
                  (aTravMgr.LastCodePrinted = aTravMgr.LastValidCode) and
                  (aTravMgr.LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this

    if Assigned(AccRec) and
      (IsValidCode or OKToPrint) then
    begin
      while (aCode <> '') and
            (AccRec^.chAccount_Code <> aCode) and
            (AccRec^.chAccount_Code < aCode) do
      begin
        //is code in range?
        if TListLedgerReport(aReport).ShowCodeOnReport( AccRec^.chAccount_Code, CodeSelected) then
        begin
          RenderStr := AccRec^.chAccount_Code + '  ' + AccRec^.chAccount_Description;

          if HasAlternativeChartCode(aReportParams.Client.clFields.clCountry,
                                     aReportParams.Client.clFields.clAccounting_System_Used ) and
             (AccRec.chAlternative_code > '') then
            RenderStr := RenderStr + ' ' + AccRec.chAlternative_code;

          IsContras := IsThisAContraCode(AccRec^.chAccount_Code, aReport);
          // show if contra or showing empty posting codes or showing non-posting codes with a balance

          if (IsContras or
              ((aReportParams.PrintEmptyCodes and (not AccRec^.chInactive or CodeSelected)) and
               (AccRec^.chPosting_Allowed or
                (aReportParams.ShowBalances and
                 (GetOpeningBalanceAmount(aReportParams.Client,AccRec^.chAccount_Code) <> 0))))) then
          begin
            aReport.RenderTitleLine(RenderStr);
            TListLedgerReport(aReport).SplitCode := RenderStr + ' (continued)';

            if aReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
              ReportLedgerOpeningBalance(AccRec^.chAccount_Code, aReport, True);

            if IsContras then
              DoContras(aReport, AccRec^.chAccount_Code);

            if aReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
              ReportLedgerClosingBalance(AccRec^.chAccount_Code, aReport, IsContras);

            TListLedgerReport(aReport).DoneSubTotal := False;
            TListLedgerReport(aReport).SplitCode := '';
            TListLedgerReport(aReport).ClearSubTotals;
            aTravMgr.LastValidCode := AccRec^.chAccount_Code;
          end;
        end;
        AccRec := aReportParams.Chart.FindNextCode(AccRec^.chAccount_Code, False);
        if not Assigned(AccRec) then
          Break;
      end;
    end;

    //Now we start to print the new code
    if aCode = '' then
      RenderStr := 'Uncoded'
    else
    begin
      AccRec := aReportParams.Chart.FindCode( aCode );
      if Assigned( AccRec ) then
      begin
         RenderStr := AccRec^.chAccount_Code + '  ' + AccRec^.chAccount_Description;

         if HasAlternativeChartCode(aReportParams.Client.clFields.clCountry,
            aReportParams.Client.clFields.clAccounting_System_Used ) and
            (AccRec.chAlternative_code > '') then
           RenderStr := RenderStr + ' ' + AccRec.chAlternative_code;
      end
      else
        RenderStr := aCode + '  INVALID CODE!';
    end;

    aReport.RenderTitleLine(RenderStr);
    TListLedgerReport(aReport).SplitCode := RenderStr + ' (continued)';
    aTravMgr.LastCodePrinted := aCode;

    if IsValidCode then
      aTravMgr.LastValidCode := aCode;

    // Show opening balance if requested
    if aReportParams.ShowBalances and (aCode <> '') then
      ReportLedgerOpeningBalance(aCode, aReport, True, Assigned(AccRec));

    // Show contras for this code - this will display ALL transactions
    // for this code (so that they display in date order)
    // so after this we need to move onto next code (as per skipping txns earlier in this proc)
    if IsThisAContraCode(aCode, aReport) then
    begin
      aTravMgr.AccountHasActivity := DoContras(aReport, aCode);
      aTravMgr.ContraCodePrinted := aCode;
      Result := False;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure Custom_LGR_PrintEntry(aSender : TObject);
var
  Code  : Bk5CodeStr;
  TravMgr : TListLedgerTMgr;
  Report : TListLedgerReport;
  ReportParams : TLRParameters;
  TranRec : TTransaction_Rec;
  CodeSelected : boolean;
begin
  TravMgr := TListLedgerTMgr(aSender);
  Report := TListLedgerReport(TravMgr.ReportJob);
  ReportParams := Report.Params;
  TranRec := TravMgr.Transaction^;
  Code := TranRec.txAccount;

  //Bank account included?
  if not IsBankAccountIncluded(Report, TravMgr) then
    Exit;
  //Code in range?
  if not TListLedgerReport(Report).ShowCodeOnReport(Code, CodeSelected) then
    Exit;
  // has txn already been printed during contras?
  // if we have printed contras then we have gone thru all codes again from
  // start so we must skip them in here
  if (Code = TravMgr.ContraCodePrinted) and
     (TravMgr.ContraCodePrinted <> NullCode) then
    Exit;

  TravMgr.ContraCodePrinted := NullCode;

  if not OutputClosingBalances(Code, TravMgr, Report, ReportParams) then
    Exit;

  ReportParams.ColManager.IsDissection := False;
  ReportParams.ColManager.OutputColumns(Report, TravMgr);
  Report.RenderDetailLine;

  TravMgr.AccountHasActivity := True;
end;

//------------------------------------------------------------------------------
procedure Custom_LGR_PrintDissect(aSender : TObject);
var
  TravMgr: TListLedgerTMgr;
  Code  : Bk5CodeStr;
  Report: TListLedgerReport;
  ReportParams: TLRParameters;
  CodeSelected : boolean;
begin
  TravMgr := TListLedgerTMgr(aSender);
  Report := TListLedgerReport(TravMgr.ReportJob);
  ReportParams := Report.Params;
  Code := TravMgr.Dissection.dsAccount;

  //is bank account included in this report?
  if not IsBankAccountIncluded(Report, TravMgr) then
    Exit;

  //is code in range?
  if not TListLedgerReport(Report).ShowCodeOnReport(Code, CodeSelected) then
    Exit;

  // has tx already been printed during contras?
  if (Code = TravMgr.ContraCodePrinted) and
     (TravMgr.ContraCodePrinted <> NullCode) then
    Exit;

  TravMgr.ContraCodePrinted := NullCode;

  if not OutputClosingBalances(Code, TravMgr, Report, ReportParams) then
    Exit;

  ReportParams.ColManager.IsDissection := True;
  ReportParams.ColManager.OutputColumns(Report, TravMgr);
  Report.RenderDetailLine;

  TravMgr.AccountHasActivity := True;
end;

//------------------------------------------------------------------------------
procedure SummaryListLedger_PrintEntry(aSender : TObject);
//trav manager has transactions sorted by account code
var
  Code    : Bk5CodeStr;
  Mgr     : TListLedgerTMgr;
  AccRec  : pAccount_Rec;
  RendStr : string;
  IsContras, IsEmpty, IsValidCode, OKToPrint: Boolean;
  Report : TListLedgerReport;
  ReportParams : TLRParameters;
  TranRec : TTransaction_Rec;
  CodeActive : boolean;
  CodeSelected : boolean;
begin
  Mgr := TListLedgerTMgr(aSender);
  Report := TListLedgerReport(Mgr.ReportJob);
  ReportParams := Report.Params;
  TranRec := Mgr.Transaction^;
  Code := TranRec.txAccount;

  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
    exit;

  //is code in range?
  if not TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( Code, CodeSelected) then
    exit;

  // has tx already been printed during contras?
  if (Code = Mgr.ContraCodePrinted) and
     (Mgr.ContraCodePrinted <> NullCode) then
    exit;

  Mgr.ContraCodePrinted := NullCode;

  AccRec := ReportParams.Chart.FindCode( Code );
  IsValidCode := Assigned(AccRec);

  CodeActive := true;
  if Assigned(AccRec) then
    CodeActive := not AccRec^.chInactive;

  //code has changed
  if ( Code <> Mgr.LastCodePrinted) then
  begin
    if ( Mgr.LastCodePrinted <> NullCode) then
    begin
      //code has changed so print totals
      if (Mgr.AccountHasActivity or (ReportParams.PrintEmptyCodes and (CodeActive or CodeSelected))) and
         (not TListLedgerReport(Mgr.ReportJob).DoneSubTotal) then
        PrintSummaryListLedgerLine( Mgr, Mgr.LastCodePrinted, TListLedgerReport(Mgr.ReportJob));

      // Show closing balance if requested
      if ReportParams.ShowBalances and (Mgr.LastCodePrinted <> '') then
      begin
        ReportLedgerClosingBalance(Mgr.LastCodePrinted, Mgr.ReportJob, False, Mgr.LastCodePrinted = Mgr.LastValidCode);
        TListLedgerReport(Mgr.ReportJob).SplitCode := '';
        Mgr.ReportJob.RenderTextLine('');
      end;
    end;

    //clear temp information
    Mgr.AccountHasActivity   := false;
    Mgr.AccountTotalGross    := 0;
    Mgr.AccountTotalTax      := 0;
    Mgr.AccountTotalNet      := 0;
    Mgr.AccountTotalQuantity := 0;
    TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
    TListLedgerReport(Mgr.ReportJob).SplitCode := '';
    TListLedgerReport(Mgr.ReportJob).ClearSubTotals;

    //Clear Super
    Mgr.ClearSuper;

    //request to show all codes regardless of any activity
    //look for all codes in between last (valid) one printed and next to be printed
    if (Mgr.LastCodePrinted = NullCode) or
       (Mgr.LastValidCode = NullCode) then
      AccRec := ReportParams.Chart.FindNextCode('', False)
    else if Mgr.LastCodePrinted <> Mgr.LastValidCode then
      AccRec := ReportParams.Chart.FindNextCode(Mgr.LastValidCode, False)
    else
      AccRec := ReportParams.Chart.FindNextCode(Mgr.LastCodePrinted, False);

    // Some conditions to handle invalid codes
    OKToPrint := ((not IsValidCode) and
                   Assigned(AccRec) and
                  (AccRec^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                 ((not IsValidCode) and
                  (Mgr.LastCodePrinted = Mgr.LastValidCode) and
                  (Mgr.LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this
    if Assigned(AccRec) and (IsValidCode or OKToPrint) then
    begin
      while (Code <> '') and (AccRec^.chAccount_Code <> Code) and (AccRec^.chAccount_Code < Code) do
      begin
        //is code in range?
        if TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( AccRec^.chAccount_Code, CodeSelected) then
        begin
          IsContras := IsThisAContraCode(AccRec^.chAccount_Code, Mgr.ReportJob);
          IsEmpty := (ReportParams.PrintEmptyCodes and (not AccRec^.chInactive or CodeSelected)) and
                    (AccRec^.chPosting_Allowed or
                     (ReportParams.ShowBalances and
                      (GetOpeningBalanceAmount(ReportParams.Client, AccRec^.chAccount_Code) <> 0)));
          if IsContras or IsEmpty then
          begin
            if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
            begin
              Mgr.ReportJob.RenderTitleLine(AccRec^.chAccount_Code + ' ' + AccRec^.chAccount_Description);
              TListLedgerReport(Mgr.ReportJob).SplitCode := AccRec^.chAccount_Code + ' ' + AccRec^.chAccount_Description + ' (continued)';
              ReportLedgerOpeningBalance(AccRec^.chAccount_Code, Mgr.ReportJob, False);
            end;

            if IsContras then
            begin
              TListLedgerReport(Mgr.ReportJob).SplitCode := AccRec^.chAccount_Code + ' ' + AccRec^.chAccount_Description + ' (continued)';
              DoContras(Mgr.ReportJob, AccRec^.chAccount_Code)
            end
            else
              PrintSummaryListLedgerLine( Mgr, AccRec^.chAccount_Code, TListLedgerReport(Mgr.ReportJob));

            if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
            begin
              ReportLedgerClosingBalance(AccRec^.chAccount_Code, Mgr.ReportJob, False);
              TListLedgerReport(Mgr.ReportJob).SplitCode := '';
              Mgr.ReportJob.RenderTextLine('');
            end
            else
              TListLedgerReport(Mgr.ReportJob).SplitCode := '';

            Mgr.LastValidCode := AccRec^.chAccount_Code;
          end;
        end;
        AccRec := ReportParams.Chart.FindNextCode(AccRec^.chAccount_Code, False);

        TListLedgerReport(Mgr.ReportJob).ClearSubTotals;

        if not Assigned(AccRec) then
          Break;
      end;
    end;

    // starting a new code
    Mgr.LastCodePrinted    := Code;

    if IsValidCode then
      Mgr.LastValidCode := Code;

    TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
    TListLedgerReport(Mgr.ReportJob).SplitCode := '';

    // Show opening balance if requested
    if ReportParams.ShowBalances and (Code <> '') then
    begin
      AccRec := ReportParams.Chart.FindCode( Code );

      If Assigned( AccRec ) then
        RendStr := Code + '  ' + AccRec^.chAccount_Description
      else
        RendStr := Code + '  INVALID CODE!';

      Mgr.ReportJob.RenderTitleLine(RendStr);
      TListLedgerReport(Mgr.ReportJob).SplitCode := RendStr + ' (continued)';
      ReportLedgerOpeningBalance(Code, Mgr.ReportJob, False, Assigned(AccRec));
    end;

    // Show contras for this code - this will display ALL transactions
    // for this code (so that they display in date order)
    // so after this we need to move onto next code
    if IsThisAContraCode(Code, Mgr.ReportJob) then
    begin
      Mgr.AccountHasActivity := DoContras(Mgr.ReportJob, Code);
      Mgr.ContraCodePrinted := Code;
      Exit;
    end;
  end;

  //store values
  Mgr.AccountTotalGross    := Mgr.AccountTotalGross + TranRec.txTemp_Base_Amount;
  Mgr.AccountTotalTax      := Mgr.AccountTotalTax   + TranRec.txGST_Amount;
  Mgr.AccountTotalNet      := Mgr.AccountTotalNet   + ( TranRec.txTemp_Base_Amount - TranRec.txGST_Amount);
  Mgr.AccountTotalQuantity := Mgr.AccountTotalQuantity + TranRec.txQuantity;

  if (TranRec.txTemp_Base_Amount <> 0) or
     (TranRec.txGST_Amount <> 0) then
     Mgr.AccountHasActivity := true;

  //Super
  if ReportParams.ShowSuperDetails then
  begin
    Mgr.SuperTotalImputed_Credit               := Mgr.SuperTotalImputed_Credit + TranRec.txSF_Imputed_Credit;
    Mgr.SuperTotalTax_Free_Dist                := Mgr.SuperTotalTax_Free_Dist + TranRec.txSF_Tax_Free_Dist;
    Mgr.SuperTotalTax_Exempt_Dist              := Mgr.SuperTotalTax_Exempt_Dist + TranRec.txSF_Tax_Exempt_Dist;
    Mgr.SuperTotalTax_Deferred_Dist            := Mgr.SuperTotalTax_Deferred_Dist + TranRec.txSF_Tax_Deferred_Dist;
    Mgr.SuperTotalTFN_Credits                  := Mgr.SuperTotalTFN_Credits + TranRec.txSF_TFN_Credits;
    Mgr.SuperTotalForeign_Income               := Mgr.SuperTotalForeign_Income + TranRec.txSF_Foreign_Income;
    Mgr.SuperTotalForeign_Tax_Credits          := Mgr.SuperTotalForeign_Tax_Credits + TranRec.txSF_Foreign_Tax_Credits;
    Mgr.SuperTotalCapital_Gains_Indexed        := Mgr.SuperTotalCapital_Gains_Indexed + TranRec.txSF_Capital_Gains_Indexed;
    Mgr.SuperTotalCapital_Gains_Disc           := Mgr.SuperTotalCapital_Gains_Disc + TranRec.txSF_Capital_Gains_Disc;
    Mgr.SuperTotalCapital_Gains_Other          := Mgr.SuperTotalCapital_Gains_Other + TranRec.txSF_Capital_Gains_Other;
    Mgr.SuperTotalOther_Expenses               := Mgr.SuperTotalOther_Expenses + TranRec.txSF_Other_Expenses;
    Mgr.SuperTotalCGT_Date                     := Mgr.SuperTotalCGT_Date + TranRec.txSF_CGT_Date;
    Mgr.SuperTotalFranked                      := Mgr.SuperTotalFranked + TranRec.txSF_Franked;
    Mgr.SuperTotalUnFranked                    := Mgr.SuperTotalUnFranked + TranRec.txSF_UnFranked;
    Mgr.SuperTotalInterest                     := Mgr.SuperTotalInterest + TranRec.txSF_Interest;
    Mgr.SuperTotalCapital_Gains_Foreign_Disc   := Mgr.SuperTotalCapital_Gains_Foreign_Disc + TranRec.txSF_Capital_Gains_Foreign_Disc;
    Mgr.SuperTotalRent                         := Mgr.SuperTotalRent + TranRec.txSF_Rent;
    Mgr.SuperTotalSpecial_Income               := Mgr.SuperTotalSpecial_Income + TranRec.txSF_Special_Income;
    Mgr.SuperTotalOther_Tax_Credit             := Mgr.SuperTotalOther_Tax_Credit + TranRec.txSF_Other_Tax_Credit;
    Mgr.SuperTotalNon_Resident_Tax             := Mgr.SuperTotalNon_Resident_Tax + TranRec.txSF_Non_Resident_Tax;
    Mgr.SuperTotalForeign_Capital_Gains_Credit := Mgr.SuperTotalForeign_Capital_Gains_Credit + TranRec.txSF_Foreign_Capital_Gains_Credit;

  //Extension Record fields
    Mgr.SuperTotalOther_Income                     := Mgr.SuperTotalOther_Income + TranRec.txTransaction_Extension^.teSF_Other_Income;
    Mgr.SuperTotalOther_Trust_Deductions           := Mgr.SuperTotalOther_Trust_Deductions + TranRec.txTransaction_Extension^.teSF_Other_Trust_Deductions;
    Mgr.SuperTotalCGT_Concession_Amount            := Mgr.SuperTotalCGT_Concession_Amount + TranRec.txTransaction_Extension^.teSF_CGT_Concession_Amount;
    Mgr.SuperTotalCGT_ForeignCGT_Before_Disc       := Mgr.SuperTotalCGT_ForeignCGT_Before_Disc + TranRec.txTransaction_Extension^.teSF_CGT_ForeignCGT_Before_Disc;
    Mgr.SuperTotalCGT_ForeignCGT_Indexation        := Mgr.SuperTotalCGT_ForeignCGT_Indexation + TranRec.txTransaction_Extension^.teSF_CGT_ForeignCGT_Indexation;
    Mgr.SuperTotalCGT_ForeignCGT_Other_Method      := Mgr.SuperTotalCGT_ForeignCGT_Other_Method + TranRec.txTransaction_Extension^.teSF_CGT_ForeignCGT_Other_Method;
    Mgr.SuperTotalCGT_TaxPaid_Indexation           := Mgr.SuperTotalCGT_TaxPaid_Indexation + TranRec.txTransaction_Extension^.teSF_CGT_TaxPaid_Indexation;
    Mgr.SuperTotalCGT_TaxPaid_Other_Method         := Mgr.SuperTotalCGT_TaxPaid_Other_Method + TranRec.txTransaction_Extension^.teSF_CGT_TaxPaid_Other_Method;
    Mgr.SuperTotalOther_Net_Foreign_Income         := Mgr.SuperTotalOther_Net_Foreign_Income + TranRec.txTransaction_Extension^.teSF_Other_Net_Foreign_Income;
    Mgr.SuperTotalCash_Distribution                := Mgr.SuperTotalCash_Distribution + TranRec.txTransaction_Extension^.teSF_Cash_Distribution;
    Mgr.SuperTotalAU_Franking_Credits_NZ_Co        := Mgr.SuperTotalAU_Franking_Credits_NZ_Co + TranRec.txTransaction_Extension^.teSF_AU_Franking_Credits_NZ_Co;
    Mgr.SuperTotalNon_Res_Witholding_Tax           := Mgr.SuperTotalNon_Res_Witholding_Tax + TranRec.txTransaction_Extension^.teSF_Non_Res_Witholding_Tax;
    Mgr.SuperTotalLIC_Deductions                   := Mgr.SuperTotalLIC_Deductions + TranRec.txTransaction_Extension^.teSF_LIC_Deductions;
    Mgr.SuperTotalNon_Cash_CGT_Discounted_Before_Discount := Mgr.SuperTotalNon_Cash_CGT_Discounted_Before_Discount + TranRec.txTransaction_Extension^.teSF_Non_Cash_CGT_Discounted_Before_Discount;
    Mgr.SuperTotalNon_Cash_CGT_Indexation          := Mgr.SuperTotalNon_Cash_CGT_Indexation + TranRec.txTransaction_Extension^.teSF_Non_Cash_CGT_Indexation;
    Mgr.SuperTotalNon_Cash_CGT_Other_Method        := Mgr.SuperTotalNon_Cash_CGT_Other_Method + TranRec.txTransaction_Extension^.teSF_Non_Cash_CGT_Other_Method;
    Mgr.SuperTotalNon_Cash_CGT_Capital_Losses      := Mgr.SuperTotalNon_Cash_CGT_Capital_Losses + TranRec.txTransaction_Extension^.teSF_Non_Cash_CGT_Capital_Losses;
    Mgr.SuperTotalShare_Consideration              := Mgr.SuperTotalShare_Consideration + TranRec.txTransaction_Extension^.teSF_Share_Consideration;
    Mgr.SuperTotalShare_Brokerage                  := Mgr.SuperTotalShare_Brokerage + TranRec.txTransaction_Extension^.teSF_Share_Brokerage;
    Mgr.SuperTotalShare_GST_Amount                 := Mgr.SuperTotalShare_GST_Amount + TranRec.txTransaction_Extension^.teSF_Share_GST_Amount;
  end;
end;

//------------------------------------------------------------------------------
procedure SummaryListLedger_PrintDissect(aSender : TObject);
var
  Code    : Bk5CodeStr;
  Mgr     : TListLedgerTMgr;
  AccRec  : pAccount_Rec;
  RendStr : string;
  IsContras, IsEmpty, IsValidCode, OKToPrint: Boolean;
  Report : TListLedgerReport;
  ReportParams : TLRParameters;
  TranRec : TTransaction_Rec;
  DissRec : tDissection_Rec;
  CodeActive : Boolean;
  CodeSelected : boolean;
begin
  Mgr := TListLedgerTMgr(aSender);
  Report := TListLedgerReport(Mgr.ReportJob);
  ReportParams := Report.Params;
  TranRec := Mgr.Transaction^;
  DissRec := Mgr.Dissection^;
  Code := DissRec.dsAccount;

  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
    Exit;

  //is code in range?
  if not TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( Code, CodeSelected) then
    Exit;

  // has tx already been printed during contras?
  if (Code = Mgr.ContraCodePrinted) and
     (Mgr.ContraCodePrinted <> NullCode) then
    Exit;

  Mgr.ContraCodePrinted := NullCode;
  AccRec := ReportParams.Chart.FindCode( Code );
  IsValidCode := Assigned(AccRec);

  CodeActive := true;
  if Assigned(AccRec) then
    CodeActive := not AccRec^.chInactive;

  //code has changed
  if ( Code <> Mgr.LastCodePrinted) then
  begin
    if ( Mgr.LastCodePrinted <> NullCode) then
    begin
      //code has changed so print totals;
      if (Mgr.AccountHasActivity or
          (ReportParams.PrintEmptyCodes and (CodeActive or CodeSelected))) and
         (not TListLedgerReport(Mgr.ReportJob).DoneSubTotal) then
      begin
        PrintSummaryListLedgerLine( Mgr, Mgr.LastCodePrinted, TListLedgerReport(Mgr.ReportJob));
        // Show closing balance if requested
        if ReportParams.ShowBalances and
          (Mgr.LastCodePrinted <> '') then
        begin
          ReportLedgerClosingBalance(Mgr.LastCodePrinted, Mgr.ReportJob, False, Mgr.LastCodePrinted = Mgr.LastValidCode);
          TListLedgerReport(Mgr.ReportJob).SplitCode := '';
          Mgr.ReportJob.RenderTextLine('');
        end;
      end;
    end;

    //clear temp information
    Mgr.AccountHasActivity   := false;
    Mgr.AccountTotalGross    := 0;
    Mgr.AccountTotalTax      := 0;
    Mgr.AccountTotalNet      := 0;
    Mgr.AccountTotalQuantity := 0;
    TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
    TListLedgerReport(Mgr.ReportJob).SplitCode := '';
    TListLedgerReport(Mgr.ReportJob).ClearSubTotals;

    //Clear Super
    Mgr.ClearSuper;

    //request to show all codes regardless of any activity
    //look for all codes in between last one printed and next to be printed
    if (Mgr.LastCodePrinted = NullCode) or
       (Mgr.LastValidCode = NullCode) then
      AccRec := ReportParams.Chart.FindNextCode('', False)
    else if Mgr.LastCodePrinted <> Mgr.LastValidCode then
      AccRec := ReportParams.Chart.FindNextCode(Mgr.LastValidCode, False)
    else
      AccRec := ReportParams.Chart.FindNextCode(Mgr.LastCodePrinted, False);

    // Some conditions to handle invalid codes
    OKToPrint := ((not IsValidCode) and
                  Assigned(AccRec) and
                  (AccRec^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                 ((not IsValidCode) and
                  (Mgr.LastCodePrinted = Mgr.LastValidCode) and
                  (Mgr.LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this

    if Assigned(AccRec) and
      (IsValidCode or OKToPrint) then
    begin
      while (Code <> '') and
            (AccRec^.chAccount_Code <> Code) and
            (AccRec^.chAccount_Code < Code) do
      begin
        //is code in range?
        if TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( AccRec^.chAccount_Code, CodeSelected) then
        begin
          IsContras := IsThisAContraCode(AccRec^.chAccount_Code, Mgr.ReportJob);
          IsEmpty := (ReportParams.PrintEmptyCodes and (not AccRec^.chInactive or CodeSelected)) and
                     (AccRec^.chPosting_Allowed or
                      (ReportParams.ShowBalances and
                       (GetOpeningBalanceAmount(ReportParams.Client,AccRec^.chAccount_Code) <> 0)));

          if IsContras or IsEmpty then
          begin
            if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
            begin
              Report.RenderTitleLine(AccRec^.chAccount_Code + ' ' + AccRec^.chAccount_Description);
              TListLedgerReport(Mgr.ReportJob).SplitCode := AccRec^.chAccount_Code + ' ' + AccRec^.chAccount_Description + ' (continued)';
              ReportLedgerOpeningBalance(AccRec^.chAccount_Code, Mgr.ReportJob, False);
            end;

            if IsContras then
              DoContras(Mgr.ReportJob, AccRec^.chAccount_Code)
            else
              PrintSummaryListLedgerLine( Mgr, AccRec^.chAccount_Code, TListLedgerReport(Mgr.ReportJob));

            if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
            begin
              ReportLedgerClosingBalance(AccRec^.chAccount_Code, Mgr.ReportJob, False);
              TListLedgerReport(Mgr.ReportJob).SplitCode := '';
              Mgr.ReportJob.RenderTextLine('');
            end
            else
              TListLedgerReport(Mgr.ReportJob).SplitCode := '';

            Mgr.LastValidCode := AccRec^.chAccount_Code;
          end;
        end;
        AccRec := ReportParams.Chart.FindNextCode(AccRec^.chAccount_Code, False);
        TListLedgerReport(Mgr.ReportJob).ClearSubTotals;
        if not Assigned(AccRec) then
          Break;
      end;
    end;

    // starting a new code
    Mgr.LastCodePrinted    := Code;

    if IsValidCode then
      Mgr.LastValidCode := Code;

    TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
    TListLedgerReport(Mgr.ReportJob).SplitCode := '';

    // Show opening balance if requested
    if ReportParams.ShowBalances and (Code <> '') then
    begin
      AccRec := ReportParams.Chart.FindCode( Code );

      If Assigned( AccRec ) then
        RendStr := Code + '  ' + AccRec^.chAccount_Description
      else
        RendStr := Code + '  INVALID CODE!';

      Report.RenderTitleLine(RendStr);
      TListLedgerReport(Mgr.ReportJob).SplitCode := RendStr + ' (continued)';
      ReportLedgerOpeningBalance(Code, Mgr.ReportJob, False, Assigned(AccRec));
    end;

    // Show contras for this code - this will display ALL transactions
    // for this code (so that they display in date order)
    // so after this we need to move onto next code
    if IsThisAContraCode(Code, Mgr.ReportJob) then
    begin
      Mgr.AccountHasActivity := DoContras(Mgr.ReportJob, Code);
      Mgr.ContraCodePrinted := Code;
      Exit;
    end;
  end;
  //store values
  Mgr.AccountTotalGross    := Mgr.AccountTotalGross + DissRec.dsTemp_Base_Amount;
  Mgr.AccountTotalTax      := Mgr.AccountTotalTax   + DissRec.dsGST_Amount;
  Mgr.AccountTotalNet      := Mgr.AccountTotalNet   + ( DissRec.dsTemp_Base_Amount - DissRec.dsGST_Amount);
  Mgr.AccountTotalQuantity := Mgr.AccountTotalQuantity + DissRec.dsQuantity;
  if ( DissRec.dsTemp_Base_Amount <> 0) or ( DissRec.dsGST_Amount <> 0) then
    Mgr.AccountHasActivity := true;

  //Super
  if ReportParams.ShowSuperDetails then
  begin
    Mgr.SuperTotalImputed_Credit                := Mgr.SuperTotalImputed_Credit + DissRec.dsSF_Imputed_Credit;
    Mgr.SuperTotalTax_Free_Dist                 := Mgr.SuperTotalTax_Free_Dist + DissRec.dsSF_Tax_Free_Dist;
    Mgr.SuperTotalTax_Exempt_Dist               := Mgr.SuperTotalTax_Exempt_Dist + DissRec.dsSF_Tax_Exempt_Dist;
    Mgr.SuperTotalTax_Deferred_Dist             := Mgr.SuperTotalTax_Deferred_Dist + DissRec.dsSF_Tax_Deferred_Dist;
    Mgr.SuperTotalTFN_Credits                   := Mgr.SuperTotalTFN_Credits + DissRec.dsSF_TFN_Credits;
    Mgr.SuperTotalForeign_Income                := Mgr.SuperTotalForeign_Income + DissRec.dsSF_Foreign_Income;
    Mgr.SuperTotalForeign_Tax_Credits           := Mgr.SuperTotalForeign_Tax_Credits + DissRec.dsSF_Foreign_Tax_Credits;
    Mgr.SuperTotalCapital_Gains_Indexed         := Mgr.SuperTotalCapital_Gains_Indexed + DissRec.dsSF_Capital_Gains_Indexed;
    Mgr.SuperTotalCapital_Gains_Disc            := Mgr.SuperTotalCapital_Gains_Disc + DissRec.dsSF_Capital_Gains_Disc;
    Mgr.SuperTotalCapital_Gains_Other           := Mgr.SuperTotalCapital_Gains_Other + DissRec.dsSF_Capital_Gains_Other;
    Mgr.SuperTotalOther_Expenses                := Mgr.SuperTotalOther_Expenses + DissRec.dsSF_Other_Expenses;
    Mgr.SuperTotalCGT_Date                      := Mgr.SuperTotalCGT_Date + DissRec.dsSF_CGT_Date;
    Mgr.SuperTotalFranked                       := Mgr.SuperTotalFranked + DissRec.dsSF_Franked;
    Mgr.SuperTotalUnFranked                     := Mgr.SuperTotalUnFranked + DissRec.dsSF_UnFranked;
    Mgr.SuperTotalInterest                      := Mgr.SuperTotalInterest + DissRec.dsSF_Interest;
    Mgr.SuperTotalCapital_Gains_Foreign_Disc    := Mgr.SuperTotalCapital_Gains_Foreign_Disc + DissRec.dsSF_Capital_Gains_Foreign_Disc;
    Mgr.SuperTotalRent                          := Mgr.SuperTotalRent + DissRec.dsSF_Rent;
    Mgr.SuperTotalSpecial_Income                := Mgr.SuperTotalSpecial_Income + DissRec.dsSF_Special_Income;
    Mgr.SuperTotalOther_Tax_Credit              := Mgr.SuperTotalOther_Tax_Credit + DissRec.dsSF_Other_Tax_Credit;
    Mgr.SuperTotalNon_Resident_Tax              := Mgr.SuperTotalNon_Resident_Tax + DissRec.dsSF_Non_Resident_Tax;
    Mgr.SuperTotalForeign_Capital_Gains_Credit  := Mgr.SuperTotalForeign_Capital_Gains_Credit + DissRec.dsSF_Foreign_Capital_Gains_Credit;

  //Extension Record fields
    Mgr.SuperTotalOther_Income                     := Mgr.SuperTotalOther_Income + DissRec.dsDissection_Extension^.deSF_Other_Income;
    Mgr.SuperTotalOther_Trust_Deductions           := Mgr.SuperTotalOther_Trust_Deductions + DissRec.dsDissection_Extension^.deSF_Other_Trust_Deductions;
    Mgr.SuperTotalCGT_Concession_Amount            := Mgr.SuperTotalCGT_Concession_Amount + DissRec.dsDissection_Extension^.deSF_CGT_Concession_Amount;
    Mgr.SuperTotalCGT_ForeignCGT_Before_Disc       := Mgr.SuperTotalCGT_ForeignCGT_Before_Disc + DissRec.dsDissection_Extension^.deSF_CGT_ForeignCGT_Before_Disc;
    Mgr.SuperTotalCGT_ForeignCGT_Indexation        := Mgr.SuperTotalCGT_ForeignCGT_Indexation + DissRec.dsDissection_Extension^.deSF_CGT_ForeignCGT_Indexation;
    Mgr.SuperTotalCGT_ForeignCGT_Other_Method      := Mgr.SuperTotalCGT_ForeignCGT_Other_Method + DissRec.dsDissection_Extension^.deSF_CGT_ForeignCGT_Other_Method;
    Mgr.SuperTotalCGT_TaxPaid_Indexation           := Mgr.SuperTotalCGT_TaxPaid_Indexation + DissRec.dsDissection_Extension^.deSF_CGT_TaxPaid_Indexation;
    Mgr.SuperTotalCGT_TaxPaid_Other_Method         := Mgr.SuperTotalCGT_TaxPaid_Other_Method + DissRec.dsDissection_Extension^.deSF_CGT_TaxPaid_Other_Method;
    Mgr.SuperTotalOther_Net_Foreign_Income         := Mgr.SuperTotalOther_Net_Foreign_Income + DissRec.dsDissection_Extension^.deSF_Other_Net_Foreign_Income;
    Mgr.SuperTotalCash_Distribution                := Mgr.SuperTotalCash_Distribution + DissRec.dsDissection_Extension^.deSF_Cash_Distribution;
    Mgr.SuperTotalAU_Franking_Credits_NZ_Co        := Mgr.SuperTotalAU_Franking_Credits_NZ_Co + DissRec.dsDissection_Extension^.deSF_AU_Franking_Credits_NZ_Co;
    Mgr.SuperTotalNon_Res_Witholding_Tax           := Mgr.SuperTotalNon_Res_Witholding_Tax + DissRec.dsDissection_Extension^.deSF_Non_Res_Witholding_Tax;
    Mgr.SuperTotalLIC_Deductions                   := Mgr.SuperTotalLIC_Deductions + DissRec.dsDissection_Extension^.deSF_LIC_Deductions;
    Mgr.SuperTotalNon_Cash_CGT_Discounted_Before_Discount := Mgr.SuperTotalNon_Cash_CGT_Discounted_Before_Discount + DissRec.dsDissection_Extension^.deSF_Non_Cash_CGT_Discounted_Before_Discount;
    Mgr.SuperTotalNon_Cash_CGT_Indexation          := Mgr.SuperTotalNon_Cash_CGT_Indexation + DissRec.dsDissection_Extension^.deSF_Non_Cash_CGT_Indexation;
    Mgr.SuperTotalNon_Cash_CGT_Other_Method        := Mgr.SuperTotalNon_Cash_CGT_Other_Method + DissRec.dsDissection_Extension^.deSF_Non_Cash_CGT_Other_Method;
    Mgr.SuperTotalNon_Cash_CGT_Capital_Losses      := Mgr.SuperTotalNon_Cash_CGT_Capital_Losses + DissRec.dsDissection_Extension^.deSF_Non_Cash_CGT_Capital_Losses;
    Mgr.SuperTotalShare_Consideration              := Mgr.SuperTotalShare_Consideration + DissRec.dsDissection_Extension^.deSF_Share_Consideration;
    Mgr.SuperTotalShare_Brokerage                  := Mgr.SuperTotalShare_Brokerage + DissRec.dsDissection_Extension^.deSF_Share_Brokerage;
    Mgr.SuperTotalShare_GST_Amount                 := Mgr.SuperTotalShare_GST_Amount + DissRec.dsDissection_Extension^.deSF_Share_GST_Amount;
  end;
end;

//------------------------------------------------------------------------------
procedure LGR_PrintEntry(aSender : TObject);
var
  Code   : Bk5CodeStr;
  AccRec : pAccount_Rec;
  RendStr, Notes : String;
  RefStr : string[20];
  Mgr : TListLedgerTMgr;
  Avg : Currency;
  Net : Money;
  Qty : Money;
  IsContras, IsValidCode, OKToPrint: Boolean;
  Report : TListLedgerReport;
  ReportParams : TLRParameters;
  TranRec : TTransaction_Rec;
  CodeSelected : boolean;
begin
  Mgr := TListLedgerTMgr(aSender);
  Report := TListLedgerReport(Mgr.ReportJob);
  ReportParams := Report.Params;
  TranRec := Mgr.Transaction^;
  Code := TranRec.txAccount;

  //is bank account included in this report?
  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
    Exit;

  //is code in range?
  if not TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( Code, CodeSelected) then
    exit;

  // has txn already been printed during contras?
  // if we have printed contras then we have gone thru all codes again from
  // start so we must skip them in here
  if (Code = Mgr.ContraCodePrinted) and (Mgr.ContraCodePrinted <> NullCode) then
    exit;

  Mgr.ContraCodePrinted := NullCode;
  IsValidCode := Assigned(ReportParams.Chart.FindCode( Code ));

  //code has changed, handle closing balance
  if Code <> Mgr.LastCodePrinted then // its a new code
  begin
    // end last code
    if Mgr.LastCodePrinted <> NullCode then
    begin
      if not TListLedgerReport(Mgr.ReportJob).DoneSubTotal then // avoid duplicate subtotals
        Mgr.ReportJob.RenderDetailSubTotal('', False, True);

      // Show closing balance if requested
      if ReportParams.ShowBalances and
         (Mgr.LastCodePrinted <> '') then
        ReportLedgerClosingBalance(Mgr.LastCodePrinted,
                                   Mgr.ReportJob,
                                   Mgr.AccountHasActivity,
                                   Mgr.LastCodePrinted = Mgr.LastValidCode);
      // Need subtotals to calculate closing bal so do not clear during the subtotal printing
      // only safe to clear once closing balances have been printed
      TListLedgerReport(Mgr.ReportJob).ClearSubTotals;
      TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
    end;
    TListLedgerReport(Mgr.ReportJob).SplitCode := '';

    //handle in between codes
    // Show inactive codes and contras if requested (that are between last code and this code)
    if (Mgr.LastCodePrinted = NullCode) or
       (Mgr.LastValidCode = NullCode) then
      AccRec := ReportParams.Chart.FindNextCode('', False) // finds first code
    else if Mgr.LastCodePrinted <> Mgr.LastValidCode then
      AccRec := ReportParams.Chart.FindNextCode(Mgr.LastValidCode, False)
    else
      AccRec := ReportParams.Chart.FindNextCode(Mgr.LastCodePrinted, False);

    // Some conditions to handle invalid codes
    OKToPrint := (not IsValidCode) and
                 (Assigned(AccRec)) and
                 (AccRec^.chAccount_Code < Code); // this code is invalid but next valid code is less than this one - need to show it

    OKToPrint := ((not OKToPrint) and
                  (Assigned(AccRec)) and
                 (not IsValidCode) and
                 (mgr.LastCodePrinted = mgr.LastValidCode) and
                 (mgr.LastCodePrinted <> NULLCODE)) and // this code is invalid but last was valid - need to show any between last and this
                 (not ReportParams.Client.clBank_Account_List.IsExchangeGainLossCode(AccRec.chAccount_Code));

    if Assigned(AccRec) and
       (IsValidCode or OKToPrint) then
    begin
      while (Code <> '') and
            (AccRec^.chAccount_Code <> Code) and
            (AccRec^.chAccount_Code < Code) do
      begin
        //is code in range?
        if TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( AccRec^.chAccount_Code, CodeSelected) then
        begin
          RendStr := AccRec^.chAccount_Code + '  ' + AccRec^.chAccount_Description;
          IsContras := IsThisAContraCode(AccRec^.chAccount_Code, Mgr.ReportJob);

          // show if contra or showing empty posting codes or showing non-posting codes with a balance
          if (IsContras or ((ReportParams.PrintEmptyCodes and (not AccRec^.chInactive or CodeSelected)) and
              (AccRec^.chPosting_Allowed or
               (ReportParams.ShowBalances and
                (GetOpeningBalanceAmount(ReportParams.Client,AccRec^.chAccount_Code) <> 0))))) then
          begin
            Mgr.ReportJob.RenderTitleLine(RendStr);

            TListLedgerReport(Mgr.ReportJob).SplitCode := RendStr + ' (continued)';

            if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
              ReportLedgerOpeningBalance(AccRec^.chAccount_Code, Mgr.ReportJob, True);

            if IsContras then
              DoContras(Mgr.ReportJob, AccRec^.chAccount_Code);

            if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
              ReportLedgerClosingBalance(AccRec^.chAccount_Code, Mgr.ReportJob, IsContras);

            TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
            TListLedgerReport(Mgr.ReportJob).SplitCode := '';
            TListLedgerReport(Mgr.ReportJob).ClearSubTotals;
            Mgr.LastValidCode := AccRec^.chAccount_Code;
          end;
        end;
        AccRec := ReportParams.Chart.FindNextCode(AccRec^.chAccount_Code, False);

        if not Assigned(AccRec) then
          Break;
      end;

      //Now we start to print the new code
      if Code = '' then
        RendStr := 'Uncoded'
      else
      begin
        AccRec := ReportParams.Chart.FindCode( Code );

        if Assigned( AccRec ) then
          RendStr := Code + '  ' + AccRec^.chAccount_Description
        else
          RendStr := Code + '  INVALID CODE!';
      end;

      Mgr.ReportJob.RenderTitleLine (RendStr);
      TListLedgerReport(Mgr.ReportJob).SplitCode := RendStr + ' (continued)';
      Mgr.LastCodePrinted := Code;

      if IsValidCode then
        Mgr.LastValidCode := Code;

      // Show opening balance if requested
      if ReportParams.ShowBalances and (Code <> '') then
        ReportLedgerOpeningBalance(Code, Mgr.ReportJob, True, Assigned(AccRec));

      // Show contras for this code - this will display ALL transactions
      // for this code (so that they display in date order)
      // so after this we need to move onto next code (as per skipping txns earlier in this proc)
      if IsThisAContraCode(Code, Mgr.ReportJob) then
      begin
        Mgr.AccountHasActivity := DoContras(Mgr.ReportJob, Code);
        Mgr.ContraCodePrinted := Code;
        Exit;
      end;
    end;
  end;

  Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ) );

  RefStr := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
  Mgr.ReportJob.PutString( RefStr );

  if Mgr.Quantities then
  begin
    Net := TranRec.txTemp_Base_Amount - TranRec.txGST_Amount;
    Qty := TranRec.txQuantity;
    Avg := calcAverage(Net/100,Qty/10000);
  end
  else
  begin
    Qty := 0;
    Avg := 0;
  end;

  if ReportParams.ShowNotes then
    Notes := GetFullNotes(Mgr.Transaction)
  else
    Notes := '';

  TListLedgerReport(Mgr.ReportJob).PutWrapped(GetNarration(Mgr.Transaction,
                                                           Mgr.Bank_Account.baFields.baAccount_Type),
                                              TranRec.txGST_Class,
                                              TranRec.txTemp_Base_Amount,
                                              TranRec.txGST_Amount,
                                              TranRec.txTemp_Base_Amount - TranRec.txGST_Amount,
                                              Qty,
                                              Avg,
                                              Notes);

  Mgr.ReportJob.RenderDetailLine;
  Mgr.AccountHasActivity := True;
end;

//------------------------------------------------------------------------------
procedure LGR_PrintDissect(aSender : Tobject);
// similar logic to printing a non-dissection above
var
  Code : Bk5CodeStr;
  AccRec : pAccount_Rec;
  RendStr, Notes, Narration : String;
  RefStr : string[20];
  Mgr : TListLedgerTMgr;
  Net : Money;
  Qty : Money;
  Avg : Currency;
  IsContras, IsValidCode, OKToPrint: Boolean;
  Report : TListLedgerReport;
  ReportParams : TLRParameters;
  TranRec : TTransaction_Rec;
  DissRec : tDissection_Rec;
  CodeSelected : boolean;
begin
  Mgr := TListLedgerTMgr(aSender);
  Report := TListLedgerReport(Mgr.ReportJob);
  ReportParams := Report.Params;
  TranRec := Mgr.Transaction^;
  DissRec := Mgr.Dissection^;
  Code := DissRec.dsAccount;

  //is bank account included in this report?
  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
   Exit;

  //is code in range?
  if not TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( Code, CodeSelected) then
    exit;

  // has tx already been printed during contras?
  if (Code = Mgr.ContraCodePrinted) and (Mgr.ContraCodePrinted <> NullCode) then
    exit;

  Mgr.ContraCodePrinted := NullCode;
  IsValidCode := Assigned(ReportParams.Chart.FindCode( Code ));

//code has changed, handle closing balance

  If Code <> Mgr.LastCodePrinted then
  Begin
     If Mgr.LastCodePrinted <> NullCode then begin
       if not TListLedgerReport(Mgr.ReportJob).DoneSubTotal then
         Mgr.ReportJob.RenderDetailSubTotal('', False, true);
       // Show closing balance if requested
       if ReportParams.ShowBalances and (Mgr.LastCodePrinted <> '') then
         ReportLedgerClosingBalance(Mgr.LastCodePrinted, Mgr.ReportJob, Mgr.AccountHasActivity, Mgr.LastCodePrinted = Mgr.LastValidCode);
       TListLedgerReport(Mgr.ReportJob).ClearSubTotals;
       TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
     end;
     TListLedgerReport(Mgr.ReportJob).SplitCode := '';

//handle codes in between

     // Show inactive codes if requested
     if (Mgr.LastCodePrinted = NullCode) or (Mgr.LastValidCode = NullCode) then
       AccRec := ReportParams.Chart.FindNextCode('', False)
     else if Mgr.LastCodePrinted <> Mgr.LastValidCode then
       AccRec := ReportParams.Chart.FindNextCode(Mgr.LastValidCode, False)
     else
       AccRec := ReportParams.Chart.FindNextCode(Mgr.LastCodePrinted, False);

     // Some conditions to handle invalid codes
     OKToPrint := ((not IsValidCode) and Assigned(AccRec) and (AccRec^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                  ((not IsValidCode) and (Mgr.LastCodePrinted = Mgr.LastValidCode) and (Mgr.LastCodePrinted <> NULLCODE)) and // this code is invalid but last was valid - need to show any between last and this
                  (not ReportParams.Client.clBank_Account_List.IsExchangeGainLossCode(AccRec.chAccount_Code));
                      
     if Assigned(AccRec) and (IsValidCode or OKToPrint) then
       while (Code <> '') and (AccRec^.chAccount_Code <> Code) and (AccRec^.chAccount_Code < Code) do
       begin
         //is code in range?
         if TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( AccRec^.chAccount_Code, CodeSelected) then
         begin
           With AccRec^ do RendStr := chAccount_Code + '  ' + chAccount_Description;
           IsContras := IsThisAContraCode(AccRec^.chAccount_Code, Mgr.ReportJob);
           if (IsContras or ((ReportParams.PrintEmptyCodes and (not AccRec^.chInactive or CodeSelected)) and
                   (AccRec^.chPosting_Allowed or (ReportParams.ShowBalances and (GetOpeningBalanceAmount(ReportParams.Client,AccRec^.chAccount_Code) <> 0))))) then
           begin
             Mgr.ReportJob.RenderTitleLine(RendStr);
             TListLedgerReport(Mgr.ReportJob).SplitCode := RendStr + ' (continued)';
             if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
               ReportLedgerOpeningBalance(AccRec^.chAccount_Code, Mgr.ReportJob, True);
             if IsContras then
               DoContras(Mgr.ReportJob, AccRec^.chAccount_Code);
             if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
               ReportLedgerClosingBalance(AccRec^.chAccount_Code, Mgr.ReportJob, IsContras);
             TListLedgerReport(Mgr.ReportJob).SplitCode := '';
             TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
             TListLedgerReport(Mgr.ReportJob).ClearSubTotals;
             Mgr.LastValidCode := AccRec^.chAccount_Code;
           end;
         end;
         AccRec := ReportParams.Chart.FindNextCode(AccRec^.chAccount_Code, False);
         if not Assigned(AccRec) then Break;
       end;

//Start the new code

     if Code = '' then
       RendStr := 'Uncoded'
     else
     begin
       AccRec := ReportParams.Chart.FindCode( Code );
       If Assigned( AccRec ) then
          With AccRec^ do RendStr := Code + '  ' + chAccount_Description
       else
          RendStr := Code + '  INVALID CODE!';
     end;

     Mgr.ReportJob.RenderTitleLine(RendStr);
     TListLedgerReport(Mgr.ReportJob).SplitCode := RendStr + ' (continued)';
     Mgr.LastCodePrinted := Code;
     if IsValidCode then
      Mgr.LastValidCode := Code;

     // Show opening balance if requested
     if ReportParams.ShowBalances and (Code <> '') then
       ReportLedgerOpeningBalance(Code, Mgr.ReportJob, True, Assigned(AccRec));

     // Show contras for this code - this will display ALL transactions
     // for this code (so that they display in date order)
     // so after this we need to move onto next code
     if IsThisAContraCode(Code, Mgr.ReportJob) then
     begin
       Mgr.AccountHasActivity := DoContras(Mgr.ReportJob, Code);
       Mgr.ContraCodePrinted := Code;
       Exit;
     end;
  end;

  {now do dissection}
  if Mgr.Bank_Account.IsAJournalAccount then
    Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ))
  else
    Mgr.ReportJob.PutString( bkDate2Str ( TranRec.txDate_Effective ) + ' [D]');

  if length(DissRec.dsReference) > 0 then
    RefStr := DissRec.dsReference
  else
    RefStr := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);

  Mgr.ReportJob.PutString( RefStr );

  If Mgr.Quantities then
  begin
    //qty is shown as +ve as long as signs match
    Net := DissRec.dsTemp_Base_Amount - DissRec.dsGST_Amount;
    Qty := DissRec.dsQuantity;
    Avg := calcAverage(Net/100,Qty/10000);
  end
  else
  begin
    Qty := 0;
    Avg := 0;
  end;

  if ReportParams.ShowNotes then
    Notes := GetFullNotes(Mgr.Dissection)
  else
    Notes := '';

  Narration := GetNarration( Mgr.Dissection, Mgr.Bank_Account.baFields.baAccount_Type);

  TListLedgerReport(Mgr.ReportJob).PutWrapped(Narration, DissRec.dsGST_Class,
    DissRec.dsTemp_Base_Amount, DissRec.dsGST_Amount, DissRec.dsTemp_Base_Amount - DissRec.dsGST_Amount, Qty, Avg, Notes);

  Mgr.ReportJob.RenderDetailLine;
  Mgr.AccountHasActivity := True;
end;

//------------------------------------------------------------------------------
procedure LGR_PrintExchangeGainLoss(aSender: TObject);
var
  AccRec: pAccount_Rec;
  Mgr : TListLedgerTMgr;
  Code  : Bk5CodeStr;
  RendStr, Notes : String;
  IsContras, IsValidCode, OKToPrint: Boolean;
  Report : TListLedgerReport;
  ReportParams : TLRParameters;
  TranRec : TTransaction_Rec;
  CodeSelected : boolean;
begin
  Mgr := TListLedgerTMgr(aSender);
  Report := TListLedgerReport(Mgr.ReportJob);
  ReportParams := Report.Params;
  TranRec := Mgr.Transaction^;
  Code := Mgr.ExchangeGainLossEntry.glAccount;

  //is bank account included in this report?
  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
    exit;

  //is code in range?
  if not TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport(Code, CodeSelected) then
    exit;

  IsValidCode := Assigned(ReportParams.Chart.FindCode(Code));

  if Code <> Mgr.LastCodePrinted then // its a new code
  begin
    // end last code
    if Mgr.LastCodePrinted <> NullCode then
    begin
      if not TListLedgerReport(Mgr.ReportJob).DoneSubTotal then // avoid duplicate subtotals
        Mgr.ReportJob.RenderDetailSubTotal('', False, True);

      // Show closing balance if requested
      if ReportParams.ShowBalances and
         (Mgr.LastCodePrinted <> '') then
        ReportLedgerClosingBalance(Mgr.LastCodePrinted,
                                   Mgr.ReportJob,
                                   Mgr.AccountHasActivity,
                                   Mgr.LastCodePrinted = Mgr.LastValidCode);

      // Need subtotals to calculate closing bal so do not clear during the subtotal printing
      // only safe to clear once closing balances have been printed
      TListLedgerReport(Mgr.ReportJob).ClearSubTotals;
      TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
    end;

    TListLedgerReport(Mgr.ReportJob).SplitCode := '';

    if (Mgr.LastCodePrinted = NullCode) or
       (Mgr.LastValidCode = NullCode) then
      AccRec := ReportParams.Chart.FindNextCode('', False) // finds first code
    else if Mgr.LastCodePrinted <> Mgr.LastValidCode then
      AccRec := ReportParams.Chart.FindNextCode(Mgr.LastValidCode, False)
    else
      AccRec := ReportParams.Chart.FindNextCode(Mgr.LastCodePrinted, False);

    // Some conditions to handle invalid codes
    OKToPrint := ((not IsValidCode) and
                  Assigned(AccRec) and
                  (AccRec^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                 ((not IsValidCode) and
                  (Mgr.LastCodePrinted = Mgr.LastValidCode) and
                  (Mgr.LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this

    if Assigned(AccRec) and
       (IsValidCode or OKToPrint) then
    begin
      while (Code <> '') and
            (AccRec^.chAccount_Code <> Code) and
            (AccRec^.chAccount_Code < Code) do
      begin
        //is code in range?
        if TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( AccRec^.chAccount_Code, CodeSelected) then
        begin
          RendStr := AccRec^.chAccount_Code + '  ' + AccRec^.chAccount_Description;

          IsContras := IsThisAContraCode(AccRec^.chAccount_Code, Mgr.ReportJob);

          // show if contra or showing empty posting codes or showing non-posting codes with a balance
          if (IsContras or
              ((ReportParams.PrintEmptyCodes and (not AccRec^.chInactive or CodeSelected)) and
               ReportParams.Client.clBank_Account_List.IsExchangeGainLossCode(AccRec.chAccount_Code) and
              (AccRec^.chPosting_Allowed or
              (ReportParams.ShowBalances and
              (GetOpeningBalanceAmount(ReportParams.Client, AccRec^.chAccount_Code) <> 0))))) then
          begin
            Mgr.ReportJob.RenderTitleLine(RendStr);

            TListLedgerReport(Mgr.ReportJob).SplitCode := RendStr + ' (continued)';

            if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
              ReportLedgerOpeningBalance(AccRec^.chAccount_Code, Mgr.ReportJob, True);

            if IsContras then
              DoContras(Mgr.ReportJob, AccRec^.chAccount_Code);

            if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
              ReportLedgerClosingBalance(AccRec^.chAccount_Code, Mgr.ReportJob, False);

            TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
            TListLedgerReport(Mgr.ReportJob).SplitCode := '';
            TListLedgerReport(Mgr.ReportJob).ClearSubTotals;

            Mgr.LastValidCode := AccRec^.chAccount_Code;
          end;
        end;

        AccRec := ReportParams.Chart.FindNextCode(AccRec^.chAccount_Code, False);

        if not Assigned(AccRec) then
          Break;
      end;
    end;

    //Now we start to print the new code
    AccRec := nil;
    if Code = '' then
    begin
      RendStr := 'Uncoded';
    end
    else
    begin
      AccRec := ReportParams.Chart.FindCode( Code );

      If Assigned( AccRec ) then
        RendStr := Code + '  ' + AccRec^.chAccount_Description
      else
        RendStr := Code + '  INVALID CODE!';
    end;

    Mgr.ReportJob.RenderTitleLine(RendStr);
    TListLedgerReport(Mgr.ReportJob).SplitCode := RendStr + ' (continued)';
    Mgr.LastCodePrinted := Code;

    if IsValidCode then
    begin
      Mgr.LastValidCode := Code;
    end;

    // Show opening balance if requested
    if ReportParams.ShowBalances and (Code <> '') then
      ReportLedgerOpeningBalance(Code, Mgr.ReportJob, True, Assigned(AccRec));

    // Show contras for  this code - this will display ALL transactions
    // for this code (so that they display in date order)
    // so after this we need to move onto next code (as per skipping txns earlier in this proc)
    if IsThisAContraCode(Code, Mgr.ReportJob) then
    begin
      Mgr.AccountHasActivity := DoContras(Mgr.ReportJob, Code);
      Mgr.ContraCodePrinted := Code;
      Exit;
    end;
  end;

  Mgr.ReportJob.PutString(bkDate2Str(Mgr.ExchangeGainLossEntry.glDate));

  Mgr.ReportJob.SkipColumn;

  TListLedgerReport(Mgr.ReportJob).PutWrapped('',
                                              0,
                                              Mgr.ExchangeGainLossEntry.glAmount,
                                              0,
                                              Mgr.ExchangeGainLossEntry.glAmount,
                                              0,
                                              0,
                                              Notes);

  Mgr.ReportJob.RenderDetailLine;
  Mgr.AccountHasActivity := True;
end;

//------------------------------------------------------------------------------
procedure SummaryListLedger_PrintExchangeGainLoss(aSender : TObject);
var
  Code    : Bk5CodeStr;
  Mgr     : TListLedgerTMgr;
  AccRec  : pAccount_Rec;
  RendStr : string;
  IsContras, IsEmpty, IsValidCode, OKToPrint: Boolean;
  Report : TListLedgerReport;
  ReportParams : TLRParameters;
  TranRec : TTransaction_Rec;
  CodeSelected : boolean;
  CodeActive : boolean;
begin
  Mgr := TListLedgerTMgr(aSender);
  Report := TListLedgerReport(Mgr.ReportJob);
  ReportParams := Report.Params;
  TranRec := Mgr.Transaction^;
  Code := Mgr.ExchangeGainLossEntry.glAccount;

   //with Mgr, ReportJob,TListLedgerReport(ReportJob).Params, Mgr.Transaction^ do
   //begin
  if not IsBankAccountIncluded(Mgr.ReportJob, Mgr) then
    Exit;

  //is code in range?
  if not TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( Code, CodeSelected) then
    Exit;

  AccRec := ReportParams.Chart.FindCode( Code );
  IsValidCode := Assigned(AccRec);

  CodeActive := true;
  if Assigned(AccRec) then
    CodeActive := not AccRec^.chInactive;

  //code has changed
  if (Code <> Mgr.LastCodePrinted) then
  begin
    if (Mgr.LastCodePrinted <> NullCode) then
    begin
      //code has changed so print totals
      if (Mgr.AccountHasActivity or (ReportParams.PrintEmptyCodes and (CodeActive or CodeSelected))) and
         (not TListLedgerReport(Mgr.ReportJob).DoneSubTotal) then
        PrintSummaryListLedgerLine(Mgr, Mgr.LastCodePrinted, TListLedgerReport(Mgr.ReportJob));

      // Show closing balance if requested
      if ReportParams.ShowBalances and (Mgr.LastCodePrinted <> '') then
      begin
        ReportLedgerClosingBalance(Mgr.LastCodePrinted,
                                   Mgr.ReportJob,
                                   False,
                                   Mgr.LastCodePrinted = Mgr.LastValidCode);

        TListLedgerReport(Mgr.ReportJob).SplitCode := '';
        Mgr.ReportJob.RenderTextLine('');
      end;
    end;

     //clear temp information
     Mgr.AccountHasActivity := false;
     Mgr.AccountTotalGross  := 0;
     Mgr.AccountTotalTax    := 0;
     Mgr.AccountTotalNet    := 0;
     Mgr.AccountTotalQuantity:= 0;
     TListLedgerReport(Mgr.ReportJob).DoneSubTotal := False;
     TListLedgerReport(Mgr.ReportJob).SplitCode := '';
     TListLedgerReport(Mgr.ReportJob).ClearSubTotals;

     //Clear Super
     Mgr.ClearSuper;

     //request to show all codes regardless of any activity
     //look for all codes in between last (valid) one printed and next to be printed
     if (Mgr.LastCodePrinted = NullCode) or
        (Mgr.LastValidCode = NullCode) then
       AccRec := ReportParams.Chart.FindNextCode('', False)
     else if Mgr.LastCodePrinted <> Mgr.LastValidCode then
       AccRec := ReportParams.Chart.FindNextCode(Mgr.LastValidCode, False)
     else
       AccRec := ReportParams.Chart.FindNextCode(Mgr.LastCodePrinted, False);
         
     // Some conditions to handle invalid codes
     OKToPrint := ((not IsValidCode) and
                   Assigned(AccRec) and
                   (AccRec^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                  ((not IsValidCode) and
                   (Mgr.LastCodePrinted = Mgr.LastValidCode) and
                   (Mgr.LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this

     if Assigned(AccRec) and
       (IsValidCode or
        OKToPrint) then
     begin
       while (Code <> '') and
             (AccRec^.chAccount_Code <> Code) and
             (AccRec^.chAccount_Code < Code) do
       begin
         //is code in range?
         if TListLedgerReport(Mgr.ReportJob).ShowCodeOnReport( AccRec^.chAccount_Code, CodeSelected) then
         begin
           IsContras := IsThisAContraCode(AccRec^.chAccount_Code, Mgr.ReportJob);
           IsEmpty := (ReportParams.PrintEmptyCodes and (not AccRec^.chInactive or CodeSelected)) and
                      (AccRec^.chPosting_Allowed or
                       (ReportParams.ShowBalances and
                        (GetOpeningBalanceAmount(ReportParams.Client, AccRec^.chAccount_Code) <> 0)));

           if IsContras or IsEmpty then
           begin
             if ReportParams.ShowBalances and
                (AccRec^.chAccount_Code <> '') then
             begin
               Mgr.ReportJob.RenderTitleLine(AccRec^.chAccount_Code + ' ' + AccRec^.chAccount_Description);

               Report.SplitCode := AccRec^.chAccount_Code + ' ' + AccRec^.chAccount_Description + ' (continued)';

               ReportLedgerOpeningBalance(AccRec^.chAccount_Code, Mgr.ReportJob, False);
             end;

             if IsContras then
             begin
               Report.SplitCode := AccRec^.chAccount_Code + ' ' + AccRec^.chAccount_Description + ' (continued)';

               DoContras(Mgr.ReportJob, AccRec^.chAccount_Code)
             end
             else
             begin
               PrintSummaryListLedgerLine( Mgr, AccRec^.chAccount_Code, Report);
             end;

             if ReportParams.ShowBalances and (AccRec^.chAccount_Code <> '') then
             begin
               ReportLedgerClosingBalance(AccRec^.chAccount_Code, Mgr.ReportJob, False);

               Report.SplitCode := '';

               Mgr.ReportJob.RenderTextLine('');
             end
             else
             begin
               TListLedgerReport(Mgr.ReportJob).SplitCode := '';
             end;

             Mgr.LastValidCode := AccRec^.chAccount_Code;
           end;
         end;

         AccRec := ReportParams.Chart.FindNextCode(AccRec^.chAccount_Code, False);

         Report.ClearSubTotals;

         if not Assigned(AccRec) then
           Break;
       end;
     end;

     // starting a new code

     Mgr.LastCodePrinted := Code;
     if IsValidCode then
       Mgr.LastValidCode := Code;
         
     Report.DoneSubTotal := False;
     Report.SplitCode := '';

     // Show opening balance if requested
     if ReportParams.ShowBalances and (Code <> '') then
     begin
       AccRec := ReportParams.Chart.FindCode( Code );

       If Assigned( AccRec ) then
         RendStr := Code + '  ' + AccRec^.chAccount_Description
       else
         RendStr := Code + '  INVALID CODE!';

       Mgr.ReportJob.RenderTitleLine(RendStr);
       Report.SplitCode := RendStr + ' (continued)';

       ReportLedgerOpeningBalance(Code, Mgr.ReportJob, False, Assigned(AccRec));
     end;

     // Show contras for this code - this will display ALL transactions
     // for this code (so that they display in date order)
     // so after this we need to move onto next code
     if IsThisAContraCode(Code, Mgr.ReportJob) then
     begin
       Mgr.AccountHasActivity := DoContras(Mgr.ReportJob, Code);
       Mgr.ContraCodePrinted := Code;

       Exit;
     end;
  end;

  //store values
  Mgr.AccountTotalGross := Mgr.AccountTotalGross + Mgr.ExchangeGainLossEntry.glAmount;
  Mgr.AccountTotalNet   := Mgr.AccountTotalNet   + Mgr.ExchangeGainLossEntry.glAmount;

  if Mgr.ExchangeGainLossEntry.glAmount <> 0 then
    Mgr.AccountHasActivity := True;
end;

//------------------------------------------------------------------------------
procedure TListLedgerReport.PutWrapped(aNarration: string;
                                       aGSTClass: Byte;
                                       aGross: Comp;
                                       aGST: Comp;
                                       aNet: Comp;
                                       aQty: Comp;
                                       aAvg: Currency;
                                       aNotes: string);
// add narration notes to ledger report and allow them to span 10 lines max
const
  MaxNotesLines = 10;
var
  Index, ColWidth, OldWidth : Integer;
  NotesList, NarrationList  : TStringList;
  NarrationDone, NotesDone: Boolean;
begin
  NarrationDone := False;
  NotesDone := False;

  NotesList     := TStringList.Create;
  NarrationList := TStringList.Create;
  try
    NotesList.Text := aNotes;
    NarrationList.Text := aNarration;
    // Remove blank lines
    Index := 0;

    while Index < NotesList.Count do
    begin
      if NotesList[Index] = '' then
        NotesList.Delete(Index)
      else
        Inc(Index);
    end;

    Index := 0;
    while Index < NarrationList.Count do
    begin
      if NarrationList[Index] = '' then
        NarrationList.Delete(Index)
      else
        Inc(Index);
    end;

    Index := 0;
    repeat
      // Wrap Narration
      if (Index < NarrationList.Count) and
         (not NarrationDone) then
      begin
        ColWidth := RenderEngine.RenderColumnWidth(CurrDetail.Count, NarrationList[ Index]);
        if (ColWidth < Length(NarrationList[Index])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store

          while (ColWidth > 0) and (NarrationList[Index][ColWidth] <> ' ') do
            Dec(ColWidth);

          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!

          NarrationList.Insert(Index + 1,
                               Copy(NarrationList[Index],
                               ColWidth + 1,
                               Length(NarrationList[Index]) - ColWidth + 1));
          NarrationList[Index] := Copy(NarrationList[Index], 1, ColWidth);
        end;

        PutString( NarrationList[ Index]);

        if not Params.WrapNarration then
          NarrationDone := True;
      end
      else // May still be some more notes to print
        SkipColumn;

      if Index = 0 then // First line - add other detail
      begin
        if params.GrossGST then
        begin
          if (aGSTClass = 0) then
            SkipColumn
          else
            PutString( GetGSTClassCode(Params.Client, aGSTClass));

          PutMoney( aGross );
          PutMoney( aGST );
        end;

        PutMoney( aGross - aGST );

        If Params.ShowQuantity then
        begin
          PutQuantity( aQty);
          PutCurrency( aAvg);
        end;
      end
      else // Other detail already printed - skip columns
      begin
        if Params.GrossGST then
        begin
          SkipColumn; // GST class
          SkipColumn; // Gross
          SkipColumn; // GST
        end;

        SkipColumn; // Net

        if Params.ShowQuantity then
        begin
          SkipColumn; // Qty
          SkipColumn; // Avg
        end;
      end;

      // Wrap Notes
      if (Index < NotesList.Count) and (not NotesDone) then
      begin
        ColWidth := RenderEngine.RenderColumnWidth(CurrDetail.Count, NotesList[ Index]);

        if (ColWidth < Length(NotesList[Index])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store

          while (ColWidth > 0) and (NotesList[Index][ColWidth] <> ' ') do
            Dec(ColWidth);

          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!

          NotesList.Insert(Index + 1, Copy(NotesList[Index], ColWidth + 1, Length(NotesList[Index]) - ColWidth + 1));
          NotesList[Index] := Copy(NotesList[Index], 1, ColWidth);
        end;

        PutString( NotesList[ Index]);

        if not Params.WrapNarration then
          NotesDone := True;
      end
      else // May still be some more narration to print
        SkipColumn;

      Inc( Index);

      //decide if need to call renderDetailLine
      if (((Index < NotesList.Count) and
           (not NotesDone)) or
          ((Index < NarrationList.Count) and
           (not NarrationDone))) and
         ( Index < MaxNotesLines) then
      begin
        RenderDetailLine(False);
        SkipColumn; // Date
        SkipColumn; // Reference
      end;

    until (((Index >= NotesList.Count) or NotesDone) and
           ((Index >= NarrationList.Count) or
            NarrationDone)) or
          (Index >= MaxNotesLines);

  finally
    NotesList.Free;
    NarrationList.Free;
  end;
end;

//------------------------------------------------------------------------------
function TListLedgerReport.ShowCodeOnReport(aCode: string; var aCodeSelected : boolean): boolean;
var
  RangeArrIndex : integer;
begin
  result := true;
  aCodeSelected := false;

  if Params.ShowAllCodes then
  begin
    if ( aCode <> '') then
      exit;
  end
  else
  begin
    for RangeArrIndex := Low( Params.RangesArray) to High( Params.RangesArray) do
    begin
      with Params.RangesArray[RangeArrIndex] do
      begin
        if ( ToCode <> '') then
        begin
          if (Params.Client.AccountCodeCompare(aCode, FromCode) >= 0) and
             (Params.Client.AccountCodeCompare(aCode, ToCode) <= 0) then
          begin
            aCodeSelected := true;
            Exit;
          end;
        end
        else
          //special case, if only a from code is specified then match
          //on the specific code
          if (FromCode <> '') and
             (FromCode = aCode) then
          begin
            aCodeSelected := true;
            Exit;
          end;
      end;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
procedure TListLedgerReport.BKPrint;
var
  TravMgr : TListLedgerTMgr;
  AccRec : pAccount_Rec;
  RendStr : string;
  IsContras : Boolean;
  CodeSelected : Boolean;
begin
  NET_AMOUNT_CAPTION := Params.Client.CurrencySymbol + ' Net';

  TravMgr := TListLedgerTMgr.Create;
  try
    TravMgr.Name := 'Main Trav Mgr';
    TravMgr.Clear;
    TravMgr.SortType             := csAccountCode;
    TravMgr.SelectionCriteria    := TravList.twAllEntries;
    TravMgr.ReportJob            := Self;

    TravMgr.AccountTotalGross    := 0;
    TravMgr.AccountTotalTax      := 0;
    TravMgr.AccountTotalNet      := 0;
    TravMgr.AccountTotalQuantity := 0;
    TravMgr.AccountHasActivity   := false;
    TravMgr.LastCodePrinted      := NullCode;
    TravMgr.ContraCodePrinted    := NullCode;
    TravMgr.LastValidCode        := NullCode;
    TravMgr.Quantities           := Params.ShowQuantity;

    //decide what to do with each code
    if Params.ShowSuperDetails then
    begin
      if Params.SummaryReport then
      begin
        TravMgr.OnEnterEntry      := SummaryListLedger_PrintEntry;
        TravMgr.OnEnterDissection := SummaryListLedger_PrintDissect;
      end
      else
      begin
        TravMgr.OnEnterEntry      := Custom_LGR_PrintEntry;
        TravMgr.OnEnterDissection := Custom_LGR_PrintDissect;
      end;
    end
    else if Params.SummaryReport then
    begin
      TravMgr.OnEnterEntry      := SummaryListLedger_PrintEntry;
      TravMgr.OnEnterDissection := SummaryListLedger_PrintDissect;

      if IsForeignCurrencyClient then
        TravMgr.OnEnterExchangeGainLoss := SummaryListLedger_PrintExchangeGainLoss;
    end
    else
    begin
      TravMgr.OnEnterEntry      := LGR_PrintEntry;
      TravMgr.OnEnterDissection := LGR_PrintDissect;

      if IsForeignCurrencyClient then
        TravMgr.OnEnterExchangeGainLoss := LGR_PrintExchangeGainLoss;
    end;

    DoneSubTotal := False;
    SplitCode := '';

    //transactions are sorted into code order, traverse through the codes
    if Params.IncludeNonTransferring then
      TravMgr.TraverseAllEntries(Params.Fromdate,Params.Todate)
    else
      TravMgr.TraverseAllEntries(Params.Fromdate, Params.ToDate, BKCONST.TransferringJournalsSet);

    //need to print final figures for last code
    if Params.Summaryreport then
    begin
      if (TravMgr.AccountHasActivity or Params.PrintEmptyCodes) and
         (not DoneSubTotal) and
         (TravMgr.LastCodePrinted <> NullCode) then
        PrintSummaryListLedgerLine( TravMgr, TravMgr.LastCodePrinted, Self);

      if Params.ShowBalances and (TravMgr.LastCodePrinted <> '') and (TravMgr.LastCodePrinted <> NULLCODE) then
      begin
        ReportLedgerClosingBalance(TravMgr.LastCodePrinted, Self, False, TravMgr.LastCodePrinted = TravMgr.LastValidCode);
        SplitCode := '';
        RenderTextLine('');
      end;
    end
    else
    begin
      if TravMgr.AccountHasActivity then
      begin
        if Params.ShowBalances and (TravMgr.LastCodePrinted = TravMgr.ContraCodePrinted) then
        begin
           //showing balances, last code was a contra code
           ReportLedgerClosingBalance(TravMgr.LastcodePrinted, Self, TravMgr.AccountHasActivity)
        end
        else if (TravMgr.ContraCodePrinted = NullCode) then
        begin
          RenderDetailSubTotal('', False, True);
          // Show closing balance if requested
          if Params.ShowBalances then
            ReportLedgerClosingBalance(TravMgr.LastcodePrinted, Self, TravMgr.AccountHasActivity, TravMgr.LastCodePrinted = TravMgr.LastValidCode);
        end;
      end;
    end;

    // show remaining empty codes
    // Show inactive codes if requested
    TravMgr.AccountTotalGross := 0;
    TravMgr.AccountTotalTax := 0;
    TravMgr.AccountTotalNet := 0;
    TravMgr.AccountTotalQuantity := 0;
    DoneSubTotal := False;
    SplitCode := '';
    ClearSubTotals;

    if TravMgr.LastValidCode = NullCode then
      AccRec := Params.Chart.FindNextCode('', False)
    else
      AccRec := Params.Chart.FindNextCode(TravMgr.LastValidCode, False);

    if Assigned(AccRec) then
    begin
      while Assigned(AccRec) do
      begin
        //is code in range?
        if ShowCodeOnReport( AccRec^.chAccount_Code, CodeSelected) then
        begin
          RendStr := AccRec^.chAccount_Code + '  ' + AccRec^.chAccount_Description;
          IsContras := IsThisAContraCode(AccRec^.chAccount_Code, Self);

          if IsContras or
             ((Params.PrintEmptyCodes and (not AccRec^.chInactive or CodeSelected)) and
              (AccRec^.chPosting_Allowed or
               (Params.ShowBalances and
                (GetOpeningBalanceAmount(Params.Client,AccRec^.chAccount_Code) <> 0)))) and
              not HasExchangeGainLossEntries(AccRec^.chAccount_Code, Params) then
          begin
            if (not Params.SummaryReport) or
               Params.ShowBalances then
            begin
              RenderTitleLine(RendStr);
              SplitCode := RendStr + ' (continued)';
            end;

            if Params.ShowBalances and (AccRec^.chAccount_Code <> '') then
              ReportLedgerOpeningBalance(AccRec^.chAccount_Code, Self, not Params.SummaryReport);

            if IsContras then
              DoContras(Self, AccRec^.chAccount_Code)
            else if Params.Summaryreport then
              PrintSummaryListLedgerLine( TravMgr, AccRec^.chAccount_Code, Self);

            if Params.ShowBalances and (AccRec^.chAccount_Code <> '') then
            begin
              ReportLedgerClosingBalance(AccRec^.chAccount_Code, Self, (IsContras and (not Params.Summaryreport)));
              SplitCode := '';

              if Params.SummaryReport then
                RenderTextLine('');
            end;
          end;
          SplitCode := '';
        end;
        AccRec := Params.Chart.FindNextCode(AccRec^.chAccount_Code, False);
        ClearSubTotals;
      end;
    end;

    if Params.ShowBalances then
    begin
      RenderTextLine('');
      RenderTextLine('');
    end;
    RenderDetailGrandTotal('');

    if Params.SpanYear then
    begin
      RenderTextLine('* This report spans a financial year.');
      RenderTextLine('  The closing balance is calculated using the opening balance of the financial year starting ' +
      bkDate2Str(params.Client.clFields.cltemp_FRS_from_Date));
      RenderTextLine('  plus the movement up to ' + bkDate2Str(Params.Todate));
    end;
  finally
    TravMgr.Free;
  end;
end;

//------------------------------------------------------------------------------
// summary list ledger displays totals for codes rather than transactions
procedure GenerateSummaryListLedgerReport( aDest : TReportDest; aJob : TListLedgerReport);
var
  TitleStr : string;
  CLeft, CGap : double;
  AvgQuantityCol : TReportColumn;
  AvgValueCol    : TReportColumn;
  MoreWidth: Integer;
  KeepGST: Boolean;
  CSym : String;
  TaxName : String;
begin
  NET_AMOUNT_CAPTION := aJob.Params.Client.CurrencySymbol + ' Net';

  CSym := aJob.params.Client.CurrencySymbol;
  TaxName := aJob.params.Client.TaxSystemNameUC;

  KeepGST := aJob.params.Client.clFields.clGST_Inclusive_Cashflow;
  aJob.params.Client.clFields.clGST_Inclusive_Cashflow := False;

  CalculateAccountTotalsForClient(aJob.params.Client,
                                  True,
                                  aJob.Params.AccountList,
                                  -1,
                                  False,
                                  True);

  aJob.params.Client.clFields.clGST_Inclusive_Cashflow := KeepGST;

  aJob.LoadReportSettings(UserPrintSettings,
                          aJob.params.MakeRptName(Report_List_Names[REPORT_SUMMARY_LIST_LEDGER]));

  //Add Headers
  AddCommonHeader(aJob);

  TitleStr := 'FROM ';
  if aJob.Params.FromDate =0 then
    TitleStr := TitleStr + 'FIRST'
  else
    TitleStr := TitleStr + bkDate2Str( aJob.Params.Fromdate );

  TitleStr := TitleStr + ' TO ';
  If aJob.params.ToDate = MaxLongInt then
    TitleStr := TitleStr + 'LAST'
  else
    TitleStr := TitleStr + bkDate2Str( aJob.params.ToDate );

  AddJobHeader(aJob,siTitle,'SUMMARY LEDGER REPORT '+TitleStr, true);
  AddJobHeader(aJob,siSubTitle,'', true);

  CLeft := Gcleft;
  CGap  := GcGap;

  if (aJob.Params.GrossGST) and
     (not aJob.Params.ShowQuantity) then
    MoreWidth := 10
  else
    MoreWidth := 0;

  if aJob.Params.ShowBalances then
    AddColAuto( aJob, cleft, 32.0 + MoreWidth, cGap, DESCRIPTION_CAPTION  ,jtLeft)
  else
  begin
    AddColAuto( aJob, cleft, 10.0, cGap, 'Account'       , jtLeft);
    AddColAuto( aJob, cleft, 22.0 + MoreWidth, cGap, 'Description'  ,jtLeft);
  end;

  if aJob.Params.GrossGST then
  begin
    AddFormatColAuto(aJob, cLeft, 13.0, cGap, CSym + ' Gross', jtRight,NUMBER_FORMAT,NUMBER_FORMAT, true);
    AddFormatColAuto(aJob, cLeft, 13.0, cGap, CSym + ' ' + TaxName,   jtRight,NUMBER_FORMAT,NUMBER_FORMAT, true);
  end;

  AvgValueCol := AddFormatColAuto(aJob, cLeft, 13.0, cGap, NET_AMOUNT_CAPTION, jtRight,NUMBER_FORMAT,NUMBER_FORMAT, true);

  if aJob.Params.ShowQuantity then
  begin
    AvgQuantityCol := AddFormatColAuto(aJob,cLeft,11.0,cGap,'Quantity',jtRight,QUANTITY_FORMAT,QUANTITY_FORMAT,False);
    AddAverageColAuto(aJob,cLeft,10.0,cGap,'Avg '+CSym+' Net',jtRight,NUMBER_FORMAT,NUMBER_FORMAT,False,AvgQuantityCol, AvgValueCol);
  end;

  //Add Footers
  AddCommonFooter(aJob);

  aJob.Generate(aDest, aJob.Params);
end;

//------------------------------------------------------------------------------
procedure GenerateDetailedListLedgerReport( aDest : TReportDest; aJob : TListLedgerReport);
var
  TitleStr : string;
  cleft, cGap : double;
  AvgValueCol : TReportColumn;
  AvgQuantityCol : TReportColumn;
  ExtraWidth, MoreWidthNarration, MoreWidthNotes: double;  //available if not showing quantities
  KeepGST: Boolean;
  CSym : String;
  TaxName : String;
  clFields : TClient_Rec;
  Client : TClientObj;
begin;
  Client := aJob.params.Client;
  clFields := Client.clFields;

  NET_AMOUNT_CAPTION := Client.CurrencySymbol + ' Net';
  CSym := Client.CurrencySymbol;
  TaxName := Client.TaxSystemNameUC;

  KeepGST := clFields.clGST_Inclusive_Cashflow;
  clFields.clGST_Inclusive_Cashflow := False;
  CalculateAccountTotalsForClient(Client, True, aJob.Params.AccountList, -1, False, True);
  clFields.clGST_Inclusive_Cashflow := KeepGST;

  aJob.LoadReportSettings(UserPrintSettings, aJob.params.MakeRptName(Report_List_Names[REPORT_LIST_LEDGER]));

  //Add Headers
  AddCommonHeader(aJob);

  TitleStr := 'FROM ';
  if aJob.Params.Fromdate =0 then
    TitleStr := TitleStr + 'FIRST'
  else
    TitleStr := TitleStr + bkDate2Str(aJob.Params.Fromdate );

  TitleStr := TitleStr + ' TO ';
  if aJob.Params.Todate = MaxLongInt then
    TitleStr := TitleStr + 'LAST'
  else
    TitleStr := TitleStr + bkDate2Str(aJob.Params.ToDate );

  AddJobHeader(aJob, SiSubTitle, 'LEDGER REPORT '+ TitleStr, true);
  AddJobHeader(aJob, SiSubTitle, '', true);

  // Workout the width
  //if we are not showing the quantities then there is extra width available
  //to be used.  quantity takes up 16% so can use 8 extra widths
  if aJob.Params.ShowNotes then
    ExtraWidth := -1.0
  else if aJob.Params.ShowQuantity then
    ExtraWidth := 0.0
  else
    ExtraWidth := 2.0;

  // Build the columns
  CLeft := GcLeft;
  CGap  := Gcgap;

  if not aJob.Params.GrossGST then
  begin
    if aJob.Params.ShowNotes then
    begin
      MoreWidthNotes := 11.0 + ExtraWidth;
      MoreWidthNarration := 17.5 + ExtraWidth;
    end
    else
    begin
      MoreWidthNarration := 23.5 + ExtraWidth;
      MoreWidthNotes := 0 + ExtraWidth;
    end;
  end
  else
  begin
    MoreWidthNarration := 0;
    MoreWidthNotes := 0;
  end;

  AddColAuto(aJob, cleft, 8, cGap, DATE_CAPTION, jtLeft);
  AddColAuto(aJob, cleft, 10.0 + ExtraWidth, cGap, REFERENCE_CAPTION, jtLeft);
  AddColAuto(aJob, cLeft, MoreWidthNarration + 20 + 4 * ExtraWidth, cGap, NARRATION_CAPTION, jtLeft);

  if aJob.Params.GrossGST then
  begin
    AddColAuto(aJob,cLeft, 3.5, cGap, TaxName, jtLeft);
    AddFormatColAuto(aJob, cLeft, 10.0 + ExtraWidth, cGap, CSym + ' Gross', jtRight, NUMBER_FORMAT, NUMBER_FORMAT, true);
    AddFormatColAuto(aJob, cLeft, 10.0 + ExtraWidth, cGap, CSym + ' ' + TaxName, jtRight, NUMBER_FORMAT, NUMBER_FORMAT, true);
  end;

  AvgValueCol := AddFormatColAuto(aJob, cLeft, 10.0 + ExtraWidth, cGap, NET_AMOUNT_CAPTION, jtRight, NUMBER_FORMAT, NUMBER_FORMAT, true);

  if aJob.Params.ShowQuantity then
  begin
    AvgQuantityCol := AddFormatColAuto(aJob, cLeft, 8.0, cGap, 'Quantity', jtRight, QUANTITY_FORMAT, QUANTITY_FORMAT, true);
    AvgQuantityCol.isGrandTotalCol := False;
    AvgQuantityCol := AddAverageColAuto(aJob, cLeft, 8.0, cGap, 'Avg ' + CSym + ' Net', jtRight, NUMBER_FORMAT, NUMBER_FORMAT, True, AvgQuantityCol, AvgValueCol);
    AvgQuantityCol.isGrandTotalCol := False;

    if aJob.Params.ShowNotes then
      AddColAuto(aJob, cLeft, 15.0, cGap, 'Notes', jtLeft);
  end
  else if aJob.Params.ShowNotes then
    AddColAuto(aJob, cLeft, MoreWidthNotes + 25.0, cGap, 'Notes', jtLeft);

  //Add Footers
  AddJobFooter(aJob, siFootNote, '[D] = Part of Dissected Entry', true);
  AddCommonFooter(aJob);

  aJob.Generate(aDest, aJob.Params);
end;

//------------------------------------------------------------------------------
procedure GenerateSuperFundListLedgerReport(aDest: TReportDest; aJob: TListLedgerReport);
var
  TitleStr: string;
  KeepGST: Boolean;
  clFields : TClient_Rec;
  Client : TClientObj;
begin;
  Client := aJob.params.Client;
  clFields := Client.clFields;

  KeepGST := clFields.clGST_Inclusive_Cashflow;
  clFields.clGST_Inclusive_Cashflow := False;
  CalculateAccountTotalsForClient(Client, True, aJob.Params.AccountList);
  clFields.clGST_Inclusive_Cashflow := KeepGST;

  aJob.LoadReportSettings(UserPrintSettings, aJob.params.MakeRptName(Report_List_Names[REPORT_LIST_LEDGER]));

  TitleStr := 'FROM ';
  if aJob.Params.Fromdate =0 then
    TitleStr := TitleStr + 'FIRST'
  else
    TitleStr := TitleStr + bkDate2Str(aJob.Params.Fromdate );

  TitleStr := TitleStr + ' TO ';
  if aJob.Params.Todate = MaxLongInt then
    TitleStr := TitleStr + 'LAST'
  else
    TitleStr := TitleStr + bkDate2Str( aJob.Params.ToDate );

  //Header
  AddCommonHeader(aJob);

  if aJob.Params.SuperfundTitle > '' then
  begin
    if not sametext( 'Hide', aJob.Params.SuperfundTitle) then
      TitleStr := format('%s %s', [aJob.Params.SuperfundTitle, TitleStr])
     // if hide, S jus stays S...
  end else if aJob.Params.SummaryReport then
    TitleStr := 'SUMMARY LEDGER REPORT WITH SUPER DETAILS ' + TitleStr
  else
    TitleStr := 'LEDGER REPORT WITH SUPER DETAILS ' + TitleStr;

  AddJobHeader(aJob, siTitle, TitleStr, true, jtCenter, True);

  AddJobHeader(aJob,SiSubTitle,'', true);

  //Ledger and superfund fields
  aJob.Params.ColManager.AddReportColumns(aJob);

  //Footers
  if not aJob.params.SummaryReport then
    AddJobFooter(aJob, siFootNote, '[D] = Part of Dissected Entry', true);

  AddCommonFooter(aJob);

  aJob.UserReportSettings.s7Orientation := aJob.Params.ColManager.Orientation;
  aJob.Generate(aDest, aJob.Params);
end;

//------------------------------------------------------------------------------
procedure DoListLedgerReport(aDest : TReportDest; aRptBatch : TReportBase = nil);
var
  Job : TListLedgerReport;
  Params : TLRParameters;
  Previewed : Boolean;
  ISOCodes : string;
  FromDate : TStDate;
  ToDate : TStDate;
  This_Year_Starts : TStDate;
  This_Year_Ends : TStDate;
  Last_Year_Starts : TStDate;
  Last_Year_Ends : TStDate;
begin
  Previewed := False;
  Params := TLRParameters.Create(ord(Report_List_Ledger), MyClient, aRptBatch, DPeriod);

  try
    Params.AccountFilter := TransferringJournalsSet;
    Params.GetBatchAccounts;
    repeat
      if not GetLRParameters(Params, Previewed) then
        exit;  // done..

      case Params.Runbtn of
        BTN_PRINT   : aDest := rdPrinter;
        BTN_PREVIEW : aDest := rdScreen;
        BTN_FILE    : aDest := rdFile;
        BTN_EMAIL   : aDest := rdEmail;
      else
        aDest := rdAsk;
      end;

      FromDate := Params.FromDate;
      ToDate := Params.ToDate;

      // Opening/Closing balances require a broader date range for Forex
      if Params.ShowBalances then
      begin
        CalculateAccountTotals.CalcYearStartEndDates(MyClient,
                                                     This_Year_Starts,
                                                     This_Year_Ends,
                                                     Last_Year_Starts,
                                                     Last_Year_Ends);

        FromDate := This_Year_Starts;
      end;

      //Check Forex
      if not MyClient.HasExchangeRates(ISOCodes,
                                       FromDate,
                                       ToDate,
                                       {ForReport=}True,
                                       {AllBankAccounts=}False) then
      begin
        HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' +
                       ISOCodes + '.', 0);
        Exit;
      end;

      Job := TListLedgerReport.Create(RptLedger);
      try
        Job.Params := Params;

        if Params.ShowSuperDetails then
          GenerateSuperFundListLedgerReport(aDest, Job)
        else if Job.Params.SummaryReport then
          GenerateSummaryListLedgerReport(aDest, Job)
        else
          GenerateDetailedListLedgerReport(aDest, Job);

      finally
        Job.Free;
      end;

      Previewed := True;
    until Params.RunExit(aDest);

  finally
    PaRams.Free;
  end;
end;

{ TListLedgerTMgr }
//------------------------------------------------------------------------------
procedure TListLedgerTMgr.ClearSuper;
begin
  SuperTotalImputed_Credit                := 0;
  SuperTotalTax_Free_Dist                 := 0;
  SuperTotalTax_Exempt_Dist               := 0;
  SuperTotalTax_Deferred_Dist             := 0;
  SuperTotalTFN_Credits                   := 0;
  SuperTotalForeign_Income                := 0;
  SuperTotalForeign_Tax_Credits           := 0;
  SuperTotalCapital_Gains_Indexed         := 0;
  SuperTotalCapital_Gains_Disc            := 0;
  SuperTotalCapital_Gains_Other           := 0;
  SuperTotalOther_Expenses                := 0;
  SuperTotalCGT_Date                      := 0;
  SuperTotalFranked                       := 0;
  SuperTotalUnFranked                     := 0;
  SuperTotalInterest                      := 0;
  SuperTotalCapital_Gains_Foreign_Disc    := 0;
  SuperTotalRent                          := 0;
  SuperTotalSpecial_Income                := 0;
  SuperTotalOther_Tax_Credit              := 0;
  SuperTotalNon_Resident_Tax              := 0;
  SuperTotalForeign_Capital_Gains_Credit  := 0;

  SuperTotalOther_Income                         := 0;
  SuperTotalOther_Trust_Deductions               := 0;
  SuperTotalCGT_Concession_Amount                := 0;
  SuperTotalCGT_ForeignCGT_Before_Disc           := 0;
  SuperTotalCGT_ForeignCGT_Indexation            := 0;
  SuperTotalCGT_ForeignCGT_Other_Method          := 0;
  SuperTotalCGT_TaxPaid_Indexation               := 0;
  SuperTotalCGT_TaxPaid_Other_Method             := 0;
  SuperTotalOther_Net_Foreign_Income             := 0;
  SuperTotalCash_Distribution                    := 0;
  SuperTotalAU_Franking_Credits_NZ_Co            := 0;
  SuperTotalNon_Res_Witholding_Tax               := 0;
  SuperTotalLIC_Deductions                       := 0;
  SuperTotalNon_Cash_CGT_Discounted_Before_Discount := 0;
  SuperTotalNon_Cash_CGT_Indexation              := 0;
  SuperTotalNon_Cash_CGT_Other_Method            := 0;
  SuperTotalNon_Cash_CGT_Capital_Losses          := 0;
  SuperTotalShare_Consideration                  := 0;
  SuperTotalShare_Brokerage                      := 0;
  SuperTotalShare_GST_Amount                     := 0;
end;

end.

