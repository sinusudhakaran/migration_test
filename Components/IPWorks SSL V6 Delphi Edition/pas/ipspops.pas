
unit ipspops;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipspopsAuthMechanisms = 
(

									 
                   amUserPassword,

									 
                   amCRAMMD5,

									 
                   amAPOP
);
  TipspopsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipspopsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipspopsSSLStartModes = 
(

									 
                   sslAutomatic,

									 
                   sslImplicit,

									 
                   sslExplicit,

									 
                   sslNone
);


  TConnectionStatusEvent = procedure(Sender: TObject;
                            const ConnectionEvent: String;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TEndTransferEvent = procedure(Sender: TObject) of Object;

  TErrorEvent = procedure(Sender: TObject;
                            ErrorCode: Integer;
                            const Description: String) of Object;

  THeaderEvent = procedure(Sender: TObject;
                            const Field: String;
                            const Value: String) of Object;

  TMessageListEvent = procedure(Sender: TObject;
                            MessageNumber: Integer;
                            const MessageUID: String;
                            MessageSize: Integer) of Object;

  TPITrailEvent = procedure(Sender: TObject;
                            Direction: Integer;
                            const Message: String) of Object;

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

  TTransferEvent = procedure(Sender: TObject;
                            BytesTransferred: LongInt;
                            Text: String;
                            EOL: Boolean) of Object;
{$IFDEF CLR}
  TTransferEventB = procedure(Sender: TObject;
                            BytesTransferred: LongInt;
                            Text: Array of Byte;
                            EOL: Boolean) of Object;

{$ENDIF}

{$IFDEF CLR}
  TPOPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsPOPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsPOPS = class(TipsCore)
    public
      FOnConnectionStatus: TConnectionStatusEvent;

      FOnEndTransfer: TEndTransferEvent;

      FOnError: TErrorEvent;

      FOnHeader: THeaderEvent;

      FOnMessageList: TMessageListEvent;

      FOnPITrail: TPITrailEvent;

      FOnSSLServerAuthentication: TSSLServerAuthenticationEvent;
			{$IFDEF CLR}FOnSSLServerAuthenticationB: TSSLServerAuthenticationEventB;{$ENDIF}
      FOnSSLStatus: TSSLStatusEvent;

      FOnStartTransfer: TStartTransferEvent;

      FOnTransfer: TTransferEvent;
			{$IFDEF CLR}FOnTransferB: TTransferEventB;{$ENDIF}

    private
      tmp_SSLServerAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TPOPSEventHook;
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


      procedure set_Command(valCommand: String);

      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);

      function get_MailPort: Integer;
      procedure set_MailPort(valMailPort: Integer);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);


      procedure TreatErr(Err: integer; const desc: string);


      function get_AuthMechanism: TipspopsAuthMechanisms;
      procedure set_AuthMechanism(valAuthMechanism: TipspopsAuthMechanisms);





      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipspopsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipspopsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_Idle: Boolean;


      function get_LastReply: String;


      function get_LocalFile: String;
      procedure set_LocalFile(valLocalFile: String);

      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);



      function get_MailServer: String;
      procedure set_MailServer(valMailServer: String);

      function get_MaxLines: Integer;
      procedure set_MaxLines(valMaxLines: Integer);

      function get_MessageCc: String;


      function get_MessageCount: Integer;


      function get_MessageDate: String;


      function get_MessageFrom: String;


      function get_MessageHeaders: String;


      function get_MessageNumber: Integer;
      procedure set_MessageNumber(valMessageNumber: Integer);

      function get_MessageReplyTo: String;


      function get_MessageSize: Integer;


      function get_MessageSubject: String;


      function get_MessageText: String;


      function get_MessageTo: String;


      function get_MessageUID: String;


      function get_Password: String;
      procedure set_Password(valPassword: String);

      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipspopsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipspopsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipspopsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipspopsSSLStartModes);

      function get_Timeout: Integer;
      procedure set_Timeout(valTimeout: Integer);

      function get_TotalSize: Integer;


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



      property Command: String

               write set_Command               ;

      property Connected: Boolean
               read get_Connected
               write set_Connected               ;



















      property MailPort: Integer
               read get_MailPort
               write set_MailPort               ;

































      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;























{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure Connect();

      procedure Delete();

      procedure Disconnect();

      procedure DoEvents();

      procedure Interrupt();

      procedure ListMessageSizes();

      procedure ListMessageUIDs();

      function LocalizeDate(DateTime: String): String;
      procedure Reset();

      procedure Retrieve();

      procedure RetrieveHeaders();


{$ENDIF}

    published

      property AuthMechanism: TipspopsAuthMechanisms
                   read get_AuthMechanism
                   write set_AuthMechanism
                   default amUserPassword
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
      property FirewallType: TipspopsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property Idle: Boolean
                   read get_Idle
                    write SetNoopBoolean
                   stored False

                   ;
      property LastReply: String
                   read get_LastReply
                    write SetNoopString
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

      property MailServer: String
                   read get_MailServer
                   write set_MailServer
                   
                   ;
      property MaxLines: Integer
                   read get_MaxLines
                   write set_MaxLines
                   default 0
                   ;
      property MessageCc: String
                   read get_MessageCc
                    write SetNoopString
                   stored False

                   ;
      property MessageCount: Integer
                   read get_MessageCount
                    write SetNoopInteger
                   stored False

                   ;
      property MessageDate: String
                   read get_MessageDate
                    write SetNoopString
                   stored False

                   ;
      property MessageFrom: String
                   read get_MessageFrom
                    write SetNoopString
                   stored False

                   ;
      property MessageHeaders: String
                   read get_MessageHeaders
                    write SetNoopString
                   stored False

                   ;
      property MessageNumber: Integer
                   read get_MessageNumber
                   write set_MessageNumber
                   default 0
                   ;
      property MessageReplyTo: String
                   read get_MessageReplyTo
                    write SetNoopString
                   stored False

                   ;
      property MessageSize: Integer
                   read get_MessageSize
                    write SetNoopInteger
                   stored False

                   ;
      property MessageSubject: String
                   read get_MessageSubject
                    write SetNoopString
                   stored False

                   ;
      property MessageText: String
                   read get_MessageText
                    write SetNoopString
                   stored False

                   ;
      property MessageTo: String
                   read get_MessageTo
                    write SetNoopString
                   stored False

                   ;
      property MessageUID: String
                   read get_MessageUID
                    write SetNoopString
                   stored False

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
      property SSLCertStoreType: TipspopsSSLCertStoreTypes
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
      property SSLStartMode: TipspopsSSLStartModes
                   read get_SSLStartMode
                   write set_SSLStartMode
                   default sslAutomatic
                   ;
      property Timeout: Integer
                   read get_Timeout
                   write set_Timeout
                   default 60
                   ;
      property TotalSize: Integer
                   read get_TotalSize
                    write SetNoopInteger
                   stored False

                   ;
      property User: String
                   read get_User
                   write set_User
                   
                   ;


      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnEndTransfer: TEndTransferEvent read FOnEndTransfer write FOnEndTransfer;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnHeader: THeaderEvent read FOnHeader write FOnHeader;

      property OnMessageList: TMessageListEvent read FOnMessageList write FOnMessageList;

      property OnPITrail: TPITrailEvent read FOnPITrail write FOnPITrail;

      property OnSSLServerAuthentication: TSSLServerAuthenticationEvent read FOnSSLServerAuthentication write FOnSSLServerAuthentication;
			{$IFDEF CLR}property OnSSLServerAuthenticationB: TSSLServerAuthenticationEventB read FOnSSLServerAuthenticationB write FOnSSLServerAuthenticationB;{$ENDIF}
      property OnSSLStatus: TSSLStatusEvent read FOnSSLStatus write FOnSSLStatus;

      property OnStartTransfer: TStartTransferEvent read FOnStartTransfer write FOnStartTransfer;

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
    PID_POPS_AuthMechanism = 1;
    PID_POPS_Command = 2;
    PID_POPS_Connected = 3;
    PID_POPS_FirewallHost = 4;
    PID_POPS_FirewallPassword = 5;
    PID_POPS_FirewallPort = 6;
    PID_POPS_FirewallType = 7;
    PID_POPS_FirewallUser = 8;
    PID_POPS_Idle = 9;
    PID_POPS_LastReply = 10;
    PID_POPS_LocalFile = 11;
    PID_POPS_LocalHost = 12;
    PID_POPS_MailPort = 13;
    PID_POPS_MailServer = 14;
    PID_POPS_MaxLines = 15;
    PID_POPS_MessageCc = 16;
    PID_POPS_MessageCount = 17;
    PID_POPS_MessageDate = 18;
    PID_POPS_MessageFrom = 19;
    PID_POPS_MessageHeaders = 20;
    PID_POPS_MessageNumber = 21;
    PID_POPS_MessageReplyTo = 22;
    PID_POPS_MessageSize = 23;
    PID_POPS_MessageSubject = 24;
    PID_POPS_MessageText = 25;
    PID_POPS_MessageTo = 26;
    PID_POPS_MessageUID = 27;
    PID_POPS_Password = 28;
    PID_POPS_SSLAcceptServerCert = 29;
    PID_POPS_SSLCertEncoded = 30;
    PID_POPS_SSLCertStore = 31;
    PID_POPS_SSLCertStorePassword = 32;
    PID_POPS_SSLCertStoreType = 33;
    PID_POPS_SSLCertSubject = 34;
    PID_POPS_SSLServerCert = 35;
    PID_POPS_SSLServerCertStatus = 36;
    PID_POPS_SSLStartMode = 37;
    PID_POPS_Timeout = 38;
    PID_POPS_TotalSize = 39;
    PID_POPS_User = 40;

    EID_POPS_ConnectionStatus = 1;
    EID_POPS_EndTransfer = 2;
    EID_POPS_Error = 3;
    EID_POPS_Header = 4;
    EID_POPS_MessageList = 5;
    EID_POPS_PITrail = 6;
    EID_POPS_SSLServerAuthentication = 7;
    EID_POPS_SSLStatus = 8;
    EID_POPS_StartTransfer = 9;
    EID_POPS_Transfer = 10;


    MID_POPS_Config = 1;
    MID_POPS_Connect = 2;
    MID_POPS_Delete = 3;
    MID_POPS_Disconnect = 4;
    MID_POPS_DoEvents = 5;
    MID_POPS_Interrupt = 6;
    MID_POPS_ListMessageSizes = 7;
    MID_POPS_ListMessageUIDs = 8;
    MID_POPS_LocalizeDate = 9;
    MID_POPS_Reset = 10;
    MID_POPS_Retrieve = 11;
    MID_POPS_RetrieveHeaders = 12;




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
{$R 'ipspops.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsPOPS; event_id: Integer; cparam: Integer; 
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
  _POPS_Create:        function(pMethod: PEventHandle; pObject: TipsPOPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _POPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _POPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _POPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _POPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _POPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _POPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _POPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Create')]
  function _POPS_Create       (pMethod: TPOPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Destroy')]
  function _POPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Set')]
  function _POPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Set')]
  function _POPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Set')]
  function _POPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Set')]
  function _POPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Set')]
  function _POPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Set')]
  function _POPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Get')]
  function _POPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Get')]
  function _POPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Get')]
  function _POPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Get')]
  function _POPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Get')]
  function _POPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Get')]
  function _POPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_GetLastError')]
  function _POPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_StaticInit')]
  function _POPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_CheckIndex')]
  function _POPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'POPS_Do')]
  function _POPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _POPS_Create       (pMethod: PEventHandle; pObject: TipsPOPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'POPS_Create';
  function _POPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'POPS_Destroy';
  function _POPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'POPS_Set';
  function _POPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'POPS_Get';
  function _POPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'POPS_GetLastError';
  function _POPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'POPS_StaticInit';
  function _POPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'POPS_CheckIndex';
  function _POPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'POPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsPOPS; event_id: Integer;
                    cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): Integer;
                    {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  var
    x: Integer;
{$IFDEF LINUX}
    msg: String;
    tmp_IdleNextWait: Integer;
    tmp_NotifyObject: TipwSocketNotifier;
{$ENDIF}
    tmp_ConnectionStatusConnectionEvent: String;
    tmp_ConnectionStatusStatusCode: Integer;
    tmp_ConnectionStatusDescription: String;
    tmp_ErrorErrorCode: Integer;
    tmp_ErrorDescription: String;
    tmp_HeaderField: String;
    tmp_HeaderValue: String;
    tmp_MessageListMessageNumber: Integer;
    tmp_MessageListMessageUID: String;
    tmp_MessageListMessageSize: Integer;
    tmp_PITrailDirection: Integer;
    tmp_PITrailMessage: String;
    tmp_SSLServerAuthenticationCertEncoded: String;
    tmp_SSLServerAuthenticationCertSubject: String;
    tmp_SSLServerAuthenticationCertIssuer: String;
    tmp_SSLServerAuthenticationStatus: String;
    tmp_SSLStatusMessage: String;
    tmp_TransferBytesTransferred: LongInt;
    tmp_TransferText: String;
    tmp_TransferEOL: Boolean;

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

      EID_POPS_ConnectionStatus:
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
      EID_POPS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_POPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_POPS_Header:
      begin
        if Assigned(lpContext.FOnHeader) then
        begin
          {assign temporary variables}
          tmp_HeaderField := AnsiString(PChar(params^[0]));

          tmp_HeaderValue := AnsiString(PChar(params^[1]));


          lpContext.FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



        end;
      end;
      EID_POPS_MessageList:
      begin
        if Assigned(lpContext.FOnMessageList) then
        begin
          {assign temporary variables}
          tmp_MessageListMessageNumber := Integer(params^[0]);
          tmp_MessageListMessageUID := AnsiString(PChar(params^[1]));

          tmp_MessageListMessageSize := Integer(params^[2]);

          lpContext.FOnMessageList(lpContext, tmp_MessageListMessageNumber, tmp_MessageListMessageUID, tmp_MessageListMessageSize);




        end;
      end;
      EID_POPS_PITrail:
      begin
        if Assigned(lpContext.FOnPITrail) then
        begin
          {assign temporary variables}
          tmp_PITrailDirection := Integer(params^[0]);
          tmp_PITrailMessage := AnsiString(PChar(params^[1]));


          lpContext.FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailMessage);



        end;
      end;
      EID_POPS_SSLServerAuthentication:
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
      EID_POPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_POPS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_POPS_Transfer:
      begin
        if Assigned(lpContext.FOnTransfer) then
        begin
          {assign temporary variables}
          tmp_TransferBytesTransferred := LongInt(params^[0]);
          SetString(tmp_TransferText, PChar(params^[1]), cbparam^[1]);

          tmp_TransferEOL := Boolean(params^[2]);

          lpContext.FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText, tmp_TransferEOL);




        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsPOPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;


  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_HeaderField: String;
  tmp_HeaderValue: String;

  tmp_MessageListMessageNumber: Integer;
  tmp_MessageListMessageUID: String;
  tmp_MessageListMessageSize: Integer;

  tmp_PITrailDirection: Integer;
  tmp_PITrailMessage: String;

  tmp_SSLServerAuthenticationCertEncoded: String;
  tmp_SSLServerAuthenticationCertSubject: String;
  tmp_SSLServerAuthenticationCertIssuer: String;
  tmp_SSLServerAuthenticationStatus: String;

  tmp_SSLServerAuthenticationCertEncodedB: Array of Byte;
  tmp_SSLStatusMessage: String;


  tmp_TransferBytesTransferred: LongInt;
  tmp_TransferText: String;
  tmp_TransferEOL: Boolean;

  tmp_TransferTextB: Array of Byte;

begin
 	p := nil;
  case event_id of
    EID_POPS_ConnectionStatus:
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
    EID_POPS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_POPS_Error:
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
    EID_POPS_Header:
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
    EID_POPS_MessageList:
    begin
      if Assigned(FOnMessageList) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_MessageListMessageNumber := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_MessageListMessageUID := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_MessageListMessageSize := Marshal.ReadInt32(params, 4*2);

        FOnMessageList(lpContext, tmp_MessageListMessageNumber, tmp_MessageListMessageUID, tmp_MessageListMessageSize);




      end;


    end;
    EID_POPS_PITrail:
    begin
      if Assigned(FOnPITrail) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_PITrailDirection := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_PITrailMessage := Marshal.PtrToStringAnsi(p);


        FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailMessage);



      end;


    end;
    EID_POPS_SSLServerAuthentication:
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
    EID_POPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_POPS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_POPS_Transfer:
    begin
      if Assigned(FOnTransfer) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_TransferBytesTransferred := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_TransferText := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*1));

				p := Marshal.ReadIntPtr(params, 4 * 2);
        if Marshal.ReadInt32(params, 4*2) <> 0 then tmp_TransferEOL := true else tmp_TransferEOL := false;


        FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText, tmp_TransferEOL);




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

				p := Marshal.ReadIntPtr(params, 4 * 2);
        if Marshal.ReadInt32(params, 4*2) <> 0 then tmp_TransferEOL := true else tmp_TransferEOL := false;


        FOnTransferB(lpContext, tmp_TransferBytesTransferred, tmp_TransferTextB, tmp_TransferEOL);




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
    RegisterComponents('IP*Works! SSL', [TipsPOPS]);
end;

constructor TipsPOPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _POPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_POPS_Create <> nil then
      m_ctl := _POPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL POPS: Error creating component');

{$IFDEF CLR}
    _POPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_24, 0);
{$ELSE}
    _POPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_24)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_POPS_Do <> nil then
      _POPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_AuthMechanism(amUserPassword) except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_LocalFile('') except on E:Exception do end;
    try set_MailServer('') except on E:Exception do end;
    try set_MaxLines(0) except on E:Exception do end;
    try set_MessageNumber(0) except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsPOPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_POPS_Destroy <> nil then{$ENDIF}
      	_POPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsPOPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsPOPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsPOPS.AboutDlg;
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
	if @_POPS_Do <> nil then
{$ENDIF}
		_POPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsPOPS.SetOK(key: String128);
begin
end;

function TipsPOPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsPOPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsPOPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsPOPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsPOPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsPOPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_POPS_GetLastError <> nil then{$ENDIF}
      msg := _POPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsPOPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_POPS_Do <> nil then
      _POPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsPOPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_POPS_Set = nil then exit;{$ENDIF}
  err := _POPS_Set(m_ctl, PID_POPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsPOPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_POPS_Set = nil then exit;{$ENDIF}
  err := _POPS_Set(m_ctl, PID_POPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsPOPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_POPS_Set = nil then exit;{$ENDIF}
  err := _POPS_Set(m_ctl, PID_POPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsPOPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_POPS_Set = nil then exit;{$ENDIF}
  err := _POPS_Set(m_ctl, PID_POPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsPOPS.get_AuthMechanism: TipspopsAuthMechanisms;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipspopsAuthMechanisms(_POPS_GetENUM(m_ctl, PID_POPS_AuthMechanism, 0, err));
{$ELSE}
  result := TipspopsAuthMechanisms(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_AuthMechanism, 0, nil);
  result := TipspopsAuthMechanisms(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_AuthMechanism(valAuthMechanism: TipspopsAuthMechanisms);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetENUM(m_ctl, PID_POPS_AuthMechanism, 0, Integer(valAuthMechanism), 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_AuthMechanism, 0, Integer(valAuthMechanism), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsPOPS.set_Command(valCommand: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_Command, 0, valCommand, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_Command, 0, Integer(PChar(valCommand)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_POPS_GetBOOL(m_ctl, PID_POPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetBOOL(m_ctl, PID_POPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_POPS_GetLONG(m_ctl, PID_POPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetLONG(m_ctl, PID_POPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_FirewallType: TipspopsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipspopsFirewallTypes(_POPS_GetENUM(m_ctl, PID_POPS_FirewallType, 0, err));
{$ELSE}
  result := TipspopsFirewallTypes(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_FirewallType, 0, nil);
  result := TipspopsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_FirewallType(valFirewallType: TipspopsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetENUM(m_ctl, PID_POPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_POPS_GetBOOL(m_ctl, PID_POPS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsPOPS.get_LastReply: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_LastReply, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_LastReply, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_LocalFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_LocalFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_LocalFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_LocalFile(valLocalFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_LocalFile, 0, valLocalFile, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_LocalFile, 0, Integer(PChar(valLocalFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_MailPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_POPS_GetLONG(m_ctl, PID_POPS_MailPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MailPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_MailPort(valMailPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetLONG(m_ctl, PID_POPS_MailPort, 0, valMailPort, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_MailPort, 0, Integer(valMailPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_MailServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MailServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MailServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_MailServer(valMailServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_MailServer, 0, valMailServer, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_MailServer, 0, Integer(PChar(valMailServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_MaxLines: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_POPS_GetLONG(m_ctl, PID_POPS_MaxLines, 0, err));
{$ELSE}
  result := Integer(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MaxLines, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_MaxLines(valMaxLines: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetLONG(m_ctl, PID_POPS_MaxLines, 0, valMaxLines, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_MaxLines, 0, Integer(valMaxLines), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_MessageCc: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageCc, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageCc, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_MessageCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_POPS_GetLONG(m_ctl, PID_POPS_MessageCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsPOPS.get_MessageDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_MessageFrom: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageFrom, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageFrom, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_MessageHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_MessageNumber: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_POPS_GetLONG(m_ctl, PID_POPS_MessageNumber, 0, err));
{$ELSE}
  result := Integer(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageNumber, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_MessageNumber(valMessageNumber: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetLONG(m_ctl, PID_POPS_MessageNumber, 0, valMessageNumber, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_MessageNumber, 0, Integer(valMessageNumber), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_MessageReplyTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageReplyTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageReplyTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_MessageSize: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_POPS_GetLONG(m_ctl, PID_POPS_MessageSize, 0, err));
{$ELSE}
  result := Integer(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageSize, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsPOPS.get_MessageSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_MessageText: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageText, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageText, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_MessageTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_MessageUID: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_MessageUID, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_MessageUID, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetBSTR(m_ctl, PID_POPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsPOPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetBSTR(m_ctl, PID_POPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetBSTR(m_ctl, PID_POPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsPOPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetBSTR(m_ctl, PID_POPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetBSTR(m_ctl, PID_POPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsPOPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetBSTR(m_ctl, PID_POPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_SSLCertStoreType: TipspopsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipspopsSSLCertStoreTypes(_POPS_GetENUM(m_ctl, PID_POPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipspopsSSLCertStoreTypes(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLCertStoreType, 0, nil);
  result := TipspopsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_SSLCertStoreType(valSSLCertStoreType: TipspopsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetENUM(m_ctl, PID_POPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetBSTR(m_ctl, PID_POPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsPOPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsPOPS.get_SSLStartMode: TipspopsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipspopsSSLStartModes(_POPS_GetENUM(m_ctl, PID_POPS_SSLStartMode, 0, err));
{$ELSE}
  result := TipspopsSSLStartModes(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_SSLStartMode, 0, nil);
  result := TipspopsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_SSLStartMode(valSSLStartMode: TipspopsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetENUM(m_ctl, PID_POPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_POPS_GetINT(m_ctl, PID_POPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsPOPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetINT(m_ctl, PID_POPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsPOPS.get_TotalSize: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_POPS_GetLONG(m_ctl, PID_POPS_TotalSize, 0, err));
{$ELSE}
  result := Integer(0);

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_TotalSize, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsPOPS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _POPS_GetCSTR(m_ctl, PID_POPS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_POPS_Get = nil then exit;
  tmp := _POPS_Get(m_ctl, PID_POPS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsPOPS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _POPS_SetCSTR(m_ctl, PID_POPS_User, 0, valUser, 0);
{$ELSE}
	if @_POPS_Set = nil then exit;
  err := _POPS_Set(m_ctl, PID_POPS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsPOPS.Config(ConfigurationString: String): String;
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


  err := _POPS_Do(m_ctl, MID_POPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsPOPS.Connect();

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



  err := _POPS_Do(m_ctl, MID_POPS_Connect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_Connect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsPOPS.Delete();

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



  err := _POPS_Do(m_ctl, MID_POPS_Delete, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_Delete, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsPOPS.Disconnect();

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



  err := _POPS_Do(m_ctl, MID_POPS_Disconnect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_Disconnect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsPOPS.DoEvents();

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



  err := _POPS_Do(m_ctl, MID_POPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsPOPS.Interrupt();

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



  err := _POPS_Do(m_ctl, MID_POPS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsPOPS.ListMessageSizes();

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



  err := _POPS_Do(m_ctl, MID_POPS_ListMessageSizes, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_ListMessageSizes, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsPOPS.ListMessageUIDs();

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



  err := _POPS_Do(m_ctl, MID_POPS_ListMessageUIDs, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_ListMessageUIDs, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsPOPS.LocalizeDate(DateTime: String): String;
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

  param[i] := Marshal.StringToHGlobalAnsi(DateTime);
  paramcb[i] := 0;

  i := i + 1;


  err := _POPS_Do(m_ctl, MID_POPS_LocalizeDate, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(DateTime);
  paramcb[i] := 0;

  i := i + 1;


	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_LocalizeDate, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsPOPS.Reset();

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



  err := _POPS_Do(m_ctl, MID_POPS_Reset, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_Reset, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsPOPS.Retrieve();

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



  err := _POPS_Do(m_ctl, MID_POPS_Retrieve, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_Retrieve, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsPOPS.RetrieveHeaders();

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



  err := _POPS_Do(m_ctl, MID_POPS_RetrieveHeaders, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_POPS_Do = nil then exit;
  err := _POPS_Do(m_ctl, MID_POPS_RetrieveHeaders, 0, @param, @paramcb); 
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

	_POPS_Create := nil;
	_POPS_Destroy := nil;
	_POPS_Set := nil;
	_POPS_Get := nil;
	_POPS_GetLastError := nil;
	_POPS_StaticInit := nil;
	_POPS_CheckIndex := nil;
	_POPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_pops_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_POPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'POPS_Create');
		@_POPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'POPS_Destroy');
		@_POPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'POPS_Set');
		@_POPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'POPS_Get');
		@_POPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'POPS_GetLastError');
		@_POPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'POPS_CheckIndex');
		@_POPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'POPS_Do');
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
  @_POPS_Create       := nil;
  @_POPS_Destroy      := nil;
  @_POPS_Set          := nil;
  @_POPS_Get          := nil;
  @_POPS_GetLastError := nil;
  @_POPS_CheckIndex   := nil;
  @_POPS_Do           := nil;
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




