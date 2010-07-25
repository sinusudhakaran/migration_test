unit PYSL;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Payee Sorted List

  Written:
  Authors:

  Purpose: used by payee lookup dlg in dlgPayeeLookup.pas

  Notes:   The are two different methods to sort on.  Alpha for the Payee Desc
           and Numeric for the payee no.

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
  ECollect, Classes, BKDefs,
  PayeeObj;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const
   MaxKeyLength = 24;
type

   TPYSObj = class(TObject)
   public
     PYSPayee   : TPayee;
     PYSSeq     : Integer;     // Updated when we insert into the list
     PYSKey     : string[ MaxKeyLength ];  // Updated when we insert into the list
   end;

   tPYSSortType = ( PYSSortByName, PYSSortByNo );

   tPYSList = class( TExtdSortedCollection )
      Seq         : Integer;
      Sort_Order  : TPYSSortType;
      constructor Create( ASort_Order : TPYSSortType );
      function    Compare( Item1, Item2 : pointer ) : integer; override;
      procedure   FreeItem( Item : Pointer ); override;
      procedure   Insert( Item : Pointer ); override;
      function    SearchFor( AKey : ShortString ): Integer;
      function    HasMatch( AKey : ShortString ): Integer;
      function    PYSObj_At( Index : Longint ) : TPYSObj;
   end;

function NewPYSObj(aPayee : TPayee) : TPYSObj;

//******************************************************************************
implementation
uses
   StStrS,
   Malloc,
   LogUtil,
   BK5Except,
   GenUtils,
   SysUtils,
   BKCONST;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'PYSL';
   DebugMe  : Boolean = False;

//CONST
//   PYSRec_Size = SizeOf( tPYSRec );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function MakeKey( PYSObj : TPYSObj; Sort_Order : TPYSSortType ): ShortString;

const
   ThisMethodName = 'MakeKey';

Var
   Key : ShortString;
   S   : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := '';
   with PYSObj, PYSPayee do
   Begin
       case Sort_Order of
          PYSSortByName :
             begin { 24 Byte Key }
                FillChar( Key, SizeOf( Key ), 32 );
                S := UpperCase( pdName );
                Move( S[1], Key[1], Ord( S[0] ) );
                S := GenUtils.LongToKey( PYSSeq );
                Move( S[1], Key[21], Ord( S[0] ) );
                Key[0] := #24;
                Result := Key;
             end;
          PYSSortByNo   : Result := GenUtils.LongToKey( pdNumber );
       end;
   end;
   Assert( Length( Result )<=MaxKeyLength, 'Key Length Error in PYSL.MakeKey' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function NewPYSObj(APayee : TPayee) : TPYSObj;

const
   ThisMethodName = 'NewPYSObj';
var
  P : TPYSObj;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   {SafeGetMem( P, PYSRec_Size );
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, PYSRec_Size, 0 );
      PYSPayee := aPtr ;
   end
   else
   Begin
      LogError( 'PYSL', 'Unable to allocate a new pPYSRec' );
      Raise ENoMemoryLeft.Create( 'PYSL: ' + 'Memory Allocation Failed in NewPYSRec' );
   end;
   NewPYSRec := P;}

   P := TPYSObj.Create;
   P.PYSPayee := APayee;
   Result := P;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Constructor tPYSList.Create( ASort_Order : TPYSSortType );
const
  ThisMethodName = 'tPYSList.Create';
Begin                   { Sorted, AllowDups }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   inherited Create;
   Duplicates := false;
   Sort_Order := ASort_Order;
   Seq        := 0;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tPYSList.Compare( Item1, Item2 : pointer ) : integer;

const
   ThisMethodName = 'tPYSList.Compare';
var
   PY1  : TPYSObj absolute Item1;
   PY2  : TPYSObj absolute Item2;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Compare := StStrS.CompStringS( PY1.PYSKey, PY2.PYSKey );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PROCEDURE tPYSList.FreeItem( Item : Pointer );
const
   ThisMethodName = 'tPYSList.FreeItem';
Begin
   if Assigned( Item ) then TPYSObj(Item).Free;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tPYSList.Insert( Item : Pointer );
const
   ThisMethodName = 'tPYSList.Insert';

Var
   P : TPYSObj absolute Item;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Inc( Seq );
   with P do
   Begin
      PYSSeq := Seq;
      PYSKey := MakeKey( P, Sort_Order );
   end;
   inherited Insert( Item );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tPYSList.PYSObj_At( Index : Longint ) : TPYSObj;
const
   ThisMethodName = 'tPYSList.PYSObj_At';

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Assert( Index<FCount, 'Index Out of Bounds' );
   Result := At( Index );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tPYSList.SearchFor( AKey : ShortString ): Integer;
{
  A brute force search is good enough here as we have to redraw the list
  after every keystroke.
}
//if the sort is by name then can compare the actual keys
//if the sort is by number then the list key is a string generated from the payee no.
//we need to compare the entered value with the payee no so convert both to string.
//need to pad out the string. ( see below).  Need to convert the given key to no and then
//compute the list key from that to see if any more items could match.
const
  ThisMethodName = 'tPYSList.SearchFor';
var
   I : Integer;
   pKey : ShortString;
   SearchKey : ShortString;
   SearchNo  : Integer;
   pNoStr    : ShortString;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := 0;
   if ( FCount = 0 ) or ( AKey = '' ) then Exit;

   for i := 0 to Pred( FCount) do begin
      case Sort_Order of
         pysSortByName : begin
            pKey := PYSObj_At( i).pysKey;
            //trim to length of search
            pKey := Copy( pKey, 1, Length( AKey ));
            if pKey = AKey then begin
               Result := i;
               Exit;
            end;
            //if current key is greater then there will be no more matches.
            //return the last item
            if pKey > AKey then begin
               if I > 0 then
                  Result := Pred( I );
               Exit;
            end;
         end;
         pysSortByNo : begin
            pKey      := PYSObj_At( i).pysKey;
            //store the payee no as a string.  pas so that length when trimmed is not
            //too short.  Otherwise search for 13 will match on 1
            pNoStr    := Pads( IntToStr( PYSObj_At(i).pysPayee.pdNumber), 6);
            SearchNo  := StrToIntDef( AKey, 0);
            SearchKey := GenUtils.LongtoKey( SearchNo);
            //trim to length of search
            pNoStr := Copy( pNoStr, 1, Length( AKey ));
            if pNoStr = AKey then begin
               Result := i;
               Exit;
            end;
            //if current key is greater then there will be no more matches.
            //return the last item. Use list keys now, not payee no
            if pKey > SearchKey then begin
               if I > 0 then
                  Result := Pred( I );
               Exit;
            end;
         end;
      end;
   end; { No match }
   Result := Pred( FCount );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tPYSList.HasMatch( AKey : ShortString ): Integer;
{
  A brute force search is good enough here as we have to redraw the list
  after every keystroke.
}
//if the sort is by name then can compare the actual keys
//if the sort is by number then the list key is a string generated from the payee no.
//we need to compare the entered value with the payee no so convert both to string.
//need to pad out the string. ( see below)
const
  ThisMethodName = 'tPYSList.HasMatch';
var
   I         : Integer;
   pKey      : ShortString;
   pNoStr    : ShortString;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := -1;
   if ( FCount = 0 ) or ( AKey = '' ) then Exit;

   for i := 0 to Pred( FCount) do begin
      case Sort_Order of
         pysSortByName : begin
            pKey := PYSObj_At( i).pysKey;
            //trim to length of search
            pKey := Copy( pKey, 1, Length( AKey ));
            if pKey = AKey then begin
               Result := (i + 1);
               Exit;
            end;
         end;
         pysSortByNo : begin
            pKey := PYSObj_At( i).pysKey;
            //store the payee no as a string.  pas so that length when trimmed is not
            //too short.  Otherwise search for 13 will match on 1
            pNoStr    := Pads( IntToStr( PYSObj_At(i).pysPayee.pdNumber), 6);
            //trim to length of search
            pNoStr := Copy( pNoStr, 1, Length( AKey ));
            if pNoStr = AKey then begin
               Result := (i + 1);
               Exit;
            end;
         end;
      end;
   end; { No match }
   if DebugMe then LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.


