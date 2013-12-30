unit rptLedgerReport;

interface
uses
  ReportDefs,
  LedgerRepDlg,
  rptParams, NewReportObj, PrintMgrObj, OvcDate, moneydef, Classes, UBatchBase,
  travList;

type
  //allows the ledger report manager to keep track of additional totals
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
    procedure ClearSuper;
  end;

  //decends from the base BK report object
  TListLedgerReport = class(TBKReport)
  protected
    procedure PutWrapped( Narration: string; GSTClass: Byte; Gross, GST, Net, Qty: Comp; Avg: Currency; Notes: string);
  public
    Params : TLRParameters;
    DoneSubTotal: Boolean;               // has displayed subtotals line
    SplitCode: string;                   // Used to re-print the code title if a page splits it up
    function ShowCodeOnReport( aCode : string) : boolean;
    procedure BKPrint;  override;
    procedure AfterNewPage(DetailPending : Boolean);  override;
  end;

  function CalcAverage(v,q : currency) : currency;

  procedure GenerateSummaryListLedgerReport(Dest : TReportDest; Job : TListLedgerReport);

  procedure DoListLedgerReport(Dest : TReportDest;
                  RptBatch : TReportBase = nil);

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

Var
  NET_AMOUNT_CAPTION : String;

function HasExchangeGainLossEntries(const Code: String; Params: TLRParameters): Boolean;
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

      if BankAccount.baFields.baExchange_Gain_Loss_Code = Code then
      begin
        if Length(BankAccount.baExchange_Gain_Loss_List.GetEntriesPostedBetween(Params.FromDate, Params.ToDate)) > 0  then
        begin
          Result := True;

          Exit;
        end;
      end;
    end;
  end;
end;

// Takes a value and quantity and returns a unit price
function CalcAverage(v,q : currency) : currency;
begin
   if q <> 0.0 then
     begin
        result := v/q;

        //the avg should have the same sign as the quantity.  For normal
        //cases the qty and net value will have the same sign, so consequently
        //the avg will have the same sign.
        result := SetSign_Curr( result, SignOf( q));
     end
   else
      result := 0;
end;

//decide if we need to print a title for the current code
procedure TListLedgerReport.AfterNewPage(DetailPending : Boolean);
begin
  if SplitCode <> '' then
    RenderTitleLine(SplitCode);
end;

// Is current bank account selected in the Advanced tab
// Returns True if selected
function IsBankAccountIncluded(ReportJob: TBkReport; Mgr: TListLedgerTMgr): Boolean;
var
  i: Integer;
  BA: TBank_Account;
begin with TListLedgerReport(ReportJob).Params do begin
   Result := False;
   for i := 0 to Pred(AccountList.Count) do
   begin
     BA := TBank_Account(AccountList[i]);
     if (BA.baFields.baBank_Account_Number = Mgr.Bank_Account.baFields.baBank_Account_Number) then
     begin
       Result := True;
       Break;
     end;
   end;
   if (IncludeNonTransferring and (Mgr.Bank_Account.baFields.baAccount_Type in BKConst.NonTrfJournalsLedgerSet)) then
    Result := True;
end;end;

// Is the given Code used as a bank contra in any bank account that is included
// Returns index into BA list, or -1 if not a contra
function IsABankContra(Code: string; Start: Integer; ReportJob: TBKReport): Integer;
var
  BA: TBank_Account;
  T: pTransaction_Rec;
  i, j, k: Integer;
begin with TListLedgerReport(ReportJob).params do begin
  Result := -1;
  if Code = '' then
    Exit;
  for i := Start to Pred(Client.clBank_Account_List.ItemCount) do
  begin
    BA := Client.clBank_Account_List.Bank_Account_At(i);
    if (BA.baFields.baContra_Account_Code = Code) and (not (BA.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
    begin
      // Is this account included
      for j := 0 to Pred(AccountList.Count) do
      begin
        if AccountList[j] = BA then
        begin
          // Does this account have any transactions coded within the report dates
          for k := 0 to Pred(BA.baTransaction_List.ItemCount) do
          begin
            T := BA.baTransaction_List.Transaction_At(k);
            if (T.txDate_Effective >= FromDate) and
               (T.txDate_Effective <= Todate) then
            begin
              Result := i;
              exit;
            end;
          end;
        end;
      end;
    end;
  end;
end;end;

// Does a given transaction use a given GST class
function DoesTxUseGSTClass(Client : TClientObj; ClassId: string; T: pTransaction_Rec): Boolean;
var
  D: pDissection_Rec;
begin
  Result := False;
  // check mainline
  if (T.txGST_Class in [ 1..MAX_GST_CLASS ]) and
     (Client.clFields.clGST_Class_Codes[T.txGST_Class] = ClassID) and
     (T.txGST_Amount <> 0) then
  begin
    Result := True;
    Exit;
  end;
  // check dissection lines
  D := T.txFirst_Dissection;
  while D <> nil do
  begin
    if (D.dsGST_Class in [ 1..MAX_GST_CLASS ]) and
       (Client.clFields.clGST_Class_Codes[D.dsGST_Class] = ClassID) and
       (D.dsGST_Amount <> 0) then
    begin
      Result := True;
      Exit;
    end;
    D := D.dsNext;
  end;
end;

// Is the given Code used as a GST control account
// Returns index into GST rates list, or -1 if not a control account
function IsAGSTContra(Code: string; Start: Integer; ReportJob: TBKReport): Integer;
var
  i, j, k: Integer;
  BA: TBank_Account;
  T: pTransaction_Rec;
begin with TListLedgerReport(ReportJob).Params do begin
  Result := -1;
  if Code = '' then
    Exit;
  for i := Start to High(Client.clFields.clGST_Account_Codes) do
    if Client.clFields.clGST_Account_Codes[i] = Code then
    begin
      // Is this GST class used in any included bank account
      for j := 0 to Pred(AccountList.Count) do
      begin
        BA := AccountList[j];
        // Are there any txns using this gst class within the report dates
        for k := 0 to Pred(BA.baTransaction_List.ItemCount) do
        begin
          T := BA.baTransaction_List.Transaction_At(k);
          if (T.txDate_Effective >= Fromdate) and
             (T.txDate_Effective <= Todate) and
             DoesTxUseGSTClass(Client,Client.clFields.clGST_Class_Codes[i], T) then
          begin
            Result := i;
            Exit;
          end;
        end;
      end;
      // ...or in non-trf journals if they are to be included
      if IncludeNonTransferring then
        for j := 0 to Pred(Client.clBank_Account_List.ItemCount) do
        begin
          BA := Client.clBank_Account_List.Bank_Account_At(j);
          if BA.baFields.baAccount_Type in BKConst.NonTrfJournalsLedgerSet then
            // Are there any txns using this gst class within the report dates
            for k := 0 to Pred(BA.baTransaction_List.ItemCount) do
            begin
              T := BA.baTransaction_List.Transaction_At(k);
              if (T.txDate_Effective >= Fromdate) and
                 (T.txDate_Effective <= Todate) and
                 DoesTxUseGSTClass(Client,Client.clFields.clGST_Class_Codes[i], T) then
              begin
                Result := i;
                Exit;
              end;
            end;
        end;
    end;
end;end;

// Is the given Code required to be used as a contra (bank or gst) in the current report
// Returns true if there are contras for the given code
function IsThisAContraCode(Code: string; ReportJob: TBKReport): Boolean;
begin  with TListLedgerReport(ReportJob).Params do begin
  Result :=
    ((BankContra > Byte(bcNone)) and (IsABankContra(Code, 0, ReportJob) > -1))
    or
    ((GSTContra > Byte(gcNone)) and (IsAGSTContra(Code, Low(Client.clFields.clGST_Account_Codes), ReportJob) > -1))
end;end;

// To get an opening balance for an invalid code there are no actual op bals -
// we just calculate movement from the financial year start
function GetOpeningBalanceForInvalidCode(Client : TClientObj; Code: string; D1: Integer): Money;
//Must be net amount !!!
var
  i, j, Dfrom, Dto: Integer;
  Curr_Dissect : pDissection_Rec;
  Df, Mf, Yf: Integer;
  Dp, Mp, Yp: Integer;
begin
  Result := 0;

  // Add all movement between financial year start and day prior to report start
  Dfrom := Client.clFields.clTemp_FRS_From_Date;
  Dto := Client.clFields.clTemp_FRS_To_Date;

  //handle special case where report is being run from fin year start date
  StDatetoDMY(Client.clFields.clFinancial_Year_Starts, Df, Mf, Yf);
  StDatetoDMY(D1, Dp, Mp, Yp);
  if (Df = Dp) and (Mf = Mp) then
  begin
    result := 0;
    exit;
  end;

  with Client.clBank_Account_List do
    for i := 0 to Pred(ItemCount) do // Loop each bank account
       for j := 0 to Pred(Bank_Account_At(i).baTransaction_List.ItemCount) do // loop each transaction
          with Bank_Account_At(i).baTransaction_List.Transaction_At(j)^ do
            if (txDate_Effective >= Dfrom) and (txDate_Effective <= Dto) then
            begin
              if (txAccount = Code) then
              begin
                Result := Result + ( txTemp_Base_Amount - txGST_Amount)
              end
              else
              if (txFirst_Dissection <> nil) then
              begin
                Curr_Dissect := txFirst_Dissection;
                while Curr_Dissect <> nil do
                begin
                  if Curr_Dissect.dsAccount = Code then
                    Result := Result + ( Curr_Dissect.dsTemp_Base_Amount - Curr_Dissect.dsGST_Amount);
                  Curr_Dissect := Curr_Dissect.dsNext;
                end;
              end;
            end;
end;

function GetOpeningBalanceAmount(Client : tClientObj; Code: string): Money;
var
  AccountInfo: TAccountInformation;
  Bal: Money;
  Df, Mf, Yf: Integer;
  Dp, Mp, Yp: Integer;
begin
  AccountInfo := TAccountInformation.Create( Client);
  try
    AccountInfo.UseBudgetIfNoActualData     := False;
    AccountInfo.LastPeriodOfActualDataToUse := Client.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode := Code;
    AccountInfo.UseBaseAmounts := True;
    StDatetoDMY(Client.clFields.clFinancial_Year_Starts, Df, Mf, Yf);
    StDatetoDMY(Client.clFields.clTemp_FRS_To_Date, Dp, Mp, Yp);
    if (Df = Dp) and (Mf = Mp) then // If start date = financial year start then just get opening bal
      Bal := AccountInfo.OpeningBalanceActualOrBudget(1)
    else
      Bal := AccountInfo.ClosingBalanceActualOrBudget(1); // else opening bal at last financial year start + movement up to previous day
  finally
    AccountInfo.Free;
  end;
  Result := Bal;
end;

// Print mainline txn within a contra code
procedure LGR_Contra_PrintEntry(Sender:TObject);
Var
   Code  : Bk5CodeStr;
   RS    : string[20];
   Mgr : TListLedgerTMgr;
   Avg : Currency;
   Net : Money;
   Qty : Money;
   GSTControlAccount, Notes: string;
   //IsSummary: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);

   With Mgr, Mgr.ReportJob, TListLedgerReport(Mgr.ReportJob).Params, Mgr.Transaction^ do
   Begin
      //is bank account included in this report?
      if not IsBankAccountIncluded(ReportJob, Mgr) then
       Exit;

      Code := txAccount;
      //IsSummary := TListLedgerReport(ReportJob).SummaryOnly;

      //get GST control account if we need to display gst contras
      if (Mgr.GSTContraType > Byte(gcNone)) and (txGst_Class in [ 1..MAX_GST_CLASS ]) then
        GSTControlAccount := Client.clFields.clGST_Account_Codes[txGst_Class]
      else
        GSTControlAccount := '';

      //does this transaction need to be handled? only if:
      //it is coded to the handled acount
      //the bank account it belongs to has this account as the contra
      //its GST class has this account as the control account
      //Skip dissections, they are handled in a seperate method
      if ((Mgr.ContraCodePrinted <> txAccount) and (Mgr.ContraCodePrinted <> Mgr.Bank_Account.baFields.baContra_Account_Code) and
         (Mgr.ContraCodePrinted <> GSTControlAccount)) or (txAccount = DISSECT_DESC) then
        exit;

      // #2608 - do not show transactions with $0 GST in the contra section unless coded to this account
      if (GSTControlAccount = Mgr.ContraCodePrinted) and (txGST_Amount = 0) and (txAccount <> GSTControlAccount) then
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
         (txTemp_Base_Amount <> 0) and (not SummaryReport) then
      begin
        Mgr.AccountTotalGross := Mgr.AccountTotalGross + (-txTemp_Base_Amount);
        Mgr.AccountHasActivity := True;
      end;

      //if we only want gst contra totals then add this txn
      if (Mgr.GSTContraType = Byte(gcTotal)) and
         (Mgr.ContraCodePrinted = GSTControlAccount) and
         (txGST_Amount <> 0) and (not SummaryReport) then
      begin
        Mgr.AccountTotalTax := Mgr.AccountTotalTax + (-txGST_Amount);
        Mgr.AccountTotalNet := Mgr.AccountTotalNet + txGST_Amount;
        Mgr.AccountHasActivity := True;
      end;

      //print contra entries if requested
      //note: txn may be printed twice (actual entry and contra) if its coded to this account

      //normal txn
      if (Mgr.ContraCodePrinted = txAccount) then
      begin
        if SummaryReport then
        begin
          Mgr.AccountTotalGross    := Mgr.AccountTotalGross + txTemp_Base_Amount;
          Mgr.AccountTotalTax      := Mgr.AccountTotalTax   + txGST_Amount;
          Mgr.AccountTotalNet      := Mgr.AccountTotalNet   + ( txTemp_Base_Amount - txGST_Amount);
          Mgr.AccountTotalQuantity := Mgr.AccountTotalQuantity + txQuantity;
          Mgr.AccountHasActivity := (txTemp_Base_Amount <> 0) or (txGST_Amount <> 0);
        end
        else
        begin
          PutString( bkDate2Str ( txDate_Effective ));

          RS := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
          PutString( RS );

          If Quantities then
          begin
            Net := txTemp_Base_Amount - txGST_Amount;
            Qty := txQuantity;
            Avg := calcAverage(Net/100,Qty/10000);
          end
          else
          begin
            Qty := 0;
            Avg := 0;
          end;
          if ShowNotes then
            Notes := GetFullNotes(Mgr.Transaction)
          else
            Notes := '';

          TListLedgerReport(ReportJob).PutWrapped(GetNarration(Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type), txGST_Class,
            txTemp_Base_Amount, txGST_Amount, txTemp_Base_Amount - txGST_Amount, Qty, Avg, Notes);

          RenderDetailLine;
          Mgr.AccountHasActivity := True;
        end;
      end;

      //bank contra
      if (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
         (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
      begin
        if SummaryReport then
        begin
          AccountTotalGross    := AccountTotalGross + (-txTemp_Base_Amount);
          AccountTotalNet    := AccountTotalNet + (-txTemp_Base_Amount);
          Mgr.AccountHasActivity := txTemp_Base_Amount <> 0;
        end
        else if (Mgr.BankContraType = Byte(bcAll)) then
        begin
          PutString( bkDate2Str ( txDate_Effective ));

          RS := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type );
          PutString( RS );

          if ShowNotes then
            Notes := GetFullNotes(Mgr.Transaction)
          else
            Notes := '';

          TListLedgerReport(ReportJob).PutWrapped(GetNarration(Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type), txGST_Class,
            -txTemp_Base_Amount, 0, -txTemp_Base_Amount, 0, 0, Notes);

          RenderDetailLine;
          Mgr.AccountHasActivity := True;
        end;
      end;

      //GST contra
      if (Mgr.ContraCodePrinted = GSTControlAccount) then
      begin
        if SummaryReport then
        begin
          AccountTotalTax      := AccountTotalTax   + (-txGST_Amount);
          AccountTotalNet      := AccountTotalNet   + txGST_Amount;
          Mgr.AccountHasActivity := txGST_Amount <> 0;
        end
        else if (Mgr.GSTContraType = Byte(gcAll)) then
        begin
          PutString( bkDate2Str ( txDate_Effective ));

          RS := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
          PutString( RS );

          if ShowNotes then
            Notes := GetFullNotes(Mgr.Transaction)
          else
            Notes := '';

          TListLedgerReport(ReportJob).PutWrapped(GetNarration(Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type), txGST_Class,
            0, -txGST_Amount, txGST_Amount, 0, 0, Notes);

          RenderDetailLine;
          Mgr.AccountHasActivity := True;
        end;
      end;
   end;
end;

// Print dissected txn within a contra code
procedure LGR_Contra_PrintDissect(Sender:Tobject);
Var
   Code  : Bk5CodeStr;
   RS    : string[20];
   Mgr : TListLedgerTMgr;
   Avg : Currency;
   Net : Money;
   Qty : Money;
   GSTControlAccount, Notes, Narration: string;
   //IsSummary: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);

   With Mgr, Mgr.ReportJob,TListLedgerReport(Mgr.ReportJob).Params, Mgr.Transaction^, Mgr.Dissection^ do
   Begin
      //is bank account included in this report?
      if not IsBankAccountIncluded(ReportJob, Mgr) then
       Exit;

      Code := dsAccount;
      //IsSummary := TListLedgerReport(ReportJob).SummaryOnly;

      //get GST control account if we need to display gst contras
      if (Mgr.GSTContraType > Byte(gcNone)) and (dsGst_Class in [ 1..MAX_GST_CLASS ]) then
        GSTControlAccount := Client.clFields.clGST_Account_Codes[dsGst_Class]
      else
        GSTControlAccount := '';

      //does this dissection line need to be handled? only if:
      //it is coded to the handled acount
      //the bank account it belongs to has this account as the contra
      //its GST class has this account as the control account
      if (Mgr.ContraCodePrinted <> dsAccount) and (Mgr.ContraCodePrinted <> Mgr.Bank_Account.baFields.baContra_Account_Code) and
         (Mgr.ContraCodePrinted <> GSTControlAccount) then
        exit;

      // #2608 - do not show transactions with $0 GST in the contra section unless coded to this account
      if (GSTControlAccount = Mgr.ContraCodePrinted) and (dsGST_Amount = 0) and (dsAccount <> GSTControlAccount) then
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
         (dsTemp_Base_Amount <> 0) and (not SummaryReport) then
      begin
        Mgr.AccountTotalGross := Mgr.AccountTotalGross + (-dsTemp_Base_Amount);
        Mgr.AccountHasActivity := True;
      end;

      //if we only want gst contra totals then add this txn
      if (Mgr.GSTContraType = Byte(gcTotal)) and
         (Mgr.ContraCodePrinted = GSTControlAccount) and
         (dsGST_Amount <> 0) and (not SummaryReport) then
      begin
        Mgr.AccountTotalTax := Mgr.AccountTotalTax + (-dsGST_Amount);
        Mgr.AccountTotalNet := Mgr.AccountTotalNet + dsGST_Amount;
        Mgr.AccountHasActivity := True;
      end;

      //print contra entries if requested
      //note: txn may be printed twice (actual entry and contra) if its coded to this account

      //normal txn
      if (Mgr.ContraCodePrinted = dsAccount) then
      begin
        if SummaryReport then
        begin
          Mgr.AccountTotalGross    := Mgr.AccountTotalGross + dsTemp_Base_Amount;
          Mgr.AccountTotalTax      := Mgr.AccountTotalTax   + dsGST_Amount;
          Mgr.AccountTotalNet      := Mgr.AccountTotalNet   + ( dsTemp_Base_Amount - dsGST_Amount);
          Mgr.AccountTotalQuantity := Mgr.AccountTotalQuantity + dsQuantity;
          Mgr.AccountHasActivity := (dsTemp_Base_Amount <> 0) or (dsGST_Amount <> 0);
        end
        else
        begin
          if Mgr.Bank_Account.IsAJournalAccount then
             PutString( bkDate2Str ( txDate_Effective ))
          else
             PutString( bkDate2Str ( txDate_Effective ) + ' [D]');

          if length(dsReference) > 0 then
             RS := dsReference
          else RS := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
          PutString( RS );

          If Quantities then
          begin
            //qty is shown as +ve as long as signs match
            Net := dsTemp_Base_Amount - dsGST_Amount;
            Qty := dsQuantity;
            Avg := calcAverage(Net/100,Qty/10000);
          end
          else
          begin
            Qty := 0;
            Avg := 0;
          end;
          if ShowNotes then
          begin
             Notes := GetFullNotes(Mgr.Dissection)
          end
          else
            Notes := '';

          Narration :=  GetNarration(Mgr.Dissection, Mgr.Bank_Account.baFields.baAccount_Type);


          TListLedgerReport(ReportJob).PutWrapped(Narration, dsGST_Class,
            dsTemp_Base_Amount, dsGST_Amount, dsTemp_Base_Amount - dsGST_Amount, Qty, Avg, Notes);

          RenderDetailLine;
        end;
        Mgr.AccountHasActivity := True;
      end;

      //bank contra
      if (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
         (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
      begin
        if SummaryReport then
        begin
          AccountTotalGross    := AccountTotalGross + (-dsTemp_Base_Amount);
          AccountTotalNet      := AccountTotalNet + (-dsTemp_Base_Amount);
          Mgr.AccountHasActivity := dsTemp_Base_Amount <> 0;
        end
        else if (Mgr.BankContraType = Byte(bcAll)) then
        begin
          if Mgr.Bank_Account.IsAJournalAccount then
             PutString( bkDate2Str ( txDate_Effective ))
          else
             PutString( bkDate2Str ( txDate_Effective ) + ' [D]');

          RS := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
          PutString( RS );

          if ShowNotes then
          begin
            Notes := GetFullNotes(Mgr.Dissection);
          end
          else
            Notes := '';

          Narration :=  GetNarration(Mgr.Dissection, Mgr.Bank_Account.baFields.baAccount_Type);

          TListLedgerReport(ReportJob).PutWrapped(Narration, dsGST_Class,
            -dsTemp_Base_Amount, 0, -dsTemp_Base_Amount, 0, 0, Notes);

          RenderDetailLine;
          Mgr.AccountHasActivity := True;
        end;
      end;

      //GST contra
      if (Mgr.ContraCodePrinted = GSTControlAccount) then // gst contra txn
      begin
        if SummaryReport then
        begin
          AccountTotalTax      := AccountTotalTax   + (-dsGST_Amount);
          AccountTotalNet      := AccountTotalNet   + dsGST_Amount;
          Mgr.AccountHasActivity := dsGST_Amount <> 0;
        end
        else if (Mgr.GSTContraType = Byte(gcAll)) then
        begin
          PutString( bkDate2Str ( txDate_Effective ));

          RS := GetFormattedReference(Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
          PutString( RS );

          if ShowNotes then
          begin
            Notes := GetFullNotes(Mgr.Dissection);
          end
          else
            Notes := '';

          Narration :=  GetNarration(Mgr.Dissection, Mgr.Bank_Account.baFields.baAccount_Type);

          TListLedgerReport(ReportJob).PutWrapped(Narration, dsGST_Class,
            0, -dsGST_Amount, dsGST_Amount, 0, 0, Notes);

          RenderDetailLine;
          Mgr.AccountHasActivity := True;
        end;
      end;
   end;
end;

procedure LGR_Contra_PrintExchangeGainLoss(Sender:TObject);
Var
   Code  : Bk5CodeStr;
   RS    : string[20];
   Mgr : TListLedgerTMgr;
   Avg : Currency;
   Net : Money;
   Qty : Money;
   GSTControlAccount, Notes: string;
   Account: pAccount_Rec;
   //IsSummary: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);

   With Mgr, Mgr.ReportJob, TListLedgerReport(Mgr.ReportJob).Params do
   Begin
      //is bank account included in this report?
      if not IsBankAccountIncluded(ReportJob, Mgr) then Exit;

      Code := ExchangeGainLossEntry.glAccount;

      //print contra entries if requested
      //note: txn may be printed twice (actual entry and contra) if its coded to this account
      if (Mgr.BankContraType = Byte(bcTotal)) and
         (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and
         (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) and
         (ExchangeGainLossEntry.glAmount <> 0) and (not SummaryReport) then
      begin
        Mgr.AccountTotalGross := Mgr.AccountTotalGross + (-ExchangeGainLossEntry.glAmount);
        Mgr.AccountHasActivity := True;
      end;

      //bank contra
      if (Mgr.ContraCodePrinted = Mgr.Bank_Account.baFields.baContra_Account_Code) and (not (Mgr.Bank_Account.baFields.baAccount_Type in LedgerNoContrasJournalSet)) then
      begin
        Account := Chart.FindCode(Code);

        if Assigned(Account) then
        begin
          if SummaryReport then
          begin
            AccountTotalGross    := AccountTotalGross + (-ExchangeGainLossEntry.glAmount);
            AccountTotalNet    := AccountTotalNet + (-ExchangeGainLossEntry.glAmount);
            Mgr.AccountHasActivity := ExchangeGainLossEntry.glAmount <> 0;
          end
          else if (Mgr.BankContraType = Byte(bcAll)) then
          begin
            PutString( bkDate2Str ( ExchangeGainLossEntry.glDate ));

            PutString(Account.chAccount_Code);

            TListLedgerReport(ReportJob).PutWrapped(Account.chAccount_Description, 0, -ExchangeGainLossEntry.glAmount, 0, -ExchangeGainLossEntry.glAmount, 0, 0, Notes);

            RenderDetailLine;

            Mgr.AccountHasActivity := True;
          end;
        end;
      end;
   end;
end;

procedure PrintSummaryListLedgerLine( Mgr : TListLedgerTMgr; Code : BK5CodeStr; Job: TBKReport);
var
  P     : pAccount_Rec;
  Avg   : Currency;
  Report: TListLedgerReport;
  ReportParams: TLRParameters;
begin
  Report := TListLedgerReport(Job);
  ReportParams := Report.Params;

  if ReportParams.ShowSuperDetails then begin
    ReportParams.ColManager.Code := Code;
    ReportParams.ColManager.OutputColumns(Report, Mgr);
    Report.RenderDetailLine;
    Mgr.ClearSuper;
  end else begin
    if Code = '' then begin
      Report.PutString( 'Uncoded');
      if not ReportParams.ShowBalances then
        Report.SkipColumn;
    end else begin
      if ReportParams.ShowBalances then
        Report.PutString('MOVEMENT')
      else begin
        Report.PutString( Code);
        P := ReportParams.Chart.FindCode( Code);
        if Assigned( P ) then
           Report.PutString( p^.chAccount_Description)
        else
           Report.PutString( 'INVALID CODE');
      end;
    end;

    if ReportParams.GrossGST then begin
      Report.PutMoney( Mgr.AccountTotalGross);
      Report.PutMoney( Mgr.AccountTotalTax);
    end;
    Report.PutMoney( Mgr.AccountTotalNet);

    if Mgr.Quantities then begin
      //qty is shown as +ve as long as signs match
      Report.PutQuantity( Mgr.AccountTotalQuantity);
      Avg := calcAverage(Mgr.AccountTotalNet/100, Mgr.AccountTotalQuantity/10000);
      Report.PutCurrency( Avg);
    end;

    Report.RenderDetailLine;
  end;
end;

// Print the bank and gst contra entries
function DoContras(ReportJob: TBKReport; Code: string) : boolean;
//parameters:
//   ReportJob : pointer to the list ledger report object
//   Code : Contra code to process
//
//   Result : returns true if contra has activity
var
  ContraTravMgr : TListLedgerTMgr;
  IsBankContra, IsGSTContra: Boolean;
  BC, GC: Integer;
  BCType, GCType: Byte;
begin
  with TListLedgerReport(ReportJob).Params do begin
  result := false;

  //are bank contras needed in this report for this code
  BC := IsABankContra(Code, 0, ReportJob);
  BCType := BankContra;
  IsBankContra := (BCType > Byte(bcNone)) and
                  (BC > -1);
  //are gst contras needed in this report for this code
  GC := IsAGSTContra(Code, Low(Client.clFields.clGST_Account_Codes), ReportJob);
  GCType := GSTContra;
  IsGSTContra := (GCType > Byte(gcNone)) and
                 (GC > -1);
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
      ContraTravMgr.ReportJob            := ReportJob;
      ContraTravMgr.AccountTotalGross    := 0;
      ContraTravMgr.AccountTotalTax      := 0;
      ContraTravMgr.AccountTotalNet      := 0;
      ContraTravMgr.AccountTotalQuantity := 0;
      ContraTravMgr.AccountHasActivity   := false;
      ContraTravMgr.LastCodePrinted      := NullCode;
      ContraTravMgr.ContraCodePrinted    := Code;
      ContraTravMgr.Quantities           := ShowQuantity;
      ContraTravMgr.BankContraType       := BCType;
      ContraTravMgr.GSTContraType        := GCType;
      ContraTravMgr.OnEnterEntry      := LGR_Contra_PrintEntry;
      ContraTravMgr.OnEnterDissection := LGR_Contra_PrintDissect;
      ContraTravMgr.OnEnterExchangeGainLoss := LGR_Contra_PrintExchangeGainLoss;

      ContraTravMgr.TraverseAllEntries(fromdate ,Todate);

      if Summaryreport then
      begin
        //display contra code summary line
        PrintSummaryListLedgerLine(ContraTravMgr, Code, TListLedgerReport(ReportJob));
        TListLedgerReport(ReportJob).DoneSubTotal := True;
      end
      else
      begin
        //if we are displaying totals, just add a single line entry
        if ShowSuperDetails  then begin
          if IsBankContra and ContraTravMgr.AccountHasActivity and (BCType = Byte(bcTotal)) then begin
            ColManager.IsBankContra := IsBankContra;
            ColManager.OutputColumns(ReportJob, ContraTravMgr);
            ReportJob.RenderDetailLine;
          end;
          if IsGSTContra and ContraTravMgr.AccountHasActivity and (GCType = Byte(gcTotal)) then begin
            ColManager.IsGSTContra := IsGSTContra;
            ColManager.OutputColumns(ReportJob, ContraTravMgr);
            ReportJob.RenderDetailLine;            
          end;
          //Reset contra falgs
          ColManager.IsBankContra := False;
          ColManager.IsGSTContra := False;
        end else begin
          if IsBankContra and ContraTravMgr.AccountHasActivity and (BCType = Byte(bcTotal)) then
          begin
            ReportJob.PutString('');
            ReportJob.PutString('CONTRA');
            ReportJob.PutString('MOVEMENT');
            if GrossGST then
            begin
              ReportJob.PutString('');
              ReportJob.PutMoney(ContraTravMgr.AccountTotalGross);
              ReportJob.PutMoney(0);
            end;
            ReportJob.PutMoney(ContraTravMgr.AccountTotalGross);
            If ContraTravMgr.Quantities then
            begin
              ReportJob.PutQuantity(0);
              ReportJob.PutCurrency(0);
            end;
            if ShowNotes then
              ReportJob.PutString('');
            ReportJob.RenderDetailLine;
          end;

          if IsGSTContra and ContraTravMgr.AccountHasActivity and (GCType = Byte(gcTotal)) then
          begin
            ReportJob.PutString('');
            ReportJob.PutString('CONTRA');
            ReportJob.PutString('MOVEMENT');
            if GrossGST then
            begin
              ReportJob.PutString('');
              ReportJob.PutMoney(0);
              ReportJob.PutMoney(ContraTravMgr.AccountTotalTax);
            end;
            ReportJob.PutMoney(ContraTravMgr.AccountTotalNet);
            If ContraTravMgr.Quantities then
            begin
              ReportJob.PutQuantity(0);
              ReportJob.PutCurrency(0);
            end;
            if ShowNotes then
              ReportJob.PutString('');
            ReportJob.RenderDetailLine;
          end;
        end;

        if ContraTravMgr.AccountHasActivity then
        begin
          // Note DO NOT clear subtotals - we need them to calculate closing bal
          ReportJob.RenderDetailSubTotal('', False, True);
          TListLedgerReport(ReportJob).DoneSubTotal := True;
          Result := true;
        end;
      end;
    finally
      ContraTravMgr.Free;
    end;
  end;
end;end;

procedure ReportLedgerOpeningBalance(Code: string; ReportJob: TBKReport; NewLine: Boolean; IsValidCode: Boolean = True);
var
  aCol: TReportColumn;
  i: Integer;
begin with TListLedgerReport(ReportJob).Params do begin
  for i := 0 to Pred(ReportJob.Columns.ItemCount) do
  begin
    aCol := ReportJob.Columns.Report_Column_At(i);
    if aCol.Caption = DATE_CAPTION then
      ReportJob.PutString(bkDate2Str(Fromdate))
    else if aCol.Caption = NET_AMOUNT_CAPTION then // Add txn amounts to opening bal
    begin
      if IsValidCode then
        ReportJob.PutMoney(GetOpeningBalanceAmount(Client, Code), False)
      else
        ReportJob.PutMoney(GetOpeningBalanceForInvalidCode(Client, Code, Fromdate), False);
    end
    else if (aCol.Caption = NARRATION_CAPTION) or (aCol.Caption = DESCRIPTION_CAPTION) then
      ReportJob.PutString('Opening Balance')
    else
      ReportJob.SkipColumn;
  end;
  ReportJob.RenderDetailLine;
  ReportJob.ClearSubTotals;
  if NewLine then
    ReportJob.RenderTextLine(' ');
end;end;

procedure ReportLedgerClosingBalance(Code: string; ReportJob: TBKReport; NewLine: Boolean; IsValidCode: Boolean = True);
var
  aCol: TReportColumn;
  i: Integer;
begin with TListLedgerReport(ReportJob).Params do begin
  for i := 0 to Pred(ReportJob.Columns.ItemCount) do
    if (ReportJob.Columns.Report_Column_At(i).Caption = NET_AMOUNT_CAPTION)
    and (Summaryreport) then
    begin
      ReportJob.RenderColumnLine(i);
      Break;
    end;
  if NewLine then
    ReportJob.RenderTextLine(' ');
  for i := 0 to Pred(ReportJob.Columns.ItemCount) do
  begin
    aCol := ReportJob.Columns.Report_Column_At(i);
    if aCol.Caption = DATE_CAPTION then
      ReportJob.PutString(bkDate2Str(Todate))
    else if aCol.Caption = NET_AMOUNT_CAPTION then // Add txn amounts to opening bal
    begin
      if IsValidCode then
        ReportJob.PutMoney(((GetOpeningBalanceAmount(Client, Code)/100) + aCol.SubTotal)*100, False)
      else
        ReportJob.PutMoney(((GetOpeningBalanceForInvalidCode(Client, Code, Fromdate)/100) + aCol.SubTotal)*100, False);
    end
    else if (aCol.Caption = NARRATION_CAPTION) or (aCol.Caption = DESCRIPTION_CAPTION) then
    begin
      if SpanYear then
        ReportJob.PutString('Closing Balance *')
      else
        ReportJob.PutString('Closing Balance');
    end
    else
      ReportJob.SkipColumn;
  end;
  ReportJob.RenderDetailLine;
end;end;

function OutputClosingBalances(Code: Bk5CodeStr; TravMgr: TListLedgerTMgr;
  Report:TListLedgerReport; ReportParams: TLRParameters): boolean;
var
  P: pAccount_Rec;
  OKToPrint: boolean;
  S: string;
  IsValidCode, IsContras: boolean;
begin
  Result := True;
  IsValidCode := Assigned(ReportParams.Chart.FindCode(Code));

  //code has changed, handle closing balance
  if Code <> TravMgr.LastCodePrinted then begin
    // end last code
    if TravMgr.LastCodePrinted <> NullCode then begin
      if not TListLedgerReport(Report).DoneSubTotal then // avoid duplicate subtotals
        Report.RenderDetailSubTotal('', False, True);
      // Show closing balance if requested
      if ReportParams.ShowBalances and (TravMgr.LastCodePrinted <> '') then
        ReportLedgerClosingBalance(TravMgr.LastCodePrinted, Report, TravMgr.AccountHasActivity, TravMgr.LastCodePrinted = TravMgr.LastValidCode);
      // Need subtotals to calculate closing bal so do not clear during the subtotal printing
      // only safe to clear once closing balances have been printed
      TListLedgerReport(Report).ClearSubTotals;
      TListLedgerReport(Report).DoneSubTotal := False;
    end;
    TListLedgerReport(Report).SplitCode := '';

    //handle in between codes
    // Show inactive codes and contras if requested (that are between last code and this code)
    if (TravMgr.LastCodePrinted = NullCode) or (TravMgr.LastValidCode = NullCode) then
      P := ReportParams.Chart.FindNextCode('', False) // finds first code
    else if TravMgr.LastCodePrinted <> TravMgr.LastValidCode then
      P := ReportParams.Chart.FindNextCode(TravMgr.LastValidCode, False)
    else
      P := ReportParams.Chart.FindNextCode(TravMgr.LastCodePrinted, False);
    // Some conditions to handle invalid codes
    OKToPrint := ((not IsValidCode) and Assigned(P) and (P^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                 ((not IsValidCode) and (TravMgr.LastCodePrinted = TravMgr.LastValidCode)
                                    and (TravMgr.LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this
    if Assigned(P) and (IsValidCode or OKToPrint) then
      while (Code <> '') and (P^.chAccount_Code <> Code) and (P^.chAccount_Code < Code) do begin
        //is code in range?
        if TListLedgerReport(Report).ShowCodeOnReport( P^.chAccount_Code) then begin
          with P^ do S := chAccount_Code + '  ' + chAccount_Description;
          if HasAlternativeChartCode(ReportParams.Client.clFields.clCountry,ReportParams.Client.clFields.clAccounting_System_Used )
          and (P.chAlternative_code > '') then
             S := S + ' ' + P.chAlternative_code;
          IsContras := IsThisAContraCode(P^.chAccount_Code, Report);
          // show if contra or showing empty posting codes or showing non-posting codes with a balance
          if (IsContras or (ReportParams.PrintEmptyCodes and
             (P^.chPosting_Allowed or
              (ReportParams.ShowBalances and
               (GetOpeningBalanceAmount(ReportParams.Client,P^.chAccount_Code) <> 0))))) then
          begin
            Report.RenderTitleLine(S);
            TListLedgerReport(Report).SplitCode := S + ' (continued)';
            if ReportParams.ShowBalances and (P^.chAccount_Code <> '') then
              ReportLedgerOpeningBalance(P^.chAccount_Code, Report, True);
            if IsContras then
              DoContras(Report, P^.chAccount_Code);
            if ReportParams.ShowBalances and (P^.chAccount_Code <> '') then
              ReportLedgerClosingBalance(P^.chAccount_Code, Report, IsContras);
            TListLedgerReport(Report).DoneSubTotal := False;
            TListLedgerReport(Report).SplitCode := '';
            TListLedgerReport(Report).ClearSubTotals;
            TravMgr.LastValidCode := P^.chAccount_Code;
          end;
        end;
        P := ReportParams.Chart.FindNextCode(P^.chAccount_Code, False);
        if not Assigned(P) then Break;
      end;

    //Now we start to print the new code
    if Code = '' then
      S := 'Uncoded'
    else begin
      P := ReportParams.Chart.FindCode( Code );
      if Assigned( P ) then begin
         with P^ do S := Code + '  ' + chAccount_Description;
         if HasAlternativeChartCode(ReportParams.Client.clFields.clCountry,ReportParams.Client.clFields.clAccounting_System_Used )
         and (P.chAlternative_code > '') then
            S := S + ' ' + P.chAlternative_code;
      end else
        S := Code + '  INVALID CODE!';
    end;

    Report.RenderTitleLine(S);
    TListLedgerReport(Report).SplitCode := S + ' (continued)';
    TravMgr.LastCodePrinted := Code;
    if IsValidCode then
      TravMgr.LastValidCode := Code;

    // Show opening balance if requested
    if ReportParams.ShowBalances and (Code <> '') then
      ReportLedgerOpeningBalance(Code, Report, True, Assigned(P));

    // Show contras for this code - this will display ALL transactions
    // for this code (so that they display in date order)
    // so after this we need to move onto next code (as per skipping txns earlier in this proc)
    if IsThisAContraCode(Code, Report) then begin
      TravMgr.AccountHasActivity := DoContras(Report, Code);
      TravMgr.ContraCodePrinted := Code;
      Result := False;
    end;
  end;
end;

procedure Custom_LGR_PrintEntry(Sender: TObject);
var
  Code  : Bk5CodeStr;
  TravMgr : TListLedgerTMgr;
  Report: TListLedgerReport;
  ReportParams: TLRParameters;
  TXN: TTransaction_Rec;
begin
  TravMgr := TListLedgerTMgr(Sender);
  Report := TListLedgerReport(TravMgr.ReportJob);
  ReportParams := Report.Params;
  TXN := TravMgr.Transaction^;
  Code := TXN.txAccount;

  //Bank account included?
  if not IsBankAccountIncluded(Report, TravMgr) then Exit;
  //Code in range?
  if not TListLedgerReport(Report).ShowCodeOnReport(Code) then Exit;
  // has txn already been printed during contras?
  // if we have printed contras then we have gone thru all codes again from
  // start so we must skip them in here
  if (Code = TravMgr.ContraCodePrinted) and
     (TravMgr.ContraCodePrinted <> NullCode) then Exit;

  TravMgr.ContraCodePrinted := NullCode;

  if not OutputClosingBalances(Code, TravMgr, Report, ReportParams) then Exit;

  ReportParams.ColManager.IsDissection := False;  
  ReportParams.ColManager.OutputColumns(Report, TravMgr);
  Report.RenderDetailLine;

  TravMgr.AccountHasActivity := True;
end;

procedure Custom_LGR_PrintDissect(Sender: TObject);
var
  TravMgr: TListLedgerTMgr;
  Code  : Bk5CodeStr;
  Report: TListLedgerReport;
  ReportParams: TLRParameters;
begin
  TravMgr := TListLedgerTMgr(Sender);
  Report := TListLedgerReport(TravMgr.ReportJob);
  ReportParams := Report.Params;
  Code := TravMgr.Dissection.dsAccount;

  //is bank account included in this report?
  if not IsBankAccountIncluded(Report, TravMgr) then Exit;
  //is code in range?
  if not TListLedgerReport(Report).ShowCodeOnReport( Code) then Exit;
  // has tx already been printed during contras?
  if (Code = TravMgr.ContraCodePrinted) and
     (TravMgr.ContraCodePrinted <> NullCode) then Exit;

  TravMgr.ContraCodePrinted := NullCode;

  if not OutputClosingBalances(Code, TravMgr, Report, ReportParams) then Exit;

  ReportParams.ColManager.IsDissection := True;
  ReportParams.ColManager.OutputColumns(Report, TravMgr);
  Report.RenderDetailLine;

  TravMgr.AccountHasActivity := True;
end;

procedure SummaryListLedger_PrintEntry( Sender : TObject);
//trav manager has transactions sorted by account code
Var
   Code  : Bk5CodeStr;
   Mgr   : TListLedgerTMgr;
   P     : pAccount_Rec;
   S     : string;
   IsContras, IsEmpty, IsValidCode, OKToPrint: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);
   with Mgr, ReportJob,TListLedgerReport(ReportJob).Params, Mgr.Transaction^ do begin
      if not IsBankAccountIncluded(ReportJob, Mgr) then
       Exit;

      Code := txAccount;

      //is code in range?
      if not TListLedgerReport(ReportJob).ShowCodeOnReport( Code) then
        exit;

      // has tx already been printed during contras?
      if (Code = ContraCodePrinted) and (ContraCodePrinted <> NullCode) then
        exit;
      ContraCodePrinted := NullCode;
      IsValidCode := Assigned(Chart.FindCode( Code ));

//code has changed

      if ( Code <> LastCodePrinted) then begin
         if ( LastCodePrinted <> NullCode) then begin
            //code has changed so print totals
            if (AccountHasActivity or PrintEmptyCodes) and
               (not TListLedgerReport(ReportJob).DoneSubTotal) then
               PrintSummaryListLedgerLine( Mgr, LastCodePrinted, TListLedgerReport(ReportJob));
           // Show closing balance if requested
           if ShowBalances and (LastCodePrinted <> '') then
           begin
             ReportLedgerClosingBalance(LastCodePrinted, ReportJob, False, LastCodePrinted = LastValidCode);
             TListLedgerReport(ReportJob).SplitCode := '';
             RenderTextLine('');
           end;
         end;

         //clear temp information
         AccountHasActivity := false;
         AccountTotalGross  := 0;
         AccountTotalTax    := 0;
         AccountTotalNet    := 0;
         AccountTotalQuantity:= 0;
         TListLedgerReport(ReportJob).DoneSubTotal := False;
         TListLedgerReport(ReportJob).SplitCode := '';
         TListLedgerReport(ReportJob).ClearSubTotals;

         //Clear Super
         ClearSuper;

//request to show all codes regardless of any activity
         //look for all codes in between last (valid) one printed and next to be printed
         if (LastCodePrinted = NullCode) or (LastValidCode = NullCode) then
           P := Chart.FindNextCode('', False)
         else if LastCodePrinted <> LastValidCode then
           P := Chart.FindNextCode(LastValidCode, False)
         else
           P := Chart.FindNextCode(LastCodePrinted, False);
         // Some conditions to handle invalid codes
         OKToPrint := ((not IsValidCode) and Assigned(P) and (P^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                      ((not IsValidCode) and (LastCodePrinted = LastValidCode) and (LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this
         if Assigned(P) and (IsValidCode or OKToPrint) then
           while (Code <> '') and (P^.chAccount_Code <> Code) and (P^.chAccount_Code < Code) do
           begin
             //is code in range?
             if TListLedgerReport(ReportJob).ShowCodeOnReport( P^.chAccount_Code) then
             begin
               IsContras := IsThisAContraCode(P^.chAccount_Code, ReportJob);
               IsEmpty := PrintEmptyCodes and
                   (P^.chPosting_Allowed or (ShowBalances and (GetOpeningBalanceAmount(Client,P^.chAccount_Code) <> 0)));
               if IsContras or IsEmpty then
               begin
                 if ShowBalances and (P^.chAccount_Code <> '') then
                 begin
                   RenderTitleLine(P^.chAccount_Code + ' ' + P^.chAccount_Description);
                   TListLedgerReport(ReportJob).SplitCode := P^.chAccount_Code + ' ' + P^.chAccount_Description + ' (continued)';
                   ReportLedgerOpeningBalance(P^.chAccount_Code, ReportJob, False);
                 end;
                 if IsContras then
                 begin
                   TListLedgerReport(ReportJob).SplitCode := P^.chAccount_Code + ' ' + P^.chAccount_Description + ' (continued)';
                   DoContras(ReportJob, P^.chAccount_Code)
                 end
                 else
                   PrintSummaryListLedgerLine( Mgr, P^.chAccount_Code, TListLedgerReport(ReportJob));
                 if ShowBalances and (P^.chAccount_Code <> '') then
                 begin
                   ReportLedgerClosingBalance(P^.chAccount_Code, ReportJob, False);
                   TListLedgerReport(ReportJob).SplitCode := '';
                   RenderTextLine('');
                 end
                 else
                   TListLedgerReport(ReportJob).SplitCode := '';
                 LastValidCode := P^.chAccount_Code;
               end;
             end;
             P := Chart.FindNextCode(P^.chAccount_Code, False);
             TListLedgerReport(ReportJob).ClearSubTotals;
             if not Assigned(P) then Break;
           end;

// starting a new code

         LastCodePrinted    := Code;
         if IsValidCode then
          LastValidCode := Code;
         TListLedgerReport(ReportJob).DoneSubTotal := False;
         TListLedgerReport(ReportJob).SplitCode := '';

         // Show opening balance if requested
         if ShowBalances and (Code <> '') then
         begin
           P := Chart.FindCode( Code );
           If Assigned( P ) then
              With P^ do S := Code + '  ' + chAccount_Description
           else
              S := Code + '  INVALID CODE!';
           RenderTitleLine(S);
           TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';
           ReportLedgerOpeningBalance(Code, ReportJob, False, Assigned(P));
         end;

         // Show contras for this code - this will display ALL transactions
         // for this code (so that they display in date order)
         // so after this we need to move onto next code
         if IsThisAContraCode(Code, ReportJob) then
         begin
           AccountHasActivity := DoContras(ReportJob, Code);
           ContraCodePrinted := Code;
           Exit;
         end;
      end;
      //store values
      AccountTotalGross    := AccountTotalGross + txTemp_Base_Amount;
      AccountTotalTax      := AccountTotalTax   + txGST_Amount;
      AccountTotalNet      := AccountTotalNet   + ( txTemp_Base_Amount - txGST_Amount);
      AccountTotalQuantity := AccountTotalQuantity + txQuantity;
      if ( txTemp_Base_Amount <> 0) or ( txGST_Amount <> 0) then
         AccountHasActivity := true;

      //Super
      if ShowSuperDetails then begin
        SuperTotalImputed_Credit                := SuperTotalImputed_Credit + txSF_Imputed_Credit;
        SuperTotalTax_Free_Dist                 := SuperTotalTax_Free_Dist + txSF_Tax_Free_Dist;
        SuperTotalTax_Exempt_Dist               := SuperTotalTax_Exempt_Dist + txSF_Tax_Exempt_Dist;
        SuperTotalTax_Deferred_Dist             := SuperTotalTax_Deferred_Dist + txSF_Tax_Deferred_Dist;
        SuperTotalTFN_Credits                   := SuperTotalTFN_Credits + txSF_TFN_Credits;
        SuperTotalForeign_Income                := SuperTotalForeign_Income + txSF_Foreign_Income;
        SuperTotalForeign_Tax_Credits           := SuperTotalForeign_Tax_Credits + txSF_Foreign_Tax_Credits;
        SuperTotalCapital_Gains_Indexed         := SuperTotalCapital_Gains_Indexed + txSF_Capital_Gains_Indexed;
        SuperTotalCapital_Gains_Disc            := SuperTotalCapital_Gains_Disc + txSF_Capital_Gains_Disc;
        SuperTotalCapital_Gains_Other           := SuperTotalCapital_Gains_Other + txSF_Capital_Gains_Other;
        SuperTotalOther_Expenses                := SuperTotalOther_Expenses + txSF_Other_Expenses;
        SuperTotalCGT_Date                      := SuperTotalCGT_Date + txSF_CGT_Date;
        SuperTotalFranked                       := SuperTotalFranked + txSF_Franked;
        SuperTotalUnFranked                     := SuperTotalUnFranked + txSF_UnFranked;
        SuperTotalInterest                      := SuperTotalInterest + txSF_Interest;
        SuperTotalCapital_Gains_Foreign_Disc    := SuperTotalCapital_Gains_Foreign_Disc + txSF_Capital_Gains_Foreign_Disc;
        SuperTotalRent                          := SuperTotalRent + txSF_Rent;
        SuperTotalSpecial_Income                := SuperTotalSpecial_Income + txSF_Special_Income;
        SuperTotalOther_Tax_Credit              := SuperTotalOther_Tax_Credit + txSF_Other_Tax_Credit;
        SuperTotalNon_Resident_Tax              := SuperTotalNon_Resident_Tax + txSF_Non_Resident_Tax;
        SuperTotalForeign_Capital_Gains_Credit  := SuperTotalForeign_Capital_Gains_Credit + txSF_Foreign_Capital_Gains_Credit;
      end;
   end;
end;

procedure SummaryListLedger_PrintDissect( Sender : TObject);
Var
   Code  : Bk5CodeStr;
   Mgr : TListLedgerTMgr;
   P     : pAccount_Rec;
   S: string;
   IsContras, IsEmpty, IsValidCode, OKToPrint: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);
   with Mgr, ReportJob,TListLedgerReport(ReportJob).Params, Mgr.Transaction^, Mgr.Dissection^ do begin
      if not IsBankAccountIncluded(ReportJob, Mgr) then
        Exit;

      Code := dsAccount;
      //is code in range?
      if not TListLedgerReport(ReportJob).ShowCodeOnReport( Code) then
         Exit;

      // has tx already been printed during contras?
      if (Code = ContraCodePrinted) and (ContraCodePrinted <> NullCode) then
         Exit;

      ContraCodePrinted := NullCode;
      IsValidCode := Assigned(Chart.FindCode( Code ));

//code has changed

      if ( Code <> LastCodePrinted) then begin
         if ( LastCodePrinted <> NullCode) then begin
            //code has changed so print totals;
            if (AccountHasActivity or PrintEmptyCodes)
            and (not TListLedgerReport(ReportJob).DoneSubTotal) then
               PrintSummaryListLedgerLine( Mgr, LastCodePrinted, TListLedgerReport(ReportJob));
           // Show closing balance if requested
           if ShowBalances
           and (LastCodePrinted <> '') then
           begin
              ReportLedgerClosingBalance(LastCodePrinted, ReportJob, False, LastCodePrinted = LastValidCode);
              TListLedgerReport(ReportJob).SplitCode := '';
              RenderTextLine('');
           end;
         end;

         //clear temp information
         AccountHasActivity := false;
         AccountTotalGross  := 0;
         AccountTotalTax    := 0;
         AccountTotalNet    := 0;
         AccountTotalQuantity := 0;
         TListLedgerReport(ReportJob).DoneSubTotal := False;
         TListLedgerReport(ReportJob).SplitCode := '';
         TListLedgerReport(ReportJob).ClearSubTotals;

         //Clear Super
         ClearSuper;

//request to show all codes regardless of any activity
         //look for all codes in between last one printed and next to be printed
         if (LastCodePrinted = NullCode) or (LastValidCode = NullCode) then
           P := Chart.FindNextCode('', False)
         else if LastCodePrinted <> LastValidCode then
           P := Chart.FindNextCode(LastValidCode, False)
         else
           P := Chart.FindNextCode(LastCodePrinted, False);
         // Some conditions to handle invalid codes
         OKToPrint := ((not IsValidCode) and Assigned(P) and (P^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                      ((not IsValidCode) and (LastCodePrinted = LastValidCode) and (LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this
         if Assigned(P) and (IsValidCode or OKToPrint) then
           while (Code <> '') and (P^.chAccount_Code <> Code) and (P^.chAccount_Code < Code) do
           begin
             //is code in range?
             if TListLedgerReport(ReportJob).ShowCodeOnReport( P^.chAccount_Code) then
             begin
               IsContras := IsThisAContraCode(P^.chAccount_Code, ReportJob);
               IsEmpty := PrintEmptyCodes and
                 (P^.chPosting_Allowed or (ShowBalances and (GetOpeningBalanceAmount(Client,P^.chAccount_Code) <> 0)));
               if IsContras or IsEmpty then
               begin
                 if ShowBalances and (P^.chAccount_Code <> '') then
                 begin
                   RenderTitleLine(P^.chAccount_Code + ' ' + P^.chAccount_Description);
                   TListLedgerReport(ReportJob).SplitCode := P^.chAccount_Code + ' ' + P^.chAccount_Description + ' (continued)';
                   ReportLedgerOpeningBalance(P^.chAccount_Code, ReportJob, False);
                 end;
                 if IsContras then
                   DoContras(ReportJob, P^.chAccount_Code)
                 else
                   PrintSummaryListLedgerLine( Mgr, P^.chAccount_Code, TListLedgerReport(ReportJob));
                 if ShowBalances and (P^.chAccount_Code <> '') then
                 begin
                   ReportLedgerClosingBalance(P^.chAccount_Code, ReportJob, False);
                   TListLedgerReport(ReportJob).SplitCode := '';
                   RenderTextLine('');
                 end
                 else
                   TListLedgerReport(ReportJob).SplitCode := '';
                 LastValidCode := P^.chAccount_Code;
               end;
             end;
             P := Chart.FindNextCode(P^.chAccount_Code, False);
             TListLedgerReport(ReportJob).ClearSubTotals;
             if not Assigned(P) then Break;
           end;

// starting a new code

         LastCodePrinted    := Code;
         if IsValidCode then
          LastValidCode := Code;
         TListLedgerReport(ReportJob).DoneSubTotal := False;
         TListLedgerReport(ReportJob).SplitCode := '';

         // Show opening balance if requested
         if ShowBalances and (Code <> '') then
         begin
           P := Chart.FindCode( Code );
           If Assigned( P ) then
              With P^ do S := Code + '  ' + chAccount_Description
           else
              S := Code + '  INVALID CODE!';
           RenderTitleLine(S);
           TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';
           ReportLedgerOpeningBalance(Code, ReportJob, False, Assigned(P));
         end;

         // Show contras for this code - this will display ALL transactions
         // for this code (so that they display in date order)
         // so after this we need to move onto next code
         if IsThisAContraCode(Code, ReportJob) then
         begin
           AccountHasActivity := DoContras(ReportJob, Code);
           ContraCodePrinted := Code;
           Exit;
         end;
      end;
      //store values
      AccountTotalGross    := AccountTotalGross + dsTemp_Base_Amount;
      AccountTotalTax      := AccountTotalTax   + dsGST_Amount;
      AccountTotalNet      := AccountTotalNet   + ( dsTemp_Base_Amount - dsGST_Amount);
      AccountTotalQuantity := AccountTotalQuantity + dsQuantity;
      if ( dsTemp_Base_Amount <> 0) or ( dsGST_Amount <> 0) then
         AccountHasActivity := true;

      //Super
      if ShowSuperDetails then begin
         SuperTotalImputed_Credit                := SuperTotalImputed_Credit + dsSF_Imputed_Credit;
         SuperTotalTax_Free_Dist                 := SuperTotalTax_Free_Dist + dsSF_Tax_Free_Dist;
         SuperTotalTax_Exempt_Dist               := SuperTotalTax_Exempt_Dist + dsSF_Tax_Exempt_Dist;
         SuperTotalTax_Deferred_Dist             := SuperTotalTax_Deferred_Dist + dsSF_Tax_Deferred_Dist;
         SuperTotalTFN_Credits                   := SuperTotalTFN_Credits + dsSF_TFN_Credits;
         SuperTotalForeign_Income                := SuperTotalForeign_Income + dsSF_Foreign_Income;
         SuperTotalForeign_Tax_Credits           := SuperTotalForeign_Tax_Credits + dsSF_Foreign_Tax_Credits;
         SuperTotalCapital_Gains_Indexed         := SuperTotalCapital_Gains_Indexed + dsSF_Capital_Gains_Indexed;
         SuperTotalCapital_Gains_Disc            := SuperTotalCapital_Gains_Disc + dsSF_Capital_Gains_Disc;
         SuperTotalCapital_Gains_Other           := SuperTotalCapital_Gains_Other + dsSF_Capital_Gains_Other;
         SuperTotalOther_Expenses                := SuperTotalOther_Expenses + dsSF_Other_Expenses;
         SuperTotalCGT_Date                      := SuperTotalCGT_Date + dsSF_CGT_Date;
         SuperTotalFranked                       := SuperTotalFranked + dsSF_Franked;
         SuperTotalUnFranked                     := SuperTotalUnFranked + dsSF_UnFranked;
         SuperTotalInterest                      := SuperTotalInterest + dsSF_Interest;
         SuperTotalCapital_Gains_Foreign_Disc    := SuperTotalCapital_Gains_Foreign_Disc + dsSF_Capital_Gains_Foreign_Disc;
         SuperTotalRent                          := SuperTotalRent + dsSF_Rent;
         SuperTotalSpecial_Income                := SuperTotalSpecial_Income + dsSF_Special_Income;
         SuperTotalOther_Tax_Credit              := SuperTotalOther_Tax_Credit + dsSF_Other_Tax_Credit;
         SuperTotalNon_Resident_Tax              := SuperTotalNon_Resident_Tax + dsSF_Non_Resident_Tax;
         SuperTotalForeign_Capital_Gains_Credit  := SuperTotalForeign_Capital_Gains_Credit + dsSF_Foreign_Capital_Gains_Credit;
      end;

   end;
end;

procedure LGR_PrintEntry(Sender:TObject);
Var
   Code  : Bk5CodeStr;
   P     : pAccount_Rec;
   S, Notes : String;
   RS    : string[20];
   Mgr : TListLedgerTMgr;
   Avg : Currency;
   Net : Money;
   Qty : Money;
   IsContras, IsValidCode, OKToPrint: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);

   With Mgr, ReportJob, ReportJob, TListLedgerReport(ReportJob).Params, Transaction^ do
   Begin
      //is bank account included in this report?
      if not IsBankAccountIncluded(ReportJob, Mgr) then
       Exit;

      Code := txAccount;

      //is code in range?
      if not TListLedgerReport(ReportJob).ShowCodeOnReport( Code) then
        exit;

      // has txn already been printed during contras?
      // if we have printed contras then we have gone thru all codes again from
      // start so we must skip them in here
      if (Code = ContraCodePrinted) and (ContraCodePrinted <> NullCode) then
        exit;

      ContraCodePrinted := NullCode;

      IsValidCode := Assigned(Chart.FindCode( Code ));

//code has changed, handle closing balance

      If Code <> LastCodePrinted then // its a new code
      Begin
         // end last code
         If LastCodePrinted <> NullCode then begin
           if not TListLedgerReport(ReportJob).DoneSubTotal then // avoid duplicate subtotals
             RenderDetailSubTotal('', False, True);
           // Show closing balance if requested
           if ShowBalances and (LastCodePrinted <> '') then
             ReportLedgerClosingBalance(LastCodePrinted, ReportJob, AccountHasActivity, LastCodePrinted = LastValidCode);
           // Need subtotals to calculate closing bal so do not clear during the subtotal printing
           // only safe to clear once closing balances have been printed
           TListLedgerReport(ReportJob).ClearSubTotals;
           TListLedgerReport(ReportJob).DoneSubTotal := False;
         end;
         TListLedgerReport(ReportJob).SplitCode := '';

//handle in between codes

         // Show inactive codes and contras if requested (that are between last code and this code)
         if (LastCodePrinted = NullCode) or (LastValidCode = NullCode) then
           P := Chart.FindNextCode('', False) // finds first code
         else if LastCodePrinted <> LastValidCode then
           P := Chart.FindNextCode(LastValidCode, False)          
         else
           P := Chart.FindNextCode(LastCodePrinted, False);
         // Some conditions to handle invalid codes
         OKToPrint := ((not IsValidCode) and Assigned(P) and (P^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                      ((not IsValidCode) and (LastCodePrinted = LastValidCode) and (LastCodePrinted <> NULLCODE)) and // this code is invalid but last was valid - need to show any between last and this
                      (not Client.clBank_Account_List.IsExchangeGainLossCode(p.chAccount_Code));
                      
         if Assigned(P) and (IsValidCode or OKToPrint) then
           while (Code <> '') and (P^.chAccount_Code <> Code) and (P^.chAccount_Code < Code) do
           begin                      
             //is code in range?
             if TListLedgerReport(ReportJob).ShowCodeOnReport( P^.chAccount_Code) then
             begin
               With P^ do S := chAccount_Code + '  ' + chAccount_Description;

               IsContras := IsThisAContraCode(P^.chAccount_Code, ReportJob);
               
               // show if contra or showing empty posting codes or showing non-posting codes with a balance
               if (IsContras or (PrintEmptyCodes and (P^.chPosting_Allowed or (ShowBalances and (GetOpeningBalanceAmount(Client,P^.chAccount_Code) <> 0))))) then
               begin
                 RenderTitleLine(S);

                 TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';

                 if ShowBalances and (P^.chAccount_Code <> '') then
                   ReportLedgerOpeningBalance(P^.chAccount_Code, ReportJob, True);

                 if IsContras then
                   DoContras(ReportJob, P^.chAccount_Code);

                 if ShowBalances and (P^.chAccount_Code <> '') then
                   ReportLedgerClosingBalance(P^.chAccount_Code, ReportJob, IsContras);

                 TListLedgerReport(ReportJob).DoneSubTotal := False;
                 TListLedgerReport(ReportJob).SplitCode := '';
                 TListLedgerReport(ReportJob).ClearSubTotals;
                 LastValidCode := P^.chAccount_Code;
               end;
             end;
             P := Chart.FindNextCode(P^.chAccount_Code, False);
             if not Assigned(P) then Break;
           end;

//Now we start to print the new code

         if Code = '' then
           S := 'Uncoded'
         else
         begin
           P := Chart.FindCode( Code );
           If Assigned( P ) then
              With P^ do S := Code + '  ' + chAccount_Description
           else
              S := Code + '  INVALID CODE!';
         end;

         RenderTitleLine (S);
         TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';
         LastCodePrinted := Code;
         if IsValidCode then
          LastValidCode := Code;

         // Show opening balance if requested
         if ShowBalances and (Code <> '') then
            ReportLedgerOpeningBalance(Code, ReportJob, True, Assigned(P));

         // Show contras for this code - this will display ALL transactions
         // for this code (so that they display in date order)
         // so after this we need to move onto next code (as per skipping txns earlier in this proc)
         if IsThisAContraCode(Code, ReportJob) then
         begin
           AccountHasActivity := DoContras(ReportJob, Code);
           ContraCodePrinted := Code;
           Exit;
         end;
      end;

      PutString( bkDate2Str ( txDate_Effective ) );

      RS := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);
      PutString( RS );

      If Quantities then
      begin
        Net := txTemp_Base_Amount - txGST_Amount;
        Qty := txQuantity;
        Avg := calcAverage(Net/100,Qty/10000);
      end
      else
      begin
        Qty := 0;
        Avg := 0;
      end;

      if ShowNotes then
        Notes := GetFullNotes(Mgr.Transaction)
      else
        Notes := '';

      TListLedgerReport(ReportJob).PutWrapped(GetNarration(Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type), txGST_Class,
        txTemp_Base_Amount, txGST_Amount, txTemp_Base_Amount - txGST_Amount, Qty, Avg, Notes);

      RenderDetailLine;
      AccountHasActivity := True;
   end;
end;

procedure LGR_PrintDissect(Sender:Tobject);
// similar logic to printing a non-dissection above
Var
   Code  : Bk5CodeStr;
   P     : pAccount_Rec;
   S, Notes, Narration : String;
   RS    : string[20];
   Mgr : TListLedgerTMgr;
   Net : Money;
   Qty   : Money;
   Avg   : Currency;
   IsContras, IsValidCode, OKToPrint: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);
   With Mgr, ReportJob, TListLedgerReport(ReportJob).Params, Transaction^, Dissection^ do
   Begin
      //is bank account included in this report?
      if not IsBankAccountIncluded(ReportJob, Mgr) then
       Exit;

      Code := dsAccount;

      //is code in range?
      if not TListLedgerReport(ReportJob).ShowCodeOnReport( Code) then
        exit;

      // has tx already been printed during contras?
      if (Code = ContraCodePrinted) and (ContraCodePrinted <> NullCode) then
        exit;
      ContraCodePrinted := NullCode;
      IsValidCode := Assigned(Chart.FindCode( Code ));

//code has changed, handle closing balance

      If Code <> LastCodePrinted then
      Begin
         If LastCodePrinted <> NullCode then begin
           if not TListLedgerReport(ReportJob).DoneSubTotal then
             RenderDetailSubTotal('', False, true);
           // Show closing balance if requested
           if ShowBalances and (LastCodePrinted <> '') then
             ReportLedgerClosingBalance(LastCodePrinted, ReportJob, AccountHasActivity, LastCodePrinted = LastValidCode);
           TListLedgerReport(ReportJob).ClearSubTotals;
           TListLedgerReport(ReportJob).DoneSubTotal := False;
         end;
         TListLedgerReport(ReportJob).SplitCode := '';

//handle codes in between

         // Show inactive codes if requested
         if (LastCodePrinted = NullCode) or (LastValidCode = NullCode) then
           P := Chart.FindNextCode('', False)
         else if LastCodePrinted <> LastValidCode then
           P := Chart.FindNextCode(LastValidCode, False)
         else
           P := Chart.FindNextCode(LastCodePrinted, False);

         // Some conditions to handle invalid codes
         OKToPrint := ((not IsValidCode) and Assigned(P) and (P^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                      ((not IsValidCode) and (LastCodePrinted = LastValidCode) and (LastCodePrinted <> NULLCODE)) and // this code is invalid but last was valid - need to show any between last and this
                      (not Client.clBank_Account_List.IsExchangeGainLossCode(p.chAccount_Code));
                      
         if Assigned(P) and (IsValidCode or OKToPrint) then
           while (Code <> '') and (P^.chAccount_Code <> Code) and (P^.chAccount_Code < Code) do
           begin
             //is code in range?
             if TListLedgerReport(ReportJob).ShowCodeOnReport( P^.chAccount_Code) then
             begin
               With P^ do S := chAccount_Code + '  ' + chAccount_Description;
               IsContras := IsThisAContraCode(P^.chAccount_Code, ReportJob);
               if (IsContras or (PrintEmptyCodes and
                       (P^.chPosting_Allowed or (ShowBalances and (GetOpeningBalanceAmount(Client,P^.chAccount_Code) <> 0))))) then
               begin
                 RenderTitleLine(S);
                 TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';
                 if ShowBalances and (P^.chAccount_Code <> '') then
                   ReportLedgerOpeningBalance(P^.chAccount_Code, ReportJob, True);
                 if IsContras then
                   DoContras(ReportJob, P^.chAccount_Code);
                 if ShowBalances and (P^.chAccount_Code <> '') then
                   ReportLedgerClosingBalance(P^.chAccount_Code, ReportJob, IsContras);
                 TListLedgerReport(ReportJob).SplitCode := '';
                 TListLedgerReport(ReportJob).DoneSubTotal := False;
                 TListLedgerReport(ReportJob).ClearSubTotals;
                 LastValidCode := P^.chAccount_Code;
               end;
             end;
             P := Chart.FindNextCode(P^.chAccount_Code, False);
             if not Assigned(P) then Break;
           end;

//Start the new code

         if Code = '' then
           S := 'Uncoded'
         else
         begin
           P := Chart.FindCode( Code );
           If Assigned( P ) then
              With P^ do S := Code + '  ' + chAccount_Description
           else
              S := Code + '  INVALID CODE!';
         end;

         RenderTitleLine(S);
         TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';
         LastCodePrinted := Code;
         if IsValidCode then
          LastValidCode := Code;

         // Show opening balance if requested
         if ShowBalances and (Code <> '') then
           ReportLedgerOpeningBalance(Code, ReportJob, True, Assigned(P));

         // Show contras for this code - this will display ALL transactions
         // for this code (so that they display in date order)
         // so after this we need to move onto next code
         if IsThisAContraCode(Code, ReportJob) then
         begin
           AccountHasActivity := DoContras(ReportJob, Code);
           ContraCodePrinted := Code;
           Exit;
         end;
      end;

      {now do dissection}
      if Mgr.Bank_Account.IsAJournalAccount then
         PutString( bkDate2Str ( txDate_Effective ))
      else
         PutString( bkDate2Str ( txDate_Effective ) + ' [D]');

      if length(dsReference) > 0 then
         RS := dsReference
      else RS := GetFormattedReference( Mgr.Transaction, Mgr.Bank_Account.baFields.baAccount_Type);

      PutString( RS );

      If Quantities then
      begin
        //qty is shown as +ve as long as signs match
        Net := dsTemp_Base_Amount - dsGST_Amount;
        Qty := dsQuantity;
        Avg := calcAverage(Net/100,Qty/10000);
      end
      else
      begin
        Qty := 0;
        Avg := 0;
      end;

      if ShowNotes then
      begin
        Notes := GetFullNotes(Mgr.Dissection)
      end
      else
        Notes := '';

      Narration := GetNarration( Mgr.Dissection, Mgr.Bank_Account.baFields.baAccount_Type);

      TListLedgerReport(ReportJob).PutWrapped(Narration, dsGST_Class,
        dsTemp_Base_Amount, dsGST_Amount, dsTemp_Base_Amount - dsGST_Amount, Qty, Avg, Notes);

      RenderDetailLine;
      AccountHasActivity := True;
   end;
end;

procedure LGR_PrintExchangeGainLoss(Sender: TObject);
var
  BankAccount: TBank_Account;
  BankIndex: Integer;
  CodeIndex: Integer;
  EntryIndex: Integer;
  GainLossEntryList: TExchangeGainLossEntryList;
  GainLossEntry: TExchange_Gain_Loss;
  CodeList: TStringList;
  Account: pAccount_Rec;
  P: pAccount_Rec;
  Title: String;
  TitleLineRendered: Boolean;
  DetailLinesRendered: Boolean;
  Mgr : TListLedgerTMgr;
  Code  : Bk5CodeStr;
  S, Notes : String;
  IsContras, IsValidCode, OKToPrint: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);

   With Mgr, ReportJob, TListLedgerReport(ReportJob) do
   Begin
     //is bank account included in this report?
     if not IsBankAccountIncluded(ReportJob, Mgr) then Exit;
                        
     Code := ExchangeGainLossEntry.glAccount;

      //is code in range?
     if not TListLedgerReport(ReportJob).ShowCodeOnReport(ExchangeGainLossEntry.glAccount) then Exit;

     IsValidCode := Assigned(Params.Chart.FindCode(Code));

     if Code <> LastCodePrinted then // its a new code
     begin
       // end last code
       if LastCodePrinted <> NullCode then
       begin
         if not TListLedgerReport(ReportJob).DoneSubTotal then // avoid duplicate subtotals
         begin
           RenderDetailSubTotal('', False, True);
         end;
         
         // Show closing balance if requested
         if Params.ShowBalances and (LastCodePrinted <> '') then
         begin
           ReportLedgerClosingBalance(LastCodePrinted, ReportJob, AccountHasActivity, LastCodePrinted = LastValidCode);
         end;

         // Need subtotals to calculate closing bal so do not clear during the subtotal printing
         // only safe to clear once closing balances have been printed
         TListLedgerReport(ReportJob).ClearSubTotals;
         TListLedgerReport(ReportJob).DoneSubTotal := False;
       end;

       TListLedgerReport(ReportJob).SplitCode := '';

       if (LastCodePrinted = NullCode) or (LastValidCode = NullCode) then
       begin
         P := Params.Chart.FindNextCode('', False); // finds first code
       end
       else if LastCodePrinted <> LastValidCode then
       begin
         P := Params.Chart.FindNextCode(LastValidCode, False);
       end
       else
       begin
         P := Params.Chart.FindNextCode(LastCodePrinted, False);
       end;

       // Some conditions to handle invalid codes
       OKToPrint := ((not IsValidCode) and Assigned(P) and (P^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                    ((not IsValidCode) and (LastCodePrinted = LastValidCode) and (LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this

       if Assigned(P) and (IsValidCode or OKToPrint) then
       begin
         while (Code <> '') and (P^.chAccount_Code <> Code) and (P^.chAccount_Code < Code) do
         begin
           //is code in range?
           if TListLedgerReport(ReportJob).ShowCodeOnReport( P^.chAccount_Code) then
           begin
             with P^ do
             begin
               S := chAccount_Code + '  ' + chAccount_Description;
             end;

             IsContras := IsThisAContraCode(P^.chAccount_Code, ReportJob);
             
             // show if contra or showing empty posting codes or showing non-posting codes with a balance
             if (IsContras or (Params.PrintEmptyCodes and Params.Client.clBank_Account_List.IsExchangeGainLossCode(p.chAccount_Code) and (P^.chPosting_Allowed or (Params.ShowBalances and (GetOpeningBalanceAmount(Params.Client, P^.chAccount_Code) <> 0))))) then
             begin
               RenderTitleLine(S);

               TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';

               if Params.ShowBalances and (P^.chAccount_Code <> '') then
               begin
                 ReportLedgerOpeningBalance(P^.chAccount_Code, ReportJob, True);
               end;

               if IsContras then
               begin
                 DoContras(ReportJob, P^.chAccount_Code);
               end;
               
               if Params.ShowBalances and (P^.chAccount_Code <> '') then
               begin
                 ReportLedgerClosingBalance(P^.chAccount_Code, ReportJob, False);
               end;

               TListLedgerReport(ReportJob).DoneSubTotal := False;
               TListLedgerReport(ReportJob).SplitCode := '';
               TListLedgerReport(ReportJob).ClearSubTotals;

               LastValidCode := P^.chAccount_Code;
             end;
           end;

           P := Params.Chart.FindNextCode(P^.chAccount_Code, False);
           
           if not Assigned(P) then
           begin
             Break;
           end;
         end;
       end;

       //Now we start to print the new code
       Account := nil;
       if Code = '' then
       begin
         S := 'Uncoded';
       end
       else
       begin
         Account := Params.Chart.FindCode( Code );

         If Assigned( Account ) then
         begin
           with Account^ do
           begin
             S := Code + '  ' + chAccount_Description;
           end
         end
         else
         begin
           S := Code + '  INVALID CODE!';
         end;
       end;

       RenderTitleLine (S);

       TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';

       LastCodePrinted := Code;

       if IsValidCode then
       begin
         LastValidCode := Code;
       end;
       
       // Show opening balance if requested
       if Params.ShowBalances and (Code <> '') then
       begin
         ReportLedgerOpeningBalance(Code, ReportJob, True, Assigned(Account));
       end;

       // Show contras for  this code - this will display ALL transactions
       // for this code (so that they display in date order)
       // so after this we need to move onto next code (as per skipping txns earlier in this proc)
       if IsThisAContraCode(Code, ReportJob) then
       begin
         AccountHasActivity := DoContras(ReportJob, Code);
         ContraCodePrinted := Code;
         Exit;
       end;
     end;

     PutString(bkDate2Str(ExchangeGainLossEntry.glDate));

     SkipColumn;

     TListLedgerReport(ReportJob).PutWrapped('', 0, ExchangeGainLossEntry.glAmount, 0, ExchangeGainLossEntry.glAmount, 0, 0, Notes);

     RenderDetailLine;
     AccountHasActivity := True;
   end;
end;

procedure SummaryListLedger_PrintExchangeGainLoss(Sender: TObject);
Var
   Code  : Bk5CodeStr;
   Mgr   : TListLedgerTMgr;
   P     : pAccount_Rec;
   S     : string;
   IsContras, IsEmpty, IsValidCode, OKToPrint: Boolean;
begin
   Mgr := TListLedgerTMgr(Sender);
   
   with Mgr, ReportJob,TListLedgerReport(ReportJob).Params, Mgr.Transaction^ do
   begin
      if not IsBankAccountIncluded(ReportJob, Mgr) then Exit;

      Code := ExchangeGainLossEntry.glAccount;

      //is code in range?
      if not TListLedgerReport(ReportJob).ShowCodeOnReport( Code) then Exit;
      
      IsValidCode := Assigned(Chart.FindCode(Code));

      //code has changed
      if (Code <> LastCodePrinted) then
      begin
        if (LastCodePrinted <> NullCode) then
        begin
          //code has changed so print totals
          if (AccountHasActivity or PrintEmptyCodes) and (not TListLedgerReport(ReportJob).DoneSubTotal) then
          begin
            PrintSummaryListLedgerLine(Mgr, LastCodePrinted, TListLedgerReport(ReportJob));
          end;

          // Show closing balance if requested
          if ShowBalances and (LastCodePrinted <> '') then
          begin
            ReportLedgerClosingBalance(LastCodePrinted, ReportJob, False, LastCodePrinted = LastValidCode);

            TListLedgerReport(ReportJob).SplitCode := '';

            RenderTextLine('');
          end;
        end;

         //clear temp information
         AccountHasActivity := false;
         AccountTotalGross  := 0;
         AccountTotalTax    := 0;
         AccountTotalNet    := 0;
         AccountTotalQuantity:= 0;
         TListLedgerReport(ReportJob).DoneSubTotal := False;
         TListLedgerReport(ReportJob).SplitCode := '';
         TListLedgerReport(ReportJob).ClearSubTotals;

         //Clear Super
         ClearSuper;

         //request to show all codes regardless of any activity
         //look for all codes in between last (valid) one printed and next to be printed

         if (LastCodePrinted = NullCode) or (LastValidCode = NullCode) then
         begin
           P := Chart.FindNextCode('', False);
         end
         else if LastCodePrinted <> LastValidCode then
         begin
           P := Chart.FindNextCode(LastValidCode, False);
         end
         else
         begin
           P := Chart.FindNextCode(LastCodePrinted, False);
         end;
         
         // Some conditions to handle invalid codes
         OKToPrint := ((not IsValidCode) and Assigned(P) and (P^.chAccount_Code < Code)) or // this code is invalid but next valid code is less than this one - need to show it
                      ((not IsValidCode) and (LastCodePrinted = LastValidCode) and (LastCodePrinted <> NULLCODE)); // this code is invalid but last was valid - need to show any between last and this

         if Assigned(P) and (IsValidCode or OKToPrint) then
         begin
           while (Code <> '') and (P^.chAccount_Code <> Code) and (P^.chAccount_Code < Code) do
           begin
             //is code in range?
             if TListLedgerReport(ReportJob).ShowCodeOnReport( P^.chAccount_Code) then
             begin
               IsContras := IsThisAContraCode(P^.chAccount_Code, ReportJob);
               IsEmpty := PrintEmptyCodes and (P^.chPosting_Allowed or (ShowBalances and (GetOpeningBalanceAmount(Client,P^.chAccount_Code) <> 0)));

               if IsContras or IsEmpty then
               begin
                 if ShowBalances and (P^.chAccount_Code <> '') then
                 begin
                   RenderTitleLine(P^.chAccount_Code + ' ' + P^.chAccount_Description);

                   TListLedgerReport(ReportJob).SplitCode := P^.chAccount_Code + ' ' + P^.chAccount_Description + ' (continued)';

                   ReportLedgerOpeningBalance(P^.chAccount_Code, ReportJob, False);
                 end;

                 if IsContras then
                 begin
                   TListLedgerReport(ReportJob).SplitCode := P^.chAccount_Code + ' ' + P^.chAccount_Description + ' (continued)';

                   DoContras(ReportJob, P^.chAccount_Code)
                 end
                 else
                 begin
                   PrintSummaryListLedgerLine( Mgr, P^.chAccount_Code, TListLedgerReport(ReportJob));
                 end;
                 
                 if ShowBalances and (P^.chAccount_Code <> '') then
                 begin
                   ReportLedgerClosingBalance(P^.chAccount_Code, ReportJob, False);

                   TListLedgerReport(ReportJob).SplitCode := '';

                   RenderTextLine('');
                 end
                 else
                 begin
                   TListLedgerReport(ReportJob).SplitCode := '';
                 end;

                 LastValidCode := P^.chAccount_Code;
               end;
             end;

             P := Chart.FindNextCode(P^.chAccount_Code, False);

             TListLedgerReport(ReportJob).ClearSubTotals;

             if not Assigned(P) then Break;
           end;
         end;

         // starting a new code

         LastCodePrinted := Code;
         if IsValidCode then
         begin
           LastValidCode := Code;
         end;
         
         TListLedgerReport(ReportJob).DoneSubTotal := False;
         TListLedgerReport(ReportJob).SplitCode := '';

         // Show opening balance if requested
         if ShowBalances and (Code <> '') then
         begin
           P := Chart.FindCode( Code );

           If Assigned( P ) then
           begin
              with P^ do S := Code + '  ' + chAccount_Description;
           end
           else
           begin
              S := Code + '  INVALID CODE!';
           end;

           RenderTitleLine(S);

           TListLedgerReport(ReportJob).SplitCode := S + ' (continued)';

           ReportLedgerOpeningBalance(Code, ReportJob, False, Assigned(P));
         end;

         // Show contras for this code - this will display ALL transactions
         // for this code (so that they display in date order)
         // so after this we need to move onto next code
         if IsThisAContraCode(Code, ReportJob) then
         begin
           AccountHasActivity := DoContras(ReportJob, Code);
           ContraCodePrinted := Code;

           Exit;
         end;
      end;

      //store values
      AccountTotalGross    := AccountTotalGross + ExchangeGainLossEntry.glAmount;
      AccountTotalNet    := AccountTotalNet + ExchangeGainLossEntry.glAmount;

      if ExchangeGainLossEntry.glAmount <> 0 then
      begin
        AccountHasActivity := True;
      end;
   end;
end;

procedure TListLedgerReport.PutWrapped(Narration: string; GSTClass: Byte;
  Gross, GST, Net, Qty: Comp; Avg: Currency; Notes: string);
// add narration notes to ledger report and allow them to span 10 lines max
const
  MaxNotesLines = 10;
var
  j, ColWidth, OldWidth : Integer;
  NotesList, NarrationList  : TStringList;
  NarrationDone, NotesDone: Boolean;
begin
  NarrationDone := False;
  NotesDone := False;
  NotesList  := TStringList.Create;
  NarrationList  := TStringList.Create;
  try
    NotesList.Text := Notes;
    NarrationList.Text := Narration;
    // Remove blank lines
    j := 0;
    while j < NotesList.Count do
    begin
      if NotesList[j] = '' then
        NotesList.Delete(j)
      else
        Inc(j);
    end;
    j := 0;
    while j < NarrationList.Count do
    begin
      if NarrationList[j] = '' then
        NarrationList.Delete(j)
      else
        Inc(j);
    end;
    j := 0;
    repeat
      // Wrap Narration
      if (j < NarrationList.Count) and (not NarrationDone) then
      begin
        ColWidth := RenderEngine.RenderColumnWidth(CurrDetail.Count, NarrationList[ j]);
        if (ColWidth < Length(NarrationList[j])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store
          while (ColWidth > 0) and (NarrationList[j][ColWidth] <> ' ') do
            Dec(ColWidth);
          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!
          NarrationList.Insert(j + 1, Copy(NarrationList[j], ColWidth + 1, Length(NarrationList[j]) - ColWidth + 1));
          NarrationList[j] := Copy(NarrationList[j], 1, ColWidth);
        end;
        PutString( NarrationList[ j]);
        if not Params.WrapNarration then
          NarrationDone := True;
      end
      else // May still be some more notes to print
        SkipColumn;

      if j = 0 then // First line - add other detail
      begin
        if params.GrossGST then
        begin
          if (GSTClass = 0) then
            SkipColumn
          else
            PutString( GetGSTClassCode(Params.Client, GSTClass));
          PutMoney( Gross );
          PutMoney( GST );
        end;
        PutMoney( Gross - GST );

        If Params.ShowQuantity then
        begin
          PutQuantity( Qty);
          PutCurrency( Avg);
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
      if (j < NotesList.Count) and (not NotesDone) then
      begin
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
        if not Params.WrapNarration then
          NotesDone := True;
      end
      else // May still be some more narration to print
        SkipColumn;

      Inc( j);

      //decide if need to call renderDetailLine
      if (((j < NotesList.Count)
           and (not NotesDone)) or ((j < NarrationList.Count) and (not NarrationDone))) and ( j < MaxNotesLines) then
      begin
        RenderDetailLine(False);
        SkipColumn; // Date
        SkipColumn; // Reference
      end;
    until (((j >= NotesList.Count) or NotesDone) and ((j >= NarrationList.Count) or NarrationDone)) or ( j >= MaxNotesLines);
  finally
     NotesList.Free;
     NarrationList.Free;
  end;                                    
end;

function TListLedgerReport.ShowCodeOnReport(aCode: string): boolean;
var
  i : integer;
begin
  result := true;

  if Params.ShowAllCodes then
  begin
    if ( aCode <> '') then
      exit;
  end
  else
  begin
    for i := Low( Params.RangesArray) to High( Params.RangesArray) do
    begin
      with Params.RangesArray[i] do
      begin
        if ( ToCode <> '') then
        begin
          if (Params.Client.AccountCodeCompare(aCode, FromCode) >= 0) and
             (Params.Client.AccountCodeCompare(aCode, ToCode) <= 0) then
            Exit;
        end
        else
          if ( FromCode <> '') and ( FromCode = aCode) then
            //special case, if only a from code is specified then match
            //on the specific code
            Exit;
      end;
    end;
  end;

  result := false;
end;

procedure TListLedgerReport.BKPrint;
var
   TravMgr : TListLedgerTMgr;
   P     : pAccount_Rec;
   S: string;
   IsContras: Boolean;
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
     TravMgr.LastCodePrinted    := NullCode;
     TravMgr.ContraCodePrinted  := NullCode;
     TravMgr.LastValidCode      := NullCode;
     TravMgr.Quantities           := Params.ShowQuantity;

     //decide what to do with each code
     if Params.ShowSuperDetails then begin
       if Params.SummaryReport then begin
         TravMgr.OnEnterEntry      := SummaryListLedger_PrintEntry;
         TravMgr.OnEnterDissection  := SummaryListLedger_PrintDissect;
       end else begin
         TravMgr.OnEnterEntry      := Custom_LGR_PrintEntry;
         TravMgr.OnEnterDissection  := Custom_LGR_PrintDissect;
       end;
     end else if Params.SummaryReport then begin
       TravMgr.OnEnterEntry       := SummaryListLedger_PrintEntry;
       TravMgr.OnEnterDissection  := SummaryListLedger_PrintDissect;

       if IsForeignCurrencyClient then
       begin
         TravMgr.OnEnterExchangeGainLoss := SummaryListLedger_PrintExchangeGainLoss;
       end;
     end
     else begin
        TravMgr.OnEnterEntry      := LGR_PrintEntry;
        TravMgr.OnEnterDissection := LGR_PrintDissect;

        if IsForeignCurrencyClient then
        begin
          TravMgr.OnEnterExchangeGainLoss := LGR_PrintExchangeGainLoss;
        end;
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
        begin
          PrintSummaryListLedgerLine( TravMgr, TravMgr.LastCodePrinted, Self);
        end;

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
          else
          if (TravMgr.ContraCodePrinted = NullCode) then
          begin
            RenderDetailSubTotal('', False, True);
            // Show closing balance if requested
            if Params.ShowBalances then
              ReportLedgerClosingBalance(TravMgr.LastcodePrinted, Self, TravMgr.AccountHasActivity, TravMgr.LastCodePrinted = TravMgr.LastValidCode);
          end
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
       P := Params.Chart.FindNextCode('', False)
     else
       P := Params.Chart.FindNextCode(TravMgr.LastValidCode, False);
     if Assigned(P) then
       while Assigned(P) do
       begin
         //is code in range?
         if ShowCodeOnReport( P^.chAccount_Code) then
         begin
           With P^ do S := chAccount_Code + '  ' + chAccount_Description;
           IsContras := IsThisAContraCode(P^.chAccount_Code, Self);
           if IsContras or (Params.PrintEmptyCodes and (P^.chPosting_Allowed or (Params.ShowBalances and (GetOpeningBalanceAmount(Params.Client,P^.chAccount_Code) <> 0)))) and not HasExchangeGainLossEntries(P^.chAccount_Code, Params) then
           begin
             if (not Params.SummaryReport) or Params.ShowBalances then
             begin
               RenderTitleLine(S);
               SplitCode := S + ' (continued)';
             end;
             if Params.ShowBalances and (P^.chAccount_Code <> '') then
               ReportLedgerOpeningBalance(P^.chAccount_Code, Self, not Params.SummaryReport);
             if IsContras then
               DoContras(Self, P^.chAccount_Code)
             else if Params.Summaryreport then
               PrintSummaryListLedgerLine( TravMgr, P^.chAccount_Code, Self);
             if Params.ShowBalances and (P^.chAccount_Code <> '') then
             begin
               ReportLedgerClosingBalance(P^.chAccount_Code, Self, (IsContras and (not Params.Summaryreport)));
               SplitCode := '';
               if Params.SummaryReport then
                 RenderTextLine('');
             end;
           end;
           SplitCode := '';
         end;
         P := Params.Chart.FindNextCode(P^.chAccount_Code, False);
         ClearSubTotals;
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

procedure GenerateSummaryListLedgerReport( Dest : TReportDest; Job : TListLedgerReport);
//summary list ledger displays totals for codes rather than transactions
var
  S           : string;
  CLeft, CGap : double;
  AvgQuantityCol : TReportColumn;
  AvgValueCol    : TReportColumn;
  MoreWidth: Integer;
  KeepGST: Boolean;
  CSym : String;
  TaxName : String;
begin
  NET_AMOUNT_CAPTION := Job.Params.Client.CurrencySymbol + ' Net';

  CSym := job.params.Client.CurrencySymbol;
  TaxName := job.params.Client.TaxSystemNameUC;

  KeepGST := job.params.Client.clFields.clGST_Inclusive_Cashflow;
  job.params.Client.clFields.clGST_Inclusive_Cashflow := False;

  CalculateAccountTotalsForClient(job.params.Client, True, Job.Params.AccountList, -1, False, True);
  job.params.Client.clFields.clGST_Inclusive_Cashflow := KeepGST;


  Job.LoadReportSettings(UserPrintSettings,job.params.MakeRptName(Report_List_Names[REPORT_SUMMARY_LIST_LEDGER]));

  //Add Headers
  AddCommonHeader(Job);

  S := 'FROM ';
  If  Job.Params.FromDate =0 then
     S := S + 'FIRST'
  else
     S := S + bkDate2Str( Job.Params.Fromdate );
  S := S + ' TO ';

  If Job.params.ToDate = MaxLongInt then
     S := S + 'LAST'
  else
     S := S + bkDate2Str( Job.params.ToDate );

  AddJobHeader(Job,siTitle,'SUMMARY LEDGER REPORT '+S, true);
  AddJobHeader(Job,siSubTitle,'', true);

  with Job.params.Client.clFields do begin
    CLeft := Gcleft;
    CGap  := GcGap;

    if (Job.Params.GrossGST) and (not Job.Params.ShowQuantity) then
      MoreWidth := 10
    else
      MoreWidth := 0;

    if Job.Params.ShowBalances then
      AddColAuto( Job, cleft, 32.0 + MoreWidth, cGap, DESCRIPTION_CAPTION  ,jtLeft)
    else
    begin
      AddColAuto( Job, cleft, 10.0, cGap, 'Account'       , jtLeft);
      AddColAuto( Job, cleft, 22.0 + MoreWidth, cGap, 'Description'  ,jtLeft);
    end;

    if Job.Params.GrossGST then
    begin
      AddFormatColAuto(Job, cLeft, 13.0, cGap, CSym + ' Gross', jtRight,NUMBER_FORMAT,NUMBER_FORMAT, true);
      AddFormatColAuto(Job, cLeft, 13.0, cGap, CSym + ' ' + TaxName,   jtRight,NUMBER_FORMAT,NUMBER_FORMAT, true);
    end;
    AvgValueCol := AddFormatColAuto(Job, cLeft, 13.0, cGap, NET_AMOUNT_CAPTION, jtRight,NUMBER_FORMAT,NUMBER_FORMAT, true);

    if Job.Params.ShowQuantity then
    begin
       AvgQuantityCol := AddFormatColAuto(Job,cLeft,11.0,cGap,'Quantity',jtRight,QUANTITY_FORMAT,QUANTITY_FORMAT,False);
       AddAverageColAuto(Job,cLeft,10.0,cGap,'Avg '+CSym+' Net',jtRight,NUMBER_FORMAT,NUMBER_FORMAT,False,AvgQuantityCol, AvgValueCol);
    end;
  end;

  //Add Footers
  AddCommonFooter(Job);

  Job.Generate(Dest, Job.Params);
end;

procedure GenerateDetailedListLedgerReport( Dest : TReportDest; Job : TListLedgerReport);
var
  S              : string;
  cleft, cGap    : double;
  AvgValueCol    : TReportColumn;
  AvgQuantityCol : TReportColumn;
  ExtraWidth, MoreWidthNarration, MoreWidthNotes: double;  //available if not showing quantities
  KeepGST: Boolean;
  CSym : String;
  TaxName : String;
begin;
  NET_AMOUNT_CAPTION := job.Params.Client.CurrencySymbol + ' Net';
  CSym := job.params.Client.CurrencySymbol;
  TaxName := job.params.Client.TaxSystemNameUC;

  KeepGST := job.params.Client.clFields.clGST_Inclusive_Cashflow;
  job.params.Client.clFields.clGST_Inclusive_Cashflow := False;
  CalculateAccountTotalsForClient(job.params.Client, True, Job.Params.AccountList, -1, False, True);
  job.params.Client.clFields.clGST_Inclusive_Cashflow := KeepGST;

  Job.LoadReportSettings(UserPrintSettings,job.params.MakeRptName(Report_List_Names[REPORT_LIST_LEDGER]));

  //Add Headers
  AddCommonHeader(Job);



  S := 'FROM ';
  If  Job.Params.Fromdate =0 then
     S := S + 'FIRST'
  else
     S := S + bkDate2Str(Job.Params.Fromdate );
  S := S + ' TO ';

  If Job.Params.Todate = MaxLongInt then
     S := S + 'LAST'
  else
     S := S + bkDate2Str( Job.Params.ToDate );

  AddJobHeader(Job,SiSubTitle,'LEDGER REPORT '+S, true);
  AddJobHeader(Job,SiSubTitle,'', true);

  // Workout the width
  //if we are not showing the quantities then there is extra width available
  //to be used.  quantity takes up 16% so can use 8 extra widths
  if Job.Params.ShowNotes then
    ExtraWidth := -1.0
  else if Job.Params.ShowQuantity then
     ExtraWidth := 0.0
  else
     ExtraWidth := 2.0;

  // Build the columns
  with Job.params.Client.clFields do
  begin
    CLeft := GcLeft;
    CGap  := Gcgap;


    if not Job.Params.GrossGST then
    begin
      if Job.Params.ShowNotes then
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

    AddColAuto(Job,cleft, 8 ,cGap,DATE_CAPTION, jtLeft);
    AddColAuto(Job,cleft, 10.0 + ExtraWidth ,cGap,REFERENCE_CAPTION,jtLeft);
    AddColAuto(Job,cLeft, MoreWidthNarration + 20 + 4 * ExtraWidth  ,cGap, NARRATION_CAPTION,jtLeft);

    if Job.Params.GrossGST then
    begin
      AddColAuto(Job,cLeft, 3.5, cGap, TaxName, jtLeft);
      AddFormatColAuto(Job, cLeft, 10.0 + ExtraWidth, cGap, CSym + ' Gross',jtRight,NUMBER_FORMAT,NUMBER_FORMAT,true);
      AddFormatColAuto(Job, cLeft, 10.0 + ExtraWidth, cGap, CSym +' '+ TaxName, jtRight,NUMBER_FORMAT,NUMBER_FORMAT,true);
    end;
    AvgValueCol := AddFormatColAuto(Job,cLeft,10.0 + ExtraWidth ,cGap,NET_AMOUNT_CAPTION,jtRight,NUMBER_FORMAT,NUMBER_FORMAT,true);

    if Job.Params.ShowQuantity then
    begin
       AvgQuantityCol := AddFormatColAuto(Job,cLeft,8.0,cGap,'Quantity',jtRight,QUANTITY_FORMAT,QUANTITY_FORMAT,true);
       AvgQuantityCol.isGrandTotalCol := False;
       AvgQuantityCol := AddAverageColAuto(Job,cLeft,8.0,cGap,'Avg '+CSym+' Net',jtRight,NUMBER_FORMAT,NUMBER_FORMAT,True,AvgQuantityCol, AvgValueCol);
       AvgQuantityCol.isGrandTotalCol := False;
       if Job.Params.ShowNotes then
         AddColAuto(Job,cLeft, 15.0, cGap, 'Notes',jtLeft);
    end
    else if Job.Params.ShowNotes then
      AddColAuto(Job,cLeft, MoreWidthNotes + 25.0, cGap, 'Notes',jtLeft);
  end;

  //Add Footers
  AddJobFooter(Job, siFootNote, '[D] = Part of Dissected Entry', true);
  AddCommonFooter(Job);

  Job.Generate(Dest,Job.Params);
end;

procedure GenerateSuperFundListLedgerReport(Dest: TReportDest; Job: TListLedgerReport);
var
  S: string;
  KeepGST: Boolean;
begin
  KeepGST := job.params.Client.clFields.clGST_Inclusive_Cashflow;
  job.params.Client.clFields.clGST_Inclusive_Cashflow := False;
  CalculateAccountTotalsForClient(job.params.Client, True, Job.Params.AccountList);
  job.params.Client.clFields.clGST_Inclusive_Cashflow := KeepGST;

  Job.LoadReportSettings(UserPrintSettings,job.params.MakeRptName(Report_List_Names[REPORT_LIST_LEDGER]));

  S := 'FROM ';
  If  Job.Params.Fromdate =0 then
     S := S + 'FIRST'
  else
     S := S + bkDate2Str(Job.Params.Fromdate );
  S := S + ' TO ';

  If Job.Params.Todate = MaxLongInt then
     S := S + 'LAST'
  else
     S := S + bkDate2Str( Job.Params.ToDate );

  //Header
  AddCommonHeader(Job);

  if Job.Params.SuperfundTitle > '' then begin
     if not sametext( 'Hide', Job.Params.SuperfundTitle) then
        S := format('%s %s', [Job.Params.SuperfundTitle, s])
     // if hide, S jus stays S...   
  end else if Job.Params.SummaryReport then
     S := 'SUMMARY LEDGER REPORT WITH SUPER DETAILS ' + S
  else
     S := 'LEDGER REPORT WITH SUPER DETAILS ' + S;

  AddJobHeader(Job,siTitle, S, true,jtCenter,True);

  AddJobHeader(Job,SiSubTitle,'', true);

  //Ledger and superfund fields
  Job.Params.ColManager.AddReportColumns(Job);

  //Footers
  if not job.params.SummaryReport then
    AddJobFooter(Job, siFootNote, '[D] = Part of Dissected Entry', true);
  AddCommonFooter(Job);

  Job.UserReportSettings.s7Orientation := job.Params.ColManager.Orientation;
  Job.Generate(Dest, Job.Params);
end;

procedure DoListLedgerReport(Dest : TReportDest;
                    RptBatch : TReportBase = nil);
var
   Job   : TListLedgerReport;
   Params : TLRParameters;
   Previewed : Boolean;
   ISOCodes: string;
   FromDate: TStDate;
   ToDate: TStDate;
   This_Year_Starts : TStDate;
   This_Year_Ends : TStDate;
   Last_Year_Starts : TStDate;
   Last_Year_Ends : TStDate;
begin
   Previewed := False;
   Params := TLRParameters.Create(ord(Report_List_Ledger),MyClient,RptBatch,DPeriod);

   try
     Params.AccountFilter := TransferringJournalsSet;
     Params.GetBatchAccounts;
     repeat
       if not GetLRParameters(Params,Previewed) then
           exit;  // done..

       case Params.Runbtn of
         BTN_PRINT   : Dest := rdPrinter;
         BTN_PREVIEW : Dest := rdScreen;
         BTN_FILE    : Dest := rdFile;
       else
         Dest := rdAsk;
       end;

       FromDate := Params.FromDate;
       ToDate := Params.ToDate;

       // Opening/Closing balances require a broader date range for Forex
       if Params.ShowBalances then
       begin
         CalculateAccountTotals.CalcYearStartEndDates(MyClient, This_Year_Starts,
           This_Year_Ends, Last_Year_Starts, Last_Year_Ends);

         FromDate := This_Year_Starts;
       end;

       //Check Forex
       if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, {ForReport=}True, {AllBankAccounts=}False) then begin
         HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
         Exit;
       end;

       Job := TListLedgerReport.Create(RptLedger);
       try
         Job.Params := Params;

         if Params.ShowSuperDetails then begin
            GenerateSuperFundListLedgerReport( Dest, Job)
         end else if Job.Params.SummaryReport then
            GenerateSummaryListLedgerReport( Dest, Job)
         else
            GenerateDetailedListLedgerReport( Dest, Job);

       finally
         Job.Free;
       end;
       Previewed := True;
     until Params.RunExit(Dest);
   finally
     PaRams.Free;
   end;
end;


{ TListLedgerTMgr }

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
end;

end.

