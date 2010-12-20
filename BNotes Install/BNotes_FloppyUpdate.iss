[Setup]
;Bits=32
AppName=BankLink Notes 2011 Update
AppVerName=BankLink Notes 2011 Update
AppCopyright=Copyright © 2001-2011 BankLink Limited
ChangesAssociations=yes
DefaultDirName={sd}\BNotes
DefaultGroupName=BankLink
DisableStartupPrompt=yes
LicenseFile=OtherFiles\bnotes_eula.txt
MinVersion=4.1,5
OutputDir=..\Binaries\BNotes FloppyInstall Update
OutputBaseFilename=disk_setupbnotes_update
DirExistsWarning=false
DiskSpanning=yes

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4

[Registry]
Root: HKCR; Subkey: ".trf"; ValueType: string; ValueName: ""; ValueData: "BankLinkBNotesFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "BankLinkBNotesFile"; ValueType: string; ValueName: ""; ValueData: "BankLink BNotes File"; Flags: uninsdeletekey
Root: HKCR; Subkey: "BankLinkBNotesFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\BNOTES.EXE,0"
Root: HKCR; Subkey: "BankLinkBNotesFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\BNOTES.EXE"" ""%1"""
Root: HKCU; Subkey: "Software\BankLink"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\BankLink\Notes"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\BankLink\Notes"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"

[Files]
Source: "..\Binaries\BNOTES.EXE"; DestDir: "{app}"
Source: "HelpGuide\Notes_guide_au.chm"; DestDir: "{app}"; DestName: "NOTES_GUIDE.CHM"
Source: "OtherFiles\bkinstall.exe"; DestDir: "{app}"
Source: "OtherFiles\bkupgcor.dll"; DestDir: "{app}"
Source: "OtherFiles\ipwssl6.dll"; DestDir: "{app}"

[Icons]
Name: "{group}\BankLink Notes"; Filename: "{app}\BNOTES.EXE"
Name: "{userdesktop}\BankLink Notes"; Filename: "{app}\BNOTES.EXE"; MinVersion: 4,4; Tasks: desktopicon

[Code]
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    if not FileExists(ExpandConstant('{app}') + '\BNOTES.exe') then
    begin
      MsgBox('A previous version of BankLink Notes must exist in the install folder for the upgrade to complete successfully.' + #13#13 + 'Please change the installation folder to your current BankLink Notes folder.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;
