program NOTESSETUP;

uses
  Forms,
  MAINFRM in 'MAINFRM.PAS' {frmMain};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
