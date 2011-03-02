unit ClientDB;

interface

uses
  Sysutils, Classes, PayeeTable, AuditTable, BKDEFS, IOStream, AuditMgr;

const
  CLIENT_DB = 'Client.db';

type
  TClientDatabase = class(TObject)
  private
    FAuditTable: TAuditTable;
    FPayeeTable: TPayeeTable;
    FLastAuditRecordID: integer;
    procedure LoadFromStream(var AStream: TIOStream);
    procedure SaveToStream(var AStream: TIOStream);
  public
    constructor Create;
    destructor Destroy; override;
    function NextAuditRecordID: integer;
    procedure LoadFromFile(AFileName: TFilename);
    procedure SaveToFile(AFileName: TFilename);
    property PayeeTable: TPayeeTable read FPayeeTable;
    property AuditTable: TAuditTable read FAuditTable;
  end;

  //Client DB singleton
  function Client: TClientDatabase;
  function ClientCopy: TClientDatabase;

implementation

uses
  TOKENS, BKDbExcept, SYATIO, BKCHIO, BKPDIO;

var
  _Client: TClientDatabase;
  _ClientCopy: TClientDatabase;

function Client: TClientDatabase;
begin
  if not Assigned(_Client) then
    _Client := TClientDatabase.Create;
  Result := _Client;
end;

function ClientCopy: TClientDatabase;
begin
  if not Assigned(_ClientCopy) then begin
    _ClientCopy := TClientDatabase.Create;
  end;
  Result := _ClientCopy;
end;


{ TClient }

constructor TClientDatabase.Create;
begin
  inherited;

  FLastAuditRecordID := 0;
  FAuditTable := TAuditTable.Create;
  FPayeeTable := TPayeeTable.Create;
end;

destructor TClientDatabase.Destroy;
begin
  FPayeeTable.Free;
  FAuditTable.Free;

  inherited;
end;

function TClientDatabase.NextAuditRecordID: integer;
begin
  Inc(FLastAuditRecordID);
  Result := FLastAuditRecordID;
end;

procedure TClientDatabase.LoadFromFile(AFileName: TFilename);
var
  Stream: TIOStream;
begin
  if not FileExists(AFilename) then Exit;

  Stream := TIOStream.Create;
  try
    Stream.LoadFromFile(AFilename);
    LoadFromStream(Stream);
    //Initial load of client copy DB
    if _ClientCopy = nil then begin
      Stream.Position := 0;
      ClientCopy.LoadFromStream(Stream);
    end;
  finally
    Stream.Free;
  end;
end;

procedure TClientDatabase.LoadFromStream(var AStream: TIOStream);
var
  Token: Byte;
begin
  FPayeeTable.ClearPayees;
  FAuditTable.AuditRecords.DeleteAll;
  Token := AStream.ReadToken;
  while (Token <> tkEndSection) do begin
    case Token of
      20: FLastAuditRecordID := AStream.ReadIntegerValue;
      tkBeginPayeesList:              FPayeeTable.LoadFromStream(AStream);
      tkBeginSystem_Audit_Trail_List: FAuditTable.LoadFromStream(AStream);
    end;
    Token := AStream.ReadToken;
  end;
end;

procedure TClientDatabase.SaveToFile(AFileName: TFilename);
var
  Stream: TIOStream;
begin
  Stream := TIOStream.Create;
  try
    //Audit
    ClientAuditMgr.DoAudit;
    //Save
    Stream.Position := 0;
    Stream.WriteIntegerValue(20, FLastAuditRecordID);
    SaveToStream(Stream);
    Stream.SaveToFile(AFilename);
    //Reload client copy DB after save
    Stream.Position := 0;
    ClientCopy.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TClientDatabase.SaveToStream(var AStream: TIOStream);
begin
  FAuditTable.SaveToStream(AStream);
  FPayeeTable.SaveToStream(AStream);
  AStream.WriteToken(tkEndSection);
end;

initialization
  _Client := nil;
  _ClientCopy := nil;
finalization
  if Assigned(_Client) then
    FreeAndNil(_Client);
  if Assigned(_ClientCopy) then
    FreeAndNil(_ClientCopy);
end.
