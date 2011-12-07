// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : https://banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl
//  >Import : https://banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl=wsdl0
//  >Import : https://banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl=wsdl0>0
//  >Import : https://banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd0
//  >Import : https://banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd1
//  >Import : https://banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd2
//  >Import : https://banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd3
// Encoding : utf-8
// Codegen  : [wfMapStringsToWideStrings+, wfUseScopedEnumeration-]
// Version  : 1.0
// (7/12/2011 11:57:10 a.m. - - $Rev: 25127 $)
// ************************************************************************ //

unit BlopiServiceFacade;

interface

uses InvokeRegistry, SOAPHTTPClient, Types, XSBuiltIns;

const
  IS_OPTN = $0001;


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
  MessageResponseOfArrayOfCatalogueEntryMIdCYrSK = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ServiceErrorMessage  = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  ExceptionDetails     = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfPracticeMIdCYrSK = class;    { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfguid = class;                { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfClientListMIdCYrSK = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfClientMIdCYrSK = class;      { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblCplx] }
  MessageResponseOfArrayOfCatalogueEntryMIdCYrSK2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponse2     = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  ServiceErrorMessage2 = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  ExceptionDetails2    = class;                 { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfPracticeMIdCYrSK2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfguid2 = class;               { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfClientListMIdCYrSK2 = class;   { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  MessageResponseOfClientMIdCYrSK2 = class;     { "http://schemas.datacontract.org/2004/07/BankLink.Common.Services"[GblElm] }
  CatalogueEntry       = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  Practice             = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  Role                 = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  User                 = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  NewUser              = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ClientList           = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ClientSummary        = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  Client               = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  NewClient            = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  Echo                 = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  EchoResponse         = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetPracticeCatalogue = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetPracticeCatalogueResponse = class;         { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  CatalogueEntry2      = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetSmeCatalogue      = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetSmeCatalogueResponse = class;              { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetUserCatalogue     = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetUserCatalogueResponse = class;             { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetPracticeDetail    = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetPracticeDetailResponse = class;            { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Practice2            = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Role2                = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  User2                = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  CreatePracticeUser   = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  NewUser2             = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  CreatePracticeUserResponse = class;           { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  SavePracticeUser     = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  SavePracticeUserResponse = class;             { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  DeletePracticeUser   = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  DeletePracticeUserResponse = class;           { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetClientList        = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetClientListResponse = class;                { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientList2          = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientSummary2       = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetClientDetail      = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  GetClientDetailResponse = class;              { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Client2              = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  CreateClient         = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  NewClient2           = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  CreateClientResponse = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  SaveClient           = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  SaveClientResponse   = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  CreateClientUser     = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  CreateClientUserResponse = class;             { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  SaveclientUser       = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  SaveclientUserResponse = class;               { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }

  { "http://www.banklinkonline.com/2011/11/Blopi"[GblSmpl] }
  ClientStatus = (Active, Suspended);

  guid            = WideString;      { "http://schemas.microsoft.com/2003/10/Serialization/"[GblSmpl] }
  ArrayOfCatalogueEntry = array of CatalogueEntry;   { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
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
    property ErrorMessages: ArrayOfServiceErrorMessage  Index (IS_OPTN) read FErrorMessages write SetErrorMessages stored ErrorMessages_Specified;
    property Exceptions:    ArrayOfExceptionDetails     Index (IS_OPTN) read FExceptions write SetExceptions stored Exceptions_Specified;
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
    property Result: ArrayOfCatalogueEntry  Index (IS_OPTN) read FResult write SetResult stored Result_Specified;
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
    property ErrorCode: WideString  Index (IS_OPTN) read FErrorCode write SetErrorCode stored ErrorCode_Specified;
    property Message_:  WideString  Index (IS_OPTN) read FMessage_ write SetMessage_ stored Message__Specified;
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
    property Message_:   WideString  Index (IS_OPTN) read FMessage_ write SetMessage_ stored Message__Specified;
    property Source:     WideString  Index (IS_OPTN) read FSource write SetSource stored Source_Specified;
    property StackTrace: WideString  Index (IS_OPTN) read FStackTrace write SetStackTrace stored StackTrace_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfPracticeMIdCYrSK, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfPracticeMIdCYrSK = class(MessageResponse)
  private
    FResult: Practice;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const APractice: Practice);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: Practice  Index (IS_OPTN) read FResult write SetResult stored Result_Specified;
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
    property Result: ClientList  Index (IS_OPTN) read FResult write SetResult stored Result_Specified;
  end;



  // ************************************************************************ //
  // XML       : MessageResponseOfClientMIdCYrSK, global, <complexType>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfClientMIdCYrSK = class(MessageResponse)
  private
    FResult: Client;
    FResult_Specified: boolean;
    procedure SetResult(Index: Integer; const AClient: Client);
    function  Result_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Result: Client  Index (IS_OPTN) read FResult write SetResult stored Result_Specified;
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
  // XML       : MessageResponseOfPracticeMIdCYrSK, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfPracticeMIdCYrSK2 = class(MessageResponseOfPracticeMIdCYrSK)
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
  // XML       : MessageResponseOfClientMIdCYrSK, global, <element>
  // Namespace : http://schemas.datacontract.org/2004/07/BankLink.Common.Services
  // ************************************************************************ //
  MessageResponseOfClientMIdCYrSK2 = class(MessageResponseOfClientMIdCYrSK)
  private
  published
  end;

  ArrayOfguid = array of guid;                  { "http://schemas.microsoft.com/2003/10/Serialization/Arrays"[GblCplx] }
  ArrayOfstring = array of WideString;          { "http://schemas.microsoft.com/2003/10/Serialization/Arrays"[GblCplx] }


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
    property CatalogueType: WideString  Index (IS_OPTN) read FCatalogueType write SetCatalogueType stored CatalogueType_Specified;
    property Description:   WideString  Index (IS_OPTN) read FDescription write SetDescription stored Description_Specified;
    property Id:            guid        Index (IS_OPTN) read FId write SetId stored Id_Specified;
  end;

  ArrayOfRole = array of Role;                  { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }
  ArrayOfUser = array of User;                  { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }


  // ************************************************************************ //
  // XML       : Practice, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
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
    property Catalogue:          ArrayOfCatalogueEntry  Index (IS_OPTN) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property DefaultAdminUserId: guid                   Index (IS_OPTN) read FDefaultAdminUserId write SetDefaultAdminUserId stored DefaultAdminUserId_Specified;
    property DisplayName:        WideString             Index (IS_OPTN) read FDisplayName write SetDisplayName stored DisplayName_Specified;
    property DomainName:         WideString             Index (IS_OPTN) read FDomainName write SetDomainName stored DomainName_Specified;
    property EMail:              WideString             Index (IS_OPTN) read FEMail write SetEMail stored EMail_Specified;
    property Id:                 guid                   Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Phone:              WideString             Index (IS_OPTN) read FPhone write SetPhone stored Phone_Specified;
    property Roles:              ArrayOfRole            Index (IS_OPTN) read FRoles write SetRoles stored Roles_Specified;
    property Subscription:       ArrayOfguid            Index (IS_OPTN) read FSubscription write SetSubscription stored Subscription_Specified;
    property Users:              ArrayOfUser            Index (IS_OPTN) read FUsers write SetUsers stored Users_Specified;
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
    property Description: WideString  Index (IS_OPTN) read FDescription write SetDescription stored Description_Specified;
    property Id:          guid        Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property RoleName:    WideString  Index (IS_OPTN) read FRoleName write SetRoleName stored RoleName_Specified;
  end;



  // ************************************************************************ //
  // XML       : User, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  User = class(TRemotable)
  private
    FEMail: WideString;
    FEMail_Specified: boolean;
    FFullName: WideString;
    FFullName_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    FRoleNames: ArrayOfstring;
    FRoleNames_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    FUserCode: WideString;
    FUserCode_Specified: boolean;
    procedure SetEMail(Index: Integer; const AWideString: WideString);
    function  EMail_Specified(Index: Integer): boolean;
    procedure SetFullName(Index: Integer; const AWideString: WideString);
    function  FullName_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetRoleNames(Index: Integer; const AArrayOfstring: ArrayOfstring);
    function  RoleNames_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
    procedure SetUserCode(Index: Integer; const AWideString: WideString);
    function  UserCode_Specified(Index: Integer): boolean;
  published
    property EMail:        WideString     Index (IS_OPTN) read FEMail write SetEMail stored EMail_Specified;
    property FullName:     WideString     Index (IS_OPTN) read FFullName write SetFullName stored FullName_Specified;
    property Id:           guid           Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property RoleNames:    ArrayOfstring  Index (IS_OPTN) read FRoleNames write SetRoleNames stored RoleNames_Specified;
    property Subscription: ArrayOfguid    Index (IS_OPTN) read FSubscription write SetSubscription stored Subscription_Specified;
    property UserCode:     WideString     Index (IS_OPTN) read FUserCode write SetUserCode stored UserCode_Specified;
  end;



  // ************************************************************************ //
  // XML       : NewUser, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  NewUser = class(TRemotable)
  private
    FEMail: WideString;
    FEMail_Specified: boolean;
    FFullName: WideString;
    FFullName_Specified: boolean;
    FRoleNames: ArrayOfstring;
    FRoleNames_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    FUserCode: WideString;
    FUserCode_Specified: boolean;
    procedure SetEMail(Index: Integer; const AWideString: WideString);
    function  EMail_Specified(Index: Integer): boolean;
    procedure SetFullName(Index: Integer; const AWideString: WideString);
    function  FullName_Specified(Index: Integer): boolean;
    procedure SetRoleNames(Index: Integer; const AArrayOfstring: ArrayOfstring);
    function  RoleNames_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
    procedure SetUserCode(Index: Integer; const AWideString: WideString);
    function  UserCode_Specified(Index: Integer): boolean;
  published
    property EMail:        WideString     Index (IS_OPTN) read FEMail write SetEMail stored EMail_Specified;
    property FullName:     WideString     Index (IS_OPTN) read FFullName write SetFullName stored FullName_Specified;
    property RoleNames:    ArrayOfstring  Index (IS_OPTN) read FRoleNames write SetRoleNames stored RoleNames_Specified;
    property Subscription: ArrayOfguid    Index (IS_OPTN) read FSubscription write SetSubscription stored Subscription_Specified;
    property UserCode:     WideString     Index (IS_OPTN) read FUserCode write SetUserCode stored UserCode_Specified;
  end;

  ArrayOfClientSummary = array of ClientSummary;   { "http://www.banklinkonline.com/2011/11/Blopi"[GblCplx] }


  // ************************************************************************ //
  // XML       : ClientList, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientList = class(TRemotable)
  private
    FCatalogue: ArrayOfCatalogueEntry;
    FCatalogue_Specified: boolean;
    FClients: ArrayOfClientSummary;
    FClients_Specified: boolean;
    procedure SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
    function  Catalogue_Specified(Index: Integer): boolean;
    procedure SetClients(Index: Integer; const AArrayOfClientSummary: ArrayOfClientSummary);
    function  Clients_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Catalogue: ArrayOfCatalogueEntry  Index (IS_OPTN) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property Clients:   ArrayOfClientSummary   Index (IS_OPTN) read FClients write SetClients stored Clients_Specified;
  end;



  // ************************************************************************ //
  // XML       : ClientSummary, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientSummary = class(TRemotable)
  private
    FClientCode: WideString;
    FClientCode_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    FName_: WideString;
    FName__Specified: boolean;
    FStatus: ClientStatus;
    FStatus_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    procedure SetClientCode(Index: Integer; const AWideString: WideString);
    function  ClientCode_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetName_(Index: Integer; const AWideString: WideString);
    function  Name__Specified(Index: Integer): boolean;
    procedure SetStatus(Index: Integer; const AClientStatus: ClientStatus);
    function  Status_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
  published
    property ClientCode:   WideString    Index (IS_OPTN) read FClientCode write SetClientCode stored ClientCode_Specified;
    property Id:           guid          Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Name_:        WideString    Index (IS_OPTN) read FName_ write SetName_ stored Name__Specified;
    property Status:       ClientStatus  Index (IS_OPTN) read FStatus write SetStatus stored Status_Specified;
    property Subscription: ArrayOfguid   Index (IS_OPTN) read FSubscription write SetSubscription stored Subscription_Specified;
  end;



  // ************************************************************************ //
  // XML       : Client, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  Client = class(TRemotable)
  private
    FCatalogue: ArrayOfCatalogueEntry;
    FCatalogue_Specified: boolean;
    FClientCode: WideString;
    FClientCode_Specified: boolean;
    FId: guid;
    FId_Specified: boolean;
    FName_: WideString;
    FName__Specified: boolean;
    FRoles: ArrayOfRole;
    FRoles_Specified: boolean;
    FStatus: ClientStatus;
    FStatus_Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    FUsers: ArrayOfUser;
    FUsers_Specified: boolean;
    procedure SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
    function  Catalogue_Specified(Index: Integer): boolean;
    procedure SetClientCode(Index: Integer; const AWideString: WideString);
    function  ClientCode_Specified(Index: Integer): boolean;
    procedure SetId(Index: Integer; const Aguid: guid);
    function  Id_Specified(Index: Integer): boolean;
    procedure SetName_(Index: Integer; const AWideString: WideString);
    function  Name__Specified(Index: Integer): boolean;
    procedure SetRoles(Index: Integer; const AArrayOfRole: ArrayOfRole);
    function  Roles_Specified(Index: Integer): boolean;
    procedure SetStatus(Index: Integer; const AClientStatus: ClientStatus);
    function  Status_Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
    procedure SetUsers(Index: Integer; const AArrayOfUser: ArrayOfUser);
    function  Users_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property Catalogue:    ArrayOfCatalogueEntry  Index (IS_OPTN) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property ClientCode:   WideString             Index (IS_OPTN) read FClientCode write SetClientCode stored ClientCode_Specified;
    property Id:           guid                   Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Name_:        WideString             Index (IS_OPTN) read FName_ write SetName_ stored Name__Specified;
    property Roles:        ArrayOfRole            Index (IS_OPTN) read FRoles write SetRoles stored Roles_Specified;
    property Status:       ClientStatus           Index (IS_OPTN) read FStatus write SetStatus stored Status_Specified;
    property Subscription: ArrayOfguid            Index (IS_OPTN) read FSubscription write SetSubscription stored Subscription_Specified;
    property Users:        ArrayOfUser            Index (IS_OPTN) read FUsers write SetUsers stored Users_Specified;
  end;



  // ************************************************************************ //
  // XML       : NewClient, global, <complexType>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  NewClient = class(TRemotable)
  private
    FClientCode: WideString;
    FClientCode_Specified: boolean;
    FName_: WideString;
    FName__Specified: boolean;
    FSubscription: ArrayOfguid;
    FSubscription_Specified: boolean;
    procedure SetClientCode(Index: Integer; const AWideString: WideString);
    function  ClientCode_Specified(Index: Integer): boolean;
    procedure SetName_(Index: Integer; const AWideString: WideString);
    function  Name__Specified(Index: Integer): boolean;
    procedure SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
    function  Subscription_Specified(Index: Integer): boolean;
  published
    property ClientCode:   WideString   Index (IS_OPTN) read FClientCode write SetClientCode stored ClientCode_Specified;
    property Name_:        WideString   Index (IS_OPTN) read FName_ write SetName_ stored Name__Specified;
    property Subscription: ArrayOfguid  Index (IS_OPTN) read FSubscription write SetSubscription stored Subscription_Specified;
  end;



  // ************************************************************************ //
  // XML       : Echo, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  Echo = class(TRemotable)
  private
    FaString: WideString;
    FaString_Specified: boolean;
    procedure SetaString(Index: Integer; const AWideString: WideString);
    function  aString_Specified(Index: Integer): boolean;
  published
    property aString: WideString  Index (IS_OPTN) read FaString write SetaString stored aString_Specified;
  end;



  // ************************************************************************ //
  // XML       : EchoResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  EchoResponse = class(TRemotable)
  private
    FEchoResult: WideString;
    FEchoResult_Specified: boolean;
    procedure SetEchoResult(Index: Integer; const AWideString: WideString);
    function  EchoResult_Specified(Index: Integer): boolean;
  published
    property EchoResult: WideString  Index (IS_OPTN) read FEchoResult write SetEchoResult stored EchoResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetPracticeCatalogue, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetPracticeCatalogue = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetPracticeCatalogueResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetPracticeCatalogueResponse = class(TRemotable)
  private
    FGetPracticeCatalogueResult: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK;
    FGetPracticeCatalogueResult_Specified: boolean;
    procedure SetGetPracticeCatalogueResult(Index: Integer; const AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK);
    function  GetPracticeCatalogueResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property GetPracticeCatalogueResult: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK  Index (IS_OPTN) read FGetPracticeCatalogueResult write SetGetPracticeCatalogueResult stored GetPracticeCatalogueResult_Specified;
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
  // XML       : GetSmeCatalogue, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetSmeCatalogue = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetSmeCatalogueResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetSmeCatalogueResponse = class(TRemotable)
  private
    FGetSmeCatalogueResult: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK;
    FGetSmeCatalogueResult_Specified: boolean;
    procedure SetGetSmeCatalogueResult(Index: Integer; const AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK);
    function  GetSmeCatalogueResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property GetSmeCatalogueResult: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK  Index (IS_OPTN) read FGetSmeCatalogueResult write SetGetSmeCatalogueResult stored GetSmeCatalogueResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetUserCatalogue, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetUserCatalogue = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FclientCode: WideString;
    FclientCode_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetclientCode(Index: Integer; const AWideString: WideString);
    function  clientCode_Specified(Index: Integer): boolean;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property clientCode:   WideString  Index (IS_OPTN) read FclientCode write SetclientCode stored clientCode_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetUserCatalogueResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetUserCatalogueResponse = class(TRemotable)
  private
    FGetUserCatalogueResult: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK;
    FGetUserCatalogueResult_Specified: boolean;
    procedure SetGetUserCatalogueResult(Index: Integer; const AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK);
    function  GetUserCatalogueResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property GetUserCatalogueResult: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK  Index (IS_OPTN) read FGetUserCatalogueResult write SetGetUserCatalogueResult stored GetUserCatalogueResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetPracticeDetail, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetPracticeDetail = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetPracticeDetailResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetPracticeDetailResponse = class(TRemotable)
  private
    FGetPracticeDetailResult: MessageResponseOfPracticeMIdCYrSK;
    FGetPracticeDetailResult_Specified: boolean;
    procedure SetGetPracticeDetailResult(Index: Integer; const AMessageResponseOfPracticeMIdCYrSK: MessageResponseOfPracticeMIdCYrSK);
    function  GetPracticeDetailResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property GetPracticeDetailResult: MessageResponseOfPracticeMIdCYrSK  Index (IS_OPTN) read FGetPracticeDetailResult write SetGetPracticeDetailResult stored GetPracticeDetailResult_Specified;
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
  // XML       : User, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  User2 = class(User)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : CreatePracticeUser, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  CreatePracticeUser = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    FnewUser: NewUser;
    FnewUser_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
    procedure SetnewUser(Index: Integer; const ANewUser: NewUser);
    function  newUser_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
    property newUser:      NewUser     Index (IS_OPTN) read FnewUser write SetnewUser stored newUser_Specified;
  end;



  // ************************************************************************ //
  // XML       : NewUser, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  NewUser2 = class(NewUser)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : CreatePracticeUserResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  CreatePracticeUserResponse = class(TRemotable)
  private
    FCreatePracticeUserResult: MessageResponseOfguid;
    FCreatePracticeUserResult_Specified: boolean;
    procedure SetCreatePracticeUserResult(Index: Integer; const AMessageResponseOfguid: MessageResponseOfguid);
    function  CreatePracticeUserResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property CreatePracticeUserResult: MessageResponseOfguid  Index (IS_OPTN) read FCreatePracticeUserResult write SetCreatePracticeUserResult stored CreatePracticeUserResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : SavePracticeUser, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  SavePracticeUser = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    Fuser: User;
    Fuser_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
    procedure Setuser(Index: Integer; const AUser: User);
    function  user_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
    property user:         User        Index (IS_OPTN) read Fuser write Setuser stored user_Specified;
  end;



  // ************************************************************************ //
  // XML       : SavePracticeUserResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  SavePracticeUserResponse = class(TRemotable)
  private
    FSavePracticeUserResult: MessageResponse;
    FSavePracticeUserResult_Specified: boolean;
    procedure SetSavePracticeUserResult(Index: Integer; const AMessageResponse: MessageResponse);
    function  SavePracticeUserResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property SavePracticeUserResult: MessageResponse  Index (IS_OPTN) read FSavePracticeUserResult write SetSavePracticeUserResult stored SavePracticeUserResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : DeletePracticeUser, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  DeletePracticeUser = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    FuserId: guid;
    FuserId_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
    procedure SetuserId(Index: Integer; const Aguid: guid);
    function  userId_Specified(Index: Integer): boolean;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
    property userId:       guid        Index (IS_OPTN) read FuserId write SetuserId stored userId_Specified;
  end;



  // ************************************************************************ //
  // XML       : DeletePracticeUserResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  DeletePracticeUserResponse = class(TRemotable)
  private
    FDeletePracticeUserResult: MessageResponse;
    FDeletePracticeUserResult_Specified: boolean;
    procedure SetDeletePracticeUserResult(Index: Integer; const AMessageResponse: MessageResponse);
    function  DeletePracticeUserResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property DeletePracticeUserResult: MessageResponse  Index (IS_OPTN) read FDeletePracticeUserResult write SetDeletePracticeUserResult stored DeletePracticeUserResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetClientList, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetClientList = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetClientListResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetClientListResponse = class(TRemotable)
  private
    FGetClientListResult: MessageResponseOfClientListMIdCYrSK;
    FGetClientListResult_Specified: boolean;
    procedure SetGetClientListResult(Index: Integer; const AMessageResponseOfClientListMIdCYrSK: MessageResponseOfClientListMIdCYrSK);
    function  GetClientListResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property GetClientListResult: MessageResponseOfClientListMIdCYrSK  Index (IS_OPTN) read FGetClientListResult write SetGetClientListResult stored GetClientListResult_Specified;
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
  // XML       : ClientSummary, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientSummary2 = class(ClientSummary)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : GetClientDetail, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetClientDetail = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    FclientId: guid;
    FclientId_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
    procedure SetclientId(Index: Integer; const Aguid: guid);
    function  clientId_Specified(Index: Integer): boolean;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
    property clientId:     guid        Index (IS_OPTN) read FclientId write SetclientId stored clientId_Specified;
  end;



  // ************************************************************************ //
  // XML       : GetClientDetailResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  GetClientDetailResponse = class(TRemotable)
  private
    FGetClientDetailResult: MessageResponseOfClientMIdCYrSK;
    FGetClientDetailResult_Specified: boolean;
    procedure SetGetClientDetailResult(Index: Integer; const AMessageResponseOfClientMIdCYrSK: MessageResponseOfClientMIdCYrSK);
    function  GetClientDetailResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property GetClientDetailResult: MessageResponseOfClientMIdCYrSK  Index (IS_OPTN) read FGetClientDetailResult write SetGetClientDetailResult stored GetClientDetailResult_Specified;
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
  // XML       : CreateClient, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  CreateClient = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    FnewClient: NewClient;
    FnewClient_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
    procedure SetnewClient(Index: Integer; const ANewClient: NewClient);
    function  newClient_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
    property newClient:    NewClient   Index (IS_OPTN) read FnewClient write SetnewClient stored newClient_Specified;
  end;



  // ************************************************************************ //
  // XML       : NewClient, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  NewClient2 = class(NewClient)
  private
  published
  end;



  // ************************************************************************ //
  // XML       : CreateClientResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  CreateClientResponse = class(TRemotable)
  private
    FCreateClientResult: MessageResponseOfguid;
    FCreateClientResult_Specified: boolean;
    procedure SetCreateClientResult(Index: Integer; const AMessageResponseOfguid: MessageResponseOfguid);
    function  CreateClientResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property CreateClientResult: MessageResponseOfguid  Index (IS_OPTN) read FCreateClientResult write SetCreateClientResult stored CreateClientResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : SaveClient, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  SaveClient = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    Fclient: ClientSummary;
    Fclient_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
    procedure Setclient(Index: Integer; const AClientSummary: ClientSummary);
    function  client_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property countryCode:  WideString     Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString     Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString     Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
    property client:       ClientSummary  Index (IS_OPTN) read Fclient write Setclient stored client_Specified;
  end;



  // ************************************************************************ //
  // XML       : SaveClientResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  SaveClientResponse = class(TRemotable)
  private
    FSaveClientResult: MessageResponse;
    FSaveClientResult_Specified: boolean;
    procedure SetSaveClientResult(Index: Integer; const AMessageResponse: MessageResponse);
    function  SaveClientResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property SaveClientResult: MessageResponse  Index (IS_OPTN) read FSaveClientResult write SetSaveClientResult stored SaveClientResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : CreateClientUser, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  CreateClientUser = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    FclientId: guid;
    FclientId_Specified: boolean;
    FnewUser: NewUser;
    FnewUser_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
    procedure SetclientId(Index: Integer; const Aguid: guid);
    function  clientId_Specified(Index: Integer): boolean;
    procedure SetnewUser(Index: Integer; const ANewUser: NewUser);
    function  newUser_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
    property clientId:     guid        Index (IS_OPTN) read FclientId write SetclientId stored clientId_Specified;
    property newUser:      NewUser     Index (IS_OPTN) read FnewUser write SetnewUser stored newUser_Specified;
  end;



  // ************************************************************************ //
  // XML       : CreateClientUserResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  CreateClientUserResponse = class(TRemotable)
  private
    FCreateClientUserResult: MessageResponseOfguid;
    FCreateClientUserResult_Specified: boolean;
    procedure SetCreateClientUserResult(Index: Integer; const AMessageResponseOfguid: MessageResponseOfguid);
    function  CreateClientUserResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property CreateClientUserResult: MessageResponseOfguid  Index (IS_OPTN) read FCreateClientUserResult write SetCreateClientUserResult stored CreateClientUserResult_Specified;
  end;



  // ************************************************************************ //
  // XML       : SaveclientUser, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  SaveclientUser = class(TRemotable)
  private
    FcountryCode: WideString;
    FcountryCode_Specified: boolean;
    FpracticeCode: WideString;
    FpracticeCode_Specified: boolean;
    FpasswordHash: WideString;
    FpasswordHash_Specified: boolean;
    FclientId: guid;
    FclientId_Specified: boolean;
    Fuser: User;
    Fuser_Specified: boolean;
    procedure SetcountryCode(Index: Integer; const AWideString: WideString);
    function  countryCode_Specified(Index: Integer): boolean;
    procedure SetpracticeCode(Index: Integer; const AWideString: WideString);
    function  practiceCode_Specified(Index: Integer): boolean;
    procedure SetpasswordHash(Index: Integer; const AWideString: WideString);
    function  passwordHash_Specified(Index: Integer): boolean;
    procedure SetclientId(Index: Integer; const Aguid: guid);
    function  clientId_Specified(Index: Integer): boolean;
    procedure Setuser(Index: Integer; const AUser: User);
    function  user_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property countryCode:  WideString  Index (IS_OPTN) read FcountryCode write SetcountryCode stored countryCode_Specified;
    property practiceCode: WideString  Index (IS_OPTN) read FpracticeCode write SetpracticeCode stored practiceCode_Specified;
    property passwordHash: WideString  Index (IS_OPTN) read FpasswordHash write SetpasswordHash stored passwordHash_Specified;
    property clientId:     guid        Index (IS_OPTN) read FclientId write SetclientId stored clientId_Specified;
    property user:         User        Index (IS_OPTN) read Fuser write Setuser stored user_Specified;
  end;



  // ************************************************************************ //
  // XML       : SaveclientUserResponse, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  SaveclientUserResponse = class(TRemotable)
  private
    FSaveclientUserResult: MessageResponse;
    FSaveclientUserResult_Specified: boolean;
    procedure SetSaveclientUserResult(Index: Integer; const AMessageResponse: MessageResponse);
    function  SaveclientUserResult_Specified(Index: Integer): boolean;
  public
    destructor Destroy; override;
  published
    property SaveclientUserResult: MessageResponse  Index (IS_OPTN) read FSaveclientUserResult write SetSaveclientUserResult stored SaveclientUserResult_Specified;
  end;


  // ************************************************************************ //
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  IBlopiServiceFacade = interface(IInvokable)
  ['{02DF8283-ABAB-2E33-9A44-1B850E27000A}']
    function  Echo(const parameters: Echo): EchoResponse; stdcall;
    function  GetPracticeCatalogue(const parameters: GetPracticeCatalogue): GetPracticeCatalogueResponse; stdcall;
    function  GetSmeCatalogue(const parameters: GetSmeCatalogue): GetSmeCatalogueResponse; stdcall;
    function  GetUserCatalogue(const parameters: GetUserCatalogue): GetUserCatalogueResponse; stdcall;
    function  GetPracticeDetail(const parameters: GetPracticeDetail): GetPracticeDetailResponse; stdcall;
    function  CreatePracticeUser(const parameters: CreatePracticeUser): CreatePracticeUserResponse; stdcall;
    function  SavePracticeUser(const parameters: SavePracticeUser): SavePracticeUserResponse; stdcall;
    function  DeletePracticeUser(const parameters: DeletePracticeUser): DeletePracticeUserResponse; stdcall;
    function  GetClientList(const parameters: GetClientList): GetClientListResponse; stdcall;
    function  GetClientDetail(const parameters: GetClientDetail): GetClientDetailResponse; stdcall;
    function  CreateClient(const parameters: CreateClient): CreateClientResponse; stdcall;
    function  SaveClient(const parameters: SaveClient): SaveClientResponse; stdcall;
    function  CreateClientUser(const parameters: CreateClientUser): CreateClientUserResponse; stdcall;
    function  SaveclientUser(const parameters: SaveclientUser): SaveclientUserResponse; stdcall;
  end;



implementation
  uses SysUtils;

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

destructor MessageResponseOfPracticeMIdCYrSK.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfPracticeMIdCYrSK.SetResult(Index: Integer; const APractice: Practice);
begin
  FResult := APractice;
  FResult_Specified := True;
end;

function MessageResponseOfPracticeMIdCYrSK.Result_Specified(Index: Integer): boolean;
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

destructor MessageResponseOfClientMIdCYrSK.Destroy;
begin
  SysUtils.FreeAndNil(FResult);
  inherited Destroy;
end;

procedure MessageResponseOfClientMIdCYrSK.SetResult(Index: Integer; const AClient: Client);
begin
  FResult := AClient;
  FResult_Specified := True;
end;

function MessageResponseOfClientMIdCYrSK.Result_Specified(Index: Integer): boolean;
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

procedure Role.SetRoleName(Index: Integer; const AWideString: WideString);
begin
  FRoleName := AWideString;
  FRoleName_Specified := True;
end;

function Role.RoleName_Specified(Index: Integer): boolean;
begin
  Result := FRoleName_Specified;
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

procedure NewUser.SetEMail(Index: Integer; const AWideString: WideString);
begin
  FEMail := AWideString;
  FEMail_Specified := True;
end;

function NewUser.EMail_Specified(Index: Integer): boolean;
begin
  Result := FEMail_Specified;
end;

procedure NewUser.SetFullName(Index: Integer; const AWideString: WideString);
begin
  FFullName := AWideString;
  FFullName_Specified := True;
end;

function NewUser.FullName_Specified(Index: Integer): boolean;
begin
  Result := FFullName_Specified;
end;

procedure NewUser.SetRoleNames(Index: Integer; const AArrayOfstring: ArrayOfstring);
begin
  FRoleNames := AArrayOfstring;
  FRoleNames_Specified := True;
end;

function NewUser.RoleNames_Specified(Index: Integer): boolean;
begin
  Result := FRoleNames_Specified;
end;

procedure NewUser.SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FSubscription := AArrayOfguid;
  FSubscription_Specified := True;
end;

function NewUser.Subscription_Specified(Index: Integer): boolean;
begin
  Result := FSubscription_Specified;
end;

procedure NewUser.SetUserCode(Index: Integer; const AWideString: WideString);
begin
  FUserCode := AWideString;
  FUserCode_Specified := True;
end;

function NewUser.UserCode_Specified(Index: Integer): boolean;
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

procedure ClientList.SetClients(Index: Integer; const AArrayOfClientSummary: ArrayOfClientSummary);
begin
  FClients := AArrayOfClientSummary;
  FClients_Specified := True;
end;

function ClientList.Clients_Specified(Index: Integer): boolean;
begin
  Result := FClients_Specified;
end;

procedure ClientSummary.SetClientCode(Index: Integer; const AWideString: WideString);
begin
  FClientCode := AWideString;
  FClientCode_Specified := True;
end;

function ClientSummary.ClientCode_Specified(Index: Integer): boolean;
begin
  Result := FClientCode_Specified;
end;

procedure ClientSummary.SetId(Index: Integer; const Aguid: guid);
begin
  FId := Aguid;
  FId_Specified := True;
end;

function ClientSummary.Id_Specified(Index: Integer): boolean;
begin
  Result := FId_Specified;
end;

procedure ClientSummary.SetName_(Index: Integer; const AWideString: WideString);
begin
  FName_ := AWideString;
  FName__Specified := True;
end;

function ClientSummary.Name__Specified(Index: Integer): boolean;
begin
  Result := FName__Specified;
end;

procedure ClientSummary.SetStatus(Index: Integer; const AClientStatus: ClientStatus);
begin
  FStatus := AClientStatus;
  FStatus_Specified := True;
end;

function ClientSummary.Status_Specified(Index: Integer): boolean;
begin
  Result := FStatus_Specified;
end;

procedure ClientSummary.SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FSubscription := AArrayOfguid;
  FSubscription_Specified := True;
end;

function ClientSummary.Subscription_Specified(Index: Integer): boolean;
begin
  Result := FSubscription_Specified;
end;

destructor Client.Destroy;
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

procedure Client.SetCatalogue(Index: Integer; const AArrayOfCatalogueEntry: ArrayOfCatalogueEntry);
begin
  FCatalogue := AArrayOfCatalogueEntry;
  FCatalogue_Specified := True;
end;

function Client.Catalogue_Specified(Index: Integer): boolean;
begin
  Result := FCatalogue_Specified;
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

procedure Client.SetName_(Index: Integer; const AWideString: WideString);
begin
  FName_ := AWideString;
  FName__Specified := True;
end;

function Client.Name__Specified(Index: Integer): boolean;
begin
  Result := FName__Specified;
end;

procedure Client.SetRoles(Index: Integer; const AArrayOfRole: ArrayOfRole);
begin
  FRoles := AArrayOfRole;
  FRoles_Specified := True;
end;

function Client.Roles_Specified(Index: Integer): boolean;
begin
  Result := FRoles_Specified;
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

procedure Client.SetUsers(Index: Integer; const AArrayOfUser: ArrayOfUser);
begin
  FUsers := AArrayOfUser;
  FUsers_Specified := True;
end;

function Client.Users_Specified(Index: Integer): boolean;
begin
  Result := FUsers_Specified;
end;

procedure NewClient.SetClientCode(Index: Integer; const AWideString: WideString);
begin
  FClientCode := AWideString;
  FClientCode_Specified := True;
end;

function NewClient.ClientCode_Specified(Index: Integer): boolean;
begin
  Result := FClientCode_Specified;
end;

procedure NewClient.SetName_(Index: Integer; const AWideString: WideString);
begin
  FName_ := AWideString;
  FName__Specified := True;
end;

function NewClient.Name__Specified(Index: Integer): boolean;
begin
  Result := FName__Specified;
end;

procedure NewClient.SetSubscription(Index: Integer; const AArrayOfguid: ArrayOfguid);
begin
  FSubscription := AArrayOfguid;
  FSubscription_Specified := True;
end;

function NewClient.Subscription_Specified(Index: Integer): boolean;
begin
  Result := FSubscription_Specified;
end;

procedure Echo.SetaString(Index: Integer; const AWideString: WideString);
begin
  FaString := AWideString;
  FaString_Specified := True;
end;

function Echo.aString_Specified(Index: Integer): boolean;
begin
  Result := FaString_Specified;
end;

procedure EchoResponse.SetEchoResult(Index: Integer; const AWideString: WideString);
begin
  FEchoResult := AWideString;
  FEchoResult_Specified := True;
end;

function EchoResponse.EchoResult_Specified(Index: Integer): boolean;
begin
  Result := FEchoResult_Specified;
end;

procedure GetPracticeCatalogue.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function GetPracticeCatalogue.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure GetPracticeCatalogue.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function GetPracticeCatalogue.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure GetPracticeCatalogue.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function GetPracticeCatalogue.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

destructor GetPracticeCatalogueResponse.Destroy;
begin
  SysUtils.FreeAndNil(FGetPracticeCatalogueResult);
  inherited Destroy;
end;

procedure GetPracticeCatalogueResponse.SetGetPracticeCatalogueResult(Index: Integer; const AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK);
begin
  FGetPracticeCatalogueResult := AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK;
  FGetPracticeCatalogueResult_Specified := True;
end;

function GetPracticeCatalogueResponse.GetPracticeCatalogueResult_Specified(Index: Integer): boolean;
begin
  Result := FGetPracticeCatalogueResult_Specified;
end;

procedure GetSmeCatalogue.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function GetSmeCatalogue.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure GetSmeCatalogue.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function GetSmeCatalogue.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

destructor GetSmeCatalogueResponse.Destroy;
begin
  SysUtils.FreeAndNil(FGetSmeCatalogueResult);
  inherited Destroy;
end;

procedure GetSmeCatalogueResponse.SetGetSmeCatalogueResult(Index: Integer; const AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK);
begin
  FGetSmeCatalogueResult := AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK;
  FGetSmeCatalogueResult_Specified := True;
end;

function GetSmeCatalogueResponse.GetSmeCatalogueResult_Specified(Index: Integer): boolean;
begin
  Result := FGetSmeCatalogueResult_Specified;
end;

procedure GetUserCatalogue.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function GetUserCatalogue.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure GetUserCatalogue.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function GetUserCatalogue.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure GetUserCatalogue.SetclientCode(Index: Integer; const AWideString: WideString);
begin
  FclientCode := AWideString;
  FclientCode_Specified := True;
end;

function GetUserCatalogue.clientCode_Specified(Index: Integer): boolean;
begin
  Result := FclientCode_Specified;
end;

destructor GetUserCatalogueResponse.Destroy;
begin
  SysUtils.FreeAndNil(FGetUserCatalogueResult);
  inherited Destroy;
end;

procedure GetUserCatalogueResponse.SetGetUserCatalogueResult(Index: Integer; const AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK: MessageResponseOfArrayOfCatalogueEntryMIdCYrSK);
begin
  FGetUserCatalogueResult := AMessageResponseOfArrayOfCatalogueEntryMIdCYrSK;
  FGetUserCatalogueResult_Specified := True;
end;

function GetUserCatalogueResponse.GetUserCatalogueResult_Specified(Index: Integer): boolean;
begin
  Result := FGetUserCatalogueResult_Specified;
end;

procedure GetPracticeDetail.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function GetPracticeDetail.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure GetPracticeDetail.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function GetPracticeDetail.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure GetPracticeDetail.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function GetPracticeDetail.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

destructor GetPracticeDetailResponse.Destroy;
begin
  SysUtils.FreeAndNil(FGetPracticeDetailResult);
  inherited Destroy;
end;

procedure GetPracticeDetailResponse.SetGetPracticeDetailResult(Index: Integer; const AMessageResponseOfPracticeMIdCYrSK: MessageResponseOfPracticeMIdCYrSK);
begin
  FGetPracticeDetailResult := AMessageResponseOfPracticeMIdCYrSK;
  FGetPracticeDetailResult_Specified := True;
end;

function GetPracticeDetailResponse.GetPracticeDetailResult_Specified(Index: Integer): boolean;
begin
  Result := FGetPracticeDetailResult_Specified;
end;

destructor CreatePracticeUser.Destroy;
begin
  SysUtils.FreeAndNil(FnewUser);
  inherited Destroy;
end;

procedure CreatePracticeUser.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function CreatePracticeUser.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure CreatePracticeUser.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function CreatePracticeUser.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure CreatePracticeUser.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function CreatePracticeUser.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

procedure CreatePracticeUser.SetnewUser(Index: Integer; const ANewUser: NewUser);
begin
  FnewUser := ANewUser;
  FnewUser_Specified := True;
end;

function CreatePracticeUser.newUser_Specified(Index: Integer): boolean;
begin
  Result := FnewUser_Specified;
end;

destructor CreatePracticeUserResponse.Destroy;
begin
  SysUtils.FreeAndNil(FCreatePracticeUserResult);
  inherited Destroy;
end;

procedure CreatePracticeUserResponse.SetCreatePracticeUserResult(Index: Integer; const AMessageResponseOfguid: MessageResponseOfguid);
begin
  FCreatePracticeUserResult := AMessageResponseOfguid;
  FCreatePracticeUserResult_Specified := True;
end;

function CreatePracticeUserResponse.CreatePracticeUserResult_Specified(Index: Integer): boolean;
begin
  Result := FCreatePracticeUserResult_Specified;
end;

destructor SavePracticeUser.Destroy;
begin
  SysUtils.FreeAndNil(Fuser);
  inherited Destroy;
end;

procedure SavePracticeUser.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function SavePracticeUser.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure SavePracticeUser.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function SavePracticeUser.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure SavePracticeUser.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function SavePracticeUser.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

procedure SavePracticeUser.Setuser(Index: Integer; const AUser: User);
begin
  Fuser := AUser;
  Fuser_Specified := True;
end;

function SavePracticeUser.user_Specified(Index: Integer): boolean;
begin
  Result := Fuser_Specified;
end;

destructor SavePracticeUserResponse.Destroy;
begin
  SysUtils.FreeAndNil(FSavePracticeUserResult);
  inherited Destroy;
end;

procedure SavePracticeUserResponse.SetSavePracticeUserResult(Index: Integer; const AMessageResponse: MessageResponse);
begin
  FSavePracticeUserResult := AMessageResponse;
  FSavePracticeUserResult_Specified := True;
end;

function SavePracticeUserResponse.SavePracticeUserResult_Specified(Index: Integer): boolean;
begin
  Result := FSavePracticeUserResult_Specified;
end;

procedure DeletePracticeUser.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function DeletePracticeUser.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure DeletePracticeUser.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function DeletePracticeUser.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure DeletePracticeUser.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function DeletePracticeUser.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

procedure DeletePracticeUser.SetuserId(Index: Integer; const Aguid: guid);
begin
  FuserId := Aguid;
  FuserId_Specified := True;
end;

function DeletePracticeUser.userId_Specified(Index: Integer): boolean;
begin
  Result := FuserId_Specified;
end;

destructor DeletePracticeUserResponse.Destroy;
begin
  SysUtils.FreeAndNil(FDeletePracticeUserResult);
  inherited Destroy;
end;

procedure DeletePracticeUserResponse.SetDeletePracticeUserResult(Index: Integer; const AMessageResponse: MessageResponse);
begin
  FDeletePracticeUserResult := AMessageResponse;
  FDeletePracticeUserResult_Specified := True;
end;

function DeletePracticeUserResponse.DeletePracticeUserResult_Specified(Index: Integer): boolean;
begin
  Result := FDeletePracticeUserResult_Specified;
end;

procedure GetClientList.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function GetClientList.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure GetClientList.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function GetClientList.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure GetClientList.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function GetClientList.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

destructor GetClientListResponse.Destroy;
begin
  SysUtils.FreeAndNil(FGetClientListResult);
  inherited Destroy;
end;

procedure GetClientListResponse.SetGetClientListResult(Index: Integer; const AMessageResponseOfClientListMIdCYrSK: MessageResponseOfClientListMIdCYrSK);
begin
  FGetClientListResult := AMessageResponseOfClientListMIdCYrSK;
  FGetClientListResult_Specified := True;
end;

function GetClientListResponse.GetClientListResult_Specified(Index: Integer): boolean;
begin
  Result := FGetClientListResult_Specified;
end;

procedure GetClientDetail.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function GetClientDetail.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure GetClientDetail.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function GetClientDetail.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure GetClientDetail.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function GetClientDetail.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

procedure GetClientDetail.SetclientId(Index: Integer; const Aguid: guid);
begin
  FclientId := Aguid;
  FclientId_Specified := True;
end;

function GetClientDetail.clientId_Specified(Index: Integer): boolean;
begin
  Result := FclientId_Specified;
end;

destructor GetClientDetailResponse.Destroy;
begin
  SysUtils.FreeAndNil(FGetClientDetailResult);
  inherited Destroy;
end;

procedure GetClientDetailResponse.SetGetClientDetailResult(Index: Integer; const AMessageResponseOfClientMIdCYrSK: MessageResponseOfClientMIdCYrSK);
begin
  FGetClientDetailResult := AMessageResponseOfClientMIdCYrSK;
  FGetClientDetailResult_Specified := True;
end;

function GetClientDetailResponse.GetClientDetailResult_Specified(Index: Integer): boolean;
begin
  Result := FGetClientDetailResult_Specified;
end;

destructor CreateClient.Destroy;
begin
  SysUtils.FreeAndNil(FnewClient);
  inherited Destroy;
end;

procedure CreateClient.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function CreateClient.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure CreateClient.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function CreateClient.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure CreateClient.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function CreateClient.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

procedure CreateClient.SetnewClient(Index: Integer; const ANewClient: NewClient);
begin
  FnewClient := ANewClient;
  FnewClient_Specified := True;
end;

function CreateClient.newClient_Specified(Index: Integer): boolean;
begin
  Result := FnewClient_Specified;
end;

destructor CreateClientResponse.Destroy;
begin
  SysUtils.FreeAndNil(FCreateClientResult);
  inherited Destroy;
end;

procedure CreateClientResponse.SetCreateClientResult(Index: Integer; const AMessageResponseOfguid: MessageResponseOfguid);
begin
  FCreateClientResult := AMessageResponseOfguid;
  FCreateClientResult_Specified := True;
end;

function CreateClientResponse.CreateClientResult_Specified(Index: Integer): boolean;
begin
  Result := FCreateClientResult_Specified;
end;

destructor SaveClient.Destroy;
begin
  SysUtils.FreeAndNil(Fclient);
  inherited Destroy;
end;

procedure SaveClient.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function SaveClient.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure SaveClient.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function SaveClient.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure SaveClient.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function SaveClient.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

procedure SaveClient.Setclient(Index: Integer; const AClientSummary: ClientSummary);
begin
  Fclient := AClientSummary;
  Fclient_Specified := True;
end;

function SaveClient.client_Specified(Index: Integer): boolean;
begin
  Result := Fclient_Specified;
end;

destructor SaveClientResponse.Destroy;
begin
  SysUtils.FreeAndNil(FSaveClientResult);
  inherited Destroy;
end;

procedure SaveClientResponse.SetSaveClientResult(Index: Integer; const AMessageResponse: MessageResponse);
begin
  FSaveClientResult := AMessageResponse;
  FSaveClientResult_Specified := True;
end;

function SaveClientResponse.SaveClientResult_Specified(Index: Integer): boolean;
begin
  Result := FSaveClientResult_Specified;
end;

destructor CreateClientUser.Destroy;
begin
  SysUtils.FreeAndNil(FnewUser);
  inherited Destroy;
end;

procedure CreateClientUser.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function CreateClientUser.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure CreateClientUser.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function CreateClientUser.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure CreateClientUser.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function CreateClientUser.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

procedure CreateClientUser.SetclientId(Index: Integer; const Aguid: guid);
begin
  FclientId := Aguid;
  FclientId_Specified := True;
end;

function CreateClientUser.clientId_Specified(Index: Integer): boolean;
begin
  Result := FclientId_Specified;
end;

procedure CreateClientUser.SetnewUser(Index: Integer; const ANewUser: NewUser);
begin
  FnewUser := ANewUser;
  FnewUser_Specified := True;
end;

function CreateClientUser.newUser_Specified(Index: Integer): boolean;
begin
  Result := FnewUser_Specified;
end;

destructor CreateClientUserResponse.Destroy;
begin
  SysUtils.FreeAndNil(FCreateClientUserResult);
  inherited Destroy;
end;

procedure CreateClientUserResponse.SetCreateClientUserResult(Index: Integer; const AMessageResponseOfguid: MessageResponseOfguid);
begin
  FCreateClientUserResult := AMessageResponseOfguid;
  FCreateClientUserResult_Specified := True;
end;

function CreateClientUserResponse.CreateClientUserResult_Specified(Index: Integer): boolean;
begin
  Result := FCreateClientUserResult_Specified;
end;

destructor SaveclientUser.Destroy;
begin
  SysUtils.FreeAndNil(Fuser);
  inherited Destroy;
end;

procedure SaveclientUser.SetcountryCode(Index: Integer; const AWideString: WideString);
begin
  FcountryCode := AWideString;
  FcountryCode_Specified := True;
end;

function SaveclientUser.countryCode_Specified(Index: Integer): boolean;
begin
  Result := FcountryCode_Specified;
end;

procedure SaveclientUser.SetpracticeCode(Index: Integer; const AWideString: WideString);
begin
  FpracticeCode := AWideString;
  FpracticeCode_Specified := True;
end;

function SaveclientUser.practiceCode_Specified(Index: Integer): boolean;
begin
  Result := FpracticeCode_Specified;
end;

procedure SaveclientUser.SetpasswordHash(Index: Integer; const AWideString: WideString);
begin
  FpasswordHash := AWideString;
  FpasswordHash_Specified := True;
end;

function SaveclientUser.passwordHash_Specified(Index: Integer): boolean;
begin
  Result := FpasswordHash_Specified;
end;

procedure SaveclientUser.SetclientId(Index: Integer; const Aguid: guid);
begin
  FclientId := Aguid;
  FclientId_Specified := True;
end;

function SaveclientUser.clientId_Specified(Index: Integer): boolean;
begin
  Result := FclientId_Specified;
end;

procedure SaveclientUser.Setuser(Index: Integer; const AUser: User);
begin
  Fuser := AUser;
  Fuser_Specified := True;
end;

function SaveclientUser.user_Specified(Index: Integer): boolean;
begin
  Result := Fuser_Specified;
end;

destructor SaveclientUserResponse.Destroy;
begin
  SysUtils.FreeAndNil(FSaveclientUserResult);
  inherited Destroy;
end;

procedure SaveclientUserResponse.SetSaveclientUserResult(Index: Integer; const AMessageResponse: MessageResponse);
begin
  FSaveclientUserResult := AMessageResponse;
  FSaveclientUserResult_Specified := True;
end;

function SaveclientUserResponse.SaveclientUserResult_Specified(Index: Integer): boolean;
begin
  Result := FSaveclientUserResult_Specified;
end;

initialization
  InvRegistry.RegisterInterface(TypeInfo(IBlopiServiceFacade), 'http://www.banklinkonline.com/2011/11/Blopi', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IBlopiServiceFacade), '');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'Echo', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'GetPracticeCatalogue', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'GetSmeCatalogue', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'GetUserCatalogue', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'GetPracticeDetail', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'CreatePracticeUser', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'SavePracticeUser', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'DeletePracticeUser', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'GetClientList', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'GetClientDetail', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'CreateClient', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'SaveClient', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'CreateClientUser', 'parameters1', 'parameters');
  InvRegistry.RegisterExternalParamName(TypeInfo(IBlopiServiceFacade), 'SaveclientUser', 'parameters1', 'parameters');
  RemClassRegistry.RegisterXSInfo(TypeInfo(guid), 'http://schemas.microsoft.com/2003/10/Serialization/', 'guid');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfCatalogueEntry), 'http://www.banklinkonline.com/2011/11/Blopi', 'ArrayOfCatalogueEntry');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfServiceErrorMessage), 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ArrayOfServiceErrorMessage');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfExceptionDetails), 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ArrayOfExceptionDetails');
  RemClassRegistry.RegisterXSClass(MessageResponse, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponse');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfCatalogueEntryMIdCYrSK, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfCatalogueEntryMIdCYrSK');
  RemClassRegistry.RegisterXSClass(ServiceErrorMessage, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ServiceErrorMessage');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ServiceErrorMessage), 'Message_', 'Message');
  RemClassRegistry.RegisterXSClass(ExceptionDetails, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ExceptionDetails');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ExceptionDetails), 'Message_', 'Message');
  RemClassRegistry.RegisterXSClass(MessageResponseOfPracticeMIdCYrSK, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfPracticeMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfguid, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfguid');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientListMIdCYrSK, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientListMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientMIdCYrSK, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfArrayOfCatalogueEntryMIdCYrSK2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfArrayOfCatalogueEntryMIdCYrSK2', 'MessageResponseOfArrayOfCatalogueEntryMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponse2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponse2', 'MessageResponse');
  RemClassRegistry.RegisterXSClass(ServiceErrorMessage2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ServiceErrorMessage2', 'ServiceErrorMessage');
  RemClassRegistry.RegisterXSClass(ExceptionDetails2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'ExceptionDetails2', 'ExceptionDetails');
  RemClassRegistry.RegisterXSClass(MessageResponseOfPracticeMIdCYrSK2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfPracticeMIdCYrSK2', 'MessageResponseOfPracticeMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfguid2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfguid2', 'MessageResponseOfguid');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientListMIdCYrSK2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientListMIdCYrSK2', 'MessageResponseOfClientListMIdCYrSK');
  RemClassRegistry.RegisterXSClass(MessageResponseOfClientMIdCYrSK2, 'http://schemas.datacontract.org/2004/07/BankLink.Common.Services', 'MessageResponseOfClientMIdCYrSK2', 'MessageResponseOfClientMIdCYrSK');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfguid), 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'ArrayOfguid');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfstring), 'http://schemas.microsoft.com/2003/10/Serialization/Arrays', 'ArrayOfstring');
  RemClassRegistry.RegisterXSClass(CatalogueEntry, 'http://www.banklinkonline.com/2011/11/Blopi', 'CatalogueEntry');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfRole), 'http://www.banklinkonline.com/2011/11/Blopi', 'ArrayOfRole');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfUser), 'http://www.banklinkonline.com/2011/11/Blopi', 'ArrayOfUser');
  RemClassRegistry.RegisterXSClass(Practice, 'http://www.banklinkonline.com/2011/11/Blopi', 'Practice');
  RemClassRegistry.RegisterXSClass(Role, 'http://www.banklinkonline.com/2011/11/Blopi', 'Role');
  RemClassRegistry.RegisterXSClass(User, 'http://www.banklinkonline.com/2011/11/Blopi', 'User');
  RemClassRegistry.RegisterXSClass(NewUser, 'http://www.banklinkonline.com/2011/11/Blopi', 'NewUser');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ArrayOfClientSummary), 'http://www.banklinkonline.com/2011/11/Blopi', 'ArrayOfClientSummary');
  RemClassRegistry.RegisterXSClass(ClientList, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientList');
  RemClassRegistry.RegisterXSInfo(TypeInfo(ClientStatus), 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientStatus');
  RemClassRegistry.RegisterXSClass(ClientSummary, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientSummary');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(ClientSummary), 'Name_', 'Name');
  RemClassRegistry.RegisterXSClass(Client, 'http://www.banklinkonline.com/2011/11/Blopi', 'Client');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(Client), 'Name_', 'Name');
  RemClassRegistry.RegisterXSClass(NewClient, 'http://www.banklinkonline.com/2011/11/Blopi', 'NewClient');
  RemClassRegistry.RegisterExternalPropName(TypeInfo(NewClient), 'Name_', 'Name');
  RemClassRegistry.RegisterXSClass(Echo, 'http://www.banklinkonline.com/2011/11/Blopi', 'Echo');
  RemClassRegistry.RegisterXSClass(EchoResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'EchoResponse');
  RemClassRegistry.RegisterXSClass(GetPracticeCatalogue, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetPracticeCatalogue');
  RemClassRegistry.RegisterXSClass(GetPracticeCatalogueResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetPracticeCatalogueResponse');
  RemClassRegistry.RegisterXSClass(CatalogueEntry2, 'http://www.banklinkonline.com/2011/11/Blopi', 'CatalogueEntry2', 'CatalogueEntry');
  RemClassRegistry.RegisterXSClass(GetSmeCatalogue, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetSmeCatalogue');
  RemClassRegistry.RegisterXSClass(GetSmeCatalogueResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetSmeCatalogueResponse');
  RemClassRegistry.RegisterXSClass(GetUserCatalogue, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetUserCatalogue');
  RemClassRegistry.RegisterXSClass(GetUserCatalogueResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetUserCatalogueResponse');
  RemClassRegistry.RegisterXSClass(GetPracticeDetail, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetPracticeDetail');
  RemClassRegistry.RegisterXSClass(GetPracticeDetailResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetPracticeDetailResponse');
  RemClassRegistry.RegisterXSClass(Practice2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Practice2', 'Practice');
  RemClassRegistry.RegisterXSClass(Role2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Role2', 'Role');
  RemClassRegistry.RegisterXSClass(User2, 'http://www.banklinkonline.com/2011/11/Blopi', 'User2', 'User');
  RemClassRegistry.RegisterXSClass(CreatePracticeUser, 'http://www.banklinkonline.com/2011/11/Blopi', 'CreatePracticeUser');
  RemClassRegistry.RegisterXSClass(NewUser2, 'http://www.banklinkonline.com/2011/11/Blopi', 'NewUser2', 'NewUser');
  RemClassRegistry.RegisterXSClass(CreatePracticeUserResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'CreatePracticeUserResponse');
  RemClassRegistry.RegisterXSClass(SavePracticeUser, 'http://www.banklinkonline.com/2011/11/Blopi', 'SavePracticeUser');
  RemClassRegistry.RegisterXSClass(SavePracticeUserResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'SavePracticeUserResponse');
  RemClassRegistry.RegisterXSClass(DeletePracticeUser, 'http://www.banklinkonline.com/2011/11/Blopi', 'DeletePracticeUser');
  RemClassRegistry.RegisterXSClass(DeletePracticeUserResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'DeletePracticeUserResponse');
  RemClassRegistry.RegisterXSClass(GetClientList, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetClientList');
  RemClassRegistry.RegisterXSClass(GetClientListResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetClientListResponse');
  RemClassRegistry.RegisterXSClass(ClientList2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientList2', 'ClientList');
  RemClassRegistry.RegisterXSClass(ClientSummary2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientSummary2', 'ClientSummary');
  RemClassRegistry.RegisterXSClass(GetClientDetail, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetClientDetail');
  RemClassRegistry.RegisterXSClass(GetClientDetailResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'GetClientDetailResponse');
  RemClassRegistry.RegisterXSClass(Client2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Client2', 'Client');
  RemClassRegistry.RegisterXSClass(CreateClient, 'http://www.banklinkonline.com/2011/11/Blopi', 'CreateClient');
  RemClassRegistry.RegisterXSClass(NewClient2, 'http://www.banklinkonline.com/2011/11/Blopi', 'NewClient2', 'NewClient');
  RemClassRegistry.RegisterXSClass(CreateClientResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'CreateClientResponse');
  RemClassRegistry.RegisterXSClass(SaveClient, 'http://www.banklinkonline.com/2011/11/Blopi', 'SaveClient');
  RemClassRegistry.RegisterXSClass(SaveClientResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'SaveClientResponse');
  RemClassRegistry.RegisterXSClass(CreateClientUser, 'http://www.banklinkonline.com/2011/11/Blopi', 'CreateClientUser');
  RemClassRegistry.RegisterXSClass(CreateClientUserResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'CreateClientUserResponse');
  RemClassRegistry.RegisterXSClass(SaveclientUser, 'http://www.banklinkonline.com/2011/11/Blopi', 'SaveclientUser');
  RemClassRegistry.RegisterXSClass(SaveclientUserResponse, 'http://www.banklinkonline.com/2011/11/Blopi', 'SaveclientUserResponse');

end.