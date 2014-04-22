// Testing Recommended Memorisations

unit utRecommendedMems;
{$TYPEINFO ON} //Needed for classes with published methods

interface

uses
  baObj32,
  TestFramework; // DUnit

type
  TUnitTestRecommendedMems = class(TTestCase)
  private
    TestAccount: TBank_Account;
    procedure CreateTestAccount;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestRecommendedMems;
  end;

implementation

uses
  AuditMgr,
  BKchIO,
  bkConst,
  BKDefs,
  BKdsIO,
  RecommendedMems,
  SysUtils,
  trxList32,
  Windows;

{ TUnitTestTemplate }

procedure TUnitTestRecommendedMems.CreateTestAccount;
const
  Apr01_2004 = 147649;
  Apr02_2004 = Apr01_2004 + 1;
  Apr03_2004 = Apr01_2004 + 2;
  Apr04_2004 = Apr01_2004 + 3;
  Apr05_2004 = Apr01_2004 + 4;
  Apr06_2004 = Apr01_2004 + 5;
  Apr07_2004 = Apr01_2004 + 6;
  Apr08_2004 = Apr01_2004 + 7;
  Apr09_2004 = Apr01_2004 + 8;
  Apr10_2004 = Apr01_2004 + 9;
var
  pD: pDissection_Rec;
  pt: pTransaction_Rec;
begin
  //Bank account
  TestAccount := TBank_Account.Create(nil);
  TestAccount.baFields.baBank_Account_Number := '12345';
  TestAccount.baFields.baBank_Account_Name   := 'Account 1';
  TestAccount.baFields.baCurrent_Balance := 100;
  TestAccount.baFields.baContra_Account_Code := '680';
  TestAccount.baFields.baCurrency_Code := 'GBP';

  //Transaction
  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr01_2004;
  pT.txDate_Effective   := Apr01_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran1';
  pT.txStatement_Details := 'Details 1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '11';
  pT.txType := 30;
  pT.txCoded_By := cbManual;

  //Dissection
  pD := New_Dissection_Rec;
  pD^.dsAccount         := '400';
  pD.dsAmount           := 6000;
  pD.dsGST_Class        := 2;
  pD.dsGST_Amount       := Round(6000/9);
  pD.dsNotes            := 'L1 NOTE';
  pD.dsGL_Narration     := 'Line 1';
  AppendDissection( pT, pD);
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  // More transactions
  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr02_2004;
  pT.txDate_Effective   := Apr02_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran2';
  pT.txStatement_Details := 'Details 1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '12';
  pT.txType := 30;
  pT.txCoded_By := cbManual;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr03_2004;
  pT.txDate_Effective   := Apr03_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran3';
  pT.txStatement_Details := 'Details 1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '13';
  pT.txType := 30;
  pT.txCoded_By := cbManual;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr04_2004;
  pT.txDate_Effective   := Apr04_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran4';
  pT.txStatement_Details := 'Details 1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '14';
  pT.txType := 30;
  pT.txCoded_By := cbManual;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran5';
  pT.txStatement_Details := 'Details 1';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '15';
  pT.txType := 30;
  pT.txCoded_By := cbNotCoded;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran6';
  pT.txStatement_Details := 'Details 2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '16';
  pT.txType := 50;
  pT.txCoded_By := cbAutoPayee;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran7';
  pT.txStatement_Details := 'Details 2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '17';
  pT.txType := 50;
  pT.txCoded_By := cbAutoPayee;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '230';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran8';
  pT.txStatement_Details := 'Details 2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '18';
  pT.txType := 50;
  pT.txCoded_By := cbAutoPayee;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '231';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran9';
  pT.txStatement_Details := 'Details 2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '19';
  pT.txType := 50;
  pT.txCoded_By := cbManual;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '231';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran10';
  pT.txStatement_Details := 'Details 2';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '20';
  pT.txType := 60;
  pT.txCoded_By := cbManual;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '232';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran11';
  pT.txStatement_Details := 'Details 3';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '20';
  pT.txType := 70;
  pT.txCoded_By := cbManual;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '232';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran12';
  pT.txStatement_Details := 'Details 3';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '20';
  pT.txType := 70;
  pT.txCoded_By := cbManual;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '232';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran13';
  pT.txStatement_Details := 'Details 3';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '20';
  pT.txType := 70;
  pT.txCoded_By := cbManual;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);

  pT := TestAccount.baTransaction_List.New_Transaction;
  pT^.txDate_Presented  := Apr05_2004;
  pT.txDate_Effective   := Apr05_2004;
  pT.txAmount           := 6000;
  pT.txAccount          := '';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'Account 1 Tran14';
  pT.txStatement_Details := 'Details 3';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;
  pT.txGST_Class := 1;
  pt.txGST_Amount := Round(12000 / 9);
  pT.txExternal_GUID := '20';
  pT.txType := 70;
  pT.txCoded_By := cbNotCoded;
  TestAccount.baTransaction_List.Insert_Transaction_Rec( pT);
end;

procedure TUnitTestRecommendedMems.SetUp;
begin
  inherited;
  CreateTestAccount;
end;

procedure TUnitTestRecommendedMems.TearDown;
begin
  inherited;
  TestAccount.Free;
end;

procedure TUnitTestRecommendedMems.TestRecommendedMems;
var
  RecommendedMems: TRecommended_Mems;
  utBankAccount           : string[20];
  utSequenceNo            : integer;
begin
  RecommendedMems := TRecommended_Mems.Create(TestAccount);
  try
    RecommendedMems.PopulateUnscannedListOneAccount(TestAccount, True);

    // Testing Unscanned has been filled correctly
    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(0).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(0).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 1);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(1).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(1).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 2);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(2).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(2).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 3);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(3).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(3).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 4);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(4).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(4).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 5);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(5).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(5).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 6);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(6).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(6).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 7);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(7).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(7).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 8);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(8).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(8).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 9);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(9).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(9).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 10);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(10).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(10).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 11);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(11).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(11).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 12);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(12).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(12).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 13);

    utBankAccount := RecommendedMems.Unscanned.Unscanned_Transaction_At(13).utFields.utBank_Account_Number;
    utSequenceNo  := RecommendedMems.Unscanned.Unscanned_Transaction_At(13).utFields.utSequence_No;
    Check(utBankAccount = '12345');
    Check(utSequenceNo = 14);

    Check(RecommendedMems.Unscanned.ItemCount = 14);

    RecommendedMems.MemScan(True, TestAccount);

    // Unscanned list should have been emptied out
    Check(RecommendedMems.Unscanned.ItemCount = 0);

    // Candidate Processing
    Check(RecommendedMems.Candidate.cpFields.cpCandidate_ID_To_Process = 8);
    Check(RecommendedMems.Candidate.cpFields.cpNext_Candidate_ID = 8);

    // Candidates
    Check(RecommendedMems.Candidates.ItemCount = 7);

    // Candidate 0
    Check(RecommendedMems.Candidates.Candidate_Mem_At(0).cmFields.cmRecord_Type = 167);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(0).cmFields.cmCount = 1);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(0).cmFields.cmType = 30);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(0).cmFields.cmBank_Account_Number = '12345');
    Check(RecommendedMems.Candidates.Candidate_Mem_At(0).cmFields.cmCoded_By = cbNotCoded);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(0).cmFields.cmAccount = '');
    Check(AnsiCompareText(RecommendedMems.Candidates.Candidate_Mem_At(0).cmFields.cmStatement_Details, 'Details 1') = 0);

    // Candidate 1
    Check(RecommendedMems.Candidates.Candidate_Mem_At(1).cmFields.cmRecord_Type = 167);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(1).cmFields.cmCount = 4);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(1).cmFields.cmType = 30);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(1).cmFields.cmBank_Account_Number = '12345');
    Check(RecommendedMems.Candidates.Candidate_Mem_At(1).cmFields.cmCoded_By = cbManual);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(1).cmFields.cmAccount = '230');
    Check(AnsiCompareText(RecommendedMems.Candidates.Candidate_Mem_At(1).cmFields.cmStatement_Details, 'Details 2') = 0);

    // Candidate 2
    Check(RecommendedMems.Candidates.Candidate_Mem_At(2).cmFields.cmRecord_Type = 167);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(2).cmFields.cmCount = 1);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(2).cmFields.cmType = 60);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(2).cmFields.cmBank_Account_Number = '12345');
    Check(RecommendedMems.Candidates.Candidate_Mem_At(2).cmFields.cmCoded_By = cbManual);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(2).cmFields.cmAccount = '231');
    Check(AnsiCompareText(RecommendedMems.Candidates.Candidate_Mem_At(2).cmFields.cmStatement_Details, 'Details 3') = 0);

    // Candidate 3
    Check(RecommendedMems.Candidates.Candidate_Mem_At(3).cmFields.cmRecord_Type = 167);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(3).cmFields.cmCount = 1);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(3).cmFields.cmType = 50);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(3).cmFields.cmBank_Account_Number = '12345');
    Check(RecommendedMems.Candidates.Candidate_Mem_At(3).cmFields.cmCoded_By = cbManual);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(3).cmFields.cmAccount = '231');
    Check(AnsiCompareText(RecommendedMems.Candidates.Candidate_Mem_At(3).cmFields.cmStatement_Details, 'Details 4') = 0);

    // Candidate 4
    Check(RecommendedMems.Candidates.Candidate_Mem_At(4).cmFields.cmRecord_Type = 167);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(4).cmFields.cmCount = 3);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(4).cmFields.cmType = 50);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(4).cmFields.cmBank_Account_Number = '12345');
    Check(RecommendedMems.Candidates.Candidate_Mem_At(4).cmFields.cmCoded_By = cbAutoPayee);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(4).cmFields.cmAccount = '230');
    Check(AnsiCompareText(RecommendedMems.Candidates.Candidate_Mem_At(4).cmFields.cmStatement_Details, 'Details 5') = 0);

    // Candidate 5
    Check(RecommendedMems.Candidates.Candidate_Mem_At(5).cmFields.cmRecord_Type = 167);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(5).cmFields.cmCount = 1);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(5).cmFields.cmType = 70);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(5).cmFields.cmBank_Account_Number = '12345');
    Check(RecommendedMems.Candidates.Candidate_Mem_At(5).cmFields.cmCoded_By = cbNotCoded);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(5).cmFields.cmAccount = '');
    Check(AnsiCompareText(RecommendedMems.Candidates.Candidate_Mem_At(5).cmFields.cmStatement_Details, 'Details 6') = 0);

    // Candidate 6
    Check(RecommendedMems.Candidates.Candidate_Mem_At(6).cmFields.cmRecord_Type = 167);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(6).cmFields.cmCount = 3);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(6).cmFields.cmType = 70);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(6).cmFields.cmBank_Account_Number = '12345');
    Check(RecommendedMems.Candidates.Candidate_Mem_At(6).cmFields.cmCoded_By = cbManual);
    Check(RecommendedMems.Candidates.Candidate_Mem_At(6).cmFields.cmAccount = '232');
    Check(AnsiCompareText(RecommendedMems.Candidates.Candidate_Mem_At(6).cmFields.cmStatement_Details, 'Details 7') = 0);

    // Recommended Mems (only one for this set of data)
    Check(RecommendedMems.Recommended.ItemCount = 2);

    // Recommendation 0
    Check(RecommendedMems.Recommended.Recommended_Mem_At(0).rmFields.rmRecord_Type = 168);
    Check(RecommendedMems.Recommended.Recommended_Mem_At(0).rmFields.rmType = 30);
    Check(RecommendedMems.Recommended.Recommended_Mem_At(0).rmFields.rmBank_Account_Number = '12345');
    Check(RecommendedMems.Recommended.Recommended_Mem_At(0).rmFields.rmAccount = '230');
    Check(AnsiCompareText(RecommendedMems.Recommended.Recommended_Mem_At(0).rmFields.rmStatement_Details,
                          'Details 1') = 0);
    Check(RecommendedMems.Recommended.Recommended_Mem_At(0).rmFields.rmManual_Count = 4);
    Check(RecommendedMems.Recommended.Recommended_Mem_At(0).rmFields.rmUncoded_Count = 1);

    // Recommendation 1
    Check(RecommendedMems.Recommended.Recommended_Mem_At(1).rmFields.rmRecord_Type = 168);
    Check(RecommendedMems.Recommended.Recommended_Mem_At(1).rmFields.rmType = 70);
    Check(RecommendedMems.Recommended.Recommended_Mem_At(1).rmFields.rmBank_Account_Number = '12345');
    Check(RecommendedMems.Recommended.Recommended_Mem_At(1).rmFields.rmAccount = '232');
    Check(AnsiCompareText(RecommendedMems.Recommended.Recommended_Mem_At(1).rmFields.rmStatement_Details,
                          'Details 3') = 0);
    Check(RecommendedMems.Recommended.Recommended_Mem_At(1).rmFields.rmManual_Count = 3);
    Check(RecommendedMems.Recommended.Recommended_Mem_At(1).rmFields.rmUncoded_Count = 1);

    // Removing a recommendation
    RecommendedMems.RemoveRecommendedMems('12345', 70, 'Details 3', false);
    Check(RecommendedMems.Recommended.ItemCount = 1);

    // Removing an account from recommendations (in our case, the only account)
    RecommendedMems.RemoveAccountFromMems(TestAccount);
    Check(RecommendedMems.Recommended.ItemCount = 0);
    Check(RecommendedMems.Candidates.ItemCount = 0);

  finally
    RecommendedMems.Free;
  end;
end;

initialization
  TestFramework.RegisterTest(TUnitTestRecommendedMems.Suite);

end.
