{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars components                                      }
{                                                                   }
{       Copyright (c) 1998-2009 Developer Express Inc.              }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE    }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS   }
{   LICENSED TO DISTRIBUTE THE EXPRESSBARS AND ALL ACCOMPANYING VCL }
{   CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.                 }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT  }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                      }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit dxRibbonForm;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ImgList, cxClasses, cxGraphics, cxControls,
  dxRibbonSkins, dxRibbonFormCaptionHelper, cxDWMApi;

type

  { TdxCustomRibbonForm }

  TdxCustomRibbonForm = class(TForm)
  private
    FAdjustLayoutForNonClientDrawing: Boolean;
    FAutoScroll: Boolean;
    FCaption: TCaption;
    FCornerRegions: array[0..3] of HRGN;
    FData: TdxRibbonFormData;
    FDisableAero: Boolean;
    FExtendFrameAtTopHeight: Integer;
    FFakeClientHandle: HWND;
    FZoomedBoundsOffsets: TRect;
    FIsActive: Boolean;
    FSizingBorders: TSize;
    FSizingLoop: Boolean;
    FDelayedActivate: Boolean;
    FNeedCallActivate: Boolean;
    FUseSkin: Boolean;
    FUseSkinColor: Boolean;
    FVisibleChanging: Boolean;
    FDefClientProc: TFarProc;
    FNewClientInstance: TFarProc;
    FOldClientProc: TFarProc;
    FPrevActiveControl: TWinControl;
  {$IFDEF DELPHI10}
    FRibbonAlwaysOnTop: Boolean;
  {$ENDIF}
    FRibbonNonClientHelper: TdxRibbonFormCaptionHelper;
    procedure CalculateCornerRegions;
    procedure CalculateZoomedOffsets;
    procedure CheckExtendFrame(AZoomed: Boolean);
    procedure CheckResizingNCHitTest(var AHitTest: Integer; const P: TPoint);
    procedure CorrectZoomedBounds(var R: TRect);
    procedure CreateCornerRegions;
    procedure DestroyCornerRegions;
    procedure ExcludeRibbonPaintArea(DC: HDC);
    procedure ForceUpdateWindowSizeForVista;
    procedure FullRedrawWithChildren;
    function GetCurrentBordersWidth: TRect;
    function GetBackgroundColor: TColor;
    function GetUseSkin: Boolean;
    procedure InvalidateFrame(AWnd: HWND; AUpdate: Boolean = False);
    function IsNeedCorrectForAutoHideTaskBar: Boolean;
    function IsNormalWindowState: Boolean;
    procedure NewClientWndProc(var Message: TMessage);
    procedure SetAutoScroll(const Value: Boolean);
    procedure SetDisableAero(const Value: Boolean);
    procedure SetPrevActiveControl(AValue: TWinControl);
  {$IFDEF DELPHI10}
    procedure SetRibbonAlwaysOnTop(const Value: Boolean);
  {$ENDIF}
    procedure SetRibbonNonClientHelper(const Value: TdxRibbonFormCaptionHelper);
    procedure SetUseSkinColor(const Value: Boolean);
    procedure ShowSystemMenu(AFromMouse: Boolean);
    procedure UpdateGlassFrame;
    procedure UpdateSystemMenu;
    //messages
    procedure CMActionUpdate(var Message: TMessage); message CM_ACTIONUPDATE;
    procedure CMActivate(var Message: TCMActivate); message CM_ACTIVATE;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure WMCaptureChanged(var Message: TMessage); message WM_CAPTURECHANGED;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMInitMenu(var Message: TWMInitMenu); message WM_INITMENU;
    procedure WMNCActivate(var Message: TWMNCActivate); message WM_NCACTIVATE;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMShowWindow(var Message: TMessage); message WM_SHOWWINDOW;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMNCRButtonUp(var Message: TWMNCRButtonUp); message WM_NCRBUTTONUP;
    procedure WMQueryOpen(var Message: TWMQueryOpen); message WM_QUERYOPEN;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Message: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    //vista support
    procedure WMDWMCompositionChanged(var Message: TMessage); message WM_DWMCOMPOSITIONCHANGED;
    //caption
    procedure WMGetText(var Message: TWMGetText); message WM_GETTEXT;
    procedure WMGetTextLength(var Message: TWMGetTextLength); message WM_GETTEXTLENGTH;
    procedure WMSetText(var Message: TWMSetText); message WM_SETTEXT;
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure AdjustLayout; virtual;
    procedure AdjustSize; override;
  {$IFDEF DELPHI10}
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  {$ENDIF}
    procedure CallDWMWindowProc(var Message);
    function CanAdjustLayout: Boolean; virtual;
    procedure CaptionChanged;
    procedure CreateWnd; override;
    procedure DestroyWindowHandle; override;
    procedure DoCreate; override;
    procedure DrawNonClientArea(ADrawCaption: Boolean; AUpdateRegion: HRGN = 1);
    procedure ExtendFrameIntoClientAreaAtTop(AHeight: Integer);
    function GetFormBorderIcons: TBorderIcons; virtual;
    function HandleWithHelper(ADown: Boolean; AButton: TMouseButton): Boolean; virtual;
    procedure InitializeNewForm; {$IFDEF DELPHI12} override; {$ENDIF}
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure ModifySystemMenu(ASysMenu: THandle); virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ShiftControlsVertically(ADelta: Integer); virtual;
    procedure UpdateNonClientArea;
    procedure UpdateWindowStates;
    procedure WndProc(var Message: TMessage); override;

    property DisableAero: Boolean read FDisableAero write SetDisableAero default False;
    property UseSkin: Boolean read GetUseSkin;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;
    procedure Invalidate; override;
    function IsUseAeroNCPaint: Boolean;

    property PrevActiveControl: TWinControl read FPrevActiveControl write SetPrevActiveControl;
  {$IFDEF DELPHI10}
    property RibbonAlwaysOnTop: Boolean read FRibbonAlwaysOnTop write SetRibbonAlwaysOnTop;
  {$ENDIF}
    property RibbonNonClientHelper: TdxRibbonFormCaptionHelper
      read FRibbonNonClientHelper write SetRibbonNonClientHelper;
    property IsActive: Boolean read FIsActive;
  published
    property AdjustLayoutForNonClientDrawing: Boolean
      read FAdjustLayoutForNonClientDrawing write FAdjustLayoutForNonClientDrawing default True;
    property AutoScroll: Boolean read FAutoScroll write SetAutoScroll default False;
    property KeyPreview default True;
    property UseSkinColor: Boolean read FUseSkinColor write SetUseSkinColor default True;
  end;

  { TdxRibbonForm }

  TdxRibbonForm = class(TdxCustomRibbonForm);

procedure SetWindowTextWithoutRedraw(AWnd: HWND; const AText: string);

implementation

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  dxBar, cxGeometry, Math, dxOffice11, dxUxTheme, MultiMon, ShellAPI, dxRibbon,
  dxStatusBar;

const
{$IFNDEF DELPHI7}
  WM_NCMOUSELEAVE     = $02A2;
{$ENDIF}
  WM_NCUAHDRAWCAPTION = $00AE;
  WM_NCUAHDRAWFRAME   = $00AF;
  WM_SYNCPAINT        = $0088;
  WM_SYSMENU          = $313;

  dxGlassMaximizedNonClientHeight = 4;
  dxFullRedrawFlags = RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN;

procedure SetWindowTextWithoutRedraw(AWnd: HWND; const AText: string);
var
  AFlags: Cardinal;
begin
  AFlags := GetWindowLong(AWnd, GWL_STYLE);
  SetWindowLong(AWnd, GWL_STYLE, AFlags and not WS_VISIBLE);
  DefWindowProc(AWnd, WM_SETTEXT, 0, LongInt(PChar(AText)));
  SetWindowLong(AWnd, GWL_STYLE, AFlags);
end;

function GetAnimation: Boolean;
var
  AInfo: TAnimationInfo;
begin
  AInfo.cbSize := SizeOf(TAnimationInfo);
  if SystemParametersInfo(SPI_GETANIMATION, SizeOf(AInfo), @AInfo, 0) then
    Result := AInfo.iMinAnimate <> 0
  else
    Result := False;
end;

procedure SetAnimation(AValue: Boolean);
var
  AInfo: TAnimationInfo;
begin
  AInfo.cbSize := SizeOf(TAnimationInfo);
  BOOL(AInfo.iMinAnimate) := AValue;
  SystemParametersInfo(SPI_SETANIMATION, SizeOf(AInfo), @AInfo, 0);
end;

{ TdxCustomRibbonForm }

constructor TdxCustomRibbonForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner); //CBUILDER workaround
end;

constructor TdxCustomRibbonForm.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  inherited CreateNew(AOwner, Dummy);
{$IFNDEF DELPHI12}
  InitializeNewForm;
{$ENDIF}
end;

destructor TdxCustomRibbonForm.Destroy;
begin
  DestroyCornerRegions;
  inherited Destroy;
end;

procedure TdxCustomRibbonForm.Invalidate;
begin
  if HandleAllocated and not IsIconic(Handle) then
    CheckExtendFrame(IsZoomed(Handle));
  inherited Invalidate;
  if ClientHandle <> 0 then
    InvalidateRect(ClientHandle, nil, True);
end;

procedure TdxCustomRibbonForm.CreateWnd;
var
  ClientCreateStruct: TClientCreateStruct;
begin
  FExtendFrameAtTopHeight := -1;
  inherited CreateWnd;
  if not (csDesigning in ComponentState) and (FormStyle = fsMDIForm) then
  begin
    with ClientCreateStruct do
    begin
      idFirstChild := $FF00; //check
      hWindowMenu := 0;
    end;
    FFakeClientHandle := Windows.CreateWindowEx(WS_EX_CLIENTEDGE, 'MDICLIENT',
      nil, WS_CHILD or WS_VISIBLE or WS_GROUP or WS_TABSTOP or
      WS_CLIPCHILDREN or WS_CLIPSIBLINGS or
      MDIS_ALLCHILDSTYLES, 0, 0, ClientWidth, ClientHeight, Handle, 0,
      HInstance, @ClientCreateStruct);
    SetWindowPos(FFakeClientHandle, 0, -20, -20, 10, 10, SWP_NOACTIVATE or SWP_NOZORDER);
    FOldClientProc := Pointer(GetWindowLong(ClientHandle, GWL_WNDPROC));
    FDefClientProc := Pointer(GetWindowLong(FFakeClientHandle, GWL_WNDPROC));
    FNewClientInstance := {$IFDEF DELPHI6}Classes.{$ENDIF}MakeObjectInstance(NewClientWndProc);
    SetWindowLong(ClientHandle, GWL_WNDPROC, Longint(FNewClientInstance));
    if ClientHandle <> 0 then
    begin
      SetWindowLong(ClientHandle, GWL_EXSTYLE,
        GetWindowLong(ClientHandle, GWL_EXSTYLE) and not WS_EX_CLIENTEDGE);
      InvalidateFrame(ClientHandle);
    end;
  end;
  UpdateSystemMenu;
end;

procedure TdxCustomRibbonForm.DestroyWindowHandle;
begin
  inherited DestroyWindowHandle;
  if csDestroying in ComponentState then
    RibbonNonClientHelper := nil;
end;

procedure TdxCustomRibbonForm.DoCreate;
begin
  inherited DoCreate;
  if FUseSkin then
    AdjustLayout;
end;

procedure TdxCustomRibbonForm.AdjustClientRect(var Rect: TRect);
begin
  inherited;
  if IsUseAeroNCPaint and IsZoomed(Handle) then
    Inc(Rect.Top, dxGlassMaximizedNonClientHeight);
end;

procedure TdxCustomRibbonForm.AdjustLayout;
var
  ALoadedHeight, AHeight, ADelta: Integer;
begin
  if not CanAdjustLayout then Exit;
  RibbonNonClientHelper.GetDesignInfo(ALoadedHeight, AHeight);
  ADelta := AHeight - ALoadedHeight;
  if WindowState <> wsMaximized then
    ClientHeight := ClientHeight + ADelta - (GetSystemMetrics(SM_CYCAPTION) + GetDefaultWindowBordersWidth(Handle).Top);
  ShiftControlsVertically(ADelta);
end;

procedure TdxCustomRibbonForm.AdjustSize;
{$IFDEF DELPHI11}
var
  AFlags: Cardinal;
{$ENDIF}
begin
{$IFDEF DELPHI11}
  if not (csLoading in ComponentState) and HandleAllocated then
  begin
    AFlags := SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOZORDER;
    if IsZoomed(Handle) then
      AFlags := AFlags or SWP_NOSIZE;
    SetWindowPos(Handle, 0, 0, 0, Width, Height, AFlags);
    RequestAlign;
  end;
{$ELSE}
  inherited AdjustSize;
{$ENDIF}
end;

{$IFDEF DELPHI10}
procedure TdxCustomRibbonForm.AlignControls(AControl: TControl; var Rect: TRect);
var
  AlignList: TList;

  function GetClientSize(Control: TWinControl): TPoint; {inline;}
  begin
    if Control.HandleAllocated then
      Result := Control.ClientRect.BottomRight
    else
      Result := Point(Control.Width, Control.Height);
    Dec(Result.X, Control.Padding.Left + Control.Padding.Right);
    Dec(Result.Y, Control.Padding.Top + Control.Padding.Bottom);
  end;

  function InsertBefore(C1, C2: TControl; AAlign: TAlign): Boolean;
  begin
    Result := False;
    case AAlign of
      alTop:
        begin
          if FRibbonAlwaysOnTop and UseSkin and RibbonNonClientHelper.IsTopmostControl(C1) then
            Result := True
          else
            Result := C1.Margins.ControlTop < C2.Margins.ControlTop;
        end;
      alBottom: Result := (C1.Margins.ControlTop + C1.Margins.ControlHeight) >= (C2.Margins.ControlTop + C2.Margins.ControlHeight);
      alLeft: Result := C1.Margins.ControlLeft < C2.Margins.ControlLeft;
      alRight: Result := (C1.Margins.ControlLeft + C1.Margins.ControlWidth) >= (C2.Margins.ControlLeft + C2.Margins.ControlWidth);
      alCustom: Result := CustomAlignInsertBefore(C1, C2);
    end;
  end;

  procedure DoPosition(Control: TControl; AAlign: TAlign; AlignInfo: TAlignInfo);
  begin
    ArrangeControl(Control, GetClientSize(Control.Parent), AAlign, AlignInfo, Rect);
  end;

  function Anchored(Align: TAlign; Anchors: TAnchors): Boolean;
  begin
    case Align of
      alLeft: Result := akLeft in Anchors;
      alTop: Result := akTop in Anchors;
      alRight: Result := akRight in Anchors;
      alBottom: Result := akBottom in Anchors;
      alClient: Result := Anchors = [akLeft, akTop, akRight, akBottom];
    else
      Result := False;
    end;
  end;

  procedure DoAlign(AAlign: TAlign);
  var
    I, J: Integer;
    Control: TControl;
    AlignInfo: TAlignInfo;
  begin
    AlignList.Clear;
    if (AControl <> nil) and ((AAlign = alNone) or AControl.Visible or
      (csDesigning in AControl.ComponentState) and
      not (csNoDesignVisible in AControl.ControlStyle)) and
      (AControl.Align = AAlign) then
      AlignList.Add(AControl);
    for I := 0 to ControlCount - 1 do
    begin
      Control := Controls[I];
      if (Control.Align = AAlign) and ((AAlign = alNone) or (Control.Visible or
        (Control.ControlStyle * [csAcceptsControls, csNoDesignVisible] =
          [csAcceptsControls, csNoDesignVisible])) or
        (csDesigning in Control.ComponentState) and
        not (csNoDesignVisible in Control.ControlStyle)) and
        (not (Control is TCustomForm) or not (csDesigning in Control.ComponentState)) then
      begin
        if Control = AControl then Continue;
        J := 0;
        while (J < AlignList.Count) and not InsertBefore(Control,
          TControl(AlignList[J]), AAlign) do Inc(J);
        AlignList.Insert(J, Control);
      end;
    end;
    for I := 0 to AlignList.Count - 1 do
    begin
      AlignInfo.AlignList := AlignList;
      AlignInfo.ControlIndex := I;
      AlignInfo.Align := AAlign;
      DoPosition(TControl(AlignList[I]), AAlign, AlignInfo);
    end;
  end;

  function AlignWork: Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := ControlCount - 1 downto 0 do
      if (Controls[I].Align <> alNone) or
        (Controls[I].Anchors <> [akLeft, akTop]) then Exit;
    Result := False;
  end;

var
  R: TRect;
begin
  if DockSite and UseDockManager and (DockManager <> nil) then
    DockManager.ResetBounds(False);
  if AlignWork then
  begin
    AdjustClientRect(Rect);
    AlignList := TList.Create;
    try
      DoAlign(alTop);
      DoAlign(alBottom);
      DoAlign(alLeft);
      DoAlign(alRight);
      DoAlign(alClient);
      DoAlign(alCustom);
      DoAlign(alNone);
      ControlsAligned;
    finally
      AlignList.Free;
    end;
  end;
  if Showing then AdjustSize;
  if ClientHandle <> 0 then
  begin
    with Rect do
      SetWindowPos(ClientHandle, HWND_BOTTOM, Left, Top, Right - Left,
        Bottom - Top, SWP_NOZORDER + SWP_NOACTIVATE);
    if FormStyle = fsMDIForm then
      if Windows.GetClientRect(ClientHandle, R) then
        InvalidateRect(ClientHandle, nil, True);
  end;
end;
{$ENDIF}

procedure TdxCustomRibbonForm.CallDWMWindowProc(var Message);
begin
  DwmDefWindowProc(Handle, TMessage(Message).Msg, TMessage(Message).WParam,
    TMessage(Message).LParam, Integer(@TMessage(Message).Result));
end;

function TdxCustomRibbonForm.CanAdjustLayout: Boolean;
begin
  Result := AdjustLayoutForNonClientDrawing and
    ([csDesigning, csDestroying, csReading, csLoading] * ComponentState = []);
end;

procedure TdxCustomRibbonForm.CaptionChanged;
begin
  UpdateWindowStates;
  RibbonNonClientHelper.CaptionChanged;
end;

procedure TdxCustomRibbonForm.NewClientWndProc(var Message: TMessage);

  procedure Default;
  begin
    with Message do
      Result := CallWindowProc(FDefClientProc, ClientHandle, Msg, wParam, lParam);
  end;

  procedure OldDefault;
  begin
    with Message do
      Result := CallWindowProc(FOldClientProc, ClientHandle, Msg, wParam, lParam);
  end;

  function MaximizedChildren: Boolean;
  var
    I: Integer;
  begin
    for I := 0 to MDIChildCount - 1 do
      if MDIChildren[I].WindowState = wsMaximized then
      begin
        Result := True;
        Exit;
      end;
    Result := False;
  end;

var
  DC: HDC;
  PS: TPaintStruct;
  R: TRect;
//  F: TForm;
  AColor: TColor;
begin
  if not UseSkin then
  begin
    with Message do
      case Msg of
        WM_NCHITTEST, WM_PAINT, WM_ERASEBKGND:
          OldDefault;
        WM_NCCALCSIZE:;
        WM_NCPAINT:;
        else
          Default;
      end;
    Exit;
  end;
  with Message do
    case Msg of
      WM_KEYDOWN:
        begin
          KeyDown(WParamLo, KeyDataToShiftState(LParam));
          if WParamLo = 0 then Exit;
          Default;
        end;
      WM_NCHITTEST:
        begin
          Default;
          if Result = HTCLIENT then Result := HTTRANSPARENT;
        end;
      WM_ERASEBKGND:
        begin
          AColor := GetBackgroundColor;
          FillRectByColor(TWMEraseBkGnd(Message).DC, ClientRect, AColor);
          // Erase the background at the location of an MDI client window
          if (FormStyle = fsMDIForm) and (ClientHandle <> 0) then
          begin
            Windows.GetClientRect(ClientHandle, R);
            FillRectByColor(TWMEraseBkGnd(Message).DC, R, AColor);
          end;
          Result := 1;
        end;
      WM_NCCALCSIZE:;
      WM_NCPAINT:;
      WM_MDIREFRESHMENU:
        Result := 0;
      WM_NCACTIVATE:
        Message.Result := 1;
      {
      $3F://!
        begin
          Default;
          F := ActiveMDIChild;
          if (F <> nil) and MaximizedChildren then
          begin
            //correct maximized bounds
            GetWindowRect(ClientHandle, R);
            R.Right := R.Right - R.Left + (F.Width - F.ClientWidth);
            R.Bottom := R.Bottom - R.Top + (F.Height - F.ClientHeight);
            if (F is TdxCustomRibbonForm) and TdxCustomRibbonForm(F).UseSkin then
              Inc(R.Bottom, TdxCustomRibbonForm(F).RibbonNonClientHelper.GetWindowCaptionHeight);
            SetWindowPos(F.Handle, 0, 0, 0, R.Right, R.Bottom,
              SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOZORDER);
          end;
        end;
      }
      WM_PAINT:
        begin
          DC := TWMPaint(Message).DC;
          if DC = 0 then
            TWMPaint(Message).DC := BeginPaint(ClientHandle, PS);
          try
            if DC = 0 then
            begin
              R := cxGetWindowRect(ClientHandle);
              R.TopLeft := ScreenToClient(R.TopLeft);
              MoveWindowOrg(TWMPaint(Message).DC, -R.Left, -R.Top);
            end;
            PaintHandler(TWMPaint(Message));
          finally
            if DC = 0 then
              EndPaint(ClientHandle, PS);
          end;
        end;
    else
      Default;
    end;
end;

procedure TdxCustomRibbonForm.DrawNonClientArea(ADrawCaption: Boolean; AUpdateRegion: HRGN = 1);
var
  DC: HDC;
  AFlags: Integer;
  ARgn: HRGN;
  AZoomed: Boolean;
begin
  if IsUseAeroNCPaint then Exit;
  UpdateWindowStates;
  AFlags := DCX_CACHE or DCX_CLIPSIBLINGS or DCX_WINDOW or DCX_VALIDATE;
  if AUpdateRegion <> 1 then
  begin
    ARgn := CreateRectRgnIndirect(cxEmptyRect);
    CombineRgn(ARgn, AUpdateRegion, 0, RGN_COPY);
    DC := GetDCEx(Handle, ARgn, AFlags or DCX_INTERSECTRGN);
  end
  else
    DC := GetDCEx(Handle, 0, AFlags);
  BarCanvas.BeginPaint(DC);
  BarCanvas.Canvas.Lock;
  try
    if IsIconic(Handle) then
      RibbonNonClientHelper.DrawWindowCaption(BarCanvas, Caption)
    else
    begin
      AZoomed := IsZoomed(Handle);
      if not AZoomed then
        RibbonNonClientHelper.DrawWindowBorders(BarCanvas);
      if ADrawCaption then
        RibbonNonClientHelper.DrawWindowCaption(nil, Caption);
    end;
  finally
    BarCanvas.Canvas.Unlock;
    BarCanvas.EndPaint;
    ReleaseDC(Handle, DC);
  end;
end;

function TdxCustomRibbonForm.HandleWithHelper(ADown: Boolean;
  AButton: TMouseButton): Boolean;
var
  P: TPoint;
begin
  Result := UseSkin;
  if Result then
  begin
    P := GetMouseCursorPos;
    if RibbonNonClientHelper.IsInCaptionArea(P.X, P.Y) then
    begin
      if ADown then
        Result := RibbonNonClientHelper.MouseDown(P, AButton)
      else
        Result := RibbonNonClientHelper.MouseUp(P, AButton);
    end
    else
      Result := False;
  end;
end;

procedure TdxCustomRibbonForm.InitializeNewForm;
begin
{$IFDEF DELPHI12}
  inherited InitializeNewForm;
{$ENDIF}
  FAutoScroll := False;
  FUseSkinColor := True;
  FAdjustLayoutForNonClientDrawing := True;
  AutoScroll := False;
  KeyPreview := True;
  CreateCornerRegions;
end;

procedure TdxCustomRibbonForm.KeyDown(var Key: Word; Shift: TShiftState);
var
  I: Integer;
  AIntf: IdxFormKeyPreviewListener;
  AForm: TForm;
begin
  inherited KeyDown(Key, Shift);
  if KeyPreview then
  begin
    if FormStyle = fsMDIChild then
      AForm := Application.MainForm
    else
      AForm := Self;
    for I := 0 to AForm.ControlCount - 1 do
      if Supports(TObject(AForm.Controls[I]), IdxFormKeyPreviewListener, AIntf) then
      begin
        AIntf.FormKeyDown(Key, Shift);
        AIntf := nil;
      end;
  end;
end;

procedure TdxCustomRibbonForm.ModifySystemMenu(ASysMenu: THandle);
begin
  if (BorderStyle <> bsNone) and (biSystemMenu in BorderIcons) and (FormStyle <> fsMDIChild) then
  begin
    if BorderStyle = bsDialog then
    begin
      DeleteMenu(ASysMenu, SC_TASKLIST, MF_BYCOMMAND);
      DeleteMenu(ASysMenu, 7, MF_BYPOSITION);
      DeleteMenu(ASysMenu, 5, MF_BYPOSITION);
      DeleteMenu(ASysMenu, SC_MAXIMIZE, MF_BYCOMMAND);
      DeleteMenu(ASysMenu, SC_MINIMIZE, MF_BYCOMMAND);
      DeleteMenu(ASysMenu, SC_SIZE, MF_BYCOMMAND);
      DeleteMenu(ASysMenu, SC_RESTORE, MF_BYCOMMAND);
    end
    else
    begin
      if not (biMinimize in BorderIcons) or (WindowState = wsMinimized) then
        EnableMenuItem(ASysMenu, SC_MINIMIZE, MF_BYCOMMAND or MF_GRAYED);
      if not (biMaximize in BorderIcons) or (WindowState = wsMaximized) then
        EnableMenuItem(ASysMenu, SC_MAXIMIZE, MF_BYCOMMAND or MF_GRAYED);
      if WindowState = wsMaximized then
      begin
        EnableMenuItem(ASysMenu, SC_SIZE, MF_BYCOMMAND or MF_GRAYED);
        EnableMenuItem(ASysMenu, SC_MOVE, MF_BYCOMMAND or MF_GRAYED);
        EnableMenuItem(ASysMenu, SC_RESTORE, MF_BYCOMMAND);
      end
      else
        if WindowState = wsNormal then
          EnableMenuItem(ASysMenu, SC_RESTORE, MF_BYCOMMAND or MF_GRAYED);
    end;
    SetMenuDefaultItem(ASysMenu, SC_CLOSE, MF_BYCOMMAND);
  end;
end;

procedure TdxCustomRibbonForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FPrevActiveControl) then
    FPrevActiveControl := nil;
  inherited Notification(AComponent, Operation);
end;

procedure TdxCustomRibbonForm.ShiftControlsVertically(ADelta: Integer);
var
  I: Integer;
  R: TRect;
begin
  if ADelta = 0 then Exit;
  DisableAlign;
  try
    for I := 0 to ControlCount - 1 do
      with Controls[I] do
        if Align in [alNone, alCustom] then
        begin
          if akBottom in Anchors then
          begin
            if akTop in Anchors then
            begin
              R := BoundsRect;
              Inc(R.Top, ADelta);
              BoundsRect := R;
            end;
          end
          else
            Top := Top + ADelta;
        end;
  finally
    EnableAlign;
  end;
end;

procedure TdxCustomRibbonForm.UpdateNonClientArea;
begin
  UpdateWindowStates;
  if UseSkin and IsWindowVisible(Handle) then
  begin
    DrawNonClientArea(False);
    RibbonNonClientHelper.UpdateNonClientArea;
  end;
end;

procedure TdxCustomRibbonForm.UpdateWindowStates;
var
  R: TRect;
begin
  if UseSkin and not (csDestroying in ComponentState) then
  begin
    FillChar(FData, SizeOf(TdxRibbonFormData), 0);
    if HandleAllocated then
    begin
      FData.Handle := Handle;
      R := cxGetWindowRect(Self);
      OffsetRect(R, -R.Left, -R.Top);
      FData.Bounds := R;
      if IsIconic(Handle) then
        FData.State := wsMinimized
      else if IsZoomed(Handle) then
        FData.State := wsMaximized
      else
        FData.State := wsNormal;
    end;
    FData.Active := FIsActive;
    FData.Border := BorderStyle;
    FData.Style  := FormStyle;
    FData.DontUseAero := DisableAero or (ParentWindow <> 0);
    RibbonNonClientHelper.CheckWindowStates(FData);
  end;
end;

procedure TdxCustomRibbonForm.CalculateCornerRegions;

  procedure CalculateRegion(ACornerRgn: HRGN; DX, DY: Integer; const ACornerRect: TRect);
  var
    R1, R2: HRGN;
  begin
    R1 := CreateRectRgnIndirect(cxEmptyRect);
    GetWindowRgn(Handle, ACornerRgn);
    GetWindowRgn(Handle, R1);
    OffsetRgn(R1, DX, DY);
    CombineRgn(ACornerRgn, ACornerRgn, R1, RGN_DIFF);
    R2 := CreateRectRgnIndirect(ACornerRect);
    CombineRgn(ACornerRgn, ACornerRgn, R2, RGN_AND);
    DeleteObject(R1);
    DeleteObject(R2);
  end;

var
  H: Integer;
begin
  H := GetSystemMetrics(SM_CYCAPTION);
  CalculateRegion(FCornerRegions[0],  FSizingBorders.cx,  FSizingBorders.cy,
    cxRect(0, 0, H, H));
  CalculateRegion(FCornerRegions[1], -FSizingBorders.cx,  FSizingBorders.cy,
    cxRect(Width - H, 0, Width, H));
  CalculateRegion(FCornerRegions[2], -FSizingBorders.cx, -FSizingBorders.cy,
    cxRect(Width - H, Height - H, Width, Height));
  CalculateRegion(FCornerRegions[3],  FSizingBorders.cx, -FSizingBorders.cy,
    cxRect(0, Height - H, H, Height));
end;

procedure TdxCustomRibbonForm.CalculateZoomedOffsets;
var
  ABData: TAppBarData;
begin
  FZoomedBoundsOffsets := cxEmptyRect;
  if IsNeedCorrectForAutoHideTaskBar then
  begin
    FillChar(ABData, sizeof(ABData), 0);
    ABData.cbSize := sizeof(ABData);
    ABData.hWnd := Handle;
    SHAppBarMessage(ABM_GETTASKBARPOS, ABData);
    if ABData.uEdge = ABE_LEFT then
      FZoomedBoundsOffsets.Left := 1
    else if (ABData.uEdge = ABE_TOP) and not IsUseAeroNCPaint then
      FZoomedBoundsOffsets.Top := 1
    else if ABData.uEdge = ABE_RIGHT then
      FZoomedBoundsOffsets.Right := 1 + Ord(IsUseAeroNCPaint)
    else if ABData.uEdge = ABE_BOTTOM then
      FZoomedBoundsOffsets.Bottom := 1;
  end;
end;

procedure TdxCustomRibbonForm.CheckExtendFrame(AZoomed: Boolean);
var
  ANonClientHeight: Integer;
begin
  if UseSkin and HandleAllocated and IsUseAeroNCPaint then
  begin
    ANonClientHeight := RibbonNonClientHelper.GetWindowCaptionHeight;
    //prevent client area rendering beyond the screen if maximized
    if AZoomed and (ANonClientHeight > 0) then
      Inc(ANonClientHeight, dxGlassMaximizedNonClientHeight);
    ExtendFrameIntoClientAreaAtTop(ANonClientHeight);
  end;
end;


function TdxCustomRibbonForm.GetUseSkin: Boolean;
begin
  Result := FUseSkin //and (FormStyle <> fsMDIChild);
end;

procedure TdxCustomRibbonForm.InvalidateFrame(AWnd: HWND; AUpdate: Boolean = False);
begin
  SetWindowPos(AWnd, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or
    SWP_NOZORDER or SWP_NOACTIVATE or SWP_DRAWFRAME);
  if AUpdate then
    UpdateWindow(AWnd);
end;

function TdxCustomRibbonForm.IsNeedCorrectForAutoHideTaskBar: Boolean;
var
  ABData : TAppBarData;
begin
  FillChar(ABData, sizeof(ABData), 0);
  ABData.cbSize := sizeof(ABData);
  Result := ((SHAppBarMessage(ABM_GETSTATE, ABData) and ABS_AUTOHIDE) > 0) and
    (MonitorFromWindow(FindWindow('Shell_TrayWnd', nil), MONITOR_DEFAULTTONEAREST) = Monitor.Handle);
end;

function TdxCustomRibbonForm.IsNormalWindowState: Boolean;
begin
  Result := not (IsIconic(Handle) or IsZoomed(Handle));
end;

procedure TdxCustomRibbonForm.SetAutoScroll(const Value: Boolean);
begin
  //don't change
  inherited AutoScroll := False;
end;

procedure TdxCustomRibbonForm.SetDisableAero(const Value: Boolean);
begin
  if FDisableAero <> Value then
  begin
    FDisableAero := Value;
    UpdateGlassFrame;
  end;
end;

procedure TdxCustomRibbonForm.SetPrevActiveControl(AValue: TWinControl);
begin
  if (AValue <> FPrevActiveControl) then
  begin
    if Assigned(FPrevActiveControl) then
      FPrevActiveControl.RemoveFreeNotification(Self);
    FPrevActiveControl := AValue;
    if Assigned(FPrevActiveControl) then
      FPrevActiveControl.FreeNotification(Self);
  end;
end;

{$IFDEF DELPHI10}
procedure TdxCustomRibbonForm.SetRibbonAlwaysOnTop(const Value: Boolean);
begin
  if FRibbonAlwaysOnTop <> Value then
  begin
    FRibbonAlwaysOnTop := Value;
    Realign;
  end;
end;
{$ENDIF}

procedure TdxCustomRibbonForm.SetRibbonNonClientHelper(const Value: TdxRibbonFormCaptionHelper);
var
  ASaveCaption: TCaption;
begin
  if FRibbonNonClientHelper <> Value then
  begin
    ASaveCaption := Caption;
    FRibbonNonClientHelper := Value;
    FUseSkin := (Value <> nil) and (FRibbonNonClientHelper <> nil);
    FExtendFrameAtTopHeight := -1;
    if csDestroying in ComponentState then
      FUseSkin := False
    else
    begin
      UpdateWindowStates;
      if HandleAllocated then
      begin
        if dxWMSetSkinnedMessage > 0 then
          SendMessage(Handle, dxWMSetSkinnedMessage, Integer(FUseSkin), 0);
        DisableAlign;
        SetWindowRgn(Handle, 0, False);
        if IsCompositionEnabled then
        begin
          if not IsWindowVisible(Handle) then //it needs for vista after change window's region
            Application.ProcessMessages;      //for an invisible window
          if not UseSkin then
            ExtendFrameIntoClientAreaAtTop(0);
        end;
        Caption := ASaveCaption;
        SetWindowPos(Handle, 0, 0, 0, Width, Height, SWP_NOMOVE or
          SWP_NOZORDER or SWP_NOACTIVATE or SWP_DRAWFRAME or SWP_FRAMECHANGED);
        FullRedrawWithChildren;
        EnableAlign;
        UpdateSystemMenu;
      end;
      if UseSkin then
        RibbonNonClientHelper.CaptionChanged;
    end;
  end;
end;

procedure TdxCustomRibbonForm.SetUseSkinColor(const Value: Boolean);
begin
  if FUseSkinColor <> Value then
  begin
    FUseSkinColor := Value;
    if HandleAllocated then
      InvalidateRect(Handle, nil, True);
  end;
end;

procedure TdxCustomRibbonForm.ShowSystemMenu(AFromMouse: Boolean);
var
  P: TPoint;
  R: TRect;
begin
  if AFromMouse then
    P := GetMouseCursorPos
  else
  begin
    R := RibbonNonClientHelper.GetWindowSystemMenuBounds;
    P.X := R.Left;
    P.Y := R.Bottom;
    P := ClientToScreen(P);
  end;
  RibbonNonClientHelper.ShowSystemMenu(P);
end;

procedure TdxCustomRibbonForm.UpdateGlassFrame;
begin
  UpdateWindowStates;
  if UseSkin and HandleAllocated and IsCompositionEnabled and IsWindowVisible(Handle) then
  begin
    SetWindowRgn(Handle, 0, False);
    FExtendFrameAtTopHeight := -1;
    ForceUpdateWindowSizeForVista;
    FExtendFrameAtTopHeight := -1;
    FullRedrawWithChildren;
  end;
end;

procedure TdxCustomRibbonForm.UpdateSystemMenu;
begin
  if UseSkin then
  begin
    RibbonNonClientHelper.InitWindowBorderIcons(GetFormBorderIcons);
    GetSystemMenu(Handle, True); //W2k painting bug workaround
  end;
end;

procedure TdxCustomRibbonForm.CMActionUpdate(var Message: TMessage);

  function UpdateControlAction(AControl: TControl): Boolean;
  begin
    Result := (AControl <> nil) and
      AControl.UpdateAction(TBasicAction(Message.LParam));
  end;

  function ProcessChildren(AContainer: TWinControl): Boolean;
  var
    I: Integer;
    AControl: TControl;
  begin
    if AContainer.Showing then
      for I := 0 to AContainer.ControlCount - 1 do
      begin
        AControl := AContainer.Controls[I];
        if AControl.Visible and UpdateControlAction(AControl) or
          (AControl is TWinControl) and ProcessChildren(TWinControl(AControl)) then
        begin
          Result := True;
          Exit;
        end;
      end;
    Result := False;
  end;

begin
  if (csDesigning in ComponentState) or not Showing then Exit;
  if PrevActiveControl is TWinControl then
  begin
    UpdateControlAction(PrevActiveControl);
    Message.Result := 1;
  end
  else
    if UpdateControlAction(ActiveControl) or UpdateControlAction(Self) or ProcessChildren(Self) then
      Message.Result := 1;
end;

procedure TdxCustomRibbonForm.CMActivate(var Message: TCMActivate);
begin
  FNeedCallActivate := True;
  if not FDelayedActivate then
    inherited;
end;

procedure TdxCustomRibbonForm.CMColorChanged(var Message: TMessage);
begin
  if UseSkin then
  begin
    if (FormStyle = fsMDIForm) and (ClientHandle <> 0) then
      Windows.InvalidateRect(ClientHandle, nil, True);
  end;
  inherited;
end;

procedure TdxCustomRibbonForm.CMShowingChanged(var Message: TMessage);

  procedure UpdateRibbonControls(var ARibbon, AStatusBar: TWinControl);
  var
    I: Integer;
  begin
    for I := 0 to ControlCount - 1 do
    begin
      if Controls[I] is TdxCustomRibbon then
        ARibbon := TWinControl(Controls[I])
      else if Controls[I] is TdxCustomStatusBar then
        AStatusBar := TWinControl(Controls[I]);
      if (ARibbon <> nil) and (AStatusBar <> nil) then Break;
    end;
  end;

  procedure CheckHideRibbonControl(var AControl: TWinControl);
  begin
    if (AControl <> nil) and AControl.HandleAllocated and AControl.Visible then
      ShowWindow(AControl.Handle, SW_HIDE)
    else
      AControl := nil;
  end;

  procedure ShowRibbonControl(AControl: TWinControl);
  begin
    if AControl <> nil then
    begin
      ShowWindow(AControl.Handle, SW_SHOWNA);
      UpdateWindow(AControl.Handle);
    end;
  end;

var
  ANeedHideRibbonControls: Boolean;
  ARibbon, AStatusBar: TWinControl;
begin
  ARibbon := nil; //remove warnings
  AStatusBar := nil;
  ANeedHideRibbonControls := Visible and FVisibleChanging;
  FDelayedActivate := ANeedHideRibbonControls;
  FNeedCallActivate := False;
  try
    if ANeedHideRibbonControls then
    begin
      UpdateRibbonControls(ARibbon, AStatusBar);
      CheckHideRibbonControl(ARibbon);
      CheckHideRibbonControl(AStatusBar);
    end;
    inherited;
  finally
    if ANeedHideRibbonControls then
    begin
      ShowRibbonControl(ARibbon);
      ShowRibbonControl(AStatusBar);
    end;
    FDelayedActivate := False;
    if FNeedCallActivate then
      Perform(CM_ACTIVATE, 0, 0);
  end;
end;

procedure TdxCustomRibbonForm.CMVisibleChanged(var Message: TMessage);
var
  Animation: Boolean;
begin
  FVisibleChanging := True;
  try
    if UseSkin and Visible and HandleAllocated and (FormStyle = fsMDIChild) then
    begin
      Animation := GetAnimation;
      if Animation then SetAnimation(False);
      inherited;
      if Animation then SetAnimation(True);
    end
    else
      inherited;
  finally
    FVisibleChanging := False;
  end;
end;

procedure TdxCustomRibbonForm.WMCancelMode(var Message: TWMCancelMode);
begin
  if UseSkin then
    RibbonNonClientHelper.CancelMode;
  inherited;
end;

procedure TdxCustomRibbonForm.WMCaptureChanged(var Message: TMessage);
begin
  if UseSkin and (THandle(Message.LParam) <> Handle) then
  begin
    FSizingLoop := False;
    RibbonNonClientHelper.CancelMode;
  end;
  inherited;
end;

procedure TdxCustomRibbonForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
var
  R: TRect;
begin
  if UseSkin and (IsUseAeroNCPaint or not DoubleBuffered or (TMessage(Message).wParam = TMessage(Message).lParam)) then
  begin
    R := ClientRect;
    //reduce flickering
    if IsUseAeroNCPaint then
      Inc(R.Top, FExtendFrameAtTopHeight);
    if not cxRectIsEmpty(R) then
      FillRectByColor(Message.DC, R, GetBackgroundColor);
  end
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMInitMenu(var Message: TWMInitMenu);
begin
  Message.Menu := GetSystemMenu(Handle, False);
  inherited;
  ModifySystemMenu(Message.Menu);
end;

procedure TdxCustomRibbonForm.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if HandleWithHelper(True, mbLeft) then
    UpdateNonClientArea
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMLButtonUp(var Message: TWMLButtonUp);
begin
  if UseSkin then
  begin
    if HandleWithHelper(False, mbLeft) then
      Message.Result := 0
    else
    begin
      RibbonNonClientHelper.CancelMode;
      inherited;
    end;
  end
  else inherited
end;

procedure TdxCustomRibbonForm.WMQueryOpen(var Message: TWMQueryOpen);
begin
  GetSystemMenu(Handle, True);
  inherited;
end;

procedure TdxCustomRibbonForm.WMRButtonDown(var Message: TWMRButtonDown);
begin
  if HandleWithHelper(True, mbRight) then
    Message.Result := 0
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMRButtonUp(var Message: TWMRButtonUp);
begin
  if HandleWithHelper(False, mbRight) then
    Message.Result := 0
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMNCRButtonUp(var Message: TWMNCRButtonUp);
begin
  if HandleWithHelper(False, mbRight) then
    Message.Result := 0
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMNCActivate(var Message: TWMNCActivate);
var
  AFlags: Cardinal;
begin
  FIsActive := Message.Active;
  if UseSkin then
  begin
    UpdateWindowStates;
    if (FormStyle = fsMDIChild) or IsUseAeroNCPaint then // AB15017 only on XP
    begin                                                // Aero required to call a default method
      AFlags := GetWindowLong(Handle, GWL_STYLE);
      SetWindowLong(Handle, GWL_STYLE, AFlags and not WS_VISIBLE);
      Message.Result := DefWindowProc(Handle, WM_NCACTIVATE, TMessage(Message).WParam, 0);
      SetWindowLong(Handle, GWL_STYLE, AFlags);
    end
    else
      Message.Result := 1; //B20794
    if not (csDestroying in ComponentState) then
    begin
      if not FIsActive then
        RibbonNonClientHelper.CancelMode;
      UpdateNonClientArea
    end;
    if (FormStyle = fsMDIForm) and (ActiveMDIChild <> nil) then
      ActiveMDIChild.Perform(WM_NCACTIVATE, Ord(IsActive), 0);
  end
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMNCCalcSize(var Message: TWMNCCalcSize);
var
  R, SaveR0: TRect;
  T: Integer;
  AIsZoomed: Boolean;
begin
  if not (UseSkin and Visible and not IsIconic(Handle) and not (csReading in ComponentState)) then
    inherited
  else
  begin
    if Message.CalcValidRects then
    begin
      AIsZoomed := IsZoomed(Handle);
      if IsUseAeroNCPaint then
      begin
        T := Message.CalcSize_Params^.rgrc[0].Top;
        if AIsZoomed and GetWindowRect(Handle, R) and not cxRectIsEqual(R, Message.CalcSize_Params^.rgrc[0]) then
          Realign;
        inherited;
        SaveR0 := Message.CalcSize_Params^.rgrc[0];
        SaveR0.Top := T;
      end
      else
      begin
        R := GetCurrentBordersWidth;
        SaveR0 := Message.CalcSize_Params^.rgrc[0];
        with Message.CalcSize_Params^.rgrc[0] do
        begin
          Inc(SaveR0.Top, R.Top);
          Dec(SaveR0.Bottom, R.Bottom);
          Inc(SaveR0.Left, R.Left);
          Dec(SaveR0.Right, R.Right);
        end;
      end;
      if AIsZoomed then
      begin
        if FormStyle = fsMDIChild then
         Inc(SaveR0.Top, GetDefaultWindowNCSize(Handle).Top - RibbonNonClientHelper.GetWindowCaptionHeight)
        else
        begin
          CalculateZoomedOffsets; //check for Taskbar autohide
          CorrectZoomedBounds(SaveR0);
        end;
      end;
      Message.CalcSize_Params^.rgrc[0] := SaveR0;
    end
    else
      inherited;
    Message.Result := 0;
  end;
end;

procedure TdxCustomRibbonForm.WMNCHitTest(var Message: TWMNCHitTest);
var
  R: TRect;
  P: TPoint;
begin
  if UseSkin then
  begin
    Message.Result := HTNOWHERE;
    if IsUseAeroNCPaint then
    begin
      CallDWMWindowProc(Message);
      if Message.Result = HTNOWHERE then
        inherited;
      if not ((Message.Result = HTCAPTION) or (Message.Result = HTCLIENT)) then
        Exit;
      Message.Result := HTNOWHERE;
    end;
    R := cxGetWindowRect(Handle);
    P := cxPoint(Message.XPos - R.Left, Message.YPos - R.Top);
    if (BorderStyle in [bsSizeable, bsSizeToolWin]) then
      CheckResizingNCHitTest(Message.Result, P);
    if (Message.Result = HTNOWHERE) and RibbonNonClientHelper.IsInCaptionArea(Message.XPos, Message.YPos) then
      RibbonNonClientHelper.GetWindowCaptionHitTest(Message);
    if Message.Result = HTNOWHERE then
      Message.Result := HTCLIENT;
  end
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMShowWindow(var Message: TMessage);
begin
  inherited;
  if WordBool(Message.WParam) and UseSkin and IsNormalWindowState then
  begin
    //for a showing MDIChild on vista without DWM
    //make sure for WM_SIZE & WM_NCCALCSIZE
    SetWindowPos(Handle, 0, 0, 0, Width, Height, SWP_NOZORDER or SWP_NOACTIVATE or
      SWP_NOMOVE or SWP_FRAMECHANGED);

    RibbonNonClientHelper.InitWindowBorderIcons(GetFormBorderIcons);
    CaptionChanged;
  end;
end;

procedure TdxCustomRibbonForm.WMNCPaint(var Message: TMessage);
begin
  if UseSkin then
  begin
    if IsUseAeroNCPaint then
      inherited;
    DrawNonClientArea(False, Message.WParam);
    Message.Result := 0;
  end
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMPaint(var Message: TWMPaint);
begin
  if UseSkin then
  begin
    UpdateWindowStates;
    if IsUseAeroNCPaint then
      ExcludeRibbonPaintArea(Message.DC);
    inherited;
  end
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMSize(var Message: TWMSize);
var
  R: TRect;
begin
  inherited;
  if UseSkin and not (csReading in ComponentState) then
  begin
    UpdateWindowStates;
    RibbonNonClientHelper.Resize;
    FSizingBorders.cx := GetSystemMetrics(SM_CXSIZEFRAME);
    FSizingBorders.cy := GetSystemMetrics(SM_CYSIZEFRAME);
    if IsUseAeroNCPaint then
    begin
      if Message.SizeType = SIZE_MAXIMIZED then
        SetWindowRgn(Handle, 0, False);
      CheckExtendFrame(Message.SizeType = SIZE_MAXIMIZED);
    end
    else
    begin
      if Message.SizeType = SIZE_MAXIMIZED then
      begin
        //clip borders
        R := cxGetWindowRect(Handle);
        OffsetRect(R, -R.Left, -R.Top);
        with GetDefaultWindowBordersWidth(Handle) do
          R := cxRectInflate(R, -Left, -Top, -Right, -Bottom);
        SetWindowRgn(Handle, CreateRectRgnIndirect(R), True);
      end
      else
      begin
        SetWindowRgn(Handle, RibbonNonClientHelper.GetWindowRegion, True);
        CalculateCornerRegions;
      end;
    end;
  end;
end;

procedure TdxCustomRibbonForm.WMSysCommand(var Message: TWMSysCommand);
var
  ACommand: Word;
  Animation: Boolean;
begin
  if UseSkin then
  begin
    ACommand := Message.CmdType and $FFF0;
    if (ACommand = SC_KEYMENU) and (Message.Key = $20) then
    begin
      ShowSystemMenu(False);
      Message.Result := 0;
    end
    else
    begin
      if (FormStyle = fsMDIChild) and ((ACommand = SC_MAXIMIZE) or
        (ACommand = SC_MINIMIZE) or (ACommand = SC_RESTORE))then
      begin
        Animation := GetAnimation;
        if Animation then SetAnimation(False);
        inherited;
        if Animation then SetAnimation(True);
      end
      else
        inherited;
      case ACommand of
        SC_MAXIMIZE, SC_RESTORE:
          UpdateNonClientArea;
        else
          UpdateWindowStates;
      end;
    end;
  end
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  UpdateWindowStates;
  inherited;
end;

procedure TdxCustomRibbonForm.WMDWMCompositionChanged(var Message: TMessage);
begin
  inherited;
  if UseSkin then
  begin
    UpdateGlassFrame;
    Message.Result := 0;
  end;
end;

procedure TdxCustomRibbonForm.WndProc(var Message: TMessage);
begin
  if not UseSkin then
    inherited WndProc(Message)
  else
    with Message do
    begin
      case Msg of
        WM_SYSMENU:
          begin
            ShowSystemMenu(True);
            Result := 0;
          end;
        WM_ENTERSIZEMOVE:
          begin
            FSizingLoop := True;
            inherited WndProc(Message);
          end;
        WM_EXITSIZEMOVE:
          begin
            FSizingLoop := False;
            inherited WndProc(Message);
            UpdateNonClientArea;
          end;
        WM_NCUAHDRAWCAPTION,
        WM_NCUAHDRAWFRAME:
          begin
            if IsUseAeroNCPaint then
              CallDWMWindowProc(Message);
            DrawNonClientArea(True);
            Message.Result := 0;
          end;
        WM_MOUSEACTIVATE, WM_SYNCPAINT:
          begin
            inherited WndProc(Message);
            DrawNonClientArea(True);
          end;
        WM_NCLBUTTONDOWN:
          begin
            if not IsUseAeroNCPaint then
              UpdateWindow(Handle);
            inherited WndProc(Message);
            if IsIconic(Handle) then
            begin
              DrawNonClientArea(True);
              Result := 0;
            end;
          end;
        WM_NCMOUSELEAVE:
          begin
            if IsUseAeroNCPaint then
              CallDWMWindowProc(Message)
            else
              inherited;
          end;
        WM_LBUTTONDOWN:
          begin
            //dmAutomatic suppress a dispatching
            if (DragMode = dmAutomatic) and not IsUseAeroNCPaint then
              if HandleWithHelper(True, mbLeft) then
                Exit;
            inherited;
          end;
      else
        if (dxWMGetSkinnedMessage <> 0) and (Msg = dxWMGetSkinnedMessage) then
        begin
          Result := Ord(UseSkin);
          Exit;
        end;
        inherited;
      end;
    end;
end;

function TdxCustomRibbonForm.IsUseAeroNCPaint: Boolean;
begin
  Result := UseAeroNCPaint(FData);
end;

procedure TdxCustomRibbonForm.CheckResizingNCHitTest(var AHitTest: Integer; const P: TPoint);
const
  CornerHitTests: array[0..3] of DWORD = (HTTOPLEFT, HTTOPRIGHT, HTBOTTOMRIGHT, HTBOTTOMLEFT);
var
  I: Integer;
  R, RW: TRect;
begin
  if not IsNormalWindowState then Exit;
  for I := 0 to 3 do
    if PtInRegion(FCornerRegions[I], P.X, P.Y) then
    begin
      AHitTest := CornerHitTests[I];
      Break;
    end;
  if AHitTest = HTNOWHERE then
  begin
    RW := cxGetWindowRect(Handle);
    OffsetRect(RW, -RW.Left, -RW.Top);
    R := RW;
    R.Bottom := R.Top + FSizingBorders.cy;
    if cxRectPtIn(R, P) then
      AHitTest := HTTOP
    else
      if not IsUseAeroNCPaint then
      begin
        R := RW;
        R.Left := R.Right - FSizingBorders.cx;
        if cxRectPtIn(R, P) then
          AHitTest := HTRIGHT
        else
        begin
          R := RW;
          R.Top := R.Bottom - FSizingBorders.cy;
          if cxRectPtIn(R, P) then
            AHitTest := HTBOTTOM
          else
          begin
            R := RW;
            R.Right := R.Left + FSizingBorders.cx;
            if cxRectPtIn(R, P) then
              AHitTest := HTLEFT;
          end;
        end;
      end;
  end;
end;

procedure TdxCustomRibbonForm.CreateCornerRegions;
var
  I: Integer;
begin
  for I := 0 to 3 do
    FCornerRegions[I] := CreateRectRgnIndirect(cxEmptyRect);
end;

procedure TdxCustomRibbonForm.DestroyCornerRegions;
var
  I: Integer;
begin
  for I := 0 to 3 do
    DeleteObject(FCornerRegions[I]);
end;

procedure TdxCustomRibbonForm.ExcludeRibbonPaintArea(DC: HDC);
var
  R, CR: HRGN;
  ARibbonRect: TRect;
begin
  if FExtendFrameAtTopHeight = 0 then Exit;
  R := GetClipRegion(DC);
  ARibbonRect := cxRect(0, 0, ClientWidth, FExtendFrameAtTopHeight);
  CR := CreateRectRgnIndirect(ARibbonRect);
  SelectClipRgn(DC, CR);
  FillRect(DC, ARibbonRect, GetStockObject(BLACK_BRUSH));
  CombineRgn(R, R, CR, RGN_DIFF);
  SelectClipRgn(DC, R);
  DeleteObject(R);
  DeleteObject(CR);
end;

procedure TdxCustomRibbonForm.ForceUpdateWindowSizeForVista;
const
  Flags = SWP_NOMOVE or SWP_NOZORDER or SWP_NOOWNERZORDER;
var
  WP: Cardinal;
begin
  if UseSkin and IsUseAeroNCPaint then
  begin
    WP := BeginDeferWindowPos(2);
    try
      DeferWindowPos(WP, Handle, 0, 0, 0, Width - 1, Height - 1, Flags);
      DeferWindowPos(WP, Handle, 0, 0, 0, Width + 1, Height + 1, Flags);
    finally
      EndDeferWindowPos(WP);
    end;
  end;
end;

procedure TdxCustomRibbonForm.FullRedrawWithChildren;
begin
  if IsWindowVisible(Handle) then
    RedrawWindow(Handle, nil, 0, dxFullRedrawFlags);
end;

procedure TdxCustomRibbonForm.ExtendFrameIntoClientAreaAtTop(AHeight: Integer);
var
  M: TdxMargins;
  DC: HDC;
  R: TRect;
begin
  if FExtendFrameAtTopHeight <> AHeight then
  begin
    if AHeight > FExtendFrameAtTopHeight then
    begin
      R := cxRect(0, FExtendFrameAtTopHeight, Width, AHeight);
      if not FVisibleChanging then
        Inc(R.Left, 100);
      if not cxRectIsEmpty(R) then
      begin
        DC := GetWindowDC(Handle);
        FillRect(DC, R, GetStockObject(BLACK_BRUSH));
        ReleaseDC(Handle, DC);
      end;
    end;
    FExtendFrameAtTopHeight := AHeight;
    M.cxLeftWidth := 0;
    M.cxRightWidth := 0;
    M.cyBottomHeight := 0;
    M.cyTopHeight := AHeight;
    DwmExtendFrameIntoClientArea(Handle, @M);
  end;
end;

function TdxCustomRibbonForm.GetFormBorderIcons: TBorderIcons;
var
  ABorderStyle: TFormBorderStyle;
begin
  ABorderStyle := BorderStyle;
  if (FormStyle = fsMDIChild) and (ABorderStyle in [bsNone, bsDialog]) then
    ABorderStyle := bsSizeable;
  Result := BorderIcons;
  case ABorderStyle of
    bsNone: Result := [];
    bsDialog: Result := (Result * [biSystemMenu, biHelp]) - [biMaximize];
    bsToolWindow,
    bsSizeToolWin: Result := Result * [biSystemMenu];
  end;
end;

procedure TdxCustomRibbonForm.CorrectZoomedBounds(var R: TRect);
begin
  Inc(R.Left, FZoomedBoundsOffsets.Left);
  Inc(R.Top, FZoomedBoundsOffsets.Top);
  Dec(R.Right, FZoomedBoundsOffsets.Right);
  Dec(R.Bottom, FZoomedBoundsOffsets.Bottom);
end;

function TdxCustomRibbonForm.GetCurrentBordersWidth: TRect;
begin
  if IsZoomed(Handle) then
  begin
    Result := GetDefaultWindowBordersWidth(Handle);
    if FormStyle = fsMDIChild then
      Result.Top := 0;
  end
  else
    Result := RibbonNonClientHelper.GetWindowBordersWidth;
end;

function TdxCustomRibbonForm.GetBackgroundColor: TColor;
begin
  if UseSkin and UseSkinColor then
    Result := RibbonNonClientHelper.GetWindowColor
  else
    Result := Color;
end;

procedure TdxCustomRibbonForm.WMGetText(var Message: TWMGetText);
var
  L: Integer;
begin
  if (csLoading in ComponentState) or UseSkin then
  begin
    L := Length(FCaption) + 1; //include the terminating null character
    if Message.TextMax < L then
      L := Message.TextMax;
    if L > 1 then
      Move(Pointer(FCaption)^, Pointer(Message.Text)^, L * SizeOf(Char));
    Message.Result := L - 1;
  end
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMGetTextLength(var Message: TWMGetTextLength);
begin
  if (csLoading in ComponentState) or UseSkin then
    Message.Result := Length(FCaption)
  else
    inherited;
end;

procedure TdxCustomRibbonForm.WMSetText(var Message: TWMSetText);

  function IsMaximizedChildForRibbonForm: Boolean;
  var
    AForm: TdxCustomRibbonForm;
  begin
    Result := False;
    if (FormStyle = fsMDIChild) and IsZoomed(Handle) and
      (Application.MainForm is TdxCustomRibbonForm) then
    begin
      AForm := TdxCustomRibbonForm(Application.MainForm);
      Result := AForm.UseSkin;
    end;
  end;

  procedure UpdateMDIForm;
  begin
    if IsMaximizedChildForRibbonForm then
      TdxCustomRibbonForm(Application.MainForm).CaptionChanged;
  end;

begin
  if (csLoading in ComponentState) or UseSkin then
  begin
    FCaption := Message.Text;
    if UseSkin then
    begin
      CaptionChanged;
      UpdateMDIForm;
      Perform(CM_TEXTCHANGED, 0, 0);
      if GetWindowLong(Handle, GWL_EXSTYLE) and WS_EX_APPWINDOW = WS_EX_APPWINDOW then
        SetWindowTextWithoutRedraw(Handle, RibbonNonClientHelper.GetTaskBarCaption);
    end
    else
    begin
      inherited;
      UpdateMDIForm;
    end;
  end
  else
  begin
    if not IsThemeActive and IsMaximizedChildForRibbonForm then
    begin
      Perform(CM_TEXTCHANGED, 0, 0);
      SetWindowTextWithoutRedraw(Handle, Message.Text);
    end
    else
      inherited;
    UpdateMDIForm;
  end;
end;

initialization
  if Win32MajorVersion >= 6 then
    BufferedPaintInit;

finalization
  if Win32MajorVersion >= 6 then
    BufferedPaintUnInit;

end.

