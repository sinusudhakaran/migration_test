[Setup]
;--------------------------------------------------------------
;   NZ Practice Update Setup file
;--------------------------------------------------------------
#Include "Bin\BankLinkPracticeUpdate.txt"
#include "Bin\BankLinkCopyRight.txt"
DefaultDirName={sd}\BK5
DisableStartupPrompt=yes
LicenseFile=Bin\BK5_EULA.RTF
MinVersion=4.1,5
Uninstallable=no
OutputDir=..\Binaries\Prac_Update_NZ
OutputBaseFilename=setup_update_nz
Compression=lzma
SolidCompression=yes
DirExistsWarning=false
RestartIfNeededByRun=no
AppendDefaultDirName=no
InfoBeforeFile=Practice CD Files\infoPRAC.txt

[Files]
;*Application files*
Source: "..\Binaries\BK5WIN.EXE"; DestDir: "{app}"
Source: "..\Binaries\bkLookup.dll"; DestDir: "{app}"
Source: "..\Binaries\BKHandler\bkHandlerSetup.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Binaries\bkmap.exe"; DestDir: "{app}"

Source: "Bin\mapi64bit.exe"; DestDir: "{app}"
Source: "Bin\bkExtMapi.dll"; DestDir: "{app}"
Source: "Bin\BK5WIN.EXE.Manifest"; DestDir: "{app}"
Source: "Bin\bkinstall.exe"; DestDir: "{app}"
Source: "Bin\bkupgcor.dll"; DestDir: "{app}"
Source: "Bin\Institutions.dat"; DestDir: "{app}"
Source: "Bin\app_nz.ini"; DestDir: "{app}"; DestName: "app.ini"
Source: "Bin\CMst.html"; DestDir: "{app}\CACHE\HTML"
Source: "Bin\CMdt.html"; DestDir: "{app}\CACHE\HTML"

Source: "Fixes\bkNetHelpFix.exe"; DestDir: "{app}"

;*Help*
Source: "Practice Help\guide_nz.chm"; DestDir: "{app}"; DestName: "guide.chm"

;*Mail Merge*
Source: "Mail Merge\BKDataSource.csv"; DestDir: "{app}"
Source: "Mail Merge\BKPrintMerge.doc"; DestDir: "{app}"
Source: "Mail Merge\BKEmailMerge.doc"; DestDir: "{app}"

;*3rd party components*
Source: "3rd Party\ipwssl6.dll"; DestDir: "{app}"
Source: "3rd Party\BKCASYS.EXE"; DestDir: "{app}"
;PDF
Source: "3rd Party\wPDF200a.DLL"; DestDir: "{app}"
Source: "3rd Party\wPDFView01.DLL"; DestDir: "{app}"
;Acclipse
Source: "3rd Party\Expat_License.txt"; DestDir: "{app}"
Source: "3rd Party\WDDX_License.html"; DestDir: "{app}"
Source: "3rd Party\wddx_com.dll"; DestDir: "{app}"
Source: "3rd Party\xmlparse.dll"; DestDir: "{app}"
Source: "3rd Party\xmltok.dll"; DestDir: "{app}"
Source: "3rd Party\libeay32.dll"; DestDir: "{app}"
Source: "3rd Party\zint.dll"; DestDir: "{app}"
Source: "3rd Party\vcredist_x86.exe"; DestDir: "{app}\Support"

Source: "AuthorityForms\TPA_Generator.xlt"; DestDir: "{app}"

Source: "Publickeys\PublicKeyCafQrCode.pke"; DestDir : "{app}\Publickeys"
Source: "Publickeys\PublicKeyMyobMigration.pke"; DestDir : "{app}\Publickeys"

Source: "..\Binaries\PracticeApplicationService.exe"; DestDir: "{app}\Practice Server"
Source: "..\Binaries\PracticeServerConsole.exe"; DestDir: "{app}\Practice Server"
Source: "..\Practice Server\Service\PracticeApplicationService.ini"; DestDir: "{app}\Practice Server"; Check: PracticeServiceINICheck;

[InstallDelete]
Type: files; Name: "{app}\Third Party Authority.pdf"

[Run]
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

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    if not FileExists(ExpandConstant('{app}') + '\BK5WIN.exe') then
    begin
      MsgBox('A previous version of MYOB BankLink Practice must exist in the install folder for the upgrade to complete successfully.' + #13#13 + 'Please change the installation folder to your current MYOB BankLink Practice folder.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;


