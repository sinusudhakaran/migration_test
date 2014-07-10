unit utCashbookChartExport;
{$TYPEINFO ON} //Needed for classes with published methods
//------------------------------------------------------------------------------
interface
uses
  TestFramework,  //DUnit
  classes,
  ChartExportToMYOBCashbook,
  clObj32;

//------------------------------------------------------------------------------
type
 TCashbookChartExportTestCase = class(TTestCase)
 private
   fTestClient : TClientObj;

   Procedure FillTestClient;
 protected
   procedure Setup; override;
   procedure TearDown; override;
 published
   procedure TestExportClientChartNoBalances;
   procedure TestExportClientChartBalances;
 end;

//------------------------------------------------------------------------------
implementation

uses
  SysUtils,
  baObj32,
  BKDEFS,
  bkConst,
  BKchIO,
  BKdsIO,
  trxList32,
  Forms,
  FrmChartExportToMYOBCashBook,
  Globals;

const
  Jan01_1980 = 138883;
  Apr01_2004 = 147649;
  Apr02_2004 = Apr01_2004 + 1;
  Apr03_2004 = Apr01_2004 + 2;
  Apr04_2004 = Apr01_2004 + 3;
  Apr05_2004 = Apr01_2004 + 4;

{ TInstitutionColTestCase }
//------------------------------------------------------------------------------
procedure TCashbookChartExportTestCase.FillTestClient;
var
  BankAcc : TBank_Account;
  pTranRec : pTransaction_Rec;
  pDissection : pDissection_Rec;
  Chart230 : pAccount_Rec;
  Chart400 : pAccount_Rec;
  Chart500 : pAccount_Rec;
begin
  //create a test client
  fTestClient := TClientObj.Create;
  //basic client details
  fTestClient.clFields.clCode := 'UNITTEST';
  fTestClient.clFields.clName := 'DUnit Test Client';
  fTestClient.clFields.clCountry := 0;    //New Zealand
  fTestClient.clFields.clFile_Type := 0;  //banklink file
  fTestClient.clFields.clAccounting_System_Used := 0;
  fTestClient.clFields.clFinancial_Year_Starts := Apr01_2004;
  fTestClient.clFields.clMagic_Number  := 123456;

  //gst rates (NZ)
  fTestClient.clFields.clGST_Applies_From[1] := Jan01_1980;

  {Income}
  fTestClient.clFields.clGST_Class_Codes[1]  := 'I';
  fTestClient.clFields.clGST_Class_Names[1]  := 'GST on Sales';
  fTestClient.clFields.clGST_Class_Types[1]  := gtOutputTax;
  fTestClient.clFields.clGST_Rates[1,1]      := 125000;
  {Expenditure}
  fTestClient.clFields.clGST_Class_Codes[2]  := 'E';
  fTestClient.clFields.clGST_Class_Names[2]  := 'GST on Purchases';
  fTestClient.clFields.clGST_Class_Types[2]  := gtInputTax;
  fTestClient.clFields.clGST_Rates[2,1]      := 125000;
  {Exempt}
  fTestClient.clFields.clGST_Class_Codes[3]  := 'X';
  fTestClient.clFields.clGST_Class_Names[3]  := 'Exempt';
  fTestClient.clFields.clGST_Class_Types[3]  := gtExempt;
  fTestClient.clFields.clGST_Rates[3,1]      := 0;
  fTestClient.ClExtra.ceLocal_Currency_Code  := 'NZD';

  //chart
  Chart230 := bkChio.New_Account_Rec;
  Chart230^.chAccount_Code := '230';
  Chart230^.chAccount_Description := 'Sales';
  Chart230^.chAccount_Type := atIncome;
  Chart230^.chGST_Class := 1;
  Chart230^.chPosting_Allowed := true;
  fTestClient.clChart.Insert( Chart230);

  Chart400 := bkChio.New_Account_Rec;
  Chart400^.chAccount_Code := '400';
  Chart400^.chAccount_Description := 'Expenses 400';
  Chart400^.chAccount_Type := atExpense;
  Chart400^.chGST_Class := 2;
  Chart400^.chPosting_Allowed := true;
  fTestClient.clChart.Insert( Chart400);

  Chart500 := bkChio.New_Account_Rec;
  Chart500^.chAccount_Code := '500';
  Chart500^.chAccount_Description := 'Expenses 500';
  Chart500^.chAccount_Type := atExpense;
  Chart500^.chGST_Class := 3;
  Chart500^.chPosting_Allowed := true;
  fTestClient.clChart.Insert( Chart500);

  //create two bank accounts
  BankAcc := TBank_Account.Create(nil);
//  ba.baClient := fTestClient;
  BankAcc.baFields.baBank_Account_Number := '12345';
  BankAcc.baFields.baBank_Account_Name   := 'Account 1';
  BankAcc.baFields.baCurrent_Balance := 100;
  BankAcc.baFields.baContra_Account_Code := '680';
  BankAcc.baFields.baCurrency_Code := 'NZD';

  fTestClient.clBank_Account_List.Insert( BankAcc);

  //create transactions
  pTranRec := BankAcc.baTransaction_List.New_Transaction;

  pTranRec^.txDate_Presented  := Apr01_2004;
  pTranRec.txDate_Effective   := Apr01_2004;
  pTranRec.txAmount           := 12000;
  pTranRec.txAccount          := '230';
  pTranRec.txNotes            := 'NOTE';
  pTranRec.txGL_Narration     := 'Account 1 Tran1';
  pTranRec.txTax_Invoice_Available   := false;
  pTranRec.txPayee_Number     := 0;
  pTranRec.txGST_Class := 1;
  pTranRec.txGST_Amount := Round(12000 / 9);
  pTranRec.txExternal_GUID := '11';


  BankAcc.baTransaction_List.Insert_Transaction_Rec( pTranRec);

  //create dissected
  pTranRec := BankAcc.baTransaction_List.New_Transaction;

  pTranRec^.txDate_Presented  := Apr02_2004;
  pTranRec.txDate_Effective   := Apr02_2004;
  pTranRec.txAmount           := 15000;
  pTranRec.txAccount          := 'DISSECTED';
  pTranRec.txNotes            := 'NOTE';
  pTranRec.txGL_Narration     := 'Account 1 Tran2';
  pTranRec.txTax_Invoice_Available   := false;
  pTranRec.txPayee_Number     := 0;
  pTranRec.txExternal_GUID := '12';

  pDissection := bkdsio.New_Dissection_Rec;
  pDissection^.dsAccount         := '400';
  pDissection.dsAmount           := 6000;
  pDissection.dsGST_Class        := 2;
  pDissection.dsGST_Amount       := Round(6000/9);
  pDissection.dsNotes            := 'L1 NOTE';
  pDissection.dsGL_Narration     := 'Line 1';
  AppendDissection( pTranRec, pDissection);

  pDissection := bkdsio.New_Dissection_Rec;
  pDissection^.dsAccount         := '402';
  pDissection.dsAmount           := 9000;
  pDissection.dsGST_Class        := 3;
  pDissection.dsGST_Amount       := 0;
  pDissection.dsGST_Has_Been_Edited := True;
  pDissection.dsNotes            := 'L2 NOTE';
  pDissection.dsGL_Narration     := 'Line 2';
  AppendDissection( pTranRec, pDissection);

  BankAcc.baTransaction_List.Insert_Transaction_Rec( pTranRec);

  //create 2nd bank account
  BankAcc := TBank_Account.Create(nil);
//  ba.baClient := fTestClient;
  BankAcc.baFields.baBank_Account_Number := '67890';
  BankAcc.baFields.baBank_Account_Name   := 'Account 2';
  BankAcc.baFields.baCurrent_Balance := 100;
  BankAcc.baFields.baContra_Account_Code := '681';
  BankAcc.baFields.baCurrency_Code := 'NZD';
  fTestClient.clBank_Account_List.Insert( BankAcc);

  pTranRec := BankAcc.baTransaction_List.New_Transaction;

  pTranRec^.txDate_Presented  := Apr03_2004;
  pTranRec.txDate_Effective   := Apr03_2004;
  pTranRec.txAmount           := -4000;
  pTranRec.txAccount          := '230';
  pTranRec.txNotes            := 'NOTE';
  pTranRec.txGL_Narration     := 'Account 2 Tran1';
  pTranRec.txTax_Invoice_Available   := false;
  pTranRec.txPayee_Number     := 0;
  pTranRec.txGST_Class := 1;
  pTranRec.txGST_Amount := Round(4000 / 9);
  pTranRec.txExternal_GUID := '13';
  pTranRec^.txQuantity := 123456;

  BankAcc.baTransaction_List.Insert_Transaction_Rec( pTranRec);

  //create dissected
  pTranRec := BankAcc.baTransaction_List.New_Transaction;

  pTranRec^.txDate_Presented  := Apr04_2004;
  pTranRec.txDate_Effective   := Apr04_2004;
  pTranRec.txAmount           := 20000;
  pTranRec.txAccount          := 'DISSECTED';
  pTranRec.txNotes            := 'NOTE';
  pTranRec.txGL_Narration     := '[A]c<c/>"&ount 2 Tran2';
  pTranRec.txTax_Invoice_Available   := false;
  pTranRec.txPayee_Number     := 0;
  pTranRec.txExternal_GUID := '14';

  pDissection := bkdsio.New_Dissection_Rec;
  pDissection^.dsAccount         := '400';
  pDissection.dsAmount           := 6000;
  pDissection.dsGST_Class        := 2;
  pDissection.dsGST_Amount       := Round(6000/9);
  pDissection.dsNotes            := 'L1 NOTE';
  pDissection.dsGL_Narration     := 'Line 1';
  AppendDissection( pTranRec, pDissection);

  pDissection := bkdsio.New_Dissection_Rec;
  pDissection^.dsAccount         := '402';
  pDissection.dsAmount           := 14000;
  pDissection.dsGST_Class        := 3;
  pDissection.dsGST_Amount       := 0;
  pDissection.dsGST_Has_Been_Edited := True;
  pDissection.dsNotes            := 'L2 NOTE';
  pDissection.dsGL_Narration     := 'Line 2';
  AppendDissection( pTranRec, pDissection);

  BankAcc.baTransaction_List.Insert_Transaction_Rec( pTranRec);
end;

//------------------------------------------------------------------------------
procedure TCashbookChartExportTestCase.Setup;
begin
  inherited;

  fTestClient := TClientObj.Create;
end;

//------------------------------------------------------------------------------
procedure TCashbookChartExportTestCase.TearDown;
begin
  FreeAndNil(fTestClient);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TCashbookChartExportTestCase.TestExportClientChartNoBalances;
const
  CHART_EXPORT_FILE = 'ChartExportFile.csv';
var
  TestFile : Text;
  LineStr : string;
begin
  FillTestClient;

  //set my client pointer
  Globals.MyClient := fTestClient;

  ChartExportToMYOBEssentialsCashbook.DoChartExport(nil, CHART_EXPORT_FILE);

  AssignFile(TestFile, CHART_EXPORT_FILE);
  Reset(TestFile);
  try
    Readln(TestFile, LineStr);
    Check(LineStr = 'Code,Description,Account Group,GST Type,Opening Balance,Opening Balance Date');

    Readln(TestFile, LineStr);
    Check(LineStr = '230,Sales,Income,GST,,'); // No amounts or total for non posting codes

    Readln(TestFile, LineStr);
    Check(LineStr = '400,Expenses 400,Expense,GST,,');

    Readln(TestFile, LineStr);
    Check(LineStr = '500,Expenses 500,Expense,E,,');
  finally
    closefile(TestFile);
  end;
end;

//------------------------------------------------------------------------------
procedure TCashbookChartExportTestCase.TestExportClientChartBalances;
const
  CHART_EXPORT_FILE = 'ChartExportFile.csv';
var
  TestFile : Text;
  LineStr : string;
begin
  FillTestClient;

  //set my client pointer
  Globals.MyClient := fTestClient;

  ChartExportToMYOBEssentialsCashbook.DoChartExport(nil, CHART_EXPORT_FILE, true);

  AssignFile(TestFile, CHART_EXPORT_FILE);
  Reset(TestFile);
  try
    Readln(TestFile, LineStr);
    Check(LineStr = 'Code,Description,Account Group,GST Type,Opening Balance,Opening Balance Date');

    Readln(TestFile, LineStr);
    Check(LineStr = '230,Sales,Income,GST,,'); // No amounts or total for non posting codes

    Readln(TestFile, LineStr);
    Check(LineStr = '400,Expenses 400,Expense,GST,,');

    Readln(TestFile, LineStr);
    Check(LineStr = '500,Expenses 500,Expense,E,,');
  finally
    closefile(TestFile);
  end;
end;

//------------------------------------------------------------------------------
initialization
  TestFramework.RegisterTest(TCashbookChartExportTestCase.Suite);

end.

