unit TravListLow;

// Sorted Entry & Dissection List for the Traverse Unit
// SPA, 20-05-99

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses ECollect, Classes, BKDefs;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// If you alter this definitition, you must change the code in
// NewTraverseItem and FreeTraverseItem that calculates the memory
// required for the structure.

type
   pTraverseItem = ^tTraverseItem;
   tTraverseItem = Packed Record
      Ptr   : Pointer;
      IsTrx : Boolean;
      Key   : ShortString;
   end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Type
   TTraverseList = class( TExtdSortedCollection )
      constructor Create; override;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
   public
      procedure   InsertData( const APtr : pointer; const ATrx : boolean; const AKey : ShortString );
   end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses LogUtil, bk5except, StStrS, Globals, Malloc;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'TravListLow';   
   DebugMe : Boolean = False;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
function NewTraverseItem( const APtr : Pointer;
                          const ATrx : Boolean;
                          const AKey : ShortString ): pTraverseItem;

Const
   ThisMethodName = 'NewTravItem';
Var
   Len  : Word;                      
   Item : pTraverseItem;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Len := Ord( AKey[0] ) + Sizeof( char ) + SizeOf( Boolean ) + Sizeof( Pointer );
   SafeGetMem( Item, Len );
   if ( Item=nil ) then
   Begin
      if DebugMe then LogUtil.LogError( UnitName, ThisMethodName + ' Memory Allocation Failed' );
      Raise ENoMemoryLeft.Create( UnitName + ' Memory Allocation Failed in NewTravItem' );
   end;
   with Item^ do Begin
      Ptr     := APtr;
      IsTrx   := ATrx;
      Key     := AKey;
   end;
   Result := Item;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
                        
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure FreeTraverseItem( Item : pTraverseItem );

Const
   ThisMethodName = 'FreeTraverseItem';
Var
   Len  : Word;
   Msg  : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   If Item=NIL then
   Begin
      Msg := 'Item is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName, Msg ] );
   end;
   with Item^ do
   Begin
      Len := Ord( Key[0] ) + Sizeof( Char ) + Sizeof( Boolean ) + Sizeof( Pointer );
      SafeFreeMem( Item, Len );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// TTraverseList 
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TTraverseList.Create;
const
  ThisMethodName = 'TTraverseList.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TTraverseList.Compare(Item1, Item2: pointer): integer;

const
   ThisMethodName = 'TTraverseList.Compare';
   
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := StStrS.CompStringS( pTraverseItem( Item1 )^.Key, 
                                 pTraverseItem( Item2 )^.Key);
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TTraverseList.FreeItem( Item: Pointer );
const
  ThisMethodName = 'TTraverseList.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   FreeTraverseItem( Item );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TTraverseList.InsertData( const APtr : pointer;
                                    const ATrx : boolean; 
                                    const AKey : ShortString );
const
  ThisMethodName = 'TTraverseList.InsertData';
Begin
   If DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Insert( NewTraverseItem( APtr, ATrx, AKey ) );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
