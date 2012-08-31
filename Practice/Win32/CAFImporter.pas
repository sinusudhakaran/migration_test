unit CAFImporter;

interface

uses
  Classes, SysUtils, XLSFile, XLSWorkbook;

const
  HSBCUK_NUMFIELDS = 18;

type
  TCAFFileFormat = (cafPDF=0);
  TCAFImportType = (cafStandard=0, cafHSBC=1);

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
    
    function ValueByIndex(FieldIndex: Integer): String; override;
  public
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
  protected
    procedure ImportAsPDF(Source: TCAFSource; const OutputFile: String); virtual;
    
    function ValidateRecord(Source: TCAFSource): Boolean; virtual; abstract;
    function ValidateFields(Source: TCAFSource): Boolean; virtual; abstract;

    function IsNumber(const Value: String): Boolean;
    function ContainsSymbols(const Value: String): Boolean;
    function IsLongMonthName(const Value: String): Boolean;

    procedure AddImportError(Row: Integer; Error: String);
    procedure ResetImportStatistics;
    procedure ResetImportErrors;

    function CreateCAFSource(const SourceFile: String): TCAFSource;

    procedure Initialize(Source: TCAFSource); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure Import(const ImportFile: String; FileFormat: TCAFFileFormat; const OutputFolder: String);

    procedure ValidateImportRecords(const ImportFile: String; out ValidLines, InvalidLines: Integer);
    function ValidateImportFields(const ImportFile: String): Boolean;

    class function CreateImporter(ImportType: TCAFImportType): TCAFImporter; static;

    property Statistics: TCAFImporterStatistics read FStatistics;
    property Errors: TStringList read FErrors;
  end;
  
implementation

uses
  DirUtils, HSBCCAFImporterUK, StandardCAFImporterUK;
  
const
  LONG_MONTH_NAMES: array[0..11] of String = ('JANUARY', 'FEBUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGEST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER');

{ TCAFImporter }

procedure TCAFImporter.AddImportError(Row: Integer; Error: String);
begin
  FErrors.Add(Format('%s|%', [IntToStr(Row), Error]));
end;

function TCAFImporter.ContainsSymbols(const Value: String): Boolean;
var
  ValueChar: Char;
begin
  Result := True;
  
  for ValueChar in Value do
  begin
    if not (LowerCase(ValueChar)[1] in['a','b','c','d','e','f','g','h','i','j','k','l','m','n','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'])  then
    begin
      Result := False;

      Break;
    end;
  end;
end;

procedure TCAFImporter.ImportAsPDF(Source: TCAFSource; const OutputFile: String);
begin

end;

procedure TCAFImporter.Initialize(Source: TCAFSource);
begin

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
    cafHSBC: Result := THSBCCAFImporterUK.Create;
    
    cafStandard: Result := TStandardCAFImporterUK.Create;

    else
    begin
      raise Exception.Create('There are currently no importers of tthat support this combination of country and importer type');
    end;
  end;
end;

destructor TCAFImporter.Destroy;
begin
  FErrors.Free;
  
  inherited;
end;

procedure TCAFImporter.Import(const ImportFile: String; FileFormat: TCAFFileFormat; const OutputFolder: String);
var
  CAFSource: TCAFSource;
  ImportFunc: TCAFImporterFunc;
begin
  ResetImportStatistics;
  
  CAFSource := CreateCAFSource(ImportFile);

  try
    case FileFormat of
      cafPDF: ImportFunc := ImportAsPDF;
    end;

    if not DirectoryExists(OutputFolder) then
    begin
      CreateDir(OutputFolder);
    end;

    CAFSource.First;

    Initialize(CAFSource);

    while not CAFSource.Eof do
    begin
      if ValidateRecord(CAFSource) then
      begin
        ImportFunc(CAFSource, OutputFolder);

        FStatistics.Generated := FStatistics.Generated + 3;
        FStatistics.Failed := FStatistics.Failed + 1;
      end
      else
      begin
        FStatistics.Failed := FStatistics.Failed + 1;
      end;

      CAFSource.Next;
    end;
  finally
    CAFSource.Free;
  end;
end;

function TCAFImporter.IsLongMonthName(const Value: String): Boolean;
var
  Index: Integer;
begin
  Result := False;
  
  for Index := 0 to Length(LONG_MONTH_NAMES) - 1 do
  begin
    if CompareText(Value, LONG_MONTH_NAMES[Index]) = 0 then
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

function TCAFImporter.ValidateImportFields(const ImportFile: String): Boolean;
var
  CAFSource: TCAFSource;
begin
  CAFSource := CreateCAFSource(ImportFile);

  try
    Result := ValidateFields(CAFSource); 
  finally
    CAFSource.Free;
  end;
end;

procedure TCAFImporter.ValidateImportRecords(const ImportFile: String; out ValidLines, InvalidLines: Integer);
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
