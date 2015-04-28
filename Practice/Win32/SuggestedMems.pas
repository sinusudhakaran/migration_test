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
  tsList32,
  MemorisationsObj,
  Classes;

const
  mtsNoScan   = 0; mtsMin = 0;
  mtsExcluded = 1;
  mtsScan     = 2; mtsMax = 3;

  tssUnScanned     = 0; tssMin = 0;
  tssExcluded      = 1;
  tssManualScanned = 2;
  tssUnCodedScaned = 3; tssMax = 3;

  tssScanned = [tssManualScanned, tssUnCodedScaned];
  tssScannedAndExluded = [tssExcluded, tssManualScanned, tssUnCodedScaned];

type
  TArrInt = Array of integer;
  TArrSuggPointers = Array of pSuggested_Mem_Rec;

  TSuggestedMemsData = record
    smId               : integer;
    smType             : Byte;
    smMatchedPhrase    : String[ 200 ];
    smAccount          : String[ 20 ];
    smTotalCount       : Integer;
  end;
  pSuggestedMemsData = ^TSuggestedMemsData;
  TSuggestedMemsArr = array of TSuggestedMemsData;

  //----------------------------------------------------------------------------
  TDoneProcessingEvent = procedure() of object;

  //----------------------------------------------------------------------------
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

    fDoneProcessingEvent : TDoneProcessingEvent;
  protected
    procedure DoScanTimer(Sender: TObject);

    procedure LogAllSuggestedMemsForAccount(aBankAccount : TBank_Account);
    procedure LogAllSuggestedMemsForClient(aClient: TClientObj);

    function FindLinkIndexUsingBothIds(aBankAccount: TBank_Account; aSuggId, aTranSeqNo : integer; aSearchList : TTranSuggSortType; var aFoundIndex: integer): boolean;
    function FindLinkId(aBankAccount: TBank_Account; aSearchId: integer; aSearchType : TTranSuggSortType; var aFoundIndex: integer) : boolean;
    function FindTransUsingEffDateAndSeqNo(aBankAccount: TBank_Account; aEffDate, aTranSeqNo : integer; var aTran : pTransaction_Rec) : boolean;
    function FindSuggestedItem(aBankAccount : TBank_Account; aSuggId : integer; var aFoundIndex : integer; var aFoundItem : pSuggested_Mem_Rec) : boolean;

    procedure FindOtherSuggIdsUsingFoundId(aBankAccount: TBank_Account; aTranSeqNo, aFoundIndex: integer; var aFoundIds, aFoundIndexes: TArrInt);
    function FindSuggIdsUsingTranId(aBankAccount : TBank_Account; aTranSeqNo : integer; var aFoundIds : TArrInt) : boolean;

    procedure FindOtherTranIdsUsingFoundId(aBankAccount : TBank_Account; aSuggId, aFoundIndex : integer; var aFoundIds, aFoundIndexes : TArrInt);
    function FindTranIdsUsingSuggId(aBankAccount : TBank_Account; aSuggId : integer; var aFoundIds : TArrInt) : boolean;

    function GetSuggestionMatchText(const aMatchPhrase : string; aStart, aEnd : boolean) : string;

    function SearchForLongestCommonPhrase(aBankAccount : TBank_Account; aTrans : pTransaction_Rec) : boolean;

    procedure DeleteSuggestionAndLinks(aBankAccount : TBank_Account; aSuggId : integer);
    procedure DeleteLinksAndSuggestions(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aOldTranState : byte);
    procedure InsertNewLink(aBankAccount : TBank_Account; aTranState : byte; aTrans : pTransaction_Rec; aSuggId : integer; aSuggestion : pSuggested_Mem_Rec);
    procedure SearchFoundMatch(aStartData: boolean; var aLCSstr : string; aEndData: boolean; aBankAccount : TBank_Account; aScanTrans, aMatchedTrans : pTransaction_Rec; var aCurrentTranSuggestions : TArrSuggPointers);

    function IsMemorisation(aMemorisations: TMemorisations_List; aType : byte; const aMatchPhrase : string): boolean;
    function IsMasterMemorisation(aType: byte; const aMatchPhrase, aBankPrefix: string): boolean;
    function IsSuggestionUsedByMem(aBankAccount : TBank_Account; aSuggestion : pSuggested_Mem_Rec): boolean;

    procedure MemScan();
    procedure ProcessTransaction(aBankAccount : TBank_Account; aTrans : pTransaction_Rec);
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

    function GetSuggestedMemsCount(aBankAccount : TBank_Account) : integer;
    function GetSuggestedMems(aBankAccount : TBank_Account) : TSuggestedMemsArr;

    function DetermineStatus(aBankAccount : TBank_Account): string;

    property MainState : byte read fMainState write fMainState;
    property NoMoreRecord : boolean read fNoMoreRecord;

    property DoneProcessingEvent : TDoneProcessingEvent read fDoneProcessingEvent write fDoneProcessingEvent;
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
  lcs2,
  SYDEFS,
  mxFiles32,
  LogUtil;

const
  UnitName = 'SuggestedMems';
  UnitNameExt = 'SuggestedMemsExt';
  ManualCodedBy = [cbManual, cbECodingManual];

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
  if MainState = mtsNoScan then
    Exit;

  if fMemScanRefCount > 0 then
    Exit;

  StopMemScan();
  try
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
  if MainState = mtsNoScan then
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
function TSuggestedMems.FindLinkIndexUsingBothIds(aBankAccount: TBank_Account; aSuggId, aTranSeqNo : integer; aSearchList : TTranSuggSortType; var aFoundIndex: integer): boolean;
var
  CurrIndex : integer;
  OldIndex : integer;
  CurrValue : double;
  DiffValue : double;
  CompareInt : integer;
  LinkList : TTran_Suggested_Link_List;

  //----------------------------------------------------------------------------
  function Compare() : integer;
  begin
    Result := 0;
    if aSearchList = tstTranId then
    begin
      Result := CompareValue(aTranSeqNo, LinkList.Tran_Suggested_Link_At(CurrIndex).tsFields.tsTran_Seq_No);
      if Result = 0 then
        Result := CompareValue(aSuggId, LinkList.Tran_Suggested_Link_At(CurrIndex).tsFields.tsSuggestedId);
    end
    else
    begin
      Result := CompareValue(aSuggId, LinkList.Tran_Suggested_Link_At(CurrIndex).tsFields.tsSuggestedId);
      if Result = 0 then
        Result := CompareValue(aTranSeqNo, LinkList.Tran_Suggested_Link_At(CurrIndex).tsFields.tsTran_Seq_No);
    end;
  end;
begin
  aFoundIndex := -1;

  if aSearchList = tstTranId then
    LinkList := aBankAccount.baTran_Suggested_Link_List
  else
    LinkList := aBankAccount.baSuggested_Tran_Link_List;

  CurrValue := (LinkList.ItemCount-1)/2;
  CurrIndex := round(CurrValue);
  DiffValue := CurrValue/2;
  repeat
    CompareInt := Compare();

    if CompareInt = 0 then
      break;

    OldIndex := CurrIndex;
    if CompareInt = -1 then
      CurrValue := CurrValue - DiffValue
    else if CompareInt = 1 then
      CurrValue := CurrValue + DiffValue;
    CurrIndex := round(CurrValue);

    DiffValue := DiffValue/2;

    if (CompareInt <> 0) and (CurrIndex = OldIndex) then
    begin
      CurrIndex := CurrIndex + CompareInt;
      if (CurrIndex > -1) and (CurrIndex < LinkList.ItemCount) then
        CompareInt := Compare();
      OldIndex := CurrIndex;
    end;
  until ((CompareInt = 0) or (CurrIndex = OldIndex));

  Result := (CompareInt = 0);

  if Result then
    aFoundIndex := CurrIndex;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindLinkId(aBankAccount: TBank_Account; aSearchId: integer; aSearchType : TTranSuggSortType; var aFoundIndex: integer): boolean;
var
  CurrIndex : integer;
  OldIndex : integer;
  CurrValue : double;
  DiffValue : double;
  CompareInt : integer;
  LinkList : TTran_Suggested_Link_List;

  //----------------------------------------------------------------------------
  function Compare() : integer;
  begin
    Result := 0;
    if aSearchType = tstTranId then
      Result := CompareValue(aSearchId, LinkList.Tran_Suggested_Link_At(CurrIndex).tsFields.tsTran_Seq_No)
    else
      Result := CompareValue(aSearchId, LinkList.Tran_Suggested_Link_At(CurrIndex).tsFields.tsSuggestedId);
  end;
begin
  aFoundIndex := -1;

  if aSearchType = tstTranId then
    LinkList := aBankAccount.baTran_Suggested_Link_List
  else
    LinkList := aBankAccount.baSuggested_Tran_Link_List;

  CurrValue := (LinkList.ItemCount-1)/2;
  CurrIndex := round(CurrValue);
  DiffValue := CurrValue/2;
  repeat
    CompareInt := Compare();

    if CompareInt = 0 then
      break;

    OldIndex := CurrIndex;
    if CompareInt = -1 then
      CurrValue := CurrValue - DiffValue
    else if CompareInt = 1 then
      CurrValue := CurrValue + DiffValue;
    CurrIndex := round(CurrValue);

    DiffValue := DiffValue/2;

    if not (CompareInt = 0) and (CurrIndex = OldIndex) then
    begin
      CurrIndex := CurrIndex + CompareInt;
      if (CurrIndex > -1) and (CurrIndex < LinkList.ItemCount) then
        CompareInt := Compare();
      OldIndex := CurrIndex;
    end;
  until ((CompareInt = 0) or (CurrIndex = OldIndex));

  Result := (CompareInt = 0);

  if Result then
    aFoundIndex := CurrIndex;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindTransUsingEffDateAndSeqNo(aBankAccount: TBank_Account; aEffDate, aTranSeqNo : integer; var aTran : pTransaction_Rec) : boolean;
var
  CurrIndex : integer;
  OldIndex : integer;
  CurrValue : double;
  DiffValue : double;
  CompareInt : integer;

  //----------------------------------------------------------------------------
  function Compare() : integer;
  begin
    if aEffDate < aBankAccount.baTransaction_List.Transaction_At(CurrIndex)^.txDate_Effective then result := -1 else
    if aEffDate > aBankAccount.baTransaction_List.Transaction_At(CurrIndex)^.txDate_Effective then result := 1  else
    if aTranSeqNo < aBankAccount.baTransaction_List.Transaction_At(CurrIndex)^.txSequence_No  then result := -1 else
    if aTranSeqNo > aBankAccount.baTransaction_List.Transaction_At(CurrIndex)^.txSequence_No  then result := 1  else
    result := 0;
  end;
begin
  Result := false;
  aTran := nil;

  CurrValue := (aBankAccount.baTransaction_List.ItemCount-1)/2;
  CurrIndex := round(CurrValue);
  DiffValue := CurrValue/2;
  repeat
    CompareInt := Compare();

    if CompareInt = 0 then
      break;

    OldIndex := CurrIndex;
    if CompareInt = -1 then
      CurrValue := CurrValue - DiffValue
    else if CompareInt = 1 then
      CurrValue := CurrValue + DiffValue;
    CurrIndex := round(CurrValue);

    DiffValue := DiffValue/2;

    if not (CompareInt = 0) and (CurrIndex = OldIndex) then
    begin
      CurrIndex := CurrIndex + CompareInt;
      if (CurrIndex > -1) and (CurrIndex < aBankAccount.baTransaction_List.ItemCount) then
        CompareInt := Compare();
      OldIndex := CurrIndex;
    end;
  until ((CompareInt = 0) or (OldIndex = CurrIndex));

  Result := (CompareInt = 0);

  if Result then
    aTran := aBankAccount.baTransaction_List.Transaction_At(CurrIndex);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindSuggestedItem(aBankAccount : TBank_Account; aSuggId : integer; var aFoundIndex : integer; var aFoundItem : pSuggested_Mem_Rec): boolean;
var
  CurrIndex : integer;
  OldIndex : integer;
  CurrValue : double;
  DiffValue : double;
  CompareInt : integer;

  //----------------------------------------------------------------------------
  function Compare() : integer;
  begin
    Result := CompareValue(aSuggId, aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(CurrIndex).smFields.smId);
  end;
begin
  Result := false;
  aFoundItem := nil;

  CurrValue := (aBankAccount.baSuggested_Mem_List.ItemCount-1)/2;
  CurrIndex := round(CurrValue);
  DiffValue := CurrValue/2;
  repeat
    CompareInt := Compare();

    if CompareInt = 0 then
      break;

    OldIndex := CurrIndex;
    if CompareInt = -1 then
      CurrValue := CurrValue - DiffValue
    else if CompareInt = 1 then
      CurrValue := CurrValue + DiffValue;
    CurrIndex := round(CurrValue);

    DiffValue := DiffValue/2;

    if not (CompareInt = 0) and (CurrIndex = OldIndex) then
    begin
      CurrIndex := CurrIndex + CompareInt;
      if (CurrIndex > -1) and (CurrIndex < aBankAccount.baSuggested_Mem_List.ItemCount) then
        CompareInt := Compare();
      OldIndex := CurrIndex;
    end;
  until ((CompareInt = 0) or (OldIndex = CurrIndex));

  Result := (CompareInt = 0);

  if Result then
  begin
    aFoundIndex := CurrIndex;
    aFoundItem := aBankAccount.baSuggested_Mem_List.GetAs_pRec(aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(aFoundIndex));
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.FindOtherSuggIdsUsingFoundId(aBankAccount: TBank_Account; aTranSeqNo, aFoundIndex: integer; var aFoundIds, aFoundIndexes: TArrInt);
var
  SearchIndex : integer;
  CompareInt : integer;

  //----------------------------------------------------------------------------
  procedure AddFound(aId, aIndex : integer);
  begin
    setlength(aFoundIds, length(aFoundIds)+1);
    setlength(aFoundIndexes, length(aFoundIndexes)+1);
    aFoundIds[high(aFoundIds)] := aId;
    aFoundIndexes[high(aFoundIndexes)] := aIndex;
  end;

begin
  // Search up for Top of the list, the reason  for this is to get id's going down in order
  SearchIndex := aFoundIndex;
  inc(SearchIndex);

  if SearchIndex < aBankAccount.baTran_Suggested_Link_List.ItemCount then
  begin
    CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No);
    while (SearchIndex < aBankAccount.baTran_Suggested_Link_List.ItemCount) and
          (CompareInt = 0) do
    begin
      inc(SearchIndex);
      if SearchIndex < aBankAccount.baTran_Suggested_Link_List.ItemCount then
        CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No)
      else
        CompareInt := 1;
    end;
  end;

  // Search down while adding
  dec(SearchIndex);

  if SearchIndex > -1 then
  begin
    CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No);
    while (SearchIndex > -1) and
          (CompareInt = 0) do
    begin
      AddFound(aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsSuggestedId, SearchIndex);

      dec(SearchIndex);
      if SearchIndex > -1 then
        CompareInt := CompareValue(aTranSeqNo, aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No)
      else
        CompareInt := -1;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindSuggIdsUsingTranId(aBankAccount : TBank_Account; aTranSeqNo : integer; var aFoundIds : TArrInt): boolean;
var
  FoundIndex : integer;
  FoundIndexes: TArrInt;
begin
  Result := false;
  if aBankAccount.baTran_Suggested_Link_List.ItemCount = 0 then
    Exit;

  if FindLinkId(aBankAccount, aTranSeqNo, tstTranId, FoundIndex) then
  begin
    FindOtherSuggIdsUsingFoundId(aBankAccount, aTranSeqNo, FoundIndex, aFoundIds, FoundIndexes);
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.FindOtherTranIdsUsingFoundId(aBankAccount: TBank_Account; aSuggId, aFoundIndex: integer; var aFoundIds, aFoundIndexes: TArrInt);
var
  SearchIndex : integer;
  CompareInt : integer;

  //----------------------------------------------------------------------------
  procedure AddFound(aId, aIndex : integer);
  begin
    setlength(aFoundIds, length(aFoundIds)+1);
    setlength(aFoundIndexes, length(aFoundIndexes)+1);
    aFoundIds[high(aFoundIds)] := aId;
    aFoundIndexes[high(aFoundIndexes)] := aIndex;
  end;

begin
  // Search up for Top of the list, the reason  for this is to get id's going down in order
  SearchIndex := aFoundIndex;
  inc(SearchIndex);

  if SearchIndex < aBankAccount.baTran_Suggested_Link_List.ItemCount then
  begin
    CompareInt := CompareValue(aSuggId, aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsSuggestedId);
    while (SearchIndex < aBankAccount.baTran_Suggested_Link_List.ItemCount) and
          (CompareInt = 0) do
    begin
      inc(SearchIndex);
      if SearchIndex < aBankAccount.baSuggested_Tran_Link_List.ItemCount then
        CompareInt := CompareValue(aSuggId, aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsSuggestedId)
      else
        CompareInt := 1;
    end;
  end;

  // Search down while adding
  dec(SearchIndex);

  if SearchIndex > -1 then
  begin
    CompareInt := CompareValue(aSuggId, aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsSuggestedId);
    while (SearchIndex > -1) and
          (CompareInt = 0) do
    begin
      AddFound(aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsTran_Seq_No, SearchIndex);

      dec(SearchIndex);
      if SearchIndex > -1 then
        CompareInt := CompareValue(aSuggId, aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(SearchIndex).tsFields.tsSuggestedId)
      else
        CompareInt := -1;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindTranIdsUsingSuggId(aBankAccount : TBank_Account; aSuggId : integer; var aFoundIds : TArrInt): boolean;
var
  FoundIndex : integer;
  FoundIndexes: TArrInt;
begin
  Result := false;
  if aBankAccount.baTran_Suggested_Link_List.ItemCount = 0 then
    Exit;

  if FindLinkId(aBankAccount, aSuggId, tstSuggId, FoundIndex) then
  begin
    FindOtherTranIdsUsingFoundId(aBankAccount, aSuggId, FoundIndex, aFoundIds, FoundIndexes);
    Result := true;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetSuggestedMemsCount(aBankAccount : TBank_Account) : integer;
var
  SuggestedMemIndex : integer;
begin
  Result := 0;

  if not NoMoreRecord then
    Exit;

  StopMemScan();
  try
    for SuggestedMemIndex := 0 to aBankAccount.baSuggested_Mem_List.ItemCount - 1 do
    begin
      if aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex).smFields.smManual_Count > 2 then
      begin
        if not IsSuggestionUsedByMem(aBankAccount,
                                     aBankAccount.baSuggested_Mem_List.GetAs_pRec(
                                     aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex))) then
          inc(Result);
      end;
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetSuggestionMatchText(const aMatchPhrase: string; aStart, aEnd: boolean): string;
begin
  result := '';

  if aStart then
    result := result + '*';

  result := result + aMatchPhrase;

  if aEnd then
    result := result + '*';
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetSuggestedMems(aBankAccount: TBank_Account): TSuggestedMemsArr;
var
  SuggestedMemIndex : integer;
  CurrIndex : integer;
  SuggId : integer;
  FoundIndex : integer;
  FoundEffDate : integer;
  FoundTranSeqNo : integer;
  FoundTran : pTransaction_Rec;
begin
  Result := nil;

  StopMemScan();
  try
    for SuggestedMemIndex := 0 to aBankAccount.baSuggested_Mem_List.ItemCount - 1 do
    begin
      if aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex).smFields.smManual_Count > 2 then
      begin
        if not IsSuggestionUsedByMem(aBankAccount,
                                     aBankAccount.baSuggested_Mem_List.GetAs_pRec(
                                     aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex))) then
        begin
          SuggId := aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex).smFields.smId;
          if FindLinkId(aBankAccount, SuggId, tstSuggId, FoundIndex) then
          begin
            FoundEffDate := aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(FoundIndex).tsFields.tsDate_Effective;
            FoundTranSeqNo := aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(FoundIndex).tsFields.tsTran_Seq_No;

            if FindTransUsingEffDateAndSeqNo(aBankAccount, FoundEffDate, FoundTranSeqNo, FoundTran) then
            begin
              CurrIndex := length(Result);
              setlength(Result, CurrIndex + 1);

              Result[CurrIndex].smId := aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex).smFields.smId;
              Result[CurrIndex].smType := FoundTran^.txType;
              Result[CurrIndex].smMatchedPhrase := GetSuggestionMatchText(
                                                     aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex).smFields.smMatched_Phrase,
                                                     aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex).smFields.smStart_Data,
                                                     aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex).smFields.smEnd_Data);
              Result[CurrIndex].smAccount := FoundTran^.txAccount;
              Result[CurrIndex].smTotalCount := aBankAccount.baSuggested_Mem_List.Suggested_Mem_At(SuggestedMemIndex).smFields.smTotal_Count;
            end;
          end;
        end;
      end;
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.DetermineStatus(aBankAccount : TBank_Account): string;
const
  MSG_NO_MEMORISATIONS = 'There are no Suggested Memorisations at this time.';
  MSG_DISABLED_MEMORISATIONS = 'Suggested Memorisations have been disabled, please contact Support.';
  MSG_STILL_PROCESSING = ' is still scanning for suggestions, please try again later.';
var
  AccountHasRecMems : boolean;
begin
  result := '';

  if fMainState = mtsNoScan then
  begin
    Result := MSG_DISABLED_MEMORISATIONS;
    Exit;
  end;

  if fNoMoreRecord then
  begin
    AccountHasRecMems := (GetSuggestedMemsCount(aBankAccount) > 0);

    if not AccountHasRecMems then
      result := MSG_NO_MEMORISATIONS;
  end
  else
  begin
    if Assigned(AdminSystem) then
      result := BRAND_PRACTICE_SHORT_NAME + MSG_STILL_PROCESSING
    else
      result := BRAND_BOOKS_SHORT_NAME + MSG_STILL_PROCESSING;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.InsertNewLink(aBankAccount : TBank_Account; aTranState : byte; aTrans : pTransaction_Rec; aSuggId : integer; aSuggestion : pSuggested_Mem_Rec);
var
  NewSuggLink : TTran_Suggested_Link;
begin
  // Current Trans already added to Suggestion so add search trans to suggestion
  NewSuggLink := TTran_Suggested_Link.Create();
  NewSuggLink.tsFields.tsDate_Effective := aTrans^.txDate_Effective;
  NewSuggLink.tsFields.tsTran_Seq_No := aTrans^.txSequence_No;
  NewSuggLink.tsFields.tsSuggestedId := aSuggId;
  aBankAccount.baTran_Suggested_Link_List.Insert(NewSuggLink);

  NewSuggLink := TTran_Suggested_Link.Create();
  NewSuggLink.tsFields.tsDate_Effective := aTrans^.txDate_Effective;
  NewSuggLink.tsFields.tsTran_Seq_No := aTrans^.txSequence_No;
  NewSuggLink.tsFields.tsSuggestedId := aSuggId;
  aBankAccount.baSuggested_Tran_Link_List.Insert(NewSuggLink);

  inc(aSuggestion^.smTotal_Count);

  if aTranState = tssManualScanned then
    inc(aSuggestion^.smManual_Count)
  else
    inc(aSuggestion^.smUncoded_Count);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.IsMemorisation(aMemorisations: TMemorisations_List; aType: byte; const aMatchPhrase: string): boolean;
var
  MemIndex : integer;
begin
  result := false;
  for MemIndex := 0 to aMemorisations.ItemCount-1 do
  begin
    if (aType = aMemorisations.Memorisation_At(MemIndex).mdFields.mdType) and
       (aMatchPhrase = aMemorisations.Memorisation_At(MemIndex).mdFields.mdStatement_Details) then
    begin
      result := true;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.IsMasterMemorisation(aType: byte; const aMatchPhrase, aBankPrefix: string): boolean;
var
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  Memorisations: TMemorisations_List;
begin
  result := false;

  // Books?
  if not assigned(AdminSystem) then
    exit;

  // No memorisations for bank prefix?
  SystemMemorisation :=
    AdminSystem.SystemMemorisationList.FindPrefix(aBankPrefix);
  if not assigned(SystemMemorisation) then
    exit;

  // No memorisation matches?
  Memorisations := TMemorisations_List(SystemMemorisation.smMemorisations);
  if not IsMemorisation(Memorisations, aType, aMatchPhrase) then
    exit;

  result := true;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.IsSuggestionUsedByMem(aBankAccount: TBank_Account; aSuggestion: pSuggested_Mem_Rec): boolean;
var
  BankPrefix : string;
  FoundIndex : integer;
  DateEffective : integer;
  TranSeqNo : integer;
  Tran : pTransaction_Rec;
  TranType : byte;
  MatchText : string;
begin
  result := false;

  if FindLinkId(aBankAccount, aSuggestion.smId, tstSuggId, FoundIndex) then
  begin
    DateEffective := aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(FoundIndex).tsFields.tsDate_Effective;
    TranSeqNo := aBankAccount.baSuggested_Tran_Link_List.Tran_Suggested_Link_At(FoundIndex).tsFields.tsTran_Seq_No;

    if FindTransUsingEffDateAndSeqNo(aBankAccount, DateEffective, TranSeqNo, Tran) then
    begin
      TranType := Tran^.txType;
      MatchText := GetSuggestionMatchText(aSuggestion^.smMatched_Phrase, aSuggestion^.smStart_Data, aSuggestion^.smEnd_Data);

      if IsMemorisation(aBankAccount.baMemorisations_List, TranType, MatchText) then
      begin
        result := true;
        exit;
      end;

      BankPrefix := GetBankPrefix(aBankAccount.baFields.baBank_Account_Number);
      if IsMasterMemorisation(TranType, MatchText, BankPrefix) then
      begin
        result := true;
        exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SearchFoundMatch(aStartData: boolean; var aLCSstr : string; aEndData: boolean; aBankAccount : TBank_Account; aScanTrans, aMatchedTrans : pTransaction_Rec; var aCurrentTranSuggestions : TArrSuggPointers);
var
  CurrentIndex  : integer;
  FoundSuggIds  : TArrInt;
  FoundTranIds  : TArrInt;
  TranIndex  : integer;
  FoundSuggestion : pSuggested_Mem_Rec;
  AddedSuggestion : pSuggested_Mem_Rec;
  NewSuggestion : TSuggested_Mem;
  NewSuggIndex  : integer;
  SuggItemIndex : integer;
  Found : boolean;

  //----------------------------------------------------------------------------
  procedure AddCurrentTranSuggestion(aSuggestion : pSuggested_Mem_Rec);
  begin
    SetLength(aCurrentTranSuggestions, length(aCurrentTranSuggestions)+1);
    aCurrentTranSuggestions[High(aCurrentTranSuggestions)] := aSuggestion;
  end;

begin
  for CurrentIndex := 0 to high(aCurrentTranSuggestions) do
  begin
    if CompareText(aLCSstr, aCurrentTranSuggestions[CurrentIndex]^.smMatched_Phrase) = 0 then
    begin
      FindTranIdsUsingSuggId(aBankAccount, aCurrentTranSuggestions[CurrentIndex]^.smId, FoundTranIds);

      Found := false;
      for TranIndex := 0 to high(FoundTranIds) do
      begin
        if FoundTranIds[TranIndex] = aMatchedTrans^.txSequence_No then
        begin
          found := true;
          break;
        end;
      end;

      if not found then
      begin
        InsertNewLink(aBankAccount, aMatchedTrans^.txSuggested_Mem_State, aMatchedTrans,
                      aCurrentTranSuggestions[CurrentIndex]^.smId, aCurrentTranSuggestions[CurrentIndex]);
      end;

      Exit;
    end;
  end;

  if FindSuggIdsUsingTranId(aBankAccount, aMatchedTrans^.txSequence_No, FoundSuggIds) then
  begin
    for CurrentIndex := 0 to high(FoundSuggIds) do
    begin
      if FindSuggestedItem(aBankAccount, FoundSuggIds[CurrentIndex], SuggItemIndex, FoundSuggestion) then
      begin
        if CompareText(aLCSstr, FoundSuggestion^.smMatched_Phrase) = 0 then
        begin
          // Search Trans already added to Suggestion so add Current Trans
          InsertNewLink(aBankAccount, aScanTrans^.txSuggested_Mem_State, aScanTrans,
                        FoundSuggestion^.smId, FoundSuggestion);

          FoundSuggestion^.smStart_Data := FoundSuggestion^.smStart_Data or aStartData;
          FoundSuggestion^.smEnd_Data   := FoundSuggestion^.smEnd_Data or aEndData;

          AddCurrentTranSuggestion(FoundSuggestion);
          Exit;
        end;
      end;
    end;
  end;

  // if not found add a new suggestion and new link
  NewSuggestion := TSuggested_Mem.Create;
  NewSuggestion.smFields.smMatched_Phrase := aLCSstr;
  NewSuggestion.smFields.smTotal_Count   := 0;
  NewSuggestion.smFields.smManual_Count  := 0;
  NewSuggestion.smFields.smUncoded_Count := 0;
  NewSuggestion.smFields.smStart_Data    := aStartData;
  NewSuggestion.smFields.smEnd_Data      := aEndData;
  NewSuggIndex := aBankAccount.baSuggested_Mem_List.Insert_Suggested_Mem_Rec(NewSuggestion);

  AddedSuggestion := aBankAccount.baSuggested_Mem_List.GetAs_pRec(NewSuggestion);

  AddCurrentTranSuggestion(AddedSuggestion);

  if (aScanTrans^.txCoded_By in ManualCodedBy) then
    InsertNewLink(aBankAccount, tssManualScanned, aScanTrans,
                NewSuggIndex, AddedSuggestion)
  else
    InsertNewLink(aBankAccount, tssUnCodedScaned, aScanTrans,
                NewSuggIndex, AddedSuggestion);

  InsertNewLink(aBankAccount, aMatchedTrans^.txSuggested_Mem_State, aMatchedTrans,
                NewSuggIndex, AddedSuggestion);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.SearchForLongestCommonPhrase(aBankAccount : TBank_Account; aTrans : pTransaction_Rec) : boolean;
var
  TranIndex : integer;
  TranRec : pTransaction_Rec;
  CurrentTranSuggestions : TArrSuggPointers;
  StartData : boolean;
  FoundLCS  : string;
  EndData   : boolean;
  SearchTranDetailsLength : integer;
  MatchTranDetailLength : integer;
begin
  SearchTranDetailsLength := length(aTrans^.txStatement_Details);
  if SearchTranDetailsLength < 3 then
    Exit;

  for TranIndex := aBankAccount.baTransaction_List.ItemCount-1 downto 0 do
  begin
    TranRec := aBankAccount.baTransaction_List.Transaction_At(TranIndex);

    MatchTranDetailLength := length(TranRec^.txStatement_Details);
    if MatchTranDetailLength < 3 then
      Continue;

    if TranRec^.txSuggested_Mem_State in [tssUnScanned, tssExcluded] then
      Continue;

    if aTrans^.txType <> TranRec^.txType then
      Continue;

    if ((TranRec^.txCoded_By in ManualCodedBy) and (aTrans^.txAccount = TranRec^.txAccount)) or
       (TranRec^.txCoded_By = cbNotCoded) then
    begin
      if (SearchTranDetailsLength = MatchTranDetailLength) and
        (CompareText(aTrans^.txStatement_Details, TranRec^.txStatement_Details) = 0) then
      begin
        SearchFoundMatch(false, aTrans^.txStatement_Details, false, aBankAccount, aTrans, TranRec, CurrentTranSuggestions);
      end
      else
      begin
        if FindLCS(Uppercase(aTrans^.txStatement_Details), Uppercase(TranRec^.txStatement_Details), StartData, FoundLCS, EndData) then
          SearchFoundMatch(StartData, FoundLCS, EndData, aBankAccount, aTrans, TranRec, CurrentTranSuggestions);
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

        if (Assigned(fDoneProcessingEvent)) and
           (fNoMoreRecord = false) and
           (fTempNoMoreRecord = true) then
        begin
          fNoMoreRecord := fTempNoMoreRecord;
          fDoneProcessingEvent();
        end
        else
          fNoMoreRecord := fTempNoMoreRecord;

        ScannedOnce := true;

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

    if not (Trans^.txSuggested_Mem_State in tssScannedAndExluded) then
      ProcessTransaction(BankAccount, Trans);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessTransaction(aBankAccount : TBank_Account; aTrans : pTransaction_Rec);
begin
  if MainState = mtsNoScan then
    Exit;

  SearchForLongestCommonPhrase(aBankAccount, aTrans);

  if (aTrans^.txCoded_By in ManualCodedBy) then
    SetSuggestedTransactionState(aBankAccount, aTrans, tssManualScanned)
  else
    SetSuggestedTransactionState(aBankAccount, aTrans, tssUnCodedScaned);
end;

//------------------------------------------------------------------------------
constructor TSuggestedMems.Create;
begin
  fScanTimer := TTimer.Create(nil);
  fScanTimer.Enabled  := false;
  fScanTimer.Interval := 150;
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
procedure TSuggestedMems.DeleteSuggestionAndLinks(aBankAccount: TBank_Account; aSuggId: integer);
var
  FoundTranListIndex   : integer;
  FoundSuggListIndex   : integer;
  FoundSuggListIndexes : TArrInt;
  FoundTranIds         : TArrInt;
  TranIndex            : integer;
  FoundSuggestion : pSuggested_Mem_Rec;
  FoundSuggestionIndex : integer;
begin
  if FindLinkId(aBankAccount, aSuggId, tstSuggId, FoundSuggListIndex) then
  begin
    FindOtherTranIdsUsingFoundId(aBankAccount, aSuggId, FoundSuggListIndex, FoundTranIds, FoundSuggListIndexes);

    for TranIndex := 0 to high(FoundTranIds) do
    begin
      if FindLinkIndexUsingBothIds(aBankAccount, aSuggId, FoundTranIds[TranIndex], tstTranId, FoundTranListIndex) then
        aBankAccount.baTran_Suggested_Link_List.AtFree(FoundTranListIndex);
    end;

    for TranIndex := 0 to high(FoundSuggListIndexes) do
      aBankAccount.baSuggested_Tran_Link_List.AtFree(FoundSuggListIndexes[TranIndex]);
  end;

  if FindSuggestedItem(aBankAccount, aSuggId, FoundSuggestionIndex, FoundSuggestion) then
    aBankAccount.baSuggested_Mem_List.AtFree(FoundSuggestionIndex);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.DeleteLinksAndSuggestions(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aOldTranState : byte);
var
  SuggIdIndex : integer;
  TranIdIndex : integer;
  FoundSuggIds : TArrInt;
  FoundTranIds : TArrInt;
  FoundLinkSuggIndexes : TArrInt;
  FoundLinkTranIndexes : TArrInt;
  FoundSuggestion : pSuggested_Mem_Rec;
  FoundSuggestionIndex : integer;
  TranSeqNo : integer;
  FoundTranListIndex : integer;
  FoundSuggListIndex : integer;
  SuggId : integer;
  TranId : integer;
  TranEffDate : integer;
  TranToDel : pTransaction_Rec;
begin
  TranSeqNo := aTrans^.txSequence_No;

  if FindLinkId(aBankAccount, TranSeqNo, tstTranId, FoundTranListIndex) then
  begin
    FindOtherSuggIdsUsingFoundId(aBankAccount, TranSeqNo, FoundTranListIndex, FoundSuggIds, FoundLinkSuggIndexes);

    for SuggIdIndex := 0 to high(FoundSuggIds) do
    begin
      if FindSuggestedItem(aBankAccount, FoundSuggIds[SuggIdIndex], FoundSuggestionIndex, FoundSuggestion) then
      begin
        if FoundSuggestion.smTotal_Count = 2 then
        begin
          DeleteSuggestionAndLinks(aBankAccount, FoundSuggIds[SuggIdIndex]);
        end
        else
        begin
          // Delete Current Transaction Link for this Suggestion
          SuggId := FoundSuggestion.smId;

          if FindLinkIndexUsingBothIds(aBankAccount, SuggId, TranSeqNo, tstSuggId, FoundSuggListIndex) then
            aBankAccount.baSuggested_Tran_Link_List.AtFree(FoundSuggListIndex);

          if FindLinkIndexUsingBothIds(aBankAccount, SuggId, TranSeqNo, tstTranId, FoundTranListIndex) then
            aBankAccount.baTran_Suggested_Link_List.AtFree(FoundTranListIndex);

          if aOldTranState = tssManualScanned then
            dec(FoundSuggestion^.smManual_Count)
          else if aOldTranState = tssUnCodedScaned then
            dec(FoundSuggestion^.smUncoded_Count);

          dec(FoundSuggestion^.smTotal_Count);
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetSuggestedTransactionState(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aState : byte);
var
  OldState : byte;
begin
  if MainState = mtsNoScan then
    Exit;

  OldState := aTrans^.txSuggested_Mem_State;
  if OldState = aState then
    Exit;

  if aBankAccount.IsAJournalAccount then
  begin
    aTrans^.txSuggested_Mem_State := tssExcluded;
    Exit;
  end;

  StopMemScan();
  try
    if (aTrans^.txCoded_By in ManualCodedBy) or (aTrans^.txCoded_By = cbNotCoded) then
      aTrans^.txSuggested_Mem_State := aState
    else
      aTrans^.txSuggested_Mem_State := tssExcluded;

    if (aTrans^.txSuggested_Mem_State = tssUnScanned) then
    begin
      if (OldState in tssScanned) then
        DeleteLinksAndSuggestions(aBankAccount, aTrans, OldState);

      inc(aBankAccount.baFields.baSuggested_UnProcessed_Count);
    end;

    if not (OldState in tssScanned) and
      (aTrans^.txSuggested_Mem_State in tssScanned) then
    begin
      if aBankAccount.baFields.baSuggested_UnProcessed_Count > 0 then
        dec(aBankAccount.baFields.baSuggested_UnProcessed_Count);
    end;

  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateAccountWithTransDelete(aBankAccount: TBank_Account);
begin
  if MainState = mtsNoScan then
    Exit;

  if aBankAccount.IsAJournalAccount then
    Exit;

  if aBankAccount.baFields.baSuggested_UnProcessed_Count > 0 then
    Dec(aBankAccount.baFields.baSuggested_UnProcessed_Count);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateAccountWithTransInsert(aBankAccount: TBank_Account; aTrans: pTransaction_Rec; aNew : boolean);
begin
  if MainState = mtsNoScan then
    Exit;

  if aBankAccount.IsAJournalAccount then
  begin
    aTrans^.txSuggested_Mem_State := tssExcluded;
    Exit;
  end;

  if (aNew) or (MEMSINI_SupportOptions = meiResetMems) then
  begin
    if (aTrans^.txCoded_By in ManualCodedBy) or (aTrans^.txCoded_By = cbNotCoded) then
      aTrans^.txSuggested_Mem_State := tssUnScanned
    else
      aTrans^.txSuggested_Mem_State := tssExcluded;
  end;

  if (aTrans^.txSuggested_Mem_State = tssUnScanned) or (aTrans^.txSuggested_Mem_State = tssExcluded) then
  begin
    if (aTrans^.txCoded_By in ManualCodedBy) or (aTrans^.txCoded_By = cbNotCoded) then
      aTrans^.txSuggested_Mem_State := tssUnScanned
    else
      aTrans^.txSuggested_Mem_State := tssExcluded;

    if aTrans^.txSuggested_Mem_State = tssUnScanned then
      inc(aBankAccount.baFields.baSuggested_UnProcessed_Count);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetMainState();
begin
  case MEMSINI_SupportOptions of
    meiDisableSuggestedMemsAll : fMainState := mtsNoScan;
    meiResetMems               : fMainState := mtsScan;
    meiDisableSuggestedMemsv2  : fMainState := mtsScan;
    meiFullfunctionality       : fMainState := mtsScan;
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

        if (TranRec^.txCoded_By in ManualCodedBy) or (TranRec^.txCoded_By = cbNotCoded) then
        begin
          TranRec^.txSuggested_Mem_State := tssUnScanned;
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
  if MainState = mtsNoScan then
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
  if MainState = mtsNoScan then
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
