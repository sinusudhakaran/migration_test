
unit ipscertmgr;

interface

uses
  SysUtils, Classes, ipscore, ipskeys
  {$IFDEF CLR}, System.Security, System.Runtime.InteropServices{$ENDIF};

{$WARNINGS OFF}

type

  TipscertmgrCertStoreTypes = 
(

									 
                   sstUser,

									 
                   sstMachine,

									 
                   sstPFXFile,

									 
                   sstPFXBlob,

									 
                   sstPEMKey
);


  TCertChainEvent = procedure(Sender: TObject;
                            CertEncoded: String;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const CertSerialNumber: String;
                            TrustStatus: Integer;
                            TrustInfo: Integer) of Object;
{$IFDEF CLR}
  TCertChainEventB = procedure(Sender: TObject;
                            CertEncoded: Array of Byte;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const CertSerialNumber: String;
                            TrustStatus: Integer;
                            TrustInfo: Integer) of Object;

{$ENDIF}
  TCertListEvent = procedure(Sender: TObject;
                            CertEncoded: String;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const CertSerialNumber: String;
                            HasPrivateKey: Boolean) of Object;
{$IFDEF CLR}
  TCertListEventB = procedure(Sender: TObject;
                            CertEncoded: Array of Byte;
                            const CertSubject: String;
                            const CertIssuer: String;
                            const CertSerialNumber: String;
                            HasPrivateKey: Boolean) of Object;

{$ENDIF}
  TErrorEvent = procedure(Sender: TObject;
                            ErrorCode: Integer;
                            const Description: String) of Object;

  TKeyListEvent = procedure(Sender: TObject;
                            const KeyContainer: String;
                            KeyType: Integer;
                            const AlgId: String;
                            KeyLen: Integer) of Object;

  TStoreListEvent = procedure(Sender: TObject;
                            const CertStore: String) of Object;


{$IFDEF CLR}
  TCertMgrEventHook = function(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         		 params: IntPtr; cbparam: IntPtr): integer;
{$ENDIF}
  EipsCertMgr = class(EIPWorksSSL)
  end;

  String128 = String[128];

  TipsCertMgr = class(TipsCore)
    public
      FOnCertChain: TCertChainEvent;
			{$IFDEF CLR}FOnCertChainB: TCertChainEventB;{$ENDIF}
      FOnCertList: TCertListEvent;
			{$IFDEF CLR}FOnCertListB: TCertListEventB;{$ENDIF}
      FOnError: TErrorEvent;

      FOnKeyList: TKeyListEvent;

      FOnStoreList: TStoreListEvent;


    private

{$IFDEF CLR}
      m_ctl: IntPtr;
      m_anchor: TCertMgrEventHook;
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

      function get_CertEncoded: String;
      procedure set_StringCertEncoded(valCertEncoded: String);


      procedure TreatErr(Err: integer; const desc: string);


      function get_CertEffectiveDate: String;




      function get_CertExpirationDate: String;


      function get_CertIssuer: String;


      function get_CertPrivateKey: String;


      function get_CertPrivateKeyAvailable: Boolean;


      function get_CertPrivateKeyContainer: String;


      function get_CertPublicKey: String;


      function get_CertPublicKeyAlgorithm: String;


      function get_CertPublicKeyLength: Integer;


      function get_CertSerialNumber: String;


      function get_CertSignatureAlgorithm: String;


      function get_CertStore: String;
      procedure set_StringCertStore(valCertStore: String);

      function get_CertStorePassword: String;
      procedure set_CertStorePassword(valCertStorePassword: String);

      function get_CertStoreType: TipscertmgrCertStoreTypes;
      procedure set_CertStoreType(valCertStoreType: TipscertmgrCertStoreTypes);

      function get_CertSubject: String;
      procedure set_CertSubject(valCertSubject: String);

      function get_CertThumbprintMD5: String;


      function get_CertThumbprintSHA1: String;


      function get_CertUsage: String;


      function get_CertUsageFlags: Integer;


      function get_CertVersion: String;




    public

      constructor Create(AOwner: TComponent); override;
      destructor Destroy; override;

      property OK: String128 read GetOK write SetOK;

{$IFNDEF CLR}
      procedure SetCertEncoded(lpCertEncoded: PChar; lenCertEncoded: Cardinal);
      procedure SetCertStore(lpCertStore: PChar; lenCertStore: Cardinal);

{$ENDIF}



      property CertEncoded: String
               read get_CertEncoded
               write set_StringCertEncoded               ;









































{$IFNDEF DELPHI3}      
      function Config(ConfigurationString: String): String;
      procedure CreateCertificate(CertSubject: String; SerialNumber: Integer);

      procedure CreateKey(KeyName: String);

      procedure DeleteCertificate();

      procedure DeleteKey(KeyName: String);

      procedure ExportCertificate(PFXFile: String; Password: String);

      function GenerateCSR(CertSubject: String; KeyName: String): String;
      procedure ImportCertificate(PFXFile: String; Password: String; Subject: String);

      procedure ImportSignedCSR(SignedCSR: String; KeyName: String);

      procedure IssueCertificate(CertSubject: String; SerialNumber: Integer);

      function ListCertificateStores(): String;
      function ListKeys(): String;
      function ListMachineStores(): String;
      function ListStoreCertificates(): String;
      procedure ReadCertificate(FileName: String);

      procedure Reset();

      procedure SaveCertificate(FileName: String);

      function ShowCertificateChain(): String;
      function SignCSR(CSR: String; SerialNumber: Integer): String;

{$ENDIF}

    published

      property CertEffectiveDate: String
                   read get_CertEffectiveDate
                    write SetNoopString
                   stored False

                   ;

      property CertExpirationDate: String
                   read get_CertExpirationDate
                    write SetNoopString
                   stored False

                   ;
      property CertIssuer: String
                   read get_CertIssuer
                    write SetNoopString
                   stored False

                   ;
      property CertPrivateKey: String
                   read get_CertPrivateKey
                    write SetNoopString
                   stored False

                   ;
      property CertPrivateKeyAvailable: Boolean
                   read get_CertPrivateKeyAvailable
                    write SetNoopBoolean
                   stored False

                   ;
      property CertPrivateKeyContainer: String
                   read get_CertPrivateKeyContainer
                    write SetNoopString
                   stored False

                   ;
      property CertPublicKey: String
                   read get_CertPublicKey
                    write SetNoopString
                   stored False

                   ;
      property CertPublicKeyAlgorithm: String
                   read get_CertPublicKeyAlgorithm
                    write SetNoopString
                   stored False

                   ;
      property CertPublicKeyLength: Integer
                   read get_CertPublicKeyLength
                    write SetNoopInteger
                   stored False

                   ;
      property CertSerialNumber: String
                   read get_CertSerialNumber
                    write SetNoopString
                   stored False

                   ;
      property CertSignatureAlgorithm: String
                   read get_CertSignatureAlgorithm
                    write SetNoopString
                   stored False

                   ;
      property CertStore: String
                   read get_CertStore
                   write set_StringCertStore
                   
                   ;
      property CertStorePassword: String
                   read get_CertStorePassword
                   write set_CertStorePassword
                   
                   ;
      property CertStoreType: TipscertmgrCertStoreTypes
                   read get_CertStoreType
                   write set_CertStoreType
                   default sstUser
                   ;
      property CertSubject: String
                   read get_CertSubject
                   write set_CertSubject
                   
                   ;
      property CertThumbprintMD5: String
                   read get_CertThumbprintMD5
                    write SetNoopString
                   stored False

                   ;
      property CertThumbprintSHA1: String
                   read get_CertThumbprintSHA1
                    write SetNoopString
                   stored False

                   ;
      property CertUsage: String
                   read get_CertUsage
                    write SetNoopString
                   stored False

                   ;
      property CertUsageFlags: Integer
                   read get_CertUsageFlags
                    write SetNoopInteger
                   stored False

                   ;
      property CertVersion: String
                   read get_CertVersion
                    write SetNoopString
                   stored False

                   ;


      property OnCertChain: TCertChainEvent read FOnCertChain write FOnCertChain;
			{$IFDEF CLR}property OnCertChainB: TCertChainEventB read FOnCertChainB write FOnCertChainB;{$ENDIF}
      property OnCertList: TCertListEvent read FOnCertList write FOnCertList;
			{$IFDEF CLR}property OnCertListB: TCertListEventB read FOnCertListB write FOnCertListB;{$ENDIF}
      property OnError: TErrorEvent read FOnError write FOnError;

      property OnKeyList: TKeyListEvent read FOnKeyList write FOnKeyList;

      property OnStoreList: TStoreListEvent read FOnStoreList write FOnStoreList;


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
    PID_CertMgr_CertEffectiveDate = 1;
    PID_CertMgr_CertEncoded = 2;
    PID_CertMgr_CertExpirationDate = 3;
    PID_CertMgr_CertIssuer = 4;
    PID_CertMgr_CertPrivateKey = 5;
    PID_CertMgr_CertPrivateKeyAvailable = 6;
    PID_CertMgr_CertPrivateKeyContainer = 7;
    PID_CertMgr_CertPublicKey = 8;
    PID_CertMgr_CertPublicKeyAlgorithm = 9;
    PID_CertMgr_CertPublicKeyLength = 10;
    PID_CertMgr_CertSerialNumber = 11;
    PID_CertMgr_CertSignatureAlgorithm = 12;
    PID_CertMgr_CertStore = 13;
    PID_CertMgr_CertStorePassword = 14;
    PID_CertMgr_CertStoreType = 15;
    PID_CertMgr_CertSubject = 16;
    PID_CertMgr_CertThumbprintMD5 = 17;
    PID_CertMgr_CertThumbprintSHA1 = 18;
    PID_CertMgr_CertUsage = 19;
    PID_CertMgr_CertUsageFlags = 20;
    PID_CertMgr_CertVersion = 21;

    EID_CertMgr_CertChain = 1;
    EID_CertMgr_CertList = 2;
    EID_CertMgr_Error = 3;
    EID_CertMgr_KeyList = 4;
    EID_CertMgr_StoreList = 5;


    MID_CertMgr_Config = 1;
    MID_CertMgr_CreateCertificate = 2;
    MID_CertMgr_CreateKey = 3;
    MID_CertMgr_DeleteCertificate = 4;
    MID_CertMgr_DeleteKey = 5;
    MID_CertMgr_ExportCertificate = 6;
    MID_CertMgr_GenerateCSR = 7;
    MID_CertMgr_ImportCertificate = 8;
    MID_CertMgr_ImportSignedCSR = 9;
    MID_CertMgr_IssueCertificate = 10;
    MID_CertMgr_ListCertificateStores = 11;
    MID_CertMgr_ListKeys = 12;
    MID_CertMgr_ListMachineStores = 13;
    MID_CertMgr_ListStoreCertificates = 14;
    MID_CertMgr_ReadCertificate = 15;
    MID_CertMgr_Reset = 16;
    MID_CertMgr_SaveCertificate = 17;
    MID_CertMgr_ShowCertificateChain = 18;
    MID_CertMgr_SignCSR = 19;




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
{$R 'ipscertmgr.dru'}
{$ENDIF}



type
  VOIDARR = array[0..16] of {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  LPVOIDARR = {$IFNDEF CLR}^{$ENDIF}VOIDARR;
  INTARR = array[0..16] of Integer;
  LPINTARR = {$IFNDEF CLR}^{$ENDIF}INTARR;
  LPINT = ^Cardinal;
{$IFNDEF CLR}
  MEventHandle = function (lpContext: TipsCertMgr; event_id: Integer; cparam: Integer; 
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
  _CertMgr_Create:        function(pMethod: PEventHandle; pObject: TipsCertMgr; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _CertMgr_Destroy:       function(p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _CertMgr_Set:           function(p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _CertMgr_Get:           function(p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _CertMgr_GetLastError:  function(p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _CertMgr_StaticInit:    function(instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _CertMgr_CheckIndex:    function(p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  _CertMgr_Do:            function(p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
{$ELSE}
{$IFDEF CLR}
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Create')]
  function _CertMgr_Create       (pMethod: TCertMgrEventHook; pObjectIgnored: IntPtr; pKey: string): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Destroy')]
  function _CertMgr_Destroy      (p: IntPtr): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Set')]
  function _CertMgr_SetINT		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Set')]
  function _CertMgr_SetLONG		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Set')]
  function _CertMgr_SetENUM		   (p: IntPtr; index: integer; arridx: integer; value: integer; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Set')]
  function _CertMgr_SetBOOL		   (p: IntPtr; index: integer; arridx: integer; value: boolean; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Set')]
  function _CertMgr_SetCSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Set')]
  function _CertMgr_SetBSTR			 (p: IntPtr; index: integer; arridx: integer; value: String; len: Cardinal): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Get')]
  function _CertMgr_GetINT		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Get')]
  function _CertMgr_GetLONG		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Get')]
  function _CertMgr_GetENUM		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Get')]
  function _CertMgr_GetBOOL		   (p: IntPtr; index: integer; arridx: integer; var len: Integer): boolean; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Get')]
  function _CertMgr_GetCSTR			(p: IntPtr; index: integer; arridx: integer; len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Get')]
  function _CertMgr_GetBSTR			(p: IntPtr; index: integer; arridx: integer; var len: Cardinal): IntPtr; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_GetLastError')]
  function _CertMgr_GetLastError (p: IntPtr): string; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_StaticInit')]
  function _CertMgr_StaticInit   (instance: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_CheckIndex')]
  function _CertMgr_CheckIndex   (p: IntPtr; index: integer; arridx: integer): integer; external;
	[SuppressUnmanagedCodeSecurity, DllImport(DLLNAME, CharSet = CharSet.Ansi, EntryPoint = 'CertMgr_Do')]
  function _CertMgr_Do           (p: IntPtr; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; external;
{$ELSE}
  function _CertMgr_Create       (pMethod: PEventHandle; pObject: TipsCertMgr; pKey: pointer): pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'CertMgr_Create';
  function _CertMgr_Destroy      (p: pointer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'CertMgr_Destroy';
  function _CertMgr_Set          (p: pointer; index: integer; arridx: integer; value: integer; len: Cardinal): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'CertMgr_Set';
  function _CertMgr_Get          (p: pointer; index: integer; arridx: integer; len: LPINT): Pointer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'CertMgr_Get';
  function _CertMgr_GetLastError (p: pointer): PChar; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'CertMgr_GetLastError';
  function _CertMgr_StaticInit   (instance: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'CertMgr_StaticInit';
  function _CertMgr_CheckIndex   (p: pointer; index: integer; arridx: integer): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'CertMgr_CheckIndex';
  function _CertMgr_Do           (p: pointer; method_id: Integer; cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): integer; {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF}; external DLLNAME name 'CertMgr_Do';
{$ENDIF}
{$ENDIF}

{$HINTS OFF}


{$IFNDEF CLR}
function FireEvents(lpContext: TipsCertMgr; event_id: Integer;
                    cparam: Integer; params: LPVOIDARR; cbparam: LPINTARR): Integer;
                    {$IFDEF LINUX}cdecl{$ELSE}stdcall{$ENDIF};
  var
    x: Integer;
{$IFDEF LINUX}
    msg: String;
    tmp_IdleNextWait: Integer;
    tmp_NotifyObject: TipwSocketNotifier;
{$ENDIF}
    tmp_CertChainCertEncoded: String;
    tmp_CertChainCertSubject: String;
    tmp_CertChainCertIssuer: String;
    tmp_CertChainCertSerialNumber: String;
    tmp_CertChainTrustStatus: Integer;
    tmp_CertChainTrustInfo: Integer;
    tmp_CertListCertEncoded: String;
    tmp_CertListCertSubject: String;
    tmp_CertListCertIssuer: String;
    tmp_CertListCertSerialNumber: String;
    tmp_CertListHasPrivateKey: Boolean;
    tmp_ErrorErrorCode: Integer;
    tmp_ErrorDescription: String;
    tmp_KeyListKeyContainer: String;
    tmp_KeyListKeyType: Integer;
    tmp_KeyListAlgId: String;
    tmp_KeyListKeyLen: Integer;
    tmp_StoreListCertStore: String;

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

      EID_CertMgr_CertChain:
      begin
        if Assigned(lpContext.FOnCertChain) then
        begin
          {assign temporary variables}
          SetString(tmp_CertChainCertEncoded, PChar(params^[0]), cbparam^[0]);

          tmp_CertChainCertSubject := AnsiString(PChar(params^[1]));

          tmp_CertChainCertIssuer := AnsiString(PChar(params^[2]));

          tmp_CertChainCertSerialNumber := AnsiString(PChar(params^[3]));

          tmp_CertChainTrustStatus := Integer(params^[4]);
          tmp_CertChainTrustInfo := Integer(params^[5]);

          lpContext.FOnCertChain(lpContext, tmp_CertChainCertEncoded, tmp_CertChainCertSubject, tmp_CertChainCertIssuer, tmp_CertChainCertSerialNumber, tmp_CertChainTrustStatus, tmp_CertChainTrustInfo);







        end;
      end;
      EID_CertMgr_CertList:
      begin
        if Assigned(lpContext.FOnCertList) then
        begin
          {assign temporary variables}
          SetString(tmp_CertListCertEncoded, PChar(params^[0]), cbparam^[0]);

          tmp_CertListCertSubject := AnsiString(PChar(params^[1]));

          tmp_CertListCertIssuer := AnsiString(PChar(params^[2]));

          tmp_CertListCertSerialNumber := AnsiString(PChar(params^[3]));

          tmp_CertListHasPrivateKey := Boolean(params^[4]);

          lpContext.FOnCertList(lpContext, tmp_CertListCertEncoded, tmp_CertListCertSubject, tmp_CertListCertIssuer, tmp_CertListCertSerialNumber, tmp_CertListHasPrivateKey);






        end;
      end;
      EID_CertMgr_Error:
      begin
        if Assigned(lpContext.FOnError) then
        begin
          {assign temporary variables}
          tmp_ErrorErrorCode := Integer(params^[0]);
          tmp_ErrorDescription := AnsiString(PChar(params^[1]));


          lpContext.FOnError(lpContext, tmp_ErrorErrorCode, tmp_ErrorDescription);



        end;
      end;
      EID_CertMgr_KeyList:
      begin
        if Assigned(lpContext.FOnKeyList) then
        begin
          {assign temporary variables}
          tmp_KeyListKeyContainer := AnsiString(PChar(params^[0]));

          tmp_KeyListKeyType := Integer(params^[1]);
          tmp_KeyListAlgId := AnsiString(PChar(params^[2]));

          tmp_KeyListKeyLen := Integer(params^[3]);

          lpContext.FOnKeyList(lpContext, tmp_KeyListKeyContainer, tmp_KeyListKeyType, tmp_KeyListAlgId, tmp_KeyListKeyLen);





        end;
      end;
      EID_CertMgr_StoreList:
      begin
        if Assigned(lpContext.FOnStoreList) then
        begin
          {assign temporary variables}
          tmp_StoreListCertStore := AnsiString(PChar(params^[0]));


          lpContext.FOnStoreList(lpContext, tmp_StoreListCertStore);


        end;
      end;

      99999: begin x := 0; end; {:)}
      
    end; {case}
    result := 0;
end;
{$ENDIF}

{$IFDEF CLR}
function TipsCertMgr.EventHook(lpContext: IntPtr; event_id: Integer; cparam: Integer; 
                         							 params: IntPtr; cbparam: IntPtr): integer;
var
  p: IntPtr;
  tmp_CertChainCertEncoded: String;
  tmp_CertChainCertSubject: String;
  tmp_CertChainCertIssuer: String;
  tmp_CertChainCertSerialNumber: String;
  tmp_CertChainTrustStatus: Integer;
  tmp_CertChainTrustInfo: Integer;

  tmp_CertChainCertEncodedB: Array of Byte;
  tmp_CertListCertEncoded: String;
  tmp_CertListCertSubject: String;
  tmp_CertListCertIssuer: String;
  tmp_CertListCertSerialNumber: String;
  tmp_CertListHasPrivateKey: Boolean;

  tmp_CertListCertEncodedB: Array of Byte;
  tmp_ErrorErrorCode: Integer;
  tmp_ErrorDescription: String;

  tmp_KeyListKeyContainer: String;
  tmp_KeyListKeyType: Integer;
  tmp_KeyListAlgId: String;
  tmp_KeyListKeyLen: Integer;

  tmp_StoreListCertStore: String;


begin
 	p := nil;
  case event_id of
    EID_CertMgr_CertChain:
    begin
      if Assigned(FOnCertChain) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_CertChainCertEncoded := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*0));

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_CertChainCertSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_CertChainCertIssuer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_CertChainCertSerialNumber := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_CertChainTrustStatus := Marshal.ReadInt32(params, 4*4);
				p := Marshal.ReadIntPtr(params, 4 * 5);
        tmp_CertChainTrustInfo := Marshal.ReadInt32(params, 4*5);

        FOnCertChain(lpContext, tmp_CertChainCertEncoded, tmp_CertChainCertSubject, tmp_CertChainCertIssuer, tmp_CertChainCertSerialNumber, tmp_CertChainTrustStatus, tmp_CertChainTrustInfo);







      end;

      if Assigned(FOnCertChainB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        SetLength(tmp_CertChainCertEncodedB, Marshal.ReadInt32(cbparam, 4 * 0)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 0), tmp_CertChainCertEncodedB,
        						 0, Length(tmp_CertChainCertEncodedB));

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_CertChainCertSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_CertChainCertIssuer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_CertChainCertSerialNumber := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        tmp_CertChainTrustStatus := Marshal.ReadInt32(params, 4*4);
				p := Marshal.ReadIntPtr(params, 4 * 5);
        tmp_CertChainTrustInfo := Marshal.ReadInt32(params, 4*5);

        FOnCertChainB(lpContext, tmp_CertChainCertEncodedB, tmp_CertChainCertSubject, tmp_CertChainCertIssuer, tmp_CertChainCertSerialNumber, tmp_CertChainTrustStatus, tmp_CertChainTrustInfo);







      end;
    end;
    EID_CertMgr_CertList:
    begin
      if Assigned(FOnCertList) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_CertListCertEncoded := Marshal.PtrToStringAnsi(p, Marshal.ReadInt32(cbparam, 4*0));

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_CertListCertSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_CertListCertIssuer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_CertListCertSerialNumber := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        if Marshal.ReadInt32(params, 4*4) <> 0 then tmp_CertListHasPrivateKey := true else tmp_CertListHasPrivateKey := false;


        FOnCertList(lpContext, tmp_CertListCertEncoded, tmp_CertListCertSubject, tmp_CertListCertIssuer, tmp_CertListCertSerialNumber, tmp_CertListHasPrivateKey);






      end;

      if Assigned(FOnCertListB) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        SetLength(tmp_CertListCertEncodedB, Marshal.ReadInt32(cbparam, 4 * 0)); 
        Marshal.Copy(Marshal.ReadIntPtr(params, 4 * 0), tmp_CertListCertEncodedB,
        						 0, Length(tmp_CertListCertEncodedB));

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_CertListCertSubject := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_CertListCertIssuer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_CertListCertSerialNumber := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 4);
        if Marshal.ReadInt32(params, 4*4) <> 0 then tmp_CertListHasPrivateKey := true else tmp_CertListHasPrivateKey := false;


        FOnCertListB(lpContext, tmp_CertListCertEncodedB, tmp_CertListCertSubject, tmp_CertListCertIssuer, tmp_CertListCertSerialNumber, tmp_CertListHasPrivateKey);






      end;
    end;
    EID_CertMgr_Error:
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
    EID_CertMgr_KeyList:
    begin
      if Assigned(FOnKeyList) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_KeyListKeyContainer := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 1);
        tmp_KeyListKeyType := Marshal.ReadInt32(params, 4*1);
				p := Marshal.ReadIntPtr(params, 4 * 2);
        tmp_KeyListAlgId := Marshal.PtrToStringAnsi(p);

				p := Marshal.ReadIntPtr(params, 4 * 3);
        tmp_KeyListKeyLen := Marshal.ReadInt32(params, 4*3);

        FOnKeyList(lpContext, tmp_KeyListKeyContainer, tmp_KeyListKeyType, tmp_KeyListAlgId, tmp_KeyListKeyLen);





      end;


    end;
    EID_CertMgr_StoreList:
    begin
      if Assigned(FOnStoreList) then
      begin
        {assign temporary variables}
				p := Marshal.ReadIntPtr(params, 4 * 0);
        tmp_StoreListCertStore := Marshal.PtrToStringAnsi(p);


        FOnStoreList(lpContext, tmp_StoreListCertStore);


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
    RegisterComponents('IP*Works! SSL', [TipsCertMgr]);
end;

constructor TipsCertMgr.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    m_ctl := nil;
    
{$IFDEF CLR}
		m_anchor := @Self.EventHook;
    m_ctl := _CertMgr_Create(m_anchor, 0, nil);
{$ELSE}
		if @_CertMgr_Create <> nil then
      m_ctl := _CertMgr_Create(@FireEvents, self, nil);
{$ENDIF}
    
    if m_ctl = nil then
      TreatErr(-1, 'IP*Works! SSL CertMgr: Error creating component');

{$IFDEF CLR}
    _CertMgr_SetCSTR(m_ctl, 255, 0, IPWSSL_OEMKEY_57, 0);
{$ELSE}
    _CertMgr_Set(m_ctl, 255, 0, Integer(PChar(IPWSSL_OEMKEY_57)), 0);
{$ENDIF}

{$IFDEF LINUX}
    if @_CertMgr_Do <> nil then
      _CertMgr_Do(m_ctl, 2001{MID_ENABLEASYNCEVENTS}, 0, NIL, NIL);
{$ENDIF}
    try set_StringCertStore('MY') except on E:Exception do end;
    try set_CertStorePassword('') except on E:Exception do end;
    try set_CertStoreType(sstUser) except on E:Exception do end;
    try set_CertSubject('') except on E:Exception do end;

end;

destructor TipsCertMgr.Destroy;
begin
    if m_ctl <> nil then begin
      {$IFNDEF CLR}if @_CertMgr_Destroy <> nil then{$ENDIF}
      	_CertMgr_Destroy(m_ctl);
    end;
    m_ctl := nil;
    inherited Destroy;
end;

function TipsCertMgr.ThrowCoreException(err: integer; const desc: string): EIPWorksSSL;
begin
    result := EipsCertMgr.CreateCode(err, desc);
end;

{*********************************************************************************}

procedure TipsCertMgr.AboutDlg;
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
	if @_CertMgr_Do <> nil then
{$ENDIF}
		_CertMgr_Do(m_ctl, 255, 0, p, pc);
{$ENDIF}
end;

{*********************************************************************************}

procedure TipsCertMgr.SetOK(key: String128);
begin
end;

function TipsCertMgr.GetOK: String128;
var
  res: String128;
begin
  result := res;
end;

{*********************************************************************************}

function TipsCertMgr.HasData: Boolean;
begin
  result := false;
end;

procedure TipsCertMgr.ReadHnd(Reader: TStream);
var
  tmp: String128;
begin
  //Reader.Read(tmp, 129);
end;

procedure TipsCertMgr.WriteHnd(Writer: TStream);
var
  tmp: String128;
begin
  tmp[0] := #0;
  //Writer.Write(tmp, 129);
end;

procedure TipsCertMgr.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('RegHnd', ReadHnd, WriteHnd, HasData);
end;

{*********************************************************************************}

procedure TipsCertMgr.TreatErr(Err: integer; const desc: string);
var
  msg: string;
begin
  msg := desc;
  if Length(msg) = 0 then begin
    {$IFNDEF CLR}if @_CertMgr_GetLastError <> nil then{$ENDIF}
      msg := _CertMgr_GetLastError(m_ctl);
  end;
  raise ThrowCoreException(err, msg);
end;

{$IFDEF LINUX}
procedure TipsCertMgr.OnSocketNotify(Socket: Integer);
begin
  if m_ctl <> nil then
    if @_CertMgr_Do <> nil then
      _CertMgr_Do(m_ctl, 2002{MID_DOSOCKETEVENTS}, 1, Pointer(@Socket), NIL);
end;
{$ENDIF}

{$IFNDEF CLR}
procedure TipsCertMgr.SetCertEncoded(lpCertEncoded: PChar; lenCertEncoded: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_CertMgr_Set = nil then exit;{$ENDIF}
  err := _CertMgr_Set(m_ctl, PID_CertMgr_CertEncoded, 0, Integer(lpCertEncoded), lenCertEncoded);
  if err <> 0 then TreatErr(err, '');
end;
procedure TipsCertMgr.SetCertStore(lpCertStore: PChar; lenCertStore: Cardinal);
var
  err: integer;
begin
  {$IFNDEF CLR}if @_CertMgr_Set = nil then exit;{$ENDIF}
  err := _CertMgr_Set(m_ctl, PID_CertMgr_CertStore, 0, Integer(lpCertStore), lenCertStore);
  if err <> 0 then TreatErr(err, '');
end;

{$ENDIF}

function TipsCertMgr.get_CertEffectiveDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertEffectiveDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertEffectiveDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertEncoded: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetBSTR(m_ctl, PID_CertMgr_CertEncoded, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertEncoded, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsCertMgr.set_StringCertEncoded(valCertEncoded: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _CertMgr_SetBSTR(m_ctl, PID_CertMgr_CertEncoded, 0, valCertEncoded, Length(valCertEncoded));

{$ELSE}
	if @_CertMgr_Set = nil then exit;
  err := _CertMgr_Set(m_ctl, PID_CertMgr_CertEncoded, 0, Integer(PChar(valCertEncoded)), Length(valCertEncoded));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsCertMgr.get_CertExpirationDate: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertExpirationDate, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertExpirationDate, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertIssuer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertIssuer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertIssuer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertPrivateKey: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertPrivateKey, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertPrivateKey, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertPrivateKeyAvailable: Boolean;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Boolean(_CertMgr_GetBOOL(m_ctl, PID_CertMgr_CertPrivateKeyAvailable, 0, err));
{$ELSE}
  result := BOOL(0);

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertPrivateKeyAvailable, 0, nil);
  result := BOOL(tmp);
{$ENDIF}
end;


function TipsCertMgr.get_CertPrivateKeyContainer: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertPrivateKeyContainer, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertPrivateKeyContainer, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertPublicKey: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertPublicKey, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertPublicKey, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertPublicKeyAlgorithm: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertPublicKeyAlgorithm, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertPublicKeyAlgorithm, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertPublicKeyLength: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_CertMgr_GetINT(m_ctl, PID_CertMgr_CertPublicKeyLength, 0, err));
{$ELSE}
  result := Integer(0);

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertPublicKeyLength, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsCertMgr.get_CertSerialNumber: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertSerialNumber, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertSerialNumber, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertSignatureAlgorithm: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertSignatureAlgorithm, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertSignatureAlgorithm, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertStore: String;
var
  val: String;
	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  len: cardinal;
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetBSTR(m_ctl, PID_CertMgr_CertStore, 0, len);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp, len);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertStore, 0, @len);
  SetString(val, PChar(tmp), len);
  result := val;
{$ENDIF}
end;
procedure TipsCertMgr.set_StringCertStore(valCertStore: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _CertMgr_SetBSTR(m_ctl, PID_CertMgr_CertStore, 0, valCertStore, Length(valCertStore));

{$ELSE}
	if @_CertMgr_Set = nil then exit;
  err := _CertMgr_Set(m_ctl, PID_CertMgr_CertStore, 0, Integer(PChar(valCertStore)), Length(valCertStore));
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsCertMgr.get_CertStorePassword: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertStorePassword, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertStorePassword, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsCertMgr.set_CertStorePassword(valCertStorePassword: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _CertMgr_SetCSTR(m_ctl, PID_CertMgr_CertStorePassword, 0, valCertStorePassword, 0);
{$ELSE}
	if @_CertMgr_Set = nil then exit;
  err := _CertMgr_Set(m_ctl, PID_CertMgr_CertStorePassword, 0, Integer(PChar(valCertStorePassword)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsCertMgr.get_CertStoreType: TipscertmgrCertStoreTypes;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := TipscertmgrCertStoreTypes(_CertMgr_GetENUM(m_ctl, PID_CertMgr_CertStoreType, 0, err));
{$ELSE}
  result := TipscertmgrCertStoreTypes(0);

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertStoreType, 0, nil);
  result := TipscertmgrCertStoreTypes(tmp);
{$ENDIF}
end;
procedure TipsCertMgr.set_CertStoreType(valCertStoreType: TipscertmgrCertStoreTypes);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _CertMgr_SetENUM(m_ctl, PID_CertMgr_CertStoreType, 0, Integer(valCertStoreType), 0);
{$ELSE}
	if @_CertMgr_Set = nil then exit;
  err := _CertMgr_Set(m_ctl, PID_CertMgr_CertStoreType, 0, Integer(valCertStoreType), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsCertMgr.get_CertSubject: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertSubject, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertSubject, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;
procedure TipsCertMgr.set_CertSubject(valCertSubject: String);
var
  err: integer;
begin
{$IFDEF CLR}
  err := _CertMgr_SetCSTR(m_ctl, PID_CertMgr_CertSubject, 0, valCertSubject, 0);
{$ELSE}
	if @_CertMgr_Set = nil then exit;
  err := _CertMgr_Set(m_ctl, PID_CertMgr_CertSubject, 0, Integer(PChar(valCertSubject)), 0);
{$ENDIF}
  if err <> 0 then TreatErr(err, '');
end;

function TipsCertMgr.get_CertThumbprintMD5: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertThumbprintMD5, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertThumbprintMD5, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertThumbprintSHA1: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertThumbprintSHA1, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertThumbprintSHA1, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertUsage: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertUsage, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertUsage, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;


function TipsCertMgr.get_CertUsageFlags: Integer;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := Integer(_CertMgr_GetLONG(m_ctl, PID_CertMgr_CertUsageFlags, 0, err));
{$ELSE}
  result := Integer(0);

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertUsageFlags, 0, nil);
  result := Integer(tmp);
{$ENDIF}
end;


function TipsCertMgr.get_CertVersion: String;
var

	tmp: {$IFDEF CLR}IntPtr{$ELSE}Pointer{$ENDIF};
  
  err: Integer;

begin
{$IFDEF CLR}
	result := '';
	tmp := _CertMgr_GetCSTR(m_ctl, PID_CertMgr_CertVersion, 0, 0);
	if tmp <> IntPtr.Zero	then result := Marshal.PtrToStringAnsi(tmp);

{$ELSE}
  result := AnsiString(PChar(nil));

	if @_CertMgr_Get = nil then exit;
  tmp := _CertMgr_Get(m_ctl, PID_CertMgr_CertVersion, 0, nil);
  result := AnsiString(PChar(tmp));
{$ENDIF}
end;




{$IFNDEF DELPHI3}
function TipsCertMgr.Config(ConfigurationString: String): String;
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


  err := _CertMgr_Do(m_ctl, MID_CertMgr_Config, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(ConfigurationString);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_Config, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsCertMgr.CreateCertificate(CertSubject: String; SerialNumber: Integer);

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

  param[i] := Marshal.StringToHGlobalAnsi(CertSubject);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := IntPtr(SerialNumber);
  paramcb[i] := 0;
  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_CreateCertificate, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);




  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(CertSubject);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Pointer(SerialNumber);
  paramcb[i] := 0;
  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_CreateCertificate, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsCertMgr.CreateKey(KeyName: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(KeyName);
  paramcb[i] := 0;

  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_CreateKey, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(KeyName);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_CreateKey, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsCertMgr.DeleteCertificate();

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



  err := _CertMgr_Do(m_ctl, MID_CertMgr_DeleteCertificate, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_DeleteCertificate, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsCertMgr.DeleteKey(KeyName: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(KeyName);
  paramcb[i] := 0;

  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_DeleteKey, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(KeyName);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_DeleteKey, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsCertMgr.ExportCertificate(PFXFile: String; Password: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(PFXFile);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Password);
  paramcb[i] := 0;

  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_ExportCertificate, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(PFXFile);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Password);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ExportCertificate, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsCertMgr.GenerateCSR(CertSubject: String; KeyName: String): String;
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

  param[i] := Marshal.StringToHGlobalAnsi(CertSubject);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(KeyName);
  paramcb[i] := 0;

  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_GenerateCSR, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(CertSubject);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(KeyName);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_GenerateCSR, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsCertMgr.ImportCertificate(PFXFile: String; Password: String; Subject: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(PFXFile);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Password);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(Subject);
  paramcb[i] := 0;

  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_ImportCertificate, 3, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);

	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);

	if param[2] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[2]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(PFXFile);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Password);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := PChar(Subject);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ImportCertificate, 3, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsCertMgr.ImportSignedCSR(SignedCSR: String; KeyName: String);

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

  param[i] := Marshal.StringToHGlobalAnsi(SignedCSR);
  paramcb[i] := Length(SignedCSR);

  i := i + 1;
  param[i] := Marshal.StringToHGlobalAnsi(KeyName);
  paramcb[i] := 0;

  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_ImportSignedCSR, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);
	if param[1] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[1]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(SignedCSR);
  paramcb[i] := Length(SignedCSR);

  i := i + 1;
  param[i] := PChar(KeyName);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ImportSignedCSR, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsCertMgr.IssueCertificate(CertSubject: String; SerialNumber: Integer);

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

  param[i] := Marshal.StringToHGlobalAnsi(CertSubject);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := IntPtr(SerialNumber);
  paramcb[i] := 0;
  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_IssueCertificate, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);




  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(CertSubject);
  paramcb[i] := 0;

  i := i + 1;
  param[i] := Pointer(SerialNumber);
  paramcb[i] := 0;
  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_IssueCertificate, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsCertMgr.ListCertificateStores(): String;
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



  err := _CertMgr_Do(m_ctl, MID_CertMgr_ListCertificateStores, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';



	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ListCertificateStores, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

function TipsCertMgr.ListKeys(): String;
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



  err := _CertMgr_Do(m_ctl, MID_CertMgr_ListKeys, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';



	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ListKeys, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

function TipsCertMgr.ListMachineStores(): String;
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



  err := _CertMgr_Do(m_ctl, MID_CertMgr_ListMachineStores, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';



	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ListMachineStores, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

function TipsCertMgr.ListStoreCertificates(): String;
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



  err := _CertMgr_Do(m_ctl, MID_CertMgr_ListStoreCertificates, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';



	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ListStoreCertificates, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

procedure TipsCertMgr.ReadCertificate(FileName: String);

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


  err := _CertMgr_Do(m_ctl, MID_CertMgr_ReadCertificate, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(FileName);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ReadCertificate, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsCertMgr.Reset();

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



  err := _CertMgr_Do(m_ctl, MID_CertMgr_Reset, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  



	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_Reset, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

procedure TipsCertMgr.SaveCertificate(FileName: String);

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


  err := _CertMgr_Do(m_ctl, MID_CertMgr_SaveCertificate, 1, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');



{$ELSE}
  

  param[i] := PChar(FileName);
  paramcb[i] := 0;

  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_SaveCertificate, 1, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');


{$ENDIF}
end;

function TipsCertMgr.ShowCertificateChain(): String;
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



  err := _CertMgr_Do(m_ctl, MID_CertMgr_ShowCertificateChain, 0, param, paramcb); 



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';



	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_ShowCertificateChain, 0, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

{$ENDIF}
end;

function TipsCertMgr.SignCSR(CSR: String; SerialNumber: Integer): String;
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

  param[i] := Marshal.StringToHGlobalAnsi(CSR);
  paramcb[i] := Length(CSR);

  i := i + 1;
  param[i] := IntPtr(SerialNumber);
  paramcb[i] := 0;
  i := i + 1;


  err := _CertMgr_Do(m_ctl, MID_CertMgr_SignCSR, 2, param, paramcb); 

	if param[0] <> IntPtr.Zero then Marshal.FreeCoTaskMem(param[0]);



  if err <> 0 then TreatErr(err, '');

  result := Marshal.PtrToStringAnsi(param[i]);


{$ELSE}
  result := '';

  param[i] := PChar(CSR);
  paramcb[i] := Length(CSR);

  i := i + 1;
  param[i] := Pointer(SerialNumber);
  paramcb[i] := 0;
  i := i + 1;


	if @_CertMgr_Do = nil then exit;
  err := _CertMgr_Do(m_ctl, MID_CertMgr_SignCSR, 2, @param, @paramcb); 
  if err <> 0 then TreatErr(err, '');

  result := AnsiString(PChar(param[i]));

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

	_CertMgr_Create := nil;
	_CertMgr_Destroy := nil;
	_CertMgr_Set := nil;
	_CertMgr_Get := nil;
	_CertMgr_GetLastError := nil;
	_CertMgr_StaticInit := nil;
	_CertMgr_CheckIndex := nil;
	_CertMgr_Do := nil;
	
	hResInfo := FindResource(HInstance, 'ipwssl6_certmgr_dta', RT_RCDATA);
	if hResInfo = 0 then exit;
	
	hResData := LoadResource(HInstance, hResInfo);
	if hResData = 0 then exit;
	
	pResData := LockResource(hResData);
	if pResData = nil then exit;
	
	pBaseAddress := IPWorksSSLLoadDRU(pResData, pEntryPoint);
	if Assigned(pBaseAddress) then begin
		@_CertMgr_Create       := IPWorksSSLFindFunc(pBaseAddress, 'CertMgr_Create');
		@_CertMgr_Destroy      := IPWorksSSLFindFunc(pBaseAddress, 'CertMgr_Destroy');
		@_CertMgr_Set          := IPWorksSSLFindFunc(pBaseAddress, 'CertMgr_Set');
		@_CertMgr_Get          := IPWorksSSLFindFunc(pBaseAddress, 'CertMgr_Get');
		@_CertMgr_GetLastError := IPWorksSSLFindFunc(pBaseAddress, 'CertMgr_GetLastError');
		@_CertMgr_CheckIndex   := IPWorksSSLFindFunc(pBaseAddress, 'CertMgr_CheckIndex');
		@_CertMgr_Do           := IPWorksSSLFindFunc(pBaseAddress, 'CertMgr_Do');
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
  @_CertMgr_Create       := nil;
  @_CertMgr_Destroy      := nil;
  @_CertMgr_Set          := nil;
  @_CertMgr_Get          := nil;
  @_CertMgr_GetLastError := nil;
  @_CertMgr_CheckIndex   := nil;
  @_CertMgr_Do           := nil;
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




