program PassGen;

uses
  Forms,
  PassGenFrm in 'PassGenFrm.pas' {frmPassGen};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Password Gen';
  Application.CreateForm(TfrmPassGen, frmPassGen);
  Application.Run;
end.
