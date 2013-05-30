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
const
{$IFDEF SmartLink}
   MutexAppName = 'SmartLink';
{$ELSE}
  {$IFDEF BKMAP}
     MutexAppName = 'BankLink Map Utility';
  {$ELSE}
    {$IFDEF BKCRYPT}
     MutexAppName = 'BankLink Decryption Utility';
    {$ELSE}
     MutexAppName = 'BankLink 5';
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

implementation
uses
   Windows,
   Dialogs,
   Forms,
   bkProduct;
var
   hMutex  : THandle;

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -}
initialization
begin
{$IFDEF ALLOWMULTIPLESESSIONS}
  hMutex := CreateMutex( nil, false, MutexAppName  + 'DEV' );
{$ELSE}
  hMutex := CreateMutex( nil, false, MutexAppName);
{$ENDIF}
  if ( hMutex <> 0 ) and ( GetLastError = ERROR_ALREADY_EXISTS ) then
  begin
     CloseHandle( hMutex );
     hMutex := 0;
{$IFNDEF SmartLink}
     ShowMessage( TProduct.BrandName + ' is already running, you cannot run more than one copy at a time.');
{$ELSE}
     ShowMessage( 'SmartLink is already running, you cannot run more than one copy at a time.');
{$ENDIF}
     Halt;
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


