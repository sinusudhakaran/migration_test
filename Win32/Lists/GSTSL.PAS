unit GSTSL;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:    GST Lookup Sorted List

   Written:  Apr 2000
   Authors:  Matthew

   Purpose:

   Notes:    Provides sorted lists, either by code or by description, for the
             gst lookup frm

             if all gst id's are numeric then the lookup will sort by numeric
             gst id's are unique so just get key from longint
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE
USES
   ECollect,
   Classes,
   BKDefs;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   MaxKeyLength = 24;
   CodeKeyLengthUsed = 8;  //tells max number of chars used from the front of the
                           //code to build the key with

Type
   pgSRec = ^tgSRec;

   tgSRec = Record
      gSIDCode     : String[ 5];
      gSDesc       : String[ 60];
      gSSeq        : Integer;     // Updated when we insert into the list
      gSKey        : string[ MaxKeyLength ];  // Updated when we insert into the list
   end;

   tgSSortType = ( gSSortByCode, gSSortByDesc );

   tgSList = class( TExtdSortedCollection )
      Seq         : Integer;
      Sort_Order  : TgSSortType;
      constructor    Create( ASort_Order : TgSSortType );
      function       Compare( Item1, Item2 : pointer ) : integer; override;
      procedure      FreeItem( Item : Pointer ); override;
      procedure      Insert( Item : Pointer ); override;
      function       SearchFor( AKey : ShortString ): Integer;
      function       HasMatch( AKey : ShortString ): Boolean;
      function       gSRec_At( Index : Longint ) : pgSRec;

      function       CompareMixed( s1 : shortString; s2 : ShortString) : integer;
   end;

function NewGSRec( GSTCode : string; GSTDesc : string) : pgSRec;

//******************************************************************************
implementation
uses
   StStrS,
   Malloc,
   LogUtil,
   bk5except,
   GenUtils,
   SysUtils,
   Math,
   BKCONST;

Const
   UnitName = 'gSL';
   DebugMe  : Boolean = False;

CONST
   gSRec_Size = SizeOf( tgSRec );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function MakeKey( gSRec : pgSRec; Sort_Order : TgSSortType ): ShortString;

const
   ThisMethodName = 'MakeKey';

Var
   Key : ShortString;
   S   : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := '';
   with gSRec^ do Begin
       case Sort_Order of
          gSSortByCode   :
             begin { 12 Byte Key - max code size is 5 }
                FillChar( Key, SizeOf( Key ), 32 );
                S := UpperCase( gsIDCode );
                Move( S[1], Key[1], Ord( S[0] ) );
                //add sequence key to ensure unique
                S := GenUtils.LongToKey( gSSeq );
                Move( S[1], Key[ CodeKeyLengthUsed + 1], Ord( S[0] ) );
                Key[0] := Char( CodeKeyLengthUsed + 4);  //add 4 for sequence no
                Result := Key;
             end;
          gSSortByDesc   :
             begin { 24 Byte Key }
                FillChar( Key, SizeOf( Key ), 32 );
                S := UpperCase( gSDesc );
                Move( S[1], Key[1], Ord( S[0] ) );
                //add sequence key to ensure unique
                S := GenUtils.LongToKey( gSSeq );
                Move( S[1], Key[21], Ord( S[0] ) );
                Key[0] := #24;
                Result := Key;
             end;
       end;
   end;
   Assert( Length( Result )<=MaxKeyLength, 'Key Length Error in gSL.MakeKey' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function NewgSRec( GSTCode : string; GSTDesc : string) : pgSRec;
const
   ThisMethodName = 'NewGSRec';
Var
   P : pgSRec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   SafeGetMem( P, gSRec_Size );
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, gSRec_Size, 0 );
      gSIDCode := GSTCode;
      gSDesc   := GSTDesc;
   end
   else
   Begin
      LogError( 'gSL', 'Unable to allocate a new pgSRec' );
      Raise ENoMemoryLeft.Create( 'gSL: ' + 'Memory Allocation Failed in NewgSRec' );
   end;
   NewgSRec := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Constructor tgSList.Create( ASort_Order : TgSSortType );
const
  ThisMethodName = 'tgSList.Create';
Begin                   { Sorted, AllowDups }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   inherited Create;
   Duplicates := false;
   Sort_Order := ASort_Order;
   Seq        := 0;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tgSList.Compare( Item1, Item2 : pointer ) : integer;

const
   ThisMethodName = 'tgSList.Compare';
var
   CH1  : pgSRec absolute Item1;
   CH2  : pgSRec absolute Item2;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if Sort_Order = gSSortByCode then begin
      result := CompareMixed( ch1^.gsKey, ch2^.gsKey);
   end
   else
      result := StStrS.CompStringS( CH1^.gSKey, CH2^.gSKey );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tgSList.SearchFor( AKey : ShortString ): Integer;

{
  A brute force search is good enough here as we have to redraw the list
  after every keystroke.
}
const
  ThisMethodName = 'tgSList.SearchFor';
var
   I         : Integer;
   NoMoreMatches : Boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := 0;
   if ( FCount = 0 ) or ( AKey = '' ) then Exit;

   for I := 0 to Pred( FCount ) do Begin
      if Copy( gSRec_At( I )^.gSKey, 1, Length( AKey ) ) = AKey then  begin
         Result := I;
         Exit;
      end;

      if Sort_Order = gsSortByCode then
         NoMoreMatches := ( CompareMixed( gsRec_At( I )^.gsKey, AKey) > 0) and ( StStrS.CompStringS( gsRec_At( I)^.gsKey, AKey) > 0)
      else
         NoMoreMatches := ( StStrS.CompStringS( gsRec_At( I)^.gsKey, AKey) > 0);

      if NoMoreMatches then begin
         if I > 0 then
            Result := Pred( I );
         Exit;
      end;
   end; { No match }
   Result := Pred( FCount );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tgSList.HasMatch( AKey : ShortString ): Boolean;

{
  A brute force search is good enough here as we have to redraw the list
  after every keystroke.
}

const
  ThisMethodName = 'tgSList.HasMatch';
var
   I : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := False;
   if ( FCount = 0 ) or ( AKey = '' ) then Exit;

   for I := 0 to Pred( FCount ) do Begin
      if Copy( gSRec_At( I )^.gSKey, 1, Length( AKey ) ) = AKey then begin
         Result := True;
         Exit;
      end;
   end; { No match }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PROCEDURE tgSList.FreeItem( Item : Pointer );
const
   ThisMethodName = 'tgSList.FreeItem';

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if Assigned( Item ) then SafeFreeMem( Item, gSRec_Size );
   Item := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tgSList.Insert( Item : Pointer );
const
   ThisMethodName = 'tgSList.Insert';

Var
   P : pgSRec absolute Item;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Inc( Seq );
   with P^ do
   Begin
      gSSeq := Seq;
      gSKey := MakeKey( P, Sort_Order );
   end;
   inherited Insert( Item );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tgSList.gSRec_At( Index : Longint ) : pgSRec;
const
   ThisMethodName = 'tgSList.gSRec_At';

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Assert( Index<FCount, 'Index Out of Bounds' );
   Result := At( Index );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tgSList.CompareMixed(s1, s2: ShortString): integer;
//compare two string,  tests to see if the strings start with numeric values.  If so
//the numeric will be sorted to the top of the list, followed by the alphas
//use Int64 data type so that cant get a string that is too large to converted to a number

   procedure SplitString ( s : shortString; var NumericPart : int64; var AlphaPart : shortString);
   //split the string into the numeric part and the remaining alpha numeric part
   var
      i : integer;
      p : integer;
   begin
      p := 0;
      //find pos of last numeric
      for i := 1 to length( s) do begin
         if s[i] in ['0'..'9'] then
            p := i
         else
            break;  //first non numeric found
      end;
      NumericPart := StrToInt64( Copy ( s,1,p));
      AlphaPart   := Copy( s, p+1, length(s));
   end;

var
   n1, n2 : Int64;
   a1, a2 : shortString; //alpha
begin
   //extract and trim the portion of the key that is made up of the code
   a1 := Trim( Copy( s1, 1, CodeKeyLengthUsed));
   a2 := Trim( Copy( s2, 1, CodeKeyLengthUsed));
   //test to see if we have 2 numbers
   if ( IsNumeric( a1) and  IsNumeric( a2)) then begin
      n1 := StrToInt64( a1);
      n2 := StrToInt64( a2);
      if n1 > n2 then result := 1 else
      if n1 < n2 then result := -1 else
      //numbers are the same , unlikely must may be that code is longer than numeric part of key
      //in this case we must use the whole key to do the compare, otherwise will get a duplication
      result := StStrS.CompStringS( a1,a2);
   end
   else if ( s1[1] in ['0'..'9']) and ( s2[1] in ['0'..'9']) then begin
      //compare the numeric portion of each string, then compare the string part
      SplitString( s1, n1, a1);
      SplitString( s2, n2, a2);
      if n1 > n2 then result := 1 else
      if n1 < n2 then result := -1 else begin
         //numeric value is the same so compare remaining alpha
         result := StStrS.CompStringS( a1,a2);
      end;
   end
   else begin
      //one or more of the keys start with a non numeric
      result := StStrS.CompStringS( s1,s2);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

