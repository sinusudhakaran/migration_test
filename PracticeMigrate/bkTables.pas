unit bkTables;

interface

uses
   MoneyDef,
   MigrateTable,
   ToDoListUnit,
   bkDefs;

type

TClient_RecFieldsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId: TGuid;
                   UserID: TGuid;
                   AccountingSystemID: TGuid;
                   TaxSystemID: TGuid;
                   GroupID: TGuid;
                   TypeID: TGuid;
                   WebExportFormat: TGuid;
                   Archived: Boolean;
                   SystemComments: string;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec): Boolean;
end;

TClient_ScheduleTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec): Boolean;
end;


TNotesOptionsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   Extra: pClientExtra_Rec;
                   Notification: Integer): Boolean;
end;

TClient_ReportOptionsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec): Boolean;
end;

TClientFinacialReportOptionsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec): Boolean;
end;

TCodingReportOptionsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec): Boolean;
end;

TBAS_OptionsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec): Boolean;
end;

TAccount_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   Value: pBank_Account_Rec): Boolean;
end;


TTransaction_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   AccountID: TGuid;
                   Value: PTransaction_Rec): Boolean;
end;


TDissection_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   TransactionID: TGuid;
                   Value: PDissection_Rec): Boolean;
end;

TMemorisation_Detail_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   AccountID: TGuid;
                   AccountingSystemID: TGuid;
                   Value: pMemorisation_Detail_Rec): Boolean;
end;

TMemorisation_Line_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   MemorisationID: TGuid;
                   SequenceNo: Integer;
                   Value: pMemorisation_Line_Rec): Boolean;
end;

TChart_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   Value: pAccount_Rec): Boolean;
end;

TChartDivisionTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID,
                   ChartID,
                   ClientId: TGuid;
                   Division: Integer
                   ): Boolean;
end;

TCustom_Heading_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   Value: pCustom_Heading_Rec): Boolean;
end;

TPayee_Detail_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   Value: pPayee_Detail_Rec): Boolean;
end;

TPayee_Line_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(SequenceNo: Integer;
                   MyID: TGuid;
                   PayeeID: TGuid;
                   Value: pPayee_Line_Rec): Boolean;
end;

TJob_Heading_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   Value: pJob_Heading_Rec): Boolean;
end;

TBudget_Header_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   Value: pBudget_Header_Rec): Boolean;
end;

TBudget_Detail_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   BudgetID: TGuid;
                   Period: Integer;
                   Value: pBudget_Detail_Rec): Boolean;
end;

TDivisionsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   Division: Integer;
                   Name: string): Boolean;
end;

TSubGroupTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   SubGroup: Integer;
                   Name: string): Boolean;
end;

TTaxEntriesTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClassID: TGuid;
                   ClientID: TGuid;
                   SequenceNo: Integer;
                   ID: string;
                   Description: string;
                   Account: string;
                   Norm: Money ): Boolean;
end;

TTaxRatesTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClassID: TGuid;
                   Rate: Money;
                   Date: integer): Boolean;
end;

TBalances_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClientID: TGuid;
                   value: pBalances_Rec): Boolean;
end;


TFuelSheetTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   BalanceID: TGuid;
                   value: pFuel_Sheet_Rec): Boolean;
end;

TReminderTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID,
                   ClientID,
                   ByUser: TGuid;
                   ToDoItem: pClientToDoItem): Boolean;
end;

TDownloadlogTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyiD, ClientID: TGuid;
                   Value: pDisk_Log_Rec): Boolean;
end;


implementation

uses
   SysUtils,
   SQLHelpers,
   bkConst,
   PasswordHash;



{ TClient_RecFieldsTable }

function TClient_RecFieldsTable.Insert(MyId: TGuid;
                   UserID: TGuid;
                   AccountingSystemID: TGuid;
                   TaxSystemID: TGuid;
                   GroupID: TGuid;
                   TypeID: TGuid;
                   WebExportFormat: TGuid;
                   Archived: Boolean;
                   SystemComments: string;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec): Boolean;

   function GetNotes: string;
   var I: Integer;
   begin
      Result := '';
      for i := Low( Value.clNotes) to High( Value.clNotes) do
         Result := Result + Value.clNotes[i];  // ?? cr
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
  Result := RunValues([ToSQL(MyId),ToSQL(clCode),ToSQL(clName),ToSQL(clAddress_L1),ToSQL(clAddress_L2),ToSQL(clAddress_L3)
               ,ToSQL(clContact_Name),ToSQL(clPhone_No),ToSQL(clFax_No),ToSQL(clClient_EMail_Address)
{2}        ,ToSQL(clCountry),ToSQL(clBankLink_Connect_Password),ToSQL(clPIN_Number),DateToSQL(clFinancial_Year_Starts)
{3}        ,ToSQL(clGST_Number),ToSQL(clGST_Period),ToSQL(clGST_Start_Month),ToSQL(clGST_Basis)
              ,ToSQL(clGST_on_Presentation_Date),ToSQL(clGST_Excludes_Accruals),ToSQL(clGST_Inclusive_Cashflow)
{4}        ,ToSQL(AccountingSystemID),ToSQL(clAccount_Code_Mask),ToSQL(clLoad_Client_Files_From),ToSQL(clSave_Client_Files_To)
               ,ToSQL(clChart_Is_Locked),DateToSQL(clChart_Last_Updated)
{5}        ,ToSQL(clMagic_Number),ToSQL(clException_Options),DateToSQL(clPeriod_Start_Date),DateToSQL(clPeriod_End_Date),ToSQL(clBankLink_Code)
{6}        ,ToSQL(clDisk_Sequence_No),ToSQL(UserID),ToSQL(clSuppress_Check_for_New_TXns),ToSQL(clDownload_From),ToSQL(clLast_Batch_Number)
{7}        ,ToSQL(clTax_Ledger_Code),ToSQL(clCheques_Expire_When),ToSQL(clShow_Notes_On_Open)
{8}        ,ToSQL(clCflw_Cash_On_Hand_Style), DateToSQL(clLast_Financial_Year_Start),ToSQL(TaxSystemID),ToSQL(clSave_Tax_Files_To)
              ,ToSQL(clJournal_Processing_Period),ToSQL(clLast_Disk_Image_Version)
{9}        ,ToSQL(clWeb_Site_Login_URL),ToSQL(clContact_Details_To_Show),ToSQL(clCustom_Contact_Name)
              ,ToSQL(clCustom_Contact_EMail_Address),ToSQL(clCustom_Contact_Phone)
{10}       ,ToSQL(clHighest_Manual_Account_No),ToSQL(clCopy_Narration_Dissection),ToSQL(SystemComments)
{11}       ,ToSQL(clClient_CC_EMail_Address),ToSQL(clLast_ECoding_Account_UID),ToSQL(WebExportFormat),ToSQL(clMobile_No)
              ,ToSQL(clFile_Read_Only),ToSQL(clSalutation),ToSQL(clExternal_ID)
{12}       ,ToSQL( clForce_Offsite_Check_Out),ToSQL(clDisable_Offsite_Check_Out),ToSQL(clAlternate_Extract_ID),ToSQL(clUse_Alterate_ID_for_extract)
{13}       ,DateToSQL(clLast_Use_Date),ToSQL(clUse_Basic_Chart),ToSQL(GroupID),ToSQL(TypeID)
              ,ToSQL(clAll_EditMode_CES),ToSQL(clAll_EditMode_DIS),ToSQL(clTFN)
{14}       , ToSql(ceAllow_Client_Unlock_Entries),ToSQL(ceAllow_Client_Edit_Chart)
              ,ToSQL(ceBudget_Include_Quantities),ToSQL(Archived)
{16}       , ToSQL(mcJournal_Processing_Duration),ToSQL( clBAS_Field_Source[bfGSTProvisional] = GSTprovisional)
              ,ToSql(clBAS_Field_Number[bfGSTProvisional] = GSTRatio),PercentToSQL(GetGSTRatio)
{17}       , ToSQL(GetNotes),ToSQL(ceBook_Gen_Finance_Reports),ToSQL(not ceBlock_Client_Edit_Mems),ToSQL(ComputePWHash(clFile_Password,MyId))],[]);
end;

procedure TClient_RecFieldsTable.SetupTable;
begin
  TableName := 'Clients';
  SetFields(['Id','Code','Name','AddressL1','AddressL2','AddressL3','ContactName','PhoneNo','FaxNo','EmailAddress'
{2}     ,'Country','BankLinkConnectPassword','PINNumber','FinancialYearStarts'
{3}     ,'GSTNumber','GSTPeriod','GSTStartMonth','GSTBasis','GSTOnPresentationDate','GSTExcludesAccruals','GSTInclusiveCashflow'
{4}     ,'AccountingSystemUsed','AccountCodeMask','LoadClientFilesFrom','SaveClientFilesTo','ChartIsLocked','ChartLastUpdated'
{5}     ,'MagicNumber','ExceptionOptions','PeriodStartDate','PeriodEndDate','BankLinkCode'
{6}     ,'DiskSequenceNo','StaffMemberId','SuppressCheckForNewTXns','DownloadFrom','LastBatchNumber'
{7}     ,'TaxLedgerCode','ChequesExpireWhen','ShowNotesOnOpen'
{8}     ,'CflwCashOnHandStyle','LastFinancialYearStart','TaxinterfaceUsed','SaveTaxFilesTo','JournalProcessingPeriod','LastDiskImageVersion'
{9}     ,'WebSiteLoginURL','ContactDetailsToShow','CustomContactName','CustomContactEMailAddress','CustomContactPhone'
{10}    ,'HighestManualAccountNo','CopyNarrationDissection','SystemComments'
{11}    ,'ClientCCEMailAddress','LastECodingAccountUID','WebExportFormat','MobileNo','FileReadOnly','Salutation','ExternalID'
{12}    ,'ForceOffsiteCheckOut','DisableOffsiteCheckOut','AlternateExtractID','UseAlterateIDforextract'
{13}    ,'LastUseDate','UseBasicChart','ClientGroupId','ClientTypeId','AllEditModeCES','AllEditModeDIS','TFN'
{14}    ,'AllowClientUnlockEntries','AllowClientEditChart','BudgetIncludeQuantities','Archived'
{15}    ,'JournalProcessingDuration','GSTIncludeProvisionalTax','GSTUseRatioOption','GSTRatio'
{16}    ,'Comments','GenerateFinancialReports','EditMemorisations','Password'],[]);

end;

{ TAccount_RecTable }

function TAccount_RecTable.Insert(MyID, ClientID: TGuid;
  Value: pBank_Account_Rec): Boolean;
begin with value^ do
  Result := RunValues([ ToSQL(MyId),ToSQL(ClientID),ToSQL(baBank_Account_Number),ToSQL(baBank_Account_Name)
              ,ToSQL(baBank_Account_Password),ToSQL(baContra_Account_Code)
 {2}     ,ToSQL(baCurrent_Balance),ToSQL(baApply_Master_Memorised_Entries),ToSQL(baAccount_Type)
              ,ToSQL(baPreferred_View),ToSQL(baHighest_BankLink_ID)
 {3}     ,ToSQL(baHighest_LRN),DateToSQL(baAccount_Expiry_Date),ToSQL(baHighest_Matched_Item_ID)
              ,ToSQL(baNotes_Always_Visible),TOSQL(baNotes_Height),ToSQL(baLast_ECoding_Transaction_UID)
 {4}     ,ToSQL(baExtend_Expiry_Date),ToSQL(baIs_A_Manual_Account),ToSQL(baAnalysis_Coding_Level)
              ,ToSQL(baECoding_Account_UID),ToSQL(baCoding_Sort_Order),ToSQL(baManual_Account_Type)
 {5}     ,ToSQL(baManual_Account_Institution),ToSQL(baManual_Account_Sent_To_Admin)
              ,ToSQL(baHDE_Sort_Order),ToSQL(baMDE_Sort_Order),ToSQL(baDIS_Sort_Order)
 {6}     ,ToSQL(baDesktop_Super_Ledger_ID),ToSql(baCurrency_Code)],[]);

end;

procedure TAccount_RecTable.SetupTable;
begin
  TableName := 'BankAccounts';
  SetFields(['Id','ClientId','BankAccountNumber','BankAccountName','BankAccountPassword','ContraAccountCode'
 {2}   , 'CurrentBalance','ApplyMasterMemorisedEntries','AccountType','PreferredView','HighestBankLink_ID'
 {3}   , 'HighestLRN','AccountExpiry_Date','HighestMatchedItemID','NotesAlwaysVisible','NotesHeight','LastECodingTransactionUID'
 {4}   , 'ExtendExpiryDate','IsAManualAccount','AnalysisCodingLevel','ECodingAccountUID','CodingSortOrder','ManualAccountType'
 {5}   , 'ManualAccountInstitution','ManualAccountSentToAdmin','HDESortOrder','MDESortOrder','DISSortOrder'
 {6}   , 'DesktopSuperLedgerID','Currency'],[]);

end;

{ TTransaction_RecTable }

function TTransaction_RecTable.Insert(MyID, AccountID: TGuid;
  Value: PTransaction_Rec): Boolean;
begin  with Value^ do
  Result := RunValues([ ToSQL(MyId),ToSQL(AccountID),ToSQL(txSequence_No)
                  ,ToSQL(txType),ToSQL(txSource),DateToSQL(txDate_Presented),DateToSQL(txDate_Effective)
{2}       ,DateToSQL(txDate_Transferred),ToSQL(txAmount) ,ToSQL(txGST_Class),ToSQL(txGST_Amount)
                  ,ToSQL(txHas_Been_Edited),QtyToSQL(txQuantity),ToSQL(txCheque_Number)
{3}       ,ToSQL(txReference),ToSQL(txParticulars),ToSQL(txAnalysis), ToSQL(txOrigBB), ToSQL(txOther_Party)
                  ,ToSQL(txAccount), ToSQL(txCoded_By)
{4}       ,nullToSQL(txPayee_Number),ToSQL(txLocked),ToSQL(txBankLink_ID),ToSQL(txGST_Has_Been_Edited)
                  ,ToSQL(txMatched_Item_ID), ToSQL(txUPI_State), ToSQL(txOriginal_Reference)
{5}       ,ToSQL(txOriginal_Source),ToSQL(txOriginal_Type),ToSQL(txOriginal_Cheque_Number),ToSQL(txOriginal_Amount)
                  ,ToSQL(txNotes),ToSQL(txECoding_Import_Notes)
{6}       ,ToSQL(txECoding_Transaction_UID), ToSQL(txGL_Narration), ToSQL(txStatement_Details), ToSQL(txTax_Invoice_Available)
{7}       ,ToSQL(txExternal_GUID),ToSQl(txDocument_Title),ToSQL(txJob_Code)
{8}       ,ToSQL(txDocument_Status_Update_Required),ToSQL(txBankLink_UID),ToSQL(txNotes_Read),ToSQL(txImport_Notes_Read)

          ],[

{1}       ToSQL(txSF_Franked),ToSQL(txSF_Unfranked),ToSQL(txSF_Interest)
              ,ToSQL(txSF_Capital_Gains_Foreign_Disc),ToSQL(txSF_Rent)
{2}       ,ToSQL(txSF_Special_Income),ToSQL(txSF_Other_Tax_Credit),ToSQL(txSF_Non_Resident_Tax)
              ,ToSQL(txSF_Member_ID)
{3}       ,ToSQL(txSF_Foreign_Capital_Gains_Credit),ToSQL(txSF_Member_Component),ToSQL(txSF_Fund_ID)
              ,ToSQL(txSF_Member_Account_ID)
{4}       ,ToSQL(txSF_Fund_Code),ToSQL(txSF_Member_Account_Code),ToSQL(txSF_Transaction_ID),ToSQL(txSF_Transaction_Code)
              ,ToSQL(txSF_Capital_Gains_Fraction_Half)
{5}       ,ToSQL(txSF_Imputed_Credit),ToSQL(txSF_Capital_Gains_Other),ToSQL(txSF_Other_Expenses)
              ,DateToSQL(txSF_CGT_Date)
{6}       ,ToSQL(txSF_Tax_Free_Dist),ToSQL(txSF_Tax_Exempt_Dist),ToSQL(txSF_Tax_Deferred_Dist)
              ,ToSQL(txSF_TFN_Credits),ToSQL(txSF_Foreign_Income)
{7}       ,ToSQL(txSF_Foreign_Tax_Credits),ToSQL(txSF_Capital_Gains_Indexed)
              ,ToSQL(Value.txSF_Capital_Gains_Disc), ToSQL(txSF_Super_Fields_Edited)]);

end;

procedure TTransaction_RecTable.SetupTable;
begin
  TableName := 'Transactions';
  SetFields(['Id','BankAccount_Id','SequenceNo','Type','Source','DatePresented','DateEffective'
{2}       ,'DateTransferred','Amount','GSTClass','GSTAmount','HasBeenEdited','Quantity','ChequeNumber'
{3}       ,'Reference','Particulars','Analysis','OrigBB','OtherParty','Account','CodedBy'
{4}       ,'PayeeNumber','Locked','BankLinkID','GSTHasBeenEdited','MatchedItemID','UPIState','OriginalReference'
{5}       ,'OriginalSource','OriginalType','OriginalChequeNumber','OriginalAmount','Notes','ECodingImportNotes'
{6}       ,'ECodingTransactionUID','GLNarration','StatementDetails' ,'TaxInvoiceAvailable'
{7}       ,'ExternalGUID','DocumentTitle','JobCode'
{8}       ,'DocumentStatusUpdateRequired','BankLinkUID','NotesRead','ImportNotesRead'

          ],[

{1}       'SFFranked','SFUnfranked','SFinterest','SFCapitalGainsForeignDisc','SFRent'
{2}       ,'SFSpecialIncome','SFOtherTaxCredit','SFNonResidentTax','SFMemberID'
{3}       ,'SFForeignCapitalGainsCredit','SFMemberComponent','SFFundID','SFMemberAccountID'
{4}       ,'SFFundCode','SFMemberAccountCode','SFTransactionID','SFTransactionCode','SFCapitalGainsFractionHalf'
{5}       ,'SFImputedCredit','SFCapitalGainsOther','SFOtherExpenses','SFCGTDate'
{6}       ,'SFTaxFreeDist','SFTaxExemptDist','SFTaxDeferredDist','SFTFNCredits','SFForeignIncome'
{7}       ,'SFForeignTaxCredits','SFCapitalGainsIndexed','SFCapitalGainsDisc','SFSuperFieldsEdited']);

end;

{ TDissection_RecTable }

function TDissection_RecTable.Insert(MyID, TransactionID: TGuid;
  Value: PDissection_Rec): Boolean;
begin with Value^ do
   Result := RunValues([ ToSQL(MyId),ToSQL(TransactionID),ToSQL(dsSequence_No)
{2}       ,ToSQL(dsAmount) ,ToSQL(dsGST_Class),ToSQL(dsGST_Amount)
                  ,ToSQL(dsHas_Been_Edited),QtyToSQL(dsQuantity),ToSQL(dsReference)
{3}       ,ToSQL(dsAccount),nullToSQL(dsPayee_Number),ToSQL(dsGST_Has_Been_Edited)
{4}       ,ToSQL(dsNotes),ToSQL(dsECoding_Import_Notes),ToSQL(dsGL_Narration), ToSQL(dsTax_Invoice)
{5}       ,ToSQL(dsExternal_GUID),ToSQl(dsDocument_Title),ToSQL(dsJob_Code)
{8}       ,ToSQL(dsDocument_Status_Update_Required),ToSQL(dsNotes_Read),ToSQL(dsImport_Notes_Read)

   ],[

          ToSQL(dsSF_Franked),ToSQL(dsSF_Unfranked),ToSQL(dsSF_Interest)
              ,ToSQL(dsSF_Capital_Gains_Foreign_Disc),ToSQL(dsSF_Rent)
{2}       ,ToSQL(dsSF_Special_Income),ToSQL(dsSF_Other_Tax_Credit),ToSQL(dsSF_Non_Resident_Tax)
              ,ToSQL(dsSF_Member_ID)
{3}       ,ToSQL(dsSF_Foreign_Capital_Gains_Credit),ToSQL(dsSF_Member_Component),ToSQL(dsSF_Fund_ID)
              ,ToSQL(dsSF_Member_Account_ID)
{4}       ,ToSQL(dsSF_Fund_Code),ToSQL(dsSF_Member_Account_Code),ToSQL(dsSF_Transaction_ID),ToSQL(dsSF_Transaction_Code)
              ,ToSQL(dsSF_Capital_Gains_Fraction_Half)
{5}       ,ToSQL(dsSF_Imputed_Credit),ToSQL(dsSF_Capital_Gains_Other),ToSQL(dsSF_Other_Expenses)
              ,DateToSQL(dsSF_CGT_Date)
{6}       ,ToSQL(dsSF_Tax_Free_Dist),ToSQL(dsSF_Tax_Exempt_Dist),ToSQL(dsSF_Tax_Deferred_Dist)
              ,ToSQL(dsSF_TFN_Credits),ToSQL(dsSF_Foreign_Income)
{7}       ,ToSQL(dsSF_Foreign_Tax_Credits),ToSQL(dsSF_Capital_Gains_Indexed)
              ,ToSQL(Value.dsSF_Capital_Gains_Disc),ToSQL(dsSF_Super_Fields_Edited)]);
end;

procedure TDissection_RecTable.SetupTable;
begin
 TableName := 'Dissections';
  SetFields(['Id','Transaction_Id','SequenceNo'
{2}       ,'Amount','GSTClass','GSTAmount','HasBeenEdited','Quantity','Reference'
{3}       ,'Account','PayeeNumber','GSTHasBeenEdited'
{4}       ,'Notes','ECodingImportNotes','GLNarration','TaxInvoice'
{5}       ,'ExternalGUID','DocumentTitle','JobCode'
{6}       ,'DocumentStatusUpdateRequired','NotesRead','ImportNotesRead'

          ],[

{1}       'SFFranked','SFUnfranked','SFinterest','SFCapitalGainsForeignDisc','SFRent'
{2}       ,'SFSpecialIncome','SFOtherTaxCredit','SFNonResidentTax','SFMemberID'
{3}       ,'SFForeignCapitalGainsCredit','SFMemberComponent','SFFundID','SFMemberAccountID'
{4}       ,'SFFundCode','SFMemberAccountCode','SFTransactionID','SFTransactionCode','SFCapitalGainsFractionHalf'
{5}       ,'SFImputedCredit','SFCapitalGainsOther','SFOtherExpenses','SFCGTDate'
{6}       ,'SFTaxFreeDist','SFTaxExemptDist','SFTaxDeferredDist','SFTFNCredits','SFForeignIncome'
{7}       ,'SFForeignTaxCredits','SFCapitalGainsIndexed','SFCapitalGainsDisc','SFSuperFieldsEdited']);

end;

{ TMemorisation_Detail_RecTable }

function TMemorisation_Detail_RecTable.Insert(MyID, AccountID,
  AccountingSystemID: TGuid; Value: pMemorisation_Detail_Rec): Boolean;

begin with Value^ do
 Result := RunValues([ ToSql(MyID),ToSql(AccountID),ToSQL(mdSequence_No),ToSQL(mdType)
               ,ToSQL(mdAmount),ToSQL(mdReference),ToSQL(mdParticulars)
{2}      ,ToSQL(mdAnalysis),ToSQL(mdOther_Party),ToSQL(mdStatement_Details)
               ,ToSQL(mdMatch_on_Amount),ToSQL(mdMatch_on_Analysis)
{3}      ,ToSQL(mdMatch_on_Other_Party),ToSQL(mdMatch_on_Notes)
               ,ToSQL(mdMatch_on_Particulars), ToSQL(mdMatch_on_Refce)
{4}      ,ToSQL(mdMatch_On_Statement_Details),NullToSQL(mdPayee_Number)
               ,ToSQL(mdFrom_Master_List),ToSQL(mdNotes )
{5}      ,DateToSQL(mdDate_Last_Applied),ToSQL(mdUse_Accounting_System)
               ,ToSQL(AccountingSystemID),DateToSQL(mdFrom_Date),DateToSQL(mdUntil_Date)],[]);

end;

procedure TMemorisation_Detail_RecTable.SetupTable;
begin
  TableName := 'Memorisations';
  SetFields(['Id','BankAccountId','SequenceNo','MemorisationType','Amount','Reference','Particulars'
{2}       ,'Analysis','OtherParty','StatementDetails','MatchOnAmount','MatchOnAnalysis'
{3}       ,'MatchOnOther_Party','MatchOnNotes','MatchOnParticulars','MatchOnRefce'
{4}       ,'MatchOnStatement_Details','Payee','FromMasterList','Notes'
{5}       ,'DateLastApplied','UseAccountingSystem','AccountingSystem','FromDate','UntilDate'],[]);

end;

{ TMemorisation_Line_RecTable }

function TMemorisation_Line_RecTable.Insert(MyID, MemorisationID: TGuid;
  SequenceNo: Integer; Value: pMemorisation_Line_Rec): Boolean;
begin with Value^ do
  Result := RunValues([ ToSql(MyID),ToSql(MemorisationID),ToSQL(SequenceNo),PercentToSQL(mlPercentage)
               ,ToSQL(mlGST_Class),ToSQL(mlGST_Has_Been_Edited)
{2}       , NullToSQL(mlPayee), ToSQL(mlGL_Narration) ,ToSQL(mlLine_Type)
               ,ToSQL(mlGST_Amount),ToSQL(mlAccount),ToSQL(mlJob_code)

   ],[

{1}        PercentToSQL(mlSF_PCFranked),PercentToSQL(mlSF_PCUnFranked),ToSQL(mlSF_Member_ID)
                ,ToSQL(mlSF_Fund_ID ),ToSQL(mlSF_Fund_Code)

{2}        ,ToSQL(mlSF_Trans_ID),ToSQL(mlSF_Trans_Code), ToSQL(mlSF_Member_Component)
                ,ToSQL(mlSF_Member_Account_ID),ToSQL(mlSF_Member_Account_Code)

{3}        ,DateToSQl(mlSF_GDT_Date),PercentToSQL(mlSF_Tax_Free_Dist),PercentToSQL(mlSF_Tax_Deferred_Dist)

{4}        ,PercentToSQL(mlSF_Tax_Exempt_Dist), PercentToSQL(mlSF_TFN_Credits)
                ,PercentToSQL(mlSF_Foreign_Income), PercentToSQL(mlSF_Foreign_Tax_Credits)
                ,PercentToSQL(mlSF_Capital_Gains_Indexed)

{5}        ,PercentToSQL(mlSF_Capital_Gains_Disc), PercentToSQL(mlSF_Capital_Gains_Other)
                ,PercentToSQL(mlSF_Interest), PercentToSQL(mlSF_Other_Expenses)

{6}        ,PercentToSQL(mlSF_Capital_Gains_Foreign_Disc),PercentToSQL(mlSF_Rent)
                ,PercentToSQL(mlSF_Special_Income), PercentToSQL(mlSF_Other_Tax_Credit)

{7}        ,PercentToSQL(mlSF_Non_Resident_Tax), PercentToSQL(mlSF_Foreign_Capital_Gains_Credit)
                ,QtyToSQL(mlQuantity), ToSQL(mlSF_Edited)
{8}        ,ToSQL(mlSF_Capital_Gains_Fraction_Half)]);

end;

procedure TMemorisation_Line_RecTable.SetupTable;
begin
  TableName := 'MemorisationLines';
  SetFields([ 'Id','MemorisationId','SequenceNo','Percentage','GSTClass','GSTHasBeenEdited'
           ,'PayeeNumber','GLNarration','LineType','GSTAmount','ChartCode','JobCode'

   ],[
{1}         'SFPCFranked','SFPCUnFranked','SFMemberID','SFFundID','SFFundCode'
{2}         ,'SFTransID','SFTransCode','SFMemberComponent','SFMemberAccountID','SFMemberAccountCode'
{3}         ,'SFGDTDate','SFTaxFreeDist','SFTaxDeferredDist'
{4}         ,'SFTaxExemptDist','SFTFNCredits','SFForeignIncome','SFForeignTaxCredits','SFCapitalGainsIndexed'
{5}         ,'SFCapitalGainsDisc','SFCapitalGainsOther','SFInterest','SFOtherExpenses'
{6}         ,'SFCapitalGainsForeignDisc','SFRent','SFSpecialIncome','SFOtherTaxCredit'
{7}         ,'SFNonResidentTax','SFForeignCapitalGainsCredit','Quantity','SFEdited'
{8}         ,'SFCapitalGainsFractionHalf']);

end;

{ TChart_RecTable }

function TChart_RecTable.Insert(MyID, ClientID: TGuid; Value: pAccount_Rec): Boolean;
begin with Value^ do
  Result := RunValues([ToSQL(MyID),ToSQL(ClientID),ToSQL(chAccount_Code),ToSQL(chAlternative_Code)
                  ,ToSQL(chAccount_Description),ToSQL(chGST_Class)
{2}       ,ToSQL(chPosting_Allowed),ToSQL(chAccount_Type),ToSQL(chEnter_Quantity),ToSQL(chMoney_Variance_Up)
{3}       ,ToSQL(chMoney_Variance_Down),ToSQL(chPercent_Variance_Up),ToSQL(chPercent_Variance_Down)
{4}       ,ToSQL(chSubtype),ToSQL(chLinked_Account_OS),ToSQL(chLinked_Account_CS),ToSQL(chHide_In_Basic_Chart)],[]);

end;

procedure TChart_RecTable.SetupTable;
begin
  TableName := 'Charts';
  SetFields(['Id','ClientId','AccountCode','AlternateCode','AccountDescription','GSTClass'
{2}      ,'PostingAllowed','ReportGroup','EnterQuantity','MoneyVariance_Up'
{3}      ,'MoneyVariance_Down','PercentVariance_Up','PercentVariance_Down'
{4}      ,'ReportGroupSubGroup','LinkedAccount_OS','LinkedAccount_CS','HideInBasicChart'],[]);

end;

{ TCustom_Heading_RecTable }

function TCustom_Heading_RecTable.Insert(MyID, ClientID: TGuid; Value: pCustom_Heading_Rec): Boolean;
begin with Value^ do
    Result := RunValues([ToSql(MyID),ToSql(ClientID),ToSQL(hdHeading_Type),ToSQL(hdHeading),ToSQL(hdMajor_ID), ToSQL(hdMinor_ID)],[]);
end;

procedure TCustom_Heading_RecTable.SetupTable;
begin
   TableName := 'Headings';
   SetFields([ 'Id','Client_Id','HeadingType','HeadingText','MajorId','MinorId'],[]);
end;

{ TPayee_Detail_RecTable }

function TPayee_Detail_RecTable.Insert(MyID, ClientID: TGuid; Value: pPayee_Detail_Rec): Boolean;
begin with Value^ do
  Result := RunValues([ToSQL(MyID),ToSQL(ClientID),ToSQL(pdNumber),ToSQL(pdName)],[]);
end;

procedure TPayee_Detail_RecTable.SetupTable;
begin
  TableName := 'Payees';
  SetFields(['Id','Client_Id','Number','Name'],[]);
end;

{ TPayee_Line_RecTable }

function TPayee_Line_RecTable.Insert(SequenceNo: Integer; MyID, PayeeID: TGuid;
  Value: pPayee_Line_Rec): Boolean;
begin with Value^ do
    Result := RunValues([ToSQL(MyID),ToSQL(PayeeID),PercentToSQL(plPercentage)
               ,ToSQL(plGST_Class),ToSQL(plGST_Has_Been_Edited)
{2}        ,ToSQL(plGL_Narration),ToSQL(plLine_Type),ToSQL(plGST_Amount)
               ,ToSQL(plAccount),ToSQL(SequenceNo)

    ],[

{1}        PercentToSQL(plSF_PCFranked),PercentToSQL(plSF_PCUnFranked),ToSQL(plSF_Member_ID)
                ,ToSQL(plSF_Fund_ID),ToSQL(plSF_Fund_Code),ToSQL(plSF_Trans_ID)

{2}        ,ToSQL(plSF_Trans_Code),ToSQL(plSF_Member_Component),ToSQL(plSF_Member_Account_ID),ToSQL(plSF_Member_Account_Code)

{3}        ,DateToSQL(plSF_GDT_Date),ToSQL(plSF_Ledger_ID),ToSQL(plSF_Ledger_Name)
                ,PercentToSQL(plSF_Tax_Free_Dist),PercentToSQL(plSF_Tax_Deferred_Dist)

{4}        ,PercentToSQL(plSF_Tax_Exempt_Dist),PercentToSQL(plSF_TFN_Credits)
                ,PercentToSQL(plSF_Foreign_Income),PercentToSQL(plSF_Foreign_Tax_Credits)
{5}        ,PercentToSQL(plSF_Capital_Gains_Indexed),PercentToSQL(plSF_Capital_Gains_Disc)
                ,PercentToSQL(plSF_Capital_Gains_Other),PercentToSQL(plSF_Interest)
{6}        ,PercentToSQL(plSF_Other_Expenses),PercentToSQL(plSF_Capital_Gains_Foreign_Disc)
                ,PercentToSQL(plSF_Rent),PercentToSQL(plSF_Special_Income),ToSQL(plSF_Capital_Gains_Fraction_Half)
{7}        ,PercentToSQL(plSF_Other_Tax_Credit),PercentToSQL(plSF_Non_Resident_Tax)
                ,PercentToSQL(plSF_Foreign_Capital_Gains_Credit),QtyToSQL(plQuantity), ToSQL(plSF_Edited)]);

end;

procedure TPayee_Line_RecTable.SetupTable;
begin
  TableName := 'PayeeLines';
  SetFields(['Id','Payee_Id','Percentage','GSTClass','GSTHasBeenEdited'
{2}      , 'GLNarration','LineType','GSTAmount','ChartCode','SequenceNo'

       ],[

{1}      'SFFranked','SFUnFranked','SFMemberID','SFFundID','SFFundCode','SFTransID'
{2}      ,'SFTransCode','SFMemberComponent','SFMemberAccountID','SFMemberAccountCode'
{3}      ,'SFGDTDate','SFLedgerID','SFLedgerName','SFTaxFreeDist','SFTaxDeferredDist'
{4}      ,'SFTaxExemptDist','SFTFNCredits','SFForeignIncome','SFForeignTaxCredits'
{5}      ,'SFCapitalGainsIndexed','SFCapitalGainsDisc','SFCapitalGainsOther','SFInterest'
{6}      ,'SFOtherExpenses','SFCapitalGainsForeignDisc','SFRent','SFSpecialIncome','SFCapitalGainsFractionHalf'
{7}      ,'SFOtherTaxCredit','SFNonResidentTax','SFForeignCapitalGainsCredit','Quantity','SFEdited']);

end;

{ TJob_Heading_RecTable }

function TJob_Heading_RecTable.Insert(MyID, ClientID: TGuid; Value: pJob_Heading_Rec): Boolean;
begin with Value^ do
   Result := RunValues([ToSQL(MyID),ToSQL(ClientID),ToSQL(jhHeading),dateToSQL(jhDate_Completed),ToSQL(jhCode)],[]);
end;

procedure TJob_Heading_RecTable.SetupTable;
begin
   TableName := 'Jobs';
   SetFields(['Id','Client_Id','Name','DateCompleted','Code'],[]);
end;

{ TBudget_Header_RecTable }

function TBudget_Header_RecTable.Insert(MyID, ClientID: TGuid;
  Value: pBudget_Header_Rec): Boolean;
begin with Value^ do
    Result := RunValues([ToSQL(MyID),ToSQL(ClientID),DateToSQL(buStart_Date)
               ,ToSQL(buName),ToSQL(buEstimated_Opening_Bank_Balance),ToSQL(buIs_Inclusive)],[]);
end;

procedure TBudget_Header_RecTable.SetupTable;
begin
  TableName := 'Budgets';
  SetFields(['Id','Client_Id','StartDate','Name','EstimatedOpeningBankBalance','IsInclusive'],[]);
end;

{ TBudget_Detail_RecTable }

function TBudget_Detail_RecTable.Insert(MyID, BudgetID: TGuid; Period: Integer;
  Value: pBudget_Detail_Rec): Boolean;
begin with Value^ do
  Result := RunValues([ ToSQL(MyID),ToSQL(BudgetID),ToSQL(bdAccount_Code),ToSQL(Period),
                   ToSQL(bdBudget[Period]),QtyToSQL(bdQty_Budget[Period]),ToSQL(bdEach_Budget[Period])],[]);
end;

procedure TBudget_Detail_RecTable.SetupTable;
begin
  TableName := 'BudgetLines';
  SetFields(['Id','Budget_Id','AccountCode','Period','Amount','Quantity','Each'],[]);
end;


{ TDivisionsTable }

function TDivisionsTable.Insert(MyID: TGuid;  ClientID: TGuid; Division: Integer; Name: string): Boolean;
begin
   Result := RunValues([ToSQL(MyID),ToSQL(ClientID),ToSQL(Division),ToSQL(Name)],[]);
end;

procedure TDivisionsTable.SetupTable;
begin
   TableName := 'ReportClientDivisions';
   SetFields(['Id','Client_Id','Division','Description'],[]);
end;

{ TTaxEntriesTable }

function TTaxEntriesTable.Insert(MyID: TGuid;
                   ClassID: TGuid;
                   ClientID: TGuid;
                   SequenceNo: Integer;
                   ID: string;
                   Description: string;
                   Account: string;
                   Norm: Money): Boolean;
begin
   Result := RunValues([ToSQL(MyID),ToSQL(ClassID),ToSQL(ClientID),ToSQL(ID),ToSQL(SequenceNo),ToSQL(Description)
                ,ToSQL(Account),PercentToSQL(Norm) ],[]);
end;

procedure TTaxEntriesTable.SetupTable;
begin
  TableName := 'TaxEntries';
  SetFields(['Id','TaxClassType_Id','ClientId','TaxId','SequenceNo','ClassDescription','ControlAccount','Norm'],[]);
end;

{ TTaxRatesTable }

function TTaxRatesTable.Insert(MyID: TGuid;
                   ClassID: TGuid;
                   Rate: Money;
                   Date: integer): Boolean;
begin
   Result := RunValues([ToSQL(MyID),ToSQL(ClassID),PercentToSQL(Rate),DateToSQL(Date)],[]);
end;

procedure TTaxRatesTable.SetupTable;
begin
  TableName := 'TaxRates';
  SetFields(['Id','TaxEntry_Id','Rate','EffectiveDate'],[]);
end;

{ TClient_ScheduleTable }

function TClient_ScheduleTable.Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec): Boolean;
begin with Value^, Extra^ do
  Result := RunValues([ToSQL(MyID), ToSQL(ClientID), ToSQL(clScheduled_Coding_Report_Style)
              ,ToSQL(clScheduled_Coding_Report_Sort_Order), DateToSQL(value.clReport_Start_Date)

{2}       ,ToSQL(clScheduled_Coding_Report_Entry_Selection), ToSQL(clScheduled_Coding_Report_Blank_Lines)
              ,ToSql(clScheduled_Coding_Report_Rule_Line), ToSQL(clScheduled_Coding_Report_New_Page)

{3}       ,ToSQL(clScheduled_Coding_Report_Print_TI), ToSQL(clScheduled_Coding_Report_Show_OP)
              ,ToSQL(clScheduled_Coding_Report_Wrap_Narration)
              ,ToSQL(not (clFax_Scheduled_Reports
                      or clCheckOut_Scheduled_Reports
                      or clWebX_Export_Scheduled_Reports
                      or clEmail_Scheduled_Reports))

{4}       ,ToSQL(clEmail_Scheduled_Reports), ToSQL(clFax_Scheduled_Reports), ToSQL(clCheckOut_Scheduled_Reports)
              ,ToSQL(clWebX_Export_Scheduled_Reports), ToSQL(clCSV_Export_Scheduled_Reports)
              ,ToSQL(clBusiness_Products_Scheduled_Reports), ToSQL(clSend_Coding_Report)

{5}       ,ToSQL(clSend_Chart_of_Accounts), ToSQL(clSend_Payee_List), ToSQL(Extra.ceSend_Job_List)
              ,ToSQL(clExclude_From_Scheduled_Reports), ToSQL(clReporting_Period) , ToSQL(extra.ceSend_Custom_Documents)

{6}       ,ToSQL(clScheduled_Client_Note_Message), ToSQL(clEmail_Report_Format), ToSQL(ceScheduled_Custom_CR_XML)
              ,ToSQL(ceScheduled_CR_Column_Line)

              ],[]);
end;

procedure TClient_ScheduleTable.SetupTable;
begin
  TableName := 'ScheduledTaskValues';
  SetFields(['Id','ClientId','CodingReportStyle','CodingReportSortOrder', 'ReportYearStart'

{2}      ,'CodingReportEntrySelection','CodingReportBlankLines','CodingReportRuleLineBetweenEntries','CodingReportNewPage'

{3}      ,'CodingReportShowTaxInvoice','CodingReportShowOtherParty','CodingReportWrapNarration','TaskPrint'

{4}      ,'TaskEmail','TaskFax','TaskCheckOut','TaskWebExport','TaskCSVExport','TaskBusinessProduct','SendCoding'

{5}      ,'SendChart','Sendpayees','SendJobs', 'ExcludeFromScheduledReports','ReportingPeriod' ,'IncludeCustomDocument'

{6}      ,'ClientNoteMessage','EmailReportFormat','CustomCodingReportXML','CodingReportRuleLineBetweenColumns'
     ],[]);

end;

{ TClient_ReportOptionsTable }

function TClient_ReportOptionsTable.Insert(MyId: TGuid;
                    ClientID: TGuid;Value: pClient_Rec;
                    More: pMoreClient_Rec; Extra: pClientExtra_Rec): Boolean;
begin with Value^, Extra^ do
   Result := RunValues([ToSQL(MyID), ToSQL(ClientID), dateToSQL(clReporting_Year_Starts),
{2}       ToSQL(clLedger_Report_Summary), ToSQL(clLedger_Report_Show_Notes), ToSQL(clLedger_Report_Show_Quantities),
              ToSQL(clLedger_Report_Show_Non_Trf)
{3}       ,ToSQL(clLedger_Report_Show_Inactive_Codes), ToSQL(clLedger_Report_Bank_Contra), ToSQL(clLedger_Report_GST_Contra)
              ,ToSQL(clLedger_Report_Show_Balances)
{4}       ,ToSQL(clLedger_Report_Show_Gross_And_GST)
              ,ToSQL(clBusiness_Products_Report_Format)
{5}       ,ToSQL(clLedger_Report_Wrap_Narration), ToSQL(Value.clProfit_Report_Show_Percentage)
              ,ToSQL(clFavourite_Report_XML)
{6}       ,ToSQL(ceCustom_Ledger_Report), ToSQL(extra.ceCustom_Ledger_Report_XML), ToSQL(ceBook_Gen_Finance_Reports)  ],[]);
end;

procedure TClient_ReportOptionsTable.SetupTable;
begin
   TableName := 'ReportingOptions';
   SetFields(['Id' ,'ClientId_Id' ,'ReportingYearStarts'
{2}      ,'LedgerReportSummary','LedgerReportShowNotes','LedgerReportShowQuantities','LedgerReportShowNonTrf'
{3}      ,'LedgerReportShowInactiveCodes','LedgerReportBankContra','LedgerReportGSTContra','LedgerReportShowBalances'
{4}      ,'LedgerReportShowGrossAndGST','BusinessProductsReportFormat'
{5}      ,'LedgerReportWrapNarration','ProfitReportShowPercentage','FavouriteReportXML'
{6}      ,'CustomLedgerReport','CustomLedgerReportXML','BookGenFinanceReports' ],[]);
end;

{ TSubGroupTable }

function TSubGroupTable.Insert(MyID, ClientID: TGuid; SubGroup: Integer; Name: string): Boolean;
begin
   Result := RunValues([ToSQL(MyID),ToSQL(ClientID),ToSQL(SubGroup), ToSQL(Name)],[]);
end;

procedure TSubGroupTable.SetupTable;
begin
   TableName := 'ReportSubGroups';
   SetFields(['Id','Client_Id','SubGroupNo','Description'],[]);
end;

{ TClientFinacialReportOptionsTable }

function TClientFinacialReportOptionsTable.Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec):Boolean;
begin with Value^, Extra^ do
    Result := RunValues([ToSQL(MyID),ToSQL(ClientID), ToSQL(clFRS_Show_YTD ), ToSQL(clFRS_Show_Variance), ToSQL(clFRS_Compare_Type)
           ,ToSQL(clFRS_Reporting_Period_Type), ToSQL(clFRS_Report_Style), ToSQL(clFRS_Report_Detail_Type)
                ,ToSQL(clFRS_Prompt_User_to_use_Budgeted_figures)
           ,ToSQL(ceFRS_Print_NP_Chart_Code_Titles), ToSQL(ceFRS_NP_Chart_Code_Detail_Type), ToSQL(clFRS_Show_Quantity)
                ,ToSQL(value.clFRS_Print_Chart_Codes)],[]);
end;

procedure TClientFinacialReportOptionsTable.SetupTable;
begin
  TableName := 'FRSOptions';
  SetFields(['Id','ClientId_Id','FRSShowYTD','FRSShowVariance','FRSCompareType'
      ,'FRSReportingPeriodType','FRSReportStyle','FRSReportDetailType','FRSPromptUsertouseBudgetedfigures'
      ,'FRSPrintNPChartCodeTitles','FRSNPChartCodeDetailType','FRSShowQuantity','FRSPrintChartCodes'
      ],[]);
end;

{ TCodingReportOptionsTable }

function TCodingReportOptionsTable.Insert(MyId, ClientID: TGuid;
  Value: pClient_Rec; More: pMoreClient_Rec; Extra: pClientExtra_Rec): Boolean;
begin with Value^, Extra^ do
   Result := RunValues([ToSQL(MyID),ToSQL(ClientID), ToSQL(clCoding_Report_Style), ToSQL(clCoding_Report_Sort_Order)
               ,ToSQL(clCoding_Report_Entry_Selection)
{2}       ,ToSQL(clCoding_Report_Blank_Lines), ToSQL(clCoding_Report_Rule_Line), ToSQL(clCoding_Report_New_Page)
               ,ToSQL(extra.ceCustom_Coding_Report_XML)
{3}       ,ToSQL(clCoding_Report_Wrap_Narration),ToSQL(clCoding_Report_Show_OP), ToSQL(Value.clCoding_Report_Print_TI)
{4}       ,ToSQL(ceCustom_Ledger_Report), ToSQL(ceCoding_Report_Column_Line)],[])
end;

procedure TCodingReportOptionsTable.SetupTable;
begin
  TableName := 'CodingReportOptions';
  SetFields(['Id','ClientId','ReportStyle','SortOrder','EntrySelection'
      ,'BlankLines','RuleLine','NewPage','CustomXML'
{3}   ,'WrapNarration', 'ShowOtherParty','ShowTaxInvoice'
{4}   ,'CustomReport','ColumnLine'],[]);

end;

{ TBalances_RecTable }

function TBalances_RecTable.Insert(MyID, ClientID: TGuid;
  value: pBalances_Rec): Boolean;
begin with Value^ Do
   Result := RunValues([ToSQL(MyID),ToSQL(ClientID),DateToSQL(blGST_Period_Starts),DateToSQL(blGST_Period_Ends),ToSQL(blClosing_Debtors_Balance)
                ,ToSQL(blOpening_Debtors_Balance)
{2}          ,ToSQL(blFBT_Adjustments),ToSQL(blOther_Adjustments),ToSQL(blClosing_Creditors_Balance),ToSQL(blOpening_Creditors_Balance)
                ,ToSQL(blCredit_Adjustments)
{3}          ,ToSQL(blBAS_Document_ID),ToSQL(blBAS_1C_PT_Last_Months_Income),ToSQL(blBAS_1D_PT_Branch_Income)
                ,ToSQL(blBAS_1E_PT_Assets),ToSQL(blBAS_1F_PT_Tax),ToSQL(blBAS_1G_PT_Refund_Used)
{4}          ,ToSQL(blBAS_5B_PT_Ratio),ToSQL(blBAS_6B_GST_Adj_PrivUse),ToSQL(blBAS_7_VAT4_GST_Adj_BAssets)
                ,ToSQL(blBAS_G7_GST_Adj_Assets),ToSQL(blBAS_G18_GST_Adj_Entertain),ToSQL(blBAS_W1_GST_Adj_Change)
                ,ToSQL(blBAS_W2_GST_Adj_Exempt),ToSQL(blBAS_W3_GST_Adj_Other)
{5}          ,ToSQL(blBAS_W4_GST_Cdj_BusUse),ToSQL(blBAS_T1_VAT1_GST_Cdj_PAssets),ToSQL(blBAS_T2_VAT2_GST_Cdj_Change)
                ,ToSQL(blBAS_T3_VAT3_GST_Cdj_Other),ToSQL(blBAS_T4),ToSQL(blBAS_F1_GST_Closing_Debtors_BalanceA)
                ,ToSQL(blBAS_F2_GST_Opening_Debtors_BalanceB),ToSQL(blBAS_F3),ToSQL(blBAS_F4)
{6}          ,ToSQL(blBAS_Form_Used),ToSQL(blBAS_GST_Option),ToSQL(blBAS_GST_Included),ToSQL(blBAS_G21_GST_Closing_Creditors_BalanceA)
                ,ToSQL(blBAS_G22_GST_Opening_Creditors_BalanceB),ToSQL(blBAS_G23),ToSQL(blBAS_G24)
{7}          ,ToSQL(blBAS_PAYG_Instalment_Option),ToSQL(blBAS_T7_VAT7),ToSQL(blBAS_T8_VAT8),ToSQL(blBAS_T9_VAT9)
                ,ToSQL(blBAS_1H),ToSQL(blGST_Adj_PrivUse),ToSQL(blGST_Adj_BAssets)
{8}          ,ToSQL(blGST_Adj_Assets),ToSQL(blGST_Adj_Entertain),ToSQL(blGST_Adj_Change),ToSQL(blGST_Adj_Exempt)
                ,ToSQL(blGST_Adj_Other),ToSQL(blGST_Cdj_BusUse)
{9}          ,ToSQL(blGST_Cdj_PAssets),ToSQL(blGST_Cdj_Change),ToSQL(blGST_Cdj_Other),ToSQL(blBAS_7C),ToSQL(blBAS_7D)
                ,ToSQL(blBAS_T6_VAT6),ToSQL(blBAS_T5_VAT5)
{10}         ,ToSQL(blUsing_Fuel_Percent_Method),ToSQL(blPT_Form_Type),ToSQL(blGST_Cdj_Customs)]

            ,[]
            );
end;

procedure TBalances_RecTable.SetupTable;
begin
  TableName := 'Balances';
  SetFields(['Id','ClientId','GSTPeriodStarts','GSTPeriodEnds','ClosingDebtorsBalance','OpeningDebtorsBalance'
{2}    ,'FBTAdjustments','OtherAdjustments','ClosingCreditorsBalance','OpeningCreditorsBalance','CreditAdjustments'
{3}    ,'BASDocumentId','BAS1CPTLastMonthsIncome','BAS1DPTBranchIncome','BAS1EPTAssets','BAS1FPTTax','BAS1GPTRefundUsed'
{4}    ,'BAS5BPTRatio','BAS6B','BAS7','BASG7','BASG18','BASW1','BASW2','BASW3'
{5}    ,'BASW4','BAST1','BAST2','BAST3','BAST4','BASF1','BASF2','BASF3','BASF4'
{6}    ,'BASFormUsed','BASGSTOption','BASGSTIncluded','BASG21','BASG22','BASG23','BASG24'
{7}    ,'BASPAYGInstalmentOption','BAST7','BAST8','BAST9','BAS1H','BASAdjPrivUse','BASAdjBAssets'
{8}    ,'BASAdjAssets','BASAdjEntertain','BASAdjChange','BASAdjExempt','BASAdjOther','BASCdjBusUse'
{9}    ,'BASCdjPAssets','BASCdjChange','BASCdjOther','BAS7C','BAS7D','BAST6','BAST5'
{10}   ,'UsingFuelPercentMethod','PTFormType','BASCdjCustoms'],[]);
end;

{ TChartDivisionTable }

function TChartDivisionTable.Insert(MyID,
                   ChartID,
                   ClientId: TGuid;
                   Division: Integer
                   ): Boolean;
begin
   Result := RunValues([ToSQL(MyID),toSQL(Division),toSQL(ClientId),toSQL(ChartId)],[]);
end;

procedure TChartDivisionTable.SetupTable;
begin
   Tablename := 'ClientReportDivisionCharts';
   SetFields(['Id','DivisionIndex','Client_Id','Chart_Id'],[]);
end;

{ TReminderTable }

function TReminderTable.Insert(
                   MyID,
                   ClientID,
                   ByUser: TGuid;
                   ToDoItem: pClientToDoItem): Boolean;

begin with ToDoItem^ do
   Result := RunValues([ToSQL(MyID), ToSQL(ClientID), ToSQL(tdDate_Entered, tdTime_Entered), ToSQL(ByUser),
                  ToSQL(tdDescription)
             ,ToSQL(tdReminderDate), ToSQL(tdIs_Completed), DateToSQL(tdDate_Completed)],[]);
end;

procedure TReminderTable.SetupTable;
begin
   Tablename := 'Reminders';
   SetFields(['Id','Client_Id','DateEntered','EnteredBy','Action'
      ,'ReminderDate','Closed','DateClosed'],[]);

end;

{ TDownloadlogTable }

function TDownloadlogTable.Insert(MyiD, ClientID: TGuid;
                   Value: pDisk_Log_Rec): Boolean;
begin with Value^ do
   Result := RunValues([ToSQL(MyID), ToSQL(ClientID), ToSQL(dlDisk_ID)
                  ,DateToSQL(dlDate_Downloaded),ToSQL(dlNo_of_Accounts),ToSQL(dlNo_of_Entries)],[]);
end;

procedure TDownloadlogTable.SetupTable;
begin
   TableName := 'ClientDownloads';
   SetFields(['Id','ClientId_Id','DiskID','DateDownloaded','NoOfAccounts','NoOfEntries'], []);
end;

{ TFuelSheetTable }

function TFuelSheetTable.Insert(MyID, BalanceID: TGuid; value: pFuel_Sheet_Rec): Boolean;
begin  with Value^ do
   Result := RunValues([ToSQL(MyID), ToSQL(BalanceID), ToSQL(fsAccount)
                  ,ToSQL(fsFuel_Type),QtyToSQL(fsFuel_Litres),ToSQL(fsFuel_Use),PercentToSQL(fsPercentage)
                  ,ToSQL(fsFuel_Eligible), PercentToSQL(fsCredit_Rate)],[]);
end;

procedure TFuelSheetTable.SetupTable;
begin
  TableName := 'FuelSheets';
  SetFields(['Id','BalanceId','Account','FuelType','FuelLitres','FuelUse','Percentage'
      ,'FuelEligible','CreditRate'],[]);

end;

{ TBAS_OptionsTable }

function TBAS_OptionsTable.Insert(MyId, ClientID: TGuid; Value: pClient_Rec;
  More: pMoreClient_Rec): Boolean;
begin
   Result := RunValues([ToSQL(MyID), ToSQL(ClientID), ToSQL(More.mcBAS_Dont_Print_Fuel_Sheet), ToSQL(Value.clBAS_Include_Fuel), ToSQL(Value.clBAS_Calculation_Method)
               ,ToSQL(Value.clBAS_Dont_Print_Calc_Sheet), ToSQL(Value.clBAS_PAYG_Withheld_Period), ToSQL(Value.clBAS_Report_Format), ToSQL(Value.clBAS_PAYG_Instalment_Period)
               ,ToSQL(Value.clBAS_Include_FBT_WET_LCT), ToSQL(Value.clBAS_Last_GST_Option), ToSQL(Value.clBAS_Last_PAYG_Instalment_Option)],[]);
end;

procedure TBAS_OptionsTable.SetupTable;
begin
   TableName := 'BASOptions';
   SetFields(['Id', 'Client_Id','BASDontPrintFuelSheet','BASIncludeFuel','BASCalculationMethod'
      ,'BASDontPrintCalcSheet','BASPAYGWithheldPeriod','BASReportFormat','BASPAYGIncomeTaxPeriod'
      ,'BASIncludeFBTWETLCT','BASLastGSTOption','BASLastPAYGInstalmentOption'],[]);

end;

{ TNotesOptionsTable }

function TNotesOptionsTable.Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   Extra: pClientExtra_Rec;
                   Notification: Integer): Boolean;
begin with Value^ do
   Result := RunValues([ToSQL(MyID), ToSQL(ClientID), ToSQL(not clECoding_Dont_Allow_UPIs), ToSQL(not clECoding_Dont_Show_Account)
                 ,ToSQL(not value.clECoding_Dont_Show_Payees), ToSQL(not clECoding_Dont_Show_GST), ToSQL(not clECoding_Dont_Show_TaxInvoice)
{2}          ,ToSQL(clECoding_WebSpace), ToSQL(clECoding_Default_Password), ToSQL(clECoding_Import_Options), ToSQL(clECoding_Last_Import_Dir)
                  ,ToSQL(Value.clECoding_Last_Export_Dir)
{3}          ,ToSQL(clECoding_Entry_Selection), ToSQL(not clECoding_Dont_Send_Chart), ToSQL(not clECoding_Dont_Send_Payees), ToSQL(not clECoding_Dont_Show_Quantity)
                 ,ToSQL(clECoding_Last_File_No), ToSQL(clECoding_Last_File_No_Imported)
{4}          ,ToSQL(not Extra.ceECoding_Dont_Send_Jobs), ToSQL(clECoding_Send_Superfund)
                 ,ToSQL(Notification and wnDontNotifyMe = 0), TOSQL(Notification and wnDontNotifyClient = 0)],[]);
end;

procedure TNotesOptionsTable.SetupTable;
begin
   TableName := 'NotesOptions';
   SetFields(['Id', 'ClientId' ,'AllowUPIs' ,'ShowChart','ShowPayees','ShowGST','ShowTaxInvoice'
{2}      ,'WebSpace','DefaultPassword' ,'ImportOptions','LastImportDir','LastExportDir'
{3}      ,'EntrySelection','SendChart' ,'SendPayees' ,'ShowQuantity' ,'LastFileNo' ,'LastFileNoImported'
{4}      ,'SendJobs' ,'SendSuperfund' ,'SendtoClientonExport' ,'SendtoPracticeTransactionsAvailable'],[]);
end;

end.
