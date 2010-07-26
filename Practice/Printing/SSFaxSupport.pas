{*******************************************************}
{                                                       }
{       Rave (tm) Fax Add-On Component (SSRenderFax)    }
{                                                       }
{       Copyright (c) 2003 by John Sandage              }
{                                                       }
{*******************************************************}

unit SSFaxSupport;

interface
  uses Windows, WinTypes, SysUtils, WinUtils;

function StripCRs(S: String): String;
function RemoveTrailingBackSlash(Path: String): String;
function WinSysDir: String;
function DLLFound(DLLName: String): Boolean;
function IsWin9x: boolean;

implementation

function StripCRs(S: String): String;
  var PreString, PostString: String;
      CRPos: Integer;
begin
  result := S;
  CRPos := Pos(chr(13)+chr(10), result);
  while CRPos > 0 do begin
    PreString := copy(result, 1, CRPos-1);
    PostString := copy(result, CRPos+2, Length(S)-CRPos-1);
    if (copy(PreString, Length(PreString), 1) = ' ') or (copy(PostString, 1, 1) = ' ') then begin
      result := PreString + PostString;
    end else begin
      result := PreString + ' ' + PostString;
    end;
    CRPos := Pos(chr(13)+chr(10), result);
  end; {while ...}
end; {StripCRs}

function RemoveTrailingBackSlash(Path: String): String;
begin
  Result := Path;
  if Length(Path) > 0 then begin
    if copy(Path, Length(Path), 1) = '\' then begin
      if copy(Path, Length(Path)-1, 1) <> ':' then begin
        Result := copy(Path, 1, Length(Path)-1);
      end;
    end;
  end;
end; {RemoveTrailingBackSlash}

function WinSysDir: String;
  var Buffer: array[0..254] of Char;
begin
  GetSystemDirectory(Buffer, 255);
  result := RemoveTrailingBackSlash(StrPas(Buffer));
end; {WinSysDir}

function DLLFound(DLLName: String): Boolean;
begin
  result := false;
  if BKFileExists(WinSysDir+'\'+DLLName) then begin
    result := true;
  end;
end; {DllFound}

function IsWin9x: boolean;
  {Constants used here are located in Windows.pas}
  var Ver: TOsVersionInfo;
begin
  Ver.dwOSVersionInfoSize := sizeof(Ver);
  GetVersionEx(Ver);
  if (Ver.dwPlatformID = VER_PLATFORM_WIN32_WINDOWS) then begin
    result := true;
  end else begin
    result := false;
  end;
end; {IsWin9x}

end.
