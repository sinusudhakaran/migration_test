unit utBGL360;
{$TYPEINFO ON} //Needed for classes with published methods

interface

uses
  chList32,
  Globals,
  SimpleFund,
  TestFramework; // DUnit

type
  TBGL360TestCase = class(TTestCase)
  private
    procedure CreateCSVDefaultFile;
  protected
    procedure SetUp; override;
  published
    procedure TestReadCSVFile;
  end;

implementation

procedure TBGL360TestCase.CreateCSVDefaultFile;
var
  CSVFile: TextFile;
begin
  try
    AssignFile(CSVFile, 'chart.csv');
    ReWrite(CSVFile);
    WriteLn(CSVFile, 'Account Code,Account Type,Account Name'); // ReadCSVFile will skip this line
    WriteLn(CSVFile, '20000,H,********** INCOME ACCOUNTS **********');
    WriteLn(CSVFile, '23800,C,Distributions Received');
    WriteLn(CSVFile, '23900,C,Dividends Received');
    WriteLn(CSVFile, '24000,C,Private dividends and other excessive non-arms length income');
    WriteLn(CSVFile, '24200,C,Contributions');
    WriteLn(CSVFile, '30000,H,********** EXPENSE ACCOUNTS **********');
    WriteLn(CSVFile, '30100,N,Accountancy Fees');
    WriteLn(CSVFile, '30200,N,Administration Costs');
    WriteLn(CSVFile, '30400,N,ATO Supervisory Levy');
    WriteLn(CSVFile, '48000,H,***** TAXATION/ALLOCATION ACCOUNTS *****');
    WriteLn(CSVFile, '48500,N,Income Tax Expense');
    WriteLn(CSVFile, '48600,N,Prior Years Under/Over Provision for Income Tax');
    WriteLn(CSVFile, '48700,C,Contributions Tax (Surcharge)');
    WriteLn(CSVFile, '50000,H,**********MEMBERS ACCOUNTS **********');
    WriteLn(CSVFile, '50010,C,Opening Balance');
    WriteLn(CSVFile, '52420,C,Contributions');
    WriteLn(CSVFile, '52850,C,Transfers In');
    WriteLn(CSVFile, '59000,H,**********MEMBERS Reserves **********');
    WriteLn(CSVFile, '59100,C,Anti-Detriment Reserve');
    WriteLn(CSVFile, '59200,C,Contribution Reserve');
    WriteLn(CSVFile, '59300,C,Investment Reserve');
    WriteLn(CSVFile, '59400,C,Pension Reserve');
    WriteLn(CSVFile, '60000,H,********** OTHER ASSETS **********');
    WriteLn(CSVFile, '60100,C,Amounts owing by Other Persons');
    WriteLn(CSVFile, '60400,C,Bank Accounts');
    WriteLn(CSVFile, '61600,C,Contributions Receivable');
    WriteLn(CSVFile, '61800,C,Distributions Receivable');
    WriteLn(CSVFile, '70000,H,********** INVESTMENTS **********');
    WriteLn(CSVFile, '71000,C,"Collectables (Coins, Stamps, Wine and Other Personal Use Assets)"');
    WriteLn(CSVFile, '72000,C,"Debt Securities (Bonds, Bills of Exchange, Promissory Notes)"');
    WriteLn(CSVFile, '72300,C,"Derivatives (Options, Hybrids, Future Contracts)"');
    WriteLn(CSVFile, '80000,H,********** LIABILITIES **********');
    WriteLn(CSVFile, '80500,C,Amounts owing to other persons');
    WriteLn(CSVFile, '81000,C,Interest Accrued');
    WriteLn(CSVFile, '83000,C,Investment Liabilities');
    WriteLn(CSVFile, '90000,H,********SUSPENSE  UNMATCHED ACCOUNTS***************');
    WriteLn(CSVFile, '91000,N,Bank Data Clearing Account');
    WriteLn(CSVFile, '92000,N,Investment Income Data Clearing Account');
  finally
    CloseFile(CSVFile);
  end;
end;

procedure TBGL360TestCase.SetUp;
begin
  CreateCSVDefaultFile;
  TestReadCSVFile;
end;

procedure TBGL360TestCase.TestReadCSVFile;
var
  NewChart: TChart;
begin
  NewChart := TChart.Create(MyClient.ClientAuditMgr);
  try
    ReadCSVFile('chart.csv', NewChart);
    Check(NewChart.Account_At(0)^.chAccount_Code          = '20000');
    Check(NewChart.Account_At(0)^.chPosting_Allowed       = false);
    Check(NewChart.Account_At(0)^.chAccount_Description   = '********** INCOME ACCOUNTS **********');
    Check(NewChart.Account_At(6)^.chAccount_Code          = '30100');
    Check(NewChart.Account_At(6)^.chAccount_Description   = 'Accountancy Fees');
    Check(NewChart.Account_At(37)^.chAccount_Code         = '92000');
    Check(NewChart.Account_At(37)^.chAccount_Description  = 'Investment Income Data Clearing Account');
  finally
    NewChart.Destroy;
  end;
end;

//------------------------------------------------------------------------------
initialization
  TestFramework.RegisterTest(TBGL360TestCase.Suite);


end.
