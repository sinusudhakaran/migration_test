{-----------------------------------------------------------------------------
 Unit Name: SystemMemorisationList
 Author:    scott.wilson
 Date:      28-Mar-2011
 Purpose:   Used to save Master memorisation lists to the System DB
 History:
-----------------------------------------------------------------------------}

unit SystemMemorisationList;

interface

uses
  ECollect, Classes, SYDefs, BKDefs, ioStream, sysUtils, AuditMgr, SysAudit,
  MemorisationsObj;

type
  pMemorisations_List = ^TMemorisations_List;

//  TSystem_Memorisation = class(TObject)
//  private
//    FSystem_Memorisation_List_Rec: pSystem_Memorisation_List_Rec;
//    FMemorisations_List: TMemorisations_List;
//    function GetPrefix: string;
//    procedure SetMemorisations_List(const Value: TMemorisations_List);
//    procedure SetPrefix(const Value: string);
//  public
//    constructor Create;
//    destructor Destroy; override;
//    procedure DoAudit(AAuditType: TAuditType; ASystemMemCopy: TSystem_Memorisation; var AAuditTable: TAuditTable);
//    procedure SaveToStream(var S: TIOStream);
//    procedure LoadFromStream(var S: TIOStream);
//    property Prefix: string read GetPrefix write SetPrefix;
//    property Memorisations_List: TMemorisations_List read FMemorisations_List write SetMemorisations_List;
//  end;

//  TSystem_Memorisation_List = class(TExtdSortedCollection)
//  protected
//    function FindRecordID(ARecordID: integer): TSystem_Memorisation;
//    procedure FreeItem(Item: Pointer); override;
//    procedure SetAuditInfo(P1, P2: TSystem_Memorisation; var AAuditInfo: TAuditInfo);
//  public
//    function Compare(Item1, Item2: Pointer): integer; override;
//    function FindPrefix(const APrefix: string): TSystem_Memorisation;
//    function System_Memorisation_At(Index: LongInt): TSystem_Memorisation;
//    procedure AddAuditValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string);
//    procedure AddMemorisation(APrefix: string; AMemorisationsList: TMemorisations_List);
//    procedure DoAudit(AAuditType: TAuditType; ASystemMemorisationsCopy: TSystem_Memorisation_List; var AAuditTable: TAuditTable);
//    procedure Insert(Item: Pointer); override;
//    procedure LoadFromStream(var S: TIOStream);
//    procedure SaveToStream(var S: TIOStream);
//  end;

  TSystem_Memorisation_List = class(TExtdSortedCollection)
  protected
    function FindRecordID(ARecordID: integer): pSystem_Memorisation_List_Rec;
    procedure FreeItem(Item: Pointer); override;
    procedure SetAuditInfo(P1, P2: pSystem_Memorisation_List_Rec; var AAuditInfo: TAuditInfo);
  public
    function Compare(Item1, Item2: Pointer): integer; override;
    function FindPrefix(const APrefix: string): pSystem_Memorisation_List_Rec;
    function System_Memorisation_At(Index: LongInt): pSystem_Memorisation_List_Rec;
    procedure AddAuditValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string);
    procedure AddMemorisation(APrefix: string; AMemorisationsList: TMemorisations_List);
    procedure DoAudit(AAuditType: TAuditType; ASystemMemorisationsCopy: TSystem_Memorisation_List; var AAuditTable: TAuditTable);
    procedure Insert(Item: Pointer); override;
    procedure LoadFromStream(var S: TIOStream);
    procedure SaveToStream(var S: TIOStream);
  end;


  procedure CopySystemMemorisation(P1, P2: pSystem_Memorisation_List_Rec);

implementation

uses
  TOKENS, SYSMIO, StStrS, LogUtil, BKDbExcept, SYAUDIT;

const
  UNIT_NAME = 'SystemMemorisationList';

{ TSystem_Memorisation_List }

procedure TSystem_Memorisation_List.AddAuditValues(
  const AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  Token, Idx: byte;
  UserType: string;
  ARecord: Pointer;
begin
  ARecord := AAuditRecord.atAudit_Record;

  if ARecord = nil then begin
    Values := AAuditRecord.atOther_Info;
    Exit;
  end;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //Prefix
      143: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Memorisation_List, 142),
                                       TSystem_Memorisation_List_Rec(ARecord^).smBank_Prefix, Values);
    end;
    Inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

procedure TSystem_Memorisation_List.AddMemorisation(APrefix: string;
  AMemorisationsList: TMemorisations_List);
var
  S: TIOStream;
  System_Memorisation: pSystem_Memorisation_List_Rec;
begin
  if Assigned(AMemorisationsList) then begin
//    System_Memorisation := TSystem_Memorisation.Create;
    System_Memorisation := New_System_Memorisation_List_Rec;
    System_Memorisation.smBank_Prefix := APrefix;
    //Copy memorisations
    S := TIOStream.Create;
    try
      TMemorisations_List(AMemorisationsList).SaveToStream(S);
      S.Position := 0;
      System_Memorisation.smMemorisations := TMemorisations_List.Create;
      TMemorisations_List(System_Memorisation.smMemorisations).LoadFromStream(S);
    finally
      S.Free;
    end;
    Insert(System_Memorisation);
  end;
end;

function TSystem_Memorisation_List.Compare(Item1, Item2: Pointer): integer;
var
  S1, S2: string;
begin
  S1 := pSystem_Memorisation_List_Rec(Item1).smBank_Prefix;
  S2 := pSystem_Memorisation_List_Rec(Item2).smBank_Prefix;
  Compare := CompStringS(S1, S2);
end;

procedure TSystem_Memorisation_List.DoAudit(AAuditType: TAuditType;
  ASystemMemorisationsCopy: TSystem_Memorisation_List;
  var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pSystem_Memorisation_List_Rec;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := atMasterMemorisations;
  AuditInfo.AuditUser := SystemAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_System_Memorisation_List;
  //Adds, changes
  for I := 0 to Pred( itemCount ) do begin
    P1 := Items[i];
    P2 := ASystemMemorisationsCopy.FindRecordID(P1.smAudit_Record_ID);
//    AuditInfo.AuditRecord := New_System_Memorisation_List_Rec;
    AuditInfo.AuditRecord := New_System_Memorisation_List_Rec;
    try
      SetAuditInfo(P1, P2, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
  end;
  //Deletes
  for i := 0 to ASystemMemorisationsCopy.ItemCount - 1 do begin
    P2 := ASystemMemorisationsCopy.Items[i];
    P1 := FindRecordID(P2.smAudit_Record_ID);
    AuditInfo.AuditRecord := New_System_Memorisation_List_Rec;
    try
      SetAuditInfo(P1, P2, AuditInfo);
      if (AuditInfo.AuditAction = aaDelete) then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Test - audit sub items
//  for I := 0 to Pred( itemCount ) do begin
//    P1 := Items[i];
//    P1.DoAudit(
//  end;
end;

function TSystem_Memorisation_List.FindPrefix(
  const APrefix: string): pSystem_Memorisation_List_Rec;
var
  i: integer;
  System_Memorisation: pSystem_Memorisation_List_Rec;
begin
  Result := nil;
  for i := First to Last do begin
    System_Memorisation := System_Memorisation_At(i);
    if Assigned(System_Memorisation) then
      if System_Memorisation.smBank_Prefix = APrefix then begin
        Result := System_Memorisation;
        Break;
      end;
  end;
end;

function TSystem_Memorisation_List.FindRecordID(
  ARecordID: integer): pSystem_Memorisation_List_Rec;
var
  i: integer;
  System_Memorisation: pSystem_Memorisation_List_Rec;
begin
  Result := nil;
  for i := First to Last do begin
    System_Memorisation := System_Memorisation_At(i);
    if Assigned(System_Memorisation) then
      if System_Memorisation.smAudit_Record_ID = ARecordID then begin
        Result := System_Memorisation;
        Break;
      end;
  end;
end;

procedure TSystem_Memorisation_List.FreeItem(Item: Pointer);
begin
//  TSystem_Memorisation(Item).Free;
  Dispose(Item);
//  Free_System_Memorisation_List_Rec_Dynamic_Fields(pSystem_Memorisation_List_Rec(Item)^);
//  SafeFreeMem( Item, System_Memorisation_List_Rec_Size );
end;

procedure TSystem_Memorisation_List.Insert(Item: Pointer);
begin
  pSystem_Memorisation_List_Rec(Item).smAudit_Record_ID := SystemAuditMgr.NextSystemRecordID;
  inherited Insert(Item);
end;

procedure TSystem_Memorisation_List.LoadFromStream(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Memorisation_List.LoadFromStream';
var
  Token: Byte;
  Msg: string;
  System_Memorisation: pSystem_Memorisation_List_Rec;
begin
  Token := S.ReadToken;
  repeat
    case Token of
      tkBegin_System_Memorisation_List:
        begin
          System_Memorisation := New_System_Memorisation_List_Rec;
          Read_System_Memorisation_List_Rec(System_Memorisation^, S);
          //Load memorisation list
          System_Memorisation.smMemorisations := TMemorisations_List.Create;
          TMemorisations_List(System_Memorisation.smMemorisations).LoadFromStream(S);
          Self.Insert(System_Memorisation);
        end
    else
      begin { Should never happen }
        Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
        LogUtil.LogMsg(lmError, UNIT_NAME, Msg);
        raise ETokenException.CreateFmt('%s - %s', [UNIT_NAME, Msg]);
      end;
    end; { of Case }
    Token := S.ReadToken;
  until Token = tkEndSection;
end;

function TSystem_Memorisation_List.System_Memorisation_At(
  Index: Integer): pSystem_Memorisation_List_Rec;
var
  P: Pointer;
begin
  Result := nil;
  P := At(Index);
  if IsASystem_Memorisation_List_Rec(P) then
    Result := P;
end;

procedure TSystem_Memorisation_List.SaveToStream(var S: TIOStream);
var
  i: integer;
  System_Memorisation: pSystem_Memorisation_List_Rec;
begin
  S.WriteToken(tkBeginSystem_Memorisation_List);
  for i := First to Last do begin
    System_Memorisation := System_Memorisation_At(i);
    if Assigned(System_Memorisation) then
      Write_System_Memorisation_List_Rec(System_Memorisation^, S);
    //Save memorisation list
    if Assigned(System_Memorisation.smMemorisations) then
      TMemorisations_List(System_Memorisation.smMemorisations).SaveToStream(S);
  end;
  S.WriteToken( tkEndSection );
end;

procedure CopySystemMemorisation(P1, P2: pSystem_Memorisation_List_Rec);
var
  S: TIOStream;
begin
  if Assigned(P1) then begin
    Copy_System_Memorisation_List_Rec(P1, P2);
    //Also copy Memorisation List
    P2.smMemorisations := nil;
    if Assigned(P1.smMemorisations) then begin
      S := TIOStream.Create;
      try
        P2.smMemorisations := TMemorisations_List.Create;
        TMemorisations_List(P1.smMemorisations).SaveToStream(S);
        S.Position := 0;
        TMemorisations_List(P2.smMemorisations).LoadFromStream(S);
      finally
        S.Free;
      end;
    end;
  end;
end;

procedure TSystem_Memorisation_List.SetAuditInfo(P1, P2: pSystem_Memorisation_List_Rec;
  var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.smAudit_Record_ID;
    AAuditInfo.AuditOtherInfo := Format('%s=%s',
                                        [SYAuditNames.GetAuditFieldName(tkBegin_System_Memorisation_List, 61),
                                         P2.smBank_Prefix]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.smAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    if SYSMIO.System_Memorisation_List_Rec_Delta(@P1, @P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.smAudit_Record_ID;
    AAuditInfo.AuditParentID := SystemAuditMgr.GetParentRecordID(AAuditInfo.AuditRecordType,
                                                                 AAuditInfo.AuditRecordID);
    P1.smAudit_Record_ID := AAuditInfo.AuditRecordID;
    SYSMIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    //Special Copy
    P2 := New_System_Memorisation_List_Rec;
    CopySystemMemorisation(P1, P2);
  end;
end;

{ TSystem_Memorisation }

//constructor TSystem_Memorisation.Create;
//begin
//  FSystem_Memorisation_List_Rec := New_System_Memorisation_List_Rec;
//  FMemorisations_List := TMemorisations_List.Create;
//end;
//
//destructor TSystem_Memorisation.Destroy;
//begin
//  FMemorisations_List.FreeAll;
//  Dispose(FSystem_Memorisation_List_Rec);
//
//  inherited;
//end;
//
//procedure TSystem_Memorisation.DoAudit(AAuditType: TAuditType;
//  ASystemMemCopy: TSystem_Memorisation; var AAuditTable: TAuditTable);
//begin
////
//end;
//
//function TSystem_Memorisation.GetPrefix: string;
//begin
//  Result := FSystem_Memorisation_List_Rec.smBank_Prefix;
//end;
//
//procedure TSystem_Memorisation.LoadFromStream(var S: TIOStream);
//begin
//  Read_System_Memorisation_List_Rec(FSystem_Memorisation_List_Rec^, S);
//  FMemorisations_List.LoadFromStream(S);
//end;
//
//procedure TSystem_Memorisation.SaveToStream(var S: TIOStream);
//begin
//  Write_System_Memorisation_List_Rec(FSystem_Memorisation_List_Rec^, S);
//  FMemorisations_List.SaveToStream(S);
//end;
//
//procedure TSystem_Memorisation.SetMemorisations_List(
//  const Value: TMemorisations_List);
//begin
//  FMemorisations_List := Value;
//end;
//
//
//procedure TSystem_Memorisation.SetPrefix(const Value: string);
//begin
//  FSystem_Memorisation_List_Rec.smBank_Prefix := Value;
//end;

end.
