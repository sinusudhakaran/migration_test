program AuditTrail;

uses
  Forms,
  MainForm in 'MainForm.pas' {Form1},
  AuditTable in 'AuditTable.pas',
  PayeeTable in 'PayeeTable.pas',
  ClientDB in 'ClientDB.pas',
  AuditMgr in 'AuditMgr.pas',
  SystemDB in 'SystemDB.pas',
  UserTable in 'UserTable.pas',
  AuditUtils in 'AuditUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
