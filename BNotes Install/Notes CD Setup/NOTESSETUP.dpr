program NOTESSETUP;

uses
  Forms,
  CountryFrm in 'CountryFrm.pas' {frmLocation},
  MAINFRM in 'MAINFRM.PAS' {frmMain};

{$R *.RES}
{$R Elevate.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'BankLink Setup Launcher';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
