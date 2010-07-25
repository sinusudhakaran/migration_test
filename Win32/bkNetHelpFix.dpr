program bkNetHelpFix;

uses
  Forms,
  frmHelpEnabler in 'frmHelpEnabler.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
