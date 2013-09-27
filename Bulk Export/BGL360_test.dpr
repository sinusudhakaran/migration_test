program BGL360_test;

uses
  Forms,
  TestFrameWork,
  GUITestRunner,
  utSimpleFund360Bulk in '..\Practice\Tests\utSimpleFund360Bulk.pas';

{$R *.RES}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.

