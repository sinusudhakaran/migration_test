unit CLSY2KX;
{
   Author, SPA 22-10-99

   This is the extract data program for Solution 6 MAS 4.1 updated for dd/mm/yyyy dates.

!!!!   Mar 2000  Advised by Solution 6 than no clients are using banklink and cls anymore !!!!

!!!!   This unit is not compatible with the new gst classes because it only exports
        classes 1..9
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
   UnitName = 'CLSY2KX';
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

procedure CLSY2KWrite( const ADate       : TStDate;
                       const AType       : Byte;
                       const ARefce      : ShortString;
                       const AAccount    : ShortString;
                       const AAmount     :  Money;
                       const AGST_Class  : Byte;
                       const AGST_Amount : Money;
                       const AQuantity   : Money;
                       const ANarration  : ShortString );
const
   ThisMethodName = 'CLSY2KWrite';
   VLine : char = #179;
var
  ExtractLength: Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
   write( XFile, Date2Str( ADate, 'dd/mm/yyyy' ), VLine );
   write( XFile, AType:3, VLine );
   write( XFile, GenUtils.FillRefce( ARefce ), VLine );
   write( XFile, Fill( AAccount ,10 ), VLine );
   write( XFile, AAmount/100:12:2, VLine );

   if AGST_Class in [ 1..9 ] then
   Begin
      write( XFile, AGST_Class:1, VLine );
      write( XFile, AGST_Amount/100:12:2, VLine );
   end
   else
   begin { No GST }
      write( XFile, ' ', VLine );
      write( XFile, 0.0:12:2, VLine );
   end;
            
   if (Globals.PRACINI_ExtractQuantity) then
     write( XFile, GetQuantityStringForExtract(AQuantity):12, VLine )
   else
     write( XFile, GetQuantityStringForExtract(0):12, VLine );
   ExtractLength := GetMaxNarrationLength;
   if ExtractLength > 40 then
     ExtractLength := 40;
   writeln( XFile, Fill( Copy( ANarration, 1, ExtractLength), 40 ), VLine );
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
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      If ( txFirst_Dissection = NIL ) then
      Begin
         S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         CLSY2KWrite( txDate_Effective,                {  const ADate       : TStDate;     }
                     txType,                          {  const AType       : Byte;        }
                     GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                     {  const ARefce      : ShortString; }
                     txAccount,                       {  const AAccount    : ShortString; }
                     txAmount,                        {  const AAmount     :  Money;      }
                     txGST_Class,                     {  const AGST_Class  : Byte;        }
                     txGST_Amount,                    {  const AGST_Amount : Money;       }
                     txQuantity,                      {  const AQuantity   : Money;       }
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
   S : shortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      CLSY2KWrite( txDate_Effective,                {  const ADate       : TStDate;     }
                  txType,                          {  const AType       : Byte;        }
                  getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{  const ARefce      : ShortString; }
                  dsAccount,                       {  const AAccount    : ShortString; }
                  dsAmount,                        {  const AAmount     :  Money;      }
                  dsGST_Class,                     {  const AGST_Class  : Byte;        }
                  dsGST_Amount,                    {  const AGST_Amount : Money;       }
                  dsQuantity,                      {  const AQuantity   : Money;       }
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
   Msg,ac       : String; 
   BankContra   : Money;
   BA           : TBank_Account;
   S            : String[150];
   D            : String[10];
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [CLSY2K format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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
            Writeln( XFile, 'Y2K' );

            { - - - - - - - - - - - - - - - -  }

            S := ConstStr( ' ',120 )+ VLine;
            D := Date2Str( CurrentDate, 'dd/mm/yyyy' );
            Move( D[1], S[1], Length( D ) );
            ac := StripM(BA);
            Move( ac[1],S[14],Length( ac ) );
            Move( baBank_Account_Name[1],S[35],Length( baBank_Account_Name ) );
            Writeln( XFile, S );

            { - - - - - - - - - - - - - - - -  }
         
            BankContra   := TravUtils.CalculateBankContra( BA, FromDate, ToDate );

            CLSY2KWrite( ToDate,                 {const ADate       : TStDate;     }
                        100,                    {const AType       : Byte;        }
                        '',                     {const ARefce      : ShortString; }
                        baContra_Account_Code,  {const AAccount    : ShortString; }
                        BankContra,             {const AAmount     : Money;       }
                        MyClient.clChart.GSTClass( baContra_Account_Code ), {const AGST_Class  : Byte;        }
                        0,                      {const AGST_Amount : Money;       }
                        0,                      {const AQuantity   : Money;       }
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

