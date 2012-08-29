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
  Dialogs,
  XMLIntf,
  XMLDoc,
  WarningMoreFrm,
  YesNoDlg;

const
  DLG_DEFAULTEXT = 'vat';
  DLG_FILTER     = 'VAT Templates (*.vat)|*.vat';

  XML_ROOT = 'Root';

  XML_EFFECTIVE_RATE1 = 'EffectiveRate_1';
  XML_EFFECTIVE_RATE2 = 'EffectiveRate_2';
  XML_EFFECTIVE_RATE3 = 'EffectiveRate_3';

  XML_RATE        = 'Rate_%d';
  XML_ID          = 'ID';
  XML_DESC        = 'Desc';
  XML_GSTTYPE     = 'GSTType';
  XML_RATE1       = 'Rate1';
  XML_RATE2       = 'Rate2';
  XML_RATE3       = 'Rate3';
  XML_ACCOUNT     = 'Account';
  XML_NORMPERCENT = 'NormPercent';

{------------------------------------------------------------------------------}
function VatSetupButtons(const aLevel: TVatLevel;
  const aButtons: array of TButton): boolean;
var
  i: integer;
begin
  // For the UK only
  if (AdminSystem.fdFields.fdCountry = whUK) then
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
function FindNode(const aNode: IXMLNode; const aName: string): IXMLNode;
begin
  ASSERT(assigned(aNode));

  result := aNode.ChildNodes.FindNode(aName);
  if not Assigned(result) then
    raise Exception.Create('XML node <'+aName+'> not found');
end;

{------------------------------------------------------------------------------}
procedure GetEffectiveRate(const aNode: IXMLNode; const aName: string;
  var aRate: integer);
var
  Node: IXMLNode;
begin
  ASSERT(assigned(aNode));

  Node := FindNode(aNode, aName);
  aRate := StrToInt(Node.Text);
end;

{------------------------------------------------------------------------------}
function GetRateNodeName(const aRow: integer): string;
begin
  result := Format(XML_RATE, [aRow]);
end;

{------------------------------------------------------------------------------}
procedure GetRate(const aNode: IXMLNode; var aValue: TVatRatesRow);
var
  ValueNode: IXMLNode;
begin
  ASSERT(assigned(aNode));

  ValueNode := FindNode(aNode, XML_ID);
  aValue.GST_ID := ValueNode.Text;

  ValueNode := FindNode(aNode, XML_DESC);
  aValue.GST_Class_Name := ValueNode.Text;

  ValueNode := FindNode(aNode, XML_GSTTYPE);
  aValue.GSTClassType := StrToInt(ValueNode.Text);

  ValueNode := FindNode(aNode, XML_RATE1);
  aValue.GST_Rates[1] := StrToFloat(ValueNode.Text);

  ValueNode := FindNode(aNode, XML_RATE2);
  aValue.GST_Rates[2] := StrToFloat(ValueNode.Text);

  ValueNode := FindNode(aNode, XML_RATE3);
  aValue.GST_Rates[3] := StrToFloat(ValueNode.Text);

  ValueNode := FindNode(aNode, XML_ACCOUNT);
  aValue.GST_Account_Code := ValueNode.Text;

  ValueNode := FindNode(aNode, XML_NORMPERCENT);
  aValue.GST_BusinessNormPercent := StrToFloat(ValueNode.Text);
end;

{------------------------------------------------------------------------------}
procedure VatLoadFromFile(const aFileName: string; var aRate1: integer;
  var aRate2: integer; var aRate3: integer; var aRates: TVatRates);
var
  Document: IXMLDocument;
  Root: IXMLNode;
  i: integer;
  NodeName: string;
  ValueNode: IXMLNode;
begin
  ASSERT(aFileName <> '');

  // Load the XML
  Document := NewXMLDocument;
  Document.LoadFromFile(aFileName);
  Root := FindNode(Document.Node, XML_ROOT);

  // Load effective rates
  GetEffectiveRate(Root, XML_EFFECTIVE_RATE1, aRate1);
  GetEffectiveRate(Root, XML_EFFECTIVE_RATE2, aRate2);
  GetEffectiveRate(Root, XML_EFFECTIVE_RATE3, aRate3);

  // Load rates
  for i := 1 to MAX_GST_CLASS do
  begin
    NodeName := GetRateNodeName(i);
    ValueNode := FindNode(Root, NodeName);
    GetRate(ValueNode, aRates[i]);
  end;
end;

{------------------------------------------------------------------------------}
procedure AddEffectiveRate(const aNode: IXMLNode; const aName: string;
  const aValue: integer);
var
  Node: IXMLNode;
begin
  ASSERT(assigned(aNode));
  ASSERT(aName <> '');

  // Create node
  Node := aNode.AddChild(aName);
  ASSERT(assigned(Node));

  // Assign value
  Node.Text := IntToStr(aValue);
end;

{------------------------------------------------------------------------------}
procedure AddRate(const aNode: IXMLNode; const aValue: TVatRatesRow);
var
  ValueNode: IXMLNode;
begin
  ValueNode := aNode.AddChild(XML_ID);
  ASSERT(assigned(ValueNode));
  ValueNode.Text := aValue.GST_ID;

  ValueNode := aNode.AddChild(XML_DESC);
  ASSERT(assigned(ValueNode));
  ValueNode.Text := aValue.GST_Class_Name;

  ValueNode := aNode.AddChild(XML_GSTTYPE);
  ASSERT(assigned(ValueNode));
  ValueNode.Text := IntToStr(aValue.GSTClassType);

  ValueNode := aNode.AddChild(XML_RATE1);
  ASSERT(assigned(ValueNode));
  ValueNode.Text := FloatToStr(aValue.GST_Rates[1]);

  ValueNode := aNode.AddChild(XML_RATE2);
  ASSERT(assigned(ValueNode));
  ValueNode.Text := FloatToStr(aValue.GST_Rates[2]);

  ValueNode := aNode.AddChild(XML_RATE3);
  ASSERT(assigned(ValueNode));
  ValueNode.Text := FloatToStr(aValue.GST_Rates[3]);

  ValueNode := aNode.AddChild(XML_ACCOUNT);
  ASSERT(assigned(ValueNode));
  ValueNode.Text := aValue.GST_Account_Code;

  ValueNode := aNode.AddChild(XML_NORMPERCENT);
  ASSERT(assigned(ValueNode));
  ValueNode.Text := FloatToStr(aValue.GST_BusinessNormPercent);
end;

{------------------------------------------------------------------------------}
procedure VatSaveToFile(const aRate1: integer; const aRate2: integer;
  const aRate3: integer; const aRates: TVatRates; const aFileName: string);
var
  Document: IXMLDocument;
  Root: IXMLNode;
  i: integer;
  NodeName: string;
  ValueNode: IXMLNode;
begin
  ASSERT(aFileName <> '');

  Document := NewXMLDocument;
  Root := Document.AddChild(XML_ROOT);

  // Save effective rates
  AddEffectiveRate(Root, XML_EFFECTIVE_RATE1, aRate1);
  AddEffectiveRate(Root, XML_EFFECTIVE_RATE2, aRate2);
  AddEffectiveRate(Root, XML_EFFECTIVE_RATE3, aRate3);

  // Save rates
  for i := 1 to MAX_GST_CLASS do
  begin
    NodeName := GetRateNodeName(i);
    ValueNode := Root.AddChild(NodeName);
    AddRate(ValueNode, aRates[i]);
  end;

  Document.SaveToFile(aFileName);
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
