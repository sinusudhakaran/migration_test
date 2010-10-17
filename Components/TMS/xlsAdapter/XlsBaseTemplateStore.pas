unit XlsBaseTemplateStore;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{$IFDEF LINUX}{$INCLUDE ../FLXCONFIG.INC}{$ELSE}{$INCLUDE ..\FLXCONFIG.INC}{$ENDIF}

interface

uses
  SysUtils, Classes,
  Contnrs,
  {$IFDEF WIN32}WOLE2Stream,{$ENDIF} //Here is not VCL/CLX, but Linux/Windows
  {$IFDEF LINUX}KGsfStream, {$ENDIF}
  XlsMessages, UFlxMessages;

type
  TXlsStorageList=class;

  TXlsStorage = class
  private
    FCompress: boolean;
    procedure SetCompress(const Value: boolean);
  public
    Name: string;
    Data: TMemoryStream;
    SubStorages: TXlsStorageList;

    property Compress: boolean read FCompress write SetCompress;

    constructor Create;
    destructor Destroy;override;

    procedure WriteData(Stream: TStream);
    procedure ReadData(Stream: TStream);

    procedure SaveToDoc( const DocOUT: TOle2Storage);
  end;

  TXlsStorageList=class(TObjectList)
  public
    Compress: boolean;
    procedure WriteData(Stream: TStream);
    procedure ReadData(Stream: TStream);
    procedure LoadFrom(const aFileName: TFileName);
    procedure SaveAs(const aFileName: TFileName);
  private
    function GetItems(index: integer): TXlsStorage;
    function GetStream(Name: widestring): TStream;
  public
    procedure LoadStorage(const DocIN: TOle2Storage; const LoadWorkbook: boolean = true);
    property Items[index: integer]: TXlsStorage read GetItems; default;
    property Stream[Name: widestring]: TStream read GetStream;
  end;



  TXlsBaseTemplateStore = class(TComponent)
  private
    { Private declarations }
  protected
    function GetStorages(Name: string): TXlsStorageList;virtual;abstract;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    procedure Loaded; override;
    function IsUpToDate: boolean;virtual; abstract;
    procedure Refresh; virtual; abstract;
    property Storages[Name: String]: TXlsStorageList read GetStorages;
    { Public declarations }
  published
    { Published declarations }
  end;

implementation
{ TXlsStorage }

constructor TXlsStorage.Create;
begin
  inherited Create;
  Data:= TMemoryStream.Create;
  SubStorages:= TXlsStorageList.Create;
end;

destructor TXlsStorage.Destroy;
begin
  FreeandNil(Data);
  FreeAndNil(SubStorages);
  inherited;
end;

procedure TXlsStorage.ReadData(Stream: TStream);
var
  Ds: integer;
begin
  Stream.ReadBuffer(Ds, SizeOf(Ds));
  SetLength(Name, Ds);
  Stream.ReadBuffer(Name[1], Ds);
  Stream.ReadBuffer(Ds, SizeOf(Ds));
  Data.Size:=Ds;
  Data.Position:=0;
  Stream.Read(Data.Memory^, Ds);
  SubStorages.ReadData(Stream);
end;

procedure TXlsStorage.SaveToDoc(const DocOUT: TOle2Storage);
var
  StreamOUT: TOle2Stream;
  i:integer;
  WideName: WideString;
begin
  WideName:=Name;
  if Data.Size> 0 then
  begin
    StreamOUT:= TOle2Stream.Create(DocOUT, WideName);
    try
      StreamOUT.Write(Data.Memory^, Data.Size);
    finally
      FreeAndNil(StreamOut);
    end;
  end else
  if SubStorages.Count>0 then
  begin
    DocOut.CdDown(WideName, true);
    try
      for i:=0 to SubStorages.Count-1 do (SubStorages[i] as TXlsStorage).SaveToDoc(DocOUT);
    finally
      DocOut.CdUp;
    end;
  end;
end;

procedure TXlsStorage.SetCompress(const Value: boolean);
begin
  FCompress := Value;
  SubStorages.Compress:=Value;
end;

procedure TXlsStorage.WriteData(Stream: TStream);
var
  Ln: integer;
begin
  Ln:=Length(Name);
  Stream.WriteBuffer(Ln, SizeOf(Ln));
  Stream.WriteBuffer(Name[1], Ln);
  Ln:=Data.Size;
  Stream.WriteBuffer(Ln, SizeOf(Ln));
  Data.Position:=0;
  Stream.Write(Data.Memory^, Data.Size);
  SubStorages.WriteData(Stream);
end;

{ TXlsStorageList }

procedure TXlsStorageList.LoadStorage(const DocIN: TOle2Storage; const LoadWorkbook: boolean);
var
  StreamIN: TOle2Stream;
  Stor: TXlsStorage;
  i: integer;
  DirInfo: TMsOleDirInfoArray;
  //PENDING: Compress: TCompressionStream;

begin
  DocIN.GetDirectories(DirInfo);
  for i:= Low(DirInfo) to High(DirInfo) do
  begin
    case DirInfo[i].OleType of
      MsOLEStreamT:
        if LoadWorkbook or (DirInfo[i].Name<>WorkbookStrS) then
        begin
          StreamIn:= TOle2Stream.Create( DocIN, DirInfo[i].Name);
          try
            Stor:=(Items[Add(TXlsStorage.Create)] as TXlsStorage);
//          Compress:= TCompressionStream.Create(clMax, Stor.Data);
            try
//            Compress.CopyFrom(OleStreamIn, OleStreamIn.Size);
              Stor.Data.CopyFrom(StreamIn, StreamIn.Size);
              finally
//              FreeAndNil(Compress);
            end; //finally
            Stor.Name:=DirInfo[i].Name;
          finally
            FreeAndNil(StreamIn);
          end; //finally
        end;

      MsOLEStorageT:
        begin
          DocIN.CDDown(DirInfo[i].Name, False);
          try
            Stor:=(Items[Add(TXlsStorage.Create)] as TXlsStorage);
            Stor.Name:=DirInfo[i].Name;
            Stor.SubStorages.LoadStorage(DocIN);
          finally
            DocIN.CdUp;
          end; //finally
        end;
    end; //case
  end; //for

end;

procedure TXlsStorageList.LoadFrom(const aFileName: TFileName);
var
  DocIN: TOle2Storage;
begin
  Clear;

  //Open template
  DocIN:= TOle2Storage.Create(aFileName, Ole2_Read, false);
  try
    LoadStorage(DocIN);
  finally
    FreeAndNil(DocIN);
  end;
end;

procedure TXlsStorageList.ReadData(Stream: TStream);
var
  Cnt, i: integer;
begin
  Stream.Read(Cnt, sizeOf(Cnt));
  Clear;
  for i:=0 to Cnt-1 do
   (Items[Add(TXlsStorage.Create)]as TXlsStorage).ReadData(Stream);
end;

procedure TXlsStorageList.WriteData(Stream: TStream);
var
  i:integer;
begin
  Stream.Write(Count, SizeOf(Count));
  for i:=0 to Count-1 do
   (Items[i]as TXlsStorage).WriteData(Stream);
end;

function TXlsStorageList.GetItems(index: integer): TXlsStorage;
begin
  Result:=inherited Items[index] as TXlsStorage;
end;

function TXlsStorageList.GetStream(Name: widestring): TStream;
var
  i:integer;
begin
  for i:=0 to Count-1 do if Items[i].Name=Name then
  begin
    Result:= Items[i].Data;
    exit;
  end;
  raise Exception.CreateFmt(ErrStreamNotFound,[Name]);
end;

procedure TXlsStorageList.SaveAs(const aFileName: TFileName);
var
  DocOUT: TOle2Storage;
  i: integer;
begin
  //Create template
  DocOut:=TOle2Storage.Create(aFileName, Ole2_Write, false);
  try
    for i:=0 to Count-1 do Items[i].SaveToDoc(DocOUT);
  finally
    FreeAndNil(DocOUT);
  end;
end;

{ TXlsBaseTemplateStore }

constructor TXlsBaseTemplateStore.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TXlsBaseTemplateStore.Loaded;
begin
  inherited;
end;

end.
