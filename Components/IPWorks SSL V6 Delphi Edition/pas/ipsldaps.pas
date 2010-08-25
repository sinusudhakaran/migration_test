
unit ipsldaps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipsldapsAttrModOps = 
(

									 
                   amoAdd,

									 
                   amoDelete,

									 
                   amoReplace
);
  TipsldapsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipsldapsSearchDerefAliases = 
(

									 
                   sdaNever,

									 
                   sdaInSearching,

									 
                   sdaFindingBaseObject,

									 
                   sdaAlways
);
  TipsldapsSearchScopes = 
(

									 
                   ssBaseObject,

									 
                   ssSingleLevel,

									 
                   ssWholeSubtree
);
  TipsldapsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipsldapsSSLStartModes = 
(

									 
                   sslAutomatic,

									 
                   sslImplicit,

									 
                   sslExplicit,

									 
                   sslNone
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

  TExtendedResponseEvent = procedure(Sender: TObject;
                            MessageId: Integer;
                            const DN: String;
                            ResultCode: Integer;
                            const Description: String;
                            const ResponseName: String;
                            ResponseValue: String) of Object;
{$IFDEF CLR}
  TExtendedResponseEventB = procedure(Sender: TObject;
                            MessageId: Integer;
                            const DN: String;
                            ResultCode: Integer;
                            const Description: String;
                            const ResponseName: String;
                            ResponseValue: Array of Byte) of Object;

{$ENDIF}
  TResultEvent = procedure(Sender: TObject;
                            MessageId: Integer;
                            const DN: String;
                            ResultCode: Integer;
                            const Description: String) of Object;

  TSearchCompleteEvent = procedure(Sender: TObject;
                            MessageId: Integer;
                            const DN: String;
                            ResultCode: Integer;
                            const Description: String) of Object;

  TSearchPageEvent = procedure(Sender: TObject;
                            MessageId: Integer;
                            const DN: String;
                            ResultCode: Integer;
                            const Description: String;
                           var  CancelSearch: Boolean) of Object;

  TSearchResultEvent = procedure(Sender: TObject;
                            MessageId: Integer;
                            const DN: String) of Object;

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
  TLDAPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsLDAPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsLDAPS = class(TipsCore)
    public
      FOnConnected: TConnectedEvent;

      FOnConnectionStatus: TConnectionStatusEvent;

      FOnDisconnected: TDisconnectedEvent;

      FOnError: TErrorEvent;

      FOnExtendedResponse: TExtendedResponseEvent;
			{$IFDEF CLR}FOnExtendedResponseB: TExtendedResponseEventB;{$ENDIF}
      FOnResult: TResultEvent;

      FOnSearchComplete: TSearchCompleteEvent;

      FOnSearchPage: TSearchPageEvent;

      FOnSearchResult: TSearchResultEvent;

      FOnSSLServerAuthentication: TSSLServerAuthenticationEvent;
			{$IFDEF CLR}FOnSSLServerAuthenticationB: TSSLServerAuthenticationEventB;{$ENDIF}
      FOnSSLStatus: TSSLStatusEvent;


    private
      tmp_SearchPageCancelSearch: Boolean;
      tmp_SSLServerAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TLDAPSEventHook;
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

      function get_AttrCount: Integer;
      procedure set_AttrCount(valAttrCount: Integer);

      function get_AttrModOp(AttrIndex: Word): TipsldapsAttrModOps;
      procedure set_AttrModOp(AttrIndex: Word; valAttrModOp: TipsldapsAttrModOps);

      function get_AttrType(AttrIndex: Word): String;
      procedure set_AttrType(AttrIndex: Word; valAttrType: String);

      function get_AttrValue(AttrIndex: Word): String;
      procedure set_StringAttrValue(AttrIndex: Word; valAttrValue: String);

      function get_Connected: Boolean;
      procedure set_Connected(valConnected: Boolean);

      function get_DeleteOldRDN: Boolean;
      procedure set_DeleteOldRDN(valDeleteOldRDN: Boolean);

      function get_LDAPVersion: Integer;
      procedure set_LDAPVersion(valLDAPVersion: Integer);

      function get_MessageId: Integer;
      procedure set_MessageId(valMessageId: Integer);

      function get_Password: String;
      procedure set_Password(valPassword: String);

      function get_ServerPort: Integer;
      procedure set_ServerPort(valServerPort: Integer);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);


      procedure TreatErr(Err: integer; const desc: string);
















      function get_DN: String;
      procedure set_DN(valDN: String);

      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipsldapsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipsldapsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_Idle: Boolean;




      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);



      function get_PageSize: Integer;
      procedure set_PageSize(valPageSize: Integer);



      function get_ResultCode: Integer;


      function get_ResultDescription: String;


      function get_ResultDN: String;


      function get_SearchDerefAliases: TipsldapsSearchDerefAliases;
      procedure set_SearchDerefAliases(valSearchDerefAliases: TipsldapsSearchDerefAliases);

      function get_SearchReturnValues: Boolean;
      procedure set_SearchReturnValues(valSearchReturnValues: Boolean);

      function get_SearchScope: TipsldapsSearchScopes;
      procedure set_SearchScope(valSearchScope: TipsldapsSearchScopes);

      function get_SearchSizeLimit: Integer;
      procedure set_SearchSizeLimit(valSearchSizeLimit: Integer);

      function get_SearchTimeLimit: Integer;
      procedure set_SearchTimeLimit(valSearchTimeLimit: Integer);

      function get_ServerName: String;
      procedure set_ServerName(valServerName: String);



      function get_SortAttributes: String;
      procedure set_SortAttributes(valSortAttributes: String);

      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipsldapsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipsldapsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipsldapsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipsldapsSSLStartModes);

      function get_Timeout: Integer;
      procedure set_Timeout(valTimeout: Integer);



    public

      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      property OK: String128 read GetOK write SetOK;

{$IFNDEF CLR}
      procedure SetAttrValue(AttrIndex: Word; lpAttrValue: PChar; lenAttrValue: Cardinal);
      procedure SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
      procedure SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
      procedure SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
      procedure SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);

{$ENDIF}

      property AcceptData: Boolean
               read get_AcceptData
               write set_AcceptData               ;

      property AttrCount: Integer
               read get_AttrCount
               write set_AttrCount               ;

      property AttrModOp[AttrIndex: Word]: TipsldapsAttrModOps
               read get_AttrModOp
               write set_AttrModOp               ;

      property AttrType[AttrIndex: Word]: String
               read get_AttrType
               write set_AttrType               ;

      property AttrValue[AttrIndex: Word]: String
               read get_AttrValue
               write set_StringAttrValue               ;

      property Connected: Boolean
               read get_Connected
               write set_Connected               ;

      property DeleteOldRDN: Boolean
               read get_DeleteOldRDN
               write set_DeleteOldRDN               ;















      property LDAPVersion: Integer
               read get_LDAPVersion
               write set_LDAPVersion               ;



      property MessageId: Integer
               read get_MessageId
               write set_MessageId               ;



      property Password: String
               read get_Password
               write set_Password               ;



















      property ServerPort: Integer
               read get_ServerPort
               write set_ServerPort               ;





      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;



















{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure Abandon(MessageId: Integer);

      procedure Add();

      procedure Bind();

      procedure Compare();

      procedure Delete();

      procedure DoEvents();

      procedure ExtendedRequest(RequestName: String; RequestValue: String);

      procedure Interrupt();

      procedure Modify();

      procedure ModifyRDN(NewRDN: String);

      procedure Search(SearchFilter: String);

      procedure Unbind();


{$ENDIF}

    published








      property DN: String
                   read get_DN
                   write set_DN
                   
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
      property FirewallType: TipsldapsFirewallTypes
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

      property LocalHost: String
                   read get_LocalHost
                   write set_LocalHost
                   stored False

                   ;

      property PageSize: Integer
                   read get_PageSize
                   write set_PageSize
                   default 0
                   ;

      property ResultCode: Integer
                   read get_ResultCode
                    write SetNoopInteger
                   stored False

                   ;
      property ResultDescription: String
                   read get_ResultDescription
                    write SetNoopString
                   stored False

                   ;
      property ResultDN: String
                   read get_ResultDN
                    write SetNoopString
                   stored False

                   ;
      property SearchDerefAliases: TipsldapsSearchDerefAliases
                   read get_SearchDerefAliases
                   write set_SearchDerefAliases
                   default sdaNever
                   ;
      property SearchReturnValues: Boolean
                   read get_SearchReturnValues
                   write set_SearchReturnValues
                   default True
                   ;
      property SearchScope: TipsldapsSearchScopes
                   read get_SearchScope
                   write set_SearchScope
                   default ssWholeSubtree
                   ;
      property SearchSizeLimit: Integer
                   read get_SearchSizeLimit
                   write set_SearchSizeLimit
                   default 0
                   ;
      property SearchTimeLimit: Integer
                   read get_SearchTimeLimit
                   write set_SearchTimeLimit
                   default 0
                   ;
      property ServerName: String
                   read get_ServerName
                   write set_ServerName
                   
                   ;

      property SortAttributes: String
                   read get_SortAttributes
                   write set_SortAttributes
                   
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
      property SSLCertStoreType: TipsldapsSSLCertStoreTypes
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
      property SSLStartMode: TipsldapsSSLStartModes
                   read get_SSLStartMode
                   write set_SSLStartMode
                   default sslAutomatic
                   ;
      property Timeout: Integer
                   read get_Timeout
                   write set_Timeout
                   default 60
                   ;


      property OnConnected: TConnectedEvent read FOnConnected write FOnConnected;

      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnDisconnected: TDisconnectedEvent read FOnDisconnected write FOnDisconnected;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnExtendedResponse: TExtendedResponseEvent read FOnExtendedResponse write FOnExtendedResponse;
			{$IFDEF CLR}property OnExtendedResponseB: TExtendedResponseEventB read FOnExtendedResponseB write FOnExtendedResponseB;{$ENDIF}
      property OnResult: TResultEvent read FOnResult write FOnResult;

      property OnSearchComplete: TSearchCompleteEvent read FOnSearchComplete write FOnSearchComplete;

      property OnSearchPage: TSearchPageEvent read FOnSearchPage write FOnSearchPage;

      property OnSearchResult: TSearchResultEvent read FOnSearchResult write FOnSearchResult;

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
    PID_LDAPS_AcceptData = 1;
    PID_LDAPS_AttrCount = 2;
    PID_LDAPS_AttrModOp = 3;
    PID_LDAPS_AttrType = 4;
    PID_LDAPS_AttrValue = 5;
    PID_LDAPS_Connected = 6;
    PID_LDAPS_DeleteOldRDN = 7;
    PID_LDAPS_DN = 8;
    PID_LDAPS_FirewallHost = 9;
    PID_LDAPS_FirewallPassword = 10;
    PID_LDAPS_FirewallPort = 11;
    PID_LDAPS_FirewallType = 12;
    PID_LDAPS_FirewallUser = 13;
    PID_LDAPS_Idle = 14;
    PID_LDAPS_LDAPVersion = 15;
    PID_LDAPS_LocalHost = 16;
    PID_LDAPS_MessageId = 17;
    PID_LDAPS_PageSize = 18;
    PID_LDAPS_Password = 19;
    PID_LDAPS_ResultCode = 20;
    PID_LDAPS_ResultDescription = 21;
    PID_LDAPS_ResultDN = 22;
    PID_LDAPS_SearchDerefAliases = 23;
    PID_LDAPS_SearchReturnValues = 24;
    PID_LDAPS_SearchScope = 25;
    PID_LDAPS_SearchSizeLimit = 26;
    PID_LDAPS_SearchTimeLimit = 27;
    PID_LDAPS_ServerName = 28;
    PID_LDAPS_ServerPort = 29;
    PID_LDAPS_SortAttributes = 30;
    PID_LDAPS_SSLAcceptServerCert = 31;
    PID_LDAPS_SSLCertEncoded = 32;
    PID_LDAPS_SSLCertStore = 33;
    PID_LDAPS_SSLCertStorePassword = 34;
    PID_LDAPS_SSLCertStoreType = 35;
    PID_LDAPS_SSLCertSubject = 36;
    PID_LDAPS_SSLServerCert = 37;
    PID_LDAPS_SSLServerCertStatus = 38;
    PID_LDAPS_SSLStartMode = 39;
    PID_LDAPS_Timeout = 40;

    EID_LDAPS_Connected = 1;
    EID_LDAPS_ConnectionStatus = 2;
    EID_LDAPS_Disconnected = 3;
    EID_LDAPS_Error = 4;
    EID_LDAPS_ExtendedResponse = 5;
    EID_LDAPS_Result = 6;
    EID_LDAPS_SearchComplete = 7;
    EID_LDAPS_SearchPage = 8;
    EID_LDAPS_SearchResult = 9;
    EID_LDAPS_SSLServerAuthentication = 10;
    EID_LDAPS_SSLStatus = 11;


    MID_LDAPS_Config = 1;
    MID_LDAPS_Abandon = 2;
    MID_LDAPS_Add = 3;
    MID_LDAPS_Bind = 4;
    MID_LDAPS_Compare = 5;
    MID_LDAPS_Delete = 6;
    MID_LDAPS_DoEvents = 7;
    MID_LDAPS_ExtendedRequest = 8;
    MID_LDAPS_Interrupt = 9;
    MID_LDAPS_Modify = 10;
    MID_LDAPS_ModifyRDN = 11;
    MID_LDAPS_Search = 12;
    MID_LDAPS_Unbind = 13;




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
{$R 'ipsldaps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsLDAPS; event_id: Integer; cparam: Integer; 
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
  _LDAPS_Create:        function(pMethod: PEventHandle; pObject: TipsLDAPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _LDAPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _LDAPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _LDAPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _LDAPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _LDAPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _LDAPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _LDAPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Create')]
  function _LDAPS_Create       (pMethod: TLDAPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Destroy')]
  function _LDAPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Set')]
  function _LDAPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Set')]
  function _LDAPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Set')]
  function _LDAPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Set')]
  function _LDAPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Set')]
  function _LDAPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Set')]
  function _LDAPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Get')]
  function _LDAPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Get')]
  function _LDAPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Get')]
  function _LDAPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Get')]
  function _LDAPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Get')]
  function _LDAPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Get')]
  function _LDAPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_GetLastError')]
  function _LDAPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_StaticInit')]
  function _LDAPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_CheckIndex')]
  function _LDAPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'LDAPS_Do')]
  function _LDAPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _LDAPS_Create       (pMethod: PEventHandle; pObject: TipsLDAPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'LDAPS_Create';
  function _LDAPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'LDAPS_Destroy';
  function _LDAPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'LDAPS_Set';
  function _LDAPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'LDAPS_Get';
  function _LDAPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'LDAPS_GetLastError';
  function _LDAPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'LDAPS_StaticInit';
  function _LDAPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'LDAPS_CheckIndex';
  function _LDAPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'LDAPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsLDAPS; event_id: Integer;
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
    tmp_ExtendedResponseMessageId: Integer;
    tmp_ExtendedResponseDN: String;
    tmp_ExtendedResponseResultCode: Integer;
    tmp_ExtendedResponseDescription: String;
    tmp_ExtendedResponseResponseName: String;
    tmp_ExtendedResponseResponseValue: String;
    tmp_ResultMessageId: Integer;
    tmp_ResultDN: String;
    tmp_ResultResultCode: Integer;
    tmp_ResultDescription: String;
    tmp_SearchCompleteMessageId: Integer;
    tmp_SearchCompleteDN: String;
    tmp_SearchCompleteResultCode: Integer;
    tmp_SearchCompleteDescription: String;
    tmp_SearchPageMessageId: Integer;
    tmp_SearchPageDN: String;
    tmp_SearchPageResultCode: Integer;
    tmp_SearchPageDescription: String;
    tmp_SearchResultMessageId: Integer;
    tmp_SearchResultDN: String;
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

      EID_LDAPS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedStatusCode := Integer(params^[0]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedStatusCode, tmp_ConnectedDescription);



        end;
      end;
      EID_LDAPS_ConnectionStatus:
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
      EID_LDAPS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedStatusCode := Integer(params^[0]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);



        end;
      end;
      EID_LDAPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_LDAPS_ExtendedResponse:
      begin
        if Assigned(lpContext.FOnExtendedResponse) then
        begin
          {assign temporary variables}
          tmp_ExtendedResponseMessageId := Integer(params^[0]);
          tmp_ExtendedResponseDN := AnsiString(PChar(params^[1]));

          tmp_ExtendedResponseResultCode := Integer(params^[2]);
          tmp_ExtendedResponseDescription := AnsiString(PChar(params^[3]));

          tmp_ExtendedResponseResponseName := AnsiString(PChar(params^[4]));

          SetString(tmp_ExtendedResponseResponseValue, PChar(params^[5]), cbparam^[5]);


          lpContext.FOnExtendedResponse(lpContext, tmp_ExtendedResponseMessageId, tmp_ExtendedResponseDN, tmp_ExtendedResponseResultCode, tmp_ExtendedResponseDescription, tmp_ExtendedResponseResponseName, tmp_ExtendedResponseResponseValue);







        end;
      end;
      EID_LDAPS_Result:
      begin
        if Assigned(lpContext.FOnResult) then
        begin
          {assign temporary variables}
          tmp_ResultMessageId := Integer(params^[0]);
          tmp_ResultDN := AnsiString(PChar(params^[1]));

          tmp_ResultResultCode := Integer(params^[2]);
          tmp_ResultDescription := AnsiString(PChar(params^[3]));


          lpContext.FOnResult(lpContext, tmp_ResultMessageId, tmp_ResultDN, tmp_ResultResultCode, tmp_ResultDescription);





        end;
      end;
      EID_LDAPS_SearchComplete:
      begin
        if Assigned(lpContext.FOnSearchComplete) then
        begin
          {assign temporary variables}
          tmp_SearchCompleteMessageId := Integer(params^[0]);
          tmp_SearchCompleteDN := AnsiString(PChar(params^[1]));

          tmp_SearchCompleteResultCode := Integer(params^[2]);
          tmp_SearchCompleteDescription := AnsiString(PChar(params^[3]));


          lpContext.FOnSearchComplete(lpContext, tmp_SearchCompleteMessageId, tmp_SearchCompleteDN, tmp_SearchCompleteResultCode, tmp_SearchCompleteDescription);





        end;
      end;
      EID_LDAPS_SearchPage:
      begin
        if Assigned(lpContext.FOnSearchPage) then
        begin
          {assign temporary variables}
          tmp_SearchPageMessageId := Integer(params^[0]);
          tmp_SearchPageDN := AnsiString(PChar(params^[1]));

          tmp_SearchPageResultCode := Integer(params^[2]);
          tmp_SearchPageDescription := AnsiString(PChar(params^[3]));

          lpContext.tmp_SearchPageCancelSearch := Boolean(params^[4]);

          lpContext.FOnSearchPage(lpContext, tmp_SearchPageMessageId, tmp_SearchPageDN, tmp_SearchPageResultCode, tmp_SearchPageDescription, lpContext.tmp_SearchPageCancelSearch);




          params^[4] := Pointer(lpContext.tmp_SearchPageCancelSearch);


        end;
      end;
      EID_LDAPS_SearchResult:
      begin
        if Assigned(lpContext.FOnSearchResult) then
        begin
          {assign temporary variables}
          tmp_SearchResultMessageId := Integer(params^[0]);
          tmp_SearchResultDN := AnsiString(PChar(params^[1]));


          lpContext.FOnSearchResult(lpContext, tmp_SearchResultMessageId, tmp_SearchResultDN);



        end;
      end;
      EID_LDAPS_SSLServerAuthentication:
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
      EID_LDAPS_SSLStatus:
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
function TipsLDAPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
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

  tmp_ExtendedResponseMessageId: Integer;
  tmp_ExtendedResponseDN: String;
  tmp_ExtendedResponseResultCode: Integer;
  tmp_ExtendedResponseDescription: String;
  tmp_ExtendedResponseResponseName: String;
  tmp_ExtendedResponseResponseValue: String;

  tmp_ExtendedResponseResponseValueB: Array of Byte;
  tmp_ResultMessageId: Integer;
  tmp_ResultDN: String;
  tmp_ResultResultCode: Integer;
  tmp_ResultDescription: String;

  tmp_SearchCompleteMessageId: Integer;
  tmp_SearchCompleteDN: String;
  tmp_SearchCompleteResultCode: Integer;
  tmp_SearchCompleteDescription: String;

  tmp_SearchPageMessageId: Integer;
  tmp_SearchPageDN: String;
  tmp_SearchPageResultCode: Integer;
  tmp_SearchPageDescription: String;

  tmp_SearchResultMessageId: Integer;
  tmp_SearchResultDN: String;

  tmp_SSLServerAuthenticationCertEncoded: String;
  tmp_SSLServerAuthenticationCertSubject: String;
  tmp_SSLServerAuthenticationCertIssuer: String;
  tmp_SSLServerAuthenticationStatus: String;

  tmp_SSLServerAuthenticationCertEncodedB: Array of Byte;
  tmp_SSLStatusMessage: String;


begin
 	p := nil;
  case event_id of
    EID_LDAPS_Connected:
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
    EID_LDAPS_ConnectionStatus:
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
    EID_LDAPS_Disconnected:
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
    EID_LDAPS_Error:
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
    EID_LDAPS_ExtendedResponse:
    begin
      if Assigned(FOnExtendedResponse) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ExtendedResponseMessageId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_ExtendedResponseDN := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_ExtendedResponseResultCode := Marshal.ReadInt32(params, 4*2);
				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_ExtendedResponseDescription := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_ExtendedResponseResponseName := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        tmp_ExtendedResponseResponseValue := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*5));


        FOnExtendedResponse(lpContext, tmp_ExtendedResponseMessageId, tmp_ExtendedResponseDN, tmp_ExtendedResponseResultCode, tmp_ExtendedResponseDescription, tmp_ExtendedResponseResponseName, tmp_ExtendedResponseResponseValue);







      end;

      if Assigned(FOnExtendedResponseB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ExtendedResponseMessageId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_ExtendedResponseDN := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_ExtendedResponseResultCode := Marshal.ReadInt32(params, 4*2);
				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_ExtendedResponseDescription := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_ExtendedResponseResponseName := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        SetLength(tmp_ExtendedResponseResponseValueB, Marshal.ReadInt32(cbparam, 4 * 5)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 5), tmp_ExtendedResponseResponseValueB,
        						 0, Length(tmp_ExtendedResponseResponseValueB));


        FOnExtendedResponseB(lpContext, tmp_ExtendedResponseMessageId, tmp_ExtendedResponseDN, tmp_ExtendedResponseResultCode, tmp_ExtendedResponseDescription, tmp_ExtendedResponseResponseName, tmp_ExtendedResponseResponseValueB);







      end;
    end;
    EID_LDAPS_Result:
    begin
      if Assigned(FOnResult) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ResultMessageId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_ResultDN := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_ResultResultCode := Marshal.ReadInt32(params, 4*2);
				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_ResultDescription := Marshal.PtrToStringAnsi(p);


        FOnResult(lpContext, tmp_ResultMessageId, tmp_ResultDN, tmp_ResultResultCode, tmp_ResultDescription);





      end;


    end;
    EID_LDAPS_SearchComplete:
    begin
      if Assigned(FOnSearchComplete) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SearchCompleteMessageId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SearchCompleteDN := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_SearchCompleteResultCode := Marshal.ReadInt32(params, 4*2);
				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_SearchCompleteDescription := Marshal.PtrToStringAnsi(p);


        FOnSearchComplete(lpContext, tmp_SearchCompleteMessageId, tmp_SearchCompleteDN, tmp_SearchCompleteResultCode, tmp_SearchCompleteDescription);





      end;


    end;
    EID_LDAPS_SearchPage:
    begin
      if Assigned(FOnSearchPage) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SearchPageMessageId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SearchPageDN := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_SearchPageResultCode := Marshal.ReadInt32(params, 4*2);
				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_SearchPageDescription := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        if Marshal.ReadInt32(params, 4*4) <> 0 then tmp_SearchPageCancelSearch := true else tmp_SearchPageCancelSearch := false;


        FOnSearchPage(lpContext, tmp_SearchPageMessageId, tmp_SearchPageDN, tmp_SearchPageResultCode, tmp_SearchPageDescription, tmp_SearchPageCancelSearch);




        if tmp_SearchPageCancelSearch then Marshal.WriteInt32(params, 4*4, 1) else Marshal.WriteInt32(params, 4*4, 0);


      end;


    end;
    EID_LDAPS_SearchResult:
    begin
      if Assigned(FOnSearchResult) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SearchResultMessageId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SearchResultDN := Marshal.PtrToStringAnsi(p);


        FOnSearchResult(lpContext, tmp_SearchResultMessageId, tmp_SearchResultDN);



      end;


    end;
    EID_LDAPS_SSLServerAuthentication:
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
    EID_LDAPS_SSLStatus:
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
    RegisterComponents('IP*Works! SSL', [TipsLDAPS]);
end;

constructor TipsLDAPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _LDAPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_LDAPS_Create <> nil then
      m_ctl := _LDAPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL LDAPS: Error creating component');

{$IFDEF CLR}
    _LDAPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_33, 0);
{$ELSE}
    _LDAPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_33)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_LDAPS_Do <> nil then
      _LDAPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_DN('') except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_PageSize(0) except on E:Exception do end;
    try set_SearchDerefAliases(sdaNever) except on E:Exception do end;
    try set_SearchReturnValues(true) except on E:Exception do end;
    try set_SearchScope(ssWholeSubtree) except on E:Exception do end;
    try set_SearchSizeLimit(0) except on E:Exception do end;
    try set_SearchTimeLimit(0) except on E:Exception do end;
    try set_ServerName('') except on E:Exception do end;
    try set_SortAttributes('') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;

end;

destructor TipsLDAPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_LDAPS_Destroy <> nil then{$ENDIF}
      	_LDAPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsLDAPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsLDAPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsLDAPS.AboutDlg;
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
	if @_LDAPS_Do <> nil then
{$ENDIF}
		_LDAPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsLDAPS.SetOK(key: String128);
begin
end;

function TipsLDAPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsLDAPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsLDAPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsLDAPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsLDAPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsLDAPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_LDAPS_GetLastError <> nil then{$ENDIF}
      msg := _LDAPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsLDAPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_LDAPS_Do <> nil then
      _LDAPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsLDAPS.SetAttrValue(AttrIndex: Word; lpAttrValue: PChar; lenAttrValue: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_LDAPS_Set = nil then exit;{$ENDIF}
  err := _LDAPS_Set(m_ctl, PID_LDAPS_AttrValue, AttrIndex, Integer(lpAttrValue), lenAttrValue);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsLDAPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_LDAPS_Set = nil then exit;{$ENDIF}
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsLDAPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_LDAPS_Set = nil then exit;{$ENDIF}
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsLDAPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_LDAPS_Set = nil then exit;{$ENDIF}
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsLDAPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_LDAPS_Set = nil then exit;{$ENDIF}
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsLDAPS.get_AcceptData: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_LDAPS_GetBOOL(m_ctl, PID_LDAPS_AcceptData, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_AcceptData, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_AcceptData(valAcceptData: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetBOOL(m_ctl, PID_LDAPS_AcceptData, 0, valAcceptData, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_AcceptData, 0, Integer(valAcceptData), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_AttrCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetINT(m_ctl, PID_LDAPS_AttrCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_AttrCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_AttrCount(valAttrCount: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetINT(m_ctl, PID_LDAPS_AttrCount, 0, valAttrCount, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_AttrCount, 0, Integer(valAttrCount), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_AttrModOp(AttrIndex: Word): TipsldapsAttrModOps;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsldapsAttrModOps(_LDAPS_GetENUM(m_ctl, PID_LDAPS_AttrModOp, AttrIndex, err));
{$ELSE}
  result := TipsldapsAttrModOps(0);
  if @_LDAPS_CheckIndex = nil then exit;
  err :=  _LDAPS_CheckIndex(m_ctl, PID_LDAPS_AttrModOp, AttrIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for AttrModOp');
	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_AttrModOp, AttrIndex, nil);
  result := TipsldapsAttrModOps(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_AttrModOp(AttrIndex: Word; valAttrModOp: TipsldapsAttrModOps);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetENUM(m_ctl, PID_LDAPS_AttrModOp, AttrIndex, Integer(valAttrModOp), 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_AttrModOp, AttrIndex, Integer(valAttrModOp), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_AttrType(AttrIndex: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_AttrType, AttrIndex, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_LDAPS_CheckIndex = nil then exit;
  err :=  _LDAPS_CheckIndex(m_ctl, PID_LDAPS_AttrType, AttrIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for AttrType');
	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_AttrType, AttrIndex, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_AttrType(AttrIndex: Word; valAttrType: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_AttrType, AttrIndex, valAttrType, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_AttrType, AttrIndex, Integer(PChar(valAttrType)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_AttrValue(AttrIndex: Word): String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetBSTR(m_ctl, PID_LDAPS_AttrValue, AttrIndex, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_LDAPS_CheckIndex = nil then exit;
  err :=  _LDAPS_CheckIndex(m_ctl, PID_LDAPS_AttrValue, AttrIndex);
  if err <> 0 then TreatErr(err, 'Invalid array index value for AttrValue');
	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_AttrValue, AttrIndex, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsLDAPS.set_StringAttrValue(AttrIndex: Word; valAttrValue: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetBSTR(m_ctl, PID_LDAPS_AttrValue, AttrIndex, valAttrValue, Length(valAttrValue));

{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_AttrValue, AttrIndex, Integer(PChar(valAttrValue)), Length(valAttrValue));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_LDAPS_GetBOOL(m_ctl, PID_LDAPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetBOOL(m_ctl, PID_LDAPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_DeleteOldRDN: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_LDAPS_GetBOOL(m_ctl, PID_LDAPS_DeleteOldRDN, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_DeleteOldRDN, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_DeleteOldRDN(valDeleteOldRDN: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetBOOL(m_ctl, PID_LDAPS_DeleteOldRDN, 0, valDeleteOldRDN, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_DeleteOldRDN, 0, Integer(valDeleteOldRDN), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_DN: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_DN, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_DN, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_DN(valDN: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_DN, 0, valDN, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_DN, 0, Integer(PChar(valDN)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetLONG(m_ctl, PID_LDAPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetLONG(m_ctl, PID_LDAPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_FirewallType: TipsldapsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsldapsFirewallTypes(_LDAPS_GetENUM(m_ctl, PID_LDAPS_FirewallType, 0, err));
{$ELSE}
  result := TipsldapsFirewallTypes(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_FirewallType, 0, nil);
  result := TipsldapsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_FirewallType(valFirewallType: TipsldapsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetENUM(m_ctl, PID_LDAPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_LDAPS_GetBOOL(m_ctl, PID_LDAPS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsLDAPS.get_LDAPVersion: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetINT(m_ctl, PID_LDAPS_LDAPVersion, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_LDAPVersion, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_LDAPVersion(valLDAPVersion: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetINT(m_ctl, PID_LDAPS_LDAPVersion, 0, valLDAPVersion, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_LDAPVersion, 0, Integer(valLDAPVersion), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_MessageId: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetINT(m_ctl, PID_LDAPS_MessageId, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_MessageId, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_MessageId(valMessageId: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetINT(m_ctl, PID_LDAPS_MessageId, 0, valMessageId, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_MessageId, 0, Integer(valMessageId), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_PageSize: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetINT(m_ctl, PID_LDAPS_PageSize, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_PageSize, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_PageSize(valPageSize: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetINT(m_ctl, PID_LDAPS_PageSize, 0, valPageSize, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_PageSize, 0, Integer(valPageSize), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_ResultCode: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetINT(m_ctl, PID_LDAPS_ResultCode, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_ResultCode, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsLDAPS.get_ResultDescription: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_ResultDescription, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_ResultDescription, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsLDAPS.get_ResultDN: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_ResultDN, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_ResultDN, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsLDAPS.get_SearchDerefAliases: TipsldapsSearchDerefAliases;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsldapsSearchDerefAliases(_LDAPS_GetENUM(m_ctl, PID_LDAPS_SearchDerefAliases, 0, err));
{$ELSE}
  result := TipsldapsSearchDerefAliases(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SearchDerefAliases, 0, nil);
  result := TipsldapsSearchDerefAliases(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_SearchDerefAliases(valSearchDerefAliases: TipsldapsSearchDerefAliases);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetENUM(m_ctl, PID_LDAPS_SearchDerefAliases, 0, Integer(valSearchDerefAliases), 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SearchDerefAliases, 0, Integer(valSearchDerefAliases), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SearchReturnValues: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_LDAPS_GetBOOL(m_ctl, PID_LDAPS_SearchReturnValues, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SearchReturnValues, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_SearchReturnValues(valSearchReturnValues: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetBOOL(m_ctl, PID_LDAPS_SearchReturnValues, 0, valSearchReturnValues, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SearchReturnValues, 0, Integer(valSearchReturnValues), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SearchScope: TipsldapsSearchScopes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsldapsSearchScopes(_LDAPS_GetENUM(m_ctl, PID_LDAPS_SearchScope, 0, err));
{$ELSE}
  result := TipsldapsSearchScopes(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SearchScope, 0, nil);
  result := TipsldapsSearchScopes(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_SearchScope(valSearchScope: TipsldapsSearchScopes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetENUM(m_ctl, PID_LDAPS_SearchScope, 0, Integer(valSearchScope), 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SearchScope, 0, Integer(valSearchScope), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SearchSizeLimit: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetINT(m_ctl, PID_LDAPS_SearchSizeLimit, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SearchSizeLimit, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_SearchSizeLimit(valSearchSizeLimit: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetINT(m_ctl, PID_LDAPS_SearchSizeLimit, 0, valSearchSizeLimit, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SearchSizeLimit, 0, Integer(valSearchSizeLimit), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SearchTimeLimit: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetINT(m_ctl, PID_LDAPS_SearchTimeLimit, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SearchTimeLimit, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_SearchTimeLimit(valSearchTimeLimit: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetINT(m_ctl, PID_LDAPS_SearchTimeLimit, 0, valSearchTimeLimit, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SearchTimeLimit, 0, Integer(valSearchTimeLimit), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_ServerName: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_ServerName, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_ServerName, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_ServerName(valServerName: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_ServerName, 0, valServerName, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_ServerName, 0, Integer(PChar(valServerName)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_ServerPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetLONG(m_ctl, PID_LDAPS_ServerPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_ServerPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_ServerPort(valServerPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetLONG(m_ctl, PID_LDAPS_ServerPort, 0, valServerPort, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_ServerPort, 0, Integer(valServerPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SortAttributes: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_SortAttributes, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SortAttributes, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_SortAttributes(valSortAttributes: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_SortAttributes, 0, valSortAttributes, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SortAttributes, 0, Integer(PChar(valSortAttributes)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetBSTR(m_ctl, PID_LDAPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsLDAPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetBSTR(m_ctl, PID_LDAPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetBSTR(m_ctl, PID_LDAPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsLDAPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetBSTR(m_ctl, PID_LDAPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetBSTR(m_ctl, PID_LDAPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsLDAPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetBSTR(m_ctl, PID_LDAPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SSLCertStoreType: TipsldapsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsldapsSSLCertStoreTypes(_LDAPS_GetENUM(m_ctl, PID_LDAPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipsldapsSSLCertStoreTypes(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLCertStoreType, 0, nil);
  result := TipsldapsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_SSLCertStoreType(valSSLCertStoreType: TipsldapsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetENUM(m_ctl, PID_LDAPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsLDAPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetCSTR(m_ctl, PID_LDAPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetBSTR(m_ctl, PID_LDAPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsLDAPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _LDAPS_GetCSTR(m_ctl, PID_LDAPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsLDAPS.get_SSLStartMode: TipsldapsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsldapsSSLStartModes(_LDAPS_GetENUM(m_ctl, PID_LDAPS_SSLStartMode, 0, err));
{$ELSE}
  result := TipsldapsSSLStartModes(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_SSLStartMode, 0, nil);
  result := TipsldapsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_SSLStartMode(valSSLStartMode: TipsldapsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetENUM(m_ctl, PID_LDAPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsLDAPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_LDAPS_GetINT(m_ctl, PID_LDAPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_LDAPS_Get = nil then exit;
  tmp := _LDAPS_Get(m_ctl, PID_LDAPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsLDAPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _LDAPS_SetINT(m_ctl, PID_LDAPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_LDAPS_Set = nil then exit;
  err := _LDAPS_Set(m_ctl, PID_LDAPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsLDAPS.Config(ConfigurationString: String): String;
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


  err := _LDAPS_Do(m_ctl, MID_LDAPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsLDAPS.Abandon(MessageId: Integer);

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

  param[i] := IntPtr(MessageId);
  paramcb[i] := 0;
  i := i + 1;


  err := _LDAPS_Do(m_ctl, MID_LDAPS_Abandon, 1, param, paramcb); 




  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := Pointer(MessageId);
  paramcb[i] := 0;
  i := i + 1;


	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Abandon, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.Add();

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



  err := _LDAPS_Do(m_ctl, MID_LDAPS_Add, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Add, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.Bind();

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



  err := _LDAPS_Do(m_ctl, MID_LDAPS_Bind, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Bind, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.Compare();

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



  err := _LDAPS_Do(m_ctl, MID_LDAPS_Compare, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Compare, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.Delete();

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



  err := _LDAPS_Do(m_ctl, MID_LDAPS_Delete, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Delete, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.DoEvents();

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



  err := _LDAPS_Do(m_ctl, MID_LDAPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.ExtendedRequest(RequestName: String; RequestValue: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(RequestName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(RequestValue);
  paramcb[i] := Length(RequestValue);

  i := i + 1;


  err := _LDAPS_Do(m_ctl, MID_LDAPS_ExtendedRequest, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);


  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(RequestName);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(RequestValue);
  paramcb[i] := Length(RequestValue);

  i := i + 1;


	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_ExtendedRequest, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.Interrupt();

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



  err := _LDAPS_Do(m_ctl, MID_LDAPS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.Modify();

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



  err := _LDAPS_Do(m_ctl, MID_LDAPS_Modify, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Modify, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.ModifyRDN(NewRDN: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(NewRDN);
  paramcb[i] := 0;

  i := i + 1;


  err := _LDAPS_Do(m_ctl, MID_LDAPS_ModifyRDN, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(NewRDN);
  paramcb[i] := 0;

  i := i + 1;


	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_ModifyRDN, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.Search(SearchFilter: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(SearchFilter);
  paramcb[i] := 0;

  i := i + 1;


  err := _LDAPS_Do(m_ctl, MID_LDAPS_Search, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(SearchFilter);
  paramcb[i] := 0;

  i := i + 1;


	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Search, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsLDAPS.Unbind();

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



  err := _LDAPS_Do(m_ctl, MID_LDAPS_Unbind, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_LDAPS_Do = nil then exit;
  err := _LDAPS_Do(m_ctl, MID_LDAPS_Unbind, 0, @param, @paramcb); 
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

	_LDAPS_Create := nil;
	_LDAPS_Destroy := nil;
	_LDAPS_Set := nil;
	_LDAPS_Get := nil;
	_LDAPS_GetLastError := nil;
	_LDAPS_StaticInit := nil;
	_LDAPS_CheckIndex := nil;
	_LDAPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_ldaps_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_LDAPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'LDAPS_Create');
		@_LDAPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'LDAPS_Destroy');
		@_LDAPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'LDAPS_Set');
		@_LDAPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'LDAPS_Get');
		@_LDAPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'LDAPS_GetLastError');
		@_LDAPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'LDAPS_CheckIndex');
		@_LDAPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'LDAPS_Do');
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
  @_LDAPS_Create       := nil;
  @_LDAPS_Destroy      := nil;
  @_LDAPS_Set          := nil;
  @_LDAPS_Get          := nil;
  @_LDAPS_GetLastError := nil;
  @_LDAPS_CheckIndex   := nil;
  @_LDAPS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




