{*********************************************************}
{* SysTools: StWmDCpy.pas 3.03                           *}
{* Copyright (c) TurboPower Software Co 1996, 2001       *}
{* All rights reserved.                                  *}
{*********************************************************}
{* SysTools: Class for handling WM_COPYDATA exchanges    *}
{*********************************************************}

{$I StDefine.inc}

{$IFDEF WIN16}
  {$C MOVEABLE,DEMANDLOAD,DISCARDABLE}
{$ENDIF}

unit StWmDCpy;

interface

uses
  {$IFDEF MSWINDOWS}
  Windows,
  {$ENDIF}
  {$IFDEF WIN16}
  WinTypes, WinProcs,
  {$ENDIF}
  SysUtils,
  Messages,
  Classes,
  Forms,
  Controls,
  Dialogs,

  StBase;

type
  TStOnDataReceivedEvent = procedure(Sender   : TObject;
                                     CopyData : TCopyDataStruct) of object;

  TStWMDataCopy = class(TStComponent)
  protected {private}
    { Private declarations }
    NewWndProc      : TFarProc;
    PrevWndProc     : TFarProc;
    FOnDataReceived : TStOnDataReceivedEvent;

    procedure AppWndProc(var Msg : TMessage);
    procedure HookForm(Value : Boolean);
  protected
    { Protected declarations }

  public
    { Public declarations }

    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }

    property OnDataReceived : TStOnDataReceivedEvent
      read FOnDataReceived
      write FOnDataReceived;
  end;


implementation


constructor TStWMDataCopy.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);

  if not (csDesigning in ComponentState) then begin
{$IFDEF Version6} {$WARN SYMBOL_DEPRECATED OFF} {$ENDIF}
    NewWndProc := MakeObjectInstance(AppWndProc);
{$IFDEF Version6} {$WARN SYMBOL_DEPRECATED ON} {$ENDIF}
    HookForm(True);
  end;
end;

destructor TStWMDataCopy.Destroy;
begin
  if Assigned(NewWndProc) then begin
    HookForm(False);
{$IFDEF Version6} {$WARN SYMBOL_DEPRECATED OFF} {$ENDIF}
    FreeObjectInstance(NewWndProc);
{$IFDEF Version6} {$WARN SYMBOL_DEPRECATED ON} {$ENDIF}
  end;

  inherited Destroy;
end;

procedure TStWMDataCopy.HookForm(Value : Boolean);
begin
  if (not (csDesigning in ComponentState))
      and not (csDestroying in ComponentState) then begin
    if Assigned(PrevWndProc) then
      Exit;
    if Value then begin
      PrevWndProc:= Pointer(
        SetWindowLong(TForm(Owner).Handle, GWL_WNDPROC, LongInt(NewWndProc)))
    end else if Assigned(PrevWndProc) then begin
      SetWindowLong(TForm(Owner).Handle, GWL_WNDPROC, LongInt(PrevWndProc));
      PrevWndProc := nil;
    end;
  end;
end;

procedure TStWMDataCopy.AppWndProc(var Msg : TMessage);
var
  CDS   : TCopyDataStruct;
begin
  with Msg do begin
    if (Msg = WM_COPYDATA) then begin
      CDS := PCopyDataStruct(Pointer(lParam))^;
      if (CDS.dwData = WMCOPYID) then begin
        if (Assigned(FOnDataReceived)) then
          FOnDataReceived(Self, CDS);
      end else
        if Assigned(PrevWndProc) then
          Result :=
            CallWindowProc(PrevWndProc, TForm(Owner).Handle, Msg, wParam, lParam);
    end else
      if Assigned(PrevWndProc) then
        Result :=
          CallWindowProc(PrevWndProc, TForm(Owner).Handle, Msg, wParam, lParam);
  end;
end;

end.
