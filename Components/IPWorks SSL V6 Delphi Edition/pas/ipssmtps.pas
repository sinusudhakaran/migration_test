
unit ipssmtps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipssmtpsAuthMechanisms = 
(

									 
                   amUserPassword,

									 
                   amCRAMMD5
);
  TipssmtpsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipssmtpsImportances = 
(

									 
                   miUnspecified,

									 
                   miHigh,

									 
                   miNormal,

									 
                   miLow
);
  TipssmtpsPriorities = 
(

									 
                   epUnspecified,

									 
                   epNormal,

									 
                   epUrgent,

									 
                   epNonUrgent
);
  TipssmtpsSensitivities = 
(

									 
                   esUnspecified,

									 
                   esPersonal,

									 
                   esPrivate,

									 
                   esCompanyConfidential
);
  TipssmtpsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipssmtpsSSLStartModes = 
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

  TExpandEvent = procedure(Sender: TObject;
                            const Address: String) of Object;

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
                            BytesTransferred: LongInt) of Object;


{$IFDEF CLR}
  TSMTPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsSMTPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsSMTPS = class(TipsCore)
    public
      FOnConnectionStatus: TConnectionStatusEvent;

      FOnEndTransfer: TEndTransferEvent;

      FOnError: TErrorEvent;

      FOnExpand: TExpandEvent;

      FOnPITrail: TPITrailEvent;

      FOnSSLServerAuthentication: TSSLServerAuthenticationEvent;
			{$IFDEF CLR}FOnSSLServerAuthenticationB: TSSLServerAuthenticationEventB;{$ENDIF}
      FOnSSLStatus: TSSLStatusEvent;

      FOnStartTransfer: TStartTransferEvent;

      FOnTransfer: TTransferEvent;


    private
      tmp_SSLServerAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TSMTPSEventHook;
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

      function get_AllowExtensions: Boolean;
      procedure set_AllowExtensions(valAllowExtensions: Boolean);

      function get_AttachedFile: String;
      procedure set_AttachedFile(valAttachedFile: String);


      procedure set_Command(valCommand: String);

      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);

      function get_MailPort: Integer;
      procedure set_MailPort(valMailPort: Integer);

      function get_MessageDate: String;
      procedure set_MessageDate(valMessageDate: String);

      function get_MessageHeaders: String;


      function get_MessageId: String;
      procedure set_MessageId(valMessageId: String);

      function get_OtherHeaders: String;
      procedure set_OtherHeaders(valOtherHeaders: String);

      function get_Password: String;
      procedure set_Password(valPassword: String);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);

      function get_User: String;
      procedure set_User(valUser: String);


      procedure TreatErr(Err: integer; const desc: string);






      function get_AuthMechanism: TipssmtpsAuthMechanisms;
      procedure set_AuthMechanism(valAuthMechanism: TipssmtpsAuthMechanisms);

      function get_BCc: String;
      procedure set_BCc(valBCc: String);

      function get_Cc: String;
      procedure set_Cc(valCc: String);





      function get_DeliveryNotificationTo: String;
      procedure set_DeliveryNotificationTo(valDeliveryNotificationTo: String);

      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipssmtpsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipssmtpsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_From: String;
      procedure set_From(valFrom: String);

      function get_Idle: Boolean;


      function get_Importance: TipssmtpsImportances;
      procedure set_Importance(valImportance: TipssmtpsImportances);

      function get_LastReply: String;


      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);



      function get_MailServer: String;
      procedure set_MailServer(valMailServer: String);







      function get_MessageText: String;
      procedure set_MessageText(valMessageText: String);





      function get_Priority: TipssmtpsPriorities;
      procedure set_Priority(valPriority: TipssmtpsPriorities);

      function get_ReadReceiptTo: String;
      procedure set_ReadReceiptTo(valReadReceiptTo: String);

      function get_ReplyTo: String;
      procedure set_ReplyTo(valReplyTo: String);

      function get_SendTo: String;
      procedure set_SendTo(valSendTo: String);

      function get_Sensitivity: TipssmtpsSensitivities;
      procedure set_Sensitivity(valSensitivity: TipssmtpsSensitivities);

      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipssmtpsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipssmtpsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipssmtpsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipssmtpsSSLStartModes);

      function get_Subject: String;
      procedure set_Subject(valSubject: String);

      function get_Timeout: Integer;
      procedure set_Timeout(valTimeout: Integer);





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

      property AllowExtensions: Boolean
               read get_AllowExtensions
               write set_AllowExtensions               ;

      property AttachedFile: String
               read get_AttachedFile
               write set_AttachedFile               ;







      property Command: String

               write set_Command               ;

      property Connected: Boolean
               read get_Connected
               write set_Connected               ;























      property MailPort: Integer
               read get_MailPort
               write set_MailPort               ;



      property MessageDate: String
               read get_MessageDate
               write set_MessageDate               ;

      property MessageHeaders: String
               read get_MessageHeaders
               ;

      property MessageId: String
               read get_MessageId
               write set_MessageId               ;



      property OtherHeaders: String
               read get_OtherHeaders
               write set_OtherHeaders               ;

      property Password: String
               read get_Password
               write set_Password               ;













      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;



















      property User: String
               read get_User
               write set_User               ;



{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure Connect();

      procedure Disconnect();

      procedure DoEvents();

      procedure Expand(EmailAddress: String);

      procedure Interrupt();

      procedure ProcessQueue(QueueDir: String);

      function Queue(QueueDir: String): String;
      procedure ResetHeaders();

      procedure Send();

      procedure SendToTerminalAndEmail();

      procedure SendToTerminalOnly();

      procedure SendToTerminalOrEmail();

      procedure Verify(EmailAddress: String);


{$ENDIF}

    published



      property AuthMechanism: TipssmtpsAuthMechanisms
                   read get_AuthMechanism
                   write set_AuthMechanism
                   default amUserPassword
                   ;
      property BCc: String
                   read get_BCc
                   write set_BCc
                   
                   ;
      property Cc: String
                   read get_Cc
                   write set_Cc
                   
                   ;


      property DeliveryNotificationTo: String
                   read get_DeliveryNotificationTo
                   write set_DeliveryNotificationTo
                   
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
      property FirewallType: TipssmtpsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property From: String
                   read get_From
                   write set_From
                   
                   ;
      property Idle: Boolean
                   read get_Idle
                    write SetNoopBoolean
                   stored False

                   ;
      property Importance: TipssmtpsImportances
                   read get_Importance
                   write set_Importance
                   default miUnspecified
                   ;
      property LastReply: String
                   read get_LastReply
                    write SetNoopString
                   stored False

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



      property MessageText: String
                   read get_MessageText
                   write set_MessageText
                   
                   ;


      property Priority: TipssmtpsPriorities
                   read get_Priority
                   write set_Priority
                   default epUnspecified
                   ;
      property ReadReceiptTo: String
                   read get_ReadReceiptTo
                   write set_ReadReceiptTo
                   
                   ;
      property ReplyTo: String
                   read get_ReplyTo
                   write set_ReplyTo
                   
                   ;
      property SendTo: String
                   read get_SendTo
                   write set_SendTo
                   
                   ;
      property Sensitivity: TipssmtpsSensitivities
                   read get_Sensitivity
                   write set_Sensitivity
                   default esUnspecified
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
      property SSLCertStoreType: TipssmtpsSSLCertStoreTypes
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
      property SSLStartMode: TipssmtpsSSLStartModes
                   read get_SSLStartMode
                   write set_SSLStartMode
                   default sslAutomatic
                   ;
      property Subject: String
                   read get_Subject
                   write set_Subject
                   
                   ;
      property Timeout: Integer
                   read get_Timeout
                   write set_Timeout
                   default 60
                   ;



      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnEndTransfer: TEndTransferEvent read FOnEndTransfer write FOnEndTransfer;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnExpand: TExpandEvent read FOnExpand write FOnExpand;

      property OnPITrail: TPITrailEvent read FOnPITrail write FOnPITrail;

      property OnSSLServerAuthentication: TSSLServerAuthenticationEvent read FOnSSLServerAuthentication write FOnSSLServerAuthentication;
			{$IFDEF CLR}property OnSSLServerAuthenticationB: TSSLServerAuthenticationEventB read FOnSSLServerAuthenticationB write FOnSSLServerAuthenticationB;{$ENDIF}
      property OnSSLStatus: TSSLStatusEvent read FOnSSLStatus write FOnSSLStatus;

      property OnStartTransfer: TStartTransferEvent read FOnStartTransfer write FOnStartTransfer;

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
    PID_SMTPS_AllowExtensions = 1;
    PID_SMTPS_AttachedFile = 2;
    PID_SMTPS_AuthMechanism = 3;
    PID_SMTPS_BCc = 4;
    PID_SMTPS_Cc = 5;
    PID_SMTPS_Command = 6;
    PID_SMTPS_Connected = 7;
    PID_SMTPS_DeliveryNotificationTo = 8;
    PID_SMTPS_FirewallHost = 9;
    PID_SMTPS_FirewallPassword = 10;
    PID_SMTPS_FirewallPort = 11;
    PID_SMTPS_FirewallType = 12;
    PID_SMTPS_FirewallUser = 13;
    PID_SMTPS_From = 14;
    PID_SMTPS_Idle = 15;
    PID_SMTPS_Importance = 16;
    PID_SMTPS_LastReply = 17;
    PID_SMTPS_LocalHost = 18;
    PID_SMTPS_MailPort = 19;
    PID_SMTPS_MailServer = 20;
    PID_SMTPS_MessageDate = 21;
    PID_SMTPS_MessageHeaders = 22;
    PID_SMTPS_MessageId = 23;
    PID_SMTPS_MessageText = 24;
    PID_SMTPS_OtherHeaders = 25;
    PID_SMTPS_Password = 26;
    PID_SMTPS_Priority = 27;
    PID_SMTPS_ReadReceiptTo = 28;
    PID_SMTPS_ReplyTo = 29;
    PID_SMTPS_SendTo = 30;
    PID_SMTPS_Sensitivity = 31;
    PID_SMTPS_SSLAcceptServerCert = 32;
    PID_SMTPS_SSLCertEncoded = 33;
    PID_SMTPS_SSLCertStore = 34;
    PID_SMTPS_SSLCertStorePassword = 35;
    PID_SMTPS_SSLCertStoreType = 36;
    PID_SMTPS_SSLCertSubject = 37;
    PID_SMTPS_SSLServerCert = 38;
    PID_SMTPS_SSLServerCertStatus = 39;
    PID_SMTPS_SSLStartMode = 40;
    PID_SMTPS_Subject = 41;
    PID_SMTPS_Timeout = 42;
    PID_SMTPS_User = 43;

    EID_SMTPS_ConnectionStatus = 1;
    EID_SMTPS_EndTransfer = 2;
    EID_SMTPS_Error = 3;
    EID_SMTPS_Expand = 4;
    EID_SMTPS_PITrail = 5;
    EID_SMTPS_SSLServerAuthentication = 6;
    EID_SMTPS_SSLStatus = 7;
    EID_SMTPS_StartTransfer = 8;
    EID_SMTPS_Transfer = 9;


    MID_SMTPS_Config = 1;
    MID_SMTPS_Connect = 2;
    MID_SMTPS_Disconnect = 3;
    MID_SMTPS_DoEvents = 4;
    MID_SMTPS_Expand = 5;
    MID_SMTPS_Interrupt = 6;
    MID_SMTPS_ProcessQueue = 7;
    MID_SMTPS_Queue = 8;
    MID_SMTPS_ResetHeaders = 9;
    MID_SMTPS_Send = 10;
    MID_SMTPS_SendToTerminalAndEmail = 11;
    MID_SMTPS_SendToTerminalOnly = 12;
    MID_SMTPS_SendToTerminalOrEmail = 13;
    MID_SMTPS_Verify = 14;




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
{$R 'ipssmtps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsSMTPS; event_id: Integer; cparam: Integer; 
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
  _SMTPS_Create:        function(pMethod: PEventHandle; pObject: TipsSMTPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMTPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMTPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMTPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMTPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMTPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMTPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _SMTPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Create')]
  function _SMTPS_Create       (pMethod: TSMTPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Destroy')]
  function _SMTPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Set')]
  function _SMTPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Set')]
  function _SMTPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Set')]
  function _SMTPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Set')]
  function _SMTPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Set')]
  function _SMTPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Set')]
  function _SMTPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Get')]
  function _SMTPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Get')]
  function _SMTPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Get')]
  function _SMTPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Get')]
  function _SMTPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Get')]
  function _SMTPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Get')]
  function _SMTPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_GetLastError')]
  function _SMTPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_StaticInit')]
  function _SMTPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_CheckIndex')]
  function _SMTPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'SMTPS_Do')]
  function _SMTPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _SMTPS_Create       (pMethod: PEventHandle; pObject: TipsSMTPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMTPS_Create';
  function _SMTPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMTPS_Destroy';
  function _SMTPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMTPS_Set';
  function _SMTPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMTPS_Get';
  function _SMTPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMTPS_GetLastError';
  function _SMTPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMTPS_StaticInit';
  function _SMTPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMTPS_CheckIndex';
  function _SMTPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'SMTPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsSMTPS; event_id: Integer;
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
    tmp_ExpandAddress: String;
    tmp_PITrailDirection: Integer;
    tmp_PITrailMessage: String;
    tmp_SSLServerAuthenticationCertEncoded: String;
    tmp_SSLServerAuthenticationCertSubject: String;
    tmp_SSLServerAuthenticationCertIssuer: String;
    tmp_SSLServerAuthenticationStatus: String;
    tmp_SSLStatusMessage: String;
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

      EID_SMTPS_ConnectionStatus:
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
      EID_SMTPS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_SMTPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_SMTPS_Expand:
      begin
        if Assigned(lpContext.FOnExpand) then
        begin
          {assign temporary variables}
          tmp_ExpandAddress := AnsiString(PChar(params^[0]));


          lpContext.FOnExpand(lpContext, tmp_ExpandAddress);


        end;
      end;
      EID_SMTPS_PITrail:
      begin
        if Assigned(lpContext.FOnPITrail) then
        begin
          {assign temporary variables}
          tmp_PITrailDirection := Integer(params^[0]);
          tmp_PITrailMessage := AnsiString(PChar(params^[1]));


          lpContext.FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailMessage);



        end;
      end;
      EID_SMTPS_SSLServerAuthentication:
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
      EID_SMTPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_SMTPS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_SMTPS_Transfer:
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
function TipsSMTPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;


  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_ExpandAddress: String;

  tmp_PITrailDirection: Integer;
  tmp_PITrailMessage: String;

  tmp_SSLServerAuthenticationCertEncoded: String;
  tmp_SSLServerAuthenticationCertSubject: String;
  tmp_SSLServerAuthenticationCertIssuer: String;
  tmp_SSLServerAuthenticationStatus: String;

  tmp_SSLServerAuthenticationCertEncodedB: Array of Byte;
  tmp_SSLStatusMessage: String;


  tmp_TransferBytesTransferred: LongInt;


begin
 	p := nil;
  case event_id of
    EID_SMTPS_ConnectionStatus:
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
    EID_SMTPS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_SMTPS_Error:
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
    EID_SMTPS_Expand:
    begin
      if Assigned(FOnExpand) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ExpandAddress := Marshal.PtrToStringAnsi(p);


        FOnExpand(lpContext, tmp_ExpandAddress);


      end;


    end;
    EID_SMTPS_PITrail:
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
    EID_SMTPS_SSLServerAuthentication:
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
    EID_SMTPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_SMTPS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_SMTPS_Transfer:
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
    RegisterComponents('IP*Works! SSL', [TipsSMTPS]);
end;

constructor TipsSMTPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _SMTPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_SMTPS_Create <> nil then
      m_ctl := _SMTPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL SMTPS: Error creating component');

{$IFDEF CLR}
    _SMTPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_23, 0);
{$ELSE}
    _SMTPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_23)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_SMTPS_Do <> nil then
      _SMTPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_AuthMechanism(amUserPassword) except on E:Exception do end;
    try set_BCc('') except on E:Exception do end;
    try set_Cc('') except on E:Exception do end;
    try set_DeliveryNotificationTo('') except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_From('') except on E:Exception do end;
    try set_Importance(miUnspecified) except on E:Exception do end;
    try set_MailServer('') except on E:Exception do end;
    try set_MessageText('') except on E:Exception do end;
    try set_Priority(epUnspecified) except on E:Exception do end;
    try set_ReadReceiptTo('') except on E:Exception do end;
    try set_ReplyTo('') except on E:Exception do end;
    try set_SendTo('') except on E:Exception do end;
    try set_Sensitivity(esUnspecified) except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;
    try set_Subject('') except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;

end;

destructor TipsSMTPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_SMTPS_Destroy <> nil then{$ENDIF}
      	_SMTPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsSMTPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsSMTPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsSMTPS.AboutDlg;
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
	if @_SMTPS_Do <> nil then
{$ENDIF}
		_SMTPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsSMTPS.SetOK(key: String128);
begin
end;

function TipsSMTPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsSMTPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsSMTPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsSMTPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsSMTPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsSMTPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_SMTPS_GetLastError <> nil then{$ENDIF}
      msg := _SMTPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsSMTPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_SMTPS_Do <> nil then
      _SMTPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsSMTPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SMTPS_Set = nil then exit;{$ENDIF}
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSMTPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SMTPS_Set = nil then exit;{$ENDIF}
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSMTPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SMTPS_Set = nil then exit;{$ENDIF}
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsSMTPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_SMTPS_Set = nil then exit;{$ENDIF}
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsSMTPS.get_AllowExtensions: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_SMTPS_GetBOOL(m_ctl, PID_SMTPS_AllowExtensions, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_AllowExtensions, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_AllowExtensions(valAllowExtensions: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetBOOL(m_ctl, PID_SMTPS_AllowExtensions, 0, valAllowExtensions, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_AllowExtensions, 0, Integer(valAllowExtensions), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_AttachedFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_AttachedFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_AttachedFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_AttachedFile(valAttachedFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_AttachedFile, 0, valAttachedFile, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_AttachedFile, 0, Integer(PChar(valAttachedFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_AuthMechanism: TipssmtpsAuthMechanisms;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmtpsAuthMechanisms(_SMTPS_GetENUM(m_ctl, PID_SMTPS_AuthMechanism, 0, err));
{$ELSE}
  result := TipssmtpsAuthMechanisms(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_AuthMechanism, 0, nil);
  result := TipssmtpsAuthMechanisms(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_AuthMechanism(valAuthMechanism: TipssmtpsAuthMechanisms);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetENUM(m_ctl, PID_SMTPS_AuthMechanism, 0, Integer(valAuthMechanism), 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_AuthMechanism, 0, Integer(valAuthMechanism), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_BCc: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_BCc, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_BCc, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_BCc(valBCc: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_BCc, 0, valBCc, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_BCc, 0, Integer(PChar(valBCc)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_Cc: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_Cc, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Cc, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_Cc(valCc: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_Cc, 0, valCc, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Cc, 0, Integer(PChar(valCc)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsSMTPS.set_Command(valCommand: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_Command, 0, valCommand, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Command, 0, Integer(PChar(valCommand)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_SMTPS_GetBOOL(m_ctl, PID_SMTPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetBOOL(m_ctl, PID_SMTPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_DeliveryNotificationTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_DeliveryNotificationTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_DeliveryNotificationTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_DeliveryNotificationTo(valDeliveryNotificationTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_DeliveryNotificationTo, 0, valDeliveryNotificationTo, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_DeliveryNotificationTo, 0, Integer(PChar(valDeliveryNotificationTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SMTPS_GetLONG(m_ctl, PID_SMTPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetLONG(m_ctl, PID_SMTPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_FirewallType: TipssmtpsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmtpsFirewallTypes(_SMTPS_GetENUM(m_ctl, PID_SMTPS_FirewallType, 0, err));
{$ELSE}
  result := TipssmtpsFirewallTypes(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_FirewallType, 0, nil);
  result := TipssmtpsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_FirewallType(valFirewallType: TipssmtpsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetENUM(m_ctl, PID_SMTPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_From: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_From, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_From, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_From(valFrom: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_From, 0, valFrom, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_From, 0, Integer(PChar(valFrom)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_SMTPS_GetBOOL(m_ctl, PID_SMTPS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsSMTPS.get_Importance: TipssmtpsImportances;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmtpsImportances(_SMTPS_GetENUM(m_ctl, PID_SMTPS_Importance, 0, err));
{$ELSE}
  result := TipssmtpsImportances(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Importance, 0, nil);
  result := TipssmtpsImportances(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_Importance(valImportance: TipssmtpsImportances);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetENUM(m_ctl, PID_SMTPS_Importance, 0, Integer(valImportance), 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Importance, 0, Integer(valImportance), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_LastReply: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_LastReply, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_LastReply, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSMTPS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_MailPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SMTPS_GetLONG(m_ctl, PID_SMTPS_MailPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_MailPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_MailPort(valMailPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetLONG(m_ctl, PID_SMTPS_MailPort, 0, valMailPort, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_MailPort, 0, Integer(valMailPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_MailServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_MailServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_MailServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_MailServer(valMailServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_MailServer, 0, valMailServer, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_MailServer, 0, Integer(PChar(valMailServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_MessageDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_MessageDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_MessageDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_MessageDate(valMessageDate: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_MessageDate, 0, valMessageDate, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_MessageDate, 0, Integer(PChar(valMessageDate)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_MessageHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_MessageHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_MessageHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSMTPS.get_MessageId: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_MessageId, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_MessageId, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_MessageId(valMessageId: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_MessageId, 0, valMessageId, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_MessageId, 0, Integer(PChar(valMessageId)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_MessageText: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_MessageText, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_MessageText, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_MessageText(valMessageText: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_MessageText, 0, valMessageText, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_MessageText, 0, Integer(PChar(valMessageText)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_OtherHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_OtherHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_OtherHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_OtherHeaders(valOtherHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_OtherHeaders, 0, valOtherHeaders, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_OtherHeaders, 0, Integer(PChar(valOtherHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_Priority: TipssmtpsPriorities;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmtpsPriorities(_SMTPS_GetENUM(m_ctl, PID_SMTPS_Priority, 0, err));
{$ELSE}
  result := TipssmtpsPriorities(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Priority, 0, nil);
  result := TipssmtpsPriorities(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_Priority(valPriority: TipssmtpsPriorities);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetENUM(m_ctl, PID_SMTPS_Priority, 0, Integer(valPriority), 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Priority, 0, Integer(valPriority), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_ReadReceiptTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_ReadReceiptTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_ReadReceiptTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_ReadReceiptTo(valReadReceiptTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_ReadReceiptTo, 0, valReadReceiptTo, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_ReadReceiptTo, 0, Integer(PChar(valReadReceiptTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_ReplyTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_ReplyTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_ReplyTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_ReplyTo(valReplyTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_ReplyTo, 0, valReplyTo, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_ReplyTo, 0, Integer(PChar(valReplyTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_SendTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_SendTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SendTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_SendTo(valSendTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_SendTo, 0, valSendTo, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SendTo, 0, Integer(PChar(valSendTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_Sensitivity: TipssmtpsSensitivities;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmtpsSensitivities(_SMTPS_GetENUM(m_ctl, PID_SMTPS_Sensitivity, 0, err));
{$ELSE}
  result := TipssmtpsSensitivities(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Sensitivity, 0, nil);
  result := TipssmtpsSensitivities(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_Sensitivity(valSensitivity: TipssmtpsSensitivities);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetENUM(m_ctl, PID_SMTPS_Sensitivity, 0, Integer(valSensitivity), 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Sensitivity, 0, Integer(valSensitivity), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetBSTR(m_ctl, PID_SMTPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSMTPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetBSTR(m_ctl, PID_SMTPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetBSTR(m_ctl, PID_SMTPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSMTPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetBSTR(m_ctl, PID_SMTPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetBSTR(m_ctl, PID_SMTPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsSMTPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetBSTR(m_ctl, PID_SMTPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_SSLCertStoreType: TipssmtpsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmtpsSSLCertStoreTypes(_SMTPS_GetENUM(m_ctl, PID_SMTPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipssmtpsSSLCertStoreTypes(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLCertStoreType, 0, nil);
  result := TipssmtpsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_SSLCertStoreType(valSSLCertStoreType: TipssmtpsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetENUM(m_ctl, PID_SMTPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetBSTR(m_ctl, PID_SMTPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsSMTPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsSMTPS.get_SSLStartMode: TipssmtpsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipssmtpsSSLStartModes(_SMTPS_GetENUM(m_ctl, PID_SMTPS_SSLStartMode, 0, err));
{$ELSE}
  result := TipssmtpsSSLStartModes(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_SSLStartMode, 0, nil);
  result := TipssmtpsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_SSLStartMode(valSSLStartMode: TipssmtpsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetENUM(m_ctl, PID_SMTPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_Subject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_Subject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Subject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_Subject(valSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_Subject, 0, valSubject, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Subject, 0, Integer(PChar(valSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_SMTPS_GetINT(m_ctl, PID_SMTPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsSMTPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetINT(m_ctl, PID_SMTPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsSMTPS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _SMTPS_GetCSTR(m_ctl, PID_SMTPS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_SMTPS_Get = nil then exit;
  tmp := _SMTPS_Get(m_ctl, PID_SMTPS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsSMTPS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _SMTPS_SetCSTR(m_ctl, PID_SMTPS_User, 0, valUser, 0);
{$ELSE}
	if @_SMTPS_Set = nil then exit;
  err := _SMTPS_Set(m_ctl, PID_SMTPS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsSMTPS.Config(ConfigurationString: String): String;
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


  err := _SMTPS_Do(m_ctl, MID_SMTPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsSMTPS.Connect();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_Connect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_Connect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.Disconnect();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_Disconnect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_Disconnect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.DoEvents();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.Expand(EmailAddress: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(EmailAddress);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMTPS_Do(m_ctl, MID_SMTPS_Expand, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(EmailAddress);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_Expand, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.Interrupt();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.ProcessQueue(QueueDir: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(QueueDir);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMTPS_Do(m_ctl, MID_SMTPS_ProcessQueue, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(QueueDir);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_ProcessQueue, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsSMTPS.Queue(QueueDir: String): String;
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

  param[i] := Marshal.StringToHGlobalAnsi(QueueDir);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMTPS_Do(m_ctl, MID_SMTPS_Queue, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(QueueDir);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_Queue, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsSMTPS.ResetHeaders();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_ResetHeaders, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_ResetHeaders, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.Send();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_Send, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_Send, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.SendToTerminalAndEmail();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_SendToTerminalAndEmail, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_SendToTerminalAndEmail, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.SendToTerminalOnly();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_SendToTerminalOnly, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_SendToTerminalOnly, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.SendToTerminalOrEmail();

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



  err := _SMTPS_Do(m_ctl, MID_SMTPS_SendToTerminalOrEmail, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_SendToTerminalOrEmail, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsSMTPS.Verify(EmailAddress: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(EmailAddress);
  paramcb[i] := 0;

  i := i + 1;


  err := _SMTPS_Do(m_ctl, MID_SMTPS_Verify, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(EmailAddress);
  paramcb[i] := 0;

  i := i + 1;


	if @_SMTPS_Do = nil then exit;
  err := _SMTPS_Do(m_ctl, MID_SMTPS_Verify, 1, @param, @paramcb); 
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

	_SMTPS_Create := nil;
	_SMTPS_Destroy := nil;
	_SMTPS_Set := nil;
	_SMTPS_Get := nil;
	_SMTPS_GetLastError := nil;
	_SMTPS_StaticInit := nil;
	_SMTPS_CheckIndex := nil;
	_SMTPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_smtps_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_SMTPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'SMTPS_Create');
		@_SMTPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'SMTPS_Destroy');
		@_SMTPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'SMTPS_Set');
		@_SMTPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'SMTPS_Get');
		@_SMTPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'SMTPS_GetLastError');
		@_SMTPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'SMTPS_CheckIndex');
		@_SMTPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'SMTPS_Do');
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
  @_SMTPS_Create       := nil;
  @_SMTPS_Destroy      := nil;
  @_SMTPS_Set          := nil;
  @_SMTPS_Get          := nil;
  @_SMTPS_GetLastError := nil;
  @_SMTPS_CheckIndex   := nil;
  @_SMTPS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




