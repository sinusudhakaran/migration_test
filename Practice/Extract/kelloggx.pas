unit kelloggx;

{
   Author, SPA 25-05-99

   notes: doesn't export any GST information

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs, Math;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'KelloggX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function Number2FRS( N : Money ): ShortString;
Var
   S  : String[13];
   i  : Integer;
Begin
   Str( ABS( N ):12:0, S );
   If ( N<0 ) then S[1] := '-';
   For i := 2 TO Length( S ) do If S[i]=' ' then S[i]:='0';
   S := Copy( S,1,10 )+'.'+Copy( S,11,2 );
   Number2FRS := S;
End;

Function Qty2FRS( N : Money ): ShortString;
Var
   S  : String[13];
   i  : Integer;
Begin
   Str( ABS( N ):12:0, S );
   If ( N<0 ) then S[1] := '-';
   For i := 2 TO Length( S ) do If S[i]=' ' then S[i]:='0';
   i := Min(2, Globals.PRACINI_ExtractDecimalPlaces);
   if i = 0 then
     S := Copy( S,1,10 )
   else
     S := Copy( S,1,8 )+'.'+Copy( S,9,i );
   Qty2FRS := S;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function Fill( M : ShortString; Len : Byte ): ShortString;

Var S : ShortString;
Begin
   FillChar( S,Sizeof( S ),#$20 );
   If Ord( M[0] )>0 then Move( M[1],S[1],Ord( M[0] ) );
   S[0]:=Chr( Len );
   Fill:=S;
End;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure KelloggsWrite(  ADate        : TStDate;
                          ARefce       : ShortString;
                          AAccount     : ShortString;
                          AAmount      : Money;
                          AQuantity    : Money;
                          ANarration   : ShortString );
const
   ThisMethodName = 'KelloggsWrite';
var
  S: ShortString;
  ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, '"', Date2Str( ADate, 'ddmmyy' ), '",' );

   S := TrimSpacesS(ReplaceCommasAndQuotes(ARefce));
   While Length( S ) > 6 do System.Delete( S, 1, 1 );

   If GenUtils.IsNumeric( S ) then
      Write( XFile, '"', S, '",' )
   else
      Write( XFile, '"      ",' );  { Leave Blank if not numeric }

   Write( XFile, '"', Fill (ReplaceCommasAndQuotes(AAccount), 6 ), '",' );

   Write( XFile, Number2FRS( AAmount ), ',' );

   if (Globals.PRACINI_ExtractQuantity) then
     Write( XFile, Qty2FRS( AQuantity ), ',' ) { Quantity }
   else
     Write( XFile, Qty2FRS( 0.0 ), ',' ); { Quantity }

   Write( XFile, '"01",' ); { Item Type }

   Write( XFile, '"      ",' ); { Enterprise }

   ExtractLength := GetMaxNarrationLength;
   if ExtractLength > 25 then
     ExtractLength := 25;

   Writeln( XFile, '"', Fill( Copy(ReplaceCommasAndQuotes(ANarration), 1, ExtractLength), 25 ), '"' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
Var
  S : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);

      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         KelloggsWrite( txDate_Effective, { ADate        : TStDate;         }
                        GetReference(TransAction,Bank_Account.baFields.baAccount_Type),      { ARefce       : ShortString;     }
                        txAccount,        { AAccount     : ShortString;     }
                        txAmount,         { AAmount      : Money;           }
                        txQuantity,       { AQuantity    : Money;           }
                        S );              { ANarration   : ShortString );   }
      end;
      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
var
   S : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      KelloggsWrite( txDate_Effective, { ADate        : TStDate;         }
                     getDsctReference(Dissection,Transaction,baAccount_Type),
                                       { ARefce       : ShortString;     }
                     dsAccount,        { AAccount     : ShortString;     }
                     dsAmount,         { AAmount      : Money;           }
                     dsQuantity,       { AQuantity    : Money;           }
                     S );              { ANarration   : ShortString );   }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';

VAR
   BA           : TBank_Account;
   Msg          : String;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Kelloggs NZ format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   with MyClient.clFields do
   begin
      BA := dlgSelect.SelectBankAccountForExport( FromDate, ToDate );
      if not Assigned( BA ) then Exit;

      With BA.baFields do
      Begin
         if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
         Begin
            HelpfulInfoMsg( 'There aren''t any new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
            exit;
         end;
      
         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
   
         Try
            NoOfEntries := 0;
            TRAVERSE.Clear;
            TRAVERSE.SetSortMethod( csDateEffective );
            TRAVERSE.SetSelectionMethod( twAllNewEntries );
            TRAVERSE.SetOnEHProc( DoTransaction );
            TRAVERSE.SetOnDSProc( DoDissection );
            TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
            OK := True;
         finally            
            System.Close( XFile );
         end;
      end;
      if OK then
      Begin
         Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
         LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
         HelpfulInfoMsg( Msg, 0 );
      end;
   end; { Scope of MyClient }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

