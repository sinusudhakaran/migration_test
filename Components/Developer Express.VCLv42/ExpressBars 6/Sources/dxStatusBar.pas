
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressStatusBar                                             }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSSTATUSBAR AND ALL              }
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

unit dxStatusBar;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Graphics, ImgList, Forms,
  ExtCtrls, dxThemeManager, dxCore, cxClasses, cxGraphics, cxControls, cxLookAndFeels;

type
  TdxStatusBarPainterClass = class of TdxStatusBarPainter;
  TdxCustomStatusBar = class;
  TdxStatusBarPanel = class;
  TdxStatusBarPanels = class;
  TdxStatusBarPanelStyle = class;
  TdxStatusBarPanelClass = class of TdxStatusBarPanel;

  { TdxStatusBarPanelStyle }

  TdxStatusBarPanelStyle = class(TPersistent)
  private
    FAlignment: TAlignment;
    FColor: TColor;
    FFont: TFont;
    FIsColorAssigned: Boolean;
    FOwner: TdxStatusBarPanel;
    FParentFont: Boolean;
    procedure FontChanged(Sender: TObject);
    function GetColor: TColor;
    function GetStatusBarControl: TdxCustomStatusBar;
    function IsColorStored: Boolean;
    function IsFontStored: Boolean;
    procedure SetAlignment(Value: TAlignment);
    procedure SetColor(Value: TColor);
    procedure SetFont(Value: TFont);
    procedure SetParentFont(Value: Boolean);
  protected
    procedure AdjustTextColor(var AColor: TColor; Active: Boolean); virtual;
    function CanDelete: Boolean; virtual;
    function CanSizing: Boolean; virtual;
    procedure Changed; virtual;
    procedure CheckSizeGripRect(var R: TRect); virtual;
    function DefaultColor: TColor; virtual;
    procedure DoAssign(ASource: TPersistent); virtual;
    procedure DrawContent(ACanvas: TcxCanvas; R: TRect; APainter: TdxStatusBarPainterClass); virtual;
    function GetMinWidth: Integer; virtual;
    function GetPanelFixed: Boolean;
    class function GetVersion: Integer; virtual;
    function InternalBevel: Boolean; virtual;
    procedure Loaded; virtual;
    procedure PanelVisibleChanged; virtual;
    procedure ParentFontChanged; virtual;
  public
    constructor Create(AOwner: TdxStatusBarPanel); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure RestoreDefaults; virtual;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Color: TColor read GetColor write SetColor stored IsColorStored;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property Owner: TdxStatusBarPanel read FOwner;
    property ParentFont: Boolean read FParentFont write SetParentFont default True;
    property StatusBarControl: TdxCustomStatusBar read GetStatusBarControl;
  end;

  TdxStatusBarPanelStyleClass = class of TdxStatusBarPanelStyle;

  { TdxStatusBarTextPanelStyle }

  TdxStatusBarEllipsisType = (dxetNone, dxetTruncate, dxetSmartPath);
  TdxStatusBarEllipsisTypes = set of TdxStatusBarEllipsisType;

  TdxStatusBarTextEvent = procedure(Sender: TObject; const R: TRect; var AText: string) of object;

  TdxStatusBarTextPanelStyle = class(TdxStatusBarPanelStyle)
  private
    FAutoHint: Boolean;
    FEllipsisType: TdxStatusBarEllipsisType;
    FImageIndex: TImageIndex;
    FOnGetText: TdxStatusBarTextEvent;
    procedure SetAutoHint(Value: Boolean);
    procedure SetEllipsisType(Value: TdxStatusBarEllipsisType);
    procedure SetImageIndex(Value: TImageIndex);
  protected
    procedure DoAssign(ASource: TPersistent); override;
    procedure DrawContent(ACanvas: TcxCanvas; R: TRect; APainter: TdxStatusBarPainterClass); override;
  public
    constructor Create(AOwner: TdxStatusBarPanel); override;
    procedure RestoreDefaults; override;
  published
    property Alignment;
    property AutoHint: Boolean read FAutoHint write SetAutoHint default False;
    property Color;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property EllipsisType: TdxStatusBarEllipsisType read FEllipsisType write SetEllipsisType default dxetNone;
    property Font;
    property ParentFont;
    property OnGetText: TdxStatusBarTextEvent read FOnGetText write FOnGetText;
  end;

  { TdxStatusBarStateIndicatorPanelStyle }

  TdxStatusBarStateIndicatorType = (sitOff, sitYellow, sitBlue, sitGreen, sitRed,
    sitTeal, sitPurple);

  TdxStatusBarStateIndicatorItem = class(TCollectionItem)
  private
    FIndicatorBitmap: TBitmap;
    FIndicatorType: TdxStatusBarStateIndicatorType;
    FVisible: Boolean;
    procedure SetIndicatorType(Value: TdxStatusBarStateIndicatorType);
    procedure SetVisible(Value: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property IndicatorType: TdxStatusBarStateIndicatorType read FIndicatorType write SetIndicatorType default sitOff;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TdxStatusBarStateIndicators = class(TCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(Index: Integer): TdxStatusBarStateIndicatorItem;
    procedure SetItem(Index: Integer; Value: TdxStatusBarStateIndicatorItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create;
    function Add: TdxStatusBarStateIndicatorItem;
    function Insert(Index: Integer): TdxStatusBarStateIndicatorItem;
    property Items[Index: Integer]: TdxStatusBarStateIndicatorItem read GetItem write SetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TdxStatusBarStateIndicatorPanelStyle = class(TdxStatusBarPanelStyle)
  private
    FSpacing: Integer;
    FIndicators: TdxStatusBarStateIndicators;
    function GetIndicators: TdxStatusBarStateIndicators;
    procedure IndicatorChangeHandler(Sender: TObject);
    procedure SetIndicators(Value: TdxStatusBarStateIndicators);
    procedure SetSpacing(Value: Integer);
  protected
    function CanSizing: Boolean; override;
    procedure DoAssign(ASource: TPersistent); override;
    procedure DrawContent(ACanvas: TcxCanvas; R: TRect; APainter: TdxStatusBarPainterClass); override;
    function GetMinWidth: Integer; override;
  public
    constructor Create(AOwner: TdxStatusBarPanel); override;
    destructor Destroy; override;
    procedure RestoreDefaults; override;
  published
    property Color;
    property Indicators: TdxStatusBarStateIndicators read GetIndicators write SetIndicators;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
  end;

  { TdxStatusBarKeyboardStatePanelStyle }

  TdxStatusBarKeyboardStateWatchedKey = class
  private
    FKeyCode: Integer;
    FKeyState: Integer;
    procedure SetKeyState(Value: Integer);
  public
    constructor Create(AKeyCode: Integer);
    function GetCurrentState: Integer;
    property KeyCode: Integer read FKeyCode;
    property KeyState: Integer read FKeyState write SetKeyState;
  end;

  TdxStatusBarKeyboardStateNotifier = class
  private
    FKeys: array of TdxStatusBarKeyboardStateWatchedKey;
    FStatusBar: TdxCustomStatusBar;
    FTimer: TTimer;
  protected
    procedure Execute(Sender: TObject);
  public
    constructor Create(AStatusBar: TdxCustomStatusBar);
    destructor Destroy; override;
    procedure SubScribeKey(AKeyCode: Integer);
    procedure UnSubScribeKey(AKeyCode: Integer);
  end;

  TdxStatusBarKeyboardState = (dxksCapsLock, dxksNumLock, dxksScrollLock, dxksInsert);
  TdxStatusBarKeyboardStates = set of TdxStatusBarKeyboardState;

  TdxStatusBarKeyStateAppearance = class(TPersistent)
  private
    FId: TdxStatusBarKeyboardState;
    FCode: Integer;
    FActiveFontColor: TColor;
    FInactiveFontColor: TColor;
    FActiveCaption: string;
    FInactiveCaption: string;
    FOnChange: TNotifyEvent;
    procedure SetActiveFontColor(Value: TColor);
    procedure SetInactiveFontColor(Value: TColor);
    procedure SetActiveCaption(const Value: string);
    procedure SetInactiveCaption(const Value: string);
  protected
    procedure Changed; virtual;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(AId: TdxStatusBarKeyboardState; ACode: Integer;
      const AActiveCaption: string; AActiveFontColor: TColor;
      const AInactiveCaption: string; AInactiveFontColor: TColor;
      AChangeHandler: TNotifyEvent);
    procedure Assign(Source: TPersistent); override;
    function GetRectWidth(ACanvas: TcxCanvas): Integer;
    property Code: Integer read FCode;
    property Id: TdxStatusBarKeyboardState read FId;
  published
    property ActiveFontColor: TColor read FActiveFontColor write SetActiveFontColor default clWindowText;
    property InactiveFontColor: TColor read FInactiveFontColor write SetInactiveFontColor default clBtnShadow;
    property ActiveCaption: string read FActiveCaption write SetActiveCaption;
    property InactiveCaption: string read FInactiveCaption write SetInactiveCaption;
  end;

  TdxStatusBarKeyboardStatePanelStyle = class(TdxStatusBarPanelStyle)
  private
    FFullRect: Boolean;
    FKeyboardStates: TdxStatusBarKeyboardStates;
    FKeyInfos: array[0..3] of TdxStatusBarKeyStateAppearance;
    FNotifier: TdxStatusBarKeyboardStateNotifier;
    function GetCapsLockAppearance: TdxStatusBarKeyStateAppearance;
    function GetInsertAppearance: TdxStatusBarKeyStateAppearance;
    function GetNumLockAppearance: TdxStatusBarKeyStateAppearance;
    function GetScrollLockAppearance: TdxStatusBarKeyStateAppearance;
    procedure NamesChangeHandler(Sender: TObject);
    procedure SetCapsLockAppearance(Value: TdxStatusBarKeyStateAppearance);
    procedure SetFullRect(Value: Boolean);
    procedure SetInsertAppearance(Value: TdxStatusBarKeyStateAppearance);
    procedure SetKeyboardStates(Value: TdxStatusBarKeyboardStates);
    procedure SetNumLockAppearance(Value: TdxStatusBarKeyStateAppearance);
    procedure SetScrollLockAppearance(Value: TdxStatusBarKeyStateAppearance);
  protected
    function CanSizing: Boolean; override;
    procedure DoAssign(ASource: TPersistent); override;
    procedure DrawContent(ACanvas: TcxCanvas; R: TRect; APainter: TdxStatusBarPainterClass); override;
    function GetMinWidth: Integer; override;
    function InternalBevel: Boolean; override;
  public
    constructor Create(AOwner: TdxStatusBarPanel); override;
    destructor Destroy; override;
    procedure RestoreDefaults; override;
  published
    property Color;
    property Font;
    property KeyboardStates: TdxStatusBarKeyboardStates read FKeyboardStates write SetKeyboardStates
      default [dxksCapsLock, dxksNumLock, dxksScrollLock, dxksInsert];
    property FullRect: Boolean read FFullRect write SetFullRect default False;
    property CapsLockKeyAppearance: TdxStatusBarKeyStateAppearance read GetCapsLockAppearance write SetCapsLockAppearance;
    property NumLockKeyAppearance: TdxStatusBarKeyStateAppearance read GetNumLockAppearance write SetNumLockAppearance;
    property ScrollLockKeyAppearance: TdxStatusBarKeyStateAppearance read GetScrollLockAppearance write SetScrollLockAppearance;
    property InsertKeyAppearance: TdxStatusBarKeyStateAppearance read GetInsertAppearance write SetInsertAppearance;
    property ParentFont;
  end;

  { TdxStatusBarContainerPanelStyle }

  TdxStatusBarContainerPanelStyle = class;

  TdxStatusBarContainerControl = class(TcxControl)
  private
    FPanelStyle: TdxStatusBarContainerPanelStyle;
  protected
    procedure Paint; override;
    function MayFocus: Boolean; override;
    function NeedsScrollBars: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  TdxStatusBarContainerPanelStyle = class(TdxStatusBarPanelStyle)
  private
    FAlignControl: Boolean;
    FContainer: TdxStatusBarContainerControl;
    procedure SetContainer(Value: TdxStatusBarContainerControl);
  protected
    function CanDelete: Boolean; override;
    procedure DoAssign(ASource: TPersistent); override;
    procedure DrawContainerControl;
    procedure DrawContent(ACanvas: TcxCanvas; R: TRect; APainter: TdxStatusBarPainterClass); override;
    procedure PanelVisibleChanged; override;
  public
    constructor Create(AOwner: TdxStatusBarPanel); override;
    destructor Destroy; override;
    procedure RestoreDefaults; override;
  published
    property AlignControl: Boolean read FAlignControl write FAlignControl default True;
    property Container: TdxStatusBarContainerControl read FContainer write SetContainer;
  end;

  { TdxStatusBarPanel }

  TdxStatusBarPanelBevel = (dxpbNone, dxpbLowered, dxpbRaised);
  TdxStatusBarDrawPanelEvent = procedure(Sender: TdxStatusBarPanel; ACanvas: TcxCanvas;
    const ARect: TRect; var ADone: Boolean) of object;

  TdxStatusBarPanel = class(TCollectionItem)
  private
    FBevel: TdxStatusBarPanelBevel;
    FBiDiMode: TBiDiMode;
    FFixed: Boolean;
    FIsMinWidthAssigned: Boolean;
    FIsWidthAssigned: Boolean;
    FMinWidth: Integer;
    FPanelStyle: TdxStatusBarPanelStyle;
    FPanelStyleClass: TdxStatusBarPanelStyleClass;
    FPanelStyleEvents: TNotifyEvent;
    FParentBiDiMode: Boolean;
    FText: string;
    FVisible: Boolean;
    FWidth: Integer;
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnDrawPanel: TdxStatusBarDrawPanelEvent;

    function GetFixed: Boolean;
    function GetLookAndFeel: TcxLookAndFeel;
    function GetMinWidth: Integer;
    function GetPanelStyleClassName: string;
    function GetStatusBarControl: TdxCustomStatusBar;
    function GetWidth: Integer;
    function IsBiDiModeStored: Boolean;
    function IsMinWidthStored: Boolean;
    function IsWidthStored: Boolean;
    procedure SetBevel(Value: TdxStatusBarPanelBevel);
    procedure SetBiDiMode(Value: TBiDiMode);
    procedure SetFixed(Value: Boolean);
    procedure SetMinWidth(Value: Integer);
    procedure SetPanelStyle(Value: TdxStatusBarPanelStyle);
    procedure SetPanelStyleClass(const Value: TdxStatusBarPanelStyleClass);
    procedure SetPanelStyleClassName(Value: string);
    procedure SetParentBiDiMode(Value: Boolean);
    procedure SetText(const Value: string);
    procedure SetVisible(Value: Boolean);
    procedure SetWidth(Value: Integer);
  protected
    procedure Click; virtual;
    procedure CreatePanelStyle; virtual;
    procedure DblClick; virtual;
    function DefaultMinWidth: Integer; virtual;
    function DefaultWidth: Integer; virtual;
    procedure DestroyPanelStyle; virtual;
    function GetDisplayName: string; override;
    procedure Loaded;
    function PaintMinWidth: Integer; virtual;
    function PaintWidth: Integer; virtual;
    procedure PreparePaintWidth(var AWidth: Integer); virtual;
    procedure StatusBarPanelStyleChanged; virtual;
    property LookAndFeel: TcxLookAndFeel read GetLookAndFeel;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure RestoreDefaults; virtual;

    procedure ParentBiDiModeChanged;
    function UseRightToLeftAlignment: Boolean;
    function UseRightToLeftReading: Boolean;

    property PanelStyleClass: TdxStatusBarPanelStyleClass read FPanelStyleClass write SetPanelStyleClass;
    property StatusBarControl: TdxCustomStatusBar read GetStatusBarControl;
  published
    property PanelStyleClassName: string read GetPanelStyleClassName write SetPanelStyleClassName;
    property PanelStyle: TdxStatusBarPanelStyle read FPanelStyle write SetPanelStyle;
    property PanelStyleEvents: TNotifyEvent read FPanelStyleEvents write FPanelStyleEvents;

    property Bevel: TdxStatusBarPanelBevel read FBevel write SetBevel default dxpbLowered;
    property BiDiMode: TBiDiMode read FBiDiMode write SetBiDiMode stored IsBiDiModeStored;
    property Fixed: Boolean read GetFixed write SetFixed default True;
    property MinWidth: Integer read GetMinWidth write SetMinWidth stored IsMinWidthStored;
    property ParentBiDiMode: Boolean read FParentBiDiMode write SetParentBiDiMode default True;
    property Text: string read FText write SetText;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: Integer read GetWidth write SetWidth stored IsWidthStored;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnDrawPanel: TdxStatusBarDrawPanelEvent read FOnDrawPanel write FOnDrawPanel;
  end;

  { TdxStatusBarPanels }
  
  TdxStatusBarPanels = class(TCollection)
  private
    FStatusBarControl: TdxCustomStatusBar;
    function GetItem(Index: Integer): TdxStatusBarPanel;
    procedure SetItem(Index: Integer; Value: TdxStatusBarPanel);
  protected
    function GetOwner: TPersistent; override;
    procedure Loaded;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AStatusBarControl: TdxCustomStatusBar);
    function Add: TdxStatusBarPanel;
    function Insert(Index: Integer): TdxStatusBarPanel;
    property Items[Index: Integer]: TdxStatusBarPanel read GetItem write SetItem; default;
  end;

  { Painters }

  TdxStatusBarPaintStyle = (stpsStandard, stpsFlat, stpsXP, stpsOffice11, stpsUseLookAndFeel);

  TdxStatusBarPainter = class
  protected
    class procedure DrawContainerControl(APanelStyle: TdxStatusBarContainerPanelStyle); virtual;
    class function IsSizeGripInPanel(AStatusBar: TdxCustomStatusBar): Boolean; virtual;
  public
    // calc
    class procedure AdjustTextColor(AStatusBar: TdxCustomStatusBar; var AColor: TColor;
      Active: Boolean); virtual;
    class function BorderSizes(AStatusBar: TdxCustomStatusBar): TRect; virtual;
    class function DrawSizeGripFirst: Boolean; virtual;
    class function GripAreaSize: TSize; virtual;
    class function GripSize: TSize; virtual;
    class function IsNativeBackground: Boolean; virtual;
    class function SeparatorSize: Integer; virtual;
    class function SeparatorSizeEx(AStatusBar: TdxCustomStatusBar): Integer; virtual;
    class function TopBorderSize: Integer; virtual;
    // draw
    class procedure DrawBorder(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      var R: TRect); virtual;
    class procedure DrawEmptyPanel(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      R: TRect); virtual;
    class procedure DrawPanel(AStatusBar: TdxCustomStatusBar; APanel: TdxStatusBarPanel;
      ACanvas: TcxCanvas; R: TRect); virtual;
    class procedure DrawPanelBorder(AStatusBar: TdxCustomStatusBar; ABevel: TdxStatusBarPanelBevel;
      ACanvas: TcxCanvas; var R: TRect); virtual;
    class procedure DrawPanelSeparator(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      const R: TRect); virtual;
    class procedure DrawSizeGrip(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      R: TRect; AOverlapped: Boolean); virtual;
    class procedure DrawTopBorder(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      const R: TRect); virtual;
    class procedure FillBackground(AStatusBar: TdxCustomStatusBar; APanel: TdxStatusBarPanel;
      ACanvas: TcxCanvas; const R: TRect); virtual;
    class function GetPanelBevel(APanel: TdxStatusBarPanel): TdxStatusBarPanelBevel; virtual;
    class function GetPanelColor(AStatusBar: TdxCustomStatusBar; APanel: TdxStatusBarPanel): TColor; virtual;
    class function ValidatePanelTextRect(AStatusBar: TdxCustomStatusBar;
      APanel: TdxStatusBarPanel; const R: TRect): TRect; virtual;
  end;

  TdxStatusBarStandardPainter = class(TdxStatusBarPainter)
  public
    class procedure DrawPanelBorder(AStatusBar: TdxCustomStatusBar; ABevel: TdxStatusBarPanelBevel;
      ACanvas: TcxCanvas; var R: TRect); override;
    class procedure DrawPanelSeparator(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      const R: TRect); override;
    class procedure FillBackground(AStatusBar: TdxCustomStatusBar; APanel: TdxStatusBarPanel;
      ACanvas: TcxCanvas; const R: TRect); override;
  end;

  TdxStatusBarFlatPainter = class(TdxStatusBarStandardPainter)
  public
    class procedure DrawPanelBorder(AStatusBar: TdxCustomStatusBar; ABevel: TdxStatusBarPanelBevel;
      ACanvas: TcxCanvas; var R: TRect); override;
  end;

  TdxStatusBarOffice11Painter = class(TdxStatusBarPainter)
  public
    // calc
    class function BorderSizes(AStatusBar: TdxCustomStatusBar): TRect; override;
    // draw
    class procedure DrawBorder(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      var R: TRect); override;
    class procedure DrawPanelBorder(AStatusBar: TdxCustomStatusBar; ABevel: TdxStatusBarPanelBevel;
      ACanvas: TcxCanvas; var R: TRect); override;
    class procedure DrawPanelSeparator(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      const R: TRect); override;
    class procedure DrawSizeGrip(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      R: TRect; AOverlapped: Boolean); override;
  end;

  TdxStatusBarXPPainter = class(TdxStatusBarPainter)
  public
    // calc
    class function BorderSizes(AStatusBar: TdxCustomStatusBar): TRect; override;
    class function GripAreaSize: TSize; override;
    class function SeparatorSize: Integer; override;
    // draw
    class procedure DrawBorder(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      var R: TRect); override;
    class procedure DrawPanelSeparator(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      const R: TRect); override;
    class procedure DrawSizeGrip(AStatusBar: TdxCustomStatusBar; ACanvas: TcxCanvas;
      R: TRect; AOverlapped: Boolean); override;
  end;

  { TdxStatusBarViewInfo }

  TdxStatusBarViewInfo = class
  private
    FPanels: TList;
    FWidths: TList;
    FSizeGripOvelapped: Boolean;
    FStatusBar: TdxCustomStatusBar;
    function GetWidth(Index: Integer): Integer;
    function GetPanel(Index: Integer): TdxStatusBarPanel;
    function GetPanelCount: Integer;
  protected
    procedure AddCalculatedItems(AAutoWidthObject: TcxAutoWidthObject);
    function GetCalculatedItemCount: Integer;
    function GetPanelAt(const APanelsBounds: TRect; X, Y: Integer): TdxStatusBarPanel;
    procedure UpdatePanels;
  public
    constructor Create(AOwner: TdxCustomStatusBar); virtual;
    destructor Destroy; override;
    procedure Calculate(const ABounds: TRect); virtual;

    property PanelCount: Integer read GetPanelCount;
    property Panels[Index: Integer]: TdxStatusBarPanel read GetPanel;
    property Widths[Index: Integer]: Integer read GetWidth; default;
    property SizeGripOvelapped: Boolean read FSizeGripOvelapped;
    property StatusBar: TdxCustomStatusBar read FStatusBar;
  end;

  { TdxCustomStatusBar }

  TdxStatusBarPanelCreateClassEvent = procedure(Sender: TdxCustomStatusBar;
    var AStatusPanelClass: TdxStatusBarPanelClass) of object;

  TdxCustomStatusBar = class(TcxControl, IdxSkinSupport)
  private
    FBorderWidth: Integer;
    FImages: TCustomImageList;
    FImageChangeLink: TChangeLink;
    FLookAndFeel: TcxLookAndFeel;
    FPainter: TdxStatusBarPainterClass;
    FPaintStyle: TdxStatusBarPaintStyle;
    FPanels: TdxStatusBarPanels;
    FSizeGrip: Boolean;
    FThemeAvailable: Boolean;
    FThemeChangedNotificator: TdxThemeChangedNotificator;
    FViewInfo: TdxStatusBarViewInfo;
    FOnHint: TNotifyEvent;

    function GetPanelsBounds: TRect;
    procedure ImageListChange(Sender: TObject);
    procedure LookAndFeelChangeHandler(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
    procedure SetBorderWidth(Value: Integer);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetLookAndFeel(Value: TcxLookAndFeel);
    procedure SetPanels(Value: TdxStatusBarPanels);
    procedure SetPaintStyle(Value: TdxStatusBarPaintStyle);
    procedure SetSizeGrip(Value: Boolean);
    procedure CMBiDiModeChanged(var Message: TMessage); message CM_BIDIMODECHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentFontChanged(var Message: TMessage); message CM_PARENTFONTCHANGED;
    procedure CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMWinIniChange(var Message: TMessage); message CM_WININICHANGE;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    procedure AdjustTextColor(var AColor: TColor; Active: Boolean); virtual;
    function CreateViewInfo: TdxStatusBarViewInfo; virtual;
    procedure FontChanged; override;
    function HasBackground: Boolean; override;
    procedure Loaded; override;
    function MayFocus: Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function NeedsScrollBars: Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure Resize; override;

    procedure Calculate; virtual;
    function ContainerByName(const AName: string): TdxStatusBarContainerControl;
    function CreatePanel: TdxStatusBarPanel; virtual;
    function CreatePanels: TdxStatusBarPanels; virtual;
    function DoHint: Boolean; virtual;
    class function GetDeafultPanelStyleClass: TdxStatusBarPanelStyleClass; virtual;
    function GetPainterClass: TdxStatusBarPainterClass; virtual;
    function GetPaintStyle: TdxStatusBarPaintStyle; virtual;
    class function GetStatusPanelClass: TdxStatusBarPanelClass; virtual;
    procedure InitPainterClass; virtual;
    procedure PaintStyleChanged; virtual;
    procedure Recalculate; 
    function SizeGripAllocated: Boolean; virtual;
    procedure ThemeChanged; virtual;
    procedure UpdatePanels; virtual;

    property Panels: TdxStatusBarPanels read FPanels write SetPanels;
    property SizeGrip: Boolean read FSizeGrip write SetSizeGrip default True;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel write SetLookAndFeel;
    property Painter: TdxStatusBarPainterClass read FPainter;
    property PaintStyle: TdxStatusBarPaintStyle read FPaintStyle write SetPaintStyle default stpsStandard;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 0;
    property ViewInfo: TdxStatusBarViewInfo read FViewInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  {$IFNDEF DELPHI10}
    function ClientToParent(const Point: TPoint; AParent: TWinControl = nil): TPoint;
  {$ENDIF}
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function CanAcceptPanelStyle(Value: TdxStatusBarPanelStyleClass): Boolean; virtual;
    function GetPanelAt(X, Y: Integer): TdxStatusBarPanel; virtual;
    property OnHint: TNotifyEvent read FOnHint write FOnHint;
  published
    property Images: TCustomImageList read FImages write SetImages;
  end;

  { TdxStatusBar }

  TdxStatusBar = class(TdxCustomStatusBar)
  published
    property Images;
    property Panels;
    property PaintStyle;
    property SizeGrip;
    property LookAndFeel;
    property OnHint;
    property BorderWidth;
    { TcxControl properties}
    property Anchors;
    property BiDiMode;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property Color default clBtnFace;
    property Constraints;
    property ShowHint;
    property ParentBiDiMode;
    property ParentFont default False;
    property ParentShowHint;
    property PopupMenu;
    property Visible;
{$IFDEF DELPHI5}
    property OnContextPopup;
{$ENDIF}
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
  end;

var
  dxStatusBarSkinPainterClass: TdxStatusBarPainterClass = nil;  

function GetRegisteredStatusBarPanelStyles: TcxRegisteredClasses;
procedure LoadIndicatorBitmap(ABitmap: TBitmap; AIndicatorType: TdxStatusBarStateIndicatorType);

implementation

{$R dxStatusBar.res}

uses
  dxThemeConsts, dxUxTheme, dxOffice11, ActnList, StdActns;

const
  GRIP_AREA_SIZE = 16;
  GRIP_SIZE = 12;
  PANELSEPARATORWIDTH = 2;

resourcestring  
  cxSTextPanelStyle = 'Text Panel';
  cxSContainerPanelStyle = 'Container Panel';
  cxSKeyboardStatePanelStyle = 'Keyboard State Panel';
  cxSStateIndicatorPanelStyle = 'State Indicator Panel';
  // design-time
  cxSCantDeleteAncestor = 'Selection contains a component introduced in an ancestor form which cannot be deleted';

var
  FRegisteredStatusBarPanelStyles: TcxRegisteredClasses;

function GetRegisteredStatusBarPanelStyles: TcxRegisteredClasses;
begin
  if FRegisteredStatusBarPanelStyles = nil then
    FRegisteredStatusBarPanelStyles := TcxRegisteredClasses.Create;
  Result := FRegisteredStatusBarPanelStyles;
end;

procedure LoadIndicatorBitmap(ABitmap: TBitmap; AIndicatorType: TdxStatusBarStateIndicatorType);
begin
  case AIndicatorType of
    sitOff: ABitmap.LoadFromResourceName(HInstance, 'DXSTATUSBAR_GRAY');
    sitYellow: ABitmap.LoadFromResourceName(HInstance, 'DXSTATUSBAR_YELLOW');
    sitBlue: ABitmap.LoadFromResourceName(HInstance, 'DXSTATUSBAR_BLUE');
    sitGreen: ABitmap.LoadFromResourceName(HInstance, 'DXSTATUSBAR_GREEN');
    sitRed: ABitmap.LoadFromResourceName(HInstance, 'DXSTATUSBAR_RED');
    sitTeal: ABitmap.LoadFromResourceName(HInstance, 'DXSTATUSBAR_TEAL');
    sitPurple: ABitmap.LoadFromResourceName(HInstance, 'DXSTATUSBAR_PURPLE');
  end;
end;

procedure DrawSizeGrip(DC: HDC; R: TRect); // dxBar
const
  ROP_DSPDxax = $00E20746;
var
  APrevBitmap, ATempBitmap, AMaskBitmap: HBITMAP;
  TempDC, MDC, MaskDC: HDC;
  W, H: Integer;
  APrevBkColor: COLORREF;
begin
  W := R.Right - R.Left;
  H := R.Bottom - R.Top;
  TempDC := CreateCompatibleDC(DC);
  ATempBitmap := SelectObject(TempDC, CreateCompatibleBitmap(DC, W, H));
  try
    BitBlt(TempDC, 0, 0, W, H, DC, R.Left, R.Top, SRCCOPY); // 1
    MDC := CreateCompatibleDC(DC);
    APrevBitmap := SelectObject(MDC, CreateCompatibleBitmap(DC, W, H));
    DrawFrameControl(MDC, Rect(0, 0, W, H), DFC_SCROLL, DFCS_SCROLLSIZEGRIP); // 2

    MaskDC := CreateCompatibleDC(DC);
    AMaskBitmap := SelectObject(MaskDC, CreateBitmap(W, H, 1, 1, nil));
    try
      APrevBkColor := SetBkColor(MDC, ColorToRGB(clBtnFace)); //!
      BitBlt(MaskDC, 0, 0, W, H, MDC, 0, 0, SRCCOPY);
      SetBkColor(MDC, APrevBkColor);

      BitBlt(TempDC, 0, 0, W, H, MaskDC, 0, 0, MERGEPAINT);
      BitBlt(MDC, 0, 0, W, H, MaskDC, 0, 0, SRCPAINT);
      BitBlt(TempDC, 0, 0, W, H, MDC, 0, 0, SRCAND);
    finally
      DeleteObject(SelectObject(MaskDC, AMaskBitmap));
      DeleteDC(MaskDC);
    end;

    DeleteObject(SelectObject(MDC, APrevBitmap));
    DeleteDC(MDC);

    BitBlt(DC, R.Left, R.Top, W, H, TempDC, 0, 0, SRCCOPY);
  finally
    DeleteObject(SelectObject(TempDC, ATempBitmap));
    DeleteDC(TempDC);
  end;
end;

procedure GenContainerName(APanel: TdxStatusBarPanel; AContainer: TdxStatusBarContainerControl);
var
  I: Integer;
begin
  I := APanel.ID;
  while I <> -1 do
    try
      AContainer.Name := APanel.StatusBarControl.Name + 'Container' + IntTostr(I);
      I := -1;
    except
      on EComponentError do //Ignore rename errors
        Inc(I);
    end;
end;

{ TdxStatusBarPanelStyle }

constructor TdxStatusBarPanelStyle.Create(AOwner: TdxStatusBarPanel);
begin
  inherited Create;
  FOwner := AOwner;
  FFont := TFont.Create;
  FFont.OnChange := FontChanged;
  ParentFont := True;
end;

destructor TdxStatusBarPanelStyle.Destroy;
begin
  FOwner := nil;
  FreeAndNil(FFont);
  inherited;
end;

procedure TdxStatusBarPanelStyle.Assign(Source: TPersistent);
begin
  if Source is TdxStatusBarPanelStyle then
  begin
    BeginUpdate;
    try
      DoAssign(Source);
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TdxStatusBarPanelStyle.BeginUpdate;                      
begin
  if Assigned(Owner) and Assigned(Owner.Collection) then
    Owner.Collection.BeginUpdate;
end;

procedure TdxStatusBarPanelStyle.EndUpdate;
begin
  if Assigned(Owner) and Assigned(Owner.Collection) then
    Owner.Collection.EndUpdate;
end;

procedure TdxStatusBarPanelStyle.RestoreDefaults;
begin
  FAlignment := taLeftJustify;
  FIsColorAssigned := False;
  ParentFont := True;
  Owner.Changed(False);
end;

procedure TdxStatusBarPanelStyle.AdjustTextColor(var AColor: TColor;
  Active: Boolean);
begin
  if AColor = clDefault then
    StatusBarControl.AdjustTextColor(AColor, Active);
end;

function TdxStatusBarPanelStyle.CanDelete: Boolean;
begin
  Result := True;
end;

function TdxStatusBarPanelStyle.CanSizing: Boolean;
begin
  Result := True;
end;

procedure TdxStatusBarPanelStyle.Changed;
begin
  if Assigned(FOwner) then
    FOwner.StatusBarPanelStyleChanged;
end;

procedure TdxStatusBarPanelStyle.CheckSizeGripRect(var R: TRect);
begin
  if (Owner.Index = (StatusBarControl.Panels.Count - 1)) and StatusBarControl.SizeGripAllocated then
    Dec(R.Right, StatusBarControl.Painter.GripAreaSize.cx);
end;

function TdxStatusBarPanelStyle.DefaultColor: TColor;
begin
  Result := StatusBarControl.Color;
end;

procedure TdxStatusBarPanelStyle.DoAssign(ASource: TPersistent);
var
  AStyle: TdxStatusBarPanelStyle;
begin
  AStyle := TdxStatusBarPanelStyle(ASource);
  RestoreDefaults;
  Alignment := AStyle.Alignment;
  if AStyle.IsColorStored then
    Color := AStyle.Color;
  if AStyle.IsFontStored then
    Font.Assign(AStyle.Font)
  else
    ParentFontChanged;
end;

procedure TdxStatusBarPanelStyle.DrawContent(ACanvas: TcxCanvas; R: TRect;
  APainter: TdxStatusBarPainterClass);
begin
  APainter.FillBackground(Self.StatusBarControl, Owner, ACanvas, R);
end;

function TdxStatusBarPanelStyle.GetMinWidth: Integer;
begin
  Result := 20;
end;

function TdxStatusBarPanelStyle.GetPanelFixed: Boolean;
begin
  Result := Owner.FFixed;
end;

class function TdxStatusBarPanelStyle.GetVersion: Integer;
begin
  Result := 0;
end;

function TdxStatusBarPanelStyle.InternalBevel: Boolean;
begin
  Result := False;
end;

procedure TdxStatusBarPanelStyle.Loaded;
begin
end;

procedure TdxStatusBarPanelStyle.PanelVisibleChanged;
begin
end;

procedure TdxStatusBarPanelStyle.ParentFontChanged;
begin
  if ParentFont then
  begin
    Font.Assign(StatusBarControl.Font);
    FParentFont := True;
  end;
end;

procedure TdxStatusBarPanelStyle.FontChanged(Sender: TObject);
begin
  FParentFont := False;
  Owner.Changed(False);
end;

function TdxStatusBarPanelStyle.GetColor: TColor;
begin
  if FIsColorAssigned then
    Result := FColor
  else
    Result := DefaultColor;
end;

function TdxStatusBarPanelStyle.GetStatusBarControl: TdxCustomStatusBar;
begin
  Result := TdxStatusBarPanels(Owner.Collection).FStatusBarControl;
end;

function TdxStatusBarPanelStyle.IsColorStored: Boolean;
begin
  Result := FIsColorAssigned;
end;

function TdxStatusBarPanelStyle.IsFontStored: Boolean;
begin
  Result := not ParentFont;
end;

procedure TdxStatusBarPanelStyle.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    Owner.Changed(False);
  end;
end;

procedure TdxStatusBarPanelStyle.SetColor(Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    FIsColorAssigned := True;
    Owner.Changed(False);
  end;
end;

procedure TdxStatusBarPanelStyle.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TdxStatusBarPanelStyle.SetParentFont(Value: Boolean);
begin
  if FParentFont <> Value then
  begin
    FParentFont := Value;
    ParentFontChanged;
  end;
end;

{ TdxStatusBarTextPanelStyle }

constructor TdxStatusBarTextPanelStyle.Create(AOwner: TdxStatusBarPanel);
begin
  inherited Create(AOwner);
  FImageIndex := -1;
end;

procedure TdxStatusBarTextPanelStyle.RestoreDefaults;
begin
  FAutoHint := False;
  FImageIndex := -1;
  FEllipsisType := dxetNone;
  inherited RestoreDefaults;
end;

procedure TdxStatusBarTextPanelStyle.DoAssign(ASource: TPersistent);
var
  AStyle: TdxStatusBarTextPanelStyle;
begin
  inherited;
  if ASource is TdxStatusBarTextPanelStyle then
  begin
    AStyle := TdxStatusBarTextPanelStyle(ASource);
    AutoHint := AStyle.AutoHint;
    ImageIndex := AStyle.ImageIndex;
    EllipsisType := AStyle.EllipsisType;
  end;
end;

procedure TdxStatusBarTextPanelStyle.DrawContent(ACanvas: TcxCanvas;
  R: TRect; APainter: TdxStatusBarPainterClass);
const
  AShowEndEllipsis: array[TdxStatusBarEllipsisType] of Integer = (0, cxShowEndEllipsis,
    cxShowPathEllipsis);
var
  ALeft, ATop: Integer;
  ATextColor: TColor;
  S: string;
begin
  inherited;
  if Assigned(StatusBarControl.Images) and
    (0 <= ImageIndex) and (ImageIndex < StatusBarControl.Images.Count) then
  begin
    ALeft := R.Left + 1;
    ATop := ((R.Top + R.Bottom) div 2) - (StatusBarControl.Images.Height div 2);
    R.Left := ALeft + StatusBarControl.Images.Width + 1;
    StatusBarControl.Images.Draw(ACanvas.Canvas, ALeft, ATop,
      ImageIndex, StatusBarControl.Enabled);
  end;
  ACanvas.Brush.Style := bsClear;
  ATextColor := Font.Color;
  APainter.AdjustTextColor(Owner.GetStatusBarControl, ATextColor, True);  
  AdjustTextColor(ATextColor, True);
  ACanvas.Font.Assign(Font);
  ACanvas.Font.Color := ATextColor;
  InflateRect(R, -2, 0);
  S := Owner.Text;
  R := APainter.ValidatePanelTextRect(StatusBarControl, Owner, R);
  if Assigned(FOnGetText) then
    FOnGetText(Self, R, S);
  ACanvas.DrawText(S, R, cxSingleLine or cxAlignVCenter or cxAlignmentsHorz[Alignment] or
    AShowEndEllipsis[EllipsisType], StatusBarControl.Enabled);
  ACanvas.Brush.Style := bsSolid;
end;

procedure TdxStatusBarTextPanelStyle.SetAutoHint(Value: Boolean);
var
  I: Integer;
begin
  if FAutoHint <> Value then
  begin
    for I := 0 to StatusBarControl.Panels.Count - 1 do
      if StatusBarControl.Panels[I].PanelStyle is TdxStatusBarTextPanelStyle then
        TdxStatusBarTextPanelStyle(StatusBarControl.Panels[I].PanelStyle).FAutoHint := False;
    FAutoHint := Value;
  end;
end;

procedure TdxStatusBarTextPanelStyle.SetEllipsisType(Value: TdxStatusBarEllipsisType);
begin
  if FEllipsisType <> Value then
  begin
    FEllipsisType := Value;
    Owner.Changed(False);
  end;
end;

procedure TdxStatusBarTextPanelStyle.SetImageIndex(Value: TImageIndex);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    Owner.Changed(False);
  end;
end;

{ TdxStatusBarStateIndicatorItem }

constructor TdxStatusBarStateIndicatorItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FVisible := True;
  FIndicatorBitmap := TBitmap.Create;
  FIndicatorBitmap.LoadFromResourceName(HInstance, 'DXSTATUSBAR_GRAY');
end;

destructor TdxStatusBarStateIndicatorItem.Destroy;
begin
  FreeAndNil(FIndicatorBitmap);
  inherited Destroy;
end;

procedure TdxStatusBarStateIndicatorItem.Assign(Source: TPersistent);
begin
  if Source is TdxStatusBarStateIndicatorItem then
  begin
    IndicatorType := TdxStatusBarStateIndicatorItem(Source).IndicatorType;
    Visible := TdxStatusBarStateIndicatorItem(Source).Visible;
  end
  else
    inherited Assign(Source);
end;

procedure TdxStatusBarStateIndicatorItem.SetIndicatorType(Value: TdxStatusBarStateIndicatorType);
begin
  if FIndicatorType <> Value then
  begin
    FIndicatorType := Value;
    LoadIndicatorBitmap(FIndicatorBitmap, FIndicatorType);
    Changed(False);
  end;
end;

procedure TdxStatusBarStateIndicatorItem.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Changed(False);
  end;
end;

{ TdxStatusBarStateIndicators }

constructor TdxStatusBarStateIndicators.Create;
begin
  inherited Create(TdxStatusBarStateIndicatorItem);
end;

function TdxStatusBarStateIndicators.Add: TdxStatusBarStateIndicatorItem;
begin
  Result := TdxStatusBarStateIndicatorItem.Create(Self);
end;

function TdxStatusBarStateIndicators.Insert(Index: Integer): TdxStatusBarStateIndicatorItem;
begin
  BeginUpdate;
  try
    if Index < 0 then Index := 0;
    if Index > Count then Index := Count;
    Result := Add;
    Result.Index := Index;
  finally
    EndUpdate;
  end;
end;

procedure TdxStatusBarStateIndicators.Update(Item: TCollectionItem);
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

function TdxStatusBarStateIndicators.GetItem(Index: Integer): TdxStatusBarStateIndicatorItem;
begin
  Result := TdxStatusBarStateIndicatorItem(inherited GetItem(Index));
end;

procedure TdxStatusBarStateIndicators.SetItem(Index: Integer; Value: TdxStatusBarStateIndicatorItem);
begin
  inherited SetItem(Index, Value);
end;

{ TdxStatusBarStateIndicatorPanelStyle }

constructor TdxStatusBarStateIndicatorPanelStyle.Create(AOwner: TdxStatusBarPanel);
begin
  inherited Create(AOwner);
  FSpacing := 4;
  FIndicators := TdxStatusBarStateIndicators.Create;
  FIndicators.OnChange := IndicatorChangeHandler;
end;

destructor TdxStatusBarStateIndicatorPanelStyle.Destroy;
begin
  FreeAndNil(FIndicators);
  inherited;
end;

procedure TdxStatusBarStateIndicatorPanelStyle.RestoreDefaults;
begin
  FSpacing := 4;
  inherited RestoreDefaults;
end;

function TdxStatusBarStateIndicatorPanelStyle.CanSizing: Boolean;
begin
  Result := False;
end;

procedure TdxStatusBarStateIndicatorPanelStyle.DoAssign(ASource: TPersistent);
var
  AStyle: TdxStatusBarStateIndicatorPanelStyle;
begin
  inherited;
  if ASource is TdxStatusBarStateIndicatorPanelStyle then
  begin
    AStyle := TdxStatusBarStateIndicatorPanelStyle(ASource);
    Spacing := AStyle.Spacing;
    Indicators := AStyle.Indicators;
  end;
end;

procedure TdxStatusBarStateIndicatorPanelStyle.DrawContent(ACanvas: TcxCanvas;
  R: TRect; APainter: TdxStatusBarPainterClass);
var
  I, ALeft, ATop: Integer;
  ABitmap: TBitmap;
begin
  inherited;
  ALeft := R.Left + Spacing;
  for I := 0 to Indicators.Count - 1 do
  begin
    ABitmap := Indicators[I].FIndicatorBitmap;
    if Indicators[I].Visible and (ABitmap <> nil) and not ABitmap.Empty then
    begin
      ATop := ((R.Top + R.Bottom) div 2) - (ABitmap.Height div 2);
      ACanvas.Draw(ALeft, ATop, ABitmap);
      Inc(ALeft, ABitmap.Width + Spacing);
    end;
  end;
end;

function TdxStatusBarStateIndicatorPanelStyle.GetMinWidth: Integer;
var
  I: Integer;
  ABitmap: TBitmap;
begin
  // WARNING: sync with DrawContent 
  if Indicators.Count > 0 then
  begin
    Result := Spacing;
    for I := 0 to Indicators.Count - 1 do
    begin
      ABitmap := Indicators[I].FIndicatorBitmap;
      if Indicators[I].Visible and (ABitmap <> nil) and not ABitmap.Empty then
        Inc(Result, ABitmap.Width + Spacing);
    end;
  end
  else
    Result := 20;
end;

function TdxStatusBarStateIndicatorPanelStyle.GetIndicators: TdxStatusBarStateIndicators;
begin
  Result := FIndicators;
end;

procedure TdxStatusBarStateIndicatorPanelStyle.IndicatorChangeHandler(Sender: TObject);
begin
  Owner.Changed(False);
end;

procedure TdxStatusBarStateIndicatorPanelStyle.SetIndicators(Value: TdxStatusBarStateIndicators);
begin
  FIndicators.Assign(Value);
end;

procedure TdxStatusBarStateIndicatorPanelStyle.SetSpacing(Value: Integer);
begin
  if FSpacing <> Value then
  begin
    FSpacing := Value;
    Owner.Changed(False);
  end;
end;

{ TdxStatusBarKeyboardStateWatchedKey }

constructor TdxStatusBarKeyboardStateWatchedKey.Create(AKeyCode: Integer);
begin
  FKeyCode := AKeyCode;
  FKeyState := Lo(GetKeyState(AKeyCode));
end;

function TdxStatusBarKeyboardStateWatchedKey.GetCurrentState: Integer;
begin
  Result := Lo(GetKeyState(FKeyCode));
end;

procedure TdxStatusBarKeyboardStateWatchedKey.SetKeyState(Value: Integer);
begin
  FKeyState := Value;
end;

{ TdxStatusBarKeyboardStateNotifier }

constructor TdxStatusBarKeyboardStateNotifier.Create(AStatusBar: TdxCustomStatusBar);
begin
  inherited Create;
  FStatusBar := AStatusBar;
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 100;
  FTimer.OnTimer := Execute;
end;

destructor TdxStatusBarKeyboardStateNotifier.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TdxStatusBarKeyboardStateNotifier.SubScribeKey(AKeyCode: Integer);
begin
  UnSubscribeKey(AKeyCode);

  SetLength(FKeys, Length(FKeys) + 1);
  FKeys[High(FKeys)] := TdxStatusBarKeyboardStateWatchedKey.Create(AKeyCode);
end;

procedure TdxStatusBarKeyboardStateNotifier.UnSubScribeKey(AKeyCode: Integer);
var
  I: Integer;
begin
  for I := 0 to High(FKeys) do
    if FKeys[I].KeyCode = AKeyCode then
    begin
      FreeAndNil(FKeys[I]);
      SetLength(FKeys, Length(FKeys) - 1);
      Break;
    end;
end;

procedure TdxStatusBarKeyboardStateNotifier.Execute(Sender: TObject);
var
  I, ACurState: Integer;
  AChanged: Boolean;
begin
  AChanged := False;
  for I := Low(FKeys) to High(FKeys) do
  begin
    ACurState := Lo(GetKeyState(FKeys[I].KeyCode));
    if ACurState <> FKeys[I].KeyState then
    begin
      FKeys[I].KeyState := ACurState;
      AChanged := True;
    end;
  end;
  if AChanged then
    FStatusBar.UpdatePanels;
end;

{ TdxStatusBarKeyStateAppearance }

constructor TdxStatusBarKeyStateAppearance.Create(AId: TdxStatusBarKeyboardState;
  ACode: Integer; const AActiveCaption: string; AActiveFontColor: TColor;
  const AInactiveCaption: string; AInactiveFontColor: TColor; AChangeHandler: TNotifyEvent);
begin
  inherited Create;
  FId := AId;
  FCode := ACode;
  FOnChange := AChangeHandler;
  FActiveFontColor := AActiveFontColor;
  FInactiveFontColor := AInactiveFontColor;
  FActiveCaption := AActiveCaption;
  FInactiveCaption := AInactiveCaption;
end;

procedure TdxStatusBarKeyStateAppearance.Assign(Source: TPersistent);
begin
  if Source is TdxStatusBarKeyStateAppearance then
  begin
    ActiveFontColor := TdxStatusBarKeyStateAppearance(Source).ActiveFontColor;
    InactiveFontColor := TdxStatusBarKeyStateAppearance(Source).InactiveFontColor;
    ActiveCaption := TdxStatusBarKeyStateAppearance(Source).ActiveCaption;
    InactiveCaption := TdxStatusBarKeyStateAppearance(Source).InactiveCaption;
  end
  else
    inherited Assign(Source);
end;

function TdxStatusBarKeyStateAppearance.GetRectWidth(ACanvas: TcxCanvas): Integer;
var
  AW, IW: Integer;
begin
  AW := ACanvas.TextWidth(FActiveCaption);
  IW := ACanvas.TextWidth(FInactiveCaption);
  if AW > IW then
    Result := AW
  else
    Result := IW;
  Inc(Result, 4);
end;

procedure TdxStatusBarKeyStateAppearance.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TdxStatusBarKeyStateAppearance.SetActiveFontColor(Value: TColor);
begin
  FActiveFontColor := Value;
  Changed;
end;

procedure TdxStatusBarKeyStateAppearance.SetInactiveFontColor(Value: TColor);
begin
  FInactiveFontColor := Value;
  Changed;
end;

procedure TdxStatusBarKeyStateAppearance.SetActiveCaption(const Value: string);
begin
  FActiveCaption := Value;
  Changed;
end;

procedure TdxStatusBarKeyStateAppearance.SetInactiveCaption(const Value: string);
begin
  FInactiveCaption := Value;
  Changed;
end;

{ TdxStatusBarKeyboardStatePanelStyle }

constructor TdxStatusBarKeyboardStatePanelStyle.Create(AOwner: TdxStatusBarPanel);
var
  I: Integer;
begin
  inherited Create(AOwner);
  FKeyInfos[0] := TdxStatusBarKeyStateAppearance.Create(dxksCapsLock, VK_CAPITAL, 'CAPS',
    FFont.Color, 'CAPS', clBtnShadow, NamesChangeHandler);
  FKeyInfos[1] := TdxStatusBarKeyStateAppearance.Create(dxksNumLock, VK_NUMLOCK, 'NUM',
    FFont.Color, 'NUM', clBtnShadow, NamesChangeHandler);
  FKeyInfos[2] := TdxStatusBarKeyStateAppearance.Create(dxksScrollLock, VK_SCROLL, 'SCRL',
    FFont.Color, 'SCRL', clBtnShadow, NamesChangeHandler);
  FKeyInfos[3] := TdxStatusBarKeyStateAppearance.Create(dxksInsert, VK_INSERT, 'OVR',
    FFont.Color, 'INS', clBtnShadow, NamesChangeHandler);
  FKeyboardStates := [FKeyInfos[0].Id, FKeyInfos[1].Id, FKeyInfos[2].Id, FKeyInfos[3].Id];
  FNotifier := TdxStatusBarKeyboardStateNotifier.Create(StatusBarControl);
  for I := 0 to High(FKeyInfos) do
    FNotifier.SubscribeKey(FKeyInfos[I].Code);
end;

destructor TdxStatusBarKeyboardStatePanelStyle.Destroy;
var
  I: Integer;
begin
  for I := High(FKeyInfos) downto 0 do
    if Assigned(FKeyInfos[I]) then
      FNotifier.UnSubscribeKey(FKeyInfos[I].Code);
  FNotifier.Free;
  for I := High(FKeyInfos) downto 0 do
    FreeAndNil(FKeyInfos[I]);
  inherited;
end;

procedure TdxStatusBarKeyboardStatePanelStyle.RestoreDefaults;
begin
  FKeyboardStates := [FKeyInfos[0].Id, FKeyInfos[1].Id, FKeyInfos[2].Id, FKeyInfos[3].Id];
  inherited RestoreDefaults;
end;

function TdxStatusBarKeyboardStatePanelStyle.CanSizing: Boolean;
begin
  Result := False;
end;

procedure TdxStatusBarKeyboardStatePanelStyle.DoAssign(ASource: TPersistent);
var
  AStyle: TdxStatusBarKeyboardStatePanelStyle;
begin
  inherited;
  if ASource is TdxStatusBarKeyboardStatePanelStyle then
  begin
    AStyle := TdxStatusBarKeyboardStatePanelStyle(ASource);
    KeyboardStates := AStyle.KeyboardStates;
    FullRect := AStyle.FullRect;
    CapsLockKeyAppearance := AStyle.CapsLockKeyAppearance;
    NumLockKeyAppearance := AStyle.NumLockKeyAppearance;
    ScrollLockKeyAppearance := AStyle.ScrollLockKeyAppearance;
    InsertKeyAppearance := AStyle.InsertKeyAppearance;
  end;
end;

procedure TdxStatusBarKeyboardStatePanelStyle.DrawContent(ACanvas: TcxCanvas;
  R: TRect; APainter: TdxStatusBarPainterClass);
var
  I: Integer;
  S: string;
  Active: Boolean;
  ARect: TRect;
  ALastKeyIndex: Integer;
  ATextColor: TColor;
begin
  inherited;
  ACanvas.Font.Assign(FFont);
  ALastKeyIndex := -1;
  for I := Low(FKeyInfos) to High(FKeyInfos) do
    if FKeyInfos[I].Id in FKeyboardStates then
      ALastKeyIndex := I;
  for I := Low(FKeyInfos) to High(FKeyInfos) do
  begin
    if FKeyInfos[I].Id in FKeyboardStates then
    begin
      Active := not (csDesigning in StatusBarControl.ComponentState) and
        (Lo(GetKeyState(FKeyInfos[I].Code)) = 1);
      if Active then
      begin
        S := FKeyInfos[I].ActiveCaption;
        ATextColor := FKeyInfos[I].FActiveFontColor;
      end
      else
      begin
        S := FKeyInfos[I].InactiveCaption;
        ATextColor := FKeyInfos[I].FInactiveFontColor;
      end;
      APainter.AdjustTextColor(Owner.GetStatusBarControl, ATextColor, Active);
      AdjustTextColor(ATextColor, Active);
      ACanvas.Font.Color := ATextColor;
      // key cell
      R.Right := R.Left + FKeyInfos[I].GetRectWidth(ACanvas);
      if not FullRect then
        Inc(R.Right, 2);
      ARect := R;
      if not FullRect then
        APainter.DrawPanelBorder(StatusBarControl, Owner.Bevel, ACanvas, ARect);
      ACanvas.Brush.Style := bsClear;
      ACanvas.DrawTexT(S, ARect, cxSingleLine or cxAlignVCenter or cxAlignHCenter,
        StatusBarControl.Enabled);
      ACanvas.Brush.Style := bsSolid;
      // key separator
      if I <> ALastKeyIndex then
        R.Left := R.Right + APainter.SeparatorSizeEx(StatusBarControl);
    end;
  end;
end;

function TdxStatusBarKeyboardStatePanelStyle.GetMinWidth: Integer;
var
  I: Integer;
  ALastKeyIndex: Integer;
begin
  // WARNING: sync with DrawContent
  if FKeyboardStates <> [] then
  begin
    StatusBarControl.Canvas.Font.Assign(FFont);
    Result := 0;
    ALastKeyIndex := -1;
    for I := Low(FKeyInfos) to High(FKeyInfos) do
      if FKeyInfos[I].Id in FKeyboardStates then
        ALastKeyIndex := I;
    for I := Low(FKeyInfos) to High(FKeyInfos) do
    begin
      if FKeyInfos[I].Id in FKeyboardStates then
      begin
        Inc(Result, FKeyInfos[I].GetRectWidth(StatusBarControl.Canvas));
        if not FullRect then Inc(Result, 2); // bevel
        // key separator
        if I <> ALastKeyIndex then
          Inc(Result, StatusBarControl.Painter.SeparatorSizeEx(StatusBarControl));
      end;
    end;
  end
  else
    Result := 50;
end;

function TdxStatusBarKeyboardStatePanelStyle.InternalBevel: Boolean;
begin
  Result := not FullRect;
end;

function TdxStatusBarKeyboardStatePanelStyle.GetCapsLockAppearance: TdxStatusBarKeyStateAppearance;
begin
  Result := FKeyInfos[0];
end;

function TdxStatusBarKeyboardStatePanelStyle.GetInsertAppearance: TdxStatusBarKeyStateAppearance;
begin
  Result := FKeyInfos[3];
end;

function TdxStatusBarKeyboardStatePanelStyle.GetNumLockAppearance: TdxStatusBarKeyStateAppearance;
begin
  Result := FKeyInfos[1];
end;

function TdxStatusBarKeyboardStatePanelStyle.GetScrollLockAppearance: TdxStatusBarKeyStateAppearance;
begin
  Result := FKeyInfos[2];
end;

procedure TdxStatusBarKeyboardStatePanelStyle.NamesChangeHandler(Sender: TObject);
begin
  Owner.Changed(False);
end;

procedure TdxStatusBarKeyboardStatePanelStyle.SetCapsLockAppearance(Value: TdxStatusBarKeyStateAppearance);
begin
  FKeyInfos[0].Assign(Value);
end;

procedure TdxStatusBarKeyboardStatePanelStyle.SetFullRect(Value: Boolean);
begin
  if FFullRect <> Value then
  begin
    FFullRect := Value;
    Owner.Changed(True);
  end;
end;

procedure TdxStatusBarKeyboardStatePanelStyle.SetInsertAppearance(Value: TdxStatusBarKeyStateAppearance);
begin
  FKeyInfos[3].Assign(Value);
end;

procedure TdxStatusBarKeyboardStatePanelStyle.SetKeyboardStates(Value: TdxStatusBarKeyboardStates);
begin
  if FKeyboardStates <> Value then
  begin
    FKeyboardStates := Value;
    Owner.Changed(False);
  end;
end;

procedure TdxStatusBarKeyboardStatePanelStyle.SetNumLockAppearance(Value: TdxStatusBarKeyStateAppearance);
begin
  FKeyInfos[1].Assign(Value);
end;

procedure TdxStatusBarKeyboardStatePanelStyle.SetScrollLockAppearance(Value: TdxStatusBarKeyStateAppearance);
begin
  FKeyInfos[2].Assign(Value);
end;

{ TdxStatusBarContainerControl }

constructor TdxStatusBarContainerControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csNoDesignVisible];
{$IFDEF DELPHI12}
  ParentDoubleBuffered := False;
{$ENDIF}
end;

destructor TdxStatusBarContainerControl.Destroy;
var
  APanel:  TdxStatusBarPanel;
begin
  if FPanelStyle <> nil then
  begin
    APanel := FPanelStyle.Owner;
    FPanelStyle.FContainer := nil;
    FPanelStyle := nil;
    APanel.PanelStyleClass := nil;
  end;
  inherited Destroy;
end;

procedure TdxStatusBarContainerControl.Paint;
var
  R: TRect;
begin
  inherited;
  R := ClientRect;
  if FPanelStyle <> nil then
    FPanelStyle.DrawContainerControl
  else
  begin
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(R);
  end;
  if csDesigning in ComponentState then
  begin
    Canvas.Pen.Color := clBtnShadow;
    Canvas.Brush.Color := clBtnShadow;
    Canvas.Brush.Style := bsBDiagonal;
{$IFDEF DELPHI5}
    Canvas.Canvas.Rectangle(R);
{$ELSE}
    Canvas.Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
{$ENDIF}
    Canvas.Brush.Style := bsSolid;
  end;
end;

function TdxStatusBarContainerControl.MayFocus: Boolean;
begin
  Result := False;
end;

function TdxStatusBarContainerControl.NeedsScrollBars: Boolean;
begin
  Result := False;
end;

{ TdxStatusBarContainerPanelStyle }

constructor TdxStatusBarContainerPanelStyle.Create(AOwner: TdxStatusBarPanel);
begin
  inherited Create(AOwner);
  FAlignControl := True;
  if StatusBarControl.ComponentState * [csUpdating, csLoading, csReading] = [] then
  begin
    FContainer := TdxStatusBarContainerControl.Create(StatusBarControl.Owner);
    FContainer.FPanelStyle := Self;
    FContainer.Parent := StatusBarControl;
    if csDesigning in StatusBarControl.ComponentState then
      GenContainerName(AOwner, FContainer);
  end;
end;

destructor TdxStatusBarContainerPanelStyle.Destroy;
begin
  Container := nil;
  inherited;
end;

procedure TdxStatusBarContainerPanelStyle.RestoreDefaults;
begin
  FAlignControl := True;
  inherited RestoreDefaults;
end;

function TdxStatusBarContainerPanelStyle.CanDelete: Boolean;
begin
  Result := (Container = nil) or not (csAncestor in Container.ComponentState);
end;

procedure TdxStatusBarContainerPanelStyle.DoAssign(ASource: TPersistent);
var
  AStyle: TdxStatusBarContainerPanelStyle;
begin
  inherited;
  if ASource is TdxStatusBarContainerPanelStyle then
  begin
    AStyle := TdxStatusBarContainerPanelStyle(ASource);
    AlignControl := AStyle.AlignControl;
    if AStyle.Container <> nil then
      Container := StatusBarControl.ContainerByName(AStyle.Container.Name);
  end;
end;

procedure TdxStatusBarContainerPanelStyle.DrawContainerControl;
begin
  StatusBarControl.Painter.DrawContainerControl(Self);
end;

procedure TdxStatusBarContainerPanelStyle.DrawContent(ACanvas: TcxCanvas; R: TRect;
  APainter: TdxStatusBarPainterClass);
var
  I: Integer;
begin
  inherited;
  if Container <> nil then
  begin
    if StatusBarControl.Painter.IsSizeGripInPanel(StatusBarControl) then
      CheckSizeGripRect(R);
    Container.BoundsRect := R;
    if AlignControl and not (csDesigning in StatusBarControl.ComponentState) then
    begin
      for I := 0 to Container.ControlCount - 1 do
        Container.Controls[I].SetBounds(0, 0, Container.Width, Container.Height);
    end;
  end;
end;

procedure TdxStatusBarContainerPanelStyle.PanelVisibleChanged;
begin
  if Container <> nil then
    Container.Visible := Owner.Visible;
end;

procedure TdxStatusBarContainerPanelStyle.SetContainer(Value: TdxStatusBarContainerControl);
begin
  if FContainer <> Value then
  begin
    if Value = nil then
    begin
      FContainer.FPanelStyle := nil;
      if StatusBarControl.ComponentState * [csDestroying, csUpdating, csLoading, csReading] <> [] then
        FContainer := nil
      else
        FreeAndNil(FContainer);
    end
    else
    begin
      FContainer := Value;
      FContainer.FPanelStyle := Self;
    end;
    PanelVisibleChanged;
  end;
end;

{ TdxStatusBarPanel }

constructor TdxStatusBarPanel.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FVisible := True;
  FMinWidth := 20;
  FWidth := 50;
  FFixed := True;
  FParentBiDiMode := True;
  FBevel := dxpbLowered;
  ParentBiDiModeChanged;
  // auto create
  if StatusBarControl.ComponentState * [csLoading, csReading] = [] then
    PanelStyleClass := StatusBarControl.GetDeafultPanelStyleClass;
end;

destructor TdxStatusBarPanel.Destroy;
begin
  DestroyPanelStyle;
  inherited Destroy;
end;

procedure TdxStatusBarPanel.Assign(Source: TPersistent);
begin
  if Source is TdxStatusBarPanel then
  begin
    if Assigned(Collection) then Collection.BeginUpdate;
    try
      RestoreDefaults;
      
      PanelStyleClassName := TdxStatusBarPanel(Source).PanelStyleClassName;
      PanelStyle := TdxStatusBarPanel(Source).PanelStyle;

      Visible := TdxStatusBarPanel(Source).Visible;
      Bevel := TdxStatusBarPanel(Source).Bevel;
      BiDiMode := TdxStatusBarPanel(Source).BiDiMode;
      Fixed := TdxStatusBarPanel(Source).Fixed;
      if TdxStatusBarPanel(Source).IsMinWidthStored then
        MinWidth := TdxStatusBarPanel(Source).MinWidth;
      ParentBiDiMode := TdxStatusBarPanel(Source).ParentBiDiMode;
      Text := TdxStatusBarPanel(Source).Text;
      if TdxStatusBarPanel(Source).IsWidthStored then
        Width := TdxStatusBarPanel(Source).Width;

      OnClick := TdxStatusBarPanel(Source).OnClick;
      OnDblClick := TdxStatusBarPanel(Source).OnDblClick;
      OnDrawPanel := TdxStatusBarPanel(Source).OnDrawPanel;
    finally
      if Assigned(Collection) then Collection.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TdxStatusBarPanel.RestoreDefaults;
begin
  FVisible := True;
  FMinWidth := 20;
  FWidth := 50;
  FFixed := True;
  FParentBiDiMode := True;
  FBevel := dxpbLowered;
  FIsMinWidthAssigned := False;
  FIsWidthAssigned := False;
  Changed(True);
end;

procedure TdxStatusBarPanel.ParentBiDiModeChanged;
begin
  if FParentBiDiMode then
  begin
    if GetOwner <> nil then
    begin
      BiDiMode := TdxStatusBarPanels(GetOwner).FStatusBarControl.BiDiMode;
      FParentBiDiMode := True;
    end;
  end;
end;

function TdxStatusBarPanel.UseRightToLeftReading: Boolean;
begin
  Result := SysLocale.MiddleEast and (BiDiMode <> bdLeftToRight);
end;

function TdxStatusBarPanel.UseRightToLeftAlignment: Boolean;
begin
  Result := SysLocale.MiddleEast and (BiDiMode = bdRightToLeft);
end;

procedure TdxStatusBarPanel.Click;
begin
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure TdxStatusBarPanel.CreatePanelStyle;
begin
  if FPanelStyleClass <> nil then
    FPanelStyle := FPanelStyleClass.Create(Self);
  StatusBarControl.Invalidate;
end;

procedure TdxStatusBarPanel.DblClick;
begin
  if Assigned(FOnDblClick) then FOnDblClick(Self);
end;

function TdxStatusBarPanel.DefaultMinWidth: Integer;
begin
  if PanelStyle <> nil then
    Result := PanelStyle.GetMinWidth
  else
    Result := 20;
end;

function TdxStatusBarPanel.DefaultWidth: Integer;
begin
  if (PanelStyle <> nil) and not PanelStyle.CanSizing then
    Result := DefaultMinWidth
  else
    Result := 50;
end;

procedure TdxStatusBarPanel.DestroyPanelStyle;
begin
  if (StatusBarControl.ComponentState * [csDestroying, csUpdating, csLoading, csReading] = []) and
    (PanelStyle <> nil) and not PanelStyle.CanDelete then
    raise EdxException.Create(cxSCantDeleteAncestor);
  FreeAndNil(FPanelStyle);
end;

function TdxStatusBarPanel.GetDisplayName: string;
begin
  Result := Text;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

procedure TdxStatusBarPanel.Loaded;
begin
  if PanelStyle <> nil then
    PanelStyle.Loaded;
end;

function TdxStatusBarPanel.PaintMinWidth: Integer;
begin
  Result := MinWidth;
  PreparePaintWidth(Result);
end;

function TdxStatusBarPanel.PaintWidth: Integer;
begin
  Result := Width;
  PreparePaintWidth(Result);
end;

procedure TdxStatusBarPanel.PreparePaintWidth(var AWidth: Integer);
begin
  if PanelStyle <> nil then
  begin
    // bevel
    if not PanelStyle.InternalBevel then
      Inc(AWidth, 2);
    // size grip
    if (Index = (StatusBarControl.Panels.Count - 1)) and StatusBarControl.SizeGripAllocated then
      Inc(AWidth, StatusBarControl.Painter.GripAreaSize.cx);
  end;
end;

procedure TdxStatusBarPanel.StatusBarPanelStyleChanged;
begin
  Changed(False);
end;

function TdxStatusBarPanel.GetFixed: Boolean;
begin
  if (PanelStyle <> nil) and not PanelStyle.CanSizing then
    Result := True
  else
    Result := FFixed;
end;

function TdxStatusBarPanel.GetLookAndFeel: TcxLookAndFeel;
begin
  Result := StatusBarControl.LookAndFeel;
end;

function TdxStatusBarPanel.GetMinWidth: Integer;
begin
  if not FIsMinWidthAssigned or
    ((PanelStyle <> nil) and not PanelStyle.CanSizing) then
    Result := DefaultMinWidth
  else
    Result := FMinWidth;
end;

function TdxStatusBarPanel.GetPanelStyleClassName: string;
begin
  if FPanelStyle = nil then
    Result := ''
  else
    Result := FPanelStyle.ClassName;
end;

function TdxStatusBarPanel.GetStatusBarControl: TdxCustomStatusBar;
begin
  Result := TdxStatusBarPanels(Collection).FStatusBarControl;
end;

function TdxStatusBarPanel.GetWidth: Integer;
begin
  if not FIsWidthAssigned or
    ((PanelStyle <> nil) and not PanelStyle.CanSizing) then
    Result := DefaultWidth
  else
    Result := FWidth;
end;

function TdxStatusBarPanel.IsBiDiModeStored: Boolean;
begin
  Result := not FParentBiDiMode;
end;

function TdxStatusBarPanel.IsMinWidthStored: Boolean;
begin
  Result := FIsMinWidthAssigned;
end;

function TdxStatusBarPanel.IsWidthStored: Boolean;
begin
  Result := FIsWidthAssigned;
end;

procedure TdxStatusBarPanel.SetBevel(Value: TdxStatusBarPanelBevel);
begin
  if FBevel <> Value then
  begin
    FBevel := Value;
    Changed(False);
  end;
end;

procedure TdxStatusBarPanel.SetBiDiMode(Value: TBiDiMode);
begin
  if Value <> FBiDiMode then
  begin
    FBiDiMode := Value;
    FParentBiDiMode := False;
    Changed(False);
  end;
end;

procedure TdxStatusBarPanel.SetFixed(Value: Boolean);
begin
  if FFixed <> Value then
  begin
    FFixed := Value;
    Changed(False);
  end;
end;

procedure TdxStatusBarPanel.SetMinWidth(Value: Integer);
begin
  if Value < 0 then Value := 0;
  FMinWidth := Value;
  FIsMinWidthAssigned := True;
  if Width < FMinWidth then Width := FMinWidth;
  Changed(False);
end;

procedure TdxStatusBarPanel.SetPanelStyle(Value: TdxStatusBarPanelStyle);
begin
  if (FPanelStyle <> nil) and (Value <> nil) then
    FPanelStyle.Assign(Value);
end;

procedure TdxStatusBarPanel.SetPanelStyleClass(const Value: TdxStatusBarPanelStyleClass);
begin
  if (FPanelStyleClass <> Value) and StatusBarControl.CanAcceptPanelStyle(Value) then
  begin
    DestroyPanelStyle;
    FPanelStyleClass := Value;
    CreatePanelStyle;
  end;
end;

procedure TdxStatusBarPanel.SetPanelStyleClassName(Value: string);
begin
  PanelStyleClass := TdxStatusBarPanelStyleClass(
    GetRegisteredStatusBarPanelStyles.FindByClassName(Value));
end;

procedure TdxStatusBarPanel.SetParentBiDiMode(Value: Boolean);
begin
  if FParentBiDiMode <> Value then
  begin
    FParentBiDiMode := Value;
    ParentBiDiModeChanged;
  end;
end;

procedure TdxStatusBarPanel.SetText(const Value: string);
begin
  if FText <> Value then
  begin
    FText := Value;
    Changed(False);
  end;
end;

procedure TdxStatusBarPanel.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    if PanelStyle <> nil then
      PanelStyle.PanelVisibleChanged;
    Changed(False);
  end;
end;

procedure TdxStatusBarPanel.SetWidth(Value: Integer);
begin
  if Value < FMinWidth then Value := FMinWidth;
  FWidth := Value;
  FIsWidthAssigned := True;
  Changed(False);
end;

{ TdxStatusBarPanels }

constructor TdxStatusBarPanels.Create(AStatusBarControl: TdxCustomStatusBar);
begin
  inherited Create(TdxStatusBarPanel);
  FStatusBarControl := AStatusBarControl;
end;

function TdxStatusBarPanels.Add: TdxStatusBarPanel;
begin
  Result := TdxStatusBarPanel.Create(Self);
end;

function TdxStatusBarPanels.Insert(Index: Integer): TdxStatusBarPanel;
begin
  BeginUpdate;
  try
    if Index < 0 then Index := 0;
    if Index > Count then Index := Count;
    Result := Add;
    Result.Index := Index;
  finally
    EndUpdate;
  end;
end;

function TdxStatusBarPanels.GetOwner: TPersistent;
begin
  Result := FStatusBarControl;
end;

procedure TdxStatusBarPanels.Loaded;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Loaded;
end;

procedure TdxStatusBarPanels.Update(Item: TCollectionItem);
begin
  if FStatusBarControl <> nil then
    FStatusBarControl.UpdatePanels;
end;

function TdxStatusBarPanels.GetItem(Index: Integer): TdxStatusBarPanel;
begin
  Result := TdxStatusBarPanel(inherited GetItem(Index));
end;

procedure TdxStatusBarPanels.SetItem(Index: Integer; Value: TdxStatusBarPanel);
begin
  inherited SetItem(Index, Value);
end;

{ TdxStatusBarViewInfo }

constructor TdxStatusBarViewInfo.Create(AOwner: TdxCustomStatusBar);
begin
  inherited Create;
  FStatusBar := AOwner;
  FWidths := TList.Create;
  FPanels := TList.Create;
end;

destructor TdxStatusBarViewInfo.Destroy;
begin
  FPanels.Free;
  FWidths.Free;
  inherited Destroy;
end;

procedure TdxStatusBarViewInfo.Calculate(const ABounds: TRect);
var
  AAutoWidthObject: TcxAutoWidthObject;
  ACount, I: Integer;
begin
  UpdatePanels;
  FWidths.Clear;
  ACount := GetCalculatedItemCount;
  if ACount > 0 then
  begin
    AAutoWidthObject := TcxAutoWidthObject.Create(ACount);
    try
      AddCalculatedItems(AAutoWidthObject);
      AAutoWidthObject.AvailableWidth := ABounds.Right - ABounds.Left;
      AAutoWidthObject.Calculate;
      FSizeGripOvelapped := AAutoWidthObject.Width >= AAutoWidthObject.AvailableWidth;
      for I := 0 to AAutoWidthObject.Count - 1 do
        FWidths.Add(Pointer(AAutoWidthObject[I].AutoWidth));
    finally
      AAutoWidthObject.Free;
    end;
  end;
end;

procedure TdxStatusBarViewInfo.AddCalculatedItems(AAutoWidthObject: TcxAutoWidthObject);
var
  I, ACount, ASeparatorSize: Integer;
  ANonFixedExists: Boolean;
begin
  ANonFixedExists := False;
  ASeparatorSize := StatusBar.Painter.SeparatorSizeEx(StatusBar);
  ACount := PanelCount;
  for I := 0 to ACount - 1 do
  begin
    with AAutoWidthObject.AddItem do
    begin
      MinWidth := Panels[I].PaintMinWidth;
      Width := Panels[I].PaintWidth;
      if not Panels[I].Fixed then
      begin
        Fixed := False;
        ANonFixedExists := True;
      end
      else
      begin
        if (I = (ACount - 1)) and not ANonFixedExists then
          Fixed := False
        else
          Fixed := True;
      end;
    end;
    // Separator
    if I < (ACount - 1) then
      with AAutoWidthObject.AddItem do
      begin
        MinWidth := ASeparatorSize;
        Width := ASeparatorSize;
        Fixed := True;
      end;
  end;
end;

procedure TdxStatusBarViewInfo.UpdatePanels;
var
  I: Integer;
begin
  FPanels.Clear;
  for I := 0 to StatusBar.Panels.Count - 1 do
    if StatusBar.Panels[I].Visible then
      FPanels.Add(StatusBar.Panels[I]);
end;

function TdxStatusBarViewInfo.GetCalculatedItemCount: Integer;
begin
  Result := PanelCount;    //visible panels
  Inc(Result, Result - 1); //separators
end;

function TdxStatusBarViewInfo.GetPanelAt(const APanelsBounds: TRect;
  X, Y: Integer): TdxStatusBarPanel;
var
  ARect: TRect;
  I, J, ACount: Integer;
begin
  Result := nil;
  ACount := PanelCount;
  if ACount = 0 then Exit;
  // Calc Panel Rects
  J := 0;
  ARect := APanelsBounds;
  for I := 0 to ACount - 1 do
  begin
    // Panel
    ARect.Right := ARect.Left + Widths[J];
    if PtInRect(ARect, Point(X, Y)) then
    begin
      Result := Panels[I];
      Break;
    end;
    Inc(J);
    // Separator
    if I < (ACount - 1) then
    begin
      ARect.Left := ARect.Right;
      ARect.Right := ARect.Left + Widths[J];
      Inc(J);
    end;
    ARect.Left := ARect.Right;
  end;
end;

function TdxStatusBarViewInfo.GetPanel(Index: Integer): TdxStatusBarPanel;
begin
  Result := TdxStatusBarPanel(FPanels[Index]);
end;

function TdxStatusBarViewInfo.GetPanelCount: Integer;
begin
  Result := FPanels.Count;
end;

function TdxStatusBarViewInfo.GetWidth(Index: Integer): Integer;
begin
  if (Index >= 0) and (Index < FWidths.Count) then
    Result := Integer(FWidths[Index])
  else
    Result := 0;
end;

{ TdxCustomStatusBar }

constructor TdxCustomStatusBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FViewInfo := CreateViewInfo;
  ControlStyle := ControlStyle - [csSetCaption] +
    [csCaptureMouse, csClickEvents, csDoubleClicks, csOpaque];
  DoubleBuffered := True;
  Color := clBtnFace;
  Height := 20;
  Align := alBottom;
  ParentFont := False;
  FSizeGrip := True;
  FPanels := CreatePanels;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  FThemeChangedNotificator := TdxThemeChangedNotificator.Create;
  FThemeChangedNotificator.OnThemeChanged := ThemeChanged;
  FLookAndFeel := TcxLookAndFeel.Create(Self);
  FLookAndFeel.OnChanged := LookAndFeelChangeHandler;
  PaintStyleChanged;
  CreateOffice11Colors;
end;

destructor TdxCustomStatusBar.Destroy;
begin
  ReleaseOffice11Colors;
  FreeAndNil(FLookAndFeel);
  FreeAndNil(FThemeChangedNotificator);
  FreeAndNil(FImageChangeLink);
  FreeAndNil(FPanels);
  FreeAndNil(FViewInfo);
  inherited Destroy;
end;

{$IFNDEF DELPHI10}
function TdxCustomStatusBar.ClientToParent(const Point: TPoint; AParent: TWinControl = nil): TPoint;
const
  SParentRequired = 'Control ''%s'' has no parent window';
  SParentGivenNotAParent = 'Parent given is not a parent of ''%s''';
var
  LParent: TWinControl;
begin
  if AParent = nil then
    AParent := Parent;
  if AParent = nil then
    raise EInvalidOperation.CreateFmt(SParentRequired, [Name]);
  Result := Point;
  Inc(Result.X, Left);
  Inc(Result.Y, Top);
  LParent := Parent;
  while (LParent <> nil) and (LParent <> AParent) do
  begin
    if LParent.Parent <> nil then
    begin
      Inc(Result.X, LParent.Left);
      Inc(Result.Y, LParent.Top);
    end;
    if LParent = AParent then
      Break
    else
      LParent := LParent.Parent;
  end;
  if LParent = nil then
    raise EInvalidOperation.CreateFmt(SParentGivenNotAParent, [Name]);
end;
{$ENDIF}

function TdxCustomStatusBar.ExecuteAction(Action: TBasicAction): Boolean;
var
  I: Integer;
  APanel: TdxStatusBarPanel;
begin
  APanel := nil;
  for I := 0 to Panels.Count - 1 do
    if (Panels[I].PanelStyle is TdxStatusBarTextPanelStyle) and
      TdxStatusBarTextPanelStyle(Panels[I].PanelStyle).AutoHint then
        APanel := Panels[I];
  if not (csDesigning in ComponentState) and
    (APanel <> nil) and (Action is THintAction) and not DoHint then
  begin
    APanel.Text := THintAction(Action).Hint;
    Result := True;
  end
  else
    Result := inherited ExecuteAction(Action);
end;

function TdxCustomStatusBar.GetPanelAt(X, Y: Integer): TdxStatusBarPanel;
begin
  Result := ViewInfo.GetPanelAt(GetPanelsBounds, X, Y);
end;

procedure TdxCustomStatusBar.AdjustTextColor(var AColor: TColor; Active: Boolean);
begin
end;

function TdxCustomStatusBar.CreateViewInfo: TdxStatusBarViewInfo;
begin
  Result := TdxStatusBarViewInfo.Create(Self);
end;

procedure TdxCustomStatusBar.FontChanged;
var
  I: Integer;
begin
  inherited;
  for I := 0 to Panels.Count - 1 do
    if Panels[I].PanelStyle <> nil then
      Panels[I].PanelStyle.ParentFontChanged;
end;

function TdxCustomStatusBar.HasBackground: Boolean;
begin
  Result := False;
end;

procedure TdxCustomStatusBar.Loaded;
begin
  inherited Loaded;
  Panels.Loaded;
  Recalculate;
end;

function TdxCustomStatusBar.MayFocus: Boolean;
begin
  Result := False;
end;

procedure TdxCustomStatusBar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  APanel: TdxStatusBarPanel;
begin
  inherited;
  if Button = mbLeft then
  begin
    APanel := GetPanelAt(X, Y);
    if (APanel <> nil) and (ssDouble in Shift) then
      APanel.DblClick;
  end;
end;

procedure TdxCustomStatusBar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  APanel: TdxStatusBarPanel;
begin
  inherited;
  if Button = mbLeft then
  begin
    APanel := GetPanelAt(X, Y);
    if APanel <> nil then
      APanel.Click;
  end;
end;

function TdxCustomStatusBar.NeedsScrollBars: Boolean;
begin
  Result := False;
end;

procedure TdxCustomStatusBar.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Images) then
    Images := nil;
end;

procedure TdxCustomStatusBar.Paint;

  procedure DrawPanels(const R: TRect);
  var
    ARect: TRect;
    I, J, ACount: Integer;
  begin
    ACount := ViewInfo.PanelCount;
    J := 0;
    ARect := R;
    for I := 0 to ACount - 1 do
    begin
      // Panel
      ARect.Right := ARect.Left + ViewInfo[J];
      Painter.DrawPanel(Self, ViewInfo.Panels[I], Canvas, ARect);
      Inc(J);
      // Separator
      if I < (ACount - 1) then
      begin
        ARect.Left := ARect.Right;
        ARect.Right := ARect.Left + ViewInfo[J];
        Painter.DrawPanelSeparator(Self, Canvas, ARect);
        Inc(J);
      end;
      ARect.Left := ARect.Right;
    end;
  end;

  procedure DrawSizeGrip(R: TRect; AOverlapped: Boolean);
  begin
    if SizeGripAllocated then
      Painter.DrawSizeGrip(Self, Canvas, R, AOverlapped); // <- ExcludeClipRect
  end;

var
  R: TRect;
  AOverlapped: Boolean;
begin
  inherited Paint;
  R := ClientBounds;
  // Border
  Painter.DrawBorder(Self, Canvas, R);
  Canvas.IntersectClipRect(R); // !!!

  AOverlapped := (ViewInfo.PanelCount <> 0) and ViewInfo.SizeGripOvelapped;
  if Painter.DrawSizeGripFirst then
    DrawSizeGrip(R, AOverlapped);

  // Panels
  if ViewInfo.PanelCount = 0 then
    Painter.DrawEmptyPanel(Self, Canvas, R)
  else
    DrawPanels(R);

  if not Painter.DrawSizeGripFirst then
    DrawSizeGrip(R, AOverlapped);
end;

procedure TdxCustomStatusBar.Resize;
begin
  inherited;
  Recalculate;
  Invalidate;
end;

function TdxCustomStatusBar.CanAcceptPanelStyle(Value: TdxStatusBarPanelStyleClass): Boolean;
begin
  Result := (Value = nil) or (Value.GetVersion = 0);
end;

procedure TdxCustomStatusBar.Calculate;
begin
  ViewInfo.Calculate(ClientBounds);
end;

function TdxCustomStatusBar.ContainerByName(const AName: string): TdxStatusBarContainerControl;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ControlCount - 1 do
    if (Controls[I] is TdxStatusBarContainerControl) and
      (CompareText(TdxStatusBarContainerControl(Controls[I]).Name, AName) = 0) then
    begin
      Result := TdxStatusBarContainerControl(Controls[I]);
      Break;
    end;
end;

function TdxCustomStatusBar.CreatePanel: TdxStatusBarPanel;
begin
  Result := GetStatusPanelClass.Create(FPanels);
end;

function TdxCustomStatusBar.CreatePanels: TdxStatusBarPanels;
begin
  Result := TdxStatusBarPanels.Create(Self);
end;

function TdxCustomStatusBar.DoHint: Boolean;
begin
  if Assigned(FOnHint) then
  begin
    FOnHint(Self);
    Result := True;
  end
  else
    Result := False;
end;

class function TdxCustomStatusBar.GetDeafultPanelStyleClass: TdxStatusBarPanelStyleClass;
begin
  Result := TdxStatusBarTextPanelStyle;
end;

function TdxCustomStatusBar.GetPainterClass: TdxStatusBarPainterClass;
begin
  if (PaintStyle = stpsUseLookAndFeel) and Assigned(dxStatusBarSkinPainterClass) and
    Assigned(LookAndFeel.SkinPainter) then
  begin
    Result := dxStatusBarSkinPainterClass;
  end
  else
    case GetPaintStyle of
      stpsStandard:
        Result := TdxStatusBarStandardPainter;
      stpsFlat:
        Result := TdxStatusBarFlatPainter;
      stpsXP:
        begin
          if FThemeAvailable then
            Result := TdxStatusBarXPPainter
          else
            Result := TdxStatusBarStandardPainter;
        end;
      stpsOffice11:
        Result := TdxStatusBarOffice11Painter;
      else
        Result := TdxStatusBarStandardPainter;
    end;
end;

function TdxCustomStatusBar.GetPaintStyle: TdxStatusBarPaintStyle;
const
  AStyles: array[TcxLookAndFeelKind] of TdxStatusBarPaintStyle = (
    stpsStandard, stpsStandard, stpsFlat{$IFDEF DXVER500}, stpsOffice11{$ENDIF});
begin
  if PaintStyle = stpsUseLookAndFeel then
  begin
    if LookAndFeel.NativeStyle and FThemeAvailable then
      Result := stpsXP
    else
      Result := AStyles[LookAndFeel.Kind];
  end
  else
    Result := PaintStyle;
end;

class function TdxCustomStatusBar.GetStatusPanelClass: TdxStatusBarPanelClass;
begin
  Result := TdxStatusBarPanel;
end;

procedure TdxCustomStatusBar.InitPainterClass;
begin
  FThemeAvailable := AreVisualStylesAvailable([totStatus]);
  FPainter := GetPainterClass;
end;

procedure TdxCustomStatusBar.PaintStyleChanged;
begin
  InitPainterClass;
  UpdatePanels;
end;

procedure TdxCustomStatusBar.Recalculate;
begin
  if not (csDestroying in ComponentState) and Assigned(Panels) then
    Calculate;
end;

function TdxCustomStatusBar.SizeGripAllocated: Boolean;
var
  FParentForm: TCustomForm;
  FPoint: TPoint;
begin
  Result := False;
  if FSizeGrip then
  begin
    FParentForm := GetParentForm(Self);
    if Assigned(FParentForm) and (FParentForm.BorderStyle in [bsSizeable, bsSizeToolWin]) and
      not (IsZoomed(FParentForm.Handle) or IsIconic(FParentForm.Handle)) then
    begin
      FPoint := ClientToParent(Point(Width, Height), FParentForm);
      Result := (FPoint.X = FParentForm.ClientWidth) and (FPoint.Y >= FParentForm.ClientHeight);
    end;
  end;
end;

procedure TdxCustomStatusBar.ThemeChanged;
begin
  PaintStyleChanged;
end;

procedure TdxCustomStatusBar.UpdatePanels;
begin
  Recalculate;
  Invalidate;
end;

function TdxCustomStatusBar.GetPanelsBounds: TRect;
var
  BSR: TRect;
begin
  // Calc Border
  Result := ClientBounds;
  BSR := Painter.BorderSizes(Self);
  Inc(Result.Left, BSR.Left);
  Inc(Result.Top, BSR.Top);
  Dec(Result.Right, BSR.Right);
  Dec(Result.Bottom, BSR.Bottom);
end;

procedure TdxCustomStatusBar.ImageListChange(Sender: TObject);
begin
  UpdatePanels;
end;

procedure TdxCustomStatusBar.LookAndFeelChangeHandler(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  PaintStyleChanged;
end;

procedure TdxCustomStatusBar.SetBorderWidth(Value: Integer);
begin
  if FBorderWidth <> Value then
  begin
    if Value <= 0 then
      FBorderWidth := 0
    else
      FBorderWidth := Value;
    UpdatePanels;
  end;
end;

procedure TdxCustomStatusBar.SetImages(const Value: TCustomImageList);
begin
  if Images <> nil then
    Images.UnRegisterChanges(FImageChangeLink);
  FImages := Value;
  if Images <> nil then
  begin
    Images.RegisterChanges(FImageChangeLink);
    Images.FreeNotification(Self);
  end;
  UpdatePanels;
end;

procedure TdxCustomStatusBar.SetLookAndFeel(Value: TcxLookAndFeel);
begin
  FLookAndFeel.Assign(Value);
  UpdatePanels;
end;

procedure TdxCustomStatusBar.SetPanels(Value: TdxStatusBarPanels);
begin
  FPanels.Assign(Value);
end;

procedure TdxCustomStatusBar.SetPaintStyle(Value: TdxStatusBarPaintStyle);
begin
  if FPaintStyle <> Value then
  begin
    FPaintStyle := Value;
    PaintStyleChanged;
  end;
end;

procedure TdxCustomStatusBar.SetSizeGrip(Value: Boolean);
begin
  if FSizeGrip <> Value then
  begin
    FSizeGrip := Value;
    UpdatePanels;
  end;
end;

procedure TdxCustomStatusBar.CMBiDiModeChanged(var Message: TMessage);
var
  I: Integer;
begin
  inherited;
  if HandleAllocated then
  begin
    for I := 0 to Panels.Count - 1 do
      if Panels[I].ParentBiDiMode then
        Panels[I].ParentBiDiModeChanged;
    UpdatePanels;
  end;
end;

procedure TdxCustomStatusBar.CMColorChanged(var Message: TMessage);
begin
  inherited;
  UpdatePanels;
end;

procedure TdxCustomStatusBar.CMEnabledChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TdxCustomStatusBar.CMParentFontChanged(var Message: TMessage);
begin
  inherited;
  UpdatePanels;
end;

procedure TdxCustomStatusBar.CMSysColorChange(var Message: TMessage);
begin
  inherited;
  RefreshOffice11Colors;
  UpdatePanels;
end;

procedure TdxCustomStatusBar.CMWinIniChange(var Message: TMessage);
begin
  inherited;
  UpdatePanels;
end;

procedure TdxCustomStatusBar.WMNCHitTest(var Message: TWMNCHitTest);
var
  P: TPoint;
  R: TRect;
begin
  inherited;
  if not (csDesigning in ComponentState) and SizeGripAllocated then
    with TWMNCHitTest(Message) do
    begin
      P := ScreenToClient(Point(XPos, YPos));
      with ClientBounds do
        R := Rect(Right - Painter.GripAreaSize.cx - 2,
          Bottom - Painter.GripAreaSize.cy - 2, Right, Bottom);
      if PtInRect(R, P) then
        Result := HTBOTTOMRIGHT;
    end;
end;

{ TdxStatusBarPainter }

class procedure TdxStatusBarPainter.AdjustTextColor(AStatusBar: TdxCustomStatusBar;
  var AColor: TColor; Active: Boolean);
begin                               
end;

class function TdxStatusBarPainter.BorderSizes(AStatusBar: TdxCustomStatusBar): TRect;
begin
  Result := Rect(AStatusBar.BorderWidth, AStatusBar.BorderWidth + TopBorderSize,
    AStatusBar.BorderWidth, AStatusBar.BorderWidth);
end;

class function TdxStatusBarPainter.DrawSizeGripFirst: Boolean;
begin
  Result := True;
end;

class function TdxStatusBarPainter.GripAreaSize: TSize;
begin
//  Result.cx := GetSystemMetrics(SM_CXHSCROLL);
//  Result.cy := GetSystemMetrics(SM_CYHSCROLL);
  Result.cx := GRIP_AREA_SIZE;
  Result.cy := GRIP_AREA_SIZE;
end;

class function TdxStatusBarPainter.GripSize: TSize;
begin
  Result.cx := GRIP_SIZE;
  Result.cy := GRIP_SIZE;
end;

class function TdxStatusBarPainter.IsNativeBackground: Boolean;
begin
  Result := False;
end;

class function TdxStatusBarPainter.SeparatorSize: Integer;
begin
  Result := PANELSEPARATORWIDTH;
end;

class function TdxStatusBarPainter.SeparatorSizeEx(
  AStatusBar: TdxCustomStatusBar): Integer;
begin
  Result := SeparatorSize;
end;

class function TdxStatusBarPainter.TopBorderSize: Integer;
begin
  Result := 2;
end;

class procedure TdxStatusBarPainter.DrawBorder(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; var R: TRect);
begin
  // top border
  DrawTopBorder(AStatusBar, ACanvas, Rect(R.Left, R.Top, R.Right, R.Top + TopBorderSize));
  Inc(R.Top, TopBorderSize);
  // border
  if AStatusBar.BorderWidth > 0 then
  begin
    ACanvas.Brush.Color := AStatusBar.Color;
    ACanvas.FillRect(Rect(R.Left, R.Top, R.Right, R.Top + AStatusBar.BorderWidth));
    Inc(R.Top, AStatusBar.BorderWidth);
    ACanvas.FillRect(Rect(R.Left, R.Bottom - AStatusBar.BorderWidth, R.Right, R.Bottom));
    Dec(R.Bottom, AStatusBar.BorderWidth);
    ACanvas.FillRect(Rect(R.Left, R.Top, R.Left + AStatusBar.BorderWidth, R.Bottom));
    Inc(R.Left, AStatusBar.BorderWidth);
    ACanvas.FillRect(Rect(R.Right - AStatusBar.BorderWidth, R.Top, R.Right, R.Bottom));
    Dec(R.Right, AStatusBar.BorderWidth);
  end;
end;

class procedure TdxStatusBarPainter.DrawEmptyPanel(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; R: TRect);
begin
  DrawPanelBorder(AStatusBar, dxpbLowered, ACanvas, R);
  FillBackground(AStatusBar, nil, ACanvas, R);
end;

class procedure TdxStatusBarPainter.DrawPanel(AStatusBar: TdxCustomStatusBar;
  APanel: TdxStatusBarPanel; ACanvas: TcxCanvas; R: TRect);

  function DoCustomDrawPanel(ACanvas: TcxCanvas; R: TRect): Boolean;
  begin
    Result := False;
    if Assigned(APanel.OnDrawPanel) then
      APanel.OnDrawPanel(APanel, ACanvas, R, Result);
  end;

begin
  if APanel = nil then
    DrawEmptyPanel(AStatusBar, ACanvas, R)
  else
    if not APanel.Visible then
      FillBackground(AStatusBar, nil, ACanvas, R)
    else
    begin
      if not IsSizeGripInPanel(AStatusBar) and (APanel.PanelStyle <> nil) then
        APanel.PanelStyle.CheckSizeGripRect(R);
      DrawPanelBorder(AStatusBar, GetPanelBevel(APanel), ACanvas, R);
      if not DoCustomDrawPanel(ACanvas, R) then
      begin
        if APanel.PanelStyle <> nil then
          APanel.PanelStyle.DrawContent(ACanvas, R, Self)
        else
          FillBackground(AStatusBar, APanel, ACanvas, R);
      end;
    end;
end;

class procedure TdxStatusBarPainter.DrawPanelBorder(AStatusBar: TdxCustomStatusBar;
  ABevel: TdxStatusBarPanelBevel; ACanvas: TcxCanvas; var R: TRect);
begin
end;

class procedure TdxStatusBarPainter.DrawPanelSeparator(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; const R: TRect);
begin
end;

class procedure TdxStatusBarPainter.DrawSizeGrip(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; R: TRect; AOverlapped: Boolean);
var
  ARect, AGripRect, R1, R2: TRect;
begin
  InflateRect(R, -1, -1);
  ARect := Rect(R.Right - GripAreaSize.cx, R.Bottom - GripAreaSize.cy, R.Right, R.Bottom);

  AGripRect := ARect;
  if AOverlapped then Inc(AGripRect.Right, 1);
  ACanvas.Brush.Color := AStatusBar.Color;
  ACanvas.FillRect(AGripRect);

  dxStatusBar.DrawSizeGrip(ACanvas.Handle, ARect);
  ACanvas.Brush.Color := AStatusBar.Color;
  R1 := Rect(R.Right - GripSize.cx, R.Bottom, R.Right + 1, R.Bottom + 1);
  ACanvas.FillRect(R1);
  R2 := Rect(R.Right, R.Bottom - GripSize.cy, R.Right + 1, R.Bottom);
  ACanvas.FillRect(R2);

  ACanvas.ExcludeClipRect(AGripRect);
  ACanvas.ExcludeClipRect(R1);
  ACanvas.ExcludeClipRect(R2);
end;

class procedure TdxStatusBarPainter.DrawTopBorder(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; const R: TRect);
begin
  ACanvas.Brush.Color := AStatusBar.Color;
  ACanvas.FillRect(R);
end;

class procedure TdxStatusBarPainter.FillBackground(AStatusBar: TdxCustomStatusBar;
  APanel: TdxStatusBarPanel; ACanvas: TcxCanvas; const R: TRect);
begin
end;

class function TdxStatusBarPainter.GetPanelBevel(APanel: TdxStatusBarPanel): TdxStatusBarPanelBevel;
begin
  if APanel <> nil then
  begin
    if (APanel.PanelStyle <> nil) and APanel.PanelStyle.InternalBevel then
      Result := dxpbNone
    else
      Result := APanel.Bevel;
  end
  else
    Result := dxpbLowered;
end;

class function TdxStatusBarPainter.GetPanelColor(AStatusBar: TdxCustomStatusBar;
  APanel: TdxStatusBarPanel): TColor;
begin
  if (APanel <> nil) and (APanel.PanelStyle <> nil) then
    Result := APanel.PanelStyle.Color
  else
    Result := AStatusBar.Color;
end;

class function TdxStatusBarPainter.ValidatePanelTextRect(AStatusBar: TdxCustomStatusBar;
  APanel: TdxStatusBarPanel; const R: TRect): TRect;
begin
  Result := R;
end;

class procedure TdxStatusBarPainter.DrawContainerControl(APanelStyle: TdxStatusBarContainerPanelStyle);
var
  AParentRect: TRect;
  AControl: TdxStatusBarContainerControl;
begin
  AParentRect := APanelStyle.StatusBarControl.ClientBounds;
  AControl := APanelStyle.Container;
  OffsetRect(AParentRect, -AControl.Left, -AControl.Top);
  DrawBorder(APanelStyle.StatusBarControl, AControl.Canvas, AParentRect);
  FillBackground(APanelStyle.StatusBarControl, APanelStyle.Owner, AControl.Canvas, AControl.ClientRect);
end;

class function TdxStatusBarPainter.IsSizeGripInPanel(AStatusBar: TdxCustomStatusBar): Boolean;
begin
  Result := True;
end;

{ TdxStatusBarStandardPainter }

class procedure TdxStatusBarStandardPainter.DrawPanelBorder(AStatusBar: TdxCustomStatusBar;
  ABevel: TdxStatusBarPanelBevel; ACanvas: TcxCanvas; var R: TRect);
const
  ABorders: array [TdxStatusBarPanelBevel] of Integer = (0, BDR_SUNKENOUTER, BDR_RAISEDINNER);
begin
  DrawEdge(ACanvas.Handle, R, ABorders[ABevel], BF_RECT or BF_ADJUST);
end;

class procedure TdxStatusBarStandardPainter.DrawPanelSeparator(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; const R: TRect);
begin
  ACanvas.Brush.Color := AStatusBar.Color;
  ACanvas.FillRect(R);
end;

class procedure TdxStatusBarStandardPainter.FillBackground(AStatusBar: TdxCustomStatusBar;
  APanel: TdxStatusBarPanel; ACanvas: TcxCanvas; const R: TRect);
begin
  ACanvas.Brush.Color := GetPanelColor(AStatusBar, APanel);
  ACanvas.FillRect(R);
end;

{ TdxStatusBarFlatPainter }

class procedure TdxStatusBarFlatPainter.DrawPanelBorder(AStatusBar: TdxCustomStatusBar;
  ABevel: TdxStatusBarPanelBevel; ACanvas: TcxCanvas; var R: TRect);
begin
  if ABevel <> dxpbNone then
  begin
    ACanvas.Brush.Color := clBtnShadow;
    ACanvas.FrameRect(R);
    InflateRect(R, -1, -1);
  end;
end;

{ TdxStatusBarOffice11Painter }

class function TdxStatusBarOffice11Painter.BorderSizes(AStatusBar: TdxCustomStatusBar): TRect;
begin
  Result := Rect(1, 1, 1, 1);
end;

class procedure TdxStatusBarOffice11Painter.DrawBorder(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; var R: TRect);
begin
  FillTubeGradientRect(ACanvas.Handle, R, dxOffice11ToolbarsColor1, dxOffice11ToolbarsColor2, False);
  InflateRect(R, -1, -1);
end;

class procedure TdxStatusBarOffice11Painter.DrawPanelBorder(AStatusBar: TdxCustomStatusBar;
  ABevel: TdxStatusBarPanelBevel; ACanvas: TcxCanvas; var R: TRect);
begin
  if ABevel <> dxpbNone then
  begin
    ACanvas.Brush.Color := GetMiddleRGB(dxOffice11ToolbarsColor2, clBlack{clBtnShadow}, 90);
    ACanvas.FrameRect(R);
    InflateRect(R, -1, -1);
  end;
end;

class procedure TdxStatusBarOffice11Painter.DrawPanelSeparator(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; const R: TRect);
var
  ARect: TRect;
begin
exit;
  ARect := R;
  InflateRect(ARect, 0, -2);
  with ARect do
  begin
    FillRect(ACanvas.Handle, Rect(Left, Top, Left + 1, Bottom - 1), dxOffice11BarSeparatorBrush1);
    FillRect(ACanvas.Handle, Rect(Left + 1, Top + 1, Left + 2, Bottom), dxOffice11BarSeparatorBrush2);
  end;
end;

class procedure TdxStatusBarOffice11Painter.DrawSizeGrip(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; R: TRect; AOverlapped: Boolean);
var
  ARect, AGripRect: TRect;
begin
  InflateRect(R, 0, -1);
  ARect := Rect(R.Right - GripAreaSize.cx, R.Bottom - GripAreaSize.cy, R.Right, R.Bottom);

  AGripRect := ARect;
  if not AOverlapped then Dec(AGripRect.Right, 1);

  Office11DrawSizeGrip(ACanvas.Handle, ARect);

  ACanvas.ExcludeClipRect(AGripRect);
end;

{ TdxStatusBarXPPainter }

class function TdxStatusBarXPPainter.BorderSizes(AStatusBar: TdxCustomStatusBar): TRect;
begin
  Result := Rect(0, TopBorderSize, 0, 0);
end;

class function TdxStatusBarXPPainter.GripAreaSize: TSize;
var
  ATheme: TdxTheme;
  DC: HDC;
begin
  ATheme := OpenTheme(totStatus);
  DC := GetDC(0);
  GetThemePartSize(ATheme, DC, SP_GRIPPER, 0, nil, TS_TRUE, @Result);
  ReleaseDC(0, DC);
end;

class function TdxStatusBarXPPainter.SeparatorSize: Integer;
var
  ATheme: TdxTheme;
  DC: HDC;
  ASize: TSize;
begin
  ATheme := OpenTheme(totStatus);
  DC := GetDC(0);
  GetThemePartSize(ATheme, DC, SP_PANE, 0, nil, TS_TRUE, @ASize);
  Result := ASize.cx;
  ReleaseDC(0, DC);
end;

class procedure TdxStatusBarXPPainter.DrawBorder(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; var R: TRect);
var
  ATheme: TdxTheme;
begin
  ATheme := OpenTheme(totStatus);
  DrawThemeBackground(ATheme, ACanvas.Handle, 0, 0, @R);
  Inc(R.Top, TopBorderSize);
end;

class procedure TdxStatusBarXPPainter.DrawPanelSeparator(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; const R: TRect);
var
  ATheme: TdxTheme;
begin
  ATheme := OpenTheme(totStatus);
  DrawThemeBackground(ATheme, ACanvas.Handle, SP_PANE, 0, @R);
end;

class procedure TdxStatusBarXPPainter.DrawSizeGrip(AStatusBar: TdxCustomStatusBar;
  ACanvas: TcxCanvas; R: TRect; AOverlapped: Boolean);
var
  ATheme: TdxTheme;
  ARect, AGripRect: TRect;
begin
  ATheme := OpenTheme(totStatus);
  InflateRect(R, -1, 0);
  ARect := Rect(R.Right - GripAreaSize.cx, R.Bottom - GripAreaSize.cy, R.Right, R.Bottom);

  AGripRect := ARect;
  if AOverlapped then Inc(AGripRect.Right, 1);

  DrawThemeBackground(ATheme, ACanvas.Handle, SP_GRIPPER, 0, @ARect);

  ACanvas.ExcludeClipRect(AGripRect);
end;

initialization
  GetRegisteredStatusBarPanelStyles.Register(TdxStatusBarTextPanelStyle, cxSTextPanelStyle);
  GetRegisteredStatusBarPanelStyles.Register(TdxStatusBarContainerPanelStyle, cxSContainerPanelStyle);
  GetRegisteredStatusBarPanelStyles.Register(TdxStatusBarKeyboardStatePanelStyle, cxSKeyboardStatePanelStyle);
  GetRegisteredStatusBarPanelStyles.Register(TdxStatusBarStateIndicatorPanelStyle, cxSStateIndicatorPanelStyle);
  RegisterClasses([TdxStatusBarContainerControl]);

finalization
  GetRegisteredStatusBarPanelStyles.Unregister(TdxStatusBarTextPanelStyle);
  GetRegisteredStatusBarPanelStyles.Unregister(TdxStatusBarContainerPanelStyle);
  GetRegisteredStatusBarPanelStyles.Unregister(TdxStatusBarKeyboardStatePanelStyle);
  GetRegisteredStatusBarPanelStyles.Unregister(TdxStatusBarStateIndicatorPanelStyle);
  FreeAndNil(FRegisteredStatusBarPanelStyles);

end.
