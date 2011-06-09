unit ImportExtra;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//------------------------------------------------------------------------------
{
   Title:       Import Extra

   Description: Routines to import extra transaction from update files

   Author:      Matthew Hopkins

   Remarks:     Rewritten Sep 2002 to support new update disk format

                All knowledge about the UpdateFiles, such as format and how to
                import is contained in this unit so that ImportExtraDlg does not
                need to now how to handle the files.

                Uses a common routine for inserting transactions from a temp
                list into a Bank Account.  This could be split out and used by
                Offsite Download and Merge32.
}
//------------------------------------------------------------------------------
interface

//Enable this if you want to be able to import an update file for a bank account
//which isn't in the client file.
{.$.DEFINE ADD_IN_UPDATE}

function ShowUpdateFileInListBox( const fileName : string;
                                  var Account    : string;
                                  var DateFrom, DateTo : integer;
                                  var Status     : byte) : boolean;

function ImportUpdateFile(Filename: string) : boolean;

//******************************************************************************
implementation
uses
   LogUtil,
   Globals,
   ErrorMoreFrm,
   InfoMoreFrm,
   GenUtils,
   bkConst,
   bkDateUtils,
   MoneyDef,
   baObj32,
   bkdefs,
   trxList32,
   bktxio,
   UpdateMF,
   SysUtils,
   StStrS,
   InsertTrans,
   FHDefs,
   FHExceptions,
   NFDiskObj, BaseDisk, dbObj, ECollect, dtList, BaList32;

const
   UnitName = 'IMPORTEXTRA';
var
   DebugMe : boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ImportUpdateFileEx( Filename : string) : boolean;
Const
  ThisMethodName = 'ImportUpdateFileEx';

var
  DiskImage      : TUpdateDiskReader;
  DiskAccount    : TDisk_Bank_Account;
  DiskTxn        : pDisk_Transaction_Rec;
  dTNo           : integer;   //disk transaction no
  BankAccount    : TBank_Account;
  TempTransList  : TTransaction_List;
  pT             : pTransaction_Rec;
  S              : string;
  NoOfEntries    : integer;
  FirstDate,
  LastDate       : integer;
  aMsg           : string;
  BCode, CCode   : String[3];
  ForeignCurrency: Boolean;
  Rate           : Extended;
  Msg            : String;
begin
  result := false;
  LogMsg( lmInfo, Unitname, 'Importing Update file ' + filename);

  DiskImage := TUpdateDiskReader.Create;
  try
    //load update file
    try
      DiskImage.LoadFromUpdateFile( Filename);
      DiskImage.Validate;
    except
      On E : Exception do begin
        aMsg := 'Error verifying update disk ' + filename + ' ' + E.Message +
                ' [' + E.Classname + ']';
        HelpfulErrorMsg( aMsg, 0);
        Exit;
      end;
    end;

    DiskAccount := DiskImage.dhAccount_List.Disk_Bank_Account_At(0);
    //check bank account details
    BankAccount := MyClient.clBank_Account_List.FindCode( DiskAccount.dbFields.dbAccount_Number);
    if not Assigned( BankAccount) then
    begin
{$IFDEF ADD_IN_UPDATE}
      //account not found, create one
      BankAccount := TBank_Account.Create(MyClient);
      with BankAccount.baFields do
      begin
        baAccount_Type        := btBank;
        baBank_Account_Number := DiskAccount.dbFields.dbAccount_Number;
        baBank_Account_Name   := DiskAccount.dbFields.dbAccount_Name;
        baDesktop_Super_Ledger_ID := -1;
        baCurrent_Balance     := UNKNOWN;
      end;

      !! Do we have a currency code in the update file?

      if ( BankAccount.baFields.baCurrency_Code = '' ) then
        BankAccount.baFields.baCurrency_Code := MyClient.clExtra.ceLocal_Currency_Code;

      //insert new bank account in the list of accounts
      MyClient.clBank_Account_List.Insert( BankAccount);
{$ELSE}
      //account not found, log error
      raise Exception.Create( 'Bank Account not found ' + DiskAccount.dbFields.dbAccount_Number);
{$ENDIF}
    end;

    BCode := BankAccount.baFields.baCurrency_Code;
    CCode := MyClient.clExtra.ceLocal_Currency_Code;
    ForeignCurrency := BankAccount.IsAForexAccount;
//    if ForeignCurrency and ( BankAccount.baForex_Info = NIL  ) then With MyClient.clFields, BankAccount.baFields do
//    Begin { We check for a valid source before allowing the user to retrieve transactions }
//      Msg := Format( 'Client %s, Bank Account %s : Unable to find an exchange rate currency data source for converting %s to %s with the description %s (%s)',
//        [ clCode, baBank_Account_Number, BCode, CCode, baDefault_Forex_Description, baDefault_Forex_Source ] );
//      LogUtil.LogMsg( lmError,UnitName, ThisMethodName + ' : ' + Msg );
//      Raise Exception.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
//    End;

    //create a temporary transaction list
    TempTransList := TTransaction_List.Create( MyClient, BankAccount, MyClient.ClientAuditMgr );
    try
      for dTNo := DiskAccount.dbTransaction_List.First to DiskAccount.dbTransaction_List.Last do
      begin
        DiskTxn := DiskAccount.dbTransaction_List.Disk_Transaction_At( dtNo);
        pT := TempTransList.New_Transaction;
        pT^.txType              := DiskTxn^.dtEntry_Type;
        pT^.txSource            := BKCONST.orBank;
        pT^.txDate_Presented    := DiskTxn.dtEffective_Date;
        pT^.txDate_Effective    := DiskTxn.dtEffective_Date;
        pT^.txReference         := DiskTxn.dtReference;

//        if ForeignCurrency then
//        Begin
//          pT.txForeign_Currency_Amount := DiskTxn.dtAmount;
//          Rate   := BankAccount.baForex_Info.Rate( BCode, CCode, pT.txDate_Presented );
//          if Rate <> 0.0 then
//            pT.txAmount := Round( pT.txForeign_Currency_Amount / Rate )
//          else
//            pT.txAmount := 0;
//          pT.txForex_Conversion_Rate   := Rate;
//        End
//        else
          pT.txAmount             := DiskTxn.dtAmount;
          
        pT^.txCheque_Number     := 0;
        pT^.txSF_Member_Account_ID:= -1;
        pT^.txSF_Fund_ID          := -1;

        pT^.txStatement_Details := DiskTxn.dtNarration;

        if DiskTxn.dtQuantity <> Unknown then
          pT^.txQuantity := DiskTxn.dtQuantity;

        //construct the cheque number from the reference field
        case MyClient.clFields.clCountry of
          whAustralia, whUK : begin
            if (pT^.txType = 1) then begin
              S := Trim( pT^.txReference);
              //cheque no is assumed to be last 6 digits
              if Length( S) > MaxChequeLength then
                S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

              pT^.txCheque_Number := Str2Long( S);
            end;
          end;

          whNewZealand : begin
            if (pT^.txType in [0,4..9]) then begin
              S := Trim( pT^.txReference);
              //cheque no is assumed to be last 6 digits
              if Length( S) > MaxChequeLength then
                S := Copy( S, (Length(S) - MaxChequeLength) + 1, MaxChequeLength);

              pT^.txCheque_Number := Str2Long( S);
            end;
          end;
        end;

        //set country specific fields
        case MyClient.clFields.clCountry of
          whAustralia : begin
            pT^.txParticulars := DiskTxn.dtBank_Type_Code_OZ_Only;
          end;
          whNewZealand : begin
            pT^.txParticulars := DiskTxn.dtParticulars_NZ_Only;
            pT^.txOther_Party := DiskTxn.dtOther_Party_NZ_Only;
            //the analysis column is padded to 12 char to maintain
            //compatibility
            pT^.txAnalysis    := GenUtils.PadStr( DiskTxn.dtAnalysis_Code_NZ_Only, 12, ' ');
            pT^.txOrigBB      := DiskTxn.dtOrig_BB;
            //construct statement details if they are missing
            //this should only happen for transaction import by old production code
            if ( pT^.txStatement_Details = '') and (( pT^.txOther_Party <> '') or ( pT^.txParticulars <> '')) then
            begin
              pT^.txStatement_Details := MakeStatementDetails( BankAccount.baFields.baBank_Account_Number,
                                                               pT^.txOther_Party, pT^.txParticulars);
            end;
          end;
        end;

        pT^.txGL_Narration      := pT^.txStatement_Details;

        //insert new transaction into list
        TempTransList.Insert_Transaction_Rec( pT);
      end;

      //merge temp transactions into new list
      InsTranListToBankAcct( MyClient,
                             BankAccount,
                             TempTransList,
                             true,
                             NoOfEntries,
                             FirstDate,
                             LastDate);

      //delete pointers from temp list so that they are not removed when free list
      TempTransList.DeleteAll;
    finally
      TempTransList.Free;
    end;
  finally
    DiskImage.Free;
  end;

  //report outcome to user
  result := true;

  aMsg := 'Imported ' + inttostr( NoOfEntries) +
          ' entries from ' + bkDate2Str( FirstDate) +
          ' to ' + bkDate2Str( LastDate) +
          ' into account ' + BankAccount.baFields.baBank_Account_Number;

  LogMsg( lmInfo, Unitname, aMsg);
  HelpfulInfoMsg( 'Import Update File complete.'#13#13 + aMsg, 0);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ImportUpdateFile(Filename: string) : boolean;
begin
  MsgBar('Importing Update File '+Filename,true);
  try
    result := ImportUpdateFileEx( Filename);
  finally
    MsgBar('',false);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ShowUpdateFileInListBox( const fileName : string; var Account : string;
                                  var DateFrom, DateTo : integer;
                                  var Status : byte) : boolean;
var
  BankAccount : TBank_Account;
  i           : integer;
  DiskImage   : TUpdateDiskReader;
begin
  result := false;
  Status := 0;

  DiskImage := TUpdateDiskReader.Create;
  try
    try
      DiskImage.LoadFromUpdateFile( Filename);
      DiskImage.Validate;
    except
      On E : Exception do
      begin
        LogMsg( lmError, Unitname, 'Error verifying update disk ' + filename +
                                   ' ' + E.Message + ' [' + E.Classname + ']');
        //still allow to be shown in list
        status := usErrorInFile;
        result := true;
        Exit;
      end;
    end;

    //update files contain 1 and only 1 bank account
    Account   := DiskImage.dhAccount_List.Disk_Bank_Account_At(0).dbFields.dbAccount_Number;
    DateFrom  := DiskImage.dhFields.dhFirst_Transaction_Date;
    DateTo    := DiskImage.dhFields.dhLast_Transaction_Date;

    //check that country is correct
    if ( MyClient.clFields.clCountry <> DiskImage.dhFields.dhCountry_Code) then
      Exit;

    //check that bank account exists in client file
    BankAccount := MyClient.clBank_Account_List.FindCode(Account);
    if Assigned(BankAccount) then
    begin
      //check that transactions are in a valid range
      for i := 0 to Pred( BankAccount.baTransaction_List.ItemCount ) do
        with BankAccount.baTransaction_List.Transaction_At(i)^ do
          if ( txDate_Presented >= DateFrom ) and ( txDate_Presented <= DateTo ) then
          begin
            Status := usInvalidDates;
            result := true;
            exit;
          end;

//      if BankAccount.IsAForexAccount then
//      Begin
//        if ( BankAccount.baFields.baDefault_Forex_Source = '' ) then
//        Begin
//          Status := usNoForexSource;
//          result := true;
//          exit;
//        End;
//        if BankAccount.baForex_Info = NIL then
//        Begin
//          Status := usNoForexSource;
//          result := true;
//          exit;
//        End;
//        if DateTo > BankAccount.baForex_Info.ToDate then
//        Begin
//          Status := usForexRatesNeedUpdating;
//          result := true;
//          exit;
//        End;
//      End;
      //all ok
      Status := usOKtoImport;
      result := true;
    end
    else
    begin
{$IFDEF ADD_IN_UPDATE}
      Status := usOKtoImport;
      result := true;
{$ELSE}
      Status := usUnknownAccount;
      Exit;
{$ENDIF}
    end;
  finally
    DiskImage.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
