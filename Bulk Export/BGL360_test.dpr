program BGL360_test;

uses
  Forms,
  TestFrameWork,
  GUITestRunner,
  utSimpleFund360Bulk;

{$R *.RES}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.

