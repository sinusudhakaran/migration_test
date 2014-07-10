program bk5test;

uses
  Forms,
  LockUtils,
  TestFrameWork,
  GUITestRunner,
  ImagesFrm,
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
  utSimpleFund360Bulk in '..\Tests\utSimpleFund360Bulk.pas',
  utSimpleFundX in '..\Tests\utSimpleFundX.pas',
  utInstitutionCol in '..\Tests\utInstitutionCol.pas',
  utToDo in '..\Tests\utToDo.pas',
  utBudget in '..\Tests\utBudget.pas',
  utTPRExtact in '..\Tests\utTPRExtact.pas',
  utRecommendedMems in '..\Tests\utRecommendedMems.pas',
  utCashbookChartExport in '..\Tests\utCashbookChartExport.pas';

{$R *.RES}

begin
  InitLocking;
  Application.Initialize;
  Application.CreateForm(TAppImages, AppImages);
  GUITestRunner.RunRegisteredTests;
end.

