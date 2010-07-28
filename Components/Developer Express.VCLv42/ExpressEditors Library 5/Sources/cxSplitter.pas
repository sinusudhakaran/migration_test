
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
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

unit cxSplitter;

{$I cxVer.inc}

interface

uses
  Windows, Classes, Controls, Forms, Graphics, Messages, SysUtils, cxClasses,
  cxControls, cxExtEditConsts, cxExtEditUtils, cxGraphics, cxLookAndFeels;

type
  TcxPositionAfterOpen = 2..High(Integer);
  TcxSplitterAlign = (salBottom, salLeft, salRight, salTop);
  TcxSplitterDragState = (sstNormal, sstResizing, sstHotZoneClick);
  TcxSplitterMouseState = (smsClicked, smsInHotZone);
  TcxSplitterMouseStates = set of TcxSplitterMouseState;
  TcxSplitterState = (ssOpened, ssClosed);
  TcxSplitterDirection = (cxsdLeftToRight, cxsdRightToLeft, cxsdTopToBottom, cxsdBottomToTop);
  TCanResizeEvent = procedure(Sender: TObject; var NewSize: Integer; var Accept: Boolean) of object;
  TBeforeOpenHotZoneEvent = procedure(Sender: TObject;
    var NewSize: Integer; var AllowOpen: Boolean) of object;
  TBeforeCloseHotZoneEvent = procedure(Sender: TObject; var AllowClose: Boolean) of object;

type
  TcxCustomSplitter = class;

  { TcxHotZoneStyle }

  TcxHotZoneStyle = class(TPersistent)
  private
    FOwner: TcxCustomSplitter;
    FSizePercent: TcxNaturalNumber;
    FVisible: Boolean;
    FHotZoneRect: TRect;
    procedure SetSizePercent(Value: TcxNaturalNumber);
    procedure SetVisible(Value: Boolean);
  protected
    procedure Changed; virtual;
    function SplitterDirection: TcxSplitterDirection; virtual;
    function CalculateHotZoneRect(const ABounds: TRect): TRect; virtual;
    function GetMinSize: TcxNaturalNumber; virtual;
    function GetMaxSize: TcxNaturalNumber; virtual;
    function DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean): TRect; virtual;
    procedure DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean); virtual;
  public
    constructor Create(AOwner: TcxCustomSplitter); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property SizePercent: TcxNaturalNumber read FSizePercent write SetSizePercent default 30;
    property Visible: Boolean read FVisible write SetVisible default True;
    property HotZoneRect: TRect read FHotZoneRect write FHotZoneRect;
    property Owner: TcxCustomSplitter read FOwner;
  end;

  TcxHotZoneStyleClass = class of TcxHotZoneStyle;

  { TcxMediaPlayer9Style }
  TcxMediaPlayer9Style = class(TcxHotZoneStyle)
  private
    FArrowRect: TRect;
    FArrowColor: TColor;
    FArrowHighlightColor: TColor;
    FLightColor: TColor;
    FBorderColor: TColor;
    FShadowStartColor: TColor;
    FShadowHighlightStartColor: TColor;
    procedure SetArrowColor(Value: TColor);
    procedure SetArrowHighlightColor(Value: TColor);
    procedure SetLightColor(Value: TColor);
    procedure SetBorderColor(Value: TColor);
    procedure SetShadowStartColor(Value: TColor);
    procedure SetShadowHighlightStartColor(Value: TColor);
  protected
    function DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean): TRect; override;
    procedure DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean); override;
    function CalculateHotZoneRect(const ABounds: TRect): TRect; override;
  public
    constructor Create(AOwner: TcxCustomSplitter); override;
    procedure Assign(Source: TPersistent); override;
  published
    property SizePercent;
    property Visible;
    property ArrowColor: TColor read FArrowColor write SetArrowColor default clWindowText;
    property ArrowHighlightColor: TColor read FArrowHighlightColor write SetArrowHighlightColor default clBlue;
    property LightColor: TColor read FLightColor write SetLightColor default clWindow;
    property BorderColor: TColor read FBorderColor write SetBorderColor default clBtnShadow;
    property ShadowStartColor: TColor read FShadowStartColor write SetShadowStartColor default $00F5E6CD;
    property ShadowHighlightStartColor: TColor read FShadowHighlightStartColor
      write SetShadowHighlightStartColor default $00AFF5C3;
  end;

  { TcxMediaPlayer8Style }
  TcxMediaPlayer8Style = class(TcxHotZoneStyle)
  private
    FLTPointsRect: TRect;
    FRBPointsRect: TRect;
    FArrowRect: TRect;
    FArrowColor: TColor;
    FArrowHighlightColor: TColor;
    FLightColor: TColor;
    FShadowColor: TColor;
    procedure SetArrowColor(Value: TColor);
    procedure SetArrowHighlightColor(Value: TColor);
    procedure SetLightColor(Value: TColor);
    procedure SetShadowColor(Value: TColor);
    procedure DrawArrowRect(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean);
  protected
    function DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean): TRect; override;
    procedure DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean); override;
    function CalculateHotZoneRect(const ABounds: TRect): TRect; override;
  public
    constructor Create(AOwner: TcxCustomSplitter); override;
    procedure Assign(Source : TPersistent); override;
  published
    property SizePercent;
    property Visible;
    property ArrowColor: TColor read FArrowColor write SetArrowColor default clWindowText;
    property ArrowHighlightColor: TColor read FArrowHighlightColor write SetArrowHighlightColor default clWindow;
    property LightColor: TColor read FLightColor write SetLightColor default clWindow;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clBtnShadow;
  end;

  { TcxXPTaskBarStyle }
  TcxXPTaskBarStyle = class(TcxHotZoneStyle)
  private
    FLightColor: TColor;
    FShadowColor: TColor;
    FLTPointsRect: TRect;
    FRBPointsRect: TRect;
    procedure SetLightColor(Value: TColor);
    procedure SetShadowColor(Value: TColor);
  protected
    function DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean): TRect; override;
    procedure DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean); override;
    function CalculateHotZoneRect(const ABounds: TRect): TRect; override;
  public
    constructor Create(AOwner: TcxCustomSplitter); override;
    procedure Assign(Source : TPersistent); override;
  published
    property SizePercent;
    property Visible;
    property LightColor: TColor read FLightColor write SetLightColor default clWindow;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clBtnShadow;
  end;

  { TcxSimpleStyle }
  TcxSimpleStyle = class(TcxHotZoneStyle)
  private
    FArrowColor: TColor;
    FArrowHighlightColor: TColor;
    FLightColor: TColor;
    FShadowColor: TColor;
    FDotsColor: TColor;
    FDotsShadowColor: TColor;
    FLTArrowRect: TRect;
    FRBArrowRect: TRect;
    procedure SetArrowColor(Value: TColor);
    procedure SetArrowHighlightColor(Value: TColor);
    procedure SetLightColor(Value: TColor);
    procedure SetShadowColor(Value: TColor);
    procedure SetDotsColor(Value: TColor);
    procedure SetDotsShadowColor(Value: TColor);
  protected
    function DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean): TRect; override;
    procedure DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
      const AHighlighted, AClicked: Boolean); override;
    function CalculateHotZoneRect(const ABounds: TRect): TRect; override;
  public
    constructor Create(AOwner: TcxCustomSplitter); override;
    procedure Assign(Source : TPersistent); override;
  published
    property SizePercent;
    property Visible;
    property ArrowColor: TColor read FArrowColor write SetArrowColor default clWindowText;
    property ArrowHighlightColor: TColor read FArrowHighlightColor write SetArrowHighlightColor default clWindow;
    property LightColor: TColor read FLightColor write SetLightColor default clWindow;
    property ShadowColor: TColor read FShadowColor write SetShadowColor default clBtnShadow;
    property DotsColor: TColor read FDotsColor write SetDotsColor default clHighlight;
    property DotsShadowColor: TColor read FDotsShadowColor write SetDotsShadowColor default clWindow;
  end;

  {TdxSplitterDragImage}

  TdxSplitterDragImage = class(TcxCustomDragImage)
  protected
    procedure Paint; override;
  end;

  { TcxCustomSplitter }

  TcxCustomSplitter = class(TcxControl)
  private
    FActiveControl: TWinControl;
    FAlignSplitter: TcxSplitterAlign;
    FAllowHotZoneDrag: Boolean;
    FAutoPosition: Boolean;
    FAutoSnap: Boolean;
    FBrush: TBrush;
    FControl: TControl;
    FDragImage: TdxSplitterDragImage;
    FDragThreshold: TcxNaturalNumber;
    FDrawCanvas: TcxCanvas;
    FHotZone: TcxHotZoneStyle;
    FHotZoneClickPoint: TPoint;
    FHotZoneEvents: TNotifyEvent;
    FHotZoneStyleClass: TcxHotZoneStyleClass;
    FInvertDirection: Boolean;
    FLastPatternDrawPosition: Integer;
    FMaxSize: Word;
    FMinSize: TcxNaturalNumber;
    FMouseStates: TcxSplitterMouseStates;
    FNativeBackground: Boolean;
    FNewSize: Integer;
    FOldSize: Integer;
    FOnAfterClose: TNotifyEvent;
    FOnAfterOpen: TNotifyEvent;
    FOnBeforeClose: TBeforeCloseHotZoneEvent;
    FOnBeforeOpen: TBeforeOpenHotZoneEvent;
    FOnCanResize: TCanResizeEvent;
    FOnMoved: TNotifyEvent;
    FPositionAfterOpen: TcxPositionAfterOpen;
    FPrevKeyDown: TKeyEvent;
    FResizeIgnoreSnap: Boolean; //deprecated
    FResizeUpdate: Boolean;
    FSavedParentShowHint: Boolean;
    FSavedShowHint: Boolean;
    FSplit: Integer;
    FSplitterClickPoint: TPoint;
    FSplitterState: TcxSplitterDragState;
    FState: TcxSplitterState;
    procedure CalcSplitSize(X, Y: Integer; var NewSize, Split: Integer;
      ACorrectWithMaxMin: Boolean = True);
    procedure ControlResizing(X, Y: Integer);
    function FindControl: TControl;
    procedure FocusKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function GetMaxControlSize: Integer;
    function IsAllControlHotZoneStyle: Boolean;
    procedure UpdateControlSize;
    procedure UpdateSize(X, Y: Integer);

    function GetDragImageTopLeft: TPoint;
    procedure InitDragImage;
    procedure MoveDragImage;
    procedure ReleaseDragImage;

    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure SetAlignSplitter(Value: TcxSplitterAlign);
    procedure SetSplitterState(Value: TcxSplitterState);
    procedure SetAllowHotZoneDrag(Value: Boolean);
    procedure SetInvertDirection(Value: Boolean);
    procedure SetHotZone(Value: TcxHotZoneStyle);
    procedure SetNativeBackground(Value: Boolean);
    procedure SetDefaultStates;
    procedure RecalcLastPosition;
    procedure NormalizeSplitterSize;
    procedure SetHotZoneStyleClass(const Value: TcxHotZoneStyleClass);
    function GetHotZoneClassName: string;
    procedure SetHotZoneClassName(Value: string);
    procedure InitResize(X, Y: Integer);
    procedure WMCancelMode(var Message: TWMCancelMode); message WM_CANCELMODE;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
  protected
    { Protected declarations }
    FDrawBitmap: TBitmap;
    FPositionBeforeClose: Integer;
    function CanFocusOnClick: Boolean; override;
    function CanResize(var NewSize: Integer): Boolean; reintroduce; virtual;
    function DoCanResize(var NewSize: Integer): Boolean; virtual;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure HotZoneStyleChanged; virtual;
    procedure DrawHotZone; virtual;
    procedure Paint; override;
    procedure StopSizing; virtual;
    function GetSplitterMinSize: TcxNaturalNumber; virtual;
    function GetSplitterMaxSize: TcxNaturalNumber; virtual;
    procedure CreateHotZone; virtual;
    procedure DestroyHotZone; virtual;
    procedure DoEventBeforeOpen(var ANewSize: Integer;
      var AllowOpenHotZone: Boolean); virtual;
    procedure DoEventAfterOpen; virtual;
    procedure DoEventBeforeClose(var AllowCloseHotZone: Boolean); virtual;
    procedure DoEventAfterClose; virtual;
    procedure DoEventMoved; virtual;
    function InternalGetMinSize: Integer;
    procedure Notification(ACOmponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    function CalculateSplitterDirection: TcxSplitterDirection; virtual;
    procedure UpdateMouseStates(X, Y: Integer); virtual;
    property AlignSplitter: TcxSplitterAlign read FAlignSplitter
      write SetAlignSplitter default salLeft;
    property AutoPosition: Boolean read FAutoPosition write FAutoPosition default True;
    property AutoSnap: Boolean read FAutoSnap write FAutoSnap default False;
    property AllowHotZoneDrag: Boolean read FAllowHotZoneDrag write SetAllowHotZoneDrag default True;
    property DragThreshold: TcxNaturalNumber read FDragThreshold write FDragThreshold default 3;
    property InvertDirection: Boolean read FInvertDirection
      write SetInvertDirection default False;
    property MinSize: TcxNaturalNumber read FMinSize write FMinSize default 30;
    property PositionAfterOpen: TcxPositionAfterOpen read FPositionAfterOpen
      write FPositionAfterOpen default 30;
    property ResizeUpdate: Boolean read FResizeUpdate
      write FResizeUpdate default False;
    property ResizeIgnoreSnap: Boolean read FResizeIgnoreSnap
      write FResizeIgnoreSnap stored False; //deprecated
    property Control: TControl read FControl write FControl;
    property NativeBackground: Boolean read FNativeBackground write SetNativeBackground default True;
    property OnCanResize: TCanResizeEvent read FOnCanResize write FOnCanResize;
    property OnMoved: TNotifyEvent read FOnMoved write FOnMoved;
    property OnBeforeOpen: TBeforeOpenHotZoneEvent read FOnBeforeOpen write FOnBeforeOpen;
    property OnAfterOpen: TNotifyEvent read FOnAfterOpen write FOnAfterOpen;
    property OnBeforeClose: TBeforeCloseHotZoneEvent read FOnBeforeClose write FOnBeforeClose;
    property OnAfterClose: TNotifyEvent read FOnAfterClose write FOnAfterClose;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure OpenSplitter;
    procedure CloseSplitter;
    property State: TcxSplitterState read FState write SetSplitterState;
    function IsPointInHotZone(const X, Y: Integer): Boolean;
    function IsPointInSplitter(const X, Y: Integer): Boolean;
    property HotZoneStyleClass: TcxHotZoneStyleClass read FHotZoneStyleClass
      write SetHotZoneStyleClass;
    property Direction: TcxSplitterDirection read CalculateSplitterDirection;
  published
    property HotZoneClassName: string read GetHotZoneClassName write SetHotZoneClassName;
    property HotZone: TcxHotZoneStyle read FHotZone write SetHotZone;
    property HotZoneEvents: TNotifyEvent read FHotZoneEvents write FHotZoneEvents;
  end;

  { TcxSplitter }
  TcxSplitter = class(TcxCustomSplitter)
  published
    { Public declarations }
    property AlignSplitter;
    property AllowHotZoneDrag;
    property AutoPosition;
    property DragThreshold;
    property NativeBackground;
    property PositionAfterOpen;
    property AutoSnap;
    property InvertDirection;
    property MinSize;
    property ResizeUpdate;
    property ResizeIgnoreSnap; //deprecated
    property Control;
    property OnCanResize;
    property OnMoved;
    property OnBeforeOpen;
    property OnAfterOpen;
    property OnBeforeClose;
    property OnAfterClose;
    property Color;
    property ShowHint;
    property ParentColor;
    property ParentShowHint;
    property Visible;
  end;

function GetRegisteredHotZoneStyles: TcxRegisteredClasses;

implementation

uses
  cxContainer, dxThemeConsts, dxThemeManager, dxUxTheme;

type
  TWinControlAccess = class(TWinControl);

const
  SplitterDefaultSize = 8;

var
  FRegisteredHotZoneStyles: TcxRegisteredClasses;

function GetRegisteredHotZoneStyles: TcxRegisteredClasses;
begin
  if FRegisteredHotZoneStyles = nil then
    FRegisteredHotZoneStyles := TcxRegisteredClasses.Create;
  Result := FRegisteredHotZoneStyles;
end;

procedure DrawSplitterDots(ACanvas: TcxCanvas; const ARect: TRect; const AClicked: Boolean;
  const AFromLeftTop: Boolean; const ALightColor, AShadowColor: TColor;
  const ASplitterDirection: TcxSplitterDirection; const ABetweenPoints, AIndent: Integer);
var
  I, ANextDotPoint: Integer;

  procedure PaintOuterDot(X, Y: Integer);
  begin
    ACanvas.Brush.Color := ALightColor;
    ACanvas.FillRect(Rect(X, Y, X + 2, Y + 2));
    ACanvas.Brush.Color := AShadowColor;
    ACanvas.FillRect(Rect(X + 1, Y + 1, X + 3, Y + 3));
  end;

  procedure PaintInnerDot(X, Y: Integer);
  begin
    ACanvas.Brush.Color := ALightColor;
    ACanvas.FillRect(Rect(X + 1, Y + 1, X + 3, Y + 3));
    ACanvas.Brush.Color := AShadowColor;
    ACanvas.FillRect(Rect(X, Y, X + 2, Y + 2));
  end;

begin
  if AFromLeftTop = True then
  begin
    if (ASplitterDirection = cxsdLeftToRight) or (ASplitterDirection = cxsdRightToLeft) then
    begin
      ANextDotPoint := ARect.Top + ABetweenPoints;
      for I := ARect.Top + ABetweenPoints to ARect.Bottom - ABetweenPoints do
        if (I = ANextDotPoint) and ((I + ABetweenPoints) <= ARect.Bottom) then
        begin
          if AClicked = False then
            PaintOuterDot(ARect.Left + AIndent, I)
          else
            PaintInnerDot(ARect.Left + AIndent, I);
          Inc(ANextDotPoint, ABetweenPoints + 2);
        end;
    end
    else
    begin
      ANextDotPoint := ARect.Left + ABetweenPoints;
      for I := ARect.Left + ABetweenPoints to ARect.Right - ABetweenPoints do
        if (I = ANextDotPoint) and ((I + ABetweenPoints) <= ARect.Right) then
        begin
          if AClicked = False then
            PaintOuterDot(I, ARect.Top + AIndent)
          else
            PaintInnerDot(I, ARect.Top + AIndent);
          Inc(ANextDotPoint, ABetweenPoints + 2);
        end;
    end;
  end
  else
  begin
    if (ASplitterDirection = cxsdLeftToRight) or (ASplitterDirection = cxsdRightToLeft) then
    begin
      ANextDotPoint := ARect.Bottom - (ABetweenPoints * 2);
      for I := ARect.Bottom - (ABetweenPoints * 2) downto ARect.Top do
        if (I = ANextDotPoint) and (I >= ARect.Top) then
        begin
          if AClicked = False then
            PaintOuterDot(ARect.Left + AIndent, I)
          else
            PaintInnerDot(ARect.Left + AIndent, I);
          Dec(ANextDotPoint, ABetweenPoints + 2);
        end;
    end
    else
    begin
      ANextDotPoint := ARect.Right - (ABetweenPoints * 2);
      for I := ARect.Right - (ABetweenPoints * 2) downto ARect.Left do
        if (I = ANextDotPoint) and (I >= ARect.Left) then
        begin
          if AClicked = False then
            PaintOuterDot(I, ARect.Top + AIndent)
          else
            PaintInnerDot(I, ARect.Top + AIndent);
          Dec(ANextDotPoint, ABetweenPoints + 2);
        end;
    end;
  end;
end;

procedure DrawHotZoneArrow(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean; const ArrowColor, ArrowHighlightColor: TColor;
  const ASplitterDirection: TcxSplitterDirection);
var
  I, ADelta, ACenter, ARectSize: Integer;
  ALocalArrowColor: TColor;
begin
  if (AHighlighted = False) or (AClicked = True) then
    ALocalArrowColor := ArrowColor
  else
    ALocalArrowColor := ArrowHighlightColor;
  if (ASplitterDirection = cxsdLeftToRight) or (ASplitterDirection = cxsdRightToLeft) then
  begin
    ARectSize := ARect.Bottom - ARect.Top;
    if (ARectSize mod 2) <> 0 then Dec(ARectSize, 1);
    ACenter := (ARectSize div 2) + 1;
  end
  else
  begin
    ARectSize := ARect.Right - ARect.Left;
    if (ARectSize mod 2) <> 0 then Dec(ARectSize, 1);
    ACenter := (ARectSize div 2) + 1;
  end;
  case ASplitterDirection of
    cxsdLeftToRight:
    begin
      for I := 0 to 3 do
      begin
        if I = 3 then
          ADelta := 1
        else
          ADelta := 0;
        DrawCanvasLine(ACanvas.Canvas, ALocalArrowColor, Point(ARect.Left + 4 - I + ADelta,
          ARect.Top + ACenter - I), Point(ARect.Left + 6 - I, ARect.Top + ACenter - I));
        DrawCanvasLine(ACanvas.Canvas, ALocalArrowColor, Point(ARect.Left + 4 - I + ADelta,
          ARect.Top + ACenter + I), Point(ARect.Left + 6 - I, ARect.Top + ACenter + I));
      end;
    end;
    cxsdRightToLeft:
    begin
      for I := 0 to 3 do
      begin
        if I = 3 then
          ADelta := -1
        else
          ADelta := 0;
        DrawCanvasLine(ACanvas.Canvas, ALocalArrowColor, Point(ARect.Left + 2 + I,
          ARect.Top + ACenter - I), Point(ARect.Left + 4 + I + ADelta, ARect.Top + ACenter - I));
        DrawCanvasLine(ACanvas.Canvas, ALocalArrowColor, Point(ARect.Left + 2 + I,
          ARect.Top + ACenter + I), Point(ARect.Left + 4 + I + ADelta, ARect.Top + ACenter + I));
      end;
    end;
    cxsdTopToBottom:
    begin
      for I := 0 to 3 do
      begin
        if I = 3 then
          ADelta := 1
        else
          ADelta := 0;
        DrawCanvasLine(ACanvas.Canvas, ALocalArrowColor, Point(ARect.Left + ACenter - I,
          ARect.Top + 4 - I + ADelta), Point(ARect.Left + ACenter - I, ARect.Top + 6 - I));
        DrawCanvasLine(ACanvas.Canvas, ALocalArrowColor, Point(ARect.Left + ACenter + I,
          ARect.Top + 4 - I + ADelta), Point(ARect.Left + ACenter + I, ARect.Top + 6 - I));
      end;
    end;
    cxsdBottomToTop:
    begin
      for I := 0 to 3 do
      begin
        if I = 3 then
          ADelta := -1
        else
          ADelta := 0;
        DrawCanvasLine(ACanvas.Canvas, ALocalArrowColor, Point(ARect.Left + ACenter - I,
          ARect.Top + 2 + I), Point(ARect.Left + ACenter - I, ARect.Top + 4 + I + ADelta));
        DrawCanvasLine(ACanvas.Canvas, ALocalArrowColor, Point(ARect.Left + ACenter + I,
          ARect.Top + 2 + I), Point(ARect.Left + ACenter + I, ARect.Top + 4 + I + ADelta));
      end;
    end;
  end;
end;

{ TcxHotZoneStyle }
constructor TcxHotZoneStyle.Create(AOwner: TcxCustomSplitter);
begin
  inherited Create;
  FOwner := AOwner;
  FSizePercent := 30;
  FVisible := True;
end;

destructor TcxHotZoneStyle.Destroy;
begin
  FOwner := nil;
  inherited;
end;

procedure TcxHotZoneStyle.Assign(Source: TPersistent);
begin
  if (Source is TcxHotZoneStyle) then
  begin
    with (Source as TcxHotZoneStyle) do
    begin
      Self.SizePercent := SizePercent;
      Self.Visible := Visible;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxHotZoneStyle.Changed;
begin
  if Assigned(FOwner) then FOwner.HotZoneStyleChanged;
end;

function TcxHotZoneStyle.SplitterDirection: TcxSplitterDirection;
begin
  if Assigned(FOwner) then
    Result := FOwner.CalculateSplitterDirection
  else
    Result := Low(TcxSplitterDirection);
end;

procedure TcxHotZoneStyle.SetSizePercent(Value: TcxNaturalNumber);
begin
  if FSizePercent <> Value then
  begin
    FSizePercent := Value;
    Changed;
  end;
end;

procedure TcxHotZoneStyle.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed;
  end;
end;

function TcxHotZoneStyle.DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean): TRect;
begin
  { Dummy }
end;

procedure TcxHotZoneStyle.DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean);
begin
  { Dummy }
end;

function TcxHotZoneStyle.GetMinSize: TcxNaturalNumber;
begin
  Result := SplitterDefaultSize;
end;

function TcxHotZoneStyle.GetMaxSize: TcxNaturalNumber;
begin
  Result := SplitterDefaultSize;
end;

function TcxHotZoneStyle.CalculateHotZoneRect(const ABounds: TRect): TRect;
var
  ARect : TRect;
  AHotZoneRectSize, APos: Integer;
begin
  ARect := ABounds;
  if (SplitterDirection = cxsdLeftToRight) or (SplitterDirection = cxsdRightToLeft) then
  begin
    ARect.Right := ARect.Left + SplitterDefaultSize - 1;
    AHotZoneRectSize := ((ARect.Bottom - ARect.Top) * SizePercent) div 100;
    APos := ((ARect.Bottom - ARect.Top) div 2) - (AHotZoneRectSize div 2);
    Result := Rect(ARect.Left, APos, ARect.Right, APos + AHotZoneRectSize);
  end
  else
  begin
    ARect.Bottom := ARect.Top + SplitterDefaultSize - 1;
    AHotZoneRectSize := ((ARect.Right - ARect.Left) * SizePercent) div 100;
    APos := ((ARect.Right - ARect.Left) div 2) - (AHotZoneRectSize div 2);
    Result := Rect(APos, ARect.Top, APos + AHotZoneRectSize, ARect.Bottom);
  end;
  HotZoneRect := Result;
end;
{ TcxHotZoneStyle }

{ TcxMediaPlayer9Style }
constructor TcxMediaPlayer9Style.Create(AOwner: TcxCustomSplitter);
begin
  inherited Create(AOwner);
  FArrowColor := clWindowText;
  FArrowHighlightColor := clBlue;
  FLightColor := clWindow;
  FBorderColor := clBtnShadow;
  FShadowStartColor := $00F5E6CD;
  FShadowHighlightStartColor := $00AFF5C3;
end;

procedure TcxMediaPlayer9Style.Assign(Source: TPersistent);
begin
  if (Source is TcxMediaPlayer9Style) then
  begin
    inherited Assign(Source);
    with (Source as TcxMediaPlayer9Style) do
    begin
      Self.ArrowColor := ArrowColor;
      Self.ArrowHighlightColor := ArrowHighlightColor;
      Self.LightColor := LightColor;
      Self.BorderColor := BorderColor;
      Self.ShadowStartColor := ShadowStartColor;
      Self.ShadowHighlightStartColor := ShadowHighlightStartColor;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxMediaPlayer9Style.SetArrowColor(Value: TColor);
begin
  if FArrowColor <> Value then
  begin
    FArrowColor := Value;
    Changed;
  end;
end;

procedure TcxMediaPlayer9Style.SetArrowHighlightColor(Value: TColor);
begin
  if FArrowHighlightColor <> Value then
  begin
    FArrowHighlightColor := Value;
    Changed;
  end;
end;

procedure TcxMediaPlayer9Style.SetLightColor(Value: TColor);
begin
  if FLightColor <> Value then
  begin
    FLightColor := Value;
    Changed;
  end;
end;

procedure TcxMediaPlayer9Style.SetBorderColor(Value: TColor);
begin
  if FBorderColor <> Value then
  begin
    FBorderColor := Value;
    Changed;
  end;
end;

procedure TcxMediaPlayer9Style.SetShadowStartColor(Value: TColor);
begin
  if FShadowStartColor <> Value then
  begin
    FShadowStartColor := Value;
    Changed;
  end;
end;

procedure TcxMediaPlayer9Style.SetShadowHighlightStartColor(Value: TColor);
begin
  if FShadowHighlightStartColor <> Value then
  begin
    FShadowHighlightStartColor := Value;
    Changed;
  end;
end;

function TcxMediaPlayer9Style.DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean): TRect;
begin
  Result := CalculateHotZoneRect(ARect);
  ACanvas.Canvas.Lock;
  try
    ACanvas.Canvas.Brush.Color := Owner.Color;
    DrawBackground(ACanvas, HotZoneRect, AHighlighted, AClicked);
    DrawHotZoneArrow(ACanvas, FArrowRect, AHighlighted, AClicked, FArrowColor,
      FArrowHighlightColor, SplitterDirection);
  finally
    ACanvas.Canvas.Unlock;
  end;
end;

function TcxMediaPlayer9Style.CalculateHotZoneRect(const ABounds: TRect): TRect;
begin
  Result := inherited CalculateHotZoneRect(ABounds);
  if (SplitterDirection = cxsdLeftToRight) or (SplitterDirection = cxsdRightToLeft) then
    FArrowRect := Rect(Result.Left, Result.Top + (RectHeight(Result) div 2) - 7,
      Result.Left + SplitterDefaultSize - 1,
      Result.Top + (RectHeight(Result) div 2) + 7)
  else
    FArrowRect := Rect(Result.Left + (RectWidth(Result) div 2) - 7,
      Result.Top, Result.Left + (RectWidth(Result) div 2) + 7,
      Result.Top + SplitterDefaultSize - 1);
  HotZoneRect := Result;
end;

procedure TcxMediaPlayer9Style.DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean);
var
  FRect: TRect;
  FXDelta, FYDelta, FShadowStepDelta, FShadowStep: Integer;
  FLocalShadowColor: TColor;
begin
  FRect := ARect;
  case SplitterDirection of
    cxsdLeftToRight, cxsdRightToLeft: InflateRectEx(FRect, 0, 1, 0, -1);
    cxsdTopToBottom, cxsdBottomToTop: InflateRectEx(FRect, 1, 0, -1, 0);
  end;
  ACanvas.Pen.Color := BorderColor;
  ACanvas.Brush.Color := LightColor;
  ACanvas.FillRect(FRect);
  DrawBounds(ACanvas, FRect, BorderColor, BorderColor);
  if AHighlighted = False then
    FLocalShadowColor := ShadowStartColor
  else
    FLocalShadowColor := ShadowHighlightStartColor;
  if not AClicked then
  begin
    FXDelta := 4;
    FYDelta := 2;
    FShadowStep := 0;
    FShadowStepDelta := -30;
  end
  else
  begin
    FXDelta := 1;
    FYDelta := 0;
    FShadowStep := -60;
    FShadowStepDelta := 30;
  end;
  case SplitterDirection of
    cxsdLeftToRight, cxsdRightToLeft:
    begin
      DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Top + 1),
        Point(ARect.Right - 1, ARect.Top + 1));
      DrawCanvasLine(ACanvas.Canvas, BorderColor, Point(ARect.Left + 1, ARect.Top),
        Point(ARect.Right, ARect.Top));
      DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Bottom - 1),
        Point(ARect.Right - 1, ARect.Bottom - 1));
      DrawCanvasLine(ACanvas.Canvas, BorderColor, Point(ARect.Left + 1, ARect.Bottom),
        Point(ARect.Right, ARect.Bottom));
      DrawCanvasLine(ACanvas.Canvas, IncColor(FLocalShadowColor, FShadowStep, FShadowStep, FShadowStep),
        Point(ARect.Left + FXDelta, ARect.Top + FYDelta), Point(ARect.Left + FXDelta,
        ARect.Bottom + FYDelta - 2));
      Inc(FShadowStep, FShadowStepDelta);
      DrawCanvasLine(ACanvas.Canvas, IncColor(FLocalShadowColor, FShadowStep, FShadowStep, FShadowStep),
        Point(ARect.Left + FXDelta + 1, ARect.Top + FYDelta + 1),
        Point(ARect.Left + FXDelta + 1, ARect.Bottom + FYDelta - 2));
      Inc(FShadowStep, FShadowStepDelta);
      DrawCanvasLine(ACanvas.Canvas, IncColor(FLocalShadowColor, FShadowStep, FShadowStep, FShadowStep),
        Point(ARect.Left + FXDelta + 2, ARect.Top + FYDelta + 1),
        Point(ARect.Left + FXDelta + 2, ARect.Bottom + FYDelta - 3));
    end;
    cxsdTopToBottom, cxsdBottomToTop:
    begin
      DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Top + 2),
        Point(ARect.Left + 1, ARect.Bottom - 1));
      DrawCanvasLine(ACanvas.Canvas, BorderColor, Point(ARect.Left, ARect.Top + 1),
        Point(ARect.Left, ARect.Bottom));
      DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Right - 1, ARect.Top + 2),
        Point(ARect.Right - 1, ARect.Bottom - 1));
      DrawCanvasLine(ACanvas.Canvas, BorderColor, Point(ARect.Right, ARect.Top + 1),
        Point(ARect.Right, ARect.Bottom));
      DrawCanvasLine(ACanvas.Canvas, IncColor(FLocalShadowColor, FShadowStep, FShadowStep, FShadowStep),
        Point(ARect.Left + FYDelta, ARect.Top + FXDelta),
        Point(ARect.Right + FYDelta - 2, ARect.Top + FXDelta));
      Inc(FShadowStep, FShadowStepDelta);
      DrawCanvasLine(ACanvas.Canvas, IncColor(FLocalShadowColor, FShadowStep, FShadowStep, FShadowStep),
        Point(ARect.Left + FYDelta + 1, ARect.Top + FXDelta + 1),
        Point(ARect.Right + FYDelta - 2, ARect.Top + FXDelta + 1));
      Inc(FShadowStep, FShadowStepDelta);
      DrawCanvasLine(ACanvas.Canvas, IncColor(FLocalShadowColor, FShadowStep, FShadowStep, FShadowStep),
        Point(ARect.Left + FYDelta + 1, ARect.Top + FXDelta + 2),
        Point(ARect.Right + FYDelta - 3, ARect.Top + FXDelta + 2));
    end;
  end;
  ACanvas.Pen.Color := FOwner.Color;
  ACanvas.Brush.Color := FOwner.Color;
end;
{ TcxMediaPlayer9Style }

{ TcxMediaPlayer8Style }
constructor TcxMediaPlayer8Style.Create(AOwner: TcxCustomSplitter);
begin
  inherited Create(AOwner);
  FArrowColor := clWindowText;
  FArrowHighlightColor := clWindow;
  FLightColor := clWindow;
  FShadowColor := clBtnShadow;
end;

procedure TcxMediaPlayer8Style.Assign(Source: TPersistent);
begin
  if (Source is TcxMediaPlayer8Style) then
  begin
    inherited Assign(Source);
    with (Source as TcxMediaPlayer8Style) do
    begin
      Self.ShadowColor := ShadowColor;
      Self.LightColor := LightColor;
      Self.ArrowColor := ArrowColor;
      Self.ArrowHighlightColor := ArrowHighlightColor;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxMediaPlayer8Style.SetShadowColor(Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    Changed;
  end;
end;

procedure TcxMediaPlayer8Style.SetLightColor(Value: TColor);
begin
  if FLightColor <> Value then
  begin
    FLightColor := Value;
    Changed;
  end;
end;

procedure TcxMediaPlayer8Style.SetArrowColor(Value: TColor);
begin
  if FArrowColor <> Value then
  begin
    FArrowColor := Value;
    Changed;
  end;
end;

procedure TcxMediaPlayer8Style.SetArrowHighlightColor(Value: TColor);
begin
  if FArrowHighlightColor <> Value then
  begin
    FArrowHighlightColor := Value;
    Changed;
  end;
end;

function TcxMediaPlayer8Style.DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean): TRect;
begin
  Result := CalculateHotZoneRect(ARect);
  ACanvas.Canvas.Lock;
  try
    ACanvas.Canvas.Brush.Color := Owner.Color;
    DrawBackground(ACanvas, HotZoneRect, AHighlighted, AClicked);
    DrawSplitterDots(ACanvas, FLTPointsRect, AClicked, False, FLightColor,
      FShadowColor, SplitterDirection, 3, 3);
    DrawSplitterDots(ACanvas, FRBPointsRect, AClicked, True, FLightColor,
      FShadowColor, SplitterDirection, 3, 3);
    DrawArrowRect(ACanvas, FArrowRect, AHighlighted, AClicked);
    DrawHotZoneArrow(ACanvas, FArrowRect, AHighlighted, AClicked, FArrowColor,
      FArrowHighlightColor, SplitterDirection);
  finally
    ACanvas.Canvas.Unlock;
  end;
end;

function TcxMediaPlayer8Style.CalculateHotZoneRect(const ABounds: TRect): TRect;
var
  FRect : TRect;
  FHotZoneRectSize, FPos: Integer;
  FHotZonePointsRectHeight, FHotZoneRoundRectHeight: Integer;
begin
  FRect := ABounds;
  if (SplitterDirection = cxsdLeftToRight) or (SplitterDirection = cxsdRightToLeft) then
  begin
    FRect.Right := FRect.Left + SplitterDefaultSize - 1;
    FHotZoneRectSize := ((FRect.Bottom - FRect.Top) * SizePercent) div 100;
    FPos := ((FRect.Bottom - FRect.Top) div 2) - (FHotZoneRectSize div 2);
    HotZoneRect := Rect(FRect.Left, FPos, FRect.Right, FPos + FHotZoneRectSize);
  end
  else
  begin
    FRect.Bottom := FRect.Top + SplitterDefaultSize - 1;
    FHotZoneRectSize := ((FRect.Right - FRect.Left) * SizePercent) div 100;
    FPos := ((FRect.Right - FRect.Left) div 2) - (FHotZoneRectSize div 2);
    HotZoneRect := Rect(FPos, FRect.Top, FPos + FHotZoneRectSize, FRect.Bottom);
  end;

  FHotZoneRoundRectHeight := 4;
  FHotZonePointsRectHeight := (FHotZoneRectSize - (FHotZoneRoundRectHeight * 2) - 19) div 2;
  if (SplitterDirection = cxsdLeftToRight) or (SplitterDirection = cxsdRightToLeft) then
  begin
    FLTPointsRect := Rect(HotZoneRect.Left, HotZoneRect.Top + FHotZoneRoundRectHeight,
      HotZoneRect.Left + HotZoneRect.Right - HotZoneRect.Left,
      HotZoneRect.Top + FHotZoneRoundRectHeight + FHotZonePointsRectHeight);
    FRBPointsRect := Rect(HotZoneRect.Left, HotZoneRect.Bottom - FHotZoneRoundRectHeight - FHotZonePointsRectHeight,
      HotZoneRect.Left + HotZoneRect.Right - HotZoneRect.Left,
      HotZoneRect.Bottom - FHotZoneRoundRectHeight - FHotZonePointsRectHeight + FHotZonePointsRectHeight);
    FArrowRect := Rect(HotZoneRect.Left, HotZoneRect.Top + FHotZonePointsRectHeight + FHotZoneRoundRectHeight,
      HotZoneRect.Left + SplitterDefaultSize - 1,
      HotZoneRect.Top + FHotZonePointsRectHeight + FHotZoneRoundRectHeight + 19);
  end
  else
  begin
    FLTPointsRect := Rect(HotZoneRect.Left + FHotZoneRoundRectHeight,
      HotZoneRect.Top, HotZoneRect.Left + FHotZoneRoundRectHeight + FHotZonePointsRectHeight,
      HotZoneRect.Bottom);
    FRBPointsRect := Rect(HotZoneRect.Right - FHotZoneRoundRectHeight - FHotZonePointsRectHeight,
      HotZoneRect.Top, HotZoneRect.Right - FHotZoneRoundRectHeight - FHotZonePointsRectHeight + FHotZonePointsRectHeight,
      HotZoneRect.Bottom);
    FArrowRect := Rect(HotZoneRect.Left + FHotZonePointsRectHeight + FHotZoneRoundRectHeight,
      HotZoneRect.Top, HotZoneRect.Left + FHotZonePointsRectHeight + FHotZoneRoundRectHeight + 19,
      HotZoneRect.Top + SplitterDefaultSize - 1);
  end;
  Result := HotZoneRect;
end;

procedure TcxMediaPlayer8Style.DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean);
begin
  ACanvas.Pen.Color := FOwner.Color;
  ACanvas.Brush.Color := FOwner.Color;
  ACanvas.FillRect(ARect);
  case SplitterDirection of
    cxsdLeftToRight:
    begin
      {Shadow border}
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left, ARect.Bottom - 4),
        Point(ARect.Left, ARect.Top + 3));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right, ARect.Bottom),
        Point(ARect.Right, ARect.Top));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 1, ARect.Bottom - 2),
        Point(ARect.Left + 1, ARect.Bottom - 4));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 1, ARect.Top + 2),
        Point(ARect.Left + 1, ARect.Top + 4));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 2, ARect.Bottom - 1),
        Point(ARect.Left + 4, ARect.Bottom - 1));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 2, ARect.Top + 1),
        Point(ARect.Left + 4, ARect.Top + 1));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 4, ARect.Bottom),
        Point(ARect.Right, ARect.Bottom));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 4, ARect.Top),
        Point(ARect.Right + 1, ARect.Top));
      {Light border}
      if AClicked = False then
      begin
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Bottom - 4),
          Point(ARect.Left + 1, ARect.Top + 3));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Top + 2),
          Point(ARect.Left + 2, ARect.Top + 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Top + 2),
          Point(ARect.Left + 4, ARect.Top + 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 4, ARect.Top + 1),
          Point(ARect.Right, ARect.Top + 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Bottom - 2),
          Point(ARect.Left + 2, ARect.Bottom - 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Bottom - 2),
          Point(ARect.Left + 4, ARect.Bottom - 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 4, ARect.Bottom - 1),
          Point(ARect.Left + 5, ARect.Bottom - 1));
      end
      else
      begin
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Right - 1, ARect.Bottom - 1),
          Point(ARect.Right - 1, ARect.Top + 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Bottom - 2),
          Point(ARect.Left + 4, ARect.Bottom - 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 4, ARect.Bottom - 1),
          Point(ARect.Left + 7, ARect.Bottom - 1));
      end;
    end;
    cxsdRightToLeft:
    begin
      {Shadow border}
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right, ARect.Bottom - 4),
        Point(ARect.Right, ARect.Top + 3));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left, ARect.Bottom),
        Point(ARect.Left, ARect.Top));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 1, ARect.Bottom - 2),
        Point(ARect.Right - 1, ARect.Bottom - 4));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 1, ARect.Top + 2),
        Point(ARect.Right - 1, ARect.Top + 4));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 2, ARect.Bottom - 1),
        Point(ARect.Right - 4, ARect.Bottom - 1));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 2, ARect.Top + 1),
        Point(ARect.Right - 4, ARect.Top + 1));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 4, ARect.Bottom),
        Point(ARect.Left, ARect.Bottom));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 3, ARect.Top),
        Point(ARect.Left - 1, ARect.Top));
      {Light border}
      if AClicked = False then
      begin
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Bottom - 1),
          Point(ARect.Left + 1, ARect.Top + 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Top + 1),
          Point(ARect.Left + 4, ARect.Top + 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 4, ARect.Top + 2),
          Point(ARect.Left + 6, ARect.Top + 2));
      end
      else
      begin
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 3, ARect.Top + 1),
          Point(ARect.Left + 4, ARect.Top + 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 4, ARect.Top + 2),
          Point(ARect.Left + 6, ARect.Top + 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 5, ARect.Top + 2),
          Point(ARect.Left + 5, ARect.Top + 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 6, ARect.Top + 4),
          Point(ARect.Left + 6, ARect.Bottom - 3));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Bottom - 1),
          Point(ARect.Left + 4, ARect.Bottom - 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 4, ARect.Bottom - 2),
          Point(ARect.Left + 6, ARect.Bottom - 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 5, ARect.Bottom - 2),
          Point(ARect.Left + 5, ARect.Bottom - 4));
      end;
    end;
    cxsdTopToBottom:
    begin
      {Shadow border}
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 4, ARect.Top),
        Point(ARect.Right - 3, ARect.Top));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left, ARect.Bottom),
        Point(ARect.Right, ARect.Bottom));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 2, ARect.Top + 1),
        Point(ARect.Left + 4, ARect.Top + 1));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 2, ARect.Top + 1),
        Point(ARect.Right - 4, ARect.Top + 1 ));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 1, ARect.Top + 2),
        Point(ARect.Left + 1, ARect.Top + 4));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 1, ARect.Top + 2),
        Point(ARect.Right - 1,ARect.Top + 4));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left, ARect.Top + 4),
        Point(ARect.Left, ARect.Bottom));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right, ARect.Top + 4),
        Point(ARect.Right, ARect.Bottom + 1));
      {Light border}
      if AClicked = False then
      begin
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 4, ARect.Top + 1),
          Point(ARect.Right - 3, ARect.Top + 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Right - 2, ARect.Top + 2),
          Point(ARect.Right - 4, ARect.Top + 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Right - 2, ARect.Top + 2),
          Point(ARect.Right - 2, ARect.Top + 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Right - 1, ARect.Top + 4),
          Point(ARect.Right - 1, ARect.Bottom));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Top + 2),
          Point(ARect.Left + 4, ARect.Top + 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Top + 2),
          Point(ARect.Left + 2, ARect.Top + 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Top + 4),
          Point(ARect.Left + 1, ARect.Top + 5));
      end
      else
      begin
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Bottom - 1),
          Point(ARect.Right - 1, ARect.Bottom - 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Top + 2),
          Point(ARect.Left + 2, ARect.Top + 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Top + 4),
          Point(ARect.Left + 1, ARect.Top + 7));
      end;
    end;
    cxsdBottomToTop:
    begin
      {Shadow border}
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 4, ARect.Bottom),
        Point(ARect.Right - 3, ARect.Bottom));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left, ARect.Top),
        Point(ARect.Right, ARect.Top));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 2, ARect.Bottom - 1),
        Point(ARect.Left + 4, ARect.Bottom - 1));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 2, ARect.Bottom - 1),
        Point(ARect.Right - 4, ARect.Bottom - 1 ));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left + 1, ARect.Bottom - 2),
        Point(ARect.Left + 1, ARect.Bottom - 4));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right - 1, ARect.Bottom - 2),
        Point(ARect.Right - 1,ARect.Bottom - 4));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Left, ARect.Bottom - 4),
        Point(ARect.Left, ARect.Top));
      DrawCanvasLine(ACanvas.Canvas, ShadowColor, Point(ARect.Right, ARect.Bottom - 3),
        Point(ARect.Right, ARect.Top - 1));
      {Light border}
      if AClicked = False then
      begin
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Top + 1),
          Point(ARect.Right - 1, ARect.Top + 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Bottom - 2),
          Point(ARect.Left + 2, ARect.Bottom - 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Bottom - 4),
          Point(ARect.Left + 1, ARect.Bottom - 7));
      end
      else
      begin
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 4, ARect.Bottom - 1),
          Point(ARect.Right - 3, ARect.Bottom - 1));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Right - 2, ARect.Bottom - 2),
          Point(ARect.Right - 4, ARect.Bottom - 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Right - 2, ARect.Bottom - 2),
          Point(ARect.Right - 2, ARect.Bottom - 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Right - 1, ARect.Bottom - 4),
          Point(ARect.Right - 1, ARect.Top));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Bottom - 2),
          Point(ARect.Left + 4, ARect.Bottom - 2));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 2, ARect.Bottom - 2),
          Point(ARect.Left + 2, ARect.Bottom - 4));
        DrawCanvasLine(ACanvas.Canvas, LightColor, Point(ARect.Left + 1, ARect.Bottom - 4),
          Point(ARect.Left + 1, ARect.Bottom - 5));
      end;
    end;
  end;
end;

procedure TcxMediaPlayer8Style.DrawArrowRect(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean);
begin
  ACanvas.Brush.Color := FOwner.Color;
  ACanvas.FillRect(ARect);
  if AClicked = False then
    DrawBounds(ACanvas, ARect, FShadowColor, FLightColor)
  else
    DrawBounds(ACanvas, ARect, FLightColor, FShadowColor);
end;
{ TcxMediaPlayer8Style }

{ TcxXPTaskBarStyle }
constructor TcxXPTaskBarStyle.Create(AOwner: TcxCustomSplitter);
begin
  inherited Create(AOwner);
  FLightColor := clWindow;
  FShadowColor := clBtnShadow;
end;

procedure TcxXPTaskBarStyle.Assign(Source: TPersistent);
begin
  if (Source is TcxXPTaskBarStyle) then
  begin
    inherited Assign(Source);
    with (Source as TcxXPTaskBarStyle) do
    begin
      Self.LightColor := LightColor;
      Self.ShadowColor := ShadowColor;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxXPTaskBarStyle.SetLightColor(Value: TColor);
begin
  if FLightColor <> Value then
  begin
    FLightColor := Value;
    Changed;
  end;
end;

procedure TcxXPTaskBarStyle.SetShadowColor(Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    Changed;
  end;
end;

function TcxXPTaskBarStyle.DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean): TRect;
begin
  Result := CalculateHotZoneRect(ARect);
  ACanvas.Canvas.Lock;
  try
    ACanvas.Canvas.Brush.Color := Owner.Color;
    DrawBackground(ACanvas, HotZoneRect, AHighlighted, AClicked);
    DrawSplitterDots(ACanvas, FLTPointsRect, not AClicked, True, FLightColor,
      FShadowColor, SplitterDirection, 4, 0);
    DrawSplitterDots(ACanvas, FRBPointsRect, not AClicked, True, FLightColor,
      FShadowColor, SplitterDirection, 4, 0);
  finally
    ACanvas.Canvas.Unlock;
  end;
end;

function TcxXPTaskBarStyle.CalculateHotZoneRect(const ABounds: TRect): TRect;
var
  FRect : TRect;
  FHotZoneRectSize, FPos: Integer;
begin
  Result := inherited CalculateHotZoneRect(ABounds);

  FRect := ABounds;
  case SplitterDirection of
    cxsdLeftToRight, cxsdRightToLeft:
    begin
      FRect.Right := FRect.Left + SplitterDefaultSize - 1;
      FHotZoneRectSize := ((FRect.Bottom - FRect.Top) * SizePercent) div 100;
      FPos := ((FRect.Bottom - FRect.Top) div 2) - (FHotZoneRectSize div 2);
      Result := Rect(FRect.Left, FPos, FRect.Right, FPos + FHotZoneRectSize);
      FLTPointsRect := Rect(Result.Left + 1, Result.Top,
        (Result.Right div 2), Result.Bottom);
      FRBPointsRect := Rect((Result.Right div 2) + 1, Result.Top + 3,
        Result.Right, Result.Bottom);
    end;
    else
    begin
      FRect.Bottom := FRect.Top + SplitterDefaultSize - 1;
      FHotZoneRectSize := ((FRect.Right - FRect.Left) * SizePercent) div 100;
      FPos := ((FRect.Right - FRect.Left) div 2) - (FHotZoneRectSize div 2);
      Result := Rect(FPos, FRect.Top, FPos + FHotZoneRectSize, FRect.Bottom);
      FLTPointsRect := Rect(Result.Left, Result.Top + 1,
        Result.Right, Result.Bottom div 2);
      FRBPointsRect := Rect(Result.Left + 3, (Result.Bottom div 2) + 1,
        Result.Right, Result.Bottom);
    end;
  end;
  HotZoneRect := Result;
end;

procedure TcxXPTaskBarStyle.DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean);
begin
  if AreVisualStylesAvailable and Owner.NativeBackground then
    cxDrawThemeParentBackground(Owner, ACanvas, ARect)
  else
  begin
    ACanvas.Brush.Color := Owner.Color;
    ACanvas.FillRect(ARect);
  end;
end;
{ TcxXPTaskBarStyle }

{ TcxSimpleStyle }
constructor TcxSimpleStyle.Create(AOwner: TcxCustomSplitter);
begin
  inherited Create(AOwner);
  FLightColor := clWindow;
  FShadowColor := clBtnShadow;
  FArrowColor := clWindowText;
  FArrowHighlightColor := clWindow;
  FDotsColor := clHighlight;
  FDotsShadowColor := clWindow;
end;

procedure TcxSimpleStyle.Assign(Source: TPersistent);
begin
  if (Source is TcxSimpleStyle) then
  begin
    inherited Assign(Source);
    with (Source as TcxSimpleStyle) do
    begin
      Self.LightColor := LightColor;
      Self.ShadowColor := ShadowColor;
      Self.ArrowColor := ArrowColor;
      Self.ArrowHighlightColor := ArrowHighlightColor;
      Self.DotsColor := DotsColor;
      Self.DotsShadowColor := DotsShadowColor;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxSimpleStyle.SetLightColor(Value: TColor);
begin
  if FLightColor <> Value then
  begin
    FLightColor := Value;
    Changed;
  end;
end;

procedure TcxSimpleStyle.SetShadowColor(Value: TColor);
begin
  if FShadowColor <> Value then
  begin
    FShadowColor := Value;
    Changed;
  end;
end;

procedure TcxSimpleStyle.SetArrowColor(Value: TColor);
begin
  if FArrowColor <> Value then
  begin
    FArrowColor := Value;
    Changed;
  end;
end;

procedure TcxSimpleStyle.SetArrowHighlightColor(Value: TColor);
begin
  if FArrowHighlightColor <> Value then
  begin
    FArrowHighlightColor := Value;
    Changed;
  end;
end;

procedure TcxSimpleStyle.SetDotsColor(Value: TColor);
begin
  if FDotsColor <> Value then
  begin
    FDotsColor := Value;
    Changed;
  end;
end;

procedure TcxSimpleStyle.SetDotsShadowColor(Value: TColor);
begin
  if FDotsShadowColor <> Value then
  begin
    FDotsShadowColor := Value;
    Changed;
  end;
end;

function TcxSimpleStyle.DrawHotZone(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean): TRect;
begin
  Result := CalculateHotZoneRect(ARect);
  ACanvas.Canvas.Lock;
  try
    ACanvas.Canvas.Brush.Color := Owner.Color;
    DrawBackground(ACanvas, HotZoneRect, AHighlighted, AClicked);
    DrawHotZoneArrow(ACanvas, FLTArrowRect, AHighlighted, AClicked, FArrowColor,
      FArrowHighlightColor, SplitterDirection);
    DrawHotZoneArrow(ACanvas, FRBArrowRect, AHighlighted, AClicked, FArrowColor,
      FArrowHighlightColor, SplitterDirection);
  finally
    ACanvas.Canvas.Unlock;
  end;
end;

function TcxSimpleStyle.CalculateHotZoneRect(const ABounds: TRect): TRect;
begin
  Result := inherited CalculateHotZoneRect(ABounds);
  case SplitterDirection of
    cxsdLeftToRight, cxsdRightToLeft:
    begin
      FLTArrowRect := Rect(Result.Left, Result.Top + 5, Result.Right, Result.Top + 12);
      FRBArrowRect := Rect(Result.Left, Result.Bottom - 12, Result.Right, Result.Bottom - 5);
    end;
    else
    begin
      FLTArrowRect := Rect(Result.Left + 5, Result.Top, Result.Left + 12, Result.Bottom);
      FRBArrowRect := Rect(Result.Right - 12, Result.Top, Result.Right - 5, Result.Bottom);
    end;
  end;
  HotZoneRect := Result;
end;

procedure TcxSimpleStyle.DrawBackground(ACanvas: TcxCanvas; const ARect: TRect;
  const AHighlighted, AClicked: Boolean);
var
  MiddlePos, I_count : Integer;
  FRect: TRect;
begin
  with ACanvas, ARect do
  begin
    FRect := DrawBounds(ACanvas, HotZoneRect, ShadowColor, ShadowColor);
    Brush.Color := Owner.Color;
    FillRect(FRect);
    {Draw Border}
    if AClicked = False then
      DrawBounds(ACanvas, FRect, LightColor, Owner.Color)
    else
      DrawBounds(ACanvas, FRect, Owner.Color, LightColor);

    Pen.Color := clHighlight;
    Brush.Color := clHighlight;
    if (SplitterDirection = cxsdTopToBottom) or (SplitterDirection = cxsdBottomToTop) then
    begin
      MiddlePos:=Top + (Bottom - Top) div 2;
      for I_count := 0 to ((Right - Left - 32) div 3) do
      begin
        if AClicked = False then
        begin
          Pixels[Left + 15 + I_count * 3, MiddlePos] := DotsShadowColor;
          Pixels[Left + 16 + I_count * 3, MiddlePos + 1] := DotsColor;
        end
        else
        begin
          Pixels[Left + 15 + I_count * 3, MiddlePos] := DotsColor;
          Pixels[Left + 16 + I_count * 3, MiddlePos + 1] := DotsShadowColor;
        end;
      end;
    end
    else
    begin
      MiddlePos := Left + (Right - Left) div 2;
      for I_count := 0 to ((Bottom - Top - 32) div 3) do
      begin
        if AClicked = False then
        begin
          Pixels[MiddlePos, Top + 15 + I_count * 3] := DotsShadowColor;
          Pixels[MiddlePos + 1, Top + 16 + I_count * 3] := DotsColor;
        end
        else
        begin
          Pixels[MiddlePos, Top + 15 + I_count * 3] := DotsColor;
          Pixels[MiddlePos + 1, Top + 16 + I_count * 3] := DotsShadowColor;
        end;
      end;
    end;
  end;
end;
{ TcxSimpleStyle }

{TdxSplitterDragImage}

procedure TdxSplitterDragImage.Paint;
begin
  Canvas.Canvas.FillRect(ClientRect);
end;

{ TcxCustomSplitter }
constructor TcxCustomSplitter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csSetCaption];
  FState := ssOpened;
  FResizeUpdate := False;
  FSplitterState := sstNormal;
  FMouseStates := [];
  FAllowHotZoneDrag := True;
  FDragThreshold := 3;
  FAutoSnap := False;
  FResizeIgnoreSnap := False; //deprecated
  FAutoPosition := True;
  FMinSize := 30;
  FPositionAfterOpen := 30;
  FNativeBackground := True;
  FInvertDirection := False;
  FNewSize := 30;
  FOldSize := -1;
  FPositionBeforeClose := FMinSize;
  FHotZone := nil;
  FHotZoneClickPoint := Point(-1, -1);
  FLastPatternDrawPosition := -1;
  FDrawBitmap := TBitmap.Create;
  FDrawCanvas := TcxCanvas.Create(FDrawBitmap.Canvas);
  BorderStyle := cxcbsNone;
  Align := alNone;
  SetBounds(0, 0, SplitterDefaultSize, 100 {must be >= 10});
  SetAlignSplitter(salLeft);
  TabStop := False;
end;

destructor TcxCustomSplitter.Destroy;
begin
  FControl := nil;
  DestroyHotZone;
  if Assigned(FBrush) then FreeAndNil(FBrush);
  if Assigned(FDrawCanvas) then FreeAndNil(FDrawCanvas);
  if Assigned(FDrawBitmap) then FreeAndNil(FDrawBitmap);
  inherited Destroy;
end;

procedure TcxCustomSplitter.Loaded;
begin
  inherited Loaded;
  if FControl = nil then
    FControl := FindControl;
  SetAlignSplitter(FAlignSplitter);
end;

procedure TcxCustomSplitter.Notification(AComponent: TComponent; Operation: Toperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FControl <> nil) and
    (AComponent = FControl) then
    FControl := nil;
end;

procedure TcxCustomSplitter.SetHotZoneStyleClass(const Value: TcxHotZoneStyleClass);
var
  ASavedHotZone: TcxHotZoneStyle;
begin
  if FHotZoneStyleClass <> Value then
  begin
    ASavedHotZone := nil;
    try
      if Assigned(FHotZone) then
      begin
        ASavedHotZone := TcxHotZoneStyle.Create(Self);
        ASavedHotZone.Assign(FHotZone);
      end;
      DestroyHotZone;
      FHotZoneStyleClass := Value;
      CreateHotZone;
      if Assigned(FHotZone) and Assigned(ASavedHotZone) then
        FHotZone.Assign(ASavedHotZone);
    finally
      if Assigned(ASavedHotZone) then
        FreeAndNil(ASavedHotZone);
    end;
    NormalizeSplitterSize;
  end;
end;

function TcxCustomSplitter.GetHotZoneClassName: string;
begin
  if FHotZone = nil then
    Result := ''
  else
    Result := FHotZone.ClassName;
end;

procedure TcxCustomSplitter.SetHotZoneClassName(Value: string);
begin
  HotZoneStyleClass := TcxHotZoneStyleClass(GetRegisteredHotZoneStyles.FindByClassName(Value));
end;

procedure TcxCustomSplitter.CreateHotZone;
begin
  if FHotZoneStyleClass <> nil then
    FHotZone := FHotZoneStyleClass.Create(Self);
  Invalidate;
end;

procedure TcxCustomSplitter.DestroyHotZone;
begin
  if Assigned(FHotZone) then FreeAndNil(FHotZone);
end;

procedure TcxCustomSplitter.SetHotZone(Value: TcxHotZoneStyle);
begin
  FHotZone := Value;
  NormalizeSplitterSize;
  Invalidate;
end;

procedure TcxCustomSplitter.SetNativeBackground(Value: Boolean);
begin
  if FNativeBackground <> Value then
  begin
    FNativeBackground := Value;
    Invalidate;
  end;
end;

procedure TcxCustomSplitter.SetDefaultStates;
begin
  FMouseStates := [];
  FSplitterState := sstNormal;
end;

function TcxCustomSplitter.GetMaxControlSize: Integer;
begin
  Result := 0;
  if FControl = nil then
    Exit;
  case AlignSplitter of
    salBottom, salTop:
      Result := FControl.Constraints.MaxHeight;
    salLeft, salRight:
      Result := FControl.Constraints.MaxWidth;
  end;
end;

function TcxCustomSplitter.IsAllControlHotZoneStyle: Boolean;
begin
  Result := LookAndFeel.SkinPainter <> nil;
end;

function TcxCustomSplitter.GetDragImageTopLeft: TPoint;
begin
  Result := Point(Left, Top);
  if Align in [alLeft, alRight] then
    Result.X := Left + FSplit + 1
  else
    Result.Y := Top + FSplit + 1;
  Result := Parent.ClientToScreen(Result);
end;

procedure TcxCustomSplitter.InitDragImage;
begin
  if not ResizeUpdate then
  begin
    FDragImage := TdxSplitterDragImage.Create;
    FDragImage.Canvas.Brush.Bitmap := AllocPatternBitmap(clBlack, clWhite);
    FDragImage.SetBounds(GetDragImageTopLeft.X, GetDragImageTopLeft.Y,
      Width - 1, Height - 1);
    FDragImage.Show;
  end;
end;

procedure TcxCustomSplitter.MoveDragImage;
begin
  FDragImage.MoveTo(GetDragImageTopLeft);
end;

procedure TcxCustomSplitter.ReleaseDragImage;
begin
  FreeAndNil(FDragImage);
end;

procedure TcxCustomSplitter.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if smsInHotZone in FMouseStates then
    Invalidate;
  Exclude(FMouseStates, smsInHotZone);
end;

procedure TcxCustomSplitter.SetAlignSplitter(Value: TcxSplitterAlign);
begin
  FAlignSplitter := Value;
  if Assigned(FHotZone) then
    NormalizeSplitterSize;
  case FAlignSplitter of
    salBottom: Align := alBottom;
    salLeft: Align := alLeft;
    salRight: Align := alRight;
    salTop: Align := alTop;
  end;
end;

function TcxCustomSplitter.GetSplitterMinSize: TcxNaturalNumber;
var
  AHorizontal: Boolean;
begin
  if LookAndFeel.SkinPainter <> nil then
  begin
    AHorizontal := AlignSplitter in [salBottom, salTop];
    if AHorizontal then
      Result := LookAndFeel.SkinPainter.GetSplitterSize(AHorizontal).cy
    else
      Result := LookAndFeel.SkinPainter.GetSplitterSize(AHorizontal).cx;
  end
  else
    if Assigned(FHotZone) then
      Result := FHotZone.GetMinSize
    else
      Result := SplitterDefaultSize;
end;

function TcxCustomSplitter.GetSplitterMaxSize: TcxNaturalNumber;
var
  AHorizontal: Boolean;
begin
  if LookAndFeel.SkinPainter <> nil then
  begin
    AHorizontal := AlignSplitter in [salBottom, salTop];
    if AHorizontal then
      Result := LookAndFeel.SkinPainter.GetSplitterSize(AHorizontal).cy
    else
      Result := LookAndFeel.SkinPainter.GetSplitterSize(AHorizontal).cx;
  end
  else
    if Assigned(FHotZone) then
      Result := FHotZone.GetMaxSize
    else
      Result := SplitterDefaultSize;
end;

procedure TcxCustomSplitter.NormalizeSplitterSize;

  procedure AdjustSplitterSize;
  begin
    case FAlignSplitter of
      salBottom, salTop: Height := GetSplitterMinSize;
      salLeft, salRight: Width := GetSplitterMinSize;
    end;
    case FAlignSplitter of
      salBottom, salTop:begin
        Constraints.MinWidth := 0;
        Constraints.MaxWidth := 0;
        Constraints.MinHeight := GetSplitterMinSize;
        Constraints.MaxHeight := GetSplitterMaxSize;
        if (Height < Constraints.MinHeight) or (Height > Constraints.MaxHeight) then
          Height := Constraints.MinHeight;
      end;
      salLeft, salRight:begin
        Constraints.MinWidth := GetSplitterMinSize;
        Constraints.MaxWidth := GetSplitterMaxSize;
        Constraints.MinHeight := 0;
        Constraints.MaxHeight := 0;
        if (Width < Constraints.MinWidth) or (Width > Constraints.MaxWidth) then
          Width := Constraints.MinWidth;
      end;
    end;
  end;

begin
  if not Assigned(FHotZone) and (LookAndFeel.SkinPainter = nil) then
  begin
    Constraints.MinWidth := 0;
    Constraints.MaxWidth := 0;
    Constraints.MinHeight := 0;
    Constraints.MaxHeight := 0;
  end
  else
    AdjustSplitterSize;
end;

function TcxCustomSplitter.CalculateSplitterDirection: TcxSplitterDirection;
begin
  Result := Low(TcxSplitterDirection);
  case FAlignSplitter of
    salTop:
      if ((State = ssOpened) and (not InvertDirection)) or
        ((State = ssClosed) and (InvertDirection)) then
        Result := cxsdBottomToTop
      else
        Result := cxsdTopToBottom;
    salBottom:
      if ((State = ssOpened) and (not InvertDirection)) or
        ((State = ssClosed) and (InvertDirection)) then
        Result := cxsdTopToBottom
      else
        Result := cxsdBottomToTop;
    salLeft:
      if ((State = ssOpened) and (not InvertDirection)) or
        ((State = ssClosed) and (InvertDirection)) then
        Result := cxsdRightToLeft
      else
        Result := cxsdLeftToRight;
    salRight:
      if ((State = ssOpened) and (not InvertDirection)) or
        ((State = ssClosed) and (InvertDirection)) then
        Result := cxsdLeftToRight
      else
        Result := cxsdRightToLeft;
  end;
end;

procedure TcxCustomSplitter.UpdateMouseStates(X, Y: Integer);
begin
  if IsPointInHotZone(X, Y) then
    Include(FMouseStates, smsInHotZone)
  else
    Exclude(FMouseStates, smsInHotZone);
end;

procedure TcxCustomSplitter.SetSplitterState(Value: TcxSplitterState);
begin
  if FState <> Value then
  begin
    if Assigned(FControl) then
    begin
      case Value of
        ssOpened: OpenSplitter;
        ssClosed: CloseSplitter;
      end;
    end;
    FState := Value;
  end;
end;

procedure TcxCustomSplitter.SetAllowHotZoneDrag(Value: Boolean);
begin
  if FAllowHotZoneDrag <> Value then
  begin
    StopSizing;
    FAllowHotZoneDrag := Value;
  end;
end;

procedure TcxCustomSplitter.SetInvertDirection(Value: Boolean);
begin
  if FInvertDirection <> Value then
  begin
    FInvertDirection := Value;
    StopSizing;
    Invalidate;
  end;
end;

function TcxCustomSplitter.FindControl: TControl;
var
  P: TPoint;
  I_count: Integer;
  R, FRReligned: TRect;
begin
  Result := nil;
  P := Point(Left, Top);
  case Align of
    alLeft: Dec(P.X);
    alRight: Inc(P.X, Width);
    alTop: Dec(P.Y);
    alBottom: Inc(P.Y, Height);
    else Exit;
  end;
  for I_count:=0 to Parent.ControlCount-1 do
  begin
    Result := Parent.Controls[I_count];
    if (Result.Visible) and (Result.Enabled) then
    begin
      R := Result.BoundsRect;
      if (R.Right - R.Left) = 0 then
        if (Align in [alTop, alLeft]) then
          Dec(R.Left)
        else
          Inc(R.Right);
      if (R.Bottom - R.Top) = 0 then
        if (Align in [alTop, alLeft]) then
          Dec(R.Top)
        else
          Inc(R.Bottom);
      if PtInRect(R, P) = True then Exit
      else
      begin
         if (Result.Align = Self.Align) then
         begin
           FRReligned := Result.BoundsRect;
           case Result.Align of
             alLeft: if (FRReligned.Right = FRReligned.Left) and
               (FRReligned.Left = Self.Width) then Exit;
             alRight: if (FRReligned.Right = FRReligned.Left) and
               (FRReligned.Right = Self.Left) then Exit;
             alTop: if (FRReligned.Bottom = FRReligned.Top) and
               (FRReligned.Top = Self.Height) then Exit;
             alBottom: if (FRReligned.Bottom = FRReligned.Top) and
               (FRReligned.Bottom = Self.Top) then Exit;
           end;
         end;
      end;
    end;
  end;
  Result := nil;
end;

procedure TcxCustomSplitter.HotZoneStyleChanged;
begin
  Invalidate;
end;

procedure TcxCustomSplitter.Paint;
var
  R: TRect;
begin
  R := ClientRect;
  FDrawBitmap.Width := RectWidth(R);
  FDrawBitmap.Height := RectHeight(R);
  FDrawBitmap.Canvas.Brush.Color := Color;
  if LookAndFeel.SkinPainter = nil then
  begin
    if AreVisualStylesAvailable and NativeBackground then
    begin
      cxDrawThemeParentBackground(Self, Canvas, R);
      BitBlt(FDrawBitmap.Canvas.Handle, 0, 0, RectWidth(R), RectHeight(R),
        Canvas.Handle, 0, 0, SRCCOPY);
    end
    else
      FDrawBitmap.Canvas.FillRect(R);
    if (HotZone <> nil) and HotZone.Visible then
      DrawHotZone;
  end else
  begin
    cxDrawTransparentControlBackground(Self, FDrawCanvas, R);
    LookAndFeel.SkinPainter.DrawSplitter(FDrawCanvas, R, smsInHotZone in FMouseStates,
      (smsClicked in FMouseStates) and (smsInHotZone in FMouseStates),
       AlignSplitter in [salBottom, salTop]);
  end;    
  BitBlt(Canvas.Handle, 0, 0, RectWidth(R), RectHeight(R),
    FDrawBitmap.Canvas.Handle, 0, 0, SRCCOPY);
end;

procedure TcxCustomSplitter.DrawHotZone;
begin
  if HotZone <> nil then
    HotZone.DrawHotZone(FDrawCanvas, FDrawCanvas.Canvas.ClipRect,
      (smsInHotZone in FMouseStates),
      (smsClicked in FMouseStates) and (smsInHotZone in FMouseStates));
end;

function TcxCustomSplitter.DoCanResize(var NewSize: Integer): Boolean;
begin
  Result := CanResize(NewSize);
  if Result and FAutoSnap and (NewSize < InternalGetMinSize) then
    NewSize := 0;
end;

procedure TcxCustomSplitter.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  inherited LookAndFeelChanged(Sender, AChangedValues);
  NormalizeSplitterSize;
  if [lfvSkinName, lfvNativeStyle] * AChangedValues <> [] then
    Invalidate;
end;

function TcxCustomSplitter.CanFocusOnClick: Boolean;
begin
  Result := False;
end;

function TcxCustomSplitter.CanResize(var NewSize: Integer): Boolean;
begin
  Result := True;
  if Assigned(FOnCanResize) then FOnCanResize(Self, NewSize, Result);
end;

procedure TcxCustomSplitter.UpdateControlSize;

  procedure CorrectSelfPosition;
  begin
    if FOldSize <= 0  then
      case Align of
        alLeft:
          Left := FControl.Left + FControl.Width;
        alTop:
          Top := FControl.Top + FControl.Height;
        alRight:
          Left := FControl.BoundsRect.Right - Width;
        alBottom:
          Top := FControl.BoundsRect.Bottom - Height;
      end;
  end;

begin
  if not Assigned(FControl) or (FNewSize = FOldSize) then
    Exit;
  Parent.DisableAlign;
  try
    case Align of
      alLeft:
        FControl.SetBounds(FControl.Left, FControl.Top, FNewSize, FControl.Height);
      alTop:
        FControl.SetBounds(FControl.Left, FControl.Top, FControl.Width, FNewSize);
      alRight:
        FControl.SetBounds(FControl.Left + FControl.Width - FNewSize,
          FControl.Top, FNewSize, FControl.Height);
      alBottom:
        FControl.SetBounds(FControl.Left,
          FControl.Top + FControl.Height - FNewSize, FControl.Width, FNewSize);
    end;
  finally
    Parent.EnableAlign;
    CorrectSelfPosition;
  end;
  FOldSize := FNewSize;
  DoEventMoved;
end;

procedure TcxCustomSplitter.CalcSplitSize(X, Y: Integer;
  var NewSize, Split: Integer; ACorrectWithMaxMin: Boolean = True);
var
  S: Integer;
begin
  if not Assigned(FControl) then Exit;
  if Align in [alLeft, alRight] then
    Split := X - FSplitterClickPoint.X
  else
    Split := Y - FSplitterClickPoint.Y;
  S:=0;
  case Align of
    alLeft: S := FControl.Width + Split;
    alRight: S := FControl.Width - Split;
    alTop: S := FControl.Height + Split;
    alBottom: S := FControl.Height - Split;
  end;
  NewSize := S;
  if not ACorrectWithMaxMin then
    Exit;
  if NewSize < 0 then
    NewSize := 0;

  if (S < InternalGetMinSize) then
  begin
    if AutoSnap then
      NewSize := 0
    else
      NewSize := InternalGetMinSize;
  end
  else
    if S > FMaxSize then
      NewSize := FMaxSize;

  if S <> NewSize then
  begin
    if Align in [alRight, alBottom] then
      S := S - NewSize
    else
      S := NewSize - S;
    Inc(Split, S);
  end;
end;

procedure TcxCustomSplitter.ControlResizing(X, Y: Integer);
  procedure UpdateState;
  begin
    if FNewSize > 0 then
      FState := ssOpened
    else
      FState := ssClosed;
  end;

  procedure AdjustControlWithMinSize(ANewSize: Integer);
  begin
    if (ANewSize < MinSize) then
    begin
      if (FState = ssOpened) and not FAutoSnap then
        FNewSize := MinSize
      else
        case FState of
          ssClosed:
            if ANewSize >= 0 then
              OpenSplitter
            else
              FNewSize := 0;
          ssOpened:
            CloseSplitter;
        end;
    end;
  end;

var
  ASplit, ANewSize: Integer;
begin
  FLastPatternDrawPosition := -1;
  ParentShowHint := FSavedParentShowHint;
  ShowHint := FSavedShowHint;
  FHotZoneClickPoint := Point(-1, -1);
  case FSplitterState of
    sstHotZoneClick:
      if (smsInHotZone in FMouseStates) then
      begin
        UpdateMouseStates(X, Y);
        case FState of
          ssClosed: OpenSplitter;
          ssOpened: CloseSplitter;
        end;
      end;
    sstResizing:
      begin
        StopSizing;
        CalcSplitSize(X, Y, ANewSize, ASplit, False);
        AdjustControlWithMinSize(ANewSize);
        UpdateControlSize;
        UpdateState;
        if (ANewSize >= 0) then
          RecalcLastPosition;
      end;
  end;
  SetDefaultStates;
  Invalidate;
end;

procedure TcxCustomSplitter.UpdateSize(X, Y: Integer);
begin
  CalcSplitSize(X, Y, FNewSize, FSplit);
end;

function TcxCustomSplitter.IsPointInHotZone(const X, Y: Integer): Boolean;
var
  AHotZoneRect: TRect;
begin
  if not IsAllControlHotZoneStyle then
  begin
    if HotZone <> nil then
    begin
      AHotZoneRect := HotZone.CalculateHotZoneRect(ClientRect);
      Result := (X >= AHotZoneRect.Left) and (X <= AHotZoneRect.Right) and
        (Y >= AHotZoneRect.Top) and (Y <= AHotZoneRect.Bottom);
    end
    else
      Result := False;
  end
  else
    Result := (X >= ClientRect.Left) and (X <= ClientRect.Right) and
     (Y >= ClientRect.Top) and (Y <= ClientRect.Bottom);
end;

function TcxCustomSplitter.IsPointInSplitter(const X, Y: Integer): Boolean;
var
  FRect : TRect;
begin
  FRect := ClientRect;
  Result := ((X >= FRect.Left) and (X <= FRect.Right) and
    (Y >= FRect.Top) and (Y <= FRect.Bottom));
end;

procedure TcxCustomSplitter.InitResize(X, Y: Integer);

  function GetMaxSize: Integer;
  var
    AMaxControlSize: Integer;
  begin
     Result := 0;
     case Align of
       alLeft:
         Result := Parent.ClientWidth - Width - FControl.Left;
       alRight:
         Result := FControl.Left + FControl.Width - Width;
       alTop:
         Result := Parent.ClientHeight - Height - FControl.Top;
       alBottom:
         Result := FControl.Top + FControl.Height - Height;
     end;
     Dec(Result, FMinSize);
     AMaxControlSize := GetMaxControlSize;
     if (AMaxControlSize <> 0) and (Result > AMaxControlSize) then
       Result := AMaxControlSize;
  end;

begin
  FMaxSize := GetMaxSize;
  UpdateSize(X, Y);
  InitDragImage;
  with ValidParentForm(Self) do
    if ActiveControl <> nil then
    begin
      FActiveControl := ActiveControl;
      FPrevKeyDown := TWinControlAccess(FActiveControl).OnKeyDown;
      TWinControlAccess(FActiveControl).OnKeyDown := FocusKeyDown;
    end;
  if not ResizeUpdate then
    MoveDragImage;
end;

procedure TcxCustomSplitter.WMCancelMode(var Message: TWMCancelMode);
begin
  inherited;
  if FSplitterState = sstResizing then
    ControlResizing(Left, Top);
end;

procedure TcxCustomSplitter.WMSetCursor(var Message: TWMSetCursor);
begin
end;

procedure TcxCustomSplitter.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (Button = mbLeft) and Assigned(FControl) then
  begin
    FSplitterClickPoint := Point(X, Y);
    FSavedShowHint := ShowHint;
    FSavedParentShowHint := ParentShowHint;
    ShowHint := False;
    Include(FMouseStates, smsClicked);
    UpdateMouseStates(X, Y);
    if (smsInHotZone in FMouseStates) then
    begin
      FSplitterState := sstHotZoneClick;
      FHotZoneClickPoint := Point(X, Y);
      Invalidate;
    end
    else
    begin
      FSplitterState := sstResizing;
      InitResize(X, Y);
    end;
  end;
end;

procedure TcxCustomSplitter.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ACursor: TCursor;
  ALocalNewSize: Integer;
  ASavedMouseStates: TcxSplitterMouseStates;
begin
  inherited;
  ASavedMouseStates := FMouseStates;
  UpdateMouseStates(X, Y);
  if (ssLeft in Shift) and (Assigned(FControl)) then
  begin
    CalcSplitSize(X, Y, ALocalNewSize, FSplit);
    case FSplitterState of
      sstResizing:
      begin
        if DoCanResize(ALocalNewSize) then
        begin
          FNewSize := ALocalNewSize;
          if not ResizeUpdate then
            MoveDragImage
          else
          begin
            RecalcLastPosition;
            UpdateControlSize;
          end;
        end;
      end;
      sstHotZoneClick:
      begin
        if AllowHotZoneDrag then
        begin
          if (((FHotZoneClickPoint.X + DragThreshold) <= X) or
             ((FHotZoneClickPoint.X - DragThreshold) >= X) or
             ((FHotZoneClickPoint.Y + DragThreshold) <= Y) or
             ((FHotZoneClickPoint.Y - DragThreshold) >= Y)) and
             DoCanResize(ALocalNewSize) then
          begin
            FSplitterState := sstResizing;
            InitResize(X, Y);
          end;
        end
        else
          if (FMouseStates <> ASavedMouseStates) then
            Invalidate;
      end;
    end;
  end;
  if Shift * [ssLeft, ssRight] = [] then
  begin
    if FMouseStates <> ASavedMouseStates then
      Invalidate;
    if (smsInHotZone in FMouseStates) and not IsAllControlHotZoneStyle then
      ACursor := crDefault
    else
    begin
      ACursor := Cursor;
      if ACursor = crDefault then
        if Align in [alBottom, alTop] then
          ACursor := crVSplit
        else
          ACursor := crHSplit;
    end;
    SetCursor(Screen.Cursors[ACursor]);
  end;
end;

procedure TcxCustomSplitter.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and Assigned(FControl) and (smsClicked in FMouseStates) then
    ControlResizing(X, Y);
end;

procedure TcxCustomSplitter.FocusKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
  begin
    StopSizing;
    SetDefaultStates;
  end
  else
    if Assigned(FPrevKeyDown) then FPrevKeyDown(Sender, Key, Shift);
end;

procedure TcxCustomSplitter.StopSizing;
var
  AMousePoint: TPoint;
begin
  if Assigned(FControl) then
  begin
    ReleaseDragImage;
    AMousePoint := ScreenToClient(Mouse.CursorPos);
    UpdateMouseStates(AMousePoint.X, AMousePoint.Y);
    if Assigned(FActiveControl) then
    begin
      TWinControlAccess(FActiveControl).OnKeyDown := FPrevKeyDown;
      FActiveControl := nil;
    end;
    FSplitterState := sstNormal;
  end;
end;

procedure TcxCustomSplitter.OpenSplitter;
var
  AAllowOpenHotZone: Boolean;
  ANewSize: Integer;
begin
  if State = ssOpened then Exit;
  if FAutoPosition = True then
    ANewSize := FPositionBeforeClose
  else
    ANewSize := FPositionAfterOpen;
  if ANewSize < InternalGetMinSize then
    ANewSize := InternalGetMinSize;

  AAllowOpenHotZone := True;
  DoEventBeforeOpen(ANewSize, AAllowOpenHotZone);
  if AAllowOpenHotZone = False then Exit;
  FState := ssOpened;
  FNewSize := ANewSize;
  RecalcLastPosition;
  UpdateControlSize;
  DoEventAfterOpen;
  Invalidate;
end;

procedure TcxCustomSplitter.CloseSplitter;
var
  FAllowCloseHotZone: Boolean;
begin
  if State = ssClosed then Exit;
  FAllowCloseHotZone := True;
  DoEventBeforeClose(FAllowCloseHotZone);
  if FAllowCloseHotZone = False then Exit;
  FState := ssClosed;
  FNewSize := 0;
  RecalcLastPosition;
  UpdateControlSize;
  DoEventAfterClose;
  Invalidate;
end;

procedure TcxCustomSplitter.RecalcLastPosition;
begin
  if (FControl<>nil) then
    case FAlignSplitter of
      salBottom, salTop:
        FPositionBeforeClose := FControl.Height;
      salLeft, salRight:
        FPositionBeforeClose := FControl.Width;
    end;
end;

procedure TcxCustomSplitter.DoEventBeforeOpen(var ANewSize: Integer;
  var AllowOpenHotZone: Boolean);
begin
  if Assigned(FOnBeforeOpen) then
    FOnBeforeOpen(Self, ANewSize, AllowOpenHotZone);
end;

procedure TcxCustomSplitter.DoEventAfterOpen;
begin
  if Assigned(FOnAfterOpen) then FOnAfterOpen(Self);
end;

procedure TcxCustomSplitter.DoEventBeforeClose(var AllowCloseHotZone: Boolean);
begin
  if Assigned(FOnBeforeClose) then FOnBeforeClose(Self, AllowCloseHotZone);
end;

procedure TcxCustomSplitter.DoEventAfterClose;
begin
  if Assigned(FOnAfterClose) then FOnAfterClose(Self);
end;

procedure TcxCustomSplitter.DoEventMoved;
begin
  if Assigned(FOnMoved) then FOnMoved(Self);
end;

function TcxCustomSplitter.InternalGetMinSize: Integer;
var
  AMinSizeConstraints: Integer;
begin
  Result := FMinSize;
  if FControl = nil then
    Exit;
  case AlignSplitter of
    salBottom, salTop:
      AMinSizeConstraints := FControl.Constraints.MinHeight;
    salLeft, salRight:
      AMinSizeConstraints := FControl.Constraints.MinWidth;
  else
    AMinSizeConstraints := 0;
  end;
  if AMinSizeConstraints > FMinSize then
    Result := AMinSizeConstraints;
end;

initialization
  GetRegisteredHotZoneStyles.Register(TcxMediaPlayer8Style, scxHotZoneStyleMediaPlayer8);
  GetRegisteredHotZoneStyles.Register(TcxMediaPlayer9Style, scxHotZoneStyleMediaPlayer9);
  GetRegisteredHotZoneStyles.Register(TcxXPTaskBarStyle, scxHotZoneStyleXPTaskBar);
  GetRegisteredHotZoneStyles.Register(TcxSimpleStyle, scxHotZoneStyleSimple);

finalization
  GetRegisteredHotZoneStyles.Unregister(TcxMediaPlayer8Style);
  GetRegisteredHotZoneStyles.Unregister(TcxMediaPlayer9Style);
  GetRegisteredHotZoneStyles.Unregister(TcxXPTaskBarStyle);
  GetRegisteredHotZoneStyles.Unregister(TcxSimpleStyle);
  FreeAndNil(FRegisteredHotZoneStyles);

end.
