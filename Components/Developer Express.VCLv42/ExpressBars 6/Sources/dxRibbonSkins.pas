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

unit dxRibbonSkins;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ImgList, ExtCtrls, dxCore, cxClasses, cxGraphics, dxBarSkin, dxBar,
  dxBarSkinConsts, dxGDIPlusAPI, cxLookAndFeelPainters;

const
  //ribbon's form consts
  rfspActiveCaption              = 10000; //don't change order
  rfspInactiveCaption            = 10001;
  rfspActiveCaptionZoomed        = 10002;
  rfspInactiveCaptionZoomed      = 10003;
  rfspActiveCaptionLeftBorder    = 10004;
  rfspInactiveCaptionLeftBorder  = 10005;
  rfspActiveCaptionRightBorder   = 10006;
  rfspInactiveCaptionRightBorder = 10007;
  rfspActiveLeftBorder           = 10008;
  rfspInactiveLeftBorder         = 10009;
  rfspActiveRightBorder          = 10010;
  rfspInactiveRightBorder        = 10011;
  rfspActiveBottomBorder1        = 10012;
  rfspInactiveBottomBorder1      = 10013;
  rfspActiveBottomBorder2        = 10014;
  rfspInactiveBottomBorder2      = 10015;
  rfspActiveBottomBorder3        = 10016;
  rfspInactiveBottomBorder3      = 10017;
  rfspRibbonForm                 = 10018;

  //border icons
  rfspBorderIconHot              = 10020;
  rfspBorderIconPressed          = 10021;
  rfspBorderIconInactiveHot      = 10022;
  rfspMinimizeNormalIconGlyph    = 10023;
  rfspMinimizeHotIconGlyph       = 10024;
  rfspMinimizePressedIconGlyph   = 10025;
  rfspMinimizeInactiveIconGlyph  = 10026;
  rfspMaximizeNormalIconGlyph    = 10027;
  rfspMaximizeHotIconGlyph       = 10028;
  rfspMaximizePressedIconGlyph   = 10029;
  rfspMaximizeInactiveIconGlyph  = 10030;
  rfspCloseNormalIconGlyph       = 10031;
  rfspCloseHotIconGlyph          = 10032;
  rfspClosePressedIconGlyph      = 10033;
  rfspCloseInactiveIconGlyph     = 10034;
  rfspRestoreNormalIconGlyph     = 10035;
  rfspRestoreHotIconGlyph        = 10036;
  rfspRestorePressedIconGlyph    = 10037;
  rfspRestoreInactiveIconGlyph   = 10038;
  rfspHelpNormalIconGlyph        = 10039;
  rfspHelpHotIconGlyph           = 10040;
  rfspHelpPressedIconGlyph       = 10041;
  rfspHelpInactiveIconGlyph      = 10042;

  //ribbon skin consts
  rspTabNormal                   = 10043;
  rspTabHot                      = 10044;
  rspTabActive                   = 10045;
  rspTabActiveHot                = 10046;
  rspTabFocused                  = 10047;
  rspTabGroupsArea               = 10048;
  rspTabSeparator                = 10049;

  rspQATDefaultGlyph             = 10052;
  rspQATAtBottom                 = 10053;
  rspRibbonClientTopArea         = 10054;

  rspQATNonClientLeft1Vista      = 10055;
  rspQATNonClientLeft2Vista      = 10056;
  rspQATNonClientRightVista      = 10057;
  rspQATPopup                    = 10058;

  rspQATNonClientLeft1Active     = 10059;
  rspQATNonClientLeft1Inactive   = 10060;
  rspQATNonClientLeft2Active     = 10061;
  rspQATNonClientLeft2Inactive   = 10062;
  rspQATNonClientRightActive     = 10063;
  rspQATNonClientRightInactive   = 10064;

  rspRibbonBackground            = 10065;
  rspRibbonBottomEdge            = 10066;

  rspApplicationButtonNormal     = 10067;
  rspApplicationButtonHot        = 10068;
  rspApplicationButtonPressed    = 10069;

  rspApplicationMenuBorder       = 10070;
  rspApplicationMenuContentHeader= 10071;
  rspApplicationMenuContentFooter= 10072;
  rspDropDownBorder              = 10073;
  rspMenuContent                 = 10074;
  rspMenuGlyph                   = 10075;
  rspMenuMark                    = 10076;
  rspMenuSeparatorHorz           = 10077;
  rspMenuSeparatorVert           = 10078;
  rspMenuArrowDown               = 10079;
  rspMenuArrowRight              = 10080;
  rspProgressSolidBand           = 10081;
  rspProgressDiscreteBand        = 10082;
  rspProgressSubstrate           = 10083;
  rspButtonGroupBorderLeft       = 10084;
  rspButtonGroupBorderRight      = 10085;
  rspScrollArrow                 = 10086;
  rspScreenTip                   = 10087;
  rspHelpButton                  = 10088;
  rspApplicationMenuButton       = 10089;

  rspStatusBar                   = 10090;
  rspStatusBarPanel              = 10091;
  rspStatusBarPanelLowered       = 10092;
  rspStatusBarPanelRaised        = 10093;
  rspStatusBarPanelSeparator     = 10094;
  rspStatusBarGripBackground     = 10095;
  rspStatusBarToolbarSeparator   = 10096;
  rspStatusBarSizeGripColor1     = 10098;
  rspStatusBarSizeGripColor2     = 10099;
  rspStatusBarFormLeftPart       = 10100;
  rspStatusBarFormRightPart      = 10104;
  rspStatusBarFormLeftPartDialog = 10108;
  rspStatusBarFormRightPartDialog= 10112;

  rspDropDownGalleryTopSizingBand = 10120;
  rspDropDownGalleryBottomSizingBand = 10121;
  rspDropDownGalleryTopSizeGrip  = 10122;
  rspDropDownGalleryBottomSizeGrip = 10123;
  rspDropDownGalleryVerticalSizeGrip = 10124;
  rspGalleryFilterBand           = 10125;
  rspGalleryGroupHeader          = 10126;

  //ribbon font colors
  rspFormCaptionText             = 10130;
  rspDocumentNameText            = 10131;
  rspTabHeaderText               = 10132;
  rspTabGroupText                = 10133;
  rspTabGroupHeaderText          = 10134;
  rspStatusBarText               = 10138;

  //state's groups const
  rspQATGroupButtonActive        = 10200;
  rspQATGroupButtonInactive      = rspQATGroupButtonActive + DXBAR_STATESCOUNT;
  rspArrowDownNormal             = rspQATGroupButtonInactive + DXBAR_STATESCOUNT;
  rspMenuDetachCaptionNormal     = rspArrowDownNormal + DXBAR_STATESCOUNT;
  rspMenuCheckNormal             = rspMenuDetachCaptionNormal + DXBAR_STATESCOUNT;
  rspMenuCheckMarkNormal         = rspMenuCheckNormal + DXBAR_STATESCOUNT;
  rspMenuScrollAreaNormal        = rspMenuCheckMarkNormal + DXBAR_STATESCOUNT;

  rspCollapsedToolbarNormal = rspMenuScrollAreaNormal + DXBAR_STATESCOUNT;
  rspCollapsedToolbarGlyphBackgroundNormal = rspCollapsedToolbarNormal + DXBAR_STATESCOUNT;

  rspEditButtonNormal            = rspCollapsedToolbarGlyphBackgroundNormal + DXBAR_STATESCOUNT;

  rspSmallButtonNormal           = rspEditButtonNormal + DXBAR_STATESCOUNT;
  rspSmallButtonGlyphBackgroundNormal = rspSmallButtonNormal + DXBAR_STATESCOUNT;
  rspSmallButtonDropButtonNormal = rspSmallButtonGlyphBackgroundNormal + DXBAR_STATESCOUNT;

  rspLargeButtonNormal           = rspSmallButtonDropButtonNormal + DXBAR_STATESCOUNT;
  rspLargeButtonGlyphBackgroundNormal = rspLargeButtonNormal + DXBAR_STATESCOUNT;
  rspLargeButtonDropButtonNormal = rspLargeButtonGlyphBackgroundNormal + DXBAR_STATESCOUNT;

  rspButtonGroupNormal           = rspLargeButtonDropButtonNormal + DXBAR_STATESCOUNT;
  rspButtonGroupBorderMiddleNormal = rspButtonGroupNormal + DXBAR_STATESCOUNT;
  rspButtonGroupSplitButtonSeparatorNormal = rspButtonGroupBorderMiddleNormal + DXBAR_STATESCOUNT;

  rspToolbarNormal               = rspButtonGroupSplitButtonSeparatorNormal + DXBAR_STATESCOUNT;
  rspToolbarHeaderNormal         = rspToolbarNormal + DXBAR_STATESCOUNT;

  rspMarkArrowNormal             = rspToolbarHeaderNormal + DXBAR_STATESCOUNT;
  rspMarkTruncatedNormal         = rspMarkArrowNormal + DXBAR_STATESCOUNT;
  rspLaunchButtonBackgroundNormal= rspMarkTruncatedNormal + DXBAR_STATESCOUNT;
  rspLaunchButtonDefaultGlyphNormal = rspLaunchButtonBackgroundNormal + DXBAR_STATESCOUNT;

  rspTabScrollLeftButtonNormal   = rspLaunchButtonDefaultGlyphNormal + DXBAR_STATESCOUNT;
  rspTabScrollRightButtonNormal  = rspTabScrollLeftButtonNormal + DXBAR_STATESCOUNT;
  rspGroupScrollLeftButtonNormal = rspTabScrollRightButtonNormal + DXBAR_STATESCOUNT;
  rspGroupScrollRightButtonNormal= rspGroupScrollLeftButtonNormal + DXBAR_STATESCOUNT;

  rspInRibbonGalleryScrollBarLineUpButtonNormal = rspGroupScrollRightButtonNormal + DXBAR_STATESCOUNT;
  rspInRibbonGalleryScrollBarLineDownButtonNormal = rspInRibbonGalleryScrollBarLineUpButtonNormal + DXBAR_STATESCOUNT;
  rspInRibbonGalleryScrollBarDropDownButtonNormal = rspInRibbonGalleryScrollBarLineDownButtonNormal + DXBAR_STATESCOUNT;

  //next = rspGroupScrollRightButtonNormal + DXBAR_STATESCOUNT;

type
  TdxApplicationButtonState = (absNormal, absHot, absPressed);
  TdxBorderDrawIcon = (bdiMinimize, bdiMaximize, bdiRestore, bdiClose, bdiHelp);
  TdxBorderIconState = (bisNormal, bisHot, bisPressed, bisInactive, bisHotInactive);
  TdxInRibbonGalleryScrollBarButtonKind = (gsbkLineUp, gsbkLineDown, gsbkDropDown);
  TdxRibbonTabState = (rtsNormal, rtsHot, rtsActive, rtsActiveHot, rtsFocused);

  TdxRibbonFormData = packed record
    Active: Boolean;
    Bounds: TRect;
    Border: TBorderStyle;
    Handle: HWND;
    State: TWindowState;
    Style: TFormStyle;
    DontUseAero: Boolean;
  end;

  TTwoStateArray = array[Boolean] of Integer;
  TThreeStateArray = array[0..2] of Integer;
  TFourStateArray = array[0..3] of Integer;
  TStatesArray = array[0..DXBAR_STATESCOUNT-1] of Integer;

  TdxCustomRibbonSkin = class(TdxCustomBarSkin)
  private
    // form
    FCaption: TTwoStateArray;
    FCaptionZoomed: TTwoStateArray;
    FCaptionLeftBorder: TTwoStateArray;
    FCaptionRightBorder: TTwoStateArray;
    FLeftBorder: TTwoStateArray;
    FRightBorder: TTwoStateArray;
    FBottomBorderThin: TTwoStateArray;
    FBottomBorderThick: array[Boolean] of TTwoStateArray;
    FBorderIconGlyph: array[TdxBorderDrawIcon] of TFourStateArray;
    FBorderIcons: TThreeStateArray;
    FFormStatusBarLeftParts: array[Boolean] of TFourStateArray;
    FFormStatusBarRightParts: array[Boolean] of TFourStateArray;
    //quick access toolbar
    FQATAtTopLeft: array[Boolean] of TTwoStateArray;
    FQATAtTopRight: TTwoStateArray;
    FQATGlassAtTopLeft: array[Boolean] of Integer;
    FQATGlassAtTopRight: Integer;
    FQATAtBottom: Integer;
    FQATPopup: Integer;
    FQATDefaultGlyph: Integer;
    FRibbonTopArea: Integer;
    //
    FApplicationButton: TThreeStateArray;
    FApplicationMenuButton: Integer;
    FApplicationMenuBorder: Integer;
    FApplicationMenuContentHeader: Integer;
    FApplicationMenuContentFooter: Integer;
    FArrowsDown: TStatesArray;
    FMenuArrowRight: Integer;
    FMenuArrowDown: Integer;
    FEditButtons: TStatesArray;
    FCollapsedToolbars: TStatesArray;
    FCollapsedToolbarGlyphBackgrounds: TStatesArray;
    FDropDownGalleryBottomSizeGrip: Integer;
    FDropDownGalleryBottomSizingBand: Integer;
    FDropDownGalleryTopSizeGrip: Integer;
    FDropDownGalleryTopSizingBand: Integer;
    FDropDownGalleryVerticalSizeGrip: Integer;
    FGalleryFilterBand: Integer;
    FGalleryGroupHeader: Integer;
    FInRibbonGalleryScrollBarDropDownButton: TStatesArray;
    FInRibbonGalleryScrollBarLineDownButton: TStatesArray;
    FInRibbonGalleryScrollBarLineUpButton: TStatesArray;
    FMenuCheck: TStatesArray;
    FMenuCheckMark: TStatesArray;
    FMenuDetachCaption: TStatesArray;
    FMenuContent: Integer;
    FMenuGlyph: Integer;
    FMenuMark: Integer;
    FMenuSeparatorHorz: Integer;
    FMenuSeparatorVert: Integer;
    FMenuScrollArea: TStatesArray;
    FDropDownBorder: Integer;
    FLargeButtons: TStatesArray;
    FSmallButtons: TStatesArray;
    FLargeButtonGlyphBackgrounds: TStatesArray;
    FSmallButtonGlyphBackgrounds: TStatesArray;
    FLargeButtonDropButtons: TStatesArray;
    FSmallButtonDropButtons: TStatesArray;
    FButtonGroup: TStatesArray;
    FButtonGroupBorderLeft: Integer;
    FButtonGroupBorderMiddle: TStatesArray;
    FButtonGroupBorderRight: Integer;
    FButtonGroupSplitButtonSeparator: TStatesArray;
    FLaunchButtonBackgrounds: TStatesArray;
    FLaunchButtonDefaultGlyphs: TStatesArray;
    FProgressSolidBand: Integer;
    FProgressDiscreteBand: Integer;
    FProgressSubstrate: Integer;
    FScrollArrow: Integer;
    FToolbar: TStatesArray;
    FToolbarHeader: TStatesArray;

    FMarkArrow: TStatesArray;
    FMarkTruncated: TStatesArray;

    FTabScrollButtons: array[Boolean] of TThreeStateArray;
    FGroupScrollButtons: array[Boolean] of TThreeStateArray;
    FQATGroupButtonActive: TStatesArray;
    FQATGroupButtonInactive: TStatesArray;
    FHelpButton: Integer;

    FStatusBar: Integer;
    FStatusBarGripBackground: Integer;
    FStatusBarPanel: Integer;
    FStatusBarPanelLowered: Integer;
    FStatusBarPanelRaised: Integer;
    FStatusBarPanelSeparator: Integer;
    FStatusBarToolbarSeparator: Integer;
    FScreenTip: Integer;

    FTabIndex: array[TdxRibbonTabState] of Integer;
    FTabSeparator: Integer;
    FTabGroupsArea: Integer;

    FLowColors: Boolean;
    procedure InternalDrawPart(const AParts: TStatesArray; DC: HDC; const R: TRect; AState: Integer);
    procedure LoadThreeStateArray(ABitmap: GpBitmap; R: TRect; const Fixed: TRect;
      var AStateArray: TThreeStateArray; AStartID: Integer;
      AInterpolationMode: Integer = InterpolationModeDefault);
    procedure LoadCommonButtonParts(ABitmap: GpBitmap);
    procedure LoadCommonMenuParts(ABitmap: GpBitmap);
    procedure LoadCommonProgressParts(ABitmap: GpBitmap);
    procedure LoadInRibbonGalleryScrollBarParts(ABitmap: GpBitmap);
  protected
    function GetName: string; virtual; abstract;

    procedure DrawApplicationButtonLC(DC: HDC; const R: TRect;
      AState: TdxApplicationButtonState); virtual;
    procedure DrawApplicationMenuBorderLC(DC: HDC; const R: TRect); virtual;
    procedure DrawBlackArrow(DC: HDC; const R: TRect; AArrowDirection: TcxArrowDirection);
    procedure DrawFormBordersLC(DC: HDC; const ABordersWidth: TRect;
      ACaptionHeight: Integer; const AData: TdxRibbonFormData); virtual;
    procedure DrawFormBorderIconLC(DC: HDC; const R: TRect;
      AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState); virtual;
    procedure DrawFormCaptionLC(DC: HDC; const R: TRect;
      const AData: TdxRibbonFormData); virtual;

    procedure DrawDropDownGalleryVerticalSizeGrip(DC: HDC; const R: TRect);

    procedure LoadFormSkin;
    procedure LoadRibbonSkin;

    procedure LoadCommonRibbonSkinBitmap(out ABitmap: GpBitmap); virtual;
    procedure LoadCustomRibbonSkinBitmap(out ABitmap: GpBitmap); virtual; abstract;
    procedure LoadFormSkinBitmap(out ABitmap: GpBitmap); virtual; abstract;

    procedure LoadCommonControlSkinFromBitmap(ABitmap: GpBitmap); virtual;
    procedure LoadCustomControlSkinFromBitmap(ABitmap: GpBitmap); virtual;
    procedure LoadFormSkinFromBitmap(ABitmap: GpBitmap); virtual;

    procedure LoadApplicationButton(ABitmap: GpBitmap); virtual;
    procedure LoadBorderIcons(ABitmap: GpBitmap); virtual;
    procedure LoadCustomButtonParts(ABitmap: GpBitmap); virtual;
    procedure LoadCustomGroup(ABitmap: GpBitmap); virtual;
    procedure LoadCustomMenuParts(ABitmap: GpBitmap); virtual;
    procedure LoadCustomProgressParts(ABitmap: GpBitmap); virtual;
    procedure LoadCustomScrollArrow(ABitmap: GpBitmap); virtual;
    procedure LoadCustomScreenTip(ABitmap: GpBitmap); virtual;
    procedure LoadGallery(ABitmap: GpBitmap); virtual;
    procedure LoadTab(ABitmap: GpBitmap);
    procedure LoadScrollButtons(ABitmap: GpBitmap);
    procedure LoadCollapsedToolbar(ABitmap: GpBitmap);
    procedure LoadQAT(ABitmap: GpBitmap);
    procedure LoadStatusBar(ABitmap: GpBitmap);

    property LowColors: Boolean read FLowColors write FLowColors;
  public
    constructor Create;

    procedure LoadElementParts(ABitmap: GpBitmap;
      var AParts; const R: TRect; AID: Integer; const AFixedSize: TRect;
      const AImageIndexes: array of Byte; const APossibleStates: TdxByteSet;
      AIsTopDown: Boolean = True; AInterpolationMode: Integer = InterpolationModeDefault);

    procedure LoadBitmapFromStream(const AResName: string; out ABitmap: GpBitmap);
    procedure LoadElementPartsFromFile(const AFileName: string;
      var AParts; AID: Integer; const AFixedSize: TRect;
      const AImageIndexes: array of Byte; const APossibleStates: TdxByteSet);

    procedure DrawApplicationButton(DC: HDC; const R: TRect; AState: TdxApplicationButtonState); virtual;
    procedure DrawApplicationMenuButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawApplicationMenuBorder(DC: HDC; const R: TRect); virtual;
    procedure DrawApplicationMenuContentHeader(DC: HDC; const R: TRect); virtual;
    procedure DrawApplicationMenuContentFooter(DC: HDC; const R: TRect); virtual;
    procedure DrawArrowDown(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawMenuArrowDown(DC: HDC; const R: TRect); virtual;
    procedure DrawMenuArrowRight(DC: HDC; const R: TRect); virtual;
    procedure DrawButtonGroup(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawButtonGroupBorderLeft(DC: HDC; const R: TRect); virtual;
    procedure DrawButtonGroupBorderMiddle(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawButtonGroupBorderRight(DC: HDC; const R: TRect); virtual;
    procedure DrawButtonGroupSplitButtonSeparator(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawCollapsedToolbarBackground(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawCollapsedToolbarGlyphBackground(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawDropDownBorder(DC: HDC; const R: TRect); virtual;
    procedure DrawDropDownGalleryBackground(DC: HDC; const R: TRect); virtual;
    procedure DrawDropDownGalleryBottomSizeGrip(DC: HDC; const R: TRect); virtual;
    procedure DrawDropDownGalleryBottomSizingBand(DC: HDC; const R: TRect); virtual;
    procedure DrawDropDownGalleryBottomVerticalSizeGrip(DC: HDC; const R: TRect); virtual;
    procedure DrawDropDownGalleryTopSizeGrip(DC: HDC; const R: TRect); virtual;
    procedure DrawDropDownGalleryTopSizingBand(DC: HDC; const R: TRect); virtual;
    procedure DrawDropDownGalleryTopVerticalSizeGrip(DC: HDC; const R: TRect); virtual;
    procedure DrawEditArrowButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawEditButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawEditEllipsisButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawEditSpinDownButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawEditSpinUpButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawFormBorders(DC: HDC; const ABordersWidth: TRect;
      ACaptionHeight: Integer; const AData: TdxRibbonFormData); virtual;
    procedure DrawFormBorderIcon(DC: HDC; const R: TRect; AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState); virtual;
    procedure DrawFormCaption(DC: HDC; const R: TRect; const AData: TdxRibbonFormData); virtual;
    procedure DrawFormStatusBarPart(DC: HDC; const R: TRect; AIsLeft, AIsActive, AIsRaised, AIsRectangular: Boolean); virtual;
    procedure DrawHelpButton(DC: HDC; const R: TRect; AState: TdxBorderIconState); virtual;
    procedure DrawHelpButtonGlyph(DC: HDC; const R: TRect; AGlyph: TBitmap); virtual;
    procedure DrawGalleryFilterBandBackground(DC: HDC; const R: TRect); virtual;
    procedure DrawGalleryGroupHeaderBackground(DC: HDC; const R: TRect); virtual;
    procedure DrawGroupScrollButton(DC: HDC; const R: TRect; ALeft: Boolean; AState: Integer); virtual;
    procedure DrawInRibbonGalleryBackground(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawInRibbonGalleryScrollBarButton(DC: HDC; const R: TRect;
      AButtonKind: TdxInRibbonGalleryScrollBarButtonKind; AState: Integer); virtual;
    procedure DrawLargeButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawLargeButtonGlyphBackground(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawLargeButtonDropButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawLaunchButtonBackground(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawLaunchButtonDefaultGlyph(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawMDIButton(DC: HDC; const R: TRect; AButton: TdxBarMDIButton; AState: TdxBorderIconState); virtual;
    procedure DrawMDIButtonGlyph(DC: HDC; const R: TRect; AButton: TdxBarMDIButton; AState: TdxBorderIconState); virtual;
    procedure DrawMenuCheck(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawMenuCheckMark(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawMenuContent(DC: HDC; const R: TRect); virtual;
    procedure DrawMenuDetachCaption(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawMenuGlyph(DC: HDC; const R: TRect); virtual;
    procedure DrawMenuMark(DC: HDC; const R: TRect); virtual;
    procedure DrawMenuSeparatorHorz(DC: HDC; const R: TRect); virtual;
    procedure DrawMenuSeparatorVert(DC: HDC; const R: TRect); virtual;
    procedure DrawMenuScrollArea(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawProgressSolidBand(DC: HDC; const R: TRect); virtual;
    procedure DrawProgressSubstrate(DC: HDC; const R: TRect); virtual;
    procedure DrawProgressDiscreteBand(DC: HDC; const R: TRect); virtual;
    procedure DrawRibbonBackground(DC: HDC; const R: TRect); virtual;
    procedure DrawRibbonBottomBorder(DC: HDC; const R: TRect); virtual;
    procedure DrawRibbonClientTopArea(DC: HDC; const R: TRect); virtual;
    procedure DrawSmallButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawSmallButtonGlyphBackground(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawSmallButtonDropButton(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawScrollArrow(DC: HDC; const R: TRect); virtual;
    procedure DrawScreenTip(DC: HDC; const R: TRect); virtual;
    procedure DrawTab(DC: HDC; const R: TRect; AState: TdxRibbonTabState); virtual;
    procedure DrawTabGroupBackground(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawTabGroupHeaderBackground(DC: HDC; const R: TRect; AState: Integer); virtual;

    procedure DrawMarkArrow(DC: HDC; const R: TRect; AState: Integer); virtual;
    procedure DrawMarkTruncated(DC: HDC; const R: TRect; AState: Integer); virtual;

    procedure DrawTabGroupsArea(DC: HDC; const R: TRect); virtual;
    procedure DrawTabScrollButton(DC: HDC; const R: TRect; ALeft: Boolean; AState: Integer); virtual;
    procedure DrawTabSeparator(DC: HDC; const R: TRect; Alpha: Byte); virtual;
    procedure DrawQuickAccessToolbar(DC: HDC; const R: TRect;
      ABellow, ANonClientDraw, AHasApplicationButton, AIsActive, ADontUseAero: Boolean); virtual;
    procedure DrawQuickAccessToolbarDefaultGlyph(DC: HDC; const R: TRect); virtual;
    procedure DrawQuickAccessToolbarGroupButton(DC: HDC; const R: TRect;
      ABellow, ANonClientDraw, AIsActive: Boolean; AState: Integer); virtual;
    procedure DrawQuickAccessToolbarPopup(DC: HDC; const R: TRect); virtual;

    procedure DrawStatusBar(DC: HDC; const R: TRect); virtual;
    procedure DrawStatusBarGripBackground(DC: HDC; const R: TRect); virtual;
    procedure DrawStatusBarPanel(DC: HDC; const Bounds, R: TRect; AIsLowered: Boolean); virtual;
    procedure DrawStatusBarPanelSeparator(DC: HDC; const R: TRect); virtual;
    procedure DrawStatusBarSizeGrip(DC: HDC; const R: TRect); virtual;
    procedure DrawStatusBarToolbarSeparator(DC: HDC; const R: TRect); virtual;

    procedure CorrectApplicationMenuButtonGlyphBounds(var R: TRect); virtual;
    function GetApplicationMenuGlyphSize: TSize; virtual;
    function GetCaptionFontSize(ACurrentFontSize: Integer): Integer; virtual;
    function GetMenuSeparatorSize: Integer; virtual;
    function GetPartColor(APart: Integer; AState: Integer = 0): TColor; virtual;
    function GetPartContentOffsets(APart: Integer): TRect; virtual;
    function GetSkinName: string; virtual;
    function GetQuickAccessToolbarLeftIndent(AHasApplicationButton: Boolean;
      AUseAeroGlass: Boolean): Integer; virtual;
    function GetQuickAccessToolbarMarkButtonOffset(AHasApplicationButton: Boolean;
      ABelow: Boolean): Integer; virtual;
    function GetQuickAccessToolbarOverrideWidth(AHasApplicationButton: Boolean;
      AUseAeroGlass: Boolean): Integer; virtual;
    function GetQuickAccessToolbarRightIndent(AHasApplicationButton: Boolean): Integer; virtual;
    function GetStatusBarSeparatorSize: Integer; virtual;
    function GetWindowBordersWidth(AHasStatusBar: Boolean): TRect; virtual;
    function HasGroupTransparency: Boolean; virtual;
    function NeedDrawGroupScrollArrow: Boolean; virtual;
    //
    procedure UpdateBitsPerPixel;
  end;

  TdxBlueRibbonSkin = class(TdxCustomRibbonSkin)
  protected
    function GetName: string; override;
    procedure LoadCustomRibbonSkinBitmap(out ABitmap: GpBitmap); override;
    procedure LoadFormSkinBitmap(out ABitmap: GpBitmap); override;
  public
    procedure DrawRibbonBottomBorder(DC: HDC; const R: TRect); override;
    function GetPartColor(APart: Integer; AState: Integer = 0): TColor; override;
  end;

  { TdxBlackRibbonSkin }

  TdxBlackRibbonSkin = class(TdxCustomRibbonSkin)
  protected
    function GetName: string; override;
    procedure LoadCustomRibbonSkinBitmap(out ABitmap: GpBitmap); override;
    procedure LoadFormSkinBitmap(out ABitmap: GpBitmap); override;
  public
    procedure DrawRibbonBottomBorder(DC: HDC; const R: TRect); override;
    function GetPartColor(APart: Integer; AState: Integer = 0): TColor; override;
  end;

  { TdxSilverRibbonSkin }

  TdxSilverRibbonSkin = class(TdxBlackRibbonSkin)
  protected
    function GetName: string; override;
    procedure LoadCustomRibbonSkinBitmap(out ABitmap: GpBitmap); override;
    procedure LoadFormSkinBitmap(out ABitmap: GpBitmap); override;
  public
    procedure DrawRibbonBottomBorder(DC: HDC; const R: TRect); override;
    function GetPartColor(APart: Integer; AState: Integer = 0): TColor; override;
  end;

function IsRectangularFormBottom(const AData: TdxRibbonFormData): Boolean; {$IFDEF DELPHI9} inline; {$ENDIF}

implementation

uses
{$IFDEF DELPHI6}
  Types,
{$ENDIF}
  cxGeometry, dxOffice11, Math, cxDWMApi;

{$R 'skins.res' 'skins.rc'}

const
  DropDownGalleryVerticalSizeGripBitmapSize: TSize = (cx: 18; cy: 7);

function IsRectangularFormBottom(const AData: TdxRibbonFormData): Boolean;
begin
  Result := (AData.Border in [bsDialog, bsSingle, bsToolWindow]) or (AData.Style = fsMDIChild);
end;

procedure ExcludeClipRect(DC: HDC; const R: TRect);
begin
  Windows.ExcludeClipRect(DC, R.Left, R.Top, R.Right, R.Bottom);
end;

procedure DrawFrame(DC: HDC; const R: TRect; AColor, ABorderColor: TColor;
  const ABorders: TcxBorders = cxBordersAll; ABorderWidth: Integer = 1);
var
  ABrush: HBRUSH;
  ABounds, ABorderBounds: TRect;
  ABorder: TcxBorder;

  function GetBorderBounds: TRect;
  begin
    Result := R;
    with Result do
      case ABorder of
        bLeft:
          begin
            Right := Left + ABorderWidth;
            Inc(ABounds.Left, ABorderWidth);
          end;
        bTop:
          begin
            Bottom := Top + ABorderWidth;
            Inc(ABounds.Top, ABorderWidth);
          end;
        bRight:
          begin
            Left := Right - ABorderWidth;
            Dec(ABounds.Right, ABorderWidth);
          end;
        bBottom:
          begin
            Top := Bottom - ABorderWidth;
            Dec(ABounds.Bottom, ABorderWidth);
          end;
      end;
  end;

begin
  if cxRectIsEmpty(R) then Exit;
  ABounds := R;
  if ABorders <> [] then
  begin
    ABrush := CreateSolidBrush(ColorToRGB(ABorderColor));
    for ABorder := Low(ABorder) to High(ABorder) do
      if ABorder in ABorders then
      begin
        ABorderBounds := GetBorderBounds;
        if not cxRectIsEmpty(ABorderBounds) then
          FillRect(DC, ABorderBounds, ABrush);
      end;
    DeleteObject(ABrush);
  end;
  if AColor <> clNone then
    FillRectByColor(DC, ABounds, AColor);
end;

procedure OutError;
begin
  raise EdxException.Create('');
end;

{ TdxCustomRibbonSkin }

constructor TdxCustomRibbonSkin.Create;
begin
  inherited Create(GetName);
  LoadFormSkin;
  LoadRibbonSkin;
  UpdateBitsPerPixel;
end;

procedure TdxCustomRibbonSkin.LoadBitmapFromStream(const AResName: string;
  out ABitmap: GpBitmap);
var
  S: TStream;
begin
  S := TResourceStream.Create(HInstance, AResName, RT_RCDATA);
  try
    ABitmap := GetImageFromStream(S);
  finally
    S.Free;
  end;
end;

procedure TdxCustomRibbonSkin.LoadElementParts(ABitmap: GpBitmap;
  var AParts; const R: TRect; AID: Integer; const AFixedSize: TRect;
  const AImageIndexes: array of Byte; const APossibleStates: TdxByteSet;
  AIsTopDown: Boolean = True; AInterpolationMode: Integer = InterpolationModeDefault);
var
  I, J, AImageIndex: Integer;
  AOffsetSize: TSize;
  ALoadRect: TRect;
begin
  J := 0;
  if AIsTopDown then
  begin
    AOffsetSize.cx := 0;
    AOffsetSize.cy := cxRectHeight(R);
  end
  else
  begin
    AOffsetSize.cx := cxRectWidth(R);
    AOffsetSize.cy := 0;
  end;
  for I := Low(TStatesArray) to High(TStatesArray) do
  begin
    if (APossibleStates = []) or (I in APossibleStates) then
    begin
      if Length(AImageIndexes) = 0 then
        AImageIndex := J
      else
        if J < Length(AImageIndexes) then
          AImageIndex := AImageIndexes[J]
        else
          AImageIndex := 0;
      ALoadRect := cxRectOffset(R, AOffsetSize.cx * AImageIndex, AOffsetSize.cy * AImageIndex);
      Inc(J);
      if cxRectIsEqual(cxEmptyRect, AFixedSize) then
        TStatesArray(AParts)[I] := AddPart1x1(ABitmap, ALoadRect, AID, '', AInterpolationMode)
      else
        TStatesArray(AParts)[I] := AddPart3x3(ABitmap, ALoadRect, AFixedSize, AID, '', AInterpolationMode);
    end;
    Inc(AID);
  end;
end;

procedure TdxCustomRibbonSkin.LoadElementPartsFromFile(const AFileName: string;
  var AParts; AID: Integer; const AFixedSize: TRect;
  const AImageIndexes: array of Byte; const APossibleStates: TdxByteSet);
var
  ABitmap: GpGraphics;
  AImageRect: TRect;
begin
  if not CheckGdiPlus then Exit;
  GdipCheck(GdipLoadImageFromFile(PWideChar(WideString(AFileName)), ABitmap));
  AImageRect.Left := 0;
  AImageRect.Top := 0;
  GdipCheck(GdipGetImageWidth(ABitmap, AImageRect.Right));
  GdipCheck(GdipGetImageHeight(ABitmap, AImageRect.Bottom));
  LoadElementParts(ABitmap, AParts, AImageRect, AID, AFixedSize, AImageIndexes,
    APossibleStates);
  GdipDisposeImage(ABitmap);
end;

//  DRAWING

procedure TdxCustomRibbonSkin.DrawApplicationButton(DC: HDC; const R: TRect;
  AState: TdxApplicationButtonState);
begin
  if LowColors then
    DrawApplicationButtonLC(DC, R, AState)
  else
    Parts[FApplicationButton[Ord(AState)]].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawApplicationMenuButton(DC: HDC; const R: TRect; AState: Integer);
begin
  if AState = DXBAR_HOT then
    InternalDrawPart(FSmallButtons, DC, R, AState)
  else
    Parts[FApplicationMenuButton].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawApplicationMenuBorder(DC: HDC; const R: TRect);
begin
  if LowColors then
    DrawApplicationMenuBorderLC(DC, R)
  else
    Parts[FApplicationMenuBorder].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawApplicationMenuContentHeader(DC: HDC; const R: TRect);
begin
  if LowColors then
    FillRectByColor(DC, R, clMenu)
  else
    Parts[FApplicationMenuContentHeader].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawApplicationMenuContentFooter(DC: HDC; const R: TRect);
begin
  if LowColors then
    FillRectByColor(DC, R, clMenu)
  else
    Parts[FApplicationMenuContentFooter].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawArrowDown(DC: HDC; const R: TRect; AState: Integer);
begin
  if FLowColors then
    DrawBlackArrow(DC, R, adDown)
  else
    InternalDrawPart(FArrowsDown, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawMenuArrowDown(DC: HDC; const R: TRect);
begin
  if FLowColors then
    DrawBlackArrow(DC, R, adDown)
  else
    Parts[FMenuArrowDown].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawMenuArrowRight(DC: HDC; const R: TRect);
begin
  if FLowColors then
    DrawBlackArrow(DC, R, adRight)
  else
    Parts[FMenuArrowRight].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawButtonGroup(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FButtonGroup, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawButtonGroupBorderLeft(DC: HDC; const R: TRect);
begin
  if not LowColors then
    Parts[FButtonGroupBorderLeft].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawButtonGroupBorderMiddle(DC: HDC; const R: TRect; AState: Integer);
begin
  if not LowColors then
    InternalDrawPart(FButtonGroupBorderMiddle, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawButtonGroupBorderRight(DC: HDC; const R: TRect);
begin
  if not LowColors then
    Parts[FButtonGroupBorderRight].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawButtonGroupSplitButtonSeparator(DC: HDC; const R: TRect; AState: Integer);
begin
  if not LowColors then
    InternalDrawPart(FButtonGroupSplitButtonSeparator, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawCollapsedToolbarBackground(DC: HDC;
  const R: TRect; AState: Integer);
begin
  if LowColors then
    InternalDrawPart(FCollapsedToolbars, DC, R, AState)
  else
    case AState of
      0, 2, 3, 4: Parts[FCollapsedToolbars[AState]].Draw(DC, R);
    else
      Parts[FCollapsedToolbars[0]].Draw(DC, R);
    end;
end;

procedure TdxCustomRibbonSkin.DrawCollapsedToolbarGlyphBackground(DC: HDC;
  const R: TRect; AState: Integer);
begin
  InternalDrawPart(FCollapsedToolbarGlyphBackgrounds, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawDropDownBorder(DC: HDC; const R: TRect);
begin
  Parts[FDropDownBorder].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawDropDownGalleryBackground(DC: HDC; const R: TRect);
begin
  FillRectByColor(DC, R, GetPartColor(DXBAR_DROPDOWNGALLERY, DXBAR_NORMAL));
end;

procedure TdxCustomRibbonSkin.DrawDropDownGalleryBottomSizeGrip(DC: HDC;
  const R: TRect);
var
  ARect: TRect;
begin
  ARect := cxRectInflate(R, 0, -3, -2, -1);
  ARect.Left := ARect.Right - cxRectHeight(ARect);
  Parts[FDropDownGalleryBottomSizeGrip].Draw(DC, ARect);
end;

procedure TdxCustomRibbonSkin.DrawDropDownGalleryBottomSizingBand(DC: HDC;
  const R: TRect);
begin
  Parts[FDropDownGalleryBottomSizingBand].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawDropDownGalleryBottomVerticalSizeGrip(DC: HDC;
  const R: TRect);
begin
  DrawDropDownGalleryVerticalSizeGrip(DC, Rect(R.Left, R.Top + 1, R.Right, R.Bottom));
end;

procedure TdxCustomRibbonSkin.DrawDropDownGalleryTopSizeGrip(DC: HDC;
  const R: TRect);
var
  ARect: TRect;
begin
  ARect := cxRectInflate(R, 0, -1, -2, -3);
  ARect.Left := ARect.Right - cxRectHeight(ARect);
  Parts[FDropDownGalleryTopSizeGrip].Draw(DC, ARect);
end;

procedure TdxCustomRibbonSkin.DrawDropDownGalleryTopSizingBand(DC: HDC;
  const R: TRect);
begin
  Parts[FDropDownGalleryTopSizingBand].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawDropDownGalleryTopVerticalSizeGrip(DC: HDC;
  const R: TRect);
begin
  DrawDropDownGalleryVerticalSizeGrip(DC, Rect(R.Left, R.Top, R.Right, R.Bottom - 1));
end;

procedure TdxCustomRibbonSkin.DrawEditArrowButton(DC: HDC; const R: TRect; AState: Integer);
begin
  // do nothing
end;

procedure TdxCustomRibbonSkin.DrawEditButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FEditButtons, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawEditEllipsisButton(DC: HDC; const R: TRect; AState: Integer);
begin
  // do nothing
end;

procedure TdxCustomRibbonSkin.DrawEditSpinDownButton(DC: HDC; const R: TRect; AState: Integer);
begin
  // do nothing
end;

procedure TdxCustomRibbonSkin.DrawEditSpinUpButton(DC: HDC; const R: TRect; AState: Integer);
begin
  // do nothing
end;

procedure TdxCustomRibbonSkin.DrawFormBorders(DC: HDC;
  const ABordersWidth: TRect; ACaptionHeight: Integer;
  const AData: TdxRibbonFormData);
var
  R: TRect;
  ARectangularBottom: Boolean;
begin
  if LowColors then
    DrawFormBordersLC(DC, ABordersWidth, ACaptionHeight, AData)
  else
  begin
    //catpion borders
    if ACaptionHeight > 0 then
    begin
      R := AData.Bounds;
      R.Bottom := ACaptionHeight;
      R.Right := R.Left + ABordersWidth.Left;
      Parts[FCaptionLeftBorder[not AData.Active]].Draw(DC, R);
      R.Right := AData.Bounds.Right;
      R.Left := R.Right - ABordersWidth.Right;
      Parts[FCaptionRightBorder[not AData.Active]].Draw(DC, R)
    end;
    ARectangularBottom := IsRectangularFormBottom(AData);
    if ABordersWidth.Bottom > 1 then
    begin
      R := AData.Bounds;
      R.Top := R.Bottom - ABordersWidth.Bottom;
      Parts[FBottomBorderThick[ARectangularBottom][not AData.Active]].Draw(DC, R);
      ExcludeClipRect(DC, R);
    end
    else
    begin
      R := AData.Bounds;
      R.Top := R.Bottom - ABordersWidth.Bottom;
      Inc(R.Left, ABordersWidth.Left);
      Dec(R.Right, ABordersWidth.Right);
      Parts[FBottomBorderThin[not AData.Active]].Draw(DC, R);
    end;
    R := AData.Bounds;
    if not ARectangularBottom then
      Dec(R.Bottom);
    R.Top := ACaptionHeight + ABordersWidth.Top;
    R.Right := R.Left + ABordersWidth.Left;
    Parts[FLeftBorder[not AData.Active]].Draw(DC, R);
    R.Right := AData.Bounds.Right;
    R.Left := R.Right - ABordersWidth.Right;
    Parts[FRightBorder[not AData.Active]].Draw(DC, R);
  end;
end;

procedure TdxCustomRibbonSkin.DrawFormBorderIcon(DC: HDC; const R: TRect;
  AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState);
var
  APart: Integer;
  GR: TRect;
begin
  if LowColors then
    DrawFormBorderIconLC(DC, R, AIcon, AState)
  else
  begin
    case AState of
      bisHot: APart := 0;
      bisPressed: APart := 1;
      bisHotInactive: APart := 2;
    else
      APart := -1;
    end;
    if APart >= 0 then
      Parts[FBorderIcons[APart]].Draw(DC, R);
    GR := cxRectBounds(R.Left, R.Top, 9, 9);
    OffsetRect(GR, (R.Right - R.Left - 9) div 2, (R.Bottom - R.Top - 9) div 2 + 1);

    case AState of
      bisHot: APart := 1;
      bisPressed: APart := 2;
      bisInactive: APart := 3;
      bisHotInactive: APart := 3;
    else
      APart := 0;
    end;
    Parts[FBorderIconGlyph[AIcon][APart]].Draw(DC, GR);
  end;
end;

procedure TdxCustomRibbonSkin.DrawFormCaption(DC: HDC; const R: TRect;
  const AData: TdxRibbonFormData);
var
  ARect: TRect;
begin
  if LowColors then
    DrawFormCaptionLC(DC, R, AData)
  else
  begin
    if AData.State = wsMaximized then
      Parts[FCaptionZoomed[not AData.Active]].Draw(DC, R)
    else if AData.State = wsMinimized then
    begin
      ARect := R;
      Dec(ARect.Bottom, 1);
      Parts[FCaption[not AData.Active]].Draw(DC, ARect);
      ARect := R;
      ARect.Top := ARect.Bottom - 1;
      Parts[FBottomBorderThin[not AData.Active]].Draw(DC, ARect);
    end
    else
      Parts[FCaption[not AData.Active]].Draw(DC, R);
  end;
end;

procedure TdxCustomRibbonSkin.DrawFormStatusBarPart(DC: HDC; const R: TRect;
  AIsLeft, AIsActive, AIsRaised, AIsRectangular: Boolean);
var
  APart: Integer;
begin
  if LowColors then
    FillRectByColor(DC, R, clBtnFace)
  else
  begin
    APart := 0;
    Inc(APart, Ord(AIsRaised));
    Inc(APart, Ord(not AIsActive) * 2);
    if AIsLeft then
      Parts[FFormStatusBarLeftParts[AIsRectangular][APart]].Draw(DC, R)
    else
      Parts[FFormStatusBarRightParts[AIsRectangular][APart]].Draw(DC, R);
  end;
end;

procedure TdxCustomRibbonSkin.DrawHelpButton(DC: HDC; const R: TRect;
  AState: TdxBorderIconState);
var
  APart: Integer;
begin
  case AState of
    bisHot: APart := DXBAR_HOT;
    bisPressed: APart := DXBAR_PRESSED;
  else
    APart := DXBAR_NORMAL;
  end;
  if APart = DXBAR_NORMAL then
    FillRectByColor(DC, R, GetPartColor(rspRibbonBackground))
  else
    DrawSmallButton(DC, R, APart);
end;

procedure TdxCustomRibbonSkin.DrawHelpButtonGlyph(DC: HDC; const R: TRect;
  AGlyph: TBitmap);
var
  GR: TRect;
begin
  GR := cxRectBounds(R.Left, R.Top, 16, 16);
  OffsetRect(GR, (R.Right - R.Left - 16) div 2, (R.Bottom - R.Top - 16) div 2);
  Parts[FHelpButton].Draw(DC, GR);
end;

procedure TdxCustomRibbonSkin.DrawGalleryFilterBandBackground(DC: HDC;
  const R: TRect);
begin
  Parts[FGalleryFilterBand].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawGalleryGroupHeaderBackground(DC: HDC; const R: TRect);
begin
  Parts[FGalleryGroupHeader].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawGroupScrollButton(DC: HDC; const R: TRect; ALeft: Boolean; AState: Integer);
var
  I: Integer;
begin
  case AState of
    DXBAR_HOT: I := 1;
    DXBAR_PRESSED: I := 2;
  else
    I := 0;
  end;
  Parts[FGroupScrollButtons[ALeft][I]].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawInRibbonGalleryBackground(DC: HDC;
  const R: TRect; AState: Integer);
begin
  DrawFrame(DC, R, GetPartColor(DXBAR_INRIBBONGALLERY_BACKGROUND, AState),
    GetPartColor(DXBAR_INRIBBONGALLERY_BORDER, AState));
end;

procedure TdxCustomRibbonSkin.DrawInRibbonGalleryScrollBarButton(DC: HDC;
  const R: TRect; AButtonKind: TdxInRibbonGalleryScrollBarButtonKind;
  AState: Integer);
begin
  case AButtonKind of
    gsbkLineUp:
      InternalDrawPart(FInRibbonGalleryScrollBarLineUpButton, DC, R, AState);
    gsbkLineDown:
      InternalDrawPart(FInRibbonGalleryScrollBarLineDownButton, DC, R, AState);
    gsbkDropDown:
      InternalDrawPart(FInRibbonGalleryScrollBarDropDownButton, DC, R, AState);
  end;
end;

procedure TdxCustomRibbonSkin.DrawLargeButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FLargeButtons, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawLargeButtonGlyphBackground(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FLargeButtonGlyphBackgrounds, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawLargeButtonDropButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FLargeButtonDropButtons, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawLaunchButtonBackground(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FLaunchButtonBackgrounds, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawLaunchButtonDefaultGlyph(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FLaunchButtonDefaultGlyphs, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawMDIButton(DC: HDC; const R: TRect;
  AButton: TdxBarMDIButton; AState: TdxBorderIconState);
var
  APart: Integer;
begin
  case AState of
    bisHot: APart := DXBAR_HOT;
    bisPressed: APart := DXBAR_PRESSED;
  else
    APart := DXBAR_NORMAL;
  end;
  if APart = DXBAR_NORMAL then
    FillRectByColor(DC, R, GetPartColor(rspRibbonBackground))
  else
    DrawSmallButton(DC, R, APart);
end;

procedure TdxCustomRibbonSkin.DrawMDIButtonGlyph(DC: HDC; const R: TRect;
  AButton: TdxBarMDIButton; AState: TdxBorderIconState);
var
  APart: Integer;
  GR: TRect;
  AIcon: TdxBorderDrawIcon;
begin
  GR := cxRectBounds(R.Left, R.Top, 9, 9);
  OffsetRect(GR, (R.Right - R.Left - 9) div 2, (R.Bottom - R.Top - 9) div 2 + 1);
  case AButton of
    mdibMinimize: AIcon := bdiMinimize;
    mdibRestore: AIcon := bdiRestore;
  else
    AIcon := bdiClose;
  end;
  case AState of
    bisHot: APart := 1;
    bisPressed: APart := 2;
    bisInactive: APart := 3;
  else
    APart := 0;
  end;
  Parts[FBorderIconGlyph[AIcon][APart]].Draw(DC, GR);
end;

procedure TdxCustomRibbonSkin.DrawMenuCheck(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FMenuCheck, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawMenuCheckMark(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FMenuCheckMark, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawMenuContent(DC: HDC; const R: TRect);
begin
  Parts[FMenuContent].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawMenuDetachCaption(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FMenuDetachCaption, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawMenuGlyph(DC: HDC; const R: TRect);
begin
  Parts[FMenuGlyph].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawMenuMark(DC: HDC; const R: TRect);
begin
  Parts[FMenuMark].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawMenuSeparatorHorz(DC: HDC; const R: TRect);
begin
  Parts[FMenuSeparatorHorz].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawMenuSeparatorVert(DC: HDC; const R: TRect);
begin
  Parts[FMenuSeparatorVert].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawMenuScrollArea(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FMenuScrollArea, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawProgressSolidBand(DC: HDC; const R: TRect);
begin
  Parts[FProgressSolidBand].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawProgressSubstrate(DC: HDC; const R: TRect);
begin
  Parts[FProgressSubstrate].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawProgressDiscreteBand(DC: HDC; const R: TRect);
begin
  Parts[FProgressDiscreteBand].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawRibbonBackground(DC: HDC; const R: TRect);
begin
  FillRectByColor(DC, R, GetPartColor(rspRibbonBackground));
end;

procedure TdxCustomRibbonSkin.DrawRibbonBottomBorder(DC: HDC; const R: TRect);
begin
end;

procedure TdxCustomRibbonSkin.DrawRibbonClientTopArea(DC: HDC; const R: TRect);
begin
  Parts[FRibbonTopArea].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawSmallButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FSmallButtons, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawSmallButtonGlyphBackground(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FSmallButtonGlyphBackgrounds, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawSmallButtonDropButton(DC: HDC; const R: TRect; AState: Integer);
begin
  InternalDrawPart(FSmallButtonDropButtons, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawScrollArrow(DC: HDC; const R: TRect);
begin
  Parts[FScrollArrow].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawScreenTip(DC: HDC; const R: TRect);
begin
  Parts[FScreenTip].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawTab(DC: HDC; const R: TRect; AState: TdxRibbonTabState);
begin
  if LowColors then
  begin
    case AState of
      rtsNormal: FillRectByColor(DC, R, clBtnFace);
      rtsActive: DrawFrame(DC, R, clHighlight, clWhite, [bLeft, bTop, bRight]);
    else
      DrawFrame(DC, R, clHighlight, clBtnFace, [bTop]);
    end;
  end
  else
    Parts[FTabIndex[AState]].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawTabGroupBackground(DC: HDC; const R: TRect; AState: Integer);
begin
  if LowColors then
    DrawFrame(DC, R, clBtnFace, clBtnShadow, [bTop, bLeft, bRight])
  else
    InternalDrawPart(FToolbar, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawTabGroupHeaderBackground(DC: HDC; const R: TRect; AState: Integer);
var
  R1: TRect;
begin
  if LowColors then
  begin
    R1 := cxRect(R.Left + 4, R.Top, R.Right - 4, R.Top + 1);
    FillRectByColor(DC, R1, clBtnShadow);
    ExcludeClipRect(DC, R1);
    DrawFrame(DC, R, clBtnFace, clBtnShadow, [bBottom, bLeft, bRight]);
  end
  else
    InternalDrawPart(FToolbarHeader, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawMarkArrow(DC: HDC; const R: TRect; AState: Integer);
var
  H: Integer;
begin
  H := (R.Bottom - R.Top) div 7;
  InternalDrawPart(FMarkArrow, DC,
    cxRect(R.Left + 3, R.Top + H * 3, R.Right - 3, R.Bottom - H * 2), AState);
end;

procedure TdxCustomRibbonSkin.DrawMarkTruncated(DC: HDC; const R: TRect; AState: Integer);
var
  H: Integer;
begin
  H := (R.Bottom - R.Top) div 7;
  InternalDrawPart(FMarkTruncated, DC,
    cxRect(R.Left + H + 1, R.Top + H * 3, R.Right - H + 1, R.Bottom - H * 2), AState);
end;

procedure TdxCustomRibbonSkin.DrawTabGroupsArea(DC: HDC; const R: TRect);
begin
  if LowColors then
    DrawFrame(DC, R, clBtnFace, clBtnShadow)
  else
    Parts[FTabGroupsArea].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawTabScrollButton(DC: HDC; const R: TRect;
  ALeft: Boolean; AState: Integer);
var
  I: Integer;
begin
  case AState of
    DXBAR_HOT: I := 1;
    DXBAR_PRESSED: I := 2;
  else
    I := 0;
  end;
  Parts[FTabScrollButtons[ALeft][I]].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawTabSeparator(DC: HDC; const R: TRect; Alpha: Byte);
begin
  Parts[FTabSeparator].Draw(DC, R, Alpha);
end;

procedure TdxCustomRibbonSkin.DrawQuickAccessToolbar(DC: HDC;
  const R: TRect; ABellow, ANonClientDraw, AHasApplicationButton, AIsActive, ADontUseAero: Boolean);
var
  W, ALeftPart, ARightPart: Integer;
  R1: TRect;
  AInactive: Boolean;
begin
  if not ABellow then
  begin
    AInactive := ANonClientDraw and not AIsActive;
    W := (R.Bottom - R.Top) div 2;
    if R.Right - W - R.Left < W then Exit;
    R1 := cxRectInflate(R, 0, -3, 0, -4);
    if AHasApplicationButton then
      R1.Right := R1.Left + 15
    else
      R1.Right := R1.Left + 7;
    ALeftPart := FQATAtTopLeft[AHasApplicationButton][AInactive];
    ARightPart := FQATAtTopRight[AInactive];
    if ANonClientDraw then
    begin
      if IsCompositionEnabled and not ADontUseAero then
      begin
        ALeftPart := FQATGlassAtTopLeft[AHasApplicationButton];
        ARightPart := FQATGlassAtTopRight;
      end;
      OffsetRect(R1, 0, 1);
    end;
    Parts[ALeftPart].Draw(DC, R1);
    R1.Left := R1.Right;
    R1.Right := R.Right - W;
    Parts[ARightPart].Draw(DC, R1);
  end
  else
    Parts[FQATAtBottom].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawQuickAccessToolbarDefaultGlyph(DC: HDC;
  const R: TRect);
begin
  if FLowColors then
  begin
    FillRectByColor(DC, R, clBtnFace);
  end
  else
    Parts[FQATDefaultGlyph].Draw(DC, R);
end; 

procedure TdxCustomRibbonSkin.DrawQuickAccessToolbarGroupButton(DC: HDC;
  const R: TRect; ABellow, ANonClientDraw, AIsActive: Boolean; AState: Integer);
begin
  if ABellow or ANonClientDraw and not AIsActive then
    InternalDrawPart(FQATGroupButtonInactive, DC, R, AState)
  else
    InternalDrawPart(FQATGroupButtonActive, DC, R, AState);
end;

procedure TdxCustomRibbonSkin.DrawQuickAccessToolbarPopup(DC: HDC; const R: TRect);
begin
  if FLowColors then
    FillRectByColor(DC, R, clBtnFace)
  else
    Parts[FQATPopup].Draw(DC, R)
end;

procedure TdxCustomRibbonSkin.DrawStatusBar(DC: HDC; const R: TRect);
begin
  if FLowColors then
    FillRectByColor(DC, R, clBtnFace)
  else
    Parts[FStatusBar].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawStatusBarGripBackground(DC: HDC; const R: TRect);
begin
  if FLowColors then
    FillRectByColor(DC, R, clBtnFace)
  else
    Parts[FStatusBarGripBackground].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawStatusBarPanel(DC: HDC; const Bounds, R: TRect;
  AIsLowered: Boolean);
begin
  if FLowColors then
    FillRectByColor(DC, R, clBtnFace)
  else
  begin
    //todo:
    if AIsLowered then
      Parts[FStatusBarPanelLowered].Draw(DC, R)
    else
      Parts[FStatusBarPanelRaised].Draw(DC, R);
  end;
end;

procedure TdxCustomRibbonSkin.DrawStatusBarPanelSeparator(DC: HDC;
  const R: TRect);
begin
  if FLowColors then
  begin
    FillRectByColor(DC, R, clBtnFace);
    FillRectByColor(DC, cxRect(R.Left, R.Top + 1, R.Left + 1, R.Bottom - 1), clBtnShadow);
  end
  else
    Parts[FStatusBarPanelSeparator].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.DrawStatusBarSizeGrip(DC: HDC; const R: TRect);
begin
  Office11DrawSizeGrip(DC, R, GetPartColor(rspStatusBarSizeGripColor1),
    GetPartColor(rspStatusBarSizeGripColor2));
end;

procedure TdxCustomRibbonSkin.DrawStatusBarToolbarSeparator(DC: HDC; const R: TRect);
begin
  if FLowColors then
  begin
    FillRectByColor(DC, R, clBtnFace);
    FillRectByColor(DC, cxRect(R.Left, R.Top, R.Left + 1, R.Bottom - 1), clBtnShadow);
  end
  else
    Parts[FStatusBarToolbarSeparator].Draw(DC, R);
end;

procedure TdxCustomRibbonSkin.CorrectApplicationMenuButtonGlyphBounds(var R: TRect);
begin
  OffsetRect(R, -1, -1);
end;

function TdxCustomRibbonSkin.GetApplicationMenuGlyphSize: TSize;
begin
  Result := cxSize(42, 42);
end;

function TdxCustomRibbonSkin.GetSkinName: string;
begin
  Result := '';
end;

function TdxCustomRibbonSkin.GetCaptionFontSize(ACurrentFontSize: Integer): Integer;
begin
  Result := ACurrentFontSize;
end;

function TdxCustomRibbonSkin.GetMenuSeparatorSize: Integer;
begin
  Result := 2;
end;

function TdxCustomRibbonSkin.GetPartColor(APart: Integer; AState: Integer = 0): TColor;
begin
  Result := clDefault;
  if LowColors then
  begin
    case APart of
      //!!!TODO:
      DXBAR_APPLICATIONMENUCONTENTSIDES: Result := $EDD3BE;
      DXBAR_APPLICATIONMENUCONTENTOUTERBORDER: Result := clWhite;
      DXBAR_APPLICATIONMENUCONTENTINNERBORDER: Result := $CAAF9B;
      DXBAR_MENUEDITSEPARATOR:
        case AState of
          DXBAR_ACTIVE:  Result := $85B6CA;
          DXBAR_ACTIVEDISABLED:  Result := $CDCDCD;
        end;
      DXBAR_SCREENTIP_FOOTERLINE:
        Result := $DDBB9E;
      DXBAR_DATENAVIGATOR_HEADER:
        Result := $DAD5D2;
      DXBAR_SEPARATOR_BACKGROUND:
        Result := $EFE7DE;
      rspRibbonBottomEdge:
        Result := $F3E2D5;
      DXBAR_EDIT_BORDER, DXBAR_EDIT_BUTTON_BORDER:
        case AState of
          DXBAR_NORMAL, DXBAR_DISABLED: Result := clBtnShadow;
        else
          Result := clWhite;
        end;
      DXBAR_EDIT_BACKGROUND:
        Result := clBtnFace;
      rspFormCaptionText, rspDocumentNameText:
        if AState = DXBAR_NORMAL then
          Result := clCaptionText
        else
          Result := clInactiveCaptionText;
      rspTabHeaderText:
        if AState = DXBAR_NORMAL then
          Result := clWindowText
        else
          Result := clHighlightText;
      rspTabGroupHeaderText:
        Result := clWindowText;
      DXBAR_ITEMTEXT, rspTabGroupText, rspStatusBarText:
        case AState of
          DXBAR_NORMAL:
            Result := clWindowText;
          DXBAR_DISABLED:
            Result := clGrayText;
          else
            Result := clHighlightText;
        end;
      DXBAR_MENUITEMTEXT, DXBAR_GALLERYGROUPHEADERTEXT:
        case AState of
          DXBAR_NORMAL:
            Result := clMenuText;
          DXBAR_DISABLED:
            Result := clGrayText;
          else
            Result := clHighlightText;
        end;
      DXBAR_GALLERYGROUPITEM_OUTERBORDER, DXBAR_GALLERYGROUPITEM_INNERBORDER:
        Result := clHighlight;
      rfspRibbonForm:
        Result := clBtnShadow;
    else
      Result := clBtnFace;
    end;
    Result := ColorToRGB(Result);
  end
  else
    case APart of
      DXBAR_GALLERYGROUPHEADERTEXT: Result := GetPartColor(DXBAR_MENUITEMTEXT);
      DXBAR_MENUEXTRAPANE: Result := $EEEAE9;
      DXBAR_MENUARROWSEPARATOR: Result := $BDB6A5;
      DXBAR_MENUDETACHCAPTIONAREA: Result := $F7F7F7;
      DXBAR_MENUITEMTEXT:
        if AState in [DXBAR_DISABLED, DXBAR_ACTIVEDISABLED] then
          Result := $A7A7A7;
      DXBAR_ITEMTEXT:
        case AState of
          DXBAR_DISABLED, DXBAR_ACTIVEDISABLED: Result := $8D8D8D;
        else
          Result := GetPartColor(rspTabGroupText);
        end;
      DXBAR_DROPDOWNGALLERY: Result := $FAFAFA;
      DXBAR_DROPDOWNBORDER_INNERLINE: Result := $F5F5F5;
      DXBAR_GALLERYGROUPITEM_OUTERBORDER:
        case AState of
          DXBAR_HOT: Result := $3694F2;
          DXBAR_CHECKED: Result := $1048EF;
          DXBAR_HOTCHECK: Result := $3695F2;
        end;
      DXBAR_GALLERYGROUPITEM_INNERBORDER:
        case AState of
          DXBAR_HOT: Result := $94E2FF;
          DXBAR_CHECKED: Result := $94E2FF;
          DXBAR_HOTCHECK: Result := $95E3FF;
        end;
    end;
end;

function TdxCustomRibbonSkin.GetPartContentOffsets(APart: Integer): TRect;
begin
  Result := cxNullRect;
end;

function TdxCustomRibbonSkin.GetQuickAccessToolbarMarkButtonOffset(
  AHasApplicationButton: Boolean; ABelow: Boolean): Integer;
begin
  if ABelow then
    Result := 5
  else
    Result := 12;
end;

function TdxCustomRibbonSkin.GetQuickAccessToolbarOverrideWidth(
  AHasApplicationButton: Boolean; AUseAeroGlass: Boolean): Integer;
begin
  if AHasApplicationButton then
    Result := 14
  else
    Result := 0;
end;

function TdxCustomRibbonSkin.GetQuickAccessToolbarLeftIndent(
  AHasApplicationButton: Boolean; AUseAeroGlass: Boolean): Integer;
begin
  Result := 0;
end;

function TdxCustomRibbonSkin.GetQuickAccessToolbarRightIndent(
  AHasApplicationButton: Boolean): Integer;
begin
  Result := 0;
end;

function TdxCustomRibbonSkin.GetStatusBarSeparatorSize: Integer;
begin
  Result := 3;
end;

function TdxCustomRibbonSkin.GetWindowBordersWidth(AHasStatusBar: Boolean): TRect;
begin
  Result := cxRect(4, 0, 4, 4);
  if AHasStatusBar then
    Result.Bottom := 1;
end;

function TdxCustomRibbonSkin.HasGroupTransparency: Boolean;
begin
  Result := False;
end;

function TdxCustomRibbonSkin.NeedDrawGroupScrollArrow: Boolean;
begin
  Result := True;
end;

procedure TdxCustomRibbonSkin.UpdateBitsPerPixel;
var
  DC: HDC;
begin
  DC := GetDC(0);
  FLowColors := GetDeviceCaps(DC, BITSPIXEL) <= 8;
  ReleaseDC(0, DC);
end;

procedure TdxCustomRibbonSkin.LoadCommonControlSkinFromBitmap(ABitmap: GpBitmap);

  procedure AddElement(var AParts; const R, F: TRect; ID: Integer;
    AInterpolationMode: Integer = InterpolationModeNearestNeighbor);
  begin
    LoadElementParts(ABitmap, AParts, R, ID, F, [0], [0]);
    Parts[Integer(AParts)].InterpolationMode := AInterpolationMode;
  end;

begin
  AddElement(FQATGlassAtTopLeft[True], cxRectBounds(0, 353, 16, 26), cxRect(0, 2, 2, 2),
    rspQATNonClientLeft1Vista, InterpolationModeHighQualityBicubic);
  AddElement(FQATGlassAtTopLeft[False], cxRectBounds(34, 353, 4, 26), cxRect(2, 2, 0, 2),
    rspQATNonClientLeft2Vista, InterpolationModeHighQualityBicubic);
  AddElement(FQATGlassAtTopRight, cxRectBounds(16, 353, 18, 26), cxRect(0, 7, 15, 7),
    rspQATNonClientRightVista, InterpolationModeHighQualityBicubic);
  LoadCommonButtonParts(ABitmap);
  LoadCommonMenuParts(ABitmap);
  LoadCommonProgressParts(ABitmap);
  FHelpButton := AddPart1x1(ABitmap, cxRectBounds(42, 353, 16, 16), rspHelpButton, '', 7);
end;

procedure TdxCustomRibbonSkin.LoadCustomControlSkinFromBitmap(ABitmap: GpBitmap);
begin
  LoadTab(ABitmap);
  LoadScrollButtons(ABitmap);
  LoadCustomGroup(ABitmap);
  LoadCollapsedToolbar(ABitmap);
  LoadCustomButtonParts(ABitmap);
  LoadCustomMenuParts(ABitmap);
  LoadCustomProgressParts(ABitmap);
  LoadCustomScrollArrow(ABitmap);
  LoadCustomScreenTip(ABitmap);
  LoadQAT(ABitmap);
  LoadStatusBar(ABitmap);
  LoadGallery(ABitmap);
end;

procedure TdxCustomRibbonSkin.LoadFormSkinFromBitmap(ABitmap: GpBitmap);

  procedure AddElement(var AParts; const R, F: TRect; ID: Integer;
    AInterpolationMode: Integer = InterpolationModeNearestNeighbor);
  begin
    LoadElementParts(ABitmap, AParts, R, ID, F, [0, 1], [0, 1]);
    Parts[TTwoStateArray(AParts)[False]].InterpolationMode := AInterpolationMode;
    Parts[TTwoStateArray(AParts)[True]].InterpolationMode := AInterpolationMode;
  end;

var
  R, Fixed: TRect;
begin
  //caption
  AddElement(FCaption, cxRectBounds(0, 37, 14, 31), cxRect(6, 10, 6, 5), rfspActiveCaption);
  AddElement(FCaptionZoomed, cxRectBounds(6, 37, 2, 31), cxRect(0, 10, 0, 5), rfspActiveCaptionZoomed);
  //caption borders
  R := cxRectBounds(0, 37, 4, 31);
  Fixed := cxRect(0, 9, 0, 2);
  AddElement(FCaptionLeftBorder, R, Fixed, rfspActiveCaptionLeftBorder);
  OffsetRect(R, 10, 0);
  AddElement(FCaptionRightBorder, R, Fixed, rfspActiveCaptionRightBorder);
  //active border
  R := cxRectBounds(15, 37, 4, 6);
  Fixed := cxRect(0, 0, 0, 5);
  AddElement(FLeftBorder, R, Fixed, rfspActiveLeftBorder);
  OffsetRect(R, 5, 0);
  AddElement(FRightBorder, R, Fixed, rfspActiveRightBorder);
  //bottom border
  AddElement(FBottomBorderThin, cxRectBounds(15, 50, 2, 2), cxEmptyRect, rfspActiveBottomBorder1);
  AddElement(FBottomBorderThick[False], cxRectBounds(40, 113, 10, 4), cxRect(4, 0, 4, 0), rfspActiveBottomBorder2);
  AddElement(FBottomBorderThick[True], cxRectBounds(40, 121, 10, 4), cxRect(4, 0, 4, 0), rfspActiveBottomBorder3);
  LoadBorderIcons(ABitmap);
  //QuickAccessToolbar non-client
  AddElement(FQATAtTopLeft[True], cxRectBounds(0, 113, 15, 26), cxRect(13, 5, 0, 5),
    rspQATNonClientLeft1Active);
  AddElement(FQATAtTopLeft[False], cxRectBounds(32, 113, 7, 26), cxRect(2, 5, 0, 5),
    rspQATNonClientLeft2Active);
  AddElement(FQATAtTopRight, cxRectBounds(13, 113, 18, 26), cxRect(0, 5, 13, 5),
    rspQATNonClientRightActive);

  FRibbonTopArea := AddPart3x3(ABitmap, cxRectBounds(6, 38, 2, 30), cxRect(0, 9, 0, 5), rspRibbonClientTopArea);
  LoadApplicationButton(ABitmap);
end;

procedure TdxCustomRibbonSkin.DrawApplicationButtonLC(DC: HDC; const R: TRect;
  AState: TdxApplicationButtonState);
var
  ARect: TRect;
  AIndex: Integer;
  APen: HPEN;
  ABrush: HBRUSH;
  AColor: TColor;
  B: TLogBrush;
begin
  AIndex := SaveDC(DC);
  if AState <> absPressed then
    AColor := ColorToRgb(clWhite)
  else
    AColor := ColorToRgb(clBtnShadow);
  APen := CreatePen(PS_SOLID, 3, AColor);
  if AState = absNormal then
    AColor := ColorToRgb(clBtnFace)
  else
    AColor := ColorToRgb(clHighlight);
  ABrush := CreateSolidBrush(AColor);
  ARect := cxRectInflate(R, -1, -1);
  Dec(ARect.Right);
  Dec(ARect.Bottom);
  SelectObject(DC, APen);
  SelectObject(DC, ABrush);
  Ellipse(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  DeleteObject(ABrush);
  DeleteObject(APen);
  APen := CreatePen(PS_SOLID, 1, 0);
  B.lbStyle := BS_NULL;
  B.lbColor := 0;
  B.lbHatch := 0;
  ABrush := CreateBrushIndirect(B);
  SelectObject(DC, APen);
  SelectObject(DC, ABrush);
  Ellipse(DC, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
  DeleteObject(ABrush);
  DeleteObject(APen);
  RestoreDC(DC, AIndex);
end;

procedure TdxCustomRibbonSkin.DrawApplicationMenuBorderLC(DC: HDC;
  const R: TRect);
begin
  DrawFrame(DC, R, clMenu, clBlack);
end;

procedure TdxCustomRibbonSkin.DrawBlackArrow(DC: HDC; const R: TRect; AArrowDirection: TcxArrowDirection);
var
  APoints: TcxArrowPoints;
  ARgn: HRGN;
begin
  TcxCustomLookAndFeelPainter.CalculateArrowPoints(R, APoints, AArrowDirection, False, 4);
  case AArrowDirection of
    adDown:
      begin
        Dec(APoints[0].X);
        Dec(APoints[1].X);
      end;
  end;
  ARgn := CreatePolygonRgn(APoints, 3, WINDING);
  FillRgn(DC, ARgn, GetStockObject(BLACK_BRUSH));
  DeleteObject(ARgn);
end;

procedure TdxCustomRibbonSkin.DrawFormBordersLC(DC: HDC;
  const ABordersWidth: TRect; ACaptionHeight: Integer;
  const AData: TdxRibbonFormData);
var
  R: TRect;
begin
  R := AData.Bounds;
  //R.Top := ACaptionHeight + ABordersWidth.Top;
  R.Right := R.Left + 2;
  FillRectByColor(DC, R, clBtnHighlight);
  R.Right := R.Left + ABordersWidth.Left;
  Inc(R.Left, 2);
  FillRectByColor(DC, R, clBtnFace);

  R.Right := AData.Bounds.Right;
  R.Left := R.Right - 1;
  FillRectByColor(DC, R, cl3DDkShadow);
  OffsetRect(R, -1, 0);
  FillRectByColor(DC, R, clBtnShadow);
  R.Right := AData.Bounds.Right - 2;
  R.Left := R.Right - (ABordersWidth.Right - 2);
  FillRectByColor(DC, R, clBtnFace);

  R := AData.Bounds;
  R.Top := R.Bottom - 1;
  FillRectByColor(DC, R, cl3DDkShadow);
end;

procedure TdxCustomRibbonSkin.DrawFormBorderIconLC(DC: HDC; const R: TRect;
  AIcon: TdxBorderDrawIcon; AState: TdxBorderIconState);
const
  Pushes: array[Boolean] of Integer = (0, DFCS_PUSHED);
  Buttons: array[TdxBorderDrawIcon] of Integer = (
    DFCS_CAPTIONMIN, DFCS_CAPTIONMAX, DFCS_CAPTIONRESTORE,
    DFCS_CAPTIONCLOSE, DFCS_CAPTIONHELP);
begin
  DrawFrameControl(DC, cxRect(R.Left + 1, R.Top + 2, R.Right - 1, R.Bottom),
    DFC_CAPTION, Buttons[AIcon] or Pushes[AState = bisPressed]);
end;

procedure TdxCustomRibbonSkin.DrawFormCaptionLC(DC: HDC; const R: TRect;
  const AData: TdxRibbonFormData);
var
  ARect: TRect;
begin
  if AData.State <> wsMaximized then
  begin
    ARect := R;
    ARect.Bottom := ARect.Top + 1;
    FillRectByColor(DC, ARect, clBtnHighlight);
    ExcludeClipRect(DC, ARect);
    OffsetRect(ARect, 0, 1);
    FillRectByColor(DC, ARect, clBtnFace);
    ExcludeClipRect(DC, ARect);
  end;
  if AData.Active then
    FillRectByColor(DC, R, clActiveCaption)
  else
    FillRectByColor(DC, R, clInactiveCaption);
end;

procedure TdxCustomRibbonSkin.DrawDropDownGalleryVerticalSizeGrip(DC: HDC;
  const R: TRect);
var
  ARect: TRect;
begin
  ARect := Rect(0, R.Top, 0, R.Bottom);
  ARect.Right := DropDownGalleryVerticalSizeGripBitmapSize.cx *
    cxRectHeight(ARect) div DropDownGalleryVerticalSizeGripBitmapSize.cy;
  OffsetRect(ARect, (cxRectWidth(R) - cxRectWidth(ARect)) div 2, 0);
  Parts[FDropDownGalleryVerticalSizeGrip].Draw(DC, ARect);
end;

procedure TdxCustomRibbonSkin.LoadFormSkin;
var
  ABitmap: GpBitmap;
begin
  LoadFormSkinBitmap(ABitmap);
  LoadFormSkinFromBitmap(ABitmap);
  GdipDisposeImage(ABitmap);
end;

procedure TdxCustomRibbonSkin.LoadRibbonSkin;
var
  ABitmap: GpBitmap;
begin
  LoadCommonRibbonSkinBitmap(ABitmap);
  LoadCommonControlSkinFromBitmap(ABitmap);
  GdipDisposeImage(ABitmap);
  //custom skin
  LoadCustomRibbonSkinBitmap(ABitmap);
  LoadCustomControlSkinFromBitmap(ABitmap);
  GdipDisposeImage(ABitmap);
end;

procedure TdxCustomRibbonSkin.LoadCommonRibbonSkinBitmap(out ABitmap: GpBitmap);
begin
  LoadBitmapFromStream('RIBBONCOMMON', ABitmap);
end;

procedure TdxCustomRibbonSkin.LoadApplicationButton(ABitmap: GpBitmap);
begin
  LoadThreeStateArray(ABitmap, cxRectBounds(0, 166, 42, 42), cxEmptyRect,
    FApplicationButton, rspApplicationButtonNormal, InterpolationModeHighQualityBicubic);
end;

const
  DefaultFixedSize: TRect = (Left: 2; Top: 2; Right: 2; Bottom: 2);

procedure TdxCustomRibbonSkin.LoadBorderIcons(ABitmap: GpBitmap);
const
  IconWidth  = 25;
  IconHeight = 25;
  IconGlyphWidth  = 9;
  IconGlyphHeight = 9;
var
  I: TdxBorderDrawIcon;
  X, Y, ID: Integer;
  R: TRect;
begin
  X := 0;
  Y := 0;
  ID := rfspMinimizeNormalIconGlyph;
  for I := Low(TdxBorderDrawIcon) to High(TdxBorderDrawIcon) do
  begin
    R := cxRectBounds(X, Y, IconGlyphWidth, IconGlyphHeight);
    LoadElementParts(ABitmap, FBorderIconGlyph[I], R, ID, DefaultFixedSize,
      [0, 1, 2, 3], [0, 1, 2, 3], True, InterpolationModeNearestNeighbor);
    Inc(X, IconGlyphWidth + 1);
    Inc(ID, 4);
  end;
  R := cxRectBounds(25, 37, IconWidth, IconHeight);
  LoadElementParts(ABitmap, FBorderIcons, R, rfspBorderIconHot,
    DefaultFixedSize, [0,1,2], [0,1,2], True, InterpolationModeNearestNeighbor);
end;

procedure TdxCustomRibbonSkin.LoadCustomButtonParts(ABitmap: GpBitmap);
const
  ArrowDownWidth         = 5;
  ArrowDownHeight        = 4;
  MenuArrowDownWidth   = 7;
  MenuArrowDownHeight  = 4;
  EditButtonWidth        = 12;
  EditButtonHeight       = 20;

  ApplicationMenuButtonWidth  = 6;
  ApplicationMenuButtonHeight = 22;

  ButtonGroupWidth = 3;
  ButtonGroupHeight = 22;
  ButtonGroupBorderWidth = 2;
  ButtonGroupMiddleBorderWidth = 1;

  LaunchButtonGlyphSize = 12;
begin
  LoadElementParts(ABitmap, FArrowsDown,
    cxRectBounds(0, 237, ArrowDownWidth, ArrowDownHeight),
    rspArrowDownNormal, cxEmptyRect, [0, 1, 2, 2, 2, 2, 0, 0, 1], []);
  LoadElementParts(ABitmap, FEditButtons,
    cxRectBounds(0, 116, EditButtonWidth, EditButtonHeight),
    rspEditButtonNormal, DefaultFixedSize, [0, 1, 2, 3, 4, 5, 1],
    [DXBAR_NORMAL..DXBAR_DROPPEDDOWN, DXBAR_ACTIVEDISABLED]);
  FMenuArrowDown := AddPart1x1(ABitmap, cxRectBounds(6, 245, MenuArrowDownWidth, MenuArrowDownHeight), rspMenuArrowDown);
  FMenuArrowRight := AddPart1x1(ABitmap, cxRectBounds(6, 237, MenuArrowDownHeight, MenuArrowDownWidth), rspMenuArrowRight);

  FApplicationMenuButton := AddPart3x3(ABitmap, cxRectBounds(0, 250, ApplicationMenuButtonWidth, ApplicationMenuButtonHeight), DefaultFixedSize, rspApplicationMenuButton);

  LoadElementParts(ABitmap, FButtonGroup,
    cxRectBounds(73, 0, ButtonGroupWidth, ButtonGroupHeight),
    rspButtonGroupNormal, Rect(1, 2, 1, 2), [], []);

  FButtonGroupBorderLeft := AddPart3x3(ABitmap, cxRectBounds(37, 197, ButtonGroupBorderWidth, ButtonGroupHeight),
    Rect(0, 2, 0, 2), rspButtonGroupBorderLeft);
  FButtonGroupBorderRight := AddPart3x3(ABitmap, cxRectBounds(38, 197, ButtonGroupBorderWidth, ButtonGroupHeight),
    Rect(0, 2, 0, 2), rspButtonGroupBorderRight);
  LoadElementParts(ABitmap, FButtonGroupBorderMiddle,
    cxRectBounds(40, 86, ButtonGroupMiddleBorderWidth, ButtonGroupHeight),
    rspButtonGroupBorderMiddleNormal, Rect(0, 2, 0, 2), [0, 1, 2, 2, 2, 2, 2, 2, 3], []);
  LoadElementParts(ABitmap, FButtonGroupSplitButtonSeparator,
    cxRectBounds(37, 86, ButtonGroupBorderWidth, ButtonGroupHeight),
    rspButtonGroupSplitButtonSeparatorNormal, Rect(0, 2, 0, 2), [0, 1, 2, 2, 3, 2, 2, 2, 4], []);

  LoadElementParts(ABitmap, FLaunchButtonDefaultGlyphs,
    cxRectBounds(34, 249, LaunchButtonGlyphSize, LaunchButtonGlyphSize),
    rspLaunchButtonDefaultGlyphNormal, cxNullRect, [0, 1, 0, 0, 0],
    [DXBAR_NORMAL, DXBAR_DISABLED, DXBAR_HOT, DXBAR_ACTIVE, DXBAR_PRESSED], True, 5);
end;

procedure TdxCustomRibbonSkin.LoadCustomGroup(ABitmap: GpBitmap);
var
  R1, R2: TRect;
begin
  R1 := cxRectBounds(13, 116, 11, 92);
  R2 := cxRect(5, 17, 5, 7);
  FTabGroupsArea := AddPart3x3(ABitmap, R1, R2, rspTabGroupsArea);
  R1 := cxRectBounds(66, 350, 8, 68);
  R2 := cxRect(3, 14, 3, 0);
  LoadElementParts(ABitmap, FToolbar, R1, rspToolbarNormal, R2, [],
    [DXBAR_NORMAL, DXBAR_HOT], False);
  R1 := cxRectBounds(66, 418, 8, 17);
  R2 := cxRect(3, 0, 3, 3);
  LoadElementParts(ABitmap, FToolbarHeader, R1, rspToolbarHeaderNormal, R2, [],
    [DXBAR_NORMAL, DXBAR_HOT], False);

  R1 := cxRectBounds(36, 220, 7, 7);
  LoadElementParts(ABitmap, FMarkArrow, R1, rspMarkArrowNormal, cxEmptyRect,
    [0, 0, 1], [DXBAR_NORMAL, DXBAR_HOT, DXBAR_PRESSED], True);
  R1 := cxRectBounds(37, 234, 7, 7);
  LoadElementParts(ABitmap, FMarkTruncated, R1, rspMarkTruncatedNormal, cxEmptyRect,
    [0, 0, 1], [DXBAR_NORMAL, DXBAR_HOT, DXBAR_PRESSED], True);
end;

procedure TdxCustomRibbonSkin.LoadCustomMenuParts(ABitmap: GpBitmap);
begin
  FApplicationMenuBorder := AddPart3x3(ABitmap, cxRectBounds(48, 321, 8, 8), Rect(3, 3, 3, 3), rspApplicationMenuBorder);
  FApplicationMenuContentHeader := AddPart1x1(ABitmap, cxRectBounds(57, 325, 2, 14), rspApplicationMenuContentHeader);
  FApplicationMenuContentFooter := AddPart1x1(ABitmap, cxRectBounds(62, 323, 2, 25), rspApplicationMenuContentFooter);
  FMenuMark := AddPart1x1(ABitmap, cxRectBounds(49, 277, 16, 16), rspMenuMark);
  FMenuScrollArea[DXBAR_NORMAL] := AddPart3x3(ABitmap, cxRectBounds(20, 237, 4, 12), Rect(1, 1, 1, 1), rspMenuScrollAreaNormal);
end;

procedure TdxCustomRibbonSkin.LoadCustomProgressParts(ABitmap: GpBitmap);
begin
  FProgressSubstrate := AddPart3x3(ABitmap, cxRectBounds(11, 237, 7, 7), DefaultFixedSize, rspProgressSubstrate);
end;

procedure TdxCustomRibbonSkin.LoadCustomScrollArrow(ABitmap: GpBitmap);
begin
  FScrollArrow := AddPart1x1(ABitmap, cxRectBounds(14, 245, 5, 3), rspScrollArrow);
end;

procedure TdxCustomRibbonSkin.LoadCustomScreenTip(ABitmap: GpBitmap);
begin
  FScreenTip := AddPart3x3(ABitmap, cxRectBounds(66, 0, 6, 165), DefaultFixedSize, rspScreenTip);
end;

procedure TdxCustomRibbonSkin.LoadGallery(ABitmap: GpBitmap);
begin
  LoadInRibbonGalleryScrollBarParts(ABitmap);
  FGalleryFilterBand := AddPart3x3(ABitmap, cxRectBounds(7, 250, 4, 13),
    cxRectBounds(1, 1, 1, 0), rspGalleryFilterBand);
  FGalleryGroupHeader := AddPart3x3(ABitmap, cxRectBounds(0, 273, 4, 4),
    cxRectBounds(0, 0, 0, 2), rspGalleryGroupHeader);
  FDropDownGalleryTopSizingBand := AddPart3x3(ABitmap, cxRectBounds(38, 29, 4, 11),
    cxRectBounds(1, 1, 1, 1), rspDropDownGalleryTopSizingBand);
  FDropDownGalleryBottomSizingBand := AddPart3x3(ABitmap, cxRectBounds(33, 29, 4, 11),
    cxRectBounds(1, 1, 1, 1), rspDropDownGalleryBottomSizingBand);
  FDropDownGalleryTopSizeGrip := AddPart3x3(ABitmap, cxRectBounds(54, 423, 7, 7),
    cxEmptyRect, rspDropDownGalleryTopSizeGrip, '', InterpolationModeNearestNeighbor);
  FDropDownGalleryBottomSizeGrip := AddPart3x3(ABitmap, cxRectBounds(46, 423, 7, 7),
    cxEmptyRect, rspDropDownGalleryBottomSizeGrip, '', InterpolationModeNearestNeighbor);
  FDropDownGalleryVerticalSizeGrip := AddPart3x3(ABitmap, cxRectBounds(46, 431,
    DropDownGalleryVerticalSizeGripBitmapSize.cx, DropDownGalleryVerticalSizeGripBitmapSize.cy),
    cxEmptyRect, rspDropDownGalleryVerticalSizeGrip);
end;

procedure TdxCustomRibbonSkin.LoadTab(ABitmap: GpBitmap);
begin
  LoadElementParts(ABitmap, FTabIndex, cxRectBounds(0, 0, 24, 23), rspTabNormal,
    cxRect(4, 4, 4, 4), [0,1,2,3,4], [0,1,2,3,4]);
  FTabSeparator :=  AddPart1x1(ABitmap, cxRectBounds(42, 86, 1, 22), rspTabSeparator);
end;

procedure TdxCustomRibbonSkin.LoadScrollButtons(ABitmap: GpBitmap);
var
  R, FR: TRect;
begin
  FR := cxRect(3, 4, 3, 5);
  R := cxRectBounds(46, 350, 9, 24);
  LoadThreeStateArray(ABitmap, R, FR, FTabScrollButtons[True], rspTabScrollLeftButtonNormal);
  R := cxRectBounds(56, 350, 9, 24);
  LoadThreeStateArray(ABitmap, R, FR, FTabScrollButtons[False], rspTabScrollRightButtonNormal);
  R := cxRectBounds(48, 0, 8, 92);
  LoadThreeStateArray(ABitmap, R, cxRect(4, 4, 2, 4), FGroupScrollButtons[True], rspGroupScrollLeftButtonNormal);
  R := cxRectBounds(57, 0, 8, 92);
  LoadThreeStateArray(ABitmap, R, cxRect(2, 4, 4, 4), FGroupScrollButtons[False], rspGroupScrollRightButtonNormal);
end;

procedure TdxCustomRibbonSkin.LoadQAT(ABitmap: GpBitmap);

  procedure LoadGroupButton(R: TRect; AStartID: Integer; var AStates: TFourStateArray);
  var
    I: Integer;
  begin
    for I := 0 to 3 do
    begin
      AStates[I] := AddPart3x3(ABitmap, R, cxRect(2, 2, 2, 2), AStartID + I);
      OffsetRect(R, 0, cxRectHeight(R));
    end;
  end;

begin
  FQATAtBottom := AddPart3x3(ABitmap, cxRectBounds(13, 209, 10, 26),
    cxRect(3, 3, 3, 3), rspQATAtBottom);
  FQATPopup :=  AddPart3x3(ABitmap, cxRectBounds(33, 0, 6, 28),
    cxRect(2, 2, 2, 2), rspQATPopup);

  LoadElementParts(ABitmap, FQATGroupButtonActive, cxRectBounds(0, 350, 22, 22),
    rspQATGroupButtonActive, DefaultFixedSize, [0, 3, 1, 1, 2, 2, 1],
    [DXBAR_NORMAL, DXBAR_DISABLED, DXBAR_HOT, DXBAR_ACTIVE, DXBAR_PRESSED, DXBAR_DROPPEDDOWN, DXBAR_ACTIVEDISABLED]);
  LoadElementParts(ABitmap, FQATGroupButtonInactive, cxRectBounds(23, 350, 22, 22),
    rspQATGroupButtonInactive, DefaultFixedSize, [0, 3, 1, 1, 2, 2, 1],
    [DXBAR_NORMAL, DXBAR_DISABLED, DXBAR_HOT, DXBAR_ACTIVE, DXBAR_PRESSED, DXBAR_DROPPEDDOWN, DXBAR_ACTIVEDISABLED]);
end;

procedure TdxCustomRibbonSkin.LoadStatusBar(ABitmap: GpBitmap);
begin
  FStatusBar := AddPart1x3(ABitmap, cxRectBounds(42, 138, 2, 22), 2, 3, rspStatusBar);
  FStatusBarPanel := FStatusBar;
  FStatusBarPanelLowered := FStatusBar;
  FStatusBarPanelRaised := AddPart1x3(ABitmap, cxRectBounds(42, 160, 2, 22), 2, 3, rspStatusBarPanelRaised);

  FStatusBarPanelSeparator := AddPart1x3(ABitmap, cxRectBounds(42, 183, 3, 22), 2, 3, rspStatusBarPanelSeparator);
  FStatusBarToolbarSeparator := AddPart1x3(ABitmap, cxRectBounds(45, 138, 2, 22), 2, 3, rspStatusBarToolbarSeparator);
  FStatusBarGripBackground := AddPart3x3(ABitmap, cxRectBounds(42, 183, 5, 22),
    cxRect(3, 2, 0, 3), rspStatusBarGripBackground);

  LoadElementParts(ABitmap, FFormStatusBarLeftParts[False], cxRectBounds(77, 241, 4, 22), rspStatusBarFormLeftPart,
    cxRect(0, 2, 0, 3), [0, 1, 2, 3], [0, 1, 2, 3]);
  LoadElementParts(ABitmap, FFormStatusBarLeftParts[True], cxRectBounds(85, 241, 4, 22), rspStatusBarFormLeftPartDialog,
    cxRect(0, 2, 0, 3), [0, 1, 2, 3], [0, 1, 2, 3]);
  LoadElementParts(ABitmap, FFormStatusBarRightParts[False], cxRectBounds(81, 241, 4, 22), rspStatusBarFormRightPart,
    cxRect(0, 2, 0, 3), [0, 1, 2, 3], [0, 1, 2, 3]);
  LoadElementParts(ABitmap, FFormStatusBarRightParts[True], cxRectBounds(89, 241, 4, 22), rspStatusBarFormRightPartDialog,
    cxRect(0, 2, 0, 3), [0, 1, 2, 3], [0, 1, 2, 3]);
end;

procedure TdxCustomRibbonSkin.LoadCollapsedToolbar(ABitmap: GpBitmap);
const
  CollapsedToolbarWidth  = 7;
  CollapsedToolbarHeight = 85;
  CollapsedToolbarFixedSize: TRect = (Left: 3; Top: 15; Right: 3; Bottom: 3);
  CollapsedToolbarGlyphBackgroundWidth = 10;
  CollapsedToolbarGlyphBackgroundHeight = 31;
  CollapsedToolbarGlyphBackgroundFixedSize: TRect = (Left: 4; Top: 9; Right: 4; Bottom: 8);
begin
  LoadElementParts(ABitmap, FCollapsedToolbars,
    cxRectBounds(25, 0, CollapsedToolbarWidth, CollapsedToolbarHeight),
    rspCollapsedToolbarNormal, CollapsedToolbarFixedSize, [0,1,3,2],
    [DXBAR_NORMAL, DXBAR_HOT, DXBAR_ACTIVE, DXBAR_PRESSED]);
  LoadElementParts(ABitmap, FCollapsedToolbarGlyphBackgrounds,
    cxRectBounds(66, 199, CollapsedToolbarGlyphBackgroundWidth,
    CollapsedToolbarGlyphBackgroundHeight),
    rspCollapsedToolbarGlyphBackgroundNormal,
    CollapsedToolbarGlyphBackgroundFixedSize, [0,1,3,2],
    [DXBAR_NORMAL, DXBAR_HOT, DXBAR_ACTIVE, DXBAR_PRESSED]);
end;

procedure TdxCustomRibbonSkin.InternalDrawPart(const AParts: TStatesArray;
  DC: HDC; const R: TRect; AState: Integer);
begin
  if AParts[AState] <> 0 then
  begin
    if LowColors then
    begin
      if AState in [DXBAR_HOT, DXBAR_CHECKED, DXBAR_HOTCHECK] then
        DrawFrame(DC, R, clHighlight, clWhite)
      else if AState = DXBAR_PRESSED then
        DrawFrame(DC, R, clHighlight, clBtnShadow)
      else
        DrawFrame(DC, R, clBtnFace, clBtnShadow);
    end
    else
      Parts[AParts[AState]].Draw(DC, R);
  end;
end;

procedure TdxCustomRibbonSkin.LoadThreeStateArray(ABitmap: GpBitmap; R: TRect;
  const Fixed: TRect; var AStateArray: TThreeStateArray; AStartID: Integer;
  AInterpolationMode: Integer = InterpolationModeDefault);
var
  I: Integer;
begin
  for I := 0 to 2 do
  begin
    AStateArray[I] := AddPart3x3(ABitmap, R, Fixed, AStartID, '', AInterpolationMode);
    OffsetRect(R, 0, R.Bottom - R.Top);
    Inc(AStartID);
  end;
end;

procedure TdxCustomRibbonSkin.LoadCommonButtonParts(ABitmap: GpBitmap);
const
  SmallButtonSize  = 22;
  SmallButtonGlyphBackgroundWidth = 29;
  SmallButtonDropButtonWidth = 12;

  LargeButtonWidth  = 42;
  LargeButtonHeight = 66;
  LargeButtonGlyphBackgroundWidth = 42;
  LargeButtonGlyphBackgroundHeight = 39;
  LargeButtonDropButtonWidth = 42;
  LargeButtonDropButtonHeight = 27;

  LaunchButtonWidth = 15;
  LaunchButtonHeight = 14;
begin
  LoadElementParts(ABitmap, FSmallButtons,
    cxRectBounds(99, 155, SmallButtonSize, SmallButtonSize),
    rspSmallButtonNormal, DefaultFixedSize, [0, 0, 1, 2, 2, 3, 4], DXBAR_BTN_STATES);
  LoadElementParts(ABitmap, FSmallButtonGlyphBackgrounds,
    cxRectBounds(86, 0, SmallButtonGlyphBackgroundWidth, SmallButtonSize),
    rspSmallButtonGlyphBackgroundNormal, DefaultFixedSize, [], DXBAR_BTN_STATES);
  LoadElementParts(ABitmap, FSmallButtonDropButtons,
    cxRectBounds(86, 155, SmallButtonDropButtonWidth, SmallButtonSize),
    rspSmallButtonDropButtonNormal, DefaultFixedSize, [], DXBAR_BTN_STATES);

  LoadElementParts(ABitmap, FLargeButtons,
    cxRectBounds(0, 0, LargeButtonWidth, LargeButtonHeight),
    rspLargeButtonNormal, DefaultFixedSize, [0, 0, 1, 2, 2, 3, 4], DXBAR_BTN_STATES);
  LoadElementParts(ABitmap, FLargeButtonGlyphBackgrounds,
    cxRectBounds(43, 0, LargeButtonGlyphBackgroundWidth, LargeButtonGlyphBackgroundHeight),
    rspLargeButtonGlyphBackgroundNormal, DefaultFixedSize, [0, 1, 2, 1, 3, 4], DXBAR_BTN_STATES);
  LoadElementParts(ABitmap, FLargeButtonDropButtons,
    cxRectBounds(43, 235, LargeButtonDropButtonWidth, LargeButtonDropButtonHeight),
    rspLargeButtonDropButtonNormal, DefaultFixedSize, [0, 1, 1, 2, 2, 0, 3], DXBAR_BTN_STATES);

  LoadElementParts(ABitmap, FLaunchButtonBackgrounds,
    cxRectBounds(101, 350, LaunchButtonWidth, LaunchButtonHeight),
    rspLaunchButtonBackgroundNormal, DefaultFixedSize, [0, 0, 1],
    [DXBAR_HOT, DXBAR_ACTIVE, DXBAR_PRESSED]);
end;

procedure TdxCustomRibbonSkin.LoadCommonMenuParts(ABitmap: GpBitmap);
const
  MenuCheckSize = 6;
  MenuCheckMarkSize = 20;
  MenuDetachCaptionSize = 5;
  MenuSeparatorSize = 2; // same as dxBar
begin
  LoadElementParts(ABitmap, FMenuDetachCaption,
    cxRectBounds(1, 331, MenuDetachCaptionSize, MenuDetachCaptionSize),
    rspMenuDetachCaptionNormal, DefaultFixedSize, [], [DXBAR_NORMAL, DXBAR_HOT]);
  LoadElementParts(ABitmap, FMenuCheck,
    cxRectBounds(99, 310, MenuCheckSize, MenuCheckSize),
    rspMenuCheckNormal, DefaultFixedSize, [], [DXBAR_NORMAL, DXBAR_DISABLED]);
  LoadElementParts(ABitmap, FMenuCheckMark,
    cxRectBounds(99, 266, MenuCheckMarkSize, MenuCheckMarkSize),
    rspMenuCheckMarkNormal, DefaultFixedSize, [], [DXBAR_NORMAL, DXBAR_DISABLED]);

  FMenuGlyph := AddPart3x3(ABitmap, cxRectBounds(14, 331, 3, 4), Rect(1, 1, 0, 1), rspMenuGlyph);
  FMenuContent := AddPart3x3(ABitmap, cxRectBounds(18, 331, 3, 4), Rect(0, 1, 1, 1), rspMenuContent);
  FMenuSeparatorHorz := AddPart1x1(ABitmap, cxRectBounds(17, 337, MenuSeparatorSize, MenuSeparatorSize), rspMenuSeparatorHorz);
  FMenuSeparatorVert := AddPart1x1(ABitmap, cxRectBounds(14, 336, MenuSeparatorSize, MenuSeparatorSize), rspMenuSeparatorVert);
  FDropDownBorder := AddPart3x3(ABitmap, cxRectBounds(28, 331, 8, 8), Rect(3, 3, 3, 3), rspDropDownBorder);

  LoadElementParts(ABitmap, FMenuScrollArea,
    cxRectBounds(86, 310, 6, 12),
    rspMenuScrollAreaNormal, DefaultFixedSize, [], [DXBAR_HOT, DXBAR_PRESSED]);
  FQATDefaultGlyph := AddPart1x1(ABitmap, cxRectBounds(100, 330, 16, 16), rspQATDefaultGlyph);
end;

procedure TdxCustomRibbonSkin.LoadCommonProgressParts(ABitmap: GpBitmap);
begin
  FProgressSolidBand := AddPart3x3(ABitmap, cxRectBounds(6, 344, 86, 8), DefaultFixedSize, rspProgressSolidband);
  FProgressDiscreteBand := AddPart3x3(ABitmap, cxRectBounds(0, 344, 5, 8), DefaultFixedSize, rspProgressDiscreteBand);
end;

procedure TdxCustomRibbonSkin.LoadInRibbonGalleryScrollBarParts(
  ABitmap: GpBitmap);
const
  ScrollBarButtonWidth = 15;
  ScrollBarButtonHeight = 20;
begin
  LoadElementParts(ABitmap, FInRibbonGalleryScrollBarLineUpButton,
    cxRectBounds(78, 0, ScrollBarButtonWidth, ScrollBarButtonHeight),
    rspInRibbonGalleryScrollBarLineUpButtonNormal, DefaultFixedSize,
    [0, 3, 1, 2], [DXBAR_NORMAL, DXBAR_DISABLED, DXBAR_HOT, DXBAR_PRESSED]);
  LoadElementParts(ABitmap, FInRibbonGalleryScrollBarLineDownButton,
    cxRectBounds(78, 80, ScrollBarButtonWidth, ScrollBarButtonHeight),
    rspInRibbonGalleryScrollBarLineDownButtonNormal, DefaultFixedSize,
    [0, 3, 1, 2], [DXBAR_NORMAL, DXBAR_DISABLED, DXBAR_HOT, DXBAR_PRESSED]);
  LoadElementParts(ABitmap, FInRibbonGalleryScrollBarDropDownButton,
    cxRectBounds(78, 160, ScrollBarButtonWidth, ScrollBarButtonHeight),
    rspInRibbonGalleryScrollBarDropDownButtonNormal, DefaultFixedSize,
    [0, 3, 1, 2], [DXBAR_NORMAL, DXBAR_DISABLED, DXBAR_HOT, DXBAR_PRESSED]);
end;

{ TdxBlueRibbonSkin }

procedure TdxBlueRibbonSkin.DrawRibbonBottomBorder(DC: HDC; const R: TRect);
var
  R1: TRect;
begin
  R1 := R;
  Dec(R1.Bottom);
  FillRectByColor(DC, R1, $EBC3A4);
  OffsetRect(R1, 0, 1);
  FillRectByColor(DC, R1, $F3E2D5);
end;

function TdxBlueRibbonSkin.GetPartColor(APart: Integer; AState: Integer = 0): TColor;
const
  RibbonEditHotBackgroundColor = clWhite;
  RibbonEditNormalBorderColor = $DEC1AB;
  RibbonEditHotBorderColor = $E1C7B3;
  RibbonEditDisabledBorderColor = $C6BBB1;
begin
  Result := inherited GetPartColor(APart, AState);
  if LowColors then Exit;
  case APart of
    DXBAR_APPLICATIONMENUCONTENTSIDES: Result := $EDD3BE;
    DXBAR_APPLICATIONMENUCONTENTOUTERBORDER: Result := clWhite;
    DXBAR_APPLICATIONMENUCONTENTINNERBORDER: Result := $CAAF9B;
    DXBAR_MENUEDITSEPARATOR:
      case AState of
        DXBAR_ACTIVE:  Result := $85B6CA;
        DXBAR_ACTIVEDISABLED:  Result := $CDCDCD;
      end;
    DXBAR_MENUITEMTEXT:
      if not (AState in [DXBAR_DISABLED, DXBAR_ACTIVEDISABLED]) then
        Result := $6E1500;
    DXBAR_EDIT_BORDER:
      case AState of
        DXBAR_NORMAL: Result := RibbonEditNormalBorderColor;
        DXBAR_HOT, DXBAR_ACTIVE, DXBAR_ACTIVEDISABLED: Result := RibbonEditHotBorderColor;
        DXBAR_DISABLED: Result := RibbonEditDisabledBorderColor;
        DXBAR_FOCUSED, DXBAR_DROPPEDDOWN: Result := RibbonEditHotBorderColor;
      end;
    DXBAR_EDIT_BACKGROUND:
      case AState of
        DXBAR_NORMAL: Result := $FBF2EA;
        DXBAR_HOT, DXBAR_ACTIVE, DXBAR_ACTIVEDISABLED: Result := RibbonEditHotBackgroundColor;
        DXBAR_DISABLED: Result := $EFEFEF;
        DXBAR_FOCUSED, DXBAR_DROPPEDDOWN: Result := RibbonEditHotBackgroundColor;
      end;
    DXBAR_EDIT_BUTTON_BORDER:
      case AState of
        DXBAR_NORMAL: Result := RibbonEditNormalBorderColor;
        DXBAR_ACTIVE: Result := $DEC7AD;
        DXBAR_HOT: Result := $99CEDB;
        DXBAR_PRESSED: Result := $45667B;
        DXBAR_DISABLED, DXBAR_ACTIVEDISABLED: Result := RibbonEditDisabledBorderColor;
        DXBAR_DROPPEDDOWN: Result := $6B99A5;
      end;
    DXBAR_SCREENTIP_FOOTERLINE:
      Result := $DDBB9E;
    DXBAR_DATENAVIGATOR_HEADER:
      Result := $DAD5D2;
    DXBAR_SEPARATOR_BACKGROUND:
      Result := $EFE7DE;
    DXBAR_INRIBBONGALLERY_BACKGROUND:
      if AState in [DXBAR_ACTIVE, DXBAR_HOT] then
        Result := $FBF3EC
      else
        Result := $F8E6D4;
    DXBAR_INRIBBONGALLERY_BORDER:
      Result := $EDD0B9;
    DXBAR_GALLERYFILTERBANDTEXT:
      if AState = DXBAR_NORMAL then
        Result := $6E1500
      else if AState = DXBAR_HOT then
        Result := $FF6600
      else
        OutError;
    rspRibbonBackground:
      Result := $FFDBBF;
    rspRibbonBottomEdge:
      Result := $F3E2D5;
    rfspRibbonForm:
      Result := $EBC3A4;
    rspFormCaptionText:
      if AState = DXBAR_NORMAL then
        Result := $AA6A3E
      else
        Result := $A0A0A0;
    rspDocumentNameText:
      if AState = DXBAR_NORMAL then
        Result := $797069
      else
        Result := $A0A0A0;
    rspTabHeaderText, rspTabGroupText:
      Result := $8B4215;
    rspTabGroupHeaderText:
      Result := $AA6A3E;
    rspStatusBarText:
      if AState in [DXBAR_NORMAL, DXBAR_HOT] then
        Result := $8B4215
      else
        Result := $8D8D8D;
    rspStatusBarSizeGripColor1:
      Result := $805D45;
    rspStatusBarSizeGripColor2:
      Result := $E8C9B1;
  end;
end;

function TdxBlueRibbonSkin.GetName: string;
begin
  Result := 'Blue';
end;

procedure TdxBlueRibbonSkin.LoadCustomRibbonSkinBitmap(out ABitmap: GpBitmap);
begin
  LoadBitmapFromStream('RIBBONBLUE', ABitmap);
end;

procedure TdxBlueRibbonSkin.LoadFormSkinBitmap(out ABitmap: GpBitmap);
begin
  LoadBitmapFromStream('FORMBLUE', ABitmap);
end;

{ TdxBlackRibbonSkin }

procedure TdxBlackRibbonSkin.DrawRibbonBottomBorder(DC: HDC; const R: TRect);
var
  R1: TRect;
begin
  R1 := R;
  Dec(R1.Bottom);
  FillRectByColor(DC, R1, $4F4F4F);
  OffsetRect(R1, 0, 1);
  FillRectByColor(DC, R1, $626262);
end;

function TdxBlackRibbonSkin.GetPartColor(APart: Integer; AState: Integer = 0): TColor;
const
  RibbonEditHotBackgroundColor = clWhite;
  RibbonEditNormalBorderColor = $898989;
  RibbonEditHotBorderColor = $898989;
  RibbonEditDisabledBorderColor = $CCCCCC;
  RibbonItemText = $464646;
begin
  Result := inherited GetPartColor(APart, AState);
  if LowColors then Exit;
  case APart of
    DXBAR_APPLICATIONMENUCONTENTSIDES: Result := $504F4F;
    DXBAR_APPLICATIONMENUCONTENTOUTERBORDER: Result := $716C6B;
    DXBAR_APPLICATIONMENUCONTENTINNERBORDER: Result := $414243;
    DXBAR_MENUEDITSEPARATOR:
      case AState of
        DXBAR_ACTIVE:  Result := $85B6CA;
        DXBAR_ACTIVEDISABLED:  Result := $CDCDCD;
      end;
    DXBAR_MENUITEMTEXT:
      if not (AState in [DXBAR_DISABLED, DXBAR_ACTIVEDISABLED]) then
        Result := RibbonItemText;
    DXBAR_EDIT_BORDER:
      case AState of
        DXBAR_NORMAL: Result := RibbonEditNormalBorderColor;
        DXBAR_HOT, DXBAR_ACTIVE, DXBAR_ACTIVEDISABLED: Result := RibbonEditHotBorderColor;
        DXBAR_DISABLED: Result := RibbonEditDisabledBorderColor;
        DXBAR_FOCUSED, DXBAR_DROPPEDDOWN: Result := RibbonEditHotBorderColor;
      end;
    DXBAR_EDIT_BACKGROUND:
      case AState of
        DXBAR_NORMAL: Result := $E8E8E8;
        DXBAR_HOT, DXBAR_ACTIVE, DXBAR_ACTIVEDISABLED: Result := RibbonEditHotBackgroundColor;
        DXBAR_DISABLED: Result := $EFEFEF;
        DXBAR_FOCUSED, DXBAR_DROPPEDDOWN: Result := RibbonEditHotBackgroundColor;
      end;
    DXBAR_EDIT_BUTTON_BORDER:
      case AState of
        DXBAR_NORMAL: Result := RibbonEditNormalBorderColor;
        DXBAR_ACTIVE: Result := $B7B7B7;
        DXBAR_HOT: Result := $99CEDB;
        DXBAR_PRESSED: Result := $45667B;
        DXBAR_DISABLED, DXBAR_ACTIVEDISABLED: Result := RibbonEditDisabledBorderColor;
        DXBAR_DROPPEDDOWN: Result := $6B99A5;
      end;
    DXBAR_DATENAVIGATOR_HEADER:
      Result := $DAD5D2;
    DXBAR_SEPARATOR_BACKGROUND:
      Result := $EFEBEF;
    DXBAR_SCREENTIP_FOOTERLINE:
      Result := $A49991;
    DXBAR_INRIBBONGALLERY_BACKGROUND:
      if AState in [DXBAR_ACTIVE, DXBAR_HOT] then
        Result := $F7F7F7
      else
        Result := $E2E2DA;
    DXBAR_INRIBBONGALLERY_BORDER:
      Result := $ACACAC;
    DXBAR_GALLERYFILTERBANDTEXT:
      if AState = DXBAR_NORMAL then
        Result := $FFFFFF
      else if AState = DXBAR_HOT then
        Result := $32D2FF
      else
        OutError;
    rspRibbonBackground:
      Result := $535353;
    rspRibbonBottomEdge:
      Result := $626262;
    rfspRibbonForm:
      Result := $696969;
    rspFormCaptionText:
      if AState = DXBAR_NORMAL then
        Result := $FFD1AE
      else
        Result := $E1E1E1;
    rspDocumentNameText:
      if AState = DXBAR_NORMAL then
        Result := $FFFFFF
      else
        Result := $E1E1E1;
    rspTabHeaderText:
      if AState = DXBAR_ACTIVE then
        Result := clBlack
      else
        Result := $FFFFFF;
    rspTabGroupText:
      Result := RibbonItemText;
    rspTabGroupHeaderText:
      Result := $FFFFFF;
    rspStatusBarText:
      case AState of
        DXBAR_NORMAL:
          Result := $FFFFFF;
        DXBAR_HOT:
          Result := clBlack;
        else
          Result := $C2C2C2;
      end;
    rspStatusBarSizeGripColor1:
      Result := $252525;
    rspStatusBarSizeGripColor2:
      Result := $CCCCCC;
  end;
end;

function TdxBlackRibbonSkin.GetName: string;
begin
  Result := 'Black';
end;

procedure TdxBlackRibbonSkin.LoadCustomRibbonSkinBitmap(out ABitmap: GpBitmap);
begin
  LoadBitmapFromStream('RIBBONBLACK', ABitmap);
end;

procedure TdxBlackRibbonSkin.LoadFormSkinBitmap(out ABitmap: GpBitmap);
begin
  LoadBitmapFromStream('FORMBLACK', ABitmap);
end;

{ TdxSilverRibbonSkin }

procedure TdxSilverRibbonSkin.DrawRibbonBottomBorder(DC: HDC; const R: TRect);
var
  R1: TRect;
begin
  R1 := R;
  Dec(R1.Bottom);
  FillRectByColor(DC, R1, $808080);
  OffsetRect(R1, 0, 1);
  FillRectByColor(DC, R1, $DCE1EB);
end;

function TdxSilverRibbonSkin.GetName: string;
begin
  Result := 'Silver';
end;

function TdxSilverRibbonSkin.GetPartColor(APart, AState: Integer): TColor;
const
  RibbonItemText = $5C534C;
begin
  Result := inherited GetPartColor(APart, AState);
  if LowColors then Exit;
  case APart of
    DXBAR_APPLICATIONMENUCONTENTSIDES: Result := $D8D2CD;
    DXBAR_APPLICATIONMENUCONTENTOUTERBORDER: Result := $FAFAFA;
    DXBAR_APPLICATIONMENUCONTENTINNERBORDER: Result := $B4AEA9;
    DXBAR_MENUITEMTEXT:
      if not (AState in [DXBAR_DISABLED, DXBAR_ACTIVEDISABLED]) then
        Result := RibbonItemText;
    DXBAR_INRIBBONGALLERY_BACKGROUND:
      if AState in [DXBAR_ACTIVE, DXBAR_HOT] then
        Result := $F2F1F0
      else
        Result := $ECEAE8;
    DXBAR_INRIBBONGALLERY_BORDER:
      if AState in [DXBAR_ACTIVE, DXBAR_HOT] then
        Result := $A4A4A4
      else
        Result := $B8B1A9;
    DXBAR_GALLERYFILTERBANDTEXT:
      if AState = DXBAR_NORMAL then
        Result := $FFFFFF
      else if AState = DXBAR_HOT then
        Result := $32D2FF
      else
        OutError;
    rspRibbonBackground:
      Result := $DDD4D0;
    rspRibbonBottomEdge:
      Result := $808080;
    rfspRibbonForm:
      Result := $B5AEAA;
    rspFormCaptionText:
      if AState = DXBAR_NORMAL then
        Result := $AA6E35
      else
        Result := $8A8A8A;
    rspDocumentNameText:
      if AState = DXBAR_NORMAL then
        Result := $6A625C
      else
        Result := $8A8A8A;
    rspTabHeaderText:
      Result := $595453;
    rspTabGroupText, rspTabGroupHeaderText:
      Result := RibbonItemText;
    rspStatusBarText:
      if AState in [DXBAR_NORMAL, DXBAR_HOT] then
        Result := $595453
      else
        Result := $8D8D8D;
    rspStatusBarSizeGripColor1:
      Result := $7E77670;
    rspStatusBarSizeGripColor2:
      Result := $D9D0CD;
  end;
end;

procedure TdxSilverRibbonSkin.LoadCustomRibbonSkinBitmap(out ABitmap: GpBitmap);
begin
  LoadBitmapFromStream('RIBBONSILVER', ABitmap);
end;

procedure TdxSilverRibbonSkin.LoadFormSkinBitmap(out ABitmap: GpBitmap);
begin
  LoadBitmapFromStream('FORMSILVER', ABitmap);
end;

procedure CreateSkins;
begin
  if not CheckGdiPlus then Exit;
  SkinManager.AddSkin(TdxBlueRibbonSkin.Create);
  SkinManager.AddSkin(TdxBlackRibbonSkin.Create);
  SkinManager.AddSkin(TdxSilverRibbonSkin.Create);
end;

procedure DestroySkins;
var
  I: Integer;
begin
  for I := SkinManager.SkinCount - 1 downto 0 do
    if SkinManager[I] is TdxCustomRibbonSkin then
      SkinManager.RemoveSkin(SkinManager[I]);
end;

initialization
  dxUnitsLoader.AddUnit(@CreateSkins, @DestroySkins);

finalization
  dxUnitsLoader.RemoveUnit(@DestroySkins);

end.
