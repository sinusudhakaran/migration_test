unit MGLX;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses StDate;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses TransactionUtils,Classes, Traverse, Globals, GenUtils, bkDateUtils, TravUtils, YesNoDlg,
     LogUtil, BaObj32, dlgSelect, 
     BkConst, MoneyDef, SysUtils, StStrS,
     InfoMoreFrm, BKDefs, glConst;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     
Const
   UnitName = 'MGLX';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   XFile              : Text;
   Buffer             : array[ 1..2048 ] of Byte;
   NoOfEntries        : LongInt;
   Contra             : Money;
   GSTDebits          : Array[ 1..MAX_GST_CLASS ] of Money;
   GSTCredits         : Array[ 1..MAX_GST_CLASS ] of Money;
   GSTUsed            : Array[ 1..MAX_GST_CLASS ] of Boolean;
   D1, D2             : TStDate;

   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure MGLWrite(  AContra      : ShortString;
 				     ADate        : TStDate;
                     ARefce       : ShortString;
                     AAccount     : ShortString;
                     AAmount      : Money;
                     ANarration   : ShortString;
                     AQuantity	 : Money;
                     AGSTClass    : Integer;
                     AGSTAmount   : Money );
const
   ThisMethodName = 'MGLWrite';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Write( XFile, NoOfEntries, ',' );
   write( XFile, '"', ReplaceCommasAndQuotes(AContra), '",' );
   Write( XFile, '"',Date2Str( ADate, 'dd/mm/yyyy' ),'",' );
   Write( XFile, '"',StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ARefce)), '",' );
	write( XFile, '"', ReplaceCommasAndQuotes(AAccount), '",' );
   write( XFile, AAmount/100:0:2, ',' );
   write( XFile, '"', Copy(StStrS.TrimSpacesS(ReplaceCommasAndQuotes(ANarration)), 1, GetMaxNarrationLength), '",' );
   if (Globals.PRACINI_ExtractQuantity) then
     write( XFile, GetQuantityStringForExtract(AQuantity), ',' )
   else
     write( XFile, GetQuantityStringForExtract(0), ',' );

   with MyClient.clFields do
   begin { Convert our internal representation into the code expected by
           the accounting software }
      if ( AGSTClass in [ 1..MAX_GST_CLASS ] ) then
      Begin
         write( XFile, '"', clGST_Class_Codes[ AGSTClass ] , '",' );
         writeln( XFile, AGSTAmount/100:0:2 );
         GSTUsed[ AGSTClass ] := True;
         If AGSTAmount > 0 then
            GSTDebits[ AGSTClass ] := GSTDebits[ AGSTClass ] + AGSTAmount
         else
            GSTCredits[ AGSTClass ] := GSTCredits[ AGSTClass ] + AGSTAmount;
      end
      else
      begin
         write( XFile,   '"', AGSTClass, '",' );
         writeln( XFile, '0.00' ); { No GST Amount }
      end
   end;

   Contra := Contra + AAmount;
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountHeader;

const
   ThisMethodName = 'DoAccountHeader';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Contra  := 0;
   FillChar( GSTDebits  , Sizeof( GSTDebits   ) , 0 );
   FillChar( GSTCredits , Sizeof( GSTCredits  ) , 0 );
   FillChar( GSTUsed    , Sizeof( GSTUsed     ) , 0 );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
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
         MGLWrite( 	baContra_Account_Code,  { AContra	   : ShortString      }
         			 txDate_Effective, 	    { ADate        : TStDate;         }
                     GetReference(TransAction,Bank_Account.baFields.baAccount_Type),      		{ ARefce       : ShortString;     }
                     txAccount,        		{ AAccount     : ShortString;     }
                     txAmount,         		{ AAmount      : Money;           }
                     S,                     { ANarration	: ShortString;     }
                     txQuantity,            { AQuantity	   : Money;           }
                     txGST_Class,           { AGSTClass    : Byte;            }
                     txGST_Amount );        { AGSTAmount   : Money );         }
      end;
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
   With MyClient.clFields, Bank_Account.baFields, Transaction^, Dissection^ do
   Begin
      If ( dsGST_Class=0 ) then dsGST_Amount := 0;
      S := dsGL_Narration;
      MGLWrite( 	baContra_Account_Code,  { AContra	      : ShortString     }
      				txDate_Effective, 	        { ADate         : TStDate;        }
                  getDsctReference(Dissection,Transaction,baAccount_Type ),
                                          { ARefce        : ShortString;    }
                  dsAccount,        		  { AAccount      : ShortString;    }
                  dsAmount,         		  { AAmount       : Money;          }
                  S,                      { ANarration  	: ShortString;    }
                  dsQuantity,             {  AQuantity	  : Money;          }
                  dsGST_Class,            {  AGSTClass    : Byte;           }
                  dsGST_Amount );         {  AGSTAmount   : Money );        }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoAccountTrailer;
const
   ThisMethodName = 'DoAccountTrailer';
Var
   GSTClass : Byte;
   S : ShortString;
   GSTClassCode  : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With Bank_Account.baFields do
   Begin
      Inc( NoOfEntries );
      MGLWrite( 	baContra_Account_Code,  { AContra	   : ShortString      }
      				D2,  	                  { ADate        : TStDate;         }
                  '',       		         { ARefce       : ShortString;     }
                  baContra_Account_Code,  { AAccount     : ShortString;     }
                  -Contra,         		   { AAmount      : Money;           }
                  'Bank Account Contra',  { ANarration	: ShortString;     }
                  0,                      {  AQuantity	 : Money;          }
                  -1,                     {  AGSTClass    : Byte;           }
                  0 );                    {  AGSTAmount   : Money );        }

      with MyClient.clFields do
      begin
         For GSTClass := 1 to MAX_GST_CLASS do
            If GSTUsed[ GSTClass ] then
         Begin
            Inc( NoOfEntries );
            GSTClassCode := clGST_Class_Codes[ GSTClass ];
            S := 'GST Class '+ GSTClassCode +' Debit Total';
            MGLWrite( 	baContra_Account_Code,             { AContra	   : ShortString      }
                        D2,  	                             { ADate        : TStDate;         }
                        '',       		                    { ARefce       : ShortString;     }
                        clGST_Account_Codes[ GSTClass ],   { AAccount     : ShortString;     }
                        GSTDebits[ GSTClass ],             { AAmount      : Money;           }
                        S,                                 { ANarration	: ShortString;     }
                        0,                                 {  AQuantity	 : Money;          }
                        -2,                                {  AGSTClass    : Byte;           }
                        0 );                               {  AGSTAmount   : Money );        }

            Inc( NoOfEntries );
            S := 'GST Class '+ GSTClassCode +' Credit Total';
            MGLWrite( 	baContra_Account_Code,             { AContra	   : ShortString      }
                        D2,  	                             { ADate        : TStDate;         }
                        '',       		                    { ARefce       : ShortString;     }
                        clGST_Account_Codes[ GSTClass ],   { AAccount     : ShortString;     }
                        GSTCredits[ GSTClass ],            { AAmount      : Money;           }
                        S,                                 { ANarration	: ShortString;     }
                        0,                                 {  AQuantity	 : Money;          }
                        -2,                                {  AGSTClass    : Byte;           }
                        0 );                               {  AGSTAmount   : Money );        }
         end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData( const FromDate, ToDate : TStDate; const SaveTo : string );

const
   ThisMethodName = 'ExtractData';

VAR
   BA           : TBank_Account;
   Msg          : String;
	No			    : Integer;
   Selected		 : TStringList;
   OK           : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   D1 := FromDate;
   D2 := ToDate;

   Msg := 'Extract data [BK5 MGL format] from '+BkDate2Str( FromDate ) + ' to ' + bkDate2Str( ToDate );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg );

   Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
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
                  HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for bank account "'+
                     baBank_Account_Number + '". To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
                  exit;
               end;

               if not TravUtils.HasRequiredGSTContraCodes( BA, FromDate, ToDate  ) then
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
         	Writeln( XFile, '"Number","Bank","Date","Reference","Account","Amount","Narration","Quantity","GST Class","GST Amount"' );
            NoOfEntries := 0;

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

