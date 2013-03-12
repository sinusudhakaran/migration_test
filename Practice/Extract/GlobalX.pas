unit GlobalX;
{
   Author, SPA 25-05-99

   This is the extract data program for Global sites.

   The data is extracted in the original Solution 6 format with
   no GST information at all.
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils,
     InfoMoreFrm, BKDefs;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'GlobalX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   Contra        : Money;
   CrValue       : Money;
   DrValue       : Money;
   ECount        : Longint;

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

Function S6_Amount ( Amount : Money ): ShortString;

Var
   S : String[20];
   Is_Neg   : Boolean;
   i        : Integer;
Begin
   Is_Neg:=( Amount<0 ); If Is_Neg then Amount:=Amount*-1;
   Str( Amount/100:13:2,S ); If Is_Neg then S[1]:='-';
   For i:=2 to Length( S ) do if S[i]=' ' then S[i]:='0';
   Result := S;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure GlobalWrite( const ADate        : TStDate;
                       const ARefce       : ShortString;
                       const AAmount      : Money;
                       const AParticulars : ShortString;
                       const AAccount     : ShortString;
                       const AOtherParty  : ShortString );
Begin
   Write( XFile, 'B' );
   Write( XFile, Date2Str( ADate, 'dd/mm/yy' ) );
   Write( XFile, GenUtils.FillRefce( ARefce ) );
   Write( XFile, S6_Amount( AAmount ) );
   Write( XFile, Fill( AParticulars, 12 ) );
   Write( XFile, Fill( AAccount, 12 ) );
   Write( XFile, Fill( AOtherParty, 20 ) );
   Writeln( XFile );

   If AAmount<0 then
      CrValue:=CrValue + AAmount
   else
      DrValue:=DrValue + AAmount;
   Contra := Contra + AAmount;
   Inc( ECount );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
   ThisMethodName = 'DoTransaction';
var
   sOther : String[ 20];
   sPart  : String[ 12];
   Narration: string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      If ( txFirst_Dissection = NIL ) then
      Begin
         txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);

         txDate_Transferred := CurrentDate;
         if SkipZeroAmountExport(Transaction) then
            Exit; // Im done...

         Narration := Copy( GetNarration(TransAction,Bank_Account.baFields.baAccount_Type), 1, GetMaxNarrationLength);
         sOther := Copy( Narration, 1, 20);
         sPart  := Copy( Narration, 21, 12);

         GlobalWrite( txDate_Effective,   { const ADate        : TStDate; }
                      GetReference(TransAction,Bank_Account.baFields.baAccount_Type),        { const ARefce       : ShortString; }
                      txAmount,           { const AAmount      : Money; }
                      sPart,              { const AParticulars : ShortString; }
                      txAccount,          { const AAccount     : ShortString; }
                      sOther );           { const AOtherParty  : ShortString ); }
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
   S : string[ 20];
   ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      ExtractLength := GetMaxNarrationLength;
      if ExtractLength > 20 then
        ExtractLength := 20;
      S := Copy(dsGL_Narration, 1, ExtractLength);
      GlobalWrite( txDate_Effective,           { const ADate        : TStDate; }
                   getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{ const ARefce       : ShortString; }
                   dsAmount,                   { const AAmount      : Money; }
                   '',                         { const AParticulars : ShortString; }
                   dsAccount,                  { const AAccount     : ShortString; }
                   S );                        { const AOtherParty  : ShortString ); }

   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

VAR
   BA : TBank_Account;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   
   Procedure ExportPeriod( D1, D2 : TStDate );
   const
      ThisMethodName = 'ExportPeriod';
   Var
      Amount : Money;      
   
   Begin { ExportPeriod }
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
      With MyClient, BA.baFields do
      Begin
         Contra := 0;
         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( twAllNewEntries );
         TRAVERSE.SetOnEHProc( DoTransaction );
         TRAVERSE.SetOnDSProc( DoDissection );
         TRAVERSE.TraverseEntriesForAnAccount( BA, D1, D2 );
         Amount := -Contra;
         
         GlobalWrite( D2,                     { const ADate        : TStDate; }
                      '',                     { const ARefce       : ShortString; }
                      Amount,                 { const AAmount      : Money; }
                      'Contra',               { const AParticulars : ShortString; }
                      baContra_Account_Code,  { const AAccount     : ShortString; }
                      '' );                   { const AOtherParty  : ShortString ); }

      end;
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const
   ThisMethodName = 'ExtractData';
   
var
   Msg          : String; 
   ti           : Integer;
   D1, D2       : TStDate;
   M1, Y1       : Integer;
   M,Y          : Integer;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [GLOBAL format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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
            
            Write( XFile, 'A' );
            Write( XFile, Fill( clCode, 13 ) );
            Write( XFile, Fill( 'From BankLink', 20 ) );
            Write( XFile, Date2Str( CurrentDate, 'dd/mm/yy' ) );
            Write( XFile, Fill( '', 36 ) );
            Writeln( XFile );
         
            DrValue := 0;
            CrValue := 0;
            ECount  := 0;
            
            StDateToDMY( FromDate, ti, M1, Y1 ); { 01-04-97 }
            M := M1; Y := Y1;
            Repeat
               D1 := DMYToStDate( 1, M, Y, Epoch );
               If D1<FromDate then D1 := FromDate;
               D2 := DMYToStDate( DaysInMonth( M, Y, Epoch ), M, Y, Epoch );
               If D2 > ToDate then D2 := ToDate;
               ExportPeriod( D1, D2 );
               Inc( M ); If M>12 then Begin M:= 1; Inc( Y ); end;
            Until ( D2 = ToDate );

            Write( XFile, 'C' );
            Write( XFile, S6_Amount( DrValue ) );
            Write( XFile, S6_Amount( abs( CrValue ) ) );
            Write( XFile, S6_Amount( CrValue+DrValue ) );
            Write( XFile, S6_Amount( abs( CrValue ) + DrValue ) );
            Write( XFile, S6_Amount( 100*ECount ) );
            Write( XFile, '':12 );
            Writeln( XFile );
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

