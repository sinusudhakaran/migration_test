unit AdvanceX;
{
   Author, SPA 24-05-99
   This is the extract data program for the latest version of APS Advance.


   MH - Rewritten Sept 2004 to use a stream object so can stream to file or
        COM call
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils, Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils,
     LogUtil, BaObj32, dlgSelect, BkConst, MoneyDef, SysUtils, Software,
     InfoMoreFrm, BKDefs, glConst, ErrorMoreFrm, ComObj, Variants, Bk5Except,
     Dialogs, Files, baUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'ADVANCEX';
   DebugMe  : Boolean = False;
   AmountFormat = '0.00';
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   DataStream    : TStringStream;
   NoOfEntries   : LongInt;
   Contra        : Money;
   CrValue       : Money;
   DrValue       : Money;
   LineCount     : Longint;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure APSWrite( const ADate       : TStDate;
                    const AType       : Byte;
                    const ARefce      : ShortString;
                    const AAccount    : ShortString;
                    const AAmount     :  Money;
                    const AGST_Class  : Byte;
                    const AGST_Amount : Money;
                    const AQuantity   : Money;
                    const ANarration  : ShortString;
                    const AccountType : byte );
const
   ThisMethodName = 'APSWrite';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   //need to write bytes from buffer into stream
   if ( AccountType <> btBank) and ( Globals.PRACINI_ExtractJournalsAsPAJournals) then
     DataStream.WriteString( 'J,' )
   else
     DataStream.WriteString( 'B,' );

   DataStream.WriteString( '"' +  Date2Str( ADate, 'dd/mm/yy' ) +  '",' );
   DataStream.WriteString( IntToStr(AType) + ',' );
   DataStream.WriteString( '"' + ReplaceCommasAndQuotes(ARefce) + '",' );
   DataStream.WriteString( '"' + ReplaceCommasAndQuotes(AAccount) + '",' );
   DataStream.WriteString( Money2Str(AAmount, AmountFormat) + ',' );
   DataStream.WriteString( '"' + Copy(ReplaceCommasAndQuotes(ANarration), 1, GetMaxNarrationLength) + '",' );

   with MyClient.clFields do begin
      if AGST_Class in [ 1..MAX_GST_CLASS ] then
      begin
         DataStream.WriteString( '"' +  clGST_Class_Codes[ AGST_Class] + '",' );
         DataStream.WriteString( Money2Str( AGST_Amount, AmountFormat) + ',' );
      end
      else
      Begin
         //unknown gst - should be sent a blank for AU and NZ
         DataStream.WriteString( '"",0.00,' );
      end;
   end;
   if (Globals.PRACINI_ExtractQuantity) then
     DataStream.WriteString(GetQuantityStringForExtract(AQuantity))
   else
     DataStream.WriteString(GetQuantityStringForExtract(0));

   DataStream.WriteString( #13#10);
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
  S : String[200];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      If ( txFirst_Dissection = NIL ) then
      Begin
         S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         APSWrite(   txDate_Effective,                {  const ADate       : TStDate;     }
                     txType,                          {  const AType       : Byte;        }
                     GetReference(TransAction,Bank_Account.baFields.baAccount_Type),                     {  const ARefce      : ShortString; }
                     txAccount,                       {  const AAccount    : ShortString; }
                     txAmount,                        {  const AAmount     :  Money;      }
                     txGST_Class,                     {  const AGST_Class  : Byte;        }
                     txGST_Amount,                    {  const AGST_Amount : Money;       }
                     txQuantity,                      {  const AQuantity   : Money;       }
                     S,                               {  const ANarration  : ShortString  }
                     Bank_Account.baFields.baAccount_Type);
      end;
      Inc( NoOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FlagTransactionAsTransferred;
begin
  Transaction.txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(Transaction.txDate_Effective);

  Transaction^.txDate_Transferred := CurrentDate;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
  ThisMethodName = 'DoDissection';
var
  S : string[ 200];
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      APSWrite(   txDate_Effective,                {  const ADate       : TStDate;     }
                  txType,                          {  const AType       : Byte;        }
                  getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{  const ARefce      : ShortString; }
                  dsAccount,                       {  const AAccount    : ShortString; }
                  dsAmount,                        {  const AAmount     :  Money;      }
                  dsGST_Class,                     {  const AGST_Class  : Byte;        }
                  dsGST_Amount,                    {  const AGST_Amount : Money;       }
                  dsQuantity,                      {  const AQuantity   : Money;       }
                  S,                               {  const ANarration  : ShortString  }
                  Bank_Account.baFields.baAccount_Type);
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FlagEntriesAsTransferred( Ba : TBank_Account; FromDate, ToDate : TStDate);
begin
  TRAVERSE.Clear;
  TRAVERSE.SetSortMethod( csDateEffective );
  TRAVERSE.SetSelectionMethod( twAllNewEntries );
  TRAVERSE.SetOnEHProc( FlagTransactionAsTransferred );
  TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//5.2 extract data routine, single account
procedure ExtractData52( const FromDate, ToDate : TStDate; const SaveTo : string );
VAR
   BA : TBank_Account;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   Procedure ExportPeriod( D1, D2 : TStDate );
   const
      ThisMethodName = 'ExportPeriod';
   Var
      GSTClass : Byte;
   Begin { ExportPeriod }
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

      With MyClient, BA.baFields do
      Begin
         Contra := 0;
         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( twAllNewEntries );
         TRAVERSE.SetIncludeZeroAmounts(PRACINI_ExtractZeroAmounts);
         TRAVERSE.SetOnAHProc( DoAccountHeader );
         TRAVERSE.SetOnEHProc( DoTransaction );
         TRAVERSE.SetOnDSProc( DoDissection );
         TRAVERSE.TraverseEntriesForAnAccount( BA, D1, D2 );

         GSTClass := clChart.GSTClass( baContra_Account_Code );

         if Contra<>0 then
         Begin
            APSWrite( D2,                      {  const ADate       : TStDate;     }
                   100,                     {  const AType       : Byte;        }
                   '',                      {  const ARefce      : ShortString; }
                   baContra_Account_Code,   {  const AAccount    : ShortString; }
                   -Contra,                 {  const AAmount     :  Money;      }
                   GSTClass,                {  const AGST_Class  : Byte;        }
                   0,                       {  const AGST_Amount : Money;       }
                   0,                       {  const AQuantity   : Money;       }
                   'Bank Account Contra',
                   BA.baFields.baAccount_Type ); {  const ANarration  : ShortString  }
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
   D1, D2       : TStDate;
   M1, Y1       : Integer;
   M,Y          : Integer;
   TransferOK           : Boolean;

   fs : TFileStream;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [APS Advance format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   with MyClient.clFields do
   begin
      BA := dlgSelect.SelectBankAccountForExport( FromDate, ToDate );
      if ( BA = nil) then
        Exit;

      with BA.baFields do
      Begin
        NoOfEntries := 0;
        DrValue     := 0;
        CrValue     := 0;
        LineCount   := 0;


        { Write the File Header }

        DataStream.WriteString('A,' );
        DataStream.WriteString('"' + StripM(BA) + '",' );
        DataStream.WriteString('"' + baBank_Account_Name + '",' );
        DataStream.WriteString('"' + clCode + '",' );
        DataStream.WriteString('"' + baContra_Account_Code + '",' );
        DataStream.WriteString('"' + Date2Str( FromDate, 'dd/mm/yy' ) + '",' );
        DataStream.WriteString('"' + Date2Str( ToDate, 'dd/mm/yy' ) +'"' );
        DataStream.WriteString( #13#10);

        //Export the transaction one month at a time
        //a contra entry is written at the end of each month
        StDateToDMY( FromDate, ti, M1, Y1 ); { 01-04-97 }
        M := M1; Y := Y1;
        Repeat
           D1 := DMYToStDate( 1, M, Y, Epoch );
           If ( D1 < FromDate) then
             D1 := FromDate;
           D2 := DMYToStDate( DaysInMonth( M, Y, Epoch ), M, Y, Epoch );
           If ( D2 > ToDate) then
             D2 := ToDate;

           ExportPeriod( D1, D2 );

           Inc( M );
           If ( M > 12) then
           begin
             M:= 1; Inc( Y );
           end;
        Until ( D2 = ToDate );


        { Write the Account Trailer }

        DataStream.WriteString( 'C,' );
        DataStream.WriteString( IntToStr( LineCount) +  ',' );
        DataStream.WriteString( Money2Str(DrValue, AmountFormat) +  ',');
        DataStream.WriteString( Money2Str(CrValue, AmountFormat) + ',' );
        DataStream.WriteString( Money2Str( DrValue + CrValue , AmountFormat));
        DataStream.WriteString( #13#10);

        { Write the End of File Marker }

        DataStream.WriteString( 'X,End of File'#13#10);
        DataStream.Position := 0;
        try
          fs := TFileStream.Create( SaveTo, fmCreate);
          try
            fs.CopyFrom( DataStream, DataStream.Size);
            TransferOK := True;
          finally
            fs.Free;
          end;
        except
          On E : Exception do
          begin
            raise EInterfaceError.Create( 'Extract failed : ' + E.Message);
          end;
        end;

        //file created ok, now mark the entries as transferred
        if TransferOK then
        Begin
           Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );
           LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );

           //set date transferred
           FlagEntriesAsTransferred( Ba, FromDate, ToDate);

           HelpfulInfoMsg( Msg, 0 );
        end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ExtractData53( const FromDate, ToDate : TStDate; const SaveTo : string );
//supports extract of multiple accounts
VAR
   BA : TBank_Account;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   Procedure ExportPeriod( D1, D2 : TStDate );
   const
      ThisMethodName = 'ExportPeriod';
   Var
      GSTClass : Byte;
   Begin { ExportPeriod }
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

      With MyClient, BA.baFields do
      Begin
         Contra := 0;
         TRAVERSE.Clear;
         TRAVERSE.SetSortMethod( csDateEffective );
         TRAVERSE.SetSelectionMethod( twAllNewEntries );
         TRAVERSE.SetIncludeZeroAmounts(PRACINI_ExtractZeroAmounts);
         TRAVERSE.SetOnAHProc( DoAccountHeader );
         TRAVERSE.SetOnEHProc( DoTransaction );
         TRAVERSE.SetOnDSProc( DoDissection );
         TRAVERSE.TraverseEntriesForAnAccount( BA, D1, D2 );

         GSTClass := clChart.GSTClass( baContra_Account_Code );

         if Contra<>0 then
         Begin
            APSWrite( D2,                      {  const ADate       : TStDate;     }
                   100,                     {  const AType       : Byte;        }
                   '',                      {  const ARefce      : ShortString; }
                   baContra_Account_Code,   {  const AAccount    : ShortString; }
                   -Contra,                 {  const AAmount     :  Money;      }
                   GSTClass,                {  const AGST_Class  : Byte;        }
                   0,                       {  const AGST_Amount : Money;       }
                   0,                       {  const AQuantity   : Money;       }
                   'Bank Account Contra',
                   BA.baFields.baAccount_Type ); {  const ANarration  : ShortString  }
         end;
      end;
      if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const
   ThisMethodName = 'ExtractData';

var
   TransferMsg : String;
   aMsg : string;
   Selected		: TStringList;
   No           : Integer;
   ti           : Integer;
   D1, D2       : TStDate;
   M1, Y1       : Integer;
   M,Y          : Integer;
   TransferOK           : Boolean;
   fs           : TFileStream;
   va           : Variant;
   vaResult     : Variant;
   P : Pointer;
   PALgr : OleVariant;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   aMsg := 'Extract data [Professional Accounting XPA format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + aMsg );

   TransferOK := False;
   with MyClient.clFields do
   begin
      Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate);
      if Selected = nil then Exit;

      NoOfEntries := 0;
      for No := 0 to Selected.Count-1 do
      begin
        BA := TBank_Account( Selected.Objects[ No ] );

        DrValue     := 0;
        CrValue     := 0;
        LineCount   := 0;
        with BA.baFields do
        begin
          { Write the File Header }

          DataStream.WriteString('A,' );
          DataStream.WriteString('"' + StripM(BA) + '",' );
          DataStream.WriteString('"' + baBank_Account_Name + '",' );
          DataStream.WriteString('"' + clCode + '",' );
          DataStream.WriteString('"' + baContra_Account_Code + '",' );
          DataStream.WriteString('"' + Date2Str( FromDate, 'dd/mm/yy' ) + '",' );
          DataStream.WriteString('"' + Date2Str( ToDate, 'dd/mm/yy' ) +'"' );
          DataStream.WriteString( #13#10);

          //Export the transaction one month at a time
          //a contra entry is written at the end of each month
          StDateToDMY( FromDate, ti, M1, Y1 ); { 01-04-97 }
          M := M1; Y := Y1;
          Repeat
             D1 := DMYToStDate( 1, M, Y, Epoch );

             D2 := DMYToStDate( DaysInMonth( M, Y, Epoch ), M, Y, Epoch );

             If ( D1 < FromDate) then
               D1 := FromDate;

             If ( D2 > ToDate) then
               D2 := ToDate;

             ExportPeriod( D1, D2 );

             Inc( M );
             If ( M>12) then
             begin
               M:= 1;
               Inc( Y );
             end;
          Until ( D2 = ToDate );

          { Write the Account Trailer }

          DataStream.WriteString( 'C,' );
          DataStream.WriteString( IntToStr( LineCount) +  ',' );
          DataStream.WriteString( Money2Str(DrValue, AmountFormat) +  ',');
          DataStream.WriteString( Money2Str(CrValue, AmountFormat) + ',');
          DataStream.WriteString( Money2Str( DrValue + CrValue, AmountFormat ));
          DataStream.WriteString( #13#10);
        end;
      end;

      { Write the End of File Marker }
      DataStream.WriteString( 'X,End of File'#13#10);

      //see if we should use the com interface or file extract
      if Software.IsXPA8Interface( clCountry, clAccounting_System_Used) then
      begin
        //test to see if PA chart dll exists
        try
          PALgr := CreateOLEObject('aPAChartMapping.advToolbox');
        except
          //invalid class string
          PALgr := UnAssigned;
        end;

        if (VarIsEmpty(PALgr)) then
        begin
          raise EInterfaceError.Create( 'The XPA interface could not be loaded.');
        end
        else
        begin
          try
            try
              //load the stream into a variant array
              va := VarArrayCreate([ 0, DataStream.Size - 1], varByte);
              p := VarArrayLock( va);
              try
                DataStream.Position := 0;
                DataStream.Read( p^, DataStream.Size);
              finally
                VarArrayUnlock( va);
              end;

              //send the array to the com object
              vaResult := PALgr.ImportArray( clSave_Client_Files_To, va);
              TransferOK := VarAsType( vaResult, varBoolean);
            except
              On E : Exception do
              begin
                raise EInterfaceError.Create( 'Extract failed: ' + E.Message);
              end;
            end;
          finally
            PALgr := UnAssigned;
          end;
        end;
      end
      else
      begin
        //Standard XPA 7 or earlier file interface
        try
          fs := TFileStream.Create( SaveTo, fmCreate);
          try
            DataStream.Position := 0;
            fs.CopyFrom( DataStream, DataStream.Size);
          finally
            fs.Free;
          end;
          TransferOK := True;
        except
          On E : Exception do
          begin
            raise EInterfaceError.Create( 'Extract failed: ' + E.Message);
          end;
        end;
      end;

      if TransferOK then
      Begin
         if Software.IsXPA8Interface( clCountry, clAccounting_System_Used) then
           TransferMsg := 'Data imported into XPA successfully.  ' + IntToStr( NoOfEntries) +  ' entries were transferred.'
         else
           TransferMsg := Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, SaveTo ] );

         LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + TransferMsg );

         //now flag entries as have being transferred
         for No := 0 to Selected.Count-1 do
         begin
           BA := TBank_Account( Selected.Objects[ No ] );
           FlagEntriesAsTransferred( Ba, FromDate, ToDate);
         end;

         HelpfulInfoMsg( TransferMsg, 0 );
      end
      else
      begin
        if Software.IsXPA8Interface( clCountry, clAccounting_System_Used) then
          TransferMsg := 'Data has not been imported into XPA.'
        else
          TransferMsg := 'Extract Data Failed.';

        HelpfulErrorMsg( TransferMsg, 0);
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );
var
  UseMultiAccountExport : boolean;
begin
  DataStream := TStringStream.Create('');
  try
    UseMultiAccountExport := PRACINI_ExtractMultipleAccountsToPA or
                             Software.IsXPA8Interface( MyClient.clFields.clCountry,
                                                       MyClient.clFields.clAccounting_System_Used);

    if Software.IsXPA8Interface( MyClient.clFields.clCountry,
                                 MyClient.clFields.clAccounting_System_Used) then
    begin
      //auto save the client file before doing the export, this is done because
      //we have to rely on code from a third party
      MyClient.clFields.clCurrent_CRC := MyClient.GetCurrentCRC;
      if (MyClient.clFields.clCurrent_CRC <> MyClient.clFields.clLast_Auto_Save_CRC) then
        MyClient.AutoSave;
    end;

    if UseMultiAccountExport then
      ExtractData53( FromDate, ToDate, SaveTo)
    else
      ExtractData52( FromDate, ToDate, SaveTo);
  finally
    DataStream.Free;
  end;
end;

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

