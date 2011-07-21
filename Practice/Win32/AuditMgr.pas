unit AuditMgr;

interface

uses
  Windows, SysUtils, Classes, IOStream, SYAuditUtils, stTree,
  SYDEFS, BKDEFS, MCDEFS,
  MoneyDef, ECollect, bkConst;

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
  atClientBankAccounts            = 10; //Client starts here
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
  atCustomHeadings                = 28;
  atBankLinkNotes                 = 29;
  atBankLinkNotesOnline           = 30;
  atBankLinkBooks                 = 31;
  atExchangeRates                 = 32; atMax = 32;
  atAll = 254;

  //Audit actions
  aaNone   = 0;  aaMin = 0;
  aaAdd    = 1;
  aaChange = 2;
  aaDelete = 3;  aaMax = 3;

  //Audit action strings
  aaNames : array[ aaMin..aaMax ] of string = ('Action', 'Add', 'Change', 'Delete');

  SystemAuditTypes = [atPracticeSetup..atAttachBankAccounts, atAll];
  TransactionAuditTypes = [atHistoricalentries..atDeliveredTransactions];
  ExchangeRateAuditTypes = [atExchangeRates];

  dbSystem = 0;
  dbClient = 1;
  dbExchangeRates = 2;

  OTHER_INFO_FLAG = '*';
  VALUES_DELIMITER = '¦'; //non-keyboard character
  USER_BOOKS = 'Books';
  USER_BOOKS_SECURE = 'Books Secure';
  USER_NOTES_ONLINE = 'Notes Online';

type
  //This is defined in MONEYDEF because all the IO units use MONEYDEF.
  TChanged_Fields_Array = MoneyDef.TChanged_Fields_Array;

  TAudit_Trail_Rec = SYDEFS.tAudit_Trail_Rec;
  TAudit_Trail_Rec_Helper = record helper for TAudit_Trail_Rec
  public
    //Audit datetimes are stored as UTC, so they need to be converted back to
    //local time for display.
    function AuditDateTimeAsLocalDateTime: TDateTime;
  end;

  TAuditType = atMin..atMax;

  PAuditInfo = ^TAuditInfo;
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
    function Audit_Pointer_At(Index : longint) : pAudit_Trail_Rec;
    function Compare(Item1,Item2 : Pointer): Integer; override;
    function FindAuditID(AAuditID: integer): pAudit_Trail_Rec;
  end;

  PScopeInfo = ^TScopeInfo;
  TScopeInfo = record
    AuditType: TAuditType;
    AuditRecordID: integer;
    AuditAction: byte;
    OtherInfo: string
  end;

  TAuditTypeInfo = record
    AyditType: TAuditType;
    TableID: byte;
  end;

  TCountry = whNewZealand..whUK;

  TAuditManager = class(TObject)
  private
    FAuditScope: TList;
    FCountry: TCountry;
    function AuditTypeToTableID(AAuditType: TAuditType): byte;
    function FindScopeInfo(AScopeInfo: PScopeInfo): integer;
    procedure AddScope(AAuditType: TAuditType; AAuditRecordID: integer;
                       AAuditAction: byte; AOtherInfo: string);
    procedure SetCountry(const Value: TCountry);
  public
    constructor Create;
    destructor Destroy; override;
    function AuditTypeToStr(AAuditType: Byte): string;
    function AuditTypeToDBStr(AAuditType: TAuditType): string;
    function AuditTypeToTableStr(AAuditType: TAuditType): string;
    function DBFromAuditType(AAuditType: TAuditType): byte;
    function CurrentUserCode: string;
    function NextAuditRecordID: integer; virtual; abstract;
    function GetParentRecordID(ARecordType: byte; ARecordID: integer): integer; virtual; abstract;
    procedure AddAuditValue(AFieldName: string; AValue: variant; var AAuditValue: string); virtual;
    procedure DoAudit; virtual; abstract;
    procedure FlagAudit(AAuditType: TAuditType; AAuditRecordID: integer = -1;
                        AAuditAction: byte = aaNone; AOtherInfo: string = ''); virtual; abstract;
    procedure WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream); virtual; abstract;
    procedure ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer); virtual; abstract;
    procedure GetValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string); virtual; abstract;
    procedure CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer); virtual; abstract;
    property AuditScope: TList read FAuditScope;
    property Country: TCountry read FCountry write SetCountry;
  end;

  TSystemAuditManager = class(TAuditManager)
  private
  public
    function NextAuditRecordID: integer; override;
    function GetParentRecordID(ARecordType: byte; ARecordID: integer): integer; override;
    function BankAccountFromLRN(ALRN: integer): string;
    function ClientCodeFromLRN(ALRN: integer): string;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType; AAuditRecordID: integer = -1;
                        AAuditAction: byte = aaNone; AOtherInfo: string = ''); override;
    procedure GetValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string); override;
    procedure ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer); override;
    procedure WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream); override;
    procedure CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer); override;
  end;

  TClientAuditManager = class(TAuditManager)
  private
    FOwner: TObject;
    FProvisionalAccountAttached: boolean;
    FUpgradingClientFile: Boolean;
    procedure SetProvisionalAccountAttached(const Value: boolean);
  public
    constructor Create(Owner: TObject);
    function NextAuditRecordID: integer; override;
    function GetParentRecordID(ARecordType: byte; ARecordID: integer): integer; override;
    function GetTransactionAuditType(ABankAccountSource: byte; ABankAccountType: byte): TAuditType;
    function GetBankAccountAuditType(ABankAccountType: byte): TAuditType;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType; AAuditRecordID: integer = -1;
                        AAuditAction: byte = aaNone; AOtherInfo: string = ''); override;
    procedure GetValues(const AAuditRecord: TAudit_Trail_Rec; var Values: string); override;
    procedure ReadAuditRecord(ARecordType: byte; AStream: TIOStream; var ARecord: pointer); override;
    procedure WriteAuditRecord(ARecordType: byte; ARecord: pointer; AStream: TIOStream); override;
    procedure CopyAuditRecord(const ARecordType: byte; P1: Pointer; var P2: Pointer); override;
    property ProvisionalAccountAttached: boolean read FProvisionalAccountAttached write SetProvisionalAccountAttached;
  end;

  TExchangeRateAuditManager = class(TAuditManager)
  private
    FOwner: TObject;
  public
    constructor Create(Owner: TObject);
    function NextAuditRecordID: integer; override;
    function GetParentRecordID(ARecordType: byte; ARecordID: integer): integer; override;
    procedure DoAudit; override;
    procedure FlagAudit(AAuditType: TAuditType; AAuditRecordID: integer = -1;
                        AAuditAction: byte = aaNone; AOtherInfo: string = ''); override;
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
//    procedure SetAuditStrings(Index: integer; Strings: TStrings);
    property AuditRecords: TAuditCollection read FAuditRecords;
  end;

  //System audit manager is a singleton because there is only one system DB
  function SystemAuditMgr: TSystemAuditManager;

  function GetAccountingSystemName(AAccountingSystem: byte): string;
  function GetUserCode(AUserLRN: integer): string;
  function GetGroupName(AGroupLRN: integer): string;
  function GetClientFileType(AClientTypeLRN: integer): string;

  procedure SetProvisionalInfo(ATxnLRN: integer; var AUserCode: shortstring; var ADateTime: TDateTime);

implementation

{$IFDEF LOOKUPDLL}
uses
  TOKENS, BKDbExcept,
  SYAUDIT, SYATIO, SYUSIO, SYFDIO, SYDLIO, SYSBIO, SYAMIO, SYCFIO, SYSMIO,
  BKAUDIT, BKPDIO, BKCLIO, BKCEIO, BKBAIO, BKCHIO, BKTXIO, BKMDIO, BKMLIO,
  BKPLIO, BKHDIO, BKDSIO,
  MCAUDIT, MCEHIO, MCERIO;
{$ELSE}
uses
  Globals, SysObj32, ClObj32, ExchangeRateList, MoneyUtils, SystemMemorisationList,
  BKAuditValues, SYAuditValues, MCAuditValues,
  bkdateutils, TOKENS,  BKDbExcept, CountryUtils,
  SYAUDIT, SYATIO, SYUSIO, SYFDIO, SYDLIO, SYSBIO, SYAMIO, SYCFIO, SYSMIO,
  BKAUDIT, BKPDIO, BKCLIO, BKCEIO, BKBAIO, BKCHIO, BKTXIO, BKMDIO, BKMLIO,
  BKPLIO, BKHDIO, BKDSIO,
  MCAUDIT, MCEHIO, MCERIO;

const
  //Audit type strings
  atNames : array[ atMin..atMax ] of string =
    ('Practice Setup',
     'Practice VAT Defaults',
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
     'VAT Setup',
     'Historical entries',
     'Provisional entries',
     'Manual entries',
     'Delivered transactions',
     'Automatic coding',
     'Cash journals',
     'Accrual journals',
     'Stock/Adjustment journals',
     'Year End Adjustment journals',
     'VAT journals',
     'Opening balances',
     'Unpresented Items',
     'Division & Sub-Group Headings',
     'BankLink Notes',
     'BankLink Notes Online',
     'BankLink Books',
     'Exchange Rates');

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

     (tkBegin_Bank_Account, dbClient),        //Client Bank Accounts
     (tkBegin_Account, dbClient),             //Chart of Accounts
     (tkBegin_Payee_Detail, dbClient),        //Payees
     (tkBegin_Client, dbClient),              //Client Files
     (tkBegin_Bank_Account, dbClient),        //Memorisations
     (tkBegin_Client, dbClient),              //GST/VAT Setup
     (tkBegin_Bank_Account, dbClient),        //Historical entries
     (tkBegin_Bank_Account, dbClient),        //Provisional entries
     (tkBegin_Bank_Account, dbClient),        //Manual entries
     (tkBegin_Bank_Account, dbClient),        //Delivered transactions
     (tkBegin_Bank_Account, dbClient),        //Automatic coding
     (tkBegin_Bank_Account, dbClient),        //Cash journals
     (tkBegin_Bank_Account, dbClient),        //Accrual journals
     (tkBegin_Bank_Account, dbClient),        //Stock/Adjustment journals
     (tkBegin_Bank_Account, dbClient),        //Year End Adjustment journals
     (tkBegin_Bank_Account, dbClient),        //GST/VAT journals
     (tkBegin_Bank_Account, dbClient),        //Opening balances
     (tkBegin_Bank_Account, dbClient),        //Unpresented Items
     (tkBegin_Custom_Heading, dbClient),      //Division & Sub-Group headings
     (tkBegin_Client, dbClient),         //BankLink Notes
     (tkBegin_Client, dbClient),         //BankLink Notes Online
     (tkBegin_Client, dbClient),         //BankLink Books

     (tkBegin_Exchange_Rates_Header, dbExchangeRates)); //Exchange Rate Source
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

{ TAuditManager }

procedure TAuditManager.AddAuditValue(AFieldName: string;
  AValue: variant; var AAuditValue: string);
var
  Value: string;
begin
{$IFNDEF LOOKUPDLL}
  if TVarData(AValue).VType = varByte then
    Value := IntToStr(AValue)
  else
    Value := ToString(AValue);
  if (AAuditValue <> '') then
    AAuditValue := AAuditValue + VALUES_DELIMITER;
    //Field names are localised - Tax System, currency name, and currency symbol
    AAuditValue := AAuditValue + Localise(Country, AFieldName) + '=' + Value;
{$ENDIF}
end;

procedure TAuditManager.AddScope(AAuditType: TAuditType; AAuditRecordID: integer;
  AAuditAction: byte; AOtherInfo: string);
var
  ScopeInfo: PScopeInfo;
begin
{$IFNDEF LOOKUPDLL}
  New(ScopeInfo);
  ScopeInfo.AuditType := AAuditType;
  ScopeInfo.AuditRecordID := AAuditRecordID;
  ScopeInfo.AuditAction := AAuditAction;
  ScopeInfo.OtherInfo := AOtherInfo;
  if FindScopeInfo(ScopeInfo) = - 1 then
    FAuditScope.Add(ScopeInfo);
{$ENDIF}    
end;

function TAuditManager.AuditTypeToDBStr(AAuditType: TAuditType): string;
begin
{$IFNDEF LOOKUPDLL}
  Result := '';
  if (AAuditType <= atMax)then
    case atNameTable[AAuditType, 1] of
      dbSystem: Result := 'SY';
      dbClient: Result := 'BK';
      dbExchangeRates: Result := 'MC';      
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
      dbExchangeRates: Result := MCAuditNames.GetAuditTableName(atNameTable[AAuditType, 0]);
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
{$IFDEF BK_UNITTESTINGON}
  Result := 'UNITTEST';
{$ELSE}
  if Assigned(AdminSystem) then
    Result := Globals.CurrUser.Code
  else if Assigned(MyClient) then begin
     if (MyClient.clFields.clDownload_From <> dlAdminSystem) then
       Result := USER_BOOKS_SECURE
     else
       Result := USER_BOOKS;
  end;
{$ENDIF}
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
       (AScopeInfo.AuditRecordID = PScopeInfo(FAuditScope.Items[i]).AuditRecordID) and
       (AScopeInfo.AuditAction = PScopeInfo(FAuditScope.Items[i]).AuditAction) and
       (AScopeInfo.OtherInfo = PScopeInfo(FAuditScope.Items[i]).OtherInfo) then begin
      Result := i;
      Break;
    end;
  end;
end;


procedure TAuditManager.SetCountry(const Value: TCountry);
begin
  FCountry := Value;
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

procedure AddSpecailAuditRec(ARecordType: Byte; AParentID: integer;
  AScopeInfo: PScopeInfo; AAuditTable: TAuditTable; AUser: string);
var
  Auditinfo: TAuditinfo;
begin
  Auditinfo.AuditRecordID := AScopeInfo.AuditRecordID;
  Auditinfo.AuditUser     := AUser;
  Auditinfo.AuditType     := AScopeInfo.AuditType;
  Auditinfo.AuditAction   := AScopeInfo.AuditAction;
  Auditinfo.AuditParentID := AParentID;
  Auditinfo.AuditRecordType := ARecordType;
//  Auditinfo.AuditChangedFields - no values required
  Auditinfo.AuditOtherInfo := AScopeInfo.OtherInfo;
  Auditinfo.AuditRecord := nil;
  AAuditTable.AddAuditRec(Auditinfo);
end;

procedure TSystemAuditManager.DoAudit;
var
  i: integer;
  TableID: byte;
begin
{$IFNDEF LOOKUPDLL}
  //Output the info only audit records first
  for i := 0 to FAuditScope.Count - 1 do begin
    TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
    if (PScopeInfo(FAuditScope.Items[i]).AuditRecordID <> -1) then begin
      //This audits a change to a specific record which may include info
      //that doesn't get audited when the database is saved (i.e no delta
      //record is created).
      AddSpecailAuditRec(TableID,
                         GetParentRecordID(TableID, PScopeInfo(FAuditScope.Items[i]).AuditRecordID),
                         PScopeInfo(FAuditScope.Items[i]),
                         AdminSystem.fAuditTable,
                         CurrentUserCode);
    end;
  end;

  //Now output the changes to the database
  for i := 0 to FAuditScope.Count - 1 do begin
    TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
    if (PScopeInfo(FAuditScope.Items[i]).AuditRecordID = -1) then begin
      case TableID of
        tkBegin_Practice_Details: AdminSystem.DoAudit(@SystemCopy.fdFields, PScopeInfo(FAuditScope.Items[i]).AuditType);
        tkBegin_User: AdminSystem.fdSystem_User_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                             SystemCopy.fdSystem_User_List,
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
                                                             SystemCopy.fSystem_Memorisation_List, 0,
                                                             AdminSystem.fAuditTable);
        tkBegin_Memorisation_Detail: ; //Do nothing - sub list (TSystem_Memorisation_List - TMemorisations_List)
        tkBegin_Memorisation_Line: ;   //Do nothing - sub list (TSystem_Memorisation_List - TMemorisations_List - TMemorisation)
      end;
    end;
  end;
  FAuditScope.Clear;
{$ENDIF}
end;

procedure TSystemAuditManager.FlagAudit(AAuditType: TAuditType;
  AAuditRecordID: integer; AAuditAction: byte; AOtherInfo: string);
begin
  //Restricted auditing to UK
  if (Country <> whUK) then Exit;

  AddScope(AAuditType, AAuditRecordID, AAuditAction, AOtherInfo);
end;

function TSystemAuditManager.GetParentRecordID(ARecordType: byte; ARecordID: integer): integer;
begin
{$IFNDEF LOOKUPDLL}
  Result := -1;
  case ARecordType of
    tkBegin_Practice_Details: Result := -1;
    tkBegin_User,
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
var
  OtherInfo: string;
  AuditInfo: string;
begin
{$IFNDEF LOOKUPDLL}
  OtherInfo := AAuditRecord.atOther_Info;
  if AAuditRecord.atAudit_Record = nil then begin
    //Add deletes
    if (AAuditRecord.atAudit_Action in [aaDelete, aaNone])then begin
      AddOtherInfoFlag(OtherInfo);
      Values := OtherInfo;
    end;
    Exit;
  end;

  AddOtherInfoFlag(OtherInfo);

  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Practice_Details    : AddSystemAuditValues(AAuditRecord, AuditInfo);
    tkBegin_User                : AddUserAuditValues(AAuditRecord, AuditInfo);
    tkBegin_System_Bank_Account : AddSystemBankAccountAuditValues(AAuditRecord, AuditInfo);
    tkBegin_Client_Account_Map  : AddClientAccountMapAuditValues(AAuditRecord, AuditInfo);
    tkBegin_Client_File         : AddClientFileAuditValues(AAuditRecord, AuditInfo);
    tkBegin_System_Memorisation_List,
    tkBegin_Memorisation_Detail,
    tkBegin_Memorisation_Line   : AddMasterMemorisationAuditValues(AAuditRecord, AuditInfo);
  end;

  //Put it together - if there is no audit information then values will be
  //blank and the audit record will not appear on the report. This is because
  //fields that are not audited may have changed.
  if (AuditInfo <> '') then
    if (OtherInfo <> '') then
      Values := Format('%s%s%s',[OtherInfo, VALUES_DELIMITER, AuditInfo])
    else
      Values := AuditInfo;
{$ENDIF}
end;

function TSystemAuditManager.NextAuditRecordID: integer;
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
    tkBegin_Dissection:
      begin
        P2 := New_Dissection_Rec;
        Copy_Dissection_Rec(P1, P2);
      end;
    tkBegin_Account:
      begin
        P2 := New_Account_Rec;
        Copy_Account_Rec(P1, P2);
      end;
    tkBegin_Custom_Heading:
      begin
        P2 := New_Custom_Heading_Rec;
        Copy_Custom_Heading_Rec(P1, P2);
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

constructor TClientAuditManager.Create(Owner: TObject);
begin
  inherited Create;

  FOwner := nil;
  FProvisionalAccountAttached := False;
  FUpgradingClientFile := False;
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
  with FOwner as TClientObj do begin
    //Output the info only audit records first
    for i := 0 to FAuditScope.Count - 1 do begin
      TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
      if (PScopeInfo(FAuditScope.Items[i]).AuditRecordID <> -1) then begin
        //This audits a change to a specific record which may include info
        //that doesn't get audited when the database is saved (i.e no delta
        //record is created).
        AddSpecailAuditRec(TableID,
                           GetParentRecordID(TableID, PScopeInfo(FAuditScope.Items[i]).AuditRecordID),
                           PScopeInfo(FAuditScope.Items[i]),
                           fAuditTable,
                           CurrentUserCode);
      end;
    end;

    //Now output the changes to the database
    for i := 0 to FAuditScope.Count - 1 do begin
      TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
      if (PScopeInfo(FAuditScope.Items[i]).AuditRecordID = -1) then begin
        case TableID of
          tkBegin_Client      : DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType, ClientCopy);
          tkBegin_Payee_Line  :         ;//Done in payee detail
          tkBegin_Payee_Detail: clPayee_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                     ClientCopy.clPayee_List, 0, fAuditTable);
          tkBegin_Transaction :         ;//Done in bank account
          tkBegin_Dissection:           ;//Done in bank account
          tkBegin_Memorisation_Detail:  ;//Done in bank account
          tkBegin_Memorisation_Line:    ;//Done in bank account
          tkBegin_Bank_Account: clBank_Account_List.DoAudit(ClientCopy.clBank_Account_List,
                                                            0, fAuditTable);
          tkBegin_Account: clChart.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                           ClientCopy.clChart,
                                           0, fAuditTable);
          tkBegin_Custom_Heading: clCustom_Headings_List.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                                 ClientCopy.clCustom_Headings_List,
                                                                 0, fAuditTable);
        end;
      end;
    end;
  end;
  FAuditScope.Clear;
{$ENDIF}
end;

procedure TClientAuditManager.FlagAudit(AAuditType: TAuditType; AAuditRecordID: integer;
  AAuditAction: byte; AOtherInfo: string);
begin
  //Restricted auditing to UK
  if (Country <> whUK) then Exit;

  AddScope(AAuditType, AAuditRecordID, AAuditAction, AOtherInfo);
end;

function TClientAuditManager.GetBankAccountAuditType(ABankAccountType: byte): TAuditType;
begin
  Result := atClientBankAccounts;
{$IFNDEF LOOKUPDLL}
  case ABankAccountType of
    btCashJournals       : Result := atCashJournals;
    btAccrualJournals    : Result := atAccrualJournals;
    btGSTJournals        : Result := atGSTJournals;
    btStockBalances,
    btStockJournals      : Result := atStockAdjustmentJournals;
    btOpeningBalances    : Result := atOpeningBalances;
    btYearEndAdjustments : Result := atYearEndAdjustmentJournals;
  end;
{$ENDIF}
end;

function TClientAuditManager.GetParentRecordID(ARecordType: byte;
  ARecordID: integer): integer;
begin
  Result := 0;
end;

function TClientAuditManager.GetTransactionAuditType(ABankAccountSource: byte;
  ABankAccountType: byte): TAuditType;
begin
  Result := atDeliveredTransactions;
{$IFNDEF LOOKUPDLL}
  case ABankAccountSource of
    orBank         : Result := atDeliveredTransactions;
    orGenerated    : Result := atUnpresentedItems;
    orManual       :
       case ABankAccountType of
         btCashJournals      : Result := atCashJournals;
         btAccrualJournals   : Result := atAccrualJournals;
         btGSTJournals       : Result := atGSTJournals;
         btOpeningBalances   : Result := atOpeningBalances;
         btStockBalances,
         btStockJournals     : Result := atStockAdjustmentJournals;
         btYearEndAdjustments: Result := atYearEndAdjustmentJournals;
       end;
    orHistorical   : Result := atHistoricalentries;
    orGeneratedRev : Result := atUnpresentedItems;
    orMDE          : Result := atManualEntries;
    orProvisional  : Result := atProvisionalEntries;
  else
    Result := atDeliveredTransactions;
  end;
{$ENDIF}
end;

procedure TClientAuditManager.GetValues(const AAuditRecord: TAudit_Trail_Rec;
  var Values: string);
var
  OtherInfo: string;
  AuditInfo: string;
begin
{$IFNDEF LOOKUPDLL}
  OtherInfo := AAuditRecord.atOther_Info;
  if AAuditRecord.atAudit_Record = nil then begin
    //Add deletes
    if (AAuditRecord.atAudit_Action in [aaDelete, aaNone])then
      Values := OtherInfo;
    Exit;
  end;

  AddOtherInfoFlag(OtherInfo);

  with FOwner as TClientObj do
    case AAuditRecord.atAudit_Record_Type of
      tkBegin_Client,
      tkBegin_ClientExtra : BKAuditValues.AddClientAuditValues(AAuditRecord, Self, AuditInfo);
      tkBegin_Payee_Detail,
      tkBegin_Payee_Line  : BKAuditValues.AddPayeeAuditValues(AAuditRecord, Self, AuditInfo);
      tkBegin_Transaction : BKAuditValues.AddTransactionAuditValues(AAuditRecord, Self, clFields, AuditInfo);
      tkBegin_Dissection  : BKAuditValues.AddDissectionAuditValues(AAuditRecord, Self, clFields, AuditInfo);
      tkBegin_Bank_Account: BKAuditValues.AddBankAccountAuditValues(AAuditRecord, Self, AuditInfo);
      tkBegin_Account     : BKAuditValues.AddAccountAuditValues(AAuditRecord, Self, clCustom_Headings_List, AuditInfo);
      tkBegin_Custom_Heading: BKAuditValues.AddCustomHeadingValues(AAuditRecord, Self, AuditInfo);
      tkBegin_Memorisation_Line,
      tkBegin_Memorisation_Detail: BKAuditValues.AddMemorisationValues(AAuditRecord, Self, AuditInfo);
    else
      AuditInfo := Format('%s%sAUDIT RECORD TYPE UNKNOWN',[Values, VALUES_DELIMITER]);
    end;

  //Put it together - if there is no audit information then values will be
  //blank and the audit record will not appear on the report. This is because
  //fields that are not audited may have changed.
  if (AuditInfo <> '') then
    if (OtherInfo <> '') then
      Values := Format('%s%s%s',[OtherInfo, VALUES_DELIMITER, AuditInfo])
    else
      Values := AuditInfo;
{$ENDIF}
end;

function TClientAuditManager.NextAuditRecordID: integer;
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
    tkBegin_Dissection:
      begin
        ARecord := New_Dissection_Rec;
        Read_Dissection_Rec(TDissection_Rec(ARecord^), AStream);
      end;
    tkBegin_Account:
      begin
        ARecord := New_Account_Rec;
        Read_Account_Rec(TAccount_Rec(ARecord^), AStream);
      end;
    tkBegin_Custom_Heading:
      begin
        ARecord := New_Custom_Heading_Rec;
        Read_Custom_Heading_Rec(TCustom_Heading_Rec(ARecord^), AStream);
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

procedure TClientAuditManager.SetProvisionalAccountAttached(
  const Value: boolean);
begin
  FProvisionalAccountAttached := Value;
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
    tkBegin_Dissection  : Write_Dissection_Rec(TDissection_Rec(ARecord^), AStream);
    tkBegin_Account     : Write_Account_Rec(TAccount_Rec(ARecord^), AStream);
    tkBegin_Custom_Heading: Write_Custom_Heading_Rec(TCustom_Heading_Rec(ARecord^), AStream);
    tkBegin_Memorisation_Detail: Write_Memorisation_Detail_Rec(TMemorisation_Detail_Rec(ARecord^), AStream);
    tkBegin_Memorisation_Line: Write_Memorisation_Line_Rec(TMemorisation_Line_Rec(ARecord^), AStream);    
  end;
{$ENDIF}
end;

{ TAuditTable }

procedure TAuditTable.AddAuditRec(AAuditInfo: TAuditInfo);
var
  AuditRec: pAudit_Trail_Rec;
  i: integer;
  SystemTime: TSystemTime;
begin
{$IFNDEF LOOKUPDLL}
  AuditRec := SYATIO.New_Audit_Trail_Rec;
  AuditRec.atAudit_ID := FAuditRecords.ItemCount + 1;
  AuditRec.atTransaction_Type := AAuditInfo.AuditType;
  AuditRec.atAudit_Action := AAuditInfo.AuditAction;

  //Save datetime as UTC
  GetSystemTime(SystemTime);
  AuditRec.atDate_Time := SystemTimeToDateTime(SystemTime);

  AuditRec.atRecord_ID := AAuditInfo.AuditRecordID;
  AuditRec.atUser_Code := AAuditInfo.AuditUser;
  AuditRec.atParent_ID := AAuditInfo.AuditParentID;
  AuditRec.atAudit_Record_Type := AAuditInfo.AuditRecordType;
  for i := Low(AAuditInfo.AuditChangedFields) to High(AAuditInfo.AuditChangedFields) do
    AuditRec.atChanged_Fields[i] := AAuditInfo.AuditChangedFields[i];
  AuditRec.atOther_Info := AAuditInfo.AuditOtherInfo;
  if (AuditRec.atAudit_Action in [aaDelete, aaNone]) then
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
            if not (pAR^.atAudit_Action in [aaDelete, aaNone]) then
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
    if not (AuditRec.atAudit_Action in [aaDelete, aaNone]) then begin
      if not Assigned(AuditRec.atAudit_Record) then
        raise ECorruptData.CreateFmt('%s - %s', [UNIT_NAME, 'Audit record not assigned.']);
      FAuditManager.WriteAuditRecord(AuditRec.atAudit_Record_Type, AuditRec.atAudit_Record, S);
    end;
  end;
  S.WriteToken( tkEndSection );
end;

//procedure TAuditTable.SetAuditStrings(Index: integer; Strings: TStrings);
////Used to output audit records to a csv file
//var
//  AuditRec: TAudit_Trail_Rec;
//  Values: string;
//begin
//
//  AuditRec := AuditRecords.Audit_At(Index);
//
//  Strings.Text := '';
//  Strings.Add(FAuditManager.AuditTypeToStr(AuditRec.atTransaction_Type));
//  Strings.Add(IntToStr(AuditRec.atParent_ID));
//  Strings.Add(IntToStr(AuditRec.atRecord_ID));
//  Strings.Add(aaNames[AuditRec.atAudit_Action]);
//  Strings.Add(AuditRec.atUser_Code);
//  Strings.Add(FormatDateTime('dd/MM/yyyy hh:mm:ss', AuditRec.AuditDateTimeAsLocalDateTime));
//  FAuditManager.GetValues(AuditRec, Values);
//  Strings.Add(Values);
//end;

{ TAuditRecords }

function TAuditCollection.Audit_At(Index: Integer): TAudit_Trail_Rec;
begin
  Result := pAudit_Trail_Rec(At(Index))^;
end;

function TAuditCollection.Audit_Pointer_At(Index: Integer): pAudit_Trail_Rec;
begin
  Result := pAudit_Trail_Rec(At(Index));
end;

function TAuditCollection.Compare(Item1, Item2: Pointer): Integer;
begin
  Result := TAudit_Trail_Rec(Item1^).atAudit_ID - TAudit_Trail_Rec(Item2^).atAudit_ID;
end;

function TAuditCollection.FindAuditID(AAuditID: integer): pAudit_Trail_Rec;
var
  L, H, I, C: Integer;
  AuditRec: pAudit_Trail_Rec;
begin
  Result := nil;
  L := 0;
  H := ItemCount - 1;

  //No items in list
  if L > H then Exit;

  repeat
    i := (L + H) shr 1;
    AuditRec := Audit_Pointer_At(i);
    if AAuditID < AuditRec^.atRecord_ID then
      C := -1
    else if AAuditID = AuditRec^.atRecord_ID then begin
      Result := AuditRec;
      C := 0
    end else
      C := 1;
    if C > 0 then
      L := i + 1
    else
      H := i - 1;
  until (C = 0) or (L > H);
end;

procedure TAuditCollection.FreeItem(Item: Pointer);
begin
  Dispose(pAudit_Trail_Rec(Item));
end;

{ TAudit_Trail_Rec_Helper }

function TAudit_Trail_Rec_Helper.AuditDateTimeAsLocalDateTime: TDateTime;
var
  TimeZoneInf: _TIME_ZONE_INFORMATION;
  UTCTime, LocalDateTime: TSystemTime;
begin
  if GetTimeZoneInformation(TimeZoneInf) < $FFFFFFFF then begin
    DatetimetoSystemTime(atDate_Time, UTCTime);
    if SystemTimeToTzSpecificLocalTime(@TimeZoneInf, UTCTime, LocalDateTime) then begin
      Result := SystemTimeToDateTime(LocalDateTime);
    end else
      Result := atDate_Time;
  end else
    Result := atDate_Time;
end;

{ TExchangeRateAuditManager }

procedure TExchangeRateAuditManager.CopyAuditRecord(const ARecordType: byte;
  P1: Pointer; var P2: Pointer);
begin
{$IFNDEF LOOKUPDLL}
  case ARecordType of
    tkBegin_Exchange_Rates_Header :
      begin
        P2 := New_Exchange_Rates_Header_Rec;
        Copy_Exchange_Rates_Header_Rec(P1, P2);
      end;
    tkBegin_Exchange_Rate :
      begin
        P2 := New_Exchange_Rate_Rec;
        Copy_Exchange_Rate_Rec(P1, P2);
      end;
  end;
{$ENDIF}
end;

constructor TExchangeRateAuditManager.Create(Owner: TObject);
begin
  inherited Create;
{$IFNDEF LOOKUPDLL}
  FOwner := nil;
  if Owner is TExchangeRateList then
    FOwner := Owner;
{$ENDIF}
end;

procedure TExchangeRateAuditManager.DoAudit;
{$IFNDEF LOOKUPDLL}
var
  i: integer;
  TableID: byte;
  ExchangeRateList: TExchangeRateList;
{$ENDIF}
begin
{$IFNDEF LOOKUPDLL}
  if Assigned(FOwner) then begin
    ExchangeRateList := TExchangeRateList(FOwner);
    //Output the info only audit records first
    for i := 0 to FAuditScope.Count - 1 do begin
      TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
      if (PScopeInfo(FAuditScope.Items[i]).AuditRecordID <> -1) then begin
        //This audits a change to a specific record which may include info
        //that doesn't get audited when the database is saved (i.e no delta
        //record is created).
        AddSpecailAuditRec(TableID,
                           GetParentRecordID(TableID, PScopeInfo(FAuditScope.Items[i]).AuditRecordID),
                           PScopeInfo(FAuditScope.Items[i]),
                           ExchangeRateList.AuditTable,
                           CurrentUserCode);
      end;
    end;
    //Now output the changes to the database
    for i := 0 to FAuditScope.Count - 1 do begin
      TableID :=  AuditTypeToTableID(PScopeInfo(FAuditScope.Items[i]).AuditType);
      if (PScopeInfo(FAuditScope.Items[i]).AuditRecordID = -1) then begin
        case TableID of
          tkBegin_Exchange_Rate,
          tkBegin_Exchange_Rates_Header: ExchangeRateList.DoAudit(PScopeInfo(FAuditScope.Items[i]).AuditType,
                                                                  ExchangeRateList.ExchangeRateListCopy);
        end;
      end;
    end;
    FAuditScope.Clear;
  end;
{$ENDIF}
end;

procedure TExchangeRateAuditManager.FlagAudit(AAuditType: TAuditType;
  AAuditRecordID: integer; AAuditAction: byte; AOtherInfo: string);
begin
{$IFNDEF LOOKUPDLL}
  AddScope(AAuditType, AAuditRecordID, AAuditAction, AOtherInfo);
{$ENDIF}
end;

function TExchangeRateAuditManager.GetParentRecordID(ARecordType: byte;
  ARecordID: integer): integer;
begin
  Result := 0;
end;

procedure TExchangeRateAuditManager.GetValues(
  const AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  OtherInfo: string;
  AuditInfo: string;
begin
{$IFNDEF LOOKUPDLL}
  OtherInfo := AAuditRecord.atOther_Info;
  if AAuditRecord.atAudit_Record = nil then begin
    //Add deletes
    if (AAuditRecord.atAudit_Action in [aaDelete, aaNone])then begin
      AddOtherInfoFlag(OtherInfo);
      Values := OtherInfo;
    end;
    Exit;
  end;

  AddOtherInfoFlag(OtherInfo);

  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Exchange_Rates_Header : AddExchangeSourceAuditValues(AAuditRecord, Self, AuditInfo);
    tkBegin_Exchange_Rate         : AddExchangeRateAuditValues(AAuditRecord, Self,
                                                               AdminSystem.fCurrencyList,
                                                               AuditInfo);
  end;

  //Put it together - if there is no audit information then values will be
  //blank and the audit record will not appear on the report. This is because
  //fields that are not audited may have changed.
  if (AuditInfo <> '') then
    if (OtherInfo <> '') then
      Values := Format('%s%s%s',[OtherInfo, VALUES_DELIMITER, AuditInfo])
    else
      Values := AuditInfo;
{$ENDIF}
end;

function TExchangeRateAuditManager.NextAuditRecordID: integer;
begin
{$IFNDEF LOOKUPDLL}
  with FOwner as TExchangeRateList do
    Result := NextAuditRecordID;
{$ENDIF}    
end;

procedure TExchangeRateAuditManager.ReadAuditRecord(ARecordType: byte;
  AStream: TIOStream; var ARecord: pointer);
begin
{$IFNDEF LOOKUPDLL}
  case ARecordType of
    tkBegin_Exchange_Rates_Header:
      begin
        ARecord := New_Exchange_Rates_Header_Rec;
        Read_Exchange_Rates_Header_Rec(TExchange_Rates_Header_Rec(ARecord^), AStream);
      end;
    tkBegin_Exchange_Rate:
      begin
        ARecord := New_Exchange_Rate_Rec;
        Read_Exchange_Rate_Rec(TExchange_Rate_Rec(ARecord^), AStream);
      end;
  end;
{$ENDIF}
end;

procedure TExchangeRateAuditManager.WriteAuditRecord(ARecordType: byte;
  ARecord: pointer; AStream: TIOStream);
begin
{$IFNDEF LOOKUPDLL}
  case ARecordType of
    tkBegin_Exchange_Rates_Header: Write_Exchange_Rates_Header_Rec(TExchange_Rates_Header_Rec(ARecord^), AStream);
    tkBegin_Exchange_Rate        : Write_Exchange_Rate_Rec(TExchange_Rate_Rec(ARecord^), AStream);
  end;
{$ENDIF}
end;

initialization
  _SystemAuditMgr := nil;
finalization
  if Assigned(_SystemAuditMgr) then
    FreeAndNil(_SystemAuditMgr);
end.
