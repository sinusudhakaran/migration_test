unit Import32;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------
{$IFDEF SmartBooks}
   .. smart books code removed from this unit
{$ENDIF}
uses
  AccountSoft,
  AccPacPlus,
  AccpacWin,
  APSAdvance,
  AttacheBPOZ,
  AttacheNZ,
  AttacheOZ,
  BCSAccounting,
  Beyond,
  CaseWare,
  CASystems,
  CASystemsOZ,
  Catsoft,
  CeeData,
  CharterQX,
  Comparto,
  Concept,
  ConceptCashManager2000,
  CSVChart,
  Global,
  HandiLedger,
  Intech,
  Intersoft,
  Master2000,
  MGL,
  MYOB,
  MYOBGen,
  MYOBAO,
  Proflex,
  QuickBooks,
  SimpleFund,
  Solution6,
  bkconst,
  bkdefs,
  clObj32,
  globals,
  GSTUtil32,
  LogUtil,
  software,
  sysutils,
  WarningMoreFrm,
  WinUtils,
  DesktopSuper,
  ProSuper,
  ClassSuperIP;

Const
   UnitName = '';
   DebugMe  : Boolean = False;

//------------------------------------------------------------------------------

procedure RefreshChart;
{
  !!! Calls ApplyDefaultGST if the chart changes so that coding is updated !!!
}

   procedure NZRefreshChart;
   Begin
      with MyClient.clFields do
      case clAccounting_System_Used of
         snOther          : ;
         snSolution6MAS42 : Solution6.RefreshChart;
         snHAPAS          : ;
         snGLMan,
         snMYOB_AO_COM    : CASystems.RefreshChart;
         snGlobal         : Global.RefreshChart;
         snMaster2000     : Master2000.RefreshChart;
         snAdvance        : APSAdvance.RefreshChart;
         snXPA            : APSAdvance.RefreshChart;
         snSmartLink      : ;
         snJobal          : ;
         snCashManager    : CSVChart.RefreshChart( '*.CHT', '', iText );
         snAttache        : AttacheNZ.RefreshChart;
         snASCIICSV       : ;
         snCharterQX      : CharterQX.RefreshChart;
         snIntech         : Intech.RefreshChart;
         snKelloggs       : ;
         snAclaim         : ;
         snIntersoft      : Intersoft.RefreshChart;
         snLotus123       : ;
         snAccPac         : AccPacPlus.RefreshChart;
         snCCM            : Concept.RefreshChart;
         snMYOB           : MYOB.RefreshChart;
         snMYOBGen        : MYOBGen.RefreshChart;
         snAccPacW        : AccPacWin.RefreshChart;
         snBeyond         : Beyond.RefreshChart;
         snPastel         : ;
         snSolution6CLS3  : Solution6.RefreshChart;
         snSolution6CLS4  : Solution6.RefreshChart;
         snSolution6MAS41 : Solution6.RefreshChart;
         snAttacheBP      : AttacheNZ.RefreshChart;
         snSolution6CLSY2K: Solution6.RefreshChart;
         snConceptCash2000 : ConceptCashManager2000.RefreshChart;
         snBK5CSV         : CSVChart.RefreshChart( '*.CSV', '', iText );
         snQBWN,
         snQBWO           : QuickBooks.RefreshChart;
      end; { of Case }
   end; { NZRefreshChart }

   //---------------------------------------------------------------------------

   procedure OZRefreshChart;
   Begin
      with MyClient.clFields do
      Case clAccounting_System_Used of
         saOther          : ;
         saSolution6MAS42 : Solution6.RefreshChart;
         saHAPAS          : ;
         saCeeData        : CeeData.RefreshChart;
         saGLMan          : CASystemsOZ.RefreshChart;
         saOmicom         : APSAdvance.RefreshChart;
         saXPA            : APSAdvance.RefreshChart;
         saASCIICSV       : ;
         saLotus123       : ;
         saAttache        : AttacheOZ.RefreshChart;
         saHandiLedger    : Handiledger.RefreshChart;
         saBGLSimpleFund, saBGLSimpleLedger  : SimpleFund.RefreshChart;
         saMYOB           : MYOB.RefreshChart;
         saMYOBGen        : MYOBGen.RefreshChart;
         saCeeDataCDS1    : ;
         saSolution6CLS3  : Solution6.RefreshChart;
         saSolution6CLS4  : Solution6.RefreshChart;
         saSolution6MAS41 : Solution6.RefreshChart;
         saQBWN,
         saQBWO           : QuickBooks.RefreshChart;
         saCaseWare       : CaseWare.RefreshChart;
         saAccountSoft    : AccountSoft.RefreshChart;
         saProflex        : Proflex.RefreshChart;
         saAttacheBP      : AttacheBPOZ.RefreshChart;
         saSolution6CLSY2K: Solution6.RefreshChart;
         saMGL            : MGL.RefreshChart;
         saComparto       : Comparto.RefreshChart;
         saXlon           : Ceedata.RefreshChart;
         saCatsoft        : Catsoft.RefreshChart;
         saBCSAccounting  : BCSAccounting.RefreshChart;
         saMYOBAccountantsOffice,
         saMYOB_AO_COM : MYOBAO.RefreshChart;
         saBK5CSV         : CSVChart.RefreshChart( '*.CSV', 'GENERIC.TPM', iText );
         saTaxAssistant   : CSVChart.RefreshChart( '*.CSV', 'TAXASST.TPM', iText );
         saElite          : CSVChart.RefreshChart( '*.CSV', 'ELITE.TPM', iText);
         saSolution6SuperFund : CSVChart.RefreshChart('*.CHT', '', iText);
         saSupervisor, saSuperMate : CSVChart.RefreshChart('*.CHT', '', iText);
         saAccomplishCashManager : CSVChart.RefreshChart('*.CSV', 'ACCOMPAU.TPM', iText);
         saPraemium       : CSVChart.RefreshChart( '*.CSV', '', iText );
         saDesktopSuper   : DesktopSuper.RefreshChart('*.CSV');
         saClassSuperIP   : ClassSuperIP.RefreshChart;
         saProSuper       : ProSuper.RefreshChart('*.CSV');
      end; { of Case }
   end; { OZRefreshChart }

   //---------------------------------------------------------------------------

   procedure UKRefreshChart;
   Begin
      Case MyClient.clFields.clAccounting_System_Used of
         suOther                   : ;
         suPA7                     : APSAdvance.RefreshChart;
         suXPA                     : APSAdvance.RefreshChart;
         suBK5CSV                  : CSVChart.RefreshChart( '*.CSV', 'GENERIC.TPM', iText );
         suSolution6MAS42          : Solution6.RefreshChart;
         suMYOBAccountantsOffice   : MYOBAO.RefreshChart;
         suMYOB_AO_COM             : MYOBAO.RefreshChart;
//         suDigita                  : ;
//         suSage                    : ;
      end;
   end;

   //---------------------------------------------------------------------------

const
   ThisMethodName = 'RefreshChart';

var
   Master     : TClientObj;
   MCountry   : Byte;
   MSystem    : Byte;
   CCountry   : Byte;
   CSystem    : Byte;
   MA         : pAccount_Rec;
   i          : integer;
   OldCRC     : LongWord;
   NewCRC     : LongWord;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned( Globals.MyClient ) then exit;

   { -------------------- Refresh this clients chart --------------- }

   with MyClient, clFields do
   begin
      if not Software.CanRefreshChart( clCountry, clAccounting_System_Used ) then
      Begin
         HelpfulWarningMsg( 'Sorry, you can''t refresh the chart from this accounting system', 0 );
         Exit;
      end;
      OldCRC := MyClient.clChart.GetCurrentCRC;
      Case clCountry of
         whNewZealand : NZRefreshChart;
         whAustralia  : OZRefreshChart;
         whUK         : UKRefreshChart;
      end;
      NewCRC := MyClient.clChart.GetCurrentCRC;
      if OldCRC = NewCRC then Exit; { nothing changed }

      clUse_Minus_As_Lookup_Key := clChart.UseMinusAsLookup;
      clUppercase_Codes         := not clChart.AllowLowerCase;

      clChart.RefreshDependencies;
   end; {with}


   //try finally required so that ApplyGSTDefaults if called.  But dont want to call it
   //until we have finished updating the chart
   try
      //if this client is the master client then nothing more to do so exit
      if MyClient.clFields.clCode = 'MASTER' then Exit;

      {------- Merge Chart and GST with the Master client if one exists ------}
      if not BKFileExists( DATADIR+ 'MASTER'+ FILEEXTN ) then exit;

      Master := TClientObj.Create;
      Try
         Master.Open( 'MASTER', FILEEXTN);
         With Master.clFields do
         Begin
            MCountry := clCountry;
            MSystem  := clAccounting_System_Used;
         end;
         With MyClient.clFields do
         Begin
            CCountry := clCountry;
            CSystem  := clAccounting_System_Used;
         end;
         If ( CCountry = MCountry ) and ( CSystem = MSystem ) then
         Begin
            //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            //  Merge the information from the MASTER client
            //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

            with MyClient.clChart do
            Begin
               For i := 0 to Pred( ItemCount) do
               Begin
                  with Account_At(i)^ do
                  Begin

                     //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                     //  Merge the GST information from the MASTER client
                     //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

                     If Software.ApplyAccountGSTClassesFromMaster( CCountry, CSystem ) then
                     Begin
                        if chGST_Class = 0 then
                        Begin
                           MA := Master.clChart.FindCode( chAccount_Code );
                           if Assigned( MA ) then chGST_Class := MA.chGST_Class;
                        end;
                     end;

                     //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                     //  Merge the Account Type information from the MASTER client
                     //  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

                     if Software.ApplyAccountTypesFromMASTER( CCountry, CSystem ) then
                     Begin
                        if ( chAccount_Type = atNone ) then
                        begin
                           MA := Master.clChart.FindCode( chAccount_Code );
                           if Assigned( MA ) then chAccount_Type := MA.chAccount_Type;
                        end;
                     end;
                  end;
               end;

               RefreshDependencies;
            end;
         end;  {with}

      finally
         Master.Free;
      end;

   finally
      GSTUTIL32.ApplyDefaultGST( false);
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.



