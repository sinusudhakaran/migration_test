{************************************************************************}
{ TExeInfo component                                                     }
{ for Delphi & C++Builder                                                }
{ version 1.2                                                            }
{                                                                        }
{ written by TMS Software                                                }
{           copyright © 2004 - 2007                                      }
{           Email : info@tmssoftware.com                                 }
{           Web : http://www.tmssoftware.com                             }
{                                                                        }
{ The source code is given as is. The author is not responsible          }
{ for any possible damage done due to the use of this code.              }
{ The component can be freely used in any application. The complete      }
{ source code remains property of the author and may not be distributed, }
{ published, given or sold in any form as such. No parts of the source   }
{ code can be included in any other component or application without     }
{ written authorization of the author.                                   }
{************************************************************************}
unit ExeInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, Graphics, Controls, Dialogs,
  TypInfo;

const
  MAJ_VER = 1; // Major version nr.
  MIN_VER = 2; // Minor version nr.
  REL_VER = 0; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // 1.2.0.0 : Added support for Windows 2003, Windows Vista

type
  TExeInfo = class(TComponent)
  private
    { Private declarations }
    FCompanyName      : String;
    FFileDescription  : String;
    FFileVersion      : String;
    FInternalName     : String;
    FLegalCopyright   : String;
    FLegalTradeMark   : String;
    FOriginalFileName : String;
    FProductName      : String;
    FProductVersion   : String;
    FComments         : String;
    FComputerName     : String;
    FOsName           : String;
    FWindowsDir       : String;
    FSystemDir        : String;
    FTempDir          : String;
    FFileFlags        : integer;
    FFileOS           : integer;
    FFileType         : integer;
    FFileCreation     : TDateTime;
    function GetVersion: string;
    procedure SetVersion(const Value: string);
  protected
    { Protected declarations }
    function GetVersionNr: Integer; virtual;
    procedure GetVersionInfo; virtual;
    function GetComputerName : String; virtual;
    procedure SetComputerName(Name : String); virtual;
    function GetWinDir : String;
    function GetSysDir : String;
    function GetTempDir : String;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property FileFlags        : integer read FFileFlags;
    property FileOS           : integer read FFileOS;
    property FileType         : integer read FFileType;
    property FileCreation     : TDateTime read FFileCreation;
    function GetOperatingSystem : string; virtual;
  published
    { Published declarations }
    property CompanyName      : string read FCompanyName write FCompanyName stored false;
    property FileDescription  : string read FFileDescription write FFileDescription stored false;
    property FileVersion      : string read FFileVersion write FFileVersion stored false;
    property InternalName     : string read FInternalName write FInternalName stored false;
    property LegalCopyright   : string read FLegalCopyright write FLegalCopyright stored false;
    property LegalTradeMark   : string read FLegalTradeMark write FLegalTradeMark stored false;
    property OriginalFileName : string read FOriginalFileName write FOriginalFileName stored false;
    property ProductName      : string read FProductName write FProductName stored false;
    property ProductVersion   : string read FProductVersion write FProductVersion stored false;
    property Comments         : string read FComments write FComments stored false;
    property ComputerName     : string read GetComputerName write SetComputerName stored false;
    property OSName           : string read GetOperatingSystem write FOSName stored false;
    property WindowsDir       : string read GetWinDir write FWindowsDir stored false;
    property SystemDir        : string read GetSysDir write FSystemDir stored false;
    property TempDir          : string read GetTempDir write FTempDir stored false;
    property Version          : string read GetVersion write SetVersion;
  end;



implementation


constructor TExeInfo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCompanyName      := 'Updated at run-time';
  FFileDescription  := 'Updated at run-time';
  FFileVersion      := 'Updated at run-time';
  FInternalName     := 'Updated at run-time';
  FLegalCopyright   := 'Updated at run-time';
  FLegalTradeMark   := 'Updated at run-time';
  FOriginalFileName := 'Updated at run-time';
  FProductName      := 'Updated at run-time';
  FProductVersion   := 'Updated at run-time';
  FComments         := 'Updated at run-time';
  FComputerName     := '';

  if not (csDesigning in ComponentState) then
    Begin
      GetVersionInfo;
      FComputerName := GetComputerName;
    End;
end;

procedure TExeInfo.GetVersionInfo;
type
  PTransBuffer = ^TTransBuffer;
  TTransBuffer = array[1..4] of smallint;
var
  iAppSize, iLenOfValue : DWord;
  pcBuf,pcValue         : PChar;
  VerSize               : DWord;
  pTrans                : PTransBuffer;
  TransStr              : string;
  sAppName              : String;
  fvip                  : pointer;
  ft                    : TFileTime;
  st                    : TSystemTime;
begin
  sAppName := Application.ExeName;
  // get version information values
  iAppSize:= GetFileVersionInfoSize(PChar(sAppName),// pointer to filename string
                                    iAppSize);      // pointer to variable to receive zero
   // if GetFileVersionInfoSize is successful
  if iAppSize > 0 then
    begin
      pcBuf := AllocMem(iAppSize);

      GetFileVersionInfo(PChar(sAppName),              // pointer to filename string
                         0,                            // ignored
                         iAppSize,                     // size of buffer
                         pcBuf);                       // pointer to buffer to receive file-version info.


      VerQueryValue(pcBuf, '\', fvip, iLenOfValue);

      FFileFlags := TVSFixedFileInfo (fvip^).dwFileFlags and TVSFixedFileInfo (fvip^).dwFileFlagsMask;
      FFileOS := TVSFixedFileInfo (fvip^).dwFileOS;
      FFileType := TVSFixedFileInfo (fvip^).dwFileType;

      ft.dwLowDateTime := TVSFixedFileInfo (fvip^).dwFileDateLS;
      ft.dwHighDateTime := TVSFixedFileInfo (fvip^).dwFileDateMS;

      FileTimeToSystemTime(ft,st);

      FFileCreation := SystemTimeToDateTime(st);

      VerQueryValue(pcBuf, PChar('\VarFileInfo\Translation'),
              pointer(ptrans), verSize);
      TransStr:= IntToHex(ptrans^[1], 4) + IntToHex(ptrans^[2], 4);

      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'CompanyName'), Pointer(pcValue),iLenOfValue) then
            FCompanyName := pcValue
      Else  FCompanyName := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'FileDescription'), Pointer(pcValue),iLenOfValue) then
            FFileDescription := pcValue
      Else  FFileDescription := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'FileVersion'), Pointer(pcValue),iLenOfValue) then
            FFileVersion := pcValue
      Else  FFileVersion := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'InternalName'), Pointer(pcValue),iLenOfValue) then
            FInternalName := pcValue
      Else  FInternalName := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'LegalCopyright'), Pointer(pcValue),iLenOfValue) then
            FLegalCopyright := pcValue
      Else  FLegalCopyright := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'LegalTradeMarks'), Pointer(pcValue),iLenOfValue) then
            FLegalTradeMark := pcValue
      Else  FLegalTradeMark := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'OriginalFileName'), Pointer(pcValue),iLenOfValue) then
            FOriginalFileName := pcValue
      Else  FOriginalFileName := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'ProductName'), Pointer(pcValue),iLenOfValue) then
            FProductName := pcValue
      Else  FProductName := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'ProductVersion'), Pointer(pcValue),iLenOfValue) then
            FProductVersion := pcValue
      Else  FProductVersion := '';
      if VerQueryValue(pcBuf,PChar('StringFileInfo\' + TransStr + '\' +
           'Comments'), Pointer(pcValue),iLenOfValue) then
            FComments := pcValue
      Else  FComments := '';
      FreeMem(pcBuf,iAppSize);
    end;
end;

function TExeInfo.GetComputerName : String;
var
   pcComputer : PChar;
   dwCSize    : DWORD;
begin
   dwCSize := MAX_COMPUTERNAME_LENGTH + 1;
   GetMem( pcComputer, dwCSize ); // allocate memory for the string
   try
      if Windows.GetComputerName( pcComputer, dwCSize ) then
         GetComputerName := StrPas(pcComputer);
   finally
      FreeMem( pcComputer ); // now free the memory allocated for the string
   end;
end;

procedure TExeInfo.SetComputerName(Name : String);
var
   pcComputer : PChar;
   dwCSize    : DWORD;
begin
   dwCSize := MAX_COMPUTERNAME_LENGTH + 1;
   GetMem( pcComputer, dwCSize ); // allocate memory for the string
   pcComputer := StrpCopy(pcComputer,Name);
   try
      Windows.SetComputerName( pcComputer )
   finally
      FreeMem( pcComputer ); // now free the memory allocated for the string
   end;
end;

function TExeInfo.GetOperatingSystem : String;
var
  osVerInfo: TOSVersionInfo;
  majorVer, minorVer: Integer;
begin
  Result := 'Unknown';
  { set operating system type flag }
  osVerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  if GetVersionEx(osVerInfo) then
  begin
    majorVer := osVerInfo.dwMajorVersion;
    minorVer := osVerInfo.dwMinorVersion;
    case osVerInfo.dwPlatformId of
      VER_PLATFORM_WIN32_NT: { Windows NT/2000 }
        begin
          if majorVer <= 4 then
            Result := 'Windows NT'
          else if (majorVer = 5) and (minorVer = 0) then
            Result := 'Windows 2000'
          else if (majorVer = 5) and (minorVer = 1) then
            Result := 'Windows XP'
          else if (majorVer = 5) and (minorVer = 2) then
            Result := 'Windows 2003'
          else if (majorVer = 6) then
            Result := 'Windows Vista'
          else
            Result := 'Unknown';
        end;
      VER_PLATFORM_WIN32_WINDOWS:  { Windows 9x/ME }
        begin
          if (majorVer = 4) and (minorVer = 0) then
            Result := 'Windows 95'
          else if (majorVer = 4) and (minorVer = 10) then
          begin
            if osVerInfo.szCSDVersion[1] = 'A' then
              Result := 'Windows 98 SE'
            else
              Result := 'Windows 98';
          end
          else if (majorVer = 4) and (minorVer = 90) then
            Result := 'Windows ME'
          else
            Result := 'Unknown';
        end;
      else
        Result := 'Unknown';
    end;
  end
  else
    Result := 'Unknown';
end;

function TExeInfo.GetWinDir : String;
//Returns the windows directory
var
   pcWindowsDirectory : PChar;
   dwWDSize           : DWORD;
begin
   dwWDSize := MAX_PATH + 1;
   GetMem( pcWindowsDirectory, dwWDSize ); // allocate memory for the string
   try
      if Windows.GetWindowsDirectory( pcWindowsDirectory, dwWDSize ) <> 0 then
         Result := StrPas(pcWindowsDirectory) + '\';
   finally
      FreeMem( pcWindowsDirectory ); // now free the memory allocated for the string
   end;
end;

function TExeInfo.GetSysDir : String;
//Returns system directory
var
   pcSystemDirectory : PChar;
   dwSDSize          : DWORD;
begin
   dwSDSize := MAX_PATH + 1;
   GetMem( pcSystemDirectory, dwSDSize ); // allocate memory for the string
   try
      if Windows.GetSystemDirectory( pcSystemDirectory, dwSDSize ) <> 0 then
         Result := StrPas(pcSystemDirectory) + '\';
   finally
      FreeMem( pcSystemDirectory ); // now free the memory allocated for the string
   end;
end;

function TExeInfo.GetTempDir : String;
//Returns temp directory
var
   pcTempDirectory : PChar;
   dwSDSize          : DWORD;
begin
   dwSDSize := MAX_PATH + 1;
   GetMem( pcTempDirectory, dwSDSize ); // allocate memory for the string
   try
      if Windows.GetTempPath( dwSDSize, pcTempDirectory ) <> 0 then
         Result := pcTempDirectory;
   finally
      FreeMem( pcTempDirectory ); // now free the memory allocated for the string
   end;
end;

function TExeInfo.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

function TExeInfo.GetVersionNr: Integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

procedure TExeInfo.SetVersion(const Value: string);
begin

end;

end.



