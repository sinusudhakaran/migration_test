unit RecommendedMems;

interface

uses
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
  public
    constructor Create(const aBankAccounts: TBank_Account_List);
    destructor  Destroy; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    procedure UpdateUnprocessedAndCandidateMems;

    property  Unscanned: TUnscanned_Transaction_List read fUnscanned;
    property  Candidate: TCandidate_Mem_Processing read fCandidate;
    property  Candidates: TCandidate_Mem_List read fCandidates;
    property  Recommended: TRecommended_Mem_List read fRecommended;

    procedure MemScan;
    procedure UpdateCandidateMems(TranRec: pTransaction_Rec; IsEditOperation: boolean);
    procedure SetLastCodingFrmKeyPress;
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

destructor TRecommended_Mems.Destroy;
begin
  FreeAndNil(fCandidates);
  FreeAndNil(fUnscanned);
  FreeAndNil(fCandidate);
  FreeAndNil(fRecommended);

  inherited;
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
  Candidates: TCandidate_Mem_List;
  SearchedStatementDetails: string;
begin
  // for i := MyClient.clRecommended_Mems.Candidates.First to MyClient.clRecommended_Mems.Candidates.Last do
  Candidates := MyClient.clRecommended_Mems.Candidates;
  First := Candidates.First;
  Last := Candidates.Last;
  Found := False;

  // Find a Candidate whose Statement Details matched those we have passed in
  FoundMatchPosition := 0; // This value shouldn't get used
  while (First <= Last) and (not Found) do
  begin
    // Get the middle of the range
    Pivot := (First + Last) div 2;
    SearchedStatementDetails := Candidates.Candidate_Mem_At(Pivot).cmFields.cmStatement_Details;
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

  // In a normal binary search we would be done, but in our case there may be several
  // matching candidates (we wouldn't expect there to be too many), and we need to
  // know about them all. So let's find the positions of the first and last candidates
  FirstCandidatePos := FoundMatchPosition;
  while (FirstCandidatePos > First) do
  begin
    if (Candidates.Candidate_Mem_At(FirstCandidatePos - 1).cmFields.cmStatement_Details = StatementDetails) then
      FirstCandidatePos := FirstCandidatePos - 1
    else
      Break;
  end;

  LastCandidatePos := FoundMatchPosition;
  while (LastCandidatePos < Last) do
  begin
    if (Candidates.Candidate_Mem_At(LastCandidatePos + 1).cmFields.cmStatement_Details = StatementDetails) then
      LastCandidatePos := LastCandidatePos + 1
    else
      Break;
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

procedure TRecommended_Mems.UpdateUnprocessedAndCandidateMems;
var
  iBankAccount: integer;
  BankAccount: TBank_Account;
  iTransaction: integer;
  Transaction: pTransaction_Rec;
  New: TUnscanned_Transaction;
begin
  // Unscanned and Candidates must be empty
  if (Unscanned.ItemCount <> 0) or (Candidates.ItemCount <> 0) then
    exit;

  for iBankAccount := 0 to fBankAccounts.ItemCount-1 do
  begin
    BankAccount := fBankAccounts[iBankAccount];

    for iTransaction := 0 to BankAccount.baTransaction_List.ItemCount-1 do
   begin
      Transaction := BankAccount.baTransaction_List.Transaction_At(iTransaction);

      New := TUnscanned_Transaction.Create;
      New.utFields.utBank_Account_Number := BankAccount.baFields.baBank_Account_Number;
      New.utFields.utSequence_No := Transaction.txSequence_No;

      Unscanned.Insert(New);
    end;
  end;
end;

function TRecommended_Mems.GetLastCodingFrmKeyPress: TDateTime;
begin
  Result := FLastCodingFrmKeyPress;
end;

procedure TRecommended_Mems.SetLastCodingFrmKeyPress;
begin
  FLastCodingFrmKeyPress := Time;
end;

procedure TRecommended_Mems.MemScan;
var
  InCodingForm  : boolean;
  StartTime     : TDateTime;

  // Does the recommended memorisation processing, returns true when this is complete
  function DoRecommendedMemProcessing: boolean;
  var
    Account              : TBank_Account;
    AccountCodesDiffer   : boolean;
    AccountIsBlank       : boolean;
    AccountsPos          : integer;
    CandidateMem1        : TCandidate_Mem;
    CandidateMem2        : TCandidate_Mem;
    CandidatePos         : integer;
    CodedByIsManual      : boolean;
    ExclusionFound       : boolean;
    FirstCandidatePos    : integer;
    IDToProcess          : integer;
    LastCandidatePos     : integer;
    ManuallyCodedCount   : integer;
    MemAdded             : boolean;
    Memorisation         : TMemorisation;
    MemsPos              : integer;
    NewRecMem            : TRecommended_Mem;
    NextCandidateID      : integer;
    UncodedCount         : integer;
  begin
    IDToProcess     := MyClient.clRecommended_Mems.Candidate.cpFields.cpCandidate_ID_To_Process;
    NextCandidateID := MyClient.clRecommended_Mems.Candidate.cpFields.cpNext_Candidate_ID;
    // Is there another candidate left to process?
    if (IDToProcess < NextCandidateID) then
    begin
      // Yes there is
      Result := False;
      // Get candidate details
      CandidateMem1 := MyClient.clRecommended_Mems.Candidates.Candidate_Mem_At(IDToProcess);
      // Increment next candidate to process
      MyClient.clRecommended_Mems.Candidate.cpFields.cpCandidate_ID_To_Process :=
        MyClient.clRecommended_Mems.Candidate.cpFields.cpCandidate_ID_To_Process + 1;
      // Does the candidate have a count >= 3, is manually coded, and it isn't dissected?
      if (CandidateMem1.cmFields.cmCount >= 3) and
         (CandidateMem1.cmFields.cmCoded_By = cbManual) and
         (CandidateMem1.cmFields.cmAccount <> DISSECT_DESC) then
      begin
        GetMatchingCandidateRange(CandidateMem1.cmFields.cmStatement_Details,
                                  FirstCandidatePos, LastCandidatePos);
        ExclusionFound := False;
        // Checking for exclusions: does the key exist in the candidate list with a
        // different code (including dissections, which will always have the code
        // 'DISSECT' and thus be excluded when we compare account codes, as our
        // original candidate will never be a dissection, these are filtered out
        // earlier) or a coding type other than manual? 
        for CandidatePos := FirstCandidatePos to LastCandidatePos do
        begin
          CandidateMem2 := Candidates.Candidate_Mem_At(CandidatePos);
          AccountCodesDiffer := (CandidateMem1.cmFields.cmAccount <> CandidateMem2.cmFields.cmAccount);
          AccountIsBlank := (CandidateMem1.cmFields.cmAccount = '');
          CodedByIsManual := (CandidateMem2.cmFields.cmCoded_By = cbManual);
          if (AccountCodesDiffer and not AccountIsBlank) or not CodedByIsManual then
          begin
            // Don't recommend this candidate, as there are existing candidates which
            // conflict with it
            ExclusionFound := True;
            Break;
          end;
        end;
        if not ExclusionFound then
        begin
          // Let's get the counts for manually coded and uncoded (blank) transactions
          ManuallyCodedCount := 0;
          UncodedCount := 0;
          for CandidatePos := FirstCandidatePos to LastCandidatePos do
          begin
            CandidateMem2 := Candidates.Candidate_Mem_At(CandidatePos);
            if (CandidateMem2.cmFields.cmCoded_By = cbManual) then
              ManuallyCodedCount := ManuallyCodedCount + CandidateMem2.cmFields.cmCount
            else if (CandidateMem2.cmFields.cmCoded_By = cbNotCoded) then
              UncodedCount := UncodedCount + CandidateMem2.cmFields.cmCount;
          end;            

          // Does an existing matching memorisation already exist? Check the candidate against all
          // existing memorisations for all of the clients bank accounts. If the following match:
          // * Entry type
          // * Bank Account Number
          // * Statement Details
          // ... then the answer is yes, so we don't add this candidate to the recommended mems list
          MemAdded := False;
          for AccountsPos := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
          begin
            Account := MyClient.clBank_Account_List.Bank_Account_At(AccountsPos);
            // We can check if the account matches here, no need to proceed further if it doesn't match
            if (CandidateMem1.cmFields.cmBank_Account_Number <> Account.baFields.baBank_Account_Number) then
            begin
              for MemsPos := Account.baMemorisations_List.First to Account.baMemorisations_List.Last do
              begin
                Memorisation := Account.baMemorisations_List.Memorisation_At(MemsPos);
                if (CandidateMem1.cmFields.cmType <> Memorisation.mdFields.mdType) or
                   (CandidateMem1.cmFields.cmStatement_Details <> Memorisation.mdFields.mdStatement_Details) then
                begin
                  // There is no matching existing memorisation, so let's add this candidate
                  // to recommended mems. As far as I can see this doesn't need to be added
                  // alphabetically, but we can change this later if needed
                  // MyClient.clRecommended_Mems.Recommended.Insert();
                  NewRecMem := TRecommended_Mem.Create;
                  NewRecMem.rmFields.rmType                 := CandidateMem1.cmFields.cmType;
                  NewRecMem.rmFields.rmBank_Account_Number  := CandidateMem1.cmFields.cmBank_Account_Number;
                  NewRecMem.rmFields.rmAccount              := CandidateMem1.cmFields.cmAccount;
                  NewRecMem.rmFields.rmStatement_Details    := CandidateMem1.cmFields.cmStatement_Details;
                  NewRecMem.rmFields.rmManual_Count         := ManuallyCodedCount;
                  NewRecMem.rmFields.rmUncoded_Count        := UncodedCount;
                  MyClient.clRecommended_Mems.Recommended.Insert(NewRecMem);
                  MemAdded := True;
                  Break;
                end;
              end;
              if MemAdded then
                Break;
            end;
          end;
        end;
      end; // if (IDToProcess < NextCandidateID) then                                 
    end else
      Result := True;
  end;

  procedure DoCandidateMemProcessing;
  var
    i                       : Integer;
    pTranRec                : pTransaction_Rec;
    ut                      : TUnscanned_Transaction;
    utAccount               : TBank_Account;
    cMem                    : TCandidate_Mem;
    MatchingCandidateFound  : boolean;
    NewCandidateInserted    : boolean;
  begin
    // Is unscanned list empty?
    if (MyClient.clRecommended_Mems.Unscanned.ItemCount > 0) then
    begin
      try
        // Get first unscanned transaction in unscanned transaction list
        ut := MyClient.clRecommended_Mems.Unscanned.Unscanned_Transaction_At(0);

        // Get transaction details for the transaction that matches the sequence number in our record
        utAccount := MyClient.clBank_Account_List.FindCode(ut.utFields.utBank_Account_Number);
        pTranRec := nil;
        for i := utAccount.baTransaction_List.First to utAccount.baTransaction_List.Last do
        begin
          pTranRec := utAccount.baTransaction_List.Transaction_At(i);
          if (pTranRec.txSequence_No = ut.utFields.utSequence_No) then
            break;
        end;
        if (pTranRec = nil) then
          Exit; // Shouldn't get to here

        // Does key exist in candidate memorisation list?
        MatchingCandidateFound := False;
        for i := MyClient.clRecommended_Mems.Candidates.First to MyClient.clRecommended_Mems.Candidates.Last do
        begin
          cMem := MyClient.clRecommended_Mems.Candidates.Candidate_Mem_At(i);
          // Checking our unscanned transaction against the candidate memorisation to see if
          // they match. We check to see if the following match:
          //   * Entry Type
          //   * Bank Account
          //   * Chart of Accounts code
          //   * Statement Details
          if (pTranRec.txType = cMem.cmFields.cmType) and
             (utAccount.baFields.baBank_Account_Number = cMem.cmFields.cmBank_Account_Number) and
             (pTranRec.txAccount = cMem.cmFields.cmAccount) and
             (pTranRec.txStatement_Details = cMem.cmFields.cmStatement_Details) then
          begin
            // There is already a matching Candidate Mem, so increase its reference count
            cMem.cmFields.cmCount := cMem.cmFields.cmCount + 1;
            MatchingCandidateFound := True;
          end;
        end;
        if not MatchingCandidateFound then
        begin
          // We haven't found a matching Candidate Mem, so create a new one
          cMem := TCandidate_Mem.Create;
          cMem.cmFields.cmID := MyClient.clRecommended_Mems.Candidate.cpFields.cpNext_Candidate_ID;

          // Increase next candidate ID for the next candidate to be created
          MyClient.clRecommended_Mems.Candidate.cpFields.cpNext_Candidate_ID :=
            MyClient.clRecommended_Mems.Candidate.cpFields.cpNext_Candidate_ID + 1;

          // Fill in details for the new candidate
          cMem.cmFields.cmCount := 1;
          cMem.cmFields.cmType := pTranRec.txType;
          cMem.cmFields.cmBank_Account_Number := utAccount.baFields.baBank_Account_Number;
          cMem.cmFields.cmCoded_By := pTranRec.txCoded_By;
          cMem.cmFields.cmAccount := pTranRec.txAccount;
          cMem.cmFields.cmStatement_Details := pTranRec.txStatement_Details;

          // Insert the new candidate in alphabetical order according to Statement Details
          if (MyClient.clRecommended_Mems.Candidates.ItemCount > 0) then
          begin
            NewCandidateInserted := False;
            for i := MyClient.clRecommended_Mems.Candidates.First to MyClient.clRecommended_Mems.Candidates.Last do
            begin
              if (cMem.cmFields.cmStatement_Details <=
              MyClient.clRecommended_Mems.Candidates.Candidate_Mem_At(i).cmFields.cmStatement_Details) then
              begin
                MyClient.clRecommended_Mems.Candidates.AtInsert(i, cMem);
                NewCandidateInserted := True;
                Break;
              end;
            end;
            if not NewCandidateInserted then
              MyClient.clRecommended_Mems.Candidates.Insert(cMem); // insert at the end
          end else
            MyClient.clRecommended_Mems.Candidates.Insert(cMem); // this is the first candidate in the list
        end;

      finally
        MyClient.clRecommended_Mems.Unscanned.AtDelete(0); // remove unscanned transaction from list
      end;
    end;
  end;
begin
  if Assigned(myClient) then // Is the client file open?
  begin
    // Store current time
    StartTime := Time;
    // Are we in the coding screen?
    InCodingForm := False;
    if Assigned(TForm(TfrmCoding)) then
      InCodingForm := (TfrmCoding.ClassName = Screen.ActiveForm.ClassName);
    if InCodingForm then
    begin
      // Has it been more than 33 milliseconds yet?
      while (MilliSecondsBetween(StartTime, Time) < 33) do
      begin
        // Has there been a keypress in the last two seconds?
        if (MilliSecondsBetween(StartTime, GetLastCodingFrmKeyPress) <= 2000) then
          Exit; // There has, so let's not do any scanning so that we don't interfere with the user
        // Is the unscanned list empty?
        if (MyClient.clRecommended_Mems.Unscanned.Last = -1) then
        begin
          // Unscanned list is empty, so do recommended processing
          if DoRecommendedMemProcessing then
            // Unscanned transaction list is empty, candidate and recommended mem
            // processing is done, nothing left to do, time to crack a beer
            Exit;
        end else
        begin
          // There are still unscanned transactions, so do candidate processing
          DoCandidateMemProcessing;
        end;
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

  // Has a match been found?
  if (MatchingCandidatePos <> -1) then
  begin
    CandidateMemRec := Candidates.Candidate_Mem_At(MatchingCandidatePos).cmFields;
    // Decrease count in matching CandidateMem
    Candidates.Candidate_Mem_At(MatchingCandidatePos).cmFields.cmCount := CandidateMemRec.cmCount - 1;
    // Does the count for this CandidateMem now equal zero?
    if (Candidates.Candidate_Mem_At(MatchingCandidatePos).cmFields.cmCount = 0) then
      // Yes, so remove this candidate from the candidate list
      Candidates.AtDelete(MatchingCandidatePos);
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
  end;
end;

end.
