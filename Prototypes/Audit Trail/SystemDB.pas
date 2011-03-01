unit SystemDB;

interface

uses
  Sysutils, Classes, UserTable, AuditTable, SYDEFS, IOStream, AuditMgr;


const
  SYSTEM_DB = 'System.db';

type
  TSystemDatabase = class(TObject)
  private
    FAuditTable: TAuditTable;
    FUserTable: TUserTable;
    FLastAuditRecordID: integer;
    procedure LoadFromStream(var AStream: TIOStream);
    procedure SaveToStream(var AStream: TIOStream);
  public
    constructor Create;
    destructor Destroy; override;
    function NextAuditRecordID: integer;
    procedure LoadFromFile(AFileName: TFilename);
    procedure SaveToFile(AFileName: TFilename);
    property UserTable: TUserTable read FUserTable;
    property AuditTable: TAuditTable read FAuditTable;
  end;

  //Client DB singleton
  function SystemData: TSystemDatabase;
  function SystemCopy: TSystemDatabase;

implementation

uses
  TOKENS;

var
  _System: TSystemDatabase;
  _SystemCopy: TSystemDatabase;

function SystemData: TSystemDatabase;
begin
  if not Assigned(_System) then
    _System := TSystemDatabase.Create;
  Result := _System;
end;

function SystemCopy: TSystemDatabase;
begin
  if not Assigned(_SystemCopy) then begin
    _SystemCopy := TSystemDatabase.Create;
  end;
  Result := _SystemCopy;
end;

{ TSystemDatabase }

constructor TSystemDatabase.Create;
begin
  inherited;

  FLastAuditRecordID := 0;
  FAuditTable := TAuditTable.Create;
  FUserTable := TUserTable.Create;
end;

destructor TSystemDatabase.Destroy;
begin
  FUserTable.Free;
  FAuditTable.Free;

  inherited;
end;

procedure TSystemDatabase.LoadFromFile(AFileName: TFilename);
var
  Stream: TIOStream;
begin
  if not FileExists(AFilename) then Exit;

  Stream := TIOStream.Create;
  try
    Stream.LoadFromFile(AFilename);
    LoadFromStream(Stream);
    //Initial load of system copy DB
    if (_SystemCopy = nil) then begin
      Stream.Position := 0;
      SystemCopy.LoadFromStream(Stream);
    end;
  finally
    Stream.Free;
  end;

end;

procedure TSystemDatabase.LoadFromStream(var AStream: TIOStream);
var
  Token: Byte;
begin
  FUserTable.ClearUsers;
  FAuditTable.AuditRecords.DeleteAll;
  Token := AStream.ReadToken;
  while (Token <> tkEndSection) do begin
    case Token of
      20: FLastAuditRecordID := AStream.ReadIntegerValue;
      tkBeginSystem_User_List:        FUserTable.LoadFromStream(AStream);
      tkBeginSystem_Audit_Trail_List: FAuditTable.LoadFromStream(AStream);
    end;
    Token := AStream.ReadToken;
  end;
end;

function TSystemDatabase.NextAuditRecordID: integer;
begin
  Inc(FLastAuditRecordID);
  Result := FLastAuditRecordID;
end;

procedure TSystemDatabase.SaveToFile(AFileName: TFilename);
var
  Stream: TIOStream;
begin
  Stream := TIOStream.Create;
  try
    Stream.Position := 0;
    Stream.WriteIntegerValue(20, FLastAuditRecordID);
    SaveToStream(Stream);
    Stream.SaveToFile(AFilename);
    //Audit
    SystemAuditMgr.DoAudit;
    //Reload system copy DB after save
    Stream.Position := 0;
    SystemCopy.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TSystemDatabase.SaveToStream(var AStream: TIOStream);
begin
  FAuditTable.SaveToStream(AStream);
  FUserTable.SaveToStream(AStream);
  AStream.WriteToken(tkEndSection);
end;

end.
