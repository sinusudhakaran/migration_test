unit BroadcastSystem;

interface

uses
  Forms,
  Messages,
  Windows;

const
  UM_MAINFORM_MODALCOMMAND = WM_USER + 1000;

  procedure BroadcastMessage(const aMessage: integer; const aValue: integer);

implementation

procedure BroadcastMessage(const aMessage: integer; const aValue: integer);
var
  i: integer;
  varMain: TForm;
  varMDIChild: TForm;
begin
  // Note: HWND_BROADCAST does not broadcast to child windows

  // Post to main
  varMain := Application.MainForm;
  PostMessage(varMain.Handle, aMessage, aValue, 0);

  // Post to MDI children
  for i := 0 to varMain.MDIChildCount-1 do    // Iterate
  begin
    varMDIChild := varMain.MDIChildren[i];
    PostMessage(varMDIChild.Handle, aMessage, aValue, 0);
  end;
end;

end.