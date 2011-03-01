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
    procedure SaveToStream(var AStream: TIOStream);
    property Count: integer read GetCount;
    property Items[index: integer]: pUser_Rec read GetItems;
  end;

implementation

uses
  TOKENS, SYAUDIT;

{ TUserTable }

procedure TUserTable.AddUser(AUser: pUser_Rec);
begin

end;

procedure TUserTable.ClearUsers;
begin
  FUserList.Clear;
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

  procedure AddField(AFieldID: byte; AVaule: string);
  begin
    if (AAuditInfo.AuditValues <> '') then
      AAuditInfo.AuditValues := AAuditInfo.AuditValues + ', ';
    AAuditInfo.AuditValues := AAuditInfo.AuditValues +
                              SYAuditNames.GetAuditFieldName(tkBegin_User, AFieldID) +
                              '=' + AVaule;
  end;

begin
  AAuditInfo.AuditAction := aaNone;
  if not Assigned(P1) then begin
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.usAudit_Record_ID;
  end else if Assigned(P2) then begin
    AAuditInfo.AuditRecordID := P1.usAudit_Record_ID;
    if not ((P1.usCode = P2.usCode) and
            (P1.usName = P2.usName) and
            (P1.usEMail_Address = P2.usEMail_Address)) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //New record
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := SystemAuditMgr.NextSystemRecordID;
    P1.usAudit_Record_ID := AAuditInfo.AuditRecordID;
  end;
  //Delta
  case AAuditInfo.AuditAction of
    aaAdd    :
      begin
        AddField(61, P1.usCode);
        AddField(62, P1.usName);
        AddField(64, P1.usEMail_Address);
      end;
    aaChange :
      begin
        if (P1.usCode <> P2.usCode) then
          AddField(61, P1.usCode);
        if (P1.usName <> P2.usName) then
           AddField(62, P1.usName);
        if (P1.usEMail_Address <> P2.usEMail_Address) then
           AddField(64, P1.usEMail_Address);
      end;
    aaDelete :
      begin
        AAuditInfo.AuditValues := '';
      end;
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
