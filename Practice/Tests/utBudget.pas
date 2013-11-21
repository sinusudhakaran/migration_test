unit utBudget;
{$TYPEINFO ON} //Needed for classes with published methods

interface

uses
  TestFramework,
  BudgetImportExport;

type
  TBudgetTest = class(TTestCase)
  private
    fData: TBudgetData;
    fExport: TBudgetImportExport;

    function  ExportFileContains(const aValue: string): boolean;

  public
    procedure SetUp; override;
    procedure TearDown; override;

  published
    procedure TestPrefix;
    procedure TestImportExport;
  end;


implementation

uses
  SysUtils,
  Classes,
  Windows,
  Globals,
  bkConst;

{ TBudgetTest }

const
  TEST_CSV = 'c:\temp\Prefix-test.csv';

procedure TBudgetTest.SetUp;
begin
  inherited;
  SetLength(fData, 1);
  fExport := TBudgetImportExport.Create;
end;

procedure TBudgetTest.TearDown;
begin
  inherited;
  FreeAndNil(fExport);
end;

procedure TBudgetTest.TestPrefix;
begin
  with fData[0] do
  begin
    bAccount := '123';
    Check(not DoAccountCodesNeedToBePrefixed(fData), 'Plain code');
    bAccount := '0123';
    Check(DoAccountCodesNeedToBePrefixed(fData), 'Leading zeros need to be prefixed');
    bAccount := '123.10';
    Check(DoAccountCodesNeedToBePrefixed(fData), 'Trailing zeros need to be prefixed');
    bAccount := '1/2/2003';
    Check(DoAccountCodesNeedToBePrefixed(fData), 'Date needs to be prefixed');
  end;
end;

procedure TBudgetTest.TestImportExport;
var
  sPrefixCode: string;
  sMsg: string;
begin
  with fData[0] do
  begin
    // Export
    bAccount := '0123';
    if not fExport.ExportBudget(TEST_CSV, true, fData, 1, sMsg, true, true) then
      Check(false, 'Error exporting to file');
    sPrefixCode := ACCOUNT_CODE_PREFIX + bAccount;
    Check(ExportFileContains(sPrefixCode), 'Export CSV should contain prefix');
    DeleteFile(TEST_CSV);

    // Note: can't test import, because it searches MyClient.clChart

    MyClient.clExtra.ceAdd_Prefix_For_Account_Code := prfxOff;
    if not fExport.ExportBudget(TEST_CSV, true, fData, 1, sMsg, true, false) then
      Check(false, 'Error exporting to file');
    Check(not ExportFileContains(sPrefixCode), 'Export CSV should contain prefix');
    DeleteFile(TEST_CSV);
  end;
end;

function TBudgetTest.ExportFileContains(const aValue: string): boolean;
var
  varText: TStringList;
  iPos: integer;
begin
  varText := TStringList.Create;
  try
    varText.LoadFromFile(TEST_CSV);
    iPos := Pos(aValue, varText.Text);
    result := (iPos <> 0);
  finally
    FreeAndNil(varText);
  end;
end;

initialization
begin
  TestFramework.RegisterTest(TBudgetTest.Suite);
end;

end.
