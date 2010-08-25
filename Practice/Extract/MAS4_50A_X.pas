unit MAS4_50A_X;

!! Not Used

{
   Author, SPA 07-09-1999

   This is the extract data program for Solution 6 MAS 4 Release 5.0A.

   The data is extracted in the internal MAS5.0 Ledger format.

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, StStrS, StDateSt, SysUtils,
     InfoMoreFrm, S6INI, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'MAS4_50A_X';
   DebugMe  : Boolean = False;
   UsingGST : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function MASDate( D : tstDate ): ShortString;
Begin
   Result := StDateToDateString( 'dd/mm/yyyy', d, False );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function InternalMASAmount( M : Money ): ShortString;

Var
   S : String[20];
Begin
   If M=0 then             {1234567890123}
   Begin                   {123456789.12 }
      result :=            '        -    ';
      exit;
   end;
   Str( Abs( M )/100.0:0:2, S );
   If ( M < 0 ) then S := '(' + S + ')' else S := S + ' ';
   While Length( S ) < 13 do S := ' ' + S;
   Result := S;
end;

function InternalMASQty( M : Money ): ShortString;

Var
   S : String[20];
Begin
   If M=0 then             {1234567890123}
   Begin                   {123456789.12 }
      result :=            '        -    ';
      exit;
   end;
   S := GetQuantityStringForExtract(Abs( M ), 2);
   If ( M < 0 ) then S := '(' + S + ')' else S := S + ' ';
   While Length( S ) < 13 do S := ' ' + S;
   Result := S;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   Contra        : Money;
   GSTTotals     : array[ 0..MAX_GST_CLASS ] of Money; { GLOBALS.MAX_GST_CLASS }
   GST_Inclusive : Boolean;
   Credits       : Money;
   Debits        : Money;
   D1, D2        : TStDate;
   ECount        : Longint;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure Add( M : Money );
Begin
   If M < 0 then
      Credits := Credits + M
  else
      Debits := Debits + M;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountHeader;

const
   ThisMethodName = 'DoAccountHeader';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Contra := 0;
   FillChar( GSTTotals, Sizeof( GSTTotals ), 0 );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountTrailerWithGST;
const
   ThisMethodName = 'DoAccountTrailerWithGST';
Var
   i : Integer;
   L : ShortString;
   S : String[80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields do
   Begin
      For i := 1 to MAX_GST_CLASS do if GSTTotals[i]<>0 then
      Begin
         L := ConstStr( ' ', 150 );
         S := MASDate( D2 );                       Move( S[1], L[ 1], Length( S ) );
         S := 'BSt';                               Move( S[1], L[12], Length( S ) );
         S := 'Contra Tax entry';                  Move( S[1], L[29], Length( S ) );
         S := clGST_Account_Codes[i];              Move( S[1], L[73], Length( S ) );
         L[96] := '-'; { Bal2 }
         S := IntToStr( i );                       Move( S[1], L[ 104 - Length( S )], Length( S ) );
//         L[103] := Chr( Ord( '0' ) + i ); { '1' to '9' }
         L[114] := '-';
         S := InternalMASAmount( GSTTotals[i] );  Move( S[1], L[122], Length( S ) );
         Add( GSTTotals[i] );
         S := baContra_Account_Code;              Move( S[1], L[135], Length( S ) );
         L[146] := 'T';
         Writeln( XFile, TrimTrailS( L ) );
         Inc( ECount );
      end;
      if Contra <> 0 then
      Begin
         L := ConstStr( ' ', 150 );
         S := MASDate( D2 );                       Move( S[1], L[ 1], Length( S ) );
         S := 'BSt';                               Move( S[1], L[12], Length( S ) );
         S := 'Contra Bank entry';                 Move( S[1], L[29], Length( S ) );

         S := baContra_Account_Code;               Move( S[1], L[73], Length( S ) );
         L[96]    := '-'; { Bal2 }
         L[103]   := '-'; { Rate }
         L[114]   := '-'; { Tax }
         S := InternalMASAmount( -Contra );        Move( S[1], L[122], Length( S ) );
         Add( -Contra );
         S := baContra_Account_Code;               Move( S[1], L[135], Length( S ) );
         L[146] := 'B';
         Writeln( XFile, TrimTrailS( L ) );
         Inc( ECount );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountTrailerNoGST;
const
   ThisMethodName = 'DoAccountTrailerNoGST';
Var
   i : Integer;
   L : ShortString;
   S : String[80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields do
   Begin
      if Contra <> 0 then
      Begin
         L := ConstStr( ' ', 143 );
         S := MASDate( D2 );                       Move( S[1], L[ 1], Length( S ) );
         S := 'BSt';                               Move( S[1], L[12], Length( S ) );
         S := 'Contra Bank entry';                 Move( S[1], L[29], Length( S ) );
         S := baContra_Account_Code;               Move( S[1], L[72], Length( S ) );

         L[97] := '-'; { Quantity }
         S := InternalMASAmount( -Contra );        Move( S[1], L[105], Length( S ) );
         Add( -Contra );

         S := baContra_Account_Code;               Move( S[1], L[119], Length( S ) );
         L[130] := 'B';
         S := baContra_Account_Code;               Move( S[1], L[133], Length( S ) );
         Writeln( XFile, TrimTrailS( L ) );
         Inc( ECount );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransactionWithGST;

const
   ThisMethodName = 'DoTransactionWithGST';
Var
   S : String[80];
   L : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         L := ConstStr( ' ', 150 );
         S := MASDate( txDate_Effective );  Move( S[1], L[ 1], Length( S ) );
         S := 'BSt';                        Move( S[1], L[12], Length( S ) );

         If ( txCheque_Number = 0 ) then
            S := ''
         else
         Begin
            Str( txCheque_Number, S );
            While ( Length( S )>6 ) do System.Delete( S, 1, 1 );
            While ( Length( S )<6 ) do S:=' '+S;
         end;

         Move( S[1], L[20], Length( S ) );

         Case clCountry of
            whNewZealand : S := Genutils.MakeComment( Reverse, txOther_Party, txParticulars );
            whAustralia  : S := Copy(txOld_Narration, 1, GetMaxNarrationLength);
         end;

         While Length( S ) > 40 do
         Begin
            Move( S[1], L[29], 40 );
            Writeln( XFile, TrimTrailS( L ) );
            Delete( S, 1, 40 );
            L := ConstStr( ' ', 150 );
         end;

         Move( S[1], L[29], Length( S ) );

         S := txAccount; Move( S[1], L[73], Length( S ) );

         if (Globals.PRACINI_ExtractQuantity) then
           S := InternalMASQty( txQuantity )
         else
           S := InternalMASQty( 0.0 );
         Move( S[1], L[88], Length( S ) );

         If not ( txGST_Class in [ 1..MAX_GST_CLASS ] ) then
         Begin
            txGST_Class  := 0;
            txGST_Amount := 0;
         end;

         If GST_Inclusive or ( txGST_Class = 0 ) then
         Begin
            L[103] := '-'; { Rate }
            S := InternalMASAmount( 0 );   Move( S[1], L[106], Length( S ) );
            S := InternalMASAmount( txAmount );
            Move( S[1], L[122], Length( S ) );
            Add( txAmount );
         end
         else
         Begin
            S := IntToStr( txGST_Class );                      Move( S[1], L[ 104 - Length( S )], Length( S ) );
//            L[103] := Chr( Ord( '0' ) + txGST_Class );
            GSTTotals[ txGST_Class ] := GSTTotals[ txGST_Class ] + txGST_Amount;
            S := InternalMASAmount( txGST_Amount );            Move( S[1], L[106], Length( S ) );
            S := InternalMASAmount( txAmount - txGST_Amount ); Move( S[1], L[122], Length( S ) );
            Add( txAmount - txGST_Amount );
         end;

         S := baContra_Account_Code;               Move( S[1], L[135], Length( S ) );
         L[146] := ' ';
         Writeln( XFile, TrimTrailS( L ) );
         Contra := Contra + txAmount;
         Inc( ECount );
      end;
      Inc ( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransactionNoGST;

const
   ThisMethodName = 'DoTransactionNoGST';
Var
   S : String[80];
   L : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         L := ConstStr( ' ', 136 );
         S := MASDate( txDate_Effective );  Move( S[1], L[ 1], Length( S ) );
         S := 'BSt';                        Move( S[1], L[12], Length( S ) );

         If ( txCheque_Number = 0 ) then
            S := ''
         else
         Begin
            Str( txCheque_Number, S );
            While ( Length( S )>6 ) do System.Delete( S, 1, 1 );
            While ( Length( S )<6 ) do S:=' '+S;
         end;

         Move( S[1], L[20], Length( S ) );

         Case clCountry of
            whNewZealand : S := Genutils.MakeComment( Reverse, txOther_Party, txParticulars );
            whAustralia  : S := Copy(tx{removeme}Narration, 1, GetMaxNarrationLength);
         end;

         While Length( S ) > 40 do
         Begin
            Move( S[1], L[29], 40 );
            Writeln( XFile, TrimTrailS( L ) );
            Delete( S, 1, 40 );
            L := ConstStr( ' ', 136 );
         end;

         Move( S[1], L[29], Length( S ) );

         S := txAccount;                                Move( S[1], L[72], Length( S ) );

         if (Globals.PRACINI_ExtractQuantity) then
           S := InternalMASAmount( txQuantity / 10.0 )
         else
           S := InternalMASAmount( 0.0 );
         Move( S[1], L[89], Length( S ) );
         S := InternalMASAmount( txAmount );            Move( S[1], L[105], Length( S ) );
         Add( txAmount );

         S := baContra_Account_Code;                    Move( S[1], L[119], Length( S ) );
         L[130] := ' ';
         Writeln( XFile, TrimTrailS( L ) );
         Contra := Contra + txAmount;
         Inc( ECount );
      end;
      Inc ( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissectionWithGST ;

const
   ThisMethodName = 'DoDissectionWithGST';
Var 
   S : String[80];
   L : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      L := ConstStr( ' ', 150 );
      S := MASDate( txDate_Effective );  Move( S[1], L[ 1], Length( S ) );
      S := 'BSt';  Move( S[1], L[12], Length( S ) );

      If ( txCheque_Number = 0 ) then
         S := ''
      else
      Begin
         Str( txCheque_Number, S );
         While ( Length( S )>6 ) do System.Delete( S, 1, 1 );
         While ( Length( S )<6 ) do S:=' '+S;
      end;
      Move( S[1], L[20], Length( S ) );

      If ( dsNarration<>'' ) then
         S := Copy(dsNarration, 1, GetMaxNarrationLength)
      else
      Begin
         Case clCountry of
            whNewZealand : S := Genutils.MakeComment( Reverse, txOther_Party, txParticulars );
            whAustralia  : S := Copy(tx{removeme}Narration, 1, GetMaxNarrationLength);
         end;
      end;

//!!!!!!!!!!!

      Move( S[1], L[29], Length( S ) );

      S := dsAccount;                                  Move( S[1], L[73], Length( S ) );
      if (Globals.PRACINI_ExtractQuantity) then
        S := InternalMASAmount( dsQuantity / 10.0 )
      else
        S := InternalMASAmount( 0.0 );
      Move( S[1], L[88], Length( S ) );

      If not ( dsGST_Class in [ 1..MAX_GST_CLASS ] ) then
      Begin
         dsGST_Class := 0;
         dsGST_Amount := 0;
      end;

      If GST_Inclusive or ( dsGST_Class = 0 ) then
      Begin
         L[103] := '-'; { Rate }
         S := InternalMASAmount( 0 );   Move( S[1], L[106], Length( S ) );
         S := InternalMASAmount( dsAmount );
         Move( S[1], L[122], Length( S ) );
         Add( dsAmount );
      end
      else
      Begin
         S := IntToStr( dsGST_Class );                      Move( S[1], L[ 104 - Length( S )], Length( S ) );
//         L[103] := Chr( Ord( '0' ) + dsGST_Class );
         GSTTotals[ dsGST_Class ] := GSTTotals[ dsGST_Class ] + dsGST_Amount;
         S := InternalMASAmount( dsGST_Amount );            Move( S[1], L[106], Length( S ) );
         S := InternalMASAmount( dsAmount - dsGST_Amount ); Move( S[1], L[122], Length( S ) );
         Add( dsAmount - dsGST_Amount );
      end;

      S := baContra_Account_Code;               Move( S[1], L[135], Length( S ) );
      L[146] := ' ';
      Writeln( XFile, TrimTrailS( L ) );
      Contra := Contra + dsAmount;
      Inc( ECount );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissectionNoGST ;

const
   ThisMethodName = 'DoDissectionWithGST';
Var
   S : String[80];
   L : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      L := ConstStr( ' ', 136 );
      S := MASDate( txDate_Effective );  Move( S[1], L[ 1], Length( S ) );
      S := 'BSt';                        Move( S[1], L[12], Length( S ) );

      If ( txCheque_Number = 0 ) then
         S := ''
      else
      Begin
         Str( txCheque_Number, S );
         While ( Length( S )>6 ) do System.Delete( S, 1, 1 );
         While ( Length( S )<6 ) do S:=' '+S;
      end;

      Move( S[1], L[20], Length( S ) );

      If ( dsNarration<>'' ) then
         S := Copy(dsNarration, 1, GetMaxNarrationLength)
      else
      Begin
         Case clCountry of
            whNewZealand : S := Genutils.MakeComment( Reverse, txOther_Party, txParticulars );
            whAustralia  : S := Copy(tx{removeme}Narration, 1, GetMaxNarrationLength);
         end;
      end;

      While Length( S ) > 40 do
      Begin
         Move( S[1], L[29], 40 );
         Writeln( XFile, TrimTrailS( L ) );
         Delete( S, 1, 40 );
         L := ConstStr( ' ', 136 );
      end;

      S := dsAccount;                                Move( S[1], L[72], Length( S ) );
      if (Globals.PRACINI_ExtractQuantity) then
        S := InternalMASAmount( dsQuantity / 10.0 )
      else
        S := InternalMASAmount( 0.0 );
      Move( S[1], L[89], Length( S ) );
      S := InternalMASAmount( dsAmount );            Move( S[1], L[105], Length( S ) );
      Add( dsAmount );

      S := baContra_Account_Code;                    Move( S[1], L[119], Length( S ) );
      L[130] := ' ';
      Writeln( XFile, TrimTrailS( L ) );
      Contra := Contra + dsAmount;
      Inc( ECount );
   
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
const
   ThisMethodName = 'ExtractData';
   HorzLine : char = #196;
   
var
   GI           : Boolean;
   Msg          : String; 
   Selected     : TStringList;
   No           : Integer;
   i            : Integer;  
   ti           : Integer;
   M1, Y1       : Integer;
   M,Y          : Integer;
   BA           : TBank_Account;
   L            : ShortString;
   S            : String[80];
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   OK := False;

   Msg := 'Extract data [MAS42 format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );
   
   Selected  := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
   If Selected = NIL then exit;

   Try
      with MyClient.clFields do
      begin

         for No := 0 to Pred( Selected.Count ) do
         Begin
            BA := TBank_Account( Selected.Objects[ No ] );
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
            end;
         end;

         UsingGST := False;
         for No := 0 to Pred( Selected.Count ) do
         Begin
            BA := TBank_Account( Selected.Objects[ No ] );
            UsingGST := UsingGST or TravUtils.HasAnyGST( BA, FromDate, ToDate );
         end;

         GI := Globals.PRACINI_REMOVEGST; { Usually FALSE }
         If UsingGST and Globals.PRACINI_PromptForGST then
         Begin
            Case GI of
               TRUE  :  GI := ( AskYesNo('GST Inclusive?','Do you want to transfer the entries GST INCLUSIVE?',
                                DLG_YES,0) = DLG_YES);

               FALSE :  GI := ( AskYesNo('GST Inclusive?','Do you want to transfer the entries GST INCLUSIVE?',
                                            DLG_NO,0) = DLG_YES);
            end;
         end;
         GST_Inclusive := GI;

         if ( not GST_Inclusive ) then
         begin { We will be creating entries for the GST Totals, so we need to check that the GST contra accounts exist }
            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
               If not HasRequiredGSTContraCodes( BA, FromDate, ToDate ) then
               Begin
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify the control account for each GST Class.' + 
                     ' To do this, go to the Other Functions|GST Details and Rates option.', 0 );
                  exit;
               end;
            end;
         end;
         
         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile ); 
      
         Try
            if UsingGST then
            Begin
            
               { - - - - - - - - - - - - - - - -  }
         
               L := ConstStr( ' ', 150 );
               S := MASDate( CurrentDate ); Move( S[1], L[1], Length( S ) );
               S := MyClient.clFields.clName;
               Move( S[1], L[ ( 150 - Length( S ) ) div 2 ], Length( S ) );
               S := 'Page 1'; Move( S[1], L[144], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );

               { - - - - - - - - - - - - - - - -  }
            
               L := ConstStr( ' ', 150 );
               S := CurrentTimeString( 'hh:mm', true);        Move( S[1], L[1], Length( S ) );
               S := 'Export Transactions';                    Move( S[1], L[65], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );

               { - - - - - - - - - - - - - - - -  }
            
               L := ConstStr( ' ', 150 );
               S := 'Client Code:';                           Move( S[1], L[1], Length( S ) );
               S := MyClient.clFields.clCode;                   Move( S[1], L[14], Length( S ) );
               S := 'Tax Ledger';                             Move( S[1], L[32], Length( S ) );
               S := 'From '+MASDate( FromDate ) + ' To '+MASDate( ToDate ); Move( S[1], L[64], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );

               { - - - - - - - - - - - - - - - -  }
            
               Writeln( XFile, ConstStr( HorzLine, 148 ) );

               { - - - - - - - - - - - - - - - -  }
            
               Write( XFile, '  Date   Type    Ref.      Narration                                  Account   ' );
               Writeln( XFile, '          Bal2    Rate      Tax         Amount      Bank      B/T Curr' );

               { - - - - - - - - - - - - - - - -  }
            
               Writeln( XFile, ConstStr( HorzLine, 148 ) );

               NoOfEntries       := 0;
               ECount            := 0;
               Debits            := 0;
               Credits           := 0;

               for No := 0 to Pred( Selected.Count ) do
               Begin
                  BA := TBank_Account( Selected.Objects[ No ] );
                  StDateToDMY( FromDate, ti, M1, Y1 ); { 01-04-97 }
                  M := M1; Y := Y1;
                  Repeat
                     D1 := DMYToStDate( 1, M, Y, Epoch );
                     If D1<FromDate then D1 := FromDate;
                     D2 := DMYToStDate( DaysInMonth( M, Y, Epoch ), M, Y, Epoch );
                     If D2 > ToDate then D2 := ToDate;

                     TRAVERSE.Clear;
                     TRAVERSE.SetSortMethod( csDateEffective );
                     TRAVERSE.SetSelectionMethod( twAllNewEntries );
                     TRAVERSE.SetOnAHProc( DoAccountHeader );
                     TRAVERSE.SetOnEHProc( DoTransactionWithGST );
                     TRAVERSE.SetOnDSProc( DoDissectionWithGST );
                     TRAVERSE.SetOnATProc( DoAccountTrailerWithGST );
                     TRAVERSE.TraverseEntriesForAnAccount( BA, D1, D2 );

                     Inc( M ); If M>12 then Begin M:= 1; Inc( Y ); end;
                  Until ( D2 = ToDate );
               end;
               For i := 1 to 3 do Writeln( XFile );

               L := ConstStr( ' ', 150 );
               S := 'Debits:'; Move( S[1], L[37], Length( S ) );
               S := InternalMASAmount( Abs( Debits ) ); Move( S[1], L[44], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );

               L := ConstStr( ' ', 150 );
               S := 'Credits:'; Move( S[1], L[36], Length( S ) );
               S := InternalMASAmount( Abs( Credits ) ); Move( S[1], L[44], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );
               Writeln( XFile );

               L := ConstStr( ' ', 150 );
               S := 'Total: '; Move( S[1], L[38], Length( S ) );
               S := InternalMASAmount( Credits + Debits ); Move( S[1], L[44], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );

               L := ConstStr( ' ', 150 );
               S := 'No. of Entries:'; Move( S[1], L[29], Length( S ) );
               Str( ECount, S ); Move( S[1], L[45], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );

               Writeln( XFile );
               Writeln( XFile );
            end
            else
            Begin
               L := ConstStr( ' ', 136 );
               S := MASDate( CurrentDate ); Move( S[1], L[1], Length( S ) );
               S := MyClient.clFields.clName;
               Move( S[1], L[ ( 136 - Length( S ) ) div 2 ], Length( S ) );
               S := 'Page 1'; Move( S[1], L[131], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );

               { - - - - - - - - - - - - - - - -  }
               
               L := ConstStr( ' ', 136 );
               S := CurrentTimeString( 'hh:mm', true);    Move( S[1], L[1], Length( S ) );
               S := 'Export Transactions';                Move( S[1], L[59], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );
               
               { - - - - - - - - - - - - - - - -  }
            
               L := ConstStr( ' ', 136 );
               S := 'Client Code:';                       Move( S[1], L[1], Length( S ) );
               S := MyClient.clFields.clCode;             Move( S[1], L[14], Length( S ) );
               S := 'No Tax Ledger';                      Move( S[1], L[32], Length( S ) );
               S := 'From '+MASDate( FromDate ) + 
                    ' To '+MASDate( ToDate );             Move( S[1], L[48], Length( S ) );
               Writeln( XFile, TrimTrailS( L ) );
               Writeln( XFile, ConstStr( HorzLine, 136 ) );
               Writeln( XFile, '  Date     Type    Reference Narration' + 
                 '                                  Account             Bal2'+
                 '           Amount     Bank      B/T Curr' );

               Writeln( XFile, ConstStr( HorzLine, 136 ) );

               { ------------------------------------------------------------- }
               
               NoOfEntries       := 0;
               ECount            := 0;
               Debits            := 0;
               Credits           := 0;

               for No := 0 to Pred( Selected.Count ) do
               Begin
                  BA := TBank_Account( Selected.Objects[ No ] );
                  StDateToDMY( FromDate, ti, M1, Y1 ); { 01-04-97 }
                  M := M1; Y := Y1;
                  Repeat
                     D1 := DMYToStDate( 1, M, Y, Epoch );
                     If D1<FromDate then D1 := FromDate;
                     D2 := DMYToStDate( DaysInMonth( M, Y, Epoch ), M, Y, Epoch );
                     If D2 > ToDate then D2 := ToDate;

                     TRAVERSE.Clear;
                     TRAVERSE.SetSortMethod( csDateEffective );
                     TRAVERSE.SetSelectionMethod( twAllNewEntries );
                     TRAVERSE.SetOnAHProc( DoAccountHeader );
                     TRAVERSE.SetOnEHProc( DoTransactionNoGST );
                     TRAVERSE.SetOnDSProc( DoDissectionNoGST );
                     TRAVERSE.SetOnATProc( DoAccountTrailerNoGST );
                     TRAVERSE.TraverseEntriesForAnAccount( BA, D1, D2 );

                     Inc( M ); If M>12 then Begin M:= 1; Inc( Y ); end;
                  Until ( D2 = ToDate );
               end;
               
               For i := 1 to 3 do Writeln( XFile );
               
               Str( Abs( Debits )/100:0:2, S );
               L := ConstStr( ' ', 36 ) + 'Debits: ' + S;
               Writeln( XFile, TrimTrailS( L ) );

               Str( Abs( Credits )/100:0:2, S );
               L := ConstStr( ' ', 35 ) + 'Credits: ' + S;
               Writeln( XFile, TrimTrailS( L ) );
               
               Writeln( XFile );

               L := ConstStr( ' ', 37 ) + 'Total: -';
               Writeln( XFile, TrimTrailS( L ) );

               Str( ECount, S );
               L := ConstStr( ' ', 28 ) + 'No. of Entries: ' + S;
               Writeln( XFile, TrimTrailS( L ) );
               
               Writeln( XFile );
               Writeln( XFile );
            end;
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

