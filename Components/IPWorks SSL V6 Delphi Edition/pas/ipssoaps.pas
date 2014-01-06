
unit ipssoaps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipssoapsAuthSchemes = 
(

									 
                   authBasic,

									 
                   authDigest
);
  TipssoapsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipssoapsFollowRedirects = 
(

									 
                   frNever,

									 
                   frAlways,

									 
                   frSameScheme
);
  TipssoapsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipssoapsValueFormats = 
(

									 
                   vfText,

									 
                   vfXML,

									 
                   vfFullXML
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
                            BytesTransferred: LongInt) of Object;


{$IFDEF CLR}
  TSOAPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsSOAPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsSOAPS = class(TipsCore)
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


    private
      tmp_RedirectAccept: Boolean;
      tmp_SSLServerAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TSOAPSEventHook;
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

      function get_OtherHeaders: String;
      procedure set_OtherHeaders(valOtherHeaders: String);

      function get_NamespaceCount: Integer;
      procedure set_NamespaceCount(valNamespaceCount: Integer);

      function get_Namespaces(NamespaceIndex: Word): String;
      procedure set_Namespaces(NamespaceIndex: Word; valNamespaces: String);

      function get_ParamAttr(ParamIndex: Word): String;
      procedure set_ParamAttr(ParamIndex: Word; valParamAttr: String);

      function get_ParamCount: Integer;
      procedure set_ParamCount(valParamCount: Integer);

      function get_ParamName(ParamIndex: Word): String;
      procedure set_ParamName(ParamIndex: Word; valParamName: String);

      function get_ParamValue(ParamIndex: Word): String;
      procedure set_ParamValue(ParamIndex: Word; valParamValue: String);

      function get_Pragma: String;
      procedure set_Pragma(valPragma: String);

      function get_Prefixes(NamespaceIndex: Word): String;
      procedure set_Prefixes(NamespaceIndex: Word; valPrefixes: String);

      function get_ProxyAuthorization: String;
      procedure set_ProxyAuthorization(valProxyAuthorization: String);

      function get_Referer: String;
      procedure set_Referer(valReferer: String);

      function get_SOAPHeader: String;
      procedure set_SOAPHeader(valSOAPHeader: String);

      function get_SOAPPacket: String;
      procedure set_SOAPPacket(valSOAPPacket: String);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);

      function get_StatusLine: String;


      function get_XAttrCount: Integer;


      function get_XAttrName(AttrIndex: Word): String;


      function get_XAttrNamespace(AttrIndex: Word): String;


      function get_XAttrPrefix(AttrIndex: Word): String;


      function get_XAttrValue(AttrIndex: Word): String;



      procedure TreatErr(Err: integer; const desc: string);


      function get_Accept: String;
      procedure set_Accept(valAccept: String);

      function get_ActionURI: String;
      procedure set_ActionURI(valActionURI: String);



      function get_AuthScheme: TipssoapsAuthSchemes;
      procedure set_AuthScheme(valAuthScheme: TipssoapsAuthSchemes);











      function get_FaultActor: String;


      function get_FaultCode: String;


      function get_FaultString: String;


      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipssoapsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipssoapsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_FollowRedirects: TipssoapsFollowRedirects;
      procedure set_FollowRedirects(valFollowRedirects: TipssoapsFollowRedirects);



      function get_Idle: Boolean;


      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);

      function get_Method: String;
      procedure set_Method(valMethod: String);

      function get_MethodURI: String;
      procedure set_MethodURI(valMethodURI: String);













      function get_Password: String;
      procedure set_Password(valPassword: String);







      function get_ProxyPort: Integer;
      procedure set_ProxyPort(valProxyPort: Integer);

      function get_ProxyServer: String;
      procedure set_ProxyServer(valProxyServer: String);



      function get_ReturnValue: String;


      function get_SOAPEncoding: String;
      procedure set_SOAPEncoding(valSOAPEncoding: String);





      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipssoapsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipssoapsSSLCertStoreTypes);

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

      function get_ValueFormat: TipssoapsValueFormats;
      procedure set_ValueFormat(valValueFormat: TipssoapsValueFormats);











      function get_XChildren: Integer;


      function get_XElement: String;


      function get_XNamespace: String;


      function get_XParent: String;


      function get_XPath: String;
      procedure set_XPath(valXPath: String);

      function get_XPrefix: String;


      function get_XText: String;




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



















      property OtherHeaders: String
               read get_OtherHeaders
               write set_OtherHeaders               ;









      property NamespaceCount: Integer
               read get_NamespaceCount
               write set_NamespaceCount               ;

      property Namespaces[NamespaceIndex: Word]: String
               read get_Namespaces
               write set_Namespaces               ;

      property ParamAttr[ParamIndex: Word]: String
               read get_ParamAttr
               write set_ParamAttr               ;

      property ParamCount: Integer
               read get_ParamCount
               write set_ParamCount               ;

      property ParamName[ParamIndex: Word]: String
               read get_ParamName
               write set_ParamName               ;

      property ParamValue[ParamIndex: Word]: String
               read get_ParamValue
               write set_ParamValue               ;



      property Pragma: String
               read get_Pragma
               write set_Pragma               ;

      property Prefixes[NamespaceIndex: Word]: String
               read get_Prefixes
               write set_Prefixes               ;

      property ProxyAuthorization: String
               read get_ProxyAuthorization
               write set_ProxyAuthorization               ;





      property Referer: String
               read get_Referer
               write set_Referer               ;





      property SOAPHeader: String
               read get_SOAPHeader
               write set_SOAPHeader               ;

      property SOAPPacket: String
               read get_SOAPPacket
               write set_SOAPPacket               ;



      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;













      property StatusLine: String
               read get_StatusLine
               ;









      property XAttrCount: Integer
               read get_XAttrCount
               ;

      property XAttrName[AttrIndex: Word]: String
               read get_XAttrName
               ;

      property XAttrNamespace[AttrIndex: Word]: String
               read get_XAttrNamespace
               ;

      property XAttrPrefix[AttrIndex: Word]: String
               read get_XAttrPrefix
               ;

      property XAttrValue[AttrIndex: Word]: String
               read get_XAttrValue
               ;

















{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure AddCookie(CookieName: String; CookieValue: String);

      procedure AddNamespace(Prefix: String; NamespaceURI: String);

      procedure AddParam(ParamName: String; ParamValue: String);

      procedure BuildPacket();

      procedure DoEvents();

      procedure EvalPacket();

      procedure Interrupt();

      procedure Reset();

      procedure SendPacket();

      procedure SendRequest();

      function Value(ParamName: String): String;

{$ENDIF}

    published

      property Accept: String
                   read get_Accept
                   write set_Accept
                   
                   ;
      property ActionURI: String
                   read get_ActionURI
                   write set_ActionURI
                   
                   ;

      property AuthScheme: TipssoapsAuthSchemes
                   read get_AuthScheme
                   write set_AuthScheme
                   default authBasic
                   ;





      property FaultActor: String
                   read get_FaultActor
                    write SetNoopString
                   stored False

                   ;
      property FaultCode: String
                   read get_FaultCode
                    write SetNoopString
                   stored False

                   ;
      property FaultString: String
                   read get_FaultString
                    write SetNoopString
                   stored False

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
      property FirewallType: TipssoapsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property FollowRedirects: TipssoapsFollowRedirects
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
      property Method: String
                   read get_Method
                   write set_Method
                   
                   ;
      property MethodURI: String
                   read get_MethodURI
                   write set_MethodURI
                   
                   ;






      property Password: String
                   read get_Password
                   write set_Password
                   
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

      property ReturnValue: String
                   read get_ReturnValue
                    write SetNoopString
                   stored False

                   ;
      property SOAPEncoding: String
                   read get_SOAPEncoding
                   write set_SOAPEncoding
                   
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
      property SSLCertStoreType: TipssoapsSSLCertStoreTypes
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
      property ValueFormat: TipssoapsValueFormats
                   read get_ValueFormat
                   write set_ValueFormat
                   stored False

                   ;





      property XChildren: Integer
                   read get_XChildren
                    write SetNoopInteger
                   stored False

                   ;
      property XElement: String
                   read get_XElement
                    write SetNoopString
                   stored False

                   ;
      property XNamespace: String
                   read get_XNamespace
                    write SetNoopString
                   stored False

                   ;
      property XParent: String
                   read get_XParent
                    write SetNoopString
                   stored False

                   ;
      property XPath: String
                   read get_XPath
                   write set_XPath
                   
                   ;
      property XPrefix: String
                   read get_XPrefix
                    write SetNoopString
                   stored False

                   ;
      property XText: String
                   read get_XText
                    write SetNoopString
                   stored False

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
    PID_SOAPS_Accept = 1;
    PID_SOAPS_ActionURI = 2;
    PID_SOAPS_Authorization = 3;
    PID_SOAPS_AuthScheme = 4;
    PID_SOAPS_Connected = 5;
    PID_SOAPS_ContentType = 6;
    PID_SOAPS_CookieCount = 7;
    PID_SOAPS_CookieName = 8;
    PID_SOAPS_CookieValue = 9;
    PID_SOAPS_FaultActor = 10;
    PID_SOAPS_FaultCode = 11;
    PID_SOAPS_FaultString = 12;
    PID_SOAPS_FirewallHost = 13;
    PID_SOAPS_FirewallPassword = 14;
    PID_SOAPS_FirewallPort = 15;
    PID_SOAPS_FirewallType = 16;
    PID_SOAPS_FirewallUser = 17;
    PID_SOAPS_FollowRedirects = 18;
    PID_SOAPS_OtherHeaders = 19;
    PID_SOAPS_Idle = 20;
    PID_SOAPS_LocalHost = 21;
    PID_SOAPS_Method = 22;
    PID_SOAPS_MethodURI = 23;
    PID_SOAPS_NamespaceCount = 24;
    PID_SOAPS_Namespaces = 25;
    PID_SOAPS_ParamAttr = 26;
    PID_SOAPS_ParamCount = 27;
    PID_SOAPS_ParamName = 28;
    PID_SOAPS_ParamValue = 29;
    PID_SOAPS_Password = 30;
    PID_SOAPS_Pragma = 31;
    PID_SOAPS_Prefixes = 32;
    PID_SOAPS_ProxyAuthorization = 33;
    PID_SOAPS_ProxyPort = 34;
    PID_SOAPS_ProxyServer = 35;
    PID_SOAPS_Referer = 36;
    PID_SOAPS_ReturnValue = 37;
    PID_SOAPS_SOAPEncoding = 38;
    PID_SOAPS_SOAPHeader = 39;
    PID_SOAPS_SOAPPacket = 40;
    PID_SOAPS_SSLAcceptServerCert = 41;
    PID_SOAPS_SSLCertEncoded = 42;
    PID_SOAPS_SSLCertStore = 43;
    PID_SOAPS_SSLCertStorePassword = 44;
    PID_SOAPS_SSLCertStoreType = 45;
    PID_SOAPS_SSLCertSubject = 46;
    PID_SOAPS_SSLServerCert = 47;
    PID_SOAPS_SSLServerCertStatus = 48;
    PID_SOAPS_StatusLine = 49;
    PID_SOAPS_Timeout = 50;
    PID_SOAPS_URL = 51;
    PID_SOAPS_User = 52;
    PID_SOAPS_ValueFormat = 53;
    PID_SOAPS_XAttrCount = 54;
    PID_SOAPS_XAttrName = 55;
    PID_SOAPS_XAttrNamespace = 56;
    PID_SOAPS_XAttrPrefix = 57;
    PID_SOAPS_XAttrValue = 58;
    PID_SOAPS_XChildren = 59;
    PID_SOAPS_XElement = 60;
    PID_SOAPS_XNamespace = 61;
    PID_SOAPS_XParent = 62;
    PID_SOAPS_XPath = 63;
    PID_SOAPS_XPrefix = 64;
    PID_SOAPS_XText = 65;

    EID_SOAPS_Connected = 1;
    EID_SOAPS_ConnectionStatus = 2;
    EID_SOAPS_Disconnected = 3;
    EID_SOAPS_EndTransfer = 4;
    EID_SOAPS_Error = 5;
    EID_SOAPS_Header = 6;
    EID_SOAPS_Redirect = 7;
    EID_SOAPS_SetCookie = 8;
    EID_SOAPS_SSLServerAuthentication = 9;
    EID_SOAPS_SSLStatus = 10;
    EID_SOAPS_StartTransfer = 11;
    EID_SOAPS_Status = 12;
    EID_SOAPS_Transfer = 13;


    MID_SOAPS_Config = 1;
    MID_SOAPS_AddCookie = 2;
    MID_SOAPS_AddNamespace = 3;
    MID_SOAPS_AddParam = 4;
    MID_SOAPS_BuildPacket = 5;
    MID_SOAPS_DoEvents = 6;
    MID_SOAPS_EvalPacket = 7;
    MID_SOAPS_Interrupt = 8;
    MID_SOAPS_Reset = 9;
    MID_SOAPS_SendPacket = 10;
    MID_SOAPS_SendRequest = 11;
    MID_SOAPS_Value = 12;




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
{$R 'ipssoaps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsSOAPS; event_id: Integer; cparam: Integer; 
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
  _SOAPS_Create:        function(pMethod: PEventHandle; pObject: TipsSOAPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SOAPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SOAPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SOAPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SOAPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SOAPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SOAPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SOAPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Create')]
  function _SOAPS_Create       (pMethod: TSOAPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Destroy')]
  function _SOAPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Set')]
  function _SOAPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Set')]
  function _SOAPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Set')]
  function _SOAPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Set')]
  function _SOAPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Set')]
  function _SOAPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Set')]
  function _SOAPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Get')]
  function _SOAPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Get')]
  function _SOAPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Get')]
  function _SOAPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Get')]
  function _SOAPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Get')]
  function _SOAPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Get')]
  function _SOAPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_GetLastError')]
  function _SOAPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_StaticInit')]
  function _SOAPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_CheckIndex')]
  function _SOAPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SOAPS_Do')]
  function _SOAPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _SOAPS_Create       (pMethod: PEventHandle; pObject: TipsSOAPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SOAPS_Create';
  function _SOAPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SOAPS_Destroy';
  function _SOAPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SOAPS_Set';
  function _SOAPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SOAPS_Get';
  function _SOAPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SOAPS_GetLastError';
  function _SOAPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SOAPS_StaticInit';
  function _SOAPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SOAPS_CheckIndex';
  function _SOAPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SOAPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsSOAPS; event_id: Integer;
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

      EID_SOAPS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_SOAPS_ConnectionStatus:
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
      EID_SOAPS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_SOAPS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_SOAPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_SOAPS_Header:
      begin
        if Assigned(lpContext.FOnHeader) then
        begin
          {assign temporary variables}
          tmp_HeaderField := AnsiString(PChar(params^[0]));

          tmp_HeaderValue := AnsiString(PChar(params^[1]));


          lpContext.FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



        end;
      end;
      EID_SOAPS_Redirect:
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
      EID_SOAPS_SetCookie:
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
      EID_SOAPS_SSLServerAuthentication:
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
      EID_SOAPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_SOAPS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_SOAPS_Status:
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
      EID_SOAPS_Transfer:
      begin
        if Assigned(lpContext.FOnTransfer) then
        begin
          {assign temporary variables}
          tmp_TransferBytesTransferred := LongInt(params^[0]);

          lpContext.FOnTransfer(lpContext, tmp_TransferBytesTransferred);


        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsSOAPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
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


begin
 	p := nil;
  case event_id of
    EID_SOAPS_Connected:
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
    EID_SOAPS_ConnectionStatus:
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
    EID_SOAPS_Disconnected:
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
    EID_SOAPS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_SOAPS_Error:
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
    EID_SOAPS_Header:
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
    EID_SOAPS_Redirect:
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
    EID_SOAPS_SetCookie:
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
    EID_SOAPS_SSLServerAuthentication:
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
    EID_SOAPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_SOAPS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_SOAPS_Status:
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
    EID_SOAPS_Transfer:
    begin
      if Assigned(FOnTransfer) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_TransferBytesTransferred := Marshal.ReadInt32(params, 4*0);

        FOnTransfer(lpContext, tmp_TransferBytesTransferred);


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
    RegisterComponents('IP*Works! SSL', [TipsSOAPS]);
end;

constructor TipsSOAPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _SOAPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_SOAPS_Create <> nil then
      m_ctl := _SOAPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL SOAPS: Error creating component');

{$IFDEF CLR}
    _SOAPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_55, 0);
{$ELSE}
    _SOAPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_55)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_SOAPS_Do <> nil then
      _SOAPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_Accept('') except on E:Exception do end;
    try set_ActionURI('') except on E:Exception do end;
    try set_AuthScheme(authBasic) except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_FollowRedirects(frNever) except on E:Exception do end;
    try set_Method('') except on E:Exception do end;
    try set_MethodURI('') except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_ProxyPort(80) except on E:Exception do end;
    try set_ProxyServer('') except on E:Exception do end;
    try set_SOAPEncoding('http://schemas.xmlsoap.org/soap/encoding/') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_URL('') except on E:Exception do end;
    try set_User('') except on E:Exception do end;
    try set_XPath('') except on E:Exception do end;

end;

destructor TipsSOAPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_SOAPS_Destroy <> nil then{$ENDIF}
      	_SOAPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsSOAPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsSOAPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsSOAPS.AboutDlg;
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
	if @_SOAPS_Do <> nil then
{$ENDIF}
		_SOAPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsSOAPS.SetOK(key: String128);
begin
end;

function TipsSOAPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsSOAPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsSOAPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsSOAPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsSOAPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsSOAPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_SOAPS_GetLastError <> nil then{$ENDIF}
      msg := _SOAPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsSOAPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_SOAPS_Do <> nil then
      _SOAPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsSOAPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SOAPS_Set = nil then exit;{$ENDIF}
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSOAPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SOAPS_Set = nil then exit;{$ENDIF}
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSOAPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SOAPS_Set = nil then exit;{$ENDIF}
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSOAPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SOAPS_Set = nil then exit;{$ENDIF}
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsSOAPS.get_Accept: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_Accept, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Accept, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_Accept(valAccept: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_Accept, 0, valAccept, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Accept, 0, Integer(PChar(valAccept)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ActionURI: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_ActionURI, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ActionURI, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_ActionURI(valActionURI: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_ActionURI, 0, valActionURI, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ActionURI, 0, Integer(PChar(valActionURI)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Authorization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_Authorization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Authorization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_Authorization(valAuthorization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_Authorization, 0, valAuthorization, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Authorization, 0, Integer(PChar(valAuthorization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_AuthScheme: TipssoapsAuthSchemes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssoapsAuthSchemes(_SOAPS_GetENUM(m_ctl, PID_SOAPS_AuthScheme, 0, err));
{$ELSE}
  result := TipssoapsAuthSchemes(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_AuthScheme, 0, nil);
  result := TipssoapsAuthSchemes(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_AuthScheme(valAuthScheme: TipssoapsAuthSchemes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetENUM(m_ctl, PID_SOAPS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_AuthScheme, 0, Integer(valAuthScheme), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_SOAPS_GetBOOL(m_ctl, PID_SOAPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetBOOL(m_ctl, PID_SOAPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ContentType: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_ContentType, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ContentType, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_ContentType(valContentType: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_ContentType, 0, valContentType, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ContentType, 0, Integer(PChar(valContentType)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_CookieCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SOAPS_GetINT(m_ctl, PID_SOAPS_CookieCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_CookieCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_CookieCount(valCookieCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetINT(m_ctl, PID_SOAPS_CookieCount, 0, valCookieCount, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_CookieCount, 0, Integer(valCookieCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_CookieName(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_CookieName, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_CookieName, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieName');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_CookieName, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_CookieName(CookieIndex: Word; valCookieName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_CookieName, CookieIndex, valCookieName, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_CookieName, CookieIndex, Integer(PChar(valCookieName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_CookieValue(CookieIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_CookieValue, CookieIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_CookieValue, CookieIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for CookieValue');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_CookieValue, CookieIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_CookieValue(CookieIndex: Word; valCookieValue: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_CookieValue, CookieIndex, valCookieValue, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_CookieValue, CookieIndex, Integer(PChar(valCookieValue)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_FaultActor: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_FaultActor, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FaultActor, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_FaultCode: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_FaultCode, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FaultCode, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_FaultString: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_FaultString, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FaultString, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SOAPS_GetLONG(m_ctl, PID_SOAPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetLONG(m_ctl, PID_SOAPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_FirewallType: TipssoapsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssoapsFirewallTypes(_SOAPS_GetENUM(m_ctl, PID_SOAPS_FirewallType, 0, err));
{$ELSE}
  result := TipssoapsFirewallTypes(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FirewallType, 0, nil);
  result := TipssoapsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_FirewallType(valFirewallType: TipssoapsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetENUM(m_ctl, PID_SOAPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_FollowRedirects: TipssoapsFollowRedirects;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssoapsFollowRedirects(_SOAPS_GetENUM(m_ctl, PID_SOAPS_FollowRedirects, 0, err));
{$ELSE}
  result := TipssoapsFollowRedirects(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_FollowRedirects, 0, nil);
  result := TipssoapsFollowRedirects(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_FollowRedirects(valFollowRedirects: TipssoapsFollowRedirects);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetENUM(m_ctl, PID_SOAPS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_FollowRedirects, 0, Integer(valFollowRedirects), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_OtherHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_OtherHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_OtherHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_OtherHeaders(valOtherHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_OtherHeaders, 0, valOtherHeaders, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_OtherHeaders, 0, Integer(PChar(valOtherHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_SOAPS_GetBOOL(m_ctl, PID_SOAPS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsSOAPS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Method: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_Method, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Method, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_Method(valMethod: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_Method, 0, valMethod, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Method, 0, Integer(PChar(valMethod)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_MethodURI: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_MethodURI, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_MethodURI, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_MethodURI(valMethodURI: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_MethodURI, 0, valMethodURI, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_MethodURI, 0, Integer(PChar(valMethodURI)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_NamespaceCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SOAPS_GetINT(m_ctl, PID_SOAPS_NamespaceCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_NamespaceCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_NamespaceCount(valNamespaceCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetINT(m_ctl, PID_SOAPS_NamespaceCount, 0, valNamespaceCount, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_NamespaceCount, 0, Integer(valNamespaceCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Namespaces(NamespaceIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_Namespaces, NamespaceIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_Namespaces, NamespaceIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for Namespaces');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Namespaces, NamespaceIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_Namespaces(NamespaceIndex: Word; valNamespaces: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_Namespaces, NamespaceIndex, valNamespaces, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Namespaces, NamespaceIndex, Integer(PChar(valNamespaces)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ParamAttr(ParamIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_ParamAttr, ParamIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_ParamAttr, ParamIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ParamAttr');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ParamAttr, ParamIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_ParamAttr(ParamIndex: Word; valParamAttr: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_ParamAttr, ParamIndex, valParamAttr, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ParamAttr, ParamIndex, Integer(PChar(valParamAttr)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ParamCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SOAPS_GetINT(m_ctl, PID_SOAPS_ParamCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ParamCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_ParamCount(valParamCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetINT(m_ctl, PID_SOAPS_ParamCount, 0, valParamCount, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ParamCount, 0, Integer(valParamCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ParamName(ParamIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_ParamName, ParamIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_ParamName, ParamIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ParamName');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ParamName, ParamIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_ParamName(ParamIndex: Word; valParamName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_ParamName, ParamIndex, valParamName, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ParamName, ParamIndex, Integer(PChar(valParamName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ParamValue(ParamIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_ParamValue, ParamIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_ParamValue, ParamIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ParamValue');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ParamValue, ParamIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_ParamValue(ParamIndex: Word; valParamValue: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_ParamValue, ParamIndex, valParamValue, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ParamValue, ParamIndex, Integer(PChar(valParamValue)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Pragma: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_Pragma, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Pragma, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_Pragma(valPragma: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_Pragma, 0, valPragma, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Pragma, 0, Integer(PChar(valPragma)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Prefixes(NamespaceIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_Prefixes, NamespaceIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_Prefixes, NamespaceIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for Prefixes');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Prefixes, NamespaceIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_Prefixes(NamespaceIndex: Word; valPrefixes: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_Prefixes, NamespaceIndex, valPrefixes, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Prefixes, NamespaceIndex, Integer(PChar(valPrefixes)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ProxyAuthorization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_ProxyAuthorization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ProxyAuthorization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_ProxyAuthorization(valProxyAuthorization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_ProxyAuthorization, 0, valProxyAuthorization, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ProxyAuthorization, 0, Integer(PChar(valProxyAuthorization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ProxyPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SOAPS_GetLONG(m_ctl, PID_SOAPS_ProxyPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ProxyPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_ProxyPort(valProxyPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetLONG(m_ctl, PID_SOAPS_ProxyPort, 0, valProxyPort, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ProxyPort, 0, Integer(valProxyPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ProxyServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_ProxyServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ProxyServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_ProxyServer(valProxyServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_ProxyServer, 0, valProxyServer, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ProxyServer, 0, Integer(PChar(valProxyServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_Referer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_Referer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Referer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_Referer(valReferer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_Referer, 0, valReferer, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Referer, 0, Integer(PChar(valReferer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ReturnValue: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_ReturnValue, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ReturnValue, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_SOAPEncoding: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_SOAPEncoding, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SOAPEncoding, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_SOAPEncoding(valSOAPEncoding: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_SOAPEncoding, 0, valSOAPEncoding, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SOAPEncoding, 0, Integer(PChar(valSOAPEncoding)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SOAPHeader: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_SOAPHeader, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SOAPHeader, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_SOAPHeader(valSOAPHeader: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_SOAPHeader, 0, valSOAPHeader, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SOAPHeader, 0, Integer(PChar(valSOAPHeader)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SOAPPacket: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_SOAPPacket, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SOAPPacket, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_SOAPPacket(valSOAPPacket: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_SOAPPacket, 0, valSOAPPacket, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SOAPPacket, 0, Integer(PChar(valSOAPPacket)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetBSTR(m_ctl, PID_SOAPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSOAPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetBSTR(m_ctl, PID_SOAPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetBSTR(m_ctl, PID_SOAPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSOAPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetBSTR(m_ctl, PID_SOAPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetBSTR(m_ctl, PID_SOAPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSOAPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetBSTR(m_ctl, PID_SOAPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SSLCertStoreType: TipssoapsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssoapsSSLCertStoreTypes(_SOAPS_GetENUM(m_ctl, PID_SOAPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipssoapsSSLCertStoreTypes(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SSLCertStoreType, 0, nil);
  result := TipssoapsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_SSLCertStoreType(valSSLCertStoreType: TipssoapsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetENUM(m_ctl, PID_SOAPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetBSTR(m_ctl, PID_SOAPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsSOAPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_StatusLine: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_StatusLine, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_StatusLine, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SOAPS_GetINT(m_ctl, PID_SOAPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetINT(m_ctl, PID_SOAPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_URL: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_URL, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_URL, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_URL(valURL: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_URL, 0, valURL, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_URL, 0, Integer(PChar(valURL)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_User, 0, valUser, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_ValueFormat: TipssoapsValueFormats;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssoapsValueFormats(_SOAPS_GetENUM(m_ctl, PID_SOAPS_ValueFormat, 0, err));
{$ELSE}
  result := TipssoapsValueFormats(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_ValueFormat, 0, nil);
  result := TipssoapsValueFormats(tmp);
{$ENDIF}
end;
procedure TipsSOAPS.set_ValueFormat(valValueFormat: TipssoapsValueFormats);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetENUM(m_ctl, PID_SOAPS_ValueFormat, 0, Integer(valValueFormat), 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_ValueFormat, 0, Integer(valValueFormat), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_XAttrCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SOAPS_GetINT(m_ctl, PID_SOAPS_XAttrCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XAttrCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsSOAPS.get_XAttrName(AttrIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XAttrName, AttrIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_XAttrName, AttrIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for XAttrName');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XAttrName, AttrIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_XAttrNamespace(AttrIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XAttrNamespace, AttrIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_XAttrNamespace, AttrIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for XAttrNamespace');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XAttrNamespace, AttrIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_XAttrPrefix(AttrIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XAttrPrefix, AttrIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_XAttrPrefix, AttrIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for XAttrPrefix');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XAttrPrefix, AttrIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_XAttrValue(AttrIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XAttrValue, AttrIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SOAPS_CheckIndex = nil then exit;
  err :=  _SOAPS_CheckIndex(m_ctl, PID_SOAPS_XAttrValue, AttrIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for XAttrValue');
	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XAttrValue, AttrIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_XChildren: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SOAPS_GetLONG(m_ctl, PID_SOAPS_XChildren, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XChildren, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsSOAPS.get_XElement: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XElement, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XElement, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_XNamespace: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XNamespace, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XNamespace, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_XParent: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XParent, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XParent, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_XPath: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XPath, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XPath, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSOAPS.set_XPath(valXPath: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SOAPS_SetCSTR(m_ctl, PID_SOAPS_XPath, 0, valXPath, 0);
{$ELSE}
	if @_SOAPS_Set = nil then exit;
  err := _SOAPS_Set(m_ctl, PID_SOAPS_XPath, 0, Integer(PChar(valXPath)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSOAPS.get_XPrefix: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XPrefix, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XPrefix, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSOAPS.get_XText: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SOAPS_GetCSTR(m_ctl, PID_SOAPS_XText, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SOAPS_Get = nil then exit;
  tmp := _SOAPS_Get(m_ctl, PID_SOAPS_XText, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;




{$IFNDEF DELPHI3}
function TipsSOAPS.Config(ConfigurationString: String): String;
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


  err := _SOAPS_Do(m_ctl, MID_SOAPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsSOAPS.AddCookie(CookieName: String; CookieValue: String);

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


  err := _SOAPS_Do(m_ctl, MID_SOAPS_AddCookie, 2, param, paramcb); 

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


	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_AddCookie, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.AddNamespace(Prefix: String; NamespaceURI: String);

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


  err := _SOAPS_Do(m_ctl, MID_SOAPS_AddNamespace, 2, param, paramcb); 

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


	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_AddNamespace, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.AddParam(ParamName: String; ParamValue: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(ParamName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(ParamValue);
  paramcb[i] := 0;

  i := i + 1;


  err := _SOAPS_Do(m_ctl, MID_SOAPS_AddParam, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(ParamName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(ParamValue);
  paramcb[i] := 0;

  i := i + 1;


	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_AddParam, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.BuildPacket();

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



  err := _SOAPS_Do(m_ctl, MID_SOAPS_BuildPacket, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_BuildPacket, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.DoEvents();

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



  err := _SOAPS_Do(m_ctl, MID_SOAPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.EvalPacket();

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



  err := _SOAPS_Do(m_ctl, MID_SOAPS_EvalPacket, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_EvalPacket, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.Interrupt();

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



  err := _SOAPS_Do(m_ctl, MID_SOAPS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.Reset();

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



  err := _SOAPS_Do(m_ctl, MID_SOAPS_Reset, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_Reset, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.SendPacket();

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



  err := _SOAPS_Do(m_ctl, MID_SOAPS_SendPacket, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_SendPacket, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSOAPS.SendRequest();

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



  err := _SOAPS_Do(m_ctl, MID_SOAPS_SendRequest, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_SendRequest, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsSOAPS.Value(ParamName: String): String;
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

  param[i] := Marshal.StringToHGlobalAnsi(ParamName);
  paramcb[i] := 0;

  i := i + 1;


  err := _SOAPS_Do(m_ctl, MID_SOAPS_Value, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ParamName);
  paramcb[i] := 0;

  i := i + 1;


	if @_SOAPS_Do = nil then exit;
  err := _SOAPS_Do(m_ctl, MID_SOAPS_Value, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

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

	_SOAPS_Create := nil;
	_SOAPS_Destroy := nil;
	_SOAPS_Set := nil;
	_SOAPS_Get := nil;
	_SOAPS_GetLastError := nil;
	_SOAPS_StaticInit := nil;
	_SOAPS_CheckIndex := nil;
	_SOAPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_soaps_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_SOAPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'SOAPS_Create');
		@_SOAPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'SOAPS_Destroy');
		@_SOAPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'SOAPS_Set');
		@_SOAPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'SOAPS_Get');
		@_SOAPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'SOAPS_GetLastError');
		@_SOAPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'SOAPS_CheckIndex');
		@_SOAPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'SOAPS_Do');
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
  @_SOAPS_Create       := nil;
  @_SOAPS_Destroy      := nil;
  @_SOAPS_Set          := nil;
  @_SOAPS_Get          := nil;
  @_SOAPS_GetLastError := nil;
  @_SOAPS_CheckIndex   := nil;
  @_SOAPS_Do           := nil;
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




