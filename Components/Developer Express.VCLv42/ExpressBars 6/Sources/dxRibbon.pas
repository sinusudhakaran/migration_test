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

unit dxRibbon;

{$I cxVer.inc}

interface

uses
  Windows, Forms, Messages, Classes, SysUtils, Graphics,
  Controls, ExtCtrls, ImgList, IniFiles, Contnrs, 
  dxCore, cxClasses, cxGraphics, cxControls, cxContainer, cxLookAndFeels, dxBar,
  dxBarSkin, dxFading, cxAccessibility, dxBarAccessibility,
  dxRibbonSkins, dxRibbonFormCaptionHelper, dxRibbonForm;

const
  dxRibbonFormCaptionMinWidth         = 50;
  dxRibbonFormCaptionTextSpace        = 4;
  dxRibbonTabMinWidth                 = 28;
  dxRibbonTabTextOffset               = 5;
  dxRibbonTabIndent                   = 17;
  dxRibbonOptimalTabSpace             = dxRibbonTabTextOffset * 2 + dxRibbonTabIndent;
  dxRibbonTabSeparatorVisibilityLimit = dxRibbonTabMinWidth div 2;
  dxRibbonApplicationButtonIndent     = 4;
  dxRibbonOwnerMinimalWidth: Integer  = 300;
  dxRibbonOwnerMinimalHeight: Integer = 250;
  dxRibbonScrollDelay                 = 400;
  dxRibbonScrollInterval              = 20;

  dxRibbonGroupRowCount = 3;

  CM_SELECTAPPMENUFIRSTITEMCONTROL = WM_DX + 25;
  CM_SHOWKEYTIPS = WM_DX + 26;

type
  TdxBarApplicationMenu = class;
  TdxCustomRibbon = class;
  TdxRibbonApplicationButtonFadingHelper = class;
  TdxRibbonElementCustomFadingHelper = class;
  TdxRibbonGroupBarControl = class;
  TdxRibbonGroupBarControlViewInfo = class;
  TdxRibbonGroupsDockControl = class;
  TdxRibbonGroupsDockControlSite = class;
  TdxRibbonGroupsDockControlSiteViewInfo = class;
  TdxRibbonGroupsDockControlViewInfo = class;
  TdxRibbonGroupsDockControlViewInfoClass = class of TdxRibbonGroupsDockControlViewInfo;
  TdxRibbonGroupsScrollButtonFadingHelper = class;
  TdxRibbonHelpButtonFadingHelper = class;
  TdxRibbonMDIButtonFadingHelper = class;
  TdxRibbonQuickAccessBarControlViewInfo = class;
  TdxRibbonQuickAccessDockControl = class;
  TdxRibbonQuickAccessGroupButton = class;
  TdxRibbonQuickAccessToolbar = class;
  TdxRibbonTab = class;
  TdxRibbonCollapsedGroupPopupBarControl = class;
  TdxRibbonTabGroup = class;
  TdxRibbonTabPainterClass = class of TdxRibbonTabPainter;
  TdxRibbonTabScrollButtonFadingHelper = class;
  TdxRibbonTabViewInfo = class;
  TdxRibbonViewInfo = class;

  EdxRibbonException = class(EdxException);

  IdxRibbonFormStatusBarDraw = interface
    ['{E6AA56DF-B87A-4D98-98CF-B41BA751594D}']
    function GetActive(AForm: TCustomForm): Boolean;
    function GetHeight: Integer;
    function GetIsRaised(ALeft: Boolean): Boolean;
  end;

  IdxRibbonFormNonClientDraw = interface
    ['{0A28260B-C352-4704-A88B-44DD8461955C}']
    procedure Add(AObject: TObject);
    procedure Remove(AObject: TObject);
  end;

  { TdxDesignSelectionHelper }

  TdxDesignSelectionHelper = class(TInterfacedObject,
    IdxBarSelectableItem
  )
  private
    FOwner: TPersistent;
    FRibbon: TdxCustomRibbon;
    FParent: TPersistent;
  protected
    //IdxBarSelectableItem
    function CanDelete(ADestruction: Boolean = False): Boolean;
    procedure DeleteSelection(var AReference: IdxBarSelectableItem; ADestruction: Boolean);
    procedure ExecuteCustomizationAction(ABasicAction: TdxBarCustomizationAction);
    function GetBarManager: TdxBarManager;
    function GetInstance: TPersistent;
    procedure GetMasterObjects(AList: TdxObjectList);
    function GetNextSelectableItem: IdxBarSelectableItem;
    function GetSelectableParent: TPersistent;
    function GetSelectionStatus: TdxBarSelectionStatus;
    function GetSupportedActions: TdxBarCustomizationActions;
    procedure Invalidate;
    function IsComplex: Boolean;
    function IsComponentSelected: Boolean;
    procedure SelectComponent(ASelectionOperation: TdxBarSelectionOperation = soExclusive);
    function SelectParentComponent: Boolean;
    procedure SelectionChanged;
  public
    constructor Create(ARibbon: TdxCustomRibbon; AOwner: TPersistent; AParent: TPersistent);
  end;

  { TdxRibbonTabPainter }

  TdxRibbonTabPainter = class
  private
    FColorScheme: TdxCustomRibbonSkin;
  protected
    procedure DrawBackground(ACanvas: TcxCanvas; const ABounds: TRect;
      AState: TdxRibbonTabState); virtual;
    procedure DrawTabSeparator(ACanvas: TcxCanvas; const ABounds: TRect;
      Alpha: Byte); virtual;
    procedure DrawText(ACanvas: TcxCanvas; const ABounds: TRect;
      const AText: string; AHasSeparator: Boolean); virtual;
  public
    constructor Create(AColorScheme: TdxCustomRibbonSkin);
    property ColorScheme: TdxCustomRibbonSkin read FColorScheme;
  end;

  { TdxRibbonPainter }

  TdxRibbonPainterClass = class of TdxRibbonPainter;

  TdxRibbonPainter = class
  private
    FRibbon: TdxCustomRibbon;
    function GetViewInfo: TdxRibbonViewInfo;
    function GetColorScheme: TdxCustomRibbonSkin;
  protected
    procedure DrawEmptyRibbon(ACanvas: TcxCanvas);
    function GetFormIconHandle: HICON;
  public
    constructor Create(ARibbon: TdxCustomRibbon); virtual;

    //non-client routines
    procedure DrawRibbonFormCaption(ACanvas: TcxCanvas; const ABounds: TRect;
      const AData: TdxRibbonFormData); virtual;
    procedure DrawRibbonFormBorderIcon(ACanvas: TcxCanvas; const ABounds: TRect;
      AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState); virtual;
    procedure DrawRibbonFormBorders(ACanvas: TcxCanvas;
      const ABordersWidth: TRect; const AData: TdxRibbonFormData); virtual;
    //client routines
    procedure DrawApplicationButton(ACanvas: TcxCanvas; const ABounds: TRect; AState: TdxApplicationButtonState); virtual;
    procedure DrawApplicationButtonGlyph(ACanvas: TcxCanvas; const ABounds: TRect; AGlyph: TBitmap; AStretch: Boolean); virtual;
    procedure DrawBackground(ACanvas: TcxCanvas; const ABounds: TRect); virtual;
    procedure DrawBottomBorder(ACanvas: TcxCanvas);
    procedure DrawDefaultFormIcon(ACanvas: TcxCanvas; const ABounds: TRect);
    procedure DrawGlowingText(DC: HDC; const AText: string;
      AFont: TFont; const ABounds: TRect; AColor: TColor; AFlags: DWORD);

    procedure DrawGroupsArea(ACanvas: TcxCanvas; const ABounds: TRect); virtual;
    procedure DrawGroupsScrollButton(ACanvas: TcxCanvas; const ABounds: TRect;
      ALeft, APressed, AHot: Boolean); virtual;
    procedure DrawGroupsScrollButtonArrow(ACanvas: TcxCanvas;
      const ABounds: TRect; ALeft: Boolean); virtual;
    procedure DrawRibbonFormCaptionText(ACanvas: TcxCanvas; const ABounds: TRect;
      const ADocumentName, ACaption: string; const AData: TdxRibbonFormData); virtual;
    procedure DrawRibbonGlassFormCaptionText(ACanvas: TcxCanvas; const ABounds: TRect;
      const ADocumentName, ACaption: string; AIsActive: Boolean); virtual;
    procedure DrawQuickAccessToolbar(ACanvas: TcxCanvas; const ABounds: TRect;
      AIsActive: Boolean); virtual;
    procedure DrawTabScrollButton(ACanvas: TcxCanvas; const ABounds: TRect;
      ALeft, APressed, AHot: Boolean); virtual;
    procedure DrawTabScrollButtonGlyph(ACanvas: TcxCanvas;
      const ABounds: TRect; ALeft: Boolean); virtual;
    procedure DrawHelpButton(ACanvas: TcxCanvas; const ABounds: TRect;
      AState: TdxBorderIconState);
    procedure DrawMDIButton(ACanvas: TcxCanvas; const ABounds: TRect;
      AButton: TdxBarMDIButton; AState: TdxBorderIconState); virtual;

    property ColorScheme: TdxCustomRibbonSkin read GetColorScheme;
    property Ribbon: TdxCustomRibbon read FRibbon;
    property ViewInfo: TdxRibbonViewInfo read GetViewInfo;
  end;

  { TdxRibbonTabViewInfo }

  TdxRibbonTabViewInfoClass = class of TdxRibbonTabViewInfo;

  TdxRibbonTabViewInfo = class
  private
    FPainter: TdxRibbonTabPainter;
    FTab: TdxRibbonTab;
    function GetCanvas: TcxCanvas;
    function GetFont: TFont;
  protected
    FCanHasSeparator: Boolean;
    FMinWidth: Integer;
    FOptimalWidth: Integer;
    FSeparatorAlphaValue: Integer;
    FSeparatorBounds: TRect;
    FTextBounds: TRect;
    FTextWidth: Integer;
    FWidth: Integer;
    procedure DrawBackground(ACanvas: TcxCanvas);
    procedure CalculateWidths; virtual;
    function GetTextBounds: TRect; virtual;
    function GetSeparatorBounds: TRect; virtual;
    function GetState: TdxRibbonTabState; virtual;
    function GetPainterClass: TdxRibbonTabPainterClass; virtual;
    function IsSelected: Boolean;
    function PrepareFadeImage(ADrawHot: Boolean): TcxBitmap;

    property Canvas: TcxCanvas read GetCanvas;
    property Painter: TdxRibbonTabPainter read FPainter;
    property Width: Integer read FWidth;
  public
    Bounds: TRect;
    constructor Create(ATab: TdxRibbonTab); virtual;
    destructor Destroy; override;
    procedure Calculate(const ABounds: TRect; ASeparatorAlpha: Byte); virtual;
    function HasSeparator: Boolean;
    procedure Paint(ACanvas: TcxCanvas);
    property Font: TFont read GetFont;
    property MinWidth: Integer read FMinWidth;
    property OptimalWidth: Integer read FOptimalWidth;
    property SeparatorAlphaValue: Integer read FSeparatorAlphaValue;
    property SeparatorBounds: TRect read FSeparatorBounds;
    property State: TdxRibbonTabState read GetState;
    property Tab: TdxRibbonTab read FTab;
    property TextBounds: TRect read FTextBounds;
    property TextWidth: Integer read FTextWidth;
  end;

  { TdxRibbonTabViewInfos }

  TdxRibbonViewInfoClass = class of TdxRibbonViewInfo;

  TdxRibbonHitTest = (rhtNone, rhtTab, rhtApplicationMenu,
    rhtTabScrollLeft, rhtTabScrollRight, rhtGroupScrollLeft, rhtGroupScrollRight, //keep order
    rhtHelpButton, rhtMDIMinimizeButton, rhtMDIRestoreButton, rhtMDICloseButton); //keep order

  TdxRibbonHitInfo = record
    HitTest: TdxRibbonHitTest;
    Tab: TdxRibbonTab;
  end;

  TdxRibbonScrollButton = (rsbLeft, rsbRight);
  TdxRibbonScrollButtons = set of TdxRibbonScrollButton;

  TdxRibbonTabsViewInfo = class(TList)
  private
    FBounds: TRect;
    FHasButtonOnRight: Boolean;
    FNeedShowHint: Boolean;
    FOwner: TdxRibbonViewInfo;
    FScrollButtonBounds: array[TdxRibbonScrollButton] of TRect;
    FScrollButtonFadingHelpers: array[TdxRibbonScrollButton] of TdxRibbonTabScrollButtonFadingHelper;
    FScrollButtons: TdxRibbonScrollButtons;
    FScrollPosition: Integer;
    FScrollWidth: Integer;
    FSeparatorAlpha: Byte;
    FTotalMinimalWidth: Integer;
    FTotalOptimalWidth: Integer;
    procedure CalculateScrollButtons;
    procedure CheckScrollPosition(var Value: Integer);
    function GetLongestTabWidth: Integer;
    function GetPainter: TdxRibbonPainter;
    function GetRealMinItemWidth(Index: Integer): Integer;
    function GetScrollButtonBounds(Index: TdxRibbonScrollButton): TRect;
    function GetScrollButtonHot(Index: TdxRibbonScrollButton): Boolean;
    function GetScrollButtonPressed(Index: TdxRibbonScrollButton): Boolean;
    function GetScrollWidth: Integer;
    function GetTabViewInfo(Index: Integer): TdxRibbonTabViewInfo;
    procedure RemoveScrolling;
    procedure SetScrollPosition(Value: Integer);
  protected
    procedure CalculateComplexTabLayout; virtual;
    procedure CalculateSimpleTabLayout; virtual;
    procedure CalculateScrollingTabLayout; virtual;
    procedure BalancedReduce(ATotalDelta: Integer);
    procedure DrawScrollButton(ACanvas: TcxCanvas; const ABounds: TRect;
      AButton: TdxRibbonScrollButton; APressed, AHot: Boolean); virtual;
    procedure SimpleReduce(ATotalDelta: Integer);
    property Owner: TdxRibbonViewInfo read FOwner;
  public
    constructor Create(AOwner: TdxRibbonViewInfo);
    destructor Destroy; override;
    procedure Calculate(const ABounds: TRect); virtual;
    procedure Clear; override;
    function GetHitInfo(var AHitInfo: TdxRibbonHitInfo; X, Y: Integer): Boolean;
    function GetRealBounds: TRect;
    procedure Invalidate;
    procedure InvalidateScrollButtons;
    procedure MakeTabVisible(ATab: TdxRibbonTab);
    procedure Paint(ACanvas: TcxCanvas);
    procedure UpdateDockControls;
    procedure UpdateTabList;

    property Bounds: TRect read FBounds;
    property Items[Index: Integer]: TdxRibbonTabViewInfo read GetTabViewInfo; default;
    property NeedShowHint: Boolean read FNeedShowHint;
    property Painter: TdxRibbonPainter read GetPainter;
    property ScrollButtonBounds[Index: TdxRibbonScrollButton]: TRect read GetScrollButtonBounds;
    property ScrollButtonHot[Index: TdxRibbonScrollButton]: Boolean read GetScrollButtonHot;
    property ScrollButtonPressed[Index: TdxRibbonScrollButton]: Boolean read GetScrollButtonPressed;
    property ScrollButtons: TdxRibbonScrollButtons read FScrollButtons;
    property ScrollPosition: Integer read FScrollPosition write SetScrollPosition;
  end;

  { TdxRibbonViewInfo }

  TdxRibbonViewInfo = class
  private
    FApplicationButtonBounds: TRect;
    FApplicationButtonFadingHelper: TdxRibbonApplicationButtonFadingHelper;
    FApplicationButtonImageBounds: TRect;
    FBounds: TRect;
    FDrawEmptyRibbon: Boolean;
    FFont: TFont;
    FFormCaptionBounds: TRect;
    FHelpButtonBounds: TRect;
    FHelpButtonFadingHelper: TdxRibbonHelpButtonFadingHelper;
    FGroupsDockControlSiteBounds: TRect;
    FMDIButtonBounds: array[TdxBarMDIButton] of TRect;
    FMDIButtonFadingHelpers: array[TdxBarMDIButton] of TdxRibbonMDIButtonFadingHelper;
    FQATBarControlSize: TSize;
    FQuickAccessToolbarBounds: TRect;
    FRibbon: TdxCustomRibbon;
    FSupportNonClientDrawing: Boolean;
    FTabGroupsDockControlBounds: TRect;
    FTabsViewInfo: TdxRibbonTabsViewInfo;
    FUseGlass: Boolean;
    procedure CheckHelpButtonHitTest(var AHitTest: TdxRibbonHitTest; X: Integer; Y: Integer);
    procedure CheckMDIButtonsHitTest(var AHitTest: TdxRibbonHitTest; X: Integer; Y: Integer);
    function GetButtonState(AButton: TdxRibbonHitTest): TdxBorderIconState;
    function GetCanvas: TcxCanvas;
    function GetGroupsDockControlSiteViewInfo: TdxRibbonGroupsDockControlSiteViewInfo;
    function GetIsFormCaptionActive: Boolean;
    function GetMDIButtonState(AButton: TdxBarMDIButton): TdxBorderIconState;
    function GetPainter: TdxRibbonPainter;
    function GetQATDockControl: TdxRibbonQuickAccessDockControl;
    function GetScrollButtonWidth: Integer;
    function GetTabsVerticalOffset: Integer;
    procedure UpdateGroupsDockControlSite;
  protected
    procedure CalculateApplicationButton; virtual;
    procedure CalculateQuickAccessToolbar; virtual;
    procedure CalculateRibbonFormCaption; virtual;
    procedure CalculateTabGroups; virtual;
    procedure CalculateTabs; virtual;
    procedure CheckButtonsHitTest(var AHitTest: TdxRibbonHitTest; X: Integer; Y: Integer);
    function GetRibbonHeight: Integer; virtual;

    function GetApplicationButtonBounds: TRect; virtual;
    function GetApplicationButtonGlyphSize: TSize; virtual;
    function GetApplicationButtonImageBounds: TRect; virtual;
    function GetApplicationButtonOffset: TRect; virtual;
    function GetApplicationButtonRegion: HRGN; virtual;
    function GetApplicationButtonSize: TSize; virtual;
    function GetApplicationButtonState: TdxApplicationButtonState; virtual;
    function GetNonClientAreaHeight: Integer; virtual;
    //form caption
    function GetCaption: string; virtual;
    function GetDocumentName: string; virtual;
    function GetRibbonFormCaptionClientBounds: TRect; virtual;
    function GetRibbonFormCaptionTextBounds: TRect; virtual;
    //QuickAccessToolbar
    function GetQATAvailWidth: Integer;
    function GetQATBarControlSize: TSize; virtual;
    function GetQATBounds: TRect; virtual;
    function GetQATHeight: Integer; virtual;
    function GetQATLeft: Integer; virtual;
    function GetQATOverrideWidth(AIgnoreHidden: Boolean = False): Integer;
    function GetQATTop: Integer; virtual;
    function GetQATWidth: Integer; virtual;
    function GetQATDockControlBounds: TRect; virtual;
    function GetQATDockControlOffset(AIgnoreHidden: Boolean = False): TRect; virtual;
    //TabGroups
    function GetGroupsDockControlSiteBounds: TRect; virtual;
    function GetTabGroupsDockControlBounds: TRect; virtual;
    function GetTabGroupsDockControlOffset: TRect; virtual;
    function GetTabGroupsHeight(AIgnoreHidden: Boolean = False): Integer; virtual;
    //Tabs
    function GetTabsBounds: TRect; virtual;
    function GetTabsHeight: Integer; virtual;
    function GetTabViewInfoClass: TdxRibbonTabViewInfoClass; virtual;
    //MDI support
    procedure CalculateMDIButtons;
    procedure DrawMDIButtons(ACanvas: TcxCanvas);
    function HasMDIButtons: Boolean;
    procedure InvalidateMDIButtons;
    function IsMDIButtonEnabled(AButton: TdxBarMDIButton; AState: Integer): Boolean;

    procedure CalculateHelpButton;
    function CanShowBarControls(AIgnoreHidden: Boolean = False): Boolean;
    procedure DrawHelpButton(ACanvas: TcxCanvas);
    procedure DrawRibbonBackground(ACanvas: TcxCanvas);
    function HasHelpButton: Boolean;
    procedure InvalidateHelpButton;
    function IsNeedDrawBottomLine: Boolean;
    function IsNeedHideControl: Boolean;
    function IsQATAtBottom: Boolean;
    procedure UpdateQATDockControl;

    function GetPainterClass: TdxRibbonPainterClass; virtual;

    property Canvas: TcxCanvas read GetCanvas;
    property DrawEmptyRibbon: Boolean read FDrawEmptyRibbon;
    property QATDockControl: TdxRibbonQuickAccessDockControl read GetQATDockControl;
    property ScrollButtonWidth: Integer read GetScrollButtonWidth;
    property TabsHeight: Integer read GetTabsHeight;
    property UseGlass: Boolean read FUseGlass;
  public
    constructor Create(ARibbon: TdxCustomRibbon); virtual;
    destructor Destroy; override;
    procedure Calculate(const ABounds: TRect); virtual;
    function GetDocumentNameTextColor(AIsActive: Boolean): TColor;
    function GetFormCaptionFont(AIsActive: Boolean): TFont;
    function GetFormCaptionText: TCaption;
    function GetHitInfo(X, Y: Integer): TdxRibbonHitInfo;
    function GetTabAtPos(X, Y: Integer): TdxRibbonTab;
    function IsApplicationButtonVisible(AIgnoreHidden: Boolean = False): Boolean;
    function IsQATAtNonClientArea(AIgnoreHidden: Boolean = False): Boolean;
    function IsQATOnGlass: Boolean;
    function IsQATVisible(AIgnoreHidden: Boolean = False): Boolean;
    function IsTabsVisible(AIgnoreHidden: Boolean = False): Boolean;
    function IsTabGroupsVisible(AIgnoreHidden: Boolean = False): Boolean;
    procedure Paint(ACanvas: TcxCanvas);

    property Bounds: TRect read FBounds;
    property FormCaptionBounds: TRect read FFormCaptionBounds;
    property ApplicationButtonBounds: TRect read FApplicationButtonBounds;
    property ApplicationButtonFadingHelper: TdxRibbonApplicationButtonFadingHelper read FApplicationButtonFadingHelper;
    property ApplicationButtonImageBounds: TRect read FApplicationButtonImageBounds;
    property ApplicationButtonState: TdxApplicationButtonState read GetApplicationButtonState;

    property HelpButtonBounds: TRect read FHelpButtonBounds;
    property HelpButtonFadingHelper: TdxRibbonHelpButtonFadingHelper read FHelpButtonFadingHelper;
    property IsFormCaptionActive: Boolean read GetIsFormCaptionActive;
    property Painter: TdxRibbonPainter read GetPainter;
    property QuickAccessToolbarBounds: TRect read FQuickAccessToolbarBounds;
    property Ribbon: TdxCustomRibbon read FRibbon;
    property SupportNonClientDrawing: Boolean read FSupportNonClientDrawing;

    property GroupsDockControlSiteBounds: TRect read FGroupsDockControlSiteBounds;
    property TabGroupsDockControlBounds: TRect read FTabGroupsDockControlBounds;

    property GroupsDockControlSiteViewInfo: TdxRibbonGroupsDockControlSiteViewInfo read GetGroupsDockControlSiteViewInfo;
    property TabsViewInfo: TdxRibbonTabsViewInfo read FTabsViewInfo;
  end;

  { TdxRibbonBarPainter }

  TdxRibbonBarPainter = class(TdxBarSkinnedPainter)
  private
    FCollapsedGroupElementSizeDenominator: Integer;
    FCollapsedGroupElementSizeNumerator: Integer;
    FDrawParams: TdxBarButtonLikeControlDrawParams;
    FRibbon: TdxCustomRibbon;
    function GetCollapsedGroupGlyph(ABarControl: TdxBarControl): TBitmap;
    function GetCollapsedGroupGlyphBackgroundSize(ABarControl: TdxBarControl): TSize;
    function GetCollapsedGroupGlyphSize(ABarControl: TdxBarControl): TSize;
    function GetGroupState(ABarControl: TdxBarControl): Integer;
    function InternalGetGroupCaptionHeight(ATextHeight: Integer): Integer;
  protected
    procedure DrawCollapsedToolbarBackgroundPart(ABarControl: TdxRibbonGroupBarControl;
      ACanvas: TcxCanvas; AGroupState: Integer);
    procedure DrawCollapsedToolbarContentPart(ABarControl: TdxRibbonGroupBarControl;
      ACanvas: TcxCanvas; AGroupState: Integer);
    procedure DrawToolbarContentPart(ABarControl: TdxBarControl; ACanvas: TcxCanvas); override;
    procedure DrawToolbarNonContentPart(ABarControl: TdxBarControl; DC: HDC); override;
    function GetCollapsedGroupWidth(ABarControl: TdxRibbonGroupBarControl): Integer; virtual;
    function GetGroupCaptionHeight(ACaptionFont: TFont): Integer; virtual;
    function GetCollapsedGroupCaptionRect(const AGroupRect: TRect): TRect; virtual;
    function GetGroupMinWidth(ABarControl: TdxRibbonGroupBarControl): Integer; virtual;
    property DrawParams: TdxBarButtonLikeControlDrawParams read FDrawParams;
  public
    constructor Create(AData: Integer); override;
    destructor Destroy; override;
    procedure BarDrawBackground(ABarControl: TdxBarControl; ADC: HDC;
      const ADestRect: TRect; const ASourceRect: TRect; ABrush: HBRUSH;
      AColor: TColor); override;
    function BarMarkRect(ABarControl: TdxBarControl): TRect; override;
    function BarMarkItemRect(ABarControl: TdxBarControl): TRect; override;
    function GetGroupRowHeight(AIconSize: Integer; AGroupFont: TFont): Integer;
    function GetToolbarContentOffsets(ABar: TdxBar;
      ADockingStyle: TdxBarDockingStyle; AHasSizeGrip: Boolean): TRect; override;
    function SubMenuControlBeginGroupSize: Integer; override;
    function SubMenuGetSeparatorSize: Integer; override;
    property Ribbon: TdxCustomRibbon read FRibbon;
  end;

  { TdxCustomRibbonDockControl }

  TdxCustomRibbonDockControl = class(TdxBarDockControl)
  private
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
  protected
    function AllowUndockWhenLoadFromIni: Boolean; override;
    procedure FillBackground(DC: HDC; const ADestR, ASourceR: TRect; ABrush: HBRUSH; AColor: TColor); override;
    function IsDrawDesignBorder: Boolean; override;
    function IsTransparent: Boolean; override;
    function IsNeedRedrawBarControlsOnPaint: Boolean; virtual;
    procedure Paint; override;
    procedure VisibleChanged; virtual;
  public
    procedure UpdateColorScheme; virtual;
  end;

  { IdxRibbonGroupViewInfo }

  TdxRibbonGroupOffsetsInfo = record
    ButtonGroupOffset: Integer;
    ContentLeftOffset: Integer;
    ContentRightOffset: Integer;
  end;

  IdxRibbonGroupViewInfo = interface
  ['{A2CAD367-1836-4FA7-8730-8E7531463C8C}']
    procedure AddSeparator(const Value: TdxBarItemSeparatorInfo);
    procedure DeleteSeparators;
    function GetContentSize: TSize;
    function GetItemControlCount: Integer;
    function GetItemControlViewInfo(AIndex: Integer): IdxBarItemControlViewInfo;
    function GetMinContentWidth: Integer;
    function GetOffsetsInfo: TdxRibbonGroupOffsetsInfo;
    function GetSeparatorCount: Integer;
    function GetSeparatorInfo(AIndex: Integer): TdxBarItemSeparatorInfo;
    procedure SetContentSize(const Value: TSize);
    procedure SetSeparatorInfo(AIndex: Integer;
      const Value: TdxBarItemSeparatorInfo);
  end;

  { IdxRibbonGroupLayoutCalculator }

  IdxRibbonGroupLayoutCalculator = interface
  ['{894AC146-F69A-4ED2-9293-AA54AAAE1189}']
    procedure CalcInit(AGroupViewInfo: IdxRibbonGroupViewInfo);
    procedure CalcLayout(AGroupViewInfo: IdxRibbonGroupViewInfo);
    function CollapseMultiColumnItemControls(
      AGroupViewInfo: IdxRibbonGroupViewInfo): Boolean;
    function DecreaseMultiColumnItemControlsColumnCount(
      AGroupViewInfo: IdxRibbonGroupViewInfo): Boolean;
    function Reduce(AGroupViewInfo: IdxRibbonGroupViewInfo;
      AUpToViewLevel: TdxBarItemRealViewLevel): Boolean;
    procedure ReduceInit(AGroupViewInfo: IdxRibbonGroupViewInfo);
  end;

  { TdxRibbonGroupsDockControl }

  TdxRibbonGroupsDockControl = class(TdxCustomRibbonDockControl)
  private
    FTab: TdxRibbonTab;
    procedure DesignMenuClick(Sender: TObject);
    function GetRibbon: TdxCustomRibbon;
    procedure InitDesignMenu(AItemLinks: TdxBarItemLinks);
    procedure ShowDesignMenu;
  protected
    FViewInfo: TdxRibbonGroupsDockControlViewInfo;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure CalcRowToolbarPositions(ARowIndex: Integer; AClientSize: Integer); override;
    procedure DblClick; override;
    procedure FillBackground(DC: HDC; const ADestR, ASourceR: TRect; ABrush: HBRUSH; AColor: TColor); override;
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; override;
    function GetDockedBarControlClass: TdxBarControlClass; override;
    function GetPainter: TdxBarPainter; override;
    function GetViewInfoClass: TdxRibbonGroupsDockControlViewInfoClass; virtual;
    function IsMultiRow: Boolean; override;
    procedure MakeRectFullyVisible(const R: TRect); virtual;
    procedure Paint; override;
    procedure SetSize; override;
    procedure ShowCustomizePopup; override;
    procedure UpdateGroupPositions;
    procedure VisibleChanged; override;

    property Ribbon: TdxCustomRibbon read GetRibbon;
    property ViewInfo: TdxRibbonGroupsDockControlViewInfo read FViewInfo;
  public
    constructor Create(ATab: TdxRibbonTab); reintroduce; virtual;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    property Tab: TdxRibbonTab read FTab;
  end;

  { TdxRibbonGroupsDockControlViewInfo }

  TdxRibbonGroupsDockControlViewInfo = class
  private
    FPrevGroupCollapsedStates: array of Boolean;
    FScrollButtons: TdxRibbonScrollButtons;
    FScrollPosition: Integer;
    procedure CheckGroupCollapsedStates;
    function GetFirstGroupPosition: Integer;
    function GetGroupCount: Integer;
    function GetGroupViewInfo(AIndex: Integer): TdxRibbonGroupBarControlViewInfo;
    function IsValidToolbar(AToolbar: TdxBar): Boolean;
    procedure SaveGroupCollapsedStates;
    function TotalGroupsWidth: Integer;
    function TryPlaceGroups(AMaxContentWidth: Integer): Boolean;
  protected
    FDockControl: TdxRibbonGroupsDockControl;
    procedure CalculateGroupsScrollInfo(AMaxContentWidth: Integer); virtual;
    procedure InternalScrollGroups(ADelta: Integer; AMaxContentWidth: Integer); virtual;
  public
    constructor Create(ADockControl: TdxRibbonGroupsDockControl); virtual;
    procedure Calculate(const ABoundsRect: TRect); virtual;
    procedure ResetScrollInfo;
    procedure ScrollGroups(AScrollLeft: Boolean; AMaxContentWidth: Integer); virtual;
    property DockControl: TdxRibbonGroupsDockControl read FDockControl;
    property FirstGroupPosition: Integer read GetFirstGroupPosition;
    property GroupCount: Integer read GetGroupCount;
    property GroupViewInfos[AIndex: Integer]: TdxRibbonGroupBarControlViewInfo read GetGroupViewInfo;
    property ScrollButtons: TdxRibbonScrollButtons read FScrollButtons;
  end;

  { TdxRibbonTabGroupsPopupWindow }

  TdxRibbonTabGroupsPopupWindow = class(TcxCustomPopupWindow)
  private
    FRibbon: TdxCustomRibbon;
    FShadow: TdxBarShadow;
    function GetBounds: TRect;
    function GetGroupsDockControlSite: TdxRibbonGroupsDockControlSite;
    procedure WMNCPaint(var Message: TMessage); message WM_NCPAINT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    function CalculatePosition: TPoint; override;
    procedure CalculateSize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Deactivate; override;
    procedure DoClosed; override;
    procedure DoShowed; override;
    procedure DoShowing; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function NeedIgnoreMouseMessageAfterCloseUp(AWnd: THandle; AMsg: Cardinal;
      AShift: TShiftState; const APos: TPoint): Boolean; override;
    procedure HandleNavigationKey(AKey: Word);
    procedure SetGroupsDockControlSite;
  public
    constructor Create(ARibbon: TdxCustomRibbon); reintroduce; virtual;
    destructor Destroy; override;
    property GroupsDockControlSite: TdxRibbonGroupsDockControlSite
      read GetGroupsDockControlSite;
    property Ribbon: TdxCustomRibbon read FRibbon;
  end;

  { TdxRibbonCustomBarControl }

  TdxRibbonPopupMenuItem = (rpmiItems, rpmiMoreCommands, rpmiQATPosition,
    rpmiQATAddRemoveItem, rpmiMinimizeRibbon);
  TdxRibbonPopupMenuItems = set of TdxRibbonPopupMenuItem;

  TdxRibbonCustomBarControl = class(TdxBarControl)
  private
    function GetQuickAccessToolbar: TdxRibbonQuickAccessToolbar;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    function AllowQuickCustomizing: Boolean; override;
    function CanAlignControl(AControl: TdxBarItemControl): Boolean; override;
    function CanMoving: Boolean; override;
    function GetBehaviorOptions: TdxBarBehaviorOptions; override;
    function GetEditFont: TFont; override;
    function GetFont: TFont; override;
    function GetFullItemRect(Item: TdxBarItemControl): TRect; override;
    function GetIsMainMenu: Boolean; override;
    function GetMultiLine: Boolean; override;
    function GetRibbon: TdxCustomRibbon; virtual; abstract;
    function HasCloseButton: Boolean; override;
    function MarkExists: Boolean; override;
    function NotHandleMouseMove(ACheckLastMousePos: Boolean = True): Boolean; override;
    function RealMDIButtonsOnBar: Boolean; override;
    //
    function ClickAtHeader: Boolean; virtual;
    procedure DoPopupMenuClick(Sender: TObject); virtual;
    function GetPopupMenuItems: TdxRibbonPopupMenuItems; virtual;
    procedure InitCustomizationPopup(AItemLinks: TdxBarItemLinks); override;
    procedure PopupMenuClick(Sender: TObject);
    procedure ShowPopup(AItem: TdxBarItemControl); override;
    //
    property QuickAccessToolbar: TdxRibbonQuickAccessToolbar read GetQuickAccessToolbar;
  public
    constructor CreateEx(AOwner: TComponent; ABar: TdxBar); override;
    property Ribbon: TdxCustomRibbon read GetRibbon;
  end;

  { TdxRibbonQuickAccessBarControl }

  TdxRibbonQuickAccessBarControl = class(TdxRibbonCustomBarControl)
  private
    FBitmap: TcxBitmap;
    FDefaultGlyph: TBitmap;
    FIsWindowCreation: Boolean;
    FInternalItems: TComponentList;
    function GetSeparatorWidth(AItemControl: TdxBarItemControl): Integer;
    function GetViewInfo: TdxRibbonQuickAccessBarControlViewInfo;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  {$IFNDEF DELPHI7}
    procedure WMPrintClient(var Message: TWMPrintClient); message WM_PRINTCLIENT;
  {$ENDIF}
  protected
    function AllItemsVisible: Boolean;
    procedure CalcControlsPositions; override;
    function CanHideAllItemsInSingleLine: Boolean; override;
    procedure CreateWnd; override;
    procedure DoPaintItem(AControl: TdxBarItemControl; ACanvas: TcxCanvas; const AItemRect: TRect); override;
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; override;
    function GetClientOffset: TRect; virtual;
    function GetDefaultItemGlyph: TBitmap; override;
    function GetItemControlDefaultViewLevel(
      AItemControl: TdxBarItemControl): TdxBarItemViewLevel; override;
    function GetMarkAccessibilityHelperClass: TdxBarAccessibilityHelperClass; override;
    function GetMarkSize: Integer; override;
    function GetMinHeight(AStyle: TdxBarDockingStyle): Integer; override;
    function GetMinWidth(AStyle: TdxBarDockingStyle): Integer; override;
    function GetPopupMenuItems: TdxRibbonPopupMenuItems; override;
    function GetQuickControlClass: TdxBarControlClass; override;
    function GetRibbon: TdxCustomRibbon; override;
    function GetSize(AMaxWidth: Integer): TSize;
    function GetSizeForWidth(AStyle: TdxBarDockingStyle; AWidth: Integer): TPoint; override;
    function GetViewInfoClass: TCustomdxBarControlViewInfoClass; override;

    function AllowQuickCustomizing: Boolean; override;
    procedure InitQuickCustomizeItemLinks(AQuickControlItemLinks: TdxBarItemLinks); override;
    procedure InitAddRemoveSubItemPopup(AItemLinks: TdxBarItemLinks); override;

    procedure InitCustomizationPopup(AItemLinks: TdxBarItemLinks); override;
    function MarkExists: Boolean; override;
    procedure RemoveItemFromQAT;
    procedure ShowPopup(AItem: TdxBarItemControl); override;
    procedure UpdateDefaultGlyph(AGlyph: TBitmap); virtual;
    procedure UpdateDoubleBuffered; override;

    property ViewInfo: TdxRibbonQuickAccessBarControlViewInfo read GetViewInfo;
  public
    constructor CreateEx(AOwner: TComponent; ABar: TdxBar); override;
    destructor Destroy; override;
    function IsOnGlass: Boolean; override;
  end;

  { TdxRibbonQuickAccessBarControlViewInfo }

  TdxRibbonQuickAccessBarControlViewInfo = class(TdxBarControlViewInfo)
  protected
    function CanShowSeparators: Boolean; override;
    function IsLastVisibleItemControl(AItemControl: TdxBarItemControl): Boolean; override;
  end;

  { TdxRibbonQuickAccessItemControlPainter }

  TdxRibbonQuickAccessPainter = class(TdxRibbonBarPainter)
  protected
    procedure BarDrawMarkBackground(ABarControl: TdxBarControl; DC: HDC;
      ItemRect: TRect; AToolbarBrush: HBRUSH); override;
    procedure DrawGroupButtonControl(ADrawParams: TdxBarButtonLikeControlDrawParams;
      const ARect: TRect); virtual;
    procedure DrawToolbarContentPart(ABarControl: TdxBarControl; ACanvas: TcxCanvas); override;
    function MarkButtonWidth: Integer; virtual;
  public
    function BarMarkRect(ABarControl: TdxBarControl): TRect; override;
    function BarMarkItemRect(ABarControl: TdxBarControl): TRect; override;
    procedure ComboControlDrawArrowButton(
      const ADrawParams: TdxBarEditLikeControlDrawParams; ARect: TRect; AInClientArea: Boolean); override;
    function GetToolbarContentOffsets(ABar: TdxBar;
      ADockingStyle: TdxBarDockingStyle; AHasSizeGrip: Boolean): TRect; override;
    function MarkButtonOffset: Integer; virtual;
    function MarkSizeX(ABarControl: TdxBarControl): Integer; override;
  end;

  { TdxRibbonQuickAccessDockControl }

  TdxRibbonQuickAccessDockControl = class(TdxCustomRibbonDockControl)
  private
    FPainter: TdxRibbonQuickAccessPainter;
    FRibbon: TdxCustomRibbon;
  protected
    procedure CalcLayout; override;
    function GetDockedBarControlClass: TdxBarControlClass; override;
    function GetPainter: TdxBarPainter; override;
    procedure VisibleChanged; override;
  public
    constructor Create(AOwner: TdxCustomRibbon); reintroduce; virtual;
    destructor Destroy; override;
    property Ribbon: TdxCustomRibbon read FRibbon;
  end;

  { TdxRibbonQuickAccessBarControlDesignHelper }

  TdxRibbonQuickAccessBarControlDesignHelper = class(TCustomdxBarControlDesignHelper)
  public
    class procedure GetEditors(AEditors: TList); override;
    class function GetForbiddenActions: TdxBarCustomizationActions; override;
  end;

  { TdxRibbonQuickAccessPopupBarControl }

  TdxRibbonQuickAccessPopupBarControl = class(TdxRibbonQuickAccessBarControl)
  private
    FPainter: TdxBarPainter;
    function GetQuickAccessBarControl: TdxRibbonQuickAccessBarControl;
    function GetMarkLink: TdxBarItemLink;
    function GetMarkSubItem: TCustomdxBarSubItem;
  protected
    function GetClientOffset: TRect; override;
    function GetPainter: TdxBarPainter; override;
    function GetRibbon: TdxCustomRibbon; override;
    function GetSizeForPopup: TSize; override;
    function HasShadow: Boolean; override;
    function IsPopup: Boolean; override;
    property QuickAccessBarControl: TdxRibbonQuickAccessBarControl
      read GetQuickAccessBarControl;
  public
    constructor CreateEx(AOwner: TComponent; ABar: TdxBar); override;
    destructor Destroy; override;
    procedure CloseUp; override;
    procedure Popup(const AOwnerRect: TRect); override;
  end;

  { TdxRibbonQuickAccessPopupItemControlPainter }

  TdxRibbonQuickAccessPopupPainter = class(TdxRibbonQuickAccessPainter)
  protected
    procedure DrawQuickAccessPopupSubItem(DC: HDC; const ARect: TRect;
      AState: Integer); virtual;
    procedure DrawToolbarContentPart(ABarControl: TdxBarControl; ACanvas: TcxCanvas); override;
  public
    function MarkButtonOffset: Integer; override;
    function MarkSizeX(ABarControl: TdxBarControl): Integer; override;
  end;

  { TdxRibbonQuickAccessPopupSubItem }

  TdxRibbonQuickAccessPopupSubItem = class(TdxBarSubItem)
  protected
    function CreateBarControl: TCustomdxBarControl; override;
  end;

  TdxRibbonQuickAccessPopupSubMenuControl = class(TdxBarSubMenuControl)
  protected
    procedure ShowPopup(AItem: TdxBarItemControl); override;
  end;

  { TdxRibbonQuickAccessPopupSubItemControl }

  TdxRibbonQuickAccessPopupSubItemControl = class(TdxBarSubItemControl)
  protected
    procedure DoCloseUp(AHadSubMenuControl: Boolean); override;
    procedure DoPaint(ARect: TRect; PaintType: TdxBarPaintType); override;
    function GetDefaultWidth: Integer; override;
  end;

  { TdxRibbonQuickAccessPopupSubItemButton }

  TdxRibbonQuickAccessPopupSubItemButton = class(TdxBarButton)
  public
    procedure DoClick; override;
  end;

  { TdxRibbonQuickAccessPopupSubItemButtonControl }

  TdxRibbonQuickAccessPopupSubItemButtonControl = class(TdxBarButtonControl)
  end;

  { TdxRibbonGroupBarControl }

  TdxRibbonGroupBarControl = class(TdxRibbonCustomBarControl,
  {$IFNDEF DELPHI6}
    IUnknown,
  {$ENDIF}
    IdxFadingObject
  )
  private
    FFadingElementData: IdxFadingElementData;
    FGroup: TdxRibbonTabGroup;
    FRibbon: TdxCustomRibbon;
    procedure DesignMenuClick(Sender: TObject);
    procedure DrawBarParentBackground(ACanvas: TcxCanvas);
    procedure DrawCaptionButtons(ACanvas: TcxCanvas);
    procedure DrawSelectedFrame(DC: HDC);
    function GetCollapsed: Boolean;
    function GetGroupDesignRect: TRect;
    function GetViewInfo: TdxRibbonGroupBarControlViewInfo;
    procedure InitDesignMenu(AItemLinks: TdxBarItemLinks);
    procedure PaintGroupBackground(ACanvas: TcxCanvas);
    procedure PaintGroupCaptionText(ACanvas: TcxCanvas);
    procedure PaintGroupMark(ACanvas: TcxCanvas);
    procedure ShowGroupDesignMenu;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  protected
    //IdxFadingObject
    function IdxFadingObject.CanFade = FadingCanFade;
    procedure IdxFadingObject.DrawFadeImage = FadingDrawFadeImage;
    procedure IdxFadingObject.GetFadingParams = FadingGetFadingParams;

    procedure FadingBegin(AData: IdxFadingElementData);
    function FadingCanFade: Boolean;
    procedure FadingDrawFadeImage;
    procedure FadingEnd;
    procedure FadingGetFadingParams(
      out AFadeOutImage, AFadeInImage: TcxBitmap;
      var AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
      var AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);

    //methods
    procedure AdjustHintWindowPosition(var APos: TPoint; const ABoundsRect: TRect; AHeight: Integer); override;
    procedure CalcLayout; override;
    function CanProcessShortCut: Boolean; override;
    procedure CaptionChanged; override;
    procedure DoHideAll; override;
    procedure DoNCPaint(DC: HDC); override;
    procedure DoOpaqueNCPaint(DC: HDC);
    procedure DoPaint; override;
    procedure DoTransparentNCPaint(DC: HDC);
    procedure DrawContentBackground; override;

    procedure DoBarMouseDown(Button: TMouseButton; Shift: TShiftState;
      const APoint: TPoint; AItemControl: TdxBarItemControl; APointInClientRect: Boolean); override;

    function ClickAtHeader: Boolean; override;
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; override;
    function GetMarkDrawState: TdxBarMarkState; override;
    function GetMoreButtonsHint: string; override;
    function GetQuickControlClass: TdxBarControlClass; override;
    function GetRibbon: TdxCustomRibbon; override;
    function GetViewInfoClass: TCustomdxBarControlViewInfoClass; override;
    procedure GlyphChanged; override;
    function HasCaptionButtons: Boolean; override;
    procedure InitQuickControl(AQuickControlItemLinks: TdxBarItemLinks); override;
    procedure MakeItemControlFullyVisible(AItemControl: TdxBarItemControl); override;
    function MarkExists: Boolean; override;
    procedure ViewStateChanged(APrevValue: TdxBarViewState); override;
    procedure UpdateCaptionButton(ACaptionButton: TdxBarCaptionButton); override;

    property ViewInfo: TdxRibbonGroupBarControlViewInfo read GetViewInfo;
  public
    constructor CreateEx(AOwner: TComponent; ABar: TdxBar); override;
    destructor Destroy; override;
    procedure CloseUp; override;
    property Collapsed: Boolean read GetCollapsed;
    property Group: TdxRibbonTabGroup read FGroup;
  end;

  TdxRibbonGroupKeyTipsBaseLinePositions = record
    BottomKeyTipsBaseLinePosition: Integer;
    Calculated: Boolean;
    RowKeyTipsBaseLinePositions: array of Integer;
  end;

  { TdxRibbonGroupBarControlViewInfo }

  TdxRibbonGroupBarControlViewInfo = class(TCustomdxBarControlViewInfo)
  private
    FCollapsed: Boolean;
    FContentSize: TSize;
    FGroupRowHeight: Integer;
    FKeyTipsBaseLinePositions: TdxRibbonGroupKeyTipsBaseLinePositions;
    FLayoutCalculator: IdxRibbonGroupLayoutCalculator;
    FNonContentAreaSize: TSize;
    function CreateCalculateHelper: IdxRibbonGroupViewInfo;
    function GetBarControl: TdxRibbonGroupBarControl;
    function GetBottomKeyTipsBaseLinePosition: Integer;
    function GetRowKeyTipsBaseLinePosition(ARowIndex: Integer): Integer;
    function GetSize: TSize;
  protected
    procedure CalculateKeyTipsBaseLinePositions;
    function CreateLayoutCalculator: IdxRibbonGroupLayoutCalculator; virtual;
    procedure DoCalculateKeyTipsBaseLinePositions; virtual;
    function GetNonContentAreaSize: TSize; virtual;
    procedure UpdateItemRects;
    property ContentSize: TSize read FContentSize write FContentSize;
    property LayoutCalculator: IdxRibbonGroupLayoutCalculator read FLayoutCalculator;
  public
    procedure Calculate; override;
    procedure CalculateFinalize; virtual;
    procedure CalculateInit; virtual;
    function CollapseMultiColumnItemControls: Boolean;
    function DecreaseMultiColumnItemControlsColumnCount: Boolean;
    function Reduce(AUpToViewLevel: TdxBarItemRealViewLevel): Boolean;
    procedure ReduceInit;
    property BarControl: TdxRibbonGroupBarControl read GetBarControl;
    property Collapsed: Boolean read FCollapsed write FCollapsed;
    property Size: TSize read GetSize;

    property BottomKeyTipsBaseLinePosition: Integer read GetBottomKeyTipsBaseLinePosition;
    property RowKeyTipsBaseLinePositions[ARowIndex: Integer]: Integer
      read GetRowKeyTipsBaseLinePosition;
  end;

  { TdxRibbonGroupBarControlDesignHelper }

  TdxRibbonGroupBarControlDesignHelper = class(TCustomdxBarControlDesignHelper)
  public
    class function GetForbiddenActions: TdxBarCustomizationActions; override;
  end;

  { TdxRibbonCollapsedGroupPopupBarControl }

  TdxRibbonCollapsedGroupPopupBarControl = class(TdxRibbonGroupBarControl)
  protected
    function GetCaption: TCaption; override;
    function GetPainter: TdxBarPainter; override;
    function GetSizeForPopup: TSize; override;
    function GetSizeForWidth(AStyle: TdxBarDockingStyle; AWidth: Integer): TPoint; override;
    function IgnoreClickAreaWhenHidePopup: TRect; override;
    function IsPopup: Boolean; override;
    function NeedHideOnNCMouseClick: Boolean; override;
  public
    constructor CreateForPopup(AParentBarControl: TdxBarControl;
      AOwnerBar: TdxBar); override;
    destructor Destroy; override;
    procedure Hide; override;
    procedure Popup(const AOwnerRect: TRect); override;
  end;

  { TdxRibbonTabGroup }

  TdxRibbonTabGroupClass = class of TdxRibbonTabGroup;

  TdxRibbonTabGroup = class(TCollectionItem,
    IUnknown,
    IdxBarSelectableItem
  )
  private
    FCanCollapse: Boolean;
    FDesignSelectionHelper: IdxBarSelectableItem;
    FLoadedToolbarName: string;
    FToolbar: TdxBar;
    procedure CheckUndockToolbar;
    function GetTab: TdxRibbonTab;
    function GetToolbar: TdxBar;
    procedure ReadToolbarName(AReader: TReader);
    procedure SetCanCollapse(Value: Boolean);
    procedure SetToolbar(Value: TdxBar);
    procedure ValidateToolbar(Value: TdxBar);
    procedure WriteToolbarName(AWriter: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure DockToolbar(AToolbar: TdxBar); virtual;
    function IsToolbarAcceptable(AToolbar: TdxBar): Boolean;
    procedure UpdateBarManager(ABarManager: TdxBarManager);
    procedure UpdateToolbarValue;

    property DesignSelectionHelper: IdxBarSelectableItem
      read FDesignSelectionHelper implements IdxBarSelectableItem;
    property Unknown: IdxBarSelectableItem
      read FDesignSelectionHelper implements IUnknown;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    property Tab: TdxRibbonTab read GetTab;
  published
    property CanCollapse: Boolean read FCanCollapse write SetCanCollapse default True;
    property ToolBar: TdxBar read GetToolbar write SetToolbar stored False;
  end;

  TdxRibbonTabGroups = class(TCollection)
  private
    FTab: TdxRibbonTab;
    function GetItem(Index: Integer): TdxRibbonTabGroup;
    procedure SetItem(Index: Integer; const Value: TdxRibbonTabGroup);
  protected
    function GetOwner: TPersistent; override;
  {$IFDEF DELPHI6}
    procedure Notify(Item: TCollectionItem; Action: TCollectionNotification); override;
  {$ENDIF}
    procedure Update(Item: TCollectionItem); override;
    procedure UpdateGroupToolbarValues;
  public
    constructor Create(ATab: TdxRibbonTab);
    function Add: TdxRibbonTabGroup;
    property Tab: TdxRibbonTab read FTab;
    property Items[Index: Integer]: TdxRibbonTabGroup read GetItem write SetItem; default;
  end;

  { TdxRibbonQuickAccessToolbar }

  TdxQuickAccessToolbarPosition = (qtpAboveRibbon, qtpBelowRibbon);

  TdxRibbonQuickAccessToolbar = class(TPersistent)
  private
    FDockControl: TdxRibbonQuickAccessDockControl;
    FRibbon: TdxCustomRibbon;
    FVisible: Boolean;
    FToolbar: TdxBar;
    FPosition: TdxQuickAccessToolbarPosition;
    procedure CheckUndockGroupToolbar(const Value: TdxBar);
    procedure SetPosition(const Value: TdxQuickAccessToolbarPosition);
    procedure SetToolbar(const Value: TdxBar);
    procedure SetVisible(const Value: Boolean);
  protected
    function Contains(AItemLink: TdxBarItemLink): Boolean;

    function CreateDockControl: TdxRibbonQuickAccessDockControl; virtual;
    function GetMenuItemsForMark: TdxRibbonPopupMenuItems; virtual;
    procedure UpdateColorScheme; virtual;
    procedure UpdateGroupButton(AForToolbar: TdxBar; ABeforeUndock: Boolean);
    procedure UpdateMenuItems(AItems: TdxBarItemLinks);
    procedure UpdateRibbon;

    property DockControl: TdxRibbonQuickAccessDockControl read FDockControl;
  public
    constructor Create(ARibbon: TdxCustomRibbon); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function HasGroupButtonForToolbar(AToolbar: TdxBar): Boolean;

    property Ribbon: TdxCustomRibbon read FRibbon;
  published
    property Position: TdxQuickAccessToolbarPosition read FPosition write SetPosition default qtpAboveRibbon;
    property Toolbar: TdxBar read FToolbar write SetToolbar;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  { TdxRibbonApplicationButton }

  TdxRibbonApplicationButton = class(TPersistent)
  private
    FGlyph: TBitmap;
    FIAccessibilityHelper: IdxBarAccessibilityHelper;
    FKeyTip: string;
    FMenu: TdxBarApplicationMenu;
    FRibbon: TdxCustomRibbon;
    FScreenTip: TdxBarScreenTip;
    FStretchGlyph: Boolean;
    FVisible: Boolean;
    function GetIAccessibilityHelper: IdxBarAccessibilityHelper;
    procedure GlyphChanged(Sender: TObject);
    procedure SetGlyph(const Value: TBitmap);
    procedure SetMenu(const Value: TdxBarApplicationMenu);
    procedure SetVisible(const Value: Boolean);
    procedure SetScreenTip(const Value: TdxBarScreenTip);
    procedure SetStretchGlyph(const Value: Boolean);
  protected
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; virtual;
    procedure Update;

    property IAccessibilityHelper: IdxBarAccessibilityHelper read GetIAccessibilityHelper;
  public
    constructor Create(ARibbon: TdxCustomRibbon); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Ribbon: TdxCustomRibbon read FRibbon;
  published
    property Glyph: TBitmap read FGlyph write SetGlyph;
    property KeyTip: string read FKeyTip write FKeyTip;
    property Menu: TdxBarApplicationMenu read FMenu write SetMenu;
    property ScreenTip: TdxBarScreenTip read FScreenTip write SetScreenTip;
    property StretchGlyph: Boolean read FStretchGlyph write SetStretchGlyph default True;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  { TdxRibbonTab }

  TdxRibbonTabClass = class of TdxRibbonTab;

  TdxRibbonTab = class(
    TcxComponentCollectionItem,
  {$IFNDEF DELPHI6}
    IUnknown,
  {$ENDIF}
    IdxBarSelectableItem,
    IdxFadingObject
  )
  private
    FCaption: string;
    FDesignSelectionHelper: IdxBarSelectableItem;
    FDockControl: TdxRibbonGroupsDockControl;
    FFadingElementData: IdxFadingElementData;
    FGroups: TdxRibbonTabGroups;
    FIAccessibilityHelper: IdxBarAccessibilityHelper;
    FKeyTip: string;
    FLastIndex: Integer;
    FLocked: Boolean;
    FRibbon: TdxCustomRibbon;
    FVisible: Boolean;
    function GetActive: Boolean;
    function GetFocused: Boolean;
    function GetHighlighted: Boolean;
    function GetIAccessibilityHelper: IdxBarAccessibilityHelper;
    function GetIsDestroying: Boolean;
    function GetViewInfo: TdxRibbonTabViewInfo;
    function GetVisibleIndex: Integer;
    procedure SetActive(Value: Boolean);
    procedure SetCaption(const Value: string);
    procedure SetHighlighted(Value: Boolean);
    procedure SetRibbon(Value: TdxCustomRibbon);
    procedure SetGroups(const Value: TdxRibbonTabGroups);
    procedure SetVisible(Value: Boolean);
  protected
    //IdxFadingObject
    procedure IdxFadingObject.DrawFadeImage = FadingDrawFadeImage;
    procedure IdxFadingObject.GetFadingParams = FadingGetFadingParams;
    procedure FadingBegin(AData: IdxFadingElementData);
    function CanFade: Boolean;
    procedure FadingDrawFadeImage;
    procedure FadingEnd;
    procedure FadingGetFadingParams(
      out AFadeOutImage, AFadeInImage: TcxBitmap;
      var AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
      var AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);
    //inherited
    function GetCollectionFromParent(AParent: TComponent): TcxComponentCollection; override;
    function GetDisplayName: string; override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetName(const Value: TComponentName); override;
    //methods
    procedure Activate; virtual;
    procedure CheckGroupToolbarsDockControl;
    procedure Deactivate; virtual;
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; virtual;
    function GetDockControlBounds: TRect; virtual;
    function GetGroupClass: TdxRibbonTabGroupClass; virtual;
    procedure ScrollDockControlGroups(AScrollLeft, AOnTimer: Boolean);
    procedure UpdateBarManager(ABarManager: TdxBarManager);
    procedure UpdateColorScheme; virtual;
    procedure UpdateDockControl;
    procedure UpdateDockControlBounds;
    procedure UpdateGroupsFont;

    property DesignSelectionHelper: IdxBarSelectableItem
      read FDesignSelectionHelper implements IdxBarSelectableItem;
    property Focused: Boolean read GetFocused;
    property Highlighted: Boolean read GetHighlighted write SetHighlighted;
    property IsDestroying: Boolean read GetIsDestroying;
    property LastIndex: Integer read FLastIndex;
    property Locked: Boolean read FLocked;
    property ViewInfo: TdxRibbonTabViewInfo read GetViewInfo;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AddToolBar(AToolBar: TdxBar);
    procedure Invalidate;
    procedure MakeVisible;

    property DockControl: TdxRibbonGroupsDockControl read FDockControl;
    property IAccessibilityHelper: IdxBarAccessibilityHelper read GetIAccessibilityHelper;
    property Ribbon: TdxCustomRibbon read FRibbon write SetRibbon;
  published
    property Active: Boolean read GetActive write SetActive default False;//stored False;
    property Caption: string read FCaption write SetCaption;
    property Groups: TdxRibbonTabGroups read FGroups write SetGroups;
    property KeyTip: string read FKeyTip write FKeyTip;
    property Visible: Boolean read FVisible write SetVisible default True;
    property VisibleIndex: Integer read GetVisibleIndex;
  end;

  TdxRibbonTabCollection = class(TcxComponentCollection)
  private
    FIAccessibilityHelper: IdxBarAccessibilityHelper;
    FOwner: TdxCustomRibbon;
    function GetIAccessibilityHelper: IdxBarAccessibilityHelper;
    function GetItem(Index: Integer): TdxRibbonTab;
    procedure SetItem(Index: Integer; const Value: TdxRibbonTab);
  protected
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; virtual;
    procedure Notify(AItem: TcxComponentCollectionItem;
      AAction: TcxComponentCollectionNotification); override;
    procedure SetItemName(AItem: TcxComponentCollectionItem); override;
    procedure Update(AItem: TcxComponentCollectionItem;
      AAction: TcxComponentCollectionNotification); override;
    procedure UpdateBarManager(ABarManager: TdxBarManager);

    property IAccessibilityHelper: IdxBarAccessibilityHelper read GetIAccessibilityHelper;
    property Owner: TdxCustomRibbon read FOwner;
  public
    constructor Create(AOwner: TdxCustomRibbon); reintroduce;
    destructor Destroy; override;
    function Add: TdxRibbonTab;

    function Insert(AIndex: Integer): TdxRibbonTab;
    property Items[Index: Integer]: TdxRibbonTab read GetItem write SetItem; default;
  end;

  { TdxRibbonFonts }

  TdxRibbonAssignedFont = (afTabHeader, afGroup, afGroupHeader);
  TdxRibbonAssignedFonts = set of TdxRibbonAssignedFont;

  TdxRibbonFonts = class(TPersistent)
  private
    FAssignedFonts: TdxRibbonAssignedFonts;
    FDocumentNameColor: TColor;
    FCaptionFont: TFont;
    FFont: TFont;
    FFonts: array[TdxRibbonAssignedFont] of TFont;
    FLocked: Boolean;
    FRibbon: TdxCustomRibbon;
    procedure FontChanged(Sender: TObject);
    function GetDefaultCaptionTextColor(AIsActive: Boolean): TColor;
    function GetFont(const Index: Integer): TFont;
    function IsFontStored(const Index: Integer): Boolean;
    procedure SetAssignedFonts(const Value: TdxRibbonAssignedFonts);
    procedure SetDocumentNameColor(const Value: TColor);
    procedure SetFont(const Index: Integer; const Value: TFont);
    procedure UpdateGroupsFont;
  protected
    procedure Invalidate;
    procedure UpdateDefaultFont(I: TdxRibbonAssignedFont);
    procedure UpdateFonts;
    property Locked: Boolean read FLocked;
  public
    constructor Create(AOwner: TdxCustomRibbon); virtual;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    function GetFormCaptionFont(AIsActive: Boolean): TFont; virtual;
    function GetGroupFont: TFont; virtual;
    function GetGroupHeaderFont: TFont; virtual;
    function GetTabHeaderFont(AState: Integer): TFont; virtual;

    property Ribbon: TdxCustomRibbon read FRibbon;
  published
    property AssignedFonts: TdxRibbonAssignedFonts
      read FAssignedFonts write SetAssignedFonts default [];
    property DocumentNameColor: TColor
      read FDocumentNameColor write SetDocumentNameColor default clDefault;
    property Group: TFont index Ord(afGroup)
      read GetFont write SetFont stored IsFontStored;
    property GroupHeader: TFont index Ord(afGroupHeader)
      read GetFont write SetFont stored IsFontStored;
    property TabHeader: TFont index Ord(afTabHeader)
      read GetFont write SetFont stored IsFontStored;
  end;

  { TdxRibbonPopupMenu }

  TdxRibbonPopupMenu = class(TdxBarPopupMenu)
  private
    FRibbon: TdxCustomRibbon;
    procedure CheckAssignRibbon;
    procedure SetRibbon(Value: TdxCustomRibbon);
  protected
    function CreateBarControl: TCustomdxBarControl; override;
    function GetControlClass: TCustomdxBarControlClass; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Ribbon: TdxCustomRibbon read FRibbon write SetRibbon;
  end;

  { TdxRibbonPopupMenuControl }

  TdxRibbonPopupMenuControl = class(TdxBarSubMenuControl)
  protected
    function GetBehaviorOptions: TdxBarBehaviorOptions; override;
  end;

  { TdxBarApplicationMenu }
  
  TdxBarApplicationMenu = class(TdxBarCustomApplicationMenu)
  protected
    function GetControlClass: TCustomdxBarControlClass; override;
  published
    property BackgroundBitmap;
    property BarManager;
    property BarSize;
    property Buttons;
    property ExtraPane;
    property ExtraPaneEvents;
    property Font;
    property ItemLinks;
    property ItemOptions;
    property UseOwnFont;

    property OnCloseUp;
    property OnPaintBar;
    property OnPopup;

    // obsolette
    property ExtraPaneWidthRatio stored False;
    property ExtraPaneSize stored False;
    property ExtraPaneItems stored False;
    property ExtraPaneHeader stored False;
    property OnExtraPaneItemClick stored False;
  end;

  TdxRibbonApplicationMenuControl = class(TdxBarApplicationMenuControl)
  private
    function GetRibbon: TdxCustomRibbon;
    procedure DoPopupMenuClick(Sender: TObject);
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    function GetBehaviorOptions: TdxBarBehaviorOptions; override;
    procedure InitCustomizationPopup(AItemLinks: TdxBarItemLinks); override;

    function GetPopupMenuItems: TdxRibbonPopupMenuItems;
    procedure PopupMenuClick(Sender: TObject);
    property Ribbon: TdxCustomRibbon read GetRibbon;
  end;

  { TdxRibbonController }

  TdxRibbonController = class(TcxIUnknownObject, IdxBarHintKeeper)
  private
    FHintInfo: TdxRibbonHitInfo;
    FHotObject: TdxRibbonHitTest;
    FPressedObject: TdxRibbonHitTest;
    FRibbon: TdxCustomRibbon;
    FScrollKind: TdxRibbonHitTest;
    FScrollTimer: TTimer;
    procedure CancelScroll;
    function CanProcessDesignTime: Boolean;
    procedure ClearHintInfo;
    procedure CreateTimer;
    function GetViewInfo: TdxRibbonViewInfo;
    procedure Invalidate(AOld, ANew: TdxRibbonHitTest);
    procedure InvalidateScrollButtons;
    procedure InvalidateButtons;
    procedure OnTimer(Sender: TObject);
    procedure StartScroll(AScrollKind: TdxRibbonHitTest);
    procedure SetHintInfo(const Value: TdxRibbonHitInfo);
    procedure SetHotObject(const Value: TdxRibbonHitTest);
    procedure SetPressedObject(const Value: TdxRibbonHitTest);
  protected
    // IdxBarHintKeeper
    function DoHint(var ANeedDeactivate: Boolean; out AHintText: string; out AShortCut: string): Boolean;
    function CreateHintViewInfo(const AHintText, AShortCut: string): TdxBarCustomHintViewInfo;
    function GetEnabled: Boolean;
    function GetHintPosition(const ACursorPos: TPoint; AHeight: Integer): TPoint;

    procedure CancelHint;
    procedure CancelMode; virtual;
    procedure CheckButtonsMouseUp(X: Integer; Y: Integer);
    procedure DesignTabMenuClick(Sender: TObject);
    procedure DoScroll(AOnTimer: Boolean);
    procedure HideHint; virtual;
    procedure InitTabDesignMenu(AItemLinks: TdxBarItemLinks); virtual;
    function IsApplicationMenuDropped: Boolean;
    function IsNeedShowHint(AObject: TdxRibbonHitTest): Boolean; virtual;
    function IsOwnerForHintObject(AObject: TdxRibbonHitTest): Boolean; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(var Key: Char); virtual;
    procedure KeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseLeave; virtual;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    function MouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; virtual;
    function MouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; virtual;
    function NotHandleMouseMove(P: TPoint): Boolean; virtual;
    procedure ProcessTabClick(ATab: TdxRibbonTab; Button: TMouseButton; Shift: TShiftState);
    procedure ScrollGroups(AScrollLeft, AOnTimer: Boolean);
    procedure ScrollTabs(AScrollLeft, AOnTimer: Boolean);
    procedure ShowTabDesignMenu; virtual;
    property HintInfo: TdxRibbonHitInfo read FHintInfo write SetHintInfo;
    property HotObject: TdxRibbonHitTest read FHotObject write SetHotObject;
    property PressedObject: TdxRibbonHitTest read FPressedObject write SetPressedObject;
  public
    constructor Create(ARibbon: TdxCustomRibbon); virtual;
    destructor Destroy; override;
    function NextTab(ATab: TdxRibbonTab): TdxRibbonTab;
    function PrevTab(ATab: TdxRibbonTab): TdxRibbonTab;

    property Ribbon: TdxCustomRibbon read FRibbon;
    property ScrollKind: TdxRibbonHitTest read FScrollKind;
    property ViewInfo: TdxRibbonViewInfo read GetViewInfo;
  end;

  { TdxRibbonGroupsDockControlSiteViewInfo }

  TdxRibbonGroupsDockControlSiteViewInfo = class
  private
    FSite: TdxRibbonGroupsDockControlSite;
    FTabGroupsScrollButtonBounds: array[TdxRibbonScrollButton] of TRect;
    FTabGroupsScrollButtons: TdxRibbonScrollButtons;
    FTabGroupsScrollFadingHelpers: array[TdxRibbonScrollButton] of TdxRibbonGroupsScrollButtonFadingHelper;
    function GetTabGroupsScrollButtonHot(AButton: TdxRibbonScrollButton): Boolean;
    function GetTabGroupsScrollButtonPressed(AButton: TdxRibbonScrollButton): Boolean;
  public
    constructor Create(ASite: TdxRibbonGroupsDockControlSite);
    destructor Destroy; override;
    procedure Calculate;
    function GetHitInfo(var AHitInfo: TdxRibbonHitInfo; X, Y: Integer): Boolean;
    procedure InvalidateScrollButtons;
    procedure Paint(ACanvas: TcxCanvas);
    property TabGroupsScrollButtons: TdxRibbonScrollButtons read FTabGroupsScrollButtons;
  end;

  { TdxRibbonGroupsDockControlSite }

  TdxRibbonGroupsDockControlSite = class(TcxControl)
  private
    FRibbon: TdxCustomRibbon;
    FViewInfo: TdxRibbonGroupsDockControlSiteViewInfo;
    function GetDockControl: TdxRibbonGroupsDockControl;
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoCancelMode; override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function MayFocus: Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function NeedsScrollBars: Boolean; override;
    procedure Paint; override;
    procedure SetRedraw(ARedraw: Boolean);

    property Ribbon: TdxCustomRibbon read FRibbon;
    property DockControl: TdxRibbonGroupsDockControl read GetDockControl;
    property ViewInfo: TdxRibbonGroupsDockControlSiteViewInfo read FViewInfo;
  public
    constructor Create(ARibbon: TdxCustomRibbon); reintroduce;
    destructor Destroy; override;
    function CanFocus: Boolean; override;
  end;

  { TdxRibbonElementCustomFadingHelper }

  TdxRibbonElementCustomFadingHelper = class(TdxFadingObjectHelper)
  private
    FRibbon: TdxCustomRibbon;
    function GetFader: TdxFader;
    function GetPainter: TdxRibbonPainter;
    function GetViewInfo: TdxRibbonViewInfo;
  protected
    function CanFade: Boolean; override;
    function IsOurObject(AHotObject: TdxRibbonHitTest): Boolean; virtual;
    // Properites
    property Fader: TdxFader read GetFader;
    property Painter: TdxRibbonPainter read GetPainter;
    property Ribbon: TdxCustomRibbon read FRibbon;
    property ViewInfo: TdxRibbonViewInfo read GetViewInfo;
  public
    constructor Create(ARibbon: TdxCustomRibbon); virtual;
    destructor Destroy; override;
    procedure UpdateHotObject(APrevHotObject: TdxRibbonHitTest;
      AHotObject: TdxRibbonHitTest);
  end;

  { TdxRibbonApplicationButtonFadingHelper }

  TdxRibbonApplicationButtonFadingHelper = class(TdxRibbonElementCustomFadingHelper)
  protected
    function CanFade: Boolean; override;
    procedure DrawFadeImage; override;
    procedure GetFadingParams(out AFadeOutImage: TcxBitmap;
      out AFadeInImage: TcxBitmap; var AFadeInAnimationFrameCount: Integer;
      var AFadeInAnimationFrameDelay: Integer; var AFadeOutAnimationFrameCount: Integer;
      var AFadeOutAnimationFrameDelay: Integer); override;
    function IsOurObject(AHotObject: TdxRibbonHitTest): Boolean; override;
  end;

  { TdxRibbonHelpButtonFadingHelper }

  TdxRibbonHelpButtonFadingHelper = class(TdxRibbonElementCustomFadingHelper)
  protected
    function CanFade: Boolean; override;
    procedure DrawFadeImage; override;
    procedure GetFadingParams(out AFadeOutImage: TcxBitmap;
      out AFadeInImage: TcxBitmap; var AFadeInAnimationFrameCount: Integer;
      var AFadeInAnimationFrameDelay: Integer; var AFadeOutAnimationFrameCount: Integer;
      var AFadeOutAnimationFrameDelay: Integer); override;
    function IsOurObject(AHotObject: TdxRibbonHitTest): Boolean; override;
  end;

  { TdxRibbonMDIButtonFadingHelper }

  TdxRibbonMDIButtonFadingHelper = class(TdxRibbonElementCustomFadingHelper)
  private
    FMDIButton: TdxBarMDIButton;
  protected
    function CanFade: Boolean; override;
    procedure DrawFadeImage; override;
    procedure GetFadingParams(out AFadeOutImage: TcxBitmap;
      out AFadeInImage: TcxBitmap; var AFadeInAnimationFrameCount: Integer;
      var AFadeInAnimationFrameDelay: Integer; var AFadeOutAnimationFrameCount: Integer;
      var AFadeOutAnimationFrameDelay: Integer); override;
    function IsOurObject(AHotObject: TdxRibbonHitTest): Boolean; override;
    property MDIButton: TdxBarMDIButton read FMDIButton;
  end;

  { TdxRibbonTabScrollButtonFadingHelper }

  TdxRibbonTabScrollButtonFadingHelper = class(TdxRibbonElementCustomFadingHelper)
  private
    FScrollButton: TdxRibbonScrollButton;
    function GetTabsViewInfo: TdxRibbonTabsViewInfo;
  protected
    function CanFade: Boolean; override;
    procedure DrawFadeImage; override;
    procedure GetFadingParams(out AFadeOutImage: TcxBitmap;
      out AFadeInImage: TcxBitmap; var AFadeInAnimationFrameCount: Integer;
      var AFadeInAnimationFrameDelay: Integer; var AFadeOutAnimationFrameCount: Integer;
      var AFadeOutAnimationFrameDelay: Integer); override;
    function GetIsButtonVisible: Boolean; virtual;
    function IsOurObject(AHotObject: TdxRibbonHitTest): Boolean; override;
    property IsButtonVisible: Boolean read GetIsButtonVisible;
    property ScrollButton: TdxRibbonScrollButton read FScrollButton;
    property TabsViewInfo: TdxRibbonTabsViewInfo read GetTabsViewInfo;
  end;

  { TdxRibbonGroupsScrollButtonFadingHelper }

  TdxRibbonGroupsScrollButtonFadingHelper = class(TdxRibbonTabScrollButtonFadingHelper)
  private
    FSite: TdxRibbonGroupsDockControlSite;
  protected
    procedure GetFadingParams(out AFadeOutImage: TcxBitmap;
      out AFadeInImage: TcxBitmap; var AFadeInAnimationFrameCount: Integer;
      var AFadeInAnimationFrameDelay: Integer; var AFadeOutAnimationFrameCount: Integer;
      var AFadeOutAnimationFrameDelay: Integer); override;
    function GetIsButtonVisible: Boolean; override;
    function IsOurObject(AHotObject: TdxRibbonHitTest): Boolean; override;
  public
    constructor Create(ASite: TdxRibbonGroupsDockControlSite); reintroduce; virtual;
    property Site: TdxRibbonGroupsDockControlSite read FSite;
  end;

  { TdxCustomRibbon }

  TdxRibbonEvent = procedure(Sender: TdxCustomRibbon) of object;
  TdxRibbonApplicationMenuClickEvent = procedure (Sender: TdxCustomRibbon;
    var AHandled: Boolean) of object;
  TdxRibbonTabChangingEvent = procedure(Sender: TdxCustomRibbon;
    ANewTab: TdxRibbonTab; var Allow: Boolean) of object;
  TdxRibbonTabGroupNotifyEvent = procedure(Sender: TdxCustomRibbon;
    ATab: TdxRibbonTab; AGroup: TdxRibbonTabGroup) of object;
  TdxRibbonHideMinimizedByClickEvent = procedure(Sender: TdxCustomRibbon;
    AWnd: THandle; AShift: TShiftState; const APos: TPoint;
    var AAllowProcessing: Boolean) of object;

  TdxRibbonInternalState = (risCreating, risAppMenuActive);
  TdxRibbonInternalStates = set of TdxRibbonInternalState;

  TdxCustomRibbon = class(TcxControl,
    IdxSkin,
    IdxRibbonFormNonClientPainter,
    IdxRibbonFormNonClientDraw,
    IdxFormKeyPreviewListener,
    IdxBarAccessibleObject)
  private
    FActiveTab: TdxRibbonTab;
    FApplicationButton: TdxRibbonApplicationButton;
    FApplicationButtonPressed: Boolean;
    FApplicationButtonState: TdxApplicationButtonState;
    FBarManager: TdxBarManager;
    FCalculatedFormCaptionHeight: Integer;
    FColorScheme: TdxCustomRibbonSkin;
    FColorSchemeHandlers: TcxEventHandlerCollection;
    FController: TdxRibbonController;
    FDocumentName: TCaption;
    FFading: Boolean;
    FFadingHelperList: TList;
    FFonts: TdxRibbonFonts;
    FFormCaptionHelper: TdxRibbonFormCaptionHelper;
    FGroupsDockControlSite: TdxRibbonGroupsDockControlSite;
    FGroupsPainter: TdxRibbonBarPainter;
    FHelpButtonScreenTip: TdxBarScreenTip;
    FHidden: Boolean;
    FHighlightedTab: TdxRibbonTab;
    FIAccessibilityHelper: IdxBarAccessibilityHelper;
    FInternalItems: TComponentList;
    FInternalState: TdxRibbonInternalStates;
    FLoadedHeight: Integer;
    FLockCount: Integer;
    FLockedCancelHint: Boolean;
    FLockModified: Boolean;
    FPainter: TdxRibbonPainter;
    FPopupMenuItems: TdxRibbonPopupMenuItems;
    FPrevOnApplicationMenuPopup: TNotifyEvent;
    FQuickAccessToolbar: TdxRibbonQuickAccessToolbar;
    FRibbonFormNonClientPainters: TList;
    FShowTabGroups: Boolean;
    FShowTabHeaders: Boolean;
    FSupportNonClientDrawing: Boolean;
    FTabGroupsPopupWindow: TdxRibbonTabGroupsPopupWindow;
    FTabs: TdxRibbonTabCollection;
    FTabsLoaded: Boolean;
    FViewInfo: TdxRibbonViewInfo;
    FOnApplicationMenuClick: TdxRibbonApplicationMenuClickEvent;
    FOnHelpButtonClick: TdxRibbonEvent;
    FOnHideMinimizedByClick: TdxRibbonHideMinimizedByClickEvent;
    FOnMoreCommandsExecute: TdxRibbonEvent;
    FOnTabChanged: TdxRibbonEvent;
    FOnTabChanging: TdxRibbonTabChangingEvent;
    FOnTabGroupCollapsed: TdxRibbonTabGroupNotifyEvent;
    FOnTabGroupExpanded: TdxRibbonTabGroupNotifyEvent;
    procedure CalculateFormCaptionHeight;
    procedure CheckDrawRibbonFormStatusBarBorders(ACanvas: TcxCanvas;
      const AData: TdxRibbonFormData; const ABordersWidth: TRect);
    procedure DrawApplicationMenuHeader(ADC: THandle; AIsClientArea: Boolean);
    function GetApplicationButtonIAccessibilityHelper: IdxBarAccessibilityHelper;
    function GetColorSchemeName: string;
    function GetFader: TdxFader;
    function GetFadingHelper(AIndex: Integer): TdxRibbonElementCustomFadingHelper;
    function GetFadingHelpersCount: Integer;
    function GetIAccessibilityHelper: IdxBarAccessibilityHelper;
    function GetIniSection(const ADelimiter: string; const ASection: string): string;
    function GetIsPopupGroupsMode: Boolean;
    function GetNextActiveTab(ATab: TdxRibbonTab): TdxRibbonTab;
    function GetQATIAccessibilityHelper: IdxBarAccessibilityHelper;
    function GetRibbonForm: TdxCustomRibbonForm;
    function GetStatusBarInterface: IdxRibbonFormStatusBarDraw;
    function GetTabCount: Integer;
    function GetTabsIAccessibilityHelper: IdxBarAccessibilityHelper;
    function GetVisibleTab(Index: Integer): TdxRibbonTab;
    function GetVisibleTabCount: Integer;
    procedure InitCustomizePopupMenu(AItemLinks: TdxBarItemLinks);
    procedure IniFileProceduresAdd;
    procedure IniFileProceduresRemove;
    procedure InitColorScheme;
    function IsOnRibbonMDIForm: Boolean;
    procedure RibbonFormInvalidate;
    procedure SetActiveTab(Value: TdxRibbonTab);
    procedure SetApplicationButton(const Value: TdxRibbonApplicationButton);
    procedure SetApplicationButtonState(const Value: TdxApplicationButtonState);
    procedure SetBarManager(Value: TdxBarManager);
    procedure SetColorScheme(const Value: TdxCustomRibbonSkin);
    procedure SetColorSchemeName(const Value: string);
    procedure SetDocumentName(const Value: TCaption);
    procedure SetFading(const Value: Boolean);
    procedure SetFonts(const Value: TdxRibbonFonts);
    procedure SetHelpButtonScreenTip(const Value: TdxBarScreenTip);
    procedure SetHighlightedTab(const Value: TdxRibbonTab);
    procedure SetPopupMenuItems(const Value: TdxRibbonPopupMenuItems);
    procedure SetQuickAccessToolbar(const Value: TdxRibbonQuickAccessToolbar);
    procedure SetShowTabGroups(const Value: Boolean);
    procedure SetShowTabHeaders(const Value: Boolean);
    procedure SetSupportNonClientDrawing(const Value: Boolean);
    procedure SetTabs(Value: TdxRibbonTabCollection);
    procedure UpdateColorSchemeListeners;
    procedure UpdateNonClientDrawing(const Value: Boolean);
    procedure WMGetObject(var Message: TMessage); message WM_GETOBJECT;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMSelectAppMenuFirstItemControl(var Message: TMessage);
      message CM_SELECTAPPMENUFIRSTITEMCONTROL;
    procedure CMShowKeyTips(var Message: TMessage); message CM_SHOWKEYTIPS;

    procedure ApplicationMenuPopupNotification(Sender: TObject);
    procedure BarManagerLoadIni(Sender: TObject; const AEventArgs);
    procedure BarManagerSaveIni(Sender: TObject; const AEventArgs);

    procedure MDIStateChanged(Sender: TObject; const AEventArgs);
    procedure SystemFontChanged(Sender: TObject; const AEventArgs);
    procedure UpdateColorScheme;
    procedure UpdateRibbonForm(AForm: TCustomForm);
  protected
    //IdxRibbonFormNonClientPainter
    procedure DrawRibbonFormCaption(ACanvas: TcxCanvas; const ABounds: TRect;
      const ACaption: string; const AData: TdxRibbonFormData);
    procedure DrawRibbonFormBorderIcon(ACanvas: TcxCanvas; const ABounds: TRect;
      AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState);
    procedure DrawRibbonFormBorders(ACanvas: TcxCanvas;
      const AData: TdxRibbonFormData; const ABordersWidth: TRect);
    function GetRibbonApplicationButtonRegion: HRGN;
    function GetRibbonFormCaptionHeight: Integer; virtual;
    function GetRibbonFormColor: TColor;
    function GetRibbonLoadedHeight: Integer;
    function GetTaskbarCaption: TCaption; virtual;
    function GetValidPopupMenuItems: TdxRibbonPopupMenuItems; virtual;
    function GetWindowBordersWidth: TRect;
    function HasStatusBar: Boolean;
    procedure RibbonFormCaptionChanged; virtual;
    procedure RibbonFormResized; virtual;
    procedure UpdateNonClientArea; virtual;
    //IdxSkin
    procedure IdxSkin.DrawBackground = SkinDrawBackground;
    procedure IdxSkin.DrawCaption = SkinDrawCaption;
    function IdxSkin.GetCaptionRect = SkinGetCaptionRect;
    function IdxSkin.GetContentOffsets = SkinGetContentOffsets;
    function IdxSkin.GetName = SkinGetName;
    function IdxSkin.GetPartColor = SkinGetPartColor;
    function IdxSkin.GetPartOffset = SkinGetPartOffset;
    procedure DrawTabGroupBackground(DC: HDC; const ARect: TRect; AState: Integer);
    function GetGroupCaptionHeight: Integer;
    function GetGroupContentHeight: Integer;
    function GetGroupHeight: Integer;
    function GetGroupRowHeight: Integer;
    procedure SkinDrawBackground(DC: HDC; const ARect: TRect; APart, AState: Integer);
    procedure SkinDrawCaption(DC: HDC; const ACaption: string; const ARect: TRect;
      APart, AState: Integer);
    function SkinGetCaptionRect(const ARect: TRect; APart: Integer): TRect;
    function SkinGetContentOffsets(APart: Integer): TRect;
    function SkinGetName: string;
    function SkinGetPartColor(APart: Integer; AState: Integer = 0): TColor;
    function SkinGetPartOffset(APart: Integer): Integer;
    //IdxFormKeyPreviewListener
    procedure FormKeyDown(var Key: Word; Shift: TShiftState);
    //IdxBarAccessibleObject
    function GetAccessibilityHelper: IdxBarAccessibilityHelper;
    //IdxRibbonFormNonClientDraw
    procedure IdxRibbonFormNonClientDraw.Add = RibbonFormNonClientDrawAdd;
    procedure IdxRibbonFormNonClientDraw.Remove = RibbonFormNonClientDrawRemove;
    procedure RibbonFormNonClientDrawAdd(AObject: TObject);
    procedure RibbonFormNonClientDrawRemove(AObject: TObject);

  {$IFDEF DELPHI12}
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  {$ENDIF}
    procedure BoundsChanged; override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    function CanScrollTabs: Boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DoCancelMode; override;
    procedure InvalidateApplicationButton;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); override;
    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure FontChanged; override;
  {$IFNDEF DELPHI12}
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  {$ENDIF}
    function GetDesignHitTest(X, Y: Integer; Shift: TShiftState): Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    function MayFocus: Boolean; override;
    procedure Modified; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function NeedsScrollBars: Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure ReadState(Reader: TReader); override;
    procedure SetName(const Value: TComponentName); override;
    procedure SetParent(AParent: TWinControl); override;

    function AddGroupButtonToQAT(ABar: TdxBar): TdxRibbonQuickAccessGroupButton;
    procedure CancelUpdate;
    function CanFade: Boolean;
    function CanPaint: Boolean;
    function CreateApplicationButton: TdxRibbonApplicationButton; virtual;
    function CreateController: TdxRibbonController; virtual;
    function CreateFormCaptionHelper: TdxRibbonFormCaptionHelper; virtual;
    function CreatePainter: TdxRibbonPainter; virtual;
    function CreateQuickAccessToolbar: TdxRibbonQuickAccessToolbar; virtual;
    function CreateGroupsPainter: TdxRibbonBarPainter; virtual;
    function CreateViewInfo: TdxRibbonViewInfo; virtual;
    procedure DesignAddTabGroup(ATab: TdxRibbonTab; ANewToolbar: Boolean);
    function DoApplicationMenuClick: Boolean;
    procedure DoHelpButtonClick; virtual;
    function DoHideMinimizedByClick(AWnd: THandle; AShift: TShiftState; const APos: TPoint): Boolean; virtual;
    function DoTabChanging(ANewTab: TdxRibbonTab): Boolean; virtual;
    procedure DoMoreCommandsExecute; virtual;
    procedure DoTabChanged; virtual;
    procedure DoTabGroupCollapsed(ATab: TdxRibbonTab; AGroup: TdxRibbonTabGroup); virtual;
    procedure DoTabGroupExpanded(ATab: TdxRibbonTab; AGroup: TdxRibbonTabGroup); virtual;

    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; virtual;
    function GetBar(ACustomizingBarControl: TCustomdxBarControl): TdxBar;
    function GetTabClass: TdxRibbonTabClass; virtual;
    function IsBarManagerValid: Boolean;
    function IsLocked: Boolean;
    function IsQuickAccessToolbarValid: Boolean;
    procedure Hide;
    procedure PopulatePopupMenuItems(ALinks: TdxBarItemLinks;
      AItems: TdxRibbonPopupMenuItems; AOnClick: TNotifyEvent);
    procedure PopupMenuItemClick(Sender: TObject);
    procedure RemoveFadingObject(AObject: TObject);
    procedure UpdateFormActionControl(ASetControl: Boolean);
    procedure SetRedraw(ARedraw: Boolean);
    procedure ShowCustomizePopup; virtual;
    procedure UpdateControlsVisibility;
    procedure UpdateHeight; virtual;
    procedure UpdateHiddenActiveTabDockControl;

    procedure AddTab(ATab: TdxRibbonTab);
    procedure RemoveTab(ATab: TdxRibbonTab);
    procedure SetNextActiveTab(ATab: TdxRibbonTab);

    procedure Changed;
    procedure FullInvalidate;
    procedure RecalculateBars;

    property ApplicationButtonIAccessibilityHelper: IdxBarAccessibilityHelper
      read GetApplicationButtonIAccessibilityHelper;
    property QATIAccessibilityHelper: IdxBarAccessibilityHelper
      read GetQATIAccessibilityHelper;
    property TabsIAccessibilityHelper: IdxBarAccessibilityHelper
      read GetTabsIAccessibilityHelper;

    property ApplicationButtonPressed: Boolean read FApplicationButtonPressed write FApplicationButtonPressed;
    property ApplicationButtonState: TdxApplicationButtonState read FApplicationButtonState write SetApplicationButtonState;
    property Fader: TdxFader read GetFader;
    property FormCaptionHelper: TdxRibbonFormCaptionHelper read FFormCaptionHelper;
    property GroupsPainter: TdxRibbonBarPainter read FGroupsPainter;
    property HighlightedTab: TdxRibbonTab read FHighlightedTab write SetHighlightedTab;
    property LockedCancelHint: Boolean read FLockedCancelHint write FLockedCancelHint;
    property TabGroupsPopupWindow: TdxRibbonTabGroupsPopupWindow read FTabGroupsPopupWindow;

    property Controller: TdxRibbonController read FController;
    property Fading: Boolean read FFading write SetFading default False; //todo:
    property FadingHelper[Index: Integer]: TdxRibbonElementCustomFadingHelper read GetFadingHelper;
    property FadingHelpersCount: Integer read GetFadingHelpersCount;
    property GroupsDockControlSite: TdxRibbonGroupsDockControlSite read FGroupsDockControlSite;
    property InternalState: TdxRibbonInternalStates read FInternalState;
    property Painter: TdxRibbonPainter read FPainter;
    property RibbonForm: TdxCustomRibbonForm read GetRibbonForm;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ApplicationMenuPopup: Boolean;
    function AreGroupsVisible: Boolean;
    procedure BeginUpdate;
    function CanFocus: Boolean; override;
    procedure CheckHide;
    procedure CloseTabGroupsPopupWindow;
    procedure EndUpdate;
  {$IFDEF DELPHI12}
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  {$ENDIF}
    function GetTabAtPos(X, Y: Integer): TdxRibbonTab;
    procedure ShowTabGroupsPopupWindow;

    property ActiveTab: TdxRibbonTab read FActiveTab write SetActiveTab;
    property ApplicationButton: TdxRibbonApplicationButton read FApplicationButton write SetApplicationButton;
    property BarManager: TdxBarManager read FBarManager write SetBarManager;
    property ColorScheme: TdxCustomRibbonSkin read FColorScheme write SetColorScheme;
    property ColorSchemeHandlers: TcxEventHandlerCollection read FColorSchemeHandlers;
    property ColorSchemeName: string read GetColorSchemeName write SetColorSchemeName stored True;
    property DocumentName: TCaption read FDocumentName write SetDocumentName;
    property Fonts: TdxRibbonFonts read FFonts write SetFonts;
    property HelpButtonScreenTip: TdxBarScreenTip read FHelpButtonScreenTip write SetHelpButtonScreenTip;
    property Hidden: Boolean read FHidden;
    property IAccessibilityHelper: IdxBarAccessibilityHelper read GetIAccessibilityHelper;
    property IsPopupGroupsMode: Boolean read GetIsPopupGroupsMode;
    property LockCount: Integer read FLockCount;
    property QuickAccessToolbar: TdxRibbonQuickAccessToolbar read FQuickAccessToolbar write SetQuickAccessToolbar;
    property PopupMenuItems: TdxRibbonPopupMenuItems
      read FPopupMenuItems write SetPopupMenuItems
      default [rpmiItems, rpmiMoreCommands, rpmiQATPosition, rpmiQATAddRemoveItem, rpmiMinimizeRibbon];
    property ShowTabGroups: Boolean read FShowTabGroups write SetShowTabGroups default True;
    property ShowTabHeaders: Boolean read FShowTabHeaders write SetShowTabHeaders default True;
    property SupportNonClientDrawing: Boolean read FSupportNonClientDrawing write SetSupportNonClientDrawing default False;
    property TabCount: Integer read GetTabCount;
    property Tabs: TdxRibbonTabCollection read FTabs write SetTabs;
    property ViewInfo: TdxRibbonViewInfo read FViewInfo;
    property VisibleTabCount: Integer read GetVisibleTabCount;
    property VisibleTabs[Index: Integer]: TdxRibbonTab read GetVisibleTab;

    property OnApplicationMenuClick: TdxRibbonApplicationMenuClickEvent
      read FOnApplicationMenuClick write FOnApplicationMenuClick;
    property OnHelpButtonClick: TdxRibbonEvent
      read FOnHelpButtonClick write FOnHelpButtonClick;
    property OnHideMinimizedByClick: TdxRibbonHideMinimizedByClickEvent
      read FOnHideMinimizedByClick write FOnHideMinimizedByClick;
    property OnMoreCommandsExecute: TdxRibbonEvent
      read FOnMoreCommandsExecute write FOnMoreCommandsExecute;
    property OnTabChanged: TdxRibbonEvent
      read FOnTabChanged write FOnTabChanged;
    property OnTabChanging: TdxRibbonTabChangingEvent
      read FOnTabChanging write FOnTabChanging;
    property OnTabGroupCollapsed: TdxRibbonTabGroupNotifyEvent
      read FOnTabGroupCollapsed write FOnTabGroupCollapsed;
    property OnTabGroupExpanded: TdxRibbonTabGroupNotifyEvent
      read FOnTabGroupExpanded write FOnTabGroupExpanded;
  end;

  TdxRibbon = class(TdxCustomRibbon)
  published
    property ApplicationButton;
    property BarManager;
    property ColorSchemeName;
    property DocumentName;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Fonts;
    property HelpButtonScreenTip;
    property PopupMenuItems;
    property QuickAccessToolbar;
    property ShowTabGroups;
    property ShowTabHeaders;
    property SupportNonClientDrawing;
    property Tabs;
    property TabOrder;
    property TabStop;

    property OnApplicationMenuClick;
    property OnHelpButtonClick;
    property OnHideMinimizedByClick;
    property OnMoreCommandsExecute;
    property OnTabChanged;
    property OnTabChanging;
    property OnTabGroupCollapsed;
    property OnTabGroupExpanded;

    property OnClick;
  {$IFDEF DELPHI5}
    property OnContextPopup;
  {$ENDIF}
    property OnDblClick;
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
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
  end;

  { TdxRibbonQuickAccessGroupButton }

  TdxRibbonQuickAccessGroupButton = class(TdxBarItem)
  private
    FToolbar: TdxBar;
    function HasGroupButtonForToolbar(AParentBar, AToolbar: TdxBar): Boolean;
    function IsToolbarDockedInRibbon(ARibbon: TdxCustomRibbon; AToolbar: TdxBar): Boolean;
    procedure SetToolbar(Value: TdxBar);
    procedure ToolbarChanged;
  protected
    function CanBePlacedOn(AParentKind: TdxBarItemControlParentKind;
      AToolbar: TdxBar; out AErrorText: string): Boolean; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

    function GetCaption: string; override;
    function IsCaptionStored: Boolean; override;
    procedure SetCaption(const Value: string); override;
  public
    function IsToolbarAcceptable(AToolbar: TdxBar): Boolean;
  published
    property Toolbar: TdxBar read FToolbar write SetToolbar;
  end;

  { TdxRibbonQuickAccessGroupButtonControl }

  TdxRibbonQuickAccessGroupButtonControl = class(TdxBarButtonLikeControl)
  private
    FPopupBarControl: TdxBarControl;
    function GetItem: TdxRibbonQuickAccessGroupButton;
  protected
    procedure CalcDrawParams(AFull: Boolean = True); override;
    function CanActivate: Boolean; override;
    procedure ControlClick(AByMouse: Boolean; AKey: Char = #0); override;
    procedure DoCloseUp(AHadSubMenuControl: Boolean); override;
    procedure DoDropDown(AByMouse: Boolean); override;
    procedure DoPaint(ARect: TRect; PaintType: TdxBarPaintType); override;
    procedure DropDown(AByMouse: Boolean); override;
    function GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass; override;
    function GetCurrentImage(AViewSize: TdxBarItemControlViewSize; ASelected: Boolean;
      out ACurrentGlyph: TBitmap; out ACurrentImages: TCustomImageList; out ACurrentImageIndex: Integer): Boolean; override;
    function GetHint: string; override;
    function GetViewStructure: TdxBarItemControlViewStructure; override;
    function IsDestroyOnClick: Boolean; override;
    function IsDropDown: Boolean; override;
    procedure ClosePopup;
  public
    destructor Destroy; override;
    function IsDroppedDown: Boolean; override;
    property Item: TdxRibbonQuickAccessGroupButton read GetItem;
  end;

  { TdxRibbonQuickAccessGroupButtonPopupBarControl }

  TdxRibbonQuickAccessGroupButtonPopupBarControl = class(TdxRibbonCollapsedGroupPopupBarControl)
  private
    FGroupButtonControl: TdxRibbonQuickAccessGroupButtonControl;
    FIsActiveChangeLocked: Boolean;
  protected
    function CanActiveChange: Boolean; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure FocusItemControl(AItemControl: TdxBarItemControl); override;
    function GetBehaviorOptions: TdxBarBehaviorOptions; override;
    procedure HideAllByEscape; override;
  public
    constructor CreateForPopup(AGroupButtonControl: TdxRibbonQuickAccessGroupButtonControl); reintroduce; virtual;
    procedure CloseUp; override;
  end;

  { TdxAddGroupButtonEditor }

  TdxAddGroupButtonEditor = class(TdxAddSubItemEditor)
  protected
    class function GetAddedItemClass(const AAddedItemName: string): TdxBarItemClass; override;
    class function GetPopupItemCaption: string; override;
  end;

  { TdxRibbonAccessibilityHelper }

  TdxRibbonAccessibilityHelper = class(TdxBarAccessibilityHelper)
  private
    FKeyTipWindowsManager: IdxBarKeyTipWindowsManager;
    function GetRibbon: TdxCustomRibbon;
  protected
    // IdxBarAccessibilityHelper
    function AreKeyTipsSupported(
      out AKeyTipWindowsManager: IdxBarKeyTipWindowsManager): Boolean; override;
    function GetBarManager: TdxBarManager; override;
    function GetDefaultAccessibleObject: IdxBarAccessibilityHelper; override;

    function GetChild(AIndex: Integer): TcxAccessibilityHelper; override;
    function GetChildCount: Integer; override;
    function GetChildIndex(AChild: TcxAccessibilityHelper): Integer; override;
    function GetOwnerObjectWindow: HWND; override;
    function GetScreenBounds(AChildID: TcxAccessibleSimpleChildElementID): TRect; override;
    function GetState(AChildID: TcxAccessibleSimpleChildElementID): Integer; override;

//    function ChildIsSimpleElement(AIndex: Integer): Boolean; override;
//    function GetChildIndex(AChild: TcxAccessibilityHelper): Integer; override;
//    function GetName(AChildID: TcxAccessibleSimpleChildElementID): string; override;
//    function GetRole(AChildID: TcxAccessibleSimpleChildElementID): Integer; override;
//    function GetSupportedProperties(AChildID: TcxAccessibleSimpleChildElementID): TcxAccessibleObjectProperties; override;

    function LogicalNavigationGetChild(AIndex: Integer): TdxBarAccessibilityHelper; override;
    function LogicalNavigationGetChildIndex(AChild: TdxBarAccessibilityHelper): Integer; override;

    property Ribbon: TdxCustomRibbon read GetRibbon;
  end;

  { TdxRibbonTabCollectionAccessibilityHelper }

  TdxRibbonTabCollectionAccessibilityHelper = class(TdxBarAccessibilityHelper)
  private
    function GetTabCollection: TdxRibbonTabCollection;
  protected
    // IdxBarAccessibilityHelper
    function GetBarManager: TdxBarManager; override;
    function GetDefaultAccessibleObject: IdxBarAccessibilityHelper; override;

    function GetChild(AIndex: Integer): TcxAccessibilityHelper; override;
    function GetChildCount: Integer; override;
    function GetChildIndex(AChild: TcxAccessibilityHelper): Integer; override;
    function GetOwnerObjectWindow: HWND; override;
    function GetParent: TcxAccessibilityHelper; override;
    function GetScreenBounds(AChildID: TcxAccessibleSimpleChildElementID): TRect; override;
    function GetState(AChildID: TcxAccessibleSimpleChildElementID): Integer; override;

//    function ChildIsSimpleElement(AIndex: Integer): Boolean; override;
//    function GetChildIndex(AChild: TcxAccessibilityHelper): Integer; override;
//    function GetName(AChildID: TcxAccessibleSimpleChildElementID): string; override;
//    function GetRole(AChildID: TcxAccessibleSimpleChildElementID): Integer; override;
//    function GetSupportedProperties(AChildID: TcxAccessibleSimpleChildElementID): TcxAccessibleObjectProperties; override;

    function LogicalNavigationGetChild(AIndex: Integer): TdxBarAccessibilityHelper; override;
    function LogicalNavigationGetChildCount: Integer; override;
    function LogicalNavigationGetChildIndex(AChild: TdxBarAccessibilityHelper): Integer; override;

    property TabCollection: TdxRibbonTabCollection read GetTabCollection;
  end;

  { TdxRibbonTabAccessibilityHelper }

  TdxRibbonTabAccessibilityHelper = class(TdxBarAccessibilityHelper)
  private
    function GetTab: TdxRibbonTab;
  protected
    // IdxBarAccessibilityHelper
    function GetBarManager: TdxBarManager; override;
    function GetNextAccessibleObject(
      ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper; override;
    function HandleNavigationKey(var AKey: Word): Boolean; override;
    function IsNavigationKey(AKey: Word): Boolean; override;
    function LogicalNavigationGetNextAccessibleObject(
      AGoForward: Boolean): IdxBarAccessibilityHelper; override;
    procedure Select(ASetFocus: Boolean); override;
    procedure Unselect(ANextSelectedObject: IdxBarAccessibilityHelper); override;

    function GetChild(AIndex: Integer): TcxAccessibilityHelper; override;
    function GetChildCount: Integer; override;
    function GetChildIndex(AChild: TcxAccessibilityHelper): Integer; override;
    function GetOwnerObjectWindow: HWND; override;
    function GetParent: TcxAccessibilityHelper; override;
    function GetScreenBounds(AChildID: TcxAccessibleSimpleChildElementID): TRect; override;
    function GetSelectable: Boolean; override;
    function GetState(AChildID: TcxAccessibleSimpleChildElementID): Integer; override;

    function GetAssignedKeyTip: string; override;
    function GetDefaultKeyTip: string; override;
    procedure GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo); override;
    procedure KeyTipHandler(Sender: TObject); override;
    procedure KeyTipsEscapeHandler; override;

    property Tab: TdxRibbonTab read GetTab;
  public
    procedure CloseUpHandler(AClosedByEscape: Boolean);
  end;

  { TdxRibbonApplicationButtonAccessibilityHelper }

  TdxRibbonApplicationButtonAccessibilityHelper = class(TdxBarAccessibilityHelper)
  private
    FPrevOnApplicationMenuCloseUp: TNotifyEvent;
    procedure ApplicationMenuCloseUpHandler(Sender: TObject);
    function GetRibbon: TdxCustomRibbon;
    procedure ShowApplicationMenu(APostMessage: UINT);
  protected
    // IdxBarAccessibilityHelper
    function GetBarManager: TdxBarManager; override;
    function GetNextAccessibleObject(
      ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper; override;
    function HandleNavigationKey(var AKey: Word): Boolean; override;
    function IsNavigationKey(AKey: Word): Boolean; override;
    procedure Select(ASetFocus: Boolean); override;
    procedure Unselect(ANextSelectedObject: IdxBarAccessibilityHelper); override;

    function GetOwnerObjectWindow: HWND; override;
    function GetParent: TcxAccessibilityHelper; override;
    function GetScreenBounds(AChildID: TcxAccessibleSimpleChildElementID): TRect; override;
    function GetSelectable: Boolean; override;
    function GetState(AChildID: TcxAccessibleSimpleChildElementID): Integer; override;

    function GetAssignedKeyTip: string; override;
    function GetDefaultKeyTip: string; override;
    procedure GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo); override;
    procedure KeyTipHandler(Sender: TObject); override;

    property Ribbon: TdxCustomRibbon read GetRibbon;
  end;

  { TdxRibbonGroupsDockControlAccessibilityHelper }

  TdxRibbonGroupsDockControlAccessibilityHelper = class(TdxDockControlAccessibilityHelper)
  private
    function GetDockControl: TdxRibbonGroupsDockControl;
  protected
    function GetChild(AIndex: Integer): TcxAccessibilityHelper; override;
    function GetChildCount: Integer; override;
    function GetChildIndex(AChild: TcxAccessibilityHelper): Integer; override;
    function GetParent: TcxAccessibilityHelper; override;
    function GetState(AChildID: TcxAccessibleSimpleChildElementID): Integer; override;

    function GetParentForKeyTip: TdxBarAccessibilityHelper; override;

    property DockControl: TdxRibbonGroupsDockControl read GetDockControl;
  end;

  { TdxRibbonQuickAccessBarControlAccessibilityHelper }

  TdxRibbonQuickAccessBarControlAccessibilityHelper = class(TdxBarControlAccessibilityHelper)
  private
    function GetBarControl: TdxRibbonQuickAccessBarControl;
  protected
    function GetChild(AIndex: Integer): TcxAccessibilityHelper; override;
    function GetChildCount: Integer; override;
    function GetChildIndex(AChild: TcxAccessibilityHelper): Integer; override;
    function GetParent: TcxAccessibilityHelper; override;

    procedure DoGetKeyTipsData(AKeyTipsData: TList); override;
    procedure GetItemControlKeyTipPosition(AItemControl: TdxBarItemControl;
      out ABasePoint: TPoint; out AHorzAlign: TAlignment;
      out AVertAlign: TcxAlignmentVert); override;
    function GetNextAccessibleObject(AItemControl: TdxBarItemControl;
      ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper; override;
    function GetParentForKeyTip: TdxBarAccessibilityHelper; override;
    function IsKeyTipContainer: Boolean; override;
    procedure KeyTipsEscapeHandler; override;

    property BarControl: TdxRibbonQuickAccessBarControl read GetBarControl;
  end;

  { TdxRibbonQuickAccessBarControlMarkAccessibilityHelper }

  TdxRibbonQuickAccessBarControlMarkAccessibilityHelper = class(TdxBarControlMarkAccessibilityHelper)
  private
    function GetBarControl: TdxRibbonQuickAccessBarControl;
  protected
    // IdxBarAccessibilityHelper
    function HandleNavigationKey(var AKey: Word): Boolean; override;
    procedure GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo); override;
    function GetKeyTip: string; override;
    procedure KeyTipHandler(Sender: TObject); override;

    property BarControl: TdxRibbonQuickAccessBarControl read GetBarControl;
  end;

  { TdxRibbonGroupBarControlAccessibilityHelper }

  TdxRibbonGroupBarControlAccessibilityHelper = class(TdxBarControlAccessibilityHelper)
  private
    function GetBarControl: TdxRibbonGroupBarControl;
    procedure ShowPopupBarControl;
  protected
    // IdxBarAccessibilityHelper
    function GetNextAccessibleObject(
      ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper; override;
    function HandleNavigationKey(var AKey: Word): Boolean; override;
    function IsNavigationKey(AKey: Word): Boolean; override;
    procedure Select(ASetFocus: Boolean); override;
    procedure Unselect(ANextSelectedObject: IdxBarAccessibilityHelper); override;

    function GetSelectable: Boolean; override;

    function Expand: TCustomdxBarControlAccessibilityHelper; override;
    procedure GetCaptionButtonKeyTipPosition(ACaptionButton: TdxBarCaptionButton;
      out ABasePointY: Integer; out AVertAlign: TcxAlignmentVert); override;
    procedure GetItemControlKeyTipPosition(AItemControl: TdxBarItemControl;
      out ABasePoint: TPoint; out AHorzAlign: TAlignment;
      out AVertAlign: TcxAlignmentVert); override;

    function GetAssignedKeyTip: string; override;
    function GetDefaultKeyTip: string; override;
    procedure GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo); override;
    procedure GetKeyTipData(AKeyTipsData: TList); override;

    function GetNextAccessibleObject(AItemControl: TdxBarItemControl;
      ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper; override;
    function GetParentForKeyTip: TdxBarAccessibilityHelper; override;
    function IsCollapsed: Boolean; override;
    function IsKeyTipContainer: Boolean; override;
    procedure KeyTipHandler(Sender: TObject); override;
    procedure KeyTipsEscapeHandler; override;

    property BarControl: TdxRibbonGroupBarControl read GetBarControl;
  public
    procedure CloseUpHandler(AClosedByEscape: Boolean);
  end;

  { TdxRibbonQuickAccessGroupButtonControlAccessibilityHelper }

  TdxRibbonQuickAccessGroupButtonControlAccessibilityHelper = class(TdxBarButtonLikeControlAccessibilityHelper)
  protected
    function IsDropDownControl: Boolean; override;
    function ShowDropDownWindow: Boolean; override;
  end;

  { TdxRibbonKeyTipWindow }

  TdxRibbonKeyTipWindow = class(TCustomControl)
  private
    FColorScheme: TdxCustomRibbonSkin;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  protected
    function CalcBoundsRect: TRect;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure Paint; override;
    procedure UpdateBounds;
  public
    constructor Create(AColorScheme: TdxCustomRibbonSkin); reintroduce; virtual;
    procedure ShowKeyTip;
    property Caption;
    property Enabled;
  end;

  { TdxRibbonKeyTipWindows }

  TdxRibbonKeyTipWindows = class(TInterfacedObject, IdxBarKeyTipWindowsManager)
  private
    FRibbon: TdxCustomRibbon;
    FWindowList: TcxObjectList;
    function GetColorScheme: TdxCustomRibbonSkin;
    function GetCount: Integer;
  protected
    // IdxBarKeyTipWindowsManager
    procedure Add(const ACaption: string; const ABasePoint: TPoint;
      AHorzAlign: TAlignment; AVertAlign: TcxAlignmentVert; AEnabled: Boolean;
      out AWindow: TObject);
    procedure Delete(AWindow: TObject);
    procedure Show;

    property ColorScheme: TdxCustomRibbonSkin read GetColorScheme;
    property Count: Integer read GetCount;
  public
    constructor Create(ARibbon: TdxCustomRibbon); reintroduce;
    destructor Destroy; override;
  end;

procedure RibbonCheckCreateComponent(var AOwner: TComponent; AClass: TClass);
procedure RibbonDockToolBar(AToolBar: TdxBar; ADockControl: TdxBarDockControl);
procedure RibbonUndockToolBar(AToolBar: TdxBar);

implementation

uses
{$IFDEF DELPHI6}
  Types,
{$ELSE}
  MultiMon,
{$ENDIF}
  dxOffice11, CommCtrl, cxGeometry, dxBarStrs, dxBarSkinConsts,
  dxRibbonGroupLayoutCalculator, Math, cxDrawTextUtils, cxLookAndFeelPainters,
  cxDWMApi, dxUxTheme, dxThemeConsts, dxThemeManager, dxGDIPlusAPI;

const
  dxRibbonTabSeparatorWidth = 1;
  dxRibbonTabsRightSpace    = 6;
  dxRibbonTabsLeftSpace     = 8;

  dxRibbonCollapsedGroupGlyphBackgroundOffsets: TRect = (Left: 3; Top: 3; Right: 3; Bottom: 4);
  dxRibbonEmptyHeight = 24;
  dxRibbonGroupCaptionHeightCorrection = 1;
  dxRibbonGroupCaptionOffsets: TRect = (Left: 0; Top: 1; Right: 0; Bottom: 3);
  dxRibbonGroupContentLeftOffset = 2;
  dxRibbonGroupContentRightOffset = 2;
  dxRibbonGroupRowHeightCorrection = 3;

  dxRibbonGroupsScrollDelta = 10;
  dxCaptionGlowRadius       = 10;

  dxRibbonBarBehaviorOptions: TdxBarBehaviorOptions = [bboAllowShowHints,
    bboClickItemsBySpaceKey, bboMouseCantUnselectNavigationItem, bboUnmoved, bboItemCustomizePopup, bboSubMenuCaptureMouse];

type
  TMouseHookStructEx = packed record
    pt: TPoint;
    hwnd: HWND;
    wHitTestCode: UINT;
    dwExtraInfo: DWORD;
    mouseData: DWORD;
  end;
  PMouseHookStructEx = ^TMouseHookStructEx;

  TCustomdxBarControlAccess = class(TCustomdxBarControl);
  TdxBarAccess = class(TdxBar);
  TdxBarControlAccess = class(TdxBarControl);
  TdxBarAccessibilityHelperAccess = class(TdxBarAccessibilityHelper);
  TdxBarCaptionButtonAccessibilityHelperAccess = class(TdxBarCaptionButtonAccessibilityHelper);
  TdxBarItemControlAccess = class(TdxBarItemControl);
  TdxBarItemControlAccessibilityHelperAccess = class(TdxBarItemControlAccessibilityHelper);
  TdxBarItemLinkAccess = class(TdxBarItemLink);
  TdxBarItemLinksAccess = class(TdxBarItemLinks);
  TdxBarManagerAccess = class(TdxBarManager);
  TdxBarSubMenuControlAccess = class(TdxBarSubMenuControl);

function HasComponentOnForm(AForm: TCustomForm; AClass: TClass): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to AForm.ComponentCount - 1 do
  begin
    if AForm.Components[I] is AClass then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure RibbonCheckCreateComponent(var AOwner: TComponent; AClass: TClass);
begin
  if not CheckGdiPlus then
    raise EdxException.CreateFmt(cxGetResourceString(@dxSBAR_GDIPLUSNEEDED), [AClass.ClassName]);
  if (AOwner = nil) and (Application.MainForm <> nil) then
    AOwner := Application.MainForm;
  if not (AOwner is TCustomForm) then
    raise EdxException.CreateFmt(cxGetResourceString(@dxSBAR_RIBBONBADOWNER), [AClass.ClassName]);
  if HasComponentOnForm(TCustomForm(AOwner), AClass) then
    raise EdxException.CreateFmt(cxGetResourceString(@dxSBAR_RIBBONMORETHANONE), [AClass.ClassName]);
end;

procedure WinControlFullInvalidate(AControl: TWinControl; AIncludeChildren: Boolean = False; AForceUpdate: Boolean = False);
var
  AFlags: Cardinal;
begin
  if (AControl <> nil) and AControl.HandleAllocated and IsWindowVisible(AControl.Handle) then
  begin
    AControl.Invalidate;
    AFlags := RDW_ERASE or RDW_INVALIDATE or RDW_FRAME;
    if AIncludeChildren then
      AFlags := AFlags or RDW_ALLCHILDREN;
    if AForceUpdate then
      AFlags := AFlags or RDW_UPDATENOW or RDW_ERASENOW;
    RedrawWindow(AControl.Handle, nil, 0, AFlags);
    if not AForceUpdate then
      AControl.Update;
  end;
end;

var
  FMouseHook: HHOOK;

function FindRibbon(AWnd: HWND; AFindOnForm: Boolean): TdxCustomRibbon;
var
  AControl: TWinControl;
  I: Integer;
begin
  Result := nil;

  AControl := FindControl(AWnd);
  if AFindOnForm and (AControl is TCustomForm) then
    for I := 0 to AControl.ComponentCount - 1 do
      if AControl.Components[I] is TdxCustomRibbon then
      begin
        Result := TdxCustomRibbon(AControl.Components[I]);
        Break;
      end;

  if Result = nil then
    repeat
      if AControl is TdxCustomRibbon then
      begin
        Result := TdxCustomRibbon(AControl);
        Break;
      end;
      if not IsChildClassWindow(AWnd) then
        Break;
      AWnd := GetParent(AWnd);
      AControl := FindControl(AWnd);
    until AWnd = 0;

  if Result <> nil then
    if Result.Hidden or (not Result.ShowTabHeaders and not Result.ShowTabGroups) then
      Result := nil;
end;

function dxRibbonMouseHook(Code: Integer; wParam: WParam; lParam: LParam): LRESULT; stdcall;
var
  AMHS: PMouseHookStructEx;

  procedure DoRibbonMouseWheel(ARibbon: TdxCustomRibbon);
  var
    AKeyState: TKeyboardState;
  begin
    GetKeyboardState(AKeyState);
    ARibbon.DoMouseWheel(KeyboardStateToShiftState(AKeyState),
      ShortInt(HiWord(AMHS.mouseData)), cxPoint(-1, -1));
  end;

  procedure ForwardMouseWheelMsgToActiveBarControl;
  begin
    SendMessage(ActiveBarControl.Handle, WM_MOUSEWHEEL,
      MakeWParam(ShiftStateToKeys(InternalGetShiftState), HiWord(AMHS.mouseData)),
      MakeLParam(AMHS.pt.X, AMHS.pt.Y));
  end;

var
  ARibbon: TdxCustomRibbon;
begin
  if (Code < 0) or (wParam <> WM_MOUSEWHEEL) or not Mouse.WheelPresent then
  begin
    Result := CallNextHookEx(FMouseHook, Code, wParam, lParam);
    Exit;
  end;

  Result := 0;

  AMHS := PMouseHookStructEx(lParam);
  case BarGetMouseWheelReceiver of
    mwrActiveBarControl:
      begin
        ForwardMouseWheelMsgToActiveBarControl;
        Result := 1;
      end;
    mwrWindow:
      begin
        ARibbon := FindRibbon(WindowFromPoint(AMHS.pt), False);
        if (ARibbon <> nil) and IsWindowEnabled(ARibbon.Handle) then
        begin
          DoRibbonMouseWheel(ARibbon);
          Result := 1;
        end
      end;
  end;

  if Result = 0 then
    Result := CallNextHookEx(FMouseHook, Code, wParam, lParam);
end;

procedure DrawRect(DC: HDC; const R: TRect; AColor: TColor; AExclude: Boolean);
begin
  FillRectByColor(DC, R, AColor);
  if AExclude then
    ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
end;

{$IFNDEF DELPHI6}
function FindMonitor(Handle: HMONITOR): TMonitor;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Screen.MonitorCount - 1 do
    if Screen.Monitors[I].Handle = Handle then
    begin
      Result := Screen.Monitors[I];
      break;
    end;
end;

function GetWorkareaRect(Handle: HMONITOR): TRect;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(Handle, @MonInfo);
  Result := MonInfo.rcWork;
end;

function MonitorFromPoint(const P: TPoint): TMonitor;
begin
  Result := FindMonitor(MultiMon.MonitorFromPoint(P, MONITOR_DEFAULTTONEAREST));
end;

function MonitorFromWindow(const Handle: THandle): TMonitor;
begin
  Result := FindMonitor(MultiMon.MonitorFromWindow(Handle, MONITOR_DEFAULTTONEAREST));
end;
{$ENDIF}

function GetMonitorWorkArea(AWnd: HWND): TRect;
var
  AMonitor: TMonitor;
begin
  if AWnd = 0 then
    AMonitor := {$IFDEF DELPHI6}Screen.{$ENDIF}MonitorFromPoint(GetMouseCursorPos)
  else
    AMonitor := {$IFDEF DELPHI6}Screen.{$ENDIF}MonitorFromWindow(AWnd);
  if Assigned(AMonitor) then
    Result := {$IFDEF DELPHI6}AMonitor.WorkareaRect{$ELSE}GetWorkareaRect(AMonitor.Handle){$ENDIF}
  else
    with Screen do
      Result := cxRectBounds(DesktopLeft, DesktopTop, DesktopWidth, DesktopHeight);
end;

function GetRibbonAccessibilityHelper(AParentWnd: HWND): IdxBarAccessibilityHelper;
var
  ARibbon: TdxCustomRibbon;
begin
  Result := nil;
  ARibbon := FindRibbon(AParentWnd, True);
  if (ARibbon <> nil) and ARibbon.Visible then
    Result := ARibbon.IAccessibilityHelper;
end;

procedure SelectFirstSelectableAccessibleObject(
  AParentObject: TdxBarAccessibilityHelper);
begin
  BarNavigationController.ChangeSelectedObject(False,
    AParentObject.GetFirstSelectableObject);
end;

//routines
procedure RibbonDockToolBar(AToolBar: TdxBar; ADockControl: TdxBarDockControl);
var
  APrevVisible: Boolean;
begin
  if (AToolBar = nil) or (AToolBar.DockControl = ADockControl) then Exit;
  APrevVisible := AToolBar.Visible;
  if not (csLoading in AToolBar.ComponentState) then
    AToolBar.Visible := False;
  try
    AToolBar.DockControl := ADockControl;
  finally
    if not (csLoading in AToolBar.ComponentState) then
      AToolBar.Visible := APrevVisible;
  end;
end;

procedure RibbonUndockToolBar(AToolBar: TdxBar);
var
  APrevVisible: Boolean;
begin
  if (AToolbar = nil) or (csDestroying in AToolbar.ComponentState) then Exit;
  APrevVisible := AToolbar.Visible;
  AToolbar.Visible := False;
  AToolbar.DockControl := nil;
  AToolbar.DockedDockControl := nil;
  AToolbar.DockedDockingStyle := dsNone;
  AToolbar.DockingStyle := dsNone;
  AToolbar.Visible := APrevVisible;
end;

type
  { TdxRibbonGroupBarControlViewInfoHelper }

  TdxRibbonGroupBarControlViewInfoHelper = class(TInterfacedObject,
    IdxRibbonGroupViewInfo)
  private
    FViewInfo: TdxRibbonGroupBarControlViewInfo;

    // IdxRibbonGroupViewInfo
    procedure AddSeparator(const Value: TdxBarItemSeparatorInfo);
    procedure DeleteSeparators;
    function GetContentSize: TSize;
    function GetItemControlCount: Integer;
    function GetItemControlViewInfo(AIndex: Integer): IdxBarItemControlViewInfo;
    function GetMinContentWidth: Integer;
    function GetOffsetsInfo: TdxRibbonGroupOffsetsInfo;
    function GetSeparatorCount: Integer;
    function GetSeparatorInfo(AIndex: Integer): TdxBarItemSeparatorInfo;
    procedure SetContentSize(const Value: TSize);
    procedure SetSeparatorInfo(AIndex: Integer;
      const Value: TdxBarItemSeparatorInfo);
  protected
    property ViewInfo: TdxRibbonGroupBarControlViewInfo read FViewInfo;
  public
    constructor Create(AViewInfo: TdxRibbonGroupBarControlViewInfo);
  end;

constructor TdxRibbonGroupBarControlViewInfoHelper.Create(
  AViewInfo: TdxRibbonGroupBarControlViewInfo);
begin
  inherited Create;
  FViewInfo := AViewInfo;
end;

// IdxRibbonGroupViewInfo
procedure TdxRibbonGroupBarControlViewInfoHelper.AddSeparator(
  const Value: TdxBarItemSeparatorInfo);
begin
  ViewInfo.AddSeparatorInfo(Value.Bounds, Value.Kind, nil);
end;

procedure TdxRibbonGroupBarControlViewInfoHelper.DeleteSeparators;
begin
  ViewInfo.RemoveSeparatorInfos;
end;

function TdxRibbonGroupBarControlViewInfoHelper.GetContentSize: TSize;
begin
  Result := ViewInfo.ContentSize;
end;

function TdxRibbonGroupBarControlViewInfoHelper.GetItemControlCount: Integer;
begin
  Result := ViewInfo.ItemControlCount;
end;

function TdxRibbonGroupBarControlViewInfoHelper.GetItemControlViewInfo(
  AIndex: Integer): IdxBarItemControlViewInfo;
begin
  Result := ViewInfo.ItemControlViewInfos[AIndex];
end;

function TdxRibbonGroupBarControlViewInfoHelper.GetMinContentWidth: Integer;
var
  ABarControl: TdxRibbonGroupBarControl;
begin
  ABarControl := ViewInfo.BarControl;
  Result := ABarControl.Ribbon.GroupsPainter.GetGroupMinWidth(ABarControl);
end;

function TdxRibbonGroupBarControlViewInfoHelper.GetOffsetsInfo: TdxRibbonGroupOffsetsInfo;
begin
  Result.ButtonGroupOffset := IdxSkin(ViewInfo.BarControl.Ribbon).GetPartOffset(DXBAR_BUTTONGROUP);
  Result.ContentLeftOffset := dxRibbonGroupContentLeftOffset;
  Result.ContentRightOffset := dxRibbonGroupContentRightOffset;
end;

function TdxRibbonGroupBarControlViewInfoHelper.GetSeparatorCount: Integer;
begin
  Result := ViewInfo.SeparatorCount;
end;

function TdxRibbonGroupBarControlViewInfoHelper.GetSeparatorInfo(
  AIndex: Integer): TdxBarItemSeparatorInfo;
begin
  Result := ViewInfo.SeparatorInfos[AIndex];
end;

procedure TdxRibbonGroupBarControlViewInfoHelper.SetContentSize(
  const Value: TSize);
begin
  ViewInfo.ContentSize := Value;
end;

procedure TdxRibbonGroupBarControlViewInfoHelper.SetSeparatorInfo(
  AIndex: Integer; const Value: TdxBarItemSeparatorInfo);
begin
  ViewInfo.SeparatorInfos[AIndex] := Value;
end;

{ TdxDesignSelectionHelper }

constructor TdxDesignSelectionHelper.Create(ARibbon: TdxCustomRibbon;
  AOwner: TPersistent; AParent: TPersistent);
begin
  FOwner := AOwner;
  FRibbon := ARibbon;
  FParent := AParent;
end;

//IdxBarSelectableItem
function TdxDesignSelectionHelper.CanDelete(ADestruction: Boolean): Boolean;
begin
  if FOwner is TComponent then
    Result := IdxBarDesigner(GetBarManager).CanDeleteComponent(TComponent(FOwner))
  else
    Result := True;
end;

procedure TdxDesignSelectionHelper.DeleteSelection(
  var AReference: IdxBarSelectableItem; ADestruction: Boolean);
begin
  if CanDelete(ADestruction) then
  begin
    AReference := nil;
    FOwner.Free;
  end;
end;

procedure TdxDesignSelectionHelper.ExecuteCustomizationAction(ABasicAction: TdxBarCustomizationAction);
begin
// do nothing;
end;

function TdxDesignSelectionHelper.GetBarManager: TdxBarManager;
begin
  Result := FRibbon.BarManager;
end;

function TdxDesignSelectionHelper.GetInstance: TPersistent;
begin
  Result := FOwner;
end;

procedure TdxDesignSelectionHelper.GetMasterObjects(AList: TdxObjectList);
begin
  AList.Add(FParent);
end;

function TdxDesignSelectionHelper.GetNextSelectableItem: IdxBarSelectableItem;
begin
  Result := nil;
end;

function TdxDesignSelectionHelper.GetSelectableParent: TPersistent;
begin
  Result := FParent;
end;

function TdxDesignSelectionHelper.GetSelectionStatus: TdxBarSelectionStatus;
begin
  if (GetBarManager <> nil) then
    Result := (GetBarManager as IdxBarDesigner).GetSelectionStatus(FOwner)
  else
    Result := ssUnselected;
end;

function TdxDesignSelectionHelper.GetSupportedActions: TdxBarCustomizationActions;
begin
  Result := [];
end;

procedure TdxDesignSelectionHelper.Invalidate;
begin
  FRibbon.FullInvalidate;
end;

function TdxDesignSelectionHelper.IsComplex: Boolean;
begin
  Result := False;
end;

function TdxDesignSelectionHelper.IsComponentSelected: Boolean;
begin
  Result := (GetBarManager <> nil) and
    (GetBarManager as IdxBarDesigner).IsComponentSelected(FOwner);
end;

procedure TdxDesignSelectionHelper.SelectComponent(
  ASelectionOperation: TdxBarSelectionOperation);
begin
  if GetBarManager <> nil then
    (GetBarManager as IdxBarDesigner).SelectComponent(FOwner, ASelectionOperation);
end;

procedure TdxDesignSelectionHelper.SelectionChanged;
begin
  Invalidate;
end;

function TdxDesignSelectionHelper.SelectParentComponent: Boolean;
begin
  Result := True;
  if GetBarManager <> nil then
    (GetBarManager as IdxBarDesigner).SelectComponent(GetSelectableParent);
end;

{ TdxRibbonTabPainter }

constructor TdxRibbonTabPainter.Create(AColorScheme: TdxCustomRibbonSkin);
begin
  FColorScheme := AColorScheme;
end;

procedure TdxRibbonTabPainter.DrawBackground(ACanvas: TcxCanvas;
  const ABounds: TRect; AState: TdxRibbonTabState);
begin
  ColorScheme.DrawTab(ACanvas.Handle, ABounds, AState);
end;

procedure TdxRibbonTabPainter.DrawTabSeparator(ACanvas: TcxCanvas;
  const ABounds: TRect; Alpha: Byte);
begin
  ColorScheme.DrawTabSeparator(ACanvas.Handle, ABounds, Alpha);
end;

procedure TdxRibbonTabPainter.DrawText(ACanvas: TcxCanvas; const ABounds: TRect;
  const AText: string; AHasSeparator: Boolean);
const
  Flags: array[Boolean] of Integer =
   (cxAlignBottom or cxAlignHCenter or cxSingleLine,
    cxAlignBottom or cxAlignLeft or cxSingleLine);
begin
  ACanvas.Brush.Style := bsClear;
  ACanvas.DrawText(AText, ABounds, Flags[AHasSeparator]);
  ACanvas.Brush.Style := bsSolid;
end;

{ TdxRibbonPainter }

constructor TdxRibbonPainter.Create(ARibbon: TdxCustomRibbon);
begin
  FRibbon := ARibbon;
end;

procedure TdxRibbonPainter.DrawApplicationButton(ACanvas: TcxCanvas;
  const ABounds: TRect; AState: TdxApplicationButtonState);
var
  B: TBitmap;
  R: TRect;
begin
  if not ViewInfo.IsApplicationButtonVisible or cxRectIsEmpty(ABounds) then Exit;
  if ViewInfo.ApplicationButtonFadingHelper.IsEmpty then
    ColorScheme.DrawApplicationButton(ACanvas.Handle, ABounds, AState)
  else
    ViewInfo.ApplicationButtonFadingHelper.DrawImage(ACanvas.Handle, ABounds);

  B := Ribbon.ApplicationButton.Glyph;
  if (B <> nil) and not B.Empty then
    DrawApplicationButtonGlyph(ACanvas, ABounds, B, Ribbon.ApplicationButton.StretchGlyph)
  else
  begin
    R := ABounds;
    InflateRect(R, -9, -9);
    DrawDefaultFormIcon(ACanvas, R);
  end;
end;

procedure TdxRibbonPainter.DrawApplicationButtonGlyph(ACanvas: TcxCanvas;
  const ABounds: TRect; AGlyph: TBitmap; AStretch: Boolean);
var
  R: TRect;
  APrevBrushStyle: TBrushStyle;
begin
  if AStretch then
    R := cxRectInflate(ABounds, -9, -9)
  else
    R := cxRectCenter(ABounds, AGlyph.Width, AGlyph.Height);

  ColorScheme.CorrectApplicationMenuButtonGlyphBounds(R);
  if AGlyph.PixelFormat = pf32bit then
    cxAlphaBlend(ACanvas.Handle, AGlyph, R, cxRect(0, 0, AGlyph.Width, AGlyph.Height), True)
  else
  begin
    APrevBrushStyle := ACanvas.Brush.Style;
    ACanvas.Brush.Style := bsClear;
    ACanvas.Canvas.BrushCopy(R, AGlyph, Rect(0, 0, AGlyph.Width, AGlyph.Height),
      AGlyph.TransparentColor);
    ACanvas.Brush.Style := APrevBrushStyle;
  end;
end;

procedure TdxRibbonPainter.DrawBackground(ACanvas: TcxCanvas; const ABounds: TRect);
var
  R: TRect;
begin
  R := ABounds;
  if ViewInfo.IsQATVisible and not ViewInfo.IsQATAtBottom and
    not ViewInfo.SupportNonClientDrawing then
  begin
    R.Bottom := ViewInfo.QuickAccessToolbarBounds.Bottom;
    ColorScheme.DrawRibbonClientTopArea(ACanvas.Handle, R);
    R := ABounds;
    R.Top := ViewInfo.QuickAccessToolbarBounds.Bottom;
  end;
  ColorScheme.DrawRibbonBackground(ACanvas.Handle, R);
end;

procedure TdxRibbonPainter.DrawBottomBorder(ACanvas: TcxCanvas);
var
  R: TRect;
begin
  R := ViewInfo.Bounds;
  R.Top := R.Bottom - 2;
  ColorScheme.DrawRibbonBottomBorder(ACanvas.Handle, R);
  ACanvas.ExcludeClipRect(R);
end;

procedure TdxRibbonPainter.DrawDefaultFormIcon(ACanvas: TcxCanvas; const ABounds: TRect);
var
  B: TcxBitmap;
begin
  if cxRectIsEmpty(ABounds) then Exit;
  if ViewInfo.UseGlass then
  begin
    B := TcxBitmap.CreateSize(ABounds);
    try
      DrawIconEx(B.Canvas.Handle, 0, 0, GetFormIconHandle, B.Width, B.Height, 0, 0, DI_NORMAL);
      cxDrawImage(ACanvas.Handle, ABounds, ABounds, B, nil, -1, idmNormal);
    finally
      B.Free;
    end;
  end
  else
  begin
    DrawIconEx(ACanvas.Handle, ABounds.Left, ABounds.Top, GetFormIconHandle,
      ABounds.Right - ABounds.Left, ABounds.Bottom - ABounds.Top, 0, 0, DI_NORMAL);
  end;
end;

procedure TdxRibbonPainter.DrawGlowingText(DC: HDC; const AText: string;
  AFont: TFont; const ABounds: TRect; AColor: TColor; AFlags: DWORD);
var
  AMemoryDC: HDC;
  AInfo: TBitmapInfo;
  dib, OldBitmap: HBITMAP;
  dttOpts: TdxDTTOpts;
  P: Pointer;
  ATheme: TdxTheme;
begin
  AMemoryDC := CreateCompatibleDC(DC);

  AInfo.bmiHeader.biSize := SizeOf(TBitmapInfo);
  AInfo.bmiHeader.biWidth := cxRectWidth(ABounds);
  AInfo.bmiHeader.biHeight := -cxRectHeight(ABounds);
  AInfo.bmiHeader.biPlanes := 1;
  AInfo.bmiHeader.biBitCount := 32;
  AInfo.bmiHeader.biCompression := BI_RGB;

  dib := CreateDIBSection(DC, AInfo, DIB_RGB_COLORS, P, 0, 0);
  OldBitmap := SelectObject(AMemoryDC, dib);

  // Draw glowing text
  SelectObject(AMemoryDC, AFont.Handle);
  dttOpts.dwSize := SizeOf(TdxDTTOpts);
  dttOpts.dwFlags := DTT_COMPOSITED or DTT_GLOWSIZE or DTT_TEXTCOLOR;
  dttOpts.crText := ColorToRGB(AColor);
  dttOpts.iGlowSize := dxCaptionGlowRadius; // This is about the size Microsoft Word 2007 uses

  ATheme := OpenTheme(totWindow);
  DrawThemeTextEx(ATheme, AMemoryDC, 0, 0, AText, -1, AFlags,
    cxRect(0, 0, ABounds.Right - ABounds.Left, ABounds.Bottom - ABounds.Top), dttOpts);

  // Copy to foreground
  cxBitBlt(DC, AMemoryDC, ABounds, cxNullPoint, SRCCOPY);

  // Clean up
  SelectObject(AMemoryDC, OldBitmap);
  DeleteObject(dib);
  DeleteDC(AMemoryDC);
end;

procedure TdxRibbonPainter.DrawGroupsArea(ACanvas: TcxCanvas; const ABounds: TRect);
begin
  ColorScheme.DrawTabGroupsArea(ACanvas.Handle, ABounds);
end;

procedure TdxRibbonPainter.DrawGroupsScrollButton(ACanvas: TcxCanvas;
  const ABounds: TRect; ALeft, APressed, AHot: Boolean);
var
  AState: Integer;
begin
  if APressed then
    AState := DXBAR_PRESSED
  else
    if AHot then
      AState := DXBAR_HOT
    else
      AState := DXBAR_NORMAL;
  ColorScheme.DrawGroupScrollButton(ACanvas.Handle, ABounds, ALeft, AState);
end;

procedure TdxRibbonPainter.DrawGroupsScrollButtonArrow(ACanvas: TcxCanvas;
  const ABounds: TRect; ALeft: Boolean);
const
  ArrowDirection: array[Boolean] of TcxArrowDirection = (adRight, adLeft);
begin
  if ColorScheme.NeedDrawGroupScrollArrow then
    TcxCustomLookAndFeelPainter.DrawArrow(ACanvas,
      cxRectInflate(ABounds, -2, 0, -2, -2), ArrowDirection[ALeft], clBlack);
end;

procedure TdxRibbonPainter.DrawQuickAccessToolbar(ACanvas: TcxCanvas;
  const ABounds: TRect; AIsActive: Boolean);
begin
  if not ViewInfo.IsQATAtNonClientArea then
  begin
    ACanvas.SaveClipRegion;
    ACanvas.SetClipRegion(TcxRegion.Create(ABounds), roIntersect);
    DrawBackground(ACanvas, ViewInfo.Bounds);
    ACanvas.RestoreClipRegion;
  end;
  ColorScheme.DrawQuickAccessToolbar(ACanvas.Handle, ABounds,
    ViewInfo.IsQATAtBottom, ViewInfo.SupportNonClientDrawing,
    ViewInfo.IsApplicationButtonVisible, AIsActive, not ViewInfo.UseGlass);
end;

procedure TdxRibbonPainter.DrawTabScrollButton(ACanvas: TcxCanvas;
  const ABounds: TRect; ALeft, APressed, AHot: Boolean);
var
  AState: Integer;
begin
  if APressed then
    AState := DXBAR_PRESSED
  else
    if AHot then
      AState := DXBAR_HOT
    else
      AState := DXBAR_NORMAL;
  ColorScheme.DrawTabScrollButton(ACanvas.Handle, ABounds, ALeft, AState);
end;

procedure TdxRibbonPainter.DrawTabScrollButtonGlyph(ACanvas: TcxCanvas;
  const ABounds: TRect; ALeft: Boolean);
const
  ArrowDirection: array[Boolean] of TcxArrowDirection = (adRight, adLeft);
begin
  TcxCustomLookAndFeelPainter.DrawArrow(ACanvas,
    cxRectInflate(ABounds, -2, 0, -2, -4), ArrowDirection[ALeft], clBlack);
end;

procedure TdxRibbonPainter.DrawHelpButton(ACanvas: TcxCanvas;
  const ABounds: TRect; AState: TdxBorderIconState);
begin
  if ViewInfo.HelpButtonFadingHelper.IsEmpty then
    ColorScheme.DrawHelpButton(ACanvas.Handle, ABounds, AState)
  else
    ViewInfo.HelpButtonFadingHelper.DrawImage(ACanvas.Handle, ABounds);
  ColorScheme.DrawHelpButtonGlyph(ACanvas.Handle, ABounds, nil); //!!!todo:
  ACanvas.ExcludeClipRect(ABounds);
end;

procedure TdxRibbonPainter.DrawMDIButton(ACanvas: TcxCanvas;
  const ABounds: TRect; AButton: TdxBarMDIButton; AState: TdxBorderIconState);
begin
  if ViewInfo.FMDIButtonFadingHelpers[AButton].IsEmpty then
    ColorScheme.DrawMDIButton(ACanvas.Handle, ABounds, AButton, AState)
  else
    ViewInfo.FMDIButtonFadingHelpers[AButton].DrawImage(ACanvas.Handle, ABounds);
  ColorScheme.DrawMDIButtonGlyph(ACanvas.Handle, ABounds, AButton, AState);
  ACanvas.ExcludeClipRect(ABounds);
end;

procedure TdxRibbonPainter.DrawRibbonFormCaptionText(ACanvas: TcxCanvas;
  const ABounds: TRect; const ADocumentName, ACaption: string;
  const AData: TdxRibbonFormData);
var
  R: TRect;
begin
  ACanvas.Font := ViewInfo.GetFormCaptionFont(AData.Active);
  R := ABounds;
  if UseAeroNCPaint(AData) then
    DrawRibbonGlassFormCaptionText(ACanvas, ABounds, ADocumentName, ACaption, True)
  else
    cxTextOut(ACanvas.Handle, ADocumentName + ACaption, R,
      CXTO_PREVENT_LEFT_EXCEED or CXTO_CENTER_HORIZONTALLY or
      CXTO_CENTER_VERTICALLY or CXTO_SINGLELINE or CXTO_END_ELLIPSIS,
      0, Length(ADocumentName), nil, clNone, ViewInfo.GetDocumentNameTextColor(AData.Active));
end;

procedure TdxRibbonPainter.DrawRibbonGlassFormCaptionText(ACanvas: TcxCanvas;
  const ABounds: TRect; const ADocumentName, ACaption: string; AIsActive: Boolean);

  function IsFormZoomed: Boolean;
  var
    F: TCustomForm;
  begin
    F := Ribbon.RibbonForm;
    Result := (F <> nil) and F.HandleAllocated and IsZoomed(F.Handle);
  end;

var
  R: TRect;
  S: string;
begin
  if IsFormZoomed then
  begin
    ACanvas.Brush.Style := bsClear;
    ACanvas.Font.Color := clWhite;
    ACanvas.DrawTexT(ADocumentName + ACaption, ABounds, cxAlignLeft or
      cxAlignVCenter or cxSingleLine or cxShowEndEllipsis);
    ACanvas.Brush.Style := bsSolid;
  end
  else
  begin
    R := ABounds;
    S := cxGetStringAdjustedToWidth(ACanvas.Handle, ACanvas.Font.Handle,
      ADocumentName + ACaption, cxRectWidth(R) - 2 * dxCaptionGlowRadius);
    R.Right := R.Left + cxTextWidth(ACanvas.Font, S) + 2 * dxCaptionGlowRadius;
    DrawGlowingText(ACanvas.Handle, S, ACanvas.Font, R, ACanvas.Font.Color,
      DT_CENTER or DT_SINGLELINE or DT_END_ELLIPSIS or DT_VCENTER or DT_NOPREFIX);
  end;
end;

procedure TdxRibbonPainter.DrawRibbonFormCaption(ACanvas: TcxCanvas;
  const ABounds: TRect; const AData: TdxRibbonFormData);
begin
  if not UseAeroNCPaint(AData) then
    ColorScheme.DrawFormCaption(ACanvas.Handle, ABounds, AData);
  if Ribbon.Hidden then
    DrawDefaultFormIcon(ACanvas, Ribbon.FormCaptionHelper.SysMenuIconBounds)
  else
  begin
    if ViewInfo.IsQATAtNonClientArea then
      DrawQuickAccessToolbar(ACanvas, ViewInfo.QuickAccessToolbarBounds, AData.Active);
    if ViewInfo.IsApplicationButtonVisible then
      DrawApplicationButton(ACanvas, ViewInfo.ApplicationButtonImageBounds,
        ViewInfo.ApplicationButtonState)
    else
      DrawDefaultFormIcon(ACanvas, Ribbon.FormCaptionHelper.SysMenuIconBounds);
  end;
  DrawRibbonFormCaptionText(ACanvas, ViewInfo.FormCaptionBounds,
    ViewInfo.GetDocumentName, ViewInfo.GetCaption, AData);
end;

procedure TdxRibbonPainter.DrawRibbonFormBorderIcon(ACanvas: TcxCanvas;
  const ABounds: TRect; AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState);
begin
  ColorScheme.DrawFormBorderIcon(ACanvas.Handle, ABounds, AIcon, AState);
end;

procedure TdxRibbonPainter.DrawRibbonFormBorders(ACanvas: TcxCanvas;
  const ABordersWidth: TRect; const AData: TdxRibbonFormData);
begin
  ColorScheme.DrawFormBorders(ACanvas.Handle, ABordersWidth,
    Ribbon.GetRibbonFormCaptionHeight, AData);
end;

procedure TdxRibbonPainter.DrawEmptyRibbon(ACanvas: TcxCanvas);
var
  ABrush: HBRUSH;
  APrevBkColor: TColor;
begin
  APrevBkColor := GetBkColor(ACanvas.Handle);
  SetBkColor(ACanvas.Handle, clSilver);
  ABrush := CreateHatchBrush(HS_BDIAGONAL, clBlack);
  FillRect(ACanvas.Handle, ViewInfo.Bounds, ABrush);
  DeleteObject(ABrush);
  SetBkColor(ACanvas.Handle, APrevBkColor);
end;

function TdxRibbonPainter.GetFormIconHandle: HICON;
var
  F: TCustomForm;
begin
  F := GetParentForm(Ribbon);
  if F is TForm then
    Result := TForm(F).Icon.Handle
  else
    Result := 0;
  if Result = 0 then
    Result := Application.Icon.Handle;
end;

function TdxRibbonPainter.GetColorScheme: TdxCustomRibbonSkin;
begin
  Result := Ribbon.ColorScheme;
end;

function TdxRibbonPainter.GetViewInfo: TdxRibbonViewInfo;
begin
  Result := Ribbon.ViewInfo;
end;

{ TdxRibbonTabViewInfo }

constructor TdxRibbonTabViewInfo.Create(ATab: TdxRibbonTab);
begin
  inherited Create;
  FTab := ATab;
  FPainter := GetPainterClass.Create(ATab.Ribbon.ColorScheme);
end;

destructor TdxRibbonTabViewInfo.Destroy;
begin
  FPainter.Free;
  inherited Destroy;
end;

procedure TdxRibbonTabViewInfo.Calculate(const ABounds: TRect; ASeparatorAlpha: Byte);
begin
  Bounds := ABounds;
  FSeparatorAlphaValue := ASeparatorAlpha;
  if HasSeparator then
    FSeparatorBounds := GetSeparatorBounds
  else
    FSeparatorBounds := cxEmptyRect;
  FTextBounds := GetTextBounds;
end;

function TdxRibbonTabViewInfo.HasSeparator: Boolean;
begin
  Result := FCanHasSeparator and (FSeparatorAlphaValue > 0);
end;

procedure TdxRibbonTabViewInfo.Paint(ACanvas: TcxCanvas);
begin
  DrawBackground(ACanvas);
  with Painter do
  begin
    ACanvas.Font := Font;
    DrawText(ACanvas, TextBounds, Tab.Caption, SeparatorAlphaValue = 255);
    if HasSeparator then
      DrawTabSeparator(ACanvas, SeparatorBounds, SeparatorAlphaValue);
    if Tab.DesignSelectionHelper.IsComponentSelected then
      ACanvas.DrawDesignSelection(cxRectInflate(Bounds, -2, -2));
  end;
end;

procedure TdxRibbonTabViewInfo.DrawBackground(ACanvas: TcxCanvas);
begin
  if Tab.FFadingElementData = nil then
    Painter.DrawBackground(ACanvas, Bounds, State)
  else
    Tab.FFadingElementData.DrawImage(ACanvas.Handle, Bounds);
end;

procedure TdxRibbonTabViewInfo.CalculateWidths;
begin
  Canvas.Font := Tab.Ribbon.Fonts.TabHeader;
  FTextWidth := Canvas.TextWidth(Tab.Caption);
  FOptimalWidth := FTextWidth + dxRibbonOptimalTabSpace;
  FMinWidth := Max(Canvas.TextWidth(Copy(Tab.Caption, 1, 3)) + dxRibbonTabTextOffset * 2,
    dxRibbonOptimalTabSpace);
end;

function TdxRibbonTabViewInfo.GetPainterClass: TdxRibbonTabPainterClass;
begin
  Result := TdxRibbonTabPainter;
end;

function TdxRibbonTabViewInfo.GetTextBounds: TRect;
begin
  Result := cxRectInflate(Bounds, -dxRibbonTabTextOffset, -4);
end;

function TdxRibbonTabViewInfo.GetSeparatorBounds: TRect;
begin
  Result := cxRect(Bounds.Right - dxRibbonTabSeparatorWidth, Bounds.Top,
    Bounds.Right, Bounds.Bottom - 1);
end;

function TdxRibbonTabViewInfo.GetState: TdxRibbonTabState;

  function GetFocusedState: TdxRibbonTabState;
  begin
    if Tab.Ribbon.AreGroupsVisible then
      Result := rtsFocused
    else
      Result := rtsHot;
  end;

begin
  with Tab do
  begin
    if Focused then
      Result := GetFocusedState
    else
      if not (Highlighted or Active) then
        Result := rtsNormal
      else
      begin
        if Tab.Ribbon.AreGroupsVisible then
        begin
          if Active then
          begin
            if Highlighted and not Tab.Ribbon.IsPopupGroupsMode then
              Result := rtsActiveHot
            else
              Result := rtsActive
          end
          else
            if Highlighted then
              Result := rtsHot
            else
              Result := rtsNormal;
        end
        else
          if Highlighted then
            Result := rtsHot
          else
            Result := rtsNormal;
      end;
  end;
end;

function TdxRibbonTabViewInfo.IsSelected: Boolean;
begin
  Result := Tab.DesignSelectionHelper.IsComponentSelected;
end;

function TdxRibbonTabViewInfo.PrepareFadeImage(ADrawHot: Boolean): TcxBitmap;
const
  ActiveStatesMap: array[Boolean] of TdxRibbonTabState = (rtsActive, rtsActiveHot);
  StatesMap: array[Boolean] of TdxRibbonTabState = (rtsNormal, rtsHot);
var
  AState: TdxRibbonTabState;
  R: TRect;
begin
  R := Bounds;
  OffsetRect(R, -R.Left, -R.Top);
  Result := TcxBitmap.CreateSize(R, pf32bit);
  Result.Canvas.Font := Font;
  if Tab.Active and Tab.Ribbon.AreGroupsVisible then
    AState := ActiveStatesMap[ADrawHot and not Tab.Ribbon.IsPopupGroupsMode]
  else
    AState := StatesMap[ADrawHot];
  Painter.DrawBackground(Result.cxCanvas, R, AState);
end;

function TdxRibbonTabViewInfo.GetCanvas: TcxCanvas;
begin
  Result := FTab.Ribbon.Canvas;
end;

function TdxRibbonTabViewInfo.GetFont: TFont;

  function GetTabState: Integer;
  begin
    //(rtsNormal, rtsHot, rtsActive, rtsActiveHot, rtsFocused);
    if Tab.Active and Tab.Ribbon.AreGroupsVisible then
      Result := DXBAR_ACTIVE
    else
      if State = rtsNormal then
        Result := DXBAR_NORMAL
      else
        Result := DXBAR_HOT;
  end;

begin
  Result := Tab.Ribbon.Fonts.GetTabHeaderFont(GetTabState);
end;

{ TdxRibbonTabsViewInfo }

constructor TdxRibbonTabsViewInfo.Create(AOwner: TdxRibbonViewInfo);
var
  AButton: TdxRibbonScrollButton;
begin
  inherited Create;
  FOwner := AOwner;
  for AButton := Low(AButton) to High(AButton) do
  begin
    FScrollButtonFadingHelpers[AButton] :=
      TdxRibbonTabScrollButtonFadingHelper.Create(AOwner.Ribbon);
    FScrollButtonFadingHelpers[AButton].FScrollButton := AButton;
  end;
end;

destructor TdxRibbonTabsViewInfo.Destroy;
var
  AButton: TdxRibbonScrollButton;
begin
  for AButton := Low(AButton) to High(AButton) do
    FScrollButtonFadingHelpers[AButton].Free;
  inherited Destroy;
end;

procedure TdxRibbonTabsViewInfo.Calculate(const ABounds: TRect);
var
  I, AHigh, AWidth: Integer;
begin
  FBounds := ABounds;
  FNeedShowHint := False;
  FScrollButtons := [];
  FSeparatorAlpha := 0;
  AWidth := ABounds.Right - ABounds.Left;
  FTotalMinimalWidth := 0;
  FTotalOptimalWidth := 0;
  FHasButtonOnRight := Owner.HasMDIButtons or Owner.HasHelpButton;
  AHigh := Count - 1;
  for I := 0 to AHigh do
    with Items[I] do
    begin
      CalculateWidths;
      Inc(FTotalOptimalWidth, OptimalWidth);
      Inc(FTotalMinimalWidth, MinWidth);
      FCanHasSeparator := (I < AHigh) or FHasButtonOnRight;
    end;
  if FTotalOptimalWidth <= AWidth then
    CalculateSimpleTabLayout
  else if FTotalMinimalWidth <= AWidth then
    CalculateComplexTabLayout
  else
    CalculateScrollingTabLayout;
end;

procedure TdxRibbonTabsViewInfo.Clear;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  inherited Clear;
end;

function TdxRibbonTabsViewInfo.GetHitInfo(var AHitInfo: TdxRibbonHitInfo;
  X, Y: Integer): Boolean;
var
  I: Integer;
begin
  AHitInfo.Tab := nil;
  if (rsbLeft in ScrollButtons) and cxRectPtIn(FScrollButtonBounds[rsbLeft], X, Y) then
    AHitInfo.HitTest := rhtTabScrollLeft
  else if (rsbRight in ScrollButtons) and cxRectPtIn(FScrollButtonBounds[rsbRight], X, Y) then
    AHitInfo.HitTest := rhtTabScrollRight
  else
    if cxRectPtIn(GetRealBounds, X, Y) then
      for I := 0 to Count - 1 do
        if cxRectPtIn(Items[I].Bounds, X, Y) then
        begin
          AHitInfo.HitTest := rhtTab;
          AHitInfo.Tab := Items[I].Tab;
          Break;
        end;
  Result := AHitInfo.HitTest in [rhtTab, rhtTabScrollLeft, rhtTabScrollRight];
end;

function TdxRibbonTabsViewInfo.GetRealBounds: TRect;
begin
  Result := Bounds;
  if rsbLeft in ScrollButtons then
    Result.Left := FScrollButtonBounds[rsbLeft].Right;
  if rsbRight in ScrollButtons then
    Result.Right := FScrollButtonBounds[rsbRight].Left;
end;

procedure TdxRibbonTabsViewInfo.Invalidate;
begin
  Owner.Ribbon.InvalidateRect(Bounds, False);
end;

procedure TdxRibbonTabsViewInfo.InvalidateScrollButtons;
var
  ARegion: TcxRegion;
begin
  ARegion := TcxRegion.Create(cxNullRect);
  try
    if rsbLeft in ScrollButtons then
      ARegion.Combine(TcxRegion.Create(ScrollButtonBounds[rsbLeft]), roAdd);
    if rsbRight in ScrollButtons then
      ARegion.Combine(TcxRegion.Create(ScrollButtonBounds[rsbRight]), roAdd);
    Owner.Ribbon.InvalidateRgn(ARegion, False);
  finally
    ARegion.Free;
  end;
end;

procedure TdxRibbonTabsViewInfo.MakeTabVisible(ATab: TdxRibbonTab);
var
  P, I: Integer;
  R: TRect;
begin
  if ScrollButtons = [] then Exit;
  for I := 0 to Count - 1 do
    if Items[I].Tab = ATab then
    begin
      R := Items[I].Bounds;
      P := ScrollPosition;
      if R.Left < Bounds.Left then
      begin
        Dec(P, Bounds.Left - R.Left);
        if I > 0 then
          Dec(P, Owner.ScrollButtonWidth);
      end
      else if R.Right > Bounds.Right then
      begin
        Inc(P, R.Right - Bounds.Right);
        if I < Count - 1 then
          Inc(P, Owner.ScrollButtonWidth);
      end;
      SetScrollPosition(P);
      Break;
    end;
end;

procedure TdxRibbonTabsViewInfo.Paint(ACanvas: TcxCanvas);

  procedure DrawScrollButtons;
  var
    AButton: TdxRibbonScrollButton;
  begin
    for AButton := Low(AButton) to High(AButton) do
      if AButton in ScrollButtons then
        DrawScrollButton(ACanvas, ScrollButtonBounds[AButton], AButton,
          ScrollButtonPressed[AButton], ScrollButtonHot[AButton]);
  end;

  procedure ExcludeTabs;
  var
    I: Integer;
    R: TRect;
  begin
    for I := 0 to Count - 1 do
    begin
      R := Items[I].Bounds;
      cxRectIntersect(R, R, Bounds);
      if not cxRectIsEmpty(R) then
        ACanvas.ExcludeClipRect(R);
    end;
  end;

var
  I: Integer;
begin
  DrawScrollButtons;
  ACanvas.SaveClipRegion;
  ACanvas.IntersectClipRect(GetRealBounds);
  for I := 0 to Count - 1 do
    Items[I].Paint(ACanvas);
  ACanvas.RestoreClipRegion;
  ExcludeTabs;
end;

procedure TdxRibbonTabsViewInfo.UpdateDockControls;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Tab.UpdateDockControl;
end;

procedure TdxRibbonTabsViewInfo.UpdateTabList;
var
  I: Integer;
  ATab: TdxRibbonTab;
begin
  Clear;
  for I := 0 to Owner.Ribbon.TabCount - 1 do
  begin
    ATab := Owner.Ribbon.Tabs[I];
    if ATab.Visible then
      Add(Owner.GetTabViewInfoClass.Create(ATab));
  end;
end;

procedure TdxRibbonTabsViewInfo.BalancedReduce(ATotalDelta: Integer);
var
  I: Integer;
  ALimit: Integer;
  AHasReduce: Boolean;
begin
  FSeparatorAlpha := 255;
  ALimit := GetLongestTabWidth - 1;
  repeat
    AHasReduce := False;
    for I := 0 to Count - 1 do
      with Items[I] do
        if (Width > ALimit) and (Width > GetRealMinItemWidth(I)) then
        begin
          AHasReduce := True;
          Dec(FWidth);
          Dec(ATotalDelta);
          if ATotalDelta = 0 then
            Break;
        end;
    Dec(ALimit);
  until (ATotalDelta = 0) or not AHasReduce;
  FNeedShowHint := AHasReduce;
end;

procedure TdxRibbonTabsViewInfo.CalculateComplexTabLayout;
var
  I, ADelta, ASimpleReduceWidth: Integer;
  R: TRect;
begin
  RemoveScrolling;
  R := Bounds;
  ADelta := FTotalOptimalWidth - (R.Right - R.Left);
  ASimpleReduceWidth := dxRibbonTabIndent * Count;
  if ADelta <= ASimpleReduceWidth then
    SimpleReduce(ADelta)
  else
  begin
    Dec(ADelta, ASimpleReduceWidth);
    BalancedReduce(ADelta);
  end;
  for I := 0 to Count - 1 do
    with Items[I] do
    begin
      R.Right := R.Left + FWidth;
      Calculate(R, FSeparatorAlpha);
      R.Left := R.Right;
    end;
end;

procedure TdxRibbonTabsViewInfo.CalculateScrollingTabLayout;
var
  I, AHight: Integer;
  R: TRect;
begin
  R := Bounds;
  FSeparatorAlpha := 255;
  FScrollWidth := GetScrollWidth;
  CheckScrollPosition(FScrollPosition);
  Dec(R.Left, FScrollPosition);
  AHight := Count - 1;
  for I := 0 to AHight do
    with Items[I] do
    begin
      R.Right := R.Left + GetRealMinItemWidth(I);
      Calculate(R, FSeparatorAlpha);
      R.Left := R.Right;
    end;
  CalculateScrollButtons;
  FNeedShowHint := True;
end;

procedure TdxRibbonTabsViewInfo.CalculateSimpleTabLayout;
var
  I, AHight: Integer;
  R: TRect;
begin
  RemoveScrolling;
  R := Bounds;
  AHight := Count - 1;
  for I := 0 to AHight do
    with Items[I] do
    begin
      R.Right := R.Left + OptimalWidth;
      Calculate(R, 0);
      R.Left := R.Right;
    end;
end;

procedure TdxRibbonTabsViewInfo.DrawScrollButton(ACanvas: TcxCanvas;
  const ABounds: TRect; AButton: TdxRibbonScrollButton; APressed, AHot: Boolean);
begin
  if FScrollButtonFadingHelpers[AButton].IsEmpty then
    Painter.DrawTabScrollButton(ACanvas, ABounds, AButton = rsbLeft, APressed, AHot)
  else
    FScrollButtonFadingHelpers[AButton].DrawImage(ACanvas.Handle, ABounds);
  Painter.DrawTabScrollButtonGlyph(ACanvas, ABounds, AButton = rsbLeft);
  ACanvas.ExcludeClipRect(ABounds);
end;

procedure TdxRibbonTabsViewInfo.SimpleReduce(ATotalDelta: Integer);
var
  I, ADelta, ARemainder: Integer;
begin
  FSeparatorAlpha := MulDiv(ATotalDelta, 255,
    Count * (dxRibbonOptimalTabSpace - dxRibbonTabTextOffset * 2));
  ADelta := ATotalDelta div Count;
  ARemainder := ATotalDelta - (Count * ADelta);
  for I := Count - 1 downto 0 do
    with Items[I] do
    begin
      FWidth := OptimalWidth - ADelta;
      if Count - I <= ARemainder then
        Dec(FWidth);
    end;
end;

procedure TdxRibbonTabsViewInfo.CalculateScrollButtons;
var
  AButtonWidth: Integer;
begin
  AButtonWidth := Owner.GetScrollButtonWidth;
  if FScrollPosition = 0 then
    FScrollButtons := [rsbRight]
  else if FScrollPosition = FScrollWidth then
    FScrollButtons := [rsbLeft]
  else
    FScrollButtons := [rsbLeft, rsbRight];
  with Bounds do
  begin
    if rsbLeft in ScrollButtons then
      FScrollButtonBounds[rsbLeft] := cxRect(Left, Top, Left + AButtonWidth, Bottom);
    if rsbRight in ScrollButtons then
      FScrollButtonBounds[rsbRight] := cxRect(Right - AButtonWidth, Top, Right, Bottom);
  end;
end;

procedure TdxRibbonTabsViewInfo.CheckScrollPosition(var Value: Integer);
begin
  Value := Min(Max(0, Value), FScrollWidth);
end;

function TdxRibbonTabsViewInfo.GetLongestTabWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    with Items[I] do
    begin
      FWidth := TextWidth + dxRibbonTabTextOffset * 2;
      Result := Max(Result, Width);
    end;
end;

function TdxRibbonTabsViewInfo.GetPainter: TdxRibbonPainter;
begin
  Result := Owner.Painter;
end;

function TdxRibbonTabsViewInfo.GetRealMinItemWidth(Index: Integer): Integer;
begin
  Result := GetTabViewInfo(Index).MinWidth;
  if Index < Count - 1 then
    Inc(Result, dxRibbonTabSeparatorWidth);
end;

function TdxRibbonTabsViewInfo.GetScrollButtonBounds(Index: TdxRibbonScrollButton): TRect;
begin
  Result := FScrollButtonBounds[Index];
end;

function TdxRibbonTabsViewInfo.GetScrollButtonHot(Index: TdxRibbonScrollButton): Boolean;
begin
  with Owner.Ribbon.Controller do
    Result :=
      ((HotObject = rhtTabScrollLeft) and (Index = rsbLeft)) or
      ((HotObject = rhtTabScrollRight) and (Index = rsbRight));
end;

function TdxRibbonTabsViewInfo.GetScrollButtonPressed(Index: TdxRibbonScrollButton): Boolean;
begin
  with Owner.Ribbon.Controller do
    Result :=
      ((ScrollKind = rhtTabScrollLeft) and (Index = rsbLeft)) or
      ((ScrollKind = rhtTabScrollRight) and (Index = rsbRight));
end;

function TdxRibbonTabsViewInfo.GetScrollWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    Inc(Result, GetRealMinItemWidth(I));
  Dec(Result, Bounds.Right - Bounds.Left);
end;

function TdxRibbonTabsViewInfo.GetTabViewInfo(
  Index: Integer): TdxRibbonTabViewInfo;
begin
  Result := inherited Items[Index];
end;

procedure TdxRibbonTabsViewInfo.RemoveScrolling;
begin
  FScrollPosition := 0;
  FScrollButtons := [];
  FScrollButtonBounds[rsbLeft] := cxEmptyRect;
  FScrollButtonBounds[rsbRight] := cxEmptyRect;
end;

procedure TdxRibbonTabsViewInfo.SetScrollPosition(Value: Integer);
begin
  CheckScrollPosition(Value);
  if FScrollPosition <> Value then
  begin
    FScrollPosition := Value;
    Owner.Ribbon.Changed;
    //CalculateScrollingTabLayout;
    //Owner.Ribbon.InvalidateRect(Bounds, False);
  end;
end;

{ TdxRibbonViewInfo }

constructor TdxRibbonViewInfo.Create(ARibbon: TdxCustomRibbon);
var
  AButton: TdxBarMDIButton;
begin
  inherited Create;
  FRibbon := ARibbon;
  FFont := TFont.Create;
  FTabsViewInfo := TdxRibbonTabsViewInfo.Create(Self);
  FApplicationButtonFadingHelper :=
    TdxRibbonApplicationButtonFadingHelper.Create(ARibbon);
  for AButton := Low(TdxBarMDIButton) to High(TdxBarMDIButton) do
  begin
    FMDIButtonFadingHelpers[AButton] :=
      TdxRibbonMDIButtonFadingHelper.Create(ARibbon);
    FMDIButtonFadingHelpers[AButton].FMDIButton := AButton;
  end;
  FHelpButtonFadingHelper := TdxRibbonHelpButtonFadingHelper.Create(ARibbon);
end;

destructor TdxRibbonViewInfo.Destroy;
var
  AButton: TdxBarMDIButton;
begin
  FApplicationButtonFadingHelper.Free;
  FHelpButtonFadingHelper.Free;
  for AButton := Low(TdxBarMDIButton) to High(TdxBarMDIButton) do
    FMDIButtonFadingHelpers[AButton].Free;
  FTabsViewInfo.Free;
  FFont.Free;
  inherited Destroy;
end;

procedure TdxRibbonViewInfo.Calculate(const ABounds: TRect);
var
  AForm: TdxCustomRibbonForm;
begin
  FBounds := ABounds;
  AForm := Ribbon.RibbonForm;
  FSupportNonClientDrawing := Ribbon.SupportNonClientDrawing and (AForm <> nil);
  FUseGlass := FSupportNonClientDrawing and AForm.IsUseAeroNCPaint;
  Ribbon.Fonts.UpdateFonts;
  CalculateApplicationButton;
  CalculateQuickAccessToolbar;
  CalculateRibbonFormCaption;
  if (Ribbon.Hidden xor IsNeedHideControl) then
  begin
    Ribbon.FHidden := not Ribbon.FHidden;
    Calculate(ABounds);
    Ribbon.UpdateHiddenActiveTabDockControl;
  end
  else
  begin
    TabsViewInfo.UpdateTabList;
    CalculateTabGroups;
    CalculateMDIButtons;
    CalculateHelpButton;
    CalculateTabs;
    Ribbon.UpdateHeight;
  end;
end;

function TdxRibbonViewInfo.GetDocumentNameTextColor(AIsActive: Boolean): TColor;
begin
  Result := Ribbon.Fonts.DocumentNameColor;
  if Result = clDefault then
    Result := Ribbon.ColorScheme.GetPartColor(rspDocumentNameText, Ord(not AIsActive));
end;

function TdxRibbonViewInfo.GetFormCaptionFont(AIsActive: Boolean): TFont;
begin
  Result := Ribbon.Fonts.GetFormCaptionFont(AIsActive);
end;

function TdxRibbonViewInfo.GetFormCaptionText: TCaption;
begin
  Result := GetDocumentName + GetCaption;
end;

function TdxRibbonViewInfo.GetHitInfo(X, Y: Integer): TdxRibbonHitInfo;
begin
  Result.HitTest := rhtNone;
  Result.Tab := nil;
  CheckButtonsHitTest(Result.HitTest, X, Y);
  if (Result.HitTest = rhtNone) and
    not (TabsViewInfo.GetHitInfo(Result, X, Y) or GroupsDockControlSiteViewInfo.GetHitInfo(Result, X, Y)) then
  begin
    if IsApplicationButtonVisible and cxRectPtIn(ApplicationButtonImageBounds, X, Y) then
      Result.HitTest := rhtApplicationMenu;
  end;
end;

function TdxRibbonViewInfo.GetTabAtPos(X, Y: Integer): TdxRibbonTab;
var
  I: Integer;
begin
  for I := 0 to TabsViewInfo.Count - 1 do
    if PtInRect(TabsViewInfo[I].Bounds, Point(X, Y)) then
    begin
      Result := TabsViewInfo[I].Tab;
      Exit;
    end;
  Result := nil;
end;

procedure TdxRibbonViewInfo.Paint(ACanvas: TcxCanvas);
begin
  if DrawEmptyRibbon then
  begin
    Painter.DrawEmptyRibbon(ACanvas);
    Exit;
  end;
  DrawRibbonBackground(ACanvas);
  if HasMDIButtons then
    DrawMDIButtons(ACanvas);
  if HasHelpButton then
    DrawHelpButton(ACanvas);
  if IsQATVisible and not IsQATAtNonClientArea then
    Painter.DrawQuickAccessToolbar(ACanvas, QuickAccessToolbarBounds, True);
  if IsNeedDrawBottomLine then
    Painter.DrawBottomBorder(ACanvas);
  if IsTabsVisible and (TabsViewInfo.Count > 0) then
    TabsViewInfo.Paint(ACanvas);
  if IsTabGroupsVisible then
    Painter.DrawGroupsArea(ACanvas, GroupsDockControlSiteBounds);
  if IsApplicationButtonVisible then
    Painter.DrawApplicationButton(ACanvas, ApplicationButtonImageBounds,
      ApplicationButtonState);
end;

procedure TdxRibbonViewInfo.UpdateQATDockControl;
begin
  with QATDockControl do
  begin
    HandleNeeded;
    Visible := IsQATVisible;
    if Visible then
      BoundsRect := GetQATDockControlBounds
    else
      UpdateBoundsRect(GetQATDockControlBounds);
  end;
end;

function TdxRibbonViewInfo.GetRibbonHeight: Integer;
begin
  if IsQATVisible and IsQATAtBottom then
    Result := GetQATBounds.Bottom
  else
  begin
    if IsTabGroupsVisible and not Ribbon.IsPopupGroupsMode then
      Result := GetGroupsDockControlSiteBounds.Bottom
    else
      Result := TabsHeight + GetTabsVerticalOffset + 1;
  end;
  FDrawEmptyRibbon := (Result < 8) and Ribbon.IsDesigning;
  if FDrawEmptyRibbon then
    Result := dxRibbonEmptyHeight;
end;

procedure TdxRibbonViewInfo.CalculateApplicationButton;
begin
  if IsApplicationButtonVisible then
  begin
    FApplicationButtonBounds := GetApplicationButtonBounds;
    FApplicationButtonImageBounds := GetApplicationButtonImageBounds;
  end
  else
  begin
    FApplicationButtonBounds := cxEmptyRect;
    FApplicationButtonImageBounds := cxEmptyRect;
  end;
end;

procedure TdxRibbonViewInfo.CalculateQuickAccessToolbar;
begin
  if IsQATVisible then
  begin
    FQATBarControlSize := GetQATBarControlSize;
    FQuickAccessToolbarBounds := GetQATBounds;
  end
  else
    FQuickAccessToolbarBounds := cxEmptyRect;
  UpdateQATDockControl;
end;

procedure TdxRibbonViewInfo.CalculateRibbonFormCaption;
begin
  if SupportNonClientDrawing then
    FFormCaptionBounds := GetRibbonFormCaptionTextBounds
  else
    FFormCaptionBounds := cxEmptyRect;
end;

procedure TdxRibbonViewInfo.CalculateTabGroups;
begin
  if IsTabGroupsVisible and not Ribbon.IsPopupGroupsMode then
  begin
    FGroupsDockControlSiteBounds := GetGroupsDockControlSiteBounds;
    FTabGroupsDockControlBounds := GetTabGroupsDockControlBounds;
  end
  else
  begin
    FGroupsDockControlSiteBounds := cxEmptyRect;
    FTabGroupsDockControlBounds := cxEmptyRect;
  end;
  if not Ribbon.IsPopupGroupsMode then
  begin
    UpdateGroupsDockControlSite;
    if IsTabGroupsVisible then
      TabsViewInfo.UpdateDockControls;
  end;
end;

procedure TdxRibbonViewInfo.CalculateTabs;
begin
  if IsTabsVisible and (TabsViewInfo.Count > 0) then
    TabsViewInfo.Calculate(GetTabsBounds);
end;

procedure TdxRibbonViewInfo.CheckButtonsHitTest(var AHitTest: TdxRibbonHitTest; X: Integer; Y: Integer);
begin
  if HasMDIButtons then
    CheckMDIButtonsHitTest(AHitTest, X, Y);
  if (AHitTest = rhtNone) and HasHelpButton then
    CheckHelpButtonHitTest(AHitTest, X, Y);
end;

function TdxRibbonViewInfo.GetApplicationButtonBounds: TRect;
begin
  with GetApplicationButtonSize do
    Result := cxRectBounds(0, 0, cx, cy);
  with GetApplicationButtonOffset do
  begin
    Inc(Result.Right, Left + Right);
    Inc(Result.Bottom, Top + Bottom);
  end;
end;

function TdxRibbonViewInfo.GetApplicationButtonGlyphSize: TSize;
begin
  Result := Ribbon.ColorScheme.GetApplicationMenuGlyphSize;
end;

function TdxRibbonViewInfo.GetApplicationButtonImageBounds: TRect;
begin
   Result := cxRectCenter(ApplicationButtonBounds, GetApplicationButtonSize);
end;

function TdxRibbonViewInfo.GetApplicationButtonOffset: TRect;
begin
  Result := cxRect(WidthToCurrentDpi(dxRibbonApplicationButtonIndent),
    WidthToCurrentDpi(dxRibbonApplicationButtonIndent * 2 + 2),
    WidthToCurrentDpi(dxRibbonApplicationButtonIndent), 0);
end;

function TdxRibbonViewInfo.GetApplicationButtonRegion: HRGN;
begin
  if IsApplicationButtonVisible then
    Result := CreateRectRgnIndirect(ApplicationButtonBounds)
  else
    Result := 0;
end;

function TdxRibbonViewInfo.GetApplicationButtonSize: TSize;
begin
  with GetApplicationButtonGlyphSize do
  begin
    Result.cx := WidthToCurrentDpi(cx);
    Result.cy := WidthToCurrentDpi(cy);
  end;
end;

function TdxRibbonViewInfo.GetApplicationButtonState: TdxApplicationButtonState;
begin
  if Ribbon.ApplicationButtonIAccessibilityHelper.IsSelected then
    Result := absHot
  else
    Result := Ribbon.ApplicationButtonState;
end;

function TdxRibbonViewInfo.GetNonClientAreaHeight: Integer;
begin
  if SupportNonClientDrawing then
    Result := Ribbon.GetRibbonFormCaptionHeight
  else
    Result := 0;
end;

function TdxRibbonViewInfo.GetCaption: string;
begin
  if Ribbon.RibbonForm <> nil then
  begin
    Result := Ribbon.RibbonForm.Caption;
    if GetDocumentName <> '' then
      Result := ' - ' + Result;
  end
  else
    Result := '';
end;

function TdxRibbonViewInfo.GetDocumentName: string;
begin
  Result := Ribbon.DocumentName;
end;

function TdxRibbonViewInfo.GetRibbonFormCaptionClientBounds: TRect;
begin
  Result := Ribbon.FormCaptionHelper.TextBounds;
  if not Ribbon.Hidden then
  begin
    if IsQATAtNonClientArea then
      Result.Left := GetQATBounds.Right +
        Ribbon.ColorScheme.GetQuickAccessToolbarRightIndent(IsApplicationButtonVisible)
    else
      if IsApplicationButtonVisible then
        Result.Left := ApplicationButtonBounds.Right;
    Result.Bottom := GetNonClientAreaHeight;
  end;
end;

function TdxRibbonViewInfo.GetRibbonFormCaptionTextBounds: TRect;
var
  W, AExtraSpace: Integer;
  R: TRect;
begin
  Result := GetRibbonFormCaptionClientBounds;
  InflateRect(Result, -dxRibbonFormCaptionTextSpace, 0);
  W := cxTextWidth(GetFormCaptionFont(True), GetFormCaptionText);
  if UseGlass then
    AExtraSpace := 2 * dxCaptionGlowRadius // add a glow radious around text
  else
    AExtraSpace := 0;
  Inc(W, AExtraSpace);
  R := cxRect(Bounds.Left + dxRibbonFormCaptionTextSpace,
    Result.Top, Bounds.Right - dxRibbonFormCaptionTextSpace, Result.Bottom);
  W := cxRectWidth(R) - W;
  if (W >= 0) {and (Ribbon.RibbonForm.FormStyle <> fsMDIChild)} then
  begin
    Inc(R.Left, W div 2);
    Dec(R.Right, W div 2 - 1);
    if cxRectContain(Result, R) then
      Result := R;
  end;
end;

function TdxRibbonViewInfo.GetQATAvailWidth: Integer;
var
  R: TRect;
  ALeft, ARight: Integer;
begin
  ALeft := 0;
  ARight := Bounds.Right;
  if not IsQATAtBottom then
  begin
    if IsApplicationButtonVisible then
      ALeft := ApplicationButtonBounds.Right - GetQATOverrideWidth;
    if SupportNonClientDrawing then
    begin
      R := Ribbon.FormCaptionHelper.TextBounds;
      Inc(R.Left, Ribbon.ColorScheme.GetQuickAccessToolbarRightIndent(IsApplicationButtonVisible));
      if UseGlass then
        Dec(R.Right, 2 * dxCaptionGlowRadius);
      ALeft := Max(R.Left, ALeft);
      ARight := R.Right - dxRibbonFormCaptionMinWidth;
    end;
  end;
  Result := Max(ARight - ALeft, 0);
end;

function TdxRibbonViewInfo.GetQATBarControlSize: TSize;
var
  AControl: TdxBarControl;
  AvailControlWidth: Integer;
begin
  Result.cx := 0;
  Result.cy := 0;
  if IsQATVisible then
  begin
    AControl := Ribbon.QuickAccessToolbar.Toolbar.Control;
    if AControl is TdxRibbonQuickAccessBarControl then
    begin
      AvailControlWidth := GetQATAvailWidth;
      with GetQATDockControlOffset do
        Dec(AvailControlWidth, Left + Right);
      Result := TdxRibbonQuickAccessBarControl(AControl).GetSize(AvailControlWidth);
    end;
  end;
end;

function TdxRibbonViewInfo.GetQATBounds: TRect;
begin
  Result := cxRectBounds(GetQATLeft, GetQATTop, GetQATWidth, GetQATHeight);
end;

function TdxRibbonViewInfo.GetQATHeight: Integer;
begin
  Result := 0;
  if IsQATVisible then
  begin
    Result := FQATBarControlSize.cy;
    with GetQATDockControlOffset do
      Inc(Result, Top + Bottom);
  end;
end;

function TdxRibbonViewInfo.GetQATLeft: Integer;
var
  AApplicationButtonVisible: Boolean;
begin
  Result := Bounds.Left;
  if not IsQATAtBottom then
  begin
    AApplicationButtonVisible := IsApplicationButtonVisible;
    Inc(Result, 2);
    if AApplicationButtonVisible then
      Result := ApplicationButtonBounds.Right - GetQATOverrideWidth
    else
      if SupportNonClientDrawing then
        Result := Ribbon.FormCaptionHelper.TextBounds.Left + 4;
    Inc(Result, Ribbon.ColorScheme.GetQuickAccessToolbarLeftIndent(
      AApplicationButtonVisible, UseGlass));
  end;
end;

function TdxRibbonViewInfo.GetQATOverrideWidth(AIgnoreHidden: Boolean = False): Integer;
begin
  Result := Ribbon.ColorScheme.GetQuickAccessToolbarOverrideWidth(
    IsApplicationButtonVisible(AIgnoreHidden), UseGlass);
end;

function TdxRibbonViewInfo.GetQATTop: Integer;
begin
  Result := 0;
  if IsQATAtBottom then
  begin
    Result := GetNonClientAreaHeight;
    if IsTabsVisible then
      Inc(Result, TabsHeight - 1);
    if IsTabGroupsVisible and not Ribbon.IsPopupGroupsMode then
      Inc(Result, GetTabGroupsHeight);
  end;
end;

function TdxRibbonViewInfo.GetQATWidth: Integer;
begin
  Result := 0;
  if IsQATVisible then
  begin
    if not IsQATAtBottom then
    begin
      Result := FQATBarControlSize.cx;
      with GetQATDockControlOffset do
        Inc(Result, Left + Right);
    end
    else
      Result := Bounds.Right;
  end;
end;

function TdxRibbonViewInfo.GetQATDockControlBounds: TRect;
begin
  with GetQATDockControlOffset do
    Result := cxRectInflate(QuickAccessToolbarBounds, -Left, -Top, -Right, -Bottom);
  Result.Right := Result.Left + FQATBarControlSize.cx;
end;

function TdxRibbonViewInfo.GetQATDockControlOffset(AIgnoreHidden: Boolean = False): TRect;
var
  H: Integer;
begin
  if not IsQATAtBottom then
  begin
    Result := cxRect(GetQATOverrideWidth(AIgnoreHidden) + 1, 0, 0, 0);
    if (FQATBarControlSize.cx <> 0) and (Ribbon.GetValidPopupMenuItems = []) then
    begin
      Inc(Result.Right, ((FQATBarControlSize.cy + 2) div 2) or 1);
      Inc(Result.Right, 12);
    end;
    if SupportNonClientDrawing then
    begin
      H := GetNonClientAreaHeight - FQATBarControlSize.cy;
      Result.Bottom := H div 2;
      Result.Top := H - Result.Bottom;
    end
    else
    begin
      Result.Top := 4;
      Result.Bottom := 5;
    end;
  end
  else
    Result := cxRect(2, 2, 2, 2);
end;

function TdxRibbonViewInfo.GetGroupsDockControlSiteBounds: TRect;
begin
  Result := Bounds;
  Inc(Result.Top, GetTabsVerticalOffset);
  Inc(Result.Top, GetTabsHeight);
  if IsTabsVisible then
    Dec(Result.Top);
  Result.Bottom := Result.Top + GetTabGroupsHeight;
end;

function TdxRibbonViewInfo.GetTabGroupsDockControlBounds: TRect;
begin
  Result := GetGroupsDockControlSiteBounds;
  OffsetRect(Result, -Result.Left, -Result.Top);
  with GetTabGroupsDockControlOffset do
    Result := cxRectInflate(Result, -Left, -Top, -Right, -Bottom);
end;

function TdxRibbonViewInfo.GetTabGroupsDockControlOffset: TRect;
begin
  Result := cxRect(4, 3, 4, 4);
end;

function TdxRibbonViewInfo.GetTabsBounds: TRect;
begin
  Result := Bounds;
  Result.Left := Max(ApplicationButtonBounds.Right, dxRibbonTabsLeftSpace);
  if HasHelpButton then
    Result.Right := FHelpButtonBounds.Left  - 1
  else
    if HasMDIButtons then
      Result.Right := FMDIButtonBounds[mdibMinimize].Left - 1
    else
      Dec(Result.Right, dxRibbonTabsRightSpace);
  Result.Bottom := Result.Top + TabsHeight;
  OffsetRect(Result, 0, GetTabsVerticalOffset);
end;

function TdxRibbonViewInfo.GetTabsHeight: Integer;
var
  AFont: TFont;
begin
  Result := 0;
  if not IsTabsVisible then
    Exit;
  AFont := Ribbon.Fonts.TabHeader;
  Result := Abs(AFont.Height) * 2 + 2;
end;

function TdxRibbonViewInfo.GetTabGroupsHeight(AIgnoreHidden: Boolean = False): Integer;
begin
  if IsTabGroupsVisible or AIgnoreHidden then
  begin
    Result := Ribbon.GetGroupHeight;
    with GetTabGroupsDockControlOffset do
      Inc(Result, Top + Bottom);
  end
  else
    Result := 0;
end;

function TdxRibbonViewInfo.GetTabViewInfoClass: TdxRibbonTabViewInfoClass;
begin
  Result := TdxRibbonTabViewInfo;
end;

procedure TdxRibbonViewInfo.CalculateMDIButtons;
var
  AButton: TdxBarMDIButton;
  R: TRect;
begin
  if HasMDIButtons then
  begin
    R := Bounds;
    R.Bottom := R.Top + TabsHeight - 2;
    OffsetRect(R, 0, GetTabsVerticalOffset);
    R.Left := R.Right - (R.Bottom - R.Top);
    for AButton := High(AButton) downto Low(AButton) do
    begin
      FMDIButtonBounds[AButton] := R;
      OffsetRect(R, -(R.Right - R.Left), 0);
    end;
  end
  else
    for AButton := Low(AButton) to High(AButton) do
      FMDIButtonBounds[AButton] := cxEmptyRect;
end;

procedure TdxRibbonViewInfo.DrawMDIButtons(ACanvas: TcxCanvas);
var
  AButton: TdxBarMDIButton;
begin
  for AButton := Low(AButton) to High(AButton) do
    Painter.DrawMDIButton(ACanvas, FMDIButtonBounds[AButton], AButton, GetMDIButtonState(AButton));
end;

function TdxRibbonViewInfo.HasMDIButtons: Boolean;
begin
  if not Ribbon.Hidden and IsTabsVisible and Ribbon.IsBarManagerValid then
    Result := Ribbon.BarManager.IsMDIMaximized and (GetSystemMenu(Ribbon.BarManager.ActiveMDIChild, False) <> 0)
  else
    Result := False;
end;

procedure TdxRibbonViewInfo.InvalidateMDIButtons;
var
  R: TRect;
begin
  if not HasMDIButtons then Exit;
  R := FMDIButtonBounds[mdibMinimize];
  R.Right := FMDIButtonBounds[mdibClose].Right;
  Ribbon.InvalidateRect(R, False);
end;

function TdxRibbonViewInfo.IsMDIButtonEnabled(AButton: TdxBarMDIButton;
  AState: Integer): Boolean;
begin
  Result := ((AButton = mdibRestore) or
     (GetMenuState(GetSystemMenu(Ribbon.BarManager.ActiveMDIChild, False),
      MDIButtonCommands[AButton], MF_BYCOMMAND) and AState = 0));
end;

function TdxRibbonViewInfo.IsApplicationButtonVisible(AIgnoreHidden: Boolean = False): Boolean;
begin
  Result := (not Ribbon.Hidden or AIgnoreHidden) and 
    Ribbon.ApplicationButton.Visible and IsTabsVisible(AIgnoreHidden) and
    (SupportNonClientDrawing or (IsQATVisible(AIgnoreHidden) and not IsQATAtBottom));
end;

function TdxRibbonViewInfo.IsQATAtNonClientArea(AIgnoreHidden: Boolean = False): Boolean;
begin
  Result := SupportNonClientDrawing and not IsQATAtBottom and
    IsQATVisible(AIgnoreHidden);
end;

function TdxRibbonViewInfo.IsQATOnGlass: Boolean;
begin
  Result := UseGlass and IsQATAtNonClientArea;
end;

function TdxRibbonViewInfo.IsQATVisible(AIgnoreHidden: Boolean = False): Boolean;
begin
  with Ribbon.QuickAccessToolbar do
    Result := CanShowBarControls(AIgnoreHidden) and
      Visible and (Toolbar <> nil) and Toolbar.Visible;
end;

function TdxRibbonViewInfo.IsTabGroupsVisible(AIgnoreHidden: Boolean = False): Boolean;
begin
  Result := CanShowBarControls(AIgnoreHidden) and
    (Ribbon.ShowTabGroups or Ribbon.IsPopupGroupsMode) and (TabsViewInfo.Count > 0);
end;

function TdxRibbonViewInfo.IsTabsVisible(AIgnoreHidden: Boolean = False): Boolean;
begin
  Result := (not Ribbon.Hidden or AIgnoreHidden) and Ribbon.ShowTabHeaders;
end;

procedure TdxRibbonViewInfo.CalculateHelpButton;
begin
  if HasHelpButton then
  begin
    FHelpButtonBounds := Bounds;
    FHelpButtonBounds.Bottom := FHelpButtonBounds.Top + TabsHeight - 2;
    OffsetRect(FHelpButtonBounds, 0, GetTabsVerticalOffset);
    if HasMDIButtons then
      FHelpButtonBounds.Right := FMDIButtonBounds[mdibMinimize].Left;
    FHelpButtonBounds.Left := FHelpButtonBounds.Right -
      (FHelpButtonBounds.Bottom - FHelpButtonBounds.Top);
  end
  else
    FHelpButtonBounds := cxEmptyRect;
end;

function TdxRibbonViewInfo.CanShowBarControls(
  AIgnoreHidden: Boolean = False): Boolean;
begin
  Result := Ribbon.IsBarManagerValid and (not Ribbon.Hidden or AIgnoreHidden);
end;

procedure TdxRibbonViewInfo.DrawHelpButton(ACanvas: TcxCanvas);
begin
  Painter.DrawHelpButton(ACanvas, FHelpButtonBounds, GetButtonState(rhtHelpButton));
end;

procedure TdxRibbonViewInfo.DrawRibbonBackground(ACanvas: TcxCanvas);
var
  R: TRect;
begin
  R := Bounds;
  R.Top := FFormCaptionBounds.Bottom;
  ACanvas.SaveClipRegion;
  ACanvas.IntersectClipRect(R);
  Painter.DrawBackground(ACanvas, Bounds);
  ACanvas.RestoreClipRegion;
end;

function TdxRibbonViewInfo.HasHelpButton: Boolean;
begin
  if not Ribbon.Hidden and IsTabsVisible then
    Result := Assigned(Ribbon.OnHelpButtonClick)
  else
    Result := False;
end;

procedure TdxRibbonViewInfo.InvalidateHelpButton;
begin
  if HasHelpButton then
    Ribbon.InvalidateRect(FHelpButtonBounds, False);
end;

function TdxRibbonViewInfo.IsNeedDrawBottomLine: Boolean;
begin
  Result := IsTabsVisible and (not IsTabGroupsVisible or Ribbon.IsPopupGroupsMode) and
    (not IsQATVisible or not IsQATAtBottom);
end;

function TdxRibbonViewInfo.IsNeedHideControl: Boolean;
var
  F: TCustomForm;
begin
  if Ribbon.IsDesigning then
  begin
    Result := False;
    Exit;
  end;
  F := GetParentForm(Ribbon);
  Result := (F <> nil) and
    (IsIconic(F.Handle) or (F.Width < dxRibbonOwnerMinimalWidth) or
    (F.Height < dxRibbonOwnerMinimalHeight));
end;

function TdxRibbonViewInfo.IsQATAtBottom: Boolean;
begin
  Result := Ribbon.QuickAccessToolbar.Position = qtpBelowRibbon;
end;

procedure TdxRibbonViewInfo.CheckHelpButtonHitTest(var AHitTest: TdxRibbonHitTest; X: Integer; Y: Integer);
begin
  if cxRectPtIn(FHelpButtonBounds, X, Y) then
    AHitTest := rhtHelpButton;
end;

procedure TdxRibbonViewInfo.CheckMDIButtonsHitTest(var AHitTest: TdxRibbonHitTest; X: Integer; Y: Integer);
const
  MDIButtonToHitTest: array[TdxBarMDIButton] of TdxRibbonHitTest =
    (rhtMDIMinimizeButton, rhtMDIRestoreButton, rhtMDICloseButton);
var
  AButton: TdxBarMDIButton;
begin
  for AButton := Low(TdxBarMDIButton) to High(TdxBarMDIButton) do
    if cxRectPtIn(FMDIButtonBounds[AButton], X, Y) then
    begin
      AHitTest := MDIButtonToHitTest[AButton];
      Break;
    end;
end;

function TdxRibbonViewInfo.GetButtonState(AButton: TdxRibbonHitTest): TdxBorderIconState;
var
  AHasPressedObject: Boolean;
begin
  with Ribbon.Controller do
  begin
    AHasPressedObject := not (PressedObject in [rhtNone, rhtTab]);
    if (HotObject <> AButton) or (AHasPressedObject and (PressedObject <> AButton)) then
      Result := bisNormal
    else
      if AHasPressedObject and (PressedObject = AButton) then
        Result := bisPressed
      else
        Result := bisHot
  end;
end;

function TdxRibbonViewInfo.GetCanvas: TcxCanvas;
begin
  Result := Ribbon.Canvas;
end;

function TdxRibbonViewInfo.GetGroupsDockControlSiteViewInfo: TdxRibbonGroupsDockControlSiteViewInfo;
begin
  Result := Ribbon.GroupsDockControlSite.ViewInfo;
end;

function TdxRibbonViewInfo.GetIsFormCaptionActive: Boolean;
begin
  Result := SupportNonClientDrawing and Ribbon.RibbonForm.IsActive;
end;

function TdxRibbonViewInfo.GetMDIButtonState(AButton: TdxBarMDIButton): TdxBorderIconState;
const
  ConvertButtons: array[TdxBarMDIButton] of TdxRibbonHitTest =
    (rhtMDIMinimizeButton, rhtMDIRestoreButton, rhtMDICloseButton);
begin
  if IsMDIButtonEnabled(AButton, 0) then
    Result := GetButtonState(ConvertButtons[AButton])
  else
    Result := bisInactive;
end;

function TdxRibbonViewInfo.GetPainter: TdxRibbonPainter;
begin
  Result := Ribbon.Painter;
end;

function TdxRibbonViewInfo.GetQATDockControl: TdxRibbonQuickAccessDockControl;
begin
  Result := Ribbon.QuickAccessToolbar.DockControl;
end;

function TdxRibbonViewInfo.GetScrollButtonWidth: Integer;
var
  AFont: TFont;
begin
  AFont := Ribbon.Fonts.TabHeader;
  Result := (Abs(AFont.Height) * 2 + 2) div 2 + 1;
end;

function TdxRibbonViewInfo.GetTabsVerticalOffset: Integer;
begin
  if SupportNonClientDrawing then
    Result := GetNonClientAreaHeight
  else
    if IsQATVisible and (Ribbon.QuickAccessToolbar.Position = qtpAboveRibbon) then
      Result := GetQATBounds.Bottom
    else
      Result := 0;
end;

procedure TdxRibbonViewInfo.UpdateGroupsDockControlSite;
begin
  Ribbon.GroupsDockControlSite.BoundsRect := GroupsDockControlSiteBounds;
end;

function TdxRibbonViewInfo.GetPainterClass: TdxRibbonPainterClass;
begin
  Result := TdxRibbonPainter;
end;

{ TdxRibbonBarPainter }

constructor TdxRibbonBarPainter.Create(AData: Integer);

  function GetDefaultGroupHeight: Integer;
  const
    DefaultFontHeight = 13;
  begin
    Result := Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBAR).Top +
      GetButtonHeight(GetSmallIconSize, DefaultFontHeight + dxRibbonGroupRowHeightCorrection) * dxRibbonGroupRowCount +
      dxRibbonGroupCaptionOffsets.Top + InternalGetGroupCaptionHeight(DefaultFontHeight) + dxRibbonGroupCaptionOffsets.Bottom;
  end;

begin
  inherited Create(AData);
  FRibbon := TdxCustomRibbon(AData);
  FDrawParams := TdxBarButtonLikeControlDrawParams.Create(nil);
  with Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBARGLYPHBACKGROUND) do
    FCollapsedGroupElementSizeNumerator := GetSmallIconSize + Top + Bottom + dxRibbonCollapsedGroupGlyphBackgroundOffsets.Top + dxRibbonCollapsedGroupGlyphBackgroundOffsets.Bottom;
  FCollapsedGroupElementSizeDenominator := GetDefaultGroupHeight;
  with Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBAR) do
    Dec(FCollapsedGroupElementSizeDenominator, Top + Bottom);
end;

destructor TdxRibbonBarPainter.Destroy;
begin
  FreeAndNil(FDrawParams);
  inherited Destroy;
end;

procedure TdxRibbonBarPainter.BarDrawBackground(ABarControl: TdxBarControl;
  ADC: HDC; const ADestRect: TRect; const ASourceRect: TRect; ABrush: HBRUSH;
  AColor: TColor);
begin
  BarCanvas.BeginPaint(ADC);
  try
    BarCanvas.SetClipRegion(TcxRegion.Create(ADestRect), roIntersect);
    TdxRibbonGroupBarControl(ABarControl).DrawBarParentBackground(BarCanvas);
    DrawToolbarContentPart(ABarControl, BarCanvas);
  finally
    BarCanvas.EndPaint;
  end;
end;

function TdxRibbonBarPainter.BarMarkRect(
  ABarControl: TdxBarControl): TRect;
begin
  Result := ABarControl.ClientRect;
end;

function TdxRibbonBarPainter.BarMarkItemRect(
  ABarControl: TdxBarControl): TRect;
begin
  Result := ABarControl.ClientRect;
end;

function TdxRibbonBarPainter.GetGroupRowHeight(AIconSize: Integer;
  AGroupFont: TFont): Integer;
//var
//  ACanvas: TcxScreenCanvas;
begin
//      ACanvas.Font := Font;
//      ACanvas.Font.Height := -MulDiv(ACanvas.Font.Size, 96, 72);
//      AScreenLogPixels := GetDeviceCaps(ACanvas.Handle, LOGPIXELSY);
//      Result := ACanvas.TextHeight('Wg');
//      Result := Result * 22 div 13;
//      Result := Result * AScreenLogPixels div 96;

  Result := GetButtonHeight(AIconSize, cxTextHeight(AGroupFont) + dxRibbonGroupRowHeightCorrection);
end;

function TdxRibbonBarPainter.GetToolbarContentOffsets(ABar: TdxBar;
  ADockingStyle: TdxBarDockingStyle; AHasSizeGrip: Boolean): TRect;
begin
  if TdxRibbonGroupBarControl(ABar.Control).Collapsed then
    Result := cxEmptyRect
  else
    Result := inherited GetToolbarContentOffsets(ABar, ADockingStyle, AHasSizeGrip);
end;

function TdxRibbonBarPainter.SubMenuControlBeginGroupSize: Integer;
begin
  Result := Ribbon.ColorScheme.GetMenuSeparatorSize;
end;

function TdxRibbonBarPainter.SubMenuGetSeparatorSize: Integer;
begin
  Result := Ribbon.ColorScheme.GetMenuSeparatorSize;
end;

procedure TdxRibbonBarPainter.DrawCollapsedToolbarBackgroundPart(
  ABarControl: TdxRibbonGroupBarControl; ACanvas: TcxCanvas; AGroupState: Integer);
begin
  if ABarControl.FFadingElementData = nil then
    Skin.DrawBackground(ACanvas.Handle, ABarControl.ClientRect, DXBAR_COLLAPSEDTOOLBAR, AGroupState)
  else
    ABarControl.FFadingElementData.DrawImage(ACanvas.Handle, ABarControl.ClientRect);
end;

procedure TdxRibbonBarPainter.DrawCollapsedToolbarContentPart(
  ABarControl: TdxRibbonGroupBarControl; ACanvas: TcxCanvas; AGroupState: Integer);

  procedure InitDrawParams(AState: Integer);
  begin
    case AState of
      DXBAR_PRESSED:
        begin
          DrawParams.HotPartIndex := icpControl;
          DrawParams.IsPressed := True;
        end;
      DXBAR_HOT: DrawParams.HotPartIndex := icpControl;
      DXBAR_NORMAL: DrawParams.HotPartIndex := icpNone;
    end;
    DrawParams.Canvas := ACanvas;
    DrawParams.Caption := TdxRibbonGroupBarControl(ABarControl).GetCaption;
    DrawParams.IsDropDown := True;
    DrawParams.ViewSize := cvsLarge;
    DrawParams.Enabled := True;
    DrawParams.CanSelect := True;
  end;

var
  ACaptionRect, R: TRect;
  AGroupGlyphBackgroundSize, AGroupGlyphSize: TSize;
begin
  ACaptionRect := GetCollapsedGroupCaptionRect(ABarControl.ClientRect);

  InitDrawParams(AGroupState);
  //#DG  ABarControl.Canvas.Font := ABarControl.Font;
  ButtonLikeControlDoDrawCaption(DrawParams, ACaptionRect, DT_CENTER);

  R := ABarControl.ClientRect;
  ExtendRect(R, Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBAR));
  R.Bottom := ACaptionRect.Top;
  AGroupGlyphBackgroundSize := GetCollapsedGroupGlyphBackgroundSize(ABarControl);
  Inc(R.Left, (cxRectWidth(R) - AGroupGlyphBackgroundSize.cx) div 2);
  R.Right := R.Left + AGroupGlyphBackgroundSize.cx;
  ExtendRect(R, Rect(0, dxRibbonCollapsedGroupGlyphBackgroundOffsets.Top, 0, dxRibbonCollapsedGroupGlyphBackgroundOffsets.Bottom));
  Inc(R.Top, (cxRectHeight(R) - AGroupGlyphBackgroundSize.cy) div 2);
  R.Bottom := R.Top + AGroupGlyphBackgroundSize.cy;
  Skin.DrawBackground(ACanvas.Handle, R, DXBAR_COLLAPSEDTOOLBARGLYPHBACKGROUND, AGroupState);

  if GetCollapsedGroupGlyph(ABarControl) <> nil then
  begin
    with Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBARGLYPHBACKGROUND) do
    begin
      Inc(R.Top, Top);
      Dec(R.Bottom, Bottom);
    end;
    AGroupGlyphSize := GetCollapsedGroupGlyphSize(ABarControl);
    Inc(R.Top, (cxRectHeight(R) - AGroupGlyphSize.cy) div 2);
    R.Bottom := R.Top + AGroupGlyphSize.cy;
    Inc(R.Left, (cxRectWidth(R) - AGroupGlyphSize.cx) div 2);
    R.Right := R.Left + AGroupGlyphSize.cx;
    TransparentDraw(ACanvas.Handle, R, GetCollapsedGroupGlyph(ABarControl));
  end;
end;

procedure TdxRibbonBarPainter.DrawToolbarContentPart(
  ABarControl: TdxBarControl; ACanvas: TcxCanvas);
var
  AGroupBarControl: TdxRibbonGroupBarControl;
  AGroupState: Integer;
  APrevWindowOrg: TPoint;
begin
  AGroupBarControl := TdxRibbonGroupBarControl(ABarControl);
  if AGroupBarControl.Collapsed then
  begin
    AGroupState := GetGroupState(ABarControl);
    DrawCollapsedToolbarBackgroundPart(AGroupBarControl, ACanvas, AGroupState);
    DrawCollapsedToolbarContentPart(AGroupBarControl, ACanvas, AGroupState);
  end
  else
    if AGroupBarControl.FFadingElementData = nil then
      inherited DrawToolbarContentPart(ABarControl, ACanvas)
    else
    begin
      with AGroupBarControl.NCOffset do
        OffsetWindowOrgEx(ACanvas.Handle, X, Y, APrevWindowOrg);
      try
        AGroupBarControl.FFadingElementData.DrawImage(ACanvas.Handle,
          AGroupBarControl.NCRect);
      finally
        SetWindowOrgEx(ACanvas.Handle, APrevWindowOrg.X, APrevWindowOrg.Y, nil);
      end;
    end;
end;

procedure TdxRibbonBarPainter.DrawToolbarNonContentPart(
  ABarControl: TdxBarControl; DC: HDC);
begin
  Skin.DrawBackground(DC, TdxBarControlAccess(ABarControl).NCRect,
    DXBAR_TOOLBAR, GetBarControlState(ABarControl));
end;

function TdxRibbonBarPainter.GetCollapsedGroupWidth(
  ABarControl: TdxRibbonGroupBarControl): Integer;

  procedure InitDrawParams;
  begin
    cxScreenCanvas.Font := ABarControl.Font;
    DrawParams.Canvas := cxScreenCanvas;
    DrawParams.Caption := ABarControl.GetCaption;
    DrawParams.ViewSize := cvsLarge;
    DrawParams.IsDropDown := True;
  end;

var
  AGlyphBackgroundAreaWidth: Integer;
  R: TRect;
begin
  InitDrawParams;
  Result := GetControlCaptionRect(DrawParams).Right;

  R := Rect(0, 0, 100, 100);
  with GetCollapsedGroupCaptionRect(R) do
    Inc(Result, (Left - R.Left) + (R.Right - Right));
  AGlyphBackgroundAreaWidth := GetCollapsedGroupGlyphBackgroundSize(ABarControl).cx +
    dxRibbonCollapsedGroupGlyphBackgroundOffsets.Left + dxRibbonCollapsedGroupGlyphBackgroundOffsets.Right;
  with Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBAR) do
    Inc(AGlyphBackgroundAreaWidth, Left + Right);
  if Result < AGlyphBackgroundAreaWidth then
    Result := AGlyphBackgroundAreaWidth;
end;

function TdxRibbonBarPainter.GetGroupCaptionHeight(
  ACaptionFont: TFont): Integer;
var
  ACanvas: TcxScreenCanvas;
begin
  ACanvas := TcxScreenCanvas.Create;
  try
    ACanvas.Font := ACaptionFont;
    if ACanvas.Font.Size < 8 then
      ACanvas.Font.Size := 8;
    Result := InternalGetGroupCaptionHeight(ACanvas.TextHeight('Qq'));
  finally
    ACanvas.Free;
  end;
end;

function TdxRibbonBarPainter.GetCollapsedGroupCaptionRect(
  const AGroupRect: TRect): TRect;
begin
  Result := AGroupRect;
  ExtendRect(Result, Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBAR));
  InflateRect(Result, -1, 0);
  Inc(Result.Top, cxRectHeight(Result) * FCollapsedGroupElementSizeNumerator div FCollapsedGroupElementSizeDenominator);
end;

function TdxRibbonBarPainter.GetGroupMinWidth(ABarControl: TdxRibbonGroupBarControl): Integer;
var
  ACanvas: TcxScreenCanvas;
begin
  ACanvas := TcxScreenCanvas.Create;
  try
    ACanvas.Font := ABarControl.Ribbon.Fonts.GetGroupHeaderFont;
    Result := ACanvas.TextWidth(ABarControl.GetCaption);
    if ABarControl.CaptionButtons.Count > 0 then
      Inc(Result, cxRectWidth(ABarControl.CaptionButtons.Rect) + Skin.GetContentOffsets(DXBAR_TOOLBAR).Right);
  finally
    ACanvas.Free;
  end;
end;

function TdxRibbonBarPainter.GetCollapsedGroupGlyph(ABarControl: TdxBarControl): TBitmap;
begin
  Result := ABarControl.Bar.Glyph;
  if (Result <> nil) and Result.Empty then
    Result := nil;
end;

function TdxRibbonBarPainter.GetCollapsedGroupGlyphBackgroundSize(
  ABarControl: TdxBarControl): TSize;
var
  AGroupContentHeight: Integer;
begin
  AGroupContentHeight := ABarControl.Height;
  with Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBAR) do
    Dec(AGroupContentHeight, Top + Bottom);
  with Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBARGLYPHBACKGROUND) do
    Result.cy := (Top + GetSmallIconSize + Bottom) * AGroupContentHeight div FCollapsedGroupElementSizeDenominator;
  Result.cx := Result.cy;
end;

function TdxRibbonBarPainter.GetCollapsedGroupGlyphSize(ABarControl: TdxBarControl): TSize;
var
  AGlyphSize: TSize;
  AGroupGlyph: TBitmap;
//  AMaxGlyphHeight: Integer;
//  R: TRect;
begin
  AGroupGlyph := GetCollapsedGroupGlyph(ABarControl);
  if AGroupGlyph <> nil then
    AGlyphSize := cxSize(AGroupGlyph.Width, AGroupGlyph.Height)
  else
    AGlyphSize := cxSize(GetSmallIconSize, GetSmallIconSize);
//  R := ABarControl.ClientRect;
//  ExtendRect(R, Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBAR));
//  R.Bottom := GetGroupCaptionRect(ABarControl.ClientRect).Top;
//  with Skin.GetContentOffsets(DXBAR_COLLAPSEDTOOLBARGLYPHBACKGROUND) do
//    AMaxGlyphHeight := cxRectHeight(R) - (Top + Bottom) - (dxRibbonCollapsedGroupGlyphBackgroundOffsets.Top + dxRibbonCollapsedGroupGlyphBackgroundOffsets.Bottom);
//  Result.cy := AGlyphSize.cy;
//  if Result.cy > AMaxGlyphHeight then
//    Result.cy := AMaxGlyphHeight;
//  Result.cx := MulDiv(AGlyphSize.cx, Result.cy, AGlyphSize.cy);

  if (AGlyphSize.cx <= GetSmallIconSize) and (AGlyphSize.cy <= GetSmallIconSize) then
    Result := AGlyphSize
  else
    if AGlyphSize.cx > AGlyphSize.cy then
    begin
      Result.cx := GetSmallIconSize;
      Result.cy := AGlyphSize.cy * GetSmallIconSize div AGlyphSize.cx;
    end
    else
    begin
      Result.cy := GetSmallIconSize;
      Result.cx := AGlyphSize.cx * GetSmallIconSize div AGlyphSize.cy;
    end;
end;

function TdxRibbonBarPainter.GetGroupState(ABarControl: TdxBarControl): Integer;
const
  GroupStates: array[TdxBarMarkState] of Integer = (DXBAR_NORMAL, DXBAR_HOT, DXBAR_PRESSED);
begin
  if ABarControl.IAccessibilityHelper.IsSelected then
    Result := DXBAR_ACTIVE
  else
    Result := GroupStates[TdxRibbonGroupBarControl(ABarControl).MarkDrawState];
end;

function TdxRibbonBarPainter.InternalGetGroupCaptionHeight(
  ATextHeight: Integer): Integer;
begin
  Result := ATextHeight + dxRibbonGroupCaptionHeightCorrection;
end;

{ TdxCustomRibbonDockControl }

procedure TdxCustomRibbonDockControl.UpdateColorScheme;
begin
  RepaintBarControls;
  Invalidate;
end;

function TdxCustomRibbonDockControl.AllowUndockWhenLoadFromIni: Boolean;
begin
  Result := False;
end;

procedure TdxCustomRibbonDockControl.FillBackground(DC: HDC;
  const ADestR, ASourceR: TRect; ABrush: HBRUSH; AColor: TColor);
begin
end;

function TdxCustomRibbonDockControl.IsDrawDesignBorder: Boolean;
begin
  Result := False;
end;

function TdxCustomRibbonDockControl.IsTransparent: Boolean;
begin
  Result := False;
end;

function TdxCustomRibbonDockControl.IsNeedRedrawBarControlsOnPaint: Boolean;
begin
  Result :=  {(csDesigning in ComponentState) and} (csPaintCopy in ControlState);
end;

procedure TdxCustomRibbonDockControl.Paint;
//var
//  I, J: Integer;
//  ABarControl: TdxBarControl;
//  P, ASaveOrg: TPoint;
begin
  inherited;
  if IsNeedRedrawBarControlsOnPaint then
  begin
{
//    BarCanvas.BeginPaint(Canvas.Handle);
//    ASaveOrg := BarCanvas.WindowOrg;
    for I := 0 to RowCount - 1 do
      for J := 0 to Rows[I].ColCount - 1 do
      begin
        ABarControl := Rows[I].Cols[J].BarControl;
        ABarControl.repaint;
        //P := ASaveOrg;
        //P := cxNullPoint;
        //MapWindowPoint(ABarControl.Handle, Handle, P);
        //BarCanvas.WindowOrg := P;

        //FillRectByColor(BarCanvas.Handle, ABarControl.ClientBounds, clRed);

        //ABarControl.PaintTo(BarCanvas.Handle, P.X, P.Y);
        //ABarControl.PaintTo(BarCanvas.Handle, ABarControl.Left, ABarControl.Top);
        //BarCanvas.WindowOrg := ASaveOrg;
      end;
//    BarCanvas.EndPaint;
}
  end;
end;

procedure TdxCustomRibbonDockControl.VisibleChanged;
begin
end;

procedure TdxCustomRibbonDockControl.CMVisibleChanged(var Message: TMessage);
begin
  if HandleAllocated and not Visible then
    ShowWindow(Handle, SW_HIDE); // SC's bugs ID CB41787, CB47149
  VisibleChanged;
  inherited;
end;

procedure TdxCustomRibbonDockControl.WMLButtonDblClk(
  var Message: TWMLButtonDblClk);
begin
  if BarManager <> nil then
  begin
    if BarManager.Designing then
      inherited
    else
      Message.Result := 0;
  end;
end;

{ TdxRibbonGroupsDockControl }

constructor TdxRibbonGroupsDockControl.Create(ATab: TdxRibbonTab);
begin
  inherited Create(nil);
  AllowDocking := False;
  FTab := ATab;
  FViewInfo := GetViewInfoClass.Create(Self);
end;

destructor TdxRibbonGroupsDockControl.Destroy;
begin
  FreeAndNil(FViewInfo);
  inherited Destroy;
end;

procedure TdxRibbonGroupsDockControl.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  AScrollButtonWidth: Integer;
  R: TRect;
begin
  if (Ribbon <> nil) and not Ribbon.IsLocked then
  begin
    Ribbon.GroupsDockControlSite.ViewInfo.Calculate;
    R := Tab.GetDockControlBounds;
    AScrollButtonWidth := Ribbon.ViewInfo.ScrollButtonWidth;
    if rsbLeft in ViewInfo.ScrollButtons then
    begin
      Inc(ALeft, AScrollButtonWidth - R.Left);
      Dec(AWidth, AScrollButtonWidth - R.Left);
    end;
    if rsbRight in ViewInfo.ScrollButtons then
      Dec(AWidth, AScrollButtonWidth - R.Left);
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
    UpdateGroupPositions;
    Ribbon.ViewInfo.GroupsDockControlSiteViewInfo.InvalidateScrollButtons;
  end
  else
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TdxRibbonGroupsDockControl.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
  if HandleAllocated and Ribbon.ColorScheme.HasGroupTransparency then
    RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
end;

procedure TdxRibbonGroupsDockControl.CalcRowToolbarPositions(ARowIndex: Integer;
  AClientSize: Integer);
begin
  if Visible then
    Tab.UpdateDockControl;
end;

procedure TdxRibbonGroupsDockControl.DblClick;
begin
end;

procedure TdxRibbonGroupsDockControl.FillBackground(DC: HDC;
  const ADestR, ASourceR: TRect; ABrush: HBRUSH; AColor: TColor);
var
  AViewInfo: TdxRibbonViewInfo;
begin
  BarCanvas.BeginPaint(DC);
  try
    AViewInfo := Ribbon.ViewInfo;
    with AViewInfo.GroupsDockControlSiteBounds do
      BarCanvas.WindowOrg := cxPointOffset(BarCanvas.WindowOrg, Left + Self.Left, Top + Self.Top);
    AViewInfo.Painter.DrawGroupsArea(BarCanvas, AViewInfo.GetGroupsDockControlSiteBounds);
  finally
    BarCanvas.EndPaint;
  end;
end;

function TdxRibbonGroupsDockControl.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonGroupsDockControlAccessibilityHelper;
end;

function TdxRibbonGroupsDockControl.GetDockedBarControlClass: TdxBarControlClass;
begin
  Result := TdxRibbonGroupBarControl;
end;

function TdxRibbonGroupsDockControl.GetPainter: TdxBarPainter;
begin
  if Ribbon <> nil then
    Result := Ribbon.GroupsPainter
  else
    Result := inherited GetPainter;
end;

function TdxRibbonGroupsDockControl.GetViewInfoClass: TdxRibbonGroupsDockControlViewInfoClass;
begin
  Result := TdxRibbonGroupsDockControlViewInfo;
end;

function TdxRibbonGroupsDockControl.IsMultiRow: Boolean;
begin
  Result := False;
end;

procedure TdxRibbonGroupsDockControl.MakeRectFullyVisible(const R: TRect);
var
  ANewLeft: Integer;
begin
  if (R.Left < 0) or (R.Right > ClientWidth) then
  begin
    if (cxRectWidth(R) > ClientWidth) or (R.Left < 0) then
      ANewLeft := 0
    else
      ANewLeft := ClientWidth - cxRectWidth(R);
    if ANewLeft <> R.Left then
      ViewInfo.InternalScrollGroups(ANewLeft - R.Left, cxRectWidth(Ribbon.ViewInfo.GetTabGroupsDockControlBounds));
  end;
end;

procedure TdxRibbonGroupsDockControl.Paint;
var
  AViewInfo: TdxRibbonViewInfo;
  R: TRect;
begin
  BarCanvas.BeginPaint(Canvas);
  try
    AViewInfo := Ribbon.ViewInfo;
    R := AViewInfo.GetGroupsDockControlSiteBounds;
    BarCanvas.WindowOrg := cxPointOffset(BarCanvas.WindowOrg, R.Left + Left, R.Top + Top);
    AViewInfo.Painter.DrawGroupsArea(BarCanvas, R);
  finally
    BarCanvas.EndPaint;
  end;
end;

procedure TdxRibbonGroupsDockControl.SetSize;
begin
end;

procedure TdxRibbonGroupsDockControl.ShowCustomizePopup;
begin
  if Ribbon.IsDesigning then
    ShowDesignMenu;
end;

procedure TdxRibbonGroupsDockControl.UpdateGroupPositions;
var
  AToolbar: TdxRibbonGroupBarControl;
  I, X: Integer;
  R: TRect;
  WP: Cardinal;
begin
  WP := BeginDeferWindowPos(ViewInfo.GroupCount);
  try
    X := ViewInfo.FirstGroupPosition;
    for I := 0 to ViewInfo.GroupCount - 1 do
    begin
      AToolbar := ViewInfo.GroupViewInfos[I].BarControl;
      with AToolbar.ViewInfo.GetSize do
        R := Rect(X, 0, X + cx, cy);
      if (AToolbar.Left <> R.Left) or (AToolbar.Top <> R.Top) or
        (AToolbar.Width <> cxRectWidth(R)) or (AToolbar.Height <> cxRectHeight(R)) then
      begin
        if AToolbar.HandleAllocated then
          DeferWindowPos(WP, AToolbar.Handle, 0, R.Left, R.Top, cxRectWidth(R), cxRectHeight(R),
            SWP_DRAWFRAME or SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOZORDER)
        else
          AToolbar.SetBounds(R.Left, R.Top, cxRectWidth(R), cxRectHeight(R));
      end;
      X := R.Right + Painter.GetToolbarsOffsetForAutoAlign;
    end;
  finally
    EndDeferWindowPos(WP);
  end;
end;

procedure TdxRibbonGroupsDockControl.VisibleChanged;
begin
  if HandleAllocated and Visible then
  begin
    Tab.UpdateDockControl;
    RepaintBarControls;
  end;
end;

procedure TdxRibbonGroupsDockControl.DesignMenuClick(Sender: TObject);
begin
  case TdxBarButton(Sender).Tag of
    0: Ribbon.Tabs.Add.DesignSelectionHelper.SelectComponent;
    1: Ribbon.DesignAddTabGroup(Tab, False);
    2: Ribbon.DesignAddTabGroup(Tab, True);
  end;
end;

function TdxRibbonGroupsDockControl.GetRibbon: TdxCustomRibbon;
begin
  Result := Tab.Ribbon;
end;

procedure TdxRibbonGroupsDockControl.InitDesignMenu(AItemLinks: TdxBarItemLinks);
begin
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONADDTAB), DesignMenuClick, 0);
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONADDEMPTYGROUP), DesignMenuClick, 1, True);
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONADDGROUPWITHTOOLBAR), DesignMenuClick, 2);
end;

procedure TdxRibbonGroupsDockControl.ShowDesignMenu;
begin
  BarDesignController.ShowCustomCustomizePopup(BarManager, InitDesignMenu, Painter);
end;

{ TdxRibbonGroupsDockControlViewInfo }

constructor TdxRibbonGroupsDockControlViewInfo.Create(
  ADockControl: TdxRibbonGroupsDockControl);
begin
  inherited Create;
  FDockControl := ADockControl;
  FScrollButtons := [];
end;

procedure TdxRibbonGroupsDockControlViewInfo.Calculate(const ABoundsRect: TRect);
type
  TGroupsReduceStage = (grsMultiColumnItemControlsColumnCount,
    grsMultiColumnItemControlsCollapsing, grsItemControlsViewLevel,
    grsGroupsCollapsing);

  function AllGroupsFitIn: Boolean;
  begin
    Result := TryPlaceGroups(cxRectWidth(ABoundsRect));
  end;

  procedure ReduceGroups(AStage: TGroupsReduceStage;
    AUpToViewLevel: TdxBarItemRealViewLevel);
  var
    AGroupViewInfo: TdxRibbonGroupBarControlViewInfo;
    ARes: Boolean;
    I: Integer;
  begin
    for I := GroupCount - 1 downto 0 do
    begin
      AGroupViewInfo := GroupViewInfos[I];
      repeat
        ARes := False;
        case AStage of
          grsMultiColumnItemControlsColumnCount:
            ARes := AGroupViewInfo.DecreaseMultiColumnItemControlsColumnCount;
          grsMultiColumnItemControlsCollapsing:
            ARes := AGroupViewInfo.CollapseMultiColumnItemControls;
          grsItemControlsViewLevel:
            ARes := AGroupViewInfo.Reduce(AUpToViewLevel);
          grsGroupsCollapsing:
            begin
              if AGroupViewInfo.BarControl.Group.CanCollapse then
              begin
                AGroupViewInfo.Collapsed := True;
                AGroupViewInfo.Calculate;
              end;
            end;
        end;
        if not ARes then
          Break;
      until AllGroupsFitIn;
      if AllGroupsFitIn then
        Break;
    end;
  end;

var
  AGroupsReduceStage: TGroupsReduceStage;
  AUpToViewLevel: TdxBarItemRealViewLevel;
  I: Integer;
begin
  SaveGroupCollapsedStates;
  for I := 0 to GroupCount - 1 do
    GroupViewInfos[I].CalculateInit;
  try
    for I := 0 to GroupCount - 1 do
      GroupViewInfos[I].Calculate;
    if not AllGroupsFitIn then
    begin
      for I := 0 to GroupCount - 1 do
        GroupViewInfos[I].ReduceInit;
      for AGroupsReduceStage := Low(TGroupsReduceStage) to High(TGroupsReduceStage) do
      begin
        if AGroupsReduceStage <> grsItemControlsViewLevel then
          ReduceGroups(AGroupsReduceStage, ivlLargeIconWithText)
        else
          for AUpToViewLevel := Succ(Low(TdxBarItemRealViewLevel)) to High(TdxBarItemRealViewLevel) do
          begin
            ReduceGroups(AGroupsReduceStage, AUpToViewLevel);
            if AllGroupsFitIn then
              Break;
          end;
        if AllGroupsFitIn then
          Break;
      end;
    end;
  finally
    for I := 0 to GroupCount - 1 do
      GroupViewInfos[I].CalculateFinalize;
  end;
  CalculateGroupsScrollInfo(cxRectWidth(ABoundsRect));
  CheckGroupCollapsedStates;
end;

procedure TdxRibbonGroupsDockControlViewInfo.ResetScrollInfo;
begin
  FScrollPosition := 0;
  FScrollButtons := [];
end;

procedure TdxRibbonGroupsDockControlViewInfo.ScrollGroups(AScrollLeft: Boolean;
  AMaxContentWidth: Integer);
begin
  if AScrollLeft then
    InternalScrollGroups(-dxRibbonGroupsScrollDelta, AMaxContentWidth)
  else
    InternalScrollGroups(dxRibbonGroupsScrollDelta, AMaxContentWidth);
end;

procedure TdxRibbonGroupsDockControlViewInfo.CalculateGroupsScrollInfo(
  AMaxContentWidth: Integer);
var
  ATotalGroupsWidth: Integer;
begin
  ATotalGroupsWidth := TotalGroupsWidth;
  if ATotalGroupsWidth <= AMaxContentWidth then
  begin
    FScrollButtons := [];
    FScrollPosition := 0;
  end
  else
  begin
    if FScrollButtons = [] then
      FScrollButtons := [rsbRight]
    else
      if FScrollButtons = [rsbLeft] then
        FScrollPosition := AMaxContentWidth - ATotalGroupsWidth
      else
        if FScrollButtons = [rsbLeft, rsbRight] then
        begin
          if FScrollPosition + ATotalGroupsWidth <= AMaxContentWidth then
          begin
            FScrollButtons := [rsbLeft];
            FScrollPosition := AMaxContentWidth - ATotalGroupsWidth;
          end;
        end;
  end;
end;

procedure TdxRibbonGroupsDockControlViewInfo.InternalScrollGroups(
  ADelta: Integer; AMaxContentWidth: Integer);

  procedure CheckScrollPosition;
  begin
    if FScrollPosition > 0 then
      FScrollPosition := 0
    else
      FScrollPosition := Max(FScrollPosition, AMaxContentWidth - TotalGroupsWidth);
  end;

begin
  Inc(FScrollPosition, ADelta);
  CheckScrollPosition;
  FScrollButtons := [];
  if FScrollPosition < 0 then
    Include(FScrollButtons, rsbLeft);
  if FScrollPosition + TotalGroupsWidth > AMaxContentWidth then
    Include(FScrollButtons, rsbRight);
  DockControl.Tab.UpdateDockControlBounds;
end;

procedure TdxRibbonGroupsDockControlViewInfo.CheckGroupCollapsedStates;
var
  AGroup: TdxRibbonTabGroup;
  AGroupViewInfo: TdxRibbonGroupBarControlViewInfo;
  I: Integer;
begin
  for I := 0 to High(FPrevGroupCollapsedStates) do
  begin
    AGroupViewInfo := GroupViewInfos[I];
    if AGroupViewInfo.Collapsed <> FPrevGroupCollapsedStates[I] then
    begin
      AGroup := AGroupViewInfo.BarControl.Group;
      if AGroupViewInfo.Collapsed then
        AGroup.Tab.Ribbon.DoTabGroupCollapsed(AGroup.Tab, AGroup)
      else
        AGroup.Tab.Ribbon.DoTabGroupExpanded(AGroup.Tab, AGroup);
    end;
  end;
end;

function TdxRibbonGroupsDockControlViewInfo.GetFirstGroupPosition: Integer;
begin
  Result := FScrollPosition;
  if rsbLeft in ScrollButtons then
    Dec(Result, DockControl.Left - DockControl.Ribbon.ViewInfo.GetTabGroupsDockControlOffset.Left);
end;

function TdxRibbonGroupsDockControlViewInfo.GetGroupCount: Integer;
var
  AToolbar: TdxBar;
  I: Integer;
begin
  Result := 0;
  for I := 0 to DockControl.Tab.Groups.Count - 1 do
  begin
    AToolbar := DockControl.Tab.Groups[I].ToolBar;
    if IsValidToolbar(AToolbar) then
      Inc(Result);
  end;
end;

function TdxRibbonGroupsDockControlViewInfo.GetGroupViewInfo(
  AIndex: Integer): TdxRibbonGroupBarControlViewInfo;
var
  AToolbar: TdxBar;
  I: Integer;
begin
  Result := nil;
  for I := 0 to DockControl.Tab.Groups.Count - 1 do
  begin
    AToolbar := DockControl.Tab.Groups[I].ToolBar;
    if IsValidToolbar(AToolbar) then
      if AIndex = 0 then
      begin
        Result := TdxRibbonGroupBarControl(AToolBar.Control).ViewInfo;
        Break;
      end
      else
        Dec(AIndex);
  end;
end;

function TdxRibbonGroupsDockControlViewInfo.IsValidToolbar(AToolbar: TdxBar): Boolean;
begin
  Result := (AToolbar <> nil) and (AToolbar.Control <> nil) and (AToolbar.Control.DockControl = DockControl);
end;

procedure TdxRibbonGroupsDockControlViewInfo.SaveGroupCollapsedStates;
var
  I: Integer;
begin
  SetLength(FPrevGroupCollapsedStates, GroupCount);
  for I := 0 to High(FPrevGroupCollapsedStates) do
    FPrevGroupCollapsedStates[I] := GroupViewInfos[I].Collapsed;
end;

function TdxRibbonGroupsDockControlViewInfo.TotalGroupsWidth: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GroupCount - 1 do
    Inc(Result, GroupViewInfos[I].GetSize.cx);
  if GroupCount > 1 then
    Inc(Result, DockControl.Painter.GetToolbarsOffsetForAutoAlign * (GroupCount - 1));
end;

function TdxRibbonGroupsDockControlViewInfo.TryPlaceGroups(
  AMaxContentWidth: Integer): Boolean;
var
  AGroupWidth, I, X: Integer;
begin
  Result := True;
  X := 0;
  for I := 0 to GroupCount - 1 do
  begin
    AGroupWidth := GroupViewInfos[I].GetSize.cx;
    if X + AGroupWidth > AMaxContentWidth then
    begin
      Result := False;
      Break;
    end;
    Inc(X, AGroupWidth + DockControl.Painter.GetToolbarsOffsetForAutoAlign);
  end;
end;

{ TdxRibbonTabGroupsPopupWindow }

constructor TdxRibbonTabGroupsPopupWindow.Create(ARibbon: TdxCustomRibbon);
begin
  inherited Create(ARibbon);
  FRibbon := ARibbon;
  FShadow := TdxBarShadow.Create(Self);
  ModalMode := False;
end;

destructor TdxRibbonTabGroupsPopupWindow.Destroy;
begin
  FreeAndNil(FShadow);
  inherited Destroy;
end;

function TdxRibbonTabGroupsPopupWindow.CalculatePosition: TPoint;
begin
  Result := GetBounds.TopLeft;
end;

procedure TdxRibbonTabGroupsPopupWindow.CalculateSize;
var
  R: TRect;
begin
  R := GetBounds;
  SetBounds(Left, Top, cxRectWidth(R), cxRectHeight(R));
end;

procedure TdxRibbonTabGroupsPopupWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
end;

procedure TdxRibbonTabGroupsPopupWindow.Deactivate;
begin
  if (ActiveBarControl = nil) or not (bsHideAll in TCustomdxBarControlAccess(ActiveBarControl).FState) then
    inherited;
end;

procedure TdxRibbonTabGroupsPopupWindow.DoClosed;
begin
  Ribbon.UpdateFormActionControl(False);
  inherited DoClosed;
  FShadow.Visible := False;
  GroupsDockControlSite.BoundsRect := cxEmptyRect;
  GroupsDockControlSite.Parent := Ribbon;
  Ribbon.Invalidate;
end;

procedure TdxRibbonTabGroupsPopupWindow.DoShowed;
begin
  inherited DoShowed;
  FShadow.SetOwnerBounds(cxEmptyRect, BoundsRect);
  FShadow.Visible := True;
end;

procedure TdxRibbonTabGroupsPopupWindow.DoShowing;
begin
  Ribbon.UpdateFormActionControl(True);
  inherited DoShowing;
  SetGroupsDockControlSite;
end;

procedure TdxRibbonTabGroupsPopupWindow.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  HandleNavigationKey(Key);
end;

procedure TdxRibbonTabGroupsPopupWindow.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if Word(Key) = VK_ESCAPE then
    CloseUp
  else
    HandleNavigationKey(Word(Key));
end;

function TdxRibbonTabGroupsPopupWindow.NeedIgnoreMouseMessageAfterCloseUp(
  AWnd: THandle; AMsg: Cardinal; AShift: TShiftState; const APos: TPoint): Boolean;
var
  AHitInfo: TdxRibbonHitInfo;
  F: TCustomForm;
  P: TPoint;
begin
  if AWnd = Ribbon.Handle then
  begin
    P := Ribbon.ScreenToClient(APos);
    AHitInfo := Ribbon.ViewInfo.GetHitInfo(P.X, P.Y);
    Result := (AHitInfo.HitTest = rhtTab) and (AHitInfo.Tab = Ribbon.ActiveTab) and
      (AMsg = WM_LBUTTONDOWN) and not (ssDouble in AShift);
  end
  else
  begin
    F := GetParentForm(Ribbon);
    if (F.Handle <> AWnd) and not HasAsParent(AWnd, Ribbon.Handle) then
      Result := not Ribbon.DoHideMinimizedByClick(AWnd, AShift, APos)
    else
      Result := False
  end;
end;

procedure TdxRibbonTabGroupsPopupWindow.HandleNavigationKey(AKey: Word);
begin
  if BarNavigationController.IsNavigationKey(AKey) then
  begin
    BarNavigationController.SetKeyTipsShowingState(nil, '');
    SelectFirstSelectableAccessibleObject(GroupsDockControlSite.DockControl.IAccessibilityHelper.GetBarHelper);
  end;
end;

procedure TdxRibbonTabGroupsPopupWindow.SetGroupsDockControlSite;
var
  R: TRect;
begin
  if Ribbon.ActiveTab <> nil then
  begin
    GroupsDockControlSite.Parent := Self;
    GroupsDockControlSite.BoundsRect := GetControlRect(Self);
    R := GroupsDockControlSite.BoundsRect;
    with Ribbon.ViewInfo.GetTabGroupsDockControlOffset do
      R := cxRectInflate(R, -Left, -Top, -Right, -Bottom);
    GroupsDockControlSite.DockControl.ViewInfo.ResetScrollInfo;
    GroupsDockControlSite.DockControl.HandleNeeded;
    GroupsDockControlSite.DockControl.ViewInfo.Calculate(R);
    GroupsDockControlSite.DockControl.BoundsRect := R;
    GroupsDockControlSite.DockControl.Visible := True;
  end;
end;

function TdxRibbonTabGroupsPopupWindow.GetBounds: TRect;
var
  AMonitorRect, ARibbonRect, ATabsRect: TRect;
  ATabGroupsHeight: Integer;
begin
  ARibbonRect := Ribbon.ClientRect;
  MapWindowRect(Ribbon.Handle, 0, ARibbonRect);
  ATabsRect := Ribbon.ViewInfo.TabsViewInfo.Bounds;
  MapWindowRect(Ribbon.Handle, 0, ATabsRect);
  Result := cxRect(ARibbonRect.Left, ATabsRect.Top - 1, ARibbonRect.Right, ATabsRect.Bottom - 1);
  ATabGroupsHeight := Ribbon.ViewInfo.GetTabGroupsHeight(True);
    AMonitorRect := GetMonitorWorkArea(0);
  cxRectIntersect(Result, Result, AMonitorRect);
  if Result.Bottom + ATabGroupsHeight > AMonitorRect.Bottom then
    Result := cxRect(Result.Left, Result.Top - ATabGroupsHeight, Result.Right, Result.Top)
  else
    Result := cxRect(Result.Left, Result.Bottom, Result.Right, Result.Bottom + ATabGroupsHeight);
end;

function TdxRibbonTabGroupsPopupWindow.GetGroupsDockControlSite: TdxRibbonGroupsDockControlSite;
begin
  Result := Ribbon.GroupsDockControlSite;
end;

procedure TdxRibbonTabGroupsPopupWindow.WMNCPaint(var Message: TMessage);
var
  DC: HDC;
  AFlags: Integer;
  ARgn: HRGN;
begin
  AFlags := DCX_CACHE or DCX_CLIPSIBLINGS or DCX_WINDOW or DCX_VALIDATE;
  if Message.WParam <> 1 then
  begin
    ARgn := CreateRectRgnIndirect(cxEmptyRect);
    CombineRgn(ARgn, Message.WParam, 0, RGN_COPY);
    DC := GetDCEx(Handle, ARgn, AFlags or DCX_INTERSECTRGN);
  end
  else
    DC := GetDCEx(Handle, 0, AFlags);
  try
    Ribbon.ColorScheme.DrawTabGroupsArea(DC, ClientRect);
  finally
    ReleaseDC(Handle, DC);
  end;
end;

procedure TdxRibbonTabGroupsPopupWindow.WMSize(var Message: TWMSize);
var
  Rgn: HRGN;
begin
  inherited;
  Rgn := CreateRoundRectRgn(0, 0, Message.Width + 1, Message.Height + 1, 4, 4);
  SetWindowRgn(Handle, Rgn, True);
end;

{ TdxRibbonQuickAccessItemControlPainter }

function TdxRibbonQuickAccessPainter.BarMarkRect(
  ABarControl: TdxBarControl): TRect;
begin
  Result := BarMarkItemRect(ABarControl);
end;

function TdxRibbonQuickAccessPainter.BarMarkItemRect(
  ABarControl: TdxBarControl): TRect;
begin
  Result := ABarControl.ClientRect;
  Result.Left := Result.Right - (MarkSizeX(ABarControl) - MarkButtonOffset);
end;

procedure TdxRibbonQuickAccessPainter.BarDrawMarkBackground(
  ABarControl: TdxBarControl; DC: HDC; ItemRect: TRect; AToolbarBrush: HBRUSH);
const
  States: array[TdxBarMarkState] of Integer =
    (DXBAR_NORMAL, DXBAR_ACTIVE, DXBAR_PRESSED);
var
  AState: Integer;
begin
  AState := States[TdxRibbonQuickAccessBarControl(ABarControl).MarkDrawState];
  if AState <> DXBAR_NORMAL then
    Skin.DrawBackground(DC, ItemRect, DXBAR_SMALLBUTTON, AState);
end;

procedure TdxRibbonQuickAccessPainter.ComboControlDrawArrowButton(
  const ADrawParams: TdxBarEditLikeControlDrawParams; ARect: TRect;
  AInClientArea: Boolean);
var
  ABitmap: TcxBitmap;
  ASaveCanvas: TcxCanvas;
begin
  if AInClientArea or not ADrawParams.BarEditControl.OnGlass then
    inherited
  else
  begin
    ABitmap := TcxBitmap.CreateSize(ARect);
    try
      ABitmap.cxCanvas.WindowOrg := ARect.TopLeft;
      ASaveCanvas := ADrawParams.Canvas;
      ADrawParams.Canvas := ABitmap.cxCanvas;
      inherited;
      ADrawParams.Canvas := ASaveCanvas;
      ABitmap.MakeOpaque;
      ABitmap.cxCanvas.WindowOrg := cxNullPoint;
      cxBitBlt(ADrawParams.Canvas.Handle, ABitmap.cxCanvas.Handle, ARect, cxNullPoint, SRCCOPY);
    finally
      ABitmap.Free;
    end;
  end
end;

procedure TdxRibbonQuickAccessPainter.DrawGroupButtonControl(
  ADrawParams: TdxBarButtonLikeControlDrawParams; const ARect: TRect);
var
  R: TRect;
begin
  Skin.DrawBackground(ADrawParams.Canvas.Handle, ARect,
    DXBAR_QUICKACCESSGROUPBUTTON, GetButtonPartState(ADrawParams, bcpButton));
  R := ARect;
  ExtendRect(R, Skin.GetContentOffsets(DXBAR_QUICKACCESSGROUPBUTTON));
  with ADrawParams do
    DrawGlyph(BarItemControl, Canvas.Handle, R, R, ptHorz, False, False, False,
      False, False, True, False, False);
end;

procedure TdxRibbonQuickAccessPainter.DrawToolbarContentPart(
  ABarControl: TdxBarControl; ACanvas: TcxCanvas);
var
  AViewInfo: TdxRibbonViewInfo;
  P: TPoint;
begin
  AViewInfo := Ribbon.ViewInfo;
  ACanvas.SaveDC;
  try
    if AViewInfo.UseGlass and AViewInfo.IsQATAtNonClientArea then
      FillRect(ACanvas.Handle, ABarControl.ClientRect, GetStockObject(BLACK_BRUSH));
    P := ACanvas.WindowOrg;
    MapWindowPoint(ABarControl.Handle, Ribbon.Handle, P);
    ACanvas.WindowOrg := P;
    if AViewInfo.IsQATAtNonClientArea and Assigned(Ribbon.FormCaptionHelper) then
      Ribbon.FormCaptionHelper.UpdateCaptionArea(ACanvas)
    else
    begin
      AViewInfo.Painter.DrawQuickAccessToolbar(ACanvas,
        AViewInfo.QuickAccessToolbarBounds, True);
    end;
  finally
    ACanvas.RestoreDC;
  end;
end;

function TdxRibbonQuickAccessPainter.MarkButtonWidth: Integer;
begin
  Result := ((Ribbon.GetGroupRowHeight + 2) div 2) or 1;
end;

function TdxRibbonQuickAccessPainter.GetToolbarContentOffsets(
  ABar: TdxBar; ADockingStyle: TdxBarDockingStyle;
  AHasSizeGrip: Boolean): TRect;
begin
  Result := cxEmptyRect;
end;

function TdxRibbonQuickAccessPainter.MarkButtonOffset: Integer;
begin
  Result := Ribbon.ColorScheme.GetQuickAccessToolbarMarkButtonOffset(
    Ribbon.ViewInfo.IsApplicationButtonVisible,
    Ribbon.QuickAccessToolbar.Position = qtpBelowRibbon);
end;

function TdxRibbonQuickAccessPainter.MarkSizeX(ABarControl: TdxBarControl): Integer;
begin
  Result := MarkButtonWidth + MarkButtonOffset;
end;

{ TdxRibbonQuickAccessBarControl }

constructor TdxRibbonQuickAccessBarControl.CreateEx(AOwner: TComponent; ABar: TdxBar);
begin
  inherited CreateEx(AOwner, ABar);
  FDefaultGlyph := cxCreateBitmap(16, 16, pf32bit);
  if ABar.DockControl <> nil then
    ABar.DockControl.Visible := True;
  FInternalItems := TComponentList.Create;
  FBitmap := TcxBitmap.Create;
end;

destructor TdxRibbonQuickAccessBarControl.Destroy;
begin
  FreeAndNil(FBitmap);
  FreeAndNil(FInternalItems);
  if DockControl <> nil then
    DockControl.Visible := False;
  FreeAndNil(FDefaultGlyph);
  inherited Destroy;
end;

function TdxRibbonQuickAccessBarControl.IsOnGlass: Boolean;
begin
  Result := Ribbon.ViewInfo.IsQATOnGlass;
end;

function TdxRibbonQuickAccessBarControl.AllItemsVisible: Boolean;
var
  AItemLink: TdxBarItemLink;
  I: Integer;
begin
  Result := True;
  for I := 0 to ItemLinks.CanVisibleItemCount - 1 do
  begin
    AItemLink := ItemLinks.CanVisibleItems[I];
    if (AItemLink.VisibleIndex = -1) or
      (AItemLink.Control <> nil) and IsRectEmpty(AItemLink.ItemRect) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

procedure TdxRibbonQuickAccessBarControl.CalcControlsPositions;

  procedure CalcItemControlsRealPositionInButtonGroup;
  var
    AItemControlViewInfos: TList;
    AItemLink: TdxBarItemLink;
    I: Integer;
  begin
    if not ViewInfo.CanShowButtonGroups then
      Exit;

    for I := 0 to ItemLinks.VisibleItemCount - 1 do
    begin
      AItemLink := ItemLinks.VisibleItems[I];
      if AItemLink.Control = nil then
        AItemLink.CreateControl;
    end;

    AItemControlViewInfos := TList.Create;
    try
      for I := 0 to ItemLinks.VisibleItemCount - 1 do
        AItemControlViewInfos.Add(Pointer(IdxBarItemControlViewInfo(ItemLinks.VisibleItems[I].Control.ViewInfo)));
      dxRibbonGroupLayoutCalculator.CalcItemControlsRealPositionInButtonGroup(AItemControlViewInfos);
    finally
      AItemControlViewInfos.Free;
    end;
  end;

var
  AItemControlWidth, ASeparatorWidth, I, X: Integer;
  AItemLink: TdxBarItemLink;
  R: TRect;
begin
  R := GetClientOffset;
  TdxBarItemLinksAccess(ItemLinks).EmptyItemRects;
  X := R.Left;
  Truncated := False;
  AItemLink := nil;
  CalcItemControlsRealPositionInButtonGroup;
  for I := 0 to ItemLinks.VisibleItemCount - 1 do
  begin
    AItemLink := ItemLinks.VisibleItems[I];
    if AItemLink.Control = nil then
      AItemLink.CreateControl;
    TdxBarItemControlAccess(AItemLink.Control).LastInRow := False;
    AItemControlWidth := TdxBarItemControlAccess(AItemLink.Control).Width;
    ASeparatorWidth := GetSeparatorWidth(AItemLink.Control);
    Truncated := X + ASeparatorWidth + AItemControlWidth > ClientWidth - GetMarkSize;
    if Truncated then
    begin
      if I > 0 then
        AItemLink := ItemLinks.VisibleItems[I - 1];
      Break;
    end;
    Inc(X, ASeparatorWidth);
    AItemLink.ItemRect := Rect(X, R.Top, X + AItemControlWidth, ClientHeight - R.Bottom);
    TdxBarItemLinkAccess(AItemLink).RowHeight := ClientHeight;
    Inc(X, AItemControlWidth);
  end;
  if AItemLink <> nil then
    TdxBarItemControlAccess(AItemLink.Control).LastInRow := True;
end;

function TdxRibbonQuickAccessBarControl.CanHideAllItemsInSingleLine: Boolean;
begin
  Result := True;
end;

procedure TdxRibbonQuickAccessBarControl.CreateWnd;
begin
  FIsWindowCreation := True;
  try
    inherited CreateWnd;
  finally
    FIsWindowCreation := False;
  end;
  UpdateDefaultGlyph(FDefaultGlyph);
end;

procedure TdxRibbonQuickAccessBarControl.DoPaintItem(AControl: TdxBarItemControl; ACanvas: TcxCanvas; const AItemRect: TRect);
begin
  ACanvas.SaveClipRegion;
  try
    ACanvas.SetClipRegion(TcxRegion.Create(AControl.ViewInfo.Bounds), roSet);
    if IsNeedBufferedOnGlass(AControl) then
    begin
      with AItemRect do
        FBitmap.SetSize(Right - Left, Bottom - Top);
      FBitmap.cxCanvas.WindowOrg := AItemRect.TopLeft;
      FillRect(FBitmap.cxCanvas.Handle, AItemRect, GetStockObject(BLACK_BRUSH));
      AControl.Paint(FBitmap.cxCanvas, AItemRect, GetPaintType);
      FBitmap.MakeOpaque;
      FBitmap.cxCanvas.WindowOrg := cxNullPoint;
      cxBitBlt(ACanvas.Handle, FBitmap.cxCanvas.Handle,
        AItemRect, cxNullPoint, SRCCOPY);
    end
    else
      AControl.Paint(ACanvas, AItemRect, GetPaintType);
  finally
    ACanvas.RestoreClipRegion;
  end;
  DrawSelectedItem(ACanvas.Handle, AControl, AItemRect);
end;

function TdxRibbonQuickAccessBarControl.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonQuickAccessBarControlAccessibilityHelper;
end;

function TdxRibbonQuickAccessBarControl.GetClientOffset: TRect;
begin
  Result := cxEmptyRect;
end;

function TdxRibbonQuickAccessBarControl.GetDefaultItemGlyph: TBitmap;
begin
  Result := FDefaultGlyph;
end;

function TdxRibbonQuickAccessBarControl.GetItemControlDefaultViewLevel(
  AItemControl: TdxBarItemControl): TdxBarItemViewLevel;
begin
  Result := AItemControl.ViewInfo.MinPossibleViewLevel;
end;

function TdxRibbonQuickAccessBarControl.GetMarkAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonQuickAccessBarControlMarkAccessibilityHelper;
end;

function TdxRibbonQuickAccessBarControl.GetMarkSize: Integer;
begin
  if MarkExists then
    Result := Painter.MarkSizeX(Self)
  else
    Result := 0;
end;

function TdxRibbonQuickAccessBarControl.GetMinHeight(
  AStyle: TdxBarDockingStyle): Integer;
begin
  if Visible then
    Result := Max(inherited GetMinHeight(AStyle), Ribbon.GetGroupRowHeight)
  else
    Result := Ribbon.GetGroupRowHeight;
end;

function TdxRibbonQuickAccessBarControl.GetMinWidth(
  AStyle: TdxBarDockingStyle): Integer;
begin
  Result := 0;
end;

function TdxRibbonQuickAccessBarControl.GetPopupMenuItems: TdxRibbonPopupMenuItems;
begin
  Result := inherited GetPopupMenuItems;
  if BarDesignController.CustomizingItemLink = nil then
    Exclude(Result, rpmiQATAddRemoveItem);
end;

function TdxRibbonQuickAccessBarControl.GetQuickControlClass: TdxBarControlClass;
begin
  Result := TdxRibbonQuickAccessPopupBarControl;
end;

function TdxRibbonQuickAccessBarControl.GetRibbon: TdxCustomRibbon;
begin
  if DockControl <> nil then
    Result := TdxRibbonQuickAccessDockControl(DockControl).Ribbon
  else
    Result := nil;                                 
end;

function TdxRibbonQuickAccessBarControl.GetSize(AMaxWidth: Integer): TSize;
var
  AItem: TdxBarItemLink;
  AItemControl: TdxBarItemControlAccess;
  AItemControlHeight, AItemControlWidth, ASeparatorWidth, I: Integer;
begin
  if not CanAllocateHandle(Self) and not IsPopup or FIsWindowCreation then
  begin
    Result := cxSize(0, 0);
    Exit;
  end;
  HandleNeeded;

  Result := cxSize(GetMarkSize, GetMinHeight(dsTop));
  for I := 0 to ItemLinks.CanVisibleItemCount - 1 do
  begin
    AItem := ItemLinks.CanVisibleItems[I];
    if AItem.Control = nil then
      AItem.CreateControl;
    AItemControl := TdxBarItemControlAccess(AItem.Control);
    AItemControlWidth := AItemControl.Width;
    ASeparatorWidth := GetSeparatorWidth(AItemControl);
    if Result.cx + ASeparatorWidth + AItemControlWidth > AMaxWidth then
      Break;
    Inc(Result.cx, ASeparatorWidth + AItemControlWidth);
    AItemControlHeight := AItemControl.Height;
    if AItemControlHeight > Result.cy then
      Result.cy := AItemControlHeight;
  end;
  if MarkExists and (Result.cx = GetMarkSize) then
    Dec(Result.cx, TdxRibbonQuickAccessPainter(Painter).MarkButtonOffset);
  with GetClientOffset do
  begin
    Inc(Result.cx, Left + Right);
    Inc(Result.cy, Top + Bottom);
  end;
end;

function TdxRibbonQuickAccessBarControl.GetSizeForWidth(
  AStyle: TdxBarDockingStyle; AWidth: Integer): TPoint;
begin
  with GetSize(AWidth) do
    Result := Point(cx, cy);
end;

function TdxRibbonQuickAccessBarControl.GetViewInfoClass: TCustomdxBarControlViewInfoClass;
begin
  Result := TdxRibbonQuickAccessBarControlViewInfo;
end;

function TdxRibbonQuickAccessBarControl.AllowQuickCustomizing: Boolean;
begin
  Result := True;
end;

procedure TdxRibbonQuickAccessBarControl.InitQuickCustomizeItemLinks(AQuickControlItemLinks: TdxBarItemLinks);
var
  ASubItem: TdxRibbonQuickAccessPopupSubItem;
begin
  FInternalItems.Clear;
  ASubItem := TdxRibbonQuickAccessPopupSubItem(AQuickControlItemLinks.AddItem(TdxRibbonQuickAccessPopupSubItem).Item);
  BarDesignController.AddInternalItem(ASubItem, FInternalItems);
  ASubItem.OnPopup := HandleQuickAccessSubItemPopup;
end;

procedure TdxRibbonQuickAccessBarControl.InitAddRemoveSubItemPopup(AItemLinks: TdxBarItemLinks);
var
  I: Integer;
  AItemLink: TdxBarItemLink;
  ASubItemButton: TdxRibbonQuickAccessPopupSubItemButton;
  ASeparator: TdxBarItem;
begin
  if ItemLinks.AvailableItemCount > 0 then
  begin
    ASeparator := AItemLinks.AddItem(TdxBarSeparator).Item;
    ASeparator.Caption := cxGetResourceString(@dxSBAR_CUSTOMIZEQAT);
    BarDesignController.AddInternalItem(ASeparator, FInternalItems);

    for I := 0 to ItemLinks.AvailableItemCount - 1 do
    begin
      AItemLink := ItemLinks.AvailableItems[I];
      ASubItemButton := TdxRibbonQuickAccessPopupSubItemButton(AItemLinks.AddItem(TdxRibbonQuickAccessPopupSubItemButton).Item);
      ASubItemButton.Tag := Integer(AItemLink);
      ASubItemButton.ButtonStyle := bsChecked;
      ASubItemButton.Down := AItemLink.Visible;
      BarDesignController.AddInternalItem(ASubItemButton, FInternalItems);
      ASubItemButton.Caption := AItemLink.Caption;
    end;
  end;
  QuickAccessToolbar.UpdateMenuItems(AItemLinks);
end;

procedure TdxRibbonQuickAccessBarControl.InitCustomizationPopup(AItemLinks: TdxBarItemLinks);
begin
  Ribbon.PopulatePopupMenuItems(AItemLinks, GetPopupMenuItems, PopupMenuClick);
end;

function TdxRibbonQuickAccessBarControl.MarkExists: Boolean;
begin
  Result := Ribbon.GetValidPopupMenuItems <> [];
end;

procedure TdxRibbonQuickAccessBarControl.RemoveItemFromQAT;
begin
  if BarDesignController.CustomizingItemLink.Item is TdxRibbonQuickAccessGroupButton then
    BarDesignController.DeleteCustomizingItem
  else
  begin
    if BarDesignController.CustomizingItemLink.OriginalItemLink <> nil then
      BarDesignController.CustomizingItemLink.OriginalItemLink.Free
    else
      BarDesignController.DeleteCustomizingItemLink;
  end;
end;

procedure TdxRibbonQuickAccessBarControl.ShowPopup(AItem: TdxBarItemControl);
var
  AItemLink: TdxBarItemLink;
begin
  if not BarManager.IsCustomizing then
  begin
    if AItem <> nil then
      AItemLink := AItem.ItemLink
    else
      AItemLink := nil;
    BarDesignController.ShowCustomCustomizePopup(BarManager, InitCustomizationPopup, Ribbon.GroupsPainter, Self, AItemLink);
  end
  else
    inherited;
end;

procedure TdxRibbonQuickAccessBarControl.UpdateDefaultGlyph(AGlyph: TBitmap);
var
  AGlyphSize: Integer;
  R: TRect;
begin
  if Ribbon = nil then Exit;
  AGlyphSize := TdxRibbonBarPainter(Painter).GetSmallIconSize;
  AGlyph.Width := AGlyphSize;
  AGlyph.Height := AGlyphSize;
  R := cxRect(0, 0, AGlyphSize, AGlyphSize);
  FillRectByColor(AGlyph.Canvas.Handle, R, 0);
  Ribbon.ColorScheme.DrawQuickAccessToolbarDefaultGlyph(AGlyph.Canvas.Handle, R);
end;

procedure TdxRibbonQuickAccessBarControl.UpdateDoubleBuffered;
begin
  DoubleBuffered := True;
end;

function TdxRibbonQuickAccessBarControl.GetSeparatorWidth(
  AItemControl: TdxBarItemControl): Integer;
begin
  if AItemControl.ItemLink.BeginGroup and ViewInfo.CanShowSeparators then
    Result := BeginGroupSize
  else
    Result := 0;
end;

function TdxRibbonQuickAccessBarControl.GetViewInfo: TdxRibbonQuickAccessBarControlViewInfo;
begin
  Result := TdxRibbonQuickAccessBarControlViewInfo(FViewInfo);
end;

procedure TdxRibbonQuickAccessBarControl.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
  PaintBuffer: THandle;
begin
  if (Ribbon <> nil) and Ribbon.IsDestroying then
  begin
    Message.Result := 0;
    Exit;
  end;
  if not FDoubleBuffered or (Message.DC <> 0) then
  begin
    if not (csCustomPaint in ControlState) and (ControlCount = 0) then
      inherited
    else
      PaintHandler(Message);
  end
  else
  begin
    if (Ribbon <> nil) and Ribbon.ViewInfo.UseGlass then
    begin
      DC := BeginPaint(Handle, PS);
      try
        PaintBuffer := BeginBufferedPaint(DC, @PS.rcPaint, BPBF_TOPDOWNDIB, nil, MemDC);
        Perform(WM_ERASEBKGND, MemDC, MemDC);
        Perform(WM_PRINTCLIENT, MemDC, PRF_CLIENT);
        EndBufferedPaint(PaintBuffer, True);
      finally
        EndPaint(Handle, PS);
      end;
    end
    else
    begin
      DC := BeginPaint(Handle, PS);
      MemBitmap := CreateCompatibleBitmap(DC, PS.rcPaint.Right - PS.rcPaint.Left,
        PS.rcPaint.Bottom - PS.rcPaint.Top);
      try
        MemDC := CreateCompatibleDC(DC);
        OldBitmap := SelectObject(MemDC, MemBitmap);
        try
          SetWindowOrgEx(MemDC, PS.rcPaint.Left, PS.rcPaint.Top, nil);
          Perform(WM_ERASEBKGND, MemDC, MemDC);
          Message.DC := MemDC;
          WMPaint(Message);
          Message.DC := 0;
          BitBlt(DC, PS.rcPaint.Left, PS.rcPaint.Top,
            PS.rcPaint.Right - PS.rcPaint.Left,
            PS.rcPaint.Bottom - PS.rcPaint.Top,
            MemDC,
            PS.rcPaint.Left, PS.rcPaint.Top,
            SRCCOPY);
        finally
          SelectObject(MemDC, OldBitmap);
        end;
      finally
        EndPaint(Handle, PS);
        DeleteDC(MemDC);
        DeleteObject(MemBitmap);
      end;
    end;
  end;
end;

{$IFNDEF DELPHI7}
procedure TdxRibbonQuickAccessBarControl.WMPrintClient(var Message: TWMPrintClient);
var
  SaveIndex: Integer;
begin
  with Message do
    if Result <> 1 then
      if ((Flags and PRF_CHECKVISIBLE) = 0) or Visible then
      begin
        SaveIndex := SaveDC(DC);
        try
          PaintHandler(TWMPaint(Message));
        finally
          RestoreDC(DC, SaveIndex);
        end;
      end
      else
        inherited
    else
      inherited;
end;
{$ENDIF}

{ TdxRibbonQuickAccessBarControlViewInfo }

function TdxRibbonQuickAccessBarControlViewInfo.CanShowSeparators: Boolean;
begin
  Result := False;
end;

function TdxRibbonQuickAccessBarControlViewInfo.IsLastVisibleItemControl(
  AItemControl: TdxBarItemControl): Boolean;
begin
  Result := TdxBarItemControlAccess(AItemControl).LastInRow;
end;

{ TdxRibbonQuickAccessDockControl }

constructor TdxRibbonQuickAccessDockControl.Create(AOwner: TdxCustomRibbon);
begin
  inherited Create(nil);
  FRibbon := AOwner;
  FPainter := TdxRibbonQuickAccessPainter.Create(Integer(Ribbon));
  Parent := AOwner;
  AllowDocking := False;
  Align := dalNone;
end;

destructor TdxRibbonQuickAccessDockControl.Destroy;
begin
  FPainter.Free;
  inherited Destroy;
end;

procedure TdxRibbonQuickAccessDockControl.CalcLayout;
begin
  Ribbon.Changed;
  inherited CalcLayout;
end;

function TdxRibbonQuickAccessDockControl.GetDockedBarControlClass: TdxBarControlClass;
begin
  Result := TdxRibbonQuickAccessBarControl;
end;

function TdxRibbonQuickAccessDockControl.GetPainter: TdxBarPainter;
begin
  Result := FPainter;
end;

procedure TdxRibbonQuickAccessDockControl.VisibleChanged;
begin
  with Ribbon do
  begin
    if not IsDestroying and IsBarManagerValid then
      Changed;
  end;
end;

{ TdxRibbonCustomBarControl }

constructor TdxRibbonCustomBarControl.CreateEx(AOwner: TComponent; ABar: TdxBar);
begin
  inherited CreateEx(AOwner, ABar);
  if not (csDesigning in ComponentState) then
    ControlStyle := ControlStyle - [csDoubleClicks];
end;

function TdxRibbonCustomBarControl.AllowQuickCustomizing: Boolean;
begin
  Result := False;
end;

function TdxRibbonCustomBarControl.CanAlignControl(AControl: TdxBarItemControl): Boolean;
begin
  Result := True;
end;

function TdxRibbonCustomBarControl.CanMoving: Boolean;
begin
  Result := False;
end;

function TdxRibbonCustomBarControl.GetBehaviorOptions: TdxBarBehaviorOptions;
begin
  Result := dxRibbonBarBehaviorOptions;
end;

function TdxRibbonCustomBarControl.GetEditFont: TFont;
begin
  if Ribbon = nil then
    Result := inherited GetEditFont
  else
    Result := Ribbon.Fonts.GetGroupFont;
end;

function TdxRibbonCustomBarControl.GetFont: TFont;
begin
  if Ribbon = nil then
    Result := inherited GetFont
  else
    Result := Ribbon.Fonts.GetGroupFont;
end;

function TdxRibbonCustomBarControl.GetFullItemRect(Item: TdxBarItemControl): TRect;
begin
  Result := GetItemRect(Item);
end;

function TdxRibbonCustomBarControl.GetIsMainMenu: Boolean;
begin
  Result := False;
end;

function TdxRibbonCustomBarControl.GetMultiLine: Boolean;
begin
  Result := False;
end;

function TdxRibbonCustomBarControl.HasCloseButton: Boolean;
begin
  Result := False;
end;

function TdxRibbonCustomBarControl.MarkExists: Boolean;
begin
  Result := False;
end;

function TdxRibbonCustomBarControl.NotHandleMouseMove(
  ACheckLastMousePos: Boolean = True): Boolean;
begin
  Result := inherited NotHandleMouseMove(ACheckLastMousePos) or HasPopupWindowAbove(Self, True);
end;

function TdxRibbonCustomBarControl.RealMDIButtonsOnBar: Boolean;
begin
  Result := False;
end;

function TdxRibbonCustomBarControl.ClickAtHeader: Boolean;
var
  R: TRect;
begin
  R := WindowRect;
  R.Top := R.Bottom - (Height - ClientBounds.Bottom);
  Result := cxRectPtIn(R, GetMouseCursorPos);
end;

procedure TdxRibbonCustomBarControl.DoPopupMenuClick(Sender: TObject);
begin
  Ribbon.PopupMenuItemClick(Sender);
end;

function TdxRibbonCustomBarControl.GetPopupMenuItems: TdxRibbonPopupMenuItems;
begin
  Result := Ribbon.GetValidPopupMenuItems - [rpmiItems];
end;

procedure TdxRibbonCustomBarControl.InitCustomizationPopup(AItemLinks: TdxBarItemLinks);
begin
  Ribbon.PopulatePopupMenuItems(AItemLinks, GetPopupMenuItems, PopupMenuClick);
end;

procedure TdxRibbonCustomBarControl.PopupMenuClick(Sender: TObject);
var
  ALinkSelf: TcxObjectLink;
begin
  ALinkSelf := cxAddObjectLink(Self);
  try
    DoPopupMenuClick(Sender);
    if ALinkSelf.Ref <> nil then
      HideAll;
  finally
    cxRemoveObjectLink(ALinkSelf);
  end;
end;

procedure TdxRibbonCustomBarControl.ShowPopup(AItem: TdxBarItemControl);
var
  AItemLink: TdxBarItemLink;
begin
  if not BarManager.IsCustomizing then
  begin
    if AItem <> nil then
      AItemLink := AItem.ItemLink
    else
      AItemLink := nil;
    if (AItemLink <> nil) or ClickAtHeader then
      BarDesignController.ShowCustomCustomizePopup(BarManager, InitCustomizationPopup, Painter, Self, AItemLink);
  end
  else
    inherited;
end;

function TdxRibbonCustomBarControl.GetQuickAccessToolbar: TdxRibbonQuickAccessToolbar;
begin
  if Ribbon <> nil then
    Result := Ribbon.QuickAccessToolbar
  else
    Result := nil;
end;

procedure TdxRibbonCustomBarControl.WMNCHitTest(var Message: TWMNCHitTest);
var
  R: TRect;
begin
  R := cxRectOffset(ClientRect, ClientToScreen(cxNullPoint));
  inherited;
  if PtInRect(R, SmallPointToPoint(Message.Pos)) then
  begin
    if HitTest = HTCAPTION then
      HitTest := HTCLIENT;
  end
  else
  begin
    Message.Result := HTCLIENT;
    HitTest := HTCLIENT;
  end;
end;

{ TdxRibbonQuickAccessBarControlDesignHelper }

class procedure TdxRibbonQuickAccessBarControlDesignHelper.GetEditors(AEditors: TList);
begin
  inherited GetEditors(AEditors);
  AEditors.Add(TdxAddGroupButtonEditor);
end;

class function TdxRibbonQuickAccessBarControlDesignHelper.GetForbiddenActions: TdxBarCustomizationActions;
begin
  Result := inherited GetForbiddenActions + [caChangeBeginGroup];
end;

{ TdxRibbonQuickAccessPopupBarControl }

constructor TdxRibbonQuickAccessPopupBarControl.CreateEx(AOwner: TComponent; ABar: TdxBar);
begin
  inherited CreateEx(AOwner, ABar);
  FPainter := TdxRibbonQuickAccessPopupPainter.Create(Integer(Ribbon));
end;

destructor TdxRibbonQuickAccessPopupBarControl.Destroy;
begin
  FreeAndNil(FPainter);
  IsActive := False;
  inherited Destroy;
end;

procedure TdxRibbonQuickAccessPopupBarControl.CloseUp;
var
  AAccessibilityHelper: TdxBarControlMarkAccessibilityHelper;
  AClosedByEscape: Boolean;
begin
  AAccessibilityHelper := TdxBarControlMarkAccessibilityHelper(QuickAccessBarControl.MarkIAccessibilityHelper.GetHelper);
  AClosedByEscape := ClosedByEscape;
  inherited CloseUp;
  AAccessibilityHelper.CloseUpHandler(AClosedByEscape);
end;

procedure TdxRibbonQuickAccessPopupBarControl.Popup(const AOwnerRect: TRect);
var
  R: TRect;
begin
  inherited Popup(AOwnerRect);
  if QuickAccessBarControl.AllItemsVisible then
  begin
    SetWindowRgn(Handle, CreateRectRgnIndirect(cxEmptyRect), True);

    R := TdxBarAccessibilityHelperAccess(QuickAccessBarControl.MarkIAccessibilityHelper.GetHelper).GetScreenBounds(cxAccessibleObjectSelfID);
    R.TopLeft := ScreenToClient(R.TopLeft);
    R.BottomRight := ScreenToClient(R.BottomRight);
    GetMarkLink.ItemRect := R;

    GetMarkSubItem.DropDown(not BarNavigationController.NavigationMode);
  end;
end;

function TdxRibbonQuickAccessPopupBarControl.GetClientOffset: TRect;
begin
  Result := cxRect(3, 3, 3, 3);
end;

function TdxRibbonQuickAccessPopupBarControl.GetPainter: TdxBarPainter;
begin
  Result := FPainter;
end;

function TdxRibbonQuickAccessPopupBarControl.GetRibbon: TdxCustomRibbon;
begin
  Result := QuickAccessBarControl.Ribbon;
end;

function TdxRibbonQuickAccessPopupBarControl.GetSizeForPopup: TSize;
begin
  Result := GetSize(MaxInt);
end;

function TdxRibbonQuickAccessPopupBarControl.HasShadow: Boolean;
begin
  Result := not QuickAccessBarControl.AllItemsVisible;
end;

function TdxRibbonQuickAccessPopupBarControl.IsPopup: Boolean;
begin
  Result := True;
end;

function TdxRibbonQuickAccessPopupBarControl.GetQuickAccessBarControl: TdxRibbonQuickAccessBarControl;
begin
  if ParentBar <> nil then
    Result := TdxRibbonQuickAccessBarControl(ParentBar)
  else
    Result := TdxRibbonQuickAccessBarControl(Bar.Control);
end;

function TdxRibbonQuickAccessPopupBarControl.GetMarkLink: TdxBarItemLink;
begin
  Result := ItemLinks[ItemLinks.Count - 1];
end;

function TdxRibbonQuickAccessPopupBarControl.GetMarkSubItem: TCustomdxBarSubItem;
begin
  Result := TCustomdxBarSubItem(GetMarkLink.Item);
end;

{ TdxRibbonQuickAccessPopupPainter }

function TdxRibbonQuickAccessPopupPainter.MarkButtonOffset: Integer;
begin
  Result := 0;
end;

function TdxRibbonQuickAccessPopupPainter.MarkSizeX(ABarControl: TdxBarControl): Integer;
begin
  Result := 0;
end;

procedure TdxRibbonQuickAccessPopupPainter.DrawQuickAccessPopupSubItem(
  DC: HDC; const ARect: TRect; AState: Integer);
begin
  if AState <> DXBAR_NORMAL then
    Skin.DrawBackground(DC, ARect, DXBAR_SMALLBUTTON, AState);
  if AState = DXBAR_ACTIVE then
    AState := DXBAR_HOT;
  Skin.DrawBackground(DC, ARect, DXBAR_MARKARROW, AState);
end;

procedure TdxRibbonQuickAccessPopupPainter.DrawToolbarContentPart(
  ABarControl: TdxBarControl; ACanvas: TcxCanvas);
begin
  Ribbon.ColorScheme.DrawQuickAccessToolbarPopup(ACanvas.Handle,
    ABarControl.ClientRect);
end;

{ TdxRibbonQuickAccessPopupSubItem }

function TdxRibbonQuickAccessPopupSubItem.CreateBarControl: TCustomdxBarControl;
begin
  Result := TdxRibbonQuickAccessPopupSubMenuControl.Create(BarManager);
end;

procedure TdxRibbonQuickAccessPopupSubMenuControl.ShowPopup(AItem: TdxBarItemControl);
begin
// do nothing
end;

{ TdxRibbonQuickAccessPopupSubItemControl }

procedure TdxRibbonQuickAccessPopupSubItemControl.DoCloseUp(
  AHadSubMenuControl: Boolean);
var
  AClosedByEscape: Boolean;
  AQATBarControl: TdxRibbonQuickAccessBarControl;
begin
  AClosedByEscape := AHadSubMenuControl and
    TdxBarSubMenuControlAccess(Item.ItemLinks.BarControl).ClosedByEscape;
  inherited DoCloseUp(AHadSubMenuControl);
  AQATBarControl := TdxRibbonQuickAccessPopupBarControl(Parent).QuickAccessBarControl;
  if AClosedByEscape then
  begin
    if AQATBarControl.AllItemsVisible then
    begin
      AQATBarControl.MarkState := msNone;
      if BarNavigationController.NavigationMode then
        AQATBarControl.MarkIAccessibilityHelper.Select(False);
    end;
  end
  else
    if AHadSubMenuControl and (BarNavigationController.AssignedSelectedObject <> nil) and
      (BarNavigationController.AssignedSelectedObject.GetHelper = AQATBarControl.MarkIAccessibilityHelper.GetHelper) then
        AQATBarControl.MarkIAccessibilityHelper.Unselect(nil);
end;

procedure TdxRibbonQuickAccessPopupSubItemControl.DoPaint(ARect: TRect;
  PaintType: TdxBarPaintType);

  function GetState: Integer;
  begin
    if DrawParams.DroppedDown then
      Result := DXBAR_PRESSED
    else
      if DrawSelected then
        Result := DXBAR_ACTIVE
      else
        Result := DXBAR_NORMAL;
  end;

begin
  TdxRibbonQuickAccessPopupPainter(Painter).DrawQuickAccessPopupSubItem(Canvas.Handle, ARect, GetState);
end;

function TdxRibbonQuickAccessPopupSubItemControl.GetDefaultWidth: Integer;
begin
  Result := TdxRibbonQuickAccessPopupPainter(Painter).MarkButtonWidth;
end;

{ TdxRibbonQuickAccessPopupSubItemButton }

procedure TdxRibbonQuickAccessPopupSubItemButton.DoClick;
begin
  TdxBarItemLink(Tag).Visible := Down;
end;

{ TdxRibbonGroupBarControl }

constructor TdxRibbonGroupBarControl.CreateEx(AOwner: TComponent; ABar: TdxBar);

  function GetGroup: TdxRibbonTabGroup;
  var
    ATab: TdxRibbonTab;
    I: Integer;
  begin
    Result := nil;
    ATab := TdxRibbonGroupsDockControl(Bar.DockControl).Tab;
    for I := 0 to ATab.Groups.Count - 1 do
      if ATab.Groups[I].ToolBar = ABar then
      begin
        Result := ATab.Groups[I];
        Break;
      end;
  end;

begin
  inherited CreateEx(AOwner, ABar);
  FGroup := GetGroup;
  FRibbon := FGroup.Tab.Ribbon;
end;

destructor TdxRibbonGroupBarControl.Destroy;
begin
  Ribbon.RemoveFadingObject(Self);
  inherited Destroy;
end;

procedure TdxRibbonGroupBarControl.CloseUp;
var
  AAccessibilityHelper: TdxRibbonGroupBarControlAccessibilityHelper;
  AClosedByEscape: Boolean;
begin
  if GetParentPopupWindow(Self, False) <> nil then
  begin
    TdxRibbonTabAccessibilityHelper(Group.Tab.IAccessibilityHelper.GetHelper).CloseUpHandler(ClosedByEscape);
    TdxRibbonTabGroupsPopupWindow(DockControl.Parent.Parent).CloseUp;
  end
  else
  begin
    AAccessibilityHelper := TdxRibbonGroupBarControlAccessibilityHelper(ParentBar.IAccessibilityHelper.GetHelper);
    AClosedByEscape := ClosedByEscape;
    inherited CloseUp;
    AAccessibilityHelper.CloseUpHandler(AClosedByEscape);
  end;
end;

function TdxRibbonGroupBarControl.FadingCanFade: Boolean;
begin
  Result := HandleAllocated and not (csDestroying in ComponentState) and
    Ribbon.CanFade;
end;

procedure TdxRibbonGroupBarControl.FadingBegin(AData: IdxFadingElementData);
begin
  FFadingElementData := AData;
end;

procedure TdxRibbonGroupBarControl.FadingDrawFadeImage;
begin
  if HandleAllocated then
    RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
end;

procedure TdxRibbonGroupBarControl.FadingEnd;
begin
  FFadingElementData := nil;
end;

procedure TdxRibbonGroupBarControl.FadingGetFadingParams(
  out AFadeOutImage, AFadeInImage: TcxBitmap;
  var AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
  var AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);

  function GetGroupViewOrg: TPoint;
  var
    R: TRect;
  begin
    R := WindowRect;
    Dec(R.Left, ClientOrigin.X);
    Dec(R.Top, ClientOrigin.Y);
    Result := R.TopLeft;
  end;

  procedure Draw(ACanvas: TcxCanvas; AState: TdxBarViewState);
  const
    CollapsedStateMap: array[TdxBarViewState] of Integer =
      (DXBAR_NORMAL, DXBAR_HOT);
  var
    APrevViewState: TdxBarViewState;
  begin
    APrevViewState := FViewState;
    try
      FViewState := AState;
      PaintGroupBackground(ACanvas);
      ACanvas.WindowOrg := GetGroupViewOrg;
      ACanvas.SaveClipRegion;
      try
        ACanvas.SetClipRegion(TcxRegion.Create(ClientRect), roSet);
        if Collapsed then
          Ribbon.GroupsPainter.DrawCollapsedToolbarBackgroundPart(Self,
            ACanvas, CollapsedStateMap[AState])
        else
          Ribbon.GroupsPainter.DrawToolbarContentPart(Self, ACanvas);
      finally
        ACanvas.RestoreClipRegion;
        ACanvas.WindowOrg := cxNullPoint;
      end;
    finally
      FViewState := APrevViewState;
    end;
  end;

begin
  AFadeInImage := TcxBitmap.CreateSize(BoundsRect, pf32bit);
  AFadeOutImage := TcxBitmap.CreateSize(BoundsRect, pf32bit);
  Draw(AFadeInImage.cxCanvas, bvsHot);
  Draw(AFadeOutImage.cxCanvas, bvsNormal);
end;

procedure TdxRibbonGroupBarControl.AdjustHintWindowPosition(var APos: TPoint;
  const ABoundsRect: TRect; AHeight: Integer);
const
  HintIndent = 2;
begin
  APos.X := ABoundsRect.Left;
  APos.Y := Ribbon.ClientToScreen(cxPoint(0, Ribbon.Height)).Y;
  APos.Y := Max(APos.Y, ClientToScreen(cxPoint(0, Height + HintIndent)).Y);
  if GetDesktopWorkArea(APos).Bottom - APos.Y < AHeight then
  begin
    APos.Y := Ribbon.ClientToScreen(cxNullPoint).Y - AHeight - HintIndent;
    APos.Y := Min(APos.Y, ClientToScreen(cxNullPoint).Y - AHeight - 2 * HintIndent);
  end;
end;

procedure TdxRibbonGroupBarControl.CalcLayout;
begin
  if Ribbon.CanFade then
    Ribbon.Fader.Clear;
end;

function TdxRibbonGroupBarControl.CanProcessShortCut: Boolean;
begin
  Result := True; 
end;

procedure TdxRibbonGroupBarControl.CaptionChanged;
begin
  inherited CaptionChanged;
  RebuildBar;
end;

procedure TdxRibbonGroupBarControl.DoHideAll;
var
  ALinkSelf: TcxObjectLink;
begin
  ALinkSelf := cxAddObjectLink(Self);
  try
    inherited;
    if (ALinkSelf.Ref <> nil) and (GetParentPopupWindow(Self, True) <> nil) then
      CloseUp;
  finally
    cxRemoveObjectLink(ALinkSelf);
  end;
end;

procedure TdxRibbonGroupBarControl.DoNCPaint(DC: HDC);
begin
  if (FFadingElementData <> nil) or Ribbon.ColorScheme.HasGroupTransparency then
    DoTransparentNCPaint(DC)
  else
    DoOpaqueNCPaint(DC);
end;

procedure TdxRibbonGroupBarControl.DoOpaqueNCPaint(DC: HDC);
begin
  if not Collapsed then
  begin
    BarCanvas.BeginPaint(DC);
    try
      PaintGroupMark(BarCanvas);
      PaintGroupBackground(BarCanvas);
      PaintGroupCaptionText(BarCanvas);
      DrawCaptionButtons(BarCanvas);
    finally
      BarCanvas.EndPaint;
    end;
  end;
end;

procedure TdxRibbonGroupBarControl.DoTransparentNCPaint(DC: HDC);
var
  P: TPoint;
  R, BR: TRect;
  AIndex: Integer;
  B: TcxBitmap;
begin
  B := TcxBitmap.CreateSize(WindowRect);
  try
    AIndex := SaveDC(DC);
    R := ClientRect;
    BR := Painter.GetToolbarContentOffsets(Bar, dsNone, False);
    OffsetRect(R, BR.Left, BR.Top);
    ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
    if IsPopup then
    begin
      R := WindowRect;
      OffsetRect(R, -R.Left, -R.Top);
      Ribbon.ColorScheme.DrawTabGroupsArea(B.Canvas.Handle, R);
    end
    else
    begin
      P := cxNullPoint;
      R := cxGetWindowRect(Ribbon.FGroupsDockControlSite);
      OffsetRect(R, -R.Left, -R.Top);
      MapWindowPoint(Handle, Ribbon.FGroupsDockControlSite.Handle, P);
      Dec(P.X, BR.Left);
      Dec(P.Y, BR.Top);
      SetWindowOrgEx(B.Canvas.Handle, P.X, P.Y, nil);
      Ribbon.ColorScheme.DrawTabGroupsArea(B.Canvas.Handle, R);
      SetWindowOrgEx(B.Canvas.Handle, 0, 0, nil);
    end;
    DoOpaqueNCPaint(B.Canvas.Handle);
    cxBitBlt(DC, B.Canvas.Handle, R, cxNullPoint, SRCCOPY);
    RestoreDC(DC, AIndex);
  finally
    B.Free;
  end;
end;

procedure TdxRibbonGroupBarControl.DrawContentBackground;
var
  R: TRect;
begin
  if FFadingElementData = nil then
    inherited DrawContentBackground
  else
  begin
    R := WindowRect;
    OffsetRect(R, -R.Left, -R.Top);
    Dec(R.Top, ClientBounds.Top);
    Dec(R.Left, ClientBounds.Left);
    FFadingElementData.DrawImage(Canvas.Handle, R);
  end;
end;

procedure TdxRibbonGroupBarControl.DoPaint;
begin
  DrawBarParentBackground(Canvas);
  if Collapsed then
  begin
    PaintGroupMark(Canvas);
    TdxRibbonBarPainter(Painter).DrawToolbarContentPart(Self, Canvas);
  end
  else
    inherited DoPaint;
end;

procedure TdxRibbonGroupBarControl.DoBarMouseDown(Button: TMouseButton; Shift: TShiftState;
  const APoint: TPoint; AItemControl: TdxBarItemControl; APointInClientRect: Boolean);
begin
  with GetWindowPoint(APoint) do
    if cxRectPtIn(GetGroupDesignRect, X, Y) then
    begin
      Group.DesignSelectionHelper.SelectComponent;
      if Button = mbRight then
        ShowGroupDesignMenu;
    end
    else
      inherited;
end;

function TdxRibbonGroupBarControl.ClickAtHeader: Boolean;
begin
  Result := Collapsed and cxRectPtIn(WindowRect, GetMouseCursorPos) or inherited ClickAtHeader;
end;

function TdxRibbonGroupBarControl.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonGroupBarControlAccessibilityHelper;
end;

function TdxRibbonGroupBarControl.GetMarkDrawState: TdxBarMarkState;
begin
  if IAccessibilityHelper.IsSelected then
    Result := msSelected
  else
    Result := MarkState;
end;

function TdxRibbonGroupBarControl.GetMoreButtonsHint: string;
begin
  Result := Caption;
end;

function TdxRibbonGroupBarControl.GetQuickControlClass: TdxBarControlClass;
begin
  Result := TdxRibbonCollapsedGroupPopupBarControl;
end;

function TdxRibbonGroupBarControl.GetRibbon: TdxCustomRibbon;
begin
  Result := FRibbon;
end;

function TdxRibbonGroupBarControl.GetViewInfoClass: TCustomdxBarControlViewInfoClass;
begin
  Result := TdxRibbonGroupBarControlViewInfo;
end;

procedure TdxRibbonGroupBarControl.GlyphChanged;
begin
  Ribbon.QuickAccessToolbar.UpdateGroupButton(Bar, False);
end;

function TdxRibbonGroupBarControl.HasCaptionButtons: Boolean;
begin
  Result := not Collapsed and inherited HasCaptionButtons;
end;

procedure TdxRibbonGroupBarControl.InitQuickControl(
  AQuickControlItemLinks: TdxBarItemLinks);
begin
// do nothing
end;

procedure TdxRibbonGroupBarControl.MakeItemControlFullyVisible(
  AItemControl: TdxBarItemControl);
var
  R: TRect;
begin
  if DockControl = nil then
    Exit;
  R := AItemControl.ViewInfo.Bounds;
  R.TopLeft := DockControl.ScreenToClient(ClientToScreen(R.TopLeft));
  R.BottomRight := DockControl.ScreenToClient(ClientToScreen(R.BottomRight));
  TdxRibbonGroupsDockControl(DockControl).MakeRectFullyVisible(R);
end;

function TdxRibbonGroupBarControl.MarkExists: Boolean;
begin
  Result := Collapsed;
end;

procedure TdxRibbonGroupBarControl.ViewStateChanged(APrevValue: TdxBarViewState);
begin
  if Ribbon.CanFade then
  begin
    if ViewState = bvsHot then
      Ribbon.Fader.FadeIn(Self)
    else
      if MarkState <> msPressed then
        Ribbon.Fader.FadeOut(Self);
  end;
  FullInvalidate;
end;

procedure TdxRibbonGroupBarControl.UpdateCaptionButton(ACaptionButton: TdxBarCaptionButton);
var
  I: Integer;
  AButtonRect: TRect;
  AButtonWidth: Integer;
begin
  if ACaptionButton = nil then
  begin
    AButtonRect := Ribbon.SkinGetCaptionRect(NCRect, DXBAR_TOOLBAR);
    AButtonWidth := cxRectHeight(AButtonRect) + 1;
    AButtonRect.Left := AButtonRect.Right - AButtonWidth;
    for I := 0 to Bar.CaptionButtons.Count - 1 do
    begin
      Bar.CaptionButtons[I].Rect := AButtonRect;
      OffsetRect(AButtonRect, -AButtonWidth, 0);
    end;
    InvalidateNCRect(CaptionButtons.Rect);
  end
  else
    InvalidateNCRect(ACaptionButton.Rect);
end;

procedure TdxRibbonGroupBarControl.DesignMenuClick(Sender: TObject);
begin
  case TdxBarButton(Sender).Tag of
    0: Ribbon.DesignAddTabGroup(Group.Tab, False);
    1: Ribbon.DesignAddTabGroup(Group.Tab, True);
    2: BarDesignController.DeleteSelectedObjects(True, True)
  end;
end;

procedure TdxRibbonGroupBarControl.DrawBarParentBackground(ACanvas: TcxCanvas);
var
  APoint: TPoint;
  ARect, AOffsets: TRect;
  AHandle: HWND;
begin
  if Ribbon.ColorScheme.HasGroupTransparency then
  begin
    ACanvas.SaveState;
    if not IsPopup then
    begin
      APoint := cxNullPoint;
      AHandle := Ribbon.FGroupsDockControlSite.Handle;
      Windows.GetClientRect(AHandle, ARect);
      MapWindowPoint(Handle, AHandle, APoint);
      OffsetRect(ARect, -APoint.X, -APoint.Y);
    end
    else
    begin
      ARect := WindowRect;
      OffsetRect(ARect, -ARect.Left, -ARect.Top);
      AOffsets := Painter.GetToolbarContentOffsets(Bar, dsNone, False);
      OffsetRect(ARect, -AOffsets.Left, -AOffsets.Top);
    end;
    Ribbon.Painter.DrawGroupsArea(ACanvas, ARect);
    ACanvas.RestoreState;
  end;
end;

procedure TdxRibbonGroupBarControl.DrawCaptionButtons(ACanvas: TcxCanvas);

  procedure DrawGlyph(AButton: TdxBarCaptionButton);
  const
    ADefaultGlyphSize = 12; // same as dxRibbonSkins.LaunchButtonGlyphSize
  var
    AGlyphRectSize: Integer;
    AGlyphRect: TRect;
    AGlyphRatio: Integer;
  begin
    AGlyphRectSize := Min(cxRectWidth(AButton.Rect), cxRectHeight(AButton.Rect)) - 2 {BorderSize} * 2;
    AGlyphRatio := Round(Max(1, AGlyphRectSize / ADefaultGlyphSize));
    AGlyphRectSize := ADefaultGlyphSize * AGlyphRatio;
    if AGlyphRatio > 1 then
      Dec(AGlyphRectSize, AGlyphRatio); // GDI+ feature
    AGlyphRect := cxRectCenter(AButton.Rect, AGlyphRectSize, AGlyphRectSize);
    if not AButton.Glyph.Empty then
      TransparentDraw(ACanvas.Handle, AGlyphRect, AButton.Glyph, AButton.Enabled)
    else
    begin
      OffsetRect(AGlyphRect, 1, 1); // because shadow
      Ribbon.GroupsPainter.Skin.DrawBackground(ACanvas.Handle, AGlyphRect, DXBAR_LAUNCHBUTTONDEFAULTGLYPH, AButton.State);
    end;
  end;

var
  I: Integer;
  AButton: TdxBarCaptionButton;
begin
  if CaptionButtons.Count = 0 then
    Exit;

  ACanvas.SetClipRegion(TcxRegion.Create(CaptionButtons.Rect), roSet);
  for I := 0 to CaptionButtons.Count - 1 do
  begin
    AButton := CaptionButtons[I];
    Ribbon.GroupsPainter.Skin.DrawBackground(ACanvas.Handle, AButton.Rect, DXBAR_LAUNCHBUTTONBACKGROUND, AButton.State);
    DrawGlyph(AButton);
  end;
end;

procedure TdxRibbonGroupBarControl.DrawSelectedFrame(DC: HDC);

  procedure DrawLine(const R: TRect);
  begin
    DrawRect(DC, R, clBlack, True);
  end;

var
  R: TRect;
begin
  R := NCRect;
  DrawLine(cxRect(R.Left, R.Top, R.Right, R.Top + 2));
  DrawLine(cxRect(R.Left, R.Bottom - 2, R.Right, R.Bottom));
  DrawLine(cxRect(R.Left, R.Top, R.Left + 2, R.Bottom));
  DrawLine(cxRect(R.Right - 2, R.Top, R.Right, R.Bottom));
end;

function TdxRibbonGroupBarControl.GetCollapsed: Boolean;
begin
  Result := ViewInfo.Collapsed;
end;

function TdxRibbonGroupBarControl.GetGroupDesignRect: TRect;
const
  MarkSize = 14;
begin
  if csDesigning in ComponentState then
  begin
    Result := WindowRect;
    OffsetRect(Result, -(Result.Left - 3), -(Result.Top + 3));
    Result.Top := Result.Bottom - MarkSize;
    Result.Right := Result.Left + MarkSize;
  end
  else
    Result := cxEmptyRect;
end;

function TdxRibbonGroupBarControl.GetViewInfo: TdxRibbonGroupBarControlViewInfo;
begin
  Result := TdxRibbonGroupBarControlViewInfo(FViewInfo);
end;

procedure TdxRibbonGroupBarControl.PaintGroupBackground(ACanvas: TcxCanvas);
begin
  ACanvas.ExcludeClipRect(ClientBounds);
  if FFadingElementData = nil then
    Ribbon.GroupsPainter.DrawToolbarNonContentPart(Self, ACanvas.Handle)
  else
    FFadingElementData.DrawImage(ACanvas.Handle, NCRect);
end;

procedure TdxRibbonGroupBarControl.PaintGroupCaptionText(ACanvas: TcxCanvas);
begin
  Ribbon.GroupsPainter.DrawToolbarNonContentPartCaption(Self, ACanvas.Handle);
end;

procedure TdxRibbonGroupBarControl.PaintGroupMark(ACanvas: TcxCanvas);
var
  ASelected: Boolean;
begin
  ASelected := Group.DesignSelectionHelper.IsComponentSelected;
  cxDrawDesignRect(ACanvas, GetGroupDesignRect, ASelected);
  if ASelected then
    DrawSelectedFrame(ACanvas.Handle);
end;

procedure TdxRibbonGroupBarControl.InitDesignMenu(AItemLinks: TdxBarItemLinks);
begin
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONADDEMPTYGROUP), DesignMenuClick, 0);
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONADDGROUPWITHTOOLBAR), DesignMenuClick, 1);
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONDELETEGROUP), DesignMenuClick, 2, True);
end;

procedure TdxRibbonGroupBarControl.ShowGroupDesignMenu;
begin
  BarDesignController.ShowCustomCustomizePopup(BarManager, InitDesignMenu, Painter);
end;

procedure TdxRibbonGroupBarControl.WMNCHitTest(var Message: TWMNCHitTest);
begin
  if Collapsed then
  begin
    Message.Result := HTCLIENT;
    HitTest := HTCLIENT;
  end
  else
    inherited;
end;

//don't use Delphi 2007 WM_PAINT handler
procedure TdxRibbonGroupBarControl.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
begin
  if not FDoubleBuffered or (Message.DC <> 0) then
  begin
    if not (csCustomPaint in ControlState) and (ControlCount = 0) then
      inherited
    else
      PaintHandler(Message);
  end
  else
  begin
    DC := GetDC(0);
    MemBitmap := CreateCompatibleBitmap(DC, ClientRect.Right, ClientRect.Bottom);
    ReleaseDC(0, DC);
    MemDC := CreateCompatibleDC(0);
    OldBitmap := SelectObject(MemDC, MemBitmap);
    try
      DC := BeginPaint(Handle, PS);
      Perform(WM_ERASEBKGND, MemDC, MemDC);
      Message.DC := MemDC;
      WMPaint(Message);
      Message.DC := 0;
      BitBlt(DC, 0, 0, ClientRect.Right, ClientRect.Bottom, MemDC, 0, 0, SRCCOPY);
      EndPaint(Handle, PS);
    finally
      SelectObject(MemDC, OldBitmap);
      DeleteDC(MemDC);
      DeleteObject(MemBitmap);
    end;
  end;
end;

{ TdxRibbonGroupBarControlViewInfo }

procedure TdxRibbonGroupBarControlViewInfo.Calculate;
var
  I: Integer;
begin
  FNonContentAreaSize := GetNonContentAreaSize;
  if Collapsed then
  begin
    ContentSize := cxClasses.Size(BarControl.Ribbon.GroupsPainter.GetCollapsedGroupWidth(BarControl),
      BarControl.Ribbon.GetGroupHeight);
    RemoveSeparatorInfos;
    for I := 0 to ItemControlCount - 1 do
      IdxBarItemControlViewInfo(ItemControlViewInfos[I]).SetBounds(cxEmptyRect);
  end
  else
    LayoutCalculator.CalcLayout(CreateCalculateHelper);
end;

procedure TdxRibbonGroupBarControlViewInfo.CalculateFinalize;
begin
  FKeyTipsBaseLinePositions.Calculated := False;
  FLayoutCalculator := nil;
  UpdateItemRects;
end;

procedure TdxRibbonGroupBarControlViewInfo.CalculateInit;
var
  AItemControl: TdxBarItemControl;
  AItemLinks: TdxBarItemLinks;
  I: Integer;
begin
  Clear;
  Collapsed := False;
  AItemLinks := BarControl.ItemLinks;
  if (AItemLinks.CanVisibleItemCount > 0) and (AItemLinks.CanVisibleItems[0].Control <> nil(*TODO*)) then
    for I := 0 to AItemLinks.CanVisibleItemCount - 1 do
    begin
      AItemControl := BarControl.ItemLinks.CanVisibleItems[I].Control;
      TdxBarItemControlAccess(AItemControl).LastInRow := I = AItemLinks.CanVisibleItemCount - 1;
      AddItemControlViewInfo(AItemControl.ViewInfo);
    end;
  FLayoutCalculator := CreateLayoutCalculator;
  FLayoutCalculator.CalcInit(CreateCalculateHelper);
end;

function TdxRibbonGroupBarControlViewInfo.CollapseMultiColumnItemControls: Boolean;
begin
  Result := LayoutCalculator.CollapseMultiColumnItemControls(
    CreateCalculateHelper);
end;

function TdxRibbonGroupBarControlViewInfo.DecreaseMultiColumnItemControlsColumnCount: Boolean;
begin
  Result := LayoutCalculator.DecreaseMultiColumnItemControlsColumnCount(
    CreateCalculateHelper);
end;

function TdxRibbonGroupBarControlViewInfo.Reduce(
  AUpToViewLevel: TdxBarItemRealViewLevel): Boolean;
begin
  Result := LayoutCalculator.Reduce(CreateCalculateHelper, AUpToViewLevel);
end;

procedure TdxRibbonGroupBarControlViewInfo.ReduceInit;
begin
  LayoutCalculator.ReduceInit(CreateCalculateHelper);
end;

procedure TdxRibbonGroupBarControlViewInfo.CalculateKeyTipsBaseLinePositions;
begin
  if not BarControl.HandleAllocated or not IsWindowVisible(BarControl.Handle) then
    raise EdxException.Create('');
  if not FKeyTipsBaseLinePositions.Calculated then
  begin
    DoCalculateKeyTipsBaseLinePositions;
    FKeyTipsBaseLinePositions.Calculated := True;
  end;
end;

function TdxRibbonGroupBarControlViewInfo.CreateLayoutCalculator: IdxRibbonGroupLayoutCalculator;
begin
  FGroupRowHeight := BarControl.Ribbon.GetGroupRowHeight;
  Result := TdxRibbonGroupLayoutCalculator.Create(FGroupRowHeight,
    dxRibbonGroupRowCount);
end;

procedure TdxRibbonGroupBarControlViewInfo.DoCalculateKeyTipsBaseLinePositions;
begin
  SetLength(FKeyTipsBaseLinePositions.RowKeyTipsBaseLinePositions, dxRibbonGroupRowCount);
  FKeyTipsBaseLinePositions.RowKeyTipsBaseLinePositions[0] := BarControl.ClientOrigin.Y - BarControl.WindowRect.Top;
  FKeyTipsBaseLinePositions.RowKeyTipsBaseLinePositions[2] :=
    BarControl.Ribbon.SkinGetCaptionRect(BarControl.NCRect, DXBAR_TOOLBAR).Top;
  with FKeyTipsBaseLinePositions do
    RowKeyTipsBaseLinePositions[1] := (RowKeyTipsBaseLinePositions[0] + RowKeyTipsBaseLinePositions[2]) div 2;

  FKeyTipsBaseLinePositions.BottomKeyTipsBaseLinePosition := BarControl.Height -
    BarControl.Ribbon.SkinGetContentOffsets(DXBAR_COLLAPSEDTOOLBAR).Bottom;
end;

function TdxRibbonGroupBarControlViewInfo.GetNonContentAreaSize;
begin
  with BarControl.Painter.GetToolbarContentOffsets(BarControl.Bar, dsNone, False) do
    Result := cxClasses.Size(Left + Right, Top + Bottom);
end;

procedure TdxRibbonGroupBarControlViewInfo.UpdateItemRects;

  function GetItemControlBounds(AIndex: Integer): TRect;
  begin
    if Collapsed then
      Result := cxEmptyRect
    else
      Result := ItemControlViewInfos[AIndex].Bounds;
  end;

var
  AItemLink: TdxBarItemLink;
  ANeedsInvalidateBarControl: Boolean;
  I: Integer;
begin
  ANeedsInvalidateBarControl := False;
  for I := 0 to ItemControlCount - 1 do
  begin
    AItemLink := ItemControlViewInfos[I].Control.ItemLink;
    ANeedsInvalidateBarControl := ANeedsInvalidateBarControl or not EqualRect(AItemLink.ItemRect, GetItemControlBounds(I));
    AItemLink.ItemRect := GetItemControlBounds(I);
  end;
  if ANeedsInvalidateBarControl and BarControl.HandleAllocated then
    InvalidateRect(BarControl.Handle, nil, False);
end;

function TdxRibbonGroupBarControlViewInfo.CreateCalculateHelper: IdxRibbonGroupViewInfo;
begin
  Result := TdxRibbonGroupBarControlViewInfoHelper.Create(Self);
end;

function TdxRibbonGroupBarControlViewInfo.GetBarControl: TdxRibbonGroupBarControl;
begin
  Result := TdxRibbonGroupBarControl(FBarControl);
end;

function TdxRibbonGroupBarControlViewInfo.GetBottomKeyTipsBaseLinePosition: Integer;
begin
  CalculateKeyTipsBaseLinePositions;
  Result := FKeyTipsBaseLinePositions.BottomKeyTipsBaseLinePosition +
    BarControl.WindowRect.Top;
end;

function TdxRibbonGroupBarControlViewInfo.GetRowKeyTipsBaseLinePosition(
  ARowIndex: Integer): Integer;
begin
  CalculateKeyTipsBaseLinePositions;
  if (ARowIndex < 0) or (ARowIndex > High(FKeyTipsBaseLinePositions.RowKeyTipsBaseLinePositions)) then
    raise EdxException.Create('');
  Result := FKeyTipsBaseLinePositions.RowKeyTipsBaseLinePositions[ARowIndex] +
    BarControl.WindowRect.Top;
end;

function TdxRibbonGroupBarControlViewInfo.GetSize: TSize;
begin
  Result := cxClasses.Size(FContentSize.cx + FNonContentAreaSize.cx,
    FContentSize.cy + FNonContentAreaSize.cy);
end;

{ TdxRibbonGroupBarControlDesignHelper }

class function TdxRibbonGroupBarControlDesignHelper.GetForbiddenActions: TdxBarCustomizationActions;
begin
  Result := [caChangeButtonPaintStyle, caChangeRecentList];
end;

{ TdxRibbonCollapsedGroupPopupBarControl }

constructor TdxRibbonCollapsedGroupPopupBarControl.CreateForPopup(
  AParentBarControl: TdxBarControl; AOwnerBar: TdxBar);
begin
  AOwnerBar.BarManager.Bars.BeginUpdate;
  try
    inherited CreateForPopup(AParentBarControl, AOwnerBar);
    Bar.ItemLinks := AOwnerBar.ItemLinks;
    Bar.CaptionButtons := AOwnerBar.CaptionButtons;
  finally
    AOwnerBar.BarManager.Bars.EndUpdate;
  end;
  CreateControls;
  UpdateDoubleBuffered;
end;

destructor TdxRibbonCollapsedGroupPopupBarControl.Destroy;
begin
  IsActive := False;
  inherited Destroy;
end;

procedure TdxRibbonCollapsedGroupPopupBarControl.Hide;
begin
  CloseUp;
end;

procedure TdxRibbonCollapsedGroupPopupBarControl.Popup(const AOwnerRect: TRect);
begin
  inherited Popup(AOwnerRect);
  FullInvalidate;
end;

function TdxRibbonCollapsedGroupPopupBarControl.GetCaption: TCaption;
begin
  Result := PopupBar.Caption;
end;

function TdxRibbonCollapsedGroupPopupBarControl.GetPainter: TdxBarPainter;
begin
  Result := Ribbon.GroupsPainter;
end;

function TdxRibbonCollapsedGroupPopupBarControl.GetSizeForPopup: TSize;
begin
  HandleNeeded;
  ViewInfo.CalculateInit;
  try
    ViewInfo.Calculate;
  finally
    ViewInfo.CalculateFinalize;
  end;
  Result := ViewInfo.GetSize;
end;

function TdxRibbonCollapsedGroupPopupBarControl.GetSizeForWidth(AStyle: TdxBarDockingStyle; AWidth: Integer): TPoint;
begin
  Result := Point(ClientWidth, ClientHeight);
end;

function TdxRibbonCollapsedGroupPopupBarControl.IgnoreClickAreaWhenHidePopup: TRect;
begin
  Result := TdxRibbonGroupBarControl(ParentBar).WindowRect;
end;

function TdxRibbonCollapsedGroupPopupBarControl.IsPopup: Boolean;
begin
  Result := True;
end;

function TdxRibbonCollapsedGroupPopupBarControl.NeedHideOnNCMouseClick: Boolean;
begin
  Result := False;
end;

{ TdxRibbonTabGroup }

constructor TdxRibbonTabGroup.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FCanCollapse := True;
  FDesignSelectionHelper := GetSelectableItem(TdxDesignSelectionHelper.Create(Tab.Ribbon, Self, Tab));
end;

destructor TdxRibbonTabGroup.Destroy;
begin
  CheckUndockToolbar;
  inherited Destroy;
  FDesignSelectionHelper := nil;
end;

procedure TdxRibbonTabGroup.Assign(Source: TPersistent);

  function IsInheritanceUpdating: Boolean;
  begin
    Result := (Tab <> nil) and (csUpdating in Tab.ComponentState);
  end;

begin
  if Source is TdxRibbonTabGroup then
  begin
    CanCollapse := TdxRibbonTabGroup(Source).CanCollapse;
    if (TdxRibbonTabGroup(Source).Toolbar <> nil) and IsInheritanceUpdating then
      ToolBar := Tab.Ribbon.BarManager.BarByComponentName(TdxRibbonTabGroup(Source).Toolbar.Name)
    else
      ToolBar := TdxRibbonTabGroup(Source).Toolbar;
  end
  else
    inherited Assign(Source);
end;

procedure TdxRibbonTabGroup.DefineProperties(Filer: TFiler);

  function NeedWriteToolbarName: Boolean;
  var
    AAncestorToolbar: TdxBar;
  begin
    if Filer.Ancestor <> nil then
    begin
      AAncestorToolbar := TdxRibbonTabGroup(Filer.Ancestor).ToolBar;
      Result := (AAncestorToolbar = nil) and (Toolbar <> nil) or
        (AAncestorToolbar <> nil) and (ToolBar = nil) or
        (AAncestorToolbar <> nil) and (AAncestorToolbar.Name <> Toolbar.Name);
    end
    else
      Result := ToolBar <> nil;
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineProperty('ToolbarName', ReadToolbarName, WriteToolbarName, NeedWriteToolbarName);
end;

procedure TdxRibbonTabGroup.DockToolbar(AToolbar: TdxBar);
var
  ADockControl: TdxRibbonGroupsDockControl;
begin
  if Tab.Active or not (AToolbar.DockControl is TdxRibbonGroupsDockControl) then
    RibbonDockToolBar(AToolbar, Tab.DockControl)
  else
  begin
    ADockControl := TdxRibbonGroupsDockControl(AToolbar.DockControl);
    if (ADockControl.Tab.Ribbon <> Tab.Ribbon) or not ADockControl.Tab.Active then
      RibbonDockToolBar(AToolbar, Tab.DockControl);
  end;
end;

function TdxRibbonTabGroup.IsToolbarAcceptable(AToolbar: TdxBar): Boolean;
begin
  Result := (AToolbar = nil) or (Tab.Ribbon.BarManager <> nil) and
    (Tab.Ribbon.BarManager = AToolbar.BarManager);
end;

procedure TdxRibbonTabGroup.UpdateBarManager(ABarManager: TdxBarManager);
begin
  if ToolBar <> nil then
    ToolBar.DockControl := Tab.DockControl;
end;

procedure TdxRibbonTabGroup.UpdateToolbarValue;
begin
  if (FLoadedToolbarName <> '') and Tab.Ribbon.IsBarManagerValid then
  begin
    ToolBar := Tab.Ribbon.BarManager.BarByComponentName(FLoadedToolbarName);
    FLoadedToolbarName := '';
  end;
end;

procedure TdxRibbonTabGroup.CheckUndockToolbar;
var
  I, J: Integer;
  ATab: TdxRibbonTab;
begin
  if FToolbar = nil then Exit;
  for I := 0 to Tab.Ribbon.TabCount - 1 do
  begin
    ATab := Tab.Ribbon.Tabs[I];
    if ATab <> Tab then
    begin
      for J := 0 to ATab.Groups.Count - 1 do
        if ATab.Groups[J].ToolBar = FToolbar then
        begin
          RibbonDockToolBar(FToolbar, ATab.DockControl);
          Exit;
        end;
    end;
  end;
  RibbonUndockToolBar(FToolbar);
end;

function TdxRibbonTabGroup.GetTab: TdxRibbonTab;
begin
  if Collection <> nil then
    Result := (Collection as TdxRibbonTabGroups).Tab
  else
    Result := nil;
end;

function TdxRibbonTabGroup.GetToolbar: TdxBar;
begin
  if (FLoadedToolbarName <> '') and (Tab <> nil) and
    Tab.Ribbon.IsBarManagerValid and IsAncestorComponentDifferencesDetection(Tab) then
      Result := Tab.Ribbon.BarManager.BarByComponentName(FLoadedToolbarName)
  else
    Result := FToolbar;
end;

procedure TdxRibbonTabGroup.ReadToolbarName(AReader: TReader);
begin
  FLoadedToolbarName := AReader.ReadString;
end;

procedure TdxRibbonTabGroup.SetCanCollapse(Value: Boolean);
begin
  if Value <> FCanCollapse then
  begin
    FCanCollapse := Value;
    if (ToolBar <> nil) and (Toolbar.Control <> nil) then
      Toolbar.Control.RepaintBar;
  end;
end;

procedure TdxRibbonTabGroup.SetToolbar(Value: TdxBar);
begin
  if not IsToolbarAcceptable(Value) then
    Exit;
  if FToolbar <> Value then
  begin
    CheckUndockToolbar;
    if Value = nil then
    begin
      Tab.Ribbon.QuickAccessToolbar.UpdateGroupButton(FToolbar, True);
      FToolbar := Value;
      Free;
    end
    else
    begin
      ValidateToolbar(Value);
      if FToolbar <> nil then
        Tab.Ribbon.QuickAccessToolbar.UpdateGroupButton(FToolbar, True);
      FToolbar := Value;
      Value.FreeNotification(Tab);
      DockToolbar(Value);
    end;
  end;
end;

procedure TdxRibbonTabGroup.ValidateToolbar(Value: TdxBar);
var
  I: Integer;
begin
  if Value = Tab.Ribbon.QuickAccessToolbar.Toolbar then
    raise EdxRibbonException.Create('This toolbar is already used as the QuickAccessToolbar');
  for I := 0 to Tab.Groups.Count - 1 do
    if (Tab.Groups[I] <> Self) and (Tab.Groups[I].ToolBar = Value) then
      raise EdxRibbonException.Create('At least one group in this tab already contains this toolbar');
end;

procedure TdxRibbonTabGroup.WriteToolbarName(AWriter: TWriter);
begin
  if ToolBar <> nil then
    AWriter.WriteString(ToolBar.Name)
  else
    AWriter.WriteString('');
end;

{ TdxRibbonTabGroups }

constructor TdxRibbonTabGroups.Create(ATab: TdxRibbonTab);
begin
  inherited Create(ATab.GetGroupClass);
  FTab := ATab;
end;

function TdxRibbonTabGroups.Add: TdxRibbonTabGroup;
begin
  Result := TdxRibbonTabGroup(inherited Add);
end;

function TdxRibbonTabGroups.GetOwner: TPersistent;
begin
  Result := Tab;
end;

{$IFDEF DELPHI6}
procedure TdxRibbonTabGroups.Notify(Item: TCollectionItem;
  Action: TCollectionNotification);
begin
  inherited;
  Tab.Ribbon.Changed;
end;
{$ENDIF}

procedure TdxRibbonTabGroups.Update(Item: TCollectionItem);
begin
  Tab.Ribbon.Changed;
  if Tab.Active then
    Tab.DockControl.UpdateDock;
end;

procedure TdxRibbonTabGroups.UpdateGroupToolbarValues;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].UpdateToolbarValue;
end;

function TdxRibbonTabGroups.GetItem(Index: Integer): TdxRibbonTabGroup;
begin
  Result := TdxRibbonTabGroup(inherited Items[Index]);
end;

procedure TdxRibbonTabGroups.SetItem(Index: Integer;
  const Value: TdxRibbonTabGroup);
begin
  TdxRibbonTabGroup(inherited Items[Index]).Assign(Value);
end;

{ TdxRibbonQuickAccessToolbar }

constructor TdxRibbonQuickAccessToolbar.Create(ARibbon: TdxCustomRibbon);
begin
  inherited Create;
  FRibbon := ARibbon;
  FPosition := qtpAboveRibbon;
  FVisible := True;
  FDockControl := CreateDockControl;
end;

destructor TdxRibbonQuickAccessToolbar.Destroy;
begin
  Toolbar := nil;
  FreeAndNil(FDockControl);
  inherited Destroy;
end;

procedure TdxRibbonQuickAccessToolbar.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonQuickAccessToolbar then
  begin
    Ribbon.BeginUpdate;
    try
      Position := TdxRibbonQuickAccessToolbar(Source).Position;
      Toolbar := TdxRibbonQuickAccessToolbar(Source).Toolbar;
      Visible := TdxRibbonQuickAccessToolbar(Source).Visible;
    finally
      Ribbon.EndUpdate;
    end;
  end;
end;

function TdxRibbonQuickAccessToolbar.HasGroupButtonForToolbar(
  AToolbar: TdxBar): Boolean;
var
  I: Integer;
begin
  Result := False;
  if (Toolbar <> nil) and (AToolbar <> nil) then
    for I := 0 to Toolbar.ItemLinks.Count - 1 do
      if (Toolbar.ItemLinks[I].Item is TdxRibbonQuickAccessGroupButton) and
        (TdxRibbonQuickAccessGroupButton(Toolbar.ItemLinks[I].Item).Toolbar = AToolbar) then
      begin
        Result := True;
        Break;
      end;
end;

procedure TdxRibbonQuickAccessToolbar.CheckUndockGroupToolbar(const Value: TdxBar);
var
  I, J: Integer;
begin
  for I := 0 to Ribbon.TabCount - 1 do
    for J := Ribbon.Tabs[I].Groups.Count - 1 downto 0 do
    begin
      with Ribbon.Tabs[I].Groups[J] do
        if ToolBar = Value then ToolBar := nil;
    end;
end;

function TdxRibbonQuickAccessToolbar.Contains(AItemLink: TdxBarItemLink): Boolean;
begin
  if (AItemLink <> nil) and (AItemLink.OriginalItemLink <> nil) then
    AItemLink := AItemLink.OriginalItemLink;
  Result := Toolbar.ItemLinks.IndexOf(AItemLink) <> -1;
end;

function TdxRibbonQuickAccessToolbar.CreateDockControl: TdxRibbonQuickAccessDockControl;
begin
  Result := TdxRibbonQuickAccessDockControl.Create(Ribbon);
end;

function TdxRibbonQuickAccessToolbar.GetMenuItemsForMark: TdxRibbonPopupMenuItems;
begin
  Result := Ribbon.GetValidPopupMenuItems - [rpmiQATAddRemoveItem];
end;

procedure TdxRibbonQuickAccessToolbar.UpdateColorScheme;
begin
  if Visible and DockControl.Visible then
    DockControl.UpdateColorScheme;
end;

procedure TdxRibbonQuickAccessToolbar.UpdateGroupButton(AForToolbar: TdxBar;
  ABeforeUndock: Boolean);
var
  AGroupButton: TdxRibbonQuickAccessGroupButton;
  I: Integer;
begin
  if Toolbar = nil then
    Exit;
  for I := 0 to Toolbar.ItemLinks.Count - 1 do
    if Toolbar.ItemLinks[I].Item is TdxRibbonQuickAccessGroupButton then
    begin
      AGroupButton := TdxRibbonQuickAccessGroupButton(Toolbar.ItemLinks[I].Item);
      if AGroupButton.Toolbar = AForToolbar then
      begin
        if ABeforeUndock then
          AGroupButton.Toolbar := nil
        else
          AGroupButton.Update;
        Break;
      end;
    end;
end;

procedure TdxRibbonQuickAccessToolbar.UpdateMenuItems(AItems: TdxBarItemLinks);
begin
  Ribbon.PopulatePopupMenuItems(AItems, GetMenuItemsForMark, Ribbon.PopupMenuItemClick);
end;

procedure TdxRibbonQuickAccessToolbar.UpdateRibbon;
begin
  if Ribbon.IsDestroying then Exit;
  Ribbon.SetRedraw(False);
  try
    Ribbon.Changed;
  finally
    Ribbon.SetRedraw(True);
    WinControlFullInvalidate(Ribbon.Parent, True);
    Ribbon.Update;
  end;
end;

procedure TdxRibbonQuickAccessToolbar.SetPosition(
  const Value: TdxQuickAccessToolbarPosition);
begin
  if FPosition <> Value then
  begin
    FPosition := Value;
    UpdateRibbon;
  end;
end;

procedure TdxRibbonQuickAccessToolbar.SetToolbar(const Value: TdxBar);

  procedure RemoveGroupButtons(AToolbar: TdxBar);
  var
    I: Integer;
  begin
    for I := AToolbar.ItemLinks.Count - 1 downto 0 do
      if AToolbar.ItemLinks[I].Item is TdxRibbonQuickAccessGroupButton then
        AToolbar.ItemLinks[I].Item.Free;
  end;

begin
  if FToolbar <> Value then
  begin
    Ribbon.BeginUpdate;
    if (FToolbar <> nil) and not (csDestroying in FToolbar.ComponentState) then
    begin
      FToolbar.RemoveFreeNotification(Ribbon);
      RemoveGroupButtons(FToolbar);
      RibbonUndockToolBar(FToolbar);
    end;
    FToolbar := Value;
    if FToolbar <> nil  then
    begin
      CheckUndockGroupToolbar(Value);
      FToolbar.FreeNotification(Ribbon);
      RibbonDockToolBar(FToolbar, DockControl);
    end
    else
      DockControl.Visible := False;
    Ribbon.CancelUpdate;
    UpdateRibbon;
  end;
end;

procedure TdxRibbonQuickAccessToolbar.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    DockControl.Visible := Value and (Toolbar <> nil);
    UpdateRibbon;
  end;
end;

{ TdxRibbonApplicationButton }

constructor TdxRibbonApplicationButton.Create(ARibbon: TdxCustomRibbon);
begin
  inherited Create;
  FRibbon := ARibbon;
  FGlyph := TBitmap.Create;
  FGlyph.OnChange := GlyphChanged;
  FVisible := True;
  FStretchGlyph := True;
end;

destructor TdxRibbonApplicationButton.Destroy;
begin
  BarAccessibilityHelperOwnerObjectDestroyed(FIAccessibilityHelper);
  Menu := nil;
  FGlyph.Free;
  inherited Destroy;
end;

procedure TdxRibbonApplicationButton.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonApplicationButton then
  begin
    Ribbon.BeginUpdate;
    try
      Glyph := TdxRibbonApplicationButton(Source).Glyph;
      KeyTip := TdxRibbonApplicationButton(Source).KeyTip;
      Menu := TdxRibbonApplicationButton(Source).Menu;
      Visible := TdxRibbonApplicationButton(Source).Visible;
      ScreenTip := TdxRibbonApplicationButton(Source).ScreenTip;
      StretchGlyph := TdxRibbonApplicationButton(Source).StretchGlyph;
    finally
      Ribbon.EndUpdate;
    end;
  end;
end;

function TdxRibbonApplicationButton.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonApplicationButtonAccessibilityHelper;
end;

procedure TdxRibbonApplicationButton.Update;
begin
  with Ribbon do
  begin
    Changed;
    if FormCaptionHelper <> nil then
      FormCaptionHelper.Calculate;
    FullInvalidate;
  end;
end;

procedure TdxRibbonApplicationButton.GlyphChanged(Sender: TObject);
begin
  Update;
end;

function TdxRibbonApplicationButton.GetIAccessibilityHelper: IdxBarAccessibilityHelper;
begin
  if FIAccessibilityHelper = nil then
    FIAccessibilityHelper := GetAccessibilityHelper(GetAccessibilityHelperClass.Create(Self));
  Result := FIAccessibilityHelper;
end;

procedure TdxRibbonApplicationButton.SetGlyph(const Value: TBitmap);
begin
  if IsGlyphAssigned(Value) and (Value.PixelFormat <> pf32bit) then
    cxMakeTrueColorBitmap(Value, FGlyph)
  else
    FGlyph.Assign(Value);
end;

procedure TdxRibbonApplicationButton.SetMenu(const Value: TdxBarApplicationMenu);
begin
  if FMenu <> Value then
  begin
    if FMenu <> nil then
      FMenu.RemoveFreeNotification(Ribbon);
    FMenu := Value;
    if FMenu <> nil then
      FMenu.FreeNotification(Ribbon);
  end;
end;

procedure TdxRibbonApplicationButton.SetScreenTip(const Value: TdxBarScreenTip);
begin
  if FScreenTip <> Value then
  begin
    if FScreenTip <> nil then
      FScreenTip.RemoveFreeNotification(Ribbon);
    FScreenTip := Value;
    if FScreenTip <> nil then
      FScreenTip.FreeNotification(Ribbon);
  end;
end;

procedure TdxRibbonApplicationButton.SetStretchGlyph(const Value: Boolean);
begin
  if FStretchGlyph <> Value then
  begin
    FStretchGlyph := Value;
    Update;
  end;
end;

procedure TdxRibbonApplicationButton.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    Update;
  end;
end;

{ TdxRibbonTab }

constructor TdxRibbonTab.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDockControl := TdxRibbonGroupsDockControl.Create(Self);
  FDockControl.Visible := False;
  FDockControl.Align := dalNone;
  FVisible := True;
  FGroups := TdxRibbonTabGroups.Create(Self);
end;

destructor TdxRibbonTab.Destroy;
begin
  BarAccessibilityHelperOwnerObjectDestroyed(FIAccessibilityHelper);
  FLastIndex := Index;
  Ribbon.RemoveFadingObject(Self);
  FGroups.Free;
  FreeAndNil(FDockControl);
  inherited Destroy;
  FDesignSelectionHelper := nil;
end;

procedure TdxRibbonTab.AddToolBar(AToolBar: TdxBar);
begin
  if AToolbar <> nil then
    Groups.Add.Toolbar := AToolBar;
end;

procedure TdxRibbonTab.Invalidate;
begin
  Ribbon.InvalidateRect(ViewInfo.Bounds, False);
  Ribbon.GroupsDockControlSite.Invalidate;
end;

procedure TdxRibbonTab.MakeVisible;
begin
  Visible := True;
  Ribbon.ViewInfo.TabsViewInfo.MakeTabVisible(Self);
end;

procedure TdxRibbonTab.Assign(Source: TPersistent);
begin
  if Source is TdxRibbonTab then
  begin
    Ribbon.BeginUpdate;
    try
      Active := TdxRibbonTab(Source).Active;
      Caption := TdxRibbonTab(Source).Caption;
      Groups := TdxRibbonTab(Source).Groups;
      KeyTip := TdxRibbonTab(Source).KeyTip;
      Visible := TdxRibbonTab(Source).Visible;
    finally
      Ribbon.EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

function TdxRibbonTab.GetCollectionFromParent(AParent: TComponent): TcxComponentCollection;
begin
  Result := (AParent as TdxCustomRibbon).Tabs;
end;

function TdxRibbonTab.GetDisplayName: string;
begin
  Result := Format('%s - ''%s''', [Name, Caption]);
end;

procedure TdxRibbonTab.Loaded;
begin
  inherited Loaded;
  Groups.UpdateGroupToolbarValues;
end;

procedure TdxRibbonTab.Notification(AComponent: TComponent; Operation: TOperation);
var
  I: Integer;
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not ((csDestroying in ComponentState) or
    (csDestroying in Ribbon.ComponentState)) then
  begin
    for I := Groups.Count - 1 downto 0 do
      if Groups[I].Toolbar = AComponent then
        Groups[I].Toolbar := nil;
  end;
end;

procedure TdxRibbonTab.SetName(const Value: TComponentName);
var
  AChangeText: Boolean;
begin
  AChangeText := not (csLoading in ComponentState) and (Name = Caption) and
    ((Owner = nil) or not (Owner is TControl) or
    not (csLoading in TControl(Owner).ComponentState));
  inherited SetName(Value);
  if AChangeText then
    Caption := Value;
end;

procedure TdxRibbonTab.Activate;
begin
  MakeVisible;
  if Ribbon.ShowTabGroups then
  begin
    UpdateDockControl;
    CheckGroupToolbarsDockControl;
    FDockControl.Visible := True;
  end
  else
    CheckGroupToolbarsDockControl;
end;

procedure TdxRibbonTab.CheckGroupToolbarsDockControl;
var
  I: Integer;
  AToolbar: TdxBar;
begin
  for I := 0 to Groups.Count - 1 do
  begin
    AToolbar := Groups[I].ToolBar;
    if (AToolBar <> nil) and (AToolBar.DockControl <> DockControl) then
      AToolBar.DockControl := DockControl;
  end;
end;

procedure TdxRibbonTab.Deactivate;
begin
  if not (csDestroying in ComponentState) then
    DockControl.Visible := False;
end;

function TdxRibbonTab.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonTabAccessibilityHelper;
end;

function TdxRibbonTab.CanFade: Boolean;
begin
  Result := Ribbon.CanFade and (ViewInfo <> nil);
end;

function TdxRibbonTab.GetActive: Boolean;
begin
  Result := Ribbon.ActiveTab = Self;
end;

function TdxRibbonTab.GetFocused: Boolean;
begin
  Result := IAccessibilityHelper.IsSelected;
end;

function TdxRibbonTab.GetHighlighted: Boolean;
begin
  Result := Ribbon.HighlightedTab = Self;
end;

function TdxRibbonTab.GetIAccessibilityHelper: IdxBarAccessibilityHelper;
begin
  if FIAccessibilityHelper = nil then
    FIAccessibilityHelper := GetAccessibilityHelper(GetAccessibilityHelperClass.Create(Self));
  Result := FIAccessibilityHelper;
end;

function TdxRibbonTab.GetIsDestroying: Boolean;
begin
  Result := csDestroying in ComponentState;
end;

function TdxRibbonTab.GetViewInfo: TdxRibbonTabViewInfo;
var
  I: Integer;
begin
  Result := nil;
  with Ribbon.ViewInfo do
  begin
    for I := 0 to TabsViewInfo.Count - 1 do
      if TabsViewInfo[I].Tab = Self then
      begin
        Result := TabsViewInfo[I];
        Break;
      end;
  end;
end;

function TdxRibbonTab.GetVisibleIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Ribbon.VisibleTabCount - 1 do
    if Ribbon.VisibleTabs[I] = Self then
    begin
      Result := I;
      break;
    end;
end;

procedure TdxRibbonTab.SetActive(Value: Boolean);
begin
  if Value then
    Ribbon.ActiveTab := Self;
end;

procedure TdxRibbonTab.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    Ribbon.Changed;
  end;
end;

procedure TdxRibbonTab.SetHighlighted(Value: Boolean);
begin
  if Value then
    Ribbon.HighlightedTab := Self;
end;

procedure TdxRibbonTab.SetRibbon(Value: TdxCustomRibbon);
begin
  if FRibbon <> Value then
  begin
    FRibbon := Value;
    if FRibbon <> nil then
    begin
      FDesignSelectionHelper := nil;
      FDesignSelectionHelper := GetSelectableItem(TdxDesignSelectionHelper.Create(Ribbon, Self, Ribbon));
      FDockControl.BarManager := FRibbon.BarManager;
      FDockControl.Parent := FRibbon.GroupsDockControlSite;
    end;
  end;
end;

function TdxRibbonTab.GetDockControlBounds: TRect;
begin
  Result := GetControlRect(Ribbon.GroupsDockControlSite);
  with Ribbon.ViewInfo.GetTabGroupsDockControlOffset do
    Result := cxRectInflate(Result, -Left, -Top, -Right, -Bottom);
end;

function TdxRibbonTab.GetGroupClass: TdxRibbonTabGroupClass;
begin
  Result := TdxRibbonTabGroup;
end;

procedure TdxRibbonTab.ScrollDockControlGroups(AScrollLeft, AOnTimer: Boolean);
var
  AMaxContentWidth: Integer;
begin
  AMaxContentWidth := Ribbon.GroupsDockControlSite.Width;
  with Ribbon.ViewInfo.GetTabGroupsDockControlOffset do
    Dec(AMaxContentWidth, Left + Right);
  DockControl.ViewInfo.ScrollGroups(AScrollLeft, AMaxContentWidth);
end;

procedure TdxRibbonTab.UpdateBarManager(ABarManager: TdxBarManager);
var
  I: Integer;
begin
  FDockControl.BarManager := ABarManager;
  for I := 0 to Groups.Count - 1 do
    Groups[I].UpdateBarManager(ABarManager);
end;

procedure TdxRibbonTab.UpdateColorScheme;
begin
  DockControl.UpdateColorScheme;
end;

procedure TdxRibbonTab.UpdateDockControl;
var
  AIsDockControlVisible: Boolean;
begin
  if not Ribbon.IsLocked then
    if GetParentPopupWindow(DockControl, True) = nil then
    begin
      AIsDockControlVisible := Visible and not Ribbon.Hidden and Ribbon.ShowTabGroups and Active;
      if AIsDockControlVisible then
      begin
        DockControl.ViewInfo.Calculate(GetDockControlBounds);
        UpdateDockControlBounds;
      end;
      DockControl.Visible := AIsDockControlVisible;
    end
    else
    begin
      DockControl.ViewInfo.Calculate(DockControl.ClientRect);
      DockControl.UpdateGroupPositions;
    end;
end;

procedure TdxRibbonTab.UpdateDockControlBounds;
begin
  if not Ribbon.IsLocked then
    DockControl.BoundsRect := GetDockControlBounds;
end;

procedure TdxRibbonTab.UpdateGroupsFont;
var
  I, J: Integer;
  ABarControl: TdxBarControl;
begin
  for I := 0 to DockControl.RowCount - 1 do
    with DockControl.Rows[I] do
    begin
      for J := 0 to ColCount - 1 do
      begin
        ABarControl := Cols[J].BarControl;
        if (ABarControl <> nil) and ABarControl.HandleAllocated then
          ABarControl.UpdateFont;
      end;
    end;
end;

procedure TdxRibbonTab.SetGroups(const Value: TdxRibbonTabGroups);
begin
  FGroups.Assign(Value);
end;

procedure TdxRibbonTab.SetVisible(Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    if Active and not Value then
      Ribbon.SetNextActiveTab(Self);
    Ribbon.Changed;
  end;
end;

procedure TdxRibbonTab.FadingBegin(AData: IdxFadingElementData);
begin
  FFadingElementData := AData;
end;

procedure TdxRibbonTab.FadingDrawFadeImage;
begin
  if not IsDestroying then
    Invalidate;
end;

procedure TdxRibbonTab.FadingEnd;
begin
  FFadingElementData := nil;
end;

procedure TdxRibbonTab.FadingGetFadingParams(
  out AFadeOutImage, AFadeInImage: TcxBitmap;
  var AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
  var AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);
begin
  AFadeOutImage := ViewInfo.PrepareFadeImage(False);
  AFadeInImage := ViewInfo.PrepareFadeImage(True);
end;

{ TdxRibbonTabCollection }

constructor TdxRibbonTabCollection.Create(AOwner: TdxCustomRibbon);
begin
  inherited Create(AOwner, AOwner.GetTabClass);
  FOwner := AOwner;
end;

destructor TdxRibbonTabCollection.Destroy;
var
  I: Integer;
begin
  BarAccessibilityHelperOwnerObjectDestroyed(FIAccessibilityHelper);
  for I := Count - 1 downto 0 do
    Items[I].Free;
  inherited Destroy;
end;

function TdxRibbonTabCollection.Add: TdxRibbonTab;
begin
  Result := TdxRibbonTab(inherited Add);
end;

function TdxRibbonTabCollection.Insert(AIndex: Integer): TdxRibbonTab;
begin
  Result := TdxRibbonTab(inherited Insert(AIndex));
end;

function TdxRibbonTabCollection.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonTabCollectionAccessibilityHelper;
end;

procedure TdxRibbonTabCollection.Notify(AItem: TcxComponentCollectionItem;
  AAction: TcxComponentCollectionNotification);
begin
  case AAction of
    ccnAdded:
      Owner.AddTab(TdxRibbonTab(AItem));
    ccnExtracted:
      Owner.RemoveTab(TdxRibbonTab(AItem));
  end;
  inherited;
end;

procedure TdxRibbonTabCollection.Update(AItem: TcxComponentCollectionItem;
  AAction: TcxComponentCollectionNotification);
begin
  inherited;
  if (AItem = nil) and not Owner.IsLocked then
    Owner.Changed;
end;

procedure TdxRibbonTabCollection.UpdateBarManager(ABarManager: TdxBarManager);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].UpdateBarManager(ABarManager);
end;

procedure TdxRibbonTabCollection.SetItemName(AItem: TcxComponentCollectionItem);
begin
  AItem.Name := CreateUniqueName(TdxRibbonTab(AItem).Ribbon.Owner,
    TdxRibbonTab(AItem).Ribbon, AItem, 'TdxRibbon', '');
end;

function TdxRibbonTabCollection.GetIAccessibilityHelper: IdxBarAccessibilityHelper;
begin
  if FIAccessibilityHelper = nil then
    FIAccessibilityHelper := GetAccessibilityHelper(GetAccessibilityHelperClass.Create(Self));
  Result := FIAccessibilityHelper;
end;

function TdxRibbonTabCollection.GetItem(Index: Integer): TdxRibbonTab;
begin
  Result := TdxRibbonTab(inherited Items[Index]);
end;

procedure TdxRibbonTabCollection.SetItem(Index: Integer;
  const Value: TdxRibbonTab);
begin
  Items[Index].Assign(Value);
end;

{ TdxRibbonFonts }

constructor TdxRibbonFonts.Create(AOwner: TdxCustomRibbon);
var
  I: TdxRibbonAssignedFont;
begin
  inherited Create;
  FRibbon := AOwner;
  FDocumentNameColor := clDefault;
  FCaptionFont := TFont.Create;
  FFont := TFont.Create;
  for I := Low(TdxRibbonAssignedFont) to High(TdxRibbonAssignedFont) do
  begin
    FFonts[I] := TFont.Create;
    FFonts[I].OnChange := FontChanged;
  end;
end;

destructor TdxRibbonFonts.Destroy;
var
  I: TdxRibbonAssignedFont;
begin
  for I := Low(TdxRibbonAssignedFont) to High(TdxRibbonAssignedFont) do
    FFonts[I].Free;
  FFont.Free;  
  FCaptionFont.Free;
  inherited Destroy;
end;

procedure TdxRibbonFonts.Assign(Source: TPersistent);
var
  I: TdxRibbonAssignedFont;
begin
  if Source is TdxRibbonFonts then
  begin
    Ribbon.BeginUpdate;
    FDocumentNameColor := TdxRibbonFonts(Source).DocumentNameColor;
    try
      for I := Low(TdxRibbonAssignedFont) to High(TdxRibbonAssignedFont) do
        FFonts[I].Assign(TdxRibbonFonts(Source).FFonts[I]);
      FAssignedFonts := TdxRibbonFonts(Source).FAssignedFonts
    finally
      Ribbon.EndUpdate;
    end;
  end
  else
    inherited;
end;

function TdxRibbonFonts.GetFormCaptionFont(AIsActive: Boolean): TFont;
begin
  Result := FFont;
  Result.Assign(FCaptionFont);
  Result.Color := GetDefaultCaptionTextColor(AIsActive);
  Result.Size := Ribbon.ColorScheme.GetCaptionFontSize(Result.Size);  
end;

function TdxRibbonFonts.GetGroupFont: TFont;
begin
  Result := FFont;
  Result.Assign(FFonts[afGroup]);
end;

function TdxRibbonFonts.GetGroupHeaderFont: TFont;
begin
  Result := FFont;
  Result.Assign(FFonts[afGroupHeader]);
  Result.Color := Ribbon.ColorScheme.GetPartColor(rspTabGroupHeaderText)
end;

function TdxRibbonFonts.GetTabHeaderFont(AState: Integer): TFont;
begin
  Result := FFont;
  Result.Assign(FFonts[afTabHeader]);
  Result.Color := Ribbon.ColorScheme.GetPartColor(rspTabHeaderText, AState);
end;

procedure TdxRibbonFonts.Invalidate;
begin
  if Ribbon.Visible and (Ribbon.ActiveTab <> nil) then
    Ribbon.ActiveTab.UpdateColorScheme;
  Ribbon.RibbonFormInvalidate;
end;

procedure TdxRibbonFonts.UpdateDefaultFont(I: TdxRibbonAssignedFont);
begin
  if Ribbon.IsBarManagerValid and (I in [afTabHeader, afGroup, afGroupHeader]) then
    FFonts[I].Assign(Ribbon.BarManager.Font);
  case I of
    afGroup:
      FFonts[I].Color := Ribbon.ColorScheme.GetPartColor(rspTabGroupText);
    afGroupHeader:
      FFonts[I].Color := Ribbon.ColorScheme.GetPartColor(rspTabGroupHeaderText);
  end;
end;

procedure TdxRibbonFonts.UpdateFonts;
var
  I: TdxRibbonAssignedFont;
  ANonClientMetrics: TNonClientMetrics;
begin
  ANonClientMetrics.cbSize := SizeOf(ANonClientMetrics);
  SystemParametersInfo(SPI_GETNONCLIENTMETRICS, 0, @ANonClientMetrics, 0);
  FCaptionFont.Handle := CreateFontIndirect(ANonClientMetrics.lfCaptionFont);
  FLocked := True;
  try
    for I := Low(TdxRibbonAssignedFont) to High(TdxRibbonAssignedFont) do
    if not (I in AssignedFonts) then
    begin
      FFonts[I].Assign(Ribbon.Font);
      UpdateDefaultFont(I);
    end;
  finally
    FLocked := False;
  end;
end;

procedure TdxRibbonFonts.FontChanged(Sender: TObject);
var
  I: TdxRibbonAssignedFont;
begin
  if Locked or Ribbon.IsLoading then Exit;
  Ribbon.BeginUpdate;
  try
    for I := Low(TdxRibbonAssignedFont) to High(TdxRibbonAssignedFont) do
      if Sender = FFonts[I] then
      begin
        Include(FAssignedFonts, TdxRibbonAssignedFont(I));
        break;
      end;
    UpdateGroupsFont;
  finally
    Ribbon.EndUpdate;
    Invalidate;
  end;
end;

function TdxRibbonFonts.GetDefaultCaptionTextColor(AIsActive: Boolean): TColor;

   function IsFormZoomed: Boolean;
   var
     F: TCustomForm;
   begin
     F := Ribbon.RibbonForm;
     Result := (F <> nil) and F.HandleAllocated and IsZoomed(F.Handle);
   end;

begin
  if Ribbon.ViewInfo.UseGlass then
  begin
    if IsFormZoomed then
     Result := clWindow
    else
      if AIsActive then
        Result := clCaptionText
      else
        Result := clInactiveCaptionText
  end
  else
    Result := Ribbon.ColorScheme.GetPartColor(rspFormCaptionText, Ord(not AIsActive));
end;

function TdxRibbonFonts.GetFont(const Index: Integer): TFont;
begin
  Result := FFonts[TdxRibbonAssignedFont(Index)]
end;

function TdxRibbonFonts.IsFontStored(const Index: Integer): Boolean;
begin
  Result := TdxRibbonAssignedFont(Index) in FAssignedFonts;
end;

procedure TdxRibbonFonts.SetAssignedFonts(const Value: TdxRibbonAssignedFonts);
begin
  if (FAssignedFonts <> Value) then
  begin
    FAssignedFonts := Value;
    UpdateFonts;
    FontChanged(nil);
  end;
end;

procedure TdxRibbonFonts.SetDocumentNameColor(const Value: TColor);
begin
  if FDocumentNameColor <> Value then
  begin
    FDocumentNameColor := Value;
    Ribbon.RibbonFormInvalidate;
  end;
end;

procedure TdxRibbonFonts.SetFont(const Index: Integer; const Value: TFont);
begin
  FFonts[TdxRibbonAssignedFont(Index)].Assign(Value);
end;

procedure TdxRibbonFonts.UpdateGroupsFont;
var
  I: Integer;
begin
  for I := 0 to Ribbon.TabCount - 1 do
    Ribbon.Tabs[I].UpdateGroupsFont;
end;

{ TdxRibbonPopupMenu }

constructor TdxRibbonPopupMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CheckAssignRibbon;
end;

function TdxRibbonPopupMenu.CreateBarControl: TCustomdxBarControl;
begin
  Result := inherited CreateBarControl;
  if Ribbon <> nil then
    TdxRibbonPopupMenuControl(Result).FPainter := Ribbon.GroupsPainter;
end;

function TdxRibbonPopupMenu.GetControlClass: TCustomdxBarControlClass;
begin
  Result := TdxRibbonPopupMenuControl;
end;

procedure TdxRibbonPopupMenu.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = Ribbon) then
    Ribbon := nil;
end;

procedure TdxRibbonPopupMenu.CheckAssignRibbon;
var
  AForm: TCustomForm;
  I: Integer;
begin
  if not ((csDesigning in ComponentState) and (Owner is TCustomForm)) then Exit;
  AForm := TCustomForm(Owner);
  if AForm <> nil then
  begin
    for I := 0 to AForm.ComponentCount - 1 do
      if AForm.Components[I] is TdxCustomRibbon then
      begin
        Ribbon := TdxCustomRibbon(AForm.Components[I]);
        Break;
      end;
  end;
end;

procedure TdxRibbonPopupMenu.SetRibbon(Value: TdxCustomRibbon);
begin
  if Ribbon <> Value then
  begin
    if Ribbon <> nil then
      Ribbon.RemoveFreeNotification(Self);
    FRibbon := Value;
    if Ribbon <> nil then
      Ribbon.FreeNotification(Self);
  end;
end;

{ TdxRibbonPopupMenuControl }

function TdxRibbonPopupMenuControl.GetBehaviorOptions: TdxBarBehaviorOptions;
begin
  Result := dxRibbonBarBehaviorOptions +
    [bboAllowSelectWindowItemsWithoutFocusing, bboExtendItemWhenAlignedToClient] -
    [bboMouseCantUnselectNavigationItem, bboSubMenuCaptureMouse];
end;

{ TdxBarApplicationMenu }

function TdxBarApplicationMenu.GetControlClass: TCustomdxBarControlClass;
begin
  Result := TdxRibbonApplicationMenuControl;
end;

{ TdxRibbonApplicationMenuControl }

function TdxRibbonApplicationMenuControl.GetBehaviorOptions: TdxBarBehaviorOptions;
begin
  Result := inherited GetBehaviorOptions + [bboItemCustomizePopup];
end;

procedure TdxRibbonApplicationMenuControl.InitCustomizationPopup(AItemLinks: TdxBarItemLinks);
begin
  if Ribbon <> nil then
    Ribbon.PopulatePopupMenuItems(AItemLinks, GetPopupMenuItems, PopupMenuClick);
end;

function TdxRibbonApplicationMenuControl.GetPopupMenuItems: TdxRibbonPopupMenuItems;
begin
  Result := Ribbon.GetValidPopupMenuItems;
  if ExtraPaneItemLinks.IndexOf(BarDesignController.CustomizingItemLink) <> -1 then
    Exclude(Result, rpmiQATAddRemoveItem);
end;

procedure TdxRibbonApplicationMenuControl.PopupMenuClick(Sender: TObject); // see TdxRibbonCustomBarControl
var
  ALinkSelf: TcxObjectLink;
begin
  ALinkSelf := cxAddObjectLink(Self);
  try
    DoPopupMenuClick(Sender);
    if ALinkSelf.Ref <> nil then
      HideAll;
  finally
    cxRemoveObjectLink(ALinkSelf);
  end;
end;

function TdxRibbonApplicationMenuControl.GetRibbon: TdxCustomRibbon;
begin
  if OwnerControl is TdxCustomRibbon then
    Result := TdxCustomRibbon(OwnerControl)
  else
    Result := nil;
end;

procedure TdxRibbonApplicationMenuControl.DoPopupMenuClick(Sender: TObject);
begin
  Ribbon.PopupMenuItemClick(Sender);
end;

procedure TdxRibbonApplicationMenuControl.WMNCHitTest(var Message: TWMNCHitTest);
var
  ARect: TRect;
begin
  if (Ribbon <> nil) and Ribbon.HandleAllocated then
  begin
    ARect := Ribbon.ViewInfo.ApplicationButtonBounds;
    MapWindowRect(Ribbon.Handle, 0, ARect);
    if PtInRect(ARect, SmallPointToPoint(Message.Pos)) then
      Message.Result := HTTRANSPARENT
    else
      inherited;
  end
  else
    inherited;
end;

{ TdxRibbonController }

constructor TdxRibbonController.Create(ARibbon: TdxCustomRibbon);
begin
  inherited Create;
  FRibbon := ARibbon;
  ClearHintInfo;
  CreateTimer;
end;

destructor TdxRibbonController.Destroy;
begin
  FreeAndNil(FScrollTimer);
  inherited Destroy;
end;

function TdxRibbonController.NextTab(ATab: TdxRibbonTab): TdxRibbonTab;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ViewInfo.TabsViewInfo.Count - 1 do
    if ViewInfo.TabsViewInfo[I].Tab = ATab then
    begin
      if I + 1 < ViewInfo.TabsViewInfo.Count then
      begin
        Result := ViewInfo.TabsViewInfo[I + 1].Tab;
        Exit;
      end;
    end;
  if (ATab = nil) and (ViewInfo.TabsViewInfo.Count > 0) then
    Result := ViewInfo.TabsViewInfo[0].Tab;
end;

function TdxRibbonController.PrevTab(ATab: TdxRibbonTab): TdxRibbonTab;
var
  I: Integer;
begin
  Result := nil;
  for I := ViewInfo.TabsViewInfo.Count - 1 downto 0 do
    if ViewInfo.TabsViewInfo[I].Tab = ATab then
    begin
      if I - 1 >= 0 then
      begin
        Result := ViewInfo.TabsViewInfo[I - 1].Tab;
        Exit;
      end;
    end;
  if (ATab = nil) and (ViewInfo.TabsViewInfo.Count > 0) then
    Result := ViewInfo.TabsViewInfo[ViewInfo.TabsViewInfo.Count - 1].Tab;
end;

procedure TdxRibbonController.CheckButtonsMouseUp(X: Integer; Y: Integer);
var
  AHitInfo: TdxRibbonHitInfo;
begin
  AHitInfo := ViewInfo.GetHitInfo(X, Y);
  if AHitInfo.HitTest = PressedObject then
  begin
    case PressedObject of
      rhtMDIMinimizeButton:
        SendMessage(Ribbon.BarManager.ActiveMDIChild, WM_SYSCOMMAND, SC_MINIMIZE, 0);
      rhtMDIRestoreButton:
        SendMessage(Ribbon.BarManager.ActiveMDIChild, WM_SYSCOMMAND, SC_RESTORE, 0);
      rhtMDICloseButton:
        SendMessage(Ribbon.BarManager.ActiveMDIChild, WM_SYSCOMMAND, SC_CLOSE, 0);
      rhtHelpButton:
        Ribbon.DoHelpButtonClick;
    end;
  end;
end;

procedure TdxRibbonController.DoScroll(AOnTimer: Boolean);
begin
  CancelHint;
  case FScrollKind of
    rhtTabScrollLeft, rhtTabScrollRight:
      ScrollTabs(FScrollKind = rhtTabScrollRight, AOnTimer);
    rhtGroupScrollLeft, rhtGroupScrollRight:
      ScrollGroups(FScrollKind = rhtGroupScrollRight, AOnTimer);
  end;
end;

procedure TdxRibbonController.InitTabDesignMenu(AItemLinks: TdxBarItemLinks);
begin
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONADDTAB), DesignTabMenuClick, 0);
  if BarDesignController.LastSelectedItem <> nil then
    BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
      cxGetResourceString(@dxSBAR_RIBBONDELETETAB), DesignTabMenuClick, 1);
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONADDEMPTYGROUP), DesignTabMenuClick, 2, True);
  BarDesignController.AddInternalItem(AItemLinks, TdxBarButton,
    cxGetResourceString(@dxSBAR_RIBBONADDGROUPWITHTOOLBAR), DesignTabMenuClick, 3);
end;

function TdxRibbonController.IsApplicationMenuDropped: Boolean;
begin
  Result := risAppMenuActive in Ribbon.InternalState;
end;

function TdxRibbonController.IsNeedShowHint(AObject: TdxRibbonHitTest): Boolean;
begin
  Result := IsOwnerForHintObject(AObject);
  if Result then
  begin
    case AObject of
      rhtTab:
        Result := (HintInfo.Tab <> nil) and ViewInfo.TabsViewInfo.NeedShowHint;
      rhtApplicationMenu:
        Result := (Ribbon.ApplicationButton.ScreenTip <> nil) and not IsApplicationMenuDropped;
      rhtHelpButton:
        Result := Ribbon.HelpButtonScreenTip <> nil;
    end;
  end;
end;

function TdxRibbonController.IsOwnerForHintObject(AObject: TdxRibbonHitTest): Boolean;
begin
  Result := AObject in [rhtTab, rhtApplicationMenu, rhtHelpButton,
    rhtMDIMinimizeButton, rhtMDIRestoreButton, rhtMDICloseButton];
end;

procedure TdxRibbonController.HideHint;
begin
  if Ribbon.IsBarManagerValid then
    Ribbon.BarManager.HideHint;
end;

procedure TdxRibbonController.KeyDown(var Key: Word; Shift: TShiftState);
begin
  HideHint;
end;

procedure TdxRibbonController.KeyPress(var Key: Char);
begin
end;

procedure TdxRibbonController.KeyUp(var Key: Word; Shift: TShiftState);
begin
end;

procedure TdxRibbonController.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  AHitInfo: TdxRibbonHitInfo;
  ARibbonParentForm: TCustomForm;
begin
  HideHint;
  if IsApplicationMenuDropped and
    Assigned(Ribbon.ApplicationButton.Menu) and Ribbon.ApplicationButton.Menu.Visible then
    Ribbon.ApplicationButton.Menu.SubMenuControl.HideAll;

  AHitInfo := ViewInfo.GetHitInfo(X, Y);
  case AHitInfo.HitTest of
    rhtTab:
      if (Button = mbLeft) and not Ribbon.IsDesigning and (ssDouble in Shift) and AHitInfo.Tab.Active then
        Ribbon.ShowTabGroups := not Ribbon.ShowTabGroups
      else
        ProcessTabClick(AHitInfo.Tab, Button, Shift);
    rhtApplicationMenu:
      if Button = mbLeft then
      begin
        if ssDouble in Shift then
        begin
          ARibbonParentForm := GetParentForm(Ribbon);
          if ARibbonParentForm <> nil then
            ARibbonParentForm.Close;
        end
        else
          if Ribbon.ApplicationMenuPopup then Exit;
      end;
    rhtTabScrollLeft..rhtGroupScrollRight:
      if Button = mbLeft then
        StartScroll(AHitInfo.HitTest);
    else
      if Button = mbRight then
      begin
        if cxRectPtIn(ViewInfo.TabsViewInfo.Bounds, X, Y) or
          (Ribbon.IsQuickAccessToolbarValid and ViewInfo.IsQATAtBottom and
          cxRectPtIn(ViewInfo.QuickAccessToolbarBounds, X, Y)) then
          Ribbon.ShowCustomizePopup;
      end;
  end;
  if Button = mbLeft then
    PressedObject := AHitInfo.HitTest;
end;

procedure TdxRibbonController.MouseLeave;
begin
  if IsOwnerForHintObject(HintInfo.HitTest) then
    CancelHint;
  Ribbon.HighlightedTab := nil;
  HotObject := rhtNone;
end;

procedure TdxRibbonController.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  AHitInfo: TdxRibbonHitInfo;
begin
  AHitInfo := ViewInfo.GetHitInfo(X, Y);
  if ViewInfo.IsApplicationButtonVisible then
  begin
    if Ribbon.ApplicationButtonPressed or IsApplicationMenuDropped then
      Ribbon.ApplicationButtonState := absPressed
    else if AHitInfo.HitTest = rhtApplicationMenu then
      Ribbon.ApplicationButtonState := absHot
    else
      Ribbon.ApplicationButtonState := absNormal;
  end;
  if NotHandleMouseMove(cxPoint(X, Y)) then Exit;
  Ribbon.HighlightedTab := AHitInfo.Tab;
  HotObject := AHitInfo.HitTest;
  HintInfo := AHitInfo;
end;

procedure TdxRibbonController.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  CancelScroll;
  if Button = mbLeft then
  begin
    ReleaseCapture;
    if ViewInfo.IsApplicationButtonVisible then
      Ribbon.ApplicationButtonPressed := False;
    CheckButtonsMouseUp(X, Y);
    PressedObject := rhtNone;
  end;
end;

function TdxRibbonController.MouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
var
  ATab: TdxRibbonTab;
begin
  ATab := NextTab(Ribbon.ActiveTab);
  Result := (ATab <> nil) and Ribbon.CanScrollTabs;
  if Result then
    Ribbon.ActiveTab := ATab;
end;

function TdxRibbonController.MouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
var
  ATab: TdxRibbonTab;
begin
  ATab := PrevTab(Ribbon.ActiveTab);
  Result := (ATab <> nil) and Ribbon.CanScrollTabs;
  if Result then
    Ribbon.ActiveTab := ATab;
end;

function TdxRibbonController.DoHint(var ANeedDeactivate: Boolean; out AHintText: string; out AShortCut: string): Boolean;
begin
  ANeedDeactivate := False;
  Result := IsNeedShowHint(HintInfo.HitTest);
  AHintText := '';
  AShortCut := '';
  if Result then
  begin
    case HintInfo.HitTest of
      rhtTab:
        AHintText := FHintInfo.Tab.Caption;
      rhtApplicationMenu:
        AHintText := Ribbon.ApplicationButton.ScreenTip.Header.Text;
      rhtHelpButton:
        AHintText := Ribbon.HelpButtonScreenTip.Header.Text;
      rhtMDIMinimizeButton:
        AHintText := cxGetResourceString(@dxSBAR_MDIMINIMIZE);
      rhtMDIRestoreButton:
        AHintText := cxGetResourceString(@dxSBAR_MDIRESTORE);
      rhtMDICloseButton:
        AHintText := cxGetResourceString(@dxSBAR_MDICLOSE);
    end;
  end;
end;

function TdxRibbonController.CreateHintViewInfo(
  const AHintText, AShortCut: string): TdxBarCustomHintViewInfo;
var
  ABarManager: TdxBarManager;
  AScreenTip: TdxBarScreenTip;
begin
  if Ribbon.IsBarManagerValid then
    ABarManager := Ribbon.BarManager
  else
    ABarManager := nil;
  case HintInfo.HitTest of
    rhtApplicationMenu:
      AScreenTip := Ribbon.ApplicationButton.ScreenTip;
    rhtHelpButton:
      AScreenTip := Ribbon.HelpButtonScreenTip;
  else
    AScreenTip := nil;
  end;
  Result := dxBarCreateScreenTipViewInfo(ABarManager, AHintText, AShortCut,
    AScreenTip, Ribbon.GroupsPainter);
end;

function TdxRibbonController.GetEnabled: Boolean;
begin
  Result := True;// TODO
end;

function TdxRibbonController.GetHintPosition(const ACursorPos: TPoint; AHeight: Integer): TPoint;
var
  AIndent: Integer;
  R: TRect;
begin
  Result := ACursorPos;
  AIndent := 0;
  case HintInfo.HitTest of
    rhtApplicationMenu:
      begin
        R := ViewInfo.ApplicationButtonBounds;
        Result := cxPoint(R.Left, R.Bottom);
        Result := Ribbon.ClientToScreen(Result);
        if GetDesktopWorkArea(Result).Bottom - Result.Y < AHeight then
        begin
          Result := Ribbon.ClientToScreen(cxPoint(R.Left, 0));
          Dec(Result.Y, AHeight + AIndent);
        end;
      end;
    else
      Inc(Result.Y, 20 {HintOffset});
  end;
end;

procedure TdxRibbonController.CancelHint;
begin
  ClearHintInfo;
  HideHint;
end;

procedure TdxRibbonController.CancelMode;
begin
  Ribbon.HighlightedTab := nil;
  CancelScroll;
  CancelHint;
end;

procedure TdxRibbonController.DesignTabMenuClick(Sender: TObject);
begin
  case TdxBarButton(Sender).Tag of
    0: Ribbon.Tabs.Add;
    1: BarDesignController.DeleteSelectedObjects(True, True);
    2: Ribbon.DesignAddTabGroup(nil, False);
    3: Ribbon.DesignAddTabGroup(nil, True);
  end;
  Ribbon.Modified;
end;

procedure TdxRibbonController.ScrollGroups(AScrollLeft, AOnTimer: Boolean);
begin
  Ribbon.ActiveTab.ScrollDockControlGroups(AScrollLeft, AOnTimer);
end;

procedure TdxRibbonController.ScrollTabs(AScrollLeft, AOnTimer: Boolean);
const
  ScrollDelta: array[Boolean, Boolean] of Integer = ((-dxRibbonTabMinWidth div 2, dxRibbonTabMinWidth div 2), (-3, 3));
begin
  with ViewInfo.TabsViewInfo do
    ScrollPosition := ScrollPosition + ScrollDelta[AOnTimer, AScrollLeft];
end;

procedure TdxRibbonController.SetHintInfo(const Value: TdxRibbonHitInfo);
var
  ANeedHide: Boolean;
begin
  if Ribbon.IsLocked or not Ribbon.IsBarManagerValid then Exit;
  if (HintInfo.HitTest <> Value.HitTest) or (HintInfo.Tab <> Value.Tab) then
  begin
    ANeedHide := IsOwnerForHintObject(HintInfo.HitTest);
    FHintInfo := Value;
    if IsOwnerForHintObject(HintInfo.HitTest) then
      Ribbon.BarManager.ActivateHint(True, '', Self)
    else
      if ANeedHide then
        HideHint;
  end;
end;

procedure TdxRibbonController.SetHotObject(const Value: TdxRibbonHitTest);
var
  APrev: TdxRibbonHitTest;
  I: Integer;
begin
  if FHotObject <> Value then
  begin
    APrev := FHotObject;
    FHotObject := Value;
    if ViewInfo.IsApplicationButtonVisible then
      if not IsApplicationMenuDropped then
        Ribbon.ApplicationButtonState := absNormal;
    for I := 0 to Ribbon.FadingHelpersCount - 1 do
      Ribbon.FadingHelper[I].UpdateHotObject(APrev, FHotObject);
    Invalidate(APrev, FHotObject);
  end;
end;

procedure TdxRibbonController.SetPressedObject(const Value: TdxRibbonHitTest);
var
  APrev: TdxRibbonHitTest;
begin
  if FPressedObject <> Value then
  begin
    APrev := FPressedObject;
    FPressedObject := Value;
    if not (FPressedObject in [rhtNone, rhtTab, rhtApplicationMenu]) then
      SetCapture(Ribbon.Handle);
    Invalidate(APrev, FPressedObject);
  end;
end;

procedure TdxRibbonController.ShowTabDesignMenu;
begin
  BarDesignController.ShowCustomCustomizePopup(Ribbon.BarManager,
    InitTabDesignMenu, Ribbon.GroupsPainter);
end;

function TdxRibbonController.NotHandleMouseMove(P: TPoint): Boolean;
begin
  if Ribbon.IsBarManagerValid and not Ribbon.IsDesigning then
    Result := (FScrollKind <> rhtNone) or
      (not IsFormActive(Ribbon.BarManager.ParentForm) and not IsFormActive(Ribbon.FTabGroupsPopupWindow) or HasPopupWindowAbove(nil, False))
  else
    Result := True;
end;

procedure TdxRibbonController.ProcessTabClick(ATab: TdxRibbonTab;
  Button: TMouseButton; Shift: TShiftState);
begin
  if CanProcessDesignTime then
  begin
    Ribbon.ActiveTab := ATab;
    BarDesignController.SelectItem(ATab);
    if Button = mbRight then
      ShowTabDesignMenu;
  end;
  if not Ribbon.IsDesigning then
  begin
    if Button = mbLeft then
    begin
      Ribbon.ActiveTab := ATab;
      if not (ssDouble in Shift) and not Ribbon.ShowTabGroups and
        (not Assigned(Ribbon.TabGroupsPopupWindow) or not Ribbon.TabGroupsPopupWindow.JustClosed) then
        Ribbon.ShowTabGroupsPopupWindow;
    end
    else if Button = mbRight then
      Ribbon.ShowCustomizePopup;
  end;
end;

procedure TdxRibbonController.CancelScroll;
begin
  FScrollKind := rhtNone;
  InvalidateScrollButtons;
  FScrollTimer.Enabled := False;
end;

function TdxRibbonController.CanProcessDesignTime: Boolean;
begin
  Result := Ribbon.IsDesigning and Ribbon.IsBarManagerValid;
end;

procedure TdxRibbonController.ClearHintInfo;
begin
  FHintInfo.HitTest := rhtNone;
  FHintInfo.Tab := nil;
end;

procedure TdxRibbonController.CreateTimer;
begin
  FScrollTimer := TTimer.Create(nil);
  FScrollTimer.Enabled := False;
  FScrollTimer.OnTimer := OnTimer;
end;

function TdxRibbonController.GetViewInfo: TdxRibbonViewInfo;
begin
  Result := Ribbon.ViewInfo;
end;

procedure TdxRibbonController.Invalidate(AOld, ANew: TdxRibbonHitTest);

   procedure InvalidateObject(AObject: TdxRibbonHitTest);
   begin
     case AObject of
       rhtTabScrollLeft..rhtGroupScrollRight:
         InvalidateScrollButtons;
       rhtHelpButton..rhtMDICloseButton:
         InvalidateButtons;
     end;
   end;

begin
  InvalidateObject(AOld);
  InvalidateObject(ANew);
end;

procedure TdxRibbonController.InvalidateScrollButtons;
begin
  with ViewInfo do
  begin
    TabsViewInfo.InvalidateScrollButtons;
    GroupsDockControlSiteViewInfo.InvalidateScrollButtons;
  end;
end;

procedure TdxRibbonController.InvalidateButtons;
begin
  with ViewInfo do
  begin
    InvalidateMDIButtons;
    InvalidateHelpButton;
  end;
end;

procedure TdxRibbonController.StartScroll(AScrollKind: TdxRibbonHitTest);
begin
  if not (AScrollKind in [rhtTabScrollLeft..rhtGroupScrollRight]) then Exit;
  FScrollKind := AScrollKind;
  FScrollTimer.Interval := dxRibbonScrollDelay;
  DoScroll(False);
  FScrollTimer.Enabled := True;
end;

procedure TdxRibbonController.OnTimer(Sender: TObject);
var
  P: TPoint;
begin
  FScrollTimer.Interval := dxRibbonScrollInterval;
  P := Ribbon.ScreenToClient(GetMouseCursorPos);
  if ViewInfo.GetHitInfo(P.X, P.Y).HitTest = FScrollKind then
    DoScroll(True);
end;

{ TdxRibbonGroupsDockControlSiteViewInfo }

constructor TdxRibbonGroupsDockControlSiteViewInfo.Create(
  ASite: TdxRibbonGroupsDockControlSite);
var
  AButton: TdxRibbonScrollButton;
begin
  inherited Create;
  FSite := ASite;
  for AButton := Low(AButton) to High(AButton) do
  begin
    FTabGroupsScrollFadingHelpers[AButton] :=
      TdxRibbonGroupsScrollButtonFadingHelper.Create(ASite);
    FTabGroupsScrollFadingHelpers[AButton].FScrollButton := AButton;
  end;
end;

destructor TdxRibbonGroupsDockControlSiteViewInfo.Destroy;
var
  AButton: TdxRibbonScrollButton;
begin
  for AButton := Low(AButton) to High(AButton) do
    FTabGroupsScrollFadingHelpers[AButton].Free;
  inherited Destroy;
end;

procedure TdxRibbonGroupsDockControlSiteViewInfo.Calculate;
var
  AScrollButtonWidth: Integer;
  R: TRect;
begin
  FTabGroupsScrollButtonBounds[rsbLeft] := cxEmptyRect;
  FTabGroupsScrollButtonBounds[rsbRight] := cxEmptyRect;
  if FSite.Ribbon.ViewInfo.IsTabGroupsVisible and (FSite.Ribbon.ActiveTab <> nil) then
  begin
    FTabGroupsScrollButtons := FSite.Ribbon.ActiveTab.DockControl.ViewInfo.ScrollButtons;
    R := GetControlRect(FSite);
    AScrollButtonWidth := FSite.Ribbon.ViewInfo.GetScrollButtonWidth;
    if rsbLeft in FTabGroupsScrollButtons then
      FTabGroupsScrollButtonBounds[rsbLeft] := Rect(R.Left, R.Top, R.Left + AScrollButtonWidth, R.Bottom);
    if rsbRight in FTabGroupsScrollButtons then
      FTabGroupsScrollButtonBounds[rsbRight] := Rect(R.Right - AScrollButtonWidth, R.Top, R.Right, R.Bottom);
  end;
end;

function TdxRibbonGroupsDockControlSiteViewInfo.GetHitInfo(
  var AHitInfo: TdxRibbonHitInfo; X, Y: Integer): Boolean;
const
  AHitTestMap: array[TdxRibbonScrollButton] of TdxRibbonHitTest =
    (rhtGroupScrollLeft, rhtGroupScrollRight);
var
  AButton: TdxRibbonScrollButton;
  P: TPoint;
begin
  Result := False;
  P := FSite.ScreenToClient(FSite.Ribbon.ClientToScreen(Point(X, Y)));
  for AButton := Low(TdxRibbonScrollButton) to High(TdxRibbonScrollButton) do
    if PtInRect(FTabGroupsScrollButtonBounds[AButton], P) then
    begin
      Result := True;
      AHitInfo.HitTest := AHitTestMap[AButton];
      Break;
    end;
end;

procedure TdxRibbonGroupsDockControlSiteViewInfo.InvalidateScrollButtons;
begin
  FSite.Invalidate;
end;

procedure TdxRibbonGroupsDockControlSiteViewInfo.Paint(ACanvas: TcxCanvas);

  procedure DrawScrollButton(AButton: TdxRibbonScrollButton);
  begin
    if not FTabGroupsScrollFadingHelpers[AButton].IsEmpty then
      FTabGroupsScrollFadingHelpers[AButton].DrawImage(ACanvas.Handle,
        FTabGroupsScrollButtonBounds[AButton])
    else
      FSite.Ribbon.Painter.DrawGroupsScrollButton(BarCanvas,
        FTabGroupsScrollButtonBounds[AButton], AButton = rsbLeft,
        GetTabGroupsScrollButtonPressed(AButton),
        GetTabGroupsScrollButtonHot(AButton));
    FSite.Ribbon.Painter.DrawGroupsScrollButtonArrow(BarCanvas,
      FTabGroupsScrollButtonBounds[AButton], AButton = rsbLeft);
    ACanvas.ExcludeClipRect(FTabGroupsScrollButtonBounds[AButton]);
  end;

var
  AViewInfo: TdxRibbonViewInfo;
  ATab: TdxRibbonTab;
  P, ASaveOrg: TPoint;
begin
  BarCanvas.BeginPaint(ACanvas.Canvas);
  try
    AViewInfo := FSite.Ribbon.ViewInfo;
    ASaveOrg := BarCanvas.WindowOrg;
    P := ASaveOrg;
    AViewInfo.Painter.DrawGroupsArea(BarCanvas, GetControlRect(FSite));
    MapWindowPoint(FSite.Handle, FSite.Ribbon.Handle, P);
    BarCanvas.WindowOrg := P;
    ATab := FSite.Ribbon.ActiveTab;
    if (ATab <> nil) and (ATab.ViewInfo <> nil) then
    begin
      BarCanvas.SaveClipRegion;
      BarCanvas.IntersectClipRect(AViewInfo.TabsViewInfo.GetRealBounds);
      ATab.ViewInfo.Paint(BarCanvas);
      BarCanvas.RestoreClipRegion;
    end;
    BarCanvas.WindowOrg := ASaveOrg;
    if rsbLeft in TabGroupsScrollButtons then
      DrawScrollButton(rsbLeft);
    if rsbRight in TabGroupsScrollButtons then
      DrawScrollButton(rsbRight);
  finally
    BarCanvas.EndPaint;
  end;
end;

function TdxRibbonGroupsDockControlSiteViewInfo.GetTabGroupsScrollButtonHot(
  AButton: TdxRibbonScrollButton): Boolean;
begin
  with FSite.Ribbon.Controller do
    Result :=
      ((HotObject = rhtGroupScrollLeft) and (AButton = rsbLeft)) or
      ((HotObject = rhtGroupScrollRight) and (AButton = rsbRight));
end;

function TdxRibbonGroupsDockControlSiteViewInfo.GetTabGroupsScrollButtonPressed(
  AButton: TdxRibbonScrollButton): Boolean;
begin
  with FSite.Ribbon.Controller do
    Result := 
      ((ScrollKind = rhtGroupScrollLeft) and (AButton = rsbLeft)) or
      ((ScrollKind = rhtGroupScrollRight) and (AButton = rsbRight));
end;

{ TdxRibbonGroupsDockControlSite }

constructor TdxRibbonGroupsDockControlSite.Create(ARibbon: TdxCustomRibbon);
begin
  inherited Create(ARibbon);
  FRibbon := ARibbon;
  FViewInfo := TdxRibbonGroupsDockControlSiteViewInfo.Create(Self);
  DoubleBuffered := True;
end;

destructor TdxRibbonGroupsDockControlSite.Destroy;
begin
  FreeAndNil(FViewInfo);
  inherited Destroy;
end;

function TdxRibbonGroupsDockControlSite.CanFocus: Boolean;
begin
  Result := False;
end;

procedure TdxRibbonGroupsDockControlSite.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
end;

procedure TdxRibbonGroupsDockControlSite.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    WindowClass.style := WindowClass.style and not (CS_VREDRAW + CS_HREDRAW);
end;

procedure TdxRibbonGroupsDockControlSite.DoCancelMode;
begin
  inherited DoCancelMode;
  Ribbon.Controller.CancelMode;
end;

function TdxRibbonGroupsDockControlSite.DoMouseWheelDown(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelDown(Shift, MousePos);
  if not Result then
    Result := Ribbon.Controller.MouseWheelDown(Shift, MousePos);
end;

function TdxRibbonGroupsDockControlSite.DoMouseWheelUp(Shift: TShiftState;
  MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelUp(Shift, MousePos);
  if not Result then
    Result := Ribbon.Controller.MouseWheelUp(Shift, MousePos);
end;

function TdxRibbonGroupsDockControlSite.MayFocus: Boolean;
begin
  Result := False;
end;

procedure TdxRibbonGroupsDockControlSite.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  with Ribbon.ScreenToClient(ClientToScreen(Point(X, Y))) do
    Ribbon.Controller.MouseDown(Button, Shift, X, Y);
end;

procedure TdxRibbonGroupsDockControlSite.MouseLeave(AControl: TControl);
begin
  inherited MouseLeave(AControl);
  Ribbon.Controller.MouseLeave;
end;

procedure TdxRibbonGroupsDockControlSite.MouseMove(Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  with Ribbon.ScreenToClient(ClientToScreen(Point(X, Y))) do
    Ribbon.Controller.MouseMove(Shift, X, Y);
end;

procedure TdxRibbonGroupsDockControlSite.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  with Ribbon.ScreenToClient(ClientToScreen(Point(X, Y))) do
    Ribbon.Controller.MouseUp(Button, Shift, X, Y);
end;

function TdxRibbonGroupsDockControlSite.NeedsScrollBars: Boolean;
begin
  Result := False;
end;

procedure TdxRibbonGroupsDockControlSite.Paint;
begin
  ViewInfo.Paint(Canvas);
end;

procedure TdxRibbonGroupsDockControlSite.SetRedraw(ARedraw: Boolean);
begin
  if HandleAllocated then
  begin
    SendMessage(Handle, WM_SETREDRAW, Ord(ARedraw), 0);
    if ARedraw and IsWindowVisible(Handle) then
      InvalidateWithChildren;
  end;
end;

function TdxRibbonGroupsDockControlSite.GetDockControl: TdxRibbonGroupsDockControl;
begin
  Result := Ribbon.ActiveTab.DockControl;
end;

{ TdxRibbonElementCustomFadingHelper }

constructor TdxRibbonElementCustomFadingHelper.Create(ARibbon: TdxCustomRibbon);
begin
  FRibbon := ARibbon;
  FRibbon.FFadingHelperList.Add(Self);
end;

destructor TdxRibbonElementCustomFadingHelper.Destroy;
begin
  FRibbon.FFadingHelperList.Remove(Self);
  FRibbon.RemoveFadingObject(Self);
  inherited Destroy;
end;

procedure TdxRibbonElementCustomFadingHelper.UpdateHotObject(
  APrevHotObject: TdxRibbonHitTest; AHotObject: TdxRibbonHitTest);
begin
  if CanFade then
  begin
    if IsOurObject(APrevHotObject) then
      Fader.FadeOut(Self);
    if IsOurObject(AHotObject) then
      Fader.FadeIn(Self);
  end;
end;

function TdxRibbonElementCustomFadingHelper.CanFade: Boolean;
begin
  Result := Ribbon.CanFade;
end;

function TdxRibbonElementCustomFadingHelper.GetFader: TdxFader;
begin
  Result := Ribbon.Fader;
end;

function TdxRibbonElementCustomFadingHelper.GetPainter: TdxRibbonPainter;
begin
  Result := Ribbon.Painter;
end;

function TdxRibbonElementCustomFadingHelper.GetViewInfo: TdxRibbonViewInfo;
begin
  Result := Ribbon.ViewInfo;
end;

function TdxRibbonElementCustomFadingHelper.IsOurObject(
  AHotObject: TdxRibbonHitTest): Boolean;
begin
  Result := False;
end;

{ TdxRibbonHelpButtonFadingHelper }

function TdxRibbonHelpButtonFadingHelper.CanFade: Boolean;
begin
  Result := ViewInfo.HasHelpButton and inherited CanFade;
end;

procedure TdxRibbonHelpButtonFadingHelper.DrawFadeImage;
begin
  if not Ribbon.IsDestroying then
    ViewInfo.InvalidateHelpButton;
end;

function TdxRibbonHelpButtonFadingHelper.IsOurObject(
  AHotObject: TdxRibbonHitTest): Boolean;
begin
  Result := AHotObject = rhtHelpButton;
end;

procedure TdxRibbonHelpButtonFadingHelper.GetFadingParams(
  out AFadeOutImage, AFadeInImage: TcxBitmap;
  var AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
  var AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);
begin
  AFadeInImage := TcxBitmap.CreateSize(ViewInfo.HelpButtonBounds, pf32bit);
  AFadeOutImage := TcxBitmap.CreateSize(ViewInfo.HelpButtonBounds, pf32bit);
  Painter.ColorScheme.DrawHelpButton(AFadeOutImage.Canvas.Handle,
    AFadeOutImage.ClientRect, bisNormal);
  Painter.ColorScheme.DrawHelpButton(AFadeInImage.Canvas.Handle,
    AFadeInImage.ClientRect, bisHot);
end;

{ TdxRibbonMDIButtonFadingHelper }

function TdxRibbonMDIButtonFadingHelper.CanFade: Boolean;
begin
  Result := ViewInfo.HasMDIButtons and inherited CanFade;
end;

procedure TdxRibbonMDIButtonFadingHelper.DrawFadeImage;
begin
  if not Ribbon.IsDestroying then
    ViewInfo.InvalidateMDIButtons;
end;

function TdxRibbonMDIButtonFadingHelper.IsOurObject(
  AHotObject: TdxRibbonHitTest): Boolean;
begin
  case MDIButton of
    mdibMinimize:
      Result := AHotObject = rhtMDIMinimizeButton;
    mdibRestore:
      Result := AHotObject = rhtMDIRestoreButton;
    mdibClose:
      Result := AHotObject = rhtMDICloseButton;
    else
      Result := False;
  end;
end;

procedure TdxRibbonMDIButtonFadingHelper.GetFadingParams(
  out AFadeOutImage: TcxBitmap; out AFadeInImage: TcxBitmap;
  var AFadeInAnimationFrameCount: Integer; var AFadeInAnimationFrameDelay: Integer;
  var AFadeOutAnimationFrameCount: Integer; var AFadeOutAnimationFrameDelay: Integer);
begin
  AFadeInImage := TcxBitmap.CreateSize(ViewInfo.FMDIButtonBounds[MDIButton], pf32bit);
  AFadeOutImage := TcxBitmap.CreateSize(ViewInfo.FMDIButtonBounds[MDIButton], pf32bit);
  Painter.ColorScheme.DrawMDIButton(AFadeInImage.Canvas.Handle,
    AFadeInImage.ClientRect, MDIButton, bisHot);
  Painter.ColorScheme.DrawMDIButton(AFadeOutImage.Canvas.Handle,
    AFadeOutImage.ClientRect, MDIButton, bisNormal);
end;

{ TdxRibbonTabScrollButtonFadingHelper }

function TdxRibbonTabScrollButtonFadingHelper.CanFade: Boolean;
begin
  Result := inherited CanFade and IsButtonVisible;
end;

procedure TdxRibbonTabScrollButtonFadingHelper.DrawFadeImage;
begin
  if not Ribbon.IsDestroying then
    Ribbon.Controller.InvalidateScrollButtons;
end;

function TdxRibbonTabScrollButtonFadingHelper.IsOurObject(
  AHotObject: TdxRibbonHitTest): Boolean;
const
  HotObjectsMap: array[TdxRibbonScrollButton] of TdxRibbonHitTest =
    (rhtTabScrollLeft, rhtTabScrollRight);
begin
  Result := HotObjectsMap[ScrollButton] = AHotObject;
end;

procedure TdxRibbonTabScrollButtonFadingHelper.GetFadingParams(
  out AFadeOutImage: TcxBitmap; out AFadeInImage: TcxBitmap;
  var AFadeInAnimationFrameCount: Integer; var AFadeInAnimationFrameDelay: Integer;
  var AFadeOutAnimationFrameCount: Integer; var AFadeOutAnimationFrameDelay: Integer);
begin
  AFadeOutImage := TcxBitmap.CreateSize(
    TabsViewInfo.ScrollButtonBounds[ScrollButton], pf32bit);
  AFadeInImage := TcxBitmap.CreateSize(
    TabsViewInfo.ScrollButtonBounds[ScrollButton], pf32bit);
  Painter.DrawTabScrollButton(AFadeInImage.cxCanvas, AFadeInImage.ClientRect,
    ScrollButton = rsbLeft, False, True);
  Painter.DrawTabScrollButton(AFadeOutImage.cxCanvas, AFadeOutImage.ClientRect,
    ScrollButton = rsbLeft, False, False);
end;

function TdxRibbonTabScrollButtonFadingHelper.GetIsButtonVisible: Boolean;
begin
  Result := (ScrollButton in TabsViewInfo.ScrollButtons);
end;

function TdxRibbonTabScrollButtonFadingHelper.GetTabsViewInfo: TdxRibbonTabsViewInfo;
begin
  Result := Ribbon.ViewInfo.TabsViewInfo;
end;

{ TdxRibbonGroupsScrollButtonFadingHelper }

constructor TdxRibbonGroupsScrollButtonFadingHelper.Create(
  ASite: TdxRibbonGroupsDockControlSite);
begin
  inherited Create(ASite.Ribbon);
  FSite := ASite;
end;

procedure TdxRibbonGroupsScrollButtonFadingHelper.GetFadingParams(
  out AFadeOutImage: TcxBitmap; out AFadeInImage: TcxBitmap;
  var AFadeInAnimationFrameCount: Integer; var AFadeInAnimationFrameDelay: Integer;
  var AFadeOutAnimationFrameCount: Integer; var AFadeOutAnimationFrameDelay: Integer);
begin
  AFadeOutImage := TcxBitmap.CreateSize(
    Site.ViewInfo.FTabGroupsScrollButtonBounds[ScrollButton], pf32bit);
  AFadeInImage := TcxBitmap.CreateSize(
    Site.ViewInfo.FTabGroupsScrollButtonBounds[ScrollButton], pf32bit);
  Painter.DrawGroupsScrollButton(AFadeInImage.cxCanvas,
    AFadeInImage.ClientRect, ScrollButton = rsbLeft, False, True);
  Painter.DrawGroupsScrollButton(AFadeOutImage.cxCanvas,
    AFadeOutImage.ClientRect, ScrollButton = rsbLeft, False, False);
end;

function TdxRibbonGroupsScrollButtonFadingHelper.GetIsButtonVisible: Boolean;
begin
  Result := ScrollButton in Site.ViewInfo.TabGroupsScrollButtons;
end;

function TdxRibbonGroupsScrollButtonFadingHelper.IsOurObject(
  AHotObject: TdxRibbonHitTest): Boolean;
const
  HotObjectsMap: array[TdxRibbonScrollButton] of TdxRibbonHitTest =
    (rhtGroupScrollLeft, rhtGroupScrollRight);
begin
  Result := HotObjectsMap[ScrollButton] = AHotObject;
end;

{ TdxRibbonApplicationButtonFadingHelper }

function TdxRibbonApplicationButtonFadingHelper.CanFade: Boolean;
begin
  Result := inherited CanFade and ViewInfo.IsApplicationButtonVisible and not
    Ribbon.Controller.IsApplicationMenuDropped;
end;

procedure TdxRibbonApplicationButtonFadingHelper.DrawFadeImage;
begin
  if not Ribbon.IsDestroying then
    Ribbon.InvalidateApplicationButton;
end;

function TdxRibbonApplicationButtonFadingHelper.IsOurObject(
  AHotObject: TdxRibbonHitTest): Boolean;
begin
  Result := AHotObject = rhtApplicationMenu;
end;

procedure TdxRibbonApplicationButtonFadingHelper.GetFadingParams(
  out AFadeOutImage, AFadeInImage: TcxBitmap;
  var AFadeInAnimationFrameCount, AFadeInAnimationFrameDelay: Integer;
  var AFadeOutAnimationFrameCount, AFadeOutAnimationFrameDelay: Integer);
begin
  AFadeInImage := TcxBitmap.CreateSize(
    ViewInfo.ApplicationButtonImageBounds, pf32bit);
  AFadeOutImage := TcxBitmap.CreateSize(
    ViewInfo.ApplicationButtonImageBounds, pf32bit);
  Painter.ColorScheme.DrawApplicationButton(AFadeInImage.Canvas.Handle,
    AFadeInImage.ClientRect, absHot);
  Painter.ColorScheme.DrawApplicationButton(AFadeOutImage.Canvas.Handle,
    AFadeOutImage.ClientRect, absNormal);
end;

{ TdxCustomRibbon }

constructor TdxCustomRibbon.Create(AOwner: TComponent);
begin
  Include(FInternalState, risCreating);
  RibbonCheckCreateComponent(AOwner, ClassType);
  Exclude(FInternalState, risCreating);
  inherited Create(AOwner);
  DoubleBuffered := True;
  FPainter := CreatePainter;
  FFadingHelperList := TList.Create;
  FViewInfo := CreateViewInfo;
  FGroupsDockControlSite := TdxRibbonGroupsDockControlSite.Create(Self);
  FGroupsDockControlSite.Parent := Self;
  FGroupsPainter := CreateGroupsPainter;
  FFonts := TdxRibbonFonts.Create(Self);
  FTabs := TdxRibbonTabCollection.Create(Self);
  Align := alTop;
  FShowTabGroups := True;
  FShowTabHeaders := True;
  FApplicationButton := CreateApplicationButton;
  FQuickAccessToolbar := CreateQuickAccessToolbar;
  FController := CreateController;
  FPopupMenuItems := [rpmiItems, rpmiMoreCommands, rpmiQATPosition, rpmiQATAddRemoveItem, rpmiMinimizeRibbon];
  FColorSchemeHandlers := TcxEventHandlerCollection.Create;

  FLockModified := True;
  try
    InitColorScheme;
    if IsDesigning then
    begin
      BarManager := GetBarManagerByComponent(AOwner);
      if FBarManager = nil then
        BarManager := TdxBarManager(dxBarManagerList[0]);
      Tabs.Add;
    end;
  finally
    FLockModified := False;
  end;
  Fading := True;
  FInternalItems := TComponentList.Create;
  FRibbonFormNonClientPainters := TList.Create;
end;

destructor TdxCustomRibbon.Destroy;
begin
  if risCreating in FInternalState then Exit;
  BarAccessibilityHelperOwnerObjectDestroyed(FIAccessibilityHelper);
  FreeAndNil(FRibbonFormNonClientPainters);
  FreeAndNil(FTabGroupsPopupWindow);
  FreeAndNil(FInternalItems);
  FreeAndNil(FController);
  FreeAndNil(FColorSchemeHandlers);
  IniFileProceduresRemove; //For removing procedures when BarManager in destroying state
  BarManager := nil;
  SupportNonClientDrawing := False;
  FreeAndNil(FApplicationButton);
  FreeAndNil(FQuickAccessToolbar);
  dxFreeAndNil(FTabs);
  FreeAndNil(FViewInfo);
  FreeAndNil(FGroupsPainter);
  FreeAndNil(FPainter);
  FreeAndNil(FFonts);
  inherited Destroy;
  FreeAndNil(FFadingHelperList);
end;

function TdxCustomRibbon.ApplicationMenuPopup: Boolean;
var
  P: TPoint;
  AOwnerOffset: Integer;
  AOwnerBounds: TRect;
begin
  Result := False;
  if not (risAppMenuActive in FInternalState) then
  begin
    FApplicationButtonPressed := True;
    ApplicationButtonState := absPressed;
    try
      if not DoApplicationMenuClick and (ApplicationButton.Menu <> nil) then
      begin
        P := ViewInfo.ApplicationButtonBounds.TopLeft;
        P.Y := ViewInfo.GetTabsBounds.Top;
        AOwnerOffset := P.Y - ViewInfo.ApplicationButtonImageBounds.Top;
        P := ClientToScreen(P);
        AOwnerBounds := ViewInfo.ApplicationButtonImageBounds;
        FPrevOnApplicationMenuPopup := ApplicationButton.Menu.OnPopup;
        ApplicationButton.Menu.OnPopup := ApplicationMenuPopupNotification;
        Include(FInternalState, risAppMenuActive);
        try
          ApplicationButton.Menu.PopupEx(P.X, P.Y, 0, AOwnerOffset, False, @AOwnerBounds, True, Self);
        finally
          Result := True;
          Exclude(FInternalState, risAppMenuActive);
          if ApplicationButton.Menu <> nil then
            ApplicationButton.Menu.OnPopup := FPrevOnApplicationMenuPopup;
        end;
      end
      else
        BarNavigationController.StopKeyboardHandling;
    finally
      FApplicationButtonPressed := False;
      ApplicationButtonState := absNormal;
      Controller.PressedObject := rhtNone;
    end;
  end;
end;

function TdxCustomRibbon.AreGroupsVisible: Boolean;
begin
  Result := not Hidden and (ShowTabGroups or IsPopupGroupsMode);
end;

procedure TdxCustomRibbon.BeginUpdate;
begin
  Inc(FLockCount);
  GroupsDockControlSite.SetRedraw(False);
end;

function TdxCustomRibbon.CanFocus: Boolean;
begin
  Result := False;
end;

procedure TdxCustomRibbon.CheckHide;
var
  F: TCustomForm;
  DC: HDC;
begin
  if FHidden xor ViewInfo.IsNeedHideControl then
  begin
    F := GetParentForm(Self{$IFDEF DELPHI8}, False{$ENDIF});
    if not FHidden and (F <> nil) and F.HandleAllocated then
    begin
      Changed;
      F.Invalidate;
      DC := GetDC(F.Handle);
      try
        SendMessage(F.Handle, WM_ERASEBKGND, DC, DC);
      finally
        ReleaseDC(F.Handle, DC);
      end;
    end
    else
      Changed;
  end;
end;

procedure TdxCustomRibbon.CloseTabGroupsPopupWindow;
begin
  if IsPopupGroupsMode then
    TabGroupsPopupWindow.CloseUp;
end;

procedure TdxCustomRibbon.EndUpdate;
begin
  Dec(FLockCount);
  if (FLockCount = 0) and not IsDestroying then
  begin
    Changed;
    GroupsDockControlSite.SetRedraw(True);
    RibbonFormInvalidate;
  end;
end;

function TdxCustomRibbon.GetTabAtPos(X, Y: Integer): TdxRibbonTab;
begin
  Result := ViewInfo.GetTabAtPos(X, Y);
end;

procedure TdxCustomRibbon.ShowTabGroupsPopupWindow;
begin
  if ShowTabGroups then Exit;
  if FTabGroupsPopupWindow = nil then
    FTabGroupsPopupWindow := TdxRibbonTabGroupsPopupWindow.Create(Self);
  FTabGroupsPopupWindow.OwnerBounds := BoundsRect;
  FTabGroupsPopupWindow.OwnerParent := Parent;
  FTabGroupsPopupWindow.Popup(nil);
  FTabGroupsPopupWindow.Invalidate;
  Invalidate;
end;

procedure TdxCustomRibbon.AddTab(ATab: TdxRibbonTab);
begin
  if ATab = nil then Exit;
  ATab.Ribbon := Self;
  if ActiveTab = nil then
    ActiveTab := ATab;
  Changed;
end;

procedure TdxCustomRibbon.RemoveTab(ATab: TdxRibbonTab);
begin
  if ATab = nil then Exit;
  BarDesignController.LockDesignerModified;
  try
    ATab.Ribbon := nil;
    if ActiveTab = ATab then
      SetNextActiveTab(ATab);
  finally
    BarDesignController.UnLockDesignerModified;
  end;
  Changed;
end;

procedure TdxCustomRibbon.SetNextActiveTab(ATab: TdxRibbonTab);
begin
  FLockModified := csDestroying in ATab.ComponentState;
  try
    ActiveTab := GetNextActiveTab(ATab);
  finally
    FLockModified := False;
  end;
end;

procedure TdxCustomRibbon.FullInvalidate;
begin
  if IsDestroying or not (HandleAllocated and Visible) then Exit;
  QuickAccessToolbar.UpdateColorScheme;
  if ActiveTab <> nil then
    ActiveTab.UpdateColorScheme;
  RibbonFormInvalidate;
  FGroupsDockControlSite.Invalidate; //for CBuilder
  Invalidate;
end;

procedure TdxCustomRibbon.Changed;
begin
  if IsLocked then Exit;
  if not (IsDesigning or LockedCancelHint) then
    Fader.Clear;
  if not LockedCancelHint then
    Controller.CancelHint;
  CalculateFormCaptionHeight;
  if FormCaptionHelper <> nil then
    FormCaptionHelper.Calculate;
  ViewInfo.Calculate(ClientBounds);
  Invalidate;
end;

procedure TdxCustomRibbon.RecalculateBars;
var
  I: Integer;
begin
  if IsBarManagerValid then
  begin

    with QuickAccessToolbar do
      if Assigned(Toolbar) and (Toolbar.Control is TdxRibbonQuickAccessBarControl) then
      begin
        with TdxRibbonQuickAccessBarControl(Toolbar.Control) do
          UpdateDefaultGlyph(FDefaultGlyph);
        Toolbar.Control.RepaintBar; // Flush glyph cache
      end;

    with BarManager do
    begin
      BeginUpdate;
      try
        for I := 0 to Bars.Count - 1 do
          if Bars.Items[I].Control <> nil then
            TdxBarControlAccess(Bars.Items[I].Control).CalcDrawingConsts;
      finally
        EndUpdate;
      end;
    end;

  end;
end;

procedure TdxCustomRibbon.DrawRibbonFormCaption(ACanvas: TcxCanvas;
  const ABounds: TRect; const ACaption: string; const AData: TdxRibbonFormData);
begin
  Painter.DrawRibbonFormCaption(ACanvas, ABounds, AData);
end;

procedure TdxCustomRibbon.DrawRibbonFormBorderIcon(ACanvas: TcxCanvas;
  const ABounds: TRect; AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState);
begin
  Painter.DrawRibbonFormBorderIcon(ACanvas, ABounds, AIcon, AState);
end;

procedure TdxCustomRibbon.DrawRibbonFormBorders(ACanvas: TcxCanvas;
  const AData: TdxRibbonFormData; const ABordersWidth: TRect);
begin
  CheckDrawRibbonFormStatusBarBorders(ACanvas, AData, ABordersWidth);
  Painter.DrawRibbonFormBorders(ACanvas, ABordersWidth, AData);
end;

function TdxCustomRibbon.GetRibbonApplicationButtonRegion: HRGN;
begin
  Result := ViewInfo.GetApplicationButtonRegion;
end;

function TdxCustomRibbon.GetRibbonFormCaptionHeight: Integer;
begin
  Result := FCalculatedFormCaptionHeight;
end;

function TdxCustomRibbon.GetRibbonFormColor: TColor;
begin
  Result := ColorScheme.GetPartColor(rfspRibbonForm);
end;

function TdxCustomRibbon.GetRibbonLoadedHeight: Integer;
begin
  Result := FLoadedHeight;
end;

function TdxCustomRibbon.GetTaskbarCaption: TCaption;
begin
  if (RibbonForm <> nil) and (RibbonForm.FormStyle = fsMDIForm) then
  begin
    Result := RibbonForm.Caption;
    if DocumentName <> '' then
      Result := Result + ' - ' + DocumentName;
  end
  else
    Result := ViewInfo.GetFormCaptionText;
end;

function TdxCustomRibbon.GetValidPopupMenuItems: TdxRibbonPopupMenuItems;
begin
  Result := PopupMenuItems;
  if not IsQuickAccessToolbarValid then
    Result := Result - [rpmiQATPosition, rpmiQATAddRemoveItem];
end;

function TdxCustomRibbon.GetWindowBordersWidth: TRect;
begin
  Result := ColorScheme.GetWindowBordersWidth(HasStatusBar);
end;

function TdxCustomRibbon.HasStatusBar: Boolean;
begin
  Result := GetStatusBarInterface <> nil;
end;

procedure TdxCustomRibbon.RibbonFormCaptionChanged;
var
  AOnMDIForm: Boolean;
  AForm: TForm;
begin
  AOnMDIForm := IsOnRibbonMDIForm;
  LockedCancelHint := True;
  Inc(FLockCount);
  try
    if AOnMDIForm then
    begin
      AForm := RibbonForm.ActiveMDIChild;
      if (AForm <> nil) and IsZoomed(AForm.Handle) then
        DocumentName := AForm.Caption
      else
        DocumentName := '';
    end;
  finally
    Dec(FLockCount);
    LockedCancelHint := False;
    if RibbonForm <> nil then
    begin
      ViewInfo.Calculate(ClientBounds);
      UpdateNonClientArea;
      if AOnMDIForm then
        Application.Title := GetTaskbarCaption;
    end;
  end;
end;

procedure TdxCustomRibbon.RibbonFormResized;
begin
  CheckHide;
end;

procedure TdxCustomRibbon.UpdateNonClientArea;
begin
  if HandleAllocated and Visible then
  begin
    RedrawWindow(Handle, nil, 0, RDW_ERASE or RDW_INVALIDATE or RDW_UPDATENOW or RDW_ERASENOW);
    if ViewInfo.IsQATAtNonClientArea then
      RedrawWindow(QuickAccessToolbar.DockControl.Handle, nil, 0,
        RDW_ERASE or RDW_INVALIDATE or RDW_ALLCHILDREN or RDW_UPDATENOW or RDW_ERASENOW);
  end;
end;

procedure TdxCustomRibbon.DrawTabGroupBackground(DC: HDC; const ARect: TRect;
  AState: Integer);
var
  R: TRect;
begin
  R := ARect;
  Dec(R.Bottom, GetGroupCaptionHeight + dxRibbonGroupCaptionOffsets.Bottom);
  ColorScheme.DrawTabGroupBackground(DC, R, AState);
  ColorScheme.DrawTabGroupHeaderBackground(DC, Rect(R.Left, R.Bottom, R.Right, ARect.Bottom), AState);
end;

function TdxCustomRibbon.GetGroupCaptionHeight: Integer;
begin
  Result := GroupsPainter.GetGroupCaptionHeight(Fonts.GetGroupHeaderFont);
end;

function TdxCustomRibbon.GetGroupContentHeight: Integer;
begin
  Result := GetGroupRowHeight * dxRibbonGroupRowCount;
end;

function TdxCustomRibbon.GetGroupHeight: Integer;
begin
  Result := GetGroupContentHeight;
  with SkinGetContentOffsets(DXBAR_TOOLBAR) do
    Inc(Result, Top + Bottom);
end;

function TdxCustomRibbon.GetGroupRowHeight: Integer;
begin
  Result := GroupsPainter.GetGroupRowHeight(GroupsPainter.GetSmallIconSize, Fonts.GetGroupFont);
end;

procedure TdxCustomRibbon.SkinDrawBackground(DC: HDC; const ARect: TRect; APart, AState: Integer);
begin
  case APart of
    DXBAR_TOOLBAR: DrawTabGroupBackground(DC, ARect, AState);
    DXBAR_COLLAPSEDTOOLBAR:
      ColorScheme.DrawCollapsedToolbarBackground(DC, ARect, AState);
    DXBAR_MARKARROW: ColorScheme.DrawMarkArrow(DC, ARect, AState);
    DXBAR_MARKTRUNCATED: ColorScheme.DrawMarkTruncated(DC, ARect, AState);
    DXBAR_COLLAPSEDTOOLBARGLYPHBACKGROUND:
      ColorScheme.DrawCollapsedToolbarGlyphBackground(DC, ARect, AState);
    DXBAR_ARROWDOWN: ColorScheme.DrawArrowDown(DC, ARect, AState);
    DXBAR_APPLICATIONMENUBUTTON: ColorScheme.DrawApplicationMenuButton(DC, ARect, AState);
    DXBAR_APPLICATIONMENUBORDER:
      begin
        ColorScheme.DrawApplicationMenuBorder(DC, ARect);
        DrawApplicationMenuHeader(DC, False);
      end;
    DXBAR_APPLICATIONMENUCONTENTHEADER:
      begin
        ColorScheme.DrawApplicationMenuContentHeader(DC, ARect);
        DrawApplicationMenuHeader(DC, True);
      end;
    DXBAR_APPLICATIONMENUCONTENTFOOTER: ColorScheme.DrawApplicationMenuContentFooter(DC, ARect);
    DXBAR_DROPDOWNBORDER: ColorScheme.DrawDropDownBorder(DC, ARect);
    DXBAR_MENUARROWDOWN: ColorScheme.DrawMenuArrowDown(DC, ARect);
    DXBAR_MENUARROWRIGHT: ColorScheme.DrawMenuArrowRight(DC, ARect);
    DXBAR_MENUCHECK: ColorScheme.DrawMenuCheck(DC, ARect, AState);
    DXBAR_MENUCHECKMARK: ColorScheme.DrawMenuCheckMark(DC, ARect, AState);
    DXBAR_MENUCONTENT: ColorScheme.DrawMenuContent(DC, ARect);
    DXBAR_MENUDETACHCAPTION: ColorScheme.DrawMenuDetachCaption(DC, ARect, AState);
    DXBAR_MENUGLYPH: ColorScheme.DrawMenuGlyph(DC, ARect);
    DXBAR_MENUMARK: ColorScheme.DrawMenuMark(DC, ARect);
    DXBAR_MENUSEPARATORHORZ: ColorScheme.DrawMenuSeparatorHorz(DC, ARect);
    DXBAR_MENUSEPARATORVERT: ColorScheme.DrawMenuSeparatorVert(DC, ARect);
    DXBAR_MENUSCROLLAREA: ColorScheme.DrawMenuScrollArea(DC, ARect, AState);
    DXBAR_SCROLLARROW: ColorScheme.DrawScrollArrow(DC, ARect);
    DXBAR_EDIT_ARROWBUTTON: ColorScheme.DrawEditArrowButton(DC, ARect, AState);
    DXBAR_EDIT_BUTTON: ColorScheme.DrawEditButton(DC, ARect, AState);
    DXBAR_EDIT_ELLIPSISBUTTON: ColorScheme.DrawEditEllipsisButton(DC, ARect, AState);
    DXBAR_SPINEDIT_UPBUTTON: ColorScheme.DrawEditSpinUpButton(DC, ARect, AState);
    DXBAR_SPINEDIT_DOWNBUTTON: ColorScheme.DrawEditSpinDownButton(DC, ARect, AState);
    DXBAR_SMALLBUTTON: ColorScheme.DrawSmallButton(DC, ARect, AState);
    DXBAR_SMALLBUTTON_GLYPH: ColorScheme.DrawSmallButtonGlyphBackground(DC, ARect, AState);
    DXBAR_SMALLBUTTON_DROPBUTTON: ColorScheme.DrawSmallButtonDropButton(DC, ARect, AState);
    DXBAR_LARGEBUTTON: ColorScheme.DrawLargeButton(DC, ARect, AState);
    DXBAR_LARGEBUTTON_GLYPH: ColorScheme.DrawLargeButtonGlyphBackground(DC, ARect, AState);
    DXBAR_LARGEBUTTON_DROPBUTTON: ColorScheme.DrawLargeButtonDropButton(DC, ARect, AState);
    DXBAR_BUTTONGROUP: ColorScheme.DrawButtonGroup(DC, ARect, AState);
    DXBAR_BUTTONGROUPBORDERLEFT: ColorScheme.DrawButtonGroupBorderLeft(DC, ARect);
    DXBAR_BUTTONGROUPBORDERMIDDLE: ColorScheme.DrawButtonGroupBorderMiddle(DC, ARect, AState);
    DXBAR_BUTTONGROUPBORDERRIGHT: ColorScheme.DrawButtonGroupBorderRight(DC, ARect);
    DXBAR_BUTTONGROUPSPLITBUTTONSEPARATOR: ColorScheme.DrawButtonGroupSplitButtonSeparator(DC, ARect, AState);
    DXBAR_LAUNCHBUTTONDEFAULTGLYPH: ColorScheme.DrawLaunchButtonDefaultGlyph(DC, ARect, AState);
    DXBAR_LAUNCHBUTTONBACKGROUND: ColorScheme.DrawLaunchButtonBackground(DC, ARect, AState);
    DXBAR_PROGRESSSOLIDBAND: ColorScheme.DrawProgressSolidBand(DC, ARect);
    DXBAR_PROGRESSSUBSTRATE: ColorScheme.DrawProgressSubstrate(DC, ARect);
    DXBAR_PROGRESSDISCRETEBAND: ColorScheme.DrawProgressDiscreteBand(DC, ARect);
    DXBAR_QUICKACCESSGROUPBUTTON: ColorScheme.DrawQuickAccessToolbarGroupButton(DC, ARect,
      ViewInfo.IsQATAtBottom, ViewInfo.SupportNonClientDrawing, ViewInfo.IsFormCaptionActive, AState);
    DXBAR_SCREENTIP: ColorScheme.DrawScreenTip(DC, ARect);
    DXBAR_INRIBBONGALLERY: ColorScheme.DrawInRibbonGalleryBackground(DC, ARect, AState);
    DXBAR_DROPDOWNGALLERY: ColorScheme.DrawDropDownGalleryBackground(DC, ARect);
    DXBAR_INRIBBONGALLERYSCROLLBAR_LINEUPBUTTON:
      ColorScheme.DrawInRibbonGalleryScrollBarButton(DC, ARect, gsbkLineUp, AState);
    DXBAR_INRIBBONGALLERYSCROLLBAR_LINEDOWNBUTTON:
      ColorScheme.DrawInRibbonGalleryScrollBarButton(DC, ARect, gsbkLineDown, AState);
    DXBAR_INRIBBONGALLERYSCROLLBAR_DROPDOWNBUTTON:
      ColorScheme.DrawInRibbonGalleryScrollBarButton(DC, ARect, gsbkDropDown, AState);
    DXBAR_DROPDOWNGALLERY_TOPSIZINGBAND:
      ColorScheme.DrawDropDownGalleryTopSizingBand(DC, ARect);
    DXBAR_DROPDOWNGALLERY_BOTTOMSIZINGBAND:
      ColorScheme.DrawDropDownGalleryBottomSizingBand(DC, ARect);
    DXBAR_DROPDOWNGALLERY_TOPSIZEGRIP:
      ColorScheme.DrawDropDownGalleryTopSizeGrip(DC, ARect);
    DXBAR_DROPDOWNGALLERY_BOTTOMSIZEGRIP:
      ColorScheme.DrawDropDownGalleryBottomSizeGrip(DC, ARect);
    DXBAR_DROPDOWNGALLERY_TOPVERTICALSIZEGRIP:
      ColorScheme.DrawDropDownGalleryTopVerticalSizeGrip(DC, ARect);
    DXBAR_DROPDOWNGALLERY_BOTTOMVERTICALSIZEGRIP:
      ColorScheme.DrawDropDownGalleryBottomVerticalSizeGrip(DC, ARect);
    DXBAR_GALLERYGROUPHEADERBACKGROUND:
      ColorScheme.DrawGalleryGroupHeaderBackground(DC, ARect);
    DXBAR_GALLERYFILTERBAND:
      ColorScheme.DrawGalleryFilterBandBackground(DC, ARect);
  end;
end;

procedure TdxCustomRibbon.SkinDrawCaption(DC: HDC; const ACaption: string;
  const ARect: TRect; APart, AState: Integer);
var
  ACaptionRect: TRect;
  APrevFont: HFONT;
  APrevTextColor: TColor;
  AFont: TFont;
begin
  if APart = DXBAR_TOOLBAR then
  begin
    AFont := Fonts.GetGroupHeaderFont;
    SetBkMode(DC, TRANSPARENT);
    APrevFont := SelectObject(DC, AFont.Handle);
    APrevTextColor := GetTextColor(DC);
    SetTextColor(DC, ColorToRGB(AFont.Color));
    ACaptionRect := ARect;
    Inc(ACaptionRect.Top, dxRibbonGroupCaptionHeightCorrection);
    cxDrawText(DC, ACaption, ACaptionRect, DT_SINGLELINE or DT_CENTER or DT_VCENTER);
    SelectObject(DC, APrevFont);
    SetTextColor(DC, APrevTextColor);
    SetBkMode(DC, OPAQUE);
  end;
end;

function TdxCustomRibbon.SkinGetCaptionRect(const ARect: TRect; APart: Integer): TRect;
begin
  if APart = DXBAR_TOOLBAR then
  begin
    Result := ARect;
    with SkinGetContentOffsets(DXBAR_TOOLBAR) do
      ExtendRect(Result, Rect(Left, 0, Right, dxRibbonGroupCaptionOffsets.Bottom));
    Result.Top := Result.Bottom - GetGroupCaptionHeight;
  end
  else
    Result := cxEmptyRect;
end;

function TdxCustomRibbon.SkinGetContentOffsets(APart: Integer): TRect;
begin
  case APart of
    DXBAR_COLLAPSEDTOOLBAR:
      Result := Rect(2, 2, 2, 2);
    DXBAR_COLLAPSEDTOOLBARGLYPHBACKGROUND:
      Result := Rect(7, 4, 7, 11);
    DXBAR_GALLERYFILTERBAND:
      Result := ColorScheme.GetPartContentOffsets(APart);
    DXBAR_QUICKACCESSGROUPBUTTON, DXBAR_SMALLBUTTON:
      Result := Rect(3, 3, 3, 3);
    DXBAR_TOOLBAR:
      Result := Rect(2, 2, 3, dxRibbonGroupCaptionOffsets.Top + GetGroupCaptionHeight + dxRibbonGroupCaptionOffsets.Bottom);
  else
    Result := cxEmptyRect;
  end;
end;

function TdxCustomRibbon.SkinGetName: string;
begin
  Result := ColorScheme.GetSkinName;
end;

function TdxCustomRibbon.SkinGetPartColor(APart: Integer; AState: Integer = 0): TColor;
begin
  Result := ColorScheme.GetPartColor(APart, AState);
end;

function TdxCustomRibbon.SkinGetPartOffset(APart: Integer): Integer;
begin
  case APart of
    DXBAR_TOOLBAR:
      Result := 2;
    DXBAR_BUTTONGROUP:
      Result := 3;
  else
    Result := 0;
  end;
end;

procedure TdxCustomRibbon.FormKeyDown(var Key: Word; Shift: TShiftState);
begin
  if not IsDestroying and HandleAllocated then
  begin
    Controller.HideHint;
    if (Key = VK_F1) and (ssCtrl in Shift) and not IsPopupGroupsMode then
    begin
      ShowTabGroups := not ShowTabGroups;
      Key := 0;
    end;
  end;
end;

function TdxCustomRibbon.GetAccessibilityHelper: IdxBarAccessibilityHelper;
begin
  Result := IAccessibilityHelper;
end;

procedure TdxCustomRibbon.RibbonFormNonClientDrawAdd(AObject: TObject);
begin
  if FRibbonFormNonClientPainters.IndexOf(AObject) = -1 then
    FRibbonFormNonClientPainters.Add(AObject);
end;

procedure TdxCustomRibbon.RibbonFormNonClientDrawRemove(AObject: TObject);
begin
  FRibbonFormNonClientPainters.Remove(AObject);
end;

{$IFDEF DELPHI12}
procedure TdxCustomRibbon.AlignControls(AControl: TControl; var Rect: TRect);
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
      alTop: Result := C1.Margins.ControlTop < C2.Margins.ControlTop;
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
end;
{$ENDIF}

procedure TdxCustomRibbon.BoundsChanged;
begin
  inherited;
  Changed;
end;

function TdxCustomRibbon.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := inherited CanResize(NewWidth, NewHeight);
  NewHeight := ViewInfo.GetRibbonHeight;
end;

function TdxCustomRibbon.CanScrollTabs: Boolean;
begin
  Result := AreGroupsVisible and not IsPopupGroupsMode and
    not ((ActiveBarControl is TdxRibbonCollapsedGroupPopupBarControl) or
    HasPopupWindowAbove(ActiveBarControl, False)); 
end;

procedure TdxCustomRibbon.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do
    style := style and not(CS_HREDRAW or CS_VREDRAW);
end;

procedure TdxCustomRibbon.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited CreateWindowHandle(Params);
  if (FMouseHook = 0) and not IsDesigning and (IsWin2KOrXP or IsWinVista) then
    SetHook(FMouseHook, WH_MOUSE, dxRibbonMouseHook);
end;

procedure TdxCustomRibbon.DoCancelMode;
begin
  inherited DoCancelMode;
  Controller.CancelMode;
end;

procedure TdxCustomRibbon.InvalidateApplicationButton;
begin
  InvalidateRect(ViewInfo.ApplicationButtonImageBounds, False);
end;

procedure TdxCustomRibbon.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  inherited LookAndFeelChanged(Sender, AChangedValues);
  UpdateColorScheme;
end;

function TdxCustomRibbon.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelDown(Shift, MousePos);
  if not Result then
    Result := Controller.MouseWheelDown(Shift, MousePos);
end;

function TdxCustomRibbon.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheelUp(Shift, MousePos);
  if not Result then
    Result := Controller.MouseWheelUp(Shift, MousePos);
end;

procedure TdxCustomRibbon.FontChanged;
begin
  BeginUpdate;
  try
    inherited FontChanged;
    FFonts.UpdateFonts;
    if ActiveTab <> nil then
      ActiveTab.UpdateGroupsFont;
  finally
    EndUpdate;
  end;
end;

procedure TdxCustomRibbon.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to Tabs.Count - 1 do
    if Tabs[I].Owner = Root then Proc(Tabs[I]);
end;

function TdxCustomRibbon.GetDesignHitTest(X, Y: Integer; Shift: TShiftState): Boolean;
begin
  Result := inherited GetDesignHitTest(X, Y, Shift);
  if not Result then
  begin
    Result := GetTabAtPos(X, Y) <> nil;
  end;
end;

procedure TdxCustomRibbon.KeyDown(var Key: Word; Shift: TShiftState);
begin
  Controller.KeyDown(Key, Shift);
  inherited;
end;

procedure TdxCustomRibbon.KeyPress(var Key: Char);
begin
  Controller.KeyPress(Key);
  inherited;
end;

procedure TdxCustomRibbon.KeyUp(var Key: Word; Shift: TShiftState);
begin
  Controller.KeyUp(Key, Shift);
  inherited;
end;

procedure TdxCustomRibbon.Loaded;
begin
  BeginUpdate;
  try
    Tabs.UpdateBarManager(BarManager);
    inherited Loaded;
    if ActiveTab <> nil then
      ActiveTab.CheckGroupToolbarsDockControl;
  finally
    EndUpdate;
  end;
end;

function TdxCustomRibbon.MayFocus: Boolean;
begin
  Result := False;
end;

procedure TdxCustomRibbon.Modified;
begin
  if not FLockModified then
    inherited;
end;

procedure TdxCustomRibbon.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  Controller.MouseDown(Button, Shift, X, Y);
end;

procedure TdxCustomRibbon.MouseLeave(AControl: TControl);
begin
  inherited MouseLeave(AControl);
  Controller.MouseLeave;
end;

procedure TdxCustomRibbon.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  Controller.MouseMove(Shift, X, Y);
end;

procedure TdxCustomRibbon.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  Controller.MouseUp(Button, Shift, X, Y);
end;

procedure TdxCustomRibbon.Paint;
var
  AControl: TWinControl;
  P: TPoint;
  R: TRect;
begin
  if SupportNonClientDrawing and (FormCaptionHelper <> nil) then
  begin
    if ViewInfo.UseGlass then
    begin
      R := ClientRect;
      R.Bottom := R.Top + FCalculatedFormCaptionHeight;
      Canvas.FillRect(R, clBlack);
    end;
    FormCaptionHelper.UpdateCaptionArea;
  end;
  ViewInfo.Paint(Canvas);
  if IsDesigning and (csPaintCopy in ControlState) and HandleAllocated then
  begin
    if ViewInfo.IsQATVisible then
    begin
      Canvas.SaveDC;
      AControl := QuickAccessToolbar.Toolbar.Control;
      P := cxNullPoint;
      MapWindowPoint(AControl.Handle, Handle, P);
      AControl.PaintTo(Canvas.Canvas.Handle, P.X, P.Y);
      Canvas.RestoreDC;
    end;
  end;
end;

function TdxCustomRibbon.NeedsScrollBars: Boolean;
begin
  Result := False;
end;

procedure TdxCustomRibbon.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = BarManager then
      BarManager := nil;
    if not IsDestroying then
    begin
      if AComponent = HelpButtonScreenTip then
        HelpButtonScreenTip := nil;
      if AComponent = BarManager then
        QuickAccessToolbar.Toolbar := nil;
      if AComponent = ApplicationButton.Menu then
        ApplicationButton.Menu := nil;
      if AComponent = ApplicationButton.ScreenTip then
        ApplicationButton.ScreenTip := nil;
      if AComponent = QuickAccessToolbar.Toolbar then
        QuickAccessToolbar.Toolbar := nil;
    end;
  end;
end;

procedure TdxCustomRibbon.ReadState(Reader: TReader);
begin
  if not FTabsLoaded then
  begin
    Tabs.Clear;
    FTabsLoaded := True;
  end;
  inherited ReadState(Reader);
  FLoadedHeight := Height;
end;

procedure TdxCustomRibbon.SetName(const Value: TComponentName);
begin
  inherited SetName(Value);
  if not FTabsLoaded and IsDesigning and (Tabs.Count > 0) then
  begin
    Tabs.SetItemName(Tabs[0]);
    Tabs[0].Caption := Tabs[0].Name;
  end;
end;

procedure TdxCustomRibbon.SetParent(AParent: TWinControl);
begin
  if Assigned(AParent) then
  begin
    AParent := GetParentForm(AParent{$IFDEF DELPHI9}, not (csDesigning in ComponentState){$ENDIF});
    if Assigned(AParent) and not (AParent is TCustomForm) then
      raise EdxException.CreateFmt(cxGetResourceString(@dxSBAR_RIBBONBADPARENT), [ClassName]);
  end;
  inherited SetParent(AParent);
  Top := 0;
  if FSupportNonClientDrawing and not IsLoading and (AParent <> nil) then
    UpdateNonClientDrawing(True);
end;

procedure TdxCustomRibbon.CalculateFormCaptionHeight;
var
  H: Integer;
begin
  if not SupportNonClientDrawing or (RibbonForm = nil) then Exit;
  //text part
  if ViewInfo.UseGlass then
    H := GetDefaultWindowNCSize(RibbonForm.Handle).Top
  else
    H := Max(GetSystemMetrics(SM_CYCAPTION) - 1, GetSystemMetrics(SM_CYSIZE)) + 6;
  H := Max(Abs(Fonts.GetFormCaptionFont(True).Height) * 2, H);
  H := Max(Abs(Fonts.GetFormCaptionFont(False).Height) * 2, H);
  //quick access toolbar
  if ViewInfo.IsQATAtNonClientArea and IsBarManagerValid then
    H := Max(GetGroupRowHeight + 9, H);
  FCalculatedFormCaptionHeight := H;
end;

procedure TdxCustomRibbon.CheckDrawRibbonFormStatusBarBorders(ACanvas: TcxCanvas;
  const AData: TdxRibbonFormData; const ABordersWidth: TRect);
var
  ATop, ABottom: Integer;
  ALeftStatusBarBounds, ARightStatusBarBounds: TRect;
  AIntf: IdxRibbonFormStatusBarDraw;
  AIsRectangular: Boolean;
begin
  if AData.State <> wsNormal then Exit;
  AIntf := GetStatusBarInterface;
  if AIntf <> nil then
  begin
    with AData.Bounds do
    begin
      ATop := Bottom - AIntf.GetHeight - 1;
      ABottom := Bottom;
      AIsRectangular := IsRectangularFormBottom(AData);
      if not AIsRectangular then Dec(ABottom);
      ALeftStatusBarBounds := cxRect(0, ATop, ABordersWidth.Left, ABottom);
      ColorScheme.DrawFormStatusBarPart(ACanvas.Handle,
       ALeftStatusBarBounds, True, AData.Active, AIntf.GetIsRaised(True), AIsRectangular);
      ACanvas.ExcludeClipRect(ALeftStatusBarBounds);
      ARightStatusBarBounds := cxRect(Right - ABordersWidth.Right, ATop, Right, ABottom);
      ColorScheme.DrawFormStatusBarPart(ACanvas.Handle,
       ARightStatusBarBounds, False, AData.Active, AIntf.GetIsRaised(False), AIsRectangular);
      ACanvas.ExcludeClipRect(ARightStatusBarBounds);
    end;
  end;
end;

procedure TdxCustomRibbon.DrawApplicationMenuHeader(ADC: THandle; AIsClientArea: Boolean);

  function GetImageBounds: TRect;
  var
    AWindowRect, AMenuWindowRect: TRect;
    ASubMenuControl: TdxBarSubMenuControl;
    ADestinationOrigin: TPoint;
  begin
    AWindowRect := cxGetWindowRect(Self);
    ASubMenuControl := ApplicationButton.Menu.SubMenuControl;
    AMenuWindowRect := cxGetWindowRect(ASubMenuControl);
    if AIsClientArea then
      ADestinationOrigin := ASubMenuControl.ClientOrigin
    else
      ADestinationOrigin := AMenuWindowRect.TopLeft;

    Result := cxRectOffset(ViewInfo.ApplicationButtonImageBounds,
      AWindowRect.Left - ADestinationOrigin.X,
      AWindowRect.Top + (Height - ClientHeight) - ADestinationOrigin.Y);
  end;

begin
  BarCanvas.BeginPaint(ADC);
  try
    Painter.DrawApplicationButton(BarCanvas, GetImageBounds, absPressed);
  finally
    BarCanvas.EndPaint;
  end;
end;

function TdxCustomRibbon.GetApplicationButtonIAccessibilityHelper: IdxBarAccessibilityHelper;
begin
  Result := ApplicationButton.IAccessibilityHelper;
end;

function TdxCustomRibbon.AddGroupButtonToQAT(ABar: TdxBar): TdxRibbonQuickAccessGroupButton;
var
  AItemLinks: TdxBarItemLinks;
begin
  Result := nil;
  if ABar = nil then
    Exit;
  AItemLinks := QuickAccessToolbar.Toolbar.ItemLinks;
  Result := TdxRibbonQuickAccessGroupButton(AItemLinks.AddItem(TdxRibbonQuickAccessGroupButton).Item);
  if Result.IsToolbarAcceptable(ABar) then
  begin
    Result.Toolbar := ABar;
    Result.Name := 'QAT' + Result.Toolbar.Name;
  end
  else
  begin
    AItemLinks.Delete(AItemLinks.Count - 1);
    Result := nil;
  end;
end;

procedure TdxCustomRibbon.CancelUpdate;
begin
  Dec(FLockCount);
  if (FLockCount = 0) and not IsDestroying then
    GroupsDockControlSite.SetRedraw(True);
end;

function TdxCustomRibbon.CanFade: Boolean;
begin
  Result := Fading and not (IsLocked or IsDesigning) and Fader.IsReady;
end;

function TdxCustomRibbon.CanPaint: Boolean;
begin
  Result := ComponentState * [csLoading, csReading, csDestroying] = [];
end;

function TdxCustomRibbon.CreateApplicationButton: TdxRibbonApplicationButton;
begin
  Result := TdxRibbonApplicationButton.Create(Self);
end;

function TdxCustomRibbon.CreateController: TdxRibbonController;
begin
  Result := TdxRibbonController.Create(Self);
end;

function TdxCustomRibbon.CreateFormCaptionHelper: TdxRibbonFormCaptionHelper;
begin
  Result := TdxRibbonFormCaptionHelper.Create(Self);
end;

function TdxCustomRibbon.CreatePainter: TdxRibbonPainter;
begin
  Result := TdxRibbonPainter.Create(Self);
end;

function TdxCustomRibbon.CreateQuickAccessToolbar: TdxRibbonQuickAccessToolbar;
begin
  Result := TdxRibbonQuickAccessToolbar.Create(Self);
end;

function TdxCustomRibbon.CreateGroupsPainter: TdxRibbonBarPainter;
begin
  Result := TdxRibbonBarPainter.Create(Integer(Self));
end;

function TdxCustomRibbon.CreateViewInfo: TdxRibbonViewInfo;
begin
  Result := TdxRibbonViewInfo.Create(Self);
end;

procedure TdxCustomRibbon.DesignAddTabGroup(ATab: TdxRibbonTab; ANewToolbar: Boolean);
var
  AGroup: TdxRibbonTabGroup;
begin
  if ATab = nil then
    ATab := ActiveTab;
  if (ATab = nil) or not IsDesigning then Exit;
  if ANewToolbar then
  begin
    BarManager.BeginUpdate;
    try
      AGroup := ATab.Groups.Add;
      AGroup.ToolBar := BarManager.AddToolBar;
      BarDesignController.SelectItem(AGroup.ToolBar);
    finally
      BarManager.EndUpdate;
    end;
  end
  else
    ATab.Groups.Add.DesignSelectionHelper.SelectComponent;
end;

function TdxCustomRibbon.DoApplicationMenuClick: Boolean;
begin
  Result := False;
  if Assigned(FOnApplicationMenuClick) then
    FOnApplicationMenuClick(Self, Result);
end;

procedure TdxCustomRibbon.DoHelpButtonClick;
begin
  if Assigned(FOnHelpButtonClick) then
    FOnHelpButtonClick(Self);
end;

function TdxCustomRibbon.DoHideMinimizedByClick(AWnd: THandle;
  AShift: TShiftState; const APos: TPoint): Boolean;
begin
  Result := True;
  if Assigned(FOnHideMinimizedByClick) then
    FOnHideMinimizedByClick(Self, AWnd, AShift, APos, Result);
end;

function TdxCustomRibbon.DoTabChanging(ANewTab: TdxRibbonTab): Boolean;
begin
  Result := True;
  if Assigned(FOnTabChanging) then
    FOnTabChanging(Self, ANewTab, Result);
end;

procedure TdxCustomRibbon.DoTabChanged;
begin
  if Assigned(FOnTabChanged) then
    FOnTabChanged(Self);
end;

procedure TdxCustomRibbon.DoTabGroupCollapsed(ATab: TdxRibbonTab;
  AGroup: TdxRibbonTabGroup);
begin
  if Assigned(FOnTabGroupCollapsed) then
    FOnTabGroupCollapsed(Self, ATab, AGroup);
end;

procedure TdxCustomRibbon.DoTabGroupExpanded(ATab: TdxRibbonTab;
  AGroup: TdxRibbonTabGroup);
begin
  if Assigned(FOnTabGroupExpanded) then
    FOnTabGroupExpanded(Self, ATab, AGroup);
end;

procedure TdxCustomRibbon.DoMoreCommandsExecute;
begin
  if Assigned(FOnMoreCommandsExecute) then
    FOnMoreCommandsExecute(Self)
  else
    BarManager.Customizing(True);
end;

function TdxCustomRibbon.GetVisibleTab(Index: Integer): TdxRibbonTab;
var
  I, J: Integer;
begin
  Result := nil;
  J := 0;
  for I := 0 to FTabs.Count - 1 do
    if Tabs[I].Visible then
    begin
      if J = Index then
      begin
        Result := Tabs[I];
        break;
      end;
      Inc(J);
    end;
end;

function TdxCustomRibbon.GetVisibleTabCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FTabs.Count - 1 do
    if Tabs[I].Visible then Inc(Result);
end;

procedure TdxCustomRibbon.InitCustomizePopupMenu(AItemLinks: TdxBarItemLinks);
var
  AItems: TdxRibbonPopupMenuItems;
begin
  AItems := GetValidPopupMenuItems - [rpmiItems, rpmiQATAddRemoveItem];
  PopulatePopupMenuItems(AItemLinks, AItems, PopupMenuItemClick);
end;

procedure TdxCustomRibbon.IniFileProceduresAdd;
begin
  FBarManager.ReadIniFileHandlers.Add(BarManagerLoadIni);
  FBarManager.WriteIniFileHandlers.Add(BarManagerSaveIni);
end;

procedure TdxCustomRibbon.IniFileProceduresRemove;
begin
  if BarManager <> nil then
  begin
    FBarManager.ReadIniFileHandlers.Remove(BarManagerLoadIni);
    FBarManager.WriteIniFileHandlers.Remove(BarManagerSaveIni);
  end;
end;

function TdxCustomRibbon.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonAccessibilityHelper;
end;

function TdxCustomRibbon.GetBar(ACustomizingBarControl: TCustomdxBarControl): TdxBar;
var
  ABarControlAccess: TdxBarControlAccess;
begin
  ABarControlAccess := TdxBarControlAccess(ACustomizingBarControl);
  if ABarControlAccess.IsPopup then
    Result := ABarControlAccess.PopupBar
  else
    Result := ABarControlAccess.Bar;
end;

function TdxCustomRibbon.GetTabClass: TdxRibbonTabClass;
begin
  Result := TdxRibbonTab;
end;

function TdxCustomRibbon.IsBarManagerValid: Boolean;
begin
  Result := (BarManager <> nil) and not (csDestroying in BarManager.ComponentState);
end;

function TdxCustomRibbon.IsLocked: Boolean;
begin
  Result := (FLockCount > 0) or not HandleAllocated or
    not CanAllocateHandle(Self) or //todo: check condition
    ([csDestroying, csLoading] * ComponentState <> []);
end;

function TdxCustomRibbon.IsQuickAccessToolbarValid: Boolean;
begin
  Result := QuickAccessToolbar.Visible and (QuickAccessToolbar.Toolbar <> nil);
end;

procedure TdxCustomRibbon.Hide;
begin
  if Hidden then Exit;
  FHidden := True;
  Changed;
  RibbonFormInvalidate;
end;

procedure TdxCustomRibbon.PopulatePopupMenuItems(ALinks: TdxBarItemLinks;
  AItems: TdxRibbonPopupMenuItems; AOnClick: TNotifyEvent);

  function GetQATPositionButtonCaption: string;
  begin
    if QuickAccessToolbar.Position = qtpAboveRibbon then
      Result := cxGetResourceString(@dxSBAR_SHOWBELOWRIBBON)
    else
      Result := cxGetResourceString(@dxSBAR_SHOWABOVERIBBON);
  end;

  function AddMenuItem(const ACaption: string; ANeedSeparator: Boolean;
    AItem: TdxRibbonPopupMenuItem; AData: TObject = nil): TdxBarButton;
  begin
    Result := TdxBarButton.Create(BarManager);
    BarDesignController.AddInternalItem(Result, FInternalItems);
    Result.Caption := ACaption;
    Result.OnClick := AOnClick;
    Result.Tag := Ord(AItem);
    Result.Data := AData;
    ALinks.Add(Result).BeginGroup := ANeedSeparator;
  end;

  procedure AddQATItem;

    function GetEnabled: Boolean;
    var
      ABar: TdxBar;
      I: Integer;
    begin
      if BarDesignController.CustomizingItemLink = nil then
      begin
        ABar := GetBar(BarDesignController.CustomizingBarControl);
        Result := not QuickAccessToolbar.HasGroupButtonForToolbar(ABar);
      end
      else
      begin
        Result := IsQuickAccessToolbarValid;
        if Result then
        begin
          ABar := QuickAccessToolbar.Toolbar;
          for I := 0 to ABar.ItemLinks.Count - 1 do
            if ABar.ItemLinks[I].Item = BarDesignController.CustomizingItemLink.Item then
            begin
              Result := False;
              Break;
            end;
        end;
      end;
    end;

    function GetAddMessage: string;
    begin
      if (BarDesignController.CustomizingItemLink = nil) or
        (BarDesignController.CustomizingItemLink.Item.GetAddMessageName = '') then
        Result := cxGetResourceString(@dxSBAR_ADDTOQAT)
      else
        Result := Format(cxGetResourceString(@dxSBAR_ADDTOQATITEMNAME),
          [BarDesignController.CustomizingItemLink.Item.GetAddMessageName]);
    end;

  begin
    if QuickAccessToolbar.Contains(BarDesignController.CustomizingItemLink) then
      AddMenuItem(cxGetResourceString(@dxSBAR_REMOVEFROMQAT), False, rpmiQATAddRemoveItem)
    else
      AddMenuItem(GetAddMessage, False, rpmiQATAddRemoveItem, BarDesignController.CustomizingBarControl).Enabled := GetEnabled;
  end;

var
  ANeedSeparator: Boolean;
  AButton: TdxBarButton;
begin
  FInternalItems.Clear;
  if not (rpmiItems in AItems) then
    ALinks.Clear;
  if rpmiQATAddRemoveItem in AItems then
    AddQATItem;
  ANeedSeparator := ALinks.Count > 0;
  if rpmiMoreCommands in AItems then
  begin
    AddMenuItem(cxGetResourceString(@dxSBAR_MORECOMMANDS), ANeedSeparator, rpmiMoreCommands);
    ANeedSeparator := False;
  end;
  if rpmiQATPosition in AItems then
    AddMenuItem(GetQATPositionButtonCaption, ANeedSeparator, rpmiQATPosition);
  if rpmiMinimizeRibbon in AItems then
  begin
    AButton := AddMenuItem(cxGetResourceString(@dxSBAR_MINIMIZERIBBON), True, rpmiMinimizeRibbon);
    if not ShowTabGroups then
    begin
      AButton.ButtonStyle := bsChecked;
      AButton.Down := True;
    end;
    AButton.Enabled := ViewInfo.TabsViewInfo.Count > 0;
  end;
end;

procedure TdxCustomRibbon.PopupMenuItemClick(Sender: TObject);

  procedure AddItemToQAT;
  var
    ACustomizingLink: TdxBarItemLink;
  begin
    ACustomizingLink := BarDesignController.CustomizingItemLink;
    if ACustomizingLink <> nil then
      QuickAccessToolbar.Toolbar.ItemLinks.Add.Item := ACustomizingLink.Item
    else
      AddGroupButtonToQAT(GetBar(TCustomdxBarControl(TdxBarItem(Sender).Data)));
  end;

  procedure RemoveItemFromQAT;
  var
    ACustomizingLink: TdxBarItemLink;
  begin
    ACustomizingLink := BarDesignController.CustomizingItemLink;
    if ACustomizingLink.Item is TdxRibbonQuickAccessGroupButton then
      BarDesignController.DeleteCustomizingItem
    else
    begin
      if ACustomizingLink.OriginalItemLink <> nil then
        ACustomizingLink.OriginalItemLink.Free
      else
        BarDesignController.DeleteCustomizingItemLink;
    end;
  end;

begin
  case TdxRibbonPopupMenuItem(TdxBarButton(Sender).Tag) of
    rpmiQATAddRemoveItem:
      if QuickAccessToolbar.Contains(BarDesignController.CustomizingItemLink) then
        RemoveItemFromQAT
      else
        AddItemToQAT;
    rpmiMoreCommands:
      DoMoreCommandsExecute;
    rpmiQATPosition:
      with QuickAccessToolbar do
      begin
        if Position = qtpAboveRibbon then
          Position := qtpBelowRibbon
        else
          Position := qtpAboveRibbon;
      end;
    rpmiMinimizeRibbon:
      ShowTabGroups := not ShowTabGroups;
  end;
end;

procedure TdxCustomRibbon.RemoveFadingObject(AObject: TObject);
var
  AFader: TdxFader;
begin
  AFader := Fader;
  if AFader <> nil then
    AFader.Remove(AObject);
end;

procedure TdxCustomRibbon.SetRedraw(ARedraw: Boolean);
begin
  if not (HandleAllocated and Visible) then Exit;
  if not ARedraw then
    SendMessage(Handle, WM_SETREDRAW, 0, 0)
  else
  begin
    SendMessage(Handle, WM_SETREDRAW, 1, 0);
    FullInvalidate;
  end;
end;

procedure TdxCustomRibbon.ShowCustomizePopup;
begin
  if not IsBarManagerValid then Exit;
  BarDesignController.ShowCustomCustomizePopup(BarManager, InitCustomizePopupMenu, GroupsPainter);
end;

procedure TdxCustomRibbon.UpdateControlsVisibility;
begin
  QuickAccessToolbar.DockControl.Visible := not Hidden and
    QuickAccessToolbar.Visible and (QuickAccessToolbar.Toolbar <> nil);
  if ActiveTab <> nil then
    ActiveTab.DockControl.Visible := not Hidden;
  Changed;
  RibbonFormInvalidate;
end;

procedure TdxCustomRibbon.UpdateHeight;
begin
  if IsLoading then Exit;
  if Hidden and not IsDesigning then
    Height := ViewInfo.GetNonClientAreaHeight
  else
    Height := ViewInfo.GetRibbonHeight;
end;

procedure TdxCustomRibbon.UpdateHiddenActiveTabDockControl;
begin
  if Hidden and (ActiveTab <> nil) then
    ActiveTab.UpdateDockControl;
end;

procedure TdxCustomRibbon.UpdateFormActionControl(ASetControl: Boolean);
var
  ARibbonForm: TdxCustomRibbonForm;
begin
  ARibbonForm := GetRibbonForm;
  if ARibbonForm <> nil then
  begin
    if ASetControl then
    begin
      if (ARibbonForm.FormStyle = fsMDIForm) and Assigned(ARibbonForm.ActiveMDIChild) then
        ARibbonForm.PrevActiveControl := ARibbonForm.ActiveMDIChild.ActiveControl
      else
        ARibbonForm.PrevActiveControl := ARibbonForm.ActiveControl
    end
    else
      ARibbonForm.PrevActiveControl := nil;
  end;
end;

function TdxCustomRibbon.GetColorSchemeName: string;
begin
  Result := FColorScheme.Name;
end;

function TdxCustomRibbon.GetFader: TdxFader;
begin
  Result := dxFader;
end;

function TdxCustomRibbon.GetFadingHelper(
  AIndex: Integer): TdxRibbonElementCustomFadingHelper;
begin
  Result := TdxRibbonElementCustomFadingHelper(FFadingHelperList.Items[AIndex]);
end;

function TdxCustomRibbon.GetFadingHelpersCount: Integer;
begin
  Result := FFadingHelperList.Count;
end;

function TdxCustomRibbon.GetIAccessibilityHelper: IdxBarAccessibilityHelper;
begin
  if FIAccessibilityHelper = nil then
    FIAccessibilityHelper := dxBar.GetAccessibilityHelper(GetAccessibilityHelperClass.Create(Self));
  Result := FIAccessibilityHelper;
end;

function TdxCustomRibbon.GetIniSection(const ADelimiter: string;
  const ASection: string): string;
var
  AOwner: TComponent;
begin
  Result := Name;
  AOwner := Owner;
  while (AOwner <> nil) and (AOwner.Name <> '') do
  begin
    Result := AOwner.Name + '_' + Result;
    AOwner := AOwner.Owner;
  end;

  Result := ASection + Result;
end;

function TdxCustomRibbon.GetIsPopupGroupsMode: Boolean;
begin
  Result := (FTabGroupsPopupWindow <> nil) and FTabGroupsPopupWindow.IsVisible;
end;

function TdxCustomRibbon.GetNextActiveTab(ATab: TdxRibbonTab): TdxRibbonTab;

  function GetIndex(ATab: TdxRibbonTab): Integer;
  begin
    if ATab = nil then
      Result := 0
    else
      if not (csDestroying in ATab.ComponentState) then
        Result := ATab.Index
      else
        Result := ATab.LastIndex;
  end;

var
  I, AIndex: Integer;
begin
  Result := nil;
  AIndex := GetIndex(ATab);
  for I := AIndex to Tabs.Count - 1 do
    if Tabs[I].Visible then
    begin
      Result := Tabs[I];
      Break;
    end;
  if Result = nil then
    for I := AIndex - 1 downto 0 do
      if Tabs[I].Visible then
      begin
        Result := Tabs[I];
        Break;
      end;
end;

function TdxCustomRibbon.GetQATIAccessibilityHelper: IdxBarAccessibilityHelper;
begin
  if (QuickAccessToolbar.Toolbar <> nil) and (QuickAccessToolbar.Toolbar.Control <> nil) then
    Result := QuickAccessToolbar.Toolbar.Control.IAccessibilityHelper
  else
    Result := nil;
end;

function TdxCustomRibbon.GetRibbonForm: TdxCustomRibbonForm;
begin
  if (Owner is TdxCustomRibbonForm) and not (csDestroying in Owner.ComponentState) then
    Result := TdxCustomRibbonForm(Owner)
  else
    Result := nil;
end;

function TdxCustomRibbon.GetStatusBarInterface: IdxRibbonFormStatusBarDraw;
var
  I: Integer;
  AForm: TCustomForm;
begin
  Result := nil;
  if SupportNonClientDrawing and not ViewInfo.UseGlass then
  begin
    AForm := RibbonForm;
    if (AForm <> nil) and AForm.HandleAllocated and (AForm.WindowState = wsNormal) then
      for I := 0 to FRibbonFormNonClientPainters.Count - 1 do
        if Supports(TObject(FRibbonFormNonClientPainters[I]), IdxRibbonFormStatusBarDraw, Result) and Result.GetActive(AForm) then
          Break
        else
          Result := nil;
  end;
end;

function TdxCustomRibbon.GetTabCount: Integer;
begin
  Result := FTabs.Count;
end;

function TdxCustomRibbon.GetTabsIAccessibilityHelper: IdxBarAccessibilityHelper;
begin
  Result := Tabs.IAccessibilityHelper;
end;

procedure TdxCustomRibbon.InitColorScheme;
var
  I: Integer;
begin
  for I := 0 to SkinManager.SkinCount - 1 do
    if SkinManager[I] is TdxCustomRibbonSkin then
    begin
      ColorSchemeName := SkinManager[I].Name;
      break;
    end;
end;

function TdxCustomRibbon.IsOnRibbonMDIForm: Boolean;
var
  AForm: TForm;
begin
  AForm := RibbonForm;
  Result := (AForm <> nil) and (AForm.FormStyle = fsMDIForm);
end;

procedure TdxCustomRibbon.RibbonFormInvalidate;
begin
  if SupportNonClientDrawing then
    WinControlFullInvalidate(RibbonForm);
end;

procedure TdxCustomRibbon.SetActiveTab(Value: TdxRibbonTab);
begin
  if (FActiveTab <> Value) and not (csDestroying in ComponentState) then
  begin
    if not IsDesigning then
    begin
      if IsBarManagerValid then
        BarManager.HideAll;
      Fader.Remove(FActiveTab);
      Fader.Remove(Value);
      if not DoTabChanging(Value) then Exit;
    end;
    CloseTabGroupsPopupWindow;
    if FActiveTab <> nil then
      FActiveTab.Deactivate;
    FActiveTab := Value;
    GroupsDockControlSite.SetRedraw(False);
    try
      if FActiveTab <> nil then
        FActiveTab.Activate;
      Changed;
      DoTabChanged;
    finally
      Changed;
      GroupsDockControlSite.SetRedraw(True);
    end;
    Modified;
  end;
end;

procedure TdxCustomRibbon.SetApplicationButton(const Value: TdxRibbonApplicationButton);
begin
  FApplicationButton.Assign(Value);
end;

procedure TdxCustomRibbon.SetApplicationButtonState(const Value: TdxApplicationButtonState);
begin
  if FApplicationButtonState <> Value then
  begin
    FApplicationButtonState := Value;
    InvalidateApplicationButton;
  end;
end;

procedure TdxCustomRibbon.SetBarManager(Value: TdxBarManager);
var
  ALockedBarManager: TdxBarManager;
begin
  if FBarManager <> Value then
  begin
    ALockedBarManager := nil;
    if IsBarManagerValid then
    begin
      FBarManager.MDIStateChangedHandlers.Remove(MDIStateChanged);
      FBarManager.SystemFontChangedHandlers.Remove(SystemFontChanged);
      FBarManager.RemoveFreeNotification(Self);
      if Value = nil then
        ALockedBarManager := FBarManager;
      IniFileProceduresRemove;
    end;
    FBarManager := Value;
    if IsBarManagerValid then
    begin
      FBarManager.MDIStateChangedHandlers.Add(MDIStateChanged);
      FBarManager.SystemFontChangedHandlers.Add(SystemFontChanged);
      FBarManager.FreeNotification(Self);
      Fonts.UpdateFonts;
      IniFileProceduresAdd;
    end;
    if Assigned(ALockedBarManager) then ALockedBarManager.BeginUpdate;
    try
      Tabs.UpdateBarManager(Value);
      QuickAccessToolbar.DockControl.BarManager := Value;
    finally
      if Assigned(ALockedBarManager) then ALockedBarManager.EndUpdate;
    end;
    Changed;
  end;
end;

procedure TdxCustomRibbon.SetColorScheme(const Value: TdxCustomRibbonSkin);
begin
  if (FColorScheme <> Value) and (Value <> nil) then
  begin
    FColorScheme := Value;
    UpdateColorScheme;
    Modified;
  end;
end;

procedure TdxCustomRibbon.SetColorSchemeName(const Value: string);
var
  ASkin: TdxCustomBarSkin;
begin
  ASkin := SkinManager.SkinByName(Value);
  if ASkin is TdxCustomRibbonSkin then
    ColorScheme := TdxCustomRibbonSkin(ASkin);
end;

procedure TdxCustomRibbon.SetDocumentName(const Value: TCaption);
{$IFDEF DELPHI11}
var
  AForm: TCustomForm;
{$ENDIF}
begin
  if FDocumentName <> Value then
  begin
    FDocumentName := Value;
  {$IFDEF DELPHI11}
    AForm := RibbonForm;
    if (AForm <> nil) and (Application.MainForm = AForm) and (AForm.HandleAllocated) then
      SetWindowTextWithoutRedraw(AForm.Handle, ViewInfo.GetFormCaptionText);
  {$ENDIF}
    Changed;
  end;
end;

procedure TdxCustomRibbon.SetFading(const Value: Boolean);
begin
  if FFading <> Value then
  begin
    FFading := Value;
    if not Value then
      Fader.Clear;
    Invalidate;
  end;
end;

procedure TdxCustomRibbon.SetFonts(const Value: TdxRibbonFonts);
begin
  FFonts.Assign(Value);
end;

procedure TdxCustomRibbon.SetHelpButtonScreenTip(const Value: TdxBarScreenTip);
begin
  if FHelpButtonScreenTip <> Value then
  begin
    if FHelpButtonScreenTip <> nil then
      FHelpButtonScreenTip.RemoveFreeNotification(Self);
    FHelpButtonScreenTip := Value;
    if FHelpButtonScreenTip <> nil then
      FHelpButtonScreenTip.FreeNotification(Self);
  end;
end;

procedure TdxCustomRibbon.SetHighlightedTab(const Value: TdxRibbonTab);
begin
  if FHighlightedTab <> Value then
  begin
    if CanFade then
      Fader.FadeOut(FHighlightedTab);
    FHighlightedTab := Value;
    if CanFade then
      Fader.FadeIn(FHighlightedTab)
    else
      InvalidateRect(ViewInfo.GetTabsBounds, False);
  end;
end;

procedure TdxCustomRibbon.SetPopupMenuItems(const Value: TdxRibbonPopupMenuItems);
begin
  if Value <> FPopupMenuItems then
  begin
    FPopupMenuItems := Value;
    Changed;
  end;
end;

procedure TdxCustomRibbon.SetQuickAccessToolbar(const Value: TdxRibbonQuickAccessToolbar);
begin
  FQuickAccessToolbar.Assign(Value);
end;

procedure TdxCustomRibbon.SetShowTabGroups(const Value: Boolean);
begin
  if FShowTabGroups <> Value then
  begin
    FShowTabGroups := Value;
    CloseTabGroupsPopupWindow;
    if not Value and (ActiveTab <> nil) then
      ActiveTab.DockControl.Visible := False;
    Changed;
  end;
end;

procedure TdxCustomRibbon.SetShowTabHeaders(const Value: Boolean);
begin
  if FShowTabHeaders <> Value then
  begin
    FShowTabHeaders := Value;
    CloseTabGroupsPopupWindow;
    Changed;
    InvalidateWithChildren;
  end;
end;

procedure TdxCustomRibbon.SetSupportNonClientDrawing(const Value: Boolean);
begin
  if FSupportNonClientDrawing <> Value then
  begin
    FSupportNonClientDrawing := Value;
    CloseTabGroupsPopupWindow;
    if Value then
      FFormCaptionHelper := CreateFormCaptionHelper
    else
      FreeAndNil(FFormCaptionHelper);
    UpdateNonClientDrawing(Value);
  end;
end;

procedure TdxCustomRibbon.SetTabs(Value: TdxRibbonTabCollection);
begin
  FTabs.Assign(Value);
end;

procedure TdxCustomRibbon.UpdateColorSchemeListeners;
begin
  FColorSchemeHandlers.CallEvents(Self, []);
end;

procedure TdxCustomRibbon.UpdateNonClientDrawing(const Value: Boolean);
var
  AForm: TdxCustomRibbonForm;
begin
  AForm := RibbonForm;
  if AForm <> nil then
  begin
    AForm.RibbonNonClientHelper := FFormCaptionHelper;
    if IsCompositionEnabled and not IsDestroying and //ViewInfo.UseGlass?
      AForm.HandleAllocated and IsZoomed(AForm.Handle) then
    begin
      RecreateWnd;
      if Assigned(FFormCaptionHelper) then
        FFormCaptionHelper.Resize;
    end;
    UpdateControlsVisibility;
  end;
end;

procedure TdxCustomRibbon.WMGetObject(var Message: TMessage);
begin
//  if CanReturnAccessibleObject(Message) then
//    Message.Result := WMGetObjectResultFromIAccessibilityHelper(Message, IAccessibilityHelper)
//  else
    inherited;
end;

procedure TdxCustomRibbon.WMPaint(var Message: TWMPaint);
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
begin
  if not CanPaint then Exit;
  if not FDoubleBuffered or (Message.DC <> 0) then
  begin
    if not (csCustomPaint in ControlState) and (ControlCount = 0) then
      inherited
    else
      PaintHandler(Message);
  end
  else
  begin
    DC := BeginPaint(Handle, PS);
    MemBitmap := CreateCompatibleBitmap(DC, PS.rcPaint.Right - PS.rcPaint.Left,
      PS.rcPaint.Bottom - PS.rcPaint.Top);
    MemDC := CreateCompatibleDC(DC);
    try
      OldBitmap := SelectObject(MemDC, MemBitmap);
      try
        SetWindowOrgEx(MemDC, PS.rcPaint.Left, PS.rcPaint.Top, nil);
        Perform(WM_ERASEBKGND, MemDC, MemDC);
        Message.DC := MemDC;
        WMPaint(Message);
        Message.DC := 0;
        BitBlt(DC, PS.rcPaint.Left, PS.rcPaint.Top,
          PS.rcPaint.Right - PS.rcPaint.Left,         
          PS.rcPaint.Bottom - PS.rcPaint.Top,
          MemDC,
          PS.rcPaint.Left, PS.rcPaint.Top,
          SRCCOPY);
      finally
        SelectObject(MemDC, OldBitmap);
      end;
    finally
      EndPaint(Handle, PS);
      DeleteDC(MemDC);
      DeleteObject(MemBitmap);
    end;
  end;
end;

procedure TdxCustomRibbon.CMSelectAppMenuFirstItemControl(
  var Message: TMessage);
begin
  if Controller.IsApplicationMenuDropped then
    SelectFirstSelectableAccessibleObject(
      ApplicationButton.Menu.ItemLinks.BarControl.IAccessibilityHelper.GetBarHelper);
end;

procedure TdxCustomRibbon.CMShowKeyTips(var Message: TMessage);
begin
  if Controller.IsApplicationMenuDropped then
    BarNavigationController.SetKeyTipsShowingState(
      ApplicationButton.Menu.ItemLinks.BarControl.IAccessibilityHelper, '');
end;

procedure TdxCustomRibbon.ApplicationMenuPopupNotification(Sender: TObject);
begin
  TCustomdxBarControlAccess(ApplicationButton.Menu.SubMenuControl).FPainter := GroupsPainter;
  if Assigned(FPrevOnApplicationMenuPopup) then
    FPrevOnApplicationMenuPopup(Sender);
end;

procedure TdxCustomRibbon.BarManagerLoadIni(Sender: TObject; const AEventArgs);

  procedure LoadQATGroupButtons(AEventData: TdxBarIniFileEventData);
  var
    I, LinkCount: Integer;
    ABarSection, AItemSection: string;
    AQATBar, ABar: TdxBar;
    AGroupButton: TdxRibbonQuickAccessGroupButton;
  begin
    AQATBar := QuickAccessToolbar.Toolbar;
    if AQATBar <> nil then
    begin
      ABarSection := TdxBarAccess(AQATBar).GetIniSection(
        AEventData.BaseSection, AQATBar.Index);
      LinkCount := AEventData.IniFile.ReadInteger(ABarSection, 'ItemLinkCount', 0);
      for I := 0 to LinkCount - 1 do
      begin
        AItemSection := TdxBarItemLinkAccess.GetIniSection(
            ABarSection, I, AEventData.StoringKind);
        ABar := BarManager.BarByComponentName(
          AEventData.IniFile.ReadString(AItemSection, 'ToolbarName', ''));
        if ABar <> nil then
        begin
          AGroupButton := AddGroupButtonToQAT(ABar);
          if (AGroupButton <> nil) and (I <> LinkCount - 1) then
            AQATBar.ItemLinks.Move(AQATBar.ItemLinks.Count - 1, I);
        end;
      end;
    end;
  end;

var
  ASection: string;
  AEventData: TdxBarIniFileEventData;
begin
  AEventData := TdxBarIniFileEventData(AEventArgs);
  ASection := GetIniSection(AEventData.Delimiter, AEventData.BaseSection);
  if AEventData.IniFile.SectionExists(ASection) then
  begin
    QuickAccessToolbar.Position := TdxQuickAccessToolbarPosition(
      AEventData.IniFile.ReadInteger(ASection, 'QuickAccessToolbarPosition', 0));
    ShowTabGroups := AEventData.IniFile.ReadBool(ASection, 'ShowTabGroups', True);
  end;
  LoadQATGroupButtons(AEventData);
end;

procedure TdxCustomRibbon.BarManagerSaveIni(Sender: TObject; const AEventArgs);

  procedure SaveQATGroupButtons(AEventData: TdxBarIniFileEventData);
  var
    I: Integer;
    AItemLinks: TdxBarItemLinks;
    ASection: string;
  begin
    if QuickAccessToolbar.Toolbar = nil then
      Exit;
    AItemLinks := QuickAccessToolbar.Toolbar.ItemLinks;
    for I := 0 to AItemLinks.Count - 1 do
      if AItemLinks[I].Item is TdxRibbonQuickAccessGroupButton then
      begin
        ASection := TdxBarAccess(QuickAccessToolbar.Toolbar).GetIniSection(
          AEventData.BaseSection, QuickAccessToolbar.Toolbar.Index);
        ASection := TdxBarItemLinkAccess(AItemLinks[I]).GetIniSection(
          ASection, I, AEventData.StoringKind);
        AEventData.IniFile.WriteString(ASection, 'ToolbarName',
          TdxRibbonQuickAccessGroupButton(AItemLinks[I].Item).Toolbar.Name);
      end;
  end;

var
  ASection: string;
  AEventData: TdxBarIniFileEventData;
begin
  AEventData := TdxBarIniFileEventData(AEventArgs);
  ASection := GetIniSection(AEventData.Delimiter, AEventData.BaseSection);
  AEventData.IniFile.WriteInteger(ASection, 'QuickAccessToolbarPosition', Ord(QuickAccessToolbar.Position));
  AEventData.IniFile.WriteBool(ASection, 'ShowTabGroups', ShowTabGroups);
  SaveQATGroupButtons(AEventData);
end;

procedure TdxCustomRibbon.MDIStateChanged(Sender: TObject; const AEventArgs);
var
  AEventData: TdxBarMDIStateChangeEventData;
  ABuffer: array[0..1023] of Char;
begin
  if not IsDesigning and IsOnRibbonMDIForm then
  begin
    AEventData := TdxBarMDIStateChangeEventData(AEventArgs);
    if AEventData.Change in [scMaximizedChanged, scChildActivated] then
    begin
      if IsZoomed(AEventData.Wnd) then
      begin
        GetWindowText(AEventData.Wnd, PChar(@ABuffer), 1023);
        DocumentName := PChar(@ABuffer);
      end
      else
        DocumentName := '';
      Application.Title := GetTaskbarCaption;
    end;
  end;
end;

procedure TdxCustomRibbon.SystemFontChanged(Sender: TObject; const AEventArgs);
begin
  FontChanged;
end;

procedure TdxCustomRibbon.UpdateColorScheme;
var
  AForm: TCustomForm;
  AValid: Boolean;
begin
  AForm := GetParentForm(Self{$IFDEF DELPHI8}, False{$ENDIF});
  AValid := Assigned(AForm) and AForm.HandleAllocated and IsWindowVisible(AForm.Handle);
  if AValid then
    SendMessage(AForm.Handle, WM_SETREDRAW, 0, 0);
  try
    Fonts.UpdateFonts;
    RecalculateBars;
    Changed;
  finally
    UpdateColorSchemeListeners;
    if AValid then
    begin
      SendMessage(AForm.Handle, WM_SETREDRAW, 1, 0);
      UpdateRibbonForm(AForm);
      WinControlFullInvalidate(AForm, True, True);
    end;
  end;
end;

procedure TdxCustomRibbon.UpdateRibbonForm(AForm: TCustomForm);
begin
  if SupportNonClientDrawing and AForm.HandleAllocated then 
    SetWindowPos(AForm.Handle, 0, 0, 0, 0, 0,
      SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_FRAMECHANGED);
end;

{ TdxRibbonQuickAccessGroupButton }

function TdxRibbonQuickAccessGroupButton.IsToolbarAcceptable(
  AToolbar: TdxBar): Boolean;
begin
  Result := TdxBarManagerAccess(BarManager).IsInitializing or (AToolbar = nil) or (LinkCount = 0) or
    IsToolbarDockedInRibbon(TdxRibbonQuickAccessDockControl(TdxBar(Links[0].Owner.Owner).RealDockControl).Ribbon, AToolbar) and
    not HasGroupButtonForToolbar(TdxBar(Links[0].Owner.Owner), AToolbar);
end;

function TdxRibbonQuickAccessGroupButton.CanBePlacedOn(
  AParentKind: TdxBarItemControlParentKind; AToolbar: TdxBar;
  out AErrorText: string): Boolean;
begin
  Result := TdxBarManagerAccess(BarManager).IsInitializing;
  if Result then
    Exit;
  if (AParentKind <> pkBar) or
    not GetBarControlClass(AToolbar).InheritsFrom(TdxRibbonQuickAccessBarControl) then
  begin
    AErrorText := cxGetResourceString(@dxSBAR_CANTPLACEQUICKACCESSGROUPBUTTON);
    Exit;
  end;
  if (Toolbar <> nil) and not ((Toolbar.DockControl is TdxRibbonGroupsDockControl) and
    (TdxRibbonGroupsDockControl(Toolbar.DockControl).BarManager = BarManager)) then
  begin
    AErrorText := cxGetResourceString(@dxSBAR_QUICKACCESSGROUPBUTTONTOOLBARNOTDOCKEDINRIBBON);
    Exit;
  end;
  if HasGroupButtonForToolbar(AToolbar, Toolbar) then
  begin
    AErrorText := cxGetResourceString(@dxSBAR_QUICKACCESSALREADYHASGROUPBUTTON);
    Exit;
  end;
  Result := True;
end;

procedure TdxRibbonQuickAccessGroupButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = Toolbar) then
    Toolbar := nil;
end;

function TdxRibbonQuickAccessGroupButton.GetCaption: string;
begin
  if Toolbar = nil then
    Result := 'GroupButton'
  else
    Result := Toolbar.Caption;
end;

function TdxRibbonQuickAccessGroupButton.IsCaptionStored: Boolean;
begin
  Result := False;
end;

procedure TdxRibbonQuickAccessGroupButton.SetCaption(const Value: string);
begin
end;

function TdxRibbonQuickAccessGroupButton.HasGroupButtonForToolbar(
  AParentBar, AToolbar: TdxBar): Boolean;
var
  AParentBarItemLinks: TdxBarItemLinks;
  I: Integer;
begin
  Result := False;
  if AToolbar <> nil then
  begin
    if AParentBar.Control <> nil then
      AParentBarItemLinks := AParentBar.Control.ItemLinks
    else
      AParentBarItemLinks := AParentBar.ItemLinks;
    for I := 0 to AParentBarItemLinks.Count - 1 do
      if not TdxBarItemLinkAccess(AParentBarItemLinks[I]).IsMarkedForDeletion and
        (AParentBarItemLinks[I].Item is TdxRibbonQuickAccessGroupButton) and
        (TdxRibbonQuickAccessGroupButton(AParentBarItemLinks[I].Item).Toolbar = AToolbar) then
      begin
        Result := True;
        Break;
      end;
  end;
end;

function TdxRibbonQuickAccessGroupButton.IsToolbarDockedInRibbon(
  ARibbon: TdxCustomRibbon; AToolbar: TdxBar): Boolean;
begin
  Result := (AToolbar.DockControl is TdxRibbonGroupsDockControl) and
    (TdxRibbonGroupsDockControl(AToolbar.DockControl).Ribbon = ARibbon);
end;

procedure TdxRibbonQuickAccessGroupButton.SetToolbar(Value: TdxBar);
begin
  if not IsToolbarAcceptable(Value) then
    Exit;
  if Value <> FToolbar then
  begin
    if FToolbar <> nil then
      FToolbar.RemoveFreeNotification(Self);
    FToolbar := Value;
    if FToolbar <> nil then
      FToolbar.FreeNotification(Self);
    ToolbarChanged;
  end;
end;

procedure TdxRibbonQuickAccessGroupButton.ToolbarChanged;
begin
  Update;
end;

{ TdxRibbonQuickAccessGroupButtonPopupBarControl }

constructor TdxRibbonQuickAccessGroupButtonPopupBarControl.CreateForPopup(
  AGroupButtonControl: TdxRibbonQuickAccessGroupButtonControl);
begin
  inherited CreateForPopup(TdxBarControl(AGroupButtonControl.Parent),
    TdxRibbonQuickAccessGroupButton(AGroupButtonControl.Item).Toolbar);
  FGroupButtonControl := AGroupButtonControl;
end;

procedure TdxRibbonQuickAccessGroupButtonPopupBarControl.CloseUp;
begin
  FGroupButtonControl.ClosePopup;
end;

function TdxRibbonQuickAccessGroupButtonPopupBarControl.CanActiveChange: Boolean;
begin
  Result := not FIsActiveChangeLocked and inherited CanActiveChange;
end;

procedure TdxRibbonQuickAccessGroupButtonPopupBarControl.CreateWnd;
begin
  inherited CreateWnd;
  IsActive := True;
end;

procedure TdxRibbonQuickAccessGroupButtonPopupBarControl.DestroyWnd;
begin
  if FGroupButtonControl.MousePressed then
    TdxRibbonQuickAccessBarControl(FGroupButtonControl.Parent).IgnoreMouseClick := True;
  inherited DestroyWnd;
end;

procedure TdxRibbonQuickAccessGroupButtonPopupBarControl.FocusItemControl(
  AItemControl: TdxBarItemControl);
begin
  if AItemControl <> nil then
  begin
    FIsActiveChangeLocked := True;
    try
      inherited FocusItemControl(AItemControl);
    finally
      FIsActiveChangeLocked := False;
    end;
  end;
end;

function TdxRibbonQuickAccessGroupButtonPopupBarControl.GetBehaviorOptions: TdxBarBehaviorOptions;
begin
  Result := inherited GetBehaviorOptions + [bboNeedsFocusWhenActive];
end;

procedure TdxRibbonQuickAccessGroupButtonPopupBarControl.HideAllByEscape;
var
  AGroupButtonControlToSelect: TdxRibbonQuickAccessGroupButtonControl;
begin
  if BarNavigationController.NavigationMode then
    AGroupButtonControlToSelect := FGroupButtonControl
  else
    AGroupButtonControlToSelect := nil;
  inherited HideAllByEscape;
  if AGroupButtonControlToSelect <> nil then
    AGroupButtonControlToSelect.IAccessibilityHelper.Select(False);
end;

{ TdxRibbonQuickAccessGroupButtonControl }

destructor TdxRibbonQuickAccessGroupButtonControl.Destroy;
begin
  ClosePopup;
  inherited Destroy;
end;

function TdxRibbonQuickAccessGroupButtonControl.IsDroppedDown: Boolean;
begin
  Result := FPopupBarControl <> nil;
end;

procedure TdxRibbonQuickAccessGroupButtonControl.CalcDrawParams(AFull: Boolean = True);
begin
  inherited CalcDrawParams(AFull);
  DrawParams.DroppedDown := IsDroppedDown;
  DrawParams.Enabled := DrawParams.Enabled and (Item.IsDesigning or (Item.Toolbar <> nil));
end;

function TdxRibbonQuickAccessGroupButtonControl.CanActivate: Boolean;
begin
  Result := not BarManager.Designing and inherited CanActivate;
end;

procedure TdxRibbonQuickAccessGroupButtonControl.ControlClick(AByMouse: Boolean;
  AKey: Char = #0);
begin
  inherited ControlClick(AByMouse, AKey);
  if TdxRibbonQuickAccessBarControl(Parent).IsDowned then
    ControlActivate(True);
end;

procedure TdxRibbonQuickAccessGroupButtonControl.DoCloseUp(
  AHadSubMenuControl: Boolean);
begin
  ClosePopup;
  Repaint;
end;

procedure TdxRibbonQuickAccessGroupButtonControl.DoDropDown(AByMouse: Boolean);
var
  AToolbar: TdxBar;
  R: TRect;
begin
  AToolbar := Item.Toolbar;
  if AToolbar <> nil then
  begin
    FPopupBarControl := TdxRibbonQuickAccessGroupButtonPopupBarControl.CreateForPopup(Self);
    R := ItemLink.ItemRect;
    R.TopLeft := Parent.ClientToScreen(R.TopLeft);
    R.BottomRight := Parent.ClientToScreen(R.BottomRight);
    FPopupBarControl.Popup(R);
    if BarNavigationController.NavigationMode and not BarNavigationController.KeyTipsHandlingMode then
      SelectFirstSelectableAccessibleObject(FPopupBarControl.IAccessibilityHelper.GetBarHelper);
    Repaint;
  end;
end;

procedure TdxRibbonQuickAccessGroupButtonControl.DoPaint(ARect: TRect;
  PaintType: TdxBarPaintType);
begin
  TdxRibbonQuickAccessPainter(Painter).DrawGroupButtonControl(DrawParams, ARect);
end;

procedure TdxRibbonQuickAccessGroupButtonControl.DropDown(AByMouse: Boolean);
begin
  inherited DropDown(AByMouse);
  Click(AByMouse);
end;

function TdxRibbonQuickAccessGroupButtonControl.GetAccessibilityHelperClass: TdxBarAccessibilityHelperClass;
begin
  Result := TdxRibbonQuickAccessGroupButtonControlAccessibilityHelper;
end;

function TdxRibbonQuickAccessGroupButtonControl.GetCurrentImage(
  AViewSize: TdxBarItemControlViewSize; ASelected: Boolean;
  out ACurrentGlyph: TBitmap; out ACurrentImages: TCustomImageList;
  out ACurrentImageIndex: Integer): Boolean;
begin
  if Item.Toolbar <> nil then
    ACurrentGlyph := Item.Toolbar.Glyph
  else
    ACurrentGlyph := nil;
  if (ACurrentGlyph <> nil) and ACurrentGlyph.Empty then
    ACurrentGlyph := nil;
  ACurrentImages := nil;
  Result := ACurrentGlyph <> nil;
end;

function TdxRibbonQuickAccessGroupButtonControl.GetHint: string;
begin
  Result := ItemLink.Caption;
end;

function TdxRibbonQuickAccessGroupButtonControl.GetViewStructure: TdxBarItemControlViewStructure;
begin
  Result := [cpIcon];
end;

function TdxRibbonQuickAccessGroupButtonControl.IsDestroyOnClick: Boolean;
begin
  Result := False;
end;

function TdxRibbonQuickAccessGroupButtonControl.IsDropDown: Boolean;
begin
  Result := True;
end;

procedure TdxRibbonQuickAccessGroupButtonControl.ClosePopup;
begin
  FreeAndNil(FPopupBarControl);
end;

function TdxRibbonQuickAccessGroupButtonControl.GetItem: TdxRibbonQuickAccessGroupButton;
begin
  Result := TdxRibbonQuickAccessGroupButton(inherited Item);
end;

{ TdxAddGroupButtonEditor }

class function TdxAddGroupButtonEditor.GetAddedItemClass(
  const AAddedItemName: string): TdxBarItemClass;
begin
  Result := TdxRibbonQuickAccessGroupButton;
end;

class function TdxAddGroupButtonEditor.GetPopupItemCaption: string;
begin
  Result := dxSBAR_CP_ADDGROUPBUTTON;
end;

{ TdxRibbonAccessibilityHelper }

// IdxBarAccessibilityHelper
function TdxRibbonAccessibilityHelper.AreKeyTipsSupported(
  out AKeyTipWindowsManager: IdxBarKeyTipWindowsManager): Boolean;
begin
  Result := True;
  if FKeyTipWindowsManager = nil then
    FKeyTipWindowsManager := TdxRibbonKeyTipWindows.Create(Ribbon);
  AKeyTipWindowsManager := FKeyTipWindowsManager;
end;

function TdxRibbonAccessibilityHelper.GetBarManager: TdxBarManager;
begin
  Result := Ribbon.BarManager;
end;

function TdxRibbonAccessibilityHelper.GetDefaultAccessibleObject: IdxBarAccessibilityHelper;
begin
  Result := nil;
  if Ribbon.AreGroupsVisible then
    Result := Ribbon.TabsIAccessibilityHelper.GetDefaultAccessibleObject;
  if (Result = nil) and Ribbon.ApplicationButtonIAccessibilityHelper.GetHelper.Visible then
    Result := Ribbon.ApplicationButtonIAccessibilityHelper;
end;

function TdxRibbonAccessibilityHelper.GetChild(
  AIndex: Integer): TcxAccessibilityHelper;
begin
  Result := nil;
  case AIndex of
    0: Result := Ribbon.ApplicationButtonIAccessibilityHelper.GetHelper;
    1: Result := Ribbon.TabsIAccessibilityHelper.GetHelper;
    2: Result := Ribbon.QATIAccessibilityHelper.GetHelper;
  end;
end;

function TdxRibbonAccessibilityHelper.GetChildCount: Integer;
begin
  Result := 2;
  if Ribbon.QATIAccessibilityHelper <> nil then
    Inc(Result);
end;

function TdxRibbonAccessibilityHelper.GetChildIndex(
  AChild: TcxAccessibilityHelper): Integer;
begin
  Result := -1;
  if AChild = Ribbon.ApplicationButtonIAccessibilityHelper.GetHelper then
    Result := 0
  else
    if AChild = Ribbon.TabsIAccessibilityHelper.GetHelper then
      Result := 1
    else
      if (Ribbon.QATIAccessibilityHelper.GetHelper <> nil) and (AChild = Ribbon.QATIAccessibilityHelper.GetHelper) then
        Result := 2;
end;

function TdxRibbonAccessibilityHelper.GetOwnerObjectWindow: HWND;
begin
  if Ribbon.HandleAllocated then
    Result := Ribbon.Handle
  else
    Result := 0;
end;

function TdxRibbonAccessibilityHelper.GetScreenBounds(
  AChildID: TcxAccessibleSimpleChildElementID): TRect;
begin
  if Visible then
    Result := cxGetWindowRect(GetOwnerObjectWindow)
  else
    Result := cxEmptyRect;
end;

function TdxRibbonAccessibilityHelper.GetState(
  AChildID: TcxAccessibleSimpleChildElementID): Integer;
var
  AHandle: HWND;
begin
  Result := cxSTATE_SYSTEM_NORMAL;
  AHandle := GetOwnerObjectWindow;
  if (AHandle = 0) or not IsWindowVisible(AHandle) then
    Result := Result or cxSTATE_SYSTEM_INVISIBLE;
end;

//function TdxRibbonAccessibilityHelper.ChildIsSimpleElement(
//  AIndex: Integer): Boolean;
//begin
//  Result := False;
//end;
//
//function TdxRibbonAccessibilityHelper.GetChildIndex(
//  AChild: TcxAccessibilityHelper): Integer;
//begin
//  Result := 0;
//end;
//
//function TdxRibbonAccessibilityHelper.GetName(
//  AChildID: TcxAccessibleSimpleChildElementID): string;
//begin
//  Result := cxGetResourceString(@dxSBAR_ACCESSIBILITY_RIBBONNAME);
//end;
//
//function TdxRibbonAccessibilityHelper.GetRole(
//  AChildID: TcxAccessibleSimpleChildElementID): Integer;
//begin
//  Result := cxROLE_SYSTEM_WINDOW;
//end;
//
//function TdxRibbonAccessibilityHelper.GetSupportedProperties(
//  AChildID: TcxAccessibleSimpleChildElementID): TcxAccessibleObjectProperties;
//begin
//  Result := [aopLocation];
//end;

function TdxRibbonAccessibilityHelper.LogicalNavigationGetChild(
  AIndex: Integer): TdxBarAccessibilityHelper;
begin
  Result := nil;
  case AIndex of
    0: Result := Ribbon.TabsIAccessibilityHelper.GetBarHelper;
    1: Result := Ribbon.ApplicationButtonIAccessibilityHelper.GetBarHelper;
    2: Result := Ribbon.QATIAccessibilityHelper.GetBarHelper;
  end;
end;

function TdxRibbonAccessibilityHelper.LogicalNavigationGetChildIndex(
  AChild: TdxBarAccessibilityHelper): Integer;
begin
  Result := 0;
  if AChild = Ribbon.TabsIAccessibilityHelper.GetBarHelper then
    Exit;
  Inc(Result);

  if AChild = Ribbon.ApplicationButtonIAccessibilityHelper.GetBarHelper then
    Exit;
  Inc(Result);

  if (Ribbon.QATIAccessibilityHelper.GetBarHelper <> nil) and (AChild = Ribbon.QATIAccessibilityHelper.GetBarHelper) then
    Exit;

  Result := -1;
end;

function TdxRibbonAccessibilityHelper.GetRibbon: TdxCustomRibbon;
begin
  Result := TdxCustomRibbon(FOwnerObject);
end;

{ TdxRibbonTabCollectionAccessibilityHelper }

// IdxBarAccessibilityHelper
function TdxRibbonTabCollectionAccessibilityHelper.GetBarManager: TdxBarManager;
begin
  Result := TabCollection.Owner.BarManager;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetDefaultAccessibleObject: IdxBarAccessibilityHelper;
begin
  if TabCollection.Owner.ActiveTab <> nil then
    Result := TabCollection.Owner.ActiveTab.IAccessibilityHelper
  else
    Result := nil;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetChild(
  AIndex: Integer): TcxAccessibilityHelper;
begin
  Result := TabCollection[AIndex].IAccessibilityHelper.GetHelper;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetChildCount: Integer;
begin
  Result := TabCollection.Count;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetChildIndex(
  AChild: TcxAccessibilityHelper): Integer;
begin
  if (AChild is TdxRibbonTabAccessibilityHelper) and (TdxRibbonTabAccessibilityHelper(AChild).Parent = Self) then
    Result := TdxRibbonTabAccessibilityHelper(AChild).Tab.Index
  else
    Result := -1;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetOwnerObjectWindow: HWND;
begin
  Result := Parent.OwnerObjectWindow;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetParent: TcxAccessibilityHelper;
begin
  Result := TabCollection.Owner.IAccessibilityHelper.GetHelper;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetScreenBounds(
  AChildID: TcxAccessibleSimpleChildElementID): TRect;
begin
  if Visible then
  begin
    Result := TabCollection.Owner.ViewInfo.TabsViewInfo.Bounds;
    with TabCollection.Owner do
    begin
      Result.TopLeft := ClientToScreen(Result.TopLeft);
      Result.BottomRight := ClientToScreen(Result.BottomRight);
    end;
  end
  else
    Result := cxEmptyRect;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetState(
  AChildID: TcxAccessibleSimpleChildElementID): Integer;
begin
  Result := Parent.States[cxAccessibleObjectSelfID];
  if not TabCollection.Owner.ViewInfo.IsTabsVisible then
    Result := Result or cxSTATE_SYSTEM_INVISIBLE;
end;

//function TdxRibbonTabCollectionAccessibilityHelper.ChildIsSimpleElement(
//  AIndex: Integer): Boolean;
//begin
//  Result := False;
//end;
//
//function TdxRibbonTabCollectionAccessibilityHelper.GetChildIndex(
//  AChild: TcxAccessibilityHelper): Integer;
//var
//  I: Integer;
//begin
//  Result := -1;
//  for I := 0 to TabCollection.Count - 1 do
//    if GetChild(I) = AChild then
//    begin
//      Result := I;
//      Break;
//    end;
//end;
//
//function TdxRibbonTabCollectionAccessibilityHelper.GetName(
//  AChildID: TcxAccessibleSimpleChildElementID): string;
//begin
//  Result := cxGetResourceString(@dxSBAR_ACCESSIBILITY_RIBBONTABCOLLECTIONNAME);
//end;
//
//function TdxRibbonTabCollectionAccessibilityHelper.GetRole(
//  AChildID: TcxAccessibleSimpleChildElementID): Integer;
//begin
//  Result := cxROLE_SYSTEM_PAGETABLIST;
//end;
//
//function TdxRibbonTabCollectionAccessibilityHelper.GetSupportedProperties(
//  AChildID: TcxAccessibleSimpleChildElementID): TcxAccessibleObjectProperties;
//begin
//  Result := [aopLocation];
//end;

function TdxRibbonTabCollectionAccessibilityHelper.LogicalNavigationGetChild(
  AIndex: Integer): TdxBarAccessibilityHelper;
begin
  if TabCollection.Owner.AreGroupsVisible then
    Result := TabCollection.Owner.ActiveTab.IAccessibilityHelper.GetBarHelper
  else
    Result := GetFirstSelectableObject;
end;

function TdxRibbonTabCollectionAccessibilityHelper.LogicalNavigationGetChildCount: Integer;
var
  AAreGroupsVisible: Boolean;
begin
  AAreGroupsVisible := TabCollection.Owner.AreGroupsVisible;
  if AAreGroupsVisible and (TabCollection.Owner.ActiveTab <> nil) or
    not AAreGroupsVisible and (GetFirstSelectableObject <> nil) then
      Result := 1
  else
    Result := 0;
end;

function TdxRibbonTabCollectionAccessibilityHelper.LogicalNavigationGetChildIndex(
  AChild: TdxBarAccessibilityHelper): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to LogicalNavigationGetChildCount - 1 do
    if AChild = LogicalNavigationGetChild(I) then
    begin
      Result := I;
      Break;
    end;
end;

function TdxRibbonTabCollectionAccessibilityHelper.GetTabCollection: TdxRibbonTabCollection;
begin
  Result := TdxRibbonTabCollection(FOwnerObject);
end;

{ TdxRibbonTabAccessibilityHelper }

procedure TdxRibbonTabAccessibilityHelper.CloseUpHandler(
  AClosedByEscape: Boolean);
begin
  if AClosedByEscape and BarNavigationController.NavigationMode then
    Select(False);
end;

// IdxBarAccessibilityHelper
function TdxRibbonTabAccessibilityHelper.GetBarManager: TdxBarManager;
begin
  Result := Tab.Ribbon.BarManager;
end;

function TdxRibbonTabAccessibilityHelper.GetNextAccessibleObject(
  ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper;
var
  ADockControlObject, ATabCollectionObject: TdxBarAccessibilityHelper;
  AStep, I: Integer;
begin
  Result := nil;
  case ADirection of
    andLeft, andRight:
      begin
        ATabCollectionObject := Parent;
        if ADirection = andLeft then
        begin
          I := ATabCollectionObject.ChildCount - 1;
          AStep := -1;
        end
        else
        begin
          I := 0;
          AStep := 1;
        end;
        while ATabCollectionObject.Childs[I] <> Self do
          Inc(I, AStep);
        I := ATabCollectionObject.GetNextSelectableChildIndex(I, ADirection = andRight);
        if I <> -1 then
          Result := ATabCollectionObject.Childs[I]
        else
          if Tab.Ribbon.ApplicationButtonIAccessibilityHelper.GetHelper.Selectable then
            Result := Tab.Ribbon.ApplicationButtonIAccessibilityHelper;
      end;
    andUp:
      if Tab.Ribbon.QATIAccessibilityHelper = nil then
        Result := Self;
    andDown:
      begin
        ADockControlObject := Tab.DockControl.IAccessibilityHelper.GetBarHelper;
        if ADockControlObject.Visible then
          Result := ADockControlObject.GetFirstSelectableObject;
      end;
  end;
  if Result = nil then
    Result := inherited GetNextAccessibleObject(ADirection);
end;

function TdxRibbonTabAccessibilityHelper.HandleNavigationKey(
  var AKey: Word): Boolean;
begin
  Result := inherited HandleNavigationKey(AKey);
  if not Result and not Tab.Ribbon.AreGroupsVisible then
  begin
    Result := AKey in [VK_RETURN, VK_SPACE];
    if Result then
    begin
      Tab.Active := True;
      Tab.Ribbon.ShowTabGroupsPopupWindow;
      SelectFirstSelectableAccessibleObject(Tab.DockControl.IAccessibilityHelper.GetBarHelper);
    end;
  end;
end;

function TdxRibbonTabAccessibilityHelper.IsNavigationKey(AKey: Word): Boolean;
begin
  Result := inherited IsNavigationKey(AKey) or (AKey = VK_ESCAPE);
  if not Tab.Ribbon.AreGroupsVisible then
    Result := Result or (AKey in [VK_RETURN, VK_SPACE]);
end;

function TdxRibbonTabAccessibilityHelper.LogicalNavigationGetNextAccessibleObject(
  AGoForward: Boolean): IdxBarAccessibilityHelper;
begin
  if AGoForward then
    Result := LogicalNavigationGetNextChild(-1, True)
  else
    Result := inherited LogicalNavigationGetNextAccessibleObject(AGoForward);
end;

procedure TdxRibbonTabAccessibilityHelper.Select(ASetFocus: Boolean);
begin
  inherited Select(ASetFocus);
  if Tab.Ribbon.AreGroupsVisible then
    Tab.Active := True;
  Tab.Invalidate;
end;

procedure TdxRibbonTabAccessibilityHelper.Unselect(
  ANextSelectedObject: IdxBarAccessibilityHelper);
begin
  inherited Unselect(ANextSelectedObject);
  Tab.Invalidate;
end;

function TdxRibbonTabAccessibilityHelper.GetChild(
  AIndex: Integer): TcxAccessibilityHelper;
begin
  Result := Tab.DockControl.IAccessibilityHelper.GetHelper;
end;

function TdxRibbonTabAccessibilityHelper.GetChildCount: Integer;
begin
  Result := 1;
end;

function TdxRibbonTabAccessibilityHelper.GetChildIndex(
  AChild: TcxAccessibilityHelper): Integer;
begin
  if AChild = Tab.DockControl.IAccessibilityHelper.GetHelper then
    Result := 0
  else
    Result := -1;
end;

function TdxRibbonTabAccessibilityHelper.GetOwnerObjectWindow: HWND;
begin
  Result := Parent.OwnerObjectWindow;
end;

function TdxRibbonTabAccessibilityHelper.GetParent: TcxAccessibilityHelper;
begin
  Result := TdxRibbonTabCollection(Tab.Collection).IAccessibilityHelper.GetHelper;
end;

function TdxRibbonTabAccessibilityHelper.GetScreenBounds(
  AChildID: TcxAccessibleSimpleChildElementID): TRect;
begin
  if Visible then
  begin
    Result := Tab.ViewInfo.Bounds;
    Result.TopLeft := Tab.Ribbon.ClientToScreen(Result.TopLeft);
    Result.BottomRight := Tab.Ribbon.ClientToScreen(Result.BottomRight);
  end
  else
    Result := cxEmptyRect;
end;

function TdxRibbonTabAccessibilityHelper.GetSelectable: Boolean;
begin
  Result := Visible;
end;

function TdxRibbonTabAccessibilityHelper.GetState(
  AChildID: TcxAccessibleSimpleChildElementID): Integer;
begin
  Result := Parent.States[cxAccessibleObjectSelfID];
  if not Tab.Visible then
    Result := Result or cxSTATE_SYSTEM_INVISIBLE;
end;

function TdxRibbonTabAccessibilityHelper.GetAssignedKeyTip: string;
begin
  Result := Tab.KeyTip;
  if (Length(Result) > 0) and dxCharInSet(Result[1], ['0'..'9']) then
    Result := '';
end;

function TdxRibbonTabAccessibilityHelper.GetDefaultKeyTip: string;
begin
  Result := 'Y';
end;

procedure TdxRibbonTabAccessibilityHelper.GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo);
var
  ABasePoint: TPoint;
  ATextMetric: TTextMetric;
begin
  inherited;
  with TcxScreenCanvas.Create do
  try
    Font := Self.Tab.ViewInfo.Font;
    GetTextMetrics(Handle, ATextMetric);
  finally
    Free;
  end;
  with Tab.ViewInfo.TextBounds do
  begin
    ABasePoint.X := (Left + Right) div 2;
    ABasePoint.Y := Bottom - ATextMetric.tmDescent;
  end;
  AKeyTipInfo.BasePoint := Tab.Ribbon.ClientToScreen(ABasePoint);
  AKeyTipInfo.HorzAlign := taCenter;
  AKeyTipInfo.VertAlign := vaBottom;
  AKeyTipInfo.Enabled := True;
end;

procedure TdxRibbonTabAccessibilityHelper.KeyTipHandler(Sender: TObject);
begin
  BarNavigationController.ChangeSelectedObject(True, Self);
  if not Tab.Ribbon.AreGroupsVisible then
  begin
    Tab.Active := True;
    BarNavigationController.UnselectAssignedSelectedObject;
    Tab.Ribbon.ShowTabGroupsPopupWindow;
  end;
  BarNavigationController.SetKeyTipsShowingState(Self, '');
end;

procedure TdxRibbonTabAccessibilityHelper.KeyTipsEscapeHandler;
begin
  Tab.Ribbon.CloseTabGroupsPopupWindow;
  inherited KeyTipsEscapeHandler;
end;

function TdxRibbonTabAccessibilityHelper.GetTab: TdxRibbonTab;
begin
  Result := TdxRibbonTab(FOwnerObject);
end;

{ TdxRibbonApplicationButtonAccessibilityHelper }

// IdxBarAccessibilityHelper
function TdxRibbonApplicationButtonAccessibilityHelper.GetBarManager: TdxBarManager;
begin
  Result := Ribbon.BarManager;
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetNextAccessibleObject(
  ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper;
var
  ATabIndex: Integer;
begin
  Result := nil;
  case ADirection of
    andLeft, andRight:
      begin
        ATabIndex := Ribbon.TabsIAccessibilityHelper.GetHelper.GetNextSelectableChildIndex(
          -1, ADirection = andRight);
        if ATabIndex <> -1 then
          Result := Ribbon.TabsIAccessibilityHelper.GetBarHelper.Childs[ATabIndex];
      end;
    andUp:
      Result := Self;
  end;
  if Result = nil then
    Result := inherited GetNextAccessibleObject(ADirection);
end;

function TdxRibbonApplicationButtonAccessibilityHelper.HandleNavigationKey(
  var AKey: Word): Boolean;
begin
  Result := inherited HandleNavigationKey(AKey);
  if Result then
    Exit;
  Result := AKey in [VK_DOWN, VK_SPACE, VK_RETURN];
  if Result then
    ShowApplicationMenu(CM_SELECTAPPMENUFIRSTITEMCONTROL);
end;

function TdxRibbonApplicationButtonAccessibilityHelper.IsNavigationKey(
  AKey: Word): Boolean;
begin
  Result := inherited IsNavigationKey(AKey) or (AKey in [VK_ESCAPE, VK_SPACE, VK_RETURN]);
end;

procedure TdxRibbonApplicationButtonAccessibilityHelper.Select(ASetFocus: Boolean);
begin
  inherited Select(ASetFocus);
  Ribbon.InvalidateRect(Ribbon.ViewInfo.ApplicationButtonBounds, False);
end;

procedure TdxRibbonApplicationButtonAccessibilityHelper.Unselect(
  ANextSelectedObject: IdxBarAccessibilityHelper);
begin
  inherited Unselect(ANextSelectedObject);
  Ribbon.InvalidateRect(Ribbon.ViewInfo.ApplicationButtonBounds, False);
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetOwnerObjectWindow: HWND;
begin
  Result := Parent.OwnerObjectWindow;
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetParent: TcxAccessibilityHelper;
begin
  Result := Ribbon.IAccessibilityHelper.GetHelper;
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetScreenBounds(
  AChildID: TcxAccessibleSimpleChildElementID): TRect;
begin
  if Visible then
  begin
    Result := Ribbon.ViewInfo.ApplicationButtonBounds;
    Result.TopLeft := Ribbon.ClientToScreen(Result.TopLeft);
    Result.BottomRight := Ribbon.ClientToScreen(Result.BottomRight);
  end
  else
    Result := cxEmptyRect;
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetSelectable: Boolean;
begin
  Result := Visible;
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetState(
  AChildID: TcxAccessibleSimpleChildElementID): Integer;
begin
  Result := Parent.States[cxAccessibleObjectSelfID];
  if not Ribbon.ViewInfo.IsApplicationButtonVisible then
    Result := Result or cxSTATE_SYSTEM_INVISIBLE;
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetAssignedKeyTip: string;
begin
  Result := Ribbon.ApplicationButton.KeyTip;
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetDefaultKeyTip: string;
begin
  Result := 'F';
end;

procedure TdxRibbonApplicationButtonAccessibilityHelper.GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo);
begin
  inherited;
  AKeyTipInfo.BasePoint := cxRectCenter(GetScreenBounds(cxAccessibleObjectSelfID));
  AKeyTipInfo.HorzAlign := taCenter;
  AKeyTipInfo.VertAlign := vaCenter;
  AKeyTipInfo.Enabled := True;
end;

procedure TdxRibbonApplicationButtonAccessibilityHelper.KeyTipHandler(Sender: TObject);
begin
  ShowApplicationMenu(CM_SHOWKEYTIPS);
end;

procedure TdxRibbonApplicationButtonAccessibilityHelper.ApplicationMenuCloseUpHandler(
  Sender: TObject);
begin
  if Assigned(FPrevOnApplicationMenuCloseUp) then
    FPrevOnApplicationMenuCloseUp(Sender);
  if TdxBarSubMenuControlAccess(TdxBarApplicationMenu(Sender).ItemLinks.BarControl).ClosedByEscape and
    BarNavigationController.NavigationMode then
      Select(False);
end;

function TdxRibbonApplicationButtonAccessibilityHelper.GetRibbon: TdxCustomRibbon;
begin
  Result := TdxRibbonApplicationButton(FOwnerObject).Ribbon;
end;

procedure TdxRibbonApplicationButtonAccessibilityHelper.ShowApplicationMenu(
  APostMessage: UINT);
begin
  if Ribbon.ApplicationButton.Menu <> nil then
  begin
    FPrevOnApplicationMenuCloseUp := Ribbon.ApplicationButton.Menu.OnCloseUp;
    Ribbon.ApplicationButton.Menu.OnCloseUp := ApplicationMenuCloseUpHandler;
    BarNavigationController.UnselectAssignedSelectedObject;
    try
      PostMessage(Ribbon.Handle, APostMessage, 0, 0);
      Ribbon.ApplicationMenuPopup;
    finally
      if Ribbon.ApplicationButton.Menu <> nil then
        Ribbon.ApplicationButton.Menu.OnCloseUp := FPrevOnApplicationMenuCloseUp;
    end;
  end
  else
  begin
    BarNavigationController.UnselectAssignedSelectedObject;
    Ribbon.ApplicationMenuPopup;
  end;
end;

{ TdxRibbonGroupsDockControlAccessibilityHelper }

function TdxRibbonGroupsDockControlAccessibilityHelper.GetChild(
  AIndex: Integer): TcxAccessibilityHelper;
begin
  Result := DockControl.ViewInfo.GroupViewInfos[AIndex].BarControl.IAccessibilityHelper.GetHelper;
end;

function TdxRibbonGroupsDockControlAccessibilityHelper.GetChildCount: Integer;
begin
  Result := DockControl.ViewInfo.GroupCount;
end;

function TdxRibbonGroupsDockControlAccessibilityHelper.GetChildIndex(
  AChild: TcxAccessibilityHelper): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to ChildCount - 1 do
    if Childs[I] = AChild then
    begin
      Result := I;
      Break;
    end;
end;

function TdxRibbonGroupsDockControlAccessibilityHelper.GetParent: TcxAccessibilityHelper;
begin
  if GetParentPopupWindow(DockControl, False) <> nil then
    Result := nil
  else
    Result := TdxRibbonGroupsDockControl(DockControl).Tab.IAccessibilityHelper.GetHelper;
end;

function TdxRibbonGroupsDockControlAccessibilityHelper.GetState(
  AChildID: TcxAccessibleSimpleChildElementID): Integer;
begin
  Result := inherited GetState(AChildID);
  if not TdxRibbonGroupsDockControl(DockControl).Tab.Ribbon.AreGroupsVisible then
    Result := Result or cxSTATE_SYSTEM_INVISIBLE;
end;

function TdxRibbonGroupsDockControlAccessibilityHelper.GetParentForKeyTip: TdxBarAccessibilityHelper;
begin
  if GetParentPopupWindow(DockControl, False) <> nil then
    Result := DockControl.Tab.IAccessibilityHelper.GetBarHelper
  else
    Result := inherited GetParentForKeyTip;
end;

function TdxRibbonGroupsDockControlAccessibilityHelper.GetDockControl: TdxRibbonGroupsDockControl;
begin
  Result := TdxRibbonGroupsDockControl(FOwnerObject);
end;

{ TdxRibbonQuickAccessToolbarAccessibilityHelper }

function TdxRibbonQuickAccessBarControlAccessibilityHelper.GetChild(
  AIndex: Integer): TcxAccessibilityHelper;
begin
  if AIndex = ChildCount - 1 then
    Result := BarControl.MarkIAccessibilityHelper.GetHelper
  else
    Result := inherited GetChild(AIndex);
end;

function TdxRibbonQuickAccessBarControlAccessibilityHelper.GetChildCount: Integer;
begin
  Result := inherited GetChildCount;
  if TCustomdxBarControlAccess(BarControl).MarkExists then
    Inc(Result);
end;

function TdxRibbonQuickAccessBarControlAccessibilityHelper.GetChildIndex(
  AChild: TcxAccessibilityHelper): Integer;
begin
  if AChild = BarControl.MarkIAccessibilityHelper.GetHelper then
    Result := inherited GetChildCount
  else
    Result := inherited GetChildIndex(AChild);
end;

function TdxRibbonQuickAccessBarControlAccessibilityHelper.GetParent: TcxAccessibilityHelper;
begin
  Result := TdxRibbonQuickAccessBarControl(BarControl).Ribbon.IAccessibilityHelper.GetHelper;
end;

procedure TdxRibbonQuickAccessBarControlAccessibilityHelper.DoGetKeyTipsData(AKeyTipsData: TList);

  procedure GetItemsKeyTipsData(
    ABarControl: TCustomdxBarControl; AStartIndex, AEndIndex: Integer; AKeyTipsData: TList; AVisible: Boolean);
  var
    I: Integer;
    AChild: TdxBarAccessibilityHelper;
    AKeyTipData: TdxBarKeyTipData;
  begin
    for I := AStartIndex to AEndIndex do
    begin
      AChild := ABarControl.ItemLinks.VisibleItems[I].Control.IAccessibilityHelper.GetBarHelper;
      AKeyTipData := TdxBarAccessibilityHelperAccess(AChild).CreateKeyTipData;
      AKeyTipData.Visible := AVisible;
      AKeyTipsData.Add(AKeyTipData);
    end;
  end;

  procedure GenerateKeyTips(AItemKeyTipsData: TList);
  var
    I: Integer;
  begin
    for I := 0 to AItemKeyTipsData.Count - 1 do
    begin
      case I of
        0..8: TdxBarKeyTipData(AItemKeyTipsData[I]).KeyTip := IntToStr(I + 1);                   // '1'..'9'
        9..17: TdxBarKeyTipData(AItemKeyTipsData[I]).KeyTip := '0' + IntToStr(18 - I);           // '09'..'01'
        18..44: TdxBarKeyTipData(AItemKeyTipsData[I]).KeyTip := '0' + Char(Ord('A') + (I - 18)); // '0A'..'0Z'
      else
        TdxBarKeyTipData(AItemKeyTipsData[I]).KeyTip := '';
      end;
      AKeyTipsData.Add(AItemKeyTipsData[I])
    end;
  end;

var
  VisibleItemCount, ARealVisibleItemCount: Integer;
  AItemKeyTipsData: TList;
begin
  AItemKeyTipsData := TList.Create;
  try
    VisibleItemCount := TdxBarItemLinksAccess(BarControl.ItemLinks).VisibleItemCount;
    if BarControl.IsPopup then
    begin
      ARealVisibleItemCount := TdxBarItemLinksAccess(BarControl.ParentBar.ItemLinks).RealVisibleItemCount;
      GetItemsKeyTipsData(BarControl.ParentBar, 0, ARealVisibleItemCount - 1, AItemKeyTipsData, False);
      GetItemsKeyTipsData(BarControl, 0, VisibleItemCount - 1 - 1{Mark!!!}, AItemKeyTipsData, True);
    end
    else
    begin
      ARealVisibleItemCount := TdxBarItemLinksAccess(BarControl.ItemLinks).RealVisibleItemCount;
      GetItemsKeyTipsData(BarControl, 0, ARealVisibleItemCount - 1, AItemKeyTipsData, True);
      GetItemsKeyTipsData(BarControl, ARealVisibleItemCount, VisibleItemCount - 1, AItemKeyTipsData, False);
      if not BarControl.AllItemsVisible then
        TdxBarAccessibilityHelperAccess(BarControl.MarkIAccessibilityHelper.GetBarHelper).GetKeyTipData(AKeyTipsData);
    end;
    GenerateKeyTips(AItemKeyTipsData);
  finally
    AItemKeyTipsData.Free;
  end;
end;

procedure TdxRibbonQuickAccessBarControlAccessibilityHelper.GetItemControlKeyTipPosition(
  AItemControl: TdxBarItemControl; out ABasePoint: TPoint;
   out AHorzAlign: TAlignment; out AVertAlign: TcxAlignmentVert);
begin
  inherited GetItemControlKeyTipPosition(AItemControl, ABasePoint, AHorzAlign,
    AVertAlign);
  AVertAlign := vaBottom;
end;

function TdxRibbonQuickAccessBarControlAccessibilityHelper.GetNextAccessibleObject(
  AItemControl: TdxBarItemControl;
  ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper;

  function InternalGetRootObject: TdxBarAccessibilityHelper;
  begin
    if TdxRibbonQuickAccessBarControl(BarControl).IsPopup then
      Result := Self
    else
      Result := GetRootAccessibleObject.GetBarHelper;
  end;

var
  AObjects: TList;
begin
  AObjects := TList.Create;
  try
    GetChildrenForNavigation(
      AItemControl.IAccessibilityHelper.GetBarHelper, InternalGetRootObject,
      TdxBarAccessibilityHelperAccess(AItemControl.IAccessibilityHelper.GetBarHelper).GetScreenBounds(cxAccessibleObjectSelfID),
      ADirection, True, AObjects);
    Result := dxBar.GetNextAccessibleObject(
      AItemControl.IAccessibilityHelper.GetBarHelper, AObjects, ADirection, True);
  finally
    AObjects.Free;
  end;
end;

function TdxRibbonQuickAccessBarControlAccessibilityHelper.GetParentForKeyTip: TdxBarAccessibilityHelper;
begin
  if BarControl.IsPopup then
    Result := BarControl.ParentBar.IAccessibilityHelper.GetBarHelper
  else
    Result := inherited GetParentForKeyTip;
end;

function TdxRibbonQuickAccessBarControlAccessibilityHelper.IsKeyTipContainer: Boolean;
begin
  Result := BarControl.IsPopup;
end;

procedure TdxRibbonQuickAccessBarControlAccessibilityHelper.KeyTipsEscapeHandler;
var
  AMarkAccessibleObject: IdxBarAccessibilityHelper;
  ASelectedControl: TdxBarItemControl;
begin
  if not BarControl.IsPopup then
  begin
    ASelectedControl := TdxRibbonQuickAccessBarControl(BarControl).SelectedControl;
    inherited KeyTipsEscapeHandler;
    BarNavigationController.ChangeSelectedObject(True, ASelectedControl.IAccessibilityHelper);
  end
  else
  begin
    BarNavigationController.SetKeyTipsShowingState(GetKeyTipContainerParent(Self), '');
    AMarkAccessibleObject := TdxRibbonQuickAccessBarControl(BarControl.ParentBar).MarkIAccessibilityHelper;
    TdxRibbonQuickAccessBarControl(BarControl.ParentBar).MarkState := msNone;
    if AMarkAccessibleObject.GetHelper.IsOwnerObjectLive then
      BarNavigationController.ChangeSelectedObject(True, AMarkAccessibleObject);
  end;
end;

function TdxRibbonQuickAccessBarControlAccessibilityHelper.GetBarControl: TdxRibbonQuickAccessBarControl;
begin
  Result := TdxRibbonQuickAccessBarControl(FOwnerObject);
end;

{ TdxRibbonQuickAccessBarControlMarkAccessibilityHelper }

// IdxBarAccessibilityHelper
function TdxRibbonQuickAccessBarControlMarkAccessibilityHelper.HandleNavigationKey(
  var AKey: Word): Boolean;
begin
  Result := inherited HandleNavigationKey(AKey);
  if (BarControl.MarkState = msPressed) and not BarControl.AllItemsVisible then
    SelectFirstSelectableAccessibleObject(
      BarDesignController.QuickControl.IAccessibilityHelper.GetBarHelper);
end;

procedure TdxRibbonQuickAccessBarControlMarkAccessibilityHelper.GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo);
begin
  inherited;
  AKeyTipInfo.BasePoint := cxRectCenter(GetScreenBounds(cxAccessibleObjectSelfID));
  AKeyTipInfo.HorzAlign := taCenter;
  AKeyTipInfo.VertAlign := vaBottom;
  AKeyTipInfo.Enabled := True;
end;

function TdxRibbonQuickAccessBarControlMarkAccessibilityHelper.GetKeyTip: string;
begin
  if BarControl.AllItemsVisible then
    Result := ''
  else
    Result := '00';
end;

procedure TdxRibbonQuickAccessBarControlMarkAccessibilityHelper.KeyTipHandler(Sender: TObject);
begin
  DropDown;
  BarNavigationController.SetKeyTipsShowingState(BarDesignController.QuickControl.IAccessibilityHelper, '');
end;

function TdxRibbonQuickAccessBarControlMarkAccessibilityHelper.GetBarControl: TdxRibbonQuickAccessBarControl;
begin
  Result := TdxRibbonQuickAccessBarControl(FOwnerObject);
end;

{ TdxRibbonGroupBarControlAccessibilityHelper }

procedure TdxRibbonGroupBarControlAccessibilityHelper.CloseUpHandler(
  AClosedByEscape: Boolean);
begin
  if AClosedByEscape and BarNavigationController.NavigationMode then
    Select(False);
end;

// IdxBarAccessibilityHelper
function TdxRibbonGroupBarControlAccessibilityHelper.GetNextAccessibleObject(
  ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper;
begin
  if BarControl.Collapsed then
    Result := GetNextAccessibleObject(nil, ADirection)
  else
    Result := inherited GetNextAccessibleObject(ADirection);
end;

function TdxRibbonGroupBarControlAccessibilityHelper.HandleNavigationKey(
  var AKey: Word): Boolean;
begin
  Result := inherited HandleNavigationKey(AKey);
  if Result then
    Exit;
  Result := BarControl.Collapsed and (AKey in [VK_RETURN, VK_SPACE]);
  if Result then
  begin
    ShowPopupBarControl;
    SelectFirstSelectableAccessibleObject(
      BarDesignController.QuickControl.IAccessibilityHelper.GetBarHelper);
  end;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.IsNavigationKey(AKey: Word): Boolean;
begin
  Result := inherited IsNavigationKey(AKey);
  if BarControl.Collapsed then
    Result := Result or (AKey in [VK_ESCAPE, VK_RETURN, VK_SPACE]);
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.Select(ASetFocus: Boolean);
begin
  if not BarControl.Collapsed then
    inherited Select(ASetFocus)
  else
  begin
    BarNavigationController.SelectedObject := Self;
    BarNavigationController.SelectedObjectParent := Parent;
    BarControl.Invalidate;

    TdxRibbonGroupsDockControl(BarControl.DockControl).MakeRectFullyVisible(BarControl.BoundsRect);
  end;
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.Unselect(
  ANextSelectedObject: IdxBarAccessibilityHelper);
begin
  if not BarControl.Collapsed then
    inherited Unselect(ANextSelectedObject)
  else
  begin
    BarNavigationController.SelectedObject := nil;
    BarNavigationController.SelectedObjectParent := nil;
    BarControl.Invalidate;
  end;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.GetSelectable: Boolean;
begin
  if BarControl.Collapsed then
    Result := Visible
  else
    Result := inherited GetSelectable;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.Expand: TCustomdxBarControlAccessibilityHelper;
begin
  if not IsCollapsed then
    raise EdxException.Create('');
  ShowPopupBarControl;
  Result := TCustomdxBarControlAccessibilityHelper(BarDesignController.QuickControl.IAccessibilityHelper.GetHelper);
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.GetCaptionButtonKeyTipPosition(
  ACaptionButton: TdxBarCaptionButton; out ABasePointY: Integer;
  out AVertAlign: TcxAlignmentVert);
begin
  ABasePointY := BarControl.ViewInfo.BottomKeyTipsBaseLinePosition;
  AVertAlign := vaBottom;
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.GetItemControlKeyTipPosition(
  AItemControl: TdxBarItemControl; out ABasePoint: TPoint;
   out AHorzAlign: TAlignment; out AVertAlign: TcxAlignmentVert);
var
  AOneRowHeightItemControl: Boolean;
  ARow: Integer;
begin
  AOneRowHeightItemControl := AItemControl.ViewInfo.ViewLevel <> ivlLargeIconWithText;

  if not AOneRowHeightItemControl then
    ABasePoint.Y := BarControl.ViewInfo.RowKeyTipsBaseLinePositions[dxRibbonGroupRowCount - 1]
  else
  begin
    ARow := IdxBarItemControlViewInfo(AItemControl.ViewInfo).GetRow;
    if (IdxBarItemControlViewInfo(AItemControl.ViewInfo).GetColumnRowCount = 2) and (ARow = 1) then
      ARow := 2;
    if IdxBarItemControlViewInfo(AItemControl.ViewInfo).GetColumnRowCount = 1 then
      ARow := 1;
    ABasePoint.Y := BarControl.ViewInfo.RowKeyTipsBaseLinePositions[ARow];
  end;
  AVertAlign := vaCenter;

  if AOneRowHeightItemControl and
    (cpIcon in TdxBarItemControlAccess(AItemControl).FDrawParams.ViewStructure) then
  begin
    ProcessPaintMessages; // AItemControl.ViewInfo.ImageBounds are calculated on painting
    with AItemControl.ViewInfo.ImageBounds do
      ABasePoint.X := (Left + Right) div 2;
    ABasePoint.X := AItemControl.Parent.ClientToScreen(ABasePoint).X;
    AHorzAlign := taRightJustify;
  end
  else
  begin
    with GetItemControlScreenBounds(AItemControl) do
      ABasePoint.X := (Left + Right) div 2;
    AHorzAlign := taCenter;
  end;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.GetAssignedKeyTip: string;
begin
  Result := BarControl.Bar.KeyTip;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.GetDefaultKeyTip: string;

  function GetFirstChar(const AText: string): string;
  begin
    if Length(AText) > 0 then
      Result := AText[1]
    else
      Result := '';
  end;

begin
  Result := 'Z' + GetFirstChar(BarControl.Bar.Caption);
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.GetKeyTipInfo(out AKeyTipInfo: TdxBarKeyTipInfo);
var
  AKeyTipBasePoint: TPoint;
begin
  inherited;
  with GetScreenBounds(cxAccessibleObjectSelfID) do
    AKeyTipBasePoint.X := (Left + Right) div 2;
  AKeyTipBasePoint.Y := BarControl.ViewInfo.BottomKeyTipsBaseLinePosition;
  AKeyTipInfo.BasePoint := AKeyTipBasePoint;
  AKeyTipInfo.HorzAlign := taCenter;
  AKeyTipInfo.VertAlign := vaBottom;
  AKeyTipInfo.Enabled := True;
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.GetKeyTipData(AKeyTipsData: TList);

  procedure AddKeyTipsForItemControls;
  var
    AItemControl: TdxBarItemControl;
    I: Integer;
  begin
    for I := 0 to BarControl.ViewInfo.ItemControlCount - 1 do
    begin
      AItemControl := BarControl.ViewInfo.ItemControlViewInfos[I].Control;
      with TdxBarItemControlAccessibilityHelperAccess(AItemControl.IAccessibilityHelper.GetBarHelper) do
        if CanSelect then
          GetKeyTipData(AKeyTipsData);
    end;
  end;

  procedure AddKeyTipsForCaptionButtons;
  var
    ACaptionButton: TdxBarCaptionButton;
    I: Integer;
  begin
    for I := 0 to BarControl.Bar.CaptionButtons.Count - 1 do
    begin
      ACaptionButton := BarControl.Bar.CaptionButtons[I];
      TdxBarCaptionButtonAccessibilityHelperAccess(ACaptionButton.IAccessibilityHelper.GetHelper).GetKeyTipData(AKeyTipsData);
    end;
  end;

begin
  inherited;

  //TODO:   GetKeyTipsData(AKeyTipsData);

  AddKeyTipsForItemControls;
  AddKeyTipsForCaptionButtons;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.GetNextAccessibleObject(
  AItemControl: TdxBarItemControl;
  ADirection: TcxAccessibilityNavigationDirection): IdxBarAccessibilityHelper;

  function FindAmongItemControlsAndCollapsedBarControls(
    ASelectedObject: TdxBarAccessibilityHelper;
    const ASelectedObjectScreenBounds: TRect): IdxBarAccessibilityHelper;

    procedure GetBarControlChildren(ABarControl: TdxRibbonGroupBarControl;
      AObjects: TList);
    var
      AItemControl1: TdxBarItemControl;
      I: Integer;
    begin
      for I := 0 to ABarControl.ViewInfo.ItemControlCount - 1 do
      begin
        AItemControl1 := ABarControl.ViewInfo.ItemControlViewInfos[I].Control;
        GetChildrenForNavigation(ASelectedObject,
          AItemControl1.IAccessibilityHelper.GetBarHelper, ASelectedObjectScreenBounds,
          ADirection, False, AObjects);
      end;
    end;

  var
    ABarControl: TdxRibbonGroupBarControl;
    AObjects: TList;
    I: Integer;
  begin
    Result := nil;
    AObjects := TList.Create;
    try
      if BarControl.IsPopup then
        GetBarControlChildren(BarControl, AObjects)
      else
        for I := 0 to Parent.ChildCount - 1 do
        begin
          ABarControl := TdxRibbonGroupBarControlAccessibilityHelper(Parent.Childs[I]).BarControl;
          if ABarControl.Collapsed then
            GetChildrenForNavigation(ASelectedObject,
              ABarControl.IAccessibilityHelper.GetBarHelper, ASelectedObjectScreenBounds, ADirection, False, AObjects)
          else
            if not ((ADirection in [andUp, andDown]) and (ABarControl <> BarControl)) then
              GetBarControlChildren(ABarControl, AObjects);
        end;
      Result := dxBar.GetNextAccessibleObject(ASelectedObject, AObjects, ADirection, True);
    finally
      AObjects.Free;
    end;
  end;

var
  ACaptionButtonIndex: Integer;
  AObjects: TList;
  AScreenBounds: TRect;
  ASelectedObject: TdxBarAccessibilityHelper;
begin
  if AItemControl <> nil then
    ASelectedObject := AItemControl.IAccessibilityHelper.GetBarHelper
  else
    ASelectedObject := Self;
  AScreenBounds := TdxBarAccessibilityHelperAccess(ASelectedObject).GetScreenBounds(cxAccessibleObjectSelfID);
  Result := FindAmongItemControlsAndCollapsedBarControls(ASelectedObject, AScreenBounds);
  if Result <> nil then
    Exit;
  case ADirection of
    andUp:
      if not (BarControl.IsPopup or TdxRibbonGroupBarControl(BarControl).Ribbon.IsPopupGroupsMode) then
        Result := TdxRibbonGroupBarControl(BarControl).Ribbon.ActiveTab.IAccessibilityHelper;
    andDown:
      begin
        ACaptionButtonIndex := -1;
        if not BarControl.Collapsed then
          ACaptionButtonIndex := BarControl.Bar.CaptionButtons.IAccessibilityHelper.GetHelper.GetNextSelectableChildIndex(-1, False);
        if ACaptionButtonIndex <> -1 then
          Result := BarControl.Bar.CaptionButtons[ACaptionButtonIndex].IAccessibilityHelper
        else
          if not (BarControl.IsPopup or TdxRibbonGroupBarControl(BarControl).Ribbon.IsPopupGroupsMode) and
            (BarControl.Ribbon.QATIAccessibilityHelper <> nil) then
          begin
            AObjects := TList.Create;
            try
              GetChildrenForNavigation(ASelectedObject,
                BarControl.Ribbon.QATIAccessibilityHelper.GetBarHelper,
                AScreenBounds, ADirection, False, AObjects);
              Result := dxBar.GetNextAccessibleObject(
                ASelectedObject, AObjects, ADirection, True);
            finally
              AObjects.Free;
            end;
          end;
      end;
  end;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.GetParentForKeyTip: TdxBarAccessibilityHelper;
begin
  if BarControl.IsPopup then
    Result := BarControl.ParentBar.IAccessibilityHelper.GetBarHelper
  else
    Result := inherited GetParentForKeyTip;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.IsCollapsed: Boolean;
begin
  Result := BarControl.Collapsed;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.IsKeyTipContainer: Boolean;
begin
  Result := BarControl.IsPopup;
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.KeyTipHandler(
  Sender: TObject);
begin
  ShowPopupBarControl;
  BarNavigationController.SetKeyTipsShowingState(
    BarDesignController.QuickControl.IAccessibilityHelper, '');
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.KeyTipsEscapeHandler;
var
  ASelectedItemControl: TdxBarItemControl;
begin
  if BarControl.IsPopup then
  begin
    if BarControl = BarDesignController.QuickControl then
    begin
      TdxRibbonGroupBarControlAccessibilityHelper(BarControl.ParentBar.IAccessibilityHelper.GetHelper).KeyTipsEscapeHandler;
      TCustomdxBarControlAccess(BarControl.ParentBar).MarkState := msNone;
    end
    else
    begin
      if not TCustomdxBarControlAccess(BarControl.ParentBar).IsPopup then
        TdxRibbonGroupBarControlAccessibilityHelper(BarControl.ParentBar.IAccessibilityHelper.GetHelper).KeyTipsEscapeHandler
      else
      begin
        ASelectedItemControl := TCustomdxBarControlAccess(BarControl.ParentBar).SelectedControl;
        BarControl.Hide;
        BarNavigationController.ChangeSelectedObject(True, ASelectedItemControl.IAccessibilityHelper);
        BarNavigationController.SetKeyTipsShowingState(ASelectedItemControl.Parent.IAccessibilityHelper, '');
      end;
    end;
  end
  else
    inherited KeyTipsEscapeHandler;
end;

function TdxRibbonGroupBarControlAccessibilityHelper.GetBarControl: TdxRibbonGroupBarControl;
begin
  Result := TdxRibbonGroupBarControl(FOwnerObject);
end;

procedure TdxRibbonGroupBarControlAccessibilityHelper.ShowPopupBarControl;
begin
  BarNavigationController.UnselectAssignedSelectedObject;
  BarControl.MarkState := msPressed;
end;

{ TdxRibbonQuickAccessGroupButtonControlAccessibilityHelper }

function TdxRibbonQuickAccessGroupButtonControlAccessibilityHelper.IsDropDownControl: Boolean;
begin
  Result := True;
end;

function TdxRibbonQuickAccessGroupButtonControlAccessibilityHelper.ShowDropDownWindow: Boolean;
begin
  TdxRibbonQuickAccessGroupButtonControl(ItemControl).DropDown(True);
  Result := ItemControl.IsDroppedDown;
end;

{ TdxRibbonKeyTipWindow }

constructor TdxRibbonKeyTipWindow.Create(AColorScheme: TdxCustomRibbonSkin);
begin
  inherited Create(nil);
  FColorScheme := AColorScheme;
  Canvas.Font := Screen.HintFont;
  Canvas.Brush.Style := bsClear;
end;

procedure TdxRibbonKeyTipWindow.ShowKeyTip;
begin
  ParentWindow := Application.Handle;
  SetWindowRgn(Handle, CreateRoundRectRgn(0, 0, Width + 1, Height + 1, 2, 2), True);
  Invalidate;
end;

function TdxRibbonKeyTipWindow.CalcBoundsRect: TRect;
var
  ATempCanvas: TcxScreenCanvas;
begin
  Result := cxEmptyRect;
  ATempCanvas := TcxScreenCanvas.Create;
  try
    ATempCanvas.Font := Canvas.Font;
    cxDrawText(ATempCanvas.Handle, Caption, Result,
      DT_CALCRECT or DT_SINGLELINE or DT_LEFT or DT_NOPREFIX);
  finally
    FreeAndNil(ATempCanvas);
  end;
  Inc(Result.Right, 6);
  Result.Right := Max(Result.Right, 16);
  Inc(Result.Bottom, 2);
end;

procedure TdxRibbonKeyTipWindow.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := WS_POPUP;
    ExStyle := WS_EX_TOOLWINDOW or WS_EX_TOPMOST;
  end;
end;

procedure TdxRibbonKeyTipWindow.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited;
  if not Enabled then
    SetLayeredWndAttributes(Handle, 153);
end;

procedure TdxRibbonKeyTipWindow.Paint;
var
  R: TRect;
begin
  R := ClientRect;
  FColorScheme.DrawScreenTip(Canvas.Handle, R);
  Canvas.Font.Color := dxBarScreenTipFontColor;
  cxDrawText(Canvas.Handle, Caption, R, DT_SINGLELINE or DT_CENTER or
    DT_NOPREFIX or DT_VCENTER);
end;

procedure TdxRibbonKeyTipWindow.UpdateBounds;
var
  R: TRect;
begin
  R := CalcBoundsRect;
  UpdateBoundsRect(R);
end;

procedure TdxRibbonKeyTipWindow.CMEnabledChanged(var Message: TMessage);
begin
  RecreateWnd;
end;

procedure TdxRibbonKeyTipWindow.CMTextChanged(var Message: TMessage);
begin
  inherited;
  UpdateBounds;
end;

procedure TdxRibbonKeyTipWindow.WMNCHitTest(var Message: TWMNCHitTest);
begin
  Message.Result := HTTRANSPARENT;
end;

{ TdxRibbonKeyTipWindows }

constructor TdxRibbonKeyTipWindows.Create(ARibbon: TdxCustomRibbon);
begin
  inherited Create;
  FRibbon := ARibbon;
  FWindowList := TcxObjectList.Create;
end;

destructor TdxRibbonKeyTipWindows.Destroy;
begin
  FreeAndNil(FWindowList);
  inherited Destroy;
end;

// IdxBarKeyTipWindowsManager
procedure TdxRibbonKeyTipWindows.Add(const ACaption: string;
  const ABasePoint: TPoint; AHorzAlign: TAlignment;
  AVertAlign: TcxAlignmentVert; AEnabled: Boolean; out AWindow: TObject);

  function GetWindowPosition(const AWindowSize: TSize; const ABasePoint: TPoint;
    AVertAlign: TcxAlignmentVert): TPoint;
  begin
    case AHorzAlign of
      taLeftJustify:
        Result.X := ABasePoint.X - AWindowSize.cx;
      taCenter:
        Result.X := ABasePoint.X - AWindowSize.cx div 2;
      taRightJustify:
        Result.X := ABasePoint.X;
    end;
    case AVertAlign of
      vaTop:
        Result.Y := ABasePoint.Y - AWindowSize.cy;
      vaCenter:
        Result.Y := ABasePoint.Y - AWindowSize.cy div 2;
      vaBottom:
        Result.Y := ABasePoint.Y;
    end;
  end;

var
  ATempWindow: TdxRibbonKeyTipWindow;
begin
  ATempWindow := TdxRibbonKeyTipWindow.Create(ColorScheme);
  ATempWindow.Caption := ACaption;
  ATempWindow.Enabled := AEnabled;
  with GetWindowPosition(cxSize(ATempWindow.Width, ATempWindow.Height),
    ABasePoint, AVertAlign) do
  begin
    ATempWindow.Left := X;
    ATempWindow.Top := Y;
  end;
  FWindowList.Add(ATempWindow);
  AWindow := ATempWindow;
end;

procedure TdxRibbonKeyTipWindows.Delete(AWindow: TObject);
var
  AIndex: Integer;
begin
  AIndex := FWindowList.IndexOf(AWindow);
  if AIndex = -1 then
    raise EdxException.Create('');
  TdxRibbonKeyTipWindow(FWindowList[AIndex]).Free;
  FWindowList.Delete(AIndex);
end;

procedure TdxRibbonKeyTipWindows.Show;
var
  AWindow: TdxRibbonKeyTipWindow;
  I: Integer;
  WP: HDWP;
begin
  if Count = 0 then
    Exit;
  WP := BeginDeferWindowPos(Count);
  try
    for I := 0 to Count - 1 do
    begin
      AWindow := TdxRibbonKeyTipWindow(FWindowList[I]);
      DeferWindowPos(WP, AWindow.Handle, HWND_TOPMOST, AWindow.Left, AWindow.Top,
        AWindow.Width, AWindow.Height, SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOZORDER);
      AWindow.ShowKeyTip;
    end;
  finally
    EndDeferWindowPos(WP);
  end;
end;

function TdxRibbonKeyTipWindows.GetColorScheme: TdxCustomRibbonSkin;
begin
  Result := FRibbon.ColorScheme;
end;

function TdxRibbonKeyTipWindows.GetCount: Integer;
begin
  Result := FWindowList.Count;
end;

initialization
  RegisterClasses([TdxRibbonTab, TdxRibbonPopupMenu]);
  dxBarRegisterItem(TdxRibbonQuickAccessPopupSubItem,
    TdxRibbonQuickAccessPopupSubItemControl, False);
  dxBarRegisterItem(TdxRibbonQuickAccessPopupSubItemButton,
    TdxRibbonQuickAccessPopupSubItemButtonControl, False);
  dxBarRegisterItem(TdxRibbonQuickAccessGroupButton,
    TdxRibbonQuickAccessGroupButtonControl, False);
  BarDesignController.RegisterBarControlDesignHelper(
    TdxRibbonGroupBarControl, TdxRibbonGroupBarControlDesignHelper);
  BarDesignController.RegisterBarControlDesignHelper(
    TdxRibbonQuickAccessBarControl, TdxRibbonQuickAccessBarControlDesignHelper);

  dxBarGetRootAccessibleObject := GetRibbonAccessibilityHelper;

finalization
  dxBarGetRootAccessibleObject := nil;

  BarDesignController.UnregisterBarControlDesignHelper(
    TdxRibbonQuickAccessBarControl, TdxRibbonQuickAccessBarControlDesignHelper);
  BarDesignController.UnregisterBarControlDesignHelper(
    TdxRibbonGroupBarControl, TdxRibbonGroupBarControlDesignHelper);
  dxBarUnregisterItem(TdxRibbonQuickAccessGroupButton);
  dxBarUnregisterItem(TdxRibbonQuickAccessPopupSubItemButton);
  dxBarUnregisterItem(TdxRibbonQuickAccessPopupSubItem);

  ReleaseHook(FMouseHook);

end.
