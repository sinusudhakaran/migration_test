library bkupgcor;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }




uses
  SysUtils,
  Classes,
  upgMain in 'upgMain.pas',
  upgConstants in 'upgConstants.pas',
  upgMainFrm in 'upgMainFrm.pas' {frmUpdMain},
  upgObjects in 'upgObjects.pas',
  upgClientCommon in 'upgClientCommon.pas',
  upgExceptions in 'upgExceptions.pas',
  CRC32 in 'CRC32.pas',
  CRCFileUtils in 'CRCFileUtils.pas',
  upgCommon in 'upgCommon.pas',
  upgDownloaderService in 'upgDownloaderService.pas',
  upgServiceUpgrader in 'upgServiceUpgrader.pas',
  AppParser in 'AppParser.pas';

{$R *.res}

exports
  CheckForUpdates,
  CheckForUpdatesEx,
  InstallUpdates,
  InstallUpdatesEx,
  FilesWaitingToBeInstalled,
  ReportFirstRun,
  InitDllapplication;
end.
