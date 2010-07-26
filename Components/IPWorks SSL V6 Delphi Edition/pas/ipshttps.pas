
unit ipshttps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipshttpsAuthSchemes = 
(

									 
                   authBasic,

									 
                   authDigest
);
  TipshttpsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipshttpsFollowRedirects = 
(

									 
                   frNever,

									 
                   frAlways,

									 
                   frSameScheme
);
  TipshttpsProxySSLs = 
(

									 
                   psAutomatic,

									 
                   psAlways,

									 
                   psNever,

									 
                   psTunnel
);
  TipshttpsSSLCertStoreTypes = 
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

  TEndTransferEvent = procedure(Sender: TObject;
                            Direction: Integer) of Object;

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

  TStartTransferEvent = procedure(Sender: TObject;
                            Direction: Integer) of Object;

  TStatusEvent = procedure(Sender: TObject;
                            const HTTPVersion: String;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TTransferEvent = procedure(Sender: TObject;
                            Direction: Integer;
                            BytesTransferred: LongInt;
                            Text: String) of Object;
{$IFDEF CLR}
  TTransferEventB = procedure(Sender: TObject;
                            Direction: Integer;
                            BytesTransferred: LongInt;
                            Text: Array of Byte) of Object;

{$ENDIF}

{$IFDEF CLR}
  THTTPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsHTTPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsHTTPS = class(TipsCore)
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
      m_anchor: THTTPSEventHook;
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

      function get_AttachedFile: String;
      procedure set_AttachedFile(valAttachedFile: String);

      function get_Authorization: String;
      procedure set_Authorization(valAuthorization: String);

      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);

      function get_ContentType: String;
      procedure set_ContentType(valContentType: String);

      function get_CookieCount: Integer;
      procedure set_CookieCount(valCookieCount: Integer);

      function get_CookieName(CookieIndex: Word): String;
      procedure set_CookieName(CookieIndex: Word; valCookieName: String);

      function get_CookieValue(CookieIndex: Word): String;
      procedure set_CookieValue(CookieIndex: Word; valCookieValue: String);

      function get_From: String;
      procedure set_From(valFrom: String);

      function get_HTTPMethod: String;
      procedure set_HTTPMethod(valHTTPMethod: String);

      function get_IfModifiedSince: String;
      procedure set_IfModifiedSince(valIfModifiedSince: String);

      function get_OtherHeaders: String;
      procedure set_OtherHeaders(valOtherHeaders: String);

      function get_PostData: String;
      procedure set_StringPostData(valPostData: String);

      function get_Pragma: String;
      procedure set_Pragma(valPragma: String);

      function get_ProxyAuthorization: String;
      procedure set_ProxyAuthorization(valProxyAuthorization: String);

      function get_Referer: String;
      procedure set_Referer(valReferer: String);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);

      function get_StatusLine: String;


      function get_TransferredData: String;


      function get_TransferredHeaders: String;


      function get_URLPath: String;
      procedure set_URLPath(valURLPath: String);

      function get_URLPort: Integer;
      procedure set_URLPort(valURLPort: Integer);

      function get_URLScheme: String;
      procedure set_URLScheme(valURLScheme: String);

      function get_URLServer: String;
      procedure set_URLServer(valURLServer: String);


      procedure TreatErr(Err: integer; const desc: string);


      function get_Accept: String;
      procedure set_Accept(valAccept: String);





      function get_AuthScheme: TipshttpsAuthSchemes;
      procedure set_AuthScheme(valAuthScheme: TipshttpsAuthSchemes);











      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipshttpsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipshttpsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_FollowRedirects: TipshttpsFollowRedirects;
      procedure set_FollowRedirects(valFollowRedirects: TipshttpsFollowRedirects);





      function get_Idle: Boolean;




      function get_LocalFile: String;
      procedure set_LocalFile(valLocalFile: String);

      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);



      function get_Password: String;
      procedure set_Password(valPassword: String);







      function get_ProxyPassword: String;
      procedure set_ProxyPassword(valProxyPassword: String);

      function get_ProxyPort: Integer;
      procedure set_ProxyPort(valProxyPort: Integer);

      function get_ProxyServer: String;
      procedure set_ProxyServer(valProxyServer: String);

      function get_ProxySSL: TipshttpsProxySSLs;
      procedure set_ProxySSL(valProxySSL: TipshttpsProxySSLs);

      function get_ProxyUser: String;
      procedure set_ProxyUser(valProxyUser: String);

      function get_Range: String;
      procedure set_Range(valRange: String);



      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipshttpsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipshttpsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;




      function get_Timeout: Integer;
      procedure set_Timeout(valTimeout: Integer);





      function get_URL: String;
      procedure set_URL(valURL: String);









      function get_User: String;
      procedure set_User(valUser: String);



    public

      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      property OK: String128 read GetOK write SetOK;

{$IFNDEF CLR}
      procedure SetPostData(lpPostData: PChar; lenPostData: Cardinal);
      procedure SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
      procedure SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
      procedure SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
      procedure SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
      procedure SetTransferredData(lpTransferredData: PChar; lenTransferredData: Cardinal);

{$ENDIF}



      property AttachedFile: String
               read get_AttachedFile
               write set_AttachedFile               ;

      property Authorization: String
               read get_Authorization
               write set_Authorization               ;



      property Connected: Boolean
               read get_Connected
               write set_Connected               ;

      property ContentType: String
               read get_ContentType
               write set_ContentType               ;

      property CookieCount: Integer
               read get_CookieCount
               write set_CookieCount               ;

      property CookieName[CookieIndex: Word]: String
               read get_CookieName
               write set_CookieName               ;

      property CookieValue[CookieIndex: Word]: String
               read get_CookieValue
               write set_CookieValue               ;













      property From: String
               read get_From
               write set_From               ;

      property HTTPMethod: String
               read get_HTTPMethod
               write set_HTTPMethod               ;



      property IfModifiedSince: String
               read get_IfModifiedSince
               write set_IfModifiedSince               ;





      property OtherHeaders: String
               read get_OtherHeaders
               write set_OtherHeaders               ;



      property PostData: String
               read get_PostData
               write set_StringPostData               ;

      property Pragma: String
               read get_Pragma
               write set_Pragma               ;

      property ProxyAuthorization: String
               read get_ProxyAuthorization
               write set_ProxyAuthorization               ;













      property Referer: String
               read get_Referer
               write set_Referer               ;



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



      property URLPath: String
               read get_URLPath
               write set_URLPath               ;

      property URLPort: Integer
               read get_URLPort
               write set_URLPort               ;

      property URLScheme: String
               read get_URLScheme
               write set_URLScheme               ;

      property URLServer: String
               read get_URLServer
               write set_URLServer               ;





{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure AddCookie(CookieName: String; CookieValue: String);

      procedure DoEvents();

      procedure Get(URL: String);

      procedure Head(URL: String);

      procedure Interrupt();

      procedure Post(URL: String);

      procedure Put(URL: String);

      procedure ResetHeaders();


{$ENDIF}

    published

      property Accept: String
                   read get_Accept
                   write set_Accept
                   
                   ;


      property AuthScheme: TipshttpsAuthSchemes
                   read get_AuthScheme
                   write set_AuthScheme
                   default authBasic
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
      property FirewallType: TipshttpsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property FollowRedirects: TipshttpsFollowRedirects
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
      property LocalHost: String
                   read get_LocalHost
                   write set_LocalHost
                   stored False

                   ;

      property Password: String
                   read get_Password
                   write set_Password
                   
                   ;



      property ProxyPassword: String
                   read get_ProxyPassword
                   write set_ProxyPassword
                   
                   ;
      property ProxyPort: Integer
                   read get_ProxyPort
                   write set_ProxyPort
                   default 80
                   ;
      property ProxyServer: String
                   read get_ProxyServer
                   write set_ProxyServer
                   
                   ;
      property ProxySSL: TipshttpsProxySSLs
                   read get_ProxySSL
                   write set_ProxySSL
                   default psAutomatic
                   ;
      property ProxyUser: String
                   read get_ProxyUser
                   write set_ProxyUser
                   
                   ;
      property Range: String
                   read get_Range
                   write set_Range
                   
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
      property SSLCertStoreType: TipshttpsSSLCertStoreTypes
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


      property URL: String
                   read get_URL
                   write set_URL
                   
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
    PID_HTTPS_Accept = 1;
    PID_HTTPS_AttachedFile = 2;
    PID_HTTPS_Authorization = 3;
    PID_HTTPS_AuthScheme = 4;
    PID_HTTPS_Connected = 5;
    PID_HTTPS_ContentType = 6;
    PID_HTTPS_CookieCount = 7;
    PID_HTTPS_CookieName = 8;
    PID_HTTPS_CookieValue = 9;
    PID_HTTPS_FirewallHost = 10;
    PID_HTTPS_FirewallPassword = 11;
    PID_HTTPS_FirewallPort = 12;
    PID_HTTPS_FirewallType = 13;
    PID_HTTPS_FirewallUser = 14;
    PID_HTTPS_FollowRedirects = 15;
    PID_HTTPS_From = 16;
    PID_HTTPS_HTTPMethod = 17;
    PID_HTTPS_Idle = 18;
    PID_HTTPS_IfModifiedSince = 19;
    PID_HTTPS_LocalFile = 20;
    PID_HTTPS_LocalHost = 21;
    PID_HTTPS_OtherHeaders = 22;
    PID_HTTPS_Password = 23;
    PID_HTTPS_PostData = 24;
    PID_HTTPS_Pragma = 25;
    PID_HTTPS_ProxyAuthorization = 26;
    PID_HTTPS_ProxyPassword = 27;
    PID_HTTPS_ProxyPort = 28;
    PID_HTTPS_ProxyServer = 29;
    PID_HTTPS_ProxySSL = 30;
    PID_HTTPS_ProxyUser = 31;
    PID_HTTPS_Range = 32;
    PID_HTTPS_Referer = 33;
    PID_HTTPS_SSLAcceptServerCert = 34;
    PID_HTTPS_SSLCertEncoded = 35;
    PID_HTTPS_SSLCertStore = 36;
    PID_HTTPS_SSLCertStorePassword = 37;
    PID_HTTPS_SSLCertStoreType = 38;
    PID_HTTPS_SSLCertSubject = 39;
    PID_HTTPS_SSLServerCert = 40;
    PID_HTTPS_SSLServerCertStatus = 41;
    PID_HTTPS_StatusLine = 42;
    PID_HTTPS_Timeout = 43;
    PID_HTTPS_TransferredData = 44;
    PID_HTTPS_TransferredHeaders = 45;
    PID_HTTPS_URL = 46;
    PID_HTTPS_URLPath = 47;
    PID_HTTPS_URLPort = 48;
    PID_HTTPS_URLScheme = 49;
    PID_HTTPS_URLServer = 50;
    PID_HTTPS_User = 51;

    EID_HTTPS_Connected = 1;
    EID_HTTPS_ConnectionStatus = 2;
    EID_HTTPS_Disconnected = 3;
    EID_HTTPS_EndTransfer = 4;
    EID_HTTPS_Error = 5;
    EID_HTTPS_Header = 6;
    EID_HTTPS_Redirect = 7;
    EID_HTTPS_SetCookie = 8;
    EID_HTTPS_SSLServerAuthentication = 9;
    EID_HTTPS_SSLStatus = 10;
    EID_HTTPS_StartTransfer = 11;
    EID_HTTPS_Status = 12;
    EID_HTTPS_Transfer = 13;


    MID_HTTPS_Config = 1;
    MID_HTTPS_AddCookie = 2;
    MID_HTTPS_DoEvents = 3;
    MID_HTTPS_Get = 4;
    MID_HTTPS_Head = 5;
    MID_HTTPS_Interrupt = 6;
    MID_HTTPS_Post = 7;
    MID_HTTPS_Put = 8;
    MID_HTTPS_ResetHeaders = 9;




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
{$R 'ipshttps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsHTTPS; event_id: Integer; cparam: Integer; 
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
  _HTTPS_Create:        function(pMethod: PEventHandle; pObject: TipsHTTPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTTPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTTPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTTPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTTPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTTPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTTPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTTPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Create')]
  function _HTTPS_Create       (pMethod: THTTPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Destroy')]
  function _HTTPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Set')]
  function _HTTPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Set')]
  function _HTTPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Set')]
  function _HTTPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Set')]
  function _HTTPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Set')]
  function _HTTPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Set')]
  function _HTTPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Get')]
  function _HTTPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Get')]
  function _HTTPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Get')]
  function _HTTPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Get')]
  function _HTTPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Get')]
  function _HTTPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Get')]
  function _HTTPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_GetLastError')]
  function _HTTPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_StaticInit')]
  function _HTTPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_CheckIndex')]
  function _HTTPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTTPS_Do')]
  function _HTTPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _HTTPS_Create       (pMethod: PEventHandle; pObject: TipsHTTPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTTPS_Create';
  function _HTTPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTTPS_Destroy';
  function _HTTPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTTPS_Set';
  function _HTTPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTTPS_Get';
  function _HTTPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTTPS_GetLastError';
  function _HTTPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTTPS_StaticInit';
  function _HTTPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTTPS_CheckIndex';
  function _HTTPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTTPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsHTTPS; event_id: Integer;
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
    tmp_EndTransferDirection: Integer;
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
    tmp_StartTransferDirection: Integer;
    tmp_StatusHTTPVersion: String;
    tmp_StatusStatusCode: Integer;
    tmp_StatusDescription: String;
    tmp_TransferDirection: Integer;
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

      EID_HTTPS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_HTTPS_ConnectionStatus:
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
      EID_HTTPS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_HTTPS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}
          tmp_EndTransferDirection := Integer(params^[0]);

          lpContext.FOnEndTransfer(lpContext, tmp_EndTransferDirection);


        end;
      end;
      EID_HTTPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_HTTPS_Header:
      begin
        if Assigned(lpContext.FOnHeader) then
        begin
          {assign temporary variables}
          tmp_HeaderField := AnsiString(PChar(params^[0]));

          tmp_HeaderValue := AnsiString(PChar(params^[1]));


          lpContext.FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



        end;
      end;
      EID_HTTPS_Redirect:
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
      EID_HTTPS_SetCookie:
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
      EID_HTTPS_SSLServerAuthentication:
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
      EID_HTTPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_HTTPS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}
          tmp_StartTransferDirection := Integer(params^[0]);

          lpContext.FOnStartTransfer(lpContext, tmp_StartTransferDirection);


        end;
      end;
      EID_HTTPS_Status:
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
      EID_HTTPS_Transfer:
      begin
        if Assigned(lpContext.FOnTransfer) then
        begin
          {assign temporary variables}
          tmp_TransferDirection := Integer(params^[0]);
          tmp_TransferBytesTransferred := LongInt(params^[1]);
          SetString(tmp_TransferText, PChar(params^[2]), cbparam^[2]);


          lpContext.FOnTransfer(lpContext, tmp_TransferDirection, tmp_TransferBytesTransferred, tmp_TransferText);




        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsHTTPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
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

  tmp_EndTransferDirection: Integer;

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

  tmp_StartTransferDirection: Integer;

  tmp_StatusHTTPVersion: String;
  tmp_StatusStatusCode: Integer;
  tmp_StatusDescription: String;

  tmp_TransferDirection: Integer;
  tmp_TransferBytesTransferred: LongInt;
  tmp_TransferText: String;

  tmp_TransferTextB: Array of Byte;

begin
 	p := nil;
  case event_id of
    EID_HTTPS_Connected:
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
    EID_HTTPS_ConnectionStatus:
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
    EID_HTTPS_Disconnected:
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
    EID_HTTPS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_EndTransferDirection := Marshal.ReadInt32(params, 4*0);

        FOnEndTransfer(lpContext, tmp_EndTransferDirection);


      end;


    end;
    EID_HTTPS_Error:
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
    EID_HTTPS_Header:
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
    EID_HTTPS_Redirect:
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
    EID_HTTPS_SetCookie:
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
    EID_HTTPS_SSLServerAuthentication:
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
    EID_HTTPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_HTTPS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_StartTransferDirection := Marshal.ReadInt32(params, 4*0);

        FOnStartTransfer(lpContext, tmp_StartTransferDirection);


      end;


    end;
    EID_HTTPS_Status:
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
    EID_HTTPS_Transfer:
    begin
      if Assigned(FOnTransfer) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_TransferDirection := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_TransferBytesTransferred := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_TransferText := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*2));


        FOnTransfer(lpContext, tmp_TransferDirection, tmp_TransferBytesTransferred, tmp_TransferText);




      end;

      if Assigned(FOnTransferB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_TransferDirection := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_TransferBytesTransferred := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        SetLength(tmp_TransferTextB, Marshal.ReadInt32(cbparam, 4 * 2)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 2), tmp_TransferTextB,
        						 0, Length(tmp_TransferTextB));


        FOnTransferB(lpContext, tmp_TransferDirection, tmp_TransferBytesTransferred, tmp_TransferTextB);




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
    RegisterComponents('IP*Works! SSL', [TipsHTTPS]);
end;

constructor TipsHTTPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _HTTPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_HTTPS_Create <> nil then
      m_ctl := _HTTPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL HTTPS: Error creating component');

{$IFDEF CLR}
    _HTTPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_18, 0);
{$ELSE}
    _HTTPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_18)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_HTTPS_Do <> nil then
      _HTTPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_Accept('') except on E:Exception do end;
    try set_AuthScheme(authBasic) except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_FollowRedirects(frNever) except on E:Exception do end;
    try set_LocalFile('') except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_ProxyPassword('') except on E:Exception do end;
    try set_ProxyPort(80) except on E:Exception do end;
    try set_ProxyServer('') except on E:Exception do end;
    try set_ProxySSL(psAutomatic) except on E:Exception do end;
    try set_ProxyUser('') except on E:Exception do end;
    try set_Range('') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_URL('') except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsHTTPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_HTTPS_Destroy <> nil then{$ENDIF}
      	_HTTPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsHTTPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsHTTPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsHTTPS.AboutDlg;
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
	if @_HTTPS_Do <> nil then
{$ENDIF}
		_HTTPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsHTTPS.SetOK(key: String128);
begin
end;

function TipsHTTPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsHTTPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsHTTPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsHTTPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsHTTPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsHTTPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_HTTPS_GetLastError <> nil then{$ENDIF}
      msg := _HTTPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsHTTPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_HTTPS_Do <> nil then
      _HTTPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsHTTPS.SetPostData(lpPostData: PChar; lenPostData: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTTPS_Set = nil then exit;{$ENDIF}
  err := _HTTPS_Set(m_ctl, PID_HTTPS_PostData, 0, Integer(lpPostData), lenPostData);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsHTTPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTTPS_Set = nil then exit;{$ENDIF}
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsHTTPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTTPS_Set = nil then exit;{$ENDIF}
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsHTTPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTTPS_Set = nil then exit;{$ENDIF}
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsHTTPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTTPS_Set = nil then exit;{$ENDIF}
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsHTTPS.SetTransferredData(lpTransferredData: PChar; lenTransferredData: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTTPS_Set = nil then exit;{$ENDIF}
  err := _HTTPS_Set(m_ctl, PID_HTTPS_TransferredData, 0, Integer(lpTransferredData), lenTransferredData);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsHTTPS.get_Accept: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_Accept, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Accept, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_Accept(valAccept: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_Accept, 0, valAccept, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_Accept, 0, Integer(PChar(valAccept)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_AttachedFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_AttachedFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_AttachedFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_AttachedFile(valAttachedFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_AttachedFile, 0, valAttachedFile, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_AttachedFile, 0, Integer(PChar(valAttachedFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_Authorization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_Authorization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Authorization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_Authorization(valAuthorization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_Authorization, 0, valAuthorization, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_Authorization, 0, Integer(PChar(valAuthorization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_AuthScheme: TipshttpsAuthSchemes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshttpsAuthSchemes(_HTTPS_GetENUM(m_ctl, PID_HTTPS_AuthScheme, 0, err));
{$ELSE}
  result := TipshttpsAuthSchemes(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_AuthScheme, 0, nil);
  result := TipshttpsAuthSchemes(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_AuthScheme(valAuthScheme: TipshttpsAuthSchemes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetENUM(m_ctl, PID_HTTPS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_HTTPS_GetBOOL(m_ctl, PID_HTTPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetBOOL(m_ctl, PID_HTTPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_ContentType: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_ContentType, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_ContentType, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_ContentType(valContentType: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_ContentType, 0, valContentType, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_ContentType, 0, Integer(PChar(valContentType)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_CookieCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTTPS_GetINT(m_ctl, PID_HTTPS_CookieCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_CookieCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_CookieCount(valCookieCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetINT(m_ctl, PID_HTTPS_CookieCount, 0, valCookieCount, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_CookieCount, 0, Integer(valCookieCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_CookieName(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_CookieName, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_HTTPS_CheckIndex = nil then exit;
  err :=  _HTTPS_CheckIndex(m_ctl, PID_HTTPS_CookieName, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieName');
	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_CookieName, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_CookieName(CookieIndex: Word; valCookieName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_CookieName, CookieIndex, valCookieName, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_CookieName, CookieIndex, Integer(PChar(valCookieName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_CookieValue(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_CookieValue, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_HTTPS_CheckIndex = nil then exit;
  err :=  _HTTPS_CheckIndex(m_ctl, PID_HTTPS_CookieValue, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieValue');
	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_CookieValue, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_CookieValue(CookieIndex: Word; valCookieValue: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_CookieValue, CookieIndex, valCookieValue, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_CookieValue, CookieIndex, Integer(PChar(valCookieValue)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTTPS_GetLONG(m_ctl, PID_HTTPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetLONG(m_ctl, PID_HTTPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_FirewallType: TipshttpsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshttpsFirewallTypes(_HTTPS_GetENUM(m_ctl, PID_HTTPS_FirewallType, 0, err));
{$ELSE}
  result := TipshttpsFirewallTypes(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_FirewallType, 0, nil);
  result := TipshttpsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_FirewallType(valFirewallType: TipshttpsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetENUM(m_ctl, PID_HTTPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_FollowRedirects: TipshttpsFollowRedirects;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshttpsFollowRedirects(_HTTPS_GetENUM(m_ctl, PID_HTTPS_FollowRedirects, 0, err));
{$ELSE}
  result := TipshttpsFollowRedirects(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_FollowRedirects, 0, nil);
  result := TipshttpsFollowRedirects(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_FollowRedirects(valFollowRedirects: TipshttpsFollowRedirects);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetENUM(m_ctl, PID_HTTPS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_From: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_From, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_From, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_From(valFrom: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_From, 0, valFrom, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_From, 0, Integer(PChar(valFrom)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_HTTPMethod: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_HTTPMethod, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_HTTPMethod, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_HTTPMethod(valHTTPMethod: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_HTTPMethod, 0, valHTTPMethod, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_HTTPMethod, 0, Integer(PChar(valHTTPMethod)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_HTTPS_GetBOOL(m_ctl, PID_HTTPS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsHTTPS.get_IfModifiedSince: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_IfModifiedSince, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_IfModifiedSince, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_IfModifiedSince(valIfModifiedSince: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_IfModifiedSince, 0, valIfModifiedSince, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_IfModifiedSince, 0, Integer(PChar(valIfModifiedSince)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_LocalFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_LocalFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_LocalFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_LocalFile(valLocalFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_LocalFile, 0, valLocalFile, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_LocalFile, 0, Integer(PChar(valLocalFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_OtherHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_OtherHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_OtherHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_OtherHeaders(valOtherHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_OtherHeaders, 0, valOtherHeaders, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_OtherHeaders, 0, Integer(PChar(valOtherHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_PostData: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetBSTR(m_ctl, PID_HTTPS_PostData, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_PostData, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsHTTPS.set_StringPostData(valPostData: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetBSTR(m_ctl, PID_HTTPS_PostData, 0, valPostData, Length(valPostData));

{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_PostData, 0, Integer(PChar(valPostData)), Length(valPostData));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_Pragma: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_Pragma, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Pragma, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_Pragma(valPragma: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_Pragma, 0, valPragma, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_Pragma, 0, Integer(PChar(valPragma)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_ProxyAuthorization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_ProxyAuthorization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_ProxyAuthorization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_ProxyAuthorization(valProxyAuthorization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_ProxyAuthorization, 0, valProxyAuthorization, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_ProxyAuthorization, 0, Integer(PChar(valProxyAuthorization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_ProxyPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_ProxyPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_ProxyPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_ProxyPassword(valProxyPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_ProxyPassword, 0, valProxyPassword, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_ProxyPassword, 0, Integer(PChar(valProxyPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_ProxyPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTTPS_GetLONG(m_ctl, PID_HTTPS_ProxyPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_ProxyPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_ProxyPort(valProxyPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetLONG(m_ctl, PID_HTTPS_ProxyPort, 0, valProxyPort, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_ProxyPort, 0, Integer(valProxyPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_ProxyServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_ProxyServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_ProxyServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_ProxyServer(valProxyServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_ProxyServer, 0, valProxyServer, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_ProxyServer, 0, Integer(PChar(valProxyServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_ProxySSL: TipshttpsProxySSLs;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshttpsProxySSLs(_HTTPS_GetENUM(m_ctl, PID_HTTPS_ProxySSL, 0, err));
{$ELSE}
  result := TipshttpsProxySSLs(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_ProxySSL, 0, nil);
  result := TipshttpsProxySSLs(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_ProxySSL(valProxySSL: TipshttpsProxySSLs);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetENUM(m_ctl, PID_HTTPS_ProxySSL, 0, Integer(valProxySSL), 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_ProxySSL, 0, Integer(valProxySSL), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_ProxyUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_ProxyUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_ProxyUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_ProxyUser(valProxyUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_ProxyUser, 0, valProxyUser, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_ProxyUser, 0, Integer(PChar(valProxyUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_Range: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_Range, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Range, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_Range(valRange: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_Range, 0, valRange, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_Range, 0, Integer(PChar(valRange)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_Referer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_Referer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Referer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_Referer(valReferer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_Referer, 0, valReferer, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_Referer, 0, Integer(PChar(valReferer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetBSTR(m_ctl, PID_HTTPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsHTTPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetBSTR(m_ctl, PID_HTTPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetBSTR(m_ctl, PID_HTTPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsHTTPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetBSTR(m_ctl, PID_HTTPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetBSTR(m_ctl, PID_HTTPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsHTTPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetBSTR(m_ctl, PID_HTTPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_SSLCertStoreType: TipshttpsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshttpsSSLCertStoreTypes(_HTTPS_GetENUM(m_ctl, PID_HTTPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipshttpsSSLCertStoreTypes(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_SSLCertStoreType, 0, nil);
  result := TipshttpsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_SSLCertStoreType(valSSLCertStoreType: TipshttpsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetENUM(m_ctl, PID_HTTPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetBSTR(m_ctl, PID_HTTPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsHTTPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsHTTPS.get_StatusLine: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_StatusLine, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_StatusLine, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsHTTPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTTPS_GetINT(m_ctl, PID_HTTPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetINT(m_ctl, PID_HTTPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_TransferredData: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetBSTR(m_ctl, PID_HTTPS_TransferredData, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_TransferredData, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsHTTPS.get_TransferredHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_TransferredHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_TransferredHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsHTTPS.get_URL: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_URL, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_URL, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_URL(valURL: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_URL, 0, valURL, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_URL, 0, Integer(PChar(valURL)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_URLPath: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_URLPath, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_URLPath, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_URLPath(valURLPath: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_URLPath, 0, valURLPath, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_URLPath, 0, Integer(PChar(valURLPath)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_URLPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTTPS_GetLONG(m_ctl, PID_HTTPS_URLPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_URLPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTTPS.set_URLPort(valURLPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetLONG(m_ctl, PID_HTTPS_URLPort, 0, valURLPort, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_URLPort, 0, Integer(valURLPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_URLScheme: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_URLScheme, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_URLScheme, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_URLScheme(valURLScheme: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_URLScheme, 0, valURLScheme, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_URLScheme, 0, Integer(PChar(valURLScheme)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_URLServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_URLServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_URLServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_URLServer(valURLServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_URLServer, 0, valURLServer, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_URLServer, 0, Integer(PChar(valURLServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTTPS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTTPS_GetCSTR(m_ctl, PID_HTTPS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTTPS_Get = nil then exit;
  tmp := _HTTPS_Get(m_ctl, PID_HTTPS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTTPS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTTPS_SetCSTR(m_ctl, PID_HTTPS_User, 0, valUser, 0);
{$ELSE}
	if @_HTTPS_Set = nil then exit;
  err := _HTTPS_Set(m_ctl, PID_HTTPS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsHTTPS.Config(ConfigurationString: String): String;
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


  err := _HTTPS_Do(m_ctl, MID_HTTPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsHTTPS.AddCookie(CookieName: String; CookieValue: String);

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


  err := _HTTPS_Do(m_ctl, MID_HTTPS_AddCookie, 2, param, paramcb); 

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


	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_AddCookie, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTTPS.DoEvents();

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



  err := _HTTPS_Do(m_ctl, MID_HTTPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTTPS.Get(URL: String);

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


  err := _HTTPS_Do(m_ctl, MID_HTTPS_Get, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_Get, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTTPS.Head(URL: String);

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


  err := _HTTPS_Do(m_ctl, MID_HTTPS_Head, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_Head, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTTPS.Interrupt();

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



  err := _HTTPS_Do(m_ctl, MID_HTTPS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTTPS.Post(URL: String);

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


  err := _HTTPS_Do(m_ctl, MID_HTTPS_Post, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_Post, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTTPS.Put(URL: String);

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


  err := _HTTPS_Do(m_ctl, MID_HTTPS_Put, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_Put, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTTPS.ResetHeaders();

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



  err := _HTTPS_Do(m_ctl, MID_HTTPS_ResetHeaders, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTTPS_Do = nil then exit;
  err := _HTTPS_Do(m_ctl, MID_HTTPS_ResetHeaders, 0, @param, @paramcb); 
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

	_HTTPS_Create := nil;
	_HTTPS_Destroy := nil;
	_HTTPS_Set := nil;
	_HTTPS_Get := nil;
	_HTTPS_GetLastError := nil;
	_HTTPS_StaticInit := nil;
	_HTTPS_CheckIndex := nil;
	_HTTPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_https_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_HTTPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'HTTPS_Create');
		@_HTTPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'HTTPS_Destroy');
		@_HTTPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'HTTPS_Set');
		@_HTTPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'HTTPS_Get');
		@_HTTPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'HTTPS_GetLastError');
		@_HTTPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'HTTPS_CheckIndex');
		@_HTTPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'HTTPS_Do');
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
  @_HTTPS_Create       := nil;
  @_HTTPS_Destroy      := nil;
  @_HTTPS_Set          := nil;
  @_HTTPS_Get          := nil;
  @_HTTPS_GetLastError := nil;
  @_HTTPS_CheckIndex   := nil;
  @_HTTPS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




