unit utInstitutionCol;
{$TYPEINFO ON} //Needed for classes with published methods
//------------------------------------------------------------------------------
interface
uses
  TestFramework,  //DUnit
  classes,
  InstitutionCol,
  BanklinkOnlineServices;

//------------------------------------------------------------------------------
type
 TInstitutionColTestCase = class(TTestCase)
 private
   fInstitutions : TInstitutions;
   fBloArrayOfInstitution : TBloArrayOfInstitution;

   procedure CreateTestCoreData();
   procedure FreeTestCoreData();
   procedure CreateTestMappingFile(aFilePath : string);
 protected
   procedure Setup; override;
   procedure TearDown; override;
 published
   procedure TestFillDataFromBlopi;
   procedure TestLoadFromFile;
   procedure TestFindItem;
 end;

//------------------------------------------------------------------------------
implementation

uses
  SysUtils;

{ TInstitutionColTestCase }
//------------------------------------------------------------------------------
procedure TInstitutionColTestCase.CreateTestCoreData;
begin
  SetLength(fBloArrayOfInstitution, 4);
  fBloArrayOfInstitution[0] := TBloInstitution.Create;
  fBloArrayOfInstitution[0].AccountEditMask := 'LLA000000099999;0;';
  fBloArrayOfInstitution[0].Active          := true;
  fBloArrayOfInstitution[0].Attachments     := 'Attachment 01';
  fBloArrayOfInstitution[0].BSBTip          := 'BSBTip 01';
  fBloArrayOfInstitution[0].BrandName       := 'BrandName 01';
  fBloArrayOfInstitution[0].CanImportData   := 1;
  fBloArrayOfInstitution[0].Code            := 'Code01';
  fBloArrayOfInstitution[0].CountryCode     := 'NZ';
  fBloArrayOfInstitution[0].HelpfulHints    := 'Hint 01';
  fBloArrayOfInstitution[0].Historical      := 'Historical 01';
  fBloArrayOfInstitution[0].Name_           := 'Name 01';
  fBloArrayOfInstitution[0].TypeCode        := 'TypeCode 01';
  fBloArrayOfInstitution[0].TypeDescription := 'TypeDescription 01';

  fBloArrayOfInstitution[1] := TBloInstitution.Create;
  fBloArrayOfInstitution[1].AccountEditMask := '00000000000009999999;0;';
  fBloArrayOfInstitution[1].Active          := true;
  fBloArrayOfInstitution[1].Attachments     := 'Attachment 02';
  fBloArrayOfInstitution[1].BSBTip          := 'BSBTip 02';
  fBloArrayOfInstitution[1].BrandName       := 'BrandName 02';
  fBloArrayOfInstitution[1].CanImportData   := 0;
  fBloArrayOfInstitution[1].Code            := 'Code02';
  fBloArrayOfInstitution[1].CountryCode     := 'NZ';
  fBloArrayOfInstitution[1].HelpfulHints    := 'Hint 02';
  fBloArrayOfInstitution[1].Historical      := 'Historical 02';
  fBloArrayOfInstitution[1].Name_           := 'Name 02';
  fBloArrayOfInstitution[1].TypeCode        := 'TypeCode 02';
  fBloArrayOfInstitution[1].TypeDescription := 'TypeDescription 02';

  fBloArrayOfInstitution[2] := TBloInstitution.Create;
  fBloArrayOfInstitution[2].AccountEditMask := '\0\3-0000-0000000-\000;0;';
  fBloArrayOfInstitution[2].Active          := true;
  fBloArrayOfInstitution[2].Attachments     := 'Attachment 03';
  fBloArrayOfInstitution[2].BSBTip          := 'BSBTip 03';
  fBloArrayOfInstitution[2].BrandName       := 'BrandName 03';
  fBloArrayOfInstitution[2].CanImportData   := 1;
  fBloArrayOfInstitution[2].Code            := 'Code03';
  fBloArrayOfInstitution[2].CountryCode     := 'AU';
  fBloArrayOfInstitution[2].HelpfulHints    := 'Hint 03';
  fBloArrayOfInstitution[2].Historical      := 'Historical 03';
  fBloArrayOfInstitution[2].Name_           := 'Name 03';
  fBloArrayOfInstitution[2].TypeCode        := 'TypeCode 03';
  fBloArrayOfInstitution[2].TypeDescription := 'TypeDescription 03';

  fBloArrayOfInstitution[3] := TBloInstitution.Create;
  fBloArrayOfInstitution[3].AccountEditMask := '\9\4\1\-000\ 000000000;0;';
  fBloArrayOfInstitution[3].Active          := true;
  fBloArrayOfInstitution[3].Attachments     := 'Attachment 04';
  fBloArrayOfInstitution[3].BSBTip          := 'BSBTip 04';
  fBloArrayOfInstitution[3].BrandName       := 'BrandName 04';
  fBloArrayOfInstitution[3].CanImportData   := 1;
  fBloArrayOfInstitution[3].Code            := 'Code04';
  fBloArrayOfInstitution[3].CountryCode     := 'UK';
  fBloArrayOfInstitution[3].HelpfulHints    := 'Hint 04';
  fBloArrayOfInstitution[3].Historical      := 'Historical 04';
  fBloArrayOfInstitution[3].Name_           := 'Name 04';
  fBloArrayOfInstitution[3].TypeCode        := 'TypeCode 04';
  fBloArrayOfInstitution[3].TypeDescription := 'TypeDescription 04';
end;

//------------------------------------------------------------------------------
procedure TInstitutionColTestCase.FreeTestCoreData;
var
  InstIndex : integer;
begin
  for InstIndex := 0 to length(fBloArrayOfInstitution) - 1 do
    FreeAndNil(fBloArrayOfInstitution[InstIndex]);
  setlength(fBloArrayOfInstitution,0);
end;

//------------------------------------------------------------------------------
procedure TInstitutionColTestCase.CreateTestMappingFile(aFilePath: string);
var
  TestFile : Text;
begin
  AssignFile(TestFile, aFilePath);
  Rewrite(TestFile);
  try
    Writeln(TestFile, 'CODE, NAME, COUNTRY_CODE, ENABLED, RURAL_MAIN_CODE, NEW_NAME, NEW_MASK, IGNORE_VALIDATION, SHOW_ADDFORM,');
    Writeln(TestFile, 'Code04,Name 04,UK,1, ,New Name 04,MASK01,0,0,');
    Writeln(TestFile, 'Code01,Name 01,NZ,0, , , ,1,0,');
    Writeln(TestFile, 'Code02,Name 02,NZ,1,Code01, , ,0,0,');
    Writeln(TestFile, 'Code03,Name 03,AU,1, ,New Name 03, ,0,0,');  
  finally
    closefile(TestFile);
  end;
end;

//------------------------------------------------------------------------------
procedure TInstitutionColTestCase.Setup;
begin
  inherited;
  fInstitutions := TInstitutions.create(TInstitutionItem);
  CreateTestCoreData();
end;

//------------------------------------------------------------------------------
procedure TInstitutionColTestCase.TearDown;
begin
  FreeAndNil(fInstitutions);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TInstitutionColTestCase.TestFillDataFromBlopi;
begin
  CreateTestCoreData;
  try
    fInstitutions.FillDataFromBlopi(fBloArrayOfInstitution);

    Check(fInstitutions.Count = 4);

    Check(TInstitutionItem(fInstitutions.Items[0]).AccountEditMask = 'LLA000000099999;0;');
    Check(TInstitutionItem(fInstitutions.Items[0]).Active = true);
    Check(TInstitutionItem(fInstitutions.Items[0]).Attachments = 'Attachment 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).BSBTip = 'BSBTip 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).BrandName = 'BrandName 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).CanImportData = 1);
    Check(TInstitutionItem(fInstitutions.Items[0]).Code = 'Code01');
    Check(TInstitutionItem(fInstitutions.Items[0]).CountryCode = 'NZ');
    Check(TInstitutionItem(fInstitutions.Items[0]).HelpfulHints = 'Hint 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).Historical = 'Historical 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).Name = 'Name 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).TypeCode = 'TypeCode 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).TypeDescription = 'TypeDescription 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).Enabled = true);
    Check(TInstitutionItem(fInstitutions.Items[0]).HasRuralCode = false);
    Check(TInstitutionItem(fInstitutions.Items[0]).RuralCode = '');
    Check(TInstitutionItem(fInstitutions.Items[0]).HasNewName = false);
    Check(TInstitutionItem(fInstitutions.Items[0]).NewName = '');
    Check(TInstitutionItem(fInstitutions.Items[0]).HasNewMask = false);
    Check(TInstitutionItem(fInstitutions.Items[0]).NewMask = '');
    Check(TInstitutionItem(fInstitutions.Items[0]).IgnoreValidation = false);
    Check(TInstitutionItem(fInstitutions.Items[0]).ShowAdditionalForms = false);

    Check(TInstitutionItem(fInstitutions.Items[1]).AccountEditMask = '00000000000009999999;0;');
    Check(TInstitutionItem(fInstitutions.Items[1]).Active = true);
    Check(TInstitutionItem(fInstitutions.Items[1]).Attachments = 'Attachment 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).BSBTip = 'BSBTip 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).BrandName = 'BrandName 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).CanImportData = 0);
    Check(TInstitutionItem(fInstitutions.Items[1]).Code = 'Code02');
    Check(TInstitutionItem(fInstitutions.Items[1]).CountryCode = 'NZ');
    Check(TInstitutionItem(fInstitutions.Items[1]).HelpfulHints = 'Hint 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).Historical = 'Historical 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).Name = 'Name 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).TypeCode = 'TypeCode 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).TypeDescription = 'TypeDescription 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).Enabled = true);
    Check(TInstitutionItem(fInstitutions.Items[1]).HasRuralCode = false);
    Check(TInstitutionItem(fInstitutions.Items[1]).RuralCode = '');
    Check(TInstitutionItem(fInstitutions.Items[1]).HasNewName = false);
    Check(TInstitutionItem(fInstitutions.Items[1]).NewName = '');
    Check(TInstitutionItem(fInstitutions.Items[1]).HasNewMask = false);
    Check(TInstitutionItem(fInstitutions.Items[1]).NewMask = '');
    Check(TInstitutionItem(fInstitutions.Items[1]).IgnoreValidation = false);
    Check(TInstitutionItem(fInstitutions.Items[1]).ShowAdditionalForms = false);

    Check(TInstitutionItem(fInstitutions.Items[2]).AccountEditMask = '\0\3-0000-0000000-\000;0;');
    Check(TInstitutionItem(fInstitutions.Items[2]).Active = true);
    Check(TInstitutionItem(fInstitutions.Items[2]).Attachments = 'Attachment 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).BSBTip = 'BSBTip 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).BrandName = 'BrandName 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).CanImportData = 1);
    Check(TInstitutionItem(fInstitutions.Items[2]).Code = 'Code03');
    Check(TInstitutionItem(fInstitutions.Items[2]).CountryCode = 'AU');
    Check(TInstitutionItem(fInstitutions.Items[2]).HelpfulHints = 'Hint 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).Historical = 'Historical 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).Name = 'Name 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).TypeCode = 'TypeCode 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).TypeDescription = 'TypeDescription 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).Enabled = true);
    Check(TInstitutionItem(fInstitutions.Items[2]).HasRuralCode = false);
    Check(TInstitutionItem(fInstitutions.Items[2]).RuralCode = '');
    Check(TInstitutionItem(fInstitutions.Items[2]).HasNewName = false);
    Check(TInstitutionItem(fInstitutions.Items[2]).NewName = '');
    Check(TInstitutionItem(fInstitutions.Items[2]).HasNewMask = false);
    Check(TInstitutionItem(fInstitutions.Items[2]).NewMask = '');
    Check(TInstitutionItem(fInstitutions.Items[2]).IgnoreValidation = false);
    Check(TInstitutionItem(fInstitutions.Items[2]).ShowAdditionalForms = false);

    Check(TInstitutionItem(fInstitutions.Items[3]).AccountEditMask = '\9\4\1\-000\ 000000000;0;');
    Check(TInstitutionItem(fInstitutions.Items[3]).Active = true);
    Check(TInstitutionItem(fInstitutions.Items[3]).Attachments = 'Attachment 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).BSBTip = 'BSBTip 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).BrandName = 'BrandName 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).CanImportData = 1);
    Check(TInstitutionItem(fInstitutions.Items[3]).Code = 'Code04');
    Check(TInstitutionItem(fInstitutions.Items[3]).CountryCode = 'UK');
    Check(TInstitutionItem(fInstitutions.Items[3]).HelpfulHints = 'Hint 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).Historical = 'Historical 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).Name = 'Name 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).TypeCode = 'TypeCode 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).TypeDescription = 'TypeDescription 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).Enabled = true);
    Check(TInstitutionItem(fInstitutions.Items[3]).HasRuralCode = false);
    Check(TInstitutionItem(fInstitutions.Items[3]).RuralCode = '');
    Check(TInstitutionItem(fInstitutions.Items[3]).HasNewName = false);
    Check(TInstitutionItem(fInstitutions.Items[3]).NewName = '');
    Check(TInstitutionItem(fInstitutions.Items[3]).HasNewMask = false);
    Check(TInstitutionItem(fInstitutions.Items[3]).NewMask = '');
    Check(TInstitutionItem(fInstitutions.Items[3]).IgnoreValidation = false);
    Check(TInstitutionItem(fInstitutions.Items[3]).ShowAdditionalForms = false);
  finally
    FreeTestCoreData;
  end;
end;

//------------------------------------------------------------------------------
procedure TInstitutionColTestCase.TestLoadFromFile;
const
  INSTCOL_FILE = 'InstitutionColFile.csv';
begin
  CreateTestCoreData;
  try
    fInstitutions.FillDataFromBlopi(fBloArrayOfInstitution);
    CreateTestMappingFile(INSTCOL_FILE);

    fInstitutions.LoadFromFile(INSTCOL_FILE);

    Check(fInstitutions.Count = 4);

    Check(TInstitutionItem(fInstitutions.Items[0]).Code = 'Code01');
    Check(TInstitutionItem(fInstitutions.Items[0]).CountryCode = 'NZ');
    Check(TInstitutionItem(fInstitutions.Items[0]).Name = 'Name 01');
    Check(TInstitutionItem(fInstitutions.Items[0]).Enabled = false);
    Check(TInstitutionItem(fInstitutions.Items[0]).HasRuralCode = false);
    Check(TInstitutionItem(fInstitutions.Items[0]).RuralCode = ' ');
    Check(TInstitutionItem(fInstitutions.Items[0]).HasNewName = false);
    Check(TInstitutionItem(fInstitutions.Items[0]).NewName = ' ');
    Check(TInstitutionItem(fInstitutions.Items[0]).HasNewMask = false);
    Check(TInstitutionItem(fInstitutions.Items[0]).NewMask = ' ');
    Check(TInstitutionItem(fInstitutions.Items[0]).IgnoreValidation = true);

    Check(TInstitutionItem(fInstitutions.Items[1]).Code = 'Code02');
    Check(TInstitutionItem(fInstitutions.Items[1]).CountryCode = 'NZ');
    Check(TInstitutionItem(fInstitutions.Items[1]).Name = 'Name 02');
    Check(TInstitutionItem(fInstitutions.Items[1]).Enabled = true);
    Check(TInstitutionItem(fInstitutions.Items[1]).HasRuralCode = true);
    Check(TInstitutionItem(fInstitutions.Items[1]).RuralCode = 'Code01');
    Check(TInstitutionItem(fInstitutions.Items[1]).HasNewName = false);
    Check(TInstitutionItem(fInstitutions.Items[1]).NewName = ' ');
    Check(TInstitutionItem(fInstitutions.Items[1]).HasNewMask = false);
    Check(TInstitutionItem(fInstitutions.Items[1]).NewMask = ' ');
    Check(TInstitutionItem(fInstitutions.Items[1]).IgnoreValidation = false);

    Check(TInstitutionItem(fInstitutions.Items[2]).Code = 'Code03');
    Check(TInstitutionItem(fInstitutions.Items[2]).CountryCode = 'AU');
    Check(TInstitutionItem(fInstitutions.Items[2]).Name = 'Name 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).Enabled = true);
    Check(TInstitutionItem(fInstitutions.Items[2]).HasRuralCode = false);
    Check(TInstitutionItem(fInstitutions.Items[2]).RuralCode = ' ');
    Check(TInstitutionItem(fInstitutions.Items[2]).HasNewName = true);
    Check(TInstitutionItem(fInstitutions.Items[2]).NewName = 'New Name 03');
    Check(TInstitutionItem(fInstitutions.Items[2]).HasNewMask = false);
    Check(TInstitutionItem(fInstitutions.Items[2]).NewMask = ' ');
    Check(TInstitutionItem(fInstitutions.Items[2]).IgnoreValidation = false);

    Check(TInstitutionItem(fInstitutions.Items[3]).Code = 'Code04');
    Check(TInstitutionItem(fInstitutions.Items[3]).CountryCode = 'UK');
    Check(TInstitutionItem(fInstitutions.Items[3]).Name = 'Name 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).Enabled = true);
    Check(TInstitutionItem(fInstitutions.Items[3]).HasRuralCode = false);
    Check(TInstitutionItem(fInstitutions.Items[3]).RuralCode = ' ');
    Check(TInstitutionItem(fInstitutions.Items[3]).HasNewName = true);
    Check(TInstitutionItem(fInstitutions.Items[3]).NewName = 'New Name 04');
    Check(TInstitutionItem(fInstitutions.Items[3]).HasNewMask = true);
    Check(TInstitutionItem(fInstitutions.Items[3]).NewMask = 'MASK01');
    Check(TInstitutionItem(fInstitutions.Items[3]).IgnoreValidation = false);

  finally
    FreeTestCoreData;
  end;
end;

//------------------------------------------------------------------------------
procedure TInstitutionColTestCase.TestFindItem;
var
  FoundInstitutionItem : TInstitutionItem;
begin
  CreateTestCoreData;
  try
    fInstitutions.FillDataFromBlopi(fBloArrayOfInstitution);

    check(fInstitutions.FindItem('','',FoundInstitutionItem) = false);

    check(fInstitutions.FindItem('Code03','AU',FoundInstitutionItem) = true);
    check(assigned(FoundInstitutionItem) = true);
    check(FoundInstitutionItem.Name = 'Name 03');

    check(fInstitutions.FindItem('Code04','UK',FoundInstitutionItem) = true);
    check(assigned(FoundInstitutionItem) = true);
    check(FoundInstitutionItem.Name = 'Name 04');

    check(fInstitutions.FindItem('Code02','NZ',FoundInstitutionItem) = true);
    check(assigned(FoundInstitutionItem) = true);
    check(FoundInstitutionItem.Name = 'Name 02');
  finally
    FreeTestCoreData;
  end;
end;

//------------------------------------------------------------------------------
initialization
  TestFramework.RegisterTest(TInstitutionColTestCase.Suite);

end.

