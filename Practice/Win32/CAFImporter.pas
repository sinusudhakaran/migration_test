unit CAFImporter;

interface

uses
  Classes, SysUtils, XLSFile, XLSWorkbook, PDFFieldEditor, Progress;

const
  UnitName = 'CAFImporter';
  
  HSBCUK_NUMFIELDS = 18;

type
  TCAFFileFormat = (cafPDF=0);
  TCAFImportType = (cafStandardUK=0, cafHSBCUK=1);

  TCAFFileFormats = set of TCAFFileFormat;

  TCAFSource = class
  protected
    function GetEof: Boolean; virtual; abstract;
    function GetCount: Integer; virtual; abstract;
    function GetCurrentRow: Integer; virtual; abstract;
    function GetFieldCount: Integer; virtual; abstract;
  public
    function ValueByIndex(FieldIndex: Integer): String; virtual; abstract;

    procedure First; virtual; abstract;
    procedure Next; virtual; abstract;

    property Eof: Boolean read GetEof;
    property Count: Integer read GetCount;
    property CurrentRow: Integer read GetCurrentRow;
    property FieldCount: Integer read GetFieldCount;
  end;

  TXLSCAFSource = class(TCAFSource)
  private
    FXLSFile: TXLSFile;
    FCurrentSheet: TSheet;
    FCurrentRow: Integer;
    FEof: Boolean;
    FIncludesFieldNames: Boolean;
  protected
    function GetEof: Boolean; override;
    function GetCount: Integer; override;
    function GetCurrentRow: Integer; override;
    function GetFieldCount: Integer; override;
  public
    function ValueByIndex(FieldIndex: Integer): String; override;

    constructor Create(const SourceFile: String; IncludesFieldNames: Boolean); virtual;
    destructor Destroy; override;

    procedure First; override;
    procedure Next; override;
  end;

  TCAFImporterStatistics = record
    Generated: Integer;
    Failed: Integer;
  end;

  TCAFImporterFunc = procedure(Source: TCAFSource; const OutputFolder: String) of object;

  TCAFImporter = class
  private
    FStatistics: TCAFImporterStatistics;
    FErrors: TStringList;
    FCAFCount: Integer;

    function GetImportProc(FileFormat: TCAFFileFormat): TCAFImporterFunc;
    class function ImportTypeToStr(ImportType: TCAFImportType): String; static;
  protected
    function ValidateRecord(Source: TCAFSource): Boolean;
    procedure ImportAsPDF(Source: TCAFSource; const OutputFolder: String); virtual;

    {$REGION 'Descendants must implement'}
    procedure DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String); virtual; abstract;
    function GetPDFTemplateFile: String; virtual; abstract;
    function GetMinFieldCount: Integer; virtual; abstract;
    function GetImporterName: String; virtual; abstract;
    {$ENDREGION}

    procedure Initialize(Source: TCAFSource); virtual;
    function SupportedFormats: TCAFFileFormats; virtual;

    procedure DoFieldValidation(Source: TCAFSource); virtual;
    procedure DoRecordValidation(Source: TCAFSource); virtual;
     
    function IsNumber(const Value: String): Boolean;
    function ContainsSymbols(const Value: String): Boolean;
    function IsLongMonthName(const Value: String): Boolean;

    procedure AddRecordValidationError(Source: TCAFSource; Error: String);
    procedure AddError(Key, Error: String);

    procedure ResetImportStatistics;
    procedure ResetImportErrors;

    function CreateCAFSource(const SourceFile: String): TCAFSource;

    property CAFCount: Integer read FCAFCount;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Import(const ImportFile: String; FileFormat: TCAFFileFormat; const OutputFolder: String; ProgressForm: ISingleProgressForm);

    procedure ValidateRecords(const ImportFile: String; out ValidLines, InvalidLines: Integer);
    function ValidateFields(const ImportFile: String): Boolean;

    class function CreateImporter(ImportType: TCAFImportType): TCAFImporter; static;
    
    property Statistics: TCAFImporterStatistics read FStatistics;
    property Errors: TStringList read FErrors;

    property ImporterName: String read GetImporterName;
  end;

implementation

uses
  DirUtils,
  Globals,
  HSBCCAFImporterUK,
  StandardCAFImporterUK,
  LogUtil;

{ TCAFImporter }

procedure TCAFImporter.AddError(Key, Error: String);
begin
  FErrors.Add(Format('%s=%s', [Key, Error]));
end;

procedure TCAFImporter.AddRecordValidationError(Source: TCAFSource; Error: String);
begin
  AddError(IntToStr(Source.CurrentRow), Error);

  LogUtil.LogMsg(lmInfo, UnitName, Format('Row %s of the Customer Authority Form import file failed validation: %s.', [IntToStr(Source.CurrentRow), Error]));
end;

function TCAFImporter.ContainsSymbols(const Value: String): Boolean;
var
  ValueChar: Char;
begin
  Result := False;
  
  for ValueChar in Value do
  begin
    if not (LowerCase(ValueChar)[1] in['a','b','c','d','e','f','g','h','i','j','k','l','m','n','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'])  then
    begin
      Result := True;

      Break;
    end;
  end;
end;

procedure TCAFImporter.ImportAsPDF(Source: TCAFSource; const OutputFolder: String);
var
  Document: TPdfFieldEdit;
  TemplateFile: String;
  OutputFile: String;
begin
  TemplateFile := AppendFileNameToPath(TemplateDir, GetPDFTemplateFile);

  if FileExists(TemplateFile) then
  begin
    Document := TPdfFieldEdit.Create(nil);

    try
      Document.LoadPDF(TemplateFile);
      
      DoImportAsPDF(Source, Document, OutputFile);

      OutputFile := AppendFileNameToPath(OutputFolder, OutputFile);

      Document.SetInformation(1, ''); //Author
      Document.SetInformation(5, ''); //Creator
      Document.SetInformation(6, ''); //Producer

      Document.SaveToFileFlattened(OutputFile);

      Inc(FCAFCount);
    finally
      Document.Free;
    end;
  end
  else
  begin
    raise Exception.Create(Format('Template document %s not found', [TemplateFile]));
  end;
end;

class function TCAFImporter.ImportTypeToStr(ImportType: TCAFImportType): String;
begin
  case ImportType of
    cafStandardUK: Result := 'Standard/Other UK';
    cafHSBCUK: Result := 'HSBC UK';
    
    else
    begin
      Result := '';
    end;
  end;
end;

procedure TCAFImporter.Initialize(Source: TCAFSource);
begin
  FCAFCount := 0;
end;

constructor TCAFImporter.Create;
begin
  FErrors := TStringList.Create;
end;

function TCAFImporter.CreateCAFSource(const SourceFile: String): TCAFSource;
begin
  if CompareText(ExtractFileExt(SourceFile), '.xls') = 0 then
  begin
    Result := TXLSCAFSource.Create(SourceFile, False);
  end
  else
  begin
    raise Exception.Create('Unsupported file type');
  end;
end;

class function TCAFImporter.CreateImporter(ImportType: TCAFImportType): TCAFImporter;
begin
  case ImportType of
    cafHSBCUK: Result := THSBCCAFImporterUK.Create;

    cafStandardUK: Result := TStandardCAFImporterUK.Create;

    else
    begin
      raise Exception.Create('There are currently no importers of that support this combination of country and importer type');
    end;
  end;
end;

destructor TCAFImporter.Destroy;
begin
  FErrors.Free;
  
  inherited;
end;

procedure TCAFImporter.DoFieldValidation(Source: TCAFSource);
begin

end;

procedure TCAFImporter.DoRecordValidation(Source: TCAFSource);
begin

end;

function TCAFImporter.GetImportProc(FileFormat: TCAFFileFormat): TCAFImporterFunc;
begin
  Result := nil;

  if FileFormat in SupportedFormats then
  begin
    case FileFormat of
      cafPDF: Result := ImportAsPDF;
    end;
  end;
end;

procedure TCAFImporter.Import(const ImportFile: String; FileFormat: TCAFFileFormat; const OutputFolder: String; ProgressForm: ISingleProgressForm);
var
  CAFSource: TCAFSource;
  ImportFunc: TCAFImporterFunc;
  ProgressStepSize: Double;
begin
  if not DirectoryExists(OutputFolder) then
  begin
    raise Exception.Create(Format('Output folder %s does not exist.', [OutputFolder]));
  end;
     
  ResetImportStatistics;

  ImportFunc := GetImportProc(FileFormat);

  if Assigned(ImportFunc) then
  begin
    CAFSource := CreateCAFSource(ImportFile);

    try
      CAFSource.First;

      Initialize(CAFSource);

      ProgressStepSize := 100 / CAFSource.GetCount;
      
      ProgressForm.Initialize;

      ProgressForm.UpdateProgressLabel('');

      while not CAFSource.Eof do
      begin
        if ValidateRecord(CAFSource) then
        begin
          ImportFunc(CAFSource, OutputFolder);

          FStatistics.Generated := FStatistics.Generated + 1;
        end
        else
        begin
          FStatistics.Failed := FStatistics.Failed + 1;
        end;

        CAFSource.Next;

        ProgressForm.UpdateProgress(ProgressStepSize); 
      end;
    finally
      CAFSource.Free;
    end;
  end;
end;

function TCAFImporter.IsLongMonthName(const Value: String): Boolean;
var
  Index: Integer;
begin
  Result := False;
  
  for Index := 1 to 12 do
  begin
    if CompareText(Value, LongMonthNames[Index]) = 0 then
    begin
      Result := True;

      Break;
    end;
  end;
end;

function TCAFImporter.IsNumber(const Value: String): Boolean;
var
  Temp: Integer;
begin
  Result := TryStrToInt(Value, Temp);
end;

procedure TCAFImporter.ResetImportErrors;
begin
  FErrors.Clear;
end;

procedure TCAFImporter.ResetImportStatistics;
begin
  FStatistics.Generated := 0;
  FStatistics.Failed := 0;
end;

function TCAFImporter.SupportedFormats: TCAFFileFormats;
begin
  Result := [];
end;

function TCAFImporter.ValidateFields(const ImportFile: String): Boolean;
var
  CAFSource: TCAFSource;
begin
  CAFSource := CreateCAFSource(ImportFile);

  try
    FErrors.Clear;

    if CAFSource.FieldCount < GetMinFieldCount then
    begin
      AddError('FieldCount', Format('The number of fields is %s, expected %s', [IntToStr(CAFSource.FieldCount), IntToStr(GetMinFieldCount)]));

      LogUtil.LogMsg(lmInfo, UnitName, Format('The number of fields in the Customer Authority Form import file is %s, expected %s', [IntToStr(CAFSource.FieldCount), IntToStr(GetMinFieldCount)]));
    end
    else
    begin
      DoFieldValidation(CAFSource);
    end;
    
    Result := FErrors.Count = 0;
  finally
    CAFSource.Free;
  end;
end;

procedure TCAFImporter.ValidateRecords(const ImportFile: String; out ValidLines, InvalidLines: Integer);
var
  CAFSource: TCAFSource;
begin
  ValidLines := 0;
  InvalidLines := 0;

  CAFSource := CreateCAFSource(ImportFile);

  try
    CAFSource.First;

    Initialize(CAFSource);

    while not CAFSource.Eof do
    begin
      if ValidateRecord(CAFSource) then
      begin
        Inc(ValidLines);
      end
      else
      begin
        Inc(InvalidLines);
      end;

      CAFSource.Next;
    end;
  finally
    CAFSource.Free;
  end;
end;

function TCAFImporter.ValidateRecord(Source: TCAFSource): Boolean;
begin
  FErrors.Clear;
  
  DoRecordValidation(Source);
  
  Result := FErrors.Count = 0;
end;

{ TXLSCAFSource }

constructor TXLSCAFSource.Create(const SourceFile: String; IncludesFieldNames: Boolean);
begin
  FCurrentSheet := nil;

  FIncludesFieldNames := IncludesFieldNames;
  
  FEof := True;
  
  FXLSFile := TXLSFile.Create;

  FXLSFile.OpenFile(SourceFile);
  
  if Assigned(FXLSFile.Workbook) then
  begin
    if FXLSFile.Workbook.Sheets.Count > 0 then
    begin
      FCurrentSheet := FXLSFile.Workbook.Sheets[0];
    end;
  end;

  First;
end;

destructor TXLSCAFSource.Destroy;
begin
  FXLSFile.Free;
  
  inherited;
end;

procedure TXLSCAFSource.First;
begin
  if Assigned(FCurrentSheet) then
  begin
    if FIncludesFieldNames then
    begin
      FCurrentRow := 1;
    end
    else
    begin
      FCurrentRow := 0;
    end;

    if Count > 0 then
    begin
      FEof := False;
    end;
  end;
end;

function TXLSCAFSource.GetCount: Integer;
begin
  if Assigned(FCurrentSheet) then
  begin
    if FIncludesFieldNames then
    begin
      Result := FCurrentSheet.Rows.Count -1;
    end
    else
    begin
      Result := FCurrentSheet.Rows.Count;
    end;
  end
  else
  begin
    Result := 0;
  end;
end;

function TXLSCAFSource.GetCurrentRow: Integer;
begin
  Result := FCurrentRow;
end;

function TXLSCAFSource.GetEof: Boolean;
begin
  Result := FEof;
end;

function TXLSCAFSource.GetFieldCount: Integer;
begin
  Result := FCurrentSheet.Columns.Count;
end;

procedure TXLSCAFSource.Next;
begin
  if Assigned(FCurrentSheet) then
  begin
    Inc(FCurrentRow);

    if FCurrentRow >= Count then
    begin
      FEof := True;
    end;
  end;
end;

function TXLSCAFSource.ValueByIndex(FieldIndex: Integer): String;
begin
  if Assigned(FCurrentSheet) then
  begin
    Result := FCurrentSheet.Cells.Cell[FCurrentRow, FieldIndex].ValueAsString;
  end
  else
  begin
    raise Exception.Create('There is no current worksheet');
  end;
end;
end.
