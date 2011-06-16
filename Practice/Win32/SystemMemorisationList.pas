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
    procedure AddAuditValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string);
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

procedure TSystem_Memorisation_List.AddAuditValues(
  const AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  Token, Idx: byte;
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
            153: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_System_Memorisation_List, Token),
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
            142: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdSequence_No, Values);
//    FAuditNamesArray[140,142] := 'Type';
            //Amount
            144: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              Money2Str(TMemorisation_Detail_Rec(ARecord^).mdAmount), Values);
            //Reference
            145: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdReference, Values);
            //Particulars
            146: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdParticulars, Values);
            //Analysis
            147: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdAnalysis, Values);
            //Other_Party
            148: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdOther_Party, Values);
            //Statement_Details
            149: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdStatement_Details, Values);
            //Match_on_Amount
            150: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Amount, Values);
            //Match_on_Analysis
            151: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Analysis, Values);
            //Match_on_Other_Party
            152: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Other_Party, Values);
            //Match_on_Notes
            153: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Notes, Values);
            //Match_on_Particulars
            154: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Particulars, Values);
            //Match_on_Refce
            155: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_on_Refce, Values);
            //Match_On_Statement_Details
            156: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdMatch_On_Statement_Details, Values);
            //Payee_Number
            157: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdPayee_Number, Values);
//    FAuditNamesArray[140,157] := 'From_Master_List';
            //Notes
            159: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdNotes, Values);
            //Date_Last_Applied
            160: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdDate_Last_Applied), Values);
            161: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              TMemorisation_Detail_Rec(ARecord^).mdUse_Accounting_System, Values);
            //Accounting_System
            162: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              GetAccountingSystemName(TMemorisation_Detail_Rec(ARecord^).mdAccounting_System), Values);
            //From_Date
            163: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdFrom_Date), Values);
            //Until_Date
            164: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Detail, Token),
                                              bkDate2Str(TMemorisation_Detail_Rec(ARecord^).mdUntil_Date), Values);
          end;
          Inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
    tkBegin_Memorisation_Line:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Account
            147: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlAccount, Values);
            //Percentage
            148: case TMemorisation_Line_Rec(ARecord^).mlLine_Type of
                   mltPercentage: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, 147),
                                                               Percent2Str(TMemorisation_Line_Rec(ARecord^).mlPercentage) + '%', Values);
                    mltDollarAmt: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, 147),
                                                               Money2Str(TMemorisation_Line_Rec(ARecord^).mlPercentage), Values);
                 end;
            //GST_Class
            149: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlGST_Class, Values);
            //GST_Has_Been_Edited
            150: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlGST_Has_Been_Edited, Values);
            //GL_Narration
            151: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlGL_Narration, Values);
            //Line_Type
            152: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              mltNames[TMemorisation_Line_Rec(ARecord^).mlLine_Type], Values);
            //GST_Amount
            153: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              Money2Str(TMemorisation_Line_Rec(ARecord^).mlGST_Amount), Values);
            //Payee
            154: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlPayee, Values);
            //Job_Code
            166: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              TMemorisation_Line_Rec(ARecord^).mlJob_Code, Values);
            //Quantity
            167: SystemAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Memorisation_Line, Token),
                                              Money2Str(TMemorisation_Line_Rec(ARecord^).mlQuantity), Values);

//**** No need to audit superfund fields as auditing is UK only
//    FAuditNamesArray[145,154] := 'SF_PCFranked';
//    FAuditNamesArray[145,155] := 'SF_Member_ID';
//    FAuditNamesArray[145,156] := 'SF_Fund_ID';
//    FAuditNamesArray[145,157] := 'SF_Fund_Code';
//    FAuditNamesArray[145,158] := 'SF_Trans_ID';
//    FAuditNamesArray[145,159] := 'SF_Trans_Code';
//    FAuditNamesArray[145,160] := 'SF_Member_Account_ID';
//    FAuditNamesArray[145,161] := 'SF_Member_Account_Code';
//    FAuditNamesArray[145,162] := 'SF_Edited';
//    FAuditNamesArray[145,163] := 'SF_Member_Component';
//    FAuditNamesArray[145,164] := 'SF_PCUnFranked';
//    FAuditNamesArray[145,167] := 'SF_GDT_Date';
//    FAuditNamesArray[145,168] := 'SF_Tax_Free_Dist';
//    FAuditNamesArray[145,169] := 'SF_Tax_Exempt_Dist';
//    FAuditNamesArray[145,170] := 'SF_Tax_Deferred_Dist';
//    FAuditNamesArray[145,171] := 'SF_TFN_Credits';
//    FAuditNamesArray[145,172] := 'SF_Foreign_Income';
//    FAuditNamesArray[145,173] := 'SF_Foreign_Tax_Credits';
//    FAuditNamesArray[145,174] := 'SF_Capital_Gains_Indexed';
//    FAuditNamesArray[145,175] := 'SF_Capital_Gains_Disc';
//    FAuditNamesArray[145,176] := 'SF_Capital_Gains_Other';
//    FAuditNamesArray[145,177] := 'SF_Other_Expenses';
//    FAuditNamesArray[145,178] := 'SF_Interest';
//    FAuditNamesArray[145,179] := 'SF_Capital_Gains_Foreign_Disc';
//    FAuditNamesArray[145,180] := 'SF_Rent';
//    FAuditNamesArray[145,181] := 'SF_Special_Income';
//    FAuditNamesArray[145,182] := 'SF_Other_Tax_Credit';
//    FAuditNamesArray[145,183] := 'SF_Non_Resident_Tax';
//    FAuditNamesArray[145,184] := 'SF_Foreign_Capital_Gains_Credit';
//    FAuditNamesArray[145,185] := 'SF_Capital_Gains_Fraction_Half';
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
  AuditInfo.AuditType := atMasterMemorisations;
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
//    AAuditInfo.AuditParentID := AParentID;
    if SYSMIO.System_Memorisation_List_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.smAudit_Record_ID;
//    AAuditInfo.AuditParentID := AParentID;
    P1.smAudit_Record_ID := AAuditInfo.AuditRecordID;
    SYSMIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    //Special Copy
    CopySystemMemorisation(P1, AAuditInfo.AuditRecord);
  end;
end;


end.
