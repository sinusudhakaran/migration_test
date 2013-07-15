program ResetPractice;

uses
  Forms,
  FResetPractice,
  LockUtils;

{$R *.res}

begin
  InitLocking;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmResetPractice, frmResetPractice);
  Application.Run;
end.
