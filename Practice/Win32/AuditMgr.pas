unit AuditMgr;

interface

uses
  SysUtils, Classes, IOStream, SYAuditUtils, stTree, SYDEFS, BKDEFS, MoneyDef,
  ECollect;

const
  UNIT_NAME = 'AuditMgr';

  //Audit types
  atPracticeSetup                 = 0;  atMin = 0;
  atPracticeGSTDefaults           = 1;
  atMasterMemorisations           = 2;
  atUsers                         = 3;
  atSystemOptions                 = 4;
  atDownloadingData               = 5;
  atSystemBankAccounts            = 6;
  atProvisionalDataEntry          = 7;
  atSystemClientFiles             = 8;
  atAttachBankAccounts            = 9;
  atClientBankAccounts            = 10;
  atChartOfAccounts               = 11;
  atPayees                        = 12;
  atClientFiles                   = 13;
  atMemorisations                 = 14;
  atGSTSetup                      = 15;
  atHistoricalentries             = 16;
  atProvisionalEntries            = 17;
  atManualEntries                 = 18;
  atDeliveredTransactions         = 19;
  atAutomaticCoding               = 20;
  atCashJournals                  = 21;
  atAccrualJournals               = 22;
  atStockAdjustmentJournals       = 23;
  atYearEndAdjustmentJournals     = 24;
  atGSTJournals                   = 25;
  atOpeningBalances               = 26;
  atUnpresentedItems              = 27;
  atBankLinkNotes                 = 28;
  atBankLinkNotesOnline           = 29;
  atBankLinkBooks                 = 30; atMax = 30;
  atAll = 254;

  //Audit actions
  aaNone   = 0;  aaMin = 0;
  aaAdd    = 1;
  aaChange = 2;
  aaDelete = 3;  aaMax = 3;

  //Audit action strings
  aaNames : array[ aaMin..aaMax ] of string = ('None', 'Add', 'Change', 'Delete');

  SystemAuditTypes = [atPracticeSetup..atSystemClientFiles, atAll];

  dbSystem = 0;
  dbClient = 1;

  OTHER_INFO_FLAG = '*';
  VALUES_DELIMITER = '¦'; //non-keyboard character

type
  //This is defined in MONEYDEF because all the IO units use MONEYDEF.
  TChanged_Fields_Array = MoneyDef.TChanged_Fields_Array;

  TAudit_Trail_Rec = SYDEFS.tAudit_Trail_Rec;

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

  TAuditCollection = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item : Pointer); override;
  public
    function Audit_At(Index : longint) : TAudit_Trail_Rec;
    function Compare(Item1,Item2 : Pointer): Integer; override;
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
    procedure CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer); virtual; abstract;
    property AuditScope: TList read FAuditScope;
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

  TClientAuditManager = class(TAuditManager)
  private
    FOwner: TObject;
  public
    constructor Create(Owner: TObject);
    function NextClientRecordID: integer;
    function GetParentRecordID(ARecordType: byte; ARecordID: integer): integer; override;
    function GetTransactionAuditType(ABankAccountSource: byte; ABankAccountType: byte): TAuditType;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType; ARecord: Pointer = nil); override;
    procedure GetValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string); override;
    procedure ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer); override;
    procedure WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream); override;
    procedure CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer); override;
  end;

  TAuditTable = class(TObject)
  private
    FAuditRecords: TAuditCollection;
    FAuditManager: TAuditManager;
  public
    constructor Create(AAuditManager: TAuditManager);
    destructor Destroy; override;
    procedure AddAuditRec(AAuditInfo: TAuditInfo);
    procedure LoadFromFile(AFileName: TFileName);
    procedure LoadFromStream( var S: TIOStream);
    procedure SaveToFile (AFileName: TFileName);
    procedure SaveToStream (var S: TIOStream);
    procedure SetAuditStrings(Index: integer; Strings: TStrings);
    property AuditRecords: TAuditCollection read FAuditRecords;
  end;

  //System audit manager is a singleton because there is only one system DB
  function SystemAuditMgr: TSystemAuditManager;

  function GetAccountingSystemName(AAccountingSystem: byte): string;
  function GetUserCode(AUserLRN: integer): string;
  function GetGroupName(AGroupLRN: integer): string;
  function GetClientFileType(AClientTypeLRN: integer): string;

  procedure SetProvisionalInfo(ATxnLRN: integer; var AUserCode: shortstring; var ADateTime: TDateTime);

  procedure GST_Class_Names_Audit_Values(V1: TGST_Class_Names_Array; var Values: string);
  procedure GST_Rates_Audit_Values(V1: TGST_Rates_Array; var Values: string);
  procedure GST_Applies_From_Array(V1: TGST_Applies_From_Array; var Values: string);

implementation

{$IFDEF LOOKUPDLL}
uses
  TOKENS, BKDbExcept, BKAuditValues,                                
  SYAUDIT, SYATIO, SYUSIO, SYFDIO, SYDLIO, SYSBIO, SYAMIO, SYCFIO, SYSMIO,
  BKAUDIT, BKPDIO, BKCLIO, BKCEIO, BKBAIO, BKCHIO, BKTXIO, BKMDIO, BKMLIO, BKPLIO;
{$ELSE}
uses
  Globals, bkConst, SysObj32, ClObj32, MoneyUtils, SystemMemorisationList, BKAuditValues,
  bkdateutils, TOKENS,  BKDbExcept,
  SYAUDIT, SYATIO, SYUSIO, SYFDIO, SYDLIO, SYSBIO, SYAMIO, SYCFIO, SYSMIO,
  BKAUDIT, BKPDIO, BKCLIO, BKCEIO, BKBAIO, BKCHIO, BKTXIO, BKMDIO, BKMLIO, BKPLIO;

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
     'Client File',
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
     (0, dbSystem),                           //Downloading Data - NOT AUDITED
     (tkBegin_System_Bank_Account, dbSystem), //System Bank Accounts
     (0, dbSystem),                           //Provisional Data Entry
     (tkBegin_Client_File, dbSystem),         //System Client Files
     (tkBegin_Client_Account_Map, dbClient),  //Attach Bank Accounts

     (tkBegin_Client, dbClient),              //Client Bank Accounts
     (tkBegin_Account, dbClient),             //Chart of Accounts
     (tkBegin_Payee_Detail, dbClient),        //Payees
     (tkBegin_Client, dbClient),              //Client Files
     (tkBegin_Bank_Account, dbClient),         //Memorisations
     (tkBegin_Client, dbClient),         //GST/VAT Setup
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
     (tkBegin_Client, dbClient),         //BankLink Notes
     (tkBegin_Client, dbClient),         //BankLink Notes Online
     (tkBegin_Client, dbClient));        //BankLink Books
{$ENDIF}

//Notes: - Master memorisations are kept outside the System DB
//       - Some practice details are kept in an INI file (for Books)
//       - Some audit types are for the same record. Need to know what type of audit
//         is requird and restrict it to part of the record.
//       - What to audit for provisional data entry? Where to get it from (Archive?)
//       - Payees and Memorisations have detail lines
//       - If a Transaction/Disection is changes then limit audit to the Bank Account
var
  _SystemAuditMgr: TSystemAuditManager;

function SystemAuditMgr: TSystemAuditManager;
begin
  if not Assigned(_SystemAuditMgr) then
    _SystemAuditMgr := TSystemAuditManager.Create;
  Result := _SystemAuditMgr;
end;

function GetAccountingSystemName(AAccountingSystem: byte): string;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  case AdminSystem.fdFields.fdCountry of
    whNewZealand: if AAccountingSystem in [snMin..snMax] then
                    Result := snNames[AAccountingSystem];
    whAustralia : if AAccountingSystem in [saMin..saMax] then
                    Result := saNames[AAccountingSystem];
    whUK        : if AAccountingSystem in [suMin..suMax] then
                    Result := suNames[AAccountingSystem];
  end;
{$ENDIF}
end;

function GetUserCode(AUserLRN: integer): string;
var
  User: pUser_Rec;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  User := AdminSystem.fdSystem_User_List.FindLRN(AUserLRN);
  if Assigned(User) then
    Result := User.usCode;
{$ENDIF}
end;

function GetGroupName(AGroupLRN: integer): string;
var
  Group: pGroup_Rec;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  Group := AdminSystem.fdSystem_Group_List.FindLRN(AGroupLRN);
  if Assigned(Group) then
    Result := Group.grName;
{$ENDIF}
end;

function GetClientFileType(AClientTypeLRN: integer): string;
var
  ClientType: pClient_Type_Rec;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  ClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(AClientTypeLRN);
  if Assigned(ClientType) then
    Result := ClientType.ctName;
{$ENDIF}
end;

procedure SetProvisionalInfo(ATxnLRN: integer; var AUserCode: shortstring; var ADateTime: TDateTime);
var
  i: integer;
begin
{$IFNDEF LOOKUPDLL}
   AUserCode := 'UNKNOWN';
   ADateTime := 0;
  if Assigned(AdminSystem) then begin
    with AdminSystem.fSystem_Provisional_List do begin
      for i := First to Last do
        if (ATxnLRN >= Provisional_Entry_At(i).peFirst_LRN) and
           (ATxnLRN <= Provisional_Entry_At(i).peLast_LRN) then begin
          AUserCode := Provisional_Entry_At(i).peUser_Code;
          ADateTime := Provisional_Entry_At(i).peDate_Time;
          Exit;
        end;
    end;
  end;
{$ENDIF}
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

procedure GST_Class_Names_Audit_Values(V1: TGST_Class_Names_Array; var Values: string);
var
  i: integer;
  Value: string;
  FieldName: string;
  TempStr: string;
begin
{$IFNDEF LOOKUPDLL}
  TempStr := '';
  for i := Low(V1) to High(V1) do begin
    Value := V1[i];
    if Value <> '' then begin
      if (Values <> '') or (TempStr <> '') then
        TempStr := TempStr + VALUES_DELIMITER;
      FieldName := SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 20);
      TempStr := Format('%s%s[%d]=%s', [TempStr, FieldName, i, Value]);
    end;
  end;
  Values := Values + TempStr;
{$ENDIF}
end;

procedure GST_Rates_Audit_Values(V1: TGST_Rates_Array; var Values: string);
var
  i, j: integer;
  Value: money;
  FieldName: string;
  TempStr: string;
begin
{$IFNDEF LOOKUPDLL}
  TempStr := '';
  for i := Low(V1) to High(V1) do
    for j := Low(V1[i]) to High(V1[i]) do begin
      Value := V1[i, j];
      if Value <> 0 then begin
        if (Values <> '') or (TempStr <> '') then
          TempStr := TempStr + VALUES_DELIMITER;
        FieldName := SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 23);
        TempStr := Format('%s%s[%d, %d]=%s', [TempStr, FieldName, i, j, MoneyStrNoSymbol(Value / 100)]);
      end;
    end;
  Values := Values + TempStr;
{$ENDIF}
end;

procedure GST_Applies_From_Array(V1: TGST_Applies_From_Array; var Values: string);
var
  i: integer;
  Value: string;
  FieldName: string;
  TempStr: string;
begin
{$IFNDEF LOOKUPDLL}
  TempStr := '';
  for i := Low(V1) to High(V1) do begin
    Value := bkDate2Str(V1[i]);
    if Value <> '' then begin
      if (Values <> '') or (TempStr <> '') then
        TempStr := TempStr + VALUES_DELIMITER;
      FieldName := SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 24);
      TempStr := Format('%s%s[%d]=%s', [TempStr, FieldName, i, Value]);
    end;
  end;
  Values := Values + TempStr;
{$ENDIF}
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
{$IFNDEF LOOKUPDLL}
  Result := '';
  if (AAuditType <= atMax)then
    case atNameTable[AAuditType, 1] of
      dbSystem: Result := 'SY';
      dbClient: Result := 'BK';
    end;
{$ENDIF}
end;

function TAuditManager.AuditTypeToStr(AAuditType: Byte): string;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  if (AAuditType <= atMax)then
    Result := atNames[AAuditType]
  else if AAuditType = atAll then
    Result := 'All';
{$ENDIF}
end;

function TAuditManager.AuditTypeToTableID(AAuditType: TAuditType): byte;
begin
{$IFNDEF LOOKUPDLL}
  Result := atNameTable[AAuditType, 0];
{$ENDIF}
end;

function TAuditManager.AuditTypeToTableStr(AAuditType: TAuditType): string;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  if (AAuditType <= atMax)then
    case atNameTable[AAuditType, 1] of
      dbSystem: Result := SYAuditNames.GetAuditTableName(atNameTable[AAuditType, 0]);
      dbClient: Result := BKAuditNames.GetAuditTableName(atNameTable[AAuditType, 0]);
    end;
{$ENDIF}
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
{$IFNDEF LOOKUPDLL}
  Result := atNameTable[AAuditType, 1];
{$ENDIF}
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


{ TSystemAuditManager }

function TSystemAuditManager.BankAccountFromLRN(ALRN: integer): string;
var
  System_Bank_Account_Rec: pSystem_Bank_Account_Rec;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  System_Bank_Account_Rec := AdminSystem.fdSystem_Bank_Account_List.FindLRN(ALRN);
  if Assigned(System_Bank_Account_Rec) then
    Result := System_Bank_Account_Rec.sbAccount_Number;
{$ENDIF}
end;

function TSystemAuditManager.ClientCodeFromLRN(ALRN: integer): string;
var
  Client_File_Rec: pClient_File_Rec;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  Client_File_Rec := AdminSystem.fdSystem_Client_File_List.FindLRN(ALRN);
  if Assigned(Client_File_Rec) then
    Result := Client_File_Rec.cfFile_Code;
{$ENDIF}
end;

procedure TSystemAuditManager.CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer);
begin
{$IFNDEF LOOKUPDLL}
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
//    tkBegin_System_Disk_Log:
//      begin
//        P2 := New_System_Disk_Log_Rec;
//        Copy_System_Disk_Log_Rec(P1, P2);
//      end;
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
    tkBegin_Memorisation_Detail:
      begin
        P2 := New_Memorisation_Detail_Rec;
        Copy_Memorisation_Detail_Rec(P1, P2);
      end;
    tkBegin_Memorisation_Line:
      begin
        P2 := New_Memorisation_Line_Rec;
        Copy_Memorisation_Line_Rec(P1, P2);
      end;
  end;
{$ENDIF}
end;

procedure TSystemAuditManager.DoAudit;
var
  i: integer;
  TableID: byte;
begin
{$IFNDEF LOOKUPDLL}
  for i := 0 to FAuditScope.Count - 1 do begin
    TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
    case TableID of
      tkBegin_Practice_Details: AdminSystem.DoAudit(@SystemCopy.fdFields, PScopeInfo(FAuditScope.Items[i]).AuditType);
      tkBegin_User: AdminSystem.fdSystem_User_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                           SystemCopy.fdSystem_User_List,
                                                           AdminSystem.fAuditTable);
//      tkBegin_System_Disk_Log: AdminSystem.fdSystem_Disk_Log.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
//                                                           SystemCopy.fdSystem_Disk_Log,
//                                                           AdminSystem.fAuditTable);
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
                                                           SystemCopy.fSystem_Memorisation_List, 0,
                                                           AdminSystem.fAuditTable);
      tkBegin_Memorisation_Detail: ; //Do nothing - sub list (TSystem_Memorisation_List - TMemorisations_List)
      tkBegin_Memorisation_Line: ;   //Do nothing - sub list (TSystem_Memorisation_List - TMemorisations_List - TMemorisation)
    end;
  end;
  FAuditScope.Clear;
{$ENDIF}
end;

procedure TSystemAuditManager.FlagAudit(AAuditType: TAuditType; ARecord: Pointer);
begin
  AddScope(AAuditType, 0);
end;

function TSystemAuditManager.GetParentRecordID(ARecordType: byte; ARecordID: integer): integer;
begin
{$IFNDEF LOOKUPDLL}
  Result := -1;
  case ARecordType of
    tkBegin_Practice_Details: Result := -1;
    tkBegin_User,
//    tkBegin_System_Disk_Log,
    tkBegin_System_Bank_Account,
    tkBegin_Client_Account_Map,
    tkBegin_Client_File,
    tkBegin_System_Memorisation_List: Result := AdminSystem.fdFields.fdAudit_Record_ID;
    tkBegin_Memorisation_Detail: Result := 0; //Should be ID of system master mem list
    tkBegin_Memorisation_Line: Result := 0; //Should be ID of mem list
  end;
{$ENDIF}
end;

procedure TSystemAuditManager.GetValues(const AAuditRecord: TAudit_Trail_Rec;
  var Values: string);
begin
{$IFNDEF LOOKUPDLL}
  Values := AAuditRecord.atOther_Info;
  if AAuditRecord.atAudit_Record = nil then
    Exit;

  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Practice_Details: AdminSystem.AddAuditValues(AAuditRecord, Values);
    tkBegin_User            : AdminSystem.fdSystem_User_List.AddAuditValues(AAuditRecord, Values);
//    tkBegin_System_Disk_Log : AdminSystem.fdSystem_Disk_Log.AddAuditValues(AAuditRecord, Values);
    tkBegin_System_Bank_Account : AdminSystem.fdSystem_Bank_Account_List.AddAuditValues(AAuditRecord, Values);
    tkBegin_Client_Account_Map  : AdminSystem.fdSystem_Client_Account_Map.AddAuditValues(AAuditRecord, Values);
    tkBegin_Client_File         : AdminSystem.fdSystem_Client_File_List.AddAuditValues(AAuditRecord, Values);
    tkBegin_System_Memorisation_List,
    tkBegin_Memorisation_Detail,
    tkBegin_Memorisation_Line   : AdminSystem.fSystem_Memorisation_List.AddAuditValues(AAuditRecord, Values);
  end;
{$ENDIF}
end;

function TSystemAuditManager.NextSystemRecordID: integer;
begin
{$IFNDEF LOOKUPDLL}
  Result := AdminSystem.NextAuditRecordID;
{$ENDIF}
end;   

procedure TSystemAuditManager.ReadAuditRecord(ARecordType: byte;
  AStream: TIOStream; var ARecord: pointer);
begin
{$IFNDEF LOOKUPDLL}
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
//    tkBegin_System_Disk_Log :
//      begin
//        ARecord := New_System_Disk_Log_Rec;
//        Read_System_Disk_Log_Rec(TSystem_Disk_Log_Rec(ARecord^), AStream);
//      end;
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
    tkBegin_Memorisation_Detail:
      begin
        ARecord := New_Memorisation_Detail_Rec;
        Read_Memorisation_Detail_Rec(TMemorisation_Detail_Rec(ARecord^), AStream);
      end;
    tkBegin_Memorisation_Line:
      begin
        ARecord := New_Memorisation_Line_Rec;
        Read_Memorisation_Line_Rec(TMemorisation_Line_Rec(ARecord^), AStream);
      end;
  end;
{$ENDIF}
end;

procedure TSystemAuditManager.WriteAuditRecord(ARecordType: byte;
  ARecord: pointer; AStream: TIOStream);
begin
{$IFNDEF LOOKUPDLL}
  case ARecordType of
    tkBegin_Practice_Details: Write_Practice_Details_Rec(TPractice_Details_Rec(ARecord^), AStream);
    tkBegin_User            : Write_User_Rec(TUser_Rec(ARecord^), AStream);
//    tkBegin_System_Disk_Log : Write_System_Disk_Log_Rec(TSystem_Disk_Log_Rec(ARecord^), AStream);
    tkBegin_System_Bank_Account : Write_System_Bank_Account_Rec(TSystem_Bank_Account_Rec(ARecord^), AStream);
    tkBegin_Client_Account_Map  : Write_Client_Account_Map_Rec(TClient_Account_Map_Rec(ARecord^), AStream);
    tkBegin_Client_File         : Write_Client_File_Rec(TClient_File_Rec(ARecord^), AStream);
    tkBegin_System_Memorisation_List: Write_System_Memorisation_List_Rec(TSystem_Memorisation_List_Rec(ARecord^), AStream);
    tkBegin_Memorisation_Detail : Write_Memorisation_Detail_Rec(TMemorisation_Detail_Rec(ARecord^), AStream);
    tkBegin_Memorisation_Line   : Write_Memorisation_Line_Rec(TMemorisation_Line_Rec(ARecord^), AStream);
  end;
{$ENDIF}
end;

{ TClientAuditManager }

procedure TClientAuditManager.CopyAuditRecord(const ARecordType: byte;
  P1: Pointer; var P2: Pointer);
begin
{$IFNDEF LOOKUPDLL}
  case ARecordType of
    tkBegin_Client :
      begin
        P2 := New_Client_Rec;
        Copy_Client_Rec(P1, P2);
      end;
    tkBegin_ClientExtra :
      begin
        P2 := New_ClientExtra_Rec;
        Copy_ClientExtra_Rec(P1, P2);
      end;
    tkBegin_Payee_Detail:
      begin
        P2 := New_Payee_Detail_Rec;
        Copy_Payee_Detail_Rec(P1, P2);
      end;
    tkBegin_Payee_Line:
      begin
        P2 := New_Payee_Line_Rec;
        Copy_Payee_Line_Rec(P1, P2);
      end;
    tkBegin_Bank_Account:
      begin
        P2 := New_Bank_Account_Rec;
        Copy_Bank_Account_Rec(P1, P2);
      end;
    tkBegin_Transaction:
      begin
        P2 := New_Transaction_Rec;
        Copy_Transaction_Rec(P1, P2);
      end;
  end;
{$ENDIF}
end;

constructor TClientAuditManager.Create(Owner: TObject);
begin
  inherited Create;

  FOwner := nil;
{$IFNDEF LOOKUPDLL}
  if Owner is TClientObj then
    FOwner := Owner;
{$ENDIF}
end;

procedure TClientAuditManager.DoAudit;
var
  i: integer;
  TableID: byte;
begin
{$IFNDEF LOOKUPDLL}
  with FOwner as TClientObj do
    for i := 0 to FAuditScope.Count - 1 do begin
      TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
      case TableID of
        tkBegin_Client      : DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType, ClientCopy);
        tkBegin_Payee_Detail: clPayee_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                   ClientCopy.clPayee_List, 0, fAuditTable);
        tkBegin_Payee_Line  : ;//Done in payee detail
        tkBegin_Transaction : ;//Done in bank account
        tkBegin_Bank_Account: clBank_Account_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                          ClientCopy.clBank_Account_List,
                                                          0, fAuditTable);
      end;
    end;
  FAuditScope.Clear;
{$ENDIF}
end;

procedure TClientAuditManager.FlagAudit(AAuditType: TAuditType;
  ARecord: Pointer);
begin
  AddScope(AAuditType, 0);
end;

function TClientAuditManager.GetParentRecordID(ARecordType: byte;
  ARecordID: integer): integer;
begin
  Result := 0;
end;

function TClientAuditManager.GetTransactionAuditType(ABankAccountSource: byte;
  ABankAccountType: byte): TAuditType;
begin
  case ABankAccountSource of
    orBank         : Result := atDeliveredTransactions;
    orGenerated    : Result := atUnpresentedItems;
    orManual       :
       case ABankAccountType of
         btCashJournals   : Result := atCashJournals;
         btAccrualJournals: Result := atAccrualJournals;
         btGSTJournals    : Result := atGSTJournals;
       end;
    orHistorical   : Result := atHistoricalentries;
    orGeneratedRev : Result := atUnpresentedItems;
    orMDE          : Result := atManualEntries;
    orProvisional  : Result := atProvisionalEntries;
  else
    Result := atDeliveredTransactions;
  end;
end;

procedure AddOtherInfoFlag(var AValuesString: string);
var
  i: integer;
  ValuesList: TStringList;
begin
  ValuesList := TStringList.Create;
  try
    ValuesList.Delimiter := VALUES_DELIMITER;
    ValuesList.StrictDelimiter := true;
    ValuesList.DelimitedText := AValuesString;
    for i := 0 to ValuesList.Count - 1 do
      ValuesList.Strings[i] := OTHER_INFO_FLAG + ValuesList.Strings[i];
    AValuesString := ValuesList.DelimitedText;
  finally
    ValuesList.Free;
  end;
end;

procedure TClientAuditManager.GetValues(const AAuditRecord: TAudit_Trail_Rec;
  var Values: string);
begin
{$IFNDEF LOOKUPDLL}
  Values := AAuditRecord.atOther_Info;
  if AAuditRecord.atAudit_Record = nil then
    Exit;

  //Test - add other info flag
  AddOtherInfoFlag(Values);

  with FOwner as TClientObj do
    case AAuditRecord.atAudit_Record_Type of
      tkBegin_Client,
      tkBegin_ClientExtra : BKAuditValues.AddClientAuditValues(AAuditRecord, Self, Values);
      tkBegin_Payee_Detail,
      tkBegin_Payee_Line  : BKAuditValues.AddPayeeAuditValues(AAuditRecord, Self, Values);
      tkBegin_Transaction : BKAuditValues.AddTransactionAuditValues(AAuditRecord, Self, clFields, Values);
      tkBegin_Bank_Account: BKAuditValues.AddBankAccountAuditValues(AAuditRecord, Self, Values);
    else
      Values := Format('%s%sAUDIT RECORD TYPE UNKNOWN',[Values, VALUES_DELIMITER]);
    end;
{$ENDIF}
end;

function TClientAuditManager.NextClientRecordID: integer;
begin
{$IFNDEF LOOKUPDLL}
  with FOwner as TClientObj do
    Result := NextAuditRecordID;
{$ENDIF}
end;

procedure TClientAuditManager.ReadAuditRecord(ARecordType: byte;
  AStream: TIOStream; var ARecord: pointer);
begin
{$IFNDEF LOOKUPDLL}
  case ARecordType of
    tkBegin_Client:
      begin
        ARecord := New_Client_Rec;
        Read_Client_Rec(TClient_Rec(ARecord^), AStream);
      end;
    tkBegin_ClientExtra:
      begin
        ARecord := New_ClientExtra_Rec;
        Read_ClientExtra_Rec(TClientExtra_Rec(ARecord^), AStream);
      end;
    tkBegin_Payee_Detail:
      begin
        ARecord := New_Payee_Detail_Rec;
        Read_Payee_Detail_Rec(TPayee_Detail_Rec(ARecord^), AStream);
      end;
    tkBegin_Payee_Line:
      begin
        ARecord := New_Payee_Line_Rec;
        Read_Payee_Line_Rec(TPayee_Line_Rec(ARecord^), AStream);
      end;
    tkBegin_Bank_Account:
      begin
        ARecord := New_Bank_Account_Rec;
        Read_Bank_Account_Rec(TBank_Account_Rec(ARecord^), AStream);
      end;
    tkBegin_Transaction:
      begin
        ARecord := New_Transaction_Rec;
        Read_Transaction_Rec(TTransaction_Rec(ARecord^), AStream);
      end;
  end;
{$ENDIF}
end;

procedure TClientAuditManager.WriteAuditRecord(ARecordType: byte;
  ARecord: pointer; AStream: TIOStream);
begin
{$IFNDEF LOOKUPDLL}
  case ARecordType of
    tkBegin_Client      : Write_Client_Rec(TClient_Rec(ARecord^), AStream);
    tkBegin_ClientExtra : Write_ClientExtra_Rec(TClientExtra_Rec(ARecord^), AStream);
    tkBegin_Payee_Detail: Write_Payee_Detail_Rec(TPayee_Detail_Rec(ARecord^), AStream);
    tkBegin_Payee_Line  : Write_Payee_Line_Rec(TPayee_Line_Rec(ARecord^), AStream);
    tkBegin_Bank_Account: Write_Bank_Account_Rec(TBank_Account_Rec(ARecord^), AStream);
    tkBegin_Transaction : Write_Transaction_Rec(TTransaction_Rec(ARecord^), AStream);
  end;
{$ENDIF}
end;

{ TAuditTable }

procedure TAuditTable.AddAuditRec(AAuditInfo: TAuditInfo);
var
  AuditRec: pAudit_Trail_Rec;
  i: integer;
begin
{$IFNDEF LOOKUPDLL}
  AuditRec := SYATIO.New_Audit_Trail_Rec;
  AuditRec.atAudit_ID := FAuditRecords.ItemCount + 1;
  AuditRec.atTransaction_Type := AAuditInfo.AuditType;
  AuditRec.atAudit_Action := AAuditInfo.AuditAction;
  AuditRec.atDate_Time := Now;
  AuditRec.atRecord_ID := AAuditInfo.AuditRecordID;
  AuditRec.atUser_Code := AAuditInfo.AuditUser;
  AuditRec.atParent_ID := AAuditInfo.AuditParentID;
  AuditRec.atAudit_Record_Type := AAuditInfo.AuditRecordType;
  for i := Low(AAuditInfo.AuditChangedFields) to High(AAuditInfo.AuditChangedFields) do
    AuditRec.atChanged_Fields[i] := AAuditInfo.AuditChangedFields[i];
  AuditRec.atOther_Info := AAuditInfo.AuditOtherInfo;
  if AuditRec.atAudit_Action = aaDelete then
    AuditRec.atAudit_Record := nil
  else if Assigned(AAuditInfo.AuditRecord) then
    FAuditManager.CopyAuditRecord(AuditRec.atAudit_Record_Type, AAuditInfo.AuditRecord, AuditRec.atAudit_Record);
  FAuditRecords.Insert(AuditRec);
{$ENDIF}
end;

constructor TAuditTable.Create(AAuditManager: TAuditManager);
begin
  inherited Create;
  FAuditManager := AAuditManager;
  FAuditRecords := TAuditCollection.Create;
end;

destructor TAuditTable.Destroy;
var
  i: integer;
begin
  //Dispose audit records
  for i := 0 to Pred(FAuditRecords.ItemCount) do
    Dispose(FAuditRecords.Audit_At(i).atAudit_Record);

  FAuditRecords.FreeAll;
  FAuditRecords.SetLimit(0);
  FAuditRecords.Free;
  inherited;
end;

procedure TAuditTable.LoadFromFile(AFileName: TFileName);
var
  InFile: TIOStream;
  Token: byte;
begin
{$IFNDEF LOOKUPDLL}
  if not FileExists(AFileName) then Exit;

  InFile := TIOStream.Create;
  try
    InFile.LoadFromFile(AFileName);
    InFile.Position := soFromBeginning;
    Token := InFile.ReadToken;
    Assert(tkBeginSystem_Audit_Trail_List = Token, 'Start Audit list token wrong');
    LoadFromStream(InFile);
  finally
    InFile.Free;
  end;
{$ENDIF}
end;

procedure TAuditTable.LoadFromStream(var S: TIOStream);
const
  THIS_METHOD_NAME = 'TAuditObj.LoadFromStream';
var
  Token: Byte;
  pAR: pAudit_Trail_Rec;
  msg: string;
begin
  Token := S.ReadToken;
  while (Token <> tkEndSection) do begin
    case Token of
      tkBegin_Audit_Trail:
          begin
            pAR := New_Audit_Trail_Rec;
            SYATIO.Read_Audit_Trail_Rec(pAR^, S);
            //Read record
            if pAR^.atAudit_Action <> aaDelete then
              FAuditManager.ReadAuditRecord(pAR^.atAudit_Record_Type, S, pAR^.atAudit_Record);
            FAuditRecords.Insert(pAR);
          end
    else
      //Should never happen
      Msg := Format('%s : Unknown Token %d', [THIS_METHOD_NAME, Token]);
      raise ETokenException.CreateFmt('%s - %s', [UNIT_NAME, Msg]);
    end;
    Token := S.ReadToken;
  end;
end;

procedure TAuditTable.SaveToFile(AFileName: TFileName);
var
  OutFile: TIOStream;
begin
  OutFile := TIOStream.Create;
  try
    OutFile.Position := soFromBeginning;
    SaveToStream(OutFile);
    OutFile.SaveToFile(AFileName);
  finally
    OutFile.Free;
  end;
end;

procedure TAuditTable.SaveToStream(var s: TIOStream);
var
  i: Integer;
  AuditRec: TAudit_Trail_Rec;
begin
  S.WriteToken(tkBeginSystem_Audit_Trail_List);
  for i := FAuditRecords.First to FAuditRecords.Last do begin
    AuditRec := FAuditRecords.Audit_At(i);
    SYATIO.Write_Audit_Trail_Rec(AuditRec, S);
    //Write record
    if (AuditRec.atAudit_Action <> aaDelete) then begin
      if not Assigned(AuditRec.atAudit_Record) then
        raise ECorruptData.CreateFmt('%s - %s', [UNIT_NAME, 'Audit record not assigned.']);
      FAuditManager.WriteAuditRecord(AuditRec.atAudit_Record_Type, AuditRec.atAudit_Record, S);
    end;
  end;
  S.WriteToken( tkEndSection );
end;

procedure TAuditTable.SetAuditStrings(Index: integer; Strings: TStrings);
var
  AuditRec: TAudit_Trail_Rec;
  Values: string;
begin
  AuditRec := AuditRecords.Audit_At(Index);

  Strings.Text := '';
  Strings.Add(FAuditManager.AuditTypeToStr(AuditRec.atTransaction_Type));
  Strings.Add(IntToStr(AuditRec.atParent_ID));
  Strings.Add(IntToStr(AuditRec.atRecord_ID));
  Strings.Add(aaNames[AuditRec.atAudit_Action]);
  Strings.Add(AuditRec.atUser_Code);
  Strings.Add(FormatDateTime('dd/MM/yyyy hh:mm:ss', AuditRec.atDate_Time));

  FAuditManager.GetValues(AuditRec, Values);
  Strings.Add(Values);
end;

{ TAuditRecords }

function TAuditCollection.Audit_At(Index: Integer): TAudit_Trail_Rec;
begin
  Result := pAudit_Trail_Rec(At(Index))^;
end;

function TAuditCollection.Compare(Item1, Item2: Pointer): Integer;
begin
  Result := TAudit_Trail_Rec(Item1^).atAudit_ID - TAudit_Trail_Rec(Item2^).atAudit_ID;
end;

procedure TAuditCollection.FreeItem(Item: Pointer);
begin
  Dispose(pAudit_Trail_Rec(Item));
//  SYATIO.Free_Audit_Trail_Rec_Dynamic_Fields( pAudit_Trail_Rec( Item)^);
//  SafeFreeMem( Item, Audit_Trail_Rec_Size );
end;

initialization
  _SystemAuditMgr := nil;
finalization
  if Assigned(_SystemAuditMgr) then
    FreeAndNil(_SystemAuditMgr);
end.
