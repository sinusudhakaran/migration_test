[Setup]
;--------------------------------------------------------------
;   Offsite Setup file
;--------------------------------------------------------------
#Include "Bin\BankLinkBooksUpdate.txt"
#include "Bin\BankLinkCopyRight.txt"
DefaultDirName={sd}\BK5
DefaultGroupName=BankLink
DisableStartupPrompt=yes
LicenseFile=Bin\BK5_EULA.RTF
MinVersion=4.1,5
OutputDir=..\Binaries\Books_Update_AU
OutputBaseFilename=setup_update_books
Compression=lzma
SolidCompression=yes
AppendDefaultDirName=no
DirExistsWarning=false
Uninstallable=no
InfoBeforeFile=Books Files\infoBOOKS.txt

[Files]
Source: "..\Binaries\BK5WIN.EXE"; DestDir: "{app}"
Source: "..\Binaries\bkhandlr.exe"; DestDir: "{app}"

Source: "Bin\bkExtMapi.dll"; DestDir: "{app}"
Source: "Bin\BK5WIN.EXE.Manifest.Books"; DestDir: "{app}"; DestName: "BK5WIN.EXE.Manifest"
Source: "Bin\bkinstall.exe"; DestDir: "{app}"
Source: "Bin\bkupgcor.dll"; DestDir: "{app}"
Source: "Bin\Institutions.dat"; DestDir: "{app}"
Source: "Bin\app_au.ini"; DestDir: "{app}"; DestName: "app.ini"

Source: "Books Files\guide_au.chm"; DestDir: "{app}"; DestName: "guide.chm"

Source: "3rd Party\wPDF200a.DLL"; DestDir: "{app}"
Source: "3rd Party\wPDFView01.DLL"; DestDir: "{app}"
Source: "3rd Party\ipwssl6.dll"; DestDir: "{app}"
Source: "3rd Party\gdiplus.dll"; DestDir: "{app}"
Source: "3rd Party\libeay32.dll"; DestDir: "{app}"
Source: "3rd Party\zint.dll"; DestDir: "{app}"
Source: "3rd Party\vcredist_x86.exe"; DestDir: "{app}"

[Registry]
Root: HKCR; Subkey: ".bk5"; ValueType: string; ValueName: ""; ValueData: "BankLink.bkHandlr"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "BankLink.bkHandlr"; ValueType: string; ValueName: ""; ValueData: "BankLink Client File"; Flags: uninsdeletekey
Root: HKCR; Subkey: "BankLink.bkHandlr"; ValueType: string; ValueName: "AlwaysShowExt"; ValueData: ""; Flags: uninsdeletekey
Root: HKCR; Subkey: "BankLink.bkHandlr\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\bkhandlr.exe,1"
Root: HKCR; Subkey: "BankLink.bkHandlr\shell"; ValueType: string; ValueName: ""; ValueData: "open"
Root: HKCR; Subkey: "BankLink.bkHandlr\shell\open"; ValueType: string; ValueName: ""; ValueData: "Check In"
Root: HKCR; Subkey: "BankLink.bkHandlr\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\bkhandlr.exe"" ""%1"""
Root: HKCR; Subkey: "BankLink.bkHandlr\shell\open\ddeexec"; ValueType: string; ValueName: ""; ValueData: "[CheckIn(""%1"")]"
Root: HKCR; Subkey: "BankLink.bkHandlr\shell\open\ddeexec\Application"; ValueType: string; ValueName: ""; ValueData: "bkhandlr"
Root: HKCR; Subkey: "BankLink.bkHandlr\shell\open\ddeexec\Topic"; ValueType: string; ValueName: ""; ValueData: "bksystem"
Root: HKCU; Subkey: "Software\BankLink"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\BankLink\"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"

[Run]
Filename: "{app}\vcredist_x86.exe"; Parameters : "/q:a"; Description : "Install Visual C++ 2008 Redistributable"; WorkingDir: "{app}"; Check : WillInstallReDist;

[Code]
function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    if not FileExists(ExpandConstant('{app}') + '\BK5WIN.exe') then
    begin
      MsgBox('A previous version of BankLink Books must exist in the install folder for the upgrade to complete successfully.' + #13#13 + 'Please change the installation folder to your current BankLink Books folder.', mbError, MB_OK);
      Result := False;
    end;
  end;
end;

function WillInstallReDist: Boolean;
var
  Version: TWindowsVersion;
begin
  GetWindowsVersionEx(Version);

  Result := (Version.Major < 6);
end;
