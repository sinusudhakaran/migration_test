unit PayeeTable;

interface

uses
  SysUtils, Classes, BKDEFS, BKPDIO, IOStream, AuditMgr, AuditTable;

type
  TPayeeTable = class(TObject)
  private
    FPayeeList: TList;
    function GetCount: integer;
    function GetItems(index: integer): pPayee_Detail_Rec;
    procedure SetAuditInfo(P1, P2: pPayee_Detail_Rec; var AAuditInfo: TAuditInfo);
    procedure CopyPayee(P1, P2: pPayee_Detail_Rec);
    procedure CompareAndCopyPayee(P1, P2, P3: pPayee_Detail_Rec);
  public
    constructor Create;
    destructor Destroy; override;
    function FindPayee(AAuditRecordID: integer): pPayee_Detail_Rec;
    function NewPayee: pPayee_Detail_Rec;
    procedure AddPayee(APayee: pPayee_Detail_Rec);
    procedure ClearPayees;
    procedure DeletePayee(APayee: pPayee_Detail_Rec);
    procedure DoAudit(AAuditTable: TAuditTable; APayeeTableCopy: TPayeeTable);
    procedure LoadFromStream(var AStream: TIOStream);
    procedure SaveToStream(var AStream: TIOStream);
    property Count: integer read GetCount;
    property Items[index: integer]: pPayee_Detail_Rec read GetItems;
  end;

implementation

uses
  TOKENS, BKAUDIT;

{ TPayeeTable }

procedure TPayeeTable.AddPayee(APayee: pPayee_Detail_Rec);
begin
  FPayeeList.Add(APayee);
end;

procedure TPayeeTable.ClearPayees;
begin
  FPayeeList.Clear;
end;

procedure TPayeeTable.CompareAndCopyPayee(P1, P2, P3: pPayee_Detail_Rec);
begin
  //Copy all fields that have changes or only ones that are audited?
  if P1.pdNumber <> P2.pdNumber then
    P3.pdNumber := P1.pdNumber;
  if P1.pdName <> P2.pdName then
    P3.pdName := P1.pdName;
end;

procedure TPayeeTable.CopyPayee(P1, P2: pPayee_Detail_Rec);
var
  S: TIOStream;
begin
  S := TIOStream.Create;
  try
    Write_Payee_Detail_Rec(P1^, S);
    S.Position := 0;
    Read_Payee_Detail_Rec(P2^, S);
  finally
    S.Free;
  end;
end;

constructor TPayeeTable.Create;
begin
  FPayeeList := TList.Create;
end;

procedure TPayeeTable.DeletePayee(APayee: pPayee_Detail_Rec);
begin
  FPayeeList.Delete(FPayeeList.IndexOf(Pointer(APayee)));
end;

destructor TPayeeTable.Destroy;
begin
  FPayeeList.Free;
  inherited;
end;

procedure TPayeeTable.DoAudit(AAuditTable: TAuditTable; APayeeTableCopy: TPayeeTable);
var
  i: integer;
  P1, P2: pPayee_Detail_Rec;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := atPayees;
  AuditInfo.AuditUser := 'SCOTT.WI';
  AuditInfo.AuditRecordType := tkBegin_Payee_Detail;
  //Adds, changes
  for i := 0 to Count - 1 do begin
    P1 := Items[i];
    P2 := APayeeTableCopy.FindPayee(P1.pdAudit_Record_ID);
    SetAuditInfo(P1, P2, AuditInfo);
    if AuditInfo.AuditAction in [aaAdd, aaChange] then
      AAuditTable.AddAuditRec(AuditInfo);
  end;
  //Deletes
  for i := 0 to APayeeTableCopy.Count - 1 do begin
    P2 := APayeeTableCopy.Items[i];
    P1 := FindPayee(P2.pdAudit_Record_ID);
    SetAuditInfo(P1, P2, AuditInfo);
    if (AuditInfo.AuditAction = aaDelete) then
      AAuditTable.AddAuditRec(AuditInfo);
  end;
end;

function TPayeeTable.FindPayee(AAuditRecordID: integer): pPayee_Detail_Rec;
var
  i: integer;
begin
  Result := nil;
  for i := 0 to FPayeeList.Count - 1 do
    if (pPayee_Detail_Rec(FPayeeList[i]).pdAudit_Record_ID = AAuditRecordID) then begin
      Result := pPayee_Detail_Rec(FPayeeList[i]);
      Break;
    end;    
end;

function TPayeeTable.GetCount: integer;
begin
  result := FPayeeList.Count;
end;

function TPayeeTable.GetItems(index: integer): pPayee_Detail_Rec;
begin
  Result := pPayee_Detail_Rec(FPayeeList.Items[index]);
end;

procedure TPayeeTable.LoadFromStream(var AStream: TIOStream);
var
  Token: Byte;
  PD: pPayee_Detail_Rec;
begin
  Token := AStream.ReadToken;
  while (Token <> tkEndSection) do begin
    if (Token = tkBegin_Payee_Detail) then begin
      PD := New_Payee_Detail_Rec;
      BKPDIO.Read_Payee_Detail_Rec(PD^, AStream);
      FPayeeList.Add(PD);
    end;
    Token := AStream.ReadToken;               
  end;
end;

function TPayeeTable.NewPayee: pPayee_Detail_Rec;
begin
  Result := BKPDIO.New_Payee_Detail_Rec;
  FPayeeList.Add(Result);
end;

procedure TPayeeTable.SaveToStream(var AStream: TIOStream);
var
  i: integer;
begin
  AStream.WriteToken(tkBeginPayeesList);
  for i := 0 to Pred(Count) do
    BKPDIO.Write_Payee_Detail_Rec(pPayee_Detail_Rec(FPayeeList[i])^, AStream);
  AStream.WriteToken(tkEndSection);
end;

procedure TPayeeTable.SetAuditInfo(P1, P2: pPayee_Detail_Rec; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditRecord := nil;
  AAuditInfo.AuditAction := aaNone;
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.pdAudit_Record_ID;
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.pdAudit_Record_ID;
    if not ((P1.pdNumber = P2.pdNumber) and
            (P1.pdName = P2.pdName) and
            (P1.pdAudit_Record_ID = P2.pdAudit_Record_ID)) then begin
      AAuditInfo.AuditAction := aaChange;
      AAuditInfo.AuditRecord := New_Payee_Detail_Rec;
      CompareAndCopyPayee(P1, P2, AAuditInfo.AuditRecord);
    end;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := ClientAuditMgr.NextClientRecordID;
    P1.pdAudit_Record_ID := AAuditInfo.AuditRecordID;
    AAuditInfo.AuditRecord := New_Payee_Detail_Rec;
    CopyPayee(P1, AAuditInfo.AuditRecord);
  end;
end;


end.
