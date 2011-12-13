// ************************************************************************ //
// The types declared in this file were generated from data read from the
// WSDL File described below:
// WSDL     : http://banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl
//  >Import : http://banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl=wsdl0
//  >Import : http://banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl=wsdl0>0
//  >Import : http://banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd0
//  >Import : http://banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd1
//  >Import : http://banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd2
//  >Import : http://banklinkonline.com/Services/BlopiServiceFacade.svc?xsd=xsd3
// Encoding : utf-8
// Codegen  : [wfMapStringsToWideStrings+, wfUseScopedEnumeration-]
// Version  : 1.0
// (14/12/2011 10:55:57 a.m. - - $Rev: 25127 $)
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
  CatalogueEntry2      = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Practice2            = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Role2                = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  User2                = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  NewUser2             = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientList2          = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  ClientSummary2       = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  Client2              = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }
  NewClient2           = class;                 { "http://www.banklinkonline.com/2011/11/Blopi"[GblElm] }

  { "http://www.banklinkonline.com/2011/11/Blopi"[GblSmpl] }
  ClientStatus = (Active, Suspended);

  guid            =  type WideString;      { "http://schemas.microsoft.com/2003/10/Serialization/"[GblSmpl] }
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
    property Result: Practice  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
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
    property Result: Client  Index (IS_OPTN or IS_NLBL) read FResult write SetResult stored Result_Specified;
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
    property CatalogueType: WideString  Index (IS_OPTN or IS_NLBL) read FCatalogueType write SetCatalogueType stored CatalogueType_Specified;
    property Description:   WideString  Index (IS_OPTN or IS_NLBL) read FDescription write SetDescription stored Description_Specified;
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
    property EMail:        WideString     Index (IS_OPTN or IS_NLBL) read FEMail write SetEMail stored EMail_Specified;
    property FullName:     WideString     Index (IS_OPTN or IS_NLBL) read FFullName write SetFullName stored FullName_Specified;
    property Id:           guid           Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property RoleNames:    ArrayOfstring  Index (IS_OPTN or IS_NLBL) read FRoleNames write SetRoleNames stored RoleNames_Specified;
    property Subscription: ArrayOfguid    Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
    property UserCode:     WideString     Index (IS_OPTN or IS_NLBL) read FUserCode write SetUserCode stored UserCode_Specified;
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
    property EMail:        WideString     Index (IS_OPTN or IS_NLBL) read FEMail write SetEMail stored EMail_Specified;
    property FullName:     WideString     Index (IS_OPTN or IS_NLBL) read FFullName write SetFullName stored FullName_Specified;
    property RoleNames:    ArrayOfstring  Index (IS_OPTN or IS_NLBL) read FRoleNames write SetRoleNames stored RoleNames_Specified;
    property Subscription: ArrayOfguid    Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
    property UserCode:     WideString     Index (IS_OPTN or IS_NLBL) read FUserCode write SetUserCode stored UserCode_Specified;
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
    property Catalogue: ArrayOfCatalogueEntry  Index (IS_OPTN or IS_NLBL) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property Clients:   ArrayOfClientSummary   Index (IS_OPTN or IS_NLBL) read FClients write SetClients stored Clients_Specified;
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
    property ClientCode:   WideString    Index (IS_OPTN or IS_NLBL) read FClientCode write SetClientCode stored ClientCode_Specified;
    property Id:           guid          Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Name_:        WideString    Index (IS_OPTN or IS_NLBL) read FName_ write SetName_ stored Name__Specified;
    property Status:       ClientStatus  Index (IS_OPTN) read FStatus write SetStatus stored Status_Specified;
    property Subscription: ArrayOfguid   Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
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
    property Catalogue:    ArrayOfCatalogueEntry  Index (IS_OPTN or IS_NLBL) read FCatalogue write SetCatalogue stored Catalogue_Specified;
    property ClientCode:   WideString             Index (IS_OPTN or IS_NLBL) read FClientCode write SetClientCode stored ClientCode_Specified;
    property Id:           guid                   Index (IS_OPTN) read FId write SetId stored Id_Specified;
    property Name_:        WideString             Index (IS_OPTN or IS_NLBL) read FName_ write SetName_ stored Name__Specified;
    property Roles:        ArrayOfRole            Index (IS_OPTN or IS_NLBL) read FRoles write SetRoles stored Roles_Specified;
    property Status:       ClientStatus           Index (IS_OPTN) read FStatus write SetStatus stored Status_Specified;
    property Subscription: ArrayOfguid            Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
    property Users:        ArrayOfUser            Index (IS_OPTN or IS_NLBL) read FUsers write SetUsers stored Users_Specified;
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
    property ClientCode:   WideString   Index (IS_OPTN or IS_NLBL) read FClientCode write SetClientCode stored ClientCode_Specified;
    property Name_:        WideString   Index (IS_OPTN or IS_NLBL) read FName_ write SetName_ stored Name__Specified;
    property Subscription: ArrayOfguid  Index (IS_OPTN or IS_NLBL) read FSubscription write SetSubscription stored Subscription_Specified;
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
  // XML       : NewUser, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  NewUser2 = class(NewUser)
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
  // XML       : ClientSummary, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  ClientSummary2 = class(ClientSummary)
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
  // XML       : NewClient, global, <element>
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // ************************************************************************ //
  NewClient2 = class(NewClient)
  private
  published
  end;


  // ************************************************************************ //
  // Namespace : http://www.banklinkonline.com/2011/11/Blopi
  // soapAction: http://www.banklinkonline.com/2011/11/Blopi/IBlopiServiceFacade/%operationName%
  // transport : http://schemas.xmlsoap.org/soap/http
  // style     : document
  // binding   : BasicHttpBinding_IBlopiServiceFacade
  // service   : BlopiServiceFacade
  // port      : BasicHttpBinding_IBlopiServiceFacade
  // URL       : http://banklinkonline.com/Services/BlopiServiceFacade.svc
  // ************************************************************************ //
  IBlopiServiceFacade = interface(IInvokable)
  ['{88E4B606-483E-CC24-1C42-418E3CD2E07E}']
    function  Echo(const aString: WideString): WideString; stdcall;
    function  GetPracticeCatalogue(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfArrayOfCatalogueEntryMIdCYrSK; stdcall;
    function  GetSmeCatalogue(const countryCode: WideString; const practiceCode: WideString): MessageResponseOfArrayOfCatalogueEntryMIdCYrSK; stdcall;
    function  GetUserCatalogue(const countryCode: WideString; const practiceCode: WideString; const clientCode: WideString): MessageResponseOfArrayOfCatalogueEntryMIdCYrSK; stdcall;
    function  GetPracticeDetail(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfPracticeMIdCYrSK; stdcall;
    function  CreatePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const newUser: NewUser): MessageResponseOfguid; stdcall;
    function  SavePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const user: User): MessageResponse; stdcall;
    function  DeletePracticeUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const userId: guid): MessageResponse; stdcall;
    function  GetClientList(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString): MessageResponseOfClientListMIdCYrSK; stdcall;
    function  GetClientDetail(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid): MessageResponseOfClientMIdCYrSK; stdcall;
    function  CreateClient(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const newClient: NewClient): MessageResponseOfguid; stdcall;
    function  SaveClient(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const client: ClientSummary): MessageResponse; stdcall;
    function  CreateClientUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; const newUser: NewUser): MessageResponseOfguid; stdcall;
    function  SaveclientUser(const countryCode: WideString; const practiceCode: WideString; const passwordHash: WideString; const clientId: guid; const user: User): MessageResponse; stdcall;
  end;

function GetIBlopiServiceFacade(UseWSDL: Boolean=System.False; Addr: string=''; HTTPRIO: THTTPRIO = nil): IBlopiServiceFacade;


implementation
  uses SysUtils;

function GetIBlopiServiceFacade(UseWSDL: Boolean; Addr: string; HTTPRIO: THTTPRIO): IBlopiServiceFacade;
const
  defWSDL = 'http://banklinkonline.com/Services/BlopiServiceFacade.svc?wsdl';
  defURL  = 'http://banklinkonline.com/Services/BlopiServiceFacade.svc';
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

initialization
  InvRegistry.RegisterInterface(TypeInfo(IBlopiServiceFacade), 'http://www.banklinkonline.com/2011/11/Blopi', 'utf-8');
  InvRegistry.RegisterDefaultSOAPAction(TypeInfo(IBlopiServiceFacade), 'http://www.banklinkonline.com/2011/11/Blopi/IBlopiServiceFacade/%operationName%');
  InvRegistry.RegisterInvokeOptions(TypeInfo(IBlopiServiceFacade), ioDocument);
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
  RemClassRegistry.RegisterXSClass(CatalogueEntry2, 'http://www.banklinkonline.com/2011/11/Blopi', 'CatalogueEntry2', 'CatalogueEntry');
  RemClassRegistry.RegisterXSClass(Practice2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Practice2', 'Practice');
  RemClassRegistry.RegisterXSClass(Role2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Role2', 'Role');
  RemClassRegistry.RegisterXSClass(User2, 'http://www.banklinkonline.com/2011/11/Blopi', 'User2', 'User');
  RemClassRegistry.RegisterXSClass(NewUser2, 'http://www.banklinkonline.com/2011/11/Blopi', 'NewUser2', 'NewUser');
  RemClassRegistry.RegisterXSClass(ClientList2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientList2', 'ClientList');
  RemClassRegistry.RegisterXSClass(ClientSummary2, 'http://www.banklinkonline.com/2011/11/Blopi', 'ClientSummary2', 'ClientSummary');
  RemClassRegistry.RegisterXSClass(Client2, 'http://www.banklinkonline.com/2011/11/Blopi', 'Client2', 'Client');
  RemClassRegistry.RegisterXSClass(NewClient2, 'http://www.banklinkonline.com/2011/11/Blopi', 'NewClient2', 'NewClient');

end.