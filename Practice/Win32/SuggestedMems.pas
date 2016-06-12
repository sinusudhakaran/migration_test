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
  chList32,
  trxList32,
  SuggMemSortedList,
  MemTranSortedList,
  MultiCast,
  Classes;

const
  mtsNoScan      = 0; mtsMin = 0;
  mtsMems2NoScan = 1;
  mtsExcluded    = 2;
  mtsScan        = 3; mtsMax = 3;

  tssUnScanned        = 0; tssMin = 0;
  tssScanned          = 1;
  tssCreateSuggestion = 2;
  tssRemoveSuggestion = 3;
  tssForCount         = 4; tssMax = 3;

  TRAN_SUGG_NOT_FOUND = -1;
  TRAN_NO_SUGG = -2;

  MSG_NO_MEMORISATIONS = 'There are no Suggested Memorisations at this time.';
  MSG_DISABLED_MEMORISATIONS = 'Suggested Memorisations have been disabled. ' + #13 +
                               'Please contact Support if you wish to enable this.';
  MSG_STILL_PROCESSING = ' is still scanning for suggestions, please try again later.';
  PARTIAL_MATCH_MIN_TRANS = 150;

type
  TFoundCreate = (fcFound, fcCreated);
  TSuggMemStatus = (ssFound , ssNoFound, ssDisabled, ssProcessing );

  //----------------------------------------------------------------------------
  TArrInt = Array of integer;
  TArrSuggPointers = Array of pSuggested_Mem_Rec;

  //----------------------------------------------------------------------------
  TSuggestedMems = class(TObject)
  private
    fMainState : Byte;
    fScanTimer : TTimer;
    fMemScanRefCount : integer;

    fNewAccount : boolean;
    fAccountIndex : integer;
    fTranIndex : integer;
    fTranType : byte;
    fTranTypeStartIndex : integer;

    fNoMoreRecord : boolean;
    fTempNoMoreRecord : boolean;

    fDoneProcessingEvent : TMultiCastNotify;
  protected
    procedure DoScanTimer(Sender: TObject);

    procedure LogAllSuggestedMemsForAccount(const aBankAccount : TBank_Account);
    procedure LogAllSuggestedMemsForClient(const aClient: TClientObj);

    procedure LogDoneProcessing(aNoMoreRecords : Boolean);

    function GetSuggestionMatchText(const aMatchPhrase : string; aStart, aEnd : boolean) : string;

    procedure DeleteSuggestionAndLinks(const aBankAccount : TBank_Account; aSuggestionId : integer);
    procedure DeleteLinksAndSuggestions(const aBankAccount : TBank_Account; const aTrans : pTran_Suggested_Index_Rec; aOldTranState : byte);
    function UpdateSuggestionAccountAndLinks(const aBankAccount : TBank_Account; const aTrans : pTran_Suggested_Index_Rec; aOldState : byte) : boolean;

    function FindPhraseOrCreate(const aBankAccount : TBank_Account; const aPhrase : string; var aPhraseid : integer) : TFoundCreate;
    function FindSuggestionUsingPhraseIdAndType(const aBankAccount: TBank_Account; aTypeId: byte; aPhraseId: integer; var aSuggested_Mem_Rec: pSuggested_Mem_Rec): boolean;
    procedure CreateSuggestion(const aBankAccount : TBank_Account; aTypeId: byte; aPhraseId: integer; Start_Data, End_Data : boolean; var aSuggested_Mem_Rec: pSuggested_Mem_Rec);
    function FindAccountOrCreate(aBankAccount : TBank_Account; aAccount : string; var aAccountid : integer) : TFoundCreate;
    function FindSuggestionAccountLinkOrCreate(const aBankAccount: TBank_Account; aSuggestionId, aAccountId: integer; const aAccount : string; var aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec): TFoundCreate;
    procedure CreateSuggestionAccountLink(const aBankAccount: TBank_Account; aSuggestionId, aAccountId: integer; const aAccount : string; var aSuggested_Account_Link_Rec : pSuggested_Account_Link_Rec);
    function FindTranSuggestionLink(const aBankAccount: TBank_Account; aTranSeqNo : integer; aSuggestionId : integer) : boolean;
    procedure CreateTranSuggestionLink(const aBankAccount: TBank_Account; const aTrans : pTran_Suggested_Index_Rec; const aSuggested_Mem_Rec: pSuggested_Mem_Rec; const aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec; aTranNewState : byte);

    procedure SearchFoundMatch(aStartData: boolean; var aMatchedPhrase : string; aEndData: boolean; const aBankAccount : TBank_Account; const aScanTrans, aMatchedTrans : pTran_Suggested_Index_Rec; aTranNewState : byte);

    function IsMemorisation(aMemorisations: TMemorisations_List; aType : byte; const aMatchPhrase : string): boolean;
    function IsMasterMemorisation(aType: byte; const aMatchPhrase, aBankPrefix: string): boolean;
    function IsSuggestionUsedByMem(aBankAccount : TBank_Account; aSuggestion : pSuggested_Mem_Rec): boolean;

    function IsSuggestionInIgnoreList(const aBankAccount : TBank_Account; const aSuggestion : pSuggested_Mem_Rec): boolean;

    function GetScannedState(aCoded_By : byte) : byte;

    procedure MemScan();
    procedure ProcessTransaction(const aBankAccount : TBank_Account; const aTrans : pTran_Suggested_Index_Rec; aRunMems2 : boolean);
    procedure SearchForMatchedPhrase(const aBankAccount : TBank_Account; const aSearchTrans : pTran_Suggested_Index_Rec; aTranNewState : byte; aRunMems2 : boolean);

    function GetSuggestionUsedInfo(const aBankAccount: TBank_Account; const aSuggestion: pSuggested_Mem_Rec; aChart : TChart; var aSuggMemItem : TSuggMemSortedListRec) : boolean;
    function FindSuggestionUsedByTransaction(const aBankAccount: TBank_Account; const aTrans : pTransaction_Rec; const aChart : TChart; var aSuggMemItem : TSuggMemSortedListRec) : boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function IsSuggMemsRunning() : boolean;

    procedure UpdateSuggestion(const aBankAccount: TBank_Account; aSuggestionId : integer; aIsHidden : boolean);
    function GetSuggestionUsedByTransaction(const aBankAccount: TBank_Account; const aTrans : pTransaction_Rec; const aChart : TChart; var aSuggMemItem : TSuggMemSortedListRec) : boolean;
    function GetTransactionListMatchingMemPhrase(const aBankAccount: TBank_Account; const aTempMem : TMemorisation; var aMemTranSortedList : TMemTranSortedList; aIdDissection : boolean ) : boolean;
    function IsAccountUsedByMem(const aBankAccount: TBank_Account; const aTempMem : TMemorisation) : boolean;

    procedure SetSuggestedTransactionState(const aBankAccount : TBank_Account; const aTrans : pTransaction_Rec; aState : byte; aAccountChanged : boolean = false; aIsBulk : boolean = false); Overload;
    procedure SetSuggestedTransactionState(const aBankAccount : TBank_Account; const aTrans : pTran_Suggested_Index_Rec; aState : byte; aAccountChanged : boolean = false; aIsBulk : boolean = false); Overload;
    procedure UpdateAccountWithTransDelete(const aBankAccount : TBank_Account; const aTrans : pTransaction_Rec);
    procedure UpdateAccountWithTransInsert(const aBankAccount : TBank_Account; const aTrans : pTran_Suggested_Index_Rec; aNew : boolean);
    procedure DoProcessingComplete();

    procedure SetMainState();
    Procedure NewClientMainState();
    procedure ResetAccount(const aBankAccount: TBank_Account);
    procedure ResetAll(const aClient: TClientObj);
    procedure ResetLogging(const aClient: TClientObj);

    procedure StartMemScan(aForceStart : boolean = false);
    procedure StopMemScan(aForceStop : boolean = false);

    function GetSuggestedMemsCount(const aBankAccount : TBank_Account; const aChart : TChart; aIncludeHidden : boolean = true) : integer;
    procedure GetSuggestedMems(const aBankAccount : TBank_Account; const aChart : TChart; var aSuggMemSortedList : TSuggMemSortedList);

    function GetStatus(const aBankAccount : TBank_Account; const aChart : TChart) : TSuggMemStatus;
    function DetermineStatus(const aBankAccount : TBank_Account; const aChart : TChart): string;

    function DoCreateNewMemorisation(const aBankAccount : TBank_Account; const aChart : TChart; aSuggId : integer) : boolean;
    procedure RunMemScan();

    property MainState : byte read fMainState write fMainState;
    property NoMoreRecord : boolean read fNoMoreRecord;
    property DoneProcessingEvent : TMultiCastNotify read fDoneProcessingEvent write fDoneProcessingEvent;
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
  spObj32,
  saObj32,
  slObj32,
  DateUtils,
  Math,
  lcs2,
  SYDEFS,
  mxFiles32,
  stDate,
  BKMLIO,
  MemoriseDlg,
  Autocode32,
  mxUtils,
  UsageUtils,
  LogUtil;

const
  UnitName = 'SuggestedMems';
  UnitNameExt = 'SuggestedMemsExt';
  ManualCodedBy = [cbManual, cbECodingManual];
  USAGE_ADDED_MEM_FROM_SUGGESTION_COUNT = 'SuggestedMemsNewMemFromPopupCount';

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
procedure TSuggestedMems.LogAllSuggestedMemsForAccount(const aBankAccount: TBank_Account);
var
  AccIndex : integer;
  AccountIndex : integer;
  SuggIndex : integer;
  SuggestedId : integer;
  FoundSuggLowIndex : integer;
  FoundSuggHighIndex : integer;
  PhraseIndex : integer;
  Phrase : string;
begin
  LogUtil.LogMsg(lmDebug, UnitName, 'MemScan, BankAccount - ' + aBankAccount.baFields.baBank_Account_Number);
  for SuggIndex := 0 to aBankAccount.baSuggested_Mem_List.ItemCount-1 do
  begin
    if aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smHas_Changed then
    begin
      SuggestedId := aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smId;

      aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smHas_Changed := false;

      if aBankAccount.baSuggested_Phrase_List.SearchUsingPhraseId(aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smPhraseId, PhraseIndex) then
        Phrase := aBankAccount.baSuggested_Phrase_List.GetPRec(PhraseIndex)^.spPhrase;

      LogUtil.LogMsg(lmDebug, UnitName,
        'Scan, Sug ' + inttostr(aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smId) +
        ', Text - ''' + Phrase + '''');

      if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedId(SuggestedId, FoundSuggLowIndex, FoundSuggHighIndex) then
      begin
        for AccountIndex := FoundSuggLowIndex to FoundSuggHighIndex do
        begin
          if aBankAccount.baSuggested_Account_List.SearchUsingAccountId(aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountIndex)^.slAccountId, AccIndex) then
          begin
            LogUtil.LogMsg(lmDebug, UnitName,'    Code = ' + aBankAccount.baSuggested_Account_List.GetPRec(AccIndex)^.saAccount +
                                             '    Count = ' + inttostr(aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountIndex)^.slCount) +
                                             '    Manual Count = ' + inttostr(aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountIndex)^.slManual_Count));
          end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.LogAllSuggestedMemsForClient(const aClient: TClientObj);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
begin
  if MainState = mtsNoScan then
    Exit;

  StopMemScan();
  try
    for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);
      if BankAccount.IsAJournalAccount then
        Continue;

      LogAllSuggestedMemsForAccount(BankAccount);
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.LogDoneProcessing(aNoMoreRecords : boolean);
begin
  if aNoMoreRecords then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, 'MemScan, No More Records, Client ' + MyClient.clFields.clCode);
    if DebugMeExt then
      LogAllSuggestedMemsForClient(MyClient);
  end
  else
    LogUtil.LogMsg(lmDebug, UnitName, 'MemScan, Found More Records, Client ' + MyClient.clFields.clCode);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetSuggestionUsedInfo(const aBankAccount: TBank_Account; const aSuggestion: pSuggested_Mem_Rec; aChart : TChart; var aSuggMemItem : TSuggMemSortedListRec) : boolean;
var
  SuggestedId : integer;
  LowAccountIndex : integer;
  HighAccountIndex : integer;
  AccountLinkIndex : integer;
  ManualCount : integer;
  TotalCount : integer;
  UncodedCount : integer;
  ManualAccountCount : integer;
  PhraseIndex : integer;
  MatchedPhrase : string;
  SearchAccountIndex : integer;
  SearchAccountId : integer;
  TranLinkIndex : integer;

  AccountId : integer;
  AccountIndex : integer;
  AccountCode : string;
  Account_Rec : pAccount_Rec;
  NoSuggestion : boolean;
  TranIndex : integer;
begin
  Result := false;
  SuggestedId := aSuggestion^.smId;

  if IsSuggestionInIgnoreList(aBankAccount, aSuggestion) then
    Exit;

  ManualCount := 0;
  ManualAccountCount := 0;
  NoSuggestion := false;
  SearchAccountId := -1;
  TotalCount := 0;
  UncodedCount := 0;

  // Search for transactions linked to Suggestion
  if aBankAccount.baTran_Suggested_Link_List.SearchUsingSuggestedId(SuggestedId, LowAccountIndex, HighAccountIndex)  then
  begin
    for TranLinkIndex := LowAccountIndex to HighAccountIndex do
    begin
      if aBankAccount.baTransaction_List.SearchUsingTypeDateandTranSeqNo(
        aSuggestion^.smTypeId ,
        aBankAccount.baTran_Suggested_Link_List.GetIndexPRec(TranLinkIndex)^.Date_Effective,
        aBankAccount.baTran_Suggested_Link_List.GetIndexPRec(TranLinkIndex)^.Tran_Seq_No,
        TranIndex) then
      begin
        if aBankAccount.baTransaction_List.GetIndexPRec(TranIndex)^.tiSuggested_Mem_State = tssRemoveSuggestion then
        begin
          NoSuggestion := true;
          break;
        end;
      end;
    end;
  end;

  if not NoSuggestion then
  begin
    if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedId(SuggestedId, LowAccountIndex, HighAccountIndex) then
    begin
      for AccountLinkIndex := LowAccountIndex to HighAccountIndex do
      begin
        if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slIsDissected then
          NoSuggestion := true;

        TotalCount := TotalCount + aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slCount;

        if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slIsUncoded then
        begin
          UncodedCount := UncodedCount + aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slCount;
          Continue;
        end;

        AccountId := aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slAccountId;
        if aBankAccount.baSuggested_Account_List.SearchUsingAccountId(AccountId, AccountIndex) then
        begin
          AccountCode := aBankAccount.baSuggested_Account_List.GetPRec(AccountIndex)^.saAccount;
          Account_Rec := aChart.FindCode(AccountCode);
          if not Assigned(Account_Rec) or (Account_Rec^.chInactive) then
          begin
            UncodedCount := UncodedCount + aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slCount;
            Continue;
          end;
        end;

        inc(ManualAccountCount);
        ManualCount := ManualCount + aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slManual_Count;
        SearchAccountId := aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slAccountId;
      end;
    end;
  end;

  if (ManualAccountCount = 1) and ((TotalCount - UncodedCount) > 2) and (not NoSuggestion) then
  begin
    if not IsSuggestionUsedByMem(aBankAccount, aSuggestion) then
    begin
      if aBankAccount.baSuggested_Phrase_List.SearchUsingPhraseId(aSuggestion^.smPhraseId, PhraseIndex) then
      begin
        if (SearchAccountId > -1) and
           (aBankAccount.baSuggested_Account_List.SearchUsingAccountId(SearchAccountId, SearchAccountIndex)) then
        begin
          MatchedPhrase := aBankAccount.baSuggested_Phrase_List.GetPRec(PhraseIndex)^.spPhrase;
          MatchedPhrase := GetSuggestionMatchText(MatchedPhrase, aSuggestion^.smStart_Data, aSuggestion^.smEnd_Data);

          aSuggMemItem.Id                 := SuggestedId;
          aSuggMemItem.AccType            := aSuggestion^.smTypeId;
          aSuggMemItem.MatchedPhrase      := MatchedPhrase;
          aSuggMemItem.Account            := aBankAccount.baSuggested_Account_List.GetPRec(SearchAccountIndex)^.saAccount;
          aSuggMemItem.TotalCount         := TotalCount;
          aSuggMemItem.ManualAcountCount  := ManualAccountCount;
          aSuggMemItem.ManualCount        := TotalCount - UncodedCount;
          aSuggMemItem.UnCodedCount       := UncodedCount;
          aSuggMemItem.IsExactMatch       := (not aSuggestion^.smStart_Data) and (not aSuggestion^.smEnd_Data);
          aSuggMemItem.IsHidden           := aSuggestion^.smHidden;

          Result := true;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetTransactionListMatchingMemPhrase(const aBankAccount: TBank_Account; const aTempMem : TMemorisation; var aMemTranSortedList : TMemTranSortedList; aIdDissection : boolean) : boolean;
var
  TranIndex : integer;
  Tran : pTransaction_Rec;
  NewSuggMemSortedItem : TMemTranSortedListRec;
  MemLine : pMemorisation_Line_Rec;
  MemLineIndex : integer;
  CheckMasterMem : boolean;
  MasterMemList : TMemorisations_List;
  SuggestionChanged : boolean;
begin
  Result := false;

  aBankAccount.baMemorisations_List.UpdateLinkedLists;
  if Assigned(AdminSystem) then
    CheckMasterMem := GetMasterMemForAccount(MyClient, aBankAccount, MasterMemList)
  else
    CheckMasterMem := false;

  for TranIndex := 0 to aBankAccount.baTransaction_List.ItemCount-1 do
  begin
    Tran := aBankAccount.baTransaction_List.Transaction_At(TranIndex);

    if Tran^.txLocked then
      Continue;

    If Tran^.txDate_Transferred <> 0 then
      Continue;

    If ( Tran^.txType <> aTempMem.mdFields^.mdType ) and
       not ( aTempMem.mdFields^.mdType = AllEntries ) then
      Continue;

    if Tran^.txDate_Effective < aTempMem.mdFields^.mdFrom_Date then
      Continue;

    if (aTempMem.mdFields^.mdUntil_Date > 0) and
       (Tran^.txDate_Effective > aTempMem.mdFields^.mdUntil_Date) then
      Continue;

    AutoCodeEntry( MyClient, aBankAccount, Tran, SuggestionChanged, CheckMasterMem, MasterMemList);

    if CanMemorise(Tran, aTempMem) then
    begin
      NewSuggMemSortedItem.SequenceNo        := Tran^.txSequence_No;
      NewSuggMemSortedItem.DateEffective     := Tran^.txDate_Effective;
      NewSuggMemSortedItem.Account           := Tran^.txAccount;
      NewSuggMemSortedItem.Amount            := Tran^.txAmount;
      NewSuggMemSortedItem.Statement_Details := Tran^.txStatement_Details;
      NewSuggMemSortedItem.CodedBy           := Tran^.txCoded_By;
      NewSuggMemSortedItem.Reference         := Tran^.txReference;
      NewSuggMemSortedItem.Analysis          := Tran^.txAnalysis;

      if not (Tran^.txFirst_Dissection = nil) and aIdDissection then
        NewSuggMemSortedItem.HasPotentialIssue := false
      else
      begin
        NewSuggMemSortedItem.HasPotentialIssue := true;
        for MemLineIndex := 0 to aTempMem.mdLines.ItemCount-1 do
        begin
          MemLine := aTempMem.mdLines.MemorisationLine_At(MemLineIndex);
          if ((Assigned(MemLine)) and (MemLineIndex = 0) and (MemLine^.mlAccount = '')) or
             (Tran^.txAccount = '') then
          begin
            NewSuggMemSortedItem.HasPotentialIssue := false;
            break;
          end;

          if (Assigned(MemLine)) and (MemLine^.mlAccount = Tran^.txAccount) then
          begin
            NewSuggMemSortedItem.HasPotentialIssue := false;
            break;
          end;
        end;
      end;

      aMemTranSortedList.AddItem(NewSuggMemSortedItem);
      Result := true;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.IsAccountUsedByMem(const aBankAccount: TBank_Account; const aTempMem: TMemorisation): boolean;
var
  TranIndex : integer;
  Tran : pTransaction_Rec;
begin
  Result := false;
  for TranIndex := 0 to aBankAccount.baTransaction_List.ItemCount-1 do
  begin
    Tran := aBankAccount.baTransaction_List.Transaction_At(TranIndex);

    if Tran^.txLocked then
      Continue;

    If Tran^.txDate_Transferred <> 0 then
      Continue;

    If ( Tran^.txType <> aTempMem.mdFields^.mdType ) and
       not ( aTempMem.mdFields^.mdType = AllEntries ) then
      Continue;

    if Tran^.txDate_Effective < aTempMem.mdFields^.mdFrom_Date then
      Continue;

    if (aTempMem.mdFields^.mdUntil_Date > 0) and
       (Tran^.txDate_Effective > aTempMem.mdFields^.mdUntil_Date) then
      Continue;

    if CanMemorise(Tran, aTempMem) then
    begin
      Result := true;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindSuggestionUsedByTransaction(const aBankAccount: TBank_Account; const aTrans : pTransaction_Rec; const aChart : TChart; var aSuggMemItem : TSuggMemSortedListRec) : boolean;
var
  FirstTranLink, LastTranLink : integer;
  TranLinkIndex, RevTranLinkIndex  : integer;
  TranSuggLinkRec : pTran_Suggested_Link_Rec;
  TranAccLinkIndex : integer;
  SuggAccLinkRec: pSuggested_Account_Link_Rec;
  LowAccountIndex, HighAccountIndex : integer;
  TranTypeIndex, TranIndex, SuggIndex : integer;
  Suggestion: pSuggested_Mem_Rec;
  SuggMemsData : TSuggMemSortedListRec;
  BestSuggMemsData : TSuggMemSortedListRec;
  SuggUsed : boolean;
begin
  Result := false;

  BestSuggMemsData.Id := -1;
  BestSuggMemsData.ManualCount := 0;
  BestSuggMemsData.MatchedPhrase := '';
  BestSuggMemsData.Account := '';
  BestSuggMemsData.TotalCount := 0;
  BestSuggMemsData.ManualAcountCount := 0;
  BestSuggMemsData.IsExactMatch := false;
  BestSuggMemsData.IsHidden := false;

  aTrans^.txSuggested_Mem_Index := TRAN_NO_SUGG;

  // find Transaction links using current Transaction
  if not aBankAccount.baTransaction_List.SearchUsingTypeDateandTranSeqNo(aTrans^.txType, aTrans^.txDate_Effective, aTrans^.txSequence_No, TranTypeIndex) then
    Exit;

  // Check that the transaction is in the right state
  if not aBankAccount.baTransaction_List.GetIndexPRec(TranTypeIndex)^.tiSuggested_Mem_State in [tssCreateSuggestion, tssForCount] then
    Exit;

  if aBankAccount.baTran_Suggested_Link_List.SearchUsingTranSeqNo(aTrans^.txSequence_No, FirstTranLink, LastTranLink) then
  begin
    for TranLinkIndex := FirstTranLink to LastTranLink do
    begin
      TranSuggLinkRec := aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_At(TranLinkIndex).GetAs_pRec;

      if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(TranSuggLinkRec.tsSuggestedId, SuggIndex) then
      begin
        Suggestion := aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex);

        if GetSuggestionUsedInfo(aBankAccount, Suggestion, aChart, SuggMemsData) then
        begin
          if (SuggMemsData.IsHidden) then
            Continue;

          if aTrans^.txSuggested_Mem_Index = TRAN_NO_SUGG then
          begin
            aTrans^.txSuggested_Mem_Index := Suggestion^.smId;
            BestSuggMemsData := SuggMemsData;
            Continue;
          end;

          if SuggMemsData.ManualCount < BestSuggMemsData.ManualCount then
            Continue;

          if SuggMemsData.ManualCount > BestSuggMemsData.ManualCount then
          begin
            aTrans^.txSuggested_Mem_Index := Suggestion^.smId;
            BestSuggMemsData := SuggMemsData;
            Continue;
          end;

          if (SuggMemsData.IsExactMatch) and (not BestSuggMemsData.IsExactMatch) then
          begin
            aTrans^.txSuggested_Mem_Index := Suggestion^.smId;
            BestSuggMemsData := SuggMemsData;
            Continue;
          end;
        end;
      end;
    end;
  end;
  aSuggMemItem := BestSuggMemsData;
  aSuggMemItem.UnCodedCount := aSuggMemItem.TotalCount - aSuggMemItem.ManualCount;
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
procedure TSuggestedMems.DeleteSuggestionAndLinks(const aBankAccount: TBank_Account; aSuggestionId: integer);
var
  ArrIndex : integer;
  TranSeqIndex : integer;
  TranSeqNoArr : Array of integer;

  AccountIndex : integer;
  AccountArr : Array of integer;

  SuggIndex : integer;
  FoundSuggLowIndex : integer;
  FoundSuggHighIndex : integer;

  TypeId : integer;
  PhraseId : integer;
  TypePhraseIndex : integer;
begin
  // Transaction Links
  if aBankAccount.baTran_Suggested_Link_List.SearchUsingSuggestedId(aSuggestionId, FoundSuggLowIndex, FoundSuggHighIndex) then
  begin
    setlength(TranSeqNoArr, (FoundSuggHighIndex-FoundSuggLowIndex)+1);
    for SuggIndex := FoundSuggLowIndex to FoundSuggHighIndex do
      TranSeqNoArr[SuggIndex] := aBankAccount.baTran_Suggested_Link_List.GetIndexPRec(SuggIndex)^.Tran_Seq_No;

    for ArrIndex := high(TranSeqNoArr) downto 0 do
    begin
      SuggIndex := ArrIndex + FoundSuggLowIndex;
      if aBankAccount.baTran_Suggested_Link_List.SearchUsingTranSeqNoAndSuggestedId(TranSeqNoArr[ArrIndex], aSuggestionId, TranSeqIndex) then
      begin
        aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_Index.DelFreeItem(aBankAccount.baTran_Suggested_Link_List.GetIndexPRec(SuggIndex));
        aBankAccount.baTran_Suggested_Link_List.DelFreeItem(aBankAccount.baTran_Suggested_Link_List.Items[TranSeqIndex]);
      end;
    end;
  end;

  // Account Links
  if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedId(aSuggestionId, FoundSuggLowIndex, FoundSuggHighIndex) then
  begin
    setlength(AccountArr, (FoundSuggHighIndex-FoundSuggLowIndex)+1);
    for SuggIndex := FoundSuggLowIndex to FoundSuggHighIndex do
      AccountArr[SuggIndex] := aBankAccount.baSuggested_Account_Link_List.GetPRec(SuggIndex)^.slAccountId;

    for ArrIndex := high(AccountArr) downto 0 do
    begin
      SuggIndex := ArrIndex + FoundSuggLowIndex;
      if aBankAccount.baSuggested_Account_Link_List.SearchUsingAccountAndSuggestedId(AccountArr[ArrIndex], aSuggestionId, AccountIndex) then
      begin
        aBankAccount.baSuggested_Account_Link_List.DelFreeItem(aBankAccount.baSuggested_Account_Link_List.Items[SuggIndex]);
        aBankAccount.baSuggested_Account_Link_List.Suggested_Account_Link_Index.DelFreeItem(aBankAccount.baSuggested_Account_Link_List.GetIndexPRec(AccountIndex));
      end;
    end;
  end;

  // Suggestion
  if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(aSuggestionId, SuggIndex) then
  begin
    TypeId   := aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smTypeId;
    PhraseId := aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smPhraseId;

    if aBankAccount.baSuggested_Mem_List.SearchUsingTypeAndPhraseId(TypeId, PhraseId, TypePhraseIndex) then
    begin
      aBankAccount.baSuggested_Mem_List.DelFreeItem(aBankAccount.baSuggested_Mem_List.Items[SuggIndex]);
      aBankAccount.baSuggested_Mem_List.Suggested_Mem_Index.DelFreeItem(aBankAccount.baSuggested_Mem_List.GetIndexPRec(TypePhraseIndex));
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.DeleteLinksAndSuggestions(const aBankAccount : TBank_Account; const aTrans : pTran_Suggested_Index_Rec; aOldTranState : byte);
var
  ArrIndex : integer;
  SuggIndex : integer;
  SuggArr : Array of integer;

  TranSeqIndex : integer;
  TranSeqNo : integer;
  FoundSuggLowIndex : integer;
  FoundSuggHighIndex : integer;

  AccountIndex : integer;
  AccountId : integer;
  OldAccountId : integer;

  LowIndex : integer;
  HighIndex : integer;
begin
  TranSeqNo := aTrans^.tiTran_Seq_No;

  if aBankAccount.baTran_Suggested_Link_List.SearchUsingTranSeqNo(TranSeqNo, FoundSuggLowIndex, FoundSuggHighIndex) then
  begin
    setlength(SuggArr, (FoundSuggHighIndex-FoundSuggLowIndex)+1);
    for ArrIndex := 0 to high(SuggArr) do
    begin
      SuggIndex := ArrIndex + FoundSuggLowIndex;
      SuggArr[ArrIndex] := aBankAccount.baTran_Suggested_Link_List.GetPRec(SuggIndex)^.tsSuggestedId;
    end;

    for ArrIndex := high(SuggArr) downto 0 do
    begin
      TranSeqIndex := ArrIndex + FoundSuggLowIndex;
      OldAccountId := aBankAccount.baTran_Suggested_Link_List.GetPRec(TranSeqIndex)^.tsAccountId;

      // Transaction Link
      if aBankAccount.baTran_Suggested_Link_List.SearchUsingSuggestedIdAndTranSeqNo(SuggArr[ArrIndex], TranSeqNo, SuggIndex) then
      begin
        aBankAccount.baTran_Suggested_Link_List.DelFreeItem(aBankAccount.baTran_Suggested_Link_List.Items[TranSeqIndex]);
        aBankAccount.baTran_Suggested_Link_List.Tran_Suggested_Link_Index.DelFreeItem(aBankAccount.baTran_Suggested_Link_List.GetIndexPRec(SuggIndex));
      end;

      // Suggestion
      if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(SuggArr[ArrIndex], SuggIndex) then
      begin
        aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smUpdate_Date := CurrentDate;
        aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smHas_Changed := true;

        // Account
        if aBankAccount.baSuggested_Account_List.SearchUsingAccountId(OldAccountId, AccountIndex) then
        begin
          AccountId := aBankAccount.baSuggested_Account_List.GetPRec(AccountIndex)^.saId;

          if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedAndAccountId(SuggArr[ArrIndex], AccountId, AccountIndex) then
          begin
            if aTrans^.tiSuggested_Mem_State = tssCreateSuggestion then                                                                       
              if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountIndex)^.slManual_Count > 0 then
                dec(aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountIndex)^.slManual_Count);

            dec(aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountIndex)^.slCount);
            if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountIndex)^.slCount < 1 then
            begin
              if aBankAccount.baSuggested_Account_Link_List.SearchUsingAccountAndSuggestedId(AccountId, SuggArr[ArrIndex], SuggIndex) then
              begin
                aBankAccount.baSuggested_Account_Link_List.DelFreeItem(aBankAccount.baSuggested_Account_Link_List.Items[AccountIndex]);
                aBankAccount.baSuggested_Account_Link_List.Suggested_Account_Link_Index.DelFreeItem(aBankAccount.baSuggested_Account_Link_List.GetIndexPRec(SuggIndex));
              end;

              // If no more links delete suggestion
              if not aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedId(SuggArr[ArrIndex], LowIndex, HighIndex) then
                DeleteSuggestionAndLinks(aBankAccount, SuggArr[ArrIndex]);
            end;
          end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateSuggestion(const aBankAccount: TBank_Account; aSuggestionId: integer; aIsHidden: boolean);
var
  SuggIndex : integer;
begin
  if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(aSuggestionId, SuggIndex) then
    aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smHidden := aIsHidden;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.UpdateSuggestionAccountAndLinks(const aBankAccount: TBank_Account; const aTrans : pTran_Suggested_Index_Rec; aOldState : byte): boolean;
var
  TranSeqNo : integer;

  FoundSuggLowIndex : integer;
  FoundSuggHighIndex : integer;

  SuggTranIndex : integer;

  SuggIndex : integer;
  SuggestedId : integer;
  OldAccountId : integer;
  NewAccountId : integer;

  AccountCreated : boolean;
  Suggested_Account_Link_Rec : pSuggested_Account_Link_Rec;

  AccountLinkIndex : integer;
  AccountLinkSubIndex : integer;
  LowIndex, HighIndex : integer;
begin
  Result := false;

  TranSeqNo := aTrans^.tiTran_Seq_No;

  if aBankAccount.baTran_Suggested_Link_List.SearchUsingTranSeqNo(TranSeqNo, FoundSuggLowIndex, FoundSuggHighIndex) then
  begin
    for SuggTranIndex := FoundSuggLowIndex to FoundSuggHighIndex do
    begin
      SuggestedId := aBankAccount.baTran_Suggested_Link_List.GetPRec(SuggTranIndex)^.tsSuggestedId;
      OldAccountId := aBankAccount.baTran_Suggested_Link_List.GetPRec(SuggTranIndex)^.tsAccountId;

      // Account
      AccountCreated := (FindAccountOrCreate(aBankAccount, aTrans^.tiAccount, NewAccountId) = fcCreated);

      if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(SuggestedId, SuggIndex) then
      begin
        aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smUpdate_Date := CurrentDate;
        aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smHas_Changed := true;
      end;

      // Account has not changed
      if NewAccountId = OldAccountId then
        Exit;

      if AccountCreated then
        CreateSuggestionAccountLink(aBankAccount, SuggestedId, NewAccountId, aTrans^.tiAccount, Suggested_Account_Link_Rec)
      else
        FindSuggestionAccountLinkOrCreate(aBankAccount, SuggestedId, NewAccountId, aTrans^.tiAccount, Suggested_Account_Link_Rec);

      // Add to New Account
      aBankAccount.baTran_Suggested_Link_List.GetPRec(SuggTranIndex)^.tsAccountId := NewAccountId;

      if aTrans^.tiSuggested_Mem_State = tssCreateSuggestion then
        inc(Suggested_Account_Link_Rec^.slManual_Count);

      inc(Suggested_Account_Link_Rec^.slCount);

      // Removed from Old Account
      if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedAndAccountId(SuggestedId, OldAccountId, AccountLinkIndex) then
      begin
        if aOldState = tssCreateSuggestion then
          if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slManual_Count > 0 then
            dec(aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slManual_Count);

        dec(aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slCount);
        if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slCount < 1 then
        begin
          if aBankAccount.baSuggested_Account_Link_List.SearchUsingAccountAndSuggestedId(OldAccountId, SuggestedId, AccountLinkSubIndex) then
          begin
            aBankAccount.baSuggested_Account_Link_List.DelFreeItem(aBankAccount.baSuggested_Account_Link_List.Items[AccountLinkIndex]);
            aBankAccount.baSuggested_Account_Link_List.Suggested_Account_Link_Index.DelFreeItem(aBankAccount.baSuggested_Account_Link_List.GetIndexPRec(AccountLinkSubIndex));
          end;

          // If no more links delete suggestion
          if not aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedId(SuggestedId, LowIndex, HighIndex) then
            DeleteSuggestionAndLinks(aBankAccount, SuggestedId);
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindPhraseOrCreate(const aBankAccount : TBank_Account; const aPhrase : string; var aPhraseid : integer) : TFoundCreate;
var
  PhraseIndex : integer;
  NewSuggested_Phrase : TSuggested_Phrase;
begin
  if aBankAccount.baSuggested_Phrase_List.SearchUsingPhrase(aPhrase, PhraseIndex) then
  begin
    aPhraseid := aBankAccount.baSuggested_Phrase_List.GetIndexPRec(PhraseIndex)^.Id;
    Result := fcFound;
  end
  else
  begin
    NewSuggested_Phrase := TSuggested_Phrase.Create();
    NewSuggested_Phrase.spFields.spPhrase := aPhrase;
    aPhraseid := aBankAccount.baSuggested_Phrase_List.Insert_Suggested_Phrase_Rec(NewSuggested_Phrase, true);
    Result := fcCreated;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindSuggestionUsingPhraseIdAndType(const aBankAccount: TBank_Account; aTypeId: byte; aPhraseId: integer; var aSuggested_Mem_Rec: pSuggested_Mem_Rec): boolean;
var
  Sugg1Index : integer;
  Sugg2Index : integer;
  SuggId : integer;
begin
  Result := false;

  if aBankAccount.baSuggested_Mem_List.SearchUsingTypeAndPhraseId(aTypeId, aPhraseId, Sugg1Index) then
  begin
    SuggId := aBankAccount.baSuggested_Mem_List.GetIndexPRec(Sugg1Index)^.Id;
    if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(SuggId, Sugg2Index) then
    begin
      aSuggested_Mem_Rec := aBankAccount.baSuggested_Mem_List.GetPRec(Sugg2Index);
      Result := true;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.CreateSuggestion(const aBankAccount: TBank_Account; aTypeId: byte; aPhraseId: integer; Start_Data, End_Data: boolean; var aSuggested_Mem_Rec: pSuggested_Mem_Rec);
var
  NewSuggested_Mem : TSuggested_Mem;
begin
  NewSuggested_Mem := TSuggested_Mem.Create();
  NewSuggested_Mem.smFields.smTypeId       := aTypeId;
  NewSuggested_Mem.smFields.smPhraseId     := aPhraseId;
  NewSuggested_Mem.smFields.smStart_Data   := Start_Data;
  NewSuggested_Mem.smFields.smEnd_Data     := End_Data;
  NewSuggested_Mem.smFields.smUpdate_Date  := CurrentDate;
  NewSuggested_Mem.smFields.smHas_Changed  := true;
  NewSuggested_Mem.smFields.smManual_Count := 0;
  NewSuggested_Mem.smFields.smHidden       := false;
  aBankAccount.baSuggested_Mem_List.Insert_Suggested_Mem_Rec(NewSuggested_Mem);
  aSuggested_Mem_Rec := aBankAccount.baSuggested_Mem_List.GetAs_pRec(NewSuggested_Mem);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindAccountOrCreate(aBankAccount: TBank_Account; aAccount: string; var aAccountid: integer): TFoundCreate;
var
  AccountIndex : integer;
  NewSuggested_Account : TSuggested_Account;
begin
  if aBankAccount.baSuggested_Account_List.SearchUsingAccount(aAccount, AccountIndex) then
  begin
    aAccountid := aBankAccount.baSuggested_Account_List.GetIndexPRec(AccountIndex)^.Id;
    Result := fcFound;
  end
  else
  begin
    NewSuggested_Account := TSuggested_Account.Create();
    NewSuggested_Account.saFields.saAccount := aAccount;
    aAccountid := aBankAccount.baSuggested_Account_List.Insert_Suggested_Account_Rec(NewSuggested_Account, true);
    Result := fcCreated;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindSuggestionAccountLinkOrCreate(const aBankAccount: TBank_Account; aSuggestionId, aAccountId: integer; const aAccount : string; var aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec): TFoundCreate;
var
  AccountLinkIndex : integer;
begin
  if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedAndAccountId(aSuggestionId, aAccountId, AccountLinkIndex) then
  begin
    aSuggested_Account_Link_Rec := aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex);
    Result := fcFound;
  end
  else
  begin
    CreateSuggestionAccountLink(aBankAccount, aSuggestionId, aAccountId, aAccount, aSuggested_Account_Link_Rec);
    Result := fcCreated;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.CreateSuggestionAccountLink(const aBankAccount: TBank_Account; aSuggestionId, aAccountId: integer; const aAccount : string; var aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec);
var
  NewSuggested_Account_Link : TSuggested_Account_Link;
begin
  NewSuggested_Account_Link := TSuggested_Account_Link.Create();
  NewSuggested_Account_Link.slFields.slSuggestedId      := aSuggestionId;
  NewSuggested_Account_Link.slFields.slAccountId        := aAccountId;
  NewSuggested_Account_Link.slFields.slCount            := 0;
  NewSuggested_Account_Link.slFields.slManual_Count     := 0;
  NewSuggested_Account_Link.slFields.slIsUncoded        := (length(trim(aAccount)) = 0);
  NewSuggested_Account_Link.slFields.slIsDissected      := (aAccount = DISSECT_DESC);

  aBankAccount.baSuggested_Account_Link_List.Insert_Suggested_Account_Link_Rec(NewSuggested_Account_Link);
  aSuggested_Account_Link_Rec := aBankAccount.baSuggested_Account_Link_List.GetAs_pRec(NewSuggested_Account_Link);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindTranSuggestionLink(const aBankAccount: TBank_Account; aTranSeqNo : integer; aSuggestionId: integer): boolean;
var
  Index : integer;
begin
  Result := aBankAccount.baTran_Suggested_Link_List.SearchUsingTranSeqNoAndSuggestedId(aTranSeqNo, aSuggestionId, Index);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.CreateTranSuggestionLink(const aBankAccount: TBank_Account; const aTrans : pTran_Suggested_Index_Rec; const aSuggested_Mem_Rec: pSuggested_Mem_Rec; const aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec; aTranNewState : byte);
var
  NewSuggLink : TTran_Suggested_Link;
begin
  NewSuggLink := TTran_Suggested_Link.Create();
  NewSuggLink.tsFields.tsDate_Effective   := aTrans^.tiDate_Effective;
  NewSuggLink.tsFields.tsTran_Seq_No      := aTrans^.tiTran_Seq_No;
  NewSuggLink.tsFields.tsSuggestedId      := aSuggested_Mem_Rec^.smId;
  NewSuggLink.tsFields.tsAccountId        := aSuggested_Account_Link_Rec^.slAccountId;
  aBankAccount.baTran_Suggested_Link_List.Insert_Tran_Suggested_Link_Rec(NewSuggLink);

  if aTranNewState = tssCreateSuggestion then
    inc(aSuggested_Account_Link_Rec^.slManual_Count);

  inc(aSuggested_Account_Link_Rec^.slCount);

  aSuggested_Mem_Rec^.smUpdate_Date := CurrentDate;
  aSuggested_Mem_Rec^.smHas_Changed := true;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SearchFoundMatch(aStartData: boolean; var aMatchedPhrase : string; aEndData: boolean; const aBankAccount : TBank_Account; const aScanTrans, aMatchedTrans : pTran_Suggested_Index_Rec; aTranNewState : byte);
var
  PhraseId : integer;
  ScanAccountId : integer;
  MatchAccountId : integer;

  PhraseCreated : boolean;
  ScanAccountCreated : boolean;
  MatchAccountCreated : boolean;

  Suggested_Mem_Rec: pSuggested_Mem_Rec;
  Scan_Suggested_Account_Link_Rec : pSuggested_Account_Link_Rec;
  Match_Suggested_Account_Link_Rec : pSuggested_Account_Link_Rec;

  AccountsNotTheSame : boolean;
begin
  AccountsNotTheSame := (CompareText(aScanTrans^.tiAccount,aMatchedTrans^.tiAccount) <> 0);

  // Phrase
  PhraseCreated := (FindPhraseOrCreate(aBankAccount, aMatchedPhrase, PhraseId) = fcCreated);

  // Suggestion
  if not PhraseCreated then
    PhraseCreated := not (FindSuggestionUsingPhraseIdAndType(aBankAccount, aScanTrans^.tiType, PhraseId, Suggested_Mem_Rec));
  if PhraseCreated then
    CreateSuggestion(aBankAccount, aScanTrans^.tiType, PhraseId, aStartData, aEndData, Suggested_Mem_Rec);

  // Account or Accounts if code not the same
  ScanAccountCreated := false;
  if AccountsNotTheSame then
    ScanAccountCreated := (FindAccountOrCreate(aBankAccount, aScanTrans^.tiAccount, ScanAccountId) = fcCreated);

  MatchAccountCreated := (FindAccountOrCreate(aBankAccount, aMatchedTrans^.tiAccount, MatchAccountId) = fcCreated);

  // Account Links
  if AccountsNotTheSame then
  begin
    if (PhraseCreated) or (ScanAccountCreated) then
      CreateSuggestionAccountLink(aBankAccount, Suggested_Mem_Rec^.smId, ScanAccountId, aScanTrans^.tiAccount, Scan_Suggested_Account_Link_Rec)
    else
      FindSuggestionAccountLinkOrCreate(aBankAccount, Suggested_Mem_Rec^.smId, ScanAccountId, aScanTrans^.tiAccount, Scan_Suggested_Account_Link_Rec);
  end;

  if (PhraseCreated) or (MatchAccountCreated) then
    CreateSuggestionAccountLink(aBankAccount, Suggested_Mem_Rec^.smId, MatchAccountId, aMatchedTrans^.tiAccount, Match_Suggested_Account_Link_Rec)
  else
    FindSuggestionAccountLinkOrCreate(aBankAccount, Suggested_Mem_Rec^.smId, MatchAccountId, aMatchedTrans^.tiAccount, Match_Suggested_Account_Link_Rec);

  // Transaction Links
  if (PhraseCreated) or
     (not FindTranSuggestionLink(aBankAccount, aScanTrans^.tiTran_Seq_No, Suggested_Mem_Rec^.smId)) then
  begin
    if AccountsNotTheSame then
      CreateTranSuggestionLink(aBankAccount, aScanTrans, Suggested_Mem_Rec, Scan_Suggested_Account_Link_Rec, aTranNewState)
    else
      CreateTranSuggestionLink(aBankAccount, aScanTrans, Suggested_Mem_Rec, Match_Suggested_Account_Link_Rec, aTranNewState );
  end;

  if (PhraseCreated) or
     (not FindTranSuggestionLink(aBankAccount, aMatchedTrans^.tiTran_Seq_No, Suggested_Mem_Rec^.smId)) then
    CreateTranSuggestionLink(aBankAccount, aMatchedTrans, Suggested_Mem_Rec, Match_Suggested_Account_Link_Rec, aMatchedTrans^.tiSuggested_Mem_State );
end;

//------------------------------------------------------------------------------
function TSuggestedMems.IsMemorisation(aMemorisations: TMemorisations_List; aType: byte; const aMatchPhrase: string): boolean;
var
  MemIndex : integer;
  MemStatementDetails : string;

  //----------------------------------------------------------------------------
  function DropWildCards(aInString : string) : string;
  var
    Index : integer;
  begin
    Result := '';
    for Index := 1 to length(aInString) do
    begin
      if aInString[Index] <> '*' then
        Result := Result + aInString[Index];
    end;
  end;
begin
  result := false;
  for MemIndex := 0 to aMemorisations.ItemCount-1 do
  begin
    MemStatementDetails := aMemorisations.Memorisation_At(MemIndex).mdFields.mdStatement_Details;
    MemStatementDetails := trim(DropWildCards(MemStatementDetails));

    if (aType = aMemorisations.Memorisation_At(MemIndex).mdFields.mdType) and
       (CompareText(aMatchPhrase, MemStatementDetails) = 0) then
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
  PhraseIndex : integer;
  BankPrefix : string;
  MatchedPhrase : string;
begin
  result := false;
  if aBankAccount.baSuggested_Phrase_List.SearchUsingPhraseId(aSuggestion^.smPhraseId, PhraseIndex) then
  begin
    MatchedPhrase := aBankAccount.baSuggested_Phrase_List.GetPRec(PhraseIndex)^.spPhrase;

    if IsMemorisation(aBankAccount.baMemorisations_List, aSuggestion^.smTypeId, MatchedPhrase) then
    begin
      result := true;
      exit;
    end;

    if aBankAccount.baFields.baApply_Master_Memorised_Entries then
    begin
      BankPrefix := GetBankPrefix(aBankAccount.baFields.baBank_Account_Number);
      if IsMasterMemorisation(aSuggestion^.smTypeId, MatchedPhrase, BankPrefix) then
      begin
        result := true;
        exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.IsSuggMemsRunning: boolean;
begin
  Result := (MainState <> mtsNoScan) and (fMemScanRefCount = 0);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.IsSuggestionInIgnoreList(const aBankAccount: TBank_Account; const aSuggestion: pSuggested_Mem_Rec): boolean;
const
  IGNORE_LIST : Array[1..4] of string =
    ('and','the','ltd','mrs');
var
  PhraseIndex : integer;
  MatchedPhrase : string;
  IgnoreIndex : integer;
begin
  result := false;
  if aBankAccount.baSuggested_Phrase_List.SearchUsingPhraseId(aSuggestion^.smPhraseId, PhraseIndex) then
  begin
    MatchedPhrase := aBankAccount.baSuggested_Phrase_List.GetPRec(PhraseIndex)^.spPhrase;

    for IgnoreIndex := 1 to high(IGNORE_LIST) do
    begin
      if CompareText(MatchedPhrase, IGNORE_LIST[IgnoreIndex]) = 0 then
      begin
        result := true;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetScannedState(aCoded_By : byte): byte;
begin
  if aCoded_By = cbManual then
  begin
    Result := tssCreateSuggestion;
    Exit;
  end;

  if aCoded_By in cbRemoveSuggestion then
  begin
    Result := tssRemoveSuggestion;
    Exit;
  end;

  Result := tssForCount;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.MemScan();
var
  StartTime : TDateTime;
  BankAccount: TBank_Account;
  Trans : pTran_Suggested_Index_Rec;
  ScannedOnce : boolean;
  RunMems2 : boolean;
  Date_Effective : integer;
  Days, Months, Years : Integer;
begin
  RunMems2 := true;
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
        if Mainstate = mtsMems2NoScan then
          RunMems2 := false;

        if DebugMe then
        begin
          if fNoMoreRecord <> fTempNoMoreRecord then
            LogDoneProcessing(fTempNoMoreRecord);
        end;

        if (ScannedOnce) and (fNoMoreRecord) and (fTempNoMoreRecord) then
        begin
          Exit;
        end;

        if (fNoMoreRecord = false) and
           (fTempNoMoreRecord = true) then
        begin
          fNoMoreRecord := fTempNoMoreRecord;
          fDoneProcessingEvent.DoEvent();
        end
        else
          fNoMoreRecord := fTempNoMoreRecord;

        ScannedOnce := true;

        fTempNoMoreRecord := true;
      end;

      if (BankAccount.baTransaction_List.ItemCount > 0) and
         (not BankAccount.IsAJournalAccount) then
      begin
        Date_Effective := BankAccount.baTransaction_List.Transaction_At(0)^.txDate_Effective;
        DateDiff(Date_Effective, CurrentDate, Days, Months, Years);

        // Set Trans account to max on first scan
        fTranIndex := BankAccount.baTransaction_List.ItemCount-1;
        fTranType := BankAccount.baTransaction_List.GetIndexPRec(fTranIndex)^.tiType;
        fTranTypeStartIndex := fTranIndex;
      end
      else
      begin
        Days := 0;
        Months := 0;
        Years := 0;
      end;

      // Disable Mems v2 when there are less than 150 transactions AND the oldest transaction is less than 3 months ago
      if (BankAccount.baTransaction_List.ItemCount < PARTIAL_MATCH_MIN_TRANS) and (Years = 0) and (Months < 3) then
        RunMems2 := false
      else
        RunMems2 := true;

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

    Trans := BankAccount.baTransaction_List.GetIndexPRec(fTranIndex);
    if Trans^.tiType <> fTranType then
    begin
      fTranType := Trans^.tiType;
      fTranTypeStartIndex := fTranIndex;
    end;
    Dec(fTranIndex);

    if Trans^.tiSuggested_Mem_State = tssUnScanned then
      ProcessTransaction(BankAccount, Trans, RunMems2);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessTransaction(const aBankAccount : TBank_Account; const aTrans : pTran_Suggested_Index_Rec; aRunMems2 : boolean);
var
  TranNewState : byte;
begin
  if MainState = mtsNoScan then
    Exit;

  TranNewState := GetScannedState(aTrans^.tiCoded_By);

  SearchForMatchedPhrase(aBankAccount, aTrans, TranNewState, aRunMems2);

  SetSuggestedTransactionState(aBankAccount, aTrans, TranNewState);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SearchForMatchedPhrase(const aBankAccount : TBank_Account; const aSearchTrans : pTran_Suggested_Index_Rec; aTranNewState : byte; aRunMems2 : boolean);
var
  TranIndex : integer;
  MatchTran : pTran_Suggested_Index_Rec;
  StartData : boolean;
  FoundLCS  : string;
  EndData   : boolean;
  SearchTranDetailsLength : integer;
  MatchTranDetailLength : integer;
  TrimmedPhrase : string;
begin
  TrimmedPhrase := Trim(aSearchTrans^.tiStatement_Details);
  SearchTranDetailsLength := length(TrimmedPhrase);

  if SearchTranDetailsLength < 3 then
    Exit;

  // don't inlcude suggestion if phrase is 3 in length and has a space in the middle example "M M"
  if (SearchTranDetailsLength = 3) and (TrimmedPhrase[2] = ' ') then
    Exit;

  TranIndex := fTranTypeStartIndex;
  MatchTran := aBankAccount.baTransaction_List.GetIndexPRec(TranIndex);
  while (MatchTran^.tiType = fTranType) do
  begin
    if MatchTran^.tiSuggested_Mem_State > tssUnScanned then
    begin

      MatchTranDetailLength := length(MatchTran^.tiStatement_Details);
      if MatchTranDetailLength > 2 then
      begin
        if (SearchTranDetailsLength = MatchTranDetailLength) and
          (CompareText(aSearchTrans^.tiStatement_Details, MatchTran^.tiStatement_Details) = 0) then
        begin
          // Mems 1
          SearchFoundMatch(false, aSearchTrans^.tiStatement_Details, false, aBankAccount, aSearchTrans, MatchTran, aTranNewState);
        end
        else
        begin
          // Mems 2
          if aRunMems2 then
          begin
            if FindLCS(Uppercase(aSearchTrans^.tiStatement_Details), Uppercase(MatchTran^.tiStatement_Details), StartData, FoundLCS, EndData) then
            begin
              if not ((Length(FoundLCS) = 3) and (FoundLCS[2] = ' ')) then
                SearchFoundMatch(StartData, FoundLCS, EndData, aBankAccount, aSearchTrans, MatchTran, aTranNewState);
            end;
          end;
        end;
      end;
    end;

    dec(TranIndex);
    if TranIndex < 0 then
      break;
    MatchTran := aBankAccount.baTransaction_List.GetIndexPRec(TranIndex);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.NewClientMainState;
begin
  fMainState := mtsScan;
end;

//------------------------------------------------------------------------------
constructor TSuggestedMems.Create;
begin
  fDoneProcessingEvent := TMultiCastNotify.Create(self);

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
  FreeAndNil(fDoneProcessingEvent);
  inherited;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetSuggestionUsedByTransaction(const aBankAccount: TBank_Account; const aTrans : pTransaction_Rec; const aChart : TChart; var aSuggMemItem : TSuggMemSortedListRec) : boolean;
var
  SuggIndex : integer;
  Suggestion: pSuggested_Mem_Rec;
begin
  Result := false;

  aSuggMemItem.ManualCount := 0;

  if aTrans^.txSuggested_Mem_Index = TRAN_NO_SUGG then
    Exit;

  if aTrans^.txSuggested_Mem_Index = TRAN_SUGG_NOT_FOUND then
  begin
    Result := FindSuggestionUsedByTransaction(aBankAccount, aTrans, aChart, aSuggMemItem);
    Exit;
  end;

  if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(aTrans^.txSuggested_Mem_Index, SuggIndex) then
  begin
    Suggestion := aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex);

    Result := GetSuggestionUsedInfo(aBankAccount, Suggestion, aChart, aSuggMemItem);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetSuggestedTransactionState(const aBankAccount : TBank_Account; const aTrans : pTransaction_Rec; aState : byte; aAccountChanged : boolean; aIsBulk : boolean);
var
  foundIndex : integer;
  Tran_Suggested_Index_Rec : pTran_Suggested_Index_Rec;
begin
  if MainState = mtsNoScan then
    Exit;

  if aBankAccount.IsAJournalAccount then
    Exit;

  if aBankAccount.baTransaction_List.SearchUsingTypeDateandTranSeqNo(aTrans^.txType,
                                                                     aTrans^.txDate_Effective,
                                                                     aTrans^.txSequence_No,
                                                                     foundIndex) then
  begin
    Tran_Suggested_Index_Rec := aBankAccount.baTransaction_List.GetIndexPRec(foundIndex);
    Tran_Suggested_Index_Rec^.tiAccount           := aTrans^.txAccount;
    Tran_Suggested_Index_Rec^.tiCoded_By          := aTrans^.txCoded_By;
    Tran_Suggested_Index_Rec^.tiStatement_Details := aTrans^.txStatement_Details;

    SetSuggestedTransactionState(aBankAccount, Tran_Suggested_Index_Rec, aState, aAccountChanged, aIsBulk);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetSuggestedTransactionState(const aBankAccount: TBank_Account; const aTrans: pTran_Suggested_Index_Rec; aState: byte; aAccountChanged, aIsBulk: boolean);
var
  OldState : byte;
  AccLinkUpdated : boolean;
begin
  OldState := aTrans^.tiSuggested_Mem_State;
  if OldState = aState then
    Exit;

  StopMemScan();
  try
    aTrans^.tiSuggested_Mem_State := aState;

    if (aTrans^.tiSuggested_Mem_State = tssUnScanned) and
      not (OldState = tssUnScanned) then
    begin
      AccLinkUpdated := false;

      if aAccountChanged then
      begin
        aTrans^.tiSuggested_Mem_State := GetScannedState(aTrans^.tiCoded_By);

        AccLinkUpdated := UpdateSuggestionAccountAndLinks(aBankAccount, aTrans, OldState);

        if (not aIsBulk) and
           (NoMoreRecord) then
          DoProcessingComplete();
      end
      else
      begin
        DeleteLinksAndSuggestions(aBankAccount, aTrans, OldState);
        inc(aBankAccount.baFields.baSuggested_UnProcessed_Count);
      end;
    end;

    if not (aTrans^.tiSuggested_Mem_State = tssUnScanned) and
      (OldState = tssUnScanned) then
    begin
      aTrans^.tiSuggested_Mem_State := GetScannedState(aTrans^.tiCoded_By);

      if aBankAccount.baFields.baSuggested_UnProcessed_Count > 0 then
        dec(aBankAccount.baFields.baSuggested_UnProcessed_Count);
    end;

  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateAccountWithTransDelete(const aBankAccount: TBank_Account; const aTrans: pTransaction_Rec);
var
  foundIndex : integer;
  Tran_Suggested_Index_Rec : pTran_Suggested_Index_Rec;
  DoLogging : boolean;
begin
  if MainState = mtsNoScan then
    Exit;

  if aBankAccount.IsAJournalAccount then
    Exit;

  DoLogging := (fMemScanRefCount = 0);

  StopMemScan();
  try
    if aBankAccount.baTransaction_List.SearchUsingTypeDateandTranSeqNo(aTrans^.txType,
                                                                       aTrans^.txDate_Effective,
                                                                       aTrans^.txSequence_No,
                                                                       foundIndex) then
    begin
      Tran_Suggested_Index_Rec := aBankAccount.baTransaction_List.GetIndexPRec(foundIndex);

      DeleteLinksAndSuggestions(aBankAccount, Tran_Suggested_Index_Rec, Tran_Suggested_Index_Rec^.tiSuggested_Mem_State);

      aBankAccount.baTransaction_List.Tran_Suggested_Index.FreeTheItem(Tran_Suggested_Index_Rec);

      if DoLogging and NoMoreRecord then
      begin
        if DebugMe then
          LogDoneProcessing(true);

        fDoneProcessingEvent.DoEvent;
      end;
    end;

  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.UpdateAccountWithTransInsert(const aBankAccount: TBank_Account; const aTrans: pTran_Suggested_Index_Rec; aNew : boolean);
begin
  if MainState = mtsNoScan then
    Exit;

  if (aNew) or (MEMSINI_SupportOptions = meiResetMems) then
    aTrans^.tiSuggested_Mem_State := tssUnScanned;

  if aTrans^.tiSuggested_Mem_State = tssUnScanned then
    inc(aBankAccount.baFields.baSuggested_UnProcessed_Count);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.DoCreateNewMemorisation(const aBankAccount : TBank_Account; const aChart : TChart; aSuggId : integer) : boolean;
var
  Mems: TMemorisations_List;
  Mem: TMemorisation;
  MemLine: pMemorisation_Line_Rec;
  SuggIndex : integer;
  Suggestion: pSuggested_Mem_Rec;
  SuggMemItem : TSuggMemSortedListRec;
begin
  Result := false;

  if aSuggId <= TRAN_SUGG_NOT_FOUND then
    Exit;

  if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(aSuggId, SuggIndex) then
  begin
    Suggestion := aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex);

    if not GetSuggestionUsedInfo(aBankAccount, Suggestion, aChart, SuggMemItem) then
      Exit;
  end;

  // Create memorisation
  Mems := aBankAccount.baMemorisations_List;
  Mem := TMemorisation.Create(Mems.AuditMgr);

  try
    Mem.mdFields.mdMatch_On_Statement_Details := true;
    Mem.mdFields.mdStatement_Details := SuggMemItem.MatchedPhrase;
    Mem.mdFields.mdType := SuggMemItem.AccType;

    // Create memorisation line
    MemLine := New_Memorisation_Line_Rec;
    MemLine.mlAccount := SuggMemItem.Account;
    MemLine.mlGST_Class := MyClient.clChart.GSTClass(SuggMemItem.Account);
    MemLine.mlPercentage := 100 * 10000; // Use 10000 for percentages
    Mem.mdLines.Insert(MemLine);

    // OK pressed, and insert mem?
    Result := CreateMemorisation(aBankAccount, Mem);
    if Result then
      incUsage(USAGE_ADDED_MEM_FROM_SUGGESTION_COUNT);
  finally
    FreeAndNil(Mem);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.DoProcessingComplete;
begin
  if not NoMoreRecord then
    Exit;

  if DebugMe then
    LogDoneProcessing(true);

  fDoneProcessingEvent.DoEvent;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetMainState();
begin
  case MEMSINI_SupportOptions of
    meiDisableSuggestedMems : fMainState := mtsNoScan;
    meiResetMems            : fMainState := mtsScan;
    meiFullfunctionality    : fMainState := mtsScan;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ResetAccount(const aBankAccount: TBank_Account);
var
  TranIndex : integer;
  TranRec : pTransaction_Rec;
  TranIndexRec : pTran_Suggested_Index_Rec;
begin
  if aBankAccount.IsAJournalAccount then
    Exit;

  StopMemScan();
  try
    fTranIndex := 0;
    aBankAccount.baFields.baSuggested_UnProcessed_Count := aBankAccount.baTransaction_List.ItemCount;
    for TranIndex := 0 to aBankAccount.baTransaction_List.ItemCount-1  do
    begin
      TranRec := aBankAccount.baTransaction_List.Transaction_At(TranIndex);
      TranIndexRec := aBankAccount.baTransaction_List.GetIndexPRec(TranIndex);
      TranRec^.txSuggested_Mem_State := tssUnScanned;
      TranIndexRec^.tiSuggested_Mem_State := tssUnScanned;
    end;

    aBankAccount.baTran_Suggested_Link_List.DeleteFreeAll();
    aBankAccount.baSuggested_Mem_List.DeleteFreeAll();
    aBankAccount.baSuggested_Account_List.DeleteFreeAll();
    aBankAccount.baSuggested_Account_Link_List.DeleteFreeAll();
    aBankAccount.baSuggested_Phrase_List.DeleteFreeAll();
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ResetAll(const aClient: TClientObj);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'ResetAll, Client ' + aClient.clFields.clCode);

  try
    StopMemScan();
    fNewAccount := true;
    fAccountIndex := 0;

    for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
    begin
      BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);

      ResetAccount(BankAccount);
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ResetLogging(const aClient: TClientObj);
var
  BankAccIndex : integer;
  BankAccount: TBank_Account;
  SuggestedMemIndex : integer;
begin
  for BankAccIndex := 0 to aClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := aClient.clBank_Account_List.Bank_Account_At(BankAccIndex);

    for SuggestedMemIndex := 0 to BankAccount.baSuggested_Mem_List.ItemCount-1 do
    begin
      BankAccount.baSuggested_Mem_List.GetPRec(SuggestedMemIndex).smHas_Changed := true;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.RunMemScan;
begin
  StopMemScan();
  try
    MemScan();
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
function TSuggestedMems.GetSuggestedMemsCount(const aBankAccount : TBank_Account; const aChart : TChart; aIncludeHidden : boolean = true) : integer;
var
  SuggestedMemIndex : integer;
  Suggestion: pSuggested_Mem_Rec;
  SuggMemItem : TSuggMemSortedListRec;
  CurrIndex : integer;
begin
  Result := 0;

  if not NoMoreRecord then
    Exit;

  StopMemScan();
  try
    for SuggestedMemIndex := 0 to aBankAccount.baSuggested_Mem_List.ItemCount - 1 do
    begin
      Suggestion := aBankAccount.baSuggested_Mem_List.GetPRec(SuggestedMemIndex);

      if GetSuggestionUsedInfo(aBankAccount, Suggestion, aChart, SuggMemItem) then
      begin
        if (not SuggMemItem.IsHidden) or aIncludeHidden then
          inc(Result);
      end;
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.GetSuggestedMems(const aBankAccount: TBank_Account; const aChart : TChart; var aSuggMemSortedList : TSuggMemSortedList);
var
  SuggestedMemIndex : integer;
  Suggestion: pSuggested_Mem_Rec;
  SuggMemItem : TSuggMemSortedListRec;
  CurrIndex : integer;
begin
  if not NoMoreRecord then
    Exit;

  StopMemScan();
  try
    for SuggestedMemIndex := 0 to aBankAccount.baSuggested_Mem_List.ItemCount - 1 do
    begin
      Suggestion := aBankAccount.baSuggested_Mem_List.GetPRec(SuggestedMemIndex);

      if GetSuggestionUsedInfo(aBankAccount, Suggestion, aChart, SuggMemItem) then
        aSuggMemSortedList.AddItem(SuggMemItem);
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetStatus(const aBankAccount: TBank_Account; const aChart: TChart): TSuggMemStatus;
var
  AccountHasRecMems : boolean;
begin
  Result := ssFound;

  if fMainState = mtsNoScan then
  begin
    Result := ssDisabled;
    Exit;
  end;

  if fNoMoreRecord then
  begin
    AccountHasRecMems := (GetSuggestedMemsCount(aBankAccount, aChart) > 0);

    if not AccountHasRecMems then
      result := ssNoFound;
  end
  else
  begin
    result := ssProcessing;
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.DetermineStatus(const aBankAccount : TBank_Account; const aChart : TChart): string;
begin
  result := '';

  case GetStatus(aBankAccount, aChart) of
    ssDisabled   : Result := MSG_DISABLED_MEMORISATIONS;
    ssNoFound    : Result := MSG_NO_MEMORISATIONS;
    ssProcessing : Result := MSG_STILL_PROCESSING;
  end;
end;

//------------------------------------------------------------------------------
initialization
begin
  DebugMe := DebugUnit(UnitName) or DebugMe;
  DebugMeExt := DebugUnit(UnitNameExt);
  fSuggestedMems := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  FreeAndNil(fSuggestedMems);
end;

end.
