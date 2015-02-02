unit WinUtils;
//------------------------------------------------------------------------------
{
   Title:        BankLink Windows Utils unit

   Description:  Utilities for Windows OS

   Remarks:      The VersionInfo singleton was added to provide a single
                 point of access for the application version information.

   Author:       ?, Scott Wilson

}
//------------------------------------------------------------------------------

interface

uses
  Windows, ShlObj;

type
  TDriveState=(dsNoDisk, dsUnformattedDisk, dsEmptyDisk, dsDiskWithFiles);

  TVersionInfo = class(TObject)
  private
    FComments: string;
    FCompanyName: string;
    FFileDescription: string;
    FFileVersion: string;
    FInternalName: string;
    FLegalCopyright: string;
    FLegalTrademarks: string;
    FOriginalFilename: string;
    FPrivateBuild: string;
    FProductName: string;
    FProductVersion: string;
    FSpecialBuild: string;
    FVersionDataAvailable: Boolean;
    FAppVerMinor: integer;
    FAppVerRelease: integer;
    FAppVerMajor: integer;
    FAppVerBuild: integer;
    procedure LoadVersionInfo;
    function GetCompanyName: string;
    function GetFileDescription: string;
    function GetLegalCopyright: string;
    function GetProductName: string;
  public
    constructor Create;
    function GetAppVersionStr: string;
    property Comments: string read FComments;
    property CompanyName: string read GetCompanyName;
    property FileDescription: string read GetFileDescription;
    property FileVersion: string read FFileVersion;
    property InternalName: string read FInternalName;
    property LegalCopyright: string read GetLegalCopyright;
    property LegalTrademarks: string read FLegalTrademarks;
    property OriginalFilename: string read FOriginalFilename;
    property PrivateBuild: string read FPrivateBuild;
    property ProductName: string read GetProductName;
    property ProductVersion: string read FProductVersion;
    property SpecialBuild: string read FSpecialBuild;
    property AppVerMajor: integer read FAppVerMajor;
    property AppVerMinor: integer read FAppVerMinor;
    property AppVerRelease: integer read FAppVerRelease;
    property AppVerBuild: integer read FAppVerBuild;
  end;

  function BKFileExists(Filename: string): Boolean;
  function DriveState( drive : string ): TDriveState;
  function GetAppVersionStr : string;
  function GetAppYearVersionStr : string;
  function GetDefaultCountryCode : string;
  function GetFileSize( FileName: string ) : Int64;
  function GetFileTimeAsInt64( FileName : string ) : int64;
  function GetGlobalEnvironment(const Name : string;
                                const User: Boolean = True): string;
  function GetScreenColors( CanvasHandle : hDC): Int64;
  function GetShortAppVersionStr : string;
  function GetTempDir( const DefaultDir : string) : string;
  function GetTicksSince(StartTick : DWORD) : Integer;
  function GetWinDir: string;
  function GetWinSysDir: string;
  function GetWinVer: string;
  function IsWin2000_or_later: boolean;
  function IsWindowsVista: Boolean;
  function ReadComputerName(AllowBlankClient: bool = true): string;
  function ReadUserName : string;
  function RegisterOCX(FileName: string): Boolean;
  function SetGlobalEnvironment(const Name, Value: string;
                                const User: Boolean = True): Boolean;
  function ShellGetFolderPath(CSIDL: Integer): string;
  function GetMyDocumentsPath: string;
  function UnRegisterOCX(FileName: string): Boolean;
  procedure DeleteFiles(Name: string);
  procedure ErrorSound;
  procedure GetBuildInfo(Var v1, v2, v3, v4: Word);
  procedure InfoSound;
  procedure RemoveFile( const FileName : string );
  procedure RenameFileEx( const OldName, NewName : string );
  procedure ResetProcessWorkingSet;

  //Singleton
  function VersionInfo: TVersionInfo;

  function GetClientRequestOpsLockEnabled: Boolean;
  function GetServerGrantOpsLockEnabled: Boolean;
  function GetServerSMB2Enabled: Boolean;


//******************************************************************************
implementation
uses
  SysUtils, TSUtils, Registry, Messages, SHFolder, bkProduct;

const
  UnitName = 'FILES';

{$WARN SYMBOL_PLATFORM OFF}

{$IFDEF bkUseFinalBuilderVer}
  {$include version.inc}
{$ENDIF}

type
  TDllRegisterServer = function: HResult; stdcall;

var
  _VersionInfo: TVersionInfo;
  FAppVersionStr : string;
  FShortAppVersionStr :  string;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function VersionInfo: TVersionInfo;
begin
  if (_VersionInfo = nil) then
    _VersionInfo := TVersionInfo.Create;
  Result := _VersionInfo;
end;

function GetClientRequestOpsLockEnabled: Boolean;
const
  CLIENT_OPSLOCK_KEY: String = 'System\CurrentControlSet\Services\MRXSmb\Parameters';
    
var
  Registry: TRegistry;
begin
  Result := True;
    
  Registry := TRegistry.Create;

  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;

    if Registry.OpenKeyReadOnly(CLIENT_OPSLOCK_KEY) then
    begin
      try
        Result := Registry.ReadInteger('OplocksDisabled') = 0;
      except
        //do nothing
      end;
    end;
  finally
    Registry.Free;
  end;
end;

function GetServerGrantOpsLockEnabled: Boolean;
const
  SERVER_OPSLOCK_KEY: String = 'SYSTEM\CurrentControlSet\services\LanmanServer\Parameters';

var
  Registry: TRegistry;
begin
  Result := True;

  Registry := TRegistry.Create;

  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;

    if Registry.OpenKeyReadOnly(SERVER_OPSLOCK_KEY) then
    begin
      try
        Result := Registry.ReadInteger('EnableOplocks') = 1;
      except
        //do nothing
      end;
    end;
  finally
    Registry.Free;
  end;
end;

function GetServerSMB2Enabled: Boolean;
const
  SERVER_OPSLOCK_KEY: String = 'SYSTEM\CurrentControlSet\services\LanmanServer\Parameters';

var
  Registry: TRegistry;
begin
  Result := True;

  Registry := TRegistry.Create;

  try
    Registry.RootKey := HKEY_LOCAL_MACHINE;

    if Registry.OpenKeyReadOnly(SERVER_OPSLOCK_KEY) then
    begin
      try
        Result := Registry.ReadInteger('SMB2') = 1;
      except
        //do nothing
      end;
    end;
  finally
    Registry.Free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetScreenColors( CanvasHandle : hDC): Int64;
var
  n1, n2: longint;
begin
  n1 := GetDeviceCaps( CanvasHandle, PLANES );
  n2 := GetDeviceCaps( CanvasHandle, BITSPIXEL );
  Result := Int64( 1 ) shl ( n1 * n2 );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetTempDir( const DefaultDir : string) : string;
var
  DirLen  : DWord;
  TempDir : string;
begin
  TempDir := DefaultDir;
  DirLen  := Windows.GetTempPath( 0, nil );
  if DirLen > 0 then begin
    SetLength( TempDir, Pred( DirLen ) );
    GetTempPath( DirLen, PChar( TempDir ) );
    TempDir := ExtractFilePath( TempDir );
  end;
  Result := TempDir;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ErrorSound;
begin
  MessageBeep(MB_ICONEXCLAMATION);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure InfoSound;
begin
  MessageBeep(MB_ICONASTERISK);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GetBuildInfo(Var v1, v2, v3, v4: Word);
begin
{$IFDEF bkUseFinalBuilderVer}
  //all values are read from the version.inc file that is filled in when the
  //build is done
  v1 := VERMAJOR;
  v2 := VERMINOR;
  v3 := VERRELEASE;
  v4 := VERBUILD;
{$ELSE}
  v1 := VersionInfo.AppVerMajor;
  v2 := VersionInfo.AppVerMinor;
  v3 := VersionInfo.AppVerRelease;
  v4 := VersionInfo.AppVerBuild;
{$ENDIF}
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetAppVersionStr : string;
//only call getbuildinfo if string not already set, should not change during
//course of session
var
  v1,v2,v3,v4 : word;
begin
  if FAppVersionStr = '' then
  begin
    GetBuildInfo( v1, v2, v3, v4);
    FAppVersionStr := inttostr(v1)+'.'+
                      inttostr(v2)+'.'+
                      inttostr(v3)+' Build '+ inttostr(v4);
  end;
  Result := FAppVersionStr
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetAppYearVersionStr : string;
begin
{$IFDEF bkUseFinalBuilderVer}
  Result := VERYEAR;
{$ELSE}
  Result := '2015';
{$ENDIF}
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetShortAppVersionStr : string;
begin
  Result := VersionInfo.FileVersion;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetWinVer: string;
type
  { Variant record used to help decipher the long integer containing
    the build number, returned by the GetVersionEx routine in the
    OSVERSIONINFO record }
  TBuildNumber = record
  case Byte of
    0: (VersionInfo: Longint);
    1: (BuildNumber: Word; MinorNumber: Byte; MajorNumber: Byte);
  end;

var
  OSVersionInfo32: OSVERSIONINFO;
  name: string;
begin
  Result := '';

  OSVersionInfo32.dwOSVersionInfoSize := SizeOf(OSVersionInfo32);
  GetVersionEx(OSVersionInfo32);

  case OSVersionInfo32.dwPlatformId of
    VER_PLATFORM_WIN32s:
      with OSVersionInfo32 do
        begin
          Name := 'Windows 3.xx (WIN32)';
          Result := Format('%s %d.%.2d.%d%s',
            [Name, dwMajorVersion, dwMinorVersion,
            TBuildNumber(dwBuildNumber).BuildNumber,
              szCSDVersion])
        end;
    VER_PLATFORM_WIN32_WINDOWS: { Windows 95/98 }
      with OSVersionInfo32 do
        begin
          if dwMajorVersion = 4 then
            begin
              if (dwMinorVersion < 10) then
                { Windows 95 }
                Name := 'Windows 95'
              else
                if (dwMinorVersion < 90) then
                  { Windows 98 }
                  Name := 'Windows 98'
                else
                  { Windows ME }
                  Name := 'Windows ME';
            end
          else
            Name := 'Windows 9x (Unknown)';

          Result := Format('%s %d.%.2d.%d%s',
            [Name, dwMajorVersion, dwMinorVersion,
            TBuildNumber(dwBuildNumber).BuildNumber,
              szCSDVersion])
        end; { end with }
    VER_PLATFORM_WIN32_NT: { Windows NT }
      with OSVersionInfo32 do
        begin
          if (dwMajorVersion < 4) then
            { Windows NT 3.5x }
            Name := 'Windows NT 3.5x'
          else
            if (dwMajorVersion < 5) then
              { Windows NT 4 }
              Name := 'Windows NT 4'
            else if dwMajorVersion = 6 then
              Name := 'Windows Vista'
            else
              { Windows 2000 }
              if dwMinorVersion = 0 then
                Name := 'Windows 2000'
              else
                Name := 'Windows XP';
          Result := Format('%s %d.%.2d.%d %s', [name, dwMajorVersion,
            dwMinorVersion, TBuildNumber(dwBuildNumber).BuildNumber,
              szCSDVersion]);
        end;
  end; { end case }
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsWin2000_or_later: boolean;
var
  OSVersionInfo32: OSVERSIONINFO;
begin
  OSVersionInfo32.dwOSVersionInfoSize := SizeOf(OSVersionInfo32);
  GetVersionEx(OSVersionInfo32);

  case OSVersionInfo32.dwPlatformId of
    VER_PLATFORM_WIN32s,   { Windows 3.x}
    VER_PLATFORM_WIN32_WINDOWS: { Windows 95/98 }
       Result := false;
  else
    Result := true;
  end; { end case }
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ReadUserName : string;
const
  MAX_USERNAME_LENGTH = 20;
var
  pUserName : array [0..MAX_USERNAME_LENGTH + 1] Of Char;
  pSize     : DWORD;
begin
  pSize := MAX_USERNAME_LENGTH;
  if Windows.getusername(pUserName, pSize) then
  begin
    Result := SysUtils.StrPas(pUserName)
  end
  else
  begin
    Result := ''
  end
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ReadComputerName(AllowBlankClient: bool = true): string;
// Originally it would allow for Blank Client, because  UsingTerminalServices is always true (Since XP)
// If you Dont want that pass in false.. and it will only show the client if there is one...
var
  pCompName : Array [0..MAX_COMPUTERNAME_LENGTH + 1] Of Char;
  pSize     : DWORD;
begin
  Result := '';
  pSize  := MAX_COMPUTERNAME_LENGTH + 1;
  if Windows.GetComputerName( pCompName, pSize ) then
    Result := SysUtils.StrPas( pCompName );

  if (TSUtils.UsingTerminalServices) then
     if AllowBlankClient
     or (TSClientName > '') then begin
        Result := Result + ' [' + TSClientName + ']';
     end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetTicksSince(StartTick : LongWord) : Integer;
//gets the systems ticks that have elasped since StartTick.
//extra logic is required to make sure no range error occurs
//GetTicksCount returns a LongWord that can wrap around to 0 after 49 days
var
  NowTick   : LongWord;
  TickDiff  : LongWord;
begin
  NowTick := GetTickCount;
  //calculate DWORD difference
  if NowTick >= StartTick then
    TickDiff := NowTick - StartTick
  else
    TickDiff := NowTick; //word has wrapped around to 0, start counting again from 0

  if TickDiff > LongWord(High(Integer)) then
    Result := High(Integer)
  else
    Result := Integer(TickDiff);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetWindowsFileTime(FileName : string) : TFileTime;
(*
  WINDOWS.PAS definition of TFILETIME =
  record
     dwLowDateTime: DWORD;
     dwHighDateTime: DWORD;
  end;

  Can be typecast as an Int64
*)
var
  Handle   : THandle;
  NotFound : TFileTime;
  FindData : TWin32FindData;
begin
  FillChar( NotFound, Sizeof( NotFound ), 0 );
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then begin
      Result := FindData.ftLastWriteTime;
      Exit;
    end;
  end;
  Result := NotFound;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetFileTimeAsInt64(FileName : string) : int64;
var
  Handle    : THandle;
  FindData  : TWin32FindData;
begin
  Result := -1;
  Handle := FindFirstFile( PChar( FileName ), FindData );
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    Result := int64( FindData.ftLastWriteTime );
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetFileSize(FileName: string) : Int64;
var
  Handle   : THandle;
  FindData : TWin32FindData;
  Converter: packed record
    case Boolean of
      false: ( n : int64 );
      true : ( low, high: DWORD );
    end;
begin
  Result := -1;
  Handle := FindFirstFile(PChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    Converter.low  := FindData.nFileSizeLow;
    Converter.high := FindData.nFileSizeHigh;
    Result := Converter.N;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RemoveFile(const FileName : string);
const
  SDeleteError = 'Cannot delete %0:s: %1:s';
  RETRY_COUNT = 20;
var
  Tries: integer;
begin
  Sleep(10);
  if BKFileExists(FileName) then
  begin
    Tries := 0;
    repeat
      Inc(Tries);
      DeleteFile(FileName);
      Sleep(10 * Tries);
    until (not BKFileExists(FileName) or (Tries > RETRY_COUNT));
    if Tries > RETRY_COUNT then
      raise Exception.CreateFmt(SDeleteError, [FileName, SysErrorMessage(GetLastError)]);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RenameFileEx( const OldName, NewName : string );
const
  SRenameError = 'Cannot rename %0:s to %1:s, %2:s';
begin
  if not SysUtils.RenameFile(OldName, NewName) then
    raise Exception.CreateFmt(SRenameError, [OldName, NewName, SysErrorMessage(GetLastError)]);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DriveState( drive : string ): TDriveState;
var
  mask : string;
  sRec: TSearchRec;
  oldMode: Cardinal;
  retcode: Integer;
begin
  oldMode:= SetErrorMode( SEM_FAILCRITICALERRORS );
  try
    mask:= Drive + '*.*';
    retcode := FindFirst( mask, faAnyfile, SRec );
    try
      case Abs(retcode) Of
         0: Result := dsDiskWithFiles;  { found at least one file }
        18, 2: Result := dsEmptyDisk;  { found no files but otherwise ok }
        21, 3: Result := dsNoDisk; { DOS ERROR_NOT_READY on WinNT, ERROR_PATH_NOT_FOUND on Win9x}
      else
        Result := dsUnformattedDisk;
      end;
    finally
      FindClose( SRec );
    end;
  finally
    SetErrorMode( oldMode );
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// #1847 - FileExists is a known performance problem over network drives
function BKFileExists(Filename: string): Boolean;
begin
  Result := GetFileAttributes(PChar(FileName)) <> $FFFFFFFF;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetWinDir: string;
begin
  SetLength(Result, MAX_PATH);
  GetWindowsDirectory(PChar(Result), MAX_PATH);
  SetLength(Result, StrLen(PChar(Result)));
  Result := IncludeTrailingPathDelimiter(Result);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetWinSysDir: string;
begin
  SetLength(Result, MAX_PATH);
  GetSystemDirectory(PChar(Result), MAX_PATH);
  SetLength(Result, StrLen(PChar(Result)));
  Result := IncludeTrailingPathDelimiter(Result);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Delete files using wildcards
procedure DeleteFiles(Name: string);
var
 srec: TSearchRec;
 dir: string;
begin
  dir := ExtractFilePath(Name);
  if FindFirst(Name, faAnyFile, srec) = 0 then
  try
    repeat
      DeleteFile(dir + srec.Name);
    until FindNext(srec) <> 0;
  finally
    FindClose(srec);
  end;
end;

{*********************************************}
{ Set Global Environment Function             }
{ Coder : Kingron,2002.8.6                    }
{ Parameter:                                  }
{ Name : environment variable name            }
{ Value: environment variable Value           }
{ Ex: SetGlobalEnvironment('MyVar','OK')      }
{*********************************************}

function SetGlobalEnvironment(const Name, Value: string; const User: Boolean = True): Boolean;
const
  REG_MACHINE_LOCATION = 'System\CurrentControlSet\Control\Session Manager\Environment';
  REG_USER_LOCATION = 'Environment';
begin
  with TRegistry.Create do
    try
      if User then { User Environment Variable }
        Result := OpenKey(REG_USER_LOCATION, True)
      else { System Environment Variable }
      begin
        RootKey := HKEY_LOCAL_MACHINE;
        Result  := OpenKey(REG_MACHINE_LOCATION, True);
      end;
      if Result then
      begin
        WriteString(Name, Value); { Write Registry for Global Environment }
        { Update Current Process Environment Variable }
        SetEnvironmentVariable(PChar(Name), PChar(Value));
        { Send Message To All Top Window for Refresh }
        SendMessage(HWND_BROADCAST, WM_SETTINGCHANGE, 0, Integer(PChar('Environment')));
      end;
    finally
      Free;
    end;
end; { SetGlobalEnvironment }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetGlobalEnvironment(const Name : string; const User: Boolean = True): string;
const
  REG_MACHINE_LOCATION = 'System\CurrentControlSet\Control\Session Manager\Environment';
  REG_USER_LOCATION = 'Environment';
var
  ok : boolean;
begin
  Result := '';
  with TRegistry.Create do
    try
      if User then { User Environment Variable }
        ok := OpenKeyReadOnly(REG_USER_LOCATION)
      else { System Environment Variable }
      begin
        RootKey := HKEY_LOCAL_MACHINE;
        ok  := OpenKeyReadOnly(REG_MACHINE_LOCATION);
      end;
      if ok then
      begin
        Result := ReadString(Name);
      end;
    finally
      Free;
    end;
end; { SetGlobalEnvironment }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetDefaultCountryCode : string;
begin
  Result := GetLocaleStr( GetUserDefaultLCID, LOCALE_ICOUNTRY, '');
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ResetProcessWorkingSet;
var
  xHandle : THandle;
  xOldMin : DWord;
  xOldMax : DWord;
begin
  if ( GetVersion < $80000000 ) then // = if NT
  begin
    xHandle := GetCurrentProcess;
    if not GetProcessWorkingSetSize( xHandle, xOldMin, xOldMax ) or
      not SetProcessWorkingSetSize( xHandle, DWORD( -1 ) , DWORD( -1 ) ) or
      not SetProcessWorkingSetSize( xHandle, xOldMin, xOldMax ) then
    begin
      //      raise exception.create( 'Error resetting the ProcessWorkingSize');
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ShellGetFolderPath(CSIDL: Integer): string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  FillChar(Buffer, MAX_PATH, 0);
  if SHGetFolderPath(0, CSIDL, 0, 0, Buffer) = S_OK then // pre-win2k
    Result := IncludeTrailingPathDelimiter(Buffer)
  else
    Result := GetWinDir;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetMyDocumentsPath: string;
var
  Path: array[0..MAX_PATH] of Char;
begin
  Result := '';
  if ShGetSpecialFolderPath(0, Path, CSIDL_Personal, False)  then
    Result := Path;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function RegisterOCX(FileName: string): Boolean;
var
  OCXHand: THandle;
  RegFunc: TDllRegisterServer;
begin
  OCXHand := LoadLibrary(PChar(FileName));
  RegFunc := GetProcAddress(OCXHand, 'DllRegisterServer');
  if @RegFunc <> nil then
    Result := RegFunc = S_OK
  else
    Result := False;
  FreeLibrary(OCXHand);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UnRegisterOCX(FileName: string): Boolean;
var
  OCXHand: THandle;
  RegFunc: TDllRegisterServer;
begin
  OCXHand := LoadLibrary(PChar(FileName));
  RegFunc := GetProcAddress(OCXHand, 'DllUnregisterServer');
  if @RegFunc <> nil then
    Result := RegFunc = S_OK
  else
    Result := False;
  FreeLibrary(OCXHand);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsWindowsVista: Boolean;
var
  VerInfo: TOSVersioninfo;
begin
  VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(VerInfo);
  Result := VerInfo.dwMajorVersion >= 6;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{ TVersionInfo }

constructor TVersionInfo.Create;
begin
  inherited Create;

  LoadVersionInfo;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TVersionInfo.GetAppVersionStr: string;
begin
  Result := Format('%d.%d.%d Build %d',
                   [FAppVerMajor, FAppVerMinor, FAppVerRelease, FAppVerBuild]);
end;
function TVersionInfo.GetCompanyName: string;
begin
  Result := TProduct.Rebrand(FCompanyName);
end;

function TVersionInfo.GetFileDescription: string;
begin
  Result := TProduct.Rebrand(FFileDescription);
end;

function TVersionInfo.GetLegalCopyright: string;
begin
  if TProduct.ProductBrand = btBankstream then
  begin
    Result := Chr(169) + ' '  + TProduct.BrandName + ' Limited 2013';
  end
  else
  begin
    Result := FLegalCopyright;
  end;
end;

function TVersionInfo.GetProductName: string;
begin
  Result := TProduct.Rebrand(FProductName);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TVersionInfo.LoadVersionInfo;
const
  SUB_BLOCK_TRANSLATION = '\VarFileInfo\Translation';
  SUB_BLOCK_COMMENTS = '\Comments';
  SUB_BLOCK_COMPANY_NAME = '\CompanyName';
  SUB_BLOCK_FILEDESCRIPTION = '\FileDescription';
  SUB_BLOCK_FILEVERSION = '\FileVersion';
  SUB_BLOCK_INTERNALNAME = '\InternalName';
  SUB_BLOCK_PRODUCTVERSION = '\ProductVersion';
  SUB_BLOCK_LEGALCOPYRIGHT = '\LegalCopyright';
  SUB_BLOCK_LEGALTRADEMARKS = '\LegalTrademarks';
  SUB_BLOCK_ORIGINALFILENAME = '\OriginalFilename';
  SUB_BLOCK_PRODUCTNAME = '\ProductName';
//  RES_NAME_STR = '\StringFileInfo\%8.8lx';
  RES_NAME_STR = '\StringFileInfo\%8.8x';
var
  InfoSize,           // Size of VERSIONINFO structure
  VerSize,            // Size of Version Info Data
  Wnd: DWORD;         // Handle for the size call.
  VSFixedFileInfo: PVSFixedFileInfo; // Delphi structure; see WINDOWS.PAS
  VerBuf: Pointer;   // pointer to a version buffer
  FileName: string;          // Name of the file to check
  Data: PChar;
  TranslCode: ^longint;
  TCode: integer;
  TransArray: array [0..1] of word;
  ResName: PChar;
begin
  FileName := ParamStr(0);
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if (InfoSize = 0) then
    FVersionDataAvailable := False
  else begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then begin
        VerQueryValue(VerBuf, SUB_BLOCK_TRANSLATION, Pointer(TranslCode), VerSize);
        if (VerSize <> 0) then begin
          TransArray[0] := HiWord(TranslCode^);
          TransArray[1] := LoWord(TranslCode^);
          TCode := MakeLong(TransArray[0], TransArray[1]);
          ResName := PChar(Format(RES_NAME_STR, [TCode]));
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_COMMENTS), Pointer(Data), VerSize) then
            FComments := Data;
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_COMPANY_NAME), Pointer(Data), VerSize) then
            FCompanyName := Data;
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_FILEDESCRIPTION), Pointer(Data), VerSize) then
            FFileDescription := Data;
          if VerQueryValue(VerBuf, Pchar(ResName + SUB_BLOCK_FILEVERSION), Pointer(Data), VerSize) then
            FFileVersion := Data;
          if VerQueryValue(VerBuf, '\', Pointer(VSFixedFileInfo), VerSize) then begin
            FAppVerMajor := VSFixedFileInfo.dwFileVersionMS shr 16;
            FAppVerMinor := VSFixedFileInfo.dwFileVersionMS and $FFFF;
            FAppVerRelease := VSFixedFileInfo.dwFileVersionLS shr 16;
            FAppVerBuild := VSFixedFileInfo.dwFileVersionLS and $FFFF;
          end;
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_INTERNALNAME), Pointer(Data), VerSize) then
            FInternalName := Data;
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_PRODUCTVERSION), Pointer(Data), VerSize) then
            FProductVersion := Data;
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_LEGALCOPYRIGHT), Pointer(Data), VerSize) then
            FLegalCopyright := Data;
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_LEGALTRADEMARKS), Pointer(Data), VerSize) then
            FLegalTrademarks := Data;
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_ORIGINALFILENAME), Pointer(Data), VerSize) then
            FOriginalFilename := Data;
          if VerQueryValue(VerBuf, PChar(ResName + SUB_BLOCK_PRODUCTNAME), Pointer(Data), VerSize) then
            FProductName := Data;
        end;
      end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
  FAppVersionStr := '';
  FShortAppVersionStr := '';
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
finalization
  FreeAndNil(_VersionInfo);
end.
