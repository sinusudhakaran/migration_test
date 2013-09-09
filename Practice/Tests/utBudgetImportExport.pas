unit utBudgetImportExport;
{$TYPEINFO ON} //Needed for classes with published methods
//------------------------------------------------------------------------------
interface
uses
  TestFramework,  //DUnit
  BudgetImportExport,
  classes;

//------------------------------------------------------------------------------
type
 TBudgetImportExportTestCase = class(TTestCase)
 private
   fBudgetImportExport : TBudgetImportExport;

   procedure CreateBudgetDefaultFile;
   function CreateBudgetData : TBudgetData;
 protected
   procedure Setup; override;
   procedure TearDown; override;
 published
   procedure TestGetDefaultFileLocation;
   procedure TestSetDefaultFileLocation;
   procedure TestExportBudget;
 end;

//------------------------------------------------------------------------------
implementation

{ TPayeesTestCase }
//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.CreateBudgetDefaultFile;
var
  BudgetDefaults: TStringList;
begin
  BudgetDefaults := TStringList.create;
  try
    BudgetDefaults.Add('CLT00001' + ',' + 'c:\test\test001.csv');
    BudgetDefaults.Add('CLT00002' + ',' + 'c:\test\test002.csv');
    BudgetDefaults.Add('CLT00003' + ',' + 'c:\test\test003.csv');
    BudgetDefaults.Add('CLT00004' + ',' + 'c:\test\test004.csv');
    BudgetDefaults.Add('CLT00005' + ',' + 'c:\test\test005.csv');
    BudgetDefaults.Add('CLT00006' + ',' + 'c:\test\test006.csv');
    BudgetDefaults.Add('CLT00007' + ',' + 'c:\test\test007.csv');
    BudgetDefaults.Add('CLT00008' + ',' + 'c:\test\test008.csv');
    BudgetDefaults.Add('CLT00009' + ',' + 'c:\test\test009.csv');
    BudgetDefaults.Add('CLT00010' + ',' + 'c:\test\test010.csv');

    BudgetDefaults.SaveToFile('BudgetDefaultFile.dat');
  finally
    BudgetDefaults.free;
  end;
end;

//------------------------------------------------------------------------------
function TBudgetImportExportTestCase.CreateBudgetData: TBudgetData;
var
  Index : integer;
begin
  SetLength(Result,3);

  // Line One
  Result[0].bAccount := '001';
  Result[0].bDesc := 'Test Description 001';

  Result[0].bAmounts[1] := 100;
  Result[0].bAmounts[2] := 200;
  Result[0].bAmounts[3] := 300;
  Result[0].bAmounts[4] := 400;
  Result[0].bAmounts[5] := 500;
  Result[0].bAmounts[6] := 600;
  Result[0].bAmounts[7] := 700;
  Result[0].bAmounts[8] := 800;
  Result[0].bAmounts[9] := 900;
  Result[0].bAmounts[10] := 1000;
  Result[0].bAmounts[11] := 1100;
  Result[0].bAmounts[12] := 1200;

  Result[0].bTotal := 0;
  for Index := 1 to 12 do
    Result[0].bTotal := Result[0].bTotal + Result[0].bAmounts[Index];

  // Line Two
  Result[1].bAccount := '002';
  Result[1].bDesc := '0123456789012345678901234567890123456789';

  Result[1].bAmounts[1] := 0;
  Result[1].bAmounts[2] := 0;
  Result[1].bAmounts[3] := 0;
  Result[1].bAmounts[4] := 0;
  Result[1].bAmounts[5] := 0;
  Result[1].bAmounts[6] := 0;
  Result[1].bAmounts[7] := 0;
  Result[1].bAmounts[8] := 0;
  Result[1].bAmounts[9] := 0;
  Result[1].bAmounts[10] := 0;
  Result[1].bAmounts[11] := 0;
  Result[1].bAmounts[12] := 0;

  Result[1].bTotal := 0;
  for Index := 1 to 12 do
    Result[1].bTotal := Result[1].bTotal + Result[1].bAmounts[Index];

    // Line Three
  Result[2].bAccount := '003';
  Result[2].bDesc := 'Test Description 003';

  Result[2].bAmounts[1] := 0;
  Result[2].bAmounts[2] := 200;
  Result[2].bAmounts[3] := 0;
  Result[2].bAmounts[4] := 400;
  Result[2].bAmounts[5] := 0;
  Result[2].bAmounts[6] := 600;
  Result[2].bAmounts[7] := 0;
  Result[2].bAmounts[8] := 800;
  Result[2].bAmounts[9] := 0;
  Result[2].bAmounts[10] := 1000;
  Result[2].bAmounts[11] := 0;
  Result[2].bAmounts[12] := 1200;

  Result[2].bTotal := 0;
  for Index := 1 to 12 do
    Result[2].bTotal := Result[2].bTotal + Result[2].bAmounts[Index];
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.Setup;
begin
  CreateBudgetDefaultFile;

  fBudgetImportExport := TBudgetImportExport.Create;
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.TearDown;
begin
  fBudgetImportExport.free;
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.TestGetDefaultFileLocation;
begin
  fBudgetImportExport.BudgetDefaultFile := 'BudgetDefaultFile.dat';

  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00001') = 'c:\test\test001.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00005') = 'c:\test\test005.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00010') = 'c:\test\test010.csv');
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.TestSetDefaultFileLocation;
begin
  fBudgetImportExport.BudgetDefaultFile := 'BudgetDefaultFile.dat';

  fBudgetImportExport.SetDefaultFileLocation('CLT00001', 'test001.csv');
  fBudgetImportExport.SetDefaultFileLocation('CLT00011', 'test011.csv');
  fBudgetImportExport.SetDefaultFileLocation('CLT00005', 'test005.csv');

  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00001') = 'test001.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00005') = 'test005.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00010') = 'c:\test\test010.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00011') = 'test011.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00002') = 'c:\test\test002.csv');
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.TestExportBudget;
const
  BUDGET_FILE = 'BudgetFile.csv';
var
  BudgetData : TBudgetData;
  PassedMsg : string;
  ResExpBudget : boolean;
  TestFile : Text;
  LineStr : string;
begin
  // Include Unused Chart Codes Test
  BudgetData := CreateBudgetData;
  ResExpBudget := fBudgetImportExport.ExportBudget(BUDGET_FILE,
                                                   true,
                                                   BudgetData,
                                                   1,
                                                   PassedMsg);

  AssignFile(TestFile, BUDGET_FILE);
  Reset(TestFile);
  try
    Readln(TestFile, LineStr);
    Check(LineStr = '"Account","Description","Total","Jan 00","Feb 00","Mar 00","Apr 00","May 00","Jun 00","Jul 00","Aug 00","Sep 00","Oct 00","Nov 00","Dec 00"');

    Readln(TestFile, LineStr);
    Check(LineStr = '"001","Test Description 001",7800,100,200,300,400,500,600,700,800,900,1000,1100,1200');

    Readln(TestFile, LineStr);
    Check(LineStr = '"002","0123456789012345678901234567890123456789",0,0,0,0,0,0,0,0,0,0,0,0,0');

    Readln(TestFile, LineStr);
    Check(LineStr = '"003","Test Description 003",4200,0,200,0,400,0,600,0,800,0,1000,0,1200');
  finally
    closefile(TestFile);
  end;

  // Don't Include Unused Chart Codes Test
  BudgetData := CreateBudgetData;
  ResExpBudget := fBudgetImportExport.ExportBudget(BUDGET_FILE,
                                                   false,
                                                   BudgetData,
                                                   1,
                                                   PassedMsg);

  AssignFile(TestFile, BUDGET_FILE);
  Reset(TestFile);
  try
    Readln(TestFile, LineStr);
    Check(LineStr = '"Account","Description","Total","Jan 00","Feb 00","Mar 00","Apr 00","May 00","Jun 00","Jul 00","Aug 00","Sep 00","Oct 00","Nov 00","Dec 00"');

    Readln(TestFile, LineStr);
    Check(LineStr = '"001","Test Description 001",7800,100,200,300,400,500,600,700,800,900,1000,1100,1200');

    Readln(TestFile, LineStr);
    Check(LineStr = '"003","Test Description 003",4200,0,200,0,400,0,600,0,800,0,1000,0,1200');
  finally
    closefile(TestFile);
  end;
end;

//------------------------------------------------------------------------------
initialization
  TestFramework.RegisterTest(TBudgetImportExportTestCase.Suite);

end.

