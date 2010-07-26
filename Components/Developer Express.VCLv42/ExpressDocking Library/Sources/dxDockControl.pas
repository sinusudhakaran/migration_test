
{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressDocking                                              }
{                                                                   }
{       Copyright (c) 2002-2009 Developer Express Inc.              }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSDOCKING AND ALL ACCOMPANYING  }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.             }
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

unit dxDockControl;

{$I cxVer.inc}

interface

uses
  Windows, Graphics, Classes, Controls, ExtCtrls, Messages,
  Forms, Menus, ImgList, IniFiles, dxDockConsts,
  dxCore, cxClasses, cxLookAndFeels, cxControls, cxGraphics;

type
  TdxDockingState = (dsDestroyed, dsUndocked, dsHidden, dsDocked, dsFloating);
  TdxDockingTypeEx = (dtNone, dtClient, dtLeft, dtTop, dtRight, dtBottom);
  TdxDockingType = dtClient..dtBottom;
  TdxDockingTypes = set of TdxDockingType;
  TdxZoneDirection = (zdUndefined, zdVertical, zdHorizontal);
  TdxZoneKind = (zkDocking, zkResizing);
  TdxAutoHidePosition = (ahpLeft, ahpTop, ahpRight, ahpBottom, ahpUndefined);
  TdxCaptionButton = (cbMaximize, cbHide, cbClose);
  TdxCaptionButtons = set of TdxCaptionButton;
  TdxTabContainerTabsPosition = (tctpTop, tctpBottom);

  TdxDockingOption =
    (doActivateAfterDocking, doDblClickDocking, doFloatingOnTop, doFreeOnClose, doUndockOnClose,
    doTabContainerHasCaption, doTabContainerCanClose, doTabContainerCanAutoHide,
    doSideContainerHasCaption, doSideContainerCanClose, doSideContainerCanAutoHide,
    doTabContainerCanInSideContainer, doSideContainerCanInTabContainer, doSideContainerCanInSideContainer,
    doImmediatelyHideOnAutoHide, doHideAutoHideIfActive,
    doRedrawOnResize, doFillDockingSelection, doUseCaptionAreaToClientDocking);
  TdxDockingOptions = set of TdxDockingOption;
  TdxDockingViewStyle = (vsStandard, vsNET, vsOffice11, vsXP, vsUseLookAndFeel);

const
  WM_DESTROYCONTROLS = WM_DX + 1;
  dxDockingDefaultDockingTypes = [dtClient, dtLeft, dtTop, dtRight, dtBottom];
  dxDockinkDefaultCaptionButtons = [cbMaximize, cbHide, cbClose];
  dxDockingDefaultOptions =
    [doActivateAfterDocking, doDblClickDocking, doFloatingOnTop, doTabContainerCanAutoHide,
    doTabContainerHasCaption, doSideContainerCanClose, doSideContainerCanAutoHide,
    doTabContainerCanInSideContainer, doRedrawOnResize];

type
  TdxDockingManager = class;
  TdxDockingController = class;
  TdxCustomDockControl = class;
  TdxCustomDockControlClass = class of TdxCustomDockControl;
  TdxDockControlPainter = class;
  TdxDockControlPainterClass = class of TdxDockControlPainter;
  TdxLayoutDockSite = class;
  TdxContainerDockSite = class;
  TdxContainerDockSiteClass = class of TdxContainerDockSite;
  TdxTabContainerDockSite = class;
  TdxSideContainerDockSite = class;
  TdxSideContainerDockSiteClass = class of TdxSideContainerDockSite;
  TdxFloatDockSite = class;
  TdxFloatForm = class;
  TdxFloatFormClass = class of TdxFloatForm;
  TdxDockSite = class;
  TdxDockSiteAutoHideContainer = class;

  TdxDockingDragImage = class(TcxSizeFrame);

  TdxZone = class
  private
    FKind: TdxZoneKind;
    FOwner: TdxCustomDockControl;
    FWidth: Integer;
  protected
    function GetDirection: TdxZoneDirection; virtual; abstract;
    function GetDockIndex: Integer; virtual;
    function GetDockType: TdxDockingType; virtual; abstract;
    function GetRectangle: TRect; virtual; abstract;
    function GetSelectionFrameWidth: Integer; virtual;
    function GetWidth: Integer; virtual;

    function CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean; virtual;
  public
    constructor Create(AOwner: TdxCustomDockControl; AWidth: Integer; AKind: TdxZoneKind);

    function CanDock(AControl: TdxCustomDockControl): Boolean; virtual;
    function CanResize(StartPoint, EndPoint: TPoint): Boolean; virtual;
    function GetDockingSelection(AControl: TdxCustomDockControl): TRect; virtual;
    function GetResizingSelection(pt: TPoint): TRect; virtual;
    function IsZonePoint(pt: TPoint): Boolean; virtual;

    procedure DoDock(AControl: TdxCustomDockControl); virtual;
    procedure DoResize(StartPoint, EndPoint: TPoint); virtual;
    procedure DrawDockingSelection(DC: HDC; AControl: TdxCustomDockControl; pt: TPoint); virtual;
    procedure DrawResizingSelection(DC: HDC; pt: TPoint); virtual;
    procedure PrepareSelectionRegion(ARegion: TcxRegion; AControl: TdxCustomDockControl; const ARect: TRect); virtual;

    class function ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean; virtual;
    class function ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean; virtual;

    property Direction: TdxZoneDirection read GetDirection;
    property DockType: TdxDockingType read GetDockType;
    property DockIndex: Integer read GetDockIndex;
    property Kind: TdxZoneKind read FKind;
    property Owner: TdxCustomDockControl read FOwner;
    property Rectangle: TRect read GetRectangle;
    property SelectionFrameWidth: Integer read GetSelectionFrameWidth;
    property Width: Integer read GetWidth;
  end;

  TdxDockPosition = record
    DockIndex: Integer;
    DockType: TdxDockingType;
    OriginalHeight: Integer;
    OriginalWidth: Integer;
    Parent: TdxCustomDockControl;
    SiblingAfter: TdxCustomDockControl;
    SiblingBefore: TdxCustomDockControl;
  end;

  TdxActivateEvent = procedure (Sender: TdxCustomDockControl; Active: Boolean) of object;
  TdxCanDockingEvent = procedure (Sender, Source: TdxCustomDockControl; Zone: TdxZone;
    X, Y: Integer; var Accept: Boolean) of object;
  TdxCanResizeEvent = procedure(Sender: TdxCustomDockControl; NewWidth, NewHeight: Integer;
    var Resize: Boolean) of object;
  TdxCreateFloatSiteEvent = procedure (Sender: TdxCustomDockControl;
    AFloatSite: TdxFloatDockSite) of object;
  TdxCreateLayoutSiteEvent = procedure (Sender: TdxCustomDockControl;
    ALayoutSite: TdxLayoutDockSite) of object;
  TdxCreateSideContainerEvent = procedure (Sender: TdxCustomDockControl;
    ASideContainer: TdxSideContainerDockSite) of object;
  TdxCreateTabContainerEvent = procedure (Sender: TdxCustomDockControl;
    ATabContainer: TdxTabContainerDockSite) of object;
  TdxCustomDrawSelectionEvent = procedure (Sender: TdxCustomDockControl; DC: HDC;
    Zone: TdxZone; ARect: TRect; Erasing: Boolean; var Handled: Boolean) of object;
  TdxDockControlCloseQueryEvent = procedure (Sender: TdxCustomDockControl;
    var CanClose: Boolean) of object;
  TdxDockControlNotifyEvent = procedure (Sender: TdxCustomDockControl) of object;
  TdxDockEvent = procedure (Sender, Site: TdxCustomDockControl; ADockType: TdxDockingType;
    AIndex: Integer) of object;
  TdxDockingEvent = procedure (Sender: TdxCustomDockControl; Zone: TdxZone;
    X, Y: Integer; var Accept: Boolean) of object;
  TdxEndDockingEvent = procedure (Sender: TdxCustomDockControl; Zone: TdxZone;
    X, Y: Integer) of object;
  TdxGetAutoHidePositionEvent = procedure (Sender: TdxCustomDockControl;
    var APosition: TdxAutoHidePosition) of object;
  TdxDockPositionEvent = procedure (Sender: TdxCustomDockControl;
    var APosition: TdxDockPosition) of object;
  TdxUpdateZonesEvent = procedure (Sender: TdxCustomDockControl; AZones: TList) of object;

  TdxMakeFloatingEvent = procedure (Sender: TdxCustomDockControl; X, Y: Integer) of object;
  TdxResizingEvent = procedure (Sender: TdxCustomDockControl; Zone: TdxZone; X, Y: Integer) of object;
  TdxStartDockingEvent = procedure (Sender: TdxCustomDockControl; X, Y: Integer) of object;
  TdxUnDockEvent = procedure (Sender, Site: TdxCustomDockControl) of object;
  TdxDockControlInternalState = (dcisCreating, dcisDestroying, dcisDestroyed, dcisInternalResizing, dcisFrameChanged, dcisLayoutLoading);
  TdxDockControlInternalStates = set of TdxDockControlInternalState;

  TdxCustomDockControl = class(TCustomControl)
  private
    FAllowDock: TdxDockingTypes;
    FAllowDockClients: TdxDockingTypes;
    FAllowFloating: Boolean;
    FAutoHide: Boolean;
    FAutoHidePosition: TdxAutoHidePosition;
    FCaptionButtons: TdxCaptionButtons;
    FCursorPoint: TPoint;
    FDockable: Boolean;
    FDockControls: TList;
    FDockingOrigin: TPoint;
    FDockingPoint: TPoint;
    FDockingTargetZone: TdxZone;
    FDockType: TdxDockingTypeEx;
    FDockZones: TList;
    FImageIndex: Integer;
    FInternalState: TdxDockControlInternalStates;
    FManagerColor: Boolean;
    FManagerFont: Boolean;
    FOriginalHeight: Integer;
    FOriginalWidth: Integer;
    FPainter: TdxDockControlPainter;
    FParentDockControl: TdxCustomDockControl;
    FRecalculateNCNeeded: Boolean;
    FResizeZones: TList;
    FResizingOrigin: TPoint;
    FResizingPoint: TPoint;
    FResizingSourceZone: TdxZone;
    FSavedCaptureControl: TControl;
    FShowCaption: Boolean;
    FSourcePoint: TPoint;
    FUpdateLayoutLock: Integer;
    FUpdateVisibilityLock: Integer;

    FCaptionIsDown: Boolean;
    FCloseButtonIsDown: Boolean;
    FCloseButtonIsHot: Boolean;
    FHideButtonIsDown: Boolean;
    FHideButtonIsHot: Boolean;
    FMaximizeButtonIsDown: Boolean;
    FMaximizeButtonIsHot: Boolean;
    FCaptionRect: TRect;
    FCaptionSeparatorRect: TRect;
    FCaptionTextRect: TRect;
    FCaptionCloseButtonRect: TRect;
    FCaptionHideButtonRect: TRect;
    FCaptionMaximizeButtonRect: TRect;
    FSavedClientRect: TRect;
    FStoredAutoHide: Boolean;
    FStoredPosition: TdxDockPosition;
    FUseDoubleBuffer: Boolean;
    FWindowRect: TRect;

    FOnActivate: TdxActivateEvent;
    FOnAutoHideChanging: TdxDockControlNotifyEvent;
    FOnAutoHideChanged: TdxDockControlNotifyEvent;
    FOnCanResize: TdxCanResizeEvent;
    FOnClose: TdxDockControlNotifyEvent;
    FOnCloseQuery: TdxDockControlCloseQueryEvent;
    FOnCanDocking: TdxCanDockingEvent;
    FOnCreateFloatSite: TdxCreateFloatSiteEvent;
    FOnCreateLayoutSite: TdxCreateLayoutSiteEvent;
    FOnCreateSideContainer: TdxCreateSideContainerEvent;
    FOnCreateTabContainer: TdxCreateTabContainerEvent;
    FOnCustomDrawDockingSelection: TdxCustomDrawSelectionEvent;
    FOnCustomDrawResizingSelection: TdxCustomDrawSelectionEvent;
    FOnDock: TdxDockEvent;
    FOnDocking: TdxDockingEvent;
    FOnEndDocking: TdxEndDockingEvent;
    FOnEndResizing: TdxResizingEvent;
    FOnGetAutoHidePosition: TdxGetAutoHidePositionEvent;
    FOnLayoutChanged: TdxDockControlNotifyEvent;
    FOnMakeFloating: TdxMakeFloatingEvent;
    FOnParentChanged: TdxDockControlNotifyEvent;
    FOnParentChanging: TdxDockControlNotifyEvent;
    FOnResizing: TdxResizingEvent;
    FOnRestoreDockPosition: TdxDockPositionEvent;
    FOnStartDocking: TdxStartDockingEvent;
    FOnStartResizing: TdxResizingEvent;
    FOnStoreDockPosition: TdxDockPositionEvent;
    FOnUnDock: TdxUnDockEvent;
    FOnUpdateDockZones: TdxUpdateZonesEvent;
    FOnUpdateResizeZones: TdxUpdateZonesEvent;
    FOnVisibleChanged: TdxDockControlNotifyEvent;
    FOnVisibleChanging: TdxDockControlNotifyEvent;

    procedure ClearDockType;
    procedure ClearChildrenParentDockControl;
    function IsColorStored: Boolean;
    function IsFontStored: Boolean;
    function IsInternalDestroying: Boolean;
    function GetActive: Boolean;
    function GetController: TdxDockingController;
    function GetDockIndex: Integer;
    function GetDockLevel: Integer;
    function GetDockingRect: TRect;
    function GetDockState: TdxDockingState;
    function GetChild(Index: Integer): TdxCustomDockControl;
    function GetChildCount: Integer;
    function GetImages: TCustomImageList;
    function GetPainter: TdxDockControlPainter;
    function GetPopupParent: TCustomForm;
    function GetTempCanvas: TCanvas;
    function GetValidChildCount: Integer;
    function GetValidChild(Index: Integer): TdxCustomDockControl;
    procedure SetAllowDock(const Value: TdxDockingTypes);
    procedure SetAllowDockClients(const Value: TdxDockingTypes);
    procedure SetAllowFloating(const Value: Boolean);
    procedure SetAutoHide(const Value: Boolean);
    procedure SetCaptionButtons(Value: TdxCaptionButtons);
    procedure SetDockable(const Value: Boolean);
    procedure SetDockType(Value: TdxDockingType);
    procedure SetDockingParams(ADockingTargetZone: TdxZone; const ADockingPoint: TPoint);
    procedure SetImageIndex(const Value: Integer);
    procedure SetManagerColor(const Value: Boolean);
    procedure SetManagerFont(const Value: Boolean);
    procedure SetParentDockControl(Value: TdxCustomDockControl);
    procedure SetShowCaption(const Value: Boolean);
    procedure SetUseDoubleBuffer(const Value: Boolean);

    procedure ReadAutoHidePosition(Reader: TReader);
    procedure ReadDockType(Reader: TReader);
    procedure ReadOriginalWidth(Reader: TReader);
    procedure ReadOriginalHeight(Reader: TReader);
    procedure WriteAutoHidePosition(Writer: TWriter);
    procedure WriteDockType(Writer: TWriter);
    procedure WriteOriginalWidth(Writer: TWriter);
    procedure WriteOriginalHeight(Writer: TWriter);

    procedure AddDockControl(AControl: TdxCustomDockControl; AIndex: Integer);
    procedure RemoveDockControl(AControl: TdxCustomDockControl);
    function IndexOfControl(AControl: TdxCustomDockControl): Integer;
    procedure ClearZones(AZones: TList);

    procedure CMDesignHitTest(var Message: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure CNKeyUp(var Message: TWMKeyUp); message CN_KEYUP;
    {$IFDEF DELPHI5}
    procedure WMContextMenu(var Message: TWMContextMenu); message WM_CONTEXTMENU;
    {$ENDIF}
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
    procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    FDesignHelper: IcxDesignHelper;

    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoEnter; override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ReadState(Reader: TReader); override;
    procedure SetParent(AParent: TWinControl); override;
    procedure VisibleChanging; override;

    function CanFocusEx: Boolean; virtual;
    function IsDockPanel: Boolean; virtual;

    function IsAncestor: Boolean;
    function IsDesigning: Boolean;
    function IsDestroying: Boolean;
    function IsLoading: Boolean;
    procedure CaptureMouse;
    procedure ReleaseMouse;
    // Designer
    function GetDesignRect: TRect; virtual;
    function GetDesignHitTest(const APoint: TPoint; AShift: TShiftState): Boolean; dynamic;
    function IsSelected: Boolean;
    procedure Modified;
    procedure NoSelection;
    procedure SelectComponent(AComponent: TComponent);
    function UniqueName: string;
    // Resizing
    function CanResizing(NewWidth, NewHeight: Integer): Boolean; virtual;
    function CanResizeAtPos(pt: TPoint): Boolean; virtual;
    procedure DoStartResize(pt: TPoint);
    procedure DoEndResize(pt: TPoint);
    procedure DoResizing(pt: TPoint);

    procedure DrawResizingSelection(AZone: TdxZone; pt: TPoint; Erasing: Boolean);
    procedure StartResize(pt: TPoint); virtual;
    procedure Resizing(pt: TPoint); virtual;
    procedure EndResize(pt: TPoint; Cancel: Boolean); virtual;
    // Resizing zones
    procedure DoUpdateResizeZones;
    procedure UpdateControlResizeZones(AControl: TdxCustomDockControl); virtual;
    procedure UpdateResizeZones;
    // Docking
    function CanUndock(AControl: TdxCustomDockControl): Boolean; virtual;
    function GetDockingTargetControlAtPos(pt: TPoint): TdxCustomDockControl;
    function GetFloatDockRect(pt: TPoint): TRect;
    procedure DoStartDocking(pt: TPoint);
    procedure DoEndDocking(pt: TPoint);
    procedure DoCanDocking(Source: TdxCustomDockControl; pt: TPoint; TargetZone: TdxZone; var Accept: Boolean);
    procedure DoDocking(pt: TPoint; TargetZone: TdxZone; var Accept: Boolean);

    procedure DrawDockingSelection(AZone: TdxZone; const pt: TPoint; AErasing: Boolean);
    procedure PrepareSelectionRegion(ARegion: TcxRegion; const ARect: TRect);
    procedure StartDocking(pt: TPoint); virtual;
    procedure Docking(pt: TPoint); virtual;
    procedure EndDocking(pt: TPoint; Cancel: Boolean); virtual;
    procedure CheckDockRules; virtual;
    procedure CheckDockClientsRules; virtual;
    // Docking zones
    procedure DoUpdateDockZones;
    procedure UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer); virtual;
    procedure UpdateDockZones;
    // Control layout
    procedure DoParentChanged;
    procedure DoParentChanging;
    procedure UpdateState; virtual;

    procedure IncludeToDock(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); virtual;
    procedure ExcludeFromDock; virtual;
    procedure CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); virtual;
    procedure DestroyChildLayout; virtual;
    procedure DestroyLayout(AControl: TdxCustomDockControl); virtual;
    procedure RemoveFromLayout; virtual;
    procedure UpdateLayout; virtual;
    procedure DoLayoutChanged;
    procedure BeginUpdateLayout;
    procedure EndUpdateLayout(AForceUpdate: Boolean = True);
    function IsUpdateLayoutLocked: Boolean;
    procedure LoadLayoutFromCustomIni(AIniFile: TCustomIniFile; AParentForm: TCustomForm;
      AParentControl: TdxCustomDockControl; ASection: string); virtual;
    procedure SaveLayoutToCustomIni(AIniFile: TCustomIniFile; ASection: string); virtual;
    property UpdateLayoutLock: Integer read FUpdateLayoutLock;

    function HasAsParent(AControl: TdxCustomDockControl): Boolean;
    function GetParentDockControl: TdxCustomDockControl; virtual;
    function GetParentForm: TCustomForm; virtual;
    function GetParentFormActive: Boolean; virtual;
    function GetParentFormVisible: Boolean; virtual;
    function GetTopMostDockControl: TdxCustomDockControl; virtual;
    // Layout site
    procedure AssignLayoutSiteProperties(ASite: TdxLayoutDockSite); virtual;
    procedure DoCreateLayoutSite(ASite: TdxLayoutDockSite);
    function GetLayoutDockSite: TdxLayoutDockSite; virtual;
    // Container site
    procedure CreateContainerLayout(AContainer: TdxContainerDockSite;
      AControl: TdxCustomDockControl; AType: TdxDockingType; Index: Integer);
    function GetContainer: TdxContainerDockSite; virtual;
    // SideContainer site
    procedure AssignSideContainerSiteProperties(ASite: TdxSideContainerDockSite); virtual;
    function CanAcceptSideContainerItems(AContainer: TdxSideContainerDockSite): Boolean; virtual;
    procedure DoCreateSideContainerSite(ASite: TdxSideContainerDockSite);
    procedure CreateSideContainerLayout(AControl: TdxCustomDockControl;
      AType: TdxDockingType; Index: Integer); virtual;
    procedure DoMaximize; virtual;
    function GetSideContainer: TdxSideContainerDockSite; virtual;
    function GetSideContainerItem: TdxCustomDockControl; virtual;
    function GetSideContainerIndex: Integer; virtual;
    function GetMinimizedHeight: Integer; virtual;
    function GetMinimizedWidth: Integer; virtual;
    // TabContainer site
    procedure AssignTabContainerSiteProperies(ASite: TdxTabContainerDockSite); virtual;
    function CanAcceptTabContainerItems(AContainer: TdxTabContainerDockSite): Boolean; virtual;
    procedure DoCreateTabContainerSite(ASite: TdxTabContainerDockSite);
    procedure CreateTabContainerLayout(AControl: TdxCustomDockControl;
      AType: TdxDockingType; Index: Integer); virtual;
    function GetTabWidth(ACanvas: TCanvas): Integer;
    function GetTabContainer: TdxTabContainerDockSite; virtual;
    // AutoHide
    procedure AutoHideChanged; virtual;
    procedure DoAutoHideChanged;
    procedure DoAutoHideChanging;
    function GetControlAutoHidePosition(AControl: TdxCustomDockControl): TdxAutoHidePosition; virtual;
    function GetAutoHideHostSite: TdxDockSite; virtual;
    function GetAutoHideContainer: TdxDockSiteAutoHideContainer; virtual;
    function GetAutoHideControl: TdxCustomDockControl; virtual;
    function GetAutoHidePosition: TdxAutoHidePosition;
    procedure ChangeAutoHide; virtual;
    // AutoSize
    function GetAutoSizeHostSite: TdxDockSite; virtual;
    // Floating site
    procedure AssignFloatSiteProperties(ASite: TdxFloatDockSite); virtual;
    procedure DoCreateFloatSite(ASite: TdxFloatDockSite);
    function GetFloatDockSite: TdxFloatDockSite; virtual;
    function GetFloatForm: TdxFloatForm; virtual;
    function GetFloatFormActive: Boolean; virtual;
    function GetFloatFormVisible: Boolean; virtual;
    procedure StoreDockPosition(pt: TPoint); virtual;
    procedure RestoreDockPosition(pt: TPoint); virtual;
    // Caption
    procedure UpdateCaption; virtual;
    // Control bounds
    procedure AdjustControlBounds(AControl: TdxCustomDockControl); virtual;
    procedure SetSize(AWidth, AHeight: Integer);
    procedure UpdateControlOriginalSize(AControl: TdxCustomDockControl); virtual;
    procedure UpdateOriginalSize;
    // Activation
    procedure CheckActiveDockControl; virtual;
    procedure DoActivate; virtual;
    procedure DoActiveChanged(AActive, ACallEvent: Boolean); virtual;
    // Closing
    procedure DoClose; virtual;
    // Destroying
    function CanDestroy: Boolean; virtual;
    procedure DoDestroy; virtual;
    // Control visibility
    procedure ChildVisibilityChanged(Sender: TdxCustomDockControl); virtual;
    procedure DoVisibleChanged; virtual;
    procedure DoVisibleChanging;
    procedure BeginUpdateVisibility;
    procedure EndUpdateVisibility;
    procedure SetVisibility(Value: Boolean);
    procedure UpdateAutoHideControlsVisibility; virtual;
    procedure UpdateAutoHideHostSiteVisibility; virtual;
    procedure UpdateLayoutControlsVisibility; virtual;
    procedure UpdateParentControlsVisibility; virtual;
    procedure UpdateRelatedControlsVisibility; virtual;
    property UpdateVisibilityLock: Integer read FUpdateVisibilityLock;
    // Controller properties
    function ControllerAutoHideInterval: Integer;
    function ControllerAutoHideMovingInterval: Integer;
    function ControllerAutoHideMovingSize: Integer;
    function ControllerAutoShowInterval: Integer;
    function ControllerColor: TColor;
    function ControllerDockZonesWidth: Integer;
    function ControllerFont: TFont;
    function ControllerImages: TCustomImageList;
    function ControllerOptions: TdxDockingOptions;
    function ControllerViewStyle: TdxDockingViewStyle;
    function ControllerResizeZonesWidth: Integer;
    function ControllerSelectionFrameWidth: Integer;
    function ControllerTabsScrollInterval: Integer;

    // Painting
    procedure Paint; override;

    procedure CheckTempCanvas(ARect: TRect);
    function ClientToWindow(pt: TPoint): TPoint;
    function ScreenToWindow(pt: TPoint): TPoint;
    function WindowRectToClient(const R: TRect): TRect;
    function WindowToClient(pt: TPoint): TPoint;
    function WindowToScreen(pt: TPoint): TPoint;
    procedure CalculateNC(var ARect: TRect); virtual;
    procedure DoDrawClient(ACanvas: TCanvas; const R: TRect); virtual;
    procedure DrawDesignRect;
    procedure InvalidateCaptionArea; virtual;
    procedure InvalidateNC(ANeedRecalculate: Boolean);
    procedure NCChanged(AImmediately: Boolean = False);
    procedure Recalculate; virtual;
    procedure Redraw(AWithChildren: Boolean);
    procedure BeginUpdateNC(ALockRedraw: Boolean = True);
    procedure EndUpdateNC;
    function CanUpdateNC: Boolean;
    function CanCalculateNC: Boolean;
    function HasBorder: Boolean; virtual;
    function HasCaption: Boolean; virtual;
    function HasCaptionCloseButton: Boolean; virtual;
    function HasCaptionHideButton: Boolean; virtual;
    function HasCaptionMaximizeButton: Boolean; virtual;
    function HasTabs: Boolean; virtual;
    function IsCaptionActive: Boolean; virtual;
    function IsCaptionVertical: Boolean; virtual;
    function IsCaptionPoint(pt: TPoint): Boolean;
    function IsCaptionCloseButtonPoint(pt: TPoint): Boolean;
    function IsCaptionHideButtonPoint(pt: TPoint): Boolean;
    function IsCaptionMaximizeButtonPoint(pt: TPoint): Boolean;
    procedure NCPaint(ACanvas: TCanvas); virtual;
    procedure NCPaintCaption(ACanvas: TCanvas); virtual;
    function NeedInvalidateCaptionArea: Boolean; virtual;
    property Painter: TdxDockControlPainter read GetPainter;
    // Rectangles
    property CaptionRect: TRect read FCaptionRect;
    property CaptionSeparatorRect: TRect read FCaptionSeparatorRect;
    property CaptionTextRect: TRect read FCaptionTextRect;
    property CaptionCloseButtonRect: TRect read FCaptionCloseButtonRect;
    property CaptionHideButtonRect: TRect read FCaptionHideButtonRect;
    property CaptionMaximizeButtonRect: TRect read FCaptionMaximizeButtonRect;
    property WindowRect: TRect read FWindowRect;

    property CaptionIsDown: Boolean read FCaptionIsDown;
    property CloseButtonIsDown: Boolean read FCloseButtonIsDown;
    property CloseButtonIsHot: Boolean read FCloseButtonIsHot;
    property HideButtonIsDown: Boolean read FHideButtonIsDown;
    property HideButtonIsHot: Boolean read FHideButtonIsHot;
    property MaximizeButtonIsDown: Boolean read FMaximizeButtonIsDown;
    property MaximizeButtonIsHot: Boolean read FMaximizeButtonIsHot;

    property CursorPoint: TPoint read FCursorPoint write FCursorPoint;
    property DockingOrigin: TPoint read FDockingOrigin;
    property DockingPoint: TPoint read FDockingPoint;
    property DockingRect: TRect read GetDockingRect;
    property DockingTargetZone: TdxZone read FDockingTargetZone;
    property ResizingOrigin: TPoint read FResizingOrigin;
    property ResizingPoint: TPoint read FResizingPoint;
    property ResizingSourceZone: TdxZone read FResizingSourceZone;
    property SourcePoint: TPoint read FSourcePoint write FSourcePoint;

    property StoredAutoHide: Boolean read FStoredAutoHide;
    property StoredPosition: TdxDockPosition read FStoredPosition;

    property TempCanvas: TCanvas read GetTempCanvas;
    property PopupParent: TCustomForm read GetPopupParent;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeforeDestruction; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    procedure Activate; virtual;
    function CanActive: Boolean; virtual;
    function CanAutoHide: Boolean; virtual;
    function CanDock: Boolean; virtual;
    function CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean; virtual;
    function CanMaximize: Boolean; virtual;
    function GetDockZoneAtPos(AControl: TdxCustomDockControl; pt: TPoint): TdxZone; virtual;
    function GetResizeZoneAtPos(pt: TPoint): TdxZone; virtual;
    function IsNeeded: Boolean; virtual;
    function IsValidChild(AControl: TdxCustomDockControl): Boolean; virtual;

    procedure Close;
    procedure MakeFloating; overload; virtual; 
    procedure MakeFloating(XPos, YPos: Integer); {$IFNDEF CBUILDER6} reintroduce; overload; {$ELSE} overload; virtual;{$ENDIF} 
    procedure DockTo(AControl: TdxCustomDockControl; AType: TdxDockingType; AIndex: Integer);
    procedure UnDock;

    property Active: Boolean read GetActive;
    property AllowDock: TdxDockingTypes read FAllowDock write SetAllowDock default dxDockingDefaultDockingTypes;
    property AllowDockClients: TdxDockingTypes read FAllowDockClients write SetAllowDockClients default dxDockingDefaultDockingTypes;
    property AllowFloating: Boolean read FAllowFloating write SetAllowFloating;
    property AutoHide: Boolean read FAutoHide write SetAutoHide;
    property AutoHideHostSite: TdxDockSite read GetAutoHideHostSite;
    property AutoHideContainer: TdxDockSiteAutoHideContainer read GetAutoHideContainer;
    property AutoHideControl: TdxCustomDockControl read GetAutoHideControl;
    property AutoHidePosition: TdxAutoHidePosition read FAutoHidePosition;
    property AutoSizeHostSite: TdxDockSite read GetAutoSizeHostSite;
    property Caption;
    property CaptionButtons: TdxCaptionButtons read FCaptionButtons write SetCaptionButtons default dxDockinkDefaultCaptionButtons;
    property ChildCount: Integer read GetChildCount;
    property Children[Index: Integer]: TdxCustomDockControl read GetChild;
    property Container: TdxContainerDockSite read GetContainer;
    property Controller: TdxDockingController read GetController;
    property Dockable: Boolean read FDockable write SetDockable default True;
    property DockIndex: Integer read GetDockIndex;
    property DockLevel: Integer read GetDockLevel;
    property DockState: TdxDockingState read GetDockState;
    property DockType: TdxDockingTypeEx read FDockType;
    property DockZones: TList read FDockZones;
    property FloatForm: TdxFloatForm read GetFloatForm;
    property FloatFormActive: Boolean read GetFloatFormActive;
    property FloatFormVisible: Boolean read GetFloatFormVisible;
    property FloatDockSite: TdxFloatDockSite read GetFloatDockSite;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property Images: TCustomImageList read GetImages;
    property LayoutDockSite: TdxLayoutDockSite read GetLayoutDockSite;
    property OriginalHeight: Integer read FOriginalHeight;
    property OriginalWidth: Integer read FOriginalWidth;
    property ParentDockControl: TdxCustomDockControl read GetParentDockControl;
    property ParentForm: TCustomForm read GetParentForm;
    property ParentFormActive: Boolean read GetParentFormActive;
    property ParentFormVisible: Boolean read GetParentFormVisible;
    property ResizeZones: TList read FResizeZones write FResizeZones;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption default True;
    property SideContainer: TdxSideContainerDockSite read GetSideContainer;
    property SideContainerItem: TdxCustomDockControl read GetSideContainerItem;
    property SideContainerIndex: Integer read GetSideContainerIndex;
    property TabContainer: TdxTabContainerDockSite read GetTabContainer;
    property TopMostDockControl: TdxCustomDockControl read GetTopMostDockControl;
    property UseDoubleBuffer: Boolean read FUseDoubleBuffer write SetUseDoubleBuffer;
    property ValidChildCount: Integer read GetValidChildCount;
    property ValidChildren[Index: Integer]: TdxCustomDockControl read GetValidChild;

    property OnActivate: TdxActivateEvent read FOnActivate write FOnActivate;
    property OnAutoHideChanged: TdxDockControlNotifyEvent read FOnAutoHideChanged
      write FOnAutoHideChanged;
    property OnAutoHideChanging: TdxDockControlNotifyEvent read FOnAutoHideChanging
      write FOnAutoHideChanging;
    property OnCanDocking: TdxCanDockingEvent read FOnCanDocking write FOnCanDocking;
    property OnCanResize: TdxCanResizeEvent read FOnCanResize write FOnCanResize;
    property OnClose: TdxDockControlNotifyEvent read FOnClose write FOnClose;
    property OnCloseQuery: TdxDockControlCloseQueryEvent read FOnCloseQuery write FOnCloseQuery;
    property OnCreateFloatSite: TdxCreateFloatSiteEvent read FOnCreateFloatSite
      write FOnCreateFloatSite;
    property OnCreateLayoutSite: TdxCreateLayoutSiteEvent read FOnCreateLayoutSite
      write FOnCreateLayoutSite;
    property OnCreateSideContainer: TdxCreateSideContainerEvent read FOnCreateSideContainer
      write FOnCreateSideContainer;
    property OnCreateTabContainer: TdxCreateTabContainerEvent read FOnCreateTabContainer
      write FOnCreateTabContainer;
    property OnCustomDrawDockingSelection: TdxCustomDrawSelectionEvent read FOnCustomDrawDockingSelection
      write FOnCustomDrawDockingSelection;
    property OnCustomDrawResizingSelection: TdxCustomDrawSelectionEvent read FOnCustomDrawResizingSelection
      write FOnCustomDrawResizingSelection;
    property OnDock: TdxDockEvent read FOnDock write FOnDock;
    property OnDocking: TdxDockingEvent read FOnDocking write FOnDocking;
    property OnEndDocking: TdxEndDockingEvent read FOnEndDocking write FOnEndDocking;
    property OnEndResizing: TdxResizingEvent read FOnEndResizing write FOnEndResizing;
    property OnGetAutoHidePosition: TdxGetAutoHidePositionEvent read FOnGetAutoHidePosition
      write FOnGetAutoHidePosition;
    property OnLayoutChanged: TdxDockControlNotifyEvent read FOnLayoutChanged
      write FOnLayoutChanged;
    property OnMakeFloating: TdxMakeFloatingEvent read FOnMakeFloating write FOnMakeFloating;
    property OnResize;
    property OnResizing: TdxResizingEvent read FOnResizing write FOnResizing;
    property OnRestoreDockPosition: TdxDockPositionEvent read FOnRestoreDockPosition
      write FOnRestoreDockPosition;
    property OnStartDocking: TdxStartDockingEvent read FOnStartDocking write FOnStartDocking;
    property OnStartResizing: TdxResizingEvent read FOnStartResizing write FOnStartResizing;
    property OnStoreDockPosition: TdxDockPositionEvent read FOnStoreDockPosition
      write FOnStoreDockPosition;
    property OnUnDock: TdxUnDockEvent read FOnUnDock write FOnUnDock;
    property OnUpdateDockZones: TdxUpdateZonesEvent read FOnUpdateDockZones
      write FOnUpdateDockZones;
    property OnUpdateResizeZones: TdxUpdateZonesEvent read FOnUpdateResizeZones
      write FOnUpdateResizeZones;
  published
    property Color stored IsColorStored;
    property Font stored IsFontStored;
    property ManagerColor: Boolean read FManagerColor write SetManagerColor default True;
    property ManagerFont: Boolean read FManagerFont write SetManagerFont default True;
    property ParentColor default False;
    property ParentFont default False;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Visible;

    {$IFDEF DELPHI5}
    property OnContextPopup;
    {$ENDIF}
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnParentChanged: TdxDockControlNotifyEvent read FOnParentChanged write FOnParentChanged;
    property OnParentChanging: TdxDockControlNotifyEvent read FOnParentChanging write FOnParentChanging;
    property OnVisibleChanged: TdxDockControlNotifyEvent read FOnVisibleChanged write FOnVisibleChanged;
    property OnVisibleChanging: TdxDockControlNotifyEvent read FOnVisibleChanging write FOnVisibleChanging;
  end;

  TdxCustomDockSite = class(TdxCustomDockControl)
  protected
  {$IFNDEF DELPHI12}
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  {$ENDIF}
    procedure ValidateInsert(AComponent: TComponent); override;
  public
  {$IFDEF DELPHI12}
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  {$ENDIF}
  published
    property AllowDockClients;
    property OnCanDocking;
    property OnLayoutChanged;
    property OnUpdateDockZones;
    property OnUpdateResizeZones;
  end;

  TdxLayoutDockSite = class(TdxCustomDockSite)
  private
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    procedure SetParent(AParent: TWinControl); override;
    // Docking zones
    procedure UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer); override;
    // Site layout
    procedure CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); override;
    procedure DestroyLayout(AControl: TdxCustomDockControl); override;
    // Sibling control
    function GetSiblingDockControl: TdxCustomDockControl; virtual;
    // Destroying
    function CanDestroy: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeforeDestruction; override;
    function CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean; override;

    property SiblingDockControl: TdxCustomDockControl read GetSiblingDockControl;
  published
    property OnCreateLayoutSite;
  end;

  TdxActiveChildChangeEvent = procedure (Sender: TdxContainerDockSite; Child: TdxCustomDockControl) of object;

  TdxContainerDockSite = class(TdxCustomDockSite)
  private
    FActiveChild: TdxCustomDockControl;
    FActiveChildIndex: Integer;
    FOnActiveChildChanged: TdxActiveChildChangeEvent;

    function GetActiveChildIndex: Integer;
    procedure SetActiveChildByIndex(AIndex: Integer);
    procedure SetActiveChild(Value: TdxCustomDockControl);
    procedure SetActiveChildIndex(Value: Integer);
  protected
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
    // Site layout
    procedure CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); override;
    procedure DestroyChildLayout; override;
    procedure DestroyLayout(AControl: TdxCustomDockControl); override;
    procedure UpdateLayout; override;
    procedure LoadLayoutFromCustomIni(AIniFile: TCustomIniFile; AParentForm: TCustomForm;
      AParentControl: TdxCustomDockControl; ASection: string); override;
    procedure SaveLayoutToCustomIni(AIniFile: TCustomIniFile; ASection: string); override;
    // AutoHide
    function GetControlAutoHidePosition(AControl: TdxCustomDockControl): TdxAutoHidePosition; override;
    // Control visibility
    procedure ChildVisibilityChanged(Sender: TdxCustomDockControl); override;
    // Children layout
    procedure BeginAdjustBounds; virtual;
    procedure EndAdjustBounds; virtual;
    procedure DoActiveChildChanged(APrevActiveChild: TdxCustomDockControl); virtual;
    class function GetHeadDockType: TdxDockingType; virtual;
    class function GetTailDockType: TdxDockingType; virtual;
    function GetFirstValidChild: TdxCustomDockControl;
    function GetFirstValidChildIndex: Integer;
    function GetLastValidChild: TdxCustomDockControl;
    function GetLastValidChildIndex: Integer;
    function GetNextValidChild(AIndex: Integer): TdxCustomDockControl;
    function GetNextValidChildIndex(AIndex: Integer): Integer;
    function GetPrevValidChild(AIndex: Integer): TdxCustomDockControl;
    function GetPrevValidChildIndex(AIndex: Integer): Integer;
    function IsValidActiveChild(AControl: TdxCustomDockControl): Boolean; virtual;
    procedure ValidateActiveChild(AIndex: Integer); virtual;
  public
    constructor Create(AOwner: TComponent); override;

    function CanContainerDockHost(AType: TdxDockingType): Boolean; virtual;
    function CanDock: Boolean; override;
    function CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean; override;

    property ActiveChild: TdxCustomDockControl read FActiveChild write SetActiveChild;
  published
    property ActiveChildIndex: Integer read GetActiveChildIndex write SetActiveChildIndex;
    property AllowDock;
    property AllowFloating;
    
    property OnActiveChildChanged: TdxActiveChildChangeEvent read FOnActiveChildChanged write FOnActiveChildChanged;
    property OnCanResize;
    property OnCreateFloatSite;
    property OnCustomDrawDockingSelection;
    property OnCustomDrawResizingSelection;
    property OnEndResizing;
    property OnResize;
    property OnResizing;
    property OnRestoreDockPosition;
    property OnStartResizing;
    property OnStoreDockPosition;
  end;

  TdxTabContainerDockSite = class(TdxContainerDockSite)
  private
    FFirstVisibleTabIndex: Integer;
    FPressedTabIndex: Integer;
    FTabsPosition: TdxTabContainerTabsPosition;
    FTabsRect: TRect;
    FTabsRects: array of TRect;
    FTabsNextTabButtonRect: TRect;
    FTabsPrevTabButtonRect: TRect;
    FTabsScroll: Boolean;
    FTabsScrollTimerID: Integer;

    FTabsNextTabButtonIsDown: Boolean;
    FTabsNextTabButtonIsEnabled: Boolean;
    FTabsNextTabButtonIsHot: Boolean;
    FTabsPrevTabButtonIsDown: Boolean;
    FTabsPrevTabButtonIsEnabled: Boolean;
    FTabsPrevTabButtonIsHot: Boolean;

    function GetLastVisibleTabIndex: Integer;
    function GetTabRectCount: Integer;
    function GetTabRect(Index: Integer): TRect;
    function GetTabsButtonsVisible: Boolean;
    procedure SetTabsPosition(const Value: TdxTabContainerTabsPosition);
    procedure SetTabsScroll(const Value: Boolean);

    function DecFirstVisibleTabIndex: Boolean;
    function IncFirstVisibleTabIndex: Boolean;
    procedure UpdateButtonsState;

    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
  protected
    function GetDesignHitTest(const APoint: TPoint; AShift: TShiftState): Boolean; override;
    // Resizing
    function CanResizeAtPos(pt: TPoint): Boolean; override;
    // Docking zones
    procedure UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer); override;
    // Site layout
    procedure IncludeToDock(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); override;
    procedure CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); override;
    procedure DestroyLayout(AControl: TdxCustomDockControl); override;
    procedure UpdateLayout; override;
    procedure LoadLayoutFromCustomIni(AIniFile: TCustomIniFile; AParentForm: TCustomForm;
      AParentControl: TdxCustomDockControl; ASection: string); override;
    procedure SaveLayoutToCustomIni(AIniFile: TCustomIniFile; ASection: string); override;
    // SideContainer site
    function CanAcceptSideContainerItems(AContainer: TdxSideContainerDockSite): Boolean; override;
    // TabContainer site
    function CanAcceptTabContainerItems(AContainer: TdxTabContainerDockSite): Boolean; override;
    // AutoHide
    procedure ChangeAutoHide; override;
    // Caption
    procedure UpdateCaption; override;
    // Closing
    procedure DoClose; override;
    // Control visibility
    procedure ChildVisibilityChanged(Sender: TdxCustomDockControl); override;
    // Children layout
    procedure DoActiveChildChanged(APrevActiveChild: TdxCustomDockControl); override;
    procedure UpdateActiveTab;
    procedure UpdateChildrenState;
    procedure ValidateActiveChild(AIndex: Integer); override;
    procedure ValidateFirstVisibleIndex;
    // Painting
    procedure CalculateNC(var ARect: TRect); override;
    procedure NCPaint(ACanvas: TCanvas); override;
    function GetTabIndexAtPos(pt: TPoint): Integer;
    function GetTabWidth(AControl: TdxCustomDockControl): Integer;
    function HasBorder: Boolean; override;
    function HasCaption: Boolean; override;
    function HasTabs: Boolean; override;
    function IsCaptionActive: Boolean; override;
    function IsTabsPoint(pt: TPoint): Boolean;
    function IsTabsNextTabButtonPoint(pt: TPoint): Boolean;
    function IsTabsPrevTabButtonPoint(pt: TPoint): Boolean;
    // Rectangles
    property TabsNextTabButtonRect: TRect read FTabsNextTabButtonRect;
    property TabsPrevTabButtonRect: TRect read FTabsPrevTabButtonRect;
    property TabsRect: TRect read FTabsRect;
    property TabRectCount: Integer read GetTabRectCount;
    property TabsRects[Index: Integer]: TRect read GetTabRect;
    // Tabs scrolling
    procedure DoIncrementTabsScroll;
    procedure DoDecrementTabsScroll;
    procedure InitIncrementTabsScroll;
    procedure InitDecrementTabsScroll;
    property FirstVisibleTabIndex: Integer read FFirstVisibleTabIndex;
    property LastVisibleTabIndex: Integer read GetLastVisibleTabIndex;

    property TabsButtonsVisible: Boolean read GetTabsButtonsVisible;
    property TabsNextTabButtonIsDown: Boolean read FTabsNextTabButtonIsDown;
    property TabsNextTabButtonIsEnabled: Boolean read FTabsNextTabButtonIsEnabled;
    property TabsNextTabButtonIsHot: Boolean read FTabsNextTabButtonIsHot;
    property TabsPrevTabButtonIsDown: Boolean read FTabsPrevTabButtonIsDown;
    property TabsPrevTabButtonIsEnabled: Boolean read FTabsPrevTabButtonIsEnabled;
    property TabsPrevTabButtonIsHot: Boolean read FTabsPrevTabButtonIsHot;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;

    function CanActive: Boolean; override;
    function CanAutoHide: Boolean; override;
    function CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean; override;
    function CanMaximize: Boolean; override;

    procedure ActivateNextChild(AGoForward: Boolean; AGoOnCycle: Boolean = True);
  published
    property AutoHide;
    property CaptionButtons;
    property Dockable;
    property ImageIndex;
    property ShowCaption;
    property TabsPosition: TdxTabContainerTabsPosition read FTabsPosition write SetTabsPosition default tctpBottom;
    property TabsScroll: Boolean read FTabsScroll write SetTabsScroll default True;

    property OnActivate;
    property OnAutoHideChanged;
    property OnAutoHideChanging;
    property OnClose;
    property OnCloseQuery;
    property OnCreateSideContainer;
    property OnDock;
    property OnDocking;
    property OnEndDocking;
    property OnGetAutoHidePosition;
    property OnMakeFloating;
    property OnStartDocking;
    property OnUnDock;
  end;

  TdxSideContainerDockSite = class(TdxContainerDockSite)
  private
    FAdjustBoundsLock: Integer;
  protected
    // Docking zones
    procedure UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer); override;
    // Site layout
    procedure IncludeToDock(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); override;
    procedure CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); override;
    procedure UpdateLayout; override;
    procedure LoadLayoutFromCustomIni(AIniFile: TCustomIniFile; AParentForm: TCustomForm;
      AParentControl: TdxCustomDockControl; ASection: string); override;
    // SideContainer site
    function CanAcceptSideContainerItems(AContainer: TdxSideContainerDockSite): Boolean; override;
    // TabContainer
    function CanAcceptTabContainerItems(AContainer: TdxTabContainerDockSite): Boolean; override;
    // Caption
    procedure UpdateCaption; override;
    // AutoHide
    procedure ChangeAutoHide; override;
    // Closing
    procedure DoClose; override;
    // Control visibility
    procedure ChildVisibilityChanged(Sender: TdxCustomDockControl); override;
    // Children layout
    procedure DoActiveChildChanged(APrevActiveChild: TdxCustomDockControl); override;
    function CanChildResize(AControl: TdxCustomDockControl; ADeltaSize: Integer): Boolean;
    procedure DoChildResize(AControl: TdxCustomDockControl; ADeltaSize: Integer; AResizeNextControl: Boolean = True);
    procedure BeginAdjustBounds; override;
    procedure EndAdjustBounds; override;
    function IsAdjustBoundsLocked: Boolean;
    property AdjustBoundsLock: Integer read FAdjustBoundsLock;
    procedure AdjustChildrenBounds(AControl: TdxCustomDockControl);
    procedure NormalizeChildrenBounds(ADeltaSize: Integer);
    procedure SetChildBounds(AControl: TdxCustomDockControl; var AWidth, AHeight: Integer);
    function IsValidActiveChild(AControl: TdxCustomDockControl): Boolean; override;
    procedure ValidateActiveChild(AIndex: Integer); override;

    function GetDifferentSize: Integer;
    function GetContainerSize: Integer; virtual; abstract;
    function GetDimension(AWidth, AHeight: Integer): Integer; virtual; abstract;
    function GetMinSize(Index: Integer): Integer; virtual; abstract;
    function GetOriginalSize(Index: Integer): Integer; virtual; abstract;
    function GetSize(Index: Integer): Integer; virtual; abstract;
    function GetPosition(Index: Integer): Integer; virtual; abstract;
    procedure SetDimension(var AWidth, AHeight: Integer; AValue: Integer); virtual; abstract;
    procedure SetOriginalSize(Index: Integer; const Value: Integer); virtual; abstract;
    procedure SetSize(Index: Integer; const Value: Integer); virtual; abstract;
    procedure SetPosition(Index: Integer; const Value: Integer); virtual; abstract;

    property MinSizes[Index: Integer]: Integer read GetMinSize;
    property OriginalSizes[Index: Integer]: Integer read GetOriginalSize write SetOriginalSize;
    property Sizes[Index: Integer]: Integer read GetSize write SetSize;
    property Positions[Index: Integer]: Integer read GetPosition write SetPosition;
    // Painting
    function HasBorder: Boolean; override;
    function HasCaption: Boolean; override;
  public
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    function CanActive: Boolean; override;
    function CanAutoHide: Boolean; override;
    function CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean; override;
    function CanMaximize: Boolean; override;
  published
    property AutoHide;
    property CaptionButtons;
    property Dockable;
    property ImageIndex;
    property ShowCaption;

    property OnActivate;
    property OnAutoHideChanged;
    property OnAutoHideChanging;
    property OnClose;
    property OnCloseQuery;
    property OnDock;
    property OnDocking;
    property OnEndDocking;
    property OnGetAutoHidePosition;
    property OnMakeFloating;
    property OnStartDocking;
    property OnUnDock;
  end;

  TdxHorizContainerDockSite = class(TdxSideContainerDockSite)
  protected
    // Resizing
    procedure UpdateControlResizeZones(AControl: TdxCustomDockControl); override;
    // SiteBounds
    procedure UpdateControlOriginalSize(AControl: TdxCustomDockControl); override;
    // Children layout
    class function GetHeadDockType: TdxDockingType; override;
    class function GetTailDockType: TdxDockingType; override;
    function GetContainerSize: Integer; override;
    function GetDimension(AWidth, AHeight: Integer): Integer; override;
    function GetMinSize(Index: Integer): Integer; override;
    function GetOriginalSize(Index: Integer): Integer; override;
    function GetSize(Index: Integer): Integer; override;
    function GetPosition(Index: Integer): Integer; override;
    procedure SetDimension(var AWidth, AHeight: Integer; AValue: Integer); override;
    procedure SetOriginalSize(Index: Integer; const Value: Integer); override;
    procedure SetSize(Index: Integer; const Value: Integer); override;
    procedure SetPosition(Index: Integer; const Value: Integer); override;
  end;

  TdxVertContainerDockSite = class(TdxSideContainerDockSite)
  protected
    // Resizing
    procedure UpdateControlResizeZones(AControl: TdxCustomDockControl); override;
    // SiteBounds
    procedure UpdateControlOriginalSize(AControl: TdxCustomDockControl); override;
    // Children layout
    class function GetHeadDockType: TdxDockingType; override;
    class function GetTailDockType: TdxDockingType; override;
    function GetContainerSize: Integer; override;
    function GetDimension(AWidth, AHeight: Integer): Integer; override;
    function GetMinSize(Index: Integer): Integer; override;
    function GetOriginalSize(Index: Integer): Integer; override;
    function GetSize(Index: Integer): Integer; override;
    function GetPosition(Index: Integer): Integer; override;
    procedure SetDimension(var AWidth, AHeight: Integer; AValue: Integer); override;
    procedure SetOriginalSize(Index: Integer; const Value: Integer); override;
    procedure SetSize(Index: Integer; const Value: Integer); override;
    procedure SetPosition(Index: Integer; const Value: Integer); override;
  end;

  TdxDockSiteAutoHideContainer = class(TWinControl)
  private
    procedure CMControlListChange(var Message: TMessage); message CM_CONTROLLISTCHANGE;
    procedure WMEraseBkgnd(var Message: TWmEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TdxDockSiteHideBar = class
  private
    FDockControls: TList;
    FRect: TRect;
    FButtonsRects: array of TRect;

    FOwner: TdxDockSite;
    function GetButtonRectCount: Integer;
    function GetButtonRect(Index: Integer): TRect;
    function GetDockControl(Index: Integer): TdxCustomDockControl;
    function GetDockControlCount: Integer;
    function GetPainter: TdxDockControlPainter;
    function GetVisible: Boolean;
  protected
    procedure Calculate(R: TRect); virtual; abstract;
    procedure CalculateButtons(R: TRect); virtual; abstract;
    function GetContainersAnchors: TAnchors; virtual; abstract;
    function GetControlsAlign: TAlign; virtual; abstract;
    function GetPosition: TdxAutoHidePosition; virtual; abstract;
    function GetButtonWidth(AControl: TdxCustomDockControl): Integer; virtual;
    function GetDefaultImageSize: Integer; virtual; abstract;
    function GetImageSize: Integer; virtual; abstract;
    function CheckHidingFinish: Boolean; virtual; abstract;
    function CheckShowingFinish: Boolean; virtual; abstract;
    procedure SetFinalPosition(AControl: TdxCustomDockControl); virtual; abstract;
    procedure SetInitialPosition(AControl: TdxCustomDockControl); virtual; abstract;
    procedure UpdatePosition(ADelta: Integer); virtual; abstract;
    procedure UpdateOwnerAutoSizeBounds(AControl: TdxCustomDockControl); virtual; abstract;

    function GetControlAtPos(pt: TPoint; var SubControl: TdxCustomDockControl): TdxCustomDockControl; virtual;
    function GetTabContainerChildAtPos(pt: TPoint; TabContainer: TdxTabContainerDockSite): TdxCustomDockControl; virtual;
    function IndexOfDockControl(AControl: TdxCustomDockControl): Integer;
    procedure CreateAutoHideContainer(AControl: TdxCustomDockControl); virtual;
    procedure DestroyAutoHideContainer(AControl: TdxCustomDockControl); virtual;
    procedure RegisterDockControl(AControl: TdxCustomDockControl);
    procedure UnregisterDockControl(AControl: TdxCustomDockControl);
    // Rectangles
    property ButtonRectCount: Integer read GetButtonRectCount;
    property ButtonsRects[Index: Integer]: TRect read GetButtonRect;
    property Painter: TdxDockControlPainter read GetPainter;
    property Rect: TRect read FRect;
  public
    constructor Create(AOwner: TdxDockSite);
    destructor Destroy; override;

    property DockControlCount: Integer read GetDockControlCount;
    property DockControls[Index: Integer]: TdxCustomDockControl read GetDockControl;
    property Owner: TdxDockSite read FOwner;
    property Position: TdxAutoHidePosition read GetPosition;
    property Visible: Boolean read GetVisible;
  end;

  TdxDockSiteLeftHideBar = class(TdxDockSiteHideBar)
  protected
    procedure Calculate(R: TRect); override;
    procedure CalculateButtons(R: TRect); override;
    function GetDefaultImageSize: Integer; override;
    function GetImageSize: Integer; override;
    function GetContainersAnchors: TAnchors; override;
    function GetControlsAlign: TAlign; override;
    function GetPosition: TdxAutoHidePosition; override;
    function CheckHidingFinish: Boolean; override;
    function CheckShowingFinish: Boolean; override;
    procedure SetFinalPosition(AControl: TdxCustomDockControl); override;
    procedure SetInitialPosition(AControl: TdxCustomDockControl); override;
    procedure UpdatePosition(ADelta: Integer); override;
    procedure UpdateOwnerAutoSizeBounds(AControl: TdxCustomDockControl); override;

    function GetTabContainerChildAtPos(pt: TPoint; TabContainer: TdxTabContainerDockSite): TdxCustomDockControl; override;
  end;

  TdxDockSiteTopHideBar = class(TdxDockSiteHideBar)
  protected
    procedure Calculate(R: TRect); override;
    procedure CalculateButtons(R: TRect); override;
    function GetDefaultImageSize: Integer; override;
    function GetImageSize: Integer; override;
    function GetContainersAnchors: TAnchors; override;
    function GetControlsAlign: TAlign; override;
    function GetPosition: TdxAutoHidePosition; override;
    function CheckHidingFinish: Boolean; override;
    function CheckShowingFinish: Boolean; override;
    procedure SetFinalPosition(AControl: TdxCustomDockControl); override;
    procedure SetInitialPosition(AControl: TdxCustomDockControl); override;
    procedure UpdatePosition(ADelta: Integer); override;
    procedure UpdateOwnerAutoSizeBounds(AControl: TdxCustomDockControl); override;

    function GetTabContainerChildAtPos(pt: TPoint; TabContainer: TdxTabContainerDockSite): TdxCustomDockControl; override;
  end;

  TdxDockSiteRightHideBar = class(TdxDockSiteLeftHideBar)
  protected
    procedure Calculate(R: TRect); override;
    function GetContainersAnchors: TAnchors; override;
    function GetControlsAlign: TAlign; override;
    function GetPosition: TdxAutoHidePosition; override;
    procedure SetFinalPosition(AControl: TdxCustomDockControl); override;
    procedure SetInitialPosition(AControl: TdxCustomDockControl); override;
    procedure UpdatePosition(ADelta: Integer); override;
  end;

  TdxDockSiteBottomHideBar = class(TdxDockSiteTopHideBar)
  protected
    procedure Calculate(R: TRect); override;
    function GetContainersAnchors: TAnchors; override;
    function GetControlsAlign: TAlign; override;
    function GetPosition: TdxAutoHidePosition; override;
    procedure SetFinalPosition(AControl: TdxCustomDockControl); override;
    procedure SetInitialPosition(AControl: TdxCustomDockControl); override;
    procedure UpdatePosition(ADelta: Integer); override;
  end;

  TdxAutoHideControlEvent = procedure (Sender: TdxDockSite; AControl: TdxCustomDockControl) of object;

  TdxDockSite = class(TdxCustomDockSite)
  private
    FAutoSize: Boolean;
    FAutoSizeHeight: Integer;
    FAutoSizeWidth: Integer;
    FHideBars: TList;
    FHidingTimerID: Integer;
    FMovingControl: TdxCustomDockControl;
    FMovingControlHideBar: TdxDockSiteHideBar;
    FMovingTimerID: Integer;
    FShowingControl: TdxCustomDockControl;
    FShowingControlCandidate: TdxCustomDockControl;
    FShowingTimerID: Integer;
    FWorkingControl: TdxCustomDockControl;

    FOnHideControl: TdxAutoHideControlEvent;
    FOnShowControl: TdxAutoHideControlEvent;

    function GetHideBarCount: Integer;
    function GetHideBar(Index: Integer): TdxDockSiteHideBar;
    function GetMovingContainer: TdxDockSiteAutoHideContainer;
    procedure SetShowingControl(Value: TdxCustomDockControl);
    procedure SetWorkingControl(AValue: TdxCustomDockControl);

    procedure CMControlListChange(var Message: TMessage); message CM_CONTROLLISTCHANGE;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
  protected
    function GetDesignHitTest(const APoint: TPoint; AShift: TShiftState): Boolean; override;
    procedure Loaded; override;
    procedure ReadState(Reader: TReader); override;
    procedure SetAutoSize(Value: Boolean); {$IFDEF DELPHI6}override;{$ENDIF}
    procedure SetParent(AParent: TWinControl); override;
    procedure ValidateInsert(AComponent: TComponent); override;
    // Resizing zones
    procedure UpdateControlResizeZones(AControl: TdxCustomDockControl); override;
    // Docking zones
    procedure UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer); override;
    // Control layout
    procedure CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); override;
    procedure DestroyLayout(AControl: TdxCustomDockControl); override;
    procedure LoadLayoutFromCustomIni(AIniFile: TCustomIniFile; AParentForm: TCustomForm;
      AParentControl: TdxCustomDockControl; ASection: string); override;
    procedure SaveLayoutToCustomIni(AIniFile: TCustomIniFile; ASection: string); override;
    // Control bounds
    procedure UpdateControlOriginalSize(AControl: TdxCustomDockControl); override;
    // Control visibility
    procedure ChildVisibilityChanged(Sender: TdxCustomDockControl); override;
    // Painting
    procedure CalculateNC(var ARect: TRect); override;
    procedure NCPaint(ACanvas: TCanvas); override;
    procedure Recalculate; override;
    // AutoHide controls
    function GetControlAutoHidePosition(AControl: TdxCustomDockControl): TdxAutoHidePosition; override;
    procedure RegisterAutoHideDockControl(AControl: TdxCustomDockControl; APosition: TdxAutoHidePosition);
    procedure UnregisterAutoHideDockControl(AControl: TdxCustomDockControl);
    // AutoSize
    procedure AdjustAutoSizeBounds; virtual;
    function CanAutoSizeChange: Boolean; virtual;
    procedure CheckAutoSizeBounds;
    function GetAutoSizeClientControl: TdxCustomDockControl; virtual;
    procedure UpdateAutoSizeBounds(AWidth, AHeight: Integer); virtual;
    // Hiding/Showing AutoHide controls
    procedure DoHideControl(AControl: TdxCustomDockControl);
    procedure DoShowControl(AControl: TdxCustomDockControl);

    procedure DoShowMovement;
    procedure DoHideMovement;
    procedure ImmediatelyHide(AFinalizing: Boolean = False);
    procedure ImmediatelyShow(AControl: TdxCustomDockControl);
    procedure InitializeHiding;
    procedure InitializeShowing;
    procedure FinalizeHiding;
    procedure FinalizeShowing;
    procedure SetFinalPosition(AControl: TdxCustomDockControl);
    procedure SetInitialPosition(AControl: TdxCustomDockControl);
    function GetClientLeft: Integer;
    function GetClientTop: Integer;
    function GetClientWidth: Integer;
    function GetClientHeight: Integer;
    // HideBars
    function GetControlAtPos(pt: TPoint; var SubControl: TdxCustomDockControl): TdxCustomDockControl;
    function GetHideBarAtPos(pt: TPoint): TdxDockSiteHideBar;
    function GetHideBarByControl(AControl: TdxCustomDockControl): TdxDockSiteHideBar;
    function GetHideBarByPosition(APosition: TdxAutoHidePosition): TdxDockSiteHideBar;

    procedure CreateHideBars; virtual;
    procedure DestroyHideBars; virtual;

    property HideBarCount: Integer read GetHideBarCount;
    property HideBars[Index: Integer]: TdxDockSiteHideBar read GetHideBar;
    property BottomHideBar: TdxDockSiteHideBar index 1 read GetHideBar;
    property LeftHideBar: TdxDockSiteHideBar index 2 read GetHideBar;
    property RightHideBar: TdxDockSiteHideBar index 3 read GetHideBar;
    property TopHideBar: TdxDockSiteHideBar index 0 read GetHideBar;

    property MovingContainer: TdxDockSiteAutoHideContainer read GetMovingContainer;
    property MovingControl: TdxCustomDockControl read FMovingControl;
    property MovingControlHideBar: TdxDockSiteHideBar read FMovingControlHideBar;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean; override;
    function GetPositionByControl(AControl: TdxCustomDockControl): TdxAutoHidePosition;
    function HasAutoHideControls: Boolean;

    property AutoSizeClientControl: TdxCustomDockControl read GetAutoSizeClientControl;
    property ShowingControl: TdxCustomDockControl read FShowingControl write SetShowingControl;
    property WorkingControl: TdxCustomDockControl read FWorkingControl write SetWorkingControl;
  published
    property Align;
    property Anchors;
    property AutoSize: Boolean read FAutoSize write SetAutoSize default False;
    property Visible;

    property OnCreateLayoutSite;
    property OnHideControl: TdxAutoHideControlEvent read FOnHideControl write FOnHideControl;
    property OnShowControl: TdxAutoHideControlEvent read FOnShowControl write FOnShowControl;
  end;

  TdxSetFloatFormCaptionEvent = procedure (Sender: TdxCustomDockControl; AFloatForm: TdxFloatForm) of object;
  TdxFloatDockSite = class(TdxCustomDockSite)
  private
    FFloatForm: TdxFloatForm;
    FFloatLeft: Integer;
    FFloatTop: Integer;
    FFloatWidth: Integer;
    FFloatHeight: Integer;
    FOnSetFloatFormCaption: TdxSetFloatFormCaptionEvent;

    function GetChild: TdxCustomDockControl;
    function GetFloatLeft: Integer;
    function GetFloatTop: Integer;
    function GetFloatWidth: Integer;
    function GetFloatHeight: Integer;
    procedure SetFloatLeft(const Value: Integer);
    procedure SetFloatTop(const Value: Integer);
    procedure SetFloatWidth(const Value: Integer);
    procedure SetFloatHeight(const Value: Integer);
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    function GetDesignRect: TRect; override;
    procedure Loaded; override;
    procedure SetParent(AParent: TWinControl); override;
    function IsLoadingFromForm: Boolean;
    // Docking
    function CanUndock(AControl: TdxCustomDockControl): Boolean; override;
    procedure StartDocking(pt: TPoint); override;
    procedure CheckDockClientsRules; override;
    // Dock zones
    procedure UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer); override;
    // Site layout
    procedure CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
      Index: Integer); override;
    procedure DestroyLayout(AControl: TdxCustomDockControl); override;
    procedure LoadLayoutFromCustomIni(AIniFile: TCustomIniFile; AParentForm: TCustomForm;
      AParentControl: TdxCustomDockControl; ASection: string); override;
    procedure SaveLayoutToCustomIni(AIniFile: TCustomIniFile; ASection: string); override;
    // Floating site
    procedure DoSetFloatFormCaption;
    function GetFloatForm: TdxFloatForm; override;
    procedure RestoreDockPosition(pt: TPoint); override;
    // Floating form
    function GetFloatFormClass: TdxFloatFormClass; virtual;
    procedure CreateFloatForm; virtual;
    procedure DestroyFloatForm; virtual;
    procedure HideFloatForm;
    procedure ShowFloatForm;
    procedure SetFloatFormPosition(ALeft, ATop: Integer);
    procedure SetFloatFormSize(AWidth, AHeight: Integer);
    // Caption
    procedure UpdateCaption; override;
    // Site bounds
    procedure AdjustControlBounds(AControl: TdxCustomDockControl); override;
    procedure UpdateControlOriginalSize(AControl: TdxCustomDockControl); override;
    procedure UpdateFloatPosition; virtual;
    // Control visibility
    procedure ChildVisibilityChanged(Sender: TdxCustomDockControl); override;
    // Activation
    // Closing
    procedure DoClose; override;
    // Destroying
    function CanDestroy: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    function HasParent: Boolean; override;

    procedure Activate; override;
    function CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean; override;
    function GetDockPanel: TdxCustomDockControl;
    property Child: TdxCustomDockControl read GetChild;
  published
    property FloatLeft: Integer read GetFloatLeft write SetFloatLeft;
    property FloatTop: Integer read GetFloatTop write SetFloatTop;
    property FloatWidth: Integer read GetFloatWidth write SetFloatWidth stored False;
    property FloatHeight: Integer read GetFloatHeight write SetFloatHeight stored False;
    property OnSetFloatFormCaption: TdxSetFloatFormCaptionEvent read FOnSetFloatFormCaption
      write FOnSetFloatFormCaption;
  end;
  
  TdxFloatForm = class(TCustomForm)
  private
    FCanDesigning: Boolean;
    FCaptionIsDown: Boolean;
    FCaptionPoint: TPoint;
    FClientHeight: Integer;
    FClientWidth: Integer;
    FDockSite: TdxFloatDockSite;
    FOnTopMost: Boolean;

    function GetParentForm: TCustomForm;

    procedure WMClose(var Message: TWMClose); message WM_CLOSE;
    procedure WMMove(var Message: TWMMove); message WM_MOVE;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
    procedure WMNCLButtonUp(var Message: TWMNCLButtonUp); message WM_NCLBUTTONUP;
    procedure WMNCLButtonDblClk(var Message: TWMNCMButtonDblClk); message WM_NCLBUTTONDBLCLK;
    procedure WMNCMouseMove(var Message: TWMNCMouseMove); message WM_NCMOUSEMOVE;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    {$IFDEF DELPHI6}
    procedure WndProc(var Message: TMessage); override;
    {$ENDIF}
    function CanDesigning: Boolean;
    function IsDesigning: Boolean;
    function IsDestroying: Boolean;
    // Dock site
    procedure InsertDockSite(ADockSite: TdxFloatDockSite);
    procedure RemoveDockSite;
    // Form position
    procedure BringToFront(ATopMost: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function IsShortCut(var Message: TWMKey): Boolean; override;

    procedure ShowWindow;
    procedure HideWindow;

    property AutoScroll default False;
    property BorderStyle default bsSizeToolWin;
    property DockSite: TdxFloatDockSite read FDockSite;
    property FormStyle;
    property Icon;
    property ParentForm: TCustomForm read GetParentForm;
  end;

  TdxEdgePosition = (epLeft, epTop, epRight, epBottom, epTopLeft, epBottomRight, epRect);
  TdxEdgePositions = set of TdxEdgePosition;
  TdxEdgesType = (etStandard, etFlat, etRaisedInner, etRaisedOuter, etSunkenInner, etSunkenOuter);
  
  TdxDockControlPainter = class
  private
    FDockControl: TdxCustomDockControl;
  protected
    class procedure AssignDefaultColor(AManager: TdxDockingManager); virtual;
    class procedure AssignDefaultFont(AManager: TdxDockingManager); virtual;
    class procedure CreateColors; virtual;
    class procedure RefreshColors; virtual;
    class procedure ReleaseColors; virtual;

    class function LightColor(AColor: TColor): TColor;
    class function LightLightColor(AColor: TColor): TColor;
    class function DarkColor(AColor: TColor): TColor;
    class function DarkDarkColor(AColor: TColor): TColor;

    class procedure DrawColorEdge(ACanvas: TCanvas; ARect: TRect; AColor: TColor;
      AEdgesType: TdxEdgesType; AEdgePositios: TdxEdgePositions);
    class procedure DrawImage(ACanvas: TCanvas; AImageList: TCustomImageList;
      AImageIndex: Integer; R: TRect);
    class function RectInRect(R1, R2: TRect): Boolean;

    function GetCaptionRect(const ARect: TRect; AIsVertical: Boolean): TRect; virtual;
    function GetColor: TColor; virtual;
    function GetFont: TFont; virtual;
    function GetBorderColor: TColor; virtual;
    function GetCaptionColor(IsActive: Boolean): TColor; virtual;
    function GetCaptionFont(IsActive: Boolean): TFont; virtual;
    function GetCaptionFontColor(IsActive: Boolean): TColor; virtual;
    function GetCaptionSignColor(IsActive, IsDown, IsHot: Boolean): TColor; virtual;
    function GetTabsColor: TColor; virtual;
    function GetTabColor(IsActive: Boolean): TColor; virtual;
    function GetTabFont(IsActive: Boolean): TFont; virtual;
    function GetTabFontColor(IsActive: Boolean): TColor; virtual;
    function GetTabsScrollButtonsColor: TColor; virtual;
    function GetTabsScrollButtonsSignColor(IsEnable: Boolean): TColor; virtual;
    function GetHideBarButtonColor: TColor; virtual;
    function GetHideBarButtonFont: TFont; virtual;
    function GetHideBarButtonFontColor: TColor; virtual;
    function GetHideBarColor: TColor; virtual;   

    function DrawCaptionFirst: Boolean; virtual;
    function NeedRedrawOnResize: Boolean; virtual;
  public
    constructor Create(ADockControl: TdxCustomDockControl); virtual; 
    // CustomDockControl
    function CanVerticalCaption: Boolean; virtual;
    function GetBorderWidths: TRect; virtual;
    function GetCaptionButtonSize: Integer; virtual;
    function GetCaptionHeight: Integer; virtual;
    function GetCaptionHorizInterval: Integer; virtual;
    function GetCaptionVertInterval: Integer; virtual;
    function GetDefaultImageHeight: Integer;
    function GetDefaultImageWidth: Integer;
    function GetImageHeight: Integer;
    function GetImageWidth: Integer;
    function IsHideBarButtonHotTrackSupports: Boolean; virtual;
    function IsValidImageIndex(AIndex: Integer): Boolean;

    procedure DrawBorder(ACanvas: TCanvas; ARect: TRect); virtual;
    procedure DrawCaption(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean); virtual;
    procedure DrawCaptionSeparator(ACanvas: TCanvas; ARect: TRect); virtual;
    procedure DrawCaptionText(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean); virtual;
    procedure DrawCaptionButtonSelection(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot: Boolean); virtual;
    procedure DrawCaptionCloseButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); virtual;
    procedure DrawCaptionHideButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); virtual;
    procedure DrawCaptionMaximizeButton(ACanvas: TCanvas; ARect: TRect;
      IsActive, IsDown, IsHot, IsSwitched: Boolean); virtual;
    procedure DrawClient(ACanvas: TCanvas; ARect: TRect); virtual;
    // TabContainer
    procedure CorrectTabRect(var ATab: TRect; APosition: TdxTabContainerTabsPosition;
      AIsActive: Boolean); virtual;
    function DrawActiveTabLast: Boolean; virtual;  
    function GetTabVertInterval: Integer; virtual;
    function GetTabVertOffset: Integer; virtual;
    function GetTabHorizInterval: Integer; virtual;
    function GetTabHorizOffset: Integer; virtual;
    function GetTabsButtonSize: Integer; virtual;
    function GetTabsHeight: Integer; virtual;

    procedure DrawTabs(ACanvas: TCanvas; ARect, AActiveTabRect: TRect;
      APosition: TdxTabContainerTabsPosition); virtual;
    procedure DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl; ARect: TRect;
      IsActive: Boolean; APosition: TdxTabContainerTabsPosition); virtual;
    procedure DrawTabContent(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition); virtual;
    procedure DrawTabsNextTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); virtual;
    procedure DrawTabsPrevTabButton(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); virtual;
    procedure DrawTabsButtonSelection(ACanvas: TCanvas; ARect: TRect;
      IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition); virtual;
    // AutoHideHostSite
    function GetHideBarHeight: Integer; virtual;
    function GetHideBarWidth: Integer; virtual;
    function GetHideBarVertInterval: Integer; virtual;
    function GetHideBarHorizInterval: Integer; virtual;

    procedure DrawHideBar(ACanvas: TCanvas; ARect: TRect; APosition: TdxAutoHidePosition); virtual;
    procedure DrawHideBarButton(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; APosition: TdxAutoHidePosition); virtual;
    procedure DrawHideBarButtonContent(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; APosition: TdxAutoHidePosition); virtual;
    procedure DrawHideBarButtonImage(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect); virtual;
    procedure DrawHideBarButtonText(ACanvas: TCanvas; AControl: TdxCustomDockControl;
      ARect: TRect; APosition: TdxAutoHidePosition); virtual;

    property DockControl: TdxCustomDockControl read FDockControl;
  end;

  TdxCustomDockControlProperties = class(TPersistent)
  private
    FOwner: TdxDockingManager;
    FAllowDock: TdxDockingTypes;
    FAllowDockClients: TdxDockingTypes;
    FAllowFloating: Boolean;
    FCaption: string;
    FCaptionButtons: TdxCaptionButtons;
    FDockable: Boolean;
    FImageIndex: Integer;
    FShowCaption: Boolean;
    FColor: TColor;
    FCursor: TCursor;
    FFont: TFont;
    FHint: string;
    FManagerColor: Boolean;
    FManagerFont: Boolean;
    FPopupMenu: TPopupMenu;
    FShowHint: Boolean;
    FTag: Integer;

    function IsColorStored: Boolean;
    function IsFontStored: Boolean;
    procedure SetColor(const Value: TColor);
    procedure SetFont(const Value: TFont);
    procedure SetManagerColor(const Value: Boolean);
    procedure SetManagerFont(const Value: Boolean);
  protected
    procedure AssignTo(Dest: TPersistent); override;
    function  GetOwner: TPersistent; override;
  public
    constructor Create(AOwner: TdxDockingManager); virtual;
    destructor Destroy; override;

    property AllowDock: TdxDockingTypes read FAllowDock write FAllowDock default dxDockingDefaultDockingTypes;
    property AllowDockClients: TdxDockingTypes read FAllowDockClients write FAllowDockClients default dxDockingDefaultDockingTypes;
    property AllowFloating: Boolean read FAllowFloating write FAllowFloating default True;
    property Caption: string read FCaption write FCaption;
    property CaptionButtons: TdxCaptionButtons read FCaptionButtons write FCaptionButtons default dxDockinkDefaultCaptionButtons;
    property Dockable: Boolean read FDockable write FDockable;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property ShowCaption: Boolean read FShowCaption write FShowCaption default True;
  published
    property Color: TColor read FColor write SetColor stored IsColorStored default clBtnFace;
    property Cursor: TCursor read FCursor write FCursor default crDefault;
    property Font: TFont read FFont write SetFont stored IsFontStored;
    property Hint: string read FHint write FHint;
    property ManagerColor: Boolean read FManagerColor write SetManagerColor default True;
    property ManagerFont: Boolean read FManagerFont write SetManagerFont default True;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property ShowHint: Boolean read FShowHint write FShowHint default False;
    property Tag: Integer read FTag write FTag default 0;
  end;

  TdxLayoutDockSiteProperties = class(TdxCustomDockControlProperties)
  published
    property AllowDockClients;
  end;

  TdxFloatDockSiteProperties = class(TdxCustomDockControlProperties)
  published
    property AllowDockClients;
  end;

  TdxSideContainerDockSiteProperties = class(TdxCustomDockControlProperties)
  published
    property AllowDock;
    property AllowDockClients;
    property AllowFloating;
    property CaptionButtons;
    property Dockable;
    property ImageIndex;
    property ShowCaption;
  end;

  TdxTabContainerDockSiteProperties = class(TdxCustomDockControlProperties)
  private
    FTabsPosition: TdxTabContainerTabsPosition;
    FTabsScroll: Boolean;
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create(AOwner: TdxDockingManager); override;
  published
    property AllowDock;
    property AllowDockClients;
    property AllowFloating;
    property CaptionButtons;
    property Dockable;
    property ImageIndex;
    property ShowCaption;
    property TabsPosition: TdxTabContainerTabsPosition read FTabsPosition write FTabsPosition default tctpBottom;
    property TabsScroll: Boolean read FTabsScroll write FTabsScroll default True;
  end;

  TdxDockingInternalState = (disManagerChanged, disContextMenu, disRedrawLocked);
  TdxDockingInternalStates = set of TdxDockingInternalState;

  TdxDockingController = class(TcxMessageWindow)
  private
    FActivatingDockControl: TdxCustomDockControl;
    FActiveDockControl: TdxCustomDockControl;
    FActiveDockControlLockCount: Integer;
    FApplicationActive: Boolean;
    FCalculatingControl: TdxCustomDockControl;
    FDestroyedDockControls: TList;
    FDockControls: TList;
    FDockingDockControl: TdxCustomDockControl;
    FDockManagers: TList;
    FDragImage: TdxDockingDragImage;
    FFont: TFont;
    FInternalState: TdxDockingInternalStates;
    FInvalidNC: TList;
    FInvalidNCBounds: TList;
    FInvalidRedraw: TList;
    FLoadedForms: TList;
    FResizingDockControl: TdxCustomDockControl;
    FSelectionBrush: TBrush;
    FTempBitmap: TBitmap;
    FUpdateNCLock: Integer;

    function GetDockControl(Index: Integer): TdxCustomDockControl;
    function GetDockControlCount: Integer;
    function GetDockManager(Index: Integer): TdxDockingManager;
    function GetDockManagerCount: Integer;
    function GetIsDocking: Boolean;
    function GetIsResizing: Boolean;
    procedure SetActiveDockControl(Value: TdxCustomDockControl);
    procedure SetApplicationActive(AValue: Boolean);
    procedure SetSelectionBrush(Value: TBrush);

    function ControlNeedUpdate(AControl: TdxCustomDockControl; AForm: TCustomForm): Boolean;
    procedure DestroyControls;
    procedure FinishDocking;
    procedure FinishResizing;
    procedure UpdateInvalidControlsNC;
    procedure UpdateLayouts(AForm: TCustomForm);
  protected
    procedure ActiveAppChanged(AActive: Boolean);
    procedure WndProc(var Message: TMessage); override;
    // Floating forms
    function IsParentForFloatDockSite(AParentForm: TCustomForm; AFloatDockSite: TdxFloatDockSite): Boolean;
    procedure BringToFrontFloatForms(AParentForm: TCustomForm; ATopMost: Boolean);
    procedure UpdateVisibilityFloatForms(AParentForm: TCustomForm; AShow: Boolean);
    procedure UpdateEnableStatusFloatForms(AParentForm: TCustomForm; AEnable: Boolean);
    // Docking
    procedure StartDocking(AControl: TdxCustomDockControl; const APoint: TPoint);
    procedure Docking(AControl: TdxCustomDockControl; const APoint: TPoint);
    procedure EndDocking(AControl: TdxCustomDockControl; const APoint: TPoint);

    // Docking controls
    procedure DockControlLoaded(AControl: TdxCustomDockControl);
    procedure DockManagerLoaded(AParentForm: TCustomForm);
    function IndexOfDockControl(AControl: TdxCustomDockControl): Integer;
    procedure RegisterDestroyedDockControl(AControl: TdxCustomDockControl);
    procedure RegisterDockControl(AControl: TdxCustomDockControl);
    procedure UnregisterDockControl(AControl: TdxCustomDockControl);
    // Docking manager
    function FindManager(AForm: TCustomForm): TdxDockingManager;
    function FindFormManager(AForm: TCustomForm): TdxDockingManager;
    procedure RegisterManager(AManager: TdxDockingManager);
    procedure UnregisterManager(AManager: TdxDockingManager);
    // Docking manager events
    procedure DoActiveDockControlChanged(ASender: TdxCustomDockControl; ACallEvent: Boolean);
    procedure DoCreateFloatSite(ASender: TdxCustomDockControl; ASite: TdxFloatDockSite);
    procedure DoCreateLayoutSite(ASender: TdxCustomDockControl; ASite: TdxLayoutDockSite);
    procedure DoCreateSideContainerSite(ASender: TdxCustomDockControl; ASite: TdxSideContainerDockSite);
    procedure DoCreateTabContainerSite(ASender: TdxCustomDockControl; ASite: TdxTabContainerDockSite);
    function DoCustomDrawResizingSelection(ASender: TdxCustomDockControl; DC: HDC;
      AZone: TdxZone; pt: TPoint; Erasing: Boolean): Boolean;
    function DoCustomDrawDockingSelection(ASender: TdxCustomDockControl; DC: HDC;
      AZone: TdxZone; R: TRect; Erasing: Boolean): Boolean;
    procedure DoSetFloatFormCaption(ASender: TdxCustomDockControl; AFloatForm: TdxFloatForm);
    procedure DoLayoutChanged(ASender: TdxCustomDockControl);
    procedure DoUpdateDockZones(ASender: TdxCustomDockControl);
    procedure DoUpdateResizeZones(ASender: TdxCustomDockControl);
    // Docking manager notifications
    procedure DoColorChanged(AForm: TCustomForm);
    procedure DoFontChanged(AForm: TCustomForm);
    procedure DoImagesChanged(AForm: TCustomForm);
    procedure DoLayoutLoaded(AForm: TCustomForm);
    procedure DoManagerChanged(AForm: TCustomForm);
    procedure DoOptionsChanged(AForm: TCustomForm);
    procedure DoPainterChanged(AForm: TCustomForm; AssignDefaultStyle: Boolean);
    procedure DoZonesWidthChanged(AForm: TCustomForm);
    // Docking manager saving/loding
    procedure ClearLayout(AForm: TCustomForm);
    procedure LoadLayoutFromCustomIni(AIniFile: TCustomIniFile; AForm: TCustomForm);
    procedure LoadControlFromCustomIni(AIniFile: TCustomIniFile; AParentForm: TCustomForm;
      AParentControl: TdxCustomDockControl; ASection: string);
    procedure SaveLayoutToCustomIni(AIniFile: TCustomIniFile; AForm: TCustomForm);
    procedure SaveControlToCustomIni(AIniFile: TCustomIniFile; AControl: TdxCustomDockControl);
    procedure UpdateLayout(AForm: TCustomForm);
    // Painting
    procedure BeginUpdateNC(ALockRedraw: Boolean = True);
    procedure EndUpdateNC;
    function CanUpdateNC(AControl: TdxCustomDockControl): Boolean;
    function CanCalculateNC(AControl: TdxCustomDockControl): Boolean;
    procedure DrawDockingSelection(ADockControl: TdxCustomDockControl;
      AZone: TdxZone; const APoint: TPoint; AErasing: Boolean);
    procedure DrawResizingSelection(ADockControl: TdxCustomDockControl;
      AZone: TdxZone; const APoint: TPoint; AErasing: Boolean);
    function PainterClass(AForm: TCustomForm): TdxDockControlPainterClass;
    procedure CalculateControls(AForm: TCustomForm);
    procedure InvalidateActiveDockControl;
    procedure InvalidateControls(AForm: TCustomForm; ANeedRecalculate: Boolean);
    procedure CreatePainterColors(AForm: TCustomForm);
    procedure RefreshPainterColors(AForm: TCustomForm);
    procedure ReleasePainterColors(AForm: TCustomForm);

    function IsUpdateNCLocked: Boolean;

    procedure CheckTempBitmap(ARect: TRect);
    procedure ReleaseTempBitmap;

    property ApplicationActive: Boolean read FApplicationActive write SetApplicationActive;
    property TempBitmap: TBitmap read FTempBitmap;
  public
    constructor Create; override;
    destructor Destroy; override;
    // Lock updates
    procedure BeginUpdate;
    procedure EndUpdate;
    // Find dock controls
    function GetDockControlAtPos(const P: TPoint): TdxCustomDockControl;
    function GetDockControlForWindow(AWnd: HWND; ADockWindow: HWND = 0): TdxCustomDockControl;
    function GetFloatDockSiteAtPos(pt: TPoint): TdxCustomDockControl;
    function GetNearestDockSiteAtPos(pt: TPoint): TdxCustomDockControl;
    function IsDockControlFocusedEx(ADockControl: TdxCustomDockControl): Boolean;
    // Default sites properties
    function DefaultLayoutSiteProperties(AForm: TCustomForm): TdxLayoutDockSiteProperties;
    function DefaultFloatSiteProperties(AForm: TCustomForm): TdxFloatDockSiteProperties;
    function DefaultHorizContainerSiteProperties(AForm: TCustomForm): TdxSideContainerDockSiteProperties;
    function DefaultVertContainerSiteProperties(AForm: TCustomForm): TdxSideContainerDockSiteProperties;
    function DefaultTabContainerSiteProperties(AForm: TCustomForm): TdxTabContainerDockSiteProperties;
    // Saving/Loading layout
    procedure LoadLayoutFromIniFile(AFileName: string; AForm: TCustomForm = nil);
    procedure LoadLayoutFromRegistry(ARegistryPath: string; AForm: TCustomForm = nil);
    procedure LoadLayoutFromStream(AStream: TStream; AForm: TCustomForm = nil);
    procedure SaveLayoutToIniFile(AFileName: string; AForm: TCustomForm = nil);
    procedure SaveLayoutToRegistry(ARegistryPath: string; AForm: TCustomForm = nil);
    procedure SaveLayoutToStream(AStream: TStream; AForm: TCustomForm = nil);

    function AutoHideInterval(AForm: TCustomForm): Integer;
    function AutoHideMovingInterval(AForm: TCustomForm): Integer;
    function AutoHideMovingSize(AForm: TCustomForm): Integer;
    function AutoShowInterval(AForm: TCustomForm): Integer;
    function Color(AForm: TCustomForm): TColor;
    function DockZonesWidth(AForm: TCustomForm): Integer;
    function Font(AForm: TCustomForm): TFont;
    function Images(AForm: TCustomForm): TCustomImageList;
    function Options(AForm: TCustomForm): TdxDockingOptions;
    function ViewStyle(AForm: TCustomForm): TdxDockingViewStyle;
    function ResizeZonesWidth(AForm: TCustomForm): Integer;
    function SelectionFrameWidth(AForm: TCustomForm): Integer;
    function TabsScrollInterval(AForm: TCustomForm): Integer;

    property ActiveDockControl: TdxCustomDockControl read FActiveDockControl write SetActiveDockControl;
    property DockControlCount: Integer read GetDockControlCount;
    property DockControls[Index: Integer]: TdxCustomDockControl read GetDockControl;
    property DockManagerCount: Integer read GetDockManagerCount;
    property DockManagers[Index: Integer]: TdxDockingManager read GetDockManager;
    property DockingDockControl: TdxCustomDockControl read FDockingDockControl;
    property IsDocking: Boolean read GetIsDocking;
    property IsResizing: Boolean read GetIsResizing;
    property ResizingDockControl: TdxCustomDockControl read FResizingDockControl;
    property SelectionBrush: TBrush read FSelectionBrush write SetSelectionBrush;
  end;

  TdxDockingManager = class(TComponent, IdxSkinSupport)
  private
    FAutoHideInterval: Integer;
    FAutoHideMovingInterval: Integer;
    FAutoHideMovingSize: Integer;
    FAutoShowInterval: Integer;
    FChangeLink: TChangeLink;
    FColor: TColor;
    FDefaultSitesPropertiesList: TList;
    FDockZonesWidth: Integer;
    FFont: TFont;
    FImages: TCustomImageList;
    FLookAndFeel: TcxLookAndFeel;
    FOptions: TdxDockingOptions;
    FResizeZonesWidth: Integer;
    FPainterClass: TdxDockControlPainterClass;
    FSelectionFrameWidth: Integer;
    FTabsScrollInterval: Integer;
    FUseDefaultSitesProperties: Boolean;
    FViewStyle: TdxDockingViewStyle;

    FOnActiveDockControlChanged: TNotifyEvent;
    FOnCreateFloatSite: TdxCreateFloatSiteEvent;
    FOnCreateLayoutSite: TdxCreateLayoutSiteEvent;
    FOnCreateSideContainer: TdxCreateSideContainerEvent;
    FOnCreateTabContainer: TdxCreateTabContainerEvent;
    FOnCustomDrawDockingSelection: TdxCustomDrawSelectionEvent;
    FOnCustomDrawResizingSelection: TdxCustomDrawSelectionEvent;
    FOnLayoutChanged: TdxDockControlNotifyEvent;
    FOnSetFloatFormCaption: TdxSetFloatFormCaptionEvent;
    FOnViewChanged: TNotifyEvent;
    FOnUpdateDockZones: TdxUpdateZonesEvent;
    FOnUpdateResizeZones: TdxUpdateZonesEvent;

    function IsDefaultSitePropertiesStored: Boolean;
    function GetDefaultSiteProperties(Index: Integer): TdxCustomDockControlProperties;
    function GetDefaultSitesPropertiesCount: Integer;
    function GetDefaultLayoutSiteProperties: TdxLayoutDockSiteProperties;
    function GetDefaultFloatSiteProperties: TdxFloatDockSiteProperties;
    function GetDefaultHorizContainerSiteProperties: TdxSideContainerDockSiteProperties;
    function GetDefaultVertContainerSiteProperties: TdxSideContainerDockSiteProperties;
    function GetDefaultTabContainerSiteProperties: TdxTabContainerDockSiteProperties;
    function GetParentForm: TCustomForm;
    procedure SetColor(const Value: TColor);
    procedure SetDefaultLayoutSiteProperties(Value: TdxLayoutDockSiteProperties);
    procedure SetDefaultFloatSiteProperties(Value: TdxFloatDockSiteProperties);
    procedure SetDefaultHorizContainerSiteProperties(Value: TdxSideContainerDockSiteProperties);
    procedure SetDefaultVertContainerSiteProperties(Value: TdxSideContainerDockSiteProperties);
    procedure SetDefaultTabContainerSiteProperties(Value: TdxTabContainerDockSiteProperties);
    procedure SetDockZonesWidth(const Value: Integer);
    procedure SetFont(const Value: TFont);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetLookAndFeel(Value: TcxLookAndFeel);
    procedure SetOptions(const Value: TdxDockingOptions);
    procedure SetResizeZonesWidth(const Value: Integer);
    procedure SetViewStyle(const Value: TdxDockingViewStyle);

    procedure DoOnImagesChanged(Sender: TObject);
    procedure DoOnFontChanged(Sender: TObject);
    procedure DoOnLFChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
    function IsLoading: Boolean;
    function IsDestroying: Boolean;

    procedure DoColorChanged;
    procedure DoFontChanged;
    procedure CreatePainterClass(AssignDefaultStyle: Boolean); virtual;
    function GetPainterClass: TdxDockControlPainterClass; virtual;
    procedure ReleasePainterClass; virtual;

    procedure CreateDefaultSitesProperties; virtual;
    procedure DestroyDefaultSitesProperties; virtual;
    procedure UpdateDefaultSitesPropertiesColor;
    procedure UpdateDefaultSitesPropertiesFont;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Saving/Loading layout
    procedure LoadLayoutFromIniFile(AFileName: string);
    procedure LoadLayoutFromRegistry(ARegistryPath: string);
    procedure LoadLayoutFromStream(AStream: TStream);
    procedure SaveLayoutToIniFile(AFileName: string);
    procedure SaveLayoutToRegistry(ARegistryPath: string);
    procedure SaveLayoutToStream(AStream: TStream);

    property DefaultSitesProperties[Index: Integer]: TdxCustomDockControlProperties read GetDefaultSiteProperties;
    property DefaultSitesPropertiesCount: Integer read GetDefaultSitesPropertiesCount;
    property PainterClass: TdxDockControlPainterClass read GetPainterClass;
    property ParentForm: TCustomForm read GetParentForm;
  published
    property AutoHideInterval: Integer read FAutoHideInterval write FAutoHideInterval default dxAutoHideInterval;
    property AutoHideMovingInterval: Integer read FAutoHideMovingInterval write FAutoHideMovingInterval default dxAutoHideMovingInterval;
    property AutoHideMovingSize: Integer read FAutoHideMovingSize write FAutoHideMovingSize default dxAutoHideMovingSize;
    property AutoShowInterval: Integer read FAutoShowInterval write FAutoShowInterval default dxAutoShowInterval;
    property Color: TColor read FColor write SetColor;
    property DefaultLayoutSiteProperties: TdxLayoutDockSiteProperties read GetDefaultLayoutSiteProperties
      write SetDefaultLayoutSiteProperties stored IsDefaultSitePropertiesStored;
    property DefaultFloatSiteProperties: TdxFloatDockSiteProperties read GetDefaultFloatSiteProperties
      write SetDefaultFloatSiteProperties stored IsDefaultSitePropertiesStored;
    property DefaultHorizContainerSiteProperties: TdxSideContainerDockSiteProperties read GetDefaultHorizContainerSiteProperties
      write SetDefaultHorizContainerSiteProperties stored IsDefaultSitePropertiesStored;
    property DefaultVertContainerSiteProperties: TdxSideContainerDockSiteProperties read GetDefaultVertContainerSiteProperties
      write SetDefaultVertContainerSiteProperties stored IsDefaultSitePropertiesStored;
    property DefaultTabContainerSiteProperties: TdxTabContainerDockSiteProperties read GetDefaultTabContainerSiteProperties
      write SetDefaultTabContainerSiteProperties stored IsDefaultSitePropertiesStored;
    property DockZonesWidth: Integer read FDockZonesWidth write SetDockZonesWidth default dxDockZonesWidth;
    property Font: TFont read FFont write SetFont;
    property Images: TCustomImageList read FImages write SetImages;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel write SetLookAndFeel;
    property Options: TdxDockingOptions read FOptions write SetOptions default dxDockingDefaultOptions;
    property ResizeZonesWidth: Integer read FResizeZonesWidth write SetResizeZonesWidth default dxResizeZonesWidth;
    property SelectionFrameWidth: Integer read FSelectionFrameWidth write FSelectionFrameWidth default dxSelectionFrameWidth;
    property TabsScrollInterval: Integer read FTabsScrollInterval write FTabsScrollInterval default dxTabsScrollInterval;
    property UseDefaultSitesProperties: Boolean read FUseDefaultSitesProperties write FUseDefaultSitesProperties default True;
    property ViewStyle: TdxDockingViewStyle read FViewStyle write SetViewStyle;

    property OnActiveDockControlChanged: TNotifyEvent read FOnActiveDockControlChanged
      write FOnActiveDockControlChanged;
    property OnCreateFloatSite: TdxCreateFloatSiteEvent read FOnCreateFloatSite
      write FOnCreateFloatSite;
    property OnCreateLayoutSite: TdxCreateLayoutSiteEvent read FOnCreateLayoutSite
      write FOnCreateLayoutSite;
    property OnCreateSideContainer: TdxCreateSideContainerEvent read FOnCreateSideContainer
      write FOnCreateSideContainer;
    property OnCreateTabContainer: TdxCreateTabContainerEvent read FOnCreateTabContainer
      write FOnCreateTabContainer;
    property OnCustomDrawDockingSelection: TdxCustomDrawSelectionEvent read FOnCustomDrawDockingSelection
      write FOnCustomDrawDockingSelection;
    property OnCustomDrawResizingSelection: TdxCustomDrawSelectionEvent read FOnCustomDrawResizingSelection
      write FOnCustomDrawResizingSelection;
    property OnLayoutChanged: TdxDockControlNotifyEvent read FOnLayoutChanged write FOnLayoutChanged;
    property OnSetFloatFormCaption: TdxSetFloatFormCaptionEvent read FOnSetFloatFormCaption
      write FOnSetFloatFormCaption;
    property OnViewChanged: TNotifyEvent read FOnViewChanged write FOnViewChanged;
    property OnUpdateDockZones: TdxUpdateZonesEvent read FOnUpdateDockZones
      write FOnUpdateDockZones;
    property OnUpdateResizeZones: TdxUpdateZonesEvent read FOnUpdateResizeZones
      write FOnUpdateResizeZones;
  end;

  function dxDockingController: TdxDockingController;

var
  CustomSkinPainterClass: TdxDockControlPainterClass;
  FOnRegisterDockControl: TcxNotifyProcedure;
  FOnUnregisterDockControl: TcxNotifyProcedure;

implementation

uses
  Types, TypInfo, SysUtils, CommCtrl, Registry, dxThemeManager, dxDockPanel,
  dxDockZones, dxDockControlXPView, dxDockControlNETView, dxDockControlOfficeView,
  Math, cxGeometry, dxOffice11;

const
  dxDockingTypeAlign: array[TdxDockingType] of TAlign =
    (alClient, alLeft, alTop, alRight, alBottom);

var
  FDockingController: TdxDockingController;
  FWndProcHookHandle: HHOOK;
  FUnitIsFinalized: Boolean;

function dxDockingController: TdxDockingController;
begin
  if (FDockingController = nil) and not FUnitIsFinalized then
    FDockingController := TdxDockingController.Create;
  Result := FDockingController;
end;

function GetParentFormForDocking(AControl: TControl): TCustomForm;
begin
  Result := GetParentForm(AControl);
  if Result is TdxFloatForm then
    Result := TdxFloatForm(Result).ParentForm;
end;

function ParentIsDockControl(AParent: TWinControl): Boolean;
begin
  Result := False;
  if AParent = nil then Exit;
  repeat
    if AParent is TdxCustomDockControl then
    begin
      Result := True;
      Break;
    end;
    AParent := AParent.Parent;
  until AParent = nil;
end;

function IsControlContainsDockSite(AControl: TControl): Boolean;
var
  I: Integer;
begin
  Result := False;
  if AControl is TWinControl then
  begin
    if AControl is TdxDockSite then
    begin
      Result := True;
      Exit;
    end;
    for I := 0 to TWinControl(AControl).ControlCount - 1 do
    begin
      Result := IsControlContainsDockSite(TWinControl(AControl).Controls[I]);
      if Result then
        Break;
    end;
  end;
end;

procedure dxMapWindowRect(AHandleFrom, AHandleTo: TcxHandle; var R: TRect; AClient: Boolean);
var
  AWindowRectFrom, AWindowRectTo: TRect;
begin
  if AClient then
    MapWindowRect(AHandleFrom, AHandleTo, R)
  else
  begin
    AWindowRectFrom := cxGetWindowRect(AHandleFrom);
    AWindowRectTo := cxGetWindowRect(AHandleTo);
    R := cxRectOffset(R, AWindowRectFrom.TopLeft);
    R := cxRectOffset(R, cxPointInvert(AWindowRectTo.TopLeft));
  end;
end;

{ TdxZone }

constructor TdxZone.Create(AOwner: TdxCustomDockControl; AWidth: Integer;
  AKind: TdxZoneKind);
begin
  Assert(AOwner <> nil, sdxInvaldZoneOwner);
  FOwner := AOwner;
  FWidth := AWidth;
  FKind := AKind;
end;

function TdxZone.IsZonePoint(pt: TPoint): Boolean;
begin
  Result := PtInRect(Rectangle, Owner.ScreenToWindow(pt));
end;

class function TdxZone.ValidateDockZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AOwner = AControl);
end;

class function TdxZone.ValidateResizeZone(AOwner, AControl: TdxCustomDockControl): Boolean;
begin
  Result := False;
end;

function TdxZone.GetDockingSelection(AControl: TdxCustomDockControl): TRect;
var
  R: TRect;
begin
  Result := Rectangle;
  R := cxGetWindowRect(Owner);
  OffsetRect(Result, R.Left, R.Top);
end;

function TdxZone.GetResizingSelection(pt: TPoint): TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

function TdxZone.GetDockIndex: Integer;
begin
  Result := -1;
end;

function TdxZone.GetSelectionFrameWidth: Integer;
begin
  Result := Owner.ControllerSelectionFrameWidth;
end;

function TdxZone.GetWidth: Integer;
begin
  if FWidth > 0 then
    Result := FWidth
  else
    Result := dxDockZonesWidth;
end;

function TdxZone.CanDock(AControl: TdxCustomDockControl): Boolean;
begin
  Result := Owner.CanDockHost(AControl, DockType);
end;

function TdxZone.CanResize(StartPoint, EndPoint: TPoint): Boolean;
begin
  Result := False;
end;

function TdxZone.CanConstrainedResize(NewWidth, NewHeight: Integer): Boolean;
begin
  Result := ((Owner.Constraints.MinHeight <= 0) or (NewHeight > Owner.Constraints.MinHeight)) and
    ((Owner.Constraints.MaxHeight <= 0) or (NewHeight < Owner.Constraints.MaxHeight)) and
    ((Owner.Constraints.MinWidth <= 0) or (NewWidth > Owner.Constraints.MinWidth)) and
    ((Owner.Constraints.MaxWidth <= 0) or (NewWidth < Owner.Constraints.MaxWidth));
end;

procedure TdxZone.DoDock(AControl: TdxCustomDockControl);
begin
  AControl.DockTo(Owner, DockType, DockIndex);
end;

procedure TdxZone.DoResize(StartPoint, EndPoint: TPoint);
begin
end;

procedure TdxZone.DrawDockingSelection(DC: HDC; AControl: TdxCustomDockControl; pt: TPoint);
var
  R: TRect;
  PenSize: Integer;
begin
  PenSize := SelectionFrameWidth;
  R := GetDockingSelection(AControl);
  with R do
  begin
    PatBlt(DC, Left + PenSize, Top, Right - Left - PenSize, PenSize, PATINVERT);
    PatBlt(DC, Right - PenSize, Top + PenSize, PenSize, Bottom - Top - PenSize, PATINVERT);
    PatBlt(DC, Left, Bottom - PenSize, Right - Left - PenSize, PenSize, PATINVERT);
    PatBlt(DC, Left, Top, PenSize, Bottom - Top - PenSize, PATINVERT);
  end;
end;

procedure TdxZone.DrawResizingSelection(DC: HDC; pt: TPoint);
var
  R: TRect;
begin
  R := GetResizingSelection(pt);
  with R do
    PatBlt(DC, Left, Top, Right - Left, Bottom - Top, PATINVERT);
end;

procedure TdxZone.PrepareSelectionRegion(ARegion: TcxRegion; AControl: TdxCustomDockControl; const ARect: TRect);
begin
  AControl.PrepareSelectionRegion(ARegion, ARect);
end;

{ TdxCustomDockControl }

constructor TdxCustomDockControl.Create(AOwner: TComponent);
begin
  Include(FInternalState, dcisCreating);
  inherited Create(AOwner);

  if not (AOwner is TCustomForm) then
    raise EdxException.Create(sdxInvalidOwner);
  Exclude(FInternalState, dcisCreating);

  Controller.RegisterDockControl(Self);
  FAllowDock := dxDockingDefaultDockingTypes;
  FAllowDockClients := dxDockingDefaultDockingTypes;
  FAllowFloating := True;
  FCaptionButtons := dxDockinkDefaultCaptionButtons;
  FDockable := True;
  FDockControls := TList.Create;
  FDockType := dtNone;
  FDockZones := TList.Create;
  FDockingPoint := cxInvalidPoint;
  FImageIndex := -1;
  ManagerColor := True;
  ManagerFont := True;
  FResizeZones := TList.Create;
  ParentColor := False;
  ParentFont := False;
  FAutoHidePosition := ahpUndefined;
  FShowCaption := True;
  FUseDoubleBuffer := False;
  ControlStyle := [csAcceptsControls, csClickEvents, csDoubleClicks, csSetCaption];
  SetBounds(0, 0, 300, 200);
end;

destructor TdxCustomDockControl.Destroy;
begin
  if not (dcisCreating in FInternalState) then
  begin
    if IsSelected then
      NoSelection;
    RemoveFromLayout;
    ClearZones(FResizeZones);
    FResizeZones.Free;
    ClearZones(FDockZones);
    FDockZones.Free;
    FDockControls.Free;
    FPainter.Free;
    FPainter := nil;
    Controller.UnregisterDockControl(Self);
  end;
  inherited;
end;

procedure TdxCustomDockControl.Assign(Source: TPersistent);
var
  AControl: TdxCustomDockControl;
begin
  if Source is TdxCustomDockControl then
  begin
    AControl := Source as TdxCustomDockControl;
    AllowDock := AControl.AllowDock;
    AllowDockClients := AControl.AllowDockClients;
    AllowFloating := AControl.AllowFloating;
    Caption := AControl.Caption;
    CaptionButtons := AControl.CaptionButtons;
    Dockable := AControl.Dockable;
    ImageIndex := AControl.ImageIndex;
    ShowCaption := AControl.ShowCaption;
    Color := AControl.Color;
    Cursor := AControl.Cursor;
    Font := AControl.Font;
    Hint := AControl.Hint;
    ManagerColor := AControl.ManagerColor;
    ManagerFont := AControl.ManagerFont;
    PopupMenu := AControl.PopupMenu;
    ShowHint := AControl.ShowHint;
    Tag := AControl.Tag;
  end
  else inherited Assign(Source)
end;

procedure TdxCustomDockControl.BeforeDestruction;
begin
  if not CanDestroy then
    raise EdxException.Create(sdxInvalidFloatingDeleting);
  inherited;
end;

procedure TdxCustomDockControl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);

  procedure DoSetBounds;
  begin
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
    if not IsUpdateLayoutLocked then
      UpdateOriginalSize;
  end;

  procedure DoChildResize;

    function GetDeltaSize: Integer;
    begin
      Result := SideContainer.GetDimension(AWidth - Width, AHeight - Height);
    end;

    function IsResizeNextControl: Boolean;
    begin
      Result := SideContainer.GetDimension(Left - ALeft, Top - ATop) = 0;
    end;

  begin
    SideContainer.DoChildResize(Self, GetDeltaSize, IsResizeNextControl);
  end;

  function IsAlignDisabled: Boolean;
  var
    AControl: TWinControl;
  begin
    AControl := Self;
    repeat
      Result := AControl.AlignDisabled;
      AControl := AControl.Parent;
    until (AControl = nil) or Result;
  end;

begin
  if (SideContainer <> nil) and (SideContainerItem = Self) and SideContainer.IsValidChild(Self) and
    not (dcisInternalResizing in FInternalState) then
  begin
    Include(FInternalState, dcisInternalResizing);
    try
      if IsAlignDisabled or IsUpdateLayoutLocked or SideContainer.IsAdjustBoundsLocked or SideContainer.IsUpdateLayoutLocked then
      begin
        SideContainer.SetChildBounds(Self, AWidth, AHeight);
        DoSetBounds;
      end
      else
        DoChildResize;
    finally
      Exclude(FInternalState, dcisInternalResizing);
    end;
  end
  else
    DoSetBounds;
end;

function TdxCustomDockControl.GetDockZoneAtPos(AControl: TdxCustomDockControl; pt: TPoint): TdxZone;
var
  I: Integer;
  AZone: TdxZone;
begin
  Result := nil;
  if AControl.Dockable then
    for I := 0 to DockZones.Count - 1 do
    begin
      AZone := TdxZone(DockZones[I]);
      if AZone.IsZonePoint(pt) and AZone.CanDock(AControl) then
      begin
        Result := AZone;
        break;
      end;
    end;
end;

function TdxCustomDockControl.GetResizeZoneAtPos(pt: TPoint): TdxZone;
var
  I: Integer;
  AZone: TdxZone;
begin
  Result := nil;
  if CanResizeAtPos(ScreenToClient(pt)) then
  begin
    for I := 0 to ResizeZones.Count - 1 do
    begin
      AZone := TdxZone(ResizeZones[I]);
      if AZone.IsZonePoint(pt) then
      begin
        Result := AZone;
        break;
      end;
    end;                                    
    if (Result = nil) and (ParentDockControl <> nil) then
      Result := ParentDockControl.GetResizeZoneAtPos(pt);
  end;
end;

function TdxCustomDockControl.IsNeeded: Boolean;
begin
  Result := ChildCount <> 1;
end;

function TdxCustomDockControl.IsValidChild(AControl: TdxCustomDockControl): Boolean;
begin
  Result := (AControl <> nil) and (AControl.ParentDockControl = Self) and
    (0 <= AControl.DockIndex) and (AControl.DockIndex < ChildCount) and
    AControl.Visible and not AControl.AutoHide;
end;

procedure TdxCustomDockControl.DockTo(AControl: TdxCustomDockControl; AType: TdxDockingType; AIndex: Integer);

  procedure ValidateControl;
  begin
    if AControl = LayoutDockSite then
      AControl := ParentDockControl
    else
      if (AControl = Container) and (Container.ChildCount = 2) and
        not Container.CanContainerDockHost(AType) then
      begin
        if DockIndex = 0 then
          AControl := Container.Children[1]
        else
          AControl := Container.Children[0];
      end;
  end;

begin
  if not CanDock or not AControl.CanDockHost(Self, AType) then
    Exit;
  BeginUpdateNC;
  try
    if AControl <> nil then
    begin
      ValidateControl;
      SelectComponent(AControl.TopMostDockControl);
      AControl.BeginUpdateLayout;
      try
        if ParentDockControl <> nil then
          if (AControl = Container) and Container.CanContainerDockHost(AType) then
            ExcludeFromDock
          else
            UnDock;
        AControl.CreateLayout(Self, AType, AIndex);
      finally
        AControl.EndUpdateLayout;
      end;
      if Assigned(FOnDock) then
        FOnDock(Self, AControl, AType, AIndex);
      Controller.DoLayoutChanged(Self);
      SelectComponent(Self);
    end;
    if doActivateAfterDocking in ControllerOptions then
      Activate;
  finally
    EndUpdateNC;
  end;
end;

procedure TdxCustomDockControl.Close;
begin
  DoClose;
end;

procedure TdxCustomDockControl.MakeFloating;
var
  pt: TPoint;
begin
  pt := Point(0, 0);
  if HandleAllocated then pt := WindowToScreen(pt);
  MakeFloating(pt.X, pt.Y);
end;

procedure TdxCustomDockControl.MakeFloating(XPos, YPos: Integer);
var
  ASite: TdxFloatDockSite;
  AWidth, AHeight: Integer;
begin
  if not CanDock then exit;
  if not AllowFloating then exit;
  BeginUpdateNC;
  try
    if FloatDockSite = nil then
    begin
      SelectComponent(TopMostDockControl);
      StoreDockPosition(Point(XPos, YPos));
      AWidth := OriginalWidth;
      AHeight := OriginalHeight;
      UnDock;
      ASite := TdxFloatDockSite.Create(Owner);
      ASite.Name := ASite.UniqueName;
      ASite.SetFloatFormPosition(XPos, YPos);
      ASite.SetFloatFormSize(AWidth, AHeight);
      ASite.CreateLayout(Self, dtClient, 0);
      ASite.ShowFloatForm;
      DoCreateFloatSite(ASite);
      if Assigned(FOnMakeFloating) then
        FOnMakeFloating(Self, XPos, YPos);
      Controller.DoLayoutChanged(Self);
      SelectComponent(Self);
      if doActivateAfterDocking in ControllerOptions then
        Activate;
    end
    else
      FloatDockSite.SetFloatFormPosition(XPos, YPos);
  finally
    EndUpdateNC;
  end;
end;

procedure TdxCustomDockControl.UnDock;
var
  AParentDockControl: TdxCustomDockControl;
begin
  if not CanDock then exit;
  BeginUpdateNC;
  try
    if AutoHide then AutoHide := False;
    if ParentDockControl <> nil then
    begin
      AParentDockControl := ParentDockControl;
      AParentDockControl.BeginUpdateLayout;
      try
        NoSelection;
        if Assigned(FOnUnDock) then
          FOnUnDock(Self, ParentDockControl);
        if FloatDockSite <> nil then
          FloatDockSite.HideFloatForm;
        AParentDockControl.DestroyLayout(Self);
        AParentDockControl.ChildVisibilityChanged(Self);
      finally
        AParentDockControl.EndUpdateLayout;
      end;
      Controller.DoLayoutChanged(Self);
    end;
  finally
    EndUpdateNC;
  end;
end;

procedure TdxCustomDockControl.AddDockControl(AControl: TdxCustomDockControl; AIndex: Integer);
var
  AOldIndex: Integer;
begin
  AOldIndex := FDockControls.IndexOf(AControl);
  if AOldIndex < 0 then
  begin
    if (0 <= AIndex) and (AIndex < FDockControls.Count) then
      FDockControls.Insert(AIndex, AControl)
    else FDockControls.Add(AControl)
  end
  else if AOldIndex <> AIndex then
  begin
    if (0 <= AIndex) and (AIndex < FDockControls.Count) then
      FDockControls.Move(AOldIndex, AIndex)
    else FDockControls.Move(AOldIndex, FDockControls.Count - 1);
  end;
end;

procedure TdxCustomDockControl.RemoveDockControl(AControl: TdxCustomDockControl);
begin
  if IndexOfControl(AControl) > -1 then
    FDockControls.Remove(AControl);
end;

function TdxCustomDockControl.IndexOfControl(AControl: TdxCustomDockControl): Integer;
begin
  Result := FDockControls.IndexOf(AControl);
end;

procedure TdxCustomDockControl.CheckDockRules;
begin
  if CanDock and (DockType <> dtNone) and not (DockType in AllowDock) then
  begin
    if AutoHide then AutoHide := False;
    FAllowFloating := True;
    MakeFloating;
  end;
end;

procedure TdxCustomDockControl.CheckDockClientsRules;
var
  I: Integer;
begin
  I := 0;
  while I < ChildCount do
  begin
    if not (Children[I].DockType in AllowDockClients) and Children[I].CanDock then
    begin
      if Children[I].AutoHide then Children[I].AutoHide := False;
      Children[I].FAllowFloating := True;
      Children[I].MakeFloating(ClientOrigin.X, ClientOrigin.Y);
      I := 0;
    end
    else Inc(I);
  end;
end;

procedure TdxCustomDockControl.ClearZones(AZones: TList);
var
  I: Integer;
begin
  if AZones = nil then exit;
  for I := 0 to AZones.Count - 1 do
    TdxZone(AZones[I]).Free;
  AZones.Clear;
end;

procedure TdxCustomDockControl.DrawDockingSelection(AZone: TdxZone; const pt: TPoint; AErasing: Boolean);
begin
  Controller.DrawDockingSelection(Self, AZone, pt, AErasing);
end;

procedure TdxCustomDockControl.PrepareSelectionRegion(ARegion: TcxRegion; const ARect: TRect);
begin
  ARegion.Combine(TcxRegion.Create(ARect), roSet);
end;

function TdxCustomDockControl.CanResizing(NewWidth, NewHeight: Integer): Boolean;
begin
  Result := True;
  if Assigned(FOnCanResize) then FOnCanResize(Self, NewWidth, NewHeight, Result);
end;

function TdxCustomDockControl.CanResizeAtPos(pt: TPoint): Boolean;
begin
  Result := not IsDesigning and not IsCaptionPoint(pt) and not IsCaptionCloseButtonPoint(pt) and
    not IsCaptionHideButtonPoint(pt) and not IsCaptionMaximizeButtonPoint(pt);
end;

procedure TdxCustomDockControl.DrawResizingSelection(AZone: TdxZone; pt: TPoint; Erasing: Boolean);
begin
  Controller.DrawResizingSelection(Self, AZone, pt, Erasing);
end;

function TdxCustomDockControl.GetFloatDockSite: TdxFloatDockSite;
begin
  if ParentDockControl is TdxFloatDockSite then
    Result := ParentDockControl as TdxFloatDockSite
  else Result := nil;
end;

function TdxCustomDockControl.GetFloatForm: TdxFloatForm;
begin
  if TopMostDockControl is TdxFloatDockSite then
    Result := (TopMostDockControl as TdxFloatDockSite).FloatForm
  else Result := nil;
end;

function TdxCustomDockControl.GetFloatFormActive: Boolean;
begin
  Result := (FloatForm <> nil) and FloatForm.Active;
end;

function TdxCustomDockControl.GetFloatFormVisible: Boolean;
begin
  Result := (FloatForm <> nil) and FloatForm.HandleAllocated and
    IsWindowVisible(FloatForm.Handle);
end;

procedure TdxCustomDockControl.StoreDockPosition(pt: TPoint);
begin
  FStoredPosition.DockIndex := DockIndex;
  FStoredPosition.Parent := ParentDockControl;
  if Container <> nil then
  begin
    if DockIndex < Container.ChildCount - 1 then
      FStoredPosition.SiblingAfter := Container.Children[DockIndex + 1]
    else
      FStoredPosition.SiblingAfter := nil;
    if DockIndex > 0 then
      FStoredPosition.SiblingBefore := Container.Children[DockIndex - 1]
    else
      FStoredPosition.SiblingBefore := nil;
    if DockType = Container.GetTailDockType then
      FStoredPosition.DockType := Container.GetTailDockType
    else
      FStoredPosition.DockType := Container.GetHeadDockType;
  end
  else
    FStoredPosition.DockType := DockType;
  FStoredPosition.OriginalHeight := OriginalHeight;
  FStoredPosition.OriginalWidth := OriginalWidth;
  if Assigned(FOnStoreDockPosition) then
    FOnStoreDockPosition(Self, FStoredPosition);
end;

procedure TdxCustomDockControl.RestoreDockPosition(pt: TPoint);
var
  AParentSite: TdxCustomDockControl;
begin
  if Assigned(FOnRestoreDockPosition) then
    FOnRestoreDockPosition(Self, FStoredPosition);
  if (FStoredPosition.Parent <> nil) and (FStoredPosition.Parent.DockState in [dsDocked, dsFloating]) and
    FStoredPosition.Parent.CanDockHost(Self, FStoredPosition.DockType) then
    AParentSite := FStoredPosition.Parent
  else
    if (FStoredPosition.SiblingBefore <> nil) and (FStoredPosition.SiblingBefore.DockState in [dsDocked, dsFloating]) and
      FStoredPosition.SiblingBefore.CanDockHost(Self, FStoredPosition.DockType) then
      AParentSite := FStoredPosition.SiblingBefore
    else
      if (FStoredPosition.SiblingAfter <> nil) and (FStoredPosition.SiblingAfter.DockState in [dsDocked, dsFloating]) and
        FStoredPosition.SiblingAfter.CanDockHost(Self, FStoredPosition.DockType) then
        AParentSite := FStoredPosition.SiblingAfter
      else
        AParentSite := nil;
  if AParentSite <> nil then
  begin
    FOriginalHeight := FStoredPosition.OriginalHeight;
    FOriginalWidth := FStoredPosition.OriginalWidth;
    DoStartDocking(pt);
    DockTo(AParentSite, FStoredPosition.DockType, FStoredPosition.DockIndex);
    DoEndDocking(pt);
    FStoredPosition.Parent := nil;
    FStoredPosition.SiblingAfter := nil;
    FStoredPosition.SiblingBefore := nil;
  end;
end;

procedure TdxCustomDockControl.AssignLayoutSiteProperties(ASite: TdxLayoutDockSite);
var
  AProperties: TdxCustomDockControlProperties;
begin
  AProperties := Controller.DefaultLayoutSiteProperties(ParentForm);
  if AProperties <> nil then
    AProperties.AssignTo(ASite);
end;

procedure TdxCustomDockControl.DoCreateLayoutSite(ASite: TdxLayoutDockSite);
begin
  AssignLayoutSiteProperties(ASite);
  if Assigned(FOnCreateLayoutSite) then
    FOnCreateLayoutSite(Self, ASite);
  Controller.DoCreateLayoutSite(Self, ASite);
end;

function TdxCustomDockControl.GetLayoutDockSite: TdxLayoutDockSite;
begin
  if (ParentDockControl <> nil) and (ParentDockControl.ChildCount = 2) then
  begin
    if ParentDockControl.Children[1 - DockIndex] is TdxLayoutDockSite then
        Result := ParentDockControl.Children[1 - DockIndex] as TdxLayoutDockSite
      else Result := nil
  end
  else Result := nil;
end;

function TdxCustomDockControl.HasAsParent(AControl: TdxCustomDockControl): Boolean;
var
  AParent: TdxCustomDockControl;
begin
  Result := False;
  AParent := Self;
  while AParent <> nil do
  begin
    if AParent = AControl then
    begin
      Result := True;
      Break;
    end;
    AParent := AParent.ParentDockControl;
  end;
end;

function TdxCustomDockControl.GetParentDockControl: TdxCustomDockControl;
begin
  Result := FParentDockControl;
end;

function TdxCustomDockControl.GetParentForm: TCustomForm;
begin
  if Owner is TCustomForm then
    Result := TCustomForm(Owner)
  else
    Result := nil;
end;

function TdxCustomDockControl.GetParentFormActive: Boolean;
begin
  Result := (ParentForm <> nil) and
    (not IsMDIForm(ParentForm) and Forms.GetParentForm(ParentForm).Active or
    IsMDIForm(ParentForm) and Application.Active);
end;

function TdxCustomDockControl.GetParentFormVisible: Boolean;
begin
  Result := (ParentForm <> nil) and (ParentForm.Visible or
    (fsVisible in ParentForm.FormState));
end;

function TdxCustomDockControl.GetTopMostDockControl: TdxCustomDockControl;
begin
  if ParentDockControl <> nil then
    Result := ParentDockControl.TopMostDockControl
  else
    Result := Self;
end;

procedure TdxCustomDockControl.ReadAutoHidePosition(Reader: TReader);
begin
  FAutoHidePosition := TdxAutoHidePosition(Reader.ReadInteger)
end;

procedure TdxCustomDockControl.ReadDockType(Reader: TReader);
begin
  SetDockType(TdxDockingType(Reader.ReadInteger));
end;

procedure TdxCustomDockControl.ReadOriginalWidth(Reader: TReader);
begin
  FOriginalWidth := Reader.ReadInteger;
end;

procedure TdxCustomDockControl.ReadOriginalHeight(Reader: TReader);
begin
  FOriginalHeight := Reader.ReadInteger;
end;

procedure TdxCustomDockControl.WriteAutoHidePosition(Writer: TWriter);
begin
  Writer.WriteInteger(Integer(FAutoHidePosition));
end;

procedure TdxCustomDockControl.WriteDockType(Writer: TWriter);
begin
  Writer.WriteInteger(Integer(DockType));
end;

procedure TdxCustomDockControl.WriteOriginalWidth(Writer: TWriter);
begin
  Writer.WriteInteger(OriginalWidth);
end;

procedure TdxCustomDockControl.WriteOriginalHeight(Writer: TWriter);
begin
  Writer.WriteInteger(OriginalHeight);
end;

procedure TdxCustomDockControl.AlignControls(AControl: TControl; var Rect: TRect);
begin
  BeginUpdateNC;
  try
    inherited AlignControls(AControl, Rect);
  finally
    EndUpdateNC;
  end;
end;

procedure TdxCustomDockControl.CreateHandle;
begin
  inherited;
  if ParentDockControl <> nil then
    ParentDockControl.UpdateDockZones;
end;

procedure TdxCustomDockControl.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params.WindowClass do
    style := style and not (CS_VREDRAW or CS_HREDRAW);
end;

procedure TdxCustomDockControl.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('AutoHidePosition', ReadAutoHidePosition, WriteAutoHidePosition, AutoHide);
  Filer.DefineProperty('DockType', ReadDockType, WriteDockType, True);
  Filer.DefineProperty('OriginalWidth', ReadOriginalWidth, WriteOriginalWidth, True);
  Filer.DefineProperty('OriginalHeight', ReadOriginalHeight, WriteOriginalHeight, True);
end;

procedure TdxCustomDockControl.DoEnter;
begin
  if (Controller.ActiveDockControl <> Self) and
    not ((Controller.ActiveDockControl <> nil) and
      Controller.ActiveDockControl.HasAsParent(Self)) then
    Controller.ActiveDockControl := Self;
  inherited;
end;

procedure TdxCustomDockControl.Loaded;
var
  APosition: TdxAutoHidePosition;
begin
  inherited;
  BeginUpdateNC;
  try
    if AutoHide and (AutoHideHostSite <> nil) then
    begin
      APosition := FAutoHidePosition;
      if APosition = ahpUndefined then
        APosition := GetAutoHidePosition;
      AutoHideHostSite.RegisterAutoHideDockControl(Self, APosition);
    end;
  finally
    EndUpdateNC;
  end;
  dxDockingController.DockControlLoaded(Self);
end;

procedure TdxCustomDockControl.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FStoredPosition.Parent then FStoredPosition.Parent := nil;
    if AComponent = FStoredPosition.SiblingAfter then FStoredPosition.SiblingAfter := nil;
    if AComponent = FStoredPosition.SiblingBefore then FStoredPosition.SiblingBefore := nil;
  end;
end;

procedure TdxCustomDockControl.ReadState(Reader: TReader);
begin
  inherited ReadState(Reader);
  if (Reader.Parent is TdxCustomDockControl) and (DockType <> dtNone) then
    IncludeToDock(Reader.Parent as TdxCustomDockControl, DockType, -1);
end;

procedure TdxCustomDockControl.SetParent(AParent: TWinControl);
begin
  DoParentChanging;
  inherited SetParent(AParent);
  DoParentChanged;
end;

procedure TdxCustomDockControl.VisibleChanging;
begin
  DoVisibleChanging;
end;

function TdxCustomDockControl.CanFocusEx: Boolean;
var
  AParentForm: TCustomForm;
begin
  AParentForm := Forms.GetParentForm(Self);
  Result := CanFocus and ((AParentForm = nil) or
    AParentForm.CanFocus and AParentForm.Enabled and AParentForm.Visible);
end;

function TdxCustomDockControl.IsDockPanel: Boolean;
begin
  Result := False;
end;

function TdxCustomDockControl.GetDesignRect: TRect;
begin
  if ParentDockControl = nil then
  begin
    with WindowRect do
      Result := Rect(Right - 16 - 3, Bottom - 16 - 3, Right - 3, Bottom - 3);
  end
  else
  begin
    Result := GetTopMostDockControl.GetDesignRect;
    dxMapWindowRect(GetTopMostDockControl.Handle, Handle, Result, False);
  end;
end;

function TdxCustomDockControl.GetDesignHitTest(const APoint: TPoint; AShift: TShiftState): Boolean;
begin
  Result := (IsCaptionPoint(APoint) and (ssLeft in AShift)) or
    Controller.IsDocking or Controller.IsResizing or
    FCaptionIsDown or FCloseButtonIsDown or FHideButtonIsDown or FMaximizeButtonIsDown;
end;

function TdxCustomDockControl.IsSelected: Boolean;
begin
  Result := (FDesignHelper <> nil) and FDesignHelper.IsObjectSelected(ParentForm, Self);
end;

procedure TdxCustomDockControl.Modified;
begin
  DesignController.DesignerModified(ParentForm);
end;

procedure TdxCustomDockControl.NoSelection;
begin
  if FDesignHelper <> nil then
    FDesignHelper.SelectObject(ParentForm, nil);
end;

procedure TdxCustomDockControl.SelectComponent(AComponent: TComponent);
begin
  if (FDesignHelper <> nil) and not (csDestroying in AComponent.ComponentState) then
  {$IFNDEF DELPHI6}
    if not (AComponent is TdxCustomDockSite) or (TdxCustomDockSite(AComponent).FloatForm = nil) then
  {$ENDIF}
      FDesignHelper.SelectObject(ParentForm, AComponent);
end;

function TdxCustomDockControl.UniqueName: string;
begin
  if FDesignHelper <> nil then
    Result := FDesignHelper.UniqueName(ClassName)
  else Result := '';
end;

function TdxCustomDockControl.IsAncestor: Boolean;
begin
  Result := csAncestor in ComponentState;
end;

function TdxCustomDockControl.IsDesigning: Boolean;
begin
  Result := csDesigning in ComponentState;
end;

function TdxCustomDockControl.IsDestroying: Boolean;
begin
  Result := (csDestroying in (Application.ComponentState + ComponentState)) or (dcisDestroyed in FInternalState);
end;

function TdxCustomDockControl.IsLoading: Boolean;
begin
  Result := csLoading in ComponentState;
end;

procedure TdxCustomDockControl.CaptureMouse;
begin
  FSavedCaptureControl := GetCaptureControl;
  SetCaptureControl(Self);
end;

procedure TdxCustomDockControl.ReleaseMouse;
begin
  SetCaptureControl(FSavedCaptureControl);
  FSavedCaptureControl := nil;
end;

procedure TdxCustomDockControl.Activate;
begin
  Controller.ActiveDockControl := Self;
  CheckActiveDockControl;
end;

procedure TdxCustomDockControl.CheckActiveDockControl;
begin
// do nothing
end;

procedure TdxCustomDockControl.DoActivate;
begin
// do nothing
end;

procedure TdxCustomDockControl.DoActiveChanged(AActive, ACallEvent: Boolean);
begin
  if TabContainer <> nil then
  begin
    if AActive then TabContainer.ActiveChild := Self; // !!! Flag
    TabContainer.InvalidateNC(False);
  end;
  if AutoHide and not Visible and AActive then
    Visible := True;
  if AActive and not dxDockingController.IsDockControlFocusedEx(Self) then
  begin
    SetWindowPos(PopupParent.Handle, 0{HWND_TOP}, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER);
    if TabContainer = nil then
      CheckActiveDockControl;
  end;
  InvalidateCaptionArea;

  if ACallEvent and Assigned(FOnActivate) then
    FOnActivate(Self, AActive);
end;

procedure TdxCustomDockControl.DoClose;
var
  ACanClose: Boolean;
begin
  ACanClose := True;
  if Assigned(FOnCloseQuery) then
    FOnCloseQuery(Self, ACanClose);
  if ACanClose then
  begin
    if Active then Controller.ActiveDockControl := nil;
    if Assigned(FOnClose) then FOnClose(Self);       
    if (doFreeOnClose in ControllerOptions) then
      DoDestroy
    else
      if (doUndockOnClose in ControllerOptions) then
        UnDock
      else
        Visible := False;
  end;
end;

function TdxCustomDockControl.CanDestroy: Boolean;
begin
  Result := not IsDesigning or (FloatDockSite = nil) or FloatDockSite.IsDestroying;
end;

procedure TdxCustomDockControl.DoDestroy;
begin
  RemoveFromLayout;
  Include(FInternalState, dcisDestroyed);
  Controller.RegisterDestroyedDockControl(Self);
end;

procedure TdxCustomDockControl.ChildVisibilityChanged(Sender: TdxCustomDockControl);
begin
end;

procedure TdxCustomDockControl.DoVisibleChanged;
begin
  if Assigned(FOnVisibleChanged) then FOnVisibleChanged(Self);
end;

procedure TdxCustomDockControl.DoVisibleChanging;
begin
  if Assigned(FOnVisibleChanging) then FOnVisibleChanging(Self);
end;

procedure TdxCustomDockControl.SetVisibility(Value: Boolean);
begin
  BeginUpdateVisibility;
  try
    Visible := Value;
  finally
    EndUpdateVisibility;
  end;
end;

procedure TdxCustomDockControl.UpdateAutoHideControlsVisibility;
begin
  if UpdateVisibilityLock > 0 then exit;
  if (ParentDockControl <> nil) and ParentDockControl.AutoHide and
    (ParentDockControl.ValidChildCount = 0) then
    ParentDockControl.UpdateAutoHideControlsVisibility;
  BeginUpdateVisibility;
  try
    if not AutoHide and (AutoHideHostSite <> nil) and Visible and StoredAutoHide then
    begin
      FStoredAutoHide := False;
      AutoHide := True;
      AutoHideHostSite.ImmediatelyShow(Self);
    end
    else
      if AutoHide and (AutoHideHostSite <> nil) then
      begin
        if not Visible then
        begin
          BeginUpdateNC;
          try
            AutoHideHostSite.NCChanged;
            AutoHide := False;
            FStoredAutoHide := True;
            SetVisibility(False);
          finally
            EndUpdateNC;
          end;
        end
        else
          AutoHideHostSite.ShowingControl := Self;
      end;
  finally
    EndUpdateVisibility;
  end;
end;

procedure TdxCustomDockControl.UpdateAutoHideHostSiteVisibility;
begin
  if AutoHideHostSite = nil then exit;
  BeginUpdateNC;
  try
    if (AutoHideControl <> nil) and (AutoHideControl <> Self) then
      AutoHideHostSite.NCChanged;
  finally
    EndUpdateNC;
  end;
end;

procedure TdxCustomDockControl.UpdateLayoutControlsVisibility;
begin
  if LayoutDockSite = nil then exit;
  LayoutDockSite.BeginUpdateVisibility;
  try
    if (Visible and not AutoHide) or (LayoutDockSite.ChildCount > 0) then
      LayoutDockSite.Visible := True
    else if not Visible and (LayoutDockSite.ChildCount = 0) then
      LayoutDockSite.Visible := False;
  finally
    LayoutDockSite.EndUpdateVisibility;
  end;
end;

procedure TdxCustomDockControl.UpdateParentControlsVisibility;
begin
  if ParentDockControl = nil then exit;
  BeginUpdateNC;
  try
    NCChanged;
    if not AutoHide then
      ParentDockControl.NCChanged;
    ParentDockControl.ChildVisibilityChanged(Self);
    if not AutoHide then
      ParentDockControl.UpdateLayout;
  finally
    EndUpdateNC;
  end;
end;

procedure TdxCustomDockControl.UpdateRelatedControlsVisibility;
begin
  BeginUpdateNC;
  try
    BeginUpdateVisibility;
    try
      UpdateAutoHideHostSiteVisibility;
      UpdateParentControlsVisibility;
      UpdateLayoutControlsVisibility;
    finally
      EndUpdateVisibility;
    end;
  finally
    EndUpdateNC;
  end;
end;

procedure TdxCustomDockControl.BeginUpdateVisibility;
begin
  Inc(FUpdateVisibilityLock);
end;

procedure TdxCustomDockControl.EndUpdateVisibility;
begin
  Dec(FUpdateVisibilityLock);
end;

function TdxCustomDockControl.CanUndock(AControl: TdxCustomDockControl): Boolean;
begin
  Result := (ValidChildCount > 1) or (ParentDockControl = nil) or ParentDockControl.CanUndock(Self);
end;

function TdxCustomDockControl.GetDockingTargetControlAtPos(pt: TPoint): TdxCustomDockControl;
begin
  Result := Controller.GetDockControlAtPos(pt);
  if Result = nil then
    Result := Controller.GetFloatDockSiteAtPos(pt);
  if Result = nil then
    Result := Controller.GetNearestDockSiteAtPos(pt);
end;

function TdxCustomDockControl.GetFloatDockRect(pt: TPoint): TRect;
begin
  Result := GetDockingRect;
  OffsetRect(Result, pt.X - DockingOrigin.X, pt.Y - DockingOrigin.Y);
end;

procedure TdxCustomDockControl.DoStartDocking(pt: TPoint);
begin
  if Assigned(FOnStartDocking) then
    FOnStartDocking(Self, pt.X, pt.Y);
end;

procedure TdxCustomDockControl.StartDocking(pt: TPoint);
var
  R: TRect;
begin
  if IsAncestor then
    raise EdxException.Create(sdxAncestorError);
  if not Dockable or (AutoHideControl <> nil) then exit;

  DoStartDocking(pt);
  Controller.FDockingDockControl := Self;
  if FloatDockSite <> nil then
  begin
    FDockingOrigin.X := pt.X - FloatDockSite.FloatForm.Left;
    FDockingOrigin.Y := pt.Y - FloatDockSite.FloatForm.Top;
  end
  else
  begin
    R := cxGetWindowRect(Self);
    FDockingOrigin.X := pt.X - R.Left;
    if (DockingRect.Left > DockingOrigin.X) or (DockingOrigin.X > DockingRect.Right) then
      FDockingOrigin.X := (DockingRect.Right - DockingRect.Left) div 2;
    FDockingOrigin.Y := pt.Y - R.Top;
    if (DockingRect.Top > DockingOrigin.Y) or (DockingOrigin.Y > DockingRect.Bottom) then
      FDockingOrigin.Y := (DockingRect.Bottom - DockingRect.Top) div 2;
  end;
  Controller.StartDocking(Self, pt);
  SetDockingParams(nil, pt);
  CaptureMouse;
end;

procedure TdxCustomDockControl.DoCanDocking(Source: TdxCustomDockControl; pt: TPoint;
  TargetZone: TdxZone; var Accept: Boolean);
begin
  if Assigned(FOnCanDocking) then
    FOnCanDocking(Self, Source, TargetZone, pt.X, pt.Y, Accept);
end;

procedure TdxCustomDockControl.DoDocking(pt: TPoint; TargetZone: TdxZone; var Accept: Boolean);
begin
  if Assigned(FOnDocking) then
    FOnDocking(Self, TargetZone, pt.X, pt.Y, Accept);
end;

procedure TdxCustomDockControl.Docking(pt: TPoint);
var
  AAccept: Boolean;
  ATargetControl: TdxCustomDockControl;
  ATargetZone: TdxZone;
begin
  ATargetControl := GetDockingTargetControlAtPos(pt);
  if (ATargetControl <> nil) and not (GetKeyState(VK_CONTROL) < 0) then
  begin
    ATargetZone := ATargetControl.GetDockZoneAtPos(Self, pt);
    AAccept := True;
    DoDocking(pt, ATargetZone, AAccept);
    if (ATargetZone <> nil) and (ATargetZone.Owner <> nil) then
      ATargetZone.Owner.DoCanDocking(Self, pt, ATargetZone, AAccept);
    if not AAccept then ATargetZone := nil;
  end
  else
    ATargetZone := nil;
  SetDockingParams(ATargetZone, pt);
  Perform(WM_SETCURSOR, Handle, HTCLIENT);
end;

procedure TdxCustomDockControl.DoEndDocking(pt: TPoint);
begin
  if Assigned(FOnEndDocking) then
    FOnEndDocking(Self, DockingTargetZone, pt.X, pt.Y);
end;

procedure TdxCustomDockControl.EndDocking(pt: TPoint; Cancel: Boolean);
var
  ATargetZone: TdxZone;
begin
  try
    ATargetZone := DockingTargetZone;
    ReleaseMouse;
    SetDockingParams(nil, cxInvalidPoint);
    Controller.EndDocking(Self, pt);

    if not Cancel then
    begin
      if ATargetZone <> nil then
        ATargetZone.DoDock(Self)
      else
        if AllowFloating then
          MakeFloating(pt.X - DockingOrigin.X, pt.Y - DockingOrigin.Y);
    end;
    DoEndDocking(pt);
  finally
    Controller.FDockingDockControl := nil;
  end;
end;

procedure TdxCustomDockControl.DoStartResize(pt: TPoint);
begin
  if Assigned(FOnStartResizing) then
    FOnStartResizing(Self, ResizingSourceZone, pt.X, pt.Y);
end;

procedure TdxCustomDockControl.StartResize(pt: TPoint);
begin
  FResizingSourceZone := GetResizeZoneAtPos(pt);
  if FResizingSourceZone = nil then exit;

  DoStartResize(pt);
  Controller.FResizingDockControl := Self;
  FResizingOrigin := pt;
  FResizingPoint := pt;
  DrawResizingSelection(ResizingSourceZone, ResizingPoint, False);
  CaptureMouse;
end;

procedure TdxCustomDockControl.DoResizing(pt: TPoint);
begin
  if Assigned(FOnResizing) then
    FOnResizing(Self, ResizingSourceZone, pt.X, pt.Y);
end;

procedure TdxCustomDockControl.Resizing(pt: TPoint);
begin
  if ResizingSourceZone = nil then exit;
  if ResizingSourceZone.CanResize(ResizingOrigin, pt) then
  begin
    DoResizing(pt);;
    DrawResizingSelection(ResizingSourceZone, ResizingPoint, True);
    FResizingPoint := pt;
    DrawResizingSelection(ResizingSourceZone, ResizingPoint, False);
  end;
end;

procedure TdxCustomDockControl.DoEndResize(pt: TPoint);
begin
  if Assigned(FOnEndResizing) then
    FOnEndResizing(Self, ResizingSourceZone, pt.X, pt.Y);
end;

procedure TdxCustomDockControl.EndResize(pt: TPoint; Cancel: Boolean);
begin
  ReleaseMouse;
  if ResizingSourceZone = nil then exit;

  DrawResizingSelection(ResizingSourceZone, ResizingPoint, True);
  try
    if not Cancel and (ParentDockControl <> nil) then
    begin
      if ResizingSourceZone.Owner.AutoHide then
      begin
        ResizingSourceZone.DoResize(ResizingOrigin, ResizingPoint);
        if ResizingSourceZone.Owner.AutoHideHostSite <> nil then
          ResizingSourceZone.Owner.AutoHideHostSite.SetFinalPosition(ResizingSourceZone.Owner);
      end
      else
      begin
        BeginUpdateNC;
        try
          ParentDockControl.NCChanged;
          ResizingSourceZone.DoResize(ResizingOrigin, ResizingPoint);
        finally
          EndUpdateNC;
        end;
      end;
    end;
    DoEndResize(pt);
  finally
    Controller.FResizingDockControl := nil;
    Perform(WM_SETCURSOR, Handle, HTCLIENT);
  end;
end;

function TdxCustomDockControl.CanDock: Boolean;
begin
  Result := False;
end;

function TdxCustomDockControl.CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean;
begin
  Result := (AControl.ParentForm = ParentForm) and not HasAsParent(AControl);
  Result := Result and AControl.CanDock;
  Result := Result and (AType in AControl.AllowDock);
  Result := Result and (AType in AllowDockClients);
  Result := Result and (AutoHideControl = nil);
end;

function TdxCustomDockControl.CanMaximize: Boolean;
begin
  Result := False;
end;

procedure TdxCustomDockControl.CreateContainerLayout(AContainer: TdxContainerDockSite;
  AControl: TdxCustomDockControl; AType: TdxDockingType; Index: Integer);
begin
  if AContainer <> nil then
  begin
    AContainer.BeginUpdateLayout;
    try
      if AType = AContainer.GetTailDockType then Inc(Index);
      AContainer.CreateLayout(AControl, AType, Index);
    finally
      AContainer.EndUpdateLayout;
    end;
  end;
end;

function TdxCustomDockControl.GetContainer: TdxContainerDockSite;
begin
  if ParentDockControl is TdxContainerDockSite then
    Result := ParentDockControl as TdxContainerDockSite
  else Result := nil;
end;

procedure TdxCustomDockControl.AssignSideContainerSiteProperties(ASite: TdxSideContainerDockSite);
var
  AProperties: TdxCustomDockControlProperties;
begin
  AProperties := Controller.DefaultVertContainerSiteProperties(ParentForm);
  if (ASite is TdxVertContainerDockSite) and (AProperties <> nil) then
    AProperties.AssignTo(ASite);
  AProperties := Controller.DefaultHorizContainerSiteProperties(ParentForm);
  if (ASite is TdxHorizContainerDockSite) and (AProperties <> nil) then
    AProperties.AssignTo(ASite);
end;

function TdxCustomDockControl.CanAcceptSideContainerItems(AContainer: TdxSideContainerDockSite): Boolean;
begin
  Result := False;
end;

procedure TdxCustomDockControl.DoCreateSideContainerSite(ASite: TdxSideContainerDockSite);
begin
  AssignSideContainerSiteProperties(ASite);
  if Assigned(FOnCreateSideContainer) then
    FOnCreateSideContainer(Self, ASite);
  Controller.DoCreateSideContainerSite(Self, ASite);
end;

procedure TdxCustomDockControl.CreateSideContainerLayout(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
var
  AIndex: Integer;
  AContainerClass: TdxSideContainerDockSiteClass;
  AContainerSite: TdxSideContainerDockSite;
  AParentControl: TdxCustomDockControl;
begin
  case AType of
    dtleft, dtRight: AContainerClass := TdxHorizContainerDockSite;
    dtTop, dtBottom: AContainerClass := TdxVertContainerDockSite;
  else
    AContainerClass := nil;
    Assert(False, Format(sdxInternalErrorCreateLayout, [TdxSideContainerDockSite.ClassName]));
  end;
  AIndex := DockIndex;
  AParentControl := ParentDockControl;
  AParentControl.BeginUpdateLayout;
  try
    ExcludeFromDock;
    AContainerSite := AContainerClass.Create(Owner);
    AContainerSite.Name := AContainerSite.UniqueName;
    AContainerSite.AdjustControlBounds(Self);
    AContainerSite.BeginUpdateLayout;
    try
      AContainerSite.IncludeToDock(AParentControl, DockType, AIndex);
      IncludeToDock(AContainerSite, dtTop, 0);
      if Index = -1 then
      begin
        if AType = AContainerSite.GetHeadDockType then
          AControl.IncludeToDock(AContainerSite, AContainerSite.GetHeadDockType, 0)
        else AControl.IncludeToDock(AContainerSite, AContainerSite.GetTailDockType, 1);
      end
      else AControl.IncludeToDock(AContainerSite, AContainerSite.GetHeadDockType, Index);
      AContainerSite.AdjustChildrenBounds(AControl);
    finally
      AContainerSite.EndUpdateLayout;
    end;
  finally
    AParentControl.EndUpdateLayout;
  end;
  DoCreateSideContainerSite(AContainerSite);
end;

procedure TdxCustomDockControl.DoMaximize;
begin
  if SideContainer <> nil then
  begin
    if (SideContainer.ActiveChild <> nil) and
      (SideContainer.ActiveChildIndex = SideContainerIndex) then
      SideContainer.ActiveChild := nil
    else SideContainer.ActiveChild :=
      SideContainer.Children[SideContainerIndex];
  end;
end;

function TdxCustomDockControl.GetSideContainer: TdxSideContainerDockSite;
begin
  if Container is TdxSideContainerDockSite then
    Result := Container as TdxSideContainerDockSite
  else
    if TabContainer <> nil then
      Result := TabContainer.GetSideContainer
    else
      Result := nil;
end;

function TdxCustomDockControl.GetSideContainerItem: TdxCustomDockControl;
begin
  if Container is TdxSideContainerDockSite then
    Result := Self
  else if (TabContainer <> nil) and (TabContainer.SideContainer <> nil) then
    Result := TabContainer
  else Result := nil;
end;

function TdxCustomDockControl.GetSideContainerIndex: Integer;
begin
  if SideContainerItem <> nil then
    Result := SideContainerItem.DockIndex
  else Result := -1;
end;

procedure TdxCustomDockControl.AssignTabContainerSiteProperies(ASite: TdxTabContainerDockSite);
var
  AProperties: TdxCustomDockControlProperties;
begin
  AProperties := Controller.DefaultTabContainerSiteProperties(ParentForm);
  if AProperties <> nil then
    AProperties.AssignTo(ASite);
end;

function TdxCustomDockControl.CanAcceptTabContainerItems(AContainer: TdxTabContainerDockSite): Boolean;
begin
  Result := False;
end;

procedure TdxCustomDockControl.DoCreateTabContainerSite(ASite: TdxTabContainerDockSite);
begin
  AssignTabContainerSiteProperies(ASite);
  if Assigned(FOnCreateTabContainer) then
    FOnCreateTabContainer(Self, ASite);
  Controller.DoCreateTabContainerSite(Self, ASite);
end;

procedure TdxCustomDockControl.CreateTabContainerLayout(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
var
  AIndex: Integer;
  AContainerSite: TdxTabContainerDockSite;
  AParentControl: TdxCustomDockControl;
begin
  AIndex := DockIndex;
  AParentControl := ParentDockControl;
  AParentControl.BeginUpdateLayout;
  try
    ExcludeFromDock;
    AContainerSite := TdxTabContainerDockSite.Create(Owner);
    AContainerSite.Name := AContainerSite.UniqueName;
    AContainerSite.BeginUpdateLayout;
    try
      AContainerSite.AdjustControlBounds(Self);
      AContainerSite.IncludeToDock(AParentControl, DockType, AIndex);
      IncludeToDock(AContainerSite, dtClient, 0);
      AControl.IncludeToDock(AContainerSite, dtClient, Index);
    finally
      AContainerSite.EndUpdateLayout;
    end;
  finally
    AParentControl.EndUpdateLayout;
  end;
  DoCreateTabContainerSite(AContainerSite);
end;

function TdxCustomDockControl.GetTabWidth(ACanvas: TCanvas): Integer;
var
  ASize: TSize;
begin
  cxGetTextExtentPoint32(ACanvas.Handle, Caption, ASize);
  Result := Painter.GetTabHorizInterval + ASize.cx + Painter.GetTabHorizInterval;
  if (Painter.GetImageWidth > 0) and Painter.IsValidImageIndex(ImageIndex) then
    Result := Result + Painter.GetImageWidth + 2 * Painter.GetTabHorizInterval;
end;

function TdxCustomDockControl.GetTabContainer: TdxTabContainerDockSite;
begin
  if Container is TdxTabContainerDockSite then
    Result := Container as TdxTabContainerDockSite
  else Result := nil;
end;

function TdxCustomDockControl.CanActive: Boolean;
begin
  Result := False;
end;

function TdxCustomDockControl.CanAutoHide: Boolean;
begin
  Result := False;
end;

procedure TdxCustomDockControl.ChangeAutoHide;
begin
  if IsAncestor then
    raise EdxException.Create(sdxAncestorError);
  AutoHide := not AutoHide;
end;

function TdxCustomDockControl.GetAutoSizeHostSite: TdxDockSite;
begin
  if (ParentDockControl is TdxDockSite) and (ParentDockControl as TdxDockSite).AutoSize then
    Result := ParentDockControl as TdxDockSite
  else
    Result := nil;
end;

procedure TdxCustomDockControl.DoAutoHideChanged;
begin
  BeginUpdateNC;
  try
    if AutoHide and not (doImmediatelyHideOnAutoHide in ControllerOptions) then
      AutoHideHostSite.ImmediatelyShow(Self);
    if not Visible then
      UpdateRelatedControlsVisibility;
  finally
    EndUpdateNC;
  end;
  if Assigned(FOnAutoHideChanged) then
    FOnAutoHideChanged(Self);
end;

procedure TdxCustomDockControl.DoAutoHideChanging;
begin
  if Assigned(FOnAutoHideChanging) then
    FOnAutoHideChanging(Self);
end;

procedure TdxCustomDockControl.AutoHideChanged;
begin
  if IsLoading or (AutoHideHostSite = nil) then exit;

  BeginUpdateNC;
  try
    DoAutoHideChanging;
    AutoHideHostSite.NCChanged;

    ParentDockControl.BeginUpdateLayout;
    try
      if AutoHide then
      begin
        AutoHideHostSite.RegisterAutoHideDockControl(Self, GetAutoHidePosition);
        Controller.ActiveDockControl := nil;
      end
      else
      begin
        AutoHideHostSite.UnregisterAutoHideDockControl(Self);
        Activate;
      end;
      UpdateResizeZones;
      UpdateDockZones;
    finally
      ParentDockControl.EndUpdateLayout;
    end;
    DoAutoHideChanged;
  finally
    EndUpdateNC;
  end;
end;

function TdxCustomDockControl.GetAutoHidePosition: TdxAutoHidePosition;
begin
  if AutoSizeHostSite <> nil then
    Result := AutoSizeHostSite.GetControlAutoHidePosition(Self)
  else
    if SideContainer <> nil then
      Result := SideContainer.GetControlAutoHidePosition(Self)
    else
      if TabContainer <> nil then
        Result := TabContainer.GetControlAutoHidePosition(Self)
      else
        Result := GetControlAutoHidePosition(Self);
  if Assigned(FOnGetAutoHidePosition) then
    FOnGetAutoHidePosition(Self, Result);
end;

function TdxCustomDockControl.GetControlAutoHidePosition(AControl: TdxCustomDockControl): TdxAutoHidePosition;
var
  ARect, AHostRect: TRect;
begin
  if AutoSizeHostSite <> nil then
    Result := AutoSizeHostSite.GetControlAutoHidePosition(AControl)
  else
    case AControl.DockType of
      dtLeft: Result := ahpLeft;
      dtTop: Result := ahpTop;
      dtRight: Result := ahpRight;
      dtBottom: Result := ahpBottom;
    else
      if AControl.HandleAllocated then
      begin
        ARect := cxGetWindowRect(AControl);
        AHostRect := cxGetWindowRect(AutoHideHostSite);
        if AControl.Width > AControl.Height then
        begin
          if ARect.Top - AHostRect.Top <= AHostRect.Bottom - ARect.Bottom then
            Result := ahpTop
          else
            Result := ahpBottom;
        end
        else
        begin
          if ARect.Left - AHostRect.Left <= AHostRect.Right - ARect.Right then
            Result := ahpLeft
          else
            Result := ahpRight;
        end;  
      end
      else
        Result := ahpLeft;
    end;
end;

function TdxCustomDockControl.GetAutoHideHostSite: TdxDockSite;
begin
  if TopMostDockControl is TdxDockSite then
    Result := TopMostDockControl as TdxDockSite
  else
    Result := nil;
end;

function TdxCustomDockControl.GetAutoHideContainer: TdxDockSiteAutoHideContainer;
begin
  if Parent is TdxDockSiteAutoHideContainer then
    Result := Parent as TdxDockSiteAutoHideContainer
  else Result := nil;
end;

function TdxCustomDockControl.GetAutoHideControl: TdxCustomDockControl;
var
  AControl: TdxCustomDockControl;
begin
  Result := nil;
  AControl := Self;
  while AControl <> nil do
  begin
    if AControl.AutoHide then 
    begin
      Result := AControl;
      Break;
    end;
    AControl := AControl.ParentDockControl;
  end;
end;

procedure TdxCustomDockControl.DoParentChanged;
begin
  if not IsLoading and Assigned(FOnParentChanged) then
    FOnParentChanged(Self);
end;

procedure TdxCustomDockControl.DoParentChanging;
begin
  if not IsLoading and Assigned(FOnParentChanging) then
    FOnParentChanging(Self);
end;

procedure TdxCustomDockControl.UpdateState;
begin
  if ParentDockControl is TdxTabContainerDockSite then
  begin
    if (TdxTabContainerDockSite(ParentDockControl).ActiveChild = Self) or AutoHide then
      Enabled := True
    else
      Enabled := False;
  end
  else
    Enabled := True;
end;

procedure TdxCustomDockControl.IncludeToDock(AControl: TdxCustomDockControl; AType: TdxDockingType;
  Index: Integer);
begin
  if IsLoading then
  begin
    BeginUpdateLayout;
    try
      SetDockType(AType);
      SetParentDockControl(AControl);
      ParentDockControl.AddDockControl(Self, Index);
      UpdateCaption;
    finally
      EndUpdateLayout(False);
    end;
  end
  else
  begin
    BeginUpdateLayout;
    try
      AControl.NCChanged;
      SetDockType(AType);
      SetParentDockControl(AControl);
      ParentDockControl.AddDockControl(Self, Index);
      UpdateOriginalSize;
      UpdateCaption;
      AControl.DoLayoutChanged;
    finally
      EndUpdateLayout;
    end;
  end;
end;

procedure TdxCustomDockControl.ExcludeFromDock;
var
  AControl: TdxCustomDockControl;
begin
  BeginUpdateLayout;
  try
    AControl := ParentDockControl;
//    AControl.NCChanged;
    SetParentDockControl(nil);
    ClearDockType;
    AControl.RemoveDockControl(Self);
    if AControl.IsNeeded then
      AControl.NCChanged;

    AdjustControlBounds(Self);
    ClearZones(DockZones);
    ClearZones(ResizeZones);
    AControl.DoLayoutChanged;
  finally
    EndUpdateLayout;
  end;
end;

procedure TdxCustomDockControl.AdjustControlBounds(AControl: TdxCustomDockControl);
begin
  SetSize(AControl.OriginalWidth, AControl.OriginalHeight);
  FOriginalWidth := AControl.OriginalWidth;
  FOriginalHeight := AControl.OriginalHeight;
end;

procedure TdxCustomDockControl.SetSize(AWidth, AHeight: Integer);
begin
  case Align of
    alBottom: SetBounds(Left, Top - (AHeight - Height), AWidth, AHeight);
    alRight: SetBounds(Left - (AWidth - Width), Top, AWidth, AHeight);
  else
    SetBounds(Left, Top, AWidth, AHeight);
  end;
end;

procedure TdxCustomDockControl.CreateLayout(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
var
  AParentSite, ASite1, ASite2: TdxCustomDockControl;
begin
  case ChildCount of
    0: begin
      ASite1 := TdxLayoutDockSite.Create(Owner);
      ASite1.Name := ASite1.UniqueName;
      ASite1.IncludeToDock(Self, dtClient, 0);
      AControl.IncludeToDock(Self, AType, 1);
      DoCreateLayoutSite(ASite1 as TdxLayoutDockSite);
    end;
    2: begin
      ASite1 := Children[0];
      ASite2 := Children[1];
      ASite1.ExcludeFromDock;
      ASite2.ExcludeFromDock;
      AParentSite := TdxLayoutDockSite.Create(Owner);
      AParentSite.Name := AParentSite.UniqueName;
      AParentSite.IncludeToDock(Self, dtClient, 0);
      ASite1.IncludeToDock(AParentSite, ASite1.DockType, 0);
      ASite2.IncludeToDock(AParentSite, ASite2.DockType, 1);
      AControl.IncludeToDock(Self, AType, 1);
      DoCreateLayoutSite(AParentSite as TdxLayoutDockSite);
    end;
  else
    Assert(False, Format(sdxInternalErrorCreateLayout, [TdxCustomDockControl.ClassName]));
  end;
end;

procedure TdxCustomDockControl.DestroyChildLayout;
var
  ADummySite: TdxCustomDockControl;
  ASite1, ASite2: TdxCustomDockControl;
begin
  ADummySite := Children[0];
  Include(ADummySite.FInternalState, dcisDestroying);
  case ADummySite.ChildCount of
    0: ADummySite.ExcludeFromDock;
    2: begin
      ASite1 := ADummySite.Children[0];
      ASite2 := ADummySite.Children[1];
      ASite1.ExcludeFromDock;
      ASite2.ExcludeFromDock;
      ADummySite.ExcludeFromDock;
      ASite1.IncludeToDock(Self, ASite1.DockType, 0);
      ASite2.IncludeToDock(Self, ASite2.DockType, 1);
    end
  else
    Assert(False, Format(sdxInternalErrorDestroyLayout, [ClassName]));
  end;
  ADummySite.DoDestroy;
end;

procedure TdxCustomDockControl.DestroyLayout(AControl: TdxCustomDockControl);
begin
  AControl.ExcludeFromDock;
  if ChildCount = 1 then
    DestroyChildLayout;
end;

procedure TdxCustomDockControl.RemoveFromLayout;
begin
  if AutoHide and (AutoHideHostSite <> nil) and not AutoHideHostSite.IsDestroying then
    AutoHide := False;
  if ParentDockControl <> nil then
  begin
    if not ParentDockControl.IsDestroying then
      UnDock
    else
      ParentDockControl.RemoveDockControl(Self);
  end;

//  if (ParentDockControl <> nil) and not ParentDockControl.IsDestroying then
//    UnDock;
  ClearChildrenParentDockControl;
end;

procedure TdxCustomDockControl.UpdateLayout;
begin
  UpdateRelatedControlsVisibility;
  UpdateDockZones;
  UpdateResizeZones;
  UpdateState;
end;

function TdxCustomDockControl.GetMinimizedHeight: Integer;
var
  ABorderWidths: TRect;
begin
  if not HasCaption then
    Result := 28
  else
  begin
    ABorderWidths := Painter.GetBorderWidths;
    if IsCaptionVertical then
      Result := ABorderWidths.Left + ABorderWidths.Right + 
        6 * Painter.GetCaptionHorizInterval + 3 * Painter.GetCaptionButtonSize
    else
      Result := Painter.GetCaptionHeight + ABorderWidths.Top + ABorderWidths.Bottom;
  end;
end;

function TdxCustomDockControl.GetMinimizedWidth: Integer;
var
  ABorderWidths: TRect;
begin
  if not HasCaption then
    Result := 58
  else
  begin
    ABorderWidths := Painter.GetBorderWidths;
    if IsCaptionVertical then
      Result := Painter.GetCaptionHeight + ABorderWidths.Top + ABorderWidths.Bottom
    else
      Result := ABorderWidths.Left + ABorderWidths.Right +
        6 * Painter.GetCaptionHorizInterval + 3 * Painter.GetCaptionButtonSize;
  end;
end;

procedure TdxCustomDockControl.UpdateControlOriginalSize(AControl: TdxCustomDockControl);
var
  AHideBar: TdxDockSiteHideBar;
begin
  if AControl.AutoHide and (AControl.AutoHideHostSite <> nil) {and
    (AControl.AutoHideHostSite.ShowingControl = AControl) }then
  begin
    AHideBar := AutoHideHostSite.GetHideBarByControl(AControl);
    if AHideBar <> nil then
      case AHideBar.Position of
        ahpLeft, ahpRight: AControl.FOriginalWidth := Width;
        ahpTop, ahpBottom: AControl.FOriginalHeight := Height;
      end;
  end
  else case DockType of
    dtLeft, dtRight:
      AControl.FOriginalWidth := Width;
    dtTop, dtBottom:
      AControl.FOriginalHeight := Height;
    dtClient: ;
  else
    AControl.FOriginalWidth := Width;
    AControl.FOriginalHeight := Height;
  end;
end;

procedure TdxCustomDockControl.UpdateOriginalSize;
begin
  if IsLoading or not Visible then exit;
  if FloatDockSite <> nil then
    FloatDockSite.UpdateControlOriginalSize(Self)
  else if AutoHideControl <> nil then
    AutoHideControl.UpdateControlOriginalSize(Self)
  else if AutoSizeHostSite <> nil then
    AutoSizeHostSite.UpdateControlOriginalSize(Self)
  else if SideContainer <> nil then
    SideContainer.UpdateControlOriginalSize(Self)
  else if TabContainer <> nil then
    TabContainer.UpdateControlOriginalSize(Self)
  else UpdateControlOriginalSize(Self);
end;

procedure TdxCustomDockControl.DoUpdateDockZones;
begin
  if Assigned(FOnUpdateDockZones) then
    FOnUpdateDockZones(Self, DockZones);
  Controller.DoUpdateDockZones(Self);
end;

procedure TdxCustomDockControl.UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer);
begin
  if TdxLeftZone.ValidateDockZone(Self, AControl) then
    AControl.DockZones.Insert(0, TdxLeftZone.Create(Self, AZoneWidth, zkDocking));
  if TdxRightZone.ValidateDockZone(Self, AControl) then
    AControl.DockZones.Insert(0, TdxRightZone.Create(Self, AZoneWidth, zkDocking));
  if TdxTopZone.ValidateDockZone(Self, AControl) then
    AControl.DockZones.Insert(0, TdxTopZone.Create(Self, AZoneWidth, zkDocking));
  if TdxBottomZone.ValidateDockZone(Self, AControl) then
    AControl.DockZones.Insert(0, TdxBottomZone.Create(Self, AZoneWidth, zkDocking));
end;

procedure TdxCustomDockControl.UpdateDockZones;
var
  I: Integer;
  AControl: TdxCustomDockControl;
  AZoneLevel, AZoneWidth: Integer;
begin
  if IsDestroying then exit;
  ClearZones(DockZones);
  AZoneLevel := DockLevel;
  AZoneWidth := ControllerDockZonesWidth;
  AControl := Self;
  while True do
  begin
    AControl.UpdateControlDockZones(Self, AZoneWidth);
    AControl := AControl.ParentDockControl;
    if AControl = nil then break;
    AZoneWidth := AZoneWidth - ControllerDockZonesWidth div AZoneLevel;
  end;
  DoUpdateDockZones;
  for I := 0 to ChildCount - 1 do
    Children[I].UpdateDockZones;
end;

procedure TdxCustomDockControl.DoUpdateResizeZones;
begin
  if Assigned(FOnUpdateResizeZones) then
    FOnUpdateResizeZones(Self, FResizeZones);
  Controller.DoUpdateResizeZones(Self);
end;

procedure TdxCustomDockControl.UpdateControlResizeZones(AControl: TdxCustomDockControl);
begin
  if AControl.AutoHide and (AControl.AutoHideHostSite <> nil) then
  begin
    if TdxAutoHideRightZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxAutoHideRightZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxAutoHideLeftZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxAutoHideLeftZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxAutoHideBottomZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxAutoHideBottomZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxAutoHideTopZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxAutoHideTopZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
  end
  else
  begin
    if TdxRightZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxRightZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxLeftZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxLeftZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxBottomZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxBottomZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxTopZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxTopZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
  end;
end;

procedure TdxCustomDockControl.UpdateResizeZones;
var
  I: Integer;
begin
  ClearZones(ResizeZones);
  if AutoHideControl <> nil then
    AutoHideControl.UpdateControlResizeZones(Self)
  else if AutoSizeHostSite <> nil then
    AutoSizeHostSite.UpdateControlResizeZones(Self)
  else if SideContainer <> nil then
    SideContainer.UpdateControlResizeZones(Self)
  else if TabContainer <> nil then
    TabContainer.UpdateControlResizeZones(Self)
  else UpdateControlResizeZones(Self);
  DoUpdateResizeZones;
  for I := 0 to ChildCount - 1 do
    Children[I].UpdateResizeZones;
end;

procedure TdxCustomDockControl.AssignFloatSiteProperties(ASite: TdxFloatDockSite);
var
  AProperties: TdxCustomDockControlProperties;
begin
  AProperties := Controller.DefaultFloatSiteProperties(ParentForm);
  if AProperties <> nil then
    AProperties.AssignTo(ASite);
end;

procedure TdxCustomDockControl.DoCreateFloatSite(ASite: TdxFloatDockSite);
begin
  AssignFloatSiteProperties(ASite);
  if Assigned(FOnCreateFloatSite) then
    FOnCreateFloatSite(Self, ASite);
  Controller.DoCreateFloatSite(Self, ASite);
end;

procedure TdxCustomDockControl.UpdateCaption;
begin
  if Container <> nil then
    Container.UpdateCaption
  else if FloatDockSite <> nil then
    FloatDockSite.UpdateCaption;
end;

function TdxCustomDockControl.ControllerAutoHideInterval: Integer;
begin
  Result := Controller.AutoHideInterval(ParentForm);
end;

function TdxCustomDockControl.ControllerAutoHideMovingInterval: Integer;
begin
  Result := Controller.AutoHideMovingInterval(ParentForm);
end;

function TdxCustomDockControl.ControllerAutoHideMovingSize: Integer;
begin
  Result := Controller.AutoHideMovingSize(ParentForm);
end;

function TdxCustomDockControl.ControllerAutoShowInterval: Integer;
begin
  Result := Controller.AutoShowInterval(ParentForm);
end;

function TdxCustomDockControl.ControllerColor: TColor;
begin
  Result := Controller.Color(ParentForm);
end;

function TdxCustomDockControl.ControllerDockZonesWidth: Integer;
begin
  Result := Controller.DockZonesWidth(ParentForm);
end;

function TdxCustomDockControl.ControllerFont: TFont;
begin
  Result := Controller.Font(ParentForm);
end;

function TdxCustomDockControl.ControllerImages: TCustomImageList;
begin
  Result := Controller.Images(ParentForm);
end;

function TdxCustomDockControl.ControllerOptions: TdxDockingOptions;
begin
  Result := Controller.Options(ParentForm);
end;

function TdxCustomDockControl.ControllerViewStyle: TdxDockingViewStyle;
begin
  Result := Controller.ViewStyle(ParentForm);
end;

function TdxCustomDockControl.ControllerResizeZonesWidth: Integer;
begin
  Result := Controller.ResizeZonesWidth(ParentForm);
end;

function TdxCustomDockControl.ControllerSelectionFrameWidth: Integer;
begin
  Result := Controller.SelectionFrameWidth(ParentForm);
end;

function TdxCustomDockControl.ControllerTabsScrollInterval: Integer;
begin
  Result := Controller.TabsScrollInterval(ParentForm);
end;

procedure TdxCustomDockControl.Paint;
begin
  DrawDesignRect;
end;

procedure TdxCustomDockControl.CheckTempCanvas(ARect: TRect);
begin
  Controller.CheckTempBitmap(ARect);
end;

function TdxCustomDockControl.ClientToWindow(pt: TPoint): TPoint;
var
  R: TRect;
begin
  pt := ClientToScreen(pt);
  R := cxGetWindowRect(Self);
  Result.X := pt.X - R.Left;
  Result.Y := pt.Y - R.Top;
end;

function TdxCustomDockControl.ScreenToWindow(pt: TPoint): TPoint;
var
  R: TRect;
begin
  R := cxGetWindowRect(Self);
  Result.X := pt.X - R.Left;
  Result.Y := pt.Y - R.Top;
end;

function TdxCustomDockControl.WindowRectToClient(const R: TRect): TRect;
begin
  Result := R;
  with ClientToWindow(cxNullPoint) do
    OffsetRect(Result, -X, -Y);
end;

function TdxCustomDockControl.WindowToClient(pt: TPoint): TPoint;
var
  R: TRect;
begin
  R := cxGetWindowRect(Self);
  Result.X := R.Left + pt.X;
  Result.Y := R.Top + pt.Y;
  Result := ScreenToClient(Result);
end;

function TdxCustomDockControl.WindowToScreen(pt: TPoint): TPoint;
var
  R: TRect;
begin
  R := cxGetWindowRect(Self);
  Result.X := pt.X + R.Left;
  Result.Y := pt.Y + R.Top;
end;

procedure TdxCustomDockControl.CalculateNC(var ARect: TRect);
var
  APos, ACaptionSeparatorSize: Integer;
begin
  if HasBorder then
    ARect := cxRectContent(ARect, Painter.GetBorderWidths);
  if HasCaption then
  begin
    SetRectEmpty(FCaptionSeparatorRect);
    FCaptionRect := Painter.GetCaptionRect(ARect, IsCaptionVertical);
    if IsCaptionVertical then
    begin
      APos := FCaptionRect.Top + 2 * Painter.GetCaptionHorizInterval;
      if HasCaptionCloseButton then
      begin
        FCaptionCloseButtonRect.Left := FCaptionRect.Left + ((FCaptionRect.Right - FCaptionRect.Left) -
          Painter.GetCaptionButtonSize) div 2;
        FCaptionCloseButtonRect.Right := FCaptionCloseButtonRect.Left + Painter.GetCaptionButtonSize;
        FCaptionCloseButtonRect.Top := APos;
        FCaptionCloseButtonRect.Bottom := FCaptionCloseButtonRect.Top + Painter.GetCaptionButtonSize;
        APos := FCaptionCloseButtonRect.Bottom + Painter.GetCaptionHorizInterval;
      end;
      if HasCaptionHideButton then
      begin
        FCaptionHideButtonRect.Left := FCaptionRect.Left + ((FCaptionRect.Right - FCaptionRect.Left) -
          Painter.GetCaptionButtonSize) div 2;
        FCaptionHideButtonRect.Right := FCaptionHideButtonRect.Left + Painter.GetCaptionButtonSize;
        FCaptionHideButtonRect.Top := APos;
        FCaptionHideButtonRect.Bottom := FCaptionHideButtonRect.Top +  Painter.GetCaptionButtonSize;
        APos := FCaptionHideButtonRect.Bottom + Painter.GetCaptionHorizInterval;
      end;
      if HasCaptionMaximizeButton then
      begin
        FCaptionMaximizeButtonRect.Left := FCaptionRect.Left + ((FCaptionRect.Right - FCaptionRect.Left) -
          Painter.GetCaptionButtonSize) div 2;
        FCaptionMaximizeButtonRect.Right := FCaptionMaximizeButtonRect.Left + Painter.GetCaptionButtonSize;
        FCaptionMaximizeButtonRect.Top := APos;
        FCaptionMaximizeButtonRect.Bottom := FCaptionMaximizeButtonRect.Top + Painter.GetCaptionButtonSize;
        APos := FCaptionMaximizeButtonRect.Bottom + Painter.GetCaptionHorizInterval;
      end;
      FCaptionTextRect := FCaptionRect;
      FCaptionTextRect.Bottom := FCaptionTextRect.Bottom - 2 * Painter.GetCaptionHorizInterval;
      FCaptionTextRect.Top := APos;

      ARect.Left := FCaptionRect.Right;
      ACaptionSeparatorSize := Min(ARect.Right - ARect.Left, Painter.GetBorderWidths.Left);
      FCaptionSeparatorRect := Rect(ARect.Left, ARect.Top, ARect.Left + ACaptionSeparatorSize, ARect.Bottom);
      ARect.Left := FCaptionSeparatorRect.Right;
    end
    else
    begin
      APos := FCaptionRect.Right - 2 * Painter.GetCaptionHorizInterval;
      if HasCaptionCloseButton then
      begin
        FCaptionCloseButtonRect.Top := FCaptionRect.Top + ((FCaptionRect.Bottom - FCaptionRect.Top) -
          Painter.GetCaptionButtonSize) div 2;
        FCaptionCloseButtonRect.Bottom := FCaptionCloseButtonRect.Top + Painter.GetCaptionButtonSize;
        FCaptionCloseButtonRect.Right := APos;
        FCaptionCloseButtonRect.Left := FCaptionCloseButtonRect.Right - Painter.GetCaptionButtonSize;
        APos := FCaptionCloseButtonRect.Left - Painter.GetCaptionHorizInterval;
      end;
      if HasCaptionHideButton then
      begin
        FCaptionHideButtonRect.Top := FCaptionRect.Top + ((FCaptionRect.Bottom - FCaptionRect.Top) -
          Painter.GetCaptionButtonSize) div 2;
        FCaptionHideButtonRect.Bottom := FCaptionHideButtonRect.Top + Painter.GetCaptionButtonSize;
        FCaptionHideButtonRect.Right := APos;
        FCaptionHideButtonRect.Left := FCaptionHideButtonRect.Right -  Painter.GetCaptionButtonSize;
        APos := FCaptionHideButtonRect.Left - Painter.GetCaptionHorizInterval;
      end;
      if HasCaptionMaximizeButton then
      begin
        FCaptionMaximizeButtonRect.Top := FCaptionRect.Top + ((FCaptionRect.Bottom - FCaptionRect.Top) -
          Painter.GetCaptionButtonSize) div 2;
        FCaptionMaximizeButtonRect.Bottom := FCaptionMaximizeButtonRect.Top + Painter.GetCaptionButtonSize;
        FCaptionMaximizeButtonRect.Right := APos;
        FCaptionMaximizeButtonRect.Left := FCaptionMaximizeButtonRect.Right - Painter.GetCaptionButtonSize;
        APos := FCaptionMaximizeButtonRect.Left - Painter.GetCaptionHorizInterval;
      end;
      FCaptionTextRect := FCaptionRect;
      FCaptionTextRect.Left := FCaptionTextRect.Left + 2 * Painter.GetCaptionHorizInterval;
      FCaptionTextRect.Right := APos;

      ARect.Top := FCaptionRect.Bottom;
      ACaptionSeparatorSize := Min(ARect.Bottom - ARect.Top, Painter.GetBorderWidths.Top);
      FCaptionSeparatorRect := Rect(ARect.Left, ARect.Top, ARect.Right, ARect.Top + ACaptionSeparatorSize);
      ARect.Top := FCaptionSeparatorRect.Bottom;
    end;
  end;
end;

procedure TdxCustomDockControl.DoDrawClient(ACanvas: TCanvas; const R: TRect);
begin
  Painter.DrawClient(ACanvas, R);
end;

procedure TdxCustomDockControl.DrawDesignRect;
var
  AcxCanvas: TcxCanvas;
begin
  if IsDesigning and not cxRectIsEmpty(GetDesignRect) then
  begin
    AcxCanvas := TcxCanvas.Create(TCanvas.Create);
    AcxCanvas.Canvas.Handle := GetWindowDC(Handle);
    try
      cxDrawDesignRect(AcxCanvas, GetDesignRect, GetTopMostDockControl.IsSelected);
    finally
      ReleaseDC(Handle, AcxCanvas.Handle);
      AcxCanvas.Canvas.Free;
      AcxCanvas.Free;
    end;
  end;
end;

procedure TdxCustomDockControl.InvalidateCaptionArea;
var
  DC: HDC;
  ACanvas: TCanvas;
begin
  if HandleAllocated and CanUpdateNC and not IsInternalDestroying then
  begin
    DC := GetWindowDC(Handle);
    try
      ACanvas := TCanvas.Create;
      try
        ACanvas.Handle := DC;
        NCPaintCaption(ACanvas);
      finally
        ACanvas.Free;
      end;
    finally
      ReleaseDC(Handle, DC);
    end;
  end
  else
    InvalidateNC(False);
end;

procedure TdxCustomDockControl.InvalidateNC(ANeedRecalculate: Boolean);
var
  R: TRect;
begin
  if HandleAllocated and not IsInternalDestroying then
  begin
    if ANeedRecalculate then
    begin
      R := WindowRect;
      CalculateNC(R);
    end;
    if CanUpdateNC then
      Perform(WM_NCPAINT, 0, 0);
  end;
end;

procedure TdxCustomDockControl.NCChanged(AImmediately: Boolean = False);
begin
  FRecalculateNCNeeded := AImmediately;
  if HandleAllocated and not IsInternalDestroying and (FRecalculateNCNeeded or CanCalculateNC) then
  begin
    Include(FInternalState, dcisFrameChanged);
    try
      SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or
        SWP_NOACTIVATE or SWP_FRAMECHANGED);
    finally
      Exclude(FInternalState, dcisFrameChanged);
    end;
  end;
end;

procedure TdxCustomDockControl.Recalculate;
begin
  NCChanged;
end;

procedure TdxCustomDockControl.Redraw(AWithChildren: Boolean);
const
  AFlagMap: array [Boolean] of DWORD = (RDW_FRAME or RDW_INVALIDATE, RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_ERASE);
begin
  if HandleAllocated and not IsInternalDestroying then
    RedrawWindow(Handle, nil, 0, AFlagMap[AWithChildren]);
end;

procedure TdxCustomDockControl.BeginUpdateNC(ALockRedraw: Boolean);
begin
  Controller.BeginUpdateNC(ALockRedraw);
end;

procedure TdxCustomDockControl.EndUpdateNC;
begin
  Controller.EndUpdateNC;
end;

function TdxCustomDockControl.CanUpdateNC: Boolean;
begin
  Result := Controller.CanUpdateNC(Self);
end;

function TdxCustomDockControl.CanCalculateNC: Boolean;
begin
  Result := Controller.CanCalculateNC(Self) or (csAlignmentNeeded in ControlState);
end;

function TdxCustomDockControl.HasBorder: Boolean;
begin
  Result := False;
end;

function TdxCustomDockControl.HasCaption: Boolean;
begin
  Result := False;
end;

function TdxCustomDockControl.HasCaptionCloseButton: Boolean;
begin
  Result := HasCaption and (cbClose in CaptionButtons);
end;

function TdxCustomDockControl.HasCaptionHideButton: Boolean;
begin
  Result := HasCaption and (cbHide in CaptionButtons) and CanAutoHide;
end;

function TdxCustomDockControl.HasCaptionMaximizeButton: Boolean;
begin
  Result := HasCaption and (cbMaximize in CaptionButtons) and CanMaximize;
end;

function TdxCustomDockControl.HasTabs: Boolean;
begin
  Result := False;
end;

function TdxCustomDockControl.IsCaptionActive: Boolean;
begin
  Result := (Controller.ActiveDockControl = Self) and Application.Active;
end;

function TdxCustomDockControl.IsCaptionVertical: Boolean;
var
  ADockType: TdxDockingType;
begin
  if SideContainer <> nil then
    ADockType := SideContainer.DockType
  else ADockType := DockType;
  Result := Painter.CanVerticalCaption and (ADockType in [dtTop, dtBottom]);
end;

function TdxCustomDockControl.IsCaptionPoint(pt: TPoint): Boolean;
begin
  Result := HasCaption and PtInRect(CaptionRect, ClientToWindow(pt));
end;

function TdxCustomDockControl.IsCaptionCloseButtonPoint(pt: TPoint): Boolean;
begin
  Result := HasCaptionCloseButton and PtInRect(CaptionCloseButtonRect, ClientToWindow(pt));
end;

function TdxCustomDockControl.IsCaptionHideButtonPoint(pt: TPoint): Boolean;
begin
  Result := HasCaptionHideButton and PtInRect(CaptionHideButtonRect, ClientToWindow(pt));
end;

function TdxCustomDockControl.IsCaptionMaximizeButtonPoint(pt: TPoint): Boolean;
begin
  Result := HasCaptionMaximizeButton and PtInRect(CaptionMaximizeButtonRect, ClientToWindow(pt));
end;

procedure TdxCustomDockControl.NCPaint(ACanvas: TCanvas);
var
  ABorders: TRect;
begin
  if Painter.DrawCaptionFirst then
    NCPaintCaption(ACanvas);
  if HasBorder then
  begin
    Painter.DrawBorder(ACanvas, WindowRect);
    with WindowRect do
    begin
      ABorders := Painter.GetBorderWidths;
      ExcludeClipRect(ACanvas.Handle, Left, Top, Left + ABorders.Left, Bottom);
      ExcludeClipRect(ACanvas.Handle, Left, Bottom - ABorders.Bottom, Right, Bottom);
      ExcludeClipRect(ACanvas.Handle, Right - ABorders.Right, Top, Left + Right, Bottom);
      ExcludeClipRect(ACanvas.Handle, Left, Top, Right, Top + ABorders.Top);
    end;
  end;
  if not Painter.DrawCaptionFirst then
    NCPaintCaption(ACanvas);
end;

procedure TdxCustomDockControl.NCPaintCaption(ACanvas: TCanvas);
begin
  if HasCaption then
  begin
    Painter.DrawCaption(ACanvas, CaptionRect, IsCaptionActive);
    Painter.DrawCaptionSeparator(ACanvas, CaptionSeparatorRect);
    Painter.DrawCaptionText(ACanvas, CaptionTextRect, IsCaptionActive);
    if HasCaptionCloseButton then
      Painter.DrawCaptionCloseButton(ACanvas, CaptionCloseButtonRect, IsCaptionActive, CloseButtonIsDown,
        CloseButtonIsHot, False);
    if HasCaptionHideButton then
      Painter.DrawCaptionHideButton(ACanvas, CaptionHideButtonRect, IsCaptionActive, HideButtonIsDown,
        HideButtonIsHot, AutoHide);
    if HasCaptionMaximizeButton then
      Painter.DrawCaptionMaximizeButton(ACanvas, CaptionMaximizeButtonRect, IsCaptionActive, MaximizeButtonIsDown,
        MaximizeButtonIsHot, (SideContainer <> nil) and (SideContainer.ActiveChild = Self));
    with CaptionRect do
      ExcludeClipRect(ACanvas.Handle, Left, Top, Right, Bottom);
  end;
end;

function TdxCustomDockControl.NeedInvalidateCaptionArea: Boolean;
begin
  Result := HasCaption;
end;

procedure TdxCustomDockControl.DoLayoutChanged;
begin
  if not IsUpdateLayoutLocked and not IsDestroying then
  begin
    UpdateLayout;
    if Assigned(FOnLayoutChanged) then
      FOnLayoutChanged(Self);
  end;
end;

procedure TdxCustomDockControl.BeginUpdateLayout;
begin
  Inc(FUpdateLayoutLock);
end;

procedure TdxCustomDockControl.EndUpdateLayout(AForceUpdate: Boolean = True);
begin
  Dec(FUpdateLayoutLock);
  if AForceUpdate then
    DoLayoutChanged;
end;

function TdxCustomDockControl.IsUpdateLayoutLocked: Boolean;
begin
  Result := UpdateLayoutLock > 0;
end;

procedure TdxCustomDockControl.LoadLayoutFromCustomIni(AIniFile: TCustomIniFile;
  AParentForm: TCustomForm; AParentControl: TdxCustomDockControl; ASection: string);

  function ReadAllowDock: TdxDockingTypes;
  begin
    Result := [];
    if AIniFile.ReadBool(ASection, 'AllowDockLeft', dtLeft in AllowDock) then
      Result := Result + [dtLeft];
    if AIniFile.ReadBool(ASection, 'AllowDockTop', dtTop in AllowDock) then
      Result := Result + [dtTop];
    if AIniFile.ReadBool(ASection, 'AllowDockRight', dtRight in AllowDock) then
      Result := Result + [dtRight];
    if AIniFile.ReadBool(ASection, 'AllowDockBottom', dtBottom in AllowDock) then
      Result := Result + [dtBottom];
    if AIniFile.ReadBool(ASection, 'AllowDockClient', dtClient in AllowDock) then
      Result := Result + [dtClient];
  end;

  function ReadAllowDockClients: TdxDockingTypes;
  begin
    Result := [];
    if AIniFile.ReadBool(ASection, 'AllowDockClientsLeft', dtLeft in AllowDockClients) then
      Result := Result + [dtLeft];
    if AIniFile.ReadBool(ASection, 'AllowDockClientsTop', dtTop in AllowDockClients) then
      Result := Result + [dtTop];
    if AIniFile.ReadBool(ASection, 'AllowDockClientsRight', dtRight in AllowDockClients) then
      Result := Result + [dtRight];
    if AIniFile.ReadBool(ASection, 'AllowDockClientsBottom', dtBottom in AllowDockClients) then
      Result := Result + [dtBottom];
    if AIniFile.ReadBool(ASection, 'AllowDockClientsClient', dtClient in AllowDockClients) then
      Result := Result + [dtClient];
  end;

  function ReadCaptionButtons: TdxCaptionButtons;
  begin
    Result := [];
    if AIniFile.ReadBool(ASection, 'CaptionButtonClose', cbClose in CaptionButtons) then
      Result := Result + [cbClose];
    if AIniFile.ReadBool(ASection, 'CaptionButtonHide', cbHide in CaptionButtons) then
      Result := Result + [cbHide];
    if AIniFile.ReadBool(ASection, 'CaptionButtonMaximize', cbMaximize in CaptionButtons) then
      Result := Result + [cbMaximize];
  end;

var
  I, AChildCount: Integer;
  AChildSection: string;
  ADockType: TdxDockingType;
  AWidth, AHeight: Integer;
begin
  BeginUpdateLayout;
  try
    Include(FInternalState, dcisLayoutLoading);
    try
      with AIniFile do
      begin
        ADockType := TdxDockingTypeEx(ReadInteger(ASection, 'DockType', 0));
        AllowDock := ReadAllowDock;
        AllowDockClients := ReadAllowDockClients;
        AllowFloating := ReadBool(ASection, 'AllowFloating', AllowFloating);
        CaptionButtons := ReadCaptionButtons;
        Dockable := ReadBool(ASection, 'Dockable', Dockable);
        AWidth := ReadInteger(ASection, 'Width', Width);
        AHeight := ReadInteger(ASection, 'Height', Height);
        SetSize(AWidth, AHeight);
        FOriginalWidth := ReadInteger(ASection, 'OriginalWidth', OriginalWidth);
        FOriginalHeight := ReadInteger(ASection, 'OriginalHeight', OriginalHeight);
        Visible := ReadBool(ASection, 'Visible', Visible);
        if (AParentControl <> nil) then
          IncludeToDock(AParentControl, ADockType, -1);
        AChildCount := ReadInteger(ASection, 'ChildCount', 0);
        for I := 0 to AChildCount - 1 do
        begin
          AChildSection := ReadString(ASection, 'Children' + IntToStr(I), '');
          Controller.LoadControlFromCustomIni(AIniFile, AParentForm, Self, AChildSection);
        end;
        FAutoHide := ReadBool(ASection, 'AutoHide', False);
        FStoredAutoHide := ReadBool(ASection, 'StoredAutoHide', False);
        if AutoHide and (AutoHideHostSite <> nil) then
        begin
          FAutoHidePosition := TdxAutoHidePosition(ReadInteger(ASection, 'AutoHidePosition', Integer(ahpUndefined)));
          if FAutoHidePosition = ahpUndefined then
            FAutoHidePosition := GetAutoHidePosition;
          AutoHideHostSite.RegisterAutoHideDockControl(Self, FAutoHidePosition);
        end;
      end;
    finally
      Exclude(FInternalState, dcisLayoutLoading);
    end;
  finally
    EndUpdateLayout;
  end;
end;

procedure TdxCustomDockControl.SaveLayoutToCustomIni(AIniFile: TCustomIniFile; ASection: string);
var
  I: Integer;
begin
  with AIniFile do
  begin
    WriteInteger(ASection, 'ChildCount', ChildCount);
    for I := 0 to ChildCount - 1 do
      WriteString(ASection, 'Children' + IntToStr(I), IntToStr(Controller.IndexOfDockControl(Children[I])));
    WriteInteger(ASection, 'DockType', Integer(DockType));
    WriteBool(ASection, 'AllowDockLeft', dtLeft in AllowDock);
    WriteBool(ASection, 'AllowDockTop', dtTop in AllowDock);
    WriteBool(ASection, 'AllowDockRight', dtRight in AllowDock);
    WriteBool(ASection, 'AllowDockBottom', dtBottom in AllowDock);
    WriteBool(ASection, 'AllowDockClient', dtClient in AllowDock);
    WriteBool(ASection, 'AllowDockClientsLeft', dtLeft in AllowDockClients);
    WriteBool(ASection, 'AllowDockClientsTop', dtTop in AllowDockClients);
    WriteBool(ASection, 'AllowDockClientsRight', dtRight in AllowDockClients);
    WriteBool(ASection, 'AllowDockClientsBottom', dtBottom in AllowDockClients);
    WriteBool(ASection, 'AllowDockClientsClient', dtClient in AllowDockClients);
    WriteBool(ASection, 'AllowFloating', AllowFloating);
    WriteBool(ASection, 'CaptionButtonClose', cbClose in CaptionButtons);
    WriteBool(ASection, 'CaptionButtonHide', cbHide in CaptionButtons);
    WriteBool(ASection, 'CaptionButtonMaximize', cbMaximize in CaptionButtons);
    WriteBool(ASection, 'Dockable', Dockable);
    WriteInteger(ASection, 'Width', Width);
    WriteInteger(ASection, 'Height', Height);
    WriteInteger(ASection, 'OriginalWidth', OriginalWidth);
    WriteInteger(ASection, 'OriginalHeight', OriginalHeight);
    WriteBool(ASection, 'Visible', Visible);
    WriteBool(ASection, 'AutoHide', AutoHide);
    WriteBool(ASection, 'StoredAutoHide', StoredAutoHide);
    if AutoHide then
      WriteInteger(ASection, 'AutoHidePosition', Integer(FAutoHidePosition));
  end;
  for I := 0 to ChildCount - 1 do
    Controller.SaveControlToCustomIni(AIniFile, Children[I]);
end;

function TdxCustomDockControl.GetDockIndex: Integer;
begin
  if ParentDockControl <> nil then
    Result := ParentDockControl.IndexOfControl(Self)
  else Result := -1;
end;

function TdxCustomDockControl.GetDockLevel: Integer;
var
  AControl: TdxCustomDockControl;
begin
  AControl := Self;
  Result := 0;
  while True do
  begin
    Inc(Result);
    AControl := AControl.ParentDockControl;
    if AControl = nil then break;
  end;
end;

function TdxCustomDockControl.GetDockingRect: TRect;
begin
  if FloatDockSite <> nil then
  begin
    Result := FloatDockSite.FloatForm.BoundsRect;
    OffsetRect(Result, - FloatDockSite.FloatForm.Left, - FloatDockSite.FloatForm.Top);
  end
  else
    Result := Rect(0, 0, OriginalWidth, OriginalHeight);
end;

function TdxCustomDockControl.GetDockState: TdxDockingState;
begin
  if dcisDestroyed in FInternalState then
    Result := dsDestroyed
  else if (ParentDockControl = nil) and (Parent = nil) then
    Result := dsUndocked
  else if not Visible then
    Result := dsHidden
  else if FloatDockSite <> nil then
    Result := dsFloating
  else Result := dsDocked;
end;

function TdxCustomDockControl.GetChild(Index: Integer): TdxCustomDockControl;
begin
  Result := TdxCustomDockControl(FDockControls.Items[Index]);
end;

function TdxCustomDockControl.GetChildCount: Integer;
begin
  Result := FDockControls.Count;
end;

function TdxCustomDockControl.GetImages: TCustomImageList;
begin
  Result := ControllerImages;
end;

procedure TdxCustomDockControl.ClearDockType;
begin
  if not AutoHide then
    Align := alNone;
end;

procedure TdxCustomDockControl.ClearChildrenParentDockControl;
var
  I: Integer;
begin
  for I := 0 to ChildCount - 1 do
    Children[I].FParentDockControl := nil;
end;

function TdxCustomDockControl.IsColorStored: Boolean;
begin
  Result := not ManagerColor and not ParentColor;
end;

function TdxCustomDockControl.IsFontStored: Boolean;
begin
  Result := not ManagerFont and not ParentFont;
end;

function TdxCustomDockControl.IsInternalDestroying: Boolean;
begin
  Result := IsDestroying or (dcisDestroying in FInternalState);
end;

function TdxCustomDockControl.GetActive: Boolean;
begin
  Result := Controller.ActiveDockControl = Self;
end;

function TdxCustomDockControl.GetController: TdxDockingController;
begin
  Result := dxDockingController;
end;

function TdxCustomDockControl.GetPainter: TdxDockControlPainter;
begin
  if FPainter = nil then
    FPainter := Controller.PainterClass(ParentForm).Create(Self);
  Result := FPainter;
end;

function TdxCustomDockControl.GetPopupParent: TCustomForm;
begin
  if FloatForm <> nil then
    Result := FloatForm
  else
    Result := ParentForm;
end;

function TdxCustomDockControl.GetTempCanvas: TCanvas;
begin
  if Controller.TempBitmap <> nil then
    Result := Controller.TempBitmap.Canvas
  else
    Result := nil;
end;

function TdxCustomDockControl.GetValidChildCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ChildCount - 1 do
    if IsValidChild(Children[I]) then
      Inc(Result);
end;

function TdxCustomDockControl.GetValidChild(Index: Integer): TdxCustomDockControl;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ChildCount - 1 do
    if IsValidChild(Children[I]) then
    begin
      if Index = 0 then
      begin
        Result := Children[I];
        break;
      end
      else Dec(Index);
    end;
end;

procedure TdxCustomDockControl.SetAllowDockClients(const Value: TdxDockingTypes);
begin
  if FAllowDockClients <> Value then
  begin
    FAllowDockClients := Value;
    if not IsLoading then
    begin
      CheckDockClientsRules;
      UpdateDockZones;
    end;
  end;
end;

procedure TdxCustomDockControl.SetAllowFloating(const Value: Boolean);
begin
  if (FAllowFloating <> Value) and (DockState <> dsFloating) then
  begin
    FAllowFloating := Value;
  end;
end;

procedure TdxCustomDockControl.SetAllowDock(const Value: TdxDockingTypes);
begin
  if FAllowDock <> Value then
  begin
    FAllowDock := Value;
    if not (IsLoading or (dcisLayoutLoading in FInternalState)) then
    begin
      CheckDockRules;
      UpdateDockZones;
    end;
  end;
end;

procedure TdxCustomDockControl.SetAutoHide(const Value: Boolean);
begin
  if (FAutoHide <> Value) and (CanAutoHide or not Value) then
  begin
    FAutoHide := Value;
    AutoHideChanged;
    UpdateState;
    Modified;
  end;
end;

procedure TdxCustomDockControl.SetCaptionButtons(Value: TdxCaptionButtons);
begin
  if FCaptionButtons <> Value then
  begin
    FCaptionButtons := Value;
    InvalidateNC(True);
  end;
end;

procedure TdxCustomDockControl.SetDockable(const Value: Boolean);
begin
  if FDockable <> Value then
  begin
    FDockable := Value;
  end;
end;

procedure TdxCustomDockControl.SetDockType(Value: TdxDockingType);
begin
  if (Self is TdxFloatDockSite) and IsDesigning and IsLoading then Exit; // Anchors bug
  FDockType := Value;
  if (FDockType <> dtNone) and (not AutoHide or IsLoading) then
    Align := dxDockingTypeAlign[Value];
end;

procedure TdxCustomDockControl.SetDockingParams(ADockingTargetZone: TdxZone; const ADockingPoint: TPoint);
begin
  if (FDockingTargetZone <> ADockingTargetZone) or (ADockingTargetZone = nil) and not cxPointIsEqual(ADockingPoint, FDockingPoint) then
  begin
    if not cxPointIsEqual(FDockingPoint, cxInvalidPoint) then
      DrawDockingSelection(DockingTargetZone, DockingPoint, True);
    FDockingTargetZone := ADockingTargetZone;
    FDockingPoint := ADockingPoint;
    if not cxPointIsEqual(FDockingPoint, cxInvalidPoint) then
      DrawDockingSelection(DockingTargetZone, DockingPoint, False);
  end;
end;

procedure TdxCustomDockControl.SetImageIndex(const Value: Integer);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    if HasCaption then
      NCChanged;
    if (AutoHideControl <> nil) and (AutoHideHostSite <> nil) then
      AutoHideHostSite.InvalidateNC(True);
    if TabContainer <> nil then
      TabContainer.InvalidateNC(True);
  end;
end;

procedure TdxCustomDockControl.SetManagerColor(const Value: Boolean);
begin
  if FManagerColor <> Value then
  begin
    if Value and not IsLoading then
      Color := ControllerColor;
    FManagerColor := Value;
    InvalidateNC(False);
  end;
end;

procedure TdxCustomDockControl.SetManagerFont(const Value: Boolean);
begin
  if FManagerFont  <> Value then
  begin
    if Value and not IsLoading then
      Font := ControllerFont;
    FManagerFont := Value;
    NCChanged;
  end;
end;

procedure TdxCustomDockControl.SetParentDockControl(Value: TdxCustomDockControl);
begin
  FParentDockControl := Value;
  if not AutoHide then
  begin
    if (Value = nil) and IsInternalDestroying then
      Visible := False
    else
      Parent := Value;
  end;
end;

procedure TdxCustomDockControl.SetShowCaption(const Value: Boolean);
begin
  if FShowCaption <> Value then
  begin
    FShowCaption := Value;
    NCChanged;
  end;
end;

procedure TdxCustomDockControl.SetUseDoubleBuffer(const Value: Boolean);
begin
  if FUseDoubleBuffer <> Value then
  begin
    FUseDoubleBuffer := Value;
    // TODO: Check?
  end;
end;

procedure TdxCustomDockControl.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if not IsLoading then FManagerFont := False;
  NCChanged;
end;

procedure TdxCustomDockControl.CMColorChanged(var Message: TMessage);
begin
  inherited;
  if not IsLoading then FManagerColor := False;
  InvalidateNC(False);
end;

procedure TdxCustomDockControl.CMTextChanged(var Message: TMessage);
begin
  inherited;
  UpdateCaption;
  if NeedInvalidateCaptionArea then
    InvalidateCaptionArea;
  if (AutoHideControl <> nil) and (AutoHideHostSite <> nil) then
    AutoHideHostSite.InvalidateNC(True);
  if TabContainer <> nil then
    TabContainer.InvalidateNC(True);
  if SideContainer <> nil then
    SideContainer.InvalidateNC(False);
end;

procedure TdxCustomDockControl.CMVisibleChanged(var Message: TMessage);
begin
  if not IsLoading and (ParentDockControl <> nil) then
  begin
    if Visible then HandleNeeded;  // DB15673
    UpdateRelatedControlsVisibility;
    UpdateCaption;
  end;
  inherited;
  UpdateAutoHideControlsVisibility;
  DoVisibleChanged;
end;

procedure TdxCustomDockControl.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  // TODO: IsActive
  if AutoHide and (AutoHideHostSite <> nil) and (AutoHideHostSite.ShowingControl = Self) then
    AutoHideHostSite.InitializeHiding;

  if FCloseButtonIsHot or FHideButtonIsHot or FMaximizeButtonIsHot then
  begin
    FCloseButtonIsHot := False;
    FHideButtonIsHot := False;
    FMaximizeButtonIsHot := False;
    InvalidateCaptionArea;
  end;
end;

procedure TdxCustomDockControl.CMDesignHitTest(var Message: TCMDesignHitTest);
begin
  inherited;
  with Message do
    if Result = 0 then
      Result := Integer(GetDesignHitTest(Point(XPos, YPos), KeysToShiftState(Keys)));
end;

procedure TdxCustomDockControl.CNKeyDown(var Message: TWMKeyDown);
begin
  case Message.CharCode of
    VK_CONTROL:
      if Controller.DockingDockControl = Self then
        Docking(ClientToScreen(CursorPoint));
    VK_ESCAPE:
      begin
        if Controller.DockingDockControl = Self then
          EndDocking(ClientToScreen(CursorPoint), True)
        else
          if Controller.ResizingDockControl = Self then
            EndResize(ClientToScreen(CursorPoint), True);
      end;
  else
    inherited;
  end;
end;

procedure TdxCustomDockControl.CNKeyUp(var Message: TWMKeyUp);
begin
  if (Message.CharCode = VK_CONTROL) and (Controller.DockingDockControl = Self) then
    Docking(ClientToScreen(CursorPoint))
  else inherited;
end;

procedure TdxCustomDockControl.WMNCCalcSize(var Message: TWMNCCalcSize);
var
  R: TRect;
  OffsetX, OffsetY: Integer;
begin
  if FRecalculateNCNeeded or CanCalculateNC then
  begin
    inherited;
    R := Message.CalcSize_Params.rgrc[0];
    OffsetX := R.Left;
    OffsetY := R.Top;
    OffsetRect(R, -OffsetX, -OffsetY);
    FWindowRect := R;
    if UseDoubleBuffer then
      CheckTempCanvas(FWindowRect);
    Canvas.Font := Font;
    CalculateNC(R);
    OffsetRect(R, OffsetX, OffsetY);
    if R.Left > R.Right then R.Left := R.Right;
    if R.Top > R.Bottom then R.Top := R.Bottom;
    Message.CalcSize_Params.rgrc[0] := R;
    FSavedClientRect := R;
    FRecalculateNCNeeded := False;
  end
  else
    Message.CalcSize_Params.rgrc[0] := FSavedClientRect;
end;

procedure TdxCustomDockControl.WMNCHitTest(var Message: TWMNCHitTest);

  function GetGetTopMostDockControlDesignRect: TRect;
  begin
    Result := GetDesignRect;
    dxMapWindowRect(Handle, 0, Result, False);
  end;

begin
  if not Visible or
    (ParentDockControl <> nil) and PtInRect(GetGetTopMostDockControlDesignRect, SmallPointToPoint(Message.Pos)) then
    Message.Result := HTTRANSPARENT
  else
    Message.Result := HTCLIENT;
end;

procedure TdxCustomDockControl.WMNCPaint(var Message: TWMNCPaint);
var
  DC: HDC;
  ACanvas: TCanvas;
  pt1, pt2: TPoint;
  ASavedIndex: Integer;
begin
  if not CanUpdateNC or IsInternalDestroying then exit;
  DC := GetWindowDC(Handle);
  try
    ASavedIndex := SaveDC(DC);
    try
      pt1 := ClientToWindow(ClientRect.TopLeft);
      pt2 := ClientToWindow(ClientRect.BottomRight);
      ExcludeClipRect(DC, pt1.X, pt1.Y, pt2.X, pt2.Y);
      if UseDoubleBuffer and (TempCanvas <> nil) then
      begin
        NCPaint(TempCanvas);
        SelectClipRgn(TempCanvas.Handle, 0);
        BitBlt(DC, 0, 0, WindowRect.Right, WindowRect.Bottom,
          TempCanvas.Handle, 0, 0, SRCCOPY);
      end
      else
      begin
        ACanvas := TCanvas.Create;
        try
          ACanvas.Handle := DC;
          NCPaint(ACanvas);
        finally
          ACanvas.Free;
        end;
      end;
      DrawDesignRect;
    finally
      RestoreDC(DC, ASavedIndex);
    end;
  finally
    ReleaseDC(Handle, DC);
  end;
end;

{$IFDEF DELPHI5}
procedure TdxCustomDockControl.WMContextMenu(var Message: TWMContextMenu);
var
  Pt, Temp: TPoint;
  AHandled: Boolean;
  APopupMenu: TPopupMenu;
begin
  Include(Controller.FInternalState, disContextMenu);
  try
    Pt := SmallPointToPoint(Message.Pos);
    if (Pt.X < 0) or (Pt.Y < 0) then Temp := Pt
    else Temp := ScreenToClient(Pt);

    AHandled := False;
    DoContextPopup(Temp, AHandled);
    Message.Result := Ord(AHandled);
    if AHandled then Exit;

    APopupMenu := GetPopupMenu;
    if (PopupMenu <> nil) and PopupMenu.AutoPopup then
    begin
      SendCancelMode(nil);
      APopupMenu.PopupComponent := Self;
      if (Pt.X < 0) or (Pt.Y < 0) then
        Pt := ClientToScreen(Point(0, 0));
      APopupMenu.Popup(Pt.X, Pt.Y);
      Message.Result := 1;
    end;
    if Message.Result = 0 then
      inherited;
  finally
    Exclude(Controller.FInternalState, disContextMenu);
  end;
end;
{$ENDIF}

procedure TdxCustomDockControl.WMEraseBkgnd(var Message: TWmEraseBkgnd);
var
  ACanvas: TCanvas;
begin
  if not DoubleBuffered or (TMessage(Message).wParam = TMessage(Message).lParam) then
  begin
    ACanvas := TCanvas.Create;
    try
      ACanvas.Handle := Message.DC;
      DoDrawClient(ACanvas, ClientRect);
    finally
      ACanvas.Free;
    end;
  end;
  Message.Result := 1;
end;

procedure TdxCustomDockControl.WMMouseActivate(var Message: TWMMouseActivate);
begin
  if WindowFromPoint(GetMouseCursorPos) = Handle then
    Activate;
end;

procedure TdxCustomDockControl.WMMove(var Message: TWMMove);
begin
  BeginUpdateNC;
  try
    inherited;
  finally
    EndUpdateNC;
  end;
end;

procedure TdxCustomDockControl.WMMouseMove(var Message: TWMMouseMove);
var
  AIsButtonPoint: Boolean;
begin
  inherited;
  Message.Result := 0;
  FCursorPoint := Point(Message.XPos, Message.YPos);
  if Controller.DockingDockControl = Self then
  begin
    Docking(ClientToScreen(CursorPoint));
    Message.Result := 1;
  end
  else
    if Controller.ResizingDockControl = Self then
    begin
      Resizing(ClientToScreen(CursorPoint));
      Message.Result := 1;
    end
    else
      if FloatFormActive or ParentFormActive or IsDesigning then
      begin
        AIsButtonPoint := IsCaptionCloseButtonPoint(CursorPoint);
        if AIsButtonPoint and not FCloseButtonIsHot then
        begin
          FCloseButtonIsHot := True;
          InvalidateCaptionArea;
          Message.Result := 1;
        end
        else
          if not AIsButtonPoint and FCloseButtonIsHot then
          begin
            FCloseButtonIsHot := False;
            InvalidateCaptionArea;
            Message.Result := 1;
          end;

        AIsButtonPoint := IsCaptionHideButtonPoint(CursorPoint);
        if AIsButtonPoint and not FHideButtonIsHot then
        begin
          FHideButtonIsHot := True;
          InvalidateCaptionArea;
          Message.Result := 1;
        end
        else
          if not AIsButtonPoint and FHideButtonIsHot then
          begin
            FHideButtonIsHot := False;
            InvalidateCaptionArea;
            Message.Result := 1;
          end;

        AIsButtonPoint := IsCaptionMaximizeButtonPoint(CursorPoint);
        if AIsButtonPoint and not FMaximizeButtonIsHot then
        begin
          FMaximizeButtonIsHot := True;
          InvalidateCaptionArea;
          Message.Result := 1;
        end
        else
          if not AIsButtonPoint and FMaximizeButtonIsHot then
          begin
            FMaximizeButtonIsHot := False;
            InvalidateCaptionArea;
            Message.Result := 1;
          end;

        if FCaptionIsDown and ((IsDesigning and
          ((Abs(CursorPoint.X - SourcePoint.X) > 3) or
          (Abs(CursorPoint.Y - SourcePoint.Y) > 3))) or
          not IsCaptionPoint(CursorPoint)) then
        begin
          ReleaseMouse;
          FCaptionIsDown := False;
          StartDocking(ClientToScreen(SourcePoint));
          Message.Result := 1;
        end;
      end;
end;

procedure TdxCustomDockControl.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  Message.Result := 0;
  SourcePoint := Point(Message.XPos, Message.YPos);
  if GetResizeZoneAtPos(ClientToScreen(SourcePoint)) <> nil then
  begin
    StartResize(ClientToScreen(SourcePoint));
    Message.Result := 1;
  end
  else
    if IsCaptionCloseButtonPoint(SourcePoint) then
    begin
      FCloseButtonIsDown := True;
      InvalidateCaptionArea;
      CaptureMouse;
      Message.Result := 1;
    end
    else
      if IsCaptionHideButtonPoint(SourcePoint) then
      begin
        FHideButtonIsDown := True;
        InvalidateCaptionArea;
        CaptureMouse;
        Message.Result := 1;
      end
      else
        if IsCaptionMaximizeButtonPoint(SourcePoint) then
        begin
          FMaximizeButtonIsDown := True;
          InvalidateCaptionArea;
          CaptureMouse;
          Message.Result := 1;
        end
        else
          if IsCaptionPoint(SourcePoint) then
          begin
            FCaptionIsDown := True;
            CaptureMouse;
            Message.Result := 1;
          end;
end;

procedure TdxCustomDockControl.WMRButtonDown(var Message: TWMRButtonDown);
begin
  Controller.FinishDocking;
  Controller.FinishResizing;
  inherited;
end;

procedure TdxCustomDockControl.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  Message.Result := 0;
  FCursorPoint := Point(Message.XPos, Message.YPos);
  if Controller.DockingDockControl = Self then
  begin
    EndDocking(ClientToScreen(CursorPoint), False);
    Message.Result := 1;
  end
  else if Controller.ResizingDockControl = Self then
  begin
    EndResize(ClientToScreen(CursorPoint), False);
    Message.Result := 1;
  end
  else
    if FCloseButtonIsDown then
    begin
      ReleaseMouse;
      FCloseButtonIsDown := False;
      if IsCaptionCloseButtonPoint(CursorPoint) and not IsDesigning then
        DoClose;
      InvalidateCaptionArea;
      Message.Result := 1;
    end
    else
      if FHideButtonIsDown then
      begin
        ReleaseMouse;
        FHideButtonIsDown := False;
        FHideButtonIsHot := False;
        if IsCaptionHideButtonPoint(CursorPoint) then
          ChangeAutoHide;
        InvalidateCaptionArea;
        Message.Result := 1;
      end
      else
        if FMaximizeButtonIsDown then
        begin
          ReleaseMouse;
          FMaximizeButtonIsDown := False;
          if IsCaptionMaximizeButtonPoint(CursorPoint) then
            DoMaximize;
          InvalidateCaptionArea;
          Message.Result := 1;
        end
        else
          if FCaptionIsDown then
          begin
            ReleaseMouse;
            FCaptionIsDown := False;
            Message.Result := 1;
          end;
  // TODO: !!!
  Controller.FActivatingDockControl := nil;
end;

procedure TdxCustomDockControl.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  pt: TPoint;
begin
  inherited;
  Message.Result := 0;
  if not IsDesigning and (doDblClickDocking in ControllerOptions) and not AutoHide and
    Dockable and IsCaptionPoint(CursorPoint) and
    not IsCaptionCloseButtonPoint(CursorPoint) and
    not IsCaptionHideButtonPoint(CursorPoint) and
    not (IsCaptionMaximizeButtonPoint(CursorPoint)) then
  begin
    pt := ClientToScreen(CursorPoint);
    DoStartDocking(pt);
    MakeFloating;
    DoEndDocking(pt);
    Message.Result := 1;
  end;
end;

procedure TdxCustomDockControl.WMSetCursor(var Message: TWMSetCursor);
var
  pt: TPoint;
  AZone: TdxZone;
begin
  if Controller.IsDocking then
  begin
    if (Controller.DockingDockControl.DockingTargetZone = nil) and not AllowFloating then
      SetCursor(Screen.Cursors[crNo])
    else inherited;
  end
  else
  begin
    GetCursorPos(pt);
    AZone := GetResizeZoneAtPos(pt);
    if AZone <> nil then
    begin
      if AZone.Direction = zdHorizontal then
        SetCursor(Screen.Cursors[crVSplit])
      else if AZone.Direction = zdVertical then
        SetCursor(Screen.Cursors[crHSplit])
      else inherited;
    end
    else inherited;
  end;
end;

procedure TdxCustomDockControl.WMSize(var Message: TWMSize);
begin
  if dcisFrameChanged in FInternalState then
    inherited
  else
  begin
    BeginUpdateNC(False);
    try
      inherited;
      if IsDesigning then
      begin
        if ParentDockControl <> nil then
          ParentDockControl.Redraw(True)
        else
          Redraw(True);
      end
      else
        if not (disRedrawLocked in Controller.FInternalState) and Painter.NeedRedrawOnResize then
          if doRedrawOnResize in ControllerOptions then
            Redraw(True)
          else
            Invalidate;
    finally
      EndUpdateNC;
    end;
  end;
end;

{ TdxCustomDockSite }

procedure TdxCustomDockSite.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to ChildCount - 1 do
    if Children[I].Owner = Root then Proc(Children[I]);
end;

procedure TdxCustomDockSite.ValidateInsert(AComponent: TComponent);
begin
  if not (AComponent is TdxCustomDockControl) then
  begin
    if AComponent is TControl then
      (AComponent as TControl).Parent := ParentForm;
    raise EdxException.CreateFmt(sdxInvalidSiteChild, [AComponent.ClassName]);
  end;
end;

{ TdxLayoutDockSite }

constructor TdxLayoutDockSite.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csDesignInteractive];
end;

procedure TdxLayoutDockSite.BeforeDestruction;
begin
  if not CanDestroy then
    raise EdxException.Create(sdxInvalidLayoutSiteDeleting);
  inherited;
end;

function TdxLayoutDockSite.CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean;
begin
  Result := inherited CanDockHost(AControl, AType);
  Result := Result and ((AType in [dtLeft, dtRight, dtTop, dtBottom]) or
    ((Atype in [dtClient]) and (ChildCount = 0)));
end;

procedure TdxLayoutDockSite.SetParent(AParent: TWinControl);
begin
  if not IsUpdateLayoutLocked and not IsDestroying and
    ((AParent = nil) or not (csLoading in AParent.ComponentState)) then
    raise EdxException.Create(sdxInvalidParentAssigning)
  else if (AParent <> nil) and not (AParent is TdxCustomDockControl) then
    raise EdxException.CreateFmt(sdxInvalidParent, [ClassName])
  else inherited SetParent(AParent);
end;

procedure TdxLayoutDockSite.UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer);
begin
  if (SiblingDockControl <> nil) and (SiblingDockControl.DockType = dtClient) then exit;
  if TdxClientZone.ValidateDockZone(Self, AControl) then
    AControl.DockZones.Insert(0, TdxClientZone.Create(Self, AZoneWidth))
  else if TdxInvisibleClientZone.ValidateDockZone(Self, AControl) then
    AControl.DockZones.Insert(0, TdxInvisibleClientZone.Create(Self, AZoneWidth));
  inherited;
end;

procedure TdxLayoutDockSite.CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
  Index: Integer);
begin
  inherited;
  if SiblingDockControl <> nil then
    SiblingDockControl.UpdateRelatedControlsVisibility;
end;

procedure TdxLayoutDockSite.DestroyLayout(AControl: TdxCustomDockControl);
begin
  inherited;
  if SiblingDockControl <> nil then
    SiblingDockControl.UpdateRelatedControlsVisibility;
end;

function TdxLayoutDockSite.GetSiblingDockControl: TdxCustomDockControl;
begin
  if (ParentDockControl <> nil) and (ParentDockControl.ChildCount = 2) then
    Result := ParentDockControl.Children[1 - DockIndex]
  else Result := nil;
end;

function TdxLayoutDockSite.CanDestroy: Boolean;
begin
  Result := ((ParentDockControl = nil) or ParentDockControl.IsDestroying) or
    ((ChildCount = 0) and (ParentDockControl.ChildCount = 1));
end;

procedure TdxLayoutDockSite.WMNCHitTest(var Message: TWMNCHitTest);
begin
  if not Visible or (IsDesigning and not Controller.IsDocking) then
    Message.Result := HTTRANSPARENT
  else inherited;
end;

{ TdxContainerDockSite }

constructor TdxContainerDockSite.Create(AOwner: TComponent);
begin
  inherited;
  UseDoubleBuffer := True;
end;

function TdxContainerDockSite.CanDock: Boolean;
begin
  Result := True;
end;

function TdxContainerDockSite.CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean;
begin
  Result := inherited CanDockHost(AControl, AType);
end;

function TdxContainerDockSite.CanContainerDockHost(AType: TdxDockingType): Boolean;
begin
  Result := (AType = GetHeadDockType) or (AType = GetTailDockType);
end;

function TdxContainerDockSite.GetControlAutoHidePosition(AControl: TdxCustomDockControl): TdxAutoHidePosition;
begin
  Result := inherited GetControlAutoHidePosition(Self);
end;

procedure TdxContainerDockSite.ChildVisibilityChanged(Sender: TdxCustomDockControl);
begin
  if disManagerChanged in Controller.FInternalState then Exit;
  Visible := (ValidChildCount > 0) and not (AutoHide and not Visible);
end;

procedure TdxContainerDockSite.Loaded;
begin
  inherited;
  SetActiveChildByIndex(FActiveChildIndex)
end;

procedure TdxContainerDockSite.SetParent(AParent: TWinControl);
begin
  if not IsUpdateLayoutLocked and not IsDestroying and
    ((AParent = nil) or not (csLoading in AParent.ComponentState)) then
    raise EdxException.Create(sdxInvalidParentAssigning)
  else if (AParent <> nil) and not ((AParent is TdxCustomDockControl) or
    (AutoHide and (AParent is TdxDockSiteAutoHideContainer))) then
    raise EdxException.CreateFmt(sdxInvalidParent, [ClassName])
  else inherited SetParent(AParent);
end;

procedure TdxContainerDockSite.CreateLayout(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
begin
  if CanContainerDockHost(AType) then
    AControl.IncludeToDock(Self, AType, Index)
  else Assert(False, Format(sdxInternalErrorCreateLayout, [TdxContainerDockSite.ClassName]));
end;

procedure TdxContainerDockSite.DestroyChildLayout;
var
  ADockIndex: Integer;
  AAutoHide, AActive: Boolean;
  AParentControl, ASite: TdxCustomDockControl;
begin
  Include(FInternalState, dcisDestroying);
  ADockIndex := DockIndex;
  AParentControl := ParentDockControl;
  if AutoHide then
  begin
    AAutoHide := True;
    AutoHide := False;
  end
  else
    AAutoHide := False;
  AActive := (Container <> nil) and (Container.ActiveChild = Self);
  ASite := Children[0];
  ASite.ExcludeFromDock;
  ExcludeFromDock;
  ASite.SetDockType(dtClient);
  ASite.AdjustControlBounds(Self);
  ASite.IncludeToDock(AParentControl, DockType, ADockIndex);
  if (ASite.Container <> nil) and AActive then
    ASite.Container.ActiveChild := ASite;
  if AAutoHide then
    ASite.AutoHide := True;
  DoDestroy;
end;

procedure TdxContainerDockSite.DestroyLayout(AControl: TdxCustomDockControl);
var
  AParentControl: TdxCustomDockControl;
begin
  AParentControl := ParentDockControl;
  AParentControl.BeginUpdateLayout;
  try
    AControl.ExcludeFromDock;
    if ChildCount = 1 then // !!!
      DestroyChildLayout
    else
      Assert(ChildCount > 0, Format(sdxInternalErrorDestroyLayout, [ClassName]));
  finally
    AParentControl.EndUpdateLayout;
  end;
end;

procedure TdxContainerDockSite.UpdateLayout;
begin
  inherited;
  ValidateActiveChild(-1);
end;

procedure TdxContainerDockSite.LoadLayoutFromCustomIni(AIniFile: TCustomIniFile;
  AParentForm: TCustomForm; AParentControl: TdxCustomDockControl; ASection: string);
begin
  BeginAdjustBounds;
  try
    inherited;
    ActiveChildIndex := AIniFile.ReadInteger(ASection, 'ActiveChildIndex', -1);
  finally
    EndAdjustBounds;
  end;
end;

procedure TdxContainerDockSite.SaveLayoutToCustomIni(AIniFile: TCustomIniFile;
  ASection: string);
begin
  inherited;
  with AIniFile do
    WriteInteger(ASection, 'ActiveChildIndex', ActiveChildIndex);
end;

procedure TdxContainerDockSite.BeginAdjustBounds;
begin
  DisableAlign;
end;

procedure TdxContainerDockSite.EndAdjustBounds;
begin
  EnableAlign;
end;

procedure TdxContainerDockSite.DoActiveChildChanged(APrevActiveChild: TdxCustomDockControl);
begin
  ValidateActiveChild(-1);
  UpdateCaption;
end;

class function TdxContainerDockSite.GetHeadDockType: TdxDockingType;
begin
  Result := dtClient;
end;

class function TdxContainerDockSite.GetTailDockType: TdxDockingType;
begin
  Result := dtClient;
end;

function TdxContainerDockSite.GetFirstValidChild: TdxCustomDockControl;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ChildCount - 1 do
    if IsValidChild(Children[I]) then
    begin
      Result := Children[I];
      break;
    end;
end;

function TdxContainerDockSite.GetFirstValidChildIndex: Integer;
var
  AControl: TdxCustomDockControl;
begin
  AControl := GetFirstValidChild;
  if AControl <> nil then
    Result := AControl.DockIndex
  else Result := -1;
end;

function TdxContainerDockSite.GetLastValidChild: TdxCustomDockControl;
var
  I: Integer;
begin
  Result := nil;
  for I := ChildCount - 1 downto 0 do
    if IsValidChild(Children[I]) then
    begin
      Result := Children[I];
      break;
    end;
end;

function TdxContainerDockSite.GetLastValidChildIndex: Integer;
var
  AControl: TdxCustomDockControl;
begin
  AControl := GetLastValidChild;
  if AControl <> nil then
    Result := AControl.DockIndex
  else Result := -1;
end;

function TdxContainerDockSite.GetNextValidChild(AIndex: Integer): TdxCustomDockControl;
var
  I: Integer;
begin
  Result := nil;
  for I := AIndex + 1 to ChildCount - 1 do
    if IsValidChild(Children[I]) then
    begin
      Result := Children[I];
      break;
    end;
end;

function TdxContainerDockSite.GetNextValidChildIndex(AIndex: Integer): Integer;
var
  AControl: TdxCustomDockControl;
begin
  AControl := GetNextValidChild(AIndex);
  if AControl <> nil then
    Result := AControl.DockIndex
  else Result := -1;
end;

function TdxContainerDockSite.GetPrevValidChild(AIndex: Integer): TdxCustomDockControl;
var
  I: Integer;
begin
  Result := nil;
  for I := AIndex - 1 downto 0  do
    if IsValidChild(Children[I]) then
    begin
      Result := Children[I];
      break;
    end;
end;

function TdxContainerDockSite.GetPrevValidChildIndex(AIndex: Integer): Integer;
var
  AControl: TdxCustomDockControl;
begin
  AControl := GetPrevValidChild(AIndex);
  if AControl <> nil then
    Result := AControl.DockIndex
  else Result := -1;
end;

function TdxContainerDockSite.IsValidActiveChild(AControl: TdxCustomDockControl): Boolean;
begin
  Result := IsValidChild(AControl);
end;

procedure TdxContainerDockSite.ValidateActiveChild(AIndex: Integer);
begin
end;

function TdxContainerDockSite.GetActiveChildIndex: Integer;
begin
  if IsLoading then
    Result := FActiveChildIndex
  else
    if ActiveChild <> nil then
      Result := ActiveChild.DockIndex
    else
      Result := -1;
end;

procedure TdxContainerDockSite.SetActiveChildByIndex(AIndex: Integer);
begin
  if (0 <= AIndex) and (AIndex < ChildCount) then
    ActiveChild := Children[AIndex]
  else
    ActiveChild := nil;
end;

procedure TdxContainerDockSite.SetActiveChild(Value: TdxCustomDockControl);
var
  APrevActiveChild: TdxCustomDockControl;
begin
  if (FActiveChild <> Value) and ((Value = nil) or IsValidActiveChild(Value)) then
  begin
    BeginUpdateNC;
    try
      APrevActiveChild := FActiveChild;
      FActiveChild := Value;
      DoActiveChildChanged(APrevActiveChild);
      if Assigned(FOnActiveChildChanged) then
        FOnActiveChildChanged(Self, FActiveChild);
    finally
      EndUpdateNC;
    end;
    Modified;
  end;
end;

procedure TdxContainerDockSite.SetActiveChildIndex(Value: Integer);
begin
  if IsLoading then
    FActiveChildIndex := Value
  else
    SetActiveChildByIndex(Value);
end;

{ TdxTabContainerDockSite }

constructor TdxTabContainerDockSite.Create(AOwner: TComponent);
begin
  inherited;
  FFirstVisibleTabIndex := 0;
  FPressedTabIndex := -1;
  FTabsPosition := tctpBottom;
  FTabsScroll := True;
  FTabsScrollTimerID := -1;
end;

procedure TdxTabContainerDockSite.Assign(Source: TPersistent);
var
  AContainer: TdxTabContainerDockSite;
begin
  if Source is TdxTabContainerDockSite then
  begin
    AContainer := Source as TdxTabContainerDockSite;
    TabsPosition := AContainer.TabsPosition;
    TabsScroll := AContainer.TabsScroll;
  end;
  inherited Assign(Source);
end;

procedure TdxTabContainerDockSite.DoActiveChildChanged(APrevActiveChild: TdxCustomDockControl);
var
  AParentForm: TCustomForm;
  AWasActive: Boolean;
begin
  inherited;

  AParentForm := Forms.GetParentForm(Self);
  AWasActive := (AParentForm <> nil) and (APrevActiveChild <> nil) and APrevActiveChild.ContainsControl(AParentForm.ActiveControl);

  if ActiveChild <> nil then
    ActiveChild.BringToFront;
  if (AutoHideControl = Self) and (AutoHideHostSite <> nil) then
    AutoHideHostSite.InvalidateNC(False);
  InvalidateNC(False);
  UpdateChildrenState;

  if AWasActive then
    if (FActiveChild <> nil) then
      FActiveChild.DoActivate
    else
      AParentForm.ActiveControl := Self;
end;

procedure TdxTabContainerDockSite.UpdateActiveTab;
begin
  if ActiveChild <> nil then
    Controller.ActiveDockControl := ActiveChild;
end;

procedure TdxTabContainerDockSite.UpdateChildrenState;
var
  I: Integer;
begin
  for I := 0 to ChildCount - 1 do
    Children[I].UpdateState;
end;

procedure TdxTabContainerDockSite.ValidateActiveChild(AIndex: Integer);
var
  AActiveChild: TdxCustomDockControl;
begin
  if not IsValidChild(ActiveChild) then
  begin
    if (ActiveChild <> nil) and IsValidChild(ActiveChild.Container) then
      ActiveChild := ActiveChild.Container
    else if AIndex = -1 then
      ActiveChild := GetFirstValidChild
    else
    begin
      if (0 <= AIndex) and (AIndex < ChildCount) then
        AActiveChild := Children[AIndex]
      else AActiveChild := nil;
      if not IsValidChild(AActiveChild) then
      begin
        AActiveChild := GetNextValidChild(AIndex);
        if AActiveChild = nil then
          AActiveChild := GetPrevValidChild(AIndex);
      end;
      ActiveChild := AActiveChild;
    end;
  end;
  ValidateFirstVisibleIndex;
end;

procedure TdxTabContainerDockSite.ValidateFirstVisibleIndex;
begin
  if IsLoading or (ActiveChildIndex < 0) then exit;
  if (FirstVisibleTabIndex > ActiveChildIndex) or (ActiveChildIndex > LastVisibleTabIndex) then
  begin
    NCChanged(True);
    if FirstVisibleTabIndex > ActiveChildIndex then
    begin
      while FirstVisibleTabIndex > ActiveChildIndex do
        if not DecFirstVisibleTabIndex then
          Break;
    end
    else
      if ActiveChildIndex > LastVisibleTabIndex then
        while ActiveChildIndex > LastVisibleTabIndex do
          if not IncFirstVisibleTabIndex then
            Break;
  end;
end;

procedure TdxTabContainerDockSite.CalculateNC(var ARect: TRect);
var
  I, XPos: Integer;
  AWidth, ATabWidth: Integer;
begin
  inherited CalculateNC(ARect);
  FTabsRect.Left := ARect.Left;
  FTabsRect.Right := ARect.Right;
  with Painter do
  begin
    if TabsPosition = tctpTop then
    begin
      FTabsRect.Top := ARect.Top;
      FTabsRect.Bottom := FTabsRect.Top + GetTabsHeight + GetTabVertOffset;
      if HasTabs then
        ARect.Top := FTabsRect.Bottom;
    end
    else
    begin
      FTabsRect.Bottom := ARect.Bottom;
      FTabsRect.Top := FTabsRect.Bottom - GetTabsHeight - GetTabVertOffset;
      if FTabsRect.Top < ARect.Top then
      begin
        FTabsRect.Top := ARect.Top;
        FTabsRect.Bottom := FTabsRect.Top + Painter.GetTabsHeight;
      end;
      if HasTabs then
        ARect.Bottom := FTabsRect.Top;
    end;
  end;  

  FTabsPrevTabButtonIsEnabled := False;
  FTabsNextTabButtonIsEnabled := False;
  if TabsScroll then
  begin
    FTabsNextTabButtonRect.Right := FTabsRect.Right - Painter.GetTabHorizInterval;
    FTabsNextTabButtonRect.Left := FTabsNextTabButtonRect.Right - Painter.GetTabsButtonSize;
    FTabsNextTabButtonRect.Top := FTabsRect.Top + Painter.GetTabVertInterval +
      (FTabsRect.Bottom - FTabsRect.Top - Painter.GetTabVertInterval -
      Painter.GetTabsButtonSize) div 2;
    FTabsNextTabButtonRect.Bottom := FTabsNextTabButtonRect.Top + Painter.GetTabsButtonSize;
    FTabsPrevTabButtonRect.Right := FTabsNextTabButtonRect.Left - 1;
    FTabsPrevTabButtonRect.Left := FTabsPrevTabButtonRect.Right - Painter.GetTabsButtonSize;
    FTabsPrevTabButtonRect.Top := FTabsRect.Top + Painter.GetTabVertInterval +
      (FTabsRect.Bottom - FTabsRect.Top - Painter.GetTabVertInterval -
      Painter.GetTabsButtonSize) div 2;
    FTabsPrevTabButtonRect.Bottom := FTabsPrevTabButtonRect.Top + Painter.GetTabsButtonSize;
  end;

  AWidth := 0;
  if not TabsScroll then
    for I := 0 to ChildCount - 1 do
      if IsValidChild(Children[I]) then Inc(AWidth, GetTabWidth(Children[I]));

  SetLength(FTabsRects, ChildCount);
  XPos := FTabsRect.Left + Painter.GetTabHorizOffset;
  with Painter do
  begin
    for I := 0 to FirstVisibleTabIndex - 1 do
    begin
      if not IsValidChild(Children[I]) then continue;
      if TabsScroll or (AWidth < (FTabsRect.Right - FTabsRect.Left) - 2 * GetTabHorizInterval) then
        ATabWidth := GetTabWidth(Children[I])
      else
        ATabWidth := ((FTabsRect.Right - FTabsRect.Left) -  2 * GetTabHorizInterval) div ValidChildCount;
      FTabsRects[I].Right := XPos;
      FTabsRects[I].Top := FTabsRect.Top + GetTabVertInterval;

      if TabsPosition = tctpBottom then
        Inc(FTabsRects[I].Top, GetTabVertInterval)
      else
        Inc(FTabsRects[I].Top, GetTabVertOffset);

      FTabsRects[I].Left := XPos - ATabWidth;
      FTabsRects[I].Bottom := FTabsRect.Bottom - GetTabVertInterval;

      if TabsPosition = tctpTop then
        Dec(FTabsRects[I].Bottom, GetTabVertInterval)
      else
        Dec(FTabsRects[I].Bottom, GetTabVertOffset);

      FTabsRects[I] := FTabsRects[I];
      XPos := XPos - ATabWidth;
    end;
    XPos := FTabsRect.Left + Painter.GetTabHorizOffset;
    for I := FirstVisibleTabIndex to ChildCount - 1 do
    begin
      if not IsValidChild(Children[I]) then continue;
      if TabsScroll or (AWidth < (FTabsRect.Right - FTabsRect.Left) - 2 * GetTabHorizInterval) then
        ATabWidth := GetTabWidth(Children[I])
      else
        ATabWidth := ((FTabsRect.Right - FTabsRect.Left) -
          2 * GetTabHorizInterval ) div ValidChildCount;
      FTabsRects[I].Left := XPos;
      FTabsRects[I].Top := FTabsRect.Top + GetTabVertInterval;
      if TabsPosition = tctpBottom then
        Inc(FTabsRects[I].Top, GetTabVertInterval)
      else
        Inc(FTabsRects[I].Top, GetTabVertOffset);
      FTabsRects[I].Right := XPos + ATabWidth;
      FTabsRects[I].Bottom := FTabsRect.Bottom - GetTabVertInterval;
      if TabsPosition = tctpTop then
        Dec(FTabsRects[I].Bottom, GetTabVertInterval)
      else
        Dec(FTabsRects[I].Bottom, GetTabVertOffset);
      XPos := XPos + ATabWidth;
    end;
  end;  
  UpdateButtonsState;
end;

procedure TdxTabContainerDockSite.NCPaint(ACanvas: TCanvas);
var
  I: Integer;
  R: TRect;
begin
  inherited;
  if HasTabs then
  begin
    if TabRectCount > 0 then
    begin
      R := TabsRects[ActiveChildIndex];
      Painter.CorrectTabRect(R, TabsPosition, True);
      Painter.DrawTabs(ACanvas, TabsRect, R, TabsPosition);
    end;
    if TabsButtonsVisible then
    begin
      Painter.DrawTabsNextTabButton(ACanvas, TabsNextTabButtonRect, TabsNextTabButtonIsDown,
        TabsNextTabButtonIsHot, TabsNextTabButtonIsEnabled, TabsPosition);
      Painter.DrawTabsPrevTabButton(ACanvas, TabsPrevTabButtonRect, TabsPrevTabButtonIsDown,
        TabsPrevTabButtonIsHot, TabsPrevTabButtonIsEnabled, TabsPosition);
      ExcludeClipRect(ACanvas.Handle, TabsPrevTabButtonRect.Left - Painter.GetTabHorizInterval,
        TabsRect.Top, TabsRect.Right, TabsRect.Bottom);
    end;
    for I := 0 to TabRectCount - 1 do
      if IsValidChild(Children[I]) then
        if PtInRect(TabsRect, TabsRects[I].TopLeft) then
        begin
          if Painter.DrawActiveTabLast and (ActiveChildIndex = I) then Continue;
          R := TabsRects[I];
          Painter.CorrectTabRect(R, TabsPosition, ActiveChildIndex = I);
          Painter.DrawTab(ACanvas, Children[I], R, ActiveChildIndex = I, TabsPosition);
        end;
    if Painter.DrawActiveTabLast then
    begin
      R := TabsRects[ActiveChildIndex];
      Painter.CorrectTabRect(R, TabsPosition, True);
      Painter.DrawTab(ACanvas, Children[ActiveChildIndex], R, True, TabsPosition);
    end;           
  end;
end;

function TdxTabContainerDockSite.GetTabIndexAtPos(pt: TPoint): Integer;
var
  I: Integer;
begin
  Result := -1;
  if HasTabs then
  begin
    pt := ClientToWindow(pt);
    for I := 0 to TabRectCount - 1 do
      if IsValidChild(Children[I]) and PtInRect(FTabsRects[I], pt) then
      begin
        Result := I;
        break;
      end;
  end;
end;

function TdxTabContainerDockSite.GetTabWidth(AControl: TdxCustomDockControl): Integer;
begin
  Result := AControl.GetTabWidth(Canvas);
end;

function TdxTabContainerDockSite.HasBorder: Boolean;
begin
  Result := (FloatDockSite = nil) and ((ValidChildCount > 1) or AutoHide);
end;

function TdxTabContainerDockSite.HasCaption: Boolean;
begin
  Result := (doTabContainerHasCaption in ControllerOptions) and
    ShowCaption and HasBorder;
end;

function TdxTabContainerDockSite.HasTabs: Boolean;
begin
  Result := not AutoHide and (ValidChildCount > 1);
end;

function TdxTabContainerDockSite.IsCaptionActive: Boolean;
begin
  Result := inherited IsCaptionActive;
  Result := Result or ((Controller.ActiveDockControl <> nil) and
    (Controller.ActiveDockControl.Container = Self) and Application.Active);
end;

function TdxTabContainerDockSite.IsTabsPoint(pt: TPoint): Boolean;
begin
  Result := HasTabs and PtInRect(TabsRect, ClientToWindow(pt));
end;

function TdxTabContainerDockSite.IsTabsNextTabButtonPoint(pt: TPoint): Boolean;
begin
  Result := TabsButtonsVisible and PtInRect(TabsNextTabButtonRect, ClientToWindow(pt));
end;

function TdxTabContainerDockSite.IsTabsPrevTabButtonPoint(pt: TPoint): Boolean;
begin
  Result := TabsButtonsVisible and PtInRect(TabsPrevTabButtonRect, ClientToWindow(pt));
end;

procedure TdxTabContainerDockSite.DoIncrementTabsScroll;
begin
  if FTabsNextTabButtonIsDown then
  begin
    if IsTabsNextTabButtonPoint(CursorPoint) then
      IncFirstVisibleTabIndex;
  end
  else if FTabsScrollTimerID > -1 then
  begin
    KillTimer(Handle, FTabsScrollTimerID);
    FTabsScrollTimerID := -1;
  end;
end;

procedure TdxTabContainerDockSite.DoDecrementTabsScroll;
begin
  if FTabsPrevTabButtonIsDown then
  begin
    if IsTabsPrevTabButtonPoint(CursorPoint) then
      DecFirstVisibleTabIndex;
  end
  else if FTabsScrollTimerID > -1 then
  begin
    KillTimer(Handle, FTabsScrollTimerID);
    FTabsScrollTimerID := -1;
  end;
end;

procedure IncrementTabsScrollTimerProc(Wnd: HWnd; Msg, TimerID, SysTime: Longint); stdcall;
var
  AControl: TdxTabContainerDockSite;
begin
  AControl := TdxTabContainerDockSite(FindControl(Wnd));
  if AControl <> nil then
    AControl.DoIncrementTabsScroll;
end;

procedure TdxTabContainerDockSite.InitIncrementTabsScroll;
begin
  if FTabsScrollTimerID > -1 then
  begin
    KillTimer(Handle, FTabsScrollTimerID);
    FTabsScrollTimerID := -1;
  end;
  FTabsScrollTimerID := SetTimer(Handle, 1, ControllerTabsScrollInterval, @IncrementTabsScrollTimerProc);
end;

procedure DecrementTabsScrollTimerProc(Wnd: HWnd; Msg, TimerID, SysTime: Longint); stdcall;
var
  AControl: TdxTabContainerDockSite;
begin
  AControl := TdxTabContainerDockSite(FindControl(Wnd));
  if AControl <> nil then
    AControl.DoDecrementTabsScroll;
end;

procedure TdxTabContainerDockSite.InitDecrementTabsScroll;
begin
  if FTabsScrollTimerID > -1 then
  begin
    KillTimer(Handle, FTabsScrollTimerID);
    FTabsScrollTimerID := -1;
  end;
  FTabsScrollTimerID := SetTimer(Handle, 1, ControllerTabsScrollInterval, @DecrementTabsScrollTimerProc);
end;

function TdxTabContainerDockSite.CanActive: Boolean;
begin
  Result := True;
end;

function TdxTabContainerDockSite.CanAutoHide: Boolean;
begin
  Result := IsLoading or ((AutoHideHostSite <> nil) and
    ((AutoHideControl = nil) or (AutoHideControl = Self)));
end;

function TdxTabContainerDockSite.CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean;
var
  ACanDockHost: Boolean;
begin
  ACanDockHost := CanContainerDockHost(AType);
  if Container is TdxSideContainerDockSite then
  begin
    ACanDockHost := ACanDockHost or Container.CanContainerDockHost(AType);
    if doSideContainerCanInSideContainer in ControllerOptions then
      ACanDockHost := ACanDockHost or (AType in [dtLeft, dtRight, dtTop, dtBottom]);
  end
  else if doTabContainerCanInSideContainer in ControllerOptions then
    ACanDockHost := ACanDockHost or (AType in [dtLeft, dtRight, dtTop, dtBottom]);
  Result := inherited CanDockHost(AControl, AType) and ACanDockHost;;
end;

function TdxTabContainerDockSite.CanMaximize: Boolean;
begin
  Result := not AutoHide and (SideContainer <> nil) and (SideContainer.ValidChildCount > 1);
end;

procedure TdxTabContainerDockSite.ActivateNextChild(AGoForward, AGoOnCycle: Boolean);
var
  AIndex, AnActiveChildIndex: Integer;
begin
  AnActiveChildIndex := ActiveChildIndex;
  AIndex := AnActiveChildIndex;
  if AIndex = -1 then
    AIndex := 0
  else
    repeat
      if AGoForward then
      begin
        if AIndex < ChildCount - 1 then
          Inc(AIndex)
        else
          AIndex := IfThen(AGoOnCycle, 0, AnActiveChildIndex);
      end
      else
      begin
        if AIndex > 0 then
          Dec(AIndex)
        else
          AIndex := IfThen(AGoOnCycle, ChildCount - 1, AnActiveChildIndex);
      end;
    until IsValidChild(Children[AIndex]) or (AIndex = AnActiveChildIndex);
  ActiveChildIndex := AIndex;
end;

function TdxTabContainerDockSite.GetDesignHitTest(const APoint: TPoint; AShift: TShiftState): Boolean;
begin
  Result := inherited GetDesignHitTest(APoint, AShift) or
    (IsTabsPoint(APoint) and (ssLeft in AShift)) or (FPressedTabIndex > -1) or
    FTabsNextTabButtonIsDown or FTabsPrevTabButtonIsDown;
end;

function TdxTabContainerDockSite.CanResizeAtPos(pt: TPoint): Boolean;
begin
  Result := inherited CanResizeAtPos(pt);
  Result := Result and (GetTabIndexAtPos(pt) = -1);
end;

procedure TdxTabContainerDockSite.UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer);
var
  I: Integer;
begin
  if not (doUseCaptionAreaToClientDocking in ControllerOptions) then
  begin
    if TdxTabContainerZone.ValidateDockZone(Self, AControl) then
      DockZones.Insert(0, TdxTabContainerZone.Create(Self));
  end;
  inherited;
  if TdxTabContainerTabZone.ValidateDockZone(Self, AControl) then
    for I := 0 to ChildCount - 1 do
    begin
      if not IsValidChild(Children[I]) then continue;
      DockZones.Insert(0, TdxTabContainerTabZone.Create(Self, I));
    end;
  if doUseCaptionAreaToClientDocking in ControllerOptions then
  begin
    if TdxTabContainerCaptionZone.ValidateDockZone(Self, AControl) then
      DockZones.Insert(0, TdxTabContainerCaptionZone.Create(Self));
  end;
end;

procedure TdxTabContainerDockSite.CreateLayout(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
begin
  if CanContainerDockHost(AType) then
    inherited CreateLayout(AControl, AType, Index)
  else if (Container <> nil) and Container.CanContainerDockHost(AType) then
    CreateContainerLayout(Container, AControl, AType, DockIndex)
  else
    case AType of
      dtLeft, dtRight,
      dtTop, dtBottom:
        CreateSideContainerLayout(AControl, AType, Index);
    else
      Assert(False, Format(sdxInternalErrorCreateLayout, [TdxTabContainerDockSite.ClassName]));
    end;
end;

procedure TdxTabContainerDockSite.DestroyLayout(AControl: TdxCustomDockControl);
var
  AActiveIndex: Integer;
begin
  if ActiveChild <> nil then
    AActiveIndex := ActiveChild.DockIndex
  else AActiveIndex := -1;
  inherited;
  if (AControl = ActiveChild) and (ChildCount > 1) then
    ValidateActiveChild(AActiveIndex);
end;

procedure TdxTabContainerDockSite.IncludeToDock(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
var
  AChild: TdxCustomDockControl;
begin
  if AControl.CanAcceptTabContainerItems(Self) and (ChildCount > 0) then
  begin
    Include(FInternalState, dcisDestroying);
    while ChildCount > 0 do
    begin
      AChild := Children[ChildCount - 1];
      AChild.ExcludeFromDock;
      AChild.IncludeToDock(AControl, AType, Index);
    end;
    DoDestroy;
  end
  else inherited;
end;

procedure TdxTabContainerDockSite.UpdateLayout;
begin
  inherited;
  if ActiveChild <> nil then
    ActiveChild.BringToFront;
  NCChanged;
end;

procedure TdxTabContainerDockSite.LoadLayoutFromCustomIni(AIniFile: TCustomIniFile;
  AParentForm: TCustomForm; AParentControl: TdxCustomDockControl; ASection: string);
begin
  inherited;
  with AIniFile do
  begin
    ShowCaption := ReadBool(ASection, 'ShowCaption', ShowCaption);
    TabsPosition := TdxTabContainerTabsPosition(ReadInteger(ASection, 'TabsPosition', 0));
    TabsScroll := ReadBool(ASection, 'TabsScroll', True);
  end;
end;

procedure TdxTabContainerDockSite.SaveLayoutToCustomIni(AIniFile: TCustomIniFile;
  ASection: string);
begin
  inherited;
  with AIniFile do
  begin
    WriteBool(ASection, 'ShowCaption', ShowCaption);
    WriteInteger(ASection, 'TabsPosition', Integer(TabsPosition));
    WriteBool(ASection, 'TabsScroll', TabsScroll);
  end;
end;

function TdxTabContainerDockSite.CanAcceptSideContainerItems(AContainer: TdxSideContainerDockSite): Boolean;
begin
  if (doSideContainerCanInTabContainer in ControllerOptions) or IsLoading then
    Result := False
  else
    Result := True;
end;

function TdxTabContainerDockSite.CanAcceptTabContainerItems(AContainer: TdxTabContainerDockSite): Boolean;
begin
  Result := True;
end;

procedure TdxTabContainerDockSite.ChangeAutoHide;
begin
  if AutoHide then
    AutoHide := False
  else if doTabContainerCanAutoHide in ControllerOptions then
    inherited ChangeAutoHide
  else if ActiveChild <> nil then
    ActiveChild.ChangeAutoHide;
end;

procedure TdxTabContainerDockSite.UpdateCaption;
var
  ACaption: string;
begin
  if ActiveChild <> nil then
    ACaption := ActiveChild.Caption
  else ACaption := '';
  if Caption <> ACaption then
    Caption := ACaption;
  inherited UpdateCaption;
end;

procedure TdxTabContainerDockSite.DoClose;
var
  I: Integer;
begin
  if (doTabContainerCanClose in ControllerOptions) then
  begin
    BeginUpdateLayout;
    try
      for I := ChildCount - 1 downto 0 do
      begin
        if Children[I].Visible then
          Children[I].DoClose;
      end;    
      if (AutoHideControl = Self) and (AutoHideHostSite <> nil) then
        AutoHideHostSite.InvalidateNC(True);
    finally
      EndUpdateLayout;
    end;
  end
  else
    if ActiveChild <> nil then
    begin
      ActiveChild.DoClose;
      if (AutoHideControl = Self) and (AutoHideHostSite <> nil) then
        AutoHideHostSite.InvalidateNC(True);
      UpdateActiveTab;
    end;
end;

procedure TdxTabContainerDockSite.ChildVisibilityChanged(Sender: TdxCustomDockControl);
begin
  inherited ChildVisibilityChanged(Sender);
  if not IsValidChild(Sender) then
  begin
    if Sender = ActiveChild then
      ValidateActiveChild(Sender.DockIndex);
    if (FirstVisibleTabIndex <= Sender.DockIndex) and
      (Sender.DockIndex <= LastVisibleTabIndex) then
      DecFirstVisibleTabIndex;
  end;
end;

function TdxTabContainerDockSite.GetLastVisibleTabIndex: Integer;
begin
  if not HandleAllocated and (TabRectCount = 0) then
  begin
    Result := ValidChildCount;
    Exit;
  end;
  if ChildCount <> TabRectCount then InvalidateNC(True);
  if ValidChildCount < 2 then
    Result := FirstVisibleTabIndex
  else
  begin
    if FFirstVisibleTabIndex >= TabRectCount then
      Result := FFirstVisibleTabIndex
    else
    begin
      for Result := FFirstVisibleTabIndex to TabRectCount - 1 do
      begin
        if (0 > Result) or (Result > ChildCount - 1) then continue;
        if not IsValidChild(Children[Result]) then continue;
        if (TabsButtonsVisible and (TabsRects[Result].Right > TabsPrevTabButtonRect.Left - Painter.GetTabHorizInterval)) or
          (TabsRects[Result].Right > TabsRect.Right) then break;
      end;
      if Result > FFirstVisibleTabIndex then
        Dec(Result);
    end;  
  end;
end;

function TdxTabContainerDockSite.GetTabRectCount: Integer;
begin
  Result := Length(FTabsRects);
end;

function TdxTabContainerDockSite.GetTabRect(Index: Integer): TRect;
begin
  Result := FTabsRects[Index];
end;

function TdxTabContainerDockSite.GetTabsButtonsVisible: Boolean;
begin
  Result := TabsScroll and (TabsPrevTabButtonIsEnabled or TabsNextTabButtonIsEnabled);
end;

procedure TdxTabContainerDockSite.SetTabsPosition(const Value: TdxTabContainerTabsPosition);
begin
  if FTabsPosition <> Value then
  begin
    FTabsPosition := Value;
    NCChanged;
  end;
end;

procedure TdxTabContainerDockSite.SetTabsScroll(const Value: Boolean);
begin
  if FTabsScroll <> Value then
  begin
    FTabsScroll := Value;
    if not FTabsScroll then
      FFirstVisibleTabIndex := 0;
    InvalidateNC(True);
  end;
end;

function TdxTabContainerDockSite.DecFirstVisibleTabIndex: Boolean;
var
  AIndex: Integer;
begin
  if Width = 0 then
  begin
    Result := False;
    Exit;
  end;
  AIndex := GetPrevValidChildIndex(FirstVisibleTabIndex);
  Result := AIndex <> -1;
  if Result then
  begin
    FFirstVisibleTabIndex := AIndex;
    InvalidateNC(True);
  end;
end;

function TdxTabContainerDockSite.IncFirstVisibleTabIndex: Boolean;
var
  AIndex: Integer;
begin
  if Width = 0 then
  begin
    Result := False;
    Exit;
  end;
  AIndex := GetNextValidChildIndex(FirstVisibleTabIndex);
  Result := AIndex <> -1;
  if Result then
  begin
    FFirstVisibleTabIndex := AIndex;
    InvalidateNC(True);
  end;
end;

procedure TdxTabContainerDockSite.UpdateButtonsState;
begin
  FTabsPrevTabButtonIsEnabled := GetPrevValidChild(FirstVisibleTabIndex) <> nil;
  FTabsNextTabButtonIsEnabled := GetNextValidChild(LastVisibleTabIndex) <> nil;
end;

procedure TdxTabContainerDockSite.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FTabsNextTabButtonIsHot or FTabsPrevTabButtonIsHot then
  begin
    FTabsNextTabButtonIsHot := False;
    FTabsPrevTabButtonIsHot := False;
    InvalidateNC(False);
  end;
end;

procedure TdxTabContainerDockSite.WMLButtonDown(var Message: TWMLButtonDown);
var
  APressedTabIndex: Integer;
begin
  inherited;
  if Message.Result = 0 then
  begin
    if IsTabsNextTabButtonPoint(SourcePoint) then
    begin
      if TabsNextTabButtonIsEnabled then
      begin
        FTabsNextTabButtonIsDown := True;
        InvalidateNC(False);
        InitIncrementTabsScroll;
        CaptureMouse;
      end;
      Message.Result := 1;
    end
    else if IsTabsPrevTabButtonPoint(SourcePoint) then
    begin
      if TabsPrevTabButtonIsEnabled then
      begin
        FTabsPrevTabButtonIsDown := True;
        InvalidateNC(False);
        InitDecrementTabsScroll;
        CaptureMouse;
      end;
      Message.Result := 1;
    end
    else
    begin
      APressedTabIndex := GetTabIndexAtPos(SourcePoint);
      if APressedTabIndex > -1 then
      begin
        CaptureMouse;
        ActiveChild := Children[APressedTabIndex];
        if ActiveChild = Children[APressedTabIndex] then
        begin
          Controller.ActiveDockControl := Children[APressedTabIndex];
          FPressedTabIndex := APressedTabIndex;
          Modified;
        end;
      end;
      Message.Result := 1;
    end;
  end;
end;

procedure TdxTabContainerDockSite.WMLButtonUp(var Message: TWMLButtonUp);
begin
  inherited;
  if Message.Result = 0 then
  begin
    if FTabsNextTabButtonIsDown then
    begin
      ReleaseMouse;
      DoIncrementTabsScroll;
      FTabsNextTabButtonIsDown := False;
      InvalidateNC(False);
      Message.Result := 1;
    end
    else if FTabsPrevTabButtonIsDown then
    begin
      ReleaseMouse;
      DoDecrementTabsScroll;
      FTabsPrevTabButtonIsDown := False;
      InvalidateNC(False);
      Message.Result := 1;
    end
    else if FPressedTabIndex > -1 then
    begin
       ReleaseMouse;
      FPressedTabIndex := -1;
      Message.Result := 1;
    end;
  end;
end;

procedure TdxTabContainerDockSite.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  pt: TPoint;
  ATabIndex: Integer;
  AControl: TdxCustomDockControl;
begin
  inherited;
  if Message.Result = 0 then
  begin
    ATabIndex := GetTabIndexAtPos(CursorPoint);
    if not IsDesigning and (doDblClickDocking in ControllerOptions) and
      not AutoHide and (ATabIndex > -1) and
      not IsTabsNextTabButtonPoint(CursorPoint) and
      not IsTabsPrevTabButtonPoint(CursorPoint) then
    begin
      AControl := Children[ATabIndex];
      if (AControl <> nil) and AControl.Dockable then
      begin
        pt := ClientToScreen(CursorPoint);
        DoStartDocking(pt);
        AControl.MakeFloating;
        DoEndDocking(pt);
        Message.Result := 1;
      end;
    end;
  end;
end;

procedure TdxTabContainerDockSite.WMMouseMove(var Message: TWMMouseMove);
var
  AIsButtonPoint: Boolean;
begin
  inherited;
  if (Message.Result = 0) and (FloatFormActive or ParentFormActive or IsDesigning) then
  begin
    AIsButtonPoint := IsTabsNextTabButtonPoint(CursorPoint);
    if AIsButtonPoint and not FTabsNextTabButtonIsHot then
    begin
      FTabsPrevTabButtonIsHot := False;
      FTabsNextTabButtonIsHot := True;
      InvalidateNC(False);
      Message.Result := 1;
    end;
    if not AIsButtonPoint and FTabsNextTabButtonIsHot then
    begin
      FTabsNextTabButtonIsHot := False;
      InvalidateNC(False);
      Message.Result := 1;
    end;
    AIsButtonPoint := IsTabsPrevTabButtonPoint(CursorPoint);
    if AIsButtonPoint and not FTabsPrevTabButtonIsHot then
    begin
      FTabsNextTabButtonIsHot := False;
      FTabsPrevTabButtonIsHot := True;
      InvalidateNC(False);
      Message.Result := 1;
    end;
    if not AIsButtonPoint and FTabsPrevTabButtonIsHot then
    begin
      FTabsPrevTabButtonIsHot := False;
      InvalidateNC(False);
      Message.Result := 1;
    end;
    if (FPressedTabIndex > -1) and ((IsDesigning and
      ((Abs(CursorPoint.X - SourcePoint.X) > 3) or (Abs(CursorPoint.Y - SourcePoint.Y) > 3))) or
      ((GetTabIndexAtPos(CursorPoint) <> FPressedTabIndex) and
      ((Abs(CursorPoint.X - SourcePoint.X) > 0) or (Abs(CursorPoint.Y - SourcePoint.Y) > 0)))) then
    begin
      ReleaseMouse;
      FPressedTabIndex := -1;
      if ActiveChild <> nil then
        ActiveChild.StartDocking(ClientToScreen(SourcePoint));
      Message.Result := 1;
    end;
  end;
end;

{ TdxSideContainerDockSite }

procedure TdxSideContainerDockSite.DoActiveChildChanged(APrevActiveChild: TdxCustomDockControl);
begin
  inherited;
  NCChanged;
  AdjustChildrenBounds(nil);
end;

function TdxSideContainerDockSite.CanChildResize(AControl: TdxCustomDockControl; ADeltaSize: Integer): Boolean;
var
  AIndex, ANextIndex: Integer;
begin
  AIndex := AControl.DockIndex;
  ANextIndex := GetNextValidChildIndex(AIndex);
  Result := (ANextIndex > -1) and (MinSizes[AIndex] < OriginalSizes[AIndex] + ADeltaSize) and
    (MinSizes[ANextIndex] < OriginalSizes[ANextIndex] - ADeltaSize);
end;

procedure TdxSideContainerDockSite.DoChildResize(AControl: TdxCustomDockControl;
  ADeltaSize: Integer; AResizeNextControl: Boolean);
var
  I, AIndex, ANextIndex: Integer;
begin
  if ADeltaSize = 0 then
    Exit;
  AIndex := AControl.DockIndex;
  if AResizeNextControl then
    ANextIndex := GetNextValidChildIndex(AIndex)
  else
    ANextIndex := GetPrevValidChildIndex(AIndex);

  if (AIndex > -1) and (ANextIndex > -1) then
  begin
    BeginAdjustBounds;
    try
      if ActiveChild <> nil then
      begin
        for I := 0 to ChildCount - 1 do
          OriginalSizes[I] := Sizes[I];
        ActiveChild := nil;
      end;
      OriginalSizes[AIndex] := OriginalSizes[AIndex] + ADeltaSize;
      OriginalSizes[ANextIndex] := OriginalSizes[ANextIndex] - ADeltaSize;
      if OriginalSizes[AIndex] < MinSizes[AIndex] then
      begin
        ADeltaSize := MinSizes[AIndex] - OriginalSizes[AIndex];
        OriginalSizes[AIndex] := OriginalSizes[AIndex] + ADeltaSize;
        OriginalSizes[ANextIndex] := OriginalSizes[ANextIndex] - ADeltaSize;
      end;
      if OriginalSizes[ANextIndex] < MinSizes[ANextIndex] then
      begin
        ADeltaSize := MinSizes[ANextIndex] - OriginalSizes[ANextIndex];
        OriginalSizes[ANextIndex] := OriginalSizes[ANextIndex] + ADeltaSize;
        OriginalSizes[AIndex] := OriginalSizes[AIndex] - ADeltaSize;
      end;
      Sizes[AIndex] := OriginalSizes[AIndex];
      Sizes[ANextIndex] := OriginalSizes[ANextIndex];
    finally
      EndAdjustBounds;
    end;
  end;
end;

procedure TdxSideContainerDockSite.BeginAdjustBounds;
begin
  Inc(FAdjustBoundsLock);
  inherited;
end;

procedure TdxSideContainerDockSite.EndAdjustBounds;
begin
  inherited;
  Dec(FAdjustBoundsLock);
end;

function TdxSideContainerDockSite.IsAdjustBoundsLocked: Boolean;
begin
  Result := AdjustBoundsLock > 0;
end;

procedure TdxSideContainerDockSite.AdjustChildrenBounds(AControl: TdxCustomDockControl);
var
  I, ADeltaSize: Integer;
  APrevIndex: Integer;
begin
  if IsAdjustBoundsLocked or IsUpdateLayoutLocked and (AControl = nil) then exit;
  BeginAdjustBounds;
  try
    if ActiveChild <> nil then
    begin
      for I := 0 to ActiveChildIndex - 1 do
      begin
        if not IsValidChild(Children[I]) then continue;
        Children[I].SetDockType(GetHeadDockType);
        Sizes[I] := MinSizes[I];
      end;
      for I := ChildCount - 1 downto ActiveChildIndex + 1 do
      begin
        if not IsValidChild(Children[I]) then continue;
        Children[I].SetDockType(GetTailDockType);
        Sizes[I] := MinSizes[I];
      end;
      if IsValidChild(ActiveChild) then ActiveChild.SetDockType(dtClient);
    end
    else if ValidChildCount > 1 then
    begin
      if AControl <> nil then
        ADeltaSize := GetDifferentSize div (ValidChildCount - 1)
      else ADeltaSize := GetDifferentSize div ValidChildCount;
      for I := 0 to ChildCount - 1 do
      begin
        if Children[I] = AControl then continue;
        if not IsValidChild(Children[I]) then continue;
        OriginalSizes[I] := OriginalSizes[I] + ADeltaSize;
        if OriginalSizes[I] < MinSizes[I] then
          OriginalSizes[I] := MinSizes[I];
      end;
      NormalizeChildrenBounds(GetDifferentSize);
      for I := 0 to ChildCount - 1 do
      begin
        if not IsValidChild(Children[I]) then continue;
        Children[I].SetDockType(GetHeadDockType);
        APrevIndex := GetPrevValidChildIndex(I);
        if APrevIndex > -1 then
          Positions[I] := Positions[APrevIndex] + Sizes[APrevIndex];
        Sizes[I] := OriginalSizes[I];
      end;
    end
    else if ValidChildCount > 0 then
    begin
      for I := 0 to ChildCount - 1 do
      begin
        if not IsValidChild(Children[I]) then continue;
        Children[I].SetDockType(dtClient);
      end;
    end;
  finally
    EndAdjustBounds;
  end;
end;

procedure TdxSideContainerDockSite.NormalizeChildrenBounds(ADeltaSize: Integer);
var
  I: Integer;
begin
  for I := 0 to ChildCount - 1 do
  begin
    if not IsValidChild(Children[I]) then continue;
    if ADeltaSize = 0 then break;
    if OriginalSizes[I] > MinSizes[I] then
      if OriginalSizes[I] + ADeltaSize < MinSizes[I] then
      begin
        ADeltaSize := ADeltaSize + (OriginalSizes[I] - MinSizes[I]);
        OriginalSizes[I] := MinSizes[I];
      end
      else
      begin
        OriginalSizes[I] := OriginalSizes[I] + ADeltaSize;
        ADeltaSize := 0;
      end;
  end;
end;

procedure TdxSideContainerDockSite.SetChildBounds(AControl: TdxCustomDockControl;
  var AWidth, AHeight: Integer);
begin
  if (ActiveChild = nil) and not IsAdjustBoundsLocked then
  begin
    OriginalSizes[AControl.DockIndex] := GetDimension(AWidth, AHeight);
    AdjustChildrenBounds(nil);
    SetDimension(AWidth, AHeight, OriginalSizes[AControl.DockIndex]);
  end;
end;

function TdxSideContainerDockSite.IsValidActiveChild(AControl: TdxCustomDockControl): Boolean;
begin
  Result := IsValidChild(AControl) or (AControl = nil);
end;

procedure TdxSideContainerDockSite.ValidateActiveChild(AIndex: Integer);
begin
  if not IsValidChild(ActiveChild) then
  begin
    if (ActiveChild <> nil) and IsValidChild(ActiveChild.Container) then
      ActiveChild := ActiveChild.Container
    else ActiveChild := nil;
  end;
end;

function TdxSideContainerDockSite.HasBorder: Boolean;
begin
  Result := (doSideContainerHasCaption in ControllerOptions) and
    ShowCaption and (FloatDockSite = nil) and (ValidChildCount > 1);
end;

function TdxSideContainerDockSite.HasCaption: Boolean;
begin
  Result := (doSideContainerHasCaption in ControllerOptions) and
    ShowCaption and (FloatDockSite = nil) and ((ValidChildCount > 1) or AutoHide);
end;

function TdxSideContainerDockSite.CanActive: Boolean;
begin
  Result := True;
end;

function TdxSideContainerDockSite.CanAutoHide: Boolean;
begin
  Result := IsLoading or ((AutoHideHostSite <> nil) and
    ((AutoHideControl = nil) or (AutoHideControl = Self)));
end;

function TdxSideContainerDockSite.CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean;
var
  ACanDockHost: Boolean;
begin
  ACanDockHost := CanContainerDockHost(AType);
  if doSideContainerCanInSideContainer in ControllerOptions then
    ACanDockHost := ACanDockHost or (AType in [dtLeft, dtRight, dtTop, dtBottom]);
  if doSideContainerCanInTabContainer in ControllerOptions then
    ACanDockHost := ACanDockHost or (AType in [dtClient]);
  Result := inherited CanDockHost(AControl, AType) and ACanDockHost;;
end;

function TdxSideContainerDockSite.CanMaximize: Boolean;
begin
  Result := not AutoHide and (SideContainer <> nil) and (SideContainer.ValidChildCount > 1);
end;

procedure TdxSideContainerDockSite.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;
  AdjustChildrenBounds(nil);
end;

procedure TdxSideContainerDockSite.UpdateControlDockZones(AControl: TdxCustomDockControl;
  AZoneWidth: Integer);
begin
  if doSideContainerCanInSideContainer in ControllerOptions then
    inherited;
end;

procedure TdxSideContainerDockSite.IncludeToDock(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
var
  AChild: TdxCustomDockControl;
begin
  if AControl.CanAcceptSideContainerItems(Self) and (ChildCount > 0) then
  begin
    Include(FInternalState, dcisDestroying);
    while ChildCount > 0 do
    begin
      AChild := Children[ChildCount - 1];
      AChild.ExcludeFromDock;
      AChild.IncludeToDock(AControl, AType, Index);
      if AControl is TdxSideContainerDockSite then
        (AControl as TdxSideContainerDockSite).AdjustChildrenBounds(AChild);
    end;
    DoDestroy;
  end
  else inherited;
end;

procedure TdxSideContainerDockSite.CreateLayout(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
begin
  if CanContainerDockHost(AType) then
  begin
    AControl.IncludeToDock(Self, AType, Index);
    AdjustChildrenBounds(AControl);
  end
  else if (Container <> nil) and Container.CanContainerDockHost(AType) then
    CreateContainerLayout(Container, AControl, AType, DockIndex)
  else
    case AType of
      dtLeft, dtRight,
      dtTop, dtBottom:
        CreateSideContainerLayout(AControl, AType, Index);
      dtClient:
        CreateTabContainerLayout(AControl, AType, Index);
    else
      Assert(False, Format(sdxInternalErrorCreateLayout, [TdxTabContainerDockSite.ClassName]));
    end;
end;

procedure TdxSideContainerDockSite.UpdateLayout;
begin
  inherited;
  AdjustChildrenBounds(nil);
end;

procedure TdxSideContainerDockSite.LoadLayoutFromCustomIni(AIniFile: TCustomIniFile;
  AParentForm: TCustomForm; AParentControl: TdxCustomDockControl; ASection: string);
begin
  BeginAdjustBounds;
  try
    inherited;
  finally
    EndAdjustBounds;
  end;
end;

function TdxSideContainerDockSite.CanAcceptSideContainerItems(AContainer: TdxSideContainerDockSite): Boolean;
begin
  if (doSideContainerCanInSideContainer in ControllerOptions) or IsLoading then
    Result := AContainer.ClassType = ClassType
  else
    Result := True;
end;

function TdxSideContainerDockSite.CanAcceptTabContainerItems(AContainer: TdxTabContainerDockSite): Boolean;
begin
  if (doTabContainerCanInSideContainer in ControllerOptions) or IsLoading then
    Result := False
  else
    Result := True;
end;

procedure TdxSideContainerDockSite.UpdateCaption;
var
  I: Integer;
  ACaption: string;
begin
  ACaption := '';
  for I := 0 to ChildCount - 1 do
  begin
    if not IsValidChild(Children[I]) then continue;
    ACaption := ACaption + Children[I].Caption;
    if GetNextValidChild(I) <> nil then
      ACaption := ACaption + ', ';
  end;
  if Caption <> ACaption then
    Caption := ACaption;
  inherited UpdateCaption;
end;

procedure TdxSideContainerDockSite.ChangeAutoHide;
begin
  if AutoHide then
    AutoHide := False
  else if doSideContainerCanAutoHide in ControllerOptions then
    inherited ChangeAutoHide
  else if ActiveChild <> nil then
    ActiveChild.ChangeAutoHide
  else if GetFirstValidChild <> nil then
    GetFirstValidChild.ChangeAutoHide
end;

procedure TdxSideContainerDockSite.DoClose;
begin
  if (doSideContainerCanClose in ControllerOptions) then
    inherited DoClose
  else if ActiveChild <> nil then
    ActiveChild.DoClose
  else if GetFirstValidChild <> nil then
    GetFirstValidChild.DoClose;
end;

procedure TdxSideContainerDockSite.ChildVisibilityChanged(Sender: TdxCustomDockControl);
begin
  inherited;
  if IsValidChild(Sender) then
    AdjustChildrenBounds(Sender)
  else if Sender = ActiveChild then
    ValidateActiveChild(Sender.DockIndex);
  NCChanged;
end;

function TdxSideContainerDockSite.GetDifferentSize: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to ChildCount - 1 do
  begin
    if not IsValidChild(Children[I]) then continue;
    Inc(Result, OriginalSizes[I]);
  end;
  Result := GetContainerSize - Result;
end;

{ TdxHorizContainerDockSite }

procedure TdxHorizContainerDockSite.UpdateControlResizeZones(AControl: TdxCustomDockControl);
begin
  inherited;
  if (AControl.SideContainerItem <> nil) and (AControl.SideContainer = Self) then
    if GetNextValidChild(AControl.SideContainerIndex) <> nil then
      AControl.ResizeZones.Insert(0, TdxHorizContainerZone.Create(
        AControl.SideContainerItem, ControllerResizeZonesWidth, zkResizing));
end;

procedure TdxHorizContainerDockSite.UpdateControlOriginalSize(AControl: TdxCustomDockControl);
begin
  if (AControl = Self) or (DockType in [dtTop, dtBottom]) then
    inherited
  else if (DockType = dtClient) and (FloatDockSite <> nil) then
    AControl.FOriginalHeight := FloatDockSite.Height;
end;

class function TdxHorizContainerDockSite.GetHeadDockType: TdxDockingType;
begin
  Result := dtLeft;
end;

class function TdxHorizContainerDockSite.GetTailDockType: TdxDockingType;
begin
  Result := dtRight;
end;

function TdxHorizContainerDockSite.GetContainerSize: Integer;
begin
  if HandleAllocated and (ClientWidth > 0) then
    Result := ClientWidth
  else Result := Width;
end;

function TdxHorizContainerDockSite.GetDimension(AWidth, AHeight: Integer): Integer;
begin
  Result := AWidth;
end;

function TdxHorizContainerDockSite.GetMinSize(Index: Integer): Integer;
begin
  Result := Children[Index].GetMinimizedWidth;
end;

function TdxHorizContainerDockSite.GetOriginalSize(Index: Integer): Integer;
begin
  Result := Children[Index].OriginalWidth;
end;

function TdxHorizContainerDockSite.GetSize(Index: Integer): Integer;
begin
  Result := Children[Index].Width;
end;

function TdxHorizContainerDockSite.GetPosition(Index: Integer): Integer;
begin
  Result := Children[Index].Left;
end;

procedure TdxHorizContainerDockSite.SetDimension(var AWidth, AHeight: Integer; AValue: Integer);
begin
  AWidth := AValue;
end;

procedure TdxHorizContainerDockSite.SetOriginalSize(Index: Integer;
  const Value: Integer);
var
  I: Integer;
begin
  Children[Index].FOriginalWidth := Value;
  if Children[Index] is TdxTabContainerDockSite then
    for I := 0 to Children[Index].ChildCount - 1 do
      Children[Index].Children[I].FOriginalWidth := Value;
end;

procedure TdxHorizContainerDockSite.SetSize(Index: Integer; const Value: Integer);
begin
  Children[Index].Width := Value;
end;

procedure TdxHorizContainerDockSite.SetPosition(Index: Integer; const Value: Integer);
begin
  Children[Index].Left := Value;
end;

{ TdxVertContainerDockSite }

procedure TdxVertContainerDockSite.UpdateControlResizeZones(AControl: TdxCustomDockControl);
begin
  inherited;
  if (AControl.SideContainerItem <> nil) and (AControl.SideContainer = Self) then
    if GetNextValidChild(AControl.SideContainerIndex) <> nil then
      AControl.ResizeZones.Insert(0, TdxVertContainerZone.Create(
        AControl.SideContainerItem, ControllerResizeZonesWidth, zkResizing));
end;

procedure TdxVertContainerDockSite.UpdateControlOriginalSize(AControl: TdxCustomDockControl);
begin
  if (AControl = Self) or (DockType in [dtLeft, dtRight]) then
    inherited
  else if (DockType = dtClient) and (FloatDockSite <> nil) then
    AControl.FOriginalWidth := FloatDockSite.Width;
end;

class function TdxVertContainerDockSite.GetHeadDockType: TdxDockingType;
begin
  Result := dtTop;
end;

class function TdxVertContainerDockSite.GetTailDockType: TdxDockingType;
begin
  Result := dtBottom;
end;

function TdxVertContainerDockSite.GetContainerSize: Integer;
begin
  if HandleAllocated and (ClientHeight > 0) then
    Result := ClientHeight
  else Result := Height;
end;

function TdxVertContainerDockSite.GetDimension(AWidth, AHeight: Integer): Integer;
begin
  Result := AHeight;
end;

function TdxVertContainerDockSite.GetMinSize(Index: Integer): Integer;
begin
  Result := Children[Index].GetMinimizedHeight;
end;

function TdxVertContainerDockSite.GetOriginalSize(Index: Integer): Integer;
begin
  Result := Children[Index].OriginalHeight;
end;

function TdxVertContainerDockSite.GetSize(Index: Integer): Integer;
begin
  Result := Children[Index].Height;
end;

function TdxVertContainerDockSite.GetPosition(Index: Integer): Integer;
begin
  Result := Children[Index].Top;
end;

procedure TdxVertContainerDockSite.SetDimension(var AWidth, AHeight: Integer; AValue: Integer);
begin
  AHeight := AValue;
end;

procedure TdxVertContainerDockSite.SetOriginalSize(Index: Integer;
  const Value: Integer);
var
  I: Integer;
begin
  Children[Index].FOriginalHeight := Value;
  if Children[Index] is TdxTabContainerDockSite then
    for I := 0 to Children[Index].ChildCount - 1 do
      Children[Index].Children[I].FOriginalHeight := Value;
end;

procedure TdxVertContainerDockSite.SetSize(Index: Integer; const Value: Integer);
begin
  Children[Index].Height := Value;
end;

procedure TdxVertContainerDockSite.SetPosition(Index: Integer; const Value: Integer);
begin
  Children[Index].Top := Value;
end;

{ TdxDockSiteAutoHideContainer }

constructor TdxDockSiteAutoHideContainer.Create(AOwner: TComponent);
begin
  inherited;
  Visible := False;
  ControlStyle := [csNoDesignVisible];
end;

procedure TdxDockSiteAutoHideContainer.CMControlListChange(var Message: TMessage);
begin
  if (csDesigning in ComponentState) and not (csLoading in ComponentState) and
    Boolean(Message.LParam) {Inserting} and
    IsControlContainsDockSite(TControl(Message.WParam)) then
    raise EdxException.Create(sdxInvalidDockSiteParent);
  inherited;
end;

procedure TdxDockSiteAutoHideContainer.WMEraseBkgnd(var Message: TWmEraseBkgnd);
begin
  Message.Result := 1;
end;

{ TdxDockSiteHideBar }

constructor TdxDockSiteHideBar.Create(AOwner: TdxDockSite);
begin
  FOwner := AOwner;
  FDockControls := TList.Create;
end;

destructor TdxDockSiteHideBar.Destroy;
begin
  FDockControls.Free;
  inherited;
end;

function TdxDockSiteHideBar.IndexOfDockControl(AControl: TdxCustomDockControl): Integer;
begin
  Result := FDockControls.IndexOf(AControl);
end;

procedure TdxDockSiteHideBar.CreateAutoHideContainer(AControl: TdxCustomDockControl);
var
  AContainer: TdxDockSiteAutoHideContainer;
begin
  AContainer := TdxDockSiteAutoHideContainer.Create(Owner);
  AContainer.Anchors := GetContainersAnchors;
  AContainer.Parent := Owner.Parent;
  AContainer.BringToFront;
  AControl.BeginUpdateLayout;
  try
    AControl.Parent := AContainer;
    AControl.Align := GetControlsAlign;
    AControl.SetVisibility(False);
    AControl.AdjustControlBounds(AControl);
  finally
    AControl.EndUpdateLayout;
  end;
end;

procedure TdxDockSiteHideBar.DestroyAutoHideContainer(AControl: TdxCustomDockControl);
var
  AContainer: TdxDockSiteAutoHideContainer;
begin
  AContainer := AControl.AutoHideContainer;
  if AContainer <> nil then
  begin
    AControl.BeginUpdateLayout;
    try
      AContainer.Perform(WM_SETREDRAW, Integer(False), 0);
//      SendMessage(AContainer.Handle, WM_SETREDRAW, Integer(False), 0);
      AControl.SetVisibility(True);
      AControl.SetParentDockControl(AControl.ParentDockControl);
      AControl.SetDockType(AControl.DockType);
      AControl.AdjustControlBounds(AControl);
    finally
      AControl.EndUpdateLayout;
    end;
    AContainer.Free;
  end;
end;

procedure TdxDockSiteHideBar.RegisterDockControl(AControl: TdxCustomDockControl);
begin
  FDockControls.Add(AControl);
  CreateAutoHideContainer(AControl);
  if DockControlCount = 1 then
    Owner.NCChanged(True);
end;

procedure TdxDockSiteHideBar.UnregisterDockControl(AControl: TdxCustomDockControl);
begin
  DestroyAutoHideContainer(AControl);
  FDockControls.Remove(AControl);
  if DockControlCount = 0 then
    Owner.NCChanged(True);
end;

function TdxDockSiteHideBar.GetButtonWidth(AControl: TdxCustomDockControl): Integer;
var
  I: Integer;
  ATabWidth, AMaxTabWidth: Integer;
  AOffset: Integer;
  ATabContainer: TdxTabContainerDockSite;
begin
  AOffset := 2 * Painter.GetHideBarHorizInterval;
  if AControl is TdxTabContainerDockSite then
  begin
    ATabContainer := AControl as TdxTabContainerDockSite;
    AMaxTabWidth := 0;
    for I := 0 to ATabContainer.ChildCount - 1 do
      if ATabContainer.IsValidChild(ATabContainer.Children[I]) then
      begin
        ATabWidth := Owner.Canvas.TextWidth(ATabContainer.Children[I].Caption);
        if Painter.IsValidImageIndex(ATabContainer.Children[I].ImageIndex) then
          Inc(ATabWidth, GetDefaultImageSize + AOffset);
        AMaxTabWidth := Max(AMaxTabWidth, ATabWidth);
      end;
    Result := AMaxTabWidth + AOffset +
      (GetDefaultImageSize + AOffset) * ((AControl as TdxTabContainerDockSite).ValidChildCount - 1);
  end
  else
  begin
    Result := Owner.Canvas.TextWidth(AControl.Caption) + AOffset;
    if GetImageSize > 0 then
      Result := Result + GetImageSize + AOffset
    else
      Result := Result + Painter.GetHideBarHorizInterval;
  end;
end;

function TdxDockSiteHideBar.GetControlAtPos(pt: TPoint; var SubControl: TdxCustomDockControl): TdxCustomDockControl;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to DockControlCount - 1 do
    if PtInRect(ButtonsRects[I], pt) then
    begin
      Result := DockControls[I];
      if Result is TdxTabContainerDockSite then
        SubControl := GetTabContainerChildAtPos(pt, DockControls[I] as TdxTabContainerDockSite)
      else SubControl := nil;
      break;
    end;
end;

function TdxDockSiteHideBar.GetTabContainerChildAtPos(pt: TPoint;
  TabContainer: TdxTabContainerDockSite): TdxCustomDockControl;
begin
  Result := nil;
end;

function TdxDockSiteHideBar.GetButtonRectCount: Integer;
begin
  Result := Length(FButtonsRects);
end;

function TdxDockSiteHideBar.GetButtonRect(Index: Integer): TRect;
begin
  Result := FButtonsRects[Index];
end;

function TdxDockSiteHideBar.GetDockControl(Index: Integer): TdxCustomDockControl;
begin
  Result := TdxCustomDockControl(FDockControls.Items[Index]);
end;

function TdxDockSiteHideBar.GetDockControlCount: Integer;
begin
  Result := FDockControls.Count;
end;

function TdxDockSiteHideBar.GetPainter: TdxDockControlPainter;
begin
  Result := Owner.Painter;
end;

function TdxDockSiteHideBar.GetVisible: Boolean;
begin
  Result := DockControlCount > 0;
end;

{ TdxDockSiteLeftHideBar }

procedure TdxDockSiteLeftHideBar.Calculate(R: TRect);
begin
  FRect.Left := R.Left;
  FRect.Top := R.Top;
  FRect.Bottom := R.Bottom;
  SetLength(FButtonsRects, DockControlCount);
  if Visible then
  begin
    FRect.Right := FRect.Left + Painter.GetHideBarWidth;
    CalculateButtons(FRect);
  end
  else FRect.Right := FRect.Left;
end;

procedure TdxDockSiteLeftHideBar.CalculateButtons(R: TRect);
var
  I, APos: Integer;
begin
  APos := R.Top + Painter.GetHideBarHorizInterval;
  if Owner.TopHideBar.Visible then
    Inc(APos, Painter.GetHideBarHeight);
  for I := 0 to DockControlCount - 1 do
  begin
    FButtonsRects[I].Top := APos;
    FButtonsRects[I].Bottom := FButtonsRects[I].Top + GetButtonWidth(DockControls[I]);
    FButtonsRects[I].Left := R.Left + Painter.GetHideBarVertInterval;
    FButtonsRects[I].Right := R.Right - Painter.GetHideBarVertInterval;
    APos := FButtonsRects[I].Bottom + Painter.GetHideBarHorizInterval
  end;
end;

function TdxDockSiteLeftHideBar.GetDefaultImageSize: Integer;
begin
  Result := Painter.GetDefaultImageHeight;
end;

function TdxDockSiteLeftHideBar.GetImageSize: Integer;
begin
  Result := Painter.GetImageHeight;
end;

function TdxDockSiteLeftHideBar.GetContainersAnchors: TAnchors;
begin
  Result := [akLeft, akTop, akBottom];
end;

function TdxDockSiteLeftHideBar.GetControlsAlign: TAlign;
begin
  Result := alRight;
end;

function TdxDockSiteLeftHideBar.GetPosition: TdxAutoHidePosition;
begin
  Result := ahpLeft;
end;

function TdxDockSiteLeftHideBar.CheckHidingFinish: Boolean;
begin
  Result := Owner.MovingContainer.Width <= 0;
end;

function TdxDockSiteLeftHideBar.CheckShowingFinish: Boolean;
begin
  Result := Owner.MovingContainer.Width >= Owner.MovingControl.OriginalWidth;
end;

procedure TdxDockSiteLeftHideBar.SetFinalPosition(AControl: TdxCustomDockControl);
begin
  AControl.AutoHideContainer.SetBounds(Owner.GetClientLeft, Owner.GetClientTop,
    AControl.OriginalWidth, Owner.GetClientHeight);
end;

procedure TdxDockSiteLeftHideBar.SetInitialPosition(AControl: TdxCustomDockControl);
begin
  AControl.AutoHideContainer.SetBounds(Owner.GetClientLeft, Owner.GetClientTop,
    0, Owner.GetClientHeight);
end;

procedure TdxDockSiteLeftHideBar.UpdatePosition(ADelta: Integer);
begin
  if (ADelta > 0) and (Owner.MovingContainer.Width + ADelta > Owner.MovingControl.OriginalWidth) then
    SetFinalPosition(Owner.MovingControl)
  else if (ADelta < 0) and (Owner.MovingContainer.Width + ADelta < 0) then
    SetInitialPosition(Owner.MovingControl)
  else Owner.MovingContainer.Width := Owner.MovingContainer.Width + ADelta;
end;

procedure TdxDockSiteLeftHideBar.UpdateOwnerAutoSizeBounds(AControl: TdxCustomDockControl);
var
  AWidth: Integer;
begin
  AWidth := 0;
  if Owner.HasAutoHideControls then
    AWidth := Painter.GetHideBarWidth;
  if not AControl.AutoHide and AControl.Visible then
    AWidth := AControl.OriginalWidth;
  Owner.UpdateAutoSizeBounds(AWidth, AControl.OriginalHeight);
end;

function TdxDockSiteLeftHideBar.GetTabContainerChildAtPos(pt: TPoint;
  TabContainer: TdxTabContainerDockSite): TdxCustomDockControl;
var
  I, Index: Integer;
  ARect, R: TRect;
begin
  Result := nil;
  Index := IndexOfDockControl(TabContainer);
  ARect := ButtonsRects[Index];
  for I := 0 to TabContainer.ActiveChildIndex - 1 do
  begin
    if not TabContainer.IsValidChild(TabContainer.Children[I]) then continue;
    R := ARect;
    R.Bottom := R.Top + (Painter.GetDefaultImageHeight + 2 * Painter.GetHideBarHorizInterval);
    if PtInRect(R, pt) then
    begin
      Result := TabContainer.Children[I];
      break;
    end;
    ARect.Top := R.Bottom;
  end;
  if Result = nil then
    for I := TabContainer.ChildCount - 1 downto TabContainer.ActiveChildIndex + 1 do
    begin
      if not TabContainer.IsValidChild(TabContainer.Children[I]) then continue;
      R := ARect;
      R.Top := R.Bottom - (Painter.GetDefaultImageHeight + 2 * Painter.GetHideBarHorizInterval);
      if PtInRect(R, pt) then
      begin
        Result := TabContainer.Children[I];
        break;
      end;
      ARect.Bottom := R.Top;
    end;
  if Result = nil then
    Result := TabContainer.ActiveChild;
end;

{ TdxDockSiteTopHideBar }

procedure TdxDockSiteTopHideBar.Calculate(R: TRect);
begin
  FRect.Left := R.Left;
  FRect.Top := R.Top;
  FRect.Right := R.Right;
  SetLength(FButtonsRects, DockControlCount);
  if Visible then
  begin
    FRect.Bottom := FRect.Top + Painter.GetHideBarHeight;
    CalculateButtons(FRect);
  end
  else FRect.Bottom := FRect.Top;
end;

procedure TdxDockSiteTopHideBar.CalculateButtons(R: TRect);
var
  I, APos: Integer;
begin
  APos := R.Left + Painter.GetHideBarHorizInterval;
  if Owner.LeftHideBar.Visible then
    Inc(APos, Painter.GetHideBarWidth);
  for I := 0 to DockControlCount - 1 do
  begin
    FButtonsRects[I].Left := APos;
    FButtonsRects[I].Right := FButtonsRects[I].Left + GetButtonWidth(DockControls[I]);
    FButtonsRects[I].Top := R.Top + Painter.GetHideBarVertInterval;
    FButtonsRects[I].Bottom := R.Bottom - Painter.GetHideBarVertInterval;
    APos := FButtonsRects[I].Right + Painter.GetHideBarHorizInterval
  end;
end;

function TdxDockSiteTopHideBar.GetDefaultImageSize: Integer;
begin
  Result := Painter.GetDefaultImageWidth;
end;

function TdxDockSiteTopHideBar.GetImageSize: Integer;
begin
  Result := Painter.GetImageWidth;
end;

function TdxDockSiteTopHideBar.GetContainersAnchors: TAnchors;
begin
  Result := [akTop, akLeft, akRight];
end;

function TdxDockSiteTopHideBar.GetControlsAlign: TAlign;
begin
  Result := alBottom;
end;

function TdxDockSiteTopHideBar.GetPosition: TdxAutoHidePosition;
begin
  Result := ahpTop;
end;

function TdxDockSiteTopHideBar.CheckHidingFinish: Boolean;
begin
  Result := Owner.MovingContainer.Height <= 0;
end;

function TdxDockSiteTopHideBar.CheckShowingFinish: Boolean;
begin
  Result := (Owner.MovingContainer.Height >= Owner.MovingControl.OriginalHeight);
end;

procedure TdxDockSiteTopHideBar.SetFinalPosition(AControl: TdxCustomDockControl);
begin
  AControl.AutoHideContainer.SetBounds(Owner.GetClientLeft, Owner.GetClientTop,
    Owner.GetClientWidth, AControl.OriginalHeight);
end;

procedure TdxDockSiteTopHideBar.SetInitialPosition(AControl: TdxCustomDockControl);
begin
  AControl.AutoHideContainer.SetBounds(Owner.GetClientLeft, Owner.GetClientTop,
    Owner.GetClientWidth, 0);
end;

procedure TdxDockSiteTopHideBar.UpdatePosition(ADelta: Integer);
begin
  if (ADelta > 0) and (Owner.MovingContainer.Height + ADelta > Owner.MovingControl.OriginalHeight) then
    SetFinalPosition(Owner.MovingControl)
  else if (ADelta < 0) and (Owner.MovingContainer.Height + ADelta < 0) then
    SetInitialPosition(Owner.MovingControl)
  else Owner.MovingContainer.Height := Owner.MovingContainer.Height + ADelta;
end;

procedure TdxDockSiteTopHideBar.UpdateOwnerAutoSizeBounds(AControl: TdxCustomDockControl);
var
  AHeight: Integer;
begin
  AHeight := 0;
  if Owner.HasAutoHideControls then
    AHeight := Painter.GetHideBarWidth;
  if not AControl.AutoHide and AControl.Visible then
    AHeight := AControl.OriginalHeight;
  Owner.UpdateAutoSizeBounds(AControl.OriginalWidth, AHeight);
end;

function TdxDockSiteTopHideBar.GetTabContainerChildAtPos(pt: TPoint;
  TabContainer: TdxTabContainerDockSite): TdxCustomDockControl;
var
  I, Index: Integer;
  ARect, R: TRect;
begin
  Result := nil;
  Index := IndexOfDockControl(TabContainer);
  ARect := ButtonsRects[Index];
  for I := 0 to TabContainer.ActiveChildIndex - 1 do
  begin
    if not TabContainer.IsValidChild(TabContainer.Children[I]) then continue;
    R := ARect;
    R.Right := R.Left + (Painter.GetDefaultImageWidth + 2 * Painter.GetHideBarHorizInterval);
    if PtInRect(R, pt) then
    begin
      Result := TabContainer.Children[I];
      break;
    end;
    ARect.Left := R.Right;
  end;
  if Result = nil then
    for I := TabContainer.ChildCount - 1 downto TabContainer.ActiveChildIndex + 1 do
    begin
      if not TabContainer.IsValidChild(TabContainer.Children[I]) then continue;
      R := ARect;
      R.Left := R.Right - (Painter.GetDefaultImageWidth + 2 * Painter.GetHideBarHorizInterval);
      if PtInRect(R, pt) then
      begin
        Result := TabContainer.Children[I];
        break;
      end;
      ARect.Right := R.Left;
    end;
  if Result = nil then
    Result := TabContainer.ActiveChild;
end;

{ TdxDockSiteRightHideBar }

procedure TdxDockSiteRightHideBar.Calculate(R: TRect);
begin
  FRect.Right := R.Right;
  FRect.Top := R.Top;
  FRect.Bottom := R.Bottom;
  SetLength(FButtonsRects, DockControlCount);
  if Visible then
  begin
    FRect.Left := FRect.Right - Painter.GetHideBarWidth;
    CalculateButtons(FRect);
  end
  else FRect.Left := FRect.Right;
end;

function TdxDockSiteRightHideBar.GetContainersAnchors: TAnchors;
begin
  Result := [akRight, akTop, akBottom];
end;

function TdxDockSiteRightHideBar.GetControlsAlign: TAlign;
begin
  Result := alLeft;
end;

function TdxDockSiteRightHideBar.GetPosition: TdxAutoHidePosition;
begin
  Result := ahpRight;
end;

procedure TdxDockSiteRightHideBar.SetFinalPosition(AControl: TdxCustomDockControl);
begin
  AControl.AutoHideContainer.SetBounds(Owner.GetClientLeft + Owner.GetClientWidth - AControl.OriginalWidth,
    Owner.GetClientTop, AControl.OriginalWidth, Owner.GetClientHeight);
end;

procedure TdxDockSiteRightHideBar.SetInitialPosition(AControl: TdxCustomDockControl);
begin
  AControl.AutoHideContainer.SetBounds(Owner.GetClientLeft + Owner.GetClientWidth,
    Owner.GetClientTop, 0, Owner.GetClientHeight);
end;

procedure TdxDockSiteRightHideBar.UpdatePosition(ADelta: Integer);
begin
  if (ADelta > 0) and (Owner.MovingContainer.Width + ADelta > Owner.MovingControl.OriginalWidth) then
    SetFinalPosition(Owner.MovingControl)
  else if (ADelta < 0) and (Owner.MovingContainer.Width + ADelta < 0) then
    SetInitialPosition(Owner.MovingControl)
  else Owner.MovingContainer.SetBounds(Owner.MovingContainer.Left - ADelta, Owner.MovingContainer.Top,
    Owner.MovingContainer.Width + ADelta, Owner.MovingContainer.Height);
end;

{ TdxDockSiteBottomHideBar }

procedure TdxDockSiteBottomHideBar.Calculate(R: TRect);
begin
  FRect.Left := R.Left;
  FRect.Bottom := R.Bottom;
  FRect.Right := R.Right;
  SetLength(FButtonsRects, DockControlCount);
  if Visible then
  begin
    FRect.Top := FRect.Bottom - Painter.GetHideBarHeight;
    CalculateButtons(FRect);
  end
  else FRect.Top := FRect.Bottom;
end;

function TdxDockSiteBottomHideBar.GetContainersAnchors: TAnchors;
begin
  Result := [akBottom, akLeft, akRight];
end;

function TdxDockSiteBottomHideBar.GetControlsAlign: TAlign;
begin
  Result := alTop;
end;

function TdxDockSiteBottomHideBar.GetPosition: TdxAutoHidePosition;
begin
  Result := ahpBottom;
end;

procedure TdxDockSiteBottomHideBar.SetFinalPosition(AControl: TdxCustomDockControl);
begin
  AControl.AutoHideContainer.SetBounds(Owner.GetClientLeft,
    Owner.GetClientTop + Owner.GetClientHeight - AControl.OriginalHeight,
    Owner.GetClientWidth, AControl.OriginalHeight);
end;

procedure TdxDockSiteBottomHideBar.SetInitialPosition(AControl: TdxCustomDockControl);
begin
  AControl.AutoHideContainer.SetBounds(Owner.GetClientLeft, Owner.GetClientTop + Owner.GetClientHeight,
    Owner.GetClientWidth, 0);
end;

procedure TdxDockSiteBottomHideBar.UpdatePosition(ADelta: Integer);
begin
  if (ADelta > 0) and (Owner.MovingContainer.Height + ADelta > Owner.MovingControl.OriginalHeight) then
    SetFinalPosition(Owner.MovingControl)
  else if (ADelta < 0) and (Owner.MovingContainer.Height + ADelta < 0) then
    SetInitialPosition(Owner.MovingControl)
  else Owner.MovingContainer.SetBounds(Owner.MovingContainer.Left, Owner.MovingContainer.Top - ADelta,
    Owner.MovingContainer.Width, Owner.MovingContainer.Height + ADelta);
end;

{ TdxDockSite }

constructor TdxDockSite.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHideBars := TList.Create;
  CreateHideBars;
  FHidingTimerID := -1;
  FMovingTimerID := -1;
  FShowingTimerID := -1;
  UseDoubleBuffer := True;
  UpdateDockZones;
end;

destructor TdxDockSite.Destroy;
begin
  DestroyHideBars;
  FHideBars.Free;
  inherited;
end;

function TdxDockSite.GetHideBarByControl(AControl: TdxCustomDockControl): TdxDockSiteHideBar;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to HideBarCount - 1 do
    if (HideBars[I].IndexOfDockControl(AControl) > -1) then
    begin
      Result := HideBars[I];
      Break;
    end;
end;

function TdxDockSite.GetHideBarByPosition(APosition: TdxAutoHidePosition): TdxDockSiteHideBar;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to HideBarCount - 1 do
    if (HideBars[I].Position = APosition) then
    begin
      Result := HideBars[I];
      Break;
    end;
end;

procedure TdxDockSite.CreateHideBars;
begin
  FHideBars.Add(TdxDockSiteTopHideBar.Create(Self));
  FHideBars.Add(TdxDockSiteBottomHideBar.Create(Self));
  FHideBars.Add(TdxDockSiteLeftHideBar.Create(Self));
  FHideBars.Add(TdxDockSiteRightHideBar.Create(Self));
end;

procedure TdxDockSite.DestroyHideBars;
var
  I: Integer;
  AHideBar: TdxDockSiteHideBar;
begin
  if FHideBars = nil then exit;
  for I := 0 to FHideBars.Count - 1 do
  begin
    AHideBar := TdxDockSiteHideBar(FHideBars[I]);
    AHideBar.Free;
  end;
  FHideBars.Clear;
end;

function TdxDockSite.CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean;
begin
  Result := inherited CanDockHost(AControl, AType);
  Result := Result and ((AType in [dtLeft, dtRight, dtTop, dtBottom]) or
    ((Atype in [dtClient]) and (ChildCount = 0)));
  Result := Result and (not AutoSize or ((AutoSizeClientControl = nil) and (AType = dtClient)));
end;

function TdxDockSite.GetPositionByControl(AControl: TdxCustomDockControl): TdxAutoHidePosition;
var
  AHideBar: TdxDockSiteHideBar;
begin
  AHideBar := GetHideBarByControl(AControl);
  if AHideBar <> nil then
    Result := AHideBar.Position
  else
    Result := ahpLeft;
end;

function TdxDockSite.HasAutoHideControls: Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to HideBarCount - 1 do
    if HideBars[I].DockControlCount > 0 then
    begin
      Result := True;
      Break;
    end;
end;

function TdxDockSite.GetControlAtPos(pt: TPoint; var SubControl: TdxCustomDockControl): TdxCustomDockControl;
var
  I: Integer;
begin
  Result := nil;
  pt := ClientToWindow(pt);
  for I := 0 to HideBarCount - 1 do
  begin
    Result := HideBars[I].GetControlAtPos(pt, SubControl);
    if Result <> nil then
      Break;
  end;
end;

function TdxDockSite.GetHideBarAtPos(pt: TPoint): TdxDockSiteHideBar;
var
  I: Integer;
begin
  Result := nil;
  pt := ClientToWindow(pt);
  for I := 0 to HideBarCount - 1 do
    if HideBars[I].Visible and ptInRect(HideBars[I].Rect, pt) then
    begin
      Result := HideBars[I];
      Break;
    end;
end;

function TdxDockSite.GetControlAutoHidePosition(AControl: TdxCustomDockControl): TdxAutoHidePosition;
begin
  if AutoSize then
  begin
    case Align of
      alTop: Result := ahpTop;
      alBottom: Result := ahpBottom;
      alLeft: Result := ahpLeft;
      alRight: Result := ahpRight;
    else
      if AControl.Width > AControl.Height then
        Result := ahpTop
      else
        Result := ahpLeft;
    end;
  end
  else
    Result := inherited GetControlAutoHidePosition(AControl);
end;

procedure TdxDockSite.RegisterAutoHideDockControl(AControl: TdxCustomDockControl;
  APosition: TdxAutoHidePosition);
var
  AHideBar: TdxDockSiteHideBar;
begin
  NCChanged;
  ImmediatelyHide;
  AHideBar := GetHideBarByPosition(APosition);
  if AHideBar <> nil then
  begin
    AControl.FAutoHidePosition := APosition;
    FMovingControlHideBar := AHideBar;
    FMovingControl := AControl;
    try
      AHideBar.RegisterDockControl(AControl);
      if Controller.ActiveDockControl = AControl then
        Controller.ActiveDockControl := nil;
    finally
      FMovingControl := nil;
      FMovingControlHideBar := nil;
    end;
  end;
end;

procedure TdxDockSite.UnregisterAutoHideDockControl(AControl: TdxCustomDockControl);
var
  AHideBar: TdxDockSiteHideBar;
begin
  NCChanged;
  ImmediatelyHide(True);
  AHideBar := GetHideBarByControl(AControl);
  if AHideBar <> nil then
  begin
    FMovingControlHideBar := AHideBar;
    FMovingControl := AControl;
    Assert(MovingContainer <> nil, sdxInternalErrorAutoHide);
    try
      AHideBar.UnregisterDockControl(AControl);
      if WorkingControl = AControl then
        WorkingControl := nil;
    finally
      FMovingControl := nil;
      FMovingControlHideBar := nil;
    end;
    AControl.FAutoHidePosition := ahpUndefined;;
  end;
end;

procedure TdxDockSite.AdjustAutoSizeBounds;
begin
  if IsDestroying or not AutoSize or (Align = alClient) then exit;
  if ChildCount > 0 then
    SetSize(FAutoSizeWidth, FAutoSizeHeight)
  else
    SetSize(FOriginalWidth, FOriginalHeight);
  BringToFront;
end;

function TdxDockSite.CanAutoSizeChange: Boolean;
begin
  Result := FAutoSize or (ChildCount = 0) or IsLoading; // childCount = 1 TODO: !!!
end;

procedure TdxDockSite.CheckAutoSizeBounds;
var
  AContainer: TdxContainerDockSite;
begin
  // TODO: Is Simple + GetContainer
  if AutoSize and (ChildCount = 2) and (ValidChildCount = 0) then
  begin
    if Children[0] is TdxContainerDockSite then
      AContainer := Children[0] as TdxContainerDockSite
    else
      if Children[1] is TdxContainerDockSite then
        AContainer := Children[1] as TdxContainerDockSite 
      else
        AContainer := nil; // error!
    ChildVisibilityChanged(AContainer);
  end;
end;

function TdxDockSite.GetAutoSizeClientControl: TdxCustomDockControl;
begin
  if AutoSize and (ChildCount > 1) and Children[0].CanDock then
    Result := Children[0]
  else
    if AutoSize and (ChildCount > 1) and Children[1].CanDock then
      Result := Children[1]
    else
      Result := nil;
end;

procedure TdxDockSite.UpdateAutoSizeBounds(AWidth, AHeight: Integer);
begin                          
  if not AutoSize then Exit;
  FAutoSizeHeight := AHeight;
  FAutoSizeWidth := AWidth;
end;

procedure TdxDockSite.DoHideControl(AControl: TdxCustomDockControl);
begin
  if Assigned(FOnHideControl) then
    FOnHideControl(Self, AControl);
end;

procedure TdxDockSite.DoShowControl(AControl: TdxCustomDockControl);
begin
  if Assigned(FOnShowControl) then
    FOnShowControl(Self, AControl);
end;

procedure ShowMovementTimerProc(Wnd: HWnd; Msg, TimerID, SysTime: Longint); stdcall;
var
  AControl: TdxDockSite;
begin
  AControl := TdxDockSite(FindControl(Wnd));
  if AControl <> nil then
    AControl.DoShowMovement;
end;

procedure TdxDockSite.DoShowMovement;
begin
  MovingControlHideBar.UpdatePosition(ControllerAutoHideMovingSize);
  if MovingControlHideBar.CheckShowingFinish then
  begin
    if FMovingTimerID > -1 then
    begin
      KillTimer(Handle, FMovingTimerID);
      FMovingTimerID := -1;
    end;
    FMovingControlHideBar := nil;
    FShowingControl := FMovingControl;
    FMovingControl := nil;
    InitializeHiding;
  end
  else
    if FMovingTimerID < 0 then
      FMovingTimerID := SetTimer(Handle, 1, ControllerAutoHideMovingInterval, @ShowMovementTimerProc);
end;

procedure HideMovementTimerProc(Wnd: HWnd; Msg, TimerID, SysTime: Longint); stdcall;
var
  AControl: TdxDockSite;
begin
  AControl := TdxDockSite(FindControl(Wnd));
  if AControl <> nil then
    AControl.DoHideMovement;
end;

procedure TdxDockSite.DoHideMovement;
begin
  MovingControlHideBar.UpdatePosition(-ControllerAutoHideMovingSize);
  if MovingControlHideBar.CheckHidingFinish then
  begin
    DoHideControl(FMovingControl);
    if FMovingTimerID > -1 then
    begin
      KillTimer(Handle, FMovingTimerID);
      FMovingTimerID := -1;
    end;
    Assert(MovingContainer <> nil, sdxInternalErrorAutoHide);
    MovingContainer.Visible := False;
    MovingControl.SetVisibility(False);
    FMovingControlHideBar := nil;
    WorkingControl := nil;
    FMovingControl := nil;
    FShowingControl := nil;
    FinalizeHiding;
  end
  else
    if FMovingTimerID < 0 then
      FMovingTimerID := SetTimer(Handle, 1, ControllerAutoHideMovingInterval, @HideMovementTimerProc);
end;

procedure TdxDockSite.ImmediatelyHide(AFinalizing: Boolean = False);
begin
  if ShowingControl <> nil then
  begin
    DoHideControl(ShowingControl);
    if not AFinalizing then
      ShowingControl.AutoHideContainer.Visible := False;
    ShowingControl.SetVisibility(False);
    if (Controller.ActiveDockControl = ShowingControl) and
      (Controller.ActiveDockControl <> Controller.FActivatingDockControl) then
      Controller.ActiveDockControl := nil;
    FShowingControl := nil;
    FinalizeHiding;
  end;
  WorkingControl := nil;
  FMovingControl := nil;
  FMovingControlHideBar := nil;
  if FMovingTimerID > -1 then
  begin
    KillTimer(Handle, FMovingTimerID);
    FMovingTimerID := -1;
  end;
end;

procedure TdxDockSite.ImmediatelyShow(AControl: TdxCustomDockControl);
var
  AHideBar: TdxDockSiteHideBar;
begin
  if MovingControl <> nil then exit;
  if ShowingControl <> AControl then
  begin
    ImmediatelyHide;
    AHideBar := GetHideBarByControl(AControl);
    if AHideBar <> nil then
    begin
      WorkingControl := AControl;
      FShowingControl := AControl;
      AHideBar.SetFinalPosition(AControl);
      AControl.AutoHideContainer.Visible := True;
      AControl.SetVisibility(True);
      AControl.AutoHideContainer.BringToFront;
      DoShowControl(AControl);
      InitializeHiding;
    end;
  end;
end;

procedure AutoHideTimerProc(Wnd: HWnd; Msg, TimerID, SysTime: Longint); stdcall;
var
  AControl: TdxDockSite;
begin
  AControl := TdxDockSite(FindControl(Wnd));
  if (AControl <> nil) and (AControl.ShowingControl <> nil) then
    AControl.FinalizeHiding
  else
    KillTimer(Wnd, TimerID);
end;

procedure TdxDockSite.InitializeHiding;
begin
  if FHidingTimerID > -1 then
  begin
    KillTimer(Handle, FHidingTimerID);
    FHidingTimerID := -1;
  end;
  if not IsDestroying and (FHidingTimerID = -1) and (ShowingControl <> nil) then
    FHidingTimerID := SetTimer(Handle, 2, ControllerAutoHideInterval, @AutoHideTimerProc)
end;

procedure AutoShowTimerProc(Wnd: HWnd; Msg, TimerID, SysTime: Longint); stdcall;
var
  AControl: TdxDockSite;
begin
  AControl := TdxDockSite(FindControl(Wnd));
  if AControl <> nil then
    AControl.FinalizeShowing
  else
    KillTimer(Wnd, TimerID);
end;

procedure TdxDockSite.InitializeShowing;
begin
  if not IsDestroying and (FShowingTimerID = -1) then
    FShowingTimerID := SetTimer(Handle, 3, ControllerAutoShowInterval, @AutoShowTimerProc)
end;

procedure TdxDockSite.FinalizeHiding;
var
  pt: TPoint;
  AControl: TdxCustomDockControl;
begin
  if Controller.IsDocking or Controller.IsResizing then Exit;
  if MovingControl <> nil then Exit;
  if ShowingControl <> nil then
  begin
    GetCursorPos(pt);
    AControl := Controller.GetDockControlAtPos(pt);
    if
      not (((AControl = Self) and (GetHideBarAtPos(ScreenToClient(pt)) <> nil)) or
        ((AControl <> nil) and (AControl.AutoHideControl = ShowingControl)) or
        (not (doHideAutoHideIfActive in ControllerOptions) and (Controller.ActiveDockControl <> nil) and
        (Controller.ActiveDockControl.AutoHideControl = ShowingControl))) then
      ShowingControl := nil;
  end
  else
    if FHidingTimerID > -1 then
    begin
      KillTimer(Handle, FHidingTimerID);
      FHidingTimerID := -1;
    end;
end;

procedure TdxDockSite.FinalizeShowing;
var
  pt: TPoint;
  AControl, ASubControl: TdxCustomDockControl;
begin
  if FShowingTimerID > -1 then
  begin
    KillTimer(Handle, FShowingTimerID);
    FShowingTimerID := -1;
  end;
  GetCursorPos(pt);
  ASubControl := nil;
  AControl := GetControlAtPos(ScreenToClient(pt), ASubControl);
  if (FShowingControlCandidate <> nil) and (FShowingControlCandidate = AControl) and not (disContextMenu in Controller.FInternalState) then
  begin
    if (ASubControl <> nil) and (AControl is TdxTabContainerDockSite) then
    begin
      if ASubControl <> (AControl as TdxTabContainerDockSite).ActiveChild then
      begin
        ImmediatelyHide;
        (AControl as TdxTabContainerDockSite).ActiveChild := ASubControl;
      end;
      ShowingControl := AControl;
    end
    else
      if (AControl <> nil) then
        ShowingControl := AControl;
  end;
end;

procedure TdxDockSite.SetFinalPosition(AControl: TdxCustomDockControl);
var
  AHideBar: TdxDockSiteHideBar;
begin
  AHideBar := GetHideBarByControl(AControl);
  if AHideBar <> nil then
    AHideBar.SetFinalPosition(AControl);
end;

procedure TdxDockSite.SetInitialPosition(AControl: TdxCustomDockControl);
var
  AHideBar: TdxDockSiteHideBar;
begin
  AHideBar := GetHideBarByControl(AControl);
  if AHideBar <> nil then
    AHideBar.SetInitialPosition(AControl);
end;

function TdxDockSite.GetClientLeft: Integer;
begin
  Result := ClientOrigin.X - Parent.ClientOrigin.X;
end;

function TdxDockSite.GetClientTop: Integer;
begin
  Result := ClientOrigin.Y - Parent.ClientOrigin.Y;
end;

function TdxDockSite.GetClientWidth: Integer;
begin
  Result := ClientWidth;
end;

function TdxDockSite.GetClientHeight: Integer;
begin
  Result := ClientHeight;
end;

function TdxDockSite.GetDesignHitTest(const APoint: TPoint; AShift: TShiftState): Boolean;
begin
  Result := inherited GetDesignHitTest(APoint, AShift) or
    (GetHideBarAtPos(APoint) <> nil);
end;

procedure TdxDockSite.Loaded;
begin
  inherited;
  CheckAutoSizeBounds;
  UpdateDockZones;
end;

procedure TdxDockSite.ReadState(Reader: TReader);
begin
  inherited;
  UpdateLayout;
end;

procedure TdxDockSite.SetAutoSize(Value: Boolean);
begin
  if (FAutoSize <> Value) and CanAutoSizeChange then
  begin
    FAutoSize := Value;
    if not IsLoading then
    begin
      AdjustAutoSizeBounds;
      UpdateLayout;
    end;
  end;
end;

procedure TdxDockSite.SetParent(AParent: TWinControl);
begin
  if IsDesigning and not IsLoading and ParentIsDockControl(AParent) then
    raise EdxException.Create(sdxInvalidDockSiteParent)
  else
    inherited SetParent(AParent);
end;

procedure TdxDockSite.ValidateInsert(AComponent: TComponent);
begin
  if not ((AComponent is TdxCustomDockControl) or (AComponent is TdxDockSiteAutoHideContainer)) then
  begin
    if AComponent is TControl then
      (AComponent as TControl).Parent := ParentForm;
    raise EdxException.CreateFmt(sdxInvalidSiteChild, [AComponent.ClassName]);
  end;
end;

procedure TdxDockSite.UpdateControlResizeZones(AControl: TdxCustomDockControl);
begin
  if AutoSize and (AControl <> Self) then
  begin
    if TdxAutoSizeRightZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxAutoSizeRightZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxAutoSizeLeftZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxAutoSizeLeftZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxAutoSizeBottomZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxAutoSizeBottomZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
    if TdxAutoSizeTopZone.ValidateResizeZone(Self, AControl) then
      AControl.ResizeZones.Insert(0, TdxAutoSizeTopZone.Create(Self, ControllerResizeZonesWidth, zkResizing));
  end
  else
    inherited UpdateControlResizeZones(AControl);
end;

procedure TdxDockSite.UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer);
begin
  if AutoSize then
  begin
    if TdxAutoSizeClientZone.ValidateDockZone(Self, AControl) then
      AControl.DockZones.Insert(0, TdxAutoSizeClientZone.Create(Self, AZoneWidth))
    else
      if TdxInvisibleAutoSizeClientZone.ValidateDockZone(Self, AControl) then
        AControl.DockZones.Insert(0, TdxInvisibleAutoSizeClientZone.Create(Self, AZoneWidth));
  end
  else
  begin
    if TdxClientZone.ValidateDockZone(Self, AControl) then
      AControl.DockZones.Insert(0, TdxClientZone.Create(Self, AZoneWidth))
    else
      if TdxInvisibleClientZone.ValidateDockZone(Self, AControl) then
        AControl.DockZones.Insert(0, TdxInvisibleClientZone.Create(Self, AZoneWidth));
    inherited;
  end;
end;

procedure TdxDockSite.CreateLayout(AControl: TdxCustomDockControl; AType: TdxDockingType;
  Index: Integer);
var
  AWidth, AHeight: Integer;
begin
  AWidth := AControl.OriginalWidth;
  AHeight := AControl.OriginalHeight;
  inherited;
  UpdateAutoSizeBounds(AWidth, AHeight);
  AdjustAutoSizeBounds;
end;

procedure TdxDockSite.DestroyLayout(AControl: TdxCustomDockControl);
begin
  inherited;
  AdjustAutoSizeBounds;
end;

procedure TdxDockSite.LoadLayoutFromCustomIni(AIniFile: TCustomIniFile;
  AParentForm: TCustomForm; AParentControl: TdxCustomDockControl; ASection: string);
var
  I, AChildCount: Integer;
  AChildSection: string;
  ADockTypes: TdxDockingTypes;
  AWidth, AHeight: Integer;
begin
  BeginUpdateLayout;
  try
    with AIniFile do
    begin
      ADockTypes := [];
      if ReadBool(ASection, 'AllowDockClientsLeft', dtLeft in AllowDockClients) then
        ADockTypes := ADockTypes + [dtLeft];
      if ReadBool(ASection, 'AllowDockClientsTop', dtTop in AllowDockClients) then
        ADockTypes := ADockTypes + [dtTop];
      if ReadBool(ASection, 'AllowDockClientsRight', dtRight in AllowDockClients) then
        ADockTypes := ADockTypes + [dtRight];
      if ReadBool(ASection, 'AllowDockClientsBottom', dtBottom in AllowDockClients) then
        ADockTypes := ADockTypes + [dtBottom];
      if ReadBool(ASection, 'AllowDockClientsClient', dtClient in AllowDockClients) then
        ADockTypes := ADockTypes + [dtClient];
      AllowDockClients := ADockTypes;
      Visible := ReadBool(ASection, 'Visible', Visible);
      AChildCount := ReadInteger(ASection, 'ChildCount', 0);
      for I := 0 to AChildCount - 1 do
      begin
        AChildSection := ReadString(ASection, 'Children' + IntToStr(I), '');
        Controller.LoadControlFromCustomIni(AIniFile, AParentForm, Self, AChildSection);
      end;
      AWidth := ReadInteger(ASection, 'Width', Width);
      AHeight := ReadInteger(ASection, 'Height', Height);
      SetSize(AWidth, AHeight);
      FOriginalWidth := ReadInteger(ASection, 'OriginalWidth', OriginalWidth);
      FOriginalHeight := ReadInteger(ASection, 'OriginalHeight', OriginalHeight);
      FAutoSize := ReadBool(ASection, 'AutoSize', AutoSize);
      // TODO: !!!
      AdjustAutoSizeBounds;
    end;
  finally
    EndUpdateLayout;
  end;
end;

procedure TdxDockSite.SaveLayoutToCustomIni(AIniFile: TCustomIniFile; ASection: string);
var
  I: Integer;
begin
  with AIniFile do
  begin
    WriteInteger(ASection, 'ChildCount', ChildCount);
    for I := 0 to ChildCount - 1 do
      WriteString(ASection, 'Children' + IntToStr(I), IntToStr(Controller.IndexOfDockControl(Children[I])));
    WriteBool(ASection, 'AllowDockClientsLeft', dtLeft in AllowDockClients);
    WriteBool(ASection, 'AllowDockClientsTop', dtTop in AllowDockClients);
    WriteBool(ASection, 'AllowDockClientsRight', dtRight in AllowDockClients);
    WriteBool(ASection, 'AllowDockClientsBottom', dtBottom in AllowDockClients);
    WriteBool(ASection, 'AllowDockClientsClient', dtClient in AllowDockClients);
    WriteInteger(ASection, 'Width', Width);
    WriteInteger(ASection, 'Height', Height);
    WriteInteger(ASection, 'OriginalWidth', OriginalWidth);
    WriteInteger(ASection, 'OriginalHeight', OriginalHeight);
    WriteBool(ASection, 'Visible', Visible);
    WriteBool(ASection, 'AutoSize', AutoSize);
  end;
  for I := 0 to ChildCount - 1 do
    Controller.SaveControlToCustomIni(AIniFile, Children[I]);
end;

procedure TdxDockSite.ChildVisibilityChanged(Sender: TdxCustomDockControl);
var
  AHideBar: TdxDockSiteHideBar;
begin
  // TODO: !!!
  if AutoSize and (AutoSizeClientControl = Sender) then
  begin
    if Sender.Visible and not HasAutoHideControls then
      UpdateAutoSizeBounds(Sender.OriginalWidth, Sender.OriginalHeight)
    else
      if not Sender.Visible and not HasAutoHideControls then
        UpdateAutoSizeBounds(FOriginalWidth, FOriginalHeight)
      else
        if HasAutoHideControls then
        begin
          AHideBar := GetHideBarByPosition(GetControlAutoHidePosition(Sender));
          if AHideBar <> nil then
            AHideBar.UpdateOwnerAutoSizeBounds(Sender);
        end;
    AdjustAutoSizeBounds;
  end;
end;

procedure TdxDockSite.UpdateControlOriginalSize(AControl: TdxCustomDockControl);
begin
  if not AutoSize and (AControl <> Self) then
    inherited
  else
    if (AControl <> Self) and (AControl.UpdateVisibilityLock = 0) and
      not AControl.IsUpdateLayoutLocked then
    begin
      case Align of
        alLeft, alRight:
          AControl.FOriginalWidth := Width;
        alTop, alBottom:
          AControl.FOriginalHeight := Height;
      end;
    end
    else
      if not AutoSize or (ChildCount = 0) then
      begin
        AControl.FOriginalWidth := Width;
        AControl.FOriginalHeight := Height;
      end;
end;

procedure TdxDockSite.CalculateNC(var ARect: TRect);
var
  I: Integer;
begin
  inherited;
  for I := 0 to HideBarCount - 1 do
    HideBars[I].Calculate(ARect);

  ARect.Left := ARect.Left + (LeftHideBar.Rect.Right - LeftHideBar.Rect.Left);
  ARect.Right := ARect.Right - (RightHideBar.Rect.Right - RightHideBar.Rect.Left);
  ARect.Top := ARect.Top + (TopHideBar.Rect.Bottom - TopHideBar.Rect.Top);
  ARect.Bottom := ARect.Bottom - (BottomHideBar.Rect.Bottom - BottomHideBar.Rect.Top);
end;

procedure TdxDockSite.NCPaint(ACanvas: TCanvas);
var
  I, J: Integer;
begin
  for I := 0 to HideBarCount - 1 do
    if HideBars[I].Visible then
    begin
      Painter.DrawHideBar(ACanvas, HideBars[I].Rect, HideBars[I].Position);
      for J := 0 to HideBars[I].ButtonRectCount - 1 do
        Painter.DrawHideBarButton(ACanvas, HideBars[I].DockControls[J],
          HideBars[I].ButtonsRects[J], HideBars[I].Position);
    end;
end;

procedure TdxDockSite.Recalculate;
begin
  CheckAutoSizeBounds;
  inherited;
end;

function TdxDockSite.GetHideBarCount: Integer;
begin
  Result := FHideBars.Count;
end;

function TdxDockSite.GetHideBar(Index: Integer): TdxDockSiteHideBar;
begin
  if (0 <= Index) and (Index < FHideBars.Count) then
    Result := TdxDockSiteHideBar(FHideBars[Index])
  else
    Result := nil;
end;

function TdxDockSite.GetMovingContainer: TdxDockSiteAutoHideContainer;
begin
  if FMovingControl <> nil then
    Result := FMovingControl.AutoHideContainer
  else
    Result := nil;
end;

procedure TdxDockSite.SetWorkingControl(AValue: TdxCustomDockControl);
begin
  if AValue <> FWorkingControl then
  begin
    FWorkingControl := AValue;
    if Painter.IsHideBarButtonHotTrackSupports then
      InvalidateNC(False);
  end;
end;

procedure TdxDockSite.SetShowingControl(Value: TdxCustomDockControl);
var
  AHideBar: TdxDockSiteHideBar;
begin
  if (FShowingControl <> Value) and (MovingControl = nil) then
  begin
    if Value <> nil then
    begin
      ImmediatelyHide;
      AHideBar := GetHideBarByControl(Value);
      if AHideBar <> nil then
      begin
        FMovingControlHideBar := AHideBar;
        FMovingControl := Value;
        WorkingControl := Value;
        Assert(MovingContainer <> nil, sdxInternalErrorAutoHide);
        MovingControlHideBar.SetInitialPosition(Value);
        MovingContainer.Visible := True;
        MovingControl.SetVisibility(True);
        MovingContainer.BringToFront;
        DoShowControl(Value);
        DoShowMovement;
      end;
    end
    else
    begin
      AHideBar := GetHideBarByControl(FShowingControl);
      if AHideBar <> nil then
      begin
        FMovingControlHideBar := AHideBar;
        FMovingControl := FShowingControl;
        WorkingControl := FShowingControl; 
        Assert(MovingContainer <> nil, sdxInternalErrorAutoHide);
        DoHideMovement;
      end;
    end;
  end;
end;

procedure TdxDockSite.CMControlListChange(var Message: TMessage);
begin
  if IsDesigning and not IsLoading and Boolean(Message.LParam) {Inserting} and
    IsControlContainsDockSite(TControl(Message.WParam)) then
    raise EdxException.Create(sdxInvalidDockSiteParent);
  inherited;
end;

procedure TdxDockSite.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if ShowingControl <> nil then InitializeHiding;
end;

procedure TdxDockSite.WMLButtonDown(var Message: TWMLButtonDown);
var
  AControl, ASubControl: TdxCustomDockControl;
begin
  inherited;
  if Message.Result = 0 then
  begin
    AControl := GetControlAtPos(SourcePoint, ASubControl);
    if AControl <> nil then
    begin
      Controller.ActiveDockControl := AControl;
      Controller.FActivatingDockControl := AControl;
      Message.Result := 1;
    end;
  end
end;

procedure TdxDockSite.WMMouseMove(var Message: TWMMouseMove);
var
  ASubControl: TdxCustomDockControl;
begin
  inherited;
  if (Message.Result = 0) and (ParentFormActive or IsDesigning) then
  begin
    FShowingControlCandidate := GetControlAtPos(CursorPoint, ASubControl);
    if FShowingControlCandidate <> nil then
      InitializeShowing;
    Message.Result := 1;
  end;
end;

{ TdxFloatDockSite }

constructor TdxFloatDockSite.Create(AOwner: TComponent);
begin
  inherited;
  CreateFloatForm;
end;

destructor TdxFloatDockSite.Destroy;
begin
  DestroyFloatForm;
  inherited;
end;

procedure TdxFloatDockSite.BeforeDestruction;
begin
  if not CanDestroy then
    raise EdxException.Create(sdxInvalidFloatSiteDeleting);
  inherited;
end;

procedure TdxFloatDockSite.HideFloatForm;
begin
  if FloatForm <> nil then
  begin
    FloatForm.Hide;
    FloatForm.SetDesigning(False);
  end;
end;

procedure TdxFloatDockSite.ShowFloatForm;
begin                                        
  if (FloatForm <> nil) and Visible and (ParentFormVisible or IsDesigning) then
  begin
    FloatForm.Show;
    FloatForm.SetDesigning(IsDesigning);
    FFloatLeft := FloatForm.Left;
    FFloatTop := FloatForm.Top;
  end;
end;

procedure TdxFloatDockSite.SetFloatFormPosition(ALeft, ATop: Integer);
var
  R: TRect;
begin
  if FloatForm = nil then Exit;
  // check work area
  R := GetDesktopWorkArea(Point(ALeft, ATop));
  if ALeft < R.Left then ALeft := R.Left;
  if ALeft >= R.Right then ALeft := R.Right - FloatForm.Width;
  if ATop < R.Top then ATop := R.Top;
  if ATop >= R.Bottom then ATop := R.Bottom - FloatForm.Height;
  FloatForm.SetBounds(ALeft, ATop, FloatForm.Width, FloatForm.Height);
end;

procedure TdxFloatDockSite.SetFloatFormSize(AWidth, AHeight: Integer);
begin
  if FloatForm = nil then exit;
  if FloatForm.HandleAllocated then
  begin
    FloatForm.ClientWidth := AWidth;
    FloatForm.ClientHeight := AHeight;
  end
  else
  begin
    FloatForm.FClientHeight := AHeight;
    FloatForm.FClientWidth := AWidth;
  end;  
end;

function TdxFloatDockSite.HasParent: Boolean;
begin
  Result := False;
end;

procedure TdxFloatDockSite.Loaded;
begin
  inherited;
  CreateFloatForm;
  UpdateCaption;
  ShowFloatForm;

  if IsDesigning and IsLoadingFromForm then // Anchors bug - see TdxFloatForm.InsertDockSite
    SetDockType(dtClient);

  SetFloatFormSize(OriginalWidth, OriginalHeight);
end;

function TdxFloatDockSite.GetDesignRect: TRect;
begin
  Result := cxNullRect;
end;

procedure TdxFloatDockSite.SetParent(AParent: TWinControl);
begin
  if not IsUpdateLayoutLocked and not IsDestroying and
    ((AParent = nil) or not (csLoading in AParent.ComponentState)) then
    raise EdxException.Create(sdxInvalidParentAssigning)
  else if (AParent <> nil) and not (AParent is TCustomForm) then
    raise EdxException.Create(sdxInvalidFloatSiteParent)
  else inherited SetParent(AParent);
end;

function TdxFloatDockSite.IsLoadingFromForm: Boolean;
begin
  Result := csLoading in Owner.ComponentState; // Anchors bug - see TdxFloatForm.InsertDockSite
end;

function TdxFloatDockSite.CanUndock(AControl: TdxCustomDockControl): Boolean;
begin
  Result := ValidChildCount > 1;
end;

procedure TdxFloatDockSite.StartDocking(pt: TPoint);
begin
  if Child <> nil then
    Child.StartDocking(pt);
end;

procedure TdxFloatDockSite.CheckDockClientsRules;
begin
end;

procedure TdxFloatDockSite.UpdateControlDockZones(AControl: TdxCustomDockControl; AZoneWidth: Integer);
begin
  if doUseCaptionAreaToClientDocking in ControllerOptions then
    if TdxFloatZone.ValidateDockZone(Self, AControl) then
      AControl.DockZones.Insert(0, TdxFloatZone.Create(Self));
end;

procedure TdxFloatDockSite.AdjustControlBounds(AControl: TdxCustomDockControl);
begin
  if FloatForm <> nil then
    SetFloatFormSize(AControl.OriginalWidth, AControl.OriginalHeight)
  else inherited;
end;

procedure TdxFloatDockSite.UpdateControlOriginalSize(AControl: TdxCustomDockControl);
begin
  if not FloatFormVisible then exit;
  AControl.FOriginalHeight := Height;
  AControl.FOriginalWidth := Width;
end;

procedure TdxFloatDockSite.UpdateFloatPosition;
begin
  if FloatFormVisible then
  begin
    FFloatLeft := FloatForm.Left;
    FFloatTop := FloatForm.Top;
    Modified;
  end;
end;

procedure TdxFloatDockSite.ChildVisibilityChanged(Sender: TdxCustomDockControl);
begin
  if Sender = Child then
  begin
    Visible := Sender.Visible;
    FloatForm.Visible := Sender.Visible and ParentFormVisible;
  end;
end;

procedure TdxFloatDockSite.Activate;
begin
  if GetDockPanel <> nil then
    GetDockPanel.Activate
  else
  begin // old code
    if Child <> nil then
      Child.Activate;
  end;    
end;

procedure TdxFloatDockSite.DoClose;
begin
  if Child <> nil then
    Child.DoClose;
end;

function TdxFloatDockSite.CanDestroy: Boolean;
begin
  Result := (Child = nil) or Child.IsDestroying;
end;

function TdxFloatDockSite.CanDockHost(AControl: TdxCustomDockControl; AType: TdxDockingType): Boolean;
begin
  Result := False;
end;

function TdxFloatDockSite.GetDockPanel: TdxCustomDockControl;
begin
  Result := Child;
  if not (Result is TdxDockPanel) then
  begin
    if Result is TdxSideContainerDockSite then
    begin
      if (Result as TdxSideContainerDockSite).ActiveChild <> nil then
        Result := (Result as TdxSideContainerDockSite).ActiveChild
      else
        if (Result as TdxSideContainerDockSite).ValidChildCount > 0 then
          Result := (Result as TdxSideContainerDockSite).ValidChildren[0]
        else
          Result := nil; 
    end
    else
    begin
      if Result is TdxContainerDockSite then
        Result := (Result as TdxContainerDockSite).ActiveChild
      else
        Result := nil;
    end;
  end;
end;

procedure TdxFloatDockSite.CreateLayout(AControl: TdxCustomDockControl;
  AType: TdxDockingType; Index: Integer);
begin
  Assert(ChildCount = 0, Format(sdxInternalErrorCreateLayout, [ClassName]));
  AControl.IncludeToDock(Self, AType, 0);
end;

procedure TdxFloatDockSite.DestroyLayout(AControl: TdxCustomDockControl);
begin
  Assert(ChildCount = 1, Format(sdxInternalErrorDestroyLayout, [ClassName]));
  Include(FInternalState, dcisDestroying);
  AControl.ExcludeFromDock;
  if not IsDestroying then DoDestroy;
end;

procedure TdxFloatDockSite.LoadLayoutFromCustomIni(AIniFile: TCustomIniFile;
  AParentForm: TCustomForm; AParentControl: TdxCustomDockControl; ASection: string);
begin
  inherited;
  with AIniFile do
  begin
    FloatLeft := ReadInteger(ASection, 'FloatLeft', FloatLeft);
    FloatTop := ReadInteger(ASection, 'FloatTop', FloatTop);
    FOriginalWidth := ReadInteger(ASection, 'Width', Width);
    FOriginalHeight := ReadInteger(ASection, 'Height', Height);
  end;
  CreateFloatForm;
  UpdateCaption;
  ShowFloatForm;
  SetFloatFormSize(OriginalWidth, OriginalHeight);
  // To fix bad layouts
  if ChildCount <> 1 then DoDestroy;
end;

procedure TdxFloatDockSite.SaveLayoutToCustomIni(AIniFile: TCustomIniFile;
  ASection: string);
begin
  inherited;
  with AIniFile do
  begin
    WriteInteger(ASection, 'FloatLeft', FloatLeft);
    WriteInteger(ASection, 'FloatTop', FloatTop);
  end;
end;

procedure TdxFloatDockSite.DoSetFloatFormCaption;
begin
  if Assigned(FOnSetFloatFormCaption) then
    FOnSetFloatFormCaption(Self, FloatForm);
  Controller.DoSetFloatFormCaption(Self, FloatForm);
end;

procedure TdxFloatDockSite.UpdateCaption;
begin
  if (Child <> nil) and (FloatForm <> nil) then
    FloatForm.Caption := Child.Caption;
  DoSetFloatFormCaption;
end;

function TdxFloatDockSite.GetFloatForm: TdxFloatForm;
begin
  Result := FFloatForm;
end;

procedure TdxFloatDockSite.RestoreDockPosition(pt: TPoint);
begin
  if (Child <> nil) and Child.Dockable then
    Child.RestoreDockPosition(pt);
end;

function TdxFloatDockSite.GetFloatFormClass: TdxFloatFormClass;
begin
  Result := TdxFloatForm;
end;

procedure TdxFloatDockSite.CreateFloatForm;
var
  AWidth, AHeight: Integer;
begin
  BeginUpdateLayout;
  try
    AWidth := OriginalWidth;
    AHeight := OriginalHeight;
    if FFloatForm = nil then
      FFloatForm := GetFloatFormClass.Create(Application);
    FFloatForm.InsertDockSite(Self);
    SetFloatFormPosition(FloatLeft, FloatTop);
    SetFloatFormSize(AWidth, AHeight);
    if (doFloatingOnTop in ControllerOptions) or IsDesigning then
      FFloatForm.BringToFront(True);
  finally
    EndUpdateLayout;
  end;
end;

procedure TdxFloatDockSite.DestroyFloatForm;
begin
  if FFloatForm = nil then exit;
  BeginUpdateLayout;
  try
    if not FFloatForm.IsDestroying then
      FFloatForm.Free;
  finally
    EndUpdateLayout;
  end;
end;

function TdxFloatDockSite.GetChild: TdxCustomDockControl;
begin
  if ChildCount = 1 then
    Result := Children[0]
  else
    Result := nil;
end;

function TdxFloatDockSite.GetFloatLeft: Integer;
begin
  if FloatForm <> nil then
    Result := FloatForm.Left
  else
    Result := FFloatLeft;
end;

function TdxFloatDockSite.GetFloatTop: Integer;
begin
  if FloatForm <> nil then
    Result := FloatForm.Top
  else
    Result := FFloatTop;
end;

function TdxFloatDockSite.GetFloatWidth: Integer;
begin
  if FloatForm <> nil then
  begin
    if FloatForm.HandleAllocated then
      Result := FloatForm.ClientWidth
    else
      Result := FloatForm.FClientWidth;
  end
  else Result := FFloatWidth;
end;

function TdxFloatDockSite.GetFloatHeight: Integer;
begin
  if FloatForm <> nil then
  begin
    if FloatForm.HandleAllocated then
      Result := FloatForm.ClientHeight
    else
      Result := FloatForm.FClientHeight;
  end
  else
    Result := FFloatHeight;
end;

procedure TdxFloatDockSite.SetFloatLeft(const Value: Integer);
begin
  FFloatLeft := Value;
  if FloatForm <> nil then
    FloatForm.Left := Value;
end;

procedure TdxFloatDockSite.SetFloatTop(const Value: Integer);
begin
  FFloatTop := Value;
  if FloatForm <> nil then
    FloatForm.Top := Value;
end;

procedure TdxFloatDockSite.SetFloatWidth(const Value: Integer);
begin
  FFloatWidth := Value;
  SetFloatFormSize(Value, FloatHeight);
end;

procedure TdxFloatDockSite.SetFloatHeight(const Value: Integer);
begin
  FFloatHeight := Value;
  SetFloatFormSize(FloatWidth, Value);
end;

procedure TdxFloatDockSite.WMNCHitTest(var Message: TWMNCHitTest);
begin
  Message.Result := HTTRANSPARENT;
end;

{ TdxFloatForm }

constructor TdxFloatForm.Create(AOwner: TComponent);
begin
  CreateNew(AOwner);
{$IFDEF DELPHI9}
  Position := poDesigned;
  PopupMode := pmExplicit;
{$ENDIF}
  FClientHeight := -1;
  FClientWidth := -1;
  AutoScroll := False;
  BorderStyle := bsSizeToolWin;
  DefaultMonitor := dmDesktop;
  Visible := False;
end;

destructor TdxFloatForm.Destroy;
begin
  RemoveDockSite;
  inherited;
end;

procedure TdxFloatForm.InsertDockSite(ADockSite: TdxFloatDockSite);
begin
  FDockSite := ADockSite;
  if not (FDockSite.IsDesigning and FDockSite.IsLoadingFromForm) then // Anchors bug - see TdxFloatDockSite.Loaded
    FDockSite.SetDockType(dtClient);
  FDockSite.Parent := Self;
  FCanDesigning := True;
end;

procedure TdxFloatForm.RemoveDockSite;
begin
  FCanDesigning := False;
  if FDockSite <> nil then
  begin
    FDockSite.Parent := nil;
    FDockSite.FFloatForm := nil;
    FDockSite := nil;
  end;
end;

procedure TdxFloatForm.BringToFront(ATopMost: Boolean);
begin
  if FOnTopMost <> ATopMost then
  begin
    FOnTopMost := ATopMost;
    RecreateWnd;
  end;
end;

function TdxFloatForm.CanDesigning: Boolean;
begin
  Result := FCanDesigning and IsDesigning and not IsDestroying and
    (ParentForm <> nil) and (ParentForm.Designer <> nil) and
    not dxDockingController.IsDocking;
end;

function TdxFloatForm.IsDesigning: Boolean;
begin
  Result := csDesigning in ComponentState;
end;

function TdxFloatForm.IsDestroying: Boolean;
begin
  Result := csDestroying in ComponentState;
end;

procedure TdxFloatForm.CreateParams(var Params: TCreateParams);
begin
{$IFDEF DELPHI9}
  PopupParent := ParentForm;
{$ENDIF}
  inherited CreateParams(Params);
  with Params do
    if FOnTopMost then
    begin
      Style := Style or WS_POPUPWINDOW;
      WndParent := ParentForm.Handle;
    end
    else
    begin
    {$IFDEF DELPHI11}
      if Application.MainFormOnTaskBar and (ParentForm <> Application.MainForm) then
        WndParent := Application.MainFormHandle
      else
    {$ENDIF}
        WndParent := Application.Handle;
    end;
end;

procedure TdxFloatForm.CreateWnd;
begin
  inherited;
  if (FClientWidth <> -1) and (FClientHeight <> -1) then
  begin
    ClientWidth := FClientWidth;
    ClientHeight := FClientHeight;
    FClientWidth := -1;
    FClientHeight := -1;
  end;
end;

function TdxFloatForm.IsShortCut(var Message: TWMKey): Boolean;
begin
  Result := inherited IsShortCut(Message);
  if not Result and (ParentForm <> nil) then
    Result := ParentForm.IsShortCut(Message);
end;

procedure TdxFloatForm.ShowWindow;
begin
  if not Visible then
    Show
  else
    Windows.ShowWindow(Handle, SW_SHOWNA);
end;

procedure TdxFloatForm.HideWindow;
begin
  if HandleAllocated then
    Windows.ShowWindow(Handle, SW_HIDE);
end;

{$IFDEF DELPHI6}
procedure TdxFloatForm.WndProc(var Message: TMessage);
var
  ADesigner: IDesignerHook;
begin
  if IsDesigning then
  begin
    if Designer <> nil then
      ADesigner := Designer
    else if CanDesigning then
      ADesigner := ParentForm.Designer
    else ADesigner := nil;
    if Designer <> nil then
      Designer := nil;
    inherited WndProc(Message);
    if (ADesigner <> nil) and CanDesigning then
      Designer := ADesigner;
  end
  else inherited WndProc(Message);
end;
{$ENDIF}

function TdxFloatForm.GetParentForm: TCustomForm;
begin
  if (FDockSite <> nil) and not FDockSite.IsDestroying then
    Result := FDockSite.ParentForm
  else Result := nil;
end;

procedure TdxFloatForm.WMClose(var Message: TWMClose);
begin
  if (DockSite <> nil) and not DockSite.IsDesigning then
    DockSite.DoClose;
end;

procedure TdxFloatForm.WMMove(var Message: TWMMove);
begin
  inherited;
  if DockSite <> nil then
    DockSite.UpdateFloatPosition;
end;

procedure TdxFloatForm.WMSize(var Message: TWMSize);
begin
  inherited;
  if DockSite <> nil then
    DockSite.Modified;
end;

procedure TdxFloatForm.WMMouseActivate(var Message: TWMMouseActivate);
begin
  inherited;
  if DockSite <> nil then
    DockSite.Activate;
end;

procedure TdxFloatForm.WMNCLButtonDown(var Message: TWMNCLButtonDown);
begin
  if (Message.HitTest = HTCAPTION) and not IsIconic(Handle) and (DockSite <> nil) then
  begin
    SendMessage(DockSite.Handle, WM_MOUSEACTIVATE, 0, 0);
    SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE);
    SendMessage(Handle, WM_NCLBUTTONUP, TMessage(Message).WParam, TMessage(Message).LParam);
    FCaptionIsDown := True;
    FCaptionPoint := Point(Message.XCursor, Message.YCursor);
  end
  else inherited;
end;

procedure TdxFloatForm.WMNCLButtonUp(var Message: TWMNCLButtonUp);
begin
  FCaptionIsDown := False;
  inherited;
end;

procedure TdxFloatForm.WMNCLButtonDblClk(var Message: TWMNCMButtonDblClk);
begin
  if not IsDesigning and (Message.HitTest = HTCAPTION) and not IsIconic(Handle) and
    (DockSite <> nil) then DockSite.RestoreDockPosition(Point(Message.XCursor, Message.YCursor))
  else
    inherited;
end;

procedure TdxFloatForm.WMNCMouseMove(var Message: TWMNCMouseMove);
begin
  if FCaptionIsDown and ((FCaptionPoint.X <> Message.XCursor) or
    (FCaptionPoint.Y <> Message.YCursor)) then
  begin
    FCaptionIsDown := False;
    DockSite.StartDocking(Point(Message.XCursor, Message.YCursor));
  end
  else inherited;
end;

{ TdxDockControlPainter }

constructor TdxDockControlPainter.Create(ADockControl: TdxCustomDockControl);
begin
  FDockControl := ADockControl;
end;

function TdxDockControlPainter.CanVerticalCaption: Boolean;
begin
  Result := True;
end;

procedure TdxDockControlPainter.CorrectTabRect(var ATab: TRect;
  APosition: TdxTabContainerTabsPosition; AIsActive: Boolean);
begin
end;

function TdxDockControlPainter.DrawActiveTabLast: Boolean;
begin
  Result := False;
end;

function TdxDockControlPainter.GetBorderWidths: TRect;
begin
  Result := Rect(2, 2, 2, 2);
end;

function TdxDockControlPainter.GetCaptionButtonSize: Integer;
begin
  Result := 12;
end;

function TdxDockControlPainter.GetCaptionHeight: Integer;
begin
  Result := 16;
end;

function TdxDockControlPainter.GetCaptionHorizInterval: Integer;
begin
  Result := 2;
end;

function TdxDockControlPainter.GetCaptionVertInterval: Integer;
begin
  Result := 2;
end;

function TdxDockControlPainter.GetDefaultImageHeight: Integer;
begin
  if DockControl.Images <> nil then
    Result := DockControl.Images.Height
  else Result := dxDefaultImageHeight;
end;

function TdxDockControlPainter.GetDefaultImageWidth: Integer;
begin
  if DockControl.Images <> nil then
    Result := DockControl.Images.Width
  else Result := dxDefaultImageWidth;
end;

function TdxDockControlPainter.GetImageHeight: Integer;
begin
  if DockControl.Images <> nil then
    Result := DockControl.Images.Height
  else Result := 0;
end;

function TdxDockControlPainter.GetImageWidth: Integer;
begin
  if DockControl.Images <> nil then
    Result := DockControl.Images.Width
  else Result := 0;
end;

function TdxDockControlPainter.IsValidImageIndex(AIndex: Integer): Boolean;
begin
  Result := IsImageAssigned(DockControl.Images, AIndex);
end;

function TdxDockControlPainter.GetHideBarHeight: Integer;
begin
  Result := 10 + GetFont.Size + 10;
  if Result < GetHideBarVertInterval + 2 + GetImageHeight + 2 + GetHideBarVertInterval then
    Result := GetHideBarVertInterval + 2 + GetImageHeight + 2 + GetHideBarVertInterval;
end;

function TdxDockControlPainter.GetHideBarWidth: Integer;
begin
  Result := 10 + GetFont.Size + 10;
  if Result < GetHideBarVertInterval + 2 + GetImageWidth + 2 + GetHideBarVertInterval then
    Result := GetHideBarVertInterval + 2 + GetImageWidth + 2 + GetHideBarVertInterval;
end;

function TdxDockControlPainter.GetHideBarVertInterval: Integer;
begin
  Result := 2;
end;

function TdxDockControlPainter.GetHideBarHorizInterval: Integer;
begin
  Result := 4;
end;

function TdxDockControlPainter.GetTabVertInterval: Integer;
begin
  Result := 2;
end;

function TdxDockControlPainter.GetTabVertOffset: Integer;
begin
  Result := 0;
end;

function TdxDockControlPainter.GetTabHorizInterval: Integer;
begin
  Result := 4;
end;

function TdxDockControlPainter.GetTabHorizOffset: Integer;
begin
  Result := GetTabHorizInterval;
end;

function TdxDockControlPainter.GetTabsButtonSize: Integer;
begin
  Result := 16;
end;

function TdxDockControlPainter.GetTabsHeight: Integer;
begin
  Result := 10 + GetFont.Size + 12;
  if Result < GetTabVertInterval + 4 + GetImageHeight + 4 + GetTabVertInterval then
    Result := GetTabVertInterval + 4 + GetImageHeight + 4 + GetTabVertInterval;
end;

procedure TdxDockControlPainter.DrawBorder(ACanvas: TCanvas; ARect: TRect);
var
  ABorders: TRect;
begin
  ACanvas.Brush.Color := ColorToRGB(GetBorderColor);
  ACanvas.Brush.Style := bsSolid;
  with ARect do
  begin
    ABorders := GetBorderWidths;
    ACanvas.FillRect(Rect(Left, Top, Left + ABorders.Left, Bottom));
    ACanvas.FillRect(Rect(Left, Bottom - ABorders.Bottom, Right, Bottom));
    ACanvas.FillRect(Rect(Right - ABorders.Right, Top, Left + Right, Bottom));
    ACanvas.FillRect(Rect(Left, Top, Right, Top + ABorders.Top));
  end;
  DrawColorEdge(ACanvas, ARect, GetColor, etRaisedOuter, [epTopLeft]);
  DrawColorEdge(ACanvas, ARect, GetColor, etRaisedInner, [epBottomRight]);
end;

procedure TdxDockControlPainter.DrawHideBar(ACanvas: TCanvas; ARect: TRect;
  APosition: TdxAutoHidePosition);
begin
  ACanvas.Brush.Color := ColorToRGB(GetHideBarColor);
  ACanvas.Brush.Style := bsSolid;
  ACanvas.FillRect(ARect);
end;

procedure TdxDockControlPainter.DrawCaption(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean);
begin
  ACanvas.Brush.Color := ColorToRGB(GetCaptionColor(IsActive));
  ACanvas.Brush.Style := bsSolid;
  ACanvas.FillRect(ARect);
end;

procedure TdxDockControlPainter.DrawCaptionSeparator(ACanvas: TCanvas; ARect: TRect);
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := ColorToRGB(GetBorderColor);
  ACanvas.FillRect(ARect);
end;

procedure TdxDockControlPainter.DrawCaptionText(ACanvas: TCanvas; ARect: TRect; IsActive: Boolean);
var
  R: TRect;
begin
  R := ARect;
  if DockControl.IsCaptionVertical then
  begin
    if ARect.Top < ARect.Bottom then
    begin
      R.Right := ARect.Left + (ARect.Right - ARect.Left) div 2 - 1;
      R.Left := R.Right - 3;
      DrawColorEdge(ACanvas, R, GetCaptionColor(IsActive), etRaisedOuter, [epTopLeft]);
      DrawColorEdge(ACanvas, R, GetCaptionColor(IsActive), etRaisedInner, [epBottomRight]);
      R.Left := ARect.Left + (ARect.Right - ARect.Left) div 2;
      R.Right := R.Left + 3;
      DrawColorEdge(ACanvas, R, GetCaptionColor(IsActive), etRaisedOuter, [epTopLeft]);
      DrawColorEdge(ACanvas, R, GetCaptionColor(IsActive), etRaisedInner, [epBottomRight]);
    end;
  end
  else
  begin
    if ARect.Left < ARect.Right then
    begin
      R.Bottom := ARect.Top + (ARect.Bottom - ARect.Top) div 2 - 1;
      R.Top := R.Bottom - 3;
      DrawColorEdge(ACanvas, R, GetCaptionColor(IsActive), etRaisedOuter, [epTopLeft]);
      DrawColorEdge(ACanvas, R, GetCaptionColor(IsActive), etRaisedInner, [epBottomRight]);
      R.Top := ARect.Top + (ARect.Bottom - ARect.Top) div 2;
      R.Bottom := R.Top + 3;
      DrawColorEdge(ACanvas, R, GetCaptionColor(IsActive), etRaisedOuter, [epTopLeft]);
      DrawColorEdge(ACanvas, R, GetCaptionColor(IsActive), etRaisedInner, [epBottomRight]);
    end;
  end;
end;

procedure TdxDockControlPainter.DrawCaptionButtonSelection(ACanvas: TCanvas; ARect: TRect;
  IsActive, IsDown, IsHot: Boolean);
begin
  if IsDown and IsHot then
  begin
    DrawColorEdge(ACanvas, ARect, GetCaptionColor(IsActive), etSunkenOuter, [epRect]);
    InflateRect(ARect, -1, -1);
    DrawColorEdge(ACanvas, ARect, GetCaptionColor(IsActive), etSunkenInner, [epTopLeft]);
  end
  else
  begin
    DrawColorEdge(ACanvas, ARect, GetCaptionColor(IsActive), etRaisedOuter, [epRect]);
    InflateRect(ARect, -1, -1);
    DrawColorEdge(ACanvas, ARect, GetCaptionColor(IsActive), etRaisedInner, [epBottomRight]);
  end;
end;

procedure TdxDockControlPainter.DrawCaptionCloseButton(ACanvas: TCanvas; ARect: TRect;
  IsActive, IsDown, IsHot, IsSwitched: Boolean);
begin
  DrawCaptionButtonSelection(ACanvas, ARect, IsActive, IsDown, IsHot);

  if IsDown and IsHot then OffsetRect(ARect, 1, 1);
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));
  ACanvas.MoveTo(ARect.Left + 2, ARect.Top + 2);
  ACanvas.LineTo(ARect.Right - 3, ARect.Bottom - 3);
  ACanvas.MoveTo(ARect.Right - 4, ARect.Top + 2);
  ACanvas.LineTo(ARect.Left + 1, ARect.Bottom - 3);
end;

procedure TdxDockControlPainter.DrawCaptionHideButton(ACanvas: TCanvas; ARect: TRect;
  IsActive, IsDown, IsHot, IsSwitched: Boolean);
begin
  DrawCaptionButtonSelection(ACanvas, ARect, IsActive, IsDown, IsHot);

  if IsDown and IsHot then OffsetRect(ARect, 1, 1);
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));
  if IsSwitched then
  begin
    ACanvas.Rectangle(ARect.Left + 4, ARect.Top + 3, ARect.Right - 3, ARect.Bottom - 4);
    ACanvas.MoveTo(ARect.Left + 4, ARect.Top + 2);
    ACanvas.LineTo(ARect.Left + 4, ARect.Bottom - 3);
    ACanvas.MoveTo(ARect.Left + 4, ARect.Bottom - 6);
    ACanvas.LineTo(ARect.Right - 3, ARect.Bottom - 6);
    ACanvas.MoveTo(ARect.Left + 2, ARect.Top + 5);
    ACanvas.LineTo(ARect.Left + 4, ARect.Top + 5);
  end
  else
  begin
    ACanvas.Rectangle(ARect.Left + 3, ARect.Top + 2, ARect.Right - 4, ARect.Bottom - 5);
    ACanvas.MoveTo(ARect.Left + 2, ARect.Bottom - 6);
    ACanvas.LineTo(ARect.Right - 3, ARect.Bottom - 6);
    ACanvas.MoveTo(ARect.Right - 6, ARect.Top + 2);
    ACanvas.LineTo(ARect.Right - 6, ARect.Bottom - 5);
    ACanvas.MoveTo(ARect.Left + 5, ARect.Bottom - 5);
    ACanvas.LineTo(ARect.Left + 5, ARect.Bottom - 3);
  end;
end;

procedure TdxDockControlPainter.DrawCaptionMaximizeButton(ACanvas: TCanvas; ARect: TRect;
  IsActive, IsDown, IsHot, IsSwitched: Boolean);
var
  pts: array[0..2] of TPoint;
begin
  DrawCaptionButtonSelection(ACanvas, ARect, IsActive, IsDown, IsHot);

  if IsDown and IsHot then OffsetRect(ARect, 1, 1);
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.Pen.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := ColorToRGB(GetCaptionSignColor(IsActive, IsDown, IsHot));
  if DockControl.SideContainer is TdxVertContainerDockSite then
    if IsSwitched then
    begin
      pts[0] := Point(ARect.Right - 4, ARect.Top + 2);
      pts[1] := Point(ARect.Left + 2, ARect.Top + 2);
    end
    else
    begin
      pts[0] := Point(ARect.Right - 4, ARect.Bottom - 4);
      pts[1] := Point(ARect.Left + 2, ARect.Bottom - 4);
    end
  else
    if IsSwitched then
    begin
      pts[0] := Point(ARect.Left + 2, ARect.Top + 2);
      pts[1] := Point(ARect.Left + 2, ARect.Bottom - 4);
    end
    else
    begin
      pts[0] := Point(ARect.Right - 4, ARect.Top + 2);
      pts[1] := Point(ARect.Right - 4, ARect.Bottom - 4);
    end;
  pts[2] := Point(ARect.Left + 5, ARect.Top + 5);
  ACanvas.Polygon(pts);
end;

procedure TdxDockControlPainter.DrawClient(ACanvas: TCanvas; ARect: TRect);
begin
  ACanvas.Brush.Color := ColorToRGB(GetColor);
  ACanvas.Brush.Style := bsSolid;
  ACanvas.FillRect(ARect);
end;

procedure TdxDockControlPainter.DrawHideBarButtonContent(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; APosition: TdxAutoHidePosition);
var
  I: Integer;
  R: TRect;
  AItemControl: TdxCustomDockControl;
const
  SeparatorEdges: array[TdxAutoHidePosition] of TdxEdgePositions = ([epBottom],
    [epRight], [epBottom], [epRight], []);
begin
  if AControl is TdxTabContainerDockSite then
  begin
    for I := 0 to (AControl as TdxTabContainerDockSite).ActiveChildIndex - 1 do
    begin
      AItemControl := AControl.Children[I];
      if not (AControl as TdxTabContainerDockSite).IsValidChild(AItemControl) then continue;
      R := ARect;
      if not (APosition in [ahpLeft, ahpRight]) then
        R.Right := R.Left + (GetDefaultImageWidth + 2 * GetHideBarHorizInterval)
      else R.Bottom := R.Top + (GetDefaultImageHeight + 2 * GetHideBarHorizInterval);
      if IsValidImageIndex(AItemControl.ImageIndex) then
        DrawHideBarButtonImage(ACanvas, AItemControl, R)
      else DrawHideBarButtonText(ACanvas, AItemControl, R, APosition);
      if not (APosition in [ahpLeft, ahpRight]) then
        ARect.Left := R.Right
      else ARect.Top := R.Bottom;
      if (AControl as TdxTabContainerDockSite).GetNextValidChild(AItemControl.DockIndex) <> nil then
        DrawColorEdge(ACanvas, R, GetHideBarButtonColor, etRaisedInner, SeparatorEdges[APosition]);
    end;
    for I := AControl.ChildCount - 1 downto (AControl as TdxTabContainerDockSite).ActiveChildIndex + 1 do
    begin
      AItemControl := AControl.Children[I];
      if not (AControl as TdxTabContainerDockSite).IsValidChild(AItemControl) then continue;
      R := ARect;
      if not (APosition in [ahpLeft, ahpRight]) then
        R.Left := R.Right - (GetDefaultImageWidth + 2 * GetHideBarHorizInterval)
      else R.Top := R.Bottom - (GetDefaultImageHeight + 2 * GetHideBarHorizInterval);
      if IsValidImageIndex(AItemControl.ImageIndex) then
        DrawHideBarButtonImage(ACanvas, AItemControl, R)
      else DrawHideBarButtonText(ACanvas, AItemControl, R, APosition);
      if not (APosition in [ahpLeft, ahpRight]) then
        ARect.Right := R.Left
      else ARect.Bottom := R.Top;
      if (AControl as TdxTabContainerDockSite).GetNextValidChild(AItemControl.DockIndex) <> nil then
        DrawColorEdge(ACanvas, R, GetHideBarButtonColor, etRaisedInner, SeparatorEdges[APosition]);
    end;
    AItemControl := (AControl as TdxTabContainerDockSite).ActiveChild;
  end
  else AItemControl := AControl;
  if IsValidImageIndex(AItemControl.ImageIndex) then
  begin
    R := ARect;
    if not (APosition in [ahpLeft, ahpRight]) then
      R.Right := R.Left + (GetDefaultImageWidth + 2 * GetHideBarHorizInterval)
    else R.Bottom := R.Top + (GetDefaultImageHeight + 2 * GetHideBarHorizInterval);
    DrawHideBarButtonImage(ACanvas, AItemControl, R);
    if not (APosition in [ahpLeft, ahpRight]) then
      ARect.Left := R.Right
    else ARect.Top := R.Bottom;
  end;
  DrawHideBarButtonText(ACanvas, AItemControl, ARect, APosition);
  if (AControl is TdxTabContainerDockSite) then
    if (AControl as TdxTabContainerDockSite).GetNextValidChild(AItemControl.DockIndex) <> nil then
      DrawColorEdge(ACanvas, ARect, GetHideBarButtonColor, etRaisedInner, SeparatorEdges[APosition]);
end;

procedure TdxDockControlPainter.DrawHideBarButton(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; APosition: TdxAutoHidePosition);
const
  TopEdges: array[TdxAutoHidePosition] of TdxEdgePositions = ([epTop], [epLeft],
    [epTopLeft], [epTopLeft], []);
  BottomEdges: array[TdxAutoHidePosition] of TdxEdgePositions = ([epBottomRight],
    [epBottomRight], [epBottom], [epRight], []);
begin
  DrawColorEdge(ACanvas, ARect, GetHideBarButtonColor, etRaisedOuter, TopEdges[APosition]);
  DrawColorEdge(ACanvas, ARect, GetHideBarButtonColor, etRaisedInner, BottomEdges[APosition]);
  DrawHideBarButtonContent(ACanvas, AControl, ARect, APosition);
end;

procedure TdxDockControlPainter.DrawHideBarButtonImage(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect);
var
  R: TRect;
begin
  if IsValidImageIndex(AControl.ImageIndex) then
  begin
    R.Left := ARect.Left + (ARect.Right - ARect.Left - GetImageWidth) div 2;
    R.Top := ARect.Top + (ARect.Bottom - ARect.Top - GetImageHeight) div 2;
    R.Right := R.Left + GetImageWidth;
    R.Bottom := R.Top + GetImageHeight;
    DrawImage(ACanvas, AControl.Images, AControl.ImageIndex, R);
  end;
end;

procedure TdxDockControlPainter.DrawHideBarButtonText(ACanvas: TCanvas;
  AControl: TdxCustomDockControl; ARect: TRect; APosition: TdxAutoHidePosition);
var
  R: TRect;
  ABitmap: TcxCustomBitmap;
begin
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font := GetHideBarButtonFont;
  ACanvas.Font.Color := ColorToRGB(GetHideBarButtonFontColor);
  InflateRect(ARect, -2, -2);
  case APosition of
    ahpTop, ahpBottom:
      cxDrawText(ACanvas.Handle, AControl.Caption, ARect,
        DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);
    ahpLeft, ahpRight:
      begin
        R := ARect;
        OffsetRect(R, - R.Left, -R.Top);
        R.Right := (ARect.Bottom - ARect.Top);
        R.Bottom := (ARect.Right - ARect.Left);
        ABitmap := TcxCustomBitmap.CreateSize(R, pf32bit);
        try
          ABitmap.Transparent := True;
          ABitmap.Canvas.Brush.Style := bsClear;
          ABitmap.Canvas.Brush.Color := GetHideBarButtonColor;
          ABitmap.Canvas.FillRect(R);

          ABitmap.Canvas.Font := GetHideBarButtonFont;
          ABitmap.Canvas.Font.Color := ColorToRGB(GetHideBarButtonFontColor);
          cxDrawText(ABitmap.Canvas.Handle, AControl.Caption, R,
            DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);
          ABitmap.Rotate(raMinus90);
          ACanvas.Draw(ARect.Left, ARect.Top, ABitmap);
        finally
          ABitmap.Free;
        end;
      end;
  end;
end;

procedure TdxDockControlPainter.DrawTabs(ACanvas: TCanvas; ARect, AActiveTabRect: TRect;
  APosition: TdxTabContainerTabsPosition);
var
  R: TRect;
begin
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := ColorToRGB(GetTabsColor);
  ACanvas.FillRect(ARect);
  R := ARect;
  if APosition = tctpTop then
  begin
    Dec(R.Bottom, 1);
    DrawColorEdge(ACanvas, R, GetTabColor(True), etRaisedOuter, [epBottom]);
    Dec(R.Bottom, 1);
    DrawColorEdge(ACanvas, R, GetTabColor(True), etRaisedInner, [epBottom]);
    R := ARect;
    R.Bottom := AActiveTabRect.Bottom;
    DrawColorEdge(ACanvas, R, GetTabColor(True), etSunkenOuter, [epBottom]);
  end
  else
  begin
    Inc(R.Top, 1);
    DrawColorEdge(ACanvas, R, GetTabColor(True), etRaisedOuter, [epTop]);
    R := ARect;
    R.Top := AActiveTabRect.Top;
    DrawColorEdge(ACanvas, R, GetTabColor(True), etSunkenOuter, [epTop]);
    Inc(R.Top, 1);
    DrawColorEdge(ACanvas, R, GetTabColor(True), etSunkenInner, [epTop]);
  end;
end;

procedure TdxDockControlPainter.DrawTab(ACanvas: TCanvas; AControl: TdxCustomDockControl;
  ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition);
var
  pts: array[0..4] of TPoint;
begin
  if IsActive then
  begin
    ACanvas.Brush.Color := ColorToRGB(GetTabColor(IsActive));
    ACanvas.Brush.Style := bsSolid;
    ACanvas.FillRect(ARect);
  end;

  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  if APosition = tctpTop then
  begin
    ACanvas.Pen.Color := LightLightColor(GetTabColor(True));
    pts[0] := Point(ARect.Left, ARect.Bottom - 1);
    pts[1] := Point(ARect.Left, ARect.Top + 2);
    pts[2] := Point(ARect.Left + 2, ARect.Top);
    pts[3] := Point(ARect.Right - 3, ARect.Top);
    pts[4] := Point(ARect.Right - 1, ARect.Top + 2);
    ACanvas.Polyline(pts);
    ACanvas.Pen.Color := DarkDarkColor(GetTabColor(True));
    ACanvas.MoveTo(ARect.Right - 1, ARect.Top + 2);
    if IsActive then
      ACanvas.LineTo(ARect.Right - 1, ARect.Bottom)
    else ACanvas.LineTo(ARect.Right - 1, ARect.Bottom - 1);
    ACanvas.Pen.Color := DarkColor(GetTabColor(True));
    ACanvas.MoveTo(ARect.Right - 2, ARect.Top + 1);
    if IsActive then
      ACanvas.LineTo(ARect.Right - 2, ARect.Bottom)
    else ACanvas.LineTo(ARect.Right - 2, ARect.Bottom - 1);
  end
  else
  begin
    ACanvas.Pen.Color := LightLightColor(GetTabColor(True));
    if IsActive then
      ACanvas.MoveTo(ARect.Left, ARect.Top)
    else ACanvas.MoveTo(ARect.Left, ARect.Top + 2);
    ACanvas.LineTo(ARect.Left, ARect.Bottom - 2);
    ACanvas.Pen.Color := DarkDarkColor(GetTabColor(True));
    pts[0] := Point(ARect.Left, ARect.Bottom - 2);
    pts[1] := Point(ARect.Left + 2, ARect.Bottom);
    pts[2] := Point(ARect.Right - 3, ARect.Bottom);
    pts[3] := Point(ARect.Right - 1, ARect.Bottom - 2);
    if IsActive then
      pts[4] := Point(ARect.Right - 1, ARect.Top - 1)
    else pts[4] := Point(ARect.Right - 1, ARect.Top + 1);
    ACanvas.Polyline(pts);
    ACanvas.Pen.Color := DarkColor(GetTabColor(True));
    pts[0] := Point(ARect.Left + 1, ARect.Bottom - 2);
    pts[1] := Point(ARect.Left + 2, ARect.Bottom - 1);
    pts[2] := Point(ARect.Right - 3, ARect.Bottom - 1);
    pts[3] := Point(ARect.Right - 2, ARect.Bottom - 2);
    if IsActive then
      pts[4] := Point(ARect.Right - 2, ARect.Top - 1)
    else pts[4] := Point(ARect.Right - 2, ARect.Top + 1);
    ACanvas.Polyline(pts);
  end;

  DrawTabContent(ACanvas, AControl, ARect, IsActive, APosition);
end;

procedure TdxDockControlPainter.DrawTabContent(ACanvas: TCanvas; AControl: TdxCustomDockControl;
  ARect: TRect; IsActive: Boolean; APosition: TdxTabContainerTabsPosition);
var
  R: TRect;
begin
  ARect.Left := ARect.Left + GetTabHorizInterval;
  if IsValidImageIndex(AControl.ImageIndex) then
  begin
    R.Left := ARect.Left;
    R.Top := ARect.Top + (ARect.Bottom - ARect.Top - GetImageHeight) div 2;
    R.Right := R.Left + GetImageWidth;
    R.Bottom := R.Top + GetImageHeight;
    if RectInRect(R, ARect) then
    begin
      DrawImage(ACanvas, AControl.Images, AControl.ImageIndex, R);
      ARect.Left := R.Right + GetTabHorizInterval;
    end;
  end;

  ACanvas.Brush.Style := bsClear;
  ACanvas.Font := GetTabFont(IsActive);
  ACanvas.Font.Color := ColorToRGB(GetTabFontColor(IsActive));
  cxDrawText(ACanvas.Handle, AControl.Caption, ARect,
    DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);
end;

procedure TdxDockControlPainter.DrawTabsNextTabButton(ACanvas: TCanvas; ARect: TRect;
  IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
var
  pts: array[0..2] of TPoint;
begin
  DrawTabsButtonSelection(ACanvas, ARect, IsDown, IsHot, IsEnable, APosition);

  ACanvas.Brush.Color := GetTabsScrollButtonsSignColor(IsEnable);
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Pen.Color := GetTabsScrollButtonsSignColor(IsEnable);
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;

  InflateRect(ARect, -1, -1);
  if IsDown and IsHot then OffsetRect(ARect, 1, 1);
  pts[0] := Point(ARect.Left + 4, ARect.Top + 2);
  pts[1] := Point(ARect.Left + 4, ARect.Bottom - 4);
  pts[2] := Point(ARect.Right - 6, ARect.Top + 6);
  ACanvas.Polygon(pts);
end;

procedure TdxDockControlPainter.DrawTabsPrevTabButton(ACanvas: TCanvas; ARect: TRect;
  IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
var
  pts: array[0..2] of TPoint;
begin
  DrawTabsButtonSelection(ACanvas, ARect, IsDown, IsHot, IsEnable, APosition);

  ACanvas.Brush.Color := GetTabsScrollButtonsSignColor(IsEnable);
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Pen.Color := GetTabsScrollButtonsSignColor(IsEnable);
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;

  InflateRect(ARect, -1, -1);
  if IsDown and IsHot then OffsetRect(ARect, 1, 1);
  pts[0] := Point(ARect.Right - 6, ARect.Top + 2);
  pts[1] := Point(ARect.Right - 6, ARect.Bottom - 4);
  pts[2] := Point(ARect.Left + 4, ARect.Top + 6);
  ACanvas.Polygon(pts);
end;

procedure TdxDockControlPainter.DrawTabsButtonSelection(ACanvas: TCanvas; ARect: TRect;
  IsDown, IsHot, IsEnable: Boolean; APosition: TdxTabContainerTabsPosition);
begin
  if IsDown and IsHot and IsEnable then
  begin
    DrawColorEdge(ACanvas, ARect, GetTabsScrollButtonsColor, etSunkenOuter, [epRect]);
    InflateRect(ARect, -1, -1);
    DrawColorEdge(ACanvas, ARect, GetTabsScrollButtonsColor, etSunkenInner, [epTopLeft]);
  end
  else
  begin
    DrawColorEdge(ACanvas, ARect, GetTabsScrollButtonsColor, etRaisedOuter, [epRect]);
    InflateRect(ARect, -1, -1);
    DrawColorEdge(ACanvas, ARect, GetTabsScrollButtonsColor, etRaisedInner, [epBottomRight]);
  end;
end;

class procedure TdxDockControlPainter.AssignDefaultColor(AManager: TdxDockingManager);
begin
  AManager.Color := clBtnFace;
end;

class procedure TdxDockControlPainter.AssignDefaultFont(AManager: TdxDockingManager);
begin
  cxResetFont(AManager.Font);
  AManager.Font.Color := clBlack;
end;

class procedure TdxDockControlPainter.CreateColors;
begin
end;

class procedure TdxDockControlPainter.RefreshColors;
begin
end;

class procedure TdxDockControlPainter.ReleaseColors;
begin
end;

class function TdxDockControlPainter.LightColor(AColor: TColor): TColor;
begin
  Result := Light(AColor, 60);
end;

class function TdxDockControlPainter.LightLightColor(AColor: TColor): TColor;
begin
  Result := Light(AColor, 20);
end;

class function TdxDockControlPainter.DarkColor(AColor: TColor): TColor;
begin
  Result := Dark(AColor, 60);
end;

class function TdxDockControlPainter.DarkDarkColor(AColor: TColor): TColor;
begin
  Result := Dark(AColor, 20);
end;

class procedure TdxDockControlPainter.DrawColorEdge(ACanvas: TCanvas; ARect: TRect;
  AColor: TColor; AEdgesType: TdxEdgesType; AEdgePositios: TdxEdgePositions);
var
  LTCol, RBCol: TColor;
begin
  case AEdgesType of
    etFlat: begin
      LTCol := DarkColor(AColor);
      RBCol := DarkColor(AColor);
    end;
    etRaisedOuter: begin
      LTCol := LightLightColor(AColor);
      RBCol := DarkDarkColor(AColor);
    end;
    etRaisedInner: begin
      LTCol := LightColor(AColor);
      RBCol := DarkColor(AColor);
    end;
    etSunkenOuter: begin
      LTCol := DarkDarkColor(AColor);
      RBCol := LightLightColor(AColor);
    end;
    etSunkenInner: begin
      LTCol := DarkColor(AColor);
      RBCol := LightColor(AColor);
    end;
  else
    LTCol := ColorToRGB(AColor);
    RBCol := ColorToRGB(AColor);
  end;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Width := 1;
  ACanvas.MoveTo(ARect.Left, ARect.Bottom - 1);
  ACanvas.Pen.Color := LTCol;
  if (epLeft in AEdgePositios) or (epTopLeft in AEdgePositios) or (epRect in AEdgePositios) then
    ACanvas.LineTo(ARect.Left, ARect.Top - 1);
  ACanvas.MoveTo(ARect.Left, ARect.Top);
  if (epTop in AEdgePositios) or (epTopLeft in AEdgePositios) or (epRect in AEdgePositios) then
    ACanvas.LineTo(ARect.Right, ARect.Top);
  ACanvas.MoveTo(ARect.Right - 1, ARect.Top);
  ACanvas.Pen.Color := RBCol;
  if (epRight in AEdgePositios) or (epBottomRight in AEdgePositios) or (epRect in AEdgePositios) then
    ACanvas.LineTo(ARect.Right - 1, ARect.Bottom);
  ACanvas.MoveTo(ARect.Right - 1, ARect.Bottom - 1);
  if (epBottom in AEdgePositios) or (epBottomRight in AEdgePositios) or (epRect in AEdgePositios) then
    ACanvas.LineTo(ARect.Left - 1, ARect.Bottom - 1)
end;

class procedure TdxDockControlPainter.DrawImage(ACanvas: TCanvas; AImageList: TCustomImageList;
  AImageIndex: Integer; R: TRect);
begin
  AImageList.Draw(ACanvas, R.Left, R.Top, AImageIndex);
end;

class function TdxDockControlPainter.RectInRect(R1, R2: TRect): Boolean;
begin
  Result := PtInRect(R2, R1.TopLeft) and PtInRect(R2, R1.BottomRight);
end;

function TdxDockControlPainter.GetCaptionRect(const ARect: TRect;
  AIsVertical: Boolean): TRect;
begin
  with Result do
    if AIsVertical then
    begin
      Left := ARect.Left;
      Top := ARect.Top;
      Right := Left + GetCaptionHeight;
      Bottom := ARect.Bottom;
    end
    else
    begin
      Left := ARect.Left;
      Top := ARect.Top;
      Bottom := Top + GetCaptionHeight;
      Right := ARect.Right;
    end;
end;

function TdxDockControlPainter.GetColor: TColor;
begin
  Result := DockControl.Color;
end;

function TdxDockControlPainter.GetFont: TFont;
begin
  Result := DockControl.Font;
end;

function TdxDockControlPainter.GetBorderColor: TColor;
begin
  Result := GetColor;
end;

function TdxDockControlPainter.GetCaptionColor(IsActive: Boolean): TColor;
begin
  Result := GetColor;
end;

function TdxDockControlPainter.GetCaptionFont(IsActive: Boolean): TFont;
begin
  Result := GetFont;
end;

function TdxDockControlPainter.GetCaptionFontColor(IsActive: Boolean): TColor;
begin
  Result := GetCaptionFont(IsActive).Color;
end;

function TdxDockControlPainter.GetCaptionSignColor(IsActive, IsDown, IsHot: Boolean): TColor;
begin
  Result := GetCaptionFontColor(IsActive);
end;

function TdxDockControlPainter.GetTabsColor: TColor;
begin
  Result := GetColor;
end;

function TdxDockControlPainter.GetTabColor(IsActive: Boolean): TColor;
begin
  Result := GetColor;
end;

function TdxDockControlPainter.GetTabFont(IsActive: Boolean): TFont;
begin
  Result := GetFont;
end;

function TdxDockControlPainter.GetTabFontColor(IsActive: Boolean): TColor;
begin
  Result := GetTabFont(IsActive).Color;
end;

function TdxDockControlPainter.GetTabsScrollButtonsColor: TColor;
begin
  Result := GetColor;
end;

function TdxDockControlPainter.GetTabsScrollButtonsSignColor(IsEnable: Boolean): TColor;
begin
  if IsEnable then
    Result := DarkDarkColor(GetColor)
  else Result := DarkColor(GetTabColor(True));
end;

function TdxDockControlPainter.GetHideBarColor: TColor;
begin
  Result := GetColor;
end;

function TdxDockControlPainter.IsHideBarButtonHotTrackSupports: Boolean; 
begin
  Result := False;
end;

function TdxDockControlPainter.GetHideBarButtonColor: TColor;
begin
  Result := GetColor;
end;

function TdxDockControlPainter.GetHideBarButtonFont: TFont;
begin
  Result := GetFont;
end;

function TdxDockControlPainter.GetHideBarButtonFontColor: TColor;
begin
  Result := GetHideBarButtonFont.Color;
end;

function TdxDockControlPainter.DrawCaptionFirst: Boolean;
begin
  Result := False;
end;

function TdxDockControlPainter.NeedRedrawOnResize: Boolean;
begin
  Result := False;
end;

{ TdxDockingController }

function dxDockingWndProcHook(Code: Integer; wParam: WParam; lParam: LParam): LRESULT; stdcall;
var
  AControl: TWinControl;
  AParentDockControl, AActiveDockControl: TdxCustomDockControl;
  AMsg: PCWPStruct;
begin
  AMsg := PCWPStruct(lParam);
  AControl := FindControl(AMsg.hwnd);
  if AControl is TdxFloatForm then
    AControl := nil;
  case AMsg.message of
    WM_ACTIVATEAPP:
      begin
        if (AControl is TCustomForm) then
        begin
          if (csDesigning in AControl.ComponentState) then
            dxDockingController.UpdateVisibilityFloatForms(nil, AMsg.wParam <> 0)
          else
          begin
          {$IFDEF DELPHI11}
            if Application.MainFormOnTaskBar and (AMsg.wParam <> 0) then
              dxDockingController.UpdateVisibilityFloatForms(Application.MainForm, AMsg.wParam <> 0);
          {$ENDIF}
          end;
        end;
        dxDockingController.ActiveAppChanged(AMsg.wParam <> 0);
      end;
    WM_ENABLE:
      if (AControl is TCustomForm) then
        dxDockingController.UpdateEnableStatusFloatForms(AControl as TCustomForm, AMsg.wParam <> 0);
  {$IFDEF DELPHI11}
    WM_SIZE:
      if (AControl is TCustomForm) and
        Application.MainFormOnTaskBar and (AControl = Application.MainForm) then
        case AMsg.wParam of
          SIZE_MINIMIZED: dxDockingController.UpdateVisibilityFloatForms(Application.MainForm, False);
          SIZE_RESTORED: dxDockingController.UpdateVisibilityFloatForms(Application.MainForm, True);
        end;
  {$ENDIF}
    WM_WINDOWPOSCHANGED:
    begin
      if (AControl is TCustomForm) then
      begin
        if PWindowPos(AMsg.lParam).flags and SWP_SHOWWINDOW <> 0 then
        begin
          dxDockingController.UpdateVisibilityFloatForms(AControl as TCustomForm, True);
          dxDockingController.UpdateLayouts(AControl as TCustomForm);
        end
        else
          if PWindowPos(AMsg.lParam).flags and SWP_HIDEWINDOW <> 0 then
            dxDockingController.UpdateVisibilityFloatForms(AControl as TCustomForm, False);
      end;
    end;
    WM_SETFOCUS:
      begin
        if dxDockingController.FActiveDockControlLockCount = 0 then
        begin
          AActiveDockControl := dxDockingController.GetDockControlForWindow(AMsg.hwnd);
          if Application.Active and
            (AActiveDockControl <> nil) and AActiveDockControl.HandleAllocated and
            (AActiveDockControl <> dxDockingController.FActivatingDockControl) then
            dxDockingController.ActiveDockControl := AActiveDockControl;
        end;
      end;
    WM_KILLFOCUS:
      begin
        if dxDockingController.FActiveDockControlLockCount = 0 then
        begin
          AParentDockControl := dxDockingController.GetDockControlForWindow(AMsg.hwnd);
          if Application.Active and (AParentDockControl <> nil) and
            (dxDockingController.ActiveDockControl = AParentDockControl) and
            (AParentDockControl <> dxDockingController.FActivatingDockControl) then
          begin
            AActiveDockControl := dxDockingController.GetDockControlForWindow(AMsg.wParam); // focused
            if (AActiveDockControl = nil) or (AActiveDockControl <> AParentDockControl) then
              dxDockingController.ActiveDockControl := nil;
          end;
        end;
      end;
  end;
  Result := CallNextHookEx(FWndProcHookHandle, Code, wParam, lParam);
end;

constructor TdxDockingController.Create;
begin
  inherited;
  FDestroyedDockControls := TList.Create;
  FLoadedForms := TList.Create;
  FDockControls := TList.Create;
  FDockManagers := TList.Create;
  FFont := TFont.Create;
  FInvalidNC := TList.Create;
  FInvalidNCBounds := TList.Create;
  FInvalidRedraw := TList.Create;
  FSelectionBrush := TBrush.Create;
  FSelectionBrush.Bitmap := AllocPatternBitmap(clBlack, clWhite);
  SetHook(FWndProcHookHandle, WH_CALLWNDPROC, dxDockingWndProcHook);
  TdxDockControlPainter.CreateColors;
end;

destructor TdxDockingController.Destroy;
begin
  TdxDockControlPainter.ReleaseColors;
  ReleaseHook(FWndProcHookHandle);
  FSelectionBrush.Free;
  FInvalidRedraw.Free;
  FInvalidNCBounds.Free;
  FInvalidNC.Free;
  FFont.Free;
  FDockManagers.Free;
  FDockControls.Free;
  FLoadedForms.Free;
  FDestroyedDockControls.Free;
  ReleaseTempBitmap;
  inherited;
end;

procedure TdxDockingController.ActiveAppChanged(AActive: Boolean);
begin
  if not AActive then
  begin
    FinishDocking;
    FinishResizing;
  end;
  
  ApplicationActive := Application.Active;
end;

procedure TdxDockingController.BeginUpdate;
begin
  BeginUpdateNC;
end;

procedure TdxDockingController.EndUpdate;
begin
  EndUpdateNC;
end;

function TdxDockingController.GetDockControlAtPos(const P: TPoint): TdxCustomDockControl;
begin
  Result := GetDockControlForWindow(WindowFromPoint(P));
end;
{function TdxDockingController.GetDockControlAtPos(const P: TPoint): TdxCustomDockControl;
var
  AControl: TControl;
  AWnd: HWND;
begin
  Result := nil;
  AWnd := WindowFromPoint(P);
  while AWnd <> 0 do
  begin
    AControl := FindControl(AWnd);
    if AControl is TdxCustomDockControl then
    begin
      Result := AControl as TdxCustomDockControl;
      Break;
    end;
    AWnd := GetParent(AWnd);
  end;
end;}

function TdxDockingController.GetDockControlForWindow(AWnd: HWND; ADockWindow: HWND = 0): TdxCustomDockControl;
var
  AFloatForm: TdxFloatForm;
begin
  Result := nil;
  while AWnd <> 0 do
  begin
    if Assigned(cxControls.cxGetParentWndForDocking) then
      AWnd := cxControls.cxGetParentWndForDocking(AWnd);

    if FindControl(AWnd) is TdxCustomDockControl then
    begin
      Result := TdxCustomDockControl(FindControl(AWnd));
      if (ADockWindow = 0) or (AWnd = ADockWindow) then
        Break
      else
        Result := nil;
    end;

    if FindControl(AWnd) is TdxFloatForm then
    begin
      AFloatForm := TdxFloatForm(FindControl(AWnd));
      if AFloatForm.DockSite <> nil then
        Result := AFloatForm.DockSite.GetDockPanel
      else
        Result := nil;
      if (Result <> nil) and (ADockWindow <> 0) and (Result.Handle <> ADockWindow) then
        Result := nil;
      Break;
    end;

    AWnd := GetParent(AWnd);
  end;
end;
{function TdxDockingController.GetDockControlForWindow(AWnd: HWND): TdxCustomDockControl;
var
  AFloatForm: TdxFloatForm;
begin
  Result := nil;

  while AWnd <> 0 do
  begin
    if Assigned(cxControls.cxGetParentWndForDocking) then
      AWnd := cxControls.cxGetParentWndForDocking(AWnd);

    if FindControl(AWnd) is TdxCustomDockControl then
    begin
      Result := FindControl(AWnd) as TdxCustomDockControl;
      Break;
    end;

    if FindControl(AWnd) is TdxFloatForm then
    begin
      AFloatForm := FindControl(AWnd) as TdxFloatForm;
      if AFloatForm.DockSite <> nil then
        Result := AFloatForm.DockSite.GetDockPanel
      else
        Result := nil;
      Break;
    end;

    AWnd := GetParent(AWnd);
  end;
end;}

function TdxDockingController.GetFloatDockSiteAtPos(pt: TPoint): TdxCustomDockControl;
var
  AControl: TWinControl;
  Message: TMessage;
begin
  Result := nil;
  AControl := FindVCLWindow(pt);
  if AControl is TdxFloatForm then
  begin
    Message.Msg := WM_NCHITTEST;
    Message.LParamLo := pt.X;
    Message.LParamHi := pt.Y;
    Message.Result := 0;
    AControl.WindowProc(Message);
    if (Message.Result = HTCAPTION) then
      Result := (AControl as TdxFloatForm).DockSite;
  end;
end;

function TdxDockingController.GetNearestDockSiteAtPos(pt: TPoint): TdxCustomDockControl;
var
  I: Integer;
  ADockSite: TdxDockSite;
  R: TRect;
begin
  Result := nil;
  for I := 0 to DockControlCount - 1 do
    if DockControls[I] is TdxDockSite then
    begin
      ADockSite := DockControls[I] as TdxDockSite;
      if not ADockSite.AutoSize then continue;
      if not (ADockSite.Align in [alLeft, alTop, alRight, alBottom]) then continue;
      if (ADockSite.Align in [alLeft, alRight]) and (ADockSite.Width > ADockSite.ControllerDockZonesWidth) then continue;
      if (ADockSite.Align in [alTop, alBottom]) and (ADockSite.Height > ADockSite.ControllerDockZonesWidth) then continue;
      R := cxGetWindowRect(ADockSite);
      case ADockSite.Align of
        alLeft: R.Right := R.Left + ADockSite.ControllerDockZonesWidth;
        alTop: R.Bottom := R.Top + ADockSite.ControllerDockZonesWidth;
        alRight: R.Left := R.Right - ADockSite.ControllerDockZonesWidth;
        alBottom: R.Top := R.Bottom - ADockSite.ControllerDockZonesWidth;
      end;
      if PtInRect(R, pt) then
      begin
        Result := ADockSite;
        break;
      end;
    end;
end;

function TdxDockingController.IsDockControlFocusedEx(ADockControl: TdxCustomDockControl): Boolean;
begin
  Result := ADockControl.HandleAllocated and
    (dxDockingController.GetDockControlForWindow(GetFocus, ADockControl.Handle) = ADockControl);
end;
{function TdxDockingController.IsDockControlFocusedEx(ADockControl: TdxCustomDockControl): Boolean;
var
  AWnd: HWND;
begin
  Result := False;
  if not ADockControl.HandleAllocated then Exit;
  AWnd := GetFocus;
  while AWnd <> 0 do
  begin
    if ADockControl.Handle = AWnd then
    begin
      Result := True;
      Break;
    end;
    AWnd := GetParent(AWnd);
  end;
end;}

function TdxDockingController.FindManager(AForm: TCustomForm): TdxDockingManager;
begin
  Result := FindFormManager(AForm);
  if (Result = nil) and (DockManagerCount > 0) then
    Result := DockManagers[0];
end;

function TdxDockingController.FindFormManager(AForm: TCustomForm): TdxDockingManager;
var
  I: Integer;
  AManager: TdxDockingManager;
begin
  Result := nil;
  for I := 0 to FDockManagers.Count - 1 do
  begin
    AManager := TdxDockingManager(FDockManagers[I]);
    if AManager.ParentForm = AForm then
    begin
      Result := AManager;
      break;
    end;
  end;
end;

procedure TdxDockingController.RegisterManager(AManager: TdxDockingManager);
var
  AOldManager: TdxDockingManager;
begin
  AOldManager := FindFormManager(AManager.ParentForm);
  if (AOldManager <> nil) and (AOldManager <> AManager) then
    raise EdxException.Create(sdxManagerError);
  if AOldManager = nil then
  begin
    FDockManagers.Add(AManager);
    DoManagerChanged(AManager.ParentForm);
  end;
end;

procedure TdxDockingController.UnregisterManager(AManager: TdxDockingManager);
begin
  if FindManager(AManager.ParentForm) <> nil then
  begin
    FDockManagers.Remove(AManager);
    DoManagerChanged(nil);
  end;
end;

procedure TdxDockingController.DoActiveDockControlChanged(ASender: TdxCustomDockControl;
  ACallEvent: Boolean);
var
  AManager: TdxDockingManager;
begin
  if ACallEvent and (ASender <> nil) then
  begin
    AManager := FindManager(ASender.ParentForm);
    if (AManager <> nil) and Assigned(AManager.OnActiveDockControlChanged) then
      AManager.OnActiveDockControlChanged(AManager);
  end;
end;

procedure TdxDockingController.DoCreateFloatSite(ASender: TdxCustomDockControl; ASite: TdxFloatDockSite);
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(ASender.ParentForm);
  if (AManager <> nil) and Assigned(AManager.OnCreateFloatSite) then
    AManager.OnCreateFloatSite(ASender, ASite);
end;

procedure TdxDockingController.DoCreateLayoutSite(ASender: TdxCustomDockControl; ASite: TdxLayoutDockSite);
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(ASender.ParentForm);
  if (AManager <> nil) and Assigned(AManager.OnCreateLayoutSite) then
    AManager.OnCreateLayoutSite(ASender, ASite);
end;

procedure TdxDockingController.DoCreateSideContainerSite(ASender: TdxCustomDockControl;
  ASite: TdxSideContainerDockSite);
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(ASender.ParentForm);
  if (AManager <> nil) and Assigned(AManager.OnCreateSideContainer) then
    AManager.OnCreateSideContainer(ASender, ASite);
end;

procedure TdxDockingController.DoCreateTabContainerSite(ASender: TdxCustomDockControl;
  ASite: TdxTabContainerDockSite);
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(ASender.ParentForm);
  if (AManager <> nil) and Assigned(AManager.OnCreateTabContainer) then
    AManager.OnCreateTabContainer(ASender, ASite);
end;

function TdxDockingController.DoCustomDrawResizingSelection(ASender: TdxCustomDockControl;
  DC: HDC; AZone: TdxZone; pt: TPoint; Erasing: Boolean): Boolean;
var
  AManager: TdxDockingManager;
begin
  Result := False;
  if Assigned(ASender.OnCustomDrawResizingSelection) then
    ASender.OnCustomDrawResizingSelection(ASender, DC, AZone, AZone.GetResizingSelection(pt), Erasing, Result);
  if not Result then
  begin
    AManager := FindManager(ASender.ParentForm);
    if (AManager <> nil) and Assigned(AManager.OnCustomDrawResizingSelection) then
      AManager.OnCustomDrawResizingSelection(ASender, DC, AZone, AZone.GetResizingSelection(pt), Erasing, Result);
  end;
end;

function TdxDockingController.DoCustomDrawDockingSelection(ASender: TdxCustomDockControl;
  DC: HDC; AZone: TdxZone; R: TRect; Erasing: Boolean): Boolean;
var
  AManager: TdxDockingManager;
begin
  Result := False;
  if Assigned(ASender.OnCustomDrawDockingSelection) then
    ASender.OnCustomDrawDockingSelection(ASender, DC, AZone, R, Erasing, Result);
  if not Result then
  begin
    AManager := FindManager(ASender.ParentForm);
    if (AManager <> nil) and Assigned(AManager.OnCustomDrawDockingSelection) then
      AManager.OnCustomDrawDockingSelection(ASender, DC, AZone, R, Erasing, Result);
  end;
end;

procedure TdxDockingController.DoSetFloatFormCaption(ASender: TdxCustomDockControl;
  AFloatForm: TdxFloatForm);
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(ASender.ParentForm);
  if (AManager <> nil) and Assigned(AManager.OnSetFloatFormCaption) then
    AManager.OnSetFloatFormCaption(ASender, AFloatForm);
end;

function TdxDockingController.DefaultLayoutSiteProperties(AForm: TCustomForm): TdxLayoutDockSiteProperties;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if (AManager <> nil) and AManager.UseDefaultSitesProperties then
    Result := AManager.DefaultLayoutSiteProperties
  else Result := nil;
end;

function TdxDockingController.DefaultFloatSiteProperties(AForm: TCustomForm): TdxFloatDockSiteProperties;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if (AManager <> nil) and AManager.UseDefaultSitesProperties then
    Result := AManager.DefaultFloatSiteProperties
  else Result := nil;
end;

function TdxDockingController.DefaultHorizContainerSiteProperties(AForm: TCustomForm): TdxSideContainerDockSiteProperties;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if (AManager <> nil) and AManager.UseDefaultSitesProperties then
    Result := AManager.DefaultHorizContainerSiteProperties
  else Result := nil;
end;

function TdxDockingController.DefaultVertContainerSiteProperties(AForm: TCustomForm): TdxSideContainerDockSiteProperties;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if (AManager <> nil) and AManager.UseDefaultSitesProperties then
    Result := AManager.DefaultVertContainerSiteProperties
  else Result := nil;
end;

function TdxDockingController.DefaultTabContainerSiteProperties(AForm: TCustomForm): TdxTabContainerDockSiteProperties;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if (AManager <> nil) and AManager.UseDefaultSitesProperties then
    Result := AManager.DefaultTabContainerSiteProperties
  else Result := nil;
end;

procedure TdxDockingController.LoadLayoutFromIniFile(AFileName: string; AForm: TCustomForm = nil);
var
  AStream: TFileStream;
begin
  if ExtractFileExt(AFileName) = '' then
    AFileName := ChangeFileExt(AFileName, '.ini');
  if not FileExists(AFileName) then Exit;
{$IFDEF DELPHI6}
  AStream := TFileStream.Create(AFileName, fmOpenRead, fmShareDenyWrite);
{$ELSE}
  AStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
{$ENDIF}
  try
    LoadLayoutFromStream(AStream, AForm);
  finally
    AStream.Free;
  end;
end;

procedure TdxDockingController.LoadLayoutFromRegistry(ARegistryPath: string; AForm: TCustomForm = nil);
var
  Storage: TRegistryIniFile;
begin
  Storage := TRegistryIniFile.Create(ARegistryPath);
  try
    LoadLayoutFromCustomIni(Storage, AForm);
  finally
    Storage.Free;
  end;
end;

procedure TdxDockingController.LoadLayoutFromStream(AStream: TStream; AForm: TCustomForm = nil);
var
  Storage: TMemIniFile;
  AStrings: TStringList;
begin
  Storage := TMemIniFile.Create('');
  AStrings := TStringList.Create;
  try
    AStrings.LoadFromStream(AStream);
    Storage.SetStrings(AStrings);
    LoadLayoutFromCustomIni(Storage, AForm);
  finally
    AStrings.Free;
    Storage.Free;
  end;
end;

procedure TdxDockingController.SaveLayoutToIniFile(AFileName: string; AForm: TCustomForm = nil);
var
  AStream: TFileStream;
begin
  if AFileName = '' then exit;
  if ExtractFileExt(AFileName) = '' then
    AFileName := ChangeFileExt(AFileName, '.ini');
{$IFDEF DELPHI6}
  AStream := TFileStream.Create(AFileName, fmCreate, fmShareExclusive);
{$ELSE}
  AStream := TFileStream.Create(AFileName, fmCreate or fmShareExclusive);
{$ENDIF}
  try
    SaveLayoutToStream(AStream, AForm);
  finally
    AStream.Free;
  end;
end;

procedure TdxDockingController.SaveLayoutToRegistry(ARegistryPath: string; AForm: TCustomForm = nil);
var
  Storage: TRegistryIniFile;
begin
  if ARegistryPath = '' then exit;
  Storage := TRegistryIniFile.Create(ARegistryPath);
  try
    SaveLayoutToCustomIni(Storage, AForm);
  finally
    Storage.Free;
  end;
end;

procedure TdxDockingController.SaveLayoutToStream(AStream: TStream; AForm: TCustomForm = nil);
var
  Storage: TMemIniFile;
  AStrings: TStringList;
begin
  Storage := TMemIniFile.Create('');
  AStrings := TStringList.Create;
  try
    SaveLayoutToCustomIni(Storage, AForm);
    Storage.GetStrings(AStrings);
    AStrings.SaveToStream(AStream);
  finally
    AStrings.Free;
    Storage.Free;
  end;
end;

function TdxDockingController.AutoHideInterval(AForm: TCustomForm): Integer;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.AutoHideInterval
  else Result := dxAutoHideInterval;
end;

function TdxDockingController.AutoHideMovingInterval(AForm: TCustomForm): Integer;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.AutoHideMovingInterval
  else Result := dxAutoHideMovingInterval;
end;

function TdxDockingController.AutoHideMovingSize(AForm: TCustomForm): Integer;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.AutoHideMovingSize
  else Result := dxAutoHideMovingSize;
end;

function TdxDockingController.AutoShowInterval(AForm: TCustomForm): Integer;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.AutoShowInterval
  else Result := dxAutoShowInterval;
end;

function TdxDockingController.Color(AForm: TCustomForm): TColor;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.Color
  else Result := clBtnFace;
end;

function TdxDockingController.DockZonesWidth(AForm: TCustomForm): Integer;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.DockZonesWidth
  else Result := dxDockZonesWidth;
end;

function TdxDockingController.Font(AForm: TCustomForm): TFont;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.Font
  else Result := FFont;
end;

function TdxDockingController.Images(AForm: TCustomForm): TCustomImageList;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.Images
  else Result := nil;
end;

function TdxDockingController.Options(AForm: TCustomForm): TdxDockingOptions;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.Options
  else
    Result := dxDockingDefaultOptions;
end;

function TdxDockingController.ViewStyle(AForm: TCustomForm): TdxDockingViewStyle;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.ViewStyle
  else Result := vsStandard;
end;

function TdxDockingController.ResizeZonesWidth(AForm: TCustomForm): Integer;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.ResizeZonesWidth
  else Result := dxResizeZonesWidth;
end;

function TdxDockingController.SelectionFrameWidth(AForm: TCustomForm): Integer;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.SelectionFrameWidth
  else Result := dxSelectionFrameWidth;
end;

function TdxDockingController.TabsScrollInterval(AForm: TCustomForm): Integer;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.TabsScrollInterval
  else Result := dxTabsScrollInterval;
end;

procedure TdxDockingController.DoColorChanged(AForm: TCustomForm);
var
  I: Integer;
begin
  BeginUpdateNC;
  try
    for I := 0 to DockControlCount - 1 do
      if ControlNeedUpdate(DockControls[I], AForm) and DockControls[I].ManagerColor then
      begin
        DockControls[I].Color := Color(DockControls[I].ParentForm);
        DockControls[I].FManagerColor := True;
      end;
    InvalidateControls(AForm, False);
  finally
    EndUpdateNC;
  end;
end;

procedure TdxDockingController.DoImagesChanged(AForm: TCustomForm);
begin
  CalculateControls(AForm);
end;

procedure TdxDockingController.DoLayoutLoaded(AForm: TCustomForm);
var
  I: Integer;
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if (AManager <> nil) then
  begin
    if Assigned(AManager.OnLayoutChanged) then
      AManager.OnLayoutChanged(nil);
  end
  else for I := 0 to DockManagerCount - 1 do
  begin
    if Assigned(DockManagers[I].OnLayoutChanged) then
      DockManagers[I].OnLayoutChanged(nil);
  end;
end;

procedure TdxDockingController.DoFontChanged(AForm: TCustomForm);
var
  I: Integer;
begin
  BeginUpdateNC;
  try
    for I := 0 to DockControlCount - 1 do
      if ControlNeedUpdate(DockControls[I], AForm) and DockControls[I].ManagerFont then
      begin
        if not DockControls[I].IsDestroying then // !!!
        begin
          DockControls[I].Font := Font(DockControls[I].ParentForm);
          DockControls[I].FManagerFont := True;
        end;
      end;
    CalculateControls(AForm);
  finally
    EndUpdateNC;
  end;
end;

procedure TdxDockingController.DoLayoutChanged(ASender: TdxCustomDockControl);
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(ASender.ParentForm);
  if (AManager <> nil) and Assigned(AManager.OnLayoutChanged) then
    AManager.OnLayoutChanged(ASender);
end;

procedure TdxDockingController.DoManagerChanged(AForm: TCustomForm);
begin
  BeginUpdateNC;
  Include(FInternalState, disManagerChanged);
  try
    DoColorChanged(AForm);
    DoImagesChanged(AForm);
    DoFontChanged(AForm);
    DoOptionsChanged(AForm);
    DoPainterChanged(AForm, False);
  finally
    Exclude(FInternalState, disManagerChanged);
    EndUpdateNC;
  end;
end;

procedure TdxDockingController.DoOptionsChanged(AForm: TCustomForm);
begin
  BringToFrontFloatForms(nil, doFloatingOnTop in Options(AForm));
  UpdateLayout(AForm);
  CalculateControls(AForm);
end;

procedure TdxDockingController.DoPainterChanged(AForm: TCustomForm; AssignDefaultStyle: Boolean);
var
  I: Integer;
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  BeginUpdateNC;
  try
    if AManager <> nil then
      AManager.ReleasePainterClass
    else
      for I := 0 to DockManagerCount - 1 do
        DockManagers[I].ReleasePainterClass;
    for I := 0 to DockControlCount - 1 do
    begin
      if ControlNeedUpdate(DockControls[I], AForm) then
      begin
        DockControls[I].FPainter.Free;
        DockControls[I].FPainter := nil;
      end;
    end;
    if AManager <> nil then
      AManager.CreatePainterClass(AssignDefaultStyle)
    else
      for I := 0 to DockManagerCount - 1 do
        DockManagers[I].CreatePainterClass(AssignDefaultStyle);
    CalculateControls(AForm);
  finally
    EndUpdateNC;
  end;
end;

procedure TdxDockingController.DoZonesWidthChanged(AForm: TCustomForm);
begin
  UpdateLayout(AForm);
end;

procedure TdxDockingController.DoUpdateDockZones(ASender: TdxCustomDockControl);
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(ASender.ParentForm);
  if (AManager <> nil) and Assigned(AManager.OnUpdateDockZones) then
    AManager.OnUpdateDockZones(ASender, ASender.DockZones);
end;

procedure TdxDockingController.DoUpdateResizeZones(ASender: TdxCustomDockControl);
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(ASender.ParentForm);
  if (AManager <> nil) and Assigned(AManager.OnUpdateResizeZones) then
    AManager.OnUpdateResizeZones(ASender, ASender.ResizeZones);
end;

procedure TdxDockingController.ClearLayout(AForm: TCustomForm);
var
  I: Integer;
begin
  I := 0;
  while I < DockControlCount do
  begin
    if ((DockControls[I].ParentForm = AForm) or (AForm = nil)) and
      (DockControls[I] is TdxDockPanel) and (DockControls[I].ParentDockControl <> nil) then
    begin
      DockControls[I].UnDock;
      I := 0;
    end
    else Inc(I);
  end;
  SendMessage(Handle, WM_DESTROYCONTROLS, 0, 0);
end;

procedure TdxDockingController.LoadLayoutFromCustomIni(AIniFile: TCustomIniFile; AForm: TCustomForm);
var
  I, ADockControlCount: Integer;
  ASections: TStringList;
  AControlClass: TdxCustomDockControlClass;
  AParentForm: TCustomForm;
  ASectionName: string;
begin
  BeginUpdateNC;
  try
    ASections := TStringList.Create;
    with AIniFile do
      try
        ReadSections(ASections);
        ADockControlCount := ReadInteger('Root', 'DockControlCount', ASections.Count);
        if ASections.Count > 0 then
          ClearLayout(AForm);
        for I := 0 to ADockControlCount - 1 do
        begin
          ASectionName := IntToStr(I);
          if SectionExists(ASectionName) then
          begin
            AControlClass := TdxCustomDockControlClass(FindClass(ReadString(ASectionName, 'ClassName', '')));
            if (AControlClass = TdxDockSite) or (AControlClass = TdxFloatDockSite) then
            begin
              AParentForm := FindGlobalComponent(ReadString(ASectionName, 'ParentForm', '')) as TCustomForm;
              if (AParentForm <> nil) and ((AParentForm = AForm) or (AForm = nil)) then
                LoadControlFromCustomIni(AIniFile, AForm, nil, ASectionName);
            end;
          end;
        end;
      finally
        ASections.Free;
      end;
  finally
    EndUpdateNC;
  end;
  DoLayoutLoaded(nil);
end;

procedure TdxDockingController.LoadControlFromCustomIni(AIniFile: TCustomIniFile;
  AParentForm: TCustomForm; AParentControl: TdxCustomDockControl; ASection: string);
var
  AControl: TdxCustomDockControl;
  AControlClass: TdxCustomDockControlClass;
begin
  with AIniFile do
  begin
    if AParentForm = nil then
      AParentForm := FindGlobalComponent(ReadString(ASection, 'ParentForm', '')) as TCustomForm;
    if AParentForm <> nil then
    begin
      AControl := AParentForm.FindComponent(ReadString(ASection, 'Name', '')) as TdxCustomDockControl;
      if AControl = nil then
      begin
        AControlClass := TdxCustomDockControlClass(FindClass(ReadString(ASection, 'ClassName', '')));
        if (AControlClass <> nil) then
        begin
          AControl := AControlClass.Create(AParentForm);
          AControl.Name := ReadString(ASection, 'Name', '');
        end;
      end;
      if AControl <> nil then
        AControl.LoadLayoutFromCustomIni(AIniFile, AParentForm, AParentControl, ASection);
    end;
  end;
end;

procedure TdxDockingController.SaveLayoutToCustomIni(AIniFile: TCustomIniFile; AForm: TCustomForm);
var
  I, AOldCount: Integer;
begin
  SendMessage(Handle, WM_DESTROYCONTROLS, 0, 0);
  // Erase old section
  AOldCount := AIniFile.ReadInteger('Root', 'DockControlCount', 0);
  for I := AOldCount - 1 downto 0 do
    AIniFile.EraseSection(IntToStr(I));
  AIniFile.WriteInteger('Root', 'DockControlCount', DockControlCount);
  for I := 0 to DockControlCount - 1 do
  begin
    if DockControls[I].DockState = dsDestroyed then continue;
    if ((DockControls[I].ParentForm = AForm) or (AForm = nil)) and
      ((DockControls[I] is TdxDockSite) or (DockControls[I] is TdxFloatDockSite)) then
      SaveControlToCustomIni(AIniFile, DockControls[I]);
  end;
end;

procedure TdxDockingController.SaveControlToCustomIni(AIniFile: TCustomIniFile;
  AControl: TdxCustomDockControl);
var
  ASection: string;
begin
  with AIniFile do
  begin
    ASection := IntToStr(IndexOfDockControl(AControl));
    WriteString(ASection, 'ClassName', AControl.ClassName);
    WriteString(ASection, 'Name', AControl.Name);
    WriteString(ASection, 'ParentForm', AControl.ParentForm.Name);
    AControl.SaveLayoutToCustomIni(AIniFile, ASection);
  end;
end;

procedure TdxDockingController.UpdateLayout(AForm: TCustomForm);
var
  I: Integer;
begin
  for I := 0 to DockControlCount - 1 do
  begin
    if DockControls[I].IsDestroying or DockControls[I].IsUpdateLayoutLocked then
      continue;
    if ControlNeedUpdate(DockControls[I], AForm) then
      DockControls[I].UpdateLayout;
  end;
end;

procedure TdxDockingController.BeginUpdateNC(ALockRedraw: Boolean);
begin
  if FCalculatingControl <> nil then exit;
  if (FUpdateNCLock = 0) and ALockRedraw then
    Include(FInternalState, disRedrawLocked);
  Inc(FUpdateNCLock);
end;

procedure TdxDockingController.EndUpdateNC;
begin
  if FCalculatingControl <> nil then exit;
  Dec(FUpdateNCLock);
  if FUpdateNCLock = 0 then
  begin
    UpdateInvalidControlsNC;
    Exclude(FInternalState, disRedrawLocked);
  end;
end;

function TdxDockingController.ControlNeedUpdate(AControl: TdxCustomDockControl; AForm: TCustomForm): Boolean;
begin
  Result := FindManager(AControl.ParentForm) = FindManager(AForm);
end;

procedure TdxDockingController.DestroyControls;
var
  AControl: TdxCustomDockControl;
begin
  while FDestroyedDockControls.Count > 0 do
  begin
    AControl := TdxCustomDockControl(FDestroyedDockControls.Items[FDestroyedDockControls.Count - 1]);
    FDestroyedDockControls.Remove(AControl);
    if not (csDestroying in AControl.ComponentState) then AControl.Free;
  end;
end;

procedure TdxDockingController.FinishDocking;
begin
  if DockingDockControl <> nil then
    DockingDockControl.EndDocking(Point(0, 0), True);
end;

procedure TdxDockingController.FinishResizing;
begin
  if ResizingDockControl <> nil then
    ResizingDockControl.EndResize(Point(0, 0), True);
end;

function CompareDocks(Item1, Item2: Pointer): Integer;
var
  AControl1, AControl2: TdxCustomDockControl;
begin
  AControl1 := TdxCustomDockControl(Item1);
  AControl2 := TdxCustomDockControl(Item2);
  Result := AControl1.DockLevel - AControl2.DockLevel;
  if Result = 0 then
    Result := AControl1.DockIndex - AControl2.DockIndex;
  if AControl2.AutoHide and not AControl1.AutoHide then
    Result := -1
  else if AControl2.AutoHide and not AControl1.AutoHide then
    Result := 1;
end;

procedure TdxDockingController.UpdateInvalidControlsNC;
var
  I: Integer;
  AControl: TdxCustomDockControl;
begin
  if FCalculatingControl <> nil then exit;
  while FInvalidNCBounds.Count > 0 do
  begin
    FInvalidNCBounds.Sort(CompareDocks);
    FCalculatingControl := TdxCustomDockControl(FInvalidNCBounds[0]);
    try
      FCalculatingControl.NCChanged;
      FInvalidNCBounds.Remove(FCalculatingControl);
    finally
      FCalculatingControl := nil;
    end;
  end;
  FInvalidNC.Sort(CompareDocks);
  for I := 0 to FInvalidNC.Count - 1 do
  begin
    AControl := TdxCustomDockControl(FInvalidNC.Items[I]);
    if not AControl.Visible then continue;
    if FInvalidRedraw.IndexOf(AControl) > -1 then
    begin
      if disRedrawLocked in FInternalState then
      begin
        AControl.Perform(WM_SETREDRAW, Integer(True), 0);
//      SendMessage(AControl.Handle, WM_SETREDRAW, Integer(True), 0);
        AControl.Redraw(True);
      end
      else
        AControl.Redraw(False);
      if AControl.HandleAllocated and (AControl is TdxDockSite) and (AControl.Parent <> nil) then
        RedrawWindow(AControl.Parent.Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN);
    end
    else
      AControl.InvalidateNC(True);
  end;
  FInvalidNC.Clear;
  FInvalidRedraw.Clear;
end;

procedure TdxDockingController.UpdateLayouts(AForm: TCustomForm);
var
  I: Integer;
begin
  I := FLoadedForms.IndexOf(AForm);
  if I <> -1 then
  begin
    FLoadedForms.Delete(I);
    dxDockingController.UpdateLayout(AForm);
  end;
end;

procedure TdxDockingController.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_DESTROYCONTROLS: DestroyControls;
    WM_SYSCOLORCHANGE: DoPainterChanged(nil, True);
  end;
  inherited;
end;

function TdxDockingController.CanUpdateNC(AControl: TdxCustomDockControl): Boolean;
begin
  Result := (FUpdateNCLock = 0) and (FCalculatingControl = nil);
  if not Result then
  begin
    if FInvalidNC.IndexOf(AControl) = -1 then
      FInvalidNC.Add(AControl);
  end;
end;

function TdxDockingController.CanCalculateNC(AControl: TdxCustomDockControl): Boolean;
begin
  Result := (FUpdateNCLock = 0);
  if not Result then
  begin
    if FInvalidRedraw.IndexOf(AControl) = -1 then
    begin
      if disRedrawLocked in FInternalState then
        AControl.Perform(WM_SETREDRAW, Integer(False), 0);
//      SendMessage(AControl.Handle, WM_SETREDRAW, Integer(False), 0);
      FInvalidRedraw.Add(AControl);
    end;
    if FInvalidNCBounds.IndexOf(AControl) = -1 then
      FInvalidNCBounds.Add(AControl);
    if FInvalidNC.IndexOf(AControl) = -1 then
      FInvalidNC.Add(AControl);
  end;
end;

procedure TdxDockingController.DrawDockingSelection(ADockControl: TdxCustomDockControl;
  AZone: TdxZone; const APoint: TPoint; AErasing: Boolean);
var
  R, ARegionRect: TRect;
  AHandled: Boolean;
  ARegion: TcxRegion;
begin
  if (AZone <> nil) or ADockControl.AllowFloating then
  begin
    if AZone <> nil then
      R := AZone.GetDockingSelection(ADockControl)
    else
      R := ADockControl.GetFloatDockRect(APoint);

    AHandled := DoCustomDrawDockingSelection(ADockControl, cxScreenCanvas.Handle, AZone, R, AErasing);

    if not AHandled then
    begin
      ARegion := TcxRegion.Create;
      try
        ARegionRect := Rect(0, 0, cxRectWidth(R), cxRectHeight(R));
        if AZone <> nil then
          AZone.PrepareSelectionRegion(ARegion, ADockControl, ARegionRect)
        else
          ADockControl.PrepareSelectionRegion(ARegion, ARegionRect);
        FDragImage.DrawSizeFrame(R, ARegion);
      finally
        ARegion.Free;
      end;
    end;
  end;
end;

procedure TdxDockingController.DrawResizingSelection(ADockControl: TdxCustomDockControl;
  AZone: TdxZone; const APoint: TPoint; AErasing: Boolean);
var
  DesktopWindow: HWND;
  DC: HDC;
  OldBrush: HBrush;
  AHandled: Boolean;
begin
  DesktopWindow := GetDesktopWindow;
  DC := GetDCEx(DesktopWindow, 0, DCX_CACHE or DCX_LOCKWINDOWUPDATE);
  try
    AHandled := DoCustomDrawResizingSelection(ADockControl, DC, AZone, APoint, AErasing);
    if not AHandled then
    begin
      OldBrush := SelectObject(DC, SelectionBrush.Handle);
      AZone.DrawResizingSelection(DC, APoint);
      SelectObject(DC, OldBrush);
    end;
  finally
    ReleaseDC(DesktopWindow, DC);
  end;
end;

function TdxDockingController.PainterClass(AForm: TCustomForm): TdxDockControlPainterClass;
var
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    Result := AManager.PainterClass
  else Result := TdxDockControlPainter;
end;

procedure TdxDockingController.CalculateControls(AForm: TCustomForm);
var
  I: Integer;
begin
  BeginUpdateNC;
  try
    for I := 0 to DockControlCount - 1 do
      if ControlNeedUpdate(DockControls[I], AForm) then
        DockControls[I].Recalculate;
  finally
    EndUpdateNC;
  end;
end;

procedure TdxDockingController.InvalidateActiveDockControl;
begin
  if ActiveDockControl <> nil then
  begin
    // InvalidateCaptionArea
    ActiveDockControl.InvalidateCaptionArea;
    if ActiveDockControl.Container <> nil then
      ActiveDockControl.Container.InvalidateCaptionArea;
  end;
end;

procedure TdxDockingController.InvalidateControls(AForm: TCustomForm; ANeedRecalculate: Boolean);
var
  I: Integer;
begin
  BeginUpdateNC;
  try
    for I := 0 to DockControlCount - 1 do
      if ControlNeedUpdate(DockControls[I], AForm) then
         DockControls[I].InvalidateNC(ANeedRecalculate);
  finally
    EndUpdateNC;
  end;
end;

procedure TdxDockingController.CreatePainterColors(AForm: TCustomForm);
var
  I: Integer;
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
    AManager.PainterClass.CreateColors
  else for I := 0 to DockManagerCount - 1 do
    DockManagers[I].PainterClass.CreateColors;
end;

procedure TdxDockingController.RefreshPainterColors(AForm: TCustomForm);
var
  I: Integer;
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
  begin
    if AManager.FPainterClass <> nil then
      AManager.FPainterClass.RefreshColors;
  end
  else for I := 0 to DockManagerCount - 1 do
    if DockManagers[I].FPainterClass <> nil then
      DockManagers[I].FPainterClass.RefreshColors;
end;

procedure TdxDockingController.ReleasePainterColors(AForm: TCustomForm);
var
  I: Integer;
  AManager: TdxDockingManager;
begin
  AManager := FindManager(AForm);
  if AManager <> nil then
  begin
    if AManager.FPainterClass <> nil then
      AManager.FPainterClass.ReleaseColors;
  end
  else for I := 0 to DockManagerCount - 1 do
    if DockManagers[I].FPainterClass <> nil then
      DockManagers[I].FPainterClass.ReleaseColors;
end;

function TdxDockingController.IsUpdateNCLocked: Boolean;
begin
  Result := FUpdateNCLock > 0;
end;

procedure TdxDockingController.CheckTempBitmap(ARect: TRect);
const
  BitmapReserve = 10;
begin
  if FTempBitmap = nil then
    FTempBitmap := cxCreateBitmap(0, 0, cxDoubleBufferedBitmapPixelFormat);
  if FTempBitmap.Width < cxRectWidth(ARect) then
    FTempBitmap.Width := cxRectWidth(ARect) + BitmapReserve;
  if FTempBitmap.Height < cxRectHeight(ARect) then
    FTempBitmap.Height := cxRectHeight(ARect) + BitmapReserve;
end;

procedure TdxDockingController.ReleaseTempBitmap;
begin
  FreeAndNil(FTempBitmap);
end;

function TdxDockingController.GetIsDocking: Boolean;
begin
  Result := DockingDockControl <> nil;
end;

function TdxDockingController.GetDockControl(Index: Integer): TdxCustomDockControl;
begin
  Result := TdxCustomDockControl(FDockControls.Items[Index]);
end;

function TdxDockingController.GetDockControlCount: Integer;
begin
  Result := FDockControls.Count;
end;

function TdxDockingController.GetDockManager(Index: Integer): TdxDockingManager;
begin
  Result := TdxDockingManager(FDockManagers.Items[Index]);
end;

function TdxDockingController.GetDockManagerCount: Integer;
begin
  Result := FDockManagers.Count;
end;

function TdxDockingController.GetIsResizing: Boolean;
begin
  Result := ResizingDockControl <> nil;
end;

procedure TdxDockingController.SetActiveDockControl(Value: TdxCustomDockControl);

  procedure ActivateParent(AControl: TdxCustomDockControl);
  begin
    // SetActiveDockControl call recursive
    if (AControl <> nil) and not (AControl is TdxDockSite) then
      ActiveDockControl := AControl;
  end;

var
  AOldActiveSite: TdxCustomDockControl;
  ACallEvent: Boolean;
begin
  if FActiveDockControl <> Value then
  begin
    Inc(FActiveDockControlLockCount);
    try
      AOldActiveSite := FActiveDockControl;

      if Value <> nil then
        ActivateParent(Value.ParentDockControl);

      if (Value = nil) or Value.CanActive then
      begin
        FActiveDockControl := Value;

        ACallEvent := FActiveDockControlLockCount = 1;
        if AOldActiveSite <> nil then
          AOldActiveSite.DoActiveChanged(False, ACallEvent);
        if FActiveDockControl <> nil then
          FActiveDockControl.DoActiveChanged(True, ACallEvent);
        if AOldActiveSite <> FActiveDockControl then
          DoActiveDockControlChanged(FActiveDockControl, ACallEvent);
      end;
      FActivatingDockControl := nil;
    finally
      Dec(FActiveDockControlLockCount);
    end;
  end;
end;

function TdxDockingController.IsParentForFloatDockSite(AParentForm: TCustomForm;
  AFloatDockSite: TdxFloatDockSite): Boolean;
begin
  Result := (AParentForm = nil) or (AParentForm = AFloatDockSite.ParentForm) or
    IsMDIForm(AParentForm) and IsMDIChild(AFloatDockSite.ParentForm);
end;

procedure TdxDockingController.BringToFrontFloatForms(AParentForm: TCustomForm; ATopMost: Boolean);
var
  I: Integer;
  AControl: TdxFloatDockSite;
begin
  for I := 0 to DockControlCount - 1 do
  begin
    if DockControls[I].IsDesigning then continue;
    if DockControls[I].IsDestroying then continue;
    if DockControls[I] is TdxFloatDockSite then
    begin
      AControl := DockControls[I] as TdxFloatDockSite;
      if (AParentForm = nil) or (AParentForm = AControl.ParentForm) then
        AControl.FloatForm.BringToFront(ATopMost);
    end;
  end;
end;

procedure TdxDockingController.UpdateVisibilityFloatForms(AParentForm: TCustomForm; AShow: Boolean);

  procedure FloatFormsHide;
  var
    I: Integer;
    AControl: TdxFloatDockSite;
  begin
    for I := 0 to DockControlCount - 1 do
    begin
      if DockControls[I] is TdxFloatDockSite then
      begin
        AControl := DockControls[I] as TdxFloatDockSite;
        if IsParentForFloatDockSite(AParentForm, AControl) and (AControl.FloatForm <> nil) {bug in Delphi 2005} then
          AControl.FloatForm.HideWindow;
      end;
    end;
  end;

  procedure FloatFormsShow;
  var
    I: Integer;
    AControl: TdxFloatDockSite;
  begin
    for I := 0 to DockControlCount - 1 do
    begin
      if DockControls[I] is TdxFloatDockSite then
      begin
        AControl := DockControls[I] as TdxFloatDockSite;
        if AControl.Visible and IsParentForFloatDockSite(AParentForm, AControl) and (AControl.FloatForm <> nil) then
          AControl.FloatForm.ShowWindow;
      end;
    end;
  end;

begin
  if AShow then
    FloatFormsShow
  else
    FloatFormsHide;
end;

procedure TdxDockingController.UpdateEnableStatusFloatForms(AParentForm: TCustomForm; AEnable: Boolean);
var
  I: Integer;
  AControl: TdxFloatDockSite;
begin
  for I := 0 to DockControlCount - 1 do
  begin
    if DockControls[I] is TdxFloatDockSite then
    begin
      AControl := DockControls[I] as TdxFloatDockSite;
      if IsParentForFloatDockSite(AParentForm, AControl) and (AControl.FloatForm <> nil) {bug in Delphi 2005} then
        EnableWindow(AControl.FloatForm.Handle, AEnable);
    end;
  end;
end;

procedure TdxDockingController.StartDocking(AControl: TdxCustomDockControl; const APoint: TPoint);
begin
  FDragImage := TdxDockingDragImage.Create(AControl.ControllerSelectionFrameWidth);
  FDragImage.FillSelection := doFillDockingSelection in AControl.ControllerOptions;
  FDragImage.PopupParent := AControl.PopupParent;
  if doFillDockingSelection in AControl.ControllerOptions then
  begin
    FDragImage.AlphaBlend := True;
    FDragImage.AlphaBlendValue := 100;
    FDragImage.Canvas.Brush.Color := clHighlight
  end
  else
  begin
    FDragImage.AlphaBlend := False;
    FDragImage.Canvas.Brush := SelectionBrush;
  end;
  FDragImage.Show;
end;

procedure TdxDockingController.Docking(AControl: TdxCustomDockControl; const APoint: TPoint);
begin

end;

procedure TdxDockingController.EndDocking(AControl: TdxCustomDockControl; const APoint: TPoint);
begin
  FreeAndNil(FDragImage);
end;

procedure TdxDockingController.DockControlLoaded(AControl: TdxCustomDockControl);
begin
  if FLoadedForms.IndexOf(AControl.ParentForm) = -1 then
    FLoadedForms.Add(AControl.ParentForm);
end;

procedure TdxDockingController.DockManagerLoaded(AParentForm: TCustomForm);
begin
  FLoadedForms.Remove(AParentForm);
end;

function TdxDockingController.IndexOfDockControl(AControl: TdxCustomDockControl): Integer;
begin
  Result := FDockControls.IndexOf(AControl);
end;

procedure TdxDockingController.RegisterDestroyedDockControl(AControl: TdxCustomDockControl);
begin
  FDestroyedDockControls.Add(AControl);
  PostMessage(Handle, WM_DESTROYCONTROLS, 0, 0);
end;

procedure TdxDockingController.RegisterDockControl(AControl: TdxCustomDockControl);
begin
  FDockControls.Add(AControl);
  if Assigned(FOnRegisterDockControl) then
    FOnRegisterDockControl(AControl);
end;

procedure TdxDockingController.UnregisterDockControl(AControl: TdxCustomDockControl);
begin
  if Assigned(FOnUnregisterDockControl) then
    FOnUnregisterDockControl(AControl);
  if AControl = FActivatingDockControl then
    FActivatingDockControl := nil;
  if AControl = FDockingDockControl then
    FDockingDockControl := nil;
  if AControl = FResizingDockControl then
    FResizingDockControl := nil;
  FDockControls.Remove(AControl);
  FDestroyedDockControls.Remove(AControl);
  FInvalidRedraw.Remove(AControl);
  FInvalidNC.Remove(AControl);
  FInvalidNCBounds.Remove(AControl);
  if FActiveDockControl = AControl then
    FActiveDockControl := nil;
end;

procedure TdxDockingController.SetApplicationActive(AValue: Boolean);
begin
  if AValue <> FApplicationActive then
  begin
    FApplicationActive := AValue;
    InvalidateActiveDockControl;
  end;
end;

procedure TdxDockingController.SetSelectionBrush(Value: TBrush);
begin
  FSelectionBrush.Assign(Value);
end;

{ TdxCustomDockControlProperties }

constructor TdxCustomDockControlProperties.Create(AOwner: TdxDockingManager);
begin
  FOwner := AOwner;
  FAllowDock := dxDockingDefaultDockingTypes;
  FAllowDockClients := dxDockingDefaultDockingTypes;
  FAllowFloating := True;
  FCaptionButtons := dxDockinkDefaultCaptionButtons;
  FColor := clBtnFace;
  FDockable := True;
  FFont := TFont.Create;
  FImageIndex := -1;
  FManagerColor := True;
  FManagerFont := True;
  FShowCaption := True;
  FShowHint := False;
  FTag := 0;
end;

destructor TdxCustomDockControlProperties.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TdxCustomDockControlProperties.AssignTo(Dest: TPersistent);
var
  AControl: TdxCustomDockControl;
  AControlProperties: TdxCustomDockControlProperties;
begin
  if Dest is TdxCustomDockControl then
  begin
    AControl := Dest as TdxCustomDockControl;
    AControl.AllowDock := FAllowDock;
    AControl.AllowDockClients := FAllowDockClients;
    AControl.AllowFloating := FAllowFloating;
    AControl.Caption := FCaption;
    AControl.CaptionButtons := FCaptionButtons;
    AControl.Dockable := FDockable;
    AControl.ImageIndex := FImageIndex;
    AControl.ShowCaption := FShowCaption;
    AControl.Color := FColor;
    AControl.Cursor := FCursor;
    AControl.Font := FFont;
    AControl.Hint := FHint;
    AControl.ManagerColor := FManagerColor;
    AControl.ManagerFont := FManagerFont;
    AControl.PopupMenu := FPopupMenu;
    AControl.ShowHint := FShowHint;
    AControl.Tag := FTag;
  end
  else if Dest is TdxCustomDockControlProperties then
  begin
    AControlProperties := Dest as TdxCustomDockControlProperties;
    AControlProperties.AllowDock := FAllowDock;
    AControlProperties.AllowDockClients := FAllowDockClients;
    AControlProperties.AllowFloating := FAllowFloating;
    AControlProperties.Caption := FCaption;
    AControlProperties.CaptionButtons := FCaptionButtons;
    AControlProperties.Dockable := FDockable;
    AControlProperties.ImageIndex := FImageIndex;
    AControlProperties.ShowCaption := FShowCaption;
    AControlProperties.Color := FColor;
    AControlProperties.Cursor := FCursor;
    AControlProperties.Font := FFont;
    AControlProperties.Hint := FHint;
    AControlProperties.ManagerColor := FManagerColor;
    AControlProperties.ManagerFont := FManagerFont;
    AControlProperties.PopupMenu := FPopupMenu;
    AControlProperties.ShowHint := FShowHint;
    AControlProperties.Tag := FTag;
  end
  else inherited;
end;

function  TdxCustomDockControlProperties.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TdxCustomDockControlProperties.IsColorStored: Boolean;
begin
  Result := not ManagerColor;
end;

function TdxCustomDockControlProperties.IsFontStored: Boolean;
begin
  Result := not ManagerFont;
end;

procedure TdxCustomDockControlProperties.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    if not (csLoading in FOwner.ComponentState)then
      FManagerColor := False;
  end;
end;

procedure TdxCustomDockControlProperties.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
  if not (csLoading in FOwner.ComponentState)then
    FManagerFont := False;
end;

procedure TdxCustomDockControlProperties.SetManagerColor(const Value: Boolean);
begin
  if FManagerColor <> Value then
  begin
    if Value and not (csLoading in FOwner.ComponentState) then
      FColor := FOwner.Color;
    FManagerColor := Value;
  end;
end;

procedure TdxCustomDockControlProperties.SetManagerFont(const Value: Boolean);
begin
  if FManagerFont <> Value then
  begin
    if Value and not (csLoading in FOwner.ComponentState) then
      FFont.Assign(FOwner.Font);
    FManagerFont := Value;
  end;
end;

{ TdxTabContainerDockSiteProperties }

constructor TdxTabContainerDockSiteProperties.Create(AOwner: TdxDockingManager);
begin
  inherited Create(AOwner);
  FTabsPosition := tctpBottom;
  FTabsScroll := True;
end;

procedure TdxTabContainerDockSiteProperties.AssignTo(Dest: TPersistent);
var
  AContainer: TdxTabContainerDockSite;
  AContainerProperties: TdxTabContainerDockSiteProperties;
begin
  if Dest is TdxTabContainerDockSite then
  begin
    AContainer := Dest as TdxTabContainerDockSite;
    AContainer.TabsPosition := FTabsPosition;
    AContainer.TabsScroll := FTabsScroll;
  end
  else if Dest is TdxTabContainerDockSiteProperties then
  begin
    AContainerProperties := Dest as TdxTabContainerDockSiteProperties;
    AContainerProperties.TabsPosition := FTabsPosition;
    AContainerProperties.TabsScroll := FTabsScroll;
  end;
  inherited;
end;

{ TdxDockingManager }

constructor TdxDockingManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAutoHideInterval := dxAutoHideInterval;
  FAutoHideMovingInterval := dxAutoHideMovingInterval;
  FAutoHideMovingSize := dxAutoHideMovingSize;
  FAutoShowInterval := dxAutoShowInterval;
  FChangeLink := TChangeLink.Create;
  FChangeLink.OnChange := DoOnImagesChanged;
  FColor := clBtnFace;
  FDefaultSitesPropertiesList := TList.Create;
  FDockZonesWidth := dxDockZonesWidth;
  CreateDefaultSitesProperties;
  FFont := TFont.Create;
  FFont.OnChange := DoOnFontChanged;
  FLookAndFeel := TcxLookAndFeel.Create(Self);
  FLookAndFeel.OnChanged := DoOnLFChanged;
  FOptions := dxDockingDefaultOptions;
  FResizeZonesWidth := dxResizeZonesWidth;
  FSelectionFrameWidth := dxSelectionFrameWidth;
  FTabsScrollInterval := dxTabsScrollInterval;
  FUseDefaultSitesProperties := True;
  FViewStyle := vsStandard;
  dxDockingController.RegisterManager(Self);
end;

destructor TdxDockingManager.Destroy;
begin
  dxDockingController.UnregisterManager(Self);
  FLookAndFeel.Free;
  FFont.Free;
  DestroyDefaultSitesProperties;
  FDefaultSitesPropertiesList.Free;
  FChangeLink.Free;
  inherited;
end;

procedure TdxDockingManager.LoadLayoutFromIniFile(AFileName: string);
begin
  dxDockingController.LoadLayoutFromIniFile(AFileName, ParentForm);
end;

procedure TdxDockingManager.LoadLayoutFromRegistry(ARegistryPath: string);
begin
  dxDockingController.LoadLayoutFromRegistry(ARegistryPath, ParentForm);
end;

procedure TdxDockingManager.LoadLayoutFromStream(AStream: TStream);
begin
  dxDockingController.LoadLayoutFromStream(AStream, ParentForm);
end;

procedure TdxDockingManager.SaveLayoutToIniFile(AFileName: string);
begin
  dxDockingController.SaveLayoutToIniFile(AFileName, ParentForm);
end;

procedure TdxDockingManager.SaveLayoutToRegistry(ARegistryPath: string);
begin
  dxDockingController.SaveLayoutToRegistry(ARegistryPath, ParentForm);
end;

procedure TdxDockingManager.SaveLayoutToStream(AStream: TStream);
begin
  dxDockingController.SaveLayoutToStream(AStream, ParentForm);
end;

procedure TdxDockingManager.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited;
  if (Operation = opRemove) and not IsDestroying then
  begin
    if AComponent = Images then
      Images := nil;
    for I := 0 to DefaultSitesPropertiesCount - 1 do
      if AComponent = DefaultSitesProperties[I].PopupMenu then
        DefaultSitesProperties[I].PopupMenu := nil;
  end;
end;

procedure TdxDockingManager.Loaded;
begin
  inherited;
  UpdateDefaultSitesPropertiesColor;
  UpdateDefaultSitesPropertiesFont;
  dxDockingController.DockManagerLoaded(ParentForm);
  dxDockingController.DoManagerChanged(ParentForm);
end;

function TdxDockingManager.IsLoading: Boolean;
begin
  Result := csLoading in ComponentState;
end;

function TdxDockingManager.IsDestroying: Boolean;
begin
  Result := csDestroying in ComponentState;
end;

procedure TdxDockingManager.DoColorChanged;
begin
  UpdateDefaultSitesPropertiesColor;
  dxDockingController.DoColorChanged(ParentForm);
end;

procedure TdxDockingManager.DoFontChanged;
begin
  UpdateDefaultSitesPropertiesFont;
  dxDockingController.DoFontChanged(ParentForm);
end;

procedure TdxDockingManager.CreatePainterClass(AssignDefaultStyle: Boolean);
begin
  PainterClass.CreateColors;
  if AssignDefaultStyle then
  begin
    PainterClass.AssignDefaultColor(Self);
    PainterClass.AssignDefaultFont(Self);
  end;
end;

function TdxDockingManager.GetPainterClass: TdxDockControlPainterClass;
const
  AStyles: array[TcxLookAndFeelKind] of TdxDockingViewStyle = (
    vsNET, vsStandard, vsNET{$IFDEF DXVER500}, vsOffice11{$ENDIF});
  APainterClasses: array[TdxDockingViewStyle] of TdxDockControlPainterClass = (
    TdxDockControlPainter, TdxDockControlNETPainter, TdxDockControlOfficePainter,
    TdxDockControlXPPainter, TdxDockControlPainter);
var
  AUseSkinPainter: Boolean;
  AViewStyle: TdxDockingViewStyle;
begin
  if FPainterClass = nil then
  begin
    AUseSkinPainter := False;
    if ViewStyle = vsUseLookAndFeel then
    begin
      if LookAndFeel.NativeStyle and AreVisualStylesAvailable([]) then
        AViewStyle := vsXP
      else
        AViewStyle := AStyles[LookAndFeel.Kind];
      AUseSkinPainter := LookAndFeel.SkinPainter <> nil;  
    end
    else
      AViewStyle := ViewStyle;

    if AUseSkinPainter and (CustomSkinPainterClass <> nil) then
      FPainterClass := CustomSkinPainterClass
    else
      FPainterClass := APainterClasses[AViewStyle];
  end;
  Result := FPainterClass;
end;

procedure TdxDockingManager.ReleasePainterClass;
begin
  if FPainterClass <> nil then
  begin
    FPainterClass.ReleaseColors;
    FPainterClass := nil;
  end;
end;

procedure TdxDockingManager.CreateDefaultSitesProperties;
begin
  if FDefaultSitesPropertiesList = nil then exit;
  FDefaultSitesPropertiesList.Add(TdxLayoutDockSiteProperties.Create(Self));
  FDefaultSitesPropertiesList.Add(TdxFloatDockSiteProperties.Create(Self));
  FDefaultSitesPropertiesList.Add(TdxSideContainerDockSiteProperties.Create(Self));
  FDefaultSitesPropertiesList.Add(TdxSideContainerDockSiteProperties.Create(Self));
  FDefaultSitesPropertiesList.Add(TdxTabContainerDockSiteProperties.Create(Self));
end;

procedure TdxDockingManager.DestroyDefaultSitesProperties;
var
  I: Integer;
begin
  if FDefaultSitesPropertiesList = nil then exit;
  for I := 0 to FDefaultSitesPropertiesList.Count - 1 do
    TdxCustomDockControlProperties(FDefaultSitesPropertiesList[I]).Free;
  FDefaultSitesPropertiesList.Clear;
end;

procedure TdxDockingManager.UpdateDefaultSitesPropertiesColor;
var
  I: Integer;
begin
  for I := 0 to DefaultSitesPropertiesCount - 1 do
    if DefaultSitesProperties[I].ManagerColor then
    begin
      DefaultSitesProperties[I].Color := Color;
      DefaultSitesProperties[I].FManagerColor := True;
    end;
end;

procedure TdxDockingManager.UpdateDefaultSitesPropertiesFont;
var
  I: Integer;
begin
  for I := 0 to DefaultSitesPropertiesCount - 1 do
    if DefaultSitesProperties[I].ManagerFont then
    begin
      DefaultSitesProperties[I].Font := Font;
      DefaultSitesProperties[I].FManagerFont := True;
    end;
end;

procedure TdxDockingManager.DoOnImagesChanged(Sender: TObject);
begin
  if not IsLoading then
    dxDockingController.DoImagesChanged(ParentForm);
end;

procedure TdxDockingManager.DoOnFontChanged(Sender: TObject);
begin
  if not IsLoading then
    DoFontChanged;
end;

procedure TdxDockingManager.DoOnLFChanged(Sender: TcxLookAndFeel; AChangedValues: TcxLookAndFeelValues);
begin
  if not IsLoading and (ViewStyle = vsUseLookAndFeel) then
    dxDockingController.DoPainterChanged(ParentForm, True);
end;

function TdxDockingManager.IsDefaultSitePropertiesStored: Boolean;
begin
  Result := FUseDefaultSitesProperties;
end;

function TdxDockingManager.GetDefaultSiteProperties(Index: Integer): TdxCustomDockControlProperties;
begin
  if (0 <= Index) and (Index < FDefaultSitesPropertiesList.Count) then
    Result := TdxCustomDockControlProperties(FDefaultSitesPropertiesList[Index])
  else Result := nil;
end;

function TdxDockingManager.GetDefaultSitesPropertiesCount: Integer;
begin
  Result := FDefaultSitesPropertiesList.Count;
end;

function TdxDockingManager.GetDefaultLayoutSiteProperties: TdxLayoutDockSiteProperties;
begin
  Result := DefaultSitesProperties[0] as TdxLayoutDockSiteProperties;
end;

function TdxDockingManager.GetDefaultFloatSiteProperties: TdxFloatDockSiteProperties;
begin
  Result := DefaultSitesProperties[1] as TdxFloatDockSiteProperties;
end;

function TdxDockingManager.GetDefaultHorizContainerSiteProperties: TdxSideContainerDockSiteProperties;
begin
  Result := DefaultSitesProperties[2] as TdxSideContainerDockSiteProperties;
end;

function TdxDockingManager.GetDefaultVertContainerSiteProperties: TdxSideContainerDockSiteProperties;
begin
  Result := DefaultSitesProperties[3] as TdxSideContainerDockSiteProperties;
end;

function TdxDockingManager.GetDefaultTabContainerSiteProperties: TdxTabContainerDockSiteProperties;
begin
  Result := DefaultSitesProperties[4] as TdxTabContainerDockSiteProperties;
end;

function TdxDockingManager.GetParentForm: TCustomForm;
begin
  if Owner is TCustomForm then
    Result := Owner as TCustomForm
  else
    Result := nil;
end;

procedure TdxDockingManager.SetColor(const Value: TColor);
begin
  if FColor <> Value then
  begin
    FColor := Value;
    if not IsLoading then
      DoColorChanged;
  end;
end;

procedure TdxDockingManager.SetDefaultLayoutSiteProperties(Value: TdxLayoutDockSiteProperties);
begin
  (DefaultSitesProperties[0] as TdxLayoutDockSiteProperties).Assign(Value);
end;

procedure TdxDockingManager.SetDefaultFloatSiteProperties(Value: TdxFloatDockSiteProperties);
begin
  (DefaultSitesProperties[1] as TdxFloatDockSiteProperties).Assign(Value);
end;

procedure TdxDockingManager.SetDefaultHorizContainerSiteProperties(Value: TdxSideContainerDockSiteProperties);
begin
  (DefaultSitesProperties[2] as TdxSideContainerDockSiteProperties).Assign(Value);
end;

procedure TdxDockingManager.SetDefaultVertContainerSiteProperties(Value: TdxSideContainerDockSiteProperties);
begin
  (DefaultSitesProperties[3] as TdxSideContainerDockSiteProperties).Assign(Value);
end;

procedure TdxDockingManager.SetDefaultTabContainerSiteProperties(Value: TdxTabContainerDockSiteProperties);
begin
  (DefaultSitesProperties[3] as TdxTabContainerDockSiteProperties).Assign(Value);
end;

procedure TdxDockingManager.SetDockZonesWidth(const Value: Integer);
begin
  if FDockZonesWidth <> Value then
  begin
    FDockZonesWidth := Value;
    dxDockingController.DoZonesWidthChanged(ParentForm);
  end;
end;

procedure TdxDockingManager.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TdxDockingManager.SetImages(const Value: TCustomImageList);
begin
  cxSetImageList(Value, FImages, FChangeLink, Self);
end;

procedure TdxDockingManager.SetLookAndFeel(Value: TcxLookAndFeel);
begin
  FLookAndFeel.Assign(Value);
end;

procedure TdxDockingManager.SetOptions(const Value: TdxDockingOptions);
begin
  if FOptions <> Value then
  begin
    FOptions := Value;
    if not IsLoading then
      dxDockingController.DoOptionsChanged(ParentForm);
  end;
end;

procedure TdxDockingManager.SetResizeZonesWidth(const Value: Integer);
begin
  if FResizeZonesWidth <> Value then
  begin
    FResizeZonesWidth := Value;
    dxDockingController.DoZonesWidthChanged(ParentForm);
  end;
end;

procedure TdxDockingManager.SetViewStyle(const Value: TdxDockingViewStyle);
begin
  if FViewStyle <> Value then
  begin
    FViewStyle := Value;
    if not IsLoading then
    begin
      dxDockingController.DoPainterChanged(ParentForm, True);
      if Assigned(FOnViewChanged) then
        FOnViewChanged(Self);
    end;
  end;
end;

initialization
  RegisterClasses([TdxLayoutDockSite, TdxContainerDockSite, TdxTabContainerDockSite,
    TdxSideContainerDockSite, TdxVertContainerDockSite, TdxHorizContainerDockSite,
    TdxFloatDockSite, TdxDockSite, TdxDockingManager]);
  cxControls.cxGetParentFormForDocking := GetParentFormForDocking;

finalization
  FUnitIsFinalized := True;
  cxControls.cxGetParentFormForDocking := nil;
  FreeAndNil(FDockingController);

end.
