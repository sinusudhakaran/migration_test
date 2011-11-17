unit LockUtils;

{
   Title : Lock Utilities

   Description: Generalised lock/unlock routines using a single shared file for locking.
   A "Waiting For..." dialog will appear if it is compiled into a GUI app.

   Author : Steve 01/2001

   Feb 02 - Raises an exception if we get an unexpected result while locking or unlocking.

}

//-----------------------------------------------------------------------------
interface
//-----------------------------------------------------------------------------

const
   ltMin                 =  1;
   ltSystemLog           =  2;
   ltAdminSystem         =  3;
   ltStartupCheck        =  4;
   ltPracIni             =  5;
   ltPracLogo            =  6;
   ltClientToDoList      =  7;
   ltClientDetailsCache  =  8;
   ltClientNotes         =  9;
   ltPracHeaderFooterImg = 10;
   ltAdminOptions        = 11;
   ltUsageStatistics     = 12;
   ltScheduledReport     = 13;
   ltCustomDocument      = 14;
   ltCodingStats         = 15;
   ltWebNotesupdate      = 16;
   ltWebNotesdata        = 17;
   ltExchangeRates       = 18;

   ltMax                 = 18;

const
   TimeToWaitForPracINI  = 60;
   TimeToWaitForPracLogo = 30;

function ObtainLock( const LockType : Integer; const MaxSecsToWait : Integer ): Boolean; overload;
function ObtainLock( const LockType, LockRef : integer; const MaxSecsToWait : Integer ): Boolean;  overload;


function ReleaseLock( const LockType : Integer ): Boolean; overload;
function ReleaseLock( const LockType, LockRef : integer): Boolean; overload;

{$IFDEF LOOKUPDLL}
procedure SetLockingFileLocation( LockDir : string);
{$ENDIF}

//-----------------------------------------------------------------------------
implementation

//WARNING: THIS UNIT IS USED BY ERROR LOG.  DO NOT LINK TO ANY OTHER BK5 UNITS AS
//         THESE MAY CAUSE OTHER UNITS TO BE INITIALISED BEFORE THE ERROR LOG UNIT!
uses
  Forms,
  WaitDlg,
  SysUtils,
  TimeUtils,
  Windows,
  WinUtils;

const

   MinSecBeforeShowProgress = 2;  //wait 2 secs

const
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
       'Exchange Rates' );

 var
    FLockFileName: string;
    FLockFileHandle: Integer;

  function LockFileHandle: Integer;
  var Buffer: array [ltMin..ltMax] of Byte;
  begin
     if FLockFileHandle < 0 then begin
        if not BKFileExists(FLockFileName) then begin
           FLockFileHandle := FileCreate(FLockFileName);
           if FLockFileHandle < 0  then
              raise Exception.CreateFmt( 'Cannot create [%s]', [FLockFileName]);
           FillChar(Buffer, Sizeof(Buffer), 0);
           FileWrite(FLockFileHandle, Buffer, Sizeof(Buffer));
        end else begin
           //file already exists, open it
           FLockFileHandle := FileOpen(FLockFileName, fmShareDenyNone);
           if FLockFileHandle < 0  then
              raise Exception.CreateFmt( 'Cannot open [%s]', [FLockFileName]);
        end;
     end;
     Result := FLockFileHandle;
  end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  function GetLockPosition(const LockType, LockRef : integer) : DWord;
  //return the true lock position give the type and the reference
  //each lock type can now support upto  1,000,000 individual lock references
  const
    OneMillion : integer = 1000000;
  begin
    //validate inputs
    if (LockType < ltMin)
    or (LockType > ltMax) then
       raise Exception.CreateFmt('Invalid Lock Type [%d]', [ LockType]);

    if (LockRef < 0)
    or (LockRef > OneMillion) then
       raise Exception.CreateFmt( 'Invalid Lock Ref [%d]  Lock Type [%d]', [ LockRef]);

    Result := (OneMillion * LockType) + LockRef;
  end;

// -----------------------------------------------------------------------------

  function LockFileEx( const LockPos : DWord ) : Boolean;
  //provides a wrapper around the win32 lockfile call
  //checks the windows last error code to see what happened
  //now always raises an exception if lock failed.
  var
    ErrorCode     : Cardinal;
    S             : string;
  begin
    Result := LockFile( LockFileHandle, LockPos, 0, 1, 0 );
    if Result then
      exit;
    ErrorCode := Windows.GetLastError;
    if ErrorCode <> ERROR_LOCK_VIOLATION then
    begin
      if ErrorCode = ERROR_INVALID_HANDLE then
        S := 'LockFile Error: Invalid File Handle (see MSKB Article Q272582 for possible cause)'
      else
      if ErrorCode = ERROR_NETNAME_DELETED then
        S := 'LockFile Error: The network name is no longer available (see MSKB Articles 888318 and 839027 for possible cause)'
      else
        S := Format( 'LockFile returned an unexpected result [%d] %s', [ ErrorCode, SysErrorMessage( ErrorCode ) ] );
      raise Exception.Create( S );
    end;
  end;

// -----------------------------------------------------------------------------

  function UnLockFileEx(const LockPos: DWord) : Boolean;
  //provides a wrapper around the win32 unlockfile call
  var
    ErrorCode     : Cardinal;
    S             : string;
  begin
    Result := UnLockFile(LockFileHandle, LockPos, 0, 1, 0 );
    if Result then
       Exit;
    ErrorCode := Windows.GetLastError;
    if ErrorCode <> ERROR_NOT_LOCKED then
    begin
      if ErrorCode = ERROR_INVALID_HANDLE then
        S := 'UnlockFile Error: Invalid File Handle (see MSKB Article Q272582 for possible cause)'
      else
      if ErrorCode = ERROR_NETNAME_DELETED then
        S := 'UnlockFile Error: The network name is no longer available (see MSKB Articles 888318 and 839027 for possible cause)'
      else
        S := Format('UnLockFile returned an unexpected result [%d] %s', [ErrorCode, SysErrorMessage(ErrorCode)]);
      raise Exception.Create(S);
    end;
  end;

// -----------------------------------------------------------------------------

  Function ObtainLock( const LockType, LockRef : Integer; const MaxSecsToWait: Integer ): Boolean;
  Var
     ET           : EventTimer;
{$IFNDEF TESTLOCKING}
     WindowList   : Pointer;
{$ENDIF}
     ProgressPos  : Double;
     ElapsedTicks : Integer;
     TicksToWait  : Integer;
     DelayForm    : TDelayForm;

     LockPos      : DWord;
  Begin
//Uncomment this to trigger an 'Admin is locked by me' error 
//**** FOR TESTING ONLY *****************************************
//     DelayForm := TDelayForm.Create( Application );
//     Try
//        DelayForm.lblDelay.Caption := 'Waiting for access to the '+ltNames[ LockType ] + '... (' + IntToStr( MaxSecsToWait) + 's)';
//        WindowList := DisableTaskWindows( DelayForm.Handle );
//        DelayForm.Show;
//        EnableTaskWindows( WindowList );
//        DelayForm.Close;
//     Finally
//        DelayForm.Release;
//     end;
//**** FOR TESTING ONLY *****************************************

     LockPos := GetLockPosition( LockType, LockRef);
     Result := LockFileEx( LockPos );

     If Result then exit;

     TicksToWait := Secs2Ticks( MaxSecsToWait );

     DelayForm := TDelayForm.Create( Application );

     Try
        DelayForm.lblDelay.Caption := 'Waiting for access to the '+ltNames[ LockType ] + '... (' + IntToStr( MaxSecsToWait) + 's)';
{$IFNDEF TESTLOCKING}
        WindowList := DisableTaskWindows( DelayForm.Handle );
{$ENDIF}
        Try
           NewTimerSecs( ET, MaxSecsToWait );
           Repeat
              Result := LockFileEx( LockPos );
              If not Result then begin
                 DelayMS( 50, True );
                 //update progress bar
                 if TicksToWait > 0 then begin
                    ElapsedTicks := ElapsedTime( ET );
                    ProgressPos := 100.0 * ElapsedTicks / TicksToWait;
                    if ProgressPos < 0 then
                       ProgressPos := 0
                    else if ProgressPos > 100 then
                       ProgressPos := 100;

                    DelayForm.pbProgress.Percent := Round(ProgressPos);

                 end;
                 //only show progress form after a certain amount of
                 //time has elapsed.  This cuts down on flicker.
                 if ElapsedTimeInSecs( ET ) > MinSecBeforeShowProgress then begin
                    if not DelayForm.Visible then DelayForm.Show;
                 end;
              end;
           Until Result or TimerExpired( ET );
        Finally
{$IFNDEF TESTLOCKING}
           EnableTaskWindows( WindowList );
{$ENDIF}
           DelayForm.Close;
        end;
     Finally
        DelayForm.Release;
     end;
  end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  Function ObtainLock( const LockType : Integer; const MaxSecsToWait: Integer ): Boolean;
  //this call does not require a lock reference
  begin
    Result := ObtainLock( LockType, 0, MaxSecsToWait);
  end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  Function ReleaseLock(const LockType, LockRef: Integer): Boolean;
  const
     UnlockSecsToWait = 30;
  Var
     ET          : EventTimer;
{$IFNDEF TESTLOCKING}
     WindowList  : Pointer;
{$ENDIF}
     ProgressPos : Double;
     ElapsedTicks : Integer;
     TicksToWait  : Integer;
     DelayForm    : TDelayForm;
     LockPos      : DWord;
  Begin
     LockPos := GetLockPosition( LockType, LockRef);
     Result := UnLockFileEx( LockPos );
     If Result then
        Exit;

     TicksToWait := Secs2Ticks( UnlockSecsToWait );

     DelayForm := TDelayForm.Create( Application );
     Try
        DelayForm.lblDelay.Caption := 'Unlocking the '+ltNames[ LockType ];
{$IFNDEF TESTLOCKING}
        WindowList := DisableTaskWindows( DelayForm.Handle );
{$ENDIF}
        Try
           NewTimerSecs( ET, UnlockSecsToWait );
           Repeat
              Result := UnLockFileEx( LockPos );
              If not Result then begin
                 DelayMS( 10, True );

                 //update progress bar
                 if TicksToWait > 0 then begin
                    ElapsedTicks := ElapsedTime( ET );
                    ProgressPos := Round( 100.0 * ElapsedTicks / TicksToWait );
                    if ProgressPos < 0 then
                       ProgressPos := 0
                    else if ProgressPos > 100 then
                       ProgressPos := 100;

                    DelayForm.pbProgress.Percent := Round(ProgressPos);

                 end;
                 //only show progress form after a certain amount of
                 //time has elapsed.  This cuts down on flicker.
                 if ElapsedTimeInSecs( ET ) > MinSecBeforeShowProgress then begin
                    if not DelayForm.Visible then DelayForm.Show;
                 end;
              end;
           Until Result or TimerExpired( ET );
        Finally
{$IFNDEF TESTLOCKING}
           EnableTaskWindows( WindowList );
{$ENDIF}
           DelayForm.Close;
        end;
     Finally
        DelayForm.Release;
     end;
  end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function ReleaseLock( const LockType : Integer ): Boolean;
//this call does not require a lock ref
begin
   Result := ReleaseLock( LockType, 0);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetLockingFileLocation( LockDir : string);

begin
  //Close existing lock file if open
  if FLockFileHandle >= 0 then begin
     FileClose(FLockFileHandle);
     FLockFileHandle := -1;
  end;

  FLockFileName := ExtractFilePath(LockDir) + 'SYSTEM.LCK';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
   FLockFileHandle := -1;  //not assigned
{$IFNDEF LOOKUPDLL}
   SetLockingFileLocation( ExtractFilePath( Application.ExeName));
{$ENDIF}
finalization
   if FLockFileHandle >= 0 then
     FileClose( FLockFileHandle );
end.

