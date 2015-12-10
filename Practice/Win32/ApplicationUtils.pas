unit ApplicationUtils;
//------------------------------------------------------------------------------
{
   Title:       Application Utilities

   Description: Utilities for controling an application

   Author:      Matthew Hopkins

   Remarks:

}
//------------------------------------------------------------------------------

interface

procedure DisableMainForm;
function EnableMainForm: Boolean;
procedure MakeMainFormForeground;
function CanProcessCommands : boolean;
function IsWoW64 : Boolean;
function IsOutlook64Bit: Boolean;

//******************************************************************************
implementation
uses
  Forms, Windows,Registry, SysUtils;

var
  FDisableMainFormCount : integer = 0;
  WindowList : pointer;

procedure DisableMainForm;
begin
  if FDisableMainFormCount = 0 then
  begin
    WindowList := DisableTaskWindows(0);
  end;
  Inc( FDisableMainFormCount);
end;

{To make sure outlook used in clients machine is 64 bit or not.}
function IsOutlook64Bit: Boolean;

// need this constant since this is not declared in windows unit. Others are present in windows unit
const
  SCS_64BIT_BINARY = 6;
var
  Registry : TRegistry;
  OutlookPath : string;
  BinaryType: DWORD;
begin
  { Create the OLE Object }
  Registry := TRegistry.Create;
  Result := False;
  try
    // Try under current user
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.Access := KEY_READ;
    OutlookPath := '';

    if Registry.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\') and
      (Registry.KeyExists('outlook.exe')) and
      (Registry.OpenKeyReadOnly('outlook.exe')) then
      OutlookPath := Registry.ReadString('path')
    else
    begin
      // Try under local machine
      Registry.RootKey := HKEY_LOCAL_MACHINE;
      Registry.Access := KEY_READ;

      if Registry.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\') and
        (Registry.KeyExists('outlook.exe')) and
        (Registry.OpenKeyReadOnly('outlook.exe')) then
        OutlookPath := Registry.ReadString('path');
    end;
    if (Trim(OutlookPath) <> '') and GetBinaryType(Pchar(OutlookPath+'outlook.exe'), Binarytype) then
    case BinaryType of
      {SCS_32BIT_BINARY,
      SCS_DOS_BINARY,
      SCS_WOW_BINARY,
      SCS_PIF_BINARY,
      SCS_POSIX_BINARY,
      SCS_OS216_BINARY : Result := False;}
      SCS_64BIT_BINARY : Result := True;
    end;
  finally
    FreeAndNil(Registry);
  end;
end;

function IsWoW64 : Boolean;
var
  IsWow64Process: function(hProcess: THandle; out Wow64Process: Bool): Bool; stdcall;
  Wow64Proc : Bool;
begin
  Result := False;
  IsWow64Process := GetProcAddress(GetModuleHandle(Kernel32), 'IsWow64Process');

  Wow64Proc := False;
  if Assigned(IsWow64Process) then
    Wow64Proc := IsWow64Process(GetCurrentProcess, Wow64Proc) and Wow64Proc;

  Result := Wow64Proc and IsOutlook64Bit;
end;

function EnableMainForm: Boolean;
begin
  Dec( FDisableMainFormCount);
  Result := (FDisableMainFormCount = 0);
  if Result then
      EnableTaskWindows(WindowList);
end;

procedure MakeMainFormForeground;
begin
  SetForegroundWindow( Application.MainForm.Handle);
end;

function CanProcessCommands : boolean;
begin
  result := FDisableMainFormCount = 0;
end;

initialization
  FDisableMainFormCount := 0;
  WindowList := nil;

end.
