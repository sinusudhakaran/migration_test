unit Outstand;
//------------------------------------------------------------------------------
{
   Title:       Outstand

   Description: Unpresented Items Unit

   Remarks:

   Author:      Major Changes by Matthew Hopkins Jan 2001

}
//------------------------------------------------------------------------------

interface

uses
   baObj32, ueList32;

function AddUnpresentedCheques (BA : TBank_Account; FromDate, ToDate : LongInt ): Boolean;
function AddInitialCheques     (BA : TBank_Account; FromDate, ToDate : LongInt ): Boolean;
function AddOutstandingDeposits(BA : TBank_Account; FromDate, ToDate : LongInt; IsInitial: Boolean = False  ): Boolean;
function AddOutstandingWithdrawals(BA : TBank_Account; FromDate, ToDate : LongInt; IsInitial: Boolean = False  ): Boolean;
function DeleteChequeRange     (BA : TBank_Account; DeleteList : TSeqList; FromDate, ToDate : integer ): Boolean;

//******************************************************************************
implementation

uses
   Controls,
   Forms,
   Graphics,
   SysUtils,
   unCheqDlg,
   bkDateUtils,
   bkutil32,
   bkdefs,
   ovcDate,
   InfoMoreFrm,
   YesNoDlg,
   globals,
   bkTXio,
   bkConst,
   InitcheqDlg,
   OutDepositDlg,
   DelUnCheqdlg,
   GenUtils,
   BaUtils,
   LogUtil,
   dxList32,
   SuggestedMems,
   TransactionUtils;

const
   UnitName = 'OUTSTAND';
var
   DebugMe : boolean = false;

//------------------------------------------------------------------------------

Procedure FindCheques( BA : TBank_Account; ChqList : TSeqList );
//Searchs all transaction in account for transactions with a cheque no
//called by AddUnpresented and AddInitial
Var
   i        : LongInt;
   T        : LongInt;
   Number   : LongInt;
   PSI      : pSeqInfo;
   Transaction : pTransaction_rec;
Begin
   With BA.baTransaction_List do For T := 0 to Pred( itemCount ) do
   Begin
      Transaction := Transaction_At( T );
      Number := GetChequeNo( Transaction);
      If Number > 0 then With Transaction^ do Begin
         If DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'FindCheques, Looking for No '+IntToStr( Number ) );

         For i := 0 to Pred( ChqList.ItemCount ) do Begin
            PSI := ChqList.SeqInfo_At(i);
            With PSI^ do If ( psNo = Number ) then Begin
               If DebugMe then LogUtil.LogMsg( lmDebug, UnitName, 'Found on '+bkDate2Str( txDate_Effective ) );
               If ( psPTR = NIL ) then { we haven't found this already }
               Begin
                  peDate         := txDate_Effective;
                  ppDate         := txDate_Presented;
                  psTransferred  := ( txDate_Transferred <> 0 );
                  psPTR          := Transaction;
               end;
            end;
         end;
      end;
   end;
end;
//------------------------------------------------------------------------------

Function AddUnpresentedCheques( BA : tBank_Account; FromDate, ToDate : LongInt ): Boolean;
{
   Calls    :  UNCHEQDLG.PAS
   Called by:  CODINGFRM.PAS

   Allows user to add cheques into the current period by adding a new chq or by
   moving and existing cheque.
   Allows users to move a cheque back into its original period and reinstate the
   original bank entry.

   Note:  entries which link to a reversing entry cannot be moved!

   FromDate and ToDate refer to the current coding period
}
var
  MyDlg       : TdlgUnCheque;
  DataArray   : tUnChqArray;
  SeqList     : TSeqList;
  ps          : pSeqInfo;
  range, i    :integer;
  Number      : integer;
  AddCount    : integer;
  MoveCount   : integer;
  Transaction, TmpTx : pTransaction_Rec;
  S           : String;
  TransOrLockedCount: integer;
  ToDay, ToMonth, ToYear, T : Integer;
  Found : Boolean;
  NewDate : LongInt;
  Rate : Double;
  BCode, CCode : String[3];
begin
  result := false;
  FillChar(DataArray,SizeOf(DataArray),#0);

  MyDlg := TdlgUnCheque.Create(Application.MainForm);
  try
    {$IFDEF SmartBooks}

    !! Need to make change in coding form to complete the UPI changes.

    S := Format( 'You are working with Account'#13+
                 '%s'#13'%s'#13#13+
                 'Enter the ranges of cheque numbers which were issued during %s',
                 [ BA.baFields.baBank_Account_Number,
                   BA.baFields.baBank_Account_Name,
                   GetMonthName(FromDate) ] );
    MyDlg.lblCodingRange.caption := S;
    {$ELSE}
    S := bkDate2Str( FromDate) + ' - ' + bkDate2Str( ToDate);
    MyDlg.lblCodingRange.Caption := S;
    MyDlg.lblChequesDate.caption := bkDate2Str( ToDate);

    //check to see if there are bank transaction within the same month as the ToDate
    //Date of last transaction - count back from end of list, find last orBank
    Found := False;
    with BA.baTransaction_List do
    begin
      i := ItemCount - 1;
      while (i > 0) and (not Found) do
      begin
        Transaction := Transaction_At( i );
        if (Transaction.txType = orBank) then
          //found the last bank transaction
          Found := True
        else
          Dec(i);
      end;
    end;
    //Label should be red if the date of the last bank transaction is earlier than
    //the first day of the month of the To Date
    if (Found) then
    begin
      StDatetoDMY( ToDate, ToDay, ToMonth, ToYear );
      NewDate := DMYToStDate(1, ToMonth, ToYear, EPOCH);
      if (Transaction.txDate_Effective < NewDate) then
      begin
        MyDlg.pnlChequeDate.BevelOuter := bvRaised;
        MyDlg.lblChequesDate.Font.color := clRed;
      end else
      begin
        MyDlg.pnlChequeDate.BevelOuter := bvNone;
        MyDlg.lblChequesDate.Font.color := clWindowText;
      end;
    end else
    begin
      MyDlg.pnlChequeDate.BevelOuter := bvNone;
      MyDlg.lblChequesDate.Font.color := clWindowText;
    end;

    {$ENDIF}

    //fill the existing cheques box.  this could be a frame that is passed
    //the bank account and the date range.
    MyDlg.fmeCheques.Fill( BA, FromDate, ToDate);

    if not MyDlg.Execute(@DataArray) then exit;
  finally
    MyDlg.Free;
  end;

  {now have a valid array of cheque ranges}
  SeqList := TSeqList.Create;
  try
    for range := 1 to MaxUnChq do with DataArray[Range] do
    if (sn1<>0) and (sn2<>0) then begin
      LogUtil.LogMsg( lmInfo, UnitName, 'Entered UPC Cheque Range '+inttostr(sn1)+'-'+inttostr(sn2) +
                                        ' period ' + bkDate2str( FromDate) + '-' + bkDate2Str( ToDate));
      for i := sn1 to sn2 do begin
        ps := NewSeqInfo(i);
        if Assigned(ps) then SeqList.insert(ps);
      end;
    end;

    //Look for existing cheques in the bank account that cheque number in range
    FindCheques(BA,SeqList);
    AddCount     := 0;
    MoveCount    := 0;
    TransOrLockedCount := 0;

    for i := 0 to pred(SeqList.ItemCount) do begin
       with SeqList.SeqInfo_At(i)^ do
          if (psPtr = nil) then begin
            inc(AddCount)      {cheque not found}
          end
          else begin
             //make sure is not locked or transfered or linked to a reversing entry
             if ( psTransferred) or ( psPtr^.txLocked) then begin
                Inc( TransOrLockedCount);
                Continue;
             end;
             if ( psPtr^.txUPI_State in [ upReversedUPC, upReversalOfUPC]) then Continue;

             case CompareDates(ppDate,FromDate,ToDate) of
                None    : if ( peDate <> ToDate) then Inc( MoveCount);
                Earlier : ;
                Within  : if (peDate <> ppDate) then Inc(MoveCount);
                Later   : Inc(MoveCount);
             end;
          end;
    end;
    //see how many cheques there are to add
    Number := AddCount + MoveCount;
    if ( Number = 0) then begin
       S := 'There are no cheques to add or move into the current period.';
       if ( TransOrLockedCount > 0) then
          S := S + #13#13+ 'They may have been transferred to your main accounting system, or be ' +
                           'part of a finalised period.';
       HelpfulInfoMsg( S, 0);
       exit;
    end;
    //confirm changes
    S := '';
    if AddCount > 0 then
       S := S + inttostr( AddCount) + ' cheque(s) will be added into the current period.'#13;
    if MoveCount > 0 then
       S := S + inttostr( MoveCount)+ ' cheque(s) will be moved into the current period.'#13;
    S := S + #13'Please confirm that you want to do this.';

    if AskYesNo('Add Unpresented Cheque(s)', S, DLG_NO, 0) = DLG_NO then exit;

    Rate := 0.0;
    if BA.IsAForexAccount then
    Begin
      BCode := BA.baFields.baCurrency_Code;
      CCode := MyClient.clExtra.ceLocal_Currency_Code;
//      Rate  := BA.baForex_Info.Rate( BCode, CCode, ToDate );
    end;

    //add transactions
    for i := pred(SeqList.ItemCount) downto 0 do with SeqList.SeqInfo_At(i)^ do begin
       number := psNo;
       if ( psPtr = nil) then begin
          //not there at all, so !! ADD !! the missing Cheques}
          Transaction := BA.baTransaction_List.New_Transaction;
          with Transaction^ do begin
             txType := BKConst.whChequeEntryType[ MyClient.clFields.clCountry ];
             txSource         := orGenerated;
             txDate_Effective := ToDate;

             if BA.IsAForexAccount then
             Begin
               txForex_Conversion_Rate := Rate;
             End;

             txCheque_Number  := number;
             txReference      := inttostr( number);
             txBank_Seq       := BA.baFields.baNumber;
             txUPI_State      := upUPC;
             txSF_Member_Account_ID:= -1;
             txSF_Fund_ID          := -1;
          end;    // with
          BA.baTransaction_List.Insert_Transaction_Rec(Transaction);

          if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'AddOut: Adding '+transaction^.txReference);
       end
       else begin
         //skip cheques which are transferred, locked, or all reversing
         if ( psTransferred) then Continue;
         if ( psPtr^.txLocked) then Continue;
         if ( psPtr^.txUPI_State in [ upReversedUPC, upReversalOfUPC]) then Continue;

         //a matching cheque has been found which should be MOVED!!!
         Transaction := psPtr;
         //remove transaction from the list so that we can change the effective date
         BA.baTransaction_List.Delete(Transaction);
         with Transaction^ do begin
            txBank_Seq := ba.baFields.baNumber;
            case CompareDates( txDate_Presented, FromDate, ToDate ) of
              None: begin
                 //The cheque exists, but has not been presented yet.  It can be moved to
                 //this period.
                 if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'AddOut: None '+txReference+' date from '+ bkDate2Str(txDate_Effective)+' to '+bkDate2Str(ToDate));
                 txDate_Effective := ToDate;
              end;

              Earlier : begin
                 //It was presented prior to the FromDate, so do nothing
              end;

              Within: begin
                 //Cheque exists in the current period, both pres date and eff
                 //are in current period so move cheque back to original date
                 if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'AddOut: Within '+txReference+' date from '+ bkDate2Str(txDate_Effective)+' to '+bkDate2Str(ToDate));
                 txDate_Effective := txDate_Presented;

                 //see if was matched upc
                 case txUPI_State of
                    upMatchedUPC : begin
                       //can change back to a normal transaction as long as chq no same
                       if txCheque_Number = txOriginal_Cheque_Number then begin
                          txSource := txOriginal_Source;
                          txType   := txOriginal_Type;

                          if txMatched_Item_ID = 0 then
                             txUPI_State := upNone
                          else
                             txUPI_State := upBalanceOfUPC;
                       end
                       else begin
                          //leave a matched upc
                          ;
                       end;
                    end;
                    upBalanceOfUPC : begin
                       //only need to change date, cheq no same so user will need
                       //to delete to get back to original state
                       ;
                    end;
                 end;
              end;

              Later: begin
                 // Has been presented in a later period, so move it to the last day of the period.
                 If DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'AddOut: Later '+txReference+' date from '+ bkDate2Str(txDate_Effective)+' to '+bkDate2Str(ToDate));
                 //change the state of the item to upcMatched
                 txDate_Effective := ToDate;
                 if ( txUPI_State = upNone) then begin
                    //must be moving a cheque so need to store original details
                    txUPI_State          := upMatchedUPC;
                    //details are the same but need to store for use by
                    //DoDeleteTrans
                    txOriginal_Reference                := txReference;
                    txOriginal_Source                   := txSource;
                    txOriginal_Type                     := txType;
                    txOriginal_Cheque_Number            := txCheque_Number;
                    txOriginal_Amount                   := txAmount;
                    txOriginal_Forex_Conversion_Rate    := txForex_Conversion_Rate   ;
//                    txOriginal_Foreign_Currency_Amount  := txForeign_Currency_Amount ;
                 end;
                 // case 7678 - may of left behind a blank UPC so need to go through
                 // the tx list from this date to find it and delete it
                 // this is done before the re-insert so we won't find that record
                 T := 0;
                 With BA.baTransaction_List do
                    while (T < itemCount) do begin
                       TmpTx := Transaction_At(T);
                       if TmpTx.txDate_Effective < ToDate then
                         inc(T)
                       else
                         if (GetChequeNo( TmpTx) = Transaction.txCheque_Number)
                         and (TmpTx.txUPI_State in [upUPC, upUPD, upUPW])
                         and (TmpTx.txAmount = 0) then
                           BA.baTransaction_List.Delete(TmpTx)
                         else
                           inc(T);
                    end;

              end;

            end;    // case
         end;
         //reinsert transaction after changing the effective date
         BA.baTransaction_List.Insert_Transaction_Rec(Transaction);
       end; //cheque found
    end;
    LogUtil.LogMsg( lmInfo, UnitName,'Added ' + inttoStr( AddCount) + '  Moved ' + inttostr( MoveCount));
    result := true;
  finally
    SeqList.Free;
  end;
end;
//------------------------------------------------------------------------------

Function AddInitialCheques( BA : tBank_Account; FromDate, ToDate : LongInt ): Boolean;
{
   This is very similar to AddUnpresentedCheques except for the following

   - The cheques are added prior to the current coding period
   - Cheques can only be added or moved FROM later periods.  Cheques cannot be
     moved back to their original period.
}
var
  MyDlg        : TdlgInitCheq;
  DataArray    : tInitChqArray;
  SeqList      : TSeqList;
  ps           : pSeqInfo;
  i,j          :integer;
  S            : String;
  Number,
  AddCount,
  MoveCount,
  TransOrLockedCount : integer;
  Transaction  : pTransaction_Rec;

  ChqsEntered  : Boolean;
  found        : boolean;
  UseDate: LongInt;
  Rate : Double;
  BCode, CCode : String[3];
begin
  if FromDate - 1 < MinValidDate then
    UseDate := FromDate
  else
    UseDate := FromDate - 1;
  result := false;
  FillChar(DataArray,SizeOf(DataArray),#0);

  //show dialog for entering cheque numbers
  MyDlg := TdlgInitCheq.Create(Application.MainForm);
  try
     MyDlg.lblChequesDate.Caption := bkDate2Str( UseDate );
     MyDlg.fmeCheques.Fill( BA, FromDate, ToDate);
     if not MyDlg.Execute(@DataArray) then exit;
  finally
     MyDlg.Free;
  end;
  //check user something entered
  ChqsEntered := false;
  for i := 1 to Max_Init_Chq do if DataArray[i]<>0 then ChqsEntered := true;
  if not ChqsEntered then exit;


  SeqList := TSeqList.Create;
  try
    //create list of all cheque numbers entered
    for i := 1 to Max_Init_Chq do if DataArray[i]<>0 then
    begin
      found := false;
      for j := 0 to Pred(SeqList.ItemCount) do
        with SeqList.SeqInfo_At(j)^ do
          if (psNo = DataArray[i]) then found := true;

      if not Found then begin
         ps := NewSeqInfo(DataArray[i]);
         if assigned(ps) then SeqList.Insert(ps);
      end;
    end;
    //Look for matches with existing cheques, count which ones can be moved or added
    FindCheques(BA,SeqList);

    AddCount := 0;
    MoveCount := 0;
    TransOrLockedCount := 0;

    for i := 0 to pred(SeqList.ItemCount) do
       with SeqList.SeqInfo_At(i)^ do begin
          if (psPtr = nil) then begin
             //cheque not found
             inc(AddCount);
          end
          else begin
             //make sure is not locked or transfered or linked to a reversing entry
             if ( psTransferred) or( psPtr^.txLocked) then begin
                Inc(TransOrLockedCount);
                Continue;
             end;
             if ( psPtr^.txUPI_State in [ upReversedUPC, upReversalOfUPC]) then Continue;
             //see what date range presentation date is in
             case CompareDates(ppDate,UseDate, UseDate) of
                None    : if ( peDate <> ( UseDate)) then Inc( MoveCount);
                Earlier : ;
                Within  : ;
                Later   : Inc(MoveCount);
             end;
          end;
       end;

    Number := AddCount + MoveCount;
    if Number = 0 then begin
       S := 'There are no cheques to add or move to the prior period.';
       if (TransOrLockedCount >0) then
          S := S + #13#13+ 'They may have been transferred to your main accounting system, or be ' +
                           'part of a finalised period.';

       HelpfulInfoMsg( S, 0);
       exit;
    end;
    //confirm changes
    S := '';
    if AddCount > 0 then
       S := S + inttostr( AddCount) + ' cheque(s) will be added to the prior period.'#13;
    if MoveCount > 0 then
       S := S + inttostr( MoveCount)+ ' cheque(s) will be moved to the prior period.'#13;
    S := S + #13'Please confirm that you want to do this.';

    if AskYesNo('Add Initial Cheques', S, DLG_NO, 0) = DLG_NO then
       exit;

    Rate := 0.0;

    if BA.IsAForexAccount then
    Begin
      BCode := BA.baFields.baCurrency_Code;
      CCode := MyClient.clExtra.ceLocal_Currency_Code;
//      Rate  := BA.baForex_Info.Rate( BCode, CCode, UseDate );
    end;

    //add transactions
    for i := pred(SeqList.ItemCount) downto 0 do with SeqList.SeqInfo_At(i)^ do begin
      number := psNo;
      if psPtr = nil then begin  {not there at all}
         Transaction := BA.baTransaction_List.New_Transaction;
         with Transaction^ do begin
            txType := BKConst.whChequeEntryType[ MyClient.clFields.clCountry ];
            txSource         := orGenerated;
            txDate_Effective := UseDate;

            if BA.IsAForexAccount then
            Begin
              txForex_Conversion_Rate := Rate;
            End;

            txCheque_Number  := number;
            txReference      := inttostr( number);
            txBank_Seq       := ba.baFields.baNumber;
            txUPI_State      := upUPC;
            txSF_Member_Account_ID:= -1;
            txSF_Fund_ID          := -1;
         end;    // with
         BA.baTransaction_List.Insert_Transaction_Rec(Transaction);

         if Debugme then LogUtil.LogMsg(lmDebug,UnitName,'AddInit: Adding '+ Transaction^.txReference);
      end
      else begin
         //skip cheques which are transferred, locked, or all reversing
         if ( psTransferred) then Continue;
         if ( psPtr^.txLocked) then Continue;
         if ( psPtr^.txUPI_State in [ upReversedUPC, upReversalOfUPC]) then Continue;

         Transaction := psPtr;
         //remove and reinsert as we have changed the Effective Date
         Ba.baTransaction_List.Delete(Transaction);
         with Transaction^ do begin
            txBank_Seq       := ba.baFields.baNumber;
            case CompareDates( txDate_Presented, UseDate, UseDate) of
              None: begin
                 //The cheque exists, but has not been presented yet.  It can be moved to
                 //this period.
                 if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'AddInit: None '+txReference+' date from '+ bkDate2Str(txDate_Effective)+' to '+bkDate2Str(ToDate));
                 txDate_Effective := UseDate;
              end;

              Later: begin
                 // Has been presented in a later period, so move it to the last day of the period.
                 If DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'AddOut: Later '+txReference+' date from '+ bkDate2Str(txDate_Effective)+' to '+bkDate2Str(ToDate));
                 //change the state of the item to upcMatched
                 txDate_Effective := UseDate;
                 if ( txUPI_State = upNone) then begin
                    //must be moving a cheque so need to store original details
                    txUPI_State                         := upMatchedUPC;
                    txOriginal_Reference                := txReference;
                    txOriginal_Source                   := txSource;
                    txOriginal_Type                     := txType;
                    txOriginal_Cheque_Number            := txCheque_Number;
                    txOriginal_Amount                   := txAmount;
                    txOriginal_Forex_Conversion_Rate    := txForex_Conversion_Rate   ;
//                    txOriginal_Foreign_Currency_Amount  := txForeign_Currency_Amount ;
                 end;
              end;
            end;    // case
         end;
         //Reinsert Transaction into bank account
         ba.baTransaction_List.Insert_Transaction_Rec(Transaction);
      end;
    end;
    result := true;
  finally
     SeqList.Free;
  end;
end;
//------------------------------------------------------------------------------

function AddOutstandingDeposits( BA : tBank_Account; FromDate, ToDate : LongInt; IsInitial: Boolean = False ): Boolean;
//transaction is added from within TDlgDeposit
begin
   with TDlgDeposit.Create(Application.MainForm) do begin
      try
         result := Execute( BA, FromDate, ToDate, upUPD, IsInitial);
      finally
         Free;
      end;
   end;
end;
//------------------------------------------------------------------------------

function AddOutstandingWithdrawals( BA : tBank_Account; FromDate, ToDate : LongInt; IsInitial: Boolean = False ): Boolean;
//transaction is added from within TDlgDeposit
begin
   with TDlgDeposit.Create(Application.MainForm) do begin
      try
         result := Execute( BA, FromDate, ToDate, upUPW, IsInitial);
      finally
         Free;
      end;
   end;
end;
//------------------------------------------------------------------------------

function DeleteChequeRange(BA : TBank_Account; DeleteList : TSeqList; FromDate, ToDate : integer ): Boolean;
{
   Delete List contains ranges of Cheques to Delete.
   Only UNPRESENTED cheques are deleted

   DeleteList contains a list of cheque number entered.

   No checking of the date range is done.
}
var
   i,j                :integer;
   S                  : String;
   Number             : integer;
   CanDeleteCount     : integer;
   TransOrLockedCount : integer;
   Transaction        : pTransaction_Rec;
   DelCount           : integer;
   DeletedTrans: pDeleted_Transaction_Rec;
begin
  result := false;

  //Find cheques that matched the cheque numbers in the delete list
  With BA.baTransaction_List do For i := 0 to Pred( itemCount ) do Begin
     Transaction := Transaction_At( i );
     //look for matching cheques in date range only
     if ( Transaction^.txDate_Effective >= FromDate) and ( Transaction^.txDate_Effective <= ToDate) then begin
        Number := Transaction^.txCheque_Number;  //all upcs must have a cheque number
        If Number > 0 then begin
           With DeleteList do
              For j := 0 to Pred( ItemCount ) do
                 With DeleteList.SeqInfo_At(j)^ do
                    If ( psNo = Number ) then begin
                       If ( psPtr = NIL ) then Begin
                          psPtr    := Transaction;
                          peDate   := Transaction^.txDate_Effective;
                          ppDate   := Transaction^.txDate_Presented;
                          psTransferred  := ( Transaction^.txDate_Transferred <> 0 );
                       end;
                    end;
        end;
     end;
  end;
  //Look thru list to determine which cheques can be deleted
  CanDeleteCount   := 0;
  TransOrLockedCount   := 0;
  //PresentedCount   := 0;
  with DeleteList do begin
     for j := 0 to Pred( ItemCount ) do With DeleteList.SeqInfo_At(j)^ do begin
        //if matching cheque found
        if Assigned( psPtr) then begin
           if ( psTransferred or psPtr^.txLocked) then
              Inc( TransOrLockedCount)
           else
           if ( ppDate = 0 ) then
              Inc( CanDeleteCount)
           else
              ;//Inc( PresentedCount);
        end;
     end;
  end;
  //stop delete if contains transferred or finalised cheques
  If ( TransOrLockedCount > 0 ) then begin
     HelpfulInfoMsg( 'The cheque range contains cheques that have been transferred '+
                     'or finalised. '#13#13+
                     'You cannot delete a cheque range that contains transferred or finalised cheques.',0);
     exit;
  end;
  //see if anything to do
  If ( CanDeleteCount ) = 0 then begin
     HelpfulInfoMsg('There are no unpresented cheques within this cheque range that can be deleted.', 0 );
     exit;
  end;
  //confirm deletion
  S := IntToStr( CanDeleteCount) + ' unpresented cheque(s) will be deleted.'#13#13+
                           'Please confirm you want to do this.';
  If not (AskYesNo('Delete Unpresented Cheques', S, DLG_NO,0 )=DLG_YES ) then
     exit;

  //delete cheques
  DelCount := 0;
  With DeleteList do For j := 0 to Pred( ItemCount ) do begin
     With DeleteList.SeqInfo_At(j)^ do begin
        If ( psPtr <> nil) and ( ppDate=0) and ( not ( psTransferred or psPtr^.txLocked)) then
        begin
           if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'Delete '+ psPtr^.txReference);

           if RecordDeletedTransactionData(BA, psPtr) then
           begin
             DeletedTrans := Create_Deleted_Transaction_Rec(psPtr, CurrUser.Code);

             try
               SuggestedMem.UpdateAccountWithTransDelete(BA, psPtr);
               BA.baTransaction_List.DelFreeItem( psPtr );

               BA.baDeleted_Transaction_List.Insert(DeletedTrans);
             except
               Dispose_Deleted_Transaction_Rec(DeletedTrans);

               raise;
             end;
           end
           else
           begin
             SuggestedMem.UpdateAccountWithTransDelete(BA, psPtr);
             BA.baTransaction_List.DelFreeItem( psPtr );
           end;

           Inc( DelCount);
        end;
     end;
  end;
  result := true;

  logUtil.logMsg( lmInfo, UnitName, 'Deleted ' + inttostr( DelCount) + ' UPCs');
end;
//------------------------------------------------------------------------------

initialization
   DebugMe := DebugUnit(UnitName);
end.
