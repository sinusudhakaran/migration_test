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
//    procedure CopySystem(P1, P2: pPractice_Details_Rec);
//    procedure CompareAndCopySystem(P1, P2, P3: pPractice_Details_Rec);
    procedure LoadFromStream(var AStream: TIOStream);
    procedure SaveToStream(var AStream: TIOStream);
    procedure SetAuditInfo(P1, P2: pPractice_Details_Rec; var AAuditInfo: TAuditInfo);
  public
    constructor Create;
    destructor Destroy; override;
    function NextAuditRecordID: integer;
    procedure DoAudit(APracticeDetails: pPractice_Details_Rec);
    procedure LoadFromFile(AFileName: TFilename);
    procedure SaveToFile(AFileName: TFilename);
    property UserTable: TUserTable read FUserTable;
    property AuditTable: TAuditTable read FAuditTable;
    procedure AddAuditValues(var Values: string; ARecord: pointer);
  end;

  //Client DB singleton
  function SystemData: TSystemDatabase;
  function SystemCopy: TSystemDatabase;

implementation

uses
  TOKENS, SYFDIO, SYAUDIT, SYAuditUtils;

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

procedure TSystemDatabase.AddAuditValues(var Values: string; ARecord: pointer);
begin
  SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 11),
                               tPractice_Details_Rec(ARecord^).fdPractice_Name_for_Reports, Values);
  SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 76),
                               tPractice_Details_Rec(ARecord^).fdPractice_Phone, Values);
  //GST names array
  GST_Class_Names_Audit_Values(TGST_Class_Names_Array(tPractice_Details_Rec(ARecord^).fdGST_Class_Names), Values);
  //GST rates array
  GST_Rates_Audit_Values(TGST_Rates_Array(tPractice_Details_Rec(ARecord^).fdGST_Rates), Values);
end;

//procedure TSystemDatabase.CompareAndCopySystem(P1, P2, P3: pPractice_Details_Rec);
//var
//  i, j: integer;
//begin
//  if P1.fdPractice_Name_for_Reports <> P2.fdPractice_Name_for_Reports then
//    P3.fdPractice_Name_for_Reports := P1.fdPractice_Name_for_Reports;
//  if P1.fdPractice_Phone <> P2.fdPractice_Phone then
//    P3.fdPractice_Phone := P1.fdPractice_Phone;
//  if StringArrayChanged(TStrArray(P1.fdGST_Class_Names), TStrArray(P2.fdGST_Class_Names)) then
//    for i := Low(P1.fdGST_Class_Names) to high(P1.fdGST_Class_Names) do
//      if P1.fdGST_Class_Names[i] <> P2.fdGST_Class_Names[i] then
//        P3.fdGST_Class_Names[i] := P1.fdGST_Class_Names[i];
//  if RatesArrayChanged(TRatesArray(P1.fdGST_Rates), TRatesArray(P2.fdGST_Rates)) then
//    for i := Low(P1.fdGST_Rates) to high(P1.fdGST_Rates) do
//      for j := Low(P1.fdGST_Rates[i]) to High((P1.fdGST_Rates[i])) do
//        if P1.fdGST_Rates[i, j] <> P2.fdGST_Rates[i, j] then
//          P3.fdGST_Rates[i, j] := P1.fdGST_Rates[i, j];
//end;

//procedure TSystemDatabase.CopySystem(P1, P2: pPractice_Details_Rec);
//var
//  S: TIOStream;
//begin
//  S := TIOStream.Create;
//  try
//    Write_Practice_Details_Rec(P1^, S);
//    S.Position := 0;
//    Read_Practice_Details_Rec(P2^, S);
//  finally
//    S.Free;
//  end;
//end;

constructor TSystemDatabase.Create;
begin
  inherited;

  FillChar(PracticeDetails, Sizeof(PracticeDetails), 0);
  PracticeDetails.fdRecord_Type := tkBegin_Practice_Details;
  PracticeDetails.fdEOR := tkEnd_Practice_Details;

  FLastAuditRecordID := 0;
  if PracticeDetails.fdAudit_Record_ID = 0 then
    PracticeDetails.fdAudit_Record_ID := NextAuditRecordID;

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

procedure TSystemDatabase.DoAudit(APracticeDetails: pPractice_Details_Rec);
var
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditAction := aaNone;
  AuditInfo.AuditType := atPracticeSetup;
  AuditInfo.AuditUser := 'SCOTT.WI';
  SetAuditInfo(@PracticeDetails, APracticeDetails, AuditInfo);
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

procedure TSystemDatabase.SetAuditInfo(P1, P2: pPractice_Details_Rec;
  var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditRecord := New_Practice_Details_Rec;
  if Practice_Details_Rec_Delta(P1, P2, AAuditInfo.AuditRecord) then begin
    AAuditInfo.AuditAction := aaChange;
    AAuditInfo.AuditRecordID := P1.fdAudit_Record_ID;
    AAuditInfo.AuditParentID := -1; //No parent
    AAuditInfo.AuditRecordType := tkBegin_Practice_Details;
  end else
    FreeAndNil(AAuditInfo.AuditRecord); //No change
end;

end.
