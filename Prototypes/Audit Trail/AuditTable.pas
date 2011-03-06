unit AuditTable;

interface

uses
  Classes, SysUtils, IOStream, ECollect, SYDEFS, AuditMgr;

type
  TAuditCollection = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item : Pointer); override;
  public
    function Audit_At(Index : longint) : TAudit_Trail_Rec;
    function Compare(Item1,Item2 : Pointer): Integer; override;
  end;

  TAuditTable = class(TObject)
  private
    FAuditRecords: TAuditCollection;
    FDatabaseObj: TObject;
    FLastAuditID: integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddAuditRec(AAuditInfo: TAuditInfo);
    procedure LoadFromFile(AFileName: TFileName);
    procedure LoadFromStream( var S: TIOStream);
    procedure SaveToFile (AFileName: TFileName);
    procedure SaveToStream (var S: TIOStream);
    procedure SetAuditStrings(Index: integer; Strings: TStrings);
    property AuditRecords: TAuditCollection read FAuditRecords;
  end;

implementation

uses
  TOKENS, BKDbExcept, SYATIO, BKDEFS, BKCHIO, BKPDIO;

const
  UNIT_NAME = 'AuditMgr';

{ TAuditObj }

procedure TAuditTable.AddAuditRec(AAuditInfo: TAuditInfo);
var
  AuditRec: pAudit_Trail_Rec;
begin
  AuditRec := SYATIO.New_Audit_Trail_Rec;
  AuditRec.atAudit_ID := FAuditRecords.ItemCount + 1;
  AuditRec.atTransaction_Type := AAuditInfo.AuditType;
  AuditRec.atAudit_Action := AAuditInfo.AuditAction;
  AuditRec.atDate_Time := Now;
  AuditRec.atRecord_ID := AAuditInfo.AuditRecordID;
  AuditRec.atUser_Code := AAuditInfo.AuditUser;
  AuditRec.atParent_ID := AAuditInfo.AuditParentID;
  AuditRec.atAudit_Record_Type := AAuditInfo.AuditRecordType;
  AuditRec.atAudit_Record := AAuditInfo.AuditRecord;
  FAuditRecords.Insert(AuditRec);
end;

constructor TAuditTable.Create;
begin
  FLastAuditID := 0;
  FDatabaseObj := nil;
  FAuditRecords := TAuditCollection.Create;
end;

destructor TAuditTable.Destroy;
begin
  FAuditRecords.Free;
  inherited;
end;

procedure TAuditTable.LoadFromFile(AFileName: TFileName);
var
  InFile: TIOStream;
  Token: byte;
begin
  if not FileExists(AFileName) then Exit;

  InFile := TIOStream.Create;
  try
    InFile.LoadFromFile(AFileName);
    InFile.Position := soFromBeginning;
    Token := InFile.ReadToken;
    Assert(tkBeginSystem_Audit_Trail_List = Token, 'Start Audit list token wrong');
    LoadFromStream(InFile);
  finally
    InFile.Free;
  end;
end;

procedure TAuditTable.LoadFromStream(var S: TIOStream);
const
  THIS_METHOD_NAME = 'TAuditObj.LoadFromStream';
var
  Token: Byte;
  pAR: pAudit_Trail_Rec;
  msg: string;
begin
  Token := S.ReadToken;
  while (Token <> tkEndSection) do begin
    case Token of
      tkBegin_Audit_Trail:
          begin
            pAR := New_Audit_Trail_Rec;
            SYATIO.Read_Audit_Trail_Rec(pAR^, S);
            //Read record
            if pAR^.atAudit_Action <> aaDelete then
              SystemAuditMgr.ReadAuditRecord(pAR^.atAudit_Record_Type, S, pAR^.atAudit_Record);
            FAuditRecords.Insert(pAR);
          end
    else
      //Should never happen
      Msg := Format('%s : Unknown Token %d', [THIS_METHOD_NAME, Token]);
      raise ETokenException.CreateFmt('%s - %s', [UNIT_NAME, Msg]);
    end;
    Token := S.ReadToken;
  end;
end;

procedure TAuditTable.SaveToFile(AFileName: TFileName);
var
  OutFile: TIOStream;
begin
  OutFile := TIOStream.Create;
  try
    OutFile.Position := soFromBeginning;
    SaveToStream(OutFile);
    OutFile.SaveToFile(AFileName);
  finally
    OutFile.Free;
  end;
end;

procedure TAuditTable.SaveToStream(var s: TIOStream);
var
  i: Integer;
  AuditRec: TAudit_Trail_Rec;
begin
  S.WriteToken(tkBeginSystem_Audit_Trail_List);
  for i := FAuditRecords.First to FAuditRecords.Last do begin
    AuditRec := FAuditRecords.Audit_At(i);
    SYATIO.Write_Audit_Trail_Rec(AuditRec, S);
    //Write record
    if AuditRec.atAudit_Action <> aaDelete then
      SystemAuditMgr.WriteAuditRecord(AuditRec.atAudit_Record_Type, AuditRec.atAudit_Record, S);
  end;
  S.WriteToken( tkEndSection );
end;

procedure TAuditTable.SetAuditStrings(Index: integer; Strings: TStrings);
var
  AuditRec: TAudit_Trail_Rec;
begin
  AuditRec := AuditRecords.Audit_At(Index);

  Strings.Text := '';
  Strings.Add(SystemAuditMgr.AuditTypeToStr(AuditRec.atTransaction_Type));
  Strings.Add(IntToStr(AuditRec.atRecord_ID));
  Strings.Add(aaNames[AuditRec.atAudit_Action]);
  Strings.Add(AuditRec.atUser_Code);
  Strings.Add(FormatDateTime('dd/MM/yyyy hh:mm:ss', AuditRec.atDate_Time));

  if AuditRec.atAudit_Action = aaDelete then Exit;

  case SystemAuditMgr.DBFromAuditType(AuditRec.atTransaction_Type) of
    dbSystem: SystemAuditMgr.GetValues(AuditRec.atAudit_Record_Type, AuditRec.atAudit_Record, Strings);
    dbClient: ClientAuditMgr.GetValues(AuditRec.atAudit_Record_Type, AuditRec.atAudit_Record, Strings);
  end;
end;

{ TAuditRecords }

function TAuditCollection.Audit_At(Index: Integer): TAudit_Trail_Rec;
begin
  Result := pAudit_Trail_Rec(At(Index))^;
end;

function TAuditCollection.Compare(Item1, Item2: Pointer): Integer;
begin
  Result := TAudit_Trail_Rec(Item1^).atAudit_ID - TAudit_Trail_Rec(Item2^).atAudit_ID;
end;

procedure TAuditCollection.FreeItem(Item: Pointer);
begin
  Dispose(pAudit_Trail_Rec(Item));
end;

end.
