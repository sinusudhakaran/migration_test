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

unit cxProgressBar;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types, Variants,
{$ENDIF}
  Windows, Classes, Controls, Forms, Graphics, Messages, SysUtils, cxClasses,
  cxContainer, cxControls, cxCustomData, cxEdit, cxExtEditConsts,
  cxFilterControlUtils, cxGraphics, cxTextEdit, cxVariants, cxLookAndFeelPainters;

const
  cxProgressBarDefaultAnimationSpeed = 10;
  cxProgressBarDefaultAnimationRestartDelay = 0;
type
  TcxBorderWidth = 0..MaxWord;
  TcxProgressBarAnimationSpeed = 0..20;
  TcxProgressBarBevelOuter = (cxbvNone, cxbvLowered, cxbvRaised);
  TcxProgressBarOrientation = (cxorHorizontal, cxorVertical);
  TcxProgressBarTextStyle = (cxtsPercent, cxtsPosition, cxtsText);
  TcxProgressBarBarStyle = (cxbsSolid, cxbsLEDs, cxbsGradient,
    cxbsGradientLEDs, cxbsBitmap, cxbsBitmapLEDs, cxbsAnimation,
    cxbsAnimationLEDs);
  TcxProgressBarAnimationPath = (cxapCycle, cxapPingPong);

const
  cxDefaultShowTextStyle = cxtsPercent;

type
  { TcxCustomProgressBarViewInfo }

  TcxCustomProgressBar = class;

  TcxCustomProgressBarViewInfo = class(TcxCustomTextEditViewInfo)
  private
    FAnimationPath: TcxProgressBarAnimationPath;
    FAnimationRestartDelay: Cardinal;
    FAnimationPosition: Integer;
    FAnimationDirection: Integer;
    FAnimationSpeed: Cardinal;
    FAnimationTimer: TcxTimer;
    FAnimationRestartDelayTimer: TcxTimer;
    FBeginColor: TColor;
    FBarBevelOuter: TcxProgressBarBevelOuter;
    FUsualBitmap: TcxBitmap;
    FPainterBitmap: TcxBitmap;
    FEndColor: TColor;
    FMarquee: Boolean;
    FMax: Double;
    FMin: Double;
    FNativeBitmap: TBitmap;
    FPosition: Double;
    FForegroundImage: TBitmap;
    FOrientation: TcxProgressBarOrientation;
    FShowText: Boolean;
    FShowTextStyle: TcxProgressBarTextStyle;
    FTextOrientation: TcxProgressBarOrientation;
    FSolidTextColor: Boolean;
    FBarStyle: TcxProgressBarBarStyle;
    FOverloadValue: Double;
    FOverloadBeginColor: TColor;
    FOverloadEndColor: TColor;
    FShowOverload: Boolean;
    FPeakValue: Double;
    FPeakColor: TColor;
    FPeakSize: TcxNaturalNumber;
    FShowPeak: Boolean;
    FRealShowOverload: Boolean;
    FRealShowPeak: Boolean;
    FPropTransparent: Boolean;
    procedure CalcDrawingParams(out ADrawProgressBarRect, ADrawOverloadBarRect,
      ADrawPeakBarRect, ADrawAnimationBarRect, ASolidRect: TRect; out ALEDsWidth: Integer);
    function CanAnimationBarShow: Boolean;
    procedure CreateBarBmp;
    procedure CreateNativeBitmap(const ASize: TSize);
    procedure CreatePainterBitmap;
    procedure ExcludeRects(ACanvas: TcxCanvas; const ABounds: TRect);
    procedure ExcludeLEDRects(ACanvas: TcxCanvas; const ABounds: TRect);
    function GetAnimationTimerInterval: Cardinal;
    function GetAnimationOffset: Integer;
    function GetMaxMinDiff: Double;
    function GetRelativeOverloadValue: Double;
    function GetRelativePeakValue: Double;
    function GetRelativePosition: Double;
    function IsLEDStyle: Boolean;
    procedure DrawBackground(ACanvas: TcxCanvas; const ACanvasParent: TcxCanvas; const ABounds: TRect);
    function GetDrawDelta: Integer;
    function GetDrawText: string;
    procedure DrawBarCaption(ACanvas: TcxCanvas);
    procedure PaintBarBevelOuter(ACanvas: TcxCanvas; ABBORect: TRect);
    procedure DrawBarBitmap(ACanvas: TcxCanvas; ARect: TRect);
    procedure DrawGradientBar(ACanvas: TcxCanvas; const ANormalRect, AOverloadRect, ABarRect: TRect);
    procedure DrawSolidBar(ACanvas: TcxCanvas; const ANormalRect, AOverloadRect: TRect);
    procedure DrawAnimationBar(ACanvas: TcxCanvas; const ABar, ASolidRect: TRect);
    procedure DrawAnimationBarBackground(ACanvas: TcxCanvas; const ASolidRect: TRect; ASolidColor: TColor; ADrawBar: Boolean);
    function CalcLEDsWidth: Integer;
    procedure AdjustForLEDsBarBounds(var ABarRect, AOverloadBarRect: TRect; const ALEDsWidth: Integer);
    procedure DrawPeak(ACanvas: TcxCanvas; const APeakRect: TRect);
    procedure DrawBorderLEDs(ACanvas: TcxCanvas; const ABarRect: TRect; ALEDsWidth: Integer);
    procedure DoAnimationTimer(Sender: TObject);
    procedure DoAnimationRestartDelayTimer(Sender: TObject);
    procedure StartAnimationTimer;
    procedure StartAnimationRestartDelayTimer;
    procedure StopAnimationTimer;
    procedure StopAnimationRestartDelayTimer;
    procedure SetAnimationPath(AValue: TcxProgressBarAnimationPath);
    procedure SetAnimationSpeed(AValue: Cardinal);
    procedure SetMarquee(AValue: Boolean);
    procedure SetBarStyle(AValue: TcxProgressBarBarStyle);
    procedure SetAnimationFirstPosition;
    procedure CalcAnimationCurrentPosition;
    function GetCorrectAnimationBarRect: TRect;
    function GetMinPositionInBounds: Integer;
    function GetMaxPositionInBounds: Integer;
    procedure SetOrientation(AValue: TcxProgressBarOrientation);
  protected
    ChangedBounds: Boolean;
    ChangedBoundsBarRect: Boolean;
    BarRect: TRect;
    ProgressBarRect: TRect;
    OverloadBarRect: TRect;
    PeakBarRect: TRect;
    AnimationBarRect: TRect;
    procedure PaintProgressBarByPainter(ACanvas: TcxCanvas);
    function GetAnimationBarDimension: Integer; virtual;
    function GetAnimationDerection: Integer; virtual;

    property AnimationPath: TcxProgressBarAnimationPath read FAnimationPath
      write SetAnimationPath;
    property AnimationRestartDelay: Cardinal read FAnimationRestartDelay write FAnimationRestartDelay;
    property AnimationSpeed: Cardinal read FAnimationSpeed write SetAnimationSpeed;
    property BeginColor: TColor read FBeginColor write FBeginColor;
    property BarBevelOuter: TcxProgressBarBevelOuter read FBarBevelOuter
      write FBarBevelOuter;
    property EndColor: TColor read FEndColor write FEndColor;
    property Marquee: Boolean read FMarquee write SetMarquee;
    property Min: Double read FMin write FMin;
    property Max: Double read FMax write FMax;
    property MaxMinDiff: Double read GetMaxMinDiff;
    property OverloadValue: Double read FOverloadValue write FOverloadValue;
    property PeakValue: Double read FPeakValue write FPeakValue;
    property Position: Double read FPosition write FPosition;
    property RelativePeakValue: Double read GetRelativePeakValue;
    property RelativeOverloadValue: Double read GetRelativeOverloadValue;
    property RelativePosition: Double read GetRelativePosition;

    property ForegroundImage: TBitmap read FForegroundImage write FForegroundImage;
    property Orientation: TcxProgressBarOrientation read FOrientation write SetOrientation;
    property ShowText: Boolean read FShowText write FShowText;
    property ShowTextStyle: TcxProgressBarTextStyle read FShowTextStyle write FShowTextStyle;
    property TextOrientation: TcxProgressBarOrientation read FTextOrientation
      write FTextOrientation;
    property SolidTextColor: Boolean read FSolidTextColor write FSolidTextColor;
    property BarStyle: TcxProgressBarBarStyle read FBarStyle write SetBarStyle;
    property OverloadBeginColor: TColor read FOverloadBeginColor write FOverloadBeginColor;
    property OverloadEndColor: TColor read FOverloadEndColor write FOverloadEndColor;
    property PeakColor: TColor read FPeakColor write FPeakColor;
    property PeakSize: TcxNaturalNumber read FPeakSize write FPeakSize;
    property ShowOverload: Boolean read FShowOverload write FShowOverload;
    property ShowPeak: Boolean read FShowPeak write FShowPeak;
    property PropTransparent: Boolean read FPropTransparent write FPropTransparent;
  public
    FocusRect: TRect;
    HasForegroundImage: Boolean;
    constructor Create; override;
    destructor Destroy; override;
    procedure DrawText(ACanvas: TcxCanvas); override;
    function GetPercentDone: Integer;
    function GetUpdateRegion(AViewInfo: TcxContainerViewInfo): TcxRegion; override;
    function NeedShowHint(ACanvas: TcxCanvas; const P: TPoint; out AText: TCaption;
      out AIsMultiLine: Boolean; out ATextRect: TRect): Boolean; override;
    procedure Paint(ACanvas: TcxCanvas); override;
    procedure PaintProgressBar(ACanvas: TcxCanvas); virtual;
    procedure Offset(DX: Integer; DY: Integer); override;
  end;

  { TcxCustomProgressBarViewData }

  TcxCustomProgressBarProperties = class;

  TcxCustomProgressBarViewData = class(TcxCustomEditViewData)
  private
    function GetProperties: TcxCustomProgressBarProperties;
  protected
    procedure CalculateViewInfoProperties(AViewInfo: TcxCustomEditViewInfo); virtual;
    function InternalGetEditConstantPartSize(ACanvas: TcxCanvas; AIsInplace: Boolean;
      AEditSizeProperties: TcxEditSizeProperties;
      var MinContentSize: TSize; AViewInfo: TcxCustomEditViewInfo): TSize; override;
    function GetDrawTextFlags: Integer; virtual;
    function GetIsEditClass: Boolean;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    procedure CalculateButtonsViewInfo(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    procedure EditValueToDrawValue(ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
      AViewInfo: TcxCustomEditViewInfo); override;
    property Properties: TcxCustomProgressBarProperties read GetProperties;
  end;

  { TcxProgressBarPropertiesValues }

  TcxProgressBarPropertiesValues = class(TcxCustomEditPropertiesValues)
  private
    function GetMax: Boolean;
    function GetMin: Boolean;
    function IsMaxStored: Boolean;
    function IsMinStored: Boolean;
    procedure SetMax(Value: Boolean);
    procedure SetMin(Value: Boolean);
  published
    property Max: Boolean read GetMax write SetMax stored IsMaxStored;
    property Min: Boolean read GetMin write SetMin stored IsMinStored;
  end;

  { TcxCustomProgressBarProperties }

  TcxCustomProgressBarProperties = class(TcxCustomEditProperties)
  private
    FAnimationPath: TcxProgressBarAnimationPath;
    FAnimationRestartDelay: Cardinal;
    FAnimationSpeed: TcxProgressBarAnimationSpeed;
    FBeginColor: TColor;
    FBarBevelOuter: TcxProgressBarBevelOuter;
    FChangedForegroundImage: Boolean;
    FChangedPosition: Boolean;
    FEndColor: TColor;
    FForegroundImage: TBitmap;
    FMarquee: Boolean;
    FOrientation: TcxProgressBarOrientation;
    FShowText: Boolean;
    FShowTextStyle: TcxProgressBarTextStyle;
    FText: string;
    FTextOrientation: TcxProgressBarOrientation;
    FSolidTextColor: Boolean;
    FBarStyle: TcxProgressBarBarStyle;
    FTransparentImage: Boolean;
    FBorderWidth: TcxBorderWidth;
    FOverloadValue: Double;
    FShowOverload: Boolean;
    FOverloadBeginColor: TColor;
    FOverloadEndColor: TColor;
    FPeakValue: Double;
    FShowPeak: Boolean;
    FPeakColor: TColor;
    FPeakSize: TcxNaturalNumber;
    function GetAssignedValues: TcxProgressBarPropertiesValues;
    function GetForegroundImage: TBitmap;
    procedure ForegroundImageChanged(Sender: TObject);
    function GetMax: Double;
    function GetMin: Double;
    function GetOverloadValueStored: Boolean;
    function GetPeakValueStored: Boolean;
    function GetRealPeakValue(APosition: Double): Double;
    function IsMaxStored: Boolean;
    function IsMinStored: Boolean;
    function IsShowTextStyleStored: Boolean;
    procedure SetAnimationPath(AValue: TcxProgressBarAnimationPath);
    procedure SetAnimationRestartDelay(AValue: Cardinal);
    procedure SetAnimationSpeed(AValue: TcxProgressBarAnimationSpeed);
    procedure SetAssignedValues(Value: TcxProgressBarPropertiesValues);
    procedure SetBeginColor(Value: TColor);
    procedure SetBarBevelOuter(Value: TcxProgressBarBevelOuter);
    procedure SetColorVista;
    procedure SetEndColor(Value: TColor);
    procedure SetForegroundImage(Value: TBitmap);
    procedure SetMarquee(Value: Boolean);
    procedure SetMax(Value: Double);
    procedure SetMin(Value: Double);
    procedure SetOrientation(Value: TcxProgressBarOrientation);
    procedure SetShowText(Value: Boolean);
    procedure SetShowTextStyle(Value: TcxProgressBarTextStyle);
    procedure SetTextOrientation(Value: TcxProgressBarOrientation);
    procedure SetSolidTextColor(Value: Boolean);
    procedure SetBarStyle(Value: TcxProgressBarBarStyle);
    procedure SetText(const AValue: string);
    procedure SetTransparentImage(Value: Boolean);
    procedure SetBorderWidth(Value: TcxBorderWidth);
    procedure SetOverloadValue(Value: Double);
    procedure SetShowOverload(Value: Boolean);
    procedure SetOverloadBeginColor(Value: TColor);
    procedure SetOverloadEndColor(Value: TColor);
    procedure SetPeakValue(Value: Double);
    procedure SetShowPeak(Value: Boolean);
    procedure SetPeakColor(Value: TColor);
    procedure SetPeakSize(Value: TcxNaturalNumber);
    procedure PostMinValue;
    procedure PostMaxValue;
    procedure PostOverloadValue;
  protected
    procedure CorrectPositionWithMaxMin(
      AViewInfo: TcxCustomProgressBarViewInfo); virtual;
    class function GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass; override;
    function GetMaxValue: Double; override;
    function GetMinValue: Double; override;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function HasDisplayValue: Boolean; override;
    property AssignedValues: TcxProgressBarPropertiesValues read GetAssignedValues
      write SetAssignedValues;
    property ChangedForegroundImage: Boolean read FChangedForegroundImage
      write FChangedForegroundImage default False;
    property ChangedPosition: Boolean read FChangedPosition
      write FChangedPosition default False;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CanCompareEditValue: Boolean; override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function IsEditValueValid(var EditValue: TcxEditValue;
      AEditFocused: Boolean): Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    // !!!
    property AnimationPath: TcxProgressBarAnimationPath read FAnimationPath
      write SetAnimationPath default cxapCycle;
    property AnimationRestartDelay: Cardinal read FAnimationRestartDelay write SetAnimationRestartDelay default cxProgressBarDefaultAnimationRestartDelay;
    property AnimationSpeed: TcxProgressBarAnimationSpeed read FAnimationSpeed write SetAnimationSpeed default cxProgressBarDefaultAnimationSpeed;
    property BarBevelOuter: TcxProgressBarBevelOuter read FBarBevelOuter
      write SetBarBevelOuter default cxbvNone;
    property BarStyle: TcxProgressBarBarStyle read FBarStyle write SetBarStyle
      default cxbsSolid;
    property BeginColor: TColor read FBeginColor write SetBeginColor
      default clNavy;
    property BorderWidth : TcxBorderWidth read FBorderWidth write SetBorderWidth
      default 0;
    property EndColor: TColor read FEndColor write SetEndColor default clWhite;
    property ForegroundImage: TBitmap read GetForegroundImage
      write SetForegroundImage;
    property Marquee: Boolean read FMarquee write SetMarquee default False;
    property Max: Double read GetMax write SetMax stored IsMaxStored;
    property Min: Double read GetMin write SetMin stored IsMinStored;
    property Orientation: TcxProgressBarOrientation read FOrientation
      write SetOrientation default cxorHorizontal;
    property OverloadBeginColor: TColor read FOverloadBeginColor
      write SetOverloadBeginColor default $008080FF;
    property OverloadEndColor: TColor read FOverloadEndColor
      write SetOverloadEndColor default clFuchsia;
    property OverloadValue: Double read FOverloadValue write SetOverloadValue
      stored GetOverloadValueStored;
    property PeakColor: TColor read FPeakColor write SetPeakColor default clRed;
    property PeakSize: TcxNaturalNumber read FPeakSize write SetPeakSize
      default 2;
    property PeakValue: Double read FPeakValue write SetPeakValue
      stored GetPeakValueStored;
    property ShowOverload: Boolean read FShowOverload write SetShowOverload
      default False;
    property ShowPeak: Boolean read FShowPeak write SetShowPeak default False;
    property ShowText: Boolean read FShowText write SetShowText default True;
    property ShowTextStyle: TcxProgressBarTextStyle read FShowTextStyle
      write SetShowTextStyle stored IsShowTextStyleStored;
    property SolidTextColor: Boolean read FSolidTextColor
      write SetSolidTextColor default False;
    property Text: string read FText write SetText;
    property TextOrientation: TcxProgressBarOrientation read FTextOrientation
      write SetTextOrientation default cxorHorizontal;
    property Transparent; // deprecated
    property TransparentImage: Boolean read FTransparentImage
      write SetTransparentImage default True;
  end;

  { TcxProgressBarProperties }

  TcxProgressBarProperties = class(TcxCustomProgressBarProperties)
  published
    property AnimationPath;
    property AnimationRestartDelay;
    property AnimationSpeed;
    property AssignedValues;
    property BarBevelOuter;
    property BarStyle;
    property BeginColor;
    property BorderWidth;
    property EndColor;
    property ForegroundImage;
    property Marquee;
    property Max;
    property Min;
    property Orientation;
    property OverloadBeginColor;
    property OverloadEndColor;
    property OverloadValue;
    property PeakColor;
    property PeakSize;
    property PeakValue;
    property ShowOverload;
    property ShowPeak;
    property ShowText;
    property ShowTextStyle;
    property SolidTextColor;
    property Text;
    property TextOrientation;
    property Transparent; // deprecated
    property TransparentImage;
  end;

  { TcxCustomProgressBar }

  TcxCustomProgressBar = class(TcxCustomEdit)
  private
    function GetPercentDone: Integer;
    function GetPosition: Double;
    function GetPositionStored: Boolean;
    function GetProperties: TcxCustomProgressBarProperties;
    function GetActiveProperties: TcxCustomProgressBarProperties;
    function GetViewInfo: TcxCustomProgressBarViewInfo;
    procedure SetProperties(Value: TcxCustomProgressBarProperties);
    procedure SetPosition(Value: Double);
  protected
    procedure CheckEditorValueBounds; virtual;
    procedure CheckEditValue; virtual;
    function DefaultParentColor: Boolean; override;
    procedure FillSizeProperties(var AEditSizeProperties: TcxEditSizeProperties); override;
    procedure Initialize; override;
    function InternalGetNotPublishedStyleValues: TcxEditStyleValues; override;
    procedure SynchronizeDisplayValue; override;
    procedure PropertiesChanged(Sender: TObject); override;
    property ViewInfo: TcxCustomProgressBarViewInfo read GetViewInfo;
    function CanFocusOnClick: Boolean; override;
    function GetEditStateColorKind: TcxEditStateColorKind; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    function CanFocus: Boolean; override;
    property ActiveProperties: TcxCustomProgressBarProperties
      read GetActiveProperties;
    property PercentDone: Integer read GetPercentDone;
    property Position: Double read GetPosition write SetPosition
      stored GetPositionStored;
    property Properties: TcxCustomProgressBarProperties read GetProperties
      write SetProperties;
    property Transparent;
  end;

  { TcxCustomProgressBar }

  TcxProgressBar = class(TcxCustomProgressBar)
  private
    function GetActiveProperties: TcxProgressBarProperties;
    function GetProperties: TcxProgressBarProperties;
    procedure SetProperties(Value: TcxProgressBarProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxProgressBarProperties
      read GetActiveProperties;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Position;
    property Properties: TcxProgressBarProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Transparent;
    property Visible;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
  Math, dxCore, cxEditConsts, cxDrawTextUtils, cxEditUtils, cxExtEditUtils,
  cxSpinEdit, dxThemeConsts, dxThemeManager, dxUxTheme, cxGeometry, dxOffice11,
  cxLookAndFeels;

const
  cxAnimationBarColorLightPercentage = 60;
  cxAnimationBarMiddlePartWidth = 10;
  cxAnimationBarTopPartWidth = 6;
  cxAnimationBarTopBeginColorLightPercentage = 40;
  cxAnimationBarTopEndColorLightPercentage = 80;
  cxAnimationBarBorderExtPartColorLightPercentage = 90;
  cxAnimationBarBorderIntPartColorLightPercentage = 80;
  cxAnimationBarBorderExtPathWidth = 4;
  cxAnimationBarBorderIntPathWidth = 20;
  cxAnimationBarBackgroundBorderWidth = 8;

type
  { TcxFilterProgressBarHelper }

  TcxFilterProgressBarHelper = class(TcxFilterSpinEditHelper)
  public
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
  end;

procedure CalculateCustomProgressBarViewInfo(ACanvas: TcxCanvas; AViewData: TcxCustomProgressBarViewData;
  AViewInfo: TcxCustomProgressBarViewInfo);

  procedure CheckFocusRectBounds;
  begin
    with AViewInfo do
    begin
      if FocusRect.Left < TextRect.Left - 1 then
        FocusRect.Left := TextRect.Left - 1;
      if FocusRect.Top < TextRect.Top - 1 then
        FocusRect.Top := TextRect.Top - 1;
      if FocusRect.Right > TextRect.Right + 1 then
        FocusRect.Right := TextRect.Right + 1;
      if FocusRect.Bottom > TextRect.Bottom + 1 then
        FocusRect.Bottom := TextRect.Bottom + 1;
    end;
  end;

begin
  with AViewInfo do
  begin
    if not IsInplace and Focused then
      if Length(Text) = 0 then
        FocusRect := cxEmptyRect
      else
      begin
        FocusRect := TextRect;
        InflateRect(FocusRect, 1, 1);
        CheckFocusRectBounds;
      end;
  end;
end;

function CalculateDelta(const APositionDelta, ARectWidth, AMaxMinDelta: Double): Integer;
var
  ACalc: Double;
begin
  ACalc := (APositionDelta * ARectWidth) / AMaxMinDelta;
  Result := Trunc(ACalc);
end;

{ TcxCustomProgressBarViewInfo }

constructor TcxCustomProgressBarViewInfo.Create;
begin
  inherited Create;
  FForegroundImage := TBitmap.Create;
  ChangedBounds := False;
  ChangedBoundsBarRect := False;
  FMarquee := False;
  FAnimationPath := cxapCycle;
  FAnimationRestartDelay := cxProgressBarDefaultAnimationRestartDelay;
  FUsualBitmap := TcxBitmap.Create;
end;

destructor TcxCustomProgressBarViewInfo.Destroy;
begin
  FreeAndNil(FForegroundImage);
  FreeAndNil(FAnimationTimer);
  FreeAndNil(FAnimationRestartDelayTimer);
  FreeAndNil(FUsualBitmap);
  FreeAndNil(FNativeBitmap);
  FreeAndNil(FPainterBitmap);
  inherited Destroy;
end;

function TcxCustomProgressBarViewInfo.GetUpdateRegion(AViewInfo: TcxContainerViewInfo): TcxRegion;
begin
  Result := inherited GetUpdateRegion(AViewInfo);
  if not (AViewInfo is TcxCustomProgressBarViewInfo) then Exit;
end;

function TcxCustomProgressBarViewInfo.NeedShowHint(ACanvas: TcxCanvas;
  const P: TPoint; out AText: TCaption; out AIsMultiLine: Boolean;
  out ATextRect: TRect): Boolean;
begin
  Result := False;
end;

procedure TcxCustomProgressBarViewInfo.DrawText(ACanvas: TcxCanvas);
begin
  DrawBarCaption(ACanvas);
end;

function TcxCustomProgressBarViewInfo.GetPercentDone: Integer;
begin
  Result := Math.Min(Round(RelativePosition * 100 / MaxMinDiff), 100);
end;

procedure TcxCustomProgressBarViewInfo.Offset(DX: Integer; DY: Integer);
begin
  inherited Offset(DX, DY);
  InflateRectEx(BarRect, DX, DY, DX, DY);
  InflateRectEx(ProgressBarRect, DX, DY, DX, DY);
  InflateRectEx(OverloadBarRect, DX, DY, DX, DY);
  InflateRectEx(PeakBarRect, DX, DY, DX, DY);
end;

procedure TcxCustomProgressBarViewInfo.Paint(ACanvas: TcxCanvas);
begin
  if ChangedBoundsBarRect then
    CreateBarBmp;
  if not Assigned(FUsualBitmap) then
    Exit;

  if not ChangedBounds and not (FShowText and (GetDrawText <> '')) then
    Exit;
  if Painter <> nil then
    PaintProgressBarByPainter(ACanvas)
  else
  begin
    if not (AreVisualStylesMustBeUsed(NativeStyle, totProgress) or
      IsInplace and Transparent) then
        DrawCustomEdit(ACanvas, Self, False, bpsSolid);
    PaintProgressBar(ACanvas);
  end;
end;

procedure TcxCustomProgressBarViewInfo.PaintProgressBar(ACanvas: TcxCanvas);
var
  ALEDsWidth: Integer;
  ADrawDelta: Integer;
  ABarRect: TRect;
  ADrawProgressBarRect: TRect;
  ADrawOverloadBarRect: TRect;
  ADrawPeakBarRect: TRect;
  ADrawAnimationBarRect: TRect;
  ASolidRect: TRect;
  APrevLogFont: TLogFont;
begin
  SaveCanvasFont(ACanvas, APrevLogFont);
  try
    ADrawDelta := GetDrawDelta;
    CalcDrawingParams(ADrawProgressBarRect, ADrawOverloadBarRect, ADrawPeakBarRect,
      ADrawAnimationBarRect, ASolidRect, ALEDsWidth);
    ABarRect := BarRect;
    if IsInplace then
      InflateRectEx(ABarRect, -BarRect.Left, -BarRect.Top, -BarRect.Left, -BarRect.Top);
    FUsualBitmap.cxCanvas.SaveClipRegion;
    try
      DrawBackground(FUsualBitmap.cxCanvas, ACanvas, ABarRect);
      if FMarquee and not IsInplace then
      begin
        ExcludeRects(FUsualBitmap.cxCanvas, ASolidRect);
        ExcludeRects(FUsualBitmap.cxCanvas, ADrawAnimationBarRect);
        ExcludeLEDRects(FUsualBitmap.cxCanvas, ADrawAnimationBarRect);
        ASolidRect := ADrawAnimationBarRect;
      end
      else
      begin
        ExcludeRects(FUsualBitmap.cxCanvas, ASolidRect);
        ExcludeLEDRects(FUsualBitmap.cxCanvas, ASolidRect);
      end;
      case FBarStyle of
        cxbsSolid, cxbsLEDs, cxbsGradient, cxbsGradientLEDs:
          begin
            if (FBarStyle in [cxbsSolid, cxbsLEDs]) and not NativeStyle then
              DrawSolidBar(FUsualBitmap.cxCanvas, ADrawProgressBarRect, ADrawOverloadBarRect)
            else
              DrawGradientBar(FUsualBitmap.cxCanvas, ADrawProgressBarRect, ADrawOverloadBarRect, ABarRect);
            if not IsLEDStyle then
              PaintBarBevelOuter(FUsualBitmap.cxCanvas, ASolidRect);
          end;
        cxbsBitmap, cxbsBitmapLEDs:
          if IsGlyphAssigned(FForegroundImage) then
            DrawBarBitmap(FUsualBitmap.cxCanvas, ASolidRect);
        cxbsAnimation, cxbsAnimationLEDs:
          begin
            if not (FMarquee and IsDesigning) then
              DrawAnimationBarBackground(FUsualBitmap.cxCanvas, ASolidRect, FBeginColor, True);
            if not FMarquee then
              DrawAnimationBar(FUsualBitmap.cxCanvas, ADrawAnimationBarRect, ASolidRect);
          end;
      end;
      if IsLEDStyle then
        DrawBorderLEDs(FUsualBitmap.cxCanvas, ASolidRect, ALEDsWidth);
      if not (FBarStyle in [cxbsAnimation, cxbsAnimationLEDs]) then
        DrawPeak(FUsualBitmap.cxCanvas, ADrawPeakBarRect);
    finally
      FUsualBitmap.cxCanvas.RestoreClipRegion;
    end;
    DrawText(FUsualBitmap.cxCanvas);
    BitBlt(ACanvas.Canvas.Handle, BarRect.Left, BarRect.Top,
      FUsualBitmap.Width, FUsualBitmap.Height, FUsualBitmap.cxCanvas.Handle,
      ADrawDelta, ADrawDelta, SRCCOPY);
  finally
    RestoreCanvasFont(ACanvas, APrevLogFont);
  end;
end;

procedure TcxCustomProgressBarViewInfo.PaintProgressBarByPainter(ACanvas: TcxCanvas);
var
  AChunkRect: TRect;
  AContentRect: TRect;
  ARect: TRect;
  AVertical: Boolean;

  function CalcRect(AVertical: Boolean; const AContentRect: TRect;
    AProgressKf: Double): TRect;
  begin
    Result := AContentRect;
    if AVertical then
      Inc(Result.Top, Trunc(RectHeight(Result) * (1 - AProgressKf)))
    else
      Result.Right := Result.Left + Trunc(RectWidth(Result) * AProgressKf);
  end;

  procedure DrawOverload(ACanvas: TcxCanvas);
  var
    AOverloadRect: TRect;
  begin
    AOverloadRect := CalcRect(AVertical, AContentRect, RelativeOverloadValue / MaxMinDiff);
    if AVertical then
    begin
      AOverloadRect.Bottom := AOverloadRect.Top;
      AOverloadRect.Top := AChunkRect.Top;
    end  
    else
    begin
      AOverloadRect.Left := AOverloadRect.Right;
      AOverloadRect.Right := AChunkRect.Right;
    end;  

    if not IsRectEmpty(AOverloadRect) then
      ACanvas.InvertRect(AOverloadRect);
  end;

begin
  if Painter = nil then Exit;
  ARect := Bounds;
  AVertical := Orientation = cxorVertical;
  OffsetRect(ARect, -ARect.Left, -ARect.Top);
  CreatePainterBitmap;
  if not Assigned(FPainterBitmap) then
    Exit;
  if not IsInplace then
    cxDrawTransparentControlBackground(Edit, FPainterBitmap.cxCanvas, Bounds)
  else
    cxEditFillRect(FPainterBitmap.cxCanvas, ARect, BackgroundColor);

  ARect := Rect(BarRect.Left - Bounds.Left, BarRect.Top - Bounds.Top,
    FPainterBitmap.Width - (Bounds.Right - BarRect.Right),
    FPainterBitmap.Height - (Bounds.Bottom - BarRect.Bottom));

  AContentRect := cxRectContent(ARect, Painter.ProgressBarBorderSize(AVertical));
  if FMarquee and not IsInplace then
    AChunkRect := GetCorrectAnimationBarRect
  else
    AChunkRect := CalcRect(AVertical, AContentRect, RelativePosition / MaxMinDiff);
  Painter.DrawProgressBarBorder(FPainterBitmap.cxCanvas, ARect, AVertical);
  FPainterBitmap.cxCanvas.SetClipRegion(TcxRegion.Create(AContentRect), roSet);
  Painter.DrawProgressBarChunk(FPainterBitmap.cxCanvas, AChunkRect, AVertical);

  if FRealShowOverload then
    DrawOverload(FPainterBitmap.cxCanvas);
  DrawText(FPainterBitmap.cxCanvas);
  cxBitBlt(ACanvas.Handle, FPainterBitmap.cxCanvas.Handle, Bounds, cxNullPoint, SRCCOPY);
end;

procedure TcxCustomProgressBarViewInfo.CalcDrawingParams(out ADrawProgressBarRect, ADrawOverloadBarRect,
  ADrawPeakBarRect, ADrawAnimationBarRect, ASolidRect: TRect; out ALEDsWidth: Integer);
begin
  ADrawProgressBarRect := ProgressBarRect;
  ADrawOverloadBarRect := OverloadBarRect;
  ADrawPeakBarRect := PeakBarRect;
  ADrawAnimationBarRect := GetCorrectAnimationBarRect;

  if IsInplace then
  begin
    InflateRectEx(ADrawProgressBarRect, -BarRect.Left, -BarRect.Top, -BarRect.Left, -BarRect.Top);
    InflateRectEx(ADrawOverloadBarRect, -BarRect.Left, -BarRect.Top, -BarRect.Left, -BarRect.Top);
    InflateRectEx(ADrawPeakBarRect, -BarRect.Left, -BarRect.Top, -BarRect.Left, -BarRect.Top);
    InflateRectEx(ADrawAnimationBarRect, -BarRect.Left, -BarRect.Top, -BarRect.Left, -BarRect.Top);
  end;

  ALEDsWidth := CalcLEDsWidth;

  if IsLEDStyle then
    AdjustForLEDsBarBounds(ADrawProgressBarRect, ADrawOverloadBarRect, ALEDsWidth);

  if not FRealShowOverload then
    ASolidRect := ADrawProgressBarRect
  else
    if FOrientation = cxorHorizontal then
      ASolidRect := Rect(ADrawProgressBarRect.Left, ADrawProgressBarRect.Top,
        ADrawOverloadBarRect.Right, ADrawOverloadBarRect.Bottom)
    else
      ASolidRect := Rect(ADrawOverloadBarRect.Left, ADrawOverloadBarRect.Top,
        ADrawProgressBarRect.Right, ADrawProgressBarRect.Bottom);
end;

function TcxCustomProgressBarViewInfo.CanAnimationBarShow: Boolean;
begin
  Result := (((FBarStyle in [cxbsAnimation, cxbsAnimationLEDs]) and not FMarquee) or FMarquee) and
    (FAnimationSpeed > 0) and not IsDesigning and not IsInplace;
end;

procedure TcxCustomProgressBarViewInfo.CreateBarBmp;
var
  ADrawDelta: Integer;
begin
  FreeAndNil(FUsualBitmap);
  FUsualBitmap := TcxBitmap.Create;
  ADrawDelta := GetDrawDelta;
  FUsualBitmap.Width := RectWidth(BarRect) + ADrawDelta;
  FUsualBitmap.Height := RectHeight(BarRect) + ADrawDelta;
  ChangedBoundsBarRect := False;
end;

procedure TcxCustomProgressBarViewInfo.CreateNativeBitmap(const ASize: TSize);
var
  ATheme: TdxTheme;
  ACreateNewBitmap: Boolean;
  ANativeBitmapRect: TRect;
begin
  ACreateNewBitmap := not Assigned(FNativeBitmap);
  if not ACreateNewBitmap and
      ((FNativeBitmap.Height <> ASize.cy) or (FNativeBitmap.Width <> ASize.cx)) then
    ACreateNewBitmap := True;
  if not ACreateNewBitmap then
    Exit;
  if not Assigned(FNativeBitmap) then
    FNativeBitmap := TBitmap.Create;    
  ATheme := OpenTheme(totProgress);
  FNativeBitmap.Width := ASize.cx;
  FNativeBitmap.Height := ASize.cy;
  ANativeBitmapRect := FNativeBitmap.Canvas.ClipRect;
  if FOrientation = cxorHorizontal then
  begin
    ANativeBitmapRect.Left := -4;
    DrawThemeBackground(ATheme, FNativeBitmap.Canvas.Handle, PP_CHUNK, 1,
      ANativeBitmapRect);
  end
  else
  begin
    ANativeBitmapRect.Top := -4;
    DrawThemeBackground(ATheme, FNativeBitmap.Canvas.Handle, PP_CHUNKVERT, 1,
      ANativeBitmapRect);
  end;
end;

procedure TcxCustomProgressBarViewInfo.CreatePainterBitmap;
var
  ACreateNewBitmap: Boolean;
begin
  ACreateNewBitmap := not Assigned(FPainterBitmap);
  if not ACreateNewBitmap and
      ((FPainterBitmap.Height <> RectHeight(Bounds)) or
      (FPainterBitmap.Width <> RectWidth(Bounds))) then
    ACreateNewBitmap := True;
  if not ACreateNewBitmap then
    Exit;
  FreeAndNil(FPainterBitmap);
  FPainterBitmap := TcxBitmap.CreateSize(Bounds);
end;

procedure TcxCustomProgressBarViewInfo.ExcludeRects(ACanvas: TcxCanvas; const ABounds: TRect);
begin
  if (FBarStyle in [cxbsAnimation, cxbsAnimationLEDs]) and
    NativeStyle then
  begin
    if FOrientation = cxorHorizontal then
    begin
      ACanvas.ExcludeClipRect(Rect(ABounds.Right, Bounds.Top, Bounds.Right, Bounds.Bottom));
      ACanvas.ExcludeClipRect(Rect(Bounds.Left, Bounds.Top, ABounds.Left, Bounds.Bottom));
    end
    else
    begin
      ACanvas.ExcludeClipRect(Rect(Bounds.Left, Bounds.Top, Bounds.Right, ABounds.Top));
      ACanvas.ExcludeClipRect(Rect(Bounds.Left, ABounds.Bottom, Bounds.Right, Bounds.Bottom))
    end;
  end
  else
    ACanvas.SetClipRegion(TcxRegion.Create(ABounds), roIntersect);
end;
procedure TcxCustomProgressBarViewInfo.ExcludeLEDRects(ACanvas: TcxCanvas;
  const ABounds: TRect);
var
  I, ALEDsWidth, ALEDsMaxCount: Integer;
begin
  ALEDsWidth := CalcLEDsWidth;
  if IsLEDStyle then
  begin
    if FOrientation = cxorHorizontal then
    begin
      ALEDsMaxCount := RectWidth(ABounds) div ALEDsWidth;
      for I := 1 to ALEDsMaxCount do
        ACanvas.ExcludeClipRect(Rect(ABounds.Left + I * ALEDsWidth - 2, ABounds.Top,
          ABounds.Left + I * ALEDsWidth, ABounds.Bottom));
    end
    else
    begin
      ALEDsMaxCount := RectHeight(ABounds) div ALEDsWidth;
      for I := 1 to ALEDsMaxCount do
        ACanvas.ExcludeClipRect(Rect(ABounds.Left, ABounds.Bottom - I * ALEDsWidth,
          ABounds.Right, ABounds.Bottom - I * ALEDsWidth + 2));
    end;
  end;
end;

function TcxCustomProgressBarViewInfo.GetAnimationTimerInterval: Cardinal;
begin
  if FAnimationSpeed <= High(FAnimationSpeed) div 2 then
    Result := 30
  else
    Result := 30 + (High(FAnimationSpeed) - FAnimationSpeed) * 4;
end;

function TcxCustomProgressBarViewInfo.GetAnimationOffset: Integer;
begin
  if FAnimationSpeed >= High(FAnimationSpeed) div 2 then
    Result := 2
  else
    Result := 2 + (FAnimationSpeed + High(FAnimationSpeed)) * 2;
end;

function TcxCustomProgressBarViewInfo.GetMaxMinDiff: Double;
begin
  Result := Max - Min;
  if Result = 0 then
    Result := 1;
end;

function TcxCustomProgressBarViewInfo.GetRelativeOverloadValue: Double;
begin
  Result := OverloadValue - Min;
end;

function TcxCustomProgressBarViewInfo.GetRelativePeakValue: Double;
begin
  Result := PeakValue - Min;
end;

function TcxCustomProgressBarViewInfo.GetRelativePosition: Double;
begin
  if FMarquee then
    Result := Max
  else
    Result := Position - Min;
end;

function TcxCustomProgressBarViewInfo.IsLEDStyle: Boolean;
begin
  Result := FBarStyle in [cxbsLEDs, cxbsGradientLEDs, cxbsBitmapLEDs,
    cxbsAnimationLEDs];
end;

procedure TcxCustomProgressBarViewInfo.DrawBackground(ACanvas: TcxCanvas; const ACanvasParent: TcxCanvas; const ABounds: TRect);
const
  BarThemeTypeMap: array[TcxProgressBarOrientation] of Integer = (PP_BAR, PP_BARVERT);
begin
  if PropTransparent then
  begin
    if not IsInplace then
    begin
      cxDrawTransparentControlBackground(Edit, ACanvas, Bounds);
    end
    else
    begin
      BitBlt(ACanvas.Handle, 0, 0,
        ABounds.Right - ABounds.Left, ABounds.Bottom - ABounds.Top,
        ACanvasParent.Handle, BarRect.Left, BarRect.Top, SRCCOPY);
    end;
  end
  else
  begin
    if not (FBarStyle in [cxbsAnimation, cxbsAnimationLEDs]) then
    begin
      ACanvas.Brush.Style := bsSolid;
      ACanvas.FillRect(ABounds, BackgroundColor);
    end;
  end;
  if (NativeStyle or (FBarStyle in [cxbsAnimation, cxbsAnimationLEDs])) and
    not IsInplace and not PropTransparent then
  begin
    if NativeStyle then
      DrawThemeBackground(OpenTheme(totProgress), ACanvas.Handle, BarThemeTypeMap[FOrientation], 1, ABounds);
  end;
  if (FBarStyle in [cxbsAnimation, cxbsAnimationLEDs]) then
  begin
    if NativeStyle then
      ACanvas.SetClipRegion(TcxRegion.CreateRoundCorners(ABounds, 2, 2), roIntersect);
    if not PropTransparent then
      DrawAnimationBarBackground(ACanvas, ABounds, BackgroundColor, False);
  end;
end;

function TcxCustomProgressBarViewInfo.GetDrawDelta: Integer;
begin
  if NativeStyle or IsInplace or (Painter <> nil) then
    Result := 0
  else
    Result := 2;
end;

function TcxCustomProgressBarViewInfo.GetDrawText: string;
begin
  Result := '';
  case FShowTextStyle of
    cxtsPercent:
      Result := IntToStr(GetPercentDone) + ' %';
    cxtsPosition:
      Result := FloatToStr(FPosition);
    cxtsText:
      Result := Text;
  end;
  if FMarquee then
    Result := Text;
end;

procedure TcxCustomProgressBarViewInfo.DrawBarCaption(ACanvas: TcxCanvas);
var
  ABarText: string;
  ATextBmp, ATextSavedBmp: TcxBitmap;
  ATextRect: TRect;
  ABarRect: TRect;
begin
  if  not FShowText then Exit;
  ABarRect := BarRect;
  if IsInplace then
    InflateRectEx(ABarRect, -BarRect.Left, -BarRect.Top,  -BarRect.Left, -BarRect.Top);
  ABarText := GetDrawText;
  ACanvas.Font.Assign(Font);
  if (Painter = nil) or ((Painter <> nil) and (Painter.ProgressBarTextColor = clDefault)) then
    ACanvas.Font.Color := TextColor
  else
    ACanvas.Font.Color := Painter.ProgressBarTextColor;
  ACanvas.Brush.Style := bsClear;
  if FTextOrientation = cxorVertical then
    ACanvas.SetFontAngle(270);
  ATextRect := Rect(0, 0, ACanvas.TextWidth(ABarText), ACanvas.TextHeight(ABarText));
  if FTextOrientation = cxorVertical then
    ATextRect := Rect(ATextRect.Top, ATextRect.Left, ATextRect.Bottom, ATextRect.Right);
  OffsetRect(ATextRect, GetDrawDelta, GetDrawDelta);
  OffsetRect(ATextRect,
    (RectWidth(ABarRect) - RectWidth(ATextRect)) div 2,
    (RectHeight(ABarRect) - RectHeight(ATextRect)) div 2);
  if (SolidTextColor = False) and (Painter = nil) then
  begin
    ATextBmp := TcxBitmap.Create;
    ATextSavedBmp := TcxBitmap.Create;
    try
      ATextBmp.Width := RectWidth(ABarRect);
      ATextBmp.Height := RectHeight(ABarRect);
      ATextSavedBmp.Width := ATextBmp.Width;
      ATextSavedBmp.Height := ATextBmp.Height;
      ATextBmp.cxCanvas.Font.Assign(ACanvas.Font);
      ATextBmp.cxCanvas.Font.Color := clBlack;
      ATextBmp.cxCanvas.Brush.Color := clWhite;
      ATextBmp.cxCanvas.FillRect(ABarRect);
      if FTextOrientation = cxorVertical then
        TextOut(ATextBmp.cxCanvas.Handle, ATextRect.Right, ATextRect.Top, PChar(ABarText), Length(ABarText))
      else
        TextOut(ATextBmp.cxCanvas.Handle, ATextRect.Left, ATextRect.Top, PChar(ABarText), Length(ABarText));
      BitBlt(ATextSavedBmp.cxCanvas.Handle, 0, 0, ATextBmp.Width, ATextBmp.Height,
        ACanvas.Handle, 0, 0, SRCCOPY);
      BitBlt(ATextBmp.cxCanvas.Handle, 0, 0, ATextBmp.Width, ATextBmp.Height,
        ACanvas.Handle, 0, 0, DSTINVERT);
      cxTextOut(ACanvas.Handle, ABarText, Bounds, CXTO_CENTER_HORIZONTALLY or CXTO_CENTER_VERTICALLY);
      ACanvas.CopyMode := cmSrcCopy;
      ACanvas.Draw(0, 0, ATextSavedBmp);
      ACanvas.CopyMode := cmSrcInvert;
      ACanvas.Draw(0, 0, ATextBmp);
    finally
      FreeAndNil(ATextBmp);
      FreeAndNil(ATextSavedBmp);
    end;
  end
  else
    if FTextOrientation = cxorVertical then
      TextOut(ACanvas.Handle, ATextRect.Right, ATextRect.Top, PChar(ABarText), Length(ABarText))
    else
      TextOut(ACanvas.Handle, ATextRect.Left, ATextRect.Top, PChar(ABarText), Length(ABarText));
end;

procedure TcxCustomProgressBarViewInfo.PaintBarBevelOuter(
  ACanvas: TcxCanvas; ABBORect: TRect);
begin
  if FBarBevelOuter = cxbvLowered then
  begin
    DrawEdge(ACanvas.Handle, ABBORect, BDR_SUNKENOUTER, BF_TOPLEFT);
    DrawEdge(ACanvas.Handle, ABBORect, BDR_SUNKENOUTER, BF_BOTTOMRIGHT);
  end;
  if FBarBevelOuter = cxbvRaised then
  begin
    DrawEdge(ACanvas.Handle, ABBORect, BDR_RAISEDINNER, BF_TOPLEFT);
    DrawEdge(ACanvas.Handle, ABBORect, BDR_RAISEDINNER, BF_BOTTOMRIGHT);
  end;
end;

procedure TcxCustomProgressBarViewInfo.DrawBarBitmap(ACanvas: TcxCanvas; ARect: TRect);
begin
  ACanvas.Brush.Bitmap := FForegroundImage;
  ACanvas.FillRect(ARect);
end;

procedure TcxCustomProgressBarViewInfo.DrawGradientBar(ACanvas: TcxCanvas; const ANormalRect, AOverloadRect, ABarRect: TRect);
var
  ASize: TSize;
  R: TRect;
begin
  with ACanvas do
  begin
    if NativeStyle then
    begin
      if FOrientation = cxorHorizontal then
      with ANormalRect do
      begin
        ASize.cx := 1;
        if RectHeight(ANormalRect) < 0 then
          ASize.cy := 0
        else
          ASize.cy := RectHeight(ANormalRect);
        CreateNativeBitmap(ASize);
        if not Assigned(FNativeBitmap) then
          Exit;
        StretchBlt(Handle, ANormalRect.Left, ANormalRect.Top, RectWidth(ANormalRect),
          RectHeight(ANormalRect), FNativeBitmap.Canvas.Handle, 0, 0,
          FNativeBitmap.Width, FNativeBitmap.Height, SRCCOPY);
      end
      else
        with ANormalRect do
        begin
          ASize.cy := 1;
          if RectWidth(ANormalRect) < 0 then
            ASize.cx := 0
          else
            ASize.cx := RectWidth(ANormalRect);
          CreateNativeBitmap(ASize);
          if not Assigned(FNativeBitmap) then
            Exit;
          StretchBlt(Handle, ANormalRect.Left, ANormalRect.Top, RectWidth(ANormalRect),
            RectHeight(ANormalRect), FNativeBitmap.Canvas.Handle, 0, 0,
            FNativeBitmap.Width, FNativeBitmap.Height, SRCCOPY);
        end;
    end
    else
      if FOrientation = cxorHorizontal then
        FillGradientRect(Handle, ABarRect, FBeginColor, FEndColor, True)
      else
        FillGradientRect(Handle, ABarRect, FEndColor, FBeginColor, False);

    if FRealShowOverload then
    begin
      R := AOverloadRect;
      R.Right := ABarRect.Right;
      R.Top := ABarRect.Top;
      if FOrientation = cxorHorizontal then
        FillGradientRect(Handle, R, FOverloadBeginColor, FOverloadEndColor, True)
      else
        FillGradientRect(Handle, R, FOverloadEndColor, FOverloadBeginColor, False);
    end;
  end;
end;

procedure TcxCustomProgressBarViewInfo.DrawSolidBar(ACanvas: TcxCanvas; const ANormalRect, AOverloadRect: TRect);
begin
  with ACanvas do
  begin
    cxEditFillRect(ACanvas, ANormalRect, FBeginColor);
    if FRealShowOverload then
      cxEditFillRect(ACanvas, AOverloadRect, FOverloadBeginColor);
  end;
end;

procedure TcxCustomProgressBarViewInfo.DrawAnimationBar(ACanvas: TcxCanvas; const ABar, ASolidRect: TRect);

  procedure LightCanvasByGradient(ACanvas: TcxCanvas; const ARect: TRect; AIsHorizontal: Boolean = True);
  var
    I: Integer;
    ABeginColor: TColor;
    AEndColor: TColor;
    ACurrentPercentage: Byte;
    ADeltaPercentage: Byte;
    AWidth: Integer;
  begin
    if AIsHorizontal then
    begin
      AWidth := RectWidth(ARect) div 2;
      for I := ARect.Top to (ARect.Top + cxAnimationBarTopPartWidth - 1) do
      begin
        ABeginColor := ACanvas.Canvas.Pixels[ASolidRect.Left + 1, I];
        AEndColor := Light(ABeginColor, cxAnimationBarColorLightPercentage);
        FillGradientRect(ACanvas.Handle, Rect(ARect.Left - AWidth, I,
          ARect.Left + AWidth - cxAnimationBarMiddlePartWidth div 2, I + 1),
          ABeginColor, AEndColor, True);
        FillRectByColor(ACanvas.Handle, Rect(ARect.Left + AWidth - cxAnimationBarMiddlePartWidth div 2,
          I, ARect.Left + AWidth + cxAnimationBarMiddlePartWidth div 2, I +1), AEndColor);
        FillGradientRect(ACanvas.Handle, Rect(ARect.Left + AWidth + cxAnimationBarMiddlePartWidth div 2,
          I, ARect.Right + AWidth, I + 1), AEndColor, ABeginColor, True);
      end;
      ACanvas.SaveClipRegion;
      try
        ACanvas.SetClipRegion(TcxRegion.Create(Rect(ARect.Left, ARect.Top,
          ARect.Right, ARect.Bottom)), roIntersect);
        for I := ARect.Left to ARect.Right do
        begin
          ACurrentPercentage := cxAnimationBarColorLightPercentage;
          ADeltaPercentage := 0;
          if I < (AWidth + ARect.Left - cxAnimationBarMiddlePartWidth div 2) then
            ADeltaPercentage := (100 - cxAnimationBarColorLightPercentage) *
              (AWidth + ARect.Left - (cxAnimationBarMiddlePartWidth div 2) - I) div
              (AWidth - cxAnimationBarMiddlePartWidth div 2)
          else
            if I > (AWidth + ARect.Left + cxAnimationBarMiddlePartWidth div 2) then
              ADeltaPercentage := (100 - cxAnimationBarColorLightPercentage) *
                (I - AWidth - ARect.Left - cxAnimationBarMiddlePartWidth div 2) div
                (AWidth - cxAnimationBarMiddlePartWidth div 2);
          Inc(ACurrentPercentage, ADeltaPercentage);
          ABeginColor := ACanvas.Canvas.Pixels[I, ARect.Top + cxAnimationBarTopPartWidth];
          AEndColor := Light(ABeginColor, ACurrentPercentage);
          ACanvas.FillRect(Rect(I, ARect.Top + cxAnimationBarTopPartWidth, I + 1,
            ARect.Bottom), AEndColor);
        end;
      finally
        ACanvas.RestoreClipRegion;
      end;
    end
    else
    begin
      AWidth := RectHeight(ARect) div 2;
      for I := ARect.Left to (ARect.Left + cxAnimationBarTopPartWidth - 1) do
      begin
        ABeginColor := GetPixel(ACanvas.Handle, I, ASolidRect.Bottom - 2);
        AEndColor := Light(ABeginColor, cxAnimationBarColorLightPercentage);
        FillGradientRect(ACanvas.Handle, Rect(I, ARect.Top - AWidth, I + 1,
          ARect.Top + AWidth - cxAnimationBarMiddlePartWidth div 2), ABeginColor, AEndColor, False);
        ACanvas.FillRect(Rect(I, ARect.Top + AWidth - cxAnimationBarMiddlePartWidth div 2,
          I + 1, ARect.Top + AWidth + cxAnimationBarMiddlePartWidth div 2), AEndColor);
        FillGradientRect(ACanvas.Handle, Rect(I, ARect.Top + AWidth + cxAnimationBarMiddlePartWidth div 2,
          I + 1, ARect.Bottom + AWidth), AEndColor, ABeginColor, False);
      end;
      ACanvas.SaveClipRegion;
      try
        ACanvas.SetClipRegion(TcxRegion.Create(Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom)), roIntersect);
        for I := ARect.Top to ARect.Bottom do
        begin
          ACurrentPercentage := cxAnimationBarColorLightPercentage;
          ADeltaPercentage := 0;
          if I < (AWidth + ARect.Top - cxAnimationBarMiddlePartWidth div 2) then
            ADeltaPercentage := (100 - cxAnimationBarColorLightPercentage) *
              (AWidth + ARect.Top - (cxAnimationBarMiddlePartWidth div 2) - I) div
              (AWidth - cxAnimationBarMiddlePartWidth div 2)
          else
            if I > (AWidth + ARect.Top + cxAnimationBarMiddlePartWidth div 2) then
              ADeltaPercentage := (100 - cxAnimationBarColorLightPercentage) *
                (I - AWidth - ARect.Top - cxAnimationBarMiddlePartWidth div 2) div
                (AWidth - cxAnimationBarMiddlePartWidth div 2);
          Inc(ACurrentPercentage, ADeltaPercentage);
          ABeginColor := ACanvas.Canvas.Pixels[ARect.Left + cxAnimationBarTopPartWidth, I];
          if (ABeginColor < 0) or (ABeginColor >= (1 shl 24)) then
            Continue;
          AEndColor := Light(ABeginColor, ACurrentPercentage);
          ACanvas.FillRect(Rect(ARect.Left + cxAnimationBarTopPartWidth, I, ARect.Right, I + 1), AEndColor);
        end;
      finally
        ACanvas.RestoreClipRegion;
      end;
    end;
  end;

begin
  if not CanAnimationBarShow then
  begin
    StopAnimationTimer;
    Exit;
  end;
  if not Assigned(FAnimationTimer) then
  begin
    if FAnimationSpeed > 0 then
      StartAnimationTimer;
    Exit;
  end;
  LightCanvasByGradient(ACanvas, ABar, (FOrientation = cxorHorizontal));
end;

procedure TcxCustomProgressBarViewInfo.DrawAnimationBarBackground(ACanvas: TcxCanvas; const ASolidRect: TRect; ASolidColor: TColor; ADrawBar: Boolean);
var
  ABorderBeginColor, ABorderEndColor: TColor;
  ATopBorderBeginColor, ATopBorderEndColor: TColor;
  ABorderExtPathWidth, ABorderIntPathWidth, ABorderWidth: Integer;
begin
  ATopBorderBeginColor := Light(ASolidColor, cxAnimationBarTopBeginColorLightPercentage);
  ATopBorderEndColor := Light(ASolidColor, cxAnimationBarTopEndColorLightPercentage);
  ABorderBeginColor := Dark(ASolidColor, cxAnimationBarBorderExtPartColorLightPercentage);
  ABorderEndColor := Dark(ASolidColor, cxAnimationBarBorderIntPartColorLightPercentage);

  if ADrawBar then
  begin
    ABorderExtPathWidth := cxAnimationBarBorderExtPathWidth;
    ABorderIntPathWidth := cxAnimationBarBorderIntPathWidth;
end
  else
  begin
    ABorderExtPathWidth := 1;
    ABorderIntPathWidth := cxAnimationBarBackgroundBorderWidth;
  end;
  ABorderWidth := ABorderExtPathWidth + ABorderIntPathWidth;

  with ACanvas do
  begin
    cxEditFillRect(ACanvas, ASolidRect, ASolidColor);
    if FOrientation = cxorHorizontal then
    begin
      if ADrawBar and (RectWidth(ASolidRect) < 3 * ABorderWidth) then
      begin
        ABorderExtPathWidth := ABorderExtPathWidth * RectWidth(ASolidRect) div (3 * ABorderWidth);
        ABorderIntPathWidth := ABorderIntPathWidth * RectWidth(ASolidRect) div (3 * ABorderWidth);
      end;
      ABorderWidth := ABorderIntPathWidth + ABorderExtPathWidth;

      with ASolidRect do
      begin
        FillGradientRect(Handle, Rect(Left, Top, Left + ABorderExtPathWidth, Bottom),
          ABorderBeginColor, ABorderEndColor, True);
        FillGradientRect(Handle, Rect(Right - ABorderExtPathWidth, Top, Right, Bottom),
          ABorderEndColor, ABorderBeginColor, True);

        FillGradientRect(Handle, Rect(Left + ABorderExtPathWidth, Top, Left + ABorderWidth,
          Bottom), ABorderEndColor, ASolidColor, True);
        FillGradientRect(Handle, Rect(Right - ABorderWidth, Top, Right - ABorderExtPathWidth, Bottom),
          ASolidColor, ABorderEndColor, True);

        FillGradientRect(Handle, Rect(Left, Top, Right, Top + cxAnimationBarTopPartWidth),
          ATopBorderBeginColor, ATopBorderEndColor, False);
      end;
    end
    else
    begin
      if RectHeight(ASolidRect) < 3 * ABorderWidth then
      begin
        ABorderExtPathWidth := ABorderExtPathWidth * RectHeight(ASolidRect) div (3 * ABorderWidth);
        ABorderIntPathWidth := ABorderIntPathWidth * RectHeight(ASolidRect) div (3 * ABorderWidth);
      end;
      ABorderWidth := ABorderIntPathWidth + ABorderExtPathWidth;

      with ASolidRect do
      begin
        FillGradientRect(Handle, Rect(Left, Top, Right, Top + ABorderExtPathWidth),
          ABorderBeginColor, ABorderEndColor, False);
        FillGradientRect(Handle, Rect(Left, Bottom - ABorderExtPathWidth, ASolidRect.Right, Bottom),
          ABorderEndColor, ABorderBeginColor, False);

        FillGradientRect(Handle, Rect(Left, Top + ABorderExtPathWidth, Right,
          Top + ABorderWidth), ABorderEndColor, ASolidColor, False);
        FillGradientRect(Handle, Rect(Left, Bottom - ABorderWidth, Right, Bottom - ABorderExtPathWidth),
          ASolidColor, ABorderEndColor, False);

        FillGradientRect(Handle, Rect(Left, Top, Left + cxAnimationBarTopPartWidth,
          Bottom), ATopBorderBeginColor, ATopBorderEndColor, True);
      end;
    end;
  end;
end;

function TcxCustomProgressBarViewInfo.CalcLEDsWidth: Integer;
begin
  if FOrientation = cxorHorizontal then
  begin
    Result := Trunc(RectHeight(ProgressBarRect) * 2 / 3) + 2;
    if (FBarStyle = cxbsBitmapLEDs) and
        Assigned(FForegroundImage) and
        (Result > FForegroundImage.Width) and
        (FForegroundImage.Width > 0) then
      Result := FForegroundImage.Width;
  end
  else
  begin
    Result := Trunc(RectWidth(ProgressBarRect) * 2 / 3) + 2;
    if (FBarStyle = cxbsBitmapLEDs) and
        Assigned(FForegroundImage) and
        (Result > FForegroundImage.Height) and
        (FForegroundImage.Height > 0) then
      Result := FForegroundImage.Height;
  end;
end;

procedure TcxCustomProgressBarViewInfo.AdjustForLEDsBarBounds(var ABarRect,
  AOverloadBarRect: TRect; const ALEDsWidth: Integer);
var
  ALEDsDelta: Integer;
begin
  if FOrientation = cxorHorizontal then
  begin
    if FRealShowOverload then
    begin
      ALEDsDelta := RectWidth(ABarRect) mod ALEDsWidth;
      Dec(ABarRect.Right, ALEDsDelta);
      Dec(AOverloadBarRect.Left, ALEDsDelta);
    end;
  end
  else
  begin
    if FRealShowOverload then
    begin
      ALEDsDelta := RectHeight(ABarRect) mod ALEDsWidth;
      Inc(ABarRect.Top, ALEDsDelta);
      Inc(AOverloadBarRect.Bottom, ALEDsDelta);
    end;
  end;
end;

procedure TcxCustomProgressBarViewInfo.DrawPeak(ACanvas: TcxCanvas; const APeakRect: TRect);
begin
  if FRealShowPeak = True then
  begin
    ACanvas.SetClipRegion(TcxRegion.Create(APeakRect), roAdd);
    cxEditFillRect(ACanvas, APeakRect, FPeakColor);
  end;
end;

procedure TcxCustomProgressBarViewInfo.DrawBorderLEDs(ACanvas: TcxCanvas;
  const ABarRect: TRect; ALEDsWidth: Integer);
var
  I, AMaxCount: Integer;
begin
  if FBarBevelOuter = cxbvNone then
    Exit;
  if FOrientation = cxorHorizontal then
  begin
    AMaxCount := RectWidth(ABarRect) div ALEDsWidth;
    for I := 1 to AMaxCount do
    begin
      PaintBarBevelOuter(ACanvas, Rect(ABarRect.Left + (I - 1) * ALEDsWidth, ABarRect.Top,
        ABarRect.Left + I * ALEDsWidth - 2, ABarRect.Bottom));
    end;
    if (ABarRect.Left + AMaxCount * ALEDsWidth) < ABarRect.Right then
      PaintBarBevelOuter(ACanvas, Rect(ABarRect.Left + AMaxCount * ALEDsWidth,
        ABarRect.Top, ABarRect.Right, ABarRect.Bottom));
  end
  else
  begin
    AMaxCount := RectHeight(ABarRect) div ALEDsWidth;
    for I := 1 to AMaxCount do
    begin
      PaintBarBevelOuter(ACanvas, Rect(ABarRect.Left, ABarRect.Bottom - (I - 1) * ALEDsWidth,
        ABarRect.Right, ABarRect.Bottom - I * ALEDsWidth + 2));
    end;
    if (ABarRect.Bottom - AMaxCount * ALEDsWidth) > ABarRect.Top then
      PaintBarBevelOuter(ACanvas, Rect(ABarRect.Left, ABarRect.Bottom - AMaxCount * ALEDsWidth,
        ABarRect.Right, ABarRect.Top));
  end;
end;

procedure TcxCustomProgressBarViewInfo.DoAnimationTimer(Sender: TObject);
begin
  if not CanAnimationBarShow then
    StopAnimationTimer;
  if not Assigned(FAnimationTimer) then Exit;
  CalcAnimationCurrentPosition;
  Edit.Repaint;
end;

procedure TcxCustomProgressBarViewInfo.DoAnimationRestartDelayTimer(Sender: TObject);
begin
  StopAnimationRestartDelayTimer;
end;

procedure TcxCustomProgressBarViewInfo.StartAnimationTimer;
begin
  if Assigned(FAnimationTimer) then
    StopAnimationTimer;
  if not CanAnimationBarShow then
    Exit;
  FAnimationTimer := TcxTimer.Create(nil);
  with FAnimationTimer do
  begin
    Enabled := False;
    Interval := GetAnimationTimerInterval;
    OnTimer := DoAnimationTimer;
    Enabled := True;
  end;
  SetAnimationFirstPosition;
end;

procedure TcxCustomProgressBarViewInfo.StartAnimationRestartDelayTimer;
begin
  if FAnimationRestartDelayTimer <> nil then
    StopAnimationRestartDelayTimer;
  if FAnimationRestartDelay = 0 then
    Exit;
  FAnimationRestartDelayTimer := TcxTimer.Create(nil);
  with FAnimationRestartDelayTimer do
  begin
    Enabled := False;
    Interval := AnimationRestartDelay;
    OnTimer := DoAnimationRestartDelayTimer;
    Enabled := True;
  end;
end;

procedure TcxCustomProgressBarViewInfo.StopAnimationTimer;
begin
  FreeAndNil(FAnimationTimer);
end;

procedure TcxCustomProgressBarViewInfo.StopAnimationRestartDelayTimer;
begin
  FreeAndNil(FAnimationRestartDelayTimer);
end;

procedure TcxCustomProgressBarViewInfo.SetAnimationPath(AValue: TcxProgressBarAnimationPath);
begin
  if AValue <> FAnimationPath then
  begin
    FAnimationPath := AValue;
    StartAnimationTimer;
  end;
end;

procedure TcxCustomProgressBarViewInfo.SetAnimationSpeed(AValue: Cardinal);
begin
  if AValue <> FAnimationSpeed then
  begin
    FAnimationSpeed := AValue;
    if Assigned(FAnimationTimer) then
    begin
      FAnimationTimer.Interval := GetAnimationTimerInterval;
      if FAnimationSpeed = 0 then
        StopAnimationTimer;
    end
    else
      if FAnimationSpeed > 0 then
        StartAnimationTimer;
  end;
end;

procedure TcxCustomProgressBarViewInfo.SetMarquee(AValue: Boolean);
begin
  if AValue <> FMarquee then
  begin
    FMarquee := AValue;
    StartAnimationTimer;
  end;
end;

procedure TcxCustomProgressBarViewInfo.SetBarStyle(
  AValue: TcxProgressBarBarStyle);
begin
  if AValue <> FBarStyle then
  begin
    FBarStyle := AValue;
    StartAnimationTimer;
  end;
end;

procedure TcxCustomProgressBarViewInfo.CalcAnimationCurrentPosition;
begin
  if FAnimationRestartDelayTimer <> nil then Exit;
  Inc(FAnimationPosition, FAnimationDirection * GetAnimationOffset);
  case FAnimationPath of
    cxapCycle:
      if (FAnimationPosition > (GetMaxPositionInBounds + GetAnimationBarDimension div 2)) or
          (FAnimationPosition < (GetMinPositionInBounds - GetAnimationBarDimension div 2)) then
      begin
        SetAnimationFirstPosition;
        StartAnimationRestartDelayTimer;
      end;
    cxapPingPong:
      begin
        if FAnimationDirection > 0 then
        begin
          if FAnimationPosition > (GetMaxPositionInBounds - GetAnimationBarDimension div 2) then
          begin
            FAnimationDirection := -FAnimationDirection;
            Dec(FAnimationPosition);
            StartAnimationRestartDelayTimer;
          end;
        end
        else
        begin
          if FAnimationPosition < (GetMinPositionInBounds + GetAnimationBarDimension div 2) then
          begin
            FAnimationDirection := -FAnimationDirection;
            Inc(FAnimationPosition);
            StartAnimationRestartDelayTimer;
          end;
        end;
      end;
  end;
end;

procedure TcxCustomProgressBarViewInfo.SetAnimationFirstPosition;
begin
  case FAnimationPath of
    cxapCycle:
      if GetAnimationDerection > 0 then
        FAnimationPosition := -GetAnimationBarDimension div 2
      else
        FAnimationPosition := GetAnimationBarDimension div 2;
    cxapPingPong:
      FAnimationPosition := GetAnimationBarDimension div 2;
  end;
  if FOrientation = cxorHorizontal then
    FAnimationDirection := GetAnimationDerection
  else
  begin
    FAnimationDirection := -GetAnimationDerection;
    FAnimationPosition := -FAnimationPosition;
  end;
  if FAnimationDirection > 0 then
    Inc(FAnimationPosition, GetMinPositionInBounds)
  else
    Inc(FAnimationPosition, GetMaxPositionInBounds);
end;

function TcxCustomProgressBarViewInfo.GetAnimationBarDimension: Integer;
begin
  Result := 50;
end;

function TcxCustomProgressBarViewInfo.GetAnimationDerection: Integer;
begin
  Result := 1;  
end;

function TcxCustomProgressBarViewInfo.GetCorrectAnimationBarRect: TRect;
begin
  Result := AnimationBarRect;
  if FOrientation = cxorHorizontal then
    OffsetRect(Result, FAnimationPosition, 0)
  else
    OffsetRect(Result, 0, FAnimationPosition);
end;

function TcxCustomProgressBarViewInfo.GetMaxPositionInBounds: Integer;
begin
  if FOrientation = cxorHorizontal then
    Result := Trunc(RectWidth(Bounds) / GetMaxMinDiff * GetRelativePosition)
  else
    Result := RectHeight(Bounds);
end;

function TcxCustomProgressBarViewInfo.GetMinPositionInBounds: Integer;
begin
  if FOrientation = cxorHorizontal then
    Result := 0
  else
    Result := RectHeight(Bounds) - Trunc(RectHeight(Bounds) / GetMaxMinDiff * GetRelativePosition);
end;

procedure TcxCustomProgressBarViewInfo.SetOrientation(
  AValue: TcxProgressBarOrientation);
begin
  if AValue <> FOrientation then
  begin
    FOrientation := AValue;
    StartAnimationTimer;
  end;
end;

{ TcxCustomProgressBarViewData }

procedure TcxCustomProgressBarViewData.CalculateViewInfoProperties(AViewInfo: TcxCustomEditViewInfo);
begin
  with TcxCustomProgressBarViewInfo(AViewInfo) do
  begin
    AnimationPath := Properties.AnimationPath;
    AnimationRestartDelay := Properties.AnimationRestartDelay;
    AnimationSpeed := Properties.AnimationSpeed;
    BeginColor := ColorToRGB(Properties.BeginColor);
    EndColor := ColorToRGB(Properties.EndColor);
    BarBevelOuter := Properties.BarBevelOuter;
    Marquee := Properties.Marquee;
    Min := Properties.Min;
    Max := Properties.Max;
    Orientation := Properties.Orientation;
    ShowText := Properties.ShowText;
    ShowTextStyle := Properties.ShowTextStyle;
    Text := Properties.Text;
    TextOrientation := Properties.TextOrientation;
    SolidTextColor := Properties.SolidTextColor;
    BarStyle := Properties.BarStyle;
    BorderWidth := Properties.BorderWidth;
    OverloadValue := Properties.OverloadValue;
    OverloadBeginColor := ColorToRGB(Properties.OverloadBeginColor);
    OverloadEndColor := ColorToRGB(Properties.OverloadEndColor);
    ShowOverload := Properties.ShowOverload;
    PeakValue := Properties.GetRealPeakValue(Position);
    PeakColor := ColorToRGB(Properties.PeakColor);
    PeakSize := Properties.PeakSize;
    ShowPeak := Properties.ShowPeak;
    if IsInplace then
      PropTransparent := Transparent
    else
      PropTransparent := TcxCustomProgressBar(Edit).Transparent;
  end;
end;

procedure TcxCustomProgressBarViewData.Calculate(ACanvas: TcxCanvas; const ABounds: TRect;
  const P: TPoint; Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
  AIsMouseEvent: Boolean);
var
  FBounds : TRect;
  FViewInfo : TcxCustomProgressBarViewInfo;
  FRealNativeStyle: Boolean;
  FBmp: TBitmap;
  AProgressBarRect, ABarRect: TRect;
  AOverloadBarRect, APeakBarRect: TRect;
begin
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);
  if (ABounds.Bottom = MaxInt) or (ABounds.Right = MaxInt) then Exit; // B94428
  FViewInfo := TcxCustomProgressBarViewInfo(AViewInfo);
  CalculateViewInfo(FViewInfo, AIsMouseEvent);
  FViewInfo.Font := Style.GetVisibleFont;
  CalculateViewInfoProperties(AViewInfo);
  if AreVisualStylesMustBeUsed(NativeStyle, totProgress) then
  begin
    FBounds := ABounds;
    FRealNativeStyle := True;
    ABarRect := ABounds;
    if IsInplace then
      InflateRectEx(FBounds, (AViewInfo.BorderWidth + 2), (AViewInfo.BorderWidth + 2),
        -(AViewInfo.BorderWidth + 2), -(AViewInfo.BorderWidth + 2))
    else
      if not (Properties.BarStyle in [cxbsAnimation, cxbsAnimationLEDs]) then
        InflateRectEx(FBounds, (AViewInfo.BorderWidth + 3), (AViewInfo.BorderWidth + 3),
          -(AViewInfo.BorderWidth + 2), -(AViewInfo.BorderWidth + 2))
      else
        InflateRectEx(FBounds, (AViewInfo.BorderWidth + 1), (AViewInfo.BorderWidth + 1),
          -(AViewInfo.BorderWidth + 1), -(AViewInfo.BorderWidth + 1));
    AProgressBarRect := FBounds;
  end
  else
  begin
    if IsInplace then
      ABarRect := ABounds
    else
      ABarRect := FViewInfo.BorderRect;
    FBounds := FViewInfo.BorderRect;
    FRealNativeStyle := False;
    InflateRect(FBounds, -AViewInfo.BorderWidth, -AViewInfo.BorderWidth);
    AProgressBarRect := FBounds;
  end;
  FViewInfo.NativeStyle := FRealNativeStyle;
  CalculateCustomProgressBarViewInfo(ACanvas, Self, FViewInfo);

  if not Properties.Marquee then
  begin
    if FViewInfo.FOrientation = cxorHorizontal then
      AProgressBarRect.Right := FBounds.Left +
        CalculateDelta(FViewInfo.Position - FViewInfo.Min, RectWidth(FBounds),
          FViewInfo.MaxMinDiff)
    else
      AProgressBarRect.Top := FBounds.Bottom -
        CalculateDelta((FViewInfo.Position - FViewInfo.Min), RectHeight(FBounds),
          FViewInfo.MaxMinDiff);
  end;

  FViewInfo.FRealShowOverload := False;
  if not Properties.Marquee and Properties.ShowOverload and
    not FRealNativeStyle and
    (FViewInfo.Position >= FViewInfo.OverloadValue) then
  begin
    FViewInfo.FRealShowOverload := True;
    AOverloadBarRect := AProgressBarRect;
    if FViewInfo.FOrientation = cxorHorizontal then
    begin
      AOverloadBarRect.Left := FBounds.Left +
        CalculateDelta(FViewInfo.RelativeOverloadValue, RectWidth(FBounds),
          FViewInfo.MaxMinDiff);
      AOverloadBarRect.Right := Math.Min(AOverloadBarRect.Right, FBounds.Right);
      AProgressBarRect.Right := AOverloadBarRect.Left;
    end else
    begin
      AOverloadBarRect.Top := AOverloadBarRect.Bottom -
        CalculateDelta(FViewInfo.RelativePosition, RectHeight(FBounds),
          FViewInfo.MaxMinDiff);
      AOverloadBarRect.Bottom := AOverloadBarRect.Bottom -
        CalculateDelta(FViewInfo.RelativeOverloadValue, RectHeight(FBounds),
          FViewInfo.MaxMinDiff);
      AOverloadBarRect.Bottom := Math.Max(AOverloadBarRect.Bottom, FBounds.Top);
      AProgressBarRect.Top := AOverloadBarRect.Bottom;
    end;
  end;

  FViewInfo.FRealShowPeak := FViewInfo.ShowPeak and not Properties.Marquee;
  if FViewInfo.FRealShowPeak then
  begin
    APeakBarRect := AProgressBarRect;
    if FViewInfo.FOrientation = cxorHorizontal then
    begin
      APeakBarRect.Left := FBounds.Left +
        CalculateDelta(FViewInfo.RelativePeakValue, RectWidth(FBounds),
        FViewInfo.MaxMinDiff);
      APeakBarRect.Left := Math.Min(APeakBarRect.Left, FBounds.Right - FViewInfo.PeakSize);
      APeakBarRect.Right := APeakBarRect.Left + FViewInfo.PeakSize;
    end
    else
    begin
      APeakBarRect.Bottom := FBounds.Bottom -
        CalculateDelta(FViewInfo.RelativePeakValue, RectHeight(FBounds),
          FViewInfo.MaxMinDiff);
      APeakBarRect.Bottom := Math.Max(APeakBarRect.Bottom, FBounds.Top + FViewInfo.PeakSize);
      APeakBarRect.Top := APeakBarRect.Bottom - FViewInfo.PeakSize;
    end;
  end;
  if Properties.ChangedForegroundImage or
    (FViewInfo.ForegroundImage.Width <= 0) or
    (FViewInfo.ForegroundImage.Height <= 0) then
  begin
    FViewInfo.ForegroundImage.Assign(Properties.ForegroundImage);
    Properties.ChangedForegroundImage := False;
    if Properties.TransparentImage then
    begin
      FBmp := TBitmap.Create;
      try
        FViewInfo.ForegroundImage.Transparent := True;
        FBmp.Width := FViewInfo.ForegroundImage.Width;
        FBmp.Height := FViewInfo.ForegroundImage.Height;
        FBmp.Canvas.Brush.Color := FViewInfo.BackgroundColor;
        FBmp.Canvas.FillRect(FBmp.Canvas.ClipRect);
        FBmp.Canvas.Draw(0, 0, FViewInfo.ForegroundImage);
        FViewInfo.ForegroundImage.Assign(FBmp);
      finally
        FBmp.Free;
      end;
    end;
  end;

  with FViewInfo do
    if Properties.Orientation = cxorHorizontal then
    begin
      AnimationBarRect.Left := AProgressBarRect.Left;
      AnimationBarRect.Top := AProgressBarRect.Top;
      AnimationBarRect.Right := AProgressBarRect.Left + GetAnimationBarDimension;
      AnimationBarRect.Bottom := AProgressBarRect.Bottom;
      OffsetRect(AnimationBarRect, -GetAnimationBarDimension div 2, 0);
    end
    else
    begin
      AnimationBarRect.Left := AProgressBarRect.Left;
      AnimationBarRect.Top := Bounds.Top;
      AnimationBarRect.Right := AProgressBarRect.Right;
      AnimationBarRect.Bottom := AnimationBarRect.Top + GetAnimationBarDimension;
      OffsetRect(AnimationBarRect, 0, -GetAnimationBarDimension div 2);
    end;
  if not IsInplace then FViewInfo.DrawSelectionBar := False;

  if Properties.ChangedPosition and not AIsMouseEvent and
    cxRectCompare(AProgressBarRect, FViewInfo.ProgressBarRect) and
    cxRectCompare(ABarRect, FViewInfo.BarRect) and
    (not FViewInfo.FRealShowOverload or cxRectCompare(AOverloadBarRect, FViewInfo.OverloadBarRect)) and
    (not FViewInfo.FRealShowPeak or cxRectCompare(APeakBarRect, FViewInfo.PeakBarRect)) then
  begin
    FViewInfo.ChangedBounds := False;
  end
  else
  begin
    FViewInfo.ProgressBarRect := AProgressBarRect;
    if not cxRectCompare(FViewInfo.BarRect, ABarRect) then
    begin
      FViewInfo.BarRect := ABarRect;
      FViewInfo.ChangedBoundsBarRect := True;
    end;
    FViewInfo.OverloadBarRect := AOverloadBarRect;
    FViewInfo.PeakBarRect := APeakBarRect;
    FViewInfo.ChangedBounds := True;
  end;
  Properties.ChangedPosition := False;
end;

procedure TcxCustomProgressBarViewData.CalculateButtonsViewInfo(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
  Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
  AIsMouseEvent: Boolean);
begin
end;

procedure TcxCustomProgressBarViewData.EditValueToDrawValue(ACanvas: TcxCanvas;
  const AEditValue: TcxEditValue; AViewInfo: TcxCustomEditViewInfo);
var
  ADisplayValue: TcxEditValue;
begin
  CalculateCustomProgressBarViewInfo(ACanvas, Self,
    TcxCustomProgressBarViewInfo(AViewInfo));
  if PreviewMode then
    Properties.PrepareDisplayValue(30, ADisplayValue, InternalFocused)
  else
    Properties.PrepareDisplayValue(AEditValue, ADisplayValue, InternalFocused);
  TcxCustomProgressBarViewInfo(AViewInfo).Position := ADisplayValue;
  Properties.CorrectPositionWithMaxMin(TcxCustomProgressBarViewInfo(AViewInfo));
end;

function TcxCustomProgressBarViewData.InternalGetEditConstantPartSize(ACanvas: TcxCanvas;
  AIsInplace: Boolean; AEditSizeProperties: TcxEditSizeProperties;
  var MinContentSize: TSize; AViewInfo: TcxCustomEditViewInfo): TSize;
var
  APrevLogFont: TLogFont;
  ASize1, ASize2: TSize;
  AText: string;
begin
  SaveCanvasFont(ACanvas, APrevLogFont);
  try
    Result := inherited InternalGetEditConstantPartSize(ACanvas, AIsInplace,
      AEditSizeProperties, MinContentSize, AViewInfo);

    with TcxCustomProgressBarViewInfo(AViewInfo) do
    begin
      ASize1.cx := RectWidth(ProgressBarRect);

      if not(IsInplace or
        AreVisualStylesMustBeUsed(AViewInfo.NativeStyle, totButton)) then
          ASize1.cx := ASize1.cx + 4;

      AText := '';
      ASize2 := GetTextEditContentSize(ACanvas, Self, AText,
        DrawTextFlagsTocxTextOutFlags(cxTextOutFlagsToDrawTextFlags(GetDrawTextFlags) and
          not(CXTO_CENTER_VERTICALLY or CXTO_BOTTOM) or CXTO_TOP), AEditSizeProperties, 0, False);
      ASize2.cx := ASize2.cx + 3;
      ASize1.cx := ASize1.cx + ASize2.cx;
      ASize1.cy := ASize2.cy;
    end;
    Result.cx := Result.cx + ASize1.cx;
    Result.cy := Result.cy + ASize1.cy;
  finally
    RestoreCanvasFont(ACanvas, APrevLogFont);
  end;
end;

function TcxCustomProgressBarViewData.GetDrawTextFlags: Integer;
begin
  Result := 0;
end;

function TcxCustomProgressBarViewData.GetIsEditClass: Boolean;
begin
  Result := False;
end;

function TcxCustomProgressBarViewData.GetProperties: TcxCustomProgressBarProperties;
begin
  Result := TcxCustomProgressBarProperties(FProperties);
end;

{ TProgressBarPropertiesValues }

function TcxProgressBarPropertiesValues.GetMax: Boolean;
begin
  Result := MaxValue;
end;

function TcxProgressBarPropertiesValues.GetMin: Boolean;
begin
  Result := MinValue;
end;

function TcxProgressBarPropertiesValues.IsMaxStored: Boolean;
begin
  Result := Max and (TcxCustomProgressBarProperties(Properties).Max = 0);
end;

function TcxProgressBarPropertiesValues.IsMinStored: Boolean;
begin
  Result := Min and (TcxCustomProgressBarProperties(Properties).Min = 0);
end;

procedure TcxProgressBarPropertiesValues.SetMax(Value: Boolean);
begin
  MaxValue := Value;
end;

procedure TcxProgressBarPropertiesValues.SetMin(Value: Boolean);
begin
  MinValue := Value;
end;

{ TcxCustomProgressBarProperties }

constructor TcxCustomProgressBarProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
//  FCurrentPosition := 0;
  FAnimationPath := cxapCycle;
  FAnimationRestartDelay := cxProgressBarDefaultAnimationRestartDelay; 
  FChangedForegroundImage := False;
  FChangedPosition := False;
  FBeginColor := clNavy;
  FEndColor := clWhite;
  FBarBevelOuter := cxbvNone;
  FPeakValue := 0;
  FOverloadValue := 80;
  FPeakSize := 2;
  FOrientation := cxorHorizontal;
  FShowText := True;
  FShowTextStyle := cxDefaultShowTextStyle;
  FTextOrientation := cxorHorizontal;
  FSolidTextColor := False;
  FBarStyle := cxbsSolid;
  FTransparentImage := True;
  FMarquee := False;
  FOverloadValue := 80;
  FBorderWidth := 0;
  FShowOverload := False;
  FOverloadBeginColor := $008080FF;
  FOverloadEndColor := clFuchsia;
  FShowPeak := False;
  FPeakColor := clRed;
  FAnimationSpeed := cxProgressBarDefaultAnimationSpeed;
  FText := '';
end;

destructor TcxCustomProgressBarProperties.Destroy;
begin
  if FForegroundImage <> nil then
    FreeAndNil(FForegroundImage);
  inherited Destroy;
end;

procedure TcxCustomProgressBarProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomProgressBarProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomProgressBarProperties do
      begin
        Self.AnimationPath := AnimationPath;
        Self.AnimationRestartDelay := AnimationRestartDelay;
        Self.BeginColor := BeginColor;
        Self.BarBevelOuter := BarBevelOuter;
        Self.EndColor := EndColor;
        Self.ForegroundImage := ForegroundImage;
        Self.Marquee := Marquee;
        Self.Min := Min;
        Self.Max := Max;
        Self.Orientation := Orientation;
        Self.ShowText := ShowText;
        Self.ShowTextStyle := ShowTextStyle;
        Self.TextOrientation := TextOrientation;
        Self.SolidTextColor := SolidTextColor;
        Self.BarStyle := BarStyle;
        Self.TransparentImage := TransparentImage;
        Self.BorderWidth := BorderWidth;
        Self.OverloadValue := OverloadValue;
        Self.ShowOverload := ShowOverload;
        Self.OverloadBeginColor := OverloadBeginColor;
        Self.OverloadEndColor := OverloadEndColor;
        Self.PeakValue := PeakValue;
        Self.ShowPeak := ShowPeak;
        Self.PeakColor := PeakColor;
        Self.PeakSize := PeakSize;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomProgressBarProperties.CanCompareEditValue: Boolean;
begin
  Result := True;
end;

class function TcxCustomProgressBarProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxProgressBar;
end;

function TcxCustomProgressBarProperties.GetDisplayText(const AEditValue: TcxEditValue;
  AFullText: Boolean = False; AIsInplace: Boolean = True): WideString;
var
  ADisplayValue: TcxEditValue;
begin
  PrepareDisplayValue(AEditValue, ADisplayValue, False);
  if FShowTextStyle = cxtsPercent then
    ADisplayValue := VarToStr(ADisplayValue) + ' %';
  Result := VarToStr(ADisplayValue);
end;

function TcxCustomProgressBarProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := [esoAlwaysHotTrack, esoFiltering, esoSorting];
end;

class function TcxCustomProgressBarProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomProgressBarViewInfo;
end;

function TcxCustomProgressBarProperties.IsEditValueValid(var EditValue: TcxEditValue;
  AEditFocused: Boolean): Boolean;
begin
  Result := inherited IsEditValueValid(EditValue, AEditFocused);
end;

procedure TcxCustomProgressBarProperties.PrepareDisplayValue(const AEditValue:
  TcxEditValue; var DisplayValue: TcxEditValue; AEditFocused: Boolean);
var
  AValue: Double;
  ACode: Integer;
begin
  DisplayValue := 0;
  if VarIsStr(AEditValue) then
  begin
    Val(VarToStr(AEditValue), AValue, ACode);
    if ACode = 0 then
      DisplayValue := AValue;
  end
  else
    if VarIsNumericEx(AEditValue) or VarIsDate(AEditValue) then
      DisplayValue := AEditValue;
//  PrepareCurrentPosition(DisplayValue);
end;

procedure TcxCustomProgressBarProperties.CorrectPositionWithMaxMin(
  AViewInfo: TcxCustomProgressBarViewInfo);
begin
  if Min < Max then
    AViewInfo.Position := Math.Min(Math.Max(AViewInfo.Position, Min), Max);
end;

class function TcxCustomProgressBarProperties.GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass;
begin
  Result := TcxProgressBarPropertiesValues;
end;

function TcxCustomProgressBarProperties.GetMaxValue: Double;
begin
  if AssignedValues.Max then
    Result := inherited GetMaxValue
  else
    Result := 100;
end;

function TcxCustomProgressBarProperties.GetMinValue: Double;
begin
  if AssignedValues.Min then
    Result := inherited GetMinValue
  else
    Result := 0;
end;

class function TcxCustomProgressBarProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomProgressBarViewData;
end;

function TcxCustomProgressBarProperties.HasDisplayValue: Boolean;
begin
  Result := True;
end;

function TcxCustomProgressBarProperties.GetAssignedValues: TcxProgressBarPropertiesValues;
begin
  Result := TcxProgressBarPropertiesValues(FAssignedValues);
end;

function TcxCustomProgressBarProperties.GetForegroundImage: TBitmap;
begin
  if FForegroundImage = nil then
  begin
    FForegroundImage := TBitmap.Create;
    FForegroundImage.OnChange := ForegroundImageChanged;
  end;
  Result := FForegroundImage;
end;

procedure TcxCustomProgressBarProperties.ForegroundImageChanged(Sender: TObject);
begin
  Changed;
end;

function TcxCustomProgressBarProperties.GetMax: Double;
begin
  Result := MaxValue;
end;

function TcxCustomProgressBarProperties.GetMin: Double;
begin
  Result := MinValue;
end;

function TcxCustomProgressBarProperties.GetOverloadValueStored: Boolean;
begin
  Result := FOverloadValue <> 80;
end;

function TcxCustomProgressBarProperties.GetPeakValueStored: Boolean;
begin
  Result := FPeakValue <> 0;
end;

procedure TcxCustomProgressBarProperties.SetAnimationPath(AValue: TcxProgressBarAnimationPath);
begin
  if AValue <> FAnimationPath then
  begin
    FAnimationPath := AValue;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetAnimationRestartDelay(AValue: Cardinal);
begin
  if AValue <> FAnimationRestartDelay then
  begin
    FAnimationRestartDelay := AValue;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetAnimationSpeed(AValue: TcxProgressBarAnimationSpeed);
begin
  if AValue < Low(AValue) then
    AValue := Low(AValue);
  if AValue > High(AValue) then
    AValue := High(AValue);
  if AValue <> FAnimationSpeed then
  begin
    FAnimationSpeed := AValue;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetAssignedValues(
  Value: TcxProgressBarPropertiesValues);
begin
  FAssignedValues.Assign(Value);
end;

procedure TcxCustomProgressBarProperties.SetBeginColor(Value: TColor);
begin
  if FBeginColor <> Value then
  begin
    FBeginColor := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetBarBevelOuter(Value: TcxProgressBarBevelOuter);
begin
  if FBarBevelOuter <> Value then
  begin
    FBarBevelOuter := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetColorVista;
begin
  FBeginColor := $D328;
end;

procedure TcxCustomProgressBarProperties.SetEndColor(Value: TColor);
begin
  if Value <> FEndColor then
  begin
    FEndColor := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetForegroundImage(Value: TBitmap);
begin
  if Value = nil then
    FreeAndNil(FForegroundImage)
  else
    ForegroundImage.Assign(Value);
  ChangedForegroundImage := True;
  Changed;
end;

procedure TcxCustomProgressBarProperties.SetMarquee(Value: Boolean);
begin
  if Value <> FMarquee then
  begin
    FMarquee := Value;
    if FMarquee then
      ShowTextStyle := cxtsText;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetMax(Value: Double);
begin
  MaxValue := Value;
  PostMaxValue;
end;

procedure TcxCustomProgressBarProperties.SetMin(Value: Double);
begin
  MinValue := Value;
  PostMinValue;
end;

procedure TcxCustomProgressBarProperties.SetOverloadValue(Value: Double);
begin
  if FOverloadValue <> Value then
  begin
    FOverloadValue := Value;
    PostOverloadValue;
    Changed;
  end;
end;

function TcxCustomProgressBarProperties.GetRealPeakValue(APosition: Double): Double;
begin
  Result := Math.Max(Math.Min(Math.Max(FPeakValue, Min), Max), APosition);
  FPeakValue := Math.Max(FPeakValue, Result);
end;

function TcxCustomProgressBarProperties.IsMaxStored: Boolean;
begin
  Result := IsMaxValueStored;
end;

function TcxCustomProgressBarProperties.IsMinStored: Boolean;
begin
  Result := IsMinValueStored;
end;

function TcxCustomProgressBarProperties.IsShowTextStyleStored: Boolean;
begin
  Result := not Marquee and (FShowTextStyle <> cxDefaultShowTextStyle);
end;

procedure TcxCustomProgressBarProperties.SetPeakValue(Value: Double);
begin
  if FPeakValue <> Value then
  begin
    FPeakValue := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.PostMinValue;
begin
  if Min > Max then Max := Min;
//  if FCurrentPosition < FMin then FCurrentPosition := FMin;
  if FOverloadValue < Min then FOverloadValue := Min;
  if FPeakValue < Min then FPeakValue := Min;
end;

procedure TcxCustomProgressBarProperties.PostMaxValue;
begin
  if Min > Max then Min := Max;
//  if FCurrentPosition > FMax then FCurrentPosition := FMax;
  if FOverloadValue > Max then FOverloadValue := Max;
  if FPeakValue > Max then FPeakValue := Max;
end;

procedure TcxCustomProgressBarProperties.PostOverloadValue;
begin
  if FOverloadValue < Min then
    FOverloadValue := Min;
  if FOverloadValue > Max then
    FOverloadValue := Max;
end;

procedure TcxCustomProgressBarProperties.SetOrientation(Value: TcxProgressBarOrientation);
begin
  if FOrientation <> Value then
  begin
    FOrientation := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetShowText(Value: Boolean);
begin
  if FShowText <> Value then
  begin
    FShowText := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetShowTextStyle(Value: TcxProgressBarTextStyle);
begin
  if (FShowTextStyle <> Value) and (not Marquee or (Marquee and (Value = cxtsText))) then
  begin
    FShowTextStyle := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetTextOrientation(Value: TcxProgressBarOrientation);
begin
  if FTextOrientation <> Value then
  begin
    FTextOrientation := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetSolidTextColor(Value: Boolean);
begin
  if FSolidTextColor <> Value then
  begin
    FSolidTextColor := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetBarStyle(Value: TcxProgressBarBarStyle);
begin
  if FBarStyle <> Value then
  begin
    FBarStyle := Value;
    if FBarStyle in [cxbsAnimation, cxbsAnimationLEDs] then
      SetColorVista;       
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetText(const AValue: string);
begin
  if FText <> AValue then
  begin
    FText := AValue;
    if Length(FText) > 0 then
      ShowTextStyle := cxtsText;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetTransparentImage(Value: Boolean);
begin
  if FTransparentImage <> Value then
  begin
    FTransparentImage := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetBorderWidth(Value: TcxBorderWidth);
begin
  if FBorderWidth <> Value then
  begin
    FBorderWidth := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetShowOverload(Value: Boolean);
begin
  if FShowOverload <> Value then
  begin
    FShowOverload := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetOverloadBeginColor(Value: TColor);
begin
  if FOverloadBeginColor <> Value then
  begin
    FOverloadBeginColor := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetOverloadEndColor(Value: TColor);
begin
  if FOverloadEndColor <> Value then
  begin
    FOverloadEndColor := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetShowPeak(Value: Boolean);
begin
  if FShowPeak <> Value then
  begin
    FShowPeak := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetPeakColor(Value: TColor);
begin
  if FPeakColor <> Value then
  begin
    FPeakColor := Value;
    Changed;
  end;
end;

procedure TcxCustomProgressBarProperties.SetPeakSize(Value: TcxNaturalNumber);
begin
  if FPeakSize <> Value then
  begin
    FPeakSize := Value;
    Changed;
  end;
end;

{ TcxCustomProgressBar }

class function TcxCustomProgressBar.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomProgressBarProperties;
end;

procedure TcxCustomProgressBar.CheckEditorValueBounds;
var
  AValue: Variant;
begin
  KeyboardAction := True;
  try
    with ActiveProperties do
      if Min < Max then
      begin
        PrepareDisplayValue(FEditValue, AValue, Focused);
        if AValue < Min then
          InternalSetEditValue(Min, False)
        else
          if AValue > Max then
            InternalSetEditValue(Max, False);
      end;     
  finally
    KeyboardAction := False;
  end;
end;

procedure TcxCustomProgressBar.CheckEditValue;
begin
  if not(IsInplace or IsDBEdit or PropertiesChangeLocked) then
    CheckEditorValueBounds;
end;

function TcxCustomProgressBar.DefaultParentColor: Boolean;
begin
  Result := True;
end;

procedure TcxCustomProgressBar.FillSizeProperties(var AEditSizeProperties: TcxEditSizeProperties);
begin
  AEditSizeProperties := DefaultcxEditSizeProperties;
  AEditSizeProperties.MaxLineCount := 1;
  AEditSizeProperties.Width := ViewInfo.TextRect.Right - ViewInfo.TextRect.Left;
end;

procedure TcxCustomProgressBar.Initialize;
begin
  inherited Initialize;
  ControlStyle := ControlStyle - [csDoubleClicks, csCaptureMouse, csClickEvents];
  Width := 121;
  Height := 21;
end;

function TcxCustomProgressBar.InternalGetNotPublishedStyleValues: TcxEditStyleValues;
begin
  Result := inherited InternalGetNotPublishedStyleValues;
  Include(Result, svHotTrack);
end;

procedure TcxCustomProgressBar.SynchronizeDisplayValue;
var
  ADisplayValue: TcxEditValue;
begin
  ActiveProperties.PrepareDisplayValue(FEditValue, ADisplayValue, Focused);
  TcxCustomProgressBarViewInfo(ViewInfo).Position := ADisplayValue;
  if ActiveProperties.Transparent then
    Invalidate;
//  if not (IsInplace and (ActiveProperties.ShowTextStyle = cxtsPosition)) then
  ActiveProperties.CorrectPositionWithMaxMin(ViewInfo);
  ShortRefreshContainer(False);
  //Invalidate;
end;

procedure TcxCustomProgressBar.PropertiesChanged(Sender: TObject);
begin
  CheckEditValue;
//  if not (IsInplace and (ActiveProperties.ShowTextStyle = cxtsPosition)) then
  ActiveProperties.CorrectPositionWithMaxMin(ViewInfo);
  inherited PropertiesChanged(Sender);
  if ActiveProperties.Transparent then
    Invalidate;
end;

function TcxCustomProgressBar.CanFocus: Boolean;
begin
  Result := IsInplace;
end;

function TcxCustomProgressBar.CanFocusOnClick: Boolean;
begin
  Result := inherited CanFocusOnClick and IsInplace;
end;

function TcxCustomProgressBar.GetEditStateColorKind: TcxEditStateColorKind;
begin
  Result := cxEditStateColorKindMap[Enabled]; 
end;

function TcxCustomProgressBar.GetPercentDone: Integer;
begin
  Result := ViewInfo.GetPercentDone;
end;

function TcxCustomProgressBar.GetPosition: Double;
begin
  Result := ViewInfo.Position;
end;

function TcxCustomProgressBar.GetPositionStored: Boolean;
begin
  Result := ViewInfo.Position <> 0;
end;

function TcxCustomProgressBar.GetProperties: TcxCustomProgressBarProperties;
begin
  Result := TcxCustomProgressBarProperties(FProperties);
end;

function TcxCustomProgressBar.GetActiveProperties: TcxCustomProgressBarProperties;
begin
  Result := TcxCustomProgressBarProperties(InternalGetActiveProperties);
end;

function TcxCustomProgressBar.GetViewInfo: TcxCustomProgressBarViewInfo;
begin
  Result := TcxCustomProgressBarViewInfo(FViewInfo);
end;

procedure TcxCustomProgressBar.SetProperties(
  Value: TcxCustomProgressBarProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomProgressBar.SetPosition(Value: Double);
begin
  if Value = ViewInfo.Position then
    Exit;
  ActiveProperties.ChangedPosition := True;
  with ActiveProperties do
    if (not IsLoading) and (Min < Max) then
      Value := Math.Min(Math.Max(Value, Min), Max);
  EditValue := Value;
end;

{ TcxProgressBar }

class function TcxProgressBar.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxProgressBarProperties;
end;

function TcxProgressBar.GetActiveProperties: TcxProgressBarProperties;
begin
  Result := TcxProgressBarProperties(InternalGetActiveProperties);
end;

function TcxProgressBar.GetProperties: TcxProgressBarProperties;
begin
  Result := TcxProgressBarProperties(FProperties);
end;

procedure TcxProgressBar.SetProperties(Value: TcxProgressBarProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterProgressBarHelper }

class procedure TcxFilterProgressBarHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
begin
  inherited InitializeProperties(AProperties, AEditProperties, AHasButtons);
  with TcxCustomSpinEditProperties(AProperties) do
  begin
    Buttons.Add;
    Buttons.Add;
    MinValue := TcxCustomProgressBarProperties(AEditProperties).Min;
    MaxValue := TcxCustomProgressBarProperties(AEditProperties).Max;
  end;
end;

initialization
  GetRegisteredEditProperties.Register(TcxProgressBarProperties, scxSEditRepositoryProgressBarItem);
  FilterEditsController.Register(TcxProgressBarProperties, TcxFilterProgressBarHelper);

finalization
  FilterEditsController.Unregister(TcxProgressBarProperties, TcxFilterProgressBarHelper);
  GetRegisteredEditProperties.Unregister(TcxProgressBarProperties);

end.

