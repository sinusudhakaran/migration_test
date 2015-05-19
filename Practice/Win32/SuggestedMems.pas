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
  Classes;

const
  mtsNoScan      = 0; mtsMin = 0;
  mtsMems2NoScan = 1;
  mtsExcluded    = 2;
  mtsScan        = 3; mtsMax = 3;

  tssUnScanned     = 0; tssMin = 0;
  tssExcluded      = 1;
  tssManualScanned = 2;
  tssUnCodedScaned = 3; tssMax = 3;

  tssScanned = [tssManualScanned, tssUnCodedScaned];
  tssScannedAndExluded = [tssExcluded, tssManualScanned, tssUnCodedScaned];

type
  TFoundCreate = (fcFound, fcCreated);

  //----------------------------------------------------------------------------
  TArrInt = Array of integer;
  TArrSuggPointers = Array of pSuggested_Mem_Rec;

  //----------------------------------------------------------------------------
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

    procedure LogDoneProcessing(aNoMoreRecords : Boolean);

    function GetSuggestionMatchText(const aMatchPhrase : string; aStart, aEnd : boolean) : string;

    procedure DeleteSuggestionAndLinks(aBankAccount : TBank_Account; aSuggestionId : integer);
    procedure DeleteLinksAndSuggestions(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aOldTranState : byte);
    function UpdateSuggestionAccountAndLinks(aBankAccount : TBank_Account; aTrans : pTransaction_Rec) : boolean;

    function FindPhraseOrCreate(aBankAccount : TBank_Account; aPhrase : string; var aPhraseid : integer) : TFoundCreate;
    function FindSuggestionUsingPhraseIdAndType(aBankAccount: TBank_Account; aTypeId: byte; aPhraseId: integer; var aSuggested_Mem_Rec: pSuggested_Mem_Rec): boolean;
    procedure CreateSuggestion(aBankAccount : TBank_Account; aTypeId: byte; aPhraseId: integer; Start_Data, End_Data : boolean; var aSuggested_Mem_Rec: pSuggested_Mem_Rec);
    function FindAccountOrCreate(aBankAccount : TBank_Account; aAccount : string; var aAccountid : integer) : TFoundCreate;
    function FindSuggestionAccountLinkOrCreate(aBankAccount: TBank_Account; aSuggestionId, aAccountId: integer; aAccount : string; var aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec): TFoundCreate;
    procedure CreateSuggestionAccountLink(aBankAccount: TBank_Account; aSuggestionId, aAccountId: integer; aAccount : string; var aSuggested_Account_Link_Rec : pSuggested_Account_Link_Rec);
    function FindTranSuggestionLink(aBankAccount: TBank_Account; aTranSeqNo : integer; aSuggestionId : integer) : boolean;
    procedure CreateTranSuggestionLink(aBankAccount: TBank_Account; aTranSeqNo: integer; aDate_Effective : integer; aSuggested_Mem_Rec: pSuggested_Mem_Rec; aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec);

    procedure SearchFoundMatch(aStartData: boolean; var aMatchedPhrase : string; aEndData: boolean; aBankAccount : TBank_Account; aScanTrans, aMatchedTrans : pTransaction_Rec; var aCurrentTranSuggestions : TArrSuggPointers; aTranNewState : byte);

    function IsMemorisation(aMemorisations: TMemorisations_List; aType : byte; const aMatchPhrase : string): boolean;
    function IsMasterMemorisation(aType: byte; const aMatchPhrase, aBankPrefix: string): boolean;
    function IsSuggestionUsedByMem(aBankAccount : TBank_Account; aSuggestion : pSuggested_Mem_Rec): boolean;

    function IsSuggestionInIgnoreList(aBankAccount : TBank_Account; aSuggestion : pSuggested_Mem_Rec): boolean;

    procedure MemScan();
    procedure ProcessTransaction(aBankAccount : TBank_Account; aTrans : pTransaction_Rec);
    procedure SearchForMatchedPhrase(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aTranNewState : byte);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetSuggestedTransactionState(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aState : byte; aAccountChanged : boolean = false; aIsBulk : boolean = false);
    procedure UpdateAccountWithTransDelete(aBankAccount : TBank_Account; aTrans: pTransaction_Rec);
    procedure UpdateAccountWithTransInsert(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aNew : boolean);
    procedure DoProcessingComplete();

    procedure SetMainState();
    Procedure NewClientMainState();
    procedure ResetAll(aClient: TClientObj);
    procedure ResetLogging(aClient: TClientObj);

    procedure StartMemScan(aForceStart : boolean = false);
    procedure StopMemScan(aForceStop : boolean = false);

    function GetSuggestedMemsCount(aBankAccount : TBank_Account; aChart : TChart) : integer;
    function GetSuggestedMems(aBankAccount : TBank_Account; aChart : TChart) : TSuggestedMemsArr;

    function DetermineStatus(aBankAccount : TBank_Account; aChart : TChart): string;

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
  spObj32,
  saObj32,
  slObj32,
  DateUtils,
  Math,
  lcs2,
  SYDEFS,
  mxFiles32,
  stDate,
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
                                             '    Count = ' + inttostr(aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountIndex)^.slCount));
          end;
        end;
      end;
    end;
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
procedure TSuggestedMems.DeleteSuggestionAndLinks(aBankAccount: TBank_Account; aSuggestionId: integer);
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
procedure TSuggestedMems.DeleteLinksAndSuggestions(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aOldTranState : byte);
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
  TranSeqNo := aTrans^.txSequence_No;

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
function TSuggestedMems.UpdateSuggestionAccountAndLinks(aBankAccount: TBank_Account; aTrans : pTransaction_Rec): boolean;
var
  TranSeqNo : integer;

  FoundSuggLowIndex : integer;
  FoundSuggHighIndex : integer;

  SuggTranIndex : integer;

  SuggIndex : integer;
  SuggestedId : integer;
  OldAccountId : integer;
  NewAccountId : integer;
  AccountIndex : integer;

  AccountCreated : boolean;
  Suggested_Account_Link_Rec : pSuggested_Account_Link_Rec;

  AccountLinkIndex : integer;
  AccountLinkSubIndex : integer;
  LowIndex, HighIndex : integer;
begin
  Result := false;

  TranSeqNo := aTrans^.txSequence_No;

  if aBankAccount.baTran_Suggested_Link_List.SearchUsingTranSeqNo(TranSeqNo, FoundSuggLowIndex, FoundSuggHighIndex) then
  begin
    for SuggTranIndex := FoundSuggLowIndex to FoundSuggHighIndex do
    begin
      SuggestedId := aBankAccount.baTran_Suggested_Link_List.GetPRec(SuggTranIndex)^.tsSuggestedId;
      OldAccountId := aBankAccount.baTran_Suggested_Link_List.GetPRec(SuggTranIndex)^.tsAccountId;

      // Account
      AccountCreated := (FindAccountOrCreate(aBankAccount, aTrans^.txAccount, NewAccountId) = fcCreated);

            // Account has not changed
      if NewAccountId = OldAccountId then
        Exit;

      if aBankAccount.baSuggested_Mem_List.SearchUsingSuggestedId(SuggestedId, SuggIndex) then
      begin
        aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smUpdate_Date := CurrentDate;
        aBankAccount.baSuggested_Mem_List.GetPRec(SuggIndex)^.smHas_Changed := true;
      end;

      if AccountCreated then
        CreateSuggestionAccountLink(aBankAccount, SuggestedId, NewAccountId, aTrans^.txAccount, Suggested_Account_Link_Rec)
      else
        FindSuggestionAccountLinkOrCreate(aBankAccount, SuggestedId, NewAccountId, aTrans^.txAccount, Suggested_Account_Link_Rec);

      // Add to New Account
      aBankAccount.baTran_Suggested_Link_List.GetPRec(SuggTranIndex)^.tsAccountId := NewAccountId;
      inc(Suggested_Account_Link_Rec^.slCount);

      // Removed from Old Account
      if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedAndAccountId(SuggestedId, OldAccountId, AccountLinkIndex) then
      begin
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
function TSuggestedMems.FindPhraseOrCreate(aBankAccount : TBank_Account; aPhrase : string; var aPhraseid : integer) : TFoundCreate;
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
function TSuggestedMems.FindSuggestionUsingPhraseIdAndType(aBankAccount: TBank_Account; aTypeId: byte; aPhraseId: integer; var aSuggested_Mem_Rec: pSuggested_Mem_Rec): boolean;
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
procedure TSuggestedMems.CreateSuggestion(aBankAccount: TBank_Account; aTypeId: byte; aPhraseId: integer; Start_Data, End_Data: boolean; var aSuggested_Mem_Rec: pSuggested_Mem_Rec);
var
  NewSuggested_Mem : TSuggested_Mem;
begin
  NewSuggested_Mem := TSuggested_Mem.Create();
  NewSuggested_Mem.smFields.smTypeId      := aTypeId;
  NewSuggested_Mem.smFields.smPhraseId    := aPhraseId;
  NewSuggested_Mem.smFields.smStart_Data  := Start_Data;
  NewSuggested_Mem.smFields.smEnd_Data    := End_Data;
  NewSuggested_Mem.smFields.smUpdate_Date := CurrentDate;
  NewSuggested_Mem.smFields.smHas_Changed := true;
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
function TSuggestedMems.FindSuggestionAccountLinkOrCreate(aBankAccount: TBank_Account; aSuggestionId, aAccountId: integer; aAccount : string; var aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec): TFoundCreate;
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
procedure TSuggestedMems.CreateSuggestionAccountLink(aBankAccount: TBank_Account; aSuggestionId, aAccountId: integer; aAccount : string; var aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec);
var
  NewSuggested_Account_Link : TSuggested_Account_Link;
begin
  NewSuggested_Account_Link := TSuggested_Account_Link.Create();
  NewSuggested_Account_Link.slFields.slSuggestedId := aSuggestionId;
  NewSuggested_Account_Link.slFields.slAccountId   := aAccountId;
  NewSuggested_Account_Link.slFields.slCount       := 0;
  NewSuggested_Account_Link.slFields.slIsUncoded   := (length(trim(aAccount)) = 0);
  NewSuggested_Account_Link.slFields.slIsDissected := (aAccount = DISSECT_DESC);
  aBankAccount.baSuggested_Account_Link_List.Insert_Suggested_Account_Link_Rec(NewSuggested_Account_Link);
  aSuggested_Account_Link_Rec := aBankAccount.baSuggested_Account_Link_List.GetAs_pRec(NewSuggested_Account_Link);
end;

//------------------------------------------------------------------------------
function TSuggestedMems.FindTranSuggestionLink(aBankAccount: TBank_Account; aTranSeqNo : integer; aSuggestionId: integer): boolean;
var
  Index : integer;
begin
  Result := aBankAccount.baTran_Suggested_Link_List.SearchUsingTranSeqNoAndSuggestedId(aTranSeqNo, aSuggestionId, Index);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.CreateTranSuggestionLink(aBankAccount: TBank_Account; aTranSeqNo: integer; aDate_Effective : integer; aSuggested_Mem_Rec: pSuggested_Mem_Rec; aSuggested_Account_Link_Rec: pSuggested_Account_Link_Rec);
var
  NewSuggLink : TTran_Suggested_Link;
begin
  NewSuggLink := TTran_Suggested_Link.Create();
  NewSuggLink.tsFields.tsDate_Effective := aDate_Effective;
  NewSuggLink.tsFields.tsTran_Seq_No := aTranSeqNo;
  NewSuggLink.tsFields.tsSuggestedId := aSuggested_Mem_Rec^.smId;
  NewSuggLink.tsFields.tsAccountId   := aSuggested_Account_Link_Rec^.slAccountId;
  aBankAccount.baTran_Suggested_Link_List.Insert_Tran_Suggested_Link_Rec(NewSuggLink);

  inc(aSuggested_Account_Link_Rec^.slCount);

  aSuggested_Mem_Rec^.smUpdate_Date := CurrentDate;
  aSuggested_Mem_Rec^.smHas_Changed := true;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SearchFoundMatch(aStartData: boolean; var aMatchedPhrase : string; aEndData: boolean; aBankAccount : TBank_Account; aScanTrans, aMatchedTrans : pTransaction_Rec; var aCurrentTranSuggestions : TArrSuggPointers; aTranNewState : byte);
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
  AccountsNotTheSame := not (aScanTrans^.txAccount = aMatchedTrans^.txAccount);

  // Phrase
  PhraseCreated := (FindPhraseOrCreate(aBankAccount, aMatchedPhrase, PhraseId) = fcCreated);

  // Suggestion
  if not PhraseCreated then
    PhraseCreated := not (FindSuggestionUsingPhraseIdAndType(aBankAccount, aScanTrans^.txType, PhraseId, Suggested_Mem_Rec));
  if PhraseCreated then
    CreateSuggestion(aBankAccount, aScanTrans^.txType, PhraseId, aStartData, aEndData, Suggested_Mem_Rec);

  // Account or Accounts if code not the same
  if AccountsNotTheSame then
    ScanAccountCreated := (FindAccountOrCreate(aBankAccount, aScanTrans^.txAccount, ScanAccountId) = fcCreated);

  MatchAccountCreated := (FindAccountOrCreate(aBankAccount, aMatchedTrans^.txAccount, MatchAccountId) = fcCreated);

  // Account Links
  if AccountsNotTheSame then
  begin
    if (PhraseCreated) or (ScanAccountCreated) then
      CreateSuggestionAccountLink(aBankAccount, Suggested_Mem_Rec^.smId, ScanAccountId, aScanTrans^.txAccount, Scan_Suggested_Account_Link_Rec)
    else
      FindSuggestionAccountLinkOrCreate(aBankAccount, Suggested_Mem_Rec^.smId, ScanAccountId, aScanTrans^.txAccount, Scan_Suggested_Account_Link_Rec);
  end;

  if (PhraseCreated) or (MatchAccountCreated) then
    CreateSuggestionAccountLink(aBankAccount, Suggested_Mem_Rec^.smId, MatchAccountId, aMatchedTrans^.txAccount, Match_Suggested_Account_Link_Rec)
  else
    FindSuggestionAccountLinkOrCreate(aBankAccount, Suggested_Mem_Rec^.smId, MatchAccountId, aMatchedTrans^.txAccount, Match_Suggested_Account_Link_Rec);

  // Transaction Links
  if (PhraseCreated) or
     (not FindTranSuggestionLink(aBankAccount, aScanTrans^.txSequence_No, Suggested_Mem_Rec^.smId)) then
  begin
    if AccountsNotTheSame then
      CreateTranSuggestionLink(aBankAccount, aScanTrans^.txSequence_No, aScanTrans^.txDate_Effective, Suggested_Mem_Rec, Scan_Suggested_Account_Link_Rec)
    else
      CreateTranSuggestionLink(aBankAccount, aScanTrans^.txSequence_No, aScanTrans^.txDate_Effective, Suggested_Mem_Rec, Match_Suggested_Account_Link_Rec);
  end;

  if (PhraseCreated) or
     (not FindTranSuggestionLink(aBankAccount, aMatchedTrans^.txSequence_No, Suggested_Mem_Rec^.smId)) then
    CreateTranSuggestionLink(aBankAccount, aMatchedTrans^.txSequence_No, aMatchedTrans^.txDate_Effective, Suggested_Mem_Rec, Match_Suggested_Account_Link_Rec);
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
  PhraseIndex : integer;
  BankPrefix : string;
  MatchedPhrase : string;
begin
  result := false;
  if aBankAccount.baSuggested_Phrase_List.SearchUsingPhraseId(aSuggestion^.smPhraseId, PhraseIndex) then
  begin
    MatchedPhrase := aBankAccount.baSuggested_Phrase_List.GetPRec(PhraseIndex)^.spPhrase;
    MatchedPhrase := GetSuggestionMatchText(MatchedPhrase, aSuggestion^.smStart_Data, aSuggestion^.smEnd_Data);

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
function TSuggestedMems.IsSuggestionInIgnoreList(aBankAccount: TBank_Account; aSuggestion: pSuggested_Mem_Rec): boolean;
const
  IGNORE_LIST : Array[1..3] of string =
    ('and','the','ltd');
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
            LogDoneProcessing(fTempNoMoreRecord);
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
procedure TSuggestedMems.NewClientMainState;
begin
  fMainState := mtsScan;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ProcessTransaction(aBankAccount : TBank_Account; aTrans : pTransaction_Rec);
var
  TranNewState : byte;
begin
  if MainState = mtsNoScan then
    Exit;

  if (aTrans^.txCoded_By in ManualCodedBy) then
    TranNewState := tssManualScanned
  else
    TranNewState := tssUnCodedScaned;

  SearchForMatchedPhrase(aBankAccount, aTrans, TranNewState);

  SetSuggestedTransactionState(aBankAccount, aTrans, TranNewState);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SearchForMatchedPhrase(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aTranNewState : byte);
var
  TranIndex : integer;
  TranRec : pTransaction_Rec;
  CurrentTranSuggestions : TArrSuggPointers;
  StartData : boolean;
  FoundLCS  : string;
  EndData   : boolean;
  SearchTranDetailsLength : integer;
  MatchTranDetailLength : integer;
  RunMems2 : boolean;
  Date_Effective : integer;
  Days, Months, Years : Integer;
begin
  SearchTranDetailsLength := length(aTrans^.txStatement_Details);
  if SearchTranDetailsLength < 3 then
    Exit;

  if (aBankAccount.baTransaction_List.ItemCount > 0) then
  begin
    Date_Effective := aBankAccount.baTransaction_List.Transaction_At(0)^.txDate_Effective;
    DateDiff(Date_Effective, CurrentDate, Days, Months, Years);
  end
  else
  begin
    Days := 0;
    Months := 0;
    Years := 0;
  end;

  RunMems2 := true;
  // Disable Mems v2 when there are less than 150 transactions AND the oldest transaction is less than 3 months ago
  if (aBankAccount.baTransaction_List.ItemCount < 150) and (Years = 0) and (Months < 3) then
    RunMems2 := false;

  if Mainstate = mtsMems2NoScan then
    RunMems2 := false;

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

    if (aTrans^.txCoded_By <= cbManual) or (aTrans^.txCoded_By = cbECodingManual) then
    begin
      if (SearchTranDetailsLength = MatchTranDetailLength) and
        (CompareText(aTrans^.txStatement_Details, TranRec^.txStatement_Details) = 0) then
      begin
        // Mems 1
        SearchFoundMatch(false, aTrans^.txStatement_Details, false, aBankAccount, aTrans, TranRec, CurrentTranSuggestions, aTranNewState);
      end
      else
      begin
        // Mems 2
        if RunMems2 then
          if FindLCS(Uppercase(aTrans^.txStatement_Details), Uppercase(TranRec^.txStatement_Details), StartData, FoundLCS, EndData) then
            SearchFoundMatch(StartData, FoundLCS, EndData, aBankAccount, aTrans, TranRec, CurrentTranSuggestions, aTranNewState);
      end;
    end;
  end;

  SetLength(CurrentTranSuggestions,0);
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
procedure TSuggestedMems.SetSuggestedTransactionState(aBankAccount : TBank_Account; aTrans : pTransaction_Rec; aState : byte; aAccountChanged : boolean; aIsBulk : boolean);
var
  OldState : byte;
  AccLinkUpdated : boolean;
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
    aTrans^.txSuggested_Mem_State := aState;

    if ((aTrans^.txCoded_By > cbManual) and (aTrans^.txCoded_By < cbECodingManual)) or
       ((aTrans^.txCoded_By > cbECodingManual)) then
      aTrans^.txSuggested_Mem_State := tssExcluded;

    if (aTrans^.txSuggested_Mem_State = tssUnScanned) then
    begin
      if (OldState in tssScanned) then
      begin
        AccLinkUpdated := false;
        if aAccountChanged then
          AccLinkUpdated := UpdateSuggestionAccountAndLinks(aBankAccount, aTrans);

        if aAccountChanged then
        begin
          aTrans^.txSuggested_Mem_State := OldState;

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
procedure TSuggestedMems.UpdateAccountWithTransDelete(aBankAccount: TBank_Account; aTrans: pTransaction_Rec);
begin
  if MainState = mtsNoScan then
    Exit;

  if aBankAccount.IsAJournalAccount then
    Exit;

  StopMemScan();
  try
    DeleteLinksAndSuggestions(aBankAccount, aTrans, aTrans^.txSuggested_Mem_State);

    if DebugMe then
      LogDoneProcessing(true);

    if Assigned(fDoneProcessingEvent) then
      fDoneProcessingEvent();

  finally
    StartMemScan();
  end;

  {if aBankAccount.baFields.baSuggested_UnProcessed_Count > 0 then
    Dec(aBankAccount.baFields.baSuggested_UnProcessed_Count);}
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
procedure TSuggestedMems.DoProcessingComplete;
begin
  if DebugMe then
    LogDoneProcessing(true);

  if Assigned(fDoneProcessingEvent) then
    fDoneProcessingEvent();
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.SetMainState();
begin
  case MEMSINI_SupportOptions of
    meiDisableSuggestedMemsAll : fMainState := mtsNoScan;
    meiResetMems               : fMainState := mtsScan;
    meiDisableSuggestedMemsv2  : fMainState := mtsMems2NoScan;
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

        if ((TranRec^.txCoded_By > cbManual) and (TranRec^.txCoded_By < cbECodingManual)) or
         ((TranRec^.txCoded_By > cbECodingManual)) then
        begin
          TranRec^.txSuggested_Mem_State := tssExcluded;
          Continue;
        end;

        TranRec^.txSuggested_Mem_State := tssUnScanned;
        inc(BankAccount.baFields.baSuggested_UnProcessed_Count);
      end;

      BankAccount.baTran_Suggested_Link_List.DeleteFreeAll();
      BankAccount.baSuggested_Mem_List.DeleteFreeAll();
      BankAccount.baSuggested_Account_List.DeleteFreeAll();
      BankAccount.baSuggested_Account_Link_List.DeleteFreeAll();
      BankAccount.baSuggested_Phrase_List.DeleteFreeAll();
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMems.ResetLogging(aClient: TClientObj);
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
function TSuggestedMems.GetSuggestedMemsCount(aBankAccount : TBank_Account; aChart : TChart) : integer;
var
  SuggestedMemIndex : integer;
  SuggestedId : integer;
  LowAccountIndex : integer;
  HighAccountIndex : integer;
  AccountLinkIndex : integer;
  ManualCount : integer;
  ManualAccountCount : integer;
  HasDissectedTran : boolean;
  AccountId : integer;
  AccountIndex : integer;
  AccountCode : string;
  Account_Rec : pAccount_Rec;
begin
  Result := 0;

  if not NoMoreRecord then
    Exit;

  StopMemScan();
  try
    for SuggestedMemIndex := 0 to aBankAccount.baSuggested_Mem_List.ItemCount - 1 do
    begin
      SuggestedId := aBankAccount.baSuggested_Mem_List.GetPRec(SuggestedMemIndex)^.smId;

      if IsSuggestionInIgnoreList(aBankAccount, aBankAccount.baSuggested_Mem_List.GetPRec(SuggestedMemIndex)) then
        Continue;

      ManualCount := 0;
      ManualAccountCount := 0;
      HasDissectedTran := false;

      if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedId(SuggestedId, LowAccountIndex, HighAccountIndex) then
      begin
        for AccountLinkIndex := LowAccountIndex to HighAccountIndex do
        begin
          if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slIsDissected then
            HasDissectedTran := true;

          if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slIsUncoded then
            Continue;

          AccountId := aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slAccountId;
          if aBankAccount.baSuggested_Account_List.SearchUsingAccountId(AccountId, AccountIndex) then
          begin
            AccountCode := aBankAccount.baSuggested_Account_List.GetPRec(AccountIndex)^.saAccount;
            Account_Rec := aChart.FindCode(AccountCode);
            if not Assigned(Account_Rec) then
              Continue;

            if Account_Rec^.chInactive then
              Continue;
          end;

          inc(ManualAccountCount);
          ManualCount := ManualCount + aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slCount;
        end;
      end;

      if (ManualAccountCount = 1) and (ManualCount > 2) and (not HasDissectedTran) then
      begin
        if not IsSuggestionUsedByMem(aBankAccount,
                                     aBankAccount.baSuggested_Mem_List.GetPRec(SuggestedMemIndex)) then
          inc(Result);
      end;
    end;
  finally
    StartMemScan();
  end;
end;

//------------------------------------------------------------------------------
function TSuggestedMems.GetSuggestedMems(aBankAccount: TBank_Account; aChart : TChart): TSuggestedMemsArr;
var
  SuggestedMemIndex : integer;
  SuggestedId : integer;
  LowAccountIndex : integer;
  HighAccountIndex : integer;
  AccountLinkIndex : integer;
  ManualCount : integer;
  TotalCount : integer;
  ManualAccountCount : integer;
  CurrIndex : integer;
  Suggestion: pSuggested_Mem_Rec;
  PhraseIndex : integer;
  MatchedPhrase : string;
  SearchAccountIndex : integer;
  SearchAccountId : integer;
  HasDissectedTran : boolean;

  AccountId : integer;
  AccountIndex : integer;
  AccountCode : string;
  Account_Rec : pAccount_Rec;
begin
  Result := nil;

  if not NoMoreRecord then
    Exit;

  StopMemScan();
  try
    for SuggestedMemIndex := 0 to aBankAccount.baSuggested_Mem_List.ItemCount - 1 do
    begin
      Suggestion := aBankAccount.baSuggested_Mem_List.GetPRec(SuggestedMemIndex);
      SuggestedId := Suggestion^.smId;

      if IsSuggestionInIgnoreList(aBankAccount, aBankAccount.baSuggested_Mem_List.GetPRec(SuggestedMemIndex)) then
        Continue;

      ManualCount := 0;
      ManualAccountCount := 0;
      TotalCount := 0;
      SearchAccountId := -1;
      HasDissectedTran := false;

      if aBankAccount.baSuggested_Account_Link_List.SearchUsingSuggestedId(SuggestedId, LowAccountIndex, HighAccountIndex) then
      begin
        for AccountLinkIndex := LowAccountIndex to HighAccountIndex do
        begin
          if aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slIsDissected then
            HasDissectedTran := true;

          if not aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slIsUncoded then
          begin
            AccountId := aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slAccountId;
            if aBankAccount.baSuggested_Account_List.SearchUsingAccountId(AccountId, AccountIndex) then
            begin
              AccountCode := aBankAccount.baSuggested_Account_List.GetPRec(AccountIndex)^.saAccount;
              Account_Rec := aChart.FindCode(AccountCode);
              if Assigned(Account_Rec) then
              begin
                if not Account_Rec^.chInactive then
                begin
                  inc(ManualAccountCount);
                  ManualCount := ManualCount + aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slCount;
                  SearchAccountId := aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slAccountId;
                end;
              end;
            end;
          end;
          TotalCount := TotalCount + aBankAccount.baSuggested_Account_Link_List.GetPRec(AccountLinkIndex)^.slCount;
        end;
      end;

      if (ManualAccountCount = 1) and (ManualCount > 2) and (not HasDissectedTran) then
      begin
        if not IsSuggestionUsedByMem(aBankAccount, Suggestion) then
        begin
          if aBankAccount.baSuggested_Phrase_List.SearchUsingPhraseId(Suggestion^.smPhraseId, PhraseIndex) then
          begin
            if (SearchAccountId > -1) and
               (aBankAccount.baSuggested_Account_List.SearchUsingAccountId(SearchAccountId, SearchAccountIndex)) then
            begin
              MatchedPhrase := aBankAccount.baSuggested_Phrase_List.GetPRec(PhraseIndex)^.spPhrase;
              MatchedPhrase := GetSuggestionMatchText(MatchedPhrase, Suggestion^.smStart_Data, Suggestion^.smEnd_Data);

              CurrIndex := length(Result);
              setlength(Result, CurrIndex + 1);

              Result[CurrIndex].smId   := SuggestedId;
              Result[CurrIndex].smType := Suggestion^.smTypeId;
              Result[CurrIndex].smMatchedPhrase := MatchedPhrase;
              Result[CurrIndex].smAccount := aBankAccount.baSuggested_Account_List.GetPRec(SearchAccountIndex)^.saAccount;
              Result[CurrIndex].smTotalCount := TotalCount;
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
function TSuggestedMems.DetermineStatus(aBankAccount : TBank_Account; aChart : TChart): string;
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
    AccountHasRecMems := (GetSuggestedMemsCount(aBankAccount, aChart) > 0);

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
