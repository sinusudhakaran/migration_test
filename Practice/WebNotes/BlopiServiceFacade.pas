// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://localhost:51659/Services/BlopiServiceFacade.svc?wsdl
//  >Import : http://localhost:51659/Services/BlopiServiceFacade.svc?wsdl=wsdl0
//  >Import : http://localhost:51659/Services/BlopiServiceFacade.svc?wsdl=wsdl0>0
//  >Import : http://localhost:51659/Services/BlopiServiceFacade.svc?xsd=xsd0
//  >Import : http://localhost:51659/Services/BlopiServiceFacade.svc?xsd=xsd1
//  >Import : http://localhost:51659/Services/BlopiServiceFacade.svc?xsd=xsd2
//  >Import : http://localhost:51659/Services/BlopiServiceFacade.svc?xsd=xsd3
// Encoding : utf-8
// Codegen  : [wfMapStringsToWideStrings+]
// Version  : 1.0
// (8/11/2011 11:15:05 a.m. - - $Rev: 25127 $)
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
  // !:string          - "http://www.w3.org/2001/XMLSchema"[Gbl]
  // !:boolean         - "http://www.w3.org/2001/XMLSchema"[Gbl]

  MessageResponse      = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfArrayOfCatalogueEntryn8pcGHF3 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ServiceErrorMessage  = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ExceptionDetails     = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfPracticen8pcGHF3 = class;    { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfClientListn8pcGHF3 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfArrayOfCatalogueEntryn8pcGHF32 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponse2     = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  ServiceErrorMessage2 = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  ExceptionDetails2    = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfPracticen8pcGHF32 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfClientListn8pcGHF32 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  CatalogueEntry       = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }
  Practice             = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }
  Role                 = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }
  User                 = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }
  ClientList           = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }
  Client               = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }
  CatalogueEntry2      = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblElm] }
  Practice2            = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblElm] }
  Role2                = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblElm] }
  User2                = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblElm] }
  ClientList2          = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblElm] }
  Client2              = class;                 { "https://banklinkonline.com/2011/10/BLOPI"[GblElm] }

  {$SCOPEDENUMS ON}
  { "https://banklinkonline.com/2011/10/BLOPI"[GblSmpl] }
  ClientStatus = (Active, Suspended);

  {$SCOPEDENUMS OFF}

  guid            =  type WideString;      { "http://schemas.microsoft.com/2003/10/Serialization/"[GblSmpl] }
  ArrayOfCatalogueEntry = array of CatalogueEntry;   { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }
  ArrayOfServiceErrorMessage = array of ServiceErrorMessage;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ArrayOfExceptionDetails = array of ExceptionDetails;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }


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
  // XML       : MessageResponseOfArrayOfCatalogueEntryn8pcGHF3, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfArrayOfCatalogueEntryn8pcGHF3 = class(MessageResponse)
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
  // XML       : MessageResponseOfPracticen8pcGHF3, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfPracticen8pcGHF3 = class(MessageResponse)
  private
    FResult: Practice;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const APractice: Practice);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: Practice  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfClientListn8pcGHF3, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfClientListn8pcGHF3 = class(MessageResponse)
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
  // XML       : MessageResponseOfArrayOfCatalogueEntryn8pcGHF3, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfArrayOfCatalogueEntryn8pcGHF32 = class(MessageResponseOfArrayOfCatalogueEntryn8pcGHF3)
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
  // XML       : MessageResponseOfPracticen8pcGHF3, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfPracticen8pcGHF32 = class(MessageResponseOfPracticen8pcGHF3)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfClientListn8pcGHF3, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfClientListn8pcGHF32 = class(MessageResponseOfClientListn8pcGHF3)
  private
  published
  end;

  ArrayOfguid = array of guid;                  { "http://schemas.microsoft.com/2003/10/Serialization/Arrays"[GblCplx] }


  // ************************************************************************ //
  // XML       : CatalogueEntry, global, <complexType>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
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

  ArrayOfRole = array of Role;                  { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }
  ArrayOfUser = array of User;                  { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }


  // ************************************************************************ //
  // XML       : Practice, global, <complexType>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  Practice = class(TRemotable)
  private
    FCatalogue: ArrayOfCatalogueEntry;
    FCatalogue_Specified: boolean;
    FDefaultAdminUserId: guid;
    FDefaultAdminUserId_Specified: boolean;
    FDisplayName: WideString;
    FDisplayName_Specified: boolean;
    FDomainName: WideString;
    FDomainName_Specified: boolean;
    FEMail: WideString;
    FEMail_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    FPhone: WideString;
    FPhone_Specified: boolean;
    FRoles: ArrayOfRole;
    FRoles_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    FUsers: ArrayOfUser;
    FUsers_Specified: boolean;
    procedure SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
    function  Catalogue_Specified(Index: Integer): boolean;
    procedure SetDefaultAdminUserId(Index: Integer; const Aguid: guid);
    function  DefaultAdminUserId_Specified(Index: Integer): boolean;
    procedure SetDisplayName(Index: Integer; const AWideString: WideString);
    function  DisplayName_Specified(Index: Integer): boolean;
    procedure SetDomainName(Index: Integer; const AWideString: WideString);
    function  DomainName_Specified(Index: Integer): boolean;
    procedure SetEMail(Index: Integer; const AWideString: WideString);
    function  EMail_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetPhone(Index: Integer; const AWideString: WideString);
    function  Phone_Specified(Index: Integer): boolean;
    procedure SetRoles(Index: Integer; const AArrayOfRole: ArrayOfRole);
    function  Roles_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
    procedure SetUsers(Index: Integer; const AArrayOfUser: ArrayOfUser);
    function  Users_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Catalogue:          ArrayOfCatalogueEntry  Index (IS_OPTN or IS_NLBL) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property DefaultAdminUserId: guid                   Index (IS_OPTN) read FDefaultAdminUserId write SetDefaultAdminUserId stored DefaultAdminUserId_Specified;
    property DisplayName:        WideString             Index (IS_OPTN or IS_NLBL) read FDisplayName write SetDisplayName stored DisplayName_Specified;
    property DomainName:         WideString             Index (IS_OPTN or IS_NLBL) read FDomainName write SetDomainName stored DomainName_Specified;
    property EMail:              WideString             Index (IS_OPTN or IS_NLBL) read FEMail write SetEMail stored EMail_Specified;
    property Id:                 guid                   Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Phone:              WideString             Index (IS_OPTN or IS_NLBL) read FPhone write SetPhone stored Phone_Specified;
    property Roles:              ArrayOfRole            Index (IS_OPTN or IS_NLBL) read FRoles write SetRoles stored Roles_Specified;
    property Subscription:       ArrayOfguid            Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
    property Users:              ArrayOfUser            Index (IS_OPTN or IS_NLBL) read FUsers write SetUsers stored Users_Specified;
  end;



  // ************************************************************************ //
  // XML       : Role, global, <complexType>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  Role = class(TRemotable)
  private
    FDescription: WideString;
    FDescription_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    procedure SetDescription(Index: Integer; const AWideString: WideString);
    function  Description_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
  published
    property Description: WideString  Index (IS_OPTN or IS_NLBL) read FDescription write SetDescription stored Description_Specified;
    property Id:          guid        Index (IS_OPTN) read FId write SetId stored Id_Specified;
  end;



  // ************************************************************************ //
  // XML       : User, global, <complexType>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  User = class(TRemotable)
  private
    FEMail: WideString;
    FEMail_Specified: boolean;
    FFullName: WideString;
    FFullName_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    FRoleIds: ArrayOfguid;
    FRoleIds_Specified: boolean;
    FUserCode: WideString;
    FUserCode_Specified: boolean;
    procedure SetEMail(Index: Integer; const AWideString: WideString);
    function  EMail_Specified(Index: Integer): boolean;
    procedure SetFullName(Index: Integer; const AWideString: WideString);
    function  FullName_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetRoleIds(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  RoleIds_Specified(Index: Integer): boolean;
    procedure SetUserCode(Index: Integer; const AWideString: WideString);
    function  UserCode_Specified(Index: Integer): boolean;
  published
    property EMail:    WideString   Index (IS_OPTN or IS_NLBL) read FEMail write SetEMail stored EMail_Specified;
    property FullName: WideString   Index (IS_OPTN or IS_NLBL) read FFullName write SetFullName stored FullName_Specified;
    property Id:       guid         Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property RoleIds:  ArrayOfguid  Index (IS_OPTN or IS_NLBL) read FRoleIds write SetRoleIds stored RoleIds_Specified;
    property UserCode: WideString   Index (IS_OPTN or IS_NLBL) read FUserCode write SetUserCode stored UserCode_Specified;
  end;

  ArrayOfClient = array of Client;              { "https://banklinkonline.com/2011/10/BLOPI"[GblCplx] }


  // ************************************************************************ //
  // XML       : ClientList, global, <complexType>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  ClientList = class(TRemotable)
  private
    FCatalogue: ArrayOfCatalogueEntry;
    FCatalogue_Specified: boolean;
    FClients: ArrayOfClient;
    FClients_Specified: boolean;
    procedure SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
    function  Catalogue_Specified(Index: Integer): boolean;
    procedure SetClients(Index: Integer; const AArrayOfClient: ArrayOfClient);
    function  Clients_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Catalogue: ArrayOfCatalogueEntry  Index (IS_OPTN or IS_NLBL) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property Clients:   ArrayOfClient          Index (IS_OPTN or IS_NLBL) read FClients write SetClients stored Clients_Specified;
  end;



  // ************************************************************************ //
  // XML       : Client, global, <complexType>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  Client = class(TRemotable)
  private
    FClientCode: WideString;
    FClientCode_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    FStatus: ClientStatus;
    FStatus_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    procedure SetClientCode(Index: Integer; const AWideString: WideString);
    function  ClientCode_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetStatus(Index: Integer; const AClientStatus: ClientStatus);
    function  Status_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
  published
    property ClientCode:   WideString    Index (IS_OPTN or IS_NLBL) read FClientCode write SetClientCode stored ClientCode_Specified;
    property Id:           guid          Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Status:       ClientStatus  Index (IS_OPTN) read FStatus write SetStatus stored Status_Specified;
    property Subscription: ArrayOfguid   Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
  end;



  // ************************************************************************ //
  // XML       : CatalogueEntry, global, <element>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  CatalogueEntry2 = class(CatalogueEntry)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : Practice, global, <element>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  Practice2 = class(Practice)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : Role, global, <element>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  Role2 = class(Role)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : User, global, <element>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  User2 = class(User)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : ClientList, global, <element>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  ClientList2 = class(ClientList)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : Client, global, <element>
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // ************************************************************************ //
  Client2 = class(Client)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : https://banklinkonline.com/2011/10/BLOPI
  // soapAction: https://banklinkonline.com/2011/10/BLOPI/IBlopiServiceFacade/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : BasicHttpBinding_IBlopiServiceFacade
  // service   : BlopiServiceFacade
  // port      : BasicHttpBinding_IBlopiServiceFacade
  // URL       : http://localhost:51659/Services/BlopiServiceFacade.svc
  // ************************************************************************ //
  IBlopiServiceFacade = interface(IInvokable)
  ['{ACA4AC84-4427-74C6-AA4F-EA82FFCA4B3D}']
    function  Echo(const aString: WideString): WideString; stdcall;
    function  GetPracticeCatalogue(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfArrayOfCatalogueEntryn8pcGHF3; stdcall;
    function  GetSmeCatalogue(const countryCode: WideString; const practiceCode: WideString): MessageResponseOfArrayOfCatalogueEntryn8pcGHF3; stdcall;
    function  GetUserCatalogue(const countryCode: WideString; const practiceCode: WideString; const clientCode: WideString): MessageResponseOfArrayOfCatalogueEntryn8pcGHF3; stdcall;
    function  GetPracticeDetail(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfPracticen8pcGHF3; stdcall;
    function  GetClientList(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfClientListn8pcGHF3; stdcall;
    function  DeletePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid): MessageResponse; stdcall;
  end;

function GetIBlopiServiceFacade(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IBlopiServiceFacade;


implementation
  uses SysUtils;

function GetIBlopiServiceFacade(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IBlopiServiceFacade;
const
  defWSDL = 'http://localhost:51659/Services/BlopiServiceFacade.svc?wsdl';
  defURL  = 'http://localhost:51659/Services/BlopiServiceFacade.svc';
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

destructor MessageResponseOfArrayOfCatalogueEntryn8pcGHF3.Destroy;
var
  I: Integer;
begin
  for I := 0 to System.Length(FResult)-1 do
    SysUtils.FreeAndNil(FResult[I]);
  System.SetLength(FResult, 0);
  inherited Destroy;
end;

procedure MessageResponseOfArrayOfCatalogueEntryn8pcGHF3.SetResult(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
begin
  FResult := AArrayOfCatalogueEntry;
  FResult_Specified := True;
end;

function MessageResponseOfArrayOfCatalogueEntryn8pcGHF3.Result_Specified(Index: Integer): boolean;
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

destructor MessageResponseOfPracticen8pcGHF3.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfPracticen8pcGHF3.SetResult(Index: Integer; const APractice: Practice);
begin
  FResult := APractice;
  FResult_Specified := True;
end;

function MessageResponseOfPracticen8pcGHF3.Result_Specified(Index: Integer): boolean;
begin
  Result := FResult_Specified;
end;

destructor MessageResponseOfClientListn8pcGHF3.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfClientListn8pcGHF3.SetResult(Index: Integer; const AClientList: ClientList);
begin
  FResult := AClientList;
  FResult_Specified := True;
end;

function MessageResponseOfClientListn8pcGHF3.Result_Specified(Index: Integer): boolean;
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

destructor Practice.Destroy;
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

procedure Practice.SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
begin
  FCatalogue := AArrayOfCatalogueEntry;
  FCatalogue_Specified := True;
end;

function Practice.Catalogue_Specified(Index: Integer): boolean;
begin
  Result := FCatalogue_Specified;
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

procedure Practice.SetDomainName(Index: Integer; const AWideString: WideString);
begin
  FDomainName := AWideString;
  FDomainName_Specified := True;
end;

function Practice.DomainName_Specified(Index: Integer): boolean;
begin
  Result := FDomainName_Specified;
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

procedure Practice.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function Practice.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
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

procedure Practice.SetRoles(Index: Integer; const AArrayOfRole: ArrayOfRole);
begin
  FRoles := AArrayOfRole;
  FRoles_Specified := True;
end;

function Practice.Roles_Specified(Index: Integer): boolean;
begin
  Result := FRoles_Specified;
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

procedure Practice.SetUsers(Index: Integer; const AArrayOfUser: ArrayOfUser);
begin
  FUsers := AArrayOfUser;
  FUsers_Specified := True;
end;

function Practice.Users_Specified(Index: Integer): boolean;
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

procedure User.SetEMail(Index: Integer; const AWideString: WideString);
begin
  FEMail := AWideString;
  FEMail_Specified := True;
end;

function User.EMail_Specified(Index: Integer): boolean;
begin
  Result := FEMail_Specified;
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

procedure User.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function User.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure User.SetRoleIds(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FRoleIds := AArrayOfguid;
  FRoleIds_Specified := True;
end;

function User.RoleIds_Specified(Index: Integer): boolean;
begin
  Result := FRoleIds_Specified;
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

procedure ClientList.SetClients(Index: Integer; const AArrayOfClient: ArrayOfClient);
begin
  FClients := AArrayOfClient;
  FClients_Specified := True;
end;

function ClientList.Clients_Specified(Index: Integer): boolean;
begin
  Result := FClients_Specified;
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

procedure Client.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function Client.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure Client.SetStatus(Index: Integer; const AClientStatus: ClientStatus);
begin
  FStatus := AClientStatus;
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

initialization
  InvRegistry.RegisterInterface(TypeInfo(IBlopiServiceFacade), 'https://banklinkonline.com/2011/10/BLOPI', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IBlopiServiceFacade), 'https://banklinkonline.com/2011/10/BLOPI/IBlopiServiceFacade/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IBlopiServiceFacade), ioDocument);
  RemClassRegistry.RegisterXSInfo(TypeInfo(guid), 'http://schemas.microsoft.com/2003/10/Serialization/', 'guid');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfCatalogueEntry), 'https://banklinkonline.com/2011/10/BLOPI', 'ArrayOfCatalogueEntry');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfServiceErrorMessage), 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ArrayOfServiceErrorMessage');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfExceptionDetails), 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ArrayOfExceptionDetails');
  RemClassRegistry.RegisterXSClass(MessageResponse, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponse');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfCatalogueEntryn8pcGHF3, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfCatalogueEntryn8pcGHF3');
  RemClassRegistry.RegisterXSClass(ServiceErrorMessage, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ServiceErrorMessage');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ServiceErrorMessage), 'Message_', 'Message');
  RemClassRegistry.RegisterXSClass(ExceptionDetails, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ExceptionDetails');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ExceptionDetails), 'Message_', 'Message');
  RemClassRegistry.RegisterXSClass(MessageResponseOfPracticen8pcGHF3, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfPracticen8pcGHF3');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientListn8pcGHF3, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientListn8pcGHF3');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfCatalogueEntryn8pcGHF32, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfCatalogueEntryn8pcGHF32', 'MessageResponseOfArrayOfCatalogueEntryn8pcGHF3');
  RemClassRegistry.RegisterXSClass(MessageResponse2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponse2', 'MessageResponse');
  RemClassRegistry.RegisterXSClass(ServiceErrorMessage2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ServiceErrorMessage2', 'ServiceErrorMessage');
  RemClassRegistry.RegisterXSClass(ExceptionDetails2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ExceptionDetails2', 'ExceptionDetails');
  RemClassRegistry.RegisterXSClass(MessageResponseOfPracticen8pcGHF32, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfPracticen8pcGHF32', 'MessageResponseOfPracticen8pcGHF3');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientListn8pcGHF32, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientListn8pcGHF32', 'MessageResponseOfClientListn8pcGHF3');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfguid), 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'ArrayOfguid');
  RemClassRegistry.RegisterXSClass(CatalogueEntry, 'https://banklinkonline.com/2011/10/BLOPI', 'CatalogueEntry');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfRole), 'https://banklinkonline.com/2011/10/BLOPI', 'ArrayOfRole');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfUser), 'https://banklinkonline.com/2011/10/BLOPI', 'ArrayOfUser');
  RemClassRegistry.RegisterXSClass(Practice, 'https://banklinkonline.com/2011/10/BLOPI', 'Practice');
  RemClassRegistry.RegisterXSClass(Role, 'https://banklinkonline.com/2011/10/BLOPI', 'Role');
  RemClassRegistry.RegisterXSClass(User, 'https://banklinkonline.com/2011/10/BLOPI', 'User');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfClient), 'https://banklinkonline.com/2011/10/BLOPI', 'ArrayOfClient');
  RemClassRegistry.RegisterXSClass(ClientList, 'https://banklinkonline.com/2011/10/BLOPI', 'ClientList');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ClientStatus), 'https://banklinkonline.com/2011/10/BLOPI', 'ClientStatus');
  RemClassRegistry.RegisterXSClass(Client, 'https://banklinkonline.com/2011/10/BLOPI', 'Client');
  RemClassRegistry.RegisterXSClass(CatalogueEntry2, 'https://banklinkonline.com/2011/10/BLOPI', 'CatalogueEntry2', 'CatalogueEntry');
  RemClassRegistry.RegisterXSClass(Practice2, 'https://banklinkonline.com/2011/10/BLOPI', 'Practice2', 'Practice');
  RemClassRegistry.RegisterXSClass(Role2, 'https://banklinkonline.com/2011/10/BLOPI', 'Role2', 'Role');
  RemClassRegistry.RegisterXSClass(User2, 'https://banklinkonline.com/2011/10/BLOPI', 'User2', 'User');
  RemClassRegistry.RegisterXSClass(ClientList2, 'https://banklinkonline.com/2011/10/BLOPI', 'ClientList2', 'ClientList');
  RemClassRegistry.RegisterXSClass(Client2, 'https://banklinkonline.com/2011/10/BLOPI', 'Client2', 'Client');

end.