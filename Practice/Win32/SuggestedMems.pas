unit SuggestedMems;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  baObj32,
  BKDEFS,
  clObj32,
  smObj32,
  ExtCtrls,
  Classes;

const
  tssNoScan   = 0; tssMin = 0;
  tssExcluded = 1;
  tssScan     = 2; tssMax = 2;

type
  TArrInt = Array of integer;
  TArrSuggPointers = Array of pSuggested_Mem_Rec;

  TSuggestedMems = class(TObject)
  private
    fMainState : Byte;
    fScanTimer : TTimer;
    fMemScanRefCount : integer;

    fNewAccount : boolean;
    fAccountIndex : integer;
    fTranIndex : integer;
    fNoMoreRecord : boolean;
    fTempNoMoreRecord : boolean;
  protected
    procedure DoScanTimer(Sender: TObject);

    procedure LogAllSuggestedMemsForAccount(aBankAccount : TBank_Account);
    procedure LogAllSuggestedMemsForClient(aClient: TClientObj);

    function FindSuggIdUsingTranId(aBankAccount : TBank_Account; aTranSeqNo : integer; var aFoundIndex : integer) : boolean;
    procedure FindOtherSuggIdsUsingFoundId(aBankAccount : TBank_Account; aTranSeqNo, aFoundIndex : integer; var aFoundIds : TArrInt);
    function FindSuggIdsUsingTranId(aBankAccount : TBank_Account; aMatchedTrans : pTransaction_Rec; var aFoundIds : TArrInt) : boolean;

    function FindTranIdsUsingSuggId(aBankAccount : TBank_Account; aSuggId : integer; var aFoundIndex : integer) : boolean;
    function FindSuggestedItem(aBankAccount : TBank_Account; aSuggId : integer; var aFoundItem : pSuggested_Mem_Rec) : boolean;

    function SearchForLongestCommonPhrase(aBankAccount : TBank_Account; aTrans : pTransaction_Rec) : boolean;

    procedure InsertNewLink(aBankAccount : TBank_Account; aTranSeqNo, aSuggId : integer; aSuggestion : pSuggested_Mem_Rec);
    procedure SearchFoundMatch(aPhrase : string; aBankAccount : TBank_Account; aScanTrans, aMatchedTrans : pTransaction_Rec; var aCurrentTranSuggestions : TArrSuggPointers);

    procedure MemScan();
    procedure ProcessTransaction(aBankAccount : TBank_Account; aTrans : pTransaction_Rec);
    procedure ProcessAccount(aBankAccount : TBank_Account);
    procedure ProcessClient(aClient: TClientObj);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetSuggestedTransactionState(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aState : byte);
    procedure UpdateAccountWithTransDelete(aBankAccount : TBank_Account);
    procedure UpdateAccountWithTransInsert(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aNew : boolean);

    procedure SetMainState();
    procedure ResetAll(aClient: TClientObj);

    procedure StartMemScan(aForceStart : boolean = false);
    procedure StopMemScan(aForceStop : boolean = false);

    property MainState : byte read fMainState write fMainState;
  end;

  //----------------------------------------------------------------------------
  function SuggestedMem(): TSuggestedMems;

//------------------------------------------------------------------------------
implementation

uses
  Globals,
  bkConst,
  BKtsIO,
  tsObj32,
  DateUtils,
  Math,
  LogUtil;

const
  UnitName = 'SuggestedMems';
  UnitNameExt = 'SuggestedMemsExt';
  CodedByToInclude = [cbManual, cbECodingManual];

var
  fSuggestedMems: TSuggestedMems;
  DebugMe : boolean = false;
  DebugMeExt : boolean = false;

//------------------------------------------------------------------------------
function SuggestedMem(): TSuggestedMems;
begin
  if not assigned(fSuggestedMems) then
  begin
    fSuggestedMems := TSuggestedMems.Create;
  end;

  result := fSuggestedMems;
end;

{ TSuggestedMems }
//------------------------------------------------------------------------------
procedure TSuggestedMems.DoScanTimer(Sender: TObject);
begin
  if MainState = tssNoScan then
    Exit;

  if fMemScanRefCount > 0 then
    Exit;

  try
    StopMemScan();
    MemScan();
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.LogAllSuggestedMemsForAccount(aBankAccount: TBank_Account);
var
  SuggIndex : integer;
begin
  LogUtil.LogMsg(lmDebug, UnitName, 'MemScan, BankAccount - ' + aBankAccount.baFields.baBank_Account_Number);
  for SuggIndex := 0 to aBankAccount.baSuggested_Mem_List.ItemCount-1 do
  begin
    LogUtil.LogMsg(lmDebug, UnitName,
      'MemScan, Suggestion ' + inttostr(aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggIndex).smFields.smId) +
      ', Phrase - ''' + aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggIndex).smFields.smMatched_Phrase +
      ''', TotalCount = ' + inttostr(aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggIndex).smFields.smTotal_Count) +
      ', ManualCount = ' + inttostr(aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggIndex).smFields.smManual_Count) +
      ', UnCodedCount = ' + inttostr(aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggIndex).smFields.smUncoded_Count));
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.LogAllSuggestedMemsForClient(aClient: TClientObj);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
begin
  if MainState = tssNoScan then
    Exit;

  for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);
    if BankAccount.IsAJournalAccount then
      Continue;

    LogAllSuggestedMemsForAccount(BankAccount);
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindSuggIdUsingTranId(aBankAccount: TBank_Account; aTranSeqNo: integer; var aFoundIndex: integer): boolean;
var
  MidIndex : integer;
  CompareInt : integer;
  DiffValue : integer;
  LastDiffValue : integer;
  LastCompareInt : integer;
  OddValue : integer;
begin
  aFoundIndex := -1;
  if Odd(aBankAccount.baTran_Suggested_Link_List.ItemCount-1) then
    OddValue := 1
  else
    OddValue := 0;

  // Quick Find for first ID
  MidIndex := floor((aBankAccount.baTran_Suggested_Link_List.ItemCount-1)/2);
  DiffValue := MidIndex;
  CompareInt := -99;
  repeat
    LastCompareInt := CompareInt;
    LastDiffValue := DiffValue;
    DiffValue := ceil(DiffValue/2);
    CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(MidIndex).tsFields.tsTran_Seq_No);

    if ((CompareInt+LastCompareInt) = 0) and (LastDiffValue = 1) then
      break;

    if CompareInt = -1 then
    begin
      MidIndex := MidIndex - DiffValue;
      if MidIndex < 0 then
        DiffValue := 0;
    end
    else if CompareInt = 1 then
    begin
      if not odd(MidIndex) then
        DiffValue := DiffValue + OddValue;

      MidIndex := MidIndex + DiffValue;
      if MidIndex >= aBankAccount.baTran_Suggested_Link_List.ItemCount then
        DiffValue := 0;
    end;
  until((CompareInt = 0) or (DiffValue = 0));
  Result := (CompareInt = 0);

  if Result then
    aFoundIndex := MidIndex;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.FindOtherSuggIdsUsingFoundId(aBankAccount: TBank_Account; aTranSeqNo, aFoundIndex: integer; var aFoundIds: TArrInt);
var
  FoundIndex : integer;
  SearchIndex : integer;
  CompareInt : integer;
  DiffValue : integer;
  OddValue : integer;
begin
  // Found one id add to list
  setlength(aFoundIds,1);
  aFoundIds[0] := aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(aFoundIndex).tsFields.tsSuggestedId;

  // Search down for more
  SearchIndex := aFoundIndex;
  dec(SearchIndex);

  if SearchIndex > -1 then
  begin
    CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No);
    while (SearchIndex > -1) and
          (CompareInt = 0) do
    begin
      setlength(aFoundIds, length(aFoundIds)+1);
      aFoundIds[high(aFoundIds)] := aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsSuggestedId;

      dec(SearchIndex);
      if SearchIndex > -1 then
        CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No)
      else
        CompareInt := -1;
    end;
  end;

  // Search up for more
  SearchIndex := aFoundIndex;
  inc(SearchIndex);

  if SearchIndex < aBankAccount.baTran_Suggested_Link_List.ItemCount then
  begin
    CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No);
    while (SearchIndex < aBankAccount.baTran_Suggested_Link_List.ItemCount) and
          (CompareInt = 0) do
    begin
      setlength(aFoundIds, length(aFoundIds)+1);
      aFoundIds[high(aFoundIds)] := aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsSuggestedId;

      inc(SearchIndex);
      if SearchIndex < aBankAccount.baTran_Suggested_Link_List.ItemCount then
        CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No)
      else
        CompareInt := 1;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindSuggIdsUsingTranId(aBankAccount : TBank_Account; aMatchedTrans: pTransaction_Rec; var aFoundIds : TArrInt): boolean;
var
  FoundIndex : integer;
begin
  Result := false;
  if aBankAccount.baTran_Suggested_Link_List.ItemCount = 0 then
    Exit;

  if FindSuggIdUsingTranId(aBankAccount, aMatchedTrans^.txSequence_No, FoundIndex) then
  begin
    FindOtherSuggIdsUsingFoundId(aBankAccount, aMatchedTrans^.txSequence_No, FoundIndex, aFoundIds);
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindTranIdsUsingSuggId(aBankAccount : TBank_Account; aSuggId : integer; var aFoundIndex : integer): boolean;
var
  MidIndex : integer;
  CompareInt : integer;
  DiffValue : integer;
  LastDiffValue : integer;
  LastCompareInt : integer;
  OddValue : integer;
begin
  aFoundIndex := -1;
  if Odd(aBankAccount.baSuggested_Tran_Link_List.ItemCount-1) then
    OddValue := 1
  else
    OddValue := 0;

  // Quick Find for first ID
  MidIndex := floor((aBankAccount.baSuggested_Tran_Link_List.ItemCount-1)/2);
  DiffValue := MidIndex;
  CompareInt := -99;
  repeat
    LastCompareInt := CompareInt;
    LastDiffValue := DiffValue;
    DiffValue := ceil(DiffValue/2);
    CompareInt := CompareValue(aSuggId, aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(MidIndex).tsFields.tsSuggestedId);

    if ((CompareInt+LastCompareInt) = 0) and (LastDiffValue = 1) then
      break;

    if CompareInt = -1 then
    begin
      MidIndex := MidIndex - DiffValue;
      if MidIndex < 0 then
        DiffValue := 0;
    end
    else if CompareInt = 1 then
    begin
      if not odd(MidIndex) then
        DiffValue := DiffValue + OddValue;

      MidIndex := MidIndex + DiffValue;
      if MidIndex >= aBankAccount.baSuggested_Tran_Link_List.ItemCount then
        DiffValue := 0;
    end;
  until((CompareInt = 0) or (DiffValue = 0));
  Result := (CompareInt = 0);

  if Result then
    aFoundIndex := MidIndex;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindSuggestedItem(aBankAccount : TBank_Account; aSuggId : integer; var aFoundItem : pSuggested_Mem_Rec): boolean;
var
  MidIndex : integer;
  CompareInt : integer;
  DiffValue : integer;
  LastDiffValue : integer;
  LastCompareInt : integer;
  OddValue : integer;
begin
  if Odd(aBankAccount.baSuggested_Mem_List.ItemCount-1) then
    OddValue := 1
  else
    OddValue := 0;

  // Quick Find for first ID
  MidIndex := floor((aBankAccount.baSuggested_Mem_List.ItemCount-1)/2);
  DiffValue := MidIndex;
  CompareInt := -99;
  repeat
    LastCompareInt := CompareInt;
    LastDiffValue := DiffValue;
    DiffValue := ceil(DiffValue/2);
    CompareInt := CompareValue(aSuggId, aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(MidIndex).smFields.smId);

    if ((CompareInt+LastCompareInt) = 0) and (LastDiffValue = 1) then
      break;

    if CompareInt = -1 then
    begin
      MidIndex := MidIndex - DiffValue;
      if MidIndex < 0 then
        DiffValue := 0;
    end
    else if CompareInt = 1 then
    begin
      if not odd(MidIndex) then
        DiffValue := DiffValue + OddValue;

      MidIndex := MidIndex + DiffValue;
      if MidIndex >= aBankAccount.baSuggested_Mem_List.ItemCount then
        DiffValue := 0;
    end;
  until((CompareInt = 0) or (DiffValue = 0));
  Result := (CompareInt = 0);

  if Result then
    aFoundItem := aBankAccount.baSuggested_Mem_List.GetAs_pRec(aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(MidIndex));
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.InsertNewLink(aBankAccount : TBank_Account; aTranSeqNo, aSuggId : integer; aSuggestion : pSuggested_Mem_Rec);
var
  NewSuggLink : TTran_Suggested_Link;
begin
  // Current Trans already added to Suggestion so add search trans to suggestion
  NewSuggLink := TTran_Suggested_Link.Create();
  NewSuggLink.tsFields.tsTran_Seq_No := aTranSeqNo;
  NewSuggLink.tsFields.tsSuggestedId := aSuggId;
  aBankAccount.baTran_Suggested_Link_List.Insert(NewSuggLink);

  NewSuggLink := TTran_Suggested_Link.Create();
  NewSuggLink.tsFields.tsTran_Seq_No := aTranSeqNo;
  NewSuggLink.tsFields.tsSuggestedId := aSuggId;
  aBankAccount.baSuggested_Tran_Link_List.Insert(NewSuggLink);

  inc(aSuggestion^.smTotal_Count);
  inc(aSuggestion^.smManual_Count);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SearchFoundMatch(aPhrase : string; aBankAccount : TBank_Account; aScanTrans, aMatchedTrans : pTransaction_Rec; var aCurrentTranSuggestions : TArrSuggPointers);
var
  CurrentIndex  : integer;
  FoundSuggIds  : TArrInt;
  FoundSuggestion : pSuggested_Mem_Rec;
  AddedSuggestion : pSuggested_Mem_Rec;
  NewSuggestion : TSuggested_Mem;
  NewSuggIndex  : integer;

  //----------------------------------------------------------------------------
  procedure AddCurrentTranSuggestion(aSuggestion : pSuggested_Mem_Rec);
  begin
    SetLength(aCurrentTranSuggestions, length(aCurrentTranSuggestions)+1);
    aCurrentTranSuggestions[High(aCurrentTranSuggestions)] := aSuggestion;
  end;

begin
  for CurrentIndex := 0 to high(aCurrentTranSuggestions) do
  begin
    if CompareText(aPhrase, aCurrentTranSuggestions[CurrentIndex]^.smMatched_Phrase) = 0 then
    begin
      // Current Trans already added to Suggestion so add search trans to suggestion
      //InsertNewLink(aBankAccount, aMatchedTrans.txSequence_No, aCurrentTranSuggestions[CurrentIndex]^.smId, aCurrentTranSuggestions[CurrentIndex]);

      Exit;
    end;
  end;

  if FindSuggIdsUsingTranId(aBankAccount, aMatchedTrans, FoundSuggIds) then
  begin
    for CurrentIndex := 0 to high(FoundSuggIds) do
    begin
      if FindSuggestedItem(aBankAccount, FoundSuggIds[CurrentIndex], FoundSuggestion) then
      begin
        if CompareText(aPhrase, FoundSuggestion.smMatched_Phrase) = 0 then
        begin
          // Search Trans already added to Suggestion so add Current Trans
          InsertNewLink(aBankAccount, aScanTrans.txSequence_No, FoundSuggestion^.smId, FoundSuggestion);
          AddCurrentTranSuggestion(FoundSuggestion);
          Exit;
        end;
      end;
    end;
  end;

  // if not found add a new suggestion and new link
  NewSuggestion := TSuggested_Mem.Create;
  NewSuggestion.smFields.smMatched_Phrase := aPhrase;
  NewSuggestion.smFields.smTotal_Count := 0;
  NewSuggestion.smFields.smManual_Count := 0;
  NewSuggestion.smFields.smUncoded_Count := 0;
  NewSuggIndex := aBankAccount.baSuggested_Mem_List.Insert_Suggested_Mem_Rec(NewSuggestion);

  AddedSuggestion := aBankAccount.baSuggested_Mem_List.GetAs_pRec(NewSuggestion);

  AddCurrentTranSuggestion(AddedSuggestion);
  InsertNewLink(aBankAccount, aScanTrans.txSequence_No, NewSuggIndex, AddedSuggestion);
  InsertNewLink(aBankAccount, aMatchedTrans.txSequence_No, NewSuggIndex, AddedSuggestion);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.SearchForLongestCommonPhrase(aBankAccount : TBank_Account; aTrans : pTransaction_Rec) : boolean;
var
  TranIndex : integer;
  TranRec : pTransaction_Rec;
  CurrentTranSuggestions : TArrSuggPointers;
begin
  for TranIndex := aBankAccount.baTransaction_List.ItemCount-1 downto 0 do
  begin
    TranRec := aBankAccount.baTransaction_List.Transaction_At(TranIndex);

    if TranRec^.txSuggested_Mem_State in [tssNoScan, tssExcluded] then
      Continue;

    if (aTrans^.txType      = TranRec^.txType) and
       (aTrans^.txCoded_By in CodedByToInclude) and
       (aTrans^.txAccount   = TranRec^.txAccount) then
    begin
      if length(aTrans^.txStatement_Details) > 2 then
      begin
        if CompareText(aTrans^.txStatement_Details, TranRec^.txStatement_Details) = 0 then
        begin
          SearchFoundMatch(aTrans^.txStatement_Details, aBankAccount, aTrans, TranRec, CurrentTranSuggestions);
        end;
      end;
    end;
  end;

  Result := true;

  SetLength(CurrentTranSuggestions,0);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.MemScan();
var
  StartTime : TDateTime;
  BankAccount: TBank_Account;
  Trans : pTransaction_Rec;
  SuggIndex : integer;
  ScannedOnce : boolean;
begin
  ScannedOnce := false;
  if MyClient.clBank_Account_List.ItemCount = 0 then
    Exit;

  StartTime := Time;
  while ((MilliSecondsBetween(StartTime, Time) < 100) ) do
  begin
    // Check if Account index is valid
    if fAccountIndex > MyClient.clBank_Account_List.ItemCount-1 then
      fAccountIndex := 0;

    // Get Account
    BankAccount := MyClient.clBank_Account_List.Bank_Account_At(fAccountIndex);

    if fNewAccount then
    begin
      if fAccountIndex = 0 then
      begin
        if DebugMe then
        begin
          if fNoMoreRecord <> fTempNoMoreRecord then
          begin
            if fTempNoMoreRecord then
            begin
              LogUtil.LogMsg(lmDebug, UnitName, 'MemScan, No More Records, Client ' + MyClient.clFields.clCode);
              if DebugMeExt then
                LogAllSuggestedMemsForClient(MyClient);
            end
            else
              LogUtil.LogMsg(lmDebug, UnitName, 'MemScan, Found More Records, Client ' + MyClient.clFields.clCode);
          end;
        end;

        if (ScannedOnce) and (fNoMoreRecord) and (fTempNoMoreRecord) then
        begin
          Exit;
        end;

        ScannedOnce := true;

        fNoMoreRecord := fTempNoMoreRecord;
        fTempNoMoreRecord := true;
      end;

      // Set Trans account to max on first scan
      fTranIndex := BankAccount.baTransaction_List.ItemCount-1;

      fNewAccount := false;
    end;

    // Account being processed is done
    if (BankAccount.baFields.baSuggested_UnProcessed_Count = 0) or
       (fTranIndex < 0) or
       (BankAccount.IsAJournalAccount) then
    begin
      if fAccountIndex < MyClient.clBank_Account_List.ItemCount then
        inc(fAccountIndex)
      else
        fAccountIndex := 0;

      fNewAccount := true;
      Continue;
    end;

    fTempNoMoreRecord := false;

    // Check if Account index is valid
    if fTranIndex > BankAccount.baTransaction_List.ItemCount-1 then
      fTranIndex := BankAccount.baTransaction_List.ItemCount-1;

    Trans := BankAccount.baTransaction_List.Transaction_At(fTranIndex);
    Dec(fTranIndex);

    if not (Trans^.txSuggested_Mem_State in [tssExcluded, tssScan]) then
      ProcessTransaction(BankAccount, Trans);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessTransaction(aBankAccount : TBank_Account; aTrans : pTransaction_Rec);
begin
  if MainState = tssNoScan then
    Exit;

  SearchForLongestCommonPhrase(aBankAccount, aTrans);
  SetSuggestedTransactionState(aBankAccount, aTrans, tssScan);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessAccount(aBankAccount: TBank_Account);
var
  TranIndex : integer;
  TranRec : pTransaction_Rec;
begin
  if MainState = tssNoScan then
    Exit;

  if aBankAccount.baFields.baSuggested_UnProcessed_Count = 0 then
    Exit;

  for TranIndex := aBankAccount.baTransaction_List.ItemCount-1 downto 0 do
  begin
    TranRec := aBankAccount.baTransaction_List.Transaction_At(TranIndex);

    if TranRec^.txSuggested_Mem_State = MainState then
      Continue;

    ProcessTransaction(aBankAccount, TranRec);

    if aBankAccount.baFields.baSuggested_UnProcessed_Count = 0 then
      Exit;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessClient(aClient: TClientObj);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
begin
  if MainState = tssNoScan then
    Exit;

  for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);
    if BankAccount.IsAJournalAccount then
      Continue;

    ProcessAccount(BankAccount);
  end;
end;

//------------------------------------------------------------------------------
constructor TSuggestedMems.Create;
begin
  fScanTimer := TTimer.Create(nil);
  fScanTimer.Enabled  := false;
  fScanTimer.Interval := 100;
  fScanTimer.OnTimer  := DoScanTimer;
  fMemScanRefCount := 1;

  fAccountIndex := 0;
  fTranIndex := 0;
  fNoMoreRecord := false;
  fTempNoMoreRecord := false;
end;

//------------------------------------------------------------------------------
destructor TSuggestedMems.Destroy;
begin
  FreeandNil(fScanTimer);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetSuggestedTransactionState(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aState : byte);
var
  OldState : byte;
begin
  if MainState = tssNoScan then
    Exit;

  OldState := aTrans^.txSuggested_Mem_State;
  if OldState = aState then
    Exit;

  if aBankAccount.IsAJournalAccount then
  begin
    aTrans^.txSuggested_Mem_State := tssExcluded;
    Exit;
  end;

  if aTrans^.txCoded_By in CodedByToInclude then
    aTrans^.txSuggested_Mem_State := aState
  else
    aTrans^.txSuggested_Mem_State := tssExcluded;

  if (OldState = MainState) then
    inc(aBankAccount.baFields.baSuggested_UnProcessed_Count);

  if (aTrans^.txSuggested_Mem_State = MainState) or
     (aTrans^.txSuggested_Mem_State = tssExcluded) then
  begin
    if aBankAccount.baFields.baSuggested_UnProcessed_Count > 0 then
      dec(aBankAccount.baFields.baSuggested_UnProcessed_Count);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateAccountWithTransDelete(aBankAccount: TBank_Account);
begin
  if MainState = tssNoScan then
    Exit;

  if aBankAccount.IsAJournalAccount then
    Exit;

  if aBankAccount.baFields.baSuggested_UnProcessed_Count > 0 then
    Dec(aBankAccount.baFields.baSuggested_UnProcessed_Count);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateAccountWithTransInsert(aBankAccount: TBank_Account; aTrans: pTransaction_Rec; aNew : boolean);
begin
  if MainState = tssNoScan then
    Exit;

  if aBankAccount.IsAJournalAccount then
  begin
    aTrans^.txSuggested_Mem_State := tssExcluded;
    Exit;
  end;

  if (aNew) or (MEMSINI_SupportOptions = meiResetMems) then
  begin
    if aTrans^.txCoded_By in CodedByToInclude then
      aTrans^.txSuggested_Mem_State := tssNoScan
    else
      aTrans^.txSuggested_Mem_State := tssExcluded;
  end;

  if aTrans^.txSuggested_Mem_State = tssNoScan then
    inc(aBankAccount.baFields.baSuggested_UnProcessed_Count);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetMainState();
begin
  case MEMSINI_SupportOptions of
    meiDisableSuggestedMemsAll : fMainState := tssNoScan;
    meiResetMems               : fMainState := tssScan;
    meiDisableSuggestedMemsv2  : fMainState := tssScan;
    meiFullfunctionality       : fMainState := tssScan;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ResetAll(aClient: TClientObj);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
  TranIndex : integer;
  TranRec : pTransaction_Rec;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'ResetAll, Client ' + aClient.clFields.clCode);

  try
    StopMemScan();
    fNewAccount := true;
    fAccountIndex := 0;
    fTranIndex := 0;

    for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);
      if BankAccount.IsAJournalAccount then
        Continue;

      BankAccount.baFields.baSuggested_UnProcessed_Count := 0;
      for TranIndex := 0 to BankAccount.baTransaction_List.ItemCount-1  do
      begin
        TranRec := BankAccount.baTransaction_List.Transaction_At(TranIndex);

        if TranRec^.txCoded_By in CodedByToInclude then
        begin
          TranRec^.txSuggested_Mem_State := tssNoScan;
          inc(BankAccount.baFields.baSuggested_UnProcessed_Count);
        end
        else
          TranRec^.txSuggested_Mem_State := tssExcluded;
      end;

      BankAccount.baSuggested_Mem_List.DeleteFreeAll();
      BankAccount.baTran_Suggested_Link_List.DeleteFreeAll();
      BankAccount.baSuggested_Tran_Link_List.DeleteFreeAll();
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.StartMemScan(aForceStart : boolean);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
begin
  if MainState = tssNoScan then
    Exit;

  if aForceStart then
  begin
    if DebugMe then
    begin
      LogUtil.LogMsg(lmDebug, UnitName, 'StartMemScan, Client ' + MyClient.clFields.clCode);
      for BankAccIndex := 0 to MyClient.clBank_Account_List.ItemCount-1 do
      begin
        BankAccount := MyClient.clBank_Account_List.Bank_Account_At(BankAccIndex);
        if BankAccount.IsAJournalAccount then
          Continue;

        LogUtil.LogMsg(lmDebug, UnitName, 'StartMemScan, Account ' + BankAccount.baFields.baBank_Account_Number +
                                          ', Unscanned Count = ' + inttostr(BankAccount.baFields.baSuggested_UnProcessed_Count));
      end;
    end;

    fNewAccount := true;
    fMemScanRefCount := 0;
    fScanTimer.Enabled := true;
    fTempNoMoreRecord := false;
    fNoMoreRecord := false;

    Exit;
  end;

  if fMemScanRefCount > 0 then
    dec(fMemScanRefCount);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.StopMemScan(aForceStop : boolean);
begin
  if MainState = tssNoScan then
    Exit;

  inc(fMemScanRefCount);

  if aForceStop then
  begin
    fScanTimer.Enabled := false;

    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'StopMemScan, Client ' + MyClient.clFields.clCode);
  end;
end;

//------------------------------------------------------------------------------
initialization
begin
  DebugMe := DebugUnit(UnitName);
  DebugMeExt := DebugUnit(UnitNameExt) or DebugMe;
  fSuggestedMems := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  FreeAndNil(fSuggestedMems);
end;

end.
