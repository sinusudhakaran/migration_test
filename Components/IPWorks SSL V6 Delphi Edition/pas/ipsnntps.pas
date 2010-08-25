
unit ipsnntps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipsnntpsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipsnntpsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipsnntpsSSLStartModes = 
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

  TGroupListEvent = procedure(Sender: TObject;
                            const Group: String;
                            FirstArticle: Integer;
                            LastArticle: Integer;
                            CanPost: Boolean) of Object;

  TGroupOverviewEvent = procedure(Sender: TObject;
                            ArticleNumber: Integer;
                            const Subject: String;
                            const From: String;
                            const ArticleDate: String;
                            const MessageId: String;
                            const References: String;
                            ArticleSize: Integer;
                            ArticleLines: Integer;
                            const OtherHeaders: String) of Object;

  TGroupSearchEvent = procedure(Sender: TObject;
                            ArticleNumber: Integer;
                            const Header: String) of Object;

  THeaderEvent = procedure(Sender: TObject;
                            const Field: String;
                            const Value: String) of Object;

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
  TNNTPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsNNTPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsNNTPS = class(TipsCore)
    public
      FOnConnectionStatus: TConnectionStatusEvent;

      FOnEndTransfer: TEndTransferEvent;

      FOnError: TErrorEvent;

      FOnGroupList: TGroupListEvent;

      FOnGroupOverview: TGroupOverviewEvent;

      FOnGroupSearch: TGroupSearchEvent;

      FOnHeader: THeaderEvent;

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
      m_anchor: TNNTPSEventHook;
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

      function get_ArticleFrom: String;
      procedure set_ArticleFrom(valArticleFrom: String);

      function get_ArticleReferences: String;
      procedure set_ArticleReferences(valArticleReferences: String);

      function get_ArticleReplyTo: String;
      procedure set_ArticleReplyTo(valArticleReplyTo: String);

      function get_ArticleSubject: String;
      procedure set_ArticleSubject(valArticleSubject: String);

      function get_ArticleText: String;
      procedure set_ArticleText(valArticleText: String);

      function get_AttachedFile: String;
      procedure set_AttachedFile(valAttachedFile: String);

      function get_CheckDate: String;
      procedure set_CheckDate(valCheckDate: String);


      procedure set_Command(valCommand: String);

      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);

      function get_MaxLines: Integer;
      procedure set_MaxLines(valMaxLines: Integer);

      function get_Newsgroups: String;
      procedure set_Newsgroups(valNewsgroups: String);

      function get_NewsPort: Integer;
      procedure set_NewsPort(valNewsPort: Integer);

      function get_Organization: String;
      procedure set_Organization(valOrganization: String);

      function get_OtherHeaders: String;
      procedure set_OtherHeaders(valOtherHeaders: String);

      function get_OverviewRange: String;
      procedure set_OverviewRange(valOverviewRange: String);

      function get_SearchHeader: String;
      procedure set_SearchHeader(valSearchHeader: String);

      function get_SearchPattern: String;
      procedure set_SearchPattern(valSearchPattern: String);

      function get_SearchRange: String;
      procedure set_SearchRange(valSearchRange: String);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);


      procedure TreatErr(Err: integer; const desc: string);


      function get_ArticleCount: Integer;


      function get_ArticleDate: String;




      function get_ArticleHeaders: String;


      function get_ArticleId: String;


















      function get_CurrentArticle: String;
      procedure set_CurrentArticle(valCurrentArticle: String);

      function get_CurrentGroup: String;
      procedure set_CurrentGroup(valCurrentGroup: String);

      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipsnntpsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipsnntpsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_FirstArticle: Integer;


      function get_Idle: Boolean;


      function get_LastArticle: Integer;


      function get_LastReply: String;


      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);







      function get_NewsServer: String;
      procedure set_NewsServer(valNewsServer: String);







      function get_Password: String;
      procedure set_Password(valPassword: String);







      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipsnntpsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipsnntpsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipsnntpsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipsnntpsSSLStartModes);

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





      property ArticleFrom: String
               read get_ArticleFrom
               write set_ArticleFrom               ;





      property ArticleReferences: String
               read get_ArticleReferences
               write set_ArticleReferences               ;

      property ArticleReplyTo: String
               read get_ArticleReplyTo
               write set_ArticleReplyTo               ;

      property ArticleSubject: String
               read get_ArticleSubject
               write set_ArticleSubject               ;

      property ArticleText: String
               read get_ArticleText
               write set_ArticleText               ;

      property AttachedFile: String
               read get_AttachedFile
               write set_AttachedFile               ;

      property CheckDate: String
               read get_CheckDate
               write set_CheckDate               ;

      property Command: String

               write set_Command               ;

      property Connected: Boolean
               read get_Connected
               write set_Connected               ;

























      property MaxLines: Integer
               read get_MaxLines
               write set_MaxLines               ;

      property Newsgroups: String
               read get_Newsgroups
               write set_Newsgroups               ;

      property NewsPort: Integer
               read get_NewsPort
               write set_NewsPort               ;



      property Organization: String
               read get_Organization
               write set_Organization               ;

      property OtherHeaders: String
               read get_OtherHeaders
               write set_OtherHeaders               ;

      property OverviewRange: String
               read get_OverviewRange
               write set_OverviewRange               ;



      property SearchHeader: String
               read get_SearchHeader
               write set_SearchHeader               ;

      property SearchPattern: String
               read get_SearchPattern
               write set_SearchPattern               ;

      property SearchRange: String
               read get_SearchRange
               write set_SearchRange               ;



      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;





















{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure Connect();

      procedure Disconnect();

      procedure DoEvents();

      procedure FetchArticle();

      procedure FetchArticleBody();

      procedure FetchArticleHeaders();

      procedure GroupOverview();

      procedure GroupSearch();

      procedure Interrupt();

      procedure ListGroups();

      procedure ListNewGroups();

      function LocalizeDate(DateTime: String): String;
      procedure PostArticle();

      procedure ResetHeaders();


{$ENDIF}

    published

      property ArticleCount: Integer
                   read get_ArticleCount
                    write SetNoopInteger
                   stored False

                   ;
      property ArticleDate: String
                   read get_ArticleDate
                    write SetNoopString
                   stored False

                   ;

      property ArticleHeaders: String
                   read get_ArticleHeaders
                    write SetNoopString
                   stored False

                   ;
      property ArticleId: String
                   read get_ArticleId
                    write SetNoopString
                   stored False

                   ;








      property CurrentArticle: String
                   read get_CurrentArticle
                   write set_CurrentArticle
                   
                   ;
      property CurrentGroup: String
                   read get_CurrentGroup
                   write set_CurrentGroup
                   
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
      property FirewallType: TipsnntpsFirewallTypes
                   read get_FirewallType
                   write set_FirewallType
                   default fwNone
                   ;
      property FirewallUser: String
                   read get_FirewallUser
                   write set_FirewallUser
                   
                   ;
      property FirstArticle: Integer
                   read get_FirstArticle
                    write SetNoopInteger
                   stored False

                   ;
      property Idle: Boolean
                   read get_Idle
                    write SetNoopBoolean
                   stored False

                   ;
      property LastArticle: Integer
                   read get_LastArticle
                    write SetNoopInteger
                   stored False

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



      property NewsServer: String
                   read get_NewsServer
                   write set_NewsServer
                   
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
      property SSLCertStoreType: TipsnntpsSSLCertStoreTypes
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
      property SSLStartMode: TipsnntpsSSLStartModes
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

      property OnGroupList: TGroupListEvent read FOnGroupList write FOnGroupList;

      property OnGroupOverview: TGroupOverviewEvent read FOnGroupOverview write FOnGroupOverview;

      property OnGroupSearch: TGroupSearchEvent read FOnGroupSearch write FOnGroupSearch;

      property OnHeader: THeaderEvent read FOnHeader write FOnHeader;

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
    PID_NNTPS_ArticleCount = 1;
    PID_NNTPS_ArticleDate = 2;
    PID_NNTPS_ArticleFrom = 3;
    PID_NNTPS_ArticleHeaders = 4;
    PID_NNTPS_ArticleId = 5;
    PID_NNTPS_ArticleReferences = 6;
    PID_NNTPS_ArticleReplyTo = 7;
    PID_NNTPS_ArticleSubject = 8;
    PID_NNTPS_ArticleText = 9;
    PID_NNTPS_AttachedFile = 10;
    PID_NNTPS_CheckDate = 11;
    PID_NNTPS_Command = 12;
    PID_NNTPS_Connected = 13;
    PID_NNTPS_CurrentArticle = 14;
    PID_NNTPS_CurrentGroup = 15;
    PID_NNTPS_FirewallHost = 16;
    PID_NNTPS_FirewallPassword = 17;
    PID_NNTPS_FirewallPort = 18;
    PID_NNTPS_FirewallType = 19;
    PID_NNTPS_FirewallUser = 20;
    PID_NNTPS_FirstArticle = 21;
    PID_NNTPS_Idle = 22;
    PID_NNTPS_LastArticle = 23;
    PID_NNTPS_LastReply = 24;
    PID_NNTPS_LocalHost = 25;
    PID_NNTPS_MaxLines = 26;
    PID_NNTPS_Newsgroups = 27;
    PID_NNTPS_NewsPort = 28;
    PID_NNTPS_NewsServer = 29;
    PID_NNTPS_Organization = 30;
    PID_NNTPS_OtherHeaders = 31;
    PID_NNTPS_OverviewRange = 32;
    PID_NNTPS_Password = 33;
    PID_NNTPS_SearchHeader = 34;
    PID_NNTPS_SearchPattern = 35;
    PID_NNTPS_SearchRange = 36;
    PID_NNTPS_SSLAcceptServerCert = 37;
    PID_NNTPS_SSLCertEncoded = 38;
    PID_NNTPS_SSLCertStore = 39;
    PID_NNTPS_SSLCertStorePassword = 40;
    PID_NNTPS_SSLCertStoreType = 41;
    PID_NNTPS_SSLCertSubject = 42;
    PID_NNTPS_SSLServerCert = 43;
    PID_NNTPS_SSLServerCertStatus = 44;
    PID_NNTPS_SSLStartMode = 45;
    PID_NNTPS_Timeout = 46;
    PID_NNTPS_User = 47;

    EID_NNTPS_ConnectionStatus = 1;
    EID_NNTPS_EndTransfer = 2;
    EID_NNTPS_Error = 3;
    EID_NNTPS_GroupList = 4;
    EID_NNTPS_GroupOverview = 5;
    EID_NNTPS_GroupSearch = 6;
    EID_NNTPS_Header = 7;
    EID_NNTPS_PITrail = 8;
    EID_NNTPS_SSLServerAuthentication = 9;
    EID_NNTPS_SSLStatus = 10;
    EID_NNTPS_StartTransfer = 11;
    EID_NNTPS_Transfer = 12;


    MID_NNTPS_Config = 1;
    MID_NNTPS_Connect = 2;
    MID_NNTPS_Disconnect = 3;
    MID_NNTPS_DoEvents = 4;
    MID_NNTPS_FetchArticle = 5;
    MID_NNTPS_FetchArticleBody = 6;
    MID_NNTPS_FetchArticleHeaders = 7;
    MID_NNTPS_GroupOverview = 8;
    MID_NNTPS_GroupSearch = 9;
    MID_NNTPS_Interrupt = 10;
    MID_NNTPS_ListGroups = 11;
    MID_NNTPS_ListNewGroups = 12;
    MID_NNTPS_LocalizeDate = 13;
    MID_NNTPS_PostArticle = 14;
    MID_NNTPS_ResetHeaders = 15;




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
{$R 'ipsnntps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsNNTPS; event_id: Integer; cparam: Integer; 
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
  _NNTPS_Create:        function(pMethod: PEventHandle; pObject: TipsNNTPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _NNTPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _NNTPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _NNTPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _NNTPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _NNTPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _NNTPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _NNTPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Create')]
  function _NNTPS_Create       (pMethod: TNNTPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Destroy')]
  function _NNTPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Set')]
  function _NNTPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Set')]
  function _NNTPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Set')]
  function _NNTPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Set')]
  function _NNTPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Set')]
  function _NNTPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Set')]
  function _NNTPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Get')]
  function _NNTPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Get')]
  function _NNTPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Get')]
  function _NNTPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Get')]
  function _NNTPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Get')]
  function _NNTPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Get')]
  function _NNTPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_GetLastError')]
  function _NNTPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_StaticInit')]
  function _NNTPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_CheckIndex')]
  function _NNTPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'NNTPS_Do')]
  function _NNTPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _NNTPS_Create       (pMethod: PEventHandle; pObject: TipsNNTPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'NNTPS_Create';
  function _NNTPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'NNTPS_Destroy';
  function _NNTPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'NNTPS_Set';
  function _NNTPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'NNTPS_Get';
  function _NNTPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'NNTPS_GetLastError';
  function _NNTPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'NNTPS_StaticInit';
  function _NNTPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'NNTPS_CheckIndex';
  function _NNTPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'NNTPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsNNTPS; event_id: Integer;
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
    tmp_GroupListGroup: String;
    tmp_GroupListFirstArticle: Integer;
    tmp_GroupListLastArticle: Integer;
    tmp_GroupListCanPost: Boolean;
    tmp_GroupOverviewArticleNumber: Integer;
    tmp_GroupOverviewSubject: String;
    tmp_GroupOverviewFrom: String;
    tmp_GroupOverviewArticleDate: String;
    tmp_GroupOverviewMessageId: String;
    tmp_GroupOverviewReferences: String;
    tmp_GroupOverviewArticleSize: Integer;
    tmp_GroupOverviewArticleLines: Integer;
    tmp_GroupOverviewOtherHeaders: String;
    tmp_GroupSearchArticleNumber: Integer;
    tmp_GroupSearchHeader: String;
    tmp_HeaderField: String;
    tmp_HeaderValue: String;
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

      EID_NNTPS_ConnectionStatus:
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
      EID_NNTPS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_NNTPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_NNTPS_GroupList:
      begin
        if Assigned(lpContext.FOnGroupList) then
        begin
          {assign temporary variables}
          tmp_GroupListGroup := AnsiString(PChar(params^[0]));

          tmp_GroupListFirstArticle := Integer(params^[1]);
          tmp_GroupListLastArticle := Integer(params^[2]);
          tmp_GroupListCanPost := Boolean(params^[3]);

          lpContext.FOnGroupList(lpContext, tmp_GroupListGroup, tmp_GroupListFirstArticle, tmp_GroupListLastArticle, tmp_GroupListCanPost);





        end;
      end;
      EID_NNTPS_GroupOverview:
      begin
        if Assigned(lpContext.FOnGroupOverview) then
        begin
          {assign temporary variables}
          tmp_GroupOverviewArticleNumber := Integer(params^[0]);
          tmp_GroupOverviewSubject := AnsiString(PChar(params^[1]));

          tmp_GroupOverviewFrom := AnsiString(PChar(params^[2]));

          tmp_GroupOverviewArticleDate := AnsiString(PChar(params^[3]));

          tmp_GroupOverviewMessageId := AnsiString(PChar(params^[4]));

          tmp_GroupOverviewReferences := AnsiString(PChar(params^[5]));

          tmp_GroupOverviewArticleSize := Integer(params^[6]);
          tmp_GroupOverviewArticleLines := Integer(params^[7]);
          tmp_GroupOverviewOtherHeaders := AnsiString(PChar(params^[8]));


          lpContext.FOnGroupOverview(lpContext, tmp_GroupOverviewArticleNumber, tmp_GroupOverviewSubject, tmp_GroupOverviewFrom, tmp_GroupOverviewArticleDate, tmp_GroupOverviewMessageId, tmp_GroupOverviewReferences, tmp_GroupOverviewArticleSize, tmp_GroupOverviewArticleLines, tmp_GroupOverviewOtherHeaders);










        end;
      end;
      EID_NNTPS_GroupSearch:
      begin
        if Assigned(lpContext.FOnGroupSearch) then
        begin
          {assign temporary variables}
          tmp_GroupSearchArticleNumber := Integer(params^[0]);
          tmp_GroupSearchHeader := AnsiString(PChar(params^[1]));


          lpContext.FOnGroupSearch(lpContext, tmp_GroupSearchArticleNumber, tmp_GroupSearchHeader);



        end;
      end;
      EID_NNTPS_Header:
      begin
        if Assigned(lpContext.FOnHeader) then
        begin
          {assign temporary variables}
          tmp_HeaderField := AnsiString(PChar(params^[0]));

          tmp_HeaderValue := AnsiString(PChar(params^[1]));


          lpContext.FOnHeader(lpContext, tmp_HeaderField, tmp_HeaderValue);



        end;
      end;
      EID_NNTPS_PITrail:
      begin
        if Assigned(lpContext.FOnPITrail) then
        begin
          {assign temporary variables}
          tmp_PITrailDirection := Integer(params^[0]);
          tmp_PITrailMessage := AnsiString(PChar(params^[1]));


          lpContext.FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailMessage);



        end;
      end;
      EID_NNTPS_SSLServerAuthentication:
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
      EID_NNTPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_NNTPS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_NNTPS_Transfer:
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
function TipsNNTPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;


  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_GroupListGroup: String;
  tmp_GroupListFirstArticle: Integer;
  tmp_GroupListLastArticle: Integer;
  tmp_GroupListCanPost: Boolean;

  tmp_GroupOverviewArticleNumber: Integer;
  tmp_GroupOverviewSubject: String;
  tmp_GroupOverviewFrom: String;
  tmp_GroupOverviewArticleDate: String;
  tmp_GroupOverviewMessageId: String;
  tmp_GroupOverviewReferences: String;
  tmp_GroupOverviewArticleSize: Integer;
  tmp_GroupOverviewArticleLines: Integer;
  tmp_GroupOverviewOtherHeaders: String;

  tmp_GroupSearchArticleNumber: Integer;
  tmp_GroupSearchHeader: String;

  tmp_HeaderField: String;
  tmp_HeaderValue: String;

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
    EID_NNTPS_ConnectionStatus:
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
    EID_NNTPS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_NNTPS_Error:
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
    EID_NNTPS_GroupList:
    begin
      if Assigned(FOnGroupList) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_GroupListGroup := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_GroupListFirstArticle := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_GroupListLastArticle := Marshal.ReadInt32(params, 4*2);
				p := Marshal.ReadIntPtr(params, 4 * 3);
        if Marshal.ReadInt32(params, 4*3) <> 0 then tmp_GroupListCanPost := true else tmp_GroupListCanPost := false;


        FOnGroupList(lpContext, tmp_GroupListGroup, tmp_GroupListFirstArticle, tmp_GroupListLastArticle, tmp_GroupListCanPost);





      end;


    end;
    EID_NNTPS_GroupOverview:
    begin
      if Assigned(FOnGroupOverview) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_GroupOverviewArticleNumber := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_GroupOverviewSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_GroupOverviewFrom := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_GroupOverviewArticleDate := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_GroupOverviewMessageId := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        tmp_GroupOverviewReferences := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 6);
        tmp_GroupOverviewArticleSize := Marshal.ReadInt32(params, 4*6);
				p := Marshal.ReadIntPtr(params, 4 * 7);
        tmp_GroupOverviewArticleLines := Marshal.ReadInt32(params, 4*7);
				p := Marshal.ReadIntPtr(params, 4 * 8);
        tmp_GroupOverviewOtherHeaders := Marshal.PtrToStringAnsi(p);


        FOnGroupOverview(lpContext, tmp_GroupOverviewArticleNumber, tmp_GroupOverviewSubject, tmp_GroupOverviewFrom, tmp_GroupOverviewArticleDate, tmp_GroupOverviewMessageId, tmp_GroupOverviewReferences, tmp_GroupOverviewArticleSize, tmp_GroupOverviewArticleLines, tmp_GroupOverviewOtherHeaders);










      end;


    end;
    EID_NNTPS_GroupSearch:
    begin
      if Assigned(FOnGroupSearch) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_GroupSearchArticleNumber := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_GroupSearchHeader := Marshal.PtrToStringAnsi(p);


        FOnGroupSearch(lpContext, tmp_GroupSearchArticleNumber, tmp_GroupSearchHeader);



      end;


    end;
    EID_NNTPS_Header:
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
    EID_NNTPS_PITrail:
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
    EID_NNTPS_SSLServerAuthentication:
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
    EID_NNTPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_NNTPS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_NNTPS_Transfer:
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
    RegisterComponents('IP*Works! SSL', [TipsNNTPS]);
end;

constructor TipsNNTPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _NNTPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_NNTPS_Create <> nil then
      m_ctl := _NNTPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL NNTPS: Error creating component');

{$IFDEF CLR}
    _NNTPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_25, 0);
{$ELSE}
    _NNTPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_25)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_NNTPS_Do <> nil then
      _NNTPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_CurrentArticle('') except on E:Exception do end;
    try set_CurrentGroup('') except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_NewsServer('') except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsNNTPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_NNTPS_Destroy <> nil then{$ENDIF}
      	_NNTPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsNNTPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsNNTPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsNNTPS.AboutDlg;
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
	if @_NNTPS_Do <> nil then
{$ENDIF}
		_NNTPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsNNTPS.SetOK(key: String128);
begin
end;

function TipsNNTPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsNNTPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsNNTPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsNNTPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsNNTPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsNNTPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_NNTPS_GetLastError <> nil then{$ENDIF}
      msg := _NNTPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsNNTPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_NNTPS_Do <> nil then
      _NNTPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsNNTPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_NNTPS_Set = nil then exit;{$ENDIF}
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsNNTPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_NNTPS_Set = nil then exit;{$ENDIF}
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsNNTPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_NNTPS_Set = nil then exit;{$ENDIF}
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsNNTPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_NNTPS_Set = nil then exit;{$ENDIF}
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsNNTPS.get_ArticleCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_NNTPS_GetLONG(m_ctl, PID_NNTPS_ArticleCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsNNTPS.get_ArticleDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_ArticleDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsNNTPS.get_ArticleFrom: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_ArticleFrom, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleFrom, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_ArticleFrom(valArticleFrom: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_ArticleFrom, 0, valArticleFrom, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_ArticleFrom, 0, Integer(PChar(valArticleFrom)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_ArticleHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_ArticleHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsNNTPS.get_ArticleId: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_ArticleId, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleId, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsNNTPS.get_ArticleReferences: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_ArticleReferences, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleReferences, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_ArticleReferences(valArticleReferences: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_ArticleReferences, 0, valArticleReferences, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_ArticleReferences, 0, Integer(PChar(valArticleReferences)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_ArticleReplyTo: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_ArticleReplyTo, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleReplyTo, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_ArticleReplyTo(valArticleReplyTo: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_ArticleReplyTo, 0, valArticleReplyTo, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_ArticleReplyTo, 0, Integer(PChar(valArticleReplyTo)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_ArticleSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_ArticleSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_ArticleSubject(valArticleSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_ArticleSubject, 0, valArticleSubject, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_ArticleSubject, 0, Integer(PChar(valArticleSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_ArticleText: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_ArticleText, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_ArticleText, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_ArticleText(valArticleText: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_ArticleText, 0, valArticleText, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_ArticleText, 0, Integer(PChar(valArticleText)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_AttachedFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_AttachedFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_AttachedFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_AttachedFile(valAttachedFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_AttachedFile, 0, valAttachedFile, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_AttachedFile, 0, Integer(PChar(valAttachedFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_CheckDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_CheckDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_CheckDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_CheckDate(valCheckDate: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_CheckDate, 0, valCheckDate, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_CheckDate, 0, Integer(PChar(valCheckDate)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsNNTPS.set_Command(valCommand: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_Command, 0, valCommand, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_Command, 0, Integer(PChar(valCommand)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_NNTPS_GetBOOL(m_ctl, PID_NNTPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsNNTPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetBOOL(m_ctl, PID_NNTPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_CurrentArticle: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_CurrentArticle, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_CurrentArticle, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_CurrentArticle(valCurrentArticle: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_CurrentArticle, 0, valCurrentArticle, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_CurrentArticle, 0, Integer(PChar(valCurrentArticle)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_CurrentGroup: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_CurrentGroup, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_CurrentGroup, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_CurrentGroup(valCurrentGroup: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_CurrentGroup, 0, valCurrentGroup, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_CurrentGroup, 0, Integer(PChar(valCurrentGroup)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_NNTPS_GetLONG(m_ctl, PID_NNTPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsNNTPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetLONG(m_ctl, PID_NNTPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_FirewallType: TipsnntpsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsnntpsFirewallTypes(_NNTPS_GetENUM(m_ctl, PID_NNTPS_FirewallType, 0, err));
{$ELSE}
  result := TipsnntpsFirewallTypes(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_FirewallType, 0, nil);
  result := TipsnntpsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsNNTPS.set_FirewallType(valFirewallType: TipsnntpsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetENUM(m_ctl, PID_NNTPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_FirstArticle: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_NNTPS_GetLONG(m_ctl, PID_NNTPS_FirstArticle, 0, err));
{$ELSE}
  result := Integer(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_FirstArticle, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsNNTPS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_NNTPS_GetBOOL(m_ctl, PID_NNTPS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsNNTPS.get_LastArticle: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_NNTPS_GetLONG(m_ctl, PID_NNTPS_LastArticle, 0, err));
{$ELSE}
  result := Integer(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_LastArticle, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsNNTPS.get_LastReply: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_LastReply, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_LastReply, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsNNTPS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_MaxLines: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_NNTPS_GetLONG(m_ctl, PID_NNTPS_MaxLines, 0, err));
{$ELSE}
  result := Integer(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_MaxLines, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsNNTPS.set_MaxLines(valMaxLines: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetLONG(m_ctl, PID_NNTPS_MaxLines, 0, valMaxLines, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_MaxLines, 0, Integer(valMaxLines), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_Newsgroups: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_Newsgroups, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_Newsgroups, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_Newsgroups(valNewsgroups: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_Newsgroups, 0, valNewsgroups, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_Newsgroups, 0, Integer(PChar(valNewsgroups)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_NewsPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_NNTPS_GetLONG(m_ctl, PID_NNTPS_NewsPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_NewsPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsNNTPS.set_NewsPort(valNewsPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetLONG(m_ctl, PID_NNTPS_NewsPort, 0, valNewsPort, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_NewsPort, 0, Integer(valNewsPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_NewsServer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_NewsServer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_NewsServer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_NewsServer(valNewsServer: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_NewsServer, 0, valNewsServer, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_NewsServer, 0, Integer(PChar(valNewsServer)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_Organization: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_Organization, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_Organization, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_Organization(valOrganization: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_Organization, 0, valOrganization, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_Organization, 0, Integer(PChar(valOrganization)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_OtherHeaders: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_OtherHeaders, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_OtherHeaders, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_OtherHeaders(valOtherHeaders: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_OtherHeaders, 0, valOtherHeaders, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_OtherHeaders, 0, Integer(PChar(valOtherHeaders)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_OverviewRange: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_OverviewRange, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_OverviewRange, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_OverviewRange(valOverviewRange: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_OverviewRange, 0, valOverviewRange, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_OverviewRange, 0, Integer(PChar(valOverviewRange)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SearchHeader: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_SearchHeader, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SearchHeader, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_SearchHeader(valSearchHeader: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_SearchHeader, 0, valSearchHeader, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SearchHeader, 0, Integer(PChar(valSearchHeader)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SearchPattern: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_SearchPattern, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SearchPattern, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_SearchPattern(valSearchPattern: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_SearchPattern, 0, valSearchPattern, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SearchPattern, 0, Integer(PChar(valSearchPattern)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SearchRange: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_SearchRange, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SearchRange, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_SearchRange(valSearchRange: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_SearchRange, 0, valSearchRange, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SearchRange, 0, Integer(PChar(valSearchRange)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetBSTR(m_ctl, PID_NNTPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsNNTPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetBSTR(m_ctl, PID_NNTPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetBSTR(m_ctl, PID_NNTPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsNNTPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetBSTR(m_ctl, PID_NNTPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetBSTR(m_ctl, PID_NNTPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsNNTPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetBSTR(m_ctl, PID_NNTPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SSLCertStoreType: TipsnntpsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsnntpsSSLCertStoreTypes(_NNTPS_GetENUM(m_ctl, PID_NNTPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipsnntpsSSLCertStoreTypes(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLCertStoreType, 0, nil);
  result := TipsnntpsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsNNTPS.set_SSLCertStoreType(valSSLCertStoreType: TipsnntpsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetENUM(m_ctl, PID_NNTPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetBSTR(m_ctl, PID_NNTPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsNNTPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsNNTPS.get_SSLStartMode: TipsnntpsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsnntpsSSLStartModes(_NNTPS_GetENUM(m_ctl, PID_NNTPS_SSLStartMode, 0, err));
{$ELSE}
  result := TipsnntpsSSLStartModes(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_SSLStartMode, 0, nil);
  result := TipsnntpsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsNNTPS.set_SSLStartMode(valSSLStartMode: TipsnntpsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetENUM(m_ctl, PID_NNTPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_NNTPS_GetINT(m_ctl, PID_NNTPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsNNTPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetINT(m_ctl, PID_NNTPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsNNTPS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _NNTPS_GetCSTR(m_ctl, PID_NNTPS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_NNTPS_Get = nil then exit;
  tmp := _NNTPS_Get(m_ctl, PID_NNTPS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsNNTPS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _NNTPS_SetCSTR(m_ctl, PID_NNTPS_User, 0, valUser, 0);
{$ELSE}
	if @_NNTPS_Set = nil then exit;
  err := _NNTPS_Set(m_ctl, PID_NNTPS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsNNTPS.Config(ConfigurationString: String): String;
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


  err := _NNTPS_Do(m_ctl, MID_NNTPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsNNTPS.Connect();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_Connect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_Connect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.Disconnect();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_Disconnect, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_Disconnect, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.DoEvents();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.FetchArticle();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_FetchArticle, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_FetchArticle, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.FetchArticleBody();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_FetchArticleBody, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_FetchArticleBody, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.FetchArticleHeaders();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_FetchArticleHeaders, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_FetchArticleHeaders, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.GroupOverview();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_GroupOverview, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_GroupOverview, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.GroupSearch();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_GroupSearch, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_GroupSearch, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.Interrupt();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.ListGroups();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_ListGroups, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_ListGroups, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.ListNewGroups();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_ListNewGroups, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_ListNewGroups, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsNNTPS.LocalizeDate(DateTime: String): String;
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


  err := _NNTPS_Do(m_ctl, MID_NNTPS_LocalizeDate, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(DateTime);
  paramcb[i] := 0;

  i := i + 1;


	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_LocalizeDate, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsNNTPS.PostArticle();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_PostArticle, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_PostArticle, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsNNTPS.ResetHeaders();

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



  err := _NNTPS_Do(m_ctl, MID_NNTPS_ResetHeaders, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_NNTPS_Do = nil then exit;
  err := _NNTPS_Do(m_ctl, MID_NNTPS_ResetHeaders, 0, @param, @paramcb); 
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

	_NNTPS_Create := nil;
	_NNTPS_Destroy := nil;
	_NNTPS_Set := nil;
	_NNTPS_Get := nil;
	_NNTPS_GetLastError := nil;
	_NNTPS_StaticInit := nil;
	_NNTPS_CheckIndex := nil;
	_NNTPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_nntps_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_NNTPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'NNTPS_Create');
		@_NNTPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'NNTPS_Destroy');
		@_NNTPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'NNTPS_Set');
		@_NNTPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'NNTPS_Get');
		@_NNTPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'NNTPS_GetLastError');
		@_NNTPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'NNTPS_CheckIndex');
		@_NNTPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'NNTPS_Do');
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
  @_NNTPS_Create       := nil;
  @_NNTPS_Destroy      := nil;
  @_NNTPS_Set          := nil;
  @_NNTPS_Get          := nil;
  @_NNTPS_GetLastError := nil;
  @_NNTPS_CheckIndex   := nil;
  @_NNTPS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




