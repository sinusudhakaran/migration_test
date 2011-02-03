program bkhandlr;

uses
  Forms,
  bkhandlr_main in 'bkhandlr_main.pas' {frmMain},
  selectbkfolderfrm in 'selectbkfolderfrm.pas' {frmSelectBK5Folder},
  RegistryUtils in 'RegistryUtils.pas';


{$R docicon.res}
{$R trfdoc.res}

begin
  Application.Initialize;
  Application.ShowMainForm := false;
  Application.Title := 'BankLink File Handler';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
