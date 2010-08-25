[Setup]
;Bits=32
AppName=BankLink BNotes
AppVerName=BankLink BNotes
AppCopyright=Copyright © 2001,2002 BankLink Limited
ChangesAssociations=yes
DefaultDirName={sd}\BNotes
DefaultGroupName=BankLink
DisableStartupPrompt=yes
LicenseFile=bnotes_eula.txt
MinVersion=4,4

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4

[Registry]
Root: HKCR; Subkey: ".trf"; ValueType: string; ValueName: ""; ValueData: "BankLinkBNotesFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "BankLinkBNotesFile"; ValueType: string; ValueName: ""; ValueData: "BankLink BNotes File"; Flags: uninsdeletekey
Root: HKCR; Subkey: "BankLinkBNotesFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\BNOTES.EXE,0"
Root: HKCR; Subkey: "BankLinkBNotesFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\BNOTES.EXE"" ""%1"""

[Files]
Source: "BNOTES.EXE"; DestDir: "{app}"
Source: "BNOTES.HLP"; DestDir: "{app}"

[Icons]
Name: "{group}\BankLink BNotes"; Filename: "{app}\BNOTES.EXE"
Name: "{userdesktop}\BankLink BNotes"; Filename: "{app}\BNOTES.EXE"; MinVersion: 4,4; Tasks: desktopicon

