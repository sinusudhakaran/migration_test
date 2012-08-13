unit upgCommon;

interface
uses windows;

  function GetDllPath : string;
  procedure RetrieveFileVersion( const aFileName : string; var vMajor, vMinor, vRelease, vBuild : word);
  function BuildInfo (Value : String) : String;
  function GetFileSize (Value : String): Int64;

implementation
uses
  SysUtils,
  Forms,
  upgConstants;

function GetDllPath : string;
var
  fn : array[0..MAX_PATH] of char;
begin
  Fillchar( fn, sizeof( fn), #0);
  GetModuleFileName( HInstance, fn, sizeof( fn));
  result := fn;
end;

procedure RetrieveFileVersion( const aFileName : string; var vMajor, vMinor, vRelease, vBuild : word);
var
   VerInfoSize  : DWORD;
   VerInfo      : Pointer;
   VerValueSize : DWORD;
   VerValue     : PVSFixedFileInfo;
   Dummy        : DWORD;
begin
  vMajor := 0;
  vMinor := 0;
  vRelease := 0;
  vBuild := 0;

  //find out where this module is running from

  VerInfoSize := GetFileVersionInfoSize( PChar( aFileName), Dummy);
  if VerInfoSize > 0 then begin
     GetMem(VerInfo, VerInfoSize);
     try
        GetFileVersionInfo(PChar( aFileName), 0, VerInfoSize, VerInfo);
        if VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize) then
        begin
           vMajor := HiWord (VerValue^.dwFileVersionMS);
           vMinor := LoWord (VerValue^.dwFileVersionMS);
           vRelease := HiWord (VerValue^.dwFileVersionLS);
           vBuild := LoWord (VerValue^.dwFileVersionLS);
        End;
     finally
        FreeMem(VerInfo, VerInfoSize);
     end { try };
  end;
end;

function BuildInfo (Value : String) : String;
   Var
      major, minor, release, build : word;
Begin { GetBuildInfo }
   result := '';
   RetrieveFileVersion (Value, major, minor, release, build);
   if not ((major = 0) and (minor = 0) and (release = 0) and (build = 0)) then
      Result := Format ('%d.%d.%d.%d', [major, minor, release, build]);
end;

function GetFileSize (Value : String): Int64;
//return the file size of a local file if it exists
var F : File;
    OldFileMode : integer;
begin
   Result := 0;
   if not SysUtils.FileExists( value ) then Exit;
   //Store the existing file mode state
   OldFileMode := FileMode;
   //Set to Read Onlly
   FileMode := 0;
   AssignFile( F, value );
   Reset( F, 1 );
   try
      Result := FileSize( F );
   finally
      FileMode := OldFileMode;
      CloseFile( F );
   end;
end;

end.
