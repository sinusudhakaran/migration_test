unit CHSL;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:    Chart of Accounts sorted Lists for Lookup

   Written:
   Authors:

   Purpose:

   Notes:  Used by AccountLookupFrm

           the CompareMixed routines are commented out until we decide we need them
           At this stage it is better to leave the lookup sorting alphabetically because
           that is the way the maintain charts dlg and the reports sort
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE USES ECollect, Classes, BKDefs;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   MaxKeyLength = 24;
   CodeKeyLengthUsed = 10;
Type
   pCHSRec = ^tCHSRec;

   tCHSRec = Record
      chsAccount_Ptr : pAccount_Rec;
      chsSeq         : Integer;     // Updated when we insert into the list
      chsKey         : string[ MaxKeyLength ];  // Updated when we insert into the list
   end;

   tCHSSortType = (chsSortByCode, chsSortByDesc, chsSortByAltCode);

   tCHSList = class( TExtdSortedCollection )
      Seq         : Integer;
      Sort_Order  : TCHSSortType;
      Use_Xlon_Sort_Order   : boolean;
      constructor    Create( ASort_Order : TCHSSortType ); override;
      function       Compare( Item1, Item2 : pointer ) : integer; override;
      procedure      FreeItem( Item : Pointer ); override;
      procedure      Insert( Item : Pointer ); override;
      function       SearchFor( AKey : ShortString ): Integer;
      function       HasMatch( AKey : ShortString ): Integer;
      function       CHSRec_At( Index : Longint ) : pCHSRec;
//      function       CompareMixed(s1, s2: ShortString): integer;
   end;

function NewCHSRec( aPtr : pAccount_Rec ) : pCHSRec;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation

uses
  StStrS, Malloc, LogUtil, BK5Except, GenUtils, SysUtils, BKCONST;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'CHSL';
   DebugMe  : Boolean = False;

CONST
   CHSRec_Size = SizeOf( tCHSRec );

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function MakeKey( CHSRec : pCHSRec; Sort_Order : TCHSSortType; const Use_Xlon_Sort_Order : boolean ): ShortString;

const
   ThisMethodName = 'MakeKey';

Var
   Key : ShortString;
   S   : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := '';
   with CHSRec^, chsAccount_Ptr^ do
   Begin
       case Sort_Order of
          CHSSortByCode   :
             begin { 14 Byte Key }
                if Use_Xlon_Sort_Order then
                  Result := UpperCase( chAccount_Code )
                else
                begin
                  FillChar( Key, SizeOf( Key ), 32 );
                  S := UpperCase( chAccount_Code );
                  Move( S[1], Key[1], Ord( S[0] ) );
                  S := GenUtils.LongToKey( chsSeq );
                  Move( S[1], Key[ CodeKeyLengthUsed + 1 ], Ord( S[0] ) );
                  Key[0] := Char( CodeKeyLengthUsed + 4);  //for integer
                  Result := Key;
                end;
             end;

          CHSSortByDesc   :
             begin { 24 Byte Key }
                FillChar( Key, SizeOf( Key ), 32 );
                S := UpperCase( chAccount_Description );
                Move( S[1], Key[1], Ord( S[0] ) );
                S := GenUtils.LongToKey( chsSeq );
                Move( S[1], Key[21], Ord( S[0] ) );
                Key[0] := #24;
                Result := Key;
             end;
            CHSSortByAltCode   :
             begin { 14 Byte Key }

                  FillChar( Key, SizeOf( Key ), 32 );
                  S := UpperCase( chAlternative_Code );
                  Move( S[1], Key[1], Ord( S[0] ) );
                  S := GenUtils.LongToKey( chsSeq );
                  Move( S[1], Key[ CodeKeyLengthUsed + 1 ], Ord( S[0] ) );
                  Key[0] := Char( CodeKeyLengthUsed + 4);  //for integer
                  Result := Key;
             end;
       end;
   end;
   Assert( Length( Result )<=MaxKeyLength, 'Key Length Error in CHSL.MakeKey' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function NewCHSRec( aPtr : pAccount_Rec ) : pCHSRec;

const
   ThisMethodName = 'NewCHSRec';
Var
   P : pCHSRec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   SafeGetMem( P, CHSRec_Size );
   If Assigned( P ) then With P^ do
   Begin
      FillChar( P^, CHSRec_Size, 0 );
      chsAccount_Ptr := aPtr ;
   end
   else
   Begin
      LogError( 'CHSL', 'Unable to allocate a new pCHSRec' );
      Raise ENoMemoryLeft.Create( 'CHSL: ' + 'Memory Allocation Failed in NewCHSRec' );
   end;
   NewCHSRec := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Constructor tCHSList.Create( ASort_Order : TCHSSortType );
const
  ThisMethodName = 'tCHSList.Create';
Begin                   { Sorted, AllowDups }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   inherited Create;
   Duplicates := false;
   Sort_Order := ASort_Order;
   Seq        := 0;
   Use_Xlon_Sort_Order   := false;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tCHSList.Compare( Item1, Item2 : pointer ) : integer;

const
   ThisMethodName = 'tCHSList.Compare';
var
   CH1  : pCHSRec absolute Item1;
   CH2  : pCHSRec absolute Item2;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if (Use_Xlon_Sort_Order) then
   begin
     Result := XlonSort(CH1^.chsKey, CH2^.chsKey);
     if (Result = 0) then
       Result := StStrS.CompStringS( CH1^.chsKey, CH2^.chsKey );
   end else
     Result := StStrS.CompStringS( CH1^.chsKey, CH2^.chsKey );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tCHSList.SearchFor( AKey : ShortString ): Integer;

{
  A brute force search is good enough here as we have to redraw the list
  after every keystroke.
}

const
  ThisMethodName = 'tCHSList.SearchFor';
var
   I : Integer;
   NoMoreMatches : Boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := 0;
   if ( FCount = 0 ) or ( AKey = '' ) then Exit;

   for I := 0 to Pred( FCount ) do
   Begin
      //logutil.logmsg(lmDebug, unitname, 'Comparing '+chsRec_At(i)^.chsKey+' and '+ aKey);

      if (CHSRec_At( I )^.chsKey[1] = AKey[1]) then
      begin
        if Copy( CHSRec_At( I )^.chsKey, 1, Length( AKey ) ) = AKey then
        begin
          Result := I;
          Exit;
        end;
      end;
      //see if we have gone past any possible matches
(*
      if Sort_Order = chsSortByCode then
         NoMoreMatches := ( CompareMixed( chsRec_At( I)^.chsKey, AKey) > 0) and ( StStrS.CompStringS( chsRec_At( I)^.chsKey, AKey) > 0)
      else
*)
      NoMoreMatches := ( StStrS.CompStringS( chsRec_At( I)^.chsKey, AKey) > 0);

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
//
// Function : HasMatch
// Parameters : AKey - the key to match
// Returns : The index of the row a match was found, or -1 if no match found
//
FUNCTION tCHSList.HasMatch( AKey : ShortString ): Integer;

{
  A brute force search is good enough here as we have to redraw the list
  after every keystroke.
}

const
  ThisMethodName = 'tCHSList.HasMatch';
var
   I : Integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := -1;
   if ( FCount = 0 ) or ( AKey = '' ) then Exit;

   for I := 0 to Pred( FCount ) do
   Begin
      if (CHSRec_At( I )^.chsKey[1] = AKey[1]) then
      begin
        if Copy( CHSRec_At( I )^.chsKey, 1, Length( AKey ) ) = AKey then
        begin
           Result := (I + 1);
           Exit;
        end;
      end;
   end; { No match }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PROCEDURE tCHSList.FreeItem( Item : Pointer );
const
   ThisMethodName = 'tCHSList.FreeItem';
   
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if Assigned( Item ) then SafeFreeMem( Item, CHSRec_Size );
   Item := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure tCHSList.Insert( Item : Pointer );
const
   ThisMethodName = 'tCHSList.Insert';
   
Var
   P : pCHSRec absolute Item;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Inc( Seq );
   with P^ do
   Begin
      chsSeq := Seq;
      chsKey := MakeKey( P, Sort_Order, Use_Xlon_Sort_Order );
   end;
   inherited Insert( Item );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION tCHSList.CHSRec_At( Index : Longint ) : pCHSRec;
const
   ThisMethodName = 'tCHSList.CHSRec_At';

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Assert( Index<FCount, 'Index Out of Bounds' );
   Result := At( Index );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*
function tCHSList.CompareMixed(s1, s2: ShortString): integer;
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
*)
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

