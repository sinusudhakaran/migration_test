unit TSUtils;
//------------------------------------------------------------------------------
{
   Title:       Terminal Services utilities

   Description: Procedures used when running the program through Microsoft
                Terminal Services

   Remarks:

   Author:      Peter 12/09/2000
}
//------------------------------------------------------------------------------

interface uses Windows;

Const
   UsingTerminalServices : Boolean = FALSE;
   TSClientAddress       : String = '';
   TSClientName          : String = '';
   TSUserName            : String = '';
   TSWinStationName      : String = '';

//------------------------------------------------------------------------------
implementation Uses SysUtils;
//------------------------------------------------------------------------------


type
  WTS_CLIENT_ADDRESS = packed record
    AddressFamily : DWORD;
    Address       : packed array [1..20] of Byte;
  end;       // Reflects relevant C++ structure

  PWTS_CLIENT_ADDRESS = ^WTS_CLIENT_ADDRESS;

  TQuerySession = function (hServer: THandle; SessionId: Dword;
                            WTSInfoClass: integer;          // assumes that enum type contains 32-bit values (probably it doesn't affect anything)
                            ppBuffer: PLPSTR; pBytesReturned: PDWORD): BOOL; stdcall;
  TFreeMemory = procedure (pMemory: pointer); stdcall;
  // Reflects relevant C++ function declarations

const
  WTSInitialProgram = 0;           // C++ enum type starts from 0
  WTSApplicationName = 1;
  WTSWorkingDirectory = 2;
  WTSOEMId = 3;
  WTSSessionId = 4;
  WTSUserName = 5;
  WTSWinStationName = 6;
  WTSDomainName = 7;
  WTSConnectState = 8;
  WTSClientBuildNumber = 9;
  WTSClientName = 10;
  WTSClientDirectory = 11;
  WTSClientProductId = 12;
  WTSClientHardwareId = 13;
  WTSClientAddress = 14;
  WTSClientDisplay = 15;
  WTSClientProtocolType = 16;

  WTS_CURRENT_SERVER_HANDLE = 0;
  WTS_CURRENT_SESSION = Dword(-1);

Procedure GetTSInfo;

var
   PBuffer        : LPSTR;
   bytes          : DWORD;
   i              : integer;
   Handle         : THandle;
   QuerySession   : TQuerySession;
   FreeMemory     : TFreeMemory;
   OK             : BOOL;
begin
   Handle := LoadLibrary('wtsapi32.dll');

   If Handle <> 0 then
   Begin
      @QuerySession := GetProcAddress(Handle, 'WTSQuerySessionInformationW');
      @FreeMemory := GetProcAddress(Handle, 'WTSFreeMemory');
      if (@QuerySession <> nil) and (@FreeMemory <> nil) then
      Begin
         PBuffer := nil;
         bytes   := 0;
         OK := QuerySession(WTS_CURRENT_SERVER_HANDLE,WTS_CURRENT_SESSION,WTSClientName,@PBuffer,@bytes );
         If OK and ( PBuffer<>nil ) then
         begin
            UsingTerminalServices := True;    //always returns true for windows XP
            TSClientName := WideCharToString( PWideChar( PBuffer ) );
            FreeMemory( PBuffer );
         end;

         PBuffer := nil;
         bytes   := 0;
         OK := QuerySession(WTS_CURRENT_SERVER_HANDLE,WTS_CURRENT_SESSION,WTSUserName,@PBuffer,@bytes );
         If OK and ( PBuffer<>nil ) then
         begin
            TSUserName := WideCharToString( PWideChar( PBuffer ) );
            FreeMemory( PBuffer );
         end;

         PBuffer := nil;
         bytes   := 0;
         OK := QuerySession(WTS_CURRENT_SERVER_HANDLE,WTS_CURRENT_SESSION,WTSWinStationName,@PBuffer,@bytes );
         If OK and ( PBuffer<>nil ) then
         begin
            TSWinStationName := WideCharToString( PWideChar( PBuffer ) );
            FreeMemory( PBuffer );
         end;

         PBuffer := nil;
         bytes   := 0;
         OK := QuerySession(WTS_CURRENT_SERVER_HANDLE,WTS_CURRENT_SESSION,WTSClientAddress,@PBuffer,@bytes);
         if OK and ( PBuffer<>nil ) then
         Begin
            With PWTS_CLIENT_ADDRESS( PBuffer )^ do
            Begin
               For i:=1 to 20 do TSClientAddress := TSClientAddress + IntToHex( Address[ i ], 2 );
            end;
            FreeMemory( PBuffer );
         end;
      end;
      FreeLibrary(Handle);
   end;
end;

//------------------------------------------------------------------------------

Initialization
   //Causes CPU debug window to appear during runtime prior to installing
   //Window 2000 Service Pack 2
   GetTSInfo;
end.

