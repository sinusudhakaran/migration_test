unit AuditMgr;

interface

uses
  SysUtils, Classes;

const
  //Audit types
  atPracticeSetup                 = 0;  atMin = 0;
  atPracticeGSTDefaults           = 1;
  atMasterMemorisations           = 2;
  atUsers                         = 3;
  atSystemOptions                 = 4;
  atDownloadingData               = 5;
  atSystemBankAccounts            = 6;
  atProvisionalDataEntry          = 7;
  atClientFiles                   = 8;
  atClientBankAccounts            = 9;
  atChartOfAccounts               = 10;
  atPayees                        = 11;
  atMemorisations                 = 12;
  atGSTSetup                      = 13;
  atHistoricalentries             = 14;
  atProvisionalEntries            = 15;
  atManualEntries                 = 16;
  atDeliveredTransactions         = 17;
  atAutomaticCoding               = 18;
  atCashJournals                  = 19;
  atAccrualJournals               = 20;
  atStockAdjustmentJournals       = 21;
  atYearEndAdjustmentJournals     = 22;
  atGSTJournals                   = 23;
  atOpeningBalances               = 24;
  atUnpresentedItems              = 25;
  atBankLinkNotes                 = 26;
  atBankLinkNotesOnline           = 27;
  atBankLinkBooks                 = 28; atMax = 28;

  //Audit actions
  aaNone   = 0;  aaMin = 0;
  aaAdd    = 1;
  aaChange = 2;
  aaDelete = 3;  aaMax = 3;

  //Audit action strings
  aaNames : array[ aaMin..aaMax ] of string = ('None', 'Add', 'Change', 'Delete');

type
  TAuditType = atMin..atMax;

  TAuditInfo = record
    AuditRecordID: integer;
    AuditUser: string;
    AuditType: TAuditType;
    AuditAction: byte;
    AuditValues: string;
  end;

  TAuditManager = class(TObject)
  private
    FAuditScope: TList;
    function AuditTypeToTableID(AAuditType: TAuditType): byte;
  public
    constructor Create;
    destructor Destroy; override;
    function AuditTypeToStr(AAuditType: TAuditType): string;
    procedure DoAudit; virtual; abstract;
    procedure FlagAudit(AAuditType: TAuditType); virtual; abstract;
    procedure TablesToAudit(ATableList: TStrings); virtual; abstract;
  end;

  TSystemAuditManager = class(TAuditManager)
  public
    function NextSystemRecordID: integer;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType); override;
    procedure TablesToAudit(ATableList: TStrings); override;
  end;

  TClientAuditManager = class(TAuditManager)
  public
    function NextClientRecordID: integer;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType); override;
    procedure TablesToAudit(ATableList: TStrings); override;
  end;

  function SystemAuditMgr: TSystemAuditManager;
  function ClientAuditMgr: TClientAuditManager;

implementation

uses
  SystemDB, ClientDB,
  SYDEFS, SYAUDIT, SYUSIO, SYFDIO, SYDLIO, SYSBIO,
  BKDEFS, BKAUDIT, BKPDIO, BKCLIO, BKBAIO, BKCHIO, BKTXIO, BKMDIO;

const
  //Audit type strings
  atNames : array[ atMin..atMax ] of string =
    ('Practice Setup',
     'Practice GST/VAT Defaults',
     'Master Memorisations',
     'Users',
     'System Options',
     'Downloading Data',
     'System Bank Accounts',
     'Provisional Data Entry',
     'Client Files',
     'Client Bank Accounts',
     'Chart of Accounts',
     'Payees',
     'Memorisations',
     'GST/VAT Setup',
     'Historical entries',
     'Provisional entries',
     'Manual entries',
     'Delivered transactions',
     'Automatic coding',
     'Cash journals',
     'Accrual journals',
     'Stock/Adjustment journals',
     'Year End Adjustment  journals',
     'GST/VAT journals',
     'Opening balances',
     'Unpresented Items',
     'BankLink Notes',
     'BankLink Notes Online',
     'BankLink Books');

  atNameTable : array[ atMin..atMax ] of byte =
    (tkBegin_Practice_Details,    //Practice Setup
     tkBegin_Practice_Details,    //Practice GST/VAT Defaults
     0,                           //Master Memorisations
     tkBegin_User,                //Users
     tkBegin_Practice_Details,    //System Options
     tkBegin_System_Disk_Log,     //Downloading Data
     tkBegin_System_Bank_Account, //System Bank Accounts
     0,                           //Provisional Data Entry
     tkBegin_Client,              //Client Files
     tkBegin_Bank_Account,        //Client Bank Accounts
     tkBegin_Account,             //Chart of Accounts
     tkBegin_Payee_Detail,        //Payees
     tkBegin_Memorisation_Detail, //Memorisations
     tkBegin_Client,              //GST/VAT Setup
     tkBegin_Transaction,         //Historical entries
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction,
     tkBegin_Transaction);

var
  _SystemAuditMgr: TSystemAuditManager;
  _ClientAuditMgr: TClientAuditManager;

function SystemAuditMgr: TSystemAuditManager;
begin
  if not Assigned(_SystemAuditMgr) then
    _SystemAuditMgr := TSystemAuditManager.Create;
  Result := _SystemAuditMgr;
end;

function ClientAuditMgr: TClientAuditManager;
begin
  if not Assigned(_ClientAuditMgr) then
    _ClientAuditMgr := TClientAuditManager.Create;
  Result := _ClientAuditMgr;
end;


{ TAuditManager }

function TAuditManager.AuditTypeToStr(AAuditType: TAuditType): string;
begin
  Result := '';
  if (AAuditType <= atMax)then
    Result := atNames[AAuditType];
end;

function TAuditManager.AuditTypeToTableID(AAuditType: TAuditType): byte;
begin
  Result := atNameTable[AAuditType];
end;

constructor TAuditManager.Create;
begin
  FAuditScope := TList.Create;
end;

destructor TAuditManager.Destroy;
begin
  FreeAndNil(FAuditScope);
  inherited;
end;

{ TClientAuditManager }

procedure TClientAuditManager.DoAudit;
var
  i: integer;
  TableID: byte;
begin
  for i := 0 to FAuditScope.Count - 1 do begin
    TableID :=  Byte(FAuditScope.Items[i]);
    case TableID of
      tkBegin_Payee_Detail: Client.PayeeTable.DoAudit(Client.AuditTable, ClientCopy.PayeeTable);
    end;
  end;
end;

procedure TClientAuditManager.FlagAudit(AAuditType: TAuditType);
var
  TableID: byte;
begin
  TableID := AuditTypeToTableID(AAuditType);
  if FAuditScope.IndexOf(Pointer(TableID)) = -1 then
    FAuditScope.Add(Pointer(TableID));
end;

function TClientAuditManager.NextClientRecordID: integer;
begin
  Result := Client.NextAuditRecordID;
end;


procedure TClientAuditManager.TablesToAudit(ATableList: TStrings);
var
  i: integer;
begin
  for i := 0 to FAuditScope.Count - 1 do
    ATableList.Add(BKAuditNames.GetAuditTableName(Byte(FAuditScope.Items[i])));
end;

{ TSystemAuditManager }

procedure TSystemAuditManager.DoAudit;
var
  i: integer;
  TableID: byte;
begin
  for i := 0 to FAuditScope.Count - 1 do begin
    TableID :=  Byte(FAuditScope.Items[i]);
    case TableID of
      tkBegin_User: SystemData.UserTable.DoAudit(SystemData.AuditTable, SystemCopy.UserTable);
    end;
  end;
end;

procedure TSystemAuditManager.FlagAudit(AAuditType: TAuditType);
var
  TableID: byte;
begin
  TableID := AuditTypeToTableID(AAuditType);
  if FAuditScope.IndexOf(Pointer(TableID)) = -1 then
    FAuditScope.Add(Pointer(TableID));
end;

function TSystemAuditManager.NextSystemRecordID: integer;
begin
  Result := SystemData.NextAuditRecordID;
end;

procedure TSystemAuditManager.TablesToAudit(ATableList: TStrings);
var
  i: integer;
begin
  for i := 0 to FAuditScope.Count - 1 do
    ATableList.Add(SYAuditNames.GetAuditTableName(Byte(FAuditScope.Items[i])));
end;

end.
