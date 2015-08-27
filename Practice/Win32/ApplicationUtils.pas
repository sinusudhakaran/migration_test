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

//******************************************************************************
implementation
uses
  Forms, Windows;

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

  Result := Wow64Proc;
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
