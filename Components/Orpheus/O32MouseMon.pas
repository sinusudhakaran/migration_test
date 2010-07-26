{*********************************************************}
{*                 O32MOUSEMON.PAS 4.0                   *}
{*       Copyright (c) 2001 TURBOPOWER Software Co       *}
{*                 All rights reserved.                  *}
{*********************************************************}

(*Changes)
{!!.02}
  10/20/01- Hdc changed to TOvcHdc for BCB Compatibility
*)

{$I OVC.INC}

unit O32MouseMon;
  { Orpheus Mouse Monitor }

interface
uses
  Windows, Classes, SysUtils, Messages, OvcMisc;                      {!!.02}

type
{!!.02 - HWnd changed to TOvcHWnd for BCB Compatibility}
  TMouseMonHandler = procedure(const MouseMessage, wParam, lParam: Integer;
    const ScreenPt: TPoint; const MouseWnd: TOvcHWnd{hWnd}) of object;

procedure StartMouseMonitor(Callback: TMouseMonHandler);
procedure StopMouseMonitor(Callback: TMouseMonHandler);

implementation

type
  TMouseMonEntry = class
  protected
    FHandler: TMouseMonHandler;
  public
    property Handler: TMouseMonHandler read FHandler write FHandler;
  end;

var
  MouseMonList: TList = nil;
  ghhk: HHook = 0;
  mhhk: HHook = 0;

function MessageHookProc(nCode: Integer; wParam, lParam: Integer): Integer; stdcall;
var
  i: Integer;
begin
  if nCode = 0 then begin
    if (nCode = HC_ACTION) and (PMsg(lParam).message = WM_MOUSEWHEEL) then
      for i := 0 to MouseMonList.Count - 1 do
        TMouseMonEntry(MouseMonList[i]).Handler(
          PMsg(lParam).message,
          PMsg(lParam).wParam,
          PMsg(lParam).lParam,
          PMsg(lParam).pt,
          PMsg(lParam).hwnd);
  end;
  Result := CallNextHookEx(ghhk, nCode, wParam, lParam);
end;

function MouseHookProc(nCode: Integer; wParam, lParam: Integer): Integer; stdcall;
var
  i: Integer;
begin
  if (nCode = HC_ACTION) and (wParam <> WM_MOUSEWHEEL) then
    for i := 0 to MouseMonList.Count - 1 do
      TMouseMonEntry(MouseMonList[i]).Handler(
        wParam,
        0,
        0,
        PMouseHookStruct(lParam).pt,
        PMouseHookStruct(lParam).hwnd);
  Result := CallNextHookEx(mhhk, nCode, wParam, lParam);
end;

procedure InstallHook;
begin
  mhhk := SetWindowsHookEx(WH_MOUSE, TFNHookProc(@MouseHookProc), 0, GetCurrentThreadID);
  ghhk := SetWindowsHookEx(WH_GETMESSAGE, TFNHookProc(@MessageHookProc), 0, GetCurrentThreadID);
end;

procedure StartMouseMonitor(Callback: TMouseMonHandler);
var
  NewEntry: TMouseMonEntry;
  i: Integer;
begin
  if MouseMonList = nil then
    MouseMonList := TList.Create;
  for i := 0 to MouseMonList.Count - 1 do
    if (TMethod(TMouseMonEntry(MouseMonList[i]).Handler).Code = TMethod(Callback).Code)
    and (TMethod(TMouseMonEntry(MouseMonList[i]).Handler).Data = TMethod(Callback).Data) then begin
      raise Exception.Create('Only one handler per window at a time, please');
      //exit;
    end;
  NewEntry := TMouseMonEntry.Create;
  NewEntry.Handler := Callback;
  MouseMonList.Add(NewEntry);
  if mhhk = 0 then
    InstallHook;
end;

procedure ClearMonList;
begin
  if MouseMonList = nil then exit;
  while MouseMonList.Count > 0 do begin
    TMouseMonEntry(MouseMonList[0]).Free;
    MouseMonList.Delete(0);
  end;
  MouseMonList.Free;
  MouseMonList := nil;
  if mhhk <> 0 then begin
    UnhookWindowsHookEx(mhhk);
    mhhk := 0;
    UnhookWindowsHookEx(ghhk);
    ghhk := 0;
  end;
end;

procedure StopMouseMonitor(Callback: TMouseMonHandler);
var
  i: Integer;
begin
  if MouseMonList = nil then exit;
  for i := 0 to MouseMonList.Count - 1 do
    if (TMethod(TMouseMonEntry(MouseMonList[i]).Handler).Code = TMethod(Callback).Code)
    and (TMethod(TMouseMonEntry(MouseMonList[i]).Handler).Data = TMethod(Callback).Data) then begin
      TMouseMonEntry(MouseMonList[i]).Free;
      MouseMonList.Delete(i);
      if MouseMonList.Count = 0 then
        ClearMonList;
      exit;
    end;
end;

initialization
finalization
  ClearMonList;
end.
