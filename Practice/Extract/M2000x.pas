unit M2000x;

{
   Author, SPA 24-05-99

   This is the extract data program for the latest version of Master 2000.

   Master 2000 Contact Details:

   Ashburton Computer Associates
   214 Burnett Street
   Ashburton

   Eric Richards


!!! NOTE: Does not work for gst classes 10-20 as there is only 1 char avaiable
          for the GST class in the export file.
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils,
     InfoMoreFrm, BKDefs, baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'M2000X';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;

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

Function M2000Amount ( Amount : Money ): ShortString;

Var
   S : String[20];
Begin
   Str( Abs( Amount ):12:0, S );
   If Amount >=0 then
      M2000Amount := '+'+S
   else
      M2000Amount := '-'+S;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure M2000Write( const ADate        : TStDate;
                      const AType        : Byte;
                      const ARefce       : ShortString;
                      const AAccount     : ShortString;
                      const AAmount      :  Money;
                      const AGST_Class   : Byte;
                      const AGST_Amount  : Money;
                      const AQuantity    : Money;
                      const AParticulars : ShortString;
                      const AOtherParty  : ShortString
                       );
const
   ThisMethodName = 'M2000Write';
   VLine : char = #179;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if AAmount <> 0 then
   Begin
      Write( XFile, 'B', VLine );
      Write( XFile, Date2Str( ADate, 'dd/mm/yy' ), VLine );
      Write( XFile, AType:3, VLine );
      Write( XFile, Fill ( ARefce, 12 ), VLine );
      Write( XFile, Fill ( AAccount, 12 ), Vline );
      Write( XFile, M2000Amount( AAmount ), Vline );
      Write( XFile, Fill( AParticulars, 12 ), VLine );
      Write( XFile, Fill( AOtherParty, 20 ), Vline );
      Write( XFile, AGST_Class:1, VLine );                    { New Format Only }
      Write( XFile, M2000Amount( AGST_Amount ), VLine );      { New Format Only }
      if (Globals.PRACINI_ExtractQuantity) then
        Write( XFile, M2000Amount( AQuantity ), VLine )        { New Format Only }
      else
        Write( XFile, M2000Amount( 0.0 ), VLine );        { New Format Only }
      Writeln( XFile );
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
var
  sOther : string[20];
  sPart  : string[12];
  Narration: string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         Narration := Copy( GetNarration(TransAction,Bank_Account.baFields.baAccount_Type), 1, GetMaxNarrationLength);
         sOther := Copy( Narration, 1, 20);
         sPart  := Copy( Narration, 21, 12);

         M2000Write( txDate_Effective,            { const ADate        : TStDate; }
                     txType,                      { const AType        : Byte; }
                     GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                 { const ARefce       : ShortString; }
                     txAccount,                   { const AAccount     : ShortString; }
                     txAmount,                    { const AAmount      :  Money; }
                     txGST_Class,                 { const AGST_Class   : Byte; }
                     txGST_Amount,                { const AGST_Amount  : Money; }
                     txQuantity / 10,              { const AQuantity    : Money; }
                     sPart,               { const AParticulars : ShortString; }
                     sOther               { const AOtherParty  : ShortString; }
                    );

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
   with Transaction^, Dissection^ do
   Begin
      ExtractLength := GetMaxNarrationLength;
      if ExtractLength > 20 then
        ExtractLength := 20;
      S := Copy(dsGL_Narration, 1, ExtractLength);

      M2000Write( txDate_Effective,            { const ADate        : TStDate; }
                  txType,                      { const AType        : Byte; }
                  getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),
                                               { const ARefce       : ShortString; }
                  dsAccount,                   { const AAccount     : ShortString; }
                  dsAmount,                    { const AAmount      :  Money; }
                  dsGST_Class,                 { const AGST_Class   : Byte; }
                  dsGST_Amount,                { const AGST_Amount  : Money; }
                  dsQuantity / 10,             { const AQuantity    : Money; }
                  '',                          { const AParticulars : ShortString; }
                  S                            { const AOtherParty  : ShortString; }
                 );

   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';
   VLine          : char = #179;
   LineLength     = 119;
   
var
   Msg, ac      : String; 
   Selected     : TStringList;
   BA           : TBank_Account;
   No           : Integer;
   OK           : Boolean;
   S            : string[120];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Master 2000 format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   
   Selected  := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   If Selected = NIL then exit;

   Try
      with MyClient.clFields do
      begin
         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
      
         Try
            NoOfEntries := 0;
            
            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
               with BA.baFields do
               Begin

                  S := ConstStr( ' ',LineLength );
                  S[1] := 'A';
                  S[2] := Vline;
                  ac := StripM(BA);;
                  Move( ac[1], S[3], Length( ac ) );
                  S[28] := VLine;
                  Move( baBank_Account_Name[1], S[29], Length ( baBank_Account_Name ) );
                  S[LineLength] := VLine;
                  Writeln( XFile, S );

                  TRAVERSE.Clear;
                  TRAVERSE.SetSortMethod( csDateEffective );
                  TRAVERSE.SetSelectionMethod( twAllNewEntries );
                  TRAVERSE.SetOnEHProc( DoTransaction );
                  TRAVERSE.SetOnDSProc( DoDissection );
                  TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );

                  Writeln( XFile, Fill( 'C'+Vline+'No more data for this account...', LineLength-1 ), VLine );
                  
               
               end;
            end;
            Writeln( XFile, Fill( 'E'+VLine+'End of BankLink Data...', LineLength-1 ), VLine );
            OK := True;
         finally            
            System.Close( XFile );
         end;

         if OK then
         Begin
            Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
            LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulInfoMsg( Msg, 0 );
         end;
      end; { Scope of MyClient }
   finally
      Selected.Free;            
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.


