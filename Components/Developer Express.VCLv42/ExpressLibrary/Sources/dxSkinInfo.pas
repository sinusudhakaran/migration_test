
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Library classes                   }
{                                                                    }
{           Copyright (c) 2000-2009 Developer Express Inc.           }
{           ALL RIGHTS RESERVED                                      }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSCROSSPLATFORMLIBRARY AND ALL   }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM       }
{   ONLY.                                                            }
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

unit dxSkinInfo;

interface

uses
  Windows, Classes, Graphics, SysUtils, cxClasses, cxGraphics, cxLookAndFeels,
  cxGeometry, cxLookAndFeelPainters, dxSkinsCore, dxSkinsStrs;

type

  { TdxSkinScrollInfo }

  TdxSkinScrollInfo = class(TObject)
  private
    FElement: TdxSkinElement;
    FImageIndex: Integer;
  public
    constructor Create(AElement: TdxSkinElement; AImageIndex: Integer;
      APart: TcxScrollBarPart);
    function Draw(DC: HDC; const R: TRect; AImageIndex: Integer;
      AState: TdxSkinElementState): Boolean;
    property Element: TdxSkinElement read FElement;
    property ImageIndex: Integer read FImageIndex;
  end;

  TdxSkinFormIcon = (sfiMenu, sfiHelp, sfiMinimize, sfiMaximize, sfiRestore, sfiClose);
  TdxSkinFormIcons = set of TdxSkinFormIcon;

  { TdxSkinInfo }

  TdxSkinInfo = class(TcxIUnknownObject, IdxSkinChangeListener, IdxSkinInfo)
  private
    FSkin: TdxSkin;
    procedure SetSkin(ASkin: TdxSkin);
  protected
    Group_Bars: TdxSkinControlGroup;
    Group_Common: TdxSkinControlGroup;
    Group_Docking: TdxSkinControlGroup;
    Group_Editors: TdxSkinControlGroup;
    Group_Form: TdxSkinControlGroup;
    Group_Grid: TdxSkinControlGroup;
    Group_NavBar: TdxSkinControlGroup;
    Group_NavPane: TdxSkinControlGroup;
    Group_Ribbon: TdxSkinControlGroup;
    Group_Scheduler: TdxSkinControlGroup;
    Group_Tabs: TdxSkinControlGroup;
    Group_VGrid: TdxSkinControlGroup;
    //
    CardViewSeparator: TdxSkinElement;
    ClockElements: array[Boolean] of TdxSkinElement;
    CheckboxElement: TdxSkinElement;
    EditButtonElements: array [Boolean] of TdxSkinElement;
    EditButtonGlyphs: array [TcxEditBtnKind] of TdxSkinElement;
    GridGroupByBox: TdxSkinElement;
    GridGroupRow: TdxSkinElement;
    GridLine: TdxSkinElement;
    GridFixedLine: TdxSkinElement;
    IndicatorImages: TdxSkinElement;
    NavigatorGlyphs: TdxSkinElement;
    NavigatorGlyphsVert: TdxSkinElement;
    RadioGroupButton: TdxSkinElement;
    Splitter: array[Boolean] of TdxSkinElement;
    TrackBarThumb: array[Boolean, TcxTrackBarTicksAlign] of TdxSkinElement;
    TrackBarTrack: array[Boolean] of TdxSkinElement;
    VGridCategory: TdxSkinElement;
    VGridLine: array[Boolean] of TdxSkinElement;
    // Colors
    ContentEvenColor: TdxSkinColor;
    ContentOddColor: TdxSkinColor;
    ContentTextColor: TdxSkinColor;
    HeaderBackgroundColor: TdxSkinColor;
    HeaderBackgroundTextColor: TdxSkinColor;
    SelectionColor: TdxSkinColor;
    SelectionTextColor: TdxSkinColor;
    // ExpandButton
    ExpandButton: TdxSkinElement;
    // Footer
    FooterCell, FooterPanel: TdxSkinElement;
    // header
    Header, HeaderSpecial: TdxSkinElement;
    // filter
    FilterButtons: array[Boolean] of TdxSkinElement;
    FilterPanel: TdxSkinElement;
    // Scheduler3
    SchedulerNavigationButtons: array[Boolean] of TdxSkinElement;
    SchedulerNavigationButtonsArrow: array[Boolean] of TdxSkinElement;
    //
    procedure CheckItem(AItem: TObject; const AMessage: string; var ACheckedItem);
    function CreateBlankElement(AGroup: TdxSkinControlGroup; const AName: string): TdxSkinElement;
    function CreateBlankGroup(const AName: string): TdxSkinControlGroup;
    function GetColorByName(AGroup: TdxSkinPersistent; const AName: string): TdxSkinColor;
    function GetIntPropertyByName(AGroup: TdxSkinPersistent; const AName: string): TdxSkinIntegerProperty;
    function GetElementColorProperty(AElement: TdxSkinPersistent; const APropName: string): TColor;
    function GetElementIntProperty(AElement: TdxSkinPersistent; const APropName: string;
      ADefValue: Integer = 0): Integer;
    function GetGroupByName(const AName: string): TdxSkinControlGroup;
    function GetElementByName(AGroup: TdxSkinControlGroup; const AName: string;
      ACreateIfEmpty: Boolean = True): TdxSkinElement;
    procedure InitializeGroups;
    procedure InitializeBarElements;
    procedure InitializeButtonElements;
    procedure InitializeCheckboxElements;
    procedure InitializeClockElements;
    procedure InitializeColors;
    procedure InitializeDockControlElements;
    procedure InitializeEditButtonElements;
    procedure InitializeFilterElements;
    procedure InitializeFooterElements;
    procedure InitializeFormElements;
    procedure InitializeGridElements;
    procedure InitializeGroupBoxElements;
    procedure InitializeHeaderElements;
    procedure InitializeIndicatorImages;
    procedure InitializeNavBarElements;
    procedure InitializeNavigatorElements;
    procedure InitializePageControlElements;
    procedure InitializeProgressBarElements;
    procedure InitializeRadioGroupElements;
    procedure InitializeRibbonColors;
    procedure InitializeRibbonElements;
    procedure InitializeRibbonProperties;
    procedure InitializeSchedulerElements;
    procedure InitializeScrollBarElements;
    procedure InitializeSizeGripElements;
    procedure InitializeSplitterElements;
    procedure InitializeToolTipElements;
    procedure InitializeTrackBarElements;
    procedure InitializeSkinInfo; virtual;

    procedure FinalizeScrollBarElements;
    procedure FinalizeSkinInfo; virtual;
    { IdxSkinInfo }
    function GetSkin: TdxSkin;
    { IdxSkinChangeListener }
    procedure SkinChanged(Sender: TdxSkin); virtual;
  public
    // Button
    ButtonDisabled: TdxSkinColor;
    ButtonElements: TdxSkinElement;
    // Colors
    ContainerBorderColor: TdxSkinColor;
    ContainerHighlightBorderColor: TdxSkinColor;
    ContentColor: TdxSkinColor;
    EditorBackgroundColors: array[TcxEditStateColorKind] of TdxSkinColor;
    EditorTextColors: array[TcxEditStateColorKind] of TdxSkinColor;
    // ProgressBar
    ProgressBarElements: array[Boolean, Boolean] of TdxSkinElement;
    // ScrollBars
    ScrollBar_Elements: array[Boolean, TcxScrollBarPart] of TdxSkinScrollInfo;
    // Label
    LabelLine: array[Boolean] of TdxSkinElement;
    // GroupBox
    GroupBoxCaptionElements: array[TcxGroupBoxCaptionPosition] of TdxSkinElement;
    GroupBoxClient: TdxSkinElement;
    GroupBoxElements: array[TcxGroupBoxCaptionPosition] of TdxSkinElement;
    // DockControl
    DockControlBorder: TdxSkinElement;
    DockControlCaption: TdxSkinElement;
    DockControlCaptionNonFocusedTextColor: TColor;
    DockControlHideBar: TdxSkinElement;
    DockControlHideBarLeft: TdxSkinElement;
    DockControlHideBarRight: TdxSkinElement;
    DockControlHideBarBottom: TdxSkinElement;
    DockControlHideBarButtons: TdxSkinElement;
    DockControlHideBarTextColor: array[Boolean] of TdxSkinColor;
    DockControlIndents: array[0..2] of Integer;
    DockControlTabHeader: TdxSkinElement;
    DockControlTabHeaderBackground: TdxSkinElement;
    DockControlTabHeaderLine: TdxSkinElement;
    DockControlTabTextColor: array[Boolean] of TdxSkinColor;
    DockControlWindowButton: TdxSkinElement;
    DockControlWindowButtonGlyphs: TdxSkinElement;
    // PageControl
    LayoutControlColor: TdxSkinColor;
    PageControlButtonHorz: TdxSkinElement;
    PageControlButtonVert: TdxSkinElement;
    PageControlHeader: TdxSkinElement;
    PageControlIndents: array[0..5] of Integer;
    PageControlPane: TdxSkinElement;
    TabTextColor: TdxSkinColor;
    TabTextColorActive: TdxSkinColor;
    TabTextColorDisabled: TdxSkinColor;
    TabTextColorHot: TdxSkinColor;
    // NavBar
    NavBarBackgroundColor: TdxSkinElement;
    NavBarGroupButtons: array [Boolean] of TdxSkinElement;
    NavBarGroupClient: TdxSkinElement;
    NavBarGroupHeader: TdxSkinElement;
    NavBarItem: TdxSkinElement;
    NavPaneCaptionFontSize: TdxSkinIntegerProperty;
    NavPaneCaptionHeight: TdxSkinIntegerProperty;
    NavPaneCollapseButton: TdxSkinElement;
    NavPaneCollapsedGroupClient: TdxSkinElement;
    NavPaneExpandButton: TdxSkinElement;
    NavPaneFormBorder: TdxSkinElement;
    NavPaneFormSizeGrip: TdxSkinElement;
    NavPaneGroupButton: array[Boolean] of TdxSkinElement;
    NavPaneGroupCaption: TdxSkinElement;
    NavPaneGroupClient: TdxSkinElement;
    NavPaneItem: TdxSkinElement;
    NavPaneOverflowPanel: TdxSkinElement;
    NavPaneOverflowPanelExpandedItem: TdxSkinElement;
    NavPaneOverflowPanelItem: TdxSkinElement;
    NavPaneScrollButtons: array[Boolean] of TdxSkinElement;
    NavPaneSelectedItem: TdxSkinElement;
    NavPaneSplitter: TdxSkinElement;
    // Form
    FormBorderWidths: array[Boolean] of TRect; 
    FormCaptionDelta: Integer;
    FormContent: TdxSkinElement;
    FormFrames: array[Boolean, TcxBorder] of TdxSkinElement;
    FormIcons: array[Boolean, TdxSkinFormIcon] of TdxSkinElement;
    FormInactiveColor: TdxSkinColor;
    FormStatusBar: TdxSkinElement;
    FormTextShadowColor: TdxSkinColor;
    SizeGrip: TdxSkinElement;
    // Scheduler
    SchedulerAllDayArea: array[Boolean] of TdxSkinElement;
    SchedulerAppointment: array[Boolean] of TdxSkinElement;
    SchedulerAppointmentBorder: TdxSkinColor;
    SchedulerAppointmentBorderSize: TdxSkinIntegerProperty;
    SchedulerAppointmentMask: TdxSkinElement;
    SchedulerAppointmentShadow: array[Boolean] of TdxSkinElement;
    SchedulerCurrentTimeIndicator: TdxSkinElement;
    SchedulerMoreButton: TdxSkinElement;
    SchedulerNavigatorColor: TdxSkinColor;
    SchedulerTimeGridCurrentTimeIndicator: TdxSkinElement;
    SchedulerTimeGridHeader: array[Boolean] of TdxSkinElement;
    SchedulerTimeLine: TdxSkinElement;
    SchedulerTimeRuler: TdxSkinElement;
    // Bars
    Bar: TdxSkinElement;
    BarCustomize: TdxSkinElement;
    BarCustomizeVertical: TdxSkinElement;
    BarDisabledTextColor: TdxSkinColor;
    BarDrag: TdxSkinElement;
    BarDragVertical: TdxSkinElement;
    BarSeparator: TdxSkinElement;
    BarVertical: TdxSkinElement;
    BarVerticalSeparator: TdxSkinElement;
    Dock: TdxSkinElement;
    FloatingBar: TdxSkinElement;
    LinkBorderPainter: TdxSkinElement;
    LinkSelected: TdxSkinElement;
    MainMenu: TdxSkinElement;
    MainMenuCustomize: TdxSkinElement;
    MainMenuDrag: TdxSkinElement;
    MainMenuLinkSelected: TdxSkinElement;
    MainMenuVertical: TdxSkinElement;
    PopupMenu: TdxSkinElement;
    PopupMenuCheck: TdxSkinElement;
    PopupMenuExpandButton: TdxSkinElement;
    PopupMenuLinkSelected: TdxSkinElement;
    PopupMenuSeparator: TdxSkinElement;
    PopupMenuSideStrip: TdxSkinElement;
    PopupMenuSideStripNonRecent: TdxSkinElement;
    PopupMenuSplitButton: TdxSkinElement;
    PopupMenuSplitButton2: TdxSkinElement;
    ScreenTipItem: TdxSkinColor;
    ScreenTipSeparator: TdxSkinElement;
    ScreenTipTitleItem: TdxSkinColor;
    ScreenTipWindow: TdxSkinElement;
    //
    RibbonApplicationButton: TdxSkinElement;
    RibbonApplicationMenuBorders: array[Boolean] of TdxSkinElement;
    RibbonButtonArrow: TdxSkinElement;
    RibbonButtonGroup: TdxSkinElement;
    RibbonButtonGroupButton: TdxSkinElement;
    RibbonButtonGroupSeparator: TdxSkinElement;
    RibbonButtonText: array[Boolean] of TColor;
    RibbonCaptionFontDelta: TdxSkinIntegerProperty;
    RibbonCaptionText: array[Boolean] of TColor;
    RibbonCollapsedToolBarBackground: TdxSkinElement;
    RibbonCollapsedToolBarGlyphBackground: TdxSkinElement;
    RibbonDocumentNameTextColor: array[Boolean] of TColor;
    RibbonExtraPaneColor: TdxSkinColor;
    RibbonFormBottom: array[Boolean] of TdxSkinElement;
    RibbonFormCaption: TdxSkinElement;
    RibbonFormLeft: array[Boolean] of TdxSkinElement;
    RibbonFormRight: array[Boolean] of TdxSkinElement;
    RibbonGalleryBackground: TdxSkinElement;
    RibbonGalleryButtonDown: TdxSkinElement;
    RibbonGalleryButtonDropDown: TdxSkinElement;
    RibbonGalleryButtonUp: TdxSkinElement;
    RibbonGalleryGroupCaption: TdxSkinElement;
    RibbonGalleryPane: TdxSkinElement;
    RibbonGallerySizeGrips: TdxSkinElement;
    RibbonGallerySizingPanel: TdxSkinElement;
    RibbonGroupScroll: array[Boolean] of TdxSkinElement;
    RibbonHeaderBackground: TdxSkinElement;
    RibbonIndents: array[0..2] of Integer;
    RibbonLargeButton: TdxSkinElement;
    RibbonLargeSplitButtonBottom: TdxSkinElement;
    RibbonLargeSplitButtonTop: TdxSkinElement;
    RibbonQATCustomizeButtonOutsizeQAT: array[Boolean] of TdxSkinBooleanProperty;
    RibbonQATIndentBeforeCustomizeButton: array[Boolean] of TdxSkinIntegerProperty;
    RibbonQuickToolbar: array[Boolean] of TdxSkinElement;
    RibbonQuickToolbarBelow: TdxSkinElement;
    RibbonQuickToolbarButtonGlyph: TdxSkinElement;
    RibbonQuickToolbarDropDown: TdxSkinElement;
    RibbonQuickToolbarGlyph: TdxSkinElement;
    RibbonSmallButton: TdxSkinElement;
    RibbonSplitButtonLeft: TdxSkinElement;
    RibbonSplitButtonRight: TdxSkinElement;
    RibbonStatusBarBackground: TdxSkinElement;
    RibbonStatusBarButton: TdxSkinElement;
    RibbonStatusBarSeparator: TdxSkinElement;
    RibbonTab: TdxSkinElement;
    RibbonTabGroup: TdxSkinElement;
    RibbonTabGroupHeader: TdxSkinElement;
    RibbonTabPanel: TdxSkinElement;
    RibbonTabPanelGroupButton: TdxSkinElement;
    RibbonTabText: array[Boolean] of TColor;
    // Status bar text colors
    RibbonStatusBarText: TColor;
    RibbonStatusBarTextHot: TColor;
    RibbonStatusBarTextDisabled: TColor;
    //
    constructor Create(ASkin: TdxSkin); virtual;
    destructor Destroy; override;

    property Skin: TdxSkin read FSkin write SetSkin;
  end;

  TdxSkinInfoClass = class of TdxSkinInfo;

implementation

uses
  Math;

{ TdxSkinInfo }

constructor TdxSkinInfo.Create(ASkin: TdxSkin);
begin
  Skin := ASkin;
end;

destructor TdxSkinInfo.Destroy;
var
  ASkin: TdxSkin;
begin
  ASkin := Skin; 
  Skin := nil;
  FreeAndNil(ASkin);
  inherited Destroy;
end;

procedure TdxSkinInfo.CheckItem(
  AItem: TObject; const AMessage: string; var ACheckedItem);
begin
  Assert(AItem <> nil, AMessage);
  TObject(ACheckedItem) := AItem;
end;

function TdxSkinInfo.CreateBlankElement(AGroup: TdxSkinControlGroup;
  const AName: string): TdxSkinElement;
var
  ABitmap: TBitmap;  
begin
  Result := AGroup.AddElement(AName);
  if Result <> nil then
  begin
    Result.Image.States := [esNormal];
    Result.Image.Stretch := smStretch;
    Result.Tag := 2;
    ABitmap := TBitmap.Create;
    try
      ABitmap.Width := 32;
      ABitmap.Height := 32;
      with ABitmap.Canvas do
      begin
        Pen.Color := clRed;
        Pen.Width := 2;
        MoveTo(0, 0);
        LineTo(ABitmap.Width, ABitmap.Height);
        MoveTo(0, ABitmap.Height);
        LineTo(ABitmap.Width, 0);
      end;
      Result.Image.Texture.SetBitmap(ABitmap);
    finally
      ABitmap.Free;
    end;
  end;
end;

function TdxSkinInfo.CreateBlankGroup(const AName: string): TdxSkinControlGroup;
begin
  Result := FSkin.AddGroup(AName);
  if Result <> nil then
    Result.Tag := 2;
end;

function TdxSkinInfo.GetColorByName(AGroup: TdxSkinPersistent;
  const AName: string): TdxSkinColor;
begin
  Result := nil;
  if AGroup <> nil then
  begin
    Result := AGroup.GetPropertyByName(AName) as TdxSkinColor;
    if Result <> nil then
      Result.Tag := 1;
  end;    
end;

function TdxSkinInfo.GetIntPropertyByName(AGroup: TdxSkinPersistent;
  const AName: string): TdxSkinIntegerProperty;
begin
  Result := nil;
  if AGroup <> nil then
  begin
    Result := AGroup.GetPropertyByName(AName) as TdxSkinIntegerProperty;
    if Result <> nil then
      Result.Tag := 1;
  end;
end;

function TdxSkinInfo.GetElementColorProperty(AElement: TdxSkinPersistent;
  const APropName: string): TColor;
var
  AProperty: TdxSkinColor;
begin
  Result := clDefault;
  if AElement <> nil then
  begin
    AProperty := AElement.GetPropertyByName(APropName) as TdxSkinColor;
    if AProperty <> nil then
      Result := AProperty.Value;
  end;
end;

function TdxSkinInfo.GetElementIntProperty(AElement: TdxSkinPersistent;
  const APropName: string; ADefValue: Integer = 0): Integer;
var
  AProperty: TdxSkinIntegerProperty;
begin
  Result := ADefValue;
  if AElement <> nil then
  begin
    AProperty := AElement.GetPropertyByName(APropName) as TdxSkinIntegerProperty;
    if AProperty <> nil then
      Result := AProperty.Value;
  end;
end;

function TdxSkinInfo.GetGroupByName(const AName: string): TdxSkinControlGroup;
begin
  if Skin = nil then
    Result := nil
  else
  begin
    Result := Skin.GetGroupByName(AName);
    if Result = nil then
      Result := CreateBlankGroup(AName)
    else  
      Result.Tag := 1;
  end;    
end;

function TdxSkinInfo.GetElementByName(AGroup: TdxSkinControlGroup;
  const AName: string; ACreateIfEmpty: Boolean = True): TdxSkinElement;
begin
  if AGroup = nil then
    Result := nil
  else
  begin
    Result := AGroup.GetElementByName(AName);
    if Result = nil then
    begin
      if ACreateIfEmpty then
        Result := CreateBlankElement(AGroup, AName);
    end
    else
      Result.Tag := 1;
  end;     
end;

procedure TdxSkinInfo.InitializeGroups;
begin
  Group_Bars := GetGroupByName(sdxSkinGroupBars);
  Group_Common := GetGroupByName(sdxSkinGroupCommon);
  Group_Docking := GetGroupByName(sdxSkinGroupDocking);
  Group_Editors := GetGroupByName(sdxSkinGroupEditors);
  Group_Ribbon := GetGroupByName(sdxSkinGroupRibbon);
  Group_Form := GetGroupByName(sdxSkinGroupForm);
  Group_Grid := GetGroupByName(sdxSkinGroupGrid);
  Group_Tabs := GetGroupByName(sdxSkinGroupTabs);
  Group_Scheduler := GetGroupByName(sdxSkinGroupScheduler);
  Group_VGrid := GetGroupByName(sdxSkinGroupVGrid);
  Group_NavBar := GetGroupByName(sdxSkinGroupNavBar);
  Group_NavPane := GetGroupByName(sdxSkinGroupNavPane);
end;

procedure TdxSkinInfo.InitializeBarElements;
begin
  Bar := GetElementByName(Group_Bars, sdxBarsBar);
  BarCustomize := GetElementByName(Group_Bars, sdxBarsBarCustomize);
  BarCustomizeVertical := GetElementByName(Group_Bars, sdxBarsBarCustomizeVertical);
  BarDrag := GetElementByName(Group_Bars, sdxBarsBarFinger);
  BarDragVertical := GetElementByName(Group_Bars, sdxBarsBarFingerVertical);
  BarSeparator := GetElementByName(Group_Bars, sdxBarsBarSeparator);
  BarVertical := GetElementByName(Group_Bars, sdxBarsBarVertical);
  BarVerticalSeparator := GetElementByName(Group_Bars, sdxBarsBarVerticalSeparator);
  Dock := GetElementByName(Group_Bars, sdxBarsDock);
  FloatingBar := GetElementByName(Group_Bars, sdxBarsFloatBar);
  LinkBorderPainter := GetElementByName(Group_Bars, sdxBarsLinkStatic);
  LinkSelected := GetElementByName(Group_Bars, sdxBarsLinkSelected);
  MainMenu := GetElementByName(Group_Bars, sdxBarsMainMenu);
  MainMenuCustomize := GetElementByName(Group_Bars, sdxBarsMainMenuCustomize, False);
  MainMenuDrag := GetElementByName(Group_Bars, sdxBarsMainMenuDrag, False);
  MainMenuLinkSelected := GetElementByName(Group_Bars, sdxBarsMainMenuLinkSelected);
  MainMenuVertical := GetElementByName(Group_Bars, sdxBarsMainMenuVertical);
  PopupMenu := GetElementByName(Group_Bars, sdxBarsPopupMenu);
  PopupMenuCheck := GetElementByName(Group_Bars, sdxBarsPopupMenuCheck);
  PopupMenuExpandButton := GetElementByName(Group_Bars, sdxBarsPopupMenuExpandButton);
  PopupMenuLinkSelected := GetElementByName(Group_Bars, sdxBarsPopupMenuLinkSelected);
  PopupMenuSeparator := GetElementByName(Group_Bars, sdxBarsPopupMenuSeparator);
  PopupMenuSideStrip := GetElementByName(Group_Bars, sdxBarsPopupMenuSideStrip);
  PopupMenuSideStripNonRecent := GetElementByName(Group_Bars, sdxBarsPopupMenuSideStripNonRecent);
  PopupMenuSplitButton := GetElementByName(Group_Bars, sdxBarsPopupMenuDropDownButtonLabel);
  PopupMenuSplitButton2 := GetElementByName(Group_Bars, sdxBarsPopupMenuDropDownButtonArrow);
end;

procedure TdxSkinInfo.InitializeButtonElements;
begin
  ButtonElements := GetElementByName(Group_Common, sdxButton);
  ExpandButton := GetElementByName(Group_Grid, sdxPlusMinus);
  if ButtonElements <> nil then
    ButtonDisabled := GetColorByName(ButtonElements, sdxSkinsButtonDisabledTextColor);
end;

procedure TdxSkinInfo.InitializeCheckboxElements;
begin
  CheckboxElement := GetElementByName(Group_Editors, sdxCheckbox);
end;

procedure TdxSkinInfo.InitializeClockElements;
begin
  ClockElements[False] := GetElementByName(Group_Editors, sdxClock);
  ClockElements[True] := GetElementByName(Group_Editors, sdxClockGlass);
end;

procedure TdxSkinInfo.InitializeColors;
var
  AKind: TcxEditStateColorKind; 
begin
  BarDisabledTextColor := GetColorByName(Group_Bars, sdxSkinsBarDisabledTextColor);
  DockControlTabTextColor[False] := GetColorByName(Group_Docking, sdxSkinsTabTextColor);
  DockControlTabTextColor[True] := GetColorByName(Group_Docking, sdxSkinsTabTextColorActive);
  SchedulerNavigatorColor := GetColorByName(Group_Scheduler, sdxSkinsSchedulerNavigatorColor);

  TabTextColor := GetColorByName(PageControlHeader, sdxTextColorNormal);
  TabTextColorActive := GetColorByName(PageControlHeader, sdxTextColorSelected);
  TabTextColorDisabled := GetColorByName(PageControlHeader, sdxTextColorDisabled);
  TabTextColorHot := GetColorByName(PageControlHeader, sdxTextColorHot);

  if Skin <> nil then
  begin
    ContainerBorderColor := Skin.GetColorByName(sdxSkinsContainerBorderColor);
    ContainerHighlightBorderColor := Skin.GetColorByName(sdxSkinsContainerHighlightBorderColor);
    ContentColor := Skin.GetColorByName(sdxSkinsContentColor);
    ContentEvenColor := Skin.GetColorByName(sdxSkinsContentEvenColor);
    ContentOddColor := Skin.GetColorByName(sdxSkinsContentOddColor);
    ContentTextColor := Skin.GetColorByName(sdxSkinsContentTextColor);
    DockControlHideBarTextColor[False] := Skin.GetColorByName(sdxSkinsDCHiddenBarTextColor);
    DockControlHideBarTextColor[True] := Skin.GetColorByName(sdxSkinsDCHiddenBarTextHotColor);
    HeaderBackgroundColor := Skin.GetColorByName(sdxSkinsHeaderBackgroundColor);
    HeaderBackgroundTextColor := Skin.GetColorByName(sdxSkinsHeaderBackgroundTextColor);
    LayoutControlColor := Skin.GetColorByName(sdxSkinsLayoutControlColor);
    SelectionColor := Skin.GetColorByName(sdxSkinsSelectionColor);
    SelectionTextColor := Skin.GetColorByName(sdxSkinsSelectionTextColor);

    for AKind := Low(TcxEditStateColorKind) to High(TcxEditStateColorKind) do
    begin
      EditorTextColors[AKind] := GetColorByName(Group_Editors, EditTextColorsMap[AKind]);
      EditorBackgroundColors[AKind] := GetColorByName(Group_Editors, EditBackgroundColorsMap[AKind]);
    end;
  end;
end;

procedure TdxSkinInfo.InitializeDockControlElements;
begin
  DockControlTabHeaderBackground := GetElementByName(Group_Docking,
    sdxDockCtrlTabHeaderBackground);
  DockControlTabHeaderLine := GetElementByName(Group_Docking,
    sdxDockCtrlTabHeaderLine);
  DockControlHideBarButtons := GetElementByName(Group_Docking,
    sdxDockCtrlTabHeaderAutoHideBar);
  DockControlWindowButton := GetElementByName(Group_Docking, sdxDockCtrlWindowButton);
  DockControlWindowButtonGlyphs := GetElementByName(Group_Docking, sdxDockCtrlWindowGlyphs);
  DockControlTabHeader := GetElementByName(Group_Docking, sdxDockCtrlTabHeader);
  DockControlHideBar := GetElementByName(Group_Docking, sdxDockCtrlAutoHideBar);
  DockControlHideBarLeft := GetElementByName(Group_Docking, sdxDockCtrlAutoHideBarLeft);
  DockControlHideBarRight := GetElementByName(Group_Docking, sdxDockCtrlAutoHideBarRight);
  DockControlHideBarBottom := GetElementByName(Group_Docking, sdxDockCtrlAutoHideBarBottom);

  DockControlCaption := GetElementByName(Group_Docking, sdxDockCtrlCaption);
  DockControlBorder := GetElementByName(Group_Docking, sdxDockCtrlBorder);
  DockControlCaptionNonFocusedTextColor := GetElementColorProperty(DockControlCaption,
    sdxDockCtrlInactiveCaptionTextColor);
    
  FillChar(DockControlIndents, SizeOf(DockControlIndents), 0);
  if Group_Docking <> nil then
  begin
    DockControlIndents[0] := GetElementIntProperty(Group_Docking, sdxDCActiveTabHeaderDownGrow);
    DockControlIndents[1] := GetElementIntProperty(Group_Docking, sdxDCActiveTabHeaderHGrow);
    DockControlIndents[2] := GetElementIntProperty(Group_Docking, sdxDCActiveTabHeaderUpGrow);
  end;
end;

procedure TdxSkinInfo.InitializeEditButtonElements;
var
  AKind: TcxEditBtnKind;
begin
  LabelLine[False] := GetElementByName(Group_Editors, sdxLabelLine);
  LabelLine[True] := GetElementByName(Group_Editors, sdxLabelLineVert);

  EditButtonElements[False] := GetElementByName(Group_Editors, sdxEditorButton);
  EditButtonElements[True] := GetElementByName(Group_Editors, sdxCloseButton);
  for AKind := Low(TcxEditBtnKind) to High(TcxEditBtnKind) do
    EditButtonGlyphs[AKind] := GetElementByName(Group_Editors, EditButtonsMap[AKind]);
end;

procedure TdxSkinInfo.InitializeFilterElements;
begin
  FilterButtons[False] := GetElementByName(Group_Grid, sdxFilterButton);
  FilterButtons[True] := GetElementByName(Group_Grid, sdxFilterButtonActive);
  FilterPanel := GetElementByName(Group_Grid, sdxFilterPanel);
end;

procedure TdxSkinInfo.InitializeFooterElements;
begin
  FooterCell := GetElementByName(Group_Grid, sdxFooterCell);
  FooterPanel := GetElementByName(Group_Grid, sdxFooterPanel);
end;

procedure TdxSkinInfo.InitializeFormElements;

  procedure CorrectStateAndStretch(AElement: TdxSkinElement;
    AInclude, AExclude: TdxSkinElementStates; AStretch: Boolean = False);
  begin
    if AElement = nil then Exit;
    AElement.Image.States := AElement.Image.States + AInclude - AExclude;
    if AStretch then
      AElement.Image.Stretch := smStretch;
  end;

  function CorrectElementMargins(const R: TRect; ASize: TSize; ASide: TcxBorder): TRect;
  begin
    Result := R;
    case ASide of
      bLeft:
        if ASize.cx = 1 then
        begin
          Result.Left := 1;
          Result.Right := 0;
        end;
      bRight:
        if ASize.cx = 1 then
        begin
          Result.Right := 1;
          Result.Left := 0;
        end;
      bBottom:
        if ASize.cy = 1 then
        begin
          Result.Top := 0;
          Result.Bottom := 1;
        end;
    end;
  end;

  procedure GetFormBorderSize(var R: TRect; const AElement: TdxSkinElement;
    ASide: TcxBorder);
  begin
    if AElement = nil then Exit;
    case ASide of
      bLeft:
        R.Left := AElement.Size.cx;
      bRight:
        R.Right := AElement.Size.cx;
      bBottom:
        R.Bottom := AElement.Size.cy;
    end;
  end;

var
  R: TRect;
  ASide: TcxBorder;
  AStandard: Boolean;
  AIcon: TdxSkinFormIcon;
begin
  FillChar(FormIcons, SizeOf(FormIcons), 0);
  FormInactiveColor := GetColorByName(Group_Form, sdxTextInactiveColor);
  FormTextShadowColor := GetColorByName(Group_Form, sdxTextShadowColor);
  FormStatusBar := GetElementByName(Group_Bars, sdxStatusBar);
  FormIcons[False, sfiClose] := GetElementByName(Group_Form, sdxSmallFormButtonClose);
  FormIcons[True, sfiClose] := GetElementByName(Group_Form, sdxFormButtonClose);
  FormIcons[True, sfiMinimize] := GetElementByName(Group_Form, sdxFormButtonMinimize);
  FormIcons[True, sfiMaximize] := GetElementByName(Group_Form, sdxFormButtonMaximize);
  FormIcons[True, sfiRestore] := GetElementByName(Group_Form, sdxFormButtonRestore);
  FormIcons[True, sfiHelp] := GetElementByName(Group_Form, sdxFormButtonHelp);
  FormContent := GetElementByName(Group_Form, sdxFormContent);

  for AStandard := False to True do
    for ASide := Low(TcxBorder) to High(TcxBorder) do
      FormFrames[AStandard, ASide] := GetElementByName(Group_Form,
        FormFrameMap[AStandard, ASide]);

  if Skin = nil then Exit;  
  Skin.BeginUpdate;
  try
    for AStandard := False to True do
    begin
      R := cxNullRect;
      for AIcon := sfiMenu to sfiClose do
        CorrectStateAndStretch(FormIcons[AStandard, AIcon],
          [esActiveDisabled], [esActive], True);
          
      for ASide := Low(TcxBorder) to High(TcxBorder) do
        if FormFrames[AStandard, ASide] <> nil then
        begin
          CorrectStateAndStretch(FormFrames[AStandard, ASide],
            [esActive, esActiveDisabled], [esNormal]);
          GetFormBorderSize(R, FormFrames[AStandard, ASide], ASide);
          with FormFrames[AStandard, ASide].Image do
            Margins.Rect := CorrectElementMargins(Margins.Rect, Size, ASide);
        end;
      FormBorderWidths[AStandard] := R;
    end;
    FormCaptionDelta := Max(1, 
      GetElementIntProperty(FormFrames[True, bTop], sdxCaptionFontDelta));
  finally
    Skin.CancelUpdate;
  end;
end;

procedure TdxSkinInfo.InitializeGroupBoxElements;
begin
  GroupBoxClient := GetElementByName(Group_Common, sdxGroupPanelNoBorder);
  GroupBoxElements[cxgpTop] := GetElementByName(Group_Common, sdxGroupPanelTop);
  GroupBoxElements[cxgpBottom] := GetElementByName(Group_Common, sdxGroupPanelBottom);
  GroupBoxElements[cxgpLeft] := GetElementByName(Group_Common, sdxGroupPanelLeft);
  GroupBoxElements[cxgpRight] := GetElementByName(Group_Common, sdxGroupPanelRight);
  GroupBoxElements[cxgpCenter] := GetElementByName(Group_Common, sdxGroupPanel);

  GroupBoxCaptionElements[cxgpTop] := GetElementByName(Group_Common, sdxGroupPanelCaptionTop);
  GroupBoxCaptionElements[cxgpBottom] := GetElementByName(Group_Common, sdxGroupPanelCaptionBottom);
  GroupBoxCaptionElements[cxgpLeft] := GetElementByName(Group_Common, sdxGroupPanelCaptionLeft);
  GroupBoxCaptionElements[cxgpRight] := GetElementByName(Group_Common, sdxGroupPanelCaptionRight);
end;

procedure TdxSkinInfo.InitializeGridElements;
begin
  GridFixedLine := GetElementByName(Group_Grid, sdxGridFixedLine);
  CardViewSeparator := GetElementByName(Group_Grid, sdxCardSeparator);
  GridGroupByBox := GetElementByName(Group_Grid, sdxGroupByBox);
  if (GridGroupByBox <> nil) and not GridGroupByBox.Image.Empty then
    GridGroupByBox.Color := clNone;
  GridGroupRow := GetElementByName(Group_Grid, sdxGroupRow);
  GridLine := GetElementByName(Group_Grid, sdxGridLine);
  VGridCategory := GetElementByName(Group_VGrid, sdxVGridRowHeader);
  VGridLine[False] := GetElementByName(Group_VGrid, sdxVGridLine);
  VGridLine[True] := GetElementByName(Group_VGrid, sdxVGridBandLine);
end;

procedure TdxSkinInfo.InitializeHeaderElements;
begin
  Header := GetElementByName(Group_Common, sdxHeader);
  HeaderSpecial := GetElementByName(Group_Common, sdxHeaderSpecial);
end;

procedure TdxSkinInfo.InitializeIndicatorImages;
begin
  IndicatorImages := GetElementByName(Group_Grid, sdxIndicatorImages);
end;

procedure TdxSkinInfo.InitializeNavBarElements;
begin
  NavBarBackgroundColor := GetElementByName(Group_NavBar, sdxNavBarBackground);
  NavBarGroupClient := GetElementByName(Group_NavBar, sdxNavBarGroupClient);
  NavBarItem := GetElementByName(Group_NavBar, sdxNavBarItem);
  NavBarGroupHeader := GetElementByName(Group_NavBar, sdxNavBarGroupHeader);
  NavBarGroupButtons[True] := GetElementByName(Group_NavBar, sdxNavBarGroupCloseButton);
  NavBarGroupButtons[False] := GetElementByName(Group_NavBar, sdxNavBarGroupOpenButton);
  NavPaneCollapseButton := GetElementByName(Group_NavPane, sdxNavPaneCollapseButton);
  NavPaneCollapsedGroupClient := GetElementByName(Group_NavPane, sdxNavPaneCollapsedGroupClient);
  NavPaneExpandButton := GetElementByName(Group_NavPane, sdxNavPaneExpandButton);
  NavPaneFormBorder := GetElementByName(Group_NavPane, sdxNavPaneFormBorder);
  NavPaneFormSizeGrip := GetElementByName(Group_NavPane, sdxNavPaneFormSizeGrip);
  NavPaneGroupButton[False] := GetElementByName(Group_NavPane, sdxNavPaneGroupButton);
  NavPaneGroupButton[True] := GetElementByName(Group_NavPane, sdxNavPaneGroupButtonSelected);
  NavPaneGroupCaption := GetElementByName(Group_NavPane, sdxNavPaneGroupCaption);
  NavPaneSplitter := GetElementByName(Group_NavPane, sdxNavPaneSplitter);
  NavPaneScrollButtons[False] := GetElementByName(Group_NavPane, sdxNavPaneScrollUpBtn);
  NavPaneScrollButtons[True] := GetElementByName(Group_NavPane, sdxNavPaneScrollDownBtn);
  NavPaneOverflowPanel := GetElementByName(Group_NavPane, sdxNavPaneOverflowPanel);
  NavPaneOverflowPanelItem := GetElementByName(Group_NavPane, sdxNavPaneOverflowPanelItem);
  NavPaneOverflowPanelExpandedItem := GetElementByName(Group_NavPane, sdxNavPaneOverflowPanelExpandItem);
  NavPaneGroupClient := GetElementByName(Group_NavPane, sdxNavPaneGroupClient);
  NavPaneItem := GetElementByName(Group_NavPane, sdxNavPaneItem);
  NavPaneSelectedItem := GetElementByName(Group_NavPane, sdxNavPaneItemSelected);
  NavPaneCaptionHeight := GetIntPropertyByName(NavPaneGroupCaption, sdxNavPaneCaptionHeight);
  NavPaneCaptionFontSize := GetIntPropertyByName(NavPaneGroupCaption, sdxNavPaneCaptionFontSize);
end;

procedure TdxSkinInfo.InitializeNavigatorElements;
begin
  NavigatorGlyphs := GetElementByName(Group_Editors, sdxNavigatorGlyphs);
  NavigatorGlyphsVert := GetElementByName(Group_Editors, sdxNavigatorGlyphsVert);
end;

procedure TdxSkinInfo.InitializePageControlElements;
begin
  PageControlHeader := GetElementByName(Group_Tabs, sdxPageControlHeaderTop);
  PageControlButtonHorz := GetElementByName(Group_Tabs, sdxPageControlHorz);
  PageControlButtonVert := GetElementByName(Group_Tabs, sdxPageControlVert);
  if FormContent <> nil then
  begin
    if PageControlButtonHorz <> nil then
      PageControlButtonHorz.Color := FormContent.Color;
    if PageControlButtonVert <> nil then
      PageControlButtonVert.Color := FormContent.Color;
  end;
  PageControlPane := GetElementByName(Group_Tabs, sdxPageControlPane);
  FillChar(PageControlIndents, SizeOf(PageControlIndents), 0);
  if Group_Tabs <> nil then
  begin
    PageControlIndents[0] := GetElementIntProperty(Group_Tabs, sdxRowIndentFar);
    PageControlIndents[1] := GetElementIntProperty(Group_Tabs, sdxRowIndentNear);
    PageControlIndents[2] := GetElementIntProperty(Group_Tabs, sdxSelectedHeaderDownGrow);
    PageControlIndents[3] := GetElementIntProperty(Group_Tabs, sdxSelectedHeaderHGrow);
    PageControlIndents[4] := GetElementIntProperty(Group_Tabs, sdxSelectedHeaderUpGrow);
    PageControlIndents[5] := GetElementIntProperty(Group_Tabs, sdxHeaderDownGrow);
  end;
end;

procedure TdxSkinInfo.InitializeProgressBarElements;
begin
  ProgressBarElements[False, False] := GetElementByName(Group_Editors, sdxProgressBorder);
  ProgressBarElements[False, True] := GetElementByName(Group_Editors, sdxProgressBorderVert);
  ProgressBarElements[True, False] := GetElementByName(Group_Editors, sdxProgressChunk);
  ProgressBarElements[True, True] := GetElementByName(Group_Editors, sdxProgressChunkVert);
end;

procedure TdxSkinInfo.InitializeRadioGroupElements;
begin
  RadioGroupButton := GetElementByName(Group_Editors, sdxRadioGroup);
end;

procedure TdxSkinInfo.InitializeRibbonColors;

  function GetElementTextColor(AElement: TdxSkinElement): TColor;
  begin
    if AElement = nil then
      Result := clDefault
    else
      Result := AElement.TextColor;
  end;

begin
  RibbonExtraPaneColor := GetColorByName(Group_Ribbon, sdxRibbonExtraPaneColor);

  RibbonCaptionText[False] := GetElementColorProperty(RibbonFormCaption, sdxTextInactiveColor);
  RibbonCaptionText[True] := GetElementTextColor(RibbonFormCaption);
  RibbonTabText[True] := GetElementColorProperty(RibbonTab, sdxTextColorSelected);
  RibbonTabText[False] := GetElementTextColor(RibbonTab);
  RibbonDocumentNameTextColor[True] := GetElementColorProperty(RibbonFormCaption,
    sdxRibbonDocumentNameTextColor);
  RibbonDocumentNameTextColor[False] := RibbonCaptionText[False];

  RibbonStatusBarText := GetElementColorProperty(RibbonStatusBarButton,
    sdxTextColorNormal);
  RibbonStatusBarTextHot := GetElementColorProperty(RibbonStatusBarButton,
    sdxTextColorHot);
  RibbonStatusBarTextDisabled := GetElementColorProperty(RibbonStatusBarButton,
    sdxTextColorDisabled);

  RibbonButtonText[False] := GetElementTextColor(RibbonSmallButton);
  RibbonButtonText[True] := GetElementColorProperty(Group_Ribbon,
    sdxRibbonButtonDisabledText); 
end;

procedure TdxSkinInfo.InitializeRibbonElements;
begin
  RibbonApplicationButton := GetElementByName(Group_Ribbon, sdxRibbonApplicationButton);
  RibbonApplicationMenuBorders[False] := GetElementByName(Group_Ribbon,
    sdxRibbonAppMenuHeaderBackground);
  RibbonApplicationMenuBorders[True] := GetElementByName(Group_Ribbon,
    sdxRibbonAppMenuFooterBackground);
  RibbonCollapsedToolBarBackground := GetElementByName(Group_Ribbon, sdxRibbonCollapsedToolBarBackground);
  RibbonCollapsedToolBarGlyphBackground := GetElementByName(Group_Ribbon, sdxRibbonCollapsedToolBarGlyphBackground);
  RibbonFormCaption := GetElementByName(Group_Ribbon, sdxRibbonFormCaption);
  RibbonFormBottom[False] := GetElementByName(Group_Ribbon, sdxRibbonFormBottom);
  RibbonFormBottom[True] := GetElementByName(Group_Ribbon, sdxRibbonDialogFrameBottom);
  RibbonFormLeft[False] := GetElementByName(Group_Ribbon, sdxRibbonFormFrameLeft);
  RibbonFormLeft[True] := GetElementByName(Group_Ribbon, sdxRibbonDialogFrameLeft);
  RibbonFormRight[False] := GetElementByName(Group_Ribbon, sdxRibbonFormFrameRight);
  RibbonFormRight[True] := GetElementByName(Group_Ribbon, sdxRibbonDialogFrameRight);
  RibbonTab := GetElementByName(Group_Ribbon, sdxRibbonTabHeaderPage);
  RibbonTabPanel := GetElementByName(Group_Ribbon, sdxRibbonTabPanel);
  RibbonTabPanelGroupButton := GetElementByName(Group_Ribbon, sdxRibbonTabPanelGroupButton);
  RibbonTabGroup := GetElementByName(Group_Ribbon, sdxRibbonTabGroup);
  RibbonTabGroupHeader := GetElementByName(Group_Ribbon, sdxRibbonTabGroupHeader);
  RibbonGalleryBackground := GetElementByName(Group_Ribbon, sdxRibbonGalleryBackground);
  RibbonGalleryButtonDown := GetElementByName(Group_Ribbon, sdxRibbonGalleryButtonDown);
  RibbonGalleryButtonDropDown := GetElementByName(Group_Ribbon, sdxRibbonGalleryButtonDropDown);
  RibbonGalleryButtonUp := GetElementByName(Group_Ribbon, sdxRibbonGalleryButtonUp);
  RibbonGalleryGroupCaption := GetElementByName(Group_Ribbon, sdxRibbonGalleryGroupCaption);
  RibbonGalleryPane := GetElementByName(Group_Ribbon, sdxRibbonGalleryPane);
  RibbonGallerySizingPanel := GetElementByName(Group_Ribbon, sdxRibbonGallerySizingPanel);
  RibbonGallerySizeGrips := GetElementByName(Group_Ribbon, sdxRibbonGallerySizeGrips);
  RibbonHeaderBackground := GetElementByName(Group_Ribbon, sdxRibbonHeaderBackground);
  RibbonSmallButton := GetElementByName(Group_Ribbon, sdxRibbonSmallButton);
  RibbonSplitButtonLeft := GetElementByName(Group_Ribbon, sdxRibbonSplitButtonLeft);
  RibbonSplitButtonRight := GetElementByName(Group_Ribbon, sdxRibbonSplitButtonRight);
  RibbonLargeButton := GetElementByName(Group_Ribbon, sdxRibbonLargeButton);
  RibbonLargeSplitButtonTop := GetElementByName(Group_Ribbon, sdxRibbonLargeSplitButtonTop);
  RibbonLargeSplitButtonBottom := GetElementByName(Group_Ribbon, sdxRibbonLargeSplitButtonBottom);
  RibbonButtonArrow := GetElementByName(Group_Ribbon, sdxRibbonButtonArrow);
  RibbonButtonGroup := GetElementByName(Group_Ribbon, sdxRibbonButtonGroup);
  RibbonStatusBarBackground := GetElementByName(Group_Ribbon, sdxRibbonStatusBarBackground);
  RibbonStatusBarButton := GetElementByName(Group_Ribbon, sdxRibbonStatusBarButton);
  RibbonStatusBarSeparator := GetElementByName(Group_Ribbon, sdxRibbonStatusBarSeparator);
  RibbonQuickToolbar[True] := GetElementByName(Group_Ribbon, sdxRibbonQuickToolbarInCaption);
  RibbonQuickToolbar[False] := GetElementByName(Group_Ribbon, sdxRibbonQuickToolbarAbove);
  RibbonQuickToolbarBelow := GetElementByName(Group_Ribbon, sdxRibbonQuickToolbarBelow);
  RibbonQuickToolbarButtonGlyph := GetElementByName(Group_Ribbon, sdxRibbonQuickToolbarButtonGlyph);
  RibbonQuickToolbarDropDown := GetElementByName(Group_Ribbon, sdxRibbonQuickToolbarDropDown);
  RibbonQuickToolbarGlyph := GetElementByName(Group_Ribbon, sdxRibbonQuickToolbarGlyph);
  RibbonButtonGroupButton := GetElementByName(Group_Ribbon, sdxRibbonButtonGroupButton);
  RibbonButtonGroupSeparator := GetElementByName(Group_Ribbon, sdxRibbonButtonGroupSeparator);
  RibbonGroupScroll[True] := GetElementByName(Group_Ribbon, sdxRibbonTabGroupLeftScroll);
  RibbonGroupScroll[False] := GetElementByName(Group_Ribbon, sdxRibbonTabGroupRightScroll);
  InitializeRibbonProperties;
  InitializeRibbonColors;
end;

procedure TdxSkinInfo.InitializeRibbonProperties;
var
  AIndex: Boolean;
begin
  for AIndex := False to True do
    if RibbonQuickToolbar[AIndex] <> nil then
      with RibbonQuickToolbar[AIndex] do
      begin
        RibbonQATCustomizeButtonOutsizeQAT[AIndex] :=
          GetPropertyByName(sdxRibbonQATCustomizeButtonOutsideQAT) as TdxSkinBooleanProperty;
        RibbonQATIndentBeforeCustomizeButton[AIndex] :=
          GetPropertyByName(sdxRibbonQATIndentBeforeCustomizeItem) as TdxSkinIntegerProperty;
      end;

  RibbonCaptionFontDelta := GetIntPropertyByName(RibbonFormCaption, sdxCaptionFontDelta);
  if Group_Ribbon = nil then
    FillChar(RibbonIndents, SizeOf(RibbonIndents), 0)
  else
  begin
    RibbonIndents[0] := GetElementIntProperty(RibbonApplicationButton,
      sdxRibbonAppButtonRightIndent);
    RibbonIndents[1] := GetElementIntProperty(RibbonQuickToolbar[True],
      sdxRibbonQuickAccessToolbarOffset);
    RibbonIndents[2] := GetElementIntProperty(Group_Ribbon, sdxRibbonTabHeaderDownGrowIndent);
  end;
end;

procedure TdxSkinInfo.InitializeScrollBarElements;

  procedure SetInfo(AHorz: Boolean; APart: TcxScrollBarPart;
    AElement: TdxSkinElement; AImageIndex: Integer = 0);
  begin
    FreeAndNil(ScrollBar_Elements[AHorz, APart]);
    if Skin <> nil then
      ScrollBar_Elements[AHorz, APart] :=
        TdxSkinScrollInfo.Create(AElement, AImageIndex, APart);
  end;

var
  AElement: TdxSkinElement;
begin
  // buttons
  AElement := GetElementByName(Group_Common, sdxScrollButton);
  if FormContent <> nil then
    AElement.Color := FormContent.Color; //todo: transparent elements bug
  SetInfo(False, sbpLineUp, AElement);
  SetInfo(False, sbpLineDown, AElement, 1);
  SetInfo(True, sbpLineUp, AElement, 2);
  SetInfo(True, sbpLineDown, AElement, 3);
  // Thumbnail
  SetInfo(False, sbpThumbnail,
    GetElementByName(Group_Common, sdxScrollThumbButtonVert));
  SetInfo(True, sbpThumbnail,
    GetElementByName(Group_Common, sdxScrollThumbButtonHorz));
  // Page
  AElement := GetElementByName(Group_Common, sdxScrollContentVert);
  SetInfo(False, sbpPageUp, AElement);
  SetInfo(False, sbpPageDown, AElement);
  AElement := GetElementByName(Group_Common, sdxScrollContentHorz);
  SetInfo(True, sbpPageUp, AElement);
  SetInfo(True, sbpPageDown, AElement);
end;

procedure TdxSkinInfo.InitializeSchedulerElements;

  procedure HideElementUsage(AElement: TdxSkinElement);
  begin
    if AElement <> nil then
      AElement.Tag := 0;
  end;

begin
  SchedulerTimeGridHeader[False] := GetElementByName(Group_Scheduler,
    sdxSchedulerTimeGridHeader);
  SchedulerTimeGridHeader[True] := GetElementByName(Group_Scheduler,
    sdxSchedulerTimeGridHeaderSelected);
  SchedulerTimeLine := GetElementByName(Group_Scheduler, sdxSchedulerTimeLine);
  SchedulerTimeRuler := GetElementByName(Group_Scheduler, sdxSchedulerTimeRuler);
  SchedulerMoreButton := GetElementByName(Group_Scheduler, sdxSchedulerMoreButton);
  SchedulerAppointment[False] := GetElementByName(Group_Scheduler, sdxSchedulerAppointmentRight);
  SchedulerAppointment[True] := GetElementByName(Group_Scheduler, sdxSchedulerAppointment);
  SchedulerAllDayArea[False] := GetElementByName(Group_Scheduler, sdxSchedulerAllDayArea);
  SchedulerAllDayArea[True] := GetElementByName(Group_Scheduler, sdxSchedulerAllDayAreaSelected);
  SchedulerCurrentTimeIndicator := GetElementByName(Group_Scheduler,
    sdxSchedulerCurrentTimeIndicator);
  SchedulerAppointmentShadow[False] := GetElementByName(Group_Scheduler,
    sdxSchedulerAppointmentBottomShadow);
  SchedulerAppointmentShadow[True] := GetElementByName(Group_Scheduler,
    sdxSchedulerAppointmentRightShadow);
  SchedulerAppointmentBorderSize := GetIntPropertyByName(SchedulerAppointment[True],
    sdxSchedulerAppointmentBorderSize);
  SchedulerAppointmentMask := GetElementByName(Group_Scheduler, sdxSchedulerAppointmentMask);
  SchedulerAppointmentBorder := GetColorByName(SchedulerAppointment[True],
    sdxSchedulerSeparatorColor);
  SchedulerNavigationButtons[False] := GetElementByName(Group_Scheduler, sdxSchedulerNavButtonPrev);
  SchedulerNavigationButtons[True] := GetElementByName(Group_Scheduler, sdxSchedulerNavButtonNext);
  SchedulerNavigationButtonsArrow[False] := GetElementByName(Group_Scheduler,
    sdxSchedulerNavButtonPrevArrow);
  SchedulerNavigationButtonsArrow[True] := GetElementByName(Group_Scheduler,
    sdxSchedulerNavButtonNextArrow);
    
  // TODO: Its a scheduler3 element - ACreateIfEmpty = False
  SchedulerTimeGridCurrentTimeIndicator := GetElementByName(Group_Scheduler,
    sdxSchedulerTimeGridCurrentTimeIndicator, False);
end;

procedure TdxSkinInfo.InitializeSizeGripElements;
begin
  SizeGrip := GetElementByName(Group_Common, sdxSizeGrip);
end;

procedure TdxSkinInfo.InitializeSplitterElements;
begin
  Splitter[False] := GetElementByName(Group_Common, sdxSplitterVert);
  Splitter[True] := GetElementByName(Group_Common, sdxSplitterHorz);
end;

procedure TdxSkinInfo.InitializeToolTipElements;
begin
  ScreenTipWindow := GetElementByName(Group_Bars, sdxScreenTipWindow);
  ScreenTipItem := GetColorByName(ScreenTipWindow, sdxScreenTipItem);
  ScreenTipSeparator := GetElementByName(Group_Bars, sdxScreenTipSeparator);
  ScreenTipTitleItem := GetColorByName(ScreenTipWindow, sdxScreenTipTitleItem);
end;

procedure TdxSkinInfo.InitializeTrackBarElements;
begin
  TrackBarTrack[True] := GetElementByName(Group_Editors, sdxTrackBarTrack);
  TrackBarTrack[False] := GetElementByName(Group_Editors, sdxTrackBarTrackVert);

  TrackBarThumb[True, tbtaDown] := GetElementByName(Group_Editors, sdxTrackBarThumb);
  TrackBarThumb[True, tbtaUp] := GetElementByName(Group_Editors, sdxTrackBarThumbUp);
  TrackBarThumb[True, tbtaBoth] := GetElementByName(Group_Editors, sdxTrackBarThumbBoth);

  TrackBarThumb[False, tbtaDown] := GetElementByName(Group_Editors, sdxTrackBarThumbVert);
  TrackBarThumb[False, tbtaUp] := GetElementByName(Group_Editors, sdxTrackBarThumbVertUp);
  TrackBarThumb[False, tbtaBoth] := GetElementByName(Group_Editors, sdxTrackBarThumbVertBoth);
end;

procedure TdxSkinInfo.InitializeSkinInfo;
begin
  InitializeGroups;
  InitializeBarElements;
  InitializeFormElements;
  InitializeDockControlElements;
  InitializeButtonElements;
  InitializeFooterElements;
  InitializeCheckboxElements;
  InitializeClockElements;
  InitializeEditButtonElements;
  InitializeGroupBoxElements;
  InitializeGridElements;
  InitializeIndicatorImages;
  InitializeNavBarElements;
  InitializeNavigatorElements;
  InitializeSchedulerElements;
  InitializeHeaderElements;
  InitializeFilterElements;
  InitializePageControlElements;
  InitializeProgressBarElements;
  InitializeRadioGroupElements;
  InitializeScrollBarElements;
  InitializeRibbonElements;
  InitializeSizeGripElements;
  InitializeSplitterElements;
  InitializeTrackBarElements;
  InitializeToolTipElements;
  InitializeColors;
end;

procedure TdxSkinInfo.FinalizeScrollBarElements;
var
  AHorz: Boolean;
  APart: TcxScrollBarPart;
begin
  for AHorz := False to True do
    for APart := Low(TcxScrollBarPart) to High(TcxScrollBarPart) do
      FreeAndNil(ScrollBar_Elements[AHorz, APart]);
end;

procedure TdxSkinInfo.FinalizeSkinInfo;
begin
  FinalizeScrollBarElements;
end;

function TdxSkinInfo.GetSkin: TdxSkin;
begin
  Result := Skin;
end;

procedure TdxSkinInfo.SkinChanged(Sender: TdxSkin);
begin
  FinalizeSkinInfo;
  InitializeSkinInfo;
end;

procedure TdxSkinInfo.SetSkin(ASkin: TdxSkin);
begin
  if ASkin <> Skin then
  begin
    if Skin <> nil then
    begin
      FinalizeSkinInfo;
      Skin.RemoveListener(Self);
    end;
    FSkin := ASkin;
    if Skin <> nil then
      Skin.AddListener(Self);
    InitializeSkinInfo;
  end;
end;

{ TdxSkinScrollInfo }

constructor TdxSkinScrollInfo.Create(AElement: TdxSkinElement;
  AImageIndex: Integer; APart: TcxScrollBarPart);
begin
  FElement := AElement;
  FImageIndex := AImageIndex;
end;

function TdxSkinScrollInfo.Draw(DC: HDC; const R: TRect; AImageIndex: Integer;
  AState: TdxSkinElementState): Boolean;
begin
  Result := Element <> nil;
  if Result then
    Element.Draw(DC, R, AImageIndex, AState);
end;

end.
