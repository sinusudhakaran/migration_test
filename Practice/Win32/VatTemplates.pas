unit VatTemplates;

interface

uses
  SysUtils,
  Classes,
  StdCtrls,
  glConst,
  bkConst,
  Globals;

type
  // For configuring the buttons
  TVatLevel = (
    vlPractice,
    vlClient
  );

  { Universal record for both EditPracGSTDlg.TGSTInfoRec, and EditGSTDlg.TGSTInfoRec
    Note: some arrays are 1-based (!)
  }
  TVatRatesRow = record
    GST_ID                  : string[GST_CLASS_CODE_LENGTH];
    GST_Class_Name          : string[60];
    GST_Rates               : array[1..MAX_VISIBLE_GST_CLASS_RATES] of double;
    GST_Account_Code        : Bk5CodeStr;
    GSTClassType            : integer; // Types from bkConst only (gst, vat)
    GST_BusinessNormPercent : double; // Not required for practice level
  end;
  TVatRates = array[1..MAX_GST_CLASS] of TVatRatesRow;

  function  VatSetupButtons(const aLevel: TVatLevel;
              const aButtons: array of TButton): boolean;

  function  VatOpenDialog(const aOwner: TComponent; var aFileName: string): boolean;
  function  VatSaveDialog(const aOwner: TComponent; var aFileName: string): boolean;

  function  VatConfirmLoad: boolean;

  procedure VatLoadFromFile(
              const aFileName: string;
              var aRate1: integer;
              var aRate2: integer;
              var aRate3: integer;
              var aRates: TVatRates);

  procedure VatSaveToFile(
              const aRate1: integer;
              const aRate2: integer;
              const aRate3: integer;
              const aRates: TVatRates;
              const aFileName: string);

  // Consistent error messages (practice and client level)
  procedure VatShowLoadException(const E: Exception);
  procedure VatShowSaveException(const E: Exception);

implementation

uses
  Types,
  Dialogs,
  IniFiles,
  Windows,
  bkdateutils,
  WarningMoreFrm,
  YesNoDlg;

const
  DLG_DEFAULTEXT = 'vat';
  DLG_FILTER     = 'VAT Templates (*.vat)|*.vat';

  SECTION_TEMPLATE   = '[Template]';
  SECTION_TAX_STARTS = '[Tax Starts]';
  SECTION_TAX_TABLE  = '[Tax Table]';

  COLUMNS_TAX_STARTS = 2;
  COLUMNS_TAX_TABLE  = 9;

  // Columns - Effective Rates
  effRow  = 0;
  effDate = 1;

  // Columns - Rates
  taxRow                 = 0;
  taxID                  = 1;
  taxDesc                = 2;
  taxType                = 3;
  taxRate1               = 4;
  taxRate2               = 5;
  taxRate3               = 6;
  taxAccount             = 7;
  taxBusinessNormPercent = 8;

{------------------------------------------------------------------------------}
function VatSetupButtons(const aLevel: TVatLevel;
  const aButtons: array of TButton): boolean;
var
  Country: byte;
  i: integer;
begin
  // Determine country
  case aLevel of
    vlPractice:
      Country := AdminSystem.fdFields.fdCountry;
    vlClient:
      Country := MyClient.clFields.clCountry;
    else
      Country := 0; // If it gets to this, we have no real way to determine the Country
  end;

  // For the UK only
  if (Country = whUK) then
  begin
    // At practice level for the System user only
    if (aLevel = vlPractice) then
      result := CurrUser.CanAccessAdmin
    else
      result := true;
  end
  else
    result := false;

  for i := 0 to High(aButtons) do
  begin
    aButtons[i].Visible := result;
  end;
end;

{------------------------------------------------------------------------------}
function VatOpenDialog(const aOwner: TComponent; var aFileName: string): boolean;
var
  Dlg: TOpenDialog;
begin
  // Create this here (similar to BAS templates)
  ForceDirectories(Globals.TemplateDir);

  Dlg := TOpenDialog.Create(aOwner);
  try
    Dlg.DefaultExt := DLG_DEFAULTEXT;
    Dlg.Filter := DLG_FILTER;
    Dlg.InitialDir := Globals.TemplateDir;
    Dlg.Options := [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing];

    result := Dlg.Execute;

    if result then
      aFileName := Dlg.FileName;
  finally
    FreeAndNil(Dlg);
  end;
end;

{------------------------------------------------------------------------------}
function VatSaveDialog(const aOwner: TComponent; var aFileName: string): boolean;
var
  Dlg: TSaveDialog;
begin
  // Create this here (similar to BAS templates)
  ForceDirectories(Globals.TemplateDir);

  Dlg := TSaveDialog.Create(aOwner);
  try
    Dlg.DefaultExt := DLG_DEFAULTEXT;
    Dlg.Filter := DLG_FILTER;
    Dlg.InitialDir := Globals.TemplateDir;
    Dlg.Options := [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing];

    result := Dlg.Execute;

    if result then
      aFileName := Dlg.FileName;
  finally
    FreeAndNil(Dlg);
  end;
end;

{------------------------------------------------------------------------------}
function VatConfirmLoad: boolean;
var
  Title: string;
  Msg: string;
  DlgResult: integer;
begin
  Title := 'Load VAT Rates';

  Msg :=
    'Note: This will also change all coded transactions to use the new VAT rates and IDs, except for:'+sLineBreak+
    '    - transactions that have been Transferred or Finalised'+sLineBreak+
    '    - transactions where the VAT has been manually overridden'+sLineBreak+
    '      by the user'+sLineBreak+ // It was necessary to manually break the line
    sLineBreak+
    'The Chart of Accounts will also be updated to use the new VAT IDs where appropriate.'+sLineBreak+
    sLineBreak+
    'Are you sure you want to load the VAT rates?';

  // The default button should be "NO"
  DlgResult := AskYesNo(Title, Msg, DLG_NO, 0);

  result := (DlgResult = DLG_YES);
end;

{------------------------------------------------------------------------------}
procedure GetSectionValues(const aLines: TStringList; const aSection: string;
  var aValues: TStringList);
var
  i: integer;
  Line: string;
  InSection: boolean;
begin
  aValues.Clear;
  
  InSection := false;
  for i := 0 to aLines.Count-1 do
  begin
    Line := aLines[i];

    if InSection then
    begin
      if (Line <> '') then
        aValues.Add(Line)
      else
        exit;
    end
    else
      InSection := SameText(Line, aSection);
  end;
end;

{------------------------------------------------------------------------------}
procedure ParseLine(const aLine: string; var aValues: TStringDynArray;
  const aNrColumns: integer);
var
  i: integer;
  ch: char;
  NrValues: integer;
begin
  // Always do this to reset ALL strings back to ''
  SetLength(aValues, 0);

  // Something to parse? (We always want to check NrColumns at the end)
  if (aLine <> '') then
  begin
    // Always have one value. This also helps when the first char is a |.
    // And also helps if the last character is a |.
    SetLength(aValues, 1);

    for i := 1 to Length(aLine) do
    begin
      ch := aLine[i];
      NrValues := Length(aValues);

      if (ch = '|') then
        SetLength(aValues, NrValues+1)
      else
        aValues[NrValues-1] := aValues[NrValues-1] + ch;
    end;
  end;

  // Not right number of columns?
  if (Length(aValues) <> aNrColumns) then
    raise Exception.CreateFmt('Required number of columns (%d) is incorrect for line <%s>',
      [aNrColumns, aLine]);
end;

{------------------------------------------------------------------------------}
procedure LoadEffectiveRates(const aLines: TStringList; var aRate1: integer;
  var aRate2: integer; var aRate3: integer);
var
  Values: TStringDynArray;
begin
  if (aLines.Count < 3) then
    raise Exception.Create('Need at least three tax starts');

  ParseLine(aLines[0], Values, COLUMNS_TAX_STARTS);
  aRate1 := bkStr2Date(Values[effDate]);

  ParseLine(aLines[1], Values, COLUMNS_TAX_STARTS);
  aRate2 := bkStr2Date(Values[effDate]);

  ParseLine(aLines[2], Values, COLUMNS_TAX_STARTS);
  aRate3 := bkStr2Date(Values[effDate]);
end;

{------------------------------------------------------------------------------}
procedure LoadRate(const aLine: string; var aValue: TVatRatesRow);
var
  Values: TStringDynArray;
begin
  ParseLine(aLine, Values, COLUMNS_TAX_TABLE);

  // Values[0] - Row, ignore

  aValue.GST_ID := Values[taxID];

  aValue.GST_Class_Name := Values[taxDesc];

  aValue.GSTClassType := StrToInt(Values[taxType]);

  aValue.GST_Rates[1] := StrToFloat(Values[taxRate1]);

  aValue.GST_Rates[2] := StrToFloat(Values[taxRate2]);

  aValue.GST_Rates[3] := StrToFloat(Values[taxRate3]);

  aValue.GST_Account_Code := Values[taxAccount];

  aValue.GST_BusinessNormPercent := StrToFloat(Values[taxBusinessNormPercent]);
end;

{------------------------------------------------------------------------------}
procedure VatLoadFromFile(const aFileName: string; var aRate1: integer;
  var aRate2: integer; var aRate3: integer; var aRates: TVatRates);
var
  Lines: TStringList;
  Values: TStringList;
  i: integer;
  ValueIndex: integer;
begin
  ASSERT(aFileName <> '');

  // Make sure everything is erased
  ZeroMemory(@aRates, SizeOf(aRates));

  Lines := TStringList.Create;
  Values := TStringList.Create;
  try
    Lines.LoadFromFile(aFileName);

    // Effective Rates - we only use 3
    GetSectionValues(Lines, SECTION_TAX_STARTS, Values);
    LoadEffectiveRates(Values, aRate1, aRate2, aRate3);

    // Rates
    // Caution: i is 1-based, and ValueIndex is 0-based
    GetSectionValues(Lines, SECTION_TAX_TABLE, Values);
    for i := 1 to MAX_GST_CLASS do
    begin
      // Valid range?
      ValueIndex := i - 1;
      if (ValueIndex < Values.Count) then
        LoadRate(Values[ValueIndex], aRates[i])
      else
        break; // No more data - stop
    end;
  finally
    FreeAndNil(Values);
    FreeAndNil(Lines);
  end;
end;

{------------------------------------------------------------------------------}
procedure SaveEffectiveRate(const aRow: integer; const aDate: integer;
  const aLines: TStringList);
var
  Line: string;
begin
  Line := IntToStr(aRow);
  Line := Line + '|';
  if (aDate <> -1) then
    Line := Line + bkDate2Str(aDate);
  aLines.Add(Line);
end;

{------------------------------------------------------------------------------}
procedure AddToLine(const aValue: string; var aLine: string);
begin
  if (Pos('|', aValue) <> 0) then
    raise Exception.CreateFmt('The value <%s> can not contain the | character', [aValue]);

  if (aLine <> '') then
    aLine := aLine + '|';

  aLine := aLine + aValue;
end;

{------------------------------------------------------------------------------}
procedure SaveRate(const aRow: integer; const aValue: TVatRatesRow;
  const aLines: TStringList);
var
  Value: string;
  Line: string;
begin
  Value := IntToStr(aRow);
  AddToLine(Value, Line);

  Value := aValue.GST_ID;
  AddToLine(Value, Line);

  Value := aValue.GST_Class_Name;
  AddToLine(Value, Line);

  Value := IntToStr(aValue.GSTClassType);
  AddToLine(Value, Line);

  Value := FloatToStr(aValue.GST_Rates[1]);
  AddToLine(Value, Line);

  Value := FloatToStr(aValue.GST_Rates[2]);
  AddToLine(Value, Line);

  Value := FloatToStr(aValue.GST_Rates[3]);
  AddToLine(Value, Line);

  Value := aValue.GST_Account_Code;
  AddToLine(Value, Line);

  Value :=FloatToStr(aValue.GST_BusinessNormPercent);
  AddToLine(Value, Line);

  aLines.Add(Line);
end;

{------------------------------------------------------------------------------}
function DetermineMaxRow(const aRates: TVatRates): integer;
var
  i: integer;
begin
  result := 0;

  for i := 1 to MAX_GST_CLASS do
  begin
    with aRates[i] do
    begin
      // Row used?
      if (GST_ID <> '') or
         (GST_Class_Name <> '') or
         (GSTClassType <> 0) or
         (GST_Rates[1] <> 0) or
         (GST_Rates[2] <> 0) or
         (GST_Rates[3] <> 0) or
         (GST_Account_Code <> '') or
         (GST_BusinessNormPercent <> 0)
      then
        result := i;
    end;
  end;
end;

{------------------------------------------------------------------------------}
procedure VatSaveToFile(const aRate1: integer; const aRate2: integer;
  const aRate3: integer; const aRates: TVatRates; const aFileName: string);
var
  Lines: TStringList;
  MaxRow: integer;
  i: integer;
begin
  ASSERT(aFileName <> '');

  Lines := TStringList.Create;
  try
    // Template
    Lines.Add(SECTION_TEMPLATE);
    // Note: don't use MyClient for Code/Name - MyClient might be nil
    Lines.Add('Code=VAT');
    Lines.Add('Name=VAT');
    Lines.Add('Version=2');
    Lines.Add('');

    // Effective Rates
    Lines.Add(SECTION_TAX_STARTS);
    SaveEffectiveRate(1, aRate1, Lines);
    SaveEffectiveRate(2, aRate2, Lines);
    SaveEffectiveRate(3, aRate3, Lines);
    SaveEffectiveRate(4, -1, Lines);
    SaveEffectiveRate(5, -1, Lines);
    Lines.Add('');

    // Rates
    Lines.Add(SECTION_TAX_TABLE);
    MaxRow := DetermineMaxRow(aRates);
    for i := 1 to MaxRow do
    begin
      SaveRate(i, aRates[i], Lines);
    end;

    Lines.SaveToFile(aFileName);
  finally
    FreeAndNil(Lines);
  end;
end;


{------------------------------------------------------------------------------}
procedure VatShowLoadException(const E: Exception);
begin
  HelpfulWarningMsg(
    'Unable to load VAT Template.'+sLineBreak+
    sLineBreak+
    'Details:'+sLineBreak+
    E.Message,
    0);
end;

{------------------------------------------------------------------------------}
procedure VatShowSaveException(const E: Exception);
begin
  HelpfulWarningMsg(
    'Unable to save VAT Template.'+sLineBreak+
    sLineBreak+
    'Details:'+sLineBreak+
    E.Message,
    0);
end;

end.
