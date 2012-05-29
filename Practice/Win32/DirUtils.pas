unit DirUtils;
//------------------------------------------------------------------------------
{
   Title:       Directory Utilities

   Description: Routines to return system directories

   Author:      Matthew Hopkins Apr 2003

   Remarks:

}
//------------------------------------------------------------------------------

interface

function GetClientDetailsCacheFilename( const cLRN : integer) : string;
function GetTaskListFilename( const tLRN : integer) : string;
function GetClientNotesFilename( const cLRN : integer) :string;
function AppendFileNameToPath(const FilePath, FileName: String): String;

//******************************************************************************
implementation
uses
  GlobalDirectories, SysUtils, bk5except;

function AppendFileNameToPath(const FilePath, FileName: String): String;
begin
  if Length(FilePath) > 0 then
  begin
    if FilePath[Length(FilePath)] <> '\' then
    begin
      Result := FilePath + '\' + FileName;
    end
    else
    begin
      Result := FilePath + FileName;
    end;
  end
  else
  begin
    Result := FileName;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CreateDirIfNotFound( aDir : String);
begin
  if not DirectoryExists(aDir) then
    if not CreateDir(aDir) then
      raise EInOutError.Create('Unable to Create Directory ' + aDir);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ClientDetailsCacheRoot : string;
begin
  result := GlobalDirectories.glDataDir + 'CACHE\';

  CreateDirIfNotFound( result);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ClientDetailsCacheDir( cLRN : integer) : string;
//returns the location of the cache, creates the directory if does not exist
var
  SubDirNo   : integer;
  SubDirName : string;
begin
  //each directory holds 25 files
  SubDirNo   := cLRN div 25;
  SubDirName := Format( 'SUB%0.5d', [ SubDirNo]);
  result     := ClientDetailsCacheRoot + SubDirName + '\';

  CreateDirIfNotFound( result);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetClientDetailsCacheFilename( const cLRN : integer) : string;
begin
  result := ClientDetailsCacheDir( cLRN) + Format( '%0.8d', [ cLRN]) + '.inf';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TaskListRoot : string;
begin
  result := GlobalDirectories.glDataDir + 'TASKS\';

  CreateDirIfNotFound( result);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TaskListDir( tLRN : integer) : string;
//returns the location of the cache, creates the directory if does not exist
var
  SubDirNo   : integer;
  SubDirName :  string;
begin
  //each directory holds 25 files
  SubDirNo   := tLRN div 25;
  SubDirName := Format( 'SUB%0.5d', [ SubDirNo]);
  result     := TaskListRoot + SubDirName + '\';

  CreateDirIfNotFound( result);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetTaskListFilename( const tLRN : integer) : string;
begin
  result := TaskListDir( tLRN) + Format( '%0.8d', [ tLRN]) + '.tdl';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetClientNotesFilename( const cLRN : integer) :string;
begin
  result := TaskListDir( cLRN) + Format( '%0.8d', [ cLRN]) + '.txt';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
