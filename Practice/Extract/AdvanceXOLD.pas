unit AdvanceXOLD;

{
   Author, SPA 24-05-99
   This is the extract data program for the old (pre-GST) version of APS Advance.

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
   UnitName = 'ADVANCEXOLD';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile         : Text;
   Buffer        : array[ 1..2048 ] of Byte;
  
   NoOfEntries   : LongInt;
   Contra        : Money;
   CrValue       : Money;
   DrValue       : Money;
   LineCount     : Integer;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure APSWrite( const ADate       : TStDate;
                    const AType       : Byte;
                    const ARefce      : ShortString;
                    const AAccount    : ShortString;
                    const AAmount     :  Money;
                    const ANarration  : ShortString );
const
   ThisMethodName = 'APSWrite';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   write( XFile, 'B,' );
   write( XFile, '"', Date2Str( ADate, 'dd/mm/yy' ), '",' );
   write( XFile, AType, ',' );
   write( XFile, '"', ReplaceCommasAndQuotes(ARefce), '",' );
   write( XFile, '"', ReplaceCommasAndQuotes(AAccount), '",' );
   write( XFile, AAmount/100:0:2, ',' );
   writeln( XFile, '"', Copy(ReplaceCommasAndQuotes(ANarration), 1, GetMaxNarrationLength), '"' );

   Inc( LineCount );
      
   Contra := Contra + AAmount;
   if AAmount < 0 then
      CrValue :=CrValue + AAmount
   else
      DrValue := DrValue + AAmount;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountHeader;

const
   ThisMethodName = 'DoAccountHeader';
Begin
//   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
//   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
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
         APSWrite(   txDate_Effective,                {  const ADate       : TStDate;     }
                     txType,                          {  const AType       : Byte;        }
                     GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                     {  const ARefce      : ShortString; }
                     txAccount,                       {  const AAccount    : ShortString; }
                     txAmount,                        {  const AAmount     :  Money;      }
                     S );                             {  const ANarration  : ShortString  }
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
   S : String[ 80];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with Transaction^, Dissection^ do
   Begin
      S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
      APSWrite(   txDate_Effective,                {  const ADate       : TStDate;     }
                  txType,                          {  const AType       : Byte;        }
                  GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                     {  const ARefce      : ShortString; }
                  dsAccount,                       {  const AAccount    : ShortString; }
                  dsAmount,                        {  const AAmount     :  Money;      }
                  S );                             {  const ANarration  : ShortString  }
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
   Begin { ExportPeriod }
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   
      With MyClient, BA.baFields do
      Begin
         Contra := 0;
         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( twAllNewEntries );
         TRAVERSE.SetOnAHProc( DoAccountHeader );
         TRAVERSE.SetOnEHProc( DoTransaction );
         TRAVERSE.SetOnDSProc( DoDissection );
         TRAVERSE.TraverseEntriesForAnAccount( BA, D1, D2 );

         if Contra<>0 then
         Begin
            APSWrite( D2,                      {  const ADate       : TStDate;     }
                   100,                     {  const AType       : Byte;        }
                   '',                      {  const ARefce      : ShortString; }
                   baContra_Account_Code,   {  const AAccount    : ShortString; }
                   -Contra,                 {  const AAmount     :  Money;      }
                   'Bank Account Contra' ); {  const ANarration  : ShortString  }
         end;
      end;
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const
   ThisMethodName = 'ExtractData';
   
var
   Msg          : String; 
   ti           : Integer;
   No           : Integer;
   Selected     : TStringList;
   D1, D2       : TStDate;
   M1, Y1       : Integer;
   M,Y          : Integer;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [APS Advance old format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
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
               With BA.baFields do
               Begin
         
                  { Write the File Header }
         
                  Write( XFile,'A,' );
                  Write( XFile,'"',StripM(BA),'",' );
                  Write( XFile,'"',baBank_Account_Name,'",' );
                  Write( XFile,'"',clCode,'"' );
                  Writeln( XFile );

                  DrValue     := 0;
                  CrValue     := 0;
                  LineCount   := 0;
         
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

                  { Write the Account Trailer }
         
                  Write( XFile, 'C,' );
                  Write( XFile, LineCount, ',' );
                  Write( XFile, DrValue/100:0:2, ',' );
                  Write( XFile, CrValue/100:0:2, ',' );
                  Write( XFile, ( DrValue + CrValue )/100:0:2 );
                  Writeln( XFile );
               end;
            end;
            
            { Write the End of File Marker }
         
            Writeln( XFile,'X, End of File' );
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

