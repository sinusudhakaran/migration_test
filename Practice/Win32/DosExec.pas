unit DosExec;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

Function RunDOSCommand( CmdLine : String ) : LongInt;

//------------------------------------------------------------------------------
implementation uses Windows, LogUtil, SysUtils;
//------------------------------------------------------------------------------

CONST
   UnitName = 'DosExec';
   DebugMe  : Boolean = False;

//------------------------------------------------------------------------------
   
Function RunDOSCommand( CmdLine : String ) : LongInt;

CONST
   ThisMethodName = 'RunDOSCommand';
   MAX_TIMEOUT    = 120000;  {ms.  = 2 minutes}
Label 
  Quit;
   
Var
   ProcessInformation : TProcessInformation;
   StartupInformation : TStartupInfo;
   ProcessCreated     : Boolean;
   ExitCode           : DWord;
   Msg                : String;
Begin
   if DebugMe then LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName + ' Begins' );

   FillMemory( @StartupInformation, SizeOf( StartupInformation ), 0 );
   StartupInformation.cb := SizeOf( StartupInformation );
   
   ProcessCreated := CreateProcess( Nil, PChar( CmdLine ), Nil, Nil, False, NORMAL_PRIORITY_CLASS, Nil, Nil, StartupInformation, ProcessInformation );
   If not ProcessCreated then
   Begin
      Msg := Format( 'Unable to run command %s, error %d', [ CmdLine, GetLastError ] );
      LogUtil.LogError( UnitName, ThisMethodName + ' : ' + Msg );
      Result := -1;
      goto Quit;
   end;
  
   WaitforSingleObject( ProcessInformation.hProcess, MAX_TIMEOUT );
   
   GetExitCodeProcess( ProcessInformation.hProcess, ExitCode );

   If ExitCode <> 0 then
   Begin
      Msg := Format( 'The command %s returned error code %d', [ CmdLine, ExitCode ] );
      LogUtil.LogError( UnitName, ThisMethodName + ': ' + Msg );
      Result := ExitCode;
   end
   else
      Result := 0; { OK }
         
   CloseHandle( ProcessInformation.hProcess );
   CloseHandle( ProcessInformation.hThread );

   Quit:
   
   if DebugMe then LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
