unit Templates;
//------------------------------------------------------------------------------
//
//   A template file is a text file which contains all the GST & BAS setup and
//   chart information for a client. We use some standard template files to create
//   default GST tables when we import a client's chart.
//
//------------------------------------------------------------------------------
interface

uses
  BKDefs,
  chList32,
  Classes;

Type
  tpl_CreateChartType = ( tpl_CreateChartFromTemplate, tpl_DontCreateChart );
  TTemplateError = (trtDoesNotExist, trtInvalid);

  //----------------------------------------------------------------------------
  TTemplates = class
    private
      function BooleanToYN(aValue : boolean) : string;
    protected
      // Save Template
      function GetTemplateFileToSave(var aTemplateFileName: string) : boolean;
      procedure WriteHeaderSection(const aTemplateFile : TextFile; const aCLFields : TClient_Rec);
      procedure WriteTaxStartsSection(const aTemplateFile : TextFile; const aCLFields : TClient_Rec);
      procedure WriteTaxTableSection(const aTemplateFile : TextFile; const aCLFields : TClient_Rec);
      procedure WriteChartSection(const aTemplateFile : TextFile; const aCLChart : TChart);
      procedure WriteBASRulesSection(const aTemplateFile : TextFile; const aCLFields : TClient_Rec);

      function GetFieldFromCurrentLine(const aCurrentLine : ShortString; aFieldNum : Integer ): ShortString;
      function GetTemplateFileToLoad(var aTemplateFileName: string) : boolean;
      procedure ClearGSTFields(var aCLFields : TClient_Rec);
      procedure ClearBASFields(var aCLFields : TClient_Rec);
      function ReadHeaderSection(const aTemplateFile : TextFile;
                                 var aCurrentLine : ShortString;
                                 var aMultiplyBy : Integer) : boolean;
      function ReadTaxStartSection(const aTemplateFile : TextFile;
                                   var aCurrentLine : ShortString;
                                   var aCLFields : TClient_Rec) : boolean;
      function ReadTaxTableSection(const aTemplateFile : TextFile;
                                   var aCurrentLine : ShortString;
                                   var aCLFields : TClient_Rec;
                                   aMultiplyBy : Integer) : boolean;
      function ReadChartSection(const aTemplateFile : TextFile;
                                var aCurrentLine : ShortString;
                                var aCLChart : TChart;
                                aCreateChart : boolean) : boolean;
      function ReadBASRulesSection(const aTemplateFile : TextFile;
                                   var aCurrentLine : ShortString;
                                   var aCLFields : TClient_Rec;
                                   aMultiplyBy : Integer) : boolean;
      procedure SetGSTItem(var aCLFields : TClient_Rec;
                           aIndex : integer; aClassCode, aClassName : string;
                           aClassType : integer; aRate1 : integer);
    public
      procedure SaveAsTemplate;

      procedure LoadFromTemplate;

      function  LoadTemplate(const aTemplateFilename : String;
                             const aCreateChartifFound : tpl_CreateChartType;
                             var aTemplateErrorType : TTemplateError ): Boolean;
      procedure LoadNZMYOBLedgerTemplate();
  end;

  function Template : TTemplates;

//------------------------------------------------------------------------------
implementation

uses
  Globals,
  glconst,
  bkDateUtils,
  StDate,
  BASUtils,
  SysUtils,
  InfoMoreFrm,
  StStrS,
  Dialogs,
  BKconst,
  BKchIO,
  GenUtils,
  GSTUtil32,
  WinUtils,
  LogUtil,
  YesNoDlg;

const
  TEMPLATE_VERSION = 2;
  UnitName = 'Templates';
  tsHeader   = 0;     tsMin = 0;
  tsTaxStart = 1;
  tsTaxTable = 2;
  tsChart    = 3;
  tsBASRules = 4;     tsMax = 4;
  tsNames : Array[ tsMin..tsMax ] of String[20] =
      (  'Header',
         'Tax Start',
         'Tax Table',
         'Chart',
         'BAS Rules');

var
  fTemplate : TTemplates;
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
function Template : TTemplates;
begin
  if not assigned(fTemplate) then
  begin
    fTemplate := TTemplates.Create;
  end;

  result := fTemplate;
end;

// TTemplates
//------------------------------------------------------------------------------
function TTemplates.BooleanToYN(aValue: boolean): string;
begin
  if aValue then
    Result := 'Y'
  else
    Result := 'N';
end;

//------------------------------------------------------------------------------
// Allow the user to select a different template name
function TTemplates.GetTemplateFileToSave(var aTemplateFileName : string) : boolean;
var
  SaveDlg : TSaveDialog;
begin
  Result := false;

  SaveDlg := TSaveDialog.Create( NIL );
  try
    SaveDlg.InitialDir := GLOBALS.TemplateDir;
    SaveDlg.FileName   := MyClient.clFields.clCode + '.TPL';
    SaveDlg.Filter     := 'Template files (*.tpl)|*.TPL';
    SaveDlg.DefaultExt := 'TPL';
    SaveDlg.Options    := [ ofNoChangeDir, ofHideReadOnly ];

    if SaveDlg.Execute then
      aTemplateFileName := SaveDlg.FileName
    else
      exit;

    while BKFileExists(aTemplateFileName) do
    begin
      if AskYesNo('Overwrite File','The file ' + ExtractFileName(aTemplateFileName) +
                  ' already exists. Overwrite?', dlg_yes, 0) = DLG_YES then
        Break;

      if not SaveDlg.Execute then
        exit;

      aTemplateFileName := SaveDlg.FileName
    end;
  finally
    FreeAndNil(SaveDlg);
    //make sure all relative paths are relative to data dir after browse
    SysUtils.SetCurrentDir( Globals.DataDir);
  end;
end;

//------------------------------------------------------------------------------
procedure TTemplates.WriteHeaderSection(const aTemplateFile : TextFile; const aCLFields : TClient_Rec);
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'WriteHeaderSection called');

  writeln(aTemplateFile, '[Template]');

  writeln(aTemplateFile, 'Code=', aCLFields.clCode);
  writeln(aTemplateFile, 'Name=', aCLFields.clName);
  writeln(aTemplateFile, 'Version=' + inttostr(TEMPLATE_VERSION));

  writeln(aTemplateFile);
end;

//------------------------------------------------------------------------------
procedure TTemplates.WriteTaxStartsSection(const aTemplateFile : TextFile; const aCLFields : TClient_Rec);
var
  GSTAppliesIndex : integer;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'WriteTaxStartsSection called');

  writeln(aTemplateFile, '[Tax Starts]');

  for GSTAppliesIndex := 1 to 5 do
    writeln(aTemplateFile, GSTAppliesIndex, '|', bkDate2Str(aCLFields.clGST_Applies_From[GSTAppliesIndex ]));

  writeln(aTemplateFile);
end;

//------------------------------------------------------------------------------
procedure TTemplates.WriteTaxTableSection(const aTemplateFile : TextFile; const aCLFields : TClient_Rec);
var
  GstIndex : integer;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'WriteTaxTableSection called');

  writeln(aTemplateFile, '[Tax Table]');

  for GstIndex := 1 to MAX_GST_CLASS do
  begin
    if aCLFields.clGST_Class_Codes[GstIndex ] <> '' then
    begin
      writeln(aTemplateFile,
              GstIndex, '|',
              aCLFields.clGST_Class_Codes[ GstIndex ], '|',
              aCLFields.clGST_Class_Names[ GstIndex ], '|',
              aCLFields.clGST_Rates[ GstIndex, 1 ]:0:0, '|',
              aCLFields.clGST_Rates[ GstIndex, 2 ]:0:0, '|',
              aCLFields.clGST_Rates[ GstIndex, 3 ]:0:0, '|',
              aCLFields.clGST_Rates[ GstIndex, 4 ]:0:0, '|',
              aCLFields.clGST_Rates[ GstIndex, 5 ]:0:0, '|',
              aCLFields.clGST_Account_Codes[ GstIndex ], '|',
              aCLFields.clGST_Business_Percent[ GstIndex]:0:0);
    end;
  end;

  writeln(aTemplateFile);
end;

//------------------------------------------------------------------------------
procedure TTemplates.WriteChartSection(const aTemplateFile : TextFile; const aCLChart : TChart);
var
  ChartIndex : integer;
  ChartAccount : pAccount_Rec;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'WriteChartSection called');

  if not assigned(aCLChart) then
    exit;

  writeln(aTemplateFile, '[Chart]' );

  for ChartIndex := 0 to aCLChart.ItemCount-1 do
  begin
    ChartAccount := aCLChart.Account_At(ChartIndex);

    writeln(aTemplateFile,
            ChartAccount^.chAccount_Code, '|',
            ChartAccount^.chAccount_Description, '|',
            ChartAccount^.chGST_Class, '|',
            BooleanToYN(ChartAccount^.chPosting_Allowed), '|',
            ChartAccount^.chAccount_Type, '|',
            BooleanToYN(ChartAccount^.chEnter_Quantity));
  end;

  writeln(aTemplateFile);
end;

//------------------------------------------------------------------------------
procedure TTemplates.WriteBASRulesSection(const aTemplateFile : TextFile; const aCLFields : TClient_Rec);
var
  BASIndex : integer;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'WriteBASRulesSection called');

  writeln(aTemplateFile, '[BAS Rules]');

  for BASIndex := MIN_SLOT to MAX_SLOT do
  begin
    if aCLFields.clBAS_Field_Number[BASIndex] > 0 then
    begin
      writeln(aTemplateFile,
              aCLFields.clBAS_Field_Number[BASIndex], '|',
              aCLFields.clBAS_Field_Source[BASIndex], '|',
              aCLFields.clBAS_Field_Account_Code[BASIndex], '|',
              aCLFields.clBAS_Field_Balance_Type[BASIndex], '|',
              aCLFields.clBAS_Field_Percent[BASIndex]:0:0);
    end;
  end;

  writeln(aTemplateFile);
end;

//------------------------------------------------------------------------------
function TTemplates.GetFieldFromCurrentLine(const aCurrentLine : ShortString; aFieldNum : Integer): ShortString;
var
  LineLength : integer;
  LineIndex : integer;
  CurrFieldNum : integer;
begin
  Result := '';
  LineLength := length(aCurrentLine);

  if LineLength = 0 then
    exit;

  CurrFieldNum := 1;
  for LineIndex := 1 to LineLength do
  begin
    Case aCurrentLine[LineIndex] of
      '|' : begin
        if CurrFieldNum = aFieldNum then
          exit;
        Inc(CurrFieldNum);
        Result := '';
      end;
    else
      Result := Result + aCurrentLine[LineIndex];
    end;
  end;

  if (CurrFieldNum = aFieldNum) then
    exit;

  Result := '';
end;

//------------------------------------------------------------------------------
function TTemplates.GetTemplateFileToLoad(var aTemplateFileName: string): boolean;
var
  OpenDlg : TOpenDialog;
begin
  Result := false;
  aTemplateFileName := '';

  OpenDlg := TOpenDialog.Create(nil);
  try
    OpenDlg.InitialDir := GLOBALS.TemplateDir;
    OpenDlg.Filter     := 'All Template files (*.tpl; *.tpm)|*.TPL;*.TPM|Template files (*.tpl)|*.TPL|Master Template files (*.tpm)|*.TPM';
    OpenDlg.Filename   := '';
    OpenDlg.Options    := [ofNoChangeDir, ofHideReadOnly];

    if (OpenDlg.Execute) and (not (aTemplateFileName = '')) then
    begin
      aTemplateFileName := OpenDlg.FileName;
      Result := true;
    end;
  finally
    FreeAndNil(OpenDlg);
    //make sure all relative paths are relative to data dir after browse
    SysUtils.SetCurrentDir(Globals.DataDir);
  end;
end;

//------------------------------------------------------------------------------
procedure TTemplates.ClearBASFields(var aCLFields: TClient_Rec);
begin
  FillChar(aCLFields.clBAS_Field_Number       ,Sizeof(aCLFields.clBAS_Field_Number), 0);
  FillChar(aCLFields.clBAS_Field_Source       ,Sizeof(aCLFields.clBAS_Field_Source), 0);
  FillChar(aCLFields.clBAS_Field_Account_Code ,Sizeof(aCLFields.clBAS_Field_Account_Code), 0);
  FillChar(aCLFields.clBAS_Field_Balance_Type ,Sizeof(aCLFields.clBAS_Field_Balance_Type), 0);
  FillChar(aCLFields.clBAS_Field_Percent      ,Sizeof(aCLFields.clBAS_Field_Percent), 0);
end;

//------------------------------------------------------------------------------
procedure TTemplates.ClearGSTFields(var aCLFields: TClient_Rec);
begin
  FillChar(aCLFields.clGST_Class_Codes      ,Sizeof(aCLFields.clGST_Class_Codes), 0);
  FillChar(aCLFields.clGST_Applies_From     ,Sizeof(aCLFields.clGST_Applies_From), 0);
  FillChar(aCLFields.clGST_Class_Names      ,Sizeof(aCLFields.clGST_Class_Names), 0);
  FillChar(aCLFields.clGST_Class_Types      ,Sizeof(aCLFields.clGST_Class_Types), 0);
  FillChar(aCLFields.clGST_Account_Codes    ,Sizeof(aCLFields.clGST_Account_Codes), 0);
  FillChar(aCLFields.clGST_Rates            ,Sizeof(aCLFields.clGST_Rates), 0);
  FillChar(aCLFields.clGST_Business_Percent ,Sizeof(aCLFields.clGST_Business_Percent), 0);
end;

//------------------------------------------------------------------------------
// Change to support 4.d.p. - do not upgrade new templates!
function TTemplates.ReadHeaderSection(const aTemplateFile : TextFile;
                                      var aCurrentLine : ShortString;
                                      var aMultiplyBy : Integer): boolean;
begin
  Result := false;

  if aCurrentLine = '[Template]' then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'ReadHeaderSection, ' + aCurrentLine + ' found.');

    repeat
      Readln( aTemplateFile, aCurrentLine );
      if aCurrentLine <> '' then
      begin
        if Lowercase(aCurrentLine) = 'version=2' then
          aMultiplyBy := 1;
      end;
    until (aCurrentLine = '') or (aCurrentLine='[Tax Starts]');
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TTemplates.ReadTaxStartSection(const aTemplateFile: TextFile;
                                        var aCurrentLine: ShortString;
                                        var aCLFields : TClient_Rec): boolean;
var
  GSTAppliesIndex : integer;
begin
  Result := false;

  if aCurrentLine = '[Tax Starts]' then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'ReadTaxStartSection, ' + aCurrentLine + ' found.');

    repeat
      Readln( aTemplateFile, aCurrentLine );
      if aCurrentLine <> '' then
      begin
        GSTAppliesIndex := GenUtils.Str2Long(GetFieldFromCurrentLine(aCurrentLine, 1));
        if GSTAppliesIndex in [1..5] then
        begin
          aCLFields.clGST_Applies_From[GSTAppliesIndex] := bkStr2Date(GetFieldFromCurrentLine(aCurrentLine, 2));
        end;
      end;
      Result := true;
    until (aCurrentLine = '');
  end;
end;

//------------------------------------------------------------------------------
function TTemplates.ReadTaxTableSection(const aTemplateFile: TextFile;
                                        var aCurrentLine: ShortString;
                                        var aCLFields: TClient_Rec;
                                        aMultiplyBy : Integer): boolean;
var
  FieldNum : integer;
  Value : LongInt;
begin
  Result := false;

  if aCurrentLine = '[Tax Table]' then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'ReadTaxTableSection, ' + aCurrentLine + ' found.');

    repeat
      Readln(aTemplateFile, aCurrentLine);
      if aCurrentLine <> '' then
      begin
        FieldNum := Str2Long(GetFieldFromCurrentLine(aCurrentLine, 1));
        if FieldNum in [1..MAX_GST_CLASS] then
        begin
          aCLFields.clGST_Class_Codes[FieldNum] := GetFieldFromCurrentLine(aCurrentLine, 2);
          aCLFields.clGST_Class_Names[FieldNum] := GetFieldFromCurrentLine(aCurrentLine, 3);

          Value := Str2Long( GetFieldFromCurrentLine(aCurrentLine, 4));
          aCLFields.clGST_Rates[FieldNum, 1] := Value * aMultiplyBy;
          Value := Str2Long( GetFieldFromCurrentLine(aCurrentLine, 5));
          aCLFields.clGST_Rates[FieldNum, 2] := Value * aMultiplyBy;
          Value := Str2Long( GetFieldFromCurrentLine(aCurrentLine, 6));
          aCLFields.clGST_Rates[FieldNum, 3] := Value * aMultiplyBy;
          Value := Str2Long( GetFieldFromCurrentLine(aCurrentLine, 7));
          aCLFields.clGST_Rates[FieldNum, 4] := Value * aMultiplyBy;
          Value := Str2Long( GetFieldFromCurrentLine(aCurrentLine, 8));
          aCLFields.clGST_Rates[FieldNum, 5] := Value * aMultiplyBy;

          aCLFields.clGST_Account_Codes[FieldNum] := GetFieldFromCurrentLine(aCurrentLine, 9);
          Value := Str2Long( GetFieldFromCurrentLine(aCurrentLine, 10));
          aCLFields.clGST_Business_Percent[FieldNum] := Value;
        end;
      end;
    until (aCurrentLine = '');
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TTemplates.ReadChartSection(const aTemplateFile: TextFile;
                                     var aCurrentLine: ShortString;
                                     var aCLChart: TChart;
                                     aCreateChart : boolean): boolean;
var
  ChartCode      : BK5CodeStr;
  ChartDesc      : String[80];
  ChartGST_Class : Integer;
  ChartType      : Integer;
  ChartQty       : Boolean;
  ChartPostOK    : Boolean;
  ChartAcc       : pAccount_Rec;
begin
  Result := false;

  if not assigned(aCLChart) then
    exit;

  if aCurrentLine = '[Chart]' then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'ReadChartSection, ' + aCurrentLine + ' found.');

    repeat
      Readln(aTemplateFile, aCurrentLine);

      if aCurrentLine <> '' then
      begin
        ChartCode      := GetFieldFromCurrentLine(aCurrentLine, 1);
        ChartDesc      := GetFieldFromCurrentLine(aCurrentLine, 2);
        ChartGST_Class := Str2Long(GetFieldFromCurrentLine(aCurrentLine, 3));
        ChartPostOK    := (GetFieldFromCurrentLine(aCurrentLine, 4) = 'Y');
        ChartType      := Str2Long( GetFieldFromCurrentLine(aCurrentLine, 5));
        ChartQty       := (GetFieldFromCurrentLine(aCurrentLine, 6) = 'Y');

        if aCreateChart then
        begin
          if aCLChart.FindCode(ChartCode) = nil then
          begin
            ChartAcc := New_Account_Rec;
            ChartAcc^.chAccount_Code        := ChartCode;
            ChartAcc^.chAccount_Description := ChartDesc;

            if ChartGST_Class in [0..MAX_GST_CLASS] then
              ChartAcc^.chGST_Class := ChartGST_Class;

            ChartAcc^.chAccount_Type        := ChartType;
            ChartAcc^.chPosting_Allowed     := ChartPostOK;
            ChartAcc^.chEnter_Quantity      := ChartQty;

            MyClient.clChart.Insert(ChartAcc);
          end;
        end
        else
        begin
          ChartAcc := aCLChart.FindCode(ChartCode);
          if Assigned(ChartAcc) then
          begin
            if ChartGST_Class in [ 0..MAX_GST_CLASS ] then
              ChartAcc^.chGST_Class := ChartGST_Class;
          end;
        end;
      end;
    until (aCurrentLine = '');
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TTemplates.ReadBASRulesSection(const aTemplateFile: TextFile;
                                        var aCurrentLine: ShortString;
                                        var aCLFields: TClient_Rec;
                                        aMultiplyBy : Integer): boolean;
var
  Slot : Integer;
  FieldNum : integer;
  Value : LongInt;
begin
  Result := false;

  if aCurrentLine = '[BAS Rules]' then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'ReadBASRulesSection, ' + aCurrentLine + ' found.');

    Slot := 0;
    repeat
      Readln(aTemplateFile, aCurrentLine);

      if aCurrentLine <> '' then
      begin
        FieldNum := Str2Long(GetFieldFromCurrentLine(aCurrentLine, 1));

        if FieldNum in [bfMin..bfMax] then
        begin
          Inc(Slot);

          if (Slot in [MIN_SLOT..MAX_SLOT]) then
          begin
            aCLFields.clBAS_Field_Number[ Slot ]       := FieldNum;
            aCLFields.clBAS_Field_Source[ Slot ]       := Str2Byte(GetFieldFromCurrentLine(aCurrentLine, 2));
            aCLFields.clBAS_Field_Account_Code[ Slot ] := GetFieldFromCurrentLine(aCurrentLine, 3);
            aCLFields.clBAS_Field_Balance_Type[ Slot ] := Str2Byte(GetFieldFromCurrentLine(aCurrentLine, 4));
            if Str2LongS(GetFieldFromCurrentLine(aCurrentLine, 5), Value ) then
              aCLFields.clBAS_Field_Percent[ Slot ] := Value * aMultiplyBy;
          end;
        end;
      end;
    until (aCurrentLine = '');
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TTemplates.SetGSTItem(var aCLFields : TClient_Rec;
                                aIndex : integer; aClassCode, aClassName : string;
                                aClassType : integer; aRate1 : integer);
begin
  aCLFields.clGST_Class_Codes[aIndex]   := aClassCode;
  aCLFields.clGST_Class_Names[aIndex]   := aClassName;
  aCLFields.clGST_Class_Types[aIndex]   := aClassType;
  aCLFields.clGST_Account_Codes[aIndex] := '';
  aCLFields.clGST_Business_Percent[aIndex] := 0;  //not used for NZ but make sure zero anyway

  aCLFields.clGST_Rates[aIndex, 1] := aRate1 * 10000;
  aCLFields.clGST_Rates[aIndex, 2] := 0;
  aCLFields.clGST_Rates[aIndex, 3] := 0;
  aCLFields.clGST_Rates[aIndex, 4] := 0;
  aCLFields.clGST_Rates[aIndex, 5] := 0;
end;

//------------------------------------------------------------------------------
procedure TTemplates.SaveAsTemplate;
var
  TemplateFile : TextFile;
  TemplateFileName : String;
  AllOK : Boolean;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'SaveAsTemplate called');

  if not assigned(MyClient) then
    exit;

  try
    if not DirectoryExists(GLOBALS.TemplateDir) then
      CreateDir(GLOBALS.TemplateDir);

    if not GetTemplateFileToSave(TemplateFileName) then
      exit;

    AssignFile(TemplateFile, TemplateFileName);
    Rewrite(TemplateFile);
    try
      WriteHeaderSection(TemplateFile, MyClient.clFields);
      WriteTaxStartsSection(TemplateFile, MyClient.clFields);
      WriteTaxTableSection(TemplateFile, MyClient.clFields);
      WriteChartSection(TemplateFile, MyClient.clChart);
      WriteBASRulesSection(TemplateFile, MyClient.clFields);

      AllOK := True;
    finally
      CloseFile(TemplateFile);
    end;

    if AllOK then
      HelpfulInfoMsg('Template saved to '+ TemplateFileName, 0 );
  except
    on E: Exception do
    begin
      LogUtil.LogMsg(lmError, UnitName, 'SaveAsTemplate : ' + E.Message);
      raise;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TTemplates.LoadFromTemplate;
var
  TemplateFileName : String;
  TemplateErrorType : TTemplateError;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'LoadFromTemplate called');

  if not Assigned(MyClient) then
    exit;

  if not GetTemplateFileToLoad(TemplateFileName) then
    exit;

  if LoadTemplate(TemplateFilename, tpl_CreateChartFromTemplate, TemplateErrorType) then
  begin
    HelpfulInfoMsg('Template loaded from '+TemplateFileName, 0);
    //now reload the gst defaults for the client
    GSTUTIL32.ApplyDefaultGST(false);
  end;
end;

//------------------------------------------------------------------------------
function TTemplates.LoadTemplate(const aTemplateFilename: String;
                                 const aCreateChartifFound: tpl_CreateChartType;
                                 var aTemplateErrorType : TTemplateError): Boolean;

var
  TemplateFile : TextFile;
  CurrentLine  : ShortString;
  CreateChart  : Boolean;
  MultiplyBy   : Integer;
  Index : integer;
  FoundSection : Array[tsMin..tsMax] of boolean;

  procedure CheckDuplicate(aSection : integer);
  begin
    if FoundSection[aSection] then
      raise Exception.Create('Error Reading Template ' + tsNames[aSection] + ' - Duplicate Section found.')
    else
      FoundSection[aSection] := true;
  end;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'LoadTemplate called, File : ' + aTemplateFilename);

  Result := False;
  if not Assigned(MyClient) then
    exit;

  if (aTemplateFilename = '') then
    exit;

  if not BKFileExists(aTemplateFilename) then
  begin
    aTemplateErrorType := trtDoesNotExist;
    LogUtil.LogMsg(lmError, UnitName, 'LoadTemplate : File not found, ' + aTemplateFilename);
    exit;
  end;

  try
    for Index := tsMin to tsMax do
      FoundSection[Index] := false;

    ClearGSTFields(MyClient.clFields);
    ClearBASFields(MyClient.clFields);

    CreateChart := (MyClient.clChart.ItemCount = 0) and
                   (aCreateChartifFound = tpl_CreateChartFromTemplate);

    Assign(TemplateFile, aTemplateFilename);
    try
      Reset(TemplateFile);

      // Change to support 4.d.p. - upgrade old templates
      MultiplyBy := 100;

      While not EOF(TemplateFile) do
      begin
        Readln(TemplateFile, CurrentLine);

        if ReadHeaderSection(TemplateFile, CurrentLine, MultiplyBy) then
          CheckDuplicate(tsHeader);
        if ReadTaxStartSection(TemplateFile, CurrentLine, MyClient.clFields) then
          CheckDuplicate(tsTaxStart);
        if ReadTaxTableSection(TemplateFile, CurrentLine, MyClient.clFields, MultiplyBy) then
          CheckDuplicate(tsTaxTable);
        if ReadChartSection(TemplateFile, CurrentLine, MyClient.clChart, CreateChart) then
          CheckDuplicate(tsChart);
        if ReadBASRulesSection(TemplateFile, CurrentLine, MyClient.clFields, MultiplyBy) then
          CheckDuplicate(tsBASRules);
      end;

      for Index := tsMin to tsMax do
      begin
        if not FoundSection[Index] then
          raise Exception.Create('Error Reading Template ' + tsNames[Index] + ' - Section not found.')
      end;

      Result := True;
    finally
      CloseFile(TemplateFile);
    end;
  except
    on E: Exception do
    begin
      LogUtil.LogMsg(lmError, UnitName, 'LoadTemplate : ' + E.Message);
      aTemplateErrorType := trtInvalid;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TTemplates.LoadNZMYOBLedgerTemplate;
begin
  ClearGSTFields(MyClient.clFields);
  // Start date is hardcoded for NZ version
  MyClient.clFields.clGST_Applies_From[1] := bkStr2Date('01/01/00');

  SetGSTItem(MyClient.clFields, 1, 'GSTI', 'GST (Input)',              gtExpenditureGST, 15);
  SetGSTItem(MyClient.clFields, 2, 'GSTO', 'GST (Output)',             gtIncomeGST,      15);
  SetGSTItem(MyClient.clFields, 3, 'E',    'Exempt',                   gtExempt,         0);
  SetGSTItem(MyClient.clFields, 4, 'NTR',  'Not Reportable',           gtExempt,         0);
  SetGSTItem(MyClient.clFields, 5, 'Z',    'Zero Rated',               gtZeroRated,      0);
  SetGSTItem(MyClient.clFields, 6, 'I',    'GST on imported supplies', gtCustoms,        0);
  SetGSTItem(MyClient.clFields, 7, 'NONE', 'Uncategorised',            gtExempt,         0);
end;

//------------------------------------------------------------------------------
initialization
begin
  DebugMe := DebugUnit(UnitName);
  fTemplate := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  FreeAndNil(fTemplate);
end;

end.
