program bk5test;

uses
  Forms,
  LockUtils,
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
  utAuditTrail in '..\Tests\utAuditTrail.pas',
  utBudgetImportExport in '..\Tests\utBudgetImportExport.pas',
  utBGL360 in '..\Tests\utBGL360.pas',
  utSimpleFundX in '..\Tests\utSimpleFundX.pas',
  utInstitutionCol in '..\Tests\utInstitutionCol.pas',
  utToDo in '..\Tests\utToDo.pas',
  utBudget in '..\Tests\utBudget.pas',
  utTPRExtact in '..\Tests\utTPRExtact.pas',
  utCashbookChartExport in '..\Tests\utCashbookChartExport.pas',
  utSuggestedMems in '..\Tests\utSuggestedMems.pas',
  utPracticeLedger in '..\Tests\utPracticeLedger.pas',
  utPromoWindow in '..\Tests\utPromoWindow.pas',
  utPromoDisplayForm in '..\Tests\utPromoDisplayForm.pas';

{$R *.RES}

begin
  InitLocking;
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.

