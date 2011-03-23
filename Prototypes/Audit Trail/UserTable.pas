unit UserTable;

interface

uses
  SysUtils, Classes, SYDEFS, SYUSIO, IOStream, AuditMgr, AuditTable;

type
  TUserTable = class(TObject)
  private
    FUserList: TList;
    function GetCount: integer;
    function GetItems(index: integer): pUser_Rec;
    procedure CopyUser(P1, P2: pUser_Rec);
    procedure CompareAndCopyUser(P1, P2, P3: pUser_Rec);
    procedure SetAuditInfo(P1, P2: pUser_Rec; var AAuditInfo: TAuditInfo);
  public
    constructor Create;
    destructor Destroy; override;
    function FindUser(AAuditRecordID: integer): pUser_Rec;
    function NewUser: pUser_Rec;
    procedure AddUser(AUser: pUser_Rec);
    procedure ClearUsers;
    procedure DeleteUser(AUser: pUser_Rec);
    procedure DoAudit(AAuditTable: TAuditTable; AUserTableCopy: TUserTable);
    procedure LoadFromStream(var AStream: TIOStream);
    procedure AddAuditValues(var Values: string; ARecord: pointer);    
    procedure SaveToStream(var AStream: TIOStream);
    property Count: integer read GetCount;
    property Items[index: integer]: pUser_Rec read GetItems;
  end;

implementation

uses
  TOKENS, SYAUDIT;

{ TUserTable }

procedure TUserTable.AddAuditValues(var Values: string; ARecord: pointer);
begin
  SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 61),
                               tUser_Rec(ARecord^).usCode, Values);
  SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 62),
                               tUser_Rec(ARecord^).usName, Values);
  SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_User, 64),
                               tUser_Rec(ARecord^).usEMail_Address, Values);
end;

procedure TUserTable.AddUser(AUser: pUser_Rec);
begin

end;

procedure TUserTable.ClearUsers;
begin
  FUserList.Clear;
end;

procedure TUserTable.CompareAndCopyUser(P1, P2, P3: pUser_Rec);
begin
  //Copy all fields that have changes or only ones that are audited?
  if P1.usCode <> P2.usCode then
    P3.usCode := P1.usCode;
  if P1.usName <> P2.usName then
    P3.usName := P1.usName;
  if P1.usEMail_Address <> P2.usEMail_Address then
    P3.usEMail_Address := P1.usEMail_Address;
end;

procedure TUserTable.CopyUser(P1, P2: pUser_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_User_Rec(P1^, S);
    S.Position := 0;
    Read_User_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

constructor TUserTable.Create;
begin
  FUserList := TList.Create;
end;

procedure TUserTable.DeleteUser(AUser: pUser_Rec);
begin
  FUserList.Delete(FUserList.IndexOf(Pointer(AUser)));
end;

destructor TUserTable.Destroy;
begin
  FreeAndNil(FUserList);
  inherited;
end;

procedure TUserTable.DoAudit(AAuditTable: TAuditTable; AUserTableCopy: TUserTable);
var
  i: integer;
  P1, P2: pUser_Rec;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := atUsers;
  AuditInfo.AuditUser := 'SCOTT.WI';
  AuditInfo.AuditRecordType := tkBegin_User;
  //Adds, changes
  for i := 0 to Count - 1 do begin
    P1 := Items[i];
    P2 := AUserTableCopy.FindUser(P1.usAudit_Record_ID);
    SetAuditInfo(P1, P2, AuditInfo);
    if AuditInfo.AuditAction in [aaAdd, aaChange] then
      AAuditTable.AddAuditRec(AuditInfo);
  end;
  //Deletes
  for i := 0 to AUserTableCopy.Count - 1 do begin
    P2 := AUserTableCopy.Items[i];
    P1 := FindUser(P2.usAudit_Record_ID);
    SetAuditInfo(P1, P2, AuditInfo);
    if (AuditInfo.AuditAction = aaDelete) then
      AAuditTable.AddAuditRec(AuditInfo);
  end;
end;
  
function TUserTable.FindUser(AAuditRecordID: integer): pUser_Rec;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to FUserList.Count - 1 do
    if (pUser_Rec(FUserList[i]).usAudit_Record_ID = AAuditRecordID) then begin
      Result := pUser_Rec(FUserList[i]);
      Break;
    end;  
end;

function TUserTable.GetCount: integer;
begin
  Result := FUserList.Count;
end;

function TUserTable.GetItems(index: integer): pUser_Rec;
begin
  Result := pUser_Rec(FUserList.Items[index]);
end;

procedure TUserTable.LoadFromStream(var AStream: TIOStream);
var
  Token: Byte;
  US: pUser_Rec;
begin
  Token := AStream.ReadToken;
  while (Token <> tkEndSection) do begin
    if (Token = tkBegin_User) then begin
      US := New_User_Rec;
      SYUSIO.Read_User_Rec(US^, AStream);
      FUserList.Add(US);
    end;
    Token := AStream.ReadToken;
  end;
end;

function TUserTable.NewUser: pUser_Rec;
begin
  Result := SYUSIO.New_User_Rec;
  FUserList.Add(Result);
end;

procedure TUserTable.SetAuditInfo(P1, P2: pUser_Rec; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditRecord := nil;
  AAuditInfo.AuditAction := aaNone;
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.usAudit_Record_ID;
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.usAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    if not ((P1.usCode = P2.usCode) and
            (P1.usName = P2.usName) and
            (P1.usEMail_Address = P2.usEMail_Address)) then begin
      AAuditInfo.AuditAction := aaChange;
      AAuditInfo.AuditRecord := New_User_Rec;
      CompareAndCopyUser(P1, P2, AAuditInfo.AuditRecord);
    end;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := SystemAuditMgr.NextSystemRecordID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    P1.usAudit_Record_ID := AAuditInfo.AuditRecordID;
    AAuditInfo.AuditRecord := New_User_Rec;
    CopyUser(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure TUserTable.SaveToStream(var AStream: TIOStream);
var
  i: integer;
begin
  AStream.WriteToken(tkBeginSystem_User_List);
  for i := 0 to Pred(Count) do
    SYUSIO.Write_User_Rec(pUser_Rec(FUserList[i])^, AStream);
  AStream.WriteToken(tkEndSection);
end;


end.
