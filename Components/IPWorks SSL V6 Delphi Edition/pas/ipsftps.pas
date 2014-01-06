
unit ipsftps;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipsftpsFirewallTypes = 
(

									 
                   fwNone,

									 
                   fwTunnel,

									 
                   fwSOCKS4,

									 
                   fwSOCKS5
);
  TipsftpsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipsftpsSSLStartModes = 
(

									 
                   sslAutomatic,

									 
                   sslImplicit,

									 
                   sslExplicit,

									 
                   sslNone
);
  TipsftpsTransferModes = 
(

									 
                   tmDefault,

									 
                   tmASCII,

									 
                   tmBinary
);


  TConnectionStatusEvent = procedure(Sender: TObject;
                            const ConnectionEvent: String;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TDirListEvent = procedure(Sender: TObject;
                            const DirEntry: String;
                            const FileName: String;
                            IsDir: Boolean;
                            FileSize: LongInt;
                            const FileTime: String) of Object;

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
                            BytesTransferred: LongInt;
                            Text: String) of Object;
{$IFDEF CLR}
  TTransferEventB = procedure(Sender: TObject;
                            BytesTransferred: LongInt;
                            Text: Array of Byte) of Object;

{$ENDIF}

{$IFDEF CLR}
  TFTPSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsFTPS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsFTPS = class(TipsCore)
    public
      FOnConnectionStatus: TConnectionStatusEvent;

      FOnDirList: TDirListEvent;

      FOnEndTransfer: TEndTransferEvent;

      FOnError: TErrorEvent;

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
      m_anchor: TFTPSEventHook;
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

      function get_FileSize: Integer;


      function get_FileTime: String;


      function get_RemotePort: Integer;
      procedure set_RemotePort(valRemotePort: Integer);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);

      function get_StartByte: String;
      procedure set_StartByte(valStartByte: String);


      procedure TreatErr(Err: integer; const desc: string);


      function get_Account: String;
      procedure set_Account(valAccount: String);









      function get_FirewallHost: String;
      procedure set_FirewallHost(valFirewallHost: String);

      function get_FirewallPassword: String;
      procedure set_FirewallPassword(valFirewallPassword: String);

      function get_FirewallPort: Integer;
      procedure set_FirewallPort(valFirewallPort: Integer);

      function get_FirewallType: TipsftpsFirewallTypes;
      procedure set_FirewallType(valFirewallType: TipsftpsFirewallTypes);

      function get_FirewallUser: String;
      procedure set_FirewallUser(valFirewallUser: String);

      function get_Idle: Boolean;


      function get_LastReply: String;


      function get_LocalFile: String;
      procedure set_LocalFile(valLocalFile: String);

      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);

      function get_Overwrite: Boolean;
      procedure set_Overwrite(valOverwrite: Boolean);

      function get_Passive: Boolean;
      procedure set_Passive(valPassive: Boolean);

      function get_Password: String;
      procedure set_Password(valPassword: String);

      function get_RemoteFile: String;
      procedure set_RemoteFile(valRemoteFile: String);

      function get_RemoteHost: String;
      procedure set_RemoteHost(valRemoteHost: String);

      function get_RemotePath: String;
      procedure set_RemotePath(valRemotePath: String);



      function get_SSLAcceptServerCert: String;
      procedure set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipsftpsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipsftpsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLServerCert: String;


      function get_SSLServerCertStatus: String;


      function get_SSLStartMode: TipsftpsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipsftpsSSLStartModes);



      function get_Timeout: Integer;
      procedure set_Timeout(valTimeout: Integer);

      function get_TransferMode: TipsftpsTransferModes;
      procedure set_TransferMode(valTransferMode: TipsftpsTransferModes);

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

      property FileSize: Integer
               read get_FileSize
               ;

      property FileTime: String
               read get_FileTime
               ;































      property RemotePort: Integer
               read get_RemotePort
               write set_RemotePort               ;



      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;















      property StartByte: String
               read get_StartByte
               write set_StartByte               ;









{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure Abort();

      procedure Append();

      procedure DeleteFile(FileName: String);

      procedure DoEvents();

      procedure Download();

      procedure Interrupt();

      procedure ListDirectory();

      procedure ListDirectoryLong();

      procedure Logoff();

      procedure Logon();

      procedure MakeDirectory(NewDir: String);

      procedure RemoveDirectory(DirName: String);

      procedure RenameFile(NewName: String);

      procedure StoreUnique();

      procedure Upload();


{$ENDIF}

    published

      property Account: String
                   read get_Account
                   write set_Account
                   
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
      property FirewallType: TipsftpsFirewallTypes
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
      property Overwrite: Boolean
                   read get_Overwrite
                   write set_Overwrite
                   default false
                   ;
      property Passive: Boolean
                   read get_Passive
                   write set_Passive
                   default false
                   ;
      property Password: String
                   read get_Password
                   write set_Password
                   
                   ;
      property RemoteFile: String
                   read get_RemoteFile
                   write set_RemoteFile
                   
                   ;
      property RemoteHost: String
                   read get_RemoteHost
                   write set_RemoteHost
                   
                   ;
      property RemotePath: String
                   read get_RemotePath
                   write set_RemotePath
                   
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
      property SSLCertStoreType: TipsftpsSSLCertStoreTypes
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
      property SSLStartMode: TipsftpsSSLStartModes
                   read get_SSLStartMode
                   write set_SSLStartMode
                   default sslAutomatic
                   ;

      property Timeout: Integer
                   read get_Timeout
                   write set_Timeout
                   default 60
                   ;
      property TransferMode: TipsftpsTransferModes
                   read get_TransferMode
                   write set_TransferMode
                   default tmDefault
                   ;
      property User: String
                   read get_User
                   write set_User
                   
                   ;


      property OnConnectionStatus: TConnectionStatusEvent read FOnConnectionStatus write FOnConnectionStatus;

      property OnDirList: TDirListEvent read FOnDirList write FOnDirList;

      property OnEndTransfer: TEndTransferEvent read FOnEndTransfer write FOnEndTransfer;

      property OnError: TErrorEvent read FOnError write FOnError;

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
    PID_FTPS_Account = 1;
    PID_FTPS_Command = 2;
    PID_FTPS_Connected = 3;
    PID_FTPS_FileSize = 4;
    PID_FTPS_FileTime = 5;
    PID_FTPS_FirewallHost = 6;
    PID_FTPS_FirewallPassword = 7;
    PID_FTPS_FirewallPort = 8;
    PID_FTPS_FirewallType = 9;
    PID_FTPS_FirewallUser = 10;
    PID_FTPS_Idle = 11;
    PID_FTPS_LastReply = 12;
    PID_FTPS_LocalFile = 13;
    PID_FTPS_LocalHost = 14;
    PID_FTPS_Overwrite = 15;
    PID_FTPS_Passive = 16;
    PID_FTPS_Password = 17;
    PID_FTPS_RemoteFile = 18;
    PID_FTPS_RemoteHost = 19;
    PID_FTPS_RemotePath = 20;
    PID_FTPS_RemotePort = 21;
    PID_FTPS_SSLAcceptServerCert = 22;
    PID_FTPS_SSLCertEncoded = 23;
    PID_FTPS_SSLCertStore = 24;
    PID_FTPS_SSLCertStorePassword = 25;
    PID_FTPS_SSLCertStoreType = 26;
    PID_FTPS_SSLCertSubject = 27;
    PID_FTPS_SSLServerCert = 28;
    PID_FTPS_SSLServerCertStatus = 29;
    PID_FTPS_SSLStartMode = 30;
    PID_FTPS_StartByte = 31;
    PID_FTPS_Timeout = 32;
    PID_FTPS_TransferMode = 33;
    PID_FTPS_User = 34;

    EID_FTPS_ConnectionStatus = 1;
    EID_FTPS_DirList = 2;
    EID_FTPS_EndTransfer = 3;
    EID_FTPS_Error = 4;
    EID_FTPS_PITrail = 5;
    EID_FTPS_SSLServerAuthentication = 6;
    EID_FTPS_SSLStatus = 7;
    EID_FTPS_StartTransfer = 8;
    EID_FTPS_Transfer = 9;


    MID_FTPS_Config = 1;
    MID_FTPS_Abort = 2;
    MID_FTPS_Append = 3;
    MID_FTPS_DeleteFile = 4;
    MID_FTPS_DoEvents = 5;
    MID_FTPS_Download = 6;
    MID_FTPS_Interrupt = 7;
    MID_FTPS_ListDirectory = 8;
    MID_FTPS_ListDirectoryLong = 9;
    MID_FTPS_Logoff = 10;
    MID_FTPS_Logon = 11;
    MID_FTPS_MakeDirectory = 12;
    MID_FTPS_RemoveDirectory = 13;
    MID_FTPS_RenameFile = 14;
    MID_FTPS_StoreUnique = 15;
    MID_FTPS_Upload = 16;




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
{$R 'ipsftps.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsFTPS; event_id: Integer; cparam: Integer; 
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
  _FTPS_Create:        function(pMethod: PEventHandle; pObject: TipsFTPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _FTPS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _FTPS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _FTPS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _FTPS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _FTPS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _FTPS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _FTPS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Create')]
  function _FTPS_Create       (pMethod: TFTPSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Destroy')]
  function _FTPS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Set')]
  function _FTPS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Set')]
  function _FTPS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Set')]
  function _FTPS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Set')]
  function _FTPS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Set')]
  function _FTPS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Set')]
  function _FTPS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Get')]
  function _FTPS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Get')]
  function _FTPS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Get')]
  function _FTPS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Get')]
  function _FTPS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Get')]
  function _FTPS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Get')]
  function _FTPS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_GetLastError')]
  function _FTPS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_StaticInit')]
  function _FTPS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_CheckIndex')]
  function _FTPS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'FTPS_Do')]
  function _FTPS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _FTPS_Create       (pMethod: PEventHandle; pObject: TipsFTPS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'FTPS_Create';
  function _FTPS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'FTPS_Destroy';
  function _FTPS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'FTPS_Set';
  function _FTPS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'FTPS_Get';
  function _FTPS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'FTPS_GetLastError';
  function _FTPS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'FTPS_StaticInit';
  function _FTPS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'FTPS_CheckIndex';
  function _FTPS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'FTPS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsFTPS; event_id: Integer;
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
    tmp_DirListDirEntry: String;
    tmp_DirListFileName: String;
    tmp_DirListIsDir: Boolean;
    tmp_DirListFileSize: LongInt;
    tmp_DirListFileTime: String;
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

      EID_FTPS_ConnectionStatus:
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
      EID_FTPS_DirList:
      begin
        if Assigned(lpContext.FOnDirList) then
        begin
          {assign temporary variables}
          tmp_DirListDirEntry := AnsiString(PChar(params^[0]));

          tmp_DirListFileName := AnsiString(PChar(params^[1]));

          tmp_DirListIsDir := Boolean(params^[2]);
          tmp_DirListFileSize := LongInt(params^[3]);
          tmp_DirListFileTime := AnsiString(PChar(params^[4]));


          lpContext.FOnDirList(lpContext, tmp_DirListDirEntry, tmp_DirListFileName, tmp_DirListIsDir, tmp_DirListFileSize, tmp_DirListFileTime);






        end;
      end;
      EID_FTPS_EndTransfer:
      begin
        if Assigned(lpContext.FOnEndTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnEndTransfer(lpContext);

        end;
      end;
      EID_FTPS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_FTPS_PITrail:
      begin
        if Assigned(lpContext.FOnPITrail) then
        begin
          {assign temporary variables}
          tmp_PITrailDirection := Integer(params^[0]);
          tmp_PITrailMessage := AnsiString(PChar(params^[1]));


          lpContext.FOnPITrail(lpContext, tmp_PITrailDirection, tmp_PITrailMessage);



        end;
      end;
      EID_FTPS_SSLServerAuthentication:
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
      EID_FTPS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusMessage := AnsiString(PChar(params^[0]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


        end;
      end;
      EID_FTPS_StartTransfer:
      begin
        if Assigned(lpContext.FOnStartTransfer) then
        begin
          {assign temporary variables}

          lpContext.FOnStartTransfer(lpContext);

        end;
      end;
      EID_FTPS_Transfer:
      begin
        if Assigned(lpContext.FOnTransfer) then
        begin
          {assign temporary variables}
          tmp_TransferBytesTransferred := LongInt(params^[0]);
          SetString(tmp_TransferText, PChar(params^[1]), cbparam^[1]);


          lpContext.FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText);



        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsFTPS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectionStatusConnectionEvent: String;
  tmp_ConnectionStatusStatusCode: Integer;
  tmp_ConnectionStatusDescription: String;

  tmp_DirListDirEntry: String;
  tmp_DirListFileName: String;
  tmp_DirListIsDir: Boolean;
  tmp_DirListFileSize: LongInt;
  tmp_DirListFileTime: String;


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
  tmp_TransferText: String;

  tmp_TransferTextB: Array of Byte;

begin
 	p := nil;
  case event_id of
    EID_FTPS_ConnectionStatus:
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
    EID_FTPS_DirList:
    begin
      if Assigned(FOnDirList) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DirListDirEntry := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_DirListFileName := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        if Marshal.ReadInt32(params, 4*2) <> 0 then tmp_DirListIsDir := true else tmp_DirListIsDir := false;

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_DirListFileSize := Marshal.ReadInt32(params, 4*3);
				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_DirListFileTime := Marshal.PtrToStringAnsi(p);


        FOnDirList(lpContext, tmp_DirListDirEntry, tmp_DirListFileName, tmp_DirListIsDir, tmp_DirListFileSize, tmp_DirListFileTime);






      end;


    end;
    EID_FTPS_EndTransfer:
    begin
      if Assigned(FOnEndTransfer) then
      begin
        {assign temporary variables}

        FOnEndTransfer(lpContext);

      end;


    end;
    EID_FTPS_Error:
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
    EID_FTPS_PITrail:
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
    EID_FTPS_SSLServerAuthentication:
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
    EID_FTPS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusMessage);


      end;


    end;
    EID_FTPS_StartTransfer:
    begin
      if Assigned(FOnStartTransfer) then
      begin
        {assign temporary variables}

        FOnStartTransfer(lpContext);

      end;


    end;
    EID_FTPS_Transfer:
    begin
      if Assigned(FOnTransfer) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_TransferBytesTransferred := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_TransferText := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*1));


        FOnTransfer(lpContext, tmp_TransferBytesTransferred, tmp_TransferText);



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


        FOnTransferB(lpContext, tmp_TransferBytesTransferred, tmp_TransferTextB);



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
    RegisterComponents('IP*Works! SSL', [TipsFTPS]);
end;

constructor TipsFTPS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _FTPS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_FTPS_Create <> nil then
      m_ctl := _FTPS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL FTPS: Error creating component');

{$IFDEF CLR}
    _FTPS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_17, 0);
{$ELSE}
    _FTPS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_17)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_FTPS_Do <> nil then
      _FTPS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_Account('') except on E:Exception do end;
    try set_FirewallHost('') except on E:Exception do end;
    try set_FirewallPassword('') except on E:Exception do end;
    try set_FirewallPort(0) except on E:Exception do end;
    try set_FirewallType(fwNone) except on E:Exception do end;
    try set_FirewallUser('') except on E:Exception do end;
    try set_LocalFile('') except on E:Exception do end;
    try set_Overwrite(false) except on E:Exception do end;
    try set_Passive(false) except on E:Exception do end;
    try set_Password('') except on E:Exception do end;
    try set_RemoteFile('') except on E:Exception do end;
    try set_RemoteHost('') except on E:Exception do end;
    try set_RemotePath('') except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;
    try set_Timeout(60) except on E:Exception do end;
    try set_TransferMode(tmDefault) except on E:Exception do end;
    try set_User('') except on E:Exception do end;

end;

destructor TipsFTPS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_FTPS_Destroy <> nil then{$ENDIF}
      	_FTPS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsFTPS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsFTPS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsFTPS.AboutDlg;
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
	if @_FTPS_Do <> nil then
{$ENDIF}
		_FTPS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsFTPS.SetOK(key: String128);
begin
end;

function TipsFTPS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsFTPS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsFTPS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsFTPS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsFTPS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsFTPS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_FTPS_GetLastError <> nil then{$ENDIF}
      msg := _FTPS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsFTPS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_FTPS_Do <> nil then
      _FTPS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsFTPS.SetSSLAcceptServerCert(lpSSLAcceptServerCert: PChar; lenSSLAcceptServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_FTPS_Set = nil then exit;{$ENDIF}
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLAcceptServerCert, 0, Integer(lpSSLAcceptServerCert), lenSSLAcceptServerCert);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsFTPS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_FTPS_Set = nil then exit;{$ENDIF}
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsFTPS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_FTPS_Set = nil then exit;{$ENDIF}
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsFTPS.SetSSLServerCert(lpSSLServerCert: PChar; lenSSLServerCert: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_FTPS_Set = nil then exit;{$ENDIF}
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLServerCert, 0, Integer(lpSSLServerCert), lenSSLServerCert);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsFTPS.get_Account: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_Account, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_Account, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_Account(valAccount: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_Account, 0, valAccount, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_Account, 0, Integer(PChar(valAccount)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;


procedure TipsFTPS.set_Command(valCommand: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_Command, 0, valCommand, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_Command, 0, Integer(PChar(valCommand)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_Connected: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_FTPS_GetBOOL(m_ctl, PID_FTPS_Connected, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_Connected, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_Connected(valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetBOOL(m_ctl, PID_FTPS_Connected, 0, valConnected, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_Connected, 0, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_FileSize: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_FTPS_GetLONG(m_ctl, PID_FTPS_FileSize, 0, err));
{$ELSE}
  result := Integer(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_FileSize, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsFTPS.get_FileTime: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_FileTime, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_FileTime, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsFTPS.get_FirewallHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_FirewallHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_FirewallHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_FirewallHost(valFirewallHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_FirewallHost, 0, valFirewallHost, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_FirewallHost, 0, Integer(PChar(valFirewallHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_FirewallPassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_FirewallPassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_FirewallPassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_FirewallPassword(valFirewallPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_FirewallPassword, 0, valFirewallPassword, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_FirewallPassword, 0, Integer(PChar(valFirewallPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_FirewallPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_FTPS_GetLONG(m_ctl, PID_FTPS_FirewallPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_FirewallPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_FirewallPort(valFirewallPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetLONG(m_ctl, PID_FTPS_FirewallPort, 0, valFirewallPort, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_FirewallPort, 0, Integer(valFirewallPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_FirewallType: TipsftpsFirewallTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsftpsFirewallTypes(_FTPS_GetENUM(m_ctl, PID_FTPS_FirewallType, 0, err));
{$ELSE}
  result := TipsftpsFirewallTypes(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_FirewallType, 0, nil);
  result := TipsftpsFirewallTypes(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_FirewallType(valFirewallType: TipsftpsFirewallTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetENUM(m_ctl, PID_FTPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_FirewallType, 0, Integer(valFirewallType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_FirewallUser: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_FirewallUser, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_FirewallUser, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_FirewallUser(valFirewallUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_FirewallUser, 0, valFirewallUser, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_FirewallUser, 0, Integer(PChar(valFirewallUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_Idle: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_FTPS_GetBOOL(m_ctl, PID_FTPS_Idle, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_Idle, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsFTPS.get_LastReply: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_LastReply, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_LastReply, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsFTPS.get_LocalFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_LocalFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_LocalFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_LocalFile(valLocalFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_LocalFile, 0, valLocalFile, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_LocalFile, 0, Integer(PChar(valLocalFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_Overwrite: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_FTPS_GetBOOL(m_ctl, PID_FTPS_Overwrite, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_Overwrite, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_Overwrite(valOverwrite: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetBOOL(m_ctl, PID_FTPS_Overwrite, 0, valOverwrite, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_Overwrite, 0, Integer(valOverwrite), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_Passive: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_FTPS_GetBOOL(m_ctl, PID_FTPS_Passive, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_Passive, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_Passive(valPassive: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetBOOL(m_ctl, PID_FTPS_Passive, 0, valPassive, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_Passive, 0, Integer(valPassive), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_Password: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_Password, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_Password, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_Password(valPassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_Password, 0, valPassword, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_Password, 0, Integer(PChar(valPassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_RemoteFile: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_RemoteFile, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_RemoteFile, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_RemoteFile(valRemoteFile: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_RemoteFile, 0, valRemoteFile, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_RemoteFile, 0, Integer(PChar(valRemoteFile)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_RemoteHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_RemoteHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_RemoteHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_RemoteHost(valRemoteHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_RemoteHost, 0, valRemoteHost, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_RemoteHost, 0, Integer(PChar(valRemoteHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_RemotePath: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_RemotePath, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_RemotePath, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_RemotePath(valRemotePath: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_RemotePath, 0, valRemotePath, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_RemotePath, 0, Integer(PChar(valRemotePath)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_RemotePort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_FTPS_GetLONG(m_ctl, PID_FTPS_RemotePort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_RemotePort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_RemotePort(valRemotePort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetLONG(m_ctl, PID_FTPS_RemotePort, 0, valRemotePort, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_RemotePort, 0, Integer(valRemotePort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_SSLAcceptServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetBSTR(m_ctl, PID_FTPS_SSLAcceptServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLAcceptServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsFTPS.set_StringSSLAcceptServerCert(valSSLAcceptServerCert: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetBSTR(m_ctl, PID_FTPS_SSLAcceptServerCert, 0, valSSLAcceptServerCert, Length(valSSLAcceptServerCert));

{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLAcceptServerCert, 0, Integer(PChar(valSSLAcceptServerCert)), Length(valSSLAcceptServerCert));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetBSTR(m_ctl, PID_FTPS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsFTPS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetBSTR(m_ctl, PID_FTPS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetBSTR(m_ctl, PID_FTPS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsFTPS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetBSTR(m_ctl, PID_FTPS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_SSLCertStoreType: TipsftpsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsftpsSSLCertStoreTypes(_FTPS_GetENUM(m_ctl, PID_FTPS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipsftpsSSLCertStoreTypes(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLCertStoreType, 0, nil);
  result := TipsftpsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_SSLCertStoreType(valSSLCertStoreType: TipsftpsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetENUM(m_ctl, PID_FTPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_SSLServerCert: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetBSTR(m_ctl, PID_FTPS_SSLServerCert, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLServerCert, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;


function TipsFTPS.get_SSLServerCertStatus: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_SSLServerCertStatus, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLServerCertStatus, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsFTPS.get_SSLStartMode: TipsftpsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsftpsSSLStartModes(_FTPS_GetENUM(m_ctl, PID_FTPS_SSLStartMode, 0, err));
{$ELSE}
  result := TipsftpsSSLStartModes(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_SSLStartMode, 0, nil);
  result := TipsftpsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_SSLStartMode(valSSLStartMode: TipsftpsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetENUM(m_ctl, PID_FTPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_StartByte: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_StartByte, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_StartByte, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_StartByte(valStartByte: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_StartByte, 0, valStartByte, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_StartByte, 0, Integer(PChar(valStartByte)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_Timeout: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_FTPS_GetINT(m_ctl, PID_FTPS_Timeout, 0, err));
{$ELSE}
  result := Integer(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_Timeout, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_Timeout(valTimeout: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetINT(m_ctl, PID_FTPS_Timeout, 0, valTimeout, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_Timeout, 0, Integer(valTimeout), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_TransferMode: TipsftpsTransferModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsftpsTransferModes(_FTPS_GetENUM(m_ctl, PID_FTPS_TransferMode, 0, err));
{$ELSE}
  result := TipsftpsTransferModes(0);

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_TransferMode, 0, nil);
  result := TipsftpsTransferModes(tmp);
{$ENDIF}
end;
procedure TipsFTPS.set_TransferMode(valTransferMode: TipsftpsTransferModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetENUM(m_ctl, PID_FTPS_TransferMode, 0, Integer(valTransferMode), 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_TransferMode, 0, Integer(valTransferMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsFTPS.get_User: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _FTPS_GetCSTR(m_ctl, PID_FTPS_User, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_FTPS_Get = nil then exit;
  tmp := _FTPS_Get(m_ctl, PID_FTPS_User, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsFTPS.set_User(valUser: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _FTPS_SetCSTR(m_ctl, PID_FTPS_User, 0, valUser, 0);
{$ELSE}
	if @_FTPS_Set = nil then exit;
  err := _FTPS_Set(m_ctl, PID_FTPS_User, 0, Integer(PChar(valUser)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsFTPS.Config(ConfigurationString: String): String;
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


  err := _FTPS_Do(m_ctl, MID_FTPS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsFTPS.Abort();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_Abort, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_Abort, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.Append();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_Append, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_Append, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.DeleteFile(FileName: String);

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


  err := _FTPS_Do(m_ctl, MID_FTPS_DeleteFile, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(FileName);
  paramcb[i] := 0;

  i := i + 1;


	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_DeleteFile, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.DoEvents();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.Download();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_Download, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_Download, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.Interrupt();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_Interrupt, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_Interrupt, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.ListDirectory();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_ListDirectory, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_ListDirectory, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.ListDirectoryLong();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_ListDirectoryLong, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_ListDirectoryLong, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.Logoff();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_Logoff, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_Logoff, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.Logon();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_Logon, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_Logon, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.MakeDirectory(NewDir: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(NewDir);
  paramcb[i] := 0;

  i := i + 1;


  err := _FTPS_Do(m_ctl, MID_FTPS_MakeDirectory, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(NewDir);
  paramcb[i] := 0;

  i := i + 1;


	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_MakeDirectory, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.RemoveDirectory(DirName: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(DirName);
  paramcb[i] := 0;

  i := i + 1;


  err := _FTPS_Do(m_ctl, MID_FTPS_RemoveDirectory, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(DirName);
  paramcb[i] := 0;

  i := i + 1;


	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_RemoveDirectory, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.RenameFile(NewName: String);

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


  err := _FTPS_Do(m_ctl, MID_FTPS_RenameFile, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(NewName);
  paramcb[i] := 0;

  i := i + 1;


	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_RenameFile, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.StoreUnique();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_StoreUnique, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_StoreUnique, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsFTPS.Upload();

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



  err := _FTPS_Do(m_ctl, MID_FTPS_Upload, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_FTPS_Do = nil then exit;
  err := _FTPS_Do(m_ctl, MID_FTPS_Upload, 0, @param, @paramcb); 
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

	_FTPS_Create := nil;
	_FTPS_Destroy := nil;
	_FTPS_Set := nil;
	_FTPS_Get := nil;
	_FTPS_GetLastError := nil;
	_FTPS_StaticInit := nil;
	_FTPS_CheckIndex := nil;
	_FTPS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_ftps_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_FTPS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'FTPS_Create');
		@_FTPS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'FTPS_Destroy');
		@_FTPS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'FTPS_Set');
		@_FTPS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'FTPS_Get');
		@_FTPS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'FTPS_GetLastError');
		@_FTPS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'FTPS_CheckIndex');
		@_FTPS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'FTPS_Do');
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
  @_FTPS_Create       := nil;
  @_FTPS_Destroy      := nil;
  @_FTPS_Set          := nil;
  @_FTPS_Get          := nil;
  @_FTPS_GetLastError := nil;
  @_FTPS_CheckIndex   := nil;
  @_FTPS_Do           := nil;
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




