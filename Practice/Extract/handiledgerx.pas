unit handiledgerx;

{$I COMPILER}
{...$I DEBUGME}
{
   Author, SPA 25-05-99
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
     InfoMoreFrm, BKDefs, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'HandiLedgerX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile        : Text;
   Buffer       : array[ 1..2048 ] of Byte;
   NoOfEntries  : LongInt;
   TranNo       : LongInt;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure HWrite(  const ADate          : TStDate;
                   const AType          : char;
                   const AAccount       : ShortString;
                   const AAmount        : Money;
                   const AGSTAmount     : Money;
                   const AGSTClass      : Byte;
                   const ACheque_Number : ShortString;
                   const ANarration     : ShortString;
                   const AQuantity      : Money);

const
   ThisMethodName = 'HWrite';

Procedure MakeHLCode( Const OurCode : ShortString; 
                     Var   HLMainCode, HLSubCode : ShortString );
Var
  p : Byte;
  i, Count: Integer;
Begin
   HLMainCode := '';
   HLSubCode  := '';

   // Handiledger exports subcodes with a "/" delimiter.

   // How many seperators?
   Count := 0;
   for i := 1 to Length(OurCode) - 1 do
    if OurCode[i] = '/' then
      Inc(Count);

   if Count in [1..2] then
   begin
     p := Pos( '/', OurCode );
     if (p=3) and (Count = 1) then
     begin
       // Rule 4) if there is one separator in the code and the format is ##/####
       // then write the entire code including the separator to the Account field -
       // nothing is written to the sub field (change required)
       HLMainCode := OurCode;
       HLSubCode := '';
       exit;
     end
     else If p>0 then
     Begin
        // Rule 3) if there is one separator in the code and the format is ####/## (or anything else)
        // then write the characters before the separator to the Account field and
        // the characters after to the Sub field - the separator is not written (existing functionality)
        HLMainCode := StStrS.TrimSpacesS( Copy( OurCode, 1, p-1 ) );
        HLSubCode  := StStrS.TrimSpacesS( Copy( OurCode, p+1, 10 ) );
        if (Count = 1) and ((Length(HLMainCode) > 4) {or (Length(HLSubCode) > 2) Case #9187}) then
        begin
          HLMainCode := OurCode;
          HLSubCode := '';
          exit;
        end;
     end;
     if Count = 2 then
     begin
       // Rule 2) if there are two separators in the code, write the characters
       // before the second separator (including the first separator) to the Account
       // field and write the characters after the second separator to the Sub field
       // column 3 - the second separator is not written (change required)
       p := Pos( '/', HLSubCode );
       If p>0 then
       Begin
          HLMainCode := HLMainCode + '/' + StStrS.TrimSpacesS( Copy( HLSubCode, 1, p-1 ) );
          HLSubCode  := StStrS.TrimSpacesS( Copy( HLSubCode, p+1, 10 ) );
          exit;
       end;
     end
     else
       exit;
   end
   else if Count > 2 then
   begin // More than 2 seperators - invalid code so put it all in one column
     HLMainCode := OurCode;
     HLSubCode  := '';
     exit;
   end;

   // But it displays them with a '.' delimiter.

   // How many seperators?
   Count := 0;
   for i := 1 to Length(OurCode) - 1 do
    if OurCode[i] = '.' then
      Inc(Count);

   if Count in [1..2] then
   begin
     p := Pos( '.', OurCode );
     if (p=3) and (Count = 1) then
     begin
       // Rule 4) if there is one separator in the code and the format is ##/####
       // then write the entire code including the separator to the Account field -
       // nothing is written to the sub field (change required)
       HLMainCode := OurCode;
       HLSubCode := '';
       exit;
     end
     else If p>0 then
     Begin
        // Rule 3) if there is one separator in the code and the format is ####/## (or anything else)
        // then write the characters before the separator to the Account field and
        // the characters after to the Sub field - the separator is not written (existing functionality)
        HLMainCode := StStrS.TrimSpacesS( Copy( OurCode, 1, p-1 ) );
        HLSubCode  := StStrS.TrimSpacesS( Copy( OurCode, p+1, 10 ) );
        if (Count = 1) and ((Length(HLMainCode) > 4) or (Length(HLSubCode) > 2)) then
        begin
          HLMainCode := OurCode;
          HLSubCode := '';
          exit;
        end;
     end;
     if Count = 2 then
     begin
       // Rule 2) if there are two separators in the code, write the characters
       // before the second separator (including the first separator) to the Account
       // field and write the characters after the second separator to the Sub field
       // column 3 - the second separator is not written (change required)
       p := Pos( '.', HLSubCode );
       If p>0 then
       Begin
          HLMainCode := HLMainCode + '.' + StStrS.TrimSpacesS( Copy( HLSubCode, 1, p-1 ) );
          HLSubCode  := StStrS.TrimSpacesS( Copy( HLSubCode, p+1, 10 ) );
          exit;
       end;
     end
     else
       exit;
   end
   else if Count > 2 then
   begin // More than 2 seperators - invalid code so put it all in one column
     HLMainCode := OurCode;
     HLSubCode  := '';
     exit;
   end;

   // Rule 1) If all else fails, do it the old way...

   HLMainCode := StStrS.TrimSpacesS( Copy( OurCode, 1, 4 ) );
   HLSubCode  := StStrS.TrimSpacesS( Copy( OurCode, 5, 6 ) );
end;


Var
   Main  : string[10];
   Sub   : string[10];
   GSTCode : String[10];
   ExtractLength: Integer;
Begin // HWrite
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   (*
     0,4400,,J,01/07/94, ,1,"Year End Bal Fwd",4318.00,C,0,0,0
     0,4410,,J,01/07/94, ,1,"Year End Bal Fwd",4318.00,D,0,0,0
     0,4400,,J,01/07/94, ,1,"Year End Bal Fwd",5142.28,D,0,0,0
     0,4415,,J,01/07/94, ,1,"Year End Bal Fwd",5142.28,C,0,0,0
     0,4400,,J,01/07/94, ,1,"Year End Bal Fwd",1035.09,C,0,0,0
     0,4530,,J,01/07/94, ,1,"Year End Bal Fwd",1035.09,D,0,0,0
     0,1100,,J,01/07/94, ,1,"Year End Bal Fwd",7700.00,D,0,0,0
     0,2305,,J,01/07/94, ,1,"Year End Bal Fwd",7700.00,C,0,0,0
   *)

   MakeHLCode( AAccount, Main, Sub );
   Main := ReplaceCommasAndQuotes(Main);
   Sub := ReplaceCommasAndQuotes(Sub);

   Write( XFile, '"',TranNo, '",' );
   Write( XFile, '"',Main, '",' );
   Write( XFile, '"',Sub, '",' );

   write( XFile, '"',AType, '",' );

   Write( XFile, '"',Date2Str( ADate, 'dd/mm/yy' ), '",' );

   Write( XFile, '" ",' ); { " " = 'Presented' }

   Write( XFile, '"',ACheque_Number, '",' );

   ExtractLength := GetMaxNarrationLength;
   if ExtractLength > 40 then
     ExtractLength := 40;
   Write( XFile, '"', Copy(ReplaceCommasAndQuotes(ANarration), 1, ExtractLength ), '",' );

   Write( XFile, '"', Abs( AAmount )/100:0:2, '",' );

   If ( AAmount >= 0 ) then
      Write( XFile, '"D",' ) { Debit }
   else
      Write( XFile, '"C",' ); { Credit }

   if Bank_Account.baFields.baAccount_Type in [ btBank, btCashJournals] then
      Write( XFile, '"Y",' )  { Cash Flag }
   else
      Write( XFile, '"",' );

   Write( XFile, '"0",' ); { Opening Flag }
   Write( XFile, '"0",' ); { Closing Flag }

   // New fields as per Tony Cottis' e-mail of 8 Jun 2000.

   Write( XFile, '"', AAmount/100:0:2, '",' );                    { Signed Amount Field }

   Write( XFile, '"', ( AAmount - AGSTAmount )/100:0:2, '",' );   { ExclAmount }

   Write( XFile, '"', AGSTAmount/100:0:2, '",' );                 { Tax }

   GSTCode := '';
   If AGSTClass in [ 1..MAX_GST_CLASS ] then GSTCode := MyClient.clFields.clGST_Class_Codes[ AGSTClass ];
   Write( XFile, '"', GSTCode, '",' );                           { TaxCode }

   //quantity
   if (Globals.PRACINI_ExtractQuantity) then
     write( XFile, Abs( AQuantity/10000):0:0) //#1692 - sign not required for this interface
   else
     write( XFile,  0.0/10000:0:0);

   Writeln( XFile );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
   ThisMethodName = 'DoTransaction';
Var
   AType : Char;   
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Inc( TranNo );
   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);
      
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         If ( txAmount >= 0 ) then
            AType := 'P'
         else
            AType := 'R';
      
         HWrite(  txDate_Effective,      { ADate          : TStDate;         }
                  AType,                 { AType          : Char             }
                  txAccount,             { AAccount       : ShortString;     }
                  txAmount,              { AAmount        : Money;           }
                  txGST_Amount,          { AGSTAmount     : Money;           }
                  txGST_Class,           { AGSTClass      : Byte;            }
                  inttostr(txCheque_Number),       { ACheque_Number : LongInt;         }
                   GetNarration(TransAction,Bank_Account.baFields.baAccount_Type),        { ANarration     : ShortString      }
                  txQuantity);
      end;
      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
Var
   AType : Char;
   LCheque_Number : String;

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      If ( dsAmount >= 0 ) then
         AType := 'P'
      else
         AType := 'R';

      LCheque_Number := IntToStr(txCheque_Number);
      if Bank_Account.baFields.baAccount_Type in
        [btCashJournals,btAccrualJournals,btGSTJournals,btStockJournals] then
        if (txCheque_Number = 0)  // savety net
        and (Length(dsReference) > 0) then
           LCheque_Number := dsReference;

      HWrite(  txDate_Effective,      { ADate          : TStDate;         }
               AType,                 { AType          : Char             }
               dsAccount,             { AAccount       : ShortString;     }
               dsAmount,              { AAmount        : Money;           }
               dsGST_Amount,          { AGSTAmount     : Money;           }
               dsGST_Class,           { AGSTClass      : Byte;            }
               LCheque_Number,        { ACheque_Number : ShortString      }
               dsGL_Narration,        { ANarration     : ShortString      }
               dsQuantity);
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoContra;

const
   ThisMethodName = 'DoContra';
Var
   AType : Char;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      If ( txAmount >= 0 ) then
         AType := 'P'
      else
         AType := 'R';

      HWrite(  txDate_Effective,      { ADate          : TStDate;         }
               AType,                 { AType          : Char             }
               baContra_Account_Code, { AAccount       : ShortString;     }
               -txAmount,             { AAmount        : Money;           }
               0,                     { AGSTAmount     : Money;           }
               0,                     { AGSTClass      : Byte;            }
               '0',                   { ACheque_Number : ShortString;     }
                GetNarration(TransAction,Bank_Account.baFields.baAccount_Type),        { ANarration     : ShortString      }
               0);
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';

VAR
   BA  : TBank_Account;
   Msg : String;
   OK  : Boolean;
   Selected : TStringList;
   i : integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Msg := 'Extract data [HandiLedger format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );


   //select accounts
   Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   if Selected = NIL then
     exit;

   try
      //verify that there are new entries and that everything is coded
      for i := 0 to Selected.Count - 1 do
      begin
        ba := TBank_Account( Selected.Objects[ i]);
        if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
        begin
          HelpfulInfoMsg( 'There are no new entries to extract from "'+ ba.baFields.baBank_Account_Number+'" in this date range!', 0 );
          exit;
        end;

        if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then
        begin
          HelpfulInfoMsg( 'Account "'+ba.baFields.baBank_Account_Number+'" has uncoded entries. ' +
                           'You must code all the entries before you can extract them.',  0 );
          Exit;
        end;
      end;

      Assign( XFile, SaveTo );
      SetTextBuf( XFile, Buffer );
      Rewrite( XFile );
      try
        NoOfEntries := 0;
        TranNo      := 0;
        for i := 0 to Selected.Count - 1 do
        begin
          ba := TBank_Account( Selected.Objects[ i]);

          TRAVERSE.Clear;
          TRAVERSE.SetSortMethod( csDateEffective );
          TRAVERSE.SetSelectionMethod( twAllNewEntries );
          TRAVERSE.SetOnEHProc( DoTransaction );
          TRAVERSE.SetOnDSProc( DoDissection );
          TRAVERSE.SetOnETProc( DoContra );
          TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
        end;
        OK := True;
      finally
        System.Close( XFile );
      end;

      if OK then
      begin
        Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
        LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
        HelpfulInfoMsg( Msg, 0 );
      end;

   finally
     Selected.Free;
   end;


   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

