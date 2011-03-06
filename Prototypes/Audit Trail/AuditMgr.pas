unit AuditMgr;

interface

uses
  SysUtils, Classes, IOStream;

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

  dbSystem = 0;
  dbClient = 1;

type
  TAuditType = atMin..atMax;

  TAuditInfo = record
    AuditRecordID: integer;
    AuditUser: string;
    AuditType: TAuditType;
    AuditAction: byte;
    AuditParentID: integer;
    AuditRecordType: byte;
    AuditRecord: Pointer;
  end;

  PScopeInfo = ^TScopeInfo;
  TScopeInfo = record
    AuditType: TAuditType;
    RecordID: integer;
  end;

  TAuditTypeInfo = record
    AyditType: TAuditType;
    TableID: byte;
  end;

  TAuditManager = class(TObject)
  private
    FAuditScope: TList;
    function AuditTypeToTableID(AAuditType: TAuditType): byte;
    function FindScopeInfo(AScopeInfo: PScopeInfo): integer;
    procedure AddScope(AAuditType: TAuditType; ARecordID: integer);
  public
    constructor Create;
    destructor Destroy; override;
    function AuditTypeToStr(AAuditType: TAuditType): string;
    function AuditTypeToDBStr(AAuditType: TAuditType): string;
    function AuditTypeToTableStr(AAuditType: TAuditType): string;
    function DBFromAuditType(AAuditType: TAuditType): byte;
    procedure DoAudit; virtual; abstract;
    procedure FlagAudit(AAuditType: TAuditType; ARecord: Pointer = nil); virtual; abstract;
    procedure AddAuditValue(ATableID, AFieldID: byte; AValue: variant;
      var AAuditValue: string); virtual; abstract;
    procedure WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream);
    procedure ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer);
    procedure GetValues(ARecordType: byte; ARecord: pointer; Strings: TStrings);
  end;

  TSystemAuditManager = class(TAuditManager)
  public
    function NextSystemRecordID: integer;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType; ARecord: Pointer = nil); override;
    procedure AddAuditValue(ATableID, AFieldID: byte; AValue: variant;
      var AAuditValue: string); override;
  end;

  TClientAuditManager = class(TAuditManager)
  public
    function NextClientRecordID: integer;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType; ARecord: Pointer = nil); override;
    procedure AddAuditValue(ATableID, AFieldID: byte; AValue: variant;
      var AAuditValue: string); override;
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
     'Year End Adjustment journals',
     'GST/VAT journals',
     'Opening balances',
     'Unpresented Items',
     'BankLink Notes',
     'BankLink Notes Online',
     'BankLink Books');

  atNameTable : array[ atMin..atMax ] of array[0..1] of byte =
    ((tkBegin_Practice_Details, dbSystem),    //Practice Setup
     (tkBegin_Practice_Details, dbSystem),    //Practice GST/VAT Defaults
     (0, dbSystem),                           //Master Memorisations
     (tkBegin_User, dbSystem),                //Users
     (tkBegin_Practice_Details, dbSystem),    //System Options
     (tkBegin_System_Disk_Log, dbSystem),     //Downloading Data
     (tkBegin_System_Bank_Account, dbSystem), //System Bank Accounts
     (0, dbSystem),                           //Provisional Data Entry
     (tkBegin_Client, dbClient),              //Client Files
     (tkBegin_Bank_Account, dbClient),        //Client Bank Accounts
     (tkBegin_Account, dbClient),             //Chart of Accounts
     (tkBegin_Payee_Detail, dbClient),        //Payees
     (tkBegin_Memorisation_Detail, dbClient), //Memorisations
     (tkBegin_Client, dbClient),              //GST/VAT Setup
     (tkBegin_Bank_Account, dbClient),         //Historical entries
     (tkBegin_Bank_Account, dbClient),         //Provisional entries
     (tkBegin_Bank_Account, dbClient),         //Manual entries
     (tkBegin_Bank_Account, dbClient),         //Delivered transactions
     (tkBegin_Bank_Account, dbClient),         //Automatic coding
     (tkBegin_Bank_Account, dbClient),         //Cash journals
     (tkBegin_Bank_Account, dbClient),         //Accrual journals
     (tkBegin_Bank_Account, dbClient),         //Stock/Adjustment journals
     (tkBegin_Bank_Account, dbClient),         //Year End Adjustment journals
     (tkBegin_Bank_Account, dbClient),         //GST/VAT journals
     (tkBegin_Bank_Account, dbClient),         //Opening balances
     (tkBegin_Bank_Account, dbClient),         //Unpresented Items
     (tkBegin_Bank_Account, dbClient),         //BankLink Notes
     (tkBegin_Bank_Account, dbClient),         //BankLink Notes Online
     (tkBegin_Bank_Account, dbClient));        //BankLink Books

//Notes: - Master memorisations are kept outside the System DB
//       - Some practice details are kept in an INI file (for Books)
//       - Some audit types are for the same record. Need to know what type of audit
//         is requird and restrict it to part of the record.
//       - What to audit for provisional data entry? Where to get it from (Archive?)
//       - Payees and Memorisations have detail lines
//       - If a Transaction/Disection is changes then limit audit to the Bank Account

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

function ToString(Value: Variant): String;
begin
  case TVarData(Value).VType of
    varSmallInt,
    varInteger   : Result := IntToStr(Value);
    varSingle,
    varDouble,
    varCurrency  : Result := FloatToStr(Value);
    varDate      : Result := FormatDateTime('dd/mm/yyyy', Value);
    varBoolean   : if Value then Result := 'T' else Result := 'F';
    varString    : Result := Value;
    else           Result := '';
  end;
end;

{ TAuditManager }

procedure TAuditManager.AddScope(AAuditType: TAuditType; ARecordID: integer);
var
  ScopeInfo: PScopeInfo;
begin
  New(ScopeInfo);
  ScopeInfo.AuditType := AAuditType;
  ScopeInfo.RecordID := ARecordID;
  if FindScopeInfo(ScopeInfo) = - 1 then
    FAuditScope.Add(ScopeInfo);
end;

function TAuditManager.AuditTypeToDBStr(AAuditType: TAuditType): string;
begin
  Result := '';
  if (AAuditType <= atMax)then
    case atNameTable[AAuditType, 1] of
      dbSystem: Result := 'SY';
      dbClient: Result := 'BK';
    end;
end;

function TAuditManager.AuditTypeToStr(AAuditType: TAuditType): string;
begin
  Result := '';
  if (AAuditType <= atMax)then
    Result := atNames[AAuditType];
end;

function TAuditManager.AuditTypeToTableID(AAuditType: TAuditType): byte;
begin
  Result := atNameTable[AAuditType, 0];
end;

function TAuditManager.AuditTypeToTableStr(AAuditType: TAuditType): string;
begin
  Result := '';
  if (AAuditType <= atMax)then
    case atNameTable[AAuditType, 1] of
      dbSystem: Result := SYAuditNames.GetAuditTableName(atNameTable[AAuditType, 0]);
      dbClient: Result := BKAuditNames.GetAuditTableName(atNameTable[AAuditType, 0]);
    end;
end;

constructor TAuditManager.Create;
begin
  FAuditScope := TList.Create;
end;

function TAuditManager.DBFromAuditType(AAuditType: TAuditType): byte;
begin
  Result := atNameTable[AAuditType, 1];
end;

destructor TAuditManager.Destroy;
var
  i: integer;
begin
  for i := 0 to FAuditScope.Count - 1 do
    Dispose(FAuditScope.Items[i]);
  FreeAndNil(FAuditScope);
  inherited;
end;

function TAuditManager.FindScopeInfo(AScopeInfo: PScopeInfo): integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to FAuditScope.Count - 1 do begin
    if (AScopeInfo.AuditType = PScopeInfo(FAuditScope.Items[i]).AuditType) and
       (AScopeInfo.RecordID = PScopeInfo(FAuditScope.Items[i]).RecordID) then begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TAuditManager.GetValues(ARecordType: byte; ARecord: pointer;
  Strings: TStrings);
var
  Values: string;
begin
  Values := '';
  case ARecordType of
    tkBegin_Payee_Detail    :
      begin
        if tPayee_Detail_Rec(ARecord^).pdNumber > 0 then
          AddAuditValue(tkBegin_Payee_Detail, 91, IntToStr(tPayee_Detail_Rec(ARecord^).pdNumber), Values);
        AddAuditValue(tkBegin_Payee_Detail, 92, tPayee_Detail_Rec(ARecord^).pdName, Values);
        Strings.Add(Values);
      end;
    tkBegin_Practice_Details:
      begin

      end;
    tkBegin_User            :
      begin
        AddAuditValue(tkBegin_User, 61, tUser_Rec(ARecord^).usCode, Values);
        AddAuditValue(tkBegin_User, 62, tUser_Rec(ARecord^).usName, Values);
        AddAuditValue(tkBegin_User, 64, tUser_Rec(ARecord^).usEMail_Address, Values);
        Strings.Add(Values);
      end;
  end;
end;

procedure TAuditManager.ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer);
begin
  case ARecordType of
    tkBegin_Payee_Detail    :
      begin
        ARecord := New_Payee_Detail_Rec;
        Read_Payee_Detail_Rec(TPayee_Detail_Rec(ARecord^), AStream);
      end;
    tkBegin_Practice_Details:
      begin
        ARecord := New_Practice_Details_Rec;
        Read_Practice_Details_Rec(TPractice_Details_Rec(ARecord^), AStream);
      end;
    tkBegin_User            :
      begin
        ARecord := New_User_Rec;
        Read_User_Rec(TUser_Rec(ARecord^), AStream);
      end;
  end;
end;

procedure TAuditManager.WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream);
begin
  case ARecordType of
    tkBegin_Payee_Detail    : Write_Payee_Detail_Rec(TPayee_Detail_Rec(ARecord^), AStream);
    tkBegin_Practice_Details: Write_Practice_Details_Rec(TPractice_Details_Rec(ARecord^), AStream);
    tkBegin_User            : Write_User_Rec(TUser_Rec(ARecord^), AStream);
  end;
end;

{ TClientAuditManager }

procedure TClientAuditManager.AddAuditValue(ATableID, AFieldID: byte; AValue: variant;
  var AAuditValue: string);
var
  Value: string;
begin
  Value := ToString(AValue);
  if Value <> '' then begin
    if (AAuditValue <> '') then
      AAuditValue := AAuditValue + ',';
    AAuditValue := AAuditValue +
                   BKAuditNames.GetAuditFieldName(ATableID, AFieldID) +
                   '=' + Value;
  end;
end;

procedure TClientAuditManager.DoAudit;
var
  i: integer;
  TableID: byte;
begin
  for i := 0 to FAuditScope.Count - 1 do begin
    TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
    case TableID of
      tkBegin_Payee_Detail: Client.PayeeTable.DoAudit(Client.AuditTable, ClientCopy.PayeeTable);
    end;
  end;
  FAuditScope.Clear;  
end;

procedure TClientAuditManager.FlagAudit(AAuditType: TAuditType; ARecord: Pointer);
begin
  AddScope(AAuditType, 0);
end;

function TClientAuditManager.NextClientRecordID: integer;
begin
  Result := Client.NextAuditRecordID;
end;


{ TSystemAuditManager }

procedure TSystemAuditManager.AddAuditValue(ATableID, AFieldID: byte; AValue: variant;
  var AAuditValue: string);
var
  Value: string;
begin
  Value := ToString(AValue);
  if Value <> '' then begin
    if (AAuditValue <> '') then
      AAuditValue := AAuditValue + ',';
    AAuditValue := AAuditValue +
                   SYAuditNames.GetAuditFieldName(ATableID, AFieldID) +
                   '=' + Value;
  end;
end;

procedure TSystemAuditManager.DoAudit;
var
  i: integer;
  TableID: byte;
begin
  for i := 0 to FAuditScope.Count - 1 do begin
    TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
    case TableID of
      tkBegin_Practice_Details: SystemData.DoAudit(@SystemCopy.PracticeDetails);
      tkBegin_User: SystemData.UserTable.DoAudit(SystemData.AuditTable, SystemCopy.UserTable);
    end;
  end;
  FAuditScope.Clear;
end;

procedure TSystemAuditManager.FlagAudit(AAuditType: TAuditType; ARecord: Pointer);
begin
  AddScope(AAuditType, 0);
end;

function TSystemAuditManager.NextSystemRecordID: integer;
begin
  Result := SystemData.NextAuditRecordID;
end;


end.
