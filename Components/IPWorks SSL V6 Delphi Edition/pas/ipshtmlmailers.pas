
unit ipshtmlmailers;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipshtmlmailersAuthMechanisms = 
(

									 
                   amUserPassword,

									 
                   amCRAMMD5
);
  TipshtmlmailersFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipshtmlmailersImportances = 
(

									 
                   miUnspecified,

									 
                   miHigh,

									 
                   miNormal,

									 
                   miLow
);
  TipshtmlmailersPriorities = 
(

									 
                   epUnspecified,

									 
                   epNormal,

									 
                   epUrgent,

									 
                   epNonUrgent
);
  TipshtmlmailersSensitivities = 
(

									 
                   esUnspecified,

									 
                   esPersonal,

									 
                   esPrivate,

									 
                   esCompanyConfidential
);
  TipshtmlmailersSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipshtmlmailersSSLStartModes = 
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
  THTMLMailerSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsHTMLMailerS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsHTMLMailerS = class(TipsCore)
    public
      FOnConnectionStatus: TConnectionStatusEvent;

      FOnEndTransfer: TEndTransferEvent;

      FOnError: TErrorEvent;

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
      m_anchor: THTMLMailerSEventHook;
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

      function get_Attachments(AttachmentIndex: Word): String;
      procedure set_Attachments(AttachmentIndex: Word; valAttachments: String);


      procedure set_Command(valCommand: String);

      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);

      function get_ImageIds(ImageIndex: Word): String;
      procedure set_ImageIds(ImageIndex: Word; valImageIds: String);

      function get_Images(ImageIndex: Word): String;
      procedure set_Images(ImageIndex: Word; valImages: String);

      function get_ImageTypes(ImageIndex: Word): String;
      procedure set_ImageTypes(ImageIndex: Word; valImageTypes: String);

      function get_MailPort: Integer;
      procedure set_MailPort(valMailPort: Integer);

      function get_MessageDate: String;
      procedure set_MessageDate(valMessageDate: String);

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


      function get_AttachmentCount: Integer;
      procedure set_AttachmentCount(valAttachmentCount: Integer);



      function get_AuthMechanism: TipshtmlmailersAuthMechanisms;
      procedure set_AuthMechanism(valAuthMechanism: TipshtmlmailersAuthMechanisms);

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

      function get_FirewallType: TipshtmlmailersFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipshtmlmailersFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_From: String;
      procedure set_From(valFrom: String);

      function get_HTMLFile: String;
      procedure set_HTMLFile(valHTMLFile: String);

      function get_Idle: Boolean;


      function get_ImageCount: Integer;
      procedure set_ImageCount(valImageCount: Integer);







      function get_Importance: TipshtmlmailersImportances;
      procedure set_Importance(valImportance: TipshtmlmailersImportances);

      function get_LastReply: String;


      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);



      function get_MailServer: String;
      procedure set_MailServer(valMailServer: String);



      function get_MessageHTML: String;
      procedure set_MessageHTML(valMessageHTML: String);



      function get_MessageText: String;
      procedure set_MessageText(valMessageText: String);



      function get_ParseHTML: Boolean;
      procedure set_ParseHTML(valParseHTML: Boolean);



      function get_Priority: TipshtmlmailersPriorities;
      procedure set_Priority(valPriority: TipshtmlmailersPriorities);

      function get_ReadReceiptTo: String;
      procedure set_ReadReceiptTo(valReadReceiptTo: String);

      function get_ReplyTo: String;
      procedure set_ReplyTo(valReplyTo: String);

      function get_SendTo: String;
      procedure set_SendTo(valSendTo: String);

      function get_Sensitivity: TipshtmlmailersSensitivities;
      procedure set_Sensitivity(valSensitivity: TipshtmlmailersSensitivities);

      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipshtmlmailersSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipshtmlmailersSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipshtmlmailersSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipshtmlmailersSSLStartModes);

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



      property Attachments[AttachmentIndex: Word]: String
               read get_Attachments
               write set_Attachments               ;







      property Command: String

               write set_Command               ;

      property Connected: Boolean
               read get_Connected
               write set_Connected               ;





















      property ImageIds[ImageIndex: Word]: String
               read get_ImageIds
               write set_ImageIds               ;

      property Images[ImageIndex: Word]: String
               read get_Images
               write set_Images               ;

      property ImageTypes[ImageIndex: Word]: String
               read get_ImageTypes
               write set_ImageTypes               ;







      property MailPort: Integer
               read get_MailPort
               write set_MailPort               ;



      property MessageDate: String
               read get_MessageDate
               write set_MessageDate               ;



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
      procedure AddAttachment(FileName: String);

      procedure Connect();

      procedure Disconnect();

      procedure DoEvents();

      procedure Interrupt();

      procedure ProcessQueue(QueueDir: String);

      function Queue(QueueDir: String): String;
      procedure ResetHeaders();

      procedure Send();


{$ENDIF}

    published

      property AttachmentCount: Integer
                   read get_AttachmentCount
                   write set_AttachmentCount
                   default 0
                   ;

      property AuthMechanism: TipshtmlmailersAuthMechanisms
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
      property FirewallType: TipshtmlmailersFirewallTypes
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
      property HTMLFile: String
                   read get_HTMLFile
                   write set_HTMLFile
                   
                   ;
      property Idle: Boolean
                   read get_Idle
                    write SetNoopBoolean
                   stored False

                   ;
      property ImageCount: Integer
                   read get_ImageCount
                   write set_ImageCount
                   default 0
                   ;



      property Importance: TipshtmlmailersImportances
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

      property MessageHTML: String
                   read get_MessageHTML
                   write set_MessageHTML
                   
                   ;

      property MessageText: String
                   read get_MessageText
                   write set_MessageText
                   
                   ;

      property ParseHTML: Boolean
                   read get_ParseHTML
                   write set_ParseHTML
                   default true
                   ;

      property Priority: TipshtmlmailersPriorities
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
      property Sensitivity: TipshtmlmailersSensitivities
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
      property SSLCertStoreType: TipshtmlmailersSSLCertStoreTypes
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
      property SSLStartMode: TipshtmlmailersSSLStartModes
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
    PID_HTMLMailerS_AttachmentCount = 1;
    PID_HTMLMailerS_Attachments = 2;
    PID_HTMLMailerS_AuthMechanism = 3;
    PID_HTMLMailerS_BCc = 4;
    PID_HTMLMailerS_Cc = 5;
    PID_HTMLMailerS_Command = 6;
    PID_HTMLMailerS_Connected = 7;
    PID_HTMLMailerS_DeliveryNotificationTo = 8;
    PID_HTMLMailerS_FirewallHost = 9;
    PID_HTMLMailerS_FirewallPassword = 10;
    PID_HTMLMailerS_FirewallPort = 11;
    PID_HTMLMailerS_FirewallType = 12;
    PID_HTMLMailerS_FirewallUser = 13;
    PID_HTMLMailerS_From = 14;
    PID_HTMLMailerS_HTMLFile = 15;
    PID_HTMLMailerS_Idle = 16;
    PID_HTMLMailerS_ImageCount = 17;
    PID_HTMLMailerS_ImageIds = 18;
    PID_HTMLMailerS_Images = 19;
    PID_HTMLMailerS_ImageTypes = 20;
    PID_HTMLMailerS_Importance = 21;
    PID_HTMLMailerS_LastReply = 22;
    PID_HTMLMailerS_LocalHost = 23;
    PID_HTMLMailerS_MailPort = 24;
    PID_HTMLMailerS_MailServer = 25;
    PID_HTMLMailerS_MessageDate = 26;
    PID_HTMLMailerS_MessageHTML = 27;
    PID_HTMLMailerS_MessageId = 28;
    PID_HTMLMailerS_MessageText = 29;
    PID_HTMLMailerS_OtherHeaders = 30;
    PID_HTMLMailerS_ParseHTML = 31;
    PID_HTMLMailerS_Password = 32;
    PID_HTMLMailerS_Priority = 33;
    PID_HTMLMailerS_ReadReceiptTo = 34;
    PID_HTMLMailerS_ReplyTo = 35;
    PID_HTMLMailerS_SendTo = 36;
    PID_HTMLMailerS_Sensitivity = 37;
    PID_HTMLMailerS_SSLAcceptServerCert = 38;
    PID_HTMLMailerS_SSLCertEncoded = 39;
    PID_HTMLMailerS_SSLCertStore = 40;
    PID_HTMLMailerS_SSLCertStorePassword = 41;
    PID_HTMLMailerS_SSLCertStoreType = 42;
    PID_HTMLMailerS_SSLCertSubject = 43;
    PID_HTMLMailerS_SSLServerCert = 44;
    PID_HTMLMailerS_SSLServerCertStatus = 45;
    PID_HTMLMailerS_SSLStartMode = 46;
    PID_HTMLMailerS_Subject = 47;
    PID_HTMLMailerS_Timeout = 48;
    PID_HTMLMailerS_User = 49;

    EID_HTMLMailerS_ConnectionStatus = 1;
    EID_HTMLMailerS_EndTransfer = 2;
    EID_HTMLMailerS_Error = 3;
    EID_HTMLMailerS_PITrail = 4;
    EID_HTMLMailerS_SSLServerAuthentication = 5;
    EID_HTMLMailerS_SSLStatus = 6;
    EID_HTMLMailerS_StartTransfer = 7;
    EID_HTMLMailerS_Transfer = 8;


    MID_HTMLMailerS_Config = 1;
    MID_HTMLMailerS_AddAttachment = 2;
    MID_HTMLMailerS_Connect = 3;
    MID_HTMLMailerS_Disconnect = 4;
    MID_HTMLMailerS_DoEvents = 5;
    MID_HTMLMailerS_Interrupt = 6;
    MID_HTMLMailerS_ProcessQueue = 7;
    MID_HTMLMailerS_Queue = 8;
    MID_HTMLMailerS_ResetHeaders = 9;
    MID_HTMLMailerS_Send = 10;




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
{$R 'ipshtmlmailers.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsHTMLMailerS; event_id: Integer; cparam: Integer; 
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
  _HTMLMailerS_Create:        function(pMethod: PEventHandle; pObject: TipsHTMLMailerS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTMLMailerS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTMLMailerS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTMLMailerS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTMLMailerS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTMLMailerS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTMLMailerS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _HTMLMailerS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Create')]
  function _HTMLMailerS_Create       (pMethod: THTMLMailerSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Destroy')]
  function _HTMLMailerS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Set')]
  function _HTMLMailerS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Set')]
  function _HTMLMailerS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Set')]
  function _HTMLMailerS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Set')]
  function _HTMLMailerS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Set')]
  function _HTMLMailerS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Set')]
  function _HTMLMailerS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Get')]
  function _HTMLMailerS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Get')]
  function _HTMLMailerS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Get')]
  function _HTMLMailerS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Get')]
  function _HTMLMailerS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Get')]
  function _HTMLMailerS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Get')]
  function _HTMLMailerS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_GetLastError')]
  function _HTMLMailerS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_StaticInit')]
  function _HTMLMailerS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_CheckIndex')]
  function _HTMLMailerS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'HTMLMailerS_Do')]
  function _HTMLMailerS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _HTMLMailerS_Create       (pMethod: PEventHandle; pObject: TipsHTMLMailerS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTMLMailerS_Create';
  function _HTMLMailerS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTMLMailerS_Destroy';
  function _HTMLMailerS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTMLMailerS_Set';
  function _HTMLMailerS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTMLMailerS_Get';
  function _HTMLMailerS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTMLMailerS_GetLastError';
  function _HTMLMailerS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTMLMailerS_StaticInit';
  function _HTMLMailerS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTMLMailerS_CheckIndex';
  function _HTMLMailerS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'HTMLMailerS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsHTMLMailerS; event_id: Integer;
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

      EID_HTMLMailerS_ConnectionStatus:
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
      EID_HTMLMailerS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_HTMLMailerS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_HTMLMailerS_PITrail:
      begin
        if Assigned(lpContext.FOnPITrail) then
        begin
          {assign temporary variables}
          tmp_PITrailDirection := Integer(params^[0]);
          tmp_PITrailMessage := AnsiString(PChar(params^[1]));


          lpContext.FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailMessage);



        end;
      end;
      EID_HTMLMailerS_SSLServerAuthentication:
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
      EID_HTMLMailerS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_HTMLMailerS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_HTMLMailerS_Transfer:
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
function TipsHTMLMailerS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;


  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

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
    EID_HTMLMailerS_ConnectionStatus:
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
    EID_HTMLMailerS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_HTMLMailerS_Error:
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
    EID_HTMLMailerS_PITrail:
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
    EID_HTMLMailerS_SSLServerAuthentication:
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
    EID_HTMLMailerS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_HTMLMailerS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_HTMLMailerS_Transfer:
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
    RegisterComponents('IP*Works! SSL', [TipsHTMLMailerS]);
end;

constructor TipsHTMLMailerS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _HTMLMailerS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_HTMLMailerS_Create <> nil then
      m_ctl := _HTMLMailerS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL HTMLMailerS: Error creating component');

{$IFDEF CLR}
    _HTMLMailerS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_42, 0);
{$ELSE}
    _HTMLMailerS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_42)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_HTMLMailerS_Do <> nil then
      _HTMLMailerS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_AttachmentCount(0) except on E:Exception do end;
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
    try set_HTMLFile('') except on E:Exception do end;
    try set_ImageCount(0) except on E:Exception do end;
    try set_Importance(miUnspecified) except on E:Exception do end;
    try set_MailServer('') except on E:Exception do end;
    try set_MessageHTML('') except on E:Exception do end;
    try set_MessageText('') except on E:Exception do end;
    try set_ParseHTML(true) except on E:Exception do end;
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

destructor TipsHTMLMailerS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_HTMLMailerS_Destroy <> nil then{$ENDIF}
      	_HTMLMailerS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsHTMLMailerS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsHTMLMailerS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsHTMLMailerS.AboutDlg;
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
	if @_HTMLMailerS_Do <> nil then
{$ENDIF}
		_HTMLMailerS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsHTMLMailerS.SetOK(key: String128);
begin
end;

function TipsHTMLMailerS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsHTMLMailerS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsHTMLMailerS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsHTMLMailerS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsHTMLMailerS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsHTMLMailerS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_HTMLMailerS_GetLastError <> nil then{$ENDIF}
      msg := _HTMLMailerS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsHTMLMailerS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_HTMLMailerS_Do <> nil then
      _HTMLMailerS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsHTMLMailerS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTMLMailerS_Set = nil then exit;{$ENDIF}
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsHTMLMailerS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTMLMailerS_Set = nil then exit;{$ENDIF}
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsHTMLMailerS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTMLMailerS_Set = nil then exit;{$ENDIF}
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsHTMLMailerS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_HTMLMailerS_Set = nil then exit;{$ENDIF}
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsHTMLMailerS.get_AttachmentCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTMLMailerS_GetINT(m_ctl, PID_HTMLMailerS_AttachmentCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_AttachmentCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_AttachmentCount(valAttachmentCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetINT(m_ctl, PID_HTMLMailerS_AttachmentCount, 0, valAttachmentCount, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_AttachmentCount, 0, Integer(valAttachmentCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Attachments(AttachmentIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_Attachments, AttachmentIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_HTMLMailerS_CheckIndex = nil then exit;
  err :=  _HTMLMailerS_CheckIndex(m_ctl, PID_HTMLMailerS_Attachments, AttachmentIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for Attachments');
	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Attachments, AttachmentIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Attachments(AttachmentIndex: Word; valAttachments: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_Attachments, AttachmentIndex, valAttachments, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Attachments, AttachmentIndex, Integer(PChar(valAttachments)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_AuthMechanism: TipshtmlmailersAuthMechanisms;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshtmlmailersAuthMechanisms(_HTMLMailerS_GetENUM(m_ctl, PID_HTMLMailerS_AuthMechanism, 0, err));
{$ELSE}
  result := TipshtmlmailersAuthMechanisms(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_AuthMechanism, 0, nil);
  result := TipshtmlmailersAuthMechanisms(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_AuthMechanism(valAuthMechanism: TipshtmlmailersAuthMechanisms);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetENUM(m_ctl, PID_HTMLMailerS_AuthMechanism, 0, Integer(valAuthMechanism), 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_AuthMechanism, 0, Integer(valAuthMechanism), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_BCc: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_BCc, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_BCc, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_BCc(valBCc: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_BCc, 0, valBCc, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_BCc, 0, Integer(PChar(valBCc)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Cc: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_Cc, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Cc, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Cc(valCc: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_Cc, 0, valCc, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Cc, 0, Integer(PChar(valCc)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsHTMLMailerS.set_Command(valCommand: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_Command, 0, valCommand, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Command, 0, Integer(PChar(valCommand)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_HTMLMailerS_GetBOOL(m_ctl, PID_HTMLMailerS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetBOOL(m_ctl, PID_HTMLMailerS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_DeliveryNotificationTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_DeliveryNotificationTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_DeliveryNotificationTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_DeliveryNotificationTo(valDeliveryNotificationTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_DeliveryNotificationTo, 0, valDeliveryNotificationTo, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_DeliveryNotificationTo, 0, Integer(PChar(valDeliveryNotificationTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTMLMailerS_GetLONG(m_ctl, PID_HTMLMailerS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetLONG(m_ctl, PID_HTMLMailerS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_FirewallType: TipshtmlmailersFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshtmlmailersFirewallTypes(_HTMLMailerS_GetENUM(m_ctl, PID_HTMLMailerS_FirewallType, 0, err));
{$ELSE}
  result := TipshtmlmailersFirewallTypes(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_FirewallType, 0, nil);
  result := TipshtmlmailersFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_FirewallType(valFirewallType: TipshtmlmailersFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetENUM(m_ctl, PID_HTMLMailerS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_From: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_From, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_From, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_From(valFrom: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_From, 0, valFrom, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_From, 0, Integer(PChar(valFrom)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_HTMLFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_HTMLFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_HTMLFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_HTMLFile(valHTMLFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_HTMLFile, 0, valHTMLFile, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_HTMLFile, 0, Integer(PChar(valHTMLFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_HTMLMailerS_GetBOOL(m_ctl, PID_HTMLMailerS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsHTMLMailerS.get_ImageCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTMLMailerS_GetINT(m_ctl, PID_HTMLMailerS_ImageCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_ImageCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_ImageCount(valImageCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetINT(m_ctl, PID_HTMLMailerS_ImageCount, 0, valImageCount, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_ImageCount, 0, Integer(valImageCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_ImageIds(ImageIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_ImageIds, ImageIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_HTMLMailerS_CheckIndex = nil then exit;
  err :=  _HTMLMailerS_CheckIndex(m_ctl, PID_HTMLMailerS_ImageIds, ImageIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ImageIds');
	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_ImageIds, ImageIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_ImageIds(ImageIndex: Word; valImageIds: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_ImageIds, ImageIndex, valImageIds, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_ImageIds, ImageIndex, Integer(PChar(valImageIds)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Images(ImageIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_Images, ImageIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_HTMLMailerS_CheckIndex = nil then exit;
  err :=  _HTMLMailerS_CheckIndex(m_ctl, PID_HTMLMailerS_Images, ImageIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for Images');
	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Images, ImageIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Images(ImageIndex: Word; valImages: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_Images, ImageIndex, valImages, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Images, ImageIndex, Integer(PChar(valImages)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_ImageTypes(ImageIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_ImageTypes, ImageIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_HTMLMailerS_CheckIndex = nil then exit;
  err :=  _HTMLMailerS_CheckIndex(m_ctl, PID_HTMLMailerS_ImageTypes, ImageIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for ImageTypes');
	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_ImageTypes, ImageIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_ImageTypes(ImageIndex: Word; valImageTypes: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_ImageTypes, ImageIndex, valImageTypes, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_ImageTypes, ImageIndex, Integer(PChar(valImageTypes)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Importance: TipshtmlmailersImportances;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshtmlmailersImportances(_HTMLMailerS_GetENUM(m_ctl, PID_HTMLMailerS_Importance, 0, err));
{$ELSE}
  result := TipshtmlmailersImportances(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Importance, 0, nil);
  result := TipshtmlmailersImportances(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Importance(valImportance: TipshtmlmailersImportances);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetENUM(m_ctl, PID_HTMLMailerS_Importance, 0, Integer(valImportance), 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Importance, 0, Integer(valImportance), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_LastReply: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_LastReply, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_LastReply, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsHTMLMailerS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_MailPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTMLMailerS_GetLONG(m_ctl, PID_HTMLMailerS_MailPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_MailPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_MailPort(valMailPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetLONG(m_ctl, PID_HTMLMailerS_MailPort, 0, valMailPort, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_MailPort, 0, Integer(valMailPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_MailServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_MailServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_MailServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_MailServer(valMailServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_MailServer, 0, valMailServer, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_MailServer, 0, Integer(PChar(valMailServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_MessageDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_MessageDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_MessageDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_MessageDate(valMessageDate: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_MessageDate, 0, valMessageDate, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_MessageDate, 0, Integer(PChar(valMessageDate)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_MessageHTML: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_MessageHTML, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_MessageHTML, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_MessageHTML(valMessageHTML: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_MessageHTML, 0, valMessageHTML, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_MessageHTML, 0, Integer(PChar(valMessageHTML)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_MessageId: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_MessageId, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_MessageId, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_MessageId(valMessageId: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_MessageId, 0, valMessageId, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_MessageId, 0, Integer(PChar(valMessageId)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_MessageText: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_MessageText, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_MessageText, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_MessageText(valMessageText: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_MessageText, 0, valMessageText, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_MessageText, 0, Integer(PChar(valMessageText)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_OtherHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_OtherHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_OtherHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_OtherHeaders(valOtherHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_OtherHeaders, 0, valOtherHeaders, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_OtherHeaders, 0, Integer(PChar(valOtherHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_ParseHTML: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_HTMLMailerS_GetBOOL(m_ctl, PID_HTMLMailerS_ParseHTML, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_ParseHTML, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_ParseHTML(valParseHTML: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetBOOL(m_ctl, PID_HTMLMailerS_ParseHTML, 0, valParseHTML, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_ParseHTML, 0, Integer(valParseHTML), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_Password, 0, valPassword, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Priority: TipshtmlmailersPriorities;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshtmlmailersPriorities(_HTMLMailerS_GetENUM(m_ctl, PID_HTMLMailerS_Priority, 0, err));
{$ELSE}
  result := TipshtmlmailersPriorities(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Priority, 0, nil);
  result := TipshtmlmailersPriorities(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Priority(valPriority: TipshtmlmailersPriorities);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetENUM(m_ctl, PID_HTMLMailerS_Priority, 0, Integer(valPriority), 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Priority, 0, Integer(valPriority), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_ReadReceiptTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_ReadReceiptTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_ReadReceiptTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_ReadReceiptTo(valReadReceiptTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_ReadReceiptTo, 0, valReadReceiptTo, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_ReadReceiptTo, 0, Integer(PChar(valReadReceiptTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_ReplyTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_ReplyTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_ReplyTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_ReplyTo(valReplyTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_ReplyTo, 0, valReplyTo, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_ReplyTo, 0, Integer(PChar(valReplyTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_SendTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_SendTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SendTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_SendTo(valSendTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_SendTo, 0, valSendTo, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SendTo, 0, Integer(PChar(valSendTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Sensitivity: TipshtmlmailersSensitivities;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshtmlmailersSensitivities(_HTMLMailerS_GetENUM(m_ctl, PID_HTMLMailerS_Sensitivity, 0, err));
{$ELSE}
  result := TipshtmlmailersSensitivities(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Sensitivity, 0, nil);
  result := TipshtmlmailersSensitivities(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Sensitivity(valSensitivity: TipshtmlmailersSensitivities);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetENUM(m_ctl, PID_HTMLMailerS_Sensitivity, 0, Integer(valSensitivity), 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Sensitivity, 0, Integer(valSensitivity), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetBSTR(m_ctl, PID_HTMLMailerS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetBSTR(m_ctl, PID_HTMLMailerS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetBSTR(m_ctl, PID_HTMLMailerS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetBSTR(m_ctl, PID_HTMLMailerS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetBSTR(m_ctl, PID_HTMLMailerS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetBSTR(m_ctl, PID_HTMLMailerS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_SSLCertStoreType: TipshtmlmailersSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshtmlmailersSSLCertStoreTypes(_HTMLMailerS_GetENUM(m_ctl, PID_HTMLMailerS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipshtmlmailersSSLCertStoreTypes(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLCertStoreType, 0, nil);
  result := TipshtmlmailersSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_SSLCertStoreType(valSSLCertStoreType: TipshtmlmailersSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetENUM(m_ctl, PID_HTMLMailerS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetBSTR(m_ctl, PID_HTMLMailerS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsHTMLMailerS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsHTMLMailerS.get_SSLStartMode: TipshtmlmailersSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipshtmlmailersSSLStartModes(_HTMLMailerS_GetENUM(m_ctl, PID_HTMLMailerS_SSLStartMode, 0, err));
{$ELSE}
  result := TipshtmlmailersSSLStartModes(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_SSLStartMode, 0, nil);
  result := TipshtmlmailersSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_SSLStartMode(valSSLStartMode: TipshtmlmailersSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetENUM(m_ctl, PID_HTMLMailerS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Subject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_Subject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Subject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Subject(valSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_Subject, 0, valSubject, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Subject, 0, Integer(PChar(valSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_HTMLMailerS_GetINT(m_ctl, PID_HTMLMailerS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetINT(m_ctl, PID_HTMLMailerS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsHTMLMailerS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _HTMLMailerS_GetCSTR(m_ctl, PID_HTMLMailerS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_HTMLMailerS_Get = nil then exit;
  tmp := _HTMLMailerS_Get(m_ctl, PID_HTMLMailerS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsHTMLMailerS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _HTMLMailerS_SetCSTR(m_ctl, PID_HTMLMailerS_User, 0, valUser, 0);
{$ELSE}
	if @_HTMLMailerS_Set = nil then exit;
  err := _HTMLMailerS_Set(m_ctl, PID_HTMLMailerS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsHTMLMailerS.Config(ConfigurationString: String): String;
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


  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsHTMLMailerS.AddAttachment(FileName: String);

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


  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_AddAttachment, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(FileName);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_AddAttachment, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTMLMailerS.Connect();

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



  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Connect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Connect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTMLMailerS.Disconnect();

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



  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Disconnect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Disconnect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTMLMailerS.DoEvents();

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



  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTMLMailerS.Interrupt();

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



  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTMLMailerS.ProcessQueue(QueueDir: String);

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


  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_ProcessQueue, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(QueueDir);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_ProcessQueue, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsHTMLMailerS.Queue(QueueDir: String): String;
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


  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Queue, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(QueueDir);
  paramcb[i] := 0;

  i := i + 1;


	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Queue, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsHTMLMailerS.ResetHeaders();

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



  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_ResetHeaders, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_ResetHeaders, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsHTMLMailerS.Send();

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



  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Send, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_HTMLMailerS_Do = nil then exit;
  err := _HTMLMailerS_Do(m_ctl, MID_HTMLMailerS_Send, 0, @param, @paramcb); 
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

	_HTMLMailerS_Create := nil;
	_HTMLMailerS_Destroy := nil;
	_HTMLMailerS_Set := nil;
	_HTMLMailerS_Get := nil;
	_HTMLMailerS_GetLastError := nil;
	_HTMLMailerS_StaticInit := nil;
	_HTMLMailerS_CheckIndex := nil;
	_HTMLMailerS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_htmlmailers_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_HTMLMailerS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'HTMLMailerS_Create');
		@_HTMLMailerS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'HTMLMailerS_Destroy');
		@_HTMLMailerS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'HTMLMailerS_Set');
		@_HTMLMailerS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'HTMLMailerS_Get');
		@_HTMLMailerS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'HTMLMailerS_GetLastError');
		@_HTMLMailerS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'HTMLMailerS_CheckIndex');
		@_HTMLMailerS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'HTMLMailerS_Do');
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
  @_HTMLMailerS_Create       := nil;
  @_HTMLMailerS_Destroy      := nil;
  @_HTMLMailerS_Set          := nil;
  @_HTMLMailerS_Get          := nil;
  @_HTMLMailerS_GetLastError := nil;
  @_HTMLMailerS_CheckIndex   := nil;
  @_HTMLMailerS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




