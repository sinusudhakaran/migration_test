unit CashbookMigrationRestData;

interface

uses
  Windows,
  SysUtils,
  Classes,
  ecollect,
  uLkJSON;

const
  UPLOAD_RESP_ERROR = -1;
  UPLOAD_RESP_UKNOWN = 0;
  UPLOAD_RESP_SUCESS = 1;
  UPLOAD_RESP_DUPLICATE = 2;
  UPLOAD_RESP_CORUPT = 3;

type
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
    fID: string;
    fName: string;

  public
    procedure Read(const aJson: TlkJSONobject);

    property  ID: string read fID write fID;
    property  Name: string read fName write fName;
  end;

  //----------------------------------------------------------------------------
  TFirms = class(TListDestroy)
  public
    function  GetItem(const aIndex: integer): TFirm;
    property  Items[const aIndex: integer]: TFirm read GetItem; default;

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
    procedure Write(const aJson: TlkJSONobject);

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

    procedure Write(const aJson: TlkJSONobject);
  end;

  //----------------------------------------------------------------------------
  TJournalData = class(TObject)
  private
    fDate        : string;
    fDescription : string;
    fReference   : string;

    fLines : TLinesData;
  public
    constructor Create(); reintroduce; overload;
    destructor Destroy; override;

    procedure Write(const aJson: TlkJSONobject);

    property Date : string read fDate write fDate;
    property Description : string read fDescription write fDescription;
    property Reference : string read fReference write fReference;

    property Lines : TLinesData read fLines write fLines;
  end;

  //----------------------------------------------------------------------------
  pJournalData = ^TJournalData;

  //----------------------------------------------------------------------------
  TJournalsData = class(TExtdSortedCollection)
  private
  protected
    procedure FreeItem( Item : Pointer ); override;
  public
    destructor Destroy; override;

    function Compare(aItem1, aItem2 : Pointer): Integer; override;
    function ItemAs(aItem : Pointer) : TJournalData;

    procedure Write(const aJson: TlkJSONobject);
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
    procedure Write(const aJson: TlkJSONobject; aTransAmount : integer);

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

    procedure Write(const aJson: TlkJSONobject; aTransAmount : integer);

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
  public
    constructor Create(Collection: TCollection); override;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject);

    property Date : string read fDate write fDate;
    property Description : string read fDescription write fDescription;
    property Reference : string read fReference write fReference;
    property Amount : integer read fAmount write fAmount;
    property CoreTransactionId : string read fCoreTransactionId write fCoreTransactionId;
    property Quantity: comp read fQuantity write fQuantity;
    property PayeeNumber: integer read fPayeeNumber write fPayeeNumber;
    property JobCode: string read fJobCode write fJobCode;

    property Allocations : TAllocationsData read fAllocations write fAllocations;
  end;

  //----------------------------------------------------------------------------
  TTransactionsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TTransactionData;

    procedure Write(const aJson: TlkJSONobject);

    function  PayeeExists(const aPayeeNumber: integer): boolean;
    function  JobExists(const aJobCode: string): boolean;
  end;

  //----------------------------------------------------------------------------
  TBankAccountData = class(TCollectionItem)
  private
    fBankAccountNumber : string;

    fTransactions : TTransactionsData;
  public
    constructor Create(Collection: TCollection); override;
    destructor  Destroy; override;

    procedure Write(const aJson: TlkJSONobject);

    property BankAccountNumber : string read fBankAccountNumber write fBankAccountNumber;
    property Transactions : TTransactionsData read fTransactions write fTransactions;
  end;

  //----------------------------------------------------------------------------
  TBankAccountsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TBankAccountData;

    procedure Write(const aJson: TlkJSONobject);

    function  PayeeExists(const aPayeeNumber: integer): boolean;
    function  JobExists(const aJobCode: string): boolean;
  end;

  //----------------------------------------------------------------------------
  TChartOfAccountData = class(TCollectionItem)
  private
    fCode : string;
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
  public
    procedure Write(const aJson: TlkJSONobject);

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
  end;

  //----------------------------------------------------------------------------
  TChartOfAccountsData = class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TChartOfAccountData;

    function FindCode(aChartCode : string; var aChartOfAccountItem : TChartOfAccountData) : boolean;

    procedure Write(const aJson: TlkJSONobject);
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

  public
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
    fABN : string;
    fIRD : string;
    fName : string;
    fClientCode : string;
    fOrigClientCode : string;
    fFinancialYearStartMonth : integer;
    fOpeningBalanceDate : string;
    fFirmId : string;
  public
    procedure Write(const aJson: TlkJSONobject);

    property  ABN : string read fABN write fABN;
    property  IRD : string read fIRD write fIRD;
    property  Name : string read fName write fName;
    property  ClientCode : string read fClientCode write fClientCode;
    property  OrigClientCode : string read fOrigClientCode write fOrigClientCode;
    property  FinancialYearStartMonth : integer read fFinancialYearStartMonth write fFinancialYearStartMonth;
    property  OpeningBalanceDate : string read fOpeningBalanceDate write fOpeningBalanceDate;
    property  FirmId : string read fFirmId write fFirmId;
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
  ZipUtils;

const
  UnitName = 'CashbookMigrationRestData';

var
  DebugMe : boolean = false;

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
begin
  ASSERT(assigned(aJson));

  ID := aJson.getString('id');
  Name := aJson.getString('name');
end;

{ TFirms }
//------------------------------------------------------------------------------
function TFirms.GetItem(const aIndex: integer): TFirm;
begin
  result := TFirm(Get(aIndex));
end;

//------------------------------------------------------------------------------
procedure TFirms.Read(const aJson: TlkJSONlist);
var
  i: integer;
  Child: TlkJSONobject;
  Firm: TFirm;
begin
  ASSERT(assigned(aJson));

  for i := 0 to aJson.Count-1 do
  begin
    Child := aJson.Child[i] as TlkJSONobject;

    // New firm
    Firm := TFirm.Create;
    Add(Firm);

    // Read firm
    Firm.Read(Child);
  end;
end;

{ TLineData }
//------------------------------------------------------------------------------
procedure TLineData.Write(const aJson: TlkJSONobject);
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
  FreeAndNil(fLines);

  inherited;
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
  if TJournalData(aItem1^).Date < TJournalData(aItem2^).Date then
    result := -1
  else if TJournalData(aItem1^).Date > TJournalData(aItem2^).Date then
    result := 1
  else
    result := 0;
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
procedure TAllocationData.Write(const aJson: TlkJSONobject; aTransAmount : integer);
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

{ TAllocationsData }
//------------------------------------------------------------------------------
function TAllocationsData.ItemAs(aIndex: integer): TAllocationData;
begin
  Result := TAllocationData(Self.Items[aIndex]);
end;

//------------------------------------------------------------------------------
procedure TAllocationsData.Write(const aJson: TlkJSONobject; aTransAmount : integer);
var
  Allocations: TlkJSONlist;
  AllocationIndex : integer;
  Allocation : TAllocationData;
  AllocationData : TlkJSONobject;
begin
  if self.Count = 0 then
    Exit;

  Allocations := TlkJSONlist.Create;
  aJson.Add('Allocations', Allocations);

  for AllocationIndex := 0 to self.Count-1 do
  begin
    AllocationData := TlkJSONobject.Create;
    Allocations.Add(AllocationData);

    Allocation := ItemAs(AllocationIndex);
    Allocation.Write(AllocationData, aTransAmount);
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
  FreeAndNil(fAllocations);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TTransactionData.Write(const aJson: TlkJSONobject);
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
  fTransactions := TTransactionsData.Create(TTransactionData);
end;

//------------------------------------------------------------------------------
destructor TBankAccountData.Destroy;
begin
  FreeAndNil(fTransactions);
  inherited;
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
function TChartOfAccountsData.ItemAs(aIndex: integer): TChartOfAccountData;
begin
  Result := TChartOfAccountData(Self.Items[aIndex]);
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

{ TPayeeData }
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
  aJson.Add('Town', fTown);
  aJson.Add('State', fState);
  aJson.Add('Postcode', fPostcode);
  aJson.Add('PhoneNumber', fPhoneNumber);
  aJson.Add('Abn', fABN);
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
initialization
begin
  DebugMe := DebugUnit(UnitName);
end;

end.
