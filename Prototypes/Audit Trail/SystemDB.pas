unit SystemDB;

interface

uses
  Sysutils, Classes, UserTable, AuditTable, SYDEFS, IOStream, AuditMgr;


const
  SYSTEM_DB = 'System.db';

type
  TSystemDatabase = class(TObject)
    PracticeDetails: TPractice_Details_Rec;
  private
    FAuditTable: TAuditTable;
    FUserTable: TUserTable;
    FLastAuditRecordID: integer;
    procedure LoadFromStream(var AStream: TIOStream);
    procedure SaveToStream(var AStream: TIOStream);
    procedure SetAuditInfo(P1, P2: TPractice_Details_Rec; var AAuditInfo: TAuditInfo);
  public
    constructor Create;
    destructor Destroy; override;
    function NextAuditRecordID: integer;
    procedure DoAudit(APracticeDetails: TPractice_Details_Rec);
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
  TOKENS,SYFDIO;

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

  FillChar(PracticeDetails, Sizeof(PracticeDetails), 0);
  PracticeDetails.fdRecord_Type := tkBegin_Practice_Details;
  PracticeDetails.fdEOR := tkEnd_Practice_Details;

  FLastAuditRecordID := 0;
  FAuditTable := TAuditTable.Create;
  FUserTable := TUserTable.Create;
end;

destructor TSystemDatabase.Destroy;
begin
  FUserTable.Free;
  FAuditTable.Free;

  SYFDIO.Free_Practice_Details_Rec_Dynamic_Fields(PracticeDetails);

  inherited;
end;

procedure TSystemDatabase.DoAudit(APracticeDetails: TPractice_Details_Rec);
var
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditAction := aaNone;
  AuditInfo.AuditType := atPracticeSetup;
  AuditInfo.AuditUser := 'SCOTT.WI';
  SetAuditInfo(PracticeDetails, APracticeDetails, AuditInfo);
  if (AuditInfo.AuditAction <> aaNone) then
    AuditTable.AddAuditRec(AuditInfo);
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
      tkBegin_Practice_Details:       Read_Practice_Details_Rec(PracticeDetails, AStream);
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
    //Audit
    SystemAuditMgr.DoAudit;
    //Save
    Stream.Position := 0;
    Stream.WriteIntegerValue(20, FLastAuditRecordID);
    SaveToStream(Stream);
    Stream.SaveToFile(AFilename);
    //Reload system copy DB after save
    Stream.Position := 0;
    SystemCopy.LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TSystemDatabase.SaveToStream(var AStream: TIOStream);
begin
  Write_Practice_Details_Rec(PracticeDetails, AStream);
  FAuditTable.SaveToStream(AStream);
  FUserTable.SaveToStream(AStream);
  AStream.WriteToken(tkEndSection);
end;

procedure TSystemDatabase.SetAuditInfo(P1, P2: TPractice_Details_Rec;
  var AAuditInfo: TAuditInfo);

type
  TStrArray = array[1..99] of string[60];
  TRatesArray = array[1..99] of array[1..5] of comp;

  function SameStringArray(A1, A2: TStrArray): boolean;
  var
    i: integer;
  begin
    Result := True;
    for i := Low(A1) to High(A2) do
      if A1[i] <> A2[i] then begin
        Result := False;
        Break;
      end;
  end;

  function SameRatesArray(A1, A2: TRatesArray): boolean;
  var
    i, j: integer;
  begin
    Result := True;
    for i := Low(A1) to High(A1) do
      for j := Low(A1[i]) to High(A1[i]) do
        if A1[i, j] <> A2[i, j] then begin
          Result := False;
          Break;
        end;
  end;

begin
  if (P1.fdPractice_Name_for_Reports <> P2.fdPractice_Name_for_Reports) or
     (P1.fdPractice_Phone <> P2.fdPractice_Phone) or
     (not SameStringArray(TStrArray(P1.fdGST_Class_Names), TStrArray(P2.fdGST_Class_Names))) or
     (not SameRatesArray(TRatesArray(P1.fdGST_Rates), TRatesArray(P2.fdGST_Rates))) then begin
    AAuditInfo.AuditAction := aaChange;
    AAuditInfo.AuditRecordID := 0;
    SystemAuditMgr.AddAuditValue(tkBegin_Practice_Details, 12, P1.fdPractice_Name_for_Reports, AAuditInfo);
  end;
end;

end.
