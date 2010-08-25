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

unit dxRibbonFormCaptionHelper;      

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, ExtCtrls, Forms,
  cxClasses, cxGraphics, cxControls, dxRibbonSkins;

type
  TdxTrackedBorderIcon = (tbiNone, tbiSystemMenu, tbiMinimize, tbiMaximize, tbiHelp);
  TdxBorderIconBounds = array[TBorderIcon] of TRect;
  TdxRibbonFormRegion = (rfrWindow, rfrClient, rfrNCHitTest);

  IdxRibbonFormNonClientPainter = interface
  ['{2F024903-3552-4859-961F-F778ED5E1DB6}']
    procedure DrawRibbonFormCaption(ACanvas: TcxCanvas;
      const ABounds: TRect; const ACaption: string; const AData: TdxRibbonFormData);
    procedure DrawRibbonFormBorders(ACanvas: TcxCanvas;
      const AData: TdxRibbonFormData; const ABordersWidth: TRect);
    procedure DrawRibbonFormBorderIcon(ACanvas: TcxCanvas; const ABounds: TRect;
      AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState);
    function GetRibbonApplicationButtonRegion: HRGN;
    function GetRibbonFormCaptionHeight: Integer;
    function GetRibbonFormColor: TColor;
    function GetRibbonLoadedHeight: Integer;
    function GetTaskbarCaption: TCaption;
    function GetWindowBordersWidth: TRect;
    function HasStatusBar: Boolean;
    procedure RibbonFormCaptionChanged;
    procedure RibbonFormResized;
    procedure UpdateNonClientArea;
  end;

  IdxFormKeyPreviewListener = interface
    ['{7192BF84-F80D-4DB0-A53B-06F6703B1A97}']
    procedure FormKeyDown(var Key: Word; Shift: TShiftState);
  end;

  TdxRibbonFormCaptionHelper = class
  private
    FBitmap: TcxBitmap;
    FBorderIcons: TBorderIcons;
    FBorderIconsArea: TRect;
    FFormCaptionDrawBounds: TRect;
    FFormCaptionRegions: array[TdxRibbonFormRegion] of HRGN;
    FHotBorderIcon: TdxTrackedBorderIcon;
    FIsClientDrawing: Boolean;
    FFormData: TdxRibbonFormData;
    FMouseTimer: TTimer;
    FOldWndProc: TWndMethod;
    FOwner: TcxControl;
    FPressedBorderIcon: TdxTrackedBorderIcon;
    FSysMenuBounds: TRect;
    FWasCapture: Boolean;
    IRibbonFormNonClientDraw: IdxRibbonFormNonClientPainter;
    procedure CalculateFormCaption;
    function CanProcessFormCaptionHitTest(X, Y: Integer): Boolean;
    procedure DestroyCaptionRegions;
    procedure DrawBorderIcons(ACanvas: TcxCanvas);
    procedure ExcludeCaptionRgn(DC: HDC);
    function GetBorderIconState(AIcon: TBorderIcon): TdxBorderIconState;
    function GetButtonFromPos(const P: TPoint): TBorderIcon;
    function GetClientRect: TRect;
    function GetClientCaptionBounds: TRect;
    function GetClientCaptionRegion: HRGN;
    function GetFormCaptionDrawBounds: TRect;
    function GetNCHitTestRegion: HRGN;
    function GetDrawIconFromBorderIcon(AIcon: TBorderIcon): TdxBorderDrawIcon;
    function GetForm: TCustomForm;
    function GetFormCaptionRegionsForDC(DC: HDC; ARegionKind: TdxRibbonFormRegion): HRGN;
    function GetHandle: THandle;
    function GetIsValid: Boolean;
    function IsBorderIconMouseEvent(const P: TPoint; out CP: TPoint;
      ACheckComposition: Boolean = True): Boolean;
    procedure RepaintBorderIcons;
    procedure StartMouseTimer;
    procedure StopMouseTimer;
    function TestWinStyle(AStyle : DWORD) : Boolean;
    procedure MouseTimerHandler(Sender: TObject);
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd);
    procedure WMNCHitTest(var Message: TWMNCHitTest);
    procedure WMPaint(var Message: TWMPaint);
    procedure WMSize(var Message: TWMSize);
    procedure WMShowWindow(var Message: TMessage);
  protected
    FBorderIconBounds: TdxBorderIconBounds;
    FSysMenuIconBounds: TRect;
    FTextBounds: TRect;
    procedure CalculateBorderIcons; virtual;
    procedure CalculateSysMenuIconBounds; virtual;
    procedure CalculateTextBounds; virtual;
    procedure BufferedDrawCaption(ADestCanvas: TcxCanvas; const ACaption: TCaption);
    procedure DrawWindowBorderIcon(ACanvas: TcxCanvas; const ABounds: TRect;
      AIcon: TBorderIcon; AState: TdxBorderIconState);
    function GetApplicationButtonRegion: HRGN; virtual;
    function GetWindowCaptionBounds: TRect; virtual;
    function GetWindowCaptionRegion: HRGN; virtual;
    function IsRoundedBottomCorners: Boolean;
    procedure OriginalWndProc(var Message);
    procedure WndProc(var Message: TMessage); virtual;

    property Control: TcxControl read FOwner;
    property Form: TCustomForm read GetForm;

    property FormCaptionDrawBounds: TRect read FFormCaptionDrawBounds;
    property FormData: TdxRibbonFormData read FFormData;
    property Handle: THandle read GetHandle;
    property Valid: Boolean read GetIsValid;
  public
    constructor Create(AOwner: TcxControl);
    destructor Destroy; override;
    procedure Calculate;
    procedure CancelMode;
    procedure CaptionChanged;
    procedure CheckWindowStates(const AFormData: TdxRibbonFormData);
    procedure DrawWindowBorders(ACanvas: TcxCanvas);
    procedure DrawWindowCaption(ACanvas: TcxCanvas; const ACaption: TCaption);
    procedure GetDesignInfo(out ALoadedHeight, ACurrentHeight: Integer);
    function GetTaskbarCaption: TCaption; virtual;
    function GetWindowBordersWidth: TRect; virtual;
    function GetWindowCaptionHeight: Integer; virtual;
    procedure GetWindowCaptionHitTest(var Message: TWMNCHitTest); virtual;
    function GetWindowColor: TColor;
    function GetWindowRegion: HRGN; virtual;
    function GetWindowSystemMenuBounds: TRect; virtual;
    procedure InitWindowBorderIcons(const AIcons: TBorderIcons);
    function IsInCaptionArea(X, Y: Integer): Boolean; virtual;
    function IsTopmostControl(AControl: TControl): Boolean;
    function MouseDown(const P: TPoint; AButton: TMouseButton): Boolean; virtual;
    function MouseUp(const P: TPoint; AButton: TMouseButton): Boolean; virtual;
    procedure Resize;
    procedure ShowSystemMenu(const P: TPoint);
    procedure UpdateCaptionArea(ACanvas: TcxCanvas = nil);
    procedure UpdateNonClientArea;

    property SysMenuIconBounds: TRect read FSysMenuIconBounds;
    property TextBounds: TRect read FTextBounds;
  end;

function GetClipRegion(DC: HDC): HRGN;
function GetDefaultWindowBordersWidth(H: THandle): TRect;
function GetDefaultWindowNCSize(H: THandle): TRect;
function UseAeroNCPaint(const AData: TdxRibbonFormData): Boolean;

implementation

uses
  cxGeometry, Math, cxDWMApi, dxBar;

const
  crClient = True;
  crForm   = False;

  BorderIconsMap: array[TBorderIcon] of TdxTrackedBorderIcon =
    (tbiSystemMenu, tbiMinimize, tbiMaximize, tbiHelp);

  BorderIconOrder: array[TBorderIcon] of TBorderIcon =
    (biSystemMenu, biHelp, biMaximize, biMinimize);

function GetClipRegion(DC: HDC): HRGN;
begin
  Result := CreateRectRgn(0, 0, 0, 0);
  if GetClipRgn(DC, Result) = 0 then
    SetRectRgn(Result, 0, 0, 30000, 30000);
end;

function GetDefaultWindowNCSize(H: THandle): TRect;
var
  SizeParams: TNCCalcSizeParams;
  WP: TWindowPos;
begin
  if IsIconic(H) then
  begin
    Result := cxEmptyRect;
    Exit;
  end;
  SizeParams.rgrc[0] := cxRect(0, 0, 500, 500);
  SizeParams.rgrc[1] := cxNullRect;
  SizeParams.rgrc[2] := cxNullRect;
  SizeParams.lppos := @WP;
  WP.hwnd := H;
  WP.hwndInsertAfter := 0;
  WP.x  := 0;
  WP.y  := 0;
  WP.cx := 0;
  WP.cy := 0;
  WP.flags := SWP_NOACTIVATE or SWP_NOCOPYBITS or SWP_NOMOVE or SWP_NOOWNERZORDER or
    SWP_NOREDRAW or SWP_NOSENDCHANGING or SWP_NOSIZE or SWP_NOZORDER;
  DefWindowProc(H, WM_NCCALCSIZE, 1, Integer(@SizeParams));
  with SizeParams.rgrc[0] do
    Result := cxRect(Left, Top, 500 - Right, 500 - Bottom);
end;

function GetDefaultWindowBordersWidth(H: THandle): TRect;
begin
  Result := GetDefaultWindowNCSize(H);
  if not cxRectIsEqual(Result, cxEmptyRect) then
    Dec(Result.Top, GetSystemMetrics(SM_CYCAPTION));
end;

function UseAeroNCPaint(const AData: TdxRibbonFormData): Boolean;
begin
  Result := not AData.DontUseAero and (AData.Style <> fsMDIChild) and
    (AData.Handle <> 0) and IsCompositionEnabled;
end;

{ TdxRibbonFormCaptionHelper }

constructor TdxRibbonFormCaptionHelper.Create(AOwner: TcxControl);
begin
  inherited Create;
  Supports(TObject(AOwner), IdxRibbonFormNonClientPainter, IRibbonFormNonClientDraw);
  FOwner := AOwner;
  FBitmap := TcxBitmap.Create;
  FOldWndProc := Control.WindowProc;
  Control.WindowProc := WndProc;
end;

destructor TdxRibbonFormCaptionHelper.Destroy;
begin
  StopMouseTimer;
  Control.WindowProc := FOldWndProc;
  DestroyCaptionRegions;
  FBitmap.Free;
  inherited Destroy;
end;

procedure TdxRibbonFormCaptionHelper.Calculate;
begin
  CalculateFormCaption;
  CalculateBorderIcons;
  CalculateSysMenuIconBounds;
  CalculateTextBounds;
end;

procedure TdxRibbonFormCaptionHelper.CancelMode;
begin
  FWasCapture := False;
  if FPressedBorderIcon <> tbiNone then
  begin
    FPressedBorderIcon := tbiNone;
    RepaintBorderIcons;
  end;
end;

procedure TdxRibbonFormCaptionHelper.CaptionChanged;
begin
  IRibbonFormNonClientDraw.RibbonFormCaptionChanged;
end;

procedure TdxRibbonFormCaptionHelper.CheckWindowStates(
  const AFormData: TdxRibbonFormData);
begin
  if not CompareMem(@AFormData, @FFormData, SizeOf(TdxRibbonFormData)) then
  begin
    FFormData := AFormData;
    if FFormData.Handle <> 0 then
      Calculate;
  end;
end;

procedure TdxRibbonFormCaptionHelper.DrawWindowBorderIcon(ACanvas: TcxCanvas;
  const ABounds: TRect; AIcon: TBorderIcon; AState: TdxBorderIconState);
begin
  IRibbonFormNonClientDraw.DrawRibbonFormBorderIcon(ACanvas, ABounds,
    GetDrawIconFromBorderIcon(AIcon), AState);
end;

function TdxRibbonFormCaptionHelper.GetTaskbarCaption: TCaption;
begin
  Result := IRibbonFormNonClientDraw.GetTaskbarCaption;
end;

function TdxRibbonFormCaptionHelper.GetWindowBordersWidth: TRect;
begin
  Result := IRibbonFormNonClientDraw.GetWindowBordersWidth;
end;

procedure TdxRibbonFormCaptionHelper.GetWindowCaptionHitTest(var Message: TWMNCHitTest);
var
  I: TBorderIcon;
  P: TPoint;
begin
  Message.Result := HTCAPTION;
  P := Control.ScreenToClient(cxPoint(Message.XPos, Message.YPos));
  if cxRectPtIn(FBorderIconsArea, P) then
  begin
    StartMouseTimer;
    for I := Low(TBorderIcon) to High(TBorderIcon) do
      if (I in FBorderIcons) and cxRectPtIn(FBorderIconBounds[I], P) then
      begin
        if FHotBorderIcon <> BorderIconsMap[I] then
        begin
          FHotBorderIcon := BorderIconsMap[I];
          RepaintBorderIcons;
        end;
        Message.Result := HTNOWHERE;
        Exit;
      end;
  end;
  if cxRectPtIn(FSysMenuBounds, P) then
    Message.Result := HTSYSMENU;
  if FHotBorderIcon <> tbiNone then
  begin
    FHotBorderIcon := tbiNone;
    RepaintBorderIcons;
  end;
end;

function TdxRibbonFormCaptionHelper.GetWindowColor: TColor;
var
  AForm: TCustomForm;
begin
  if IRibbonFormNonClientDraw <> nil then
    Result := IRibbonFormNonClientDraw.GetRibbonFormColor
  else
  begin
    AForm := Form;
    if AForm <> nil then
      Result := AForm.Color
    else
      Result := clBtnFace;
  end;
end;

function TdxRibbonFormCaptionHelper.GetWindowRegion: HRGN;
const
  Radius = 9;
var
  F: TCustomForm;
  R: HRGN;
  RW: TRect;
  AWidth, AHeight: Integer;
begin
  Result := 0;
  F := Form;
  if (F = nil) or not F.HandleAllocated or not GetWindowRect(F.Handle, RW) then Exit;
  AWidth  := RW.Right  - RW.Left;
  AHeight := RW.Bottom - RW.Top;
  if not IsRoundedBottomCorners then
  begin
    Result := CreateRoundRectRgn(0, 0, AWidth + 1, Radius * 2, Radius, Radius);
    R := CreateRectRgn(0, Radius, AWidth + 1, AHeight + 1);
    CombineRgn(Result, Result, R, RGN_OR);
    DeleteObject(R);
  end
  else
    Result := CreateRoundRectRgn(0, 0, AWidth + 1, AHeight + 1, Radius, Radius);
end;

function TdxRibbonFormCaptionHelper.GetWindowSystemMenuBounds: TRect;
var
  R: TRect;
  H: Integer;
begin
  R := GetDefaultWindowBordersWidth(FormData.Handle);
  if UseAeroNCPaint(FormData) then
  begin
    H := GetSystemMetrics(SM_CYCAPTION);
    Result := cxRectBounds(0, R.Top, H, H);
  end
  else
    Result := cxRect(0, R.Top, GetSystemMetrics(SM_CYSIZE) + 2, GetWindowCaptionHeight - 2);
end;

procedure TdxRibbonFormCaptionHelper.InitWindowBorderIcons(
  const AIcons: TBorderIcons);
begin
  FBorderIcons := AIcons;
  FHotBorderIcon := tbiNone;
  FPressedBorderIcon := tbiNone;
  Calculate;
end;

function TdxRibbonFormCaptionHelper.IsInCaptionArea(X, Y: Integer): Boolean;
var
  P: TPoint;
begin
  Result := (FFormCaptionRegions[rfrWindow] <> 0) and Valid;
  if Result then
  begin
    if FormData.State = wsMinimized then
      Result := True
    else
    begin
      P := Control.ScreenToClient(cxPoint(X, Y));
      Result := PtInRegion(FFormCaptionRegions[rfrNCHitTest], P.X, P.Y)
    end;
  end;
end;

function TdxRibbonFormCaptionHelper.IsTopmostControl(AControl: TControl): Boolean;
begin
  Result := (AControl <> nil) and (AControl = Control);
end;

procedure TdxRibbonFormCaptionHelper.Resize;
begin
  Calculate;
  IRibbonFormNonClientDraw.RibbonFormResized;
end;

function TdxRibbonFormCaptionHelper.GetApplicationButtonRegion: HRGN;
begin
  if (FormData.Handle <> 0) and (FormData.State <> wsMinimized) then
    Result := IRibbonFormNonClientDraw.GetRibbonApplicationButtonRegion
  else
    Result := 0;
end;

procedure TdxRibbonFormCaptionHelper.BufferedDrawCaption(ADestCanvas: TcxCanvas;
  const ACaption: TCaption);
var
  R1, R2: HRGN;
begin
  ADestCanvas.SaveDC;
  try
    FBitmap.cxCanvas.FillRect(cxRect(0, 0, FBitmap.Width, FBitmap.Height), clBlack);
    IRibbonFormNonClientDraw.DrawRibbonFormCaption(FBitmap.cxCanvas,
      FFormCaptionDrawBounds, ACaption, FormData);
    DrawBorderIcons(FBitmap.cxCanvas);
    if FormData.State <> wsMinimized then
    begin
      R1 := GetClipRegion(ADestCanvas.Handle);
      R2 := GetFormCaptionRegionsForDC(ADestCanvas.Handle, rfrClient);
      CombineRgn(R2, R2, R1, RGN_AND);
      SelectClipRgn(ADestCanvas.Handle, R2);
      DeleteObject(R1);
      DeleteObject(R2);
    end;
    BitBlt(ADestCanvas.Handle, 0, 0, Control.Width, Control.Height,
      FBitmap.cxCanvas.Handle, 0, 0, SRCCOPY);
  finally
    ADestCanvas.RestoreDC;
  end;
end;

procedure TdxRibbonFormCaptionHelper.DrawWindowBorders(ACanvas: TcxCanvas);
begin
  IRibbonFormNonClientDraw.DrawRibbonFormBorders(ACanvas, FormData, GetWindowBordersWidth);
end;

procedure TdxRibbonFormCaptionHelper.DrawWindowCaption(ACanvas: TcxCanvas;
  const ACaption: TCaption);
var
  ASaveIndex: Integer;
begin
  if Valid then
  begin
    if FIsClientDrawing or UseAeroNCPaint(FormData) then
    begin
      ASaveIndex := SaveDC(Control.Canvas.Handle);
      SelectClipRgn(Control.Canvas.Handle, FFormCaptionRegions[rfrClient]);
      IRibbonFormNonClientDraw.DrawRibbonFormCaption(Control.Canvas,
        FFormCaptionDrawBounds, ACaption, FormData);
      DrawBorderIcons(Control.Canvas);
      RestoreDC(Control.Canvas.Handle, ASaveIndex);
      ExcludeCaptionRgn(Control.Canvas.Handle);
    end
    else
      if FormData.State = wsMinimized then
        BufferedDrawCaption(ACanvas, ACaption)
      else
      begin
        BufferedDrawCaption(Control.ActiveCanvas, ACaption);
        ExcludeCaptionRgn(Control.ActiveCanvas.Handle);
      end;
  end;
end;

procedure TdxRibbonFormCaptionHelper.GetDesignInfo(out ALoadedHeight, ACurrentHeight: Integer);
begin
  ALoadedHeight := IRibbonFormNonClientDraw.GetRibbonLoadedHeight;
  ACurrentHeight := Control.Height;
end;

procedure TdxRibbonFormCaptionHelper.CalculateBorderIcons;
var
  R: TRect;
  I, AIcon: TBorderIcon;
  H: Integer;
  AIconSize: TSize;
begin
  if UseAeroNCPaint(FormData) then
  begin
    if FormData.Handle <> 0 then
      DwmGetWindowAttribute(FormData.Handle, DWMWA_CAPTION_BUTTON_BOUNDS, @FBorderIconsArea, SizeOf(R));
    Exit;
  end;
  if (FormData.Handle <> 0) and not (FormData.Border in [bsToolWindow, bsSizeToolWin]) then
    AIconSize := cxSize(GetSystemMetrics(SM_CXSIZE), GetSystemMetrics(SM_CYSIZE))
  else
    AIconSize := cxSize(GetSystemMetrics(SM_CXSMSIZE), GetSystemMetrics(SM_CYSMSIZE));
  H := GetWindowCaptionHeight - AIconSize.cy;
  R := GetClientRect;
  R.Top := H - (H div 2);
  R.Bottom := R.Top + AIconSize.cy;
  R.Left := R.Right - AIconSize.cx;
  if (FormData.Handle <> 0) and (FormData.State = wsMinimized) then
    Dec(R.Bottom);
  FBorderIconsArea := R;
  for I := Low(TBorderIcon) to High(TBorderIcon) do
  begin
    AIcon := BorderIconOrder[I];
    if AIcon in FBorderIcons then
    begin
      FBorderIconBounds[AIcon] := R;
      FBorderIconsArea.Left := R.Left;
      OffsetRect(R, -AIconSize.cx, 0);
    end
    else
      FBorderIconBounds[AIcon] := cxEmptyRect;
  end;
end;

procedure TdxRibbonFormCaptionHelper.CalculateFormCaption;
begin
  DestroyCaptionRegions;
  FFormCaptionRegions[rfrWindow] := GetWindowCaptionRegion;
  FFormCaptionRegions[rfrClient] := GetClientCaptionRegion;
  FFormCaptionRegions[rfrNCHitTest] := GetNCHitTestRegion;
  FFormCaptionDrawBounds := GetFormCaptionDrawBounds;

  if Abs(cxRectWidth(FFormCaptionDrawBounds)) > 10000 then
  begin
    FFormCaptionDrawBounds.Left := 0;
    FFormCaptionDrawBounds := GetFormCaptionDrawBounds;
  end;

{$IFDEF DELPHI10}
  FBitmap.SetSize(cxRectWidth(FFormCaptionDrawBounds), GetWindowCaptionHeight);
{$ELSE}
  FBitmap.Width := cxRectWidth(FFormCaptionDrawBounds);
  FBitmap.Height := GetWindowCaptionHeight;
{$ENDIF}
end;

function TdxRibbonFormCaptionHelper.CanProcessFormCaptionHitTest(X, Y: Integer): Boolean;
var
  P: TPoint;
begin
  Result := (FFormCaptionRegions[rfrNCHitTest] <> 0) and (GetCapture = 0);
  if Result then
  begin
    P := Control.ScreenToClient(Point(X, Y));
    Result := PtInRegion(FFormCaptionRegions[rfrNCHitTest], P.X, P.Y);
  end;
end;

procedure TdxRibbonFormCaptionHelper.CalculateSysMenuIconBounds;
var
  AHasSysMenu: Boolean;
  R: TRect;
  H: Integer;
begin
  FSysMenuBounds := cxEmptyRect;
  FSysMenuIconBounds := cxEmptyRect;
  AHasSysMenu := TestWinStyle(WS_SYSMENU) and (FormData.Border in [bsSingle, bsSizeable]);
  if AHasSysMenu then
  begin
    FSysMenuBounds := GetWindowSystemMenuBounds;
    if UseAeroNCPaint(FormData) then
    begin
      H := (FSysMenuBounds.Bottom - FSysMenuBounds.Top - 3) and $FE;
      FSysMenuIconBounds := cxRectBounds(FSysMenuBounds.Left, FSysMenuBounds.Top, H, H);
    end
    else
    begin
      R := GetDefaultWindowBordersWidth(FormData.Handle);
      H := GetSystemMetrics(SM_CYSMICON);
      FSysMenuIconBounds := cxRectBounds(0, R.Top, H, H);
      OffsetRect(FSysMenuIconBounds, 0, (cxRectHeight(FSysMenuBounds) - H) div 2);
      if FormData.State = wsMinimized then
        OffsetRect(FSysMenuIconBounds, 4, 2);
    end;
  end;
end;

procedure TdxRibbonFormCaptionHelper.CalculateTextBounds;
begin
  FTextBounds := GetClientRect;
  Inc(FTextBounds.Top);
  FTextBounds.Left := FSysMenuIconBounds.Right;
  FTextBounds.Bottom := GetWindowCaptionHeight;
  if FBorderIcons <> [] then
    FTextBounds.Right := FBorderIconsArea.Left;
end;

procedure TdxRibbonFormCaptionHelper.DrawBorderIcons(ACanvas: TcxCanvas);
var
  I: TBorderIcon;
  R: TRect;
begin
  if UseAeroNCPaint(FormData) then Exit;
  for I := Low(TBorderIcon) to High(TBorderIcon) do
  begin
    if I in FBorderIcons then
    begin
      R := FBorderIconBounds[I];
      DrawWindowBorderIcon(ACanvas, R, I, GetBorderIconState(I));
    end;
  end;
end;

procedure TdxRibbonFormCaptionHelper.ExcludeCaptionRgn(DC: HDC);
var
  R1, R2: HRGN;
begin
  if FFormCaptionRegions[rfrClient] = 0 then Exit;
  R1 := GetClipRegion(DC);
  R2 := GetFormCaptionRegionsForDC(DC, rfrClient);
  CombineRgn(R1, R1, R2, RGN_DIFF);
  SelectClipRgn(DC, R1);
  DeleteObject(R1);
  DeleteObject(R2);
end;

function TdxRibbonFormCaptionHelper.GetBorderIconState(
  AIcon: TBorderIcon): TdxBorderIconState;
begin
  if not FormData.Active then
  begin
    if BorderIconsMap[AIcon] = FHotBorderIcon then
      Result := bisHotInactive
    else
      Result := bisInactive;
  end
  else
  begin
    if FPressedBorderIcon <> tbiNone then
    begin
      if (BorderIconsMap[AIcon] = FPressedBorderIcon) and (FPressedBorderIcon = FHotBorderIcon) then
        Result := bisPressed
      else
        Result := bisNormal;
    end
    else if BorderIconsMap[AIcon] = FHotBorderIcon then
      Result := bisHot
    else
      Result := bisNormal;
  end;
end;

function TdxRibbonFormCaptionHelper.GetButtonFromPos(
  const P: TPoint): TBorderIcon;
var
  I, AIcon: TBorderIcon;
begin
  Result := biSystemMenu;
  for I := Low(BorderIconOrder) to High(BorderIconOrder) do
  begin
    AIcon := BorderIconOrder[I];
    if (AIcon in FBorderIcons) and cxRectPtIn(FBorderIconBounds[AIcon], P) then
    begin
      Result := AIcon;
      Exit;
    end;
  end;
end;

function TdxRibbonFormCaptionHelper.GetClientRect: TRect;
var
  R: TRect;
begin
  if FormData.Handle > 0 then
  begin
    if FormData.State = wsMinimized then
    begin
      Result := FormData.Bounds;
      R := GetWindowBordersWidth;
      Dec(Result.Right, R.Left);
    end
    else
      if not Windows.GetClientRect(FormData.Handle, Result) then
        Result := cxNullRect;
  end
  else
    Result := Control.ClientRect;
end;

function TdxRibbonFormCaptionHelper.GetDrawIconFromBorderIcon(
  AIcon: TBorderIcon): TdxBorderDrawIcon;
begin
  case AIcon of
    biMinimize:
      begin
        if FormData.State = wsMinimized then
          Result := bdiRestore
        else
          Result := bdiMinimize;
      end;
    biMaximize:
      begin
        if FormData.State = wsMaximized then
          Result := bdiRestore
        else
          Result := bdiMaximize;
      end;
    biSystemMenu:
      Result := bdiClose;
    else
      Result := bdiHelp;
  end;
end;

function TdxRibbonFormCaptionHelper.GetForm: TCustomForm;
begin
  if Control.Owner is TCustomForm then
    Result := TCustomForm(Control.Owner)
  else
    Result := nil;
end;

function TdxRibbonFormCaptionHelper.GetFormCaptionRegionsForDC(DC: HDC;
  ARegionKind: TdxRibbonFormRegion): HRGN;
var
  AWindowOrg, AViewportOrg: TPoint;
begin
  Result := 0;
  if FFormCaptionRegions[ARegionKind] = 0 then Exit;
  Result := CreateRectRgnIndirect(cxEmptyRect);
  CombineRgn(Result, FFormCaptionRegions[ARegionKind], 0, RGN_COPY);
  GetWindowOrgEx(DC, AWindowOrg);
  GetViewportOrgEx(DC, AViewportOrg);
  OffsetRgn(Result, AViewportOrg.X - AWindowOrg.X, AViewportOrg.Y - AWindowOrg.Y);
end;

function TdxRibbonFormCaptionHelper.GetHandle: THandle;
begin
  Result := FOwner.Handle;
end;

function TdxRibbonFormCaptionHelper.GetIsValid: Boolean;
begin
  Result := FOwner.HandleAllocated and
   (FOwner.ComponentState * [{csDestroying,} csLoading] = []);
end;

function TdxRibbonFormCaptionHelper.IsBorderIconMouseEvent(const P: TPoint;
  out CP: TPoint; ACheckComposition: Boolean = True): Boolean;
begin
  CP := Control.ScreenToClient(P);
  Result := not (ACheckComposition and UseAeroNCPaint(FormData)) and
    cxRectPtIn(FBorderIconsArea, CP);
end;

function TdxRibbonFormCaptionHelper.GetWindowCaptionBounds: TRect;
var
  R: TRect;
begin
  Result := Control.ClientRect;
  if FormData.Handle <> 0 then
  begin
    Result := FormData.Bounds;
    if FormData.State = wsMaximized then
    begin
      R := GetDefaultWindowBordersWidth(FormData.Handle);
      Inc(Result.Left, R.Left);
      Inc(Result.Top, R.Top);
      Dec(Result.Right, R.Right);
    end;
  end;
  Result.Bottom := Result.Top + GetWindowCaptionHeight;
end;

function TdxRibbonFormCaptionHelper.GetWindowCaptionHeight: Integer;
begin
  if (FormData.Handle <> 0) and (FormData.State = wsMinimized) then
    Result := FormData.Bounds.Bottom - FormData.Bounds.Top
  else
    Result := IRibbonFormNonClientDraw.GetRibbonFormCaptionHeight
end;

function TdxRibbonFormCaptionHelper.GetClientCaptionBounds: TRect;
var
  R: TRect;
begin
  if FormData.Handle <> 0 then
  begin
    Result := GetClientRect;
    R := GetWindowBordersWidth;
    Dec(Result.Left, R.Left);
    Dec(Result.Top, R.Top);
    Inc(Result.Right, R.Right);
  end
  else
    Result := Control.ClientRect;
  Result.Bottom := Result.Top + GetWindowCaptionHeight;
end;

function TdxRibbonFormCaptionHelper.GetClientCaptionRegion: HRGN;
var
  RW, B: TRect;
  R: HRGN;
begin
  if FFormCaptionRegions[rfrWindow] = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := CreateRectRgnIndirect(cxEmptyRect);
  CombineRgn(Result, FFormCaptionRegions[rfrWindow], 0, RGN_COPY);
  if (FormData.Handle <> 0) and (FormData.State <> wsMaximized) and GetWindowRect(FormData.Handle, RW) then
  begin
    OffsetRect(RW, -RW.Left, -RW.Top);
    B := GetWindowBordersWidth;
    R := CreateRectRgn(0, 0, B.Left, GetWindowCaptionHeight);
    CombineRgn(Result, Result, R, RGN_DIFF); //exclude left border
    DeleteObject(R);
    R := CreateRectRgn(RW.Right - B.Right, 0, RW.Right, GetWindowCaptionHeight);
    CombineRgn(Result, Result, R, RGN_DIFF); //exclude right border
    DeleteObject(R);
    OffsetRgn(Result, -B.Left, -B.Top);
  end
end;

function TdxRibbonFormCaptionHelper.GetFormCaptionDrawBounds: TRect;
begin
  if (FormData.Handle <> 0) and (FormData.State = wsMinimized) then
  begin
    Result := GetClientRect;
    Inc(Result.Right, GetWindowBordersWidth.Left);
  end
  else
    Result := GetClientCaptionBounds;
end;

function TdxRibbonFormCaptionHelper.GetNCHitTestRegion: HRGN;
var
  R: HRGN;
begin
  if FFormCaptionRegions[rfrClient] = 0 then
  begin
    Result := 0;
    Exit;
  end;
  Result := CreateRectRgnIndirect(cxEmptyRect);
  CombineRgn(Result, FFormCaptionRegions[rfrClient], 0, RGN_COPY);
  R := GetApplicationButtonRegion;
  if R <> 0 then
  begin
    CombineRgn(Result, Result, R, RGN_DIFF);
    DeleteObject(R);
  end;
end;

function TdxRibbonFormCaptionHelper.GetWindowCaptionRegion: HRGN;
var
  RW: TRect;
begin
  if FormData.Handle = 0 then
  begin
    Result := 0;
    Exit;
  end;
  RW := FormData.Bounds;
  RW.Bottom := RW.Top + GetWindowCaptionHeight;
  Result := CreateRectRgnIndirect(RW);
end;

function TdxRibbonFormCaptionHelper.IsRoundedBottomCorners: Boolean;
begin
  Result := not IsRectangularFormBottom(FormData);
end;

procedure TdxRibbonFormCaptionHelper.RepaintBorderIcons;
var
  ACanvas: TcxCanvas;
  DC: HDC;
begin
  if not Valid or UseAeroNCPaint(FormData) then Exit;
  if FormData.State = wsMinimized then
  begin
    DC := GetDCEx(FormData.Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS or DCX_WINDOW or DCX_VALIDATE);
    BarCanvas.BeginPaint(DC);
    BarCanvas.Canvas.Lock;
    try
      BarCanvas.SetClipRegion(TcxRegion.Create(FBorderIconsArea), roSet);
      BufferedDrawCaption(BarCanvas, '');
    finally
      BarCanvas.Canvas.Unlock;
      BarCanvas.EndPaint;
      ReleaseDC(FormData.Handle, DC);
    end;
  end
  else
  begin
    ACanvas := Control.ActiveCanvas;
    ACanvas.Canvas.Lock;
    try
      ACanvas.SaveClipRegion;
      ACanvas.SetClipRegion(TcxRegion.Create(FBorderIconsArea), roSet);
      BufferedDrawCaption(ACanvas, '');
      ACanvas.RestoreClipRegion;
    finally
      ACanvas.Canvas.Unlock;
    end;
  end;
end;

procedure TdxRibbonFormCaptionHelper.StartMouseTimer;
begin
  if FMouseTimer <> nil then Exit;
  FMouseTimer := TTimer.Create(nil);
  FMouseTimer.Interval := 20;
  FMouseTimer.OnTimer := MouseTimerHandler;
end;

procedure TdxRibbonFormCaptionHelper.StopMouseTimer;
begin
  FreeAndNil(FMouseTimer);
end;

function TdxRibbonFormCaptionHelper.TestWinStyle(AStyle : DWORD) : Boolean;
begin
  Result := (FormData.Handle <> 0) and
    ((GetWindowLong(FormData.Handle, GWL_STYLE) and AStyle) <> 0);
end;

function TdxRibbonFormCaptionHelper.MouseDown(const P: TPoint;
  AButton: TMouseButton): Boolean;
var
  CP: TPoint;
begin
  Result := False;
  if not Valid then Exit;
  if (AButton = mbLeft) and IsBorderIconMouseEvent(P, CP) then
  begin
    Result := True;
    FPressedBorderIcon := BorderIconsMap[GetButtonFromPos(CP)];
    RepaintBorderIcons;
    SetCapture(FormData.Handle);
    FWasCapture := True;
  end;
end;

function TdxRibbonFormCaptionHelper.MouseUp(const P: TPoint;
  AButton: TMouseButton): Boolean;
const
  Commands: array[Boolean, Boolean] of Word = (
    (SC_MINIMIZE, SC_RESTORE),
    (SC_MAXIMIZE, SC_RESTORE));
var
  CP: TPoint;
  AIcon: TBorderIcon;
  ACommand: Word;
begin
  Result := False;
  if not Valid then Exit;
  if AButton = mbLeft then
  begin
    if IsBorderIconMouseEvent(P, CP) and (FPressedBorderIcon <> tbiNone) then
    begin
      Result := True;
      AIcon := GetButtonFromPos(CP);
      if BorderIconsMap[AIcon] = FPressedBorderIcon then
      begin
        case AIcon of
          biSystemMenu:
            ACommand := SC_CLOSE;
          biMinimize:
            ACommand := Commands[False, FormData.State = wsMinimized];
          biMaximize:
            ACommand := Commands[True, FormData.State = wsMaximized]
          else
            ACommand := SC_CONTEXTHELP;
        end;
        PostMessage(FormData.Handle, WM_SYSCOMMAND, ACommand, 0);
      end;
      FPressedBorderIcon := tbiNone;
      RepaintBorderIcons;
    end;
    if FWasCapture and (GetCapture = FormData.Handle) then
      ReleaseCapture;
  end
  else if (AButton = mbRight) and not IsBorderIconMouseEvent(P, CP, False) then
  begin
    Result := True;
    ShowSystemMenu(P);
  end;
end;

procedure TdxRibbonFormCaptionHelper.MouseTimerHandler(Sender: TObject);

  function NeedRepaint(const AMousePos: TPoint; H: HWND): Boolean;
  var
    AClientPos: TPoint;
  begin
    AClientPos := AMousePos;
    MapWindowPoint(0, H, AClientPos);
    Result := not cxRectPtIn(FBorderIconsArea, AClientPos);
    if not Result then
    begin
      if FormData.State = wsMinimized then
        Result := WindowFromPoint(AMousePos) <> H
      else
        Result := RealChildWindowFromPoint(H, AClientPos) <> Handle;
    end;
  end;

begin
  if (FormData.Handle <> 0) and Valid then
  begin
    if NeedRepaint(GetMouseCursorPos, FormData.Handle) then
    begin
      FHotBorderIcon := tbiNone;
      StopMouseTimer;
      RepaintBorderIcons;
    end;
  end
  else StopMouseTimer;
end;

procedure TdxRibbonFormCaptionHelper.WMEraseBkgnd(var Message: TWMEraseBkgnd);
var
  ASaveIndex: Integer;
begin
  if Message.DC <> 0 then
  begin
    ASaveIndex := SaveDC(Message.DC);
    ExcludeCaptionRgn(Message.DC);
    inherited;
    RestoreDC(Message.DC, ASaveIndex);
  end
  else
    inherited;
end;

procedure TdxRibbonFormCaptionHelper.WMNCHitTest(var Message: TWMNCHitTest);
begin
  if CanProcessFormCaptionHitTest(Message.XPos, Message.YPos) then
    Message.Result := HTTRANSPARENT
  else
    OriginalWndProc(Message);
end;

procedure TdxRibbonFormCaptionHelper.WMPaint(var Message: TWMPaint);
begin
  FIsClientDrawing := True;
  OriginalWndProc(Message);
  FIsClientDrawing := False;
end;

procedure TdxRibbonFormCaptionHelper.WMSize(var Message: TWMSize);
begin
  Calculate;
  OriginalWndProc(Message);
end;

procedure TdxRibbonFormCaptionHelper.WMShowWindow(var Message: TMessage);
begin
  FHotBorderIcon := tbiNone;
  FPressedBorderIcon := tbiNone;
  if WordBool(Message.wParam) then
    Calculate;
  OriginalWndProc(Message);
end;

procedure TdxRibbonFormCaptionHelper.OriginalWndProc(var Message);
begin
  FOldWndProc(TMessage(Message));
end;

procedure TdxRibbonFormCaptionHelper.ShowSystemMenu(const P: TPoint);
var
  M: HMENU;
  ACommand: LongWord;
begin
  M := GetSystemMenu(FormData.Handle, False);
  ACommand := LongWord(TrackPopupMenu(M, TPM_RETURNCMD or TPM_TOPALIGN or TPM_LEFTALIGN, P.X, P.Y, 0, FormData.Handle, nil));
  PostMessage(FormData.Handle, WM_SYSCOMMAND, ACommand, 0);
end;

procedure TdxRibbonFormCaptionHelper.UpdateCaptionArea(ACanvas: TcxCanvas = nil);
begin
  if ACanvas = nil then
    DrawWindowCaption(nil, '')
  else
    BufferedDrawCaption(ACanvas, '');
end;

procedure TdxRibbonFormCaptionHelper.UpdateNonClientArea;
begin
  IRibbonFormNonClientDraw.UpdateNonClientArea;
end;

procedure TdxRibbonFormCaptionHelper.DestroyCaptionRegions;
var
  I: TdxRibbonFormRegion;
begin
  for I := Low(TdxRibbonFormRegion) to High(TdxRibbonFormRegion) do
    if FFormCaptionRegions[I] <> 0 then
    begin
      DeleteObject(FFormCaptionRegions[I]);
      FFormCaptionRegions[I] := 0;
    end;
end;

procedure TdxRibbonFormCaptionHelper.WndProc(var Message: TMessage);
begin
  if Control.IsDesigning then
    OriginalWndProc(Message)
  else
  begin
    case Message.Msg of
      WM_SIZE:
        WMSize(TWMSize(Message));
      WM_NCHITTEST:
        WMNCHitTest(TWMNCHitTest(Message));
      WM_ERASEBKGND:
        WMEraseBkgnd(TWMEraseBkgnd(Message));
      WM_PAINT:
        WMPaint(TWMPaint(Message));
      WM_SHOWWINDOW:
        WMShowWindow(Message);
      else
        OriginalWndProc(Message);
    end;
  end;
end;

end.
