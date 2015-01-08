unit RecommendedMems;

interface

uses
  Classes,
  IOStream,
  BKutIO,
  BKcpIO,
  utObj32,
  utList32,
  cpObj32,
  cmList32,
  rmList32,
  Tokens,
  baObj32,
  baList32,
  BKDefs,
  RecommendedMemsV2;

type
  TRecommended_Mems = class(TObject)
  private
    fStartTickCount : int64;
    fCandMemBusy : boolean;
    fRemoveAccounts : boolean;
    fPopulateUnscannedLists : boolean;

    fBankAccount: TBank_Account;
    fBankAccounts: TBank_Account_List;

    fUnscanned: TUnscanned_Transaction_List;
    fCandidate: TCandidate_Mem_Processing;
    fCandidates: TCandidate_Mem_List;
    fRecommended: TRecommended_Mem_List;
    FLastCodingFrmKeyPress: TDateTime;

    fMemsV2: TMemsV2;

    function GetLastCodingFrmKeyPress: TDateTime;
    function GetMatchingCandidateRange(StatementDetails: string; var FirstCandidatePos,
                                       LastCandidatePos: integer): boolean;
  protected
    procedure SetCandMemBusy(aValue : boolean);
  public
    constructor Create(const aBankAccounts: TBank_Account_List); reintroduce; overload;
    constructor Create(const aBankAccount: TBank_Account); reintroduce; overload;
    destructor  Destroy; override;
    procedure SetBankAccounts(const aBankAccounts: TBank_Account_List);

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function MemScan(RunningUnitTest: boolean; TestAccount: TBank_Account): boolean;
    procedure UpdateCandidateMems(TranRec: pTransaction_Rec; IsEditOrInsertOperation: boolean);
    procedure RescanCandidates;
    procedure SetLastCodingFrmKeyPress;
    procedure RemoveAccountFromMems(AccountNo: string); Overload;
    procedure RemoveAccountFromMems(BankAccount: TBank_Account); Overload;
    procedure RemoveAccountsFromMems(DoPopulate: boolean = True); overload;
    procedure RemoveAccountsFromMems(AccountList: TStringList; DoPopulate: boolean = True); overload;
    procedure RemoveAccountsFromMems(AccountList: TBank_Account_List; DoPopulate: boolean = True); overload;
    procedure PopulateUnscannedListOneAccount(BankAccount: TBank_Account; RunningUnitTest: boolean);
    procedure PopulateUnscannedListAllAccounts(RunningUnitTest: boolean);
    procedure RemoveRecommendedMems(Account: string; EntryType: byte; StatementDetails: string;
                                    AddedMasterMem: boolean);
    procedure RepopulateRecommendedMems;
    function GetCountOfRecMemsInAccount(AccountNo: string): integer;
    procedure ResetAll;
    procedure SetBankAccount(Value: TBank_Account);

    property  BankAccount: TBank_Account read fBankAccount write SetBankAccount;
    property  Unscanned: TUnscanned_Transaction_List read fUnscanned;
    property  Candidate: TCandidate_Mem_Processing read fCandidate;
    property  Candidates: TCandidate_Mem_List read fCandidates;
    property  Recommended: TRecommended_Mem_List read fRecommended;

    property CandMemBusy : boolean read fCandMemBusy write SetCandMemBusy;
  end;

implementation

uses
  BKConst,
  BKDbExcept,
  cmObj32,
  CodingFrm,
  DateUtils,
  Dialogs,
  Forms,
  Globals,
  MainFrm,
  MemorisationsObj,
  OSFont,
  rmObj32,
  SysUtils,
  Windows,
  LogUtil,
  DebugTimer,
  SyDefs,
  mxFiles32,
  Software;

const
  UnitName = 'RecommendedMems';
  DebugMe: boolean = false;{ TSomeClass }

constructor TRecommended_Mems.Create(const aBankAccounts: TBank_Account_List);
begin
  fStartTickCount := 0;
  fRemoveAccounts := false;
  fCandMemBusy := false;
  fPopulateUnscannedLists := false;
  fBankAccounts := aBankAccounts;

  fUnscanned := TUnscanned_Transaction_List.Create;
  fCandidate := TCandidate_Mem_Processing.Create;
  fCandidates := TCandidate_Mem_List.Create;
  fRecommended := TRecommended_Mem_List.Create;

  fMemsV2 := TMemsV2.Create(fBankAccounts, fCandidates, fRecommended);
end;

constructor TRecommended_Mems.Create(const aBankAccount: TBank_Account);
var
  aBankAccounts: TBank_Account_List;
begin
  aBankAccounts := TBank_Account_List.Create;
  aBankAccounts.Insert(aBankAccount);
  Create(aBankAccounts);
end;

destructor TRecommended_Mems.Destroy;
begin
  FreeAndNil(fMemsV2);

  FreeAndNil(fCandidates);
  FreeAndNil(fUnscanned);
  FreeAndNil(fCandidate);
  FreeAndNil(fRecommended);

  inherited;
end;

procedure TRecommended_Mems.SetBankAccount(Value: TBank_Account);
begin
  fBankAccount := Value;
end;

procedure TRecommended_Mems.SetBankAccounts(const aBankAccounts: TBank_Account_List);
begin
  fBankAccounts := aBankAccounts;
end;

procedure TRecommended_Mems.SetCandMemBusy(aValue: boolean);
var
  TimeTaken : double;
begin
  if fCandMemBusy <> aValue then
  begin
    if DebugMe then
    begin
      if aValue then
      begin
        LogUtil.LogMsg(lmDebug, UnitName, 'CandidateMemScan Start, Unscanned Count = ' + inttostr(fUnscanned.ItemCount));
        fStartTickCount := GetTickCount();
      end
      else
      begin
        TimeTaken := (GetTickCount - fStartTickCount)/1000;
        LogUtil.LogMsg(lmDebug, UnitName, 'CandidateMemScan End - Time Taken ' + floattostr(TimeTaken) + ' seconds.')
      end;
    end;

    fCandMemBusy := aValue;
  end;
end;

procedure TRecommended_Mems.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'LoadFromFile';
var
  Token : byte;
  Msg   : String;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start Load from File');

  Token := s.ReadToken;

  while (Token <> tkEndSection) do
  begin
    case Token of
      tkBeginUnscanned_Transaction_List : fUnscanned.LoadFromFile(S);
      tkBegin_Candidate_Mem_Processing  : fCandidate.LoadFromFile(S);
      tkBeginCandidate_Mem_List         : fCandidates.LoadFromFile(S);
      tkBeginRecommended_Mem_List       : fRecommended.LoadFromFile(S);
    else
      begin { Should never happen }
        Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
        raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
      end;
    end;

    Token := S.ReadToken;
  end;

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End Load from File');
end;

// Pass in a Statement Details string, and this procedure will put the position of the
// first matching Candidate into FirstCandidate and the last into LastCandidate.
// Uses a binary search as the Candidates should be in alphabetical order according to
// the contents of their Statement Details field.
// Returns false if there has been an error and the resetall procedure has to be called,
// see below.
function TRecommended_Mems.GetMatchingCandidateRange(StatementDetails: string;
                                                     var FirstCandidatePos, LastCandidatePos: integer): boolean;
var
  First, Last, Pivot, FoundMatchPosition: integer;
  Found: boolean;
  CandidateList: TCandidate_Mem_List;
  SearchedStatementDetails: string;
  StringCompareInt: integer;
begin
  Result := True;
  try
    FirstCandidatePos := -1;
    LastCandidatePos  := -1;

    CandidateList := Candidates;
    First := CandidateList.First;
    Last := CandidateList.Last;
    Found := False;

    // Find a Candidate whose Statement Details matched those we have passed in
    FoundMatchPosition := -1;
    while (First <= Last) and (not Found) and (Last <> -1) do
    begin
      // Get the middle of the range
      Pivot := (First + Last) shr 1; // shr = shift right 1 (equivalent to div 2)
      SearchedStatementDetails := CandidateList.Candidate_Mem_At(Pivot).cmFields.cmStatement_Details;
      // Compare the string in the middle with the searched one (case insensitive)
      StringCompareInt := CompareText(SearchedStatementDetails, StatementDetails);
      if (UpperCase(SearchedStatementDetails) = UpperCase(StatementDetails)) then
      begin
        Found := True;
        FoundMatchPosition := Pivot;
      end
      else if (StringCompareInt > 0) then
        // Now we'll search within the first half
        Last := Pivot - 1
      else
        // Now we'll search within the second half
        First := Pivot + 1;
    end;

    if FoundMatchPosition = -1 then
      Exit; // there are no matching candidates

    // In a normal binary search we would be done, but in our case there may be several
    // matching candidates (we wouldn't expect there to be too many), and we need to
    // know about them all. So let's find the positions of the first and last candidates

    // We go back through the list, from the position of the matching candidate we found,
    // until we find the first matching candidate, store the position of the first match
    // as FirstCandidatePos, which will be used in the Recommended Mem logic
    FirstCandidatePos := FoundMatchPosition;
    while (FirstCandidatePos > First) do
    begin
      if (CompareText(CandidateList.Candidate_Mem_At(FirstCandidatePos - 1).cmFields.cmStatement_Details,
                          StatementDetails) = 0) then
        FirstCandidatePos := FirstCandidatePos - 1
      else
        Break;
    end;

    // Now we go forward through the list, from the position of the matching candidate we
    // found, until we find the last matching candidate, store the position of the last
    // match as LastCandidatePos, which will be used in the Recommended Mem logic
    LastCandidatePos := FoundMatchPosition;
    while (LastCandidatePos < Last) do
    begin
      if (CompareText(CandidateList.Candidate_Mem_At(LastCandidatePos + 1).cmFields.cmStatement_Details,
                          StatementDetails) = 0) then
        LastCandidatePos := LastCandidatePos + 1
      else
        Break;
    end;
  finally
    // If either of these values are -1, a mistake has been made when generating the candidate
    // list, so we now need to rebuild it. A code change has been made to fix the only known
    // source of such a mistake, see Scenario 88339
    if (FirstCandidatePos = -1) or (LastCandidatePos = -1) then
    begin
      if Assigned(MyClient) then
      begin
        MyClient.clRecommended_Mems.ResetAll;
        MyClient.clRecommended_Mems.PopulateUnscannedListAllAccounts(false);
      end;
      Result := False;
    end;
  end;
end;

procedure TRecommended_Mems.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'SaveToFile';
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start Save to File');

  S.WriteToken(tkBeginRecommended_Mems);

  fUnscanned.SaveToFile(S);
  fCandidate.SaveToFile(S);
  fCandidates.SaveToFile(S);
  fRecommended.SaveToFile(S);

  S.WriteToken(tkEndSection);

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End Save to File');
end;

function TRecommended_Mems.GetLastCodingFrmKeyPress: TDateTime;
begin
  Result := FLastCodingFrmKeyPress;
end;

procedure TRecommended_Mems.SetLastCodingFrmKeyPress;
begin
  FLastCodingFrmKeyPress := Time;
end;

function TRecommended_Mems.MemScan(RunningUnitTest: boolean; TestAccount: TBank_Account): boolean;
const
  ThisMethodName = 'MemScan';
var
  InCodingForm      : boolean;
  LastKeyPressTime  : TDateTime;
  StartTime         : TDateTime;

  function DoMemsMatch(MemIsMaster: boolean; CandidateMem: TCandidate_Mem; CompareMem: TMemorisation): boolean;
  begin
    Result := (CandidateMem.cmFields.cmType = CompareMem.mdFields.mdType) and
              (CompareText(CandidateMem.cmFields.cmStatement_Details,
                               CompareMem.mdFields.mdStatement_Details) = 0);
    if MemIsMaster and Result then
      if Assigned(MyClient) then      
        if CompareMem.mdFields.mdUse_Accounting_System then
          Result := (CompareMem.mdFields.mdAccounting_System = MyClient.clFields.clAccounting_System_Used);        
  end;

  // Returns true if there is an existing memorisation which matches CandidateMem1
  function AddMemorisationIfUnique(Account            : TBank_Account;
                                   CandidateMem1      : TCandidate_Mem;
                                   FirstCandidatePos  : integer;
                                   LastCandidatePos   : integer): boolean;
  var
    CandidateMem2       : TCandidate_Mem;
    CandidatePos        : integer;
    ManuallyCodedCount  : integer;
    ExcludeMem          : boolean;
    Memorisation        : TMemorisation;
    MemsPos             : integer;
    NewRecMem           : TRecommended_Mem;
    UncodedCount        : integer;
    MemList             : TMemorisations_List;
    SystemMemorisation  : pSystem_Memorisation_List_Rec;
    BankPrefix          : BankPrefixStr;
  begin
    Result := False;
    // We can check if the account matches here, no need to proceed further if it doesn't match
    if (CandidateMem1.cmFields.cmBank_Account_Number = Account.baFields.baBank_Account_Number) then
    begin
      ExcludeMem := False;

      // Checking memorisations for the current account
      for MemsPos := Account.baMemorisations_List.First to Account.baMemorisations_List.Last do
      begin
        Memorisation := Account.baMemorisations_List.Memorisation_At(MemsPos);
        if DoMemsMatch(false, CandidateMem1, Memorisation) then
        begin
          ExcludeMem := True;
          Break;
        end;
      end;

      // Checking master mems
      if Assigned(AdminSystem) then
      begin
        BankPrefix := mxFiles32.GetBankPrefix(Account.baFields.baBank_Account_Number);
        SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BankPrefix);
        if Assigned(SystemMemorisation) then
        begin
          MemList := TMemorisations_List(SystemMemorisation.smMemorisations);
          for MemsPos := MemList.First to MemList.Last do
          begin
            Memorisation := MemList.Memorisation_At(MemsPos);
            if DoMemsMatch(true, CandidateMem1, Memorisation) then
            begin
              ExcludeMem := True;
              Break;
            end;
          end;
        end;
      end;

      // Check if any candidates have:
      // * A matching account code
      // * Matching statement details
      // * A matching bank account number
      // If a candidate is found that matches all of these, and isn't manually coded
      // nor uncoded, then exclude our candidate
      // TODO: optimize this if possible
      // TODO: check if this is redundant, see similar functionality in CheckForExclusions
      for CandidatePos := 0 to Candidates.ItemCount - 1 do
      begin
        CandidateMem2 := Candidates.Candidate_Mem_At(CandidatePos);
        if (CandidateMem1.cmFields.cmAccount = CandidateMem2.cmFields.cmAccount) and
        (CompareText(CandidateMem1.cmFields.cmStatement_Details,
                        CandidateMem2.cmFields.cmStatement_Details) = 0) and
        (not (CandidateMem2.cmFields.cmCoded_By in [cbManual, cbNotCoded])) and
        (CandidateMem1.cmFields.cmBank_Account_Number = CandidateMem2.cmFields.cmBank_Account_Number) then
          ExcludeMem := True;
      end;

      if not ExcludeMem then
      begin
        // Let's get the counts for manually coded and uncoded (blank) transactions
        ManuallyCodedCount := 0;
        UncodedCount := 0;
        if (FirstCandidatePos = -1) or (LastCandidatePos = -1) then
        begin
          // If either of these values are -1, a mistake has been made when generating the candidate
          // list, so we now need to rebuild it. A code change has been made to fix the only known
          // source of such a mistake, see Scenario 88339
          if Assigned(MyClient) then
          begin
            MyClient.clRecommended_Mems.ResetAll;
            MyClient.clRecommended_Mems.PopulateUnscannedListAllAccounts(false);
          end;
          Exit;
        end;
        for CandidatePos := FirstCandidatePos to LastCandidatePos do
        begin
          CandidateMem2 := Candidates.Candidate_Mem_At(CandidatePos);
          if (CandidateMem1.cmFields.cmBank_Account_Number = CandidateMem2.cmFields.cmBank_Account_Number) then
          begin
            if (CandidateMem1.cmFields.cmType = CandidateMem2.cmFields.cmType) then
            begin
              if (CandidateMem2.cmFields.cmCoded_By = cbManual) then
                ManuallyCodedCount := ManuallyCodedCount + CandidateMem2.cmFields.cmCount
              else if (CandidateMem2.cmFields.cmCoded_By = cbNotCoded) then
                UncodedCount := UncodedCount + CandidateMem2.cmFields.cmCount;
            end;
          end;
        end;

        // There is no matching existing memorisation, so let's add this candidate
        // to recommended mems. This doesn't need to be and so isn't added
        // alphabetically, but we can change this later if needed
        NewRecMem := TRecommended_Mem.Create;
        NewRecMem.rmFields.rmType                 := CandidateMem1.cmFields.cmType;
        NewRecMem.rmFields.rmBank_Account_Number  := CandidateMem1.cmFields.cmBank_Account_Number;
        NewRecMem.rmFields.rmAccount              := CandidateMem1.cmFields.cmAccount;
        NewRecMem.rmFields.rmStatement_Details    := CandidateMem1.cmFields.cmStatement_Details;
        NewRecMem.rmFields.rmManual_Count         := ManuallyCodedCount;
        NewRecMem.rmFields.rmUncoded_Count        := UncodedCount;
        Recommended.Insert(NewRecMem);
      end;
      // We've found the matching account, so whether or not we've added a
      // recommended mem, there is no need to keep looking through the accounts
      Result := True;
    end; // if (CandidateMem1.cmFields.cmBank_Account_Number = Account.baFields.baBank_Account_Number) then
  end;

  // Does the recommended memorisation processing, returns true when this is complete
  function DoRecommendedMemProcessing: boolean;
  var
    Account                   : TBank_Account;
    AccountCodesDiffer        : boolean;
    AccountsPos               : integer;
    BlankStatementDetails     : boolean;
    C2AccountIsCurrentAccount : boolean;
    C2HasBlankCode            : boolean;
    CandidateMem1             : TCandidate_Mem;
    CandidateMem2             : TCandidate_Mem;
    C2CodedByIsManual         : boolean;
    // EitherAccountIsBlank    : boolean;
    FirstCandidatePos         : integer;
    CandidateToProcess        : integer;
    LastCandidatePos          : integer;
    NextCandidateID           : integer;
    IsActive                  : boolean;
    LineIsInvalid             : boolean;
    C2CodeIsValid             : boolean;

    // Returns true if we should exclude the candidate
    function CheckForExclusions: boolean;
    var
      CandidatePos: integer;
    begin
      Result := False;
      CandidateMem2 := nil;

//      Assert((FirstCandidatePos <> -1) and (LastCandidatePos <> -1),
//             'FirstCandidatePos and LastCandidatePos shouldn''t be -1 here');
      if (FirstCandidatePos = -1) or (LastCandidatePos = -1) then
      begin
        // If either of these values are -1, a mistake has been made when generating the candidate
        // list, so we now need to rebuild it. A code change has been made to fix the only known
        // source of such a mistake, see Scenario 88339
        if Assigned(MyClient) then
        begin
          MyClient.clRecommended_Mems.ResetAll;
          MyClient.clRecommended_Mems.PopulateUnscannedListAllAccounts(false);
        end;
        Exit;
      end;

      for CandidatePos := FirstCandidatePos to LastCandidatePos do
      begin
        CandidateMem2 := Candidates.Candidate_Mem_At(CandidatePos);
        // Does the key (entry type, bank account code, statement details) match? We have already
        // checked the latter so just check the first two
        if (CandidateMem1.cmFields.cmType = CandidateMem2.cmFields.cmType) and
        (CandidateMem1.cmFields.cmBank_Account_Number = CandidateMem2.cmFields.cmBank_Account_Number) then
        begin
          AccountCodesDiffer := (CandidateMem1.cmFields.cmAccount <> CandidateMem2.cmFields.cmAccount);
          // EitherAccountIsBlank := (CandidateMem1.cmFields.cmAccount = '') or
          //                         (CandidateMem2.cmFields.cmAccount = '');
          C2CodedByIsManual := (CandidateMem2.cmFields.cmCoded_By = cbManual);
          C2HasBlankCode := (CandidateMem2.cmFields.cmAccount = '');
          BlankStatementDetails := (CandidateMem1.cmFields.cmStatement_Details = '');

          // We don't want to exclude candidates because of suggestions in a different account.
          // If C2AccountIsCurrentAccount is true, then the account of the candidate we're comparing
          // our current candidate to (C1 = current candidate, c2 = compared candidate) is the same
          // as the current account, OR there is no current account because we're just scanning
          // mems at this point and are not yet in the suggested mems form
          if Assigned(fBankAccount) then
            C2AccountIsCurrentAccount :=
              (CandidateMem2.cmFields.cmBank_Account_Number = fBankAccount.baFields.baBank_Account_Number)
          else
            C2AccountIsCurrentAccount := True;

          // Candidates with invalid or inactive chart codes should not exclude other candidates
          C2CodeIsValid := True;
          if Assigned(MyClient) and (CandidateMem2.cmFields.cmAccount <> '') then
          begin
            if not MyClient.clChart.CanCodeTo(CandidateMem2.cmFields.cmAccount, IsActive,
                                              HasAlternativeChartCode(MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used)) then
              C2CodeIsValid := False
            else if not IsActive then
              C2CodeIsValid := False;
          end;

          {
          if ((AccountCodesDiffer and not EitherAccountIsBlank) or
          (CodedByIsManual = false)) and
          (Candidate2HasBlankCode = false) and
          C2CodeIsValid then
          }
          // This part has been split up a bit to make it more readable, rather than
          // cramming all the conditions into one big If Statement
          if (((not C2CodedByIsManual) or AccountCodesDiffer) and
          (not C2HasBlankCode)) and
          C2AccountIsCurrentAccount and
          C2CodeIsValid then
          begin
            // Don't recommend this candidate
            Result := True;
            Break;
          end;
          if BlankStatementDetails then
          begin
            // Don't recommend this candidate
            Result := True;
            Break;
          end;
          if (CandidateMem2.cmFields.cmAccount = DISSECT_DESC) then
          begin
            // Don't recommend this candidate
            Result := True;
            Break;
          end;
        end;
      end;
    end;

  begin
    IsActive := True;
    if DebugMe then
      CreateDebugTimer('TRecommended_Mems.DoRecommendedMemProcessing');

    if (Candidate.cpFields.cpCandidate_ID_To_Process < 1) then
      Candidate.cpFields.cpCandidate_ID_To_Process := 1;
    CandidateToProcess := Candidate.cpFields.cpCandidate_ID_To_Process;
    if (Candidate.cpFields.cpNext_Candidate_ID <= Candidates.ItemCount) then
      Candidate.cpFields.cpNext_Candidate_ID := Candidates.ItemCount + 1;
    NextCandidateID := Candidate.cpFields.cpNext_Candidate_ID;
    if (CandidateToProcess > Candidates.ItemCount) then
    begin
      // We have run out of candidates to process
      CandidateToProcess := NextCandidateID;
      Candidate.cpFields.cpCandidate_ID_To_Process := CandidateToProcess;
    end;
    // Is there another candidate left to process?
    if (CandidateToProcess < NextCandidateID) then
    begin
      // Yes there is
      Result := False;
      // Get candidate details
      CandidateMem1 := Candidates.Candidate_Mem_At(CandidateToProcess - 1);
      // Increment next candidate to process
      Candidate.cpFields.cpCandidate_ID_To_Process :=
        Candidate.cpFields.cpCandidate_ID_To_Process + 1;
      LineIsInvalid := False;
      if Assigned(MyClient) then
      begin
        if not MyClient.clChart.CanCodeTo(CandidateMem1.cmFields.cmAccount, IsActive,
                                          HasAlternativeChartCode(MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used)) then
          LineIsInvalid := True
        else if not IsActive then
          LineIsInvalid := True;
      end;
      // Does the candidate have a count >= 3, is manually coded, and isn't dissected?
      if (CandidateMem1.cmFields.cmCount >= 3) and
         (CandidateMem1.cmFields.cmCoded_By = cbManual) and
         (CandidateMem1.cmFields.cmAccount <> DISSECT_DESC) and
         (not LineIsInvalid) then // sorry for the double negative here :/
      begin
//        Assert((CandidateMem1.cmFields.cmAccount <> ''), 'Blank account code and manual coding should be mutually exclusive');
        if not GetMatchingCandidateRange(CandidateMem1.cmFields.cmStatement_Details,
                                         FirstCandidatePos, LastCandidatePos) then
          Exit;

        // Checking for exclusions: does the key exist in the candidate list with a
        // different code (including dissections, which will always have the code
        // 'DISSECT' and thus be excluded when we compare account codes, as our
        // original candidate will never be a dissection, these are filtered out
        // earlier) or a coding type other than manual? Also, is Statement
        // Details NOT blank?
        if not CheckForExclusions then
        begin
          // Does an existing matching memorisation already exist? Check the candidate against all
          // existing memorisations for all of the clients bank accounts. If the following match:
          // * Entry type
          // * Bank Account Number
          // * Statement Details
          // ... then the answer is yes, so we don't add this candidate to the recommended mems list
          if RunningUnitTest then
            AddMemorisationIfUnique(TestAccount, CandidateMem1, FirstCandidatePos, LastCandidatePos)
          else
          begin
            for AccountsPos := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
            begin
              Account := MyClient.clBank_Account_List.Bank_Account_At(AccountsPos);

              if AddMemorisationIfUnique(Account, CandidateMem1, FirstCandidatePos, LastCandidatePos) then
                Break;
            end; // for AccountsPos := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
          end; // if RunningUnitTest
        end; // if not ExclusionFound
      end; // if (CandidateMem1.cmFields.cmCount >= 3) and (CandidateMem1.cmFields.cmCoded_By = cbManual) and (CandidateMem1.cmFields.cmAccount <> DISSECT_DESC)
    end // if (CandidateToProcess < NextCandidateID)
    else
      Result := True;
  end;

  procedure DoCandidateMemProcessing;
  var
    i                       : Integer;
    pTranRec                : pTransaction_Rec;
    utBankAccount           : string[20];
    utSequenceNo            : integer;
    utAccount               : TBank_Account;
    cMem                    : TCandidate_Mem;
    MatchingCandidateFound  : boolean;
    NewCandidateInserted    : boolean;
  begin
    if DebugMe then
      CreateDebugTimer('TRecommended_Mems.DoCandidateMemProcessing');

    // Is unscanned list empty?
    if (Unscanned.ItemCount > 0) then
    begin
      try
        // Get first unscanned transaction in unscanned transaction list
        utBankAccount := Unscanned.Unscanned_Transaction_At(0).utFields.utBank_Account_Number;
        utSequenceNo  := Unscanned.Unscanned_Transaction_At(0).utFields.utSequence_No;
        // Get transaction details for the transaction that matches the sequence number in our record
        if RunningUnitTest then
          utAccount := TestAccount
        else
          utAccount := MyClient.clBank_Account_List.FindCode(utBankAccount);

        if not Assigned(utAccount) then
          // The account for this unscanned transaction has been removed, so let's get rid of it.
          // This is in a Try/Finally, so the unscanned transaction will be deleted in the Finally below
          Exit;
        pTranRec := nil;
        // TODO: optimize this search, see TExtdSortedCollection.Search
        for i := utAccount.baTransaction_List.First to utAccount.baTransaction_List.Last do
        begin
          pTranRec := utAccount.baTransaction_List.Transaction_At(i);
          if (pTranRec.txSequence_No = utSequenceNo) then
            break;
        end;
        if (pTranRec = nil) then
        begin
//          Assert(not Assigned(pTranRec), 'pTranRec should not be nil here');
          Exit; // Shouldn't get to here
        end;

        // Does key exist in candidate memorisation list?
        MatchingCandidateFound := False;
        // TODO: optimize this search, see TExtdSortedCollection.Search
        for i := Candidates.First to Candidates.Last do
        begin
          cMem := Candidates.Candidate_Mem_At(i);
          // Checking our unscanned transaction against the candidate memorisation to see if
          // they match. We check to see if the following match:
          //   * Coded By
          //   * Entry Type
          //   * Bank Account
          //   * Chart of Accounts code
          //   * Statement Details
          if (pTranRec.txCoded_By = cMem.cmFields.cmCoded_By) and
             (pTranRec.txType = cMem.cmFields.cmType) and
             (utAccount.baFields.baBank_Account_Number = cMem.cmFields.cmBank_Account_Number) and
             (pTranRec.txAccount = cMem.cmFields.cmAccount) and
             (CompareText(pTranRec.txStatement_Details, cMem.cmFields.cmStatement_Details) = 0) then
          begin
            // There is already a matching Candidate Mem, so increase its reference count
            cMem.cmFields.cmCount := cMem.cmFields.cmCount + 1;
            MatchingCandidateFound := True;
            Break;
          end;
        end;
        if not MatchingCandidateFound then
        begin
          // We haven't found a matching Candidate Mem, so create a new one
          cMem := TCandidate_Mem.Create;
          cMem.cmFields.cmID := Candidate.cpFields.cpNext_Candidate_ID;

          // Increase next candidate ID for the next candidate to be created
          Candidate.cpFields.cpNext_Candidate_ID :=
            Candidate.cpFields.cpNext_Candidate_ID + 1;

          // Fill in details for the new candidate
          cMem.cmFields.cmCount := 1;
          cMem.cmFields.cmType := pTranRec.txType;
          cMem.cmFields.cmBank_Account_Number := utAccount.baFields.baBank_Account_Number;
          cMem.cmFields.cmCoded_By := pTranRec.txCoded_By;
          cMem.cmFields.cmAccount := pTranRec.txAccount;
          cMem.cmFields.cmStatement_Details := pTranRec.txStatement_Details;

          // Insert the new candidate in alphabetical order according to Statement Details
          if (Candidates.ItemCount > 0) then
          begin
            NewCandidateInserted := False;
            // TODO: optimize search, see TExtdSortedCollection.Search
            for i := Candidates.First to Candidates.Last do
            begin
              if (CompareText(cMem.cmFields.cmStatement_Details,
                              Candidates.Candidate_Mem_At(i).cmFields.cmStatement_Details) <= 0) then
              begin
                Candidates.AtInsert(i, cMem);
                NewCandidateInserted := True;
                Break;
              end;
            end;
            if not NewCandidateInserted then
              Candidates.Insert(cMem); // insert at the end
          end else
            Candidates.Insert(cMem); // this is the first candidate in the list
        end;
      finally
        Unscanned.AtFree(0);
      end;
    end // if (Unscanned.ItemCount > 0) then
    else
    begin
      // Candidate mem scanning is complete, recommended mem scanning can begin, set
      // CandidateIDToProcess to 1 to make sure the recommended mem scanning will
      // start from the first candidate. Should already be 1 but hey let's be safe
//      Assert((Candidate.cpFields.cpCandidate_ID_To_Process = 1), 'cpCandidate_ID_To_Process should be 1, but it isn''t');
      Candidate.cpFields.cpCandidate_ID_To_Process := 1;

      fMemsV2.Reset;
    end;
  end;
begin
  {if DebugMe then
  begin
    if fLastTickCount > getTickCount then
      fLastTickCount := getTickCount;

    if (fLastTickCount + 1000) > getTickCount then
    begin
      fLastTickCount := getTickCount;
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Unscanned Item Count = ' + inttostr(Unscanned.ItemCount));
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Unscanned Item Count = ' + inttostr(Unscanned.ItemCount));
    end;
  end; }

  Result := False;
  if Assigned(myClient) or RunningUnitTest then // Is the client file open?
  begin
    if MEMSINI_SupportOptions = meiDisableSuggestedMemsAll then
    begin
      Result := false;
      Exit;
    end;

    // Store current time
    StartTime := Time;

    // Are we in the coding screen?
    if Assigned(Screen.ActiveForm) then
      InCodingForm := (TfrmCoding.ClassName = Screen.ActiveForm.ClassName)
    else
      InCodingForm := False;

    // Are we in the coding form, and has there been a keypress in the last two seconds?
    LastKeyPressTime := GetLastCodingFrmKeyPress;
    if InCodingForm and (MilliSecondsBetween(StartTime, LastKeyPressTime) <= 2000) then
      Exit; // We are and there has, let's not do any scanning so that we don't interfere with the user

    // Has it been more than 33 milliseconds yet?
    while ((MilliSecondsBetween(StartTime, Time) < 33) or RunningUnitTest) do
    begin
      // Is the unscanned list empty?
      if (Unscanned.ItemCount = 0) then
      begin
        CandMemBusy := false;
        { Before data is available, Unscanned.ItemCount is called several times
          which puts fMemsV2 in the 'finished' state. We check to see if there
          are any candidates at all.
          This also solves the problem where MemScan is called while loading a
          zip stream. VCLZip calls ProcessMessages from there (can be turned
          off if required). }
        if not Assigned(TestAccount) then
        begin
          if (Candidates.ItemCount <> 0) then
          begin
            { More processing to do?
              Note: don't give control to DoRecommendedProcessing yet }
            if fMemsV2.DoProcessing then
              continue;
          end;
        end;

        // Unscanned list is empty, so do recommended processing
        if DoRecommendedMemProcessing then
        begin
          // Unscanned transaction list is empty, candidate and recommended mem
          // processing is done, nothing left to do, time to crack a beer
          Result := True;
          Exit;
        end;
      end
      else
      begin
        CandMemBusy := true;
        // There are still unscanned transactions, so do candidate processing
        DoCandidateMemProcessing;
      end;
    end;
  end;
end;

// This procedure should be called when a tranaction is edited or deleted
// IMPORTANT NOTE: When you call this method, you should do the following in a try/finally statement:
//   1) Set frmMain.MemScanIsBusy to true (check frmMain is assigned first)
//   2) Call the method
//   3) Make any changes to the transaction
//   4) In the finally, set frmMain.MemScanIsBusy to false (again, check frmMain is assigned first)
//
// This will prevent any scanning from being done while changes are made to transactions, we don't
// want the scanning to use out-of-date information
//
// You can put the contents of the entire method (the method you call this from) in the try/finally if
// you like, this is probably the easiest and safest way, I have done this most of the time.
procedure TRecommended_Mems.UpdateCandidateMems(TranRec: pTransaction_Rec; IsEditOrInsertOperation: boolean);
const
  ThisMethodName = 'UpdateCandidateMems';
var
  Account               : TBank_Account;
  CandidateInt          : integer;
  CandidateMemRec       : tCandidate_Mem_Rec;
  FirstCandidatePos     : integer;
  LastCandidatePos      : integer;
  MatchingCandidatePos  : integer;
  NewUnscannedTran      : TUnscanned_Transaction;
  utIndex               : integer;
  StartTickCount : int64;
  TimeTaken : double;
begin
  if not Assigned(TranRec) then
    Exit; // this shouldn't happen!

  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');
    StartTickCount := GetTickCount;
  end;

  // Search CandidateMems for a matching key. We can use binary search because
  // CandidateMems has been created in alphabetical order according to the
  // Statement Details field.
  // Key =
  // * Entry Type
  // * Bank Account Number
  // * Coding Type
  // * Account Code
  // * Statement Details
  Account := TBank_Account(TranRec.txBank_Account);
  if not GetMatchingCandidateRange(TranRec.txStatement_Details,
                                   FirstCandidatePos,
                                    LastCandidatePos) then
    Exit;
  MatchingCandidatePos := -1;
  if (FirstCandidatePos > -1) then
  begin
    for CandidateInt := FirstCandidatePos to LastCandidatePos do
    begin
      CandidateMemRec := Candidates.Candidate_Mem_At(CandidateInt).cmFields;
      // Statement details has already been matched, no need to check it again
      if (CandidateMemRec.cmType = TranRec.txType) and
      (CandidateMemRec.cmBank_Account_Number = Account.baFields.baBank_Account_Number) and
      (CandidateMemRec.cmCoded_By = TranRec.txCoded_By) and
      (CandidateMemRec.cmAccount = TranRec.txAccount) then
      begin
        MatchingCandidatePos := CandidateInt;
        break;
      end;
    end;
  end;

  // Has a match been found?
  if (MatchingCandidatePos <> -1) then
  begin
    CandidateMemRec := Candidates.Candidate_Mem_At(MatchingCandidatePos).cmFields;
    // Decrease count in matching CandidateMem
    Candidates.Candidate_Mem_At(MatchingCandidatePos).cmFields.cmCount := CandidateMemRec.cmCount - 1;
    // Does the count for this CandidateMem now equal zero?
    if (Candidates.Candidate_Mem_At(MatchingCandidatePos).cmFields.cmCount = 0) then
      // Yes, so remove this candidate from the candidate list
      Candidates.AtFree(MatchingCandidatePos);
  end;

  // Is this an edit operation (rather than a delete)?
  if IsEditOrInsertOperation then
  begin
    // Add modified transaction to unscanned list. We can use the old details
    // (bank account and sequence number), because they don't change when a
    // transaction gets modified by the user
    NewUnscannedTran := TUnscanned_Transaction.Create;
    NewUnscannedTran.utFields.utBank_Account_Number := Account.baFields.baBank_Account_Number;
    NewUnscannedTran.utFields.utSequence_No := TranRec.txSequence_No;
    utIndex := -1;
    if Unscanned.Search(NewUnscannedTran, utIndex) then
      FreeAndNil(NewUnscannedTran)
    else
      Unscanned.Insert(NewUnscannedTran);
  end;

  RescanCandidates;

  if DebugMe then
  begin
    TimeTaken := (GetTickCount - StartTickCount)/1000;
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End - Time Taken ' + floattostr(TimeTaken) + ' seconds.');
  end;
end;

// Scan the candidate list again and rebuild the suggested mems list
procedure TRecommended_Mems.RescanCandidates;
const
  ThisMethodName = 'RescanCandidates';
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');

  // Rescan candidates later (for both MemsV2 as well as MemsV1)
  Candidate.cpFields.cpCandidate_ID_To_Process := 1;
  fMemsV2.Reset;
  // Clear suggested memorisation list
  Recommended.FreeAll;
end;

// Builds the unscanned transactions list for all bank accounts
procedure TRecommended_Mems.PopulateUnscannedListAllAccounts(RunningUnitTest: boolean);
const
  ThisMethodName = 'PopulateUnscannedListAllAccounts';
var
  iBankAccount: integer;
  StartTickCount : int64;
  TimeTaken : double;
begin
  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');
    StartTickCount := GetTickCount();
  end;

  fPopulateUnscannedLists := true;
  try
    // TODO: add simple dialog (no progress bar)
    // Unscanned and Candidates must be empty
    if (Unscanned.ItemCount <> 0) or (Candidates.ItemCount <> 0) then
      exit;

    for iBankAccount := 0 to fBankAccounts.ItemCount-1 do
      PopulateUnscannedListOneAccount(fBankAccounts[iBankAccount], RunningUnitTest);

    if DebugMe then
    begin
      TimeTaken := (GetTickCount - StartTickCount)/1000;
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End - Time Taken ' + floattostr(TimeTaken) + ' seconds.');
    end;
  finally
    fPopulateUnscannedLists := false;
  end;
end;

// Builds the unscanned transactions list for one bank account
procedure TRecommended_Mems.PopulateUnscannedListOneAccount(BankAccount: TBank_Account; RunningUnitTest: boolean);
const
  ThisMethodName = 'PopulateUnscannedListOneAccount';
var
  iTransaction: integer;
  MaintainMemScanStatus: boolean;
  New: TUnscanned_Transaction;
  Transaction: pTransaction_Rec;
  utIndex: integer;
  StartTickCount : int64;
  TimeTaken : double;
begin
  {$IF Defined(MAPCHECK) or Defined(BKRELINK)}
  Exit; // bkmap shouldn't build suggested mems
  {$IFEND}

  if (DebugMe and (not fPopulateUnscannedLists)) then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');
    StartTickCount := GetTickCount();
  end;

  if BankAccount.IsAJournalAccount then
    Exit; // don't scan journals

  MaintainMemScanStatus := False;
  try
    if not RunningUnitTest then
    begin
      if Assigned(frmMain) then
        MaintainMemScanStatus := frmMain.MemScanIsBusy;
      if Assigned(frmMain) then
        frmMain.MemScanIsBusy := True;
    end;
    for iTransaction := 0 to BankAccount.baTransaction_List.ItemCount-1 do
    begin
      Transaction := BankAccount.baTransaction_List.Transaction_At(iTransaction);
      New := TUnscanned_Transaction.Create;
      New.utFields.utBank_Account_Number := BankAccount.baFields.baBank_Account_Number;
      New.utFields.utSequence_No := Transaction.txSequence_No;
      utIndex := -1;
      if Assigned(Unscanned) then
      begin
        if Unscanned.Search(New, utIndex) then
          FreeAndNil(New)
        else
          Unscanned.Insert(New);
      end;
    end;
  finally
    if Assigned(frmMain) then
      if not RunningUnitTest then
        if not MaintainMemScanStatus then
          frmMain.MemScanIsBusy := False;
  end;

  Candidate.cpFields.cpCandidate_ID_To_Process := 1;
  Candidate.cpFields.cpNext_Candidate_ID := 1;

  if (DebugMe and (not fPopulateUnscannedLists)) then
  begin
    TimeTaken := (GetTickCount - StartTickCount)/1000;
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End - Time Taken ' + floattostr(TimeTaken) + ' seconds.');
  end;
end;

// Removes an account from candidates and recommended mems. Should be called when:
// * Purging an account (in this case, via the RemoveAccountsFromMems method)
// * Merging an account
// * Unattaching an account
// EDIT: this will now complete wipe out the recommendations, otherwise we run
// into duplicate recommendations under certain circumstances, eg. bug 87884 in TFS
procedure TRecommended_Mems.RemoveAccountFromMems(AccountNo: string);
const
  ThisMethodName = 'RemoveAccountFromMems (Single)';
var
  i: integer;
  LoopStart: integer;
  MaintainMemScanStatus: boolean;
  StartTickCount : int64;
  TimeTaken : double;
begin
  if (DebugMe and (not fRemoveAccounts)) then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');
    StartTickCount := GetTickCount();
  end;

  MaintainMemScanStatus := False;
  try
    if Assigned(frmMain) then // false for unit tests, which don't need to set this boolean anyway
    begin
      MaintainMemScanStatus := frmMain.MemScanIsBusy;
      frmMain.MemScanIsBusy := True;
    end;
    // Delete all unscanned transactions with this account number,
    // so that we don't have to worry about duplicates being added
    LoopStart := Unscanned.ItemCount - 1; // Deletions will lower the item count, so we have to get this value before doing any deletions
    if (LoopStart >= 0) then
      for i := LoopStart downto 0 do
        if (Unscanned.Unscanned_Transaction_At(i).utFields.utBank_Account_Number = AccountNo) then
          Unscanned.AtFree(i);

    // Delete all candidates with this account number
    LoopStart := Candidates.ItemCount - 1;
    if (LoopStart >= 0) then
      for i := LoopStart downto 0 do
        if (Candidates.Candidate_Mem_At(i).cmFields.cmBank_Account_Number = AccountNo) then
          Candidates.AtFree(i);

    // Delete all recommended mems
    LoopStart := Recommended.ItemCount - 1;
    if (LoopStart >= 0) then
      for i := LoopStart downto 0 do
        Recommended.AtFree(i);

    // Will need to rebuild recommended mems later, so set ID To Process back to the start of Candidates
    fCandidate.cpFields.cpCandidate_ID_To_Process := 1;

    if (DebugMe and (not fRemoveAccounts)) then
    begin
      TimeTaken := (GetTickCount - StartTickCount)/1000;
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End - Time Taken ' + floattostr(TimeTaken) + ' seconds.');
    end;
  finally
    if Assigned(frmMain) then // false for unit tests, which don't need to set this boolean anyway
      if not MaintainMemScanStatus then
        frmMain.MemScanIsBusy := False;
  end;
end;

procedure TRecommended_Mems.RemoveAccountFromMems(BankAccount: TBank_Account);
begin
  RemoveAccountFromMems(BankAccount.baFields.baBank_Account_Number);
end;

// Removes all accounts from candidates and recommended mems
procedure TRecommended_Mems.RemoveAccountsFromMems(DoPopulate: boolean = True);
const
  ThisMethodName = 'RemoveAccountsFromMems.1';
var
  AccountList : TStringList;
  i           : integer;
  StartTickCount : int64;
  TimeTaken : double;
begin
  fRemoveAccounts := true;
  try
    if DebugMe then
    begin
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');
      StartTickCount := GetTickCount();
    end;

    AccountList := TStringList.Create;
    for i := 0 to MyClient.clBank_Account_List.ItemCount - 1 do
      AccountList.Add(MyClient.clBank_Account_List.Bank_Account_At(i).baFields.baBank_Account_Number);
    RemoveAccountsFromMems(AccountList, DoPopulate);

    if DebugMe then
    begin
      TimeTaken := (GetTickCount - StartTickCount)/1000;
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End - Time Taken ' + floattostr(TimeTaken) + ' seconds.');
    end;

  finally
    fRemoveAccounts := false;
  end;
end;

// Removes a given list of accounts from candidates and recommended mems
procedure TRecommended_Mems.RemoveAccountsFromMems(AccountList: TStringList; DoPopulate: boolean = True);
const
  ThisMethodName = 'RemoveAccountsFromMems.2';
var
  BankAccount: TBank_Account;
  i: integer;
  MaintainMemScanStatus: boolean;
  NoTiming : boolean;
  StartTickCount : int64;
  TimeTaken : double;
begin
  NoTiming := fRemoveAccounts;
  fRemoveAccounts := true;

  if (DebugMe and (not NoTiming)) then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');
    StartTickCount := GetTickCount();
  end;

  MaintainMemScanStatus := False;
  try
    if Assigned(frmMain) then
    begin
      MaintainMemScanStatus := frmMain.MemScanIsBusy;
      frmMain.MemScanIsBusy := True;
    end;

    Unscanned.FreeAll;

    for i := 0 to AccountList.Count - 1 do
      RemoveAccountFromMems(AccountList.Strings[i]);

    if DoPopulate then
    begin
      for i := 0 to AccountList.Count - 1 do
      begin
        BankAccount := MyClient.clBank_Account_List.FindCode(AccountList.Strings[i]);
        PopulateUnscannedListOneAccount(BankAccount, False);
      end;
    end;

    if (DebugMe and (not NoTiming)) then
    begin
      TimeTaken := (GetTickCount - StartTickCount)/1000;
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End - Time Taken ' + floattostr(TimeTaken) + ' seconds.');
    end;
  finally
    if Assigned(frmMain) then
      if not MaintainMemScanStatus then
        frmMain.MemScanIsBusy := False;

    fRemoveAccounts := false;
  end;
end;

// Removes a given list of accounts from candidates and recommended mems
procedure TRecommended_Mems.RemoveAccountsFromMems(AccountList: TBank_Account_List; DoPopulate: boolean = True);
const
  ThisMethodName = 'RemoveAccountsFromMems.3';
var
  i: integer;
  MaintainMemScanStatus: boolean;
  NoTiming : boolean;
  StartTickCount : int64;
  TimeTaken : double;
begin
  NoTiming := fRemoveAccounts;
  fRemoveAccounts := true;
  MaintainMemScanStatus := False;

  if (DebugMe and (not NoTiming)) then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');
    StartTickCount := GetTickCount();
  end;

  try
    if Assigned(frmMain) then
    begin
      MaintainMemScanStatus := frmMain.MemScanIsBusy;
      frmMain.MemScanIsBusy := True;
    end;

    Unscanned.FreeAll;

    for i := 0 to AccountList.ItemCount - 1 do
      RemoveAccountFromMems(AccountList.Bank_Account_At(i).baFields.baBank_Account_Number);

    if DoPopulate then
      for i := 0 to AccountList.ItemCount - 1 do
        PopulateUnscannedListOneAccount(AccountList.Bank_Account_At(i), False);

    if (DebugMe and (not NoTiming)) then
    begin
      TimeTaken := (GetTickCount - StartTickCount)/1000;
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End - Time Taken ' + floattostr(TimeTaken) + ' seconds.');
    end;

  finally
    if Assigned(frmMain) then
      if not MaintainMemScanStatus then
        frmMain.MemScanIsBusy := False;
    fRemoveAccounts := false;
  end;
end;

// Called after we have created a new memorisation, any matching recommended mems should be deleted.
// There may be several if a master mem has been added, but should only be one for normal (account
// specific) memorisations
procedure TRecommended_Mems.RemoveRecommendedMems(Account: string; EntryType: byte; StatementDetails: string;
                                                  AddedMasterMem: boolean);
var
  i: integer;
  memRec: tRecommended_Mem_Rec;
begin
  for i := Recommended.Last downto Recommended.First do
  begin
    memRec := Recommended.Recommended_Mem_At(i).rmFields;
    if ((memRec.rmBank_Account_Number = Account) or AddedMasterMem) and
    (memRec.rmType = EntryType) and
    (CompareText(memRec.rmStatement_Details, StatementDetails) = 0) then
    begin
      Recommended.AtFree(i);
      if (Account <> '') then
        // We've created a normal (non-master) mem, so there should only be
        // one matching recommended mem, so we don't need to keep looking
        break;
    end;
  end;
end;

function TRecommended_Mems.GetCountOfRecMemsInAccount(AccountNo: string): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 0 to MyClient.clRecommended_Mems.Recommended.ItemCount - 1 do
  begin
    if (Trim(MyClient.clRecommended_mems.Recommended.Recommended_Mem_At(i).rmFields.rmBank_Account_Number) =
    Trim(AccountNo)) then
      inc(Result);
  end;
end;

procedure TRecommended_Mems.RepopulateRecommendedMems;
const
  ThisMethodName = 'RepopulateRecommendedMems';
var
  RecMemScanningComplete: boolean;
  StartTickCount : int64;
  TimeTaken : double;
begin
  if DebugMe then
  begin
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');
    StartTickCount := GetTickCount;
  end;

  MyClient.clRecommended_Mems.Recommended.FreeAll;

  MyClient.clRecommended_Mems.Candidate.cpFields.cpCandidate_ID_To_Process := 1;

  fMemsV2.Reset;

  while True do
  begin
    RecMemScanningComplete := MyClient.clRecommended_Mems.MemScan(false, nil);     
    if RecMemScanningComplete then
      break;
  end;

  if DebugMe then
  begin
    TimeTaken := (GetTickCount - StartTickCount)/1000;
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End - Time Taken ' + floattostr(TimeTaken) + ' seconds.');
  end;
end;

// Clears the suggested mem data
procedure TRecommended_Mems.ResetAll;
const
  ThisMethodName = 'ResetAll';
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Start');

  try
    if Assigned(frmMain) then    
      frmMain.MemScanIsBusy := True;

    // Mems1 reset
    Candidates.FreeAll;
    Recommended.FreeAll;
    Unscanned.FreeAll;
    Candidate.cpFields.cpCandidate_ID_To_Process := 1;
    Candidate.cpFields.cpNext_Candidate_ID := 1;

    // Mems2 reset
    fMemsV2.Reset;
  finally
    if Assigned(frmMain) then    
      frmMain.MemScanIsBusy := False;
  end;
end;

initialization
begin
  DebugMe := DebugUnit(UnitName);
end;

end.
