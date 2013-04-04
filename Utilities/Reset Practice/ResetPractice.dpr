program ResetPractice;

uses
  Forms,
  FResetPractice;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmResetPractice, frmResetPractice);
  Application.Run;
end.
