[Setup]
;Bits=32
AppName=BankLink Notes 2009
AppVerName=BankLink Notes 2009
AppCopyright=Copyright © 2001-2009 BankLink Limited
ChangesAssociations=yes
DefaultDirName={sd}\BNotes
DefaultGroupName=BankLink
DisableStartupPrompt=yes
LicenseFile=bnotes_eula.txt
MinVersion=4.1,5
SourceDir=G:\BNotes\Testing Release
OutputDir=G:\BNotes\Testing Release\FloppyInstall
OutputBaseFilename=disk_setupbnotes
DiskSpanning=yes

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4

[Registry]
Root: HKCR; Subkey: ".trf"; ValueType: string; ValueName: ""; ValueData: "BankLinkBNotesFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "BankLinkBNotesFile"; ValueType: string; ValueName: ""; ValueData: "BankLink BNotes File"; Flags: uninsdeletekey
Root: HKCR; Subkey: "BankLinkBNotesFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\BNOTES.EXE,0"
Root: HKCR; Subkey: "BankLinkBNotesFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\BNOTES.EXE"" ""%1"""

[Files]
Source: "BNOTES.EXE"; DestDir: "{app}"
Source: "HelpGuide\Notes_guide_au.chm"; DestDir: "{app}"; DestName: "NOTES_GUIDE.CHM"
Source: "bkinstall.exe"; DestDir: "{app}"
Source: "bkupgcor.dll"; DestDir: "{app}"
Source: "ipwssl6.dll"; DestDir: "{app}"

[Icons]
Name: "{group}\BankLink Notes"; Filename: "{app}\BNOTES.EXE"
Name: "{userdesktop}\BankLink Notes"; Filename: "{app}\BNOTES.EXE"; MinVersion: 4,4; Tasks: desktopicon

