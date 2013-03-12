unit charterx;
{
   Author, SPA 25-05-99
   Chris Hillier is the only Charter user.
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'CharterX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;
   Contra             : Money;   
   NoOfLines          : LongInt;
   NoOfComments       : LongInt;
   LastEntryDate      : TStDate;
   ECount             : Longint;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CheckTransaction;
const
   ThisMethodName = 'CheckTransaction';
Var
   S : ShortString;   
Begin   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      If ( txFirst_Dissection = NIL ) then
      Begin
         Inc( NoOfLines );
         S := TrimSpacesS(  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type));
         If S<>'' then Inc( NoOfComments );
      end;
      If txDate_Effective > LastEntryDate then LastEntryDate := txDate_Effective;
   end;   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CheckDissection;
const
   ThisMethodName = 'CheckDissection';
Begin   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   with Dissection^ do
   Begin
      Inc( NoOfLines );
      If Trim( dsGL_Narration ) <>'' then Inc( NoOfComments );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function N3( A : LongInt ): ShortString;

Var
   S : String[3];
   i  : Byte;
Begin
   Str( A:3, S );
   For i:=1 to 3 do if S[i]=' ' then S[i]:='0';
   N3 := S;
end;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CharterWrite(  const ADate        : TStDate;
                         const ARefce       : ShortString;
                         const AAccount     : ShortString;
                         const AAmount      : Money;
                         const ANarration   : ShortString );
const
   ThisMethodName = 'CharterWrite';
Var
   S : ShortString;
Begin
   Inc( ECount );
   Write( XFile, '"L",' );
   Write( XFile, ECount, ',1,1,' );
   Write( XFile, ReplaceCommasAndQuotes(AAccount),',' );

   S := TrimSpacesS( GenUtils.FillRefce( ReplaceCommasAndQuotes(ARefce)) );
   While Length( S ) > 6 do System.Delete( S, 1, 1 );
   While Length( S ) < 6 do S := ' '+S;
   Write( XFile, '"',S,'",' );

   Write( XFile, '"', Date2Str( ADate, 'dd/mm/yy' ),'",0,' );

   Write( XFile, AAmount/100:0:2, ',' );

   S := Copy(TrimSpacesS(ReplaceCommasAndQuotes(ANarration)), 1, GetMaxNarrationLength);
   While Length( S ) > 20 do S[0]:=Pred( S[0] );
   Writeln( XFile, '"', S, '"' );
   
   Contra := Contra + AAmount;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountHeader;

const
   ThisMethodName = 'DoAccountHeader';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Contra := 0;
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
         CharterWrite(  txDate_Effective,
                        GetReference(TransAction,Bank_Account.baFields.baAccount_Type),
                        txAccount,
                        txAmount,
                        S );
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
   with Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      CharterWrite(  txDate_Effective,
                     getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),
                     dsAccount,
                     dsAmount,
                     S );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoAccountTrailer ;

const
   ThisMethodName = 'DoAccountTrailer';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with Bank_Account.baFields do
   Begin
      CharterWrite(  LastEntryDate,
                     'CONTRA',
                     baContra_Account_Code, 
                     -Contra,
                     'Contra to Bank' );
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

   Msg := 'Extract data [Charter QX format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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
         
         NoOfLines          := 0;
         NoOfComments       := 0;
         LastEntryDate      := 0;
         
         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( twAllNewEntries );
         TRAVERSE.SetOnEHProc( CheckTransaction );
         TRAVERSE.SetOnDSProc( CheckDissection );
         TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );

         Inc( NoOfLines );    { For the Header }
         Inc( NoOfLines );    { For the Contra }
         Inc( NoOfComments ); { ditto }
      
         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
   
         Try
            NoOfEntries := 0;
            ECount      := 0;

            Write( XFile, '"GL",' );
            Write( XFile, N3( NoOfLines ), ',' );
            Write( XFile, N3( NoOfComments ), ',' );
            Writeln( XFile, '000' );

            { General Ledger Header Record }

            Write( XFile, '"H",1,"From BankLink   ","J",1,' );
            Writeln( XFile, '"',Date2Str( LastEntryDate, 'dd/mm/yy' ),'",0.00' );

            TRAVERSE.Clear;
            TRAVERSE.SetSortMethod( csDateEffective );
            TRAVERSE.SetSelectionMethod( twAllNewEntries );
            TRAVERSE.SetOnAHProc( DoAccountHeader );
            TRAVERSE.SetOnEHProc( DoTransaction );
            TRAVERSE.SetOnDSProc( DoDissection );
            TRAVERSE.SetOnATProc( DoAccountTrailer );
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



