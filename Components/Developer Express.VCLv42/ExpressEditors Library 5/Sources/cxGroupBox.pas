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

unit cxGroupBox;

{$I cxVer.inc}

interface

uses
  Windows, Messages,
  SysUtils, Classes, Controls, Graphics, Forms, cxControls, cxGraphics,
  cxLookAndFeels, cxContainer, cxEditPaintUtils, cxEdit,
  cxTextEdit, cxClasses, cxCheckBox, cxLookAndFeelPainters;

const
  cxGroupBox_SupportNonClientArea: Boolean = True;

type
  TcxCaptionAlignment = (alTopLeft, alTopCenter, alTopRight,
    alBottomLeft, alBottomCenter, alBottomRight,
    alLeftTop, alLeftCenter, alLeftBottom,
    alRightTop, alRightCenter, alRightBottom,
    alCenterCenter);

  TcxPanelOffice11BackgroundKind = (pobkGradient, pobkOffice11Color, pobkStyleColor);

  { TcxGroupBoxButtonViewInfo }

  TcxGroupBoxButtonViewInfo = class(TcxEditButtonViewInfo)
  public
    Caption: string;
    Column, Row: Integer;
    function GetGlyphRect(ACanvas: TcxCanvas; AGlyphSize: TSize; AAlignment: TLeftRight; AIsPaintCopy: Boolean): TRect; virtual;
  end;

  { TcxGroupBoxViewInfo }

  TcxCustomGroupBox = class;

  TcxGroupBoxViewInfo = class(TcxCustomTextEditViewInfo)
  private
    function GetCaptionRectIndent: TRect;
    function GetControlRect: TRect;
    function GetEdit: TcxCustomGroupBox;
    function CalcOffsetBoundsForPanel: TRect;
    procedure CalcBoundsForPanel;
    function GetFrameBounds: TRect;
    procedure CalcTextBoundsForPanel;
    function CalcCorrectionBoundsForPanel: TRect;
    procedure AdjustTextBoundsForPanel;
    procedure AdjustCaptionBoundsForPanel;
    procedure DrawHorizontalTextCaption(ACanvas: TcxCanvas);
    procedure DrawVerticalTextCaption(ACanvas: TcxCanvas);
    procedure DrawFrame(ACanvas: TcxCanvas; R: TRect);
    function GetBoundsForPanel: TRect;
    function GetThemeBackgroundRect(ACanvas: TcxCanvas): TRect;
    procedure DrawUsualBackground(ACanvas: TcxCanvas);
    procedure DrawNativeBackground(ACanvas: TcxCanvas; const ACaptionRect: TRect);
    procedure DrawNativeGroupBoxBackground(ACanvas: TcxCanvas);
    procedure DrawNativePanelBackground(ACanvas: TcxCanvas; const ACaptionRect: TRect);
    procedure DrawOffice11PanelBackground(ACanvas: TcxCanvas; const R: TRect);
    procedure InternalDrawBackground(ACanvas: TcxCanvas);
    procedure InternalDrawBackgroundByPainter(ACanvas: TcxCanvas);
  protected
    procedure AdjustCaptionRect(ACaptionPosition: TcxGroupBoxCaptionPosition); virtual;
    procedure DrawCaption(ACanvas: TcxCanvas); virtual;
    function GetButtonViewInfoClass: TcxEditButtonViewInfoClass; override;
    procedure InternalPaint(ACanvas: TcxCanvas); override;
    function IsPanelStyle: Boolean;

    property CaptionRectIndent: TRect read GetCaptionRectIndent;
    property ControlRect: TRect read GetControlRect;
  public
    Alignment: TLeftRight;
    CaptionRect: TRect;
    IsDesigning: Boolean;
    TextRect: TRect;
    constructor Create; override;
    destructor Destroy; override;
    property Edit: TcxCustomGroupBox read GetEdit;
  end;

  { TcxGroupBoxViewData }

  TcxGroupBoxViewData = class(TcxCustomEditViewData)
  private
    procedure AdjustHorizontalCaptionRect(var R: TRect);
    procedure AdjustVerticalCaptionRect(var R: TRect);
    function GetCaptionRect(ACanvas: TcxCanvas): TRect;
    function GetEdit: TcxCustomGroupBox;
    function GetShadowWidth: Integer;
    function HasNonClientArea: Boolean;
    procedure CalcRects(ACanvas: TcxCanvas; AEditViewInfo: TcxGroupBoxViewInfo);
  protected
    function GetContainerState(const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState;
      AIsMouseEvent: Boolean): TcxContainerState; override;
    function IsPanelStyle: Boolean;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    function GetBorderColor: TColor; override;
    function GetBorderExtent: TRect; override;
    function GetClientExtent(ACanvas: TcxCanvas;
      AViewInfo: TcxCustomEditViewInfo): TRect; override;
    function HasShadow: Boolean; override;
    class function IsNativeStyle(ALookAndFeel: TcxLookAndFeel): Boolean; override;
    property Edit: TcxCustomGroupBox read GetEdit;
  end;

  { TcxButtonGroupViewData }

  TcxCustomButtonGroupProperties = class;

  TcxEditMetrics = record
    AutoHeightColumnWidthCorrection, AutoHeightWidthCorrection,
    ColumnWidthCorrection, WidthCorrection: Integer;
    ClientLeftBoundCorrection, ClientWidthCorrection, ColumnOffset: Integer;
    ButtonSize: TSize;
  end;

  { TcxButtonGroupViewInfo }

  TcxButtonGroupViewInfo = class(TcxGroupBoxViewInfo)
  protected
    procedure DrawEditButton(ACanvas: TcxCanvas; AButtonVisibleIndex: Integer); override;
    procedure DrawButtonCaption(ACanvas: TcxCanvas;
      AButtonViewInfo: TcxGroupBoxButtonViewInfo; const AGlyphRect: TRect); virtual; abstract;
    procedure DrawButtonGlyph(ACanvas: TcxCanvas;
      AButtonViewInfo: TcxGroupBoxButtonViewInfo; const AGlyphRect: TRect); virtual; abstract;
    function GetGlyphSize: TSize; virtual;
    function IsButtonGlypthTransparent(AButtonViewInfo: TcxGroupBoxButtonViewInfo): Boolean; virtual; abstract;
  public
    CaptionExtent: TRect;
    GlyphSize: TSize;
  end;

  TcxButtonGroupViewData = class(TcxGroupBoxViewData)
  private
    function GetProperties: TcxCustomButtonGroupProperties;
  protected
    procedure CalculateButtonPositions(ACanvas: TcxCanvas;
      AViewInfo: TcxCustomEditViewInfo); virtual;
    procedure CalculateButtonViewInfos(AViewInfo: TcxCustomEditViewInfo); virtual;
    function GetDrawTextFlags: Integer; virtual;
    procedure GetEditMetrics(AAutoHeight: Boolean; ACanvas: TcxCanvas;
      out AMetrics: TcxEditMetrics); virtual; abstract;
    function GetCaptionRectExtent: TRect; virtual;
    procedure CalculateButtonNativeState(AViewInfo: TcxCustomEditViewInfo;
      AButtonViewInfo: TcxGroupBoxButtonViewInfo); virtual; abstract;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    procedure CalculateButtonsViewInfo(ACanvas: TcxCanvas; const ABounds: TRect;
      const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
      AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean); override;
    function GetEditConstantPartSize(ACanvas: TcxCanvas;
      const AEditSizeProperties: TcxEditSizeProperties;
      var MinContentSize: TSize; AViewInfo: TcxCustomEditViewInfo = nil): TSize; override;
    class function IsButtonNativeStyle(ALookAndFeel: TcxLookAndFeel): Boolean; virtual;
    property Properties: TcxCustomButtonGroupProperties read GetProperties;
  end;

  TcxButtonGroupViewDataClass = class of TcxButtonGroupViewData;

  { TcxCustomGroupBoxProperties }

  TcxCustomGroupBoxProperties = class(TcxCustomEditProperties)
  protected
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
  public
    class function GetContainerClass: TcxContainerClass; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
  end;

  { TcxButtonGroupItem }

  TcxButtonGroupItem = class(TCollectionItem)
  private
    FCaption: TCaption;
    FEnabled: Boolean;
    FTag: TcxTag;
    function GetIsCollectionDestroying: Boolean;
    function IsTagStored: Boolean;
    procedure SetCaption(const Value: TCaption);
    procedure SetEnabled(Value: Boolean);
  protected
    procedure DoChanged(ACollection: TCollection; ACollectionOperation: TcxCollectionOperation;
      AIndex: Integer = -1);
    property Caption: TCaption read FCaption write SetCaption;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property IsCollectionDestroying: Boolean read GetIsCollectionDestroying;
    property Tag: TcxTag read FTag write FTag stored IsTagStored;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function GetCaption: TCaption;
  end;

  { TcxButtonGroupItems }

  TcxButtonGroupItems = class(TcxOwnedInterfacedCollection, IcxCheckItems)
  private
    FChangedItemIndex: Integer;
    FChangedItemOperation: TcxCollectionOperation;
    FItemChanged: Boolean;
    function GetItem(Index: Integer): TcxButtonGroupItem;
    procedure SetItem(Index: Integer; Value: TcxButtonGroupItem);

    { IcxCheckItems }
    function IcxCheckItems.GetCaption = CheckItemsGetCaption;
    function IcxCheckItems.GetCount = CheckItemsGetCount;
    function CheckItemsGetCaption(Index: Integer): string;
    function CheckItemsGetCount: Integer;
  protected
    procedure Update(Item: TCollectionItem); override;
    property ChangedItemIndex: Integer read FChangedItemIndex;
    property ChangedItemOperation: TcxCollectionOperation
      read FChangedItemOperation;
    property ItemChanged: Boolean read FItemChanged;
  public
    procedure InternalNotify(AItem: TcxButtonGroupItem; AItemIndex: Integer;
      AItemOperation: TcxCollectionOperation);
    property Items[Index: Integer]: TcxButtonGroupItem
      read GetItem write SetItem; default;
  end;

  TcxButtonGroupItemsClass = class of TcxButtonGroupItems;

  { TcxCustomButtonGroupProperties }

  TcxCustomButtonGroupProperties = class(TcxCustomGroupBoxProperties)
  private
    FColumns: Integer;
    FItems: TcxButtonGroupItems;
    FWordWrap: Boolean;
    procedure SetColumns(Value: Integer);
    procedure SetItems(Value: TcxButtonGroupItems);
    procedure SetWordWrap(Value: Boolean);
  protected
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    function CreateItems: TcxButtonGroupItems; virtual;
    function GetButtonsPerColumn: Integer;
    function GetColumnCount: Integer; virtual;
  public
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function CreatePreviewProperties: TcxCustomEditProperties; override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetSpecialFeatures: TcxEditSpecialFeatures; override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    // !!!
    property Columns: Integer read FColumns write SetColumns default 1;
    property Items: TcxButtonGroupItems read FItems write SetItems;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  end;

  { TcxPanelStyle }

  TcxPanelStyle = class(TPersistent)
  private
    FActive: Boolean;
    FBorderWidth: TBorderWidth;
    FCaptionIndent: Integer;
    FEdit: TcxCustomGroupBox;
    FOfficeBackgroundKind: TcxPanelOffice11BackgroundKind;
    FWordWrap: Boolean;

    procedure SetActive(AValue: Boolean);
    procedure SetBorderWidth(AValue: TBorderWidth);
    procedure SetCaptionIndent(AValue: Integer);
    procedure SetOfficeBackgroundKind(AValue: TcxPanelOffice11BackgroundKind);
    procedure SetWordWrap(AValue: Boolean);
  protected
    procedure Update;
    property Edit: TcxCustomGroupBox read FEdit;
  public
    constructor Create(AOwner: TcxCustomGroupBox); virtual;
    procedure Assign(ASource: TPersistent); override;
  published
    property Active: Boolean read FActive write SetActive default False;
    property BorderWidth: TBorderWidth read FBorderWidth write SetBorderWidth default 0;
    property CaptionIndent: Integer read FCaptionIndent write SetCaptionIndent default 2;
    property OfficeBackgroundKind: TcxPanelOffice11BackgroundKind read FOfficeBackgroundKind
      write SetOfficeBackgroundKind default pobkOffice11Color;
    property WordWrap: Boolean read FWordWrap write SetWordWrap default False;
  end;

  { TcxCustomGroupBox }

  TcxGroupBoxCustomDrawEvent = procedure (Sender: TcxCustomGroupBox; var ADone: Boolean) of object;
  TcxGroupBoxMeasureCaptionHeightEvent = procedure (Sender: TcxCustomGroupBox; const APainter: TcxCustomLookAndFeelPainterClass; var ACaptionHeight: Integer) of object;
  TcxGroupBoxCustomDrawElementEvent = procedure (Sender: TcxCustomGroupBox; ACanvas: TCanvas; const ABounds: TRect; const APainter: TcxCustomLookAndFeelPainterClass; var ADone: Boolean) of object;

  TcxCustomGroupBox = class(TcxCustomEdit)
  private
    FAlignment: TcxCaptionAlignment;
    FCaptionBkColor: TColor; // deprecated
    FCaptionFont: TFont;
    FIsAccelCharHandling: Boolean;
    FPanelStyle: TcxPanelStyle;
    FRedrawOnResize: Boolean;
    FVisibleCaption: string;
    FOnCustomDraw: TcxGroupBoxCustomDrawEvent;
  {$IFDEF DELPHI7}
    FOnCustomDrawCaption: TcxGroupBoxCustomDrawElementEvent;
    FOnCustomDrawContentBackground: TcxGroupBoxCustomDrawElementEvent;
    FOnMeasureCaptionHeight: TcxGroupBoxMeasureCaptionHeightEvent;
  {$ENDIF}

    procedure CalculateVisibleCaption;
    function GetCaptionBkColor: TColor; // deprecated
    function GetColor: TColor; // deprecated
    function GetFont: TFont; // deprecated
    function GetViewInfo: TcxGroupBoxViewInfo;
    function IsSkinAvailable: Boolean;

    procedure UpdateCaption;
    procedure UpdateNonClientArea;
    function GetHorizontalCaptionIndent: Integer;
    function GetPanelStyleCaptionDrawingFlags: Cardinal;
    function GetVerticalCaptionIndent: Integer;
    function GetVisibleCaption: string;

    procedure SetAlignment(Value: TcxCaptionAlignment);
    procedure SetCaptionBkColor(Value: TColor); // deprecated
    procedure SetColor(Value: TColor); // deprecated
    procedure SetFont(Value: TFont); // deprecated
    procedure SetPanelStyle(AValue: TcxPanelStyle);
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure WMNCPaint(var Message: TWMNCPaint);
  {$IFNDEF DELPHI7}
    procedure WMPrintClient(var Message: TMessage); message WM_PRINTCLIENT;
  {$ENDIF}
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
    function CanAutoSize: Boolean; override;
    function CanFocusOnClick: Boolean; override;
    function CanHaveTransparentBorder: Boolean; override;

    procedure ContainerStyleChanged(Sender: TObject); override;
    function CreatePanelStyle: TcxPanelStyle; virtual;
    function DefaultParentColor: Boolean; override;
    procedure FontChanged; override;
    procedure Initialize; override;
    function InternalGetActiveStyle: TcxContainerStyle; override;
    function InternalGetNotPublishedStyleValues: TcxEditStyleValues; override;
    function IsContainerClass: Boolean; override;
    function IsNativeBackground: Boolean; override;
    function IsPanelStyle: Boolean;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); override;
    procedure Paint; override;
    procedure TextChanged; override;
    function HasShadow: Boolean; override;
    procedure AdjustCanvasFontSettings(ACanvas: TcxCanvas);
    function DoCustomDraw: Boolean;
  {$IFDEF DELPHI7}
    function DoCustomDrawCaption(ACanvas: TcxCanvas; const ABounds: TRect; const APainter: TcxCustomLookAndFeelPainterClass): Boolean; virtual;
    function DoCustomDrawContentBackground(ACanvas: TcxCanvas; const ABounds: TRect; const APainter: TcxCustomLookAndFeelPainterClass): Boolean; virtual;
    procedure DoMeasureCaptionHeight(const APainter: TcxCustomLookAndFeelPainterClass; var ACaptionHeight: Integer);
  {$ENDIF}
    function GetCaptionDrawingFlags: Cardinal;
    function GetShadowBounds: TRect; override;
    function GetShadowBoundsExtent: TRect; override;
    function HasNonClientArea: Boolean; virtual;
    function IsNonClientAreaSupported: Boolean; virtual;
    function IsVerticalText: Boolean;
    function NeedRedrawOnResize: Boolean; virtual;
    procedure CalculateCaptionFont;
    procedure Resize; override;
    procedure WndProc(var Message: TMessage); override;

    property CaptionBkColor: TColor read GetCaptionBkColor write SetCaptionBkColor stored False; // deprecated
    property Color: TColor read GetColor write SetColor stored False; // deprecated
    property Ctl3D;
    property Font: TFont read GetFont write SetFont stored False; // deprecated
    property PanelStyle: TcxPanelStyle read FPanelStyle write SetPanelStyle;
    property ParentBackground;
    property RedrawOnResize: Boolean read FRedrawOnResize write FRedrawOnResize default True;
    property TabStop default False;
    property ViewInfo: TcxGroupBoxViewInfo read GetViewInfo;
    property OnCustomDraw: TcxGroupBoxCustomDrawEvent read FOnCustomDraw write FOnCustomDraw;
  {$IFDEF DELPHI7}
    property OnCustomDrawCaption: TcxGroupBoxCustomDrawElementEvent read FOnCustomDrawCaption write FOnCustomDrawCaption;
    property OnCustomDrawContentBackground: TcxGroupBoxCustomDrawElementEvent read FOnCustomDrawContentBackground write FOnCustomDrawContentBackground;
    property OnMeasureCaptionHeight: TcxGroupBoxMeasureCaptionHeightEvent read FOnMeasureCaptionHeight write FOnMeasureCaptionHeight;
  {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;

    property Alignment: TcxCaptionAlignment read FAlignment write SetAlignment
      default alTopLeft;
    property Transparent;
  end;

  { TcxGroupBox }

  TcxGroupBox = class(TcxCustomGroupBox)
  published
    property Align;
    property Alignment;
    property Anchors;
    property BiDiMode;
    property Caption;
    property CaptionBkColor; // deprecated
    property Color; // deprecated
    property Constraints;
    property Ctl3D;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font; // deprecated
    property LookAndFeel; // deprecated
    property PanelStyle;
    property ParentBackground;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RedrawOnResize;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Transparent;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnCustomDraw;
  {$IFDEF DELPHI7}
    property OnCustomDrawCaption;
    property OnCustomDrawContentBackground;
  {$ENDIF}
    property OnDblClick;
    property OnDockDrop;
    property OnDockOver;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
  {$IFDEF DELPHI7}
    property OnMeasureCaptionHeight;
  {$ENDIF}
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

  { TcxCustomButtonGroup }

  TcxCustomButtonGroup = class(TcxCustomGroupBox)
  private
    FButtons: TList;
    procedure DoButtonDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure DoButtonDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DoButtonKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoButtonKeyPress(Sender: TObject; var Key: Char);
    procedure DoButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DoButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoButtonMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure DoButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DoButtonMouseWheel(Sender: TObject;
       Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint; var Handled: Boolean);
    function GetProperties: TcxCustomButtonGroupProperties;
    function GetActiveProperties: TcxCustomButtonGroupProperties;
    procedure SetProperties(Value: TcxCustomButtonGroupProperties);
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged);
      message WM_WINDOWPOSCHANGED;
  protected
    function CanAutoSize: Boolean; override;
    procedure ContainerStyleChanged(Sender: TObject); override;
    procedure CursorChanged; override;
    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure EnabledChanged; override;
    procedure Initialize; override;
    function IsButtonDC(ADC: THandle): Boolean; override;
    function IsContainerClass: Boolean; override;
    procedure PropertiesChanged(Sender: TObject); override;
    procedure ReadState(Reader: TReader); override;
    function RefreshContainer(const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
      AIsMouseEvent: Boolean): Boolean; override;
    procedure CreateHandle; override;
    procedure ArrangeButtons; virtual;
    function GetButtonDC(AButtonIndex: Integer): THandle; virtual; abstract;
    function GetButtonIndexAt(const P: TPoint): Integer;
    function GetButtonInstance: TWinControl; virtual; abstract;
    function GetFocusedButtonIndex: Integer;
    procedure InitButtonInstance(AButton: TWinControl); virtual;
    function IsNonClientAreaSupported: Boolean; override;
    procedure SetButtonCount(Value: Integer); virtual;
    procedure SynchronizeButtonsStyle; virtual;
    procedure UpdateButtons; virtual;
    property InternalButtons: TList read FButtons;
    property TabStop default True;
  public
    destructor Destroy; override;
    procedure ActivateByMouse(Shift: TShiftState; X, Y: Integer;
      var AEditData: TcxCustomEditData); override;
    function Focused: Boolean; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure GetTabOrderList(List: TList); override;
    function IsButtonNativeStyle: Boolean;
    property AutoSize default False;
    property ActiveProperties: TcxCustomButtonGroupProperties
      read GetActiveProperties;
    property Properties: TcxCustomButtonGroupProperties read GetProperties
      write SetProperties;
  end;

implementation

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  dxThemeConsts, cxEditUtils, Math, Types, dxOffice11, TypInfo, dxThemeManager,
  dxUxTheme, cxDrawTextUtils, cxGeometry, dxCore;

const
  cxCaptionRectLeftBound = 8;
  cxNativeState: array[Boolean] of Integer = (GBS_DISABLED, GBS_NORMAL);

  WM_DXUPDATENONCLIENTAREA: Cardinal = WM_DX + $10;

type
  TControlAccess = class(TControl);
  TWinControlAccess = class(TWinControl);

function cxGroupBoxAlignment2GroupBoxCaption(AAlignment: TcxCaptionAlignment): TcxGroupBoxCaptionPosition;
begin
  if AAlignment in [alTopLeft, alTopCenter, alTopRight] then
    Result := cxgpTop
  else
  if AAlignment in [alBottomLeft, alBottomCenter, alBottomRight] then
    Result := cxgpBottom
  else
  if AAlignment in [alLeftTop, alLeftCenter, alLeftBottom] then
    Result := cxgpLeft
  else
  if AAlignment in [alRightTop, alRightCenter, alRightBottom] then
    Result := cxgpRight
  else
    Result := cxgpCenter;
end;

{ TcxGroupBoxButtonViewInfo }

function TcxGroupBoxButtonViewInfo.GetGlyphRect(ACanvas: TcxCanvas; AGlyphSize: TSize; AAlignment: TLeftRight; AIsPaintCopy: Boolean): TRect;
begin
  Result.Top := Bounds.Top + (Bounds.Bottom - Bounds.Top - AGlyphSize.cy) div 2;
  Result.Bottom := Result.Top + AGlyphSize.cy;
  if AAlignment = taRightJustify then
  begin
    Result.Left := Bounds.Left;
    Result.Right := Result.Left + AGlyphSize.cx;
  end
  else
  begin
    Result.Right := Bounds.Right;
    Result.Left := Result.Right - AGlyphSize.cx;
  end;
end;

{ TcxGroupBoxViewInfo }

constructor TcxGroupBoxViewInfo.Create;
begin
  inherited Create;
end;

destructor TcxGroupBoxViewInfo.Destroy;
begin
  inherited Destroy;
end;

procedure TcxGroupBoxViewInfo.AdjustCaptionRect(ACaptionPosition: TcxGroupBoxCaptionPosition);
var
  ACaptionHeight: Integer;
begin
  if not Edit.IsVerticalText then
    ACaptionHeight := cxRectHeight(CaptionRect)
  else
    ACaptionHeight := cxRectWidth(CaptionRect);
{$IFDEF DELPHI7}
  Edit.DoMeasureCaptionHeight(Painter, ACaptionHeight);
{$ENDIF}
  case Edit.Alignment of
    alTopLeft, alTopCenter, alTopRight:
      CaptionRect.Bottom := CaptionRect.Top + ACaptionHeight;
    alBottomLeft, alBottomCenter, alBottomRight:
      CaptionRect.Top := CaptionRect.Bottom - ACaptionHeight;
    alLeftTop, alLeftCenter, alLeftBottom:
      CaptionRect.Right := CaptionRect.Left + ACaptionHeight;
    alRightTop, alRightCenter, alRightBottom:
      CaptionRect.Left := CaptionRect.Right - ACaptionHeight;
  end;
end;

procedure TcxGroupBoxViewInfo.DrawCaption(ACanvas: TcxCanvas);

  procedure AdjustRectForBordersNone(var R: TRect);
  var
    ACaptionPos: TcxGroupBoxCaptionPosition;
    ARect: TRect;
  begin
    if (BorderStyle = ebsNone) then
    begin
      ACaptionPos := cxGroupBoxAlignment2GroupBoxCaption(Edit.Alignment);
      case ACaptionPos of
        cxgpTop:
          ACaptionPos := cxgpBottom;
        cxgpBottom:
          ACaptionPos := cxgpTop;
        cxgpLeft:
          ACaptionPos := cxgpRight;
        cxgpRight:
          ACaptionPos := cxgpLeft;
      end;
      ARect := Painter.GroupBoxBorderSize(False, ACaptionPos);
      R := Rect(R.Left - ARect.Left, R.Top - ARect.Top, R.Right + ARect.Right, R.Bottom + ARect.Bottom);
    end;
  end;

var
  ACaptionPos: TcxGroupBoxCaptionPosition;
  ACaptionRect: TRect;
begin
  ACanvas.SaveClipRegion;
  try
    ACanvas.SetClipRegion(TcxRegion.Create(CaptionRect), roIntersect);
    if (Edit.FVisibleCaption = '') {$IFDEF DELPHI7}or Edit.DoCustomDrawCaption(ACanvas, CaptionRect, Painter){$ENDIF} then
      Exit;
    Edit.AdjustCanvasFontSettings(ACanvas);
    if Assigned(Painter) then
    begin
      ACaptionPos := cxGroupBoxAlignment2GroupBoxCaption(Edit.Alignment);
      if not IsPanelStyle then
      begin
        ACaptionRect := CaptionRect;
        AdjustRectForBordersNone(ACaptionRect);
        Painter.DrawGroupBoxCaption(ACanvas, ACaptionRect, ACaptionPos);
      end;
    end;
    ACanvas.Brush.Style := bsClear;
    if not Edit.IsVerticalText then
      DrawHorizontalTextCaption(ACanvas)
    else
      DrawVerticalTextCaption(ACanvas);
  finally
    ACanvas.RestoreClipRegion;
  end;
end;

function TcxGroupBoxViewInfo.GetButtonViewInfoClass: TcxEditButtonViewInfoClass;
begin
  Result := TcxGroupBoxButtonViewInfo;
end;

procedure TcxGroupBoxViewInfo.InternalPaint(ACanvas: TcxCanvas);
begin
  if IsInplace then
  begin
    if Edit = nil then
      inherited InternalPaint(ACanvas)
    else
      if IsCustomBackground then
        DrawBackground(ACanvas)
      else
        cxEditFillRect(ACanvas, Bounds, BackgroundColor);
    Exit;
  end;

  InternalDrawBackground(ACanvas);
  DrawCaption(ACanvas);

  if not IsPanelStyle then
    ACanvas.ExcludeClipRect(CaptionRect);

  DrawFrame(ACanvas, GetFrameBounds);

  if Edit.IsDBEditPaintCopyDrawing then
    DrawButtons(ACanvas);
end;

function TcxGroupBoxViewInfo.IsPanelStyle: Boolean;
begin
  Result := (Edit <> nil) and Edit.PanelStyle.Active;
end;

function TcxGroupBoxViewInfo.GetCaptionRectIndent: TRect;
var
  ACaptionPosition: TcxGroupBoxCaptionPosition;
  R1: TRect;
begin
  Result := cxNullRect;
  if Assigned(Edit) and Assigned(Edit.Style.LookAndFeel.SkinPainter) and not IsPanelStyle then
  begin
    ACaptionPosition := cxGroupBoxAlignment2GroupBoxCaption(Edit.Alignment);
    R1 := Edit.Style.LookAndFeel.SkinPainter.GroupBoxBorderSize(True, ACaptionPosition);
    case ACaptionPosition of
      cxgpTop:
        Result.Top := R1.Top + R1.Bottom;
      cxgpBottom:
        Result.Bottom := R1.Top + R1.Bottom;
      cxgpLeft:
        Result.Left := R1.Right + R1.Left;
      cxgpRight:
        Result.Right := R1.Right + R1.Left;
    end;
  end;
end;

function TcxGroupBoxViewInfo.GetControlRect: TRect;
begin
  Result := cxContainer.GetControlRect(Edit);
end;

function TcxGroupBoxViewInfo.GetEdit: TcxCustomGroupBox;
begin
  Result := TcxCustomGroupBox(FEdit);
end;

function TcxGroupBoxViewInfo.CalcOffsetBoundsForPanel: TRect;
var
  ABorderSize: TRect;
  ACaptionIndentRect: TRect;
  ABorderWidth: Integer;
begin
  ABorderWidth := GetContainerBorderWidth(TcxContainerBorderStyle(BorderStyle));
  ABorderSize := Rect(ABorderWidth, ABorderWidth, ABorderWidth, ABorderWidth);
  ACaptionIndentRect := cxEmptyRect;
  case Edit.Alignment of
    alTopLeft, alLeftTop, alLeftCenter, alLeftBottom, alBottomLeft:
      ACaptionIndentRect.Left := Edit.GetHorizontalCaptionIndent;
    alTopRight, alRightTop, alRightCenter, alRightBottom, alBottomRight:
      ACaptionIndentRect.Right := Edit.GetHorizontalCaptionIndent;
  end;
  case Edit.Alignment of
    alLeftTop, alTopLeft, alTopCenter, alTopRight, alRightTop:
      ACaptionIndentRect.Top := Edit.GetVerticalCaptionIndent;
    alLeftBottom, alBottomLeft, alBottomCenter, alBottomRight, alRightBottom:
      ACaptionIndentRect.Bottom := Edit.GetVerticalCaptionIndent;
  end;
  Result.Left := ABorderSize.Left + ACaptionIndentRect.Left;
  Result.Top := ABorderSize.Top + ACaptionIndentRect.Top;
  Result.Right := ABorderSize.Right + ACaptionIndentRect.Right;
  Result.Bottom := ABorderSize.Bottom + ACaptionIndentRect.Bottom;
end;

procedure TcxGroupBoxViewInfo.CalcBoundsForPanel;
begin
  if IsPanelStyle then
  begin
    CalcTextBoundsForPanel;
    AdjustTextBoundsForPanel;
    CaptionRect := TextRect;
    AdjustCaptionBoundsForPanel;
  end;
end;

function TcxGroupBoxViewInfo.GetFrameBounds: TRect;
begin
  if IsPanelStyle then
    Result := GetBoundsForPanel
  else
  begin
    Result := BorderRect;
    ExtendRectByBorders(Result,
      GetContainerBorderWidth(TcxContainerBorderStyle(BorderStyle)), Edges);
  end;
end;

procedure TcxGroupBoxViewInfo.CalcTextBoundsForPanel;
var
  AFlag: Cardinal;
  ACanvas: TcxCanvas;
begin
  AFlag := CXTO_CALCRECT;
  if Edit.PanelStyle.WordWrap then
    AFlag := AFlag or CXTO_WORDBREAK;
  TextRect := CalcCorrectionBoundsForPanel;
  ACanvas := TcxCanvas.Create(Edit.Canvas.Canvas);
  try
    Edit.AdjustCanvasFontSettings(ACanvas);
    cxTextOut(ACanvas.Handle, Edit.FVisibleCaption, TextRect, AFlag);
  finally
    FreeAndNil(ACanvas);
  end;
end;

function TcxGroupBoxViewInfo.CalcCorrectionBoundsForPanel: TRect;
var
  AOffsetRect: TRect;
begin
  AOffsetRect := CalcOffsetBoundsForPanel;
  Result := GetBoundsForPanel;
  with AOffsetRect do
  begin
    Inc(Result.Left, Left);
    Inc(Result.Top, Top);
    Dec(Result.Right, Right);
    Dec(Result.Bottom, Bottom);
  end;
end;

procedure TcxGroupBoxViewInfo.AdjustTextBoundsForPanel;
var
  ATextWidth, ATextHeight: Integer;
  R: TRect;
begin
  with TextRect do
  begin
    ATextWidth := Right - Left;
    ATextHeight := Bottom - Top;
  end;
  R := CalcCorrectionBoundsForPanel;
  OffsetRect(TextRect, R.Left - TextRect.Left, R.Top - TextRect.Top);
  case Edit.Alignment of
    alTopCenter, alBottomCenter, alCenterCenter:
      OffsetRect(TextRect, (R.Right - R.Left - ATextWidth - TextRect.Left) div 2, 0);
    alTopRight, alRightTop, alRightCenter, alRightBottom, alBottomRight:
      OffsetRect(TextRect, R.Right - ATextWidth - TextRect.Left, 0);
  end;
  case Edit.Alignment of
    alLeftCenter, alRightCenter, alCenterCenter:
      OffsetRect(TextRect, 0, (R.Bottom - R.Top - ATextHeight - TextRect.Top) div 2);
    alLeftBottom, alBottomLeft, alBottomCenter, alBottomRight, alRightBottom:
      OffsetRect(TextRect, 0, R.Bottom - ATextHeight - TextRect.Top);
  end;
end;

procedure TcxGroupBoxViewInfo.AdjustCaptionBoundsForPanel;

  procedure ChangeIfLess(var AInValue, AChangeValue: Integer);
  begin
    AInValue := Max(AChangeValue, AInValue);
  end;
  procedure ChangeIfGreat(var AInValue, AChangeValue: Integer);
  begin
    AInValue := Min(AChangeValue, AInValue);
  end;

var
  R: TRect;
begin
  R := CalcCorrectionBoundsForPanel;
  ChangeIfGreat(CaptionRect.Right, R.Right);
  ChangeIfGreat(CaptionRect.Bottom, R.Bottom);
  ChangeIfLess(CaptionRect.Left, R.Left);
  ChangeIfLess(CaptionRect.Top, R.Top);
end;

procedure TcxGroupBoxViewInfo.DrawHorizontalTextCaption(ACanvas: TcxCanvas);
begin
  cxDrawText(ACanvas.Handle, Edit.FVisibleCaption, TextRect, Edit.GetCaptionDrawingFlags);
end;

procedure TcxGroupBoxViewInfo.DrawVerticalTextCaption(ACanvas: TcxCanvas);
var
  AFlags, X, Y: Integer;
begin
  AFlags := ETO_CLIPPED;
  if Edit.FAlignment in [alLeftTop, alLeftCenter, alLeftBottom] then
  begin
    X := TextRect.Left;
    Y := TextRect.Bottom - 1;
  end
  else
  begin
    X := TextRect.Right;
    Y := TextRect.Top + 1;
  end;
  cxExtTextOut(ACanvas.Handle, Edit.FVisibleCaption, Point(X, Y), TextRect, AFlags);
end;

procedure TcxGroupBoxViewInfo.DrawFrame(ACanvas: TcxCanvas; R: TRect);
var
  ABackgroundRect: TRect;
  ANativeState: Integer;
  ATheme: TdxTheme;
begin
  if NativeStyle then
  begin
    if IsPanelStyle then
    begin
      if BorderStyle <> ebsNone then
        Edit.LookAndFeelPainter.DrawBorder(ACanvas, GetBoundsForPanel);
    end
    else
    begin
      if BorderStyle <> ebsNone then
      begin
        ATheme := OpenTheme(totButton);
        ANativeState := cxNativeState[Enabled];
        ABackgroundRect := GetThemeBackgroundRect(ACanvas);
        DrawThemeBackground(ATheme, ACanvas.Handle, BP_GROUPBOX, ANativeState,
          ABackgroundRect);
      end;
    end;
  end
  else
  begin
    if not Assigned(Painter) then
    begin
      case BorderStyle of
        ebsSingle: ACanvas.FrameRect(R, BorderColor, 1, Edit.ActiveStyle.Edges, True);
        ebsThick: ACanvas.FrameRect(R, BorderColor, 2, Edit.ActiveStyle.Edges, True);
        ebsFlat:
          begin
            ACanvas.FrameRect(R, clBtnShadow, 1, Edit.ActiveStyle.Edges, True);
            InflateRect(R, -1, -1);
            ACanvas.FrameRect(R, clBtnHighlight, 1, Edit.ActiveStyle.Edges, True);
        end;
        ebs3D:
          if Edit.Ctl3D then
          begin
            Dec(R.Right);
            Dec(R.Bottom);
            ACanvas.FrameRect(R, clBtnShadow, 1, Edit.ActiveStyle.Edges, True);
            OffsetRect(R, 1, 1);
            ACanvas.FrameRect(R, clBtnHighlight, 1, Edit.ActiveStyle.Edges, True);
          end
        else
        begin
          ACanvas.FrameRect(R, clWindowFrame, 1, Edit.ActiveStyle.Edges, True);
          InflateRect(R, -1, -1);
          ACanvas.FrameRect(R, BackgroundColor, 1, Edit.ActiveStyle.Edges, True);
        end;
      end;
    end;
  end;
end;

function TcxGroupBoxViewInfo.GetThemeBackgroundRect(
  ACanvas: TcxCanvas): TRect;
begin
  Result := ControlRect;
  if not IsPanelStyle then
    case Edit.FAlignment of
      alTopLeft, alTopCenter, alTopRight:
        Result.Top := ACanvas.TextHeight('Qq') div 2;
      alBottomLeft, alBottomCenter, alBottomRight:
        Dec(Result.Bottom, ACanvas.TextHeight('Qq') div 2);
      alLeftTop, alLeftCenter, alLeftBottom:
        Result.Left := ACanvas.TextHeight('Qq') div 2;
      alRightTop, alRightCenter, alRightBottom:
        Dec(Result.Right, ACanvas.TextHeight('Qq') div 2);
    end;
end;

function TcxGroupBoxViewInfo.GetBoundsForPanel: TRect;
begin
  Result := Bounds;
  if not NativeStyle and (Painter = nil) then
    if Edit.HasShadow then
    begin
      Dec(Result.Right, cxContainerShadowWidth);
      Dec(Result.Bottom, cxContainerShadowWidth);
    end;
end;

procedure TcxGroupBoxViewInfo.DrawUsualBackground(ACanvas: TcxCanvas);
begin
  if Edit.HasShadow then
    DrawContainerShadow(ACanvas, GetFrameBounds);
    
  if not Transparent then
  begin
    if Edit.IsTransparent then
      cxDrawTransparentControlBackground(Edit, ACanvas, ControlRect)
    else
      cxEditFillRect(ACanvas, ControlRect, BackgroundColor);
  end;
end;

procedure TcxGroupBoxViewInfo.DrawNativeBackground(ACanvas: TcxCanvas;
  const ACaptionRect: TRect);
begin
  if IsPanelStyle then
    DrawNativePanelBackground(ACanvas, ACaptionRect)
  else
    DrawNativeGroupBoxBackground(ACanvas);
end;

procedure TcxGroupBoxViewInfo.DrawNativeGroupBoxBackground(
  ACanvas: TcxCanvas);
var
  AClipRgn: TcxRegion;
  ANativeState: Integer;
  ATheme: TdxTheme;
begin
  AClipRgn := ACanvas.GetClipRegion;
  try
    ATheme := OpenTheme(totButton);
    ANativeState := cxNativeState[Enabled];
    if Edit.IsTransparent then
      cxDrawTransparentControlBackground(Edit, ACanvas, Bounds)
    else
      if Edit.IsNativeBackground and
          IsThemeBackgroundPartiallyTransparent(ATheme, BP_GROUPBOX, ANativeState) then
      begin
        cxDrawThemeParentBackground(Edit, ACanvas, Bounds);
        ACanvas.Canvas.Refresh; // SC-B31215
      end
      else
        cxEditFillRect(ACanvas.Handle, Bounds, GetSolidBrush(ACanvas, BackgroundColor));
  finally
    ACanvas.SetClipRegion(AClipRgn, roSet);
  end;
end;

procedure TcxGroupBoxViewInfo.DrawNativePanelBackground(
  ACanvas: TcxCanvas; const ACaptionRect: TRect);
var
  ABackgroundRect: TRect;
begin
  ABackgroundRect := GetBoundsForPanel;
  if BorderStyle <> ebsNone then
    InflateRect(ABackgroundRect, -Edit.LookAndFeelPainter.BorderSize, -Edit.LookAndFeelPainter.BorderSize);

  if Edit.IsTransparent then
  begin
    ACanvas.SaveClipRegion;
    try
      ACanvas.SetClipRegion(TcxRegion.Create(ABackgroundRect), roIntersect);
      Edit.LookAndFeelPainter.DrawPanelBackground(ACanvas, Edit, GetBoundsForPanel);
    finally
      ACanvas.RestoreClipRegion;
    end;
  end
  else
    if Edit.LookAndFeel.NativeStyle then
      if Edit.IsNativeBackground then
        cxDrawThemeParentBackground(Edit, ACanvas, ABackgroundRect)
      else
        Edit.LookAndFeelPainter.DrawPanelBackground(ACanvas, Edit, ABackgroundRect, BackgroundColor)
    else
      if Edit.LookAndFeel.Kind = lfOffice11 then
        DrawOffice11PanelBackground(ACanvas, ABackgroundRect);
end;

procedure TcxGroupBoxViewInfo.DrawOffice11PanelBackground(ACanvas: TcxCanvas; const R: TRect);
begin
  with Edit.LookAndFeelPainter do
    case Edit.PanelStyle.OfficeBackgroundKind of
      pobkGradient:
        DrawPanelBackground(ACanvas, Edit, R, dxOffice11ToolbarsColor1, dxOffice11ToolbarsColor2);
      pobkOffice11Color:
        DrawPanelBackground(ACanvas, Edit, R, GetMiddleRGB(dxOffice11ToolbarsColor1, dxOffice11ToolbarsColor2, 50));
      pobkStyleColor:
        DrawPanelBackground(ACanvas, Edit, R, BackgroundColor);
    end;
end;

procedure TcxGroupBoxViewInfo.InternalDrawBackground(ACanvas: TcxCanvas);
begin
  if NativeStyle or (IsPanelStyle and Assigned(Edit.LookAndFeelPainter) and
      (Edit.LookAndFeelPainter = TcxOffice11LookAndFeelPainter)) then
    DrawNativeBackground(ACanvas, CaptionRect)
  else
  begin
    ACanvas.SaveClipRegion;
    try
      if Painter = nil then
        DrawUsualBackground(ACanvas)
      else
        InternalDrawBackgroundByPainter(ACanvas);
    finally
      ACanvas.RestoreClipRegion;
    end;
  end;
end;

procedure TcxGroupBoxViewInfo.InternalDrawBackgroundByPainter(ACanvas: TcxCanvas);
var
  ABounds: TRect;
  ACaptionPos: TcxGroupBoxCaptionPosition;
begin
  if IsPanelStyle then
    ABounds := GetBoundsForPanel
  else
    if BorderStyle = ebsNone then
      ABounds := Bounds
    else
      ABounds := BorderRect;
{$IFDEF DELPHI7}
  if not Edit.DoCustomDrawContentBackground(ACanvas, ABounds, Painter) then
  begin
{$ENDIF}
    if IsPanelStyle then
      Painter.DrawPanelContent(ACanvas, ABounds, BorderStyle <> ebsNone)
    else
    begin
      if BorderStyle = ebsNone then
        Painter.DrawGroupBoxBackground(ACanvas, ABounds, ABounds)
      else
      begin
        cxDrawTransparentControlBackground(Edit, ACanvas, ControlRect);
        ACaptionPos := cxGroupBoxAlignment2GroupBoxCaption(Edit.Alignment);
        if Edit.FVisibleCaption = '' then
          ACaptionPos := cxgpCenter;
        Painter.DrawGroupBoxContent(ACanvas, ABounds, ACaptionPos, Edges);
      end;
    end;
{$IFDEF DELPHI7}
  end;
{$ENDIF}
end;

{ TcxGroupBoxViewData }

procedure TcxGroupBoxViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);
var
  AEditViewInfo: TcxGroupBoxViewInfo;
begin
  AEditViewInfo := TcxGroupBoxViewInfo(AViewInfo);
  AEditViewInfo.IsDesigning := IsDesigning;
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);

  if not IsInplace then
  begin
    Edit.CalculateCaptionFont;
    Edit.CalculateVisibleCaption;
    CalcRects(ACanvas, AEditViewInfo);
  end;
end;

function TcxGroupBoxViewData.GetBorderColor: TColor;
begin
  if Style.BorderStyle in [ebsUltraFlat, ebsOffice11] then
  begin
    if Enabled then
      Result := GetEditBorderHighlightColor(Style.BorderStyle = ebsOffice11)
    else
      Result := clBtnShadow;
  end
  else
    Result := Style.BorderColor;
end;

function TcxGroupBoxViewData.GetBorderExtent: TRect;
var
  AHeaderSideBorderOffset: Integer;
begin
  Result := inherited GetBorderExtent;
  if not IsInplace and (Edit.FAlignment <> alCenterCenter) and not IsPanelStyle then
  begin
    cxScreenCanvas.Font := Edit.FCaptionFont;
    AHeaderSideBorderOffset := cxScreenCanvas.TextHeight('Qq') div 2 - 1 +
      cxEditMaxBorderWidth;
    case Edit.FAlignment of
      alTopLeft, alTopCenter, alTopRight:
        Result.Top := AHeaderSideBorderOffset;
      alBottomLeft, alBottomCenter, alBottomRight:
        Result.Bottom := AHeaderSideBorderOffset;
      alLeftTop, alLeftCenter, alLeftBottom:
        Result.Left := AHeaderSideBorderOffset - 1;
      alRightTop, alRightCenter, alRightBottom:
        Result.Right := AHeaderSideBorderOffset - 1;
    end;
  end;
end;

function TcxGroupBoxViewData.GetClientExtent(
  ACanvas: TcxCanvas; AViewInfo: TcxCustomEditViewInfo): TRect;
var
  AContentOffsets: TRect;
  AHeaderSideClientExtent: Integer;
begin
  Result := inherited GetBorderExtent;
  if not (IsInplace or (AViewInfo.Painter = nil)) then
  begin
    if IsPanelStyle then
      AContentOffsets := AViewInfo.Painter.PanelBorderSize
    else
      AContentOffsets := AViewInfo.Painter.GroupBoxBorderSize(
        False, cxGroupBoxAlignment2GroupBoxCaption(Edit.Alignment));

    Inc(Result.Top, AContentOffsets.Top);
    Inc(Result.Left, AContentOffsets.Left);
    Inc(Result.Right, AContentOffsets.Right);
    Inc(Result.Bottom, AContentOffsets.Bottom);

    if HasNonClientArea then
    begin
      case cxGroupBoxAlignment2GroupBoxCaption(Edit.Alignment) of
        cxgpTop:
          Inc(Result.Bottom, TcxGroupBoxViewInfo(AViewInfo).CaptionRectIndent.Top);
        cxgpLeft:
          Inc(Result.Right, TcxGroupBoxViewInfo(AViewInfo).CaptionRectIndent.Left);
      end;
    end;
  end;

  if not (IsInplace or IsPanelStyle) and (Edit.FAlignment <> alCenterCenter) then
  begin
    cxScreenCanvas.Font := Edit.FCaptionFont;
    AHeaderSideClientExtent := cxScreenCanvas.TextHeight('Qq') +
      Result.Top + cxEditMaxBorderWidth + 1;
    case Edit.FAlignment of
      alTopLeft, alTopCenter, alTopRight:
        Result.Top := AHeaderSideClientExtent;
      alBottomLeft, alBottomCenter, alBottomRight:
        Result.Bottom := AHeaderSideClientExtent;
      alLeftTop, alLeftCenter, alLeftBottom:
        Result.Left := AHeaderSideClientExtent;
      alRightTop, alRightCenter, alRightBottom:
        Result.Right := AHeaderSideClientExtent;
    end;
  end;
end;

function TcxGroupBoxViewData.HasShadow: Boolean;
begin
  Result := Edit.HasShadow and inherited HasShadow;
end;

class function TcxGroupBoxViewData.IsNativeStyle(ALookAndFeel: TcxLookAndFeel): Boolean;
begin
  Result := AreVisualStylesMustBeUsed(
    ALookAndFeel.NativeStyle or (ALookAndFeel.Kind = lfOffice11), totEdit) and
      (ALookAndFeel.SkinPainter = nil);
end;

function TcxGroupBoxViewData.GetContainerState(const ABounds: TRect;
  const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
  AIsMouseEvent: Boolean): TcxContainerState;
begin
  if Enabled then
    Result := [csNormal]
  else
    Result := [csDisabled];
end;

function TcxGroupBoxViewData.IsPanelStyle: Boolean;
begin
  Result := (Edit <> nil) and Edit.IsPanelStyle;
end;

function TcxGroupBoxViewData.HasNonClientArea: Boolean;
begin
  Result := not IsInplace and Edit.HasNonClientArea;
end;

function TcxGroupBoxViewData.GetShadowWidth: Integer;
begin
  Result := 0;
  if HasShadow then
    Result := cxContainerShadowWidth;
end;

function TcxGroupBoxViewData.GetCaptionRect(ACanvas: TcxCanvas): TRect;
var
  ACaptionSize: TSize;
begin
  if Edit.FVisibleCaption = '' then
  begin
    Result := cxEmptyRect;
    Exit;
  end;
  Edit.AdjustCanvasFontSettings(ACanvas);
  with ACanvas do
  begin
    ACaptionSize := cxTextExtent(Font, Edit.FVisibleCaption);
    Result := Rect(0, 0, ACaptionSize.cx, ACaptionSize.cy);
    OffsetRect(Result, cxCaptionRectLeftBound, 0);
    if not Edit.IsVerticalText then
      AdjustHorizontalCaptionRect(Result)
    else
      AdjustVerticalCaptionRect(Result);
    //B93506
    //InflateRect(Result, 1, 1);
  end;
end;

procedure TcxGroupBoxViewData.AdjustHorizontalCaptionRect(var R: TRect);
var
  AShadowWidth: Integer;
begin
  AShadowWidth := GetShadowWidth;

  case Edit.FAlignment of
    alTopCenter, alBottomCenter, alCenterCenter:
      OffsetRect(R, -R.Left + (Edit.Width - AShadowWidth - (R.Right - R.Left)) div 2, 0);
    alTopRight, alRightTop, alRightCenter, alRightBottom, alBottomRight:
      OffsetRect(R, Edit.Width - R.Right - R.Left - AShadowWidth, 0);
  end;
  case Edit.FAlignment of
    alLeftCenter, alRightCenter, alCenterCenter:
      OffsetRect(R, 0, -R.Top + (Edit.Height - AShadowWidth -
        (R.Bottom - R.Top)) div 2);
    alLeftBottom, alBottomLeft, alBottomCenter, alBottomRight, alRightBottom:
      R := Rect(R.Left, Edit.Height - R.Top -
        (R.Bottom - R.Top), R.Right, Edit.Height - R.Top);
  end
end;

procedure TcxGroupBoxViewData.AdjustVerticalCaptionRect(var R: TRect);
var
  AShadowWidth, ATextWidth: Integer;
begin
  AShadowWidth := GetShadowWidth;
  ATextWidth := R.Right - R.Left;

  case Edit.FAlignment of
    alLeftTop:
      begin
        R := Rect(R.Top, R.Left, R.Bottom, 0);
        R.Bottom := R.Top + ATextWidth + 1;
      end;
    alLeftCenter:
      begin
        R := Rect(R.Top, 0, R.Bottom,
        Edit.Height - AShadowWidth - (Edit.Height - AShadowWidth - ATextWidth) div 2);
        R.Top := R.Bottom - ATextWidth - 1;
      end;
    alLeftBottom:
      begin
        R := Rect(R.Top, 0, R.Bottom,
        Edit.Height - AShadowWidth - R.Left);
        R.Top := R.Bottom - ATextWidth - 1;
      end;
    alRightTop:
      R := Rect(Edit.Width - R.Bottom, R.Left,
        Edit.Width - R.Top, R.Left + ATextWidth);
    alRightCenter:
      begin
        R := Rect(Edit.Width - R.Bottom,
          (Edit.Height - ATextWidth) div 2, Edit.Width - R.Top, 0);
        R.Bottom := R.Top + ATextWidth;
      end;
    alRightBottom:
      R := Rect(Edit.Width - R.Bottom,
        Edit.Height - R.Left - ATextWidth, Edit.Width - R.Top,
        Edit.Height - R.Left);
  end;
end;

function TcxGroupBoxViewData.GetEdit: TcxCustomGroupBox;
begin
  Result := TcxCustomGroupBox(FEdit);
end;

procedure TcxGroupBoxViewData.CalcRects(ACanvas: TcxCanvas;
  AEditViewInfo: TcxGroupBoxViewInfo);

  procedure CalculateBorderRect(var R: TRect; const AIndent: TRect;
    ACaptionPosition: TcxGroupBoxCaptionPosition);
  begin
    if HasNonClientArea then
      case ACaptionPosition of
        cxgpTop:
          Dec(R.Bottom, AIndent.Top);
        cxgpLeft:
          Dec(R.Right, AIndent.Left);
      end;
  end;

  procedure CalculateCaptionRect(var R: TRect; const AIndent: TRect;
    const ATextSize: TSize; ACaptionPosition: TcxGroupBoxCaptionPosition);
  begin
    case ACaptionPosition of
      cxgpBottom:
        R.Top := R.Bottom - ATextSize.cy - AIndent.Bottom;
      cxgpRight:
        R.Left := R.Right - ATextSize.cy - AIndent.Right;
      cxgpCenter:
        R := cxRectCenter(R, ATextSize);
      cxgpLeft:
        begin
          R.Right := R.Left + ATextSize.cy;
          if HasNonClientArea then
            Dec(R.Left, AIndent.Left)
          else
            Inc(R.Right, AIndent.Left);
        end;
      cxgpTop:
        begin
          R.Bottom := R.Top + ATextSize.cy;
          if HasNonClientArea then
            Dec(R.Top, AIndent.Top)
          else
            Inc(R.Bottom, AIndent.Top);
        end;
    end;
  end;

  procedure CalculateTextRect(const ABorderSize: TRect; ATextWidth: Integer);
  begin
    with AEditViewInfo do
    begin
      TextRect := cxRectContent(CaptionRect, ABorderSize);
      if Edit.Alignment in [alTopRight, alBottomRight] then
        TextRect.Left := TextRect.Right - ATextWidth;
      if Edit.Alignment in [alTopCenter, alBottomCenter] then
        TextRect.Left := (TextRect.Left + TextRect.Right - ATextWidth) div 2;
      if Edit.Alignment in [alLeftTop, alRightTop] then
        TextRect.Bottom := TextRect.Top + ATextWidth;
      if Edit.Alignment in [alLeftBottom, alRightBottom] then
        TextRect.Top := TextRect.Bottom - ATextWidth;
      if Edit.Alignment in [alLeftCenter, alRightCenter] then
      begin
        TextRect.Top := (TextRect.Bottom + TextRect.Top - ATextWidth) div 2;
        TextRect.Bottom := TextRect.Top + ATextWidth;
      end;
    end;
  end;

var
  ACaptionPos: TcxGroupBoxCaptionPosition;
  ARect: TRect;
  ATextSize: TSize;
begin
  if IsPanelStyle then
  begin
    AEditViewInfo.CalcBoundsForPanel;
    Exit;
  end;

  if Style.LookAndFeel.SkinPainter = nil then
  begin
    AEditViewInfo.CaptionRect := GetCaptionRect(ACanvas);
    AEditViewInfo.TextRect := AEditViewInfo.CaptionRect;
  end
  else
    with AEditViewInfo do
    begin
      ARect := GetCaptionRectIndent; 
      BorderRect := ControlRect;
      CaptionRect := BorderRect;
      Edit.AdjustCanvasFontSettings(ACanvas);
      ATextSize := ACanvas.TextExtent(Edit.FVisibleCaption);
      ATextSize.cy := Max(ATextSize.cy, ACanvas.TextHeight('Qq'));
      ACaptionPos := cxGroupBoxAlignment2GroupBoxCaption(Edit.Alignment);
      CalculateCaptionRect(CaptionRect, ARect, ATextSize, ACaptionPos);
      CalculateBorderRect(BorderRect, ARect, ACaptionPos);
      CalculateTextRect(Style.LookAndFeel.SkinPainter.GroupBoxBorderSize(True,
        ACaptionPos), ATextSize.cx);
      AdjustCaptionRect(ACaptionPos);
    end;
end;

{ TcxButtonGroupViewInfo }

procedure TcxButtonGroupViewInfo.DrawEditButton(ACanvas: TcxCanvas;
  AButtonVisibleIndex: Integer);
var
  AButtonViewInfo: TcxGroupBoxButtonViewInfo;
  AGlyphRect: TRect;
begin
  AButtonViewInfo := TcxGroupBoxButtonViewInfo(ButtonsInfo[AButtonVisibleIndex]);
  AGlyphRect := AButtonViewInfo.GetGlyphRect(ACanvas, GetGlyphSize,
    Alignment, IsDBEditPaintCopyDrawing);
  if not IsDBEditPaintCopyDrawing then
    DrawEditBackground(ACanvas, AButtonViewInfo.Bounds, AGlyphRect,
      IsButtonGlypthTransparent(AButtonViewInfo));
  DrawButtonGlyph(ACanvas, AButtonViewInfo, AGlyphRect);
  DrawButtonCaption(ACanvas, AButtonViewInfo, AGlyphRect);
end;

function TcxButtonGroupViewInfo.GetGlyphSize: TSize;
begin
  Result := GlyphSize;
end;

{ TcxButtonGroupViewData }

procedure TcxButtonGroupViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
  AIsMouseEvent: Boolean);
begin
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo,
    AIsMouseEvent);
  with TcxButtonGroupViewInfo(AViewInfo) do
  begin
    DrawTextFlags := GetDrawTextFlags;
    CaptionExtent := GetCaptionRectExtent;
  end;
end;

procedure TcxButtonGroupViewData.CalculateButtonsViewInfo(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo; AIsMouseEvent: Boolean);

  procedure CalculateButtonStates;
  var
    AButtonsCount, APrevPressedButton, I: Integer;
    AButtonViewInfo: TcxGroupBoxButtonViewInfo;
    ACapturePressing, AHoldPressing, AIsButtonPressed, AMouseButtonPressing: Boolean;
  begin
    AButtonsCount := Properties.Items.Count;
    AViewInfo.IsButtonReallyPressed := False;
    if AIsMouseEvent then
      APrevPressedButton := AViewInfo.PressedButton
    else
      APrevPressedButton := -1;
    AViewInfo.PressedButton := -1;
    AViewInfo.SelectedButton := -1;

    for I := 0 to AButtonsCount - 1 do
    begin
      AButtonViewInfo := TcxGroupBoxButtonViewInfo(AViewInfo.ButtonsInfo[I]);
      AButtonViewInfo.Index := I;
      AButtonViewInfo.Data.NativeStyle := IsButtonNativeStyle(Style.LookAndFeel);
      AButtonViewInfo.Data.Transparent := (Self.Style.ButtonTransparency = ebtAlways) or
        (Self.Style.ButtonTransparency = ebtInactive) and not Selected;

      AButtonViewInfo.Data.BackgroundColor := AViewInfo.BackgroundColor;
      AIsButtonPressed := IsButtonPressed(AViewInfo, I);
      with AButtonViewInfo do
      begin
        if not Enabled then
          Data.State := ebsDisabled
        else
          if AIsButtonPressed or (not IsDesigning and PtInRect(AButtonViewInfo.Bounds, P)) then
          begin
            ACapturePressing := (Button = cxmbNone) and (ButtonToShift(mbLeft) *
              Shift <> []) and (Data.State = ebsNormal) and (GetCaptureButtonVisibleIndex =
              I);
            AMouseButtonPressing := (Button = ButtonTocxButton(mbLeft)) and
              ((Shift = ButtonToShift(mbLeft)) or
              (Shift = ButtonToShift(mbLeft) + [ssDouble]));
            AHoldPressing := (Data.State = ebsPressed) and (Shift * ButtonToShift(mbLeft) <> []);
            if AIsButtonPressed or AMouseButtonPressing or AHoldPressing or
                ACapturePressing then
              AViewInfo.IsButtonReallyPressed := True;
            if not AIsButtonPressed and (Shift = []) and not ACapturePressing then
            begin
              Data.State := ebsSelected;
              AViewInfo.SelectedButton := I;
            end
            else
              if (AIsButtonPressed or ACapturePressing and CanPressButton(AViewInfo, I) or ((Shift = [ssLeft]) or (Shift = [ssLeft, ssDouble])) and
                ((Button = cxmbLeft) and CanPressButton(AViewInfo, I) or
                (APrevPressedButton = I))) or AHoldPressing then
              begin
                Data.State := ebsPressed;
                AViewInfo.PressedButton := I;
              end
              else
                Data.State := ebsNormal;
          end
          else
            Data.State := ebsNormal;

      CalculateButtonNativeState(AViewInfo, AButtonViewInfo);
      end;
    end;
  end;

var
  AButtonsCount: Integer;
begin
  AButtonsCount := Properties.Items.Count;
  TcxGroupBoxViewInfo(AViewInfo).SetButtonCount(AButtonsCount);
  if AButtonsCount = 0 then
    Exit;

  CalculateButtonViewInfos(AViewInfo);
  CalculateButtonPositions(ACanvas, AViewInfo);
  CalculateButtonStates;
end;

function TcxButtonGroupViewData.GetEditConstantPartSize(ACanvas: TcxCanvas;
  const AEditSizeProperties: TcxEditSizeProperties;
  var MinContentSize: TSize; AViewInfo: TcxCustomEditViewInfo = nil): TSize;
var
  AButtonsCount, AButtonsPerColumn, AColumnsCount: Integer;
  ACaption: string;
  AColumnWidth, AMaxButtonHeight: Integer;
  ADefaultButtonHeight, AButtonHeight: Integer;
  AFlags: Integer;
  AMaxColumnWidth: Integer;
  ASizeCorrection: TSize;
  ATextWidth: Integer;
  I: Integer;
  R: TRect;
  AEditMetrics: TcxEditMetrics;
begin
  MinContentSize := cxNullSize;
  ACanvas.Font := Style.GetVisibleFont;
  ASizeCorrection := Self.GetEditContentSizeCorrection;
  AButtonsCount := Properties.Items.Count;
  AColumnsCount := Properties.GetColumnCount;
  GetEditMetrics(AEditSizeProperties.Width >= 0, ACanvas, AEditMetrics);
  ADefaultButtonHeight := ACanvas.TextHeight('Zg') + ASizeCorrection.cy;
  if AEditSizeProperties.Width >= 0 then
  begin
    Result.cx := AEditSizeProperties.Width;
    if AButtonsCount = 0 then
      Result.cy := ADefaultButtonHeight
    else
    begin
      Result.cy := 0;
      AButtonsPerColumn := Properties.GetButtonsPerColumn;
      AColumnWidth := AEditSizeProperties.Width - ContentOffset.Left -
        ContentOffset.Right + AEditMetrics.AutoHeightWidthCorrection -
        AEditMetrics.ColumnOffset * (AColumnsCount - 1);
      AColumnWidth := AColumnWidth div AColumnsCount - AEditMetrics.ButtonSize.cx -
        AEditMetrics.AutoHeightColumnWidthCorrection;
      if AColumnWidth <= 0 then
        AColumnWidth := 1;
      AMaxButtonHeight := ADefaultButtonHeight;
      Include(PaintOptions, epoAutoHeight);
      AFlags := GetDrawTextFlags and not cxAlignVCenter or cxAlignTop;
      for I := 0 to AButtonsCount - 1 do
      begin
        R := Rect(0, 0, AColumnWidth, MaxInt);
        ACaption := Properties.Items[I].Caption;
        if Properties.WordWrap and (ACaption <> '') then
        begin
          ACanvas.TextExtent(ACaption, R, AFlags);
          AButtonHeight := R.Bottom - R.Top + ASizeCorrection.cy;
          if AMaxButtonHeight < AButtonHeight then
            AMaxButtonHeight := AButtonHeight;
        end;
      end;
      Result.cy := AMaxButtonHeight * AButtonsPerColumn;
      if not IsInplace then
      begin
        R := GetClientExtent(ACanvas, nil);
        Result.cy := Result.cy + R.Top + R.Bottom;
      end;
    end;
  end else
  begin
    if AButtonsCount = 0 then
    begin
      Result.cx := 0;
      Result.cy := ACanvas.TextHeight('Zg') + ASizeCorrection.cy;
    end else
    begin
      AMaxColumnWidth := 0;
      AButtonsPerColumn := Properties.GetButtonsPerColumn;
      for I := 0 to AButtonsCount - 1 do
      begin
        ATextWidth := ACanvas.TextWidth(Properties.Items[I].Caption);
        if ATextWidth > AMaxColumnWidth then
          AMaxColumnWidth := ATextWidth;
      end;
      Result.cx := (AMaxColumnWidth + AEditMetrics.ColumnWidthCorrection + AEditMetrics.ButtonSize.cx) *
        AColumnsCount + AEditMetrics.ColumnOffset * (AColumnsCount - 1) + AEditMetrics.WidthCorrection;
      if ADefaultButtonHeight > AEditMetrics.ButtonSize.cy then
        Result.cy := ADefaultButtonHeight
      else
        Result.cy := AEditMetrics.ButtonSize.cy;
      Result.cy := Result.cy * AButtonsPerColumn;
    end;
  end;
end;

class function TcxButtonGroupViewData.IsButtonNativeStyle(
  ALookAndFeel: TcxLookAndFeel): Boolean;
begin
  Result := AreVisualStylesMustBeUsed(ALookAndFeel.NativeStyle, totButton);
end;

procedure TcxButtonGroupViewData.CalculateButtonPositions(ACanvas: TcxCanvas;
  AViewInfo: TcxCustomEditViewInfo);
var
  AButtonsCount, AButtonsPerColumn, AButtonHeight, AButtonWidth, AClientHeight,
    AColumnsCount, ATopOffset, I: Integer;
  AButtonViewInfo: TcxGroupBoxButtonViewInfo;
  AClientExtent: TRect;
  AEditMetrics: TcxEditMetrics;
begin
  AButtonsCount := Properties.Items.Count;
  AColumnsCount := Properties.GetColumnCount;
  AButtonsPerColumn := Properties.GetButtonsPerColumn;
  AClientExtent := GetClientExtent(ACanvas, AViewInfo);
  GetEditMetrics(False, nil, AEditMetrics);
  AButtonWidth := (Bounds.Right - Bounds.Left - (AClientExtent.Left +
    AClientExtent.Right) + AEditMetrics.ClientWidthCorrection -
    AEditMetrics.ColumnOffset * (AColumnsCount - 1)) div AColumnsCount;
  AClientHeight := Bounds.Bottom - Bounds.Top - AClientExtent.Top - AClientExtent.Bottom;

  ATopOffset := Bounds.Top + AClientExtent.Top + (AClientHeight mod AButtonsPerColumn) div 2;

    AButtonHeight := AClientHeight div AButtonsPerColumn;

  for I := 0 to AButtonsCount - 1 do
  begin
    AButtonViewInfo := TcxGroupBoxButtonViewInfo(AViewInfo.ButtonsInfo[I]);
    AButtonViewInfo.Bounds.Left := Bounds.Left + AClientExtent.Left +
      AButtonViewInfo.Column * (AButtonWidth + AEditMetrics.ColumnOffset) +
      AEditMetrics.ClientLeftBoundCorrection;
    AButtonViewInfo.Bounds.Top := ATopOffset + AButtonViewInfo.Row * AButtonHeight;
    AButtonViewInfo.Bounds.Right := AButtonViewInfo.Bounds.Left + AButtonWidth;
    AButtonViewInfo.Bounds.Bottom := AButtonViewInfo.Bounds.Top + AButtonHeight;
    AButtonViewInfo.VisibleBounds := AButtonViewInfo.Bounds;
  end;
end;

procedure TcxButtonGroupViewData.CalculateButtonViewInfos(AViewInfo: TcxCustomEditViewInfo);

  function GetButtonStyle: TcxEditButtonStyle;
  const
    AButtonInplaceStyleMap: array[TcxLookAndFeelKind] of TcxEditButtonStyle =
      (btsFlat, bts3D, btsUltraFlat,
      btsOffice11);
    AButtonStyleMap: array [TcxEditBorderStyle] of TcxEditButtonStyle =
      (bts3D, btsFlat, btsFlat, btsFlat, bts3D, btsUltraFlat,
      btsOffice11);
  begin
    if IsInplace then
      Result := AButtonInplaceStyleMap[Style.LookAndFeel.Kind]
    else
      case Style.BorderStyle of
        ebsUltraFlat:
          Result := btsUltraFlat;
        ebsOffice11:
          Result := btsOffice11;
        else
          Result := AButtonStyleMap[AViewInfo.BorderStyle];
      end;
  end;

var
  AButtonsCount, AButtonsPerColumn, I: Integer;
  AButtonStyle: TcxEditButtonStyle;
  AButtonViewInfo: TcxGroupBoxButtonViewInfo;
begin
  AButtonStyle := GetButtonStyle;
  AButtonsCount := Properties.Items.Count;
  AButtonsPerColumn := Properties.GetButtonsPerColumn;

  for I := 0 to AButtonsCount - 1 do
  begin
    AButtonViewInfo := TcxGroupBoxButtonViewInfo(AViewInfo.ButtonsInfo[I]);
    with AButtonViewInfo do
    begin
      HasBackground := AViewInfo.HasBackground;
      Data.Style := AButtonStyle;
      Caption := Properties.FItems[I].Caption;
      Column := I div AButtonsPerColumn;
      Row := I mod AButtonsPerColumn;
    end;
  end;
end;

function TcxButtonGroupViewData.GetDrawTextFlags: Integer;
begin
  Result := cxAlignLeft or cxAlignVCenter or cxShowPrefix;
  if (epoAutoHeight in PaintOptions) and Properties.WordWrap then
  begin
    Result := Result or cxDontClip;
    Result := Result or cxWordBreak;
  end
  else
    Result := Result or cxSingleLine;
end;

function TcxButtonGroupViewData.GetCaptionRectExtent: TRect;
begin
  Result := cxEmptyRect;
end;

function TcxButtonGroupViewData.GetProperties: TcxCustomButtonGroupProperties;
begin
  Result := TcxCustomButtonGroupProperties(FProperties);
end;

{ TcxCustomGroupBoxProperties }

class function TcxCustomGroupBoxProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxCustomGroupBox;
end;

class function TcxCustomGroupBoxProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxGroupBoxViewInfo;
end;

class function TcxCustomGroupBoxProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxGroupBoxViewData;
end;

{ TcxButtonGroupItem }

constructor TcxButtonGroupItem.Create(Collection: TCollection);
begin
  if Assigned(Collection) then
    Collection.BeginUpdate;
  try
    inherited Create(Collection);
    FEnabled := True;
    DoChanged(Collection, copAdd);
  finally
    if Assigned(Collection) then
      Collection.EndUpdate;
  end;
end;

destructor TcxButtonGroupItem.Destroy;
var
  ACollection: TCollection;
  AIndex: Integer;
begin
  ACollection := Collection;
  if not IsCollectionDestroying then
    AIndex := Index
  else
    AIndex := -1;
  if Assigned(ACollection) then
    ACollection.BeginUpdate;
  try
    inherited Destroy;
    DoChanged(ACollection, copDelete, AIndex);
  finally
    if Assigned(ACollection) then
      ACollection.EndUpdate;
  end;
end;

procedure TcxButtonGroupItem.Assign(Source: TPersistent);
begin
  if Source is TcxButtonGroupItem then
    with TcxButtonGroupItem(Source) do
    begin
      Self.Caption := Caption;
      Self.Enabled := Enabled;
      Self.Tag := Tag;
    end
  else
    inherited Assign(Source);
end;

function TcxButtonGroupItem.GetCaption: TCaption;
begin
  Result := FCaption;
end;

procedure TcxButtonGroupItem.DoChanged(ACollection: TCollection;
  ACollectionOperation: TcxCollectionOperation; AIndex: Integer = -1);
begin
  if Assigned(ACollection) then
    if AIndex = -1 then
      TcxButtonGroupItems(ACollection).InternalNotify(Self, AIndex, ACollectionOperation)
    else
      TcxButtonGroupItems(ACollection).InternalNotify(nil, AIndex, ACollectionOperation);
end;

function TcxButtonGroupItem.GetIsCollectionDestroying: Boolean;
begin
  Result := (Collection <> nil) and TcxButtonGroupItems(Collection).IsDestroying;
end;

function TcxButtonGroupItem.IsTagStored: Boolean;
begin
  Result := FTag <> 0;
end;

procedure TcxButtonGroupItem.SetCaption(const Value: TCaption);
begin
  if Value <> FCaption then
  begin
    FCaption := Value;
    DoChanged(Collection, copChanged);
  end;
end;

procedure TcxButtonGroupItem.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    DoChanged(Collection, copChanged);
  end;
end;

{ TcxButtonGroupItems }

procedure TcxButtonGroupItems.InternalNotify(AItem: TcxButtonGroupItem;
  AItemIndex: Integer; AItemOperation: TcxCollectionOperation);
begin
  if TcxCustomEditProperties(GetOwner).ChangedLocked or IsDestroying then
    Exit;
  if AItem <> nil then
    FChangedItemIndex := AItem.Index
  else
    FChangedItemIndex := AItemIndex;
  FChangedItemOperation := AItemOperation;
  FItemChanged := True;
  try
    TcxCustomEditProperties(GetOwner).Changed;
  finally
    FItemChanged := False;
  end;
end;

procedure TcxButtonGroupItems.Update(Item: TCollectionItem);
begin
  inherited;
  TcxCustomEditProperties(GetOwner).Changed;
end;

function TcxButtonGroupItems.GetItem(Index: Integer): TcxButtonGroupItem;
begin
  Result := TcxButtonGroupItem(inherited Items[Index]);
end;

procedure TcxButtonGroupItems.SetItem(Index: Integer; Value: TcxButtonGroupItem);
begin
  inherited Items[Index] := Value;
end;

function TcxButtonGroupItems.CheckItemsGetCaption(Index: Integer): string;
begin
  Result := TcxButtonGroupItem(Items[Index]).Caption;
end;

function TcxButtonGroupItems.CheckItemsGetCount: Integer;
begin
  Result := Count;
end;

{ TcxCustomButtonGroupProperties }

constructor TcxCustomButtonGroupProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FColumns := 1;
  FItems := CreateItems;
end;

destructor TcxCustomButtonGroupProperties.Destroy;
begin
  BeginUpdate;
  try
    FreeAndNil(FItems);
  finally
    EndUpdate(False);
  end;
  inherited Destroy;
end;

procedure TcxCustomButtonGroupProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomButtonGroupProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomButtonGroupProperties do
      begin
        Self.Columns := Columns;
        Self.Items := Items;
        Self.WordWrap := WordWrap;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

function TcxCustomButtonGroupProperties.CreatePreviewProperties: TcxCustomEditProperties;
const
  AItemCaptions: array [0..2] of string = ('A', 'B', 'C');
var
  I: Integer;
begin
  Result := inherited CreatePreviewProperties;
  for I := 0 to High(AItemCaptions) do
    TcxButtonGroupItem(TcxCustomButtonGroupProperties(Result).Items.Add).Caption := AItemCaptions[I];
  TcxCustomButtonGroupProperties(Result).Columns := 3;
end;

class function TcxCustomButtonGroupProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxCustomButtonGroup;
end;

function TcxCustomButtonGroupProperties.GetSpecialFeatures: TcxEditSpecialFeatures;
begin
  Result := inherited GetSpecialFeatures + [esfMinSize];
end;

function TcxCustomButtonGroupProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := [esoAlwaysHotTrack, esoAutoHeight, esoEditing, esoFiltering,
    esoShowingCaption, esoSorting, esoTransparency];
  if Items.Count > 0 then
    Include(Result, esoHotTrack);
end;

class function TcxCustomButtonGroupProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxButtonGroupViewInfo;
end;

class function TcxCustomButtonGroupProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxButtonGroupViewData;
end;

function TcxCustomButtonGroupProperties.GetColumnCount: Integer;
var
  AButtonCount, AButtonsPerColumn: Integer;
begin
  Result := Columns;
  AButtonCount := Items.Count;
  if Result > AButtonCount then
    Result := AButtonCount;
  if AButtonCount > 0 then
  begin
    if Result = 0 then
      Result := 1;
    AButtonsPerColumn := (AButtonCount + Result - 1) div Result;
    Result := (AButtonCount + AButtonsPerColumn - 1) div AButtonsPerColumn;
  end;
end;

function TcxCustomButtonGroupProperties.CreateItems: TcxButtonGroupItems;
begin
  Result := TcxButtonGroupItems.Create(Self, TcxButtonGroupItem);
end;

function TcxCustomButtonGroupProperties.GetButtonsPerColumn: Integer;
var
  AColumnsCount: Integer;
begin
  AColumnsCount := GetColumnCount;
  Result := (Items.Count + AColumnsCount - 1) div AColumnsCount;
end;

procedure TcxCustomButtonGroupProperties.SetColumns(Value: Integer);
begin
  if Value < 1 then
    Value := 1;
  if Value <> FColumns then
  begin
    FColumns := Value;
    Changed;
  end;
end;

procedure TcxCustomButtonGroupProperties.SetItems(Value: TcxButtonGroupItems);
begin
  FItems.Assign(Value);
end;

procedure TcxCustomButtonGroupProperties.SetWordWrap(Value: Boolean);
begin
  if Value <> FWordWrap then
  begin
    FWordWrap := Value;
    Changed;
  end;
end;

{ TcxPanelStyle }

constructor TcxPanelStyle.Create(AOwner: TcxCustomGroupBox);
begin
  inherited Create;
  FEdit := AOwner;
  FCaptionIndent := 2;
  FActive := False;
  FOfficeBackgroundKind := pobkOffice11Color;
  FWordWrap := False;
end;

procedure TcxPanelStyle.Assign(ASource: TPersistent);
begin
  if ASource is TcxPanelStyle then
  begin
    Active := TcxPanelStyle(ASource).Active;
    CaptionIndent := TcxPanelStyle(ASource).CaptionIndent;
    WordWrap := TcxPanelStyle(ASource).WordWrap;
    OfficeBackgroundKind := TcxPanelStyle(ASource).OfficeBackgroundKind;
  end
  else
    inherited Assign(ASource);
end;

procedure TcxPanelStyle.SetActive(AValue: Boolean);
begin
  if AValue <> FActive then
  begin
    FActive := AValue;
    Update;
  end;
end;

procedure TcxPanelStyle.SetBorderWidth(AValue: TBorderWidth);
begin
  if AValue <> FBorderWidth then
  begin
    FBorderWidth := AValue;
    if Active then
      Update;
  end;
end;

procedure TcxPanelStyle.SetCaptionIndent(AValue: Integer);
begin
  AValue := Max(2, AValue);
  if AValue <> FCaptionIndent then
  begin
    FCaptionIndent := AValue;
    if FActive then
      Update;
  end;
end;

procedure TcxPanelStyle.SetOfficeBackgroundKind(
  AValue: TcxPanelOffice11BackgroundKind);
begin
  if FOfficeBackgroundKind <> AValue then
  begin
    FOfficeBackgroundKind := AValue;
    if FActive and (Edit.LookAndFeel.Kind = lfOffice11) then
      Update;
  end;
end;

procedure TcxPanelStyle.SetWordWrap(AValue: Boolean);
begin
  if AValue <> FWordWrap then
  begin
    FWordWrap := AValue;
    if FActive then
      Update;
  end;
end;

procedure TcxPanelStyle.Update;
begin
  Edit.UpdateCaption;
end;

{ TcxCustomGroupBox }

constructor TcxCustomGroupBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRedrawOnResize := True;
end;

destructor TcxCustomGroupBox.Destroy;
begin
  FreeAndNil(FCaptionFont);
  FreeAndNil(FPanelStyle);
  inherited Destroy;
end;

class function TcxCustomGroupBox.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomGroupBoxProperties;
end;

procedure TcxCustomGroupBox.CalculateVisibleCaption;
begin
  if FVisibleCaption <> GetVisibleCaption then
  begin
    FVisibleCaption := GetVisibleCaption;
    UpdateNonClientArea;
  end;
end;

function TcxCustomGroupBox.GetCaptionBkColor: TColor;
begin
  Result := FCaptionBkColor; // for CBuilder 10 
end;

function TcxCustomGroupBox.GetColor: TColor;
begin
  Result := Style.Color;
end;

function TcxCustomGroupBox.GetFont: TFont;
begin
  Result := Style.GetVisibleFont;
end;

function TcxCustomGroupBox.GetViewInfo: TcxGroupBoxViewInfo;
begin
  Result := TcxGroupBoxViewInfo(inherited ViewInfo);
end;

function TcxCustomGroupBox.IsSkinAvailable: Boolean;
begin
  Result := (LookAndFeel <> nil) and (LookAndFeel.SkinPainter <> nil);
end;

procedure TcxCustomGroupBox.UpdateCaption;
begin
  CalculateCaptionFont;
  CalculateVisibleCaption;
  ShortRefreshContainer(False);
  UpdateNonClientArea;
  Realign;
end;

procedure TcxCustomGroupBox.UpdateNonClientArea;
begin
  if HandleAllocated and IsNonClientAreaSupported then
    PostMessage(Handle, WM_DXUPDATENONCLIENTAREA, 0, 0);
end;

procedure TcxCustomGroupBox.SetPanelStyle(AValue: TcxPanelStyle);
begin
  if AValue <> FPanelStyle then
  begin
    FPanelStyle.Assign(AValue);
    UpdateCaption;
  end;
end;

function TcxCustomGroupBox.GetHorizontalCaptionIndent: Integer;
begin
  Result := 0;
  if IsPanelStyle Then
  begin
    Result := 2;
    if not (Alignment in [alTopCenter, alCenterCenter, alBottomCenter]) then
      Result := PanelStyle.CaptionIndent;
  end;
end;

function TcxCustomGroupBox.GetVerticalCaptionIndent: Integer;
begin
  Result := 0;
  if IsPanelStyle Then
  begin
    Result := 2;
    if not (FAlignment in [alLeftCenter, alCenterCenter, alRightCenter]) then
      Result := PanelStyle.CaptionIndent;
  end;
end;

function TcxCustomGroupBox.GetVisibleCaption: string;
begin
  if IsVerticalText then
    Result := RemoveAccelChars(Caption)
  else
    Result := Caption;
end;

function TcxCustomGroupBox.GetPanelStyleCaptionDrawingFlags: Cardinal;
begin
  Result := 0;
  case Alignment of
    alTopLeft, alLeftTop, alLeftCenter, alLeftBottom, alBottomLeft:
      Result := Result or DT_LEFT;
    alTopCenter, alCenterCenter, alBottomCenter:
      Result := Result or DT_CENTER;
    alTopRight, alRightTop, alRightCenter, alRightBottom, alBottomRight:
      Result := Result or DT_RIGHT;
  end;
  case Alignment of
    alLeftTop, alTopLeft, alTopCenter, alTopRight, alRightTop:
      Result := Result or DT_TOP;
    alLeftCenter, alCenterCenter, alRightCenter:
      Result := Result or DT_VCENTER;
    alLeftBottom, alBottomLeft, alBottomCenter, alBottomRight, alRightBottom:
      Result := Result or DT_BOTTOM;
  end;
end;

procedure TcxCustomGroupBox.SetAlignment(Value: TcxCaptionAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    UpdateCaption;
  end;
end;

procedure TcxCustomGroupBox.SetCaptionBkColor(Value: TColor);
begin
  FCaptionBkColor := Value; // for CBuilder 10
end;

procedure TcxCustomGroupBox.SetColor(Value: TColor);
begin
  Style.Color := Value;
end;

procedure TcxCustomGroupBox.SetFont(Value: TFont);
begin
  Style.Font := Value;
end;

{$IFNDEF DELPHI7}
procedure TcxCustomGroupBox.WMPrintClient(var Message: TMessage);
begin
  if (Message.Result <> 1) and
    ((Message.LParam and PRF_CHECKVISIBLE = 0) or Visible) then
      PaintHandler(TWMPaint(Message))
  else
    inherited;
end;
{$ENDIF}

procedure TcxCustomGroupBox.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) and CanFocus then
    begin
      FIsAccelCharHandling := True;
      try
        SelectFirst;
        Result := 1;
      finally
        FIsAccelCharHandling := False;
      end;
    end
    else
      inherited;
end;

procedure TcxCustomGroupBox.WMNCPaint(var Message: TWMNCPaint);

  procedure DrawCaption(const ACanvas: TcxCanvas);
  var
    AViewInfo: TcxGroupBoxViewInfo;
    R, R1: TRect;
  begin
    ACanvas.SaveClipRegion;
    try
      AViewInfo := TcxGroupBoxViewInfo(ViewInfo);
      R := AViewInfo.GetCaptionRectIndent;
      R1 := AViewInfo.CaptionRect;
      case cxGroupBoxAlignment2GroupBoxCaption(Alignment) of
        cxgpLeft:
          R1.Right := R1.Left + R.Left;
        cxgpRight:
          R1.Left := R1.Right - R.Right;
        cxgpTop:
          R1.Bottom := R1.Top + R.Top;
        cxgpBottom:
          R1.Top := R1.Bottom - R.Bottom;
      end;
      SetWindowOrgEx(ACanvas.Handle, -R.Left, -R.Top, nil);
      ACanvas.SetClipRegion(TcxRegion.Create(R1), roSet);
      AViewInfo.DrawCaption(ACanvas);
    finally
      ACanvas.RestoreClipRegion;
    end;
  end;

var
  ACanvas: TCanvas;
  AcxCanvas: TcxCanvas;
  DC: HDC;
begin
  if IsNonClientAreaSupported and IsSkinAvailable then
  begin
    DC := GetWindowDC(Handle);
    ACanvas := TCanvas.Create;
    AcxCanvas := TcxCanvas.Create(ACanvas);
    try
      ACanvas.Handle := DC;
      DrawCaption(AcxCanvas);
      ACanvas.Handle := 0;
    finally
      AcxCanvas.Free;
      ACanvas.Free;
    end;
    ReleaseDC(Handle, DC);
  end;
end;

function TcxCustomGroupBox.IsNonClientAreaSupported: Boolean;
begin
  Result := cxGroupBox_SupportNonClientArea;
end;

procedure TcxCustomGroupBox.WndProc(var Message: TMessage);
const
  RedrawWindowFlags = RDW_ERASE or RDW_INVALIDATE or RDW_FRAME or RDW_ALLCHILDREN;
  SetWindowPosFlags = SWP_FRAMECHANGED or SWP_NOACTIVATE or SWP_NOMOVE or
    SWP_NOSIZE or SWP_NOZORDER;
begin
  case Message.Msg of
    WM_NCPAINT:
      WMNCPaint(TWMNCPaint(Message));
    WM_NCCALCSIZE:
      if HasNonClientArea then
      begin
        TWMNCCalcSize(Message).CalcSize_Params^.rgrc[0] :=
          cxRectContent(BoundsRect, TcxGroupBoxViewInfo(ViewInfo).GetCaptionRectIndent);
      end;
    else
      if (Message.Msg = WM_DXUPDATENONCLIENTAREA) and IsNonClientAreaSupported then
      begin
        SetWindowPos(Handle, 0, 0, 0, 0, 0, SetWindowPosFlags);
        RedrawWindow(Handle, nil, 0, RedrawWindowFlags);
      end;
  end;
  inherited WndProc(Message);
end;

procedure TcxCustomGroupBox.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  inherited LookAndFeelChanged(Sender, AChangedValues);
  UpdateNonClientArea;
  Invalidate;
end;

procedure TcxCustomGroupBox.AdjustClientRect(var Rect: TRect);
var
  AViewData: TcxCustomEditViewData;
begin
  if IsDestroying then
    Exit;
  AViewData := TcxCustomEditViewData(CreateViewData);
  try
    InitializeViewData(AViewData);
    Rect := GetControlRect(Self);
    ExtendRect(Rect, AViewData.GetClientExtent(Canvas, ViewInfo));
    if IsPanelStyle then
      InflateRect(Rect, -PanelStyle.BorderWidth, -PanelStyle.BorderWidth);
  finally
    FreeAndNil(AViewData);
  end;
end;

function TcxCustomGroupBox.CanAutoSize: Boolean;
begin
  Result := False;
end;

function TcxCustomGroupBox.CanFocusOnClick: Boolean;
begin
  Result := False;
end;

function TcxCustomGroupBox.CanHaveTransparentBorder: Boolean;
begin
  Result := Style.TransparentBorder and not IsPanelStyle and inherited CanHaveTransparentBorder;
end;

procedure TcxCustomGroupBox.ContainerStyleChanged(Sender: TObject);
begin
  CalculateCaptionFont;
  inherited ContainerStyleChanged(Sender);
end;

function TcxCustomGroupBox.CreatePanelStyle: TcxPanelStyle;
begin
  Result := TcxPanelStyle.Create(Self);
end;

function TcxCustomGroupBox.DefaultParentColor: Boolean;
begin
  Result := True;
end;

procedure TcxCustomGroupBox.FontChanged;
begin
  inherited FontChanged;
  Realign;
end;

procedure TcxCustomGroupBox.Initialize;
begin
  inherited Initialize;
  ControlStyle := ControlStyle + [csAcceptsControls, csCaptureMouse, csClickEvents];
  SetBounds(Left, Top, 185, 105);
  FCaptionFont := TFont.Create;
  CalculateCaptionFont;
  TabStop := False;
  FPanelStyle := CreatePanelStyle;
end;

function TcxCustomGroupBox.InternalGetActiveStyle: TcxContainerStyle;
begin
  if csDisabled in ViewInfo.ContainerState then
    Result := FStyles.StyleDisabled
  else
    Result := FStyles.Style;
end;

function TcxCustomGroupBox.InternalGetNotPublishedStyleValues: TcxEditStyleValues;
begin
  Result := inherited InternalGetNotPublishedStyleValues;
  Include(Result, svHotTrack);
end;

function TcxCustomGroupBox.IsContainerClass: Boolean;
begin
  Result := True;
end;

function TcxCustomGroupBox.IsNativeBackground: Boolean;
begin
  Result := IsNativeStyle and ParentBackground and not IsInplace and
    not Transparent;
end;

function TcxCustomGroupBox.IsPanelStyle: Boolean;
begin
  Result := PanelStyle.Active;
end;

procedure TcxCustomGroupBox.Paint;
begin
  if not DoCustomDraw then
    inherited Paint;
end;

procedure TcxCustomGroupBox.TextChanged;
begin
  inherited TextChanged;
  CalculateVisibleCaption;
  ShortRefreshContainer(False);
end;

function TcxCustomGroupBox.HasShadow: Boolean;
begin
  Result := inherited HasShadow;
  if Result then
  begin
    if not IsPanelStyle then
      Result := Alignment in [alLeftTop, alLeftCenter, alLeftBottom, alTopLeft, alTopCenter, alTopRight];
    Result := Result and not (ViewInfo.NativeStyle or IsSkinAvailable);
  end;
end;

procedure TcxCustomGroupBox.AdjustCanvasFontSettings(ACanvas: TcxCanvas);
var
  AColor: TColorRef;
  ATextColor: TColor;
  ATheme: TdxTheme;
begin
  with ACanvas do
  begin
    Font.Assign(FCaptionFont);
    if IsNativeStyle then
    begin
      ATheme := OpenTheme(totButton);
      GetThemeColor(ATheme, BP_GROUPBOX, cxNativeState[Enabled], TMT_TEXTCOLOR, AColor);
      Font.Color := AColor;
    end;
    if ViewInfo.Painter <> nil then
    begin
      ATextColor := ViewInfo.Painter.GroupBoxTextColor(
        cxGroupBoxAlignment2GroupBoxCaption(Alignment));
      if ATextColor <> clDefault then
        Font.Color := ATextColor;
    end;    
  end;
end;

procedure TcxCustomGroupBox.CalculateCaptionFont;
var
  AFontEscapement: Longint;
  ALogFont: TLogFont;
  ATextMetric : TTextMetric;
begin
  if IsInplace then
    Exit;
  FCaptionFont.Assign(ActiveStyle.GetVisibleFont);
  if IsVerticalText then
  begin
    cxScreenCanvas.Font := FCaptionFont;
    GetTextMetrics(cxScreenCanvas.Handle, ATextMetric);
    if ATextMetric.tmPitchAndFamily and TMPF_TRUETYPE = 0 then
      FCaptionFont.Name := 'Arial';

    if FAlignment in [alLeftTop, alLeftCenter, alLeftBottom] then
      AFontEscapement := 900
    else
      AFontEscapement := 2700;
    cxGetFontData(FCaptionFont.Handle, ALogFont);
    if AFontEscapement <> ALogFont.lfEscapement then
    begin
      ALogFont.lfEscapement := AFontEscapement;
      ALogFont.lfOrientation := AFontEscapement;
      ALogFont.lfOutPrecision := OUT_TT_ONLY_PRECIS;
      FCaptionFont.Handle := CreateFontIndirect(ALogFont);
    end;
  end;
end;

procedure TcxCustomGroupBox.Resize;
begin
  if RedrawOnResize and NeedRedrawOnResize then
    InvalidateWithChildren;
  inherited Resize;
end;

function TcxCustomGroupBox.DoCustomDraw: Boolean;
begin
  Result := False;
  if Assigned(FOnCustomDraw) then
    FOnCustomDraw(Self, Result);
end;

{$IFDEF DELPHI7}
function TcxCustomGroupBox.DoCustomDrawCaption(ACanvas: TcxCanvas; const ABounds: TRect; const APainter: TcxCustomLookAndFeelPainterClass): Boolean;
begin
  Result := False;
  if Assigned(FOnCustomDrawCaption) then
    FOnCustomDrawCaption(Self, ACanvas.Canvas, ABounds, APainter, Result);
end;

function TcxCustomGroupBox.DoCustomDrawContentBackground(ACanvas: TcxCanvas; const ABounds: TRect; const APainter: TcxCustomLookAndFeelPainterClass): Boolean;
begin
  Result := False;
  if Assigned(FOnCustomDrawContentBackground) then
    FOnCustomDrawContentBackground(Self, ACanvas.Canvas, ABounds, APainter, Result);
end;

procedure TcxCustomGroupBox.DoMeasureCaptionHeight(const APainter: TcxCustomLookAndFeelPainterClass; var ACaptionHeight: Integer);
begin
  if Assigned(FOnMeasureCaptionHeight) then
    FOnMeasureCaptionHeight(Self, APainter, ACaptionHeight);
end;
{$ENDIF}

function TcxCustomGroupBox.GetCaptionDrawingFlags: Cardinal;
const
  DrawTextFlagsMap: array[Boolean] of Cardinal = (DT_SINGLELINE, DT_WORDBREAK);
begin
  if IsPanelStyle then
    Result := DrawTextFlagsMap[PanelStyle.WordWrap] or GetPanelStyleCaptionDrawingFlags
  else
    Result := DT_SINGLELINE;
end;

function TcxCustomGroupBox.GetShadowBounds: TRect;
begin
  if IsPanelStyle then
    Result := ViewInfo.GetBoundsForPanel
  else
    Result := inherited GetShadowBounds;

  case Alignment of
    alTopLeft, alTopCenter, alTopRight:
      Result.Top := 0;
    alBottomLeft, alBottomCenter, alBottomRight:
      Result.Bottom := Height;
    alLeftTop, alLeftCenter, alLeftBottom:
      Result.Left := 0;
    alRightTop, alRightCenter, alRightBottom:
      Result.Right := Width;
  end;
end;

function TcxCustomGroupBox.GetShadowBoundsExtent: TRect;
begin
  Result := inherited GetShadowBoundsExtent;
  case Alignment of
    alTopLeft, alTopCenter, alTopRight:
      Result.Top := ViewInfo.GetFrameBounds.Top - GetShadowBounds.Top;
    alLeftTop, alLeftCenter, alLeftBottom:
      Result.Left := ViewInfo.GetFrameBounds.Left - GetShadowBounds.Left;
  end;
end;

function TcxCustomGroupBox.HasNonClientArea: Boolean;
begin
  Result := not IsPanelStyle and IsNonClientAreaSupported and
    IsSkinAvailable and (Caption <> '');
end;

function TcxCustomGroupBox.IsVerticalText: Boolean;
begin
  Result := (FAlignment in [alLeftTop, alLeftCenter, alLeftBottom, alRightTop,
    alRightCenter, alRightBottom]) and not IsPanelStyle;
end;

function TcxCustomGroupBox.NeedRedrawOnResize: Boolean;
begin
  Result := IsNativeStyle or Assigned(LookAndFeel.SkinPainter);
end;

{ TcxCustomButtonGroup }

destructor TcxCustomButtonGroup.Destroy;
begin
  SetButtonCount(0);
  FreeAndNil(FButtons);
  inherited Destroy;
end;

procedure TcxCustomButtonGroup.ActivateByMouse(Shift: TShiftState; X, Y: Integer;
  var AEditData: TcxCustomEditData);
var
  P: TPoint;
  AButtonIndex: Integer;
begin
  Activate(AEditData);
  P := Parent.ClientToScreen(Point(X, Y));
  P := ScreenToClient(P);
  AButtonIndex := GetButtonIndexAt(P);
  if AButtonIndex <> -1 then
  begin
    with ViewInfo.ButtonsInfo[AButtonIndex].Bounds do
    begin
      P.X := (Right - Left) div 2;
      P.Y := (Bottom - Top) div 2;
    end;
    if ssLeft in Shift then
    begin
      SendMouseEvent(TWinControl(FButtons[AButtonIndex]), WM_MOUSEMOVE, [], P);
      SendMouseEvent(TWinControl(FButtons[AButtonIndex]), WM_LBUTTONDOWN, Shift, P);
    end
    else
      SendMouseEvent(TWinControl(FButtons[AButtonIndex]), WM_LBUTTONUP, Shift, P);
  end;
end;

function TcxCustomButtonGroup.Focused: Boolean;
var
  I: Integer;
begin
  Result := inherited Focused;
  if not Result and not FIsCreating then
    for I := 0 to FButtons.Count - 1 do
      if TWinControl(FButtons[I]).Focused then
      begin
        Result := True;
        Break;
      end;
end;

class function TcxCustomButtonGroup.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomButtonGroupProperties;
end;

procedure TcxCustomButtonGroup.GetTabOrderList(List: TList);
begin
  if IsInplace and Visible then
    List.Remove(Parent);
end;

function TcxCustomButtonGroup.IsButtonNativeStyle: Boolean;
begin
  Result := TcxButtonGroupViewDataClass(Properties.GetViewDataClass).IsButtonNativeStyle(Style.LookAndFeel);
end;

procedure TcxCustomButtonGroup.PropertiesChanged(Sender: TObject);
begin
  if not (csReading in ComponentState) then
    UpdateButtons;
  inherited PropertiesChanged(Sender);
end;

procedure TcxCustomButtonGroup.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
  UpdateButtons;
  SynchronizeDisplayValue;
end;

function TcxCustomButtonGroup.CanAutoSize: Boolean;
begin
  Result := not IsInplace and AutoSize;
end;

procedure TcxCustomButtonGroup.ContainerStyleChanged(Sender: TObject);
begin
  inherited ContainerStyleChanged(Sender);
  if not FIsCreating then
    UpdateButtons;
end;

procedure TcxCustomButtonGroup.CursorChanged;
begin
  UpdateButtons;
end;

procedure TcxCustomButtonGroup.DoEditKeyDown(var Key: Word; Shift: TShiftState);
var
  AButtonsInColumn, AButtonsPerColumn: Integer;
  AFocusedButtonIndex: Integer;
  AColumn, ARow: Integer;
begin
  AFocusedButtonIndex := GetFocusedButtonIndex;
  if AFocusedButtonIndex = -1 then
    Exit;
  AButtonsPerColumn := ActiveProperties.GetButtonsPerColumn;
  AButtonsInColumn := AButtonsPerColumn;
  with TcxGroupBoxButtonViewInfo(ViewInfo.ButtonsInfo[AFocusedButtonIndex]) do
  begin
    AColumn := Column;
    ARow := Row;
  end;
  if AFocusedButtonIndex - ARow + AButtonsInColumn - 1 >= ActiveProperties.Items.Count then
    AButtonsInColumn := ActiveProperties.Items.Count - (AFocusedButtonIndex - ARow);
  case Key of
    VK_DOWN:
      if ARow < AButtonsInColumn - 1 then
      begin
        TWinControl(FButtons[AFocusedButtonIndex + 1]).SetFocus;
        Key := 0;
      end;
    VK_LEFT:
      if AColumn > 0 then
      begin
        TWinControl(FButtons[AFocusedButtonIndex - AButtonsPerColumn]).SetFocus;
        Key := 0;
      end;
    VK_RIGHT:
      if AFocusedButtonIndex + AButtonsPerColumn < FButtons.Count then
      begin
        TWinControl(FButtons[AFocusedButtonIndex + AButtonsPerColumn]).SetFocus;
        Key := 0;
      end;
    VK_UP:
      if ARow > 0 then
      begin
        TWinControl(FButtons[AFocusedButtonIndex - 1]).SetFocus;
        Key := 0;
      end
  end;
  inherited DoEditKeyDown(Key, Shift);
end;

procedure TcxCustomButtonGroup.EnabledChanged;
begin
  inherited EnabledChanged;
  UpdateButtons;
end;

procedure TcxCustomButtonGroup.Initialize;
begin
  inherited Initialize;
  FButtons := TList.Create;
  AutoSize := False;
  TabStop := True;
end;

function TcxCustomButtonGroup.IsButtonDC(ADC: THandle): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to InternalButtons.Count - 1 do
    if GetButtonDC(I) = ADC then
    begin
      Result := True;
      Break;
    end;
end;

function TcxCustomButtonGroup.IsContainerClass: Boolean;
begin
  Result := FIsAccelCharHandling;
end;

function TcxCustomButtonGroup.RefreshContainer(const P: TPoint;
  Button: TcxMouseButton; Shift: TShiftState; AIsMouseEvent: Boolean): Boolean;
begin
  Result := inherited RefreshContainer(P, Button, Shift, AIsMouseEvent);
  ArrangeButtons;
end;

procedure TcxCustomButtonGroup.CreateHandle;
begin
  inherited CreateHandle;
  UpdateButtons;
  SynchronizeDisplayValue;
end;

procedure TcxCustomButtonGroup.ArrangeButtons;
var
  AButtonViewInfo: TcxGroupBoxButtonViewInfo;
  I: Integer;
  R: TRect;
begin
  for I := 0 to FButtons.Count - 1 do
    with TWinControl(FButtons[I]) do
    begin
      AButtonViewInfo := TcxGroupBoxButtonViewInfo(ViewInfo.ButtonsInfo[I]);
      R := AButtonViewInfo.Bounds;
      SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    end;
end;

function TcxCustomButtonGroup.GetButtonIndexAt(const P: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to ActiveProperties.Items.Count - 1 do
    if PtInRect(ViewInfo.ButtonsInfo[I].Bounds, P) then
    begin
      Result := I;
      Break;
    end;
end;

function TcxCustomButtonGroup.GetFocusedButtonIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to ActiveProperties.Items.Count - 1 do
    if TWinControl(FButtons[I]).Focused then
    begin
      Result := I;
      Break;
    end;
end;

procedure TcxCustomButtonGroup.InitButtonInstance(AButton: TWinControl);
begin
  TControlAccess(AButton).ParentShowHint := False;
  AButton.Parent := Self;

  TControlAccess(AButton).OnDragDrop := DoButtonDragDrop;
  TControlAccess(AButton).OnDragOver := DoButtonDragOver;
  TWinControlAccess(AButton).OnKeyDown := DoButtonKeyDown;
  TWinControlAccess(AButton).OnKeyPress := DoButtonKeyPress;
  TWinControlAccess(AButton).OnKeyUp := DoButtonKeyUp;
  TControlAccess(AButton).OnMouseDown := DoButtonMouseDown;
  TControlAccess(AButton).OnMouseMove := DoButtonMouseMove;
  TControlAccess(AButton).OnMouseUp := DoButtonMouseUp;
  {$IFDEF DELPHI6}
  TControlAccess(AButton).OnMouseWheel := DoButtonMouseWheel;
  {$ELSE}
  TWinControlAccess(AButton).OnMouseWheel := DoButtonMouseWheel;
  {$ENDIF}
end;

procedure TcxCustomButtonGroup.SetButtonCount(Value: Integer);
begin
  with ActiveProperties.Items do
    if ItemChanged then
    begin
      if ChangedItemOperation = copAdd then
        InitButtonInstance(GetButtonInstance)
      else
        if ChangedItemOperation = copDelete then
          TWinControl(FButtons[ChangedItemIndex]).Free;
    end
    else
      if Value <> FButtons.Count then
      begin
        DisableAlign;
        try
          if Value < FButtons.Count then
            while FButtons.Count > Value do
              TWinControl(FButtons.Last).Free
          else
            while FButtons.Count < Value do
              InitButtonInstance(GetButtonInstance);
        finally
          EnableAlign;
        end;
      end;
end;

function TcxCustomButtonGroup.IsNonClientAreaSupported: Boolean;
begin
  Result := False;
end;

procedure TcxCustomButtonGroup.SynchronizeButtonsStyle;
var
  AButton: TWinControlAccess;
  ATempFont: TFont;
  I: Integer;
begin
  ATempFont := TFont.Create;
  try
    for I := 0 to FButtons.Count - 1 do
    begin
      AButton := TWinControlAccess(FButtons[I]);
      AButton.Color := ActiveStyle.Color;
      ATempFont.Assign(Style.GetVisibleFont);
      ATempFont.Color := ActiveStyle.GetVisibleFont.Color;
      AssignFonts(AButton.Font, ATempFont);
    end;
  finally
    ATempFont.Free;
  end;
end;

procedure TcxCustomButtonGroup.UpdateButtons;
var
  AButton: TWinControl;
  I: Integer;
begin
  SetButtonCount(ActiveProperties.Items.Count);
  ShortRefreshContainer(False);
  for I := 0 to FButtons.Count - 1 do
  begin
    AButton := TWinControl(FButtons[I]);
    AButton.Enabled := Enabled and ActiveProperties.Items[I].Enabled;
  end;
  SynchronizeButtonsStyle;
  for I := 0 to FButtons.Count - 1 do
  begin
    AButton := TWinControl(FButtons[I]);
    AButton.Cursor := Cursor;
  end;
end;

procedure TcxCustomButtonGroup.DoButtonDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  with TWinControl(Sender) do
    Self.DragDrop(Source, Left + X, Top + Y);
end;

procedure TcxCustomButtonGroup.DoButtonDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  with TWinControl(Sender) do
    Self.DragOver(Source, Left + X, Top + Y, State, Accept);
end;

procedure TcxCustomButtonGroup.DoButtonKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  KeyDown(Key, Shift);
end;

procedure TcxCustomButtonGroup.DoButtonKeyPress(Sender: TObject; var Key: Char);
begin
  KeyPress(Key);
end;

procedure TcxCustomButtonGroup.DoButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  KeyUp(Key, Shift);
end;

procedure TcxCustomButtonGroup.DoButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  InnerControlMouseDown := True;
  try
    with TWinControl(Sender) do
      Self.MouseDown(Button, Shift, X + Left, Y + Top);
  finally
    InnerControlMouseDown := False;
  end;
end;

procedure TcxCustomButtonGroup.DoButtonMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  with TWinControl(Sender) do
    Self.MouseMove(Shift, X + Left, Y + Top);
end;

procedure TcxCustomButtonGroup.DoButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with TWinControl(Sender) do
    Self.MouseUp(Button, Shift, X + Left, Y + Top);
end;

procedure TcxCustomButtonGroup.DoButtonMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer;  MousePos: TPoint; var Handled: Boolean);
begin
  Handled := False;
end;

function TcxCustomButtonGroup.GetProperties: TcxCustomButtonGroupProperties;
begin
  Result := TcxCustomButtonGroupProperties(FProperties);
end;

function TcxCustomButtonGroup.GetActiveProperties: TcxCustomButtonGroupProperties;
begin
  Result := TcxCustomButtonGroupProperties(InternalGetActiveProperties);
end;

procedure TcxCustomButtonGroup.SetProperties(Value: TcxCustomButtonGroupProperties);
begin
  FProperties.Assign(Value);
end;

procedure TcxCustomButtonGroup.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  if not IsDestroying and IsTransparentBackground then
    RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_ALLCHILDREN);
end;

initialization
  WM_DXUPDATENONCLIENTAREA := RegisterWindowMessage('WM_DXUPDATENONCLIENTAREA');

end.
