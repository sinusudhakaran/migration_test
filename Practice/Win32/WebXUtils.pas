// Utilities for importing from WebXOffice
unit WebXUtils;

interface

uses Classes, clobj32, baobj32, baList32, bkdefs, MoneyDef;

function IsExportFile(const Filename: string): Boolean;

procedure ParseWDDXClientDetails(const Filename: string; var cCode: string;
  var cName: string; var cStartDate: string; var cEndDate: string; var cFileSequence: Integer);

procedure ParseWDDXTransactions(aClient: TClientObj; const Filename: string; var BAList: TBank_Account_List);

function ValidateTransactionForImport( ECT : pTransaction_Rec;
                                       T   : pTransaction_Rec;
                                       var aMsg : string) : boolean;

procedure RejectTransaction( aClient: TClientObj;
                             ECT : pTransaction_Rec;
                             Reason : string;
                             var RejectedLines : TStringList);

procedure ProcessECodingFile( BAList: TBank_Account_List; aClient : TClientObj; var ImportedCount, RejectedCount : integer);

function IsWDDXInstalled: Boolean;

function RegisterWDDXCOM: Boolean;

procedure ImportStandardTransaction( ECT : pTRansaction_Rec;
                                     BKT   : pTransaction_Rec;
                                     aClient : TClientObj;
                                     BankPrefix : string);

procedure ImportDissectedTransaction( ECT : pTRansaction_Rec;
                                      BKT   : pTransaction_Rec;
                                      aClient : TClientObj);

function IsWebFileWaiting: Boolean;

implementation

uses SysUtils, WDDX_COMLib_TLB, trxList32, bktxio, bkdsio, bkbaio, ECodingUtils,
  GenUtils, BKDateUtils, BKConst, stDate, glConst, PayeeObj, GSTCalc32,
  TransactionUtils, Globals, COMObj, WebXOffice, WinUtils, UTransactionCompare;

// Test to see if the file is an export file - if so we wont allow import
function IsExportFile(const Filename: string): Boolean;
var
  Packet: TStrings;
  WDDX: TWDDXDeserializer;
  V: OleVariant;
begin
  Packet := TStringList.Create;
  WDDX := TWDDXDeserializer.Create(nil);
  try
    try
      Packet.LoadFromFile(Filename);
      V := WDDX.Deserialize(Packet.Text);
      // This is a special var only used by BK5, its ignored by WebXOffice
      Result := V.getProp('EXPORTED');
    except
      Result := False;
    end;
  finally
    WDDX.Free;
    Packet.Free;
  end;
end;

// Read the client details - the user of this function is expected to check
// that the correct client and file sequence are being imported
// Filename must exist
procedure ParseWDDXClientDetails(const Filename: string; var cCode: string; var cName: string;
  var cStartDate: string; var cEndDate: string; var cFileSequence: Integer);
var
  Packet: TStrings;
  WDDX: TWDDXDeserializer;
  V: OleVariant;
begin
  Packet := TStringList.Create;
  WDDX := TWDDXDeserializer.Create(nil);
  try
      Packet.LoadFromFile(Filename);
      V := WDDX.Deserialize(Packet.Text);
      // Read client details
      cCode := V.getProp('CLIENT CODE');
      cName := V.getProp('CLIENT NAME');
      cStartDate := V.getProp('START DATE');
      cEndDate := V.getProp('END DATE');
      cFileSequence := V.getProp('FILE SEQUENCE');
  finally
    WDDX.Free;
    Packet.Free;
  end;
end;

// Read the transactions into a bank account list
procedure ParseWDDXTransactions(aClient: TClientObj; const Filename: string; var BAList: TBank_Account_List);
var
  Packet: TStrings;
  WDDX: TWDDXDeserializer;
  V, R: OleVariant;
  i, j, uid, line: Integer;
  BA, BAbk: TBank_Account;
  TR, TRbk: PTransaction_Rec;
  DR, DRbk: PDissection_Rec;
  MoneyVal: Double;
  Dissected: Boolean;
begin
  Packet := TStringList.Create;
  WDDX := TWDDXDeserializer.Create(nil);
  try
    Packet.LoadFromFile(Filename);
    V := WDDX.Deserialize(Packet.Text);
    // We need to build the transaction list from TRANSACTION INFO plus get the
    // extra info from the existing transaction in BK5
    R := V.getProp('TRANSACTION INFO');
    for i := 1 to StrToInt(R.getRowCount) do
    begin
      uid := R.getField(i, 'ACCOUNT_UID');
      BA := BAList.FindAccountFromECodingUID(uid);
      BAbk := aClient.clBank_Account_List.FindAccountFromECodingUID(uid);
      if not Assigned(BA) then
      begin
        // Add new bank account
        BA := TBank_Account.Create(aClient);
        BA.baTransaction_List := TTransaction_List.Create( aClient, BA, aClient.FClientAuditMgr );
        BA.baFields.baECoding_Account_UID := uid;
        BA.baFields.baRecord_Type := tkBegin_Bank_Account;
        BA.baFields.baEOR := tkEnd_Bank_Account;
        if Assigned(BAbk) then
          BA.baFields.baCurrency_Code := BAbk.baFields.baCurrency_Code
        else
          BA.baFields.baCurrency_Code := whCurrencyCodes[ aClient.clFields.clCountry ];
        BA.baFields.baBank_Account_Number := IntToStr( uid);
        BA.baFields.baDesktop_Super_Ledger_ID := -1;        
        BAList.Insert(BA);
      end;
      uid := R.getField(i, 'TRANSACTION_UID');
      // Now fill in txn info using the info from the WDDX file
      TR :=  BA.baTransaction_List.New_Transaction;
      TR.txECoding_Transaction_UID := uid;
      MoneyVal := R.getField(i, 'QUANTITY');
      TR.txQuantity := MoneyVal * 10000;
      TR.txPayee_Number := R.getField(i, 'PAYEE_NUMBER');
      TR.txNotes := R.getField(i, 'NOTES');
      TR.txTax_Invoice_Available := R.getField(i, 'TAX_INVOICE_AVAILABLE');
      // Now fill in txn info using the info from BK5
      // Make sure the transaction exists in BK5
      // If it doesnt we just include wots in the WDDX and Verify will reject it
      // If the account has gone from BK5 then it needs to be rejected
      // This will happen in the verify method
      if Assigned(BAbk) then
      begin
        TRbk := BAbk.baTransaction_List.FindTransactionFromECodingUID(uid);
        if Assigned(TRbk) then
        begin
          TR.txGST_Has_Been_Edited := TRbk.txGST_Has_Been_Edited;
          TR.txGL_Narration := TRbk.txGL_Narration;
          TR.txAccount := TRbk.txAccount;
          TR.txAmount := TRbk.txAmount;
          TR.txGST_Class := TRbk.txGST_Class;
          TR.txGST_Amount := TRbk.txGST_Amount;
          TR.txHas_Been_Edited := TRbk.txHas_Been_Edited;
          // And add existing BK5 dissections
          DRbk := TRbk.txFirst_Dissection;
          while DRbk <> nil do
          begin
            // add the dissection lines
            DR := bkdsio.New_Dissection_Rec;
            DR.dsAccount := DRbk.dsAccount;
            DR.dsAmount := DRbk.dsAmount;
            DR.dsGL_Narration := DRbk.dsGL_Narration;
            DR.dsGST_Amount := DRbk.dsGST_Amount;
            DR.dsGST_Class := DRbk.dsGST_Class;
            DR.dsGST_Has_Been_Edited := DRbk.dsGST_Has_Been_Edited;
            DR.dsHas_Been_Edited := DRbk.dsHas_Been_Edited;
            DR.dsNotes := DRbk.dsNotes;
            DR.dsPayee_Number := DRbk.dsPayee_Number;
            DR.dsQuantity := DRbk.dsQuantity;
            trxlist32.AppendDissection( TR, DR);
            DRbk := DRbk.dsNext;
          end;
        end;
      end;
      BA.baTransaction_List.Insert_Transaction_Rec(TR);
    end;

    // Read the transaction details and overwrite with changed data
    R := V.getProp('TRANSACTION DETAIL');
    for i := 1 to StrToInt(R.getRowCount) do
    begin
      uid := R.getField(i, 'ACCOUNT_UID');
      BA := BAList.FindAccountFromECodingUID(uid);
      uid := R.getField(i, 'TRANSACTION_UID');
      TR := BA.baTransaction_List.FindTransactionFromECodingUID(uid);
      line := R.getField(i, 'SEQUENCE_NUMBER');
      // Is it dissected?
      if i < R.getRowCount then
        Dissected :=  (R.getField(i + 1, 'TRANSACTION_UID') = uid) or
                      (TR.txFirst_Dissection <> nil)
      else
        Dissected := (TR.txFirst_Dissection <> nil);
      if (line = 1) and (not Dissected) then
      begin
        TR.txAccount := R.getField(i, 'CHART_CODE');
        MoneyVal := R.getField(i, 'AMOUNT');
        TR.txAmount := Double2Money(MoneyVal);
        TR.txGST_Class := R.getField(i, 'GST_CLASS');
        MoneyVal := R.getField(i, 'GST_AMOUNT');
        TR.txGST_Amount := Double2Money(MoneyVal);
        TR.txHas_Been_Edited := R.getField(i, 'HAS_BEEN_EDITED');
        TR.txGST_Has_Been_Edited := R.getField(i, 'GST_HAS_BEEN_EDITED');
        TR.txGL_Narration := R.getField(i, 'NARRATION');
      end
      else
      begin
        // Dissection lines may be read in reverse order so make they're all created
        DR := TR.txFirst_Dissection;
        for j := 0 to Pred(line) do
        begin
          if DR = nil then
          begin
            DR := bkdsio.New_Dissection_Rec;
            trxlist32.AppendDissection( TR, DR);
          end;
          if j < Pred(line) then
            DR := DR.dsNext;
        end;
        // dissection line exists so overwrite with info
        // add the dissection line
        DR.dsAccount := R.getField(i, 'CHART_CODE');
        MoneyVal := R.getField(i, 'AMOUNT');
        DR.dsAmount := Double2Money(MoneyVal);
        DR.dsGL_Narration := R.getField(i, 'NARRATION');
        MoneyVal := R.getField(i, 'GST_AMOUNT');
        DR.dsGST_Amount := Double2Money(MoneyVal);
        DR.dsGST_Class := R.getField(i, 'GST_CLASS');
        DR.dsGST_Has_Been_Edited := R.getField(i, 'GST_HAS_BEEN_EDITED');
        DR.dsHas_Been_Edited := R.getField(i, 'HAS_BEEN_EDITED');
        DR.dsNotes := R.getField(i, 'NOTES');
        DR.dsPayee_Number := R.getField(i, 'PAYEE_NUMBER');
        MoneyVal := R.getField(i, 'QUANTITY');
        DR.dsQuantity := MoneyVal * 10000;
      end;
    end;
  finally
    WDDX.Free;
    Packet.Free;
  end;
end;

// Check an existing transaction is ok to import
// Returns True if OK
// If returns False, aMsg will be filled with a reason
function ValidateTransactionForImport( ECT : pTransaction_Rec;
                                       T   : pTransaction_Rec;
                                       var aMsg : string) : boolean;
var
  DR: pDissection_Rec;
  Dissect_Total : Money;
begin
  result := false;
  aMsg   := '';

  //check match found
  if not Assigned( T) then
  begin
     aMsg := 'Match not found';
     exit;
  end;

 //check the presentation dates match
  if ( ECT.txDate_Presented <> 0) and ( ECT.txDate_Presented <> T.txDate_Presented)  then
  begin
     //rejected transaction found, pres dates different
     aMsg := 'Pres Date Mismatch - expected ' + bkDate2Str( T.txDate_Presented);
     exit;
  end;

  //check for finalised or transferred in bk5
  if ( T.txLocked) then
  begin
     aMsg := 'Finalised';
     exit;
  end;
  if ( T.txDate_Transferred <> 0 ) then
  begin
     aMsg := 'Transferred';
     exit;
  end;

  // Check dissection lines add up to main line amount
  if ( ECT.txFirst_Dissection <> NIL ) then begin
     Dissect_Total := 0;
     DR := ECT.txFirst_Dissection;
     while DR<>NIL do with DR^ do begin
        Dissect_Total := Dissect_Total + dsAmount;
        DR := dsNext;
     end;
     If ECT.txAmount <> Dissect_Total then Begin
     begin
      aMsg := 'Dissection lines total does not match transaction total';
      exit;
     end;
    end;
  end;

  //everything ok
  result := true;
end;

// Format the reason and adds it to the list of rejected transactions
procedure RejectTransaction( aClient: TClientObj; ECT : pTransaction_Rec;
  Reason : string; var RejectedLines : TStringList);
var
  NewLine : string;
  ECPayee : TPayee;
begin
  NewLine := 'Code = ' + ECT^.txAccount;
  NewLine := NewLine + '  Amt = ' + Money2Str( ECT^.txAmount);
  NewLine := NewLine + '  GST = ' + Money2Str( ECT^.txGST_Amount);

  if ECT^.txTax_Invoice_Available then
     NewLine := NewLine + '  Tax Inv = Y';

  if ECT^.txPayee_Number <> 0 then
  begin
    ECPayee := aClient.clPayee_List.Find_Payee_Number(ECT^.txPayee_Number);
    if assigned( ECPayee) then
      NewLine := NewLine + '  Payee = ' + inttostr( ecPayee.pdNumber) + ' ' + ecPayee.pdName;
  end;

  if ECT^.txQuantity <> 0 then
     NewLine := NewLine + '  Qty = ' + FormatFloat('#,##0.####', ECT^.txQuantity/10000);

  if Trim( ECT^.txNotes) <> '' then
     NewLine := NewLine + '  Notes = ' + GenUtils.StripReturnCharsFromString( ECT^.txNotes, ' | ');

  if Trim( ECT^.txGL_Narration) <> '' then
     NewLine := NewLine + '  Narration = ' + GenUtils.StripReturnCharsFromString( ECT^.txGL_Narration, ' | ');

  NewLine := NewLine + '  [' + Reason + ']';

  RejectedLines.Add( NewLine);
end;

// Get the narration details for a payee
function GetPayeeDetailsForNarration( aClient : TClientObj;
                                      const PayeeNo : integer;
                                      const LineNo : integer) : string;
var
  Payee : TPayee;
begin
  result := '';
  Payee := aClient.clPayee_List.Find_Payee_Number( PayeeNo);
  if Assigned( Payee) then
     result := Payee.pdLines.PayeeLine_At( LineNo).plGL_Narration;
end;

// Import a non-dissected transaction
procedure ImportStandardTransaction( ECT : pTRansaction_Rec;
                                     BKT   : pTransaction_Rec;
                                     aClient : TClientObj;
                                     BankPrefix : string);
var
  bkPayee            : PayeeObj.TPayee;
  bkPayeeLine        : pPayee_Line_Rec;
  NeedToUpdatePayeeDetails : boolean;
  NeedToUpdateGST          : boolean;
  trxPayeeDetails    : string;
  aMsg               : string;
  OldGLNarration: String;
begin
  //first we need to determine if the bk5 transaction is coded
  //if it is currently uncoded then code the transaction using the information
  //in the WebXOffice transaction
  NeedToUpdatePayeeDetails := False;
  NeedToUpdateGST          := False;
  trxPayeeDetails          := '';

  if BKT^.txFirst_Dissection = nil then
  begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 1 - WebXOffice (ND)  BK5 (ND)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //The BK5 transaction has not been dissected
    BKT^.txTemp_Tag := 1;
    //Amount - override the amount if the transaction is a UPC or UPD
    if ( BKT^.txAmount <> ECT^.txAmount) then
    begin
      if ( BKT^.txUPI_State in [ upUPC, upUPD, upUPW]) and (BKT^.txAmount = 0) then
      begin
        BKT^.txAmount := ECT^.txAmount;
        //update the GST amount if a class has been set in BK5.  This is in
        //case the transaction has been coded
        if BKT^.txGST_Class = 0 then
          BKT^.txGST_Amount := 0
        else
          //Assumes that Webx is never Forex and uses txAmount instead of Local_Amount
          BKT^.txGST_Amount := CalculateGSTForClass( aClient, BKT^.txDate_Effective, BKT^.txAmount, BKT^.txGST_Class);

        BKT.txTransfered_To_Online := False;
      end
      else
      begin
        //bk5 transaction already has an amount, so add a note to import notes
        if ECT^.txAmount <> 0 then
          AddToImportNotes( BKT, 'Amount '+ Money2Str( ECT^.txAmount), WEBX_GENERIC_APP_NAME);
      end;
    end;

    //Account
    if ( BKT.txAccount <> ECT.txAccount) and ( ECT.txAccount <> '') then
    begin
      if BKT.txAccount = '' then
      begin
        //account is blank so use ecoding account to code the transaction
        BKT.txAccount         := ECT.txAccount;
        BKT.txHas_Been_Edited := true;
        BKT.txTransfered_To_Online := False;
        NeedToUpdateGST       := true;
      end
      else begin
        AddToImportNotes( BKT, 'Account Code ' + ECT.txAccount, WEBX_GENERIC_APP_NAME);
      end;
    end;

    //Payee
    if ECT^.txPayee_Number <> 0 then
    begin
      //get payees
      bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);

      if ( ECT^.txPayee_Number = BKT^.txPayee_Number) then
        //even though the payee has not changed we need to reconstruct the
        //payee details so that the narration can be set correctly
        NeedToUpdatePayeeDetails := True
      else
      begin
        if not Assigned( bkPayee) then
          AddToImportNotes( BKT, 'Unknown Payee - number ' + IntToStr(ECT^.txPayee_Number), WEBX_GENERIC_APP_NAME)
        else
        begin
          //payee found
          if ( BKT^.txPayee_Number = 0) then
          begin
            //set the bk5 payee number from here
            BKT.txPayee_Number         := ECT^.txPayee_Number;
            BKT.txHas_Been_Edited      := True;
            BKT.txTransfered_To_Online := False;
            NeedToUpdatePayeeDetails   := True;
            NeedToUpdateGST            := True;
          end
          else
            AddToImportNotes( BKT, 'Payee ' + bkPayee.pdName +
                                   ' (' + inttostr( bkPayee.pdNumber) + ')',
                                   WEBX_GENERIC_APP_NAME);
        end;
      end;

      //now construct the payee details string so that we can set the narration
      if NeedToUpdatePayeeDetails then
      begin
        if Assigned( bkPayee) then
        begin
          if bkPayee.IsDissected then
          begin
            if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
              trxPayeeDetails := bkPayee.pdName
            else
              trxPayeeDetails := '';
          end
          else
          begin
            bkPayeeLine := bkPayee.FirstLine;
            if Assigned( bkPayeeLine) and ( bkPayeeLine.plAccount = BKT^.txAccount) then
              trxPayeeDetails := GetPayeeDetailsForNarration( aClient,
                                                              BKT^.txPayee_Number,
                                                              0)
            else
              trxPayeeDetails := bkPayee.pdName;
          end;
        end;
      end;
    end;

    //GST
    if NeedToUpdateGST then
    begin
      if ECT^.txPayee_Number <> 0 then
      begin
        //get payees
        bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);
        if Assigned(bkPayee) then
          bkPayeeLine := bkPayee.FirstLine
        else
          bkPayeeLine := nil;

        //decide whether to use gst from chart or payee
        if ( Assigned( bkPayeeLine)) and ( bkPayeeLine.plGST_Has_Been_Edited) and ( BKT^.txAccount = ECT^.txAccount) then
        begin
          //the gst has been overriden at the payee level so use that gst info
          //to code the transaction, this means that the gst amount in WebXOffice
          //should match the default gst amount for bk5
          BKT^.txGST_Class          := bkPayeeLine.plGST_Class;
          //Assumes that Webx is never Forex and uses txAmount instead of Local_Amount
          BKT^.txGST_Amount         := CalculateGSTForClass( aClient,
                                                             BKT^.txDate_Effective,
                                                             BKT^.txAmount,
                                                             BKT^.txGST_Class);
          BKT^.txGST_Has_Been_Edited := True;
        end
        else
        begin
          //use the gst from the account code
          UpdateTransGSTFields( aClient, BKT, BankPrefix, cbCodeIT);
        end;

        BKT.txCoded_By         := cbCodeIT;
        BKT.txHas_Been_Edited  := True;
        BKT.txTransfered_To_Online := False;
      end
      else
      begin
         //if manually coded then update gst class and amount from the account code
         //this will also update txCoded_by , txHasBeenEdited and txGST_has_been_Edited
         UpdateTransGSTFields( aClient, BKT, BankPrefix, cbCodeIT);
         BKT.txCoded_By := cbCodeIT;
      end;
    end;

    //gst
    if (ECT.txGST_Has_Been_Edited) and
       (BKT.txGST_Amount <> ECT.txGST_Amount) then
    begin
      aMsg := 'GST Amount    ' + Money2Str( ECT.txGST_Amount);
      AddToImportNotes( BKT, aMsg, WEBX_GENERIC_APP_NAME);
    end;

    //tax inv
    BKT^.txTax_Invoice_Available       := ECT^.txTax_Invoice_Available;

    //quantity
    //correct the sign of the quantity before comparing in case it is incorrect
    //in WebXOffice
    ECT^.txQuantity := ForceSignToMatchAmount( ECT^.txQuantity, BKT^.txAmount);
    if ( BKT^.txQuantity <> ECT^.txQuantity) then
    begin
      if BKT^.txQuantity = 0 then
      begin
        BKT^.txQuantity := ECT^.txQuantity;

        BKT.txTransfered_To_Online := False;
      end
      else
         AddToImportNotes( BKT, 'Quantity   ' + FormatFloat('#,##0.####', ECT.txQuantity/10000), WEBX_GENERIC_APP_NAME);
    end;

    OldGLNarration := BKT^.txGL_Narration;

    //gl narration
    BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            trxPayeeDetails,
                                            ECT^.txNotes);

    if BKT^.txGL_Narration <> BKT^.txGL_Narration then
    begin
      BKT.txTransfered_To_Online := False;
    end;

    //Notes
    BKT.txNotes := ECT.txNotes;
  end
  else
  begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 2 - WebXOffice (ND)  BK5 (D)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //Export the details to the notes field as the bk5 transaction is dissected
    BKT^.txTemp_Tag := 2;

    if ( ECT.txUPI_State in [ upUPD, upUPC, upUPW]) and ( ECT.txAmount <> 0) then
    begin
       AddToImportNotes( BKT, 'Amount ' + Money2Str( ECT.txAmount), WEBX_GENERIC_APP_NAME);
    end;
    //account
    if ( ECT.txAccount <> '') then
       AddToImportNotes( BKT, 'Account Code ' + ECT.txAccount, WEBX_GENERIC_APP_NAME);
    //gst, tax inv
    if ( ECT.txGST_Has_Been_Edited) then
    begin
       AddToImportNotes( BKT, 'GST Amount ' + Money2Str( ECT.txGST_Amount), WEBX_GENERIC_APP_NAME);
    end;
    //payee
    if ( ECT.txPayee_Number <> 0) and ( ECT.txPayee_Number <> BKT.txPayee_Number) then
    begin
       bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);

       if Assigned( bkPayee) then
         AddToImportNotes( BKT, ' Payee ' + bkPayee.pdName +
                                ' (' + inttostr( bkPayee.pdNumber) + ')',
                                WEBX_GENERIC_APP_NAME)
       else
         AddToImportNotes( BKT, 'Unknown Payee - number ' + IntToStr(ECT^.txPayee_Number), WEBX_GENERIC_APP_NAME);
    end;
    //quantity
    ECT^.txQuantity := ForceSignToMatchAmount( ECT^.txQuantity, ECT^.txAmount);
    if ( ECT.txQuantity <> 0) then
       AddToImportNotes( BKT, 'Quantity ' + FormatFloat('#,##0.####', ECT.txQuantity/10000), WEBX_GENERIC_APP_NAME);

    //tax invoice
    BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;

    //notes
    BKT.txNotes := ECT.txNotes;
  end;
end;

//returns true if the dissection lines match
//a match is determined by both transactions having the same no of dissect lines
//the account and amount must match for each of these lines
function DissectionsMatch( T : pTransaction_Rec; ECT : pTransaction_Rec) : boolean;
var
  D      : pDissection_Rec;
  ECD    : pDissection_Rec;
begin
  result := false;
  //same number of lines, codes and amount match
  D      := T.txFirst_Dissection;
  ECD    := ECT.txFirst_Dissection;

  if T.txAmount <> ECT.txAmount then
    exit;

  while ( D <> nil) and ( ECD <> nil) do
  begin
     if D^.dsAccount <> ECD^.dsAccount then
       exit;
     if D.dsAmount  <> ECD.dsAmount  then
       exit;

     D := D.dsNext;
     ECD := ECD.dsNext;
  end;

  if not (( ECD = nil) and ( D = nil)) then
     exit;

  result := true;
end;

//the dissection cannot be imported because of one of the following reasons:
//
//    1) The dissection lines in WebXOffice do not match the dissection in bk5
//    2) The WebXOffice transaction has been dissected, but the bk5 transaction has been coded normally
procedure ExportDissectionLinesToNotes( aClient : TClientObj; T : pTransaction_Rec; ECT : pTransaction_Rec);
var
  ExtraNotes : TStringList;
  ECD        : pDissection_Rec;
  NewLine    : string;
  ECPayee    : TPayee;
begin
  AddToImportNotes( T, 'Dissection cannot be imported.  Details added to notes', WEBX_GENERIC_APP_NAME);

  ExtraNotes := TStringList.Create;
  try
     ExtraNotes.Add( '');
     ExtraNotes.Add( 'Dissection Details');
     //add transaction level details
     if ( T^.txAmount <> ECT^.txAmount) then
        ExtraNotes.Add( 'Transaction Amount = ' + Money2Str( ECT^.txAmount));

     if ECT^.txPayee_Number <> 0 then
     begin
       ecPayee := aClient.clPayee_List.Find_Payee_Number( ECT.txPayee_Number);
       if Assigned( ecPayee) then
         ExtraNotes.Add( 'Transaction Payee = ' + ecPayee.pdName + ' (' +
                         inttostr( ecPayee.pdNumber) + ')');
     end;
     //add details for each line
     ECD := ECT^.txFirst_Dissection;
     while (ECD <> nil) do begin
        NewLine := '';

        NewLine := NewLine + 'Code = ' + ECD.dsAccount;
        NewLine := NewLine + '  Amt = ' + Money2Str( ECD.dsAmount);
        NewLine := NewLine + '  GST = ' + Money2Str( ECD.dsGST_Amount);
        if ECD.dsPayee_Number <> 0 then
        begin
           ECPayee := aClient.clPayee_List.Find_Payee_Number( ECD.dsPayee_Number);
           if assigned( ECPayee) then
              NewLine := NewLine + '  Payee = ' + ecPayee.pdName + ' (' +
                                      inttostr( ecPayee.pdNumber) + ') ';
        end;
        if ECD.dsQuantity <> 0 then
           NewLine := NewLine + '  Qty = ' + FormatFloat('#,##0.####', ECD.dsQuantity/10000);

        if Trim( ECD.dsNotes) <> '' then
           NewLine := NewLine + '  Notes = ' + GenUtils.StripReturnCharsFromString( ECD.dsNotes, ' | ');

        ExtraNotes.Add( NewLine);
        ECD := ECD.dsNext;
     end;

     ECT.txNotes := ECT.txNotes + ExtraNotes.Text;
  finally
     ExtraNotes.Free;
  end;
end;

//matches the lines in the dissection with the lines in the payee.
//the match is done on account
function ECodingDissectionMatchesBK5Payee( bkPayee : TPayee;
                                           ECT     : pTransaction_Rec) : boolean;
var
  D : pDissection_Rec;
  Line : integer;
  PayeeLine : pPayee_Line_Rec;
begin
  result := true;

  D := ECT^.txFirst_Dissection;
  Line := 0;

  while ( D <> nil) do
    begin
      Inc( Line);
      D := D.dsNext;
    end;

  if Line = bkPayee.pdLines.ItemCount then
    begin
      D := ECT^.txFirst_Dissection;
      for line := bkPayee.pdLines.First to bkPayee.pdLines.Last do
        begin
          PayeeLine := bkPayee.pdLines.PayeeLine_At( Line);
          if PayeeLine.plAccount <> D.dsAccount then
            begin
              result := false;
              exit;
            end;
          D := D.dsNext;
        end;
    end
  else
    result := false;
end;

//both transactions are dissected, test for match has been done
procedure ImportExistingDissection( ECT : pTransaction_Rec;
                                    BKT   : pTransaction_Rec;
                                    aClient : TClientObj);
var
  bkPayee : TPayee;
  bkPayeeLine : pPayee_Line_Rec;
  BKD                : pDissection_Rec;
  ECD                : pDissection_Rec;

  bkDissectionLine   : pDissection_Rec;
  DissectionLineNo   : integer;

  DissectionMatchesPayee   : boolean;

  Transaction_Payee : TPayee;
  trxPayeeDetail     : string;
  dPayeeDetail       : string;  //detail for dissection line

  UseBK5PayeeInformation : boolean;
  CurrentProcessingPayeeID : integer;

  LinesForCurrentPayee : integer;
  CurrentPayeeLine     : integer;
  i : integer;
begin
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //CASE 5 - WebXOffice (D)  BK5 (D) - Dissections Match
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //GST will have been assigned when the transaction was coded in BK5 so we
  //do not need to reassign the gst here

  trxPayeeDetail := '';
  dPayeeDetail := '';
  Transaction_Payee := nil;
  DissectionMatchesPayee := False;

  BKT^.txTemp_Tag := 5;

  //Import Transaction level fields

  //amount
    // already tested that this matches bk5

  //account
    // n/a because transaction is dissected

  //gst
    // n/a because transaction is dissected

  //Notes
  BKT.txNotes        := ECT.txNotes;
  BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;

  //Payee
  //payee cannot be set in WebXOffice if the transaction has been coded by
  //the accountant, however we may need to recreate the narration
  bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);

  if ( BKT^.txPayee_Number <> ECT^.txPayee_Number) then
  begin
    //payee is different, add a note
    if ect^.txPayee_Number <> 0 then
    begin
      if Assigned( bkPayee) then
        AddToImportNotes( BKT, 'Payee ' + bkPayee.pdName + ' (' + inttostr( bkPayee.pdNumber) + ')', WEBX_GENERIC_APP_NAME)
      else
        AddToImportNotes( BKT, 'Unknown Payee - number ' + IntToStr(ECT^.txPayee_Number), WEBX_GENERIC_APP_NAME);
    end;
  end;

  //store the payee name so that we can use it to recreate the narration if
  //needed
  if ( BKT^.txPayee_Number <> 0) then
  begin
    bkPayee :=  aClient.clPayee_List.Find_Payee_Number( BKT^.txPayee_Number);
    if Assigned( bkPayee) then
    begin
      trxPayeeDetail := bkPayee.pdFields.pdName;

      //now see if the dissection matches the narration
      DissectionMatchesPayee := BK5DissectionMatchesBK5Payee( bkPayee, BKT);
      Transaction_Payee := bkPayee;
    end;
  end;

  //GL Narration
  if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
    BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            trxPayeeDetail,
                                            ECT^.txNotes)
  else
    BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            '',
                                            ECT^.txNotes);

  //NOW IMPORT DISSECTION LINES
  BKD := BKT^.txFirst_Dissection;
  ECD := ECT^.txFirst_Dissection;
  DissectionLineNo := 1;

  CurrentProcessingPayeeID := 0;
  CurrentPayeeLine := 0;
  LinesForCurrentPayee := 0;
  UseBK5PayeeInformation := false;

  while ( BKD <> nil) do
  begin
    BKD.dsECoding_Import_Notes := '';

    //Amount
      //already tested that this matches bk5, also cannot be edited in WebXOffice unless upc

    //Account
      //already tested that this matched bk5, also cannot be edited in WebXOffice if it was dissected in bk5 on export

    //GST Amount
      //show flag if amounts are different or user has specied gst and zero for
      //and uncoded line
    if ( ECD.dsGST_Has_Been_Edited) then
      if ( ECD.dsGST_Amount <> BKD.dsGST_Amount) or
         (( ECD.dsGST_Amount = 0) and ( BKD.dsAccount = '')) then
      begin              
        AddToImportNotes( BKD, 'GST Amount  ' + Money2Str( ECD.dsGST_Amount), WEBX_GENERIC_APP_NAME);
      end;

    //Quantity
    ECD^.dsQuantity := ForceSignToMatchAmount( ECD^.dsQuantity, BKD^.dsAmount);
    if ( ECD^.dsQuantity <> BKD^.dsQuantity) then
    begin
      if BKD^.dsQuantity = 0 then
      begin
        BKD^.dsQuantity := ECD^.dsQuantity;
      end
      else
        AddToImportNotes( BKD, 'Quantity  ' + FormatFloat('#,##0.####', ECD.dsQuantity/10000), WEBX_GENERIC_APP_NAME);
    end;

    //Notes
    BKD.dsNotes := ECD.dsNotes;

    //Payee
    //show note if payee values are different
    if BKD.dsPayee_Number <> ECD.dsPayee_Number then
    begin
      //payee is different, add a note
      if ecd^.dsPayee_Number <> 0 then
      begin
        bkPayee := aClient.clPayee_List.Find_Payee_Number( ECD^.dsPayee_Number);

        if Assigned( bkPayee) then
          AddToImportNotes( BKD, 'Payee ' + bkPayee.pdName + ' (' + inttostr( bkPayee.pdNumber) + ')', WEBX_GENERIC_APP_NAME)
        else
          AddToImportNotes( BKD, 'Unknown Payee - number ' + IntToStr(ECT^.txPayee_Number), WEBX_GENERIC_APP_NAME);
      end;
    end;

    if BKT^.txPayee_Number <> 0 then
    begin
      //if the dissection has been created by a payee at transaction level then
      //use the payee for narration
      if DissectionMatchesPayee then
        dPayeeDetail := Transaction_Payee.pdLines.PayeeLine_At( DissectionLineNo - 1).plGL_Narration
      else
        dPayeeDetail := '';  //dont know what payee detail to use

      UseBK5PayeeInformation := false;
    end
    else
    begin
      //if the dissection lines are coded by payee then we need to see if
      //the payee lines match the next n dissection lines
      //this will allow us to reset the narration
      bkPayee := aClient.clPayee_List.Find_Payee_Number( BKD^.dsPayee_Number);
      dPayeeDetail := '';

      if not Assigned( bkPayee) then
      begin
        dPayeeDetail := '';
        UseBK5PayeeInformation := false;
      end
      else
      begin
        //payee found
        dPayeeDetail := bkPayee.pdFields.pdName;

        //see if we are already coding using a payee
        if ( CurrentProcessingPayeeID <> BKD.dsPayee_Number) or ( CurrentPayeeLine > ( LinesForCurrentPayee - 1)) then
        begin
          //this is a new payee id, see if the following lines match
          //the structure of the payee in bk5
          CurrentProcessingPayeeID := bkPayee.pdFields.pdNumber;
          LinesForCurrentPayee := bkPayee.pdLinesCount;
          CurrentPayeeLine := 0;
          UseBK5PayeeInformation := false;
          //bkPayeeLine := nil;

          if LinesForCurrentPayee > 0 then
          begin
            bkDissectionLine := BKD;
            //see if next n lines match the bk5 payee
            i := 0;
            Repeat
              bkPayeeLine := bkPayee.pdLines.PayeeLine_At( i);
              UseBK5PayeeInformation := ( bkDissectionLine.dsAccount = bkPayeeLine.plAccount);
              bkDissectionLine := bkDissectionLine.dsNext;
              if bkDissectionLine <> nil then
                Inc( i);
            Until ( i = LinesForCurrentPayee) or ( bkDissectionLine = nil) or ( not UseBK5PayeeInformation);

            //make sure there are enough dissection lines
            if ( i < (LinesForCurrentPayee - 1)) then
              UseBK5PayeeInformation := false;

            if not UseBK5PayeeInformation then
            begin
              LinesForCurrentPayee := 0;
              //bkPayeeLine := nil;
            end;
          end;
        end;

        //get the current line and use that to set the narration
        if UseBK5PayeeInformation then
        begin
          bkPayeeLine := bkPayee.pdLines.PayeeLine_At( CurrentPayeeLine);
          dPayeeDetail := bkPayeeLine.plGL_Narration;
          Inc( CurrentPayeeLine);
        end;
      end;
    end;

    //Narration
    BKD.dsGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                           BKD.dsGL_Narration,
                                           dPayeeDetail,
                                           ECD.dsNotes);

    //move to next dissection line
    BKD := BKD.dsNext;
    ECD := ECD.dsNext;
    Inc( DissectionLineNo);
  end;
end;

procedure ImportNewDissection_NoPayees( ECT : pTransaction_Rec;
                                        BKT : pTransaction_Rec;
                                        aClient : TClientObj);
var
  BKD                : pDissection_Rec;
  ECD                : pDissection_Rec;
  DefaultGSTClass    : byte;
  DefaultGSTAmount   : Money;
begin
  BKT.txAccount := DISSECT_DESC;
  BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;

  ClearGSTFields( BKT);
  ClearSuperFundFields( BKT);

  //Import Transaction Level Fields
  BKT.txAmount := ECT.txAmount;
  BKT.txPayee_Number := 0;
  BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                          BKT^.txGL_Narration,
                                          '',
                                          ECT^.txNotes);
  BKT.txNotes := ECT.txNotes;
  BKT.txCoded_By := cbCodeIT;
  BKT.txTemp_Tag := 61;  
  
  //NOW IMPORT DISSECTION LINES
  ECD := ECT^.txFirst_Dissection;
  while ( ECD <> nil) do
  begin
    //create a new dissection line for the bk5 transaction
    BKD := bkdsio.New_Dissection_Rec;
    BKD.dsECoding_Import_Notes  := '';

    BKD.dsAmount            := ECD.dsAmount;
    BKD.dsAccount           := ECD.dsAccount;
    BKD.dsHas_Been_Edited   := ECD.dsHas_Been_Edited;

    //GST - calculate gst using information from the chart codes
    CalculateGST( aClient, BKT^.txDate_Effective, BKD^.dsAccount, BKD^.dsAmount, DefaultGSTClass, DefaultGSTAmount);
    BKD^.dsGST_Amount   := DefaultGSTAmount;
    BKD^.dsGST_Class    := DefaultGSTClass;
    BKD^.dsGST_Has_Been_Edited := False;

    //now see if the gst specified in bnotes is different
    //also add a note if gst is 0.00 in both places and trans is uncoded
    if (ECD^.dsGST_Has_Been_Edited) then
      if ( ECD^.dsGST_Amount <> BKD^.dsGST_Amount) or
         (( ECD^.dsGST_Amount = 0) and ( BKD^.dsAccount = ''))
      then
        AddToImportNotes( BKD, 'GST Amount  ' + Money2Str( ECD^.dsGST_Amount), WEBX_GENERIC_APP_NAME);

    BKD.dsQuantity          := ForceSignToMatchAmount( ECD.dsQuantity, BKD.dsAmount);
    BKD.dsNotes             := ECD.dsNotes;
    BKD.dsGL_Narration      := UpdateNarration( aClient.clFields.clECoding_Import_Options, BKD.dsGL_Narration, '', ECD.dsNotes);

    //Add the new dissection to the transaction
    TrxList32.AppendDissection( BKT, BKD);
    ECD := ECD.dsNext;
  end;
end;

procedure ImportNewDissection_TransactionLevelPayee( ECT : pTransaction_Rec;
                                        BKT : pTransaction_Rec;
                                        aClient : TClientObj);
var
  bkPayee : TPayee;
  bkPayeeLine : pPayee_Line_Rec;
  BKD                : pDissection_Rec;
  ECD                : pDissection_Rec;
  DissectionLineNo   : integer;
  DissectionMatchesPayee   : boolean;
  trxPayeeDetail     : string;
  dPayeeDetail       : string;  //detail for dissection line
  DefaultGSTClass    : byte;
  DefaultGSTAmount   : Money;
  UseTransactionPayeeDetails  : boolean;
begin
  //Dissect the BK5 transaction
  BKT.txAccount := DISSECT_DESC;
  ClearGSTFields( BKT);
  ClearSuperFundFields( BKT);

  //Import Transaction Level Fields
  //Amount
  BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;
  BKT.txAmount := ECT.txAmount;
  BKT.txPayee_Number := 0;
  BKT.txTemp_Tag := 62;

  //Payee
  bkPayee := nil;
  trxPayeeDetail := '';
  dPayeeDetail := '';
  UseTransactionPayeeDetails := False;

  if ECT^.txPayee_Number <> 0 then
  begin
    bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);

    if not Assigned( bkPayee) then
    begin
      //no matching payee found in bk5
      AddToImportNotes( BKT, 'Unknown Payee - number ' + IntToStr(ECT^.txPayee_Number), WEBX_GENERIC_APP_NAME);
    end
    else
    begin
      //payee found
      //set the bk5 payee number from here
      BKT.txPayee_Number         := ECT^.txPayee_Number;
      BKT.txHas_Been_Edited      := True;
      BKT.txTransfered_To_Online := False;

      if bkPayee.IsDissected then
      begin
        //use the payee name outside the narration
        if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
        begin
          trxPayeeDetail := bkPayee.pdName;
          dPayeeDetail   := trxPayeeDetail;
        end
        else
        begin
          trxPayeeDetail := '';
          dPayeeDetail   := bkPayee.pdName;
        end;

        //now we need to see if the payee lines match the dissection lines
        //this will be used later to decide what payee details to add
        //to each line
        DissectionMatchesPayee := ECodingDissectionMatchesBK5Payee( bkPayee, ECT);
      end
      else
      begin
        //transaction is dissected but payee is not.
        trxPayeeDetail       := bkPayee.pdName;
        dPayeeDetail         := '';
        DissectionMatchesPayee := false;
      end;

      //the payee and dissection match so we can use the bk5 payee for
      //calculating the default gst for this line
      UseTransactionPayeeDetails := DissectionMatchesPayee;
    end;
  end;

  //GL Narration
  BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                          BKT^.txGL_Narration,
                                          trxPayeeDetail,
                                          ECT^.txNotes);
  //Notes
  BKT.txNotes         := ECT.txNotes;

  BKT.txCoded_By := cbCodeIT;

  //NOW IMPORT DISSECTION LINES
  ECD := ECT^.txFirst_Dissection;
  DissectionLineNo := 1;

  while ( ECD <> nil) do
  begin
    //create a new dissection line for the bk5 transaction
    BKD := bkdsio.New_Dissection_Rec;
    BKD.dsECoding_Import_Notes  := '';


    BKD.dsAmount            := ECD.dsAmount;
    BKD.dsAccount           := ECD.dsAccount;
    BKD.dsHas_Been_Edited   := ECD.dsHas_Been_Edited;
    BKD.dsPayee_Number      := 0;

    //GST and Payee
    if UseTransactionPayeeDetails then
    begin
      //this flag is only set if the bk5 payee exists and it matches the
      //dissection
      //bkpayee will have been set above
      //payee will have been set OUTSIDE the dissection

      bkPayeeLine := bkPayee.pdLines.PayeeLine_At( DissectionLineNo - 1);

      BKD^.dsGST_Class  := bkPayeeLine.plGST_Class;
      //Assumes that Webx is never Forex and uses dsAmount instead of Local_Amount
      BKD^.dsGST_Amount := CalculateGSTForClass( aClient, BKT^.txDate_Effective, BKD^.dsAmount, BKD^.dsGST_Class);
      BKD^.dsGST_Has_Been_Edited := bkPayeeLine.plGST_Has_Been_Edited;

      //the payee was specified at the transaction level, the dissection
      //and the payee match so use the details from the payee for the
      //payee detail
      dPayeeDetail := bkPayee.pdLines.PayeeLine_At( DissectionLineNo - 1).plGL_Narration;
      // if blank then use payee name
      if Trim(dPayeeDetail) = '' then
        dPayeeDetail := bkPayee.pdName;      
    end
    else
    begin
      //set gst information based on the chart
      //payee not found or dissection too long, use default gst
      //calculate gst using information from the chart codes
      CalculateGST( aClient, BKT^.txDate_Effective, BKD^.dsAccount, BKD^.dsAmount, DefaultGSTClass, DefaultGSTAmount);
      BKD^.dsGST_Amount   := DefaultGSTAmount;
      BKD^.dsGST_Class    := DefaultGSTClass;
      BKD^.dsGST_Has_Been_Edited := False;
    end;

    //now see if the gst specified in bnotes is different
    //also add a note if gst is 0.00 in both places and trans is uncoded
    if (ECD^.dsGST_Has_Been_Edited) then
      if ( ECD^.dsGST_Amount <> BKD^.dsGST_Amount) or
         (( ECD^.dsGST_Amount = 0) and ( BKD^.dsAccount = ''))
      then
        AddToImportNotes( BKD, 'GST Amount  ' + Money2Str( ECD^.dsGST_Amount), WEBX_GENERIC_APP_NAME);

    //Quantity
    BKD.dsQuantity          := ForceSignToMatchAmount( ECD.dsQuantity, BKD.dsAmount);

    //Notes
    BKD.dsNotes             := ECD.dsNotes;

    //Narration
    BKD.dsGL_Narration      := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                                BKD.dsGL_Narration,
                                                dPayeeDetail,
                                                ECD.dsNotes);

    //Add the new dissection to the transaction
    TrxList32.AppendDissection( BKT, BKD);
    ECD := ECD.dsNext;
    Inc( DissectionLineNo);
  end;
end;

procedure ImportNewDissection_DissectionLinePayees( ECT : pTRansaction_Rec;
                                      BKT   : pTransaction_Rec;
                                      aClient : TClientObj);
var
  bkPayee : TPayee;
  bkPayeeLine : pPayee_Line_Rec;
  BKD                : pDissection_Rec;
  ECD                : pDissection_Rec;
  DissectionLine     : pDissection_Rec;
  trxPayeeDetail     : string;
  dPayeeDetail       : string;  //detail for dissection line
  DefaultGSTClass    : byte;
  DefaultGSTAmount   : Money;
  UseBK5PayeeInformation : boolean;
  CurrentProcessingPayeeID : integer;
  LinesForCurrentPayee : integer;
  CurrentPayeeLine     : integer;
  i : integer;
begin
  //look through the dissection lines and try to match payee, match
  //on account and payee line no
  trxPayeeDetail       := '';
  dPayeeDetail         := '';

  //Dissect the BK5 transaction
  BKT.txAccount := DISSECT_DESC;
  ClearGSTFields( BKT);
  ClearSuperFundFields( BKT);
  UseBK5PayeeInformation := false;

  //Import Transaction Level Fields
  //Amount
  BKT.txAmount        := ECT.txAmount;
  BKT.txPayee_Number := 0;
  BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                          BKT^.txGL_Narration,
                                          '',
                                          ECT^.txNotes);
  BKT.txNotes         := ECT.txNotes;
  BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;
  BKT.txTemp_Tag := 63;

  BKT.txCoded_By := cbCodeIT;

  //NOW IMPORT DISSECTION LINES
  ECD := ECT^.txFirst_Dissection;
  CurrentProcessingPayeeID := 0;       //id of payee we are currently using
  CurrentPayeeLine := 0;               //line # in the payee detail
  LinesForCurrentPayee := 0;           //total # of lines in payee detail
  bkPayeeLine := nil;

  while ( ECD <> nil) do
  begin
    //create a new dissection line for the bk5 transaction
    BKD := bkdsio.New_Dissection_Rec;
    BKD.dsECoding_Import_Notes  := '';

    BKD.dsAmount := ECD.dsAmount;
    BKD.dsAccount := ECD.dsAccount;
    BKD.dsHas_Been_Edited := ECD.dsHas_Been_Edited;
    BKD.dsQuantity := ForceSignToMatchAmount( ECD.dsQuantity, BKD.dsAmount);
    BKD.dsNotes := ECD.dsNotes;

    dPayeeDetail := '';

    //Payee
    if ( ECD^.dsPayee_Number <> 0) then
    begin
      //payee has been specified INSIDE the dissection
      bkPayee := aClient.clPayee_List.Find_Payee_Number( ECD^.dsPayee_Number);

      if not Assigned( bkPayee) then
      begin
        AddToImportNotes( BKD, 'Unknown Payee - number ' + IntToStr(ECT^.txPayee_Number), WEBX_GENERIC_APP_NAME);
        UseBK5PayeeInformation := false;
      end
      else
      begin
        //payee # matches
        BKD.dsPayee_Number    := ECD.dsPayee_Number;
        BKD.dsHas_Been_Edited := True;

        //see if we are already coding using a payee
        if ( CurrentProcessingPayeeID <> ecd.dsPayee_Number) or ( CurrentPayeeLine > ( LinesForCurrentPayee - 1)) then
        begin
          //this is a new payee id, see if the following lines match
          //the structure of the payee in bk5
          CurrentProcessingPayeeID := bkPayee.pdFields.pdNumber;
          LinesForCurrentPayee := bkPayee.pdLinesCount;
          CurrentPayeeLine := 0;

          if LinesForCurrentPayee > 0 then
          begin
            DissectionLine := ECD;
            //see if next n lines match the bk5 payee
            i := 0;
            Repeat
              bkPayeeLine := bkPayee.pdLines.PayeeLine_At( i);
              UseBK5PayeeInformation := ( DissectionLine.dsAccount = bkPayeeLine.plAccount);
              DissectionLine := DissectionLine.dsNext;
              if DissectionLine <> nil then
              begin
                Inc(i);
              end;
            Until ( i = LinesForCurrentPayee) or ( DissectionLine = nil) or ( not UseBK5PayeeInformation);

            //make sure there are enough dissection lines
            if ( i < (LinesForCurrentPayee - 1)) then
              UseBK5PayeeInformation := false;

            if not UseBK5PayeeInformation then
            begin
              LinesForCurrentPayee := 0;
              //bkPayeeLine := nil;
            end;
          end;
        end;

        if UseBK5PayeeInformation then
        begin
          bkPayeeLine := bkPayee.pdLines.PayeeLine_At( CurrentPayeeLine);
          Inc( CurrentPayeeLine);

          dPayeeDetail := bkPayeeLine.plGL_Narration;
        end
        else
          //payee doesnt match, just use the payee name for each line
          dPayeeDetail := bkPayee.pdFields.pdName;
      end;
    end
    else
    begin
      UseBK5PayeeInformation := false;
      bkPayeeLine := nil;
      dPayeeDetail := '';
    end;

    //gst
    if UseBK5PayeeInformation and Assigned( bkPayeeLine) then
    begin
      BKD^.dsGST_Class  := bkPayeeLine.plGST_Class;
      //Assumes that Webx is never Forex and uses dsAmount instead of Local_Amount
      BKD^.dsGST_Amount := CalculateGSTForClass( aClient, BKT^.txDate_Effective, BKD^.dsAmount, BKD^.dsGST_Class);
      BKD^.dsGST_Has_Been_Edited := bkPayeeLine.plGST_Has_Been_Edited;
    end
    else
    begin
      //Assumes that Webx is never Forex and uses dsAmount instead of Local_Amount
      CalculateGST( aClient, BKT^.txDate_Effective, BKD^.dsAccount, BKD^.dsAmount, DefaultGSTClass, DefaultGSTAmount);

      BKD^.dsGST_Amount   := DefaultGSTAmount;
      BKD^.dsGST_Class    := DefaultGSTClass;
      BKD^.dsGST_Has_Been_Edited := False;
    end;

    //now see if the gst specified in bnotes is different
    //also add a note if gst is 0.00 in both places and trans is uncoded
    if (ECD^.dsGST_Has_Been_Edited) then
      if ( ECD^.dsGST_Amount <> BKD^.dsGST_Amount) or
         (( ECD^.dsGST_Amount = 0) and ( BKD^.dsAccount = ''))
      then
        AddToImportNotes( BKD, 'GST Amount  ' + Money2Str( ECD^.dsGST_Amount), WEBX_GENERIC_APP_NAME);

    //Narration
    BKD.dsGL_Narration      := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                  BKD.dsGL_Narration, dPayeeDetail, ECD.dsNotes);

    //Add the new dissection to the transaction
    TrxList32.AppendDissection( BKT, BKD);
    ECD := ECD.dsNext;
  end;
end;

// Import a dissected transaction
procedure ImportDissectedTransaction( ECT : pTRansaction_Rec;
                                      BKT   : pTransaction_Rec;
                                      aClient : TClientObj);
const
  dplNone = 0;
  dplAtTransaction = 1;
  dplWithinDissection = 2;
var
  ECD                   : pDissection_Rec;
  ExportToNotesRequired : Boolean;
  DissectionPayeeLevel  : byte;
begin
  //we first need to check if the transaction can be imported at all,
  //or if we should just export the transaction to the notes field.
  ExportToNotesRequired    := false;

  //if the transaction is dissected then both dissections must match before
  //importing
  if ( BKT^.txFirst_Dissection <> nil) and ( not DissectionsMatch( BKT, ECT)) then
  begin
    ExportToNotesRequired := true;
    BKT^.txTemp_Tag := 3;
  end;

  //if the transaction is not dissected we need some further tests
  if ( BKT^.txFirst_Dissection = nil) then
  begin
    //if bk5 tranasction is coded then export
    if BKT^.txAccount <> '' then
    begin
      ExportToNotesRequired := true;
      BKT^.txTemp_Tag := 4;
    end;

    //if transaction amounts are different then dissection will not balance
    if ( BKT^.txAmount <> ECT^.txAmount) then
    begin
      ExportToNotesRequired := true;
      BKT^.txTemp_Tag := 4;      
    end;
  end;

  if ExportToNotesRequired then
  begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 3   WebXOffice (D)   BK5 ( D)  - Dissections don't match
    //CASE 4   WebXOffice (D)   BK5 ( ND) - TrxAmount different
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ExportDissectionLinesToNotes( aClient, BKT, ECT);
    BKT.txNotes        := ECT.txNotes;

    Exit;
  end;

  if BKT^.txFirst_Dissection <> nil then
  begin
    //both transactions are dissected, test for match has been done
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 5 - WebXOffice (D)  BK5 (D) - Dissections Match
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ImportExistingDissection( ECT, BKT, aClient);
  end
  else
  begin
    //bk5 tranaction is not coded, code from dissection WebXOffice transaction
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 6 - WebXOffice (D)  BK5 (NC)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -

    //it is easier to split this into three cases because of the complexity
    //introduced by payees

    //case 6a - The WebXOffice dissection does not contain any payee coding
    //case 6b - The dissection has been coded via a payee at the trans level
    //case 6c - The dissection has lines with payees codes

    //look for payees in the WebXOffice dissection
    DissectionPayeeLevel := dplNone;

    if ECT.txPayee_Number <> 0 then
      DissectionPayeeLevel := dplAtTransaction
    else
    begin
      ECD := ECT^.txFirst_Dissection;
      while ( ECD <> nil) do
      begin
        if ECD.dsPayee_Number <> 0 then
        begin
          ECD := nil;
          DissectionPayeeLevel := dplWithinDissection;
        end
        else
          ECD := ECD.dsNext;
      end;
    end;

    //CASE 6a - no payee
    if DissectionPayeeLevel = dplNone then
    begin
      ImportNewDissection_NoPayees( ECT, BKT, aClient);
    end;

    //case 6b - Payee specified at transaction level
    if DissectionPayeeLevel = dplAtTransaction then
    begin
      ImportNewDissection_TransactionLevelPayee( ECT, BKT, aClient);
    end;

    //CASE 6c
    if DissectionPayeeLevel = dplWithinDissection then
    begin
      ImportNewDissection_DissectionLinePayees( ECT, BKT, aClient);
    end;
  end;
end;

// This routine actually does the importing from the WebXOffice file
procedure ProcessECodingFile( BAList: TBank_Account_List; aClient : TClientObj; var ImportedCount, RejectedCount : integer);
var
  acNo             : integer;
  TNo              : integer;
  BKTNo            : integer;
  ba               : TBank_Account;
  ecBA             : TBank_Account;
  TempT            : pTransaction_Rec;
  T                : pTransaction_Rec;
  ECT              : pTransaction_Rec;
  EMsg             : string;
  S                : string;
  TransactionCompare: TTransactionCompare;
begin
  //initialise counters
  RejectedCount     := 0;
  ImportedCount     := 0;

  //cycle through each bank account in the file and find the matching
  //bk5 file
  for acNo := 0 to BAList.Last do
  begin
    ecBa := BAList.Bank_Account_At( acNo);
    BA := aClient.clBank_Account_List.FindAccountFromECodingUID(ecBA.baFields.baECoding_Account_UID);

    if Assigned( Ba) then
    begin
      //Matching BK5 account found, so import transactions
      for TNo := 0 to ecBa.baTransaction_List.Last do
      begin
        T := nil;

        ECT := ecBa.baTransaction_List.Transaction_At( TNo);
        // WebXOffice cannot have UPIs
        if ECT.txECoding_Transaction_UID = 0 then
          Inc( RejectedCount)
        else
        begin
          //Find the matching BK5 transaction
          T := nil;
          for BKTNo := 0 to ba.baTransaction_List.Last do
          begin
            TempT := ba.baTransaction_List.Transaction_At( BKTNo);
            if TempT^.txECoding_Transaction_UID = ECT^.txECoding_Transaction_UID then
            begin
              T := TempT;
              Break;
            end;
          end;
        end;

        //check that transaction is valid and import it
        if Assigned( T) then
        begin
          if ValidateTransactionForImport( ECT, T, EMsg) then
          begin
            T^.txECoding_Import_Notes := '';
            // Why are we forcing this to be set???
            T^.txHas_Been_Edited := True;  //See Case 7113
            T^.txTransfered_To_Online := False;

            // Well it would apear it breaks the disection inport if we dont set it
            // May need to revisit ... read the case ...

            S := Copy( Ba.baFields.baBank_Account_Number, 1, 2);
            //the way we import the transaction depends on whether or not the transaction
            //is dissected in WebXOffice

            if T.txTransfered_To_Online then
            begin
              TransactionCompare := TDataExportTransactionCompare.Create(T);

              try
                if ECT^.txFirst_Dissection = nil then
                begin
                  ImportStandardTransaction( ECT, T, aClient, S);
                end
                else
                begin
                  ImportDissectedTransaction( ECT, T, aClient);
                end;

                if not TransactionCompare.IsEqual(T) then
                begin
                  T.txTransfered_To_Online := False;
                end;
              finally
                TransactionCompare.Free;
              end;
            end
            else
            begin
              if ECT^.txFirst_Dissection = nil then
              begin
                ImportStandardTransaction( ECT, T, aClient, S);
              end
              else
              begin
                ImportDissectedTransaction( ECT, T, aClient);
              end;            
            end;

            Inc( ImportedCount);
          end
          else
          begin
            Inc( RejectedCount);
          end;
        end;
      end;  //transaction loop
    end;
  end; // bank account loop
end;

// Returns True if installed and registsred
function IsWDDXInstalled: Boolean;
var
  DWDDX: TWDDXDeserializer;
begin
  Result := True;
  DWDDX := nil;
  try
    DWDDX := TWDDXDeserializer.Create(nil);
    DWDDX.DefaultInterface;
  except
    Result := False;
  end;
  if Assigned(DWDDX) then
    DWDDX.Free;
end;

// Try to register the WDDX COM
function RegisterWDDXCOM: Boolean;
var
  path: string;
begin
  path := IncludeTrailingPathDelimiter(GLOBALS.DataDir) + WDDX_FILENAME;
  Result := True;
  if not FileExists(path) then
    Result := False
  else
    try
      RegisterCOMServer(path);
    except
      Result := False;
    end;
end;

function IsWebFileWaiting: Boolean;
var
  WebXFile, Filename: string;
  i: Integer;
begin
  Result := False;
  WebXFile := WebXOffice.GetWebXDataPath;
  if (WebXFile = '') then exit; // no acclipse installed
  if not IsWDDXInstalled then
  begin
    if not RegisterWDDXCOM then exit; // no acclipse installed
  end;

  // what would be the next file to import
  // is there a file greater than the last one imported and less than or equal the last one exported
  i := MyClient.clFields.clECoding_Last_File_No_Imported + 1;
  while i <= MyClient.clFields.clECoding_Last_File_No do
  begin
    Filename := WebXOffice.GetWebXDataPath(WEBX_IMPORT_FOLDER) +
              MyClient.clFields.clCode + '_' + inttostr(i) + '.' + WEBX_IMPORT_EXTN;
    if BKFileExists(Filename) then
    begin
      Result := True;
      Break;
    end
    else
      Inc(i);
  end;
end;

end.
