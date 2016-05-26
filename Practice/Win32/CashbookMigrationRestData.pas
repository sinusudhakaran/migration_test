unit CashbookMigrationRestData;

interface

uses
  Windows,
  SysUtils,
  Classes,
  ecollect,
  uLkJSON,
  contnrs;

const
  UPLOAD_RESP_ERROR = -1;
  UPLOAD_RESP_UKNOWN = 0;
  UPLOAD_RESP_SUCESS = 1;
  UPLOAD_RESP_DUPLICATE = 2;
  UPLOAD_RESP_CORUPT = 3;

  AT_COSTOFSALES = 'cost_of_sales';
  AT_EXPENSE = 'expense';
  AT_OTHEREXPENSE = 'other_expense';
  AT_ASSET = 'asset';
  AT_INCOME = 'income';
  AT_OTHERINCOME = 'other_income';
  AT_LIABILITY = 'liability';
  AT_EQUITY = 'equity';
  AT_UNCATEGORISED = 'uncategorised';

  ValidPLCodes : Array [1..9] of String[3] = ('CAP', 'EXP', 'FRE', 'GNR', 'GST', 'INP', 'ITS', 'NTR','NA');

type
  TLicenceType = (ltCashbook, ltPracticeLedger);
  //----------------------------------------------------------------------------
  TSelectedData = record
    FirmId : string;
    Bankfeeds : boolean;
    ChartOfAccount : boolean;
    ChartOfAccountBalances : boolean;
    NonTransferedTransactions : boolean;
    DoMoveRatherThanCopy : Boolean;
  end;

  //----------------------------------------------------------------------------
  TListDestroy = class(TList)
  protected
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  end;

  //----------------------------------------------------------------------------
  TFirm = class
  private
    FID: string;
    FName: string;
    FRegion : string; // AU or NZ
    FEligibleLicense : string; // can be comma separated like CB, PL
  public
    procedure Read(const aJson: TlkJSONobject);

    property  ID: string read fID write fID;
    property  Name: string read fName write fName;
    property Region : string read FRegion write FRegion;
    property EligibleLicense : string read FEligibleLicense write FEligibleLicense;
  end;

  //----------------------------------------------------------------------------
  TFirms = class(TListDestroy)
  public
    function  GetItem(const aIndex: integer): TFirm; overload;
    function GetItem(const aFirmID: string): TFirm;overload;
    property  Items[const aIndex: integer]: TFirm read GetItem; default;

    function IsValidJSON(aJSONObject : TlkJSONobject):Boolean;
    procedure Read(const aJson: TlkJSONlist);
  end;

  //----------------------------------------------------------------------------
  TLineData = class(TCollectionItem)
  private
    fAccountNumber : string;
    fAmount : integer;
    fDescription : string;
    fReference : string;
    fTaxRate : string;
    fTaxAmount : integer;
    fIsCredit : boolean;
    fQuantity: comp;
    fPayeeNumber: integer;
    fJobCode: string;
  public
    procedure Write(const aJson: TlkJSONobject;IsDirectAPI:Boolean=False);

    property AccountNumber : string read fAccountNumber write fAccountNumber;
    property Amount : integer read fAmount write fAmount;

    property Description : string read fDescription write fDescription;
    property Reference : string read fReference write fReference;
    property TaxRate : string read fTaxRate write fTaxRate;
    property TaxAmount : integer read fTaxAmount write fTaxAmount;

    property IsCredit : boolean read fIsCredit write fIsCredit;

    property Quantity: comp read fQuantity write fQuantity;
    property PayeeNumber: integer read fPayeeNumber write fPayeeNumber;
    property JobCode: string read fJobCode write fJobCode;
  end;

  //----------------------------------------------------------------------------
  TLinesData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TLineData;

    procedure Write(const aJson: TlkJSONobject);overload;
    procedure Write(const aJson: TlkJSONobject; FromIndex,ItemCount:Integer);overload;
  end;

  //----------------------------------------------------------------------------
  TJournalData = class(TObject)
  private
    fDate        : string;
    fDescription : string;
    fReference   : string;

    fLines : TLinesData;
    FSequenceNo: Integer;
    FJournalAccountName: string;
    FJournalContraCode : string;
  public
    constructor Create(); reintroduce; overload;
    destructor Destroy; override;

    procedure Write(const aJson: TlkJSONobject);overload;
    procedure Write(const aJson: TlkJSONobject;FromIndex,ItemCount:Integer);overload;

    property Date : string read fDate write fDate;
    property Description : string read fDescription write fDescription;
    property Reference : string read fReference write fReference;

    property Lines : TLinesData read fLines write fLines;
    property SequenceNo: Integer read FSequenceNo write FSequenceNo;
    property JournalAccountName : string read FJournalAccountName write FJournalAccountName;
    property JournalContraCode: string read FJournalContraCode write FJournalContraCode;
  end;

  //----------------------------------------------------------------------------
  pJournalData = ^TJournalData;

  //----------------------------------------------------------------------------
  TJournalsData = class(TExtdSortedCollection)
  private
    FBatchRef : string;
  protected
    procedure FreeItem( Item : Pointer ); override;
  public
    destructor Destroy; override;

    function Compare(aItem1, aItem2 : Pointer): Integer; override;
    function ItemAs(aItem : Pointer) : TJournalData;

    procedure Write(const aJson: TlkJSONobject);overload;
    procedure Write(const aJson: TlkJSONobject;FromIndex, JournalCount: Integer);overload;
    procedure WriteAJournal(const aJson: TlkJSONobject;JournalIndex, FromIndex, JournalCount: Integer);overload;

    property BatchRef : string read FBatchRef write FBatchRef;
  end;

  //----------------------------------------------------------------------------
  TAllocationData = class(TCollectionItem)
  private
    fAccountNumber : string;
    fDescription : string;
    fAmount : integer;
    fTaxRate : string;
    fTaxAmount : integer;
    fQuantity: comp;
    fPayeeNumber: integer;
    fJobCode: string;
  public
    procedure Write(const aJson: TlkJSONobject; aTransAmount : integer;IsDirectAPI:Boolean=False);

    property AccountNumber : string read fAccountNumber write fAccountNumber;
    property Description : string read fDescription write fDescription;
    property Amount : integer read fAmount write fAmount;
    property TaxRate : string read fTaxRate write fTaxRate;
    property TaxAmount : integer read fTaxAmount write fTaxAmount;
    property Quantity: comp read fQuantity write fQuantity;
    property PayeeNumber: integer read fPayeeNumber write fPayeeNumber;
    property JobCode: string read fJobCode write fJobCode;
  end;

  //----------------------------------------------------------------------------
  TAllocationsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TAllocationData;

    procedure Write(const aJson: TlkJSONobject; aTransAmount : integer;IsDirectAPI:Boolean=False);

    function  PayeeExists(const aPayeeNumber: integer): boolean;
    function  JobExists(const aJobCode: string): boolean;
  end;

  //----------------------------------------------------------------------------
  TTransactionData = class(TCollectionItem)
  private
    fDate : string;
    fDescription : string;
    fReference : string;
    fAmount : integer;
    fCoreTransactionId : string;
    fQuantity: comp;
    fPayeeNumber: integer;
    fJobCode: string;

    fAllocations : TAllocationsData;
    FSequenceNo : Integer; // Temporary storage. No need to send the data to api
  public
    constructor Create(Collection: TCollection); override;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject;IsDirectAPI:Boolean=False);

    property Date : string read fDate write fDate;
    property Description : string read fDescription write fDescription;
    property Reference : string read fReference write fReference;
    property Amount : integer read fAmount write fAmount;
    property CoreTransactionId : string read fCoreTransactionId write fCoreTransactionId;
    property Quantity: comp read fQuantity write fQuantity;
    property PayeeNumber: integer read fPayeeNumber write fPayeeNumber;
    property JobCode: string read fJobCode write fJobCode;

    property Allocations : TAllocationsData read fAllocations write fAllocations;
    property SequenceNo : Integer read FSequenceNo write FSequenceNo;
  end;

  //----------------------------------------------------------------------------
  TTransactionsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TTransactionData;

    procedure Write(const aJson: TlkJSONobject);overload;
    procedure Write(const aJson: TlkJSONobject;FromIndex, TransCount: Integer);overload;

    function  PayeeExists(const aPayeeNumber: integer): boolean;
    function  JobExists(const aJobCode: string): boolean;
  end;

  //----------------------------------------------------------------------------
  TBankAccountData = class(TCollectionItem)
  private
    fBankAccountNumber : string;
    FBatchRef : string;
    fTransactions : TTransactionsData;
    FBankAccountName: string;
  public
    constructor Create(Collection: TCollection); override;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject);overload;
    procedure Write(const aJson: TlkJSONobject;FromIndex, TransCount: Integer);overload;

    property BankAccountNumber : string read fBankAccountNumber write fBankAccountNumber;
    property BankAccountName : string read FBankAccountName write  FBankAccountName;
    property BatchRef : string read FBatchRef write FBatchRef;
    property Transactions : TTransactionsData read fTransactions write fTransactions;
  end;

  //----------------------------------------------------------------------------
  TBankAccountsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TBankAccountData;

    procedure Write(const aJson: TlkJSONobject);
    procedure WriteABankAccount(const aJson: TlkJSONobject;BankIndex, FromIndex, TransCount : Integer);

    function  PayeeExists(const aPayeeNumber: integer): boolean;
    function  JobExists(const aJobCode: string): boolean;
  end;

  //----------------------------------------------------------------------------
  TChartOfAccountData = class(TCollectionItem)
  private
    fCode : string; // id for practice ledger
    FID: Integer;
    fName : string;
    fAccountType : string;
    fGstType : string;
    fOrigAccountType : string;
    fOrigGstType : string;
    fOpeningBalance : integer;
    fBankOrCreditFlag : boolean;
    fInactive : boolean;
    fPostingAllowed : boolean;
    fDivisions : string;
    FIsSystemAccount: Boolean;
    FBusinessID : string;
    FSystemAccountType: string;
  public
    procedure Write(const aJson: TlkJSONobject);
    procedure Read(const aJson: TlkJSONobject);

    property ID: Integer read FID write FID;
    property Code : string read fCode write fCode;
    property Name : string read fName write fName;
    property AccountType : string read fAccountType write fAccountType;
    property GstType : string read fGstType write fGstType;
    property OrigAccountType : string read fOrigAccountType write fOrigAccountType;
    property OrigGstType : string read fOrigGstType write fOrigGstType;
    property OpeningBalance : integer read fOpeningBalance write fOpeningBalance;
    property BankOrCreditFlag : boolean read fBankOrCreditFlag write fBankOrCreditFlag;
    property Inactive : boolean read fInactive write fInactive;
    property PostingAllowed : boolean read fPostingAllowed write fPostingAllowed;
    property Divisions : string read fDivisions write fDivisions;
    property IsSystemAccount: Boolean read FIsSystemAccount write FIsSystemAccount;
    property BusinessID: string read FBusinessID write FBusinessID;
    property SystemAccountType: string read FSystemAccountType write FSystemAccountType;
  end;

  TChartOfAccountsType = ( tcoaCashbook, tcoaPracticeLedger );
  TValidLedgerCodes    = array of String[3];
  //----------------------------------------------------------------------------
  TChartOfAccountsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TChartOfAccountData;

    function FindCode(aChartCode : string; var aChartOfAccountItem : TChartOfAccountData) : boolean;

    procedure Write(const aJson: TlkJSONobject);
    function IsValidJSON( aJSON: TlkJSONobject; aValidLedgerCodes : TValidLedgerCodes ):Boolean;
    procedure Read(aBusinessID: string; const aJson: TlkJSONobject;
                aChartOfAccountsType : tChartOfAccountsType = tcoaCashbook ); virtual;

  end;

  //----------------------------------------------------------------------------
  TPracticeLedgerChartOfAccountsData = class( TChartOfAccountsData )
  private
  protected
  public
    procedure Read(aBusinessID: string; const aJson: TlkJSONobject); reintroduce;
  end;

  //----------------------------------------------------------------------------
  TDivisionData = class(TCollectionItem)
  private
    fId : integer;
    fName : string;
  public
    procedure Write(const aJson: TlkJSONobject);

    property Id : integer read fId write fId;
    property Name : string read fName write fName;
  end;

  //----------------------------------------------------------------------------
  TDivisionsData = class(TCollection)
  private
  public
    destructor Destroy; override;

    function ItemAs(aIndex : integer) : TDivisionData;

    procedure Write(const aJson: TlkJSONobject);
  end;

  //----------------------------------------------------------------------------
  TBankFeedApplicationData = class(TCollectionItem)
  private
    fCountryCode : string;
    fCoreClientCode : string;
    fCoreAccountId : string;
    fBankAccountNumber : string;
    fOperation : string;
  public
    procedure Write(const aJson: TlkJSONobject);

    property CountryCode : string read fCountryCode write fCountryCode;
    property CoreClientCode : string read fCoreClientCode write fCoreClientCode;
    property CoreAccountId : string read fCoreAccountId write fCoreAccountId;
    property BankAccountNumber : string read fBankAccountNumber write fBankAccountNumber;
    property Operation : string read fOperation write fOperation;
  end;

  //----------------------------------------------------------------------------
  TBankFeedApplicationsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TBankFeedApplicationData;

    procedure Write(const aJson: TlkJSONobject);
  end;

  //----------------------------------------------------------------------------
  TPayeeLineData = class(TCollectionItem)
  private
    fAccountNumber: string;
    fPercentage: comp;
    fTaxRate: string;
    fNarration: string;
    fAmount: comp;

  public
    procedure Write(const aJson: TlkJSONobject);

    property  AccountNumber: string read fAccountNumber write fAccountNumber;
    property  Percentage: comp read fPercentage write fPercentage;
    property  TaxRate: string read fTaxRate write fTaxRate;
    property  Narration: string read fNarration write fNarration;
    property  Amount: comp read fAmount write fAmount;

  end;

  //----------------------------------------------------------------------------
  TPayeeLinesData = class(TCollection)
  private
  public
    function ItemAs(aIndex: integer): TPayeeLineData;

    procedure Write(const aJson: TlkJSONobject);
  end;

  //----------------------------------------------------------------------------
  TPayeeData = class(TCollectionItem)
  private
    fPayeeNumber: integer;
    fInactive: boolean;
    fContractorPayee: boolean;
    fPayeeName: string;
    fPayeeSurname: string;
    fPayeeGivenName: string;
    fOtherName: string;
    fAddress: string;
    fTown: string;
    fState: string;
    fPostcode: string;
    fPhoneNumber: string;
    fABN: string;
    fBusinessName: string;
    fTradingName: string;
    fAddress2: string;
    fCountry: string;
    fBankAccountNumber: string;

    fLines: TPayeeLinesData;

  public
    constructor Create(Collection: TCollection); override;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject);

    property  PayeeNumber: integer read fPayeeNumber write fPayeeNumber;
    property  Inactive: boolean read fInactive write fInactive;
    property  ContractorPayee: boolean read fContractorPayee write fContractorPayee;
    property  PayeeName: string read fPayeeName write fPayeeName;
    property  PayeeSurname: string read fPayeeSurname write fPayeeSurname;
    property  PayeeGivenName: string read fPayeeGivenName write fPayeeGivenName;
    property  OtherName: string read fOtherName write fOtherName;
    property  Address: string read fAddress write fAddress;
    property  Town: string read fTown write fTown;
    property  State: string read fState write fState;
    property  Postcode: string read fPostcode write fPostcode;
    property  PhoneNumber: string read fPhoneNumber write fPhoneNumber;
    property  ABN: string read fABN write fABN;
    property  BusinessName: string read fBusinessName write fBusinessName;
    property  TradingName: string read fTradingName write fTradingName;
    property  Address2: string read fAddress2 write fAddress2;
    property  Country: string read fCountry write fCountry;
    property  BankAccountNumber: string read fBankAccountNumber write fBankAccountNumber;

    property  Lines: TPayeeLinesData read fLines;
  end;

  //----------------------------------------------------------------------------
  TPayeesData = class(TCollection)
  public
    function  ItemAs(aIndex: integer): TPayeeData;

    procedure Write(const aJson: TlkJSONobject);
  end;

  //----------------------------------------------------------------------------
  TJobData = class(TCollectionItem)
  private
    fCode: string;
    fName: string;
    fCompleted: integer;

  public
    procedure Write(const aJson: TlkJSONobject);

    property  Code: string read fCode write fCode;
    property  Name: string read fName write fName;
    property  Completed: integer read fCompleted write fCompleted;
  end;

  //----------------------------------------------------------------------------
  TJobsData = class(TCollection)
  public
    function  ItemAs(aIndex: integer): TJobData;

    procedure Write(const aJson: TlkJSONobject);
  end;

  //----------------------------------------------------------------------------
  TBusinessData = class
  private
    FID: string;
    FName: string;
    fABN : string;
    fIRD : string;
    fClientCode : string;
    fOrigClientCode : string;
    fFinancialYearStartMonth : integer;
    fOpeningBalanceDate : string;
    fFirmId : string;
    FVisibility: Boolean;
    FLicenseCode: string;
  public
    procedure Write(const aJson: TlkJSONobject);
    procedure Read(const aJson: TlkJSONobject);

    property ID: string read FID write FID;
    property Name: string read FName write FName;

    property  ABN : string read fABN write fABN;
    property  IRD : string read fIRD write fIRD;
    property  ClientCode : string read fClientCode write fClientCode;
    property  OrigClientCode : string read fOrigClientCode write fOrigClientCode;
    property  FinancialYearStartMonth : integer read fFinancialYearStartMonth write fFinancialYearStartMonth;
    property  OpeningBalanceDate : string read fOpeningBalanceDate write fOpeningBalanceDate;
    property  FirmId : string read fFirmId write fFirmId;
    property Visibility: Boolean read FVisibility write FVisibility;
    property LicenseCode : string read FLicenseCode write FLicenseCode;
  end;

  TBusinesses = class(TObjectList)
  public
    function GetItem(aIndex : integer) : TBusinessData;overload;
    function GetItem(aBusinessID : string) : TBusinessData;overload;

    function IsValidJSON(aJSON: TlkJSONobject; aFirmID, aLicense: string):Boolean;
    procedure Read(aFirmID:string;LicenseType: TLicenceType;const aJson: TlkJSONObject);
  end;

  //----------------------------------------------------------------------------
  TClientData = class
  private
    fBusinessData: TBusinessData;
    fBankFeedApplicationsData : TBankFeedApplicationsData;
    fChartOfAccountsData : TChartOfAccountsData;
    fDivisionsData : TDivisionsData;
    fBankAccountsData : TBankAccountsData;
    fJournalsData : TJournalsData;
    fPayeesData: TPayeesData;
    fJobsData: TJobsData;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Write(const aJson: TlkJSONobject; aSelectedData: TSelectedData);

    property BusinessData: TBusinessData read fBusinessData write fBusinessData;
    property BankFeedApplicationsData : TBankFeedApplicationsData read fBankFeedApplicationsData write fBankFeedApplicationsData;
    property ChartOfAccountsData: TChartOfAccountsData read fChartOfAccountsData write fChartOfAccountsData;
    property DivisionsData: TDivisionsData read fDivisionsData write fDivisionsData;
    property BankAccountsData : TBankAccountsData read fBankAccountsData write fBankAccountsData;
    property JournalsData: TJournalsData read fJournalsData write fJournalsData;
    property PayeesData: TPayeesData read fPayeesData;
    property JobsData: TJobsData read fJobsData;
  end;

  //----------------------------------------------------------------------------
  TClientBase = class
  private
    fClientData : TClientData;

    fToken : string;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject; aSelectedData: TSelectedData);

    function GetData(aSelectedData: TSelectedData) : string;

    property ClientData: TClientData read fClientData write fClientData;

    property Token : string read fToken write fToken;
  end;

  //----------------------------------------------------------------------------
  TFile = class
  private
    fID: string;
    fFileName: string;
    fDataLength: integer;
    fData: string;

    function  GetFileHash: string;
    function  GetDataAsZipBase64: string;
  public
    constructor Create;

    procedure Write(const aJson: TlkJSONobject);

    property  ID: string read fID write fID;
    property  FileName: string read fFileName write fFileName;
    property  DataLength: integer read fDataLength write fDataLength;
    property  Data: string read fData write fData;
  end;

  //----------------------------------------------------------------------------
  TParameters = class(TListDestroy)
  private
    fDataStore: string;
    fQueue: string;
    fRegion: string;
    fBLIdentity : string;
  public
    procedure Write(const aJson: TlkJSONlist);

    property DataStore : string read fDataStore write fDataStore;
    property Queue : string read fQueue write fQueue;
    property Region : string read fRegion write fRegion;
    property BLIdentity : string read fBLIdentity write fBLIdentity;
  end;

    //----------------------------------------------------------------------------
  TMigrationUpload = class
  private
    fID: string;
    fUploadType: integer;
    fFile: TFile;
    fParameters: TParameters;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject);

    property  ID: string read fID;
    property  UploadType: integer read fUploadType write fUploadType;
    property  Files: TFile read fFile;
    property  Parameters: TParameters read fParameters;
  end;

  //----------------------------------------------------------------------------
  TUrlsMap = class
  private
    fName: string;
    fValue: string;
  public
    procedure Read(const aJson: TlkJSONobject);

    property  Name: string read fName write fName;
    property  Value: string read fValue write fValue;
  end;

  //----------------------------------------------------------------------------
  TMigrationUploadResponse = class
  private
    fUploadID: string;
    fResponseCode: integer;
    fUrlsMap: TUrlsMap;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Read(const aJson: TlkJSONobject);

    property  UploadID: string read fUploadID write fUploadID;
    property  RespondeCode: integer read fResponseCode write fResponseCode;
    property  UrlsMap: TUrlsMap read fUrlsMap;
  end;

//------------------------------------------------------------------------------
implementation

uses
  IdCoder,
  IdCoderMIME,
  CryptUtils,
  GenUtils,
  LogUtil,
  ZlibExGZ,
  Globals,
  ZipUtils,
  StDateSt,
  bkdateutils;

const
  UnitName = 'CashbookMigrationRestData';

var
  DebugMe : boolean = false;

function CompareNames(Item1, Item2: Pointer): Integer;
begin
  Result := CompareText(TBusinessData(Item1).Name, TBusinessData(Item2).Name)
end;
{ TListDestroy }
//------------------------------------------------------------------------------
procedure TListDestroy.Notify(Ptr: Pointer; Action: TListNotification);
var
  Item: TObject;
begin
  inherited;

  if (Action = lnDeleted) then
  begin
    Item := TObject(Ptr);
    FreeAndNil(Item);
  end;
end;

{ TFirm }
//------------------------------------------------------------------------------
procedure TFirm.Read(const aJson: TlkJSONobject);
var
  License : TlkJSONbase;
  i : Integer;
begin
  ASSERT(Assigned(aJson));

  ID := aJson.getString('id');
  Name := aJson.getString('name');
  Region := aJson.getString('region');
  License := aJson.Field['eligible_licence_codes'];
  if Assigned(License) then
  begin
    for i := 0 to License.Count - 1 do
    begin
      if (Trim(FEligibleLicense) = '') then
        FEligibleLicense := License.Child[i].Value
      else
        FEligibleLicense := FEligibleLicense + ',' + License.Child[i].Value;
    end;
  end;
end;

{ TFirms }
//------------------------------------------------------------------------------
function TFirms.GetItem(const aIndex: integer): TFirm;
begin
  result := TFirm(Get(aIndex));
end;

//------------------------------------------------------------------------------
function TFirms.GetItem(const aFirmID: string): TFirm;
var
  i : Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if TFirm(Items[i]).ID = aFirmID then
    begin
      Result := TFirm(Items[i]);
      Exit;
    end;
  end;
end;

function TFirms.IsValidJSON(aJSONObject: TlkJSONobject): Boolean;
var
  License : TlkJSONbase;
  i : Integer;
begin
  Result := False;

  if not Assigned(aJSONObject) then
    Exit;

  if not (Assigned(aJSONObject.Field['id']) and
     Assigned(aJSONObject.Field['name']) and
     Assigned(aJSONObject.Field['region']) and
     Assigned(aJSONObject.Field['eligible_licence_codes'])) then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'Missing fields in Firm data received from API');
    Exit;
  end;

  try
    if ((Trim(aJSONObject.getString('id')) = '') or
        (Trim(aJSONObject.getString('name')) = '') or
        (Trim(aJSONObject.getString('region')) = '')) then
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, 'Missing fields in Firm data received from API');
      Exit;
    end;

    if not ((Trim(aJSONObject.getString('region'))= 'AU') or (Trim(aJSONObject.getString('region'))= 'NZ')) then
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, 'Invalid region in Firm data received from API');
      Exit;
    end;

    License := aJSONObject.Field['eligible_licence_codes'];

    if Assigned(License) then
    begin
      if License.Count = 0 then
      begin
        if DebugMe then
          LogUtil.LogMsg(lmDebug, UnitName, 'Invalid region in Firm data received from API');
        Exit;
      end;

      for i := 0 to License.Count - 1 do
      begin
        if ((Trim(License.Child[i].Value) = '') or
           (not((License.Child[i].Value = 'CB') or (License.Child[i].Value = 'PL')))) then
        begin
          if DebugMe then
            LogUtil.LogMsg(lmDebug, UnitName, 'Invalid region in Firm data received from API');
          Exit;
        end;
      end;
    end;
  except
    Exit;
  end;
  Result := True;
end;

procedure TFirms.Read(const aJson: TlkJSONlist);
var
  i: integer;
  Child: TlkJSONobject;
  Firm: TFirm;
begin
  ASSERT(Assigned(aJson));

  for i := 0 to aJson.Count-1 do
  begin
    Child := aJson.Child[i] as TlkJSONobject;
    if Assigned(Child) then
    begin
      if IsValidJSON(Child) then
      begin
        // New firm
        Firm := TFirm.Create;
        // Read firm
        Firm.Read(Child);
        Add(Firm);
      end
      else
        LogUtil.LogMsg(lmInfo , UnitName, 'GET Firms API retrieved some invalid data');
    end;
  end;

  Self.Sort(CompareNames);
end;

{ TLineData }
//------------------------------------------------------------------------------
procedure TLineData.Write(const aJson: TlkJSONobject;IsDirectAPI:Boolean=False);
begin
  if IsDirectAPI then
  begin
    aJson.Add('account_number', AccountNumber);
    aJson.Add('amount', (abs(Amount)-abs(TaxAmount)));

    aJson.Add('description', Description);
    aJson.Add('tax_rate', TaxRate);
    aJson.Add('tax_amount', abs(TaxAmount) );
    aJson.Add('is_credit', IsCredit);
    aJson.Add('quantity', Quantity);
    //aJson.Add('payee_number', PayeeNumber);
  end
  else
  begin
    aJson.Add('AccountNumber', AccountNumber);
    aJson.Add('Amount', (abs(Amount)-abs(TaxAmount)));

    aJson.Add('Description', Description);
    aJson.Add('Reference', Reference);
    aJson.Add('TaxRate', TaxRate);
    aJson.Add('TaxAmount', abs(TaxAmount) );

    aJson.Add('IsCredit', IsCredit);

    aJson.Add('Quantity', Quantity);
    aJson.Add('PayeeNumber', PayeeNumber);
    aJson.Add('JobCode', JobCode);
  end;
end;

{ TLinesData }
//------------------------------------------------------------------------------
function TLinesData.ItemAs(aIndex: integer): TLineData;
begin
  Result := TLineData(Self.Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TLinesData.Write(const aJson: TlkJSONobject);
var
  Lines: TlkJSONlist;
  LineIndex : integer;
  Line : TLineData;
  LineData : TlkJSONobject;
begin
  if self.Count = 0 then
    Exit;

  Lines := TlkJSONlist.Create;
  aJson.Add('Lines', Lines);

  for LineIndex := 0 to self.Count-1 do
  begin
    LineData := TlkJSONobject.Create;
    Lines.Add(LineData);

    Line := ItemAs(LineIndex);
    Line.Write(LineData);
  end;
end;

//------------------------------------------------------------------------------
constructor TJournalData.Create();
begin
  inherited Create();

  fLines := TLinesData.Create(TLineData);
end;

//------------------------------------------------------------------------------
destructor TJournalData.Destroy;
begin
  FLines.Clear;
  FreeAndNil(FLines);

  inherited;
end;

procedure TJournalData.Write(const aJson: TlkJSONobject; FromIndex,
  ItemCount: Integer);
begin
  aJson.Add('date', Date);
  aJson.Add('description', Description);
  aJson.Add('reference_id', Reference);

  Lines.Write(aJson,FromIndex, ItemCount);
end;

//------------------------------------------------------------------------------
procedure TJournalData.Write(const aJson: TlkJSONobject);
begin
  aJson.Add('Date', Date);
  aJson.Add('Description', Description);
  aJson.Add('Reference', Reference);

  Lines.Write(aJson);
end;

{ TJournalsData }
//------------------------------------------------------------------------------
procedure TJournalsData.FreeItem(Item: Pointer);
begin
  inherited;

end;

//------------------------------------------------------------------------------
function TJournalsData.Compare(aItem1, aItem2: Pointer): Integer;
begin
  if DateStringToStDate('yyyy-mm-dd', TJournalData(aItem1).Date, Epoch) < DateStringToStDate('yyyy-mm-dd', TJournalData(aItem2).Date, Epoch) then
    Result := -1
  else if DateStringToStDate('yyyy-mm-dd', TJournalData(aItem1).Date, Epoch) > DateStringToStDate('yyyy-mm-dd', TJournalData(aItem2).Date, Epoch) then
    Result := 1
  else
    Result := 0;
end;

//------------------------------------------------------------------------------
destructor TJournalsData.Destroy;
begin

  inherited;
end;

//------------------------------------------------------------------------------
function TJournalsData.ItemAs(aItem : Pointer): TJournalData;
begin
  Result := TJournalData(aItem);
end;

procedure TJournalsData.Write(const aJson: TlkJSONobject; FromIndex,
  JournalCount: Integer);
var
  Journals: TlkJSONlist;
  i, ToIndex : integer;
  Journal : TJournalData;
  JournalData : TlkJSONobject;
begin
  if Self.ItemCount = 0 then
    Exit;

  if FromIndex > ItemCount then
    Exit;

  if FromIndex + JournalCount > ItemCount then
    ToIndex := ItemCount
  else
    ToIndex := FromIndex + JournalCount;

  Journals := TlkJSONlist.Create;

  FBatchRef := 'JOUR-' + FormatdateTime('ddmmyyyyhhnnss',Now);
  if Assigned(MyClient) then
    FBatchRef := MyClient.clFields.clName + '-' + FormatdateTime('ddmmyyyyhhnnss',Now);

  aJson.Add('batch_ref', FBatchRef);
  aJson.Add('general_journals', Journals);

  for i := FromIndex to ToIndex - 1 do
  begin
    JournalData := TlkJSONobject.Create;
    Journals.Add(JournalData);

    Journal := ItemAs(Items[i]);
    if Assigned(Journal) then
      Journal.Write(JournalData,FromIndex, Journal.Lines.Count); //JournalCount);
  end;
end;

procedure TJournalsData.WriteAJournal(const aJson: TlkJSONobject; JournalIndex,
  FromIndex, JournalCount: Integer);
var
  Journals: TlkJSONlist;
  JournalObj : TJournalData;
  JournalData : TlkJSONobject;
begin
  if Self.ItemCount = 0 then
    Exit;

  if FromIndex > ItemCount then
    Exit;

  JournalObj := ItemAs(Items[JournalIndex]);
  Journals := TlkJSONlist.Create;
  JournalData := TlkJSONobject.Create;
  Journals.Add(JournalData);

  FBatchRef := 'JOUR' + FormatdateTime('ddmmyyyyhhnnss',Now);
  aJson.Add('batch_ref', FBatchRef);
  aJson.Add('general_journals', Journals);

  if Assigned(JournalObj) then
    JournalObj.Write(JournalData, FromIndex, JournalObj.Lines.Count);//JournalCount);
end;

//------------------------------------------------------------------------------
procedure TJournalsData.Write(const aJson: TlkJSONobject);
var
  Journals: TlkJSONlist;
  JournalIndex : integer;
  Journal : TJournalData;
  JournalData : TlkJSONobject;
begin
  if self.ItemCount = 0 then
    Exit;

  Journals := TlkJSONlist.Create;
  aJson.Add('generaljournals', Journals);

  for JournalIndex := 0 to self.ItemCount-1 do
  begin
    JournalData := TlkJSONobject.Create;
    Journals.Add(JournalData);

    Journal := ItemAs(Items[JournalIndex]);
    Journal.Write(JournalData);
  end;
end;

{ TAllocationData }
//------------------------------------------------------------------------------
procedure TAllocationData.Write(const aJson: TlkJSONobject; aTransAmount : integer;IsDirectAPI:Boolean=False);
begin
  if IsDirectAPI then
  begin
    aJson.Add('account_number', AccountNumber);
    aJson.Add('description', Description);

    aJson.Add('amount', (Amount-TaxAmount));
    aJson.Add('tax_rate', TaxRate);
    aJson.Add('tax_amount', TaxAmount);
    aJson.Add('quantity', Quantity);
    //aJson.Add('payee_number', PayeeNumber);
  end
  else
  begin
    aJson.Add('AccountNumber', AccountNumber);
    aJson.Add('Description', Description);

    aJson.Add('Amount', (Amount-TaxAmount));
    aJson.Add('TaxRate', TaxRate);
    aJson.Add('TaxAmount', TaxAmount);

    aJson.Add('Quantity', Quantity);
    aJson.Add('PayeeNumber', PayeeNumber);
    aJson.Add('JobCode', JobCode);
  end;
end;

{ TAllocationsData }
//------------------------------------------------------------------------------
function TAllocationsData.ItemAs(aIndex: integer): TAllocationData;
begin
  Result := TAllocationData(Self.Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TAllocationsData.Write(const aJson: TlkJSONobject; aTransAmount : integer;IsDirectAPI:Boolean=False);
var
  Allocations: TlkJSONlist;
  AllocationIndex : integer;
  Allocation : TAllocationData;
  AllocationData : TlkJSONobject;
begin
  if Self.Count = 0 then
    Exit;

  Allocations := TlkJSONlist.Create;

  if IsDirectAPI  then
    aJson.Add('allocations', Allocations)
  else
    aJson.Add('Allocations', Allocations);

  for AllocationIndex := 0 to self.Count-1 do
  begin
    AllocationData := TlkJSONobject.Create;
    Allocations.Add(AllocationData);

    Allocation := ItemAs(AllocationIndex);

    Allocation.Write(AllocationData, aTransAmount,IsDirectAPI)
  end;
end;

//------------------------------------------------------------------------------
function TAllocationsData.PayeeExists(const aPayeeNumber: integer): boolean;
var
  i: integer;
  AllocationData: TAllocationData;
begin
  for i := 0 to Count-1 do
  begin
    AllocationData := ItemAs(i);

    if (AllocationData.PayeeNumber = aPayeeNumber) then
    begin
      result := true;

      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TAllocationsData.JobExists(const aJobCode: string): boolean;
var
  i: integer;
  AllocationData: TAllocationData;
begin
  for i := 0 to Count-1 do
  begin
    AllocationData := ItemAs(i);

    if (AllocationData.JobCode = aJobCode) then
    begin
      result := true;

      exit;
    end;
  end;

  result := false;
end;

{ TTransactionData }
//------------------------------------------------------------------------------
constructor TTransactionData.Create(Collection: TCollection);
begin
  inherited;

  fAllocations := TAllocationsData.Create(TAllocationData);
end;

//------------------------------------------------------------------------------
destructor TTransactionData.Destroy;
begin
  fAllocations.Clear;
  FreeAndNil(fAllocations);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TTransactionData.Write(const aJson: TlkJSONobject;IsDirectAPI:Boolean=False);
begin
  if IsDirectAPI then
  begin
    aJson.Add('date', Date);
    aJson.Add('description', Description);
    aJson.Add('amount', -(Amount));

    if CoreTransactionId <> '' then
      aJson.Add('core_transaction_id', CoreTransactionId);
    aJson.Add('quantity', Quantity);
    //aJson.Add('payee_number', PayeeNumber);

    Allocations.Write(aJson, Amount, True);
  end
  else
  begin
    aJson.Add('Date', Date);
    aJson.Add('Description', Description);
    aJson.Add('Reference', Reference);

    aJson.Add('Amount', -(Amount));

    if CoreTransactionId <> '' then
      aJson.Add('CoreTransactionId', CoreTransactionId);

    aJson.Add('Quantity', Quantity);
    aJson.Add('PayeeNumber', PayeeNumber);
    aJson.Add('JobCode', JobCode);

    Allocations.Write(aJson, Amount);
  end;
end;

{ TTransactionsData }
//------------------------------------------------------------------------------
function TTransactionsData.ItemAs(aIndex: integer): TTransactionData;
begin
  Result := TTransactionData(Self.Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TTransactionsData.Write(const aJson: TlkJSONobject);
var
  Transactions: TlkJSONlist;
  TransactionIndex : integer;
  Transaction : TTransactionData;
  TransactionData : TlkJSONobject;
begin
  if self.Count = 0 then
    Exit;

  Transactions := TlkJSONlist.Create;
  aJson.Add('BankTransactions', Transactions);

  for TransactionIndex := 0 to self.Count-1 do
  begin
    TransactionData := TlkJSONobject.Create;
    Transactions.Add(TransactionData);

    Transaction := ItemAs(TransactionIndex);
    Transaction.Write(TransactionData);
  end;
end;

//------------------------------------------------------------------------------
function TTransactionsData.PayeeExists(const aPayeeNumber: integer): boolean;
var
  i: integer;
  TransactionData: TTransactionData;
begin
  for i := 0 to Count-1 do
  begin
    TransactionData := ItemAs(i);

    if (TransactionData.PayeeNumber = aPayeeNumber) then
    begin
      result := true;
      exit;
    end;

    if TransactionData.Allocations.PayeeExists(aPayeeNumber) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

procedure TTransactionsData.Write(const aJson: TlkJSONobject; FromIndex,
  TransCount: Integer);
var
  Transactions: TlkJSONlist;
  i : integer;
  Transaction : TTransactionData;
  TransactionData : TlkJSONobject;
  ToIndex: Integer;
begin
  // this write function is used for direct api write.
  if Self.Count = 0 then
    Exit;

  if FromIndex > Count then
    Exit;

  if FromIndex + TransCount > Count then
    ToIndex := Count
  else
    ToIndex := FromIndex + TransCount;

  Transactions := TlkJSONlist.Create;
  aJson.Add('bank_transactions', Transactions);

  for i := FromIndex to ToIndex - 1 do
  begin
    TransactionData := TlkJSONobject.Create;
    Transactions.Add(TransactionData);

    Transaction := ItemAs(i);
    Transaction.Write(TransactionData,True);
  end;
end;

//------------------------------------------------------------------------------
function TTransactionsData.JobExists(const aJobCode: string): boolean;
var
  i: integer;
  TransactionData: TTransactionData;
begin
  for i := 0 to Count-1 do
  begin
    TransactionData := ItemAs(i);

    if (TransactionData.JobCode = aJobCode) then
    begin
      result := true;
      exit;
    end;

    if TransactionData.Allocations.JobExists(aJobCode) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

{ TBankAccountData }
//------------------------------------------------------------------------------
constructor TBankAccountData.Create(Collection: TCollection);
begin
  inherited;
  FTransactions := TTransactionsData.Create(TTransactionData);
end;

//------------------------------------------------------------------------------
destructor TBankAccountData.Destroy;
begin
  fTransactions.Clear;
  FreeAndNil(fTransactions);
  inherited;
end;

procedure TBankAccountData.Write(const aJson: TlkJSONobject; FromIndex,
  TransCount: Integer);
begin
  FBatchRef := 'BA' + FormatdateTime('ddmmyyyyhhnnss',Now);
  if Assigned(MyClient) then
    FBatchRef := MyClient.clFields.clName + '-' + FormatdateTime('ddmmyyyyhhnnss',Now);

  aJson.Add('batch_ref', FBatchRef);
  aJson.Add('bank_account_number', BankAccountNumber);

  Transactions.Write(aJson, FromIndex, TransCount);
end;

//------------------------------------------------------------------------------
procedure TBankAccountData.Write(const aJson: TlkJSONobject);
begin
  aJson.Add('BankAccountNumber', BankAccountNumber);

  Transactions.Write(aJson);
end;

{ TBankAccountsData }
//------------------------------------------------------------------------------
function TBankAccountsData.ItemAs(aIndex: integer): TBankAccountData;
begin
  Result := TBankAccountData(Self.Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TBankAccountsData.Write(const aJson: TlkJSONobject);
var
  BankAccounts: TlkJSONlist;
  BankAccountIndex : integer;
  BankAccount : TBankAccountData;
  BankAccountData : TlkJSONobject;
  AllBankAccountsEmpty : boolean;
begin
  if (self.Count = 0) then
    Exit;

  AllBankAccountsEmpty := true;
  for BankAccountIndex := 0 to self.Count-1 do
    if ItemAs(BankAccountIndex).Transactions.Count > 0 then
      AllBankAccountsEmpty := false;

  if AllBankAccountsEmpty then
    Exit;

  BankAccounts := TlkJSONlist.Create;
  aJson.Add('bankaccounts', BankAccounts);

  for BankAccountIndex := 0 to self.Count-1 do
  begin
    if ItemAs(BankAccountIndex).Transactions.Count = 0 then
      continue;

    BankAccountData := TlkJSONobject.Create;
    BankAccounts.Add(BankAccountData);

    BankAccount := ItemAs(BankAccountIndex);
    BankAccount.Write(BankAccountData);
  end;
end;

procedure TBankAccountsData.WriteABankAccount(const aJson: TlkJSONobject;
  BankIndex, FromIndex, TransCount: Integer);
var
  BankAccounts: TlkJSONlist;
  BankAccountObj : TBankAccountData;
  BankAccountData : TlkJSONobject;
  AllBankAccountsEmpty : boolean;
  i: Integer;
begin
  if (Self.Count = 0) then
    Exit;

  AllBankAccountsEmpty := true;
  for i := 0 to Self.Count-1 do
    if ItemAs(i).Transactions.Count > 0 then
      AllBankAccountsEmpty := false;

  if AllBankAccountsEmpty then
    Exit;

  BankAccountObj := ItemAs(BankIndex);
  BankAccounts := TlkJSONlist.Create;
  BankAccountData := TlkJSONobject.Create;
  aJson.Add('', BankAccounts);

  BankAccounts.Add(BankAccountData);
  BankAccountObj.Write(BankAccountData, FromIndex, TransCount);
end;

//------------------------------------------------------------------------------
function TBankAccountsData.PayeeExists(const aPayeeNumber: integer): boolean;
var
  i: integer;
  BankAccountData: TBankAccountData;
begin
  for i := 0 to Count-1 do
  begin
    BankAccountData := ItemAs(i);

    if BankAccountData.Transactions.PayeeExists(aPayeeNumber) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

//------------------------------------------------------------------------------
function TBankAccountsData.JobExists(const aJobCode: string): boolean;
var
  i: integer;
  BankAccountData: TBankAccountData;
begin
  for i := 0 to Count-1 do
  begin
    BankAccountData := ItemAs(i);

    if BankAccountData.Transactions.JobExists(aJobCode) then
    begin
      result := true;
      exit;
    end;
  end;

  result := false;
end;

{ TChartOfAccountData }
//------------------------------------------------------------------------------
procedure TChartOfAccountData.Read(const aJson: TlkJSONobject);
begin
  ASSERT(assigned(aJson));

  FID := aJson.getInt('id');
  FName := aJson.getString('name');
  FCode := aJson.getString('number');
  fAccountType := aJson.getString('account_type');
  fGstType := aJson.getString('tax_rate');
  FBusinessID := aJson.getString('business_id');
  fOpeningBalance := 0;
  fBankOrCreditFlag := False;
  FIsSystemAccount := False;
  FSystemAccountType := '';
  if (Assigned(aJson.Field['opening_balance']) and (aJson.Field['opening_balance'].SelfType <> jsNull)) then
    fOpeningBalance := aJson.getInt('opening_balance');
  if (Assigned(aJson.Field['bank_or_credit_flag']) and (aJson.Field['bank_or_credit_flag'].SelfType <> jsNull)) then
    fBankOrCreditFlag := aJson.getBoolean('bank_or_credit_flag');
  if (Assigned(aJson.Field['permits_journal_entry']) and (aJson.Field['permits_journal_entry'].SelfType <> jsNull)) then
    fPostingAllowed := aJson.getBoolean('permits_journal_entry');
  if (Assigned(aJson.Field['system_account']) and (aJson.Field['system_account'].SelfType <> jsNull)) then
    FIsSystemAccount := aJson.getBoolean('system_account');
  if (Assigned(aJson.Field['system_account_type']) and (aJson.Field['system_account_type'].SelfType <> jsNull)) then
    FSystemAccountType := aJson.getString('system_account_type');
end;

procedure TChartOfAccountData.Write(const aJson: TlkJSONobject);
begin
  aJson.Add('Code', Code);
  aJson.Add('Name', Name);
  aJson.Add('AccountType', AccountType);
  aJson.Add('GstType', GstType);
  aJson.Add('OrigAccountType', OrigAccountType);
  aJson.Add('OrigGstType', OrigGstType);

  if OpeningBalance <> 0 then
    aJson.Add('OpeningBalance', OpeningBalance);

  if BankOrCreditFlag then
    aJson.Add('BankOrCreditFlag', BankOrCreditFlag);

  aJson.Add('Inactive', InActive);
  aJson.Add('PostingAllowed', PostingAllowed);
  aJson.Add('Divisions', Divisions);
end;

{ TChartOfAccountsData }
//------------------------------------------------------------------------------
function TChartOfAccountsData.IsValidJSON( aJSON: TlkJSONobject; aValidLedgerCodes : TValidLedgerCodes ): Boolean;
var
  AcctType, GSTCode : string;
  i : Integer;
  GSTValid : Boolean;
begin
  Result := False;
  if not Assigned(aJSON) then
    Exit;

  if not (Assigned(aJSON.Field['id']) and
     Assigned(aJSON.Field['name']) and
     Assigned(aJSON.Field['number']) and
     Assigned(aJSON.Field['business_id']) and
     Assigned(aJSON.Field['tax_rate']) and
     Assigned(aJSON.Field['account_type'])) then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'Missing fields in COA data received from API');
    Exit;
  end;

  try
    if ((aJSON.getInt('id') <= 0) or
        (Trim(aJson.getString('name')) = '') or
        (Trim(aJson.getString('number')) = '') or
        (Trim(aJson.getString('account_type')) = '') or
        (Trim(aJson.getString('business_id')) = '') or
        (Trim(aJson.getString('tax_rate')) = ''))then
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, 'Missing fields in COA data received from API');
      Exit;
    end;
  except
    Exit; // exit if there is any exception while processing the integer type : typecast error
  end;

  AcctType := Trim(aJson.getString('account_type'));

  if not ((AcctType = AT_COSTOFSALES) or
      (AcctType = AT_EXPENSE) or
      (AcctType = AT_OTHEREXPENSE) or
      (AcctType = AT_ASSET) or
      (AcctType = AT_INCOME) or
      (AcctType = AT_OTHERINCOME) or
      (AcctType = AT_LIABILITY) or
      (AcctType = AT_EQUITY) or
      (AcctType = AT_UNCATEGORISED)) then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'Invalid account type in COA data received from API ' + AcctType);
    Exit;
  end;

  GSTCode := Trim(aJson.getString('tax_rate'));

  GSTValid := False;
  for i := 1 to High(ValidPLCodes) do
  if GSTCode = ValidPLCodes[i] then
  begin
    GSTValid := True;
    Break;
  end;
  if not GSTValid then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'Invalid GST type in COA data received from API ' + AcctType);
    Exit;
  end;

  Result := True;
end;

function TChartOfAccountsData.ItemAs(aIndex: integer): TChartOfAccountData;
begin
  Result := TChartOfAccountData(Self.Items[aIndex]);
end;

procedure TChartOfAccountsData.Read(aBusinessID: string; const aJson: TlkJSONobject);
var
  i: integer;
  Child: TlkJSONobject;
  Field : TlkJSONlist;
  ChartOfAccount: TChartOfAccountData;
begin
  Clear;

  ASSERT(assigned(aJson));
  if Trim(aBusinessID) = '' then
  Exit;

  Field := aJson.Field['accounts'] as TlkJsonList;

  if not Assigned(Field) then
    Exit;

  for i := 0 to Field.Count - 1 do
  begin
    Child := Field.Child[i] as TlkJSONobject;

    if IsValidJSON(Child) then
    begin
      // New business
      ChartOfAccount := TChartOfAccountData(Self.Add);
      // Read business
      ChartOfAccount.Read(Child);
    end
    else
      LogUtil.LogMsg(lmInfo , UnitName, 'GET COA API retrieved some invalid data');
  end;
end;

//------------------------------------------------------------------------------
function TChartOfAccountsData.FindCode(aChartCode : string; var aChartOfAccountItem : TChartOfAccountData) : boolean;
var
  ChartIndex : integer;
  ChartOfAccountItem : TChartOfAccountData;
begin
  Result := false;
  aChartOfAccountItem := nil;
  for ChartIndex := 0 to Count - 1 do
  begin
    ChartOfAccountItem := ItemAs(ChartIndex);
    if ChartOfAccountItem.Code = aChartCode then
    begin
      Result := true;
      aChartOfAccountItem := ChartOfAccountItem;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TChartOfAccountsData.Write(const aJson: TlkJSONobject);
var
  Accounts: TlkJSONlist;
  AccountIndex : integer;
  ChartOfAccount : TChartOfAccountData;
  ChartOfAccountData : TlkJSONobject;
begin
  if self.Count = 0 then
    Exit;

  Accounts := TlkJSONlist.Create;
  aJson.Add('accounts', Accounts);

  for AccountIndex := 0 to self.Count-1 do
  begin
    ChartOfAccountData := TlkJSONobject.Create;
    Accounts.Add(ChartOfAccountData);

    ChartOfAccount := ItemAs(AccountIndex);
    ChartOfAccount.Write(ChartOfAccountData);
  end;
end;

{ TDivisionData }
//------------------------------------------------------------------------------
procedure TDivisionData.Write(const aJson: TlkJSONobject);
begin
  aJson.Add('Id', Id);
  aJson.Add('Name', Name);
end;

//------------------------------------------------------------------------------
{ TDivisionsData }
destructor TDivisionsData.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
function TDivisionsData.ItemAs(aIndex: integer): TDivisionData;
begin
  Result := TDivisionData(Self.Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TDivisionsData.Write(const aJson: TlkJSONobject);
var
  Divisions: TlkJSONlist;
  DivisionIndex : integer;
  Division : TDivisionData;
  DivisionData : TlkJSONobject;
begin
  if self.Count = 0 then
    Exit;

  Divisions := TlkJSONlist.Create;
  aJson.Add('divisions', Divisions);

  for DivisionIndex := 0 to self.Count-1 do
  begin
    DivisionData := TlkJSONobject.Create;
    Divisions.Add(DivisionData);

    Division := ItemAs(DivisionIndex);
    Division.Write(DivisionData);
  end;
end;

{ TBankFeedApplicationData }
//------------------------------------------------------------------------------
procedure TBankFeedApplicationData.Write(const aJson: TlkJSONobject);
begin
  aJson.Add('CountryCode',       CountryCode);
  aJson.Add('CoreClientCode',    CoreClientCode);
  aJson.Add('CoreAccountId',     CoreAccountId);
  aJson.Add('BankAccountNumber', BankAccountNumber);
  aJson.Add('Operation',         Operation);
end;

{ TBankFeedApplicationsData }
//------------------------------------------------------------------------------
function TBankFeedApplicationsData.ItemAs(aIndex: integer): TBankFeedApplicationData;
begin
  Result := TBankFeedApplicationData(Self.Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TBankFeedApplicationsData.Write(const aJson: TlkJSONobject);
var
  BankFeedApps: TlkJSONlist;
  BankFeedAppIndex : integer;
  BankFeedApp : TBankFeedApplicationData;
  BankFeedAppData : TlkJSONobject;
begin
  if self.Count = 0 then
    Exit;

  BankFeedApps := TlkJSONlist.Create;
  aJson.Add('bankfeedapplications', BankFeedApps);

  for BankFeedAppIndex := 0 to self.Count-1 do
  begin
    BankFeedAppData := TlkJSONobject.Create;
    BankFeedApps.Add(BankFeedAppData);

    BankFeedApp := ItemAs(BankFeedAppIndex);
    BankFeedApp.Write(BankFeedAppData);
  end;
end;

{ TPayeeLineData }
//------------------------------------------------------------------------------
procedure TPayeeLineData.Write(const aJson: TlkJSONobject);
begin
  aJson.Add('AccountNumber', fAccountNumber);
  aJson.Add('Percentage', fPercentage);
  aJson.Add('TaxRate', fTaxRate);
  aJson.Add('Narration', fNarration);
  aJson.Add('Amount', fAmount);
end;

{ TPayeeLinesData }
//------------------------------------------------------------------------------
function TPayeeLinesData.ItemAs(aIndex: integer): TPayeeLineData;
begin
  result := TPayeeLineData(Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TPayeeLinesData.Write(const aJson: TlkJSONobject);
var
  Lines: TlkJSONlist;
  i: integer;
  Line: TlkJSONobject;
  LineData: TPayeeLineData;
begin
  if (Count = 0) then
    exit;

  Lines := TlkJSONlist.Create;
  aJson.Add('Lines', Lines);

  for i := 0 to Count-1 do
  begin
    Line := TlkJSONobject.Create;
    Lines.Add(Line);

    LineData := ItemAs(i);
    LineData.Write(Line);
  end;
end;

{ TPayeeData }
//------------------------------------------------------------------------------
constructor TPayeeData.Create(Collection: TCollection);
begin
  inherited;

  fLines := TPayeeLinesData.Create(TPayeeLineData);
end;

//------------------------------------------------------------------------------
destructor TPayeeData.Destroy;
begin
  FreeAndNil(fLines);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TPayeeData.Write(const aJson: TlkJSONobject);
begin
  aJson.Add('PayeeNumber', fPayeeNumber);
  aJson.Add('Inactive', fInactive);
  aJson.Add('ContractorPayee', fContractorPayee);
  aJson.Add('PayeeName', fPayeeName);
  aJson.Add('PayeeSurname', fPayeeSurname);
  aJson.Add('PayeeGivenName', fPayeeGivenName);
  aJson.Add('OtherName', fOtherName);
  aJson.Add('Address', fAddress);
  aJson.Add('Address2', fAddress2);
  aJson.Add('Town', fTown);
  aJson.Add('State', fState);
  aJson.Add('Postcode', fPostcode);
  aJson.Add('Country', fCountry);
  aJson.Add('PhoneNumber', fPhoneNumber);
  aJson.Add('Abn', fABN);
  aJson.Add('BusinessName', fBusinessName);
  aJson.Add('TradingName', fTradingName);
  aJson.Add('BankAccountNumber', fBankAccountNumber);

  fLines.Write(aJson);
end;

{ TPayeesData }
//------------------------------------------------------------------------------
function TPayeesData.ItemAs(aIndex: integer): TPayeeData;
begin
  Result := TPayeeData(Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TPayeesData.Write(const aJson: TlkJSONobject);
var
  Payees: TlkJSONlist;
  i: integer;
  Payee: TlkJSONobject;
  PayeeData: TPayeeData;
begin
  if (Count = 0) then
    exit;

  Payees := TlkJSONlist.Create;
  aJson.Add('payees', Payees);

  for i := 0 to Count-1 do
  begin
    Payee := TlkJSONobject.Create;
    Payees.Add(Payee);

    PayeeData := ItemAs(i);
    PayeeData.Write(Payee);
  end;
end;

{ TJobData }
//------------------------------------------------------------------------------
procedure TJobData.Write(const aJson: TlkJSONobject);
var
  bCompleted: boolean;
begin
  aJson.Add('Code', fCode);
  aJson.Add('Name', fName);
  bCompleted := (fCompleted <> 0);
  aJson.Add('Completed', bCompleted);
end;

{ TJobsData }
//------------------------------------------------------------------------------
function TJobsData.ItemAs(aIndex: integer): TJobData;
begin
  Result := TJobData(Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TJobsData.Write(const aJson: TlkJSONobject);
var
  Jobs: TlkJSONlist;
  i: integer;
  Job: TlkJSONobject;
  JobData: TJobData;
begin
  if (Count = 0) then
    exit;

  Jobs := TlkJSONlist.Create;
  aJson.Add('jobs', Jobs);

  for i := 0 to Count-1 do
  begin
    Job := TlkJSONobject.Create;
    Jobs.Add(Job);

    JobData := ItemAs(i);
    JobData.Write(Job);
  end;
end;

{ TBusinessData }
//------------------------------------------------------------------------------
procedure TBusinessData.Read(const aJson: TlkJSONobject);
begin
  ASSERT(assigned(aJson));

  FID := aJson.getString('id');
  FName := aJson.getString('name');
  FClientCode := '';
  FABN := '';
  FIRD := '';

  if ((aJson.Field['client_code'].SelfType <> jsNull)) then
    FClientCode := aJson.getString('client_code');

  if (Assigned(aJson.Field['abn']) and (aJson.Field['abn'].SelfType <> jsNull)) then
    FABN := aJson.getString('abn');
  FFirmId := aJson.getString('firm_id');
  FVisibility := aJson.getBoolean('visibility');
  if (Assigned(aJson.Field['ird']) and (aJson.Field['ird'].SelfType <> jsNull)) then
    FIRD := aJson.getString('ird');
  if (Assigned(aJson.Field['licence_code'])) and (aJson.Field['licence_code'].SelfType <> jsNull) then
    FLicenseCode := aJson.getString('licence_code');
end;

procedure TBusinessData.Write(const aJson: TlkJSONobject);
begin
  ASSERT(assigned(aJson));

  if (ABN <> '') then
    aJson.Add('Abn', ABN);

  if (IRD <> '') then
    aJson.Add('Ird', IRD);

  aJson.Add('LedgerName', Name);
  aJson.Add('ClientCode', ClientCode);

  if ClientCode <> OrigClientCode then
    aJson.Add('OrigClientCode', OrigClientCode);

  aJson.Add('FinancialYearStartMonth', FinancialYearStartMonth);

  if trim(OpeningBalanceDate) <> '' then
    aJson.Add('OpeningBalanceDate', OpeningBalanceDate);

  aJson.Add('FirmId', FirmId);
end;

{ TClientData }
//------------------------------------------------------------------------------
constructor TClientData.Create;
begin
  fBusinessData := TBusinessData.Create;
  fChartOfAccountsData := TChartOfAccountsData.Create(TChartOfAccountData);
  fDivisionsData := TDivisionsData.Create(TDivisionData);
  fBankAccountsData := TBankAccountsData.Create(TBankAccountData);
  fBankFeedApplicationsData := TBankFeedApplicationsData.Create(TBankFeedApplicationData);

  fJournalsData := TJournalsData.Create();
  fJournalsData.Duplicates := true;

  fPayeesData := TPayeesData.Create(TPayeeData);
  fJobsData := TJobsData.Create(TJobData);
end;

//------------------------------------------------------------------------------
destructor TClientData.Destroy;
begin
  FreeAndNil(fBankFeedApplicationsData);
  FreeAndNil(fBusinessData);
  FreeAndNil(fChartOfAccountsData);
  FreeAndNil(fDivisionsData);
  FreeAndNil(fBankAccountsData);
  FreeAndNil(fJournalsData);
  FreeAndNil(fPayeesData);
  FreeAndNil(fJobsData);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TClientData.Write(const aJson: TlkJSONobject; aSelectedData: TSelectedData);
var
  JsonBusiness : TlkJSONobject;
begin
  // Business data, create the ledger on cashbook
  JsonBusiness := TlkJSONobject.Create;
  aJson.Add('ledger', JsonBusiness);
  BusinessData.Write(JsonBusiness);

  BankFeedApplicationsData.Write(aJson);

  ChartOfAccountsData.Write(aJson);

  DivisionsData.Write(aJson);

  if aSelectedData.NonTransferedTransactions then
  begin
    BankAccountsData.Write(aJson);

    JournalsData.Write(aJson);
  end;

  PayeesData.Write(aJson);

  JobsData.Write(aJson);
end;

{ TClientBase }
//------------------------------------------------------------------------------
constructor TClientBase.Create;
begin
  fClientData := TClientData.Create;
end;

//------------------------------------------------------------------------------
destructor TClientBase.Destroy;
begin
  FreeAndNil(fClientData);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TClientBase.Write(const aJson: TlkJSONobject; aSelectedData: TSelectedData);
var
  JsonClientData : TlkJSONobject;
begin
  aJson.Add('Token', Token);

  // Client data
  JsonClientData := TlkJSONobject.Create;
  aJson.Add('Data', JsonClientData);
  ClientData.Write(JsonClientData, aSelectedData);
end;

//------------------------------------------------------------------------------
function TClientBase.GetData(aSelectedData: TSelectedData): string;
var
  Json: TlkJSONobject;
begin
  Json := nil;
  try
    // Write Json
    Json := TlkJSONobject.Create;
    Write(Json, aSelectedData);

    // Jason to text
    result := FixJsonString(TlkJSON.GenerateText(Json));

  finally
    FreeAndNil(Json);
  end;
end;

{ TFile }
//------------------------------------------------------------------------------
constructor TFile.Create;
var
  NewID: TGUID;
begin
  CreateGUID(NewID);
  fID := TrimedGuid(NewID);
end;

//------------------------------------------------------------------------------
function TFile.GetFileHash: string;
begin
  result := Lowercase(HashStr(fData, false));
end;

//------------------------------------------------------------------------------
function TFile.GetDataAsZipBase64: string;
begin
  result := GZCompressStr(fData);

  result := EncodeString(TidEncoderMIME, result);
end;

//------------------------------------------------------------------------------
procedure TFile.Write(const aJson: TlkJSONobject);
var
  iDataLength: integer;
  sData: string;
begin
  aJson.Add('Id', fId);

  aJson.Add('FileName', fFileName);

  aJson.Add('FileHash', GetFileHash);

  sData := GetDataAsZipBase64;

  iDataLength := Length(fData);

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, 'Business Data Original Size : ' + inttostr(Length(fData)) +
                                      ', Zipped and Base64 Size : ' + inttostr(Length(sData)) +
                                      ', Size Change : ' + inttostr(trunc((Length(sData)/Length(fData))*100)) + '%' +
                                      ' of the Original Size.');

  aJson.Add('DataLength', iDataLength);

  aJson.Add('Data', sData);
end;

{ TParameters }
//------------------------------------------------------------------------------
procedure TParameters.Write(const aJson: TlkJSONlist);
var
  Parameter: TlkJSONobject;
begin
  // DataStore
  Parameter := TlkJSONobject.Create;
  aJson.Add(Parameter);
  Parameter.Add('Key', 'DataStore');
  Parameter.Add('Value', fDataStore);

  // Queue
  Parameter := TlkJSONobject.Create;
  aJson.Add(Parameter);
  Parameter.Add('Key', 'Queue');
  Parameter.Add('Value', fQueue);

  // Region
  Parameter := TlkJSONobject.Create;
  aJson.Add(Parameter);
  Parameter.Add('Key', 'Region');
  Parameter.Add('Value', fRegion);

  // BLIdentity
  Parameter := TlkJSONobject.Create;
  aJson.Add(Parameter);
  Parameter.Add('Key', 'BLIdentity');
  Parameter.Add('Value', fBLIdentity);
end;

{ TFileUpload }
//------------------------------------------------------------------------------
constructor TMigrationUpload.Create;
var
  NewID: TGUID;
begin
  CreateGUID(NewID);
  fID := TrimedGuid(NewID);

  fUploadType := 7;

  fFile := TFile.Create;

  fParameters := TParameters.Create;
end;

//------------------------------------------------------------------------------
destructor TMigrationUpload.Destroy;
begin
  FreeAndNil(fFile);
  FreeAndNil(fParameters);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TMigrationUpload.Write(const aJson: TlkJSONobject);
var
  Files: TlkJSONlist;
  NewFile: TlkJSONobject;
  Parameters: TlkJSONlist;
begin
  aJson.Add('Id', fID);

  aJson.Add('UploadType', fUploadType);

  // File
  Files := TlkJSONlist.Create;
  aJson.Add('Files', Files);
  NewFile := TlkJSONobject.Create;
  Files.Add(NewFile);
  fFile.Write(NewFile);

  // Parameters
  Parameters := TlkJSONlist.Create;
  aJson.Add('Parameters', Parameters);
  fParameters.Write(Parameters);
end;

{ TUrlsMap }
//------------------------------------------------------------------------------
procedure TUrlsMap.Read(const aJson: TlkJSONobject);
begin
  fName := aJson.NameOf[0];

  fValue := aJson.getString(0);
end;

{ TFileUploadResult }
//------------------------------------------------------------------------------
constructor TMigrationUploadResponse.Create;
begin
  fUrlsMap := TUrlsMap.Create;
end;

//------------------------------------------------------------------------------
destructor TMigrationUploadResponse.Destroy;
begin
  FreeAndNil(fUrlsMap);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TMigrationUploadResponse.Read(const aJson: TlkJSONobject);
var
  UrlsMap: TlkJSONobject;
begin
  fUploadId := aJson.getString('UploadId');

  fResponseCode := aJson.getInt('ResponseCode');

  if fResponseCode = UPLOAD_RESP_SUCESS then
  begin
    UrlsMap := (aJson.Field['UrlsMap'] as TlkJSONobject);
    fUrlsMap.Read(UrlsMap);
  end;
end;

//------------------------------------------------------------------------------


{ TBusinesses }

function TBusinesses.GetItem(aIndex: integer): TBusinessData;
begin
  Result := TBusinessData(Self.Items[aIndex]);
end;

function TBusinesses.GetItem(aBusinessID: string): TBusinessData;
var
  i : Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    if (TBusinessData(Items[i]).ID = aBusinessID) then
    begin
      Result := TBusinessData(Items[i]);
      Exit;
    end;
  end;
end;

function TBusinesses.IsValidJSON(aJSON: TlkJSONobject; aFirmId, aLicense : string): Boolean;
begin
  Result := False;

  if not Assigned(aJSON) then
    Exit;

  if not (Assigned(aJSON.Field['id']) and
     Assigned(aJSON.Field['name']) and
     Assigned(aJSON.Field['firm_id']) and
     Assigned(aJSON.Field['licence_code']) and
     Assigned(aJSON.Field['visibility']) and
     Assigned(aJSON.Field['client_code'])) then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, 'Missing fields in Business data received from API');
    Exit;
  end;

  try
    if ((Trim(aJSON.getString('id')) = '') or
        (Trim(aJSON.getString('name')) = '') or
        (Trim(aJSON.getString('firm_id')) = '') or
        (Trim(aJSON.getString('client_code')) = '') or
        (Trim(aJSON.getString('licence_code')) = '')) then
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, 'Missing fields in Business data received from API');
      Exit;
    end;

    if ((Trim(aJSON.getString('firm_id')) <> aFirmId) or
        (not aJson.getBoolean('visibility')) or
        (Pos(aLicense, Trim(aJSON.getString('licence_code'))) <= 0)
        ) then
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, Trim(aJSON.getString('name')) + ' is filtered out after validating Firm_ID/Visibility/License_Code');
      Exit;
    end;
  except
    Exit;
  end;

  Result := True;
end;

procedure TBusinesses.Read(aFirmID: string;LicenseType: TLicenceType; const aJson: TlkJSONObject);
var
  i: integer;
  Child: TlkJSONobject;
  Field : TlkJSONlist;
  Business: TBusinessData;
  LicenseTypeStr : string;
begin
  Clear;

  ASSERT(assigned(aJson));

  if Trim(aFirmID) = '' then
    Exit;

  Field := aJson.Field['businesses'] as TlkJsonList;

  if not Assigned(Field) then
    Exit;

  case LicenseType of
    ltCashbook : LicenseTypeStr := 'CB';
    ltPracticeLedger : LicenseTypeStr := 'PL';
  end;

  for i := 0 to Field.Count-1 do
  begin
    Child := Field.Child[i] as TlkJSONobject;

    if IsValidJSON(Child, aFirmID, LicenseTypeStr) then
    begin
      // New business
      Business:= TBusinessData.Create;
      // Read business
      Business.Read(Child);

      Add(Business);
    end
    else
      LogUtil.LogMsg(lmInfo , UnitName, 'GET Businesses API retrieved some invalid data');
  end;

  Self.Sort(CompareNames);
end;

procedure TLinesData.Write(const aJson: TlkJSONobject; FromIndex,
  ItemCount: Integer);
var
  Lines: TlkJSONlist;
  i, ToIndex : integer;
  Line : TLineData;
  LineData : TlkJSONobject;
begin
  if Self.Count = 0 then
    Exit;

  // this write function is used for direct api write.
  if Self.Count = 0 then
    Exit;

  if FromIndex > Count then
    Exit;

  if FromIndex + ItemCount > Count then
    ToIndex := Count
  else
    ToIndex := FromIndex + ItemCount;

  Lines := TlkJSONlist.Create;
  aJson.Add('lines', Lines);

  for i := FromIndex to ToIndex-1 do
  begin
    LineData := TlkJSONobject.Create;
    Lines.Add(LineData);

    Line := ItemAs(i);
    Line.Write(LineData, True);
  end;
end;

{ TPracticeLedgerChartOfAccountsData }

procedure TPracticeLedgerChartOfAccountsData.Read(aBusinessID: string;
  const aJson: TlkJSONobject);
begin
  inherited Read( aBusinessID, aJson, tcoaPracticeLedger );
end;

initialization
begin
  DebugMe := DebugUnit(UnitName);
end;

end.
