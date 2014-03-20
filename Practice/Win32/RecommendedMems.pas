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
  BKDefs;

type
  TRecommended_Mems = class(TObject)
  private
    fBankAccounts: TBank_Account_List;

    fUnscanned: TUnscanned_Transaction_List;
    fCandidate: TCandidate_Mem_Processing;
    fCandidates: TCandidate_Mem_List;
    fRecommended: TRecommended_Mem_List;
    FLastCodingFrmKeyPress: TDateTime;

    function GetLastCodingFrmKeyPress: TDateTime;
    procedure GetMatchingCandidateRange(StatementDetails: string; var FirstCandidatePos, LastCandidatePos: integer);
    procedure RemoveAccountFromMems(AccountNo: string); Overload;
    // procedure ResetAll;
  public
    constructor Create(const aBankAccounts: TBank_Account_List); reintroduce; overload;
    constructor Create(const aBankAccount: TBank_Account); reintroduce; overload;
    destructor  Destroy; override;
    procedure SetBankAccounts(const aBankAccounts: TBank_Account_List);

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    property  Unscanned: TUnscanned_Transaction_List read fUnscanned;
    property  Candidate: TCandidate_Mem_Processing read fCandidate;
    property  Candidates: TCandidate_Mem_List read fCandidates;
    property  Recommended: TRecommended_Mem_List read fRecommended;

    procedure MemScan(RunningUnitTest: boolean; TestAccount: TBank_Account);
    procedure UpdateCandidateMems(TranRec: pTransaction_Rec; IsEditOperation: boolean);
    procedure SetLastCodingFrmKeyPress;
    procedure RemoveAccountFromMems(BankAccount: TBank_Account); Overload;
    procedure RemoveAccountsFromMems(AccountList: TStringList);
    procedure PopulateUnscannedListOneAccount(BankAccount: TBank_Account; RunningUnitTest: boolean);
    procedure PopulateUnscannedListAllAccounts(RunningUnitTest: boolean);
    procedure RemoveRecommendedMems(Account: string; EntryType: byte; StatementDetails: string);
  end;
                                                            
var
  recommended_Mems: TRecommended_Mems;

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
  SysUtils;

const
  UnitName = 'RecommendedMems';
  DebugMe: boolean = false;{ TSomeClass }

constructor TRecommended_Mems.Create(const aBankAccounts: TBank_Account_List);
begin
  fBankAccounts := aBankAccounts;

  fUnscanned := TUnscanned_Transaction_List.Create;
  fCandidate := TCandidate_Mem_Processing.Create;
  fCandidates := TCandidate_Mem_List.Create;
  fRecommended := TRecommended_Mem_List.Create;
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
  FreeAndNil(fCandidates);
  FreeAndNil(fUnscanned);
  FreeAndNil(fCandidate);
  FreeAndNil(fRecommended);

  inherited;
end;

procedure TRecommended_Mems.SetBankAccounts(const aBankAccounts: TBank_Account_List);
begin
  fBankAccounts := aBankAccounts;
end;

procedure TRecommended_Mems.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TRecommended_Mems.LoadFromStream';
var
  Token : byte;
  Msg   : String;
begin
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
end;

// Pass in a Statement Details string, and this procedure will put the position of the
// first matching Candidate into FirstCandidate and the last into LastCandidate.
// Uses a binary search as the Candidates should be in alphabetical order according to
// the contents of their Statement Details field
procedure TRecommended_Mems.GetMatchingCandidateRange(StatementDetails: string;
                                                      var FirstCandidatePos, LastCandidatePos: integer);
var
  First, Last, Pivot, FoundMatchPosition: integer;
  Found: boolean;
  CandidateList: TCandidate_Mem_List;
  SearchedStatementDetails: string;
begin
  try
    FirstCandidatePos := -1;
    LastCandidatePos  := -1;

    if Assigned(frmMain) then // false if this is a unit test, in which case we don't need to set this boolean anyway
      frmMain.MemScanIsBusy := True;
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
      // Compare the string in the middle with the searched one
      if (SearchedStatementDetails = StatementDetails) then
      begin
        Found := True;
        FoundMatchPosition := Pivot;
      end
      else if (SearchedStatementDetails > StatementDetails) then
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
    FirstCandidatePos := FoundMatchPosition;
    while (FirstCandidatePos > First) do
    begin
      if (CandidateList.Candidate_Mem_At(FirstCandidatePos - 1).cmFields.cmStatement_Details = StatementDetails) then
        FirstCandidatePos := FirstCandidatePos - 1
      else
        Break;
    end;

    LastCandidatePos := FoundMatchPosition;
    while (LastCandidatePos < Last) do
    begin
      if (CandidateList.Candidate_Mem_At(LastCandidatePos + 1).cmFields.cmStatement_Details = StatementDetails) then
        LastCandidatePos := LastCandidatePos + 1
      else
        Break;
    end;
  finally
    if Assigned(frmMain) then // false if this is a unit test, in which case we don't need to set this boolean anyway
      frmMain.MemScanIsBusy := False;
  end;
end;

procedure TRecommended_Mems.SaveToFile(var S: TIOStream);
begin
  S.WriteToken(tkBeginRecommended_Mems);

  fUnscanned.SaveToFile(S);
  fCandidate.SaveToFile(S);
  fCandidates.SaveToFile(S);
  fRecommended.SaveToFile(S);

  S.WriteToken(tkEndSection);
end;

function TRecommended_Mems.GetLastCodingFrmKeyPress: TDateTime;
begin
  Result := FLastCodingFrmKeyPress;
end;

procedure TRecommended_Mems.SetLastCodingFrmKeyPress;
begin
  FLastCodingFrmKeyPress := Time;
end;

procedure TRecommended_Mems.MemScan(RunningUnitTest: boolean; TestAccount: TBank_Account);
var
  InCodingForm  : boolean;
  StartTime     : TDateTime;

  // Returns true if the account for CandidateMem1 matches the account passed in
  function AddMemorisationIfUnique(Account            : TBank_Account;
                                   CandidateMem1      : TCandidate_Mem;
                                   CandidateMem2      : TCandidate_Mem;
                                   FirstCandidatePos  : integer;
                                   LastCandidatePos   : integer): boolean;
  var
    CandidatePos        : integer;
    ManuallyCodedCount  : integer;
    ExcludeMem          : boolean;
    Memorisation        : TMemorisation;
    MemsPos             : integer;
    NewRecMem           : TRecommended_Mem;
    UncodedCount        : integer;
  begin
    Result := False;
    // We can check if the account matches here, no need to proceed further if it doesn't match
    if (CandidateMem1.cmFields.cmBank_Account_Number = Account.baFields.baBank_Account_Number) then
    begin
      ExcludeMem := False;
      for MemsPos := Account.baMemorisations_List.First to Account.baMemorisations_List.Last do
      begin
        Memorisation := Account.baMemorisations_List.Memorisation_At(MemsPos);
        if (CandidateMem1.cmFields.cmType = Memorisation.mdFields.mdType) and
           (CandidateMem1.cmFields.cmStatement_Details = Memorisation.mdFields.mdStatement_Details) then
        begin
          ExcludeMem := True;
          Break;
        end;
      end;

      // Check if any candidates have a matching account code, and matching
      // statement details, if so exclude them too
      // TODO: optimize this if possible
      for CandidatePos := 0 to Candidates.ItemCount - 1 do
      begin
        CandidateMem2 := Candidates.Candidate_Mem_At(CandidatePos);
        if (CandidateMem1.cmFields.cmAccount = CandidateMem2.cmFields.cmAccount) and
        (CandidateMem1.cmFields.cmStatement_Details = CandidateMem2.cmFields.cmStatement_Details) and
        not (CandidateMem2.cmFields.cmCoded_By in [cbManual, cbNotCoded]) then
          ExcludeMem := True;
      end;

      if not ExcludeMem then
      begin
        // Let's get the counts for manually coded and uncoded (blank) transactions
        ManuallyCodedCount := 0;
        UncodedCount := 0;
        for CandidatePos := FirstCandidatePos to LastCandidatePos do
        begin
          CandidateMem2 := Candidates.Candidate_Mem_At(CandidatePos);
          if (CandidateMem1.cmFields.cmBank_Account_Number = CandidateMem2.cmFields.cmBank_Account_Number) then
          begin
            if (CandidateMem2.cmFields.cmCoded_By = cbManual) then
              ManuallyCodedCount := ManuallyCodedCount + CandidateMem2.cmFields.cmCount
            else if (CandidateMem2.cmFields.cmCoded_By = cbNotCoded) then
              UncodedCount := UncodedCount + CandidateMem2.cmFields.cmCount;
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
    Account                 : TBank_Account;
    AccountCodesDiffer      : boolean;
    AccountsPos             : integer;
    BlankStatementDetails   : boolean;
    Candidate2HasBlankCode  : boolean;
    CandidatePos             : integer;
    CandidateMem1           : TCandidate_Mem;
    CandidateMem2           : TCandidate_Mem;
    CodedByIsManual         : boolean;
    // EitherAccountIsBlank    : boolean;
    ExclusionFound          : boolean;
    FirstCandidatePos       : integer;
    CandidateToProcess      : integer;
    LastCandidatePos        : integer;                    
    NextCandidateID         : integer;
  begin
    if (Candidate.cpFields.cpCandidate_ID_To_Process < 1) then
      Candidate.cpFields.cpCandidate_ID_To_Process := 1;
    CandidateToProcess := Candidate.cpFields.cpCandidate_ID_To_Process;
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
      // Does the candidate have a count >= 3, is manually coded, and it isn't dissected?
      if (CandidateMem1.cmFields.cmCount >= 3) and
         (CandidateMem1.cmFields.cmCoded_By = cbManual) and
         (CandidateMem1.cmFields.cmAccount <> DISSECT_DESC) then
      begin
        Assert((CandidateMem1.cmFields.cmAccount <> ''), 'Blank account code and manual coding should be mutually exclusive');
        GetMatchingCandidateRange(CandidateMem1.cmFields.cmStatement_Details,
                                  FirstCandidatePos, LastCandidatePos);
        ExclusionFound := False;
        // Checking for exclusions: does the key exist in the candidate list with a
        // different code (including dissections, which will always have the code
        // 'DISSECT' and thus be excluded when we compare account codes, as our
        // original candidate will never be a dissection, these are filtered out
        // earlier) or a coding type other than manual? Also, is Statement
        // Details NOT blank?
        CandidateMem2 := nil;
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
            CodedByIsManual := (CandidateMem2.cmFields.cmCoded_By = cbManual);
            Candidate2HasBlankCode := (CandidateMem2.cmFields.cmAccount = '');
            BlankStatementDetails := (CandidateMem1.cmFields.cmStatement_Details = '');

            {
            if ((AccountCodesDiffer and not EitherAccountIsBlank) or
            (CodedByIsManual = false)) and
            (Candidate2HasBlankCode = false) then
            }
            if (((not CodedByIsManual) or AccountCodesDiffer) and
            (not Candidate2HasBlankCode)) or
            BlankStatementDetails then
            begin
              // Don't recommend this candidate
              ExclusionFound := True;
              Break;
            end;
          end;
        end;
        if not ExclusionFound then
        begin
          // Does an existing matching memorisation already exist? Check the candidate against all
          // existing memorisations for all of the clients bank accounts. If the following match:
          // * Entry type
          // * Bank Account Number
          // * Statement Details
          // ... then the answer is yes, so we don't add this candidate to the recommended mems list
          if RunningUnitTest then
            AddMemorisationIfUnique(TestAccount, CandidateMem1, CandidateMem2, FirstCandidatePos, LastCandidatePos)
          else
          begin
            for AccountsPos := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
            begin
              Account := MyClient.clBank_Account_List.Bank_Account_At(AccountsPos);
              if AddMemorisationIfUnique(Account, CandidateMem1, CandidateMem2, FirstCandidatePos, LastCandidatePos) then
                Break;
            end; // for AccountsPos := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
          end;
        end; // if not ExclusionFound then
      end; // if (CandidateToProcess < NextCandidateID) then
    end else
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
          Assert(not Assigned(pTranRec), 'pTranRec should not be nil here');
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
             (pTranRec.txStatement_Details = cMem.cmFields.cmStatement_Details) then
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
              if (cMem.cmFields.cmStatement_Details <=
              Candidates.Candidate_Mem_At(i).cmFields.cmStatement_Details) then
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
      Assert((Candidate.cpFields.cpCandidate_ID_To_Process = 1), 'cpCandidate_ID_To_Process should be 1, but it isn''t');
      Candidate.cpFields.cpCandidate_ID_To_Process := 1;
    end;
  end;
begin
  if Assigned(myClient) or RunningUnitTest then // Is the client file open?
  begin
    // Store current time
    StartTime := Time;
    // Are we in the coding screen?
    if Assigned(Screen.ActiveForm) then
      InCodingForm := (TfrmCoding.ClassName = Screen.ActiveForm.ClassName)
    else
      InCodingForm := False;
    // Has it been more than 33 milliseconds yet?
    while ((MilliSecondsBetween(StartTime, Time) < 33) or RunningUnitTest) do
    begin
      // Are we in the coding form, and has there been a keypress in the last two seconds?
      if InCodingForm and (MilliSecondsBetween(StartTime, GetLastCodingFrmKeyPress) <= 2000) then
        Exit; // We are and there has, let's not do any scanning so that we don't interfere with the user
      // Is the unscanned list empty?
      if (Unscanned.ItemCount = 0) then
      begin
        // Unscanned list is empty, so do recommended processing
        if DoRecommendedMemProcessing then
          // Unscanned transaction list is empty, candidate and recommended mem
          // processing is done, nothing left to do, time to crack a beer
          Exit;
      end
      else
      begin
        // There are still unscanned transactions, so do candidate processing
        DoCandidateMemProcessing;
      end;
    end;
  end;
end;

// This procedure should be called when a tranaction is edited or deleted
procedure TRecommended_Mems.UpdateCandidateMems(TranRec: pTransaction_Rec; IsEditOperation: boolean);
var
  Account               : TBank_Account;
  CandidateInt          : integer;
  CandidateMemRec       : tCandidate_Mem_Rec;
  FirstCandidatePos     : integer;
  LastCandidatePos      : integer;
  MatchingCandidatePos  : integer;
  NewUnscannedTran      : TUnscanned_Transaction;
begin
  if not Assigned(TranRec) then
    Exit; // this shouldn't happen!
  try
    frmMain.MemScanIsBusy := True;

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
    GetMatchingCandidateRange(TranRec.txStatement_Details,
                              FirstCandidatePos,
                              LastCandidatePos);
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
    if IsEditOperation then
    begin
      // Add modified transaction to unscanned list. We can use the old details
      // (bank account and sequence number), because they don't change when a
      // transaction gets modified by the user
      NewUnscannedTran := TUnscanned_Transaction.Create;
      NewUnscannedTran.utFields.utBank_Account_Number := Account.baFields.baBank_Account_Number;
      NewUnscannedTran.utFields.utSequence_No := TranRec.txSequence_No;
      Unscanned.Insert(NewUnscannedTran);
    end;

    // Rescan candidates later
    Candidate.cpFields.cpCandidate_ID_To_Process := 1;
    // Clear recommended memorisation list
    Recommended.FreeAll;
  finally
    frmMain.MemScanIsBusy := False;
  end;
end;

// Builds the unscanned transactions list for all bank accounts
procedure TRecommended_Mems.PopulateUnscannedListAllAccounts(RunningUnitTest: boolean);
var
  iBankAccount: integer;
begin
  // TODO: add simple dialog (no progress bar)
  // Unscanned and Candidates must be empty
  if (Unscanned.ItemCount <> 0) or (Candidates.ItemCount <> 0) then
    exit;

  for iBankAccount := 0 to fBankAccounts.ItemCount-1 do
    PopulateUnscannedListOneAccount(fBankAccounts[iBankAccount], RunningUnitTest);
end;

// Builds the unscanned transactions list for one bank account
procedure TRecommended_Mems.PopulateUnscannedListOneAccount(BankAccount: TBank_Account; RunningUnitTest: boolean);
var
  iTransaction: integer;
  New: TUnscanned_Transaction;
  Transaction: pTransaction_Rec;
begin
  try
    if not RunningUnitTest then
      frmMain.MemScanIsBusy := True;
    for iTransaction := 0 to BankAccount.baTransaction_List.ItemCount-1 do
    begin
      Transaction := BankAccount.baTransaction_List.Transaction_At(iTransaction);
      New := TUnscanned_Transaction.Create;
      New.utFields.utBank_Account_Number := BankAccount.baFields.baBank_Account_Number;
      New.utFields.utSequence_No := Transaction.txSequence_No;
      Unscanned.Insert(New);
    end;
  finally
    if not RunningUnitTest then    
      frmMain.MemScanIsBusy := False;
  end;

  Candidate.cpFields.cpCandidate_ID_To_Process := 1;
  Candidate.cpFields.cpNext_Candidate_ID := 1;
end;

// Removes an account from candidates and recommended mems. Should be called when:
// * Purging an account (in this case, via the RemoveAccountsFromMems method below this one)
// * Merging an account
// * Unattaching an account
procedure TRecommended_Mems.RemoveAccountFromMems(AccountNo: string);
var
  i: integer;
  LoopStart: integer;
begin
  try
    if Assigned(frmMain) then // false for unit tests, which don't need to set this boolean anyway
      frmMain.MemScanIsBusy := True;
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

    // Delete all recommended mems with this account number
    LoopStart := Recommended.ItemCount - 1;
    if (LoopStart >= 0) then
      for i := LoopStart downto 0 do
        if (Recommended.Recommended_Mem_At(i).rmFields.rmBank_Account_Number = AccountNo) then
          Recommended.AtFree(i);

    // Will need to rebuild recommended mems later, so set ID To Proces back to the start of Candidates
    fCandidate.cpFields.cpCandidate_ID_To_Process := 1;
  finally
    if Assigned(frmMain) then
      frmMain.MemScanIsBusy := False;
  end;
end;

procedure TRecommended_Mems.RemoveAccountFromMems(BankAccount: TBank_Account);
begin
  RemoveAccountFromMems(BankAccount.baFields.baBank_Account_Number);
end;

// RemoveAccountsFromMems is only called when purging transactions, if you're
// using it for other reasons you may not want the part where it populates
// the unscanned list, see comment below
procedure TRecommended_Mems.RemoveAccountsFromMems(AccountList: TStringList);
var
  BankAccount: TBank_Account;
  i: integer;
begin
  for i := 0 to AccountList.Count - 1 do
    RemoveAccountFromMems(AccountList.Strings[i]);

  frmMain.MemScanIsBusy := True;
  try
    // Purge may only remove some of the data for this account, but we have removed all the
    // candidates with a matching account number, so we need to add all the transactions
    // for this account to the unscanned list
    for i := 0 to AccountList.Count - 1 do
    begin
      BankAccount := MyClient.clBank_Account_List.FindCode(AccountList.Strings[i]);
      PopulateUnscannedListOneAccount(BankAccount, False);
    end;
  finally
    frmMain.MemScanIsBusy := False;
  end;
end;

// Called after we have created a new memorisation, any matching recommended mems should be deleted.
// There may be several if a master mem has been added, but should only be one for normal (account
// specific) memorisations
procedure TRecommended_Mems.RemoveRecommendedMems(Account: string; EntryType: byte; StatementDetails: string);
var
  i: integer;
  memRec: tRecommended_Mem_Rec;
begin
  for i := 0 to Recommended.ItemCount - 1 do
  begin
    memRec := Recommended.Recommended_Mem_At(i).rmFields;
    // If the account is blank, it's because we've created a new master mem,
    // which is not specific to one account
    if ((memRec.rmBank_Account_Number = Account) or (Account = '')) and
    (memRec.rmType = EntryType) and
    (memRec.rmStatement_Details = StatementDetails) then
    begin
      Recommended.AtFree(i);
      if (Account <> '') then
        // We've created a normal (non-master) mem, so there should only be
        // one matching recommended mem, so we don't need to keep looking
        break;
    end;
  end;

end;

// This is here for debugging purposes, it shouldn't be used anywhere permanently
{
procedure TRecommended_Mems.ResetAll;
begin
  try
    frmMain.MemScanIsBusy := True;
    Candidates.FreeAll;
    Candidates.Destroy;
    Recommended.FreeAll;
    Recommended.Destroy;
    Unscanned.FreeAll;
    Unscanned.Destroy;
    Candidate.cpFields.cpCandidate_ID_To_Process := 1;
    Candidate.cpFields.cpNext_Candidate_ID := 1;
  finally
    frmMain.MemScanIsBusy := False;
  end;                                                  
end;
}

end.
