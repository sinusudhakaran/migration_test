unit utSimpleFund360Bulk;
{$TYPEINFO ON} //Needed for classes with published methods

interface

uses
  bkConst,
  bkDefs,
  Classes,
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
    function CreateTransactionRec : pTransaction_Rec;
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure TestExtractBGL360;
  end;

implementation

{ TSimpleFundXTestCase }

uses
  OmniXML,
  ExtractBGL360,
  ExtractCommon,
  MoneyDef,
  SysUtils,
  StDateSt,
  BKTXIO;

function TSimpleFund360BulkTestCase.CreateTransactionRec : pTransaction_Rec;
begin
  Result := BKTXIO.New_Transaction_Rec;

  Result^.txDate_Presented  := Apr01_2004;
  Result.txDate_Effective   := Apr01_2004;
  Result.txAmount           := 12000;
  Result.txAccount          := '230';
  Result.txNotes            := 'NOTE';
  Result.txGL_Narration     := 'Account 1 Tran1';
  Result.txTax_Invoice_Available   := false;
  Result.txPayee_Number     := 0;
  Result.txGST_Class := 1;
  Result.txGST_Amount := Round(12000 / 9);
  Result.txExternal_GUID := '11';
end;

procedure TSimpleFund360BulkTestCase.Setup;
begin
end;

procedure TSimpleFund360BulkTestCase.TearDown;
begin
end;

procedure TSimpleFund360BulkTestCase.TestExtractBGL360;
const
  BGL360 = 0;
var
  Session       : TExtractSession;
  TestNode      : IxmlNode;
  FFields       : TStringList;
  FLineCount    : Integer;
  FTransCount   : Integer;
  FCurrentBal   : Money;
  TestTrans     : pTransaction_Rec;
  TransText     : string;

  procedure AddDateField(const Name: string; Value: Integer);
  begin
     if Value <> 0 then
        FFields.Add(Name + '=' + StDateToDateString('dd/mm/yyyy',Value,False));
  end;

  procedure AddField(const Name, Value: string);
  begin
     if Value > '' then
        FFields.Add(Name + '=' + Value );
  end;

  procedure AddNumberField(const Name: string; Value: Integer);
  begin
     FFields.Add(Name + '=' + InttoStr(Value));
  end;

  procedure AddMoneyField(const Name: string; Value: Money);
  begin
     if (Value=UnKnown)
     or (Value=0) then
     else
        FFields.Add(Name + '=' + Format('%.2f',[Value/100]));
  end;

  procedure AddTaxFields(TaxAmount: Money; TaxClass: Integer);
  var
    Code, Desc : string;
  begin
    AddMoneyField(f_Tax,TaxAmount);
  end;

  procedure AddQtyField(const Name: string; Value: Money);
  begin
    if Value <> 0 then
        FFields.Add(Name + '=' + Format('%.4f',[Value/10000]));
  end;

  function GetFullNotes (pT: pTransaction_Rec): string;
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

  function LookupChart(const Value: string): string;
  begin
     Result := '';
  end;

  function LookupJob(const Value: string): string;
  begin
     Result := '';
  end;

  function TransactionToText(aTrans: pTransaction_Rec): string;
  begin
    FFields := TStringList.Create;
    AddNumberField(f_Line,FlineCount);
    AddNumberField(f_Trans,FTransCount);
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

    // Coding
    AddField(f_Code,aTrans.txAccount);
    AddField(f_Desc,LookupChart(aTrans.txAccount));
    // Job
    AddField(f_JobCode, aTrans.txJob_Code);
    AddField(f_JobDesc, lookupJob(aTrans.txJob_Code));

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

    // Running balance
    if FCurrentBal <> Unknown then
      AddMoneyField(f_Balance,FCurrentBal);
    Result := FFields.DelimitedText;
  end;

begin
  TestTrans := CreateTransactionRec;
  TransText := TransactionToText(TestTrans);
  Session.Data := PAnsiChar(AnsiString(TransText));

  try
    StartFile;
    ClientStart(Session);
    Session.ExtractFunction := ef_SessionStart;
    WriteBGLFields(Session, TestNode, True);

    { This is just to show you what the xml will look like after it's generated below. If you
      change the code below, you should update this comment
    TestNode.xml = '<Transactions>
                      <Transaction>
                        <Transaction_Type>Other Transaction</Transaction_Type>
                        <Account_Code_Type>Simple Fund</Account_Code_Type>
                        <Other_Reference>             11</Other_Reference>
                        <Transaction_Source>Bank Statement</Transaction_Source>
                        <Cash>Cash</Cash>
                        <Account_Code>230</Account_Code>
                        <Transaction_Date>01/04/2004</Transaction_Date>
                        <Text>Account 1 Tran1</Text>
                        <Amount>120.00</Amount>
                        <GST>13.33</GST>
                        <GST_Rate>N/A</GST_Rate>
                      </Transaction>
                    </Transactions>'
    }

    Check(TestNode.NodeName                                 = 'Transactions');
    Check(TestNode.FirstChild.NodeName                      = 'Transaction');
    Check(TestNode.FirstChild.FirstChild.NodeName           = 'Transaction_Type');
    Check(TestNode.FirstChild.FirstChild.Text               = 'Other Transaction');
    Check(TestNode.FirstChild.ChildNodes.Item[1].NodeName   = 'Account_Code_Type');
    Check(TestNode.FirstChild.ChildNodes.Item[1].Text       = 'Simple Fund');
    Check(TestNode.FirstChild.ChildNodes.Item[2].NodeName   = 'Other_Reference');
    Check(Trim(TestNode.FirstChild.ChildNodes.Item[2].Text) = '11');
    Check(TestNode.FirstChild.ChildNodes.Item[3].NodeName   = 'Transaction_Source');
    Check(TestNode.FirstChild.ChildNodes.Item[3].Text       = 'Bank Statement');
    Check(TestNode.FirstChild.ChildNodes.Item[4].NodeName   = 'Cash');
    Check(TestNode.FirstChild.ChildNodes.Item[4].Text       = 'Cash');
    Check(TestNode.FirstChild.ChildNodes.Item[5].NodeName   = 'Account_Code');
    Check(TestNode.FirstChild.ChildNodes.Item[5].Text       = '230');
    Check(TestNode.FirstChild.ChildNodes.Item[6].NodeName   = 'Transaction_Date');
    Check(TestNode.FirstChild.ChildNodes.Item[6].Text       = '01/04/2004');
    Check(TestNode.FirstChild.ChildNodes.Item[7].NodeName   = 'Text');
    Check(TestNode.FirstChild.ChildNodes.Item[7].Text       = 'Account 1 Tran1');
    Check(TestNode.FirstChild.ChildNodes.Item[8].NodeName   = 'Amount');
    Check(TestNode.FirstChild.ChildNodes.Item[8].Text       = '120.00');
    Check(TestNode.FirstChild.ChildNodes.Item[9].NodeName   = 'GST');
    Check(TestNode.FirstChild.ChildNodes.Item[9].Text       = '13.33');
    Check(TestNode.FirstChild.ChildNodes.Item[10].NodeName  = 'GST_Rate');
    Check(TestNode.FirstChild.ChildNodes.Item[10].Text      = 'N/A');
  finally
    TestNode := nil
  end;
end;

initialization
  TestFramework.RegisterTest(TSimpleFund360BulkTestCase.Suite);

end.
