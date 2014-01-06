
unit ipswebuploads;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipswebuploadsAuthSchemes = 
(

									 
                   authBasic,

									 
                   authDigest
);
  TipswebuploadsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipswebuploadsFollowRedirects = 
(

									 
                   frNever,

									 
                   frAlways,

									 
                   frSameScheme
);
  TipswebuploadsProxySSLs = 
(

									 
                   psAutomatic,

									 
                   psAlways,

									 
                   psNever,

									 
                   psTunnel
);
  TipswebuploadsSSLCertStoreTypes = 
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
  TUploadProgressEvent = procedure(Sender: TObject;
                            PercentDone: Integer) of Object;


{$IFDEF CLR}
  TWebUploadSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsWebUploadS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsWebUploadS = class(TipsCore)
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
      FOnUploadProgress: TUploadProgressEvent;


    private
      tmp_RedirectAccept: Boolean;
      tmp_SSLServerAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TWebUploadSEventHook;
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

      function get_CookieCount: Integer;
      procedure set_CookieCount(valCookieCount: Integer);

      function get_CookieName(CookieIndex: Word): String;
      procedure set_CookieName(CookieIndex: Word; valCookieName: String);

      function get_CookieValue(CookieIndex: Word): String;
      procedure set_CookieValue(CookieIndex: Word; valCookieValue: String);

      function get_FileNames(FileIndex: Word): String;
      procedure set_FileNames(FileIndex: Word; valFileNames: String);

      function get_FileVarNames(FileIndex: Word): String;
      procedure set_FileVarNames(FileIndex: Word; valFileVarNames: String);

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



      function get_AuthScheme: TipswebuploadsAuthSchemes;
      procedure set_AuthScheme(valAuthScheme: TipswebuploadsAuthSchemes);









      function get_FileCount: Integer;
      procedure set_FileCount(valFileCount: Integer);





      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipswebuploadsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipswebuploadsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_FollowRedirects: TipswebuploadsFollowRedirects;
      procedure set_FollowRedirects(valFollowRedirects: TipswebuploadsFollowRedirects);









      function get_Idle: Boolean;


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

      function get_ProxySSL: TipswebuploadsProxySSLs;
      procedure set_ProxySSL(valProxySSL: TipswebuploadsProxySSLs);

      function get_ProxyUser: String;
      procedure set_ProxyUser(valProxyUser: String);



      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipswebuploadsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipswebuploadsSSLCertStoreTypes);

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

      property CookieCount: Integer
               read get_CookieCount
               write set_CookieCount               ;

      property CookieName[CookieIndex: Word]: String
               read get_CookieName
               write set_CookieName               ;

      property CookieValue[CookieIndex: Word]: String
               read get_CookieValue
               write set_CookieValue               ;



      property FileNames[FileIndex: Word]: String
               read get_FileNames
               write set_FileNames               ;

      property FileVarNames[FileIndex: Word]: String
               read get_FileVarNames
               write set_FileVarNames               ;













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

      procedure AddFileVar(FileVar: String; FileName: String);

      procedure AddFormVar(VarName: String; VarValue: String);

      procedure DoEvents();

      procedure Interrupt();

      procedure Reset();

      procedure Upload();

      procedure UploadTo(URL: String);


{$ENDIF}

    published

      property Accept: String
                   read get_Accept
                   write set_Accept
                   
                   ;

      property AuthScheme: TipswebuploadsAuthSchemes
                   read get_AuthScheme
                   write set_AuthScheme
                   default authBasic
                   ;




      property FileCount: Integer
                   read get_FileCount
                   write set_FileCount
                   default 0
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
      property FirewallType: TipswebuploadsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property FollowRedirects: TipswebuploadsFollowRedirects
                   read get_FollowRedirects
                   write set_FollowRedirects
                   default frNever
                   ;




      property Idle: Boolean
                   read get_Idle
                    write SetNoopBoolean
                   stored False

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
      property ProxySSL: TipswebuploadsProxySSLs
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
      property SSLCertStoreType: TipswebuploadsSSLCertStoreTypes
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
      property OnUploadProgress: TUploadProgressEvent read FOnUploadProgress write FOnUploadProgress;


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
    PID_WebUploadS_Accept = 1;
    PID_WebUploadS_Authorization = 2;
    PID_WebUploadS_AuthScheme = 3;
    PID_WebUploadS_Connected = 4;
    PID_WebUploadS_CookieCount = 5;
    PID_WebUploadS_CookieName = 6;
    PID_WebUploadS_CookieValue = 7;
    PID_WebUploadS_FileCount = 8;
    PID_WebUploadS_FileNames = 9;
    PID_WebUploadS_FileVarNames = 10;
    PID_WebUploadS_FirewallHost = 11;
    PID_WebUploadS_FirewallPassword = 12;
    PID_WebUploadS_FirewallPort = 13;
    PID_WebUploadS_FirewallType = 14;
    PID_WebUploadS_FirewallUser = 15;
    PID_WebUploadS_FollowRedirects = 16;
    PID_WebUploadS_FormVarCount = 17;
    PID_WebUploadS_FormVarNames = 18;
    PID_WebUploadS_FormVarValues = 19;
    PID_WebUploadS_From = 20;
    PID_WebUploadS_Idle = 21;
    PID_WebUploadS_LocalHost = 22;
    PID_WebUploadS_OtherHeaders = 23;
    PID_WebUploadS_Password = 24;
    PID_WebUploadS_ProxyAuthorization = 25;
    PID_WebUploadS_ProxyPassword = 26;
    PID_WebUploadS_ProxyPort = 27;
    PID_WebUploadS_ProxyServer = 28;
    PID_WebUploadS_ProxySSL = 29;
    PID_WebUploadS_ProxyUser = 30;
    PID_WebUploadS_Referer = 31;
    PID_WebUploadS_SSLAcceptServerCert = 32;
    PID_WebUploadS_SSLCertEncoded = 33;
    PID_WebUploadS_SSLCertStore = 34;
    PID_WebUploadS_SSLCertStorePassword = 35;
    PID_WebUploadS_SSLCertStoreType = 36;
    PID_WebUploadS_SSLCertSubject = 37;
    PID_WebUploadS_SSLServerCert = 38;
    PID_WebUploadS_SSLServerCertStatus = 39;
    PID_WebUploadS_StatusLine = 40;
    PID_WebUploadS_Timeout = 41;
    PID_WebUploadS_TransferredData = 42;
    PID_WebUploadS_TransferredHeaders = 43;
    PID_WebUploadS_URL = 44;
    PID_WebUploadS_User = 45;

    EID_WebUploadS_Connected = 1;
    EID_WebUploadS_ConnectionStatus = 2;
    EID_WebUploadS_Disconnected = 3;
    EID_WebUploadS_EndTransfer = 4;
    EID_WebUploadS_Error = 5;
    EID_WebUploadS_Header = 6;
    EID_WebUploadS_Redirect = 7;
    EID_WebUploadS_SetCookie = 8;
    EID_WebUploadS_SSLServerAuthentication = 9;
    EID_WebUploadS_SSLStatus = 10;
    EID_WebUploadS_StartTransfer = 11;
    EID_WebUploadS_Status = 12;
    EID_WebUploadS_Transfer = 13;
    EID_WebUploadS_UploadProgress = 14;


    MID_WebUploadS_Config = 1;
    MID_WebUploadS_AddCookie = 2;
    MID_WebUploadS_AddFileVar = 3;
    MID_WebUploadS_AddFormVar = 4;
    MID_WebUploadS_DoEvents = 5;
    MID_WebUploadS_Interrupt = 6;
    MID_WebUploadS_Reset = 7;
    MID_WebUploadS_Upload = 8;
    MID_WebUploadS_UploadTo = 9;




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
{$R 'ipswebuploads.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsWebUploadS; event_id: Integer; cparam: Integer; 
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
  _WebUploadS_Create:        function(pMethod: PEventHandle; pObject: TipsWebUploadS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebUploadS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebUploadS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebUploadS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebUploadS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebUploadS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebUploadS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _WebUploadS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Create')]
  function _WebUploadS_Create       (pMethod: TWebUploadSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Destroy')]
  function _WebUploadS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Set')]
  function _WebUploadS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Set')]
  function _WebUploadS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Set')]
  function _WebUploadS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Set')]
  function _WebUploadS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Set')]
  function _WebUploadS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Set')]
  function _WebUploadS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Get')]
  function _WebUploadS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Get')]
  function _WebUploadS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Get')]
  function _WebUploadS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Get')]
  function _WebUploadS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Get')]
  function _WebUploadS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Get')]
  function _WebUploadS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_GetLastError')]
  function _WebUploadS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_StaticInit')]
  function _WebUploadS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_CheckIndex')]
  function _WebUploadS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'WebUploadS_Do')]
  function _WebUploadS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _WebUploadS_Create       (pMethod: PEventHandle; pObject: TipsWebUploadS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebUploadS_Create';
  function _WebUploadS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebUploadS_Destroy';
  function _WebUploadS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebUploadS_Set';
  function _WebUploadS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebUploadS_Get';
  function _WebUploadS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebUploadS_GetLastError';
  function _WebUploadS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebUploadS_StaticInit';
  function _WebUploadS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebUploadS_CheckIndex';
  function _WebUploadS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'WebUploadS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsWebUploadS; event_id: Integer;
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
    tmp_UploadProgressPercentDone: Integer;

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

      EID_WebUploadS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_WebUploadS_ConnectionStatus:
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
      EID_WebUploadS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_WebUploadS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_WebUploadS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_WebUploadS_Header:
      begin
        if Assigned(lpContext.FOnHeader) then
        begin
          {assign temporary variables}
          tmp_HeaderField := AnsiString(PChar(params^[0]));

          tmp_HeaderValue := AnsiString(PChar(params^[1]));


          lpContext.FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



        end;
      end;
      EID_WebUploadS_Redirect:
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
      EID_WebUploadS_SetCookie:
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
      EID_WebUploadS_SSLServerAuthentication:
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
      EID_WebUploadS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_WebUploadS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_WebUploadS_Status:
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
      EID_WebUploadS_Transfer:
      begin
        if Assigned(lpContext.FOnTransfer) then
        begin
          {assign temporary variables}
          tmp_TransferBytesTransferred := LongInt(params^[0]);
          SetString(tmp_TransferText, PChar(params^[1]), cbparam^[1]);


          lpContext.FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText);



        end;
      end;
      EID_WebUploadS_UploadProgress:
      begin
        if Assigned(lpContext.FOnUploadProgress) then
        begin
          {assign temporary variables}
          tmp_UploadProgressPercentDone := Integer(params^[0]);

          lpContext.FOnUploadProgress(lpContext, tmp_UploadProgressPercentDone);


        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsWebUploadS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
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
  tmp_UploadProgressPercentDone: Integer;


begin
 	p := nil;
  case event_id of
    EID_WebUploadS_Connected:
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
    EID_WebUploadS_ConnectionStatus:
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
    EID_WebUploadS_Disconnected:
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
    EID_WebUploadS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_WebUploadS_Error:
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
    EID_WebUploadS_Header:
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
    EID_WebUploadS_Redirect:
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
    EID_WebUploadS_SetCookie:
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
    EID_WebUploadS_SSLServerAuthentication:
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
    EID_WebUploadS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_WebUploadS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_WebUploadS_Status:
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
    EID_WebUploadS_Transfer:
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
    EID_WebUploadS_UploadProgress:
    begin
      if Assigned(FOnUploadProgress) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_UploadProgressPercentDone := Marshal.ReadInt32(params, 4*0);

        FOnUploadProgress(lpContext, tmp_UploadProgressPercentDone);


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
    RegisterComponents('IP*Works! SSL', [TipsWebUploadS]);
end;

constructor TipsWebUploadS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _WebUploadS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_WebUploadS_Create <> nil then
      m_ctl := _WebUploadS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL WebUploadS: Error creating component');

{$IFDEF CLR}
    _WebUploadS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_51, 0);
{$ELSE}
    _WebUploadS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_51)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_WebUploadS_Do <> nil then
      _WebUploadS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_Accept('') except on E:Exception do end;
    try set_AuthScheme(authBasic) except on E:Exception do end;
    try set_FileCount(0) except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_FollowRedirects(frNever) except on E:Exception do end;
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

destructor TipsWebUploadS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_WebUploadS_Destroy <> nil then{$ENDIF}
      	_WebUploadS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsWebUploadS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsWebUploadS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsWebUploadS.AboutDlg;
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
	if @_WebUploadS_Do <> nil then
{$ENDIF}
		_WebUploadS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsWebUploadS.SetOK(key: String128);
begin
end;

function TipsWebUploadS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsWebUploadS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsWebUploadS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsWebUploadS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsWebUploadS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsWebUploadS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_WebUploadS_GetLastError <> nil then{$ENDIF}
      msg := _WebUploadS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsWebUploadS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_WebUploadS_Do <> nil then
      _WebUploadS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsWebUploadS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebUploadS_Set = nil then exit;{$ENDIF}
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebUploadS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebUploadS_Set = nil then exit;{$ENDIF}
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebUploadS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebUploadS_Set = nil then exit;{$ENDIF}
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebUploadS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebUploadS_Set = nil then exit;{$ENDIF}
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsWebUploadS.SetTransferredData(lpTransferredData: PChar; lenTransferredData: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_WebUploadS_Set = nil then exit;{$ENDIF}
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_TransferredData, 0, Integer(lpTransferredData), lenTransferredData);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsWebUploadS.get_Accept: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_Accept, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_Accept, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_Accept(valAccept: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_Accept, 0, valAccept, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_Accept, 0, Integer(PChar(valAccept)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_Authorization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_Authorization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_Authorization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_Authorization(valAuthorization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_Authorization, 0, valAuthorization, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_Authorization, 0, Integer(PChar(valAuthorization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_AuthScheme: TipswebuploadsAuthSchemes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebuploadsAuthSchemes(_WebUploadS_GetENUM(m_ctl, PID_WebUploadS_AuthScheme, 0, err));
{$ELSE}
  result := TipswebuploadsAuthSchemes(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_AuthScheme, 0, nil);
  result := TipswebuploadsAuthSchemes(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_AuthScheme(valAuthScheme: TipswebuploadsAuthSchemes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetENUM(m_ctl, PID_WebUploadS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_WebUploadS_GetBOOL(m_ctl, PID_WebUploadS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetBOOL(m_ctl, PID_WebUploadS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_CookieCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebUploadS_GetINT(m_ctl, PID_WebUploadS_CookieCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_CookieCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_CookieCount(valCookieCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetINT(m_ctl, PID_WebUploadS_CookieCount, 0, valCookieCount, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_CookieCount, 0, Integer(valCookieCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_CookieName(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_CookieName, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebUploadS_CheckIndex = nil then exit;
  err :=  _WebUploadS_CheckIndex(m_ctl, PID_WebUploadS_CookieName, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieName');
	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_CookieName, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_CookieName(CookieIndex: Word; valCookieName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_CookieName, CookieIndex, valCookieName, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_CookieName, CookieIndex, Integer(PChar(valCookieName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_CookieValue(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_CookieValue, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebUploadS_CheckIndex = nil then exit;
  err :=  _WebUploadS_CheckIndex(m_ctl, PID_WebUploadS_CookieValue, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieValue');
	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_CookieValue, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_CookieValue(CookieIndex: Word; valCookieValue: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_CookieValue, CookieIndex, valCookieValue, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_CookieValue, CookieIndex, Integer(PChar(valCookieValue)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FileCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebUploadS_GetINT(m_ctl, PID_WebUploadS_FileCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FileCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_FileCount(valFileCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetINT(m_ctl, PID_WebUploadS_FileCount, 0, valFileCount, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FileCount, 0, Integer(valFileCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FileNames(FileIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_FileNames, FileIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebUploadS_CheckIndex = nil then exit;
  err :=  _WebUploadS_CheckIndex(m_ctl, PID_WebUploadS_FileNames, FileIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for FileNames');
	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FileNames, FileIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_FileNames(FileIndex: Word; valFileNames: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_FileNames, FileIndex, valFileNames, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FileNames, FileIndex, Integer(PChar(valFileNames)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FileVarNames(FileIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_FileVarNames, FileIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebUploadS_CheckIndex = nil then exit;
  err :=  _WebUploadS_CheckIndex(m_ctl, PID_WebUploadS_FileVarNames, FileIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for FileVarNames');
	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FileVarNames, FileIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_FileVarNames(FileIndex: Word; valFileVarNames: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_FileVarNames, FileIndex, valFileVarNames, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FileVarNames, FileIndex, Integer(PChar(valFileVarNames)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebUploadS_GetLONG(m_ctl, PID_WebUploadS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetLONG(m_ctl, PID_WebUploadS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FirewallType: TipswebuploadsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebuploadsFirewallTypes(_WebUploadS_GetENUM(m_ctl, PID_WebUploadS_FirewallType, 0, err));
{$ELSE}
  result := TipswebuploadsFirewallTypes(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FirewallType, 0, nil);
  result := TipswebuploadsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_FirewallType(valFirewallType: TipswebuploadsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetENUM(m_ctl, PID_WebUploadS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FollowRedirects: TipswebuploadsFollowRedirects;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebuploadsFollowRedirects(_WebUploadS_GetENUM(m_ctl, PID_WebUploadS_FollowRedirects, 0, err));
{$ELSE}
  result := TipswebuploadsFollowRedirects(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FollowRedirects, 0, nil);
  result := TipswebuploadsFollowRedirects(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_FollowRedirects(valFollowRedirects: TipswebuploadsFollowRedirects);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetENUM(m_ctl, PID_WebUploadS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FormVarCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebUploadS_GetINT(m_ctl, PID_WebUploadS_FormVarCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FormVarCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_FormVarCount(valFormVarCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetINT(m_ctl, PID_WebUploadS_FormVarCount, 0, valFormVarCount, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FormVarCount, 0, Integer(valFormVarCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FormVarNames(VarIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_FormVarNames, VarIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebUploadS_CheckIndex = nil then exit;
  err :=  _WebUploadS_CheckIndex(m_ctl, PID_WebUploadS_FormVarNames, VarIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for FormVarNames');
	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FormVarNames, VarIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_FormVarNames(VarIndex: Word; valFormVarNames: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_FormVarNames, VarIndex, valFormVarNames, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FormVarNames, VarIndex, Integer(PChar(valFormVarNames)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_FormVarValues(VarIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_FormVarValues, VarIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_WebUploadS_CheckIndex = nil then exit;
  err :=  _WebUploadS_CheckIndex(m_ctl, PID_WebUploadS_FormVarValues, VarIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for FormVarValues');
	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_FormVarValues, VarIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_FormVarValues(VarIndex: Word; valFormVarValues: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_FormVarValues, VarIndex, valFormVarValues, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_FormVarValues, VarIndex, Integer(PChar(valFormVarValues)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_From: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_From, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_From, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_From(valFrom: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_From, 0, valFrom, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_From, 0, Integer(PChar(valFrom)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_WebUploadS_GetBOOL(m_ctl, PID_WebUploadS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsWebUploadS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_OtherHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_OtherHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_OtherHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_OtherHeaders(valOtherHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_OtherHeaders, 0, valOtherHeaders, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_OtherHeaders, 0, Integer(PChar(valOtherHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_Password, 0, valPassword, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_ProxyAuthorization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_ProxyAuthorization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_ProxyAuthorization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_ProxyAuthorization(valProxyAuthorization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_ProxyAuthorization, 0, valProxyAuthorization, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_ProxyAuthorization, 0, Integer(PChar(valProxyAuthorization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_ProxyPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_ProxyPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_ProxyPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_ProxyPassword(valProxyPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_ProxyPassword, 0, valProxyPassword, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_ProxyPassword, 0, Integer(PChar(valProxyPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_ProxyPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebUploadS_GetLONG(m_ctl, PID_WebUploadS_ProxyPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_ProxyPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_ProxyPort(valProxyPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetLONG(m_ctl, PID_WebUploadS_ProxyPort, 0, valProxyPort, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_ProxyPort, 0, Integer(valProxyPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_ProxyServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_ProxyServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_ProxyServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_ProxyServer(valProxyServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_ProxyServer, 0, valProxyServer, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_ProxyServer, 0, Integer(PChar(valProxyServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_ProxySSL: TipswebuploadsProxySSLs;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebuploadsProxySSLs(_WebUploadS_GetENUM(m_ctl, PID_WebUploadS_ProxySSL, 0, err));
{$ELSE}
  result := TipswebuploadsProxySSLs(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_ProxySSL, 0, nil);
  result := TipswebuploadsProxySSLs(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_ProxySSL(valProxySSL: TipswebuploadsProxySSLs);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetENUM(m_ctl, PID_WebUploadS_ProxySSL, 0, Integer(valProxySSL), 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_ProxySSL, 0, Integer(valProxySSL), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_ProxyUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_ProxyUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_ProxyUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_ProxyUser(valProxyUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_ProxyUser, 0, valProxyUser, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_ProxyUser, 0, Integer(PChar(valProxyUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_Referer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_Referer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_Referer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_Referer(valReferer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_Referer, 0, valReferer, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_Referer, 0, Integer(PChar(valReferer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetBSTR(m_ctl, PID_WebUploadS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebUploadS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetBSTR(m_ctl, PID_WebUploadS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetBSTR(m_ctl, PID_WebUploadS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebUploadS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetBSTR(m_ctl, PID_WebUploadS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetBSTR(m_ctl, PID_WebUploadS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsWebUploadS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetBSTR(m_ctl, PID_WebUploadS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_SSLCertStoreType: TipswebuploadsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipswebuploadsSSLCertStoreTypes(_WebUploadS_GetENUM(m_ctl, PID_WebUploadS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipswebuploadsSSLCertStoreTypes(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_SSLCertStoreType, 0, nil);
  result := TipswebuploadsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_SSLCertStoreType(valSSLCertStoreType: TipswebuploadsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetENUM(m_ctl, PID_WebUploadS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetBSTR(m_ctl, PID_WebUploadS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsWebUploadS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebUploadS.get_StatusLine: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_StatusLine, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_StatusLine, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebUploadS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_WebUploadS_GetINT(m_ctl, PID_WebUploadS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsWebUploadS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetINT(m_ctl, PID_WebUploadS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_TransferredData: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetBSTR(m_ctl, PID_WebUploadS_TransferredData, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_TransferredData, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsWebUploadS.get_TransferredHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_TransferredHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_TransferredHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsWebUploadS.get_URL: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_URL, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_URL, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_URL(valURL: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_URL, 0, valURL, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_URL, 0, Integer(PChar(valURL)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsWebUploadS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _WebUploadS_GetCSTR(m_ctl, PID_WebUploadS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_WebUploadS_Get = nil then exit;
  tmp := _WebUploadS_Get(m_ctl, PID_WebUploadS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsWebUploadS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _WebUploadS_SetCSTR(m_ctl, PID_WebUploadS_User, 0, valUser, 0);
{$ELSE}
	if @_WebUploadS_Set = nil then exit;
  err := _WebUploadS_Set(m_ctl, PID_WebUploadS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsWebUploadS.Config(ConfigurationString: String): String;
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


  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsWebUploadS.AddCookie(CookieName: String; CookieValue: String);

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


  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_AddCookie, 2, param, paramcb); 

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


	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_AddCookie, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebUploadS.AddFileVar(FileVar: String; FileName: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(FileVar);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(FileName);
  paramcb[i] := 0;

  i := i + 1;


  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_AddFileVar, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(FileVar);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(FileName);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_AddFileVar, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebUploadS.AddFormVar(VarName: String; VarValue: String);

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


  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_AddFormVar, 2, param, paramcb); 

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


	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_AddFormVar, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebUploadS.DoEvents();

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



  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebUploadS.Interrupt();

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



  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebUploadS.Reset();

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



  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_Reset, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_Reset, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebUploadS.Upload();

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



  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_Upload, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_Upload, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsWebUploadS.UploadTo(URL: String);

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


  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_UploadTo, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(URL);
  paramcb[i] := 0;

  i := i + 1;


	if @_WebUploadS_Do = nil then exit;
  err := _WebUploadS_Do(m_ctl, MID_WebUploadS_UploadTo, 1, @param, @paramcb); 
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

	_WebUploadS_Create := nil;
	_WebUploadS_Destroy := nil;
	_WebUploadS_Set := nil;
	_WebUploadS_Get := nil;
	_WebUploadS_GetLastError := nil;
	_WebUploadS_StaticInit := nil;
	_WebUploadS_CheckIndex := nil;
	_WebUploadS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_webuploads_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_WebUploadS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'WebUploadS_Create');
		@_WebUploadS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'WebUploadS_Destroy');
		@_WebUploadS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'WebUploadS_Set');
		@_WebUploadS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'WebUploadS_Get');
		@_WebUploadS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'WebUploadS_GetLastError');
		@_WebUploadS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'WebUploadS_CheckIndex');
		@_WebUploadS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'WebUploadS_Do');
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
  @_WebUploadS_Create       := nil;
  @_WebUploadS_Destroy      := nil;
  @_WebUploadS_Set          := nil;
  @_WebUploadS_Get          := nil;
  @_WebUploadS_GetLastError := nil;
  @_WebUploadS_CheckIndex   := nil;
  @_WebUploadS_Do           := nil;
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




