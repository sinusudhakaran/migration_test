program TestApp;

uses
  Forms,
  UnitTest in 'UnitTest.pas' {TestForm},
  UsageDataReporting in 'UsageDataReporting.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
end.
