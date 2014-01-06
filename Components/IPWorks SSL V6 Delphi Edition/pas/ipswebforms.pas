
unit ipswebforms;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipswebformsAuthSchemes = 
(

									 
                   authBasic,

									 
                   authDigest
);
  TipswebformsEncodings = 
(

									 
                   encURLEncoding,

									 
                   encMultipartFormData,

									 
                   encQueryString
);
  TipswebformsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipswebformsFollowRedirects = 
(

									 
                   frNever,

									 
                   frAlways,

									 
                   frSameScheme
);
  TipswebformsProxySSLs = 
(

									 
                   psAutomatic,

									 
                   psAlways,

									 
                   psNever,

									 
                   psTunnel
);
  TipswebformsSSLCertStoreTypes = 
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
  TWebFormSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsWebFormS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsWebFormS = class(TipsCore)
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
      m_anchor: TWebFormSEventHook;
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

      function get_FormVarCount: Integer;
      procedure set_FormVarCount(valFormVarCount: Integer);

      function get_FormVarNames(VarIndex: Word): String;
      procedure set_FormVarNames(VarIndex: Word; valFormVarNames: String);

      function get_FormVarValues(VarIndex: Word): String;
      procedure set_FormVarValues(VarIndex: Word; valFormVarValues: String);

      function get_From: String;
      procedure set_From(valFrom: String);

      function get_OtherHeaders: String;
      procedure set_OtherHeaders(valOtherHeaders: String);

      function get_ProxyAuthorization: String;
      procedure set_ProxyAuthorization(valProxyAuthorization: String);

      function get_Referer: String;
      procedure set_Referer(valReferer: String);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);

      function get_StatusLine: String;


      function get_TransferredData: String;


      function get_TransferredHeaders: String;



      procedure TreatErr(Err: integer; const desc: string);


      function get_Accept: String;
      procedure set_Accept(valAccept: String);



      function get_AuthScheme: TipswebformsAuthSchemes;
      procedure set_AuthScheme(valAuthScheme: TipswebformsAuthSchemes);











      function get_Encoding: TipswebformsEncodings;
      procedure set_Encoding(valEncoding: TipswebformsEncodings);

      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipswebformsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipswebformsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_FollowRedirects: TipswebformsFollowRedirects;
      procedure set_FollowRedirects(valFollowRedirects: TipswebformsFollowRedirects);









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

      function get_ProxySSL: TipswebformsProxySSLs;
      procedure set_ProxySSL(valProxySSL: TipswebformsProxySSLs);

      function get_ProxyUser: String;
      procedure set_ProxyUser(valProxyUser: String);



      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipswebformsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipswebformsSSLCertStoreTypes);

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
      procedure SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
      procedure SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
      procedure SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
      procedure SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
      procedure SetTransferredData(lpTransferredData: PChar; lenTransferredData: Cardinal);

{$ENDIF}



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















      property FormVarCount: Integer
               read get_FormVarCount
               write set_FormVarCount               ;

      property FormVarNames[VarIndex: Word]: String
               read get_FormVarNames
               write set_FormVarNames               ;

      property FormVarValues[VarIndex: Word]: String
               read get_FormVarValues
               write set_FormVarValues               ;

      property From: String
               read get_From
               write set_From               ;







      property OtherHeaders: String
               read get_OtherHeaders
               write set_OtherHeaders               ;



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







{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure AddCookie(CookieName: String; CookieValue: String);

      procedure AddFormVar(VarName: String; VarValue: String);

      procedure DoEvents();

      procedure Interrupt();

      procedure Reset();

      procedure Submit();

      procedure SubmitTo(URL: String);


{$ENDIF}

    published

      property Accept: String
                   read get_Accept
                   write set_Accept
                   
                   ;

      property AuthScheme: TipswebformsAuthSchemes
                   read get_AuthScheme
                   write set_AuthScheme
                   default authBasic
                   ;





      property Encoding: TipswebformsEncodings
                   read get_Encoding
                   write set_Encoding
                   default encURLEncoding
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
      property FirewallType: TipswebformsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property FollowRedirects: TipswebformsFollowRedirects
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
      property ProxySSL: TipswebformsProxySSLs
                   read get_ProxySSL
                   write set_ProxySSL
                   default psAutomatic
                   ;
      property ProxyUser: String
                   read get_ProxyUser
                   write set_ProxyUser
                   
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
      property SSLCertStoreType: TipswebformsSSLCertStoreTypes
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
    PID_WebFormS_Accept = 1;
    PID_WebFormS_Authorization = 2;
    PID_WebFormS_AuthScheme = 3;
    PID_WebFormS_Connected = 4;
    PID_WebFormS_ContentType = 5;
    PID_WebFormS_CookieCount = 6;
    PID_WebFormS_CookieName = 7;
    PID_WebFormS_CookieValue = 8;
    PID_WebFormS_Encoding = 9;
    PID_WebFormS_FirewallHost = 10;
    PID_WebFormS_FirewallPassword = 11;
    PID_WebFormS_FirewallPort = 12;
    PID_WebFormS_FirewallType = 13;
    PID_WebFormS_FirewallUser = 14;
    PID_WebFormS_FollowRedirects = 15;
    PID_WebFormS_FormVarCount = 16;
    PID_WebFormS_FormVarNames = 17;
    PID_WebFormS_FormVarValues = 18;
    PID_WebFormS_From = 19;
    PID_WebFormS_Idle = 20;
    PID_WebFormS_LocalFile = 21;
    PID_WebFormS_LocalHost = 22;
    PID_WebFormS_OtherHeaders = 23;
    PID_WebFormS_Password = 24;
    PID_WebFormS_ProxyAuthorization = 25;
    PID_WebFormS_ProxyPassword = 26;
    PID_WebFormS_ProxyPort = 27;
    PID_WebFormS_ProxyServer = 28;
    PID_WebFormS_ProxySSL = 29;
    PID_WebFormS_ProxyUser = 30;
    PID_WebFormS_Referer = 31;
    PID_WebFormS_SSLAcceptServerCert = 32;
    PID_WebFormS_SSLCertEncoded = 33;
    PID_WebFormS_SSLCertStore = 34;
    PID_WebFormS_SSLCertStorePassword = 35;
    PID_WebFormS_SSLCertStoreType = 36;
    PID_WebFormS_SSLCertSubject = 37;
    PID_WebFormS_SSLServerCert = 38;
    PID_WebFormS_SSLServerCertStatus = 39;
    PID_WebFormS_StatusLine = 40;
    PID_WebFormS_Timeout = 41;
    PID_WebFormS_TransferredData = 42;
    PID_WebFormS_TransferredHeaders = 43;
    PID_WebFormS_URL = 44;
    PID_WebFormS_User = 45;

    EID_WebFormS_Connected = 1;
    EID_WebFormS_ConnectionStatus = 2;
    EID_WebFormS_Disconnected = 3;
    EID_WebFormS_EndTransfer = 4;
    EID_WebFormS_Error = 5;
    EID_WebFormS_Header = 6;
    EID_WebFormS_Redirect = 7;
    EID_WebFormS_SetCookie = 8;
    EID_WebFormS_SSLServerAuthentication = 9;
    EID_WebFormS_SSLStatus = 10;
    EID_WebFormS_StartTransfer = 11;
    EID_WebFormS_Status = 12;
    EID_WebFormS_Transfer = 13;


    MID_WebFormS_Config = 1;
    MID_WebFormS_AddCookie = 2;
    MID_WebFormS_AddFormVar = 3;
    MID_WebFormS_DoEvents = 4;
    MID_WebFormS_Interrupt = 5;
    MID_WebFormS_Reset = 6;
    MID_WebFormS_Submit = 7;
    MID_WebFormS_SubmitTo = 8;




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
{$R 'ipswebforms.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsWebFormS; event_id: Integer; cparam: Integer; 
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
  _WebFormS_Create:        function(pMethod: PEventHandle; pObject: TipsWebFormS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebFormS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebFormS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebFormS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebFormS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebFormS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebFormS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebFormS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Create')]
  function _WebFormS_Create       (pMethod: TWebFormSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Destroy')]
  function _WebFormS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Set')]
  function _WebFormS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Set')]
  function _WebFormS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Set')]
  function _WebFormS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Set')]
  function _WebFormS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Set')]
  function _WebFormS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Set')]
  function _WebFormS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Get')]
  function _WebFormS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Get')]
  function _WebFormS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Get')]
  function _WebFormS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Get')]
  function _WebFormS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Get')]
  function _WebFormS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Get')]
  function _WebFormS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_GetLastError')]
  function _WebFormS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_StaticInit')]
  function _WebFormS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_CheckIndex')]
  function _WebFormS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebFormS_Do')]
  function _WebFormS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _WebFormS_Create       (pMethod: PEventHandle; pObject: TipsWebFormS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebFormS_Create';
  function _WebFormS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebFormS_Destroy';
  function _WebFormS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebFormS_Set';
  function _WebFormS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebFormS_Get';
  function _WebFormS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebFormS_GetLastError';
  function _WebFormS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebFormS_StaticInit';
  function _WebFormS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebFormS_CheckIndex';
  function _WebFormS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebFormS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsWebFormS; event_id: Integer;
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

      EID_WebFormS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_WebFormS_ConnectionStatus:
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
      EID_WebFormS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_WebFormS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_WebFormS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_WebFormS_Header:
      begin
        if Assigned(lpContext.FOnHeader) then
        begin
          {assign temporary variables}
          tmp_HeaderField := AnsiString(PChar(params^[0]));

          tmp_HeaderValue := AnsiString(PChar(params^[1]));


          lpContext.FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



        end;
      end;
      EID_WebFormS_Redirect:
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
      EID_WebFormS_SetCookie:
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
      EID_WebFormS_SSLServerAuthentication:
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
      EID_WebFormS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_WebFormS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_WebFormS_Status:
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
      EID_WebFormS_Transfer:
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
function TipsWebFormS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
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
    EID_WebFormS_Connected:
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
    EID_WebFormS_ConnectionStatus:
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
    EID_WebFormS_Disconnected:
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
    EID_WebFormS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_WebFormS_Error:
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
    EID_WebFormS_Header:
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
    EID_WebFormS_Redirect:
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
    EID_WebFormS_SetCookie:
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
    EID_WebFormS_SSLServerAuthentication:
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
    EID_WebFormS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_WebFormS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_WebFormS_Status:
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
    EID_WebFormS_Transfer:
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
    RegisterComponents('IP*Works! SSL', [TipsWebFormS]);
end;

constructor TipsWebFormS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _WebFormS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_WebFormS_Create <> nil then
      m_ctl := _WebFormS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL WebFormS: Error creating component');

{$IFDEF CLR}
    _WebFormS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_49, 0);
{$ELSE}
    _WebFormS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_49)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_WebFormS_Do <> nil then
      _WebFormS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_Accept('') except on E:Exception do end;
    try set_AuthScheme(authBasic) except on E:Exception do end;
    try set_Encoding(encURLEncoding) except on E:Exception do end;
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
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_URL('') except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsWebFormS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_WebFormS_Destroy <> nil then{$ENDIF}
      	_WebFormS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsWebFormS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsWebFormS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsWebFormS.AboutDlg;
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
	if @_WebFormS_Do <> nil then
{$ENDIF}
		_WebFormS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsWebFormS.SetOK(key: String128);
begin
end;

function TipsWebFormS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsWebFormS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsWebFormS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsWebFormS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsWebFormS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsWebFormS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_WebFormS_GetLastError <> nil then{$ENDIF}
      msg := _WebFormS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsWebFormS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_WebFormS_Do <> nil then
      _WebFormS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsWebFormS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebFormS_Set = nil then exit;{$ENDIF}
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebFormS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebFormS_Set = nil then exit;{$ENDIF}
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebFormS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebFormS_Set = nil then exit;{$ENDIF}
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebFormS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebFormS_Set = nil then exit;{$ENDIF}
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebFormS.SetTransferredData(lpTransferredData: PChar; lenTransferredData: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebFormS_Set = nil then exit;{$ENDIF}
  err := _WebFormS_Set(m_ctl, PID_WebFormS_TransferredData, 0, Integer(lpTransferredData), lenTransferredData);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsWebFormS.get_Accept: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_Accept, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_Accept, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_Accept(valAccept: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_Accept, 0, valAccept, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_Accept, 0, Integer(PChar(valAccept)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_Authorization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_Authorization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_Authorization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_Authorization(valAuthorization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_Authorization, 0, valAuthorization, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_Authorization, 0, Integer(PChar(valAuthorization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_AuthScheme: TipswebformsAuthSchemes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebformsAuthSchemes(_WebFormS_GetENUM(m_ctl, PID_WebFormS_AuthScheme, 0, err));
{$ELSE}
  result := TipswebformsAuthSchemes(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_AuthScheme, 0, nil);
  result := TipswebformsAuthSchemes(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_AuthScheme(valAuthScheme: TipswebformsAuthSchemes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetENUM(m_ctl, PID_WebFormS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_WebFormS_GetBOOL(m_ctl, PID_WebFormS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetBOOL(m_ctl, PID_WebFormS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_ContentType: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_ContentType, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_ContentType, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_ContentType(valContentType: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_ContentType, 0, valContentType, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_ContentType, 0, Integer(PChar(valContentType)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_CookieCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebFormS_GetINT(m_ctl, PID_WebFormS_CookieCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_CookieCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_CookieCount(valCookieCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetINT(m_ctl, PID_WebFormS_CookieCount, 0, valCookieCount, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_CookieCount, 0, Integer(valCookieCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_CookieName(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_CookieName, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebFormS_CheckIndex = nil then exit;
  err :=  _WebFormS_CheckIndex(m_ctl, PID_WebFormS_CookieName, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieName');
	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_CookieName, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_CookieName(CookieIndex: Word; valCookieName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_CookieName, CookieIndex, valCookieName, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_CookieName, CookieIndex, Integer(PChar(valCookieName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_CookieValue(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_CookieValue, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebFormS_CheckIndex = nil then exit;
  err :=  _WebFormS_CheckIndex(m_ctl, PID_WebFormS_CookieValue, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieValue');
	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_CookieValue, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_CookieValue(CookieIndex: Word; valCookieValue: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_CookieValue, CookieIndex, valCookieValue, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_CookieValue, CookieIndex, Integer(PChar(valCookieValue)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_Encoding: TipswebformsEncodings;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebformsEncodings(_WebFormS_GetENUM(m_ctl, PID_WebFormS_Encoding, 0, err));
{$ELSE}
  result := TipswebformsEncodings(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_Encoding, 0, nil);
  result := TipswebformsEncodings(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_Encoding(valEncoding: TipswebformsEncodings);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetENUM(m_ctl, PID_WebFormS_Encoding, 0, Integer(valEncoding), 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_Encoding, 0, Integer(valEncoding), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebFormS_GetLONG(m_ctl, PID_WebFormS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetLONG(m_ctl, PID_WebFormS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FirewallType: TipswebformsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebformsFirewallTypes(_WebFormS_GetENUM(m_ctl, PID_WebFormS_FirewallType, 0, err));
{$ELSE}
  result := TipswebformsFirewallTypes(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FirewallType, 0, nil);
  result := TipswebformsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_FirewallType(valFirewallType: TipswebformsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetENUM(m_ctl, PID_WebFormS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FollowRedirects: TipswebformsFollowRedirects;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebformsFollowRedirects(_WebFormS_GetENUM(m_ctl, PID_WebFormS_FollowRedirects, 0, err));
{$ELSE}
  result := TipswebformsFollowRedirects(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FollowRedirects, 0, nil);
  result := TipswebformsFollowRedirects(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_FollowRedirects(valFollowRedirects: TipswebformsFollowRedirects);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetENUM(m_ctl, PID_WebFormS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FormVarCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebFormS_GetINT(m_ctl, PID_WebFormS_FormVarCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FormVarCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_FormVarCount(valFormVarCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetINT(m_ctl, PID_WebFormS_FormVarCount, 0, valFormVarCount, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FormVarCount, 0, Integer(valFormVarCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FormVarNames(VarIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_FormVarNames, VarIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebFormS_CheckIndex = nil then exit;
  err :=  _WebFormS_CheckIndex(m_ctl, PID_WebFormS_FormVarNames, VarIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for FormVarNames');
	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FormVarNames, VarIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_FormVarNames(VarIndex: Word; valFormVarNames: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_FormVarNames, VarIndex, valFormVarNames, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FormVarNames, VarIndex, Integer(PChar(valFormVarNames)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_FormVarValues(VarIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_FormVarValues, VarIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebFormS_CheckIndex = nil then exit;
  err :=  _WebFormS_CheckIndex(m_ctl, PID_WebFormS_FormVarValues, VarIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for FormVarValues');
	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_FormVarValues, VarIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_FormVarValues(VarIndex: Word; valFormVarValues: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_FormVarValues, VarIndex, valFormVarValues, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_FormVarValues, VarIndex, Integer(PChar(valFormVarValues)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_From: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_From, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_From, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_From(valFrom: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_From, 0, valFrom, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_From, 0, Integer(PChar(valFrom)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_WebFormS_GetBOOL(m_ctl, PID_WebFormS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsWebFormS.get_LocalFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_LocalFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_LocalFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_LocalFile(valLocalFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_LocalFile, 0, valLocalFile, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_LocalFile, 0, Integer(PChar(valLocalFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_OtherHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_OtherHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_OtherHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_OtherHeaders(valOtherHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_OtherHeaders, 0, valOtherHeaders, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_OtherHeaders, 0, Integer(PChar(valOtherHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_Password, 0, valPassword, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_ProxyAuthorization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_ProxyAuthorization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_ProxyAuthorization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_ProxyAuthorization(valProxyAuthorization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_ProxyAuthorization, 0, valProxyAuthorization, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_ProxyAuthorization, 0, Integer(PChar(valProxyAuthorization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_ProxyPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_ProxyPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_ProxyPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_ProxyPassword(valProxyPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_ProxyPassword, 0, valProxyPassword, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_ProxyPassword, 0, Integer(PChar(valProxyPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_ProxyPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebFormS_GetLONG(m_ctl, PID_WebFormS_ProxyPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_ProxyPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_ProxyPort(valProxyPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetLONG(m_ctl, PID_WebFormS_ProxyPort, 0, valProxyPort, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_ProxyPort, 0, Integer(valProxyPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_ProxyServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_ProxyServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_ProxyServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_ProxyServer(valProxyServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_ProxyServer, 0, valProxyServer, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_ProxyServer, 0, Integer(PChar(valProxyServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_ProxySSL: TipswebformsProxySSLs;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebformsProxySSLs(_WebFormS_GetENUM(m_ctl, PID_WebFormS_ProxySSL, 0, err));
{$ELSE}
  result := TipswebformsProxySSLs(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_ProxySSL, 0, nil);
  result := TipswebformsProxySSLs(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_ProxySSL(valProxySSL: TipswebformsProxySSLs);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetENUM(m_ctl, PID_WebFormS_ProxySSL, 0, Integer(valProxySSL), 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_ProxySSL, 0, Integer(valProxySSL), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_ProxyUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_ProxyUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_ProxyUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_ProxyUser(valProxyUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_ProxyUser, 0, valProxyUser, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_ProxyUser, 0, Integer(PChar(valProxyUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_Referer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_Referer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_Referer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_Referer(valReferer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_Referer, 0, valReferer, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_Referer, 0, Integer(PChar(valReferer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetBSTR(m_ctl, PID_WebFormS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebFormS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetBSTR(m_ctl, PID_WebFormS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetBSTR(m_ctl, PID_WebFormS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebFormS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetBSTR(m_ctl, PID_WebFormS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetBSTR(m_ctl, PID_WebFormS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebFormS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetBSTR(m_ctl, PID_WebFormS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_SSLCertStoreType: TipswebformsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebformsSSLCertStoreTypes(_WebFormS_GetENUM(m_ctl, PID_WebFormS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipswebformsSSLCertStoreTypes(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_SSLCertStoreType, 0, nil);
  result := TipswebformsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_SSLCertStoreType(valSSLCertStoreType: TipswebformsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetENUM(m_ctl, PID_WebFormS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetBSTR(m_ctl, PID_WebFormS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsWebFormS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebFormS.get_StatusLine: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_StatusLine, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_StatusLine, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebFormS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebFormS_GetINT(m_ctl, PID_WebFormS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebFormS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetINT(m_ctl, PID_WebFormS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_TransferredData: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetBSTR(m_ctl, PID_WebFormS_TransferredData, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_TransferredData, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsWebFormS.get_TransferredHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_TransferredHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_TransferredHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebFormS.get_URL: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_URL, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_URL, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_URL(valURL: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_URL, 0, valURL, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_URL, 0, Integer(PChar(valURL)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebFormS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebFormS_GetCSTR(m_ctl, PID_WebFormS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebFormS_Get = nil then exit;
  tmp := _WebFormS_Get(m_ctl, PID_WebFormS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebFormS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebFormS_SetCSTR(m_ctl, PID_WebFormS_User, 0, valUser, 0);
{$ELSE}
	if @_WebFormS_Set = nil then exit;
  err := _WebFormS_Set(m_ctl, PID_WebFormS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsWebFormS.Config(ConfigurationString: String): String;
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


  err := _WebFormS_Do(m_ctl, MID_WebFormS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebFormS_Do = nil then exit;
  err := _WebFormS_Do(m_ctl, MID_WebFormS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsWebFormS.AddCookie(CookieName: String; CookieValue: String);

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


  err := _WebFormS_Do(m_ctl, MID_WebFormS_AddCookie, 2, param, paramcb); 

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


	if @_WebFormS_Do = nil then exit;
  err := _WebFormS_Do(m_ctl, MID_WebFormS_AddCookie, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebFormS.AddFormVar(VarName: String; VarValue: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(VarName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(VarValue);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebFormS_Do(m_ctl, MID_WebFormS_AddFormVar, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(VarName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(VarValue);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebFormS_Do = nil then exit;
  err := _WebFormS_Do(m_ctl, MID_WebFormS_AddFormVar, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebFormS.DoEvents();

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



  err := _WebFormS_Do(m_ctl, MID_WebFormS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebFormS_Do = nil then exit;
  err := _WebFormS_Do(m_ctl, MID_WebFormS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebFormS.Interrupt();

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



  err := _WebFormS_Do(m_ctl, MID_WebFormS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebFormS_Do = nil then exit;
  err := _WebFormS_Do(m_ctl, MID_WebFormS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebFormS.Reset();

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



  err := _WebFormS_Do(m_ctl, MID_WebFormS_Reset, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebFormS_Do = nil then exit;
  err := _WebFormS_Do(m_ctl, MID_WebFormS_Reset, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebFormS.Submit();

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



  err := _WebFormS_Do(m_ctl, MID_WebFormS_Submit, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebFormS_Do = nil then exit;
  err := _WebFormS_Do(m_ctl, MID_WebFormS_Submit, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebFormS.SubmitTo(URL: String);

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


  err := _WebFormS_Do(m_ctl, MID_WebFormS_SubmitTo, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebFormS_Do = nil then exit;
  err := _WebFormS_Do(m_ctl, MID_WebFormS_SubmitTo, 1, @param, @paramcb); 
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

	_WebFormS_Create := nil;
	_WebFormS_Destroy := nil;
	_WebFormS_Set := nil;
	_WebFormS_Get := nil;
	_WebFormS_GetLastError := nil;
	_WebFormS_StaticInit := nil;
	_WebFormS_CheckIndex := nil;
	_WebFormS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_webforms_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_WebFormS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'WebFormS_Create');
		@_WebFormS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'WebFormS_Destroy');
		@_WebFormS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'WebFormS_Set');
		@_WebFormS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'WebFormS_Get');
		@_WebFormS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'WebFormS_GetLastError');
		@_WebFormS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'WebFormS_CheckIndex');
		@_WebFormS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'WebFormS_Do');
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
  @_WebFormS_Create       := nil;
  @_WebFormS_Destroy      := nil;
  @_WebFormS_Set          := nil;
  @_WebFormS_Get          := nil;
  @_WebFormS_GetLastError := nil;
  @_WebFormS_CheckIndex   := nil;
  @_WebFormS_Do           := nil;
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




