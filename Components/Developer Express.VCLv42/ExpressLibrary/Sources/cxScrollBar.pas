
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressCommonLibrary                                         }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSCOMMONLIBRARY AND ALL          }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit cxScrollBar;

{$I cxVer.inc}

interface

uses
  Windows, Messages, dxThemeManager,
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
{$IFNDEF DELPHI5}
  cxClasses,
{$ENDIF}
  SysUtils, Classes, Controls, StdCtrls,
  Graphics, cxGraphics, Forms, cxLookAndFeels, cxLookAndFeelPainters;

type
  TcxScrollBar = class;

  TcxScrollBarState = record
    PressedPart: TcxScrollBarPart;
    HotPart: TcxScrollBarPart;
  end;

  { TcxScrollBarViewInfo }

  TcxScrollBarViewInfo = class
  protected
    FBottomRightArrowRect: TRect;
    FPageDownRect: TRect;
    FPageUpRect: TRect;
    FScrollBar: TcxScrollBar;
    FThumbnailRect: TRect;
    FThumbnailSize: Integer;
    FTopLeftArrowRect: TRect;
    procedure CalculateRects; virtual;
    property ScrollBar: TcxScrollBar read FScrollBar;
  public
    constructor Create(AScrollBar: TcxScrollBar); virtual;
    procedure AdjustPageRects;
    procedure Calculate; virtual;
    procedure CalculateMinThumnailSize;
    procedure CalculateThumbnailRect;
    procedure SetThumbnailPos(APos: Integer);
    property BottomRightArrowRect: TRect read FBottomRightArrowRect;
    property PageDownRect: TRect read FPageDownRect;
    property PageUpRect: TRect read FPageUpRect;
    property ThumbnailRect: TRect read FThumbnailRect;
    property ThumbnailSize: Integer read FThumbnailSize;
    property TopLeftArrowRect: TRect read FTopLeftArrowRect;
  end;

  TcxScrollBarViewInfoClass = class of TcxScrollBarViewInfo;

  TcxScrollBar = class(TCustomControl, {$IFNDEF DELPHI6}IUnknown,{$ENDIF} IdxSkinSupport)
  private
    FBitmap: TBitmap;
    FCanvas: TcxCanvas;
    FDownMousePos: TPoint;
    FKind: TScrollBarKind;
    FLargeChange: TScrollBarInc;
    FLookAndFeel: TcxLookAndFeel;
    FMax: Integer;
    FMin: Integer;
    FPageSize: Integer;
    FPosition: Integer;
    FRealCtl3D: Boolean;
    FSavePosition: Integer;
    FSaveThumbnailPos: TPoint;
    FSmallChange: TScrollBarInc;
    FThemeChangedNotificator: TdxThemeChangedNotificator;
    FTimer: TComponent;
    FUnlimitedTracking: Boolean;
    FOnChange: TNotifyEvent;
    FOnScroll: TScrollEvent;
    procedure CancelScroll;
    procedure DoScroll(APart: TcxScrollBarPart);
    function GetCtr3D: Boolean;
    function GetInternalCtl3D: Boolean;
    function GetPositionFromThumbnail: Integer;
    function GetScrollBarPart(P: TPoint): TcxScrollBarPart;
    procedure InternalScroll(AScrollCode: TScrollCode);
    function IsCtl3DStored: Boolean;
    procedure OnTimer(Sender: TObject);
    procedure SetCtl3D(Value: Boolean);
    procedure SetInternalCtl3D(Value: Boolean);
    procedure SetKind(Value: TScrollBarKind);
    procedure SetLookAndFeel(Value: TcxLookAndFeel);
    procedure SetMax(Value: Integer);
    procedure SetMin(Value: Integer);
    procedure SetPageSize(Value: Integer);
    procedure SetPosition(Value: Integer);
    procedure ThemeChanged;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CNHScroll(var Message: TWMHScroll); message CN_HSCROLL;
    procedure CNVScroll(var Message: TWMVScroll); message CN_VSCROLL;
    procedure CNCtlColorScrollBar(var Message: TMessage); message CN_CTLCOLORSCROLLBAR;
    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    FState: TcxScrollBarState;
    FViewInfo: TcxScrollBarViewInfo;
    procedure Change; virtual;
    function GetPainter: TcxCustomLookAndFeelPainterClass;
    function GetViewInfoClass: TcxScrollBarViewInfoClass; virtual;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseEnter(AControl: TControl); dynamic;
    procedure MouseLeave(AControl: TControl); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;

    procedure DoPaint(ACanvas: TcxCanvas); virtual;
    procedure DrawScrollBarPart(ACanvas: TcxCanvas; const R: TRect;
      APart: TcxScrollBarPart; AState: TcxButtonState); virtual;
    function IsButtonHotTrack: Boolean; virtual;
    procedure Paint; override;
    procedure Scroll(ScrollCode: TScrollCode; var ScrollPos: Integer); virtual;
    function ScrollBarMinimalThumbSize: Integer; virtual;

    property InternalCtl3D: Boolean read GetInternalCtl3D write SetInternalCtl3D;
    property Painter: TcxCustomLookAndFeelPainterClass read GetPainter;
    property ViewInfo: TcxScrollBarViewInfo read FViewInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetScrollParams(AMin, AMax, APosition, APageSize: Integer; ARedraw: Boolean = True);
    procedure SetParams(APosition, AMin, AMax: Integer);
  published
    property Align;
    property Anchors;
    property Constraints;
    property Ctl3D read GetCtr3D write SetCtl3D stored IsCtl3DStored;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Kind: TScrollBarKind read FKind write SetKind default sbHorizontal;
    property LargeChange: TScrollBarInc
      read FLargeChange write FLargeChange
      default 1;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel write SetLookAndFeel;
    property Max: Integer read FMax write SetMax default 100;
    property Min: Integer read FMin write SetMin default 0;
    property PageSize: Integer read FPageSize write SetPageSize;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property Position: Integer
      read FPosition write SetPosition
      default 0;
    property ShowHint;
    property SmallChange: TScrollBarInc
      read FSmallChange write FSmallChange
      default 1;
    property UnlimitedTracking: Boolean read FUnlimitedTracking write FUnlimitedTracking default False;
    property Visible;
  {$IFDEF DELPHI5}
    property OnContextPopup;
  {$ENDIF}
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnScroll: TScrollEvent read FOnScroll write FOnScroll;
    property OnStartDock;
    property OnStartDrag;
  end;
  TcxScrollBarClass = class of TcxScrollBar;

function GetScrollBarSize: TSize;      

implementation

uses
  dxuxTheme,
  dxThemeConsts,
  Consts, cxControls;

const
  EmptyRect: TRect = (Left: 0; Top: 0; Right: 0; Bottom: 0);
  cxScrollInitialInterval = 400;
  cxScrollInterval = 60;
  cxScrollMinDistance: Integer = 34;
  cxScrollMaxDistance: Integer = 136;
  cxMinStdThumbnailSize = 8;
  cxTimerParts = [sbpLineUp, sbpLineDown, sbpPageUp, sbpPageDown];

function GetScrollBarSize: TSize;
begin
  Result.cx := GetSystemMetrics(SM_CXVSCROLL);
  Result.cy := GetSystemMetrics(SM_CYHSCROLL);
end;

function MaxInt(A, B: Integer): Integer;
begin
  if A > B then Result := A else Result := B;
end;

function MinInt(A, B: Integer): Integer;
begin
  if A < B then Result := A else Result := B;
end;

{$IFNDEF DELPHI6}

function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ALeft + AWidth;
    Bottom :=  ATop + AHeight;
  end;
end;

{$ENDIF}

{ TcxScrollBarViewInfo }

constructor TcxScrollBarViewInfo.Create(AScrollBar: TcxScrollBar);
begin
  inherited Create;
  FScrollBar := AScrollBar;
end;

procedure TcxScrollBarViewInfo.AdjustPageRects;
begin
  if not IsRectEmpty(FThumbnailRect) then
  begin
    if ScrollBar.Kind = sbHorizontal then
    begin
      FPageUpRect := Rect(FTopLeftArrowRect.Right, 0, FThumbnailRect.Left, ScrollBar.Height);
      FPageDownRect := Rect(FThumbnailRect.Right, 0, FBottomRightArrowRect.Left, ScrollBar.Height);
    end
    else
    begin
      FPageUpRect := Rect(0, FTopLeftArrowRect.Bottom, ScrollBar.Width, FThumbnailRect.Top);
      FPageDownRect := Rect(0, FThumbnailRect.Bottom, ScrollBar.Width, FBottomRightArrowRect.Top);
    end
  end
  else
  begin
    FPageUpRect := EmptyRect;
    FPageDownRect := EmptyRect;
  end;
end;

procedure TcxScrollBarViewInfo.Calculate;
begin
  CalculateRects;
end;

procedure TcxScrollBarViewInfo.CalculateMinThumnailSize;
begin
  FThumbnailSize := ScrollBar.ScrollBarMinimalThumbSize;
end;

procedure TcxScrollBarViewInfo.CalculateThumbnailRect;
var
  ADelta, ASize: Integer;
begin
  FThumbnailRect := EmptyRect;
  AdjustPageRects;
  if not ScrollBar.Enabled then
    Exit;
  if ScrollBar.Kind = sbHorizontal then
  begin
    ADelta := FBottomRightArrowRect.Left - FTopLeftArrowRect.Right;
    if ScrollBar.PageSize = 0 then
    begin
      ASize := GetSystemMetrics(SM_CXHTHUMB);
      if ASize > ADelta then
        Exit;
      Dec(ADelta, ASize);
      if (ADelta <= 0) or (ScrollBar.Max = ScrollBar.Min) then
        FThumbnailRect := Bounds(FTopLeftArrowRect.Right, 0, ASize, ScrollBar.Height)
      else
        FThumbnailRect := Bounds(FTopLeftArrowRect.Right +
          MulDiv(ADelta, ScrollBar.Position - ScrollBar.Min, ScrollBar.Max - ScrollBar.Min), 0, ASize, ScrollBar.Height);
    end
    else
    begin
      ASize := MinInt(ADelta, MulDiv(ScrollBar.PageSize, ADelta, ScrollBar.Max - ScrollBar.Min + 1));
      if (ADelta < FThumbnailSize) or (ScrollBar.Max = ScrollBar.Min) then
        Exit;
      if ASize < FThumbnailSize then
        ASize := FThumbnailSize;
      Dec(ADelta, ASize);
      FThumbnailRect := Bounds(FTopLeftArrowRect.Right, 0, ASize, ScrollBar.Height);
      ASize := (ScrollBar.Max - ScrollBar.Min) - (ScrollBar.PageSize - 1);
      OffsetRect(FThumbnailRect, MulDiv(ADelta, MinInt(ScrollBar.Position - ScrollBar.Min, ASize), ASize), 0);
    end;
  end
  else
  begin
    ADelta := FBottomRightArrowRect.Top - FTopLeftArrowRect.Bottom;
    if ScrollBar.PageSize = 0 then
    begin
      ASize := GetSystemMetrics(SM_CYVTHUMB);
      if ASize > ADelta then
        Exit;
      Dec(ADelta, ASize);
      if (ADelta <= 0) or (ScrollBar.Max = ScrollBar.Min) then
        FThumbnailRect := Bounds(0, FTopLeftArrowRect.Bottom, ScrollBar.Width, ASize)
      else
        FThumbnailRect := Bounds(0, FTopLeftArrowRect.Bottom +
          MulDiv(ADelta, ScrollBar.Position - ScrollBar.Min, ScrollBar.Max - ScrollBar.Min), ScrollBar.Width, ASize);
    end
    else
    begin
      ASize := MinInt(ADelta, MulDiv(ScrollBar.PageSize, ADelta, ScrollBar.Max - ScrollBar.Min + 1));
      if (ADelta < FThumbnailSize) or (ScrollBar.Max = ScrollBar.Min) then
        Exit;
      if ASize < FThumbnailSize then
        ASize := FThumbnailSize;
      Dec(ADelta, ASize);
      FThumbnailRect := Bounds(0, FTopLeftArrowRect.Bottom, ScrollBar.Width, ASize);
      ASize := (ScrollBar.Max - ScrollBar.Min) - (ScrollBar.PageSize - 1);
      OffsetRect(FThumbnailRect, 0, MulDiv(ADelta, MinInt(ScrollBar.Position - ScrollBar.Min, ASize), ASize));
    end;
  end;
  AdjustPageRects;
end;

procedure TcxScrollBarViewInfo.SetThumbnailPos(APos: Integer);
begin
  if ScrollBar.Kind = sbHorizontal then
    OffsetRect(FThumbnailRect, -FThumbnailRect.Left + APos, 0)
  else
    OffsetRect(FThumbnailRect, 0, -FThumbnailRect.Top + APos);
end;

procedure TcxScrollBarViewInfo.CalculateRects;
var
  ASize, H, W: Integer;
begin
  if ScrollBar.Kind = sbHorizontal then
  begin
    ASize := GetScrollBarSize.cy;
    if ScrollBar.Width div 2 < ASize then
      W := ScrollBar.Width div 2
    else
      W := ASize;
    FTopLeftArrowRect := Bounds(0, 0, W, ScrollBar.Height);
    FBottomRightArrowRect := Bounds(ScrollBar.Width - W, 0, W, ScrollBar.Height);
  end
  else
  begin
    ASize := GetScrollBarSize.cx;
    if ScrollBar.Height div 2 < ASize then
      H := ScrollBar.Height div 2
    else
      H := ASize;
    FTopLeftArrowRect := Bounds(0, 0, ScrollBar.Width, H);
    FBottomRightArrowRect := Bounds(0, ScrollBar.Height - H, ScrollBar.Width, H);
  end;
  CalculateThumbnailRect;
end;

{ TcxScrollBar }

constructor TcxScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitmap := TBitmap.Create;
  FBitmap.PixelFormat := pfDevice;
  FCanvas := TcxCanvas.Create(FBitmap.Canvas);
  FLookAndFeel := TcxLookAndFeel.Create(Self);
  FLookAndFeel.OnChanged := LookAndFeelChanged;
  FViewInfo := GetViewInfoClass.Create(Self);
  Width := 121;
  ControlStyle := [csFramed, csOpaque, csCaptureMouse];
  FKind := sbHorizontal;
  Height := GetScrollBarSize.cy;
  FThemeChangedNotificator := TdxThemeChangedNotificator.Create;
  FThemeChangedNotificator.OnThemeChanged := ThemeChanged;
  FPosition := 0;
  FMin := 0;
  FMax := 100;
  FSmallChange := 1;
  FLargeChange := 1;

  FTimer := TcxTimer.Create(nil);
  TcxTimer(FTimer).Enabled := False;
  TcxTimer(FTimer).Interval:= cxScrollInitialInterval;
  TcxTimer(FTimer).OnTimer := OnTimer;
  ViewInfo.CalculateMinThumnailSize;
  ViewInfo.Calculate;
end;

destructor TcxScrollBar.Destroy;
begin
  FreeAndNil(FTimer);
  FreeAndNil(FThemeChangedNotificator);
  FreeAndNil(FViewInfo);
  FreeAndNil(FLookAndFeel);
  FreeAndNil(FCanvas);
  FreeAndNil(FBitmap);
  inherited Destroy;
end;

procedure TcxScrollBar.SetCtl3D(Value: Boolean);
begin
  FRealCtl3D := Value;
  InternalCtl3D := Value;
end;

procedure TcxScrollBar.SetInternalCtl3D(Value: Boolean);
begin
  if InternalCtl3D <> Value then
    inherited Ctl3D := Value;
end;

function TcxScrollBar.IsCtl3DStored: Boolean;
begin
  Result := not ParentCtl3D;
end;

procedure TcxScrollBar.OnTimer(Sender: TObject);

  function CheckHotPart: Boolean;
  var
    P: TPoint;
  begin
    GetCursorPos(P);
    Result := GetScrollBarPart(ScreenToClient(P)) = FState.PressedPart;
  end;

begin
  if (GetCaptureControl = Self) and (FState.PressedPart in cxTimerParts) then
  begin
    if TcxTimer(FTimer).Interval = cxScrollInitialInterval then
      TcxTimer(FTimer).Interval := cxScrollInterval;
    DoScroll(FState.PressedPart);
    TcxTimer(FTimer).Enabled := CheckHotPart;
  end
  else
    CancelScroll;
end;

procedure TcxScrollBar.SetKind(Value: TScrollBarKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    if not (csLoading in ComponentState) then
      SetBounds(Left, Top, Height, Width)
    else
      ViewInfo.Calculate;
    Invalidate;
  end;
end;

procedure TcxScrollBar.SetLookAndFeel(Value: TcxLookAndFeel);
begin
  FLookAndFeel.Assign(Value);
end;

procedure TcxScrollBar.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  ABoundsChanged: Boolean;
begin
  ABoundsChanged := (ALeft <> Left) or (ATop <> Top) or
    (AWidth <> Width) or (AHeight <> Height);
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if ABoundsChanged and (AWidth > 0) and (AHeight > 0) then
  begin
    FBitmap.Width := AWidth;
    FBitmap.Height := AHeight;
    ViewInfo.Calculate;
  end;
end;

procedure TcxScrollBar.SetScrollParams(AMin, AMax, APosition,
  APageSize: Integer; ARedraw: Boolean = True);
begin
  if (AMax < AMin) or (AMax < APageSize) then
    raise EInvalidOperation.Create(SScrollBarRange);
  ARedraw := ARedraw and HandleAllocated;

  if APosition < AMin then APosition := AMin;
  if APosition > AMax then APosition := AMax;

    if (Min <> AMin) or (Max <> AMax) or (FPageSize <> APageSize) or
      (Position <> APosition) then
    begin
      FMin := AMin;
      FMax := AMax;
      FPageSize := APageSize;
    end                                          
    else
      ARedraw := False;
    if Position <> APosition then
    begin
      Enabled := True;
      FPosition := APosition;
      ViewInfo.CalculateThumbnailRect;
      if ARedraw then Repaint;
      Change;
    end
    else
    begin
      ViewInfo.CalculateThumbnailRect;
      if ARedraw then Repaint;
    end;
end;

procedure TcxScrollBar.SetParams(APosition, AMin, AMax: Integer);
begin
  SetScrollParams(AMin, AMax, APosition, FPageSize);
end;

procedure TcxScrollBar.SetMax(Value: Integer);
begin
  SetScrollParams(FMin, Value, FPosition, FPageSize);
end;

procedure TcxScrollBar.SetMin(Value: Integer);
begin
  SetScrollParams(Value, FMax, FPosition, FPageSize);
end;

procedure TcxScrollBar.SetPageSize(Value: Integer);
begin
  SetScrollParams(FMin, FMax, FPosition, Value);
end;

procedure TcxScrollBar.SetPosition(Value: Integer);
begin
  SetScrollParams(FMin, FMax, Value, FPageSize);
end;

procedure TcxScrollBar.Change;
begin
  inherited Changed;
  if Assigned(FOnChange) then FOnChange(Self);
end;

function TcxScrollBar.GetPainter: TcxCustomLookAndFeelPainterClass;
begin
  Result := LookAndFeel.GetAvailablePainter(totScrollBar);
end;

function TcxScrollBar.GetViewInfoClass: TcxScrollBarViewInfoClass;
begin
  Result := TcxScrollBarViewInfo;
end;

procedure TcxScrollBar.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
var
  ASaveValue: Boolean;
begin
  if (LookAndFeel.SkinPainter <> nil) and Ctl3D then
  begin
    ASaveValue := Ctl3D;
    InternalCtl3D := False;
    FRealCtl3D := ASaveValue;
  end
  else
    InternalCtl3D := FRealCtl3D;
  ViewInfo.CalculateMinThumnailSize;
  ViewInfo.Calculate;
  Invalidate;
end;

procedure TcxScrollBar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  APart: TcxScrollBarPart;
begin
  inherited;
  if (Button <> mbLeft) then Exit;
  APart := GetScrollBarPart(Point(X, Y));
  if APart <> sbpNone then
  begin
    if APart = sbpThumbnail then
    begin
      FDownMousePos := Point(X, Y);
      FSavePosition := FPosition;
      FSaveThumbnailPos := ViewInfo.ThumbnailRect.TopLeft;
      InternalScroll(scTrack);
    end;
    FState.PressedPart := APart;
    FState.HotPart := APart;
    if APart in cxTimerParts then
    begin
      DoScroll(APart);
      TcxTimer(FTimer).Interval := cxScrollInitialInterval;
      TcxTimer(FTimer).Enabled := True;
    end;
    Repaint;
  end;
end;

procedure TcxScrollBar.MouseEnter(AControl: TControl);
begin
  if IsButtonHotTrack or (FState.PressedPart in cxTimerParts) then
    Repaint;
end;

procedure TcxScrollBar.MouseLeave(AControl: TControl);
begin
  if FState.PressedPart <> sbpThumbnail then
    FState.HotPart := sbpNone;
  if IsButtonHotTrack or (FState.PressedPart in cxTimerParts) then
    Invalidate;
end;

procedure TcxScrollBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  APart: TcxScrollBarPart;
  R: TRect;
  ADelta, ANewPos, ASize: Integer;

  procedure UpdateThumbnail(ADeltaX, ADeltaY: Integer);
  begin
    if FKind = sbHorizontal then
      ViewInfo.SetThumbnailPos(FSaveThumbnailPos.X + ADeltaX)
    else
      ViewInfo.SetThumbnailPos(FSaveThumbnailPos.Y + ADeltaY);
    ViewInfo.AdjustPageRects;
    Repaint;
  end;

begin
  inherited MouseMove(Shift, X, Y);
  APart := GetScrollBarPart(Point(X, Y));
  if FState.PressedPart = sbpThumbnail then
  begin
    if FKind = sbHorizontal then
    begin
      ASize := ViewInfo.ThumbnailRect.Right - ViewInfo.ThumbnailRect.Left;
      R := Rect(-cxScrollMinDistance, -cxScrollMaxDistance,
        Width + cxScrollMinDistance, Height + cxScrollMaxDistance);
    end
    else
    begin
      ASize := ViewInfo.ThumbnailRect.Bottom - ViewInfo.ThumbnailRect.Top;
      R := Rect(-cxScrollMaxDistance, -cxScrollMinDistance,
        Width + cxScrollMaxDistance, Height + cxScrollMinDistance);
    end;
    if not (FUnlimitedTracking or PtInRect(R, Point(X, Y))) then
    begin
      if Position <> FSavePosition then
      begin
        Position := FSavePosition;
        DoScroll(sbpThumbnail);
      end; 
    end
    else
    begin
      if FKind = sbHorizontal then
      begin
        ADelta := X - FDownMousePos.X;
        if ADelta = 0 then Exit;
        if (ADelta < 0) and (FSaveThumbnailPos.X + ADelta < ViewInfo.TopLeftArrowRect.Right) then
          ADelta := ViewInfo.TopLeftArrowRect.Right - FSaveThumbnailPos.X
        else
          if (ADelta > 0) and (FSaveThumbnailPos.X + ASize + ADelta > ViewInfo.BottomRightArrowRect.Left) then
            ADelta := ViewInfo.BottomRightArrowRect.Left - (FSaveThumbnailPos.X + ASize);
        UpdateThumbnail(ADelta, 0);
      end
      else
      begin
        ADelta := Y - FDownMousePos.Y;
        if ADelta = 0 then Exit;
        if (ADelta < 0) and (FSaveThumbnailPos.Y + ADelta < ViewInfo.TopLeftArrowRect.Bottom) then
          ADelta := ViewInfo.TopLeftArrowRect.Bottom - FSaveThumbnailPos.Y
        else
          if (ADelta > 0) and (FSaveThumbnailPos.Y + ASize + ADelta > ViewInfo.BottomRightArrowRect.Top) then
            ADelta := ViewInfo.BottomRightArrowRect.Top - (FSaveThumbnailPos.Y + ASize);
        UpdateThumbnail(0, ADelta);
      end;
      ANewPos := GetPositionFromThumbnail;
      if ANewPos <> FPosition then
      begin
        FPosition := ANewPos;
        DoScroll(sbpThumbnail);
      end;
    end;
  end
  else
  begin
    if FState.PressedPart <> sbpNone then
      TcxTimer(FTimer).Enabled := FState.PressedPart = APart;
    if (FState.HotPart <> APart) and IsButtonHotTrack then
    begin
      FState.HotPart := APart;
      Repaint;
    end
    else
      FState.HotPart := APart;
  end;
end;

procedure TcxScrollBar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  begin
    CancelScroll;
    FState.HotPart := GetScrollBarPart(Point(X, Y));
  end;
end;

procedure TcxScrollBar.DoPaint(ACanvas: TcxCanvas);

  function GetButtonStateFromPartState(APart: TcxScrollBarPart): TcxButtonState;
  begin
    if not Enabled then
      Result := cxbsDisabled
    else
      if (APart <> sbpThumbnail) or ((APart = sbpThumbnail) and
        IsButtonHotTrack) then
      begin
        if FState.PressedPart <> sbpNone then
          if (APart = FState.PressedPart) and (APart = FState.HotPart) then
            Result := cxbsPressed
          else
            Result := cxbsNormal
        else
          if (APart = FState.HotPart) and not (csDesigning in ComponentState) then
            Result := cxbsHot
          else
            Result := cxbsNormal
      end
      else
        Result := cxbsNormal;
  end;

begin
  if not IsRectEmpty(ViewInfo.ThumbnailRect) then
    DrawScrollBarPart(ACanvas, ViewInfo.ThumbnailRect, sbpThumbnail,
      GetButtonStateFromPartState(sbpThumbnail))
  else
    DrawScrollBarPart(ACanvas, Bounds(0, 0, Width, Height), sbpPageUp, cxbsNormal);
  DrawScrollBarPart(ACanvas, ViewInfo.TopLeftArrowRect, sbpLineUp,
    GetButtonStateFromPartState(sbpLineUp));
  DrawScrollBarPart(ACanvas, ViewInfo.BottomRightArrowRect, sbpLineDown,
    GetButtonStateFromPartState(sbpLineDown));
  if not IsRectEmpty(ViewInfo.PageUpRect) then
    DrawScrollBarPart(ACanvas, ViewInfo.PageUpRect, sbpPageUp,
      GetButtonStateFromPartState(sbpPageUp));
  if not IsRectEmpty(ViewInfo.PageDownRect) then
    DrawScrollBarPart(ACanvas, ViewInfo.PageDownRect, sbpPageDown,
      GetButtonStateFromPartState(sbpPageDown));
end;

procedure TcxScrollBar.DrawScrollBarPart(ACanvas: TcxCanvas; const R: TRect;
  APart: TcxScrollBarPart; AState: TcxButtonState);
begin
  Painter.DrawScrollBarPart(ACanvas, Kind = sbHorizontal, R, APart, AState);
end;

function TcxScrollBar.IsButtonHotTrack: Boolean;
begin
  Result := Painter.IsButtonHotTrack;
end;

procedure TcxScrollBar.Paint;
begin
  DoPaint(FCanvas);
  BitBlt(Canvas.Handle, 0, 0, FBitmap.Width, FBitmap.Height,
    FCanvas.Handle, 0, 0, SRCCOPY);
end;

procedure TcxScrollBar.Scroll(ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  if Assigned(FOnScroll) then FOnScroll(Self, ScrollCode, ScrollPos);
end;

function TcxScrollBar.ScrollBarMinimalThumbSize: Integer;
begin
  Result := Painter.ScrollBarMinimalThumbSize(Kind = sbVertical);
end;

procedure TcxScrollBar.CancelScroll;
begin
  if FState.PressedPart <> sbpNone then
  begin
    if FState.PressedPart = sbpThumbnail then
    begin
      FPosition := GetPositionFromThumbnail;
      InternalScroll(scPosition);
    end;
    TcxTimer(FTimer).Enabled := False;
    FState.PressedPart := sbpNone;
    FState.HotPart := sbpNone;
    InternalScroll(scEndScroll);
    ViewInfo.CalculateThumbnailRect;
    Invalidate;
  end;
end;

procedure TcxScrollBar.DoScroll(APart: TcxScrollBarPart);
begin
  case APart of
    sbpLineUp:  InternalScroll(scLineUp);
    sbpLineDown: InternalScroll(scLineDown);
    sbpPageUp: InternalScroll(scPageUp);
    sbpPageDown: InternalScroll(scPageDown);
    sbpThumbnail: InternalScroll(scTrack);
  end;
end;

function TcxScrollBar.GetCtr3D: Boolean;
begin
  Result := InternalCtl3D or FRealCtl3D;
end;

function TcxScrollBar.GetInternalCtl3D: Boolean;
begin
  Result := inherited Ctl3D;
end;

function TcxScrollBar.GetPositionFromThumbnail: Integer;
var
  ATotal, AThumbnailSize, ADistance: Integer;
begin
  ATotal := FMax - FMin;
  if FPageSize > 0 then Dec(ATotal, FPageSize - 1);
  if FKind = sbHorizontal then
  begin
    AThumbnailSize := ViewInfo.ThumbnailRect.Right - ViewInfo.ThumbnailRect.Left;
    ADistance := ViewInfo.BottomRightArrowRect.Left - ViewInfo.TopLeftArrowRect.Right - AThumbnailSize;
    Result := FMin + MulDiv(ATotal, ViewInfo.ThumbnailRect.Left - ViewInfo.TopLeftArrowRect.Right,
      ADistance);
  end
  else
  begin
    AThumbnailSize := ViewInfo.ThumbnailRect.Bottom - ViewInfo.ThumbnailRect.Top;
    ADistance := ViewInfo.BottomRightArrowRect.Top - ViewInfo.TopLeftArrowRect.Bottom - AThumbnailSize;
    Result := FMin + MulDiv(ATotal, ViewInfo.ThumbnailRect.Top - ViewInfo.TopLeftArrowRect.Bottom,
      ADistance);
  end;
end;

function TcxScrollBar.GetScrollBarPart(P: TPoint): TcxScrollBarPart;
begin
  Result := sbpNone;
  if not PtInRect(ClientRect, P) then
    Exit;
  if PtInRect(ViewInfo.TopLeftArrowRect, P) then
    Result := sbpLineUp
  else if PtInRect(ViewInfo.BottomRightArrowRect, P) then
    Result := sbpLineDown
  else if IsRectEmpty(ViewInfo.ThumbnailRect) then
    Exit
  else if PtInRect(ViewInfo.ThumbnailRect, P) then
    Result := sbpThumbnail
  else if PtInRect(ViewInfo.PageUpRect, P) then
    Result := sbpPageUp
  else if PtInRect(ViewInfo.PageDownRect, P) then
    Result := sbpPageDown
end;

procedure TcxScrollBar.InternalScroll(AScrollCode: TScrollCode);
var
  ScrollPos: Integer;
  NewPos: Longint;

  procedure CorrectPos(var APos: Integer);
  begin
    if APos < Min then APos := Min;
    if APos > Max then APos := Max;
  end;

begin
  NewPos := Position;
  case AScrollCode of
    scLineUp:
      Dec(NewPos, SmallChange);
    scLineDown:
      Inc(NewPos, SmallChange);
    scPageUp:
      Dec(NewPos, LargeChange);
    scPageDown:
      Inc(NewPos, LargeChange);
    scTop:
        NewPos := FMin;
    scBottom:
        NewPos := FMax;
  end;
  CorrectPos(NewPos);
  ScrollPos := NewPos;
  Scroll(AScrollCode, ScrollPos);
  begin
    CorrectPos(ScrollPos);
    if ScrollPos <> FPosition then
    begin
      if AScrollCode <> scTrack then
        SetPosition(ScrollPos)
      else
      begin
        FPosition := ScrollPos;
        Repaint;
      end;
    end;
  end;
end;

procedure TcxScrollBar.ThemeChanged;
begin
  ViewInfo.CalculateMinThumnailSize;
  ViewInfo.Calculate;
  UpdateScrollBarBitmaps;
  Invalidate;
  if Parent <> nil then
    Parent.Realign;
end;

procedure TcxScrollBar.CMCtl3DChanged(
  var Message: TMessage);
begin
  inherited;
  FRealCtl3D := InternalCtl3D;
  LookAndFeelChanged(LookAndFeel, []);
end;

procedure TcxScrollBar.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  ViewInfo.Calculate;
  if not Enabled then
    CancelScroll;
  Invalidate;
end;

procedure TcxScrollBar.CNHScroll(var Message: TWMHScroll);
begin
  InternalScroll(TScrollCode(Message.ScrollCode));
end;

procedure TcxScrollBar.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseEnter(Self)
  else
    MouseEnter(TControl(Message.lParam));
end;

procedure TcxScrollBar.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseLeave(Self)
  else
    MouseLeave(TControl(Message.lParam));
end;

procedure TcxScrollBar.CMSysColorChange(var Message: TMessage);
begin
  UpdateScrollBarBitmaps;
  inherited;
end;

procedure TcxScrollBar.CMVisibleChanged(var Message: TMessage);
begin
  if not Visible then CancelScroll;
  inherited;
end;

procedure TcxScrollBar.CNVScroll(var Message: TWMVScroll);
begin
  InternalScroll(TScrollCode(Message.ScrollCode));
end;

procedure TcxScrollBar.CNCtlColorScrollBar(var Message: TMessage);
begin
  UpdateScrollBarBitmaps;
  with Message do
    CallWindowProc(DefWndProc, Handle, Msg, WParam, LParam);
end;

procedure TcxScrollBar.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TcxScrollBar.WMCancelMode(var Message: TWMCancelMode);
begin
  CancelScroll;
  inherited;
end;

end.
