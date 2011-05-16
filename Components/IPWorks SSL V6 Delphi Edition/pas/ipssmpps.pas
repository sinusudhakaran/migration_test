
unit ipssmpps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipssmppsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipssmppsMessagePriorities = 
(

									 
                   smppMessagePriorityLow,

									 
                   smppMessagePriorityNormal,

									 
                   smppMessagePriorityHigh,

									 
                   smppMessagePriorityUrgent
);
  TipssmppsRecipientTypes = 
(

									 
                   smppRecipientTypeNormal,

									 
                   smppRecipientTypeList
);
  TipssmppsServiceTypes = 
(

									 
                   smppServiceDefault,

									 
                   smppServiceCMT,

									 
                   smppServiceCPT,

									 
                   smppServiceVMN,

									 
                   smppServiceVMA,

									 
                   smppServiceWAP,

									 
                   smppServiceUSSD,

									 
                   smppServiceCBS
);
  TipssmppsSMPPVersions = 
(

									 
                   smppVersion50,

									 
                   smppVersion34,

									 
                   smppVersion33
);
  TipssmppsSSLCertStoreTypes = 
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

  TErrorEvent = procedure(Sender: TObject;
                            ErrorCode: Integer;
                            const Description: String) of Object;

  TPITrailEvent = procedure(Sender: TObject;
                            Direction: Integer;
                            PDU: String) of Object;
{$IFDEF CLR}
  TPITrailEventB = procedure(Sender: TObject;
                            Direction: Integer;
                            PDU: Array of Byte) of Object;

{$ENDIF}
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


{$IFDEF CLR}
  TSMPPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsSMPPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsSMPPS = class(TipsCore)
    public
      FOnConnected: TConnectedEvent;

      FOnConnectionStatus: TConnectionStatusEvent;

      FOnDisconnected: TDisconnectedEvent;

      FOnError: TErrorEvent;

      FOnPITrail: TPITrailEvent;
			{$IFDEF CLR}FOnPITrailB: TPITrailEventB;{$ENDIF}
      FOnSSLServerAuthentication: TSSLServerAuthenticationEvent;
			{$IFDEF CLR}FOnSSLServerAuthenticationB: TSSLServerAuthenticationEventB;{$ENDIF}
      FOnSSLStatus: TSSLStatusEvent;


    private
      tmp_SSLServerAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TSMPPSEventHook;
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

      function get_MessageId: String;


      function get_Recipient: String;
      procedure set_Recipient(valRecipient: String);

      function get_RecipientAddress(RecipientIdx: Word): String;
      procedure set_RecipientAddress(RecipientIdx: Word; valRecipientAddress: String);

      function get_RecipientCount: Integer;
      procedure set_RecipientCount(valRecipientCount: Integer);

      function get_RecipientType(RecipientIdx: Word): TipssmppsRecipientTypes;
      procedure set_RecipientType(RecipientIdx: Word; valRecipientType: TipssmppsRecipientTypes);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);


      procedure TreatErr(Err: integer; const desc: string);


      function get_Connected: Boolean;


      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipssmppsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipssmppsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_MessageExpiration: String;
      procedure set_MessageExpiration(valMessageExpiration: String);



      function get_MessagePriority: TipssmppsMessagePriorities;
      procedure set_MessagePriority(valMessagePriority: TipssmppsMessagePriorities);

      function get_Password: String;
      procedure set_Password(valPassword: String);









      function get_ScheduledDelivery: String;
      procedure set_ScheduledDelivery(valScheduledDelivery: String);

      function get_ServiceType: TipssmppsServiceTypes;
      procedure set_ServiceType(valServiceType: TipssmppsServiceTypes);

      function get_SMPPPort: Integer;
      procedure set_SMPPPort(valSMPPPort: Integer);

      function get_SMPPServer: String;
      procedure set_SMPPServer(valSMPPServer: String);

      function get_SMPPVersion: TipssmppsSMPPVersions;
      procedure set_SMPPVersion(valSMPPVersion: TipssmppsSMPPVersions);

      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipssmppsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipssmppsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SystemType: String;
      procedure set_SystemType(valSystemType: String);

      function get_Timeout: Integer;
      procedure set_Timeout(valTimeout: Integer);

      function get_UserId: String;
      procedure set_UserId(valUserId: String);



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















      property MessageId: String
               read get_MessageId
               ;





      property Recipient: String
               read get_Recipient
               write set_Recipient               ;

      property RecipientAddress[RecipientIdx: Word]: String
               read get_RecipientAddress
               write set_RecipientAddress               ;

      property RecipientCount: Integer
               read get_RecipientCount
               write set_RecipientCount               ;

      property RecipientType[RecipientIdx: Word]: TipssmppsRecipientTypes
               read get_RecipientType
               write set_RecipientType               ;













      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;





















{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure AddRecipient(RecipientType: Integer; RecipientAddress: String);

      procedure CancelMessage(MessageId: String);

      procedure CheckLink();

      function CheckMessage(MessageId: String): String;
      procedure Connect(UserId: String; Password: String);

      procedure Disconnect();

      procedure ReplaceMessage(MessageId: String; NewMessage: String);

      function SendCommand(CommandId: Integer; Payload: String): String;
      function SendData(Data: String): String;
      function SendMessage(Message: String): String;

{$ENDIF}

    published

      property Connected: Boolean
                   read get_Connected
                    write SetNoopBoolean
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
      property FirewallType: TipssmppsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property MessageExpiration: String
                   read get_MessageExpiration
                   write set_MessageExpiration
                   
                   ;

      property MessagePriority: TipssmppsMessagePriorities
                   read get_MessagePriority
                   write set_MessagePriority
                   default smppMessagePriorityLow
                   ;
      property Password: String
                   read get_Password
                   write set_Password
                   
                   ;




      property ScheduledDelivery: String
                   read get_ScheduledDelivery
                   write set_ScheduledDelivery
                   
                   ;
      property ServiceType: TipssmppsServiceTypes
                   read get_ServiceType
                   write set_ServiceType
                   default smppServiceDefault
                   ;
      property SMPPPort: Integer
                   read get_SMPPPort
                   write set_SMPPPort
                   default 3551
                   ;
      property SMPPServer: String
                   read get_SMPPServer
                   write set_SMPPServer
                   
                   ;
      property SMPPVersion: TipssmppsSMPPVersions
                   read get_SMPPVersion
                   write set_SMPPVersion
                   default smppVersion50
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
      property SSLCertStoreType: TipssmppsSSLCertStoreTypes
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
      property SystemType: String
                   read get_SystemType
                   write set_SystemType
                   
                   ;
      property Timeout: Integer
                   read get_Timeout
                   write set_Timeout
                   default 60
                   ;
      property UserId: String
                   read get_UserId
                   write set_UserId
                   
                   ;


      property OnConnected: TConnectedEvent read FOnConnected write FOnConnected;

      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnDisconnected: TDisconnectedEvent read FOnDisconnected write FOnDisconnected;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnPITrail: TPITrailEvent read FOnPITrail write FOnPITrail;
			{$IFDEF CLR}property OnPITrailB: TPITrailEventB read FOnPITrailB write FOnPITrailB;{$ENDIF}
      property OnSSLServerAuthentication: TSSLServerAuthenticationEvent read FOnSSLServerAuthentication write FOnSSLServerAuthentication;
			{$IFDEF CLR}property OnSSLServerAuthenticationB: TSSLServerAuthenticationEventB read FOnSSLServerAuthenticationB write FOnSSLServerAuthenticationB;{$ENDIF}
      property OnSSLStatus: TSSLStatusEvent read FOnSSLStatus write FOnSSLStatus;


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
    PID_SMPPS_Connected = 1;
    PID_SMPPS_FirewallHost = 2;
    PID_SMPPS_FirewallPassword = 3;
    PID_SMPPS_FirewallPort = 4;
    PID_SMPPS_FirewallType = 5;
    PID_SMPPS_FirewallUser = 6;
    PID_SMPPS_MessageExpiration = 7;
    PID_SMPPS_MessageId = 8;
    PID_SMPPS_MessagePriority = 9;
    PID_SMPPS_Password = 10;
    PID_SMPPS_Recipient = 11;
    PID_SMPPS_RecipientAddress = 12;
    PID_SMPPS_RecipientCount = 13;
    PID_SMPPS_RecipientType = 14;
    PID_SMPPS_ScheduledDelivery = 15;
    PID_SMPPS_ServiceType = 16;
    PID_SMPPS_SMPPPort = 17;
    PID_SMPPS_SMPPServer = 18;
    PID_SMPPS_SMPPVersion = 19;
    PID_SMPPS_SSLAcceptServerCert = 20;
    PID_SMPPS_SSLCertEncoded = 21;
    PID_SMPPS_SSLCertStore = 22;
    PID_SMPPS_SSLCertStorePassword = 23;
    PID_SMPPS_SSLCertStoreType = 24;
    PID_SMPPS_SSLCertSubject = 25;
    PID_SMPPS_SSLServerCert = 26;
    PID_SMPPS_SSLServerCertStatus = 27;
    PID_SMPPS_SystemType = 28;
    PID_SMPPS_Timeout = 29;
    PID_SMPPS_UserId = 30;

    EID_SMPPS_Connected = 1;
    EID_SMPPS_ConnectionStatus = 2;
    EID_SMPPS_Disconnected = 3;
    EID_SMPPS_Error = 4;
    EID_SMPPS_PITrail = 5;
    EID_SMPPS_SSLServerAuthentication = 6;
    EID_SMPPS_SSLStatus = 7;


    MID_SMPPS_Config = 1;
    MID_SMPPS_AddRecipient = 2;
    MID_SMPPS_CancelMessage = 3;
    MID_SMPPS_CheckLink = 4;
    MID_SMPPS_CheckMessage = 5;
    MID_SMPPS_Connect = 6;
    MID_SMPPS_Disconnect = 7;
    MID_SMPPS_ReplaceMessage = 8;
    MID_SMPPS_SendCommand = 9;
    MID_SMPPS_SendData = 10;
    MID_SMPPS_SendMessage = 11;




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
{$R 'ipssmpps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsSMPPS; event_id: Integer; cparam: Integer; 
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
  _SMPPS_Create:        function(pMethod: PEventHandle; pObject: TipsSMPPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMPPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMPPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMPPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMPPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMPPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMPPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMPPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Create')]
  function _SMPPS_Create       (pMethod: TSMPPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Destroy')]
  function _SMPPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Set')]
  function _SMPPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Set')]
  function _SMPPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Set')]
  function _SMPPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Set')]
  function _SMPPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Set')]
  function _SMPPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Set')]
  function _SMPPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Get')]
  function _SMPPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Get')]
  function _SMPPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Get')]
  function _SMPPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Get')]
  function _SMPPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Get')]
  function _SMPPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Get')]
  function _SMPPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_GetLastError')]
  function _SMPPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_StaticInit')]
  function _SMPPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_CheckIndex')]
  function _SMPPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMPPS_Do')]
  function _SMPPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _SMPPS_Create       (pMethod: PEventHandle; pObject: TipsSMPPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMPPS_Create';
  function _SMPPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMPPS_Destroy';
  function _SMPPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMPPS_Set';
  function _SMPPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMPPS_Get';
  function _SMPPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMPPS_GetLastError';
  function _SMPPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMPPS_StaticInit';
  function _SMPPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMPPS_CheckIndex';
  function _SMPPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMPPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsSMPPS; event_id: Integer;
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
    tmp_PITrailDirection: Integer;
    tmp_PITrailPDU: String;
    tmp_SSLServerAuthenticationCertEncoded: String;
    tmp_SSLServerAuthenticationCertSubject: String;
    tmp_SSLServerAuthenticationCertIssuer: String;
    tmp_SSLServerAuthenticationStatus: String;
    tmp_SSLStatusMessage: String;

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

      EID_SMPPS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_SMPPS_ConnectionStatus:
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
      EID_SMPPS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_SMPPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_SMPPS_PITrail:
      begin
        if Assigned(lpContext.FOnPITrail) then
        begin
          {assign temporary variables}
          tmp_PITrailDirection := Integer(params^[0]);
          SetString(tmp_PITrailPDU, PChar(params^[1]), cbparam^[1]);


          lpContext.FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailPDU);



        end;
      end;
      EID_SMPPS_SSLServerAuthentication:
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
      EID_SMPPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsSMPPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
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

  tmp_PITrailDirection: Integer;
  tmp_PITrailPDU: String;

  tmp_PITrailPDUB: Array of Byte;
  tmp_SSLServerAuthenticationCertEncoded: String;
  tmp_SSLServerAuthenticationCertSubject: String;
  tmp_SSLServerAuthenticationCertIssuer: String;
  tmp_SSLServerAuthenticationStatus: String;

  tmp_SSLServerAuthenticationCertEncodedB: Array of Byte;
  tmp_SSLStatusMessage: String;


begin
 	p := nil;
  case event_id of
    EID_SMPPS_Connected:
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
    EID_SMPPS_ConnectionStatus:
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
    EID_SMPPS_Disconnected:
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
    EID_SMPPS_Error:
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
    EID_SMPPS_PITrail:
    begin
      if Assigned(FOnPITrail) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_PITrailDirection := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_PITrailPDU := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*1));


        FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailPDU);



      end;

      if Assigned(FOnPITrailB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_PITrailDirection := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        SetLength(tmp_PITrailPDUB, Marshal.ReadInt32(cbparam, 4 * 1)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 1), tmp_PITrailPDUB,
        						 0, Length(tmp_PITrailPDUB));


        FOnPITrailB(lpContext, tmp_PITrailDirection, tmp_PITrailPDUB);



      end;
    end;
    EID_SMPPS_SSLServerAuthentication:
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
    EID_SMPPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


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
    RegisterComponents('IP*Works! SSL', [TipsSMPPS]);
end;

constructor TipsSMPPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _SMPPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_SMPPS_Create <> nil then
      m_ctl := _SMPPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL SMPPS: Error creating component');

{$IFDEF CLR}
    _SMPPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_71, 0);
{$ELSE}
    _SMPPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_71)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_SMPPS_Do <> nil then
      _SMPPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_MessageExpiration('') except on E:Exception do end;
    try set_MessagePriority(smppMessagePriorityLow) except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_ScheduledDelivery('') except on E:Exception do end;
    try set_ServiceType(smppServiceDefault) except on E:Exception do end;
    try set_SMPPPort(3551) except on E:Exception do end;
    try set_SMPPServer('') except on E:Exception do end;
    try set_SMPPVersion(smppVersion50) except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SystemType('') except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_UserId('') except on E:Exception do end;

end;

destructor TipsSMPPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_SMPPS_Destroy <> nil then{$ENDIF}
      	_SMPPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsSMPPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsSMPPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsSMPPS.AboutDlg;
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
	if @_SMPPS_Do <> nil then
{$ENDIF}
		_SMPPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsSMPPS.SetOK(key: String128);
begin
end;

function TipsSMPPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsSMPPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsSMPPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsSMPPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsSMPPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsSMPPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_SMPPS_GetLastError <> nil then{$ENDIF}
      msg := _SMPPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsSMPPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_SMPPS_Do <> nil then
      _SMPPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsSMPPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SMPPS_Set = nil then exit;{$ENDIF}
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSMPPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SMPPS_Set = nil then exit;{$ENDIF}
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSMPPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SMPPS_Set = nil then exit;{$ENDIF}
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSMPPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SMPPS_Set = nil then exit;{$ENDIF}
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsSMPPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_SMPPS_GetBOOL(m_ctl, PID_SMPPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsSMPPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SMPPS_GetLONG(m_ctl, PID_SMPPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetLONG(m_ctl, PID_SMPPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_FirewallType: TipssmppsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmppsFirewallTypes(_SMPPS_GetENUM(m_ctl, PID_SMPPS_FirewallType, 0, err));
{$ELSE}
  result := TipssmppsFirewallTypes(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_FirewallType, 0, nil);
  result := TipssmppsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_FirewallType(valFirewallType: TipssmppsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetENUM(m_ctl, PID_SMPPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_MessageExpiration: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_MessageExpiration, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_MessageExpiration, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_MessageExpiration(valMessageExpiration: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_MessageExpiration, 0, valMessageExpiration, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_MessageExpiration, 0, Integer(PChar(valMessageExpiration)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_MessageId: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_MessageId, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_MessageId, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSMPPS.get_MessagePriority: TipssmppsMessagePriorities;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmppsMessagePriorities(_SMPPS_GetENUM(m_ctl, PID_SMPPS_MessagePriority, 0, err));
{$ELSE}
  result := TipssmppsMessagePriorities(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_MessagePriority, 0, nil);
  result := TipssmppsMessagePriorities(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_MessagePriority(valMessagePriority: TipssmppsMessagePriorities);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetENUM(m_ctl, PID_SMPPS_MessagePriority, 0, Integer(valMessagePriority), 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_MessagePriority, 0, Integer(valMessagePriority), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_Recipient: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_Recipient, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_Recipient, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_Recipient(valRecipient: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_Recipient, 0, valRecipient, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_Recipient, 0, Integer(PChar(valRecipient)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_RecipientAddress(RecipientIdx: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_RecipientAddress, RecipientIdx, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_SMPPS_CheckIndex = nil then exit;
  err :=  _SMPPS_CheckIndex(m_ctl, PID_SMPPS_RecipientAddress, RecipientIdx);
  if err <> 0 then TreatErr(err, 'Invalid array index value for RecipientAddress');
	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_RecipientAddress, RecipientIdx, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_RecipientAddress(RecipientIdx: Word; valRecipientAddress: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_RecipientAddress, RecipientIdx, valRecipientAddress, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_RecipientAddress, RecipientIdx, Integer(PChar(valRecipientAddress)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_RecipientCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SMPPS_GetINT(m_ctl, PID_SMPPS_RecipientCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_RecipientCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_RecipientCount(valRecipientCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetINT(m_ctl, PID_SMPPS_RecipientCount, 0, valRecipientCount, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_RecipientCount, 0, Integer(valRecipientCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_RecipientType(RecipientIdx: Word): TipssmppsRecipientTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmppsRecipientTypes(_SMPPS_GetENUM(m_ctl, PID_SMPPS_RecipientType, RecipientIdx, err));
{$ELSE}
  result := TipssmppsRecipientTypes(0);
  if @_SMPPS_CheckIndex = nil then exit;
  err :=  _SMPPS_CheckIndex(m_ctl, PID_SMPPS_RecipientType, RecipientIdx);
  if err <> 0 then TreatErr(err, 'Invalid array index value for RecipientType');
	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_RecipientType, RecipientIdx, nil);
  result := TipssmppsRecipientTypes(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_RecipientType(RecipientIdx: Word; valRecipientType: TipssmppsRecipientTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetENUM(m_ctl, PID_SMPPS_RecipientType, RecipientIdx, Integer(valRecipientType), 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_RecipientType, RecipientIdx, Integer(valRecipientType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_ScheduledDelivery: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_ScheduledDelivery, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_ScheduledDelivery, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_ScheduledDelivery(valScheduledDelivery: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_ScheduledDelivery, 0, valScheduledDelivery, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_ScheduledDelivery, 0, Integer(PChar(valScheduledDelivery)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_ServiceType: TipssmppsServiceTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmppsServiceTypes(_SMPPS_GetENUM(m_ctl, PID_SMPPS_ServiceType, 0, err));
{$ELSE}
  result := TipssmppsServiceTypes(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_ServiceType, 0, nil);
  result := TipssmppsServiceTypes(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_ServiceType(valServiceType: TipssmppsServiceTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetENUM(m_ctl, PID_SMPPS_ServiceType, 0, Integer(valServiceType), 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_ServiceType, 0, Integer(valServiceType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SMPPPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SMPPS_GetINT(m_ctl, PID_SMPPS_SMPPPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SMPPPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_SMPPPort(valSMPPPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetINT(m_ctl, PID_SMPPS_SMPPPort, 0, valSMPPPort, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SMPPPort, 0, Integer(valSMPPPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SMPPServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_SMPPServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SMPPServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_SMPPServer(valSMPPServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_SMPPServer, 0, valSMPPServer, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SMPPServer, 0, Integer(PChar(valSMPPServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SMPPVersion: TipssmppsSMPPVersions;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmppsSMPPVersions(_SMPPS_GetENUM(m_ctl, PID_SMPPS_SMPPVersion, 0, err));
{$ELSE}
  result := TipssmppsSMPPVersions(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SMPPVersion, 0, nil);
  result := TipssmppsSMPPVersions(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_SMPPVersion(valSMPPVersion: TipssmppsSMPPVersions);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetENUM(m_ctl, PID_SMPPS_SMPPVersion, 0, Integer(valSMPPVersion), 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SMPPVersion, 0, Integer(valSMPPVersion), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetBSTR(m_ctl, PID_SMPPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSMPPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetBSTR(m_ctl, PID_SMPPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetBSTR(m_ctl, PID_SMPPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSMPPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetBSTR(m_ctl, PID_SMPPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetBSTR(m_ctl, PID_SMPPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSMPPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetBSTR(m_ctl, PID_SMPPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SSLCertStoreType: TipssmppsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmppsSSLCertStoreTypes(_SMPPS_GetENUM(m_ctl, PID_SMPPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipssmppsSSLCertStoreTypes(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SSLCertStoreType, 0, nil);
  result := TipssmppsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_SSLCertStoreType(valSSLCertStoreType: TipssmppsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetENUM(m_ctl, PID_SMPPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetBSTR(m_ctl, PID_SMPPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsSMPPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSMPPS.get_SystemType: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_SystemType, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_SystemType, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_SystemType(valSystemType: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_SystemType, 0, valSystemType, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_SystemType, 0, Integer(PChar(valSystemType)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SMPPS_GetINT(m_ctl, PID_SMPPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSMPPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetINT(m_ctl, PID_SMPPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMPPS.get_UserId: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMPPS_GetCSTR(m_ctl, PID_SMPPS_UserId, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMPPS_Get = nil then exit;
  tmp := _SMPPS_Get(m_ctl, PID_SMPPS_UserId, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMPPS.set_UserId(valUserId: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMPPS_SetCSTR(m_ctl, PID_SMPPS_UserId, 0, valUserId, 0);
{$ELSE}
	if @_SMPPS_Set = nil then exit;
  err := _SMPPS_Set(m_ctl, PID_SMPPS_UserId, 0, Integer(PChar(valUserId)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsSMPPS.Config(ConfigurationString: String): String;
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


  err := _SMPPS_Do(m_ctl, MID_SMPPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsSMPPS.AddRecipient(RecipientType: Integer; RecipientAddress: String);

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

  param[i] := IntPtr(RecipientType);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(RecipientAddress);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMPPS_Do(m_ctl, MID_SMPPS_AddRecipient, 2, param, paramcb); 


	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := Pointer(RecipientType);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := PChar(RecipientAddress);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_AddRecipient, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMPPS.CancelMessage(MessageId: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(MessageId);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMPPS_Do(m_ctl, MID_SMPPS_CancelMessage, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(MessageId);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_CancelMessage, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMPPS.CheckLink();

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



  err := _SMPPS_Do(m_ctl, MID_SMPPS_CheckLink, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_CheckLink, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsSMPPS.CheckMessage(MessageId: String): String;
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

  param[i] := Marshal.StringToHGlobalAnsi(MessageId);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMPPS_Do(m_ctl, MID_SMPPS_CheckMessage, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(MessageId);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_CheckMessage, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsSMPPS.Connect(UserId: String; Password: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(UserId);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Password);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMPPS_Do(m_ctl, MID_SMPPS_Connect, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(UserId);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Password);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_Connect, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMPPS.Disconnect();

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



  err := _SMPPS_Do(m_ctl, MID_SMPPS_Disconnect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_Disconnect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMPPS.ReplaceMessage(MessageId: String; NewMessage: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(MessageId);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(NewMessage);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMPPS_Do(m_ctl, MID_SMPPS_ReplaceMessage, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(MessageId);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(NewMessage);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_ReplaceMessage, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsSMPPS.SendCommand(CommandId: Integer; Payload: String): String;
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

  param[i] := IntPtr(CommandId);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Payload);
  paramcb[i] := Length(Payload);

  i := i + 1;


  err := _SMPPS_Do(m_ctl, MID_SMPPS_SendCommand, 2, param, paramcb); 


	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);


  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i], paramcb[i]);


{$ELSE}
  result := '';

  param[i] := Pointer(CommandId);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := PChar(Payload);
  paramcb[i] := Length(Payload);

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_SendCommand, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  SetString(result, PChar(param[i]), paramcb[i]);

{$ENDIF}
end;

function TipsSMPPS.SendData(Data: String): String;
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

  param[i] := Marshal.StringToHGlobalAnsi(Data);
  paramcb[i] := Length(Data);

  i := i + 1;


  err := _SMPPS_Do(m_ctl, MID_SMPPS_SendData, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);


  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(Data);
  paramcb[i] := Length(Data);

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_SendData, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

function TipsSMPPS.SendMessage(Message: String): String;
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

  param[i] := Marshal.StringToHGlobalAnsi(Message);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMPPS_Do(m_ctl, MID_SMPPS_SendMessage, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(Message);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMPPS_Do = nil then exit;
  err := _SMPPS_Do(m_ctl, MID_SMPPS_SendMessage, 1, @param, @paramcb); 
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

	_SMPPS_Create := nil;
	_SMPPS_Destroy := nil;
	_SMPPS_Set := nil;
	_SMPPS_Get := nil;
	_SMPPS_GetLastError := nil;
	_SMPPS_StaticInit := nil;
	_SMPPS_CheckIndex := nil;
	_SMPPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_smpps_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_SMPPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'SMPPS_Create');
		@_SMPPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'SMPPS_Destroy');
		@_SMPPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'SMPPS_Set');
		@_SMPPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'SMPPS_Get');
		@_SMPPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'SMPPS_GetLastError');
		@_SMPPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'SMPPS_CheckIndex');
		@_SMPPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'SMPPS_Do');
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
  @_SMPPS_Create       := nil;
  @_SMPPS_Destroy      := nil;
  @_SMPPS_Set          := nil;
  @_SMPPS_Get          := nil;
  @_SMPPS_GetLastError := nil;
  @_SMPPS_CheckIndex   := nil;
  @_SMPPS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




