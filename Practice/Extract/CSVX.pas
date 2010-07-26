unit CSVX;

{
   Author, SPA 25-05-99
   This is a new "recommended" CSV format for all systems.
}

{...$DEFINE NEW}       // Set this to use the new Account Selection dialog.

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string;
                       AllowUncoded : boolean = false;
                       AllowBlankContra : boolean = false );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, 
{$IFDEF NEW}
     BaSelFrm,
{$ELSE}
     dlgSelect, 
{$ENDIF}
     BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'CSVX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;
   NoOfLines          : LongInt;
   TotalAmount        : Money;
   DoBankAccount      : Boolean;
   DoChartDescription : Boolean;
   DoQuantity         : Boolean;
   UseGUIDId          : Boolean;



procedure CSVWriteRaw(Fields: Array of ShortString);
var
  I: Integer;
begin
  for I := 0 to Length(Fields) - 1 do
  begin
    if I <> Length(Fields) -1 then
      Write(XFile, Fields[I],',')
    else
      WriteLn(XFile, Fields[I]);
  end;
end;

function GetTransactionGUID: string;
begin
  CheckExternalGUID(Traverse.Transaction);
  Result := TrimGUID(Traverse.Transaction^.txExternal_GUID);
end;

procedure CSVWrite(  ABankAccount : ShortString;
                     AContra      : ShortString;
 						   ADate        : TStDate;
                     ARefce       : ShortString;
                     AAccount     : ShortString;
                     AAmount      : Money;
                     ANarration   : ShortString;
                     AQuantity	 : Money;
                     AGSTClass    : Byte;
                     AGSTAmount   : Money );

   function ChartDescription: Shortstring;
   var Cr: pAccount_Rec;
   begin
      Result := '';
      if AAccount > '' then begin
         Cr := MyClient.clChart.FindCode(AAccount);
         if Assigned(Cr) then
            Result := CR.chAccount_Description;
      end;
   end;

const
   ThisMethodName = 'CSVWrite';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   TotalAmount := Totalamount + AAmount;
   Inc(NoOfLines);
   if UseGUIDId then begin
     if (ABankAccount <> 'CHECKSUM') and (ABankAccount <> 'BALANCE') then
       Write( XFile, '"', GetTransactionGUID, '",')
     else
       Write (XFile, '"",');
   end else
     Write( XFile, NoOfEntries, ',' );


   if DoBankAccount then
      write( XFile, '"', ReplaceCommasAndQuotes(ABankAccount), '",');

   Write( XFile, '"', ReplaceCommasAndQuotes(AContra), '",' );
   Write( XFile, '"', Date2Str( ADate, 'dd/mm/yyyy' ),'",' );
   Write( XFile, '"', ReplaceCommasAndQuotes( StStrS.TrimSpacesS( ARefce )), '",' );
   Write( XFile, '"', ReplaceCommasAndQuotes(AAccount), '",' );

   if DoChartDescription then
      write( XFile, '"', ChartDescription, '",');

   write( XFile, AAmount/100:0:2, ',' );
   write( XFile, '"',Copy(ReplaceCommasAndQuotes( StStrS.TrimSpacesS( ANarration )), 1, GetMaxNarrationLength), '",' );

   if DoQuantity then
      write( XFile, GetQuantityStringForExtract(AQuantity), ',' )
   else
      write( XFile, GetQuantityStringForExtract(0), ',' );

   with MyClient.clFields do
   begin { Convert our internal representation into the code expected by
           the accounting software }
      if ( AGSTClass in [ 1..MAX_GST_CLASS ] ) then begin
         write( XFile, '"', clGST_Class_Codes[ AGSTClass] , '",' );
         writeln( XFile, AGSTAmount/100:0:2 );
      end else begin
         write( XFile,   '"",' ); { No GST Class }
         writeln( XFile, '0.00' ); { No GST Amount }
      end;
   end;

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
  S : ShortString;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With MyClient.clFields, Bank_Account.baFields, Transaction^ do
   Begin
      txDate_Transferred := CurrentDate;
      if SkipZeroAmountExport(Transaction) then
         Exit; // Im done...

      Inc( NoOfEntries );
      If ( txFirst_Dissection = NIL ) then
      Begin
         S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
         If ( txGST_Class=0 ) then txGST_Amount := 0;
         CSVWrite( 	baBank_Account_Number,  { ABankAccount : ShortString      }
                     baContra_Account_Code,  { AContra	   : ShortString      }
                     txDate_Effective, 	   { ADate        : TStDate;         }
                     GetReference(TransAction,Bank_Account.baFields.baAccount_Type),      		{ ARefce       : ShortString;     }
                     txAccount,        		{ AAccount     : ShortString;     }
                     txAmount,         		{ AAmount      : Money;           }
                     S,                      { ANarration	: ShortString;     }
                     txQuantity,             { AQuantity	   : Money;           }
                     txGST_Class,            { AGSTClass    : Byte;            }
                     txGST_Amount );         { AGSTAmount   : Money );         }
      end;
      //For SmartBooks transactions can be exported as many times as the user wanted
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure DoDissection ;

const
   ThisMethodName = 'DoDissection';
var
   s : ShortSTring;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      S := dsGL_Narration;
      If ( dsGST_Class=0 ) then dsGST_Amount := 0;
      CSVWrite( 	baBank_Account_Number,  { ABankAccount : ShortString      }
                  baContra_Account_Code,  { AContra	   : ShortString      }
      				txDate_Effective, 	   { ADate        : TStDate;         }
                  getDsctReference(Dissection,Transaction,Traverse.Bank_Account.baFields.baAccount_Type),{ ARefce       : ShortString;     }
                  dsAccount,        		{ AAccount     : ShortString;     }
                  dsAmount,         		{ AAmount      : Money;           }
                  S,                      { ANarration	: ShortString;     }
                  dsQuantity,             { AQuantity	 : Money;          }
                  dsGST_Class,            { AGSTClass    : Byte;           }
                  dsGST_Amount );         { AGSTAmount   : Money );        }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFNDEF NEW}

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string;
                       AllowUncoded : boolean = false;
                       AllowBlankContra : boolean = false );
const
   ThisMethodName = 'ExtractData';

VAR
   BA           : TBank_Account;
   Msg          : String;
	 No			    : Integer;
   Selected		 : TStringList;
   OK           : Boolean;
   DoClientDescription: Boolean;
   DoBalance: Boolean;


  function GetClosingBalance(BA: TBank_Account): Money;
  var
    OpenBl, CloseBl, OpenCBBl, CloseCBBl: Money;
  begin
    BA.CalculatePDBalances(FromDate, ToDate, OpenBL, CloseBL, OpenCBBl, CloseCBBl);
    Result := CloseBL; 
  end;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Msg := 'Extract data [BK5 CSV format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   if (MyClient.clFields.clAccounting_System_Used = snConceptCash2000)
   and (MyClient.clFields.clCountry = whNewZealand) then begin
      BA := dlgSelect.SelectBankAccountForExport( FromDate, ToDate );
      if BA = NIL then
         exit;
      Selected := TStringList.Create;
      Selected.AddObject(BA.baFields.baBank_Account_Number, BA);
   end else
      Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );

   If Selected = NIL then
      exit;

   try
      with MyClient.clFields do begin
         for No := 0 to Pred( Selected.Count ) do Begin
            BA := TBank_Account( Selected.Objects[ No ] );
            With BA.baFields do Begin
               if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  )= 0 then Begin
                  HelpfulInfoMsg( 'There are no new entries to extract, for ' + baBank_Account_Number +', in the selected date range.',0);
                  exit;
               end;

               if not AllowUncoded then
               begin
                 if not TravUtils.AllCoded(BA, FromDate, ToDate) then
                 Begin
                    HelpfulInfoMsg( 'Account "'+baBank_Account_Number+'" has uncoded entries. ' +
                       'You must code all the entries before you can extract them.',  0 );
                    Exit;
                 end;
               end;

               if not AllowBlankContra then
               begin
                 if BA.baFields.baContra_Account_Code = '' then
                 Begin
                   HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for bank account "'+
                      baBank_Account_Number + '". To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
                   exit;
                 end;
               end;

            end;
         end;

         Assign( XFile, SaveTo );
         SetTextBuf( XFile, Buffer );
         Rewrite( XFile );

         Try
            // Fill the header
            {Not used anymore... if (MyClient.clFields.clCountry = whAustralia)
              and (MyClient.clFields.clAccounting_System_Used = saClassSuperIP) then
            begin
               Writeln( XFile, '"Number","Account Number","Bank","Date","Reference","Account","Amount","Narration","Quantity","GST Class","GST Amount"');
               DoBankAccount := True;
               DoChartDescription := False;
               DoClientDescription := false;
               UseGUIDId := False;
               DoBalance := false;
            end
            else} if (MyClient.clFields.clCountry = whAustralia)
              and (MyClient.clFields.clAccounting_System_Used = saPraemium) then
            begin
               Writeln( XFile, '"Number","Bank","Date","Reference","Account","Amount","Narration","Quantity","GST Class","GST Amount"');
               DoBankAccount := False;
               DoChartDescription := False;
               DoClientDescription := False;
               UseGUIDId := False;
               DoBalance := false;
            end
            else if (MyClient.clFields.clCountry = whAustralia)
              and (MyClient.clFields.clAccounting_System_Used = saIRESSXplan) then
            begin
              Writeln( XFile, '"Transaction GUID","Account Number","Bank","Date","Reference","Account","Account Description","Amount","Narration","Quantity","GST Class","GST Amount"');
              DoBankAccount := True;
              DoChartDescription := True;
              DoClientDescription := True;
              UseGUIDId := true;
              DoBalance := true;
            end
            else
            begin
               Writeln( XFile, '"Number","Bank","Date","Reference","Account","Amount","Narration","Quantity","GST Class","GST Amount"');
               DoBankAccount := False;
               DoChartDescription := False;
               DoClientDescription := false;
               UseGUIDId := false;
               DoBalance := false;
            end;
            DoQuantity := Globals.PRACINI_ExtractQuantity;

            NoOfEntries := 0;
            NoOfLines := 0;
            TotalAmount := 0;

            //As per case 7587
            if DoClientDescription then
                        //"Transaction GUID","Account#","Bank","Date","Reference",
              CSVWriteRaw(['""'             ,'""'      ,'""'  ,'""'  ,'""',

                        //"Account"                      ,"Account Description",          "Amount","Narration","Quantity","GST Class","GST Amount"'
                         '"'+MyClient.clFields.clCode+'"','"'+MyClient.clFields.clName+'"',''     ,'""'       ,''        ,'""'       ,'']);

            for No := 0 to Pred( Selected.Count ) do Begin
               BA := TBank_Account(Selected.Objects[ No ]);
               TRAVERSE.Clear;
               TRAVERSE.SetSortMethod( csDateEffective );
               TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
               TRAVERSE.SetOnAHProc( DoAccountHeader );
               TRAVERSE.SetOnEHProc( DoTransaction );
               TRAVERSE.SetOnDSProc( DoDissection );
               TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );

               if DoBalance then
               begin
                 CSVWrite('BALANCE',
                  '',
                  TRAVERSE.Transaction.txDate_Effective,
                  '',
                  '',
                  GetClosingBalance(BA),
                  '',
                  0,
                  0,
                  0);
               end;

            end;

            if DoBankAccount then
            begin // More by acident
               DoQuantity := True;
               NoOfLines := NoOfLines * 10000; //4 decimal places
               CSVWrite( 'CHECKSUM',
                         '',              { AContra	   : ShortString      }
                         CurrentDate, 	   { ADate        : TStDate;         }
                         '',      		   { ARefce       : ShortString;     }
                         '',        		{ AAccount     : ShortString;     }
                         TotalAmount,     { AAmount      : Money;           }
                         '',              { ANarration	: ShortString;     }
                         NoOfLines  ,     { AQuantity	   : Money;           }
                         0,               { AGSTClass    : Byte;            }
                         0);              { AGSTAmount   : Money );         }
            end;
            OK := True;
         finally
            System.Close(XFile);
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

{$ENDIF}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*
{$IFDEF NEW}
procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';
  
VAR
   BA           : TBank_Account;
   Msg          : String; 
	No			    : Integer;   
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   OK := False;

   Msg := 'Extract data [BK5 CSV format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   if not BaSelFrm.SelectBankAccountsForExport( FromDate, ToDate, MultipleAccounts ) then exit;
   
   with MyClient.clBank_Account_List do
   begin
      for No := 0 to Pred( ItemCount ) do
      Begin
         BA := Bank_Account_At( No );
         With BA.baFields do If baIs_Selected then
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
               HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for bank account "'+
                  baBank_Account_Number + '". To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
               exit;
            end;
         end;
      end;

      Assign( XFile, SaveTo );
      SetTextBuf( XFile, Buffer );
      Rewrite( XFile );

      Try
      	Writeln( XFile, '"Number","Bank","Date","Reference","Account","Amount","Narration","Quantity","GST Class","GST Amount"' );
         NoOfEntries := 0;

         for No := 0 to Pred( ItemCount ) do
         Begin
            BA := Bank_Account_At( No );
            With BA.baFields do
            Begin
               If baIs_Selected then
               Begin
                  TRAVERSE.Clear;
                  TRAVERSE.SetSortMethod( csDateEffective );
                  TRAVERSE.SetSelectionMethod( TRAVERSE.twAllNewEntries );
                  TRAVERSE.SetOnAHProc( DoAccountHeader );
                  TRAVERSE.SetOnEHProc( DoTransaction );
                  TRAVERSE.SetOnDSProc( DoDissection );
                  TRAVERSE.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
               end;
            end;
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

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
{$ENDIF}
*)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

