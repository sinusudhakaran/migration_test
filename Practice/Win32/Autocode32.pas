Unit Autocode32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Autocodes the entries for a specified Bank Account for the given client
//
//******************************************************************************
//IMPORTANT:
//
//Is called from MERGE32 which does not use the global Client object
//therefore this unit and any of the units it calls cannot be COUPLED in any way
//to use the global client object.
//******************************************************************************
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE
USES
   baobj32,
   MemorisationsObj,
   bkDefs,
   clObj32;

Procedure AutoCodeEntries( aClient : TClientObj;
                           BA : TBank_Account;
                           CONST EntryType : Byte;
                           CONST FromDate, ToDate : LongInt;
                           DoUpdateRecMemCandidates: boolean = True);

Function FindMemorisation( const aBankAccount : TBank_Account;
                           const aTransaction : pTransaction_Rec;
                           var   aMemorisedTransaction : TMemorisation ) : Boolean;

CONST AllEntries : Byte = 255;

//******************************************************************************
implementation
uses
  Classes,
  software,
  BKCONST,
  BKDSIO,
  GenUtils,
  glConst,
  GLOBALS,
  GSTCALC32,
  LOGUTIL,
  MATCHES,
  MONEYDEF,
  mxUtils,
  mxFiles32,
  PayeeObj,
  StStrS,
  trxList32,
  ForexHelpers,
  SuperFieldsUtils,
  transactionUtils,
  ECollect,
  SysUtils,
  Admin32,
  SystemMemorisationList,
  SYDEFS,
  MainFrm;

const
   DebugMe : Boolean = FALSE;

{ ---------------------------------------------------------------------- }

Procedure AutoCodeEntries( aClient : TClientObj;
                           BA : TBank_Account;
                           CONST EntryType : Byte;
                           CONST FromDate, ToDate : LongInt;
                           DoUpdateRecMemCandidates: boolean = True);

VAR
   Mask           : Bk5CodeStr;
   Analysis       : String[12];
   TempStr        : Bk5CodeStr;
   p              : Integer;
   TestCode       : ShortString;
   No             : LongInt;
   BankPrefix     : BankPrefixStr;
   EntryNo        : LongInt;
   MX             : TMemorisation;
   MXFound        : TMemorisation;
   Edited         : Boolean;
   Split          : MemSplitTotals;
   SplitPct       : MemSplitPercentages;
   PayeeSplit     : PayeeSplitTotals;
   PayeeSplitPct  : PayeeSplitPercentages;
   i              : Integer;
   NoDigits       : Integer;
   IsDissected    : Boolean;
   checkMasterMX  : boolean;

//   MasterMemList  : TMaster_Memorisations_List;
   MasterMemList  : TMemorisations_List;
   MemorisationLine : pMemorisation_Line_Rec;

   AnalysisMatchFound : boolean;

   Transaction    : pTransaction_Rec;
   Dissection     : pDissection_Rec;

   Payee          : TPayee;
   PayeeLine : pPayee_Line_Rec;

   DoAnalysisCoding : boolean;
   SubCode          : string;
   //WasEdited        : Boolean;
   AuditIDList: TList;
   MaintainMemScanStatus: boolean;

   function DoSuperFund: Boolean;
   begin
      if MemorisationLine.mlSF_Edited
      and (aClient.clFields.clCountry = whAustralia) then begin

         Result := (not (aClient.clFields.clAccounting_System_Used in [saBGLSimpleFund, saBGLSimpleLedger, saBGL360]))
                or (Transaction.txDate_Effective >= mcSwitchDate); // cannot do new and Old list

      end else
         Result := False
   end;

Var
  Amount : Money;
  Msg : String;
  Forex : Boolean;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
Begin
   try
     if Assigned(frmMain) then
     begin
       MaintainMemScanStatus := frmMain.MemScanIsBusy;
       frmMain.MemScanIsBusy := True;
     end;

     With aClient, BA do
     Begin
        If ( baFields.baAccount_Type <> btBank ) then
           Exit; // This procedure is for Bank Accounts only
        If baTransaction_List.ItemCount = 0 then
           Exit;

        Forex := BA.IsAForexAccount;

        // Use pure numeric analysis matching - mask is irrelevant
        Mask := ConstStr( '#', MaxBk5CodeLen );

        baMemorisations_List.UpdateLinkedLists;
        MasterMemList := nil;

        //test to see if we should check for master memorisations
        BankPrefix := mxFiles32.GetBankPrefix( baFields.baBank_Account_Number);
        CheckMasterMX := false;
        if (baFields.baApply_Master_Memorised_Entries) and Assigned(AdminSystem) and
           (aClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number) and
           (aClient.clFields.clDownload_From = dlAdminSystem) then
        begin
           Master_Mem_Lists_Collection. ReloadSystemMXList( BankPrefix);

           //Master memorisations are now stored in the System DB - so it
           //must be reloaded if the datetime stamp has changed (i.e another
           //user has updated it and master mems may have changed).
           RefreshAdmin;
           SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BankPrefix);
           if Assigned(SystemMemorisation) then
             MasterMemList := TMemorisations_List(SystemMemorisation.smMemorisations);

           if Assigned( MasterMemList) then
             begin
               MasterMemList.UpdateLinkedLists;
               CheckMasterMX := true;
             end;
        end;

        //cycle thru the transactions
        With baTransaction_List do For EntryNo := 0 to Pred( ItemCount ) do
        Begin
           Transaction := Transaction_At( EntryNo );
           With Transaction^ do
           Begin
              //figure out if transaction needs to be skipped
              If txLocked then
                 Continue; // Locked, don't change

              If txDate_Transferred <> 0 then
                 Continue; // Transfered, don't change

              If ( txType <> EntryType )
              and not ( EntryType = AllEntries ) then
                 Continue; // Not the type we are looking for

              // Check the Date Range
              if txDate_Effective < FromDate then
                 Continue;
              if (ToDate > 0)
              and (txDate_Effective > ToDate) then
                 Continue;
              //WasEdited := false;

              if txHas_Been_Edited then begin
                 // Check if this is actualy True..
                 if txAccount > '' then begin
                    //TFS 12252 - update alternative account codes when chart has been refreshed
                    if HasAlternativeChartCode(aClient.clFields.clCountry, aClient.clFields.clAccounting_System_Used) then
                      txAccount := aCLient.clChart.MatchAltCode(txAccount);
                    Continue; // Must be True
                 end;
                 if txSF_Super_Fields_Edited then
                    if txCoded_By in [cbManualSuper,cbECodingManual] then
                       Continue; // Must be True
                 txHas_Been_Edited := False;// was not True
                 //WasEdited := true;
              end;


              //May add this back in later once have considered all implications
              //There is an issue if no chart exists and values in the analysis col.  Need a way to
              //stop analysis coding occuring...
              //If ( txAccount = '' ) and ( txFirst_Dissection = NIL ) then txCoded_By := cbNotCoded;

              //Try to automatically replace the gst amounts if transaction hasnt been edited
              If ( txCoded_By in [ cbManual, cbManualPayee, cbECodingManual, cbECodingManualPayee, cbManualSuper ] ) then
              Begin
                 // Still Check the GST...
                 If ( txFirst_Dissection=NIL ) then
                 Begin
                    If ( txGST_Class = 0 ) and ( not txGST_Has_Been_Edited) then begin  //if the gst has been edited then txHas_Been with be set
                       CalculateGST( aClient, txDate_Effective, txAccount, Local_Amount, txGST_Class, txGST_Amount );
                       txGST_Has_Been_Edited := false;
                    end;
                    Continue;
                 end
                 else
                 Begin
                    Dissection := txFirst_Dissection;
                    While Dissection<>NIL do With Dissection^ do
                    Begin
                       If ( dsGST_Class=0 ) and ( not( dsHas_Been_Edited or dsGST_Has_Been_Edited)) then begin
                          CalculateGST( aClient, txDate_Effective, dsAccount, Local_Amount, dsGST_Class, dsGST_Amount );
                          dsHas_Been_Edited := false;
                       end;
                       Dissection := dsNext;
                    end;
                 end;
                 // GST Done Cannot do anything else
                 Continue;
              end;

              //prevent dissections from being cleared if quantity or super fields
              //edited

              Edited := FALSE;
              Dissection := txFirst_Dissection;
              While (Dissection<>NIL)
              and (not Edited) do
                 With Dissection^ do Begin
                    Edited := (dsQuantity <> 0) or
                              ( ( dsSF_Super_Fields_Edited ) and not(txCoded_By in [cbMemorisedM, cbMemorisedC]));
                    Dissection := dsNext;
                 end;

              If Edited then
                Continue;

              // Update recommended memorisation scanning
              if DoUpdateRecMemCandidates then
                aClient.clRecommended_Mems.UpdateCandidateMems(Transaction, True);

              //clear any existing coding
              txAccount         := '';
              txJob_Code        := '';
              txPayee_Number    := 0;
              txMatched_By      := nil;
              txCoded_By        := cbNotCoded;
              ClearGSTFields( Transaction);
              ClearSuperFundFields(Transaction);
              {if not WasEdited then
                 txJob_Code := '';  Job is not Blanked }

              AuditIDList := TList.Create;
              try
                //Remove any dissections
                Dump_Dissections( Transaction, AuditIDList );

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //                   M E M O R I S A T I O N S
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                With baMemorisations_List do
                Begin
                   //check for client memorisations
                   MX :=  MXFirstByEntryType[ txType ];
                   MXFound := NIL;
                   while (MX<>NIL)
                   and (MXFound=NIL) do begin
                      if CanMemorise (Transaction, MX) then begin
                         if (not (MX.mdFields.mdFrom_Master_List)) // Don't care
                         or (not (MX.mdFields.mdUse_Accounting_System)) // Don't care
                         or (MX.mdFields.mdAccounting_System = aClient.clFields.clAccounting_System_Used) {Does match} then
                            if MX.FirstLine <> nil then
                               MXFound := MX;
                      end;
                      MX := TMemorisation(MX.mdFields.mdNext_Memorisation);
                   end;

                   //check for MASTER memorisations
                   if (MXFound = nil)
                   and CheckMasterMX then begin
                      MX := MasterMemList.mxFirstByEntryType[txType];
                      while (mx <> nil)
                      and (mxFound = nil) do begin
                         // Check if we should apply this..
                         if (not (MX.mdFields.mdUse_Accounting_System)) // Dont care
                         or (MX.mdFields.mdAccounting_System = aClient.clFields.clAccounting_System_Used) {Does match} then
                            if MxUtils.CanMemorise(Transaction, mx) then
                               mxFound := MX;
                         Mx := TMemorisation(Mx.mdFields.mdNext_Memorisation);
                      end;
                   end;

                   //if mx found then autocode this transactions
                   MX := MXFound;
                   If MX<>NIL then With MX.mdFields^ do
                   Begin
                      if mdFrom_Master_List then
                        txCoded_By := BKCONST.cbMemorisedM
                      else
                        txCoded_By := BKCONST.cbMemorisedC;

                      txMatched_By := MX.mdFields;

                      mdDate_Last_Applied := txDate_Effective;

                      if not Mx.IsDissected then
                        begin
                          //code the single line
                          MemorisationLine := Mx.FirstLine;
                          if HasAlternativeChartCode (aClient.clFields.clCountry,aClient.clFields.clAccounting_System_Used ) then
                             txAccount := aCLient.clChart.MatchAltCode(MemorisationLine.mlAccount)
                          else
                             txAccount := MemorisationLine.mlAccount;

                          txPayee_Number := MemorisationLine.mlPayee;
                          if MemorisationLine.mlJob_Code > '' then
                             txJob_Code := MemorisationLine.mlJob_Code;
                          //calculate GST class and Amounts.  If the gst has not been edited then use the default for
                          //the chart
                          if MemorisationLine.mlGST_Has_Been_Edited then
                            begin
                              txGST_Class := MemorisationLine.mlGST_Class;
                              txGST_Amount := CalculateGSTForClass( aClient, txDate_Effective, Local_Amount, txGST_Class );
                              txGST_Has_Been_Edited := true;
                            end
                          else
                            begin
                              CalculateGST( aClient,txDate_Effective, txAccount, Local_Amount, txGST_Class, txGST_Amount );
                              txGST_Has_Been_Edited := false;
                            end;

                          //set narration
                          if MemorisationLine.mlGL_Narration <> '' then
                             txGL_Narration := MemorisationLine.mlGL_Narration;

                          if DoSuperFund then begin
                             if MemorisationLine.mlSF_PCFranked <> 0 then begin
                                 txSF_Franked := abs(Double2Money (Percent2Double(MemorisationLine.mlSF_PCFranked) * Money2Double(txAmount)/100));
                                 txSF_Imputed_Credit := FrankingCredit(txSF_Franked, txDate_Effective);
                             end;
                             if MemorisationLine.mlSF_PCUnFranked <> 0 then begin
                                 if (MemorisationLine.mlSF_PCUnFranked + MemorisationLine.mlSF_PCFranked) = 1000000 then
                                     txSF_UnFranked := Abs(txAmount) - txSF_Franked  // No Rounding Isues
                                 else
                                     txSF_UnFranked := abs(Double2Money (Percent2Double(MemorisationLine.mlSF_PCUnFranked) * Money2Double(txAmount)/100));
                             end;
                             txSF_Member_Account_ID    := MemorisationLine.mlSF_Member_Account_ID;
                             txSF_Member_Account_Code  := MemorisationLine.mlSF_Member_Account_Code;
                             txSF_Fund_ID              := MemorisationLine.mlSF_Fund_ID;
                             txSF_Fund_Code            := MemorisationLine.mlSF_Fund_Code;
                             txSF_Member_ID            := MemorisationLine.mlSF_Member_ID;
                             txSF_Transaction_ID       := MemorisationLine.mlSF_Trans_ID;
                             txSF_Transaction_Code     := MemorisationLine.mlSF_Trans_Code;
                             txSF_Member_Account_ID    := MemorisationLine.mlSF_Member_Account_ID;
                             txSF_Member_Account_Code  := MemorisationLine.mlSF_Member_Account_Code;
                             txSF_Member_Component     := MemorisationLine.mlSF_Member_Component;

                             if MemorisationLine.mlQuantity <> 0 then
                                txQuantity := MemorisationLine.mlQuantity;
                             if MemorisationLine.mlSF_GDT_Date <> 0 then
                                txSF_CGT_Date := MemorisationLine.mlSF_GDT_Date;

                             txSF_Capital_Gains_Fraction_Half := MemorisationLine.mlSF_Capital_Gains_Fraction_Half;

                             SplitRevenue(txAmount,
                                           txSF_Tax_Free_Dist,
                                           txSF_Tax_Exempt_Dist,
                                           txSF_Tax_Deferred_Dist,
                                           txSF_Foreign_Income,
                                           txSF_Capital_Gains_Indexed,
                                           txSF_Capital_Gains_Disc,
                                           txSF_Capital_Gains_Other,
                                           txSF_Capital_Gains_Foreign_Disc,
                                           txSF_Other_Expenses,
                                           txSF_Interest,
                                           txSF_Rent,
                                           txSF_Special_Income,
                                           MemorisationLine);
                             txSF_Super_Fields_Edited  := True;
                          end else begin
                             ClearSuperFundFields(Transaction);
                          end;
                          Continue;
                        end;

                      //Dissected memorisation
                      Amount := Transaction.txAmount;

                      //Entry needs to be dissected
                      mxUtils.MemorisationSplit( Amount, MX, Split, SplitPct );
                      txAccount      := DISSECT_DESC;
                      txPayee_Number := 0;
                      ClearGSTFields( Transaction);
                      ClearSuperFundFields( Transaction);

                      for i := MX.mdLines.First to MX.mdLines.Last do
                        begin
                          MemorisationLine := MX.mdLines.MemorisationLine_At(i);
                          if ( MemorisationLine.mlAccount <> '') or ( Split[i] <> 0) then
                            begin
                              New( Dissection );
                              FillChar( Dissection^, Dissection_Rec_Size, 0);
                              Dissection.dsBank_Account := Transaction.txBank_Account;
                              with Dissection^ do
                                begin
                                  dsRecord_Type := tkBegin_Dissection;
                                  dsEOR := tkEnd_Dissection;
                                  dsTransaction  := Transaction;
                                  if HasAlternativeChartCode (aClient.clFields.clCountry,aClient.clFields.clAccounting_System_Used ) then
                                     dsAccount := aCLient.clChart.MatchAltCode(MemorisationLine.mlAccount)
                                  else
                                     dsAccount := MemorisationLine.mlAccount;
                                  dsAmount := Split[i];
                                  dsPercent_Amount := SplitPct[i];
                                  dsAmount_Type_Is_Percent := SplitPct[i] <> 0;
                                  dsPayee_Number := MemorisationLine.mlPayee;
                                  if MemorisationLine.mlJob_Code > '' then begin
                                     txJob_Code := '';
                                     dsJob_Code := MemorisationLine.mlJob_Code;
                                  end;

                                  dsGST_Has_Been_Edited := false;
                                  if MemorisationLine.mlGST_Has_Been_Edited then begin
                                      dsGST_Class := MemorisationLine.mlGST_Class;
                                      dsGST_Has_Been_Edited := true;
                                  end;

                                  if MemorisationLine.mlGL_Narration <> '' then
                                     dsGL_Narration := MemorisationLine.mlGL_Narration
                                  else
                                     dsGL_Narration := txGL_Narration;

                                  if DoSuperFund then begin
                                     if MemorisationLine.mlSF_PCFranked <> 0 then begin
                                        dsSF_Franked := abs(Double2Money (Percent2Double(MemorisationLine.mlSF_PCFranked) * Money2Double(dsAmount)/100));
                                        dsSF_Imputed_Credit := FrankingCredit(dsSF_Franked, txDate_Effective);
                                     end;

                                     if MemorisationLine.mlSF_PCUnFranked <> 0 then begin

                                        if (MemorisationLine.mlSF_PCUnFranked + MemorisationLine.mlSF_PCFranked) = 1000000 then
                                           dsSF_UnFranked := Abs(dsAmount) - dsSF_Franked  // No Rounding Isues
                                        else
                                           dsSF_UnFranked := abs(Double2Money (Percent2Double(MemorisationLine.mlSF_PCUnFranked) * Money2Double(dsAmount)/100));
                                     end;

                                     dsSF_Member_Account_ID    := MemorisationLine.mlSF_Member_Account_ID;
                                     dsSF_Member_Account_Code  := MemorisationLine.mlSF_Member_Account_Code;
                                     dsSF_Fund_ID              := MemorisationLine.mlSF_Fund_ID;
                                     dsSF_Fund_Code            := MemorisationLine.mlSF_Fund_Code;
                                     dsSF_Member_ID            := MemorisationLine.mlSF_Member_ID;
                                     dsSF_Transaction_ID       := MemorisationLine.mlSF_Trans_ID;
                                     dsSF_Transaction_Code     := MemorisationLine.mlSF_Trans_Code;
                                     dsSF_Member_Account_ID    := MemorisationLine.mlSF_Member_Account_ID;
                                     dsSF_Member_Account_Code  := MemorisationLine.mlSF_Member_Account_Code;
                                     dsSF_Member_Component     := MemorisationLine.mlSF_Member_Component;

                                     if MemorisationLine.mlQuantity <> 0 then
                                        dsQuantity := MemorisationLine.mlQuantity;

                                     if MemorisationLine.mlSF_GDT_Date <> 0 then
                                        dsSF_CGT_Date := MemorisationLine.mlSF_GDT_Date;

                                     dsSF_Capital_Gains_Fraction_Half := MemorisationLine.mlSF_Capital_Gains_Fraction_Half;
                                     SplitRevenue(dsAmount,
                                           dsSF_Tax_Free_Dist,
                                           dsSF_Tax_Exempt_Dist,
                                           dsSF_Tax_Deferred_Dist,
                                           dsSF_Foreign_Income,
                                           dsSF_Capital_Gains_Indexed,
                                           dsSF_Capital_Gains_Disc,
                                           dsSF_Capital_Gains_Other,
                                           dsSF_Capital_Gains_Foreign_Disc,
                                           dsSF_Other_Expenses,
                                           dsSF_Interest,
                                           dsSF_Rent,
                                           dsSF_Special_Income,
                                           MemorisationLine);
                                     dsSF_Super_Fields_Edited  := True;
                                  end;


                                end;

  //                            AppendDissection( Transaction, Dissection, aClient.ClientAuditMgr );
                              if AuditIDList.Count > 0 then begin
                                Dissection.dsAudit_Record_ID := integer(AuditIDList.Items[0]);
                                AppendDissection( Transaction, Dissection, nil );
                                AuditIDList.Delete(0);
                              end else
                                TrxList32.AppendDissection( Transaction, Dissection, aClient.ClientAuditMgr );
                            end;
                        end;

                        //Calculate the GST for dissections
                        Dissection := Transaction.txFirst_Dissection;
                        while (Dissection <> nil) do begin
                          if Dissection.dsGST_Has_Been_Edited then
                            Dissection.dsGST_Amount := CalculateGSTForClass(aClient, txDate_Effective, Dissection.Local_Amount, Dissection.dsGST_Class)
                          else
                            CalculateGST(aClient, txDate_Effective, Dissection.dsAccount, Dissection.Local_Amount, Dissection.dsGST_Class, Dissection.dsGST_Amount);
                          Dissection := Dissection.dsNext;
                        end;

                      txTransfered_To_Online := False;

                      Continue;
                   end;
                end; { Scope of Memorised_Transaction_List^ }

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //      A N A L Y S I S   C O D I N G   B Y   P A Y E E
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                if ( aClient.clFields.clCountry = whNewZealand ) and ( aClient.clPayee_List.ItemCount > 0 ) then
                begin
                   // Aug 02  Added two deposit types 56,57 for Wayne Campbell so can uses as payeers
                   // Change in 5.3 so that uses the same types as codes
                   // txTypes 0, 4, 5, 8, 9 are NO LONGER checked in 5.3 >
                   // Old code -> ( txType in [ 0,4..9, 56, 57 ] ) and  ///note 0,4..9 and cheques, 56, 57 are deposits

                   DoAnalysisCoding := true;
                   case baFields.baAnalysis_Coding_Level of
                     acRestrictedLevel1 : DoAnalysisCoding := ( txType in [ 6, 7, 15, 30, 50, 56, 57 ] );
                     acRestrictedLevel2 : DoAnalysisCoding := ( txType in [ 6, 7, 56, 57 ] );
                     acDisabled         : DoAnalysisCoding := False;
                   end;

                   if DoAnalysisCoding then
                   begin
                     Analysis := StStrS.TrimSpacesS( txAnalysis );
                     if GenUtils.IsNumeric( Analysis ) then
                     begin
                        ZTrim( Analysis );
                        //remove leading zeros
                        While (Analysis <> '') and (Analysis[1] = '0') do
                          System.Delete(Analysis, 1, 1);
                        No := StrToIntSafe( Analysis );
                        If ( No>0 ) then
                        Begin
                           Payee := clPayee_List.Find_Payee_Number( No );
                           If Assigned( Payee ) then
                           Begin
                              if not Payee.IsDissected then
                              begin
                                 //Single line entry, just modify existing transaction
                                 txCoded_By     := cbAutoPayee;
                                 txPayee_Number := Payee.pdNumber;

                                 PayeeLine := Payee.FirstLine;
                                 if Assigned( PayeeLine) then
                                   begin
                                     txAccount      := PayeeLine.plAccount;
                                     if PayeeLine.plGL_Narration <> '' then
                                       txGL_Narration := PayeeLine.plGL_Narration;
                                     //calculate GST.  If has been edited then use class, otherwise use default
                                     if ( PayeeLine.plGST_Has_Been_Edited) then begin
                                        txGST_Class    := PayeeLine.plGST_Class;
                                        txGST_Amount   := CalculateGSTForClass( aClient, txDate_Effective, Local_Amount, txGST_Class);
                                        txGST_Has_Been_Edited := true;
                                     end
                                     else begin
                                        CalculateGST( aClient, txDate_Effective, txAccount, Local_Amount, txGST_Class, txGST_Amount);
                                        txGST_Has_Been_Edited := false;
                                     end;
                                   end;
                                 Continue;
                              end;

                              Amount := Transaction.txAmount;

                              //Entry needs to be dissected
                              PayeePercentageSplit( Amount, Payee, PayeeSplit, PayeeSplitPct );
                              txCoded_By     := cbAutoPayee;
                              txPayee_Number := Payee.pdNumber;
                              txAccount      := DISSECT_DESC;
                              //txGL_Narration := Payee.pdName;

                              ClearGSTFields( Transaction);
                              ClearSuperFundFields( Transaction);

                              for i := Payee.pdLines.First to Payee.pdLines.Last do
                              Begin
                                if PayeeSplit[i] <> 0 then
                                begin
                                  PayeeLine := Payee.pdLines.PayeeLine_At(i);

                                  New( Dissection );
                                  FillChar( Dissection^, Dissection_Rec_Size, 0 );
                                  Dissection.dsBank_Account := Transaction.txBank_Account;
                                  With Dissection^ do
                                  begin
                                     dsRecord_Type  := tkBegin_Dissection;
                                     dsEOR          := tkEnd_Dissection;
                                     dsTransaction  := Transaction;
                                     dsAccount      := PayeeLine.plAccount;
                                     dsAmount       := PayeeSplit[i];
                                     dsPercent_Amount := PayeeSplitPct[i];
                                     dsAmount_type_Is_Percent := PayeesplitPct[i] <> 0;
                                     if PayeeLine.plGL_Narration <> '' then
                                       dsGL_Narration := PayeeLine.plGL_Narration
                                     else
                                       dsGL_Narration := Transaction.txGL_Narration;

                                     dsGST_Has_Been_Edited := false;
                                     if PayeeLine.plGST_Has_Been_Edited then begin
                                        dsGST_Class := PayeeLine.plGST_Class;
                                        dsGST_Has_Been_Edited := true;
                                     end;

                                  end;
    //                              AppendDissection( Transaction, Dissection, aClient.ClientAuditMgr );
                                if AuditIDList.Count > 0 then begin
                                  Dissection.dsAudit_Record_ID := integer(AuditIDList.Items[0]);
                                  AppendDissection( Transaction, Dissection, nil );
                                  AuditIDList.Delete(0);
                                end else
                                  TrxList32.AppendDissection( Transaction, Dissection, aClient.ClientAuditMgr );
                                end;
                              End;

                              //Calculate GST for dissection
                              Dissection := Transaction.txFirst_Dissection;
                              while (Dissection <> nil) do begin
                                if Dissection.dsGST_Has_Been_Edited then
                                  Dissection.dsGST_Amount := CalculateGSTForClass(aClient, txDate_Effective, Dissection.Local_Amount, Dissection.dsGST_Class)
                                else
                                  CalculateGST(aClient, txDate_Effective, Dissection.dsAccount, Dissection.Local_Amount, Dissection.dsGST_Class, Dissection.dsGST_Amount);
                                Dissection := Dissection.dsNext;
                              end;

                              txTransfered_To_Online := False;
                           end; //matching payee
                        end;
                     end; //if DoAnalysisCoding
                   end;
                end;
              finally
                AuditIDList.Free;
              end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //      A N A L Y S I S   C O D I N G   B Y   A C C O U N T
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

              { If there isn't a chart, then we can't validate the analysis code }
              If ( clChart.ItemCount = 0 ) then Continue;

              If ( aClient.clFields.clCountry = whNewZealand ) then
              Begin
                 DoAnalysisCoding := true;
                 case baFields.baAnalysis_Coding_Level of
                   acRestrictedLevel1 : DoAnalysisCoding := ( txType in [ 6, 7, 15, 30, 50, 56, 57 ] );
                   acRestrictedLevel2 : DoAnalysisCoding := ( txType in [ 6, 7, 56, 57 ] );
                   acDisabled         : DoAnalysisCoding := False;
                 end;

                 If DoAnalysisCoding then
                 begin
                   Analysis := StStrS.TrimSpacesS( txAnalysis );
                   if GenUtils.IsNumeric( Analysis ) then
                   begin
                      While ( Length( Analysis )<12 ) do Analysis:='0'+Analysis; (* Fix for old BMS data *)
                      NoDigits := 0;
                      For i:=1 to Length( Mask ) do If ( Mask[i]='#' ) then Inc( NoDigits );

                      TempStr := '';
                      If NoDigits>0 then For i:=0 to NoDigits-1 do
                      Begin
                         p:=Length( Analysis )-i;
                         If ( p>0 ) and ( p<=Length( Analysis ) ) then TempStr:=Analysis[p]+TempStr;
                      end;

                      ZTrim( TempStr );

                      p :=0 ; TestCode := '';

                      For i:=1 to Length( Mask ) do
                      If ( Mask[i]='#' ) then
                      Begin
                         Inc( p );
                         If p<=Length( TempStr ) then TestCode := TestCode + TempStr[ p ];
                      end
                      else
                         TestCode := TestCode + Mask[i];

                      //remove leading non-numerics
                      While ( TestCode<>'' ) and ( not ( TestCode[1] in ['0'..'9'] ) ) do
                         System.Delete( TestCode,1,1 );
                      //remove trailing non-numerics
                      While ( TestCode<>'' ) and ( not ( TestCode[Length( TestCode )] in ['0'..'9'] ) ) do
                         TestCode[0]:=Pred( TestCode[0] );
                      //remove leading zero's
                      While ( TestCode<>'' ) and ( not ( TestCode[1] in ['1'..'9'] ) ) do
                         System.Delete( TestCode,1,1 );

                      if TestCode <> '' then begin
                         //Now have a test code to start using
                         //try to find a match, if no match found add leading zeros
                         //to see if a match found now ie.  Try to find '010'
                         AnalysisMatchFound := false;
                         while (not AnalysisMatchFound) and ( Length( TestCode) <= Length( Mask)) do begin
                             AnalysisMatchFound := clChart.CanCodeTo ( TestCode );
                             if not AnalysisMatchFound then // Try sub-accounts
                             begin
                               AnalysisMatchFound := clChart.CanCodeTo_NumericSearch(TestCode, SubCode);
                               if AnalysisMatchFound then
                                TestCode := SubCode;
                             end;
                             if not AnalysisMatchFound then begin
                                TestCode := '0' + TestCode;
                             end;
                         end;

                         if AnalysisMatchFound then begin
                            //match found
                            txAccount      := TestCode;
                            txCoded_By     := cbAnalysis;
                            CalculateGST( aClient, txDate_Effective, txAccount, Local_Amount, txGST_Class, txGST_Amount );
                            txGST_Has_Been_Edited := false;
                            Continue;
                         end;

                         txTransfered_To_Online := False;
                      end;
                   end;
                 end;
              end; { of Analysis Code Processing }
           end; { Scope of Transaction^ }
        end; { of EntryNo }

  //      AppTime.StopTime;
  //      ShowMessage( AppTime.GetElapsedStr);

     end; { Scope of Client and BankAccount }
   finally
     if Assigned(frmMain) then
       if not MaintainMemScanStatus then
         frmMain.MemScanIsBusy := False;
   end;
end; { of AUTOCODE }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function FindMemorisation( const aBankAccount : TBank_Account;
                           const aTransaction : pTransaction_Rec;
                           var   aMemorisedTransaction : TMemorisation ) : Boolean;
// Pass a BankAccount and Transaction.
// Returns true if Memorisation found. Pointer to Memorised transaction in var
// Does not check Master Memorisations
var
   MX  : TMemorisation;
begin
   Result := False;
   with aBankAccount do begin
      with baMemorisations_List do begin
         UpdateLinkedLists;
         MX := MXFirstByEntryType[ aTransaction.txType ];
         aMemorisedTransaction := NIL;
         while ( MX<>NIL ) and ( Result=False ) do begin
            If CanMemorise ( aTransaction, MX ) then begin
               Result := True;
               aMemorisedTransaction := MX;
            end;
            MX := TMemorisation( MX.mdFields.mdNext_Memorisation);
         end;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Initialization
   DebugMe := LogUtil.DebugUnit( 'AUTOCODE' );
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
END.
