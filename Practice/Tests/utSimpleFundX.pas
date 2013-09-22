unit utSimpleFundX;
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
  TSimpleFundXTestCase = class(TTestCase)
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
  Globals,
  OmniXML,
  SimpleFundX,
  trxList32;

procedure TSimpleFundXTestCase.CreateBK5TestClient;
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

procedure TSimpleFundXTestCase.Setup;
begin
  CreateBK5TestClient;
end;

procedure TSimpleFundXTestCase.TearDown;
begin
  BK5TestClient.Free;

end;

procedure TSimpleFundXTestCase.TestExtractBGL360;
const
  XmlFile = 'BGLTest.xml';
var
  XmlTestDoc: IXMLDocument;
  BGLImportExport, BankBalances, Transactions: IXmlNode;
begin
  SimpleFundX.ExtractDataBGL360(Apr01_2004, Apr04_2004, XmlFile, AccountList);

  XmlTestDoc := CreateXMLDoc;
  XmlTestDoc.PreserveWhiteSpace := false;
  XmlTestDoc.Load(XmlFile);
  Check(XMLTestDoc.FirstChild.XML = '<?xml version="1.0" encoding="ISO-8859-1"?>');
  BGLImportExport := XmlTestDoc.LastChild;
  Check(BGLImportExport.NodeName = 'BGL_Import_Export');
  Check(BGLImportExport.SelectSingleNode('Supplier').Text = 'MYOB BankLink');
  Check(BGLImportExport.SelectSingleNode('Product').Text = 'SF360');
  Check(BGLImportExport.SelectSingleNode('Import_Export_Version').Text = '5.0');
  Check(BGLImportExport.LastChild.NodeName = 'Entity_Details');
  Check(BGLImportExport.LastChild.FirstChild.XML = '<Entity_Code>UNITTEST</Entity_Code>');
  BankBalances := XmlTestDoc.LastChild.LastChild.ChildNodes.Item[1];
  Check(BankBalances.FirstChild.SelectSingleNode('BalanceAmount').Text = '-269.00');
  Check(BankBalances.LastChild.SelectSingleNode('BSB').Text = '67890');
  Transactions := XmlTestDoc.LastChild.LastChild.ChildNodes.Item[2];
  Check(Transactions.FirstChild.SelectSingleNode('Transaction_Date').Text = '01/04/2004');
  Check(Transactions.ChildNodes.Item[1].SelectSingleNode('Amount').Text = '60.00');
  Check(Transactions.ChildNodes.Item[2].SelectSingleNode('Text').Text = 'Line 2');

  Check('fail' = 'bigfail'); // deliberate fail, want to test the build will spot it, don't leave this in
end;

initialization
  TestFramework.RegisterTest(TSimpleFundXTestCase.Suite);

end.
