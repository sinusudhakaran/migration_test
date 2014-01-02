unit txul;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Unsorted Transaction List

  Written: 02/Sep/1999
  Authors: Andy, Matthew

  Purpose: Provides a list of transaction pointers which is unsorted.  This
     will be used by HistoricalTransDlg to preserve the order of transactions as they
     are entered.
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   bkdefs, ecollect;
type
   TUnSorted_Transaction_List = class( TExtdCollection )
      lastSeq   : integer;
      constructor Create; override;
   protected
      procedure FreeItem( Item : Pointer ); override;
   public
      function  Insert(Item : Pointer):integer; override;
      function  Transaction_At( Index : Longint ) : pTransaction_Rec;
      procedure Sort( ASort_Order : byte);
   end;
//******************************************************************************
implementation
uses
   bktxio,
   trxList32,
   Logutil,
   bkConst,
   txsl;

const
   DebugMe : Boolean = FALSE;
   UnitName = 'TXUL';
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TUnSorted_Transaction_List.Create;
begin
   inherited;
   LastSeq := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TUnSorted_Transaction_List.FreeItem( Item : Pointer );
begin
   Dispose_Transaction_Rec(pTransaction_Rec(item));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TUnSorted_Transaction_List.Transaction_At( Index : Longint ) : pTransaction_Rec;
const
  ThisMethodName = 'TUnSorted_Transaction_List.Transaction_At';
var
   P : Pointer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   if BKTXIO.IsATransaction_Rec( P ) then
      Transaction_At := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TUnSorted_Transaction_List.Insert(Item : Pointer):integer;
const
  ThisMethodName = 'TUnSorted_Transaction_List.Insert';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := -1;
   If BKTXIO.IsATransaction_Rec( Item ) then
   Begin
      //the sequence no is used to give the transactions a unique key so
      //that they can be inserted into a TSorted_Transaction_List
      Inc( LastSeq );
      pTransaction_Rec(Item)^.txSequence_No := LastSeq;
      result := Inherited Insert( Item );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TUnSorted_Transaction_List.Sort( ASort_Order: byte);
//sort the list by inserting all pointers into a sorted transaction list
//then delete all pointer (without Free) from the current list
//and reinsert in the order from the sorted trans list
var
   SortedTList : TSorted_Transaction_List;
   i           : integer;
begin
   SortedTList := TSorted_Transaction_List.Create( ASort_Order );
   try
      //insert into sorted list
      SortedTList.Duplicates := True;
      for i := 0 to Pred( ItemCount ) do
         SortedTList.Insert( Transaction_At(i));
      //empty current list, reset sequence no
      Self.DeleteAll;
      lastSeq := 0;
      //reinsert into list
      for i := 0 to Pred( SortedTList.ItemCount ) do
         Insert( SortedTList.Transaction_At(i));
   finally
      SortedTList.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

