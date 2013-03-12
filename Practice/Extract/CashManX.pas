unit CashManX;

(*

   Contact Details for Cash Manager:-

   Mr Peter Busch
   Accomplish P/L
   PO Box 456
   Neutral Bay
   Sydney

   Ph 02 9904 1442
   Fx 02 9904 1871

   Supported locally by Burge Business Systems
   
   Phone 09-524-7099
   Fax 09-524-9793
   Email info@burge.co.nz    Freepost 3039
   P O Box 74-310
   AUCKLAND 1130
   New Zealand  

   03-Apr-2000: removed the 'dissection' count in each line by setting it to zero.
   Cash Manager can't cope with dissected entries where the entry type for each dissection 
   line is different - occurs when you gross up Amex sales and results in an incorrect amount
   going through into Cash Manager.

   22 Apr 2002 : mjch reintroducted the dissection count code.  dissections could not be
                 imported at all with above change.  Have tested 5.0.0.309 with latest
                 burge version and tested ok.

                 Max narration length = 30 chars

*)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils,
     InfoMoreFrm, BKDefs, StStrS, baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'CASHMANX';
   DebugMe  : Boolean = False;
   

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;
   Total         : Money;
   GSTTotal      : Money;
   dCount        : integer;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoAccountHeader ;

const
   ThisMethodName = 'DoAccountHeader';

   Function FormatAccountCode( Code, Mask : ShortString ): ShortString;
   Var
      p : Byte;
      i : Byte;
      
   Begin
      p := 0;
      Result := '';
      For i := 1 to Length( Mask ) do
      Begin
         If ( Mask[i] = '-' ) then
            Result := Result + '-'
         else
         Begin
            Inc( p );
            if p <= Length( Code ) then 
               Result := Result + Code[p];
         end;
      end;
   end;

Var S : String[61];
    C : String[20];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S := ConstStr( ' ', 61 );
   C := '';

   With MyClient.clFields, Bank_Account.baFields do
   Begin
      Case clCountry of
         whNewZealand : C := FormatAccountCode( StripM(Bank_Account), '##-####-########-###' );
         whAustralia  : C := FormatAccountCode( StripM(Bank_Account), '###-###-#########' );
      end;
      S[1]:= '1';
      Move( C[1], S[2], Length( C ) );
      Writeln( XFile, S );
   end;
   Total    := 0;
   GSTTotal := 0;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function GetEntryType( T : Byte; Amount : Money ): Byte;

const
   ThisMethodName = 'GetEntryType';

Const
   cshUnknown       = 0;
   cshDeposit       = 1;
   cshCheque        = 2;
   cshDirectCredit  = 3;
   cshDirectDebit   = 4;

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Result := cshUnknown;
   With MyClient.clFields do
   Begin
      Case clCountry of
         whNewZealand :
            Begin
               if (T in [0,3,4,5,6,7,8,9]) and ( Amount > 0 ) then Result := cshCheque else
               if (T in [38,50,52,56,57,65,84,85]) and ( Amount < 0 ) then Result := cshDeposit else
               if (Amount > 0) then Result := cshDirectDebit else
               if (Amount < 0) then Result := cshDirectCredit;
            end;
         whAustralia  :
            Begin
               if (T in [1]) and ( Amount > 0 ) then Result := cshCheque else
               if (T in [10]) and ( Amount < 0 ) then Result := cshDeposit else
               if (Amount > 0) then Result := cshDirectDebit else
               if (Amount < 0) then Result := cshDirectCredit;
            end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------

function StripOutDash( Const OurRef : ShortString ): ShortString;
var
   p : Byte;
begin
   Result := '';
   for p := 1 to Length( OurRef) do
      if OurRef[ p] <> '-' then
         Result := Result + OurRef[ p];
end;

//------------------------------------------------------------------------------


procedure CashmanWrite(  const ADate          : TStDate;
                         const AType          : Byte;
                         const ARefce         : ShortString;
                         const AAccount       : ShortString;
                         const AAmount        : Money;
                         const AGST_Amount    : Money;
                         const AQuantity      : Money;
                         const ANarration     : ShortString;
                         const ADissectionNo  : integer );
const
   ThisMethodName = 'CashmanWrite';
Var
   S  : ShortString;
   No : LongInt;
   X : Byte;
   ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Write( XFile, '2' );
   Write( XFile, Date2Str( ADate, 'dd/mm/yyyy' ) );
   X := GetEntryType( AType, AAmount );
   Write( XFile, X:1 );

   { ------------------------------------------- }

   //strip "-" char from reference.  This is a hack to fix a problem
   //in the Burge Import routines
   S := StStrS.TrimSpacesS( StripOutDash( ARefce));
   While Length( S ) > 6 do System.Delete( S, 1, 1 );
   No := 0;
   if Str2LongS( S, No ) then
   Begin
      If No = 0 then Write( XFile, '':6 ) else Write( XFile, No:6 );
   end
   else
      Write( XFile, '':6 );

   { ------------------------------------------- }

   S := TrimSpacesS( AAccount );
   While Length( S ) < 8 do S := S + ' ';
   Write( XFile, Copy( S, 1, 8 ) );

   { ------------------------------------------- }

   Str( AAmount/100:14:2, S );
   Write( XFile, S );

   { ------------------------------------------- }

   Str( AGST_Amount/100:14:2, S );
   Write( XFile, S );

   { ------------------------------------------- }

   if (Globals.PRACINI_ExtractQuantity) then
     Str( AQuantity/10000:9:0, S )
   else
     Str( 0.0:9:0, S );
   Write( XFile, S ); { No decimals }

   { ------------------------------------------- }

   ExtractLength := GetMaxNarrationLength;
   if ExtractLength > 30 then
     ExtractLength := 30;
   S := Copy(ANarration, 1, ExtractLength);
   While Length( S ) < 30 do S := S + ' ';
   Write( XFile, Copy( S, 1, 30 ) );

   { ------------------------------------------- }

   Writeln( XFile, ADissectionNo :8 ); { Was a dissection count but this didn't work in Cash Manager }

   Total := Total + AAmount;
   GSTTotal := GSTTotal + AGST_Amount;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
  ThisMethodName = 'DoTransaction';
Var
  S  : String[80];
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
         If ( txGST_Class=0 ) then txGST_Amount := 0;
         CashmanWrite( txDate_Effective,      { const ADate          : TStDate;      }
                       txType,                { const AType          : Byte;         }
                       GetReference(TransAction,Bank_Account.baFields.baAccount_Type),           { const ARefce         : ShortString;  }
                       txAccount,             { const AAccount       : ShortString;  }
                       txAmount,              { const AAmount        : Money;        }
                       txGST_Amount,          { const AGST_Amount    : Money;        }
                       txQuantity,            { const AQuantity      : Money;        }
                       S,                     { const ANarration     : ShortString;  }
                       0                      { ADissectioNo}
                      );
      end
      else
         Inc( dCount);

      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
var
   S : string[ 80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with MyClient.clFields, Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      If ( dsGST_Class=0 ) then dsGST_Amount := 0;
      CashmanWrite( txDate_Effective,      { const ADate          : TStDate;      }
                    txType,                { const AType          : Byte;         }
                    getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),           { const ARefce         : ShortString;  }
                    dsAccount,             { const AAccount       : ShortString;  }
                    dsAmount,              { const AAmount        : Money;        }
                    dsGST_Amount,          { const AGST_Amount    : Money;        }
                    dsQuantity,            { const AQuantity      : Money;        }
                    S,                     { const ANarration     : ShortString;  }
                    dCount                 { ADissectionNo }
                   );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoAccountTrailer;

const
   ThisMethodName = 'DoAccountTrailer';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Write( XFile, '3' );
   Write( XFile, Total/100:14:2 );
   Write( XFile, GSTTotal/100:14:2 );
   Writeln( XFile );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';
var
   Msg          : String;
   Selected     : TStringList;
   BA           : TBank_Account;
   No           : Integer;
   OK           : Boolean;
   S            : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [Cash Manager format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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
            end;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );

         Try

            Write( XFile, '0' );
            S := clName + ' ['+Date2Str( CurrentDate, 'dd/mm/yy' )+']';
            While Length( S )<60 do S := S + ' ';
            Writeln( XFile, Copy( S, 1, 60 ) );

            NoOfEntries := 0;
            dCount      := 0;

            for No := 0 to Pred( Selected.Count ) do
            Begin
               BA := TBank_Account( Selected.Objects[ No ] );
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
               TRAVERSE.SetOnAHProc( DoAccountHeader );
               TRAVERSE.SetOnEHProc( DoTransaction );
               TRAVERSE.SetOnDSProc( DoDissection );
               TRAVERSE.SetOnATProc( DoAccountTrailer );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
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



