unit OneInst;
//Description
//
//Place this unit as one of the first in the Uses section of the Project. 
//The Initialization section ensures a single instance of a Delphi 32 application.
//It checks for an existing Instance and if found restores it and Halts
//this Instance.
//
//-----------------------------------------------------------------------------
interface

implementation

uses
   Windows,
   Messages,
   SysUtils,
   Dialogs,
   Forms,
   ecGlobalConst;

var
   hMutex  : THandle;
//   hWindow : HWnd;

const
  MUTEX_NAME = 'BNotes';

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
initialization
begin
  hMutex := CreateMutex( nil, false, MUTEX_NAME);
  if ( hMutex <> 0 ) and ( GetLastError = ERROR_ALREADY_EXISTS ) then begin
     CloseHandle( hMutex );
     hMutex := 0;
     ShowMessage( ecGlobalConst.APP_NAME + ' is already running, you cannot run more than one copy at a time.');
     Halt;
{
     //Rename this version to find other version
     Application.Title := 'SecondInst';
     hWindow := FindWindow( nil, Globals.APPTITLE );
     // Restore and bring to foreground
     if ( hWindow <> 0 ) then begin
        PostMessage( hWindow, wm_SysCommand, sc_Restore, 0 );
        SetForeGroundWindow( hWindow );
     end;
     Halt;
}
  end;
end;

finalization
begin
   if ( hMutex <> 0 ) then begin
      CloseHandle( hMutex );
   end;
end;
{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}          

end.


