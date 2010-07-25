unit AutoSaveUtils;
//------------------------------------------------------------------------------
{
   Title:       Auto Save Utilities

   Description: Utilities to allow/prevent auto saves

   Author:      Matthew Hopkins   June 2003

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
  SysUtils;

type
  EASDisableCountException = class(Exception);

function AutoSaveAllowed : boolean;

procedure DisableAutoSave;
procedure EnableAutoSave;

var
  AutoSaveInUse     : boolean;
  
//******************************************************************************
implementation
var
  AutoSaveLockCount : integer;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DisableAutoSave;
//increase the number of autosave locks to prevent an autosave occuring
//if autosave is not in use then clear any outstanding locks
begin
  if AutoSaveInUse then
    Inc( AutoSaveLockCount)
  else
    AutoSaveLockCount := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure EnableAutoSave;
begin
  if AutoSaveInUse then
  begin
    Dec( AutoSaveLockCount);
    //make sure that there have been the same # of disable/enable calls
    //the assert will fail if there have been more enables than disables.
    //note: there seems to be a problem with Win95b clients and disabling the
    //autosave when the menu is dropped down
    //assert( AutoSaveLockCount >= 0);
    if ( AutoSaveLockCount < 0) then
    begin
      AutoSaveLockCount := 0;
      raise EASDisableCountException.Create( 'AutoSaveLockCount < 0');
    end;
  end
  else
    AutoSaveLockCount := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AutoSaveAllowed : boolean;
begin
  result := AutoSaveLockCount = 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
  AutoSaveLockCount := 0;
  AutoSaveInUse := false;
end.
