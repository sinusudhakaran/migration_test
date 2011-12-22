unit bkHelpers;

interface

uses bkDefs;

function GetClient_RecFields: string;
function GetClient_RecValues(MyId: TGuid;
                             UserID: TGuid;
                             AccountingSystemID: TGuid;
                             TaxSystemID: TGuid;
                             GroupID: TGuid;
                             TypeID: TGuid;
                             WebExportFormat: TGuid;
                             Archived: Boolean;
                             Value: pClient_Rec;
                             More: pMoreClient_Rec;
                             Extra: pClientExtra_Rec): string;


function GetAccount_RecFields: string;
function GetAccount_RecValues(MyID: TGuid;
                              ClientID: TGuid;
                              Value: pBank_Account_Rec): string;


function GetTransaction_RecFields(SFFields: Boolean = false): string;
function GetTransaction_RecValues(
                            MyID: TGuid;
                            AccountID: TGuid;
                            Value: PTransaction_Rec;
                            SFFields: Boolean = false): string;

function GetMemorisation_Detail_RecFields: string;
function GetMemorisation_Detail_RecValues(
                            MyID: TGuid;
                            AccountID: TGuid;
                            AccountingSystemID: TGuid;
                            Value: pMemorisation_Detail_Rec): string;

function GetMemorisation_Line_RecFields(SFFields: Boolean = false): string;
function GetMemorisation_Line_RecValues(
                            MyID: TGuid;
                            MemorisationID: TGuid;
                            SequenceNo: Integer;
                            Value: pMemorisation_Line_Rec;
                            SFFields: Boolean = false): string;


function GetDissection_RecFields(SFFields: Boolean = false): string;
function GetDissection_RecValues(
                            MyID: TGuid;
                            TransactionID: TGuid;
                            Value: PDissection_Rec;
                            SFFields: Boolean = false): string;

function GetChart_RecFields: string;
function GetChart_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pAccount_Rec;
                            SFFields: Boolean = false): string;

function GetCustom_Heading_RecFields: string;
function GetCustom_Heading_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pCustom_Heading_Rec): string;


function GetPayee_Detail_RecFields: string;
function GetPayee_Detail_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pPayee_Detail_Rec): string;

function GetPayee_Line_RecFields(SFFields: Boolean = false): string;
function GetPayee_Line_RecValues(
                            SequenceNo: Integer;
                            MyID: TGuid;
                            PayeeID: TGuid;
                            Value: pPayee_Line_Rec;
                            SFFields: Boolean = false): string;

function GetJob_Heading_RecFields: string;
function GetJob_Heading_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pJob_Heading_Rec): string;

function GetBudget_Header_RecFields: string;
function GetBudget_Header_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pBudget_Header_Rec): string;

function GetBudget_Detail_RecFields: string;
function GetBudget_Detail_RecValues(
                            MyID: TGuid;
                            BudgetID: TGuid;
                            Period: Integer;
                            Value: pBudget_Detail_Rec): string;



implementation

uses SysUtils, SQLHelpers, bkConst, MoneyDef;


//*************************************  CLIENT ********************************

function GetClient_RecFields: string;
begin
result := '[Id],[Code],[Name],[AddressL1],[AddressL2],[AddressL3],[ContactName],[PhoneNo],[FaxNo],[EmailAddress]'
{2}     + ',[Country],[BankLinkConnectPassword],[PINNumber],[FinancialYearStarts]'
{3}     + ',[SendChartOfAccounts],[SendUnpresentedChequeList],[SendPayeeList],[SendPayeeReport]'
{4}     + ',[GSTNumber],[GSTPeriod],[GSTStartMonth],[GSTBasis],[GSTOnPresentationDate],[GSTExcludesAccruals],[GSTInclusiveCashflow]'
{5}     + ',[AccountingSystemUsed],[AccountCodeMask],[LoadClientFilesFrom],[SaveClientFilesTo],[ChartIsLocked],[ChartLastUpdated]'
{6}     + ',[MagicNumber],[ExceptionOptions],[PeriodStartDate],[PeriodEndDate],[BankLinkCode]'
{7}     + ',[DiskSequenceNo],[StaffMemberId],[SuppressCheckForNewTXns],[DownloadFrom],[LastBatchNumber]'
{8}     + ',[TaxLedgerCode],[ChequesExpireWhen],[ShowNotesOnOpen]'
{9}     + ',[CflwCashOnHandStyle],[LastFinancialYearStart],[TaxinterfaceUsed],[SaveTaxFilesTo],[JournalProcessingPeriod],[LastDiskImageVersion]'
{10}    + ',[WebSiteLoginURL],[ContactDetailsToShow],[CustomContactName],[CustomContactEMailAddress],[CustomContactPhone]'
{11}    + ',[HighestManualAccountNo],[CopyNarrationDissection]'
{12}    + ',[ClientCCEMailAddress],[LastECodingAccountUID],[WebExportFormat],[MobileNo],[FileReadOnly],[Salutation],[ExternalID]'
{13}    + ',[ForceOffsiteCheckOut],[DisableOffsiteCheckOut],[AlternateExtractID],[UseAlterateIDforextract]'
{14}    + ',[LastUseDate],[UseBasicChart],[ClientGroupId],[ClientTypeId],[AllEditModeCES],[AllEditModeDIS],[TFN]'
{15}    + ',[AllowClientUnlockEntries],[AllowClientEditChart],[ScheduledCustomCRXML],[BudgetIncludeQuantities],[ScheduledCRColumnLine],[Archived]'
{16}    + ',[JournalProcessingDuration],[GSTIncludeProvisionalTax],[GSTUseRatioOption],[GSTRatio]'
{17}    + ',[Comments],[GenerateFinancialReports],[EditMemorisations],[Password],[IsCheckedOut]'
end;


function GetClient_RecValues(MyId: TGuid;
                             UserID: TGuid;
                             AccountingSystemID: TGuid;
                             TaxSystemID: TGuid;
                             GroupID: TGuid;
                             TypeID: TGuid;
                             WebExportFormat: TGuid;
                             Archived: Boolean;
                             Value: pClient_Rec;
                             More: pMoreClient_Rec;
                             Extra: pClientExtra_Rec): string;
       function GetNotes: string;
       var I: Integer;
       begin
          Result := '';
          for i := Low( Value.clNotes) to High( Value.clNotes) do
             Result := Result + Value.clNotes[i];
       end;

       function GetGSTRatio: Money;
       begin
          if (Value.clBAS_Field_Source[bfGSTProvisional] = GSTprovisional)
          and (Value.clBAS_Field_Number[bfGSTProvisional] = GSTRatio) then
             Result := Value.clBAS_Field_Percent[bfGSTProvisional] * 1000 // seems in one decimal place ??
          else
             Result := Unknown;
       end;

begin with Value^, Extra^, More^ do
     Result := ToSQL(MyId) + ToSQL(clCode) + ToSQL(clName) + ToSQL(clAddress_L1) + ToSQL(clAddress_L2) + ToSQL(clAddress_L3)
                + ToSQL(clContact_Name) + ToSQL(clPhone_No) + ToSQL(clFax_No) + ToSQL(clClient_EMail_Address)
{2}         + ToSQL(clCountry) + ToSQL(clBankLink_Connect_Password) + ToSQL(clPIN_Number) + DateToSQL(clFinancial_Year_Starts)
{3}         + ToSQL(clSend_Chart_of_Accounts) + ToSQL(clSend_Unpresented_Cheque_List) + ToSQL(clSend_Payee_List) + ToSQL(clSend_Payee_Report)
{4}         + ToSQL(clGST_Number) + ToSQL(clGST_Period) + ToSQL(clGST_Start_Month) + ToSQL(clGST_Basis)
               + ToSQL(clGST_on_Presentation_Date) + ToSQL(clGST_Excludes_Accruals) + ToSQL(clGST_Inclusive_Cashflow)
{5}         + ToSQL(AccountingSystemID) + ToSQL(clAccount_Code_Mask) + ToSQL(clLoad_Client_Files_From) + ToSQL(clSave_Client_Files_To)
                + ToSQL(clChart_Is_Locked) + DateToSQL(clChart_Last_Updated)
{6}         + ToSQL(clMagic_Number) + ToSQL(clException_Options) + DateToSQL(clPeriod_Start_Date) + DateToSQL(clPeriod_End_Date) + ToSQL(clBankLink_Code)
{7}         + ToSQL(clDisk_Sequence_No) + ToSQL(UserID) + ToSQL(clSuppress_Check_for_New_TXns) + ToSQL(clDownload_From) + ToSQL(clLast_Batch_Number)
{8}         + ToSQL(clTax_Ledger_Code) + ToSQL(clCheques_Expire_When) + ToSQL(clShow_Notes_On_Open)
{9}         + ToSQL(clCflw_Cash_On_Hand_Style) +  DateToSQL(clLast_Financial_Year_Start) + ToSQL(TaxSystemID) + ToSQL(clSave_Tax_Files_To)
               + ToSQL(clJournal_Processing_Period) + ToSQL(clLast_Disk_Image_Version)
{10}        + ToSQL(clWeb_Site_Login_URL) + ToSQL(clContact_Details_To_Show) + ToSQL(clCustom_Contact_Name)
               + ToSQL(clCustom_Contact_EMail_Address) + ToSQL(clCustom_Contact_Phone)
{11}        + ToSQL(clHighest_Manual_Account_No) + ToSQL(clCopy_Narration_Dissection)
{12}        + ToSQL(clClient_CC_EMail_Address) + ToSQL(clLast_ECoding_Account_UID) + ToSQL(WebExportFormat) + ToSQL(clMobile_No)
               + ToSQL(clFile_Read_Only) + ToSQL(clSalutation) + ToSQL(clExternal_ID)
{13}        + ToSQL( clForce_Offsite_Check_Out) + ToSQL(clDisable_Offsite_Check_Out) + ToSQL(clAlternate_Extract_ID) + ToSQL(clUse_Alterate_ID_for_extract)
{14}        + DateToSQL(clLast_Use_Date) + ToSQL(clUse_Basic_Chart) + ToSQL(GroupID) + ToSQL(TypeID)
               + ToSQL(clAll_EditMode_CES) + ToSQL(clAll_EditMode_DIS) + ToSQL(clTFN)
{15}        +  ToSql(ceAllow_Client_Unlock_Entries) + ToSQL(ceAllow_Client_Edit_Chart) + ToSQL(ceScheduled_Custom_CR_XML)
               + ToSQL(ceBudget_Include_Quantities) + ToSQL(ceScheduled_CR_Column_Line) + ToSQL(Archived)
{16}        +  ToSQL(mcJournal_Processing_Duration) + ToSQL( clBAS_Field_Source[bfGSTProvisional] = GSTprovisional)
               + ToSql(clBAS_Field_Number[bfGSTProvisional] = GSTRatio) + PercentToSQL(GetGSTRatio)
{17}        +  ToSQL(GetNotes) + ToSQL(ceBook_Gen_Finance_Reports) + ToSQL(not ceBlock_Client_Edit_Mems) + ToSQL(clFile_Password, False);
end;


//*************************************  Bank account ********************************


function GetAccount_RecFields: string;
begin
 Result := '[Id],[ClientId],[BankAccountNumber],[BankAccountName],[BankAccountPassword],[ContraAccountCode]'
 {2}    +  ',[CurrentBalance],[ApplyMasterMemorisedEntries],[AccountType],[PreferredView],[HighestBankLink_ID]'
 {3}    +  ',[HighestLRN],[AccountExpiry_Date],[HighestMatchedItemID],[NotesAlwaysVisible],[NotesHeight],[LastECodingTransactionUID]'
 {4}    +  ',[ExtendExpiryDate],[IsAManualAccount],[AnalysisCodingLevel],[ECodingAccountUID],[CodingSortOrder],[ManualAccountType]'
 {5}    +  ',[ManualAccountInstitution],[ManualAccountSentToAdmin],[HDESortOrder],[MDESortOrder],[DISSortOrder]'
 {6}    +  ',[DesktopSuperLedgerID],[Currency]';

end;

function GetAccount_RecValues(MyID: TGuid;
                              ClientID: TGuid;
                              Value: pBank_Account_Rec): string;
begin with value^ do
   Result := ToSQL(MyId) + ToSQL(ClientID) + ToSQL(baBank_Account_Number) + ToSQL(baBank_Account_Name)
               + ToSQL(baBank_Account_Password) + ToSQL(baContra_Account_Code)
 {2}      + ToSQL(baCurrent_Balance) + ToSQL(baApply_Master_Memorised_Entries) + ToSQL(baAccount_Type)
               + ToSQL(baPreferred_View) + ToSQL(baHighest_BankLink_ID)
 {3}      + ToSQL(baHighest_LRN) + DateToSQL(baAccount_Expiry_Date) + ToSQL(baHighest_Matched_Item_ID)
               + ToSQL(baNotes_Always_Visible) + TOSQL(baNotes_Height) + ToSQL(baLast_ECoding_Transaction_UID)
 {4}      + ToSQL(baExtend_Expiry_Date) + ToSQL(baIs_A_Manual_Account) + ToSQL(baAnalysis_Coding_Level)
               + ToSQL(baECoding_Account_UID) + ToSQL(baCoding_Sort_Order) + ToSQL(baManual_Account_Type)
 {5}      + ToSQL(baManual_Account_Institution) + ToSQL(baManual_Account_Sent_To_Admin)
               + ToSQL(baHDE_Sort_Order) + ToSQL(baMDE_Sort_Order) + ToSQL(baDIS_Sort_Order)
 {6}      + ToSQL(baDesktop_Super_Ledger_ID) + ToSql(baCurrency_Code, false);
end;                              


//************************************* TRANSACTION ********************************

function GetTransaction_RecFields(SFFields: Boolean = false): string;
begin
   Result := '[Id],[BankAccount_Id],[SequenceNo],[Type],[Source],[DatePresented],[DateEffective]'
{2}       + ',[DateTransferred],[Amount],[GSTClass],[GSTAmount],[HasBeenEdited],[Quantity],[ChequeNumber]'
{3}       + ',[Reference],[Particulars],[Analysis],[OrigBB],[OtherParty],[Account],[CodedBy]'
{4}       + ',[PayeeNumber],[Locked],[BankLinkID],[GSTHasBeenEdited],[MatchedItemID],[UPIState],[OriginalReference]'
{5}       + ',[OriginalSource],[OriginalType],[OriginalChequeNumber],[OriginalAmount],[Notes],[ECodingImportNotes]'
{6}       + ',[ECodingTransactionUID],[GLNarration],[StatementDetails] ,[TaxInvoiceAvailable]'
{7}       + ',[ExternalGUID],[DocumentTitle],[JobCode]'
{8}       + ',[DocumentStatusUpdateRequired],[BankLinkUID],[NotesRead],[ImportNotesRead]';

   if SFFields then
   Result := Result
{1}       + ',[SFFranked],[SFUnfranked],[SFinterest],[SFCapitalGainsForeignDisc],[SFRent]'
{2}       + ',[SFSpecialIncome],[SFOtherTaxCredit],[SFNonResidentTax],[SFMemberID]'
{3}       + ',[SFForeignCapitalGainsCredit],[SFMemberComponent],[SFFundID],[SFMemberAccountID]'
{4}       + ',[SFFundCode],[SFMemberAccountCode],[SFTransactionID],[SFTransactionCode],[SFCapitalGainsFractionHalf]'
{5}       + ',[SFImputedCredit],[SFCapitalGainsOther],[SFOtherExpenses],[SFCGTDate]'
{6}       + ',[SFTaxFreeDist],[SFTaxExemptDist],[SFTaxDeferredDist],[SFTFNCredits],[SFForeignIncome]'
{7}       + ',[SFForeignTaxCredits],[SFCapitalGainsIndexed],[SFCapitalGainsDisc],[SFSuperFieldsEdited]';


end;


function GetTransaction_RecValues(
                            MyID: TGuid;
                            AccountID: TGuid;
                            Value: PTransaction_Rec;
                            SFFields: Boolean = false): string;
begin  with Value^ do
    Result := ToSQL(MyId) + ToSQL(AccountID) + ToSQL(txSequence_No)
                   + ToSQL(txType) + ToSQL(txSource) + DateToSQL(txDate_Presented) + DateToSQL(txDate_Effective)
{2}        + ToSQL(txDate_Transferred) + ToSQL(txAmount)  + ToSQL(txGST_Class) + ToSQL(txGST_Amount)
                   + ToSQL(txHas_Been_Edited) + QtyToSQL(txQuantity) + ToSQL(txCheque_Number)
{3}        + ToSQL(txReference) + ToSQL(txParticulars) + ToSQL(txAnalysis)+ ToSQL(txOrigBB)+ ToSQL(txOther_Party)
                   + ToSQL(txAccount)+ ToSQL(txCoded_By)
{4}        + ToSQL(txPayee_Number) + ToSQL(txLocked) + ToSQL(txBankLink_ID) + ToSQL(txGST_Has_Been_Edited)
                   + ToSQL(txMatched_Item_ID)+ ToSQL(txUPI_State)+ ToSQL(txOriginal_Reference)
{5}        + ToSQL(txOriginal_Source) + ToSQL(txOriginal_Type) + ToSQL(txOriginal_Cheque_Number) + ToSQL(txOriginal_Amount)
                   + ToSQL(txNotes) + ToSQL(txECoding_Import_Notes)
{6}        + ToSQL(txECoding_Transaction_UID) + ToSQL(txGL_Narration)+ ToSQL(txStatement_Details)+ ToSQL(txTax_Invoice_Available)
{7}        + ToSQL(txExternal_GUID) + ToSQl(txDocument_Title) + ToSQL(txJob_Code)
{8}        + ToSQL(txDocument_Status_Update_Required) + ToSQL(txBankLink_UID) + ToSQL(txNotes_Read) + ToSQL(txImport_Notes_Read, SFFields);

 if SFFields then with Value^ do
   Result := Result + ToSQL(txSF_Franked) + ToSQL(txSF_Unfranked) + ToSQL(txSF_Interest)
               + ToSQL(txSF_Capital_Gains_Foreign_Disc) + ToSQL(txSF_Rent)
{2}        + ToSQL(txSF_Special_Income) + ToSQL(txSF_Other_Tax_Credit) + ToSQL(txSF_Non_Resident_Tax)
               + ToSQL(txSF_Member_ID)
{3}        + ToSQL(txSF_Foreign_Capital_Gains_Credit) + ToSQL(txSF_Member_Component) + ToSQL(txSF_Fund_ID)
               + ToSQL(txSF_Member_Account_ID)
{4}        + ToSQL(txSF_Fund_Code) + ToSQL(txSF_Member_Account_Code) + ToSQL(txSF_Transaction_ID) + ToSQL(txSF_Transaction_Code)
               + ToSQL(txSF_Capital_Gains_Fraction_Half)
{5}        + ToSQL(txSF_Imputed_Credit) + ToSQL(txSF_Capital_Gains_Other) + ToSQL(txSF_Other_Expenses)
               + DateToSQL(txSF_CGT_Date)
{6}        + ToSQL(txSF_Tax_Free_Dist) + ToSQL(txSF_Tax_Exempt_Dist) + ToSQL(txSF_Tax_Deferred_Dist)
               + ToSQL(txSF_TFN_Credits) + ToSQL(txSF_Foreign_Income)
{7}        + ToSQL(txSF_Foreign_Tax_Credits) + ToSQL(txSF_Capital_Gains_Indexed) 
               + ToSQL(Value.txSF_Capital_Gains_Disc) +ToSQL(txSF_Super_Fields_Edited, false);

end;


//************************************* Dissection ********************************



function GetDissection_RecFields(SFFields: Boolean = false): string;
begin
   Result := '[Id],[Transaction_Id],[SequenceNo]'
{2}       + ',[Amount],[GSTClass],[GSTAmount],[HasBeenEdited],[Quantity],[Reference]'
{3}       + ',[Account],[PayeeNumber],[GSTHasBeenEdited]'
{4}       + ',[Notes],[ECodingImportNotes],[GLNarration],[TaxInvoice]'
{5}       + ',[ExternalGUID],[DocumentTitle],[JobCode]'
{6}       + ',[DocumentStatusUpdateRequired],[NotesRead],[ImportNotesRead]';

   if SFFields then
   Result := Result
{1}       + ',[SFFranked],[SFUnfranked],[SFinterest],[SFCapitalGainsForeignDisc],[SFRent]'
{2}       + ',[SFSpecialIncome],[SFOtherTaxCredit],[SFNonResidentTax],[SFMemberID]'
{3}       + ',[SFForeignCapitalGainsCredit],[SFMemberComponent],[SFFundID],[SFMemberAccountID]'
{4}       + ',[SFFundCode],[SFMemberAccountCode],[SFTransactionID],[SFTransactionCode],[SFCapitalGainsFractionHalf]'
{5}       + ',[SFImputedCredit],[SFCapitalGainsOther],[SFOtherExpenses],[SFCGTDate]'
{6}       + ',[SFTaxFreeDist],[SFTaxExemptDist],[SFTaxDeferredDist],[SFTFNCredits],[SFForeignIncome]'
{7}       + ',[SFForeignTaxCredits],[SFCapitalGainsIndexed],[SFCapitalGainsDisc],[SFSuperFieldsEdited]';


end;


function GetDissection_RecValues(
                            MyID: TGuid;
                            TransactionID: TGuid;
                            Value: PDissection_Rec;
                            SFFields: Boolean = false): string;
begin  with Value^ do
    Result := ToSQL(MyId) + ToSQL(TransactionID) + ToSQL(dsSequence_No)
{2}        + ToSQL(dsAmount)  + ToSQL(dsGST_Class) + ToSQL(dsGST_Amount)
                   + ToSQL(dsHas_Been_Edited) + QtyToSQL(dsQuantity) + ToSQL(dsReference)
{3}        + ToSQL(dsAccount) + ToSQL(dsPayee_Number) + ToSQL(dsGST_Has_Been_Edited)
{4}        + ToSQL(dsNotes) + ToSQL(dsECoding_Import_Notes) + ToSQL(dsGL_Narration)+ ToSQL(dsTax_Invoice)
{5}        + ToSQL(dsExternal_GUID) + ToSQl(dsDocument_Title) + ToSQL(dsJob_Code)
{8}        + ToSQL(dsDocument_Status_Update_Required) + ToSQL(dsNotes_Read) + ToSQL(dsImport_Notes_Read, SFFields);

 if SFFields then with Value^ do
   Result := Result + ToSQL(dsSF_Franked) + ToSQL(dsSF_Unfranked) + ToSQL(dsSF_Interest)
               + ToSQL(dsSF_Capital_Gains_Foreign_Disc) + ToSQL(dsSF_Rent)
{2}        + ToSQL(dsSF_Special_Income) + ToSQL(dsSF_Other_Tax_Credit) + ToSQL(dsSF_Non_Resident_Tax)
               + ToSQL(dsSF_Member_ID)
{3}        + ToSQL(dsSF_Foreign_Capital_Gains_Credit) + ToSQL(dsSF_Member_Component) + ToSQL(dsSF_Fund_ID)
               + ToSQL(dsSF_Member_Account_ID)
{4}        + ToSQL(dsSF_Fund_Code) + ToSQL(dsSF_Member_Account_Code) + ToSQL(dsSF_Transaction_ID) + ToSQL(dsSF_Transaction_Code)
               + ToSQL(dsSF_Capital_Gains_Fraction_Half)
{5}        + ToSQL(dsSF_Imputed_Credit) + ToSQL(dsSF_Capital_Gains_Other) + ToSQL(dsSF_Other_Expenses)
               + DateToSQL(dsSF_CGT_Date)
{6}        + ToSQL(dsSF_Tax_Free_Dist) + ToSQL(dsSF_Tax_Exempt_Dist) + ToSQL(dsSF_Tax_Deferred_Dist)
               + ToSQL(dsSF_TFN_Credits) + ToSQL(dsSF_Foreign_Income)
{7}        + ToSQL(dsSF_Foreign_Tax_Credits) + ToSQL(dsSF_Capital_Gains_Indexed)
               + ToSQL(Value.dsSF_Capital_Gains_Disc) + ToSQL(dsSF_Super_Fields_Edited, false);

end;

//************************************* Memorization Detail ********************************
function GetMemorisation_Detail_RecFields: string;
begin
   Result := '[Id],[BankAccountId],[SequenceNo],[MemorisationType],[Amount],[Reference],[Particulars]'
{2}       + ',[Analysis],[OtherParty],[StatementDetails],[MatchOnAmount],[MatchOnAnalysis]'
{3}       + ',[MatchOnOther_Party],[MatchOnNotes],[MatchOnParticulars],[MatchOnRefce]'
{4}       + ',[MatchOnStatement_Details],[PayeeNumber],[FromMasterList],[Notes]'
{5}       + ',[DateLastApplied],[UseAccountingSystem],[AccountingSystem],[FromDate],[UntilDate]';
end;


function GetMemorisation_Detail_RecValues(
                            MyID: TGuid;
                            AccountID: TGuid;
                            AccountingSystemID: TGuid;
                            Value: pMemorisation_Detail_Rec): string;
begin with Value^ do
   Result :=  ToSql(MyID) + ToSql(AccountID) + ToSQL(mdSequence_No) + ToSQL(mdType)
                + ToSQL(mdAmount) + ToSQL(mdReference) + ToSQL(mdParticulars)
{2}       + ToSQL(mdAnalysis) + ToSQL(mdOther_Party) + ToSQL(mdStatement_Details)
                + ToSQL(mdMatch_on_Amount) + ToSQL(mdMatch_on_Analysis)
{3}       + ToSQL(mdMatch_on_Other_Party) + ToSQL(mdMatch_on_Notes)
                + ToSQL(mdMatch_on_Particulars)+ ToSQL(mdMatch_on_Refce)
{4}       + ToSQL(mdMatch_On_Statement_Details) + ToSQL(mdPayee_Number)
                + ToSQL(mdFrom_Master_List) + ToSQL(mdNotes )
{5}       + DateToSQL(mdDate_Last_Applied) + ToSQL(mdUse_Accounting_System)
                + ToSQL(AccountingSystemID) + DateToSQL(mdFrom_Date) + DateToSQL(mdUntil_Date, false)
end;

//************************************* Memorization Line ********************************
function GetMemorisation_Line_RecFields(SFFields: Boolean = false): string;
begin
   Result := '[Id],[MemorisationId],[SequenceNo],[Percentage],[GSTClass],[GSTHasBeenEdited]'
           + ',[PayeeNumber],[GLNarration],[LineType],[GSTAmount],[ChartCode],[JobCode]';

   if SFFields then
      Result := Result
{1}         + ',[SFPCFranked],[SFPCUnFranked],[SFMemberID],[SFFundID],[SFFundCode]'
{2}         + ',[SFTransID],[SFTransCode],[SFMemberComponent],[SFMemberAccountID],[SFMemberAccountCode]'
{3}         + ',[SFGDTDate],[SFTaxFreeDist],[SFTaxDeferredDist]'
{4}         + ',[SFTaxExemptDist],[SFTFNCredits],[SFForeignIncome],[SFForeignTaxCredits],[SFCapitalGainsIndexed]'
{5}         + ',[SFCapitalGainsDisc],[SFCapitalGainsOther],[SFInterest],[SFOtherExpenses]'
{6}         + ',[SFCapitalGainsForeignDisc],[SFRent],[SFSpecialIncome],[SFOtherTaxCredit]'
{7}         + ',[SFNonResidentTax],[SFForeignCapitalGainsCredit],[Quantity],[SFEdited]'
{8}         + ',[SFCapitalGainsFractionHalf]'

end;
function GetMemorisation_Line_RecValues(
                            MyID: TGuid;
                            MemorisationID: TGuid;
                            SequenceNo: Integer;
                            Value: pMemorisation_Line_Rec;
                            SFFields: Boolean = false): string;
begin with Value^ do begin
   Result := ToSql(MyID) + ToSql(MemorisationID) + ToSQL(SequenceNo) + PercentToSQL(mlPercentage)
                + ToSQL(mlGST_Class) + ToSQL(mlGST_Has_Been_Edited)
{2}        +  ToSQL(mlPayee)+ ToSQL(mlGL_Narration)  + ToSQL(mlLine_Type)
                + ToSQL(mlGST_Amount) + ToSQL(mlAccount) + ToSQL(mlJob_code,SFFields);

    if SFFields then
      Result := Result
{1}         + PercentToSQL(mlSF_PCFranked) + PercentToSQL(mlSF_PCUnFranked) + ToSQL(mlSF_Member_ID)
                 + ToSQL(mlSF_Fund_ID ) + ToSQL(mlSF_Fund_Code)

{2}         + ToSQL(mlSF_Trans_ID) + ToSQL(mlSF_Trans_Code) +  ToSQL(mlSF_Member_Component)
                 + ToSQL(mlSF_Member_Account_ID) + ToSQL(mlSF_Member_Account_Code)

{3}         + DateToSQl(mlSF_GDT_Date) + PercentToSQL(mlSF_Tax_Free_Dist) + PercentToSQL(mlSF_Tax_Deferred_Dist)

{4}         + PercentToSQL(mlSF_Tax_Exempt_Dist)+ PercentToSQL(mlSF_TFN_Credits)
                 + PercentToSQL(mlSF_Foreign_Income)+ PercentToSQL(mlSF_Foreign_Tax_Credits)
                 + PercentToSQL(mlSF_Capital_Gains_Indexed)

{5}         + PercentToSQL(mlSF_Capital_Gains_Disc)+ PercentToSQL(mlSF_Capital_Gains_Other)
                 + PercentToSQL(mlSF_Interest)+ PercentToSQL(mlSF_Other_Expenses)

{6}         + PercentToSQL(mlSF_Capital_Gains_Foreign_Disc) + PercentToSQL(mlSF_Rent)
                 + PercentToSQL(mlSF_Special_Income)+ PercentToSQL(mlSF_Other_Tax_Credit)

{7}         + PercentToSQL(mlSF_Non_Resident_Tax)+ PercentToSQL(mlSF_Foreign_Capital_Gains_Credit)
                 + QtyToSQL(mlQuantity)+ ToSQL(mlSF_Edited)
{8}         + ToSQL(mlSF_Capital_Gains_Fraction_Half, false)


end;end;



//************************************* Headings ********************************
function GetCustom_Heading_RecFields: string;
begin
   Result := '[Id],[Client_Id],[HeadingType],[HeadingText],[MajorId],[MinorId]'
end;

function GetCustom_Heading_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pCustom_Heading_Rec): string;
begin with value^ do
   Result := ToSql(MyID) + ToSql(ClientID) + ToSQL(hdHeading_Type) + ToSQL(hdHeading)
      + ToSQL(hdMajor_ID) +  ToSQL(hdMinor_ID, False);
end;

//************************************* Chart entry ********************************

function GetChart_RecFields: string;
begin
  Result := '[Id],[ClientId_Id],[AccountCode],[AlternateCode],[AccountDescription],[GSTClass]'
{2}      + ',[PostingAllowed],[ReportGroup],[EnterQuantity],[MoneyVariance_Up]'
{3}      + ',[MoneyVariance_Down],[PercentVariance_Up],[PercentVariance_Down]'
{4}      + ',[ReportGroupSubGroup],[LinkedAccount_OS],[LinkedAccount_CS],[HideInBasicChart]'

end;



function GetChart_RecValues( MyID: TGuid;
                            ClientID: TGuid;
                            Value: pAccount_Rec;
                            SFFields: Boolean = false): string;

begin with Value^ do
    Result := ToSQL(MyID) + ToSQL(ClientID) + ToSQL(chAccount_Code) + ToSQL(chAlternative_Code)
                   + ToSQL(chAccount_Description) + ToSQL(chGST_Class)
{2}        + ToSQL(chPosting_Allowed) + ToSQL(chAccount_Type) + ToSQL(chEnter_Quantity) + ToSQL(chMoney_Variance_Up)
{3}        + ToSQL(chMoney_Variance_Down) + ToSQL(chPercent_Variance_Up) + ToSQL(chPercent_Variance_Down)
{4}        + ToSQL(chSubtype) + ToSQL(chLinked_Account_OS) + ToSQL(chLinked_Account_CS) + ToSQL(chHide_In_Basic_Chart, false);

end;



//************************************* Payee entry ********************************
function GetPayee_Detail_RecFields: string;
begin
   Result :=  '[Id],[Client_Id],[Number],[Name]';
end;

function GetPayee_Detail_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pPayee_Detail_Rec): string;

begin with Value^ do
    Result := ToSQL(MyID) + ToSQL(ClientID) + ToSQL(pdNumber) + ToSQL(pdName, False);
end;

//************************************* Payee Line ********************************

function GetPayee_Line_RecFields(SFFields: Boolean = false): string;
begin
  Result := '[Id],[Payee_Id],[Percentage],[GSTClass],[GSTHasBeenEdited]'
{2}       +  ',[GLNarration],[LineType],[GSTAmount],[ChartCode],[SequenceNo]';

  if SFFields then
     Result := Result
{1}      + ',[SFFranked],[SFUnFranked],[SFMemberID],[SFFundID],[SFFundCode],[SFTransID]'
{2}      + ',[SFTransCode],[SFMemberComponent],[SFMemberAccountID],[SFMemberAccountCode]'
{3}      + ',[SFGDTDate],[SFLedgerID],[SFLedgerName],[SFTaxFreeDist],[SFTaxDeferredDist]'
{4}      + ',[SFTaxExemptDist],[SFTFNCredits],[SFForeignIncome],[SFForeignTaxCredits]'
{5}      + ',[SFCapitalGainsIndexed],[SFCapitalGainsDisc],[SFCapitalGainsOther],[SFInterest]'
{6}      + ',[SFOtherExpenses],[SFCapitalGainsForeignDisc],[SFRent],[SFSpecialIncome],[SFCapitalGainsFractionHalf]'
{7}      + ',[SFOtherTaxCredit],[SFNonResidentTax],[SFForeignCapitalGainsCredit],[Quantity],[SFEdited]';
end;

function GetPayee_Line_RecValues(
                            SequenceNo: Integer;
                            MyID: TGuid;
                            PayeeID: TGuid;
                            Value: pPayee_Line_Rec;
                            SFFields: Boolean = false): string;
begin with Value^ do begin
    Result := ToSQL(MyID) + ToSQL(PayeeID) + PercentToSQL(plPercentage)
                + ToSQL(plGST_Class) + ToSQL(plGST_Has_Been_Edited)
{2}         + ToSQL(plGL_Narration) + ToSQL(plLine_Type) + ToSQL(plGST_Amount)
                + ToSQL(plAccount) + ToSQL(SequenceNo, SFFields);

    if SFFields then
    Result := Result
{1}         + PercentToSQL(plSF_PCFranked) + PercentToSQL(plSF_PCUnFranked) + ToSQL(plSF_Member_ID)
                 + ToSQL(plSF_Fund_ID) + ToSQL(plSF_Fund_Code) + ToSQL(plSF_Trans_ID)

{2}         + ToSQL(plSF_Trans_Code) + ToSQL(plSF_Member_Component) + ToSQL(plSF_Member_Account_ID) + ToSQL(plSF_Member_Account_Code)

{3}         + DateToSQL(plSF_GDT_Date) + ToSQL(plSF_Ledger_ID) +ToSQL(plSF_Ledger_Name)
                 + PercentToSQL(plSF_Tax_Free_Dist) + PercentToSQL(plSF_Tax_Deferred_Dist)

{4}         + PercentToSQL(plSF_Tax_Exempt_Dist) + PercentToSQL(plSF_TFN_Credits)
                 + PercentToSQL(plSF_Foreign_Income) + PercentToSQL(plSF_Foreign_Tax_Credits)
{5}         + PercentToSQL(plSF_Capital_Gains_Indexed) + PercentToSQL(plSF_Capital_Gains_Disc)
                 + PercentToSQL(plSF_Capital_Gains_Other) + PercentToSQL(plSF_Interest)
{6}         + PercentToSQL(plSF_Other_Expenses) + PercentToSQL(plSF_Capital_Gains_Foreign_Disc)
                 + PercentToSQL(plSF_Rent) + PercentToSQL(plSF_Special_Income) + ToSQL(plSF_Capital_Gains_Fraction_Half)
{7}         + PercentToSQL(plSF_Other_Tax_Credit) + PercentToSQL(plSF_Non_Resident_Tax)
                 + PercentToSQL(plSF_Foreign_Capital_Gains_Credit) + QtyToSQL(plQuantity)+ ToSQL(plSF_Edited,false);

end; end;

//************************************* Jobs ********************************
function GetJob_Heading_RecFields: string;
begin
   Result := '[Id],[Client_Id],[Name],[DateCompleted],[Code]';
end;

function GetJob_Heading_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pJob_Heading_Rec): string;
begin with value^ do
   Result := ToSQL(MyID) + ToSQL(ClientID) + ToSQL(jhHeading) + dateToSQL(jhDate_Completed) + ToSQL(jhCode, False);
end;

//************************************* Budget Header ********************************

function GetBudget_Header_RecFields: string;
begin
  Result := '[Id],[Client_Id],[StartDate],[Name],[EstimatedOpeningBankBalance],[IsInclusive]';
end;

function GetBudget_Header_RecValues(
                            MyID: TGuid;
                            ClientID: TGuid;
                            Value: pBudget_Header_Rec): string;
begin with value^ do
    Result := ToSQL(MyID) + ToSQL(ClientID) + DateToSQL(buStart_Date)
                + ToSQL(buName) + ToSQL(buEstimated_Opening_Bank_Balance) + ToSQL(buIs_Inclusive, False);

end;

//************************************* Budget Header ********************************

function GetBudget_Detail_RecFields: string;
begin
  Result := '[Id],[Budget_Id],[AccountCode],[Period],[Amount],[Quantity],[Each]';

end;

function GetBudget_Detail_RecValues(
                            MyID: TGuid;
                            BudgetID: TGuid;
                            Period: Integer;
                            Value: pBudget_Detail_Rec): string;
begin  with value^ do
    Result := ToSQL(MyID) + ToSQL(BudgetID) + ToSQL(bdAccount_Code) + ToSQL(Period) +
                   ToSQL(bdBudget[Period]) + QtyToSQL(bdQty_Budget[Period]) + ToSQL(bdEach_Budget[Period],false);
end;




end.
