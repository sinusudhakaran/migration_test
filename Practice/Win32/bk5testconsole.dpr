program bk5testconsole;

uses
  LockUtils,
  TestFrameWork,
  TextTestRunner,

  utFileExtensionUtils in '..\Tests\utFileExtensionUtils.pas',
  utGUIReportSchedule in '..\Tests\utGUIReportSchedule.pas',
  utMemorisationsObj in '..\Tests\utMemorisationsObj.pas',
  UTmxUtils in '..\Tests\UTmxUtils.pas',
  utMYOB in '..\Tests\utMYOB.pas',
  utPayeeObj in '..\Tests\utPayeeObj.pas',
  utUpgrade in '..\Tests\utUpgrade.pas',
  utWebXOffice in '..\Tests\utWebXOffice.pas',
//  utAuditTrail in '..\Tests\utAuditTrail.pas',
  utBudgetImportExport in '..\Tests\utBudgetImportExport.pas',
//  utBGL360 in '..\Tests\utBGL360.pas',
  utSimpleFund360Bulk in '..\Tests\utSimpleFund360Bulk.pas',
  utSimpleFundX in '..\Tests\utSimpleFundX.pas',
  utInstitutionCol in '..\Tests\utInstitutionCol.pas',
  utToDo in '..\Tests\utToDo.pas',
  utBudget in '..\Tests\utBudget.pas',
  utTPRExtact in '..\Tests\utTPRExtact.pas',
  utCashbookChartExport in '..\Tests\utCashbookChartExport.pas',
  utSuggestedMems in '..\Tests\utSuggestedMems.pas',
  utPracticeLedger in '..\Tests\utPracticeLedger.pas';

{$R *.res}
begin
  InitLocking;
  TextTestRunner.RunRegisteredTests(rxbHaltOnFailures);
end.
