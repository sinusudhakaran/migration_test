program Migrator ;

uses
  Forms,
  Mainform in 'Mainform.pas' {formMain},
  FromBrowseForm in 'FromBrowseForm.pas' {FromBrowse},
  GuidList in 'GuidList.pas',
  syTables in 'syTables.pas',
  bkTables in 'bkTables.pas',
  btTables in 'btTables.pas',
  PasswordHash in 'PasswordHash.pas',
  MigrateActions in 'MigrateActions.pas',
  Migraters in 'Migraters.pas',
  ClientMigrater in 'ClientMigrater.pas',
  SystemMigrater in 'SystemMigrater.pas',
  MigrateTable in 'MigrateTable.pas',
  AvailableSQLServers in 'AvailableSQLServers.pas',
  MigrateStats in 'MigrateStats.pas',
  CDTables in 'CDTables.pas',
  LogTables in 'LogTables.pas',
  LogMigrater in 'LogMigrater.pas',
  logger in 'logger.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  {$IFDEF Debug}
  ReportMemoryLeaksOnShutdown := true;
  {$EndIf}
  Application.CreateForm(TformMain, formMain);
  Application.Run;
end.
