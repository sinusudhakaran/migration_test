unit utSimpleFund360Bulk;
{$TYPEINFO ON} //Needed for classes with published methods

interface

uses
  bkConst,
  bkDefs,
  Classes,
  clObj32,
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
    BK5TestClient: TClientObj;
    Chart230, Chart400 : pAccount_Rec;
    AccountList: TStringList;
    procedure CreateBK5TestClient;
  protected
    procedure Setup; override;
    procedure TearDown; override;
  published
    procedure TestExtractBGL360;
  end;

implementation

{ TSimpleFundXTestCase }

uses
  baObj32,
  BKchIO,
  BKdsIO,
  BulkExtractFrm,
  ExtractBGL360,
  ExtractCommon,
  glConst,
  Globals,
  MoneyDef,
  OmniXML,
  SimpleFundX,
  Software,
  StDateSt,
  SysUtils,
  trxList32;

procedure TSimpleFund360BulkTestCase.CreateBK5TestClient;
var
  ba : TBank_Account;
  pt : pTransaction_Rec;
  pD : pDissection_Rec;

begin
  AccountList := TStringList.Create;

  //create a test client
  BK5TestClient := TClientObj.Create;
  //basic client details
  BK5TestClient.clFields.clCode := 'UNITTEST';
  BK5TestClient.clFields.clName := 'DUnit Test Client';
  BK5TestClient.clFields.clCountry := 0;    //New Zealand
  BK5TestClient.clFields.clFile_Type := 0;  //banklink file
  BK5TestClient.clFields.clAccounting_System_Used := 0;
  BK5TestClient.clFields.clFinancial_Year_Starts := 147649; //01 April 2004
  BK5TestClient.clFields.clMagic_Number  := 123456;

  //gst rates (NZ)
  BK5TestClient.clFields.clGST_Applies_From[1] := 138883; // 01 Jan 1980

  {Income}
  BK5TestClient.clFields.clGST_Class_Codes[1]  := 'I';
  BK5TestClient.clFields.clGST_Class_Names[1]  := 'GST on Sales';
  BK5TestClient.clFields.clGST_Class_Types[1]  := gtOutputTax;
  BK5TestClient.clFields.clGST_Rates[1,1]      := 125000;
  {Expenditure}
  BK5TestClient.clFields.clGST_Class_Codes[2]  := 'E';
  BK5TestClient.clFields.clGST_Class_Names[2]  := 'GST on Purchases';
  BK5TestClient.clFields.clGST_Class_Types[2]  := gtInputTax;
  BK5TestClient.clFields.clGST_Rates[2,1]      := 125000;
  {Exempt}
  BK5TestClient.clFields.clGST_Class_Codes[3]  := 'X';
  BK5TestClient.clFields.clGST_Class_Names[3]  := 'Exempt';
  BK5TestClient.clFields.clGST_Class_Types[3]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[3,1]      := 0;
  BK5TestClient.ClExtra.ceLocal_Currency_Code  := 'NZD';

  //chart
  Chart230 := bkChio.New_Account_Rec;
  Chart230^.chAccount_Code := '230';
  Chart230^.chAccount_Description := 'Sales';
  Chart230^.chGST_Class := 1;
  Chart230^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( Chart230);

  Chart400 := bkChio.New_Account_Rec;
  Chart400^.chAccount_Code := '400';
  Chart400^.chAccount_Description := 'Expenses 400';
  Chart400^.chGST_Class := 2;
  Chart400^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( Chart400);

  //create two bank accounts
  ba := TBank_Account.Create(nil);
  ba.baFields.baBank_Account_Number := '12345';
  ba.baFields.baBank_Account_Name   := 'Account 1';
  ba.baFields.baCurrent_Balance := 100;
  ba.baFields.baContra_Account_Code := '680';
  ba.baFields.baCurrency_Code := 'NZD';

  bk5testClient.clBank_Account_List.Insert( ba);

  //create transactions
  pT := ba.baTransaction_List.New_Transaction;

  pT^.txDate_Presented  := Apr01_2004;
  pT.txDate_Effective   := Apr01_2004;
  pT.txAmount           := 12000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '11';


  ba.baTransaction_List.Insert_Transaction_Rec( pT);

  //create dissected
  pT := ba.baTransaction_List.New_Transaction;

  pT^.txDate_Presented  := Apr02_2004;
  pT.txDate_Effective   := Apr02_2004;
  pT.txAmount           := 15000;
  pT.txAccount          := 'DISSECTED';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txExternal_GUID := '12';

  pD := bkdsio.New_Dissection_Rec;
  pD^.dsAccount         := '400';
  pD.dsAmount           := 6000;
  pD.dsGST_Class        := 2;
  pD.dsGST_Amount       := Round(6000/9);
  pD.dsNotes            := 'L1 NOTE';
  pD.dsGL_Narration     := 'Line 1';
  AppendDissection( pT, pD);

  pD := bkdsio.New_Dissection_Rec;
  pD^.dsAccount         := '402';
  pD.dsAmount           := 9000;
  pD.dsGST_Class        := 3;
  pD.dsGST_Amount       := 0;
  pD.dsGST_Has_Been_Edited := True;
  pD.dsNotes            := 'L2 NOTE';
  pD.dsGL_Narration     := 'Line 2';
  AppendDissection( pT, pD);

  ba.baTransaction_List.Insert_Transaction_Rec( pT);
  AccountList.AddObject(ba.baFields.baBank_Account_Number, ba);

  //create 2nd bank account
  ba := TBank_Account.Create(nil);
//  ba.baClient := bk5testClient;
  ba.baFields.baBank_Account_Number := '67890';
  ba.baFields.baBank_Account_Name   := 'Account 2';
  ba.baFields.baCurrent_Balance := 100;
  ba.baFields.baContra_Account_Code := '681';
  ba.baFields.baCurrency_Code := 'NZD';
  bk5testClient.clBank_Account_List.Insert( ba);

  pT := ba.baTransaction_List.New_Transaction;

  pT^.txDate_Presented  := Apr03_2004;
  pT.txDate_Effective   := Apr03_2004;
  pT.txAmount           := -4000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 2 Tran1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(4000 / 9);
  pT.txExternal_GUID := '13';
  pT^.txQuantity := 123456;

  ba.baTransaction_List.Insert_Transaction_Rec( pT);

  //create dissected
  pT := ba.baTransaction_List.New_Transaction;

  pT^.txDate_Presented  := Apr04_2004;
  pT.txDate_Effective   := Apr04_2004;
  pT.txAmount           := 20000;
  pT.txAccount          := 'DISSECTED';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := '[A]c<c/>"&ount 2 Tran2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txExternal_GUID := '14';

  pD := bkdsio.New_Dissection_Rec;
  pD^.dsAccount         := '400';
  pD.dsAmount           := 6000;
  pD.dsGST_Class        := 2;
  pD.dsGST_Amount       := Round(6000/9);
  pD.dsNotes            := 'L1 NOTE';
  pD.dsGL_Narration     := 'Line 1';
  AppendDissection( pT, pD);

  pD := bkdsio.New_Dissection_Rec;
  pD^.dsAccount         := '402';
  pD.dsAmount           := 14000;
  pD.dsGST_Class        := 3;
  pD.dsGST_Amount       := 0;
  pD.dsGST_Has_Been_Edited := True;
  pD.dsNotes            := 'L2 NOTE';
  pD.dsGL_Narration     := 'Line 2';
  AppendDissection( pT, pD);

  ba.baTransaction_List.Insert_Transaction_Rec( pT);
  AccountList.AddObject(ba.baFields.baBank_Account_Number, ba);

  MyClient := BK5TestClient;
end;

procedure TSimpleFund360BulkTestCase.Setup;
begin
  CreateBK5TestClient;
end;

procedure TSimpleFund360BulkTestCase.TearDown;
begin
  BK5TestClient.Free;

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

  procedure AddField(const Name, Value: string);
  begin
     if Value > '' then
        FFields.Add(Name + '=' + Value );
  end;

  function LookupChart(const Value: string): string;
  begin
     Result := '';
     if (Value > '')
     and Assigned(bk5testclient) then
         Result := bk5testclient.clChart.FindDesc(Value);
  end;

  procedure AddNumberField(const Name: string; Value: Integer);
  begin
     FFields.Add(Name + '=' + InttoStr(Value));
  end;

  procedure AddDateField(const Name: string; Value: Integer);
  begin
     if Value <> 0 then
        FFields.Add(Name + '=' + StDateToDateString('dd/mm/yyyy',Value,False));
  end;

  procedure AddMoneyField(const Name: string; Value: Money);
  begin
     if (Value=UnKnown)
     or (Value=0) then
     else
        FFields.Add(Name + '=' + Format('%.2f',[Value/100]));
  end;

  function LookupTaxClass(const Value: integer; var Code, Desc: string ): boolean;
  begin
     Result := false;
     if Assigned(BK5TestClient)
     and (Value in [1..MAX_GST_CLASS]) then begin
        Desc := BK5TestClient.clFields.clGST_Class_Names [Value];
        Code := BK5TestClient.clFields.clGST_Class_Codes [Value];
        Result := True;
     end;
  end;

  procedure AddTaxFields(TaxAmount: Money; TaxClass: Integer);
  var
    Code, Desc : string;
  begin
     if TaxClass > 0 then begin
        if LookupTaxClass(TaxClass, Code, Desc) then begin
           AddField(f_TaxCode,Code);
           AddField(f_TaxDesc,Desc);
        end;
        AddMoneyField(f_Tax,TaxAmount);
     end;
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

  function LookupJob(const Value: string): string;
  begin
     Result := '';
     if (Value > '')
     and Assigned(BK5TestClient) then
         Result := BK5TestClient.clJobs.JobName(Value);
  end;

  function AccountToText(anAccount: TBank_Account): string;
  begin
     FFields.Clear;

     AddField(f_Name, anAccount.baFields.baBank_Account_Name );
     AddField(f_Number, anAccount.baFields.baBank_Account_Number);
     AddField(f_ContraCode, anAccount.baFields.baContra_Account_Code);
     AddField(f_ContraDesc, LookupChart(anAccount.baFields.baContra_Account_Code) );

     if Software.HasSuperfundLegerID(BK5TestClient.clFields.clCountry,BK5TestClient.clFields.clAccounting_System_Used) then
        AddNumberField(f_FundID, anAccount.baFields.baDesktop_Super_Ledger_ID)
     else if Software.HasSuperfundLegerCode(BK5TestClient.clFields.clCountry,BK5TestClient.clFields.clAccounting_System_Used) then
        AddField(f_FundID, anAccount.baFields.baSuperFund_Ledger_Code);

     if FCurrentBal <> Unknown then
        AddMoneyField(f_Balance,FCurrentBal);
     Result := FFields.DelimitedText;
  end;

  procedure AddBGLFields(Date, Component: Integer);
  begin
    if (Date = 0)
    or (Date >= mcSwitchDate) then begin
       if Component in [mcnewMin .. mcnewMax] then
          AddField(f_MemComp,mcNewNames[Component]);

    end else begin
        if Component in [mcOldMin .. mcOldMax] then
           AddField(f_MemComp,mcOldNames[Component]);
    end;
  end;

  procedure AddFractionField(const Name: string; Value: Boolean);
  begin
     if Value then
        FFields.Add(Name + '=1/2' )
     else
        FFields.Add(Name + '=2/3' )
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

    // Superfund...
    if IsSuperFund(BK5TestClient.clFields.clCountry,BK5TestClient.clFields.clAccounting_System_Used) then begin

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

       // Fund, Member and Transaction are more system specific
       case BK5TestClient.clFields.clAccounting_System_Used of
         saBGL360: AddBGLFields(aTrans.txDate_Effective,
                                         aTrans.txSF_Member_Component);
       end;

    end;

    // Running balance
    if FCurrentBal <> Unknown then
      AddMoneyField(f_Balance,FCurrentBal);
    Result := FFields.DelimitedText;
  end;

begin
  TestTrans := BK5TestClient.clBank_Account_List.Bank_Account_At(0).baTransaction_List.Transaction_At(0);
  TransText := TransactionToText(TestTrans);
  Session.Data := PAnsiChar(AnsiString(TransText));

  try
    StartFile;
    ClientStart(Session);
    Session.ExtractFunction := ef_SessionStart;
    WriteBGLFields(Session, TestNode, True);

    {
    TestNode.xml = '<Transactions>
                      <Transaction>
                        <Transaction_Type>Other Transaction</Transaction_Type>
                        <Account_Code_Type>Simple Fund</Account_Code_Type>
                        <Other_Reference>             11</Other_Reference>
                        <Transaction_Source>Journal</Transaction_Source>
                        <Cash>Non Cash</Cash>
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
//    Check('a' = 'b'); // remove this
  finally
    TestNode := nil
  end;
end;

initialization
  TestFramework.RegisterTest(TSimpleFund360BulkTestCase.Suite);

end.
