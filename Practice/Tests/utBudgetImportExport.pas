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
   procedure CreateBudgetFile(aFilePath : string);
   function CreateBudgetData : TBudgetData;
 protected
   procedure Setup; override;
   procedure TearDown; override;
 published
   procedure TestGetDefaultFileLocation;
   procedure TestSetDefaultFileLocation;
   procedure TestExportBudget;
   procedure TestImportBudget;
   procedure TestCopyBudget;
 end;

//------------------------------------------------------------------------------
implementation

uses
  BUDOBJ32;

{ TPayeesTestCase }
//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.CreateBudgetDefaultFile;
var
  BudgetDefaults: TStringList;
begin
  BudgetDefaults := TStringList.create;
  try
    BudgetDefaults.Add('CLT00001' + ',' + 'Budget001' + ',' + 'c:\test\test001_001.csv');
    BudgetDefaults.Add('CLT00001' + ',' + 'Budget002' + ',' + 'c:\test\test001_002.csv');
    BudgetDefaults.Add('CLT00001' + ',' + 'Budget003' + ',' + 'c:\test\test001_003.csv');
    BudgetDefaults.Add('CLT00002' + ',' + 'Budget001' + ',' + 'c:\test\test002_001.csv');
    BudgetDefaults.Add('CLT00002' + ',' + 'Budget002' + ',' + 'c:\test\test002_002.csv');
    BudgetDefaults.Add('CLT00003' + ',' + 'Budget001' + ',' + 'c:\test\test003_001.csv');
    BudgetDefaults.Add('CLT00004' + ',' + 'Budget001' + ',' + 'c:\test\test004_001.csv');
    BudgetDefaults.Add('CLT00004' + ',' + 'Budget002' + ',' + 'c:\test\test004_002.csv');
    BudgetDefaults.Add('CLT00004' + ',' + 'Budget003' + ',' + 'c:\test\test004_003.csv');
    BudgetDefaults.Add('CLT00005' + ',' + 'Budget001' + ',' + 'c:\test\test005_001.csv');

    BudgetDefaults.SaveToFile('BudgetDefaultFile.dat');
  finally
    BudgetDefaults.free;
  end;
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.CreateBudgetFile(aFilePath : string);
var
  TestFile : Text;
begin
  AssignFile(TestFile, aFilePath);
  Rewrite(TestFile);
  try
    Writeln(TestFile, '"Account","Description","Total","Jan 00","Feb 00","Mar 00","Apr 00","May 00","Jun 00","Jul 00","Aug 00","Sep 00","Oct 00","Nov 00","Dec 00"');
    Writeln(TestFile, '"001","New Values",17800,1100,1200,1300,1400,1500,1600,1700,1800,1900,11000,11100,11200');
    Writeln(TestFile, '"003","Cleared Values",0,0,0,0,0,0,0,0,0,0,0,0,0');
    Writeln(TestFile, '"004","Not Found",14200,0,200,0,400,0,600,0,800,0,1000,0,1200');
    Writeln(TestFile, '"005","Not Found",4200,0,200,0,2400,0,600,0,800,0,1000,0,1200');
  finally
    closefile(TestFile);
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
  Result[0].bIsPosting := false;

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
  Result[1].bIsPosting := true;

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
  Result[2].bIsPosting := true;

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

  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00001','Budget001') = 'c:\test\test001_001.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00004','Budget003') = 'c:\test\test004_003.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00005','Budget001') = 'c:\test\test005_001.csv');
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.TestSetDefaultFileLocation;
begin
  fBudgetImportExport.BudgetDefaultFile := 'BudgetDefaultFile.dat';

  fBudgetImportExport.SetDefaultFileLocation('CLT00001', 'Budget004', 'test001_004.csv');
  fBudgetImportExport.SetDefaultFileLocation('CLT00006', 'Budget001', 'test006_001.csv');
  fBudgetImportExport.SetDefaultFileLocation('CLT00003', 'Budget002', 'test003_002.csv');

  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00001','Budget001') = 'c:\test\test001_001.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00004','Budget003') = 'c:\test\test004_003.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00005','Budget001') = 'c:\test\test005_001.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00001','Budget004') = 'test001_004.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00006','Budget001') = 'test006_001.csv');
  Check(fBudgetImportExport.GetDefaultFileLocation('CLT00003','Budget002') = 'test003_002.csv');
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.TestCopyBudget;
var
  BudgetData : TBudgetData;
  BudgetDataCopy : TBudgetData;
  BudgetIndex : integer;
begin
  BudgetData := CreateBudgetData;

  BudgetDataCopy := fBudgetImportExport.CopyBudgetData(BudgetData, false, -1); // the third parameter is unnecessary when second parameter is false, see CopyBudgetData

  for BudgetIndex := 0 to Length(BudgetData) - 1 do
  begin
    Check(BudgetData[BudgetIndex].bAccount     = BudgetDataCopy[BudgetIndex].bAccount);
    Check(BudgetData[BudgetIndex].bDesc        = BudgetDataCopy[BudgetIndex].bDesc);
    Check(BudgetData[BudgetIndex].bTotal       = BudgetDataCopy[BudgetIndex].bTotal);
    Check(BudgetData[BudgetIndex].bAmounts[1]  = BudgetDataCopy[BudgetIndex].bAmounts[1]);
    Check(BudgetData[BudgetIndex].bAmounts[2]  = BudgetDataCopy[BudgetIndex].bAmounts[2]);
    Check(BudgetData[BudgetIndex].bAmounts[3]  = BudgetDataCopy[BudgetIndex].bAmounts[3]);
    Check(BudgetData[BudgetIndex].bAmounts[4]  = BudgetDataCopy[BudgetIndex].bAmounts[4]);
    Check(BudgetData[BudgetIndex].bAmounts[5]  = BudgetDataCopy[BudgetIndex].bAmounts[5]);
    Check(BudgetData[BudgetIndex].bAmounts[6]  = BudgetDataCopy[BudgetIndex].bAmounts[6]);
    Check(BudgetData[BudgetIndex].bAmounts[7]  = BudgetDataCopy[BudgetIndex].bAmounts[7]);
    Check(BudgetData[BudgetIndex].bAmounts[8]  = BudgetDataCopy[BudgetIndex].bAmounts[8]);
    Check(BudgetData[BudgetIndex].bAmounts[9]  = BudgetDataCopy[BudgetIndex].bAmounts[9]);
    Check(BudgetData[BudgetIndex].bAmounts[10] = BudgetDataCopy[BudgetIndex].bAmounts[10]);
    Check(BudgetData[BudgetIndex].bAmounts[11] = BudgetDataCopy[BudgetIndex].bAmounts[11]);
    Check(BudgetData[BudgetIndex].bAmounts[12] = BudgetDataCopy[BudgetIndex].bAmounts[12]);
  end;
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
                                                   PassedMsg,
                                                   True);

  AssignFile(TestFile, BUDGET_FILE);
  Reset(TestFile);
  try
    Readln(TestFile, LineStr);
    Check(LineStr = '"Account","Description","Total","Jan 00","Feb 00","Mar 00","Apr 00","May 00","Jun 00","Jul 00","Aug 00","Sep 00","Oct 00","Nov 00","Dec 00"');

    Readln(TestFile, LineStr);
    Check(LineStr = '"001","Test Description 001",,,,,,,,,,,,,'); // No amounts or total for non posting codes

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
                                                   PassedMsg,
                                                   True);

  AssignFile(TestFile, BUDGET_FILE);
  Reset(TestFile);
  try
    Readln(TestFile, LineStr);
    Check(LineStr = '"Account","Description","Total","Jan 00","Feb 00","Mar 00","Apr 00","May 00","Jun 00","Jul 00","Aug 00","Sep 00","Oct 00","Nov 00","Dec 00"');

    Readln(TestFile, LineStr);
    Check(LineStr = '"001","Test Description 001",,,,,,,,,,,,,'); // No amounts or total for non posting codes

    Readln(TestFile, LineStr);
    Check(LineStr = '"003","Test Description 003",4200,0,200,0,400,0,600,0,800,0,1000,0,1200');
  finally
    closefile(TestFile);
  end;

  // Don't Include Non-Posting Codes Test
  BudgetData := CreateBudgetData;
  ResExpBudget := fBudgetImportExport.ExportBudget(BUDGET_FILE,
                                                   true,
                                                   BudgetData,
                                                   1,
                                                   PassedMsg,
                                                   False);

  AssignFile(TestFile, BUDGET_FILE);
  Reset(TestFile);
  try
    Readln(TestFile, LineStr);
    Check(LineStr = '"Account","Description","Total","Jan 00","Feb 00","Mar 00","Apr 00","May 00","Jun 00","Jul 00","Aug 00","Sep 00","Oct 00","Nov 00","Dec 00"');

    Readln(TestFile, LineStr);
    Check(LineStr = '"002","0123456789012345678901234567890123456789",0,0,0,0,0,0,0,0,0,0,0,0,0');

    Readln(TestFile, LineStr);
    Check(LineStr = '"003","Test Description 003",4200,0,200,0,400,0,600,0,800,0,1000,0,1200');
  finally
    closefile(TestFile);
  end;
end;

//------------------------------------------------------------------------------
procedure TBudgetImportExportTestCase.TestImportBudget;
const
  BUDGET_FILE = 'BudgetFile.csv';
  BUDGET_FILE_ERROR = 'BudgetFileError.txt';
var
  BudgetData : TBudgetData;
  ResExpBudget : boolean;
  MsgStr : string;

  RowsImported : integer;
  RowsNotImported : integer;
begin
  // Include Unused Chart Codes Test
  BudgetData := CreateBudgetData;
  CreateBudgetFile(BUDGET_FILE);

  ResExpBudget := fBudgetImportExport.ImportBudget(BUDGET_FILE,
                                                   BUDGET_FILE_ERROR,
                                                   RowsImported,
                                                   RowsNotImported,
                                                   BudgetData,
                                                   MsgStr);

  Check(Length(BudgetData) = 3);

  if Length(BudgetData) = 3 then
  begin
    // Altered Line but is not posting
    Check(BudgetData[0].bAccount = '001');
    Check(BudgetData[0].bDesc = 'Test Description 001');
    Check(BudgetData[0].bTotal = 7800);
    Check(BudgetData[0].bAmounts[1] = 100);
    Check(BudgetData[0].bAmounts[2] = 200);
    Check(BudgetData[0].bAmounts[3] = 300);
    Check(BudgetData[0].bAmounts[4] = 400);
    Check(BudgetData[0].bAmounts[5] = 500);
    Check(BudgetData[0].bAmounts[6] = 600);
    Check(BudgetData[0].bAmounts[7] = 700);
    Check(BudgetData[0].bAmounts[8] = 800);
    Check(BudgetData[0].bAmounts[9] = 900);
    Check(BudgetData[0].bAmounts[10] = 1000);
    Check(BudgetData[0].bAmounts[11] = 1100);
    Check(BudgetData[0].bAmounts[12] = 1200);

    // Unchanged Line
    Check(BudgetData[1].bAccount = '002');
    Check(BudgetData[1].bDesc = '0123456789012345678901234567890123456789');
    Check(BudgetData[1].bTotal = 0);
    Check(BudgetData[1].bAmounts[1] = 0);
    Check(BudgetData[1].bAmounts[2] = 0);
    Check(BudgetData[1].bAmounts[3] = 0);
    Check(BudgetData[1].bAmounts[4] = 0);
    Check(BudgetData[1].bAmounts[5] = 0);
    Check(BudgetData[1].bAmounts[6] = 0);
    Check(BudgetData[1].bAmounts[7] = 0);
    Check(BudgetData[1].bAmounts[8] = 0);
    Check(BudgetData[1].bAmounts[9] = 0);
    Check(BudgetData[1].bAmounts[10] = 0);
    Check(BudgetData[1].bAmounts[11] = 0);
    Check(BudgetData[1].bAmounts[12] = 0);

    // Cleared Value Line
    Check(BudgetData[2].bAccount = '003');
    Check(BudgetData[2].bDesc = 'Test Description 003');
    Check(BudgetData[2].bTotal = 0);
    Check(BudgetData[2].bAmounts[1] = 0);
    Check(BudgetData[2].bAmounts[2] = 0);
    Check(BudgetData[2].bAmounts[3] = 0);
    Check(BudgetData[2].bAmounts[4] = 0);
    Check(BudgetData[2].bAmounts[5] = 0);
    Check(BudgetData[2].bAmounts[6] = 0);
    Check(BudgetData[2].bAmounts[7] = 0);
    Check(BudgetData[2].bAmounts[8] = 0);
    Check(BudgetData[2].bAmounts[9] = 0);
    Check(BudgetData[2].bAmounts[10] = 0);
    Check(BudgetData[2].bAmounts[11] = 0);
    Check(BudgetData[2].bAmounts[12] = 0);
  end;
end;

//------------------------------------------------------------------------------
initialization
  TestFramework.RegisterTest(TBudgetImportExportTestCase.Suite);

end.

