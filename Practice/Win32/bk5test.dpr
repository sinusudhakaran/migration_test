program bk5test;

uses
  Forms,
  TestFrameWork,
  GUITestRunner,
  utWebXOffice in 'Tests\utWebXOffice.pas',
  utPayeeObj in 'tests\utPayeeObj.pas',
  UTmxUtils in 'Tests\UTmxUtils.pas',
  utMemorisationsObj in 'Tests\utMemorisationsObj.pas',
  utGUIReportSchedule in 'Tests\utGUIReportSchedule.pas',
  utMYOB in 'Tests\utMYOB.pas',
  utUpgrade in 'Tests\utUpgrade.pas',
  utFileExtensionUtils in 'Tests\utFileExtensionUtils.pas';

{$R *.RES}

begin
 Application.Initialize;
 GUITestRunner.RunRegisteredTests;
end.

