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
