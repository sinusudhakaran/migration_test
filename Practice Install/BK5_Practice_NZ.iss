[Setup]
;-------------------------------------------------------
;   NZ Practice Setup file
;-------------------------------------------------------
#Include "Bin\BankLinkPractice.txt"
#include "Bin\BankLinkCopyRight.txt"
DefaultDirName={sd}\BK5
DefaultGroupName=MYOB
DisableStartupPrompt=yes
LicenseFile=Bin\BK5_EULA.RTF
MinVersion=4.1,5
OutputDir=..\Binaries\PracticeInstall_NZ
OutputBaseFilename=setup_practice_nz
Compression=lzma
SolidCompression=yes
RestartIfNeededByRun=no
AppendDefaultDirName=no

[Files]
Source: "..\Binaries\BK5WIN.EXE"; DestDir: "{app}"
Source: "..\Binaries\bkLookup.dll"; DestDir: "{app}"
Source: "..\Binaries\BKHandler\bkHandlerSetup.exe"; DestDir: "{app}"
Source: "..\Binaries\bkmap.exe"; DestDir: "{app}"

Source: "Bin\mapi64bit.exe"; DestDir: "{app}"
Source: "Bin\bkExtMapi.dll"; DestDir: "{app}"
Source: "Bin\BK5WIN.EXE.Manifest"; DestDir: "{app}"
Source: "Bin\bkinstall.exe"; DestDir: "{app}"
Source: "Bin\bkupgcor.dll"; DestDir: "{app}"
Source: "Bin\NZ.INF"; DestDir: "{app}"
Source: "Bin\OZ.INF"; DestDir: "{app}"
Source: "Bin\Institutions.dat"; DestDir: "{app}"
Source: "Bin\app_nz.ini"; DestDir: "{app}"; DestName: "app.ini"
Source: "Bin\CMst.html"; DestDir: "{app}\CACHE\HTML"
Source: "Bin\CMdt.html"; DestDir: "{app}\CACHE\HTML"

Source: "Practice Help\guide_nz.chm"; DestDir: "{app}"; DestName: "guide.chm"

Source: "Mail Merge\BKDataSource.csv"; DestDir: "{app}"
Source: "Mail Merge\BKPrintMerge.doc"; DestDir: "{app}"
Source: "Mail Merge\BKEmailMerge.doc"; DestDir: "{app}"

Source: "Fixes\bkNetHelpFix.exe"; DestDir: "{app}"

Source: "3rd Party\wPDF200a.DLL"; DestDir: "{app}"
Source: "3rd Party\wPDFView01.DLL"; DestDir: "{app}"
Source: "3rd Party\Expat_License.txt"; DestDir: "{app}"
Source: "3rd Party\WDDX_License.html"; DestDir: "{app}"
Source: "3rd Party\wddx_com.dll"; DestDir: "{app}"
Source: "3rd Party\xmlparse.dll"; DestDir: "{app}"
Source: "3rd Party\xmltok.dll"; DestDir: "{app}"
Source: "3rd Party\ipwssl6.dll"; DestDir: "{app}"
Source: "3rd Party\RTM.EXE"; DestDir: "{app}"
Source: "3rd Party\DPMI16BI.OVL"; DestDir: "{app}"
Source: "3rd Party\STUB.EXE"; DestDir: "{app}"
Source: "3rd Party\FETCH.EXE"; DestDir: "{app}"
Source: "3rd Party\BKCASYS.EXE"; DestDir: "{app}"
Source: "3rd Party\GET4CEE.EXE"; DestDir: "{app}"
Source: "3rd Party\ACTCHART.EXE"; DestDir: "{app}"
Source: "3rd Party\S6BNK.COM"; DestDir: "{app}"
Source: "3rd Party\libeay32.dll"; DestDir: "{app}"
Source: "3rd Party\zint.dll"; DestDir: "{app}"
Source: "3rd Party\vcredist_x86.exe"; DestDir: "{app}\Support"

Source: "AuthorityForms\TPA_Generator.xlt"; DestDir: "{app}"

Source: "Practice CD Files\NZ Samples\NZCODED.BK5"; DestDir: "{app}\SAMPLES"
Source: "Practice CD Files\NZ Samples\JO.BK5"; DestDir: "{app}\SAMPLES"
Source: "Practice CD Files\NZ Samples\JOCODED.BK5"; DestDir: "{app}\SAMPLES"
Source: "Practice CD Files\NZ Samples\NZUNCODE.BK5"; DestDir: "{app}\SAMPLES"

Source: "Publickeys\PublicKeyCafQrCode.pke"; DestDir : "{app}\Publickeys"
Source: "Publickeys\PublicKeyMyobMigration.pke"; DestDir : "{app}\Publickeys"

Source: "..\Binaries\PracticeApplicationService.exe"; DestDir: "{app}\Practice Server"
Source: "..\Binaries\PracticeServerConsole.exe"; DestDir: "{app}\Practice Server"
Source: "..\Practice Server\Service\PracticeApplicationService.ini"; DestDir: "{app}\Practice Server"; check PracticeServiceINICheck;

[Icons]
Name: "{group}\MYOB BankLink Practice"; Filename: "{app}\BK5WIN.EXE"
Name: "{group}\Create Initial Database"; Filename: "{app}\BK5WIN.EXE"; Parameters: "/dbcreate";

[Tasks]
Name: createdb; Description: "Create an initial database";

[Run]
Filename: "{app}\BK5WIN.EXE"; Parameters : "/dbcreate_norun"; Description : "Create an initial MYOB BankLink Practice Database"; WorkingDir: "{app}"; Tasks : createdb;
Filename: "{app}\BK5WIN.EXE"; Description : "Start MYOB BankLink Practice"; WorkingDir: "{app}"; Flags: postinstall nowait;

[Registry]
Root: HKCU; Subkey: "Software\BankLink"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\BankLink\"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"

[Code]
function PracticeServiceINICheck:Boolean;
begin
  Result := True;
  if FileExists(ExpandConstant('{app}') + '\Practice Server\PracticeApplicationService.ini') then
    Result := False;
end;

