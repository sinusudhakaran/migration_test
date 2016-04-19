unit BankLinkOnlineServices;

//------------------------------------------------------------------------------
interface

uses
  Forms,
  BlopiServiceFacade,
  InvokeRegistry,
  Windows,
  XMLIntf,
  TypInfo,
  Classes,
  ComCtrls,
  clObj32,
  baObj32,
  SysUtils,
  SOAPHTTPClient,
  SOAPHTTPTrans,
  P5Auth,
  OnlinePasswordFrm;

type
  TBloStatus                = BlopiServiceFacade.Status;
  TBloArrayOfString         = BlopiServiceFacade.ArrayOfString;

  TBloGuid                  = BlopiServiceFacade.Guid;
  TBloArrayOfGuid           = BlopiServiceFacade.ArrayOfGuid;

  TBloCatalogueEntry        = BlopiServiceFacade.CatalogueEntry;
  TBloArrayOfCatalogueEntry = BlopiServiceFacade.ArrayOfCatalogueEntry;

  TBloPracticeRead          = BlopiServiceFacade.PracticeRead;

  TBloClient                = BlopiServiceFacade.Client;
  TBloClientCreate          = BlopiServiceFacade.ClientCreate;
  TBloClientUpdate          = BlopiServiceFacade.ClientUpdate;
  TBloClientReadDetail      = BlopiServiceFacade.ClientReadDetail;

  TBloUserCreate            = BlopiServiceFacade.UserCreate;
  TBloUserCreatePractice    = BlopiServiceFacade.UserCreatePractice;
  TBloUserUpdate            = BlopiServiceFacade.UserUpdate;
  TBloUserUpdatePractice    = BlopiServiceFacade.UserUpdatePractice;
  TBloUserRead              = BlopiServiceFacade.UserRead;
  TBloArrayOfUserRead       = BlopiServiceFacade.ArrayOfUserRead;

  TBloDataPlatformSubscription       = BlopiServiceFacade.DataPlatformSubscription;
  TBloArrayOfDataPlatformSubscriber  = BlopiServiceFacade.ArrayOfDataPlatformSubscriber;
  TBloArrayOfDataPlatformBankAccount = BlopiServiceFacade.ArrayOfDataPlatformBankAccount;
  TBloDataPlatformBankAccount        = BlopiServiceFacade.DataPlatformBankAccount;
  TBloDataPlatformSubscriber         = BlopiServiceFacade.DataPlatformSubscriber;
  TBloIBizzCredentials               = BlopiServiceFacade.PracticeDataSubscriberCredentials;
  TBloArrayOfPracticeDataSubscriberCount = BlopiServiceFacade.ArrayOfPracticeDataSubscriberCount;

  TBloInstitution              = BlopiServiceFacade.Institution;
  TBloArrayOfInstitution       = BlopiServiceFacade.ArrayOfInstitution;
  TBloAccountValidation        = BlopiServiceFacade.AccountValidation;
  TBloArrayOfAccountValidation = BlopiServiceFacade.ArrayOfAccountValidation;
  TBloPracticeUpgradeReminder  = BlopiServiceFacade.PracticeUpgradeReminder;

  TBloArrayOfRemotable = Array of TRemotable;

  TBloArrayOfPracticeBankAccount = BlopiServiceFacade.ArrayOfPracticeBankAccount;

  TBloUploadResult = BlopiServiceFacade.UploadResult;

  TBloUploadResultCode = (Success, NoFileReceived, InvalidCredentials, InternalError, FileFormatError);

  TServiceStatus = (ssActive, ssSuspended, ssDisabled);

  TAccountVendors = record
    AccountVendors : TBloDataPlatformSubscription;
    IsLastAccForVendors : Array of Boolean;
    ExportDataEnabled : Boolean;
    ClientNeedRefresh : Boolean;
    AccountID: Integer;
  end;

  TClientAccVendors = record
    ClientID     : TBloGuid;
    ClientCode   : WideString;
    ClientVendors : TBloArrayOfDataPlatformSubscriber;
    AccountsVendors : Array of TAccountVendors;
  end;

  TVarTypeData = record
    Name     : String;
    TypeInfo : PTypeInfo;
  end;

  EAuthenticationException = Exception;

  TArrVarTypeData = Array of TVarTypeData;

  TAuthenticationStatus = (paNone, paConnectionError, paOffLineUser, paChangePassword);

  TBloResult = (bloSuccess, bloFailedNonFatal, bloFailedFatal);

  TUserDetailHelper = class helper for BlopiServiceFacade.User
  public
    function AddRoleName(RoleName: string) : Boolean;
    function IsPracticeAdministrator: Boolean;
    function HasRoles(const RoleList: array of String): Boolean;
  end;
                            
  TClientBaseHelper = class helper for BlopiServiceFacade.Client
  private
    function GetStatusString: string;
  public
    function AddSubscription(AProductID: TBloGuid) : Boolean;
    function RemoveSubscription(AProductID: TBloGuid) : Boolean;
    function HasSubscription(AProductID: TBloGuid) : Boolean;
    property StatusString: string read GetStatusString;
  end;

  TClientHelper = Class helper for BlopiServiceFacade.ClientReadDetail
  private
    function GetDeactivated: boolean;
    function GetClientConnectDays: string;
    function GetFreeTrialEndDate: TDateTime;
    function GetBillingEndDate: TDateTime;
    function GetUserOnTrial: boolean;
    function GetSuspended: boolean;
  public
    procedure UpdateAdminUser(AUserName, AEmail: WideString);
    function GetPrimaryUser: TBloUserRead;
    function FindUser(const EmailAddress: String): TBloUserRead;
    property Deactivated: boolean read GetDeactivated;
    property ClientConnectDays: string read GetClientConnectDays; // 0 if client must always be online
    property FreeTrialEndDate: TDateTime read GetFreeTrialEndDate;
    property BillingEndDate: TDateTime read GetBillingEndDate;
    property UserOnTrial: boolean read GetUserOnTrial;
    property Suspended: boolean read GetSuspended;
  End;

  TClientListHelper = class helper for ClientList
  public
    function GetClientGuid(const ClientCode: WideString): TBloGuid;
  end;

  TPracticeHelper = Class helper for PracticeRead
  private
    function GetUserRoleGuidFromPracUserType(aUstNameIndex : integer; aInstance: PracticeRead) : Guid;

    function GetRoleName(RoleIndex: Integer): String;
  public
    function GetRoleFromPracUserType(aUstNameIndex : integer; aInstance: PracticeRead) : Role;

    function GetUserRoleNameFromPracUserType(aUstNameIndex : integer) : String;

    function CheckUserRolesEqual(PracticeRole: Integer; User: TBloUserRead): Boolean;

    function IsEqual(Instance: PracticeRead): Boolean;

    function FindUser(const EmailAddress: String): TBloUserRead;
    function FindUserByCode(const UserCode: String): TBloUserRead;
  End;

  TProductConfigService = class(TObject)
  private
    FPractice, FPracticeCopy: TBloPracticeRead;
    FClientList: ClientList;
    FOnLine: Boolean;
    FRegistered: Boolean;
    FValidBConnectDetails: Boolean;

    FSubDomain: String;
    FExceptionRaised: Boolean;

    procedure HandleException(const MethodName: String; E: Exception; SuppressErrors: Boolean = False);

    procedure SynchronizeClientSettings(BlopiClient: TBloClientReadDetail);


    function IsUserCreatedOnBankLinkOnline(const APractice : TBloPracticeRead;
                                           const AUserId   : TBloGuid   = '';
                                           const AUserCode : string = ''): Boolean;

    function RemotableObjectToXML(ARemotable: TRemotable): string;
    procedure LoadRemotableObjectFromXML(const XML: string; ARemotable: TRemotable);
    procedure SaveRemotableObjectToFile(ARemotable: TRemotable);
    function LoadRemotableObjectFromFile(ARemotable: TRemotable): Boolean;
    function GetTypeItemIndex(var aDataArray: TArrVarTypeData;
                              const aName : String) : integer;
    procedure AddTypeItem(var aDataArray : TArrVarTypeData;
                          var aDataItem  : TVarTypeData);
    procedure AddToXMLTypeNameList(const aName : String;
                                   aTypeInfo : PTypeInfo;
                                   var aNameList : TArrVarTypeData);
    procedure FindXMLTypeNamesToModify(const aMethodName : String;
                                       var aNameList : TArrVarTypeData);
    procedure MaskCreditCardForLogs(const aCurrNode : IXMLNode);
    procedure AddXMLNStoArrays(const aCurrNode : IXMLNode;
                               var aNameList : TArrVarTypeData);
    procedure DoBeforeExecute(const MethodName: string;
                              var SOAPRequest: InvString);

    procedure DoAfterSecureExecute(const MethodName: string; SOAPResponse: TStream);

    procedure CreateXMLError(Document: IXMLDocument; const MethodName, ErrorCode, ErrorMessage: String);

    procedure SetTimeOuts(ConnecTimeout : DWord ;
                          SendTimeout   : DWord ;
                          ReciveTimeout : DWord);
    function GetServiceFacade(PracticeCode: string = '') : IBlopiServiceFacade;
    function GetSecureServiceFacade : IBlopiSecureServiceFacade; overload;
    function GetSecureServiceFacade(out HTTPRIO: THTTPRIO) : IBlopiSecureServiceFacade; overload;
    function GetAuthenticationServiceFacade : IP5Auth;

    function GetBanklinkOnlineURL(Service: string): String;

    function GetCachedPractice: TBloPracticeRead;
    function MessageResponseHasError(AMesageresponse: MessageResponse; ErrorText: string;
                                     SimpleError: boolean = false; ContextMsgInt: integer = 0;
                                     ContextErrorCode: string = ''; ReportResponseErrors: Boolean = True): Boolean;

    function GetProducts : TBloArrayOfGuid;
    function GetRegistered: Boolean;
    function GetValidBConnectDetails: Boolean;
    procedure RemoveInvalidSubscriptions;
    procedure ShowSuspendDeactiveWarning;

    // Client methods
    function CreateClientUser(const aClientId     : TBloGuid;
                              const aEMail        : WideString;
                              const aFullName     : WideString;
                              const aRoleNames    : TBloArrayOfString;
                              const aSubscription : TBloArrayOfGuid;
                              const aUserCode     : WideString;
                              out UserId: TBloGuid): Boolean;

    function UpdateClientUser(const aClientId     : TBloGuid;
                              const aId           : TBloGuid;
                              const aFullName     : WideString;
                              const aRoleNames    : TBloArrayOfString;
                              const aSubscription : TBloArrayOfGuid;
                              const aUserCode     : WideString;
                              const ErrorHandlerMessage: String): Boolean;

    function AddEditClientUser(const aExistingClient : TBloClientReadDetail;
                               const aClientSubscription : TBloArrayOfGuid;
                               aNewClientId    : TBloGuid;
                               aClientCode     : String;
                               var   aUserId   : TBloGuid;
                               const aEMail    : WideString;
                               const aFullName : WideString) : Boolean; overload;

    function CheckClientUser(Client              : TBloClientReadDetail;
                             const EMail         : WideString;
                             const FullName      : WideString;
                             var   UserId        : TBloGuid;
                             const aSubscription : TBloArrayOfGuid) : Boolean; overload;

    function AddClientUser(ClientId             : TBloGuid;
                           const UserCode       : String;
                           const EMailAddress   : WideString;
                           const FullName       : WideString;
                           const aSubscriptions : TBloArrayOfguid;
                           var   UserId         : TBloGuid): Boolean;

    procedure FillInClientDetails(var aBloClientCreate: TBloClientCreate);

    // Practice User methods
    function UpdatePracticeUserPass(const aUserId      : TBloGuid;
                                    const aUserCode    : WideString;
                                    const aOldPassword : WideString;
                                    const aNewPassword : WideString;
                                    const UserEmail    : WideString;
                                    const ErrorHandlerMessage: String) : Boolean;

    function CreatePracticeUser(const aEmail        : WideString;
                                const aFullName     : WideString;
                                const aUserCode     : WideString;
                                const aRoleNames    : TBloArrayOfstring;
                                const aSubscription : TBloArrayOfguid;
                                const aPassword     : WideString;
                                const ErrorHandlerMessage: String) : Guid;

    function UpdatePracticeUser(const aUserId       : TBloGuid;
                                const aFullName     : WideString;
                                const aUserCode     : WideString;
                                const aRoleNames    : TBloArrayOfstring;
                                const aSubscription : TBloArrayOfguid;
                                const Password      : WideString;
                                const ErrorHandlerMessage: String) : Boolean;

    function DeleteUser(const aUserId      : TBloGuid;
                        const aUserCode    : WideString;
                        const ErrorHandlerMessage: String) : Boolean;

    function IsVendorInPractice(aAvailableServiceArray : TBloArrayOfDataPlatformSubscriber;
                                aVendorGuid : TBloGuid) : Boolean;
    function GetVendorsHidingNonPractice(aAvailableServiceArray : TBloArrayOfDataPlatformSubscriber;
                                         aSubscribers : TBloArrayOfDataPlatformSubscriber) : TBloArrayOfDataPlatformSubscriber;

    function CheckAuthentication(ServiceResponse: MessageResponse): Boolean;
    function ReAuthenticateUser(out Cancelled, OfflineAuthentication: Boolean; IgnoreOnlineStatus: Boolean = False): Boolean;
    function GetServiceStatus: TServiceStatus;
    function GetServiceActive: Boolean;
    function GetServiceSuspended: Boolean;
    function ErrorOccurred: Boolean;
    function GetBankLinkOnlinePracticeURL : string;
  public
    procedure FreeClientAccVendorsRecord(aClientAccVendors : TClientAccVendors);

    procedure CopyRemotableObject(ASource, ATarget: TRemotable); overload;
    procedure CopyRemotableObject(ASource, ATarget: TBloArrayOfRemotable); overload;

    function IsExportDataEnabled : Boolean;
    function IsExportDataEnabledFoAccount(const aBankAcct : TBank_Account) : Boolean;

    function IsItemInArrayString(const aBloArrayOfString : TBloArrayOfString;
                                 const aItem : WideString) : Boolean;
    function GetItemIndexInArrayString(const aBloArrayOfString : TBloArrayOfString;
                                       const aItem : WideString) : Integer;
    function AddItemToArrayString(var aBloArrayOfString : TBloArrayOfString;
                                  aItem : WideString) : Boolean;
    function RemoveItemFromArrayString(var aBloArrayOfString : TBloArrayOfString;
                                       aItem : WideString) : Boolean;


    function IsItemInArrayGuid(const aBloArrayOfGuid : TBloArrayOfGuid;
                               const aItem : TBloGuid) : Boolean;
    function GetItemIndexInArrayGuid(const aBloArrayOfGuid : TBloArrayOfGuid;
                                     const aItem : TBloGuid) : Integer;
    function AddItemToArrayGuid(var aBloArrayOfGuid : TBloArrayOfGuid;
                                aItem : TBloGuid) : Boolean;
    function RemoveItemFromArrayGuid(var aBloArrayOfGuid : TBloArrayOfGuid;
                                     aItem : TBloGuid) : Boolean;
    function CheckGuidArrayEquality(GuidArray1, GuidArray2: TBloArrayOfGuid): boolean;
    function GetClientGuid(const AClientCode: string): WideString; overload;


    destructor Destroy; override;
    //Practice methods
    function GetPractice(aUpdateUseOnline: Boolean = True; aForceOnlineCall : Boolean = false; PracticeCode: string = ''; AllowProgressBar: Boolean = True; SuppressErrors: Boolean = False): TBloPracticeRead;
    function IsPracticeActive(aShowWarning: Boolean = true): Boolean;
    function IsPracticeDeactivated(aShowWarning: Boolean = true): boolean;
    function IsPracticeSuspended(aShowWarning: Boolean = true): boolean;
    function GetCatalogueEntry(AProductId: TBloGuid): TBloCatalogueEntry;
    function IsPracticeProductEnabled(AProductId: TBloGuid; AUsePracCopy : Boolean): Boolean;
    function HasProductJustBeenUnTicked(AProductId: TBloGuid): Boolean;
    function HasProductJustBeenTicked(AProductId: TBloGuid): Boolean;

    function GetNotesId : TBloGuid;
    function IsNotesOnlineEnabled: Boolean;
    function IsCICOEnabled: Boolean;
    procedure UpdateUserAllowOnlineSetting;
    function SavePractice(aShowMessage : Boolean; ShowSuccessMessage: Boolean = True): Boolean;
    function PracticeChanged: Boolean;
    procedure AddProduct(AProductId: TBloGuid);
    procedure ClearAllProducts;
    function OnlineStatus: TBloStatus;
    function RemoveProduct(AProductId: TBloGuid; ShowClientWarning: boolean = True): string;
    procedure SelectAllProducts;

    procedure SetPrimaryContact(AUser: TBloUserRead);
    function GetPrimaryContact(AUsePracCopy: Boolean): TBloUserRead;

    function GetCatFromSub(aSubGuid : Guid): CatalogueEntry;
    property CachedPractice: PracticeRead read GetCachedPractice;
    function GetServiceAgreementVersion(): WideString;
    function GetServiceAgreement() : WideString;
    procedure SavePracticeDetailsToSystemDB(ARemotable: TRemotable);
    function VendorEnabledForPractice(ClientVendorGuid: TBloGuid): boolean;

    //Client methods
    function CreateNewClientWithUser(aNewClient: TBloClientCreate; aNewUserCreate: TBloUserCreate): TBloClientReadDetail;
    procedure LoadClientList(PracticeCode: string = '');
    function GetClientDetailsWithCode(AClientCode: string; SynchronizeBlopi: Boolean = False): TBloClientReadDetail;
    function GetClientDetailsWithGUID(AClientGuid: Guid; SynchronizeBlopi: Boolean = False): TBloClientReadDetail;
    function CreateNewClient(ANewClient: TBloClientCreate): Guid;
    function CreateNewClientUser(NewUser: TBloUserCreate; ClientGUID: string): Guid;
    procedure UpdateClientStatus(var ClientReadDetail: TBloClientReadDetail; const ClientCode: WideString);
    property Clients: ClientList read FClientList;

    function GetOnlineClientIndex(aClientCode: string) : Integer;
    function SaveClientNotesOption(aWebExportFormat : Byte) : Boolean;
    function CreateClient(const aBillingFrequency : WideString;
                                aMaxOfflineDays   : Integer;
                                aStatus           : TBloStatus;
                          const aSubscription     : TBloArrayOfguid;
                          const aUserEMail        : WideString;
                          const aUserFullName     : WideString;
                          var ClientID            : TBloGuid) : Boolean;
    function UpdateClient(const aExistingClient       : TBloClientReadDetail;
                          const aBillingFrequency     : WideString;
                                aMaxOfflineDays       : Integer;
                                aStatus               : TBloStatus;
                          const aSubscription         : TBloArrayOfGuid;
                          const aUserEMail            : WideString;
                          const aUserFullName         : WideString;
                          aShowUpdateSuccess  : Boolean = true): Boolean;
    function DeleteClient(const aExistingClient : TBloClientReadDetail): Boolean;

    //User methods
    function GetUnLinkedOnlineUsers(aPractice : TBloPracticeRead = nil) : TBloArrayOfUserRead;
    function GetOnlineUserLinkedToCode(aUserCode : String; aPractice: TBloPracticeRead = Nil; ShowProgress: Boolean = True) : TBloUserRead;

    function AddEditPracUser(var   aUserId         : TBloGuid;
                             const aEMail          : WideString;
                             const aFullName       : WideString;
                             const aUserCode       : WideString;
                             const aUstNameIndex   : integer;
                             var   aIsUserCreated  : Boolean;
                             const aChangePassword : Boolean;
                             aOldPassword          : WideString;
                             aNewPassword          : WideString) : Boolean;

    function DeletePracUser(const aUserCode : string;
                            const aUserGuid : string;
                            aPractice : TBloPracticeRead = nil): Boolean;
    function IsPrimPracUser(const aUserCode : string = '';
                            aPractice : TBloPracticeRead = nil): Boolean;
    function GetPracUserGuid(const aUserCode : string;
                             aPractice : TBloPracticeRead): TBloGuid;
    function ChangePracUserPass(const aUserCode    : WideString;
                                const aOldPassword : WideString;
                                const aNewPassword : WideString;
                                const UserEmail    : WideString;
                                aPractice          : TBloPracticeRead = nil;
                                aLinkedUserGuid    : TBloGuid = '') : Boolean;  overload;

    function ChangePracUserPass(const aUserGuid    : TBloGuid;
                                const aUserCode    : WideString;
                                const aOldPassword : WideString;
                                const aNewPassword : WideString;
                                const UserEmail    : WideString): Boolean; overload;

    function UpdateClientNotesOption(ClientReadDetail: TBloClientReadDetail; WebExportFormat: Byte): Boolean;

    function GetExportDataId: TBloGuid;
    function GetIBizzExportGuid: TBloGuid;
    function GetBGLExportGuid: TBloGuid;
    function GuidToDesc(const aGuid: TBloGuid): string;
    procedure LogGuids(const aName: string; const aGuids: TBloArrayOfGuid);

    function GuidsEqual(GuidA, GuidB: TBloGuid): Boolean;
    function GuidArraysEqual(GuidArrayA, GuidArrayB: TBloArrayOfGuid): Boolean;

    function PracticeHasVendors : Boolean;
    function GetPracticeVendorExports(ShowProgressBar: boolean = True; PracticeCode: string = '') : TBloDataPlatformSubscription;
    function GetClientVendorExports(aClientGuid: TBloGuid) : TBloDataPlatformSubscription;
    function GetAccountVendors(aClientGuid : TBloGuid; aAccountId: Integer;
                               ShowProgressBar: boolean): TBloDataPlatformSubscription;
    function GetClientAccountsVendors(aClientCode: string;
                                      aClientGuid: TBloGuid;
                                      out aClientAccVendors : TClientAccVendors;
                                      aShowProgressBar: Boolean = True): Boolean; overload;
    function GetIBizzCredentials: TBloIBizzCredentials;
    function SaveIBizzCredentials(const AcclipseCode: WideString; aShowMessage: Boolean): Boolean;

    function VendorExportExists(VendorExports: ArrayOfDataPlatformSubscriber; VendorExportGuid: TBloGuid): Boolean;

    function SavePracticeVendorExports(VendorExports: TBloArrayOfGuid;
                                       aShowMessage: Boolean = True): Boolean;
    function SaveClientVendorExports(aClientId : TBloGuid;
                                     aVendorExports: TBloArrayOfGuid;
                                     aShowMessage: Boolean = True;
                                     ShowProgressBar: Boolean = true;
                                     ShowSuccessMessage: Boolean = True): Boolean;

    function SaveAccountVendorExports(aClientId : TBloGuid;
                                      aAccountID : Integer;
                                      aAccountName: String;
                                      aAccountNumber: String;
                                      aVendorExports: TBloArrayOfGuid;
                                      aShowMessage: Boolean = True;
                                      ShowProgressBar: Boolean = True;
                                      ShowSuccessMessage: Boolean = True): Boolean;

    function GetClientBankAccounts(aClientGuid: TBloGuid;
                                   out BankAccounts: TBloArrayOfDataPlatformBankAccount;
                                   aShowProgressBar: Boolean = True;
                                   ReportResponseErrors: Boolean = True): TBloResult;

    function GetVendorExportClientCount(PracticeCode: string = ''): TBloArrayOfPracticeDataSubscriberCount;

    function GetClientGuid(const ClientCode: WideString; out Id: TBloGuid): Boolean; overload;

    function ResetPracticeUserPassword(const EmailAddress: String; UserGuid: TBloGuid): Boolean;
    function ResetPracticeUserPasswordUnSecure(const aEmailAddress: String): Boolean;

    function CompareGuidArrays(SubscriptionA, SubscriptionB: TBloArrayOfGuid): Boolean;

    function GetOnlineClientUser(const ClientCode: String; out UserFullName, UserEmail: String): Boolean;

    function PracticeUserExists(const EmailAddress: String; RefreshPractice: Boolean = True): Boolean;

    function AuthenticateUser(const Domain, Username, Password: String; out AuthenticationResult: TAuthenticationStatus; IgnoreOnlineUser: Boolean = False): Boolean;

    function ProcessData(const XmlData: String; out AuthenticationError: Boolean; OnPostingData: TPostingDataEvent = nil): TBloUploadResult;

    function GetAccountStatusList(out Success: Boolean): TBloArrayOfPracticeBankAccount;

    procedure SuspendService;
    procedure ResumeService;

    function GetInstitutionList(out aBloArrayOfInstitution : TBloArrayOfInstitution) : TBloResult;
    function ValidateAccount(aAccountNumber, aInstCode, aCountryCode : string; var aFailedReason : string; aSupressProgress : boolean) : TBloResult;
    function ValidateAccountList(var aValidateAccountList : TBloArrayOfAccountValidation; aSupressProgress : boolean; var aErrorString : string) : TBloResult;
    function GetPracUpgReminderMsg(var aLatestVersion, aReminderVersion, aReminderMessage : string; aSupressProgress : boolean): TBloResult;

    procedure ResetExceptionTest;

    property OnLine: Boolean read FOnLine;
    property Registered: Boolean read GetRegistered;
    property ValidBConnectDetails: Boolean read GetValidBConnectDetails;
    property ProductList : TBloArrayOfGuid read GetProducts;

    property Practice: PracticeRead read GetCachedPractice;

    property ServiceStatus: TServiceStatus read GetServiceStatus;
    property ServiceActive: Boolean read GetServiceActive;
    property ServiceSuspended: Boolean read GetServiceSuspended;

    property ExceptionRaised: Boolean read FExceptionRaised;
    property BankLinkOnlinePracticeURL : string read GetBankLinkOnlinePracticeURL;
  end;

Const
  staActive      = BlopiServiceFacade.Active;
  staSuspended   = BlopiServiceFacade.Suspended;
  staDeactivated = BlopiServiceFacade.Deactivated;
  staDeleted     = BlopiServiceFacade.Deleted;

  //Product config singleton
  function ProductConfigService: TProductConfigService;

  procedure HandleException(const MethodName: String; E: Exception); overload;
  procedure HandleException(const MethodName, UnitName: String; E: Exception); overload;

//------------------------------------------------------------------------------
implementation

uses
  Controls,
  XMLDoc,
  OPToSOAPDomConv,
  LogUtil,
  WarningMoreFrm,
  ErrorMoreFrm,
  InfoMoreFrm,
  IniSettings,
  WebUtils,
  stDate,
  IniFiles,
  Progress,
  BkConst,
  WinINet,
  OpConvert,
  strUtils,
  WideStrUtils,
  WSDLIntf,
  IntfInfo,
  ObjAuto,
  SyDefs,
  Globals,
  xmldom,
  Login32,
  XSBuiltIns,
  Admin32,
  bkBranding,
  bkProduct,
  ShlObj,
  DateUtils,
  bkUrls,
  TransactionUtils;

const
  UNIT_NAME = 'BankLinkOnlineServices';
  INIFILE_NAME = 'BankLinkOnline.ini';

  { NOTE: any changes in PRODUCT_GUID or VENDOR_EXPORT_GUID also need to be
    supported in function GuidToDesc. }

  PRODUCT_GUID_CICO = '6D700B31-DAEE-4847-8CB2-82C21328AC33';
  PRODUCT_GUID_NOTES_ONLINE = '6D700B31-DAEE-4847-8CB2-82C21328AC30';
  PRODUCT_GUID_EXPORT_DATA = '6D700B31-DAEE-4847-8CB2-82C21328AC34';

  VENDOR_EXPORT_GUID_IBIZZ = '00ed4b6e-4c2b-4219-a102-c239d11a6ee8';
  VENDOR_EXPORT_GUID_BGL = '5fc52936-cfb0-4c19-85ea-d048a5b3440c';

  ROLES_CLIENT_ADMINISTRATOR = 'Client Administrator';

var
  __BankLinkOnlineServiceMgr: TProductConfigService;
  DebugMe : Boolean = False;

//------------------------------------------------------------------------------
function ProductConfigService: TProductConfigService;
begin
  if not Assigned(__BankLinkOnlineServiceMgr) then
    __BankLinkOnlineServiceMgr := TProductConfigService.Create;
  Result := __BankLinkOnlineServiceMgr;
end;

{ TProductConfigService }
//------------------------------------------------------------------------------
function TProductConfigService.IsExportDataEnabled : Boolean;
begin
  Result := OnLine and
            Registered and
            IsPracticeActive(False) and
            IsPracticeProductEnabled(GetExportDataId, True);
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsExportDataEnabledFoAccount(const aBankAcct : TBank_Account) : Boolean;
begin
  Result := IsExportDataEnabled and
            (not aBankAcct.baFields.baIs_A_Manual_Account) and
            (not (aBankAcct.baFields.baIs_A_Provisional_Account)) and
            (not (aBankAcct.IsAJournalAccount)) and
            (aBankAcct.baFields.baCore_Account_ID > 0);
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsItemInArrayString(const aBloArrayOfString : TBloArrayOfString;
                                                   const aItem : WideString) : Boolean;
var
  Index : integer;
begin
  Result := False;

  // Check if Item Exists
  for Index := Low(aBloArrayOfString) to High(aBloArrayOfString) do
  begin
    if aBloArrayOfString[Index] = aItem then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetItemIndexInArrayString(const aBloArrayOfString : TBloArrayOfString;
                                                         const aItem : WideString) : Integer;
var
  Index : integer;
begin
  Result := -1;

  // Check if Item Exists
  for Index := Low(aBloArrayOfString) to High(aBloArrayOfString) do
  begin
    if aBloArrayOfString[Index] = aItem then
    begin
      Result := Index;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.AddItemToArrayString(var aBloArrayOfString : TBloArrayOfString;
                                                    aItem : WideString) : Boolean;
begin
  Result := False;
  // Check if Item Exists
  if IsItemInArrayString(aBloArrayOfString, aItem) then
    Exit;

  //Add Item
  SetLength(aBloArrayOfString, Length(aBloArrayOfString) + 1);
  aBloArrayOfString[High(aBloArrayOfString)] := aItem;
  Result := True;
end;

//------------------------------------------------------------------------------
function TProductConfigService.RemoveItemFromArrayString(var aBloArrayOfString : TBloArrayOfString;
                                                         aItem : WideString) : Boolean;
var
  Index : integer;
  ItemIndex : integer;
begin
  Result := False;

  // Get Item Index
  ItemIndex := GetItemIndexInArrayString(aBloArrayOfString, aItem);
  if ItemIndex = -1 then
    Exit;

  //Remove Item
  if High(aBloArrayOfString) >= (ItemIndex+1) then
  begin
    for Index := High(aBloArrayOfString) downto ItemIndex+1 do
    begin
      aBloArrayOfString[Index-1] := aBloArrayOfString[Index];
    end;
  end;
  SetLength(aBloArrayOfString, Length(aBloArrayOfString) - 1);

  Result := True;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsItemInArrayGuid(const aBloArrayOfGuid : TBloArrayOfGuid;
                                                 const aItem : TBloGuid) : Boolean;
var
  Index : integer;
begin
  Result := False;

  // Check if Item Exists
  for Index := Low(aBloArrayOfGuid) to High(aBloArrayOfGuid) do
  begin
    if aBloArrayOfGuid[Index] = aItem then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetItemIndexInArrayGuid(const aBloArrayOfGuid : TBloArrayOfGuid;
                                                       const aItem : TBloGuid) : Integer;
var
  Index : integer;
begin
  Result := -1;

  // Check if Item Exists
  for Index := Low(aBloArrayOfGuid) to High(aBloArrayOfGuid) do
  begin
    if aBloArrayOfGuid[Index] = aItem then
    begin
      Result := Index;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.AddItemToArrayGuid(var aBloArrayOfGuid : TBloArrayOfGuid;
                                                  aItem : TBloGuid) : Boolean;
begin
  Result := False;
  // Check if Item Exists
  if IsItemInArrayGuid(aBloArrayOfGuid, aItem) then
    Exit;

  //Add Item
  SetLength(aBloArrayOfGuid, Length(aBloArrayOfGuid) + 1);
  aBloArrayOfGuid[High(aBloArrayOfGuid)] := aItem;
  Result := True;
end;

//------------------------------------------------------------------------------
function TProductConfigService.RemoveItemFromArrayGuid(var aBloArrayOfGuid : TBloArrayOfGuid;
                                                       aItem : TBloGuid) : Boolean;
var
  Index : integer;
  ItemIndex : integer;
begin
  Result := False;

  // Get Item Index
  ItemIndex := GetItemIndexInArrayGuid(aBloArrayOfGuid, aItem);
  if ItemIndex = -1 then
    Exit;

  //Remove Item
  if High(aBloArrayOfGuid) >= (ItemIndex+1) then
  begin
    for Index := ItemIndex+1 to High(aBloArrayOfGuid) do
    begin
      aBloArrayOfGuid[Index-1] := aBloArrayOfGuid[Index];
    end;
  end;
  SetLength(aBloArrayOfGuid, Length(aBloArrayOfGuid) - 1);

  Result := True;
end;

//------------------------------------------------------------------------------
function TProductConfigService.ChangePracUserPass(const aUserGuid: TBloGuid; const aUserCode: WideString; const aOldPassword, aNewPassword: WideString; const UserEmail: WideString): Boolean;
var
  ShowProgress    : Boolean;
begin
  ShowProgress := Progress.StatusSilent;
  if ShowProgress then
  begin
    Screen.Cursor := crHourGlass;
    Progress.StatusSilent := False;
    Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
  end;

  try
    if ShowProgress then
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Sending Data', 60);

    Result := UpdatePracticeUserPass(aUserGuid,
                                    aUserCode,
                                    aOldPassword,
                                    aNewPassword,
                                    UserEmail,
                                    'change practice user password on');

    if (Result) and (ShowProgress) then
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);

  finally
    if ShowProgress then
    begin
      Progress.StatusSilent := True;
      Progress.ClearStatus;
      Screen.Cursor := crDefault;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.CheckGuidArrayEquality(GuidArray1, GuidArray2: TBloArrayOfGuid): boolean;
var
  i, j: integer;
  MatchFound: boolean;
begin
  Result := False;
  MatchFound := False;
  if (Length(GuidArray1) = Length(GuidArray2)) then
  begin
    if (Length(GuidArray1) = 0) then
    begin
      Result := True; // both arrays are empty, and therefore equal
      Exit;
    end;
    for i := 0 to High(GuidArray1) do
    begin
      MatchFound := False;
      for j := 0 to High(GuidArray2) do
      begin
        if (GuidArray1[i] = GuidArray2[j]) then
        begin
          MatchFound := True;
          break;
        end;
      end;
      if not MatchFound then
        break; // There is an ID in one array without a matching ID in the other array, so these arrays don't match
    end;
    Result := MatchFound;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.AddProduct(AProductId: TBloGuid);
var
  Subscription : TBloArrayOfGuid;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
    'AddProduct ' + GuidToDesc(aProductId)
  );

  Subscription := FPracticeCopy.Subscription;
  try
    AddItemToArrayGuid(Subscription, AProductId);
  finally
    FPracticeCopy.Subscription := Subscription;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.ClearAllProducts;
var
  i: integer;
  SubArray: TBloArrayOfGuid;
  WarningStr, Msg: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
    'ClearAllProducts'
  );

  //Copy the subscription array
  SetLength(SubArray, Length(FPracticeCopy.Subscription));
  for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do
    SubArray[i] := FPracticeCopy.Subscription[i];
  //Try to remove product
  Msg := '';
  for i := Low(SubArray) to High(SubArray) do
  begin
    WarningStr := RemoveProduct(SubArray[i], false);
    if (WarningStr <> '') then
      Msg := Msg + WarningStr + #10#10;
  end;
  if (Msg <> '') then
    HelpfulWarningMsg(Msg, 0);
end;

//------------------------------------------------------------------------------
function TProductConfigService.CompareGuidArrays(SubscriptionA, SubscriptionB: TBloArrayOfGuid): Boolean;
var
  Index: Integer;
begin
  Result := True;
  
  if Length(SubscriptionA) = Length(SubscriptionB) then
  begin
    for Index := 0 to Length(SubscriptionA) - 1 do
    begin
      if not IsItemInArrayGuid(SubscriptionB, SubscriptionA[Index]) then
      begin
        Result := False;

        Break;
      end;
    end;

    if Result then
    begin
      for Index := 0 to Length(SubscriptionB) - 1 do
      begin
        if not IsItemInArrayGuid(SubscriptionA, SubscriptionB[Index]) then
        begin
          Result := False;

          Break;
        end;
      end;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.CopyRemotableObject(ASource, ATarget: TRemotable);
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XML: IXMLDocument;
  XMLStr: WideString;
begin
  // This can be nil, easier to not act on it here
  if not assigned(ATarget) then
    exit;

  XML := NewXMLDocument;
  Converter := TSOAPDomConv.Create(NIL);

  NodeRoot   := XML.AddChild('Root');
  NodeParent := NodeRoot.AddChild('Parent');
  NodeObject := ASource.ObjectToSOAP(NodeRoot, NodeParent, Converter,
                                     'CopyObject', '', [ocoDontPrefixNode],
                                     XMLStr);

  ATarget.SOAPToObject(NodeRoot, NodeObject, Converter);
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.CopyRemotableObject(ASource, ATarget: TBloArrayOfRemotable);
var
  Index : integer;
begin
  for Index := 0 to length(ASource)-1 do
  begin
    CopyRemotableObject(ASource[Index], ATarget[Index]);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.CreateNewClient(ANewClient: TBloClientCreate): TBloGuid;
var
  BlopiInterface: IBlopiSecureServiceFacade;
  MsgResponse: MessageResponseOfGuid;
  ShowProgress : Boolean;
  Cancelled: Boolean;
  ConnectionError: Boolean;
begin
  Result := '';

  if not Assigned(AdminSystem) then
    Exit;

  if not Registered then
    Exit;

  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Creating Client', 50);

      BlopiInterface :=  GetSecureServiceFacade;
      
      try
        if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
          'CreateClient for ' + aNewClient.Name_
        );

        MsgResponse := BlopiInterface.CreateClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                   AdminSystem.fdFields.fdBankLink_Code,
                                                   AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                   ANewClient);
      except
        on E: EAuthenticationException do
        begin
          if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
          begin
            if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
              'CreateClient for ' + aNewClient.Name_
            );

            MsgResponse := BlopiInterface.CreateClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                   AdminSystem.fdFields.fdBankLink_Code,
                                                   AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                   ANewClient);
          end
          else
          begin
            Exit;
          end;  
        end;
      end;

      if not MessageResponseHasError(MsgResponse, 'create client on') then
        Result := Copy(MsgResponse.Result, 1, Length(MsgResponse.Result));

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);

    finally
      FreeAndNil(MsgResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('CreateNewClient', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.CreateNewClientUser(NewUser: TBloUserCreate; ClientGUID: string): Guid;
var
  BlopiInterface: IBlopiSecureServiceFacade;
  MsgResponseOfGuid: MessageResponseOfGuid;
  Cancelled: Boolean;
  ConnectionError: Boolean;
begin
  try
    try
      BlopiInterface  := GetSecureServiceFacade;

      try
        if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
          'CreateClientUser for ' + NewUser.UserCode
        );

        MsgResponseOfGuid := BlopiInterface.CreateClientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                                           AdminSystem.fdFields.fdBankLink_Code,
                                                           AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                           ClientGUID,
                                                           NewUser);
      except
        on E: EAuthenticationException do
        begin
          if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
          begin
            if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
              'CreateClientUser for ' + NewUser.UserCode
            );

            MsgResponseOfGuid := BlopiInterface.CreateClientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                                         AdminSystem.fdFields.fdBankLink_Code,
                                                         AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                         ClientGUID,
                                                         NewUser);
          end
          else
          begin
            Exit;
          end;
        end;
      end;

      Result := Copy(MsgResponseOfGuid.Result,1,length(MsgResponseOfGuid.Result));
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running CreateNewClientUser, Error Message : ' + E.Message);

        raise Exception.Create(bkBranding.PracticeProductName + ' is unable to create a new user on ' + BRAND_ONLINE + '. Please contact ' + BRAND_SUPPORT + ' for assistance.');
      end;
    end;

    if not MessageResponseHasError(MsgResponseOfGuid, 'update practice user password on') then
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'User ' + NewUser.FullName + ' has been successfully created on ' + BRAND_ONLINE + '.')
    else
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'User ' + NewUser.FullName + ' was not created on ' + BRAND_ONLINE + '.');

  finally
    FreeAndNil(MsgResponseOfGuid);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.CreateNewClientWithUser(aNewClient: TBloClientCreate; aNewUserCreate: TBloUserCreate): TBloClientReadDetail;
var
  TheGuid: TBloGuid;
  MsgResponseOfGuid: MessageResponseOfGuid;
  ClientDetailResponse: MessageResponseOfClientReadDetailMIdCYrSK;
  BlopiInterface: IBlopiServiceFacade;
begin
  try
    BlopiInterface  := GetServiceFacade;
    TheGuid := CreateNewClient(aNewClient);

    if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
      'CreateClientUser for ' + aNewUserCreate.UserCode
    );

    MsgResponseOfGuid := BlopiInterface.CreateClientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                                           AdminSystem.fdFields.fdBankLink_Code,
                                                           AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                           TheGuid,
                                                           aNewUserCreate);


    ClientDetailResponse := BlopiInterface.GetClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                       AdminSystem.fdFields.fdBankLink_Code,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                       MsgResponseOfGuid.Result);

    Result := TBloClientReadDetail.Create;
    CopyRemotableObject(ClientDetailResponse.Result, Result);
  finally
    FreeAndNil(MsgResponseOfGuid);
    FreeAndNil(ClientDetailResponse);
  end;
end;

//------------------------------------------------------------------------------
destructor TProductConfigService.Destroy;
begin
  //Clear all created objects etc???
  FreeAndNil(FPracticeCopy);
  FreeAndNil(FPractice);
  FreeAndNil(FClientList);
  inherited;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetIBizzCredentials: TBloIBizzCredentials;
var
  DataSubscriberCredentialsResponse: MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k;
  ShowProgress: Boolean;
  BlopiInterface: IBlopiServiceFacade;
begin
  Result := nil;
  
  try
    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting iBizz Subscriber Credentials', 50);

      BlopiInterface :=  GetServiceFacade;
      
      //Get the vendor export types from BankLink Online
      DataSubscriberCredentialsResponse := BlopiInterface.GetPracticeDataSubscriberCredentials(CountryText(AdminSystem.fdFields.fdCountry),
                                                       AdminSystem.fdFields.fdBankLink_Code,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                       GetIBizzExportGuid);
                                                       
      if not MessageResponseHasError(MessageResponse(DataSubscriberCredentialsResponse), 'get the iBizz subscriber credentials from') then
      begin
        Result := TBloIBizzCredentials.create;
        CopyRemotableObject(DataSubscriberCredentialsResponse.Result, Result);
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(DataSubscriberCredentialsResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetIBizzCredentials', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetIBizzExportGuid: TBloGuid;
begin
  Result := VENDOR_EXPORT_GUID_IBIZZ;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetBanklinkOnlinePracticeURL: string;
begin
  Result := 'https://' + FPractice.DomainName + '.' +
            Copy(TUrls.BooksOnlineDefaultUrl, 13 ,
            Length(TUrls.BooksOnlineDefaultUrl));
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetBGLExportGuid: TBloGuid;
begin
  Result := VENDOR_EXPORT_GUID_BGL;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GuidToDesc(const aGuid: TBloGuid): string;
begin
  if SameText(aGuid, PRODUCT_GUID_CICO) then
    result := 'CiCo'
  else if SameText(aGuid, PRODUCT_GUID_NOTES_ONLINE) then
    result := 'Notes'
  else if SameText(aGuid, PRODUCT_GUID_EXPORT_DATA) then
    result := 'Export Data'
  else if SameText(aGuid, VENDOR_EXPORT_GUID_IBIZZ) then
    result := 'iBizz'
  else if SameText(aGuid, VENDOR_EXPORT_GUID_BGL) then
    result := 'BGL'

  // Subscribers
  else if SameText(aGuid, '42275A45-218F-439E-9326-097CC76E2114') then
    result := 'iBizz'
  else if SameText(aGuid, 'B6AE05DC-2D1D-476C-B8EB-B89F42C27304') then
    result := 'MYOB'

  else
    result := aGuid; // Just return the GUID
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.LogGuids(const aName: string;
  const aGuids: TBloArrayOfGuid);
var
  sMsg: string;
  i: integer;
begin
  sMsg := aName + ': ';
  for i := 0 to High(aGuids) do
  begin
    if (i <> 0) then
      sMsg := sMsg + ', ';

    sMsg := sMsg + GuidToDesc(aGuids[i]);
  end;
  LogUtil.LogMsg(lmDebug, UNIT_NAME, sMsg);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetBanklinkOnlineURL(Service: String): String;
begin
  if Trim(FSubdomain) <> '' then
  begin
    Result := ReplaceText(PRACINI_BankLink_Online_Services_URL, 'https://www.', Format('https://%s.', [FSubdomain]));
  end
  else
  begin
    Result := PRACINI_BankLink_Online_Services_URL;
  end;

  if Assigned(AdminSystem) then
  begin
    Result := Result + Format('%s?PracticeCode=%s', [Service, AdminSystem.fdFields.fdBankLink_Code]);
  end
  else
  begin
    Result := Result + Service;
  end;

  //Result := 'http://localhost:56787/Services/BlopiServiceFacade.svc';
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetCachedPractice: TBloPracticeRead;
begin
  Result := FPractice;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetCatalogueEntry(
  AProductId: TBloGuid): TBloCatalogueEntry;
var
  i: integer;
begin
  Result :=  nil;
  for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
    if (AProductId = FPractice.Catalogue[i].Id) then begin
      Result := FPractice.Catalogue[i];
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientDetailsWithCode(AClientCode: string; SynchronizeBlopi: Boolean = False): TBloClientReadDetail;
var
  ClientGuid: WideString;
begin
  Result := nil;

  if not Assigned(AdminSystem) then
    Exit;

  if not Registered then
    Exit;

  //Find client code in the client list
  ClientGuid := GetClientGuid(AClientCode);
  if (ClientGuid <> '') then
    Result := GetClientDetailsWithGuid(ClientGuid, SynchronizeBlopi);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientDetailsWithGuid(AClientGuid: TBloGuid; SynchronizeBlopi: Boolean = False): TBloClientReadDetail;
var
  BlopiInterface: IBlopiServiceFacade;
  ClientDetailResponse: MessageResponseOfClientReadDetailMIdCYrSK;
  ShowProgress : Boolean;
begin
  Result := nil;
  try
    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Client Details', 50);

      BlopiInterface :=  GetServiceFacade;
      //Get the client from BankLink Online
      ClientDetailResponse := BlopiInterface.GetClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                       AdminSystem.fdFields.fdBankLink_Code,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                       AClientGuid);
      if not Assigned(Globals.AdminSystem) then
      begin
        // Show this warning for suspended/deactivated books users
        case ClientDetailResponse.Result.Status of
          Suspended,
          Deactivated: HelpfulWarningMsg(bkBranding.BooksProductName + ' is unable to access ' + BRAND_ONLINE + '. ' +
                                         'Please contact your accountant for further assistance', 0);
        end;
      end;

      if not MessageResponseHasError(MessageResponse(ClientDetailResponse), 'get the client settings from') then
      begin
        Result := TBloClientReadDetail.Create;
        CopyRemotableObject(ClientDetailResponse.Result, Result);

        if SynchronizeBlopi then
        begin
          SynchronizeClientSettings(Result);
        end;
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(ClientDetailResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetClientDetailsWithGuid', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientGuid(const aClientCode: string): WideString;
var
  Guid: TBloGuid;
begin
  Result := '';

  if GetClientGuid(aClientCode, Guid) then
  begin
    Result := Guid;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientGuid(const ClientCode: WideString; out Id: TBloGuid): Boolean;
type
  TResponseType = (rtClientFound, ctClientNotFound, rtError);
  
  function CheckResponse(Response: MessageResponse): TResponseType;
  begin
    Result := rtError;
    
    if Assigned(Response) then
    begin
      if Response.Success then
      begin
        Result := rtClientFound;
      end
      else if Length(Response.ErrorMessages) = 1  then
      begin
        if CompareText(Response.ErrorMessages[0].ErrorCode, 'BusinessPlusService_GetSmeIdFailed') = 0 then
        begin
          Result := ctClientNotFound;
        end;
      end;
    end;
  end;

var
  BlopiInterface: IBlopiServiceFacade;
  BlopiClientGuid: MessageResponseOfguid;
  ShowProgress : Boolean;
begin
  Result := False;
  
  try
    ShowProgress := Progress.StatusSilent;
    
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if UseBankLinkOnline then
      begin
        if ShowProgress then
        begin
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Looking Up Client', 50);
        end;

        BlopiInterface := GetServiceFacade;

        BlopiClientGuid := BlopiInterface.GetClientId(CountryText(AdminSystem.fdFields.fdCountry),
                                                        AdminSystem.fdFields.fdBankLink_Code,
                                                        AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                        ClientCode);

        case CheckResponse(BlopiClientGuid) of
          rtClientFound:
          begin
            Id := Copy(BlopiClientGuid.Result,1,length(BlopiClientGuid.Result));

            Result := True;
          end;

          rtError:
          begin
            MessageResponseHasError(MessageResponse(BlopiClientGuid), 'looking up the client from');
          end;
        end;

        if ShowProgress then
        begin
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
        end;
      end;
    finally
      FreeAndNil(BlopiClientGuid);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetClientGuid', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetOnlineClientUser(const ClientCode: String; out UserFullName, UserEmail: String): Boolean;
var
  ClientReadDetail: TBloClientReadDetail;
  PrimaryUser: TBloUserRead;
begin
  Result := False;

  if OnLine then
  begin
    ClientReadDetail := ProductConfigService.GetClientDetailsWithCode(ClientCode);

    if Assigned(ClientReadDetail) then
    begin
      try
        PrimaryUser := ClientReadDetail.GetPrimaryUser;

        if Assigned(PrimaryUser) then
        begin
          UserFullName := PrimaryUser.FullName;
          UserEmail := PrimaryUser.EMail;

          Result := True;
        end;
      finally
        FreeAndNil(ClientReadDetail);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetExportDataId: TBloGuid;
var
  i   : integer;
  Cat : TBloCatalogueEntry;
begin
  Result := '';
  
  if Assigned(FPractice) then
  begin
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do
    begin
      Cat := FPracticeCopy.Catalogue[i];

      if GuidsEqual(Cat.Id, PRODUCT_GUID_EXPORT_DATA) then
      begin
        Result := Cat.Id;
        
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetPractice(aUpdateUseOnline: Boolean; aForceOnlineCall : Boolean; PracticeCode: string; AllowProgressBar: Boolean; SuppressErrors: Boolean): TBloPracticeRead;
var
  i: integer;
  BlopiInterface: IBlopiServiceFacade;
  PracticeDetailResponse: MessageResponseOfPracticeReadMIdCYrSK;
  Msg: string;
  ShowProgress : Boolean;
begin
  Result := Nil;
  if not Assigned(AdminSystem) then
    Exit;

  //Check that BConnect secure code has been assigned
  if AdminSystem.fdFields.fdBankLink_Code = '' then begin
    HelpfulErrorMsg('The ' + BRAND_SECURE + ' Code for this practice has not been set. ' +
                    'Please set this before attempting to use ' + BRAND_ONLINE +
                    '.', 0);
    Exit;
  end;

  //Initialise
  FOnLine := False;
  FRegistered := False;
  FValidBConnectDetails := False;
  //UseBankLinkOnline is updated by the user when the practice details
  //dialog is open - so dont't reset it.
  if aUpdateUseOnline then
    UseBankLinkOnline := False;

  FreeAndNil(FPractice);
  FPractice := TBloPracticeRead.Create;

  FreeAndNil(FPracticeCopy);
  FPracticeCopy := TBloPracticeRead.Create;

  try
    ShowProgress := Progress.StatusSilent and AllowProgressBar;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      try
        if ShowProgress then
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Practice Details', 50);

        //Load cached practice details if they are registered or not
        if AdminSystem.fdFields.fdBankLink_Online_Config <> '' then
          LoadRemotableObjectFromXML(AdminSystem.fdFields.fdBankLink_Online_Config, FPractice);

        //UseBankLinkOnline is updated by the user when the practice details
        //dialog is open - so dont't reload it from the system db.
        if aUpdateUseOnline then
          UseBankLinkOnline := ServiceActive;

        //Try to load practice details from BankLink Online
        FOnLine := False;
        if (UseBankLinkOnline)
        or not FPractice.IsEqual(FPracticeCopy)
        or (aForceOnlineCall) then
        begin
          //Reload from BankLink Online
          if (PracticeCode = '') then
            PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
          BlopiInterface := GetServiceFacade(PracticeCode);
          PracticeDetailResponse := BlopiInterface.GetPractice(CountryText(AdminSystem.fdFields.fdCountry),
                                                               PracticeCode,
                                                               AdminSystem.fdFields.fdBankLink_Connect_Password);

          if Assigned(PracticeDetailResponse) then
          begin
            FOnline := True;

            if Assigned(PracticeDetailResponse.Result) then
            begin
              AdminSystem.fdFields.fdLast_BankLink_Online_Update := stDate.CurrentDate;

              if Assigned(FPractice) then
              begin
                FreeAndNil(FPractice);
                FPractice := TBloPracticeRead.Create;
              end;
              
              CopyRemotableObject(PracticeDetailResponse.Result, FPractice);
              FRegistered := True;
              FValidBConnectDetails := True;

              FSubdomain := FPractice.DomainName;

              for i := 1 to Screen.FormCount - 1 do
              begin
                if (Screen.Forms[i].Name = 'frmClientManager') then
                begin
                  SendMessage(Screen.Forms[i].Handle, BK_PRACTICE_DETAILS_CHANGED, 0, 0);
                  break;
                end;
              end;

            end else
            begin
              //Something went wrong
              Msg := '';
              if Length(PracticeDetailResponse.ErrorMessages) > 0 then
              begin
                //Check for non-registered Practice
                if (PracticeDetailResponse.ErrorMessages[0].ErrorCode = 'BusinessPlusService_GetPracticeIdFailed') then
                begin
                  FRegistered := False;
                  FValidBConnectDetails := True;
                  AdminSystem.fdFields.fdBankLink_Online_Config := '';
                end else
                begin
                  for i := Low(PracticeDetailResponse.ErrorMessages) to High(PracticeDetailResponse.ErrorMessages) do
                    Msg := Msg + ServiceErrorMessage(PracticeDetailResponse.ErrorMessages[i]).Message_;
                  if Msg = 'Invalid BConnect Credentials' then
                    //Clear the cached practice details if not registered for this practice code
                    AdminSystem.fdFields.fdBankLink_Online_Config := '';
                end;
              end else
                Msg := 'Unknown error';
              if Msg <> '' then
              begin
                if not SuppressErrors then
                begin
                  HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to get the practice details from ' + BRAND_ONLINE + '.', 0, True, Msg, True);
                end;

                Exit;
              end;
            end;
          end;
        end;
        if ShowProgress then
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
      except
        on E:Exception do
        begin
          HandleException('GetPractice', E, SuppressErrors);
        end;
      end;
    finally
      FreeAndNil(PracticeDetailResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  finally
    //Make a copy for editing
    if FPractice <> nil then
      CopyRemotableObject(FPractice, FPracticeCopy);
    Result := FPracticeCopy;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetProducts: TBloArrayOfGuid;
begin
  if Assigned(FPracticeCopy) then
    Result := FPracticeCopy.Subscription;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetRegistered: Boolean;
begin
  if not Assigned(FPractice) then
    GetPractice;
  Result := FRegistered;  
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.LoadClientList(PracticeCode: string = '');
var
  BlopiInterface: IBlopiServiceFacade;
  BlopiClientList: MessageResponseOfClientListMIdCYrSK;
  ShowProgress : Boolean;
begin
  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;
    try
      FreeAndNil(FClientList);
      if UseBankLinkOnline then begin
        if ShowProgress then
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Client List', 50);

        if (PracticeCode = '') then
          PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
        BlopiInterface := GetServiceFacade(PracticeCode);
        BlopiClientList := BlopiInterface.GetClientList(CountryText(AdminSystem.fdFields.fdCountry),
                                                        PracticeCode,
                                                        AdminSystem.fdFields.fdBankLink_Connect_Password);
        if not MessageResponseHasError(MessageResponse(BlopiClientList), 'load the client list from') then
          if Assigned(BlopiClientList.Result) then
          begin
            FClientList := ClientList.Create;
            CopyRemotableObject(BlopiClientList.Result, FClientList);
          end;

        if ShowProgress then
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
      end;
    finally
      FreeAndNil(BlopiClientList);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('LoadClientList', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.LoadRemotableObjectFromFile(ARemotable: TRemotable): Boolean;
var
  XMLDoc: IXMLDocument;
begin
  Result := False;
  if FileExists(ARemotable.ClassName + '.xml') then begin
    XMLDoc := NewXMLDocument;
    XMLDoc.LoadFromFile(ARemotable.ClassName + '.xml');
    LoadRemotableObjectFromXML(XMLDoc.XML.Text, ARemotable);
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.LoadRemotableObjectFromXML(const XML: string;
  ARemotable: TRemotable);
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XMLDoc: IXMLDocument;
begin
  Converter := TSOAPDomConv.Create(NIL);
  XMLDoc := NewXMLDocument;
  XMLDoc.LoadFromXML(XML);
  NodeRoot := XMLDoc.ChildNodes.FindNode('Root');
  NodeParent := NodeRoot.ChildNodes.FindNode('Parent');
  NodeObject := NodeParent.ChildNodes.FindNode('CopyObject');
  ARemotable.SOAPToObject(NodeRoot, NodeObject, Converter);
end;

//------------------------------------------------------------------------------
// ContextMsgInt and ContextErrorCode have been added to allow custom error messages
// to be shown to the user rather than the default BLOPI error message. This could be
// expanded to use arrays, so that multiple codes with a different message selected
// for each code can be passed through, but I think single values should be enough
function TProductConfigService.MessageResponseHasError(
  AMesageresponse: MessageResponse; ErrorText: string; SimpleError: boolean = false;
  ContextMsgInt: integer = 0; ContextErrorCode: string = ''; ReportResponseErrors: Boolean = True): Boolean;
const
  MAIN_ERROR_MESSAGE =  BKPRACTICENAME + ' is unable to %s. Please see the details below or contact ' + BRAND_SUPPORT + ' for assistance.';
var
  ErrorMessage: string;
  ErrIndex : integer;
  Details: TStringList;

  //-------------------------------------------------------------
  procedure AddLine(MessageList: TStrings; const aName: string; const aMessage: string);
  begin
    if aMessage = '' then
      Exit;
    if Assigned(MessageList) then begin
      if MessageList.Count > 0 then
        MessageList.add('');
      MessageList.Add(aName + ': ' + aMessage);
    end;
  end;

var
  CustomMessage, CustomError: String;
begin
  Result := False;

  case ContextMsgInt of
    0: begin
         CustomMessage := '';
         CustomError := '';
       end;
    1: begin
         CustomMessage := 'This client has been deactivated';
         CustomError := BRAND_ONLINE + ' is unable to display the Export To ' +
                        'options for this client. Please see the details ' +
                        'below or contact ' + BRAND_ONLINE + ' support for assistance';
       end;
  end;

  if Assigned(AMesageresponse) then
  begin
    if not AMesageresponse.Success then
    begin
      //Error message returned by BankLink Online
      Result := True;
      if (CustomError <> '') then
        ErrorMessage := CustomError
      else
        ErrorMessage := Format(MAIN_ERROR_MESSAGE, [ErrorText]);
      Details := TStringList.Create;
      try
        for ErrIndex := 0 to high(AMesageresponse.ErrorMessages) do
        begin
          AddLine(Details, 'Code', AMesageresponse.ErrorMessages[ErrIndex].ErrorCode);
          if (ContextErrorCode = AMesageresponse.ErrorMessages[ErrIndex].ErrorCode) then
            AddLine(Details, 'Message', CustomMessage)
          else
            AddLine(Details, 'Message', AMesageresponse.ErrorMessages[ErrIndex].Message_);
        end;

        for ErrIndex := 0 to high(AMesageresponse.Exceptions) do
        begin
          AddLine(Details, 'Message', AMesageresponse.Exceptions[ErrIndex].Message_);
          AddLine(Details, 'Source', AMesageresponse.Exceptions[ErrIndex].Source);
          AddLine(Details, 'StackTrace', AMesageresponse.Exceptions[ErrIndex].StackTrace);
        end;

        if ReportResponseErrors and (Details.Count > 0) then
        begin
          HelpfulErrorMsg(ErrorMessage, 0, False, Details.Text, not SimpleError);
        end;
        
        LogUtil.LogMsg(lmError, 'ERRORMOREFRM', Details.Text);
      finally
        Details.Free;
      end;
    end;
  end
  else
  begin
    //No response from BankLink Online
    ErrorMessage := Format(MAIN_ERROR_MESSAGE, ['connect to', BRAND_ONLINE]);
    HelpfulErrorMsg(ErrorMessage, 0);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.OnlineStatus: TBloStatus;
begin
  Result := Active;
  if Assigned(FPractice) then
    Result := FPractice.Status;
end;

//------------------------------------------------------------------------------

function TProductConfigService.PracticeChanged: Boolean;
begin
  if not Assigned(FPracticeCopy) then
    Result := True
  else
    Result := not FPracticeCopy.IsEqual(FPractice);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetTypeItemIndex(var aDataArray: TArrVarTypeData;
                                                const aName : String) : integer;
var
  Index : integer;
begin
  Result := -1;
  for Index := 0 to high(aDataArray) do
  begin
    if UpperCase(aDataArray[Index].Name) = UpperCase(aName) then
    begin
      Result := Index;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetValidBConnectDetails: Boolean;
begin
  Result := FValidBConnectDetails;
end;

function TProductConfigService.GetVendorExportClientCount(PracticeCode: string = ''): TBloArrayOfPracticeDataSubscriberCount;
var
  DataSubscriberCredentialsResponse: MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k;
  ShowProgress: Boolean;
  BlopiInterface: IBlopiServiceFacade;
  Index: Integer;
begin
  Result := nil;
  
  try
    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Data Export Subscribers', 50);

      if (PracticeCode = '') then
        PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
      BlopiInterface := GetServiceFacade(PracticeCode);

      //Get the vendor export types from BankLink Online
      DataSubscriberCredentialsResponse := BlopiInterface.GetPracticeDataSubscriberCount(CountryText(AdminSystem.fdFields.fdCountry),
                                                       PracticeCode,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password);
                                                       
      if not MessageResponseHasError(MessageResponse(DataSubscriberCredentialsResponse), 'get the vendor subscribers') then
      begin
        SetLength(Result, length(DataSubscriberCredentialsResponse.Result));
        for Index := 0 to length(Result)-1 do
        begin
          Result[Index] := PracticeDataSubscriberCount.Create;
        end;

        CopyRemotableObject(TBloArrayOfRemotable(DataSubscriberCredentialsResponse.Result), TBloArrayOfRemotable(Result));
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(DataSubscriberCredentialsResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetVendorExportClientCount', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GuidArraysEqual(GuidArrayA, GuidArrayB: TBloArrayOfGuid): Boolean;
var
  Index: Integer;
begin
  Result := True;
  
  if Length(GuidArrayA) = Length(GuidArrayB) then
  begin
    for Index := 0 to Length(GuidArrayA) - 1 do
    begin
      if GuidArrayA[Index] <> GuidArrayB[Index] then
      begin
        Result := False;

        Break;
      end;
    end;
  end
  else
  begin
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GuidsEqual(GuidA, GuidB: TBloGuid): Boolean;
begin
  Result := CompareText(GuidA, GuidB) = 0;
end;

//------------------------------------------------------------------------------
function TProductConfigService.PracticeHasVendors : Boolean;
var
  FPracticeVendorExports : TBloDataPlatformSubscription;
begin
  Result := false;
  try
    FPracticeVendorExports := GetPracticeVendorExports;
    if Assigned(FPracticeVendorExports) then
      Result := (Length(FPracticeVendorExports.Current) > 0);
  finally
    FreeAndNil(FPracticeVendorExports);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.PracticeUserExists(const EmailAddress: String; RefreshPractice: Boolean = True): Boolean;
begin
  Result := False;

  if RefreshPractice then
  begin
    GetPractice;
  end
  else
  if not Assigned(FPractice) then
  begin
    GetPractice;
  end;
  
  if Assigned(FPractice) then
  begin
    Result := FPractice.FindUser(EmailAddress) <> nil; 
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.ProcessData(const XmlData: String; out AuthenticationError: Boolean; OnPostingData: TPostingDataEvent = nil): TBloUploadResult;
var
  ServiceProvider: IBlopiSecureServiceFacade;
  HTTPRIO: THTTPRIO;
  Cancelled: Boolean;
  ConnectionError: Boolean;
  BloUploadResult : TBloUploadResult;
begin
  AuthenticationError := False;
  
  ServiceProvider := GetSecureServiceFacade(HTTPRIO);

  HTTPRIO.HTTPWebNode.OnPostingData := OnPostingData;

  try
    try
      try
        BloUploadResult := ServiceProvider.ProcessData(
          CountryText(AdminSystem.fdFields.fdCountry),
          AdminSystem.fdFields.fdBankLink_Code,
          AdminSystem.fdFields.fdBankLink_Connect_Password,
          EncodeText(XMLData));

        Result := TBloUploadResult.create;
        CopyRemotableObject(BloUploadResult, Result);
      except
        on E: EAuthenticationException do
        begin
          if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
          begin
            BloUploadResult := ServiceProvider.ProcessData(
              CountryText(AdminSystem.fdFields.fdCountry),
              AdminSystem.fdFields.fdBankLink_Code,
              AdminSystem.fdFields.fdBankLink_Connect_Password,
              EncodeText(XMLData));

            FreeAndNil(Result);
            Result := TBloUploadResult.create;
            CopyRemotableObject(BloUploadResult, Result);
          end
          else
          begin
            AuthenticationError := True;

            Exit;
          end;
        end;
      end;
    finally
      FreeAndNil(BloUploadResult);
    end;
  except
    on E: Exception do
    begin
      HandleException('ProcessData', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.AddTypeItem(var aDataArray: TArrVarTypeData;
                                            var aDataItem: TVarTypeData);
begin
  SetLength(aDataArray, High(aDataArray) + 2);
  aDataArray[High(aDataArray)] := aDataItem;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.AddToXMLTypeNameList(const aName : String;
                                                     aTypeInfo : PTypeInfo;
                                                     var aNameList : TArrVarTypeData);
var
  TypeData : PTypeData;
  PropList : PPropList;
  Index    : integer;
  NewItem  : TVarTypeData;
begin
  TypeData := GetTypeData(aTypeInfo);

  case aTypeInfo.Kind of
    tkClass : begin
      if TypeData.PropCount > 0 then
      begin
        // Loops through all published properties of the class
        new(PropList);

        GetPropInfos(aTypeInfo, PropList);
        for Index := 0 to TypeData.PropCount-1 do
        begin
          // Recursive call for published class properties
          AddToXMLTypeNameList(PropList[Index].Name, PropList[Index].PropType^, aNameList)
        end;

        Dispose(PropList)
      end
    end;
    tkDynArray : begin
      if TypeData.elType2^.Kind in
        [tkInteger, tkChar, tkFloat, tkString, tkWChar, tkLString, tkWString, tkVariant, tkInt64] then
      begin
        //Adds the name and TypeInfo to the Name List
        NewItem.Name     := aName;
        NewItem.TypeInfo := aTypeInfo;
        AddTypeItem(aNameList, NewItem);
      end
      else
      begin
        // Recursive call for array Element Type
        AddToXMLTypeNameList('Array', TypeData.elType2^, aNameList);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.FindXMLTypeNamesToModify(const aMethodName : String;
                                                         var aNameList : TArrVarTypeData);
var
  InterfaceMetaData : TIntfMetaData;
  InterfaceIndex    : integer;
  ParamIndex        : integer;
begin
  // Gets the RTTI info for the the Interface
  GetIntfMetaData(TypeInfo(IBlopiServiceFacade), InterfaceMetaData);

  // Searches for the passed method name in the Info List
  for InterfaceIndex := 0 to high(InterfaceMetaData.MDA) do
  begin
    if InterfaceMetaData.MDA[InterfaceIndex].Name = aMethodName then
    begin
      for ParamIndex := 0 to InterfaceMetaData.MDA[InterfaceIndex].ParamCount - 1 do
      begin
        AddToXMLTypeNameList(InterfaceMetaData.MDA[InterfaceIndex].Params[ParamIndex].Name,
                             InterfaceMetaData.MDA[InterfaceIndex].Params[ParamIndex].Info,
                             aNameList);
      end;
    end;
  end;
end;

procedure TProductConfigService.FreeClientAccVendorsRecord(aClientAccVendors: TClientAccVendors);
var
  Index : integer;
begin
  for Index := 0 to length(aClientAccVendors.ClientVendors)-1 do
    FreeAndNil(aClientAccVendors.ClientVendors[Index]);
  SetLength(aClientAccVendors.ClientVendors, 0);

  for Index := 0 to length(aClientAccVendors.AccountsVendors)-1 do
    FreeAndNil(aClientAccVendors.AccountsVendors[Index].AccountVendors);
  SetLength(aClientAccVendors.AccountsVendors, 0);
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.MaskCreditCardForLogs(const aCurrNode : IXMLNode);
var
  NodeIndex : integer;
  NodeValue : String;
begin
  if not Assigned(aCurrNode) then
    Exit;

  if UpperCase(aCurrNode.NodeName) = 'ACCOUNTNUMBER' then
  begin
    NodeValue := aCurrNode.NodeValue;

    if IsAccountACreditCard(NodeValue) then
      aCurrNode.NodeValue := MaskCreditCard(NodeValue);
  end;

  for NodeIndex := 0 to aCurrNode.ChildNodes.Count - 1 do
  begin
    MaskCreditCardForLogs(aCurrNode.ChildNodes[NodeIndex]);
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.AddXMLNStoArrays(const aCurrNode : IXMLNode;
                                                 var aNameList : TArrVarTypeData);
var
  NodeIndex : integer;
  NamSpcURI : WideString;
  NamSpcPre : WideString;
  ClassName : WideString;
  NodeName  : String;
  EditIndex : integer;
  FindIndex : integer;
  Values : Array of OleVariant;
  IsScalar : Boolean;
begin
  if not Assigned(aCurrNode) then
    Exit;

  // Searches for the Node Name in the passed Name List
  FindIndex := GetTypeItemIndex(aNameList, aCurrNode.LocalName);

  if FindIndex > -1 then
  begin
    if aCurrNode.ChildNodes.Count > 0 then
    begin
      NamSpcPre := 'D5P1';
      // Gets the Name Space URI from the RemClassRegistry, this is added in the
      // Service Facade by the Auto generated code
      RemClassRegistry.InfoToURI(aNameList[FindIndex].TypeInfo, NamSpcURI, ClassName, IsScalar);
      // since it is only fixing arrays it uses the first element name as the node name
      NodeName := aCurrNode.ChildNodes[0].NodeName;

      // Saves values
      SetLength(Values, aCurrNode.ChildNodes.Count);
      for EditIndex := 0 to aCurrNode.ChildNodes.Count - 1 do
        Values[EditIndex] := aCurrNode.ChildNodes[EditIndex].NodeValue;

      // removes all child nodes
      for EditIndex := aCurrNode.ChildNodes.Count - 1 downto 0 do
        aCurrNode.ChildNodes.Delete(EditIndex);

      // Adds the Names Space to the Array Node
      aCurrNode.DeclareNamespace(NamSpcPre, NamSpcURI);

      // ReAdds the Child nodes adding the Name Space Alias
      for EditIndex := 0 to High(Values) do
        aCurrNode.AddChild(NamSpcPre + ':' + NodeName).NodeValue := Values[EditIndex];

      SetLength(Values, 0);
    end;
  end
  else
  begin
    // Recursive call for child nodes
    for NodeIndex := 0 to aCurrNode.ChildNodes.Count - 1 do
      AddXMLNStoArrays(aCurrNode.ChildNodes.Nodes[NodeIndex], aNameList);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.AuthenticateUser(const Domain, Username, Password: String; out AuthenticationResult: TAuthenticationStatus; IgnoreOnlineUser: Boolean = False): Boolean;
var
  AuthenticationService : IP5Auth;
  Response: P5AuthResponse;
  ShowProgress: Boolean;
  OnlineUser: TBloUserRead;
begin
  Result := False;

  AuthenticationResult := paNone;

  try
    ShowProgress := Progress.StatusSilent;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
      begin
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Authenticating User', 50);
      end;

      OnlineUser := ProductConfigService.GetOnlineUserLinkedToCode(Username, FPractice, False);

      if Debugme then
      begin
        LogUtil.LogMsg(lmDebug, UNIT_NAME, 'AuthenticateUser : Assigned(OnlineUser) - ' + booltostr(Assigned(OnlineUser), True));
        LogUtil.LogMsg(lmDebug, UNIT_NAME, 'AuthenticateUser : IgnoreOnlineUser - ' + booltostr(IgnoreOnlineUser, True));
      end;

      if Assigned(OnlineUser) or IgnoreOnlineUser then
      begin
        AuthenticationService := GetAuthenticationServiceFacade;

        if (IgnoreOnlineUser) and (not Assigned(OnlineUser)) then
        begin
          if Debugme then
            LogUtil.LogMsg(lmDebug, UNIT_NAME, 'Before AuthenticateUser Call - SubDomain:' + FSubDomain + ',  Email:' + CurrUser.EmailAddress{ + ',  Password:' + Password});

          Response := AuthenticationService.AuthenticateUser(FSubDomain, CurrUser.EmailAddress, Password);
        end
        else
        begin
          if Debugme then
            LogUtil.LogMsg(lmDebug, UNIT_NAME, 'Before AuthenticateUser Call - SubDomain:' + FSubDomain + ',  Email:' + OnlineUser.EMail{ + ',  Password:' + Password});

          Response := AuthenticationService.AuthenticateUser(FSubDomain, OnlineUser.EMail, Password);
        end;

        if Debugme then
          LogUtil.LogMsg(lmDebug, UNIT_NAME, 'Responce - ' + booltostr(Response.Success, True));

        Result := Response.Success;

        if Response.IsPasswordChangeRequired then
        begin
          AuthenticationResult := paChangePassword;
        end;

        if ShowProgress then
        begin
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
        end;
      end
      else
      begin
        AuthenticationResult := paOffLineUser;
      end;
    finally
      FreeAndNil(Response);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('AuthenticateUser', E);

      AuthenticationResult := paConnectionError;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.DoAfterSecureExecute(const MethodName: string; SOAPResponse: TStream);
var
  Buffer: array[0..255] of Char;
  LogXmlFile : String;
  FileStr : TFileStream;
  StrStream : TStringStream;
  Folder : String;
  BufferPath : packed array[ 0..MAX_PATH ] of Char;
  SearchRec  : TSearchRec;
  FindResult : integer;
  FileDate : TDateTime;
  Document : IXMLDocument;
begin
  if DebugMe then
  begin
    if SHGetSpecialFolderPath(Application.Handle, @BufferPath[0], CSIDL_COOKIES, false) then
    begin
      Folder := BufferPath;
      LogUtil.LogMsg(lmDebug, UNIT_NAME, 'Cookie folder : ' + Folder);

      FindResult := FindFirst(Folder + '\*.*', (faAnyfile) , SearchRec);
      try
        while FindResult = 0 do
        begin
          if ((SearchRec.Attr and faAnyfile) <> 0) then
          begin
            if FileAge(Folder + '\' + SearchRec.Name, FileDate) then
            begin
              if not (SearchRec.Name = 'index.dat') and
                 (incDay(now(), -1) < FileDate) then
              begin
                try
                  FileStr := TFileStream.Create(Folder + '\' + SearchRec.Name, fmOpenRead);
                  try
                    FileStr.Position := 0;
                    FileStr.Read(Buffer, 256);

                    if Pos(uppercase('banklink'), uppercase(Buffer)) > 0 then
                    begin
                      LogUtil.LogMsg(lmDebug, UNIT_NAME, 'BankLink Cookie : ' + SearchRec.Name + ', Date and Time :' + DateTimeToStr(FileDate));
                    end;

                  finally
                    FreeAndNil(FileStr);
                  end;
                except
                  on E:Exception do
                  begin
                    LogUtil.LogMsg(lmError, UNIT_NAME, 'Error Reading Cookie : ' + SearchRec.Name + ', Date and Time :' + DateTimeToStr(FileDate));
                  end;
                end;
              end;
            end;
          end;

          FindResult := FindNext(SearchRec);
        end;

      finally
        SysUtils.FindClose(SearchRec);
      end;
    end;

    LogXmlFile := Globals.DataDir + 'Blopi_Responce_' + MethodName + '_' +
                      FormatDateTime('yyyy-mm-dd hh-mm-ss zzz', Now) + '.txt';

    SOAPResponse.Position :=0;

    // Loads the SoapRequest into a XML Document
    Document := NewXMLDocument;
    try
      StrStream := TStringStream.Create('');
      try
        StrStream.CopyFrom(SOAPResponse, SOAPResponse.Size);

        Document.LoadFromXML(StrStream.DataString);

        if not Document.IsEmptyDoc then
        begin
          MaskCreditCardForLogs(Document.DocumentElement);

          Document.SaveToFile(LogXmlFile);
        end;
      finally
        FreeAndNil(StrStream);
      end;
    finally
      Document := nil;
    end;
  end;

  SOAPResponse.Position := 0;
  SOAPResponse.Read(Buffer, 256);

  if Pos('!DOCTYPE html', Buffer) > 0 then
  begin
    raise EAuthenticationException.Create('You are not authenticated');
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.DoBeforeExecute(const MethodName: string;
                                                var SOAPRequest: InvString);
var
  Document : IXMLDocument;
  NameList : TArrVarTypeData;
  LogXmlFile : String;
begin
  // Fills the passed Name List Array with all the XML Node Names and thier
  // TypeInfo that are arrays and need thier xml name spaces added
  FindXMLTypeNamesToModify(MethodName, NameList);

  if (high(NameList) = -1) and
     (not DebugMe) then
    Exit;

  // Loads the SoapRequest into a XML Document
  Document := NewXMLDocument;
  try
    Document.LoadFromXML(SOAPRequest);

    if not Document.IsEmptyDoc then
    begin
      // Searchs in the XML for the Node Name in the passed NameList and adds
      // the relavant namespace to the node and all elements
      AddXMLNStoArrays(Document.DocumentElement, NameList);

      Document.SaveToXML(SOAPRequest);

      if DebugMe then
      begin
        LogXmlFile := Globals.DataDir + 'Blopi_Request_' + MethodName + '_' +
                      FormatDateTime('yyyy-mm-dd hh-mm-ss zzz', Now) + '.xml';

        MaskCreditCardForLogs(Document.DocumentElement);

        Document.SaveToFile(LogXmlFile);

        LogUtil.LogMsg(lmDebug, UNIT_NAME, Format('Call online method: %s', [MethodName]));
      end;

    end;
  finally
    Document := nil;
  end;
end;

function TProductConfigService.ErrorOccurred: Boolean;
begin
  result := false;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SetTimeOuts(ConnecTimeout : DWord ;
                                            SendTimeout   : DWord ;
                                            ReciveTimeout : DWord);
begin
  InternetSetOption(nil, INTERNET_OPTION_CONNECT_TIMEOUT, Pointer(@ConnecTimeout), SizeOf(ConnecTimeout));
  InternetSetOption(nil, INTERNET_OPTION_SEND_TIMEOUT, Pointer(@SendTimeout), SizeOf(SendTimeout));
  InternetSetOption(nil, INTERNET_OPTION_RECEIVE_TIMEOUT, Pointer(@ReciveTimeout), SizeOf(ReciveTimeout));
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetSecureServiceFacade: IBlopiSecureServiceFacade;
var
  HTTPRIO: THTTPRIO;
begin
  HTTPRIO := THTTPRIO.Create(nil);
  HTTPRIO.OnBeforeExecute := DoBeforeExecute;
  HTTPRIO.OnAfterExecute := DoAfterSecureExecute;

  Result := GetIBlopiSecureServiceFacade(False, GetBanklinkOnlineURL('/services/blopisecureservicefacade.svc'), HTTPRIO);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetSecureServiceFacade(out HTTPRIO: THTTPRIO): IBlopiSecureServiceFacade;
begin
  HTTPRIO := THTTPRIO.Create(nil);
  HTTPRIO.OnBeforeExecute := DoBeforeExecute;
  HTTPRIO.OnAfterExecute := DoAfterSecureExecute;

  Result := GetIBlopiSecureServiceFacade(False, GetBanklinkOnlineURL('/services/blopisecureservicefacade.svc'), HTTPRIO);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetServiceActive: Boolean;
begin
  Result := GetServiceStatus = ssActive;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetServiceAgreementVersion(): WideString;
var
  BlopiInterface: IBlopiServiceFacade;
  ReturnMsg: MessageResponseOfstring;
  ShowProgress : Boolean;
begin
  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;
    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Service Agreement Version', 50);

      BlopiInterface := GetServiceFacade;
      ReturnMsg := BlopiInterface.GetTermsConditionsVersion(CountryText(AdminSystem.fdFields.fdCountry),
                                                            AdminSystem.fdFields.fdBankLink_Code,
                                                            AdminSystem.fdFields.fdBankLink_Connect_Password);
      if not MessageResponseHasError(MessageResponse(ReturnMsg), 'get the service agreement version from') then
      begin
        Result := Copy(ReturnMsg.Result,1,length(ReturnMsg.Result));
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(ReturnMsg);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetServiceAgreementVersion', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetServiceAgreement(): WideString;
var
  BlopiInterface: IBlopiServiceFacade;
  ReturnMsg: MessageResponseOfstring;
  ShowProgress : Boolean;
begin
  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;
    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Service Agreement', 50);

      BlopiInterface := GetServiceFacade;
      ReturnMsg := BlopiInterface.GetTermsAndConditions(CountryText(AdminSystem.fdFields.fdCountry),
                                                        AdminSystem.fdFields.fdBankLink_Code,
                                                        AdminSystem.fdFields.fdBankLink_Connect_Password);
      if not MessageResponseHasError(MessageResponse(ReturnMsg), 'get the service agreement from') then
      begin
        Result := Copy(ReturnMsg.Result, 1, length(ReturnMsg.Result));
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(ReturnMsg);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetServiceAgreement', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetServiceFacade(PracticeCode: string = ''): IBlopiServiceFacade;
var
  HTTPRIO: THTTPRIO;
begin
  HTTPRIO := THTTPRIO.Create(nil);
  HTTPRIO.OnBeforeExecute := DoBeforeExecute;
  HTTPRIO.OnAfterExecute := DoAfterSecureExecute;

  Result := GetIBlopiServiceFacade(False, GetBanklinkOnlineURL('/Services/BlopiServiceFacade.svc'), HTTPRIO);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetServiceStatus: TServiceStatus;
begin
  if Assigned(AdminSystem) then
  begin
    if AdminSystem.fdFields.fdUse_BankLink_Online then
    begin
      if AdminSystem.fdFields.fdBanklink_Online_Suspended then
      begin
        Result := ssSuspended;
      end
      else
      begin
        Result := ssActive;
      end;
    end
    else
    begin
      Result := ssDisabled;
    end;
  end
  else
  begin
    Result := ssDisabled;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetServiceSuspended: Boolean;
begin
  Result := AdminSystem.fdFields.fdBanklink_Online_Suspended;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetCatFromSub(aSubGuid : TBloGuid): TBloCatalogueEntry;
var
  i: integer;
begin
  Result := Nil;
  if Assigned(FPracticeCopy) then begin
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
      if FPracticeCopy.Catalogue[i].id = aSubGuid then
      begin
        Result := FPracticeCopy.Catalogue[i];
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsCICOEnabled: Boolean;
var
  i, j: integer;
  Cat: TBloCatalogueEntry;
begin
  Result := False;
  if not Assigned(FPractice) then
    GetPractice;

  if Assigned(FPractice) then begin
    for i := Low(FPractice.Catalogue) to High(FPractice.Catalogue) do begin
      Cat := FPractice.Catalogue[i];
      if UpperCase(Cat.Id) = PRODUCT_GUID_CICO then begin
        for j := Low(FPractice.Subscription) to High(FPractice.Subscription) do begin
          if FPractice.Subscription[j] = Cat.Id then begin
            Result := True;
            Break;
          end;
        end;
        Break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.UpdateUserAllowOnlineSetting;
var
  AdminUserIndex : integer;
  BlopiUserIndex : integer;
  User           : pUser_Rec;
begin
  if not Assigned(AdminSystem) then
    Exit;

  if not Assigned(FPractice) then
    GetPractice;

  if Assigned(FPractice) then
  begin
    for AdminUserIndex := AdminSystem.fdSystem_User_List.First to
                          AdminSystem.fdSystem_User_List.Last do
    begin
      User := AdminSystem.fdSystem_User_List.User_At(AdminUserIndex);

      User.usAllow_Banklink_Online := False;
      for BlopiUserIndex := Low(FPractice.Users) to High(FPractice.Users) do
      begin
        if User.usCode = FPractice.Users[BlopiUserIndex].UserCode then
        begin
          User.usAllow_Banklink_Online := True;
          Break;
        end;
      end;

      if Assigned(CurrUser) and Assigned(User) then // Checking CurrUser in case the Practice window has been closed
        if CurrUser.Code = User.usCode then
          CurrUser.AllowBanklinkOnline := User.usAllow_Banklink_Online;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetInstitutionList(out aBloArrayOfInstitution : TBloArrayOfInstitution) : TBloResult;
var
  BlopiInterface : IBlopiServiceFacade;
  MsgResponse : MessageResponseOfArrayOfInstitutionMIdCYrSK2;
  ResponceError : Boolean;
  Index : integer;
begin
  Result := bloFailedNonFatal;
  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
  aBloArrayOfInstitution := nil;

  BlopiInterface := GetServiceFacade;
  try
    try
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Retrieving Institution List', 55);

      try
        MsgResponse := BlopiInterface.GetInstitutions(CountryText(AdminSystem.fdFields.fdCountry),
                                                      AdminSystem.fdFields.fdBankLink_Code,
                                                      AdminSystem.fdFields.fdBankLink_Connect_Password);

        ResponceError := MessageResponseHasError(MsgResponse, 'Get Institution List from');

        if not ResponceError then
        begin
          SetLength(aBloArrayOfInstitution, Length(MsgResponse.Result));
          for Index := 0 to Length(aBloArrayOfInstitution)-1 do
          begin
            aBloArrayOfInstitution[Index] := TBloInstitution.Create;
          end;

          CopyRemotableObject(TBloArrayOfRemotable(MsgResponse.Result), TBloArrayOfRemotable(aBloArrayOfInstitution));

          Result := bloSuccess;
          LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Successfully retrieved Institutions from ' + BRAND_ONLINE + '.');
        end
        else
        begin
          LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Institutions were not retrieved from ' + BRAND_ONLINE + '.');
          result := bloFailedFatal;
        end;

      finally
        FreeAndNil(MsgResponse);
      end;

      if not ResponceError then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);

    except
      on E : Exception do
      begin
        HandleException('GetInstitutionList', E);
        Result := bloFailedFatal;
      end;
    end;
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.ValidateAccount(aAccountNumber, aInstCode, aCountryCode: string; var aFailedReason: string; aSupressProgress : boolean): TBloResult;
var
  AccountList: TBloArrayOfAccountValidation;
  ErrorString : string;
begin
  aFailedReason := '';
  Result := bloFailedFatal;

  SetLength(AccountList, 1);
  AccountList[0] := TBloAccountValidation.create;

  try
    AccountList[0].AccountNumber    := aAccountNumber;
    AccountList[0].InstitutionCode  := aInstCode;
    AccountList[0].CountryCode      := aCountryCode;
    AccountList[0].FailureReason    := '';
    AccountList[0].ValidationPassed := false;

    Result := ValidateAccountList(AccountList, aSupressProgress, ErrorString);
    if (Result = bloSuccess) then
    begin
      if not AccountList[0].ValidationPassed then
      begin
        Result := bloFailedFatal;
        aFailedReason := AccountList[0].FailureReason;
      end;
    end
    else if (Result = bloFailedNonFatal) then
    begin
      aFailedReason := ErrorString;
    end;

  finally
    FreeAndNil(AccountList[0]);
    SetLength(AccountList, 0);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.ValidateAccountList(var aValidateAccountList: TBloArrayOfAccountValidation; aSupressProgress : boolean; var aErrorString : string): TBloResult;
Const
  VALUE_CANNT_BE_NULL = 'Value cannot be null';
var
  BlopiInterface  : IBlopiServiceFacade;
  MsgResponse     : MessageResponseOfArrayOfAccountValidationMIdCYrSK;
  ResponceError   : Boolean;
  ErrIndex : integer;
begin
  Result := bloFailedNonFatal;
  Screen.Cursor := crHourGlass;
  aErrorString := '';

  if not aSupressProgress then
  begin
    Progress.StatusSilent := False;
    Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
  end;

  BlopiInterface := GetServiceFacade;
  try
    try
      if not aSupressProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Validate Account List', 55);

      try
        MsgResponse := BlopiInterface.ValidateAccounts(CountryText(AdminSystem.fdFields.fdCountry),
                                                       AdminSystem.fdFields.fdBankLink_Code,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                       aValidateAccountList);

        ResponceError := MessageResponseHasError(MsgResponse, 'Validate Account List from',false,0,'',not aSupressProgress);

        if not ResponceError then
        begin
          if Length(aValidateAccountList) = Length(MsgResponse.Result) then
          begin
            CopyRemotableObject(TBloArrayOfRemotable(MsgResponse.Result), TBloArrayOfRemotable(aValidateAccountList));

            Result := bloSuccess;
            LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Successfully validated Account List from ' + BRAND_ONLINE + '.');
          end
          else
          begin
            LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Account List returned did not match list sent to ' + BRAND_ONLINE + '.');
            result := bloFailedFatal;
          end;
        end
        else
        begin
          if length(MsgResponse.Exceptions) > 0 then
          begin
            if pos(VALUE_CANNT_BE_NULL, MsgResponse.Exceptions[0].Message_) > 0 then
            begin
              for ErrIndex := 0 to high(MsgResponse.Exceptions) do
              begin
                aErrorString := aErrorString + 'Message' + MsgResponse.Exceptions[ErrIndex].Message_ + #13#10;
                aErrorString := aErrorString + 'Source' + MsgResponse.Exceptions[ErrIndex].Source + #13#10;
                aErrorString := aErrorString + 'StackTrace' + MsgResponse.Exceptions[ErrIndex].StackTrace + #13#10;
              end;

              LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Account List was not validated from ' + BRAND_ONLINE + '.' +
                             #13#10 + aErrorString);
              result := bloFailedNonFatal;
            end;
          end
          else
          begin
            LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Account List was not validated from ' + BRAND_ONLINE + '.');
            result := bloFailedFatal;
          end;
        end;

      finally
        FreeAndNil(MsgResponse);
      end;

      if not ResponceError then
        if not aSupressProgress then
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);

    except
      on E : Exception do
      begin
        HandleException('ValidateAccountList', E);
        Result := bloFailedFatal;
      end;
    end;
  finally
    if not aSupressProgress then
    begin
      Progress.StatusSilent := True;
      Progress.ClearStatus;
    end;

    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetPracUpgReminderMsg(var aLatestVersion, aReminderVersion, aReminderMessage : string; aSupressProgress : boolean): TBloResult;
var
  BlopiInterface  : IBlopiServiceFacade;
  MsgResponse     : MessageResponseOfPracticeUpgradeReminderMIdCYrSK;
  ResponceError   : Boolean;
begin
  Result := bloFailedNonFatal;
  aLatestVersion := '';
  aReminderVersion := '';
  aReminderMessage := '';

  Screen.Cursor := crHourGlass;

  if not aSupressProgress then
  begin
    Progress.StatusSilent := False;
    Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
  end;

  BlopiInterface := GetServiceFacade;
  try
    try
      if not aSupressProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Retrieve Reminder Message', 55);

      try
        MsgResponse := BlopiInterface.GetPracticeUpgradeReminder(CountryText(AdminSystem.fdFields.fdCountry),
                                                                 AdminSystem.fdFields.fdBankLink_Code,
                                                                 AdminSystem.fdFields.fdBankLink_Connect_Password);

        ResponceError := MessageResponseHasError(MsgResponse, 'Retrieve Reminder Message from', false, 0, '', false);

        if not ResponceError then
        begin
          aLatestVersion := Copy(MsgResponse.Result.LatestVersion , 1, Length(MsgResponse.Result.LatestVersion));
          aReminderVersion := Copy(MsgResponse.Result.ReminderVersion , 1, Length(MsgResponse.Result.ReminderVersion));
          aReminderMessage := Copy(MsgResponse.Result.ReminderMessage , 1, Length(MsgResponse.Result.ReminderMessage));

          Result := bloSuccess;
          LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Successfully Retrieved Reminder Message from ' + BRAND_ONLINE + '.');
        end
        else
        begin
          LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Reminder Message was not retrieved from ' + BRAND_ONLINE + '.');
          result := bloFailedFatal;
        end;

      finally
        FreeAndNil(MsgResponse);
      end;

      if not ResponceError then
        if not aSupressProgress then
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);

    except
      on E : Exception do
      begin
        HandleException('GetPracUpgReminderMsg', E, true);
        Result := bloFailedFatal;
      end;
    end;
  finally
    if not aSupressProgress then
    begin
      Progress.StatusSilent := True;
      Progress.ClearStatus;
    end;

    Screen.Cursor := crDefault;
  end;
end;

// Get list of vendors enabled for the practice
//------------------------------------------------------------------------------
function TProductConfigService.VendorEnabledForPractice(ClientVendorGuid: TBloGuid): boolean;
var
  PracticeExportDataService   : TBloDataPlatformSubscription;
  AvailableServiceArray : TBloArrayOfDataPlatformSubscriber;
  i: integer;
begin
  try
    PracticeExportDataService := GetPracticeVendorExports;
    if Assigned(PracticeExportDataService) then
      AvailableServiceArray := PracticeExportDataService.Current;

    Result := False;
    for i := 0 to High(AvailableServiceArray) do
    begin
      if (ClientVendorGuid = AvailableServiceArray[i].Id) then
      begin
        Result := True;
        break;
      end;
    end;
  finally
    FreeAndNil(PracticeExportDataService);
    SetLength(AvailableServiceArray, 0);
    AvailableServiceArray := nil;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.VendorExportExists(VendorExports: ArrayOfDataPlatformSubscriber; VendorExportGuid: TBloGuid): Boolean;
var
  Index: Integer;
begin
  Result := False;
  
  for Index := 0 to Length(VendorExports) - 1 do
  begin
    if GuidsEqual(VendorExports[Index].Id, VendorExportGuid) then
    begin
      Result := True;

      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetNotesId : TBloGuid;
var
  i   : integer;
  Cat : TBloCatalogueEntry;
begin
  Result := '';
  if Assigned(FPractice) then
  begin
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do
    begin
      Cat := FPracticeCopy.Catalogue[i];
      if UpperCase(Cat.Id) = PRODUCT_GUID_NOTES_ONLINE then
      begin
        Result := Cat.Id;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsNotesOnlineEnabled: Boolean;
var
  i       : integer;
  NotesId : TBloGuid;
begin
  Result := False;

  NotesId := GetNotesId;
  if not(NotesId = '') then
  begin
    for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do
    begin
      if FPracticeCopy.Subscription[i] = NotesId then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsPracticeActive(aShowWarning: Boolean): Boolean;
begin
  Result := (OnlineStatus = Active);

  if AShowWarning then
    ShowSuspendDeactiveWarning;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsPracticeDeactivated(aShowWarning: Boolean): boolean;
begin
  Result := (OnlineStatus = Deactivated);

  if AShowWarning then
    ShowSuspendDeactiveWarning;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsPracticeSuspended(aShowWarning: Boolean): boolean;
begin
  Result := (OnlineStatus = Suspended);

  if AShowWarning then
    ShowSuspendDeactiveWarning;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsPracticeProductEnabled(AProductId: TBloGuid; AUsePracCopy : Boolean): Boolean;
var
  i: integer;
  Prac : TBloPracticeRead;
begin
  if AUsePracCopy then
    Prac := FPracticeCopy
  else
    Prac := FPractice;

  Result := False;
  if Assigned(Prac) then begin
    for i := Low(Prac.Subscription) to High(Prac.Subscription) do begin
      if Prac.Subscription[i] = AProductID then begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.HandleException(const MethodName: String; E: Exception; SuppressErrors: Boolean);
var
  MainMessage: String;
  MessageDetails: String;
  ShowDetails: Boolean;
begin
  MainMessage := Format('%s encountered a problem while connecting to %s. Please see the details below or contact ' + BRAND_SUPPORT + ' for assistance.', [bkBranding.PracticeProductName, BRAND_ONLINE]);

  MessageDetails := E.Message;

  ShowDetails := True;

  if E is ESOAPHTTPException then
  begin
    if (Pos(' - URL:', E.Message) > 0) then
    begin
      MessageDetails := Copy(MessageDetails, 0, Pos(' - URL:', E.Message) -1) + '.';
    end;
  end
  else
  if E is EDOMParseError then
  begin
    MainMessage := Format('%s encountered a problem connecting to %s. Please contact ' + BRAND_SUPPORT + ' for assistance', [bkBranding.PracticeProductName, BRAND_ONLINE]);
    
    ShowDetails := False;
  end;

  if not SuppressErrors then
  begin
    HelpfulErrorMsg(MainMessage, 0, True, MessageDetails, ShowDetails);
  end;

  LogUtil.LogMsg(lmError, UNIT_NAME, Format('Exception running %s, Error Message : %s', [MethodName, E.Message]));

  FExceptionRaised := True;
end;

//------------------------------------------------------------------------------
function TProductConfigService.HasProductJustBeenTicked(AProductId: TBloGuid): Boolean;
begin
  Result := (not IsPracticeProductEnabled(AProductID, False)) and IsPracticeProductEnabled(AProductID, True); 
end;

//------------------------------------------------------------------------------
function TProductConfigService.HasProductJustBeenUnTicked(AProductId: TBloGuid): Boolean;
begin
  // Was the Product Ticked and is it currently unticked
  Result := (IsPracticeProductEnabled(AProductId, False)) and
            (not IsPracticeProductEnabled(AProductId, True));
end;

//------------------------------------------------------------------------------
function TProductConfigService.ReAuthenticateUser(out Cancelled, OfflineAuthentication: Boolean; IgnoreOnlineStatus: Boolean = False): Boolean;
var
  Password: String;
  PasswordReset : boolean;
begin
  Result := False;

  if Debugme then
  begin
    LogUtil.LogMsg(lmDebug, UNIT_NAME, 'ReAuthenticateUser : CurrUser.AllowBanklinkOnline - ' + booltostr(CurrUser.AllowBanklinkOnline, True));
    LogUtil.LogMsg(lmDebug, UNIT_NAME, 'ReAuthenticateUser : IgnoreOnlineStatus - ' + booltostr(IgnoreOnlineStatus, True));
    LogUtil.LogMsg(lmDebug, UNIT_NAME, 'ReAuthenticateUser : OfflineAuthentication - ' + booltostr(OfflineAuthentication, True));
  end;

  if CurrUser.AllowBanklinkOnline or IgnoreOnlineStatus then
  begin
    try
      Password := CurrUser.Password;

      repeat
        if TfrmLogin.LoginOnline(Curruser.Code, CurrUser.FullName, Password, Cancelled, OfflineAuthentication, IgnoreOnlineStatus) then
        begin
          CurrUser.Password := Password;

          Result := True;
        end
        else
        begin
          if OfflineAuthentication then
          begin
            HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to authenticate with ' + BRAND_ONLINE + '. Please contact ' + BRAND_SUPPORT + ' for assistance.', 0);

            LogUtil.LogMsg(lmError, UNIT_NAME, 'An error occurred while authenticating with ' + BRAND_ONLINE + '.');

            Exit;
          end
          else
          if Cancelled then
          begin
            Exit;
          end
          else
          begin
            if not TfrmOnlinePassword.PromptUser(Password, CurrUser.EmailAddress, PasswordReset) then
            begin
              HelpfulErrorMsg(bkBranding.PracticeProductName + ' authentication with ' + BRAND_ONLINE + ' failed. Please contact ' + BRAND_SUPPORT + ' for assistance.', 0);

              LogUtil.LogMsg(lmError, UNIT_NAME, ' authentication with ' + BRAND_ONLINE + ' failed.');

              Exit;
            end;

            if PasswordReset then
              Exit;
          end;
        end;
      until Result;
    except
      on E:Exception do
      begin
        HandleException('ReAuthenticateUser', E);
      end;
    end;
  end
  else
  begin
    HelpfulErrorMsg('You are not a ' + BRAND_ONLINE + ' enabled user. Only ' + BRAND_ONLINE + ' enabled users can update ' + BRAND_ONLINE + '. Please contact ' + BRAND_SUPPORT + ' for assistance.', 0);

    LogUtil.LogMsg(lmError, UNIT_NAME, 'An error occurred while authenticating with ' + BRAND_ONLINE + '.');

    Exit;  
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.RemotableObjectToXML(
  ARemotable: TRemotable): string;
var
  Converter: IObjConverter;
  NodeObject: IXMLNode;
  NodeParent: IXMLNode;
  NodeRoot: IXMLNode;
  XMLDoc: IXMLDocument;
  XMLStr: WideString;
begin
  Result := '';
  try
    XMLDoc:= NewXMLDocument;
    NodeRoot:= XMLDoc.AddChild('Root');
    NodeParent:= NodeRoot.AddChild('Parent');
    Converter:= TSOAPDomConv.Create(NIL);
    NodeObject:= ARemotable.ObjectToSOAP(NodeRoot, NodeParent, Converter,
                                         'CopyObject', '', [ocoDontPrefixNode],
                                         XMLStr);
    Result := XMLDoc.XML.Text;
  except
    on E:Exception do
    begin
      HandleException('RemotableObjectToXML', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.RemoveInvalidSubscriptions;
var
  i, j: integer;
  GuidList: TStringList;
  Found: Boolean;
begin
  GuidList := TStringList.Create;
  try
    //Remove any subscriptions that aren't in the catalogue
    for i := Low(FPracticeCopy.Subscription) to High(FPracticeCopy.Subscription) do begin
      Found := False;
      for j := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
        if FPracticeCopy.Subscription[i] = FPracticeCopy.Catalogue[j].Id then
          Found := True;
      end;
      if not Found then
        GuidList.Add(FPracticeCopy.Subscription[i]);
    end;
    for i  := 0 to GuidList.Count - 1 do
      RemoveProduct(GuidList[i]);
  finally
    GuidList.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.ShowSuspendDeactiveWarning;
begin
  case OnlineStatus of
    Suspended: HelpfulWarningMsg(BRAND_ONLINE + ' is currently in suspended ' +
                                 '(read-only) mode. Please contact ' + BRAND_SUPPORT +
                                 ' for further assistance.', 0);
    Deactivated: HelpfulWarningMsg(BRAND_ONLINE + ' is currently deactivated. ' +
                                   'Please contact ' + BRAND_SUPPORT + ' for further ' +
                                   'assistance.', 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SuspendService;
begin
  if LoadAdminSystem(True, 'BankLinkOnlineServices') then
  begin
    try
      AdminSystem.fdFields.fdBanklink_Online_Suspended := True;

      SaveAdminSystem;
    except
      if AdminIsLocked then
      begin
        UnlockAdmin;
      end;
      
      raise;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SynchronizeClientSettings(BlopiClient: TBloClientReadDetail);
var
  UserEmail: String;
  UserName: String;
  NotesId : TBloGuid;
  Subscription: TBloArrayOfguid;
  BlopiClientChanged: Boolean;
  PrimaryUser: TBloUserRead;
begin
  if Assigned(MyClient) then
  begin
    if MyClient.clFields.clCode = BlopiClient.ClientCode then
    begin
      Subscription := BlopiClient.Subscription;

      BlopiClientChanged := False;

      if not MyClient.clFields.clFile_Read_Only then
      begin
        if (MyClient.clFields.clWeb_Export_Format <> wfWebNotes) then
        begin
          NotesId := GetNotesId;

          if IsItemInArrayGuid(Subscription, NotesId) then
          begin
            RemoveItemFromArrayGuid(Subscription, NotesId);

            BlopiClientChanged := True;
          end;
        end;

        if BlopiClient.SecureCode <> MyClient.clFields.clBankLink_Code then
        begin
          BlopiClientChanged := True;
        end;
      end;

      if BlopiClientChanged then
      begin
        PrimaryUser := BlopiClient.GetPrimaryUser;

        if Assigned(PrimaryUser) then
        begin
          UserEmail := PrimaryUser.Email;
          UserName := PrimaryUser.FullName;
        end else
        begin
          UserEmail := MyClient.clFields.clClient_EMail_Address;
          UserName := MyClient.clFields.clContact_Name;
        end;

        if ProductConfigService.UpdateClient(BlopiClient,
                                             BlopiClient.BillingFrequency,
                                             BlopiClient.MaxOfflineDays,
                                             BlopiClient.Status,
                                             Subscription,
                                             UserEmail,
                                             UserName,
                                             False) then
        begin
          BlopiClient.Subscription := Subscription;
          
          BlopiClient.SecureCode := MyClient.clFields.clBankLink_Code;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.RemoveProduct(AProductId: TBloGuid; ShowClientWarning: boolean = True): string;
var
  i, j: integer;
  SubArray: TBloArrayOfGuid;
  ClientsUsingProduct: integer;
  Msg: string;
  TempCatalogueEntry: TBloCatalogueEntry;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
    'RemoveProduct ' + GuidToDesc(aProductId)
  );

  Result := '';
  try
    if not Assigned(FClientList) then
      LoadClientList;

    if not Assigned(FClientList) then
      raise Exception.Create('Error getting client detials from ' + BRAND_ONLINE);

    ClientsUsingProduct := 0;
    //Check if any clients are using the product
    for i := Low(FClientList.Clients) to High(FClientList.Clients) do begin
      for j := Low(FClientList.Clients[i].Subscription) to High(FClientList.Clients[i].Subscription) do begin
        if (FClientList.Clients[i].Status <> Deactivated) and (AProductId = FClientList.Clients[i].Subscription[j]) then
        begin
          if AdminSystem.fdSystem_Client_File_List.FindCode(FClientList.Clients[i].ClientCode) <> nil then
          begin
            Inc(ClientsUsingProduct);
          end;
        end;
      end;
    end;

    TempCatalogueEntry := GetCatalogueEntry(AProductId);
    if Assigned(TempCatalogueEntry) then begin
      if ClientsUsingProduct > 0 then begin
        if ClientsUsingProduct = 1 then
          Msg := Format('There is currently 1 client using %s. Please remove ' +
                        'access for this client from this product before ' +
                        'disabling it',
                        [TempCatalogueEntry.Description])
        else
          Msg := Format('There are currently %d clients using %s. Please remove ' +
                        'access for these clients from this product before ' +
                        'disabling it',
                        [ClientsUsingProduct, TempCatalogueEntry.Description]);
        if ShowClientWarning then
          HelpfulWarningMsg(Msg, 0)
        else
          Result := Msg; // In this case, the method which calls RemoveProduct will be displaying the message, so that several warnings can be shown together
        Exit;
      end;
    end;

    SubArray := FPracticeCopy.Subscription;
    try
      for i := Low(SubArray) to High(SubArray) do begin
        if AProductId = SubArray[i] then begin
          if (i < 0) or (i > High(SubArray)) then
            Break;
          for j := i to High(SubArray) - 1 do begin
            SubArray[j] := SubArray[j+1];
          end;
          SubArray[High(SubArray)] := '';
          SetLength(SubArray, Length(SubArray) - 1);
          Break;
        end;
      end;
    finally
      FPracticeCopy.Subscription := SubArray;
    end;
  except
    on E: Exception do
    begin
      HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to remove the product. Please contact ' + BRAND_SUPPORT + ' for assistance.', 0);

      LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running RemoveProduct, Error Message : ' + E.Message);

      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.ResetExceptionTest;
begin
  FExceptionRaised := False;
end;

function TProductConfigService.ResetPracticeUserPassword(const EmailAddress: String; UserGuid: TBloGuid): Boolean;
var
  BlopiInterface: IBlopiSecureServiceFacade;
  MsgResponse: MessageResponse;
  Cancelled: Boolean;
  ConnectionError: Boolean;
begin
  Result := False;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  BlopiInterface := GetSecureServiceFacade;
  try
    try
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Resetting user password', 70);

      try
        if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
          'ResetPracticeUserPassword for ' + EmailAddress
        );

        MsgResponse := BlopiInterface.ResetPracticeUserPassword(CountryText(AdminSystem.fdFields.fdCountry),
                                               AdminSystem.fdFields.fdBankLink_Code,
                                               AdminSystem.fdFields.fdBankLink_Connect_Password,
                                               UserGuid);

      except
        on E: EAuthenticationException do
        begin
          if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
          begin
            if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
              'ResetPracticeUserPassword for ' + EmailAddress
            );

            MsgResponse := BlopiInterface.ResetPracticeUserPassword(CountryText(AdminSystem.fdFields.fdCountry),
                                             AdminSystem.fdFields.fdBankLink_Code,
                                             AdminSystem.fdFields.fdBankLink_Connect_Password,
                                             UserGuid);
          end
          else
          begin
            Exit;
          end;
        end;
      end;


      if not MessageResponseHasError(MsgResponse, 'reset user password on') then
      begin
        HelpfulInfoMsg(Format('The user password for %s has been successfully reset on %s.',[EMailAddress, BRAND_ONLINE]), 0);

        LogUtil.LogMsg(lmInfo, UNIT_NAME, 'The user password for ' + EMailAddress + ' has been successfully reset on ' + BRAND_ONLINE + '.');

        Result := True;
      end
      else
      begin
        LogUtil.LogMsg(lmInfo, UNIT_NAME, 'The user password for ' + EMailAddress + ' was not reset on ' + BRAND_ONLINE + '.');
      end;
    except
      on E : Exception do
      begin
        HandleException('ResetPracticeUserPassword', E);
      end;
    end;
  finally
    FreeAndNil(MsgResponse);

    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.ResetPracticeUserPasswordUnSecure(const aEmailAddress: String): Boolean;
var
  BlopiInterface: IBlopiServiceFacade;
  MsgResponse: MessageResponse;
begin
  Result := False;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  BlopiInterface := GetServiceFacade;
  try
    try
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Resetting user password', 70);

      if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
        'ResetUserPassword for ' + aEmailAddress
      );

      MsgResponse := BlopiInterface.ResetUserPassword(CountryText(AdminSystem.fdFields.fdCountry),
                                                      AdminSystem.fdFields.fdBankLink_Code,
                                                      aEmailAddress);

      if not MessageResponseHasError(MsgResponse, 'reset user password on') then
      begin
        HelpfulInfoMsg(Format('A temporary password has been sent to %s.',[aEMailAddress]), 0);

        LogUtil.LogMsg(lmInfo, UNIT_NAME, 'The user password for ' + aEMailAddress + ' has been successfully unsecure reset on ' + BRAND_ONLINE + '.');

        Result := True;
      end
      else
      begin
        LogUtil.LogMsg(lmInfo, UNIT_NAME, 'The user password for ' + aEMailAddress + ' was not unsecurely reset on ' + BRAND_ONLINE + '.');
      end;
    except
      on E : Exception do
      begin
        HandleException('ResetPracticeUserPassword', E);
      end;
    end;
  finally
    FreeAndNil(MsgResponse);

    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.ResumeService;
begin
  if LoadAdminSystem(True, 'BankLinkOnlineServices') then
  begin
    try
      AdminSystem.fdFields.fdBanklink_Online_Suspended := False;

      SaveAdminSystem;
    except
      if AdminIsLocked then
      begin
        UnlockAdmin;
      end;
      
      raise;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.SavePractice(aShowMessage : Boolean; ShowSuccessMessage: Boolean = True): Boolean;
var
  BlopiInterface : IBlopiServiceFacade;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  PracUpdate      : PracticeUpdate;
begin
  Result := False;
  if Assigned(FPracticeCopy) then
  begin
    FPractice.Free;
    FPractice := PracticeRead.Create;

    PracUpdate := PracticeUpdate.Create;
    try
      RemoveInvalidSubscriptions;
      CopyRemotableObject(FPracticeCopy, FPractice);
      CopyRemotableObject(FPractice, PracUpdate);

      //Save to the web service
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
      try
        PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
        PracCode        := AdminSystem.fdFields.fdBankLink_Code;
        PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

        BlopiInterface := GetServiceFacade;

        Progress.UpdateAppStatus(BRAND_ONLINE, 'Saving Practice Details', 33);

        if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
          'SavePractice'
        );

        MsgResponce := BlopiInterface.SavePractice(PracCountryCode, PracCode, PracPassHash, PracUpdate);
        if not MessageResponseHasError(MsgResponce, 'update the Practice settings to') then
        begin
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Saving Practice Details to System Database', 66);
          Result := True;
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
        end;

      finally
        FreeAndNil(MsgResponce);

        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;

    finally
      FreeandNil(PracUpdate);
    end;

    if aShowMessage then
    begin
      if Result then
      begin
        if ShowSuccessMessage then
        begin
          HelpfulInfoMsg('Practice Settings have been successfully updated to ' + BRAND_ONLINE + '.', 0);
        end;
      end
      else
        HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to update the Practice settings to ' + BRAND_ONLINE + '.', 0);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SavePracticeDetailsToSystemDB(ARemotable: TRemotable);
begin
  if not Assigned(AdminSystem) then
    Exit;

  AdminSystem.fdFields.fdBankLink_Online_Config := RemotableObjectToXML(ARemotable);
end;

//------------------------------------------------------------------------------
function TProductConfigService.SavePracticeVendorExports(VendorExports: TBloArrayOfGuid; aShowMessage: Boolean): Boolean;
var
  BlopiInterface : IBlopiServiceFacade;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  PracUpdate      : PracticeUpdate;
begin
  Result := False;
  if UseBankLinkOnline then
  begin
    if Assigned(FPracticeCopy) then
    begin
      FPractice.Free;
      FPractice := PracticeRead.Create;

      PracUpdate := PracticeUpdate.Create;
      try
        RemoveInvalidSubscriptions;
        CopyRemotableObject(FPracticeCopy, FPractice);
        CopyRemotableObject(FPractice, PracUpdate);

        //Save to the web service
        Screen.Cursor := crHourGlass;
        Progress.StatusSilent := False;
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
        try
          PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
          PracCode        := AdminSystem.fdFields.fdBankLink_Code;
          PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

          BlopiInterface := GetServiceFacade;

          Progress.UpdateAppStatus(BRAND_ONLINE, 'Saving Practice data export settings', 33);

          if DebugMe then
            LogGuids('SavePracticeDataSubscribers', VendorExports);

          MsgResponce := BlopiInterface.SavePracticeDataSubscribers(PracCountryCode, PracCode, PracPassHash, VendorExports);

          if not MessageResponseHasError(MsgResponce, 'update the Practice data export settings to') then
          begin
            Result := True;
            Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
          end;

        finally
          Progress.StatusSilent := True;
          Progress.ClearStatus;
          Screen.Cursor := crDefault;
        end;

      finally
        FreeAndNil(MsgResponce);
        FreeAndNil(PracUpdate);
      end;

      if not Result and aShowMessage then
      begin
        HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to update the Practice data export settings to ' + BRAND_ONLINE + '.', 0);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.SaveClientVendorExports(aClientId : TBloGuid;
                                                       aVendorExports: TBloArrayOfGuid;
                                                       aShowMessage: Boolean = True;
                                                       ShowProgressBar: Boolean = true;
                                                       ShowSuccessMessage: Boolean = True): Boolean;
var
  BlopiInterface : IBlopiServiceFacade;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  PracUpdate      : PracticeUpdate;
begin
  Result := False;
  if UseBankLinkOnline then
  begin
    if Assigned(FPracticeCopy) then
    begin
      FPractice.Free;
      FPractice := PracticeRead.Create;

      PracUpdate := PracticeUpdate.Create;
      try
        RemoveInvalidSubscriptions;
        CopyRemotableObject(FPracticeCopy, FPractice);
        CopyRemotableObject(FPractice, PracUpdate);

        //Save to the web service
        Screen.Cursor := crHourGlass;
        Progress.StatusSilent := False;
        if ShowProgressBar then
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
        try
          PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
          PracCode        := AdminSystem.fdFields.fdBankLink_Code;
          PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

          BlopiInterface := GetServiceFacade;
          if ShowProgressBar then
            Progress.UpdateAppStatus(BRAND_ONLINE, 'Saving Client data export settings', 33);

          if DebugMe then
            LogGuids('SaveClientDataSubscribers', aVendorExports
          );

          MsgResponce := BlopiInterface.SaveClientDataSubscribers(PracCountryCode,
                                                                  PracCode,
                                                                  PracPassHash,
                                                                  aClientId,
                                                                  aVendorExports);

          if not MessageResponseHasError(MsgResponce, 'update the Client data export settings to') then
          begin
            Result := True;
            if ShowProgressBar then                 
              Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
          end;

        finally
          Progress.StatusSilent := True;
          Progress.ClearStatus;
          Screen.Cursor := crDefault;
        end;

      finally
        FreeAndNil(MsgResponce);
        FreeAndNil(PracUpdate);
      end;

      if aShowMessage then
      begin
        if Result then
        begin
          if ShowSuccessMessage then
          begin
            HelpfulInfoMsg('Client data export settings have been successfully updated to ' + BRAND_ONLINE + '.', 0);
          end;
        end
        else
        begin
          HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to update the Client data export settings to ' + BRAND_ONLINE + '.', 0);
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.SaveAccountVendorExports(aClientId : TBloGuid;
                                                        aAccountID : Integer;
                                                        aAccountName: String;
                                                        aAccountNumber: String;
                                                        aVendorExports: TBloArrayOfGuid;
                                                        aShowMessage: Boolean = True;
                                                        ShowProgressBar: Boolean = True;
                                                        ShowSuccessMessage: Boolean = True): Boolean;
var
  BlopiInterface : IBlopiServiceFacade;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  PracUpdate      : PracticeUpdate;
  AccountData     : DataPlatformBankAccount;
begin
  Result := False;
  if UseBankLinkOnline then
  begin
    if Assigned(FPracticeCopy) then
    begin
      FPractice.Free;
      FPractice := PracticeRead.Create;

      PracUpdate := PracticeUpdate.Create;
      try
        RemoveInvalidSubscriptions;
        CopyRemotableObject(FPracticeCopy, FPractice);
        CopyRemotableObject(FPractice, PracUpdate);

        //Save to the web service
        Screen.Cursor := crHourGlass;
        Progress.StatusSilent := False;
        if ShowProgressBar then
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
        try
          PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
          PracCode        := AdminSystem.fdFields.fdBankLink_Code;
          PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

          BlopiInterface := GetServiceFacade;

          if ShowProgressBar then
            Progress.UpdateAppStatus(BRAND_ONLINE, 'Saving Account data export settings', 33);

          AccountData := DataPlatformBankAccount.Create;

          try
            AccountData.AccountId := aAccountID;
            AccountData.AccountName := aAccountName;
            AccountData.AccountNumber := aAccountNumber;
            AccountData.Subscribers := aVendorExports;

            if DebugMe then
              LogGuids('SaveBankAccountDataSubscribers for ' + AccountData.AccountNumber, aVendorExports);

            MsgResponce := BlopiInterface.SaveBankAccountDataSubscribers(PracCountryCode,
                                                                         PracCode,
                                                                         PracPassHash,
                                                                         aClientId,
                                                                         AccountData);

            if not MessageResponseHasError(MsgResponce, 'update the Account data export settings to') then
            begin
              Result := True;
              if ShowProgressBar then
                Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
            end;
          finally
            AccountData.Free;
          end;
        finally
          Progress.StatusSilent := True;
          Progress.ClearStatus;
          Screen.Cursor := crDefault;
        end;

      finally
        FreeAndNil(MsgResponce);
        FreeAndNil(PracUpdate);
      end;

      if aShowMessage then
      begin
        if Result then
        begin
          if ShowSuccessMessage then
          begin
            HelpfulInfoMsg('Account data export settings have been successfully updated to ' + BRAND_ONLINE + '.', 0);
          end;
        end
        else
        begin
          HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to update the Account data export settings to ' + BRAND_ONLINE + '.', 0);
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SaveRemotableObjectToFile(ARemotable: TRemotable);
var
  XMLDoc: IXMLDocument;
begin
  XMLDoc:= NewXMLDocument;
  XMLDoc.LoadFromXML(RemotableObjectToXML(ARemotable));
  XMLDoc.SaveToFile(ARemotable.ClassName + '.xml');
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SelectAllProducts;
var
  i: integer;
  Cat: TBloCatalogueEntry;
  SubArray: TBloArrayOfGuid;
begin
  SubArray := FPracticeCopy.Subscription;
  try
    SetLength(SubArray, Length(FPracticeCopy.Catalogue));
    for i := Low(FPracticeCopy.Catalogue) to High(FPracticeCopy.Catalogue) do begin
      Cat := FPracticeCopy.Catalogue[i];
      SubArray[i] := Cat.Id;
    end;
  finally
    FPracticeCopy.Subscription := SubArray;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.SetPrimaryContact(AUser: TBloUserRead);
begin
  FPracticeCopy.DefaultAdminUserId := AUser.Id;
end;

{ TClientHelper }
//------------------------------------------------------------------------------
function TClientHelper.GetClientConnectDays: string;
begin
  Result := '90';
end;

//------------------------------------------------------------------------------
function TClientHelper.GetDeactivated: boolean;
begin
  Result := true;
end;

//------------------------------------------------------------------------------
function TClientHelper.GetFreeTrialEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

//------------------------------------------------------------------------------
function TClientHelper.GetPrimaryUser: TBloUserRead;
var
  Index: Integer;
begin
  Result := nil;

  if Length(Users) > 0 then
  begin
    for Index := 0 to Length(Users) - 1 do
    begin
      if CompareText(Users[Index].Id, PrimaryContactUserId) = 0 then
      begin
        Result := Users[Index];

        Break;
      end;
    end;

    if (Result = nil) then
    begin
      Result := Users[0];
    end;
  end;
end;

//------------------------------------------------------------------------------
function TClientHelper.GetSuspended: boolean;
begin
  Result := (Self.Status = BlopiServiceFacade.Suspended);
end;

//------------------------------------------------------------------------------
function TClientHelper.GetUserOnTrial: boolean;
begin
  Result := false;
end;

//------------------------------------------------------------------------------
procedure TClientHelper.UpdateAdminUser(AUserName, AEmail: WideString);
var
  UserArray : ArrayOfUserRead;
  RoleArray : TBloArrayOfString;
  NewUser   : TBloUserRead;
begin
  //Should only be one client admin user
  if Length(Self.Users) = 0 then begin
    //Add
    NewUser := TBloUserRead.Create;
    UserArray := Self.Users;
    try
      SetLength(UserArray, Length(Self.Users) + 1);
      Self.Users := UserArray;
      Self.Users[0] := NewUser;
      RoleArray := NewUser.RoleNames;
      try
        SetLength(RoleArray, Length(NewUser.RoleNames) + 1);
        RoleArray[0] := 'Client Administrator';
      finally
        NewUser.RoleNames := RoleArray;
      end;
    finally
      Self.Users := UserArray;
    end;
  end;
  //Update
  User(Self.Users[0]).FullName := AUserName;
  // User(Self.Users[0]).Email := AEmail;   Removed from service

end;

//------------------------------------------------------------------------------
function TUserDetailHelper.AddRoleName(RoleName: string): Boolean;
var
  RoleArray: ArrayOfstring;
  i: integer;

begin
  Result := False;
  for i := Low(RoleNames) to High(RoleNames) do
    if (RoleNames[i] = RoleName) then
      Exit;

  RoleArray := RoleNames;
  try
    SetLength(RoleArray, Length(RoleArray) + 1);
    RoleArray[High(RoleArray)] := RoleName;
    Result := True;
  finally
    RoleNames := RoleArray;
  end;
end;

//------------------------------------------------------------------------------
function TClientBaseHelper.AddSubscription(AProductID: TBloGuid) : Boolean;
var
  SubArray: TBloArrayOfGuid;
  i: integer;
begin
  Result := False;
  for i := Low(Subscription) to High(Subscription) do
    if (Subscription[i] = AProductID) then
      Exit;

  SubArray := Subscription;
  try
    SetLength(SubArray, Length(SubArray) + 1);
    SubArray[High(SubArray)] := AProductId;
    Result := True;
  finally
    Subscription := SubArray;
  end;
end;

//------------------------------------------------------------------------------
function TClientBaseHelper.RemoveSubscription(AProductID: TBloGuid) : Boolean;
var
  SubArray: TBloArrayOfGuid;
  i: integer;
  FoundIndex : integer;
begin
  Result := False;
  FoundIndex := -1;
  // Try Find Product to Remove
  for i := Low(Subscription) to High(Subscription) do
    if (Subscription[i] = AProductID) then
      FoundIndex := i;

  if FoundIndex > -1 then
  begin
    SubArray := Subscription;

    // Move Items after Found Item all one back
    if FoundIndex < High(SubArray) then
    begin
      for i := (FoundIndex+1) to High(SubArray) do
        SubArray[i-1] := SubArray[i];
    end;

    // Remove Last item
    SetLength(SubArray, Length(SubArray) - 1);
    Result := True;

    Subscription := SubArray;
  end;
end;

//------------------------------------------------------------------------------
function TClientBaseHelper.GetStatusString: string;
begin
  case self.Status of
    Active: Result := 'Active';
    Suspended: Result := 'Suspended';
    Deactivated: Result := 'Deactivated';
    else Result := '';
  end;
end;

//------------------------------------------------------------------------------
function TClientBaseHelper.HasSubscription(AProductID: TBloGuid) : Boolean;
var
  i : Integer;
begin
  Result := False;
  for i := Low(Subscription) to High(Subscription) do
  begin
    if (Subscription[i] = AProductID) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TClientHelper.FindUser(const EmailAddress: String): TBloUserRead;
var
  Index: Integer;
begin
  Result := nil;

  for Index := 0 to Length(Users) - 1 do
  begin
    if CompareText(Users[Index].EMail, EmailAddress) = 0 then
    begin
      Result := Users[Index];

      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TClientHelper.GetBillingEndDate: TDateTime;
begin
  Result := StrToDate('31/12/2011');
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsUserCreatedOnBankLinkOnline(const APractice : TBloPracticeRead;
                                                             const AUserId   : TBloGuid   = '';
                                                             const AUserCode : string = '') : Boolean;
var
  UserIndex : Integer;
begin
  Result := False;

  // Goes through passed through Practice users and finds the first one with either
  // a matching TBloGuid or Code
  for UserIndex := 0 to High(APractice.Users) do
  begin
    if (APractice.Users[UserIndex].Id       = AUserId)
    or (APractice.Users[UserIndex].UserCode = AUserCode) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsVendorInPractice(aAvailableServiceArray : TBloArrayOfDataPlatformSubscriber;
                                                  aVendorGuid : TBloGuid) : Boolean;
var
  VenIndex : integer;
begin
  Result := False;
  if not Assigned(aAvailableServiceArray) then
    Exit;

  for VenIndex := 0 to High(aAvailableServiceArray) do
  begin
    if (aVendorGuid = aAvailableServiceArray[VenIndex].Id) then
    begin
      Result := True;
      break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetVendorsHidingNonPractice(aAvailableServiceArray : TBloArrayOfDataPlatformSubscriber;
                                                           aSubscribers : TBloArrayOfDataPlatformSubscriber) : TBloArrayOfDataPlatformSubscriber;
var
  VenIndex : integer;
begin
  SetLength(Result, 0);
  if Assigned(aSubscribers) then
  begin
    for VenIndex := 0 to high(aSubscribers) do
    begin
      if IsVendorInPractice(aAvailableServiceArray,
                            aSubscribers[VenIndex].id) then
      begin
        SetLength(Result, Length(Result)+1);
        Result[High(Result)] := DataPlatformSubscriber.Create;
        CopyRemotableObject(aSubscribers[VenIndex], Result[High(Result)]);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetUnLinkedOnlineUsers(aPractice: TBloPracticeRead): TBloArrayOfUserRead;
var
  PracUserIndex : integer;
  OnlineUserIndex : integer;
  Found : Boolean;
  FreeUserIndex : Integer;
begin
  SetLength(Result,0);

  if not Assigned(aPractice) then
    aPractice := GetPractice;

  if not online then
    Exit;

  for OnlineUserIndex := 0 to high(aPractice.Users) do
  begin
    Found := False;
    for PracUserIndex := 0 to AdminSystem.fdSystem_User_List.Last do
    begin
    
      if (AdminSystem.fdSystem_User_List.User_At(PracUserIndex).usCode = aPractice.Users[OnlineUserIndex].UserCode) then
      begin
        Found := True;
        break;
      end;
    end;

    if not Found then
    begin
      SetLength(Result, Length(Result)+1);
      FreeUserIndex := High(Result);
      Result[FreeUserIndex] := TBloUserRead.Create;
      Result[FreeUserIndex].EMail := aPractice.Users[OnlineUserIndex].EMail;
      Result[FreeUserIndex].Id := aPractice.Users[OnlineUserIndex].Id;
      Result[FreeUserIndex].FullName := aPractice.Users[OnlineUserIndex].FullName;
      Result[FreeUserIndex].RoleNames := aPractice.Users[OnlineUserIndex].RoleNames;
      Result[FreeUserIndex].Subscription := aPractice.Users[OnlineUserIndex].Subscription;
      Result[FreeUserIndex].UserCode := aPractice.Users[OnlineUserIndex].UserCode;
    end;
  end;
end;

//-----------------------------------------------------------------------------
function TProductConfigService.GetOnlineUserLinkedToCode(aUserCode : String; aPractice: TBloPracticeRead; ShowProgress: Boolean) : TBloUserRead;
var
  OnlineUserIndex  : integer;
  PracticePassedIn : Boolean;
  Found : Boolean;
begin
  Result := nil;

  Found := false;

  PracticePassedIn := Assigned(aPractice);

  if not PracticePassedIn then
    aPractice := GetPractice(ShowProgress);

  if online then
  begin
    for OnlineUserIndex := 0 to high(aPractice.Users) do
    begin
      if (aUserCode = aPractice.Users[OnlineUserIndex].UserCode) then
      begin
        Found := true;
        Result := aPractice.Users[OnlineUserIndex];

        Break;
      end;
    end;
  end;

  if not found then
    Result := nil;
end;

//------------------------------------------------------------------------------
function TProductConfigService.CreateClientUser(const aClientId     : TBloGuid;
                                                const aEMail        : WideString;
                                                const aFullName     : WideString;
                                                const aRoleNames    : TBloArrayOfString;
                                                const aSubscription : TBloArrayOfGuid;
                                                const aUserCode     : WideString;
                                                out UserId: TBloGuid): Boolean;
var
  BloUserCreate  : TBloUserCreate;
  BlopiInterface : IBlopiSecureServiceFacade;
  MsgResponceGuid : MessageResponseOfGuid;
  Cancelled: Boolean;
  ConnectionError: Boolean;
begin
  Result := False;
  
  BlopiInterface := GetSecureServiceFacade;

  BloUserCreate := TBloUserCreate.Create;
  try
    BloUserCreate.EMail        := aEMail;
    BloUserCreate.FullName     := aFullName;
    BloUserCreate.RoleNames    := aRoleNames;
    BloUserCreate.Subscription := aSubscription;
    BloUserCreate.UserCode     := aUserCode;

    if not PracticeUserExists(aEmail) then
    begin
      try
        if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
          'CreateClientUser for ' + BloUserCreate.UserCode
        );

        MsgResponceGuid := BlopiInterface.CreateClientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                                AdminSystem.fdFields.fdBankLink_Code,
                                                AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                aClientId,
                                                BloUserCreate);

      except
        on E: EAuthenticationException do
        begin
          if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
          begin
            if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
              'CreateClientUser for ' + BloUserCreate.UserCode
            );
            
            MsgResponceGuid := BlopiInterface.CreateClientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                              AdminSystem.fdFields.fdBankLink_Code,
                                              AdminSystem.fdFields.fdBankLink_Connect_Password,
                                              aClientId,
                                              BloUserCreate);
          end
          else
          begin
            Exit;
          end;
        end;
      end;

      if not MessageResponseHasError(MsgResponceGuid, 'create the client user on', true) then
      begin
        UserId := copy(MsgResponceGuid.Result,1,Length(MsgResponceGuid.Result));

        LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client User ' + aUserCode + ' has been successfully updated on ' + BRAND_ONLINE + '.');

        Result := True;
      end
      else
      begin
        LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client User ' + aUserCode + ' was not updated on ' + BRAND_ONLINE + '.');
      end;
    end
    else
    begin
      HelpfulErrorMsg(Format(bkBranding.PracticeProductName + ' is unable to create client user ' +
                             'on ' + BRAND_ONLINE + '. User with email address %s already ' +
                             'exists as a Practice user. Please specify a different ' +
                             'email address or contact ' + BRAND_SUPPORT + ' for assistance.', [aEmail]), 0, False, '', False);

    end;

  finally
    FreeAndNil(MsgResponceGuid);
    FreeAndNil(BloUserCreate);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.UpdateClientUser(const aClientId     : TBloGuid;
                                                const aId           : TBloGuid;
                                                const aFullName     : WideString;
                                                const aRoleNames    : TBloArrayOfString;
                                                const aSubscription : TBloArrayOfGuid;
                                                const aUserCode     : WideString;
                                                const ErrorHandlerMessage: String): Boolean;
var
  BloUserUpdate  : TBloUserUpdate;
  BlopiInterface : IBlopiSecureServiceFacade;
  Cancelled: Boolean;
  ConnectionError: Boolean;
  Response: MessageResponse;
begin
  Result := False;
  
  BlopiInterface := GetSecureServiceFacade;

  BloUserUpdate := TBloUserUpdate.Create;
  try
    BloUserUpdate.Id           := aId;
    BloUserUpdate.FullName     := aFullName;
    BloUserUpdate.RoleNames    := aRoleNames;
    BloUserUpdate.Subscription := aSubscription;
    BloUserUpdate.UserCode     := aUserCode;

    try
      if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
        'SaveClientUser for ' + BloUserUpdate.UserCode
      );

      Response := BlopiInterface.SaveClientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                            AdminSystem.fdFields.fdBankLink_Code,
                                            AdminSystem.fdFields.fdBankLink_Connect_Password,
                                            aClientId,
                                            BloUserUpdate);
    except
      on E: EAuthenticationException do
      begin
        if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
        begin
          if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
            'SaveClientUser for ' + BloUserUpdate.UserCode
          );

          Response := BlopiInterface.SaveClientUser(CountryText(AdminSystem.fdFields.fdCountry),
                                          AdminSystem.fdFields.fdBankLink_Code,
                                          AdminSystem.fdFields.fdBankLink_Connect_Password,
                                          aClientId,
                                          BloUserUpdate);
        end
        else
        begin
          Exit;
        end;
      end;
    end;

    if Response.Success then
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client User ' + aUserCode + ' has been successfully updated on ' + BRAND_ONLINE + '.')
    else
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client User ' + aUserCode + ' was not updated on ' + BRAND_ONLINE + '.');

    Result := not MessageResponseHasError(Response, ErrorHandlerMessage);
  finally
    FreeAndNil(Response);
    FreeAndNil(BloUserUpdate);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.AddEditClientUser(const aExistingClient : TBloClientReadDetail;
                                                 const aClientSubscription : TBloArrayOfGuid;
                                                 aNewClientId    : TBloGuid;
                                                 aClientCode     : String;
                                                 var   aUserId   : TBloGuid;
                                                 const aEMail    : WideString;
                                                 const aFullName : WideString) : Boolean;
var
  UserCode        : WideString;
  RoleNames       : TBloArrayOfstring;
  ClientId        : TBloGuid;
begin
  Result := False;

  // Do nothing user exists and is the same
  if (Assigned(aExistingClient)) and
     (Length(aExistingClient.Users) > 0) and
     (Trim(Uppercase(aExistingClient.Users[0].EMail)) = Trim(Uppercase(aEMail))) and
     (Trim(Uppercase(aExistingClient.Users[0].FullName)) = Trim(Uppercase(aFullName))) then
  begin
    aUserId := aExistingClient.Users[0].Id;
    Result := True;
    Exit;
  end;

  // if the user is empty or the email is differant Create a new User
  if (not Assigned(aExistingClient)) or
     (Length(aExistingClient.Users) = 0) or
     (Trim(Uppercase(aExistingClient.Users[0].EMail)) <> Trim(Uppercase(aEMail))) then
  begin
    if (Assigned(aExistingClient)) and
       (Length(aExistingClient.Users) > 0) then
    begin
      UserCode     := aExistingClient.Users[0].UserCode;
      ClientId     := aExistingClient.Id;

      Result := DeleteUser(aExistingClient.Users[0].Id, UserCode, 'Clear the client user on');
    end
    else
    begin
      if Assigned(aExistingClient) then
      begin
        UserCode := aExistingClient.ClientCode;
        ClientId := aExistingClient.Id;
      end
      else
      begin
        ClientId := aNewClientId;
        UserCode := aClientCode;
      end;
    end;
    AddItemToArrayString(RoleNames, 'Client Administrator');

    Result := CreateClientUser(ClientId,
                               aEMail,
                               aFullName,
                               RoleNames,
                               aClientSubscription,
                               UserCode,
                               aUserId);
    Exit;
  end;

  // if the user exist and the email is the same update
  if (Length(aExistingClient.Users) > 0) and
     (Trim(Uppercase(aExistingClient.Users[0].EMail)) = Trim(Uppercase(aEMail))) then
  begin
    aUserId := aExistingClient.Users[0].Id;
    Result := UpdateClientUser(aExistingClient.Id,
                                    aUserId,
                                    aFullName,
                                    aExistingClient.Users[0].RoleNames,
                                    aExistingClient.Users[0].Subscription,
                                    aExistingClient.Users[0].UserCode,
                                    'create the client user on');

    Exit;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.FillInClientDetails(var aBloClientCreate: TBloClientCreate);
begin
  if (not Assigned(MyClient)) and
     (not Assigned(aBloClientCreate)) then
    Exit;

  aBloClientCreate.Address1         := MyClient.clFields.clAddress_L1;
  aBloClientCreate.Address2         := MyClient.clFields.clAddress_L2;
  aBloClientCreate.Address3         := MyClient.clFields.clAddress_L3;
  aBloClientCreate.CountryCode      := CountryText(MyClient.clFields.clCountry);

  if aBloClientCreate.CountryCode = 'NZ' then
    aBloClientCreate.AddressCountry := 'New Zealand'
  else if aBloClientCreate.CountryCode = 'AU' then
    aBloClientCreate.AddressCountry := 'Australia'
  else if aBloClientCreate.CountryCode = 'UK' then
    aBloClientCreate.AddressCountry := 'United Kingdom';

  aBloClientCreate.Email            := MyClient.clFields.clClient_EMail_Address;
  aBloClientCreate.Fax              := MyClient.clFields.clFax_No;
  aBloClientCreate.Mobile           := MyClient.clFields.clMobile_No;
  aBloClientCreate.Phone            := MyClient.clFields.clPhone_No;
  aBloClientCreate.Salutation       := MyClient.clFields.clSalutation;

  if MyClient.clFields.clCountry = whAustralia then
  begin
    aBloClientCreate.TaxNumber := '';
    aBloClientCreate.Abn := MyClient.clFields.clGST_Number;
  end
  else
  begin
    aBloClientCreate.Abn := '';
    aBloClientCreate.TaxNumber := MyClient.clFields.clGST_Number;
  end;

  aBloClientCreate.Tfn              := MyClient.clFields.clTFN;
  aBloClientCreate.Name_            := MyClient.clFields.clName;
end;

//------------------------------------------------------------------------------
function TProductConfigService.UpdatePracticeUserPass(const aUserId      : TBloGuid;
                                                      const aUserCode    : WideString;
                                                      const aOldPassword : WideString;
                                                      const aNewPassword : WideString;
                                                      const UserEmail    : WideString;
                                                      const ErrorHandlerMessage: String) : Boolean;
var
  BlopiInterface : IBlopiSecureServiceFacade;
  Response: MessageResponse;
  AuthenticationStatus: TAuthenticationStatus;
begin
  Result := False;

  try
    BlopiInterface := GetSecureServiceFacade;
    try
    if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
      'ChangePracticeUserPassword for ' + aUserCode
    );

    Response := BlopiInterface.ChangePracticeUserPassword(CountryText(AdminSystem.fdFields.fdCountry),
                                                      AdminSystem.fdFields.fdBankLink_Code,
                                                      AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                      aUserId,
                                                      aOldPassword,
                                                      aNewPassword);

    except
      on E: EAuthenticationException do
      begin
        if AuthenticateUser(AdminSystem.fdFields.fdBankLink_Code, aUserCode, aOldPassword, AuthenticationStatus) then
        begin
          if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
            'ChangePracticeUserPassword for ' + aUserCode
          );

          Response := BlopiInterface.ChangePracticeUserPassword(CountryText(AdminSystem.fdFields.fdCountry),
                                                      AdminSystem.fdFields.fdBankLink_Code,
                                                      AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                      aUserId,
                                                      aOldPassword,
                                                      aNewPassword);
        end
        else
        begin
          Exit;
        end;
      end;
    end;

    if Response.Success then
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Practice User ' + aUserCode + ' password has been successfully changed on ' + BRAND_ONLINE + '.')
    else
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Practice User ' + aUserCode + ' password was not changed on ' + BRAND_ONLINE + '.');

    Result := not MessageResponseHasError(Response, ErrorHandlerMessage);
  finally
    FreeAndNil(Response);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.CreatePracticeUser(const aEmail        : WideString;
                                                  const aFullName     : WideString;
                                                  const aUserCode     : WideString;
                                                  const aRoleNames    : TBloArrayOfstring;
                                                  const aSubscription : TBloArrayOfguid;
                                                  const aPassword     : WideString;
                                                  const ErrorHandlerMessage: String) : Guid;
var
  CreateUser      : TBloUserCreatePractice;
  BlopiInterface  : IBlopiSecureServiceFacade;
  Cancelled: Boolean;
  ConnectionError: Boolean;
  Response: MessageResponseOfGuid;
begin
  Result := '';
  
  BlopiInterface := GetSecureServiceFacade;

  CreateUser := TBloUserCreatePractice.Create;
  try
    CreateUser.Email        := aEmail;
    CreateUser.FullName     := aFullName;
    CreateUser.UserCode     := aUserCode;
    CreateUser.RoleNames    := aRoleNames;
    CreateUser.Subscription := aSubscription;
    CreateUser.Password     := aPassword;

    try
      if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
        'CreatePracticeUser for ' + aUserCode
      );

      Response := BlopiInterface.CreatePracticeUser(CountryText(AdminSystem.fdFields.fdCountry),
                                                AdminSystem.fdFields.fdBankLink_Code,
                                                AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                CreateUser);


      except
        on E: EAuthenticationException do
        begin
          if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
          begin
            if DebugMe then
              LogUtil.LogMsg(lmDebug, UNIT_NAME, 'CreatePracticeUser for ' + aUserCode);

            Response := BlopiInterface.CreatePracticeUser(CountryText(AdminSystem.fdFields.fdCountry),
                                              AdminSystem.fdFields.fdBankLink_Code,
                                              AdminSystem.fdFields.fdBankLink_Connect_Password,
                                              CreateUser);
          end
          else
          begin
            Exit;
          end;
        end;
      end;

    if Response.Success then
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Practice User ' + aUserCode + ' has been successfully created on ' + BRAND_ONLINE + '.')
    else
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Practice User ' + aUserCode + ' was not created on ' + BRAND_ONLINE + '.');

    if not MessageResponseHasError(Response, ErrorHandlerMessage) and Assigned(Response) then
    begin
      Result := Copy(Response.Result, 1, length(Response.Result));
    end;
  finally
    FreeAndNil(Response);
    FreeAndNil(CreateUser);
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.CreateXMLError(Document: IXMLDocument; const MethodName, ErrorCode, ErrorMessage: String);
var
  EnvelopeNode: IXMLNode;
  HeaderNode: IXMLNode;
  BodyNode: IXMLNode;
  ResponseNode: IXMLNode;
  ResultNode: IXMLNode;
  ErrorMessageNode: IXMLNode;
  ServiceErrorMessageNode: IXMLNode;
  Node: IXMLNode;
begin
  EnvelopeNode := Document.AddChild('Envelope');

  EnvelopeNode.Attributes['xmlns'] := '';

  HeaderNode := EnvelopeNode.AddChild('Header');

  Node := HeaderNode.AddChild('ActivityId');

  Node.Attributes['xmlns'] := '';
  Node.Attributes['CorrelationId'] := '';
  Node.Text := '';

  BodyNode := EnvelopeNode.AddChild('Body');

  ResponseNode := BodyNode.AddChild(MethodName + 'Response');
  ResponseNode.Attributes['xmlns'] := '';

  ResultNode := ResponseNode.AddChild(MethodName + 'Result');
  ResultNode.Attributes['xmlns:a'] := '';
  ResultNode.Attributes['xmlns:i'] := '';

  ErrorMessageNode := ResultNode.AddChild('ErrorMessage');

  ServiceErrorMessageNode := ErrorMessageNode.AddChild('ServiceErrorMessage');

  ServiceErrorMessageNode.AddChild('ErrorCode').Text := ErrorCode;
  ServiceErrorMessageNode.AddChild('Message').Text := ErrorMessage;

  ResultNode.AddChild('Exceptions');
  ResultNode.AddChild('Success').Text := 'false';
  ResultNode.AddChild('Result');
end;

//------------------------------------------------------------------------------
function TProductConfigService.UpdatePracticeUser(const aUserId       : TBloGuid;
                                                  const aFullName     : WideString;
                                                  const aUserCode     : WideString;
                                                  const aRoleNames    : TBloArrayOfstring;
                                                  const aSubscription : TBloArrayOfguid;
                                                  const Password      : WideString;
                                                  const ErrorHandlerMessage: String) : Boolean;
var
  UpdateUser     : TBloUserUpdatePractice;
  BlopiInterface : IBlopiSecureServiceFacade;
  Cancelled: Boolean;
  ConnectionError: Boolean;
  Response: MessageResponse;
begin
  Result := False;

  BlopiInterface := GetSecureServiceFacade;

  UpdateUser := TBloUserUpdatePractice.Create;
  try
    UpdateUser.Id           := aUserId;
    UpdateUser.FullName     := aFullName;
    UpdateUser.UserCode     := aUserCode;
    UpdateUser.RoleNames    := aRoleNames;
    UpdateUser.Subscription := aSubscription;

    try
      if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
        'SavePracticeUser for ' + aUserCode
      );

      Response := BlopiInterface.SavePracticeUser(CountryText(AdminSystem.fdFields.fdCountry),
                                              AdminSystem.fdFields.fdBankLink_Code,
                                              AdminSystem.fdFields.fdBankLink_Connect_Password,
                                              UpdateUser);

      except
        on E: EAuthenticationException do
        begin
          if ReAuthenticateUser(Cancelled, ConnectionError, aUserCode = CurrUser.Code) and not (Cancelled or ConnectionError) then
          begin
            if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
              'SavePracticeUser for ' + aUserCode
            );
            
            Response := BlopiInterface.SavePracticeUser(CountryText(AdminSystem.fdFields.fdCountry),
                                            AdminSystem.fdFields.fdBankLink_Code,
                                            AdminSystem.fdFields.fdBankLink_Connect_Password,
                                            UpdateUser);
          end
          else
          begin
            Exit;
          end;     
        end;
      end;

    
    if Response.Success then
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Practice User ' + aUserCode + ' has been successfully updated to ' + BRAND_ONLINE + '.')
    else
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Practice User ' + aUserCode + ' was not updated to ' + BRAND_ONLINE + '.');

    Result := not MessageResponseHasError(Response, ErrorHandlerMessage);
  finally
    FreeAndNil(Response);
    FreeAndNil(UpdateUser);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.DeleteUser(const aUserId      : TBloGuid;
                                          const aUserCode    : WideString;
                                          const ErrorHandlerMessage: String) : Boolean;
var
  BlopiInterface : IBlopiSecureServiceFacade;
  Cancelled: Boolean;
  ConnectionError: Boolean;
  Response: MessageResponse;
begin
  Result := False;

  try
    BlopiInterface := GetSecureServiceFacade;

    try
      if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
        'DeleteUser for ' + aUserCode
      );

      Response := BlopiInterface.DeleteUser(CountryText(AdminSystem.fdFields.fdCountry),
                                        AdminSystem.fdFields.fdBankLink_Code,
                                        AdminSystem.fdFields.fdBankLink_Connect_Password,
                                        aUserId);
    except
      on E: EAuthenticationException do
      begin
        if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
        begin
          if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
            'DeleteUser for ' + aUserCode
          );

          Response := BlopiInterface.DeleteUser(CountryText(AdminSystem.fdFields.fdCountry),
                                      AdminSystem.fdFields.fdBankLink_Code,
                                      AdminSystem.fdFields.fdBankLink_Connect_Password,
                                      aUserId);
        end
        else
        begin
          Exit;
        end;      
      end;
    end;

    if Response.Success then
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'User ' + aUserCode + ' has been successfully deleted from ' + BRAND_ONLINE + '.')
    else
      LogUtil.LogMsg(lmInfo, UNIT_NAME, 'User ' + aUserCode + ' was not deleted from ' + BRAND_ONLINE + '.');

    Result := not MessageResponseHasError(Response, ErrorHandlerMessage);
  finally
    FreeAndNil(Response);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetOnlineClientIndex(aClientCode: string) : Integer;
var
  ClientIndex : Integer;
begin
  Result := -1;
  ProductConfigService.LoadClientList;

  if not assigned(fClientList) then
    Exit;

  for ClientIndex := 0 to high(fClientList.Clients) do
  begin
    if fClientList.Clients[ClientIndex].ClientCode = aClientCode then
    begin
      Result := ClientIndex;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.SaveClientNotesOption(aWebExportFormat : Byte) : Boolean;
var
  Changed : Boolean;
  ClientReadDetail : TBloClientReadDetail;
  NotesId : TBloGuid;
  Subscription : TBloArrayOfguid;
  UserEmail, UserName: string;
begin
  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  try
    //Get client list (so that we can lookup the client code)
    ProductConfigService.LoadClientList;
    ClientReadDetail := ProductConfigService.GetClientDetailsWithCode(MyClient.clFields.clCode);
    NotesId := ProductConfigService.GetNotesId;
    Subscription := ClientReadDetail.Subscription;

    if aWebExportFormat = wfWebNotes then
      Changed := AddItemToArrayGuid(Subscription, NotesId)
    else
      Changed := RemoveItemFromArrayGuid(Subscription, NotesId);

    if Changed then
    begin
      if (Length(ClientReadDetail.Users) > 0) then
      begin
        UserEmail := ClientReadDetail.Users[0].Email;
        UserName := ClientReadDetail.Users[0].FullName;
      end else
      begin
        UserEmail := MyClient.clFields.clClient_EMail_Address;
        UserName := MyClient.clFields.clContact_Name;
      end;

      Result := ProductConfigService.UpdateClient(ClientReadDetail,
                                                  ClientReadDetail.BillingFrequency,
                                                  ClientReadDetail.MaxOfflineDays,
                                                  ClientReadDetail.Status,
                                                  Subscription,
                                                  UserEmail,
                                                  UserName);
    end
    else
      Result := True;

  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.SaveIBizzCredentials(const AcclipseCode: WideString; aShowMessage: Boolean): Boolean;
var
  BlopiInterface : IBlopiServiceFacade;
  PracCountryCode : WideString;
  PracCode        : WideString;
  PracPassHash    : WideString;
  MsgResponce     : MessageResponse;
  PracUpdate      : PracticeUpdate;
  IBizzCredentials: TBloIBizzCredentials;
begin
  Result := False;
  if UseBankLinkOnline then
  begin
    if Assigned(FPracticeCopy) then
    begin
      FPractice.Free;
      FPractice := PracticeRead.Create;

      PracUpdate := PracticeUpdate.Create;
      try
        RemoveInvalidSubscriptions;
        CopyRemotableObject(FPracticeCopy, FPractice);
        CopyRemotableObject(FPractice, PracUpdate);

        //Save to the web service
        Screen.Cursor := crHourGlass;
        Progress.StatusSilent := False;
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
        try
          PracCountryCode := CountryText(AdminSystem.fdFields.fdCountry);
          PracCode        := AdminSystem.fdFields.fdBankLink_Code;
          PracPassHash    := AdminSystem.fdFields.fdBankLink_Connect_Password;

          BlopiInterface := GetServiceFacade;

          Progress.UpdateAppStatus(BRAND_ONLINE, 'Saving iBizz subscriber credentials', 33);

          IBizzCredentials := TBloIBizzCredentials.Create;

          try
            IBizzCredentials.ExternalSubscriberId := AcclipseCode;

            if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
              'SavePracticeDataSubscriberCredentials for ' + PracCode
            );

            MsgResponce := BlopiInterface.SavePracticeDataSubscriberCredentials(PracCountryCode, PracCode, PracPassHash, GetIBizzExportGuid, IBizzCredentials);

            if not MessageResponseHasError(MsgResponce, 'update the iBizz subscriber credentials to') then
            begin
              Result := True;
              Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
            end;
          finally
            IBizzCredentials.Free;
          end;

        finally
          Progress.StatusSilent := True;
          Progress.ClearStatus;
          Screen.Cursor := crDefault;
        end;

      finally
        FreeAndNil(MsgResponce);
        FreeandNil(PracUpdate);
      end;

      if not Result and aShowMessage then
      begin
        HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to update the iBizz subscriber credentials ' + BRAND_ONLINE + '.', 0);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.CreateClient(const aBillingFrequency : WideString;
                                                  aMaxOfflineDays   : Integer;
                                                  aStatus           : TBloStatus;
                                            const aSubscription     : TBloArrayOfguid;
                                            const aUserEMail        : WideString;
                                            const aUserFullName     : WideString;
                                            var ClientID            : TBloGuid) : Boolean;
var
  BloClientCreate : TBloClientCreate;
  BlopiInterface  : IBlopiSecureServiceFacade;
  MsgResponseGuid : MessageResponseOfguid;
  UserId : TBloGuid;
  ClientCode : WideString;
  ClientIndex : Integer;
  BloClientReadDetail : TBloClientReadDetail;
  Cancelled: Boolean;
  ConnectionError: Boolean;
begin
  Result := False;

  if not Assigned(MyClient) then
    Exit;

  ClientCode := MyClient.clFields.clCode;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  BlopiInterface := GetSecureServiceFacade;
  try
    try
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Retrieving Info', 25);
      ClientIndex := GetOnlineClientIndex(ClientCode);

      if ClientIndex = -1 then
      begin
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Updating Client', 40);
        BloClientCreate := TBloClientCreate.Create;
        try
          FillInClientDetails(BloClientCreate);

          BloClientCreate.BillingFrequency := aBillingFrequency;
          BloClientCreate.ClientCode       := ClientCode;
          BloClientCreate.MaxOfflineDays   := aMaxOfflineDays;
          BloClientCreate.Status           := aStatus;
          BloClientCreate.Subscription     := aSubscription;
          BloClientCreate.SecureCode       := MyClient.clFields.clBankLink_Code;

          try
            if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
              'CreateClient for ' + BloClientCreate.Name_
            );

            MsgResponseGuid := BlopiInterface.CreateClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                         AdminSystem.fdFields.fdBankLink_Code,
                                                         AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                         BloClientCreate);

          except
            on E: EAuthenticationException do
            begin
              if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
              begin
                if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
                  'CreateClient for ' + BloClientCreate.Name_
                );
                
                MsgResponseGuid := BlopiInterface.CreateClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                       AdminSystem.fdFields.fdBankLink_Code,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                       BloClientCreate);
              end
              else
              begin
                Exit;
              end;       
            end;
          end;
      
          Result := not MessageResponseHasError(MsgResponseGuid, 'create client on');

          if Result then
            MyClient.Opened := True;
          ClientID := GetClientGuid(BloClientCreate.ClientCode);


          if Result then
          begin
            LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client ' + ClientCode + ' has been successfully created on ' + BRAND_ONLINE + '.');

            Progress.UpdateAppStatus(BRAND_ONLINE, 'Saving Client User', 70);
            Result := AddEditClientUser(Nil,
                                        aSubscription,
                                        MsgResponseGuid.Result,
                                        ClientCode,
                                        UserId,
                                        aUserEMail,
                                        aUserFullName);
          end
          else
            LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client ' + ClientCode + ' was not created on ' + BRAND_ONLINE + '.');

        finally
          FreeAndNil(MsgResponseGuid);
          FreeAndNil(BloClientCreate);
        end;

        if Result then
        begin
          HelpfulInfoMsg(Format('Settings for %s have been successfully updated on ' +
                         '%s.',[ClientCode, BRAND_ONLINE]), 0);
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
        end;
      end
      else
      begin
        BloClientReadDetail := GetClientDetailsWithGUID(fClientList.Clients[ClientIndex].Id, False);

        Result := UpdateClient(BloClientReadDetail,
                               aBillingFrequency,
                               aMaxOfflineDays,
                               aStatus,
                               aSubscription,
                               aUserEMail,
                               aUserFullName);
      end;
    except
      on E : Exception do
      begin
        HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to create the client on ' + BRAND_ONLINE + '. Please contact ' + BRAND_SUPPORT + ' for assistance.', 0);
        
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running CreateClient, Error Message : ' + E.Message);
      end;
    end;
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.UpdateClient(const aExistingClient       : TBloClientReadDetail;
                                            const aBillingFrequency     : WideString;
                                                  aMaxOfflineDays       : Integer;
                                                  aStatus               : TBloStatus;
                                            const aSubscription         : TBloArrayOfGuid;
                                            const aUserEMail            : WideString;
                                            const aUserFullName         : WideString;
                                            aShowUpdateSuccess  : Boolean = true): Boolean;
var
  BloClientUpdate : TBloClientUpdate;
  BlopiInterface  : IBlopiSecureServiceFacade;
  MsgResponse     : MessageResponse;
  UserId : TBloGuid;
  ClientName, ClientCode : WideString;

  //------------------------------------------
  function ClientDetailsHasChanged : Boolean;
  var
    SubOldIndex : integer;
    SubNewIndex : integer;
    Found : Boolean;
  begin
    Result := False;
    if (not (aExistingClient.BillingFrequency   = aBillingFrequency)) or
       (not (aExistingClient.MaxOfflineDays     = aMaxOfflineDays)) or
       (not (aExistingClient.Status             = aStatus)) or
       (not (High(aExistingClient.Subscription) = High(aSubscription))) or
       (not (aExistingClient.SecureCode = MyClient.clFields.clBankLink_Code)) then
    begin
      Result := True;
      Exit;
    end;

    for SubOldIndex := 0 to High(aExistingClient.Subscription) do
    begin
      Found := False;
      for SubNewIndex := 0 to High(aSubscription) do
      begin
        if (aExistingClient.Subscription[SubOldIndex] = aSubscription[SubNewIndex]) then
        begin
          Found := True;
          break;
        end;

        if not Found then
        begin
          Result := True;
          Exit;
        end;
      end;
    end;
  end;

var
  Cancelled: Boolean;
  ConnectionError: Boolean;
begin
  Result := False;

  if not Assigned(MyClient) then
    Exit;

  ClientName := MyClient.clFields.clName;
  ClientCode := MyClient.clFields.clCode;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  BlopiInterface := GetSecureServiceFacade;
  try
    try
      UserId := '';
      
      if CheckClientUser(aExistingClient, aUserEmail, aUserFullName, UserId, aSubscription) then
      begin
        Result := True;

        if ClientDetailsHasChanged or (aExistingClient.PrimaryContactUserId <> UserId) then
        begin
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Updating Client', 70);
          BloClientUpdate := TBloClientUpdate.Create;
          try
            BloClientUpdate.Id                   := aExistingClient.Id;
            BloClientUpdate.PrimaryContactUserId := UserId;
            BloClientUpdate.BillingFrequency     := aBillingFrequency;
            BloClientUpdate.ClientCode           := ClientCode;
            BloClientUpdate.MaxOfflineDays       := aMaxOfflineDays;
            BloClientUpdate.Name_                := ClientName;
            BloClientUpdate.Status               := aStatus;
            BloClientUpdate.Subscription         := aSubscription;
            BloClientUpdate.SecureCode           := MyClient.clFields.clBankLink_Code;

            try
              if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
                'SaveClient for ' + aUserEmail
              );

              MsgResponse := BlopiInterface.SaveClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                     AdminSystem.fdFields.fdBankLink_Code,
                                                     AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                     BloClientUpdate);
            except
              on E: EAuthenticationException do
              begin
                if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
                begin
                  if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
                    'SaveClient for ' + aUserEmail
                  );

                  MsgResponse := BlopiInterface.SaveClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                   AdminSystem.fdFields.fdBankLink_Code,
                                                   AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                   BloClientUpdate);
                end
                else
                begin
                  Result := False;
                  
                  Exit;
                end;     
              end;
            end;

            Result := not MessageResponseHasError(MsgResponse, 'update client on');

            if Result then
              LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client ' + ClientCode + ' has been successfully updated on ' + BRAND_ONLINE + '.')
            else
              LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client ' + ClientCode + ' was not updated on ' + BRAND_ONLINE + '.');

          finally
            FreeAndNil(MsgResponse);
            FreeAndNil(BloClientUpdate);
          end;
        end;

        if (Result) then
        begin
          if aShowUpdateSuccess then
            HelpfulInfoMsg(Format('Settings for %s have been successfully updated to ' +
                                  '%s.',[ClientCode, BRAND_ONLINE]), 0);
          Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
        end;
      end;
    except
      on E : Exception do
      begin
        HelpfulErrorMsg(bkBranding.PracticeProductName + ' is unable to update the client to ' + BRAND_ONLINE + '. Please contact ' + BRAND_SUPPORT + ' for assistance.', 0);
        
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running UpdateClient, Error Message : ' + E.Message);

        Result := False;
      end;
    end;
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.UpdateClientNotesOption(ClientReadDetail: TBloClientReadDetail; WebExportFormat: Byte): Boolean;
var
  Changed : Boolean;
  NotesId : TBloGuid;
  Subscription : TBloArrayOfguid;
  UserEmail, UserName: string;
  PrimaryUser: TBloUserRead;
begin
  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  try
    Subscription := ClientReadDetail.Subscription;

    NotesId := GetNotesId;
    
    if WebExportFormat = wfWebNotes then
    begin
      Changed := AddItemToArrayGuid(Subscription, NotesId)
    end
    else
    begin
      Changed := RemoveItemFromArrayGuid(Subscription, NotesId);
    end;

    PrimaryUser := ClientReadDetail.GetPrimaryUser;
    
    if Assigned(PrimaryUser) then
    begin
      UserEmail := PrimaryUser.Email;
      UserName := PrimaryUser.FullName;
    end else
    begin
      UserEmail := MyClient.clFields.clClient_EMail_Address;
      UserName := MyClient.clFields.clContact_Name;
    end;

    Result := UpdateClient(ClientReadDetail,
                           ClientReadDetail.BillingFrequency,
                           ClientReadDetail.MaxOfflineDays,
                           ClientReadDetail.Status,
                           Subscription,
                           UserEmail,
                           UserName);
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
procedure TProductConfigService.UpdateClientStatus(var ClientReadDetail: TBloClientReadDetail; const ClientCode: WideString);
var
  BlopiInterface  : IBlopiServiceFacade;
  ClientDetailResponse: MessageResponseOfClientReadDetailMIdCYrSK;
  ClientGuid: TBloGuid;
  NewClientReadDetail: TBloClientReadDetail;
  PrimaryContact: TBloUserRead;
begin
  try
    ClientGuid := GetClientGuid(ClientCode);
    BlopiInterface := ProductConfigService.GetServiceFacade;
    ClientDetailResponse := BlopiInterface.GetClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                     AdminSystem.fdFields.fdBankLink_Code,
                                                     AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                     ClientGuid);
    NewClientReadDetail := TBloClientReadDetail.Create;
    CopyRemotableObject(ClientDetailResponse.Result, NewClientReadDetail);
    NewClientReadDetail.Status := BlopiServiceFacade.Active;

    PrimaryContact := NewClientReadDetail.GetPrimaryUser;

    {
      ProductConfigService.UpdateClient(ClientReadDetail, NewClientReadDetail.BillingFrequency,
                                      NewClientReadDetail.MaxOfflineDays, NewClientReadDetail.Status,
                                      NewClientReadDetail.Subscription, NewClientReadDetail.Users[0].EMail,
                                      NewClientReadDetail.Users[0].FullName, false);
      }

    ProductConfigService.UpdateClient(ClientReadDetail, NewClientReadDetail.BillingFrequency,
                                      NewClientReadDetail.MaxOfflineDays, NewClientReadDetail.Status,
                                      NewClientReadDetail.Subscription, PrimaryContact.EMail,
                                      PrimaryContact.FullName, false);


    ClientReadDetail := NewClientReadDetail;
  finally
    FreeAndNil(ClientDetailResponse);
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.DeleteClient(const aExistingClient : TBloClientReadDetail): Boolean;
var
  BloClientUpdate : TBloClientUpdate;
  BlopiInterface  : IBlopiSecureServiceFacade;
  MsgResponse     : MessageResponse;
  UserId          : TBloGuid;
  Cancelled: Boolean;
  ConnectionError: Boolean;
begin
  Result := false;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  BlopiInterface := GetSecureServiceFacade;
  try
    try
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Deleting Client User', 55);

      if High(aExistingClient.Users) = -1 then
      begin
        Result := AddEditClientUser(aExistingClient,
                                    aExistingClient.Subscription,
                                    '',
                                    '',
                                    UserId,
                                    'DeleteClientUser@Test.com',
                                    'DeleteClientUser');

        if Not Result then
          Exit;
      end
      else
      begin
        UserId := aExistingClient.GetPrimaryUser.Id;
      end;

      BloClientUpdate := TBloClientUpdate.Create;
      try
        BloClientUpdate.Id                   := aExistingClient.Id;
        BloClientUpdate.PrimaryContactUserId := UserId;
        BloClientUpdate.BillingFrequency     := aExistingClient.BillingFrequency;
        BloClientUpdate.ClientCode           := aExistingClient.ClientCode;
        BloClientUpdate.MaxOfflineDays       := aExistingClient.MaxOfflineDays;
        BloClientUpdate.Name_                := aExistingClient.Name_;
        BloClientUpdate.Status               := staDeleted;
        BloClientUpdate.Subscription         := aExistingClient.Subscription;

        try
          if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
            'SaveClient for ' + aExistingClient.ClientCode
          );

          MsgResponse := BlopiInterface.SaveClient(CountryText(AdminSystem.fdFields.fdCountry),
                                                 AdminSystem.fdFields.fdBankLink_Code,
                                                 AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                 BloClientUpdate);


        except
          on E: EAuthenticationException do
          begin
            if ReAuthenticateUser(Cancelled, ConnectionError) and not (Cancelled or ConnectionError) then
            begin
              if DebugMe then LogUtil.LogMsg(lmDebug, UNIT_NAME,
                'SaveClient for ' + aExistingClient.ClientCode
              );

              MsgResponse := BlopiInterface.SaveClient(CountryText(AdminSystem.fdFields.fdCountry),
                                               AdminSystem.fdFields.fdBankLink_Code,
                                               AdminSystem.fdFields.fdBankLink_Connect_Password,
                                               BloClientUpdate);
            end
            else
            begin
              Exit;
            end;
          end;
        end;

        Result := not MessageResponseHasError(MsgResponse, 'delete client on');

        if Result then
          LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client ' + aExistingClient.ClientCode + ' has been successfully marked as Deleted on ' + BRAND_ONLINE + '.')
        else
          LogUtil.LogMsg(lmInfo, UNIT_NAME, 'Client ' + aExistingClient.ClientCode + ' was not marked as Deleted on ' + BRAND_ONLINE + '.');

      finally
        FreeAndNil(MsgResponse);
        FreeAndNil(BloClientUpdate);
      end;

      if Result then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running UpdateClient, Error Message : ' + E.Message);

        raise Exception.Create(bkBranding.PracticeProductName + ' is unable to save the client to ' + BRAND_ONLINE + '. Please contact ' + BRAND_SUPPORT + ' for assistance.');
      end;
    end;
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.AddClientUser(ClientId: TBloGuid;
  const UserCode: String; const EMailAddress, FullName: WideString;
  const aSubscriptions: TBloArrayOfguid;
  var UserId: TBloGuid): Boolean;
var
  Roles: TBloArrayOfString;
begin
  AddItemToArrayString(Roles, ROLES_CLIENT_ADMINISTRATOR);

  Result := CreateClientUser(ClientId,
                             EMailAddress,
                             FullName,
                             Roles,
                             aSubscriptions,
                             UserCode,
                             UserId);
end;

//------------------------------------------------------------------------------
function TProductConfigService.CheckAuthentication(ServiceResponse: MessageResponse): Boolean;
begin
  Result := True;
  
  if not ServiceResponse.Success then
  begin
    if Length(ServiceResponse.Exceptions) > 0 then
    begin
      Result := CompareText(ServiceResponse.Exceptions[0].Message_, 'You are not authenticated') <> 0
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.CheckClientUser(Client: TBloClientReadDetail;
                                               const EMail, FullName: WideString;
                                               var UserId: TBloGuid;
                                               const aSubscription : TBloArrayOfGuid): Boolean;
var
  PrimaryUser     : TBloUserRead;
  ClientUser: TBloUserRead;
begin
  Result := False;

  PrimaryUser := Client.GetPrimaryUser;

  if (not Assigned(PrimaryUser)) then
  begin
    Result := AddClientUser(Client.Id, Client.ClientCode, Email, FullName, aSubscription, UserId);
  end
  else
  begin
    if (CompareText(Trim(PrimaryUser.EMail), Trim(EMail)) <> 0) then
    begin
      ClientUser := Client.FindUser(Email);

      if ClientUser = nil then
      begin
        Result := AddClientUser(Client.Id, Client.ClientCode, Email, FullName, aSubscription, UserId);

        Exit;
      end
      else
      begin
        PrimaryUser := ClientUser;
      end;  
    end;

    UserId := PrimaryUser.Id;

    if (CompareText(Trim(PrimaryUser.FullName), Trim(FullName)) <> 0) or
       (CheckGuidArrayEquality(PrimaryUser.Subscription, aSubscription) = false) then
    begin
      Result := UpdateClientUser(Client.Id,
                                 UserId,
                                 FullName,
                                 PrimaryUser.RoleNames,
                                 aSubscription,
                                 PrimaryUser.UserCode,
                                 'update the client user on');
    end
    else
    begin
      Result := True;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.AddEditPracUser(var   aUserId         : TBloGuid;
                                               const aEMail          : WideString;
                                               const aFullName       : WideString;
                                               const aUserCode       : WideString;
                                               const aUstNameIndex   : integer;
                                               var   aIsUserCreated  : Boolean;
                                               const aChangePassword : Boolean;
                                               aOldPassword          : WideString;
                                               aNewPassword          : WideString) : Boolean;
var
  CurrPractice    : TBloPracticeRead;
  IsUserOnline    : Boolean;
  RoleNames       : TBloArrayOfString;
  UserGuid: Guid;
begin
  Result := false;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  try
    try
      // Does the User Already Exist on BankLink Online?
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Receiving Data', 33);
      CurrPractice := GetPractice(true, true);
      if OnLine then
      begin
        IsUserOnline := IsUserCreatedOnBankLinkOnline(CurrPractice, aUserId, aUserCode);

        SetLength(RoleNames,1);
        RoleNames[0] := CurrPractice.GetRoleFromPracUserType(aUstNameIndex, CurrPractice).RoleName;

        Progress.UpdateAppStatus(BRAND_ONLINE, 'Sending Data', 66);

        if IsUserOnline then
        begin
          if aUserId = '' then
            aUserId := GetPracUserGuid(aUserCode, CurrPractice);

          Result := UpdatePracticeUser(aUserId,
                                       aFullName,
                                       aUserCode,
                                       RoleNames,
                                       CurrPractice.Subscription,
                                       aNewPassword,
                                       'update practice user on');

          if Result then
          begin
            if aChangePassword and (aOldPassword <> aNewPassword) then
            begin
              Progress.UpdateAppStatus(BRAND_ONLINE, 'Sending Data', 88);

              Result := UpdatePracticeUserPass(aUserId,
                                               aUserCode,
                                               aOldPassword,
                                               aNewPassword,
                                               aEmail,
                                               'update practice user password on');
            end;

            if Result then
            begin
              aIsUserCreated := false;
              Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
            end;
          end;
        end
        else
        begin
          UserGuid := CreatePracticeUser(aEmail,
                                         aFullName,
                                         aUserCode,
                                         RoleNames,
                                         CurrPractice.Subscription,
                                         aNewPassword,
                                         'create practice user on');

          Result := UserGuid <> '';

          if Result then
          begin
            aUserId := UserGuid;
            aIsUserCreated := True;
            Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
          end;
        end;
      end
      else
      begin
        if aIsUserCreated then
          LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' was not created on ' + BRAND_ONLINE + '.')
        else
          LogUtil.LogMsg(lmInfo, UNIT_NAME, aUserCode + ' was not updated to ' + BRAND_ONLINE + '.');
      end;
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running AddEditPracUser, Error Message : ' + E.Message);

        raise Exception.Create(bkBranding.PracticeProductName + ' is unable to update the user to ' + BRAND_ONLINE + '. Please contact ' + BRAND_SUPPORT + ' for assistance.');
      end;
    end;
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.DeletePracUser(const aUserCode : string;
                                              const aUserGuid : string;
                                              aPractice : TBloPracticeRead) : Boolean;
var
  UserGuid    : TBloGuid;
begin
  Result := false;

  Screen.Cursor := crHourGlass;
  Progress.StatusSilent := False;
  Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);

  try
    try
      if not Assigned(aPractice) then
        aPractice := GetPractice;

      if Online then
      begin
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Sending Data', 50);
        if aUserCode = '' then
          UserGuid := aUserGuid
        else
          UserGuid := GetPracUserGuid(aUserCode, aPractice);

        if not (UserGuid = '') then
        begin
          Result := DeleteUser(UserGuid,
                               aUserCode,
                               'delete practice user on');
        end
        else
          Result := True;
      end;

      if Result then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    except
      on E : Exception do
      begin
        LogUtil.LogMsg(lmError, UNIT_NAME, 'Exception running DeletePracUser, Error Message : ' + E.Message);
        
        raise Exception.Create(bkBranding.PracticeProductName + ' is unable to delete the user from ' + BRAND_ONLINE + '. Please contact ' + BRAND_SUPPORT + ' for assistance.');
      end;
    end;
  finally
    Progress.StatusSilent := True;
    Progress.ClearStatus;
    Screen.Cursor := crDefault;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.IsPrimPracUser(const aUserCode : string;
                                              aPractice : TBloPracticeRead): Boolean;
begin
  if aUserCode = '' then
  begin
    Result := false;
    Exit;
  end;

  if not Assigned(aPractice) then
    aPractice := GetPractice(true);

  Result := (GetPracUserGuid(aUserCode, aPractice) = aPractice.DefaultAdminUserId);
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetPracUserGuid(const aUserCode : string;
                                               aPractice : TBloPracticeRead): TBloGuid;
var
  i: integer;
  TempUser: TBloUserRead;
begin
  Result := '';

  for i := Low(aPractice.Users) to High(aPractice.Users) do
  begin
    TempUser := aPractice.Users[i];
    if TempUser.UserCode = AUserCode then begin
      Result := TempUser.Id;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetPrimaryContact(AUsePracCopy: Boolean): TBloUserRead;
var
  TempPractice: TBloPracticeRead;
  Index: Integer;
begin
  Result := nil;

  if AUsePracCopy then
  begin
    TempPractice := FPracticeCopy;
  end
  else
  begin
    TempPractice := FPractice;
  end;

  for Index := Low(TempPractice.Users) to High(TempPractice.Users) do
  begin
    if TempPractice.Users[Index].Id = TempPractice.DefaultAdminUserId then
    begin
      Result := TempPractice.Users[Index];
      
      Break;
    end;
  end;

end;

//------------------------------------------------------------------------------
function TProductConfigService.ChangePracUserPass(const aUserCode    : WideString;
                                                  const aOldPassword : WideString;
                                                  const aNewPassword : WideString;
                                                  const UserEmail    : WideString;
                                                  aPractice          : TBloPracticeRead;
                                                  aLinkedUserGuid    : TBloGuid) : Boolean;
var
  UserGuid        : WideString;
  ShowProgress    : Boolean;
begin
  Result := false;

  ShowProgress := Progress.StatusSilent;
  if ShowProgress then
  begin
    Screen.Cursor := crHourGlass;
    Progress.StatusSilent := False;
    Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
  end;

  try
    if not Assigned(aPractice) then
    begin
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Sending Data', 40);
      aPractice := GetPractice;
    end;

    if ShowProgress then
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Sending Data', 60);

    if aLinkedUserGuid = '' then
      UserGuid := GetPracUserGuid(aUserCode, aPractice)
    else
      UserGuid := aLinkedUserGuid;

    Result:= UpdatePracticeUserPass(UserGuid,
                                          aUserCode,
                                          aOldPassword,
                                          aNewPassword,
                                          UserEmail,
                                          'change practice user password on');

    if (Result) and (ShowProgress) then
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);

  finally
    if ShowProgress then
    begin
      Progress.StatusSilent := True;
      Progress.ClearStatus;
      Screen.Cursor := crDefault;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetPracticeVendorExports(ShowProgressBar: boolean = True;
                                                        PracticeCode: string = '') : TBloDataPlatformSubscription;
var
  DataPlatformSubscriberResponse: MessageResponseOfDataPlatformSubscription6cY85e5k;
  ShowProgress: Boolean;
  BlopiInterface: IBlopiServiceFacade;
begin
  Result := nil;
  
  try
    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent and ShowProgressBar;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Available Data Exports', 50);

      if (PracticeCode = '') then
        PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
      BlopiInterface := GetServiceFacade(PracticeCode);
      //Get the vendor export types from BankLink Online
      DataPlatformSubscriberResponse := BlopiInterface.GetPracticeDataSubscribers(CountryText(AdminSystem.fdFields.fdCountry),
                                                       PracticeCode,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password);
                                                       
      if not MessageResponseHasError(MessageResponse(DataPlatformSubscriberResponse), 'get the vendor export types from') then
      begin
        Result := TBloDataPlatformSubscription.Create;
        CopyRemotableObject(DataPlatformSubscriberResponse.Result, Result);
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(DataPlatformSubscriberResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetPracticeVendorExports', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientVendorExports(aClientGuid: TBloGuid) : TBloDataPlatformSubscription;
var
  DataPlatformSubscriberResponse: MessageResponseOfDataPlatformSubscription6cY85e5k;
  ShowProgress: Boolean;
  BlopiInterface: IBlopiServiceFacade; 
begin
  Result := nil;
  
  try
    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Available Data Exports', 50);

      BlopiInterface :=  GetServiceFacade;
      
      //Get the vendor export types from BankLink Online
      DataPlatformSubscriberResponse := BlopiInterface.GetClientDataSubscribers(CountryText(AdminSystem.fdFields.fdCountry),
                                                       AdminSystem.fdFields.fdBankLink_Code,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                       aClientGuid);
                                                       
      if not MessageResponseHasError(MessageResponse(DataPlatformSubscriberResponse),
                                     'get the vendor export types from',
                                     false,
                                     1,
                                     '152') then
      begin
        Result := TBloDataPlatformSubscription.Create;
        CopyRemotableObject(DataPlatformSubscriberResponse.Result, Result);
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(DataPlatformSubscriberResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetClientVendorExports', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetAccountStatusList(out Success: Boolean): TBloArrayOfPracticeBankAccount;
var
  BlopiInterface: IBlopiServiceFacade;
  MsgResponse: MessageResponseOfArrayOfPracticeBankAccountrLqac6vj;
  ShowProgress : Boolean;
  Index : integer;
begin
  Success := False;

  try
    ShowProgress := Progress.StatusSilent;
    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Bank Accounts', 50);

      BlopiInterface :=  GetServiceFacade;

      MsgResponse := BlopiInterface.GetBankAccounts(CountryText(AdminSystem.fdFields.fdCountry),
                                                   AdminSystem.fdFields.fdBankLink_Code,
                                                   AdminSystem.fdFields.fdBankLink_Connect_Password);

      if not MessageResponseHasError(MsgResponse, 'get bank accounts from') then
      begin
        SetLength(Result, Length(MsgResponse.Result));
        for Index := 0 to Length(Result)-1 do
        begin
          Result[Index] := PracticeBankAccount.Create;
        end;

        CopyRemotableObject(TBloArrayOfRemotable(MsgResponse.Result), TBloArrayOfRemotable(Result));

        Success := True;
      end;

      if ShowProgress then
      begin
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
      end;
    finally
      FreeAndNil(MsgResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetAccountStatusList', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetAccountVendors(aClientGuid : TBloGuid; aAccountID: Integer;
                                                 ShowProgressBar: boolean): TBloDataPlatformSubscription;
var
  DataPlatformSubscriberResponse : MessageResponseOfDataPlatformSubscription6cY85e5k;
  BlopiInterface            : IBlopiServiceFacade;
  PracticeExportDataService : TBloDataPlatformSubscription;
  AvailableServiceArray     : TBloArrayOfDataPlatformSubscriber;
  ShowProgress: Boolean;
  Index : integer;
begin
  Result := nil;

  try
    PracticeExportDataService := GetPracticeVendorExports(ShowProgressBar);
    if Assigned(PracticeExportDataService) then
    begin
      AvailableServiceArray := PracticeExportDataService.Current;
    end;

    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent and ShowProgressBar;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Available Data Exports', 50);

      BlopiInterface :=  GetServiceFacade;

      //Get the vendor export types from BankLink Online
      DataPlatformSubscriberResponse := BlopiInterface.GetBankAccountDataSubscribers(CountryText(AdminSystem.fdFields.fdCountry),
                                                       AdminSystem.fdFields.fdBankLink_Code,
                                                       AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                       aClientGuid,
                                                       aAccountId);

      if not MessageResponseHasError(MessageResponse(DataPlatformSubscriberResponse), 'get the vendor export types from') then
      begin
        Result := TBloDataPlatformSubscription.Create;
        CopyRemotableObject(DataPlatformSubscriberResponse.Result, Result);

        for Index := 0 to Length(Result.Available)-1 do
          FreeAndNil(Result.Available[Index]);
        Result.Available := GetVendorsHidingNonPractice(AvailableServiceArray,
                                                        DataPlatformSubscriberResponse.Result.Available);

        for Index := 0 to Length(Result.Current)-1 do
          FreeAndNil(Result.Current[Index]);
        Result.Current   := GetVendorsHidingNonPractice(AvailableServiceArray,
                                                        DataPlatformSubscriberResponse.Result.Current);
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(DataPlatformSubscriberResponse);
      FreeAndNil(PracticeExportDataService);
      SetLength(AvailableServiceArray, 0);
      AvailableServiceArray := nil;

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetAccountVendors', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetAuthenticationServiceFacade: IP5Auth;
var
  HTTPRIO: THTTPRIO;
begin
  HTTPRIO := THTTPRIO.Create(nil);
  HTTPRIO.OnBeforeExecute := DoBeforeExecute;
  HTTPRIO.OnAfterExecute := DoAfterSecureExecute;

  Result := GetIP5Auth(False, GetBanklinkOnlineURL('/Services/P5auth.svc'), HTTPRIO)
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientAccountsVendors(aClientCode: string;
                                                        aClientGuid: TBloGuid;
                                                        out aClientAccVendors: TClientAccVendors;
                                                        aShowProgressBar: Boolean = True): Boolean;
var
  DataPlatformClientSubscriberResponse: MessageResponseOfDataPlatformClient6cY85e5k;
  ShowProgress: Boolean;
  BlopiInterface: IBlopiServiceFacade;
  ClientGuid : TBloGuid;
  AccountIndex : integer;
  VendorIndex : integer;
  VendorGuid : TBloGuid;
  Current : ArrayOfDataPlatformSubscriber;
  BankAccountIndex : integer;
  BankAcct : TBank_Account;
  PracticeExportDataService   : TBloDataPlatformSubscription;
  AvailableServiceArray : TBloArrayOfDataPlatformSubscriber;
  VendorCount : integer;
  CurrVendor : integer;

  //----------------------------------------
  function GetClientVendorName(aVendorid : TBloGuid; aClientVendors : TBloArrayOfDataPlatformSubscriber) : string;
  var
    VenIndex : integer;
  begin
    Result := '';
    for VenIndex := 0 to high(aClientVendors) do
    begin
      if aClientVendors[VenIndex].Id = aVendorid then
      begin
        Result := aClientVendors[VenIndex].Name_;
        break;
      end;
    end;
  end;

begin
  Result := false;

  if aClientGuid = '' then
  begin
    ClientGuid := GetClientGuid(AClientCode);
    if ClientGuid = '' then
      Exit;
  end
  else
    ClientGuid := aClientGuid;

  try
    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent and aShowProgressBar;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      PracticeExportDataService := GetPracticeVendorExports;
      if Assigned(PracticeExportDataService) then
        AvailableServiceArray := PracticeExportDataService.Current;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Client Accounts Vendors', 50);

      BlopiInterface :=  GetServiceFacade;

      //Get the vendor export types from BankLink Online
      DataPlatformClientSubscriberResponse := BlopiInterface.GetBankAccountsDataSubscribers(CountryText(AdminSystem.fdFields.fdCountry),
                                                             AdminSystem.fdFields.fdBankLink_Code,
                                                             AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                             ClientGuid);

      if not MessageResponseHasError(MessageResponse(DataPlatformClientSubscriberResponse), 'get the client accounts vendors') then
      begin
        // Filling Client Account Vendors Record
        aClientAccVendors.ClientID := ClientGuid;
        aClientAccVendors.ClientCode := aClientCode;
        aClientAccVendors.ClientVendors := GetVendorsHidingNonPractice(AvailableServiceArray,
                                                                       DataPlatformClientSubscriberResponse.Result.Available);

        Setlength(aClientAccVendors.AccountsVendors, length(DataPlatformClientSubscriberResponse.Result.BankAccounts));
        for AccountIndex := 0 to high(aClientAccVendors.AccountsVendors) do
        begin
          aClientAccVendors.AccountsVendors[AccountIndex].ClientNeedRefresh := false;

          aClientAccVendors.AccountsVendors[AccountIndex].AccountVendors := TBloDataPlatformSubscription.Create;

          aClientAccVendors.AccountsVendors[AccountIndex].AccountVendors.Available :=
            GetVendorsHidingNonPractice(AvailableServiceArray,
                                        DataPlatformClientSubscriberResponse.Result.Available);

          aClientAccVendors.AccountsVendors[AccountIndex].AccountID :=
            DataPlatformClientSubscriberResponse.Result.BankAccounts[AccountIndex].AccountId;

          aClientAccVendors.AccountsVendors[AccountIndex].ExportDataEnabled := False;
          for BankAccountIndex := 0 to MyClient.clBank_Account_List.ItemCount-1 do
          begin
            BankAcct := MyClient.clBank_Account_List.Bank_Account_At(BankAccountIndex);

            if BankAcct.baFields.baCore_Account_ID = aClientAccVendors.AccountsVendors[AccountIndex].AccountId then
            begin
              aClientAccVendors.AccountsVendors[AccountIndex].ExportDataEnabled :=
                (not BankAcct.baFields.baIs_A_Manual_Account) and
                (not (BankAcct.baFields.baIs_A_Provisional_Account)) and
                (not (BankAcct.IsAJournalAccount));
            end;
          end;

          VendorCount := 0;
          for VendorIndex := 0 to high(DataPlatformClientSubscriberResponse.Result.BankAccounts[AccountIndex].Subscribers) do
            if IsVendorInPractice(AvailableServiceArray,
                                  DataPlatformClientSubscriberResponse.Result.BankAccounts[AccountIndex].Subscribers[VendorIndex]) then
              inc(VendorCount);

          Setlength(Current, VendorCount);
          aClientAccVendors.AccountsVendors[AccountIndex].AccountVendors.Current := Current;

          CurrVendor := 0;
          for VendorIndex := 0 to high(DataPlatformClientSubscriberResponse.Result.BankAccounts[AccountIndex].Subscribers) do
          begin
            VendorGuid := DataPlatformClientSubscriberResponse.Result.BankAccounts[AccountIndex].Subscribers[VendorIndex];

            if IsVendorInPractice(AvailableServiceArray, VendorGuid) then
            begin
              aClientAccVendors.AccountsVendors[AccountIndex].AccountVendors.Current[CurrVendor] := TBloDataPlatformSubscriber.Create;
              aClientAccVendors.AccountsVendors[AccountIndex].AccountVendors.Current[CurrVendor].Id :=
                VendorGuid;
              aClientAccVendors.AccountsVendors[AccountIndex].AccountVendors.Current[CurrVendor].Name_ :=
                GetClientVendorName(VendorGuid, aClientAccVendors.ClientVendors);

              inc(CurrVendor);
            end;
          end;
        end;
      end;

      Result := True;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(DataPlatformClientSubscriberResponse);
      FreeAndNil(PracticeExportDataService);
      SetLength(AvailableServiceArray, 0);
      AvailableServiceArray := nil;

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetClientAccountsVendorss', E);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TProductConfigService.GetClientBankAccounts(aClientGuid: TBloGuid;
  out BankAccounts: TBloArrayOfDataPlatformBankAccount;
  aShowProgressBar: Boolean;
  ReportResponseErrors: Boolean): TBloResult;
var
  DataPlatformClientSubscriberResponse: MessageResponseOfDataPlatformClient6cY85e5k;
  ShowProgress: Boolean;
  BlopiInterface: IBlopiServiceFacade;
  Index : integer;
begin
  Result := bloFailedNonFatal;

  try
    if not Assigned(AdminSystem) then
      Exit;

    if not Registered then
      Exit;

    ShowProgress := Progress.StatusSilent and aShowProgressBar;

    if ShowProgress then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BRAND_ONLINE, 'Connecting', 10);
    end;

    try
      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Getting Client Accounts Vendors', 50);

      BlopiInterface :=  GetServiceFacade;

      //Get the vendor export types from BankLink Online
      DataPlatformClientSubscriberResponse := BlopiInterface.GetBankAccountsDataSubscribers(CountryText(AdminSystem.fdFields.fdCountry),
                                                             AdminSystem.fdFields.fdBankLink_Code,
                                                             AdminSystem.fdFields.fdBankLink_Connect_Password,
                                                             aClientGuid);

      if not MessageResponseHasError(MessageResponse(DataPlatformClientSubscriberResponse), 'get the client accounts vendors', False, 0, '', ReportResponseErrors) then
      begin
        SetLength(BankAccounts, Length(DataPlatformClientSubscriberResponse.Result.BankAccounts));
        for Index := 0 to Length(BankAccounts)-1 do
        begin
          BankAccounts[Index] := DataPlatformBankAccount.Create;
        end;

        CopyRemotableObject(TBloArrayOfRemotable(DataPlatformClientSubscriberResponse.Result.BankAccounts), TBloArrayOfRemotable(BankAccounts));

        Result := bloSuccess;
      end
      else
      begin
        if not Assigned(DataPlatformClientSubscriberResponse) then
        begin
          Result := bloFailedFatal;
        end
        else
        if Length(DataPlatformClientSubscriberResponse.Exceptions) > 0 then
        begin
          Result := bloFailedFatal;
        end;
      end;

      if ShowProgress then
        Progress.UpdateAppStatus(BRAND_ONLINE, 'Finished', 100);
    finally
      FreeAndNil(DataPlatformClientSubscriberResponse);

      if ShowProgress then
      begin
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end;
  except
    on E:Exception do
    begin
      HandleException('GetClientBankAccounts', E);

      Result := bloFailedFatal;
    end;
  end;
end;

{ TPracticeHelper }
//------------------------------------------------------------------------------
function TPracticeHelper.GetUserRoleGuidFromPracUserType(aUstNameIndex: integer;
                                                         aInstance: PracticeRead): Guid;
begin
  Result := '';
  if (aUstNameIndex < ustMin)
  or (aUstNameIndex > ustMax) then
    raise Exception.Create('Practice User Type does not exist in the Admin System.');

  if High(aInstance.Roles) < 1 then
    raise Exception.Create('Get Practice Roles returned no role information.');

  case aUstNameIndex of
                            // Accountant Practice Standard User
    ustRestricted : Result := aInstance.Roles[1].id;
                            // Accountant Practice Standard User
    ustNormal     : Result := aInstance.Roles[1].id;
                            // Accountant Practice Administrator
    ustSystem     : Result := aInstance.Roles[0].id;
  end;
end;

//------------------------------------------------------------------------------
function TPracticeHelper.GetUserRoleNameFromPracUserType(aUstNameIndex: integer): String;
begin
  Result := '';

  case aUstNameIndex of
                            // Accountant Practice Standard User
    ustRestricted : Result := GetRoleName(1);
                            // Accountant Practice Standard User
    ustNormal     : Result := GetRoleName(1);
                            // Accountant Practice Administrator
    ustSystem     : Result := GetRoleName(0);
  end;
end;

//------------------------------------------------------------------------------
function TPracticeHelper.IsEqual(Instance: PracticeRead): Boolean;
var
  i: integer;
begin
  Result := False;
  if not Assigned(Instance) then Exit;

  Result :=
    (DefaultAdminUserId = Instance.DefaultAdminUserId) and
    (DisplayName = Instance.DisplayName) and
    (DomainName = Instance.DomainName) and
    (EMail = Instance.EMail) and
    (Phone = Instance.Phone) and
    (Status = Instance.Status);

  //Compare users (shouldn't change)
  if Result then begin
    Result := (High(Users) = High(Instance.Users));
    if Result then begin
      for i := Low(Users) to High(Users) do begin
        if Users[i].Id <> Instance.Users[i].Id then begin
          Result := False;
          Break;
        end;
      end;
    end;
  end;

  //Catalogue can't be changed so no need to compare

  //Compare Roles
  if Result then begin
    Result := (High(Roles) = High(Instance.Roles));
    if Result then begin
      for i := Low(Roles) to High(Roles) do begin
        if Roles[i].Id <> Instance.Roles[i].Id then begin
          Result := False;
          Break;
        end;
      end;
    end;
  end;

  //Compare subscriptions
  if Result then begin
    Result := (High(Subscription) = High(Instance.Subscription));
    if Result then begin
      for i := Low(Subscription) to High(Subscription) do begin
        if Subscription[i] <> Instance.Subscription[i] then begin
          Result := False;
          Break;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TPracticeHelper.CheckUserRolesEqual(PracticeRole: Integer; User: TBloUserRead): Boolean;
begin
  Result := False;
  
  if PracticeRole = ustSystem then
  begin
    if User.HasRoles([GetUserRoleNameFromPracUserType(ustSystem)]) then
    begin
      Result := True;
    end;
  end
  else
  begin
    if User.HasRoles([GetUserRoleNameFromPracUserType(ustNormal)]) and not User.HasRoles([GetUserRoleNameFromPracUserType(ustSystem)]) then
    begin
      Result := True;
    end;  
  end;
end;

//------------------------------------------------------------------------------
function TPracticeHelper.FindUser(const EmailAddress: String): TBloUserRead;
var
  Index: Integer;
begin
  Result := nil;
  
  for Index := 0 to Length(Users) - 1 do
  begin
    if CompareText(Trim(Users[Index].EMail), Trim(EmailAddress)) = 0 then
    begin
      Result := Users[Index];

      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TPracticeHelper.FindUserByCode(const UserCode: String): TBloUserRead;
var
  Index: Integer;
begin
  Result := nil;
  
  for Index := 0 to Length(Users) - 1 do
  begin
    if CompareText(Trim(Users[Index].UserCode), Trim(UserCode)) = 0 then
    begin
      Result := Users[Index];

      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TPracticeHelper.GetRoleFromPracUserType(aUstNameIndex: integer;
                                                 aInstance: PracticeRead): Role;
var
  RoleGuid : TBloGuid;
  RoleIndex : integer;
begin
  Result := Nil;
  RoleGuid := GetUserRoleGuidFromPracUserType(aUstNameIndex, aInstance);

  for RoleIndex := 0 to High(Self.Roles) do
  begin
    if (Self.Roles[RoleIndex].Id = RoleGuid) then
    begin
      Result := Self.Roles[RoleIndex];
      Exit;
    end;
  end;

  raise Exception.Create('Practice User Role does not exist on ' + BRAND_ONLINE + '.');
end;

//------------------------------------------------------------------------------
function TPracticeHelper.GetRoleName(RoleIndex: Integer): String;
begin
  if RoleIndex < Length(Roles) then
  begin
    Result := Roles[RoleIndex].RoleName;
  end
  else
  begin
    Result := '';
  end;
end;

//------------------------------------------------------------------------------
{ TClientListHelper }
function TClientListHelper.GetClientGuid(const ClientCode: WideString): TBloGuid;
var
  Index: Integer;
begin
  for Index := Low(Clients) to High(Clients) do
  begin
    if (ClientCode = Clients[Index].ClientCode) then
    begin
      Result := Clients[Index].Id;

      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure HandleException(const MethodName: String; E: Exception);
begin
  HandleException(MethodName, UNIT_NAME, E);
end;

//------------------------------------------------------------------------------
procedure HandleException(const MethodName, UnitName: String; E: Exception); overload;
var
  MainMessage: String;
  MessageDetails: String;
  ShowDetails: Boolean;
begin
  MainMessage := Format('%s encountered a problem while connecting to %s. Please see the details below or contact ' + BRAND_SUPPORT + ' for assistance.', [bkBranding.PracticeProductName, BRAND_ONLINE]);
  
  MessageDetails := E.Message;

  ShowDetails := True;
  
  if E is ESOAPHTTPException then
  begin
    if (Pos(' - URL:', E.Message) > 0) then
    begin
      MessageDetails := Copy(MessageDetails, 0, Pos(' - URL:', E.Message) -1) + '.';
    end;
  end
  else
  if E is EDOMParseError then
  begin
    MainMessage := Format('%s encountered a problem connecting to %s. Please contact ' + BRAND_SUPPORT + ' for assistance', [bkBranding.PracticeProductName, BRAND_ONLINE]);
    
    ShowDetails := False;
  end;

  HelpfulErrorMsg(MainMessage, 0, True, MessageDetails, ShowDetails);

  LogUtil.LogMsg(lmError, UnitName, Format('Exception running %s, Error Message : %s', [MethodName, E.Message]));
end;

//------------------------------------------------------------------------------
function TUserDetailHelper.HasRoles(const RoleList: array of String): Boolean;
var
  Index: Integer;
  IIndex: Integer;
  RoleCount: Integer;
begin
  RoleCount := 0;
  
  for Index := 0 to Length(RoleList) - 1 do
  begin
    for IIndex := 0 to Length(RoleNames) - 1 do
    begin
      if CompareText(RoleList[Index], RoleNames[IIndex]) = 0 then
      begin
        Inc(RoleCount);
      end;
    end;
  end;

  Result := RoleCount = Length(RoleList);
end;

//------------------------------------------------------------------------------
function TUserDetailHelper.IsPracticeAdministrator: Boolean;
var
  Index: Integer;
begin
  Result := False;
  
  for Index := 0 to Length(RoleNames) - 1 do
  begin
    if CompareText(RoleNames[Index], 'Accountant Practice Administrator') = 0 then
    begin
      Result := True;

      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UNIT_NAME);
  __BankLinkOnlineServiceMgr := nil;

//------------------------------------------------------------------------------
finalization
 FreeAndNil(__BankLinkOnlineServiceMgr);
end.

