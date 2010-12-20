[Setup]
;Bits=32
AppName=BankLink Notes 2011
AppVerName=BankLink Notes 2011
AppCopyright=Copyright © 2001-2011 BankLink Limited
ChangesAssociations=yes
DefaultDirName={sd}\BNotes
DefaultGroupName=BankLink
DisableStartupPrompt=yes
LicenseFile=OtherFiles\bnotes_eula.rtf
MinVersion=4.1,5
OutputDir=..\Binaries\BNotes Install
OutputBaseFilename=setupbnotes

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4

[Registry]
Root: HKCR; Subkey: ".trf"; ValueType: string; ValueName: ""; ValueData: "BankLinkBNotesFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "BankLinkBNotesFile"; ValueType: string; ValueName: ""; ValueData: "BankLink BNotes File"; Flags: uninsdeletekey
Root: HKCR; Subkey: "BankLinkBNotesFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\BNOTES.EXE,0"
Root: HKCR; Subkey: "BankLinkBNotesFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\BNOTES.EXE"" ""%1"""

[Files]
Source: "..\Binaries\BNOTES.EXE"; DestDir: "{app}"
Source: "HelpGuide\Notes_guide_au.chm"; DestDir: "{app}"; DestName: "NOTES_GUIDE.CHM"
Source: "OtherFiles\bkinstall.exe"; DestDir: "{app}"
Source: "OtherFiles\bkupgcor.dll"; DestDir: "{app}"
Source: "OtherFiles\ipwssl6.dll"; DestDir: "{app}"

[Icons]
Name: "{group}\BankLink Notes"; Filename: "{app}\BNOTES.EXE"
Name: "{userdesktop}\BankLink Notes"; Filename: "{app}\BNOTES.EXE"; MinVersion: 4,4; Tasks: desktopicon

