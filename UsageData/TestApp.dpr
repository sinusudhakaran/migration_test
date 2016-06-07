program TestApp;

uses
  Forms,
  UnitTest in 'UnitTest.pas' {TestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTestForm, TestForm);
  Application.Run;
end.
