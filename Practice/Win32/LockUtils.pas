unit LockUtils;

{
   Title : Lock Utilities

   Description: Generalised lock/unlock routines using a single shared file for locking.
   A "Waiting For..." dialog will appear if it is compiled into a GUI app.

   Author : Steve 01/2001

   Feb 02 - Raises an exception if we get an unexpected result while locking or unlocking.

}
                                                         
//------------------------------------------------------------------------------
interface

uses
  Windows,
  IPClientLocking,
  PracticeClientServer,
  WaitDlg;

const
  ltMin                   = 1;
  ltSystemLog             = 2;
  ltAdminSystem           = 3;
  ltStartupCheck          = 4;
  ltPracIni               = 5;
  ltPracLogo              = 6;
  ltClientToDoList        = 7;
  ltClientDetailsCache    = 8;
  ltClientNotes           = 9;
  ltPracHeaderFooterImg   = 10;
  ltAdminOptions          = 11;
  ltUsageStatistics       = 12;
  ltScheduledReport       = 13;
  ltCustomDocument        = 14;
  ltCodingStats           = 15;
  ltWebNotesupdate        = 16;
  ltWebNotesdata          = 17;
  ltExchangeRates         = 18;
  ltBlopiServiceAgreement = 19;
  ltMemsIni               = 20;
  ltCashBookStartCashe    = 21;
  ltCashBookDetailCashe   = 22;

  ltMax = 22;

  TimeToWaitForPracINI  = 60;
  TimeToWaitForPracLogo = 30;
  LOG_LOCK_DELAY        = 1000;

  UnitName = 'LockUtils';

Type
  //----------------------------------------------------------------------------
  TFileCheckStatus = (fcsOK,
                      fscException,
                      fcsCanNotFind,
                      fcsCanNotOpen,
                      fcsCanNotLock);

  TLockState = (lsLocking, lsUnlocking);

  //----------------------------------------------------------------------------
  // Base Locking Class : has the public Lock and unlock methods, handles the
  // Locking Delay form and the Main Locking Loop
  TFileLocking = class
  private
    fDelayForm  : TDelayForm;
    fWindowList : Pointer;

    fMinTicksBeforeShowProgress : Dword;

    fLockType : integer;
    fLockRef : integer;
    fMaxSecsToWait : Integer;
    fLockState : TLockState;
    fLockMessageDisplaying : boolean;

    fNetLockingOn : boolean;
  protected
    procedure CreateDelayForm(aTicksToWait : Dword);
    procedure UpdateDelayForm(aElapsedTicks, aTicksToWait : Dword);
    procedure DestroyDelayForm;

    function WaitingMessageLoop(aLockState : TLockState) : boolean;

    function InitialLockingCall() : Boolean; virtual; abstract;
    function LoopLockingCall() : Boolean; virtual; abstract;
  public
    function ObtainLock( const aLockType, aMaxSecsToWait : Integer ): Boolean; overload;
    function ObtainLock( const aLockType, aLockRef, aMaxSecsToWait : Integer ): Boolean; overload;

    function ReleaseLock( const aLockType : Integer ): Boolean; overload;
    function ReleaseLock( const aLockType, aLockRef : integer): Boolean; overload;

    property MinTicksBeforeShowProgress : Dword read fMinTicksBeforeShowProgress write fMinTicksBeforeShowProgress;
    property LockMessageDisplaying : boolean read fLockMessageDisplaying write fLockMessageDisplaying;
    property NetLockingOn : boolean read fNetLockingOn write fNetLockingOn;
  end;

  //----------------------------------------------------------------------------
  // Windows file Locking
  TWindowsFileLocking = class(TFileLocking)
  private
    fLockPos : DWord;
    FLockFileName: string;
    FLockFileHandle: Integer;
  protected
    function LockFileHandle: Integer;
    function GetLockPosition(const LockType, LockRef : integer) : DWord;
    function LockFileEx( const LockPos : DWord ) : Boolean;
    function UnLockFileEx(const LockPos: DWord) : Boolean;

    function InitialLockingCall() : Boolean; override;
    function LoopLockingCall() : Boolean; override;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure SetLockingFileLocation( aLockDir : string);
  end;

  //----------------------------------------------------------------------------
  // TCP Client/Server Locking
  TNetworkFileLocking = class(TFileLocking)
  private
    fRequestID : DWord;
    fLockWriteSuccessful : Boolean;
    fIPClientLock : TIPClientLocking;
    fLockMessageDisplaying : boolean;
  protected
    function ReadFromServer() : boolean;
    function CritSecWriteReadFromServer() : boolean;

    function InitialLockingCall() : Boolean; override;
    function LoopLockingCall() : Boolean; override;

    procedure OnLockLogging(aMethod : String; aMesssage : String);

    function GetServerIP() : string;
    procedure SetServerIP(aValue : string);
    function GetServerPort() : string;
    procedure SetServerPort(aValue : string);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure InitilizeIPLocking(aUDP_Client_Port : integer;
                                 aUDP_BuffInitSize : integer;
                                 aDiscoveryTimeOut : dword;
                                 aUDPTimeOut : dword;
                                 aLockTimeOut : dword;
                                 aTCPTimeOut : dword;
                                 aProcessMessageDelay : dword;
                                 aServer_IP : string;
                                 aServer_Port : integer;
                                 aGroup_ID : string);

    procedure ClientIPLoginUser(aUserCode : string; aWorkstation : string);

    property LockMessageDisplaying : boolean read fLockMessageDisplaying write fLockMessageDisplaying;
    property ServerIP : string read GetServerIP write SetServerIP;
    property ServerPort : string read GetServerPort write SetServerPort;
  end;

// Called just after the first read of the Ini file so it can init the locking
// and then use locking before writing the ini file
procedure InitLocking(aNetLockingOn : Boolean = false;
                      aUDP_Client_Port : integer = 0;
                      aUDP_BuffInitSize : integer = 0;
                      aDiscoveryTimeOut : dword = 0;
                      aUDPTimeOut : dword = 0;
                      aLockTimeOut : dword = 0;
                      aTCPTimeOut : dword = 0;
                      aProcessMessageDelay : dword = 0;
                      aServer_IP : string = '';
                      aServer_Port : integer = 0;
                      aGroupId : string = '' );
function GetFileLockStatus(aFilePath : string) : TFileCheckStatus;

var
  FileLocking : TFileLocking;

//------------------------------------------------------------------------------
implementation
//WARNING: THIS UNIT IS USED BY ERROR LOG.  DO NOT LINK TO ANY OTHER BK5 UNITS AS
//         THESE MAY CAUSE OTHER UNITS TO BE INITIALISED BEFORE THE ERROR LOG UNIT!
uses
  Forms,
  SysUtils,
  TimeUtils,
  WinUtils,
  IdExceptionCore,
  IdException,
  MadStackTrace,
  LogUtil,
  ErrorLog,
  SyncObjs,
  bkProduct;

const
  TICKS_PER_SECOND = 1000;
  TICKS_BEFORE_DELAY_SHOWN = 2000;

  ltNames : Array[ ltMin..ltMax ] of String[80] =
    ( '',
      'System Log',
      'System Database',
      'Startup Check',
      'Practice INI File',
      'Practice Logo File',
      'Client Task List',
      'Client Details Cache',
      'Client Notes',
      'Header/Footer Image File',
      'Admin System Options',
      'Usage Statistics',
      'Scheduled Reports',
      'Custom Documents',
      'Coding Statistics',
      'WebNotes Update',
      'WebNotes Data',
      'Exchange Rates',
      'BankLink Online Service Agreement',
      'Memorisation INI File',
      'CashBook Before you start Cashe',
      'CashBook Migration details Cashe'
      );

var
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
procedure InitLocking(aNetLockingOn : Boolean;
                      aUDP_Client_Port : integer;
                      aUDP_BuffInitSize : integer;
                      aDiscoveryTimeOut : dword;
                      aUDPTimeOut : dword;
                      aLockTimeOut : dword;
                      aTCPTimeOut : dword;
                      aProcessMessageDelay : dword;
                      aServer_IP : string;
                      aServer_Port : integer;
                      aGroupId : string);
begin
  DebugMe := DebugUnit( UnitName );

  if aNetLockingOn then
  begin
    FileLocking := TNetworkFileLocking.Create;
    TNetworkFileLocking(FileLocking).InitilizeIPLocking(aUDP_Client_Port,
                                                        aUDP_BuffInitSize,
                                                        aDiscoveryTimeOut,
                                                        aUDPTimeOut,
                                                        aLockTimeOut,
                                                        aTCPTimeOut,
                                                        aProcessMessageDelay,
                                                        aServer_IP,
                                                        aServer_Port,
                                                        aGroupId);
  end
  else
    FileLocking := TWindowsFileLocking.Create;

  FileLocking.NetLockingOn := aNetLockingOn;
end;

//------------------------------------------------------------------------------
function GetFileLockStatus(aFilePath : string) : TFileCheckStatus;
var
  LockPos : DWord;
  LockFileHandle : Integer;
begin
  try
    if BKFileExists(aFilePath) then
    begin
      LockFileHandle := FileCreate(aFilePath);
      if LockFileHandle > -1 then
      begin
        try
          if LockFile( LockFileHandle, 0, 0, 1, 0 ) then
          begin
            Result := fcsOK;
            UnLockFile(LockFileHandle, 0, 0, 1, 0 );
          end
          else
            Result := fcsCanNotLock;
        finally
          FileClose(LockFileHandle)
        end;
      end
      else
        Result := fcsCanNotOpen;
    end
    else
      Result := fcsCanNotFind;
  except
    Result := fscException
  end;
end;

{ TFileLocking }
//------------------------------------------------------------------------------
procedure TFileLocking.CreateDelayForm(aTicksToWait : Dword);
begin
  LockMessageDisplaying := True;
  fDelayForm := TDelayForm.Create( Application );

  case fLockState of
    lsLocking   : fDelayForm.lblDelay.Caption := 'Waiting for access to the ' +
                                                 ltNames[ fLockType ] +
                                                 '... (' +
                                                 IntToStr( aTicksToWait div TICKS_PER_SECOND) +
                                                 's)';

    lsUnlocking : fDelayForm.lblDelay.Caption := 'Unlocking the ' +
                                                 ltNames[ fLockType ];
  end;

  fWindowList := DisableTaskWindows( fDelayForm.Handle );

  fDelayForm.Show;
end;

//------------------------------------------------------------------------------
procedure TFileLocking.UpdateDelayForm(aElapsedTicks, aTicksToWait : Dword);
var
  ProgressPos : Double;
begin
  ProgressPos := Round( 100.0 * (aElapsedTicks / aTicksToWait) );
  if ProgressPos < 0 then
    ProgressPos := 0
  else if ProgressPos > 100 then
    ProgressPos := 100;

  fDelayForm.pbProgress.Percent := Round(ProgressPos);

  fDelayForm.Update;
end;

//------------------------------------------------------------------------------
procedure TFileLocking.DestroyDelayForm;
begin
  if Assigned(fDelayForm) then
  begin
    EnableTaskWindows(fWindowList);
    fDelayForm.Close;
    FreeAndNil(fDelayForm);
    LockMessageDisplaying := false;
  end;
end;

//------------------------------------------------------------------------------
function TFileLocking.WaitingMessageLoop(aLockState : TLockState) : boolean;
Var
  StartLockTick  : Dword;
  CurrentTick    : Dword;
  MaxTicksToWait : Dword;

  LockTimeExpired : Boolean;
  ShowProgress    : Boolean;
Begin
  ShowProgress := false;
  fLockState := aLockState;

  // First Call
  Result := InitialLockingCall();

  If Result then
    Exit;

  MaxTicksToWait := (fMaxSecsToWait * TICKS_PER_SECOND);
  try
    StartLockTick := GetTickCount;
    Repeat
      // Next Calls
      Result := LoopLockingCall();

      CurrentTick := GetTickCount;
      if Not ShowProgress then
      begin
        ShowProgress := (CurrentTick > StartLockTick + fMinTicksBeforeShowProgress);
        if ShowProgress then
          CreateDelayForm(MaxTicksToWait);
      end
      else
        UpdateDelayForm((CurrentTick - StartLockTick), MaxTicksToWait);

      LockTimeExpired := (CurrentTick > StartLockTick + MaxTicksToWait);
    Until (Result) or
          (LockTimeExpired);
  finally
    DestroyDelayForm();
  end;
end;

//------------------------------------------------------------------------------
function TFileLocking.ObtainLock( const aLockType, aMaxSecsToWait : Integer ): Boolean;
begin
  Result := ObtainLock( aLockType, 0, aMaxSecsToWait);
end;

//------------------------------------------------------------------------------
function TFileLocking.ObtainLock(const aLockType, aLockRef, aMaxSecsToWait : Integer): Boolean;
Begin
  fLockType      := aLockType;
  fLockRef       := aLockRef;
  fMaxSecsToWait := aMaxSecsToWait;

  Result := WaitingMessageLoop(lsLocking);
end;

//------------------------------------------------------------------------------
function TFileLocking.ReleaseLock(const aLockType: Integer): Boolean;
begin
  Result := ReleaseLock( aLockType, 0);
end;

//------------------------------------------------------------------------------
function TFileLocking.ReleaseLock(const aLockType, aLockRef: integer): Boolean;
const
  UNLOCK_SECS_TO_WAIT = 30;
Begin
  fLockType      := aLockType;
  fLockRef       := aLockRef;
  fMaxSecsToWait := UNLOCK_SECS_TO_WAIT;

  Result := WaitingMessageLoop(lsUnLocking);
end;

{ TWindowsFileLocking }
//------------------------------------------------------------------------------
function TWindowsFileLocking.LockFileHandle: Integer;
var
  Buffer: array [ltMin..ltMax] of Byte;
begin
  if FLockFileHandle < 0 then
  begin
    if not BKFileExists(FLockFileName) then
    begin
      FLockFileHandle := FileCreate(FLockFileName);
      if FLockFileHandle < 0 then
        raise Exception.CreateFmt( 'Cannot create [%s]', [FLockFileName]);
      FillChar(Buffer, Sizeof(Buffer), 0);
      FileWrite(FLockFileHandle, Buffer, Sizeof(Buffer));
    end
    else
    begin
      //file already exists, open it
      FLockFileHandle := FileOpen(FLockFileName, fmShareDenyNone);
      if FLockFileHandle < 0  then
        raise Exception.CreateFmt( 'Cannot open [%s]', [FLockFileName]);
    end;
  end;
  Result := FLockFileHandle;
end;

//------------------------------------------------------------------------------
// return the true lock position give the type and the reference
// each lock type can now support upto  1,000,000 individual lock references
function TWindowsFileLocking.GetLockPosition(const LockType, LockRef: integer): DWord;
const
  ONE_MILLION : integer = 1000000;
begin
  //validate inputs
  if (LockType < ltMin) or
     (LockType > ltMax) then
    raise Exception.CreateFmt('Invalid Lock Type [%d]', [ LockType]);

  if (LockRef < 0) or
     (LockRef > ONE_MILLION) then
    raise Exception.CreateFmt( 'Invalid Lock Ref [%d]  Lock Type [%d]', [ LockRef]);

  Result := (ONE_MILLION * LockType) + LockRef;
end;

//------------------------------------------------------------------------------
function TWindowsFileLocking.LockFileEx(const LockPos: DWord): Boolean;
var
  ErrorCode : Cardinal;
  Str       : string;
begin
  Result := LockFile( LockFileHandle, LockPos, 0, 1, 0 );
  if Result then
    exit;

  ErrorCode := Windows.GetLastError;

  if ErrorCode <> ERROR_LOCK_VIOLATION then
  begin
    if ErrorCode = ERROR_INVALID_HANDLE then
      Str := 'LockFile Error: Invalid File Handle (see MSKB Article Q272582 for possible cause)'
    else if ErrorCode = ERROR_NETNAME_DELETED then
      Str := 'LockFile Error: The network name is no longer available (see MSKB Articles 888318 and 839027 for possible cause)'
    else
      Str := Format( 'LockFile returned an unexpected result [%d] %s', [ ErrorCode, SysErrorMessage( ErrorCode ) ] );

    raise Exception.Create( Str );
  end;
end;

//------------------------------------------------------------------------------
function TWindowsFileLocking.UnLockFileEx(const LockPos: DWord): Boolean;
var
  ErrorCode : Cardinal;
  Str       : string;
begin
  Result := UnLockFile(LockFileHandle, LockPos, 0, 1, 0 );
  if Result then
    Exit;

  ErrorCode := Windows.GetLastError;

  if ErrorCode <> ERROR_NOT_LOCKED then
  begin
    if ErrorCode = ERROR_INVALID_HANDLE then
      Str := 'UnlockFile Error: Invalid File Handle (see MSKB Article Q272582 for possible cause)'
    else if ErrorCode = ERROR_NETNAME_DELETED then
      Str := 'UnlockFile Error: The network name is no longer available (see MSKB Articles 888318 and 839027 for possible cause)'
    else
      Str := Format('UnLockFile returned an unexpected result [%d] %s', [ErrorCode, SysErrorMessage(ErrorCode)]);

    raise Exception.Create(Str);
  end;
end;

//------------------------------------------------------------------------------
function TWindowsFileLocking.InitialLockingCall() : Boolean;
begin
  fLockPos := GetLockPosition( fLockType, fLockRef);

  Result := LoopLockingCall();
end;

//------------------------------------------------------------------------------
function TWindowsFileLocking.LoopLockingCall() : Boolean;
begin
  if fLockState = lsLocking then
    Result := LockFileEx( fLockPos )
  else if fLockState = lsUnLocking then
    Result := UnLockFileEx( fLockPos )
  else
    Result := false;
end;

//------------------------------------------------------------------------------
constructor TWindowsFileLocking.Create;
begin
  MinTicksBeforeShowProgress := TICKS_BEFORE_DELAY_SHOWN;
  FLockFileHandle := -1;  //not assigned
{$IFNDEF LOOKUPDLL}
  SetLockingFileLocation( ExtractFilePath( Application.ExeName));
{$ENDIF}
end;

//------------------------------------------------------------------------------
destructor TWindowsFileLocking.Destroy;
begin
  if FLockFileHandle >= 0 then
    FileClose( FLockFileHandle );

  inherited;
end;

//------------------------------------------------------------------------------
procedure TWindowsFileLocking.SetLockingFileLocation(aLockDir: string);
begin
  //Close existing lock file if open
  if FLockFileHandle >= 0 then
  begin
    FileClose(FLockFileHandle);
    FLockFileHandle := -1;
  end;

  FLockFileName := ExtractFilePath(aLockDir) + 'SYSTEM.LCK';
end;

{ TNetworkFileLocking }
//------------------------------------------------------------------------------
function TNetworkFileLocking.ReadFromServer: boolean;
begin
  try
    if fLockState = lsLocking then
      Result := fIPClientLock.RecieveLock(fLockType, fRequestID)
    else
      Result := fIPClientLock.RecieveUnLock(fLockType, fRequestID);
  except
    on E : EIdConnClosedGracefully do
      Result := false;
    on E : EIdReadTimeout do
      Result := false;
  end;
end;

//------------------------------------------------------------------------------
function TNetworkFileLocking.CritSecWriteReadFromServer: boolean;
var
  Critical : TCriticalSection;
begin
  Critical := TCriticalSection.Create;

  Critical.Enter;
  try
    if fLockState = lsLocking then
      Result := fIPClientLock.RequestLock(fLockType)
    else
      Result := fIPClientLock.RequestUnLock(fLockType);

    fRequestID := fIPClientLock.RequestID;
  finally
    Critical.Leave;
    FreeandNil(Critical);
  end;

  if Result then
  begin
    fLockWriteSuccessful := true;
    Result := ReadFromServer();
  end
  else
  begin
    fLockWriteSuccessful := false;
    Result := false;
  end;
end;

//------------------------------------------------------------------------------
function TNetworkFileLocking.InitialLockingCall(): Boolean;
begin
  Result := CritSecWriteReadFromServer();
end;

//------------------------------------------------------------------------------
function TNetworkFileLocking.LoopLockingCall(): Boolean;
begin
  if fLockWriteSuccessful then
    Result := ReadFromServer()
  else
    Result := CritSecWriteReadFromServer();
end;

//------------------------------------------------------------------------------
procedure TNetworkFileLocking.OnLockLogging(aMethod, aMesssage: String);
begin
  LogUtil.LogMsg(lmDebug, aMethod, aMesssage, 0, false);
end;

//------------------------------------------------------------------------------
constructor TNetworkFileLocking.Create;
begin
  MinTicksBeforeShowProgress := TICKS_BEFORE_DELAY_SHOWN;
  fIPClientLock := TIPClientLocking.Create;
end;

//------------------------------------------------------------------------------
destructor TNetworkFileLocking.Destroy;
begin
  FreeAndNil(fIPClientLock);
  inherited;
end;

//------------------------------------------------------------------------------
function TNetworkFileLocking.GetServerIP: string;
begin
  Result := fIPClientLock.ServerIP;
end;

//------------------------------------------------------------------------------
procedure TNetworkFileLocking.SetServerIP(aValue: string);
begin
  fIPClientLock.ServerIP := aValue;
end;

//------------------------------------------------------------------------------
function TNetworkFileLocking.GetServerPort: string;
begin
  Result := Inttostr(fIPClientLock.ServerTCPPort);
end;

//------------------------------------------------------------------------------
procedure TNetworkFileLocking.SetServerPort(aValue: string);
begin
  fIPClientLock.ServerTCPPort := Strtoint(aValue);
end;

//------------------------------------------------------------------------------
procedure TNetworkFileLocking.InitilizeIPLocking(aUDP_Client_Port : integer;
                                                 aUDP_BuffInitSize : integer;
                                                 aDiscoveryTimeOut : dword;
                                                 aUDPTimeOut : dword;
                                                 aLockTimeOut : dword;
                                                 aTCPTimeOut : dword;
                                                 aProcessMessageDelay : dword;
                                                 aServer_IP : string;
                                                 aServer_Port : integer;
                                                 aGroup_ID : string);
var
  Connected : boolean;
begin
  fIPClientLock.ICLMessageEvent   := OnLockLogging;
  fIPClientLock.DebugMe           := DebugMe;
  fIPClientLock.AppVersion        := '1.0.0.0';
  fIPClientLock.UDPPort           := aUDP_Client_Port;
  fIPClientLock.UDPBufferInitSize := aUDP_BuffInitSize;

  fIPClientLock.DiscoveryTimeOut := aDiscoveryTimeOut;
  fIPClientLock.UDPTimeOut       := aUDPTimeOut;

  fIPClientLock.LockTimeOut      := aLockTimeOut;
  fIPClientLock.TCPTimeOut       := aTCPTimeOut;

  fIPClientLock.setGroupID(aGroup_ID);

  fIPClientLock.ProcessMessageDelay := aProcessMessageDelay;

  if (aServer_IP <> '') and
     (aServer_Port > -1) then
  begin
    fIPClientLock.ServerIP := aServer_IP;
    fIPClientLock.ServerTCPPort := aServer_Port;
    Connected := fIPClientLock.ManualConnect;
  end
  else
    Connected := fIPClientLock.Connect;

  if not Connected then
    Raise Exception.Create( 'Can not connect to Locking Server IP: ' + fIPClientLock.ServerIP +
                            ' , Server Port : ' + inttostr(fIPClientLock.ServerTCPPort));
end;

//------------------------------------------------------------------------------
procedure TNetworkFileLocking.ClientIPLoginUser(aUserCode, aWorkstation: string);
var
  UserCode : TUserCode;
  Workstation : TWorkstation;
  Index: Integer;
begin
  FillChar(UserCode, Length(UserCode), #0);
  FillChar(Workstation, Length(Workstation), #0);

  for Index := 1 to Length(aUserCode) do
  begin
    UserCode[Index -1] := aUserCode[Index];
  end;

  for Index := 1 to Length(aWorkStation) do
  begin
    if Index < Length(WorkStation) then
    begin
      Workstation[Index -1] := aWorkStation[Index];
    end
    else
    begin
      Break;
    end;
  end;
                                                          
  fIPClientLock.RequestLoginUser(UserCode, Workstation);
end;

end.

