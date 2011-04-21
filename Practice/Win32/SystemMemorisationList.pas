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
    function AddMemorisation(APrefix: string; AMemorisationsList: TMemorisations_List): pSystem_Memorisation_List_Rec;
    procedure DoAudit(AAuditType: TAuditType; ASystemMemorisationsCopy:
              TSystem_Memorisation_List; var AAuditTable: TAuditTable);
    procedure Insert(Item: Pointer); override;
    procedure LoadFromStream(var S: TIOStream);
    procedure SaveToStream(var S: TIOStream);
  end;

  procedure CopySystemMemorisation(P1, P2: pSystem_Memorisation_List_Rec);

implementation

uses
  TOKENS, SYSMIO, StStrS, LogUtil, BKDbExcept, SYAUDIT, BKAUDIT, BKMDIO,
  MoneyUtils, bkdateutils;

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

  case AAuditRecord.atAudit_Record_Type of
    tkBegin_System_Memorisation_List:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Prefix
            153: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Memorisation_List, 152),
                                             TSystem_Memorisation_List_Rec(ARecord^).smBank_Prefix, Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
    tkBegin_Memorisation_Detail :
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Sequence_No
            142: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 141),
                                              TMemorisation_Detail_Rec(ARecord^).mdSequence_No, Values);
//    FAuditNamesArray[140,142] := 'Type';
            //Amount
            144: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 143),
                                              MoneyStrNoSymbol(TMemorisation_Detail_Rec(ARecord^).mdAmount), Values);
            //Reference
            145: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 144),
                                              TMemorisation_Detail_Rec(ARecord^).mdReference, Values);
            //Particulars
            146: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 145),
                                              TMemorisation_Detail_Rec(ARecord^).mdParticulars, Values);
            //Analysis
            147: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 146),
                                              TMemorisation_Detail_Rec(ARecord^).mdAnalysis, Values);
            //Other_Party
            148: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 147),
                                              TMemorisation_Detail_Rec(ARecord^).mdOther_Party, Values);
            //Statement_Details
            149: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 148),
                                              TMemorisation_Detail_Rec(ARecord^).mdStatement_Details, Values);
            //Match_on_Amount
            150: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 149),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Amount, Values);
            //Match_on_Analysis
            151: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 150),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Analysis, Values);
            //Match_on_Other_Party
            152: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 151),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Other_Party, Values);
            //Match_on_Notes
            153: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 152),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Notes, Values);
            //Match_on_Particulars
            154: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 153),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Particulars, Values);
            //Match_on_Refce
            155: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 154),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Refce, Values);
            //Match_On_Statement_Details
            156: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 155),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_On_Statement_Details, Values);
            //Payee_Number
            157: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 156),
                                              TMemorisation_Detail_Rec(ARecord^).mdPayee_Number, Values);
//    FAuditNamesArray[140,157] := 'From_Master_List';
            //Notes
            159: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 158),
                                              TMemorisation_Detail_Rec(ARecord^).mdNotes, Values);
            //Date_Last_Applied
            160: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 159),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdDate_Last_Applied), Values);
            161: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 160),
                                              TMemorisation_Detail_Rec(ARecord^).mdUse_Accounting_System, Values);
            //Accounting_System
            162: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 161),
                                              GetAccountingSystemName(TMemorisation_Detail_Rec(ARecord^).mdAccounting_System), Values);
            //From_Date
            163: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 162),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdFrom_Date), Values);
            //Until_Date
            164: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, 163),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdUntil_Date), Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
  end;

end;

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
      System_Memorisation.smMemorisations := TMemorisations_List.Create;
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
  ASystemMemorisationsCopy: TSystem_Memorisation_List;
  var AAuditTable: TAuditTable);
var
  i, j: integer;
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

  //Test - audit each master memorisation for the institution
  for I := 0 to Pred( itemCount ) do begin
    P1 := Items[i];
    P2 := ASystemMemorisationsCopy.FindRecordID(P1.smAudit_Record_ID);
    if Assigned(P1.smMemorisations) then begin
      TMemorisations_List(P1.smMemorisations).DoAudit(atMasterMemorisations, P2.smMemorisations, AAuditTable);
    end;
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
  while Token <> tkEndSection do begin
    case Token of
      tkBegin_System_Memorisation_List:
        begin
          System_Memorisation := New_System_Memorisation_List_Rec;
          Read_System_Memorisation_List_Rec(System_Memorisation^, S);
          //Load memorisation list
          System_Memorisation.smMemorisations := TMemorisations_List.Create;
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
    if SYSMIO.System_Memorisation_List_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
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
    CopySystemMemorisation(P1, AAuditInfo.AuditRecord);
  end;
end;


end.
