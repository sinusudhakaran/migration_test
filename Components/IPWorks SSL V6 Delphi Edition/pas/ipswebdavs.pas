
unit ipswebdavs;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipswebdavsAuthSchemes = 
(

									 
                   authBasic,

									 
                   authDigest
);
  TipswebdavsDepths = 
(

									 
                   dpUnspecified,

									 
                   dpResourceOnly,

									 
                   dpImmediateChildren,

									 
                   dpInfinity
);
  TipswebdavsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipswebdavsFollowRedirects = 
(

									 
                   frNever,

									 
                   frAlways,

									 
                   frSameScheme
);
  TipswebdavsPropertyOperations = 
(

									 
                   opGet,

									 
                   opSet,

									 
                   opDelete
);
  TipswebdavsSSLCertStoreTypes = 
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

  TDirListEvent = procedure(Sender: TObject;
                            const ResourceURI: String;
                            const DisplayName: String;
                            const ContentLanguage: String;
                            const ContentLength: String;
                            const ContentType: String;
                            const LastModified: String) of Object;

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

  TResourcePropertiesEvent = procedure(Sender: TObject;
                            const ResourceURI: String;
                            const ResourceProperties: String) of Object;

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
  TWebDAVSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsWebDAVS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsWebDAVS = class(TipsCore)
    public
      FOnConnected: TConnectedEvent;

      FOnConnectionStatus: TConnectionStatusEvent;

      FOnDirList: TDirListEvent;

      FOnDisconnected: TDisconnectedEvent;

      FOnEndTransfer: TEndTransferEvent;

      FOnError: TErrorEvent;

      FOnHeader: THeaderEvent;

      FOnRedirect: TRedirectEvent;

      FOnResourceProperties: TResourcePropertiesEvent;

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
      m_anchor: TWebDAVSEventHook;
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

      function get_CookieCount: Integer;
      procedure set_CookieCount(valCookieCount: Integer);

      function get_CookieName(CookieIndex: Word): String;
      procedure set_CookieName(CookieIndex: Word; valCookieName: String);

      function get_CookieValue(CookieIndex: Word): String;
      procedure set_CookieValue(CookieIndex: Word; valCookieValue: String);

      function get_NamespaceCount: Integer;
      procedure set_NamespaceCount(valNamespaceCount: Integer);

      function get_NamespacePrefixes(NamespaceIndex: Word): String;
      procedure set_NamespacePrefixes(NamespaceIndex: Word; valNamespacePrefixes: String);

      function get_Namespaces(NamespaceIndex: Word): String;
      procedure set_Namespaces(NamespaceIndex: Word; valNamespaces: String);

      function get_OtherHeaders: String;
      procedure set_OtherHeaders(valOtherHeaders: String);

      function get_PropertyCount: Integer;
      procedure set_PropertyCount(valPropertyCount: Integer);

      function get_PropertyName(PropertyIndex: Word): String;
      procedure set_PropertyName(PropertyIndex: Word; valPropertyName: String);

      function get_PropertyOperation(PropertyIndex: Word): TipswebdavsPropertyOperations;
      procedure set_PropertyOperation(PropertyIndex: Word; valPropertyOperation: TipswebdavsPropertyOperations);

      function get_PropertyStatus(PropertyIndex: Word): String;


      function get_PropertyValue(PropertyIndex: Word): String;
      procedure set_PropertyValue(PropertyIndex: Word; valPropertyValue: String);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);

      function get_StatusLine: String;


      function get_TransferredData: String;


      function get_TransferredHeaders: String;



      procedure TreatErr(Err: integer; const desc: string);


      function get_Accept: String;
      procedure set_Accept(valAccept: String);

      function get_AuthScheme: TipswebdavsAuthSchemes;
      procedure set_AuthScheme(valAuthScheme: TipswebdavsAuthSchemes);







      function get_Depth: TipswebdavsDepths;
      procedure set_Depth(valDepth: TipswebdavsDepths);

      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipswebdavsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipswebdavsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_FollowRedirects: TipswebdavsFollowRedirects;
      procedure set_FollowRedirects(valFollowRedirects: TipswebdavsFollowRedirects);

      function get_Idle: Boolean;


      function get_LocalFile: String;
      procedure set_LocalFile(valLocalFile: String);

      function get_LockOwner: String;
      procedure set_LockOwner(valLockOwner: String);

      function get_LockScope: String;
      procedure set_LockScope(valLockScope: String);

      function get_LockTimeout: Integer;
      procedure set_LockTimeout(valLockTimeout: Integer);

      function get_LockTokens: String;
      procedure set_LockTokens(valLockTokens: String);

      function get_LockType: String;
      procedure set_LockType(valLockType: String);









      function get_Password: String;
      procedure set_Password(valPassword: String);











      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipswebdavsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipswebdavsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;




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
      procedure SetTransferredData(lpTransferredData: PChar; lenTransferredData: Cardinal);

{$ENDIF}





      property CookieCount: Integer
               read get_CookieCount
               write set_CookieCount               ;

      property CookieName[CookieIndex: Word]: String
               read get_CookieName
               write set_CookieName               ;

      property CookieValue[CookieIndex: Word]: String
               read get_CookieValue
               write set_CookieValue               ;





























      property NamespaceCount: Integer
               read get_NamespaceCount
               write set_NamespaceCount               ;

      property NamespacePrefixes[NamespaceIndex: Word]: String
               read get_NamespacePrefixes
               write set_NamespacePrefixes               ;

      property Namespaces[NamespaceIndex: Word]: String
               read get_Namespaces
               write set_Namespaces               ;

      property OtherHeaders: String
               read get_OtherHeaders
               write set_OtherHeaders               ;



      property PropertyCount: Integer
               read get_PropertyCount
               write set_PropertyCount               ;

      property PropertyName[PropertyIndex: Word]: String
               read get_PropertyName
               write set_PropertyName               ;

      property PropertyOperation[PropertyIndex: Word]: TipswebdavsPropertyOperations
               read get_PropertyOperation
               write set_PropertyOperation               ;

      property PropertyStatus[PropertyIndex: Word]: String
               read get_PropertyStatus
               ;

      property PropertyValue[PropertyIndex: Word]: String
               read get_PropertyValue
               write set_PropertyValue               ;



      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;













      property StatusLine: String
               read get_StatusLine
               ;



      property TransferredData: String
               read get_TransferredData
               ;

      property TransferredHeaders: String
               read get_TransferredHeaders
               ;





{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure AddCookie(CookieName: String; CookieValue: String);

      procedure AddNamespace(Prefix: String; NamespaceURI: String);

      procedure CopyResource(SourceResourceURI: String; DestinationResourceURI: String);

      procedure DeleteResource(ResourceURI: String);

      procedure DoEvents();

      procedure FindProperties(ResourceURI: String);

      procedure FindPropertyNames(ResourceURI: String);

      function GetProperty(PropertyName: String): String;
      procedure GetResource(ResourceURI: String);

      procedure Interrupt();

      procedure ListDirectory(ResourceURI: String);

      procedure LockResource(ResourceURI: String);

      procedure MakeDirectory(ResourceURI: String);

      procedure MoveResource(SourceResourceURI: String; DestinationResourceURI: String);

      procedure PatchProperties(ResourceURI: String);

      procedure PostToResource(ResourceURI: String; PostData: String);

      procedure PutResource(ResourceURI: String);

      procedure Reset();

      procedure SetProperty(PropertyName: String; PropertyValue: String);

      procedure UnLockResource(ResourceURI: String);


{$ENDIF}

    published

      property Accept: String
                   read get_Accept
                   write set_Accept
                   
                   ;
      property AuthScheme: TipswebdavsAuthSchemes
                   read get_AuthScheme
                   write set_AuthScheme
                   default authBasic
                   ;



      property Depth: TipswebdavsDepths
                   read get_Depth
                   write set_Depth
                   default dpUnspecified
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
      property FirewallType: TipswebdavsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property FollowRedirects: TipswebdavsFollowRedirects
                   read get_FollowRedirects
                   write set_FollowRedirects
                   default frNever
                   ;
      property Idle: Boolean
                   read get_Idle
                    write SetNoopBoolean
                   stored False

                   ;
      property LocalFile: String
                   read get_LocalFile
                   write set_LocalFile
                   
                   ;
      property LockOwner: String
                   read get_LockOwner
                   write set_LockOwner
                   
                   ;
      property LockScope: String
                   read get_LockScope
                   write set_LockScope
                   
                   ;
      property LockTimeout: Integer
                   read get_LockTimeout
                   write set_LockTimeout
                   default 0
                   ;
      property LockTokens: String
                   read get_LockTokens
                   write set_LockTokens
                   
                   ;
      property LockType: String
                   read get_LockType
                   write set_LockType
                   
                   ;




      property Password: String
                   read get_Password
                   write set_Password
                   
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
      property SSLCertStoreType: TipswebdavsSSLCertStoreTypes
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

      property OnDirList: TDirListEvent read FOnDirList write FOnDirList;

      property OnDisconnected: TDisconnectedEvent read FOnDisconnected write FOnDisconnected;

      property OnEndTransfer: TEndTransferEvent read FOnEndTransfer write FOnEndTransfer;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnHeader: THeaderEvent read FOnHeader write FOnHeader;

      property OnRedirect: TRedirectEvent read FOnRedirect write FOnRedirect;

      property OnResourceProperties: TResourcePropertiesEvent read FOnResourceProperties write FOnResourceProperties;

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
    PID_WebDAVS_Accept = 1;
    PID_WebDAVS_AuthScheme = 2;
    PID_WebDAVS_CookieCount = 3;
    PID_WebDAVS_CookieName = 4;
    PID_WebDAVS_CookieValue = 5;
    PID_WebDAVS_Depth = 6;
    PID_WebDAVS_FirewallHost = 7;
    PID_WebDAVS_FirewallPassword = 8;
    PID_WebDAVS_FirewallPort = 9;
    PID_WebDAVS_FirewallType = 10;
    PID_WebDAVS_FirewallUser = 11;
    PID_WebDAVS_FollowRedirects = 12;
    PID_WebDAVS_Idle = 13;
    PID_WebDAVS_LocalFile = 14;
    PID_WebDAVS_LockOwner = 15;
    PID_WebDAVS_LockScope = 16;
    PID_WebDAVS_LockTimeout = 17;
    PID_WebDAVS_LockTokens = 18;
    PID_WebDAVS_LockType = 19;
    PID_WebDAVS_NamespaceCount = 20;
    PID_WebDAVS_NamespacePrefixes = 21;
    PID_WebDAVS_Namespaces = 22;
    PID_WebDAVS_OtherHeaders = 23;
    PID_WebDAVS_Password = 24;
    PID_WebDAVS_PropertyCount = 25;
    PID_WebDAVS_PropertyName = 26;
    PID_WebDAVS_PropertyOperation = 27;
    PID_WebDAVS_PropertyStatus = 28;
    PID_WebDAVS_PropertyValue = 29;
    PID_WebDAVS_SSLAcceptServerCert = 30;
    PID_WebDAVS_SSLCertEncoded = 31;
    PID_WebDAVS_SSLCertStore = 32;
    PID_WebDAVS_SSLCertStorePassword = 33;
    PID_WebDAVS_SSLCertStoreType = 34;
    PID_WebDAVS_SSLCertSubject = 35;
    PID_WebDAVS_SSLServerCert = 36;
    PID_WebDAVS_SSLServerCertStatus = 37;
    PID_WebDAVS_StatusLine = 38;
    PID_WebDAVS_Timeout = 39;
    PID_WebDAVS_TransferredData = 40;
    PID_WebDAVS_TransferredHeaders = 41;
    PID_WebDAVS_User = 42;

    EID_WebDAVS_Connected = 1;
    EID_WebDAVS_ConnectionStatus = 2;
    EID_WebDAVS_DirList = 3;
    EID_WebDAVS_Disconnected = 4;
    EID_WebDAVS_EndTransfer = 5;
    EID_WebDAVS_Error = 6;
    EID_WebDAVS_Header = 7;
    EID_WebDAVS_Redirect = 8;
    EID_WebDAVS_ResourceProperties = 9;
    EID_WebDAVS_SetCookie = 10;
    EID_WebDAVS_SSLServerAuthentication = 11;
    EID_WebDAVS_SSLStatus = 12;
    EID_WebDAVS_StartTransfer = 13;
    EID_WebDAVS_Status = 14;
    EID_WebDAVS_Transfer = 15;


    MID_WebDAVS_Config = 1;
    MID_WebDAVS_AddCookie = 2;
    MID_WebDAVS_AddNamespace = 3;
    MID_WebDAVS_CopyResource = 4;
    MID_WebDAVS_DeleteResource = 5;
    MID_WebDAVS_DoEvents = 6;
    MID_WebDAVS_FindProperties = 7;
    MID_WebDAVS_FindPropertyNames = 8;
    MID_WebDAVS_GetProperty = 9;
    MID_WebDAVS_GetResource = 10;
    MID_WebDAVS_Interrupt = 11;
    MID_WebDAVS_ListDirectory = 12;
    MID_WebDAVS_LockResource = 13;
    MID_WebDAVS_MakeDirectory = 14;
    MID_WebDAVS_MoveResource = 15;
    MID_WebDAVS_PatchProperties = 16;
    MID_WebDAVS_PostToResource = 17;
    MID_WebDAVS_PutResource = 18;
    MID_WebDAVS_Reset = 19;
    MID_WebDAVS_SetProperty = 20;
    MID_WebDAVS_UnLockResource = 21;




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
{$R 'ipswebdavs.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsWebDAVS; event_id: Integer; cparam: Integer; 
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
  _WebDAVS_Create:        function(pMethod: PEventHandle; pObject: TipsWebDAVS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebDAVS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebDAVS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebDAVS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebDAVS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebDAVS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebDAVS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebDAVS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Create')]
  function _WebDAVS_Create       (pMethod: TWebDAVSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Destroy')]
  function _WebDAVS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Set')]
  function _WebDAVS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Set')]
  function _WebDAVS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Set')]
  function _WebDAVS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Set')]
  function _WebDAVS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Set')]
  function _WebDAVS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Set')]
  function _WebDAVS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Get')]
  function _WebDAVS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Get')]
  function _WebDAVS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Get')]
  function _WebDAVS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Get')]
  function _WebDAVS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Get')]
  function _WebDAVS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Get')]
  function _WebDAVS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_GetLastError')]
  function _WebDAVS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_StaticInit')]
  function _WebDAVS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_CheckIndex')]
  function _WebDAVS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebDAVS_Do')]
  function _WebDAVS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _WebDAVS_Create       (pMethod: PEventHandle; pObject: TipsWebDAVS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebDAVS_Create';
  function _WebDAVS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebDAVS_Destroy';
  function _WebDAVS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebDAVS_Set';
  function _WebDAVS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebDAVS_Get';
  function _WebDAVS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebDAVS_GetLastError';
  function _WebDAVS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebDAVS_StaticInit';
  function _WebDAVS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebDAVS_CheckIndex';
  function _WebDAVS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebDAVS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsWebDAVS; event_id: Integer;
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
    tmp_DirListResourceURI: String;
    tmp_DirListDisplayName: String;
    tmp_DirListContentLanguage: String;
    tmp_DirListContentLength: String;
    tmp_DirListContentType: String;
    tmp_DirListLastModified: String;
    tmp_DisconnectedStatusCode: Integer;
    tmp_DisconnectedDescription: String;
    tmp_ErrorErrorCode: Integer;
    tmp_ErrorDescription: String;
    tmp_HeaderField: String;
    tmp_HeaderValue: String;
    tmp_RedirectLocation: String;
    tmp_ResourcePropertiesResourceURI: String;
    tmp_ResourcePropertiesResourceProperties: String;
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

      EID_WebDAVS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_WebDAVS_ConnectionStatus:
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
      EID_WebDAVS_DirList:
      begin
        if Assigned(lpContext.FOnDirList) then
        begin
          {assign temporary variables}
          tmp_DirListResourceURI := AnsiString(PChar(params^[0]));

          tmp_DirListDisplayName := AnsiString(PChar(params^[1]));

          tmp_DirListContentLanguage := AnsiString(PChar(params^[2]));

          tmp_DirListContentLength := AnsiString(PChar(params^[3]));

          tmp_DirListContentType := AnsiString(PChar(params^[4]));

          tmp_DirListLastModified := AnsiString(PChar(params^[5]));


          lpContext.FOnDirList(lpContext, tmp_DirListResourceURI, tmp_DirListDisplayName, tmp_DirListContentLanguage, tmp_DirListContentLength, tmp_DirListContentType, tmp_DirListLastModified);







        end;
      end;
      EID_WebDAVS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_WebDAVS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_WebDAVS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_WebDAVS_Header:
      begin
        if Assigned(lpContext.FOnHeader) then
        begin
          {assign temporary variables}
          tmp_HeaderField := AnsiString(PChar(params^[0]));

          tmp_HeaderValue := AnsiString(PChar(params^[1]));


          lpContext.FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



        end;
      end;
      EID_WebDAVS_Redirect:
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
      EID_WebDAVS_ResourceProperties:
      begin
        if Assigned(lpContext.FOnResourceProperties) then
        begin
          {assign temporary variables}
          tmp_ResourcePropertiesResourceURI := AnsiString(PChar(params^[0]));

          tmp_ResourcePropertiesResourceProperties := AnsiString(PChar(params^[1]));


          lpContext.FOnResourceProperties(lpContext, tmp_ResourcePropertiesResourceURI, tmp_ResourcePropertiesResourceProperties);



        end;
      end;
      EID_WebDAVS_SetCookie:
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
      EID_WebDAVS_SSLServerAuthentication:
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
      EID_WebDAVS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_WebDAVS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_WebDAVS_Status:
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
      EID_WebDAVS_Transfer:
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
function TipsWebDAVS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectedStatusCode: Integer;
  tmp_ConnectedDescription: String;

  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;

  tmp_DirListResourceURI: String;
  tmp_DirListDisplayName: String;
  tmp_DirListContentLanguage: String;
  tmp_DirListContentLength: String;
  tmp_DirListContentType: String;
  tmp_DirListLastModified: String;

  tmp_DisconnectedStatusCode: Integer;
  tmp_DisconnectedDescription: String;


  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_HeaderField: String;
  tmp_HeaderValue: String;

  tmp_RedirectLocation: String;

  tmp_ResourcePropertiesResourceURI: String;
  tmp_ResourcePropertiesResourceProperties: String;

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
    EID_WebDAVS_Connected:
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
    EID_WebDAVS_ConnectionStatus:
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
    EID_WebDAVS_DirList:
    begin
      if Assigned(FOnDirList) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DirListResourceURI := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_DirListDisplayName := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_DirListContentLanguage := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_DirListContentLength := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_DirListContentType := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        tmp_DirListLastModified := Marshal.PtrToStringAnsi(p);


        FOnDirList(lpContext, tmp_DirListResourceURI, tmp_DirListDisplayName, tmp_DirListContentLanguage, tmp_DirListContentLength, tmp_DirListContentType, tmp_DirListLastModified);







      end;


    end;
    EID_WebDAVS_Disconnected:
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
    EID_WebDAVS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_WebDAVS_Error:
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
    EID_WebDAVS_Header:
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
    EID_WebDAVS_Redirect:
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
    EID_WebDAVS_ResourceProperties:
    begin
      if Assigned(FOnResourceProperties) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ResourcePropertiesResourceURI := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_ResourcePropertiesResourceProperties := Marshal.PtrToStringAnsi(p);


        FOnResourceProperties(lpContext, tmp_ResourcePropertiesResourceURI, tmp_ResourcePropertiesResourceProperties);



      end;


    end;
    EID_WebDAVS_SetCookie:
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
    EID_WebDAVS_SSLServerAuthentication:
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
    EID_WebDAVS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_WebDAVS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_WebDAVS_Status:
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
    EID_WebDAVS_Transfer:
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
    RegisterComponents('IP*Works! SSL', [TipsWebDAVS]);
end;

constructor TipsWebDAVS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _WebDAVS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_WebDAVS_Create <> nil then
      m_ctl := _WebDAVS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL WebDAVS: Error creating component');

{$IFDEF CLR}
    _WebDAVS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_61, 0);
{$ELSE}
    _WebDAVS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_61)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_WebDAVS_Do <> nil then
      _WebDAVS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_Accept('') except on E:Exception do end;
    try set_AuthScheme(authBasic) except on E:Exception do end;
    try set_Depth(dpUnspecified) except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_FollowRedirects(frNever) except on E:Exception do end;
    try set_LocalFile('') except on E:Exception do end;
    try set_LockOwner('') except on E:Exception do end;
    try set_LockScope('') except on E:Exception do end;
    try set_LockTimeout(0) except on E:Exception do end;
    try set_LockTokens('') except on E:Exception do end;
    try set_LockType('') except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsWebDAVS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_WebDAVS_Destroy <> nil then{$ENDIF}
      	_WebDAVS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsWebDAVS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsWebDAVS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsWebDAVS.AboutDlg;
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
	if @_WebDAVS_Do <> nil then
{$ENDIF}
		_WebDAVS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsWebDAVS.SetOK(key: String128);
begin
end;

function TipsWebDAVS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsWebDAVS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsWebDAVS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsWebDAVS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsWebDAVS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsWebDAVS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_WebDAVS_GetLastError <> nil then{$ENDIF}
      msg := _WebDAVS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsWebDAVS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_WebDAVS_Do <> nil then
      _WebDAVS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsWebDAVS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebDAVS_Set = nil then exit;{$ENDIF}
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebDAVS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebDAVS_Set = nil then exit;{$ENDIF}
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebDAVS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebDAVS_Set = nil then exit;{$ENDIF}
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebDAVS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebDAVS_Set = nil then exit;{$ENDIF}
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebDAVS.SetTransferredData(lpTransferredData: PChar; lenTransferredData: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebDAVS_Set = nil then exit;{$ENDIF}
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_TransferredData, 0, Integer(lpTransferredData), lenTransferredData);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsWebDAVS.get_Accept: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_Accept, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_Accept, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_Accept(valAccept: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_Accept, 0, valAccept, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_Accept, 0, Integer(PChar(valAccept)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_AuthScheme: TipswebdavsAuthSchemes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebdavsAuthSchemes(_WebDAVS_GetENUM(m_ctl, PID_WebDAVS_AuthScheme, 0, err));
{$ELSE}
  result := TipswebdavsAuthSchemes(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_AuthScheme, 0, nil);
  result := TipswebdavsAuthSchemes(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_AuthScheme(valAuthScheme: TipswebdavsAuthSchemes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetENUM(m_ctl, PID_WebDAVS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_CookieCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebDAVS_GetINT(m_ctl, PID_WebDAVS_CookieCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_CookieCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_CookieCount(valCookieCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetINT(m_ctl, PID_WebDAVS_CookieCount, 0, valCookieCount, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_CookieCount, 0, Integer(valCookieCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_CookieName(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_CookieName, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebDAVS_CheckIndex = nil then exit;
  err :=  _WebDAVS_CheckIndex(m_ctl, PID_WebDAVS_CookieName, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieName');
	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_CookieName, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_CookieName(CookieIndex: Word; valCookieName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_CookieName, CookieIndex, valCookieName, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_CookieName, CookieIndex, Integer(PChar(valCookieName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_CookieValue(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_CookieValue, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebDAVS_CheckIndex = nil then exit;
  err :=  _WebDAVS_CheckIndex(m_ctl, PID_WebDAVS_CookieValue, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieValue');
	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_CookieValue, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_CookieValue(CookieIndex: Word; valCookieValue: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_CookieValue, CookieIndex, valCookieValue, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_CookieValue, CookieIndex, Integer(PChar(valCookieValue)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_Depth: TipswebdavsDepths;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebdavsDepths(_WebDAVS_GetENUM(m_ctl, PID_WebDAVS_Depth, 0, err));
{$ELSE}
  result := TipswebdavsDepths(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_Depth, 0, nil);
  result := TipswebdavsDepths(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_Depth(valDepth: TipswebdavsDepths);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetENUM(m_ctl, PID_WebDAVS_Depth, 0, Integer(valDepth), 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_Depth, 0, Integer(valDepth), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebDAVS_GetLONG(m_ctl, PID_WebDAVS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetLONG(m_ctl, PID_WebDAVS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_FirewallType: TipswebdavsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebdavsFirewallTypes(_WebDAVS_GetENUM(m_ctl, PID_WebDAVS_FirewallType, 0, err));
{$ELSE}
  result := TipswebdavsFirewallTypes(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_FirewallType, 0, nil);
  result := TipswebdavsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_FirewallType(valFirewallType: TipswebdavsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetENUM(m_ctl, PID_WebDAVS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_FollowRedirects: TipswebdavsFollowRedirects;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebdavsFollowRedirects(_WebDAVS_GetENUM(m_ctl, PID_WebDAVS_FollowRedirects, 0, err));
{$ELSE}
  result := TipswebdavsFollowRedirects(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_FollowRedirects, 0, nil);
  result := TipswebdavsFollowRedirects(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_FollowRedirects(valFollowRedirects: TipswebdavsFollowRedirects);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetENUM(m_ctl, PID_WebDAVS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_WebDAVS_GetBOOL(m_ctl, PID_WebDAVS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsWebDAVS.get_LocalFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_LocalFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_LocalFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_LocalFile(valLocalFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_LocalFile, 0, valLocalFile, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_LocalFile, 0, Integer(PChar(valLocalFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_LockOwner: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_LockOwner, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_LockOwner, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_LockOwner(valLockOwner: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_LockOwner, 0, valLockOwner, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_LockOwner, 0, Integer(PChar(valLockOwner)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_LockScope: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_LockScope, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_LockScope, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_LockScope(valLockScope: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_LockScope, 0, valLockScope, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_LockScope, 0, Integer(PChar(valLockScope)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_LockTimeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebDAVS_GetINT(m_ctl, PID_WebDAVS_LockTimeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_LockTimeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_LockTimeout(valLockTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetINT(m_ctl, PID_WebDAVS_LockTimeout, 0, valLockTimeout, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_LockTimeout, 0, Integer(valLockTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_LockTokens: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_LockTokens, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_LockTokens, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_LockTokens(valLockTokens: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_LockTokens, 0, valLockTokens, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_LockTokens, 0, Integer(PChar(valLockTokens)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_LockType: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_LockType, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_LockType, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_LockType(valLockType: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_LockType, 0, valLockType, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_LockType, 0, Integer(PChar(valLockType)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_NamespaceCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebDAVS_GetINT(m_ctl, PID_WebDAVS_NamespaceCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_NamespaceCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_NamespaceCount(valNamespaceCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetINT(m_ctl, PID_WebDAVS_NamespaceCount, 0, valNamespaceCount, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_NamespaceCount, 0, Integer(valNamespaceCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_NamespacePrefixes(NamespaceIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_NamespacePrefixes, NamespaceIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebDAVS_CheckIndex = nil then exit;
  err :=  _WebDAVS_CheckIndex(m_ctl, PID_WebDAVS_NamespacePrefixes, NamespaceIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for NamespacePrefixes');
	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_NamespacePrefixes, NamespaceIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_NamespacePrefixes(NamespaceIndex: Word; valNamespacePrefixes: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_NamespacePrefixes, NamespaceIndex, valNamespacePrefixes, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_NamespacePrefixes, NamespaceIndex, Integer(PChar(valNamespacePrefixes)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_Namespaces(NamespaceIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_Namespaces, NamespaceIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebDAVS_CheckIndex = nil then exit;
  err :=  _WebDAVS_CheckIndex(m_ctl, PID_WebDAVS_Namespaces, NamespaceIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for Namespaces');
	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_Namespaces, NamespaceIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_Namespaces(NamespaceIndex: Word; valNamespaces: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_Namespaces, NamespaceIndex, valNamespaces, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_Namespaces, NamespaceIndex, Integer(PChar(valNamespaces)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_OtherHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_OtherHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_OtherHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_OtherHeaders(valOtherHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_OtherHeaders, 0, valOtherHeaders, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_OtherHeaders, 0, Integer(PChar(valOtherHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_Password, 0, valPassword, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_PropertyCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebDAVS_GetINT(m_ctl, PID_WebDAVS_PropertyCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_PropertyCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_PropertyCount(valPropertyCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetINT(m_ctl, PID_WebDAVS_PropertyCount, 0, valPropertyCount, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_PropertyCount, 0, Integer(valPropertyCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_PropertyName(PropertyIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_PropertyName, PropertyIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebDAVS_CheckIndex = nil then exit;
  err :=  _WebDAVS_CheckIndex(m_ctl, PID_WebDAVS_PropertyName, PropertyIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for PropertyName');
	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_PropertyName, PropertyIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_PropertyName(PropertyIndex: Word; valPropertyName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_PropertyName, PropertyIndex, valPropertyName, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_PropertyName, PropertyIndex, Integer(PChar(valPropertyName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_PropertyOperation(PropertyIndex: Word): TipswebdavsPropertyOperations;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebdavsPropertyOperations(_WebDAVS_GetENUM(m_ctl, PID_WebDAVS_PropertyOperation, PropertyIndex, err));
{$ELSE}
  result := TipswebdavsPropertyOperations(0);
  if @_WebDAVS_CheckIndex = nil then exit;
  err :=  _WebDAVS_CheckIndex(m_ctl, PID_WebDAVS_PropertyOperation, PropertyIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for PropertyOperation');
	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_PropertyOperation, PropertyIndex, nil);
  result := TipswebdavsPropertyOperations(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_PropertyOperation(PropertyIndex: Word; valPropertyOperation: TipswebdavsPropertyOperations);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetENUM(m_ctl, PID_WebDAVS_PropertyOperation, PropertyIndex, Integer(valPropertyOperation), 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_PropertyOperation, PropertyIndex, Integer(valPropertyOperation), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_PropertyStatus(PropertyIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_PropertyStatus, PropertyIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebDAVS_CheckIndex = nil then exit;
  err :=  _WebDAVS_CheckIndex(m_ctl, PID_WebDAVS_PropertyStatus, PropertyIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for PropertyStatus');
	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_PropertyStatus, PropertyIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebDAVS.get_PropertyValue(PropertyIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_PropertyValue, PropertyIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebDAVS_CheckIndex = nil then exit;
  err :=  _WebDAVS_CheckIndex(m_ctl, PID_WebDAVS_PropertyValue, PropertyIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for PropertyValue');
	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_PropertyValue, PropertyIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_PropertyValue(PropertyIndex: Word; valPropertyValue: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_PropertyValue, PropertyIndex, valPropertyValue, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_PropertyValue, PropertyIndex, Integer(PChar(valPropertyValue)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetBSTR(m_ctl, PID_WebDAVS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebDAVS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetBSTR(m_ctl, PID_WebDAVS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetBSTR(m_ctl, PID_WebDAVS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebDAVS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetBSTR(m_ctl, PID_WebDAVS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetBSTR(m_ctl, PID_WebDAVS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebDAVS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetBSTR(m_ctl, PID_WebDAVS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_SSLCertStoreType: TipswebdavsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebdavsSSLCertStoreTypes(_WebDAVS_GetENUM(m_ctl, PID_WebDAVS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipswebdavsSSLCertStoreTypes(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_SSLCertStoreType, 0, nil);
  result := TipswebdavsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_SSLCertStoreType(valSSLCertStoreType: TipswebdavsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetENUM(m_ctl, PID_WebDAVS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetBSTR(m_ctl, PID_WebDAVS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsWebDAVS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebDAVS.get_StatusLine: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_StatusLine, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_StatusLine, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebDAVS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebDAVS_GetINT(m_ctl, PID_WebDAVS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebDAVS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetINT(m_ctl, PID_WebDAVS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebDAVS.get_TransferredData: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetBSTR(m_ctl, PID_WebDAVS_TransferredData, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_TransferredData, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsWebDAVS.get_TransferredHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_TransferredHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_TransferredHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebDAVS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebDAVS_GetCSTR(m_ctl, PID_WebDAVS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebDAVS_Get = nil then exit;
  tmp := _WebDAVS_Get(m_ctl, PID_WebDAVS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebDAVS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebDAVS_SetCSTR(m_ctl, PID_WebDAVS_User, 0, valUser, 0);
{$ELSE}
	if @_WebDAVS_Set = nil then exit;
  err := _WebDAVS_Set(m_ctl, PID_WebDAVS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsWebDAVS.Config(ConfigurationString: String): String;
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


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsWebDAVS.AddCookie(CookieName: String; CookieValue: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(CookieName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(CookieValue);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_AddCookie, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(CookieName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(CookieValue);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_AddCookie, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.AddNamespace(Prefix: String; NamespaceURI: String);

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


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_AddNamespace, 2, param, paramcb); 

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


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_AddNamespace, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.CopyResource(SourceResourceURI: String; DestinationResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(SourceResourceURI);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(DestinationResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_CopyResource, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(SourceResourceURI);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(DestinationResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_CopyResource, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.DeleteResource(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_DeleteResource, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_DeleteResource, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.DoEvents();

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



  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.FindProperties(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_FindProperties, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_FindProperties, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.FindPropertyNames(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_FindPropertyNames, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_FindPropertyNames, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsWebDAVS.GetProperty(PropertyName: String): String;
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


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_GetProperty, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(PropertyName);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_GetProperty, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsWebDAVS.GetResource(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_GetResource, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_GetResource, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.Interrupt();

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



  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.ListDirectory(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_ListDirectory, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_ListDirectory, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.LockResource(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_LockResource, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_LockResource, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.MakeDirectory(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_MakeDirectory, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_MakeDirectory, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.MoveResource(SourceResourceURI: String; DestinationResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(SourceResourceURI);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(DestinationResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_MoveResource, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(SourceResourceURI);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(DestinationResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_MoveResource, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.PatchProperties(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_PatchProperties, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_PatchProperties, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.PostToResource(ResourceURI: String; PostData: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(PostData);
  paramcb[i] := Length(PostData);

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_PostToResource, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);


  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(PostData);
  paramcb[i] := Length(PostData);

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_PostToResource, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.PutResource(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_PutResource, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_PutResource, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.Reset();

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



  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_Reset, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_Reset, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.SetProperty(PropertyName: String; PropertyValue: String);

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


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_SetProperty, 2, param, paramcb); 

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


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_SetProperty, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebDAVS.UnLockResource(ResourceURI: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_UnLockResource, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ResourceURI);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebDAVS_Do = nil then exit;
  err := _WebDAVS_Do(m_ctl, MID_WebDAVS_UnLockResource, 1, @param, @paramcb); 
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

	_WebDAVS_Create := nil;
	_WebDAVS_Destroy := nil;
	_WebDAVS_Set := nil;
	_WebDAVS_Get := nil;
	_WebDAVS_GetLastError := nil;
	_WebDAVS_StaticInit := nil;
	_WebDAVS_CheckIndex := nil;
	_WebDAVS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_webdavs_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_WebDAVS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'WebDAVS_Create');
		@_WebDAVS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'WebDAVS_Destroy');
		@_WebDAVS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'WebDAVS_Set');
		@_WebDAVS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'WebDAVS_Get');
		@_WebDAVS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'WebDAVS_GetLastError');
		@_WebDAVS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'WebDAVS_CheckIndex');
		@_WebDAVS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'WebDAVS_Do');
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
  @_WebDAVS_Create       := nil;
  @_WebDAVS_Destroy      := nil;
  @_WebDAVS_Set          := nil;
  @_WebDAVS_Get          := nil;
  @_WebDAVS_GetLastError := nil;
  @_WebDAVS_CheckIndex   := nil;
  @_WebDAVS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


{$WARNINGS ON}
{$HINTS ON}
end.




