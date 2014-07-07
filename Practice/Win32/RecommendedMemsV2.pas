unit RecommendedMemsV2;

interface

uses
  Classes,
  SysUtils,

  utObj32,
  utList32,
  cpObj32,
  cmObj32,
  cmList32,
  rmObj32,
  rmList32,
  ECollect,

  LogUtil;

type
  {-----------------------------------------------------------------------------
    TLCS
  -----------------------------------------------------------------------------}
  TLCS = class(TObject)
  private
    fStartData: boolean;
    fDetails: string;
    fEndData: boolean;

  public
    procedure Assign(const aFrom: TLCS);

    function  HasStartOrEnd: boolean;

    function  Compare(const aOther: TLCS): boolean;

    function  ToString: string;

    procedure SetData(const aStartData: boolean; const aDetails: string;
                const aEndData: boolean);

    property  StartData: boolean read fStartData write fStartData;
    property  Details: string read fDetails write fDetails;
    property  EndData: boolean read fEndData write fEndData;
  end;


  {-----------------------------------------------------------------------------
    TCandidateString
  -----------------------------------------------------------------------------}
  TCandidateString = class(TObject)
  private
    fBankAccountNumber: string;
    fAccount: string;
    fEntryType: byte;
    fLCS: TLCS;

  public
    constructor Create;
    destructor  Destroy; override;

    procedure Assign(const aFrom: TCandidateString);
    function  Copy: TCandidateString;

    function  Compare(const aOther: TCandidateString): boolean;

    property  BankAccountNumber: string read fBankAccountNumber
                write fBankAccountNumber;
    property  Account: string read fAccount write fAccount;
    property  EntryType: byte read fEntryType write fEntryType;
    property  LCS: TLCS read fLCS;
  end;


  {-----------------------------------------------------------------------------
    TCandidateStringlist
  -----------------------------------------------------------------------------}
  TCandidateStringList = class(TList)
  public
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

    procedure Assign(const aFrom: TCandidateStringList);

    function  Compare(const aOther: TCandidateStringList): boolean;

    function  FindDuplicate(const aBankAccountNumber: string; 
                const aAccount: string; const aEntryType: byte; 
                const aDetails: string): boolean;

    function  FindLCS(const aStartData: boolean; const aDetails: string;
                const aEndData: boolean): boolean; overload;
    function  FindLCS(const aLCS: TLCS): boolean; overload;

    function  FindString(const aValue: TCandidateString): boolean;

    function  GetString(const aIndex: integer): TCandidateString;
    property  Strings[const aIndex: integer]: TCandidateString read GetString;
                default;

    procedure AddOrMerge(const aValue: TCandidateString);

    procedure CopyRelevantLCSTo(const aOther: TCandidateStringList);

    procedure LogData;
  end;


  {-----------------------------------------------------------------------------
    TCandidateStringTreeItem
  -----------------------------------------------------------------------------}
  TCandidateStringTreeItem = class(TObject)
  private
    fEntryType: byte;
    fCandidateStrings: TCandidateStringList;

  public
    constructor Create(const aFrom: TCandidateString);
    destructor  Destroy; override;

  public
    property  EntryType: byte read fEntryType;
    property  CandidateStrings: TCandidateStringList read fCandidateStrings;
  
  end;


  {-----------------------------------------------------------------------------
    TCandidateStringTree
  -----------------------------------------------------------------------------}
  TCandidateStringTree = class(TList)
  public
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

    function  GetTreeItem(const aIndex: integer): TCandidateStringTreeItem;
    property  TreeItems[const aIndex: integer]: TCandidateStringTreeItem 
                read GetTreeItem; default;

    function  IndexOf(const aValue: TCandidateString): integer;
                
    procedure AddOrMerge(const aValue: TCandidateString);

    procedure CopyRelevantLCSTo(const aOther: TCandidateStringList);
  end;


  {-----------------------------------------------------------------------------
    TCandidateGroup
  -----------------------------------------------------------------------------}
  TCandidateGroup = class
  private
    fBankAccountNumber: string;
    fAccount: string;
    fEntryType: byte;

    // Do NOT FreeAndNil Items from here, because they are owned by another class
    fCandidates: TList;

  public
    constructor Create(const aBankAccountNumber: string; const aAccount: string;
                  const aEntryType: byte);
    destructor  Destroy; override;

    property  BankAccountNumber: string read fBankAccountNumber;
    property  Account: string read fAccount;
    property  EntryType: byte read fEntryType;

    procedure Add(const aCandidate: TCandidate_Mem);

    procedure DetermineLCS(const aCandidateStrings: TCandidateStringList);
  end;


  {-----------------------------------------------------------------------------
    TCandidateGroupList
  -----------------------------------------------------------------------------}
  TCandidateGroupList = class(TList)
  public
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;

    function  Find(const aBankAccountNumber: string; const aAccount: string;
                const aEntryType: byte; var aIndex: integer): boolean;

    procedure LogData;
  end;


  {-----------------------------------------------------------------------------
    TMemsV2
  -----------------------------------------------------------------------------}
  TMemsV2 = class(TObject)
  private
    // Note: place holders, do not delete
    fCandidates: TCandidate_Mem_List;
    fRecommended: TRecommended_Mem_List;

    fGroups: TCandidateGroupList;
    fCandidateStrings: TCandidateStringList;
    fRefinementStrings: TCandidateStringList;

  public
    constructor Create(const aCandidates: TCandidate_Mem_List;
                  const aRecommended: TRecommended_Mem_List);
    destructor  Destroy; override;

    // Run functions
    function  AllowedToRun: boolean;
    procedure Run;

  private
    // Main functions for getting candidate strings
    procedure GetAccountsFromCandidates;
    procedure GetCandidateStrings;
    procedure EliminateCandidateStrings;
    function  RefineCandidateStrings: boolean;
    procedure AddCandidateStringsToRecommended;

    // Additional helper functions
    function  MoreThanOneAccount(const aDetails: string;
                var aAccount: string): boolean;
    function  LessThanMinimumCount(const aDetails: string): boolean;
    function  FindRecommended(const aRecommended: TRecommended_Mem): boolean;

  public
    property  Candidates: TCandidate_Mem_List read fCandidates;
    property  Recommended: TRecommended_Mem_List read fRecommended;
  end;


  {-----------------------------------------------------------------------------
    LCS
  -----------------------------------------------------------------------------}
  function  FindLCS(const aFirst: string; const aSecond: string;
              var aStartData: boolean; var aDetails: string;
              var aEndData: boolean): boolean;

  function  LongestCommonSubstring(const AFirst, ASecond: String): string;

  function  FindLCSInLCS(const aLCS1: TLCS; const aLCS2: TLCS;
              var aStartData: boolean; var aDetails: string;
              var aEndData: boolean): boolean;


  {-----------------------------------------------------------------------------
    RunMemsV2
  -----------------------------------------------------------------------------}
  procedure RunMemsV2(const aCandidates: TCandidate_Mem_List;
              const aRecommended: TRecommended_Mem_List);


type
  {-----------------------------------------------------------------------------
    Logging
  -----------------------------------------------------------------------------}
  TLogMethod = procedure(const aMsg: string) of object;

  procedure SetLog(const aLogMethod: TLogMethod);


implementation

uses
  Math,
  bkConst,
  StDate,
  Globals,
  baObj32,
  BKDEFS,
  Windows,
  MMSystem,
  Controls,
  Forms;

{-------------------------------------------------------------------------------
  Logging
-------------------------------------------------------------------------------}
const
  UnitName = 'RecommendedMemsV2';
var
  DebugMe: boolean;
  u_Log: TLogMethod;

//------------------------------------------------------------------------------
procedure SetLog(const aLogMethod: TLogMethod);
begin
  u_Log := aLogMethod;

  DebugMe := true;
end;

//------------------------------------------------------------------------------
procedure Log(const aMsg: string);
begin
  if assigned(u_Log) then
    u_Log(aMsg)
  else
    LogUtil.LogMsg(lmDebug, UnitName, aMsg);
end;


{-------------------------------------------------------------------------------
  TLCS
-------------------------------------------------------------------------------}
function FindLCSInLCS(const aLCS1: TLCS; const aLCS2: TLCS;
  var aStartData: boolean; var aDetails: string; var aEndData: boolean
  ): boolean;
begin
  result := FindLCS(aLCS1.Details, aLCS2.Details, aStartData,
    aDetails, aEndData);

  if not result then
    exit;

  // Keep wildcards intact
  aStartData := (aStartData or aLCS1.StartData or aLCS2.StartData);
  aEndData := (aEndData or aLCS1.EndData or aLCS2.EndData);
end;


{-------------------------------------------------------------------------------
  TLCS
-------------------------------------------------------------------------------}
procedure TLCS.Assign(const aFrom: TLCS);
begin
  // Copy fields
  fStartData := aFrom.fStartData;
  fDetails := aFrom.fDetails;
  fEndData := aFrom.fEndData;
end;

//------------------------------------------------------------------------------
function TLCS.HasStartOrEnd: boolean;
begin
  result := (fStartData or fEndData);
end;

//------------------------------------------------------------------------------
function TLCS.Compare(const aOther: TLCS): boolean;
begin
  result :=
    (StartData = aOther.StartData) and
    (Details = aOther.Details) and
    (EndData = aOther.EndData);
end;

//------------------------------------------------------------------------------
function TLCS.ToString: string;
begin
  result := '';

  if fStartData then
    result := result + '*';

  result := result + fDetails;

  if fEndData then
    result := result + '*';
end;

//------------------------------------------------------------------------------
procedure TLCS.SetData(const aStartData: boolean; const aDetails: string;
  const aEndData: boolean);
begin
  fStartData := aStartData;
  fDetails := aDetails;
  fEndData := aEndData;
end;


{-------------------------------------------------------------------------------
  TCandidateString
-------------------------------------------------------------------------------}
constructor TCandidateString.Create;
begin
  inherited;

  fLCS := TLCS.Create;
end;

//------------------------------------------------------------------------------
destructor TCandidateString.Destroy;
begin
  FreeAndNil(fLCS);

  inherited; // LAST
end;

//------------------------------------------------------------------------------
procedure TCandidateString.Assign(const aFrom: TCandidateString);
begin
  fBankAccountNumber := aFrom.fBankAccountNumber;
  fAccount := aFrom.fAccount;
  fEntryType := aFrom.fEntryType;
  fLCS.Assign(aFrom.LCS);
end;

//------------------------------------------------------------------------------
function TCandidateString.Copy: TCandidateString;
begin
  result := TCandidateString.Create;
  result.Assign(self);
end;

//------------------------------------------------------------------------------
function TCandidateString.Compare(const aOther: TCandidateString): boolean;
begin
  result :=
    (BankAccountNumber = aOther.BankAccountNumber) and
    (Account = aOther.Account) and
    (EntryType = aOther.EntryType) and
    LCS.Compare(aOther.LCS);
end;


{-------------------------------------------------------------------------------
  TCandidateStringList
-------------------------------------------------------------------------------}
procedure TCandidateStringList.Notify(Ptr: Pointer; Action: TListNotification);
var
  varDelete: TObject;
begin
  inherited;

  if (Action <> lnDeleted) then
    exit;

  varDelete := TObject(Ptr);
  FreeAndNil(varDelete);
end;

//------------------------------------------------------------------------------
procedure TCandidateStringList.Assign(const aFrom: TCandidateStringList);
var
  i: integer;
  Source: TCandidateString;
  Copy: TCandidateString;
begin
  ASSERT(assigned(aFrom));

  Clear;

  for i := 0 to aFrom.Count-1 do
  begin
    Source := aFrom[i];

    Copy := Source.Copy;

    Add(Copy);
  end;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.Compare(const aOther: TCandidateStringList
  ): boolean;
var
  i: integer;
  Candidate: TCandidateString;
begin
  if (Count <> aOther.Count) then
  begin
    result := false;
    exit;
  end;

  // Note: Compare both ways, e.g. ABCD and DCBA are similar arrays

  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);
    if not aOther.FindLCS(Candidate.LCS) then
    begin
      result := false;
      exit;
    end;
  end;

  for i := 0 to aOther.Count-1 do
  begin
    Candidate := aOther[i];
    if not FindLCS(Candidate.LCS) then
    begin
      result := false;
      exit;
    end;
  end;

  result := true;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.FindString(const aValue: TCandidateString
  ): boolean;
var
  i: integer;
  Candidate: TCandidateString;
begin
  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);

    // Match?
    if Candidate.Compare(aValue) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.FindDuplicate(const aBankAccountNumber: string; 
  const aAccount: string; const aEntryType: byte; const aDetails: string
  ): boolean;
var
  i: integer;
  CandidateString: TCandidateString;
begin
  for i := 0 to Count-1 do
  begin
    CandidateString := Items[i];

    // Duplicate?
    if (CandidateString.BankAccountNumber = aBankAccountNumber) and
       (CandidateString.Account = aAccount) and
       (CandidateString.EntryType = aEntryType) and
       (CandidateString.LCS.Details = aDetails) then
    begin
      result := true;

      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.FindLCS(const aStartData: boolean;
  const aDetails: string; const aEndData: boolean): boolean;
var
  i: integer;
  CandidateString: TCandidateString;
begin
  for i := 0 to Count-1 do
  begin
    CandidateString := GetString(i);
    if (CandidateString.LCS.StartData = aStartData) and
       (CandidateString.LCS.Details = aDetails) and
       (CandidateString.LCS.EndData = aEndData) then
    begin
      result := true;

      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TCandidateStringList.FindLCS(const aLCS: TLCS): boolean;
begin
  result := FindLCS(aLCS.StartData, aLCS.Details, aLCS.EndData);
end;

//------------------------------------------------------------------------------
function TCandidateStringList.GetString(const aIndex: integer): TCandidateString;
begin
  result := TCandidateString(Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TCandidateStringList.AddOrMerge(const aValue: TCandidateString);
var
  i: integer;
  Candidate: TCandidateString;
begin
  // Note: At this point we're the owner of aValue

  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);

    // BankAccountNumber different?
    if (Candidate.BankAccountNumber <> aValue.BankAccountNumber) then
      continue;
    
    // Note: no need to check the Account Code here (during refinement that is)

    // EntryType different?
    if (Candidate.EntryType <> aValue.EntryType) then
      continue;
    
    // Different Details?
    if (Candidate.LCS.Details <> aValue.LCS.Details) then
      continue;

    // Merge the wildcards
    Candidate.LCS.StartData := (Candidate.LCS.StartData or aValue.LCS.StartData);
    Candidate.LCS.EndData := (Candidate.LCS.EndData or aValue.LCS.EndData);

    // We've merged the two candidate strings, so we have to delete this one
    aValue.Free;

    // Stop searching
    exit;
  end;

  if DebugMe then
    Log('Add: ' + aValue.LCS.ToString + ', ' + IntToStr(Integer(self)));

  // New entry
  Add(aValue);
end;

//------------------------------------------------------------------------------
procedure TCandidateStringList.CopyRelevantLCSTo(
  const aOther: TCandidateStringList);
var
  i: integer;
  iLowest: integer;
  Candidate: TCandidateString;
  iLength: integer;
  New: TCandidateString;
begin
  iLowest := MaxInt;

  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);
    iLength := Length(Candidate.LCS.Details);
    iLowest := Min(iLowest, iLength);
  end;

  for i := 0 to Count-1 do
  begin
    Candidate := GetString(i);
    iLength := Length(Candidate.LCS.Details);

    // Not the highest?
    if (iLength <> iLowest) then
      continue;

    // Add
    New := Candidate.Copy;
    aOther.AddOrMerge(New);
  end;
end;

//------------------------------------------------------------------------------
procedure TCandidateStringList.LogData;
var
  i: integer;
  CandidateString: TCandidateString;
  sAccount: string;
  sEntryType: string;
begin
  if not DebugMe then
    exit;

  Log('');
  Log('Candidate Strings:');

  for i := 0 to Count-1 do
  begin
    CandidateString := GetString(i);

    if (CandidateString.Account = '') then
      sAccount := 'Uncharted'
    else
      sAccount := CandidateString.Account;

    sEntryType := IntToStr(CandidateString.EntryType);

    Log(sAccount + '/' + sEntryType + ': ' + CandidateString.LCS.ToString);
  end;
end;


{-------------------------------------------------------------------------------
  TCandidateStringTreeItem
-------------------------------------------------------------------------------}
constructor TCandidateStringTreeItem.Create(const aFrom: TCandidateString);
begin
  fEntryType := aFrom.EntryType;
  fCandidateStrings := TCandidateStringList.Create;
end;

//------------------------------------------------------------------------------
destructor TCandidateStringTreeItem.Destroy;
begin
  FreeAndNil(fCandidateStrings);
  
  inherited;
end;


{-------------------------------------------------------------------------------
  TCandidateStringTree
-------------------------------------------------------------------------------}
procedure TCandidateStringTree.Notify(Ptr: Pointer; Action: TListNotification);
var
  varDelete: TObject;
begin
  inherited;

  if (Action <> lnDeleted) then
    exit;

  varDelete := TObject(Ptr);
  FreeAndNil(varDelete);
end;

//------------------------------------------------------------------------------
function TCandidateStringTree.GetTreeItem(const aIndex: integer
  ): TCandidateStringTreeItem;
begin
  result := TCandidateStringTreeItem(Items[aIndex]);
end;

//------------------------------------------------------------------------------
function TCandidateStringTree.IndexOf(const aValue: TCandidateString): integer;
var
  i: integer;
  TreeItem: TCandidateStringTreeItem;
begin
  for i := 0 to Count-1 do
  begin
    TreeItem := TreeItems[i];

    // Found?
    if (TreeItem.EntryType = aValue.EntryType) then
    begin
      result := i;

      exit;
    end;
  end;

  result := -1;
end;

//------------------------------------------------------------------------------
procedure TCandidateStringTree.AddOrMerge(const aValue: TCandidateString);
var
  iIndex: integer;
  TreeItem: TCandidateStringTreeItem;
begin
  iIndex := IndexOf(aValue);

  // New?
  if (iIndex = -1) then
  begin
    TreeItem := TCandidateStringTreeItem.Create(aValue);
    Add(TreeItem);
  end
  else
    TreeItem := TreeItems[iIndex];

  TreeItem.CandidateStrings.AddOrMerge(aValue);
end;

//------------------------------------------------------------------------------
procedure TCandidateStringTree.CopyRelevantLCSTo(
  const aOther: TCandidateStringList);
var
  i: integer;
  TreeItem: TCandidateStringTreeItem;
begin
  for i := 0 to Count-1 do
  begin
    TreeItem := TreeItems[i];

    TreeItem.CandidateStrings.CopyRelevantLCSTo(aOther);
  end;
end;


{-------------------------------------------------------------------------------
  TCandidateGroup
-------------------------------------------------------------------------------}
constructor TCandidateGroup.Create(const aBankAccountNumber: string;
  const aAccount: string; const aEntryType: byte);
begin
  fBankAccountNumber := aBankAccountNumber;
  fAccount := aAccount;
  fEntryType := aEntryType;

  fCandidates := TList.Create;
end;

//------------------------------------------------------------------------------
destructor TCandidateGroup.Destroy;
begin
  FreeAndNil(fCandidates);

  inherited; // LAST
end;

//------------------------------------------------------------------------------
procedure TCandidateGroup.Add(const aCandidate: TCandidate_Mem);
begin
  ASSERT(assigned(aCandidate));

  fCandidates.Add(aCandidate);
end;

//------------------------------------------------------------------------------
procedure TCandidateGroup.DetermineLCS(const aCandidateStrings: TCandidateStringList);
const
  MANUAL = [cbManual, cbManualPayee, cbECodingManual, cbECodingManualPayee, cbManualSuper];
  AUTOMATIC = [cbMemorisedC, cbAnalysis, cbAutoPayee, cbMemorisedM, cbCodeIT];
  MANUAL_AUTOMATIC = MANUAL + AUTOMATIC;
var
  iRow: integer;
  iRowOther: integer;

  Candidate: TCandidate_Mem;
  CandidateOther: TCandidate_Mem;

  bStartData: boolean;
  sDetails: string;
  bEndData: boolean;

  New: TCandidateString;
begin
  for iRow := 0 to fCandidates.Count-1 do
  begin
    for iRowOther := 0 to fCandidates.Count-1 do
    begin
      // Same row?
      if (iRow = iRowOther) then
        continue;

      Candidate := TCandidate_Mem(fCandidates[iRow]);
      CandidateOther := TCandidate_Mem(fCandidates[iRowOther]);

      // Not same Bank Account Number
      if (Candidate.cmFields.cmBank_Account_Number <> CandidateOther.cmFields.cmBank_Account_Number) then
        continue;

      // Not same Account Code?
      if (Candidate.cmFields.cmAccount <> CandidateOther.cmFields.cmAccount) then
        continue;

      // Not same entry type?
      if (Candidate.cmFields.cmType <> CandidateOther.cmFields.cmType) then
        continue;

      { Not manual?
        Note: no need to check the account code because it's already done in
        obtaining the accounts list.
      }
      if not (Candidate.cmFields.cmCoded_By in MANUAL) then
        continue;

      // Not auto or manual?
      if not (CandidateOther.cmFields.cmCoded_By in MANUAL_AUTOMATIC) then
        continue;

      // Can't find longest string?
      if not FindLCS(Candidate.cmFields.cmStatement_Details,
        CandidateOther.cmFields.cmStatement_Details, bStartData, sDetails,
        bEndData) then
      begin
        continue;
      end;

      // No start or end tag?
      if not (bStartData or bEndData) then
        continue;

      // Not a valid Details?
      sDetails := Trim(sDetails);
      if (sDetails = '') then
        continue;

      // Duplicate Details?
      if aCandidateStrings.FindDuplicate(BankAccountNumber, Account, EntryType, 
        sDetails) then
      begin
        continue;
      end;

      // Create new candidate string
      New := TCandidateString.Create;
      New.fBankAccountNumber := BankAccountNumber;
      New.Account := Account;
      New.EntryType := EntryType;
      New.LCS.SetData(bStartData, sDetails, bEndData);

      // Add
      aCandidateStrings.Add(New);
    end;
  end;
end;


{-------------------------------------------------------------------------------
  TCandidateGroupList
-------------------------------------------------------------------------------}
procedure TCandidateGroupList.Notify(Ptr: Pointer; Action: TListNotification);
var
  varDelete: TCandidateGroup;
begin
  inherited;

  if (Action <> lnDeleted) then
    exit;

  varDelete := TCandidateGroup(Ptr);
  FreeAndNil(varDelete);
end;

//------------------------------------------------------------------------------
function TCandidateGroupList.Find(const aBankAccountNumber: string;
  const aAccount: string; const aEntryType: byte; var aIndex: integer): boolean;
var
  i: integer;
  varAccount: TCandidateGroup;
begin
  for i := 0 to Count-1 do
  begin
    varAccount := Items[i];

    // Match?
    if (varAccount.BankAccountNumber = aBankAccountNumber) and
       (varAccount.Account = aAccount) and
       (varAccount.EntryType = aEntryType) then
    begin
      result := true;
      aIndex := i;
      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
procedure TCandidateGroupList.LogData;
var
  i: integer;
  Group: TCandidateGroup;
begin
  if not DebugMe then
    exit;

  Log('BankAccountNumber/Account/EntryType groups:');

  for i := 0 to Count-1 do
  begin
    Group := TCandidateGroup(Get(i));

    Log(Group.BankAccountNumber + '/' + Group.Account + '/' + IntToStr(Group.EntryType));
  end;
end;


{-------------------------------------------------------------------------------
  TMemsV2
-------------------------------------------------------------------------------}
constructor TMemsV2.Create(const aCandidates: TCandidate_Mem_List;
  const aRecommended: TRecommended_Mem_List);
begin
  ASSERT(assigned(aCandidates));
  ASSERT(assigned(aRecommended));

  fCandidates := aCandidates;
  fRecommended := aRecommended;

  fGroups := TCandidateGroupList.Create;
  fCandidateStrings := TCandidateStringList.Create;
  fRefinementStrings := TCandidateStringList.Create;
end;

//------------------------------------------------------------------------------
destructor TMemsV2.Destroy;
begin
  FreeAndNil(fGroups);
  FreeAndNil(fCandidateStrings);
  FreeAndNil(fRefinementStrings);

  inherited; // LAST
end;

var
  u_CandidatesCount: integer = -1;

//------------------------------------------------------------------------------
function TMemsV2.AllowedToRun: boolean;
const
  MIN_MONTHS = 3;
  MIN_TRANSACTIONS = 150;
var
  dtMonthsAgo: TStDate;
  iCount: integer;
  iBank: integer;
  BankAccount: TBank_Account;
  iTrans: integer;
  Transaction: pTransaction_Rec;
begin
  { Nothing to do?
    Note: RunMemsV2 gets called quite often, so this is a way to exit early
    if there's nothing to do. }
  if (Candidates.ItemCount = u_CandidatesCount) then
  begin
    result := false;
    exit;
  end
  else
    u_CandidatesCount := Candidates.ItemCount;

  // Init
  dtMonthsAgo := IncDate(CurrentDate, 0, MIN_MONTHS, 0);
  iCount := 0;

  // Search transactions for criteria
  for iBank := 0 to MyClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := MyClient.clBank_Account_List.Bank_Account_At(iBank);

    for iTrans := 0 to BankAccount.baTransaction_List.ItemCount-1 do
    begin
      Transaction := BankAccount.baTransaction_List.Transaction_At(iTrans);

      // Transaction date older than three months?
      if (Transaction.txDate_Effective < dtMonthsAgo) then
      begin
        result := true;
        exit;
      end;

      // More than 150 transactions?
      Inc(iCount);
      if (iCount >= MIN_TRANSACTIONS) then
      begin
        result := true;
        exit;
      end;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
procedure TMemsV2.Run;
const
  MAX_ITERATION = 10;
var
  iIteration: integer;
begin
  GetAccountsFromCandidates;
  if DebugMe then
    fGroups.LogData;

  GetCandidateStrings;
  if DebugMe then
    fCandidateStrings.LogData;

  // Iterate over Eliminate and Refine
  for iIteration := 1 to MAX_ITERATION do
  begin
    if DebugMe then
    begin
      Log('');
      Log('ITERATION: ' + IntToStr(iIteration));
      fCandidateStrings.LogData;
    end;

    EliminateCandidateStrings;

    { Last iteration?
      Note: we don't run RefineCandidateStrings on the last iteration, because
      it will wipe out the Account Codes if it has new values.
    }
    if (iIteration = MAX_ITERATION) then
      break;

    // Candidate strings are the same after refining?
    if not RefineCandidateStrings then
    begin
      if DebugMe then
      begin
        Log('');
        Log('Candidates after refinement are identical');
      end;

      break;
    end;
  end;

  if DebugMe then
  begin
    Log('');
    Log('FINAL RESULT:');
    fCandidateStrings.LogData;
  end;

  // Add final result to recommended mems
  AddCandidateStringsToRecommended;
end;

//------------------------------------------------------------------------------
procedure TMemsV2.GetAccountsFromCandidates;
var
  i: integer;
  Candidate: TCandidate_Mem;
  sBankAccountNumber: string;
  sAccount: string;
  byEntryType: byte;
  iFound: integer;
  varAdd: TCandidateGroup;
begin
  for i := 0 to Candidates.ItemCount-1 do
  begin
    Candidate := Candidates[i];

    sBankAccountNumber := Candidate.cmFields.cmBank_Account_Number;

    // Uncoded transaction?
    sAccount := Candidate.cmFields.cmAccount;
    if (sAccount = '') then
      continue;

    // Add to account
    byEntryType := Candidate.cmFields.cmType;
    if fGroups.Find(sBankAccountNumber, sAccount, byEntryType, iFound) then
      varAdd := fGroups[iFound]
    else
    begin
      varAdd := TCandidateGroup.Create(sBankAccountNumber, sAccount, byEntryType
        );
      fGroups.Add(varAdd);
    end;
    ASSERT(assigned(varAdd));

    varAdd.Add(Candidate);
  end;
end;

//------------------------------------------------------------------------------
procedure TMemsV2.GetCandidateStrings;
var
  i: integer;
  Group: TCandidateGroup;
begin
  // Determine the LCS for each account
  for i := 0 to fGroups.Count-1 do
  begin
    Group := fGroups[i];
    Group.DetermineLCS(fCandidateStrings);
  end;
end;

//------------------------------------------------------------------------------
procedure TMemsV2.EliminateCandidateStrings;
var
  i: integer;
  CandidateString: TCandidateString;
  sDetails: string;
  sAccount: string;
begin
  if DebugMe then
  begin
    Log('');
    Log('String Elimination:');
  end;

  for i := fCandidateStrings.Count-1 downto 0 do
  begin
    CandidateString := fCandidateStrings[i];
    sDetails := CandidateString.LCS.Details;

    if MoreThanOneAccount(sDetails, sAccount) then
    begin
      if DebugMe then
        Log('More than one account: '+CandidateString.LCS.ToString);
      fCandidateStrings.Delete(i);
      continue;
    end
    else
    begin
      { Note: after refinement the Account Code is gone, so we must join them
        together again here. }
      CandidateString.Account := sAccount;
    end;

    if LessThanMinimumCount(sDetails) then
    begin
      if DebugMe then
        Log('Count less than minimum: '+CandidateString.LCS.ToString);
      fCandidateStrings.Delete(i);
      continue;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TMemsV2.MoreThanOneAccount(const aDetails: string;
  var aAccount: string): boolean;
var
  bFirstAccount: boolean;
  sAccountFound: string;
  i: integer;
  Candidate: TCandidate_Mem;
  sDetails: string;
  iPos: integer;
  sAccount: string;
begin
  bFirstAccount := true;

  for i := 0 to fCandidates.ItemCount-1 do
  begin
    Candidate := fCandidates[i];

    // Position of partial match within details
    sDetails := Candidate.cmFields.cmStatement_Details;
    iPos := Pos(aDetails, sDetails);
    if (iPos = 0) then
      continue;

    sAccount := Candidate.cmFields.cmAccount;

    // First time we find an account?
    if bFirstAccount then
    begin
      bFirstAccount := false;
      sAccountFound := sAccount;

      continue;
    end;

    // Different account?
    if (sAccountFound <> sAccount) then
    begin
      // More than one account found, stop looking
      result := true;
      exit;
    end;
  end;

  ASSERT(not bFirstAccount, 'There should always be a match');
  aAccount := sAccountFound;

  result := false;
end;

//------------------------------------------------------------------------------
function TMemsV2.LessThanMinimumCount(const aDetails: string): boolean;
const
  MIN_COUNT = 3;
var
  iCount: integer;
  i: integer;
  Candidate: TCandidate_Mem;
  sDetails: string;
  iPos: integer;
begin
  iCount := 0;

  for i := 0 to fCandidates.ItemCount-1 do
  begin
    Candidate := fCandidates[i];
    sDetails := Candidate.cmFields.cmStatement_Details;

    // Position of partial match within details
    iPos := Pos(aDetails, sDetails);
    if (iPos = 0) then
      continue;

    iCount := iCount + Candidate.cmFields.cmCount;

    { Minimum already met?
      Note: stop searching which prevents searching the entire list. }
    if (iCount >= MIN_COUNT) then
    begin
      result := false;
      exit;
    end;
  end;

  // After having searched all, still below minimum?
  if (iCount < MIN_COUNT) then
  begin
    result := true;
    exit;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TMemsV2.RefineCandidateStrings: boolean;
var
  TempStrings: TCandidateStringTree;
  iRow: integer;
  iRowOther: integer;
  Candidate: TCandidateString;
  CandidateOther: TCandidateString;
  bStartData: boolean;
  sDetails: string;
  bEndData: boolean;
  New: TCandidateString;
begin
  if DebugMe then
  begin
    Log('');
    Log('String Refinement:');
  end;

  { Note: the Account Code will be lost during this process, but will be
    recovered again during the string elimination process. New refined strings
    are not checked for a minimum size. }

  TempStrings := TCandidateStringTree.Create;
  try
    for iRow := 0 to fCandidateStrings.Count-1 do
    begin
      TempStrings.Clear;
      
      for iRowOther := 0 to fCandidateStrings.Count-1 do
      begin
        { Note: it's okay to compare against itself, because we want to retain 
          the LCS if there's only one item per EntryType. }
            
        Candidate := fCandidateStrings[iRow];
        CandidateOther := fCandidateStrings[iRowOther];

        // BankAccountNumber mismatch?
        if (Candidate.BankAccountNumber <> CandidateOther.BankAccountNumber) then
          continue;

        // Note: no need to do Account Code
        
        // Entry type mismatch?
        if (Candidate.EntryType <> CandidateOther.EntryType) then
          continue;

        // Found new longer string?
        if FindLCSinLCS(Candidate.LCS, CandidateOther.LCS, bStartData, sDetails,
          bEndData) then
        begin
          // New LCS
          New := TCandidateString.Create;
          New.BankAccountNumber := Candidate.BankAccountNumber;
          New.Account := Candidate.Account;
          New.EntryType := Candidate.EntryType;
          New.LCS.SetData(bStartData, sDetails, bEndData);
          TempStrings.AddOrMerge(New);
        end
        else
        begin
          // Original LCS
          New := Candidate.Copy;
          TempStrings.AddOrMerge(New);
        end;
      end;

      { Copy the top LCS (longest string, could be multiple) to the refinement
        strings. }
      TempStrings.CopyRelevantLCSTo(fRefinementStrings);
    end;
  finally
    FreeAndNil(TempStrings);
  end;

  // The refinement produces the same candidate strings?
  if fCandidateStrings.Compare(fRefinementStrings) then
  begin
    // Don't iterate anymore
    result := false;
    exit;
  end;

  // Copy refinement strings across to candidate strings
  fCandidateStrings.Clear;
  fCandidateStrings.Assign(fRefinementStrings);
  fRefinementStrings.Clear;

  result := true;
end;

//------------------------------------------------------------------------------
procedure TMemsV2.AddCandidateStringsToRecommended;
var
  i: integer;
  Candidate: TCandidateString;
  New: TRecommended_Mem;
begin
  for i := 0 to fCandidateStrings.Count-1 do
  begin
    Candidate := fCandidateStrings[i];

    // Create new
    New := TRecommended_Mem.Create;
    New.rmFields.rmBank_Account_Number := Candidate.BankAccountNumber;
    New.rmFields.rmAccount := Candidate.Account;
    New.rmFields.rmType := Candidate.EntryType;
    New.rmFields.rmStatement_Details := Candidate.LCS.ToString;

    { Already exists?
      Note: don't use Recommended.Search, because it compares other fields, that
      are always different, as well.
    }
    if FindRecommended(New) then
    begin
      FreeAndNil(New);
      continue;
    end;

    if DebugMe then
      Log('Add suggested mem: ' + New.rmFields.rmStatement_Details);

    try
      fRecommended.Insert(New);
    except
      ; // Ignore, we already did our best to check for duplicates
    end;
  end;
end;

//------------------------------------------------------------------------------
function TMemsV2.FindRecommended(const aRecommended: TRecommended_Mem): boolean;
var
  i: integer;
  RecommendedOther: TRecommended_Mem;
begin
  for i := 0 to Recommended.ItemCount-1 do
  begin
    RecommendedOther := Recommended.Recommended_Mem_At(i);

    // Already exists?
    if (aRecommended.rmFields.rmBank_Account_Number = RecommendedOther.rmFields.rmBank_Account_Number) and
       (aRecommended.rmFields.rmAccount = RecommendedOther.rmFields.rmAccount) and
       (aRecommended.rmFields.rmType = RecommendedOther.rmFields.rmType) and        
       (aRecommended.rmFields.rmStatement_Details = RecommendedOther.rmFields.rmStatement_Details) then
    begin
      result := true;

      exit;
    end;
  end;

  result := false;
end;


{-------------------------------------------------------------------------------
  FindLCS
-------------------------------------------------------------------------------}
function FindLCS(const aFirst: string; const aSecond: string;
  var aStartData: boolean; var aDetails: string; var aEndData: boolean
  ): boolean;
var
  iPos1: integer;
  iPos2: integer;
  iLastPos1: integer;
  iLastPos2: integer;
  iLength1: integer;
  iLength2: integer;
begin
  result := false;

  // Longest match
  aDetails := LongestCommonSubstring(aFirst, aSecond);
  aDetails := Trim(aDetails);
  if (aDetails = '') then
    exit;

  // Data BEFORE the Details?
  iPos1 := Pos(aDetails, aFirst);
  iPos2 := Pos(aDetails, aSecond);
  aStartData := (iPos1 > 1) or (iPos2 > 1);

  // Data AFTER the Details?
  iLastPos1 := iPos1 + Length(aDetails) - 1;
  iLastPos2 := iPos2 + Length(aDetails) - 1;
  iLength1 := Length(aFirst);
  iLength2 := Length(aSecond);
  aEndData := (iLastPos1 < iLength1) or (iLastPos2 < iLength2);

  result := true;
end;


{-------------------------------------------------------------------------------
  Longest Common Substring

  Sourced from:
  http://forum.codecall.net/topic/53596-longest-common-substring/
-------------------------------------------------------------------------------}
function LongestCommonSubstring(const AFirst, ASecond: String): String;
var
  I, J, K: Integer;
  LSubString: String;
begin
  Result := '';
  for I := 1 to Length(AFirst) do for J := 1 to Length(ASecond) do
  begin
    K := 1;
    while (K <= Length(AFirst)) and (K <= Length(ASecond)) do
    begin
      if Copy(AFirst, I, K) = Copy(ASecond, J, K) then
      begin
        LSubString := Copy(AFirst, I, K);
      end else
      begin
        if Length(LSubString) > Length(Result) then Result := LSubString;
        LSubString := '';
      end;
      if Length(LSubString) > Length(Result) then Result := LSubString;
      LSubString := '';
      Inc(K);
    end;
  end;
end;


{-------------------------------------------------------------------------------
  RunMemsV2
-------------------------------------------------------------------------------}
procedure RunMemsV2(const aCandidates: TCandidate_Mem_List;
  const aRecommended: TRecommended_Mem_List);
var
  dwStart: DWORD;
  dwDuration: DWORD;
  MemsV2: TMemsV2;
  crCurrent: TCursor;
begin
  dwStart := timeGetTime;

  MemsV2 := nil;
  try
    MemsV2 := TMemsV2.Create(aCandidates, aRecommended);

    { Transactions older than 3 months or exceeds 150 transactions in the
      account? }
    if not MemsV2.AllowedToRun then
    begin
      if DebugMe then
        Log('Not enough transactions to run');

      exit;
    end;

    // Could take some time
    crCurrent := Screen.Cursor;
    Screen.Cursor := crHourGlass;
    try
      MemsV2.Run;
    finally
      Screen.Cursor := crCurrent;
    end;
  finally
    FreeAndNil(MemsV2);
  end;

  dwDuration := timeGetTime - dwStart;

  if DebugMe then
    Log('Mems V2: ' + IntToStr(dwDuration) + ' ms');
end;


initialization
begin
  DebugMe := DebugUnit(UnitName);
end;


end.
