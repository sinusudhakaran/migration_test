
unit ipstelnets;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipstelnetsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipstelnetsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipstelnetsSSLStartModes = 
(

									 
                   sslAutomatic,

									 
                   sslImplicit,

									 
                   sslExplicit,

									 
                   sslNone
);


  TCommandEvent = procedure(Sender: TObject;
                            CommandCode: Integer) of Object;

  TConnectedEvent = procedure(Sender: TObject;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TConnectionStatusEvent = procedure(Sender: TObject;
                            const ConnectionEvent: String;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TDataInEvent = procedure(Sender: TObject;
                            Text: String) of Object;
{$IFDEF CLR}
  TDataInEventB = procedure(Sender: TObject;
                            Text: Array of Byte) of Object;

{$ENDIF}
  TDisconnectedEvent = procedure(Sender: TObject;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TDoEvent = procedure(Sender: TObject;
                            OptionCode: Integer) of Object;

  TDontEvent = procedure(Sender: TObject;
                            OptionCode: Integer) of Object;

  TErrorEvent = procedure(Sender: TObject;
                            ErrorCode: Integer;
                            const Description: String) of Object;

  TReadyToSendEvent = procedure(Sender: TObject) of Object;

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

  TSubOptionEvent = procedure(Sender: TObject;
                            SubOption: String) of Object;
{$IFDEF CLR}
  TSubOptionEventB = procedure(Sender: TObject;
                            SubOption: Array of Byte) of Object;

{$ENDIF}
  TWillEvent = procedure(Sender: TObject;
                            OptionCode: Integer) of Object;

  TWontEvent = procedure(Sender: TObject;
                            OptionCode: Integer) of Object;


{$IFDEF CLR}
  TTelnetSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsTelnetS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsTelnetS = class(TipsCore)
    public
      FOnCommand: TCommandEvent;

      FOnConnected: TConnectedEvent;

      FOnConnectionStatus: TConnectionStatusEvent;

      FOnDataIn: TDataInEvent;
			{$IFDEF CLR}FOnDataInB: TDataInEventB;{$ENDIF}
      FOnDisconnected: TDisconnectedEvent;

      FOnDo: TDoEvent;

      FOnDont: TDontEvent;

      FOnError: TErrorEvent;

      FOnReadyToSend: TReadyToSendEvent;

      FOnSSLServerAuthentication: TSSLServerAuthenticationEvent;
			{$IFDEF CLR}FOnSSLServerAuthenticationB: TSSLServerAuthenticationEventB;{$ENDIF}
      FOnSSLStatus: TSSLStatusEvent;

      FOnSubOption: TSubOptionEvent;
			{$IFDEF CLR}FOnSubOptionB: TSubOptionEventB;{$ENDIF}
      FOnWill: TWillEvent;

      FOnWont: TWontEvent;


    private
      tmp_SSLServerAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TTelnetSEventHook;
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

      function get_AcceptData: Boolean;
      procedure set_AcceptData(valAcceptData: Boolean);

      function get_BytesSent: Integer;



      procedure set_Command(valCommand: Integer);

      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);


      procedure set_StringDataToSend(valDataToSend: String);


      procedure set_DontOption(valDontOption: Integer);


      procedure set_DoOption(valDoOption: Integer);


      procedure set_StringDoSubOption(valDoSubOption: String);

      function get_RemotePort: Integer;
      procedure set_RemotePort(valRemotePort: Integer);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);


      procedure set_StringUrgentData(valUrgentData: String);


      procedure set_WillOption(valWillOption: Integer);


      procedure set_WontOption(valWontOption: Integer);


      procedure TreatErr(Err: integer; const desc: string);


















      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipstelnetsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipstelnetsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_KeepAlive: Boolean;
      procedure set_KeepAlive(valKeepAlive: Boolean);

      function get_Linger: Boolean;
      procedure set_Linger(valLinger: Boolean);

      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);

      function get_LocalPort: Integer;
      procedure set_LocalPort(valLocalPort: Integer);

      function get_RemoteHost: String;
      procedure set_RemoteHost(valRemoteHost: String);



      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipstelnetsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipstelnetsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipstelnetsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipstelnetsSSLStartModes);

      function get_Timeout: Integer;
      procedure set_Timeout(valTimeout: Integer);

      function get_Transparent: Boolean;
      procedure set_Transparent(valTransparent: Boolean);









    public

      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      property OK: String128 read GetOK write SetOK;

{$IFNDEF CLR}
      procedure SetDataToSend(lpDataToSend: PChar; lenDataToSend: Cardinal);
      procedure SetDoSubOption(lpDoSubOption: PChar; lenDoSubOption: Cardinal);
      procedure SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
      procedure SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
      procedure SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
      procedure SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
      procedure SetUrgentData(lpUrgentData: PChar; lenUrgentData: Cardinal);

{$ENDIF}

      property AcceptData: Boolean
               read get_AcceptData
               write set_AcceptData               ;

      property BytesSent: Integer
               read get_BytesSent
               ;

      property Command: Integer

               write set_Command               ;

      property Connected: Boolean
               read get_Connected
               write set_Connected               ;

      property DataToSend: String

               write set_StringDataToSend               ;

      property DontOption: Integer

               write set_DontOption               ;

      property DoOption: Integer

               write set_DoOption               ;

      property DoSubOption: String

               write set_StringDoSubOption               ;





















      property RemotePort: Integer
               read get_RemotePort
               write set_RemotePort               ;



      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;



















      property UrgentData: String

               write set_StringUrgentData               ;

      property WillOption: Integer

               write set_WillOption               ;

      property WontOption: Integer

               write set_WontOption               ;



{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure Connect(Host: String);

      procedure Disconnect();

      procedure DoEvents();

      procedure Send(Text: String);


{$ENDIF}

    published









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
      property FirewallType: TipstelnetsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property KeepAlive: Boolean
                   read get_KeepAlive
                   write set_KeepAlive
                   default False
                   ;
      property Linger: Boolean
                   read get_Linger
                   write set_Linger
                   default True
                   ;
      property LocalHost: String
                   read get_LocalHost
                   write set_LocalHost
                   stored False

                   ;
      property LocalPort: Integer
                   read get_LocalPort
                   write set_LocalPort
                   default 0
                   ;
      property RemoteHost: String
                   read get_RemoteHost
                   write set_RemoteHost
                   
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
      property SSLCertStoreType: TipstelnetsSSLCertStoreTypes
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
      property SSLStartMode: TipstelnetsSSLStartModes
                   read get_SSLStartMode
                   write set_SSLStartMode
                   default sslAutomatic
                   ;
      property Timeout: Integer
                   read get_Timeout
                   write set_Timeout
                   default 0
                   ;
      property Transparent: Boolean
                   read get_Transparent
                   write set_Transparent
                   default false
                   ;





      property OnCommand: TCommandEvent read FOnCommand write FOnCommand;

      property OnConnected: TConnectedEvent read FOnConnected write FOnConnected;

      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnDataIn: TDataInEvent read FOnDataIn write FOnDataIn;
			{$IFDEF CLR}property OnDataInB: TDataInEventB read FOnDataInB write FOnDataInB;{$ENDIF}
      property OnDisconnected: TDisconnectedEvent read FOnDisconnected write FOnDisconnected;

      property OnDo: TDoEvent read FOnDo write FOnDo;

      property OnDont: TDontEvent read FOnDont write FOnDont;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnReadyToSend: TReadyToSendEvent read FOnReadyToSend write FOnReadyToSend;

      property OnSSLServerAuthentication: TSSLServerAuthenticationEvent read FOnSSLServerAuthentication write FOnSSLServerAuthentication;
			{$IFDEF CLR}property OnSSLServerAuthenticationB: TSSLServerAuthenticationEventB read FOnSSLServerAuthenticationB write FOnSSLServerAuthenticationB;{$ENDIF}
      property OnSSLStatus: TSSLStatusEvent read FOnSSLStatus write FOnSSLStatus;

      property OnSubOption: TSubOptionEvent read FOnSubOption write FOnSubOption;
			{$IFDEF CLR}property OnSubOptionB: TSubOptionEventB read FOnSubOptionB write FOnSubOptionB;{$ENDIF}
      property OnWill: TWillEvent read FOnWill write FOnWill;

      property OnWont: TWontEvent read FOnWont write FOnWont;


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
    PID_TelnetS_AcceptData = 1;
    PID_TelnetS_BytesSent = 2;
    PID_TelnetS_Command = 3;
    PID_TelnetS_Connected = 4;
    PID_TelnetS_DataToSend = 5;
    PID_TelnetS_DontOption = 6;
    PID_TelnetS_DoOption = 7;
    PID_TelnetS_DoSubOption = 8;
    PID_TelnetS_FirewallHost = 9;
    PID_TelnetS_FirewallPassword = 10;
    PID_TelnetS_FirewallPort = 11;
    PID_TelnetS_FirewallType = 12;
    PID_TelnetS_FirewallUser = 13;
    PID_TelnetS_KeepAlive = 14;
    PID_TelnetS_Linger = 15;
    PID_TelnetS_LocalHost = 16;
    PID_TelnetS_LocalPort = 17;
    PID_TelnetS_RemoteHost = 18;
    PID_TelnetS_RemotePort = 19;
    PID_TelnetS_SSLAcceptServerCert = 20;
    PID_TelnetS_SSLCertEncoded = 21;
    PID_TelnetS_SSLCertStore = 22;
    PID_TelnetS_SSLCertStorePassword = 23;
    PID_TelnetS_SSLCertStoreType = 24;
    PID_TelnetS_SSLCertSubject = 25;
    PID_TelnetS_SSLServerCert = 26;
    PID_TelnetS_SSLServerCertStatus = 27;
    PID_TelnetS_SSLStartMode = 28;
    PID_TelnetS_Timeout = 29;
    PID_TelnetS_Transparent = 30;
    PID_TelnetS_UrgentData = 31;
    PID_TelnetS_WillOption = 32;
    PID_TelnetS_WontOption = 33;

    EID_TelnetS_Command = 1;
    EID_TelnetS_Connected = 2;
    EID_TelnetS_ConnectionStatus = 3;
    EID_TelnetS_DataIn = 4;
    EID_TelnetS_Disconnected = 5;
    EID_TelnetS_Do = 6;
    EID_TelnetS_Dont = 7;
    EID_TelnetS_Error = 8;
    EID_TelnetS_ReadyToSend = 9;
    EID_TelnetS_SSLServerAuthentication = 10;
    EID_TelnetS_SSLStatus = 11;
    EID_TelnetS_SubOption = 12;
    EID_TelnetS_Will = 13;
    EID_TelnetS_Wont = 14;


    MID_TelnetS_Config = 1;
    MID_TelnetS_Connect = 2;
    MID_TelnetS_Disconnect = 3;
    MID_TelnetS_DoEvents = 4;
    MID_TelnetS_Send = 5;




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
{$R 'ipstelnets.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsTelnetS; event_id: Integer; cparam: Integer; 
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
  _TelnetS_Create:        function(pMethod: PEventHandle; pObject: TipsTelnetS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _TelnetS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _TelnetS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _TelnetS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _TelnetS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _TelnetS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _TelnetS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _TelnetS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Create')]
  function _TelnetS_Create       (pMethod: TTelnetSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Destroy')]
  function _TelnetS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Set')]
  function _TelnetS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Set')]
  function _TelnetS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Set')]
  function _TelnetS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Set')]
  function _TelnetS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Set')]
  function _TelnetS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Set')]
  function _TelnetS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Get')]
  function _TelnetS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Get')]
  function _TelnetS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Get')]
  function _TelnetS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Get')]
  function _TelnetS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Get')]
  function _TelnetS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Get')]
  function _TelnetS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_GetLastError')]
  function _TelnetS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_StaticInit')]
  function _TelnetS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_CheckIndex')]
  function _TelnetS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'TelnetS_Do')]
  function _TelnetS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _TelnetS_Create       (pMethod: PEventHandle; pObject: TipsTelnetS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'TelnetS_Create';
  function _TelnetS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'TelnetS_Destroy';
  function _TelnetS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'TelnetS_Set';
  function _TelnetS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'TelnetS_Get';
  function _TelnetS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'TelnetS_GetLastError';
  function _TelnetS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'TelnetS_StaticInit';
  function _TelnetS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'TelnetS_CheckIndex';
  function _TelnetS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'TelnetS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsTelnetS; event_id: Integer;
                    cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): Integer;
                    {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  var
    x: Integer;
{$IFDEF LINUX}
    msg: String;
    tmp_IdleNextWait: Integer;
    tmp_NotifyObject: TipwSocketNotifier;
{$ENDIF}
    tmp_CommandCommandCode: Integer;
    tmp_ConnectedStatusCode: Integer;
    tmp_ConnectedDescription: String;
    tmp_ConnectionStatusConnectionEvent: String;
    tmp_ConnectionStatusStatusCode: Integer;
    tmp_ConnectionStatusDescription: String;
    tmp_DataInText: String;
    tmp_DisconnectedStatusCode: Integer;
    tmp_DisconnectedDescription: String;
    tmp_DoOptionCode: Integer;
    tmp_DontOptionCode: Integer;
    tmp_ErrorErrorCode: Integer;
    tmp_ErrorDescription: String;
    tmp_SSLServerAuthenticationCertEncoded: String;
    tmp_SSLServerAuthenticationCertSubject: String;
    tmp_SSLServerAuthenticationCertIssuer: String;
    tmp_SSLServerAuthenticationStatus: String;
    tmp_SSLStatusMessage: String;
    tmp_SubOptionSubOption: String;
    tmp_WillOptionCode: Integer;
    tmp_WontOptionCode: Integer;

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

      EID_TelnetS_Command:
      begin
        if Assigned(lpContext.FOnCommand) then
        begin
          {assign temporary variables}
          tmp_CommandCommandCode := Integer(params^[0]);

          lpContext.FOnCommand(lpContext, tmp_CommandCommandCode);


        end;
      end;
      EID_TelnetS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_TelnetS_ConnectionStatus:
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
      EID_TelnetS_DataIn:
      begin
        if Assigned(lpContext.FOnDataIn) then
        begin
          {assign temporary variables}
          SetString(tmp_DataInText, PChar(params^[0]), cbparam^[0]);


          lpContext.FOnDataIn(lpContext, tmp_DataInText);


        end;
      end;
      EID_TelnetS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_TelnetS_Do:
      begin
        if Assigned(lpContext.FOnDo) then
        begin
          {assign temporary variables}
          tmp_DoOptionCode := Integer(params^[0]);

          lpContext.FOnDo(lpContext, tmp_DoOptionCode);


        end;
      end;
      EID_TelnetS_Dont:
      begin
        if Assigned(lpContext.FOnDont) then
        begin
          {assign temporary variables}
          tmp_DontOptionCode := Integer(params^[0]);

          lpContext.FOnDont(lpContext, tmp_DontOptionCode);


        end;
      end;
      EID_TelnetS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_TelnetS_ReadyToSend:
      begin
        if Assigned(lpContext.FOnReadyToSend) then
        begin
          {assign temporary variables}

          lpContext.FOnReadyToSend(lpContext);

        end;
      end;
      EID_TelnetS_SSLServerAuthentication:
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
      EID_TelnetS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_TelnetS_SubOption:
      begin
        if Assigned(lpContext.FOnSubOption) then
        begin
          {assign temporary variables}
          SetString(tmp_SubOptionSubOption, PChar(params^[0]), cbparam^[0]);


          lpContext.FOnSubOption(lpContext, tmp_SubOptionSubOption);


        end;
      end;
      EID_TelnetS_Will:
      begin
        if Assigned(lpContext.FOnWill) then
        begin
          {assign temporary variables}
          tmp_WillOptionCode := Integer(params^[0]);

          lpContext.FOnWill(lpContext, tmp_WillOptionCode);


        end;
      end;
      EID_TelnetS_Wont:
      begin
        if Assigned(lpContext.FOnWont) then
        begin
          {assign temporary variables}
          tmp_WontOptionCode := Integer(params^[0]);

          lpContext.FOnWont(lpContext, tmp_WontOptionCode);


        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsTelnetS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_CommandCommandCode: Integer;

  tmp_ConnectedStatusCode: Integer;
  tmp_ConnectedDescription: String;

  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;

  tmp_DataInText: String;

  tmp_DataInTextB: Array of Byte;
  tmp_DisconnectedStatusCode: Integer;
  tmp_DisconnectedDescription: String;

  tmp_DoOptionCode: Integer;

  tmp_DontOptionCode: Integer;

  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;


  tmp_SSLServerAuthenticationCertEncoded: String;
  tmp_SSLServerAuthenticationCertSubject: String;
  tmp_SSLServerAuthenticationCertIssuer: String;
  tmp_SSLServerAuthenticationStatus: String;

  tmp_SSLServerAuthenticationCertEncodedB: Array of Byte;
  tmp_SSLStatusMessage: String;

  tmp_SubOptionSubOption: String;

  tmp_SubOptionSubOptionB: Array of Byte;
  tmp_WillOptionCode: Integer;

  tmp_WontOptionCode: Integer;


begin
 	p := nil;
  case event_id of
    EID_TelnetS_Command:
    begin
      if Assigned(FOnCommand) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_CommandCommandCode := Marshal.ReadInt32(params, 4*0);

        FOnCommand(lpContext, tmp_CommandCommandCode);


      end;


    end;
    EID_TelnetS_Connected:
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
    EID_TelnetS_ConnectionStatus:
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
    EID_TelnetS_DataIn:
    begin
      if Assigned(FOnDataIn) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DataInText := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*0));


        FOnDataIn(lpContext, tmp_DataInText);


      end;

      if Assigned(FOnDataInB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        SetLength(tmp_DataInTextB, Marshal.ReadInt32(cbparam, 4 * 0)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 0), tmp_DataInTextB,
        						 0, Length(tmp_DataInTextB));


        FOnDataInB(lpContext, tmp_DataInTextB);


      end;
    end;
    EID_TelnetS_Disconnected:
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
    EID_TelnetS_Do:
    begin
      if Assigned(FOnDo) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DoOptionCode := Marshal.ReadInt32(params, 4*0);

        FOnDo(lpContext, tmp_DoOptionCode);


      end;


    end;
    EID_TelnetS_Dont:
    begin
      if Assigned(FOnDont) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DontOptionCode := Marshal.ReadInt32(params, 4*0);

        FOnDont(lpContext, tmp_DontOptionCode);


      end;


    end;
    EID_TelnetS_Error:
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
    EID_TelnetS_ReadyToSend:
    begin
      if Assigned(FOnReadyToSend) then
      begin
        {assign temporary variables}

        FOnReadyToSend(lpContext);

      end;


    end;
    EID_TelnetS_SSLServerAuthentication:
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
    EID_TelnetS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_TelnetS_SubOption:
    begin
      if Assigned(FOnSubOption) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SubOptionSubOption := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*0));


        FOnSubOption(lpContext, tmp_SubOptionSubOption);


      end;

      if Assigned(FOnSubOptionB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        SetLength(tmp_SubOptionSubOptionB, Marshal.ReadInt32(cbparam, 4 * 0)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 0), tmp_SubOptionSubOptionB,
        						 0, Length(tmp_SubOptionSubOptionB));


        FOnSubOptionB(lpContext, tmp_SubOptionSubOptionB);


      end;
    end;
    EID_TelnetS_Will:
    begin
      if Assigned(FOnWill) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_WillOptionCode := Marshal.ReadInt32(params, 4*0);

        FOnWill(lpContext, tmp_WillOptionCode);


      end;


    end;
    EID_TelnetS_Wont:
    begin
      if Assigned(FOnWont) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_WontOptionCode := Marshal.ReadInt32(params, 4*0);

        FOnWont(lpContext, tmp_WontOptionCode);


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
    RegisterComponents('IP*Works! SSL', [TipsTelnetS]);
end;

constructor TipsTelnetS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _TelnetS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_TelnetS_Create <> nil then
      m_ctl := _TelnetS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL TelnetS: Error creating component');

{$IFDEF CLR}
    _TelnetS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_19, 0);
{$ELSE}
    _TelnetS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_19)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_TelnetS_Do <> nil then
      _TelnetS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_KeepAlive(false) except on E:Exception do end;
    try set_Linger(true) except on E:Exception do end;
    try set_LocalPort(0) except on E:Exception do end;
    try set_RemoteHost('') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;
    try set_Timeout(0) except on E:Exception do end;
    try set_Transparent(false) except on E:Exception do end;

end;

destructor TipsTelnetS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_TelnetS_Destroy <> nil then{$ENDIF}
      	_TelnetS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsTelnetS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsTelnetS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsTelnetS.AboutDlg;
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
	if @_TelnetS_Do <> nil then
{$ENDIF}
		_TelnetS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsTelnetS.SetOK(key: String128);
begin
end;

function TipsTelnetS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsTelnetS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsTelnetS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsTelnetS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsTelnetS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsTelnetS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_TelnetS_GetLastError <> nil then{$ENDIF}
      msg := _TelnetS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsTelnetS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_TelnetS_Do <> nil then
      _TelnetS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsTelnetS.SetDataToSend(lpDataToSend: PChar; lenDataToSend: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_TelnetS_Set = nil then exit;{$ENDIF}
  err := _TelnetS_Set(m_ctl, PID_TelnetS_DataToSend, 0, Integer(lpDataToSend), lenDataToSend);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsTelnetS.SetDoSubOption(lpDoSubOption: PChar; lenDoSubOption: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_TelnetS_Set = nil then exit;{$ENDIF}
  err := _TelnetS_Set(m_ctl, PID_TelnetS_DoSubOption, 0, Integer(lpDoSubOption), lenDoSubOption);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsTelnetS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_TelnetS_Set = nil then exit;{$ENDIF}
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsTelnetS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_TelnetS_Set = nil then exit;{$ENDIF}
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsTelnetS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_TelnetS_Set = nil then exit;{$ENDIF}
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsTelnetS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_TelnetS_Set = nil then exit;{$ENDIF}
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsTelnetS.SetUrgentData(lpUrgentData: PChar; lenUrgentData: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_TelnetS_Set = nil then exit;{$ENDIF}
  err := _TelnetS_Set(m_ctl, PID_TelnetS_UrgentData, 0, Integer(lpUrgentData), lenUrgentData);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsTelnetS.get_AcceptData: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_TelnetS_GetBOOL(m_ctl, PID_TelnetS_AcceptData, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_AcceptData, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_AcceptData(valAcceptData: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBOOL(m_ctl, PID_TelnetS_AcceptData, 0, valAcceptData, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_AcceptData, 0, Integer(valAcceptData), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_BytesSent: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_TelnetS_GetLONG(m_ctl, PID_TelnetS_BytesSent, 0, err));
{$ELSE}
  result := Integer(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_BytesSent, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;



procedure TipsTelnetS.set_Command(valCommand: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetINT(m_ctl, PID_TelnetS_Command, 0, valCommand, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_Command, 0, Integer(valCommand), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_TelnetS_GetBOOL(m_ctl, PID_TelnetS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBOOL(m_ctl, PID_TelnetS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsTelnetS.set_StringDataToSend(valDataToSend: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBSTR(m_ctl, PID_TelnetS_DataToSend, 0, valDataToSend, Length(valDataToSend));

{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_DataToSend, 0, Integer(PChar(valDataToSend)), Length(valDataToSend));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsTelnetS.set_DontOption(valDontOption: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetINT(m_ctl, PID_TelnetS_DontOption, 0, valDontOption, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_DontOption, 0, Integer(valDontOption), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsTelnetS.set_DoOption(valDoOption: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetINT(m_ctl, PID_TelnetS_DoOption, 0, valDoOption, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_DoOption, 0, Integer(valDoOption), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsTelnetS.set_StringDoSubOption(valDoSubOption: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBSTR(m_ctl, PID_TelnetS_DoSubOption, 0, valDoSubOption, Length(valDoSubOption));

{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_DoSubOption, 0, Integer(PChar(valDoSubOption)), Length(valDoSubOption));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetCSTR(m_ctl, PID_TelnetS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsTelnetS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetCSTR(m_ctl, PID_TelnetS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetCSTR(m_ctl, PID_TelnetS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsTelnetS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetCSTR(m_ctl, PID_TelnetS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_TelnetS_GetLONG(m_ctl, PID_TelnetS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetLONG(m_ctl, PID_TelnetS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_FirewallType: TipstelnetsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipstelnetsFirewallTypes(_TelnetS_GetENUM(m_ctl, PID_TelnetS_FirewallType, 0, err));
{$ELSE}
  result := TipstelnetsFirewallTypes(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_FirewallType, 0, nil);
  result := TipstelnetsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_FirewallType(valFirewallType: TipstelnetsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetENUM(m_ctl, PID_TelnetS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetCSTR(m_ctl, PID_TelnetS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsTelnetS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetCSTR(m_ctl, PID_TelnetS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_KeepAlive: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_TelnetS_GetBOOL(m_ctl, PID_TelnetS_KeepAlive, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_KeepAlive, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_KeepAlive(valKeepAlive: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBOOL(m_ctl, PID_TelnetS_KeepAlive, 0, valKeepAlive, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_KeepAlive, 0, Integer(valKeepAlive), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_Linger: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_TelnetS_GetBOOL(m_ctl, PID_TelnetS_Linger, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_Linger, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_Linger(valLinger: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBOOL(m_ctl, PID_TelnetS_Linger, 0, valLinger, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_Linger, 0, Integer(valLinger), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetCSTR(m_ctl, PID_TelnetS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsTelnetS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetCSTR(m_ctl, PID_TelnetS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_LocalPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_TelnetS_GetLONG(m_ctl, PID_TelnetS_LocalPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_LocalPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_LocalPort(valLocalPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetLONG(m_ctl, PID_TelnetS_LocalPort, 0, valLocalPort, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_LocalPort, 0, Integer(valLocalPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_RemoteHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetCSTR(m_ctl, PID_TelnetS_RemoteHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_RemoteHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsTelnetS.set_RemoteHost(valRemoteHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetCSTR(m_ctl, PID_TelnetS_RemoteHost, 0, valRemoteHost, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_RemoteHost, 0, Integer(PChar(valRemoteHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_RemotePort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_TelnetS_GetLONG(m_ctl, PID_TelnetS_RemotePort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_RemotePort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_RemotePort(valRemotePort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetLONG(m_ctl, PID_TelnetS_RemotePort, 0, valRemotePort, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_RemotePort, 0, Integer(valRemotePort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetBSTR(m_ctl, PID_TelnetS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsTelnetS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBSTR(m_ctl, PID_TelnetS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetBSTR(m_ctl, PID_TelnetS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsTelnetS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBSTR(m_ctl, PID_TelnetS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetBSTR(m_ctl, PID_TelnetS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsTelnetS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBSTR(m_ctl, PID_TelnetS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetCSTR(m_ctl, PID_TelnetS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsTelnetS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetCSTR(m_ctl, PID_TelnetS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_SSLCertStoreType: TipstelnetsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipstelnetsSSLCertStoreTypes(_TelnetS_GetENUM(m_ctl, PID_TelnetS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipstelnetsSSLCertStoreTypes(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLCertStoreType, 0, nil);
  result := TipstelnetsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_SSLCertStoreType(valSSLCertStoreType: TipstelnetsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetENUM(m_ctl, PID_TelnetS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetCSTR(m_ctl, PID_TelnetS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsTelnetS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetCSTR(m_ctl, PID_TelnetS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetBSTR(m_ctl, PID_TelnetS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsTelnetS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _TelnetS_GetCSTR(m_ctl, PID_TelnetS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsTelnetS.get_SSLStartMode: TipstelnetsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipstelnetsSSLStartModes(_TelnetS_GetENUM(m_ctl, PID_TelnetS_SSLStartMode, 0, err));
{$ELSE}
  result := TipstelnetsSSLStartModes(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_SSLStartMode, 0, nil);
  result := TipstelnetsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_SSLStartMode(valSSLStartMode: TipstelnetsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetENUM(m_ctl, PID_TelnetS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_TelnetS_GetINT(m_ctl, PID_TelnetS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetINT(m_ctl, PID_TelnetS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsTelnetS.get_Transparent: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_TelnetS_GetBOOL(m_ctl, PID_TelnetS_Transparent, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_TelnetS_Get = nil then exit;
  tmp := _TelnetS_Get(m_ctl, PID_TelnetS_Transparent, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsTelnetS.set_Transparent(valTransparent: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBOOL(m_ctl, PID_TelnetS_Transparent, 0, valTransparent, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_Transparent, 0, Integer(valTransparent), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsTelnetS.set_StringUrgentData(valUrgentData: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetBSTR(m_ctl, PID_TelnetS_UrgentData, 0, valUrgentData, Length(valUrgentData));

{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_UrgentData, 0, Integer(PChar(valUrgentData)), Length(valUrgentData));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsTelnetS.set_WillOption(valWillOption: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetINT(m_ctl, PID_TelnetS_WillOption, 0, valWillOption, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_WillOption, 0, Integer(valWillOption), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsTelnetS.set_WontOption(valWontOption: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _TelnetS_SetINT(m_ctl, PID_TelnetS_WontOption, 0, valWontOption, 0);
{$ELSE}
	if @_TelnetS_Set = nil then exit;
  err := _TelnetS_Set(m_ctl, PID_TelnetS_WontOption, 0, Integer(valWontOption), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsTelnetS.Config(ConfigurationString: String): String;
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


  err := _TelnetS_Do(m_ctl, MID_TelnetS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_TelnetS_Do = nil then exit;
  err := _TelnetS_Do(m_ctl, MID_TelnetS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsTelnetS.Connect(Host: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(Host);
  paramcb[i] := 0;

  i := i + 1;


  err := _TelnetS_Do(m_ctl, MID_TelnetS_Connect, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(Host);
  paramcb[i] := 0;

  i := i + 1;


	if @_TelnetS_Do = nil then exit;
  err := _TelnetS_Do(m_ctl, MID_TelnetS_Connect, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsTelnetS.Disconnect();

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



  err := _TelnetS_Do(m_ctl, MID_TelnetS_Disconnect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_TelnetS_Do = nil then exit;
  err := _TelnetS_Do(m_ctl, MID_TelnetS_Disconnect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsTelnetS.DoEvents();

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



  err := _TelnetS_Do(m_ctl, MID_TelnetS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_TelnetS_Do = nil then exit;
  err := _TelnetS_Do(m_ctl, MID_TelnetS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsTelnetS.Send(Text: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(Text);
  paramcb[i] := Length(Text);

  i := i + 1;


  err := _TelnetS_Do(m_ctl, MID_TelnetS_Send, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);


  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(Text);
  paramcb[i] := Length(Text);

  i := i + 1;


	if @_TelnetS_Do = nil then exit;
  err := _TelnetS_Do(m_ctl, MID_TelnetS_Send, 1, @param, @paramcb); 
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

	_TelnetS_Create := nil;
	_TelnetS_Destroy := nil;
	_TelnetS_Set := nil;
	_TelnetS_Get := nil;
	_TelnetS_GetLastError := nil;
	_TelnetS_StaticInit := nil;
	_TelnetS_CheckIndex := nil;
	_TelnetS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_telnets_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_TelnetS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'TelnetS_Create');
		@_TelnetS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'TelnetS_Destroy');
		@_TelnetS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'TelnetS_Set');
		@_TelnetS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'TelnetS_Get');
		@_TelnetS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'TelnetS_GetLastError');
		@_TelnetS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'TelnetS_CheckIndex');
		@_TelnetS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'TelnetS_Do');
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
  @_TelnetS_Create       := nil;
  @_TelnetS_Destroy      := nil;
  @_TelnetS_Set          := nil;
  @_TelnetS_Get          := nil;
  @_TelnetS_GetLastError := nil;
  @_TelnetS_CheckIndex   := nil;
  @_TelnetS_Do           := nil;
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




