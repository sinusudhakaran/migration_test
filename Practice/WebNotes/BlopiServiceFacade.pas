 // ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl
//  >Import : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl=wsdl0
//  >Import : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl=wsdl0>0
//  >Import : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd0
//  >Import : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd2
//  >Import : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd1
//  >Import : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd3
//  >Import : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd4
// Encoding : utf-8
// Codegen  : [wfMapStringsToWideStrings+, wfUseScopedEnumeration-]
// Version  : 1.0
// (24/05/2012 2:24:40 p.m. - - $Rev: 25127 $)
// ************************************************************************ //

unit BlopiServiceFacade;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;
  IS_UNBD = $0002;
  IS_NLBL = $0004;
  IS_REF  = $0080;


type

  // ************************************************************************ //
  // The following types, referred to in the WSDL document are not being represented
  // in this file. They are either aliases[@] of other types represented or were referred
  // to but never[!] declared in the document. The types from the latter category
  // typically map to predefined/known XML or Embarcadero types; however, they could also 
  // indicate incorrect WSDL documents that failed to declare or import a schema type.
  // ************************************************************************ //
  // !:int             - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]

  DataPlatformSubscription = class;             { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }
  DataPlatformSubscriber = class;               { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }
  PracticeDataSubscriberCredentials = class;    { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }
  PracticeDataSubscriberCount = class;          { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }
  DataPlatformClient   = class;                 { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }
  DataPlatformBankAccount = class;              { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }
  DataPlatformSubscription2 = class;            { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblElm] }
  DataPlatformSubscriber2 = class;              { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblElm] }
  PracticeDataSubscriberCredentials2 = class;   { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblElm] }
  PracticeDataSubscriberCount2 = class;         { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblElm] }
  DataPlatformClient2  = class;                 { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblElm] }
  DataPlatformBankAccount2 = class;             { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblElm] }
  MessageResponse      = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfArrayOfCatalogueEntryMIdCYrSK = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ServiceErrorMessage  = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ExceptionDetails     = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfPracticeReadMIdCYrSK = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfguid = class;                { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfClientListMIdCYrSK = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfClientReadDetailMIdCYrSK = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfstring = class;              { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfDataPlatformSubscription6cY85e5k = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfDataPlatformClient6cY85e5k = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfArrayOfCatalogueEntryMIdCYrSK2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponse2     = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  ServiceErrorMessage2 = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  ExceptionDetails2    = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfPracticeReadMIdCYrSK2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfguid2 = class;               { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfClientListMIdCYrSK2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfClientReadDetailMIdCYrSK2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfstring2 = class;             { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfDataPlatformSubscription6cY85e5k2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfDataPlatformClient6cY85e5k2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  CatalogueEntry       = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  Practice             = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  PracticeRead         = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  Role                 = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  User                 = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  UserRead             = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  PracticeUpdate       = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  UserCreate           = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  UserCreatePractice   = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  UserUpdate           = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  UserUpdatePractice   = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ClientList           = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  Client               = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ClientRead           = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ClientReadDetail     = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ClientCreate         = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ClientUpdate         = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  CatalogueEntry2      = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  PracticeRead2        = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Practice2            = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Role2                = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  UserRead2            = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  User2                = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  PracticeUpdate2      = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  UserCreatePractice2  = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  UserCreate2          = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  UserUpdatePractice2  = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  UserUpdate2          = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientList2          = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientRead2          = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Client2              = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientReadDetail2    = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientCreate2        = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientUpdate2        = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }

  { "http://www.banklinkonline.com/2011/11/Blopi"[GblSmpl] }
  Status = (Active, Suspended, Deactivated, Deleted);

  { "http://schemas.datacontract.org/2004/07/BankLink.PracticeIntegration.Contract.DataContracts"[GblSmpl] }
  ResultCode = (Success, NoFileReceived, InvalidCredentials, InternalError, FileFormatError);

  guid            =  type WideString;      { "http://schemas.microsoft.com/2003/10/Serialization/"[GblSmpl] }
  ArrayOfstring = array of WideString;          { "http://schemas.microsoft.com/2003/10/Serialization/Arrays"[GblCplx] }
  ArrayOfguid = array of guid;                  { "http://schemas.microsoft.com/2003/10/Serialization/Arrays"[GblCplx] }
  ArrayOfint = array of Integer;                { "http://schemas.microsoft.com/2003/10/Serialization/Arrays"[GblCplx] }
  ArrayOfDataPlatformSubscriber = array of DataPlatformSubscriber;   { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }


  // ************************************************************************ //
  // XML       : DataPlatformSubscription, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  DataPlatformSubscription = class(TRemotable)
  private
    FAvailable: ArrayOfDataPlatformSubscriber;
    FAvailable_Specified: boolean;
    FCurrent: ArrayOfDataPlatformSubscriber;
    FCurrent_Specified: boolean;
    procedure SetAvailable(Index: Integer; const AArrayOfDataPlatformSubscriber: ArrayOfDataPlatformSubscriber);
    function  Available_Specified(Index: Integer): boolean;
    procedure SetCurrent(Index: Integer; const AArrayOfDataPlatformSubscriber: ArrayOfDataPlatformSubscriber);
    function  Current_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Available: ArrayOfDataPlatformSubscriber  Index (IS_OPTN or IS_NLBL) read FAvailable write SetAvailable stored Available_Specified;
    property Current:   ArrayOfDataPlatformSubscriber  Index (IS_OPTN or IS_NLBL) read FCurrent write SetCurrent stored Current_Specified;
  end;



  // ************************************************************************ //
  // XML       : DataPlatformSubscriber, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  DataPlatformSubscriber = class(TRemotable)
  private
    FId: guid;
    FId_Specified: boolean;
    FName_: WideString;
    FName__Specified: boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetName_(Index: Integer; const AWideString: WideString);
    function  Name__Specified(Index: Integer): boolean;
  published
    property Id:    guid        Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Name_: WideString  Index (IS_OPTN or IS_NLBL) read FName_ write SetName_ stored Name__Specified;
  end;



  // ************************************************************************ //
  // XML       : PracticeDataSubscriberCredentials, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  PracticeDataSubscriberCredentials = class(TRemotable)
  private
    FExternalSubscriberId: WideString;
    FExternalSubscriberId_Specified: boolean;
    procedure SetExternalSubscriberId(Index: Integer; const AWideString: WideString);
    function  ExternalSubscriberId_Specified(Index: Integer): boolean;
  published
    property ExternalSubscriberId: WideString  Index (IS_OPTN or IS_NLBL) read FExternalSubscriberId write SetExternalSubscriberId stored ExternalSubscriberId_Specified;
  end;

  ArrayOfPracticeDataSubscriberCount = array of PracticeDataSubscriberCount;   { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }


  // ************************************************************************ //
  // XML       : PracticeDataSubscriberCount, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  PracticeDataSubscriberCount = class(TRemotable)
  private
    FClientCount: Integer;
    FClientCount_Specified: boolean;
    FClientIds: ArrayOfguid;
    FClientIds_Specified: boolean;
    FSubscriberId: guid;
    FSubscriberId_Specified: boolean;
    procedure SetClientCount(Index: Integer; const AInteger: Integer);
    function  ClientCount_Specified(Index: Integer): boolean;
    procedure SetClientIds(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  ClientIds_Specified(Index: Integer): boolean;
    procedure SetSubscriberId(Index: Integer; const Aguid: guid);
    function  SubscriberId_Specified(Index: Integer): boolean;
  published
    property ClientCount:  Integer      Index (IS_OPTN) read FClientCount write SetClientCount stored ClientCount_Specified;
    property ClientIds:    ArrayOfguid  Index (IS_OPTN or IS_NLBL) read FClientIds write SetClientIds stored ClientIds_Specified;
    property SubscriberId: guid         Index (IS_OPTN) read FSubscriberId write SetSubscriberId stored SubscriberId_Specified;
  end;

  ArrayOfDataPlatformBankAccount = array of DataPlatformBankAccount;   { "http://www.banklinkonline.com/2011/11/DataPlatform"[GblCplx] }


  // ************************************************************************ //
  // XML       : DataPlatformClient, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  DataPlatformClient = class(TRemotable)
  private
    FAvailable: ArrayOfDataPlatformSubscriber;
    FAvailable_Specified: boolean;
    FBankAccounts: ArrayOfDataPlatformBankAccount;
    FBankAccounts_Specified: boolean;
    procedure SetAvailable(Index: Integer; const AArrayOfDataPlatformSubscriber: ArrayOfDataPlatformSubscriber);
    function  Available_Specified(Index: Integer): boolean;
    procedure SetBankAccounts(Index: Integer; const AArrayOfDataPlatformBankAccount: ArrayOfDataPlatformBankAccount);
    function  BankAccounts_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Available:    ArrayOfDataPlatformSubscriber   Index (IS_OPTN or IS_NLBL) read FAvailable write SetAvailable stored Available_Specified;
    property BankAccounts: ArrayOfDataPlatformBankAccount  Index (IS_OPTN or IS_NLBL) read FBankAccounts write SetBankAccounts stored BankAccounts_Specified;
  end;



  // ************************************************************************ //
  // XML       : DataPlatformBankAccount, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  DataPlatformBankAccount = class(TRemotable)
  private
    FAccountId: Integer;
    FAccountId_Specified: boolean;
    FAccountName: WideString;
    FAccountName_Specified: boolean;
    FAccountNumber: WideString;
    FAccountNumber_Specified: boolean;
    FSubscribers: ArrayOfguid;
    FSubscribers_Specified: boolean;
    procedure SetAccountId(Index: Integer; const AInteger: Integer);
    function  AccountId_Specified(Index: Integer): boolean;
    procedure SetAccountName(Index: Integer; const AWideString: WideString);
    function  AccountName_Specified(Index: Integer): boolean;
    procedure SetAccountNumber(Index: Integer; const AWideString: WideString);
    function  AccountNumber_Specified(Index: Integer): boolean;
    procedure SetSubscribers(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscribers_Specified(Index: Integer): boolean;
  published
    property AccountId:   Integer      Index (IS_OPTN) read FAccountId write SetAccountId stored AccountId_Specified;
    property AccountName:   WideString   Index (IS_OPTN) read FAccountName write SetAccountName stored AccountName_Specified;
    property AccountNumber: WideString   Index (IS_OPTN) read FAccountNumber write SetAccountNumber stored AccountNumber_Specified;
    property Subscribers: ArrayOfguid  Index (IS_OPTN or IS_NLBL) read FSubscribers write SetSubscribers stored Subscribers_Specified;
  end;



  // ************************************************************************ //
  // XML       : DataPlatformSubscription, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  DataPlatformSubscription2 = class(DataPlatformSubscription)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DataPlatformSubscriber, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  DataPlatformSubscriber2 = class(DataPlatformSubscriber)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : PracticeDataSubscriberCredentials, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  PracticeDataSubscriberCredentials2 = class(PracticeDataSubscriberCredentials)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : PracticeDataSubscriberCount, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  PracticeDataSubscriberCount2 = class(PracticeDataSubscriberCount)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DataPlatformClient, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  DataPlatformClient2 = class(DataPlatformClient)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : DataPlatformBankAccount, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/DataPlatform
  // ************************************************************************ //
  DataPlatformBankAccount2 = class(DataPlatformBankAccount)
  private
  published
  end;

  // ************************************************************************ //
  // XML       : PracticeBankAccount, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.PracticeIntegration.Contract.DataContracts
  // ************************************************************************ //
  PracticeBankAccount = class(TRemotable)
  private
    FAccountId: Integer;
    FAccountId_Specified: boolean;
    FAccountName: WideString;
    FAccountName_Specified: boolean;
    FAccountNumber: WideString;
    FAccountNumber_Specified: boolean;
    FCostCode: WideString;
    FCostCode_Specified: boolean;
    FCreatedDate: TXSDateTime;
    FCreatedDate_Specified: boolean;
    FFileNumber: WideString;
    FFileNumber_Specified: boolean;
    FRejectionReason: WideString;
    FRejectionReason_Specified: boolean;
    FStatus: WideString;
    FStatus_Specified: boolean;
    procedure SetAccountId(Index: Integer; const AInteger: Integer);
    function  AccountId_Specified(Index: Integer): boolean;
    procedure SetAccountName(Index: Integer; const AWideString: WideString);
    function  AccountName_Specified(Index: Integer): boolean;
    procedure SetAccountNumber(Index: Integer; const AWideString: WideString);
    function  AccountNumber_Specified(Index: Integer): boolean;
    procedure SetCostCode(Index: Integer; const AWideString: WideString);
    function  CostCode_Specified(Index: Integer): boolean;
    procedure SetCreatedDate(Index: Integer; const ATXSDateTime: TXSDateTime);
    function  CreatedDate_Specified(Index: Integer): boolean;
    procedure SetFileNumber(Index: Integer; const AWideString: WideString);
    function  FileNumber_Specified(Index: Integer): boolean;
    procedure SetRejectionReason(Index: Integer; const AWideString: WideString);
    function  RejectionReason_Specified(Index: Integer): boolean;
    procedure SetStatus(Index: Integer; const AWideString: WideString);
    function  Status_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property AccountId:       Integer      Index (IS_OPTN) read FAccountId write SetAccountId stored AccountId_Specified;
    property AccountName:     WideString   Index (IS_OPTN) read FAccountName write SetAccountName stored AccountName_Specified;
    property AccountNumber:   WideString   Index (IS_OPTN) read FAccountNumber write SetAccountNumber stored AccountNumber_Specified;
    property CostCode:        WideString   Index (IS_OPTN) read FCostCode write SetCostCode stored CostCode_Specified;
    property CreatedDate:     TXSDateTime  Index (IS_OPTN) read FCreatedDate write SetCreatedDate stored CreatedDate_Specified;
    property FileNumber:      WideString   Index (IS_OPTN) read FFileNumber write SetFileNumber stored FileNumber_Specified;
    property RejectionReason: WideString   Index (IS_OPTN) read FRejectionReason write SetRejectionReason stored RejectionReason_Specified;
    property Status:          WideString   Index (IS_OPTN) read FStatus write SetStatus stored Status_Specified;
  end;
  
  ArrayOfCatalogueEntry = array of CatalogueEntry;   { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ArrayOfServiceErrorMessage = array of ServiceErrorMessage;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ArrayOfExceptionDetails = array of ExceptionDetails;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ArrayOfPracticeBankAccount = array of PracticeBankAccount;

  // ************************************************************************ //
  // XML       : MessageResponse, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponse = class(TRemotable)
  private
    FErrorMessages: ArrayOfServiceErrorMessage;
    FErrorMessages_Specified: boolean;
    FExceptions: ArrayOfExceptionDetails;
    FExceptions_Specified: boolean;
    FSuccess: Boolean;
    FSuccess_Specified: boolean;
    procedure SetErrorMessages(Index: Integer; const AArrayOfServiceErrorMessage: ArrayOfServiceErrorMessage);
    function  ErrorMessages_Specified(Index: Integer): boolean;
    procedure SetExceptions(Index: Integer; const AArrayOfExceptionDetails: ArrayOfExceptionDetails);
    function  Exceptions_Specified(Index: Integer): boolean;
    procedure SetSuccess(Index: Integer; const ABoolean: Boolean);
    function  Success_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property ErrorMessages: ArrayOfServiceErrorMessage  Index (IS_OPTN or IS_NLBL) read FErrorMessages write SetErrorMessages stored ErrorMessages_Specified;
    property Exceptions:    ArrayOfExceptionDetails     Index (IS_OPTN or IS_NLBL) read FExceptions write SetExceptions stored Exceptions_Specified;
    property Success:       Boolean                     Index (IS_OPTN) read FSuccess write SetSuccess stored Success_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfArrayOfCatalogueEntryMIdCYrSK, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfArrayOfCatalogueEntryMIdCYrSK = class(MessageResponse)
  private
    FResult: ArrayOfCatalogueEntry;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: ArrayOfCatalogueEntry  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : ServiceErrorMessage, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  ServiceErrorMessage = class(TRemotable)
  private
    FErrorCode: WideString;
    FErrorCode_Specified: boolean;
    FMessage_: WideString;
    FMessage__Specified: boolean;
    procedure SetErrorCode(Index: Integer; const AWideString: WideString);
    function  ErrorCode_Specified(Index: Integer): boolean;
    procedure SetMessage_(Index: Integer; const AWideString: WideString);
    function  Message__Specified(Index: Integer): boolean;
  published
    property ErrorCode: WideString  Index (IS_OPTN or IS_NLBL) read FErrorCode write SetErrorCode stored ErrorCode_Specified;
    property Message_:  WideString  Index (IS_OPTN or IS_NLBL) read FMessage_ write SetMessage_ stored Message__Specified;
  end;



  // ************************************************************************ //
  // XML       : ExceptionDetails, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  ExceptionDetails = class(TRemotable)
  private
    FMessage_: WideString;
    FMessage__Specified: boolean;
    FSource: WideString;
    FSource_Specified: boolean;
    FStackTrace: WideString;
    FStackTrace_Specified: boolean;
    procedure SetMessage_(Index: Integer; const AWideString: WideString);
    function  Message__Specified(Index: Integer): boolean;
    procedure SetSource(Index: Integer; const AWideString: WideString);
    function  Source_Specified(Index: Integer): boolean;
    procedure SetStackTrace(Index: Integer; const AWideString: WideString);
    function  StackTrace_Specified(Index: Integer): boolean;
  published
    property Message_:   WideString  Index (IS_OPTN or IS_NLBL) read FMessage_ write SetMessage_ stored Message__Specified;
    property Source:     WideString  Index (IS_OPTN or IS_NLBL) read FSource write SetSource stored Source_Specified;
    property StackTrace: WideString  Index (IS_OPTN or IS_NLBL) read FStackTrace write SetStackTrace stored StackTrace_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfPracticeReadMIdCYrSK, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfPracticeReadMIdCYrSK = class(MessageResponse)
  private
    FResult: PracticeRead;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const APracticeRead: PracticeRead);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: PracticeRead  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfguid, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfguid = class(MessageResponse)
  private
    FResult: guid;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const Aguid: guid);
    function  Result_Specified(Index: Integer): boolean;
  published
    property Result: guid  Index (IS_OPTN) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfClientListMIdCYrSK, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfClientListMIdCYrSK = class(MessageResponse)
  private
    FResult: ClientList;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const AClientList: ClientList);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: ClientList  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfClientReadDetailMIdCYrSK, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfClientReadDetailMIdCYrSK = class(MessageResponse)
  private
    FResult: ClientReadDetail;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const AClientReadDetail: ClientReadDetail);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: ClientReadDetail  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfstring, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfstring = class(MessageResponse)
  private
    FResult: WideString;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const AWideString: WideString);
    function  Result_Specified(Index: Integer): boolean;
  published
    property Result: WideString  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfDataPlatformSubscription6cY85e5k, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfDataPlatformSubscription6cY85e5k = class(MessageResponse)
  private
    FResult: DataPlatformSubscription;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const ADataPlatformSubscription: DataPlatformSubscription);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: DataPlatformSubscription  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k = class(MessageResponse)
  private
    FResult: PracticeDataSubscriberCredentials;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const APracticeDataSubscriberCredentials: PracticeDataSubscriberCredentials);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: PracticeDataSubscriberCredentials  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k = class(MessageResponse)
  private
    FResult: ArrayOfPracticeDataSubscriberCount;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const AArrayOfPracticeDataSubscriberCount: ArrayOfPracticeDataSubscriberCount);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: ArrayOfPracticeDataSubscriberCount  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfDataPlatformClient6cY85e5k, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfDataPlatformClient6cY85e5k = class(MessageResponse)
  private
    FResult: DataPlatformClient;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const ADataPlatformClient: DataPlatformClient);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: DataPlatformClient  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfArrayOfCatalogueEntryMIdCYrSK, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfArrayOfCatalogueEntryMIdCYrSK2 = class(MessageResponseOfArrayOfCatalogueEntryMIdCYrSK)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponse, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponse2 = class(MessageResponse)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ServiceErrorMessage, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  ServiceErrorMessage2 = class(ServiceErrorMessage)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ExceptionDetails, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  ExceptionDetails2 = class(ExceptionDetails)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfPracticeReadMIdCYrSK, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfPracticeReadMIdCYrSK2 = class(MessageResponseOfPracticeReadMIdCYrSK)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfguid, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfguid2 = class(MessageResponseOfguid)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfClientListMIdCYrSK, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfClientListMIdCYrSK2 = class(MessageResponseOfClientListMIdCYrSK)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfClientReadDetailMIdCYrSK, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfClientReadDetailMIdCYrSK2 = class(MessageResponseOfClientReadDetailMIdCYrSK)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfstring, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfstring2 = class(MessageResponseOfstring)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfDataPlatformSubscription6cY85e5k, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfDataPlatformSubscription6cY85e5k2 = class(MessageResponseOfDataPlatformSubscription6cY85e5k)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k2 = class(MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k2 = class(MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfDataPlatformClient6cY85e5k, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfDataPlatformClient6cY85e5k2 = class(MessageResponseOfDataPlatformClient6cY85e5k)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : CatalogueEntry, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  CatalogueEntry = class(TRemotable)
  private
    FCatalogueType: WideString;
    FCatalogueType_Specified: boolean;
    FDescription: WideString;
    FDescription_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    procedure SetCatalogueType(Index: Integer; const AWideString: WideString);
    function  CatalogueType_Specified(Index: Integer): boolean;
    procedure SetDescription(Index: Integer; const AWideString: WideString);
    function  Description_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
  published
    property CatalogueType: WideString  Index (IS_OPTN or IS_NLBL) read FCatalogueType write SetCatalogueType stored CatalogueType_Specified;
    property Description:   WideString  Index (IS_OPTN or IS_NLBL) read FDescription write SetDescription stored Description_Specified;
    property Id:            guid        Index (IS_OPTN) read FId write SetId stored Id_Specified;
  end;

  ArrayOfRole = array of Role;                  { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ArrayOfUserRead = array of UserRead;          { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }


  // ************************************************************************ //
  // XML       : Practice, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  Practice = class(TRemotable)
  private
    FDefaultAdminUserId: guid;
    FDefaultAdminUserId_Specified: boolean;
    FDisplayName: WideString;
    FDisplayName_Specified: boolean;
    FEMail: WideString;
    FEMail_Specified: boolean;
    FPhone: WideString;
    FPhone_Specified: boolean;
    FStatus: Status;
    FStatus_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    procedure SetDefaultAdminUserId(Index: Integer; const Aguid: guid);
    function  DefaultAdminUserId_Specified(Index: Integer): boolean;
    procedure SetDisplayName(Index: Integer; const AWideString: WideString);
    function  DisplayName_Specified(Index: Integer): boolean;
    procedure SetEMail(Index: Integer; const AWideString: WideString);
    function  EMail_Specified(Index: Integer): boolean;
    procedure SetPhone(Index: Integer; const AWideString: WideString);
    function  Phone_Specified(Index: Integer): boolean;
    procedure SetStatus(Index: Integer; const AStatus: Status);
    function  Status_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
  published
    property DefaultAdminUserId: guid         Index (IS_OPTN) read FDefaultAdminUserId write SetDefaultAdminUserId stored DefaultAdminUserId_Specified;
    property DisplayName:        WideString   Index (IS_OPTN or IS_NLBL) read FDisplayName write SetDisplayName stored DisplayName_Specified;
    property EMail:              WideString   Index (IS_OPTN or IS_NLBL) read FEMail write SetEMail stored EMail_Specified;
    property Phone:              WideString   Index (IS_OPTN or IS_NLBL) read FPhone write SetPhone stored Phone_Specified;
    property Status:             Status       Index (IS_OPTN) read FStatus write SetStatus stored Status_Specified;
    property Subscription:       ArrayOfguid  Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
  end;



  // ************************************************************************ //
  // XML       : PracticeRead, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  PracticeRead = class(Practice)
  private
    FCatalogue: ArrayOfCatalogueEntry;
    FCatalogue_Specified: boolean;
    FDomainName: WideString;
    FDomainName_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    FRoles: ArrayOfRole;
    FRoles_Specified: boolean;
    FUsers: ArrayOfUserRead;
    FUsers_Specified: boolean;
    procedure SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
    function  Catalogue_Specified(Index: Integer): boolean;
    procedure SetDomainName(Index: Integer; const AWideString: WideString);
    function  DomainName_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetRoles(Index: Integer; const AArrayOfRole: ArrayOfRole);
    function  Roles_Specified(Index: Integer): boolean;
    procedure SetUsers(Index: Integer; const AArrayOfUserRead: ArrayOfUserRead);
    function  Users_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Catalogue:  ArrayOfCatalogueEntry  Index (IS_OPTN or IS_NLBL) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property DomainName: WideString             Index (IS_OPTN or IS_NLBL) read FDomainName write SetDomainName stored DomainName_Specified;
    property Id:         guid                   Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Roles:      ArrayOfRole            Index (IS_OPTN or IS_NLBL) read FRoles write SetRoles stored Roles_Specified;
    property Users:      ArrayOfUserRead        Index (IS_OPTN or IS_NLBL) read FUsers write SetUsers stored Users_Specified;
  end;



  // ************************************************************************ //
  // XML       : Role, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  Role = class(TRemotable)
  private
    FDescription: WideString;
    FDescription_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    FRoleName: WideString;
    FRoleName_Specified: boolean;
    procedure SetDescription(Index: Integer; const AWideString: WideString);
    function  Description_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetRoleName(Index: Integer; const AWideString: WideString);
    function  RoleName_Specified(Index: Integer): boolean;
  published
    property Description: WideString  Index (IS_OPTN or IS_NLBL) read FDescription write SetDescription stored Description_Specified;
    property Id:          guid        Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property RoleName:    WideString  Index (IS_OPTN or IS_NLBL) read FRoleName write SetRoleName stored RoleName_Specified;
  end;



  // ************************************************************************ //
  // XML       : User, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  User = class(TRemotable)
  private
    FFullName: WideString;
    FFullName_Specified: boolean;
    FRoleNames: ArrayOfstring;
    FRoleNames_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    FUserCode: WideString;
    FUserCode_Specified: boolean;
    procedure SetFullName(Index: Integer; const AWideString: WideString);
    function  FullName_Specified(Index: Integer): boolean;
    procedure SetRoleNames(Index: Integer; const AArrayOfstring: ArrayOfstring);
    function  RoleNames_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
    procedure SetUserCode(Index: Integer; const AWideString: WideString);
    function  UserCode_Specified(Index: Integer): boolean;
  published
    property FullName:     WideString     Index (IS_OPTN or IS_NLBL) read FFullName write SetFullName stored FullName_Specified;
    property RoleNames:    ArrayOfstring  Index (IS_OPTN or IS_NLBL) read FRoleNames write SetRoleNames stored RoleNames_Specified;
    property Subscription: ArrayOfguid    Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
    property UserCode:     WideString     Index (IS_OPTN or IS_NLBL) read FUserCode write SetUserCode stored UserCode_Specified;
  end;



  // ************************************************************************ //
  // XML       : UserRead, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserRead = class(User)
  private
    FEMail: WideString;
    FEMail_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    procedure SetEMail(Index: Integer; const AWideString: WideString);
    function  EMail_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
  published
    property EMail: WideString  Index (IS_OPTN or IS_NLBL) read FEMail write SetEMail stored EMail_Specified;
    property Id:    guid        Index (IS_OPTN) read FId write SetId stored Id_Specified;
  end;



  // ************************************************************************ //
  // XML       : PracticeUpdate, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  PracticeUpdate = class(Practice)
  private
    FId: guid;
    FId_Specified: boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
  published
    property Id: guid  Index (IS_OPTN) read FId write SetId stored Id_Specified;
  end;



  // ************************************************************************ //
  // XML       : UserCreate, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserCreate = class(User)
  private
    FEMail: WideString;
    FEMail_Specified: boolean;
    procedure SetEMail(Index: Integer; const AWideString: WideString);
    function  EMail_Specified(Index: Integer): boolean;
  published
    property EMail: WideString  Index (IS_OPTN or IS_NLBL) read FEMail write SetEMail stored EMail_Specified;
  end;



  // ************************************************************************ //
  // XML       : UserCreatePractice, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserCreatePractice = class(UserCreate)
  private
    FPassword: WideString;
    FPassword_Specified: boolean;
    procedure SetPassword(Index: Integer; const AWideString: WideString);
    function  Password_Specified(Index: Integer): boolean;
  published
    property Password: WideString  Index (IS_OPTN or IS_NLBL) read FPassword write SetPassword stored Password_Specified;
  end;



  // ************************************************************************ //
  // XML       : UserUpdate, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserUpdate = class(User)
  private
    FId: guid;
    FId_Specified: boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
  published
    property Id: guid  Index (IS_OPTN) read FId write SetId stored Id_Specified;
  end;



  // ************************************************************************ //
  // XML       : UserUpdatePractice, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserUpdatePractice = class(UserUpdate)
  private
    FPassword: WideString;
    FPassword_Specified: boolean;
    procedure SetPassword(Index: Integer; const AWideString: WideString);
    function  Password_Specified(Index: Integer): boolean;
  published
    property Password: WideString  Index (IS_OPTN or IS_NLBL) read FPassword write SetPassword stored Password_Specified;
  end;

  ArrayOfClientRead = array of ClientRead;      { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }


  // ************************************************************************ //
  // XML       : ClientList, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientList = class(TRemotable)
  private
    FCatalogue: ArrayOfCatalogueEntry;
    FCatalogue_Specified: boolean;
    FClients: ArrayOfClientRead;
    FClients_Specified: boolean;
    procedure SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
    function  Catalogue_Specified(Index: Integer): boolean;
    procedure SetClients(Index: Integer; const AArrayOfClientRead: ArrayOfClientRead);
    function  Clients_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Catalogue: ArrayOfCatalogueEntry  Index (IS_OPTN or IS_NLBL) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property Clients:   ArrayOfClientRead      Index (IS_OPTN or IS_NLBL) read FClients write SetClients stored Clients_Specified;
  end;



  // ************************************************************************ //
  // XML       : Client, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  Client = class(TRemotable)
  private
    FBillingFrequency: WideString;
    FBillingFrequency_Specified: boolean;
    FClientCode: WideString;
    FClientCode_Specified: boolean;
    FMaxOfflineDays: Integer;
    FMaxOfflineDays_Specified: boolean;
    FName_: WideString;
    FName__Specified: boolean;
    FSecureCode: WideString;
    FSecureCode_Specified: boolean;
    FStatus: Status;
    FStatus_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    procedure SetBillingFrequency(Index: Integer; const AWideString: WideString);
    function  BillingFrequency_Specified(Index: Integer): boolean;
    procedure SetClientCode(Index: Integer; const AWideString: WideString);
    function  ClientCode_Specified(Index: Integer): boolean;
    procedure SetMaxOfflineDays(Index: Integer; const AInteger: Integer);
    function  MaxOfflineDays_Specified(Index: Integer): boolean;
    procedure SetName_(Index: Integer; const AWideString: WideString);
    function  Name__Specified(Index: Integer): boolean;
    procedure SetSecureCode(Index: Integer; const AWideString: WideString);
    function  SecureCode_Specified(Index: Integer): boolean;
    procedure SetStatus(Index: Integer; const AStatus: Status);
    function  Status_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
  published
    property BillingFrequency: WideString   Index (IS_OPTN or IS_NLBL) read FBillingFrequency write SetBillingFrequency stored BillingFrequency_Specified;
    property ClientCode:       WideString   Index (IS_OPTN or IS_NLBL) read FClientCode write SetClientCode stored ClientCode_Specified;
    property MaxOfflineDays:   Integer      Index (IS_OPTN) read FMaxOfflineDays write SetMaxOfflineDays stored MaxOfflineDays_Specified;
    property Name_:            WideString   Index (IS_OPTN or IS_NLBL) read FName_ write SetName_ stored Name__Specified;
    property SecureCode:       WideString   Index (IS_OPTN or IS_NLBL) read FSecureCode write SetSecureCode stored SecureCode_Specified;
    property Status:           Status       Index (IS_OPTN) read FStatus write SetStatus stored Status_Specified;
    property Subscription:     ArrayOfguid  Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
  end;



  // ************************************************************************ //
  // XML       : ClientRead, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientRead = class(Client)
  private
    FId: guid;
    FId_Specified: boolean;
    FPrimaryContactFullName: WideString;
    FPrimaryContactFullName_Specified: boolean;
    FPrimaryContactUserId: guid;
    FPrimaryContactUserId_Specified: boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetPrimaryContactFullName(Index: Integer; const AWideString: WideString);
    function  PrimaryContactFullName_Specified(Index: Integer): boolean;
    procedure SetPrimaryContactUserId(Index: Integer; const Aguid: guid);
    function  PrimaryContactUserId_Specified(Index: Integer): boolean;
  published
    property Id:                     guid        Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property PrimaryContactFullName: WideString  Index (IS_OPTN or IS_NLBL) read FPrimaryContactFullName write SetPrimaryContactFullName stored PrimaryContactFullName_Specified;
    property PrimaryContactUserId:   guid        Index (IS_OPTN) read FPrimaryContactUserId write SetPrimaryContactUserId stored PrimaryContactUserId_Specified;
  end;



  // ************************************************************************ //
  // XML       : ClientReadDetail, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientReadDetail = class(ClientRead)
  private
    FCatalogue: ArrayOfCatalogueEntry;
    FCatalogue_Specified: boolean;
    FRoles: ArrayOfRole;
    FRoles_Specified: boolean;
    FUsers: ArrayOfUserRead;
    FUsers_Specified: boolean;
    procedure SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
    function  Catalogue_Specified(Index: Integer): boolean;
    procedure SetRoles(Index: Integer; const AArrayOfRole: ArrayOfRole);
    function  Roles_Specified(Index: Integer): boolean;
    procedure SetUsers(Index: Integer; const AArrayOfUserRead: ArrayOfUserRead);
    function  Users_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Catalogue: ArrayOfCatalogueEntry  Index (IS_OPTN or IS_NLBL) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property Roles:     ArrayOfRole            Index (IS_OPTN or IS_NLBL) read FRoles write SetRoles stored Roles_Specified;
    property Users:     ArrayOfUserRead        Index (IS_OPTN or IS_NLBL) read FUsers write SetUsers stored Users_Specified;
  end;



  // ************************************************************************ //
  // XML       : ClientCreate, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientCreate = class(Client)
  private
    FAbn: WideString;
    FAbn_Specified: boolean;
    FAddress1: WideString;
    FAddress1_Specified: boolean;
    FAddress2: WideString;
    FAddress2_Specified: boolean;
    FAddress3: WideString;
    FAddress3_Specified: boolean;
    FAddressCountry: WideString;
    FAddressCountry_Specified: boolean;
    FCountryCode: WideString;
    FCountryCode_Specified: boolean;
    FEmail: WideString;
    FEmail_Specified: boolean;
    FFax: WideString;
    FFax_Specified: boolean;
    FMobile: WideString;
    FMobile_Specified: boolean;
    FPhone: WideString;
    FPhone_Specified: boolean;
    FSalutation: WideString;
    FSalutation_Specified: boolean;
    FTaxNumber: WideString;
    FTaxNumber_Specified: boolean;
    FTfn: WideString;
    FTfn_Specified: boolean;
    procedure SetAbn(Index: Integer; const AWideString: WideString);
    function  Abn_Specified(Index: Integer): boolean;
    procedure SetAddress1(Index: Integer; const AWideString: WideString);
    function  Address1_Specified(Index: Integer): boolean;
    procedure SetAddress2(Index: Integer; const AWideString: WideString);
    function  Address2_Specified(Index: Integer): boolean;
    procedure SetAddress3(Index: Integer; const AWideString: WideString);
    function  Address3_Specified(Index: Integer): boolean;
    procedure SetAddressCountry(Index: Integer; const AWideString: WideString);
    function  AddressCountry_Specified(Index: Integer): boolean;
    procedure SetCountryCode(Index: Integer; const AWideString: WideString);
    function  CountryCode_Specified(Index: Integer): boolean;
    procedure SetEmail(Index: Integer; const AWideString: WideString);
    function  Email_Specified(Index: Integer): boolean;
    procedure SetFax(Index: Integer; const AWideString: WideString);
    function  Fax_Specified(Index: Integer): boolean;
    procedure SetMobile(Index: Integer; const AWideString: WideString);
    function  Mobile_Specified(Index: Integer): boolean;
    procedure SetPhone(Index: Integer; const AWideString: WideString);
    function  Phone_Specified(Index: Integer): boolean;
    procedure SetSalutation(Index: Integer; const AWideString: WideString);
    function  Salutation_Specified(Index: Integer): boolean;
    procedure SetTaxNumber(Index: Integer; const AWideString: WideString);
    function  TaxNumber_Specified(Index: Integer): boolean;
    procedure SetTfn(Index: Integer; const AWideString: WideString);
    function  Tfn_Specified(Index: Integer): boolean;
  published
    property Abn:            WideString  Index (IS_OPTN or IS_NLBL) read FAbn write SetAbn stored Abn_Specified;
    property Address1:       WideString  Index (IS_OPTN or IS_NLBL) read FAddress1 write SetAddress1 stored Address1_Specified;
    property Address2:       WideString  Index (IS_OPTN or IS_NLBL) read FAddress2 write SetAddress2 stored Address2_Specified;
    property Address3:       WideString  Index (IS_OPTN or IS_NLBL) read FAddress3 write SetAddress3 stored Address3_Specified;
    property AddressCountry: WideString  Index (IS_OPTN or IS_NLBL) read FAddressCountry write SetAddressCountry stored AddressCountry_Specified;
    property CountryCode:    WideString  Index (IS_OPTN or IS_NLBL) read FCountryCode write SetCountryCode stored CountryCode_Specified;
    property Email:          WideString  Index (IS_OPTN or IS_NLBL) read FEmail write SetEmail stored Email_Specified;
    property Fax:            WideString  Index (IS_OPTN or IS_NLBL) read FFax write SetFax stored Fax_Specified;
    property Mobile:         WideString  Index (IS_OPTN or IS_NLBL) read FMobile write SetMobile stored Mobile_Specified;
    property Phone:          WideString  Index (IS_OPTN or IS_NLBL) read FPhone write SetPhone stored Phone_Specified;
    property Salutation:     WideString  Index (IS_OPTN or IS_NLBL) read FSalutation write SetSalutation stored Salutation_Specified;
    property TaxNumber:      WideString  Index (IS_OPTN or IS_NLBL) read FTaxNumber write SetTaxNumber stored TaxNumber_Specified;
    property Tfn:            WideString  Index (IS_OPTN or IS_NLBL) read FTfn write SetTfn stored Tfn_Specified;
  end;



  // ************************************************************************ //
  // XML       : ClientUpdate, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientUpdate = class(Client)
  private
    FId: guid;
    FId_Specified: boolean;
    FPrimaryContactUserId: guid;
    FPrimaryContactUserId_Specified: boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetPrimaryContactUserId(Index: Integer; const Aguid: guid);
    function  PrimaryContactUserId_Specified(Index: Integer): boolean;
  published
    property Id:                   guid  Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property PrimaryContactUserId: guid  Index (IS_OPTN) read FPrimaryContactUserId write SetPrimaryContactUserId stored PrimaryContactUserId_Specified;
  end;



  // ************************************************************************ //
  // XML       : CatalogueEntry, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  CatalogueEntry2 = class(CatalogueEntry)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : PracticeRead, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  PracticeRead2 = class(PracticeRead)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : Practice, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  Practice2 = class(Practice)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : Role, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  Role2 = class(Role)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : UserRead, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserRead2 = class(UserRead)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : User, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  User2 = class(User)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : PracticeUpdate, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  PracticeUpdate2 = class(PracticeUpdate)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : UserCreatePractice, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserCreatePractice2 = class(UserCreatePractice)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : UserCreate, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserCreate2 = class(UserCreate)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : UserUpdatePractice, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserUpdatePractice2 = class(UserUpdatePractice)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : UserUpdate, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  UserUpdate2 = class(UserUpdate)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ClientList, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientList2 = class(ClientList)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ClientRead, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientRead2 = class(ClientRead)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : Client, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  Client2 = class(Client)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ClientReadDetail, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientReadDetail2 = class(ClientReadDetail)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ClientCreate, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientCreate2 = class(ClientCreate)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ClientUpdate, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientUpdate2 = class(ClientUpdate)
  private
  published
  end;

  UploadResult = class(TRemotable)
  private
    FFileCount: Integer;
    FFileCount_Specified: boolean;
    FMessages: ArrayOfstring;
    FMessages_Specified: boolean;
    FResult: ResultCode;
    FResult_Specified: boolean;
    procedure SetFileCount(Index: Integer; const AInteger: Integer);
    function  FileCount_Specified(Index: Integer): boolean;
    procedure SetMessages(Index: Integer; const AArrayOfstring: ArrayOfstring);
    function  Messages_Specified(Index: Integer): boolean;
    procedure SetResult(Index: Integer; const AResultCode: ResultCode);
    function  Result_Specified(Index: Integer): boolean;
  published
    property FileCount: Integer        Index (IS_OPTN) read FFileCount write SetFileCount stored FileCount_Specified;
    property Messages:  ArrayOfstring  Index (IS_OPTN) read FMessages write SetMessages stored Messages_Specified;
    property Result:    ResultCode     Index (IS_OPTN) read FResult write SetResult stored Result_Specified;
  end;

  
  // ************************************************************************ //
  // XML       : MessageResponseOfArrayOfPracticeBankAccountrLqac6vj, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfArrayOfPracticeBankAccountrLqac6vj = class(MessageResponse)
  private
    FResult: ArrayOfPracticeBankAccount;
    FResult_Specified: boolean;
    
    procedure SetResult(Index: Integer; const AArrayOfPracticeBankAccount: ArrayOfPracticeBankAccount);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: ArrayOfPracticeBankAccount  Index (IS_OPTN) read FResult write SetResult stored Result_Specified;
  end;

  
  // ************************************************************************ //
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // soapAction: http://www.banklinkonline.com/2011/11/Blopi/IBlopiServiceFacade/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : BasicHttpBinding_IBlopiServiceFacade
  // service   : BlopiServiceFacade
  // port      : BasicHttpBinding_IBlopiServiceFacade
  // URL       : https://www.banklinkonline.com/Services/BlopiServiceFacade.svc
  // ************************************************************************ //
  IBlopiServiceFacade = interface(IInvokable)
  ['{88E4B606-483E-CC24-1C42-418E3CD2E07E}']
    function  Echo(const aString: WideString): WideString; stdcall;
    function  EchoArrayOfstring(const strings: ArrayOfstring): WideString; stdcall;
    function  GetPracticeCatalogue(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfArrayOfCatalogueEntryMIdCYrSK; stdcall;
    function  GetSmeCatalogue(const countryCode: WideString; const practiceCode: WideString): MessageResponseOfArrayOfCatalogueEntryMIdCYrSK; stdcall;
    function  GetUserCatalogue(const countryCode: WideString; const practiceCode: WideString; const clientCode: WideString): MessageResponseOfArrayOfCatalogueEntryMIdCYrSK; stdcall;
    function  GetPractice(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfPracticeReadMIdCYrSK; stdcall;
    function  SavePractice(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const practice: PracticeUpdate): MessageResponse; stdcall;
    function  CreatePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const user: UserCreatePractice): MessageResponseOfguid; stdcall;
    function  SavePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const user: UserUpdatePractice): MessageResponse; stdcall;
    function  ResetPracticeUserPassword(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid): MessageResponse; stdcall;
    function  ChangePracticeUserPassword(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid; const oldPassword: WideString; const newPassword: WideString
                                         ): MessageResponse; stdcall;
    function  AuthenticatePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid; const password: WideString): MessageResponse; stdcall;
    function  DeleteUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid): MessageResponse; stdcall;
    function  GetClientList(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfClientListMIdCYrSK; stdcall;
    function  GetClient(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid): MessageResponseOfClientReadDetailMIdCYrSK; stdcall;
    function  GetClientId(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientCode: WideString): MessageResponseOfguid; stdcall;
    function  CreateClient(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const ClientCreate: ClientCreate): MessageResponseOfguid; stdcall;
    function  SaveClient(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const ClientUpdate: ClientUpdate): MessageResponse; stdcall;
    function  CreateClientUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; const user: UserCreate): MessageResponseOfguid; stdcall;
    function  SaveClientUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; const user: UserUpdate): MessageResponse; stdcall;
    function  GetTermsAndConditions(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfstring; stdcall;
    function  GetPracticeDataSubscribers(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfDataPlatformSubscription6cY85e5k; stdcall;
    function  GetPracticeDataSubscriberCredentials(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const subscriberId: guid): MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k; stdcall;
    function  GetPracticeDataSubscriberCount(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k; stdcall;
    function  SavePracticeDataSubscribers(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const subscription: ArrayOfguid): MessageResponse; stdcall;
    function  SavePracticeDataSubscriberCredentials(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const subscriberId: guid; const practiceDataSubscriberCredentials: PracticeDataSubscriberCredentials): MessageResponse; stdcall;
    function  GetClientDataSubscribers(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid): MessageResponseOfDataPlatformSubscription6cY85e5k; stdcall;
    function  SaveClientDataSubscribers(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; const subscription: ArrayOfguid): MessageResponse; stdcall;
    function  GetBankAccountDataSubscribers(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; const accountId: Integer): MessageResponseOfDataPlatformSubscription6cY85e5k; stdcall;
    function  GetBankAccountsDataSubscribers(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid): MessageResponseOfDataPlatformClient6cY85e5k; stdcall;
    function  SaveBankAccountDataSubscribers(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; bankAccountData: DataPlatformBankAccount): MessageResponse; stdcall;
    function  SaveBankAccountsDataSubscribers(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; accountDataList: ArrayOfDataPlatformBankAccount): MessageResponse; stdcall;
    function  GetBankAccounts(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfArrayOfPracticeBankAccountrLqac6vj; stdcall;
  end;

  IBlopiSecureServiceFacade = interface(IInvokable)
  ['{958CF0CB-A3F7-EEBD-CFA2-D2296D3722CD}']
    function  CreatePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const user: UserCreatePractice): MessageResponseOfguid; stdcall;
    function  SavePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const user: UserUpdatePractice): MessageResponse; stdcall;
    function  ResetPracticeUserPassword(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid): MessageResponse; stdcall;
    function  ChangePracticeUserPassword(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid; const oldPassword: WideString; const newPassword: WideString
                                         ): MessageResponse; stdcall;

    function  CreateClient(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const ClientCreate: ClientCreate): MessageResponseOfguid; stdcall;
    function  DeleteUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid): MessageResponse; stdcall;
    function  SaveClient(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const ClientUpdate: ClientUpdate): MessageResponse; stdcall;
    function  CreateClientUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; const user: UserCreate): MessageResponseOfguid; stdcall;
    function  SaveClientUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; const user: UserUpdate): MessageResponse; stdcall;
    function  ProcessData(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const zipedXmlData: WideString): UploadResult; stdcall;
  end;

function GetIBlopiServiceFacade(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IBlopiServiceFacade;
function GetIBlopiSecureServiceFacade(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IBlopiSecureServiceFacade;

implementation

uses SysUtils;

function GetIBlopiServiceFacade(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IBlopiServiceFacade;
const
  defWSDL = 'https://www.banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl';
  defURL  = 'https://www.banklinkonline.com/Services/BlopiServiceFacade.svc';
  defSvc  = 'BlopiServiceFacade';
  defPrt  = 'BasicHttpBinding_IBlopiServiceFacade';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IBlopiServiceFacade);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;

function GetIBlopiSecureServiceFacade(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IBlopiSecureServiceFacade;
const
  defWSDL = 'https://www.banklinkonline.com/Services/BlopiSecureServiceFacade.svc/mex?wsdl';
  defURL  = 'https://www.banklinkonline.com/Services/BlopiSecureServiceFacade.svc';
  defSvc  = 'BlopiSecureServiceFacade';
  defPrt  = 'BasicHttpBinding_IBlopiSecureServiceFacade';
var
  RIO: THTTPRIO;
begin
  Result := nil;
  if (Addr = '') then
  begin
    if UseWSDL then
      Addr := defWSDL
    else
      Addr := defURL;
  end;
  if HTTPRIO = nil then
    RIO := THTTPRIO.Create(nil)
  else
    RIO := HTTPRIO;
  try
    Result := (RIO as IBlopiSecureServiceFacade);
    if UseWSDL then
    begin
      RIO.WSDLLocation := Addr;
      RIO.Service := defSvc;
      RIO.Port := defPrt;
    end else
      RIO.URL := Addr;
  finally
    if (Result = nil) and (HTTPRIO = nil) then
      RIO.Free;
  end;
end;

procedure PracticeBankAccount.SetAccountId(Index: Integer; const AInteger: Integer);
begin
  FAccountId := AInteger;
  FAccountId_Specified := True;
end;

function PracticeBankAccount.AccountId_Specified(Index: Integer): boolean;
begin
  Result := FAccountId_Specified;
end;

procedure PracticeBankAccount.SetAccountName(Index: Integer; const AWideString: WideString);
begin
  FAccountName := AWideString;
  FAccountName_Specified := True;
end;

function PracticeBankAccount.AccountName_Specified(Index: Integer): boolean;
begin
  Result := FAccountName_Specified;
end;

procedure PracticeBankAccount.SetAccountNumber(Index: Integer; const AWideString: WideString);
begin
  FAccountNumber := AWideString;
  FAccountNumber_Specified := True;
end;

function PracticeBankAccount.AccountNumber_Specified(Index: Integer): boolean;
begin
  Result := FAccountNumber_Specified;
end;

procedure PracticeBankAccount.SetCostCode(Index: Integer; const AWideString: WideString);
begin
  FCostCode := AWideString;
  FCostCode_Specified := True;
end;

procedure PracticeBankAccount.SetCreatedDate(Index: Integer;
  const ATXSDateTime: TXSDateTime);
begin
  FCreatedDate := ATXSDateTime;
  FCreatedDate_Specified := True;
end;

function PracticeBankAccount.CostCode_Specified(Index: Integer): boolean;
begin
  Result := FCostCode_Specified;
end;

function PracticeBankAccount.CreatedDate_Specified(Index: Integer): boolean;
begin
  Result := FCreatedDate_Specified;
end;

destructor PracticeBankAccount.Destroy;
begin
  FreeAndNil(FCreatedDate);

  inherited;
end;

procedure PracticeBankAccount.SetFileNumber(Index: Integer; const AWideString: WideString);
begin
  FFileNumber := AWideString;
  FFileNumber_Specified := True;
end;

function PracticeBankAccount.FileNumber_Specified(Index: Integer): boolean;
begin
  Result := FFileNumber_Specified;
end;

procedure PracticeBankAccount.SetRejectionReason(Index: Integer; const AWideString: WideString);
begin
  FRejectionReason := AWideString;
  FRejectionReason_Specified := True;
end;

function PracticeBankAccount.RejectionReason_Specified(Index: Integer): boolean;
begin
  Result := FRejectionReason_Specified;
end;

procedure PracticeBankAccount.SetStatus(Index: Integer; const AWideString: WideString);
begin
  FStatus := AWideString;
  FStatus_Specified := True;
end;

function PracticeBankAccount.Status_Specified(Index: Integer): boolean;
begin
  Result := FStatus_Specified;
end;

destructor DataPlatformSubscription.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FAvailable)-1 do
    SysUtils.FreeAndNil(FAvailable[I]);
  System.SetLength(FAvailable, 0);
  for I := 0 to System.Length(FCurrent)-1 do
    SysUtils.FreeAndNil(FCurrent[I]);
  System.SetLength(FCurrent, 0);
  inherited Destroy;
end;

procedure DataPlatformSubscription.SetAvailable(Index: Integer; const AArrayOfDataPlatformSubscriber: ArrayOfDataPlatformSubscriber);
begin
  FAvailable := AArrayOfDataPlatformSubscriber;
  FAvailable_Specified := True;
end;

function DataPlatformSubscription.Available_Specified(Index: Integer): boolean;
begin
  Result := FAvailable_Specified;
end;

procedure DataPlatformSubscription.SetCurrent(Index: Integer; const AArrayOfDataPlatformSubscriber: ArrayOfDataPlatformSubscriber);
begin
  FCurrent := AArrayOfDataPlatformSubscriber;
  FCurrent_Specified := True;
end;

function DataPlatformSubscription.Current_Specified(Index: Integer): boolean;
begin
  Result := FCurrent_Specified;
end;

procedure DataPlatformSubscriber.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function DataPlatformSubscriber.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure DataPlatformSubscriber.SetName_(Index: Integer; const AWideString: WideString);
begin
  FName_ := AWideString;
  FName__Specified := True;
end;

function DataPlatformSubscriber.Name__Specified(Index: Integer): boolean;
begin
  Result := FName__Specified;
end;

procedure PracticeDataSubscriberCredentials.SetExternalSubscriberId(Index: Integer; const AWideString: WideString);
begin
  FExternalSubscriberId := AWideString;
  FExternalSubscriberId_Specified := True;
end;

function PracticeDataSubscriberCredentials.ExternalSubscriberId_Specified(Index: Integer): boolean;
begin
  Result := FExternalSubscriberId_Specified;
end;

procedure PracticeDataSubscriberCount.SetClientCount(Index: Integer; const AInteger: Integer);
begin
  FClientCount := AInteger;
  FClientCount_Specified := True;
end;

function PracticeDataSubscriberCount.ClientCount_Specified(Index: Integer): boolean;
begin
  Result := FClientCount_Specified;
end;

procedure PracticeDataSubscriberCount.SetClientIds(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FClientIds := AArrayOfguid;
  FClientIds_Specified := True;
end;

function PracticeDataSubscriberCount.ClientIds_Specified(Index: Integer): boolean;
begin
  Result := FClientIds_Specified;
end;

procedure PracticeDataSubscriberCount.SetSubscriberId(Index: Integer; const Aguid: guid);
begin
  FSubscriberId := Aguid;
  FSubscriberId_Specified := True;
end;

function PracticeDataSubscriberCount.SubscriberId_Specified(Index: Integer): boolean;
begin
  Result := FSubscriberId_Specified;
end;

destructor DataPlatformClient.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FAvailable)-1 do
    SysUtils.FreeAndNil(FAvailable[I]);
  System.SetLength(FAvailable, 0);
  for I := 0 to System.Length(FBankAccounts)-1 do
    SysUtils.FreeAndNil(FBankAccounts[I]);
  System.SetLength(FBankAccounts, 0);
  inherited Destroy;
end;

procedure DataPlatformClient.SetAvailable(Index: Integer; const AArrayOfDataPlatformSubscriber: ArrayOfDataPlatformSubscriber);
begin
  FAvailable := AArrayOfDataPlatformSubscriber;
  FAvailable_Specified := True;
end;

function DataPlatformClient.Available_Specified(Index: Integer): boolean;
begin
  Result := FAvailable_Specified;
end;

procedure DataPlatformClient.SetBankAccounts(Index: Integer; const AArrayOfDataPlatformBankAccount: ArrayOfDataPlatformBankAccount);
begin
  FBankAccounts := AArrayOfDataPlatformBankAccount;
  FBankAccounts_Specified := True;
end;

function DataPlatformClient.BankAccounts_Specified(Index: Integer): boolean;
begin
  Result := FBankAccounts_Specified;
end;

function DataPlatformBankAccount.AccountName_Specified(Index: Integer): boolean;
begin
  Result := FAccountName_Specified;
end;

function DataPlatformBankAccount.AccountNumber_Specified(Index: Integer): boolean;
begin
  Result := FAccountNumber_Specified;
end;

procedure DataPlatformBankAccount.SetAccountId(Index: Integer; const AInteger: Integer);
begin
  FAccountId := AInteger;
  FAccountId_Specified := True;
end;

procedure DataPlatformBankAccount.SetAccountName(Index: Integer;
  const AWideString: WideString);
begin
  FAccountName := AWideString;
  FAccountName_Specified := True;
end;

procedure DataPlatformBankAccount.SetAccountNumber(Index: Integer;
  const AWideString: WideString);
begin
  FAccountNumber := AWideString;
  FAccountNumber_Specified := True;
end;

function DataPlatformBankAccount.AccountId_Specified(Index: Integer): boolean;
begin
  Result := FAccountId_Specified;
end;

procedure DataPlatformBankAccount.SetSubscribers(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FSubscribers := AArrayOfguid;
  FSubscribers_Specified := True;
end;

function DataPlatformBankAccount.Subscribers_Specified(Index: Integer): boolean;
begin
  Result := FSubscribers_Specified;
end;

destructor MessageResponse.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FErrorMessages)-1 do
    SysUtils.FreeAndNil(FErrorMessages[I]);
  System.SetLength(FErrorMessages, 0);
  for I := 0 to System.Length(FExceptions)-1 do
    SysUtils.FreeAndNil(FExceptions[I]);
  System.SetLength(FExceptions, 0);
  inherited Destroy;
end;

procedure MessageResponse.SetErrorMessages(Index: Integer; const AArrayOfServiceErrorMessage: ArrayOfServiceErrorMessage);
begin
  FErrorMessages := AArrayOfServiceErrorMessage;
  FErrorMessages_Specified := True;
end;

function MessageResponse.ErrorMessages_Specified(Index: Integer): boolean;
begin
  Result := FErrorMessages_Specified;
end;

procedure MessageResponse.SetExceptions(Index: Integer; const AArrayOfExceptionDetails: ArrayOfExceptionDetails);
begin
  FExceptions := AArrayOfExceptionDetails;
  FExceptions_Specified := True;
end;

function MessageResponse.Exceptions_Specified(Index: Integer): boolean;
begin
  Result := FExceptions_Specified;
end;

procedure MessageResponse.SetSuccess(Index: Integer; const ABoolean: Boolean);
begin
  FSuccess := ABoolean;
  FSuccess_Specified := True;
end;

function MessageResponse.Success_Specified(Index: Integer): boolean;
begin
  Result := FSuccess_Specified;
end;

destructor MessageResponseOfArrayOfCatalogueEntryMIdCYrSK.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FResult)-1 do
    SysUtils.FreeAndNil(FResult[I]);
  System.SetLength(FResult, 0);
  inherited Destroy;
end;

procedure MessageResponseOfArrayOfCatalogueEntryMIdCYrSK.SetResult(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
begin
  FResult := AArrayOfCatalogueEntry;
  FResult_Specified := True;
end;

function MessageResponseOfArrayOfCatalogueEntryMIdCYrSK.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

procedure ServiceErrorMessage.SetErrorCode(Index: Integer; const AWideString: WideString);
begin
  FErrorCode := AWideString;
  FErrorCode_Specified := True;
end;

function ServiceErrorMessage.ErrorCode_Specified(Index: Integer): boolean;
begin
  Result := FErrorCode_Specified;
end;

procedure ServiceErrorMessage.SetMessage_(Index: Integer; const AWideString: WideString);
begin
  FMessage_ := AWideString;
  FMessage__Specified := True;
end;

function ServiceErrorMessage.Message__Specified(Index: Integer): boolean;
begin
  Result := FMessage__Specified;
end;

procedure ExceptionDetails.SetMessage_(Index: Integer; const AWideString: WideString);
begin
  FMessage_ := AWideString;
  FMessage__Specified := True;
end;

function ExceptionDetails.Message__Specified(Index: Integer): boolean;
begin
  Result := FMessage__Specified;
end;

procedure ExceptionDetails.SetSource(Index: Integer; const AWideString: WideString);
begin
  FSource := AWideString;
  FSource_Specified := True;
end;

function ExceptionDetails.Source_Specified(Index: Integer): boolean;
begin
  Result := FSource_Specified;
end;

procedure ExceptionDetails.SetStackTrace(Index: Integer; const AWideString: WideString);
begin
  FStackTrace := AWideString;
  FStackTrace_Specified := True;
end;

function ExceptionDetails.StackTrace_Specified(Index: Integer): boolean;
begin
  Result := FStackTrace_Specified;
end;

destructor MessageResponseOfPracticeReadMIdCYrSK.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfPracticeReadMIdCYrSK.SetResult(Index: Integer; const APracticeRead: PracticeRead);
begin
  FResult := APracticeRead;
  FResult_Specified := True;
end;

function MessageResponseOfPracticeReadMIdCYrSK.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

procedure MessageResponseOfguid.SetResult(Index: Integer; const Aguid: guid);
begin
  FResult := Aguid;
  FResult_Specified := True;
end;

function MessageResponseOfguid.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

destructor MessageResponseOfClientListMIdCYrSK.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfClientListMIdCYrSK.SetResult(Index: Integer; const AClientList: ClientList);
begin
  FResult := AClientList;
  FResult_Specified := True;
end;

function MessageResponseOfClientListMIdCYrSK.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

destructor MessageResponseOfClientReadDetailMIdCYrSK.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfClientReadDetailMIdCYrSK.SetResult(Index: Integer; const AClientReadDetail: ClientReadDetail);
begin
  FResult := AClientReadDetail;
  FResult_Specified := True;
end;

function MessageResponseOfClientReadDetailMIdCYrSK.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

procedure MessageResponseOfstring.SetResult(Index: Integer; const AWideString: WideString);
begin
  FResult := AWideString;
  FResult_Specified := True;
end;

function MessageResponseOfstring.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

destructor MessageResponseOfDataPlatformSubscription6cY85e5k.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfDataPlatformSubscription6cY85e5k.SetResult(Index: Integer; const ADataPlatformSubscription: DataPlatformSubscription);
begin
  FResult := ADataPlatformSubscription;
  FResult_Specified := True;
end;

function MessageResponseOfDataPlatformSubscription6cY85e5k.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

destructor MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k.SetResult(Index: Integer; const APracticeDataSubscriberCredentials: PracticeDataSubscriberCredentials);
begin
  FResult := APracticeDataSubscriberCredentials;
  FResult_Specified := True;
end;

function MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

destructor MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FResult)-1 do
    SysUtils.FreeAndNil(FResult[I]);
  System.SetLength(FResult, 0);
  inherited Destroy;
end;

procedure MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k.SetResult(Index: Integer; const AArrayOfPracticeDataSubscriberCount: ArrayOfPracticeDataSubscriberCount);
begin
  FResult := AArrayOfPracticeDataSubscriberCount;
  FResult_Specified := True;
end;

function MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

destructor MessageResponseOfDataPlatformClient6cY85e5k.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfDataPlatformClient6cY85e5k.SetResult(Index: Integer; const ADataPlatformClient: DataPlatformClient);
begin
  FResult := ADataPlatformClient;
  FResult_Specified := True;
end;

function MessageResponseOfDataPlatformClient6cY85e5k.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

procedure CatalogueEntry.SetCatalogueType(Index: Integer; const AWideString: WideString);
begin
  FCatalogueType := AWideString;
  FCatalogueType_Specified := True;
end;

function CatalogueEntry.CatalogueType_Specified(Index: Integer): boolean;
begin
  Result := FCatalogueType_Specified;
end;

procedure CatalogueEntry.SetDescription(Index: Integer; const AWideString: WideString);
begin
  FDescription := AWideString;
  FDescription_Specified := True;
end;

function CatalogueEntry.Description_Specified(Index: Integer): boolean;
begin
  Result := FDescription_Specified;
end;

procedure CatalogueEntry.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function CatalogueEntry.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure Practice.SetDefaultAdminUserId(Index: Integer; const Aguid: guid);
begin
  FDefaultAdminUserId := Aguid;
  FDefaultAdminUserId_Specified := True;
end;

function Practice.DefaultAdminUserId_Specified(Index: Integer): boolean;
begin
  Result := FDefaultAdminUserId_Specified;
end;

procedure Practice.SetDisplayName(Index: Integer; const AWideString: WideString);
begin
  FDisplayName := AWideString;
  FDisplayName_Specified := True;
end;

function Practice.DisplayName_Specified(Index: Integer): boolean;
begin
  Result := FDisplayName_Specified;
end;

procedure Practice.SetEMail(Index: Integer; const AWideString: WideString);
begin
  FEMail := AWideString;
  FEMail_Specified := True;
end;

function Practice.EMail_Specified(Index: Integer): boolean;
begin
  Result := FEMail_Specified;
end;

procedure Practice.SetPhone(Index: Integer; const AWideString: WideString);
begin
  FPhone := AWideString;
  FPhone_Specified := True;
end;

function Practice.Phone_Specified(Index: Integer): boolean;
begin
  Result := FPhone_Specified;
end;

procedure Practice.SetStatus(Index: Integer; const AStatus: Status);
begin
  FStatus := AStatus;
  FStatus_Specified := True;
end;

function Practice.Status_Specified(Index: Integer): boolean;
begin
  Result := FStatus_Specified;
end;

procedure Practice.SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FSubscription := AArrayOfguid;
  FSubscription_Specified := True;
end;

function Practice.Subscription_Specified(Index: Integer): boolean;
begin
  Result := FSubscription_Specified;
end;

destructor PracticeRead.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FCatalogue)-1 do
    SysUtils.FreeAndNil(FCatalogue[I]);
  System.SetLength(FCatalogue, 0);
  for I := 0 to System.Length(FRoles)-1 do
    SysUtils.FreeAndNil(FRoles[I]);
  System.SetLength(FRoles, 0);
  for I := 0 to System.Length(FUsers)-1 do
    SysUtils.FreeAndNil(FUsers[I]);
  System.SetLength(FUsers, 0);
  inherited Destroy;
end;

procedure PracticeRead.SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
begin
  FCatalogue := AArrayOfCatalogueEntry;
  FCatalogue_Specified := True;
end;

function PracticeRead.Catalogue_Specified(Index: Integer): boolean;
begin
  Result := FCatalogue_Specified;
end;

procedure PracticeRead.SetDomainName(Index: Integer; const AWideString: WideString);
begin
  FDomainName := AWideString;
  FDomainName_Specified := True;
end;

function PracticeRead.DomainName_Specified(Index: Integer): boolean;
begin
  Result := FDomainName_Specified;
end;

procedure PracticeRead.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function PracticeRead.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure PracticeRead.SetRoles(Index: Integer; const AArrayOfRole: ArrayOfRole);
begin
  FRoles := AArrayOfRole;
  FRoles_Specified := True;
end;

function PracticeRead.Roles_Specified(Index: Integer): boolean;
begin
  Result := FRoles_Specified;
end;

procedure PracticeRead.SetUsers(Index: Integer; const AArrayOfUserRead: ArrayOfUserRead);
begin
  FUsers := AArrayOfUserRead;
  FUsers_Specified := True;
end;

function PracticeRead.Users_Specified(Index: Integer): boolean;
begin
  Result := FUsers_Specified;
end;

procedure Role.SetDescription(Index: Integer; const AWideString: WideString);
begin
  FDescription := AWideString;
  FDescription_Specified := True;
end;

function Role.Description_Specified(Index: Integer): boolean;
begin
  Result := FDescription_Specified;
end;

procedure Role.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function Role.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure Role.SetRoleName(Index: Integer; const AWideString: WideString);
begin
  FRoleName := AWideString;
  FRoleName_Specified := True;
end;

function Role.RoleName_Specified(Index: Integer): boolean;
begin
  Result := FRoleName_Specified;
end;

procedure User.SetFullName(Index: Integer; const AWideString: WideString);
begin
  FFullName := AWideString;
  FFullName_Specified := True;
end;

function User.FullName_Specified(Index: Integer): boolean;
begin
  Result := FFullName_Specified;
end;

procedure User.SetRoleNames(Index: Integer; const AArrayOfstring: ArrayOfstring);
begin
  FRoleNames := AArrayOfstring;
  FRoleNames_Specified := True;
end;

function User.RoleNames_Specified(Index: Integer): boolean;
begin
  Result := FRoleNames_Specified;
end;

procedure User.SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FSubscription := AArrayOfguid;
  FSubscription_Specified := True;
end;

function User.Subscription_Specified(Index: Integer): boolean;
begin
  Result := FSubscription_Specified;
end;

procedure User.SetUserCode(Index: Integer; const AWideString: WideString);
begin
  FUserCode := AWideString;
  FUserCode_Specified := True;
end;

function User.UserCode_Specified(Index: Integer): boolean;
begin
  Result := FUserCode_Specified;
end;

procedure UserRead.SetEMail(Index: Integer; const AWideString: WideString);
begin
  FEMail := AWideString;
  FEMail_Specified := True;
end;

function UserRead.EMail_Specified(Index: Integer): boolean;
begin
  Result := FEMail_Specified;
end;

procedure UserRead.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function UserRead.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure PracticeUpdate.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function PracticeUpdate.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure UserCreate.SetEMail(Index: Integer; const AWideString: WideString);
begin
  FEMail := AWideString;
  FEMail_Specified := True;
end;

function UserCreate.EMail_Specified(Index: Integer): boolean;
begin
  Result := FEMail_Specified;
end;

procedure UserCreatePractice.SetPassword(Index: Integer; const AWideString: WideString);
begin
  FPassword := AWideString;
  FPassword_Specified := True;
end;

function UserCreatePractice.Password_Specified(Index: Integer): boolean;
begin
  Result := FPassword_Specified;
end;

procedure UserUpdate.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function UserUpdate.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure UserUpdatePractice.SetPassword(Index: Integer; const AWideString: WideString);
begin
  FPassword := AWideString;
  FPassword_Specified := True;
end;

function UserUpdatePractice.Password_Specified(Index: Integer): boolean;
begin
  Result := FPassword_Specified;
end;

destructor ClientList.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FCatalogue)-1 do
    SysUtils.FreeAndNil(FCatalogue[I]);
  System.SetLength(FCatalogue, 0);
  for I := 0 to System.Length(FClients)-1 do
    SysUtils.FreeAndNil(FClients[I]);
  System.SetLength(FClients, 0);
  inherited Destroy;
end;

procedure ClientList.SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
begin
  FCatalogue := AArrayOfCatalogueEntry;
  FCatalogue_Specified := True;
end;

function ClientList.Catalogue_Specified(Index: Integer): boolean;
begin
  Result := FCatalogue_Specified;
end;

procedure ClientList.SetClients(Index: Integer; const AArrayOfClientRead: ArrayOfClientRead);
begin
  FClients := AArrayOfClientRead;
  FClients_Specified := True;
end;

function ClientList.Clients_Specified(Index: Integer): boolean;
begin
  Result := FClients_Specified;
end;

procedure Client.SetBillingFrequency(Index: Integer; const AWideString: WideString);
begin
  FBillingFrequency := AWideString;
  FBillingFrequency_Specified := True;
end;

function Client.BillingFrequency_Specified(Index: Integer): boolean;
begin
  Result := FBillingFrequency_Specified;
end;

procedure Client.SetClientCode(Index: Integer; const AWideString: WideString);
begin
  FClientCode := AWideString;
  FClientCode_Specified := True;
end;

function Client.ClientCode_Specified(Index: Integer): boolean;
begin
  Result := FClientCode_Specified;
end;

procedure Client.SetMaxOfflineDays(Index: Integer; const AInteger: Integer);
begin
  FMaxOfflineDays := AInteger;
  FMaxOfflineDays_Specified := True;
end;

function Client.MaxOfflineDays_Specified(Index: Integer): boolean;
begin
  Result := FMaxOfflineDays_Specified;
end;

procedure Client.SetName_(Index: Integer; const AWideString: WideString);
begin
  FName_ := AWideString;
  FName__Specified := True;
end;

function Client.Name__Specified(Index: Integer): boolean;
begin
  Result := FName__Specified;
end;

procedure Client.SetSecureCode(Index: Integer; const AWideString: WideString);
begin
  FSecureCode := AWideString;
  FSecureCode_Specified := True;
end;

function Client.SecureCode_Specified(Index: Integer): boolean;
begin
  Result := FSecureCode_Specified;
end;

procedure Client.SetStatus(Index: Integer; const AStatus: Status);
begin
  FStatus := AStatus;
  FStatus_Specified := True;
end;

function Client.Status_Specified(Index: Integer): boolean;
begin
  Result := FStatus_Specified;
end;

procedure Client.SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FSubscription := AArrayOfguid;
  FSubscription_Specified := True;
end;

function Client.Subscription_Specified(Index: Integer): boolean;
begin
  Result := FSubscription_Specified;
end;

procedure ClientRead.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function ClientRead.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure ClientRead.SetPrimaryContactFullName(Index: Integer; const AWideString: WideString);
begin
  FPrimaryContactFullName := AWideString;
  FPrimaryContactFullName_Specified := True;
end;

function ClientRead.PrimaryContactFullName_Specified(Index: Integer): boolean;
begin
  Result := FPrimaryContactFullName_Specified;
end;

procedure ClientRead.SetPrimaryContactUserId(Index: Integer; const Aguid: guid);
begin
  FPrimaryContactUserId := Aguid;
  FPrimaryContactUserId_Specified := True;
end;

function ClientRead.PrimaryContactUserId_Specified(Index: Integer): boolean;
begin
  Result := FPrimaryContactUserId_Specified;
end;

destructor ClientReadDetail.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FCatalogue)-1 do
    SysUtils.FreeAndNil(FCatalogue[I]);
  System.SetLength(FCatalogue, 0);
  for I := 0 to System.Length(FRoles)-1 do
    SysUtils.FreeAndNil(FRoles[I]);
  System.SetLength(FRoles, 0);
  for I := 0 to System.Length(FUsers)-1 do
    SysUtils.FreeAndNil(FUsers[I]);
  System.SetLength(FUsers, 0);
  inherited Destroy;
end;

procedure ClientReadDetail.SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
begin
  FCatalogue := AArrayOfCatalogueEntry;
  FCatalogue_Specified := True;
end;

function ClientReadDetail.Catalogue_Specified(Index: Integer): boolean;
begin
  Result := FCatalogue_Specified;
end;

procedure ClientReadDetail.SetRoles(Index: Integer; const AArrayOfRole: ArrayOfRole);
begin
  FRoles := AArrayOfRole;
  FRoles_Specified := True;
end;

function ClientReadDetail.Roles_Specified(Index: Integer): boolean;
begin
  Result := FRoles_Specified;
end;

procedure ClientReadDetail.SetUsers(Index: Integer; const AArrayOfUserRead: ArrayOfUserRead);
begin
  FUsers := AArrayOfUserRead;
  FUsers_Specified := True;
end;

function ClientReadDetail.Users_Specified(Index: Integer): boolean;
begin
  Result := FUsers_Specified;
end;

procedure ClientCreate.SetAbn(Index: Integer; const AWideString: WideString);
begin
  FAbn := AWideString;
  FAbn_Specified := True;
end;

function ClientCreate.Abn_Specified(Index: Integer): boolean;
begin
  Result := FAbn_Specified;
end;

procedure ClientCreate.SetAddress1(Index: Integer; const AWideString: WideString);
begin
  FAddress1 := AWideString;
  FAddress1_Specified := True;
end;

function ClientCreate.Address1_Specified(Index: Integer): boolean;
begin
  Result := FAddress1_Specified;
end;

procedure ClientCreate.SetAddress2(Index: Integer; const AWideString: WideString);
begin
  FAddress2 := AWideString;
  FAddress2_Specified := True;
end;

function ClientCreate.Address2_Specified(Index: Integer): boolean;
begin
  Result := FAddress2_Specified;
end;

procedure ClientCreate.SetAddress3(Index: Integer; const AWideString: WideString);
begin
  FAddress3 := AWideString;
  FAddress3_Specified := True;
end;

function ClientCreate.Address3_Specified(Index: Integer): boolean;
begin
  Result := FAddress3_Specified;
end;

procedure ClientCreate.SetAddressCountry(Index: Integer; const AWideString: WideString);
begin
  FAddressCountry := AWideString;
  FAddressCountry_Specified := True;
end;

function ClientCreate.AddressCountry_Specified(Index: Integer): boolean;
begin
  Result := FAddressCountry_Specified;
end;

procedure ClientCreate.SetCountryCode(Index: Integer; const AWideString: WideString);
begin
  FCountryCode := AWideString;
  FCountryCode_Specified := True;
end;

function ClientCreate.CountryCode_Specified(Index: Integer): boolean;
begin
  Result := FCountryCode_Specified;
end;

procedure ClientCreate.SetEmail(Index: Integer; const AWideString: WideString);
begin
  FEmail := AWideString;
  FEmail_Specified := True;
end;

function ClientCreate.Email_Specified(Index: Integer): boolean;
begin
  Result := FEmail_Specified;
end;

procedure ClientCreate.SetFax(Index: Integer; const AWideString: WideString);
begin
  FFax := AWideString;
  FFax_Specified := True;
end;

function ClientCreate.Fax_Specified(Index: Integer): boolean;
begin
  Result := FFax_Specified;
end;

procedure ClientCreate.SetMobile(Index: Integer; const AWideString: WideString);
begin
  FMobile := AWideString;
  FMobile_Specified := True;
end;

function ClientCreate.Mobile_Specified(Index: Integer): boolean;
begin
  Result := FMobile_Specified;
end;

procedure ClientCreate.SetPhone(Index: Integer; const AWideString: WideString);
begin
  FPhone := AWideString;
  FPhone_Specified := True;
end;

function ClientCreate.Phone_Specified(Index: Integer): boolean;
begin
  Result := FPhone_Specified;
end;

procedure ClientCreate.SetSalutation(Index: Integer; const AWideString: WideString);
begin
  FSalutation := AWideString;
  FSalutation_Specified := True;
end;

function ClientCreate.Salutation_Specified(Index: Integer): boolean;
begin
  Result := FSalutation_Specified;
end;

procedure ClientCreate.SetTaxNumber(Index: Integer; const AWideString: WideString);
begin
  FTaxNumber := AWideString;
  FTaxNumber_Specified := True;
end;

function ClientCreate.TaxNumber_Specified(Index: Integer): boolean;
begin
  Result := FTaxNumber_Specified;
end;

procedure ClientCreate.SetTfn(Index: Integer; const AWideString: WideString);
begin
  FTfn := AWideString;
  FTfn_Specified := True;
end;

function ClientCreate.Tfn_Specified(Index: Integer): boolean;
begin
  Result := FTfn_Specified;
end;

procedure ClientUpdate.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function ClientUpdate.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure ClientUpdate.SetPrimaryContactUserId(Index: Integer; const Aguid: guid);
begin
  FPrimaryContactUserId := Aguid;
  FPrimaryContactUserId_Specified := True;
end;

function ClientUpdate.PrimaryContactUserId_Specified(Index: Integer): boolean;
begin
  Result := FPrimaryContactUserId_Specified;
end;

{ UploadResult }

function UploadResult.FileCount_Specified(Index: Integer): boolean;
begin
  Result := FFileCount_Specified;
end;

function UploadResult.Messages_Specified(Index: Integer): boolean;
begin
  Result := FMessages_Specified;
end;

function UploadResult.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

procedure UploadResult.SetFileCount(Index: Integer; const AInteger: Integer);
begin
  FFileCount := AInteger;
  FFileCount_Specified := True;
end;

procedure UploadResult.SetMessages(Index: Integer;
  const AArrayOfstring: ArrayOfstring);
begin
  FMessages := AArrayOfstring;
  FMessages_Specified := True;
end;

procedure UploadResult.SetResult(Index: Integer; const AResultCode: ResultCode);
begin
  FResult := AResultCode;
  FResult_Specified := True;
end;

{ MessageResponseOfArrayOfPracticeBankAccountrLqac6vj }

destructor MessageResponseOfArrayOfPracticeBankAccountrLqac6vj.Destroy;
var
  I: Integer;
begin
  for I := 0 to Length(FResult)-1 do
    FreeAndNil(FResult[I]);
  SetLength(FResult, 0);
  inherited Destroy;
end;

function MessageResponseOfArrayOfPracticeBankAccountrLqac6vj.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

procedure MessageResponseOfArrayOfPracticeBankAccountrLqac6vj.SetResult(Index: Integer; const AArrayOfPracticeBankAccount: ArrayOfPracticeBankAccount);
begin
  FResult := AArrayOfPracticeBankAccount;
  FResult_Specified := True;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IBlopiServiceFacade), 'http://www.banklinkonline.com/2011/11/Blopi', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IBlopiServiceFacade), 'http://www.banklinkonline.com/2011/11/Blopi/IBlopiServiceFacade/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IBlopiServiceFacade), ioDocument);

  InvRegistry.RegisterInterface(TypeInfo(IBlopiSecureServiceFacade), 'http://www.banklinkonline.com/2011/11/Blopi', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IBlopiSecureServiceFacade), 'http://www.banklinkonline.com/2011/11/Blopi/IBlopiSecureServiceFacade/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IBlopiSecureServiceFacade), ioDocument);

  RemClassRegistry.RegisterXSInfo(TypeInfo(guid), 'http://schemas.microsoft.com/2003/10/Serialization/', 'guid');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfstring), 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'ArrayOfstring');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfguid), 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'ArrayOfguid');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfint), 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'ArrayOfint');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfDataPlatformSubscriber), 'http://www.banklinkonline.com/2011/11/DataPlatform', 'ArrayOfDataPlatformSubscriber');
  RemClassRegistry.RegisterXSClass(DataPlatformSubscription, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'DataPlatformSubscription');
  RemClassRegistry.RegisterXSClass(DataPlatformSubscriber, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'DataPlatformSubscriber');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(DataPlatformSubscriber), 'Name_', 'Name');
  RemClassRegistry.RegisterXSClass(PracticeDataSubscriberCredentials, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'PracticeDataSubscriberCredentials');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfPracticeDataSubscriberCount), 'http://www.banklinkonline.com/2011/11/DataPlatform', 'ArrayOfPracticeDataSubscriberCount');
  RemClassRegistry.RegisterXSClass(PracticeDataSubscriberCount, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'PracticeDataSubscriberCount');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfDataPlatformBankAccount), 'http://www.banklinkonline.com/2011/11/DataPlatform', 'ArrayOfDataPlatformBankAccount');
  RemClassRegistry.RegisterXSClass(DataPlatformClient, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'DataPlatformClient');
  RemClassRegistry.RegisterXSClass(DataPlatformBankAccount, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'DataPlatformBankAccount');
  RemClassRegistry.RegisterXSClass(DataPlatformSubscription2, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'DataPlatformSubscription2', 'DataPlatformSubscription');
  RemClassRegistry.RegisterXSClass(DataPlatformSubscriber2, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'DataPlatformSubscriber2', 'DataPlatformSubscriber');
  RemClassRegistry.RegisterXSClass(PracticeDataSubscriberCredentials2, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'PracticeDataSubscriberCredentials2', 'PracticeDataSubscriberCredentials');
  RemClassRegistry.RegisterXSClass(PracticeDataSubscriberCount2, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'PracticeDataSubscriberCount2', 'PracticeDataSubscriberCount');
  RemClassRegistry.RegisterXSClass(DataPlatformClient2, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'DataPlatformClient2', 'DataPlatformClient');
  RemClassRegistry.RegisterXSClass(DataPlatformBankAccount2, 'http://www.banklinkonline.com/2011/11/DataPlatform', 'DataPlatformBankAccount2', 'DataPlatformBankAccount');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfCatalogueEntry), 'http://www.banklinkonline.com/2011/11/Blopi', 'ArrayOfCatalogueEntry');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfServiceErrorMessage), 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ArrayOfServiceErrorMessage');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfExceptionDetails), 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ArrayOfExceptionDetails');
  RemClassRegistry.RegisterXSClass(MessageResponse, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponse');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfCatalogueEntryMIdCYrSK, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfCatalogueEntryMIdCYrSK');
  RemClassRegistry.RegisterXSClass(ServiceErrorMessage, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ServiceErrorMessage');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ServiceErrorMessage), 'Message_', 'Message');
  RemClassRegistry.RegisterXSClass(ExceptionDetails, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ExceptionDetails');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ExceptionDetails), 'Message_', 'Message');
  RemClassRegistry.RegisterXSClass(MessageResponseOfPracticeReadMIdCYrSK, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfPracticeReadMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfguid, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfguid');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientListMIdCYrSK, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientListMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientReadDetailMIdCYrSK, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientReadDetailMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfstring, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfstring');
  RemClassRegistry.RegisterXSClass(MessageResponseOfDataPlatformSubscription6cY85e5k, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfDataPlatformSubscription6cY85e5k');
  RemClassRegistry.RegisterXSClass(MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k');
  RemClassRegistry.RegisterXSClass(MessageResponseOfDataPlatformClient6cY85e5k, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfDataPlatformClient6cY85e5k');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfCatalogueEntryMIdCYrSK2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfCatalogueEntryMIdCYrSK2', 'MessageResponseOfArrayOfCatalogueEntryMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponse2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponse2', 'MessageResponse');
  RemClassRegistry.RegisterXSClass(ServiceErrorMessage2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ServiceErrorMessage2', 'ServiceErrorMessage');
  RemClassRegistry.RegisterXSClass(ExceptionDetails2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ExceptionDetails2', 'ExceptionDetails');
  RemClassRegistry.RegisterXSClass(MessageResponseOfPracticeReadMIdCYrSK2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfPracticeReadMIdCYrSK2', 'MessageResponseOfPracticeReadMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfguid2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfguid2', 'MessageResponseOfguid');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientListMIdCYrSK2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientListMIdCYrSK2', 'MessageResponseOfClientListMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientReadDetailMIdCYrSK2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientReadDetailMIdCYrSK2', 'MessageResponseOfClientReadDetailMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfstring2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfstring2', 'MessageResponseOfstring');
  RemClassRegistry.RegisterXSClass(MessageResponseOfDataPlatformSubscription6cY85e5k2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfDataPlatformSubscription6cY85e5k2', 'MessageResponseOfDataPlatformSubscription6cY85e5k');
  RemClassRegistry.RegisterXSClass(MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k2', 'MessageResponseOfPracticeDataSubscriberCredentials6cY85e5k');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k2', 'MessageResponseOfArrayOfPracticeDataSubscriberCount6cY85e5k');
  RemClassRegistry.RegisterXSClass(MessageResponseOfDataPlatformClient6cY85e5k2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfDataPlatformClient6cY85e5k2', 'MessageResponseOfDataPlatformClient6cY85e5k');
  RemClassRegistry.RegisterXSClass(CatalogueEntry, 'http://www.banklinkonline.com/2011/11/Blopi', 'CatalogueEntry');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfRole), 'http://www.banklinkonline.com/2011/11/Blopi', 'ArrayOfRole');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfUserRead), 'http://www.banklinkonline.com/2011/11/Blopi', 'ArrayOfUserRead');
  RemClassRegistry.RegisterXSInfo(TypeInfo(Status), 'http://www.banklinkonline.com/2011/11/Blopi', 'Status');
  RemClassRegistry.RegisterXSClass(Practice, 'http://www.banklinkonline.com/2011/11/Blopi', 'Practice');
  RemClassRegistry.RegisterXSClass(PracticeRead, 'http://www.banklinkonline.com/2011/11/Blopi', 'PracticeRead');
  RemClassRegistry.RegisterXSClass(Role, 'http://www.banklinkonline.com/2011/11/Blopi', 'Role');
  RemClassRegistry.RegisterXSClass(User, 'http://www.banklinkonline.com/2011/11/Blopi', 'User');
  RemClassRegistry.RegisterXSClass(UserRead, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserRead');
  RemClassRegistry.RegisterXSClass(PracticeUpdate, 'http://www.banklinkonline.com/2011/11/Blopi', 'PracticeUpdate');
  RemClassRegistry.RegisterXSClass(UserCreate, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserCreate');
  RemClassRegistry.RegisterXSClass(UserCreatePractice, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserCreatePractice');
  RemClassRegistry.RegisterXSClass(UserUpdate, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserUpdate');
  RemClassRegistry.RegisterXSClass(UserUpdatePractice, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserUpdatePractice');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfClientRead), 'http://www.banklinkonline.com/2011/11/Blopi', 'ArrayOfClientRead');
  RemClassRegistry.RegisterXSClass(ClientList, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientList');
  RemClassRegistry.RegisterXSClass(Client, 'http://www.banklinkonline.com/2011/11/Blopi', 'Client');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(Client), 'Name_', 'Name');
  RemClassRegistry.RegisterXSClass(ClientRead, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientRead');
  RemClassRegistry.RegisterXSClass(ClientReadDetail, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientReadDetail');
  RemClassRegistry.RegisterXSClass(ClientCreate, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientCreate');
  RemClassRegistry.RegisterXSClass(ClientUpdate, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientUpdate');
  RemClassRegistry.RegisterXSClass(CatalogueEntry2, 'http://www.banklinkonline.com/2011/11/Blopi', 'CatalogueEntry2', 'CatalogueEntry');
  RemClassRegistry.RegisterXSClass(PracticeRead2, 'http://www.banklinkonline.com/2011/11/Blopi', 'PracticeRead2', 'PracticeRead');
  RemClassRegistry.RegisterXSClass(Practice2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Practice2', 'Practice');
  RemClassRegistry.RegisterXSClass(Role2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Role2', 'Role');
  RemClassRegistry.RegisterXSClass(UserRead2, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserRead2', 'UserRead');
  RemClassRegistry.RegisterXSClass(User2, 'http://www.banklinkonline.com/2011/11/Blopi', 'User2', 'User');
  RemClassRegistry.RegisterXSClass(PracticeUpdate2, 'http://www.banklinkonline.com/2011/11/Blopi', 'PracticeUpdate2', 'PracticeUpdate');
  RemClassRegistry.RegisterXSClass(UserCreatePractice2, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserCreatePractice2', 'UserCreatePractice');
  RemClassRegistry.RegisterXSClass(UserCreate2, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserCreate2', 'UserCreate');
  RemClassRegistry.RegisterXSClass(UserUpdatePractice2, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserUpdatePractice2', 'UserUpdatePractice');
  RemClassRegistry.RegisterXSClass(UserUpdate2, 'http://www.banklinkonline.com/2011/11/Blopi', 'UserUpdate2', 'UserUpdate');
  RemClassRegistry.RegisterXSClass(ClientList2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientList2', 'ClientList');
  RemClassRegistry.RegisterXSClass(ClientRead2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientRead2', 'ClientRead');
  RemClassRegistry.RegisterXSClass(Client2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Client2', 'Client');
  RemClassRegistry.RegisterXSClass(ClientReadDetail2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientReadDetail2', 'ClientReadDetail');
  RemClassRegistry.RegisterXSClass(ClientCreate2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientCreate2', 'ClientCreate');
  RemClassRegistry.RegisterXSClass(ClientUpdate2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientUpdate2', 'ClientUpdate');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfPracticeBankAccountrLqac6vj, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfPracticeBankAccountrLqac6vj');
  RemClassRegistry.RegisterXSClass(PracticeBankAccount, 'http://schemas.datacontract.org/2004/07/BankLink.PracticeIntegration.Contract.DataContracts', 'PracticeBankAccount');
  
end.
