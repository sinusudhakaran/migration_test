program BOOKSSETUP;

uses
  Forms,
  CountryFrm in 'CountryFrm.pas' {frmLocation},
  MainFrm in 'MainFrm.pas' {frmMain};


{$R *.RES}
{$R Elevate.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Banklink Books Setup Launcher';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
