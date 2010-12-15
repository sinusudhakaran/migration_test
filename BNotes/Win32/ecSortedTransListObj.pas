unit ECSortedTransListObj;
//------------------------------------------------------------------------------
{
   Title:       Sorted Transaction List Object

   Description: A sorted list of transaction pointers.

   Remarks:     An item is never freed from the sorted items list because
                free will be handled by the
                normal transaction list  ( EcTransactionListObj);

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface
uses
   ecdefs, ecollect;

type
   tSorted_Transaction_List = class (TExtdSortedCollection)
      Country: Byte;
      Sort_Order: Byte;
      constructor Create( ACountry, ASort_Order : Byte );
      function    Compare( Item1, Item2 : pointer ): Integer; override;
      procedure   FreeItem( Item : Pointer ); override;
      function    Transaction_At( Index : LongInt ): pTransaction_Rec;
   public
      function    MakeSortKey(P : pTransaction_Rec): string;
   end;

//******************************************************************************
implementation
uses
   stStrs,
   ectxio,
   bkconst,
   KeyUtils,
   SysUtils;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ tSorted_Transaction_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSorted_Transaction_List.Compare(Item1, Item2: pointer): Integer;
var
  Key1, Key2: ShortString;
begin
  Key1   := MakeSortKey( pTransaction_Rec( Item1 ) );
  Key2   := MakeSortKey( pTransaction_Rec( Item2 ) );
  Result := CompStrings( Key1, Key2 );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSorted_Transaction_List.Create(ACountry, ASort_Order: Byte);
begin
  Inherited Create;
  Duplicates := false;
  Country    := ACountry;
  Sort_Order := ASort_Order;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSorted_Transaction_List.FreeItem(Item: Pointer);
begin
   //Do nothing,  delete handled by main list
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSorted_Transaction_List.MakeSortKey(P: pTransaction_Rec): string;
var
  Code: BK5CodeStr;

  Const
     SUnknownCountry = 'tSorted_Transaction_List.MakeSortKey : Unknown Country %d';

     // --------------------------------------------------------------------------
     Function NZSortByChequeNoKey : ShortString;
     Begin
        With P^ do
        Begin
           If txCheque_Number > 0 then
              Result  := Int32ToKey( txBank_Seq ) + ByteToKey( 1 ) + Int32ToKey( txCheque_Number ) + Int32ToKey( txAuto_Sequence_No )
           else
           If ( txType = 15 ) then { Automatic Payments }
              Result  := Int32ToKey( txBank_Seq ) +  ByteToKey( 2 ) +
                         ExtToKey( txAmount ) + Int32ToKey( txDate_Effective ) +
                         Int32ToKey( txAuto_Sequence_No ) {23}
           else
              Result  := Int32ToKey( txBank_Seq ) + ByteToKey( 3 ) + Int32ToKey( txAuto_Sequence_No ); {9}
        end;
     end;
     // --------------------------------------------------------------------------
     Function OZSortByChequeNoKey : ShortString;
     Begin
        With P^ do
        Begin
           If txCheque_Number > 0 then
              Result  := Int32ToKey( txBank_Seq ) + ByteToKey( 1 ) + Int32ToKey( txCheque_Number ) + Int32ToKey( txAuto_Sequence_No )
           else
           If ( txType = 3 ) then { Automatic Payments }
              Result  := Int32ToKey( txBank_Seq ) +  ByteToKey( 2 ) +
                         ExtToKey( txAmount ) + Int32ToKey( txDate_Effective ) +
                         Int32ToKey( txAuto_Sequence_No ) {23}
           else
              Result  := Int32ToKey( txBank_Seq ) + ByteToKey( 3 ) + Int32ToKey( txAuto_Sequence_No ); {9}
        end;
     end;
     // --------------------------------------------------------------------------
     Function UKSortByChequeNoKey : ShortString;
     Begin
        With P^ do
        Begin
           If txCheque_Number > 0 then
              Result  := Int32ToKey( txBank_Seq ) + ByteToKey( 1 ) + Int32ToKey( txCheque_Number ) + Int32ToKey( txAuto_Sequence_No )
           else
           If ( txType = 3 ) then { Automatic Payments }
              Result  := Int32ToKey( txBank_Seq ) +  ByteToKey( 2 ) +
                         ExtToKey( txAmount ) + Int32ToKey( txDate_Effective ) +
                         Int32ToKey( txAuto_Sequence_No ) {23}
           else
              Result  := Int32ToKey( txBank_Seq ) + ByteToKey( 3 ) + Int32ToKey( txAuto_Sequence_No ); {9}
        end;
     end;

begin
  { Can now return a String up to 32 characters }
  With P^ do Begin
     Case Sort_Order of
        csDateEffective : Result :=
           Int32ToKey( txBank_Seq ) +
           Int32ToKey( txDate_Effective ) +
           Int32ToKey ( txAuto_Sequence_No ); { 12 }

        csChequeNumber  : Case Country of
                             whNewZealand : Result := NZSortByChequeNoKey;
                             whAustralia  : Result := OZSortByChequeNoKey;
                             whUK         : Result := UKSortByChequeNoKey;
                          end;

        csDatePresented : Result :=
           Int32ToKey( txBank_Seq ) +
           Int32ToKey( txDate_Presented ) +
           Int32ToKey ( txAuto_Sequence_No ); {12}

        csAccountCode   :
           Begin
              If ( txFirst_Dissection<>NIL ) then
                 Code := CharStrS( #254, MaxBK5CodeLen )
              else
                 Code := PadChS( txAccount, ' ', MaxBk5CodeLen ); { Pad out to fill the field }
              Result := Code + Int32ToKey( txDate_Effective ) +
                               Int32ToKey( txBank_Seq ) +
                               Int32ToKey( txAuto_Sequence_No ); {32}
           end;

        csByValue : Result := Int32ToKey( txBank_Seq ) +
                              ExtToKey( txAmount ) +
                              Int32ToKey( txDate_Effective ) +
                              Int32ToKey( txAuto_Sequence_No ); {22}

        csByNarration :
           Begin
              Code := UpperCase( Copy( txNarration, 1, MaxBk5CodeLen ) );
              Code   := PadChS( Code, ' ', MaxBk5CodeLen ); { Pad out to fill the field }
              Result := Int32ToKey( txBank_Seq ) +
                        Code +
                        Int32ToKey( txDate_Effective ) +
                        Int32ToKey( txAuto_Sequence_No ); {32} {was 22}
           end;
     end;  //case
  end; //with
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSorted_Transaction_List.Transaction_At( Index: Integer): pTransaction_Rec;
var
  P: Pointer;
begin
  Result := nil;
  P := At( Index );
  If ECTXIO.IsATransaction_Rec( P ) then Result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
