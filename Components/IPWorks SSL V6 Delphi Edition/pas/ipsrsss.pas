
unit ipsrsss;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipsrsssAuthSchemes = 
(

									 
                   authBasic,

									 
                   authDigest
);
  TipsrsssFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipsrsssFollowRedirects = 
(

									 
                   frNever,

									 
                   frAlways,

									 
                   frSameScheme
);
  TipsrsssRSSVersions = 
(

									 
                   rssVersionUndefined,

									 
                   rssVersion091,

									 
                   rssVersion092,

									 
                   rssVersion200
);
  TipsrsssSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);


  TConnectedEvent = procedure(Sender: TObject;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TConnectionStatusEvent = procedure(Sender: TObject;
                            const ConnectionEvent: String;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TDisconnectedEvent = procedure(Sender: TObject;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TEndTransferEvent = procedure(Sender: TObject) of Object;

  TErrorEvent = procedure(Sender: TObject;
                            ErrorCode: Integer;
                            const Description: String) of Object;

  THeaderEvent = procedure(Sender: TObject;
                            const Field: String;
                            const Value: String) of Object;

  TRedirectEvent = procedure(Sender: TObject;
                            const Location: String;
                           var  Accept: Boolean) of Object;

  TSetCookieEvent = procedure(Sender: TObject;
                            const Name: String;
                            const Value: String;
                            const Expires: String;
                            const Domain: String;
                            const Path: String;
                            Secure: Boolean) of Object;

  TSSLServerAuthenticationEvent = procedure(Sender: TObject;
                            CertEncoded: String;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const Status: String;
                           var  Accept: Boolean) of Object;
{$IFDEF CLR}
  TSSLServerAuthenticationEventB = procedure(Sender: TObject;
                            CertEncoded: Array of Byte;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const Status: String;
                           var  Accept: Boolean) of Object;

{$ENDIF}
  TSSLStatusEvent = procedure(Sender: TObject;
                            const Message: String) of Object;

  TStartTransferEvent = procedure(Sender: TObject) of Object;

  TStatusEvent = procedure(Sender: TObject;
                            const HTTPVersion: String;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TTransferEvent = procedure(Sender: TObject;
                            BytesTransferred: LongInt;
                            Text: String) of Object;
{$IFDEF CLR}
  TTransferEventB = procedure(Sender: TObject;
                            BytesTransferred: LongInt;
                            Text: Array of Byte) of Object;

{$ENDIF}

{$IFDEF CLR}
  TRSSSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsRSSS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsRSSS = class(TipsCore)
    public
      FOnConnected: TConnectedEvent;

      FOnConnectionStatus: TConnectionStatusEvent;

      FOnDisconnected: TDisconnectedEvent;

      FOnEndTransfer: TEndTransferEvent;

      FOnError: TErrorEvent;

      FOnHeader: THeaderEvent;

      FOnRedirect: TRedirectEvent;

      FOnSetCookie: TSetCookieEvent;

      FOnSSLServerAuthentication: TSSLServerAuthenticationEvent;
			{$IFDEF CLR}FOnSSLServerAuthenticationB: TSSLServerAuthenticationEventB;{$ENDIF}
      FOnSSLStatus: TSSLStatusEvent;

      FOnStartTransfer: TStartTransferEvent;

      FOnStatus: TStatusEvent;

      FOnTransfer: TTransferEvent;
			{$IFDEF CLR}FOnTransferB: TTransferEventB;{$ENDIF}

    private
      tmp_RedirectAccept: Boolean;
      tmp_SSLServerAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TRSSSEventHook;
			function EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
			                   params: IntPtr; cbparam: IntPtr): integer;
{$ELSE}
      m_ctl: Pointer;
{$ENDIF}
      
      function HasData: Boolean;
      procedure ReadHnd(Reader: TStream);
      procedure WriteHnd(Writer: TStream);

      procedure SetOK(key: String128);
      function GetOK: String128;

    protected
      procedure AboutDlg; override;
      procedure DefineProperties(Filer: TFiler); override;

      function ThrowCoreException(Err: integer; const Desc: string): EIPWorksSSL; override;

{$IFDEF LINUX}
      procedure OnSocketNotify(Socket: Integer);
{$ENDIF}

{$IFDEF CLR}
		public
{$ENDIF}

      function get_ChannelCategoryDomain: String;
      procedure set_ChannelCategoryDomain(valChannelCategoryDomain: String);

      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);

      function get_ItemAuthor(ItemIndex: Word): String;
      procedure set_ItemAuthor(ItemIndex: Word; valItemAuthor: String);

      function get_ItemCategory(ItemIndex: Word): String;
      procedure set_ItemCategory(ItemIndex: Word; valItemCategory: String);

      function get_ItemCategoryDomain(ItemIndex: Word): String;
      procedure set_ItemCategoryDomain(ItemIndex: Word; valItemCategoryDomain: String);

      function get_ItemComments(ItemIndex: Word): String;
      procedure set_ItemComments(ItemIndex: Word; valItemComments: String);

      function get_ItemCount: Integer;
      procedure set_ItemCount(valItemCount: Integer);

      function get_ItemDescription(ItemIndex: Word): String;
      procedure set_ItemDescription(ItemIndex: Word; valItemDescription: String);

      function get_ItemGuid(ItemIndex: Word): String;
      procedure set_ItemGuid(ItemIndex: Word; valItemGuid: String);

      function get_ItemLink(ItemIndex: Word): String;
      procedure set_ItemLink(ItemIndex: Word; valItemLink: String);

      function get_ItemPubDate(ItemIndex: Word): String;
      procedure set_ItemPubDate(ItemIndex: Word; valItemPubDate: String);

      function get_ItemSource(ItemIndex: Word): String;
      procedure set_ItemSource(ItemIndex: Word; valItemSource: String);

      function get_ItemSourceURL(ItemIndex: Word): String;
      procedure set_ItemSourceURL(ItemIndex: Word; valItemSourceURL: String);

      function get_ItemTitle(ItemIndex: Word): String;
      procedure set_ItemTitle(ItemIndex: Word; valItemTitle: String);

      function get_NamespaceCount: Integer;
      procedure set_NamespaceCount(valNamespaceCount: Integer);

      function get_NamespacePrefixes(NamespaceIndex: Word): String;
      procedure set_NamespacePrefixes(NamespaceIndex: Word; valNamespacePrefixes: String);

      function get_Namespaces(NamespaceIndex: Word): String;
      procedure set_Namespaces(NamespaceIndex: Word; valNamespaces: String);

      function get_RSSData: String;


      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);


      procedure TreatErr(Err: integer; const desc: string);


      function get_Accept: String;
      procedure set_Accept(valAccept: String);

      function get_AuthScheme: TipsrsssAuthSchemes;
      procedure set_AuthScheme(valAuthScheme: TipsrsssAuthSchemes);

      function get_ChannelCategory: String;
      procedure set_ChannelCategory(valChannelCategory: String);



      function get_ChannelCopyright: String;
      procedure set_ChannelCopyright(valChannelCopyright: String);

      function get_ChannelDescription: String;
      procedure set_ChannelDescription(valChannelDescription: String);

      function get_ChannelDocs: String;
      procedure set_ChannelDocs(valChannelDocs: String);

      function get_ChannelLanguage: String;
      procedure set_ChannelLanguage(valChannelLanguage: String);

      function get_ChannelLastBuildDate: String;
      procedure set_ChannelLastBuildDate(valChannelLastBuildDate: String);

      function get_ChannelLink: String;
      procedure set_ChannelLink(valChannelLink: String);

      function get_ChannelManagingEditor: String;
      procedure set_ChannelManagingEditor(valChannelManagingEditor: String);

      function get_ChannelPubDate: String;
      procedure set_ChannelPubDate(valChannelPubDate: String);

      function get_ChannelTitle: String;
      procedure set_ChannelTitle(valChannelTitle: String);

      function get_ChannelWebMaster: String;
      procedure set_ChannelWebMaster(valChannelWebMaster: String);



      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipsrsssFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipsrsssFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_FollowRedirects: TipsrsssFollowRedirects;
      procedure set_FollowRedirects(valFollowRedirects: TipsrsssFollowRedirects);

      function get_Idle: Boolean;


      function get_ImageLink: String;
      procedure set_ImageLink(valImageLink: String);

      function get_ImageTitle: String;
      procedure set_ImageTitle(valImageTitle: String);

      function get_ImageURL: String;
      procedure set_ImageURL(valImageURL: String);































      function get_Password: String;
      procedure set_Password(valPassword: String);



      function get_RSSVersion: TipsrsssRSSVersions;
      procedure set_RSSVersion(valRSSVersion: TipsrsssRSSVersions);

      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipsrsssSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipsrsssSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_TextInputDescription: String;
      procedure set_TextInputDescription(valTextInputDescription: String);

      function get_TextInputLink: String;
      procedure set_TextInputLink(valTextInputLink: String);

      function get_TextInputName: String;
      procedure set_TextInputName(valTextInputName: String);

      function get_TextInputTitle: String;
      procedure set_TextInputTitle(valTextInputTitle: String);

      function get_Timeout: Integer;
      procedure set_Timeout(valTimeout: Integer);

      function get_User: String;
      procedure set_User(valUser: String);



    public

      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      property OK: String128 read GetOK write SetOK;

{$IFNDEF CLR}
      procedure SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
      procedure SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
      procedure SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
      procedure SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);

{$ENDIF}







      property ChannelCategoryDomain: String
               read get_ChannelCategoryDomain
               write set_ChannelCategoryDomain               ;





















      property Connected: Boolean
               read get_Connected
               write set_Connected               ;





















      property ItemAuthor[ItemIndex: Word]: String
               read get_ItemAuthor
               write set_ItemAuthor               ;

      property ItemCategory[ItemIndex: Word]: String
               read get_ItemCategory
               write set_ItemCategory               ;

      property ItemCategoryDomain[ItemIndex: Word]: String
               read get_ItemCategoryDomain
               write set_ItemCategoryDomain               ;

      property ItemComments[ItemIndex: Word]: String
               read get_ItemComments
               write set_ItemComments               ;

      property ItemCount: Integer
               read get_ItemCount
               write set_ItemCount               ;

      property ItemDescription[ItemIndex: Word]: String
               read get_ItemDescription
               write set_ItemDescription               ;

      property ItemGuid[ItemIndex: Word]: String
               read get_ItemGuid
               write set_ItemGuid               ;

      property ItemLink[ItemIndex: Word]: String
               read get_ItemLink
               write set_ItemLink               ;

      property ItemPubDate[ItemIndex: Word]: String
               read get_ItemPubDate
               write set_ItemPubDate               ;

      property ItemSource[ItemIndex: Word]: String
               read get_ItemSource
               write set_ItemSource               ;

      property ItemSourceURL[ItemIndex: Word]: String
               read get_ItemSourceURL
               write set_ItemSourceURL               ;

      property ItemTitle[ItemIndex: Word]: String
               read get_ItemTitle
               write set_ItemTitle               ;

      property NamespaceCount: Integer
               read get_NamespaceCount
               write set_NamespaceCount               ;

      property NamespacePrefixes[NamespaceIndex: Word]: String
               read get_NamespacePrefixes
               write set_NamespacePrefixes               ;

      property Namespaces[NamespaceIndex: Word]: String
               read get_Namespaces
               write set_Namespaces               ;



      property RSSData: String
               read get_RSSData
               ;





      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;



























{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure AddItem(Title: String; Description: String; Link: String);

      procedure AddNamespace(Prefix: String; NamespaceURI: String);

      procedure GetFeed(URL: String);

      function GetProperty(PropertyName: String): String;
      procedure GetURL(URL: String);

      procedure Put(URL: String);

      procedure ReadFile(FileName: String);

      procedure Reset();

      procedure SetProperty(PropertyName: String; PropertyValue: String);

      procedure WriteFile(Filename: String);


{$ENDIF}

    published

      property Accept: String
                   read get_Accept
                   write set_Accept
                   
                   ;
      property AuthScheme: TipsrsssAuthSchemes
                   read get_AuthScheme
                   write set_AuthScheme
                   default authBasic
                   ;
      property ChannelCategory: String
                   read get_ChannelCategory
                   write set_ChannelCategory
                   
                   ;

      property ChannelCopyright: String
                   read get_ChannelCopyright
                   write set_ChannelCopyright
                   
                   ;
      property ChannelDescription: String
                   read get_ChannelDescription
                   write set_ChannelDescription
                   
                   ;
      property ChannelDocs: String
                   read get_ChannelDocs
                   write set_ChannelDocs
                   
                   ;
      property ChannelLanguage: String
                   read get_ChannelLanguage
                   write set_ChannelLanguage
                   
                   ;
      property ChannelLastBuildDate: String
                   read get_ChannelLastBuildDate
                   write set_ChannelLastBuildDate
                   
                   ;
      property ChannelLink: String
                   read get_ChannelLink
                   write set_ChannelLink
                   
                   ;
      property ChannelManagingEditor: String
                   read get_ChannelManagingEditor
                   write set_ChannelManagingEditor
                   
                   ;
      property ChannelPubDate: String
                   read get_ChannelPubDate
                   write set_ChannelPubDate
                   
                   ;
      property ChannelTitle: String
                   read get_ChannelTitle
                   write set_ChannelTitle
                   
                   ;
      property ChannelWebMaster: String
                   read get_ChannelWebMaster
                   write set_ChannelWebMaster
                   
                   ;

      property FirewallHost: String
                   read get_FirewallHost
                   write set_FirewallHost
                   
                   ;
      property FirewallPassword: String
                   read get_FirewallPassword
                   write set_FirewallPassword
                   
                   ;
      property FirewallPort: Integer
                   read get_FirewallPort
                   write set_FirewallPort
                   default 0
                   ;
      property FirewallType: TipsrsssFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property FollowRedirects: TipsrsssFollowRedirects
                   read get_FollowRedirects
                   write set_FollowRedirects
                   default frNever
                   ;
      property Idle: Boolean
                   read get_Idle
                    write SetNoopBoolean
                   stored False

                   ;
      property ImageLink: String
                   read get_ImageLink
                   write set_ImageLink
                   
                   ;
      property ImageTitle: String
                   read get_ImageTitle
                   write set_ImageTitle
                   
                   ;
      property ImageURL: String
                   read get_ImageURL
                   write set_ImageURL
                   
                   ;















      property Password: String
                   read get_Password
                   write set_Password
                   
                   ;

      property RSSVersion: TipsrsssRSSVersions
                   read get_RSSVersion
                   write set_RSSVersion
                   default rssVersion200
                   ;
      property SSLAcceptServerCert: String
                   read get_SSLAcceptServerCert
                   write set_StringSSLAcceptServerCert
                   stored False

                   ;

      property SSLCertStore: String
                   read get_SSLCertStore
                   write set_StringSSLCertStore
                   
                   ;
      property SSLCertStorePassword: String
                   read get_SSLCertStorePassword
                   write set_SSLCertStorePassword
                   
                   ;
      property SSLCertStoreType: TipsrsssSSLCertStoreTypes
                   read get_SSLCertStoreType
                   write set_SSLCertStoreType
                   default sstUser
                   ;
      property SSLCertSubject: String
                   read get_SSLCertSubject
                   write set_SSLCertSubject
                   
                   ;
      property SSLServerCert: String
                   read get_SSLServerCert
                    write SetNoopString
                   stored False

                   ;
      property SSLServerCertStatus: String
                   read get_SSLServerCertStatus
                    write SetNoopString
                   stored False

                   ;
      property TextInputDescription: String
                   read get_TextInputDescription
                   write set_TextInputDescription
                   
                   ;
      property TextInputLink: String
                   read get_TextInputLink
                   write set_TextInputLink
                   
                   ;
      property TextInputName: String
                   read get_TextInputName
                   write set_TextInputName
                   
                   ;
      property TextInputTitle: String
                   read get_TextInputTitle
                   write set_TextInputTitle
                   
                   ;
      property Timeout: Integer
                   read get_Timeout
                   write set_Timeout
                   default 60
                   ;
      property User: String
                   read get_User
                   write set_User
                   
                   ;


      property OnConnected: TConnectedEvent read FOnConnected write FOnConnected;

      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnDisconnected: TDisconnectedEvent read FOnDisconnected write FOnDisconnected;

      property OnEndTransfer: TEndTransferEvent read FOnEndTransfer write FOnEndTransfer;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnHeader: THeaderEvent read FOnHeader write FOnHeader;

      property OnRedirect: TRedirectEvent read FOnRedirect write FOnRedirect;

      property OnSetCookie: TSetCookieEvent read FOnSetCookie write FOnSetCookie;

      property OnSSLServerAuthentication: TSSLServerAuthenticationEvent read FOnSSLServerAuthentication write FOnSSLServerAuthentication;
			{$IFDEF CLR}property OnSSLServerAuthenticationB: TSSLServerAuthenticationEventB read FOnSSLServerAuthenticationB write FOnSSLServerAuthenticationB;{$ENDIF}
      property OnSSLStatus: TSSLStatusEvent read FOnSSLStatus write FOnSSLStatus;

      property OnStartTransfer: TStartTransferEvent read FOnStartTransfer write FOnStartTransfer;

      property OnStatus: TStatusEvent read FOnStatus write FOnStatus;

      property OnTransfer: TTransferEvent read FOnTransfer write FOnTransfer;
			{$IFDEF CLR}property OnTransferB: TTransferEventB read FOnTransferB write FOnTransferB;{$ENDIF}

    end;

    procedure Register;

implementation

{$T-}

{$IFDEF LINUX}
uses QForms, Libc, Qt, QDialogs;
{$ELSE}
{$IFNDEF CLR}
uses Windows, WinTypes, WinProcs, Messages, Forms, Dialogs;  
{$ENDIF}
{$ENDIF}

const
    PID_RSSS_Accept = 1;
    PID_RSSS_AuthScheme = 2;
    PID_RSSS_ChannelCategory = 3;
    PID_RSSS_ChannelCategoryDomain = 4;
    PID_RSSS_ChannelCopyright = 5;
    PID_RSSS_ChannelDescription = 6;
    PID_RSSS_ChannelDocs = 7;
    PID_RSSS_ChannelLanguage = 8;
    PID_RSSS_ChannelLastBuildDate = 9;
    PID_RSSS_ChannelLink = 10;
    PID_RSSS_ChannelManagingEditor = 11;
    PID_RSSS_ChannelPubDate = 12;
    PID_RSSS_ChannelTitle = 13;
    PID_RSSS_ChannelWebMaster = 14;
    PID_RSSS_Connected = 15;
    PID_RSSS_FirewallHost = 16;
    PID_RSSS_FirewallPassword = 17;
    PID_RSSS_FirewallPort = 18;
    PID_RSSS_FirewallType = 19;
    PID_RSSS_FirewallUser = 20;
    PID_RSSS_FollowRedirects = 21;
    PID_RSSS_Idle = 22;
    PID_RSSS_ImageLink = 23;
    PID_RSSS_ImageTitle = 24;
    PID_RSSS_ImageURL = 25;
    PID_RSSS_ItemAuthor = 26;
    PID_RSSS_ItemCategory = 27;
    PID_RSSS_ItemCategoryDomain = 28;
    PID_RSSS_ItemComments = 29;
    PID_RSSS_ItemCount = 30;
    PID_RSSS_ItemDescription = 31;
    PID_RSSS_ItemGuid = 32;
    PID_RSSS_ItemLink = 33;
    PID_RSSS_ItemPubDate = 34;
    PID_RSSS_ItemSource = 35;
    PID_RSSS_ItemSourceURL = 36;
    PID_RSSS_ItemTitle = 37;
    PID_RSSS_NamespaceCount = 38;
    PID_RSSS_NamespacePrefixes = 39;
    PID_RSSS_Namespaces = 40;
    PID_RSSS_Password = 41;
    PID_RSSS_RSSData = 42;
    PID_RSSS_RSSVersion = 43;
    PID_RSSS_SSLAcceptServerCert = 44;
    PID_RSSS_SSLCertEncoded = 45;
    PID_RSSS_SSLCertStore = 46;
    PID_RSSS_SSLCertStorePassword = 47;
    PID_RSSS_SSLCertStoreType = 48;
    PID_RSSS_SSLCertSubject = 49;
    PID_RSSS_SSLServerCert = 50;
    PID_RSSS_SSLServerCertStatus = 51;
    PID_RSSS_TextInputDescription = 52;
    PID_RSSS_TextInputLink = 53;
    PID_RSSS_TextInputName = 54;
    PID_RSSS_TextInputTitle = 55;
    PID_RSSS_Timeout = 56;
    PID_RSSS_User = 57;

    EID_RSSS_Connected = 1;
    EID_RSSS_ConnectionStatus = 2;
    EID_RSSS_Disconnected = 3;
    EID_RSSS_EndTransfer = 4;
    EID_RSSS_Error = 5;
    EID_RSSS_Header = 6;
    EID_RSSS_Redirect = 7;
    EID_RSSS_SetCookie = 8;
    EID_RSSS_SSLServerAuthentication = 9;
    EID_RSSS_SSLStatus = 10;
    EID_RSSS_StartTransfer = 11;
    EID_RSSS_Status = 12;
    EID_RSSS_Transfer = 13;


    MID_RSSS_Config = 1;
    MID_RSSS_AddItem = 2;
    MID_RSSS_AddNamespace = 3;
    MID_RSSS_GetFeed = 4;
    MID_RSSS_GetProperty = 5;
    MID_RSSS_GetURL = 6;
    MID_RSSS_Put = 7;
    MID_RSSS_ReadFile = 8;
    MID_RSSS_Reset = 9;
    MID_RSSS_SetProperty = 10;
    MID_RSSS_WriteFile = 11;




{$IFDEF CLR}
{$DEFINE USEIPWORKSSSLDLL}

{$ENDIF}

{$IFDEF LINUX}
  {$DEFINE USEIPWORKSSSLDLL}
  DLLNAME = 'libipworksssl.so.6';
{$ELSE}
  DLLNAME = 'IPWSSL6.DLL';
{$ENDIF}



{$IFNDEF USEIPWORKSSSLDLL}
{$R 'ipsrsss.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsRSSS; event_id: Integer; cparam: Integer; 
                           params: LPVOIDARR; cbparam: LPINTARR): integer;
                           {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  PEventHandle = ^MEventHandle;
{$ENDIF}


{$IFNDEF CLR}
var
  pEntryPoint: Pointer;
  pBaseAddress: Pointer;
{$ENDIF}


{$IFNDEF USEIPWORKSSSLDLL}
  _RSSS_Create:        function(pMethod: PEventHandle; pObject: TipsRSSS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _RSSS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _RSSS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _RSSS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _RSSS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _RSSS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _RSSS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _RSSS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Create')]
  function _RSSS_Create       (pMethod: TRSSSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Destroy')]
  function _RSSS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Set')]
  function _RSSS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Set')]
  function _RSSS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Set')]
  function _RSSS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Set')]
  function _RSSS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Set')]
  function _RSSS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Set')]
  function _RSSS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Get')]
  function _RSSS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Get')]
  function _RSSS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Get')]
  function _RSSS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Get')]
  function _RSSS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Get')]
  function _RSSS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Get')]
  function _RSSS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_GetLastError')]
  function _RSSS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_StaticInit')]
  function _RSSS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_CheckIndex')]
  function _RSSS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'RSSS_Do')]
  function _RSSS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _RSSS_Create       (pMethod: PEventHandle; pObject: TipsRSSS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'RSSS_Create';
  function _RSSS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'RSSS_Destroy';
  function _RSSS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'RSSS_Set';
  function _RSSS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'RSSS_Get';
  function _RSSS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'RSSS_GetLastError';
  function _RSSS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'RSSS_StaticInit';
  function _RSSS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'RSSS_CheckIndex';
  function _RSSS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'RSSS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsRSSS; event_id: Integer;
                    cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): Integer;
                    {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  var
    x: Integer;
{$IFDEF LINUX}
    msg: String;
    tmp_IdleNextWait: Integer;
    tmp_NotifyObject: TipwSocketNotifier;
{$ENDIF}
    tmp_ConnectedStatusCode: Integer;
    tmp_ConnectedDescription: String;
    tmp_ConnectionStatusConnectionEvent: String;
    tmp_ConnectionStatusStatusCode: Integer;
    tmp_ConnectionStatusDescription: String;
    tmp_DisconnectedStatusCode: Integer;
    tmp_DisconnectedDescription: String;
    tmp_ErrorErrorCode: Integer;
    tmp_ErrorDescription: String;
    tmp_HeaderField: String;
    tmp_HeaderValue: String;
    tmp_RedirectLocation: String;
    tmp_SetCookieName: String;
    tmp_SetCookieValue: String;
    tmp_SetCookieExpires: String;
    tmp_SetCookieDomain: String;
    tmp_SetCookiePath: String;
    tmp_SetCookieSecure: Boolean;
    tmp_SSLServerAuthenticationCertEncoded: String;
    tmp_SSLServerAuthenticationCertSubject: String;
    tmp_SSLServerAuthenticationCertIssuer: String;
    tmp_SSLServerAuthenticationStatus: String;
    tmp_SSLStatusMessage: String;
    tmp_StatusHTTPVersion: String;
    tmp_StatusStatusCode: Integer;
    tmp_StatusDescription: String;
    tmp_TransferBytesTransferred: LongInt;
    tmp_TransferText: String;

  begin
    case event_id of

{$IFDEF LINUX}      
      2000:  {EID_IDLE}
      begin
        tmp_IdleNextWait := Integer(params^[0]);
        if Application.Terminated then
          tmp_IdleNextWait := -1;
        Application.ProcessMessages;
        params^[0] := Pointer(tmp_IdleNextWait);
      end;

      2001:  {EID_ASYNCSELECT}
      begin
        tmp_NotifyObject := TipwSocketNotifier.Create(TSocket(params^[0]), Integer(params^[1]), lpContext.OnSocketNotify);
        params^[2] := Pointer(tmp_NotifyObject);
      end;

      2002:  {EID_DELETENOTIFYOBJECT}
      begin
        tmp_NotifyObject := TipwSocketNotifier(params^[0]);
        tmp_NotifyObject.Free;
      end;
{$ENDIF}

      EID_RSSS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_RSSS_ConnectionStatus:
      begin
        if Assigned(lpContext.FOnConnectionStatus) then
        begin
          {assign temporary variables}
          tmp_ConnectionStatusConnectionEvent := AnsiString(PChar(params^[0]));

          tmp_ConnectionStatusStatusCode := Integer(params^[1]);
          tmp_ConnectionStatusDescription := AnsiString(PChar(params^[2]));


          lpContext.FOnConnectionStatus(lpContext, tmp_ConnectionStatusConnectionEvent, tmp_ConnectionStatusStatusCode, tmp_ConnectionStatusDescription);




        end;
      end;
      EID_RSSS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_RSSS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_RSSS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_RSSS_Header:
      begin
        if Assigned(lpContext.FOnHeader) then
        begin
          {assign temporary variables}
          tmp_HeaderField := AnsiString(PChar(params^[0]));

          tmp_HeaderValue := AnsiString(PChar(params^[1]));


          lpContext.FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



        end;
      end;
      EID_RSSS_Redirect:
      begin
        if Assigned(lpContext.FOnRedirect) then
        begin
          {assign temporary variables}
          tmp_RedirectLocation := AnsiString(PChar(params^[0]));

          lpContext.tmp_RedirectAccept := Boolean(params^[1]);

          lpContext.FOnRedirect(lpContext, tmp_RedirectLocation, lpContext.tmp_RedirectAccept);

          params^[1] := Pointer(lpContext.tmp_RedirectAccept);


        end;
      end;
      EID_RSSS_SetCookie:
      begin
        if Assigned(lpContext.FOnSetCookie) then
        begin
          {assign temporary variables}
          tmp_SetCookieName := AnsiString(PChar(params^[0]));

          tmp_SetCookieValue := AnsiString(PChar(params^[1]));

          tmp_SetCookieExpires := AnsiString(PChar(params^[2]));

          tmp_SetCookieDomain := AnsiString(PChar(params^[3]));

          tmp_SetCookiePath := AnsiString(PChar(params^[4]));

          tmp_SetCookieSecure := Boolean(params^[5]);

          lpContext.FOnSetCookie(lpContext, tmp_SetCookieName, tmp_SetCookieValue, tmp_SetCookieExpires, tmp_SetCookieDomain, tmp_SetCookiePath, tmp_SetCookieSecure);







        end;
      end;
      EID_RSSS_SSLServerAuthentication:
      begin
        if Assigned(lpContext.FOnSSLServerAuthentication) then
        begin
          {assign temporary variables}
          SetString(tmp_SSLServerAuthenticationCertEncoded, PChar(params^[0]), cbparam^[0]);

          tmp_SSLServerAuthenticationCertSubject := AnsiString(PChar(params^[1]));

          tmp_SSLServerAuthenticationCertIssuer := AnsiString(PChar(params^[2]));

          tmp_SSLServerAuthenticationStatus := AnsiString(PChar(params^[3]));

          lpContext.tmp_SSLServerAuthenticationAccept := Boolean(params^[4]);

          lpContext.FOnSSLServerAuthentication(lpContext, tmp_SSLServerAuthenticationCertEncoded, tmp_SSLServerAuthenticationCertSubject, tmp_SSLServerAuthenticationCertIssuer, tmp_SSLServerAuthenticationStatus, lpContext.tmp_SSLServerAuthenticationAccept);




          params^[4] := Pointer(lpContext.tmp_SSLServerAuthenticationAccept);


        end;
      end;
      EID_RSSS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_RSSS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_RSSS_Status:
      begin
        if Assigned(lpContext.FOnStatus) then
        begin
          {assign temporary variables}
          tmp_StatusHTTPVersion := AnsiString(PChar(params^[0]));

          tmp_StatusStatusCode := Integer(params^[1]);
          tmp_StatusDescription := AnsiString(PChar(params^[2]));


          lpContext.FOnStatus(lpContext, tmp_StatusHTTPVersion, tmp_StatusStatusCode, tmp_StatusDescription);




        end;
      end;
      EID_RSSS_Transfer:
      begin
        if Assigned(lpContext.FOnTransfer) then
        begin
          {assign temporary variables}
          tmp_TransferBytesTransferred := LongInt(params^[0]);
          SetString(tmp_TransferText, PChar(params^[1]), cbparam^[1]);


          lpContext.FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText);



        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsRSSS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectedStatusCode: Integer;
  tmp_ConnectedDescription: String;

  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;

  tmp_DisconnectedStatusCode: Integer;
  tmp_DisconnectedDescription: String;


  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_HeaderField: String;
  tmp_HeaderValue: String;

  tmp_RedirectLocation: String;

  tmp_SetCookieName: String;
  tmp_SetCookieValue: String;
  tmp_SetCookieExpires: String;
  tmp_SetCookieDomain: String;
  tmp_SetCookiePath: String;
  tmp_SetCookieSecure: Boolean;

  tmp_SSLServerAuthenticationCertEncoded: String;
  tmp_SSLServerAuthenticationCertSubject: String;
  tmp_SSLServerAuthenticationCertIssuer: String;
  tmp_SSLServerAuthenticationStatus: String;

  tmp_SSLServerAuthenticationCertEncodedB: Array of Byte;
  tmp_SSLStatusMessage: String;


  tmp_StatusHTTPVersion: String;
  tmp_StatusStatusCode: Integer;
  tmp_StatusDescription: String;

  tmp_TransferBytesTransferred: LongInt;
  tmp_TransferText: String;

  tmp_TransferTextB: Array of Byte;

begin
 	p := nil;
  case event_id of
    EID_RSSS_Connected:
    begin
      if Assigned(FOnConnected) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ConnectedStatusCode := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_ConnectedDescription := Marshal.PtrToStringAnsi(p);


        FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



      end;


    end;
    EID_RSSS_ConnectionStatus:
    begin
      if Assigned(FOnConnectionStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ConnectionStatusConnectionEvent := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_ConnectionStatusStatusCode := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_ConnectionStatusDescription := Marshal.PtrToStringAnsi(p);


        FOnConnectionStatus(lpContext, tmp_ConnectionStatusConnectionEvent, tmp_ConnectionStatusStatusCode, tmp_ConnectionStatusDescription);




      end;


    end;
    EID_RSSS_Disconnected:
    begin
      if Assigned(FOnDisconnected) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DisconnectedStatusCode := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_DisconnectedDescription := Marshal.PtrToStringAnsi(p);


        FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



      end;


    end;
    EID_RSSS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_RSSS_Error:
    begin
      if Assigned(FOnError) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ErrorErrorCode := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_ErrorDescription := Marshal.PtrToStringAnsi(p);


        FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



      end;


    end;
    EID_RSSS_Header:
    begin
      if Assigned(FOnHeader) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_HeaderField := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_HeaderValue := Marshal.PtrToStringAnsi(p);


        FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



      end;


    end;
    EID_RSSS_Redirect:
    begin
      if Assigned(FOnRedirect) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_RedirectLocation := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        if Marshal.ReadInt32(params, 4*1) <> 0 then tmp_RedirectAccept := true else tmp_RedirectAccept := false;


        FOnRedirect(lpContext, tmp_RedirectLocation, tmp_RedirectAccept);

        if tmp_RedirectAccept then Marshal.WriteInt32(params, 4*1, 1) else Marshal.WriteInt32(params, 4*1, 0);


      end;


    end;
    EID_RSSS_SetCookie:
    begin
      if Assigned(FOnSetCookie) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SetCookieName := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SetCookieValue := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_SetCookieExpires := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_SetCookieDomain := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_SetCookiePath := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        if Marshal.ReadInt32(params, 4*5) <> 0 then tmp_SetCookieSecure := true else tmp_SetCookieSecure := false;


        FOnSetCookie(lpContext, tmp_SetCookieName, tmp_SetCookieValue, tmp_SetCookieExpires, tmp_SetCookieDomain, tmp_SetCookiePath, tmp_SetCookieSecure);







      end;


    end;
    EID_RSSS_SSLServerAuthentication:
    begin
      if Assigned(FOnSSLServerAuthentication) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLServerAuthenticationCertEncoded := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*0));

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SSLServerAuthenticationCertSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_SSLServerAuthenticationCertIssuer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_SSLServerAuthenticationStatus := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        if Marshal.ReadInt32(params, 4*4) <> 0 then tmp_SSLServerAuthenticationAccept := true else tmp_SSLServerAuthenticationAccept := false;


        FOnSSLServerAuthentication(lpContext, tmp_SSLServerAuthenticationCertEncoded, tmp_SSLServerAuthenticationCertSubject, tmp_SSLServerAuthenticationCertIssuer, tmp_SSLServerAuthenticationStatus, tmp_SSLServerAuthenticationAccept);




        if tmp_SSLServerAuthenticationAccept then Marshal.WriteInt32(params, 4*4, 1) else Marshal.WriteInt32(params, 4*4, 0);


      end;

      if Assigned(FOnSSLServerAuthenticationB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        SetLength(tmp_SSLServerAuthenticationCertEncodedB, Marshal.ReadInt32(cbparam, 4 * 0)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 0), tmp_SSLServerAuthenticationCertEncodedB,
        						 0, Length(tmp_SSLServerAuthenticationCertEncodedB));

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SSLServerAuthenticationCertSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_SSLServerAuthenticationCertIssuer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_SSLServerAuthenticationStatus := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        if Marshal.ReadInt32(params, 4*4) <> 0 then tmp_SSLServerAuthenticationAccept := true else tmp_SSLServerAuthenticationAccept := false;


        FOnSSLServerAuthenticationB(lpContext, tmp_SSLServerAuthenticationCertEncodedB, tmp_SSLServerAuthenticationCertSubject, tmp_SSLServerAuthenticationCertIssuer, tmp_SSLServerAuthenticationStatus, tmp_SSLServerAuthenticationAccept);




        if tmp_SSLServerAuthenticationAccept then Marshal.WriteInt32(params, 4*4, 1) else Marshal.WriteInt32(params, 4*4, 0);


      end;
    end;
    EID_RSSS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_RSSS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_RSSS_Status:
    begin
      if Assigned(FOnStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_StatusHTTPVersion := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_StatusStatusCode := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_StatusDescription := Marshal.PtrToStringAnsi(p);


        FOnStatus(lpContext, tmp_StatusHTTPVersion, tmp_StatusStatusCode, tmp_StatusDescription);




      end;


    end;
    EID_RSSS_Transfer:
    begin
      if Assigned(FOnTransfer) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_TransferBytesTransferred := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_TransferText := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*1));


        FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText);



      end;

      if Assigned(FOnTransferB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_TransferBytesTransferred := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        SetLength(tmp_TransferTextB, Marshal.ReadInt32(cbparam, 4 * 1)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 1), tmp_TransferTextB,
        						 0, Length(tmp_TransferTextB));


        FOnTransferB(lpContext, tmp_TransferBytesTransferred, tmp_TransferTextB);



      end;
    end;

    99999: begin p := nil; end; {:)}
      
  end; {case}
  result := 0;
end;                         								
{$ENDIF}

procedure Register;
begin
    {Register the TAbout editor!!}
    ipsCore.Register;
    RegisterComponents('IP*Works! SSL', [TipsRSSS]);
end;

constructor TipsRSSS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _RSSS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_RSSS_Create <> nil then
      m_ctl := _RSSS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL RSSS: Error creating component');

{$IFDEF CLR}
    _RSSS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_59, 0);
{$ELSE}
    _RSSS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_59)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_RSSS_Do <> nil then
      _RSSS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_Accept('') except on E:Exception do end;
    try set_AuthScheme(authBasic) except on E:Exception do end;
    try set_ChannelCategory('') except on E:Exception do end;
    try set_ChannelCopyright('') except on E:Exception do end;
    try set_ChannelDescription('') except on E:Exception do end;
    try set_ChannelDocs('http://backend.userland.com/rss2') except on E:Exception do end;
    try set_ChannelLanguage('') except on E:Exception do end;
    try set_ChannelLastBuildDate('') except on E:Exception do end;
    try set_ChannelLink('') except on E:Exception do end;
    try set_ChannelManagingEditor('') except on E:Exception do end;
    try set_ChannelPubDate('') except on E:Exception do end;
    try set_ChannelTitle('') except on E:Exception do end;
    try set_ChannelWebMaster('') except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_FollowRedirects(frNever) except on E:Exception do end;
    try set_ImageLink('') except on E:Exception do end;
    try set_ImageTitle('') except on E:Exception do end;
    try set_ImageURL('') except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_RSSVersion(rssVersion200) except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_TextInputDescription('') except on E:Exception do end;
    try set_TextInputLink('') except on E:Exception do end;
    try set_TextInputName('') except on E:Exception do end;
    try set_TextInputTitle('') except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsRSSS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_RSSS_Destroy <> nil then{$ENDIF}
      	_RSSS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsRSSS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsRSSS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsRSSS.AboutDlg;
var
	p : LPVOIDARR;
	pc: LPINTARR;	
begin
{$IFDEF LINUX}
  inherited AboutDlg;
{$ELSE}
{$IFNDEF CLR}
	p := nil;
	pc := nil;
	if @_RSSS_Do <> nil then
{$ENDIF}
		_RSSS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsRSSS.SetOK(key: String128);
begin
end;

function TipsRSSS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsRSSS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsRSSS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsRSSS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsRSSS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsRSSS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_RSSS_GetLastError <> nil then{$ENDIF}
      msg := _RSSS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsRSSS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_RSSS_Do <> nil then
      _RSSS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsRSSS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_RSSS_Set = nil then exit;{$ENDIF}
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsRSSS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_RSSS_Set = nil then exit;{$ENDIF}
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsRSSS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_RSSS_Set = nil then exit;{$ENDIF}
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsRSSS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_RSSS_Set = nil then exit;{$ENDIF}
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsRSSS.get_Accept: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_Accept, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_Accept, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_Accept(valAccept: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_Accept, 0, valAccept, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_Accept, 0, Integer(PChar(valAccept)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_AuthScheme: TipsrsssAuthSchemes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsrsssAuthSchemes(_RSSS_GetENUM(m_ctl, PID_RSSS_AuthScheme, 0, err));
{$ELSE}
  result := TipsrsssAuthSchemes(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_AuthScheme, 0, nil);
  result := TipsrsssAuthSchemes(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_AuthScheme(valAuthScheme: TipsrsssAuthSchemes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetENUM(m_ctl, PID_RSSS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelCategory: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelCategory, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelCategory, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelCategory(valChannelCategory: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelCategory, 0, valChannelCategory, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelCategory, 0, Integer(PChar(valChannelCategory)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelCategoryDomain: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelCategoryDomain, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelCategoryDomain, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelCategoryDomain(valChannelCategoryDomain: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelCategoryDomain, 0, valChannelCategoryDomain, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelCategoryDomain, 0, Integer(PChar(valChannelCategoryDomain)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelCopyright: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelCopyright, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelCopyright, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelCopyright(valChannelCopyright: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelCopyright, 0, valChannelCopyright, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelCopyright, 0, Integer(PChar(valChannelCopyright)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelDescription: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelDescription, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelDescription, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelDescription(valChannelDescription: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelDescription, 0, valChannelDescription, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelDescription, 0, Integer(PChar(valChannelDescription)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelDocs: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelDocs, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelDocs, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelDocs(valChannelDocs: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelDocs, 0, valChannelDocs, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelDocs, 0, Integer(PChar(valChannelDocs)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelLanguage: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelLanguage, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelLanguage, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelLanguage(valChannelLanguage: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelLanguage, 0, valChannelLanguage, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelLanguage, 0, Integer(PChar(valChannelLanguage)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelLastBuildDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelLastBuildDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelLastBuildDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelLastBuildDate(valChannelLastBuildDate: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelLastBuildDate, 0, valChannelLastBuildDate, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelLastBuildDate, 0, Integer(PChar(valChannelLastBuildDate)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelLink: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelLink, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelLink, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelLink(valChannelLink: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelLink, 0, valChannelLink, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelLink, 0, Integer(PChar(valChannelLink)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelManagingEditor: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelManagingEditor, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelManagingEditor, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelManagingEditor(valChannelManagingEditor: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelManagingEditor, 0, valChannelManagingEditor, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelManagingEditor, 0, Integer(PChar(valChannelManagingEditor)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelPubDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelPubDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelPubDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelPubDate(valChannelPubDate: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelPubDate, 0, valChannelPubDate, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelPubDate, 0, Integer(PChar(valChannelPubDate)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelTitle: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelTitle, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelTitle, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelTitle(valChannelTitle: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelTitle, 0, valChannelTitle, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelTitle, 0, Integer(PChar(valChannelTitle)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ChannelWebMaster: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ChannelWebMaster, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ChannelWebMaster, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ChannelWebMaster(valChannelWebMaster: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ChannelWebMaster, 0, valChannelWebMaster, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ChannelWebMaster, 0, Integer(PChar(valChannelWebMaster)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_RSSS_GetBOOL(m_ctl, PID_RSSS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetBOOL(m_ctl, PID_RSSS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_RSSS_GetLONG(m_ctl, PID_RSSS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetLONG(m_ctl, PID_RSSS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_FirewallType: TipsrsssFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsrsssFirewallTypes(_RSSS_GetENUM(m_ctl, PID_RSSS_FirewallType, 0, err));
{$ELSE}
  result := TipsrsssFirewallTypes(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_FirewallType, 0, nil);
  result := TipsrsssFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_FirewallType(valFirewallType: TipsrsssFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetENUM(m_ctl, PID_RSSS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_FollowRedirects: TipsrsssFollowRedirects;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsrsssFollowRedirects(_RSSS_GetENUM(m_ctl, PID_RSSS_FollowRedirects, 0, err));
{$ELSE}
  result := TipsrsssFollowRedirects(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_FollowRedirects, 0, nil);
  result := TipsrsssFollowRedirects(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_FollowRedirects(valFollowRedirects: TipsrsssFollowRedirects);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetENUM(m_ctl, PID_RSSS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_RSSS_GetBOOL(m_ctl, PID_RSSS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsRSSS.get_ImageLink: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ImageLink, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ImageLink, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ImageLink(valImageLink: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ImageLink, 0, valImageLink, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ImageLink, 0, Integer(PChar(valImageLink)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ImageTitle: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ImageTitle, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ImageTitle, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ImageTitle(valImageTitle: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ImageTitle, 0, valImageTitle, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ImageTitle, 0, Integer(PChar(valImageTitle)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ImageURL: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ImageURL, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ImageURL, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ImageURL(valImageURL: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ImageURL, 0, valImageURL, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ImageURL, 0, Integer(PChar(valImageURL)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemAuthor(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemAuthor, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemAuthor, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemAuthor');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemAuthor, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemAuthor(ItemIndex: Word; valItemAuthor: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemAuthor, ItemIndex, valItemAuthor, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemAuthor, ItemIndex, Integer(PChar(valItemAuthor)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemCategory(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemCategory, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemCategory, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemCategory');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemCategory, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemCategory(ItemIndex: Word; valItemCategory: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemCategory, ItemIndex, valItemCategory, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemCategory, ItemIndex, Integer(PChar(valItemCategory)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemCategoryDomain(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemCategoryDomain, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemCategoryDomain, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemCategoryDomain');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemCategoryDomain, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemCategoryDomain(ItemIndex: Word; valItemCategoryDomain: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemCategoryDomain, ItemIndex, valItemCategoryDomain, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemCategoryDomain, ItemIndex, Integer(PChar(valItemCategoryDomain)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemComments(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemComments, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemComments, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemComments');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemComments, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemComments(ItemIndex: Word; valItemComments: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemComments, ItemIndex, valItemComments, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemComments, ItemIndex, Integer(PChar(valItemComments)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_RSSS_GetINT(m_ctl, PID_RSSS_ItemCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_ItemCount(valItemCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetINT(m_ctl, PID_RSSS_ItemCount, 0, valItemCount, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemCount, 0, Integer(valItemCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemDescription(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemDescription, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemDescription, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemDescription');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemDescription, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemDescription(ItemIndex: Word; valItemDescription: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemDescription, ItemIndex, valItemDescription, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemDescription, ItemIndex, Integer(PChar(valItemDescription)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemGuid(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemGuid, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemGuid, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemGuid');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemGuid, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemGuid(ItemIndex: Word; valItemGuid: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemGuid, ItemIndex, valItemGuid, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemGuid, ItemIndex, Integer(PChar(valItemGuid)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemLink(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemLink, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemLink, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemLink');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemLink, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemLink(ItemIndex: Word; valItemLink: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemLink, ItemIndex, valItemLink, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemLink, ItemIndex, Integer(PChar(valItemLink)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemPubDate(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemPubDate, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemPubDate, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemPubDate');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemPubDate, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemPubDate(ItemIndex: Word; valItemPubDate: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemPubDate, ItemIndex, valItemPubDate, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemPubDate, ItemIndex, Integer(PChar(valItemPubDate)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemSource(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemSource, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemSource, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemSource');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemSource, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemSource(ItemIndex: Word; valItemSource: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemSource, ItemIndex, valItemSource, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemSource, ItemIndex, Integer(PChar(valItemSource)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemSourceURL(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemSourceURL, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemSourceURL, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemSourceURL');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemSourceURL, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemSourceURL(ItemIndex: Word; valItemSourceURL: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemSourceURL, ItemIndex, valItemSourceURL, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemSourceURL, ItemIndex, Integer(PChar(valItemSourceURL)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_ItemTitle(ItemIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_ItemTitle, ItemIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_ItemTitle, ItemIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ItemTitle');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_ItemTitle, ItemIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_ItemTitle(ItemIndex: Word; valItemTitle: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_ItemTitle, ItemIndex, valItemTitle, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_ItemTitle, ItemIndex, Integer(PChar(valItemTitle)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_NamespaceCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_RSSS_GetINT(m_ctl, PID_RSSS_NamespaceCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_NamespaceCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_NamespaceCount(valNamespaceCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetINT(m_ctl, PID_RSSS_NamespaceCount, 0, valNamespaceCount, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_NamespaceCount, 0, Integer(valNamespaceCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_NamespacePrefixes(NamespaceIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_NamespacePrefixes, NamespaceIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_NamespacePrefixes, NamespaceIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for NamespacePrefixes');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_NamespacePrefixes, NamespaceIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_NamespacePrefixes(NamespaceIndex: Word; valNamespacePrefixes: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_NamespacePrefixes, NamespaceIndex, valNamespacePrefixes, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_NamespacePrefixes, NamespaceIndex, Integer(PChar(valNamespacePrefixes)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_Namespaces(NamespaceIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_Namespaces, NamespaceIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_RSSS_CheckIndex = nil then exit;
  err :=  _RSSS_CheckIndex(m_ctl, PID_RSSS_Namespaces, NamespaceIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for Namespaces');
	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_Namespaces, NamespaceIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_Namespaces(NamespaceIndex: Word; valNamespaces: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_Namespaces, NamespaceIndex, valNamespaces, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_Namespaces, NamespaceIndex, Integer(PChar(valNamespaces)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_Password, 0, valPassword, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_RSSData: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_RSSData, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_RSSData, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsRSSS.get_RSSVersion: TipsrsssRSSVersions;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsrsssRSSVersions(_RSSS_GetENUM(m_ctl, PID_RSSS_RSSVersion, 0, err));
{$ELSE}
  result := TipsrsssRSSVersions(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_RSSVersion, 0, nil);
  result := TipsrsssRSSVersions(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_RSSVersion(valRSSVersion: TipsrsssRSSVersions);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetENUM(m_ctl, PID_RSSS_RSSVersion, 0, Integer(valRSSVersion), 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_RSSVersion, 0, Integer(valRSSVersion), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetBSTR(m_ctl, PID_RSSS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsRSSS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetBSTR(m_ctl, PID_RSSS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetBSTR(m_ctl, PID_RSSS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsRSSS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetBSTR(m_ctl, PID_RSSS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetBSTR(m_ctl, PID_RSSS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsRSSS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetBSTR(m_ctl, PID_RSSS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_SSLCertStoreType: TipsrsssSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsrsssSSLCertStoreTypes(_RSSS_GetENUM(m_ctl, PID_RSSS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipsrsssSSLCertStoreTypes(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_SSLCertStoreType, 0, nil);
  result := TipsrsssSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_SSLCertStoreType(valSSLCertStoreType: TipsrsssSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetENUM(m_ctl, PID_RSSS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetBSTR(m_ctl, PID_RSSS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsRSSS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsRSSS.get_TextInputDescription: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_TextInputDescription, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_TextInputDescription, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_TextInputDescription(valTextInputDescription: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_TextInputDescription, 0, valTextInputDescription, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_TextInputDescription, 0, Integer(PChar(valTextInputDescription)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_TextInputLink: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_TextInputLink, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_TextInputLink, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_TextInputLink(valTextInputLink: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_TextInputLink, 0, valTextInputLink, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_TextInputLink, 0, Integer(PChar(valTextInputLink)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_TextInputName: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_TextInputName, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_TextInputName, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_TextInputName(valTextInputName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_TextInputName, 0, valTextInputName, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_TextInputName, 0, Integer(PChar(valTextInputName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_TextInputTitle: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_TextInputTitle, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_TextInputTitle, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_TextInputTitle(valTextInputTitle: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_TextInputTitle, 0, valTextInputTitle, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_TextInputTitle, 0, Integer(PChar(valTextInputTitle)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_RSSS_GetINT(m_ctl, PID_RSSS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsRSSS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetINT(m_ctl, PID_RSSS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsRSSS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _RSSS_GetCSTR(m_ctl, PID_RSSS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_RSSS_Get = nil then exit;
  tmp := _RSSS_Get(m_ctl, PID_RSSS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsRSSS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _RSSS_SetCSTR(m_ctl, PID_RSSS_User, 0, valUser, 0);
{$ELSE}
	if @_RSSS_Set = nil then exit;
  err := _RSSS_Set(m_ctl, PID_RSSS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsRSSS.Config(ConfigurationString: String): String;
var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..2] of Pointer;
  paramcb : array[0..2] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsRSSS.AddItem(Title: String; Description: String; Link: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..4] of Pointer;
  paramcb : array[0..4] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(Title);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Description);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Link);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_AddItem, 3, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);

	if param[2] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[2]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(Title);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Description);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Link);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_AddItem, 3, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsRSSS.AddNamespace(Prefix: String; NamespaceURI: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..3] of Pointer;
  paramcb : array[0..3] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(Prefix);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(NamespaceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_AddNamespace, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(Prefix);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(NamespaceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_AddNamespace, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsRSSS.GetFeed(URL: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..2] of Pointer;
  paramcb : array[0..2] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(URL);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_GetFeed, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_GetFeed, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsRSSS.GetProperty(PropertyName: String): String;
var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..2] of Pointer;
  paramcb : array[0..2] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(PropertyName);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_GetProperty, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(PropertyName);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_GetProperty, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsRSSS.GetURL(URL: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..2] of Pointer;
  paramcb : array[0..2] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(URL);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_GetURL, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_GetURL, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsRSSS.Put(URL: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..2] of Pointer;
  paramcb : array[0..2] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(URL);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_Put, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_Put, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsRSSS.ReadFile(FileName: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..2] of Pointer;
  paramcb : array[0..2] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(FileName);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_ReadFile, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(FileName);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_ReadFile, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsRSSS.Reset();

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..1] of Pointer;
  paramcb : array[0..1] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}



  err := _RSSS_Do(m_ctl, MID_RSSS_Reset, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_Reset, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsRSSS.SetProperty(PropertyName: String; PropertyValue: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..3] of Pointer;
  paramcb : array[0..3] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(PropertyName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(PropertyValue);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_SetProperty, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(PropertyName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(PropertyValue);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_SetProperty, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsRSSS.WriteFile(Filename: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..2] of Pointer;
  paramcb : array[0..2] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(Filename);
  paramcb[i] := 0;

  i := i + 1;


  err := _RSSS_Do(m_ctl, MID_RSSS_WriteFile, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(Filename);
  paramcb[i] := 0;

  i := i + 1;


	if @_RSSS_Do = nil then exit;
  err := _RSSS_Do(m_ctl, MID_RSSS_WriteFile, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;


{$ENDIF}


{$IFNDEF LINUX}
{$IFNDEF CLR}
{$IFNDEF USEIPWORKSSSLDLL}
procedure LoadRESDLL;
var
  hResInfo: HRSRC;
  hResData: HGLOBAL;
  pResData: Pointer;

begin

	_RSSS_Create := nil;
	_RSSS_Destroy := nil;
	_RSSS_Set := nil;
	_RSSS_Get := nil;
	_RSSS_GetLastError := nil;
	_RSSS_StaticInit := nil;
	_RSSS_CheckIndex := nil;
	_RSSS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_rsss_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_RSSS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'RSSS_Create');
		@_RSSS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'RSSS_Destroy');
		@_RSSS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'RSSS_Set');
		@_RSSS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'RSSS_Get');
		@_RSSS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'RSSS_GetLastError');
		@_RSSS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'RSSS_CheckIndex');
		@_RSSS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'RSSS_Do');
	end;
	
	FreeResource(hResData);  

end;


initialization
begin
  pBaseAddress := nil;
  pEntryPoint := nil;
  LoadResDLL;
end;

finalization
begin
  @_RSSS_Create       := nil;
  @_RSSS_Destroy      := nil;
  @_RSSS_Set          := nil;
  @_RSSS_Get          := nil;
  @_RSSS_GetLastError := nil;
  @_RSSS_CheckIndex   := nil;
  @_RSSS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




