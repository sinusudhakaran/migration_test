unit XLSFile;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0

    Rev history:    
    2003-08-29  Add: SaveToStream added
    2004-02-03  Add: OnProgress event added
    2005-09-15  Add: read options added
    2006-06-23  Add: OpenStream added
    2008-03-04  Add: Read BIFF8 standard protected workbooks
    2008-05-04  Add: ListSeparator property

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, XLSWorkbook, XLSBase;

type
  {TXLSFile}
  TXLSFile = class
  private
    FWorkbook: TWorkbook;
    FOnProgress: TProgressEvent;
    FReaderOptions: TReaderOptions;
    FDataFromFile: Boolean;
    FCodePage: Integer;
    FListSeparator: AnsiChar;
    function  GetCodePage: Integer;
    procedure SetCodePage(ACodePage: Integer);
    procedure SetListSeparator(ASeparator: AnsiChar);
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveAs(const AFileName: WideString);
    procedure SaveAsProtected(const AFileName: WideString; const APassword: WideString);
    procedure SaveToStream(const AStream: TStream);
    procedure SaveToStreamProtected(const AStream: TStream; const APassword: WideString);
    procedure OpenFile(const AFileName: WideString);
    procedure OpenProtectedFile(const AFileName: WideString; const APassword: WideString);
    procedure OpenStream(const AStream: TStream);
    procedure OpenProtectedStream(const AStream: TStream; const APassword: WideString);
    procedure Clear;
    property Workbook: TWorkbook read FWorkbook;
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
    property DataFromFile: Boolean read FDataFromFile;
    property CodePage: Integer read GetCodePage write SetCodePage;
    property ListSeparator: AnsiChar read FListSeparator write SetListSeparator;
    { Read options }
    property ReadEmptyCells: Boolean read FReaderOptions.ReadEmptyCells write FReaderOptions.ReadEmptyCells;
    property ReadRowFormats: Boolean read FReaderOptions.ReadRowFormats write FReaderOptions.ReadRowFormats;
    property ReadColumnFormats: Boolean read FReaderOptions.ReadColumnFormats write FReaderOptions.ReadColumnFormats;
    property ReadFormulas: Boolean read FReaderOptions.ReadFormulas write FReaderOptions.ReadFormulas;
    property RaiseErrorOnReadUnknownFormula: Boolean read FReaderOptions.RaiseErrorOnReadUnknownFormula write FReaderOptions.RaiseErrorOnReadUnknownFormula;
    property ReadDrawings: Boolean read FReaderOptions.ReadDrawings write FReaderOptions.ReadDrawings;
  end;

  { Helper functions }  
  function GetXLSFileVersion(const AFileName: WideString): Byte;
  function GetXLSFileProtectionMethod(const AFileName: WideString): Integer;

implementation
uses XLSReader
  , XLSWriter
  , Windows
  , SysUtils
  , Unicode
  , XLSFormula
;

{TXLSFile}
constructor TXLSFile.Create;
begin
  FWorkbook:= TWorkbook.Create(1);
  FDataFromFile:= False;

  { Set default options }
  FReaderOptions.ReadEmptyCells:= True;
  FReaderOptions.ReadRowFormats:= True;
  FReaderOptions.ReadColumnFormats:= True;
  FReaderOptions.ReadFormulas:= True;
  FReaderOptions.RaiseErrorOnReadUnknownFormula:= False;
  FReaderOptions.ReadDrawings:= True;

  { Get current ANSI code-page identifier for the system }
  SetCodePage(GetACP);

  { Get current list separator }
  {$IFDEF XLF_D3}
  if (SysUtils.DecimalSeparator = ',') then
    SetListSeparator(';')
  else
    SetListSeparator(',');  
  {$ELSE}
  SetListSeparator(AnsiChar(SysUtils.ListSeparator));
  {$ENDIF}
end;

destructor TXLSFile.Destroy;
begin
  FWorkbook.Destroy;
  inherited;
end;

function  TXLSFile.GetCodePage: Integer;
begin
  Result:= FCodePage;
end;

procedure TXLSFile.SetCodePage(ACodePage: Integer);
begin
  FCodePage:= ACodePage;
  Unicode.CodePageForConversions:= ACodePage;
end;

procedure TXLSFile.SetListSeparator(ASeparator: AnsiChar);
begin
  FListSeparator:= ASeparator;
  XLSFormula.FMLA_ARG_SEPARATOR:= ASeparator;
end;

procedure TXLSFile.SaveAs(const AFileName: WideString);
begin
  SaveAsProtected(AFileName, '');
end;

procedure TXLSFile.SaveAsProtected(const AFileName: WideString; const APassword: WideString);
var
  Writer: TXLSWriter;
begin
  Writer:= TXLSWriter.Create(Self);
  try
    Writer.OnProgress:= FOnProgress;
    if (APassword = '') then
      Writer.SaveAs(AFileName)
    else
      Writer.SaveAsProtected(AFileName, APassword);
  finally
    Writer.Destroy;
  end;
end;

procedure TXLSFile.SaveToStream(const AStream: TStream);
begin
  SaveToStreamProtected(AStream, '');
end;

procedure TXLSFile.SaveToStreamProtected(const AStream: TStream; const APassword: WideString);
var
  Writer: TXLSWriter;
begin
  Writer:= TXLSWriter.Create(Self);
  try
    Writer.OnProgress:= FOnProgress;
    if (APAssword = '') then
      Writer.SaveToStream(AStream)
    else
      Writer.SaveToStreamProtected(AStream, APAssword);
  finally
    Writer.Destroy;
  end;
end;

procedure TXLSFile.OpenFile(const AFileName: WideString);
begin
  OpenProtectedFile(AFileName, '');
end;

procedure TXLSFile.OpenProtectedFile(const AFileName: WideString; const APassword: WideString);
var
  Reader: TXLSReader;
begin
  Reader:= TXLSReader.Create(Self);
  try
    Reader.OnProgress:= FOnProgress;
    Reader.ReadFromFile(AFileName, APassword, FReaderOptions);
  finally
    Reader.Destroy;
  end;

  FDataFromFile:= True;
end;

procedure TXLSFile.OpenStream(const AStream: TStream);
begin
  OpenProtectedStream(AStream ,'');
end;

procedure TXLSFile.OpenProtectedStream(const AStream: TStream; const APassword: WideString);
var
  Reader: TXLSReader;
begin
  Reader:= TXLSReader.Create(Self);
  try
    Reader.OnProgress:= FOnProgress;
    Reader.ReadFromStream(AStream, APassword, FReaderOptions);
  finally
    Reader.Destroy;
  end;

  FDataFromFile:= True;
end;

procedure TXLSFile.Clear;
begin
  FWorkbook.Clear;
  FDataFromFile:= False;  
end;

{ Helper functions }
function GetXLSFileVersion(const AFileName: WideString): Byte;
var
  xf: TXLSFile;
  Reader: TXLSReader;
begin
  xf:= TXLSFile.Create;
  Reader:= TXLSReader.Create(xf);

  try
    Result:= Reader.GetFileVersion(AFileName);
  finally
    Reader.Destroy;
    xf.Destroy;
  end;
end;

function GetXLSFileProtectionMethod(const AFileName: WideString): Integer;
var
  xf: TXLSFile;
  Reader: TXLSReader;
begin
  xf:= TXLSFile.Create;
  Reader:= TXLSReader.Create(xf);

  try
    Result:= Reader.GetFileProtectionMethod(AFileName);
  finally
    Reader.Destroy;
    xf.Destroy;
  end;
end;

end.

