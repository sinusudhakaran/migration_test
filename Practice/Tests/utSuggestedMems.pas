unit utSuggestedMems;

//------------------------------------------------------------------------------
interface

uses
  TestFramework,
  BKDEFS,
  baObj32,
  clObj32;

{$TYPEINFO ON} //Needed for classes with published methods

type
  TSuggestedMemsTestCase = class(TTestCase)
  private
    fTestClient : TClientObj;
    fExternal_GUID : integer;
    fBankAcc01 : TBank_Account;
  protected
    procedure RunAllmMemScan();
    function GetNextGuid() : string;
    procedure CreateClientWithGSTClasses();
    procedure CreateAndFillChartOnClient();
    function CreateAccountForClient(aBankAccNumber     : string;
                                    aBankAccName       : string;
                                    aCurrentBal        : Extended;
                                    aContraAccountCode : string;
                                    aCurrency_Code     : string) : TBank_Account;
    procedure InsertTranIntoAccount(aBankAcc : TBank_Account;
                                    aDate : integer;
                                    aAmount : Extended;
                                    aAccount : string;
                                    aCodedBy : byte;
                                    aNotes : string;
                                    aStatement_Details : string;
                                    aGST_Class : Byte;
                                    aGST_Amount : Extended);
    procedure InsertMemIntoAccount(aBankAcc : TBank_Account;
                                   aTranType : byte;
                                   aAccountCode : string;
                                   aMatchedStatementDetails : string);
    procedure UpdateTransaction(aTranIndex : integer; aAccountCode : string; aCodedBy : byte);

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExactMatchSuggestion;
    procedure TestPartialMatchSuggestion;
    procedure TestUncodedCountSuggestion;
    procedure TestExactMatchWithTwoDifferantCodes;
    procedure TestExactMatchWithDifferantCodedby;
    procedure TestTransactionCodedEdit;
    procedure TestTransactionUnCodedEdit;
    procedure TestTransactionDelete;
    procedure TestSuggestionBeingMemorized;
    procedure TestSuggestionWithInActiveChartCode;
    procedure TestSuggestionWithInValidChartCode;
    procedure TestSuggestionIgnoreList;
    procedure TestSuggestionListAndCountMethodsAreTheSame;
    procedure TestMultipleSuggestions;
  end;

//------------------------------------------------------------------------------
implementation

uses
  Classes,
  SysUtils,
  bkConst,
  BKchIO,
  BKdsIO,
  trxList32,
  Globals,
  SuggestedMems,
  MemorisationsObj,
  StDate,
  BKMLIO,
  SuggMemSortedList;

const
  Jan01_1980 = 138883;
  Apr01_2004 = 147649;
  Apr02_2004 = Apr01_2004 + 1;
  Apr03_2004 = Apr01_2004 + 2;
  Apr04_2004 = Apr01_2004 + 3;
  Apr05_2004 = Apr01_2004 + 4;

{ TSuggestedMemsTestCase }
//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.RunAllmMemScan;
begin
  while (fBankAcc01.baFields.baSuggested_UnProcessed_Count > 0) do
    SuggestedMem.RunMemScan();
end;

//------------------------------------------------------------------------------
function TSuggestedMemsTestCase.GetNextGuid: string;
begin
  inc(fExternal_GUID);
  Result := inttostr(fExternal_GUID);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.CreateClientWithGSTClasses;
begin
  fTestClient := TClientObj.Create;
  //basic client details
  fTestClient.clFields.clCode := 'UNITTEST';
  fTestClient.clFields.clName := 'DUnit Test Client';
  fTestClient.clFields.clCountry := 0;    //New Zealand
  fTestClient.clFields.clFile_Type := 0;  //banklink file
  fTestClient.clFields.clAccounting_System_Used := 0;
  fTestClient.clFields.clFinancial_Year_Starts := Apr01_2004;
  fTestClient.clFields.clMagic_Number  := 123456;

  //gst rates (NZ)
  fTestClient.clFields.clGST_Applies_From[1] := Jan01_1980;

  {Income}
  fTestClient.clFields.clGST_Class_Codes[1]  := 'I';
  fTestClient.clFields.clGST_Class_Names[1]  := 'GST on Sales';
  fTestClient.clFields.clGST_Class_Types[1]  := gtOutputTax;
  fTestClient.clFields.clGST_Rates[1,1]      := 125000;
  {Expenditure}
  fTestClient.clFields.clGST_Class_Codes[2]  := 'E';
  fTestClient.clFields.clGST_Class_Names[2]  := 'GST on Purchases';
  fTestClient.clFields.clGST_Class_Types[2]  := gtInputTax;
  fTestClient.clFields.clGST_Rates[2,1]      := 125000;
  {Exempt}
  fTestClient.clFields.clGST_Class_Codes[3]  := 'X';
  fTestClient.clFields.clGST_Class_Names[3]  := 'Exempt';
  fTestClient.clFields.clGST_Class_Types[3]  := gtExempt;
  fTestClient.clFields.clGST_Rates[3,1]      := 0;
  fTestClient.ClExtra.ceLocal_Currency_Code  := 'NZD';

  MyClient := fTestClient;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.CreateAndFillChartOnClient;
var
  Chart230 : pAccount_Rec;
  Chart400 : pAccount_Rec;
  Chart500 : pAccount_Rec;
begin
  //chart
  Chart230 := bkChio.New_Account_Rec;
  Chart230^.chAccount_Code := '230';
  Chart230^.chAccount_Description := 'Sales';
  Chart230^.chAccount_Type := atIncome;
  Chart230^.chGST_Class := 1;
  Chart230^.chPosting_Allowed := true;
  Chart230^.chInactive := false;
  fTestClient.clChart.Insert( Chart230);

  Chart400 := bkChio.New_Account_Rec;
  Chart400^.chAccount_Code := '400';
  Chart400^.chAccount_Description := 'Expenses 400';
  Chart400^.chAccount_Type := atExpense;
  Chart400^.chGST_Class := 2;
  Chart400^.chPosting_Allowed := true;
  Chart400^.chInactive := false;
  fTestClient.clChart.Insert( Chart400);

  Chart500 := bkChio.New_Account_Rec;
  Chart500^.chAccount_Code := '500';
  Chart500^.chAccount_Description := 'Expenses 500';
  Chart500^.chAccount_Type := atExpense;
  Chart500^.chGST_Class := 3;
  Chart500^.chPosting_Allowed := true;
  Chart500^.chInactive := true;
  fTestClient.clChart.Insert( Chart500);
end;

//------------------------------------------------------------------------------
function TSuggestedMemsTestCase.CreateAccountForClient(aBankAccNumber     : string;
                                                       aBankAccName       : string;
                                                       aCurrentBal        : Extended;
                                                       aContraAccountCode : string;
                                                       aCurrency_Code     : string) : TBank_Account;
begin
  Result := TBank_Account.Create(nil);

  Result.baFields.baBank_Account_Number         := aBankAccNumber;
  Result.baFields.baBank_Account_Name           := aBankAccName;
  Result.baFields.baCurrent_Balance             := aCurrentBal;
  Result.baFields.baContra_Account_Code         := aContraAccountCode;
  Result.baFields.baCurrency_Code               := aCurrency_Code;
  Result.baFields.baSuggested_UnProcessed_Count := 0;
  Result.baFields.baAccount_Type                := sbtData;
  Result.baFields.baNumber                      := 1;

  fTestClient.clBank_Account_List.Insert( Result);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.InsertTranIntoAccount(aBankAcc : TBank_Account;
                                                       aDate : integer;
                                                       aAmount : Extended;
                                                       aAccount : string;
                                                       aCodedBy : byte;
                                                       aNotes : string;
                                                       aStatement_Details : string;
                                                       aGST_Class : Byte;
                                                       aGST_Amount : Extended);
var
  pTranRec : pTransaction_Rec;
begin
    //create transactions
  pTranRec := aBankAcc.baTransaction_List.Setup_New_Transaction;

  pTranRec^.txBank_Seq               := aBankAcc.baFields.baNumber;
  pTranRec^.txDate_Presented         := aDate;
  pTranRec^.txDate_Effective         := aDate;
  pTranRec^.txAmount                 := aAmount;
  pTranRec^.txAccount                := aAccount;
  pTranRec^.txCoded_By               := aCodedBy;
  pTranRec^.txNotes                  := aNotes;
  pTranRec^.txGL_Narration           := aStatement_Details;
  pTranRec^.txStatement_Details      := aStatement_Details;
  pTranRec^.txTax_Invoice_Available  := false;
  pTranRec^.txPayee_Number           := 0;
  pTranRec^.txGST_Class              := aGST_Class;
  pTranRec^.txGST_Amount             := aGST_Amount;
  pTranRec^.txExternal_GUID          := GetNextGuid();
  pTranRec^.txSuggested_Mem_State    := tssUnScanned;
  pTranRec^.txSuggested_Mem_Index    := TRAN_SUGG_NOT_FOUND;
  pTranRec^.txSuggested_Manual_Count := 0;
  pTranRec^.txType                   := whWithdrawalEntryType[whNewZealand];

  aBankAcc.baTransaction_List.Insert_Transaction_Rec( pTranRec);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.InsertMemIntoAccount(aBankAcc : TBank_Account;
                                                      aTranType : byte;
                                                      aAccountCode : string;
                                                      aMatchedStatementDetails : string);
var
  TestMem : TMemorisation;
  MemLine : pMemorisation_Line_Rec;
begin
  TestMem := TMemorisation.Create(fTestClient.ClientAuditMgr);

  TestMem.mdFields.mdSequence_No                := 0;
  TestMem.mdFields.mdType                       := aTranType;

  TestMem.mdFields.mdMatch_on_Amount            := mxNo;
  TestMem.mdFields.mdAmount                     := 0;

  TestMem.mdFields.mdMatch_on_Analysis          := false;
  TestMem.mdFields.mdAnalysis                   := '';

  TestMem.mdFields.mdMatch_on_Other_Party       := false;
  TestMem.mdFields.mdOther_Party                := '';

  TestMem.mdFields.mdMatch_on_Notes             := false;
  TestMem.mdFields.mdNotes                      := '';

  TestMem.mdFields.mdMatch_on_Particulars       := false;
  TestMem.mdFields.mdParticulars                := '';

  TestMem.mdFields.mdMatch_on_Refce             := false;
  TestMem.mdFields.mdReference                  := '';

  TestMem.mdFields.mdMatch_On_Statement_Details := True;
  TestMem.mdFields.mdStatement_Details          := aMatchedStatementDetails;

  TestMem.mdFields.mdUse_Accounting_System      := false;
  TestMem.mdFields.mdAccounting_System          := 0;

  TestMem.mdFields.mdDate_Last_Applied          := 0;
  TestMem.mdFields.mdFrom_Date                  := 0;
  TestMem.mdFields.mdUntil_Date                 := 0;

  MemLine := BKMLIO.New_Memorisation_Line_Rec;
  MemLine.mlAccount                             := aAccountCode;
  TestMem.mdLines.Insert(MemLine);

  aBankAcc.baMemorisations_List.Insert_Memorisation(TestMem);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.UpdateTransaction(aTranIndex : integer; aAccountCode : string; aCodedBy : byte);
var
  TranRec : pTransaction_Rec;
begin
  TranRec := fBankAcc01.baTransaction_List.Transaction_At(aTranIndex);
  TranRec^.txAccount  := aAccountCode;
  TranRec^.txCoded_By := aCodedBy;

  SuggestedMem.SetSuggestedTransactionState(fBankAcc01, TranRec, tssUnScanned, true);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.SetUp;
begin
  inherited;
  fExternal_GUID := 999;
  SuggestedMem.StartMemScan(true);

  CreateClientWithGSTClasses();
  CreateAndFillChartOnClient();

  fBankAcc01 := CreateAccountForClient('000111222333', 'Test Account 01', 0, '680', 'NZD');
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TearDown;
begin
  inherited;
  SuggestedMem.StopMemScan(true);
  FreeAndNil(fTestClient);
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestExactMatchSuggestion;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction and checks that they are added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    if (SuggMemSortedList.ItemCount = 1) then
    begin
      SuggMemSortedListRec := SuggMemSortedList.GetPRec(0);

      Check((SuggMemSortedListRec^.Id = 1),'Id should be 1 at this point since it is the first Suggestion');
      Check((SuggMemSortedListRec^.AccType = whWithdrawalEntryType[whNewZealand]),'Account type was not the same (tran Type)');
      Check((SuggMemSortedListRec^.MatchedPhrase = 'Big Large Dog'),'Suggestion Matching Phrase is not correct');
      Check((SuggMemSortedListRec^.Account = '230'),'Account Code shouldh be 230 for this Suggestion');
      Check((SuggMemSortedListRec^.TotalCount = 3),'Total count should be 3 since there are 3 transactions');
      Check((SuggMemSortedListRec^.ManualCount = 3),'Manual count should be 3 since there are 3 maunaul transactions');
      Check((SuggMemSortedListRec^.UnCodedCount = 0),'Uncoded count should be 0 since there are No uncoded transactions');
      Check((SuggMemSortedListRec^.ManualAcountCount = 1),'ManualAcountCount should be 1 since there is only one Account code so far');
      Check((SuggMemSortedListRec^.IsExactMatch = true),'This should be an exact match since all statementdetails are the same');
      Check((SuggMemSortedListRec^.IsHidden = false),'IsHidden should be false since this has not been set and defaults to true');
    end;
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestPartialMatchSuggestion;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
  TranIndex : integer;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    // Add 3 partial match transaction and checks that they are not added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'Happy Face', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'Happy', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'Dog Happy Cat', 1, Round(120 / 9));

    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions since the Transaction are younger than 3 months old and less than 150 Transaction exist.');

    // Added 150 uncoded transaction and checks if the previous 3 transactions are added
    for TranIndex := 0 to 150 do
      InsertTranIntoAccount(fBankAcc01, CurrentDate()-300+TranIndex, -25, '', cbNotCoded, 'Note 01', 'Standard Uncoded Transaction', 1, Round(-25 / 9));

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should now be one suggestion since the Transcation count has gone over 150');

    if (SuggMemSortedList.ItemCount = 1) then
    begin
      SuggMemSortedListRec := SuggMemSortedList.GetPRec(0);

      Check((SuggMemSortedListRec^.Id = 1),'Id should be 1 at this point since it is the first Suggestion');
      Check((SuggMemSortedListRec^.AccType = whWithdrawalEntryType[whNewZealand]),'Account type was not the same (tran Type)');
      Check((SuggMemSortedListRec^.MatchedPhrase = '*HAPPY*'),'Suggestion Matching Phrase is not correct');
      Check((SuggMemSortedListRec^.Account = '230'),'Account Code shouldh be 230 for this Suggestion');
      Check((SuggMemSortedListRec^.TotalCount = 3),'Total count should be 3 since there are 3 transactions');
      Check((SuggMemSortedListRec^.ManualCount = 3),'Manual count should be 3 since there are 3 maunaul transactions');
      Check((SuggMemSortedListRec^.UnCodedCount = 0),'Uncoded count should be 0 since there are No uncoded transactions');
      Check((SuggMemSortedListRec^.ManualAcountCount = 1),'ManualAcountCount should be 1 since there is only one Account code so far');
      Check((SuggMemSortedListRec^.IsExactMatch = false),'This should be an partial match since all statementdetails are differant');
      Check((SuggMemSortedListRec^.IsHidden = false),'IsHidden should be false since this has not been set and defaults to true');
    end;
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestUncodedCountSuggestion;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction and checks that they are added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    // Adds 3 exact match transactions that are uncoded check if total and uncoded are right
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-6, -100, '', cbNotCoded, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-5, -110, '', cbNotCoded, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-4, -120, '', cbNotCoded, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    if (SuggMemSortedList.ItemCount = 1) then
    begin
      SuggMemSortedListRec := SuggMemSortedList.GetPRec(0);

      Check((SuggMemSortedListRec^.Id = 1),'Id should be 1 at this point since it is the first Suggestion');
      Check((SuggMemSortedListRec^.AccType = whWithdrawalEntryType[whNewZealand]),'Account type was not the same (tran Type)');
      Check((SuggMemSortedListRec^.MatchedPhrase = 'Big Large Dog'),'Suggestion Matching Phrase is not correct');
      Check((SuggMemSortedListRec^.Account = '230'),'Account Code shouldh be 230 for this Suggestion');
      Check((SuggMemSortedListRec^.TotalCount = 6),'Total count should be 6 since there are 3 manual transactions and 3 uncoded');
      Check((SuggMemSortedListRec^.ManualCount = 3),'Manual count should be 3 since there are 3 maunaul transactions');
      Check((SuggMemSortedListRec^.UnCodedCount = 3),'Uncoded count should be 3 since there are 3 uncoded transactions');
      Check((SuggMemSortedListRec^.ManualAcountCount = 1),'ManualAcountCount should be 1 since there is only one Account code so far');
      Check((SuggMemSortedListRec^.IsExactMatch = true),'This should be an exact match since all statementdetails are the same');
      Check((SuggMemSortedListRec^.IsHidden = false),'IsHidden should be false since this has not been set and defaults to true');
    end;
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestExactMatchWithTwoDifferantCodes;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction and checks that they are added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    // Adds 1 exact match transaction with differant code and checks that the suggestion has been removed
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '400', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions since the new matching Transaction is using a second code.');
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestExactMatchWithDifferantCodedby;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction and checks that they are added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    // Adds 1 exact match transaction with differant code and checks that the suggestion has been removed
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbAnalysis, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions since the new matching Transaction is coded by a code that removes suggestions.');
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestTransactionCodedEdit;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
  TranIndex : integer;
  TranRec : pTransaction_Rec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transactions that are uncoded check if total and uncoded are right
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-6, -100, '', cbNotCoded, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-5, -110, '', cbNotCoded, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-4, -120, '', cbNotCoded, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));

    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions since the transactions are all uncoded.');

    for TranIndex := 0 to fBankAcc01.baTransaction_List.ItemCount-1 do
      UpdateTransaction(TranIndex, '230', cbManual);

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    if (SuggMemSortedList.ItemCount = 1) then
    begin
      SuggMemSortedListRec := SuggMemSortedList.GetPRec(0);

      Check((SuggMemSortedListRec^.Id = 1),'Id should be 1 at this point since it is the first Suggestion');
      Check((SuggMemSortedListRec^.AccType = whWithdrawalEntryType[whNewZealand]),'Account type was not the same (tran Type)');
      Check((SuggMemSortedListRec^.MatchedPhrase = 'Big Large Dog'),'Suggestion Matching Phrase is not correct');
      Check((SuggMemSortedListRec^.Account = '230'),'Account Code shouldh be 230 for this Suggestion');
      Check((SuggMemSortedListRec^.TotalCount = 3),'Total count should be 3 since there are 3 transactions');
      Check((SuggMemSortedListRec^.ManualCount = 3),'Manual count should be 3 since there are 3 maunaul transactions');
      Check((SuggMemSortedListRec^.UnCodedCount = 0),'Uncoded count should be 0 since there are No uncoded transactions');
      Check((SuggMemSortedListRec^.ManualAcountCount = 1),'ManualAcountCount should be 1 since there is only one Account code so far');
      Check((SuggMemSortedListRec^.IsExactMatch = true),'This should be an exact match since all statementdetails are the same');
      Check((SuggMemSortedListRec^.IsHidden = false),'IsHidden should be false since this has not been set and defaults to true');
    end;
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestTransactionUnCodedEdit;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
  TranIndex : integer;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction and checks that they are added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    for TranIndex := 0 to fBankAcc01.baTransaction_List.ItemCount-1 do
      UpdateTransaction(TranIndex, '', cbNotCoded);

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions since the transactions were uncoded.');
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestTransactionDelete;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
  TranIndex : integer;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction and checks that they are added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    for TranIndex := fBankAcc01.baTransaction_List.ItemCount-1 downto 0 do
    begin
      SuggestedMem.UpdateAccountWithTransDelete(fBankAcc01, fBankAcc01.baTransaction_List.Transaction_At(TranIndex));
      fBankAcc01.baTransaction_List.DelFreeItem( fBankAcc01.baTransaction_List.Transaction_At(TranIndex) );
    end;

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions since the transactions were deleted.');
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestSuggestionBeingMemorized;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction and checks that they are added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 1),'There should only be one Suggestion at this point.');

    InsertMemIntoAccount(fBankAcc01, whWithdrawalEntryType[whNewZealand], '230', 'Big Large Dog');

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions at this point, since we just made a mem for the Suggestion');

  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestSuggestionWithInActiveChartCode;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction with inactive chart code and checks that they are not added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '500', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '500', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '500', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions at this point since the Chart Code is inactive.');
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestSuggestionWithInValidChartCode;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction with invalid chart code and checks that they are not added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '999', cbManual, 'Note 01', 'Big Large Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '999', cbManual, 'Note 01', 'Big Large Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '999', cbManual, 'Note 01', 'Big Large Dog', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions at this point since the Chart Code is invalid.');
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestSuggestionIgnoreList;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Adds 3 exact match transaction with ignored details and checks that they are not added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'and', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'and', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'and', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions at this point since the Statement details is in the ignore list.');

    // Adds 3 exact match transaction with ignored details and checks that they are not added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'the', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'the', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'the', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions at this point since the Statement details is in the ignore list.');

     // Adds 3 exact match transaction with ignored details and checks that they are not added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'ltd', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'ltd', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'ltd', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions at this point since the Statement details is in the ignore list.');

    // Adds 3 exact match transaction with ignored details and checks that they are not added
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-3, -100, '230', cbManual, 'Note 01', 'mrs', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-2, -110, '230', cbManual, 'Note 01', 'mrs', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-1, -120, '230', cbManual, 'Note 01', 'mrs', 1, Round(120 / 9));
    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions at this point since the Statement details is in the ignore list.');
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

procedure TSuggestedMemsTestCase.TestSuggestionListAndCountMethodsAreTheSame;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    InsertTranIntoAccount(fBankAcc01, CurrentDate()-200, -100, '230', cbManual, 'Note 01', 'Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-199, -110, '230', cbManual, 'Note 01', 'Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-198, -120, '230', cbManual, 'Note 01', 'Dog', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-197, -100, '230', cbManual, 'Note 01', 'Hello', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-196, -110, '230', cbManual, 'Note 01', 'Hello', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-195, -120, '230', cbManual, 'Note 01', 'Hello', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-194, -100, '230', cbManual, 'Note 01', 'Cat', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-193, -110, '230', cbManual, 'Note 01', 'Cat', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-192, -120, '230', cbManual, 'Note 01', 'Cat', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-191, -100, '230', cbManual, 'Note 01', 'Bye', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-190, -110, '230', cbManual, 'Note 01', 'Bye', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-189, -120, '230', cbManual, 'Note 01', 'Bye', 1, Round(120 / 9));

    InsertTranIntoAccount(fBankAcc01, CurrentDate()-188, -100, '230', cbManual, 'Note 01', 'Dog Hello', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-187, -110, '230', cbManual, 'Note 01', 'Dog Hello', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-186, -120, '230', cbManual, 'Note 01', 'Dog Hello', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-185, -100, '230', cbManual, 'Note 01', 'Hello Cat', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-184, -110, '230', cbManual, 'Note 01', 'Hello Cat', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-183, -120, '230', cbManual, 'Note 01', 'Hello Cat', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-182, -100, '230', cbManual, 'Note 01', 'Cat Bye', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-181, -110, '230', cbManual, 'Note 01', 'Cat Bye', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-180, -120, '230', cbManual, 'Note 01', 'Cat Bye', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-179, -100, '230', cbManual, 'Note 01', 'Bye Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-178, -110, '230', cbManual, 'Note 01', 'Bye Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-177, -120, '230', cbManual, 'Note 01', 'Bye Dog', 1, Round(120 / 9));

    InsertTranIntoAccount(fBankAcc01, CurrentDate()-176, -100, '230', cbManual, 'Note 01', 'Dog Hello Cat', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-175, -110, '230', cbManual, 'Note 01', 'Dog Hello Cat', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-174, -120, '230', cbManual, 'Note 01', 'Dog Hello Cat', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-173, -100, '230', cbManual, 'Note 01', 'Hello Cat Bye', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-172, -110, '230', cbManual, 'Note 01', 'Hello Cat Bye', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-171, -120, '230', cbManual, 'Note 01', 'Hello Cat Bye', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-170, -100, '230', cbManual, 'Note 01', 'Cat Bye Dog', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-169, -110, '230', cbManual, 'Note 01', 'Cat Bye Dog', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-168, -120, '230', cbManual, 'Note 01', 'Cat Bye Dog', 1, Round(120 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-167, -100, '230', cbManual, 'Note 01', 'Bye Dog Hello', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-166, -110, '230', cbManual, 'Note 01', 'Bye Dog Hello', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-165, -120, '230', cbManual, 'Note 01', 'Bye Dog Hello', 1, Round(120 / 9));

    InsertTranIntoAccount(fBankAcc01, CurrentDate()-164, -100, '230', cbManual, 'Note 01', 'Dog Hello Cat Bye', 1, Round(100 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-163, -110, '230', cbManual, 'Note 01', 'Dog Hello Cat Bye', 1, Round(110 / 9));
    InsertTranIntoAccount(fBankAcc01, CurrentDate()-162, -120, '230', cbManual, 'Note 01', 'Dog Hello Cat Bye', 1, Round(120 / 9));

    RunAllmMemScan();

    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 13),'There should be 13 Suggestions at this point.');

    Check((SuggestedMem.GetSuggestedMemsCount(fBankAcc01, fTestClient.clChart) = 13),'There should be 13 Suggestions at this point.');
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
procedure TSuggestedMemsTestCase.TestMultipleSuggestions;
var
  SuggMemSortedList : TSuggMemSortedList;
  SuggMemSortedListRec : pSuggMemSortedListRec;
  TranIndex : integer;
  SuggIndex : integer;
  TranRec : pTransaction_Rec;
begin
  SuggMemSortedList := TSuggMemSortedList.create;

  try
    MEMSINI_SupportOptions := meiFullfunctionality;
    SuggestedMem.SetMainState();
    SuggestedMem.ResetAll(fTestClient);
    SuggestedMem.StartMemScan(true);

    // Add 350 uncoded transactions check to see that there are no suggestions
    SuggestedMem.StopMemScan();
    try
      for TranIndex := 0 to 49 do
      begin
        InsertTranIntoAccount(fBankAcc01, CurrentDate() - 601 + TranIndex, -25,  '', cbNotCoded, 'Tran 01', 'mad dog chasing a large cat', 1, Round(-25 / 9));
        InsertTranIntoAccount(fBankAcc01, CurrentDate() - 501 + TranIndex, -50,  '', cbNotCoded, 'Tran 02', 'I chased that mad dog and it ran away', 1, Round(-50 / 9));
        InsertTranIntoAccount(fBankAcc01, CurrentDate() - 401 + TranIndex, -75,  '', cbNotCoded, 'Tran 03', 'The large cat was in a high tree and could not get out', 1, Round(-75 / 9));
        InsertTranIntoAccount(fBankAcc01, CurrentDate() - 301 + TranIndex, -100, '', cbNotCoded, 'Tran 04', 'I climbed up the tree and the large cat scrathed me', 1, Round(-100 / 9));
        InsertTranIntoAccount(fBankAcc01, CurrentDate() - 201 + TranIndex, -125, '', cbNotCoded, 'Tran 05', 'I fell out of the tree and broke my leg', 1, Round(-125 / 9));
        InsertTranIntoAccount(fBankAcc01, CurrentDate() - 101 + TranIndex, -150, '', cbNotCoded, 'Tran 06', 'A large truck fell from the sky and hit my head', 1, Round(-150 / 9));
        InsertTranIntoAccount(fBankAcc01, CurrentDate() - 1 + TranIndex,   -175, '', cbNotCoded, 'Tran 07', 'Suddenly I woke up and realized it was all a dream', 1, Round(-175 / 9));
      end;
    finally
      SuggestedMem.StartMemScan();
    end;

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 0),'There should be no Suggestions at this point since all the transactions are uncoded.');

    SuggestedMem.StopMemScan();
    try
      UpdateTransaction(10, '230', cbManual);
      UpdateTransaction(11, '230', cbManual);
      UpdateTransaction(12, '230', cbManual);

      UpdateTransaction(60, '230', cbManual);
      UpdateTransaction(61, '230', cbManual);
      UpdateTransaction(62, '230', cbManual);

      UpdateTransaction(110, '230', cbManual);
      UpdateTransaction(111, '230', cbManual);
      UpdateTransaction(112, '230', cbManual);

      UpdateTransaction(160, '230', cbManual);
      UpdateTransaction(161, '230', cbManual);
      UpdateTransaction(162, '230', cbManual);

      UpdateTransaction(210, '230', cbManual);
      UpdateTransaction(211, '230', cbManual);
      UpdateTransaction(212, '230', cbManual);

      UpdateTransaction(260, '230', cbManual);
      UpdateTransaction(261, '230', cbManual);
      UpdateTransaction(262, '230', cbManual);

      UpdateTransaction(310, '230', cbManual);
      UpdateTransaction(311, '230', cbManual);
      UpdateTransaction(312, '230', cbManual);
    finally
      SuggestedMem.StartMemScan();
    end;

    RunAllmMemScan();

    SuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAcc01, fTestClient.clChart, SuggMemSortedList);

    Check((SuggMemSortedList.ItemCount = 16),'There should be 16 Suggestions at this point');

    for SuggIndex := 0 to 15 do
    begin
      SuggMemSortedListRec := SuggMemSortedList.GetPRec(SuggIndex);

      case SuggIndex of
        0 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*A LARGE*'),'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 100),           'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 6),            'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 94),          'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),      'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),       'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        1 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*FELL*'),    'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 100),            'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 6),             'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 94),           'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),       'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),        'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        2 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*LARGE CAT*'),'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 150),             'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 9),              'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 141),           'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),        'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),         'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        3 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*LARGE*'),    'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 150),             'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 9),              'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 141),           'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),        'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),         'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        4 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*MAD DOG*'),  'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 100),              'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 6),              'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 94),            'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),        'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),         'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        5 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*THE LARGE CAT*'),'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 100),                 'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 6),                  'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 94),                'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),            'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),             'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        6 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*THE TREE AND*'),'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 100),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 6),                 'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 94),               'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),           'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        7 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*TREE AND*'),    'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 100),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 6),                 'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 94),               'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),           'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        8 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = '*WAS*'),         'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 100),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 6),                 'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 94),               'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),           'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = false),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an patial match');
        end;
        9 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = 'A large truck fell from the sky and hit my head'),
                'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 50),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 3),                'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 47),              'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),          'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = true),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an exact match');
        end;
        10 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = 'I chased that mad dog and it ran away'),
                'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 50),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 3),                'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 47),              'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),          'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = true),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an exact match');
        end;
        11 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = 'I climbed up the tree and the large cat scrathed me'),
                'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 50),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 3),                'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 47),              'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),          'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = true),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an exact match');
        end;
        12 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = 'I fell out of the tree and broke my leg'),
                'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 50),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 3),                'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 47),              'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),          'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = true),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an exact match');
        end;
        13 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = 'mad dog chasing a large cat'),
                'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 50),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 3),                'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 47),              'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),          'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = true),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an exact match');
        end;
        14 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = 'Suddenly I woke up and realized it was all a dream'),
                'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 50),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 3),                'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 47),              'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),          'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = true),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an exact match');
        end;
        15 : begin
          Check((SuggMemSortedListRec^.MatchedPhrase = 'The large cat was in a high tree and could not get out'),
                'Suggestion : ' + inttostr(SuggIndex) +  ', Suggestion Matching Phrase is not correct');
          Check((SuggMemSortedListRec^.TotalCount = 50),                'Suggestion : ' + inttostr(SuggIndex) +  ', Total count is wrong');
          Check((SuggMemSortedListRec^.ManualCount = 3),                'Suggestion : ' + inttostr(SuggIndex) +  ', Manual count is wrong');
          Check((SuggMemSortedListRec^.UnCodedCount = 47),              'Suggestion : ' + inttostr(SuggIndex) +  ', Uncoded count is wrong');
          Check((SuggMemSortedListRec^.ManualAcountCount = 1),          'Suggestion : ' + inttostr(SuggIndex) +  ', ManualAcountCount should be 1 since there is only one Account code so far');
          Check((SuggMemSortedListRec^.IsExactMatch = true),            'Suggestion : ' + inttostr(SuggIndex) +  ', This should be an exact match');
        end;
      end;

      Check((SuggMemSortedListRec^.AccType = whWithdrawalEntryType[whNewZealand]),'Suggestion : ' + inttostr(SuggIndex) +  ', Account type was not the same (tran Type)');
      Check((SuggMemSortedListRec^.Account = '230'),'Suggestion : ' + inttostr(SuggIndex) +  ', Account Code shouldh be 230 for this Suggestion');
      Check((SuggMemSortedListRec^.IsHidden = false),'Suggestion : ' + inttostr(SuggIndex) +  ', IsHidden should be false since this has not been set and defaults to true');
    end;
  finally
    FreeAndNil(SuggMemSortedList);
  end;
end;

//------------------------------------------------------------------------------
initialization
  TestFramework.RegisterTest(TSuggestedMemsTestCase.Suite);
end.
