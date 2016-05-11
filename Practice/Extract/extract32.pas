unit Extract32;

{
  This unit contains all the ExtractData options for the various accounting
  systems.
}

{..$DEFINE TESTING}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ExtractData(const Fromdate: Integer = 0; const Todate: Integer = 0);

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  ExtractDlg, Globals, baobj32, Software, ContraDlg, WarningMoreFrm,
  ErrorMoreFrm, LogUtil, bkConst, InfoMoreFrm, StDate, S6INI,
  classes, bkDateUtils, SysUtils, ClientHomePagefrm, ExUtil,
  AcclipseX,
  AccountSoftX,
  AccPacWinX,
  AccPacX,
  AdvanceX,
  AdvanceXOld,
  AsciiXNZ,
  AsciiXOZ,
  AttacheBPNZX,
  AttacheBPOZX,
  ATTACHEXNZ,
  ATTACHEXOZ,
  BeyondX,
  CaseWareX,
  CashManX,
  CatsoftX,
  CeeDataX,
  CharterX,
  CLS3X,
  CLS41X,
  CLSY2KX,
  CompartoX,
  ConceptX,
  ConceptCashManager2000X,
  CSVX,
  GLMAN3X,
  GLMANX,
  GlobalNewX,
  GlobalX,
  HandiLedgerX,
  IntechX,
  IntersoftX,
  JobalOZX,
  KelloggX,
  M2000OldX,
  M2000x,
  MAS41X,
  MAS42X,
  //MAS_ASCIIX,
  //MAS4_50A_X,
  MGLX,
  MYOBAOX,
  MYOBX,
  MYOBGenX,
  ProflexX,
  QuickBooksX,
  SimpleFundX,
  SmartLinkX,
  XlonX,
  BusinessProductsExport,
  ComObj, bk5Except,
  SupervisorX, DesktopSuperX, ProSuperX, SageHandisoftSuperX,
  RewardSuperXmlX, ClassSuperXmlX,
  MYOBAccRightX,
  PracticeLedgerObj,
  BKDefs;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

const
   UnitName = 'Extract32';
   DebugMe  : Boolean = False;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{$IFNDEF TESTING}

procedure CheckForMissingExchangeRates(FromDate, ToDate: integer);
const
  MISSING_EXCHANGE_RATES_1 = 'There are entries without exchange rates for ';
  MISSING_EXCHANGE_RATES_2 = ' within the period you are trying to extract. ' +
                             'Please update the exchange rates before ' +
                             'extracting the data.';
var
  MissingISOCodes: string;
begin
  if not myClient.HasExchangeRates(MissingISOCodes, FromDate, ToDate) then
    HelpfulWarningMsg(MISSING_EXCHANGE_RATES_1 + MissingISOCodes +
                      MISSING_EXCHANGE_RATES_2, 0);
end;

procedure ExtractData(const Fromdate: Integer = 0; const Todate: Integer = 0);

const
   ThisMethodName = 'ExtractData';

var
   FD, TD       : integer;
   NF           : boolean;
   Path         : String;
   BA           : tBank_Account;
   i            : integer;
   Contra_Code  : String;
   Msg          : String;
   PeriodIndex: Integer;
   PeriodList: TDateList;
   BankIndex: Integer;

   ContraCodeInChart : pAccount_Rec;

   // Extracts the folder part of the path.
   // In case you're wondering why this is necessary, simply using ExtractFileDir on a directory
   // path without a backslash at the end would strip out the last folder name
   // eg. c:\test\test2 would become c:\test
   function GetFolderFromPath: string;
   begin
     if (ExtractFileExt(Path) = '') then
       Result := Path // user has selected a folder, not a file
     else
       Result := ExtractFileDir(Path);
     if (Copy(Result, Length(Result), 1) <> '\') then
       Result := Result + '\';
   end;
   
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned( myClient ) then exit;
   AssignGlobalRedrawForeign(True);

   SysUtils.SetCurrentDir( Globals.DataDir);
   FD := Fromdate;
   TD := ToDate;
   if not ExtractDlg.GetExtractParameters(
      FD,     { From Date }
      TD,     { To Date }
      NF,     { New Format }
      Path )  { Path }
      then exit;

   CheckForMissingExchangeRates(FD, TD);

   { Check that we have a contra account code and enter it if necessary }

   with MyClient, clFields do
   begin
      if Software.ContraCodeRequired( clCountry, clAccounting_System_Used ) then
      Begin
         For i := 0 to Pred( clBank_Account_List.ItemCount ) do
         begin
            BA := clBank_Account_List.Bank_Account_At( i );
            with BA.baFields do
            begin { Can we extract data for this account? }
               { Do not need a contra for Handliledger journals - case #2576 }
               {if (clCountry = whAustralia) and (clAccounting_System_Used = saHandiLedger) and (baAccount_Type in [ btCashJournals, btAccrualJournals ]) then
                 Continue;  NOT REQUIRED}
               if ( baAccount_Type in [ btBank, btCashJournals, btAccrualJournals ] ) and
                  ( baContra_Account_Code = '' ) then
               Begin
                  Contra_Code := '';
                  Msg := SHORTAPPNAME + ' needs to know the account code in your client''s chart for the bank account '
                         + BA.AccountName + '.'+#13+#13
                         + 'This account code will be used when the bank account contra entry is generated.';

                  if ContraDlg.GetContra( 'Enter Bank Account Contra Code', Msg, Contra_Code ) then
                     baContra_Account_Code := Contra_Code;
               end;

               ContraCodeInChart := MyClient.clChart.FindCode( baContra_Account_Code );
               if not assigned( ContraCodeInChart ) or      // Couldn't find the Contra code OR
                      ( assigned( ContraCodeInChart ) and   // Contra Code is found AND the
                        ContraCodeInChart.chInactive ) then // Contra code is not active
               begin
                 Msg := format( 'Your contra code for Bank Account number %s is ' +
                                'not valid. Please update under Other Functions ' +
                                '| Bank Accounts before exporting', [ baBank_Account_Number ] );
                 HelpfulErrorMsg( Msg, 0, true );
               end;

            end;
         end;
      end; { Contra Required }
   end; { with }

   with MyClient.clFields do
   Begin

      if (MyClient.clFields.clAccounting_System_Used = saBGL360) then
        // The default file name for BGL 360 is based off the current date,
        // so it shouldn't be saved as the path for next time
        clSave_Client_Files_To := ExtractFileDir(Path);

      Try
         Case clCountry of
            whNewZealand :
               Case clAccounting_System_Used of
                  snOther           : ;
                  snSolution6MAS42  : MAS42X.ExtractData( FD, TD, Path );
                  snHAPAS           : HelpfulInfoMsg( 'Sorry, HAPAS is not supported in '+ShortAppName, 0 );
                  snGLMan           : if NF then GLMANX.ExtractData( FD, TD, Path, True ) else GLMAN3X.ExtractData( FD, TD, Path );
                  snMYOB_AO_COM     : GLMANX.ExtractData( FD, TD, Path );
                  snAcclipse        : AcclipseX.ExtractData( FD, TD, Path );
                  snGlobal          : if NF then GlobalNewX.ExtractData( FD, TD, Path ) else GlobalX.ExtractData( FD, TD, Path );
                  snMaster2000      : if NF then M2000X.ExtractData( FD, TD, Path ) else M2000OldX.ExtractData( FD, TD, Path );
                  snAdvance         : if NF then AdvanceX.ExtractData( FD, TD, Path ) else AdvanceXOld.ExtractData( FD, TD, Path );
                  snSmartLink       : SmartLinkX.ExtractData( FD, TD, Path );
                  snXPA             : AdvanceX.ExtractData( FD, TD, Path );
                  snJobal           : SmartLinkX.ExtractData( FD, TD, Path );
                  snCashManager     : CashManX.ExtractData(FD, TD, Path );
                  snAttache         : AttacheXNZ.ExtractData(FD, TD, Path );
                  snASCIICSV        : AsciiXNZ.ExtractData(FD, TD, Path );
                  snCharterQX       : CHARTERX.ExtractData(FD, TD, Path );
                  snIntech          : IntechX.ExtractData(FD, TD, Path );
                  snKelloggs        : KELLOGGX.ExtractData(FD, TD, Path );
                  snAclaim          : HelpfulInfoMsg( 'Sorry, Aclaim is not supported in '+ShortAppName, 0 );
                  snIntersoft       : IntersoftX.ExtractData(FD, TD, Path );
                  snLotus123        : HelpfulInfoMsg( 'Sorry, Lotus 1-2-3 is not supported in '+ShortAppName, 0 );
                  snAccPac          : AccPacX.ExtractData(FD, TD, Path );
                  snCCM             : ConceptX.ExtractData(FD, TD, Path );
                  snMYOB            : MYOBX.ExtractData(FD, TD, Path );
                  snAccPacW         : AccPacWinX.ExtractData(FD, TD, Path );
                  snSmartBooks      : SmartLinkX.ExtractData( FD, TD, Path );
                  snBeyond          : BeyondX.ExtractData( FD, TD, Path );
                  snPastel          : HelpfulInfoMsg( 'Sorry, Pastel is not supported in '+ShortAppName, 0 );
                  snSolution6CLS3   : CLS3X.ExtractData( FD, TD, Path );
                  snSolution6CLS4   : CLS41X.ExtractData( FD, TD, Path );
                  snSolution6MAS41  : MAS41X.ExtractData( FD, TD, Path );
                  snAttacheBP       : AttacheBPNZX.ExtractData( FD, TD, Path );
                  snBK5CSV          : CSVX.ExtractData( FD, TD, Path );
                  snCaseWare        : CaseWareX.ExtractData( FD, TD, Path );
                  snSolution6CLSY2K : CLSY2KX.ExtractData( FD, TD, Path );
                  snConceptCash2000 : ConceptCashManager2000X.ExtractData( FD, TD, Path);
                  snQBWn		      : QuickBooksX.ExtractData( FD, TD, False, Path );
                  snQBWo		      : QuickBooksX.ExtractData( FD, TD, True, Path );
                  snMYOBGen         : MYOBGenX.ExtractData(Fd, TD, Path);
                  snQIF             : DoExtractBusinessProduct(FD, TD, Path);
                  snOFXV1           : DoExtractBusinessProduct(FD, TD, Path);
                  snOFXV2           : DoExtractBusinessProduct(FD, TD, Path);
                  snMYOBAccRight    : MYOBAccRightX.ExtractData( FD, TD, Path );
                  snMYOBOnlineLedger: PracticeLedger.ExportDataToAPI(FD, TD);
               end; { of Case }

            whAustralia :
               Case clAccounting_System_Used of
                  saOther           : ;
                  saSolution6MAS42  : MAS42X.ExtractData( FD, TD, Path );
                  saHAPAS           : HelpfulInfoMsg( 'Sorry, HAPAS is not supported in '+ShortAppName, 0 );
                  saCeeData         : CeeDataX.ExtractData( FD, TD );
                  saGLMan           : If NF then GLManX.ExtractData( FD, TD, Path, True ) else GLMAN3X.ExtractData( FD, TD, Path );
                  saOmicom          : if NF then AdvanceX.ExtractData( FD, TD, Path ) else AdvanceXOld.ExtractData( FD, TD, Path );
                  saXPA             : AdvanceX.ExtractData( FD, TD, Path );
                  saASCIICSV        : AsciiXOZ.ExtractData(FD, TD, Path );
                  saLotus123        : HelpfulInfoMsg( 'Sorry, Lotus 1-2-3 is not supported in '+ShortAppName, 0 );
                  saAttache         : AttacheXOZ.ExtractData(FD, TD, Path );
                  saHandiLedger     : HandiLedgerX.ExtractData( FD, TD, Path );
                  saBGLSimpleFund, saBGLSimpleLedger : SimpleFundX.ExtractData( clAccounting_System_Used, FD, TD, Path );
                  saBGL360          : SimpleFundX.ExtractData( clAccounting_System_Used, FD, TD, GetFolderFromPath + clCode + '_' + Date2Str(FD, 'ddmmyyyy') + '_' + Date2Str(TD, 'ddmmyyyy') + '.XML');
                  saMYOB            : MYOBX.ExtractData(FD, TD, Path);
                  saCeeDataCDS1     : HelpfulInfoMsg( 'Sorry, the CDS1 Format is not supported at present in '+ShortAppName, 0 );
                  saSolution6CLS3   : CLS3X.ExtractData( FD, TD, Path );
                  saSolution6CLS4   : CLS41X.ExtractData( FD, TD, Path );
                  saSolution6MAS41  : MAS41X.ExtractData( FD, TD, Path );
                  saQBWo		        : QuickBooksX.ExtractData( FD, TD,True, Path );
                  saQBWn		        : QuickBooksX.ExtractData( FD, TD,False, Path );
                  saBK5CSV          : CSVX.ExtractData( FD, TD, Path );
                  saTaxAssistant    : CSVX.ExtractData( FD, TD, Path );
                  saElite           : CSVX.ExtractData( FD, TD, Path);
                  saCaseWare        : CaseWareX.ExtractData( FD, TD, Path );
                  saAccountSoft     : AccountSoftX.ExtractData( FD, TD, Path );
                  saProflex         : ProflexX.ExtractData( FD, TD, Path );
                  saTeletaxLW       : ; { Unsupported }
                  saAttacheBP       : AttacheBPOZX.ExtractData(FD, TD, Path );
                  saSolution6CLSY2K : CLSY2KX.ExtractData( FD, TD, Path );
                  saEasyBooks       : JOBALOZX.ExtractData( FD, TD, Path );
                  saMGL             : MGLX.ExtractData( FD, TD, Path );
                  saComparto        : CompartoX.ExtractData( FD, TD, Path );
                  saXlon            : XlonX.ExtractData( FD, TD );
                  saCatsoft         : CatSoftX.ExtractData( FD, TD, Path );
                  saBCSAccounting   : CSVX.ExtractData( FD, TD, Path );
                  saMYOBAccountantsOffice,
                  saMYOB_AO_COM     : MYOBAOX.ExtractData( FD, TD, Path);
                  saSolution6SuperFund : SupervisorX.ExtractData(clAccounting_System_Used, FD, TD, Path);
                  saSupervisor, saSuperMate  : SupervisorX.ExtractData(clAccounting_System_Used, FD, TD, Path);
                  saMYOBGen         : MYOBGenX.ExtractData(Fd, TD, Path);
                  saAccomplishCashManager : CSVX.ExtractData( FD, TD, Path);
                  saPraemium        : CSVX.ExtractData( FD, TD, Path, true,true ); //#1889
                  saQIF             : DoExtractBusinessProduct(FD, TD, Path);
                  saOFXV1           : DoExtractBusinessProduct(FD, TD, Path);
                  saOFXV2           : DoExtractBusinessProduct(FD, TD, Path);
                  saDesktopSuper    : DesktopSuperX.ExtractData( FD, TD, Path );
                  saIRESSXplan      : CSVX.ExtractData( FD, TD, Path, true, true); //7587
                  saRewardSuper     : RewardSuperXmlX.ExtractData( FD, TD, Path, True, True );
                  saClassSuperIP    : ClassSuperXmlX.ExtractData( FD, TD, Path, True, True );
                  saProSuper        : ProSuperX.ExtractData( FD, TD, Path, True, True );
                  saSageHandisoftSuperfund : SageHandisoftSuperX.ExtractData( FD, TD, Path, True, True );
                  saAcclipse        : AcclipseX.ExtractData( FD, TD, Path );
                  saMYOBAccRight    : MYOBAccRightX.ExtractData( FD, TD, Path );
                  saMYOBOnlineLedger: PracticeLedger.ExportDataToAPI(FD, TD);
               end;


            whUK :
               Case clAccounting_System_Used of
                  suOther       : ;
                  suSageLine50  : ;
                  suQuickBooks  : CSVX.ExtractData( FD, TD, Path ); //QuickBooksX.ExtractData( FD, TD,False, Path );
                  suBK5CSV      : CSVX.ExtractData( FD, TD, Path );
                  suQIF         : DoExtractBusinessProduct(FD, TD, Path);
                  suOFXV1       : DoExtractBusinessProduct(FD, TD, Path);
                  suOFXV2       : DoExtractBusinessProduct(FD, TD, Path);
                  // suAcclipse        : AcclipseX.ExtractData( FD, TD, Path ); Might need this in future if iFirm (Acclipse) is added for UK

                  suTASBooks   :;
               end;
         end; { Case clCountry }

         PeriodList := GetPeriodsBetween(FD, TD, True);

         for BankIndex := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
         begin
           BA := MyClient.clBank_Account_List.Bank_Account_At(BankIndex);

           for PeriodIndex := 0 to Length(PeriodList) - 1 do
           begin
             BA.baFinalized_Exchange_Rate_List.AddExchangeRate(PeriodList[PeriodIndex], BA.Default_Forex_Conversion_Rate(PeriodList[PeriodIndex]));  
           end;
         end;
           

      except
         on e : EFCreateError do begin
            Msg := 'Please ensure this is a valid file name, and you have access rights to the directory.';
            HelpfulErrorMsg( Msg, 0, False, E.Message, True );
            Msg := 'EFCreateError : '+E.Message;
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
         end;
         on e : EInOutError do begin
            Msg := 'EInOutError occurred';
            HelpfulErrorMsg(Msg,0, false, E.Message, True);
            Logutil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
         end;

         on e : EOleSysError do
         begin
            Msg := 'Error extracting data.';
            HelpfulErrorMsg(Msg,0, True, E.Message + ' ' + E.ClassName, True);
         end;

         on e : EInterfaceError do
         begin
            Msg := 'Error extracting data.';
            HelpfulErrorMsg(Msg,0, True, E.Message + ' ' + E.ClassName, True);
         end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
{$ELSE}
(*
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TestNZ;

   procedure ClearFlags;
   var
      B : Integer;
      T : Integer;
   Begin
      with MyClient, clBank_Account_List do for B := 0 to Pred( ItemCount ) do
         with Bank_Account_At( B ), baTransaction_List do for T := 0 to Pred( ItemCount ) do
            with Transaction_At( T )^ do txDate_Transferred := 0;
   end;
   
Var
   Sys : Byte;
   FD  : TStDate;
   TD  : TStDate;
   
Begin
   with MyClient.clFields do
   Begin
      FD := bkDateUtils.bkStr2Date( '01/04/98' );
      TD := bkDateUtils.bkStr2Date( '30/06/98
      ' );
      for Sys := snMin to snMax do
      Begin
         clAccounting_System_Used := Sys;
         clLast_Batch_Number      := 0;
         case Sys of
{ snOther           } snOther           : ;
{ snSolution6MAS42  } snSolution6MAS42  : MAS42X.ExtractData( FD, TD, 'MAS42.5' );
{ snHAPAS           } snHAPAS           : HelpfulInfoMsg( 'Sorry, HAPAS is not supported in BankLink 5', 0 );
{ snGLMan           } snGLMan           : Begin
                                             GLMANX.ExtractData( FD, TD, 'CANEW.5' );
                                             ClearFlags;
                                             GLMAN3X.ExtractData( FD, TD, 'CAOLD.5' );
                                          end;
{ snGlobal          } snGlobal          : Begin
                                             GlobalX.ExtractData( FD, TD, 'GLOBAL.5' );
                                             ClearFlags;
                                             GlobalNewX.ExtractData( FD, TD, 'GLOBAL.NEW' );
                                          end;
{ snMaster2000      } snMaster2000      : Begin
                                             M2000X.ExtractData( FD, TD, 'M2000NEW.5' );
                                             ClearFlags;
                                             M2000OldX.ExtractData( FD, TD, 'M2000OLD.5' );
                                          end;
{ snAdvance         } snAdvance         : Begin
                                             AdvanceX.ExtractData( FD, TD, 'APSNEW.5' );
                                             ClearFlags;
                                             AdvanceXOld.ExtractData( FD, TD, 'APSOLD.5' );
                                          end;
{ snSmartLink       } snSmartLink       : SmartLinkX.ExtractData( FD, TD, '' );
{ snJobal           } snJobal           : ; //SmartLinkX.ExtractData( FD, TD, Path );
{ snCashManager     } snCashManager     : CashManX.ExtractData(FD, TD, 'CASHMAN.5' );
{ snAttache         } snAttache         : AttacheXNZ.ExtractData(FD, TD, 'ATTACHE.5' );
{ snASCIICSV        } snASCIICSV        : AsciiXNZ.ExtractData(FD, TD, 'ASCII.5' );
{ snCharterQX       } snCharterQX       : CHARTERX.ExtractData(FD, TD, 'CHARTER.5' );
{ snIntech          } snIntech          : IntechX.ExtractData(FD, TD, 'INTECH.5' );
{ snKelloggs        } snKelloggs        : KELLOGGX.ExtractData(FD, TD, 'KELLOGG.5' );
{ snAclaim          } snAclaim          : HelpfulInfoMsg( 'Sorry, Aclaim is not supported in BankLink 5', 0 );
{ snIntersoft       } snIntersoft       : IntersoftX.ExtractData(FD, TD, 'INTRSOFT.5' );
{ snLotus123        } snLotus123        : HelpfulInfoMsg( 'Sorry, Lotus 1-2-3 is not supported in BankLink 5', 0 );
{ snAccPac          } snAccPac          : AccPacX.ExtractData(FD, TD, 'ACCPAC.5' );
{ snCCM             } snCCM             : ConceptX.ExtractData(FD, TD, 'CONCEPT.5' );
{ snMYOB            } snMYOB            : MYOBX.ExtractData(FD, TD, 'MYOB.5' );
{ snAccPacW         } snAccPacW         : AccPacWinX.ExtractData(FD, TD, 'ACCPACW.5' );
{ snSmartBooks      } snSmartBooks      : ; // SmartLinkX.ExtractData( FD, TD, Path );
{ snBeyond          } snBeyond          : BeyondX.ExtractData( FD, TD, 'BEYOND.5' );
{ snPastel          } snPastel          : HelpfulInfoMsg( 'Sorry, Pastel is not supported in BankLink 5', 0 );
{ snSolution6CLS3   } snSolution6CLS3   : CLS3X.ExtractData( FD, TD, 'CLS3.5' ); 
{ snSolution6CLS4   } snSolution6CLS4   : CLS41X.ExtractData( FD, TD, 'CLS4.5' ); 
{ snSolution6MAS41  } snSolution6MAS41  : MAS41X.ExtractData( FD, TD, 'MAS41.5' ); 
{ snAttacheBP       } snAttacheBP       : AttacheBPNZX.ExtractData( FD, TD, 'BUSPTNR.5' );
{ snBK5CSV          } snBK5CSV          : CSVX.ExtractData( FD, TD, 'BK5CSV.5' );


         end;
         ClearFlags; 
      end;
   end;
end;   

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TestOZ;

   procedure ClearFlags;
   var
      B : Integer;
      T : Integer;
   Begin
      with MyClient, clBank_Account_List do for B := 0 to Pred( ItemCount ) do
         with Bank_Account_At( B ), baTransaction_List do for T := 0 to Pred( ItemCount ) do
            with Transaction_At( T )^ do txDate_Transferred := 0;
   end;
   
Var
   Sys : Byte;
   FD  : TStDate;
   TD  : TStDate;
   
Begin
   with MyClient.clFields do
   Begin
      FD := bkDateUtils.bkStr2Date( '01/04/98' );
      TD := bkDateUtils.bkStr2Date( '30/06/98' );
      for Sys := saMin to saMax do
      Begin
         clAccounting_System_Used := Sys;
         clLast_Batch_Number      := 0;
         case Sys of
{ saOther           } saOther           : ;
{ saSolution6MAS42  } saSolution6MAS42  : MAS42X.ExtractData( FD, TD, 'MAS42.5' ); 
{ saHAPAS           } saHAPAS           : HelpfulInfoMsg( 'Sorry, HAPAS is not supported in BankLink 5', 0 );
{ saCeeData         } saCeeData         : CeeDataX.ExtractData( FD, TD, 'CEEDATA.5' );
{ saGLMan           } saGLMan           : 
                                          Begin
                                             GLMANX.ExtractData( FD, TD, 'CANEW.5' );
                                             ClearFlags;
                                             GLMAN3X.ExtractData( FD, TD, 'CAOLD.5' );
                                          end;
{ saOmicom          } saOmicom          : 
                                          Begin
                                             AdvanceX.ExtractData( FD, TD, 'APSNEW.5' );
                                             ClearFlags;
                                             AdvanceXOld.ExtractData( FD, TD, 'APSOLD.5' );
                                          end;

{ saASCIICSV        } saASCIICSV        : AsciiXOZ.ExtractData(FD, TD, 'ASCII.5' );
{ saLotus123        } saLotus123        : HelpfulInfoMsg( 'Sorry, Lotus 1-2-3 is not supported in BankLink 5', 0 );
{ saAttache         } saAttache         : AttacheXOZ.ExtractData(FD, TD, 'ATTACHE.5' );
{ saHandiLedger     } saHandiLedger     : HandiLedgerX.ExtractData( FD, TD, 'HANDI.5' );
{ saBGLSimpleFund   } saBGLSimpleFund   : SimpleFundX.ExtractData( FD, TD, 'SIMPLE.5' );
{ saMYOB            } saMYOB            : MYOBX.ExtractData(FD, TD, 'MYOB.5' );
{ saCeeDataCDS1     } saCeeDataCDS1     : HelpfulInfoMsg( 'Sorry, the CDS1 Format is not supported at present in BankLink 5', 0 );
{ saSolution6CLS3   } saSolution6CLS3   : CLS3X.ExtractData( FD, TD, 'CLS3.5' ); 
{ saSolution6CLS4   } saSolution6CLS4   : CLS41X.ExtractData( FD, TD, 'CLS4.5' ); 
{ saSolution6MAS41  } saSolution6MAS41  : MAS41X.ExtractData( FD, TD, 'MAS41.5' ); 
{ saBK5CSV          } saBK5CSV          : CSVX.ExtractData( FD, TD, 'BK5CSV.5' ); 
         end;
         ClearFlags; 
      end;
   end;
end;   

procedure ExtractData;

Begin
   with MyClient.clFields do
   Begin
      case clCountry of
         whNewZealand : TestNZ;
         whAustralia  : TestOZ;
      end;
   end;
end;
*)
{$ENDIF}

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
