
unit ipsxmpps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipsxmppsBuddySubscriptions = 
(

									 
                   stNone,

									 
                   stTo,

									 
                   stFrom,

									 
                   stBoth,

									 
                   stRemove
);
  TipsxmppsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipsxmppsMessageTypes = 
(

									 
                   mtNormal,

									 
                   mtChat,

									 
                   mtGroupChat,

									 
                   mtHeadline,

									 
                   mtError
);
  TipsxmppsPresences = 
(

									 
                   pcOffline,

									 
                   pcChat,

									 
                   pcAway,

									 
                   pcXA,

									 
                   pcDND
);
  TipsxmppsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipsxmppsSSLStartModes = 
(

									 
                   sslAutomatic,

									 
                   sslImplicit,

									 
                   sslExplicit,

									 
                   sslNone
);


  TBuddyUpdateEvent = procedure(Sender: TObject;
                            BuddyIdx: Integer) of Object;

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

  TIQEvent = procedure(Sender: TObject;
                            const Iq: String) of Object;

  TMessageInEvent = procedure(Sender: TObject;
                            const From: String;
                            const Domain: String;
                            const Resource: String;
                            const MessageText: String;
                            const MessageHTML: String) of Object;

  TPITrailEvent = procedure(Sender: TObject;
                            Direction: Integer;
                            const Pi: String) of Object;

  TPresenceEvent = procedure(Sender: TObject;
                            const User: String;
                            const Domain: String;
                            const Resource: String;
                            Availability: Integer;
                            const Status: String) of Object;

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

  TSubscriptionRequestEvent = procedure(Sender: TObject;
                            const From: String;
                            const Domain: String;
                           var  Accept: Boolean) of Object;

  TSyncEvent = procedure(Sender: TObject) of Object;


{$IFDEF CLR}
  TXMPPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsXMPPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsXMPPS = class(TipsCore)
    public
      FOnBuddyUpdate: TBuddyUpdateEvent;

      FOnConnected: TConnectedEvent;

      FOnConnectionStatus: TConnectionStatusEvent;

      FOnDisconnected: TDisconnectedEvent;

      FOnError: TErrorEvent;

      FOnIQ: TIQEvent;

      FOnMessageIn: TMessageInEvent;

      FOnPITrail: TPITrailEvent;

      FOnPresence: TPresenceEvent;

      FOnSSLServerAuthentication: TSSLServerAuthenticationEvent;
			{$IFDEF CLR}FOnSSLServerAuthenticationB: TSSLServerAuthenticationEventB;{$ENDIF}
      FOnSSLStatus: TSSLStatusEvent;

      FOnSubscriptionRequest: TSubscriptionRequestEvent;

      FOnSync: TSyncEvent;


    private
      tmp_SSLServerAuthenticationAccept: Boolean;
      tmp_SubscriptionRequestAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TXMPPSEventHook;
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

      function get_BuddyCount: Integer;


      function get_BuddyGroup(BuddyIndex: Word): String;
      procedure set_BuddyGroup(BuddyIndex: Word; valBuddyGroup: String);

      function get_BuddyId(BuddyIndex: Word): String;


      function get_BuddySubscription(BuddyIndex: Word): TipsxmppsBuddySubscriptions;


      function get_MessageHTML: String;
      procedure set_MessageHTML(valMessageHTML: String);

      function get_MessageSubject: String;
      procedure set_MessageSubject(valMessageSubject: String);

      function get_MessageText: String;
      procedure set_MessageText(valMessageText: String);

      function get_MessageThread: String;
      procedure set_MessageThread(valMessageThread: String);

      function get_MessageType: TipsxmppsMessageTypes;
      procedure set_MessageType(valMessageType: TipsxmppsMessageTypes);

      function get_Presence: TipsxmppsPresences;
      procedure set_Presence(valPresence: TipsxmppsPresences);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);

      function get_Status: String;
      procedure set_Status(valStatus: String);

      function get_UserInfoCount: Integer;
      procedure set_UserInfoCount(valUserInfoCount: Integer);

      function get_UserInfoFields(FieldIndex: Word): String;
      procedure set_UserInfoFields(FieldIndex: Word; valUserInfoFields: String);

      function get_UserInfoValues(FieldIndex: Word): String;
      procedure set_UserInfoValues(FieldIndex: Word; valUserInfoValues: String);


      procedure TreatErr(Err: integer; const desc: string);










      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);

      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipsxmppsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipsxmppsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_IMPort: Integer;
      procedure set_IMPort(valIMPort: Integer);

      function get_IMServer: String;
      procedure set_IMServer(valIMServer: String);











      function get_OtherData: String;
      procedure set_OtherData(valOtherData: String);

      function get_Password: String;
      procedure set_Password(valPassword: String);



      function get_Resource: String;
      procedure set_Resource(valResource: String);

      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipsxmppsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipsxmppsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipsxmppsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipsxmppsSSLStartModes);



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

      property BuddyCount: Integer
               read get_BuddyCount
               ;

      property BuddyGroup[BuddyIndex: Word]: String
               read get_BuddyGroup
               write set_BuddyGroup               ;

      property BuddyId[BuddyIndex: Word]: String
               read get_BuddyId
               ;

      property BuddySubscription[BuddyIndex: Word]: TipsxmppsBuddySubscriptions
               read get_BuddySubscription
               ;

















      property MessageHTML: String
               read get_MessageHTML
               write set_MessageHTML               ;

      property MessageSubject: String
               read get_MessageSubject
               write set_MessageSubject               ;

      property MessageText: String
               read get_MessageText
               write set_MessageText               ;

      property MessageThread: String
               read get_MessageThread
               write set_MessageThread               ;

      property MessageType: TipsxmppsMessageTypes
               read get_MessageType
               write set_MessageType               ;





      property Presence: TipsxmppsPresences
               read get_Presence
               write set_Presence               ;





      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;















      property Status: String
               read get_Status
               write set_Status               ;





      property UserInfoCount: Integer
               read get_UserInfoCount
               write set_UserInfoCount               ;

      property UserInfoFields[FieldIndex: Word]: String
               read get_UserInfoFields
               write set_UserInfoFields               ;

      property UserInfoValues[FieldIndex: Word]: String
               read get_UserInfoValues
               write set_UserInfoValues               ;



{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure Add(JabberId: String; Name: String; Groups: String);

      procedure Cancel(JabberId: String);

      procedure ChangePresence(PresenceCode: Integer; Status: String);

      procedure Connect(User: String; Password: String);

      procedure Disconnect();

      procedure DoEvents();

      procedure ProbePresence(JabberId: String);

      procedure QueryRegister(XMPPServer: String);

      procedure Register(XMPPServer: String);

      procedure Remove(JabberId: String; Name: String; Group: String);

      procedure RetrieveRoster();

      procedure SendCommand(Command: String);

      procedure SendMessage(JabberId: String);

      procedure SetUserInfoField(Field: String; Value: String);

      procedure SubscribeTo(JabberId: String);

      procedure Unregister();

      procedure UnsubscribeTo(JabberId: String);


{$ENDIF}

    published





      property Connected: Boolean
                   read get_Connected
                   write set_Connected
                   default False
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
      property FirewallType: TipsxmppsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property IMPort: Integer
                   read get_IMPort
                   write set_IMPort
                   default 5223
                   ;
      property IMServer: String
                   read get_IMServer
                   write set_IMServer
                   
                   ;





      property OtherData: String
                   read get_OtherData
                   write set_OtherData
                   
                   ;
      property Password: String
                   read get_Password
                   write set_Password
                   
                   ;

      property Resource: String
                   read get_Resource
                   write set_Resource
                   
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
      property SSLCertStoreType: TipsxmppsSSLCertStoreTypes
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
      property SSLStartMode: TipsxmppsSSLStartModes
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





      property OnBuddyUpdate: TBuddyUpdateEvent read FOnBuddyUpdate write FOnBuddyUpdate;

      property OnConnected: TConnectedEvent read FOnConnected write FOnConnected;

      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnDisconnected: TDisconnectedEvent read FOnDisconnected write FOnDisconnected;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnIQ: TIQEvent read FOnIQ write FOnIQ;

      property OnMessageIn: TMessageInEvent read FOnMessageIn write FOnMessageIn;

      property OnPITrail: TPITrailEvent read FOnPITrail write FOnPITrail;

      property OnPresence: TPresenceEvent read FOnPresence write FOnPresence;

      property OnSSLServerAuthentication: TSSLServerAuthenticationEvent read FOnSSLServerAuthentication write FOnSSLServerAuthentication;
			{$IFDEF CLR}property OnSSLServerAuthenticationB: TSSLServerAuthenticationEventB read FOnSSLServerAuthenticationB write FOnSSLServerAuthenticationB;{$ENDIF}
      property OnSSLStatus: TSSLStatusEvent read FOnSSLStatus write FOnSSLStatus;

      property OnSubscriptionRequest: TSubscriptionRequestEvent read FOnSubscriptionRequest write FOnSubscriptionRequest;

      property OnSync: TSyncEvent read FOnSync write FOnSync;


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
    PID_XMPPS_BuddyCount = 1;
    PID_XMPPS_BuddyGroup = 2;
    PID_XMPPS_BuddyId = 3;
    PID_XMPPS_BuddySubscription = 4;
    PID_XMPPS_Connected = 5;
    PID_XMPPS_FirewallHost = 6;
    PID_XMPPS_FirewallPassword = 7;
    PID_XMPPS_FirewallPort = 8;
    PID_XMPPS_FirewallType = 9;
    PID_XMPPS_FirewallUser = 10;
    PID_XMPPS_IMPort = 11;
    PID_XMPPS_IMServer = 12;
    PID_XMPPS_MessageHTML = 13;
    PID_XMPPS_MessageSubject = 14;
    PID_XMPPS_MessageText = 15;
    PID_XMPPS_MessageThread = 16;
    PID_XMPPS_MessageType = 17;
    PID_XMPPS_OtherData = 18;
    PID_XMPPS_Password = 19;
    PID_XMPPS_Presence = 20;
    PID_XMPPS_Resource = 21;
    PID_XMPPS_SSLAcceptServerCert = 22;
    PID_XMPPS_SSLCertEncoded = 23;
    PID_XMPPS_SSLCertStore = 24;
    PID_XMPPS_SSLCertStorePassword = 25;
    PID_XMPPS_SSLCertStoreType = 26;
    PID_XMPPS_SSLCertSubject = 27;
    PID_XMPPS_SSLServerCert = 28;
    PID_XMPPS_SSLServerCertStatus = 29;
    PID_XMPPS_SSLStartMode = 30;
    PID_XMPPS_Status = 31;
    PID_XMPPS_Timeout = 32;
    PID_XMPPS_User = 33;
    PID_XMPPS_UserInfoCount = 34;
    PID_XMPPS_UserInfoFields = 35;
    PID_XMPPS_UserInfoValues = 36;

    EID_XMPPS_BuddyUpdate = 1;
    EID_XMPPS_Connected = 2;
    EID_XMPPS_ConnectionStatus = 3;
    EID_XMPPS_Disconnected = 4;
    EID_XMPPS_Error = 5;
    EID_XMPPS_IQ = 6;
    EID_XMPPS_MessageIn = 7;
    EID_XMPPS_PITrail = 8;
    EID_XMPPS_Presence = 9;
    EID_XMPPS_SSLServerAuthentication = 10;
    EID_XMPPS_SSLStatus = 11;
    EID_XMPPS_SubscriptionRequest = 12;
    EID_XMPPS_Sync = 13;


    MID_XMPPS_Config = 1;
    MID_XMPPS_Add = 2;
    MID_XMPPS_Cancel = 3;
    MID_XMPPS_ChangePresence = 4;
    MID_XMPPS_Connect = 5;
    MID_XMPPS_Disconnect = 6;
    MID_XMPPS_DoEvents = 7;
    MID_XMPPS_ProbePresence = 8;
    MID_XMPPS_QueryRegister = 9;
    MID_XMPPS_Register = 10;
    MID_XMPPS_Remove = 11;
    MID_XMPPS_RetrieveRoster = 12;
    MID_XMPPS_SendCommand = 13;
    MID_XMPPS_SendMessage = 14;
    MID_XMPPS_SetUserInfoField = 15;
    MID_XMPPS_SubscribeTo = 16;
    MID_XMPPS_Unregister = 17;
    MID_XMPPS_UnsubscribeTo = 18;




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
{$R 'ipsxmpps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsXMPPS; event_id: Integer; cparam: Integer; 
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
  _XMPPS_Create:        function(pMethod: PEventHandle; pObject: TipsXMPPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _XMPPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _XMPPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _XMPPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _XMPPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _XMPPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _XMPPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _XMPPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Create')]
  function _XMPPS_Create       (pMethod: TXMPPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Destroy')]
  function _XMPPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Set')]
  function _XMPPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Set')]
  function _XMPPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Set')]
  function _XMPPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Set')]
  function _XMPPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Set')]
  function _XMPPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Set')]
  function _XMPPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Get')]
  function _XMPPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Get')]
  function _XMPPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Get')]
  function _XMPPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Get')]
  function _XMPPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Get')]
  function _XMPPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Get')]
  function _XMPPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_GetLastError')]
  function _XMPPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_StaticInit')]
  function _XMPPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_CheckIndex')]
  function _XMPPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'XMPPS_Do')]
  function _XMPPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _XMPPS_Create       (pMethod: PEventHandle; pObject: TipsXMPPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'XMPPS_Create';
  function _XMPPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'XMPPS_Destroy';
  function _XMPPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'XMPPS_Set';
  function _XMPPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'XMPPS_Get';
  function _XMPPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'XMPPS_GetLastError';
  function _XMPPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'XMPPS_StaticInit';
  function _XMPPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'XMPPS_CheckIndex';
  function _XMPPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'XMPPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsXMPPS; event_id: Integer;
                    cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): Integer;
                    {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  var
    x: Integer;
{$IFDEF LINUX}
    msg: String;
    tmp_IdleNextWait: Integer;
    tmp_NotifyObject: TipwSocketNotifier;
{$ENDIF}
    tmp_BuddyUpdateBuddyIdx: Integer;
    tmp_ConnectedStatusCode: Integer;
    tmp_ConnectedDescription: String;
    tmp_ConnectionStatusConnectionEvent: String;
    tmp_ConnectionStatusStatusCode: Integer;
    tmp_ConnectionStatusDescription: String;
    tmp_DisconnectedStatusCode: Integer;
    tmp_DisconnectedDescription: String;
    tmp_ErrorErrorCode: Integer;
    tmp_ErrorDescription: String;
    tmp_IQIq: String;
    tmp_MessageInFrom: String;
    tmp_MessageInDomain: String;
    tmp_MessageInResource: String;
    tmp_MessageInMessageText: String;
    tmp_MessageInMessageHTML: String;
    tmp_PITrailDirection: Integer;
    tmp_PITrailPi: String;
    tmp_PresenceUser: String;
    tmp_PresenceDomain: String;
    tmp_PresenceResource: String;
    tmp_PresenceAvailability: Integer;
    tmp_PresenceStatus: String;
    tmp_SSLServerAuthenticationCertEncoded: String;
    tmp_SSLServerAuthenticationCertSubject: String;
    tmp_SSLServerAuthenticationCertIssuer: String;
    tmp_SSLServerAuthenticationStatus: String;
    tmp_SSLStatusMessage: String;
    tmp_SubscriptionRequestFrom: String;
    tmp_SubscriptionRequestDomain: String;

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

      EID_XMPPS_BuddyUpdate:
      begin
        if Assigned(lpContext.FOnBuddyUpdate) then
        begin
          {assign temporary variables}
          tmp_BuddyUpdateBuddyIdx := Integer(params^[0]);

          lpContext.FOnBuddyUpdate(lpContext, tmp_BuddyUpdateBuddyIdx);


        end;
      end;
      EID_XMPPS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_XMPPS_ConnectionStatus:
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
      EID_XMPPS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_XMPPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_XMPPS_IQ:
      begin
        if Assigned(lpContext.FOnIQ) then
        begin
          {assign temporary variables}
          tmp_IQIq := AnsiString(PChar(params^[0]));


          lpContext.FOnIQ(lpContext, tmp_IQIq);


        end;
      end;
      EID_XMPPS_MessageIn:
      begin
        if Assigned(lpContext.FOnMessageIn) then
        begin
          {assign temporary variables}
          tmp_MessageInFrom := AnsiString(PChar(params^[0]));

          tmp_MessageInDomain := AnsiString(PChar(params^[1]));

          tmp_MessageInResource := AnsiString(PChar(params^[2]));

          tmp_MessageInMessageText := AnsiString(PChar(params^[3]));

          tmp_MessageInMessageHTML := AnsiString(PChar(params^[4]));


          lpContext.FOnMessageIn(lpContext, tmp_MessageInFrom, tmp_MessageInDomain, tmp_MessageInResource, tmp_MessageInMessageText, tmp_MessageInMessageHTML);






        end;
      end;
      EID_XMPPS_PITrail:
      begin
        if Assigned(lpContext.FOnPITrail) then
        begin
          {assign temporary variables}
          tmp_PITrailDirection := Integer(params^[0]);
          tmp_PITrailPi := AnsiString(PChar(params^[1]));


          lpContext.FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailPi);



        end;
      end;
      EID_XMPPS_Presence:
      begin
        if Assigned(lpContext.FOnPresence) then
        begin
          {assign temporary variables}
          tmp_PresenceUser := AnsiString(PChar(params^[0]));

          tmp_PresenceDomain := AnsiString(PChar(params^[1]));

          tmp_PresenceResource := AnsiString(PChar(params^[2]));

          tmp_PresenceAvailability := Integer(params^[3]);
          tmp_PresenceStatus := AnsiString(PChar(params^[4]));


          lpContext.FOnPresence(lpContext, tmp_PresenceUser, tmp_PresenceDomain, tmp_PresenceResource, tmp_PresenceAvailability, tmp_PresenceStatus);






        end;
      end;
      EID_XMPPS_SSLServerAuthentication:
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
      EID_XMPPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_XMPPS_SubscriptionRequest:
      begin
        if Assigned(lpContext.FOnSubscriptionRequest) then
        begin
          {assign temporary variables}
          tmp_SubscriptionRequestFrom := AnsiString(PChar(params^[0]));

          tmp_SubscriptionRequestDomain := AnsiString(PChar(params^[1]));

          lpContext.tmp_SubscriptionRequestAccept := Boolean(params^[2]);

          lpContext.FOnSubscriptionRequest(lpContext, tmp_SubscriptionRequestFrom, tmp_SubscriptionRequestDomain, lpContext.tmp_SubscriptionRequestAccept);


          params^[2] := Pointer(lpContext.tmp_SubscriptionRequestAccept);


        end;
      end;
      EID_XMPPS_Sync:
      begin
        if Assigned(lpContext.FOnSync) then
        begin
          {assign temporary variables}

          lpContext.FOnSync(lpContext);

        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsXMPPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_BuddyUpdateBuddyIdx: Integer;

  tmp_ConnectedStatusCode: Integer;
  tmp_ConnectedDescription: String;

  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;

  tmp_DisconnectedStatusCode: Integer;
  tmp_DisconnectedDescription: String;

  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_IQIq: String;

  tmp_MessageInFrom: String;
  tmp_MessageInDomain: String;
  tmp_MessageInResource: String;
  tmp_MessageInMessageText: String;
  tmp_MessageInMessageHTML: String;

  tmp_PITrailDirection: Integer;
  tmp_PITrailPi: String;

  tmp_PresenceUser: String;
  tmp_PresenceDomain: String;
  tmp_PresenceResource: String;
  tmp_PresenceAvailability: Integer;
  tmp_PresenceStatus: String;

  tmp_SSLServerAuthenticationCertEncoded: String;
  tmp_SSLServerAuthenticationCertSubject: String;
  tmp_SSLServerAuthenticationCertIssuer: String;
  tmp_SSLServerAuthenticationStatus: String;

  tmp_SSLServerAuthenticationCertEncodedB: Array of Byte;
  tmp_SSLStatusMessage: String;

  tmp_SubscriptionRequestFrom: String;
  tmp_SubscriptionRequestDomain: String;



begin
 	p := nil;
  case event_id of
    EID_XMPPS_BuddyUpdate:
    begin
      if Assigned(FOnBuddyUpdate) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_BuddyUpdateBuddyIdx := Marshal.ReadInt32(params, 4*0);

        FOnBuddyUpdate(lpContext, tmp_BuddyUpdateBuddyIdx);


      end;


    end;
    EID_XMPPS_Connected:
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
    EID_XMPPS_ConnectionStatus:
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
    EID_XMPPS_Disconnected:
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
    EID_XMPPS_Error:
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
    EID_XMPPS_IQ:
    begin
      if Assigned(FOnIQ) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_IQIq := Marshal.PtrToStringAnsi(p);


        FOnIQ(lpContext, tmp_IQIq);


      end;


    end;
    EID_XMPPS_MessageIn:
    begin
      if Assigned(FOnMessageIn) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_MessageInFrom := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_MessageInDomain := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_MessageInResource := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_MessageInMessageText := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_MessageInMessageHTML := Marshal.PtrToStringAnsi(p);


        FOnMessageIn(lpContext, tmp_MessageInFrom, tmp_MessageInDomain, tmp_MessageInResource, tmp_MessageInMessageText, tmp_MessageInMessageHTML);






      end;


    end;
    EID_XMPPS_PITrail:
    begin
      if Assigned(FOnPITrail) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_PITrailDirection := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_PITrailPi := Marshal.PtrToStringAnsi(p);


        FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailPi);



      end;


    end;
    EID_XMPPS_Presence:
    begin
      if Assigned(FOnPresence) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_PresenceUser := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_PresenceDomain := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_PresenceResource := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_PresenceAvailability := Marshal.ReadInt32(params, 4*3);
				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_PresenceStatus := Marshal.PtrToStringAnsi(p);


        FOnPresence(lpContext, tmp_PresenceUser, tmp_PresenceDomain, tmp_PresenceResource, tmp_PresenceAvailability, tmp_PresenceStatus);






      end;


    end;
    EID_XMPPS_SSLServerAuthentication:
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
    EID_XMPPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_XMPPS_SubscriptionRequest:
    begin
      if Assigned(FOnSubscriptionRequest) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SubscriptionRequestFrom := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SubscriptionRequestDomain := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        if Marshal.ReadInt32(params, 4*2) <> 0 then tmp_SubscriptionRequestAccept := true else tmp_SubscriptionRequestAccept := false;


        FOnSubscriptionRequest(lpContext, tmp_SubscriptionRequestFrom, tmp_SubscriptionRequestDomain, tmp_SubscriptionRequestAccept);


        if tmp_SubscriptionRequestAccept then Marshal.WriteInt32(params, 4*2, 1) else Marshal.WriteInt32(params, 4*2, 0);


      end;


    end;
    EID_XMPPS_Sync:
    begin
      if Assigned(FOnSync) then
      begin
        {assign temporary variables}

        FOnSync(lpContext);

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
    RegisterComponents('IP*Works! SSL', [TipsXMPPS]);
end;

constructor TipsXMPPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _XMPPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_XMPPS_Create <> nil then
      m_ctl := _XMPPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL XMPPS: Error creating component');

{$IFDEF CLR}
    _XMPPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_70, 0);
{$ELSE}
    _XMPPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_70)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_XMPPS_Do <> nil then
      _XMPPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_Connected(false) except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_IMPort(5223) except on E:Exception do end;
    try set_IMServer('') except on E:Exception do end;
    try set_OtherData('') except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_Resource('IP*Works! XMPP Agent') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsXMPPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_XMPPS_Destroy <> nil then{$ENDIF}
      	_XMPPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsXMPPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsXMPPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsXMPPS.AboutDlg;
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
	if @_XMPPS_Do <> nil then
{$ENDIF}
		_XMPPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsXMPPS.SetOK(key: String128);
begin
end;

function TipsXMPPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsXMPPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsXMPPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsXMPPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsXMPPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsXMPPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_XMPPS_GetLastError <> nil then{$ENDIF}
      msg := _XMPPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsXMPPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_XMPPS_Do <> nil then
      _XMPPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsXMPPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_XMPPS_Set = nil then exit;{$ENDIF}
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsXMPPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_XMPPS_Set = nil then exit;{$ENDIF}
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsXMPPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_XMPPS_Set = nil then exit;{$ENDIF}
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsXMPPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_XMPPS_Set = nil then exit;{$ENDIF}
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsXMPPS.get_BuddyCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_XMPPS_GetINT(m_ctl, PID_XMPPS_BuddyCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_BuddyCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsXMPPS.get_BuddyGroup(BuddyIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_BuddyGroup, BuddyIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_XMPPS_CheckIndex = nil then exit;
  err :=  _XMPPS_CheckIndex(m_ctl, PID_XMPPS_BuddyGroup, BuddyIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for BuddyGroup');
	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_BuddyGroup, BuddyIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_BuddyGroup(BuddyIndex: Word; valBuddyGroup: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_BuddyGroup, BuddyIndex, valBuddyGroup, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_BuddyGroup, BuddyIndex, Integer(PChar(valBuddyGroup)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_BuddyId(BuddyIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_BuddyId, BuddyIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_XMPPS_CheckIndex = nil then exit;
  err :=  _XMPPS_CheckIndex(m_ctl, PID_XMPPS_BuddyId, BuddyIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for BuddyId');
	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_BuddyId, BuddyIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsXMPPS.get_BuddySubscription(BuddyIndex: Word): TipsxmppsBuddySubscriptions;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsxmppsBuddySubscriptions(_XMPPS_GetENUM(m_ctl, PID_XMPPS_BuddySubscription, BuddyIndex, err));
{$ELSE}
  result := TipsxmppsBuddySubscriptions(0);
  if @_XMPPS_CheckIndex = nil then exit;
  err :=  _XMPPS_CheckIndex(m_ctl, PID_XMPPS_BuddySubscription, BuddyIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for BuddySubscription');
	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_BuddySubscription, BuddyIndex, nil);
  result := TipsxmppsBuddySubscriptions(tmp);
{$ENDIF}
end;


function TipsXMPPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_XMPPS_GetBOOL(m_ctl, PID_XMPPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetBOOL(m_ctl, PID_XMPPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_XMPPS_GetLONG(m_ctl, PID_XMPPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetLONG(m_ctl, PID_XMPPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_FirewallType: TipsxmppsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsxmppsFirewallTypes(_XMPPS_GetENUM(m_ctl, PID_XMPPS_FirewallType, 0, err));
{$ELSE}
  result := TipsxmppsFirewallTypes(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_FirewallType, 0, nil);
  result := TipsxmppsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_FirewallType(valFirewallType: TipsxmppsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetENUM(m_ctl, PID_XMPPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_IMPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_XMPPS_GetINT(m_ctl, PID_XMPPS_IMPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_IMPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_IMPort(valIMPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetINT(m_ctl, PID_XMPPS_IMPort, 0, valIMPort, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_IMPort, 0, Integer(valIMPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_IMServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_IMServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_IMServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_IMServer(valIMServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_IMServer, 0, valIMServer, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_IMServer, 0, Integer(PChar(valIMServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_MessageHTML: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_MessageHTML, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_MessageHTML, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_MessageHTML(valMessageHTML: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_MessageHTML, 0, valMessageHTML, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_MessageHTML, 0, Integer(PChar(valMessageHTML)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_MessageSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_MessageSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_MessageSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_MessageSubject(valMessageSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_MessageSubject, 0, valMessageSubject, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_MessageSubject, 0, Integer(PChar(valMessageSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_MessageText: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_MessageText, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_MessageText, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_MessageText(valMessageText: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_MessageText, 0, valMessageText, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_MessageText, 0, Integer(PChar(valMessageText)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_MessageThread: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_MessageThread, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_MessageThread, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_MessageThread(valMessageThread: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_MessageThread, 0, valMessageThread, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_MessageThread, 0, Integer(PChar(valMessageThread)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_MessageType: TipsxmppsMessageTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsxmppsMessageTypes(_XMPPS_GetENUM(m_ctl, PID_XMPPS_MessageType, 0, err));
{$ELSE}
  result := TipsxmppsMessageTypes(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_MessageType, 0, nil);
  result := TipsxmppsMessageTypes(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_MessageType(valMessageType: TipsxmppsMessageTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetENUM(m_ctl, PID_XMPPS_MessageType, 0, Integer(valMessageType), 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_MessageType, 0, Integer(valMessageType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_OtherData: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_OtherData, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_OtherData, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_OtherData(valOtherData: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_OtherData, 0, valOtherData, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_OtherData, 0, Integer(PChar(valOtherData)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_Presence: TipsxmppsPresences;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsxmppsPresences(_XMPPS_GetENUM(m_ctl, PID_XMPPS_Presence, 0, err));
{$ELSE}
  result := TipsxmppsPresences(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_Presence, 0, nil);
  result := TipsxmppsPresences(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_Presence(valPresence: TipsxmppsPresences);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetENUM(m_ctl, PID_XMPPS_Presence, 0, Integer(valPresence), 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_Presence, 0, Integer(valPresence), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_Resource: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_Resource, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_Resource, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_Resource(valResource: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_Resource, 0, valResource, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_Resource, 0, Integer(PChar(valResource)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetBSTR(m_ctl, PID_XMPPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsXMPPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetBSTR(m_ctl, PID_XMPPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetBSTR(m_ctl, PID_XMPPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsXMPPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetBSTR(m_ctl, PID_XMPPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetBSTR(m_ctl, PID_XMPPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsXMPPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetBSTR(m_ctl, PID_XMPPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_SSLCertStoreType: TipsxmppsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsxmppsSSLCertStoreTypes(_XMPPS_GetENUM(m_ctl, PID_XMPPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipsxmppsSSLCertStoreTypes(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLCertStoreType, 0, nil);
  result := TipsxmppsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_SSLCertStoreType(valSSLCertStoreType: TipsxmppsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetENUM(m_ctl, PID_XMPPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetBSTR(m_ctl, PID_XMPPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsXMPPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsXMPPS.get_SSLStartMode: TipsxmppsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsxmppsSSLStartModes(_XMPPS_GetENUM(m_ctl, PID_XMPPS_SSLStartMode, 0, err));
{$ELSE}
  result := TipsxmppsSSLStartModes(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_SSLStartMode, 0, nil);
  result := TipsxmppsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_SSLStartMode(valSSLStartMode: TipsxmppsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetENUM(m_ctl, PID_XMPPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_Status: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_Status, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_Status, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_Status(valStatus: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_Status, 0, valStatus, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_Status, 0, Integer(PChar(valStatus)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_XMPPS_GetINT(m_ctl, PID_XMPPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetINT(m_ctl, PID_XMPPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_User, 0, valUser, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_UserInfoCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_XMPPS_GetINT(m_ctl, PID_XMPPS_UserInfoCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_UserInfoCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsXMPPS.set_UserInfoCount(valUserInfoCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetINT(m_ctl, PID_XMPPS_UserInfoCount, 0, valUserInfoCount, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_UserInfoCount, 0, Integer(valUserInfoCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_UserInfoFields(FieldIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_UserInfoFields, FieldIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_XMPPS_CheckIndex = nil then exit;
  err :=  _XMPPS_CheckIndex(m_ctl, PID_XMPPS_UserInfoFields, FieldIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for UserInfoFields');
	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_UserInfoFields, FieldIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_UserInfoFields(FieldIndex: Word; valUserInfoFields: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_UserInfoFields, FieldIndex, valUserInfoFields, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_UserInfoFields, FieldIndex, Integer(PChar(valUserInfoFields)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsXMPPS.get_UserInfoValues(FieldIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _XMPPS_GetCSTR(m_ctl, PID_XMPPS_UserInfoValues, FieldIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_XMPPS_CheckIndex = nil then exit;
  err :=  _XMPPS_CheckIndex(m_ctl, PID_XMPPS_UserInfoValues, FieldIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for UserInfoValues');
	if @_XMPPS_Get = nil then exit;
  tmp := _XMPPS_Get(m_ctl, PID_XMPPS_UserInfoValues, FieldIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsXMPPS.set_UserInfoValues(FieldIndex: Word; valUserInfoValues: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _XMPPS_SetCSTR(m_ctl, PID_XMPPS_UserInfoValues, FieldIndex, valUserInfoValues, 0);
{$ELSE}
	if @_XMPPS_Set = nil then exit;
  err := _XMPPS_Set(m_ctl, PID_XMPPS_UserInfoValues, FieldIndex, Integer(PChar(valUserInfoValues)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsXMPPS.Config(ConfigurationString: String): String;
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


  err := _XMPPS_Do(m_ctl, MID_XMPPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsXMPPS.Add(JabberId: String; Name: String; Groups: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..4] of Pointer;
  paramcb : array[0..4] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(JabberId);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Name);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Groups);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_Add, 3, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);

	if param[2] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[2]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(JabberId);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Name);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Groups);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_Add, 3, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.Cancel(JabberId: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(JabberId);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_Cancel, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(JabberId);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_Cancel, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.ChangePresence(PresenceCode: Integer; Status: String);

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

  param[i] := IntPtr(PresenceCode);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Status);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_ChangePresence, 2, param, paramcb); 


	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := Pointer(PresenceCode);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := PChar(Status);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_ChangePresence, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.Connect(User: String; Password: String);

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
  param[i] := Marshal.StringToHGlobalAnsi(Password);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_Connect, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(User);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Password);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_Connect, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.Disconnect();

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



  err := _XMPPS_Do(m_ctl, MID_XMPPS_Disconnect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_Disconnect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.DoEvents();

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



  err := _XMPPS_Do(m_ctl, MID_XMPPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.ProbePresence(JabberId: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(JabberId);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_ProbePresence, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(JabberId);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_ProbePresence, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.QueryRegister(XMPPServer: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(XMPPServer);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_QueryRegister, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(XMPPServer);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_QueryRegister, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.Register(XMPPServer: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(XMPPServer);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_Register, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(XMPPServer);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_Register, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.Remove(JabberId: String; Name: String; Group: String);

var
{$IFDEF CLR}
  param : LPVOIDARR;
  paramcb : LPINTARR;
{$ELSE}
  param : array[0..4] of Pointer;
  paramcb : array[0..4] of Integer;
{$ENDIF}
  i, err: Integer;
begin
  i := 0;
{$IFDEF CLR}

  param[i] := Marshal.StringToHGlobalAnsi(JabberId);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Name);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Group);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_Remove, 3, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);

	if param[2] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[2]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(JabberId);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Name);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Group);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_Remove, 3, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.RetrieveRoster();

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



  err := _XMPPS_Do(m_ctl, MID_XMPPS_RetrieveRoster, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_RetrieveRoster, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.SendCommand(Command: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(Command);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_SendCommand, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(Command);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_SendCommand, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.SendMessage(JabberId: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(JabberId);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_SendMessage, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(JabberId);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_SendMessage, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.SetUserInfoField(Field: String; Value: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(Field);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Value);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_SetUserInfoField, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(Field);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Value);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_SetUserInfoField, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.SubscribeTo(JabberId: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(JabberId);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_SubscribeTo, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(JabberId);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_SubscribeTo, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.Unregister();

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



  err := _XMPPS_Do(m_ctl, MID_XMPPS_Unregister, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_Unregister, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsXMPPS.UnsubscribeTo(JabberId: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(JabberId);
  paramcb[i] := 0;

  i := i + 1;


  err := _XMPPS_Do(m_ctl, MID_XMPPS_UnsubscribeTo, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(JabberId);
  paramcb[i] := 0;

  i := i + 1;


	if @_XMPPS_Do = nil then exit;
  err := _XMPPS_Do(m_ctl, MID_XMPPS_UnsubscribeTo, 1, @param, @paramcb); 
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

	_XMPPS_Create := nil;
	_XMPPS_Destroy := nil;
	_XMPPS_Set := nil;
	_XMPPS_Get := nil;
	_XMPPS_GetLastError := nil;
	_XMPPS_StaticInit := nil;
	_XMPPS_CheckIndex := nil;
	_XMPPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_xmpps_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_XMPPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'XMPPS_Create');
		@_XMPPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'XMPPS_Destroy');
		@_XMPPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'XMPPS_Set');
		@_XMPPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'XMPPS_Get');
		@_XMPPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'XMPPS_GetLastError');
		@_XMPPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'XMPPS_CheckIndex');
		@_XMPPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'XMPPS_Do');
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
  @_XMPPS_Create       := nil;
  @_XMPPS_Destroy      := nil;
  @_XMPPS_Set          := nil;
  @_XMPPS_Get          := nil;
  @_XMPPS_GetLastError := nil;
  @_XMPPS_CheckIndex   := nil;
  @_XMPPS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




