program bk5testconsole;

uses
  TestFrameWork,
  TextTestRunner,
  utWebXOffice in 'Tests\utWebXOffice.pas',
  utMemorisationsObj in 'Tests\utMemorisationsObj.pas',
  UTmxUtils in 'Tests\UTmxUtils.pas',
  utPayeeObj in 'Tests\utPayeeObj.pas',
  utMYOB in 'Tests\utMYOB.pas',
  utGUIReportSchedule in 'Tests\utGUIReportSchedule.pas',
  utUpgrade in 'Tests\utUpgrade.pas',
  utFileExtensionUtils in 'Tests\utFileExtensionUtils.pas';

{$R *.res}

begin
  TextTestRunner.RunRegisteredTests(rxbHaltOnFailures);

end.
