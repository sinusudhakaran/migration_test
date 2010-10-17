unit TemplateStore;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

{$IFDEF ConditionalExpressions}
      {$if CompilerVersion >= 18}
         {$DEFINE BCB2006UP}
      {$ifend}
{$ENDIF}

interface
{$R XlsTemplateStore.res}
uses
  SysUtils, Classes, XlsMessages, UFlxMessages, XlsBaseTemplateStore,
  {$IFDEF WIN32}WOLE2Stream,{$ENDIF} //Here is not VCL/CLX, but Linux/Windows
  {$IFDEF LINUX}KGsfStream, {$ENDIF}
  contnrs;

type
  TXlsTemplate= class (TCollectionItem)
  private
    FFileName: TFileName;
    FCompress: boolean;
    FStorages: TXlsStorageList;
    FModifiedDate: TDateTime;

    procedure SetFileName(const Value: TFileName);
    procedure SetCompress(const Value: boolean);

    property Compress: boolean read FCompress write SetCompress;
  protected
    function GetDisplayName: string; override;
    procedure SetDisplayName(const Value: string); override;

    procedure WriteData(Stream: TStream);
    procedure ReadData(Stream: TStream);
    procedure WriteModifiedDate(Writer: TWriter);
    procedure ReadModifiedDate(Reader: TReader);
    procedure DefineProperties(Filer: TFiler); override;
    function Equal(aTemplate: TXlsTemplate): Boolean;
  public
    property Storages: TXlsStorageList read FStorages;
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure SaveAs(const aFileName: TFileName);

    property ModifiedDate: TDateTime read FModifiedDate;
  published
    property FileName: TFileName read FFileName write SetFileName stored false;
  end;

  TXlsTemplateList=class(TOwnedCollection) //Items are TXlsTemplate
  private
    FCompress: boolean;
    procedure SetCompress(const Value: boolean);
    property Compress: boolean read FCompress write SetCompress;
    function GetItems(Index: integer): TXlsTemplate;
  public
    property Items[Index: integer]: TXlsTemplate read GetItems; default;
  end;

  TXlsTemplateStore = class(TXlsBaseTemplateStore)
  private
    FCompress: boolean;
    FCaseInsensitive: boolean;
    FRefreshPath: string;
    procedure SetCompress(const Value: boolean);
    function DoUp(s: string): string;
    { Private declarations }
  protected
    FTemplates: TXlsTemplateList;
    function GetStorages(Name: String): TXlsStorageList; override;
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;override;

    function IsUpToDate: boolean;override;
    procedure Refresh;override;

    procedure LoadTemplateFromStream(const aStream: TStream; const aTemplateName: string); 
  published
    { Published declarations }
    property Templates: TXlsTemplateList read FTemplates write FTemplates;
    property Compress: boolean read FCompress write SetCompress;
    property CaseInsensitive: boolean read FCaseInsensitive write FCaseInsensitive default false;
    property RefreshPath: string read FRefreshPath write FRefreshPath;

    //PENDING:AssignTo
  end;

procedure Register;

implementation
procedure Register;
begin
  RegisterComponents('FlexCel', [TXlsTemplateStore]);
end;


{ TXlsTemplate }

constructor TXlsTemplate.Create(Collection: TCollection);
begin
  inherited;
  FStorages:=TXlsStorageList.Create;
end;

procedure TXlsTemplate.DefineProperties(Filer: TFiler);

  function DoWrite: Boolean;
  begin
    if Filer.Ancestor <> nil then
      Result := not (Filer.Ancestor is TXlsTemplate) or
        not Equal(TXlsTemplate(Filer.Ancestor))
    else
      Result := FFileName<>'';
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('TemplateData', ReadData, WriteData, DoWrite);
  Filer.DefineProperty('ModifiedDate', ReadModifiedDate, WriteModifiedDate, DoWrite);
end;

destructor TXlsTemplate.Destroy;
begin
  FreeAndNil(FStorages);
  inherited;
end;

function TXlsTemplate.Equal(aTemplate: TXlsTemplate): Boolean;
begin
  Result:=FFileName=aTemplate.FFileName;
end;

function TXlsTemplate.GetDisplayName: string;
begin
  Result:=FFileName;
end;

procedure TXlsTemplate.ReadData(Stream: TStream);
var
  Version: SmallInt;
  Ln: integer;
begin
  Stream.ReadBuffer(Version, SizeOf(Version));
  Stream.ReadBuffer(Ln, SizeOF(Ln));
  SetLength(FFileName, Ln);
  Stream.ReadBuffer(FFileName[1], Ln);
  FStorages.ReadData(Stream);
end;

procedure TXlsTemplate.ReadModifiedDate(Reader: TReader);
begin
  FModifiedDate:=Reader.ReadDate;
end;

procedure TXlsTemplate.SaveAs(const aFileName: TFileName);
begin
  FStorages.SaveAs(aFileName);
end;

procedure TXlsTemplate.SetCompress(const Value: boolean);
var
  i:integer;
begin
  FCompress := Value;
  for i:=0 to FStorages.Count-1 do FStorages[i].Compress:=Value;
end;

procedure TXlsTemplate.SetDisplayName(const Value: string);
begin
  inherited;
  FileName:=Value;
end;

procedure TXlsTemplate.SetFileName(const Value: TFileName);
begin
  FStorages.LoadFrom(Value);
  FFileName := ExtractFileName(Value);
  {$IFDEF BCB2006UP}
     FileAge(Value, FModifiedDate);
  {$ELSE}
     FModifiedDate:=FileDateToDateTime(FileAge(Value));
  {$ENDIF}
end;

procedure TXlsTemplate.WriteData(Stream: TStream);
var
  Version: SmallInt;
  Ln: integer;
begin
  Version:=1;
  Stream.WriteBuffer(Version,SizeOf(Version));
  Ln:=Length(FFileName);
  Stream.WriteBuffer(Ln, SizeOf(Ln));
  Stream.WriteBuffer(FFileName[1], Ln);
  FStorages.WriteData(Stream);
end;

procedure TXlsTemplate.WriteModifiedDate(Writer: TWriter);
begin
  Writer.WriteDate(FModifiedDate);
end;

{ TXlsTemplateStore }

constructor TXlsTemplateStore.Create(AOwner: TComponent);
begin
  inherited;
  FTemplates:= TXlsTemplateList.Create(Self, TXlsTemplate);
end;

destructor TXlsTemplateStore.Destroy;
begin
  FreeAndNil(FTemplates);
  inherited;
end;

function TXlsTemplateStore.DoUp(s: string): string;
begin
  if FCaseInsensitive then Result := UpperCase(s) else Result := s;
end;

function TXlsTemplateStore.GetStorages(Name: String): TXlsStorageList;
var
  i: integer;
begin
  Name:= ExtractFileName(Name);
  if FCaseInsensitive then Name := UpperCase(Name);

  for i:=0 to Templates.Count -1 do if DoUp(Templates[i].FileName)=Name then
  begin
    Result:=Templates[i].Storages;
    exit;
  end;
  raise Exception.CreateFmt(ErrFileNotFound, [Name]);
end;

function TXlsTemplateStore.IsUpToDate: boolean;
var
  FileName: string;
  i: integer;
  {$IFDEF BCB2006UP}
  Modified: TDateTime;
  {$ENDIF}
begin
  Result:=false;
  for i:=0 to Templates.Count-1 do
  begin
    FileName:=IncludeTrailingPathDelimiter(RefreshPath)+Templates[i].FileName;
    if not FileExists(FileName) then exit;

    {$IFDEF BCB2006UP}
       FileAge(FileName, Modified);
       if Modified <> Templates[i].ModifiedDate then exit;
    {$ELSE}
       if FileAge(FileName) <> DateTimeToFileDate(Templates[i].ModifiedDate) then exit;
    {$ENDIF}
  end;
  Result:=true;
end;

procedure TXlsTemplateStore.LoadTemplateFromStream(const aStream: TStream;
  const aTemplateName: string);
var
  NewTemplate: TXlsTemplate;
  DocIN: TOle2Storage;
begin
  NewTemplate:=(Templates.Add as TXlsTemplate);

  DocIN:= TOle2Storage.Create('', Ole2_Read, false, aStream);
  try
    NewTemplate.Storages.LoadStorage(DocIN);
  finally
    FreeAndNil(DocIN);
  end;
  NewTemplate.FFileName := aTemplateName;
end;

procedure TXlsTemplateStore.Refresh;
var
  i: integer;
begin
  for i:=0 to Templates.Count-1 do
  begin
    Templates[i].FileName:=IncludeTrailingPathDelimiter(RefreshPath)+Templates[i].FileName;
  end;
end;

procedure TXlsTemplateStore.SetCompress(const Value: boolean);
begin
  FCompress := Value;
  Templates.Compress:=Value;
end;

{ TXlsTemplateList }

function TXlsTemplateList.GetItems(Index: integer): TXlsTemplate;
begin
  Result:= inherited Items[Index] as TXlsTemplate;
end;

procedure TXlsTemplateList.SetCompress(const Value: boolean);
var
  i:integer;
begin
  FCompress := Value;
  for i:=0 to Count-1 do Items[i].Compress:=true;
end;

end.
