unit bkTables;

interface

uses
   UBatchBase,
   MoneyDef,
   MigrateTable,
   ToDoListUnit,
   ClientDetailCacheobj,
   syDefs, //  pClient_File_Rec
   bkDefs,
   globals,
   LogUtil;

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
                   Archived: Boolean;
                   FromMagicNumber: integer;
                   ToMagicNumber: integer;
                   SystemComments: string;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec;
                   AClient: pClient_File_Rec;
                   CheckedOutTo: TGuid): Boolean;

    function InsertProspect(MyId: TGuid;
                   UserID: TGuid;
                   GroupID: TGuid;
                   TypeID: TGuid;
                   Archived: Boolean;
                   Magic_Number: integer;
                   Country: Integer;
                   SystemComments: string;
                   ClientDetailsCache: TClientDetailsCache;
                   AClient: pClient_File_Rec
                  ): Boolean;
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

TClientReportTable  = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function InsertClient(MyId, ClientID: TGuid
                  ): Boolean;
   function InsertReport(MyiD, ClientID: TGuid; Report: TReportBase; SequenceNo: Integer):  Boolean;

end;

(*
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

*)
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
                   Value: pBank_Account_Rec;
                   Map: pClient_Account_Map_Rec;
                   Excluded: boolean
                   ): Boolean;
end;

TColumnConfigTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID, AccountID: TGuid;
     ScreenType: integer; Country: string; date: Integer ): Boolean;
end;

TColumnConfigColumnsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID, ConFigID : TGuid;
                   ColumnID : string;
                   Position : integer;
                   Width : Integer;
                   IsEditable : Boolean;
                   IsVisible: Boolean;
                   IsSortColumn: Boolean): Boolean;
end;


TTransaction_RecTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   AccountID: TGuid;
                   MatchedItemID: TGuid;
                   Value: PTransaction_Rec;
                   IsSplitPayee, IsDissected, IsSplitJob, IsPayeeOverridden, IsJobOverridden: boolean;
                   memID, MasterMemiD: TGuid): Boolean;
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
                   SequenceNo: Integer;
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

TBalances_ParamTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
   procedure AddMoney(BalanceID: TGuid; Name: string; value: Money; Force: Boolean = false);
   procedure AddRate(BalanceID: TGuid; Name: string; value: Money);
public
    function Insert(BalanceID: TGuid;
                   value: pBalances_Rec): Boolean;  virtual; abstract;
end;

TBalances_ParamTableNZ = class (TBalances_ParamTable)
public
  function Insert(BalanceID: TGuid;
                   value: pBalances_Rec): Boolean;  override;
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


TReportParameterTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function AddClient(MyId, ClientReportID: TGuid; Value: pClient_Rec;  Extra: pClientExtra_Rec): boolean;

   function Update(ParamName, ParamValue, ParamType: string; ClientReportID:TGuid): Boolean; overload;
   function Update(ParamName: string; ParamValue: Boolean; ClientReportID:TGuid): Boolean; overload;
   //function Update(ParamName: string; ParamValue: TGuid; ClientReportID:TGuid): Boolean; overload;
   function Update(ParamName: string; ParamValue: Integer; ClientReportID:TGuid): Boolean; overload;
   //function Update(ParamName: string; ParamValue: Money; ClientReportID:TGuid): Boolean; overload;
end;

TClientParameterTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Update(ParameterGroup, ParamName, ParamValue, ParamType: string; ClientID:TGuid): Boolean; //overload;
end;


implementation

uses
   Math,
   GstWorkRec,
   CustomDocEditorFrm,
   STDate,
   Variants,
   SysUtils,
   SQLHelpers,
   bkConst,
   PasswordHash;




(*******************************************************************************)

{ TClient_RecFieldsTable }

function TClient_RecFieldsTable.Insert(MyId: TGuid;
                   UserID: TGuid;
                   AccountingSystemID: TGuid;
                   TaxSystemID: TGuid;
                   GroupID: TGuid;
                   TypeID: TGuid;
                   Archived: Boolean;
                   FromMagicNumber: integer;
                   ToMagicNumber: integer;
                   SystemComments: string;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec;
                   AClient: pClient_File_Rec;
                   CheckedOutTo: TGuid): Boolean;



   function GetNotes: string;
   var I: Integer;
   begin
      Result := '';
      for i := Low( Value.clNotes) to High( Value.clNotes) do
         Result := Result + Value.clNotes[i];  // ?? cr
   end;

   function GetGSTRatio: Money;
   begin
      if  (Value.clCountry = whNewZealand)
      and (Value.clBAS_Field_Source[bfGSTProvisional] = GSTprovisional)
      and (Value.clBAS_Field_Number[bfGSTProvisional] = GSTRatio) then
         Result := Value.clBAS_Field_Percent[bfGSTProvisional] * 1000 // seems in one decimal place ??
      else
         Result := Unknown;
   end;

   function MagicNumber: integer;
   begin
      if value.clMagic_Number = fromMagicNumber then
         result :=  ToMagicNumber
      else
         result := value.clMagic_Number;
   end;

begin


  with Value^, Extra^, More^ do
    Result := RunValues([ToSQL(MyId),ToSQL(clCode),ToSQL(clName),ToSQL(clAddress_L1),ToSQL(clAddress_L2),ToSQL(clAddress_L3)
                 ,ToSQL(clContact_Name),ToSQL(clPhone_No),ToSQL(clFax_No),ToSQL(clClient_EMail_Address)
  {2}        ,ToSQL(clCountry),ToSQL(clBankLink_Connect_Password),ToSQL(clPIN_Number),DateToSQL(clFinancial_Year_Starts)
  {3}        ,ToSQL(clGST_Number),ToSQL(clGST_Period),ToSQL(clGST_Start_Month),ToSQL(clGST_Basis)
                ,ToSQL(clGST_Inclusive_Cashflow)
  {4}        ,ToSQL(AccountingSystemID),ToSQL(clAccount_Code_Mask),ToSQL(clLoad_Client_Files_From),ToSQL(clSave_Client_Files_To)
                 ,ToSQL(clChart_Is_Locked),DateToSQL(clChart_Last_Updated)
  {5}        ,ToSQL(MagicNumber),ToSQL(clException_Options),DateToSQL(clPeriod_Start_Date),DateToSQL(clPeriod_End_Date),ToSQL(clBankLink_Code)
  {6}        ,ToSQL(clDisk_Sequence_No),ToSQL(UserID),ToSQL(clSuppress_Check_for_New_TXns),ToSQL(clDownload_From),ToSQL(clLast_Batch_Number)
  {7}        ,ToSQL(clTax_Ledger_Code),ToSQL(clCheques_Expire_When),ToSQL(clShow_Notes_On_Open)
  {8}        ,ToSQL(clCflw_Cash_On_Hand_Style), DateToSQL(clLast_Financial_Year_Start),ToSQL(TaxSystemID),ToSQL(clSave_Tax_Files_To)
                ,ToSQL(clJournal_Processing_Period),ToSQL(clLast_Disk_Image_Version)
  {9}        ,ToSQL(clWeb_Site_Login_URL),ToSQL(clContact_Details_To_Show),ToSQL(clCustom_Contact_Name)
                ,ToSQL(clCustom_Contact_EMail_Address),ToSQL(clCustom_Contact_Phone)
  {10}       ,ToSQL(clHighest_Manual_Account_No),ToSQL(clCopy_Narration_Dissection),ToSQL(SystemComments)
  {11}       ,ToSQL(clClient_CC_EMail_Address),ToSQL(clLast_ECoding_Account_UID),{ToSQL(WebExportFormat),{}ToSQL(clMobile_No)
                ,ToSQL(clFile_Read_Only),ToSQL(clSalutation),ToSQL(clExternal_ID)
  {12}       ,ToSQL( clForce_Offsite_Check_Out),ToSQL(clDisable_Offsite_Check_Out),ToSQL(clAlternate_Extract_ID),ToSQL(clUse_Alterate_ID_for_extract)
  {13}       ,DateToSQL(AClient.cfDate_Last_Accessed),ToSQL(clUse_Basic_Chart),ToSQL(GroupID),ToSQL(TypeID)
                ,ToSQL(clAll_EditMode_CES),ToSQL(clAll_EditMode_DIS),ToSQL(clTFN)
  {14}       , ToSql(ceAllow_Client_Unlock_Entries),ToSQL(ceAllow_Client_Edit_Chart)
                ,ToSQL(ceBudget_Include_Quantities),ToSQL(Archived)
  {15}       , ToSQL(mcJournal_Processing_Duration),ToSQL( clBAS_Field_Source[bfGSTProvisional] = GSTprovisional)
                ,ToSql(clBAS_Field_Number[bfGSTProvisional] = GSTRatio),PercentToSQL(GetGSTRatio)
  {16}       , ToSQL(GetNotes),ToSQL(ceBook_Gen_Finance_Reports),ToSQL(not ceBlock_Client_Edit_Mems)
                ,PWToSQL(LowerCase(clFile_Password)),ToSQL(False),ToSQL(CheckedOutTo)],[]);
end;

function TClient_RecFieldsTable.InsertProspect(
                   MyId: TGuid;
                   UserID: TGuid;
                   GroupID: TGuid;
                   TypeID: TGuid;
                   Archived: Boolean;
                   Magic_Number: integer;
                   Country: Integer;
                   SystemComments: string;
                   ClientDetailsCache: TClientDetailsCache;
                   AClient: pClient_File_Rec
                  ):Boolean;
begin
with  AClient^, ClientDetailsCache do begin
  Result := RunValues([ToSQL(MyId),ToSQL(cfFile_Code),ToSQL(cfFile_Name),ToSQL(Address_L1),ToSQL(Address_L2),ToSQL(Address_L3)
               ,ToSQL(Contact_Name),ToSQL(Phone_No),ToSQL(Fax_No),ToSQL(EMail_Address)
{2}        ,ToSQL(Country),null,null,null
{3}        ,null,ToSQL(cfGST_Period),ToSQL(cfGST_Start_Month)
              ,null,null
{4}        ,null,null,null,null
               ,null,null
{5}        ,ToSQL(Magic_Number),null,null,null,null
{6}        ,null,ToSQL(UserID),null,null,null
{7}        ,null,null,null
{8}        ,null, DateToSQL(cfFinancial_Year_Starts),null,null
              ,null,null
{9}        ,null,ToSQL(cfContact_Details_To_Show),null
              ,null,null
{10}       ,null,null,ToSQL(SystemComments)
{11}       ,null,null{,null{},ToSQL(Mobile_No)
              ,null,ToSQL(Salutation),null
{12}       ,null,null,null,null
{13}       ,DateToSQL(cfDate_Last_Accessed),null,ToSQL(GroupID),ToSQL(TypeID)
              ,null,null,null
{14}       , null,null
              ,null,ToSQL(Archived)
{15}       , null,null
              ,null,null
{16}       , null,null,null
              ,PWToSQL(LowerCase(cfFile_Password)),ToSQL(True),null],[]);
end;
end;

procedure TClient_RecFieldsTable.SetupTable;
begin
  TableName := 'Clients';
  SetFields(['Id','Code','Name','AddressL1','AddressL2','AddressL3','ContactName','PhoneNo','FaxNo','EmailAddress'
{2}     ,'Country','BankLinkConnectPassword','PINNumber','FinancialYearStarts'
{3}     ,'GSTNumber','GSTPeriod','GSTStartMonth','GSTBasis','GSTInclusiveCashflow'
{4}     ,'AccountingSystemUsed','AccountCodeMask','LoadClientFilesFrom','SaveClientFilesTo','ChartIsLocked','ChartLastUpdated'
{5}     ,'MagicNumber','ExceptionOptions','PeriodStartDate','PeriodEndDate','BankLinkCode'
{6}     ,'DiskSequenceNo','StaffMemberId','SuppressCheckForNewTXns','DownloadFrom','LastBatchNumber'
{7}     ,'TaxLedgerCode','ChequesExpireWhen','ShowNotesOnOpen'
{8}     ,'CflwCashOnHandStyle','LastFinancialYearStart','TaxinterfaceUsed','SaveTaxFilesTo','JournalProcessingPeriod','LastDiskImageVersion'
{9}     ,'WebSiteLoginURL','ContactDetailsToShow','CustomContactName','CustomContactEMailAddress','CustomContactPhone'
{10}    ,'HighestManualAccountNo','CopyNarrationDissection','SystemComments'
{11}    ,'ClientCCEMailAddress','LastECodingAccountUID',{'WebExportFormat',{}'MobileNo','FileReadOnly','Salutation','ExternalID'
{12}    ,'ForceOffsiteCheckOut','DisableOffsiteCheckOut','AlternateExtractID','UseAlterateIDforextract'
{13}    ,'LastUseDate','UseBasicChart','ClientGroupId','ClientTypeId','AllEditModeCES','AllEditModeDIS','TFN'
{14}    ,'AllowClientUnlockEntries','AllowClientEditChart','BudgetIncludeQuantities','Archived'
{15}    ,'JournalProcessingDuration','GSTIncludeProvisionalTax','GSTUseRatioOption','GSTRatio'
{16}    ,'Comments','GenerateFinancialReports','EditMemorisations','Password','IsProspect','CheckedOutTo'],[]);

end;


(*******************************************************************************)

{ TAccount_RecTable }

function TAccount_RecTable.Insert(MyID: TGuid;
                   ClientID: TGuid;
                   Value: pBank_Account_Rec;
                   Map: pClient_Account_Map_Rec;
                   Excluded: boolean
                   ): Boolean;

    function LastScheduledReportDate : Variant;
    begin
        Result := null;
        if not assigned(map) then
           exit;
        Result := DateToSQL(map.amLast_Date_Printed);
    end;



begin with value^ do
  Result := RunValues([ ToSQL(MyId),ToSQL(ClientID),ToSQL(baBank_Account_Number),ToSQL(baBank_Account_Name)
              ,PWToSQL(LowerCase(baBank_Account_Password)),ToSQL(baContra_Account_Code)
 {2}     ,ToSQL(baCurrent_Balance),ToSQL(baApply_Master_Memorised_Entries),ToSQL(baAccount_Type)
              ,ToSQL(baPreferred_View),ToSQL(baHighest_BankLink_ID)
 {3}     ,ToSQL(baHighest_LRN),DateToSQL(baAccount_Expiry_Date),ToSQL(baHighest_Matched_Item_ID)
              ,ToSQL(baNotes_Always_Visible),TOSQL(baNotes_Height),ToSQL(baLast_ECoding_Transaction_UID)
 {4}     ,ToSQL(baExtend_Expiry_Date),ToSQL(baIs_A_Manual_Account),ToSQL(baAnalysis_Coding_Level)
              ,ToSQL(baECoding_Account_UID),ToSQL(baCoding_Sort_Order),ToSQL(baManual_Account_Type)
 {5}     ,ToSQL(baManual_Account_Institution),ToSQL(baManual_Account_Sent_To_Admin)
              ,ToSQL(baHDE_Sort_Order),ToSQL(baMDE_Sort_Order),ToSQL(baDIS_Sort_Order)
 {6}     ,ToSQL(baDesktop_Super_Ledger_ID), ToSQL(Value.baSuperFund_Ledger_Code),ToSql(baCurrency_Code)
              ,ToSQL(Excluded or baIs_A_Manual_Account), LastScheduledReportDate ],[]);

end;

procedure TAccount_RecTable.SetupTable;
begin
  TableName := 'BankAccounts';
  SetFields(['Id','Client_Id','BankAccountNumber','BankAccountName','BankAccountPassword','ContraAccountCode'
 {2}   , 'CurrentBalance','ApplyMasterMemorisedEntries','AccountType','PreferredView','HighestBankLinkID'
 {3}   , 'LastSequenceNo','AccountExpiryDate','HighestMatchedItemID','NotesAlwaysVisible','NotesHeight','LastECodingTransactionUID'
 {4}   , 'ExtendExpiryDate','IsAManualAccount','AnalysisCodingLevel','ECodingAccountUID','CodingSortOrder','ManualAccountType'
 {5}   , 'ManualAccountInstitution','ManualAccountSentToAdmin','HDESortOrder','MDESortOrder','DISSortOrder'
 {6}   , 'SFLedgerID','SFLedgerCode','Currency','ExcludedFromScheduledReports','LastScheduledReportDate'
       ],  []);

end;


(*******************************************************************************)

{ TColumnConfigTable }

function TColumnConfigTable.Insert(MyID, AccountID: TGuid;
  ScreenType: integer; Country: string; date: Integer ): Boolean;
begin
    Result := RunValues([ ToSQL(MyId), ToSQL(Name),ToSQL(AccountID),ToSQL(ScreenType),ToSQL(Country)
    ,ToSQL(0),DateToSQL(date)],[]);
end;

procedure TColumnConfigTable.SetupTable;
begin
  TableName := 'CodingColumnConfigurations';
   SetFields(['Id', 'Name', 'BankAccount_Id',  'ScreenType', 'Country',
   'IsDefault', 'DateCreated'],[]);
end;


(*******************************************************************************)

{ TColumnConfigColumnsTable }

function TColumnConfigColumnsTable.Insert(MyID, ConFigID: TGuid; ColumnID: string;
  Position, Width: Integer; IsEditable, IsVisible,
  IsSortColumn: Boolean): Boolean;
begin
   Result := RunValues([ToSQL(MyId), ToSQL(ColumnID), ToSQL(Position), ToSQL(Width), ToSQL(IsVisible)
    ,ToSQL(IsEditable),ToSQL(IsSortColumn),ToSql(0), ToSQL(ConFigID)],[]);
end;

procedure TColumnConfigColumnsTable.SetupTable;
begin
   TableName := 'CodingColumns';
   SetFields(['Id', 'ColumnId', 'Position',  'Width', 'IsVisible',
   'IsEditable', 'IsSortColumn', 'SortAscending', 'CodingColumnConfiguration_Id' ],[]);

end;


(*******************************************************************************)

{ TTransaction_RecTable }

function TTransaction_RecTable.Insert(MyID, AccountID,MatchedItemID: TGuid;
  Value: PTransaction_Rec; IsSplitPayee, IsDissected, IsSplitJob, IsPayeeOverridden,
  IsJobOverridden: boolean;
   memID, MasterMemiD: TGuid): Boolean;

   function ChartCode: string;
   begin
      if IsDissected then
         Result := '' // Don't want 'Dissected'
      else
         Result := Value^.txAccount

   end;

begin  with Value^ do
  Result := RunValues([ ToSQL(MyId),ToSQL(AccountID),ToSQL(txSequence_No)
                  ,ToSQL(txType),ToSQL(txSource),DateToSQL(txDate_Presented),DateToSQL(txDate_Effective)
{2}       ,DateToSQL(txDate_Transferred),ToSQL(txAmount) ,ToSQL(txGST_Class),ToSQL(txGST_Amount)
                  ,ToSQL(txHas_Been_Edited),QtyToSQL(txQuantity),ToSQL(txCheque_Number)
{3}       ,ToSQL(txReference),ToSQL(txParticulars),ToSQL(txAnalysis), ToSQL(txOrigBB), ToSQL(txOther_Party)
                  ,ToSQL(ChartCode), ToSQL(txCoded_By)
{4}       ,nullToSQL(txPayee_Number),ToSQL(txLocked),ToSQL(txBankLink_ID),ToSQL(txGST_Has_Been_Edited)
                  ,ToSQL(MatchedItemID), ToSQL(txUPI_State), ToSQL(txOriginal_Reference)
{5}       ,ToSQL(txOriginal_Source),ToSQL(txOriginal_Type),ToSQL(txOriginal_Cheque_Number),ToSQL(txOriginal_Amount)
                  ,ToSQL(txNotes),ToSQL(txECoding_Import_Notes)
{6}       ,ToSQL(txECoding_Transaction_UID), ToSQL(txGL_Narration), ToSQL(txStatement_Details), ToSQL(txTax_Invoice_Available)
{7}       ,ToSQL(txExternal_GUID),ToSQl(txDocument_Title),ToSQL(txJob_Code)
{8}       ,ToSQL(txDocument_Status_Update_Required),ToSQL(txBankLink_UID),ToSQL(txNotes_Read),ToSQL(txImport_Notes_Read)
{9}       ,ToSQL(IsDissected),ToSQL(IsSplitPayee),ToSQL(IsSplitJob),ToSQL(IsPayeeOverridden),ToSQL(IsJobOverridden), ToSQL(0)
{10}      ,ToSQL(memID), ToSQL(MasterMemiD) ],[

          // SMSF
{1}       ToSQL(value.txSF_Super_Fields_Edited ), ToSQL(txSF_Franked),ToSQL(txSF_UnFranked),
{2}       ToSQL(txSF_Member_ID), ToSQL(txSF_Fund_ID ), ToSQL(txSF_Fund_Code),

{3}       ToSQL(txSF_Transaction_ID), ToSQL(txSF_Transaction_Code), ToSQL(txSF_Member_Account_ID), ToSQL(txSF_Member_Account_Code), null,

{4}       ToSQL(txSF_Member_Component), ToSQL(txSF_Other_Expenses), ToSQL(txSF_Interest), ToSQL(txSF_Rent),
              ToSQL(txSF_Special_Income), null,

{5}       ToSQL(txSF_Tax_Free_Dist), ToSQL(txSF_Tax_Exempt_Dist), ToSQL(txSF_Tax_Deferred_Dist), ToSQL(txSF_TFN_Credits),
              ToSQL(txSF_Other_Tax_Credit), ToSQL(txSF_Non_Resident_Tax),

{6}       ToSQL(txSF_Foreign_Income), ToSQL(txSF_Foreign_Tax_Credits), ToSQL(txSF_Capital_Gains_Indexed),
               ToSQL(txSF_Capital_Gains_Disc),

{7}       ToSQL(txSF_Capital_Gains_Other), ToSQL(txSF_Capital_Gains_Foreign_Disc), ToSQL(txSF_Foreign_Capital_Gains_Credit),

{8}       DateToSQl(txSF_CGT_Date), ToSQL(txSF_Capital_Gains_Fraction_Half)

]);
end;

procedure TTransaction_RecTable.SetupTable;
begin
  TableName := 'Transactions';
  SetFields(['Id','BankAccount_Id','SequenceNo','Type','Source','DatePresented','DateEffective'
{2}       ,'DateTransferred','Amount','GSTClass','GSTAmount','HasBeenEdited','Quantity','ChequeNumber'
{3}       ,'Reference','Particulars','Analysis','OrigBB','OtherParty','ChartCode','CodedBy'
{4}       ,'PayeeNumber','Locked','BankLinkID','GSTHasBeenEdited','MatchedItemID','UPIState','OriginalReference'
{5}       ,'OriginalSource','OriginalType','OriginalChequeNumber','OriginalAmount','Notes','ECodingImportNotes'
{6}       ,'ECodingTransactionUID','GLNarration','StatementDetails' ,'TaxInvoiceAvailable'
{7}       ,'ExternalGUID','DocumentTitle','JobCode'
{8}       ,'DocumentStatusUpdateRequired','BankLinkUID','NotesRead','ImportNotesRead'
{9}       ,'IsDissected','IsSplitPayee','IsSplitJob','IsPayeeOverridden','IsJobOverridden', 'ReportStatus'
{10}      ,'MemorisationID', 'MasterMemorisationID'
          ],SFLineFields);


end;


(*******************************************************************************)

{ TDissection_RecTable }

function TDissection_RecTable.Insert(MyID, TransactionID: TGuid;
  Value: PDissection_Rec): Boolean;

  function GetPercent : Variant;
  begin
     if value.dsAmount_Type_Is_Percent then
        Result := PercentToSQL(value.dsPercent_Amount)
     else
        Result := null;
  end;

   function GetLineType : Variant;
  begin
     if value.dsAmount_Type_Is_Percent then
        Result := ToSQL(0)
     else
        Result := ToSQL(1)
  end;


begin with Value^ do
   Result := RunValues([ ToSQL(MyId),ToSQL(TransactionID),ToSQL(dsSequence_No)
{2}       ,ToSQL(dsAmount),GetPercent, GetLineType ,ToSQL(dsGST_Class),ToSQL(dsGST_Amount)
                  ,ToSQL(dsHas_Been_Edited),QtyToSQL(dsQuantity),ToSQL(dsReference)
{3}       ,ToSQL(dsAccount),nullToSQL(dsPayee_Number),ToSQL(dsGST_Has_Been_Edited)
{4}       ,ToSQL(dsNotes),ToSQL(dsECoding_Import_Notes),ToSQL(dsGL_Narration), ToSQL(dsTax_Invoice)
{5}       ,ToSQL(dsExternal_GUID),ToSQl(dsDocument_Title),ToSQL(dsJob_Code)
{8}       ,ToSQL(dsDocument_Status_Update_Required),ToSQL(dsNotes_Read),ToSQL(dsImport_Notes_Read),ToSQL(value.dsJournal_Type)

   ],[
{1}       ToSQL(value.dsSF_Super_Fields_Edited ), ToSQL(dsSF_Franked),ToSQL(dsSF_UnFranked),
{2}       ToSQL(dsSF_Member_ID), ToSQL(dsSF_Fund_ID ), ToSQL(dsSF_Fund_Code),

{3}       ToSQL(dsSF_Transaction_ID), ToSQL(dsSF_Transaction_Code), ToSQL(dsSF_Member_Account_ID), ToSQL(dsSF_Member_Account_Code), null,

{4}       ToSQL(dsSF_Member_Component), ToSQL(dsSF_Other_Expenses), ToSQL(dsSF_Interest), ToSQL(dsSF_Rent),
              ToSQL(dsSF_Special_Income), null,

{5}       ToSQL(dsSF_Tax_Free_Dist), ToSQL(dsSF_Tax_Exempt_Dist), ToSQL(dsSF_Tax_Deferred_Dist), ToSQL(dsSF_TFN_Credits),
              ToSQL(dsSF_Other_Tax_Credit), ToSQL(dsSF_Non_Resident_Tax),

{6}       ToSQL(dsSF_Foreign_Income), ToSQL(dsSF_Foreign_Tax_Credits), ToSQL(dsSF_Capital_Gains_Indexed),
               ToSQL(dsSF_Capital_Gains_Disc),

{7}       ToSQL(dsSF_Capital_Gains_Other), ToSQL(dsSF_Capital_Gains_Foreign_Disc), ToSQL(dsSF_Foreign_Capital_Gains_Credit),

{8}       DateToSQl(dsSF_CGT_Date), ToSQL(dsSF_Capital_Gains_Fraction_Half)]);
end;

procedure TDissection_RecTable.SetupTable;
begin
 TableName := 'Dissections';
  SetFields(['Id','Transaction_Id','SequenceNo'
{2}       ,'Amount','Percentage','LineType','GSTClass','GSTAmount','HasBeenEdited','Quantity','Reference'
{3}       ,'ChartCode','PayeeNumber','GSTHasBeenEdited'
{4}       ,'Notes','ECodingImportNotes','GLNarration','TaxInvoiceAvailable'
{5}       ,'ExternalGUID','DocumentTitle','JobCode'
{6}       ,'DocumentStatusUpdateRequired','NotesRead','ImportNotesRead' ,'JournalType'

          ],SFLineFields);



end;


(*******************************************************************************)

{ TMemorisation_Detail_RecTable }

function TMemorisation_Detail_RecTable.Insert(MyID, AccountID,
      AccountingSystemID: TGuid; SequenceNo: Integer;
      Value: pMemorisation_Detail_Rec): Boolean;

begin with Value^ do
 Result := RunValues([ ToSql(MyID),ToSql(AccountID),ToSQL(SequenceNo),ToSQL(mdType)
               ,ToSQL(mdAmount),ToSQL(mdReference),ToSQL(mdParticulars)
{2}      ,ToSQL(mdAnalysis),ToSQL(mdOther_Party),ToSQL(mdStatement_Details)
               ,ToSQL(mdMatch_on_Amount <> 0),ToSQL(mdMatch_on_Analysis)
{3}      ,ToSQL(mdMatch_on_Other_Party),ToSQL(mdMatch_on_Notes)
               ,ToSQL(mdMatch_on_Particulars), ToSQL(mdMatch_on_Refce)
{4}      ,ToSQL(mdMatch_On_Statement_Details),NullToSQL(mdPayee_Number)
               ,ToSQL(mdFrom_Master_List),ToSQL(mdNotes ), ToSQL(Value.mdMatch_on_Amount)
{5}      ,DateToSQL(mdDate_Last_Applied),ToSQL(mdUse_Accounting_System)
               ,ToSQL(AccountingSystemID),DateToSQL(mdFrom_Date),DateToSQL(mdUntil_Date)],[]);

end;

procedure TMemorisation_Detail_RecTable.SetupTable;
begin
  TableName := 'Memorisations';
  SetFields(['Id','BankAccount_Id','SequenceNo','MemorisationType','Amount','Reference','Particulars'
{2}       ,'Analysis','OtherParty','StatementDetails','MatchOnAmount','MatchOnAnalysis'
{3}       ,'MatchOnOther_Party','MatchOnNotes','MatchOnParticulars','MatchOnRefce'
{4}       ,'MatchOnStatement_Details','PayeeNumber','FromMasterList','Notes' , 'MatchOnAmountType'
{5}       ,'DateLastApplied','UseAccountingSystem','AccountingSystem','FromDate','UntilDate'],[]);

end;


(*******************************************************************************)

{ TMemorisation_Line_RecTable }

function TMemorisation_Line_RecTable.Insert(MyID, MemorisationID: TGuid;
  SequenceNo: Integer; Value: pMemorisation_Line_Rec): Boolean;

   function Amount : variant;
  begin
      if value.mlLine_Type = mltDollarAmt then
         result := ToSQL(value.mlPercentage)
      else
         result := null;
  end;

  function percentage : variant;
  begin
      if value.mlLine_Type = mltPercentage then
         result := PercentToSQL(value.mlPercentage)
      else
         result := null;
  end;
begin with Value^ do
  Result := RunValues([ ToSql(MyID),ToSql(MemorisationID),ToSQL(SequenceNo),Percentage
               ,ToSQL(mlGST_Class),ToSQL(mlGST_Has_Been_Edited)
{2}       , NullToSQL(mlPayee), ToSQL(mlGL_Narration) ,ToSQL(mlLine_Type)
               ,Amount ,ToSQL(mlAccount),ToSQL(mlJob_code), QtyToSQL(mlQuantity)

   ],[

{1}       ToSQL(mlSF_Edited), PercentToSQL(mlSF_PCFranked),PercentToSQL(mlSF_PCUnFranked),
{2}       ToSQL(mlSF_Member_ID), ToSQL(mlSF_Fund_ID ), ToSQL(mlSF_Fund_Code),

{3}       ToSQL(mlSF_Trans_ID), ToSQL(mlSF_Trans_Code), ToSQL(mlSF_Member_Account_ID), ToSQL(mlSF_Member_Account_Code), null,

{4}       ToSQL(mlSF_Member_Component), PercentToSQL(mlSF_Other_Expenses), PercentToSQL(mlSF_Interest), PercentToSQL(mlSF_Rent),
              PercentToSQL(mlSF_Special_Income), null,

{5}       PercentToSQL(mlSF_Tax_Free_Dist), PercentToSQL(mlSF_Tax_Exempt_Dist), PercentToSQL(mlSF_Tax_Deferred_Dist), PercentToSQL(mlSF_TFN_Credits),
              PercentToSQL(mlSF_Other_Tax_Credit), PercentToSQL(mlSF_Non_Resident_Tax),

{6}       PercentToSQL(mlSF_Foreign_Income), PercentToSQL(mlSF_Foreign_Tax_Credits), PercentToSQL(mlSF_Capital_Gains_Indexed),
               PercentToSQL(mlSF_Capital_Gains_Disc),

{7}       PercentToSQL(mlSF_Capital_Gains_Other), PercentToSQL(mlSF_Capital_Gains_Foreign_Disc), PercentToSQL(mlSF_Foreign_Capital_Gains_Credit),


{8}       DateToSQl(mlSF_GDT_Date), ToSQL(mlSF_Capital_Gains_Fraction_Half)
    ]);

end;

procedure TMemorisation_Line_RecTable.SetupTable;
begin
  TableName := 'MemorisationLines';

  SetFields([ 'Id','Memorisation_Id','SequenceNo','Percentage','GSTClass','GSTHasBeenEdited'
           ,'PayeeNumber','GLNarration','LineType','Amount','ChartCode','JobCode','Quantity'

   ],SFLineFields);

end;


(*******************************************************************************)

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
  SetFields(['Id','Client_Id','AccountCode','AlternateCode','AccountDescription','GSTClass'
{2}      ,'PostingAllowed','ReportGroup','EnterQuantity','MoneyVariance_Up'
{3}      ,'MoneyVariance_Down','PercentVariance_Up','PercentVariance_Down'
{4}      ,'ReportGroupSubGroup','LinkedAccount_OS','LinkedAccount_CS','HideInBasicChart'],[]);

end;


(*******************************************************************************)

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


(*******************************************************************************)

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


(*******************************************************************************)

{ TPayee_Line_RecTable }

function TPayee_Line_RecTable.Insert(SequenceNo: Integer; MyID, PayeeID: TGuid;
  Value: pPayee_Line_Rec): Boolean;

  function Amount : variant;
  begin
      if value.plLine_Type = mltDollarAmt then
         result := ToSQL(value.plPercentage)
      else
         result := null;
  end;

  function percentage : variant;
  begin
      if value.plLine_Type = mltPercentage then
         result := PercentToSQL(value.plPercentage)
      else
         result := null;
  end;

begin with Value^ do
    Result := RunValues([ToSQL(MyID),ToSQL(PayeeID),Percentage
               ,ToSQL(plGST_Class),ToSQL(plGST_Has_Been_Edited)
{2}        ,ToSQL(plGL_Narration),ToSQL(plLine_Type), Amount
               ,ToSQL(plAccount),ToSQL(SequenceNo),QtyToSQL(plQuantity)

    ],[

{1}       ToSQL(plSF_Edited), PercentToSQL(plSF_PCFranked), PercentToSQL(plSF_PCUnFranked),
{2}       ToSQL(plSF_Member_ID), ToSQL(plSF_Fund_ID ), ToSQL(plSF_Fund_Code),

{3}       ToSQL(plSF_Trans_ID), ToSQL(plSF_Trans_Code), ToSQL(plSF_Member_Account_ID), ToSQL(plSF_Member_Account_Code), toSQL(plSF_Ledger_ID),

{4}       ToSQL(plSF_Member_Component), PercentToSQL(plSF_Other_Expenses), PercentToSQL(plSF_Interest), PercentToSQL(plSF_Rent),
              PercentToSQL(plSF_Special_Income), null,

{5}       PercentToSQL(plSF_Tax_Free_Dist), PercentToSQL(plSF_Tax_Exempt_Dist), PercentToSQL(plSF_Tax_Deferred_Dist), PercentToSQL(plSF_TFN_Credits),
              PercentToSQL(plSF_Other_Tax_Credit), PercentToSQL(plSF_Non_Resident_Tax),

{6}       PercentToSQL(plSF_Foreign_Income), PercentToSQL(plSF_Foreign_Tax_Credits), PercentToSQL(plSF_Capital_Gains_Indexed),
               PercentToSQL(plSF_Capital_Gains_Disc),

{7}       PercentToSQL(plSF_Capital_Gains_Other), PercentToSQL(plSF_Capital_Gains_Foreign_Disc), PercentToSQL(plSF_Foreign_Capital_Gains_Credit),

{8}       DateToSQl(plSF_GDT_Date), ToSQL(plSF_Capital_Gains_Fraction_Half) ]);

end;

procedure TPayee_Line_RecTable.SetupTable;
begin
  TableName := 'PayeeLines';
  SetFields(['Id','Payee_Id','Percentage','GSTClass','GSTHasBeenEdited'
{2}      , 'GLNarration','LineType','Amount','ChartCode','SequenceNo', 'Quantity'

       ],SFLineFields);


end;


(*******************************************************************************)

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


(*******************************************************************************)

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


(*******************************************************************************)

{ TBudget_Detail_RecTable }

function TBudget_Detail_RecTable.Insert(MyID, BudgetID: TGuid; Period: Integer;
  Value: pBudget_Detail_Rec): Boolean;
  // Have to work out the what's set...
  // Budgets have a different scale, see BudgetUnitPriceEntry

  function RemakeQty: Money;
  begin
     result := Value^.bdQty_Budget[Period];
     if (result = 0)
     or (result = Unknown) then
        result := 10000;
  end;

  function RemakeEach : Money;
  begin
     result := Value^.bdEach_Budget[Period];
     if (result = 0)
     or (result = Unknown) then
        result := Value^.bdBudget[Period] * 10000;
  end;

begin with Value^ do
  Result := RunValues([ ToSQL(MyID),ToSQL(BudgetID),ToSQL(bdAccount_Code),ToSQL(Period),
                   ToSQL(Trunc(RoundTo(bdBudget[Period],0))),QtyToSQL(RemakeQty),QtyToSQL(RemakeEach)],[]);
end;

procedure TBudget_Detail_RecTable.SetupTable;
begin
  TableName := 'BudgetLines';
  SetFields(['Id','Budget_Id','AccountCode','Period','Amount','Quantity','Each'],[]);
end;



(*******************************************************************************)

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


(*******************************************************************************)

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
  SetFields(['Id','TaxClassType_Id','Client_Id','TaxId','SequenceNo','ClassDescription','ControlAccount','Norm'],[]);
end;


(*******************************************************************************)

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


(*******************************************************************************)

{ TClient_ScheduleTable }

function TClient_ScheduleTable.Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   More: pMoreClient_Rec;
                   Extra: pClientExtra_Rec): Boolean;

    function GetMonth(Date: Integer): Integer;
    var t: Integer;
    begin
       stDate.StDateToDMY(Date, t, result, t);
    end;

begin with Value^, Extra^ do
  Result := RunValues([ToSQL(MyID), ToSQL(ClientID), ToSQL(clScheduled_Coding_Report_Style)
              ,ToSQL(clScheduled_Coding_Report_Sort_Order), GetMonth(value.clReport_Start_Date)

{2}       ,ToSQL(clScheduled_Coding_Report_Entry_Selection), ToSQL(clScheduled_Coding_Report_Blank_Lines)
              ,ToSql(clScheduled_Coding_Report_Rule_Line), ToSQL(clScheduled_Coding_Report_New_Page)

{3}       ,ToSQL(clScheduled_Coding_Report_Print_TI), ToSQL(clScheduled_Coding_Report_Show_OP)
              ,ToSQL(clScheduled_Coding_Report_Wrap_Narration)
              ,ToSQL(not (clFax_Scheduled_Reports
                      or clCheckOut_Scheduled_Reports
                      or clECoding_Export_Scheduled_Reports
                      or clWebX_Export_Scheduled_Reports
                      or clEmail_Scheduled_Reports))

{4}       ,ToSQL(clEmail_Scheduled_Reports), ToSQL(clFax_Scheduled_Reports), ToSQL(clCheckOut_Scheduled_Reports)
              ,ToSQL(Extra.ceOnline_Scheduled_Reports), ToSQL(clWebX_Export_Scheduled_Reports), ToSQL(clCSV_Export_Scheduled_Reports)
              ,ToSQL(Value.clECoding_Export_Scheduled_Reports)
              ,ToSQL(clBusiness_Products_Scheduled_Reports), ToSQL(clSend_Coding_Report)

{5}       ,ToSQL(clSend_Chart_of_Accounts), ToSQL(clSend_Payee_List), ToSQL(Extra.ceSend_Job_List)
              , ToSQL(clReporting_Period) , ToSQL(extra.ceSend_Custom_Documents)

{6}       ,ToSQL(clScheduled_Client_Note_Message), ToSQL(clEmail_Report_Format), ToSQL(ceScheduled_Custom_CR_XML)
              ,ToSQL(ceScheduled_CR_Column_Line)

              ],[]);
end;

procedure TClient_ScheduleTable.SetupTable;
begin
  TableName := 'ScheduledTaskValues';
  SetFields(['Id','Client_Id','CodingReportStyle','CodingReportSortOrder', 'ReportYearStartMonth'

{2}      ,'CodingReportEntrySelection','CodingReportBlankLines','CodingReportRuleLineBetweenEntries','CodingReportNewPage'

{3}      ,'CodingReportShowTaxInvoice','CodingReportShowOtherParty','CodingReportWrapNarration','TaskPrint'

{4}      ,'TaskEmail','TaskFax','TaskCheckOut','TaskOnlineCheckOut','TaskWebExport','TaskCSVExport','TaskSendNotes','TaskBusinessProduct','SendCoding'

{5}      ,'SendChart','Sendpayees','SendJobs', 'ReportingPeriod' ,'IncludeCustomDocument'

{6}      ,'ClientNoteMessage','EmailReportFormat','CustomCodingReportXML','CodingReportRuleLineBetweenColumns'
     ],[]);

end;

(*

(*******************************************************************************

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
   SetFields(['Id' ,'ClientId' ,'ReportingYearStarts'
{2}      ,'LedgerReportSummary','LedgerReportShowNotes','LedgerReportShowQuantities','LedgerReportShowNonTrf'
{3}      ,'LedgerReportShowInactiveCodes','LedgerReportBankContra','LedgerReportGSTContra','LedgerReportShowBalances'
{4}      ,'LedgerReportShowGrossAndGST','BusinessProductsReportFormat'
{5}      ,'LedgerReportWrapNarration','ProfitReportShowPercentage','FavouriteReportXML'
{6}      ,'CustomLedgerReport','CustomLedgerReportXML','BookGenFinanceReports' ],[]);
end;

*)

(*******************************************************************************)

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

(*******************************************************************************)

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
  SetFields(['Id','Client_Id','FRSShowYTD','FRSShowVariance','FRSCompareType'
      ,'FRSReportingPeriodType','FRSReportStyle','FRSReportDetailType','FRSPromptUsertouseBudgetedfigures'
      ,'FRSPrintNPChartCodeTitles','FRSNPChartCodeDetailType','FRSShowQuantity','FRSPrintChartCodes'
      ],[]);
end;

(*******************************************************************************)

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
  SetFields(['Id','Client_Id','ReportStyle','SortOrder','EntrySelection'
      ,'BlankLines','RuleLine','NewPage','CustomXML'
{3}   ,'WrapNarration', 'ShowOtherParty','ShowTaxInvoice'
{4}   ,'CustomReport','ColumnLine'],[]);

end;

(*******************************************************************************)

{ TBalances_RecTable }
(*

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
  SetFields(['Id','Client_Id','GSTPeriodStarts','GSTPeriodEnds','ClosingDebtorsBalance','OpeningDebtorsBalance'
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
  *)


function TBalances_RecTable.Insert(MyID: TGuid;
                   ClientID: TGuid;
                   value: pBalances_Rec): Boolean;
begin
    Result := RunValues([ToSQL(MyID),DateToSQL(value.blGST_Period_Starts),DateToSQL(value.blGST_Period_Ends),ToSQL(ClientID)],[]);
end;

procedure TBalances_RecTable.SetupTable;
begin
  TableName := 'TaxReturns';
  SetFields(['Id','PeriodStart','PeriodEnd','Client_Id'],[])
end;

(*******************************************************************************)
{ TBalances_ParamTable }


procedure TBalances_ParamTable.AddMoney(BalanceID: TGuid; Name: string; value: Money; Force: Boolean = false);
begin
   if Force then begin
      // The force, makes sure the entry is saved, so Practice-7 knows it needs to show the tab..
      if (value = 0) then begin
         RunValues([ToSQL(NewGuid),name,'decimal','0.00', ToSql(BalanceID)],[]);
         exit; // Done..
      end;
      if (value = Unknown) then begin
         RunValues([ToSQL(NewGuid),name,'decimal','null', ToSql(BalanceID)],[]);
         exit; // Done..
      end

   end else
      if (value = 0)
      or (value = Unknown) then
        Exit; // Don't need to save..

   RunValues([ToSQL(NewGuid),name,'decimal',FormatFloat('0.00', Value/100),ToSql(BalanceID)],[]);
end;

procedure TBalances_ParamTable.AddRate(BalanceID: TGuid; Name: string;
  value: Money);
begin
  if (value = 0)
  or (value = Unknown) then
      Exit; // Don't need to save..
   RunValues([ToSQL(NewGuid),name,'decimal',FormatFloat('0.0', Value/10),ToSql(BalanceID)],[]);
end;

procedure TBalances_ParamTable.SetupTable;
begin
   TableName := 'TaxReturnParameters';
   SetFields(['Id','ParameterName','ParameterType','ParameterValue','TaxReturn_Id'],[])
end;


{ TBalances_ParamTableNZ }

function TBalances_ParamTableNZ.Insert(BalanceID: TGuid;
  value: pBalances_Rec): Boolean;
begin
     Result := True;

         // Work out Form Period  GSTRateChangeDate = 150023;  // 1/10/2010
     if (value.blGST_Period_Ends > GSTRateChangeDate)
     and (value.blGST_Period_Starts < GSTRateChangeDate) then begin
         // Transitional..
         // Could move all the Part2 (B) bits here, but is much harder to read / check
         // Its only the Opening and Closing Debtors and creditors that is a bit odd
         // Delphi keeps the overall closing ballance in the same place, so you know where to find it as an opening balance default

         AddMoney(BalanceID, 'GST_101_Workpaper_PurchasesFromLedger_PlusClosingCreditors', value.blBAS_G21_GST_Closing_Creditors_BalanceA);
         AddMoney(BalanceID, 'GST_101_Workpaper_PlusClosingDebtors',  value.blBAS_F1_GST_Closing_Debtors_BalanceA );


         AddMoney(BalanceID, 'GST_101_Workpaper_PurchasesFromLedger_PlusClosingCreditors_Part2', value.blClosing_Creditors_Balance);
         AddMoney(BalanceID, 'GST_101_Workpaper_PlusClosingDebtors_Part2',  value.blClosing_Debtors_Balance);
     end else begin
         // Normal
         AddMoney(BalanceID, 'GST_101_Workpaper_PlusClosingDebtors',  value.blClosing_Debtors_Balance );
         AddMoney(BalanceID, 'GST_101_Workpaper_PurchasesFromLedger_PlusClosingCreditors', value.blClosing_Creditors_Balance);

     end;
     // GST 'FromLedger' Invoice basis, Optional Panel

     AddMoney(BalanceID, 'GST_101_Workpaper_LessOpeningDebtors',        value.blOpening_Debtors_Balance );
     AddMoney(BalanceID, 'GST_101_Workpaper_LessOpeningDebtors_Part2', Value.blBAS_F2_GST_Opening_Debtors_BalanceB);

     AddMoney(BalanceID, 'GST_101_Workpaper_PurchasesFromLedger_LessOpeningCreditors', value.blOpening_Creditors_Balance);
     AddMoney(BalanceID, 'GST_101_Workpaper_PurchasesFromLedger_LessOpeningCreditors_Part2', value.blBAS_G22_GST_Opening_Creditors_BalanceB);

     // Payment Tab, Need atleast one of these to show the tab..
     AddMoney(BalanceID, 'GST_103B_PaymentCalculation_CompulsoryOrVoluntaryTax', value.blBAS_1F_PT_Tax, TFormType(Value.blPT_Form_Type) in [GST103Bc, GST103Bv]);
     AddMoney(BalanceID, 'GST_103B_PaymentCalculation_TransferToProvisional', value.blBAS_1G_PT_Refund_Used, TFormType(Value.blPT_Form_Type) in [GST103Bc, GST103Bv]);

     // Provisional tab, Need at least one of these to show the tab..
     AddMoney(BalanceID, 'GST_103B_ProvisionalTax_AdjustmentForTheAssetsWorth', value.blBAS_1E_PT_Assets, TFormType(Value.blPT_Form_Type) in [GST103Bc]);
     AddMoney(BalanceID, 'GST_103B_ProvisionalTax_MonthlyTotalSalesAndIncome', value.blBAS_1C_PT_Last_Months_Income, TFormType(Value.blPT_Form_Type) in [GST103Bc]);
     AddMoney(BalanceID, 'GST_103B_ProvisionalTax_OtherBranchesTotalSalesAndIncome', value.blBAS_1D_PT_Branch_Income, TFormType(Value.blPT_Form_Type) in [GST103Bc]);

     AddRate(BalanceID, 'GST_103B_ProvisionalTax_Ratio',Value.blBAS_5B_PT_Ratio);



     // 372 work sheet
     AddMoney(BalanceID, 'GST_372_Adjustments_PrivateUseGoodsAndServices', value.blGST_Adj_PrivUse);
     AddMoney(BalanceID, 'GST_372_Adjustments_PrivateUseGoodsAndServices_Part2', value.blBAS_6B_GST_Adj_PrivUse);

     AddMoney(BalanceID, 'GST_372_Adjustments_BusinessAssetsUsedPrivately', value. blGST_Adj_BAssets);
     AddMoney(BalanceID, 'GST_372_Adjustments_BusinessAssetsUsedPrivately_Part2', value.blBAS_7_VAT4_GST_Adj_BAssets);

     AddMoney(BalanceID, 'GST_372_Adjustments_AssetsKeptAfterCeasing', value.blGST_Adj_Assets);
     AddMoney(BalanceID, 'GST_372_Adjustments_AssetsKeptAfterCeasing_Part2', value.blBAS_G7_GST_Adj_Assets);

     AddMoney(BalanceID, 'GST_372_Adjustments_EntertainmentExpenses', value.blGST_Adj_Entertain);
     AddMoney(BalanceID, 'GST_372_Adjustments_EntertainmentExpenses_Part2', value.blBAS_G18_GST_Adj_Entertain);

     AddMoney(BalanceID, 'GST_372_Adjustments_ChangeOfAccountingBasis', value.blGST_Adj_Change);
     AddMoney(BalanceID, 'GST_372_Adjustments_ChangeOfAccountingBasis_Part2', value.blBAS_W1_GST_Adj_Change);


     AddMoney(BalanceID, 'GST_372_Adjustments_GoodsAndServicesUsedInMakingExemptSupplies', value.blGST_Adj_Exempt);
     AddMoney(BalanceID, 'GST_372_Adjustments_GoodsAndServicesUsedInMakingExemptSupplies_Part2', value.blBAS_W2_GST_Adj_Exempt);

     AddMoney(BalanceID, 'GST_372_Adjustments_Other', value.blGST_Adj_Other);
     AddMoney(BalanceID, 'GST_372_Adjustments_Other_Part2', value.blBAS_W3_GST_Adj_Other);


     AddMoney(BalanceID, 'GST_372_Adjustments_Total', value.blOther_Adjustments );
     AddMoney(BalanceID, 'GST_372_Adjustments_Total_Part2', value.blBAS_G23);

     AddMoney(BalanceID, 'GST_372_CreditAdjustments_BusinessUseOfExemptGoodsAndServices', value.blGST_Cdj_BusUse);
     AddMoney(BalanceID, 'GST_372_CreditAdjustments_BusinessUseOfExemptGoodsAndServices_Part2', value.blBAS_W4_GST_Cdj_BusUse);

     AddMoney(BalanceID, 'GST_372_CreditAdjustments_PrivateAssetsForBusinessCostingLessThan', value.blGST_Cdj_PAssets);
     AddMoney(BalanceID, 'GST_372_CreditAdjustments_PrivateAssetsForBusinessCostingLessThan_Part2', value.blBAS_T1_VAT1_GST_Cdj_PAssets);

     AddMoney(BalanceID, 'GST_372_CreditAdjustments_ChangeOfAccountingBasis', value.blGST_Cdj_Change );
     AddMoney(BalanceID, 'GST_372_CreditAdjustments_ChangeOfAccountingBasis_Part2', value.blBAS_T2_VAT2_GST_Cdj_Change);

     AddMoney(BalanceID, 'GST_372_CreditAdjustments_Other', value.blGST_Cdj_Other  );
     AddMoney(BalanceID, 'GST_372_CreditAdjustments_Other_Part2', value.blBAS_W3_GST_Adj_Other);

     AddMoney(BalanceID, 'GST_372_CreditAdjustments_Total', value.blCredit_Adjustments);
     AddMoney(BalanceID, 'GST_372_CreditAdjustments_Total_Part2', value.blBAS_T8_VAT8);

end;



(*******************************************************************************)

{ TChartDivisionTable }

function TChartDivisionTable.Insert(MyID,
                   ChartID,
                   ClientId: TGuid;
                   Division: Integer
                   ): Boolean;
begin
   Result := RunValues([ToSQL(MyID),toSQL(Division),{toSQL(ClientId),}toSQL(ChartId)],[]);
end;

procedure TChartDivisionTable.SetupTable;
begin
   Tablename := 'ClientReportDivisionCharts';
   SetFields(['Id','DivisionIndex',{'Client_Id',}'Chart_Id'],[]);
end;


(*******************************************************************************)

{ TReminderTable }

function TReminderTable.Insert(
                   MyID,
                   ClientID,
                   ByUser: TGuid;
                   ToDoItem: pClientToDoItem): Boolean;


begin with ToDoItem^ do
   Result := RunValues([ToSQL(MyID), ToSQL(ClientID), ToSQL(tdDate_Entered, tdTime_Entered), ToSQL(ByUser),
                  ToSQL(tdDescription)
             ,DateToSQL(tdReminderDate), ToSQL((tdDate_Completed > 0) and (tdDate_Completed < maxint) ), DateToSQL( tdDate_Completed)],[]);
end;

procedure TReminderTable.SetupTable;
begin
   Tablename := 'Reminders';
   SetFields(['Id','Client_Id','DateEntered','EnteredBy','Action'
      ,'ReminderDate','Closed','DateClosed'],[]);

end;


(*******************************************************************************)

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
   SetFields(['Id','Client_Id','DiskID','DateDownloaded','NoOfAccounts','NoOfEntries'], []);
end;


(*******************************************************************************)

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
  SetFields(['Id','Balance_Id','Account','FuelType','FuelLitres','FuelUse','Percentage'
      ,'FuelEligible','CreditRate'],[]);

end;


(*******************************************************************************)

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


(*******************************************************************************)

{ TNotesOptionsTable }

function TNotesOptionsTable.Insert(MyId: TGuid;
                   ClientID: TGuid;
                   Value: pClient_Rec;
                   Extra: pClientExtra_Rec;
                   Notification: Integer): Boolean;
begin with Value^ do
   Result := RunValues([ToSQL(MyID), ToSQL(ClientID), ToSQL(not clECoding_Dont_Allow_UPIs), ToSQL(not clECoding_Dont_Show_Account)
                 ,ToSQL(not value.clECoding_Dont_Show_Payees), ToSQL(not clECoding_Dont_Show_GST), ToSQL(not clECoding_Dont_Show_TaxInvoice)
{2}          ,ToSQL(clECoding_WebSpace), PWToSQL(clECoding_Default_Password), ToSQL(clECoding_Import_Options), ToSQL(clECoding_Last_Import_Dir)
                  ,ToSQL(Value.clECoding_Last_Export_Dir)
{3}          ,ToSQL(clECoding_Entry_Selection), ToSQL(not clECoding_Dont_Send_Chart), ToSQL(not clECoding_Dont_Send_Payees), ToSQL(not clECoding_Dont_Show_Quantity)
                 ,ToSQL(clECoding_Last_File_No), ToSQL(clECoding_Last_File_No_Imported)
{4}          ,ToSQL(not Extra.ceECoding_Dont_Send_Jobs), ToSQL(clECoding_Send_Superfund)
                 ,ToSQL(Notification and wnDontNotifyMe = 0), TOSQL(Notification and wnDontNotifyClient = 0)],[]);
end;

procedure TNotesOptionsTable.SetupTable;
begin
   TableName := 'NotesOptions';
   SetFields(['Id', 'Client_Id' ,'AllowUPIs' ,'ShowChart','ShowPayees','ShowGST','ShowTaxInvoice'
{2}      ,'WebSpace','DefaultPassword' ,'ImportOptions','LastImportDir','LastExportDir'
{3}      ,'EntrySelection','SendChart' ,'SendPayees' ,'ShowQuantity' ,'LastFileNo' ,'LastFileNoImported'
{4}      ,'SendJobs' ,'SendSuperfund' ,'SendtoClientonExport' ,'SendtoPracticeTransactionsAvailable'],[]);
end;


(*******************************************************************************)

{ TReportParameterTable }

function TReportParameterTable.AddClient(MyId, ClientReportID: TGuid;
  Value: pClient_Rec;  Extra: pClientExtra_Rec): boolean;

  function GetYear(fromDate: Integer): Integer;
  var tmp : Integer;
  begin
     result := 0;
     if(fromdate = 0)
     or (fromdate = -1) then
        exit;
     StDateToDMY(fromDate,tmp,tmp,result);
  end;

begin
   Update('CodingReportStyle', Value.clCoding_Report_Style,ClientReportID);
   Update('CodingReportSortOrder', Value.clCoding_Report_Sort_Order ,ClientReportID);
   Update('CodingReportEntrySelection', Value.clCoding_Report_Entry_Selection ,ClientReportID);
   Update('CodingReportBlankLines', Value.clCoding_Report_Blank_Lines ,ClientReportID);
   Update('CodingReportRuleLine', Value.clCoding_Report_Rule_Line ,ClientReportID);
   Update('CodingReportPrintTI', Value.clCoding_Report_Print_TI ,ClientReportID);
   Update('CodingReportShowOP', Value.clCoding_Report_Show_OP ,ClientReportID);
   Update('CodingReportWrapNarration', Value.clCoding_Report_Wrap_Narration ,ClientReportID);
   Update('CodingReportColumnLine', Extra.ceCoding_Report_Column_Line ,ClientReportID);
   Update('ReportingPeriod', Value.clReporting_Period ,ClientReportID);
   Update('ReportingYearStarts', GetYear(Value.clReporting_Year_Starts) ,ClientReportID);
   Update('FRSPrintChartCodes', Value.clFRS_Print_Chart_Codes ,ClientReportID);
   Update('FRSShowYTD', Value.clFRS_Show_YTD ,ClientReportID);
   Update('FRSShowVariance', Value.clFRS_Show_Variance ,ClientReportID);
   Update('FRSCompareType', Value.clFRS_Compare_Type ,ClientReportID);
   Update('FRSReportDetailType', Value.clFRS_Report_Detail_Type ,ClientReportID);
   Update('FRSPrintNPChartCodeTitles', Extra.ceFRS_Print_NP_Chart_Code_Titles ,ClientReportID);
   Update('FRSNPChartCodeDetailType', Extra.ceFRS_NP_Chart_Code_Detail_Type ,ClientReportID);
   Update('FRSReportingPeriodType', Value.clFRS_Reporting_Period_Type ,ClientReportID);
   Update('FRSReportStyle', Value.clFRS_Report_Style ,ClientReportID);
   Update('FRSShowQuantity', Value.clFRS_Show_Quantity ,ClientReportID);
   Update('ProfitReportShowPercentage', Value.clProfit_Report_Show_Percentage ,ClientReportID);
   Update('CflwCashOnHandStyle', Value.clCflw_Cash_On_Hand_Style ,ClientReportID);
   Update('FRSPromptUsertouseBudgetedfigures', Value.clFRS_Prompt_User_to_use_Budgeted_figures ,ClientReportID);

   Update('GSTInclusive', Value.clGST_Inclusive_Cashflow ,ClientReportID); //??

   Update('LedgerReportSummary', Value.clLedger_Report_Summary ,ClientReportID);
   Update('LedgerReportShowNotes', Value.clLedger_Report_Show_Notes ,ClientReportID);
   Update('LedgerReportShowQuantities', Value.clLedger_Report_Show_Quantities ,ClientReportID);
   Update('LedgerReportShowNonTrf', Value.clLedger_Report_Show_Non_Trf ,ClientReportID);
   Update('LedgerReportShowInactiveCodes', Value.clLedger_Report_Show_Inactive_Codes ,ClientReportID);
   Update('LedgerReportBankContra', Value.clLedger_Report_Bank_Contra ,ClientReportID);
   Update('LedgerReportGSTContra', Value.clLedger_Report_GST_Contra ,ClientReportID);
   Update('LedgerReportShowBalances', Value.clLedger_Report_Show_Balances ,ClientReportID);
   Update('LedgerReportShowGrossAndGST', Value.clLedger_Report_Show_Gross_And_GST ,ClientReportID);
   Update('LedgerReportWrapNarration', Value.clLedger_Report_Wrap_Narration ,ClientReportID);
   Update('ListEntriesSortOrder', Extra.ceList_Entries_Sort_Order ,ClientReportID);
   Update('ListEntriesInclude', Extra.ceList_Entries_Include ,ClientReportID);
   Update('ListEntriesTwoColumn', Extra.ceList_Entries_Two_Column ,ClientReportID);
   Update('ListEntriesShowBalance', Extra.ceList_Entries_Show_Balance ,ClientReportID);
   Update('ListEntriesShowNotes', Extra.ceList_Entries_Show_Notes ,ClientReportID);
   Update('ListEntriesWrapNarration', Extra.ceList_Entries_Wrap_Narration ,ClientReportID);
   Update('ListEntriesShowOtherParty', Extra.ceList_Entries_Show_Other_Party ,ClientReportID);
   Update('ListPayeesDetailed', Extra.ceList_Payees_Detailed ,ClientReportID);
   Update('ListPayeesSortBy', Extra.ceList_Payees_SortBy ,ClientReportID);
   Update('ListPayeesRuleLine', Extra.ceList_Payees_Rule_Line ,ClientReportID);

   Update('GstReportIncludeAccrualJournals',not Value.clGST_Excludes_Accruals,ClientReportID);
   if value.clGST_on_Presentation_Date then
      Update('GstReportClassifyEntriesBy', 1, ClientReportID)
   else
      Update('GstReportClassifyEntriesBy', 0, ClientReportID);

   Update('GstReportBasFormat',Value.clBAS_Report_Format,ClientReportID);
   Update('GstReportIncludeGstCalculationSheet',not value.clBAS_Dont_Print_Calc_Sheet,ClientReportID);
   Update('GstReportIncludeFuelTaxCalculationSheet', Value.clBAS_Include_Fuel,ClientReportID);



   //Update('X', Value ,ClientReportID);

end;



procedure TReportParameterTable.SetupTable;
begin
   TableName := 'ReportParameters';

end;

function TReportParameterTable.Update(ParamName: string; ParamValue: Boolean; ClientReportID:TGuid): Boolean;
  function value : string;
  begin
   if ParamValue then
      Result := 'true'
   else
      Result := 'false';
  end;
begin
   Result :=  Update (ParamName,value ,'Boolean',ClientReportID);
end;

function TReportParameterTable.Update(ParamName, ParamValue, ParamType: string; ClientReportID:TGuid): Boolean;
  var sql : string;


begin
   Result := false;
   try
   sql :=  format('if (exists (select * from  [%0:s] as t1 where t1.ParameterName = ''%1:s'' and t1.ClientReport_Id = ''%4:s'' ))'   +
   ' begin update [%0:s] set [ParameterValue] = ''%2:s'' where [ParameterName] = ''%1:s''  and [ClientReport_Id] = ''%4:s''  end else begin' +
   ' insert into [%0:s] ([ParameterName], [ParameterType], [ParameterValue],  [ClientReport_Id], [ID] ) values '+
                        '(''%1:s'',''%3:s'',''%2:s'', ''%4:s'',  ''%5:s'' ) end',
     // 0     1         2          3               4                     5
   [TableName,ParamName,Paramvalue,Paramtype,ToSQL(ClientReportID),  ToSQL(NewGuid)]);

      connection.Execute( sql );
      Result := true;
   except
      on e: exception do begin
         raise exception.Create(Format('Error : %s in table %s',[e.Message,TableName]));
      end;
   end;
end;

{
function TReportParameterTable.Update(ParamName: string;
  ParamValue: Money; ClientReportID:TGuid): Boolean;
begin

end;
}

function TReportParameterTable.Update(ParamName: string; ParamValue: Integer; ClientReportID:TGuid): Boolean;
begin
    Result := UpDate(ParamName, IntToStr(ParamValue), 'int32',ClientReportID);
end;
      {
function TReportParameterTable.Update(ParamName: string; ParamValue: TGuid; ClientReportID:TGuid): Boolean;
begin

end;
}



{ TClientReportTable }

function TClientReportTable.InsertClient(MyId, ClientID: TGuid): Boolean;
begin
   result := RunValues([ToSql(MyID), null, null, null, null, null,
      null, null, null,null, null, null, null, toSql(ClientID)],[]);
end;

function TClientReportTable.InsertReport(MyiD, ClientID: TGuid;
  Report: TReportBase; SequenceNo: Integer): Boolean;
begin
   result := RunValues([ToSql(MyID), ToSQL(integer(Get_ReportListType(report.Title))), ToSql(report.Name), DateTimeToSQL(report.Createdon), null, ToSQL(report.Createdby),
      ToSQL(report.DatesText), ToSQL(report.RunDestination), DateTimeToSQL(report.LastRun), null, ToSQL(report.User), ToSQL(SequenceNo),
      ToSQL(report.Title), toSql(ClientID)],[]);
end;

procedure TClientReportTable.SetupTable;
begin
     TableName := 'ClientReports';
   SetFields(['Id' ,'Report_Id','FavouriteName', 'CreatedDate', 'CreatedBy_Id', 'CreatedBy'
      ,'LastRunForDates', 'LastRunDestination', 'LastRunDate', 'LastRunBy_Id', 'LastRunBy', 'SequenceNo'
      ,'Report', 'Client_Id'],[]);

end;

{ TClientParameterTable }

procedure TClientParameterTable.SetupTable;
begin
   TableName := 'ClientParameters';
end;

function TClientParameterTable.Update(ParameterGroup, ParamName, ParamValue, ParamType: string; ClientID:TGuid): Boolean;
  var sql : string;

begin
   Result := false;
   try
   sql :=  format('if (exists (select * from  [%0:s] as t1 where t1.ParameterName = ''%1:s'' and t1.Client_Id = ''%4:s'' and t1.[ParameterGroup] = ''%6:s''))'   +
   ' begin update [%0:s] set [ParameterValue] = ''%2:s'' where [ParameterName] = ''%1:s''  and [Client_Id] = ''%4:s'' and [ParameterGroup] = ''%6:s'' end else begin' +
   ' insert into [%0:s] ([ParameterName], [ParameterType], [ParameterValue],  [Client_Id], [ID], [ParameterGroup] ) values '+
                        '(''%1:s'', ''%3:s'', ''%2:s'', ''%4:s'', ''%5:s'', ''%6:s'') end',
     // 0     1         2          3               4                     5         6
   [TableName,ParamName,Paramvalue,Paramtype,ToSQL(ClientID), ToSQL(NewGuid), ParameterGroup]);

      connection.Execute( sql );
      Result := true;
   except
      on e: exception do begin
         raise exception.Create(Format('Error : %s in table %s',[e.Message,TableName]));
      end;
   end;
end;

end.
