unit AuditMgr;

interface

uses
  SysUtils, Classes, IOStream, SYAuditUtils, stTree, SYDEFS;

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
  atAttachBankAccounts            = 9;
  atClientBankAccounts            = 10;
  atChartOfAccounts               = 11;
  atPayees                        = 12;
  atMemorisations                 = 13;
  atGSTSetup                      = 14;
  atHistoricalentries             = 15;
  atProvisionalEntries            = 16;
  atManualEntries                 = 17;
  atDeliveredTransactions         = 18;
  atAutomaticCoding               = 19;
  atCashJournals                  = 20;
  atAccrualJournals               = 21;
  atStockAdjustmentJournals       = 22;
  atYearEndAdjustmentJournals     = 23;
  atGSTJournals                   = 24;
  atOpeningBalances               = 25;
  atUnpresentedItems              = 26;
  atBankLinkNotes                 = 27;
  atBankLinkNotesOnline           = 28;
  atBankLinkBooks                 = 29; atMax = 29;
  atAll = 254;

  SystemAuditTypes = [atPracticeSetup..atClientFiles, atAll];

  //Audit actions
  aaNone   = 0;  aaMin = 0;
  aaAdd    = 1;
  aaChange = 2;
  aaDelete = 3;  aaMax = 3;

  //Audit action strings
  aaNames : array[ aaMin..aaMax ] of string = ('None', 'Add', 'Change', 'Delete');

  dbSystem = 0;
  dbClient = 1;

  VALUES_DELIMITER = '¦'; //non-keyboard character

type

  TAuditType = atMin..atMax;

  TAuditInfo = record
    AuditRecordID: integer;
    AuditUser: string;
    AuditType: TAuditType;
    AuditAction: byte;
    AuditParentID: integer;
    AuditRecordType: byte;
    AuditChangedFields: TChanged_Fields_Array;
    AuditOtherInfo: string;
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
    function AuditTypeToStr(AAuditType: Byte): string;
    function AuditTypeToDBStr(AAuditType: TAuditType): string;
    function AuditTypeToTableStr(AAuditType: TAuditType): string;
    function DBFromAuditType(AAuditType: TAuditType): byte;
    function CurrentUserCode: string;
    function GetParentRecordID(ARecordType: byte; ARecordID: integer): integer; virtual; abstract;
    procedure AddAuditValue(AFieldName: string; AValue: variant; var AAuditValue: string); virtual;
    procedure DoAudit; virtual; abstract;
    procedure FlagAudit(AAuditType: TAuditType; ARecord: Pointer = nil); virtual; abstract;
    procedure WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream); virtual; abstract;
    procedure ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer); virtual; abstract;
    procedure GetValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string); virtual; abstract;
    //test
    procedure CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer); virtual; abstract;
  end;

  TSystemAuditManager = class(TAuditManager)
  private
  public
    function NextSystemRecordID: integer;
    function GetParentRecordID(ARecordType: byte; ARecordID: integer): integer; override;
    function BankAccountFromLRN(ALRN: integer): string;
    function ClientCodeFromLRN(ALRN: integer): string;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType; ARecord: Pointer = nil); override;
    procedure GetValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string); override;
    procedure ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer); override;
    procedure WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream); override;
    procedure CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer); override;
  end;

//  TClientAuditManager = class(TAuditManager)
//  public
//    function NextClientRecordID: integer;
//    function GetParentRecordID(ARecordType: byte; ARecordID: integer): integer; override;
//    procedure DoAudit; override;
//    procedure FlagAudit(AAuditType: TAuditType; ARecord: Pointer = nil); override;
//    procedure GetValues(AAuditRecord: TAudit_Trail_Rec; Strings: TStrings); override;
//    procedure ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer; var ChangedFields: string); override;
//    procedure WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream); override;
//  end;

  function SystemAuditMgr: TSystemAuditManager;
//  function ClientAuditMgr: TClientAuditManager;

  procedure GST_Class_Names_Audit_Values(V1: TGST_Class_Names_Array; var Values: string);
  procedure GST_Rates_Audit_Values(V1: TGST_Rates_Array; var Values: string);

implementation

uses
  Globals, SysObj32, MoneyDef, MoneyUtils, SystemMemorisationList,
  SYAUDIT, SYUSIO, SYFDIO, SYDLIO, SYSBIO, SYAMIO, SYCFIO, SYSMIO,
  BKDEFS, {BKAUDIT,} BKPDIO, BKCLIO, BKBAIO, BKCHIO, BKTXIO, BKMDIO;

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
     'Attach Bank Accounts',
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
     (tkBegin_System_Memorisation_List, dbSystem), //Master Memorisations
     (tkBegin_User, dbSystem),                //Users
     (tkBegin_Practice_Details, dbSystem),    //System Options
     (tkBegin_System_Disk_Log, dbSystem),     //Downloading Data
     (tkBegin_System_Bank_Account, dbSystem), //System Bank Accounts
     (0, dbSystem),                           //Provisional Data Entry
     (tkBegin_Client_File, dbSystem),         //System Client Files
     (tkBegin_Client_Account_Map, dbClient),  //Attach Bank Accounts
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
//  _ClientAuditMgr: TClientAuditManager;

function SystemAuditMgr: TSystemAuditManager;
begin
  if not Assigned(_SystemAuditMgr) then
    _SystemAuditMgr := TSystemAuditManager.Create;
  Result := _SystemAuditMgr;
end;

//function ClientAuditMgr: TClientAuditManager;
//begin
//  if not Assigned(_ClientAuditMgr) then
//    _ClientAuditMgr := TClientAuditManager.Create;
//  Result := _ClientAuditMgr;
//end;

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

procedure GST_Class_Names_Audit_Values(V1: TGST_Class_Names_Array; var Values: string);
var
  i: integer;
  Value: string;
  FieldName: string;
  TempStr: string;
begin
  TempStr := '';
  for i := Low(V1) to High(V1) do begin
    Value := V1[i];
    if Value <> '' then begin
      if (Values <> '') or (TempStr <> '') then
        TempStr := TempStr + VALUES_DELIMITER;
      FieldName := SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 19);
      TempStr := Format('%s%s[%d]=%s', [TempStr, FieldName, i, Value]);
    end;
  end;
  Values := Values + TempStr;
end;

procedure GST_Rates_Audit_Values(V1: TGST_Rates_Array; var Values: string);
var
  i, j: integer;
  Value: money;
  FieldName: string;
  TempStr: string;
begin
  TempStr := '';
  for i := Low(V1) to High(V1) do
    for j := Low(V1[i]) to High(V1[i]) do begin
      Value := V1[i, j];
      if Value <> 0 then begin
        if (Values <> '') or (TempStr <> '') then
          TempStr := TempStr + VALUES_DELIMITER;
        FieldName := SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 22);
        TempStr := Format('%s%s[%d, %d]=%s', [TempStr, FieldName, i, j, MoneyStrNoSymbol(Value / 100)]);
      end;
    end;
  Values := Values + TempStr;
end;

{ TAuditManager }

procedure TAuditManager.AddAuditValue(AFieldName: string;
  AValue: variant; var AAuditValue: string);
var
  Value: string;
begin
  if TVarData(AValue).VType = varByte then
    Value := IntToStr(AValue)
  else
    Value := ToString(AValue);
  if (AAuditValue <> '') then
    AAuditValue := AAuditValue + VALUES_DELIMITER;
  AAuditValue := AAuditValue + AFieldName + '=' + Value;
end;

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

function TAuditManager.AuditTypeToStr(AAuditType: Byte): string;
begin
  Result := '';
  if (AAuditType <= atMax)then
    Result := atNames[AAuditType]
  else if AAuditType = atAll then
    Result := 'All';
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
//      dbClient: Result := BKAuditNames.GetAuditTableName(atNameTable[AAuditType, 0]);
    end;
end;

constructor TAuditManager.Create;
begin
  FAuditScope := TList.Create;
end;

function TAuditManager.CurrentUserCode: string;
begin
{$IFDEF LOOKUPDLL}
  Result := '';
{$ELSE}
  Result := Globals.CurrUser.Code;
{$ENDIF}
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

{ TClientAuditManager }

//procedure TClientAuditManager.DoAudit;
//var
//  i: integer;
//  TableID: byte;
//begin
//  for i := 0 to FAuditScope.Count - 1 do begin
//    TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
//    case TableID of
//      tkBegin_Payee_Detail: Client.PayeeTable.DoAudit(Client.AuditTable, ClientCopy.PayeeTable);
//    end;
//  end;
//  FAuditScope.Clear;
//end;
//
//procedure TClientAuditManager.FlagAudit(AAuditType: TAuditType; ARecord: Pointer);
//begin
//  AddScope(AAuditType, 0);
//end;
//
//function TClientAuditManager.GetParentRecordID(ARecordType: byte;
//  ARecordID: integer): integer;
//begin
//  Result := 0;
//end;
//
//function TClientAuditManager.NextClientRecordID: integer;
//begin
//  Result := Client.NextAuditRecordID;
//end;


{ TSystemAuditManager }

function TSystemAuditManager.BankAccountFromLRN(ALRN: integer): string;
var
  System_Bank_Account_Rec: pSystem_Bank_Account_Rec;
begin
  Result := '';
  System_Bank_Account_Rec := AdminSystem.fdSystem_Bank_Account_List.FindLRN(ALRN);
  if Assigned(System_Bank_Account_Rec) then
    Result := System_Bank_Account_Rec.sbAccount_Number;
end;

function TSystemAuditManager.ClientCodeFromLRN(ALRN: integer): string;
var
  Client_File_Rec: pClient_File_Rec;
begin
  Result := '';
  Client_File_Rec := AdminSystem.fdSystem_Client_File_List.FindLRN(ALRN);
  if Assigned(Client_File_Rec) then
    Result := Client_File_Rec.cfFile_Code;
end;

procedure TSystemAuditManager.CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer);
begin
  case ARecordType of
    tkBegin_Practice_Details:
      begin
        P2 := New_Practice_Details_Rec;
        Copy_Practice_Details_Rec(P1, P2);
      end;
    tkBegin_User:
      begin
        P2 := New_User_Rec;
        Copy_User_Rec(P1, P2);
      end;
    tkBegin_System_Disk_Log:
      begin
        P2 := New_System_Disk_Log_Rec;
        Copy_System_Disk_Log_Rec(P1, P2);
      end;
    tkBegin_System_Bank_Account:
      begin
        P2 := New_System_Bank_Account_Rec;
        Copy_System_Bank_Account_Rec(P1, P2);
      end;
    tkBegin_Client_Account_Map:
      begin
        P2 := New_Client_Account_Map_Rec;
        Copy_Client_Account_Map_Rec(P1, P2);
      end;
    tkBegin_Client_File:
      begin
        P2 := New_Client_File_Rec;
        Copy_Client_File_Rec(P1, P2);
      end;
    tkBegin_System_Memorisation_List:
      begin
        //Speacial copy
        P2 := New_System_Memorisation_List_Rec;
        CopySystemMemorisation(P1, P2);
      end;
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
      tkBegin_Practice_Details: AdminSystem.DoAudit(@SystemCopy.fdFields, PScopeInfo(FAuditScope.Items[i]).AuditType);
      tkBegin_User: AdminSystem.fdSystem_User_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                           SystemCopy.fdSystem_User_List,
                                                           AdminSystem.fAuditTable);
      tkBegin_System_Disk_Log: AdminSystem.fdSystem_Disk_Log.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                           SystemCopy.fdSystem_Disk_Log,
                                                           AdminSystem.fAuditTable);
      tkBegin_System_Bank_Account: AdminSystem.fdSystem_Bank_Account_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                           SystemCopy.fdSystem_Bank_Account_List,
                                                           AdminSystem.fAuditTable);
      tkBegin_Client_Account_Map: AdminSystem.fdSystem_Client_Account_Map.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                           SystemCopy.fdSystem_Client_Account_Map,
                                                           AdminSystem.fAuditTable);
      tkBegin_Client_File: AdminSystem.fdSystem_Client_File_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                           SystemCopy.fdSystem_Client_File_List,
                                                           AdminSystem.fAuditTable);
      tkBegin_System_Memorisation_List: AdminSystem.fSystem_Memorisation_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                           SystemCopy.fSystem_Memorisation_List,
                                                           AdminSystem.fAuditTable);
    end;
  end;
  FAuditScope.Clear;
end;

procedure TSystemAuditManager.FlagAudit(AAuditType: TAuditType; ARecord: Pointer);
begin
  AddScope(AAuditType, 0);
end;

function TSystemAuditManager.GetParentRecordID(ARecordType: byte; ARecordID: integer): integer;
begin
  Result := -1;
  case ARecordType of
    tkBegin_Practice_Details: Result := -1;
    tkBegin_User,
    tkBegin_System_Disk_Log,
    tkBegin_System_Bank_Account,
    tkBegin_Client_Account_Map,
    tkBegin_Client_File,
    tkBegin_System_Memorisation_List: Result := AdminSystem.fdFields.fdAudit_Record_ID;
  end;
end;

procedure TSystemAuditManager.GetValues(const AAuditRecord: TAudit_Trail_Rec;
  var Values: string);
begin
  Values := '';
  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Practice_Details: AdminSystem.AddAuditValues(AAuditRecord, Values);
    tkBegin_User            : AdminSystem.fdSystem_User_List.AddAuditValues(AAuditRecord, Values);
    tkBegin_System_Disk_Log : AdminSystem.fdSystem_Disk_Log.AddAuditValues(AAuditRecord, Values);
    tkBegin_System_Bank_Account : AdminSystem.fdSystem_Bank_Account_List.AddAuditValues(AAuditRecord, Values);
    tkBegin_Client_Account_Map  : AdminSystem.fdSystem_Client_Account_Map.AddAuditValues(AAuditRecord, Values);
    tkBegin_Client_File         : AdminSystem.fdSystem_Client_File_List.AddAuditValues(AAuditRecord, Values);
    tkBegin_System_Memorisation_List: AdminSystem.fSystem_Memorisation_List.AddAuditValues(AAuditRecord, Values);
  end;
end;

function TSystemAuditManager.NextSystemRecordID: integer;
begin
  Result := AdminSystem.NextAuditRecordID;
end;   

procedure TSystemAuditManager.ReadAuditRecord(ARecordType: byte;
  AStream: TIOStream; var ARecord: pointer);
begin
  case ARecordType of
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
    tkBegin_System_Disk_Log :
      begin
        ARecord := New_System_Disk_Log_Rec;
        Read_System_Disk_Log_Rec(TSystem_Disk_Log_Rec(ARecord^), AStream);
      end;
    tkBegin_System_Bank_Account :
      begin
        ARecord := New_System_Bank_Account_Rec;
        Read_System_Bank_Account_Rec(TSystem_Bank_Account_Rec(ARecord^), AStream);
      end;
    tkBegin_Client_Account_Map:
      begin
        ARecord := New_Client_Account_Map_Rec;
        Read_Client_Account_Map_Rec(TClient_Account_Map_Rec(ARecord^), AStream);
      end;
    tkBegin_Client_File:
      begin
        ARecord := New_Client_File_Rec;
        Read_Client_File_Rec(TClient_File_Rec(ARecord^), AStream);
      end;
    tkBegin_System_Memorisation_List:
      begin
        ARecord := New_System_Memorisation_List_Rec;
        Read_System_Memorisation_List_Rec(TSystem_Memorisation_List_Rec(ARecord^), AStream);
      end;
  end;
end;

procedure TSystemAuditManager.WriteAuditRecord(ARecordType: byte;
  ARecord: pointer; AStream: TIOStream);
begin
  case ARecordType of
    tkBegin_Practice_Details: Write_Practice_Details_Rec(TPractice_Details_Rec(ARecord^), AStream);
    tkBegin_User            : Write_User_Rec(TUser_Rec(ARecord^), AStream);
    tkBegin_System_Disk_Log : Write_System_Disk_Log_Rec(TSystem_Disk_Log_Rec(ARecord^), AStream);
    tkBegin_System_Bank_Account : Write_System_Bank_Account_Rec(TSystem_Bank_Account_Rec(ARecord^), AStream);
    tkBegin_Client_Account_Map  : Write_Client_Account_Map_Rec(TClient_Account_Map_Rec(ARecord^), AStream);
    tkBegin_Client_File         : Write_Client_File_Rec(TClient_File_Rec(ARecord^), AStream);
    tkBegin_System_Memorisation_List: Write_System_Memorisation_List_Rec(TSystem_Memorisation_List_Rec(ARecord^), AStream);
//    tkBegin_System_Memorisation_List: TSystem_Memorisation(ARecord^).SaveToStream(AStream); //Speacial write
  end;
end;

initialization
  _SystemAuditMgr := nil;
finalization
  if Assigned(_SystemAuditMgr) then
    FreeAndNil(_SystemAuditMgr);
end.
