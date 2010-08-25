
unit ipsipdaemons;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipsipdaemonsSSLCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);
  TipsipdaemonsSSLStartModes = 
(

									 
                   sslAutomatic,

									 
                   sslImplicit,

									 
                   sslExplicit,

									 
                   sslNone
);


  TConnectedEvent = procedure(Sender: TObject;
                            ConnectionId: Integer;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TConnectionRequestEvent = procedure(Sender: TObject;
                           var  Accept: Boolean) of Object;

  TDataInEvent = procedure(Sender: TObject;
                            ConnectionId: Integer;
                            Text: String;
                            EOL: Boolean) of Object;
{$IFDEF CLR}
  TDataInEventB = procedure(Sender: TObject;
                            ConnectionId: Integer;
                            Text: Array of Byte;
                            EOL: Boolean) of Object;

{$ENDIF}
  TDisconnectedEvent = procedure(Sender: TObject;
                            ConnectionId: Integer;
                            StatusCode: Integer;
                            const Description: String) of Object;

  TErrorEvent = procedure(Sender: TObject;
                            ErrorCode: Integer;
                            const Description: String) of Object;

  TReadyToSendEvent = procedure(Sender: TObject;
                            ConnectionId: Integer) of Object;

  TSSLClientAuthenticationEvent = procedure(Sender: TObject;
                            ConnectionId: Integer;
                            CertEncoded: String;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const Status: String;
                           var  Accept: Boolean) of Object;
{$IFDEF CLR}
  TSSLClientAuthenticationEventB = procedure(Sender: TObject;
                            ConnectionId: Integer;
                            CertEncoded: Array of Byte;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const Status: String;
                           var  Accept: Boolean) of Object;

{$ENDIF}
  TSSLStatusEvent = procedure(Sender: TObject;
                            ConnectionId: Integer;
                            const Message: String) of Object;


{$IFDEF CLR}
  TIPDaemonSEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsIPDaemonS = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsIPDaemonS = class(TipsCore)
    public
      FOnConnected: TConnectedEvent;

      FOnConnectionRequest: TConnectionRequestEvent;

      FOnDataIn: TDataInEvent;
			{$IFDEF CLR}FOnDataInB: TDataInEventB;{$ENDIF}
      FOnDisconnected: TDisconnectedEvent;

      FOnError: TErrorEvent;

      FOnReadyToSend: TReadyToSendEvent;

      FOnSSLClientAuthentication: TSSLClientAuthenticationEvent;
			{$IFDEF CLR}FOnSSLClientAuthenticationB: TSSLClientAuthenticationEventB;{$ENDIF}
      FOnSSLStatus: TSSLStatusEvent;


    private
      tmp_ConnectionRequestAccept: Boolean;
      tmp_SSLClientAuthenticationAccept: Boolean;

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TIPDaemonSEventHook;
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

      function get_AcceptData(ConnectionId: Word): Boolean;
      procedure set_AcceptData(ConnectionId: Word; valAcceptData: Boolean);

      function get_BytesSent(ConnectionId: Word): Integer;


      function get_Connected(ConnId: Word): Boolean;
      procedure set_Connected(ConnId: Word; valConnected: Boolean);

      function get_ConnectionBacklog: Integer;
      procedure set_ConnectionBacklog(valConnectionBacklog: Integer);

      function get_ConnectionCount: Integer;



      procedure set_StringDataToSend(ConnectionId: Word; valDataToSend: String);

      function get_EOL(ConnectionId: Word): String;
      procedure set_StringEOL(ConnectionId: Word; valEOL: String);

      function get_Listening: Boolean;
      procedure set_Listening(valListening: Boolean);

      function get_LocalAddress(ConnectionId: Word): String;


      function get_RemoteHost(ConnectionId: Word): String;


      function get_RemotePort(ConnectionId: Word): Integer;


      function get_SingleLineMode(ConnectionId: Word): Boolean;
      procedure set_SingleLineMode(ConnectionId: Word; valSingleLineMode: Boolean);

      function get_SSLCertEncoded: String;
      procedure set_StringSSLCertEncoded(valSSLCertEncoded: String);


      procedure TreatErr(Err: integer; const desc: string);
















      function get_KeepAlive: Boolean;
      procedure set_KeepAlive(valKeepAlive: Boolean);

      function get_Linger: Boolean;
      procedure set_Linger(valLinger: Boolean);





      function get_LocalHost: String;
      procedure set_LocalHost(valLocalHost: String);

      function get_LocalPort: Integer;
      procedure set_LocalPort(valLocalPort: Integer);







      function get_SSLAuthenticateClients: Boolean;
      procedure set_SSLAuthenticateClients(valSSLAuthenticateClients: Boolean);



      function get_SSLCertStore: String;
      procedure set_StringSSLCertStore(valSSLCertStore: String);

      function get_SSLCertStorePassword: String;
      procedure set_SSLCertStorePassword(valSSLCertStorePassword: String);

      function get_SSLCertStoreType: TipsipdaemonsSSLCertStoreTypes;
      procedure set_SSLCertStoreType(valSSLCertStoreType: TipsipdaemonsSSLCertStoreTypes);

      function get_SSLCertSubject: String;
      procedure set_SSLCertSubject(valSSLCertSubject: String);

      function get_SSLStartMode: TipsipdaemonsSSLStartModes;
      procedure set_SSLStartMode(valSSLStartMode: TipsipdaemonsSSLStartModes);



    public

      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      property OK: String128 read GetOK write SetOK;

{$IFNDEF CLR}
      procedure SetDataToSend(ConnectionId: Word; lpDataToSend: PChar; lenDataToSend: Cardinal);
      procedure SetEOL(ConnectionId: Word; lpEOL: PChar; lenEOL: Cardinal);
      procedure SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
      procedure SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);

{$ENDIF}

      property AcceptData[ConnectionId: Word]: Boolean
               read get_AcceptData
               write set_AcceptData               ;

      property BytesSent[ConnectionId: Word]: Integer
               read get_BytesSent
               ;

      property Connected[ConnId: Word]: Boolean
               read get_Connected
               write set_Connected               ;

      property ConnectionBacklog: Integer
               read get_ConnectionBacklog
               write set_ConnectionBacklog               ;

      property ConnectionCount: Integer
               read get_ConnectionCount
               ;

      property DataToSend[ConnectionId: Word]: String

               write set_StringDataToSend               ;

      property EOL[ConnectionId: Word]: String
               read get_EOL
               write set_StringEOL               ;





      property Listening: Boolean
               read get_Listening
               write set_Listening               ;

      property LocalAddress[ConnectionId: Word]: String
               read get_LocalAddress
               ;





      property RemoteHost[ConnectionId: Word]: String
               read get_RemoteHost
               ;

      property RemotePort[ConnectionId: Word]: Integer
               read get_RemotePort
               ;

      property SingleLineMode[ConnectionId: Word]: Boolean
               read get_SingleLineMode
               write set_SingleLineMode               ;



      property SSLCertEncoded: String
               read get_SSLCertEncoded
               write set_StringSSLCertEncoded               ;













{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure Disconnect(ConnectionId: Integer);

      procedure DoEvents();

      procedure Send(ConnectionId: Integer; Text: String);

      procedure SendLine(ConnectionId: Integer; Text: String);

      procedure Shutdown();

      procedure StartSSL(ConnectionId: Integer);


{$ENDIF}

    published








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



      property SSLAuthenticateClients: Boolean
                   read get_SSLAuthenticateClients
                   write set_SSLAuthenticateClients
                   default false
                   ;

      property SSLCertStore: String
                   read get_SSLCertStore
                   write set_StringSSLCertStore
                   
                   ;
      property SSLCertStorePassword: String
                   read get_SSLCertStorePassword
                   write set_SSLCertStorePassword
                   
                   ;
      property SSLCertStoreType: TipsipdaemonsSSLCertStoreTypes
                   read get_SSLCertStoreType
                   write set_SSLCertStoreType
                   default sstUser
                   ;
      property SSLCertSubject: String
                   read get_SSLCertSubject
                   write set_SSLCertSubject
                   
                   ;
      property SSLStartMode: TipsipdaemonsSSLStartModes
                   read get_SSLStartMode
                   write set_SSLStartMode
                   default sslAutomatic
                   ;


      property OnConnected: TConnectedEvent read FOnConnected write FOnConnected;

      property OnConnectionRequest: TConnectionRequestEvent read FOnConnectionRequest write FOnConnectionRequest;

      property OnDataIn: TDataInEvent read FOnDataIn write FOnDataIn;
			{$IFDEF CLR}property OnDataInB: TDataInEventB read FOnDataInB write FOnDataInB;{$ENDIF}
      property OnDisconnected: TDisconnectedEvent read FOnDisconnected write FOnDisconnected;

      property OnError: TErrorEvent read FOnError write FOnError;

      property OnReadyToSend: TReadyToSendEvent read FOnReadyToSend write FOnReadyToSend;

      property OnSSLClientAuthentication: TSSLClientAuthenticationEvent read FOnSSLClientAuthentication write FOnSSLClientAuthentication;
			{$IFDEF CLR}property OnSSLClientAuthenticationB: TSSLClientAuthenticationEventB read FOnSSLClientAuthenticationB write FOnSSLClientAuthenticationB;{$ENDIF}
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
    PID_IPDaemonS_AcceptData = 1;
    PID_IPDaemonS_BytesSent = 2;
    PID_IPDaemonS_Connected = 3;
    PID_IPDaemonS_ConnectionBacklog = 4;
    PID_IPDaemonS_ConnectionCount = 5;
    PID_IPDaemonS_DataToSend = 6;
    PID_IPDaemonS_EOL = 7;
    PID_IPDaemonS_KeepAlive = 8;
    PID_IPDaemonS_Linger = 9;
    PID_IPDaemonS_Listening = 10;
    PID_IPDaemonS_LocalAddress = 11;
    PID_IPDaemonS_LocalHost = 12;
    PID_IPDaemonS_LocalPort = 13;
    PID_IPDaemonS_RemoteHost = 14;
    PID_IPDaemonS_RemotePort = 15;
    PID_IPDaemonS_SingleLineMode = 16;
    PID_IPDaemonS_SSLAuthenticateClients = 17;
    PID_IPDaemonS_SSLCertEncoded = 18;
    PID_IPDaemonS_SSLCertStore = 19;
    PID_IPDaemonS_SSLCertStorePassword = 20;
    PID_IPDaemonS_SSLCertStoreType = 21;
    PID_IPDaemonS_SSLCertSubject = 22;
    PID_IPDaemonS_SSLStartMode = 23;

    EID_IPDaemonS_Connected = 1;
    EID_IPDaemonS_ConnectionRequest = 2;
    EID_IPDaemonS_DataIn = 3;
    EID_IPDaemonS_Disconnected = 4;
    EID_IPDaemonS_Error = 5;
    EID_IPDaemonS_ReadyToSend = 6;
    EID_IPDaemonS_SSLClientAuthentication = 7;
    EID_IPDaemonS_SSLStatus = 8;


    MID_IPDaemonS_Config = 1;
    MID_IPDaemonS_Disconnect = 2;
    MID_IPDaemonS_DoEvents = 3;
    MID_IPDaemonS_Send = 4;
    MID_IPDaemonS_SendLine = 5;
    MID_IPDaemonS_Shutdown = 6;
    MID_IPDaemonS_StartSSL = 7;




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
{$R 'ipsipdaemons.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsIPDaemonS; event_id: Integer; cparam: Integer; 
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
  _IPDaemonS_Create:        function(pMethod: PEventHandle; pObject: TipsIPDaemonS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IPDaemonS_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IPDaemonS_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IPDaemonS_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IPDaemonS_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IPDaemonS_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IPDaemonS_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _IPDaemonS_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Create')]
  function _IPDaemonS_Create       (pMethod: TIPDaemonSEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Destroy')]
  function _IPDaemonS_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Set')]
  function _IPDaemonS_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Set')]
  function _IPDaemonS_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Set')]
  function _IPDaemonS_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Set')]
  function _IPDaemonS_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Set')]
  function _IPDaemonS_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Set')]
  function _IPDaemonS_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Get')]
  function _IPDaemonS_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Get')]
  function _IPDaemonS_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Get')]
  function _IPDaemonS_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Get')]
  function _IPDaemonS_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Get')]
  function _IPDaemonS_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Get')]
  function _IPDaemonS_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_GetLastError')]
  function _IPDaemonS_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_StaticInit')]
  function _IPDaemonS_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_CheckIndex')]
  function _IPDaemonS_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'IPDaemonS_Do')]
  function _IPDaemonS_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _IPDaemonS_Create       (pMethod: PEventHandle; pObject: TipsIPDaemonS; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IPDaemonS_Create';
  function _IPDaemonS_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IPDaemonS_Destroy';
  function _IPDaemonS_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IPDaemonS_Set';
  function _IPDaemonS_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IPDaemonS_Get';
  function _IPDaemonS_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IPDaemonS_GetLastError';
  function _IPDaemonS_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IPDaemonS_StaticInit';
  function _IPDaemonS_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IPDaemonS_CheckIndex';
  function _IPDaemonS_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'IPDaemonS_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsIPDaemonS; event_id: Integer;
                    cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): Integer;
                    {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  var
    x: Integer;
{$IFDEF LINUX}
    msg: String;
    tmp_IdleNextWait: Integer;
    tmp_NotifyObject: TipwSocketNotifier;
{$ENDIF}
    tmp_ConnectedConnectionId: Integer;
    tmp_ConnectedStatusCode: Integer;
    tmp_ConnectedDescription: String;
    tmp_DataInConnectionId: Integer;
    tmp_DataInText: String;
    tmp_DataInEOL: Boolean;
    tmp_DisconnectedConnectionId: Integer;
    tmp_DisconnectedStatusCode: Integer;
    tmp_DisconnectedDescription: String;
    tmp_ErrorErrorCode: Integer;
    tmp_ErrorDescription: String;
    tmp_ReadyToSendConnectionId: Integer;
    tmp_SSLClientAuthenticationConnectionId: Integer;
    tmp_SSLClientAuthenticationCertEncoded: String;
    tmp_SSLClientAuthenticationCertSubject: String;
    tmp_SSLClientAuthenticationCertIssuer: String;
    tmp_SSLClientAuthenticationStatus: String;
    tmp_SSLStatusConnectionId: Integer;
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

      EID_IPDaemonS_Connected:
      begin
        if Assigned(lpContext.FOnConnected) then
        begin
          {assign temporary variables}
          tmp_ConnectedConnectionId := Integer(params^[0]);
          tmp_ConnectedStatusCode := Integer(params^[1]);
          tmp_ConnectedDescription := AnsiString(PChar(params^[2]));


          lpContext.FOnConnected(lpContext, tmp_ConnectedConnectionId, tmp_ConnectedStatusCode, tmp_ConnectedDescription);




        end;
      end;
      EID_IPDaemonS_ConnectionRequest:
      begin
        if Assigned(lpContext.FOnConnectionRequest) then
        begin
          {assign temporary variables}
          lpContext.tmp_ConnectionRequestAccept := Boolean(params^[0]);

          lpContext.FOnConnectionRequest(lpContext, lpContext.tmp_ConnectionRequestAccept);
          params^[0] := Pointer(lpContext.tmp_ConnectionRequestAccept);


        end;
      end;
      EID_IPDaemonS_DataIn:
      begin
        if Assigned(lpContext.FOnDataIn) then
        begin
          {assign temporary variables}
          tmp_DataInConnectionId := Integer(params^[0]);
          SetString(tmp_DataInText, PChar(params^[1]), cbparam^[1]);

          tmp_DataInEOL := Boolean(params^[2]);

          lpContext.FOnDataIn(lpContext, tmp_DataInConnectionId, tmp_DataInText, tmp_DataInEOL);




        end;
      end;
      EID_IPDaemonS_Disconnected:
      begin
        if Assigned(lpContext.FOnDisconnected) then
        begin
          {assign temporary variables}
          tmp_DisconnectedConnectionId := Integer(params^[0]);
          tmp_DisconnectedStatusCode := Integer(params^[1]);
          tmp_DisconnectedDescription := AnsiString(PChar(params^[2]));


          lpContext.FOnDisconnected(lpContext, tmp_DisconnectedConnectionId, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);




        end;
      end;
      EID_IPDaemonS_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_IPDaemonS_ReadyToSend:
      begin
        if Assigned(lpContext.FOnReadyToSend) then
        begin
          {assign temporary variables}
          tmp_ReadyToSendConnectionId := Integer(params^[0]);

          lpContext.FOnReadyToSend(lpContext, tmp_ReadyToSendConnectionId);


        end;
      end;
      EID_IPDaemonS_SSLClientAuthentication:
      begin
        if Assigned(lpContext.FOnSSLClientAuthentication) then
        begin
          {assign temporary variables}
          tmp_SSLClientAuthenticationConnectionId := Integer(params^[0]);
          SetString(tmp_SSLClientAuthenticationCertEncoded, PChar(params^[1]), cbparam^[1]);

          tmp_SSLClientAuthenticationCertSubject := AnsiString(PChar(params^[2]));

          tmp_SSLClientAuthenticationCertIssuer := AnsiString(PChar(params^[3]));

          tmp_SSLClientAuthenticationStatus := AnsiString(PChar(params^[4]));

          lpContext.tmp_SSLClientAuthenticationAccept := Boolean(params^[5]);

          lpContext.FOnSSLClientAuthentication(lpContext, tmp_SSLClientAuthenticationConnectionId, tmp_SSLClientAuthenticationCertEncoded, tmp_SSLClientAuthenticationCertSubject, tmp_SSLClientAuthenticationCertIssuer, tmp_SSLClientAuthenticationStatus, lpContext.tmp_SSLClientAuthenticationAccept);





          params^[5] := Pointer(lpContext.tmp_SSLClientAuthenticationAccept);


        end;
      end;
      EID_IPDaemonS_SSLStatus:
      begin
        if Assigned(lpContext.FOnSSLStatus) then
        begin
          {assign temporary variables}
          tmp_SSLStatusConnectionId := Integer(params^[0]);
          tmp_SSLStatusMessage := AnsiString(PChar(params^[1]));


          lpContext.FOnSSLStatus(lpContext, tmp_SSLStatusConnectionId, tmp_SSLStatusMessage);



        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsIPDaemonS.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_ConnectedConnectionId: Integer;
  tmp_ConnectedStatusCode: Integer;
  tmp_ConnectedDescription: String;


  tmp_DataInConnectionId: Integer;
  tmp_DataInText: String;
  tmp_DataInEOL: Boolean;

  tmp_DataInTextB: Array of Byte;
  tmp_DisconnectedConnectionId: Integer;
  tmp_DisconnectedStatusCode: Integer;
  tmp_DisconnectedDescription: String;

  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_ReadyToSendConnectionId: Integer;

  tmp_SSLClientAuthenticationConnectionId: Integer;
  tmp_SSLClientAuthenticationCertEncoded: String;
  tmp_SSLClientAuthenticationCertSubject: String;
  tmp_SSLClientAuthenticationCertIssuer: String;
  tmp_SSLClientAuthenticationStatus: String;

  tmp_SSLClientAuthenticationCertEncodedB: Array of Byte;
  tmp_SSLStatusConnectionId: Integer;
  tmp_SSLStatusMessage: String;


begin
 	p := nil;
  case event_id of
    EID_IPDaemonS_Connected:
    begin
      if Assigned(FOnConnected) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ConnectedConnectionId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_ConnectedStatusCode := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_ConnectedDescription := Marshal.PtrToStringAnsi(p);


        FOnConnected(lpContext, tmp_ConnectedConnectionId, tmp_ConnectedStatusCode, tmp_ConnectedDescription);




      end;


    end;
    EID_IPDaemonS_ConnectionRequest:
    begin
      if Assigned(FOnConnectionRequest) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        if Marshal.ReadInt32(params, 4*0) <> 0 then tmp_ConnectionRequestAccept := true else tmp_ConnectionRequestAccept := false;


        FOnConnectionRequest(lpContext, tmp_ConnectionRequestAccept);
        if tmp_ConnectionRequestAccept then Marshal.WriteInt32(params, 4*0, 1) else Marshal.WriteInt32(params, 4*0, 0);


      end;


    end;
    EID_IPDaemonS_DataIn:
    begin
      if Assigned(FOnDataIn) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DataInConnectionId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_DataInText := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*1));

				p := Marshal.ReadIntPtr(params, 4 * 2);
        if Marshal.ReadInt32(params, 4*2) <> 0 then tmp_DataInEOL := true else tmp_DataInEOL := false;


        FOnDataIn(lpContext, tmp_DataInConnectionId, tmp_DataInText, tmp_DataInEOL);




      end;

      if Assigned(FOnDataInB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DataInConnectionId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        SetLength(tmp_DataInTextB, Marshal.ReadInt32(cbparam, 4 * 1)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 1), tmp_DataInTextB,
        						 0, Length(tmp_DataInTextB));

				p := Marshal.ReadIntPtr(params, 4 * 2);
        if Marshal.ReadInt32(params, 4*2) <> 0 then tmp_DataInEOL := true else tmp_DataInEOL := false;


        FOnDataInB(lpContext, tmp_DataInConnectionId, tmp_DataInTextB, tmp_DataInEOL);




      end;
    end;
    EID_IPDaemonS_Disconnected:
    begin
      if Assigned(FOnDisconnected) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_DisconnectedConnectionId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_DisconnectedStatusCode := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_DisconnectedDescription := Marshal.PtrToStringAnsi(p);


        FOnDisconnected(lpContext, tmp_DisconnectedConnectionId, tmp_DisconnectedStatusCode, tmp_DisconnectedDescription);




      end;


    end;
    EID_IPDaemonS_Error:
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
    EID_IPDaemonS_ReadyToSend:
    begin
      if Assigned(FOnReadyToSend) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_ReadyToSendConnectionId := Marshal.ReadInt32(params, 4*0);

        FOnReadyToSend(lpContext, tmp_ReadyToSendConnectionId);


      end;


    end;
    EID_IPDaemonS_SSLClientAuthentication:
    begin
      if Assigned(FOnSSLClientAuthentication) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLClientAuthenticationConnectionId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SSLClientAuthenticationCertEncoded := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*1));

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_SSLClientAuthenticationCertSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_SSLClientAuthenticationCertIssuer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_SSLClientAuthenticationStatus := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        if Marshal.ReadInt32(params, 4*5) <> 0 then tmp_SSLClientAuthenticationAccept := true else tmp_SSLClientAuthenticationAccept := false;


        FOnSSLClientAuthentication(lpContext, tmp_SSLClientAuthenticationConnectionId, tmp_SSLClientAuthenticationCertEncoded, tmp_SSLClientAuthenticationCertSubject, tmp_SSLClientAuthenticationCertIssuer, tmp_SSLClientAuthenticationStatus, tmp_SSLClientAuthenticationAccept);





        if tmp_SSLClientAuthenticationAccept then Marshal.WriteInt32(params, 4*5, 1) else Marshal.WriteInt32(params, 4*5, 0);


      end;

      if Assigned(FOnSSLClientAuthenticationB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLClientAuthenticationConnectionId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        SetLength(tmp_SSLClientAuthenticationCertEncodedB, Marshal.ReadInt32(cbparam, 4 * 1)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 1), tmp_SSLClientAuthenticationCertEncodedB,
        						 0, Length(tmp_SSLClientAuthenticationCertEncodedB));

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_SSLClientAuthenticationCertSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_SSLClientAuthenticationCertIssuer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_SSLClientAuthenticationStatus := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 5);
        if Marshal.ReadInt32(params, 4*5) <> 0 then tmp_SSLClientAuthenticationAccept := true else tmp_SSLClientAuthenticationAccept := false;


        FOnSSLClientAuthenticationB(lpContext, tmp_SSLClientAuthenticationConnectionId, tmp_SSLClientAuthenticationCertEncodedB, tmp_SSLClientAuthenticationCertSubject, tmp_SSLClientAuthenticationCertIssuer, tmp_SSLClientAuthenticationStatus, tmp_SSLClientAuthenticationAccept);





        if tmp_SSLClientAuthenticationAccept then Marshal.WriteInt32(params, 4*5, 1) else Marshal.WriteInt32(params, 4*5, 0);


      end;
    end;
    EID_IPDaemonS_SSLStatus:
    begin
      if Assigned(FOnSSLStatus) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_SSLStatusConnectionId := Marshal.ReadInt32(params, 4*0);
				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_SSLStatusMessage := Marshal.PtrToStringAnsi(p);


        FOnSSLStatus(lpContext, tmp_SSLStatusConnectionId, tmp_SSLStatusMessage);



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
    RegisterComponents('IP*Works! SSL', [TipsIPDaemonS]);
end;

constructor TipsIPDaemonS.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _IPDaemonS_Create(m_anchor, 0, nil);
{$ELSE}
		if @_IPDaemonS_Create <> nil then
      m_ctl := _IPDaemonS_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL IPDaemonS: Error creating component');

{$IFDEF CLR}
    _IPDaemonS_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_12, 0);
{$ELSE}
    _IPDaemonS_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_12)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_IPDaemonS_Do <> nil then
      _IPDaemonS_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_KeepAlive(false) except on E:Exception do end;
    try set_Linger(true) except on E:Exception do end;
    try set_LocalPort(0) except on E:Exception do end;
    try set_SSLAuthenticateClients(false) except on E:Exception do end;
    try set_StringSSLCertStore('MY') except on E:Exception do end;
    try set_SSLCertStorePassword('') except on E:Exception do end;
    try set_SSLCertStoreType(sstUser) except on E:Exception do end;
    try set_SSLCertSubject('') except on E:Exception do end;
    try set_SSLStartMode(sslAutomatic) except on E:Exception do end;

end;

destructor TipsIPDaemonS.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_IPDaemonS_Destroy <> nil then{$ENDIF}
      	_IPDaemonS_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsIPDaemonS.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsIPDaemonS.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsIPDaemonS.AboutDlg;
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
	if @_IPDaemonS_Do <> nil then
{$ENDIF}
		_IPDaemonS_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsIPDaemonS.SetOK(key: String128);
begin
end;

function TipsIPDaemonS.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsIPDaemonS.HasData: Boolean;
begin
  result := false;
end;

procedure TipsIPDaemonS.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsIPDaemonS.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsIPDaemonS.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsIPDaemonS.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_IPDaemonS_GetLastError <> nil then{$ENDIF}
      msg := _IPDaemonS_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsIPDaemonS.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_IPDaemonS_Do <> nil then
      _IPDaemonS_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsIPDaemonS.SetDataToSend(ConnectionId: Word; lpDataToSend: PChar; lenDataToSend: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_IPDaemonS_Set = nil then exit;{$ENDIF}
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_DataToSend, ConnectionId, Integer(lpDataToSend), lenDataToSend);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsIPDaemonS.SetEOL(ConnectionId: Word; lpEOL: PChar; lenEOL: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_IPDaemonS_Set = nil then exit;{$ENDIF}
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_EOL, ConnectionId, Integer(lpEOL), lenEOL);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsIPDaemonS.SetSSLCertEncoded(lpSSLCertEncoded: PChar; lenSSLCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_IPDaemonS_Set = nil then exit;{$ENDIF}
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLCertEncoded, 0, Integer(lpSSLCertEncoded), lenSSLCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsIPDaemonS.SetSSLCertStore(lpSSLCertStore: PChar; lenSSLCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_IPDaemonS_Set = nil then exit;{$ENDIF}
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLCertStore, 0, Integer(lpSSLCertStore), lenSSLCertStore);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsIPDaemonS.get_AcceptData(ConnectionId: Word): Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IPDaemonS_GetBOOL(m_ctl, PID_IPDaemonS_AcceptData, ConnectionId, err));
{$ELSE}
  result := BOOL(0);
  if @_IPDaemonS_CheckIndex = nil then exit;
  err :=  _IPDaemonS_CheckIndex(m_ctl, PID_IPDaemonS_AcceptData, ConnectionId);
  if err <> 0 then TreatErr(err, 'Invalid array index value for AcceptData');
	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_AcceptData, ConnectionId, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_AcceptData(ConnectionId: Word; valAcceptData: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBOOL(m_ctl, PID_IPDaemonS_AcceptData, ConnectionId, valAcceptData, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_AcceptData, ConnectionId, Integer(valAcceptData), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_BytesSent(ConnectionId: Word): Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IPDaemonS_GetLONG(m_ctl, PID_IPDaemonS_BytesSent, ConnectionId, err));
{$ELSE}
  result := Integer(0);
  if @_IPDaemonS_CheckIndex = nil then exit;
  err :=  _IPDaemonS_CheckIndex(m_ctl, PID_IPDaemonS_BytesSent, ConnectionId);
  if err <> 0 then TreatErr(err, 'Invalid array index value for BytesSent');
	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_BytesSent, ConnectionId, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsIPDaemonS.get_Connected(ConnId: Word): Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IPDaemonS_GetBOOL(m_ctl, PID_IPDaemonS_Connected, ConnId, err));
{$ELSE}
  result := BOOL(0);
  if @_IPDaemonS_CheckIndex = nil then exit;
  err :=  _IPDaemonS_CheckIndex(m_ctl, PID_IPDaemonS_Connected, ConnId);
  if err <> 0 then TreatErr(err, 'Invalid array index value for Connected');
	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_Connected, ConnId, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_Connected(ConnId: Word; valConnected: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBOOL(m_ctl, PID_IPDaemonS_Connected, ConnId, valConnected, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_Connected, ConnId, Integer(valConnected), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_ConnectionBacklog: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IPDaemonS_GetINT(m_ctl, PID_IPDaemonS_ConnectionBacklog, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_ConnectionBacklog, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_ConnectionBacklog(valConnectionBacklog: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetINT(m_ctl, PID_IPDaemonS_ConnectionBacklog, 0, valConnectionBacklog, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_ConnectionBacklog, 0, Integer(valConnectionBacklog), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_ConnectionCount: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IPDaemonS_GetINT(m_ctl, PID_IPDaemonS_ConnectionCount, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_ConnectionCount, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;



procedure TipsIPDaemonS.set_StringDataToSend(ConnectionId: Word; valDataToSend: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBSTR(m_ctl, PID_IPDaemonS_DataToSend, ConnectionId, valDataToSend, Length(valDataToSend));

{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_DataToSend, ConnectionId, Integer(PChar(valDataToSend)), Length(valDataToSend));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_EOL(ConnectionId: Word): String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IPDaemonS_GetBSTR(m_ctl, PID_IPDaemonS_EOL, ConnectionId, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_IPDaemonS_CheckIndex = nil then exit;
  err :=  _IPDaemonS_CheckIndex(m_ctl, PID_IPDaemonS_EOL, ConnectionId);
  if err <> 0 then TreatErr(err, 'Invalid array index value for EOL');
	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_EOL, ConnectionId, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsIPDaemonS.set_StringEOL(ConnectionId: Word; valEOL: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBSTR(m_ctl, PID_IPDaemonS_EOL, ConnectionId, valEOL, Length(valEOL));

{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_EOL, ConnectionId, Integer(PChar(valEOL)), Length(valEOL));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_KeepAlive: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IPDaemonS_GetBOOL(m_ctl, PID_IPDaemonS_KeepAlive, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_KeepAlive, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_KeepAlive(valKeepAlive: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBOOL(m_ctl, PID_IPDaemonS_KeepAlive, 0, valKeepAlive, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_KeepAlive, 0, Integer(valKeepAlive), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_Linger: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IPDaemonS_GetBOOL(m_ctl, PID_IPDaemonS_Linger, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_Linger, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_Linger(valLinger: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBOOL(m_ctl, PID_IPDaemonS_Linger, 0, valLinger, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_Linger, 0, Integer(valLinger), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_Listening: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IPDaemonS_GetBOOL(m_ctl, PID_IPDaemonS_Listening, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_Listening, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_Listening(valListening: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBOOL(m_ctl, PID_IPDaemonS_Listening, 0, valListening, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_Listening, 0, Integer(valListening), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_LocalAddress(ConnectionId: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IPDaemonS_GetCSTR(m_ctl, PID_IPDaemonS_LocalAddress, ConnectionId, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_IPDaemonS_CheckIndex = nil then exit;
  err :=  _IPDaemonS_CheckIndex(m_ctl, PID_IPDaemonS_LocalAddress, ConnectionId);
  if err <> 0 then TreatErr(err, 'Invalid array index value for LocalAddress');
	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_LocalAddress, ConnectionId, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIPDaemonS.get_LocalHost: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IPDaemonS_GetCSTR(m_ctl, PID_IPDaemonS_LocalHost, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_LocalHost, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIPDaemonS.set_LocalHost(valLocalHost: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetCSTR(m_ctl, PID_IPDaemonS_LocalHost, 0, valLocalHost, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_LocalHost, 0, Integer(PChar(valLocalHost)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_LocalPort: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IPDaemonS_GetLONG(m_ctl, PID_IPDaemonS_LocalPort, 0, err));
{$ELSE}
  result := Integer(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_LocalPort, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_LocalPort(valLocalPort: Integer);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetLONG(m_ctl, PID_IPDaemonS_LocalPort, 0, valLocalPort, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_LocalPort, 0, Integer(valLocalPort), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_RemoteHost(ConnectionId: Word): String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IPDaemonS_GetCSTR(m_ctl, PID_IPDaemonS_RemoteHost, ConnectionId, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));
  if @_IPDaemonS_CheckIndex = nil then exit;
  err :=  _IPDaemonS_CheckIndex(m_ctl, PID_IPDaemonS_RemoteHost, ConnectionId);
  if err <> 0 then TreatErr(err, 'Invalid array index value for RemoteHost');
	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_RemoteHost, ConnectionId, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsIPDaemonS.get_RemotePort(ConnectionId: Word): Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_IPDaemonS_GetLONG(m_ctl, PID_IPDaemonS_RemotePort, ConnectionId, err));
{$ELSE}
  result := Integer(0);
  if @_IPDaemonS_CheckIndex = nil then exit;
  err :=  _IPDaemonS_CheckIndex(m_ctl, PID_IPDaemonS_RemotePort, ConnectionId);
  if err <> 0 then TreatErr(err, 'Invalid array index value for RemotePort');
	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_RemotePort, ConnectionId, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsIPDaemonS.get_SingleLineMode(ConnectionId: Word): Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IPDaemonS_GetBOOL(m_ctl, PID_IPDaemonS_SingleLineMode, ConnectionId, err));
{$ELSE}
  result := BOOL(0);
  if @_IPDaemonS_CheckIndex = nil then exit;
  err :=  _IPDaemonS_CheckIndex(m_ctl, PID_IPDaemonS_SingleLineMode, ConnectionId);
  if err <> 0 then TreatErr(err, 'Invalid array index value for SingleLineMode');
	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_SingleLineMode, ConnectionId, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_SingleLineMode(ConnectionId: Word; valSingleLineMode: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBOOL(m_ctl, PID_IPDaemonS_SingleLineMode, ConnectionId, valSingleLineMode, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SingleLineMode, ConnectionId, Integer(valSingleLineMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_SSLAuthenticateClients: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_IPDaemonS_GetBOOL(m_ctl, PID_IPDaemonS_SSLAuthenticateClients, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_SSLAuthenticateClients, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_SSLAuthenticateClients(valSSLAuthenticateClients: Boolean);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBOOL(m_ctl, PID_IPDaemonS_SSLAuthenticateClients, 0, valSSLAuthenticateClients, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLAuthenticateClients, 0, Integer(valSSLAuthenticateClients), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_SSLCertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IPDaemonS_GetBSTR(m_ctl, PID_IPDaemonS_SSLCertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_SSLCertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsIPDaemonS.set_StringSSLCertEncoded(valSSLCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBSTR(m_ctl, PID_IPDaemonS_SSLCertEncoded, 0, valSSLCertEncoded, Length(valSSLCertEncoded));

{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLCertEncoded, 0, Integer(PChar(valSSLCertEncoded)), Length(valSSLCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_SSLCertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IPDaemonS_GetBSTR(m_ctl, PID_IPDaemonS_SSLCertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_SSLCertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsIPDaemonS.set_StringSSLCertStore(valSSLCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetBSTR(m_ctl, PID_IPDaemonS_SSLCertStore, 0, valSSLCertStore, Length(valSSLCertStore));

{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLCertStore, 0, Integer(PChar(valSSLCertStore)), Length(valSSLCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_SSLCertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IPDaemonS_GetCSTR(m_ctl, PID_IPDaemonS_SSLCertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_SSLCertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIPDaemonS.set_SSLCertStorePassword(valSSLCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetCSTR(m_ctl, PID_IPDaemonS_SSLCertStorePassword, 0, valSSLCertStorePassword, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLCertStorePassword, 0, Integer(PChar(valSSLCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_SSLCertStoreType: TipsipdaemonsSSLCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsipdaemonsSSLCertStoreTypes(_IPDaemonS_GetENUM(m_ctl, PID_IPDaemonS_SSLCertStoreType, 0, err));
{$ELSE}
  result := TipsipdaemonsSSLCertStoreTypes(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_SSLCertStoreType, 0, nil);
  result := TipsipdaemonsSSLCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_SSLCertStoreType(valSSLCertStoreType: TipsipdaemonsSSLCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetENUM(m_ctl, PID_IPDaemonS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLCertStoreType, 0, Integer(valSSLCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_SSLCertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _IPDaemonS_GetCSTR(m_ctl, PID_IPDaemonS_SSLCertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_SSLCertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsIPDaemonS.set_SSLCertSubject(valSSLCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetCSTR(m_ctl, PID_IPDaemonS_SSLCertSubject, 0, valSSLCertSubject, 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLCertSubject, 0, Integer(PChar(valSSLCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsIPDaemonS.get_SSLStartMode: TipsipdaemonsSSLStartModes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipsipdaemonsSSLStartModes(_IPDaemonS_GetENUM(m_ctl, PID_IPDaemonS_SSLStartMode, 0, err));
{$ELSE}
  result := TipsipdaemonsSSLStartModes(0);

	if @_IPDaemonS_Get = nil then exit;
  tmp := _IPDaemonS_Get(m_ctl, PID_IPDaemonS_SSLStartMode, 0, nil);
  result := TipsipdaemonsSSLStartModes(tmp);
{$ENDIF}
end;
procedure TipsIPDaemonS.set_SSLStartMode(valSSLStartMode: TipsipdaemonsSSLStartModes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _IPDaemonS_SetENUM(m_ctl, PID_IPDaemonS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ELSE}
	if @_IPDaemonS_Set = nil then exit;
  err := _IPDaemonS_Set(m_ctl, PID_IPDaemonS_SSLStartMode, 0, Integer(valSSLStartMode), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;



{$IFNDEF DELPHI3}
function TipsIPDaemonS.Config(ConfigurationString: String): String;
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


  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_IPDaemonS_Do = nil then exit;
  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsIPDaemonS.Disconnect(ConnectionId: Integer);

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

  param[i] := IntPtr(ConnectionId);
  paramcb[i] := 0;
  i := i + 1;


  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_Disconnect, 1, param, paramcb); 




  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := Pointer(ConnectionId);
  paramcb[i] := 0;
  i := i + 1;


	if @_IPDaemonS_Do = nil then exit;
  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_Disconnect, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIPDaemonS.DoEvents();

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



  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_DoEvents, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IPDaemonS_Do = nil then exit;
  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_DoEvents, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIPDaemonS.Send(ConnectionId: Integer; Text: String);

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

  param[i] := IntPtr(ConnectionId);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Text);
  paramcb[i] := Length(Text);

  i := i + 1;


  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_Send, 2, param, paramcb); 


	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);


  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := Pointer(ConnectionId);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := PChar(Text);
  paramcb[i] := Length(Text);

  i := i + 1;


	if @_IPDaemonS_Do = nil then exit;
  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_Send, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIPDaemonS.SendLine(ConnectionId: Integer; Text: String);

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

  param[i] := IntPtr(ConnectionId);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Text);
  paramcb[i] := 0;

  i := i + 1;


  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_SendLine, 2, param, paramcb); 


	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := Pointer(ConnectionId);
  paramcb[i] := 0;
  i := i + 1;
  param[i] := PChar(Text);
  paramcb[i] := 0;

  i := i + 1;


	if @_IPDaemonS_Do = nil then exit;
  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_SendLine, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIPDaemonS.Shutdown();

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



  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_Shutdown, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_IPDaemonS_Do = nil then exit;
  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_Shutdown, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsIPDaemonS.StartSSL(ConnectionId: Integer);

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

  param[i] := IntPtr(ConnectionId);
  paramcb[i] := 0;
  i := i + 1;


  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_StartSSL, 1, param, paramcb); 




  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := Pointer(ConnectionId);
  paramcb[i] := 0;
  i := i + 1;


	if @_IPDaemonS_Do = nil then exit;
  err := _IPDaemonS_Do(m_ctl, MID_IPDaemonS_StartSSL, 1, @param, @paramcb); 
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

	_IPDaemonS_Create := nil;
	_IPDaemonS_Destroy := nil;
	_IPDaemonS_Set := nil;
	_IPDaemonS_Get := nil;
	_IPDaemonS_GetLastError := nil;
	_IPDaemonS_StaticInit := nil;
	_IPDaemonS_CheckIndex := nil;
	_IPDaemonS_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_ipdaemons_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_IPDaemonS_Create       := IPWorksSSLFindFunc(pBaseAddress, 'IPDaemonS_Create');
		@_IPDaemonS_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'IPDaemonS_Destroy');
		@_IPDaemonS_Set          := IPWorksSSLFindFunc(pBaseAddress, 'IPDaemonS_Set');
		@_IPDaemonS_Get          := IPWorksSSLFindFunc(pBaseAddress, 'IPDaemonS_Get');
		@_IPDaemonS_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'IPDaemonS_GetLastError');
		@_IPDaemonS_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'IPDaemonS_CheckIndex');
		@_IPDaemonS_Do           := IPWorksSSLFindFunc(pBaseAddress, 'IPDaemonS_Do');
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
  @_IPDaemonS_Create       := nil;
  @_IPDaemonS_Destroy      := nil;
  @_IPDaemonS_Set          := nil;
  @_IPDaemonS_Get          := nil;
  @_IPDaemonS_GetLastError := nil;
  @_IPDaemonS_CheckIndex   := nil;
  @_IPDaemonS_Do           := nil;
  IPWorksSSLFreeDRU(pBaseAddress, pEntryPoint);
  pBaseAddress := nil;
  pEntryPoint := nil;
end;
{$ENDIF}
{$ENDIF}
{$ENDIF}


end.




