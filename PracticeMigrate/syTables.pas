unit syTables;

interface
uses
  DB,
  ADODB,
  MoneyDef,
  MigrateTable,
  bkDefs,// MasterMems
  sydefs;

type

TSystemBankAccountTable = class (TMigrateTable)
  protected
     procedure SetupTable; override;
  public
     function Insert  (MyId:TGuid; Value: pSystem_Bank_Account_Rec): Boolean;
  end;

TClientGroupTable = class (TMigrateTable)
  protected
     procedure SetupTable; override;
  public
     function Insert(id:TGuid; Value: pGroup_Rec): Boolean;
end;

TClientTypeTable = class (TMigrateTable)
  protected
     procedure SetupTable; override;
  public
     function Insert(id:TGuid; Value: pClient_Type_Rec): Boolean;
end;

TSystemClientFileTable = class (TMigrateTable)
  protected
     procedure SetupTable; override;
  public
     function Insert(MyId:TGuid; Database:string; GroupID:tGuid; TypeID:tGuid; Value: pClient_File_Rec): Boolean;
end;

TUserTable = class (TMigrateTable)
  protected
     procedure SetupTable; override;
  public
     function Insert(MyId:TGuid; Value: pUser_Rec): Boolean;
end;

TClientAccountMapTable = class (TMigrateTable)
  protected
     procedure SetupTable; override;
  public
     function Insert(MyId,ClientID,ClientAccID,SystemAccID:TGuid;
                   Value: pClient_Account_Map_Rec): Boolean;
end;

TUserMappingTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyiD,ClientID,UserID: TGuid): Boolean;
end;

TMasterMemorisationsTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyId, Provider: TGuid;
                  SequenceNo: integer;
                  Prefix: string;
                  Value: PMemorisation_Detail_Rec): Boolean;
end;

TMasterMemlinesTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyiD,MemID: TGuid;
                   SequenceNo: integer;
                   Value: pMemorisation_Line_Rec): Boolean;
end;

TChargesTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyiD, AccountId: TGuid;
        Date: Integer;
        Charges: Double;
        Transactions: Integer;
        IsNew, LoadChargeBilled: Boolean;
        OffSiteChargeIncluded: Boolean;
        FileCode,CostCode: string  ): Boolean;
end;

TTaxEntriesTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyID: TGuid;
                   ClassID: TGuid;
                   SequenceNo: Integer;
                   ID: string;
                   Description: string;
                   Account: string ): Boolean;
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

TDownloadDocumentTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyiD: TGuid;
        DocType: string;
        DocName: string;
        FileName: string;
        ForDate: Integer): Boolean;
end;

TDownloadlogTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Insert(MyiD: TGuid;
                   Value: pSystem_Disk_Log_Rec): Boolean;
end;

TParameterTable = class (TMigrateTable)
protected
   procedure SetupTable; override;
public
   function Update(ParamName, ParamValue: string): Boolean; overload;
   function Update(ParamName: string; ParamValue: Boolean): Boolean; overload;
   function Update(ParamName: string; ParamValue: TGuid): Boolean; overload;
   function Update(ParamName: string;ParamValue: Integer): Boolean; overload;
   function Update(ParamName: string; ParamValue: Money): Boolean; overload;
end;



implementation

uses
  Variants,
  SysUtils,
  bkConst,
  PasswordHash,
  SQLHelpers;


{ TSystemBankAccountTable }

procedure TSystemBankAccountTable.SetupTable;
begin
  TableName := 'SystemBankAccounts';
  SetFields(
   ['Id','AccountNumber','AccountName','AccountPassword','CurrentBalance','LastSequenceNo'
   ,'NewThisMonth','NoOfEntriesThisMonth','FromDateThisMonth','ToDateThisMonth','CostCode','ChargesThisMonth'
   ,'OpeningBalanceFromDisk','ClosingBalanceFromDisk','WasOnLatestDisk','LastEntryDate'
   ,'DateOfLastEntryPrinted','MarkAsDeleted','FileCode','MatterID','AssignmentID','DisbursementID','AccountType'
   ,'JobCode','ActivityCode','FirstAvailableDate','NoChargeAccount','CurrencyCode','InstitutionName','SecureCode','Inactive'
   ,'Frequency','FrequencyChangePending','LastBankLink_ID'],[]);

end;

function TSystemBankAccountTable.Insert(MyId: TGuid; Value: pSystem_Bank_Account_Rec): Boolean;
begin with Value^ do
   result := RunValues([ToSQL(MyId) ,ToSQL(Value.sbAccount_Number) ,ToSQL(Value.sbAccount_Name) ,ToSQL(Value.sbAccount_Password)
              ,ToSQL(Value.sbCurrent_Balance) ,toSQL(Value.sbLast_Transaction_LRN)

          ,ToSQL(Value.sbNew_This_Month) ,ToSQL(Value.sbNo_of_Entries_This_Month) ,DateToSQL(Value.sbFrom_Date_This_Month)
              ,DateToSQL(Value.sbTo_Date_This_Month) ,ToSQL(Value.sbCost_Code) , ToSQL(Value.sbCharges_This_Month)

          ,ToSQL(Value.sbOpening_Balance_from_Disk) ,ToSQL(Value.sbClosing_Balance_from_Disk)
              ,ToSQL(Value.sbWas_On_Latest_Disk) ,DateToSQL(Value.sbLast_Entry_Date)

          ,DateToSQL(Value.sbDate_Of_Last_Entry_Printed) ,ToSQL(Value.sbMark_As_Deleted) ,ToSQL(Value.sbFile_Code) ,ToSQL(Value.sbMatter_ID)
              ,ToSQL(Value.sbAssignment_ID) ,ToSQL(Value.sbDisbursement_ID) ,ToSQL(Value.sbAccount_Type)

          ,ToSQL(Value.sbJob_Code) ,ToSQL(Value.sbActivity_Code) , DateToSQL(Value.sbFirst_Available_Date) ,ToSQL(Value.sbNo_Charge_Account)
              ,ToSQL(Value.sbCurrency_Code) ,ToSQL(Value.sbInstitution) ,ToSQL(Value.sbBankLink_Code) ,toSQL(false)

          ,ToSQL(Value.sbFrequency) ,ToSQL(Value.sbFrequency_Change_Pending), ToSQL(0)],[]);
end;

{ TClientGroupTable }

procedure TClientGroupTable.SetupTable;
begin
   TableName :=  'ClientGroups';
   SetFields(['Id','Name'],[]);
end;

function TClientGroupTable.Insert(id: TGuid; Value: pGroup_Rec): Boolean;
begin
   Result := RunValues([ToSQL(Id) ,ToSQL(Value.grName)],[]);
end;


{ TClientTypeTable }
procedure TClientTypeTable.SetupTable;
begin
   TableName := 'ClientTypes';
   SetFields(['Id','Name'],[]);
end;

function TClientTypeTable.Insert(id: TGuid; Value: pClient_Type_Rec): Boolean;
begin
    Result := RunValues([ToSQL(Id) ,ToSQL(Value.ctName)],[]);
end;


{ TSystemClientFileTable }

procedure TSystemClientFileTable.SetupTable;
begin
   TableName := 'PracticeClients';
   SetFields(['Id','ClientName','ClientDB','Code','ClientGroups_Id','ClientTypes_Id'],[]);
end;


function TSystemClientFileTable.Insert(MyId: TGuid; Database: string; GroupID,
  TypeID: tGuid; Value: pClient_File_Rec): Boolean;
begin with Value^ do
   Result := RunValues([ToSQL(MyId) ,ToSQL(cfFile_Name) ,ToSQL(Database) ,ToSql(cfFile_Code)
               ,ToSQL(GroupID) , ToSQL(TypeID)],[]);
end;


{ TUserTable }

procedure TUserTable.SetupTable;
begin
  TableName := 'Users';
  SetFields(['Id','Code','Name','Password','EmailAddress','SystemAccess','DialogColour'
{2}         ,'ReverseMouseButtons','MASTERAccess','IsRemoteUser','DirectDial'
{3}         ,'ShowCMOnOpen','ShowPrinterChoice','EULAVersion'
{4}         ,'SuppressHF','ShowPracticeLogo'
{5}         ,'IsDeleted','CanAccessAllClients','IncorrectLoginCount','IsLockedOut'],[]);
end;

function TUserTable.Insert(MyId: TGuid; Value: pUser_Rec): Boolean;
begin
    with Value^ do
    Result := RunValues([
{1}           ToSQL(MyId), ToSQL(usCode), ToSQL(usName), ToSQL(ComputePWHash(usPassword,MyId))
                 ,ToSQL(usEMail_Address) ,ToSQL(usSystem_Access) ,ToSQL(usDialog_Colour)
{2}          ,ToSQL(usReverse_Mouse_Buttons) ,ToSQL(usMASTER_Access) ,ToSQL(usIs_Remote_User) ,ToSQL(usDirect_Dial)
{3}          ,ToSQL(usShow_CM_on_open) ,ToSQL(usShow_Printer_Choice) ,ToSQL(usEULA_Version)
{4}          ,ToSQL(usSuppress_HF) ,ToSQL(usShow_Practice_Logo)
{5}          ,ToSQL(False) ,ToSQL(usSystem_Access) ,ToSQL(0) ,ToSQL(False)],[]);
end;


{ TClientAccountMapTable }

procedure TClientAccountMapTable.SetupTable;
begin
  TableName := 'ClientSystemAccounts';
  setFields(
         ['Id','PracticeClientId','ClientAccount','SystemBankAccountId'
          ,'LastDatePrinted','TempLastDatePrinted','EarliestDownloadDate'],[]);
end;

function TClientAccountMapTable.Insert(MyId, ClientID, ClientAccID,
  SystemAccID: TGuid; Value: pClient_Account_Map_Rec): Boolean;
begin
   with Value^ do
   Result := RunValues(
          [ToSQL(MyID), ToSQL(ClientID), ToSQL(ClientAccID), ToSQL(SystemAccID)
          ,DateToSQL(amLast_Date_Printed), DateToSQL(amTemp_Last_Date_Printed)
                 ,DateToSQL(amEarliest_Download_Date)],[]);
end;


{ TFile_Access_Mapping_RecTable }

function TUserMappingTable.Insert(MyiD, ClientID,
  UserID: TGuid): Boolean;
begin
  Result := RunValues(
          [ToSQL(MyID), ToSQL(UserID), ToSQL(ClientID)],[]);
end;

procedure TUserMappingTable.SetupTable;
begin
  Tablename := 'UserClients';
  SetFields(['Id','User_Id','Client_Id'],[]);
end;

{ TMasterMemorisationsTable }

function TMasterMemorisationsTable.Insert
                 (MyId, Provider: TGuid;
                 SequenceNo: integer;
                  Prefix: string;
                  Value: PMemorisation_Detail_Rec): Boolean;

begin with Value^ do
  Result := RunValues(
{1}       [ToSQL(MyID), ToSQL(SequenceNo), ToSQL(mdType),ToSQL(mdAmount)
              ,ToSQL(mdReference), ToSQL(mdParticulars)
{2}       ,ToSQL(mdAnalysis), ToSQL(mdOther_Party), ToSQL(mdStatement_Details), ToSQL(mdMatch_on_Amount <> mxNo), ToSQL(mdMatch_on_Analysis)
{3}       ,ToSQL(mdMatch_on_Other_Party), ToSQL(mdMatch_on_Notes), ToSQL(mdMatch_on_Particulars), ToSQL(mdMatch_on_Refce)
{4}       ,ToSQL(mdMatch_On_Statement_Details), ToSQL(mdPayee_Number), ToSQL(mdFrom_Master_List), ToSQL(mdNotes)
              ,DateToSQL(mdDate_Last_Applied)
{5}       ,ToSQL(mdUse_Accounting_System),ToSQL(Provider), DateToSQL(mdFrom_Date), DateToSQL(mdUntil_Date)
              ,ToSQL(Prefix), ToSQL(mdMatch_on_Amount)],[]);

end;

procedure TMasterMemorisationsTable.SetupTable;
begin
   Tablename := 'MasterMemorisations';
{1}   SetFields(['Id','SequenceNo','MemorisationType','Amount','Reference','Particulars'
{2}      ,'Analysis','OtherParty','StatementDetails','MatchOnAmount','MatchOnAnalysis'
{3}      ,'MatchOnOtherParty','MatchOnNotes','MatchOnParticulars','MatchOnRefce'
{4}      ,'MatchOnStatementDetails','PayeeNumber','FromMasterList','Notes' ,'DateLastApplied'
{5}      ,'UseAccountingSystem','AccountingSystem','AppliesFrom','AppliesTo','BankCode','MatchOnAmountType'],[]);

end;

{ TMasterMemlinesTable }

function TMasterMemlinesTable.Insert(MyiD, MemID: TGuid;  SequenceNo: integer; Value: pMemorisation_Line_Rec): Boolean;
begin with Value^ do
   Result := RunValues(
       [ToSQL(MyID), ToSQL(MemID), ToSQL(SequenceNo), ToSQL(mlAccount), PercentToSQL(mlPercentage), ToSQL(mlGST_Class), ToSQL(mlGST_Has_Been_Edited)
              ,ToSQL(mlGL_Narration)
       ,ToSQL(mlLine_Type), ToSQL(mlGST_Amount), NullToSQL(mlPayee), ToSQL(mlJob_Code), QtyToSQL(mlQuantity)

       ],[
{1}       ToSQL(mlSF_Edited), PercentToSQL(mlSF_PCFranked),PercentToSQL(mlSF_PCUnFranked),
{2}       ToSQL(mlSF_Member_ID), ToSQL(mlSF_Fund_ID ), ToSQL(mlSF_Fund_Code),

{3}       ToSQL(mlSF_Trans_ID), ToSQL(mlSF_Trans_Code), ToSQL(mlSF_Member_Account_ID), ToSQL(mlSF_Member_Account_Code), toSQL(0 ),

{4}       ToSQL(mlSF_Member_Component), PercentToSQL(mlSF_Other_Expenses), PercentToSQL(mlSF_Interest), PercentToSQL(mlSF_Rent),
              PercentToSQL(mlSF_Special_Income), PercentToSQL(0),

{5}       PercentToSQL(mlSF_Tax_Free_Dist), PercentToSQL(mlSF_Tax_Exempt_Dist), PercentToSQL(mlSF_Tax_Deferred_Dist), PercentToSQL(mlSF_TFN_Credits),
              PercentToSQL(mlSF_Other_Tax_Credit), PercentToSQL(mlSF_Non_Resident_Tax),

{6}       PercentToSQL(mlSF_Foreign_Income), PercentToSQL(mlSF_Foreign_Tax_Credits), PercentToSQL(mlSF_Capital_Gains_Indexed),
               PercentToSQL(mlSF_Capital_Gains_Disc),

{7}       PercentToSQL(mlSF_Capital_Gains_Other), PercentToSQL(mlSF_Capital_Gains_Foreign_Disc), PercentToSQL(mlSF_Foreign_Capital_Gains_Credit),


{8}       DateToSQl(mlSF_GDT_Date), ToSQL(mlSF_Capital_Gains_Fraction_Half)]);

end;

procedure TMasterMemlinesTable.SetupTable;
begin
   Tablename := 'MasterMemorisationLines';
   SetFields(['Id','MasterMemorisationId_Id','SequenceNo','ChartCode','Percentage','GSTClass','GSTHasBeenEdited','GLNarration'
      ,'LineType','GSTAmount','PayeeNumber','JobCode', 'Quantity'

     ],SFLineFields);
end;

{ TChargesTable }

function TChargesTable.Insert(MyiD, AccountId: TGuid;
        Date: Integer;
        Charges: Double;
        Transactions: Integer;
        IsNew, LoadChargeBilled: Boolean;
        OffSiteChargeIncluded: Boolean;
        FileCode,CostCode: string  ): Boolean;
begin
   Result := RunValues([ToSQL(MyiD), ToSQL(AccountId), DateToSQL(Date),
            Charges, ToSQL(Transactions), ToSQL(IsNew), ToSQL(LoadChargeBilled),
        ToSQL(OffSiteChargeIncluded), ToSQL(FileCode),ToSQL(CostCode)],[])
end;

procedure TChargesTable.SetupTable;
begin
   TableName := 'AccountCharges';
   SetFields(['Id','SystemBankAccountId','Date','Charges','Transactions','NewAccount','LoadChargeBilled'
      ,'OffSiteChargeIncluded','FileCode','CostCode'
      ],[]);

end;

{ TDownloadDocumentTable }

function TDownloadDocumentTable.Insert(MyiD: TGuid;
        DocType: string;
        DocName: string;
        FileName: string;

        ForDate: Integer): Boolean;

begin
   Result := False;
   Parameters[0].Value := ToSQL(MyID);
   Parameters[1].Value := ToSQL(DocType);
   Parameters[2].Value := DateToSQL(ForDate);
   Parameters[3].LoadFromFile(FileName,ftBlob);
   Parameters[4].Value := ToSQL(DocName);
   // Run the query
   try
      Result := ExecSQL = 1;
   except
      on e: exception do begin
         raise exception.Create(Format('Error : %s in table %s',[e.Message,TableName]));
      end;
   end;
end;

procedure TDownloadDocumentTable.SetupTable;
begin
   TableName := 'DownloadDocuments';
   SetFields(['Id','DocumentType','ForDate','Document','FileName'],[]);
end;

{ TDownloadlogTable }

function TDownloadlogTable.Insert(MyiD: TGuid;
                   Value: pSystem_Disk_Log_Rec): Boolean;
begin
   with Value^ do
    Result := RunValues([ToSQL(MyID),ToSql(Value.dlDisk_ID),DateToSQL(Value.dlDate_Downloaded)
               ,ToSQL(Value.dlNo_of_Accounts), ToSQL(Value.dlNo_of_Entries), ToSQL(Value.dlWas_In_Last_Download)],[]);
end;

procedure TDownloadlogTable.SetupTable;
begin
   TableName := 'Downloads';
   SetFields(['Id','DiskId','DateDownloaded','NoOfAccounts','NoOfEntries','WasInLastDownload'],[]);
end;

{ TParameterTable }

function TParameterTable.Update(ParamName, ParamValue: string): Boolean;
begin
    Result := RunValues([ToSQL(ParamValue), ToSQL(ParamName)],[]);
end;

procedure TParameterTable.SetupTable;
begin
   TableName := 'SystemParameters';

  // Make the query
  SQL.Text := Format('update [%s] set [ParameterValue] = :ParameterValue where [ParameterName] = :ParameterName',[TableName]);

end;

function TParameterTable.Update(ParamName: string;
  ParamValue: Boolean): Boolean;
begin
   if ParamValue then
      Result := Update(ParamName,'true')
   else
      Result := Update(ParamName,'false')
end;

function TParameterTable.Update(ParamName: string; ParamValue: TGuid): Boolean;
begin
   Result := RunValues([ToSQL(ParamValue), ToSQL(ParamName)],[]);
end;

function TParameterTable.Update(ParamName: string;ParamValue: Integer): Boolean;
begin
   Result := UpDate(ParamName, IntToStr(ParamValue));
end;

function TParameterTable.Update(ParamName: string; ParamValue: Money): Boolean;
begin
  Result := UpDate(ParamName, FormatFloat('0.00', ParamValue/100) );
end;




{ TTaxEntriesTable }

function TTaxEntriesTable.Insert(MyID: TGuid;
                   ClassID: TGuid;
                   SequenceNo: Integer;
                   ID: string;
                   Description: string;
                   Account: string): Boolean;
begin
   Result := RunValues([ToSQL(MyID),ToSQL(ClassID),ToSQL(ID),ToSQL(SequenceNo),ToSQL(Description)
                ,ToSQL(Account) ],[]);
end;

procedure TTaxEntriesTable.SetupTable;
begin
  TableName := 'SysTaxEntries';
  SetFields(['Id','TaxClassType_Id','TaxId','SequenceNo','ClassDescription','ControlAccount'],[]);
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
  TableName := 'SysTaxRates';
  SetFields(['Id','TaxEntry_Id','Rate','EffectiveDate'],[]);
end;


end.
