unit CLSL;

{
   This is the sorted list used by the account lookup 
   dialog in ClientLookupFrm.Pas.
}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE USES ECollect, CFList32, SyDefs, Classes;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   MaxKeyLength = 24;
Type
   pCLSRec = ^tCLSRec;
   tCLSRec = Record
      clsPtr : pClient_File_Rec;
      clsSeq : Integer;                 // Updated when we insert into the list
      clsKey : string[ MaxKeyLength ];  // Updated when we insert into the list
   end;
   
   tCLSSortType = ( clsSortByCode, clsSortByName );
   
   tCLSList = class( TExtdSortedCollection )
      Seq         : Integer;
      Sort_Order  : TCLSSortType;
      constructor    Create( ASort_Order : TCLSSortType );
      function       Compare( Item1, Item2 : pointer ) : integer; override;
      procedure      FreeItem( Item : Pointer ); override;
      procedure      Insert( Item : Pointer ); override;
      function       SearchFor( AKey : ShortString ): Integer;
      function       HasMatch( AKey : ShortString ): Integer;
      function       CLSRec_At( Index : Longint ) : pCLSRec;
   end;

function NewCLSRec( aPtr : pClient_File_Rec ) : pCLSRec;
   
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses StStrS, Malloc, LogUtil, BK5Except, GenUtils, SysUtils, BKCONST;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'CLSL';
   DebugMe  : Boolean = False;
         
CONST
   CLSRec_Size = SizeOf( tCLSRec );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   
function MakeKey( CLSRec : pCLSRec; Sort_Order : TCLSSortType ): ShortString;

const
   ThisMethodName = 'MakeKey';
   
Var
   Key : ShortString;
   S   : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := '';
   with CLSRec^, clsPtr^ do
   Begin
       case Sort_Order of
          CLSSortByCode   : 
             begin { 14 Byte Key }
                FillChar( Key, SizeOf( Key ), 32 );
                S := UpperCase( cfFile_Code );
                Move( S[1], Key[1], Ord( S[0] ) );
                S := GenUtils.LongToKey( clsSeq );
                Move( S[1], Key[11], Ord( S[0] ) );
                Key[0] := #14;
                Result := Key;
             end;
                              
          CLSSortByName   : 
             begin { 24 Byte Key }
                FillChar( Key, SizeOf( Key ), 32 );
                S := UpperCase( cfFile_Name );
                Move( S[1], Key[1], Ord( S[0] ) );
                S := GenUtils.LongToKey( clsSeq );
                Move( S[1], Key[21], Ord( S[0] ) );
                Key[0] := #24;
                Result := Key;
             end;
       end;
   end;
   Assert( Length( Result )<=MaxKeyLength, 'Key Length Error in CLSL.MakeKey' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function NewCLSRec( aPtr : pClient_File_Rec ) : pCLSRec;

const
   ThisMethodName = 'NewCLSRec';
Var
   P : pCLSRec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   SafeGetMem( P, CLSRec_Size );
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, CLSRec_Size, 0 );
      clsPtr := aPtr ;
   end
   else
   Begin
      LogError( 'CLSL', 'Unable to allocate a new pCLSRec' );
      Raise ENoMemoryLeft.Create( 'CLSL: ' + 'Memory Allocation Failed in NewCLSRec' );
   end;
   NewCLSRec := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Constructor tCLSList.Create( ASort_Order : TCLSSortType );
const
  ThisMethodName = 'tCLSList.Create';
Begin                   { Sorted, AllowDups }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   inherited Create;
   Duplicates := false;
   Sort_Order := ASort_Order;
   Seq        := 0;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tCLSList.Compare( Item1, Item2 : pointer ) : integer;

const
   ThisMethodName = 'tCLSList.Compare';
var
   CH1  : pCLSRec absolute Item1;
   CH2  : pCLSRec absolute Item2;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Compare := StStrS.CompStringS( CH1^.clsKey, CH2^.clsKey );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
FUNCTION tCLSList.SearchFor( AKey : ShortString ): Integer;

{
  A brute force search is good enough here as we have to redraw the list 
  after every keystroke.
}

const
  ThisMethodName = 'tCLSList.SearchFor';
var
   I : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := 0;
   if ( FCount = 0 ) or ( AKey = '' ) then Exit;
   
   for I := 0 to Pred( FCount ) do
   Begin
      if Copy( CLSRec_At( I )^.clsKey, 1, Length( AKey ) ) = AKey then
      begin 
         Result := I;
         Exit;
      end;
      if ( CLSRec_At( I )^.clsKey > AKey ) then
      begin 
         if I > 0 then 
            Result := Pred( I );
         Exit;
      end;
      
   end; { No match }
   Result := Pred( FCount );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      
FUNCTION tCLSList.HasMatch( AKey : ShortString ): Integer;

{
  A brute force search is good enough here as we have to redraw the list 
  after every keystroke.
}

const
  ThisMethodName = 'tCLSList.HasMatch';
var
   I : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := -1;
   if ( FCount = 0 ) or ( AKey = '' ) then Exit;
   
   for I := 0 to Pred( FCount ) do
   Begin
      if Copy( CLSRec_At( I )^.clsKey, 1, Length( AKey ) ) = AKey then
      begin 
         Result := (i + 1);
         Exit;
      end;
   end; { No match }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PROCEDURE tCLSList.FreeItem( Item : Pointer );
const
   ThisMethodName = 'tCLSList.FreeItem';
   
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if Assigned( Item ) then SafeFreeMem( Item, CLSRec_Size );
   Item := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tCLSList.Insert( Item : Pointer );
const
   ThisMethodName = 'tCLSList.Insert';
   
Var
   P : pCLSRec absolute Item;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Inc( Seq );
   with P^ do
   Begin
      clsSeq := Seq;
      clsKey := MakeKey( P, Sort_Order );
   end;
   inherited Insert( Item );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tCLSList.CLSRec_At( Index : Longint ) : pCLSRec;
const
   ThisMethodName = 'tCLSList.CLSRec_At';
   
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Assert( Index<FCount, 'Index Out of Bounds' );
   Result := At( Index );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

