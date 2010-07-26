
unit ipsimaps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipsimapsAuthMechanisms = 
(

									 
                   amUserPassword,

									 
                   amCRAMMD5
);
  TipsimapsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipsimapsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipsimapsSSLStartModes = 
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

  TMailboxACLEvent = procedure(Sender: TObject;
                            const Mailbox: String;
                            const User: String;
                            const Rights: String) of Object;

  TMailboxListEvent = procedure(Sender: TObject;
                            const Mailbox: String;
                            const Separator: String;
                            const Flags: String) of Object;

  TMessageInfoEvent = procedure(Sender: TObject;
                            const MessageId: String;
                            const Subject: String;
                            const MessageDate: String;
                            const From: String;
                            const Flags: String;
                            Size: Integer) of Object;

  TMessagePartEvent = procedure(Sender: TObject;
                            const PartId: String;
                            Size: Integer;
                            const ContentType: String;
                            const Filename: String;
                            const ContentEncoding: String;
                            const Parameters: String;
                            const MultipartMode: String) of Object;

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
                            const Text: String) of Object;


{$IFDEF CLR}
  TIMAPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsIMAPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsIMAPS = class(TipsCore)
    public
      FOnConnectionStatus: TConnectionStatusEvent;

      FOnEndTransfer: TEndTransferEvent;

      FOnError: TErrorEvent;

      FOnMailboxACL: TMailboxACLEvent;

      FOnMailboxList: TMailboxListEvent;

      FOnMessageInfo: TMessageInfoEvent;

      FOnMessagePart: TMessagePartEvent;

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
      m_anchor: TIMAPSEventHook;
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

      function get_EndByte: Integer;
      procedure set_EndByte(valEndByte: Integer);

      function get_MailboxFlags: String;


      function get_MailPort: Integer;
      procedure set_MailPort(valMailPort: Integer);

      function get_MessageBCc(AddressIndex: Word): String;


      function get_MessageCc(AddressIndex: Word): String;


      function get_MessageContentEncoding: String;


      function get_MessageContentType: String;


      function get_MessageDate: String;


      function get_MessageDeliveryTime: String;


      function get_MessageFlags: String;
      procedure set_MessageFlags(valMessageFlags: String);

      function get_MessageFrom: String;


      function get_MessageHeaders: String;
      procedure set_MessageHeaders(valMessageHeaders: String);

      function get_MessageId: String;


      function get_MessageInReplyTo: String;


      function get_MessageNetId: String;


      function get_MessageReplyTo: String;


      function get_MessageSender: String;


      function get_MessageSize: Integer;


      function get_MessageSubject: String;


      function get_MessageText: String;
      procedure set_MessageText(valMessageText: String);

      function get_MessageTo(AddressIndex: Word): String;


      function get_PartId: String;
      procedure set_PartId(valPartId: String);

      function get_PeekMode: Boolean;
      procedure set_PeekMode(valPeekMode: Boolean);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);

      function get_StartByte: Integer;
      procedure set_StartByte(valStartByte: Integer);

      function get_UIDMode: Boolean;
      procedure set_UIDMode(valUIDMode: Boolean);


      procedure TreatErr(Err: integer; const desc: string);


      function get_AuthMechanism: TipsimapsAuthMechanisms;
      procedure set_AuthMechanism(valAuthMechanism: TipsimapsAuthMechanisms);







      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipsimapsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipsimapsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_Idle: Boolean;


      function get_LastReply: String;


      function get_LocalFile: String;
      procedure set_LocalFile(valLocalFile: String);

      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);

      function get_Mailbox: String;
      procedure set_Mailbox(valMailbox: String);





      function get_MailServer: String;
      procedure set_MailServer(valMailServer: String);









      function get_MessageCount: Integer;






















      function get_MessageSet: String;
      procedure set_MessageSet(valMessageSet: String);











      function get_Password: String;
      procedure set_Password(valPassword: String);



      function get_RecentMessageCount: Integer;


      function get_SearchCriteria: String;
      procedure set_SearchCriteria(valSearchCriteria: String);

      function get_SortCriteria: String;
      procedure set_SortCriteria(valSortCriteria: String);

      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipsimapsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipsimapsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipsimapsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipsimapsSSLStartModes);



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

{$ENDIF}



      property Command: String

               write set_Command               ;

      property Connected: Boolean
               read get_Connected
               write set_Connected               ;

      property EndByte: Integer
               read get_EndByte
               write set_EndByte               ;





















      property MailboxFlags: String
               read get_MailboxFlags
               ;

      property MailPort: Integer
               read get_MailPort
               write set_MailPort               ;



      property MessageBCc[AddressIndex: Word]: String
               read get_MessageBCc
               ;

      property MessageCc[AddressIndex: Word]: String
               read get_MessageCc
               ;

      property MessageContentEncoding: String
               read get_MessageContentEncoding
               ;

      property MessageContentType: String
               read get_MessageContentType
               ;



      property MessageDate: String
               read get_MessageDate
               ;

      property MessageDeliveryTime: String
               read get_MessageDeliveryTime
               ;

      property MessageFlags: String
               read get_MessageFlags
               write set_MessageFlags               ;

      property MessageFrom: String
               read get_MessageFrom
               ;

      property MessageHeaders: String
               read get_MessageHeaders
               write set_MessageHeaders               ;

      property MessageId: String
               read get_MessageId
               ;

      property MessageInReplyTo: String
               read get_MessageInReplyTo
               ;

      property MessageNetId: String
               read get_MessageNetId
               ;

      property MessageReplyTo: String
               read get_MessageReplyTo
               ;

      property MessageSender: String
               read get_MessageSender
               ;



      property MessageSize: Integer
               read get_MessageSize
               ;

      property MessageSubject: String
               read get_MessageSubject
               ;

      property MessageText: String
               read get_MessageText
               write set_MessageText               ;

      property MessageTo[AddressIndex: Word]: String
               read get_MessageTo
               ;

      property PartId: String
               read get_PartId
               write set_PartId               ;



      property PeekMode: Boolean
               read get_PeekMode
               write set_PeekMode               ;









      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;















      property StartByte: Integer
               read get_StartByte
               write set_StartByte               ;



      property UIDMode: Boolean
               read get_UIDMode
               write set_UIDMode               ;





{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure AddMessageFlags(Flags: String);

      procedure AppendToMailbox();

      procedure CheckMailbox();

      procedure CloseMailbox();

      procedure Connect();

      procedure CopyToMailbox();

      procedure CreateMailbox();

      procedure DeleteFromMailbox();

      procedure DeleteMailbox();

      procedure DeleteMailboxACL(User: String);

      procedure Disconnect();

      procedure DoEvents();

      procedure ExamineMailbox();

      procedure ExpungeMailbox();

      procedure FetchMessageHeaders();

      procedure FetchMessageInfo();

      procedure FetchMessagePart();

      procedure FetchMessageText();

      procedure GetMailboxACL();

      procedure Interrupt();

      procedure ListMailboxes();

      procedure ListSubscribedMailboxes();

      function LocalizeDate(DateTime: String): String;
      procedure MoveToMailbox();

      procedure Noop();

      procedure RenameMailbox(NewName: String);

      procedure ResetMessageFlags();

      procedure SearchMailbox();

      procedure SelectMailbox();

      procedure SetMailboxACL(User: String; Rights: String);

      procedure SubscribeMailbox();

      procedure UnsetMessageFlags();

      procedure UnsubscribeMailbox();


{$ENDIF}

    published

      property AuthMechanism: TipsimapsAuthMechanisms
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
      property FirewallType: TipsimapsFirewallTypes
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
      property Mailbox: String
                   read get_Mailbox
                   write set_Mailbox
                   
                   ;


      property MailServer: String
                   read get_MailServer
                   write set_MailServer
                   
                   ;




      property MessageCount: Integer
                   read get_MessageCount
                    write SetNoopInteger
                   stored False

                   ;










      property MessageSet: String
                   read get_MessageSet
                   write set_MessageSet
                   
                   ;





      property Password: String
                   read get_Password
                   write set_Password
                   
                   ;

      property RecentMessageCount: Integer
                   read get_RecentMessageCount
                    write SetNoopInteger
                   stored False

                   ;
      property SearchCriteria: String
                   read get_SearchCriteria
                   write set_SearchCriteria
                   
                   ;
      property SortCriteria: String
                   read get_SortCriteria
                   write set_SortCriteria
                   
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
      property SSLCertStoreType: TipsimapsSSLCertStoreTypes
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
      property SSLStartMode: TipsimapsSSLStartModes
                   read get_SSLStartMode
                   write set_SSLStartMode
                   default sslAutomatic
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


      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnEndTransfer: TEndTransferEvent read FOnEndTransfer write FOnEndTransfer;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnMailboxACL: TMailboxACLEvent read FOnMailboxACL write FOnMailboxACL;

      property OnMailboxList: TMailboxListEvent read FOnMailboxList write FOnMailboxList;

      property OnMessageInfo: TMessageInfoEvent read FOnMessageInfo write FOnMessageInfo;

      property OnMessagePart: TMessagePartEvent read FOnMessagePart write FOnMessagePart;

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
    PID_IMAPS_AuthMechanism = 1;
    PID_IMAPS_Command = 2;
    PID_IMAPS_Connected = 3;
    PID_IMAPS_EndByte = 4;
    PID_IMAPS_FirewallHost = 5;
    PID_IMAPS_FirewallPassword = 6;
    PID_IMAPS_FirewallPort = 7;
    PID_IMAPS_FirewallType = 8;
    PID_IMAPS_FirewallUser = 9;
    PID_IMAPS_Idle = 10;
    PID_IMAPS_LastReply = 11;
    PID_IMAPS_LocalFile = 12;
    PID_IMAPS_LocalHost = 13;
    PID_IMAPS_Mailbox = 14;
    PID_IMAPS_MailboxFlags = 15;
    PID_IMAPS_MailPort = 16;
    PID_IMAPS_MailServer = 17;
    PID_IMAPS_MessageBCc = 18;
    PID_IMAPS_MessageCc = 19;
    PID_IMAPS_MessageContentEncoding = 20;
    PID_IMAPS_MessageContentType = 21;
    PID_IMAPS_MessageCount = 22;
    PID_IMAPS_MessageDate = 23;
    PID_IMAPS_MessageDeliveryTime = 24;
    PID_IMAPS_MessageFlags = 25;
    PID_IMAPS_MessageFrom = 26;
    PID_IMAPS_MessageHeaders = 27;
    PID_IMAPS_MessageId = 28;
    PID_IMAPS_MessageInReplyTo = 29;
    PID_IMAPS_MessageNetId = 30;
    PID_IMAPS_MessageReplyTo = 31;
    PID_IMAPS_MessageSender = 32;
    PID_IMAPS_MessageSet = 33;
    PID_IMAPS_MessageSize = 34;
    PID_IMAPS_MessageSubject = 35;
    PID_IMAPS_MessageText = 36;
    PID_IMAPS_MessageTo = 37;
    PID_IMAPS_PartId = 38;
    PID_IMAPS_Password = 39;
    PID_IMAPS_PeekMode = 40;
    PID_IMAPS_RecentMessageCount = 41;
    PID_IMAPS_SearchCriteria = 42;
    PID_IMAPS_SortCriteria = 43;
    PID_IMAPS_SSLAcceptServerCert = 44;
    PID_IMAPS_SSLCertEncoded = 45;
    PID_IMAPS_SSLCertStore = 46;
    PID_IMAPS_SSLCertStorePassword = 47;
    PID_IMAPS_SSLCertStoreType = 48;
    PID_IMAPS_SSLCertSubject = 49;
    PID_IMAPS_SSLServerCert = 50;
    PID_IMAPS_SSLServerCertStatus = 51;
    PID_IMAPS_SSLStartMode = 52;
    PID_IMAPS_StartByte = 53;
    PID_IMAPS_Timeout = 54;
    PID_IMAPS_UIDMode = 55;
    PID_IMAPS_User = 56;

    EID_IMAPS_ConnectionStatus = 1;
    EID_IMAPS_EndTransfer = 2;
    EID_IMAPS_Error = 3;
    EID_IMAPS_MailboxACL = 4;
    EID_IMAPS_MailboxList = 5;
    EID_IMAPS_MessageInfo = 6;
    EID_IMAPS_MessagePart = 7;
    EID_IMAPS_PITrail = 8;
    EID_IMAPS_SSLServerAuthentication = 9;
    EID_IMAPS_SSLStatus = 10;
    EID_IMAPS_StartTransfer = 11;
    EID_IMAPS_Transfer = 12;


    MID_IMAPS_Config = 1;
    MID_IMAPS_AddMessageFlags = 2;
    MID_IMAPS_AppendToMailbox = 3;
    MID_IMAPS_CheckMailbox = 4;
    MID_IMAPS_CloseMailbox = 5;
    MID_IMAPS_Connect = 6;
    MID_IMAPS_CopyToMailbox = 7;
    MID_IMAPS_CreateMailbox = 8;
    MID_IMAPS_DeleteFromMailbox = 9;
    MID_IMAPS_DeleteMailbox = 10;
    MID_IMAPS_DeleteMailboxACL = 11;
    MID_IMAPS_Disconnect = 12;
    MID_IMAPS_DoEvents = 13;
    MID_IMAPS_ExamineMailbox = 14;
    MID_IMAPS_ExpungeMailbox = 15;
    MID_IMAPS_FetchMessageHeaders = 16;
    MID_IMAPS_FetchMessageInfo = 17;
    MID_IMAPS_FetchMessagePart = 18;
    MID_IMAPS_FetchMessageText = 19;
    MID_IMAPS_GetMailboxACL = 20;
    MID_IMAPS_Interrupt = 21;
    MID_IMAPS_ListMailboxes = 22;
    MID_IMAPS_ListSubscribedMailboxes = 23;
    MID_IMAPS_LocalizeDate = 24;
    MID_IMAPS_MoveToMailbox = 25;
    MID_IMAPS_Noop = 26;
    MID_IMAPS_RenameMailbox = 27;
    MID_IMAPS_ResetMessageFlags = 28;
    MID_IMAPS_SearchMailbox = 29;
    MID_IMAPS_SelectMailbox = 30;
    MID_IMAPS_SetMailboxACL = 31;
    MID_IMAPS_SubscribeMailbox = 32;
    MID_IMAPS_UnsetMessageFlags = 33;
    MID_IMAPS_UnsubscribeMailbox = 34;




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
{$R 'ipsimaps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsIMAPS; event_id: Integer; cparam: Integer; 
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
  _IMAPS_Create:        function(pMethod: PEventHandle; pObject: TipsIMAPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IMAPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IMAPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IMAPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IMAPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IMAPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IMAPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IMAPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Create')]
  function _IMAPS_Create       (pMethod: TIMAPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Destroy')]
  function _IMAPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Set')]
  function _IMAPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Set')]
  function _IMAPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Set')]
  function _IMAPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Set')]
  function _IMAPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Set')]
  function _IMAPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Set')]
  function _IMAPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Get')]
  function _IMAPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Get')]
  function _IMAPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Get')]
  function _IMAPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Get')]
  function _IMAPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Get')]
  function _IMAPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Get')]
  function _IMAPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_GetLastError')]
  function _IMAPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_StaticInit')]
  function _IMAPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_CheckIndex')]
  function _IMAPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IMAPS_Do')]
  function _IMAPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _IMAPS_Create       (pMethod: PEventHandle; pObject: TipsIMAPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IMAPS_Create';
  function _IMAPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IMAPS_Destroy';
  function _IMAPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IMAPS_Set';
  function _IMAPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IMAPS_Get';
  function _IMAPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IMAPS_GetLastError';
  function _IMAPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IMAPS_StaticInit';
  function _IMAPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IMAPS_CheckIndex';
  function _IMAPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IMAPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsIMAPS; event_id: Integer;
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
    tmp_MailboxACLMailbox: String;
    tmp_MailboxACLUser: String;
    tmp_MailboxACLRights: String;
    tmp_MailboxListMailbox: String;
    tmp_MailboxListSeparator: String;
    tmp_MailboxListFlags: String;
    tmp_MessageInfoMessageId: String;
    tmp_MessageInfoSubject: String;
    tmp_MessageInfoMessageDate: String;
    tmp_MessageInfoFrom: String;
    tmp_MessageInfoFlags: String;
    tmp_MessageInfoSize: Integer;
    tmp_MessagePartPartId: String;
    tmp_MessagePartSize: Integer;
    tmp_MessagePartContentType: String;
    tmp_MessagePartFilename: String;
    tmp_MessagePartContentEncoding: String;
    tmp_MessagePartParameters: String;
    tmp_MessagePartMultipartMode: String;
    tmp_PITrailDirection: Integer;
    tmp_PITrailMessage: String;
    tmp_SSLServerAuthenticationCertEncoded: String;
    tmp_SSLServerAuthenticationCertSubject: String;
    tmp_SSLServerAuthenticationCertIssuer: String;
    tmp_SSLServerAuthenticationStatus: String;
    tmp_SSLStatusMessage: String;
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

      EID_IMAPS_ConnectionStatus:
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
      EID_IMAPS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_IMAPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_IMAPS_MailboxACL:
      begin
        if Assigned(lpContext.FOnMailboxACL) then
        begin
          {assign temporary variables}
          tmp_MailboxACLMailbox := AnsiString(PChar(params^[0]));

          tmp_MailboxACLUser := AnsiString(PChar(params^[1]));

          tmp_MailboxACLRights := AnsiString(PChar(params^[2]));


          lpContext.FOnMailboxACL(lpContext, tmp_MailboxACLMailbox, tmp_MailboxACLUser, tmp_MailboxACLRights);




        end;
      end;
      EID_IMAPS_MailboxList:
      begin
        if Assigned(lpContext.FOnMailboxList) then
        begin
          {assign temporary variables}
          tmp_MailboxListMailbox := AnsiString(PChar(params^[0]));

          tmp_MailboxListSeparator := AnsiString(PChar(params^[1]));

          tmp_MailboxListFlags := AnsiString(PChar(params^[2]));


          lpContext.FOnMailboxList(lpContext, tmp_MailboxListMailbox, tmp_MailboxListSeparator, tmp_MailboxListFlags);




        end;
      end;
      EID_IMAPS_MessageInfo:
      begin
        if Assigned(lpContext.FOnMessageInfo) then
        begin
          {assign temporary variables}
          tmp_MessageInfoMessageId := AnsiString(PChar(params^[0]));

          tmp_MessageInfoSubject := AnsiString(PChar(params^[1]));

          tmp_MessageInfoMessageDate := AnsiString(PChar(params^[2]));

          tmp_MessageInfoFrom := AnsiString(PChar(params^[3]));

          tmp_MessageInfoFlags := AnsiString(PChar(params^[4]));

          tmp_MessageInfoSize := Integer(params^[5]);

          lpContext.FOnMessageInfo(lpContext, tmp_MessageInfoMessageId, tmp_MessageInfoSubject, tmp_MessageInfoMessageDate, tmp_MessageInfoFrom, tmp_MessageInfoFlags, tmp_MessageInfoSize);







        end;
      end;
      EID_IMAPS_MessagePart:
      begin
        if Assigned(lpContext.FOnMessagePart) then
        begin
          {assign temporary variables}
          tmp_MessagePartPartId := AnsiString(PChar(params^[0]));

          tmp_MessagePartSize := Integer(params^[1]);
          tmp_MessagePartContentType := AnsiString(PChar(params^[2]));

          tmp_MessagePartFilename := AnsiString(PChar(params^[3]));

          tmp_MessagePartContentEncoding := AnsiString(PChar(params^[4]));

          tmp_MessagePartParameters := AnsiString(PChar(params^[5]));

          tmp_MessagePartMultipartMode := AnsiString(PChar(params^[6]));


          lpContext.FOnMessagePart(lpContext, tmp_MessagePartPartId, tmp_MessagePartSize, tmp_MessagePartContentType, tmp_MessagePartFilename, tmp_MessagePartContentEncoding, tmp_MessagePartParameters, tmp_MessagePartMultipartMode);








        end;
      end;
      EID_IMAPS_PITrail:
      begin
        if Assigned(lpContext.FOnPITrail) then
        begin
          {assign temporary variables}
          tmp_PITrailDirection := Integer(params^[0]);
          tmp_PITrailMessage := AnsiString(PChar(params^[1]));


          lpContext.FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailMessage);



        end;
      end;
      EID_IMAPS_SSLServerAuthentication:
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
      EID_IMAPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_IMAPS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_IMAPS_Transfer:
      begin
        if Assigned(lpContext.FOnTransfer) then
        begin
          {assign temporary variables}
          tmp_TransferBytesTransferred := LongInt(params^[0]);
          tmp_TransferText := AnsiString(PChar(params^[1]));


          lpContext.FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText);



        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsIMAPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;


  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_MailboxACLMailbox: String;
  tmp_MailboxACLUser: String;
  tmp_MailboxACLRights: String;

  tmp_MailboxListMailbox: String;
  tmp_MailboxListSeparator: String;
  tmp_MailboxListFlags: String;

  tmp_MessageInfoMessageId: String;
  tmp_MessageInfoSubject: String;
  tmp_MessageInfoMessageDate: String;
  tmp_MessageInfoFrom: String;
  tmp_MessageInfoFlags: String;
  tmp_MessageInfoSize: Integer;

  tmp_MessagePartPartId: String;
  tmp_MessagePartSize: Integer;
  tmp_MessagePartContentType: String;
  tmp_MessagePartFilename: String;
  tmp_MessagePartContentEncoding: String;
  tmp_MessagePartParameters: String;
  tmp_MessagePartMultipartMode: String;

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


begin
 	p := nil;
  case event_id of
    EID_IMAPS_ConnectionStatus:
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
    EID_IMAPS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_IMAPS_Error:
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
    EID_IMAPS_MailboxACL:
    begin
      if Assigned(FOnMailboxACL) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_MailboxACLMailbox := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_MailboxACLUser := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_MailboxACLRights := Marshal.PtrToStringAnsi(p);


        FOnMailboxACL(lpContext, tmp_MailboxACLMailbox, tmp_MailboxACLUser, tmp_MailboxACLRights);




      end;


    end;
    EID_IMAPS_MailboxList:
    begin
      if Assigned(FOnMailboxList) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_MailboxListMailbox := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_MailboxListSeparator := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_MailboxListFlags := Marshal.PtrToStringAnsi(p);


        FOnMailboxList(lpContext, tmp_MailboxListMailbox, tmp_MailboxListSeparator, tmp_MailboxListFlags);




      end;


    end;
    EID_IMAPS_MessageInfo:
    begin
      if Assigned(FOnMessageInfo) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_MessageInfoMessageId := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_MessageInfoSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_MessageInfoMessageDate := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_MessageInfoFrom := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_MessageInfoFlags := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        tmp_MessageInfoSize := Marshal.ReadInt32(params, 4*5);

        FOnMessageInfo(lpContext, tmp_MessageInfoMessageId, tmp_MessageInfoSubject, tmp_MessageInfoMessageDate, tmp_MessageInfoFrom, tmp_MessageInfoFlags, tmp_MessageInfoSize);







      end;


    end;
    EID_IMAPS_MessagePart:
    begin
      if Assigned(FOnMessagePart) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_MessagePartPartId := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_MessagePartSize := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_MessagePartContentType := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_MessagePartFilename := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_MessagePartContentEncoding := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        tmp_MessagePartParameters := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 6);
        tmp_MessagePartMultipartMode := Marshal.PtrToStringAnsi(p);


        FOnMessagePart(lpContext, tmp_MessagePartPartId, tmp_MessagePartSize, tmp_MessagePartContentType, tmp_MessagePartFilename, tmp_MessagePartContentEncoding, tmp_MessagePartParameters, tmp_MessagePartMultipartMode);








      end;


    end;
    EID_IMAPS_PITrail:
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
    EID_IMAPS_SSLServerAuthentication:
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
    EID_IMAPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_IMAPS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_IMAPS_Transfer:
    begin
      if Assigned(FOnTransfer) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_TransferBytesTransferred := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_TransferText := Marshal.PtrToStringAnsi(p);


        FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText);



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
    RegisterComponents('IP*Works! SSL', [TipsIMAPS]);
end;

constructor TipsIMAPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _IMAPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_IMAPS_Create <> nil then
      m_ctl := _IMAPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL IMAPS: Error creating component');

{$IFDEF CLR}
    _IMAPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_31, 0);
{$ELSE}
    _IMAPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_31)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_IMAPS_Do <> nil then
      _IMAPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_AuthMechanism(amUserPassword) except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_LocalFile('') except on E:Exception do end;
    try set_Mailbox('Inbox') except on E:Exception do end;
    try set_MailServer('') except on E:Exception do end;
    try set_MessageSet('') except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_SearchCriteria('') except on E:Exception do end;
    try set_SortCriteria('') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsIMAPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_IMAPS_Destroy <> nil then{$ENDIF}
      	_IMAPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsIMAPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsIMAPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsIMAPS.AboutDlg;
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
	if @_IMAPS_Do <> nil then
{$ENDIF}
		_IMAPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsIMAPS.SetOK(key: String128);
begin
end;

function TipsIMAPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsIMAPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsIMAPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsIMAPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsIMAPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsIMAPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_IMAPS_GetLastError <> nil then{$ENDIF}
      msg := _IMAPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsIMAPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_IMAPS_Do <> nil then
      _IMAPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsIMAPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_IMAPS_Set = nil then exit;{$ENDIF}
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsIMAPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_IMAPS_Set = nil then exit;{$ENDIF}
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsIMAPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_IMAPS_Set = nil then exit;{$ENDIF}
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsIMAPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_IMAPS_Set = nil then exit;{$ENDIF}
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsIMAPS.get_AuthMechanism: TipsimapsAuthMechanisms;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsimapsAuthMechanisms(_IMAPS_GetENUM(m_ctl, PID_IMAPS_AuthMechanism, 0, err));
{$ELSE}
  result := TipsimapsAuthMechanisms(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_AuthMechanism, 0, nil);
  result := TipsimapsAuthMechanisms(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_AuthMechanism(valAuthMechanism: TipsimapsAuthMechanisms);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetENUM(m_ctl, PID_IMAPS_AuthMechanism, 0, Integer(valAuthMechanism), 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_AuthMechanism, 0, Integer(valAuthMechanism), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsIMAPS.set_Command(valCommand: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_Command, 0, valCommand, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_Command, 0, Integer(PChar(valCommand)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IMAPS_GetBOOL(m_ctl, PID_IMAPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetBOOL(m_ctl, PID_IMAPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_EndByte: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IMAPS_GetLONG(m_ctl, PID_IMAPS_EndByte, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_EndByte, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_EndByte(valEndByte: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetLONG(m_ctl, PID_IMAPS_EndByte, 0, valEndByte, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_EndByte, 0, Integer(valEndByte), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IMAPS_GetLONG(m_ctl, PID_IMAPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetLONG(m_ctl, PID_IMAPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_FirewallType: TipsimapsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsimapsFirewallTypes(_IMAPS_GetENUM(m_ctl, PID_IMAPS_FirewallType, 0, err));
{$ELSE}
  result := TipsimapsFirewallTypes(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_FirewallType, 0, nil);
  result := TipsimapsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_FirewallType(valFirewallType: TipsimapsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetENUM(m_ctl, PID_IMAPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IMAPS_GetBOOL(m_ctl, PID_IMAPS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsIMAPS.get_LastReply: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_LastReply, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_LastReply, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_LocalFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_LocalFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_LocalFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_LocalFile(valLocalFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_LocalFile, 0, valLocalFile, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_LocalFile, 0, Integer(PChar(valLocalFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_Mailbox: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_Mailbox, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_Mailbox, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_Mailbox(valMailbox: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_Mailbox, 0, valMailbox, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_Mailbox, 0, Integer(PChar(valMailbox)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_MailboxFlags: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MailboxFlags, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MailboxFlags, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MailPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IMAPS_GetLONG(m_ctl, PID_IMAPS_MailPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MailPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_MailPort(valMailPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetLONG(m_ctl, PID_IMAPS_MailPort, 0, valMailPort, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_MailPort, 0, Integer(valMailPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_MailServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MailServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MailServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_MailServer(valMailServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_MailServer, 0, valMailServer, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_MailServer, 0, Integer(PChar(valMailServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_MessageBCc(AddressIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageBCc, AddressIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_IMAPS_CheckIndex = nil then exit;
  err :=  _IMAPS_CheckIndex(m_ctl, PID_IMAPS_MessageBCc, AddressIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for MessageBCc');
	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageBCc, AddressIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageCc(AddressIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageCc, AddressIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_IMAPS_CheckIndex = nil then exit;
  err :=  _IMAPS_CheckIndex(m_ctl, PID_IMAPS_MessageCc, AddressIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for MessageCc');
	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageCc, AddressIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageContentEncoding: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageContentEncoding, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageContentEncoding, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageContentType: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageContentType, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageContentType, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IMAPS_GetLONG(m_ctl, PID_IMAPS_MessageCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsIMAPS.get_MessageDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageDeliveryTime: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageDeliveryTime, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageDeliveryTime, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageFlags: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageFlags, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageFlags, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_MessageFlags(valMessageFlags: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_MessageFlags, 0, valMessageFlags, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_MessageFlags, 0, Integer(PChar(valMessageFlags)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_MessageFrom: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageFrom, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageFrom, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_MessageHeaders(valMessageHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_MessageHeaders, 0, valMessageHeaders, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_MessageHeaders, 0, Integer(PChar(valMessageHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_MessageId: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageId, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageId, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageInReplyTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageInReplyTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageInReplyTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageNetId: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageNetId, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageNetId, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageReplyTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageReplyTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageReplyTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageSender: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageSender, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageSender, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageSet: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageSet, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageSet, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_MessageSet(valMessageSet: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_MessageSet, 0, valMessageSet, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_MessageSet, 0, Integer(PChar(valMessageSet)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_MessageSize: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IMAPS_GetLONG(m_ctl, PID_IMAPS_MessageSize, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageSize, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsIMAPS.get_MessageSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_MessageText: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageText, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageText, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_MessageText(valMessageText: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_MessageText, 0, valMessageText, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_MessageText, 0, Integer(PChar(valMessageText)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_MessageTo(AddressIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_MessageTo, AddressIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_IMAPS_CheckIndex = nil then exit;
  err :=  _IMAPS_CheckIndex(m_ctl, PID_IMAPS_MessageTo, AddressIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for MessageTo');
	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_MessageTo, AddressIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_PartId: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_PartId, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_PartId, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_PartId(valPartId: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_PartId, 0, valPartId, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_PartId, 0, Integer(PChar(valPartId)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_PeekMode: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IMAPS_GetBOOL(m_ctl, PID_IMAPS_PeekMode, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_PeekMode, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_PeekMode(valPeekMode: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetBOOL(m_ctl, PID_IMAPS_PeekMode, 0, valPeekMode, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_PeekMode, 0, Integer(valPeekMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_RecentMessageCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IMAPS_GetLONG(m_ctl, PID_IMAPS_RecentMessageCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_RecentMessageCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsIMAPS.get_SearchCriteria: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_SearchCriteria, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SearchCriteria, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_SearchCriteria(valSearchCriteria: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_SearchCriteria, 0, valSearchCriteria, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SearchCriteria, 0, Integer(PChar(valSearchCriteria)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_SortCriteria: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_SortCriteria, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SortCriteria, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_SortCriteria(valSortCriteria: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_SortCriteria, 0, valSortCriteria, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SortCriteria, 0, Integer(PChar(valSortCriteria)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetBSTR(m_ctl, PID_IMAPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsIMAPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetBSTR(m_ctl, PID_IMAPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetBSTR(m_ctl, PID_IMAPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsIMAPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetBSTR(m_ctl, PID_IMAPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetBSTR(m_ctl, PID_IMAPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsIMAPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetBSTR(m_ctl, PID_IMAPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_SSLCertStoreType: TipsimapsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsimapsSSLCertStoreTypes(_IMAPS_GetENUM(m_ctl, PID_IMAPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipsimapsSSLCertStoreTypes(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLCertStoreType, 0, nil);
  result := TipsimapsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_SSLCertStoreType(valSSLCertStoreType: TipsimapsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetENUM(m_ctl, PID_IMAPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetBSTR(m_ctl, PID_IMAPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsIMAPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIMAPS.get_SSLStartMode: TipsimapsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsimapsSSLStartModes(_IMAPS_GetENUM(m_ctl, PID_IMAPS_SSLStartMode, 0, err));
{$ELSE}
  result := TipsimapsSSLStartModes(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_SSLStartMode, 0, nil);
  result := TipsimapsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_SSLStartMode(valSSLStartMode: TipsimapsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetENUM(m_ctl, PID_IMAPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_StartByte: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IMAPS_GetLONG(m_ctl, PID_IMAPS_StartByte, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_StartByte, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_StartByte(valStartByte: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetLONG(m_ctl, PID_IMAPS_StartByte, 0, valStartByte, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_StartByte, 0, Integer(valStartByte), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IMAPS_GetINT(m_ctl, PID_IMAPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetINT(m_ctl, PID_IMAPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_UIDMode: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IMAPS_GetBOOL(m_ctl, PID_IMAPS_UIDMode, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_UIDMode, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIMAPS.set_UIDMode(valUIDMode: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetBOOL(m_ctl, PID_IMAPS_UIDMode, 0, valUIDMode, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_UIDMode, 0, Integer(valUIDMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIMAPS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IMAPS_GetCSTR(m_ctl, PID_IMAPS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IMAPS_Get = nil then exit;
  tmp := _IMAPS_Get(m_ctl, PID_IMAPS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIMAPS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IMAPS_SetCSTR(m_ctl, PID_IMAPS_User, 0, valUser, 0);
{$ELSE}
	if @_IMAPS_Set = nil then exit;
  err := _IMAPS_Set(m_ctl, PID_IMAPS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsIMAPS.Config(ConfigurationString: String): String;
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


  err := _IMAPS_Do(m_ctl, MID_IMAPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsIMAPS.AddMessageFlags(Flags: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(Flags);
  paramcb[i] := 0;

  i := i + 1;


  err := _IMAPS_Do(m_ctl, MID_IMAPS_AddMessageFlags, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(Flags);
  paramcb[i] := 0;

  i := i + 1;


	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_AddMessageFlags, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.AppendToMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_AppendToMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_AppendToMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.CheckMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_CheckMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_CheckMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.CloseMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_CloseMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_CloseMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.Connect();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_Connect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_Connect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.CopyToMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_CopyToMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_CopyToMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.CreateMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_CreateMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_CreateMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.DeleteFromMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_DeleteFromMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_DeleteFromMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.DeleteMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_DeleteMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_DeleteMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.DeleteMailboxACL(User: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(User);
  paramcb[i] := 0;

  i := i + 1;


  err := _IMAPS_Do(m_ctl, MID_IMAPS_DeleteMailboxACL, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(User);
  paramcb[i] := 0;

  i := i + 1;


	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_DeleteMailboxACL, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.Disconnect();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_Disconnect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_Disconnect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.DoEvents();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.ExamineMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_ExamineMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_ExamineMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.ExpungeMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_ExpungeMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_ExpungeMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.FetchMessageHeaders();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_FetchMessageHeaders, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_FetchMessageHeaders, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.FetchMessageInfo();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_FetchMessageInfo, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_FetchMessageInfo, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.FetchMessagePart();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_FetchMessagePart, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_FetchMessagePart, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.FetchMessageText();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_FetchMessageText, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_FetchMessageText, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.GetMailboxACL();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_GetMailboxACL, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_GetMailboxACL, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.Interrupt();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.ListMailboxes();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_ListMailboxes, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_ListMailboxes, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.ListSubscribedMailboxes();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_ListSubscribedMailboxes, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_ListSubscribedMailboxes, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsIMAPS.LocalizeDate(DateTime: String): String;
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


  err := _IMAPS_Do(m_ctl, MID_IMAPS_LocalizeDate, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(DateTime);
  paramcb[i] := 0;

  i := i + 1;


	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_LocalizeDate, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsIMAPS.MoveToMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_MoveToMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_MoveToMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.Noop();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_Noop, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_Noop, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.RenameMailbox(NewName: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(NewName);
  paramcb[i] := 0;

  i := i + 1;


  err := _IMAPS_Do(m_ctl, MID_IMAPS_RenameMailbox, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(NewName);
  paramcb[i] := 0;

  i := i + 1;


	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_RenameMailbox, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.ResetMessageFlags();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_ResetMessageFlags, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_ResetMessageFlags, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.SearchMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_SearchMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_SearchMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.SelectMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_SelectMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_SelectMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.SetMailboxACL(User: String; Rights: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(User);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Rights);
  paramcb[i] := 0;

  i := i + 1;


  err := _IMAPS_Do(m_ctl, MID_IMAPS_SetMailboxACL, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(User);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Rights);
  paramcb[i] := 0;

  i := i + 1;


	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_SetMailboxACL, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.SubscribeMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_SubscribeMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_SubscribeMailbox, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.UnsetMessageFlags();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_UnsetMessageFlags, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_UnsetMessageFlags, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIMAPS.UnsubscribeMailbox();

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



  err := _IMAPS_Do(m_ctl, MID_IMAPS_UnsubscribeMailbox, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IMAPS_Do = nil then exit;
  err := _IMAPS_Do(m_ctl, MID_IMAPS_UnsubscribeMailbox, 0, @param, @paramcb); 
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

	_IMAPS_Create := nil;
	_IMAPS_Destroy := nil;
	_IMAPS_Set := nil;
	_IMAPS_Get := nil;
	_IMAPS_GetLastError := nil;
	_IMAPS_StaticInit := nil;
	_IMAPS_CheckIndex := nil;
	_IMAPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_imaps_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_IMAPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'IMAPS_Create');
		@_IMAPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'IMAPS_Destroy');
		@_IMAPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'IMAPS_Set');
		@_IMAPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'IMAPS_Get');
		@_IMAPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'IMAPS_GetLastError');
		@_IMAPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'IMAPS_CheckIndex');
		@_IMAPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'IMAPS_Do');
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
  @_IMAPS_Create       := nil;
  @_IMAPS_Destroy      := nil;
  @_IMAPS_Set          := nil;
  @_IMAPS_Get          := nil;
  @_IMAPS_GetLastError := nil;
  @_IMAPS_CheckIndex   := nil;
  @_IMAPS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




