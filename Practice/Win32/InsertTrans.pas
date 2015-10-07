unit InsertTrans;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Insert Transactions

  Written:  07 Sep 1999
  Authors:  Matthew

  Purpose:  Takes a temporary transaction list and import its transactions
     into the transaction list of the specified bank account.

  Note: DOES NOT rely on the global MyClient object

  Is Called from ImportExtra.PAS (import update file)
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
   clObj32,
   baObj32,
   trxList32;

procedure InsTranListToBankAcct( aClient         : TClientObj;
                                 BankAccount     : TBank_Account;
                                 TempTransList   : TTransaction_List;
                                 DoAutoCode      : boolean;
                                 var NoOfEntries : integer;
                                 var FirstDate   : integer;
                                 var LastDate    : integer);

//******************************************************************************
implementation
uses
   ueList32,
   LogUtil,
   AutoCode32,
   bkDefs,
   bktxio,
   bkConst,
   moneydef,
   GenUtils;

const
   UnitName = 'InsertTrans';
var
   DebugMe : boolean = false;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure InsTranListToBankAcct( aClient         : TClientObj;
                                 BankAccount     : TBank_Account;
                                 TempTransList   : TTransaction_List;
                                 DoAutoCode      : boolean;
                                 var NoOfEntries : integer;
                                 var FirstDate   : integer;
                                 var LastDate    : integer);
{
 Insert transactions from a temporary transaction list into the specified bank account
 Builds a Unpresented Items list and attempts to match new transactions to UPI's
 Calls Autocode if DoAutocode parameter is specified

 Works for both NZ and OZ transactions

 Could be used in Offsite Download and Merge 32 when time permits

 Requires a client object that is used by AutoCode
}
const
   ThisMethodName = 'InsTranListToBankAcct';
var
  i              :integer;
  UEList         : tUEList;
  UE             : pUE;
  TempTransaction,
  NewTransaction : pTransaction_Rec;
  ForeignCurrency : Boolean;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  NoOfEntries := 0;
  FirstDate   := 0;
  LastDate    := 0;

  ForeignCurrency := BankAccount.IsAForexAccount;

//  if ForeignCurrency  then
//    UEList := MakeForeignCurrencyUEList( BankAccount )
//  else
    UEList    := MakeUEList( BankAccount );

  //create a unpresented items list to check new transactions against
  try
     for i := 0 to Pred(TempTransList.ItemCount) do begin
        TempTransaction := TempTransList.Transaction_At(i);

        //try to match upi against new transaction, if no match found then
        //import into the bank accounts transaction list.
        with TempTransaction^ do
        begin
          UE := NIL;
//          if ForeignCurrency then
//          begin
//            If (Assigned(UEList) and ( txCheque_Number <> 0 ) and ( txForeign_Currency_Amount <> 0 )) then
//              UE := UEList.FindUEByNumberAndAmount( txCheque_Number, txForeign_Currency_Amount );
//          end
//          else
          begin
            If (Assigned(UEList) and ( txCheque_Number <> 0 ) and ( txAmount <> 0 )) then
               UE := UEList.FindUEByNumberAndAmount( txCheque_Number, txAmount );
          end;
           //Make sure the UE item hasnt been matched since UElist was built
          if Assigned( UE) then
          begin
            if ( UE^.Presented <> 0) or ( UE^.Issued > TempTransaction^.txDate_Presented) then
              UE := nil;
          end;
        end;

        If Assigned( UE ) then With UE^ do begin
           //an unpresented cheque has been found that matches
           //both the amount and the cheque number.
           //update UPC to show that has been matched
           ptr^.txUPI_State          := upMatchedUPC;
           ptr^.txDate_Presented     := TempTransaction^.txDate_Effective;
           UE^.Presented             := TempTransaction^.txDate_Effective;
           ptr^.txOriginal_Reference := TempTransaction^.txReference;
           ptr^.txOriginal_Source    := TempTransaction^.txSource;
           ptr^.txOriginal_Type      := TempTransaction^.txType;
           ptr^.txOriginal_Amount    := TempTransaction^.txAmount;
           ptr^.txOriginal_Forex_Conversion_Rate    := TempTransaction^.txForex_Conversion_Rate   ;
//           ptr^.txOriginal_Foreign_Currency_Amount  := TempTransaction^.txForeign_Currency_Amount ;
           ptr^.txOriginal_Cheque_Number := TempTransaction^.txCheque_Number;
        end
        else begin
           NewTransaction :=  BankAccount.baTransaction_List.Setup_New_Transaction;
           With NewTransaction^ do Begin
              txType                     := TempTransaction.txType;
              txSource                   := TempTransaction.txSource;
              txDate_Presented           := TempTransaction.txDate_Presented;
              txDate_Effective           := TempTransaction.txDate_Effective;
              txDate_Transferred         := 0;

              txAmount                   := TempTransaction.txAmount;
              txQuantity                 := TempTransaction.txQuantity;
              txReference                := TempTransaction.txReference;
              txParticulars              := TempTransaction.txParticulars;
              txOrigBB                   := TempTransaction.txOrigBB;
              txOther_Party              := TempTransaction.txOther_Party;
              txCheque_Number            := TempTransaction.txCheque_Number;
              txAnalysis                 := TempTransaction.txAnalysis;
              txForex_Conversion_Rate    := TempTransaction.txForex_Conversion_Rate   ;
//              txForeign_Currency_Amount  := TempTransaction.txForeign_Currency_Amount ;

              txGL_Narration             := TempTransaction.txGL_Narration;
              txStatement_Details        := TempTransaction.txStatement_Details;

              txBank_Seq                 := BankAccount.baFields.baNumber;  //setbank account sequence no to current bank index
           end;

           with BankAccount do begin
              baTransaction_List.Insert_Transaction_Rec( NewTransaction );
              If ( baFields.baCurrent_Balance <> Unknown ) then
                 baFields.baCurrent_Balance := baFields.baCurrent_Balance + NewTransaction.txAmount;
           end;

           If ( FirstDate = 0 ) or (( FirstDate > 0 ) and ( NewTransaction.txDate_Effective < FirstDate )) then
                 FirstDate := NewTransaction.txDate_Effective;

           If ( NewTransaction.txDate_Effective > LastDate ) then
              LastDate := NewTransaction.txDate_Effective;

           Inc( NoOfEntries );
        end;
     end;  //of loop thru trxs
  finally
     UEList.Free;
  end;

  //Autocode the entries
  if DoAutoCode and ( NoOfEntries > 0 ) then begin
     if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' - AutocodeEntries');
     AutoCodeEntries( aClient, BankAccount,AllEntries, FirstDate, LastDate);
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
