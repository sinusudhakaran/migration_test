program BNotes;



uses
  Forms,
  SysUtils,
  WinUtils,
  ecGlobalConst,
  ecMessageBoxUtils,
  INISettings,
  BaseFrm in 'Win32\BaseFrm.pas' {frmBase},
  DissectionFrm in 'Win32\DissectionFrm.pas' {frmDissection},
  ImagesFrm in 'Win32\ImagesFrm.pas' {AppImages},
  MailSettingsFrm in 'Win32\MailSettingsFrm.pas' {frmMailSettings},
  MainFrm in 'Win32\MainFrm.pas' {frmMain},
  NotesHelp in 'Win32\NotesHelp.pas',
  PasswordFrm in 'Win32\PasswordFrm.pas' {frmPassword},
  SendFrm in 'Win32\SendFrm.pas' {frmSend},
  UPCRangeFrm in 'Win32\UPCRangeFrm.pas' {frmUPCRange},
  AboutFrm in 'Win32\AboutFrm.pas' {frmAbout};

{$R *.RES}
{//$R WINXP.RES}

begin
  if (Pos('Windows 95', WinUtils.GetWinVer) > 0) then
    ErrorMessage('This application does not run on Windows 95.'#13#13 + ecGlobalConst.APP_NAME + ' will now terminate.')
  else if (Pos('Windows NT', WinUtils.GetWinVer) > 0) then
    ErrorMessage('This application does not run on Windows NT.'#13#13 + ecGlobalConst.APP_NAME + ' will now terminate.')
  else
  begin
    //read local ini file
    INISettings.ReadLocalINI;
    if (INISettings.INI_DefaultFileLocation = '') then
      INISettings.INI_DefaultFileLocation := ExtractFilePath(Application.ExeName);

    Application.Initialize;
    Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TAppImages, AppImages);
  Application.Run;

    //write local ini file
    INISettings.WriteLocalINI;
  end;
end.

