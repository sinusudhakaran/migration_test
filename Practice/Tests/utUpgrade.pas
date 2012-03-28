unit utUpgrade;
{$TYPEINFO ON} //Needed for classes with published methods
interface
uses
  TestFramework,  //DUnit
  SyDefs,
  SysUtils,
  Windows;

type
  TUpgradeTestCase = class(TTestCase)
  private
    procedure SetupNewAdminSystem;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestUpgradesFrom90to99;
  end;


implementation

uses
  Admin32,
  bkConst,
  DBCreate,
  globals,
  SycfIO,
  ReportTypes,
  upgrade;

{ TUpgradeTestCase }

procedure TUpgradeTestCase.Setup;
begin
  inherited;
  SetupNewAdminSystem;
end;

procedure TUpgradeTestCase.SetupNewAdminSystem;
begin
  //Setup a new Admin System so we can test upgrading it.
  NewAdminSystem(whNewZealand, 'UPGRADETEST', 'Test Admin system for unit testing');
end;

procedure TUpgradeTestCase.TearDown;
begin
  inherited;
  FreeAndNil(AdminSystem);
end;

procedure TUpgradeTestCase.TestUpgradesFrom90to99;
const
  InitialVersion = 90;
  LatestCheckVersion = 99;
begin
  AdminSystem.fdFields.fdFile_Version := InitialVersion;
  //Need to delete ClientTypes (since they are added during upgrade)
  AdminSystem.fdSystem_Client_Type_List.DeleteAll;
  AdminSystem.fdFields.fdClient_Type_LRN_Counter := 0;
  UpgradeAdminToLatestVersion;
  //Check 94 Upgrade (Update Processing Stats)
  //Can't check without having client files.

  //Check 96 Update (Client Types)
  //Check 8 are there
  CheckEquals(9, AdminSystem.fdSystem_Client_Type_List.ItemCount, 'Client Type List Count incorrect');
  //Test to make sure this one isn't there (also checks tests)
  CheckEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('Test')), 'Test Client Type Found');
  //Check the correct ones are there
  CheckNotEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('Coding Report')), 'Coding Report not Found');
  CheckNotEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('Notes')), 'Notes not Found');
  CheckNotEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('Books')), 'Books not Found');
  CheckNotEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('Books Secure')), 'Books Secure not Found');
  CheckNotEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('CodeIT')), 'CodeIT not Found');
  CheckNotEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('GST')), 'GST not Found');
  CheckNotEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('Annual')), 'Annual not Found');
  CheckNotEquals(0, Integer(AdminSystem.fdSystem_Client_Type_List.FindName('GST/Coding Report')), 'GST/Coding Report not Found');

  //Check 97 Upgrade (XML Header and Footers)
  //Check to see if XML file exists
  Check(FileExists(ReportTypesFilename), 'XML Report Types missing');

  //Check 98 Upgrade (Checking Client Account Map)
  //Can't check without having client files.

end;

initialization
  TestFramework.RegisterTest(TUpgradeTestCase.Suite);
end.
