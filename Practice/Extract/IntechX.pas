unit IntechX;

(*
   Intech Contact is:

   Ken Forrest
   Intech Christchurch
   Phone 03 358 0920
   chch@intechsoftware.co.nz

   Intech Users:

   Martin Wakefield ( Julie Bruce )

*)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, StStrS, StDateSt, SysUtils,
     InfoMoreFrm, glConst, baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'IntechX';
   DebugMe  : Boolean = False;
   
CONST
   FiveMillion       : LongInt =  500000000;
   MinusHalfAMillion : LongInt =  -50000000;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   NoTrx         : Longint;
   CrValue       : Money;
   DrValue       : Money;
   CodeLength    : Byte;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function MakeIntechCode( OurCode : ShortString ): ShortString;
Var
   OurLen   : Byte Absolute OurCode;
   Main     : Integer;
   Sub      : Integer;
   MainStr  : String[10];
   SubStr   : String[10];
   SResult   : String[10];
   SLen     : Byte Absolute Result;
   i        : Byte;
Begin
   SResult := '000000';
   Case CodeLength of
      3 :
         Begin { Convert '45692 ' to '092456' }
            MainStr  := StStrS.TrimSpacesS( Copy( OurCode, 1, 3 ) );
            SubStr   := StStrS.TrimSpacesS( Copy( OurCode, 4, 2 ) );
            Main     := GenUtils.StrToIntSafe( MainStr );
            Sub      := GenUtils.StrToIntSafe( SubStr );
            Str( Main:3, MainStr ); Move( MainStr[1], SResult[4], 3 );
            Str( Sub:2, SubStr ); Move( SubStr[1], SResult[2], 2 );
            For i := 1 to SLen do If SResult[i]=' ' then SResult[i] := '0';
         end;
      4 :
         Begin { Convert '45672 ' to '024567' }
            MainStr  := StStrS.TrimSpacesS( Copy( OurCode, 1, 4 ) );
            SubStr   := StStrS.TrimSpacesS( Copy( OurCode, 5, 1 ) );
            Main     := GenUtils.StrToIntSafe( MainStr );
            Sub      := GenUtils.StrToIntSafe( SubStr );
            Str( Main:4, MainStr ); Move( MainStr[1], SResult[3], 4 );
            Str( Sub:1, SubStr ); Move( SubStr[1], SResult[2], 1 );
            For i := 1 to SLen do If SResult[i]=' ' then SResult[i] := '0';
         end;

      5 : Begin
             SResult := StStrS.TrimSpacesS( OurCode );
             If SLen > 6 then SLen := 6 else While SLen<6 do SResult := '0'+SResult;
          end;
   end;
   MakeIntechCode := SResult;
end;

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

Function S6_Amount( Amount: Money ): ShortString;

Var
   S      : String[20];
   Is_Neg : Boolean;
   i      : Integer;
Begin
   Is_Neg:=( Amount<0 ); If Is_Neg then Amount:=Amount*-1;
   Str( Amount/100:13:2,S ); If Is_Neg then S[1]:='-';
   For i:=2 to Length( S ) do if S[i]=' ' then S[i]:='0';
   S6_Amount:=S;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountHeader;

const
   ThisMethodName = 'DoAccountHeader';
var
   ac: string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   CrValue  := 0;
   DrValue  := 0;
   NoTrx    := 0;
   With MyClient.clFields, Bank_Account.baFields do
   Begin
      Write( XFile, 'A' );
      Write( XFile, Fill( clCode, 13 ) );
      ac := StripM(Bank_Account);
      Write( XFile, Fill( ac, 20 ) );
      Write( XFile, Date2Str( CurrentDate, 'dd/mm/yy' ) );
      Writeln( XFile, ConstStr( ' ', 36 ) );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure IntechWrite(  ADate    : TStDate;
                        ACode    : String;
                        ARefce   : String;
                        AAmount  : Money;
                        APart    : String;
                        AQty     : Money;
                        ADesc    : String );

   Procedure SaveEntryFor( M : Money );

   const
      ThisMethodName = 'SaveEntryFor';
   Var      
      S           : String[80];
      SLen        : Byte Absolute S;
      i           : Byte;
      IsActive    : boolean;
   Begin
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
      If MyClient.clChart.CanCodeTo( ACode, IsActive ) then
         Write( XFile, 'b' )
      else
         Write( XFile, 'B' );

      Write( XFile, Date2Str( ADate, 'dd/mm/yy' ) );

      Write( XFile, MakeIntechCode( ACode ) );

      S := GenUtils.FillRefce( ARefce );

      If GenUtils.IsNumeric( S ) then
      Begin { Pad to Six Digits if Necessary }
         While ( SLen < 6 ) do S := '0'+S;
         While ( SLen > 6 ) do System.Delete( S, 1, 1 );
      end
      else
      Begin
         S := StStrS.TrimSpacesS( S );
         While ( SLen < 6 ) do S := S + ' ';
         If ( SLen > 6 ) then Slen := 6;
      end;
      Write( XFile, S );

      Write( XFile, S6_Amount( M ) );

      Write( XFile, Fill( APart, 12 ) );

      if (Globals.PRACINI_ExtractQuantity) then
        Str( Abs( aQty )/10000:12:0, S )
      else
        Str( 0.0/10000:12:0, S );
      If aQty<0 then S[1] := '-' else S[1] := ' ';
      For i := 2 to SLen do If S[i]=' ' then S[i] := '0';
      Write( XFile, S );

      Write( XFile, Fill( ADesc, 20 ) );
      Writeln( XFile );

      Inc( NoTrx );

      If AAmount<0 then
         CrValue := CrValue + AAmount
      else
         DrValue := DrValue + AAmount;

      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   end;

Var
   Total : Money;
Begin
   Total := AAmount;
   While ( Total > FiveMillion ) do
   Begin
      SaveEntryFor( FiveMillion );
      Total := Total - FiveMillion;
   end;
   While ( Total < MinusHalfAMillion ) do
   Begin
      SaveEntryFor( MinusHalfAMillion );
      Total := Total - MinusHalfAMillion;
   end;
   SaveEntryFor( Total );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
Var
  CC : string[10];
  sOther : string[20];
  sPart  : string[12];
  Narration: string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);
      
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txGST_Class=0 ) then txGST_Amount := 0;
      If ( txFirst_Dissection = NIL ) then
      Begin
         Narration := Copy( GetNarration(TransAction,Bank_Account.baFields.baAccount_Type), 1, GetMaxNarrationLength);
         sOther := Copy( Narration, 1, 20);
         sPart  := Copy( Narration, 21, 12);
         IntechWrite( txDate_Effective,              { ADate    : Date;       }
                      txAccount,                     { ACode    : String;     }
                      GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                   { ARefce   : String;     }
                      txAmount- txGST_Amount,        { AAmount  : Money;      }
                      sPart,                         { APart    : String;     }
                      txQuantity,                    { AQty     : Money;      }
                      sOther                         { ADesc    : String );   }
                    );

         If txGST_Amount<>0 then
         Begin
            CC := '';
            if txGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ txGST_Class ];
            IntechWrite( txDate_Effective,           { ADate    : Date;       }
                         CC,                         { ACode    : String;     }
                         GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                { ARefce   : String;     }
                         txGST_Amount,               { AAmount  : Money;      }
                         sPart,              { APart    : String;     }
                         0,                          { AQty     : Money;      }
                         sOther               { ADesc    : String );   }
                      );
         end;
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
   CC : string[10];
   sOther : string[ 20];
   sPart  : string[ 12];
   Narration: string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      If ( dsGST_Class=0 ) then dsGST_Amount := 0;
      Narration := Copy(dsGL_Narration, 1, GetMaxNarrationLength);
      sOther := Copy( Narration, 1, 20);
      sPart  := Copy( Narration, 21, 12);

      IntechWrite( txDate_Effective,                      { ADate    : Date;       }
                   dsAccount,                             { ACode    : String;     }
                   getDsctReference(Dissection,Transaction ,Traverse.Bank_Account.baFields.baAccount_Type),
                                                          { ARefce   : String;     }
                   dsAmount - dsGST_Amount,               { AAmount  : Money;      }
                   sPart,                                 { APart    : String;     }
                   dsQuantity,                            { AQty     : Money;      }
                   sOther                                 { ADesc    : String );   }
                 );

      if dsGST_Amount<>0 then
      Begin
         CC := '';
         if dsGST_Class in [ 1..MAX_GST_CLASS ] then CC := clGST_Account_Codes[ dsGST_Class ];
         IntechWrite( txDate_Effective,                      { ADate    : Date;       }
                      CC,                                    { ACode    : String;     }
                      getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),
                                                             { ARefce   : String;     }
                      dsGST_Amount,                          { AAmount  : Money;      }
                      sPart,                                 { APart    : String;     }
                      0,                                     { AQty     : Money;      }
                      sOther                                 { ADesc    : String );   }
                    );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoAccountTrailer ;
Begin
   Write( XFile, 'C' );
   Write( XFile, S6_Amount( DrValue ) );
   Write( XFile, S6_Amount( abs( CrValue ) ) );
   Write( XFile, S6_Amount( CrValue+DrValue ) );
   Write( XFile, S6_Amount( abs( CrValue )+DrValue ) );
   Write( XFile, S6_Amount( 100*NoTrx ) );
   Write( XFile, ConstStr( ' ', 12 ) );
   Writeln( XFile );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
const
   ThisMethodName = 'ExtractData';

   HorzLine : char = #196;

var
   SI           : Smallint;
   Msg          : String;
//   Selected     : TStringList;
//   No           : Integer;
   BA           : TBank_Account;
   S            : String[80];
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Intech format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   With MyClient.clChart do
   Begin
      CodeLength := 3;
      if FindCode( 'CODE' )<>NIL then
      Begin
         S := FindDesc( 'CODE' );
         If StStrS.Str2Int16S( S, SI ) then
         Begin
            if ( SI in [ 3,4,5 ] ) then
            Begin
               CodeLength := SI;
               Msg := SysUtils.Format( 'Set the code length to %d based on chart', [ CodeLength ] );
               if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
            end;
         end;
      end;
   end;

   ba := SelectBankAccountForExport( FromDate, ToDate);
   if not Assigned( ba) then
     Exit;

   {
   Selected  := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   If Selected = NIL then exit;
   Try
   }
      with MyClient.clFields do
      begin
   {
         for No := 0 to Pred( Selected.Count ) do
         Begin
            BA := TBank_Account( Selected.Objects[ No ] );
   }
            With BA.baFields do
            Begin
               if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then
               Begin
                  HelpfulInfoMsg( 'There aren''t any new entries to extract from "'+baBank_Account_Number+'" in this date range!', 0 );
                  exit;
               end;

               if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then
               Begin
                  HelpfulInfoMsg( 'Account "'+baBank_Account_Number+'" has uncoded entries. ' +
                  'You must code all the entries before you can extract them.',  0 );
                  Exit;
               end;

               if BA.baFields.baContra_Account_Code = '' then
               Begin
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for this bank account. '+
                     ' To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
                  exit;
               end;

               If not HasRequiredGSTContraCodes( BA, FromDate, ToDate ) then
               Begin
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify the control account for each GST Class.' +
                     ' To do this, go to the Other Functions|GST Details and Rates option.', 0 );
                  exit;
               end;
            end;
   {      end; }


         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );

         Try
            NoOfEntries       := 0;
{
            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
}
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( twAllNewEntries );
               TRAVERSE.SetOnAHProc( DoAccountHeader );
               TRAVERSE.SetOnEHProc( DoTransaction );
               TRAVERSE.SetOnDSProc( DoDissection );
               TRAVERSE.SetOnATProc( DoAccountTrailer );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
{            end;}
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
{
   finally
      Selected.Free;
   end;
}
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.


