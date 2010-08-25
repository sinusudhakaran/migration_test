unit AdminNotesForClient;
//------------------------------------------------------------------------------
{
   Title:       Admin System notes for client

   Description: Allows access to the notes held in the admin system for each
                client.  The notes are never sent out to a client

   Author:      Matthew Hopkins  May 2003

   Remarks:

}
//------------------------------------------------------------------------------

interface

function GetNotesForClient( cLRN : integer) : string;
procedure UpdateNotesForClient( cLRN : integer; NewNotes : string);

//******************************************************************************
implementation
uses
  Classes,
  DirUtils,
  Globals,
  SysUtils,
  LockUtils,
  WinUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetNotesForClient( cLRN : integer) : string;
var
  Filename : string;
  Notes    : TStringList;
begin
  result := '';

  Filename := GetClientNotesFilename( cLRN);
  LockUtils.ObtainLock( ltClientNotes, cLRN, Globals.PRACINI_TicksToWaitForAdmin div 1000);
  try
    if BKFileExists( Filename) then
    begin
      Notes := TStringList.Create;
      try
        Notes.LoadFromFile( Filename);
        result := Notes.Text;
      finally
        Notes.Free;
      end;
    end;
  finally
    LockUtils.ReleaseLock( ltClientNotes, cLRN);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UpdateNotesForClient( cLRN : integer; NewNotes : string);
var
  Filename : string;
  Notes    : TStringList;
begin
  Filename := GetClientNotesFilename( cLRN);
  LockUtils.ObtainLock( ltClientNotes, cLRN, Globals.PRACINI_TicksToWaitForAdmin div 1000);
  try
    Notes := TStringList.Create;
    try
      Notes.Text := NewNotes;
      Notes.SaveToFile( Filename);
    finally
      Notes.Free;
    end;
  finally
    LockUtils.ReleaseLock( ltClientNotes, cLRN);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
