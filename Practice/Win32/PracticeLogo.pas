unit PracticeLogo;
//------------------------------------------------------------------------------
{
   Title:        Practice Logo Unit

   Description:  This unit deals with loading the practice logo into a mime
                 encoded string.

                 Routine also handles locking so that we dont get any other
                 reads at the same time

   Author:       Matthew Hopkins

   Remarks:

}
//------------------------------------------------------------------------------

interface

function EncodePracticeLogo( const filename : string) : string;

//******************************************************************************
implementation
uses
  SysUtils,
  MimeUtils,
  LockUtils,
  LogUtil;

const
  Unitname = 'PracticeLogo';

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EncodePracticeLogo( const filename : string) : string;
var
  sMsg : string;
begin
  result := '';

  if filename = '' then
    exit;

  try
    FileLocking.ObtainLock( ltPracLogo, TimeToWaitForPracLogo );
    try
      result := EncodeImageToString( filename);
    finally
      FileLocking.ReleaseLock( ltPracLogo)
    end;
  except
    on E : Exception do
    begin
      sMsg := 'Error encoding image ' + filename + ' - ' + E.Message + ' [' + E.Classname + ']';
      LogMsg( lmError, Unitname, sMsg);
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
