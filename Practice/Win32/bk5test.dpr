program bk5test;

uses
  Forms,
  TestFrameWork,
  GUITestRunner,
  utFileExtensionUtils in '..\Tests\utFileExtensionUtils.pas',
  utGUIReportSchedule in '..\Tests\utGUIReportSchedule.pas',
  utMemorisationsObj in '..\Tests\utMemorisationsObj.pas',
  UTmxUtils in '..\Tests\UTmxUtils.pas',
  utMYOB in '..\Tests\utMYOB.pas',
  utPayeeObj in '..\Tests\utPayeeObj.pas',
  utUpgrade in '..\Tests\utUpgrade.pas',
  utWebXOffice in '..\Tests\utWebXOffice.pas',
  utAuditTrail in '..\Tests\utAuditTrail.pas' {/utBudgetImportExport in '..\Tests\utBudgetImportExport.pas';},
  utBudgetImportExport in '..\Tests\utBudgetImportExport.pas',
  utBGL360 in '..\Tests\utBGL360.pas',
  utTestTemplate in '..\Tests\utTestTemplate.pas',
  utSimpleFundX in '..\Tests\utSimpleFundX.pas';

{$R *.RES}

begin
 Application.Initialize;
 GUITestRunner.RunRegisteredTests;
end.

