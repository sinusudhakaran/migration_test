unit Traverse;

// SPA, 20-05-99
// This unit provides a means of traversing the bank accounts, accounts
// and dissections in a defined sort order.
// 

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate, BKCONST, BKDEFS, BAOBJ32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const
   twAllEntries            = 0;  twMin = 0;
   twAllUncoded            = 1;
   twAllNewEntries         = 2;
   twAllNewUncodedEntries  = 3;
   twAllPresentedEntries   = 4;
   twAllUnpresentedEntries = 5;
   twAllGSTUncoded = 6;           twMax = 6;

   csByGSTRate             = csMax + 1;

TYPE
   ProcPtr = Procedure;

Procedure SetOnAHProc        ( P : ProcPtr );
Procedure SetOnEHProc        ( P : ProcPtr );
Procedure SetOnDSProc        ( P : ProcPtr );
Procedure SetOnETProc        ( P : ProcPtr );
Procedure SetOnATProc        ( P : ProcPtr );

Var
   Transaction  : pTransaction_Rec;
//DN BGL360 - Not required   TransactionExtra : pTransaction_Extension_Rec;
   Dissection   : pDissection_Rec;
//DN BGL360 - Not required   DissectionExtra : pDissection_Extension_Rec;
   
   Bank_Account : TBank_Account;
   Traverse_From: TstDate;
   Traverse_To  : TstDate;

// Procedure SetBeforeSortProc  ( P : ProcPtr );
// Procedure SetOnSortProc      ( P : ProcPtr );
// Procedure SetAfterSortProc   ( P : ProcPtr );

Procedure SetSortMethod( Sequence : Byte );
Procedure SetSelectionMethod( Which : Byte );
Procedure SetIncludeZeroAmounts( Value : Boolean );
Procedure TraverseEntriesForAnAccount( const ABank_Account : TBank_Account; const FromDate, ToDate : TStDate );

// Procedure TraverseEntriesForAllAccounts( FromDate, ToDate : TStDate );
// Procedure TraverseEveryEntryForEveryAccount( FromDate, ToDate : TStDate );
// Procedure TraverseEntriesForJournalAccounts( FromDate, ToDate : TStDate );

Procedure Clear;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation 
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  LogUtil, GenUtils, Bk5Except, bkdbExcept,
  TransactionUtils,
  TravListLow, Globals, Bkutil32,
  SysUtils, CAUtils, MoneyDef;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'Traverse';
   DebugMe : Boolean = False;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

VAR
   SortMethod     : Byte;
   SelectWhich    : Byte;
   IncludeZeroAmounts : Boolean = True;

   OnAHProcPtr    : ProcPtr;
   OnEHProcPtr    : ProcPtr;
   OnDSProcPtr    : ProcPtr;
   OnETProcPtr    : ProcPtr;
   OnATProcPtr    : ProcPtr;

   BeforeSortProcPtr : ProcPtr;
   OnSortProcPtr  : ProcPtr;
   AfterSortProcPtr  : ProcPtr;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
procedure Clear;
Begin
   SortMethod         := 0;
   SelectWhich        := 0;
   IncludeZeroAmounts := True;
   OnAHProcPtr        := nil;
   OnEHProcPtr        := nil;
   OnDSProcPtr        := nil;
   OnETProcPtr        := nil;
   OnATProcPtr        := nil;
   Bank_Account       := nil;
   Transaction        := nil;
   Dissection         := nil;
   BeforeSortProcPtr  := nil;
   OnSortProcPtr      := nil;
   AfterSortProcPtr   := nil;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
Procedure SetOnAHProc ( P : ProcPtr ); Begin OnAHProcPtr := P; end;
Procedure SetOnEHProc ( P : ProcPtr ); Begin OnEHProcPtr := P; end;
Procedure SetOnDSProc ( P : ProcPtr ); Begin OnDSProcPtr := P; end;
Procedure SetOnETProc ( P : ProcPtr ); Begin OnETProcPtr := P; end;
Procedure SetOnATProc ( P : ProcPtr ); Begin OnATProcPtr := P; end;
Procedure SetBeforeSortProc   ( P : ProcPtr ); Begin BeforeSortProcPtr  := P; end;
Procedure SetOnSortProc       ( P : ProcPtr ); Begin OnSortProcPtr      := P; end;
Procedure SetAfterSortProc    ( P : ProcPtr ); Begin AfterSortProcPtr   := P; end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function SelectMe( CONST T : pTransaction_Rec ): Boolean;

Const
   ThisMethodName = 'SelectMe';
Var
   Msg : string;
Begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  Result := False;
  If not ( SelectWhich in [ twMin..twMax ] ) Then
  Begin
    Msg := 'SelectWhich out of Range';
    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
    Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
       Msg]);
  end ;

  With T^ do Case SelectWhich of
    twAllEntries            : Result := TRUE;
    twAllUncoded            : Result := BKUTIL32.IsUncoded(T);
    twAllNewEntries         : Result := ( txDate_Transferred = 0 );
    twAllNewUncodedEntries  : Result := ( txDate_Transferred = 0 ) and (BKUTIL32.IsUncoded(T));
    twAllPresentedEntries   : Result := ( txDate_Presented<>0 );
    twAllUnpresentedEntries : Result := ( txDate_Presented = 0 );
    twAllGSTUncoded         : Result := ( txDate_Transferred = 0 ) and (BKUTIL32.IsGSTUncoded(T));
  end;

  if Result then
    if not IncludeZeroAmounts then
       if HasZeroAmount(T) then
          Result := False; // Skip the Zero amount ones

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure SetSortMethod( Sequence : Byte );

Const
   ThisMethodName = 'SetSortMethod';
Var
   Msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   If not ( Sequence in [ csMin..csByGSTRate ] ) Then
   Begin
      Msg := 'Sequence out of Range';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;
   SortMethod := Sequence;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function MakeSortKey( const P : pTransaction_Rec ) : ShortString;

   //- - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                      
   (*function NZChequeKey : ShortString;
   Begin
      with P^ do Begin
         Case txType of
            0, 4..9 :
               NZChequeKey := LongToKey( txBank_Seq ) +
                              ByteToKey( 1 ) +
                              LongToKey( txCheque_Number ) +
                              LongToKey( txSequence_No ); {13}

            15 :
               NZChequeKey := LongToKey( txBank_Seq ) +
                              ByteToKey( 2 ) +
                              LongToKey( Trunc( txAmount ) ) +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No ); {17}

            else
               NZChequeKey := LongToKey( txBank_Seq ) +
                              ByteToKey( 3 ) +
                              LongToKey( txSequence_No ); {9}
         end; { of Case }
      end;
   end;*)

   //- - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   (*function OZChequeKey : ShortString;
   Begin
      with P^ do Begin
         Case txType of
            1: OZChequeKey := LongToKey( txBank_Seq ) +
                              ByteToKey( 1 ) +
                              LongToKey( txCheque_Number ) +
                              LongToKey( txSequence_No ); {13}

            3: OZChequeKey := LongToKey( txBank_Seq ) +
                              ByteToKey( 2 ) +
                              LongToKey( Trunc( txAmount ) ) +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No ); {17}
            else
               OZChequeKey := LongToKey( txBank_Seq ) +
                              ByteToKey( 3 ) +
                              LongToKey( txSequence_No ); {9}
         end; { of Case txType }
      end;
   end;*)

   //- - -  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   ThisMethodName = 'MakeSortKey';
Var
   Code     : Bk5CodeStr;
   Msg      : string;
Begin
   If not Assigned( MyClient) Then
   Begin
      Msg := 'MyClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;
   
   With P^ do
   Begin
      Case SortMethod of
         csDateEffective :
            MakeSortKey :=    LongToKey( txBank_Seq ) +
                              LongToKey( txDate_Effective ) +
                              LongToKey ( txSequence_No ); { 12 }

         csChequeNumber  :
            begin
               Case MyClient.clFields.clCountry of
                  whNewZealand :
                     Begin
                        Case txType of
                           0, 3..9 :
                             Result := //LongToKey( txBank_Seq ) +
                                       ByteToKey( 1 ) +
                                       LongToKey( txCheque_Number ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No ); {13}
                           else
                             Result := LongToKey( txBank_Seq ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No );

                        end; { of Case txType }
                     end;
                  whAustralia, whUK :
                     Begin
                        Case txType of
                           1 :
                             Result :=
                               //LongToKey( txBank_Seq ) +
                               ByteToKey( 1 ) +
                               LongToKey( txCheque_Number ) +
                               LongToKey( txDate_Effective ) +
                               LongToKey ( txSequence_No ); {13}
                           else
                             Result := LongToKey( txBank_Seq ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No );
                        end; { of Case txType }
                     end;
               end; { of Case fdCountry }

            end;

         csReference :
           Result := LongToKey( txBank_Seq ) +
                     GetFormattedReference( p) +
                     LongToKey( txDate_Effective ) +
                     LongToKey( txSequence_No );

         csDatePresented :
            MakeSortKey :=    LongToKey( txBank_Seq ) +
                              LongToKey( txDate_Presented ) +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No ); {12}

         csAccountCode   :
            Begin
               Code := txAccount;
               If ( txFirst_Dissection<>NIL ) then Code := 'þ';
               While Length( Code ) < MaxBk5CodeLen Do Code := Code + ' ';
               result := Code + { !! 42.50 }
                  LongToKey( txDate_Effective ) +
                  LongToKey( txBank_Seq ) +
                  LongToKey( txSequence_No ); {32}
            end;

         csByValue       :
            Begin
               MakeSortKey :=  LongToKey( txBank_Seq ) +
                               LongToKey( Trunc( txAmount ) ) +
                               LongToKey( txDate_Effective ) +
                               LongToKey( txSequence_No ); {16}
            end;

         csByNarration :
            Begin
               Code := Uppercase( Copy( txGL_Narration, 1, MaxBk5CodeLen ) );
               While Length( Code ) < MaxBk5CodeLen Do Code := Code + ' ';
               MakeSortKey :=    LongToKey( txBank_Seq ) +
                                 Code +
                                 LongToKey( txDate_Effective ) +
                                 LongToKey( txSequence_No ); {32}
            end;

         csByGSTRate :
            Begin
               MakeSortKey := ByteToKey( txGST_Class ) +
                              LongToKey( txBank_Seq ) +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No );
            end;
      else
         begin
            //if unknown sort then sort by date
            MakeSortKey :=    LongToKey( txBank_Seq ) +
                              LongToKey( txDate_Effective ) +
                              LongToKey ( txSequence_No ); { 12 }
         end;
      end; { of Case }
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure SetSelectionMethod( Which : Byte );

Const
   ThisMethodName = 'SetSelectionMethod';
Var
   Msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   If not ( Which in [ twMin..twMax ] ) Then
   Begin
      Msg := 'Selection Method out of Range';
      LogUtil.LogError( UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   end ;
   SelectWhich := Which;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure SetIncludeZeroAmounts( Value : Boolean );
Const
   ThisMethodName = 'SetIncludeZeroAmounts';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   IncludeZeroAmounts := Value;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TraverseAnEntry;

Const
   ThisMethodName = 'TraverseAnEntry';
Var
   Total : Money;
   Msg   : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with Transaction^ do
   Begin
      If Assigned( OnEHProcPtr ) then OnEHProcPtr ;

      If ( txFirst_Dissection<>nil ) and ( Assigned( OnDSProcPtr ) ) then
      Begin
         Total := 0;
         Dissection := txFirst_Dissection;
         While Dissection<>nil do with Dissection^ do
         Begin
            If ( Assigned( OnDSProcPtr ) ) then
              OnDSProcPtr ;

            Total := Total + dsAmount;
            Dissection := dsNext;
         end;
         if ( Total <> txAmount ) then
         Begin
            Msg := 'Total of Dissection Lines is Incorrect!';
            LogUtil.LogError( UnitName, ThisMethodName + ' : ' + Msg);
            Raise EDataIntegrity.CreateFmt('%s - %s : %s',
              [UnitName, ThisMethodName, Msg] );
         end;
      end;   
      if ( Assigned( OnETProcPtr ) ) then OnETProcPtr ;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure TraverseEntriesForAnAccount( const ABank_Account : TBank_Account; const FromDate, ToDate : TStDate );

Const
    ThisMethodName = 'TraverseEntriesForAnAccount';

Var
   TNo               : LongInt;
   SortedList        : TTraverseList;
   SortKey           : ShortString;
   OK                : Boolean;
   Item              : pTraverseItem;
   Balance           : Money;
   
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   Bank_Account  := ABank_Account;
   Traverse_From := FromDate;
   Traverse_To   := ToDate;

   with Bank_Account, baTransaction_List do
   Begin
      If Assigned( OnAHProcPtr ) then OnAHProcPtr ;

      If ( SortMethod = csDateEffective ) then
      Begin (* Don't bother sorting them, they are in index order *)
        Balance := Bank_Account.baFields.baCurrent_Balance;

        for TNo := Last downto First do
        begin
          Transaction := Transaction_at(TNo);
//DN BGL360 - Not required          TransactionExtra := GetExtraTransctionData;

          if (Balance <> Unknown) then
          begin
            if (Transaction^.txUPI_State in [upUPC,upReversedUPC,upReversalOfUPC, upUPD,upReversedUPD,upReversalOfUPD, upUPW,upReversedUPW,upReversalOfUPW]) then
            begin
              Balance := Balance + Transaction.txAmount;
            end;
          end;
        end;

        for TNo := Last downto First do
        begin
          Transaction := Transaction_at(TNo);
//DN BGL360 - Not required          TransactionExtra := GetExtraTransctionData;

          Transaction.txTemp_Balance := Balance;

          if (Balance <> Unknown) then
          begin
            Balance := Balance - Transaction.txAmount;
          end;
        end;

         for TNo := 0 to Pred( ItemCount ) do
         Begin
            Transaction := Transaction_At( TNo );
//DN BGL360 - Not required            TransactionExtra := GetExtraTransctionData;
            with Transaction^ do
            Begin
               if ( txDate_Effective >=FromDate ) and
                  ( txDate_Effective <=ToDate ) and
                  SelectMe( Transaction ) then TraverseAnEntry;
            end;
         end;
      end
      else
      begin { We need to sort the entries first }
         If Assigned( BeforeSortProcPtr ) then BeforeSortProcPtr;

         SortedList := TTraverseList.Create;

         Try
            for TNo := 0 to Pred( ItemCount ) do
            Begin
               Transaction := Transaction_At( TNo );
//DN BGL360 - Not required               TransactionExtra := GetExtraTransctionData;
               
               with Transaction^ do
               Begin
                  OK := False;

                  (* In DatePresented order, we need to select the entries based on
                  their Presentation Date *)

                  if ( SortMethod = csDatePresented ) then
                  Begin
                     If ( txDate_Presented >= FromDate ) and ( txDate_Presented <= ToDate ) then
                        OK := True;
                  end
                  else
                  begin (* Select them based on their effective date *)
                     if ( txDate_Effective >=FromDate ) and
                        ( txDate_Effective <=ToDate ) then OK := True;
                  end;

                  If OK and SelectMe( Transaction ) then
                  Begin
                     // If Assigned( OnSortProcPtr ) then OnSortProcPtr;
                     If ( SortMethod in [ csAccountCode, csByGSTRate ] ) and
                        ( Assigned( OnDSProcPtr ) ) and ( txFirst_Dissection<>nil ) then
                     Begin
                        Dissection := txFirst_Dissection;
                        while Dissection <> nil do with Dissection^ do
                        Begin
                           Case SortMethod of
                              csAccountCode :
                                 Begin
                                    SortKey := dsAccount;
                                    While Length( SortKey ) < MaxBk5CodeLen Do SortKey := SortKey + ' ';
                                    SortKey := SortKey + LongToKey( txDate_Effective )
                                                       + LongToKey( txSequence_No )
                                                       + LongToKey( dsSequence_No )
                                                       + 'D';
                                 end;

                              csByGSTRate :
                                 Begin
                                    SortKey := ByteToKey( dsGST_Class ) +
                                               LongToKey( txDate_Effective ) +
                                               LongToKey( txSequence_No ) +
                                               LongToKey( dsSequence_No );
                                 end;
                              end; { of Case }

                           SortedList.InsertData( Dissection, FALSE, SortKey );
                           Dissection := Dissection^.dsNext;
                        end;
                     end
                     else
                     Begin
                        SortKey := MakeSortKey( Transaction );
                        SortedList.InsertData( Transaction, True, SortKey );
                     end;
                  end;
               end;
            end;

            with SortedList do for TNo := 0 to Pred( ItemCount ) do
            Begin
               Item := SortedList.Items[ TNo ];
               With Item^ do
               Begin
                  If IsTrx then 
                  Begin
                     Transaction := Ptr;
                     TraverseAnEntry;
                  end
                  else
                  Begin
                     Dissection := Ptr;
                     Transaction := Dissection^.dsTransaction;
                     OnDSProcPtr;
                  end;
               end;
            end;
         
         finally
            SortedList.Free;
         end;
      end;
      if Assigned( OnATProcPtr ) then OnATProcPtr ;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
   
Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
