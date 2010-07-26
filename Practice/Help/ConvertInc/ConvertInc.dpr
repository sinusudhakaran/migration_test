program ConvertInc;

uses
  Forms,
  MainFrm in 'MainFrm.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'BankLink Include file converter';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
