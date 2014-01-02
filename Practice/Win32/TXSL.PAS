UNIT TXSL;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Sorted Transaction List - hold pointers to transactions
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE USES
   bkdefs, ecollect, iostream, classes, trxlist32;

Type
   tSorted_Transaction_List = class( TExtdSortedCollection )
      Sort_Order : Byte;
      constructor    Create( ASort_Order : Byte ); reintroduce; overload; virtual;
      function       Compare( Item1, Item2 : pointer ) : integer; override;
      procedure      FreeItem( Item : Pointer ); override;
      function       Transaction_At( Index : Longint ) : pTransaction_Rec;
      function       GetTransCoreID_At( Index : longint ) : int64;
   end;
//******************************************************************************
IMPLEMENTATION
uses
   bktxio, bkdsio, tokens, LogUtil, bkutil32, sysutils, ststrs,appTime, globals,
   bkConst, GenUtils;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'TXSL';
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Constructor TSorted_Transaction_List.Create(ASort_Order : Byte);
const
  ThisMethodName = 'TSorted_Transaction_List.Create';
Begin                   { Sorted, AllowDups }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   Sort_Order := ASort_Order;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TSorted_Transaction_List.Compare( Item1, Item2 : pointer ) : integer;
var
   Key1, Key2 : ShortString;
Begin
   if Sort_Order = csAccountCodeXLON then
   begin
     //special case for xlon sorting
     Key1 := Uppercase( pTransaction_Rec( Item1)^.txAccount);
     Key2 := Uppercase( pTransaction_Rec( Item2)^.txAccount);
     Result := XlonSort( Key1, Key2);
     if (Result = 0) then
     begin
       if (pTransaction_Rec(Item1).txSequence_No > pTransaction_Rec(Item2).txSequence_No) then
         Result := 1
       else
         Result := -1;
     end;
   end else
   begin
     //use normal sorting
     Key1 := BKUTIL32.MakeSortKey( pTransaction_Rec(Item1), Sort_Order );
     Key2 := BKUTIL32.MakeSortKey( pTransaction_Rec(Item2), Sort_Order );
     result := CompStrings(Key1,Key2);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TSorted_Transaction_List.FreeItem( Item : Pointer );
Begin
   { Do Nothing, this list doesnt dispose of pointer, the pointer belong
     to the main transaction list!}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TSorted_Transaction_List.Transaction_At( Index : Longint ) : pTransaction_Rec;
const
  ThisMethodName = 'TSorted_Transaction_List.Transaction_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   If BKTXIO.IsATransaction_Rec( P ) then
      Transaction_At := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSorted_Transaction_List.GetTransCoreID_At( Index : longint ) : int64;
begin
  Result := BKUTIL32.GetTransCoreID(Transaction_At(Index));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.


