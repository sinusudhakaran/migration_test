program bkhandlr;

uses
  Forms,
  bkhandlr_main in 'bkhandlr_main.pas' {frmMain},
  selectbkfolderfrm in 'selectbkfolderfrm.pas' {frmSelectBK5Folder},
  RegistryUtils in 'RegistryUtils.pas',
  BKHandConsts in 'BKHandConsts.pas';

{$R docicon.res}
{$R trfdoc.res}

begin
  Application.Initialize;
  Application.ShowMainForm := false;
  Application.Title := BRAND_FULL_APP_NAME;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
