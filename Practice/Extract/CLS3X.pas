unit CLS3X;

{
   Author, SPA 24-05-99

   This is the extract data program for Solution 6 MAS 3.x and is imported
   using Cheque List.

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, StStrS, StDateSt, SysUtils,
     InfoMoreFrm, baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'CLS3X';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
   NoOfEntries   : LongInt;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function Fill( M : ShortString; Size : integer ): ShortString;
{create fixed with fields filled with space}
begin
   while Length( M ) < Size do M := M + ' ';
   result := Copy( M, 1, Size );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   The initial file spec for transferring into Solution 6 only allowed 10
   characters for the amount field, so this would overflow on large amounts. The
   program puts in multiples of Five Million or Minus Half a Million until the
   remainder is within the valid range, then puts that too.
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CLS3Write(  const ADate       : TStDate;
                      const AType       : Byte;
                      const ARefce      : ShortString;
                      const AAccount    : ShortString;
                      const AAmount     : Money;
                      const ANarration  : ShortString );

   procedure CLS3WriteEntryFor( HowMuch : Money );

   const
      ThisMethodName = 'CLS3WriteEntryFor';
      VLine : char = #179;
   var
     ExtractLength: Integer;   
   Begin
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
      write( XFile, Date2Str( ADate, 'dd/mm/yy' ), VLine );
      write( XFile, AType:3, VLine );
      Write( XFile, GenUtils.FillRefce( ARefce ), VLine );
      Write( XFile, Fill( AAccount ,10 ), VLine );
      Write( XFile, HowMuch/100:10:2, VLine );
      ExtractLength := GetMaxNarrationLength;
      if ExtractLength > 40 then
        ExtractLength := 40;
      Writeln( XFile, Fill( Copy( ANarration, 1, ExtractLength), 40 ), VLine );
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   end;

const
   ThisMethodName    = 'CLS3Write';
   FiveMillion       : Money =  500000000;
   MinusHalfAMillion : Money =  -50000000;

Var
   Total : Money;

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Total := AAmount;
   While ( Total > FiveMillion ) do
   Begin
      CLS3WriteEntryFor( FiveMillion );
      Total := Total - FiveMillion;
   end;
   While ( Total < MinusHalfAMillion ) do
   Begin
      CLS3WriteEntryFor( MinusHalfAMillion );
      Total := Total - MinusHalfAMillion;
   end;
   CLS3WriteEntryFor ( Total );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoTransaction;

const
   ThisMethodName = 'DoTransaction';
Var
   S : String[80];
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
         CLS3Write(  txDate_Effective,                {  const ADate       : TStDate;     }
                     txType,                          {  const AType       : Byte;        }
                     GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                     {  const ARefce      : ShortString; }
                     txAccount,                       {  const AAccount    : ShortString; }
                     txAmount,                        {  const AAmount     : Money;      }
                     S );                             {  const ANarration  : ShortString  }
      end;
      Inc ( NoOfEntries );
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

   With Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      CLS3Write(  txDate_Effective,                {  const ADate       : TStDate;     }
                  txType,                          {  const AType       : Byte;        }
                  getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type), {  const ARefce      : ShortString; }
                  dsAccount,                       {  const AAccount    : ShortString; }
                  dsAmount,                        {  const AAmount     : Money;      }
                  S );                   {  const ANarration  : ShortString  }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
const
   ThisMethodName = 'ExtractData';
   VLine        : char = #179;
var
   SortThem     : Boolean;
   Msg, ac      : String;
   BankContra   : Money;
   BA           : TBank_Account;
   S            : String[150];
   D            : String[10];
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [CLS3x format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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
         
         if baContra_Account_Code = '' then
         Begin
            HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for this bank account. '+
               ' To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
            exit;
         end;
         
         SortThem := False;
         if not TravUtils.AllCoded( BA, FromDate, ToDate  ) then
         Begin
            SortThem := AskYesNo('Sort Entries','Do you want to sort the entries for coding in CLS?',DLG_NO,0) = DLG_YES;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );
      
         Try
            { Write the identification information so FETCH.EXE can validate
              the information CLS sends... }

            Writeln( XFile, clCode );
            Writeln( XFile, bkDate2Str( FromDate ) );
            Writeln( XFile, bkDate2Str( ToDate ) );
            Writeln( XFile, '' );

            { - - - - - - - - - - - - - - - -  }

            S := ConstStr( ' ',88 )+ VLine;
            D := Date2Str( CurrentDate, 'dd/mm/yy' );
            Move( D[1], S[1], Length( D ) );
            ac := StripM(BA);
            Move( ac[1],S[14],Length( ac ) );
            Move( baBank_Account_Name[1],S[35],Length( baBank_Account_Name ) );
            Writeln( XFile, S );

            { - - - - - - - - - - - - - - - -  }
         
            BankContra   := TravUtils.CalculateBankContra( BA, FromDate, ToDate );

            CLS3Write(  ToDate,                 {const ADate       : TStDate;     }
                        100,                    {const AType       : Byte;        }
                        '',                     {const ARefce      : ShortString; }
                        baContra_Account_Code,  {const AAccount    : ShortString; }
                        BankContra,             {const AAmount     : Money;       }
                        'Auto Contra'           {const ANarration  : ShortString  } 
                         );

            { - - - - - - - - - - - - - - - -  }
         
            NoOfEntries       := 0;

            TRAVERSE.Clear;
            if SortThem then
               TRAVERSE.SetSortMethod( csChequeNumber )
            else
               TRAVERSE.SetSortMethod( csDateEffective );
            
            TRAVERSE.SetSelectionMethod( twAllNewEntries );
            TRAVERSE.SetOnEHProc( DoTransaction );
            TRAVERSE.SetOnDSProc( DoDissection );
            TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
            OK := True;
         finally            
            System.Close( XFile );
         end;
      end; { Scope of BA.baFields }
      
      if OK then
      Begin
         Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
         LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
         HelpfulInfoMsg( Msg, 0 );
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

