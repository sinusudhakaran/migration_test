unit utWebXOffice;
//------------------------------------------------------------------------------
{
   Title:       Unit Tests for WebXOffice interface

   Description:

   Author:      Matthew Hopkins           Jul 2004

   Remarks:     Tests the creation of a bank account and transaction list from
                a created WDDX file

                Tests the import cases for the WebXUtils for importing each
                transaction/dissection.

   Revisions:   Cases 1,2,3,4,5 comments added to test cases
                Cases 6a,6b,6c done

}
//------------------------------------------------------------------------------
{$TYPEINFO ON} //Needed for classes with published methods
interface
uses
  TestFramework, //DUnit
  clObj32, PayeeObj, bkDefs;

type
 TWebXImportTests = class(TTestCase)
 private

 protected

 published
   //procedure TestConvertWDDX_To_AccountList;
   procedure TestValidateTransaction;
 end;

 TResultSet = Array[0..9] of String;                //10 tests
 TDissectedResultSet = Array[0..9,1..5] of string;  //10 tests + 3 lines
 TRecreateProc = procedure( var pT : pTransaction_Rec) of object;

 TWebXTransactionImportTests = class( TTestCase)
 private
   BK5TestClient : TClientObj;
   Payee1,
   Payee2,
   Payee3,
   Payee4,
   Payee5 : TPayee;

   Chart230,
   Chart400 : pAccount_Rec;

   procedure CheckForImportNoteLine(FieldName, Note: string);
   procedure RecreateBK5Transaction_Case1_NoNarration(var pT: pTransaction_Rec);
   procedure RecreateBK5Transaction_Case1_WithNarration(var pT: pTransaction_Rec);
   procedure RecreateBK5Transaction_Case6_NoNarration(var pT: pTransaction_Rec);
   procedure RecreateBK5Transaction_Case6_WithNarration(var pT: pTransaction_Rec);
   procedure RecreateBK5Transaction_Case5_Basic(var pT : pTransaction_Rec);
   procedure RecreateBK5Transaction_Case5_DissectedByPayee(var pT : pTransaction_Rec);
   procedure RecreateBK5Transaction_Case5_DissectedWithInternalPayees(var pT : pTransaction_Rec);
 protected
   procedure Setup; override;
   procedure TearDown; override;

   procedure CreateBK5TestClient;

   procedure CheckTransactionLevelNarration( ExpectedResultSet : TResultSet;
                                             pT_CodeIT : pTransaction_Rec;
                                             RecreateProc : TRecreateProc;
                                             ExpectedCase : integer;
                                             TestID : string);

   procedure CheckDissectionLevelNarration( ExpectedResultSet : TDissectedResultSet;
                                             pT_CodeIT : pTransaction_Rec;
                                             RecreateProc : TRecreateProc;
                                             ExpectedCase : integer;
                                             TestID : string);


 published
   procedure TestCase1_AmountChanged;
   procedure TestCase1_AmountChangedForUPI;
   procedure TestCase1_AmountSetForUPI;
   procedure TestCase1_AccountSet;
   procedure TestCase1_AccountSetToUnknown;
   procedure TestCase1_AccountChanged;
   procedure TestCase1_PayeeSet;
   procedure TestCase1_PayeeSet_WithOveride;
   procedure TestCase1_AccountSet_GSTAmountChanged;
   procedure TestCase1_PayeeSet_GSTAmountChanged;
   procedure TestCase1_PayeeSet_WithOveride_GSTAmountChanged;
   procedure TestCase1_PayeeSet_AccountChanged;
   procedure TestCase1_TaxInvoice;
   procedure TestCase1_Notes;
   procedure TestCase1_Narration_Blank;
   procedure TestCase1_Narration_PreExisting;
   procedure TestCase1_QuantitySet;
   procedure TestCase1_QuantityChanged;
   procedure TestCase1_UnchangedBasic;
   procedure TestCase1_UnchangedWithPayee;
   procedure TestCase1_BlankPayee_BlankNarr;
   procedure TestCase1_BlankPayee_Custom;
   procedure TestCase1_BlankPayee_PayeeName;

   procedure TestCase2_EditableFields;
   procedure TestCase2_Notes;
   procedure TestCase2_TaxInvoice;

   procedure TestCase3_DifferentAmounts;
   procedure TestCase3_DifferentAccounts;
   procedure TestCase3_DifferentNumberOfLines;

   procedure TestCase4;

   //existing matched dissection
   procedure TestCase5_UnchangedBasic;
   procedure TestCase5_TaxInvoice;
   procedure TestCase5_TransactionNotesChanged;
   procedure TestCase5_TransactionPayeeSet;
   procedure TestCase5_TransactionPayeeChanged;
   procedure TestCase5_TransactionNarration;

   procedure TestCase5_DissectionGSTChanged;
   procedure TestCase5_DissectionQuantity;
   procedure TestCase5_Notes;
   procedure TestCase5_PayeeSetOnDissectLine;
   procedure TestCase5_PayeeChangedOnDissectLine;
   procedure TestCase5_DissectionNarration;

   //new dissection, no payee
   procedure TestCase6a_AmountChanged;
   procedure TestCase6a_AccountSet;
   procedure TestCase6a_AccountSet_GSTAmountChanged;
   procedure TestCase6a_GSTSet;
   procedure TestCase6a_QuantitySet;
   procedure TestCase6a_NotesSet;
   procedure TestCase6a_NarrationAtTrxLevel;
   procedure TestCase6a_NarrationAtTrxLevel_ExistingNarration;
   procedure TestCase6a_TaxInvoice;
   procedure TestCase6a_NarrationAtDissectLevel;

   //new dissection, payee at transaction level
   procedure TestCase6b_NarrationAtTrxLevel;
   procedure TestCase6b_NarrationAtTrxLevel_ExistingNarration;
   procedure TestCase6b_DissectedPayee;
   procedure TestCase6b_DifferentPayee;
   procedure TestCase6b_UnknownPayee;
   procedure TestCase6b_NotesSet;
   procedure TestCase6b_QuantitySet;
   procedure TestCase6b_TaxInvoice;

   //new dissection, payee at dissection level
   procedure TestCase6c_StandardPayeeAndManualLines;
   procedure TestCase6c_SingleDissectedPayee;
   procedure TestCase6c_MultipleDissectedPayee;
   procedure TestCase6c_PayeeCodeMismatch;
   procedure TestCase6c_UnknownPayee;
   procedure TestCase6c_NotesSet;
   procedure TestCase6c_QuantitySet;
   procedure TestCase6c_NarrationAtTrxLevel;
   procedure TestCase6c_NarrationAtTrxLevel_ExistingNarration;
   procedure TestCase6c_TaxInvoice;

   //extra
   procedure TestCase6_PayeeSetAtTrxAndDissectLevels;



 end;

implementation
uses
  Classes, SysUtils, baList32, baObj32, GenUtils, WebxUtils, bkConst,
  bkchio, bkplio, bktxio, bkdsio, trxList32, ECodingUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CountOfDissectionLines( pT : pTransaction_Rec) : integer;
var
  pD : pDissection_Rec;
begin
  result := 0;
  pD := pT^.txFirst_Dissection;
  while (pd <> nil) do
  begin
    Inc( result);
    pd := pd.dsNext;
  end;
end;

{ TWebXImportTests }

type
  TTransactionDetailRec = record
    Account_UID : integer;
    Transaction_UID : integer;
    Sequence_Number : integer;
    chart_Code : string;
    amount : double;
    gst_class : integer;
    gst_amount : double;
    has_been_edited : boolean;
    quantity : double;
    payee_number : integer;
    gst_has_been_edited : boolean;
    narration : string;
    notes : string;
    TaxInvoiceAvailable : boolean;
  end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*procedure TWebXImportTests.TestConvertWDDX_To_AccountList;
//create a test xml file and verify the transactions from the resulting
//bank account list match the exported data
const
  WddxFilename = 'test.xml';
var
  WddxFile : TextFile;
  TransactionArray : Array[0..50] of TTransactionDetailRec;
  TransactionArrayLineNo : integer;

  procedure InsertTransaction(Account_UID          : integer;
                              Transaction_UID      : integer;
                              Sequence_Number      : integer;
                              chart_Code           : string;
                              amount               : double;
                              gst_class            : integer;
                              gst_amount           : double;
                              has_been_edited      : boolean;
                              quantity             : double;
                              payee_number         : integer;
                              gst_has_been_edited  : boolean;
                              narration            : string;
                              notes                : string;
                              TaxInvoiceAvailable  : boolean);
  begin
    TransactionArray[ TransactionArrayLineNo].Account_UID          :=  Account_UID;
    TransactionArray[ TransactionArrayLineNo].Transaction_UID      :=  Transaction_UID;
    TransactionArray[ TransactionArrayLineNo].Sequence_Number      :=  Sequence_Number;
    TransactionArray[ TransactionArrayLineNo].chart_Code           :=  chart_Code;
    TransactionArray[ TransactionArrayLineNo].amount               :=  amount;
    TransactionArray[ TransactionArrayLineNo].gst_class            :=  gst_class;
    TransactionArray[ TransactionArrayLineNo].gst_amount           :=  gst_amount;
    TransactionArray[ TransactionArrayLineNo].has_been_edited      :=  has_been_edited;
    TransactionArray[ TransactionArrayLineNo].quantity             :=  quantity;
    TransactionArray[ TransactionArrayLineNo].payee_number         :=  payee_number;
    TransactionArray[ TransactionArrayLineNo].gst_has_been_edited  :=  gst_has_been_edited;
    TransactionArray[ TransactionArrayLineNo].narration            :=  narration;
    TransactionArray[ TransactionArrayLineNo].notes                :=  notes;
    TransactionArray[ TransactionArrayLineNo].TaxInvoiceAvailable  :=  TaxInvoiceAvailable;
    TransactionArrayLineNo := TransactionArrayLineNo + 1;
  end;

  procedure WddxWrite( i : integer); overload;
  begin
    Write( WddxFile, '<number>'+IntToStr(i)+'</number>');
  end;

  procedure WddxWrite( s : string); overload;
  begin
    if s <> '' then
      Write( WddxFile, '<string>'+s+'</string>')
    else
      Write( WddxFile, '<string />');
  end;

  procedure WddxWrite( b : boolean); overload;
  begin
    if b then
      WddxWrite('1')
    else
      WddxWrite('0');
  end;

  procedure WddxWrite( d : double); overload;
  begin
    Write( WddxFile, '<number>'+FormatFloat('0.00',d)+'</number>');
  end;

  procedure WriteTransactions;
  var
    i : integer;
  begin
    if TransactionArrayLineNo = 0 then
      exit;

    Write( WddxFile, '<field name="ACCOUNT_UID">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Account_UID);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="TRANSACTION_UID">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Transaction_UID);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="SEQUENCE_NUMBER">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Sequence_Number);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="CHART_CODE">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].chart_code);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="AMOUNT">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Amount);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="GST_CLASS">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].gst_class);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="GST_AMOUNT">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Gst_amount);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="HAS_BEEN_EDITED">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Has_Been_edited);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="QUANTITY">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Quantity);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="PAYEE_NUMBER">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Payee_number);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="GST_HAS_BEEN_EDITED">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].gst_has_been_edited);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="NARRATION">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Narration);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="NOTES">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].Notes);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="TAX_INVOICE_AVAILABLE">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      WddxWrite(TransactionArray[i].TaxInvoiceAvailable);
    end;
    Write( WddxFile, '</field>');
  end;

  function CountTotalTransactions: Integer;
  var
    i: Integer;
  begin
    Result := 0;
    for i := 0 to TransactionArrayLineNo - 1 do
      if TransactionArray[i].Sequence_Number = 1 then
        Inc(Result);
  end;

  procedure WriteNotes;
  var
    i : integer;
  begin
    if TransactionArrayLineNo = 0 then
      exit;

    Write( WddxFile, '<field name="TAX_INVOICE_AVAILABLE">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      if TransactionArray[i].Sequence_Number = 1 then
        WddxWrite(TransactionArray[i].TaxInvoiceAvailable);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="QUANTITY">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      if TransactionArray[i].Sequence_Number = 1 then
        WddxWrite(TransactionArray[i].Quantity);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="PAYEE_NUMBER">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      if TransactionArray[i].Sequence_Number = 1 then
        WddxWrite(TransactionArray[i].payee_number);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="NOTES">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      if TransactionArray[i].Sequence_Number = 1 then
        WddxWrite(TransactionArray[i].Notes);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="TRANSACTION_UID">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      if TransactionArray[i].Sequence_Number = 1 then
        WddxWrite(TransactionArray[i].Transaction_UID);
    end;
    Write( WddxFile, '</field>');

    Write( WddxFile, '<field name="ACCOUNT_UID">');
    for i := 0 to TransactionArrayLineNo - 1 do
    begin
      if TransactionArray[i].Sequence_Number = 1 then
        WddxWrite(TransactionArray[i].Account_UID);
    end;
    Write( WddxFile, '</field>');
    
  end;

  function FindTestDataIndex( aUID, tUID : integer) : integer;
  var
    i : integer;
  begin
    result := -1;
    for i := Low( TransactionArray) to High( TransactionArray) do
    begin
      if (TransactionArray[i].Transaction_UID = tUID) and
         (TransactionArray[i].Account_UID = aUID) then
      begin
        result := i;
        exit;
      end;
    end;
  end;

  function TestDataTotalAmountForUID( aUID, tUID : integer) : double;
  var
    i : integer;
  begin
    result := 0;
    for i := Low( TransactionArray) to High( TransactionArray) do
    begin
      if (TransactionArray[i].Transaction_UID = tUID) and
         (TransactionArray[i].Account_UID = aUID) then
      begin
        result := result + TransactionArray[i].amount;
      end;
    end;
  end;

  function TestDataNoOfLinesForUID( aUID, tUID : integer) : integer;
  var
    i : integer;
  begin
    result := 0;
    for i := Low( TransactionArray) to High( TransactionArray) do
    begin
      if (TransactionArray[i].Transaction_UID = tUID) and
         (TransactionArray[i].Account_UID = aUID) then
      begin
        result := result + 1;
      end;
    end;
  end;


  procedure CheckTransaction( aUID, tUID : integer; Account : TBank_Account);
  // aUID : Account UID
  // tUID : Transaction UID
  var
    pT : pTransaction_Rec;
    pD : pDissection_Rec;
    testDataIndex : integer;
    CountOfDissectLines : integer;
  begin
    pT := Account.baTransaction_List.FindTransactionFromECodingUID( tUID);
    Check( pT <> nil, 'UID ' +  InttoStr( aUID) + '.' + IntTostr( tUID) + ' missing');

    testDataIndex := FindTestDataIndex( aUID, tUID);
    if pT.txFirst_Dissection = nil then
    begin
      //check next line in test data has different transaction id
      CheckNotEquals( TransactionArray[ TestDataIndex].Transaction_UID,
                      TransactionArray[ TestDataIndex + 1].Transaction_UID,
                      'Test Data is dissected');

      CheckEquals( Double2Money( TransactionArray[ testDataIndex].amount) , pT.txAmount, 'Amount');
      CheckEquals( TransactionArray[ TestDataIndex].Chart_code, pT.txAccount,'Account');
      CheckEquals( TransactionArray[ TestDataIndex].gst_class, pT.txGST_Class, 'GST class');
      CheckEquals( Double2Money( TransactionArray[ TestDataIndex].gst_amount), pT.txGST_Amount, 'GST Amount');
      CheckEquals( TransactionArray[ TestDataIndex].has_been_edited, pT.txHas_been_edited, 'Has_been_edited');
      CheckEquals( TransactionArray[ TestDataIndex].Quantity * 10000, pT.txQuantity, 'txQuantity');
      CheckEquals( TransactionArray[ TestDataIndex].payee_number, pT.txPayee_Number , 'txPayee_Number');
      CheckEquals( TransactionArray[ TestDataIndex].gst_has_been_edited, pT.txgst_Has_been_edited, 'txgst_Has_been_edited');
      CheckEquals( TransactionArray[ TestDataIndex].Narration, pT.txGL_Narration,'txGL_Narration');
      CheckEquals( TransactionArray[ TestDataIndex].Notes, pT.txNotes,'txNotes');
      CheckEquals( TransactionArray[ TestDataIndex].TaxInvoiceAvailable, pT.txTax_Invoice_Available,'txTax_Invoice_Available');
    end
    else
    begin
      //check next line has same transaction uid
      CheckEquals( TransactionArray[ TestDataIndex].Transaction_UID,
                   TransactionArray[ TestDataIndex + 1].Transaction_UID,
                   'Test Data not dissected');

      //check transaction
      CheckEquals( Double2Money( TestDataTotalAmountForUID( aUID, tUID)) , pT.txAmount,'(D)txAmount');
      CheckEquals( 'DISSECTED', pT.txAccount,'(D)txAccount');
      CheckEquals( 0, pT.txGST_Class,'(D)txGST_class');
      CheckEquals( 0, pT.txGST_Amount,'(D)txGST_Amount');
      CheckEquals( False, pt.txGST_Has_Been_Edited, '(D)txGST_has_been_edited');
      CheckEquals( False, pT.txHas_been_edited,'(D)txHas_Been_edited');
      CheckEquals( 0, pT.txQuantity,'(D)txQuantity');

      CheckEquals( TransactionArray[ TestDataIndex].payee_number, pT.txPayee_Number,'(D)txPayee'); //?????????????
      CheckEquals( TransactionArray[ TestDataIndex].Notes, pT.txNotes,'(D)txNotes'); //??????????
      CheckEquals( false {TransactionArray[ TestDataIndex].TaxInvoiceAvailable}, pT.txTax_Invoice_Available,'txTax_Invoice_Available'); //????????????

      CountOfDissectLines := 0;
      pD := pT^.txFirst_Dissection;
      while (pd <> nil) do
      begin
        Inc( CountOfDissectLines);
        pd := pd.dsNext;
      end;
      CheckEquals( CountOfDissectLines, TestDataNoOfLinesForUID( aUID, tUID));

      pD := pT^.txFirst_Dissection;
      while (pd <> nil) do
      begin
        CheckEquals( Double2Money( TransactionArray[ testDataIndex].amount) , pD.dsAmount,'dsAmount');
        CheckEquals( TransactionArray[ TestDataIndex].Chart_code, pD.dsAccount,'dsAccount');
        CheckEquals( TransactionArray[ TestDataIndex].gst_class, pD.dsGST_Class,'dsGST_Class');
        CheckEquals( Double2Money( TransactionArray[ TestDataIndex].gst_amount), pD.dsGST_Amount,'dsGST_Amount');
        CheckEquals( TransactionArray[ TestDataIndex].has_been_edited, pD.dsHas_been_edited,'dsHas_been_edited');
        CheckEquals( TransactionArray[ TestDataIndex].Quantity * 10000, pD.dsQuantity, 'dsquantity');
        CheckEquals( TransactionArray[ TestDataIndex].payee_number, pD.dsPayee_Number, 'dsPayee');
        CheckEquals( TransactionArray[ TestDataIndex].gst_has_been_edited, pD.dsgst_Has_been_edited, 'dsGST_has_been_edited');
        CheckEquals( TransactionArray[ TestDataIndex].Narration, pD.dsGL_Narration, 'dsGL_Narrartion');
        CheckEquals( TransactionArray[ TestDataIndex].Notes, pD.dsNotes,'dsNotes');

        pd := pd.dsNext;
        TestDataIndex := TestDataIndex + 1;
      end;


    end;
  end;

var
  CountOfAccounts : integer;
  CountOfTransactions : integer;
  CountOfDissectLines : integer;
  BankAccountList : TBank_Account_List;
  aClient : TClientObj;
  ba : TBank_Account;
  t,i : integer;
  tr : pTransaction_rec;
  dr : pDissection_rec;
begin
  RegisterWDDXCOM;

  TransactionArrayLineNo := 0;

  try
    //create a wddx file for import
    //3 accounts, 4, 5, 6 transactions
    Assign( WddxFile, WddxFilename);
    Rewrite( WddxFile);
    try
      Write( WddxFile, '<wddxPacket version="1.0">' );
      Write( WddxFile, '<header/>' );
      Write( WddxFile, '<data><struct>' );

      //client detail
      Write( WddxFile, '<var name="CLIENT CODE"><string>NZCODED</string></var>');
      Write( WddxFile, '<var name="CLIENT NAME"><string>Chalet de neige</string></var>');
      Write( WddxFile, '<var name="COUNTRY"><string>New Zealand</string></var>');
      Write( WddxFile, '<var name="START DATE"><string>01/12/2003</string></var>');
      Write( WddxFile, '<var name="END DATE"><string>31/12/2003</string></var>');

        //accounts, there is no account information in the BKO file, only the

        //create transaction details
        //account uid, transaction uid, sequence no, code, amount, gst class, gst amt, edited flag
        //             quantity, payee, gst edit flag, narration , notes

        InsertTransaction( 1, 1, 1, '1001', 1.01, 1, 0.01, true, 1.000, 0, true, 'Narration 1', 'Notes 1', false);
        //dissected line
        InsertTransaction( 1, 2, 1, '1002', 1.02, 2, 0.02, true, 2.000, 0, true, 'Narration 2', 'Notes 2 T2 D1', false);
          InsertTransaction( 1, 2, 2, '1002', 1.03, 3, 0.03, true, 3.000, 0, true, 'Narration 3', 'Notes 3 T2 D2', false);
        //blank line
        InsertTransaction( 1, 3, 1, '', 1.04, 0, 0.00, false, 0.000, 0, false, '', '', true);

        InsertTransaction( 2, 1, 1, '2001', 2.01, 1, 0.21, false, 0.000, 1, false, '', 'Account 2',false);
        InsertTransaction( 2, 2, 1, '2002', 2.02, 2, 0.22, false, 0.000, 2, false, '', 'Account 2',false);
        InsertTransaction( 2, 3, 1, '2003', 2.03, 3, 0.23, false, 0.000, 3, false, '', 'Account 2',false);
        InsertTransaction( 2, 4, 1, '2004', 2.04, 4, 0.24, false, 0.000, 4, false, '', 'Account 2',false);
        InsertTransaction( 2, 5, 1, '2005', 2.05, 5, 0.25, false, 0.000, 5, false, '', 'Account 2',false);

        InsertTransaction( 3, 6, 1, '3001', 3.01, 1, 0.25, false, 0.000, 5, false, 'Narr3', 'Dissect Line 1',false);
          InsertTransaction( 3, 6, 2, '3002', 3.01, 1, 0.25, false, 0.000, 5, false, '', 'Dissect Line 1',false);
          InsertTransaction( 3, 6, 3, '3003', 3.01, 1, 0.25, false, 0.000, 5, false, '', 'Dissect Line 2',false);
          InsertTransaction( 3, 6, 4, '3004', 3.01, 1, 0.25, false, 0.000, 5, false, '', 'Dissect Line 3',false);
          InsertTransaction( 3, 6, 5, '3005', 3.01, 1, 0.25, false, 0.000, 5, false, '', 'Dissect Line 4',false);
          InsertTransaction( 3, 6, 6, '3006', 3.01, 1, 0.25, false, 0.000, 5, false, '', 'Dissect Line 5',false);
        InsertTransaction( 3, 7, 1, '3007', 3.02, 1, 0.25, false, 0.000, 5, false, '', 'Transaction 2',false);
        InsertTransaction( 3, 8, 1, '3008', 3.03, 1, 0.25, false, 0.000, 5, false, '', 'Transaction 3',false);

      Writeln( WddxFile);
      Writeln( WddxFile, '<var name="TRANSACTION DETAIL"><recordset rowCount="' + inttostr( TransactionArrayLineNo) +
               '" fieldNames="ACCOUNT_UID,TRANSACTION_UID,SEQUENCE_NUMBER,CHART_CODE,AMOUNT,GST_CLASS,GST_AMOUNT,HAS_BEEN_EDITED,QUANTITY,PAYEE_NUMBER,GST_HAS_BEEN_EDITED,NARRATION,NOTES,TAX_INVOICE_AVAILABLE">');
      WriteTransactions;
      Writeln( WddxFile);
      Writeln( WddxFile, '</recordset></var>');
      Writeln( WddxFile);
      Writeln( WddxFile, '<var name="TRANSACTIONS"><recordset rowCount="' + inttostr( CountTotalTransactions) +
               '" fieldNames="TAX_INVOICE_AVAILABLE,QUANTITY,PAYEE_NUMBER,NOTES,TRANSACTION_UID,ACCOUNT_UID">');
      WriteNotes;
      Writeln( WddxFile);
      Writeln( WddxFile, '</recordset></var>');
      Write( WddxFile, '</struct></data>' );
      Write( WddxFile, '</wddxPacket>' );
    finally
      System.Close( WddxFile);
    end;

    //read in file
    BankAccountList := TBank_Account_List.Create;
    try
      aClient := TClientObj.Create;
      try
        WebXUtils.ParseWDDXTransactions( aClient, WddxFilename, BankAccountList);
      finally
        aClient.Free;
      end;

      //get stats
      CountOfAccounts := BankAccountList.ItemCount;
      CountOfTransactions := 0;
      CountOfDissectLines := 0;
      for i := 0 to CountOfAccounts - 1 do
      begin
        ba := BankAccountList.Bank_Account_At(i);
        CountOfTransactions := CountOfTransactions + ba.baTransaction_List.ItemCount;
        for t := 0 to ba.baTransaction_List.Last do
        begin
          TR := ba.baTransaction_List.Transaction_At(t);
          DR := tr.txFirst_Dissection;
          while DR <> nil do
          begin
            Inc( CountOfDissectLines);
            DR := DR.dsNext;
          end;
        end;
      end;

      //check results
      CheckEquals( 3, CountOfAccounts);
      CheckEquals( 11, CountOfTransactions);
      CheckEquals( 8, CountOfDissectLines);

      //check transactions for account 1,
      ba := BankAccountList.Bank_Account_At(0);
      CheckEquals( 3, ba.baTransaction_List.ItemCount);

      CheckTransaction( 1, 1, ba);
      CheckTransaction( 1, 2, ba);
      CheckTransaction( 1, 3, ba);

      //check transactions for account 2
      ba := BankAccountList.Bank_Account_At(1);
      CheckEquals( 5, ba.baTransaction_List.ItemCount);
      CheckTransaction( 2, 1, ba);
      CheckTransaction( 2, 2, ba);
      CheckTransaction( 2, 3, ba);
      CheckTransaction( 2, 4, ba);
      CheckTransaction( 2, 5, ba);

      //check transactions for account 3
      ba := BankAccountList.Bank_Account_At(2);
      CheckEquals( 3, ba.baTransaction_List.ItemCount);

      CheckTransaction( 3, 6, ba);
      CheckTransaction( 3, 7, ba);
      CheckTransaction( 3, 8, ba);
    finally
      BankAccountList.Free;
    end;
  finally
    //clean up after test
    //DeleteFile( WddxFilename);
  end;
end;
*)
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXImportTests.TestValidateTransaction;
var
  BKT : pTRansaction_rec;
  WebXT : pTransaction_rec;
  s : string;
begin
  //create a bk5 transaction and a webx transaction
  New( BKT);
  New( WebXT);
  try
    //cannot import if bk5 transaction is locked

    BKT^.txDate_Presented := 1;
    WebXT^.txDate_Presented := 1;
    WebXT^.txFirst_Dissection := nil;

    BKT^.txLocked := false;
    BKT^.txDate_Transferred := 0;
    BKT^.txFirst_Dissection := nil;
    CheckEquals( True, ValidateTransactionForImport( WebXT, BKT ,s), 'Expect pass');

    BKT^.txLocked := true;
    BKT^.txDate_Transferred := 0;
    CheckEquals( False, ValidateTransactionForImport( WebXT, BKT ,s), 'Expect fail bkt locked');

    BKT^.txLocked := false;
    BKT^.txDate_Transferred := 1;
    CheckEquals( False, ValidateTransactionForImport( WebXT, BKT, s), 'Expect fail bkt transfered');

    BKT^.txLocked := false;
    BKT^.txDate_Transferred := 0;
    WebXT^.txDate_Presented := 2;
    CheckEquals( False, ValidateTransactionForImport( WebXT, BKT, s), 'Expect fail bkt Pres Date changed');

  finally
    Dispose( BKT);
    Dispose( WebXT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TWebXTransactionImportTests }
const
  Apr01_2004 = 147649;
  Apr02_2004 = Apr01_2004 + 1;
  Apr03_2004 = Apr01_2004 + 2;
  Apr04_2004 = Apr01_2004 + 3;
  Apr05_2004 = Apr01_2004 + 4;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.CheckDissectionLevelNarration(
  ExpectedResultSet: TDissectedResultSet; pT_CodeIT: pTransaction_Rec;
  RecreateProc: TRecreateProc; ExpectedCase: integer; TestID: string);
//generic routine for testing the narration for each dissection line
//requires a set of expected results for each line
//comprises of 10 tests
//test 0: Dont change anything
//
//                Notes       Payee       Notes and Payee
// Dont           test 1      test 4      test 7
// Overwrite
//
// Append         test 2      test 5      test 8
//
// Release        test 3      test 6      test 9
//
// Supports up to 5 dissection lines per test
var
  pT_BK5 : pTransaction_Rec;
  Lines : integer;

  procedure CheckDissectLines( TNo : integer);
  var
    pD_BK5 : pDissection_Rec;
    i : integer;
  begin
    pD_BK5 := pT_BK5.txFirst_Dissection;
    for i := 1 to lines do
    begin
      CheckEquals( ExpectedResultSet[ TNo, i], pD_BK5.dsGL_Narration, TestID + '.T' + IntToStr(TNo) + '.' + IntToStr(i));
      pD_BK5 := pD_BK5.dsNext;
    end;
  end;

begin
  pT_BK5 := nil;
  try
    //dont fill
    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckEquals( CountOfDissectionLines( pT_CodeIT), Lines, TestID + ' Lines');
    CheckDissectLines(0);

    //fill with notes  dont overwrite, append, replace
    BK5TestClient.clFields.clECoding_Import_Options := noFillWithNotes or noDontOverwrite;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(1);

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithNotes or noAppend;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(2);

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithNotes;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(3);

    //fill with payee  dont overwrite, append, replace
    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName or noDontOverwrite;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(4);

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName or noAppend;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(5);

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(6);

    //fill with payee + notes dont overwrite, append, replace
    BK5TestClient.clFields.clECoding_Import_Options := noFillWithBoth or noDontOverwrite;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(7);

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithBoth or noAppend;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(8);

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithBoth;
    RecreateProc( pT_BK5);
    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    Lines := CountOfDissectionLines( pT_BK5);
    CheckDissectLines(9);

  finally
    BK5TestClient.clFields.clECoding_Import_Options := 0;
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.CheckForImportNoteLine( FieldName : string; Note : string);
//verify that a particular string is present in the import note
begin
  Check( Pos( ': '+FieldName, Note) > 0, FieldName + ' Tag expected; Was "' + Note + '"');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.CheckTransactionLevelNarration(
  ExpectedResultSet: TResultSet; pT_CodeIT: pTransaction_Rec;
  RecreateProc: TRecreateProc; ExpectedCase : integer; TestID : string);
//generic routine for testing the narration at transaction level
//requires a set of expected results for each line
//comprises of 10 tests
//test 0: Dont change anything
//
//                Notes       Payee       Notes and Payee
// Dont           test 1      test 4      test 7
// Overwrite
//
// Append         test 2      test 5      test 8
//
// Release        test 3      test 6      test 9
//
var
  pT_BK5 : pTransaction_Rec;

  procedure CheckNarration( TNo : integer);
  begin
    CheckEquals( ExpectedResultSet[TNo], pT_BK5.txGL_Narration, TestID + '.T' + IntToStr(TNo));
  end;

begin
  pT_BK5 := nil;
  try
    //dont fill
    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    RecreateProc( pT_BK5);
    if pT_CodeIT.txFirst_Dissection = nil then
      WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
    else
      WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);

    CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
    CheckNarration(0);


    //Notes Only
      //fill when gl narration does exist
      BK5TestClient.clFields.clECoding_Import_Options := noFillWithNotes or noDontOverwrite;
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(1);

      BK5TestClient.clFields.clECoding_Import_Options := noFillWithNotes or noAppend;
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(2);

      BK5TestClient.clFields.clECoding_Import_Options := noFillWithNotes;   //replace
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(3);

    //Payee Only
      //fill when gl narration does exist
      BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName or noDontOverwrite;
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(4);

      BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName or noAppend;
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(5);

      BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;   //replace
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(6);

    //Payee and Narration Only
      //fill when gl narration does exist
      BK5TestClient.clFields.clECoding_Import_Options := noFillWithBoth or noDontOverwrite;
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(7);

      BK5TestClient.clFields.clECoding_Import_Options := noFillWithBoth or noAppend;
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(8);

      BK5TestClient.clFields.clECoding_Import_Options := noFillWithBoth;   //replace
      RecreateProc( pT_BK5);
      if pT_CodeIT.txFirst_Dissection = nil then
        WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00')
      else
        WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
      CheckEquals( ExpectedCase, pT_Bk5.txTemp_Tag, TestID + ' Case');
      CheckNarration(9);
  finally
    BK5TestClient.clFields.clECoding_Import_Options := 0;
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.CreateBK5TestClient;
//creates a test client with basic chart, single bank account, and payees
var
  pCH : pAccount_Rec;
  NewLine : pPayee_Line_Rec;
begin
  //create a test client
  BK5TestClient := TClientObj.Create;
  //basic client details
  BK5TestClient.clFields.clCode := 'UNITTEST';
  BK5TestClient.clFields.clName := 'DUnit Test Client';
  BK5TestClient.clFields.clCountry := 0;    //New Zealand
  BK5TestClient.clFields.clFile_Type := 0;  //banklink file
  BK5TestClient.clFields.clAccounting_System_Used := 0;
  BK5TestClient.clFields.clFinancial_Year_Starts := 147649; //01 April 2004
  BK5TestClient.clFields.clMagic_Number  := 123456;

  //gst rates (NZ)
  BK5TestClient.clFields.clGST_Applies_From[1] := 138883; // 01 Jan 1980

  {Income}
  BK5TestClient.clFields.clGST_Class_Codes[1]  := 'I';
  BK5TestClient.clFields.clGST_Class_Names[1]  := 'GST on Sales';
  BK5TestClient.clFields.clGST_Class_Types[1]  := gtOutputTax;
  BK5TestClient.clFields.clGST_Rates[1,1]      := 125000;
  {Expenditure}
  BK5TestClient.clFields.clGST_Class_Codes[2]  := 'E';
  BK5TestClient.clFields.clGST_Class_Names[2]  := 'GST on Purchases';
  BK5TestClient.clFields.clGST_Class_Types[2]  := gtInputTax;
  BK5TestClient.clFields.clGST_Rates[2,1]      := 125000;
  {Exempt}
  BK5TestClient.clFields.clGST_Class_Codes[3]  := 'X';
  BK5TestClient.clFields.clGST_Class_Names[3]  := 'Exempt';
  BK5TestClient.clFields.clGST_Class_Types[3]  := gtExempt;
  BK5TestClient.clFields.clGST_Rates[3,1]      := 0;

  //chart
  Chart230 := bkChio.New_Account_Rec;
  Chart230^.chAccount_Code := '230';
  Chart230^.chAccount_Description := 'Sales';
  Chart230^.chGST_Class := 1;
  Chart230^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( Chart230);

  Chart400 := bkChio.New_Account_Rec;
  Chart400^.chAccount_Code := '400';
  Chart400^.chAccount_Description := 'Expenses 400';
  Chart400^.chGST_Class := 2;
  Chart400^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( Chart400);

  pCH := bkChio.New_Account_Rec;
  pCH^.chAccount_Code := '401';
  pCH^.chAccount_Description := 'Expenses 401';
  pCH^.chGST_Class := 2;
  pCH^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( pCH);

  pCH := bkChio.New_Account_Rec;
  pCH^.chAccount_Code := '402';
  pCH^.chAccount_Description := 'Expenses 402';
  pCH^.chGST_Class := 2;
  pCH^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( pCH);

  pCH := bkChio.New_Account_Rec;
  pCH^.chAccount_Code := '500';
  pCH^.chAccount_Description := 'Expenses GST Exempt';
  pCH^.chGST_Class := 3;
  pCH^.chPosting_Allowed := true;
  BK5TestClient.clChart.Insert( pCH);

  //payees
  Payee1 := TPayee.Create;
  Payee1.pdFields.pdName := 'Single Payee';
  Payee1.pdFields.pdNumber := 1;
  BK5TestClient.clPayee_List.Insert(Payee1);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '400';
    NewLine.plGST_Class := 2;
    NewLine.plPercentage := 10000;     //100%
    NewLine.plGL_Narration := 'P1 Line 1';
    Payee1.pdLines.Insert(NewLine);

  Payee2 := TPayee.Create;
  Payee2.pdFields.pdName := 'Dissected Payee';
  Payee2.pdFields.pdNumber := 2;
  BK5TestClient.clPayee_List.Insert(Payee2);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '400';
    NewLine.plGST_Class := 2;
    NewLine.plPercentage := 3000;     //100%
    NewLine.plGL_Narration := 'P2 Line 1';
    Payee2.pdLines.Insert(NewLine);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '401';
    NewLine.plPercentage := 7000;     //100%
    NewLine.plGST_Class := 2;
    NewLine.plGL_Narration := 'P2 Line 2';
    Payee2.pdLines.Insert(NewLine);

  Payee3 := TPayee.Create;
  Payee3.pdFields.pdName := 'Single Payee with GST override';
  Payee3.pdFields.pdNumber := 3;
  BK5TestClient.clPayee_List.Insert(Payee3);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '400';
    NewLine.plGST_Class := 3;
    NewLine.plPercentage := 10000;     //100%
    NewLine.plGST_Has_Been_Edited := true;
    NewLine.plGL_Narration := 'P3 Line 1';
    Payee3.pdLines.Insert(NewLine);

  Payee4 := TPayee.Create;
  Payee4.pdFields.pdName := 'Dissected Payee with GST override';
  Payee4.pdFields.pdNumber := 4;
  BK5TestClient.clPayee_List.Insert(Payee4);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '400';
    NewLine.plGST_Class := 2;
    NewLine.plPercentage := 3000;     //30%
    NewLine.plGL_Narration := 'P4 Line 1';
    Payee4.pdLines.Insert(NewLine);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '402';
    NewLine.plPercentage := 7000;     //70%
    NewLine.plGST_Class := 3;
    NewLine.plGL_Narration := 'P4 Line 2';
    NewLine.plGST_Has_Been_Edited := true;    //GST OVERRIDE!!
    Payee4.pdLines.Insert(NewLine);

  //payees
  Payee5 := TPayee.Create;
  Payee5.pdFields.pdName := 'Single Blank Payee';
  Payee5.pdFields.pdNumber := 5;
  BK5TestClient.clPayee_List.Insert(Payee5);

    NewLine := bkplio.New_Payee_Line_Rec;
    NewLine.plAccount := '';
    NewLine.plGST_Class := 0;
    NewLine.plPercentage := 10000;     //100%
    NewLine.plGL_Narration := 'P5 Line 1';
    Payee5.pdLines.Insert(NewLine);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.RecreateBK5Transaction_Case1_NoNarration(
  var pT: pTransaction_Rec);
//used by the narration testing routines to recreate a transaction for testing
//narration is empty
//case 1: Non dissected BK5 transaction
begin
  if Assigned( pT) then
    trxList32.Dispose_Transaction_Rec( pT);

  pT := bktxio.New_Transaction_Rec;
  pT^.txDate_Presented  := Apr01_2004;
  pT^.txDate_Effective  := Apr01_2004;
  pT^.txECoding_Transaction_UID      := 1;
  pT.txAmount := 10000;
  pT.txNotes  := 'NOTE';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.RecreateBK5Transaction_Case1_WithNarration(
  var pT: pTransaction_Rec);
//used by the narration testing routines to recreate a transaction for testing
//narration is filled
//case 1: Non dissected BK5 transaction
begin
  if Assigned( pT) then
    trxList32.Dispose_Transaction_Rec( pT);

  pT := bktxio.New_Transaction_Rec;
  pT^.txDate_Presented  := Apr01_2004;
  pT^.txDate_Effective  := Apr01_2004;
  pT^.txECoding_Transaction_UID      := 1;
  pT.txAmount := 10000;
  pT.txNotes  := 'NOTE';
  pT.txGL_Narration := 'BK5';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.RecreateBK5Transaction_Case6_NoNarration( var pT : pTransaction_Rec);
//used by the narration testing routines to recreate a transaction for testing
//narration is empty
//case 6: uncoded bk5 transaction
begin
  if Assigned( pT) then
    trxList32.Dispose_Transaction_Rec( pT);

  pT := bktxio.New_Transaction_Rec;
  pT^.txDate_Presented  := Apr01_2004;
  pT^.txDate_Effective  := Apr01_2004;
  pT^.txECoding_Transaction_UID      := 1;
  pT.txAmount := 10000;
  pT.txNotes  := 'NOTE';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.RecreateBK5Transaction_Case6_WithNarration(
  var pT: pTransaction_Rec);
//used by the narration testing routines to recreate a transaction for testing
//narration is empty
//case 6: uncoded bk5 transaction
begin
  if Assigned( pT) then
    trxList32.Dispose_Transaction_Rec( pT);

  pT := bktxio.New_Transaction_Rec;
  pT^.txDate_Presented  := Apr01_2004;
  pT^.txDate_Effective  := Apr01_2004;
  pT^.txECoding_Transaction_UID      := 1;
  pT.txAmount := 10000;
  pT.txNotes  := 'NOTE';
  pT.txGL_Narration := 'BK5';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.Setup;
//create a client for use within each test
begin
  inherited;

  CreateBK5TestClient;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TearDown;
begin
  //destroy the test client
  BK5TestClient.Free;

  inherited;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_AccountChanged;
//case 1  CodeIT  Not dissection  BK  not dissected
//change the account
//dont expect the gst or account to be imported
//expect a import note to be created
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00
    pT_BK5.txAccount          := '230';
    pT_BK5.txGST_Class        := 1;
    pT_BK5.txGST_Amount       := 1111;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAccount         := '330';

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');

    CheckEquals( '230', pT_BK5^.txAccount, 'Account');
    CheckEquals( 1, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 1111, pT_BK5.txGST_Amount, 'GST Amount');
    CheckForImportNoteLine( 'Account', pT_BK5^.txECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_AccountSet;
//case 1  CodeIT  Not dissection  BK  not dissected
//set the account, expect gst class and amoun to be updated from the chart
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAccount         := '230';

    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');

    CheckEquals( '230', pT_BK5^.txAccount, 'Account');
    CheckEquals( 1, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( Round(10000 / 9), pT_BK5.txGST_Amount, 'GST Amount');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_AccountSetToUnknown;
//case 1  CodeIT  Not dissection  BK  not dissected
//unknown account code used, expect an only the account to be updated
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAccount         := '330';

    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');

    CheckEquals( '330', pT_BK5^.txAccount, 'Account');
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'GST Amount');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_AccountSet_GSTAmountChanged;
//case 1  CodeIT  Not dissection  BK  not dissected
// gst amount changed, expect gst amount to remain the same and an import note
// to be created
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAccount         := '230';
    pT_CodeIT^.txGST_Has_Been_Edited := true;
    pT_CodeIT^.txGST_Amount      := 0;

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');

    CheckEquals( '230', pT_BK5^.txAccount, 'Account');
    CheckEquals( 1, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 1111, pT_BK5.txGST_Amount, 'GST Amount');
    CheckForImportNoteLine( 'GST Amount', pT_BK5^.txECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_AmountChanged;
//case 1  CodeIT  Not dissection  BK  not dissected
//amount edited, expnect nothing to change, import note should be created
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAmount          := 10500;  //$100.00

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount should be unchanged');
    CheckForImportNoteLine( 'Amount 105.00', pT_BK5.txECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_AmountChangedForUPI;
//case 1  CodeIT  Not dissection  BK  not dissected
//change the amount of a upc, dont expect amount to change, expect import note
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00
    pT_BK5.txUPI_State        := upUPC;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAmount          := 10500;  //$100.00

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount should be unchanged');
    CheckForImportNoteLine( 'Amount', pT_BK5^.txECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_AmountSetForUPI;
//case 1  CodeIT  Not dissection  BK  not dissected
//amount set for a upi, expect new amount to be used, expect new amount to be
//used for gst calculation
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 0;
    pT_BK5.txUPI_State        := upUPC;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAmount          := 10500;  //$100.00
    pT_CodeIT^.txAccount         := '400';
    pT_CodeIT^.txGST_CLass       := Chart400.chGST_Class;
    pT_CodeIT.txGST_Amount       := Round(10500/9);

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 10500, pT_BK5.txAmount, 'Amount should be unchanged');
    CheckEquals( Integer(Chart400.chGST_Class), Integer(pT_CodeIT^.txGST_CLass), 'GST Class');
    CheckEquals( Round(10500/9), pT_CodeIT.txGST_Amount, 'GST Amount');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_Narration_Blank;
//case 1  CodeIT  Not dissection  BK  not dissected
//test that narration is set to expected values under all conditions
//start with blank narration
var
  pT_CodeIT : pTransaction_Rec;
  P : string;
  E : TResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  try
    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txGL_Narration    := 'C';  //should never occur
    PT_CodeIT^.txNotes           := 'NOTE';

    pT_CodeIT^.txPayee_Number    := 1;  //single payee
    pT_CodeIT^.txAccount         := '400';
    pT_CodeIT^.txGST_Class       := 2;
    pT_CodeIT^.txGST_Amount      := 1111;

    P := Payee1.FirstLine.plGL_Narration;

    e[0]  := '';                //dont fill
    //fill with notes bk5 gl narration blank   dont overwrite, append, replace
    e[1]  := 'NOTE';
    e[2]  := 'NOTE';
    e[3]  := 'NOTE';
    //fill with payee bk5 gl narration = ''   dont overwrite, append, replace
    e[4]  := P;
    e[5]  := P;
    e[6]  := P;
    //fill with payee + notes bk5 gl narration = ''   dont overwrite, append, replace
    e[7]  := P + ' : NOTE';
    e[8]  := P + ' : NOTE';
    e[9]  := P + ' : NOTE';

    CheckTransactionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case1_NoNarration, 1, '1');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_Narration_PreExisting;
//case 1  CodeIT  Not dissection  BK  not dissected
//test that narration is set to expected values under all conditions
//start with narration preexisting
var
  pT_CodeIT : pTransaction_Rec;
  P : string;
  E : TResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  try
    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txGL_Narration    := 'C';  //should never occur
    PT_CodeIT^.txNotes           := 'NOTE';

    pT_CodeIT^.txPayee_Number    := 1;  //single payee
    pT_CodeIT^.txAccount         := '400';
    pT_CodeIT^.txGST_Class       := 2;
    pT_CodeIT^.txGST_Amount      := 1111;

    P := Payee1.FirstLine.plGL_Narration;

    e[0]  := 'BK5';                //dont fill
    //fill with notes bk5 gl narration = BK5   dont overwrite, append, replace
    e[1]  := 'BK5';
    e[2]  := 'BK5 : NOTE';
    e[3]  := 'NOTE';
    //fill with payee bk5 gl narration = BK5   dont overwrite, append, replace
    e[4]  := 'BK5';
    e[5]  := 'BK5 : ' + P;
    e[6]  := P;
    //fill with notes bk5 gl narration = BK5   dont overwrite, append, replace
    e[7]  := 'BK5';
    e[8]  := 'BK5 : ' + P + ' : NOTE';
    e[9]  := P + ' : NOTE';

    CheckTransactionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case1_WithNarration, 1, '1');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_Notes;
//case 1  CodeIT  Not dissection  BK  not dissected
//check with notes blank and notes preexisting, expect new notes to be applied
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txNotes           := 'Test Notes';

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( pT_CodeIT.txNotes, pT_BK5.txNotes, 'Notes');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');

    pT_BK5.txNotes     := 'Notes to clear';
    pT_CodeIT^.txNotes := '';

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( pT_CodeIT.txNotes, pT_BK5.txNotes, 'Notes (cleared)');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_PayeeSet;
//case 1  CodeIT  Not dissection  BK  not dissected
//set the payee for an uncoded bk transaction
//expect gst class and amount to be set from the chart
//expect payee nubmer to be updated
//expect payee details to be used for the narration
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txPayee_Number    := 1;  //single payee
    pT_CodeIT^.txAccount         := '400';
    pT_CodeIT^.txGST_Class       := 2;
    pT_CodeIT^.txGST_Amount      := 1111;


    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    finally
       BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( '400', pT_BK5^.txAccount, 'Account');
    CheckEquals( 2, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( Round(10000 / 9), pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( 1, pT_BK5^.txPayee_Number);
    CheckEquals( Payee1.FirstLine.plGL_Narration, pT_BK5^.txGL_Narration, 'Narration');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_PayeeSet_AccountChanged;
//case 1  CodeIT  Not dissection  BK  not dissected
//edit the account once the transaction has been coded via payee
//gl narration should now be payee name instead of narration for first line
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txPayee_Number    := 1;  //single payee
    pT_CodeIT^.txAccount         := '500';
    pT_CodeIT^.txGST_Class       := 3;
    pT_CodeIT^.txGST_Amount      := 0;


    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    finally
       BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( '500', pT_BK5^.txAccount, 'Account');
    CheckEquals( 3, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( 1, pT_BK5^.txPayee_Number);
    CheckEquals( Payee1.pdName, pT_BK5^.txGL_Narration, 'Narration'); //cant decide if account or payee was entered first so assume account
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_PayeeSet_GSTAmountChanged;
//case 1  CodeIT  Not dissection  BK  not dissected
//code by payee then overide the gst amount
//expect gst amount to be set from chart and an import note added
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txPayee_Number    := 1;  //single payee
    pT_CodeIT^.txAccount         := Payee1.FirstLine.plAccount;
    pT_CodeIT^.txGST_Class       := 3;
    pT_CodeIT^.txGST_Amount      := 0;
    pT_CodeIT^.txGST_Has_Been_Edited  := true;

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    finally
       BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( Payee1.FirstLine.plAccount, pT_BK5^.txAccount, 'Account');
    CheckEquals( Integer(Payee1.FirstLine.plGST_Class), Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( Round(10000 / 9), pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( 1, pT_BK5^.txPayee_Number);
    CheckEquals( Payee1.FirstLine.plGL_Narration, pT_BK5^.txGL_Narration, 'Narration');
    CheckForImportNoteLine( 'GST Amount', pT_BK5^.txECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_PayeeSet_WithOveride;
//case 1  CodeIT  Not dissection  BK  not dissected
//payee set with gst override in payee line
//expect transaction to be coded and default gst information to be taken from
//the payee rather than the chart
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txPayee_Number    := 3;  //single payee
    pT_CodeIT^.txAccount         := Payee3.FirstLine.plAccount;
    pT_CodeIT^.txGST_Class       := Payee3.FirstLine.plGST_Class;
    pT_CodeIT^.txGST_Amount      := 0;

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    finally
       BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( Payee3.FirstLine.plAccount, pT_BK5^.txAccount, 'Account');
    CheckEquals( Integer(Payee3.FirstLine.plGST_Class), Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( Payee3.pdNumber, pT_BK5^.txPayee_Number);
    CheckEquals( Payee3.FirstLine.plGL_Narration, pT_BK5^.txGL_Narration, 'Narration');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_PayeeSet_WithOveride_GSTAmountChanged;
//case 1  CodeIT  Not dissection  BK  not dissected
//code trnsaction via payee then override gst amount (no override in payee)
//expect gst amout to be set from chart and gst amount note to be added
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txPayee_Number    := 3;  //single payee
    pT_CodeIT^.txAccount         := Payee3.FirstLine.plAccount;
    pT_CodeIT^.txGST_Class       := 0;
    pT_CodeIT^.txGST_Amount      := 10;
    pT_CodeIT^.txGST_Has_Been_Edited := true;

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    finally
       BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( Payee3.FirstLine.plAccount, pT_BK5^.txAccount, 'Account');
    CheckEquals( Integer(Payee3.FirstLine.plGST_Class), Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( Payee3.pdNumber, pT_BK5^.txPayee_Number);
    CheckEquals( Payee3.FirstLine.plGL_Narration, pT_BK5^.txGL_Narration, 'Narration');
    CheckForImportNoteLine( 'GST Amount', pT_BK5^.txECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_QuantityChanged;
//case 1  CodeIT  Not dissection  BK  not dissected
//edit quantity, expect existing quantity to remain and import note to be added
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;
    pT_BK5.txQuantity         := 1234;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txQuantity        := 4567;

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 1234, pt_bk5.txQuantity, 'Quantity');
    CheckForImportNoteLine( 'Quantity', pT_BK5^.txECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_QuantitySet;
//case 1  CodeIT  Not dissection  BK  not dissected
//edit quantity in codeit, expect to be set in bk5 as existing quantity is zero
//check 4 case so that we can be sure that the quantity always matches the sign
//of the transaction
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txQuantity        := 1234;

    //check quantity
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 1234, pT_BK5.txQuantity, 'Quantity');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');

    //check sign is corrected
    pT_BK5.txQuantity := 0;
    pT_CodeIT.txQuantity := -1234;
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 1234, pT_BK5.txQuantity, 'Quantity');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');

    //check sign is corrected
    pT_BK5.txAmount := -10000;
    pT_BK5.txQuantity := 0;
    pT_CodeIT.txQuantity := -1234;
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( -1234, pT_BK5.txQuantity, 'Quantity');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');

    //check sign is corrected
    pT_BK5.txAmount := -10000;
    pT_BK5.txQuantity := 0;
    pT_CodeIT.txQuantity := 1234;
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( -1234, pT_BK5.txQuantity, 'Quantity');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_TaxInvoice;
//case 1  CodeIT  Not dissection  BK  not dissected
//set tax invoice value in codeit, bk5 setting to be override, no note expected
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txTax_Invoice_Available := false;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txTax_Invoice_Available := true;

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( pT_CodeIT.txTax_Invoice_Available, pT_BK5.txTax_Invoice_Available, 'TaxInvoice');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');

    pT_BK5.txTax_Invoice_Available := true;
    pT_CodeIT^.txTax_Invoice_Available := false;

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( pT_CodeIT.txTax_Invoice_Available, pT_BK5.txTax_Invoice_Available, 'TaxInvoice (cleared)');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_UnchangedBasic;
//case 1  CodeIT  Not dissection  BK  not dissected
//export and import the same transaction, nothing should change
//dont fill the payee name as the narration is checked in a seperate test
var
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00
    pT_BK5^.txAccount         := '230';
    pT_BK5^.txGST_Class       := 1;
    pT_BK5^.txGST_Amount      := 1111;
    pT_BK5^.txGL_Narration    := 'NARR';
    pT_BK5^.txNotes           := 'NOTES';

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pT_BK5, pT_BK5, BK5TestClient, '00');
    finally
      BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( '230', pT_BK5^.txAccount, 'Account');
    CheckEquals( 1, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 1111, pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( 0, pT_BK5^.txPayee_Number);
    CheckEquals( 'NARR', pT_BK5^.txGL_Narration, 'Narration');
    CheckEquals( 'NOTES', pT_BK5^.txNotes, 'Notes');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase1_UnchangedWithPayee;
//case 1  CodeIT  Not dissection  BK  not dissected
//same test as above, nothing changed, however this time there is a payee
//on the transaction so we have updated the narration with the payee name.
//nothing should change and no note expected
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00
    pT_BK5^.txPayee_Number    := 1;  //single payee
    pT_BK5^.txAccount         := Payee1.FirstLine.plAccount;
    pT_BK5^.txGST_Class       := Payee1.FirstLine.plGST_Class;
    pT_BK5^.txGST_Amount      := 1111;

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pT_BK5, pT_BK5, BK5TestClient, '00');
    finally
      BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( Payee1.FirstLine.plAccount, pT_BK5^.txAccount, 'Account');
    CheckEquals( Integer(Payee1.FirstLine.plGST_Class), Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 1111, pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( 1, pT_BK5^.txPayee_Number);
    CheckEquals( Payee1.FirstLine.plGL_Narration, pT_BK5^.txGL_Narration, 'Narration'); //cant decide if account or payee was entered first so assume account
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase1_BlankPayee_BlankNarr;
//case 1  CodeIT  Not dissection  BK  not dissected
//blank bk5 transaction, code the CodeIT transaction using a blank payee
//should retain bk5 narration
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00
    pT_BK5^.txPayee_Number    := 0;
    pT_BK5^.txAccount         := '';
    pT_BK5^.txGST_Class       := 0;
    pT_BK5^.txGST_Amount      := 0;
    pT_BK5^.txGL_Narration    := 'NARR';

    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAmount          := 10000;  //$100.00
    pT_CodeIT^.txPayee_Number    := 5;  //single payee
    pT_CodeIT^.txAccount         := '';
    pT_CodeIT^.txGST_Class       := 0;
    pT_CodeIT^.txGST_Amount      := 0;

    Payee5.pdLines.PayeeLine_At(0).plGL_Narration := '';

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pt_CodeIT, pT_BK5, BK5TestClient, '00');
    finally
      BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( '', pT_BK5^.txAccount, 'Account');
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( 5, pT_BK5^.txPayee_Number);
    CheckEquals( pT_BK5^.txGL_Narration, 'NARR', 'Narration'); //cant decide if account or payee was entered first so assume account
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;


procedure TWebXTransactionImportTests.TestCase1_BlankPayee_PayeeName;
//case 1  CodeIT  Not dissection  BK  not dissected
//blank bk5 transaction, code the CodeIT transaction using a blank payee
//payee name specified, should see name in narration
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00
    pT_BK5^.txPayee_Number    := 0;
    pT_BK5^.txAccount         := '';
    pT_BK5^.txGST_Class       := 0;
    pT_BK5^.txGST_Amount      := 0;
    pT_BK5^.txGL_Narration    := 'NARR';

    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAmount          := 10000;  //$100.00
    pT_CodeIT^.txPayee_Number    := 5;  //single payee
    pT_CodeIT^.txAccount         := '';
    pT_CodeIT^.txGST_Class       := 0;
    pT_CodeIT^.txGST_Amount      := 0;

    Payee5.pdLines.PayeeLine_At(0).plGL_Narration := Payee5.pdFields.pdName;

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pt_CodeIT, pT_BK5, BK5TestClient, '00');
    finally
      BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( '', pT_BK5^.txAccount, 'Account');
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( 5, pT_BK5^.txPayee_Number);
    CheckEquals( pT_BK5^.txGL_Narration, Payee5.pdFields.pdName, 'Narration'); //cant decide if account or payee was entered first so assume account
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;


procedure TWebXTransactionImportTests.TestCase1_BlankPayee_Custom;
//case 1  CodeIT  Not dissection  BK  not dissected
//blank bk5 transaction, code the CodeIT transaction using a blank payee
//custom narration specified, should see custom in narr
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00
    pT_BK5^.txPayee_Number    := 0;
    pT_BK5^.txAccount         := '';
    pT_BK5^.txGST_Class       := 0;
    pT_BK5^.txGST_Amount      := 0;
    pT_BK5^.txGL_Narration    := 'NARR';

    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txAmount          := 10000;  //$100.00
    pT_CodeIT^.txPayee_Number    := 5;  //single payee
    pT_CodeIT^.txAccount         := '';
    pT_CodeIT^.txGST_Class       := 0;
    pT_CodeIT^.txGST_Amount      := 0;

    Payee5.pdLines.PayeeLine_At(0).plGL_Narration := 'CUSTOM';

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    try
      WebXUtils.ImportStandardTransaction( pt_CodeIT, pT_BK5, BK5TestClient, '00');
    finally
      BK5TestClient.clFields.clECoding_Import_Options := 0;
    end;

    CheckEquals( 1, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( '', pT_BK5^.txAccount, 'Account');
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'GST Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'GST Amount');
    CheckEquals( 5, pT_BK5^.txPayee_Number);
    CheckEquals( pT_BK5^.txGL_Narration, 'CUSTOM', 'Narration'); //cant decide if account or payee was entered first so assume account
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;



// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase2_EditableFields;
//case 2: CodeIT transaction standard, bk5 transaction is dissected
//cannot import the webx transaction because the bk5 one is dissected, the best
//thing to do is export all of the details for the codeit transaction into the
//notes field
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5^.txAmount          := 10000;  //$100.00
    pT_BK5^.txAccount         := 'DISSECTED';
    pT_BK5^.txQuantity        := 0;
    pT_BK5.txGL_Narration     := 'NARR';

    pD_BK5 := bkdsio.New_Dissection_Rec;
    pD_BK5^.dsAccount := '230';
    pD_BK5^.dsAmount  := 5000;
    trxlist32.AppendDissection( pT_BK5, pD_BK5);

    pD_BK5 := bkdsio.New_Dissection_Rec;
    pD_BK5^.dsAccount := '230';
    pD_BK5^.dsAmount  := 5000;
    trxlist32.AppendDissection( pT_BK5, pD_BK5);

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount := 11000;

    //test everything added to import notes
    //amount unchanged
    pT_CodeIt.txUPI_State := upUPC;
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    pT_CodeIt.txUPI_State := 0;
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount unchanged');
    CheckForImportNoteLine( 'Amount', pT_BK5.txECoding_Import_Notes);

    pT_CodeIt.txAccount := '230';
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 'DISSECTED', pT_Bk5.txAccount, 'Account');
    CheckForImportNoteLine( 'Account ', pT_BK5.txECoding_Import_Notes);

    pT_CodeIt.txGST_Has_Been_Edited := True;
    pT_CodeIt.txGST_Amount := 111;
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 0, pT_Bk5.txGST_Amount, 'Account');
    CheckForImportNoteLine( 'GST Amount', pT_BK5.txECoding_Import_Notes);

    pT_CodeIT.txPayee_Number := 1;
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 0, pT_Bk5.txPayee_Number, 'Payee');
    CheckForImportNoteLine( 'Payee', pT_BK5.txECoding_Import_Notes);

    pT_CodeIT.txQuantity := 1;
    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 0, pT_Bk5.txPayee_Number, 'Quantity');
    CheckForImportNoteLine( 'Quantity', pT_BK5.txECoding_Import_Notes);

    CheckEquals( 'NARR', pT_BK5.txGL_Narration, 'Narration unchanged');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase2_Notes;
//case 2: CodeIT transaction standard, bk5 transaction is dissected
//check that the note on the transaction are imported
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
      pD_BK5 := bkdsio.New_Dissection_Rec;
      pD_BK5^.dsAccount := '230';
      pD_BK5^.dsAmount  := 5000;
      trxlist32.AppendDissection( pT_BK5, pD_BK5);
      pD_BK5 := bkdsio.New_Dissection_Rec;
      pD_BK5^.dsAccount := '230';
      pD_BK5^.dsAmount  := 5000;
      trxlist32.AppendDissection( pT_BK5, pD_BK5);

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txNotes           := 'Test Notes';

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( pT_CodeIT.txNotes, pT_BK5.txNotes, 'Notes');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');

    pT_BK5.txNotes     := 'Notes to clear';
    pT_CodeIT^.txNotes := '';

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( pT_CodeIT.txNotes, pT_BK5.txNotes, 'Notes (cleared)');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase2_TaxInvoice;
//case 2: CodeIT transaction standard, bk5 transaction is dissected
//check that we bk5 tax invoice flag is set correctly. no note expected
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txTax_Invoice_Available := false;
    pT_BK5.txAmount := 10000;

    pD_BK5 := bkdsio.New_Dissection_Rec;
    pD_BK5^.dsAccount := '230';
    pD_BK5^.dsAmount  := 5000;
    trxlist32.AppendDissection( pT_BK5, pD_BK5);

    pD_BK5 := bkdsio.New_Dissection_Rec;
    pD_BK5^.dsAccount := '230';
    pD_BK5^.dsAmount  := 5000;
    trxlist32.AppendDissection( pT_BK5, pD_BK5);

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT^.txTax_Invoice_Available := true;

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( pT_CodeIT.txTax_Invoice_Available, pT_BK5.txTax_Invoice_Available, 'TaxInvoice');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');

    pT_BK5.txTax_Invoice_Available := true;
    pT_CodeIT^.txTax_Invoice_Available := false;

    WebXUtils.ImportStandardTransaction( pT_CodeIt, pT_BK5, BK5TestClient, '00');
    CheckEquals( 2, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( pT_CodeIT.txTax_Invoice_Available, pT_BK5.txTax_Invoice_Available, 'TaxInvoice (cleared)');
    CheckEquals( '', pT_BK5^.txECoding_Import_Notes, 'Import note');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase3_DifferentAccounts;
//case 3 : CodeIT dissected, BK5 dissect but dissections dont match
//alter an account so that they no longer match
//make sure that the dissection is not imported and the field are exported to
//notes
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 3000;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '231';
        pD_BK5^.dsAmount  := 3000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 3, pT_BK5.txTemp_Tag, 'Case');
    CheckForImportNoteLine( 'Dissection cannot be imported', pT_BK5.txECoding_Import_Notes);
    CheckNotEquals( 'NOTE', pT_BK5.txNotes, 'Notes');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase3_DifferentAmounts;
//case 3 : CodeIT dissected, BK5 dissect but dissections dont match
//alter an aamount so that they no longer match
//make sure that the dissection is not imported and the field are exported to
//notes
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 3000;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 3000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 3, pT_BK5.txTemp_Tag, 'Case');
    CheckForImportNoteLine( 'Dissection cannot be imported', pT_BK5.txECoding_Import_Notes);
    CheckNotEquals( 'NOTE', pT_BK5.txNotes, 'Notes');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase3_DifferentNumberOfLines;
//case 3 : CodeIT dissected, BK5 dissect but dissections dont match
//add a dissection line so that they no longer match
//make sure that the dissection is not imported and the field are exported to
//notes
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 3000;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 2000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 1000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 3, pT_BK5.txTemp_Tag, 'Case');
    CheckForImportNoteLine( 'Dissection cannot be imported', pT_BK5.txECoding_Import_Notes);
    CheckNotEquals( 'NOTE', pT_BK5.txNotes, 'Notes');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase4;
//case 4: CodeIT dissected, BK5 now coded as standard transaction or amount changed
//standard bk5 transaction now code so cant be override with codeIt dissection
//make sure that the dissection is not imported and the field are exported to
//notes
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 11000;

    pD_BK5 := bkdsio.New_Dissection_Rec;
    pD_BK5^.dsAccount := '230';
    pD_BK5^.dsAmount  := 7000;
    trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    pD_BK5 := bkdsio.New_Dissection_Rec;
    pD_BK5^.dsAccount := '230';
    pD_BK5^.dsAmount  := 4000;
    trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 4, pT_BK5.txTemp_Tag, 'Case');
    CheckForImportNoteLine( 'Dissection cannot be imported', pT_BK5.txECoding_Import_Notes);
    CheckNotEquals( 'NOTE', pT_BK5.txNotes, 'Notes');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase6a_AccountSet;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := Chart230.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 7000/9);
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := Chart400.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 3000 / 9);
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 61, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '230', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( Integer(Chart230.chGST_Class), Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 7000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '400', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( Integer(Chart400.chGST_Class), Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6a_AccountSet_GSTAmountChanged;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := Chart230.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 7000/9);
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := Chart400.chGST_Class;
        pD_BK5.dsGST_Amount := 250;
        pD_BK5.dsGST_Has_Been_Edited := True;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 61, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '230', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( Integer(Chart230.chGST_Class), Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 7000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes, 'L1 Import Notes');

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '400', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( Integer(Chart400.chGST_Class), Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');      //Edited
        CheckForImportNoteLine( 'GST Amount', pD_BK5.dsECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6a_AmountChanged;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 11000;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 4000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 4, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckNotEquals( '', pT_BK5.txECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6a_GSTSet;
//gst set without code
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5^.dsGST_Amount := 700;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '';
        pD_BK5^.dsAmount  := 4000;
        pD_BK5^.dsGST_Amount := 400;
        pD_BK5^.dsGST_Has_Been_Edited := true;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 61, pT_BK5.txTemp_Tag, 'Case');
        pD_BK5 := pT_BK5.txFirst_Dissection;
        //no line expects, gst edit flag not set so wont import amount
        CheckEquals('', pD_BK5.dsECoding_Import_Notes, 'No GST Tag expected');

        pD_BK5 := pD_BK5.dsNext;
        CheckForImportNoteLine('GST Amount  4.00', pD_BK5.dsECoding_Import_Notes);
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6a_NarrationAtDissectLevel;
var
  pT_CodeIT : pTransaction_Rec;
  pD_CodeIT : pDissection_Rec;
  E : TDissectedResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  try
    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'note';
        pD_CodeIT := bkdsio.New_Dissection_Rec;
        pD_CodeIT^.dsAccount := '230';
        pD_CodeIT^.dsAmount  := 7000;
        pD_CodeIT^.dsNotes := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_CodeIT);
        pD_CodeIT := bkdsio.New_Dissection_Rec;
        pD_CodeIT^.dsAccount := '230';
        pD_CodeIT^.dsAmount  := 3000;
        pD_CodeIT^.dsNotes := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_CodeIT);

     //    e[ test number, dissection line no] = Expected result

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := '';
     e[4,2]  := '';
     e[5,1]  := '';
     e[5,2]  := '';
     e[6,1]  := '';
     e[6,2]  := '';
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := 'L1 NOTE';
     e[7,2]  := 'L2 NOTE';
     e[8,1]  := 'L1 NOTE';
     e[8,2]  := 'L2 NOTE';
     e[9,1]  := 'L1 NOTE';
     e[9,2]  := 'L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 61, '6a');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6a_NarrationAtTrxLevel;
var
  pT_CodeIT : pTransaction_Rec;
  pD_CodeIT : pDissection_Rec;
  E : TResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  try
    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'note';
        pD_CodeIT := bkdsio.New_Dissection_Rec;
        pD_CodeIT^.dsAccount := '230';
        pD_CodeIT^.dsAmount  := 7000;
        pD_CodeIT^.dsNotes := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_CodeIT);
        pD_CodeIT := bkdsio.New_Dissection_Rec;
        pD_CodeIT^.dsAccount := '230';
        pD_CodeIT^.dsAmount  := 3000;
        pD_CodeIT^.dsNotes := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_CodeIT);

     e[0]  := '';                //dont fill
     //fill with notes bk5 gl narration blank   dont overwrite, append, replace
     e[1]  := 'note';
     e[2]  := 'note';
     e[3]  := 'note';
     //fill with payee bk5 gl narration = ''   dont overwrite, append, replace
     e[4]  := '';
     e[5]  := '';
     e[6]  := '';
     //fill with payee + notes bk5 gl narration = ''   dont overwrite, append, replace
     e[7]  := 'note';
     e[8]  := 'note';
     e[9]  := 'note';

     CheckTransactionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 61, '6a');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6a_NarrationAtTrxLevel_ExistingNarration;
var
  pT_CodeIT : pTransaction_Rec;
  pD_CodeIT : pDissection_Rec;
  E : TResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  try
    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'note';
        pD_CodeIT := bkdsio.New_Dissection_Rec;
        pD_CodeIT^.dsAccount := '230';
        pD_CodeIT^.dsAmount  := 7000;
        pD_CodeIT^.dsNotes := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_CodeIT);
        pD_CodeIT := bkdsio.New_Dissection_Rec;
        pD_CodeIT^.dsAccount := '230';
        pD_CodeIT^.dsAmount  := 3000;
        pD_CodeIT^.dsNotes := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_CodeIT);

     e[0]  := 'BK5';                //dont fill
     //fill with notes bk5 gl narration  bk5 dont overwrite, append, replace
     e[1]  := 'BK5';
     e[2]  := 'BK5 : note';
     e[3]  := 'note';
     //fill with payee bk5 gl narration  bk5   dont overwrite, append, replace
     e[4]  := 'BK5';
     e[5]  := 'BK5';
     e[6]  := 'BK5';
     //fill with payee + notes bk5 gl narration bk5   dont overwrite, append, replace
     e[7]  := 'BK5';
     e[8]  := 'BK5 : note';
     e[9]  := 'note';

     CheckTransactionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_WithNarration, 61, '6a');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
  end;
end;




procedure TWebXTransactionImportTests.TestCase6a_NotesSet;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'CODEIT NOTE';
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := Chart230.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 7000/9);
        pD_BK5.dsNotes      := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := Chart400.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 3000 / 9);
        pD_BK5.dsNotes      := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 61, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 'CODEIT NOTE', pT_BK5.txNotes, 'T Note');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 Note');

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 Note');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6a_QuantitySet;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 4000;
    pT_BK5.txQuantity := 1;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 4000;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := 1000;
        pD_BK5.dsQuantity := 1234;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount := 2000;
        pD_BK5.dsQuantity := -5678;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := -3000;
        pD_BK5.dsQuantity := 2345;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount :=  -4000;
        pD_BK5.dsQuantity := -3456;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 61, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 1, pT_BK5.txQuantity, 'txQuantity unchanged');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( 1234, pD_BK5.dsquantity, 'L1 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( 5678, pD_BK5.dsquantity, 'L2 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( -2345, pD_BK5.dsquantity, 'L3 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( -3456, pD_BK5.dsquantity, 'L4 Quantity');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase6a_TaxInvoice;
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';
    pT_BK5.txTax_Invoice_Available := false;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'CODEIT NOTE';
    pT_CodeIT.txTax_Invoice_Available := true;

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := Chart230.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 7000/9);
        pD_BK5.dsNotes      := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := Chart400.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 3000 / 9);
        pD_BK5.dsNotes      := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 61, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( true, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6b_TaxInvoice;
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';
    pT_BK5.txTax_Invoice_Available := false;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'CODEIT NOTE';
    pT_CodeIT.txPayee_Number := 2;
    pT_CodeIT.txTax_Invoice_Available := true;

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '230';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := Chart230.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 7000/9);
        pD_BK5.dsNotes      := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := Chart400.chGST_Class;
        pD_BK5.dsGST_Amount := Round( 3000 / 9);
        pD_BK5.dsNotes      := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 62, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( true, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6b_DifferentPayee;
//coding doesn't match payee
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TDissectedResultSet;
  P : string;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txPayee_Number     := Payee2.pdNumber;

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 62, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 2, pT_BK5.txPayee_Number, 'txPayee');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        //expect that the gst set using the chart code because payee is differnt
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '402', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( Round( 7000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckForImportNoteLine( 'GST Amount  0.00', pD_BK5.dsECoding_Import_Notes);

     //    e[ test number, dissection line no] = Expected result
     P := Payee2.pdName;

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := P;
     e[4,2]  := P;
     e[5,1]  := P;
     e[5,2]  := P;
     e[6,1]  := P;
     e[6,2]  := P;
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := P + ' : L1 NOTE';
     e[7,2]  := P + ' : L2 NOTE';
     e[8,1]  := P + ' : L1 NOTE';
     e[8,2]  := P + ' : L2 NOTE';
     e[9,1]  := P + ' : L1 NOTE';
     e[9,2]  := P + ' : L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 62, '6b');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6b_DissectedPayee;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TDissectedResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txPayee_Number     := 4;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 62, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 4, pT_BK5.txPayee_Number, 'txPayee');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '402', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( 0, pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);


     //    e[ test number, dissection line no] = Expected result

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := 'P4 Line 1';
     e[4,2]  := 'P4 Line 2';
     e[5,1]  := 'P4 Line 1';
     e[5,2]  := 'P4 Line 2';
     e[6,1]  := 'P4 Line 1';
     e[6,2]  := 'P4 Line 2';
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := 'P4 Line 1 : L1 NOTE';
     e[7,2]  := 'P4 Line 2 : L2 NOTE';
     e[8,1]  := 'P4 Line 1 : L1 NOTE';
     e[8,2]  := 'P4 Line 2 : L2 NOTE';
     e[9,1]  := 'P4 Line 1 : L1 NOTE';
     e[9,2]  := 'P4 Line 2 : L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 62, '6b');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;


procedure TWebXTransactionImportTests.TestCase6b_NarrationAtTrxLevel;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TResultSet;
  P : string;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txPayee_Number     := 4;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

     P := Payee4.pdName;

     e[0]  := '';
     //fill with notes bk5 gl narration existing   dont overwrite, append, replace
     e[1]  := 'NOTE';
     e[2]  := 'NOTE';
     e[3]  := 'NOTE';
     //fill with payee bk5 gl narration existing   dont overwrite, append, replace
     e[4]  := '';
     e[5]  := '';
     e[6]  := '';
     //fill with payee + notes bk5 gl narration existing   dont overwrite, append, replace
     e[7]  := 'NOTE';
     e[8]  := 'NOTE';
     e[9]  := 'NOTE';

     CheckTransactionLevelNarration( e, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 62, '6b');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6b_NarrationAtTrxLevel_ExistingNarration;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TResultSet;
  P : string;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txPayee_Number     := 4;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

     P := Payee4.pdName;

     e[0]  := 'BK5';
     //fill with notes bk5 gl narration existing   dont overwrite, append, replace
     e[1]  := 'BK5';
     e[2]  := 'BK5 : NOTE';
     e[3]  := 'NOTE';
     //fill with payee bk5 gl narration existing   dont overwrite, append, replace
     e[4]  := 'BK5';
     e[5]  := 'BK5';
     e[6]  := 'BK5';
     //fill with payee + notes bk5 gl narration existing   dont overwrite, append, replace
     e[7]  := 'BK5';
     e[8]  := 'BK5 : NOTE';
     e[9]  := 'NOTE';

     CheckTransactionLevelNarration( e, pT_CodeIT, RecreateBK5Transaction_Case6_WithNarration, 62, '6b');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6b_NotesSet;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'CODEIT NOTE';
    pT_CodeIT.txPayee_Number     := 2;

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsNotes      := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '401';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsNotes      := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 62, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 'CODEIT NOTE', pT_BK5.txNotes, 'T Note');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 Note');

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 Note');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6b_QuantitySet;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txQuantity := 1;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'CODEIT NOTE';
    pT_CodeIT.txPayee_Number     := 2;

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := 1000;
        pD_BK5.dsQuantity := 1234;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount := 2000;
        pD_BK5.dsQuantity := -5678;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := -3000;
        pD_BK5.dsQuantity := 2345;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount :=  -4000;
        pD_BK5.dsQuantity := -3456;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 62, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 1, pT_BK5.txQuantity, 'txQuantity unchanged');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( 1234, pD_BK5.dsquantity, 'L1 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( 5678, pD_BK5.dsquantity, 'L2 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( -2345, pD_BK5.dsquantity, 'L3 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( -3456, pD_BK5.dsquantity, 'L4 Quantity');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6b_UnknownPayee;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TDissectedResultSet;
  P : string;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txPayee_Number     := 99;       //unknown

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 62, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');
    CheckForImportNoteLine( 'Unknown Payee', pT_BK5.txECoding_Import_Notes);

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        //expect that the gst set using the chart code because payee is differnt
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '402', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( Round( 7000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckForImportNoteLine( 'GST Amount  0.00', pD_BK5.dsECoding_Import_Notes);

     //    e[ test number, dissection line no] = Expected result
     P := '';

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := P;
     e[4,2]  := P;
     e[5,1]  := P;
     e[5,2]  := P;
     e[6,1]  := P;
     e[6,2]  := P;
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := 'L1 NOTE';
     e[7,2]  := 'L2 NOTE';
     e[8,1]  := 'L1 NOTE';
     e[8,2]  := 'L2 NOTE';
     e[9,1]  := 'L1 NOTE';
     e[9,2]  := 'L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 62, '6b');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6c_SingleDissectedPayee;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TDissectedResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 63, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( 4, pD_BK5.dsPayee_Number, 'L2 Payee');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '402', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( 0, pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckEquals( 4, pD_BK5.dsPayee_Number, 'L2 Payee');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

     //    e[ test number, dissection line no] = Expected result

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := 'P4 Line 1';
     e[4,2]  := 'P4 Line 2';
     e[5,1]  := 'P4 Line 1';
     e[5,2]  := 'P4 Line 2';
     e[6,1]  := 'P4 Line 1';
     e[6,2]  := 'P4 Line 2';
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := 'P4 Line 1 : L1 NOTE';
     e[7,2]  := 'P4 Line 2 : L2 NOTE';
     e[8,1]  := 'P4 Line 1 : L1 NOTE';
     e[8,2]  := 'P4 Line 2 : L2 NOTE';
     e[9,1]  := 'P4 Line 1 : L1 NOTE';
     e[9,2]  := 'P4 Line 2 : L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 63, '6c');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;


procedure TWebXTransactionImportTests.TestCase6c_NarrationAtTrxLevel;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    e[0]  := '';
    //fill with notes bk5 gl narration existing   dont overwrite, append, replace
    e[1]  := 'NOTE';
    e[2]  := 'NOTE';
    e[3]  := 'NOTE';
    //fill with payee bk5 gl narration existing   dont overwrite, append, replace
    e[4]  := '';
    e[5]  := '';
    e[6]  := '';
    //fill with payee + notes bk5 gl narration existing   dont overwrite, append, replace
    e[7]  := 'NOTE';
    e[8]  := 'NOTE';
    e[9]  := 'NOTE';

    CheckTransactionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 63, '6c');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6c_NarrationAtTrxLevel_ExistingNarration;
var
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  try
    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    e[0]  := 'BK5';
    //fill with notes bk5 gl narration existing   dont overwrite, append, replace
    e[1]  := 'BK5';
    e[2]  := 'BK5 : NOTE';
    e[3]  := 'NOTE';
    //fill with payee bk5 gl narration existing   dont overwrite, append, replace
    e[4]  := 'BK5';
    e[5]  := 'BK5';
    e[6]  := 'BK5';
    //fill with payee + notes bk5 gl narration existing   dont overwrite, append, replace
    e[7]  := 'BK5';
    e[8]  := 'BK5 : NOTE';
    e[9]  := 'NOTE';

    CheckTransactionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_WithNarration, 63, '6c');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6c_NotesSet;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'CODEIT NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsNotes      := 'L1 NOTE';
        pD_BK5.dsPayee_Number     := 2;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '401';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsNotes      := 'L2 NOTE';
        pD_BK5.dsPayee_Number     := 2;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 63, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 'CODEIT NOTE', pT_BK5.txNotes, 'T Note');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 Note');

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 Note');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6c_PayeeCodeMismatch;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TDissectedResultSet;
  P : string;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '401';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 63, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( 4, pD_BK5.dsPayee_Number, 'L2 Payee');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '401', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( Round(7000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckEquals( 4, pD_BK5.dsPayee_Number, 'L2 Payee');
        CheckForImportNoteLine('GST Amount  0.00', pD_BK5.dsECoding_Import_Notes);  //overriden

     //    e[ test number, dissection line no] = Expected result
     P := Payee4.pdName;

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := P;
     e[4,2]  := P;
     e[5,1]  := P;
     e[5,2]  := P;
     e[6,1]  := P;
     e[6,2]  := P;
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := P + ' : L1 NOTE';
     e[7,2]  := P + ' : L2 NOTE';
     e[8,1]  := P + ' : L1 NOTE';
     e[8,2]  := P + ' : L2 NOTE';
     e[9,1]  := P + ' : L1 NOTE';
     e[9,2]  := P + ' : L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 63, '6c');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6c_QuantitySet;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txQuantity := 1;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'CODEIT NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := 1000;
        pD_BK5.dsQuantity := 1234;
        pD_BK5.dsPayee_Number := 1;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount := 2000;
        pD_BK5.dsQuantity := -5678;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := -3000;
        pD_BK5.dsQuantity := 2345;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount :=  -4000;
        pD_BK5.dsQuantity := -3456;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 63, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 1, pT_BK5.txQuantity, 'txQuantity unchanged');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( 1234, pD_BK5.dsquantity, 'L1 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( 5678, pD_BK5.dsquantity, 'L2 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( -2345, pD_BK5.dsquantity, 'L3 Quantity');
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( -3456, pD_BK5.dsquantity, 'L4 Quantity');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6c_StandardPayeeAndManualLines;
//first line is non dissected payee + 1 manually added line
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TDissectedResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        pD_BK5.dsPayee_Number := 1;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 63, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( 1, pD_Bk5.dsPayee_Number, 'L1 Payee');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '402', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( Round(7000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckEquals( 0, pD_Bk5.dsPayee_Number, 'L2 Payee');
        CheckForImportNoteLine('GST Amount  0.00', pD_BK5.dsECoding_Import_Notes);

     //    e[ test number, dissection line no] = Expected result

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := 'P1 Line 1';
     e[4,2]  := '';
     e[5,1]  := 'P1 Line 1';
     e[5,2]  := '';
     e[6,1]  := 'P1 Line 1';
     e[6,2]  := '';
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := 'P1 Line 1 : L1 NOTE';
     e[7,2]  := 'L2 NOTE';
     e[8,1]  := 'P1 Line 1 : L1 NOTE';
     e[8,2]  := 'L2 NOTE';
     e[9,1]  := 'P1 Line 1 : L1 NOTE';
     e[9,2]  := 'L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 63, '6c');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6c_UnknownPayee;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TDissectedResultSet;
  P : string;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        pD_BK5.dsPayee_Number := 99;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        pD_BK5.dsPayee_Number := 99;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);
    CheckEquals( 63, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( 0, pD_BK5.dsPayee_Number, 'L1 Payee');
        CheckForImportNoteLine( 'Unknown Payee', pD_BK5.dsECoding_Import_Notes);

        //expect that the gst set using the chart code because payee is differnt
        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '402', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( Round( 7000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckEquals( 0, pD_BK5.dsPayee_Number, 'L2 Payee');
        CheckForImportNoteLine( 'GST Amount  0.00', pD_BK5.dsECoding_Import_Notes);
        CheckForImportNoteLine( 'Unknown Payee', pD_BK5.dsECoding_Import_Notes);

     //    e[ test number, dissection line no] = Expected result
     P := '';

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := P;
     e[4,2]  := P;
     e[5,1]  := P;
     e[5,2]  := P;
     e[6,1]  := P;
     e[6,2]  := P;
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := 'L1 NOTE';
     e[7,2]  := 'L2 NOTE';
     e[8,1]  := 'L1 NOTE';
     e[8,2]  := 'L2 NOTE';
     e[9,1]  := 'L1 NOTE';
     e[9,2]  := 'L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 63, '6c');
  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;


procedure TWebXTransactionImportTests.TestCase6c_TaxInvoice;
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_CodeIT : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;
    pT_BK5.txNotes  := 'NOTE';
    pT_BK5.txTax_Invoice_Available := false;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'CODEIT NOTE';
    pT_CodeIT.txTax_Invoice_Available := true;

        pD_CodeIT := bkdsio.New_Dissection_Rec;
        pD_CodeIT^.dsAccount := '230';
        pD_CodeIT^.dsAmount  := 7000;
        pD_CodeIT.dsGST_Class := Chart230.chGST_Class;
        pD_CodeIT.dsGST_Amount := Round( 7000/9);
        pD_CodeIT.dsNotes      := 'L1 NOTE';
        pD_CodeIT.dsPayee_Number := 2;

        trxlist32.AppendDissection( pT_CodeIT, pD_CodeIT);

        pD_CodeIT := bkdsio.New_Dissection_Rec;
        pD_CodeIT^.dsAccount := '400';
        pD_CodeIT^.dsAmount  := 3000;
        pD_CodeIT.dsGST_Class := Chart400.chGST_Class;
        pD_CodeIT.dsGST_Amount := Round( 3000 / 9);
        pD_CodeIT.dsNotes      := 'L2 NOTE';
        trxlist32.AppendDissection( pT_CodeIT, pD_CodeIT);

    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 63, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( true, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6_PayeeSetAtTrxAndDissectLevels;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'NOTE';
    pT_CodeIT.txPayee_Number     := 2;

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);

    //payee information within the dissection will be ignored, only use
    //payee info on trx

    CheckEquals( 62, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 2, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 2, pT_BK5.txPayee_Number, 'txPayee');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( 0, pD_BK5.dsPayee_Number, 'L2 Payee');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '402', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( Round(7000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckEquals( 0, pD_BK5.dsPayee_Number, 'L2 Payee');
        CheckForImportNoteLine('GST Amount  0.00', pD_BK5.dsECoding_Import_Notes);

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

procedure TWebXTransactionImportTests.TestCase6c_MultipleDissectedPayee;
var
  pT_CodeIT : pTransaction_Rec;
  pT_BK5 : pTRansaction_Rec;
  pD_BK5 : pDissection_Rec;
  E : TDissectedResultSet;
begin
  //create a codeIT transaction
  pT_CodeIT := bktxio.New_Transaction_Rec;
  pT_BK5 := bktxio.New_Transaction_Rec;
  try
    pT_BK5^.txDate_Presented  := Apr01_2004;
    pT_BK5^.txDate_Effective  := Apr01_2004;
    pT_BK5^.txECoding_Transaction_UID      := 1;
    pT_BK5.txAmount := 10000;

    pT_CodeIT^.txDate_Presented  := Apr01_2004;
    pT_CodeIT^.txDate_Effective  := Apr01_2004;
    pT_CodeIT^.txECoding_Transaction_UID      := 1;
    pT_CodeIT.txAmount           := 10000;
    pT_CodeIT.txNotes            := 'NOTE';

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'L1 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '402';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 3;
        pD_BK5.dsGST_Amount := 0;
        pD_BK5.dsGST_Has_Been_Edited := true;
        pD_BK5.dsNotes := 'L2 NOTE';
        pD_BK5.dsPayee_Number := 4;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5^.dsAmount  := 3000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round( 3000/9);
        pD_BK5.dsNotes := 'P2 L1 NOTE';
        pD_BK5.dsPayee_Number := 2;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '401';
        pD_BK5^.dsAmount  := 7000;
        pD_BK5.dsGST_Class := 2;
        pD_BK5.dsGST_Amount := Round(7000/9);
        pD_BK5.dsNotes := 'P2 L2 NOTE';
        pD_BK5.dsPayee_Number := 2;

        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    WebXUtils.ImportDissectedTransaction( pT_CodeIt, pT_BK5, BK5TestClient);

    CheckEquals( 63, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 4, CountOfDissectionLines( pT_BK5), 'Line Count');
    CheckEquals( 10000, pT_BK5.txAmount, 'Amount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'Dissect Tag');
    CheckEquals( '', pT_BK5.txECoding_Import_Notes);
    CheckEquals( 0, Integer(pT_BK5.txGST_Class), 'txGST_Class');
    CheckEquals( 0, pT_BK5.txGST_Amount, 'txGST_Amount');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');

        pD_BK5 := pT_BK5.txFirst_Dissection;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'L1 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '402', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( 0, pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '400', pD_BK5.dsAccount, 'L1 Account');
        CheckEquals( 3000, pD_BK5.dsAmount, 'L1 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 GST_Class');
        CheckEquals( Round( 3000/9), pD_bk5.dsGST_Amount, 'P2 L1 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

        pD_BK5 := pD_BK5.dsNext;
        CheckEquals( '401', pD_BK5.dsAccount, 'L2 Account');
        CheckEquals( 7000, pD_BK5.dsAmount, 'L2 Amount');
        CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L2 GST_Class');  //override
        CheckEquals( Round( 7000/9), pD_bk5.dsGST_Amount, 'L2 GST_Amount');
        CheckEquals( '', pD_BK5.dsECoding_Import_Notes);

     //    e[ test number, dissection line no] = Expected result

     //dont fill
     e[0,1]  := '';
     e[0,2]  := '';
     //fill with notes bk5   dont overwrite, append, replace
     e[1,1]  := 'L1 NOTE';
     e[1,2]  := 'L2 NOTE';
     e[1,3]  := 'P2 L1 NOTE';
     e[1,4]  := 'P2 L2 NOTE';
     e[2,1]  := 'L1 NOTE';
     e[2,2]  := 'L2 NOTE';
     e[2,3]  := 'P2 L1 NOTE';
     e[2,4]  := 'P2 L2 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     e[3,3]  := 'P2 L1 NOTE';
     e[3,4]  := 'P2 L2 NOTE';
     //fill with payee bk5   dont overwrite, append, replace
     e[4,1]  := 'P4 Line 1';
     e[4,2]  := 'P4 Line 2';
     e[4,3]  := 'P2 Line 1';
     e[4,4]  := 'P2 Line 2';
     e[5,1]  := 'P4 Line 1';
     e[5,2]  := 'P4 Line 2';
     e[5,3]  := 'P2 Line 1';
     e[5,4]  := 'P2 Line 2';
     e[6,1]  := 'P4 Line 1';
     e[6,2]  := 'P4 Line 2';
     e[6,3]  := 'P2 Line 1';
     e[6,4]  := 'P2 Line 2';
     //fill with payee + notes   dont overwrite, append, replace
     e[7,1]  := 'P4 Line 1 : L1 NOTE';
     e[7,2]  := 'P4 Line 2 : L2 NOTE';
     e[7,3]  := 'P2 Line 1 : P2 L1 NOTE';
     e[7,4]  := 'P2 Line 2 : P2 L2 NOTE';
     e[8,1]  := 'P4 Line 1 : L1 NOTE';
     e[8,2]  := 'P4 Line 2 : L2 NOTE';
     e[8,3]  := 'P2 Line 1 : P2 L1 NOTE';
     e[8,4]  := 'P2 Line 2 : P2 L2 NOTE';
     e[9,1]  := 'P4 Line 1 : L1 NOTE';
     e[9,2]  := 'P4 Line 2 : L2 NOTE';
     e[9,3]  := 'P2 Line 1 : P2 L1 NOTE';
     e[9,4]  := 'P2 Line 2 : P2 L2 NOTE';

     CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case6_NoNarration, 63, '6c');

  finally
    trxList32.Dispose_Transaction_Rec( pT_CodeIt);
    trxList32.Dispose_Transaction_Rec( pT_BK5);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_UnchangedBasic;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//basic transaction, no payees involved, expected fields to be unchanged
//dont expect a note to be added
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_Basic( pT_BK5);
    RecreateBK5Transaction_Case5_Basic( pT_CodeIT);

    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');

    CheckEquals( 15000, pT_BK5.txAmount, 'txAmount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'txAccount');
    CheckEquals( 'NOTE', pT_BK5.txNotes, 'txNotes');
    CheckEquals( 'GL NARRATION', pT_BK5.txGL_Narration,'txGL Narration');
    CheckEquals( false, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');
    CheckEquals( '', pT_BK5.txEcoding_Import_Notes, 'txImportNote');

    pD_BK5 := pT_BK5.txFirst_Dissection;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L1 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L1 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L1 dsGSTAmount');
      CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 dsNote');
      CheckEquals( 'L1 GLNARR', pD_BK5.dsGL_Narration, 'L1 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L1 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L1 dsImportNote');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '401', pD_BK5^.dsAccount, 'L2 dsAccount');
      CheckEquals( 9000, pD_BK5.dsAmount, 'L2 dsAmount');
      CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 dsGSTClass');
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L2 dsGSTAmount');
      CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 dsNote');
      CheckEquals( 'L2 GLNARR', pD_BK5.dsGL_Narration, 'L2 dsGLNarration');
      CheckEquals( True, pD_BK5.dsGST_Has_Been_Edited, 'L2 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L2 dsImportNote');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_TaxInvoice;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//everthing the same expect the tax invoice setting, expect to be applied at
//transaction level
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_Basic( pT_BK5);
    RecreateBK5Transaction_Case5_Basic( pT_CodeIT);                   
    pT_BK5.txTax_Invoice_Available := false;
    pT_CodeIT.txTax_Invoice_Available := true;

    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( true, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.RecreateBK5Transaction_Case5_Basic(
  var pT: pTransaction_Rec);
//case 5 transaction, used to create basic dissected transaction
var
  pD : pDissection_Rec;
begin
  if Assigned( pT) then
    trxList32.Dispose_Transaction_Rec( pT);
  pT := bktxio.New_Transaction_Rec;

  pT^.txDate_Presented  := Apr01_2004;
  pT.txDate_Effective   := Apr01_2004;
  pT.txAmount           := 15000;
  pT.txAccount          := 'DISSECTED';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := 'GL NARRATION';
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 0;

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '400';
    pD.dsAmount           := 6000;
    pD.dsGST_Class        := 2;
    pD.dsGST_Amount       := Round(6000/9);
    pD.dsNotes            := 'L1 NOTE';
    pD.dsGL_Narration     := 'L1 GLNARR';
    AppendDissection( pT, pD);

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '401';
    pD.dsAmount           := 9000;
    pD.dsGST_Class        := 3;
    pD.dsGST_Amount       := 0;
    pD.dsGST_Has_Been_Edited := True;
    pD.dsNotes            := 'L2 NOTE';
    pD.dsGL_Narration     := 'L2 GLNARR';
    AppendDissection( pT, pD);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.RecreateBK5Transaction_Case5_DissectedByPayee(
  var pT: pTransaction_Rec);
//create a transaction coded by a dissected payee at the transaction level
var
  pD : pDissection_Rec;
begin
  if Assigned( pT) then
    trxList32.Dispose_Transaction_Rec( pT);
  pT := bktxio.New_Transaction_Rec;

  pT^.txDate_Presented  := Apr01_2004;
  pT.txDate_Effective   := Apr01_2004;
  pT.txAmount           := 15000;
  pT.txAccount          := 'DISSECTED';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := Payee4.pdName;
  pT.txTax_Invoice_Available   := false;
  pT.txPayee_Number     := 4;

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '400';
    pD.dsAmount           := 6000;
    pD.dsGST_Class        := 2;
    pD.dsGST_Amount       := Round(6000/9);
    pD.dsNotes            := 'L1 NOTE';
    pD.dsGL_Narration     := 'P4 Line 1';
    AppendDissection( pT, pD);

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '402';
    pD.dsAmount           := 9000;
    pD.dsGST_Class        := 3;
    pD.dsGST_Amount       := 0;
    pD.dsGST_Has_Been_Edited := True;
    pD.dsNotes            := 'L2 NOTE';
    pD.dsGL_Narration     := 'P4 Line 2';
    AppendDissection( pT, pD);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.RecreateBK5Transaction_Case5_DissectedWithInternalPayees(
  var pT: pTransaction_Rec);
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
var
  pD : pDissection_Rec;
begin
  if Assigned( pT) then
    trxList32.Dispose_Transaction_Rec( pT);
  pT := bktxio.New_Transaction_Rec;

  pT^.txDate_Presented  := Apr01_2004;
  pT.txDate_Effective   := Apr01_2004;
  pT.txAmount           := 15000;
  pT.txAccount          := 'DISSECTED';
  pT.txNotes            := 'NOTE';
  pT.txGL_Narration     := '';
  pT.txTax_Invoice_Available   := false;

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '400';
    pD.dsAmount           := 6000;
    pD.dsGST_Class        := 2;
    pD.dsGST_Amount       := Round(6000/9);
    pD.dsNotes            := 'L1 NOTE';
    pD.dsGL_Narration     := 'P4 Line 1';
    pD.dsPayee_Number     := 4;
    AppendDissection( pT, pD);

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '402';
    pD.dsAmount           := 9000;
    pD.dsGST_Class        := 3;
    pD.dsGST_Amount       := 0;
    pD.dsGST_Has_Been_Edited := True;
    pD.dsNotes            := 'L2 NOTE';
    pD.dsGL_Narration     := 'P4 Line 2';
    pD.dsPayee_Number     := 4;
    AppendDissection( pT, pD);

    pD := bkdsio.New_Dissection_Rec;
    pD^.dsAccount         := '400';
    pD.dsAmount           := 6000;
    pD.dsGST_Class        := 2;
    pD.dsGST_Amount       := Round(6000/9);
    pD.dsNotes            := 'L3 NOTE';
    pD.dsGL_Narration     := 'P1 Line 1';
    pD.dsPayee_Number     := 1;
    AppendDissection( pT, pD);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_TransactionNotesChanged;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//check that bk5 notes are replaced with codeIt notes
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_Basic( pT_BK5);
    RecreateBK5Transaction_Case5_Basic( pT_CodeIT);
    pT_CodeIT.txNotes := 'CodeIT Note';

    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');
    CheckEquals( 'CodeIT Note', pT_BK5.txNotes, 'txNotes');
    CheckEquals( '', pT_BK5.txEcoding_Import_Notes, 'txImportNote');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_TransactionPayeeChanged;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//changed the payee a transaction level, expect payee to stay the same and for
//a note to be added
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_DissectedByPayee( pT_BK5);
    RecreateBK5Transaction_Case5_DissectedByPayee( pT_CodeIT);
    pT_CodeIT.txPayee_Number := 1;

    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');

    CheckEquals( 15000, pT_BK5.txAmount, 'txAmount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'txAccount');
    CheckEquals( 'NOTE', pT_BK5.txNotes, 'txNotes');
    CheckEquals( Payee4.pdName, pT_BK5.txGL_Narration,'txGL Narration');
    CheckEquals( 4, pT_BK5.txPayee_Number, 'txPayee'); //dont expect this to change
    CheckForImportNoteLine( 'Payee', pT_BK5.txECoding_Import_Notes);

    pD_BK5 := pT_BK5.txFirst_Dissection;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L1 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L1 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L1 dsGSTAmount');
      CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 dsNote');
      CheckEquals( 'P4 Line 1', pD_BK5.dsGL_Narration, 'L1 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L1 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L1 dsImportNote');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '402', pD_BK5^.dsAccount, 'L2 dsAccount');
      CheckEquals( 9000, pD_BK5.dsAmount, 'L2 dsAmount');
      CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 dsGSTClass');
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L2 dsGSTAmount');
      CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 dsNote');
      CheckEquals( 'P4 Line 2', pD_BK5.dsGL_Narration, 'L2 dsGLNarration');
      CheckEquals( True, pD_BK5.dsGST_Has_Been_Edited, 'L2 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L2 dsImportNote');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_TransactionPayeeSet;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//transaction level payee was 0 now 2, expect nothing to change but
//import note to report payee attempt
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_Basic( pT_BK5);
    RecreateBK5Transaction_Case5_Basic( pT_CodeIT);
    pT_CodeIT.txPayee_Number := 1;

    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');

    CheckEquals( 15000, pT_BK5.txAmount, 'txAmount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'txAccount');
    CheckEquals( 'NOTE', pT_BK5.txNotes, 'txNotes');
    CheckEquals( 'GL NARRATION', pT_BK5.txGL_Narration,'txGL Narration');
    CheckEquals( false, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');
    CheckForImportNoteLine( 'Payee', pT_BK5.txECoding_Import_Notes);

    pD_BK5 := pT_BK5.txFirst_Dissection;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L1 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L1 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L1 dsGSTAmount');
      CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 dsNote');
      CheckEquals( 'L1 GLNARR', pD_BK5.dsGL_Narration, 'L1 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L1 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L1 dsImportNote');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '401', pD_BK5^.dsAccount, 'L2 dsAccount');
      CheckEquals( 9000, pD_BK5.dsAmount, 'L2 dsAmount');
      CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 dsGSTClass');
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L2 dsGSTAmount');
      CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 dsNote');
      CheckEquals( 'L2 GLNARR', pD_BK5.dsGL_Narration, 'L2 dsGLNarration');
      CheckEquals( True, pD_BK5.dsGST_Has_Been_Edited, 'L2 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L2 dsImportNote');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_TransactionNarration;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//check that the narration will be set correctly for a transaction that
//has been dissected by a payee at transaction level
var
  pT_CodeIT : pTransaction_Rec;
  E : TResultSet;
begin
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_DissectedByPayee( pT_CodeIT);
    pT_CodeIT.txNotes := 'CodeItNote';

     e[0]  := Payee4.pdName;                //dont fill
     //fill with notes bk5 gl narration 'note'   dont overwrite, append, replace
     e[1]  := Payee4.pdName;
     e[2]  := Payee4.pdName + ' : CodeItNote';
     e[3]  := 'CodeItNote';
     //fill with payee bk5 gl narration = 'note'    dont overwrite, append, replace
     e[4]  := Payee4.pdName;
     e[5]  := Payee4.pdName;  //is dissected payee so import should leave narr the same at trx level
     e[6]  := Payee4.pdName;
     //fill with payee + notes bk5 gl narration = 'note'    dont overwrite, append, replace
     e[7]  := Payee4.pdName;
     e[8]  := Payee4.pdName + ' : CodeItNote';
     e[9]  := 'CodeItNote';

    CheckTransactionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case5_DissectedByPayee, 5, '5');
  finally
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_DissectionGSTChanged;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//gst amount changed within a dissection line
//expect an import note to be created but everything else stay the same
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_Basic( pT_BK5);
      pD_BK5 := bkdsio.New_Dissection_Rec;
      pD_BK5^.dsAccount := '';
      pD_BK5.dsAmount := 6000;
      pD_BK5.dsQuantity := 0;
      trxlist32.AppendDissection( pT_BK5, pD_BK5);

    RecreateBK5Transaction_Case5_Basic( pT_CodeIT);
      pD_BK5 := pT_CodeIT.txFirst_Dissection;
      pD_BK5.dsGST_Has_Been_Edited := true;
      pD_BK5.dsGST_Amount := 100;

      pD_BK5 := bkdsio.New_Dissection_Rec;
      pD_BK5^.dsAccount := '';
      pD_BK5.dsAmount := 6000;
      pD_BK5.dsQuantity := 0;
      pD_BK5.dsGST_Has_Been_Edited := true;
      pD_BK5.dsGST_Amount := 200;
      trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');

    CheckEquals( 15000, pT_BK5.txAmount, 'txAmount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'txAccount');
    CheckEquals( 'NOTE', pT_BK5.txNotes, 'txNotes');
    CheckEquals( 'GL NARRATION', pT_BK5.txGL_Narration,'txGL Narration');
    CheckEquals( false, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');
    CheckEquals( '', pT_BK5.txEcoding_Import_Notes, 'txImportNote');

    pD_BK5 := pT_BK5.txFirst_Dissection;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L1 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L1 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L1 dsGSTAmount');
      CheckForImportNoteLine( 'GST Amount  1.00', pD_Bk5.dsECoding_Import_Notes);
      CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 dsNote');
      CheckEquals( 'L1 GLNARR', pD_BK5.dsGL_Narration, 'L1 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L1 dsGSTEdited');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '401', pD_BK5^.dsAccount, 'L2 dsAccount');
      CheckEquals( 9000, pD_BK5.dsAmount, 'L2 dsAmount');
      CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 dsGSTClass');
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L2 dsGSTAmount');
      CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 dsNote');
      CheckEquals( 'L2 GLNARR', pD_BK5.dsGL_Narration, 'L2 dsGLNarration');
      CheckEquals( True, pD_BK5.dsGST_Has_Been_Edited, 'L2 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L2 dsImportNote');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L3 dsGSTAmount');
      CheckForImportNoteLine( 'GST Amount  2.00', pD_Bk5.dsECoding_Import_Notes);
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_DissectionNarration;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//dissected transaction with multiple payees within dissection
//check narration set correctly
var
  pT_CodeIT : pTransaction_Rec;
  E : TDissectedResultSet;
begin
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_DissectedWithInternalPayees( pT_CodeIT);
    pT_CodeIT.txNotes := 'CodeItNote';

     e[0,1]  := 'P4 Line 1';
     e[0,2]  := 'P4 Line 2';
     e[0,3]  := 'P1 Line 1';
     //fill with notes    dont overwrite, append, replace
     e[1,1]  := 'P4 Line 1';
     e[1,2]  := 'P4 Line 2';
     e[1,3]  := 'P1 Line 1';
     e[2,1]  := 'P4 Line 1 : L1 NOTE';
     e[2,2]  := 'P4 Line 2 : L2 NOTE';
     e[2,3]  := 'P1 Line 1 : L3 NOTE';
     e[3,1]  := 'L1 NOTE';
     e[3,2]  := 'L2 NOTE';
     e[3,3]  := 'L3 NOTE';
     //fill with payee    dont overwrite, append, replace
     e[4,1]  := 'P4 Line 1';
     e[4,2]  := 'P4 Line 2';
     e[4,3]  := 'P1 Line 1';
     e[5,1]  := 'P4 Line 1 : P4 Line 1';
     e[5,2]  := 'P4 Line 2 : P4 Line 2';
     e[5,3]  := 'P1 Line 1 : P1 Line 1';
     e[6,1]  := 'P4 Line 1';
     e[6,2]  := 'P4 Line 2';
     e[6,3]  := 'P1 Line 1';
     //fill with payee + notes  dont overwrite, append, replace
     e[7,1]  := 'P4 Line 1';
     e[7,2]  := 'P4 Line 2';
     e[7,3]  := 'P1 Line 1';
     e[8,1]  := 'P4 Line 1 : P4 Line 1 : L1 NOTE';
     e[8,2]  := 'P4 Line 2 : P4 Line 2 : L2 NOTE';
     e[8,3]  := 'P1 Line 1 : P1 Line 1 : L3 NOTE';
     e[9,1]  := 'P4 Line 1 : L1 NOTE';
     e[9,2]  := 'P4 Line 2 : L2 NOTE';
     e[9,3]  := 'P1 Line 1 : L3 NOTE';

    CheckDissectionLevelNarration( E, pT_CodeIT, RecreateBK5Transaction_Case5_DissectedWithInternalPayees, 5, '5');
  finally
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_DissectionQuantity;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//quantity changed on 4 lines, set on 1 line
//expect quantity to be updated in bk5 transaction for each line
//expect quantity sign to be corrected
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_Basic( pT_BK5);
    pT_BK5^.txQuantity := 1;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := 1000;
        pD_BK5.dsQuantity := 0;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount := 6000;
        pD_BK5.dsQuantity := 0;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := -3000;
        pD_BK5.dsQuantity := 0;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount :=  -1000;
        pD_BK5.dsQuantity := 0;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount :=  -3000;
        pD_BK5.dsQuantity := -1000;
        trxlist32.AppendDissection( pT_BK5, pD_BK5);

    RecreateBK5Transaction_Case5_Basic( pT_CodeIT);
    pT_CodeIT^.txQuantity := 2;
        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := 1000;
        pD_BK5.dsQuantity := 1234;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount := 6000;
        pD_BK5.dsQuantity := -5678;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount   := -3000;
        pD_BK5.dsQuantity := 2345;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount :=  -1000;
        pD_BK5.dsQuantity := -3456;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

        pD_BK5 := bkdsio.New_Dissection_Rec;
        pD_BK5^.dsAccount := '400';
        pD_BK5.dsAmount :=  -3000;
        pD_BK5.dsQuantity := -2000;
        trxlist32.AppendDissection( pT_CodeIT, pD_BK5);

    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');

    CheckEquals( 15000, pT_BK5.txAmount, 'txAmount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'txAccount');
    CheckEquals( 'NOTE', pT_BK5.txNotes, 'txNotes');
    CheckEquals( 'GL NARRATION', pT_BK5.txGL_Narration,'txGL Narration');
    CheckEquals( false, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');
    CheckEquals( '', pT_BK5.txEcoding_Import_Notes, 'txImportNote');


    CheckEquals( 1, pT_BK5.txQuantity, 'txQuantity unchanged');

    pD_BK5 := pT_BK5.txFirst_Dissection;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L1 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L1 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L1 dsGSTAmount');
      CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 dsNote');
      CheckEquals( 'L1 GLNARR', pD_BK5.dsGL_Narration, 'L1 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L1 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L1 dsImportNote');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '401', pD_BK5^.dsAccount, 'L2 dsAccount');
      CheckEquals( 9000, pD_BK5.dsAmount, 'L2 dsAmount');
      CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 dsGSTClass');
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L2 dsGSTAmount');
      CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 dsNote');
      CheckEquals( 'L2 GLNARR', pD_BK5.dsGL_Narration, 'L2 dsGLNarration');
      CheckEquals( True, pD_BK5.dsGST_Has_Been_Edited, 'L2 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L2 dsImportNote');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( 1234, pD_BK5.dsquantity, 'L3 Quantity');
    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( 5678, pD_BK5.dsquantity, 'L4 Quantity');
    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( -2345, pD_BK5.dsquantity, 'L5 Quantity');
    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( -3456, pD_BK5.dsquantity, 'L6 Quantity');
    pD_BK5 := pD_BK5.dsNext;
      CheckForImportNoteLine('Quantity', pD_BK5.dsECoding_Import_Notes);
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_Notes;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//check that the bk5 notes will be replace for each line in the codeIt dissection
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_BK5 : pDissection_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_Basic( pT_BK5);
    RecreateBK5Transaction_Case5_Basic( pT_CodeIT);
      pD_BK5 := pT_CodeIT.txFirst_Dissection;
      pD_BK5.dsNotes := 'CodeNoteL1';
      pD_BK5 := pD_BK5.dsNext;
      pD_BK5.dsNotes := 'CodeNoteL2';

    BK5TestClient.clFields.clECoding_Import_Options := noDontFill;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');

    CheckEquals( 15000, pT_BK5.txAmount, 'txAmount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'txAccount');
    CheckEquals( 'NOTE', pT_BK5.txNotes, 'txNotes');
    CheckEquals( 'GL NARRATION', pT_BK5.txGL_Narration,'txGL Narration');
    CheckEquals( false, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');
    CheckEquals( '', pT_BK5.txEcoding_Import_Notes, 'txImportNote');

    pD_BK5 := pT_BK5.txFirst_Dissection;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L1 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L1 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L1 dsGSTAmount');
      CheckEquals( 'CodeNoteL1', pD_BK5.dsNotes, 'L1 dsNote');
      CheckEquals( 'L1 GLNARR', pD_BK5.dsGL_Narration, 'L1 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L1 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L1 dsImportNote');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '401', pD_BK5^.dsAccount, 'L2 dsAccount');
      CheckEquals( 9000, pD_BK5.dsAmount, 'L2 dsAmount');
      CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 dsGSTClass');
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L2 dsGSTAmount');
      CheckEquals( 'CodeNoteL2', pD_BK5.dsNotes, 'L2 dsNote');
      CheckEquals( 'L2 GLNARR', pD_BK5.dsGL_Narration, 'L2 dsGLNarration');
      CheckEquals( True, pD_BK5.dsGST_Has_Been_Edited, 'L2 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L2 dsImportNote');
  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_PayeeChangedOnDissectLine;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//dont expect payee on dissect line to change, note should be added
//narration should be unchanged
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_CodeIT, pD_BK5 : pDissection_Rec;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_DissectedWithInternalPayees( pT_BK5);
    RecreateBK5Transaction_Case5_DissectedWithInternalPayees( pT_CodeIT);
    pD_CodeIT := pT_CodeIT.txFirst_Dissection;
    pD_CodeIT.dsPayee_Number := 1;

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');

    CheckEquals( 15000, pT_BK5.txAmount, 'txAmount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'txAccount');
    CheckEquals( 'NOTE', pT_BK5.txNotes, 'txNotes');
    CheckEquals( '', pT_BK5.txGL_Narration,'txGL Narration');
    CheckEquals( false, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');
    CheckEquals( '', pT_BK5.txEcoding_Import_Notes, 'txImportNote');

    pD_BK5 := pT_BK5.txFirst_Dissection;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L1 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L1 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L1 dsGSTAmount');
      CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 dsNote');
      CheckEquals( 'P4 Line 1', pD_BK5.dsGL_Narration, 'L1 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L1 dsGSTEdited');
      CheckEquals( 4, pD_BK5.dsPayee_Number, 'L1 Payee');
      CheckForImportNoteLine( 'Payee', pD_BK5.dsECoding_Import_Notes);

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '402', pD_BK5^.dsAccount, 'L2 dsAccount');
      CheckEquals( 9000, pD_BK5.dsAmount, 'L2 dsAmount');
      CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 dsGSTClass');
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L2 dsGSTAmount');
      CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 dsNote');
      CheckEquals( 'P4 Line 2', pD_BK5.dsGL_Narration, 'L2 dsGLNarration');
      CheckEquals( True, pD_BK5.dsGST_Has_Been_Edited, 'L2 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L2 dsImportNote');
      CheckEquals( 4, pD_BK5.dsPayee_Number, 'L2 Payee');

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L3 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L3 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L3 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L3 dsGSTAmount');
      CheckEquals( 'L3 NOTE', pD_BK5.dsNotes, 'L3 dsNote');
      CheckEquals( 'P1 Line 1', pD_BK5.dsGL_Narration, 'L3 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L3 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L3 dsImportNote');
      CheckEquals( 1, pD_BK5.dsPayee_Number, 'L3 Payee');

  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TWebXTransactionImportTests.TestCase5_PayeeSetOnDissectLine;
//case 5: CodeIT dissected, BK5 dissected, accounts and amounts match
//payee changed from 0 to value in CodeIT on a dissection line
//expect payee to remain as 0 as user is not able to edit the payee
//for a dissection line that is already coded
//expect import note
var
  pT_BK5 : pTransaction_Rec;
  pT_CodeIT : pTransaction_Rec;
  pD_CodeIT : pDissection_Rec;
  PD_BK5 : pDissection_REc;
begin
  pT_BK5 := nil;
  pT_CodeIT := nil;
  try
    RecreateBK5Transaction_Case5_Basic( pT_BK5);
    RecreateBK5Transaction_Case5_Basic( pT_CodeIT);
    pD_CodeIT := pT_CodeIT.txFirst_Dissection;
    pD_CodeIT.dsPayee_Number := 1;

    BK5TestClient.clFields.clECoding_Import_Options := noFillWithPayeeName;
    WebXUtils.ImportDissectedTransaction( pT_CodeIT, pT_BK5, BK5TestClient);

    CheckEquals( 5, pT_BK5.txTemp_Tag, 'Case');

    CheckEquals( 15000, pT_BK5.txAmount, 'txAmount');
    CheckEquals( 'DISSECTED', pT_BK5.txAccount, 'txAccount');
    CheckEquals( 'NOTE', pT_BK5.txNotes, 'txNotes');
    CheckEquals( 'GL NARRATION', pT_BK5.txGL_Narration,'txGL Narration');
    CheckEquals( false, pT_BK5.txTax_Invoice_Available, 'txTax Invoice');
    CheckEquals( 0, pT_BK5.txPayee_Number, 'txPayee');
    CheckEquals( '', pT_BK5.txEcoding_Import_Notes, 'txImportNote');

    pD_BK5 := pT_BK5.txFirst_Dissection;
      CheckEquals( '400', pD_BK5^.dsAccount, 'L1 dsAccount');
      CheckEquals( 6000, pD_BK5.dsAmount, 'L1 dsAmount');
      CheckEquals( 2, Integer(pD_BK5.dsGST_Class), 'L1 dsGSTClass');
      CheckEquals( Round(6000/9), pD_BK5.dsGST_Amount, 'L1 dsGSTAmount');
      CheckEquals( 'L1 NOTE', pD_BK5.dsNotes, 'L1 dsNote');
      CheckEquals( 'L1 GLNARR', pD_BK5.dsGL_Narration, 'L1 dsGLNarration');
      CheckEquals( False, pD_BK5.dsGST_Has_Been_Edited, 'L1 dsGSTEdited');
      CheckEquals( 0, pD_BK5.dsPayee_Number, 'L1 Payee');
      CheckForImportNoteLine( 'Payee', pD_BK5.dsECoding_Import_Notes);

    pD_BK5 := pD_BK5.dsNext;
      CheckEquals( '401', pD_BK5^.dsAccount, 'L2 dsAccount');
      CheckEquals( 9000, pD_BK5.dsAmount, 'L2 dsAmount');
      CheckEquals( 3, Integer(pD_BK5.dsGST_Class), 'L2 dsGSTClass');
      CheckEquals( 0, pD_BK5.dsGST_Amount, 'L2 dsGSTAmount');
      CheckEquals( 'L2 NOTE', pD_BK5.dsNotes, 'L2 dsNote');
      CheckEquals( 'L2 GLNARR', pD_BK5.dsGL_Narration, 'L2 dsGLNarration');
      CheckEquals( True, pD_BK5.dsGST_Has_Been_Edited, 'L2 dsGSTEdited');
      CheckEquals( '', pD_BK5.dsEcoding_Import_Notes, 'L2 dsImportNote');
      CheckEquals( 0, pD_BK5.dsPayee_Number, 'L2 Payee');

  finally
    Dispose_Transaction_Rec( pT_BK5);
    Dispose_Transaction_Rec( pT_CodeIT);
  end;
end;



initialization
  TestFramework.RegisterTest(TWebXImportTests.Suite);
  TestFramework.RegisterTest(TWebXTransactionImportTests.Suite);

end.




