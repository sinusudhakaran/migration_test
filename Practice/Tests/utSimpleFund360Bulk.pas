unit utSimpleFund360Bulk;
{$TYPEINFO ON} //Needed for classes with published methods

interface

uses
  bkConst,
  bkDefs,
  Classes,
  MoneyDef,
  OmniXML,
  TestFramework; // DUnit

const
  Apr01_2004 = 147649;
  Apr02_2004 = Apr01_2004 + 1;
  Apr03_2004 = Apr01_2004 + 2;
  Apr04_2004 = Apr01_2004 + 3;
  Apr05_2004 = Apr01_2004 + 4;

type
  TSimpleFund360BulkTestCase = class(TTestCase)
  private
    fTestTransaction_Rec : pTransaction_Rec;
    fFields              : TStringList;
    TestNode      : IxmlNode;

    TransactionsNode    : IxmlNode;
    CurrentTransaction  : IXMLNode;
    ContraEntries       : IXMLNode;
    Entry               : IXMLNode;
    EntryType           : IXMLNode;
    EntryTypeDetail     : IXMLNode;
    TransactionTypeNode : IXMLNode;

    function SetupTransactionRec (AccountCode : string ) : pTransaction_Rec;
    procedure AddDateField(const Name: string; Value: Integer);
    procedure AddField(const Name, Value: string);
    procedure AddMoneyField(const Name: string; Value: Money);
    procedure AddNumberField(const Name: string; Value: Integer);
    procedure AddQtyField(const Name: string; Value: Money);
    procedure AddTaxFields(TaxAmount: Money; TaxClass: Integer);
    function GetFullNotes(pT: pTransaction_Rec): string;
    function LookupChart(const Value: string): string;
    function LookupJob(const Value: string): string;
    function TransactionToText(aTrans: pTransaction_Rec): string;
    procedure CheckGeneric(asEntry_Type_Detail: string);
    procedure CheckBGL360(aiAccount: integer);
    procedure RunTestForAccountNumber(asAccountNumber: string);
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure TestExtractBGL360_Distribution;
    procedure TestExtractBGL360_Dividend;
    procedure TestExtractBGL360_Interest;
    procedure TestExtractBGL360_ShareTrade;
    procedure TestExtractBGL360_OtherTransaction;
  end;

implementation

{ TSimpleFundXTestCase }

uses
  ExtractBGL360,
  ExtractCommon,
  SysUtils,
  StDateSt,
  trxList32;
//  BKTXIO;

const
  c_ExtractNumberAs = 'WBM037148807694';
  cttanDistribution = 23800;
  cttanDividend     = 23900;
  cttanInterest     = 25000;
//  cttanShareTrade   = 70000;
  cttanShareTradeRangeStart   = 70000;
  cttanShareTradeRangeEnd     = 79999;

function StripBGL360ControlAccountCode( Value : string ) : integer;
var
  liPos  : integer;
  lsControlCode : string;
begin
  Result := 0;
  Value := trim( Value );
  if Value <> '' then begin
    liPos := pos( '/', Value);  // Fetch the control account code, if this is a sub account type
    if liPos = 0 then           // Not a sub account type, so fetch the whole code
      lsControlCode := Value
    else
      lsControlCode := copy( Value, 1, pred( liPos ) ); // Fetch the first characters (or the whole acocunt code if not a sub account)
    result := StrToIntDef(  lsControlCode ,0 );
  end;
end;

procedure PopulateTransactionRec( aAccount : string; aTransRec : pTransaction_Rec; var aAccountCode : integer; var aAcctHead : string );
  procedure PopulateShareTrade;
  begin
    ///////////// ***************** Share Trade Tab ***************** ////////////////
    //    fBGL360_Units
    aTransRec^.txQuantity                                                            := 5;
    //    fBGL360_Contract_Date
    aTransRec^.txTransaction_Extension^.teSF_Contract_Date                           := Apr03_2004;
    //    fBGL360_Settlement_Date
    aTransRec^.txTransaction_Extension^.teSF_Settlement_Date                         := Apr04_2004;
    //    fBGL360_Brokerage - abs
    aTransRec^.txTransaction_Extension^.teSF_Share_Brokerage                         := 10;
    //    fBGL360_GST_Rate - abs
    aTransRec^.txTransaction_Extension^.teSF_Share_GST_Rate                          := '75';
    //    fBGL360_GST_Amount - abs
    aTransRec^.txTransaction_Extension^.teSF_Share_GST_Amount                        := Round(12000 / 9);;
    //    fBGL360_Consideration
    aTransRec^.txTransaction_Extension^.teSF_Share_Consideration                     := 1234;
    ///////////// ***************** Share Trade Tab ***************** ////////////////
  end;

  procedure PopulateDividendAndDistribution;
  begin
    ///////////// ***************** Dividend / Distribution Tabs ***************** ////////////////
    //    fBGL360_Dividends_Franked - abs
    aTransRec^.txSF_Franked                                                          := 9000;
    //    fBGL360_Dividends_Unfranked - abs
    aTransRec^.txSF_Unfranked                                                        := 3000;
    //    fBGL360_Franking_Credits - abs
    aTransRec^.txSF_Imputed_Credit                                                   := 500;
    ///////////// ***************** Dividend / Distribution Tabs ***************** ////////////////
    ///////////// ***************** Distribution / Dividend ***************** ////////////////
    //    fBGL360_Assessable_Foreign_Source_Income - abs
    aTransRec^.txSF_Foreign_Income                                                   := 1100;
    //    fBGL360_Foreign_Income_Tax_Paid_Offset_Credits - abs
    aTransRec^.txSF_Foreign_Tax_Credits                                              := 1200;
    //    fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company - abs
    aTransRec^.txTransaction_Extension^.teSF_AU_Franking_Credits_NZ_Co               := 1300;
    ///////////// ***************** Distribution / Dividend ***************** ////////////////

    ///////////// ***************** Distribution / Dividend Tabs ***************** ////////////////
    //    fBGL360_LIC_Deduction - abs
    aTransRec^.txTransaction_Extension^.teSF_LIC_Deductions                          := 3000;
    ///////////// ***************** Distribution / Dividend Tabs ***************** ////////////////
  end;

  procedure PopulateDistributionAndInterest;
  begin
    ///////////// ***************** Distribution / Interest Tabs ***************** ////////////////
    //   fBGL360_Interest - abs
    aTransRec^.txSF_Interest                                                         := 100;
    //    fBGL360_Other_Income - abs
    aTransRec^.txTransaction_Extension^.teSF_Other_Income                            := 200;
    ///////////// ***************** Distribution / Interest Tabs ***************** ////////////////
  end;

  procedure PopulateDistribution;
  begin
    ///////////// ***************** Distribution ***************** ////////////////
    //    fBGL360_Less_Other_Allowable_Trust_Deductions - abs
    aTransRec^.txTransaction_Extension^.teSF_Other_Trust_Deductions                  := 300;
    //    fBGL360_Discounted_Capital_Gain_Before_Discount - abs
    aTransRec^.txSF_Capital_Gains_Disc                 := 0;
    //    fBGL360_Capital_Gains_CGT_Concessional_Amount - abs
    aTransRec^.txTransaction_Extension^.teSF_CGT_Concession_Amount                   := 400;
    //    fBGL360_Capital_Gain_Indexation_Method - abs
    aTransRec^.txSF_Capital_Gains_Indexed     := 0;
    //    fBGL360_Capital_Gain_Other_Method - abs
    aTransRec^.txSF_Capital_Gains_Other  := 0;
    //    fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount - abs
    aTransRec^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Before_Disc              := 500;
    //    fBGL360_Foreign_Capital_Gains_Indexation_Method - abs
    aTransRec^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Indexation               := 600;
    //    fBGL360_Foreign_Capital_Gains_Other_Method - abs
    aTransRec^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Other_Method             := 700;
    //    fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid - abs
    aTransRec^.txSF_Capital_Gains_Foreign_Disc                                       := 800;
    //    fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid - abs
    aTransRec^.txTransaction_Extension^.teSF_CGT_TaxPaid_Indexation                  := 900;
    //    fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid - abs
    aTransRec^.txTransaction_Extension^.teSF_CGT_TaxPaid_Other_Method                := 1000;
    ///////////// ***************** Distribution ***************** ////////////////
    ///////////// ***************** Distribution ***************** ////////////////
    //    fBGL360_Other_Net_Foreign_Source_Income - abs
    aTransRec^.txTransaction_Extension^.teSF_Other_Net_Foreign_Income                := 1400;
    //    fBGL360_Cash_Distribution - abs
    aTransRec^.txTransaction_Extension^.teSF_Cash_Distribution                       := 1500;
    //    fBGL360_Tax_Exempted_Amounts - abs
    aTransRec^.txSF_Tax_Exempt_Dist                                                  := 1600;
    //    fBGL360_Tax_Free_Amounts - abs
    aTransRec^.txSF_Tax_Free_Dist                                                    := 1700;
    //    fBGL360_Tax_Deferred_amounts - abs
    aTransRec^.txSF_Tax_Deferred_Dist                                                := 1800;
    ///////////// ***************** Distribution ***************** ////////////////

    ///////////// ***************** Distribution Tab ***************** ////////////////
    //    fBGL360_Other_Expenses - abs
    aTransRec^.txSF_Other_Expenses                                                   := 2100;
    //    fBGL360_Other_Net_Foreign_Source_Income - abs
    aTransRec^.txTransaction_Extension^.teSF_Other_Net_Foreign_Income                := 2200;
    //    fBGL360_Cash_Distribution - abs
    aTransRec^.txTransaction_Extension^.teSF_Cash_Distribution                       := 2300;
    //    fBGL360_Tax_Exempted_Amounts - abs
    aTransRec^.txSF_Tax_Exempt_Dist                                                  := 2400;
    //    fBGL360_Tax_Free_Amounts - abs
    aTransRec^.txSF_Tax_Free_Dist                                                    := 2500;
    //    fBGL360_Tax_Deferred_amounts - abs
    aTransRec^.txSF_Tax_Deferred_Dist                                                := 2600;
    //    fBGL360_TFN_Amounts_withheld - abs
    aTransRec^.txSF_TFN_Credits                                                      := 2700;
    //    fBGL360_Non_Resident_Withholding_Tax - abs
    aTransRec^.txTransaction_Extension^.teSF_Non_Res_Witholding_Tax                  := 2800;
    //    fBGL360_Other_Expenses - abs
    aTransRec^.txSF_Other_Expenses                                                   := 2900;
    ///////////// ***************** Distribution Tab ***************** ////////////////

    ///////////// ***************** Distribution Tab ***************** ////////////////
    //    fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash - abs
    aTransRec^.txTransaction_Extension^.teSF_Non_Cash_CGT_Discounted_Before_Discount := 3100;
    //    fBGL360_Capital_Gains_Indexation_Method_Non_Cash - abs
    aTransRec^.txTransaction_Extension^.teSF_Non_Cash_CGT_Indexation                 := 3200;
    //    fBGL360_Capital_Gains_Other_Method_Non_Cash - abs
    aTransRec^.txTransaction_Extension^.teSF_Non_Cash_CGT_Other_Method               := 3300;
    //    fBGL360_Capital_Losses_Non_Cash - abs
    aTransRec^.txTransaction_Extension^.teSF_Non_Cash_CGT_Capital_Losses             := 3400;
    ///////////// ***************** Distribution Tab ***************** ////////////////
  end;

  procedure PopulateDistributionDividendInterest;
  begin
    ///////////// ***************** Distribution / Dividend  / Interest tabs ***************** ////////////////
    //    fBGL360_TFN_Amounts_withheld - abs
    aTransRec^.txSF_TFN_Credits                                                      := 1900;
    //    fBGL360_Non_Resident_Withholding_Tax - abs
    aTransRec^.txTransaction_Extension^.teSF_Non_Res_Witholding_Tax                  := 2000;
    ///////////// ***************** Distribution / Dividend  / Interest tabs ***************** ////////////////
  end;


begin
  aTransRec^.txDate_Presented         := Apr01_2004;
  aTransRec^.txDate_Effective          := Apr02_2004;
  aTransRec^.txAmount                  := 12000;

//E.g '78200/GPT.AX'; //Share // '25000'; //Interest //'23900'; //Dividends // '23800'; // Distribution
  aTransRec^.txAccount                 := aAccount;
  aTransRec^.txNotes                   := 'NOTE';
  aTransRec^.txGL_Narration            := 'Account 1 Tran1';
  aTransRec^.txTax_Invoice_Available   := false;
  aTransRec^.txPayee_Number            := 1;
  aTransRec^.txGST_Class               := 1;
  aTransRec^.txGST_Amount              := Round(12000 / 9);
  aTransRec^.txExternal_GUID           := '0987654321';

  aAccountCode := StripBGL360ControlAccountCode( aTransRec^.txAccount );

  case aAccountCode of
    cttanDistribution : begin
      aAcctHead := 'Distribution_Transaction';
      PopulateDividendAndDistribution;
      PopulateDistributionDividendInterest;
      PopulateDistributionAndInterest;
      PopulateDistribution;

    end;

    cttanDividend : begin
      aAcctHead := 'Dividend_Transaction';
      PopulateDistributionDividendInterest;
      PopulateDividendAndDistribution;
    end;

    cttanInterest : begin
      aAcctHead := 'Interest_Transaction';
      PopulateDistributionAndInterest;
      PopulateDistributionDividendInterest;
    end;

    else
      if ( aAccountCode >= cttanShareTradeRangeStart ) and
            ( aAccountCode <= cttanShareTradeRangeEnd ) then //DN Refactored out, since range was introduced ((AccountCode >= cttanShareTradeRangeStart) and (AccountCode <= cttanShareTradeRangeEnd)) 
      begin
        aAcctHead := 'Share_Trade_Transaction';
        PopulateShareTrade;
      end
      else
      begin
        aAcctHead := 'Other_Transaction';
      end;  
  end;
end;

procedure TSimpleFund360BulkTestCase.Setup;
begin
  fTestTransaction_Rec := trxList32.Create_New_Transaction;
  fFields := TStringList.Create;
end;

function TSimpleFund360BulkTestCase.SetupTransactionRec(
  AccountCode: string): pTransaction_Rec;
begin

end;

procedure TSimpleFund360BulkTestCase.TearDown;
begin
  if assigned( fFields ) then
    freeAndNil( fFields );
  if assigned( fTestTransaction_Rec ) then //NB!! Not an Object
    freeMem( fTestTransaction_Rec );       //NB!! Not an Object
end;


////////////////////////////////////////////////////////////////////////////////
// Support routines                                                           //
////////////////////////////////////////////////////////////////////////////////

procedure TSimpleFund360BulkTestCase.AddDateField(const Name: string; Value: Integer);
begin
   if Value <> 0 then
      fFields.Add(Name + '=' + StDateToDateString('dd/mm/yyyy',Value,False));
end;

procedure TSimpleFund360BulkTestCase.AddField(const Name, Value: string);
begin
   if Value > '' then
      fFields.Add(Name + '=' + Value );
end;

procedure TSimpleFund360BulkTestCase.AddNumberField(const Name: string; Value: Integer);
begin
   fFields.Add(Name + '=' + InttoStr(Value));
end;

procedure TSimpleFund360BulkTestCase.AddMoneyField(const Name: string; Value: Money);
begin
   if (Value=UnKnown)
   or (Value=0) then
   else
      fFields.Add(Name + '=' + Format('%.2f',[Value/100]));
end;

procedure TSimpleFund360BulkTestCase.AddTaxFields(TaxAmount: Money; TaxClass: Integer);
var
  Code, Desc : string;
begin
  AddMoneyField(f_Tax,TaxAmount);
end;

procedure TSimpleFund360BulkTestCase.AddQtyField(const Name: string; Value: Money);
begin
  if Value <> 0 then
      fFields.Add(Name + '=' + Format('%.4f',[Value/10000]));
end;

function TSimpleFund360BulkTestCase.GetFullNotes (pT: pTransaction_Rec): string;
begin
   Result := '';
   if Assigned(pt) then begin
      Result := pt.txECoding_Import_Notes;
      if pt.txNotes > '' then begin
         if Result > '' then
            Result := Result + '; ';
         Result := Result + pt.txNotes;
      end;
   end;
end;

function TSimpleFund360BulkTestCase.LookupChart(const Value: string): string;
begin
   Result := '';
end;

function TSimpleFund360BulkTestCase.LookupJob(const Value: string): string;
begin
   Result := '';
end;


function TSimpleFund360BulkTestCase.TransactionToText(aTrans: pTransaction_Rec): string;
var
  fLineCount    : Integer;
  fTransCount   : Integer;
  fCurrentBal   : Money;

  procedure AddBGL360Fields;
  begin
//  fBGL360_Accrual_Date
    if True then

    AddDateField(fBGL360_Accrual_Date, aTrans^.txTransaction_Extension^.teSF_Accrual_Date);
//  fBGL360_Cash_Date
    AddDateField(fBGL360_Cash_Date, aTrans^.txTransaction_Extension^.teSF_Cash_Date);
//  fBGL360_Record_Date
    AddDateField(fBGL360_Record_Date, aTrans^.txTransaction_Extension^.teSF_Record_Date);

///////////// ***************** Share Trade Tab ***************** ////////////////
//    fBGL360_Units
      AddQtyField(fBGL360_Units {fQuantity}, aTrans^.txQuantity);
//    fBGL360_Contract_Date
      AddDateField(fBGL360_Contract_Date, aTrans^.txTransaction_Extension^.teSF_Contract_Date);
//    fBGL360_Settlement_Date
      AddDateField(fBGL360_Settlement_Date, aTrans^.txTransaction_Extension^.teSF_Settlement_Date);
//    fBGL360_Brokerage
      AddMoneyField( fBGL360_Brokerage,
        abs( aTrans^.txTransaction_Extension^.teSF_Share_Brokerage ) ) ;
//    fBGL360_GST_Rate
      AddNumberField( fBGL360_GST_Rate,
        Abs( StrToIntDef( aTrans^.txTransaction_Extension^.teSF_Share_GST_Rate, 0 ) ) );
//    fBGL360_GST_Amount
      AddMoneyField( fBGL360_GST_Amount,
        Abs( aTrans^.txTransaction_Extension^.teSF_Share_GST_Amount ) );
//    fBGL360_Consideration
      AddMoneyField( fBGL360_Consideration,
        ( aTrans^.txTransaction_Extension^.teSF_Share_Consideration ) );
///////////// ***************** Share Trade Tab ***************** ////////////////

///////////// ***************** Dividend / Distribution Tabs ***************** ////////////////
//    fBGL360_Dividends_Franked
      AddMoneyField( fBGL360_Dividends_Franked,
        abs(aTrans^.txSF_Franked) );
//    fBGL360_Dividends_Unfranked
      AddMoneyField( fBGL360_Dividends_Unfranked,
        abs(aTrans^.txSF_Unfranked) );
//    fBGL360_Franking_Credits
      AddMoneyField( fBGL360_Franking_Credits,
        Abs(aTrans^.txSF_Imputed_Credit) );
///////////// ***************** Dividend / Distribution Tabs ***************** ////////////////

///////////// ***************** Distribution / Interest Tabs ***************** ////////////////
//   fBGL360_Interest
      AddMoneyField( fBGL360_Interest,
        Abs( aTrans^.txSF_Interest) );
//    fBGL360_Other_Income
      AddMoneyField( fBGL360_Other_Income,
        Abs(aTrans^.txTransaction_Extension^.teSF_Other_Income ) );
///////////// ***************** Distribution / Interest Tabs ***************** ////////////////

///////////// ***************** Distribution ***************** ////////////////
//    fBGL360_Less_Other_Allowable_Trust_Deductions
      AddMoneyField( fBGL360_Less_Other_Allowable_Trust_Deductions,
        Abs(aTrans^.txTransaction_Extension^.teSF_Other_Trust_Deductions ) );
//    fBGL360_Discounted_Capital_Gain_Before_Discount
      AddMoneyField( fBGL360_Discounted_Capital_Gain_Before_Discount,
        Abs(aTrans^.txSF_Capital_Gains_Disc) );
//    fBGL360_Capital_Gains_CGT_Concessional_Amount
      AddMoneyField( fBGL360_Capital_Gains_CGT_Concessional_Amount,
        Abs(aTrans^.txTransaction_Extension^.teSF_CGT_Concession_Amount ) );
//    fBGL360_Capital_Gain_Indexation_Method
      AddMoneyField( fBGL360_Capital_Gain_Indexation_Method,
        Abs( aTrans^.txSF_Capital_Gains_Indexed) );
//    fBGL360_Capital_Gain_Other_Method
      AddMoneyField( fBGL360_Capital_Gain_Other_Method,
        Abs( aTrans^.txSF_Capital_Gains_Other) );
//    fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount
      AddMoneyField( fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Before_Disc ) );
//    fBGL360_Foreign_Capital_Gains_Indexation_Method
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Indexation_Method,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Indexation ) );
//    fBGL360_Foreign_Capital_Gains_Other_Method
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Other_Method,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_ForeignCGT_Other_Method ) );
//    fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid,
        Abs( aTrans^.txSF_Capital_Gains_Foreign_Disc ) );
//    fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_TaxPaid_Indexation ) );
//    fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid
      AddMoneyField( fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid,
        Abs( aTrans^.txTransaction_Extension^.teSF_CGT_TaxPaid_Other_Method ) );
///////////// ***************** Distribution ***************** ////////////////

///////////// ***************** Distribution / Dividend ***************** ////////////////
//    fBGL360_Assessable_Foreign_Source_Income
      AddMoneyField( fBGL360_Assessable_Foreign_Source_Income,
        Abs( aTrans^.txSF_Foreign_Income ) );
//    fBGL360_Foreign_Income_Tax_Paid_Offset_Credits
      AddMoneyField( fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
        Abs( aTrans^.txSF_Foreign_Tax_Credits ) );
//    fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company
      AddMoneyField( fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
        Abs( aTrans^.txTransaction_Extension^.teSF_AU_Franking_Credits_NZ_Co ) );
///////////// ***************** Distribution / Dividend ***************** ////////////////

///////////// ***************** Distribution ***************** ////////////////
//    fBGL360_Other_Net_Foreign_Source_Income
      AddMoneyField( fBGL360_Other_Net_Foreign_Source_Income,
        Abs( aTrans^.txTransaction_Extension^.teSF_Other_Net_Foreign_Income ) );
//    fBGL360_Cash_Distribution
      AddMoneyField( fBGL360_Cash_Distribution,
        Abs( aTrans^.txTransaction_Extension^.teSF_Cash_Distribution ) );
//    fBGL360_Tax_Exempted_Amounts
      AddMoneyField( fBGL360_Tax_Exempted_Amounts,
        Abs( aTrans^.txSF_Tax_Exempt_Dist ) );
//    fBGL360_Tax_Free_Amounts
      AddMoneyField( fBGL360_Tax_Free_Amounts,
        Abs( aTrans^.txSF_Tax_Free_Dist ) );
//    fBGL360_Tax_Deferred_amounts
      AddMoneyField( fBGL360_Tax_Deferred_amounts,
        Abs( aTrans^.txSF_Tax_Deferred_Dist ) );
///////////// ***************** Distribution ***************** ////////////////

///////////// ***************** Distribution / Dividend  / Interest tabs ***************** ////////////////
//    fBGL360_TFN_Amounts_withheld
      AddMoneyField( fBGL360_TFN_Amounts_withheld,
        Abs( aTrans^.txSF_TFN_Credits ) );
//    fBGL360_Non_Resident_Withholding_Tax
      AddMoneyField( fBGL360_Non_Resident_Withholding_Tax,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Res_Witholding_Tax ) );
///////////// ***************** Distribution / Dividend  / Interest tabs ***************** ////////////////

///////////// ***************** Distribution Tab ***************** ////////////////
//    fBGL360_Other_Expenses
      AddMoneyField( fBGL360_Other_Expenses,
        Abs( aTrans^.txSF_Other_Expenses ) );
//    fBGL360_Other_Net_Foreign_Source_Income
      AddMoneyField( fBGL360_Other_Net_Foreign_Source_Income,
        Abs( aTrans^.txTransaction_Extension^.teSF_Other_Net_Foreign_Income ) );
//    fBGL360_Cash_Distribution
      AddMoneyField( fBGL360_Cash_Distribution,
        Abs( aTrans^.txTransaction_Extension^.teSF_Cash_Distribution ) );
//    fBGL360_Tax_Exempted_Amounts
      AddMoneyField( fBGL360_Tax_Exempted_Amounts,
      Abs( aTrans^.txSF_Tax_Exempt_Dist ) );
//    fBGL360_Tax_Free_Amounts
      AddMoneyField( fBGL360_Tax_Free_Amounts,
      Abs( aTrans^.txSF_Tax_Free_Dist ) );
//    fBGL360_Tax_Deferred_amounts
      AddMoneyField( fBGL360_Tax_Deferred_amounts,
      Abs( aTrans^.txSF_Tax_Deferred_Dist ) );
//    fBGL360_TFN_Amounts_withheld
      AddMoneyField( fBGL360_TFN_Amounts_withheld,
      Abs( aTrans^.txSF_TFN_Credits ) );
//    fBGL360_Non_Resident_Withholding_Tax
      AddMoneyField( fBGL360_Non_Resident_Withholding_Tax,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Res_Witholding_Tax ) );
//    fBGL360_Other_Expenses
      AddMoneyField( fBGL360_Other_Expenses,
      Abs( aTrans^.txSF_Other_Expenses ) );
///////////// ***************** Distribution Tab ***************** ////////////////

///////////// ***************** Distribution / Dividend Tabs ***************** ////////////////
//    fBGL360_LIC_Deduction
      AddMoneyField( fBGL360_LIC_Deductions,
        Abs( aTrans^.txTransaction_Extension^.teSF_LIC_Deductions ) );
///////////// ***************** Distribution / Dividend Tabs ***************** ////////////////

///////////// ***************** Distribution Tab ***************** ////////////////
//    fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash
      AddMoneyField( fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Cash_CGT_Discounted_Before_Discount ) );
//    fBGL360_Capital_Gains_Indexation_Method_Non_Cash
      AddMoneyField( fBGL360_Capital_Gains_Indexation_Method_Non_Cash,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Cash_CGT_Indexation ) );
//    fBGL360_Capital_Gains_Other_Method_Non_Cash
      AddMoneyField( fBGL360_Capital_Gains_Other_Method_Non_Cash,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Cash_CGT_Other_Method ) );
//    fBGL360_Capital_Losses_Non_Cash
      AddMoneyField( fBGL360_Capital_Losses_Non_Cash,
        Abs( aTrans^.txTransaction_Extension^.teSF_Non_Cash_CGT_Capital_Losses ) );
///////////// ***************** Distribution Tab ***************** ////////////////
  end;
begin
   fFields.Clear;
   AddNumberField(f_Line, fLineCount);
   AddNumberField(f_Trans, fTransCount);

   // Any other IDs
   AddField(f_TransID,aTrans.txExternal_GUID);

   AddDateField(f_Date,aTrans.txDate_Effective);
   AddMoneyField(f_Amount,aTrans.txAmount);

   AddTaxFields(aTrans.txGST_Amount, aTrans.txGST_Class);

   AddQtyField(f_Quantity, aTrans.txQuantity);
   AddNumberField(f_TransType, aTrans.txType);

   // Narratives
   if Atrans.txCheque_Number <> 0 then
      AddNumberField(f_ChequeNo, Atrans.txCheque_Number);

   AddField(f_Reference,   aTrans.txReference);
   AddField(f_Analysis,    aTrans.txAnalysis);
   AddField(f_OtherParty,  aTrans.txOther_Party);
   AddField(f_Particulars, aTrans.txParticulars);
   AddField(f_Narration,   aTrans.txGL_Narration);
   AddField(f_Notes,       GetFullNotes(aTrans));

   AddField(f_ExtractNumberAs, 'WBM037148807694');

   // Coding
   AddField(f_Code,aTrans.txAccount);
   AddField(f_Desc,LookupChart(aTrans.txAccount));
   // Job
   AddField(f_JobCode, aTrans.txJob_Code);
   AddField(f_JobDesc, lookupJob(aTrans.txJob_Code));

   // Superfund...
   // Common Fields (Typically Money)
   AddDateField(f_CGTDate,aTrans.txSF_CGT_Date);

   AddMoneyField(f_Franked,aTrans.txSF_Franked);
   AddMoneyField(f_UnFranked,aTrans.txSF_UnFranked);

   AddMoneyField(f_Imp_Credit,aTrans.txSF_Imputed_Credit);
   AddMoneyField(f_TFN_Credit,aTrans.txSF_TFN_Credits);
   AddMoneyField(f_Frn_Credit,aTrans.txSF_Foreign_Tax_Credits);

   AddMoneyField(f_TF_Dist,aTrans.txSF_Tax_Free_Dist);
   AddMoneyField(f_TE_Dist,aTrans.txSF_Tax_Exempt_Dist);
   AddMoneyField(f_TD_Dist,aTrans.txSF_Tax_Deferred_Dist);

   AddMoneyField(f_CGI,aTrans.txSF_Capital_Gains_Indexed);
   AddMoneyField(f_CGD,aTrans.txSF_Capital_Gains_Disc);
   AddMoneyField(f_CGO,aTrans.txSF_Capital_Gains_Other);

   AddMoneyField(f_Frn_Income,aTrans.txSF_Foreign_Income);
   AddMoneyField(f_CGO,aTrans.txSF_Capital_Gains_Other);

   AddMoneyField(f_OExpences,aTrans.txSF_Other_Expenses);
   AddMoneyField(f_Interest, aTrans.txSF_Interest);
   AddMoneyField(f_ForeignCG, aTrans.txSF_Capital_Gains_Other);
   AddMoneyField(f_ForeignDiscCG, aTrans.txSF_Capital_Gains_Foreign_Disc);
   AddMoneyField(f_Rent, aTrans.txSF_Rent);
   AddMoneyField(f_SpecialIncome, aTrans.txSF_Special_Income);
   AddMoneyField(f_ForeignCGCredit, aTrans.txSF_Foreign_Capital_Gains_Credit);
   AddMoneyField(f_OT_Credit, aTrans.txSF_Other_Tax_Credit);
   AddMoneyField(f_NonResidentTax, aTrans.txSF_Non_Resident_Tax);

   AddBGL360Fields;


   // Running balance
   if FCurrentBal <> Unknown then
      AddMoneyField(f_Balance,FCurrentBal);
   Result := fFields.DelimitedText;
end;

const
  c_Amount                    = 'Amount';
  c_Amount_Value              = '120.00';

  c_Account_Code              = 'Account_Code';
  c_Distribution_Account_Code = '23800/ASX.DST';
  c_Dividend_Account_Code     = '23900/ASX.DIV';
  c_Interest_Account_Code     = '25000/ASX.INT';
  c_Other_Account_Code        = '20000/GPT.AX';
  c_Share_Account_Code        = '78200/GPT.AX';


procedure TSimpleFund360BulkTestCase.CheckGeneric( asEntry_Type_Detail : string );
begin
  TransactionsNode    := TestNode;
  CurrentTransaction  := TestNode.FirstChild;
  ContraEntries       := CurrentTransaction.ChildNodes.Item[7];
  Entry               := ContraEntries.FirstChild;
  EntryType           := Entry.FirstChild;
  EntryTypeDetail     := Entry.ChildNodes.Item[ 1];
  TransactionTypeNode := EntryTypeDetail.FirstChild;

  Check(TestNode.NodeName                                 = 'Transactions' , Format('Expected node "%s", but found node "%s"', [ 'Transactions' , TestNode.NodeName ]) );
  Check(TestNode.FirstChild.NodeName                      = 'Transaction',   Format('Expected node "%s", but found node "%s"', [ 'Transaction', TestNode.FirstChild.NodeName ]) );

  Check(CurrentTransaction.FirstChild.NodeName            = 'Transaction_Type', Format('Expected node "%s", but found node "%s"', [ 'Transaction_Type', TestNode.FirstChild.NodeName ]) );
  Check(CurrentTransaction.FirstChild.Text                = 'Bank_Transaction', Format('Expected node "%s", but found node "%s"', [ 'Bank_Transaction', TestNode.FirstChild.Text ]) );

  Check(CurrentTransaction.ChildNodes.Item[1].NodeName    = 'Unique_Reference', Format('Expected node "%s", but found node "%s"', [ 'Unique_Reference', CurrentTransaction.ChildNodes.Item[1].NodeName ]) );
  Check(CurrentTransaction.ChildNodes.Item[1].Text        = '     0987654321',  Format('Expected node "%s", but found node "%s"', [ '     0987654321', CurrentTransaction.ChildNodes.Item[1].Text ]) );

  Check(CurrentTransaction.ChildNodes.Item[2].NodeName    = 'BSB', Format('Expected node "%s", but found node "%s"', [ 'BSB', CurrentTransaction.ChildNodes.Item[2].NodeName ]) );
  Check(Trim(CurrentTransaction.ChildNodes.Item[2].Text)  = 'WBM037', Format('Expected node "%s", but found node "%s"', [ 'WBM037', Trim(CurrentTransaction.ChildNodes.Item[2].Text) ]) );

  Check(CurrentTransaction.ChildNodes.Item[3].NodeName    = 'Bank_Account_No', Format('Expected node "%s", but found node "%s"', [ 'Bank_Account_No', CurrentTransaction.ChildNodes.Item[3].NodeName ]) );
  Check(CurrentTransaction.ChildNodes.Item[3].Text        = '148807694', Format('Expected node "%s", but found node "%s"', [  '148807694', CurrentTransaction.ChildNodes.Item[3].Text ]) );

  Check(CurrentTransaction.ChildNodes.Item[4].NodeName    = 'Transaction_Date', Format('Expected node "%s", but found node "%s"', [ 'Transaction_Date', CurrentTransaction.ChildNodes.Item[2].NodeName ]) );
  Check(Trim(CurrentTransaction.ChildNodes.Item[4].Text)  = '02/04/2004', Format('Expected node "%s", but found node "%s"', [ '02/04/2004', Trim(CurrentTransaction.ChildNodes.Item[2].Text) ]) );

  Check(CurrentTransaction.ChildNodes.Item[5].NodeName    = 'Text', Format('Expected node "%s", but found node "%s"', [ 'Text', CurrentTransaction.ChildNodes.Item[3].NodeName ]) );
  Check(CurrentTransaction.ChildNodes.Item[5].Text        = 'Account 1 Tran1', Format('Expected node "%s", but found node "%s"', [  'Account 1 Tran1', CurrentTransaction.ChildNodes.Item[3].Text ]) );

  Check(CurrentTransaction.ChildNodes.Item[6].NodeName    = c_Amount, Format('Expected node "%s", but found node "%s"', [ 'Amount', CurrentTransaction.ChildNodes.Item[4].NodeName ]) );
  Check(CurrentTransaction.ChildNodes.Item[6].Text        = '-' + c_Amount_Value, Format('Expected node "%s", but found node "%s"', [ '-' + c_Amount_Value, CurrentTransaction.ChildNodes.Item[4].Text]) );

  Check(ContraEntries.NodeName                            = 'Contra_Entries', Format('Expected node "%s", but found node "%s"', [ 'Contra_Entries', ContraEntries.NodeName ]) );
  Check(Entry.NodeName                                    = 'Entry', Format('Expected node "%s", but found node "%s"', [ 'Entry', Entry.NodeName ]) );

  Check(EntryType.NodeName                                = 'Entry_Type', Format('Expected node "%s", but found node "%s"', [ 'Entry_Type', Entry.ChildNodes.Item[0].NodeName ]) );
  Check(EntryType.Text                                    = asEntry_Type_Detail, Format('Expected node "%s", but found node "%s"', [ asEntry_Type_Detail, Entry.ChildNodes.Item[0].NodeName ]) );

  Check(EntryTypeDetail.NodeName                          = 'Entry_Type_Detail', Format('Expected node "%s", but found node "%s"', [ 'Entry_Type_Detail', EntryTypeDetail.NodeName ]) );
  Check(TransactionTypeNode.NodeName                      = asEntry_Type_Detail, Format('Expected node "%s", but found node "%s"', [ asEntry_Type_Detail, TransactionTypeNode.NodeName ]) );
end;

procedure TSimpleFund360BulkTestCase.CheckBGL360( aiAccount : integer );
begin
  case aiAccount of
    cttanDistribution : begin
      Check(TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName = c_Account_Code,
        Format('Expected node "%s", but found node "%s"', [ c_Account_Code,
          TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 0 ].Text = c_Distribution_Account_Code,
        Format('Expected node "%s", but found node "%s"', [ c_Distribution_Account_Code,
          TransactionTypeNode.ChildNodes.Item[ 0 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName = c_Amount,
        Format('Expected node "%s", but found node "%s"', [ c_Amount,
          TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 1 ].Text = c_Amount_Value,
        Format('Expected node "%s", but found node "%s"', [ c_Amount_Value,
          TransactionTypeNode.ChildNodes.Item[ 1 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 2 ].NodeName = fBGL360_Dividends_Franked,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Dividends_Franked,
          TransactionTypeNode.ChildNodes.Item[ 2 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 2 ].Text = '90.00',
        Format('Expected node "%s", but found node "%s"', [ '90.00',
          TransactionTypeNode.ChildNodes.Item[ 2 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 3 ].NodeName = fBGL360_Dividends_Unfranked,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Dividends_Unfranked,
          TransactionTypeNode.ChildNodes.Item[ 3 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 3 ].Text = '30.00',
        Format('Expected node "%s", but found node "%s"', [ '30.00',
          TransactionTypeNode.ChildNodes.Item[ 3 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 4 ].NodeName = fBGL360_Franking_Credits,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Franking_Credits,
          TransactionTypeNode.ChildNodes.Item[ 4 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 4 ].Text = '5.00',
        Format('Expected node "%s", but found node "%s"', [ '5.00',
          TransactionTypeNode.ChildNodes.Item[ 4 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 5 ].NodeName = fBGL360_Interest,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Interest,
          TransactionTypeNode.ChildNodes.Item[ 5 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 5 ].Text = '1.00',
        Format('Expected node "%s", but found node "%s"', [ '1.00',
          TransactionTypeNode.ChildNodes.Item[ 5 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 6 ].NodeName = fBGL360_Other_Income,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Other_Income,
          TransactionTypeNode.ChildNodes.Item[ 6 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 6 ].Text = '2.00',
        Format('Expected node "%s", but found node "%s"', [ '2.00',
          TransactionTypeNode.ChildNodes.Item[ 6 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 7 ].NodeName = fBGL360_Less_Other_Allowable_Trust_Deductions,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Less_Other_Allowable_Trust_Deductions,
          TransactionTypeNode.ChildNodes.Item[ 7 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 7 ].Text = '3.00',
        Format('Expected node "%s", but found node "%s"', [ '3.00',
          TransactionTypeNode.ChildNodes.Item[ 7 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 8 ].NodeName = fBGL360_Capital_Gains_CGT_Concessional_Amount,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Capital_Gains_CGT_Concessional_Amount,
          TransactionTypeNode.ChildNodes.Item[ 8 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 8 ].Text = '4.00',
        Format('Expected node "%s", but found node "%s"', [ '4.00',
          TransactionTypeNode.ChildNodes.Item[ 8 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 9 ].NodeName = fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount,
          TransactionTypeNode.ChildNodes.Item[ 9 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 9 ].Text = '5.00',
        Format('Expected node "%s", but found node "%s"', [ '5.00',
          TransactionTypeNode.ChildNodes.Item[ 9 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 10 ].NodeName = fBGL360_Foreign_Capital_Gains_Indexation_Method,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Foreign_Capital_Gains_Indexation_Method,
          TransactionTypeNode.ChildNodes.Item[ 10 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 10 ].Text = '6.00',
        Format('Expected node "%s", but found node "%s"', [ '6.00',
          TransactionTypeNode.ChildNodes.Item[ 10 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 11 ].NodeName = fBGL360_Foreign_Capital_Gains_Other_Method,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Foreign_Capital_Gains_Other_Method,
          TransactionTypeNode.ChildNodes.Item[ 11 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 11 ].Text = '7.00',
        Format('Expected node "%s", but found node "%s"', [ '7.00',
          TransactionTypeNode.ChildNodes.Item[ 11].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 12 ].NodeName = fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Foreign_Discounted_Capital_Gains_Before_Discount_Tax_Paid,
          TransactionTypeNode.ChildNodes.Item[ 12 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 12 ].Text = '8.00',
        Format('Expected node "%s", but found node "%s"', [ '8.00',
          TransactionTypeNode.ChildNodes.Item[ 12 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 13 ].NodeName = fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Foreign_Capital_Gains_Indexation_Method_Tax_Paid,
          TransactionTypeNode.ChildNodes.Item[ 13 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 13 ].Text = '9.00',
        Format('Expected node "%s", but found node "%s"', [ '9.00',
          TransactionTypeNode.ChildNodes.Item[ 13 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 14 ].NodeName = fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Foreign_Capital_Gains_Other_Method_Tax_Paid,
          TransactionTypeNode.ChildNodes.Item[ 14 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 14 ].Text = '10.00',
        Format('Expected node "%s", but found node "%s"', [ '10.00',
          TransactionTypeNode.ChildNodes.Item[ 14 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 15 ].NodeName = fBGL360_Assessable_Foreign_Source_Income,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Assessable_Foreign_Source_Income,
          TransactionTypeNode.ChildNodes.Item[ 15 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 15 ].Text = '11.00',
        Format('Expected node "%s", but found node "%s"', [ '11.00',
          TransactionTypeNode.ChildNodes.Item[ 15 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 16 ].NodeName = fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
          TransactionTypeNode.ChildNodes.Item[ 16 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 16 ].Text = '12.00',
        Format('Expected node "%s", but found node "%s"', [ '12.00',
          TransactionTypeNode.ChildNodes.Item[ 16 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 17 ].NodeName = fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
          TransactionTypeNode.ChildNodes.Item[ 17 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 17 ].Text = '13.00',
        Format('Expected node "%s", but found node "%s"', [ '13.00',
          TransactionTypeNode.ChildNodes.Item[ 17 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 18 ].NodeName = fBGL360_Other_Net_Foreign_Source_Income,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Other_Net_Foreign_Source_Income,
          TransactionTypeNode.ChildNodes.Item[ 18 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 18 ].Text = '22.00',
        Format('Expected node "%s", but found node "%s"', [ '22.00',
          TransactionTypeNode.ChildNodes.Item[ 18 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 19 ].NodeName = fBGL360_Cash_Distribution,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Cash_Distribution,
          TransactionTypeNode.ChildNodes.Item[ 19 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 19 ].Text = '23.00',
        Format('Expected node "%s", but found node "%s"', [ '23.00',
          TransactionTypeNode.ChildNodes.Item[ 19 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 20 ].NodeName = fBGL360_Tax_Exempted_Amounts,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Tax_Exempted_Amounts,
          TransactionTypeNode.ChildNodes.Item[ 20 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 20 ].Text = '24.00',
        Format('Expected node "%s", but found node "%s"', [ '24.00',
          TransactionTypeNode.ChildNodes.Item[ 20 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 21 ].NodeName = fBGL360_Tax_Free_Amounts,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Tax_Free_Amounts,
          TransactionTypeNode.ChildNodes.Item[ 21 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 21 ].Text = '25.00',
        Format('Expected node "%s", but found node "%s"', [ '25.00',
          TransactionTypeNode.ChildNodes.Item[ 21 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 22 ].NodeName = fBGL360_Tax_Deferred_amounts,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Tax_Deferred_amounts,
          TransactionTypeNode.ChildNodes.Item[ 22 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 22 ].Text = '26.00',
        Format('Expected node "%s", but found node "%s"', [ '26.00',
          TransactionTypeNode.ChildNodes.Item[ 22 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 23 ].NodeName = fBGL360_TFN_Amounts_withheld,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_TFN_Amounts_withheld,
          TransactionTypeNode.ChildNodes.Item[ 23 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 23 ].Text = '27.00',
        Format('Expected node "%s", but found node "%s"', [ '27.00',
          TransactionTypeNode.ChildNodes.Item[ 23 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 24 ].NodeName = fBGL360_Non_Resident_Withholding_Tax,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Non_Resident_Withholding_Tax,
          TransactionTypeNode.ChildNodes.Item[ 24 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 24 ].Text = '28.00',
        Format('Expected node "%s", but found node "%s"', [ '28.00',
          TransactionTypeNode.ChildNodes.Item[ 24 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 25 ].NodeName = fBGL360_Other_Expenses,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Other_Expenses,
          TransactionTypeNode.ChildNodes.Item[ 25 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 25 ].Text = '29.00',
        Format('Expected node "%s", but found node "%s"', [ '29.00',
          TransactionTypeNode.ChildNodes.Item[ 25 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 26 ].NodeName = fBGL360_LIC_Deductions,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_LIC_Deductions,
          TransactionTypeNode.ChildNodes.Item[ 26 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 26 ].Text = '30.00',
        Format('Expected node "%s", but found node "%s"', [ '30.00',
          TransactionTypeNode.ChildNodes.Item[ 26 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 27 ].NodeName = fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Discounted_Capital_Gain_Before_Discount_Non_Cash,
          TransactionTypeNode.ChildNodes.Item[ 27 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 27 ].Text = '31.00',
        Format('Expected node "%s", but found node "%s"', [ '31.00',
          TransactionTypeNode.ChildNodes.Item[ 27 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 28 ].NodeName = fBGL360_Capital_Gains_Indexation_Method_Non_Cash,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Capital_Gains_Indexation_Method_Non_Cash,
          TransactionTypeNode.ChildNodes.Item[ 28 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 28 ].Text = '32.00',
        Format('Expected node "%s", but found node "%s"', [ '32.00',
          TransactionTypeNode.ChildNodes.Item[ 28 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 29 ].NodeName = fBGL360_Capital_Gains_Other_Method_Non_Cash,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Capital_Gains_Other_Method_Non_Cash,
          TransactionTypeNode.ChildNodes.Item[ 29 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 29 ].Text = '33.00',
        Format('Expected node "%s", but found node "%s"', [ '33.00',
          TransactionTypeNode.ChildNodes.Item[ 29 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 30 ].NodeName = fBGL360_Capital_Losses_Non_Cash,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Capital_Losses_Non_Cash,
          TransactionTypeNode.ChildNodes.Item[ 30 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 30 ].Text = '34.00',
        Format('Expected node "%s", but found node "%s"', [ '34.00',
          TransactionTypeNode.ChildNodes.Item[ 30 ].Text ]) );

    end;
    cttanDividend : begin
      Check(TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName = c_Account_Code,
        Format('Expected node "%s", but found node "%s"', [ c_Account_Code,
          TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 0 ].Text = c_Dividend_Account_Code,
        Format('Expected node "%s", but found node "%s"', [ c_Dividend_Account_Code,
          TransactionTypeNode.ChildNodes.Item[ 0 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName = c_Amount,
        Format('Expected node "%s", but found node "%s"', [ c_Amount,
          TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 1 ].Text = c_Amount_Value,
        Format('Expected node "%s", but found node "%s"', [ c_Amount_Value,
          TransactionTypeNode.ChildNodes.Item[ 1 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 2 ].NodeName = fBGL360_Dividends_Franked,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Dividends_Franked,
          TransactionTypeNode.ChildNodes.Item[ 2 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 2 ].Text = '90.00',
        Format('Expected node "%s", but found node "%s"', [ '90.00',
          TransactionTypeNode.ChildNodes.Item[ 2 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 3 ].NodeName = fBGL360_Dividends_Unfranked,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Dividends_Unfranked,
          TransactionTypeNode.ChildNodes.Item[ 3 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 3 ].Text = '30.00',
        Format('Expected node "%s", but found node "%s"', [ '30.00',
          TransactionTypeNode.ChildNodes.Item[ 3 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 4 ].NodeName = fBGL360_Franking_Credits,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Franking_Credits,
          TransactionTypeNode.ChildNodes.Item[ 4 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 4 ].Text = '5.00',
        Format('Expected node "%s", but found node "%s"', [ '5.00',
          TransactionTypeNode.ChildNodes.Item[ 4 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 5 ].NodeName = fBGL360_Assessable_Foreign_Source_Income,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Assessable_Foreign_Source_Income,
          TransactionTypeNode.ChildNodes.Item[ 5 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 5 ].Text = '11.00',
        Format('Expected node "%s", but found node "%s"', [ '11.00',
          TransactionTypeNode.ChildNodes.Item[ 5 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 6 ].NodeName = fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Foreign_Income_Tax_Paid_Offset_Credits,
          TransactionTypeNode.ChildNodes.Item[ 6 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 6 ].Text = '12.00',
        Format('Expected node "%s", but found node "%s"', [ '12.00',
          TransactionTypeNode.ChildNodes.Item[ 6 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 7 ].NodeName = fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Australian_Franking_Credits_from_a_New_Zealand_Company,
          TransactionTypeNode.ChildNodes.Item[ 7 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 7 ].Text = '13.00',
        Format('Expected node "%s", but found node "%s"', [ '13.00',
          TransactionTypeNode.ChildNodes.Item[ 7 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 8 ].NodeName = fBGL360_TFN_Amounts_withheld,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_TFN_Amounts_withheld,
          TransactionTypeNode.ChildNodes.Item[ 8 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 8 ].Text = '19.00',
        Format('Expected node "%s", but found node "%s"', [ '19.00',
          TransactionTypeNode.ChildNodes.Item[ 8 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 9 ].NodeName = fBGL360_Non_Resident_Withholding_Tax,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Non_Resident_Withholding_Tax,
          TransactionTypeNode.ChildNodes.Item[ 9 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 9 ].Text = '20.00',
        Format('Expected node "%s", but found node "%s"', [ '20.00',
          TransactionTypeNode.ChildNodes.Item[ 9 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 10 ].NodeName = fBGL360_LIC_Deductions,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_LIC_Deductions,
          TransactionTypeNode.ChildNodes.Item[ 10 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 10 ].Text = '30.00',
        Format('Expected node "%s", but found node "%s"', [ '30.00',
          TransactionTypeNode.ChildNodes.Item[ 10 ].Text ]) );

    end;
    cttanInterest : begin
      Check(TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName = c_Account_Code,
        Format('Expected node "%s", but found node "%s"', [ c_Account_Code,
          TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 0 ].Text = c_Interest_Account_Code,
        Format('Expected node "%s", but found node "%s"', [ c_Interest_Account_Code,
          TransactionTypeNode.ChildNodes.Item[ 0 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName = c_Amount,
        Format('Expected node "%s", but found node "%s"', [ c_Amount,
          TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 1 ].Text = c_Amount_Value,
        Format('Expected node "%s", but found node "%s"', [ c_Amount_Value,
          TransactionTypeNode.ChildNodes.Item[ 1 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 2 ].NodeName = fBGL360_Interest,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Interest,
          TransactionTypeNode.ChildNodes.Item[ 2 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 2 ].Text = '1.00',
        Format('Expected node "%s", but found node "%s"', [ '1.00',
          TransactionTypeNode.ChildNodes.Item[ 2 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 3 ].NodeName = fBGL360_Other_Income,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Other_Income,
          TransactionTypeNode.ChildNodes.Item[ 3 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 3 ].Text = '2.00',
        Format('Expected node "%s", but found node "%s"', [ '2.00',
          TransactionTypeNode.ChildNodes.Item[ 3 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 4 ].NodeName = fBGL360_TFN_Amounts_withheld,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_TFN_Amounts_withheld,
          TransactionTypeNode.ChildNodes.Item[ 4 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 4 ].Text = '19.00',
        Format('Expected node "%s", but found node "%s"', [ '19.00',
          TransactionTypeNode.ChildNodes.Item[ 4 ].Text ]) );

      Check(TransactionTypeNode.ChildNodes.Item[ 5 ].NodeName = fBGL360_Non_Resident_Withholding_Tax,
        Format('Expected node "%s", but found node "%s"', [ fBGL360_Non_Resident_Withholding_Tax,
          TransactionTypeNode.ChildNodes.Item[ 5 ].NodeName ]) );
      Check(TransactionTypeNode.ChildNodes.Item[ 5 ].Text = '20.00',
        Format('Expected node "%s", but found node "%s"', [ '20.00',
          TransactionTypeNode.ChildNodes.Item[ 5 ].Text ]) );

    end;
    else begin
      if ( ( aiAccount >= cttanShareTradeRangeStart ) and
            ( aiAccount <= cttanShareTradeRangeEnd ) ) then begin //DN Refactored out, since range was introduced ((AccountCode >= cttanShareTradeRangeStart) and (AccountCode <= cttanShareTradeRangeEnd)) then
        Check(TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName = c_Account_Code,
          Format('Expected node "%s", but found node "%s"', [ c_Account_Code,
            TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 0 ].Text = c_Share_Account_Code,
          Format('Expected node "%s", but found node "%s"', [ c_Share_Account_Code,
            TransactionTypeNode.ChildNodes.Item[ 0 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName = c_Amount,
          Format('Expected node "%s", but found node "%s"', [ c_Amount,
            TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 1 ].Text = c_Amount_Value,
          Format('Expected node "%s", but found node "%s"', [ c_Amount_Value,
            TransactionTypeNode.ChildNodes.Item[ 1 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 2 ].NodeName = fBGL360_Units,
          Format('Expected node "%s", but found node "%s"', [ fBGL360_Units,
            TransactionTypeNode.ChildNodes.Item[ 2 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 2 ].Text = '0.0005',
          Format('Expected node "%s", but found node "%s"', [ '0.0005',
            TransactionTypeNode.ChildNodes.Item[ 2 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 3 ].NodeName = fBGL360_Contract_Date,
          Format('Expected node "%s", but found node "%s"', [ fBGL360_Contract_Date,
            TransactionTypeNode.ChildNodes.Item[ 3 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 3 ].Text = '03/04/2004',
          Format('Expected node "%s", but found node "%s"', [ '03/04/2004',
            TransactionTypeNode.ChildNodes.Item[ 3 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 4 ].NodeName = fBGL360_Settlement_Date,
          Format('Expected node "%s", but found node "%s"', [ fBGL360_Settlement_Date,
            TransactionTypeNode.ChildNodes.Item[ 4 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 4 ].Text = '04/04/2004',
          Format('Expected node "%s", but found node "%s"', [ '04/04/2004',
            TransactionTypeNode.ChildNodes.Item[ 4 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 5 ].NodeName = fBGL360_Brokerage,
          Format('Expected node "%s", but found node "%s"', [ fBGL360_Brokerage,
            TransactionTypeNode.ChildNodes.Item[ 5 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 5 ].Text = '0.10',
          Format('Expected node "%s", but found node "%s"', [ '0.10',
            TransactionTypeNode.ChildNodes.Item[ 5 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 6 ].NodeName = fBGL360_GST_Rate,
          Format('Expected node "%s", but found node "%s"', [ fBGL360_GST_Rate,
            TransactionTypeNode.ChildNodes.Item[ 6 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 6 ].Text = '75',
          Format('Expected node "%s", but found node "%s"', [ '75',
            TransactionTypeNode.ChildNodes.Item[ 6 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 7 ].NodeName = fBGL360_GST_Amount,
          Format('Expected node "%s", but found node "%s"', [ fBGL360_GST_Amount,
            TransactionTypeNode.ChildNodes.Item[ 7 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 7 ].Text = '13.33',
          Format('Expected node "%s", but found node "%s"', [ '13.33',
            TransactionTypeNode.ChildNodes.Item[ 7 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 8 ].NodeName = fBGL360_Consideration,
          Format('Expected node "%s", but found node "%s"', [ fBGL360_Consideration,
            TransactionTypeNode.ChildNodes.Item[ 8 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 8 ].Text = '12.34',
          Format('Expected node "%s", but found node "%s"', [ '12.34',
            TransactionTypeNode.ChildNodes.Item[ 8 ].Text ]) );
      end
      else begin // Then it must be an Other_Transaction
        Check(TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName = c_Account_Code,
          Format('Expected node "%s", but found node "%s"', [ c_Account_Code,
            TransactionTypeNode.ChildNodes.Item[ 0 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 0 ].Text = c_Other_Account_Code,
          Format('Expected node "%s", but found node "%s"', [ c_Other_Account_Code,
            TransactionTypeNode.ChildNodes.Item[ 0 ].Text ]) );

        Check(TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName = c_Amount,
          Format('Expected node "%s", but found node "%s"', [ c_Amount,
            TransactionTypeNode.ChildNodes.Item[ 1 ].NodeName ]) );
        Check(TransactionTypeNode.ChildNodes.Item[ 1 ].Text = c_Amount_Value,
          Format('Expected node "%s", but found node "%s"', [ c_Amount_Value,
            TransactionTypeNode.ChildNodes.Item[ 1 ].Text ]) );
      end;
    end;
  end;
end;

procedure TSimpleFund360BulkTestCase.RunTestForAccountNumber( asAccountNumber : string );
var
  Session       : TExtractSession;

  TransText     : string;
  iAccount      : integer;
  sEntry_Type_Detail      : string;

begin
  iAccount           := 0;
  sEntry_Type_Detail := '';
  PopulateTransactionRec( asAccountNumber, fTestTransaction_Rec, iAccount, sEntry_Type_Detail );
  TransText := TransactionToText(fTestTransaction_Rec);
  Session.Data := PAnsiChar(AnsiString(TransText));

  try
    StartFile;
    ClientStart(Session);
    Session.ExtractFunction := ef_SessionStart;
    WriteBGLFields(Session, TestNode, True);

    CheckGeneric( sEntry_Type_Detail );

    CheckBGL360( iAccount );
  finally
    TestNode := nil
  end;
end;

procedure TSimpleFund360BulkTestCase.TestExtractBGL360_Distribution;
begin
  RunTestForAccountNumber( c_Distribution_Account_Code );
end;

procedure TSimpleFund360BulkTestCase.TestExtractBGL360_Dividend;
begin
  RunTestForAccountNumber( c_Dividend_Account_Code );

end;

procedure TSimpleFund360BulkTestCase.TestExtractBGL360_Interest;
begin
  RunTestForAccountNumber( c_Interest_Account_Code );

end;

procedure TSimpleFund360BulkTestCase.TestExtractBGL360_OtherTransaction;
begin
  RunTestForAccountNumber( c_Other_Account_Code );
end;

procedure TSimpleFund360BulkTestCase.TestExtractBGL360_ShareTrade;
begin
  RunTestForAccountNumber( c_Share_Account_Code );

end;

initialization
  TestFramework.RegisterTest(TSimpleFund360BulkTestCase.Suite);

end.
