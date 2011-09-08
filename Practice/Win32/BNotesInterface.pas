unit BNotesInterface;
//------------------------------------------------------------------------------
{
   Title:       ECoding Interface Unit

   Description: Import/Export interface unit for the ECoding interface

   Remarks:

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface
uses
   clObj32, sysobj32, classes, reportDefs, ecDefs, BKDefs, baObj32,
   ecObj, PayeeObj;

   function VerifyBNotesFile( ECFile : TEcClient; aClient : TClientObj; filename : string) : boolean;

   procedure ProcessBNotesFile( ECFile : TECClient; aClient : TClientObj; var ImportedCount, NewCount, RejectedCount : integer);

   function GenerateBNotesFile( const aClient : TClientObj; DestFilename : string;
                                 const DateFrom : Integer; const DateTo : integer;
                                 var EntriesCount : integer;
                                 const IsScheduledReport : boolean;
                                 const AdminSystem : TSystemObj;
                                 const ScheduledReportPrintAll : boolean;
                                 const SchdSummaryList : TList;
                                 const EncodedLogo : string;
                                 const AccountList: TList;
                                 const ReportStartDate: Integer = 0) : boolean;

//******************************************************************************
implementation
uses
   Autocode32,
   bkConst,
   bkDateUtils,
   bkdsio,
   bktxio,
   bkUtil32,
   Dialogs,
   ECBankAccountObj,
   ecchio,
   ecdsio,
   ecplio,
   ECodingImportResultsFrm,
   ecpyio,
   ECTransactionListObj,
   ectxio,
   Software,
   ErrorMoreFrm,
   GenUtils,
   glConst,
   GlobalDirectories,
   GSTCalc32,
   logUtil,
   MoneyDef,
   Scheduled,
   stDate,
   syDefs,
   SysUtils,
   TransactionUtils,
   trxList32,
   ECollect, ecBankAccountsListObj, BaList32,
   ecPayeeObj,
   ecJobObj,
   pyList32,
   SuperfieldsUtils,
   ECodingUtils, ClientUtils, SchedRepUtils, Globals,
   ISO_4217,
   ForexHelpers;

const
   UnitName = 'BNotesInterface';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GenerateBNotesFile( const aClient : TClientObj; DestFilename : string;
                              const DateFrom : Integer; const DateTo : integer;
                              var EntriesCount : integer;
                              const IsScheduledReport : boolean;
                              const AdminSystem : TSystemObj;
                              const ScheduledReportPrintAll : boolean;
                              const SchdSummaryList : TList;
                              const EncodedLogo : string;
                              const AccountList: TList;
                              const ReportStartDate: Integer = 0) : boolean;

   function IncludeThisAccount( BA : TBank_Account) : boolean;
   var
    CompareBA: TBank_Account;
    i: Integer;
   begin
     Result := False;
     if not ( BA.baFields.baAccount_Type in [ btBank]) then
       exit;
     if IsScheduledReport then
      Result := True
     else
       for i := 0 to Pred(AccountList.Count) do
       begin
         CompareBA := aClient.clBank_Account_List.Bank_Account_At(Integer(AccountList[i]));
         if (CompareBA.baFields.baBank_Account_Number = BA.baFields.baBank_Account_Number) then
         begin
           Result := True;
           Break;
         end;
       end;
   end;

var
   ECFile   : TEcClient;
   RateNo   : integer;
   ClassNo  : integer;
   AcNo     : integer;
   BA       : TBank_Account;
   NewEcBA  : TECBank_Account;
   T        : BKDEFS.pTransaction_Rec;
   D        : BKDEFS.pDissection_Rec;
   ECT      : ECDEFS.pTransaction_Rec;
   ECD      : ECDEFS.pDissection_Rec;
   TNo      : integer;
   ChNo     : integer;
   Account  : BKDEFS.pAccount_Rec;
   ECAcct   : ECDEFS.pAccount_Rec;
   PNo      : integer;

   aPayee   : PayeeObj.TPayee;
   aECPayee : ecPayeeObj.TECPayee;
   NewPayeeLine : ecDefs.pPayee_Line_Rec;
   aPayeeLine : bkdefs.pPayee_Line_Rec;

   PLineNo  : integer;

   AdminBA  : pSystem_Bank_Account_Rec;

   NewSummaryRec   : pSchdRepSummaryRec;
   FirstSummaryRec : pSchdRepSummaryRec;
   AccountsFound   : integer;
   AccountsExported : integer;
   FirstEntryDate  : integer;
   LastEntryDate   : integer;
   FirstScheduledDate: Integer;

   SkipTransaction : boolean;
   i, LastDate     : integer;

   aName,
   aPhone,
   aEmail,
   aWeb            : string;
   pCF : pClient_File_Rec;
  jNo: Integer;
  aJob: pJob_Heading_Rec;
  aECJob: TECJob;
begin
   EntriesCount := 0;

   ECFile := TEcClient.Create;
   try
      //copy file details
      ecFile.ecFields.ecCode               := aClient.clFields.clCode;
      ecFile.ecFields.ecName               := aClient.clFields.clName;
      ecFile.ecFields.ecPractice_Name      := aClient.clFields.clPractice_Name;
      ecFile.ecFields.ecPractice_Code      := aClient.ClFields.CLPractice_Code;

      GetPracticeContactDetails( aClient, aName, aPhone, aEmail, aWeb);

      //update contact details
      ecFile.ecFields.ecContact_Person        := aName;
      ecFile.ecFields.ecContact_EMail_Address := aEmail;
      ecFile.ecFields.ecContact_Phone_Number  := aPhone;
      ecFile.ecFields.ecPractice_Web_Site     := aWeb;
      ecFile.ecFields.ecPractice_Logo         := EncodedLogo;

      //update fields
      ecFile.ecFields.ecCountry            := aClient.clFields.clCountry;
      ecFile.ecFields.ecAccount_Code_Mask  := aClient.clFields.clAccount_Code_Mask;
      ecFile.ecFields.ecMagic_Number       := aClient.clFields.clMagic_Number;
      ecFile.ecFields.ecFile_Password      := aClient.clFields.clECoding_Default_Password;
      ecFile.ecFields.ecDate_Range_From    := DateFrom;
      ecFile.ecFields.ecDate_Range_To      := DateTo;

      ecFile.ecFields.ecRestrict_UPIs      := aClient.clFields.clECoding_Dont_Allow_UPIs;
      ecFile.ecFields.ecHide_Account_Col   := aClient.clFields.clECoding_Dont_Show_Account;
      ecFile.ecFields.ecHide_Quantity_Col  := aClient.clFields.clECoding_Dont_Show_Quantity;
      ecFile.ecFields.ecHide_Payee_Col     := aClient.clFields.clECoding_Dont_Show_Payees;
      ecFile.ecFields.ecHide_GST_Col       := aClient.clFields.clECoding_Dont_Show_GST;
      ecFile.ecFields.ecHide_Tax_Invoice_Col :=aClient.clFields.clECoding_Dont_Show_TaxInvoice;
      ecFile.ecFields.ecHide_Job_Col       := aClient.clExtra.ceECoding_Dont_Send_Jobs;
      if aClient.clFields.clECoding_Send_Superfund
      and Software.CanUseSuperFundFields(aClient.clFields.clCountry,aClient.clFields.clAccounting_System_Used) then
         ecFile.ecFields.ecSuper_Fund_System := aClient.clFields.clAccounting_System_Used
      else
         ecFile.ecFields.ecSuper_Fund_System := 0;
      ecFile.ecFields.ecFile_Number        := aClient.clFields.clECoding_Last_File_No + 1;
      ecFile.ecFields.ecFile_Version       := ECDEFS.EC_FILE_VERSION;

      ecFile.ecFields.ecShow_Notes_On_Open := False;
      ecFile.ecFields.ecNotes              := '';

      //copy gst rates and apply from dates
      for RateNo := 1 to glConst.Max_GST_Class_Rates do begin
          ecFile.ecFields.ecGST_Applies_From[ RateNo] := aClient.clFields.clGST_Applies_From[ RateNo];
          for ClassNo := 1 to glConst.Max_GST_Class do begin
             ecFile.ecFields.ecGST_Rates[ ClassNo, RateNo] := aClient.clFields.clGST_Rates[ ClassNo, RateNo];
          end;
      end;

      //copy Tax rates and apply from dates
      for RateNo := low(ecFile.ecFields.ecTAX_Applies_From) to High(ecFile.ecFields.ecTAX_Applies_From) do
         for ClassNo := low(ecFile.ecFields.ecTAX_Applies_From[RateNo]) to High(ecFile.ecFields.ecTAX_Applies_From[RateNo]) do begin
            ecFile.ecFields.ecTAX_Applies_From[RateNo,ClassNo] :=  aClient.clExtra.ceTAX_Applies_From[RateNo,ClassNo];
            ecFile.ecFields.ecTAX_Rates [RateNo,ClassNo] :=  aClient.clExtra.ceTAX_Rates[RateNo,ClassNo];
         end;

      AccountsFound := 0;
      AccountsExported := 0;
      FirstScheduledDate := MaxInt;
      FirstSummaryRec  := nil;

      //copy bank accounts
      for acNo := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
         BA := aClient.clBank_Account_List.Bank_Account_At( acNo);

         //autocode all entries before exporting so that code/uncode set correctly
         AutoCode32.AutoCodeEntries( aClient, ba, AllEntries, DateFrom, DateTo);

         FirstEntryDate := MaxInt;
         LastEntryDate  := 0;

         if IncludeThisAccount( BA) then begin
            //schedule reports specific code
            if IsScheduledReport then begin
               //if scheduled reports then determine if acccount can be found in admin system
               //accounts found depends on no of admin accounts found
               BA.baFields.baTemp_Include_In_Scheduled_Coding_Report := false;
               BA.baFields.baTemp_New_Date_Last_Trx_Printed := 0;  //this value will be written in admin sytem
                                                                   //see Scheduled.ProcessClient()
               //access the admin system and read date_of_last_transaction_printed.
               AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( BA.baFields.baBank_Account_Number);
               if Assigned( AdminBA) then begin
                  Inc( AccountsFound);
                  // Dont skip until we've included this account in the total
                  if Pos(ba.baFields.baBank_Account_Number + ',', aClient.clFields.clExclude_From_Scheduled_Reports) > 0 then
                    Continue;
                  if ScheduledReportPrintAll then
                     //set date so that all transactions will be included
                     BA.baFields.baTemp_Date_Of_Last_Trx_Printed := 0
                  else
                  begin
                    LastDate := ClientUtils.GetLastPrintedDate(aClient.clFields.clCode, AdminBA.sbLRN);
                    if LastDate = 0 then
                      BA.baFields.baTemp_Date_Of_Last_Trx_Printed := IncDate(ReportStartDate, -1, 0, 0)
                    else if GetMonthsBetween(LastDate, ReportStartDate) > 1 then
                      BA.baFields.baTemp_Date_Of_Last_Trx_Printed := GetFirstDayOfMonth(IncDate(ReportStartDate, 0, -1, 0))
                    else
                      BA.baFields.baTemp_Date_Of_Last_Trx_Printed := LastDate;
                  end;
               end
               else begin
                  //this account does not exist in the admin sytem, set date so that
                  //no valid entries will ever be found
                  BA.baFields.baTemp_Date_Of_Last_Trx_Printed := MaxInt;
               end;
            end;

            NewECBA := TECBank_Account.Create;
            NewECBA.baFields.baBank_Account_Number    := BA.baFields.baBank_Account_Number;
            NewECBA.baFields.baBank_Account_Name      := BA.baFields.baBank_Account_Name;
            NewECBA.baFields.baCurrency_Code          := BA.baFields.baCurrency_Code;
            NewECBA.baFields.baCurrency_Symbol        := Get_ISO_4217_Symbol(BA.baFields.baCurrency_Code);

            //copy transactions
            for TNo := 0 to Pred( BA.baTransaction_List.ItemCount) do begin
               T := BA.baTransaction_List.Transaction_At( TNo);
               SkipTransaction := false;

               //check is in date range
               if (( T.txDate_Effective < DateFrom) or ( T.txDate_Effective > DateTo))
                  or
                  (( aClient.clFields.clECoding_Entry_Selection = esUncodedOnly) and
                   ( T.txAccount <> '')) then
               begin
                  SkipTransaction := true;
               end;

               //check date of last transaction sent if scheduled reports run
               if (not SkipTransaction) //Skipping already
               and IsScheduledReport then begin
                  if (T.txDate_Effective > ba.baFields.baTemp_Date_Of_Last_Trx_Printed) // In the Range
                  and (not IsUPCFromPreviousMonth(T.txDate_Effective, T.txUPI_State, ReportStartDate))
                  or (ScheduledReportPrintAll) then begin
                     if T.txDate_Effective < FirstEntryDate then
                        FirstEntryDate := T.txDate_Effective;

                     if T.txDate_Effective > LastEntryDate then
                        LastEntryDate  := T.txDate_Effective;

                     if ba.baFields.baTemp_Date_Of_Last_Trx_Printed > 0 then
                        if ba.baFields.baTemp_Date_Of_Last_Trx_Printed < FirstScheduledDate then
                           FirstScheduledDate := ba.baFields.baTemp_Date_Of_Last_Trx_Printed;

                     ba.baFields.baTemp_New_Date_Last_Trx_Printed := T.txDate_Effective;
                     ba.baFields.baTemp_Include_In_Scheduled_Coding_Report := true;

                  end else
                      SkipTransaction := true
               end;

               if not SkipTransaction then begin
                  //set ecoding ID, this will be used to synchronise the transaction
                  if T.txECoding_Transaction_UID = 0 then begin
                     Inc( BA.baFields.baLast_ECoding_Transaction_UID);
                     T.txECoding_Transaction_UID := BA.baFields.baLast_ECoding_Transaction_UID;
                  end;

                  //copy transaction details
                  ECT := ectxio.New_Transaction_Rec;
                  ECT.txType                  := T.txType;
                  ECT.txDate_Presented        := T.txDate_Presented;
                  ECT.txDate_Effective        := T.txDate_Effective;
                  ECT.txAmount                := T.txAmount;
                  ECT.txGST_Class             := T.txGST_Class;
                  //BNotes doesn't handle GST/VAT for multi-currency accounts TFS
                  //so extract it in the statement currency
                  if BA.IsAForexAccount then begin
                    if T.txGST_Has_Been_Edited then
                      //If manually edited then use the exchange rate to calculate VAT in forex currency
                      ECT.txGST_Amount := (T.txGST_Amount * T.Default_Forex_Rate)
                    else
                      //If NOT manually edited then use the tax rate to calculate VAT in forex currency
                      ECT.txGST_Amount := GSTCALC32.CalculateGSTForClass(aClient, T.txDate_Effective, T.txAmount, T.txGST_Class);
                  end else
                    ECT.txGST_Amount            := T.txGST_Amount;
                  ECT.txHas_Been_Edited       := T.txHas_Been_Edited;
                  ECT.txQuantity              := T.txQuantity;
                  ECT.txCheque_Number         := T.txCheque_Number;
                  ECT.txReference             := T.txReference;
                  ECT.txAnalysis              := T.txAnalysis;
                  ECT.txOrigBB                := T.txOrigBB;
                  // The other party and particulars fields are no longer used in BNotes
                  // ECT.txOther_Party           := T.txOther_Party;
                  // ECT.txParticulars           := T.txParticulars;
                  ECT.txNarration             := T.txGL_Narration;
                  //old narration needed in case they overwrite narration with Payee and want to remove payee.
                  ECT.txOld_Narration         := T.txGL_Narration;
                  ECT.txAccount               := T.txAccount;
                  ECT.txCoded_By              := T.txCoded_By;
                  ECT.txPayee_Number          := T.txPayee_Number;
                  ECT.txJob_Code              := T.txJob_Code;
                  ECT.txLocked                := T.txLocked;
                  ECT.txGST_Has_Been_Edited   := T.txGST_Has_Been_Edited;
                  ECT.txUPI_State             := T.txUPI_State;
                  ECT.txNotes                 := T.txNotes;
                  ECT.txECoding_ID            := T.txECoding_Transaction_UID;
                  ECT.txTax_Invoice_Available := T.txTax_Invoice_Available;
                  if ecFile.ecFields.ecSuper_Fund_System <> 0 then begin
                     ECT.txSF_Franked            := T.txSF_Franked;
                     ECT.txSF_UnFranked          := T.txSF_UnFranked;
                     ECT.txSF_Franking_Credit    := T.txSF_Imputed_Credit;
                     ECT.txSF_Edited             := (ECT.txSF_Franked <> 0)
                                                 or (ECT.txSF_UnFranked <> 0)
                                                 or (ECT.txSF_Franking_Credit <> 0);
                  end;

                  //set code lock state
                  ECT.txCode_Locked := (( T.txAccount <> '') or
                                       ( T.txFirst_Dissection <> nil));
                  //copy dissections
                  if T.txFirst_Dissection <> nil then begin
                     D := T.txFirst_Dissection;
                     while D <> nil do begin
                        ECD := ecdsio.New_Dissection_Rec;
                        ECD.dsAccount         := D.dsAccount;
                        ECD.dsAmount          := D.dsAmount;
                        ECD.dsGST_Class       := D.dsGST_Class;
                        //BNotes doesn't handle GST/VAT for multi-currency accounts TFS
                        //so extract it in the statement currency
                        if BA.IsAForexAccount then begin
                          if D.dsGST_Has_Been_Edited then
                            //If manually edited then use the exchange rate to calculate VAT in forex currency
                            ECD.dsGST_Amount := (D.dsGST_Amount * T.Default_Forex_Rate)
                          else
                            //If NOT manually edited then use the tax rate to calculate VAT in forex currency
                            ECD.dsGST_Amount := GSTCALC32.CalculateGSTForClass(aClient, T.txDate_Effective, D.dsAmount, D.dsGST_Class);
                        end else
                          ECD.dsGST_Amount      := D.dsGST_Amount;
                        ECD.dsQuantity        := D.dsQuantity;
                        ECD.dsNarration       := D.dsGL_Narration;
                        ECD.dsTax_Invoice      := D.dsTax_Invoice;
                        ECD.dsHas_Been_Edited := D.dsHas_Been_Edited;
                        ECD.dsGST_Has_Been_Edited := D.dsGST_Has_Been_Edited;
                        ECD.dsPayee_Number    := D.dsPayee_Number;
                        ECD.dsJob_Code        := D.dsJob_Code;
                        ECD.dsNotes           := D.dsNotes;
                        if ecFile.ecFields.ecSuper_Fund_System <> 0 then begin
                           ECD.dsSF_Franked         := D.dsSF_Franked;
                           ECD.dsSF_UnFranked       := D.dsSF_UnFranked;
                           ECD.dsSF_Franking_Credit := D.dsSF_Imputed_Credit;
                           ECD.dsSF_Edited          := (ECD.dsSF_Franked <> 0)
                                                    or (ECD.dsSF_UnFranked <> 0)
                                                    or (ECD.dsSF_Franking_Credit <> 0);
                        end;

                        ECTransactionListObj.AppendDissection( ECT, ECD);
                        D := D.dsNext;
                     end;
                  end;
                  NewECBA.baTransaction_List.Insert_Transaction_Rec( ECT);
                  Inc( EntriesCount);
               end;
            end;
            //only add bank account if has some transactions
            if NewECBA.baTransaction_List.ItemCount = 0 then
               NewECBA.Free
            else begin
               ecFile.ecBankAccounts.Insert( NewECBA);

               //now handle scheduled reports summary lines
               if IsScheduledReport and ( SchdSummaryList <> nil) then begin
                  Inc( AccountsExported);

                  GetMem( NewSummaryRec, Sizeof( TSchdRepSummaryRec));
                  with NewSummaryRec^ do begin
                     ClientCode         := aClient.clFields.clCode;
                     AccountNo          := BA.baFields.baBank_Account_Number;
                     PrintedFrom        := FirstEntryDate;
                     PrintedTo          := LastEntryDate;
                     AcctsPrinted       := 0;  //AccountedExported;
                     AcctsFound         := 0;
                     SendBy             := rdEcoding;
                     UserResponsible    := 0;
                     Completed          := True;
                     TxLastMonth        := (aClient.clFields.clReporting_Period = roSendEveryMonth)
                                        and (FirstEntryDate < ReportStartDate)
                                        and (not aClient.clFields.clCheckOut_Scheduled_Reports)
                                        and (not aClient.clExtra.ceOnline_Scheduled_Reports);
                  end;
                  SchdSummaryList.Add( NewSummaryRec);
                  //store a pointer to the first record so that we can update it with the
                  //accounts printed and accounts found values.
                  if FirstSummaryRec = nil then begin
                     FirstSummaryRec := NewSummaryRec;
                  end;
               end;
            end;
         end;
      end;// Accounts

      if (FirstScheduledDate < Maxint) // been set..
      and (FirstScheduledDate > ecFile.ecFields.ecDate_Range_From) then
        ecFile.ecFields.ecDate_Range_From := FirstScheduledDate;

      if not aClient.clFields.clECoding_Dont_Send_Chart then begin
         //copy chart list
         for chNo := 0 to Pred( aClient.clChart.ItemCount) do begin
            Account := aClient.clChart.Account_At( chNo);
            ECAcct  := ecchio.New_Account_Rec;

            ECAcct.chAccount_Code            := Account.chAccount_Code;
            ECAcct.chAccount_Description     := Account.chAccount_Description;
            ECAcct.chGST_Class               := Account.chGST_Class;
            ECAcct.chPosting_Allowed         := Account.chPosting_Allowed;
            ECAcct.chHide_In_Basic_Chart     := Account.chHide_In_Basic_Chart;

            ECFile.ecChart.Insert( ECAcct);
         end;
      end;

      //copy payees
      if not aClient.clFields.clECoding_Dont_Send_Payees then
        begin
           for pNo := aClient.clPayee_List.First to aClient.clPayee_List.Last do
             begin
               aPayee := aClient.clPayee_List.Payee_At( pNo);
               aECPayee := ecPayeeObj.TEcPayee.Create;
               aECPayee.pdFields.pdNumber := aPayee.pdNumber;
               aECPayee.pdFields.pdName   := aPayee.pdName;

               for pLineNo := aPayee.pdLines.First to aPayee.pdLines.Last do
                 begin
                   //copy lines
                   NewPayeeLine := ecPLIO.New_Payee_Line_Rec;
                   aPayeeLine := aPayee.pdLines.PayeeLine_At( pLineNo);

                   NewPayeeLine.plAccount  := aPayeeLine.plAccount;
                   NewPayeeLine.plPercentage := aPayeeLine.plPercentage;
                   NewPayeeLine.plGST_Class := aPayeeLine.plGST_Class;
                   NewPayeeLine.plGST_Has_Been_Edited := aPayeeLine.plGST_Has_Been_Edited;
                   NewPayeeLine.plGL_Narration := aPayeeLine.plGL_Narration;
                   NewPayeeLine.plLine_Type := aPayeeLine.plLine_Type;

                   aECPayee.pdLines.Insert( NewPayeeLine);
                 end;

               ECFile.ecPayees.Insert( aECPayee);
             end;
        end;

      //copy Jobs
      if not aClient.clExtra.ceECoding_Dont_Send_Jobs then
      begin
        for jNo := aClient.clJobs.First to aClient.clJobs.Last do
        begin
          aJob := aClient.clJobs.Job_At(jNo);
          aECJob := ecJobObj.TECJob.Create;
          aECJob.jhFields.jhLRN := aJob.jhLRN;
          aECJob.jhFields.jhCode := aJob.jhCode;
          //If heading is blank, use Code. BugzID:11373
          if aJob.jhHeading <> '' then
            aECJob.jhFields.jhHeading := aJob.jhHeading
          else
            aECJob.jhFields.jhHeading := aJob.jhCode;
          aECJob.jhFields.jhIsCompleted := aJob.jhDate_Completed <> 0;
          ECFile.ecJobs.Insert(aECJob);
        end;

      end;

      if ecFile.ecBankAccounts.ItemCount > 0 then begin
        //now save object
        ecFile.SaveToFile( DestFilename);
        if IsScheduledReport then begin
           FirstSummaryRec^.AcctsPrinted := AccountsExported;
           FirstSummaryRec^.AcctsFound   := AccountsFound;
           FirstSummaryRec^.SendBy       := rdECoding;
        end;
        result := true;
      end
      else begin
        //dont save a file with no bank accounts
        result := false;
      end;
   finally
      ECFile.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RejectTransaction( ECFile : TECClient; ECT : ECDEFS.pTransaction_Rec; Reason : string; var RejectedLines : TStringList);
//format the reason and adds it to the list of rejected transactions
var
  NewLine : string;
  ECPayee : EcPayeeObj.TEcPayee;
begin
  NewLine := '';

  NewLine := NewLine + 'Date = ' + bkDate2Str( ECT^.txDate_Effective);
  NewLine := NewLine + '  Code = ' + ECT^.txAccount;
  NewLine := NewLine + '  Amt = ' + Money2Str( ECT^.txAmount);
  NewLine := NewLine + '  GST = ' + Money2Str( ECT^.txGST_Amount);

  if ECT^.txTax_Invoice_Available then
     NewLine := NewLine + '  Tax Inv = Y';

  if ECT^.txPayee_Number <> 0 then
  begin
     ECPayee := ECFile.ecPayees.Find_Payee_Number( ECT^.txPayee_Number);
     if assigned( ECPayee) then
        NewLine := NewLine + '  Payee = ' + inttostr( ecPayee.pdNumber) +
                             ' ' + ecPayee.pdName;
  end;

  if ECT^.txQuantity <> 0 then
     NewLine := NewLine + '  Qty = ' + FormatFloat('#,##0.####', ECT^.txQuantity/10000);

  if Trim( ECT^.txNotes) <> '' then
     NewLine := NewLine + '  Notes = ' + GenUtils.StripReturnCharsFromString( ECT^.txNotes, ' | ');

  NewLine := NewLine + '  [' + Reason + ']';

  RejectedLines.Add( NewLine);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ValidateTransactionForImport( ECT : ECDefs.pTransaction_Rec;
                                      T   : BKDefs.pTransaction_Rec;
                                      var aMsg : string) : boolean;
begin
  result := false;
  aMsg   := '';

  //check match found
  if not Assigned( T) then
  begin
     aMsg := 'Match not found';
     exit;
  end;

  //check the presentation dates match
  if not (( ECT.txDate_Presented = 0 ) or
          ( ECT.txDate_Presented = T.txDate_Presented)) then
  begin
     //rejected transaction found, pres dates different
     aMsg := 'Pres Date Mismatch  expected ' + bkDate2Str( T.txDate_Presented);
     exit;
  end;

  //check for finalised or transferred in bk5
  if ( T.txLocked) then
  begin
     aMsg := 'Finalised';
     exit;
  end;
  if ( T.txDate_Transferred <> 0 ) then
  begin
     aMsg := 'Transferred';
     exit;
  end;

  //everything ok
  result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ValidateNewTransaction( ECFile : TEcClient;
                                 ECT : ecDefs.pTransaction_Rec;
                                 aClient  : TClientObj;
                                 SelectedBA : TBank_Account;
                                 var aMsg : string;
                                 var BKT : bkDefs.pTransaction_Rec) : boolean;
//validate the current transaction to see if it can be added to the client
//file.  May also return a matching bk5 transaction if a upc if found with the
//same cheque no
var
  BOM,
  EOM       : integer;
  d,m,y     : integer;
  B         : integer;
  Ba        : TBank_Account;
  T         : integer;
  pT        : bkdefs.pTransaction_Rec;
begin
  result := false;
  BKT    := nil;
  aMsg   := '';

  if not ( ECT^.txUPI_State in [ upUPC, upUPD, upUPW]) then
  begin
    aMsg := 'No Sync ID';
    exit;
  end
  else
  begin
    //new transaction is an unpresented item, make sure it will not be
    //added to a finalised period, test against the month that the transaction
    //is part of
    StDateToDMY( ECT.txDate_Effective, d, m, y);
    BOM := ECfile.ecFields.ecDate_Range_From; //DMYtoSTDate( 1, m, y, BKDATEEPOCH);
    EOM := ECfile.ecFields.ecDate_Range_To; //DMYtoSTDate( DaysInMonth( m, y, BKDATEEPOCH), m, y, BKDATEEPOCH);

    //need to check each bank account is case this is the only transaction
    //to be added and all other transactions in this period are locked
    for B := 0 to aClient.clBank_Account_List.Last do
    begin
      ba := aClient.clBank_Account_List.Bank_Account_At(B);
      for t := 0 to ba.baTransaction_List.Last do
      begin
        pT := ba.baTransaction_List.Transaction_At(t);
        if ( pT^.txDate_Effective >= BOM) and ( pT^.txDate_Effective <= EOM) then
        begin
          //make sure not locked
          if pT.txLocked then
          begin
            aMsg := 'Adding to finalised period';
            exit;
          end;

          //make sure this accounts has not been transferred already
          if ( ba = SelectedBa) and ( pT.txDate_Transferred <> 0) then
          begin
            aMsg := 'Adding to transferred period';
            Exit;
          end;
        end;
      end;
    end;

    //if the item is a upc make sure that there are no other upc's with the
    //same cheque number. if a match is found validate that transaction
    Result := true;

    if ECT^.txUPI_State = upUPC then
    begin
      //try to find a upc with this cheque number so that we avoid duplication
      //upc must not be transferred or finalised
      for t := 0 to SelectedBa.baTransaction_List.Last do
      begin
        pT := SelectedBa.baTransaction_List.Transaction_At(t);

        if ( pT.txCheque_Number = ECT.txCheque_Number) and
           ( pT.txUPI_State = upUPC) then
        begin
          BKT    := pT;
          if ValidateTransactionForImport( ECT, BKT, aMsg) then
            //found a valid matching transaction
            Exit
          else
            //cannot import into the matched transaction, keep looking
            BKT := nil;
        end;
      end;
    end;
  end;

  Result := True;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function VerifyBNotesFile( ECFile : TEcClient; aClient : TClientObj; filename : string) : boolean;
//returns true if verify failed and user aborted import
var
  acNo             : integer;
  TNo              : integer;
  BKTNo            : integer;
  ba               : TBank_Account;
  ecBA             : TECBank_Account;
  TempT            : bkdefs.pTransaction_Rec;
  T                : bkdefs.pTransaction_Rec;
  ECT              : ecdefs.pTransaction_Rec;
  RejectedLines    : TStringList;
  RejectMsg        : string;
  RejectedLogFilename : string;
  EMsg             : string;
  ImportedCount    : integer;
  RejectedCount    : integer;
  NewCount         : integer;
begin
  result := false;

  ImportedCount := 0;
  RejectedCount := 0;
  NewCount      := 0;

  LogUtil.LogMsg( lmInfo, UnitName, 'Verifying file ' + filename +
                                    ' (' + bkDate2Str(ECFile.ecFields.ecDate_Range_From) +
                                    ' - ' + bkDate2Str(ECFile.ecFields.ecDate_Range_To) + ')');

  RejectedLines := TStringList.Create;
  try
    try
       //cycle thru each bank account and find matching bk5 account
       for acNo := 0 to Pred( ecFile.ecBankAccounts.ItemCount) do
       begin
          ecBA := ecFile.ecBankAccounts.Bank_Account_At( acNo);
          //find matching bk5 account
          ba := aClient.clBank_Account_List.FindCode( ecBa.baFields.baBank_Account_Number);
          if not Assigned( ba) then
          begin
             //rejected bank account
             LogUtil.LogError( Unitname, 'Rejected account ' + ecBa.baFields.baBank_Account_Number);
          end
          else
          begin
             //now import transactions
             for TNo := 0 to Pred( ecBA.baTransaction_List.ItemCount) do
             begin
                ECT := ecBA.baTransaction_List.Transaction_At( TNo);
                if ECT^.txECoding_ID <> 0 then
                begin
                   //find matching bk5 transaction
                   T := nil;
                   for BKTNo := 0 to Pred( ba.baTransaction_List.ItemCount) do
                   begin
                      TempT := ba.baTransaction_List.Transaction_At( bkTno);
                      if TempT.txECoding_Transaction_UID = ECT.txECoding_ID then
                      begin
                         T := TempT;
                         Break;
                      end;
                   end;
                   //see if match found and is valid
                   if ValidateTransactionForImport( ECT, T, RejectMsg) then
                      Inc( ImportedCount)
                   else
                   begin
                      RejectTransaction( ECFile, ECT, RejectMsg, RejectedLines);
                      Inc( RejectedCount);
                   end;
                end
                else begin
                   //a transaction found with no match
                   T := nil;
                   if ValidateNewTransaction( ECFile, ECT, aClient, Ba, RejectMsg, T) then
                   begin
                     if Assigned( T) then
                       Inc( ImportedCount)
                     else
                       Inc( NewCount);
                   end
                   else
                   begin
                     //transaction has no ecoding ID and is not a UPC or UPD
                     RejectTransaction( ECFile, ECT, RejectMsg, RejectedLines);
                     Inc( RejectedCount);
                   end;
                end;
             end;  //for tNo
          end;
       end;

       //save list of rejected transactions
       try
          if RejectedLines.Count > 0 then
          begin
             RejectedLogFilename := glDataDir + ExtractFilename( filename) + '.log';
             RejectedLines.SaveToFile( RejectedLogFilename);
          end;
       except
          on E :Exception do
          begin
             //crash the system because the client will have been updated
             EMsg := 'Cannot save list of rejected transactions to ' + RejectedLogFilename + '. ' + E.Message;
             HelpfulErrorMsg( eMsg, 0);
             RejectedLogFilename := '';
          end;
       end;

       LogUtil.LogMsg( lmInfo, UnitName, 'File verified ' +
                    inttostr( ImportedCount) + ' transaction(s) will be updated '+
                    inttostr( NewCount)      + ' new transaction(s) ' +
                    inttostr( RejectedCount) + ' rejected transaction(s)');

       if not ConfirmImport( filename, ImportedCount, NewCount, RejectedCount, RejectedLogFilename, 'transaction(s)', 'imported', aClient.clFields.clCountry)
       then
       begin
          LogUtil.LogMsg( lmInfo, unitname, 'User aborted import');
          exit;
       end;

       //user has ok'ed file for importing
       Result := True;

    except
       on E : Exception do
       begin
          eMsg := 'An error occurred verifying the file.  The import will not continue.' +
                  ' [' + E.Message + ']';
          HelpfulErrorMsg( eMsg, 0);
          Exit;
       end;
    end;
  finally
    RejectedLines.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetPayeeDetailsForNarration( aClient : TClientObj;
                                      ecFile : TEcClient;
                                      const PayeeNo : integer;
                                      const LineNo : integer) : string;
var
  Payee : PayeeObj.TPayee;
  EcPayee : EcPayeeObj.TEcPayee;
begin
  result := '';
  Payee := aClient.clPayee_List.Find_Payee_Number( PayeeNo);
  if Assigned( Payee) then
     result := Payee.pdLines.PayeeLine_At( LineNo).plGL_Narration
  else begin
     //the payee could no longer be found in bk5, try using the ecoding name
     EcPayee := EcFile.ecPayees.Find_Payee_Number( PayeeNo);
     if Assigned( EcPayee) then
        result := EcPayee.pdName;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UnknownPayeeMsg( ecPayee : ecPayeeObj.TEcPayee) : string;
begin
  result := '';
  //the payee does not exist in BK5 so we can't set the new payee number
  //see if payee still exists in bnotes, may have been added there
  if Assigned( ecPayee) then
  begin
    if ecPayee.pdFields.pdAdded_By_ECoding then
      result := 'New Payee! - ' + ecPayee.pdName
    else
      result := 'Unknown Payee - ' + ecPayee.pdName;
  end;
end;

function UnknownJobMsg(ecJob: TEcJob): string;
begin
  Result := '';
  //if if it's a new job, or an unknown one (maybe it was deleted from BK5 while the notes file was out)
  if Assigned(ecJob) then
  begin
    if ecJob.jhFields.jhAdded_By_ECoding then
      Result := 'New Job! - ' + ecJob.jhFields.jhHeading
    else
      Result := 'Unknown Job - ' + ecJob.jhFields.jhHeading;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ImportStandardTransaction( ECT : ecDefs.pTRansaction_Rec;
                                     BKT   : bkDefs.pTransaction_Rec;
                                     ECFile : TECClient;
                                     aClient : TClientObj;
                                     BankPrefix : string;
                                     BA: TBank_Account);
var
  ecPayee            : ecPayeeObj.TecPayee;
  bkPayee            : PayeeObj.TPayee;
  bkPayeeLine        : bkDefs.pPayee_Line_Rec;

  NeedToUpdatePayeeDetails : boolean;
  NeedToUpdateGST          : boolean;
  trxPayeeDetails    : string;

  aMsg               : string;
  ecJob: TECJob;
  bkJob: pJob_Heading_Rec;
begin
  //first we need to determine if the bk5 transaction is coded
  //if it is currently uncoded then code the transaction using the information
  //in the bnotes transaction
  NeedToUpdatePayeeDetails := False;
  NeedToUpdateGST          := False;
  trxPayeeDetails          := '';

  //Convert VAT amount from forex to base for forex bank accounts
  if ba.IsAForexAccount then begin
    //If the exchange rate is zero then flag GST as edited so that it is
    //added as a note.
    if (BKT.Default_Forex_Rate <> 0) then
      ECT.txGST_Amount := (ECT.txGST_Amount / BKT.Default_Forex_Rate)
    else
      ECT.txGST_Has_Been_Edited := (ECT.txGST_Amount <> 0); // Fix for Bug 19876
  end;

  if BKT^.txFirst_Dissection = nil then
  begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 1 - BNotes (ND)  BK5 (ND)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //The BK5 transaction has not been dissected

    //Amount - override the amount if the transaction is a UPC or UPD
    if ( BKT^.txUPI_State in [ upUPC, upUPD, upUPW]) and ( BKT^.txAmount <> ECT^.txAmount) then
    begin
      if BKT^.txAmount = 0 then
      begin
        BKT^.txAmount            := ECT^.txAmount;
        //update the GST amount if a class has been set in BK5.  This is in
        //case the transaction has been coded
        if BKT^.txGST_Class = 0 then
          BKT^.txGST_Amount := 0
        else
          BKT^.txGST_Amount := CalculateGSTForClass( aClient, BKT^.txDate_Effective, BKT^.Local_Amount, BKT^.txGST_Class);
      end
      else
      begin
        //bk5 transaction already has an amount, so add a note to import notes
        if ECT^.txAmount <> 0 then
          AddToImportNotes( BKT, 'Amount '+ Money2Str( ECT^.txAmount), glConst.ECODING_APP_NAME);
      end;
    end;

    //Account
    if ( BKT.txAccount <> ECT.txAccount) and ( ECT.txAccount <> '') then
    begin
      if BKT.txAccount = '' then
      begin
        //account is blank so use ecoding account to code the transaction
        BKT.txAccount         := ECT.txAccount;
        BKT.txHas_Been_Edited := true;

        if ECT.txCoded_By = cbManual then
          NeedToUpdateGST     := true;
      end
      else begin
        AddToImportNotes( BKT, 'Account Code ' + ECT.txAccount, glConst.ECODING_APP_NAME);
      end;
    end;

    //Payee
    bkPayee := nil;

    if ECT^.txPayee_Number <> 0 then
    begin
      //get payees
      ecPayee := ecFile.ecPayees.Find_Payee_Number( ECT^.txPayee_Number);
      if (Assigned( ecPayee) and ( ecPayee.pdFields.pdAdded_By_ECoding)) then
      begin
        //new payee, flag in import notes
        AddToImportNotes( BKT, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
      end
      else
      begin
        bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);

        if ( ECT^.txPayee_Number = BKT^.txPayee_Number) then
          //even though the payee has not changed we need to reconstruct the
          //payee details so that the narration can be set correctly
          NeedToUpdatePayeeDetails := True
        else
        begin
          if not Assigned( bkPayee) then
          begin
            AddToImportNotes( BKT, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
          end
          else
          begin
            //payee found
            if ( BKT^.txPayee_Number = 0) then
            begin
              //set the bk5 payee number from here
              BKT.txPayee_Number         := ECT^.txPayee_Number;
              BKT.txHas_Been_Edited      := True;
              NeedToUpdatePayeeDetails   := True;

              if ECT^.txCoded_By = cbManualPayee then
                NeedToUpdateGST        := True;
            end
            else
              AddToImportNotes( BKT, 'Payee ' + bkPayee.pdName +
                                     ' (' + inttostr( bkPayee.pdNumber) + ')',
                                     glConst.ECODING_APP_NAME);
          end;
        end;
      end;

      //now construct the payee details string so that we can set the narration
      if NeedToUpdatePayeeDetails then
      begin
        if Assigned( bkPayee) then
        begin
          if bkPayee.IsDissected then
          begin
            if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
              trxPayeeDetails := bkPayee.pdName
            else
              trxPayeeDetails := '';
          end
          else
          begin
            bkPayeeLine := bkPayee.FirstLine;
            if Assigned( bkPayeeLine) and ( bkPayeeLine.plAccount = BKT^.txAccount) then
              trxPayeeDetails := GetPayeeDetailsForNarration( aClient,
                                                              ecFile,
                                                              BKT^.txPayee_Number,
                                                              0)
            else
              trxPayeeDetails := bkPayee.pdName; //cant find details so at least use name
          end;
        end;
      end;
    end;

    //jobs
    if ECT^.txJob_Code <> BKT^.txJob_Code then
    begin
      ecJob := ecFile.ecJobs.Find_Job_Code(ECT^.txJob_Code);
      bkJob := aClient.clJobs.FindCode(ECT^.txJob_Code);
      if Assigned(ecJob) and not Assigned(bkJob) then
        AddToImportNotes(BKT, UnknownJobMsg(ecJob), glConst.ECODING_APP_NAME)
      else
      begin
        //if there was no existing job then apply new job
        if BKT^.txJob_Code = '' then
        begin
          BKT^.txJob_Code := ECT^.txJob_Code;
          BKT^.txHas_Been_Edited := true;
        end
        else
        begin
          //add notes
          if ECT^.txJob_Code = '' then
            AddToImportNotes(BKT, 'Job Removed', glConst.ECODING_APP_NAME)  //deleted job
          else
            AddToImportNotes(BKT, 'Job ' + bkJob.jhHeading + ' (' + bkJob.jhCode + ')', glConst.ECODING_APP_NAME);
          
        end;

      end;
    end;

    //GST
    if NeedToUpdateGST then
    begin
      if ECT.txCoded_By = cbManual then
      begin
         //if manually coded then update gst class and amount from the account code
         //this will also update txCoded_by , txHasBeenEdited and txGST_has_been_Edited
         UpdateTransGSTFields( aClient, BKT, BankPrefix, cbECodingManual);
      end;

      if ECT.txCoded_By = cbManualPayee then
      begin
        //get payees
        bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);
        bkPayeeLine := bkPayee.FirstLine;

        //decide whether to use gst from chart or payee
        if ( Assigned( bkPayeeLine)) and ( bkPayeeLine.plGST_Has_Been_Edited) and ( BKT^.txAccount = ECT^.txAccount) then
        begin
          //the gst has been overriden at the payee level so use that gst info
          //to code the transaction, this means that the gst amount in bnotes
          //should match the default gst amount for bk5
          BKT^.txGST_Class          := bkPayeeLine.plGST_Class;
          BKT^.txGST_Amount         := CalculateGSTForClass( aClient,
                                                             BKT^.txDate_Effective,
                                                             BKT^.Local_Amount,
                                                             BKT^.txGST_Class);
          BKT^.txGST_Has_Been_Edited := True;
        end
        else
        begin
          //use the gst from the account code
          UpdateTransGSTFields( aClient, BKT, BankPrefix, cbECodingManual);
        end;

        BKT.txCoded_By         := cbECodingManualPayee;
        BKT.txHas_Been_Edited  := True;
      end;
    end;

    //gst
    if ECT.txGST_Has_Been_Edited then begin
      aMsg := '';
      //GST will be set if account is set above
      //In all other cases the gst amount will be written to import notes
      //unless it is blank in BNotes.  Blank means don't change
      //also show note if user has specified gst and 0.00 for an uncoded trans
      if ( BKT.txGST_Amount <> ECT.txGST_Amount) or (( ECT.txGST_Amount = 0) and ( BKT.txAccount = '')) then
      begin
         aMsg := aClient.TaxSystemNameUC + ' Amount    ' + Money2Str( ECT.txGST_Amount);
      end;
      AddToImportNotes( BKT, aMsg, glConst.ECODING_APP_NAME);
    end;

    //tax inv
    BKT^.txTax_Invoice_Available       := ECT^.txTax_Invoice_Available;

    //quantity
    //correct the sign of the quantity before comparing in case it is incorrect
    //in bnotes
    ECT^.txQuantity := ForceSignToMatchAmount( ECT^.txQuantity, BKT^.txAmount);
    if ( BKT^.txQuantity <> ECT^.txQuantity) then
    begin
      if BKT^.txQuantity = 0 then
      begin
        BKT^.txQuantity := ECT^.txQuantity;
      end
      else
         AddToImportNotes( BKT, 'Quantity   ' + FormatFloat('#,##0.####', ECT.txQuantity/10000), glConst.ECODING_APP_NAME);
    end;

     //Superfields
    if ECFile.ecFields.ecSuper_Fund_System <> 0 then begin
       //Have a go..

       if (BKT^.txSF_Franked <> ECT^.txSF_Franked)
       or (BKT^.txSF_UnFranked <> ECT^.txSF_UnFranked)
       or (BKT^.txSF_Imputed_Credit <> ECT^.txSF_Franking_Credit) then begin
          // Someting Changed...
          if (BKT^.txSF_Franked = 0)
          and (BKT^.txSF_UnFranked = 0)
          and (BKT^.txSF_Imputed_Credit = 0) then begin
             // Did not have anny, just fill it in..
             BKT^.txSF_Franked := ECT^.txSF_Franked;
             BKT^.txSF_UnFranked := ECT^.txSF_UnFranked;
             BKT^.txSF_Imputed_Credit := ECT^.txSF_Franking_Credit;
             BKT^.txSF_Super_Fields_Edited := True;
             BKT^.txHas_Been_Edited  := True;
             BKT^.txCoded_By := cbECodingManual;
             if FrankingCredit(BKT^.txSF_Franked, BKT^.txDate_Effective) <> BKT^.txSF_Imputed_Credit  then begin
                aMsg := 'The franking credit amounts do not match the calculated amounts ''Franked: $' + Money2Str( BKT^.txSF_Franked) +
                ' Unfranked: $' +  Money2Str( BKT^.txSF_UnFranked) +
                ' Franking Credits: $' +  Money2Str( BKT^.txSF_Imputed_Credit) + '''';
                AddToImportNotes( BKT,aMsg , glConst.ECODING_APP_NAME);
             end;

          end else begin
             aMsg := 'Superfund: ''Franked: $' + Money2Str( ECT^.txSF_Franked) +
                ' Unfranked: $' +  Money2Str( ECT^.txSF_UnFranked) +
                ' Franking Credits: $' +  Money2Str( ECT^.txSF_Franking_Credit) + '''';
                AddToImportNotes( BKT,aMsg , glConst.ECODING_APP_NAME);

          end;
       end;
    end;

    //gl narration
    BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            trxPayeeDetails,
                                            ECT^.txNotes);

    //Notes
    UpdateNotes(BKT, ECT.txNotes);


  end
  else
  begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 2 - BNotes (ND)  BK5 (D)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //Export the details to the notes field as the bk5 transaction is dissected

    if ( ECT.txUPI_State in [ upUPD, upUPC, upUPW]) and ( ECT.txAmount <> 0) then
    begin
       AddToImportNotes( BKT, 'Amount ' + Money2Str( ECT.txAmount), glConst.ECODING_APP_NAME);
    end;
    //account
    if ( ECT.txAccount <> '') then
       AddToImportNotes( BKT, 'Account Code ' + ECT.txAccount, glConst.ECODING_APP_NAME);
    //gst, tax inv
    if ( ECT.txGST_Has_Been_Edited) then
    begin
       AddToImportNotes( BKT, aClient.TaxSystemNameUC + ' Amount ' + Money2Str( ECT.txGST_Amount), glConst.ECODING_APP_NAME);
    end;
    //payee
    if ( ECT.txPayee_Number <> 0) and ( ECT.txPayee_Number <> BKT.txPayee_Number) then
    begin
       ecPayee := ecFile.ecPayees.Find_Payee_Number( ECT^.txPayee_Number);
       bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);

       if Assigned( bkPayee) and ((ecPayee = nil) or (not ecPayee.pdFields.pdAdded_By_ECoding)) then
         AddToImportNotes( BKT, ' Payee ' + bkPayee.pdName +
                                ' (' + inttostr( bkPayee.pdNumber) + ')',
                                glConst.ECODING_APP_NAME)
       else
         AddToImportNotes( BKT, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
    end;
    //quantity
    ECT^.txQuantity := ForceSignToMatchAmount( ECT^.txQuantity, ECT^.txAmount);
    if ( ECT.txQuantity <> 0) then
    begin
       AddToImportNotes( BKT, 'Quantity ' + FormatFloat('#,##0.####', ECT.txQuantity/10000), glConst.ECODING_APP_NAME);
    end;

    //tax invoice
    BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;

    //notes
    UpdateNotes(BKT, ECT.txNotes);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ECodingDissectionMatchesBK5Payee( bkPayee : PayeeObj.TPayee;
                                           ECT     : ecDefs.pTransaction_Rec) : boolean;
//matches the lines in the dissection with the lines in the payee.
//the match is done on account
var
  D : ecDefs.pDissection_Rec;
  Line : integer;
  PayeeLine : bkdefs.pPayee_Line_Rec;
begin
  result := true;

  D := ECT^.txFirst_Dissection;
  Line := 0;

  while ( D <> nil) do
    begin
      Inc( Line);
      D := D.dsNext;
    end;

  if Line = bkPayee.pdLines.ItemCount then
    begin
      D := ECT^.txFirst_Dissection;
      for line := bkPayee.pdLines.First to bkPayee.pdLines.Last do
        begin
          PayeeLine := bkPayee.pdLines.PayeeLine_At( Line);
          if PayeeLine.plAccount <> D.dsAccount then
            begin
              result := false;
              exit;
            end;
          D := D.dsNext;
        end;
    end
  else
    result := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ExportDissectionLinesToNotes( ECFile : TEcClient; T : BKDEFS.pTransaction_Rec; ECT : ECDEFS.pTransaction_Rec);
//the dissection cannot be imported because of one of the following reasons:
//
//    1) The dissection lines in bnotes do not match the dissection in bk5
//    2) The bnotes transaction has been dissected, but the bk5 transaction has been coded normally

var
  ExtraNotes : TStringList;
  ECD        : ECDEFS.pDissection_Rec;
  NewLine    : string;
  ECPayee    : ecPayeeObj.TecPayee;
begin
  AddToImportNotes( T, 'Dissection cannot be imported.  Details added to notes', glConst.ECODING_APP_NAME);

  ExtraNotes := TStringList.Create;
  try
     ExtraNotes.Add( '');
     ExtraNotes.Add( 'Dissection Details');
     //add transaction level details
     if ( T^.txAmount <> ECT^.txAmount) then
        ExtraNotes.Add( 'Transaction Amount = ' + Money2Str( ECT^.txAmount));

     if ECT^.txPayee_Number <> 0 then
     begin
       ecPayee := ecFile.ecPayees.Find_Payee_Number( ECT.txPayee_Number);
       if Assigned( ecPayee) then
         ExtraNotes.Add( 'Transaction Payee = ' + ecPayee.pdName + ' (' +
                         inttostr( ecPayee.pdNumber) + ')');
     end;
     //add details for each line
     ECD := ECT^.txFirst_Dissection;
     while (ECD <> nil) do begin
        NewLine := '';

        NewLine := NewLine + 'Code = ' + ECD.dsAccount;
        NewLine := NewLine + '  Amt = ' + Money2Str( ECD.dsAmount);
        NewLine := NewLine + '  GST = ' + Money2Str( ECD.dsGST_Amount);
        if ECD.dsPayee_Number <> 0 then
        begin
           ECPayee := ECFile.ecPayees.Find_Payee_Number( ECD.dsPayee_Number);
           if assigned( ECPayee) then
              NewLine := NewLine + '  Payee = ' + ecPayee.pdName + ' (' +
                                      inttostr( ecPayee.pdNumber) + ') ';
        end;
        if ECD.dsQuantity <> 0 then
           NewLine := NewLine + '  Qty = ' + FormatFloat('#,##0.####', ECD.dsQuantity/10000);

        if Trim( ECD.dsNotes) <> '' then
           NewLine := NewLine + '  Notes = ' + GenUtils.StripReturnCharsFromString( ECD.dsNotes, ' | ');

        if ECD.dsJob_Code <> '' then
          NewLine := NewLine + '  Job = ' + ECD.dsJob_Code;

        ExtraNotes.Add( NewLine);
        ECD := ECD.dsNext;
     end;

     ECT.txNotes := ECT.txNotes + ExtraNotes.Text;
  finally
     ExtraNotes.Free;
  end;
end;

procedure ImportTransactionJob(BKT: bkDefs.pTransaction_Rec; ECT: ecDefs.pTransaction_Rec; aClient: TClientObj; ECFile: TEcClient);
var
  bkJob: pJob_Heading_Rec;
  ecJob: TECJob;
begin
  if ECT^.txJob_Code <> BKT^.txJob_Code then
  begin
    ecJob := ecFile.ecJobs.Find_Job_Code(ECT^.txJob_Code);
    bkJob := aClient.clJobs.FindCode(ECT^.txJob_Code);
    if Assigned(ecJob) and not Assigned(bkJob) then
      AddToImportNotes(BKT, UnknownJobMsg(ecJob), glConst.ECODING_APP_NAME)
    else
    begin
      //if there was no existing job then apply new job
      if BKT^.txJob_Code = '' then
      begin
        BKT^.txJob_Code := ECT^.txJob_Code;
        BKT^.txHas_Been_Edited := true;
      end
      else
      begin
        //add notes
        if ECT^.txJob_Code = '' then
          AddToImportNotes(BKT, 'Job Removed', glConst.ECODING_APP_NAME)
        else
          //deleted job
          AddToImportNotes(BKT, 'Job ' + bkJob.jhHeading + ' (' + bkJob.jhCode + ')', glConst.ECODING_APP_NAME);
      end;
    end;
  end;
end;

procedure ImportDissectionJob(ECT: ecDefs.pTransaction_Rec; ECFile: TEcClient; BKD: bkDefs.pDissection_Rec; ECD: ecDefs.pDissection_Rec; aClient: TClientObj);
var
  bkJob: pJob_Heading_Rec;
  ecJob: TECJob;
begin
  //Jobs
  if (ECT^.txJob_Code = '') and (BKD^.dsJob_Code <> ECD^.dsJob_Code) then
  //only import jobs for dissections if the job for the main transaction is blank
  begin
    ecJob := ecFile.ecJobs.Find_Job_Code(ECD^.dsJob_Code);
    bkJob := aClient.clJobs.FindCode(ECD^.dsJob_Code);
    if Assigned(ecJob) and not Assigned(bkJob) then
      AddToImportNotes(BKD, UnknownJobMsg(ecJob), glConst.ECODING_APP_NAME)
    else
    begin
      //if there was no existing job then apply new job
      if BKD^.dsJob_Code = '' then
      begin
        BKD^.dsJob_Code := ECD^.dsJob_Code;
        BKD^.dsHas_Been_Edited := true;
      end
      else
      begin
        //add notes
        if ECD^.dsJob_Code = '' then
          AddToImportNotes(BKD, 'Job Removed', glConst.ECODING_APP_NAME)
        else
          //deleted job
          AddToImportNotes(BKD, 'Job ' + bkJob.jhHeading + ' (' + bkJob.jhCode + ')', glConst.ECODING_APP_NAME);
      end;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ImportExistingDissection( ECT : ecDefs.pTRansaction_Rec;
                                      BKT   : bkDefs.pTransaction_Rec;
                                      ECFile : TECClient;
                                      aClient : TClientObj);
var
  bkPayee : PayeeObj.TPayee;
  bkPayeeLine : Bkdefs.pPayee_Line_Rec;
  ecPayee : EcPayeeObj.TEcPayee;
  //ecPayeeLine : ecDefs.pPayee_Line_Rec;
  BKD                : bkDefs.pDissection_Rec;
  ECD                : ecDefs.pDissection_Rec;

  bkDissectionLine   : bkDefs.pDissection_Rec;
  DissectionLineNo   : integer;

  DissectionMatchesPayee   : boolean;

  Transaction_Payee : PayeeObj.TPayee;
  trxPayeeDetail     : string;
  dPayeeDetail       : string;  //detail for dissection line

  UseBK5PayeeInformation : boolean;
  CurrentProcessingPayeeID : integer;

  LinesForCurrentPayee : integer;
  CurrentPayeeLine     : integer;
  i : integer;
begin
  //both transactions are dissected, test for match has been done
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //CASE 5 - BNotes (D)  BK5 (D) - Dissections Match
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //GST will have been assigned when the transaction was coded in BK5 so we
  //do not need to reassign the gst here

  trxPayeeDetail := '';
  dPayeeDetail := '';
  Transaction_Payee := nil;
  DissectionMatchesPayee := False;

  //Import Transaction level fields

  //amount
    // already tested that this matches bk5

  //account
    // n/a because transaction is dissected

  //gst
    // n/a because transaction is dissected

  //Notes
  UpdateNotes(BKT, ECT.txNotes);

  //Payee
  //payee cannot be set in bnotes if the transaction has been coded by
  //the accountant, however we may need to recreate the narration
  ecPayee := ecFile.ecPayees.Find_Payee_Number( ECT^.txPayee_Number);
  bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);

  if ( BKT^.txPayee_Number <> ECT^.txPayee_Number) then
  begin
    //payee is different, add a note
    if ect^.txPayee_Number <> 0 then
    begin
      if Assigned( bkPayee) and (( ecPayee = nil) or (not ecPayee.pdFields.pdAdded_By_ECoding)) then
        AddToImportNotes( BKT, 'Payee ' + bkPayee.pdName + ' (' + inttostr( bkPayee.pdNumber) + ')', glConst.ECODING_APP_NAME)
      else
        AddToImportNotes( BKT, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
    end;
  end;

  //store the payee name so that we can use it to recreate the narration if
  //needed
  if ( BKT^.txPayee_Number <> 0) then
  begin
    //payee has been specified at transaction level
    bkPayee :=  aClient.clPayee_List.Find_Payee_Number( BKT^.txPayee_Number);
    if Assigned( bkPayee) then
    begin
      trxPayeeDetail := bkPayee.pdFields.pdName;

      //now see if the dissection matches the narration
      DissectionMatchesPayee := BK5DissectionMatchesBK5Payee( bkPayee, BKT);
      Transaction_Payee := bkPayee;
    end;
  end;
  //Jobs
  ImportTransactionJob(BKT, ECT, aClient, ECFile);

  //GL Narration
  if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
    BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            trxPayeeDetail,
                                            ECT^.txNotes)
  else
    BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                            BKT^.txGL_Narration,
                                            '',
                                            ECT^.txNotes);

  BKT^.txTax_Invoice_Available := ECT^.txTax_Invoice_Available;

  //NOW IMPORT DISSECTION LINES
  BKD := BKT^.txFirst_Dissection;
  ECD := ECT^.txFirst_Dissection;
  DissectionLineNo := 1;

  CurrentProcessingPayeeID := 0;
  CurrentPayeeLine := 0;
  LinesForCurrentPayee := 0;
  //bkPayeeLine := nil;
  UseBK5PayeeInformation := false;

  while ( BKD <> nil) do
  begin
    BKD.dsECoding_Import_Notes := '';

    //Amount
      //already tested that this matches bk5, also cannot be edited in bnotes unless upc

    //Account
      //already tested that this matched bk5, also cannot be edited in bnotes if it was dissected in bk5 on export

    //GST Amount
      //show flag if amounts are different or user has specied gst and zero for
      //and uncoded line
    if ( ECD.dsGST_Has_Been_Edited) then
      if ( ECD.dsGST_Amount <> BKD.dsGST_Amount) or
         (( ECD.dsGST_Amount = 0) and ( BKD.dsAccount = '')) then
      begin
        AddToImportNotes( BKD, aClient.TaxSystemNameUC + ' Amount  ' + Money2Str( ECD.dsGST_Amount), glConst.ECODING_APP_NAME);
      end;

    //Quantity
    ECD^.dsQuantity := ForceSignToMatchAmount( ECD^.dsQuantity, BKD^.dsAmount);
    if ( ECD^.dsQuantity <> BKD^.dsQuantity) then
    begin
      if BKD^.dsQuantity = 0 then
      begin
        BKD^.dsQuantity := ECD^.dsQuantity;
      end
      else
        AddToImportNotes( BKD, 'Quantity  ' + FormatFloat('#,##0.####', ECD.dsQuantity/10000), glConst.ECODING_APP_NAME);
    end;

    //Tax Invoice
    BKD^.dsTax_Invoice := ECD^.dsTax_Invoice;

    //Notes
    BKD.dsNotes := ECD.dsNotes;

    //Payee
    //show note if payee values are different
    if BKD.dsPayee_Number <> ECD.dsPayee_Number then
    begin
      //payee is different, add a note
      if ecd^.dsPayee_Number <> 0 then
      begin
        bkPayee := aClient.clPayee_List.Find_Payee_Number( ECD^.dsPayee_Number);
        ecPayee := ecFile.ecPayees.Find_Payee_Number( ECD^.dsPayee_Number);

        if Assigned( bkPayee) and (( ecPayee = nil) or (not ecPayee.pdFields.pdAdded_By_ECoding)) then
          AddToImportNotes( BKD, 'Payee ' + bkPayee.pdName + ' (' + inttostr( bkPayee.pdNumber) + ')', glConst.ECODING_APP_NAME)
        else
          AddToImportNotes( BKD, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
      end;
    end;

    if BKT^.txPayee_Number <> 0 then
    begin
      //if the dissection has been created by a payee at transaction level then
      //use the payee for narration
      if DissectionMatchesPayee then
        dPayeeDetail := Transaction_Payee.pdLines.PayeeLine_At( DissectionLineNo - 1).plGL_Narration
      else
        dPayeeDetail := '';  //dont know what payee detail to use

      UseBK5PayeeInformation := false;
    end
    else
    begin
      //if the dissection lines are coded by payee then we need to see if
      //the payee lines match the next n dissection lines
      //this will allow us to reset the narration
      bkPayee := aClient.clPayee_List.Find_Payee_Number( BKD^.dsPayee_Number);
      dPayeeDetail := '';

      if not Assigned( bkPayee) then
      begin
        dPayeeDetail := '';
        UseBK5PayeeInformation := false;
      end
      else
      begin
        //payee found
        dPayeeDetail := bkPayee.pdFields.pdName;

        //see if we are already coding using a payee
        if ( CurrentProcessingPayeeID <> BKD.dsPayee_Number) or ( CurrentPayeeLine > ( LinesForCurrentPayee - 1)) then
        begin
          //this is a new payee id, see if the following lines match
          //the structure of the payee in bk5
          CurrentProcessingPayeeID := bkPayee.pdFields.pdNumber;
          LinesForCurrentPayee := bkPayee.pdLinesCount;
          CurrentPayeeLine := 0;
          UseBK5PayeeInformation := false;
          //bkPayeeLine := nil;

          if LinesForCurrentPayee > 0 then
          begin
            bkDissectionLine := BKD;
            //see if next n lines match the bk5 payee
            i := 0;
            Repeat
              bkPayeeLine := bkPayee.pdLines.PayeeLine_At( i);
              UseBK5PayeeInformation := ( bkDissectionLine.dsAccount = bkPayeeLine.plAccount);
              bkDissectionLine := bkDissectionLine.dsNext;
              if bkDissectionLine <> nil then
                Inc( i);
            Until ( i = LinesForCurrentPayee) or ( bkDissectionLine = nil) or ( not UseBK5PayeeInformation);

            //make sure there are enough dissection lines
            if ( i < (LinesForCurrentPayee - 1)) then
              UseBK5PayeeInformation := false;

            if not UseBK5PayeeInformation then
            begin
              LinesForCurrentPayee := 0;
              //bkPayeeLine := nil;
            end;
          end;
        end;

        //get the current line and use that to set the narration
        if UseBK5PayeeInformation then
        begin
          bkPayeeLine := bkPayee.pdLines.PayeeLine_At( CurrentPayeeLine);
          dPayeeDetail := bkPayeeLine.plGL_Narration;
          Inc( CurrentPayeeLine);
        end;
      end;
    end;
    //Jobs
    ImportDissectionJob(ECT, ECFile, BKD, ECD, aClient);

    //Narration
    BKD.dsGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                           BKD.dsGL_Narration,
                                           dPayeeDetail,
                                           ECD.dsNotes);

    //Superfields
    if ECFile.ecFields.ecSuper_Fund_System <> 0 then begin
       //Have a go..
       if (BKD^.dsSF_Franked <> ECD^.dsSF_Franked)
       or (BKD^.dsSF_UnFranked <> ECD^.dsSF_UnFranked)
       or (BKD^.dsSF_Imputed_Credit <> ECD^.dsSF_Franking_Credit) then begin
          BKT.txCoded_By := cbECodingManual;
          if (BKD^.dsSF_Franked = 0)
          and (BKD^.dsSF_UnFranked = 0)
          and (BKD^.dsSF_Imputed_Credit = 0) then begin
             // Hade nothing, just fill it in
             BKD^.dsSF_Franked        := ECD^.dsSF_Franked;
             BKD^.dsSF_UnFranked      := ECD^.dsSF_UnFranked;
             BKD^.dsSF_Imputed_Credit := ECD^.dsSF_Franking_Credit;
             BKD.dsSF_Super_Fields_Edited := True;

             if FrankingCredit(BKD^.dsSF_Franked, BKT^.txDate_Effective) <> BKD^.dsSF_Imputed_Credit  then begin
                  AddToImportNotes( BKD,'The franking credit amounts do not match the calculated amounts ''Franked: $' + Money2Str( BKd^.dsSF_Franked) +
                  ' Unfranked: $' +  Money2Str( BKD^.dsSF_UnFranked) +
                  ' Franking Credits: $' +  Money2Str( BKD^.dsSF_Imputed_Credit) + '''', glConst.ECODING_APP_NAME) ;
             end;
          end else begin
             // Just make a Note..
             AddToImportNotes( BKD,'Superfund ''Franked: $' + Money2Str( ECD^.dsSF_Franked) +
                  ' Unfranked: $' +  Money2Str( ECD^.dsSF_UnFranked) +
                  ' Franking Credits: $' +  Money2Str( ECD^.dsSF_Franking_Credit) + '''', glConst.ECODING_APP_NAME) ;
          end;
       end;
    end;

    //move to next dissection line
    BKD := BKD.dsNext;
    ECD := ECD.dsNext;
    Inc( DissectionLineNo);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ImportNewDissection_NoPayees( ECT : ecDefs.pTransaction_Rec;
                                        BKT : bkDefs.pTransaction_Rec;
                                        aClient : TClientObj;
                                        ECFile : TEcClient
                                        );
var
  BKD                : bkDefs.pDissection_Rec;
  ECD                : ecDefs.pDissection_Rec;
  DefaultGSTClass    : byte;
  DefaultGSTAmount   : Money;
begin
  BKT.txAccount := DISSECT_DESC;
  BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;

  ClearGSTFields( BKT);
  ClearSuperFundFields( BKT);

  //Import Transaction Level Fields
  BKT.txAmount := ECT.txAmount;
  BKT.txPayee_Number := 0;

  //Jobs
  ImportTransactionJob(BKT, ECT, aClient, ECFile);
  BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                          BKT^.txGL_Narration,
                                          '',
                                          ECT^.txNotes);
  UpdateNotes(BKT, ECT.txNotes);
  case ECT^.txCoded_By of
    cbManual, cbManualPayee : BKT^.txCoded_By := bkconst.cbECodingManual;
  else
    BKT^.txCoded_By := ECT^.txCoded_By;
  end;

  //NOW IMPORT DISSECTION LINES
  ECD := ECT^.txFirst_Dissection;
  while ( ECD <> nil) do
  begin
    //create a new dissection line for the bk5 transaction
    BKD := bkdsio.New_Dissection_Rec;
    BKD.dsECoding_Import_Notes  := '';

    BKD.dsAmount            := ECD.dsAmount;
    BKD.dsAccount           := ECD.dsAccount;
    BKD.dsHas_Been_Edited   := ECD.dsHas_Been_Edited;
    BKD.dsSF_Member_Account_ID:= -1;
    BKD.dsSF_Fund_ID          := -1;
    BKD.dsBank_Account        := BKT^.txBank_Account;
    BKD.dsTransaction         := BKT;

    //GST - calculate gst using information from the chart codes
    CalculateGST( aClient, BKT^.txDate_Effective, BKD^.dsAccount, BKD^.Local_Amount, DefaultGSTClass, DefaultGSTAmount);

    BKD^.dsGST_Amount   := DefaultGSTAmount;
    BKD^.dsGST_Class    := DefaultGSTClass;
    BKD^.dsGST_Has_Been_Edited := False;

    //now see if the gst specified in bnotes is different
    //also add a note if gst is 0.00 in both places and trans is uncoded
    if (ECD^.dsGST_Has_Been_Edited) then
      if ( ECD^.dsGST_Amount <> BKD^.dsGST_Amount) or
         (( ECD^.dsGST_Amount = 0) and ( BKD^.dsAccount = ''))
      then
        AddToImportNotes( BKD, aClient.TaxSystemNameUC + ' Amount  ' + Money2Str( ECD^.dsGST_Amount), glConst.ECODING_APP_NAME);

    BKD.dsQuantity          := ForceSignToMatchAmount( ECD.dsQuantity, BKD.dsAmount);
    BKD.dsNotes             := ECD.dsNotes;
    BKD.dsGL_Narration      := UpdateNarration( aClient.clFields.clECoding_Import_Options, BKD.dsGL_Narration, '', ECD.dsNotes);

    BKD.dsTax_Invoice := ECD.dsTax_Invoice;
    //Jobs
    ImportDissectionJob(ECT, ECFile, BKD, ECD, aClient);

    if ECFile.ecFields.ecSuper_Fund_System <> 0 then begin
       //Have a go..
       if (BKD^.dsSF_Franked <> ECD^.dsSF_Franked)
       or (BKD^.dsSF_UnFranked <> ECD^.dsSF_UnFranked)
       or (BKD^.dsSF_Imputed_Credit <> ECD^.dsSF_Franking_Credit) then begin
          BKT.txCoded_By := cbECodingManual;
          if (BKD^.dsSF_Franked = 0)
          and (BKD^.dsSF_UnFranked = 0)
          and (BKD^.dsSF_Imputed_Credit = 0) then begin
             // Hade nothing, just fill it in
             BKD^.dsSF_Franked        := ECD^.dsSF_Franked;
             BKD^.dsSF_UnFranked      := ECD^.dsSF_UnFranked;
             BKD^.dsSF_Imputed_Credit := ECD^.dsSF_Franking_Credit;

             BKD.dsSF_Super_Fields_Edited := True;

             if FrankingCredit(BKD^.dsSF_Franked, BKT^.txDate_Effective) <> BKD^.dsSF_Imputed_Credit  then begin
                  AddToImportNotes( BKD,'The franking credit amounts do not match the calculated amounts ''Franked: $' + Money2Str( BKd^.dsSF_Franked) +
                  ' Unfranked: $' +  Money2Str( BKD^.dsSF_UnFranked) +
                  ' Franking Credits: $' +  Money2Str( BKD^.dsSF_Imputed_Credit) + '''', glConst.ECODING_APP_NAME) ;
             end;
          end else begin
             // Just make a Note..
             AddToImportNotes( BKD,'Superfund ''Franked: $' + Money2Str( ECD^.dsSF_Franked) +
                  ' Unfranked: $' +  Money2Str( ECD^.dsSF_UnFranked) +
                  ' Franking Credits: $' +  Money2Str( ECD^.dsSF_Franking_Credit) + '''', glConst.ECODING_APP_NAME) ;
          end;
       end;
    end;

    //Add the new dissection to the transaction
    TrxList32.AppendDissection( BKT, BKD, aClient.ClientAuditMgr);
    ECD := ECD.dsNext;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ImportNewDissection_TransactionLevelPayee( ECT : ecDefs.pTransaction_Rec;
                                        BKT : bkDefs.pTransaction_Rec;
                                        aClient : TClientObj;
                                        ecFile : TECClient);
var
  bkPayee : PayeeObj.TPayee;
  bkPayeeLine : Bkdefs.pPayee_Line_Rec;
  ecPayee : EcPayeeObj.TEcPayee;
  BKD                : bkDefs.pDissection_Rec;
  ECD                : ecDefs.pDissection_Rec;
  DissectionLineNo   : integer;
  DissectionMatchesPayee   : boolean;
  trxPayeeDetail     : string;
  dPayeeDetail       : string;  //detail for dissection line
  DefaultGSTClass    : byte;
  DefaultGSTAmount   : Money;
  UseTransactionPayeeDetails  : boolean;
begin
  //Dissect the BK5 transaction
  BKT.txAccount := DISSECT_DESC;
  ClearGSTFields( BKT);
  ClearSuperFundFields( BKT);

  //Import Transaction Level Fields
  //Amount
  BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;
  BKT.txAmount := ECT.txAmount;
  BKT.txPayee_Number := 0;
  ImportTransactionJob(BKT, ECT, aClient, ECFile);
  //Payee
  bkPayee := nil;
  trxPayeeDetail := '';
  dPayeeDetail := '';
  UseTransactionPayeeDetails := False;

  if ECT^.txPayee_Number <> 0 then
  begin
    ecPayee := ecFile.ecPayees.Find_Payee_Number( ECT^.txPayee_Number);
    if Assigned( ecPayee) and (ecPayee.pdFields.pdAdded_By_ECoding) then
    begin
      //payee is new, don't try to match it
      AddToImportNotes( BKT, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
    end
    else
    begin
      bkPayee := aClient.clPayee_List.Find_Payee_Number( ECT^.txPayee_Number);

      if not Assigned( bkPayee) then
      begin
        //no matching payee found in bk5
        AddToImportNotes( BKT, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
      end
      else
      begin
        //payee found
        //set the bk5 payee number from here
        BKT.txPayee_Number         := ECT^.txPayee_Number;
        BKT.txHas_Been_Edited      := True;

        if bkPayee.IsDissected then
        begin
          //use the payee name outside the narration
          if Assigned(AdminSystem) and AdminSystem.fdFields.fdReplace_Narration_With_Payee then
          begin
            trxPayeeDetail := bkPayee.pdName;
            dPayeeDetail   := trxPayeeDetail;
          end
          else
          begin
            trxPayeeDetail := '';
            dPayeeDetail   := bkPayee.pdName;
          end;

          //now we need to see if the payee lines match the dissection lines
          //this will be used later to decide what payee details to add
          //to each line
          DissectionMatchesPayee := ECodingDissectionMatchesBK5Payee( bkPayee, ECT);
        end
        else
        begin
          //transaction is dissected but payee is not.
          trxPayeeDetail       := bkPayee.pdName;
          dPayeeDetail         := '';
          DissectionMatchesPayee := false;
        end;

        //the payee and dissection match so we can use the bk5 payee for
        //calculating the default gst for this line
        UseTransactionPayeeDetails := DissectionMatchesPayee;
      end;
    end;
  end;

  //GL Narration
  BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                          BKT^.txGL_Narration,
                                          trxPayeeDetail,
                                          ECT^.txNotes);
  //Notes
  UpdateNotes(BKT, ECT.txNotes);

  case ECT^.txCoded_By of
    cbManual      : BKT^.txCoded_By := bkconst.cbECodingManual;
    cbManualPayee : BKT^.txCoded_By := bkconst.cbECodingManualPayee;
  else
    BKT^.txCoded_By := ECT^.txCoded_By;
  end;

  //NOW IMPORT DISSECTION LINES
  ECD := ECT^.txFirst_Dissection;
  DissectionLineNo := 1;

  while ( ECD <> nil) do
  begin
    //create a new dissection line for the bk5 transaction
    BKD := bkdsio.New_Dissection_Rec;
    BKD.dsECoding_Import_Notes  := '';


    BKD.dsAmount            := ECD.dsAmount;
    BKD.dsAccount           := ECD.dsAccount;
    BKD.dsHas_Been_Edited   := ECD.dsHas_Been_Edited;
    BKD.dsPayee_Number      := 0;
    BKD.dsSF_Member_Account_ID:= -1;
    BKD.dsSF_Fund_ID          := -1;
    BKD.dsBank_Account        := BKT^.txBank_Account;
    BKD.dsTransaction         := BKT;

    //GST and Payee
    if UseTransactionPayeeDetails then
    begin
      //this flag is only set if the bk5 payee exists and it matches the
      //dissection
      //bkpayee will have been set above
      //payee will have been set OUTSIDE the dissection

      bkPayeeLine := bkPayee.pdLines.PayeeLine_At( DissectionLineNo - 1);

      BKD^.dsGST_Class  := bkPayeeLine.plGST_Class;
      BKD^.dsGST_Amount := CalculateGSTForClass( aClient, BKT^.txDate_Effective, BKD^.Local_Amount, BKD^.dsGST_Class);
      BKD^.dsGST_Has_Been_Edited := bkPayeeLine.plGST_Has_Been_Edited;

      //the payee was specified at the transaction level, the dissection
      //and the payee match so use the details from the payee for the
      //payee detail
      dPayeeDetail := bkPayee.pdLines.PayeeLine_At( DissectionLineNo - 1).plGL_Narration;
      // if blank then use payee name
      if Trim(dPayeeDetail) = '' then
        dPayeeDetail := bkPayee.pdName;
    end
    else
    begin
      //set gst information based on the chart
      //payee not found or dissection too long, use default gst
      //calculate gst using information from the chart codes
      CalculateGST( aClient, BKT^.txDate_Effective, BKD^.dsAccount, BKD^.Local_Amount, DefaultGSTClass, DefaultGSTAmount);
      BKD^.dsGST_Amount   := DefaultGSTAmount;
      BKD^.dsGST_Class    := DefaultGSTClass;
      BKD^.dsGST_Has_Been_Edited := False;
    end;

    //now see if the gst specified in bnotes is different
    //also add a note if gst is 0.00 in both places and trans is uncoded
    if (ECD^.dsGST_Has_Been_Edited) then
      if ( ECD^.dsGST_Amount <> BKD^.dsGST_Amount) or
         (( ECD^.dsGST_Amount = 0) and ( BKD^.dsAccount = ''))
      then
        AddToImportNotes( BKD, aClient.TaxSystemNameUC + ' Amount  ' + Money2Str( ECD^.dsGST_Amount), glConst.ECODING_APP_NAME);

    //Quantity
    BKD.dsQuantity          := ForceSignToMatchAmount( ECD.dsQuantity, BKD.dsAmount);

    ImportDissectionJob(ECT, ECFile, BKD, ECD, aClient);

    //Notes
    BKD.dsNotes             := ECD.dsNotes;

    //Narration
    BKD.dsGL_Narration      := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                                BKD.dsGL_Narration,
                                                dPayeeDetail,
                                                ECD.dsNotes);

    if ECFile.ecFields.ecSuper_Fund_System <> 0 then begin
       //Have a go..
       if (BKD^.dsSF_Franked <> ECD^.dsSF_Franked)
       or (BKD^.dsSF_UnFranked <> ECD^.dsSF_UnFranked)
       or (BKD^.dsSF_Imputed_Credit <> ECD^.dsSF_Franking_Credit) then begin
          BKT.txCoded_By := cbECodingManual;
          if (BKD^.dsSF_Franked = 0)
          and (BKD^.dsSF_UnFranked = 0)
          and (BKD^.dsSF_Imputed_Credit = 0) then begin
             // Hade nothing, just fill it in
             BKD^.dsSF_Franked        := ECD^.dsSF_Franked;
             BKD^.dsSF_UnFranked      := ECD^.dsSF_UnFranked;
             BKD^.dsSF_Imputed_Credit := ECD^.dsSF_Franking_Credit;

             BKD.dsSF_Super_Fields_Edited := True;

             if FrankingCredit(BKD^.dsSF_Franked, BKT^.txDate_Effective) <> BKD^.dsSF_Imputed_Credit  then begin
                  AddToImportNotes( BKD,'The franking credit amounts do not match the calculated amounts ''Franked: $' + Money2Str( BKd^.dsSF_Franked) +
                  ' Unfranked: $' +  Money2Str( BKD^.dsSF_UnFranked) +
                  ' Franking Credits: $' +  Money2Str( BKD^.dsSF_Imputed_Credit) + '''', glConst.ECODING_APP_NAME) ;
             end;
          end else begin
             // Just make a Note..
             AddToImportNotes( BKD,'Superfund ''Franked: $' + Money2Str( ECD^.dsSF_Franked) +
                  ' Unfranked: $' +  Money2Str( ECD^.dsSF_UnFranked) +
                  ' Franking Credits: $' +  Money2Str( ECD^.dsSF_Franking_Credit) + '''', glConst.ECODING_APP_NAME) ;
          end;
       end;
    end;
    //Add the new dissection to the transaction
    TrxList32.AppendDissection( BKT, BKD, aClient.ClientAuditMgr);
    ECD := ECD.dsNext;
    Inc( DissectionLineNo);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ImportNewDissection_DissectionLinePayees( ECT : ecDefs.pTRansaction_Rec;
                                      BKT   : bkDefs.pTransaction_Rec;
                                      ECFile : TECClient;
                                      aClient : TClientObj);
var
  bkPayee : PayeeObj.TPayee;
  bkPayeeLine : Bkdefs.pPayee_Line_Rec;
  ecPayee : EcPayeeObj.TEcPayee;
  //ecPayeeLine : ecDefs.pPayee_Line_Rec;
  BKD                : bkDefs.pDissection_Rec;
  ECD                : ecDefs.pDissection_Rec;
  DissectionLine     : ecDefs.pDissection_Rec;
  trxPayeeDetail     : string;
  dPayeeDetail       : string;  //detail for dissection line
  DefaultGSTClass    : byte;
  DefaultGSTAmount   : Money;
  UseBK5PayeeInformation : boolean;
  CurrentProcessingPayeeID : integer;
  LinesForCurrentPayee : integer;
  CurrentPayeeLine     : integer;
  i : integer;
begin
  //look through the dissection lines and try to match payee, match
  //on account and payee line no
  trxPayeeDetail       := '';
  dPayeeDetail         := '';

  //Dissect the BK5 transaction
  BKT.txAccount := DISSECT_DESC;
  ClearGSTFields( BKT);
  ClearSuperFundFields( BKT);
  UseBK5PayeeInformation := false;

  //Import Transaction Level Fields
  //Amount
  BKT.txAmount        := ECT.txAmount;
  BKT.txPayee_Number := 0;
  ImportTransactionJob(BKT, ECT, aClient, ECFile);
  BKT^.txGL_Narration := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                          BKT^.txGL_Narration,
                                          '',
                                          ECT^.txNotes);
  UpdateNotes(BKT, ECT.txNotes);
  BKT.txTax_Invoice_Available := ECT.txTax_Invoice_Available;

  case ECT^.txCoded_By of
    cbManual      : BKT^.txCoded_By := bkconst.cbECodingManual;
    cbManualPayee : BKT^.txCoded_By := bkconst.cbECodingManualPayee;
  else
    BKT^.txCoded_By := ECT^.txCoded_By;
  end;

  //NOW IMPORT DISSECTION LINES
  ECD := ECT^.txFirst_Dissection;
  CurrentProcessingPayeeID := 0;       //id of payee we are currently using
  CurrentPayeeLine := 0;               //line # in the payee detail
  LinesForCurrentPayee := 0;           //total # of lines in payee detail
  bkPayeeLine := nil;

  while ( ECD <> nil) do
  begin
    //create a new dissection line for the bk5 transaction
    BKD := bkdsio.New_Dissection_Rec;
    BKD.dsECoding_Import_Notes  := '';

    BKD.dsAmount := ECD.dsAmount;
    BKD.dsAccount := ECD.dsAccount;
    BKD.dsHas_Been_Edited := ECD.dsHas_Been_Edited;
    BKD.dsQuantity := ForceSignToMatchAmount( ECD.dsQuantity, BKD.dsAmount);
    BKD.dsNotes := ECD.dsNotes;
    BKD.dsSF_Member_Account_ID:= -1;
    BKD.dsSF_Fund_ID          := -1;
    BKD.dsBank_Account        := BKT^.txBank_Account;
    BKD.dsTransaction         := BKT;

    dPayeeDetail := '';

    //Payee
    if ( ECD^.dsPayee_Number <> 0) then
    begin
      //payee has been specified INSIDE the dissection
      ecPayee := ecFile.ecPayees.Find_Payee_Number( ECD^.dsPayee_Number);
      if ( Assigned( ecPayee) and ( ecPayee.pdFields.pdAdded_By_ECoding)) then
      begin
        AddToImportNotes( BKD, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
      end
      else
      begin
        bkPayee := aClient.clPayee_List.Find_Payee_Number( ECD^.dsPayee_Number);

        if not Assigned( bkPayee) then
        begin
          AddToImportNotes( BKD, UnknownPayeeMsg( ecPayee), glConst.ECODING_APP_NAME);
          UseBK5PayeeInformation := false;
        end
        else
        begin
          //payee # matches
          BKD.dsPayee_Number    := ECD.dsPayee_Number;
          BKD.dsHas_Been_Edited := True;

          //see if we are already coding using a payee
          if ( CurrentProcessingPayeeID <> ecd.dsPayee_Number) or ( CurrentPayeeLine > ( LinesForCurrentPayee - 1)) then
          begin
            //this is a new payee id, see if the following lines match
            //the structure of the payee in bk5
            CurrentProcessingPayeeID := bkPayee.pdFields.pdNumber;
            LinesForCurrentPayee := bkPayee.pdLinesCount;
            CurrentPayeeLine := 0;

            if LinesForCurrentPayee > 0 then
            begin
              DissectionLine := ECD;
              //see if next n lines match the bk5 payee
              i := 0;
              Repeat
                bkPayeeLine := bkPayee.pdLines.PayeeLine_At( i);
                UseBK5PayeeInformation := ( DissectionLine.dsAccount = bkPayeeLine.plAccount);
                DissectionLine := DissectionLine.dsNext;
                if DissectionLine <> nil then
                begin
                  Inc(i);
                end;
              Until ( i = LinesForCurrentPayee) or ( DissectionLine = nil) or ( not UseBK5PayeeInformation);

              //make sure there are enough dissection lines
              if ( i < (LinesForCurrentPayee - 1)) then
                UseBK5PayeeInformation := false;

              if not UseBK5PayeeInformation then
              begin
                LinesForCurrentPayee := 0;
                //bkPayeeLine := nil;
              end;
            end;
          end;

          if UseBK5PayeeInformation then
          begin
            bkPayeeLine := bkPayee.pdLines.PayeeLine_At( CurrentPayeeLine);
            Inc( CurrentPayeeLine);

            dPayeeDetail := bkPayeeLine.plGL_Narration;
          end
          else
            //payee doesnt match, just use the payee name for each line
            dPayeeDetail := bkPayee.pdFields.pdName;
        end;
      end;
    end
    else
    begin
      UseBK5PayeeInformation := false;
      bkPayeeLine := nil;
      dPayeeDetail := '';
    end;

    //gst
    if UseBK5PayeeInformation and Assigned( bkPayeeLine) then
    begin
      BKD^.dsGST_Class  := bkPayeeLine.plGST_Class;
      BKD^.dsGST_Amount := CalculateGSTForClass( aClient, BKT^.txDate_Effective, BKD^.Local_Amount, BKD^.dsGST_Class);
      BKD^.dsGST_Has_Been_Edited := bkPayeeLine.plGST_Has_Been_Edited;
    end
    else
    begin
      CalculateGST( aClient, BKT^.txDate_Effective, BKD^.dsAccount, BKD^.Local_Amount, DefaultGSTClass, DefaultGSTAmount);

      BKD^.dsGST_Amount   := DefaultGSTAmount;
      BKD^.dsGST_Class    := DefaultGSTClass;
      BKD^.dsGST_Has_Been_Edited := False;
    end;

    //now see if the gst specified in bnotes is different
    //also add a note if gst is 0.00 in both places and trans is uncoded
    if (ECD^.dsGST_Has_Been_Edited) then
      if ( ECD^.dsGST_Amount <> BKD^.dsGST_Amount) or
         (( ECD^.dsGST_Amount = 0) and ( BKD^.dsAccount = ''))
      then
        AddToImportNotes( BKD, aClient.TaxSystemNameUC + ' Amount  ' + Money2Str( ECD^.dsGST_Amount), glConst.ECODING_APP_NAME);

    ImportDissectionJob(ECT, ECfile, BKD, ECD, aClient);

    //Narration
    BKD.dsGL_Narration      := UpdateNarration( aClient.clFields.clECoding_Import_Options,
                                                BKD.dsGL_Narration, dPayeeDetail, ECD.dsNotes);

    if ECFile.ecFields.ecSuper_Fund_System <> 0 then begin
       //Have a go..
       if (BKD^.dsSF_Franked <> ECD^.dsSF_Franked)
       or (BKD^.dsSF_UnFranked <> ECD^.dsSF_UnFranked)
       or (BKD^.dsSF_Imputed_Credit <> ECD^.dsSF_Franking_Credit) then begin
          BKT.txCoded_By := cbECodingManual;
          if (BKD^.dsSF_Franked = 0)
          and (BKD^.dsSF_UnFranked = 0)
          and (BKD^.dsSF_Imputed_Credit = 0) then begin
             // Had nothing, just fill it in
             BKD^.dsSF_Franked        := ECD^.dsSF_Franked;
             BKD^.dsSF_UnFranked      := ECD^.dsSF_UnFranked;
             BKD^.dsSF_Imputed_Credit := ECD^.dsSF_Franking_Credit;

             BKD.dsSF_Super_Fields_Edited := True;
             if FrankingCredit(BKD^.dsSF_Franked, BKT^.txDate_Effective) <> BKD^.dsSF_Imputed_Credit  then begin
                  AddToImportNotes( BKD,'The franking credit amounts do not match the calculated amounts ''Franked: $' + Money2Str( BKd^.dsSF_Franked) +
                  ' Unfranked: $' +  Money2Str( BKD^.dsSF_UnFranked) +
                  ' Franking Credits: $' +  Money2Str( BKD^.dsSF_Imputed_Credit) + '''', glConst.ECODING_APP_NAME) ;
             end;
          end else begin
             // Just make a Note..
              AddToImportNotes( BKD,'Superfund ''Franked: $' + Money2Str( ECD^.dsSF_Franked) +
                  ' Unfranked: $' +  Money2Str( ECD^.dsSF_UnFranked) +
                  ' Franking Credits: $' +  Money2Str( ECD^.dsSF_Franking_Credit) + '''', glConst.ECODING_APP_NAME) ;
          end;
       end;
    end;
    //Add the new dissection to the transaction
    TrxList32.AppendDissection( BKT, BKD, aClient.ClientAuditMgr);
    ECD := ECD.dsNext;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DissectionsMatch( T : BKDEFS.pTransaction_Rec; ECT : ECDEFS.pTransaction_Rec) : boolean;
//returns true if the dissection lines match
//a match is determined by both transactions having the same no of dissect lines
//the account and amount must match for each of these lines
var
  D      : BKDEFS.pDissection_Rec;
  ECD    : ECDEFS.pDissection_Rec;
begin
  result := false;
  //same number of lines, codes and amount match
  D      := T.txFirst_Dissection;
  ECD    := ECT.txFirst_Dissection;

  while ( D <> nil) and ( ECD <> nil) do
  begin
     if D^.dsAccount <> ECD^.dsAccount then
       exit;
     if D.dsAmount  <> ECD.dsAmount  then
       exit;

     D := D.dsNext;
     ECD := ECD.dsNext;
  end;

  if not (( ECD = nil) and ( D = nil)) then
     exit;

  result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ImportDissectedTransaction( ECT : ecDefs.pTRansaction_Rec;
                                      BKT   : bkDefs.pTransaction_Rec;
                                      ECFile : TECClient;
                                      aClient : TClientObj;
                                      BA: TBank_Account);
const
  dplNone = 0;
  dplAtTransaction = 1;
  dplWithinDissection = 2;
var
  ECD                   : ecDefs.pDissection_Rec;
  ExportToNotesRequired : Boolean;
  DissectionPayeeLevel  : byte;
  ExchangeRate: double;
begin
  //we first need to check if the transaction can be imported at all,
  //or if we should just export the transaction to the notes field.
  ExportToNotesRequired    := false;

  //if the transaction is dissected then both dissections must match before
  //importing
  if ( BKT^.txFirst_Dissection <> nil) and ( not DissectionsMatch( BKT, ECT)) then
    ExportToNotesRequired := true;

  //if the transaction is not dissected we need some further tests
  if ( BKT^.txFirst_Dissection = nil) then
  begin
    //if bk5 tranasction is coded then export
    if BKT^.txAccount <> '' then
      ExportToNotesRequired := true;

    //if transaction amounts are different then dissection will not balance
    if ( BKT^.txAmount <> ECT^.txAmount) then
    begin
      //must be a upc/upd
      if not ( BKT.txUPI_State in [ upUPC, upUPD, upUPW]) then
        ExportToNotesRequired := true;

      //if the bk5 amount is non zero then export to notes
      if BKT^.txAmount <> 0 then
        ExportToNotesRequired := true;
    end;
  end;

  if ExportToNotesRequired then
  begin
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 3   BNotes (D)   BK5 ( D)  - Dissections don't match
    //CASE 4   BNotes (D)   BK5 ( ND) - TrxAmount different
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ExportDissectionLinesToNotes( EcFile, BKT, ECT);
    UpdateNotes(BKT, ECT.txNotes);

    Exit;
  end;

  //Convert VAT amount from forex to base for forex bank accounts
  if ba.IsAForexAccount then begin
    //If the exchange rate is zero then flag GST as edited so that it is
    //added as a note.
    ExchangeRate := BKT.Default_Forex_Rate;
    if (ExchangeRate <> 0) then
      ECT.txGST_Amount := (ECT.txGST_Amount / ExchangeRate)
    else
      ECT.txGST_Has_Been_Edited := True;
    ECD := ECT^.txFirst_Dissection;
    while ( ECD <> nil) do begin
      if (ExchangeRate <> 0) then
        ECD.dsGST_Amount :=  (ECD.dsGST_Amount / ExchangeRate);
      ECD := ECD.dsNext;
    end;
  end;

  if BKT^.txFirst_Dissection <> nil then
  begin
    //both transactions are dissected, test for match has been done
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 5 - BNotes (D)  BK5 (D) - Dissections Match
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    ImportExistingDissection( ECT, BKT, ECFile, aClient);
  end
  else
  begin
    //bk5 tranaction is not coded, code from dissection bnotes transaction
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -
    //CASE 6 - BNotes (D)  BK5 (NC)
    // - - - - - - - - - - - - - - - - - - - - - - - - - - -

    //it is easier to split this into three cases because of the complexity
    //introduced by payees

    //case 6a - The BNotes dissection does not contain any payee coding
    //case 6b - The dissection has been coded via a payee at the trans level
    //case 6c - The dissection has lines with payees codes

    //look for payees in the bnotes dissection
    DissectionPayeeLevel := dplNone;

    if ECT.txPayee_Number <> 0 then
      DissectionPayeeLevel := dplAtTransaction
    else
    begin
      ECD := ECT^.txFirst_Dissection;
      while ( ECD <> nil) do
      begin
        if ECD.dsPayee_Number <> 0 then
        begin
          ECD := nil;
          DissectionPayeeLevel := dplWithinDissection;
        end
        else
          ECD := ECD.dsNext;
      end;
    end;

    //CASE 6a - no payee
    if DissectionPayeeLevel = dplNone then
    begin
      ImportNewDissection_NoPayees( ECT, BKT, aClient,ecFile);
    end;

    //case 6b - Payee specified at transaction level
    if DissectionPayeeLevel = dplAtTransaction then
    begin
      ImportNewDissection_TransactionLevelPayee( ECT, BKT, aClient, ecFile);
    end;

    //CASE 6c
    if DissectionPayeeLevel = dplWithinDissection then
    begin
      ImportNewDissection_DissectionLinePayees( ECT, BKT, ecFile, aClient);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ImportNewTransaction( ECT : ecDefs.pTransaction_Rec;
                                ECFile : TECClient;
                                aClient : TClientObj;
                                bkBank : TBank_Account);
var
  BKT          : bkdefs.pTransaction_Rec;
  Prefix       : string;
begin
  //no matching bk5 transaction found
  //
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //CASE 7 - New Transaction, code from BNotes
  // - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if ECT^.txUPI_State in [ upUPD, upUPC, upUPW] then
  begin
    //determine if the UPC matches an existing bk5 transaction
    //the transaction may have been downloaded since, or already imported from
    //this bnotes file

    //set up a new blank transaction, fill cheque details
    BKT := bktxio.New_Transaction_Rec;

    //set up the new transaction
    BKT^.txType               := ECT^.txType;
    BKT.txSource              := orGenerated;
    BKT.txDate_Presented      := 0;
    BKT.txDate_Effective      := ECT.txDate_Effective;
    BKT.txCheque_Number       := ECT.txCheque_Number;
    BKT.txReference           := ECT.txReference;
    BKT.txUPI_State           := ECT.txUPI_State;
    BKT.txBank_Seq            := bkBank.baFields.baNumber;
    BKT.txSF_Member_Account_ID:= -1;
    BKT.txSF_Fund_ID          := -1;

    bkBank.baTransaction_List.Insert_Transaction_Rec( BKT);
  end;

  //now use standard routines to import the transaction
  if Assigned( BKT) then
  begin
    if ECT.txFirst_Dissection = nil then
    begin
      Prefix := Copy( bkBank.baFields.baBank_Account_Number, 1, 2);
      ImportStandardTransaction( ECT, BKT, ECFile, aClient, Prefix, bkBank);
    end
    else
      ImportDissectedTransaction( ECT, BKT, ECFile, aClient, bkBank);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ProcessBNotesFile( ECFile : TECClient; aClient : TClientObj; var ImportedCount, NewCount, RejectedCount : integer);
//this routine actually does the importing from the bnotes file
var
  acNo             : integer;
  TNo              : integer;
  BKTNo            : integer;
  ba               : TBank_Account;
  ecBA             : TECBank_Account;
  TempT            : bkdefs.pTransaction_Rec;
  T                : bkdefs.pTransaction_Rec;
  ECT              : ecdefs.pTransaction_Rec;
  EMsg             : string;
//  FileComments     : string;
//  StartPos         : integer;
//  i                : integer;
  S                : string;
begin
  //initialise counters
  RejectedCount     := 0;
  NewCount          := 0;
  ImportedCount     := 0;

  //cycle through each bank account in the bnotes file and find the matching
  //bk5 file
  for acNo := 0 to ECFile.ecBankAccounts.Last do
  begin
    ecBa := ECFile.ecBankAccounts.Bank_Account_At( acNo);
    ba   := aClient.clBank_Account_List.FindCode( ecBa.baFields.baBank_Account_Number);

    if Assigned( Ba) then
    begin
      //Matching BK5 account found, so import transactions
      for TNo := 0 to ecBa.baTransaction_List.Last do
      begin
        T := nil;

        ECT := ecBa.baTransaction_List.Transaction_At( TNo);
        if ECT.txECoding_ID = 0 then
        begin
          if ValidateNewTransaction(ECFile,  ECT, aClient, Ba, EMsg, T) then
          begin
            if not Assigned( T) then
            begin
              //new transaction
              ImportNewTransaction( ECT, ECFile, aClient, Ba);
              Inc( NewCount);
            end;
            //if T is assigned then a match was found during the verify process
            //this can then be processed using the standard import routines
          end
          else
            Inc( RejectedCount);
        end
        else
        begin
          //Find the matching BK5 transaction
          T := nil;
          for BKTNo := 0 to ba.baTransaction_List.Last do
          begin
            TempT := ba.baTransaction_List.Transaction_At( BKTNo);
            if TempT^.txECoding_Transaction_UID = ECT^.txECoding_ID then
            begin
              T := TempT;
              Break;
            end;
          end;
        end;

        //check that transaction is valid and import it
        if Assigned( T) then
        begin
          if ValidateTransactionForImport( ECT, T, EMsg) then
          begin
            T^.txECoding_Import_Notes := '';
            S := Copy( Ba.baFields.baBank_Account_Number, 1, 2);
            //the way we import the transaction depends on whether or not the transaction
            //is dissected in bnotes
            if ECT^.txFirst_Dissection = nil then
              ImportStandardTransaction( ECT, T,
                                         ECFile, aClient,
                                         S, ba)
            else
              ImportDissectedTransaction( ECT, T,
                                          ECFile, aClient, ba);

            Inc( ImportedCount);
          end
          else
          begin
            Inc( RejectedCount);
          end;
        end;
      end;  //transaction loop
    end;
  end; // bank account loop

  //update bnotes setting that are stored in BK5
  aClient.clFields.clECoding_Last_File_No_Imported := ECFile.ecFields.ecFile_Number;
  aClient.clFields.clECoding_Default_Password      := ecFile.ecFields.ecFile_Password;

  //reimport file notes
//  FileComments := ecFile.ecFields.ecNotes;
//  StartPos     := 1;
//  for i := Low( aClient.clFields.clNotes) to High( aClient.clFields.clNotes) do begin
//    S := Copy( FileComments, StartPos, 100);
//    if S = '' then break;
//    aClient.clFields.clNotes[ i] := S;
//    StartPos := StartPos + 100;
//  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

