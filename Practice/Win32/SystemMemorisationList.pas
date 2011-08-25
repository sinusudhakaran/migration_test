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
  ECollect, Classes, SYDefs, BKDefs, ioStream, sysUtils, AuditMgr, 
  MemorisationsObj;

type
  pMemorisations_List = ^TMemorisations_List;

  TSystem_Memorisation_List = class(TExtdSortedCollection)
  protected
    function FindRecordID(ARecordID: integer): pSystem_Memorisation_List_Rec;
    procedure FreeItem(Item: Pointer); override;
    procedure SetAuditInfo(P1, P2: pSystem_Memorisation_List_Rec; AParentID: integer; var AAuditInfo: TAuditInfo);
  public
    function Compare(Item1, Item2: Pointer): integer; override;
    function FindPrefix(const APrefix: string): pSystem_Memorisation_List_Rec;
    function System_Memorisation_At(Index: LongInt): pSystem_Memorisation_List_Rec;
    function AddMemorisation(APrefix: string; AMemorisationsList: TMemorisations_List): pSystem_Memorisation_List_Rec;
    procedure DoAudit(AAuditType: TAuditType; ASystemMemorisationsCopy:
              TSystem_Memorisation_List; AParentID: integer;
              var AAuditTable: TAuditTable);
    procedure Insert(Item: Pointer); override;
    procedure LoadFromStream(var S: TIOStream);
    procedure SaveToStream(var S: TIOStream);
  end;

  procedure CopySystemMemorisation(P1, P2: pSystem_Memorisation_List_Rec);

implementation

uses
  TOKENS, SYSMIO, StStrS, LogUtil, BKDbExcept, SYAUDIT, BKAUDIT, BKMDIO, BKMLIO,
  GenUtils, bkdateutils, Dialogs, bkConst;

const
  UNIT_NAME = 'SystemMemorisationList';

{ TSystem_Memorisation_List }

function TSystem_Memorisation_List.AddMemorisation(APrefix: string;
  AMemorisationsList: TMemorisations_List): pSystem_Memorisation_List_Rec;
var
  S: TIOStream;
  System_Memorisation: pSystem_Memorisation_List_Rec;
begin
  Result := nil;
  if Assigned(AMemorisationsList) then begin
    System_Memorisation := New_System_Memorisation_List_Rec;
    System_Memorisation.smBank_Prefix := APrefix;
    //Copy memorisations
    S := TIOStream.Create;
    try
      TMemorisations_List(AMemorisationsList).SaveToStream(S);
      S.Position := 0;
      System_Memorisation.smMemorisations := TMemorisations_List.Create(SystemAuditMgr);
      TMemorisations_List(System_Memorisation.smMemorisations).LoadFromStream(S);
    finally
      S.Free;
    end;
    Insert(System_Memorisation);
    Result := System_Memorisation;
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
  ASystemMemorisationsCopy: TSystem_Memorisation_List; AParentID: integer;
  var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pSystem_Memorisation_List_Rec;
  AuditInfo: TAuditInfo;
  MemorisationsListCopy: TMemorisations_List;
begin
  AuditInfo.AuditType := arMasterMemorisations;
  AuditInfo.AuditUser := SystemAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_System_Memorisation_List;
  //Adds, changes
  for I := 0 to Pred( itemCount ) do begin
    P1 := Items[i];
    P2 := ASystemMemorisationsCopy.FindRecordID(P1.smAudit_Record_ID);
    AuditInfo.AuditRecord := New_System_Memorisation_List_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
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
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if (AuditInfo.AuditAction = aaDelete) then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;

  //Audit each master memorisation for the institution
  for i := 0 to Pred(ItemCount) do begin
    MemorisationsListCopy := nil;
    P1 := Items[i];
    P2 := ASystemMemorisationsCopy.FindRecordID(P1.smAudit_Record_ID);
    if Assigned(P2) then
      MemorisationsListCopy := P2.smMemorisations;
    if Assigned(P1.smMemorisations) then
      TMemorisations_List(P1.smMemorisations).DoAudit(MemorisationsListCopy,
                                                      P1.smAudit_Record_ID,
                                                      AAuditTable);
  end;
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
  Dispose(Item);
end;

procedure TSystem_Memorisation_List.Insert(Item: Pointer);
begin
  pSystem_Memorisation_List_Rec(Item).smAudit_Record_ID := SystemAuditMgr.NextAuditRecordID;
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
  while Token <> tkEndSection do begin
    case Token of
      tkBegin_System_Memorisation_List:
        begin
          System_Memorisation := New_System_Memorisation_List_Rec;
          Read_System_Memorisation_List_Rec(System_Memorisation^, S);
          //Load memorisation list
          System_Memorisation.smMemorisations := TMemorisations_List.Create(SystemAuditMgr);
          TMemorisations_List(System_Memorisation.smMemorisations).LoadFromStream(S);
          inherited Insert(System_Memorisation);
        end
    else
      begin { Should never happen }
        Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
        LogUtil.LogMsg(lmError, UNIT_NAME, Msg);
        raise ETokenException.CreateFmt('%s - %s', [UNIT_NAME, Msg]);
      end;
    end; { of Case }
    Token := S.ReadToken;
  end;
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
      if Assigned(System_Memorisation.smMemorisations) then
        if TMemorisations_List(System_Memorisation.smMemorisations).ItemCount > 0 then begin
          Write_System_Memorisation_List_Rec(System_Memorisation^, S);
          TMemorisations_List(System_Memorisation.smMemorisations).SaveToStream(S);
        end;
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
        P2.smMemorisations := TMemorisations_List.Create(SystemAuditMgr);
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
  AParentID: integer; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','System Memorisation List']) +
                               VALUES_DELIMITER +
                               Format('%s=%d', ['ParentID', AParentID]);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.smAudit_Record_ID;
    AAuditInfo.AuditOtherInfo := AAuditInfo.AuditOtherInfo + VALUES_DELIMITER +
                                 Format('%s=%s',
                                        [SYAuditNames.GetAuditFieldName(tkBegin_System_Memorisation_List, 61),
                                         P2.smBank_Prefix]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.smAudit_Record_ID;
    if SYSMIO.System_Memorisation_List_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.smAudit_Record_ID;
    P1.smAudit_Record_ID := AAuditInfo.AuditRecordID;
    SYSMIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    //Special Copy
    CopySystemMemorisation(P1, AAuditInfo.AuditRecord);
  end;
end;


end.
