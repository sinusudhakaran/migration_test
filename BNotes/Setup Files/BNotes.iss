[Setup]
;Bits=32
AppName=BankLink BNotes
AppVerName=BankLink BNotes
AppCopyright=Copyright © 2001,2002 BankLink Limited
ChangesAssociations=yes
DefaultDirName={sd}\BNotes
DefaultGroupName=BankLink
DisableStartupPrompt=yes
LicenseFile=OtherFiles\bnotes_eula.rtf
MinVersion=4,4

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"; MinVersion: 4,4

[Registry]
Root: HKCR; Subkey: ".trf"; ValueType: string; ValueName: ""; ValueData: "BankLinkBNotesFile"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "BankLinkBNotesFile"; ValueType: string; ValueName: ""; ValueData: "BankLink BNotes File"; Flags: uninsdeletekey
Root: HKCR; Subkey: "BankLinkBNotesFile\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\BNOTES.EXE,0"
Root: HKCR; Subkey: "BankLinkBNotesFile\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\BNOTES.EXE"" ""%1"""

[Files]
Source: "..\Binaries\BNOTES.EXE"; DestDir: "{app}"
Source: "OtherFiles\bkinstall.exe"; DestDir: "{app}"
Source: "OtherFiles\bkupgcor.dll"; DestDir: "{app}"
Source: "OtherFiles\ipwssl6.dll"; DestDir: "{app}"

Source: "HelpGuide\Notes_Guide_NZ.chm"; DestDir: "{app}"; DestName: "NOTES_Guide.chm"; Check: CountryIs(1)
Source: "HelpGuide\Notes_Guide_AU.chm"; DestDir: "{app}"; DestName: "NOTES_Guide.chm"; Check: CountryIs(0)
Source: "HelpGuide\Notes_Guide_UK.chm"; DestDir: "{app}"; DestName: "NOTES_Guide.chm"; Check: CountryIs(2)

; PlusCountry dll
Source: "PlusCountry.dll"; Flags: dontcopy

[Icons]
Name: "{group}\BankLink BNotes"; Filename: "{app}\BNOTES.EXE"
Name: "{userdesktop}\BankLink BNotes"; Filename: "{app}\BNOTES.EXE"; MinVersion: 4,4; Tasks: desktopicon

[Code]
var
  CountryCode: integer;
  CountryPage: TInputOptionWizardPage;
  FinishedInstall: Boolean;

function DefaultCountry: Integer;
external 'DefaultCountry@files:PlusCountry.dll stdcall setuponly delayload';

function CountryIs(C:Integer): Boolean;
begin
  Result := (C = CountryCode)
end;

function CountryText(Param:String): String;
begin
  Result := IntToStr(CountryCode);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Index, TempCountry: integer;
begin
  Result := True;
  if CurPageId = wpWelcome then begin
    TempCountry := DefaultCountry;
    case TempCountry of
      0: Index := 1;
      1: Index := 0;
      2: Index := 2;
    else
      Index := -1;
    end
    CountryPage.SelectedValueIndex := Index;
  end else if CurPageId = CountryPage.ID then begin
    case CountryPage.SelectedValueIndex of
      0: CountryCode := 0;
      1: CountryCode := 1;
      2: CountryCode := 2;
    end;
    Result := CountryCode >= 0;
  end;
end;

procedure InitializeWizard();
begin
  //Select Country Page
  CountryPage := CreateInputOptionPage(wpWelcome, 'Country', 'Please select a country for InvoicePlus.', '', True, False);
  CountryPage.Add('Australia');
  CountryPage.Add('New Zealand');
  CountryPage.Add('United Kingdom');
end;
