{***************************************************************************}
{ TAdvOfficeTabSet component                                                }
{ for Delphi & C++Builder                                                   }
{ version 1.0                                                               }
{                                                                           }
{ written by TMS Software                                                   }
{            copyright © 2006                                               }
{            Email : info@tmssoftware.com                                   }
{            Web : http://www.tmssoftware.com                               }
{                                                                           }
{ The source code is given as is. The author is not responsible             }
{ for any possible damage done due to the use of this code.                 }
{ The component can be freely used in any application. The complete         }
{ source code remains property of the author and may not be distributed,    }
{ published, given or sold in any form as such. No parts of the source      }
{ code can be included in any other component or application without        }
{ written authorization of the author.                                      }
{***************************************************************************}

unit AdvOfficeTabSet;

{$I TMSDEFS.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Math, Menus,
  Dialogs, Forms, ImgList, CommCtrl, ExtCtrls, ComCtrls, AdvGDIP, GDIPicture,
  AdvHintInfo, AdvGlowButton;

{$R ADVOFFICETABSET.RES}

const
  GLOWSPEED = 50;
  IMG_SPACE = 2;
  DEFAULT_TABHEIGHT = 26;
  ADVPAGE_OFFSET = 1;
  SCROLLER_SIZE = 32;
  TabBUTTON_SIZE = 18;

  MAJ_VER = 1; // Major version nr.
  MIN_VER = 1; // Minor version nr.
  REL_VER = 1; // Release nr.
  BLD_VER = 0; // Build nr.

  // version history
  // 1.0.0.1 : Fixed issue with hidden tabs & scrolling
  // 1.0.0.2 : Fixed issue with deleting tabs
  // 1.1.0.0 : New : property TabRearrange added
  //         : New : OnTabMoved event added
  //         : New : TAdvOfficeMDITabSet
  // 1.1.1.0 : New : Office 2007 silver style added
  //         : Fixed : issue with close button position 

type
  TAdvCustomOfficeTabSet = class;
  TAdvOfficeTabSet = class;

  TGradientDirection = (gdHorizontal, gdVertical);
  TGlowState = (gsHover, gsPush, gsNone);
  TButtonLayout = (blGlyphLeft, blGlyphTop, blGlyphRight, blGlyphBottom);
  TDropDownPosition = (dpRight, dpBottom);
  //TGDIPGradient = (ggRadial, ggVertical, ggDiagonalForward, ggDiagonalBackward);
  //TAntiAlias = (aaNone, aaClearType, aaAntiAlias);

  TTabMovedEvent = procedure (Sender : TObject; FromIndex, ToIndex: integer) of object;

  TTabSetTabSettings = class(TPersistent)
  private
    FLeftMargin: Integer;
    FRightMargin: Integer;
    FOnChange: TNotifyEvent;
    FHeight: Integer;
    FStartMargin: Integer;
    FEndMargin: Integer;
    FSpacing: Integer;
    procedure SetLeftMargin(const Value: Integer);
    procedure SetRightMargin(const Value: Integer);
    procedure SetHeight(const Value: Integer);
    procedure SetStartMargin(const Value: Integer);
    procedure SetEndMargin(const Value: Integer);
    procedure SetSpacing(const Value: Integer);
  protected
    procedure Changed;
    property EndMargin: Integer read FEndMargin write SetEndMargin;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property LeftMargin: Integer read FLeftMargin write SetLeftMargin default 4;
    property RightMargin: Integer read FRightMargin write SetRightMargin default 4;
    property StartMargin: Integer read FStartMargin write SetStartMargin default 60;
    property Height: Integer read FHeight write SetHeight default 26;
    property Spacing: Integer read FSpacing write SetSpacing default 4;
  end;

  TGradientBackground = class(TPersistent)
  private
    FSteps: Integer;
    FColor: TColor;
    FColorTo: TColor;
    FDirection: TGradientDirection;
    FOnChange: TNotifyEvent;
    procedure SetColor(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetDirection(const Value: TGradientDirection);
    procedure SetSteps(const Value: Integer);
    procedure Changed;
  protected
  public
    constructor Create; 
    procedure Assign(Source: TPersistent); override;  
  published
    property Color: TColor read FColor write SetColor;
    property ColorTo: TColor read FColorTo write SetColorTo;
    property Direction: TGradientDirection read FDirection write SetDirection;
    property Steps: Integer read FSteps write SetSteps default 64;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TVistaBackground = class(TPersistent)
  private
    FSteps: Integer;
    FColor: TColor;
    FColorTo: TColor;
    FOnChange: TNotifyEvent;
    FColorMirror: TColor;
    FColorMirrorTo: TColor;
    FBorderColor: TColor;
    FGradientMirror: TGDIPGradient;
    FGradient: TGDIPGradient;
    procedure SetColor(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetSteps(const Value: Integer);
    procedure Changed;
    procedure SetBorderColor(const Value: TColor);
    procedure SetColorMirror(const Value: TColor);
    procedure SetColorMirrorTo(const Value: TColor);
    procedure SetGradient(const Value: TGDIPGradient);
    procedure SetGradientMirror(const Value: TGDIPGradient);
  protected
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property Color: TColor read FColor write SetColor;
    property ColorTo: TColor read FColorTo write SetColorTo;
    property ColorMirror: TColor read FColorMirror write SetColorMirror;
    property ColorMirrorTo: TColor read FColorMirrorTo write SetColorMirrorTo;
    property Gradient: TGDIPGradient read FGradient write SetGradient;
    property GradientMirror: TGDIPGradient read FGradientMirror write SetGradientMirror;
    property Steps: Integer read FSteps write SetSteps default 64;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TCustomTabAppearance = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FBorderColor: TColor;
    FBorderColorHot: TColor;
    FColor: TColor;
    FColorTo: TColor;
    FColorHot: TColor;
    FColorHotTo: TColor;
    FColorSelectedTo: TColor;
    FBorderColorDisabled: TColor;
    FBorderColorSelected: TColor;
    FColorDisabled: TColor;
    FColorDisabledTo: TColor;
    FColorSelected: TColor;
    FColorMirror: TColor;
    FColorMirrorTo: TColor;
    FColorMirrorHot: TColor;
    FColorMirrorHotTo: TColor;
    FGradientMirror: TGDIPGradient;
    FGradientMirrorHot: TGDIPGradient;
    FGradient: TGDIPGradient;
    FGradientHot: TGDIPGradient;
    FColorMirrorDisabledTo: TColor;
    FColorMirrorDisabled: TColor;
    FColorMirrorSelectedTo: TColor;
    FColorMirrorSelected: TColor;
    FGradientSelected: TGDIPGradient;
    FGradientDisabled: TGDIPGradient;
    FGradientMirrorSelected: TGDIPGradient;
    FGradientMirrorDisabled: TGDIPGradient;
    FTextColorDisabled: TColor;
    FTextColorSelected: TColor;
    FTextColor: TColor;
    FTextColorHot: TColor;
    FBackGround: TGradientBackground;
    FBorderColorSelectedHot: TColor;
    FBorderColorDown: TColor;
    FFont: TFont;
    procedure OnBackGroundChanged(Sender: TObject);
    procedure SetBackGround(const Value: TGradientBackground);
    procedure SetBorderColor(const Value: TColor);
    procedure SetBorderColorDisabled(const Value: TColor);
    procedure SetBorderColorSelected(const Value: TColor);
    procedure SetBorderColorSelectedHot(const Value: TColor);
    procedure SetColor(const Value: TColor);
    procedure SetColorDisabled(const Value: TColor);
    procedure SetColorDisabledTo(const Value: TColor);
    procedure SetColorHot(const Value: TColor);
    procedure SetColorHotTo(const Value: TColor);
    procedure SetColorMirror(const Value: TColor);
    procedure SetColorMirrorDisabled(const Value: TColor);
    procedure SetColorMirrorDisabledTo(const Value: TColor);
    procedure SetColorMirrorHot(const Value: TColor);
    procedure SetColorMirrorHotTo(const Value: TColor);
    procedure SetColorMirrorSelected(const Value: TColor);
    procedure SetColorMirrorSelectedTo(const Value: TColor);
    procedure SetColorMirrorTo(const Value: TColor);
    procedure SetColorSelected(const Value: TColor);
    procedure SetColorSelectedTo(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetGradient(const Value: TGDIPGradient);
    procedure SetGradientDisabled(const Value: TGDIPGradient);
    procedure SetGradientHot(const Value: TGDIPGradient);
    procedure SetGradientMirror(const Value: TGDIPGradient);
    procedure SetGradientMirrorDisabled(const Value: TGDIPGradient);
    procedure SetGradientMirrorHot(const Value: TGDIPGradient);
    procedure SetGradientMirrorSelected(const Value: TGDIPGradient);
    procedure SetGradientSelected(const Value: TGDIPGradient);
    procedure SetTextColor(const Value: TColor);
    procedure SetTextColorDisabled(const Value: TColor);
    procedure SetTextColorHot(const Value: TColor);
    procedure SetTextColorSelected(const Value: TColor);
    procedure SetBorderColorDown(const Value: TColor);
    procedure SetFont(const Value: TFont);
  protected
    procedure Changed;
    property BackGround: TGradientBackground read FBackGround write SetBackGround;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property BorderColorHot: TColor read FBorderColorHot write FBorderColorHot;
    property BorderColorSelected: TColor read FBorderColorSelected write SetBorderColorSelected;
    property BorderColorSelectedHot: TColor read FBorderColorSelectedHot write SetBorderColorSelectedHot;
    property BorderColorDisabled: TColor read FBorderColorDisabled write SetBorderColorDisabled;
    property BorderColorDown: TColor read FBorderColorDown write SetBorderColorDown;
    property Color: TColor read FColor write SetColor;
    property ColorTo: TColor read FColorTo write SetColorTo;
    property ColorSelected: TColor read FColorSelected write SetColorSelected;
    property ColorSelectedTo: TColor read FColorSelectedTo write SetColorSelectedTo;
    property ColorDisabled: TColor read FColorDisabled write SetColorDisabled;
    property ColorDisabledTo: TColor read FColorDisabledTo write SetColorDisabledTo;
    property ColorHot: TColor read FColorHot write SetColorHot;
    property ColorHotTo: TColor read FColorHotTo write SetColorHotTo;
    property ColorMirror: TColor read FColorMirror write SetColorMirror;
    property ColorMirrorTo: TColor read FColorMirrorTo write SetColorMirrorTo;
    property ColorMirrorHot: TColor read FColorMirrorHot write SetColorMirrorHot;
    property ColorMirrorHotTo: TColor read FColorMirrorHotTo write SetColorMirrorHotTo;
    property ColorMirrorSelected: TColor read FColorMirrorSelected write SetColorMirrorSelected;
    property ColorMirrorSelectedTo: TColor read FColorMirrorSelectedTo write SetColorMirrorSelectedTo;
    property ColorMirrorDisabled: TColor read FColorMirrorDisabled write SetColorMirrorDisabled;
    property ColorMirrorDisabledTo: TColor read FColorMirrorDisabledTo write SetColorMirrorDisabledTo;
    property Font: TFont read FFont write SetFont;
    property Gradient: TGDIPGradient read FGradient write SetGradient;
    property GradientMirror: TGDIPGradient read FGradientMirror write SetGradientMirror;
    property GradientHot: TGDIPGradient read FGradientHot write SetGradientHot;
    property GradientMirrorHot: TGDIPGradient read FGradientMirrorHot write SetGradientMirrorHot;
    property GradientSelected: TGDIPGradient read FGradientSelected write SetGradientSelected;
    property GradientMirrorSelected: TGDIPGradient read FGradientMirrorSelected write SetGradientMirrorSelected;
    property GradientDisabled: TGDIPGradient read FGradientDisabled write SetGradientDisabled;
    property GradientMirrorDisabled: TGDIPGradient read FGradientMirrorDisabled write SetGradientMirrorDisabled;
    property TextColor: TColor read FTextColor write SetTextColor;
    property TextColorHot: TColor read FTextColorHot write SetTextColorHot;
    property TextColorSelected: TColor read FTextColorSelected write SetTextColorSelected;
    property TextColorDisabled: TColor read FTextColorDisabled write SetTextColorDisabled;
  end;

  TTabAppearance = class(TCustomTabAppearance)
  private
  protected
  public
  published
    property BackGround;
  end;

  TTabSetTabScroller = class(TObject)
  private
    FMin: integer;
    FMax: integer;
    FPosition: integer;
    FVisible: Boolean;
    procedure SetMax(const Value: integer);
    procedure SetMin(const Value: integer);
    procedure SetPosition(const Value: integer);
    procedure SetVisible(const Value: Boolean);
  protected
  public
    constructor Create;
    function CanGoForward: Boolean;
    function CanGoBack: Boolean;
    property Min: integer read FMin write SetMin;
    property Max: integer read FMax write SetMax;
    property Position: integer read FPosition write SetPosition;
    property Visible: Boolean read FVisible write SetVisible;
  end;

  TDbgList = class(TList)
  private
    function GetItemsEx(Index: Integer): Pointer;
    procedure SetItemsEx(Index: Integer; const Value: Pointer);
  public
    property Items[Index: Integer]: Pointer read GetItemsEx write SetItemsEx; default;
  end;

  TTabSetButtonSettings = class(TPersistent)
  private
    FOnChange: TNotifyEvent;
    FTabListButton: boolean;
    FCloseButton: Boolean;
    FScrollButtonNextPicture: TGDIPPicture;
    FScrollButtonPrevPicture: TGDIPPicture;
    FTabListButtonPicture: TGDIPPicture;
    FCloseButtonPicture: TGDIPPicture;
    FScrollButtonPrevHint: String;
    FScrollButtonNextHint: String;
    FCloseButtonHint: String;
    FTabListButtonHint: String;
    procedure Changed;
    procedure OnPictureChanged(Sender: TObject);
    procedure SetCloseButton(const Value: Boolean);
    procedure SetCloseButtonPicture(const Value: TGDIPPicture);
    procedure SetTabListButton(const Value: boolean);
    procedure SetTabListButtonPicture(const Value: TGDIPPicture);
    procedure SetScrollButtonNextPicture(const Value: TGDIPPicture);
    procedure SetScrollButtonPrevPicture(const Value: TGDIPPicture);
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property CloseButton: Boolean read FCloseButton write SetCloseButton default false;
    property TabListButton: boolean read FTabListButton write SetTabListButton default false;
    property CloseButtonPicture: TGDIPPicture read FCloseButtonPicture write SetCloseButtonPicture;
    property TabListButtonPicture: TGDIPPicture read FTabListButtonPicture write SetTabListButtonPicture;
    property ScrollButtonPrevPicture: TGDIPPicture read FScrollButtonPrevPicture write SetScrollButtonPrevPicture;
    property ScrollButtonNextPicture: TGDIPPicture read FScrollButtonNextPicture write SetScrollButtonNextPicture;
    property CloseButtonHint: String read FCloseButtonHint write FCloseButtonHint;
    property TabListButtonHint: String read FTabListButtonHint write FTabListButtonHint;
    property ScrollButtonNextHint: String read FScrollButtonNextHint write FScrollButtonNextHint;
    property ScrollButtonPrevHint: String read FScrollButtonPrevHint write FScrollButtonPrevHint;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TCustomAdvOfficeTabSetStyler = class(TComponent)
  private
    FControlList: TDbgList;
    FTabAppearance: TTabAppearance;
    FRoundEdges: Boolean;
    FAutoThemeAdapt: boolean;
    FGlowButtonAppearance: TGlowButtonAppearance;
    FBlendFactor: Integer;
    FButtonBorderColor: TColor;
    procedure OnTabAppearanceChanged(Sender: TObject);
    procedure OnGlowButtonAppearanceChanged(Sender: TObject);
    procedure SetRoundEdges(const Value: boolean);
    procedure SetTabAppearance(const Value: TTabAppearance);
    procedure SetGlowButtonAppearance(const Value: TGlowButtonAppearance);
    procedure SetButtonBorderColor(const Value: TColor);
  protected
    procedure AddControl(AControl: TCustomControl);
    procedure RemoveControl(AControl: TCustomControl);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Change(PropID: integer);
    property BlendFactor: Integer read FBlendFactor write FBlendFactor;

    property AutoThemeAdapt: boolean read FAutoThemeAdapt write FAutoThemeAdapt default False;
    property TabAppearance: TTabAppearance read FTabAppearance write SetTabAppearance;  // 1
    property RoundEdges: boolean read FRoundEdges write SetRoundEdges default True;   // 3
    property ButtonBorderColor: TColor read FButtonBorderColor write SetButtonBorderColor;
    property GlowButtonAppearance: TGlowButtonAppearance read FGlowButtonAppearance write SetGlowButtonAppearance; // 4
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure Assign(Source: TPersistent); override;
  end;

  TDummyHintControl = class(TControl)
  private
    FOfficeHint: TAdvHintInfo;
    procedure SetOfficeHint(const Value: TAdvHintInfo);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OfficeHint: TAdvHintInfo read FOfficeHint write SetOfficeHint;
  end;

  TOfficeTabCollectionItem = class(TCollectionItem)
  private
    FCaption: string;
    FVisible: Boolean;
    FTag: integer;
    FImageIndex: Integer;
    FEnabled: boolean;
    FTimer: TTimer;
    FTimeInc: Integer;
    FStepHover: Integer;
    FStepPush: Integer;
    FGlowState: TGlowState;  
    FIPicture: TGDIPPicture;
    FIDisabledPicture: TGDIPPicture;
    FOfficeHint: TAdvHintInfo;
    procedure TimerProc(Sender: TObject);
    procedure PictureChanged(Sender: TObject);
    procedure SetCaption(const Value: string);
    procedure SetVisible(const Value: Boolean);
    procedure SetImageIndex(const Value: Integer);
    procedure SetEnabled(const Value: boolean);
    procedure SetDisabledPicture(const Value: TGDIPPicture);
    procedure SetPicture(const Value: TGDIPPicture);
    procedure SetOfficeHint(const Value: TAdvHintInfo);
  protected
    FChildForm: TForm;
    FOnActivateForm: TNotifyEvent;
    FOnDestroyForm: TNotifyEvent;
    function GetDisplayName: string; override;
    procedure SetIndex(Value: Integer); override;
    procedure Refresh;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write SetCaption;
    property Enabled: boolean read FEnabled write SetEnabled default true;
    property Visible: Boolean read FVisible write SetVisible default true;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property DisabledPicture: TGDIPPicture read FIDisabledPicture write SetDisabledPicture;
    property Picture: TGDIPPicture read FIPicture write SetPicture;
    property OfficeHint: TAdvHintInfo read FOfficeHint write SetOfficeHint;
    property Tag: integer read FTag write FTag default 0;
  end;

  TOfficeTabCollection = class(TCollection)
  private
    FOwner: TAdvCustomOfficeTabSet;
    function GetItem(Index: Integer): TOfficeTabCollectionItem;
    procedure SetItem(Index: Integer; const Value: TOfficeTabCollectionItem);
  protected
  public
    constructor Create(AOwner: TAdvCustomOfficeTabSet);
    property Items[Index: Integer]: TOfficeTabCollectionItem read GetItem write SetItem; default;
    property AdvOfficeTabSet: TAdvCustomOfficeTabSet read FOwner;
    function Add: TOfficeTabCollectionItem;
    procedure Delete(Index: Integer);
    function Insert(Index: Integer): TOfficeTabCollectionItem;
    function GetOwner: TPersistent; override;
    procedure Move(CurIndex, NewIndex : integer);
  end;

  TTabChangingEvent = procedure(Sender: TObject; FromTab, ToTab: Integer; var AllowChange: Boolean) of object;
  TOnTabClose = procedure (Sender:TObject; TabIndex: integer; var Allow: boolean) of object;
  TOnTabListClick = procedure (Sender: TObject; X, Y: integer) of object;

  TAdvCustomOfficeTabSet = class(TCustomControl)
  private
    FInternalOfficeTabSetStyler: TCustomAdvOfficeTabSetStyler;
    FOfficeTabSetStyler: TCustomAdvOfficeTabSetStyler;
    FCurrentOfficeTabSetStyler: TCustomAdvOfficeTabSetStyler;
    FOffSetY: integer;
    FOffSetX: integer;
    //FAdvPages: TDbgList;
    FAdvOfficeTabs: TOfficeTabCollection;
    FPropertiesLoaded: Boolean;
    FShowNonSelectedTabs: Boolean;
    FTabSettings: TTabSetTabSettings;
    FTabScroller: TTabSetTabScroller;
    FActiveTabIndex: Integer;
    FHotTabIndex: Integer;
    FDownTabIndex: Integer;
    FOldHotTabIndex: Integer;
    FHintTabIndex: Integer;
    FImages: TCustomImageList;
    FDisabledImages: TCustomImageList;
    //FScrollerHoverLeftBtn: Boolean;
    //FScrollerDownLeftBtn: Boolean;
    //FScrollerHoverRightBtn: Boolean;
    //FScrollerDownRightBtn: Boolean;
    FShowTabHint: Boolean;
    FOnChange: TNotifyEvent;
    FOnChanging: TTabChangingEvent;
    FOldCapRightIndent: Integer;
    FOfficeHint: TAdvHintInfo;
    FTabPosition: TTabPosition;
    FAntiAlias: TAntiAlias;
    FButtonSettings: TTabSetButtonSettings;
    FTabListMenu: TPopupMenu;
    FOnTabClose: TOnTabClose;
    FOnTabListClick: TOnTabListClick;
    FRotateTabLeftRight: Boolean;
    FCloseOnTab: Boolean;
    FCloseButton: TAdvGlowButton;
    FTabListButton: TAdvGlowButton;
    FScrollPrevButton: TAdvGlowButton;
    FScrollNextButton: TAdvGlowButton;
    FTabOffSet: Integer;
    FUseMaxSpace: Boolean;
    FFreeOnClose: Boolean;
    FDummyHintControl: TDummyHintControl;
    FTabRearrange: Boolean;
    FOnTabMoved: TTabMovedEvent;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
    procedure CMShowingChanged(var Message: TMessage); message CM_SHOWINGCHANGED;
    procedure CMControlChange(var Message: TCMControlChange); message CM_CONTROLCHANGE;
    procedure CMControlListChange(var Message: TCMControlListChange); message CM_CONTROLLISTCHANGE;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMDesignHitTest(var Msg: TCMDesignHitTest); message CM_DESIGNHITTEST;
    procedure CMHintShow(var Message: TMessage); message CM_HINTSHOW;
    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    procedure OnTabSettingsChanged(Sender: TObject);
    procedure OnButtonSettingChanged(Sender: TObject);
    procedure OnCloseButtonClick(Sender: TObject);
    procedure OnTabListButtonClick(Sender: TObject);
    procedure OnTabListMenuClick(Sender: TObject);
    procedure OnScrollPrevButtonClick(Sender: TObject);
    procedure OnScrollNextButtonClick(Sender: TObject);
    procedure OnEnterTab(TabIndex: Integer);
    procedure OnExitTab(TabIndex: Integer);
    //procedure SetPagePosition(AdvPage: TAdvOfficePage);
    //procedure SetAllPagesPosition;
    procedure SetOfficeTabSetStyler(const Value: TCustomAdvOfficeTabSetStyler);
    //function GetAdvOfficePageCount: integer;
    //function GetAdvPages(index: integer): TAdvOfficePage;
    function GetPopupMenuEx: TPopupMenu;
    procedure SetPopupMenuEx(const Value: TPopupMenu);
    procedure SetShowNonSelectedTabs(const Value: Boolean);
    //function GetActivePage: TAdvOfficePage;
    function GetActiveTabIndex: Integer;
    //procedure SetActivePage(const Value: TAdvOfficePage);
    procedure SetActiveTabIndex(const Value: Integer);
    procedure SetTabSettings(const Value: TTabSetTabSettings);
    procedure SetImages(const Value: TCustomImageList);
    procedure SetDisabledImages(const Value: TCustomImageList);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    procedure SetOfficeHint(const Value: TAdvHintInfo);
    procedure SetTabPosition(const Value: TTabPosition);
    procedure SetAntiAlias(const Value: TAntiAlias);
    procedure SetButtonSettings(const Value: TTabSetButtonSettings);
    procedure SetTabListMenu(const Value: TPopupMenu);
    procedure SetCloseOnTab(const Value: Boolean);
    procedure SetRotateTabLeftRight(const Value: Boolean);
    procedure SetAdvOfficeTabs(Value: TOfficeTabCollection);
  protected
    procedure AlignControls(AControl: TControl; var ARect: TRect); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure DrawTab(TabIndex: Integer);
    procedure DrawAllTabs;
    //procedure DrawTabScrollBtnLeft;
    //procedure DrawTabScrollBtnRight;
    procedure DrawTabScrollButtons;
    procedure Paint; override;

    procedure SetChildOrder(Child: TComponent; Order: Integer); override;
    //procedure SetAdvPageBounds(AdvPage: TAdvOfficePage; var ALeft, ATop, AWidth, AHeight: Integer);

    procedure UpdateMe(PropID: integer);
    procedure ChangeActiveTab(TabIndex: Integer); virtual;

    procedure UpdateTabScroller;
    procedure ScrollLeftBtnClick;
    procedure ScrollRightBtnClick;

    procedure InitializeAndUpdateButtons;
    function AnyButtonVisible: Boolean;

    function CanShowTab(TabIndex: Integer): Boolean;
    function GetVisibleTabCount: Integer;

    procedure BeforeCloseTab(Tab: TOfficeTabCollectionItem); virtual;

    procedure InvalidateTab(TabIndex: Integer);
    function GetButtonsRect: TRect;
    function GetTabsArea: TRect;
    function GetTabsRect: TRect;
    function GetTabRect(StartIndex, TabIndex: Integer; ConsiderTabScroller: Boolean): TRect;  overload;
    function GetTabRect(TabIndex: Integer): TRect; overload;
    function PTOnTab(X, Y: Integer): Integer;
    function GetCloseButtonRect: TRect;
    function GetTabListRect: TRect;
    function GetTabScrollerRect: TRect;
    function GetTabScrollerLeftRect: TRect;
    function GetTabScrollerRightRect: TRect;
    function PtOnTabScrollLeftBtn(X, Y: integer): Boolean;
    function PtOnTabScrollRightBtn(X, Y: integer): Boolean;

    property AdvOfficeTabs: TOfficeTabCollection read FAdvOfficeTabs write SetAdvOfficeTabs;
    property AdvOfficeTabSetStyler: TCustomAdvOfficeTabSetStyler read FOfficeTabSetStyler write SetOfficeTabSetStyler;
    property ActiveTabIndex: Integer read GetActiveTabIndex write SetActiveTabIndex;
    property AntiAlias: TAntiAlias read FAntiAlias write SetAntiAlias default aaClearType;
    property ButtonSettings: TTabSetButtonSettings read FButtonSettings write SetButtonSettings;
    property CloseOnTab: Boolean read FCloseOnTab write SetCloseOnTab default false;
    property DisabledImages: TCustomImageList read FDisabledImages write SetDisabledImages;
    property FreeOnClose: boolean read FFreeOnClose write FFreeOnClose default false;
    property Images: TCustomImageList read FImages write SetImages;
    property OfficeHint: TAdvHintInfo read FOfficeHint write SetOfficeHint;
    property TabListMenu: TPopupMenu read FTabListMenu write SetTabListMenu;
    property PopupMenu: TPopupMenu read GetPopupMenuEx write SetPopupMenuEx;
    property RotateTabLeftRight: Boolean read FRotateTabLeftRight write SetRotateTabLeftRight default true;
    property ShowNonSelectedTabs: Boolean read FShowNonSelectedTabs write SetShowNonSelectedTabs default False;
    property ShowTabHint: Boolean read FShowTabHint write FShowTabHint default false;
    property TabPosition: TTabPosition read FTabPosition write SetTabPosition default tpTop;
    property TabRearrange: Boolean read FTabRearrange write FTabRearrange default false;
    property TabSettings: TTabSetTabSettings read FTabSettings write SetTabSettings;
    property Version: string read GetVersion write SetVersion stored false;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TTabChangingEvent read FOnChanging write FOnChanging;
    property OnTabClose: TOnTabClose read FOnTabClose write FOnTabClose;
    property OnTabMoved: TTabMovedEvent read FOnTabMoved write FOnTabMoved;
    property OnTabListClick: TOnTabListClick read FOnTabListClick write FOnTabListClick;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CreateParams(var Params: TCreateParams); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;

    function GetVersionNr: integer;

    //procedure MoveAdvOfficeTab(CurIndex, NewIndex: Integer);
    function FindNextTab(TabIndex: Integer; GoForward, CheckTabVisible: Boolean): Integer;
    procedure SelectNextTab(GoForward: Boolean);
    //function IndexOfPage(AdvPage: TAdvOfficePage): Integer;
  published
  end;

  TAdvOfficeTabSet = class(TAdvCustomOfficeTabSet)
  public
  published
    property AdvOfficeTabs;
    property AdvOfficeTabSetStyler;
    property Align;
    property Anchors;
    property ActiveTabIndex;
    property AntiAlias;
    property ButtonSettings;
    property Constraints;
    property CloseOnTab;
    property DisabledImages;
    property FreeOnClose;
    property Images;
    property OfficeHint;
    property TabListMenu;
    property PopupMenu;
    property RotateTabLeftRight;
    property ShowNonSelectedTabs;
    property ShowTabHint;
    property ShowHint;
    property TabPosition;
    property TabRearrange;
    property TabSettings;
    property Version;
    property Visible;
    property OnChange;
    property OnChanging;
    property OnTabClose;
    property OnTabMoved;
    property OnTabListClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  TAdvOfficeMDITabSet = class(TAdvCustomOfficeTabSet)
  private
    FInternalDelete: Boolean;
    function GetAdvOfficeTabCount: integer;
    function GetAdvOfficeTabs(index: integer): TOfficeTabCollectionItem;
    procedure OnChildFormActivate(Sender: TObject);
    procedure OnChildFormDestroy(Sender: TObject);
  protected
    procedure ChangeActiveTab(TabIndex: Integer); override;
    procedure BeforeCloseTab(Tab: TOfficeTabCollectionItem); override;
    procedure Change;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddTab(ChildForm: TForm): TOfficeTabCollectionItem;
    function GetChildForm(Tab: TOfficeTabCollectionItem): TForm;

    property AdvOfficeTabCount: integer read GetAdvOfficeTabCount;
    property AdvOfficeTabs[index: integer]: TOfficeTabCollectionItem read GetAdvOfficeTabs;
    //property AdvOfficeTabs;
    property ActiveTabIndex;
  published
    property AdvOfficeTabSetStyler;
    property Align;
    property Anchors;
    property AntiAlias;
    property ButtonSettings;
    property Constraints;
    property CloseOnTab;
    property DisabledImages;
    //property FreeOnClose;
    property Images;
    property OfficeHint;
    property TabListMenu;
    property PopupMenu;
    property RotateTabLeftRight;
    property ShowNonSelectedTabs;
    property ShowTabHint;
    property ShowHint;
    property TabPosition;
    property TabRearrange;
    property TabSettings;
    property Version;
    property Visible;
    property OnChange;
    property OnChanging;
    property OnTabClose;
    property OnTabMoved;
    property OnTabListClick;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

implementation


//------------------------------------------------------------------------------

function ColorToARGB(Color: TColor): ARGB;
var
  c: TColor;
begin
  c := ColorToRGB(Color);
  Result := ARGB( $FF000000 or ((DWORD(c) and $FF) shl 16) or ((DWORD(c) and $FF00) or ((DWORD(c) and $ff0000) shr 16)));
end;

//------------------------------------------------------------------------------

procedure DrawGradient(Canvas: TCanvas; FromColor, ToColor: TColor; Steps: Integer; R: TRect; Direction: Boolean);
var
  diffr, startr, endr: Integer;
  diffg, startg, endg: Integer;
  diffb, startb, endb: Integer;
  rstepr, rstepg, rstepb, rstepw: Real;
  i, stepw: Word;

begin
  if Direction then
    R.Right := R.Right - 1
  else
    R.Bottom := R.Bottom - 1;

  if Steps = 0 then
    Steps := 1;

  FromColor := ColorToRGB(FromColor);
  ToColor := ColorToRGB(ToColor);

  startr := (FromColor and $0000FF);
  startg := (FromColor and $00FF00) shr 8;
  startb := (FromColor and $FF0000) shr 16;
  endr := (ToColor and $0000FF);
  endg := (ToColor and $00FF00) shr 8;
  endb := (ToColor and $FF0000) shr 16;

  diffr := endr - startr;
  diffg := endg - startg;
  diffb := endb - startb;

  rstepr := diffr / steps;
  rstepg := diffg / steps;
  rstepb := diffb / steps;

  if Direction then
    rstepw := (R.Right - R.Left) / Steps
  else
    rstepw := (R.Bottom - R.Top) / Steps;

  with Canvas do
  begin
    for i := 0 to steps - 1 do
    begin
      endr := startr + Round(rstepr * i);
      endg := startg + Round(rstepg * i);
      endb := startb + Round(rstepb * i);
      stepw := Round(i * rstepw);
      Pen.Color := endr + (endg shl 8) + (endb shl 16);
      Brush.Color := Pen.Color;
      if Direction then
        Rectangle(R.Left + stepw, R.Top, R.Left + stepw + Round(rstepw) + 1, R.Bottom)
      else
        Rectangle(R.Left, R.Top + stepw, R.Right, R.Top + stepw + Round(rstepw) + 1);
    end;
  end;
end;

//------------------------------------------------------------------------------

function BlendColor(Col1,Col2:TColor; BlendFactor:Integer): TColor;
var
  r1,g1,b1: Integer;
  r2,g2,b2: Integer;

begin
  if BlendFactor >= 100 then
  begin
    Result := Col1;
    Exit;
  end;
  if BlendFactor <= 0 then
  begin
    Result := Col2;
    Exit;
  end;

  Col1 := Longint(ColorToRGB(Col1));
  r1 := GetRValue(Col1);
  g1 := GetGValue(Col1);
  b1 := GetBValue(Col1);

  Col2 := Longint(ColorToRGB(Col2));
  r2 := GetRValue(Col2);
  g2 := GetGValue(Col2);
  b2 := GetBValue(Col2);

  r1 := Round( BlendFactor/100 * r1 + (1 - BlendFactor/100) * r2);
  g1 := Round( BlendFactor/100 * g1 + (1 - BlendFactor/100) * g2);
  b1 := Round( BlendFactor/100 * b1 + (1 - BlendFactor/100) * b2);

  Result := RGB(r1,g1,b1);
end;

//------------------------------------------------------------------------------

procedure DrawRoundRect(graphics: TGPGraphics; Pen: TGPPen; X,Y,Width,Height,Radius: integer);
var
  path:TGPGraphicsPath;
begin
  path := TGPGraphicsPath.Create;
  path.AddLine(X + radius, Y, X + width - (radius*2), Y);
  path.AddArc(X + width - (radius*2), Y, radius*2, radius*2, 270, 90);
  path.AddLine(X + width, Y + radius, X + width, Y + height - (radius*2));
  path.AddArc(X + width - (radius*2), Y + height - (radius*2), radius*2, radius*2,0,90);
  path.AddLine(X + width - (radius*2), Y + height, X + radius, Y + height);
  path.AddArc(X, Y + height - (radius*2), radius*2, radius*2, 90, 90);
  path.AddLine(X, Y + height - (radius*2), X, Y + radius);
  path.AddArc(X, Y, radius*2, radius*2, 180, 90);
  path.CloseFigure;
  graphics.DrawPath(pen, path);
  path.Free;
end;

//------------------------------------------------------------------------------

procedure DrawRect(graphics: TGPGraphics; Pen: TGPPen; X,Y,Width,Height: integer);
var
  path:TGPGraphicsPath;
begin
  path := TGPGraphicsPath.Create;
  path.AddLine(X, Y, X + width, Y);
  path.AddLine(X + width, Y, X + width, Y + height);
  path.AddLine(X + width, Y + height, X, Y + height);
  path.AddLine(X, Y + height, X, Y);
  path.CloseFigure;
  graphics.DrawPath(pen, path);
  path.Free;
end;

//------------------------------------------------------------------------------

function DrawVistaText(Canvas: TCanvas; Alignment: TAlignment; r: TRect; Caption:string; AFont: TFont; Enabled: Boolean; RealDraw: Boolean; AntiAlias: TAntiAlias; Direction: TTabPosition): TRect;
var
  graphics : TGPGraphics;
  w,h: Integer;
  fontFamily: TGPFontFamily;
  font: TGPFont;
  rectf: TGPRectF;
  stringFormat: TGPStringFormat;
  solidBrush: TGPSolidBrush;
  x1,y1,x2,y2: single;
  fs: integer;
  sizerect: TGPRectF;
  szRect: TRect;
  DTFLAG: DWORD;
begin
  if (Caption <> '') then
  begin
    graphics := TGPGraphics.Create(Canvas.Handle);
    fontFamily:= TGPFontFamily.Create(AFont.Name);
    fs := 0;

    font := TGPFont.Create(fontFamily, AFont.Size , fs, UnitPoint);
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);

    w := R.Right - R.Left;
    h := R.Bottom - R.Top;

    x1 := r.Left;
    y1 := r.Top;
    x2 := w;
    y2 := h;

    rectf := MakeRect(x1,y1,x2,y2);

    stringFormat := nil;
    if RealDraw then
    begin
      case (Direction) of
        tpTop, tpBottom: stringFormat := TGPStringFormat.Create;
        tpLeft:
        begin
          stringFormat := TGPStringFormat.Create; //($00000002);
        end;
        tpRight: stringFormat := TGPStringFormat.Create($00000002);
      end;
    end
    else
      stringFormat := TGPStringFormat.Create;


    if Enabled then
      solidBrush := TGPSolidBrush.Create(ColorToARGB(AFont.Color))
    else
      solidBrush := TGPSolidBrush.Create(ColorToARGB(clGray));

    case Alignment of
      taLeftJustify: stringFormat.SetAlignment(StringAlignmentNear);
      taCenter:
      begin
        // Center-justify each line of text.
        stringFormat.SetAlignment(StringAlignmentCenter);
      end;
      taRightJustify: stringFormat.SetAlignment(StringAlignmentFar);
    end;

    // Center the block of text (top to bottom) in the rectangle.
    stringFormat.SetLineAlignment(StringAlignmentCenter);

    stringFormat.SetHotkeyPrefix(HotkeyPrefixShow);

    //graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    //graphics.MeasureString(Caption, Length(Caption), font, rectf, stringFormat, sizerect);
    case AntiAlias of
    aaClearType:graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    aaAntiAlias:graphics.SetTextRenderingHint(TextRenderingHintAntiAlias);
    end;

    if AntiAlias = aaNone then
    begin
      szRect.Left := round(rectf.X);
      szRect.Top := round(rectf.Y);

      szRect.Right := szRect.Left + 2;
      szRect.Bottom := DrawText(Canvas.Handle,PChar(Caption),Length(Caption), szrect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK);

      sizeRect.X := szRect.Left;
      sizeRect.Y := szRect.Top;
      sizeRect.Width := szRect.Right - szRect.Left;
      sizeRect.Height := szRect.Bottom - szRect.Top;
    end
    else
      graphics.MeasureString(Caption, Length(Caption), font, rectf, stringFormat, sizerect);


    Result := Rect(round(sizerect.X), Round(sizerect.Y), Round(sizerect.X + sizerect.Width), Round(sizerect.Y + sizerect.Height));
    rectf := MakeRect(x1,y1,x2,y2);

    if RealDraw then
    begin
      //graphics.DrawString(Caption, Length(Caption), font, rectf, stringFormat, solidBrush);
      if AntiAlias = aaNone then
      begin
        szRect.Left := round(rectf.X);
        szRect.Top := round(rectf.Y);
        szRect.Right := szRect.Left + round(rectf.Width);
        szRect.Bottom := szRect.Top + round(rectf.Height);
        Canvas.Brush.Style := bsClear;

        DTFLAG := DT_LEFT;
        case Alignment of
        taRightJustify: DTFLAG := DT_RIGHT;
        taCenter: DTFLAG := DT_CENTER;
        end;
        DrawText(Canvas.Handle,PChar(Caption),Length(Caption), szrect, DTFLAG or DT_VCENTER or DT_SINGLELINE)
      end
      else
        graphics.DrawString(Caption, Length(Caption), font, rectf, stringFormat, solidBrush);
    end;
      
    stringformat.Free;
    solidBrush.Free;
    font.Free;
    fontfamily.Free;
    graphics.Free;
  end;
end;

//------------------------------------------------------------------------------

procedure DrawVistaGradient(Canvas: TCanvas; r: TRect; CFU, CTU, CFB, CTB, PC: TColor;
   GradientU,GradientB: TGDIPGradient; Caption:string; AFont: TFont;
   Images: TImageList; ImageIndex: integer; EnabledImage: Boolean; Layout: TButtonLayout;
   DropDownButton: Boolean; DrawDwLine: Boolean; Enabled: Boolean; Focus: Boolean; DropDownPos: TDropDownPosition;
   Picture: TGDIPPicture; AntiAlias: TAntiAlias; RoundEdges: Boolean; Direction: TTabPosition); overload;
var
  graphics : TGPGraphics;
  path: TGPGraphicsPath;
  pthGrBrush: TGPPathGradientBrush;
  linGrBrush: TGPLinearGradientBrush;
  gppen : tgppen;
  count: Integer;
  w,h,h2,w2: Integer;
  colors : array[0..0] of TGPColor;
  fontFamily: TGPFontFamily;
  font: TGPFont;
  rectf: TGPRectF;
  stringFormat: TGPStringFormat;
  solidBrush: TGPSolidBrush;
  x1,y1,x2,y2: single;
  fs: integer;
  sizerect: TGPRectF;
  ImgX, ImgY, ImgW, ImgH: Integer;
  BtnR, DwR: TRect;
  AP: TPoint;
  szRect: TRect;

  procedure DrawArrow(ArP: TPoint; ArClr: TColor);
  begin
    Canvas.Pen.Color := ArClr;
    Canvas.MoveTo(ArP.X, ArP.Y);
    Canvas.LineTo(ArP.X + 5, ArP.Y);
    Canvas.MoveTo(ArP.X + 1, ArP.Y + 1);
    Canvas.LineTo(ArP.X + 4, ArP.Y + 1);
    Canvas.Pixels[ArP.X + 2, ArP.Y + 2] := ArClr;
  end;

begin
  BtnR := R;
  if DropDownPos = dpRight then
  begin
    DwR := Rect(BtnR.Right - DropDownSectWidth, BtnR.Top, BtnR.Right, BtnR.Bottom);
    if DropDownButton then
      BtnR.Right := DwR.Left;
  end
  else // DropDownPos = doBottom
  begin
    DwR := Rect(BtnR.Left, BtnR.Bottom - DropDownSectWidth, BtnR.Right, BtnR.Bottom);
    if DropDownButton then
      BtnR.Bottom := DwR.Top;
  end;

  w := r.Right - r.Left;
  h := r.Bottom - r.Top;

  h2 := h div 2;
  w2 := w div 2;

  graphics := TGPGraphics.Create(Canvas.Handle);

  case (Direction) of
    tpTop:
    begin
      // down ellips brush
      Canvas.Brush.Color := cfb;
      Canvas.FillRect(rect(r.Left , r.top +  h2, r.Right , r.Bottom ));

      // Create a path that consists of a single ellipse.
      path := TGPGraphicsPath.Create;
      //  path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
      path.AddEllipse(r.Left, r.Top +  h2, w , h);

      pthGrBrush := nil;
      linGrBrush := nil;

      case GradientB of
      ggRadial: pthGrBrush := TGPPathGradientBrush.Create(path);
      ggVertical: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top + h2,w,h2),ColorToARGB(CFB),ColorToARGB(CTB), LinearGradientModeVertical);
      ggDiagonalForward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top + h2,w,h2),ColorToARGB(CFB),ColorToARGB(CTB), LinearGradientModeForwardDiagonal);
      ggDiagonalBackward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top + h2,w,h2),ColorToARGB(CFB),ColorToARGB(CTB), LinearGradientModeBackwardDiagonal);
      end;

      if GradientB = ggRadial then
      begin
        pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Bottom));

        // Set the color at the center point to blue.
        pthGrBrush.SetCenterColor(ColorToARGB(CTB));

        colors[0] := ColorToARGB(CFB);
        count := 1;
        pthGrBrush.SetSurroundColors(@colors, count);
        graphics.FillRectangle(pthGrBrush, r.Left + 1,r.Top + h2, w - 1, h2+1);
        pthGrBrush.Free;
      end
      else
      begin
        graphics.FillRectangle(linGrBrush, r.Left + 1,r.Top + h2 + 1, w - 1, h2 + 1);
        linGrBrush.Free;
      end;

      path.Free;

      Canvas.Brush.Color := cfu;
      //Canvas.FillRect(rect(r.Left + 1, r.Top + 2, r.Right - 1, r.top +  h2));
      Canvas.FillRect(rect(r.Left , r.Top , r.Right , r.top +  h2));

      // Create a path that consists of a single ellipse.
      path := TGPGraphicsPath.Create;
      path.AddEllipse(r.Left, r.Top - h2 , w , h);

      case GradientU of
      ggRadial: pthGrBrush := TGPPathGradientBrush.Create(path);                      // FF: Gradient fix here replace h by h2
      ggVertical: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w,h2+1),ColorToARGB(CFU),ColorToARGB(CTU), LinearGradientModeVertical);
      ggDiagonalForward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w,h),ColorToARGB(CFU),ColorToARGB(CTU), LinearGradientModeForwardDiagonal);
      ggDiagonalBackward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w,h),ColorToARGB(CFU),ColorToARGB(CTU), LinearGradientModeBackwardDiagonal);
      end;

      if GradientU = ggRadial then
      begin
        pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.top));

        // Set the color at the center point to blue.
        pthGrBrush.SetCenterColor(ColorToARGB(CTU));

        colors[0] := ColorToARGB(CFU);
        count := 1;
        pthGrBrush.SetSurroundColors(@colors, count);

        graphics.FillRectangle(pthGrBrush, r.Left + 1,r.Top + 1, w - 1, h - h2 - 1);
        pthGrBrush.Free;
      end
      else
      begin
        graphics.FillRectangle(linGrBrush, r.Left + 1,r.Top + 1, w - 1, h2);
        linGrBrush.Free;
      end;

      path.Free;

    end;
    tpBottom:
    begin
      // down ellips brush
      Canvas.Brush.Color := cfb;
      Canvas.FillRect(rect(r.Left , r.top, r.Right , r.top +  h2));

      // Create a path that consists of a single ellipse.
      path := TGPGraphicsPath.Create;
      //  path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
      path.AddEllipse(r.Left, r.Top, w , h2);

      pthGrBrush := nil;
      linGrBrush := nil;

      case GradientB of
      ggRadial: pthGrBrush := TGPPathGradientBrush.Create(path);
      ggVertical: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w,h2),ColorToARGB(CTB),ColorToARGB(CFB), LinearGradientModeVertical);
      ggDiagonalForward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w,h2),ColorToARGB(CTB),ColorToARGB(CFB), LinearGradientModeForwardDiagonal);
      ggDiagonalBackward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w,h2),ColorToARGB(CTB),ColorToARGB(CFB), LinearGradientModeBackwardDiagonal);
      end;

      if GradientB = ggRadial then
      begin
        pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Top));

        // Set the color at the center point to blue.
        pthGrBrush.SetCenterColor(ColorToARGB(CTB));

        colors[0] := ColorToARGB(CFB);
        count := 1;
        pthGrBrush.SetSurroundColors(@colors, count);
        graphics.FillRectangle(pthGrBrush, r.Left + 1,r.Top, w - 1, h2+1);
        pthGrBrush.Free;
      end
      else
      begin
        graphics.FillRectangle(linGrBrush, r.Left + 1,r.Top + 1, w - 1, h2 + 1);
        linGrBrush.Free;
      end;

      path.Free;

      Canvas.Brush.Color := cfu;
      Canvas.FillRect(rect(r.Left , r.top +  h2, r.Right , r.Bottom));

      // Create a path that consists of a single ellipse.
      path := TGPGraphicsPath.Create;
      path.AddEllipse(r.Left, r.Bottom - h2 , w , h);

      case GradientU of
      ggRadial: pthGrBrush := TGPPathGradientBrush.Create(path);                      // FF: Gradient fix here replace h by h2
      ggVertical: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top + h2-1,w,h2),ColorToARGB(CTU),ColorToARGB(CFU), LinearGradientModeVertical);
      ggDiagonalForward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top + h2,w,h),ColorToARGB(CTU),ColorToARGB(CFU), LinearGradientModeForwardDiagonal);
      ggDiagonalBackward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top + h2,w,h),ColorToARGB(CTU),ColorToARGB(CFU), LinearGradientModeBackwardDiagonal);
      end;

      if GradientU = ggRadial then
      begin
        pthGrBrush.SetCenterPoint(MakePoint(r.Left + w2, r.Bottom));

        // Set the color at the center point to blue.
        pthGrBrush.SetCenterColor(ColorToARGB(CTU));

        colors[0] := ColorToARGB(CFU);
        count := 1;
        pthGrBrush.SetSurroundColors(@colors, count);

        graphics.FillRectangle(pthGrBrush, r.Left + 1,r.Top + h2 + 1, w - 1, h2 - 1);
        pthGrBrush.Free;
      end
      else
      begin
        graphics.FillRectangle(linGrBrush, r.Left + 1,r.Top + h2, w - 1, h2 - 1);
        linGrBrush.Free;
      end;

      path.Free;
    end;
    tpLeft:
    begin
      // down ellips brush
      Canvas.Brush.Color := cfb;
      Canvas.FillRect(rect(r.Left + w2, r.top, r.Right , r.Bottom));

      // Create a path that consists of a single ellipse.
      path := TGPGraphicsPath.Create;
      //  path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
      path.AddEllipse(r.Left + w2, r.Top, w , h);

      pthGrBrush := nil;
      linGrBrush := nil;

      case GradientB of
      ggRadial: pthGrBrush := TGPPathGradientBrush.Create(path);
      ggVertical: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left + w2,r.Top,w2,h),ColorToARGB(CFB),ColorToARGB(CTB), LinearGradientModeHorizontal);
      ggDiagonalForward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left + w2,r.Top,w2,h),ColorToARGB(CFB),ColorToARGB(CTB), LinearGradientModeForwardDiagonal);
      ggDiagonalBackward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left + w2,r.Top,w2,h),ColorToARGB(CFB),ColorToARGB(CTB), LinearGradientModeBackwardDiagonal);
      end;

      if GradientB = ggRadial then
      begin
        pthGrBrush.SetCenterPoint(MakePoint(r.Right, r.Top + h2));

        // Set the color at the center point to blue.
        pthGrBrush.SetCenterColor(ColorToARGB(CTB));

        colors[0] := ColorToARGB(CFB);
        count := 1;
        pthGrBrush.SetSurroundColors(@colors, count);
        graphics.FillRectangle(pthGrBrush, r.Left + w2, r.Top, w2 + 1, h-1);
        pthGrBrush.Free;
      end
      else
      begin
        graphics.FillRectangle(linGrBrush, r.Left + w2 + 1,r.Top, w2 + 1, h - 1);
        linGrBrush.Free;
      end;

      path.Free;

      Canvas.Brush.Color := cfu;
      //Canvas.FillRect(rect(r.Left + 1, r.Top + 2, r.Right - 1, r.top +  h2));
      Canvas.FillRect(rect(r.Left , r.Top , r.Left + w2 , r.Bottom));

      // Create a path that consists of a single ellipse.
      path := TGPGraphicsPath.Create;
      path.AddEllipse(r.Left - w2, r.Top, w , h);

      case GradientU of
      ggRadial: pthGrBrush := TGPPathGradientBrush.Create(path);                      // FF: Gradient fix here replace h by h2
      ggVertical: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w2,h),ColorToARGB(CFU),ColorToARGB(CTU), LinearGradientModeHorizontal);
      ggDiagonalForward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w,h),ColorToARGB(CFU),ColorToARGB(CTU), LinearGradientModeForwardDiagonal);
      ggDiagonalBackward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w,h),ColorToARGB(CFU),ColorToARGB(CTU), LinearGradientModeBackwardDiagonal);
      end;

      if GradientU = ggRadial then
      begin
        pthGrBrush.SetCenterPoint(MakePoint(r.Left, r.top + h2));

        // Set the color at the center point to blue.
        pthGrBrush.SetCenterColor(ColorToARGB(CTU));

        colors[0] := ColorToARGB(CFU);
        count := 1;
        pthGrBrush.SetSurroundColors(@colors, count);

        graphics.FillRectangle(pthGrBrush, r.Left + 1,r.Top + 1, w2 - 1, h - 1);
        pthGrBrush.Free;
      end
      else
      begin
        graphics.FillRectangle(linGrBrush, r.Left + 1,r.Top + 1, w2 - 1, h - 1);
        linGrBrush.Free;
      end;

      path.Free;

    end;
    tpRight:
    begin
      Canvas.Brush.Color := cfu;
      Canvas.FillRect(rect(r.Right - w2 , r.Top , r.Right ,r.Bottom));

      // Create a path that consists of a single ellipse.
      path := TGPGraphicsPath.Create;
      path.AddEllipse(r.Right - w2, r.Top, w, h);

      pthGrBrush := nil;
      linGrBrush := nil;

      case GradientU of
      ggRadial: pthGrBrush := TGPPathGradientBrush.Create(path);                      // FF: Gradient fix here replace h by h2
      ggVertical: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Right-w2,r.Top,w2,h),ColorToARGB(CTU),ColorToARGB(CFU), LinearGradientModeHorizontal);
      ggDiagonalForward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Right-w2,r.Top,w,h),ColorToARGB(CTU),ColorToARGB(CFU), LinearGradientModeForwardDiagonal);
      ggDiagonalBackward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Right-w2,r.Top,w,h),ColorToARGB(CTU),ColorToARGB(CFU), LinearGradientModeBackwardDiagonal);
      end;

      if GradientU = ggRadial then
      begin
        pthGrBrush.SetCenterPoint(MakePoint(r.Right, r.top + h2));

        // Set the color at the center point to blue.
        pthGrBrush.SetCenterColor(ColorToARGB(CTU));

        colors[0] := ColorToARGB(CFU);
        count := 1;
        pthGrBrush.SetSurroundColors(@colors, count);

        graphics.FillRectangle(pthGrBrush, r.Right - w2 + 1,r.Top + 1, w2 - 1, h - 1);
        pthGrBrush.Free;
      end
      else
      begin
        graphics.FillRectangle(linGrBrush, r.Right - w2, r.Top + 1, w2, h - 1);
        linGrBrush.Free;
      end;

      path.Free;

      // down ellips brush
      Canvas.Brush.Color := cfb;
      Canvas.FillRect(rect(r.Left , r.top, r.Left + w2, r.Bottom ));

      // Create a path that consists of a single ellipse.
      path := TGPGraphicsPath.Create;
      //  path.AddRectangle(MakeRect(r.Left, r.Top +  (h div 2), w , h));
      path.AddEllipse(r.Left - w2, r.Top, w , h);

      pthGrBrush := nil;
      linGrBrush := nil;

      case GradientB of
      ggRadial: pthGrBrush := TGPPathGradientBrush.Create(path);
      ggVertical: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w2+2,h),ColorToARGB(CTB),ColorToARGB(CFB), LinearGradientModeHorizontal);
      ggDiagonalForward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w2,h),ColorToARGB(CTB),ColorToARGB(CFB), LinearGradientModeForwardDiagonal);
      ggDiagonalBackward: linGrBrush := TGPLinearGradientBrush.Create(MakeRect(r.Left,r.Top,w2,h),ColorToARGB(CTB),ColorToARGB(CFB), LinearGradientModeBackwardDiagonal);
      end;

      if GradientB = ggRadial then
      begin
        pthGrBrush.SetCenterPoint(MakePoint(r.Left, r.Top + h2));

        // Set the color at the center point to blue.
        pthGrBrush.SetCenterColor(ColorToARGB(CTB));

        colors[0] := ColorToARGB(CFB);
        count := 1;
        pthGrBrush.SetSurroundColors(@colors, count);
        graphics.FillRectangle(pthGrBrush, r.Left,r.Top, w2 + 1, h-1);
        pthGrBrush.Free;
      end
      else
      begin
        graphics.FillRectangle(linGrBrush, r.Left,r.Top, w2 + 2, h - 1);
        linGrBrush.Free;
      end;

      path.Free;

    end;
  end;


  gppen := tgppen.Create(ColorToARGB(PC),1);

  graphics.SetSmoothingMode(SmoothingModeAntiAlias);

  if (PC <> clNone) then
  begin
    if not RoundEdges then
      DrawRect(graphics, gppen,r.Left,r.Top, w - 1, h - 1)
    else
      DrawRoundRect(graphics, gppen,r.Left,r.Top, w - 1, h - 1, 3);
  end;

  gppen.Free;

  if Focus then
  begin
    gppen := tgppen.Create(ColorToARGB($E4AD89),1);
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    DrawRoundRect(graphics, gppen,r.Left + 1,r.Top + 1, r.Right - 3, r.Bottom - 3, 3);
    gppen.Free;
    gppen := tgppen.Create(ColorToARGB(clgray),1);
    gppen.SetDashStyle(DashStyleDot);
    graphics.SetSmoothingMode(SmoothingModeAntiAlias);
    DrawRoundRect(graphics, gppen,r.Left + 2,r.Top + 2, r.Right - 5, r.Bottom - 5, 3);
    gppen.Free;
  end;

  fontFamily:= TGPFontFamily.Create(AFont.Name);

  fs := 0;

  ImgH := 0;
  ImgW := 0;

  if (fsBold in AFont.Style) then
    fs := fs + 1;
  if (fsItalic in AFont.Style) then
    fs := fs + 2;
  if (fsUnderline in AFont.Style) then
    fs := fs + 4;

  if Assigned(Picture) and not Picture.Empty then
  begin
    Picture.GetImageSizes;
    ImgW := Picture.Width;
    ImgH := Picture.Height;
  end
  else
  begin
    if (ImageIndex > -1) and Assigned(Images) then
    begin
      ImgW := Images.Width;
      ImgH := Images.Height;
    end;
  end;

  if (Caption <> '') then
  begin
    font := TGPFont.Create(fontFamily, AFont.Size , fs, UnitPoint);

    w := BtnR.Right - BtnR.Left;
    h := BtnR.Bottom - BtnR.Top;

    x1 := r.Left;
    y1 := r.Top;
    x2 := w;
    y2 := h;

    rectf := MakeRect(x1,y1,x2,y2);

    stringFormat := TGPStringFormat.Create;

    if Enabled then
      solidBrush := TGPSolidBrush.Create(ColorToARGB(AFont.Color))
    else
      solidBrush := TGPSolidBrush.Create(ColorToARGB(clGray));

    // Center-justify each line of text.
    stringFormat.SetAlignment(StringAlignmentCenter);

    // Center the block of text (top to bottom) in the rectangle.
    stringFormat.SetLineAlignment(StringAlignmentCenter);

    stringFormat.SetHotkeyPrefix(HotkeyPrefixShow);

    case AntiAlias of
    aaClearType:graphics.SetTextRenderingHint(TextRenderingHintClearTypeGridFit);
    aaAntiAlias:graphics.SetTextRenderingHint(TextRenderingHintAntiAlias);
    end;

    //graphics.MeasureString(Caption, Length(Caption), font, rectf, stringFormat, sizerect);
    if AntiAlias = aaNone then
    begin
      szRect.Left := round(rectf.X);
      szRect.Top := round(rectf.Y);

      szRect.Right := szRect.Left + 2;
      szRect.Bottom := DrawText(Canvas.Handle,PChar(Caption),Length(Caption), szrect, DT_CALCRECT or DT_LEFT or DT_WORDBREAK);

      sizeRect.X := szRect.Left;
      sizeRect.Y := szRect.Top;
      sizeRect.Width := szRect.Right - szRect.Left;
      sizeRect.Height := szRect.Bottom - szRect.Top;
    end
    else
      graphics.MeasureString(Caption, Length(Caption), font, rectf, stringFormat, sizerect);

    if (ImgW > 0) then
    begin
      case Layout of
        blGlyphLeft:
        begin
          x1 := r.Left + 2 + ImgW;
          x2 := w - 2 - ImgW;

          ImgX := round(sizerect.X - ImgW div 2);
          if ImgX < 2 then ImgX := 2;
          ImgY := r.Top + Max(0, (h - ImgH) div 2);
        end;
        blGlyphTop:
        begin
          y1 := r.Top{ + 2} + ImgH;
          y2 := h - 2 - ImgH;

          ImgX := r.Left + Max(0, (w - ImgW) div 2);
          ImgY := round(y2 - sizerect.Height);
          ImgY := Max(0, ImgY div 2);
          ImgY := round(y1) - ImgH + ImgY; //round(sizerect.Height) - ImgY - 4;
          if ImgY < 2 then ImgY := 2;
        end;
        blGlyphRight:
        begin
          x1 := 2;
          x2 := w - 4 - ImgW;

          ImgX := round(X2 - sizerect.width);
          ImgX := Max(0, ImgX div 2);
          ImgX := ImgX + round(sizerect.width) + 4;
          if ImgX > (w - ImgW) then
            ImgX := w - ImgW - 2;
          ImgY := r.Top + Max(0, (h - ImgH) div 2);
        end;
        blGlyphBottom:
        begin
          y1 := 2;
          y2 := h - 2 - ImgH;

          ImgX := r.Left + Max(0, (w - ImgW) div 2);
          ImgY := round(y2 - sizerect.Height);
          ImgY := Max(0, ImgY div 2);
          ImgY := round(sizerect.Height + 2) + ImgY;
          if ImgY > (h - ImgH) then ImgY := h - ImgH - 2;
        end;
      end;
    end;

    rectf := MakeRect(x1,y1,x2,y2);

    //graphics.DrawString(Caption, Length(Caption), font, rectf, stringFormat, solidBrush);
    if AntiAlias = aaNone then
    begin
      szRect.Left := round(rectf.X);
      szRect.Top := round(rectf.Y);
      szRect.Right := szRect.Left + round(rectf.Width);
      szRect.Bottom := szRect.Top + round(rectf.Height);
      Canvas.Brush.Style := bsClear;
      DrawText(Canvas.Handle,PChar(Caption),Length(Caption), szrect, DT_CENTER or DT_VCENTER or DT_SINGLELINE)
    end
    else
      graphics.DrawString(Caption, Length(Caption), font, rectf, stringFormat, solidBrush);

    stringformat.Free;
    font.Free;
  end;

  fontfamily.Free;

  if DropDownButton then
  begin

    if DropDownPos = dpRight then
      w := w - 8
    else
      h := h - 8;
  end;

  if Assigned(Picture) and not Picture.Empty then
  begin
     if Caption = '' then
       Canvas.Draw(r.Left + Max(0, (w - ImgW) div 2), r.Top + Max(0, (h - ImgH) div 2), Picture)
     else
       Canvas.Draw(ImgX, ImgY, Picture);
  end
  else
    if (ImageIndex <> -1) and Assigned(Images) then
    begin
      if Caption = '' then
        Images.Draw(Canvas, r.Left + Max(0, (w - Images.Width) div 2), r.Top + Max(0, (h - Images.Height) div 2), ImageIndex, EnabledImage)
      else
      begin
        Images.Draw(Canvas, ImgX, ImgY, ImageIndex, EnabledImage);
      end;
    end;


  Canvas.Brush.Style := bsClear;
  if DropDownButton then
  begin
    if DrawDwLine then
    begin
      Canvas.Pen.Color := PC;
      //Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 6, 6);
      if (DropDownPos = dpRight) then
      begin
        Canvas.MoveTo(DwR.Left, DwR.Top);
        Canvas.LineTo(DwR.Left, DwR.Bottom);
      end
      else
      begin
        Canvas.MoveTo(DwR.Left, DwR.Top);
        Canvas.LineTo(DwR.Right, DwR.Top);
      end;
    end;
    AP.X := DwR.Left + ((DwR.Right - DwR.Left - 5) div 2);
    AP.Y := DwR.Top + ((DwR.Bottom - DwR.Top - 3) div 2) + 1;
    if not Enabled then
      DrawArrow(AP, clGray)
    else
      DrawArrow(AP, clBlack);
  end;

  graphics.Free;
end;


procedure DrawVistaGradient(Canvas: TCanvas; r: TRect; CFU, CTU, CFB, CTB, PC: TColor;
   GradientU,GradientB: TGDIPGradient; Caption:string; AFont: TFont; Enabled: Boolean; Focus: Boolean;
   AntiAlias: TAntiAlias; RoundEdges: Boolean; Direction: TTabPosition = tpTop); overload;
begin
  DrawVistaGradient(Canvas, r, CFU, CTU, CFB, CTB, PC, GradientU,GradientB, Caption, AFont,
   nil, -1, True, blGlyphLeft, False, False, Enabled, Focus, dpRight, nil, AntiAlias, RoundEdges, Direction);
end;

//------------------------------------------------------------------------------

{ TTabSetTabSettings }

constructor TTabSetTabSettings.Create;
begin
  inherited;
  FLeftMargin := 4;
  FRightMargin := 4;
  FHeight := DEFAULT_TABHEIGHT;
  FStartMargin := 4;
  FEndMargin := 0;
  FSpacing := 4;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabSettings.Assign(Source: TPersistent);
begin
  if (Source is TTabSetTabSettings) then
  begin
    LeftMargin := (Source as TTabSetTabSettings).LeftMargin;
    RightMargin := (Source as TTabSetTabSettings).RightMargin;
    Height := (Source as TTabSetTabSettings).Height;
    StartMargin := (Source as TTabSetTabSettings).StartMargin;
    EndMargin := (Source as TTabSetTabSettings).EndMargin;
  end
  else
    inherited;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabSettings.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

//------------------------------------------------------------------------------

procedure TTabSetTabSettings.SetLeftMargin(const Value: Integer);
begin
  if (FLeftMargin <> Value) then
  begin
    FLeftMargin := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabSettings.SetRightMargin(const Value: Integer);
begin
  if (FRightMargin <> Value) then
  begin
    FRightMargin := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabSettings.SetHeight(const Value: Integer);
begin
  if (FHeight <> Value) then
  begin
    FHeight := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabSettings.SetStartMargin(const Value: Integer);
begin
  if (FStartMargin <> Value) then
  begin
    FStartMargin := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabSettings.SetEndMargin(const Value: Integer);
begin
  if (FEndMargin <> Value) then
  begin
    FEndMargin := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabSettings.SetSpacing(const Value: Integer);
begin
  if (FSpacing <> Value) then
  begin
    FSpacing := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

{ TTabSetTabScroller }

constructor TTabSetTabScroller.Create;
begin
  inherited;
  FMin := 0;
  FMax := 0;
  FPosition := 0;
  FVisible := False;
end;

//------------------------------------------------------------------------------

function TTabSetTabScroller.CanGoBack: Boolean;
begin
  Result := Position > Min;
end;

//------------------------------------------------------------------------------

function TTabSetTabScroller.CanGoForward: Boolean;
begin
  Result := Position < Max;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabScroller.SetMax(const Value: integer);
begin
  if Value >= FMin then FMax := Value;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabScroller.SetMin(const Value: integer);
begin
  if Value <= FMax then FMin := Value;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabScroller.SetPosition(const Value: integer);
begin
  FPosition := Value;
end;

//------------------------------------------------------------------------------

procedure TTabSetTabScroller.SetVisible(const Value: Boolean);
begin
  FVisible := Value;
end;

//------------------------------------------------------------------------------

{ TGradientBackground }

procedure TGradientBackground.Assign(Source: TPersistent);
begin
  if (Source is TGradientBackground) then
  begin
    FColor := (Source as TGradientBackground).Color;
    FColorTo := (Source as TGradientBackground).ColorTo;
    FDirection := (Source as TGradientBackground).Direction;
    FSteps := (Source as TGradientBackground).Steps;
  end;
end;

//------------------------------------------------------------------------------

procedure TGradientBackground.Changed;
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

//------------------------------------------------------------------------------

constructor TGradientBackground.Create;
begin
  inherited;
  Color := clWhite;
  ColorTo := clBtnFace;
  Steps := 64;
  Direction := gdHorizontal;
end;

//------------------------------------------------------------------------------

procedure TGradientBackground.SetColor(const Value: TColor);
begin
  FColor := Value;
  Changed;
end;

//------------------------------------------------------------------------------

procedure TGradientBackground.SetColorTo(const Value: TColor);
begin
  FColorTo := Value;
  Changed;
end;

//------------------------------------------------------------------------------

procedure TGradientBackground.SetDirection(
  const Value: TGradientDirection);
begin
  FDirection := Value;
  Changed;
end;

//------------------------------------------------------------------------------

procedure TGradientBackground.SetSteps(const Value: Integer);
begin
  FSteps := Value;
  Changed;
end;


//------------------------------------------------------------------------------

{ TVistaBackground }

constructor TVistaBackground.Create;
begin
  inherited;
  FSteps := 64;
  FColor := clWhite;
  FColorTo := clWhite;
  FColorMirror := clSilver;
  FColorMirrorTo := clWhite;
  FBorderColor := clGray;
  FGradient := ggVertical;
  FGradientMirror := ggVertical;
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.Assign(Source: TPersistent);
begin
  if (Source is TVistaBackground) then
  begin
    FSteps := (Source as TVistaBackground).Steps;
    FColor := (Source as TVistaBackground).Color;
    FColorTo := (Source as TVistaBackground).ColorTo;
    FColorMirror := (Source as TVistaBackground).ColorMirror;
    FColorMirrorTo := (Source as TVistaBackground).ColorMirrorTo;
    FBorderColor := (Source as TVistaBackground).BorderColor;
    Gradient := (Source as TVistaBackground).Gradient;
    GradientMirror := (Source as TVistaBackground).GradientMirror;
  end
  else
    inherited Assign(Source);
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.SetColor(const Value: TColor);
begin
  if (FColor <> Value) then
  begin
    FColor := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.SetColorTo(const Value: TColor);
begin
  if (FColorTo  <> Value) then
  begin
    FColorTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.SetBorderColor(const Value: TColor);
begin
  if (FBorderColor <> Value) then
  begin
    FBorderColor := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.SetColorMirror(const Value: TColor);
begin
  if (FColorMirror <> Value) then
  begin
    FColorMirror := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.SetColorMirrorTo(const Value: TColor);
begin
  if (FColorMirrorTo <> Value) then
  begin
    FColorMirrorTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.SetGradient(const Value: TGDIPGradient);
begin
  if (FGradient <> Value) then
  begin
    FGradient := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.SetGradientMirror(const Value: TGDIPGradient);
begin
  if(FGradientMirror <> Value) then
  begin
    FGradientMirror := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TVistaBackground.SetSteps(const Value: Integer);
begin
  if (FSteps <> Value) then
  begin
    FSteps := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

{ TCustomTabAppearance }

constructor TCustomTabAppearance.Create;
begin
  inherited;
  FBorderColor := clBtnFace;
  FBorderColorHot := clBlue;
  FBorderColorSelectedHot := clNone;
  FBorderColorDown := clNone;
  FColor := clBtnFace;
  FColorTo := clWhite;
  FColorHot := clYellow;
  FColorHotTo := clNone;
  FColorSelectedTo := clBtnFace;
  FBorderColorDisabled := clNone;
  FBorderColorSelected := clBtnFace;
  FColorDisabled := clNone;
  FColorDisabledTo := clNone;
  FColorSelected := clWhite;
  FColorMirror := clWhite;
  FColorMirrorTo := clWhite;
  FColorMirrorHot := clNone;
  FColorMirrorHotTo := clNone;
  FGradientMirror := ggVertical;
  FGradientMirrorHot := ggVertical;
  FGradient := ggVertical;
  FGradientHot := ggVertical;
  FColorMirrorDisabledTo := clNone;
  FColorMirrorDisabled := clNone;
  FColorMirrorSelectedTo := clWhite;
  FColorMirrorSelected := clWhite;
  FGradientSelected := ggVertical;
  FGradientDisabled := ggVertical;
  FGradientMirrorSelected := ggVertical;
  FGradientMirrorDisabled := ggVertical;
  FTextColorDisabled := clWhite;
  FTextColorSelected := clBlue;
  FTextColor := clBlue;
  FTextColorHot := clBlue;
  FBackGround := TGradientBackground.Create;
  FBackGround.OnChange := OnBackGroundChanged;
  FFont := TFont.Create;
  FFont.Name := 'Tahoma';
  FFont.Size := 8;
  FFont.Style := [];
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.Assign(Source: TPersistent);
begin
  if (Source is TCustomTabAppearance) then
  begin
    FBorderColor := (Source as TCustomTabAppearance).BorderColor;
    FBorderColorHot := (Source as TCustomTabAppearance).BorderColorHot;
    FBorderColorSelectedHot := (Source as TCustomTabAppearance).BorderColorSelectedHot;
    FBorderColorDown := (Source as TCustomTabAppearance).BorderColorDown;
    FColor := (Source as TCustomTabAppearance).Color;
    FColorTo := (Source as TCustomTabAppearance).ColorTo;
    FColorHot := (Source as TCustomTabAppearance).ColorHot;
    FColorHotTo := (Source as TCustomTabAppearance).ColorHotTo;
    FColorSelectedTo := (Source as TCustomTabAppearance).ColorSelectedTo;
    FBorderColorDisabled := (Source as TCustomTabAppearance).BorderColorDisabled;
    FBorderColorSelected := (Source as TCustomTabAppearance).BorderColorSelected;
    FColorDisabled := (Source as TCustomTabAppearance).ColorDisabled;
    FColorDisabledTo := (Source as TCustomTabAppearance).ColorDisabledTo;
    FColorSelected := (Source as TCustomTabAppearance).ColorSelected;
    FColorMirror := (Source as TCustomTabAppearance).ColorMirror;
    FColorMirrorTo := (Source as TCustomTabAppearance).ColorMirrorTo;
    FColorMirrorHot := (Source as TCustomTabAppearance).ColorMirrorHot;
    FColorMirrorHotTo := (Source as TCustomTabAppearance).ColorMirrorHotTo;
    FGradientMirror := (Source as TCustomTabAppearance).GradientMirror;
    FGradientMirrorHot := (Source as TCustomTabAppearance).GradientMirrorHot;
    FGradient := (Source as TCustomTabAppearance).Gradient;
    FGradientHot := (Source as TCustomTabAppearance).GradientHot;
    FColorMirrorDisabledTo := (Source as TCustomTabAppearance).ColorMirrorDisabledTo;
    FColorMirrorDisabled := (Source as TCustomTabAppearance).ColorMirrorDisabled;
    FColorMirrorSelectedTo := (Source as TCustomTabAppearance).ColorMirrorSelectedTo;
    FColorMirrorSelected := (Source as TCustomTabAppearance).ColorMirrorSelected;
    FGradientSelected := (Source as TCustomTabAppearance).GradientSelected;
    FGradientDisabled := (Source as TCustomTabAppearance).GradientDisabled;
    FGradientMirrorSelected := (Source as TCustomTabAppearance).GradientMirrorSelected;
    FGradientMirrorDisabled := (Source as TCustomTabAppearance).GradientMirrorDisabled;
    FTextColorDisabled := (Source as TCustomTabAppearance).TextColorDisabled;
    FTextColorSelected := (Source as TCustomTabAppearance).TextColorSelected;
    Font.Assign((Source as TCustomTabAppearance).Font);
    TextColor := (Source as TCustomTabAppearance).TextColor;
    TextColorHot := (Source as TCustomTabAppearance).TextColorHot;
    BackGround.Assign((Source as TCustomTabAppearance).BackGround);
  end
  else
    inherited Assign(Source);
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

//------------------------------------------------------------------------------

destructor TCustomTabAppearance.Destroy;
begin
  FBackGround.Free;
  FFont.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetBackGround(const Value: TGradientBackground);
begin
  FBackGround.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetBorderColor(const Value: TColor);
begin
  if (FBorderColor <> Value) then
  begin
    FBorderColor := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetBorderColorDisabled(const Value: TColor);
begin
  if (FBorderColorDisabled <> Value) then
  begin
    FBorderColorDisabled := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetBorderColorSelected(const Value: TColor);
begin
  if (FBorderColorSelected <> Value) then
  begin
    FBorderColorSelected := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetBorderColorSelectedHot(
  const Value: TColor);
begin
  if (FBorderColorSelectedHot <> Value) then
  begin
    FBorderColorSelectedHot := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColor(const Value: TColor);
begin
  if (FColor <> Value) then
  begin
    FColor := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorDisabled(const Value: TColor);
begin
  if (FColorDisabled <> Value) then
  begin
    FColorDisabled := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorDisabledTo(const Value: TColor);
begin
  if (FColorDisabledTo <> Value) then
  begin
    FColorDisabledTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorHot(const Value: TColor);
begin
  if (FColorHot <> Value) then
  begin
    FColorHot := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorHotTo(const Value: TColor);
begin
  if (FColorHotTo <> Value) then
  begin
    FColorHotTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorMirror(const Value: TColor);
begin
  if (FColorMirror <> Value) then
  begin
    FColorMirror := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorMirrorDisabled(const Value: TColor);
begin
  if (FColorMirrorDisabled <> Value) then
  begin
    FColorMirrorDisabled := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorMirrorDisabledTo(
  const Value: TColor);
begin
  if (FColorMirrorDisabledTo <> Value) then
  begin
    FColorMirrorDisabledTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorMirrorHot(const Value: TColor);
begin
  if (FColorMirrorHot <> Value) then
  begin
    FColorMirrorHot := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorMirrorHotTo(const Value: TColor);
begin
  if (FColorMirrorHotTo <> Value) then
  begin
    FColorMirrorHotTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorMirrorSelected(const Value: TColor);
begin
  if (FColorMirrorSelected <> Value) then
  begin
    FColorMirrorSelected := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorMirrorSelectedTo(
  const Value: TColor);
begin
  if (FColorMirrorSelectedTo <> Value) then
  begin
    FColorMirrorSelectedTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorMirrorTo(const Value: TColor);
begin
  if (FColorMirrorTo <> Value) then
  begin
    FColorMirrorTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorSelected(const Value: TColor);
begin
  if (FColorSelected <> Value) then
  begin
    FColorSelected := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorSelectedTo(const Value: TColor);
begin
  if (FColorSelectedTo <> Value) then
  begin
    FColorSelectedTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetColorTo(const Value: TColor);
begin
  if (FColorTo <> Value) then
  begin
    FColorTo := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetGradient(const Value: TGDIPGradient);
begin
  if (FGradient <> Value) then
  begin
    FGradient := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetGradientDisabled(
  const Value: TGDIPGradient);
begin
  if (FGradientDisabled <> Value) then
  begin
    FGradientDisabled := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetGradientHot(const Value: TGDIPGradient);
begin
  if (FGradientHot <> Value) then
  begin
    FGradientHot := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetGradientMirror(
  const Value: TGDIPGradient);
begin
  if (FGradientMirror <> Value) then
  begin
    FGradientMirror := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetGradientMirrorDisabled(
  const Value: TGDIPGradient);
begin
  if (FGradientMirrorDisabled <> Value) then
  begin
    FGradientMirrorDisabled := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetGradientMirrorHot(
  const Value: TGDIPGradient);
begin
  if (FGradientMirrorHot <> Value) then
  begin
    FGradientMirrorHot := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetGradientMirrorSelected(
  const Value: TGDIPGradient);
begin
  if (FGradientMirrorSelected <> Value) then
  begin
    FGradientMirrorSelected := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetGradientSelected(
  const Value: TGDIPGradient);
begin
  if (FGradientSelected <> Value) then
  begin
    FGradientSelected := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetTextColor(const Value: TColor);
begin
  if (FTextColor <> Value) then
  begin
    FTextColor := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetTextColorDisabled(const Value: TColor);
begin
  if (FTextColorDisabled <> Value) then
  begin
    FTextColorDisabled := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetTextColorHot(const Value: TColor);
begin
  if (FTextColorHot <> Value) then
  begin
    FTextColorHot := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetTextColorSelected(const Value: TColor);
begin
  if (FTextColorSelected <> Value) then
  begin
    FTextColorSelected := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.OnBackGroundChanged(Sender: TObject);
begin
  Changed;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetBorderColorDown(const Value: TColor);
begin
  if (FBorderColorDown <> Value) then
  begin
    FBorderColorDown := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomTabAppearance.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

//------------------------------------------------------------------------------

{ TDbgList }

function TDbgList.GetItemsEx(Index: Integer): Pointer;
begin
  if (Index >= Count) then
  begin
    raise Exception.Create('Index out of bounds in list read access');
  end;

  if Index < Count then
    Result := inherited Items[Index]
  else
    Result := nil;
end;

//------------------------------------------------------------------------------

procedure TDbgList.SetItemsEx(Index: Integer; const Value: Pointer);
begin
  if (Index >= Count) then
  begin
    raise Exception.Create('Index out of bounds in list write access');
  end;
  if Index < Count then
    inherited Items[Index] := value;
end;

//------------------------------------------------------------------------------

{ TCustomAdvOfficeTabSetStyler }

procedure TCustomAdvOfficeTabSetStyler.AddControl(AControl: TCustomControl);
begin
  FControlList.Add(AControl);
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.Assign(Source: TPersistent);
begin
  if Source is TCustomAdvOfficeTabSetStyler then
  begin
    TabAppearance.Assign((Source as TCustomAdvOfficeTabSetStyler).TabAppearance);
    RoundEdges := (Source as TCustomAdvOfficeTabSetStyler).RoundEdges;
    ButtonBorderColor := (Source as TCustomAdvOfficeTabSetStyler).ButtonBorderColor;
  end
  else
    inherited Assign(Source);
end;

//------------------------------------------------------------------------------

constructor TCustomAdvOfficeTabSetStyler.Create(AOwner: TComponent);
begin
  inherited;
  FControlList := TDbgList.Create;
  FRoundEdges := True;
  FBlendFactor := 50;

  FTabAppearance := TTabAppearance.Create;
  FTabAppearance.OnChange := OnTabAppearanceChanged;
  FGlowButtonAppearance := TGlowButtonAppearance.Create;
  FGlowButtonAppearance.onChange := OnGlowButtonAppearanceChanged;
  FButtonBorderColor := clNone;
end;

//------------------------------------------------------------------------------

destructor TCustomAdvOfficeTabSetStyler.Destroy;
begin
  FControlList.Free;
  FTabAppearance.Free;
  FGlowButtonAppearance.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.Change(PropID: integer);
var
  i: integer;
begin
  for i := 0 to FControlList.Count - 1 do
  begin
    if (TCustomControl(FControlList[i]) is TAdvCustomOfficeTabSet) then
      TAdvCustomOfficeTabSet(FControlList[i]).UpdateMe(PropID);
  end;
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  i: integer;
begin
  inherited;
  if not (csDestroying in ComponentState) and (Operation = opRemove) then
  begin
    i := FControlList.IndexOf(AComponent);
    if i >= 0 then
      FControlList.Remove(AComponent);
  end;

end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.RemoveControl(AControl: TCustomControl);
var
  i: integer;
begin
  i := FControlList.IndexOf(AControl);
  if i >= 0 then
    FControlList.Delete(i);
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.OnTabAppearanceChanged(Sender: TObject);
begin
  Change(1);
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.OnGlowButtonAppearanceChanged(Sender: TObject);
begin
  Change(4);
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.Loaded;
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.SetRoundEdges(const Value: boolean);
begin
  FRoundEdges := Value;
  Change(3);
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.SetTabAppearance(
  const Value: TTabAppearance);
begin
  FTabAppearance.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.SetGlowButtonAppearance(
  const Value: TGlowButtonAppearance);
begin
  FGlowButtonAppearance.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TCustomAdvOfficeTabSetStyler.SetButtonBorderColor(
  const Value: TColor);
begin
  if (FButtonBorderColor <> Value) then
  begin
    FButtonBorderColor := Value;
    Change(1);
  end;
end;

//------------------------------------------------------------------------------

{ TOfficeTabCollectionItem }

constructor TOfficeTabCollectionItem.Create(Collection: TCollection);
begin
  inherited;
  
  FCaption := 'TabItem';
  FVisible := true;
  FEnabled := true;
  FImageIndex := -1;

  FCaption := FCaption + inttostr(Index+1);
  DisplayName:= FCaption;

  FTimer := nil;

  FIPicture := TGDIPPicture.Create;
  FIPicture.OnChange := PictureChanged;

  FIDisabledPicture := TGDIPPicture.Create;
  FIDisabledPicture.OnChange := PictureChanged;

  FOfficeHint := TAdvHintInfo.Create;
  
  FChildForm := nil;

  if Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
  begin
    if (TOfficeTabCollection(Collection).AdvOfficeTabSet.ActiveTabIndex < 0) and (Index = 0) then
      TOfficeTabCollection(Collection).AdvOfficeTabSet.FActiveTabIndex := Index;
    TOfficeTabCollection(Collection).AdvOfficeTabSet.UpdateTabScroller;
    TOfficeTabCollection(Collection).AdvOfficeTabSet.Invalidate;
  end;
end;

//------------------------------------------------------------------------------
procedure TOfficeTabCollectionItem.Assign(Source: TPersistent);
begin
  if (Source is TOfficeTabCollectionItem) then
  begin
    FCaption := (Source as TOfficeTabCollectionItem).Caption;
    FVisible := (Source as TOfficeTabCollectionItem).Visible;
    FEnabled := (Source as TOfficeTabCollectionItem).Enabled;
    FOfficeHint.Assign((Source as TOfficeTabCollectionItem).OfficeHint);
    FIPicture := (Source as TOfficeTabCollectionItem).FIPicture;
    FIDisabledPicture := (Source as TOfficeTabCollectionItem).FIDisabledPicture;
    FImageIndex := (Source as TOfficeTabCollectionItem).ImageIndex;
    FTag := (Source as TOfficeTabCollectionItem).Tag;
  end
  else
    inherited Assign(Source);
end;


//------------------------------------------------------------------------------
destructor TOfficeTabCollectionItem.Destroy;
begin
  FIPicture.Free;
  FIDisabledPicture.Free;
  FOfficeHint.Free;
  if Assigned(FTimer) then
    FreeAndNil(FTimer);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TOfficeTabCollectionItem.SetCaption(const Value: string);
begin
  FCaption := Value;
  if Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
  begin
    TOfficeTabCollection(Collection).AdvOfficeTabSet.InitializeAndUpdateButtons;
    TOfficeTabCollection(Collection).AdvOfficeTabSet.UpdateTabScroller;
  end;
  Refresh;
end;

//------------------------------------------------------------------------------
procedure TOfficeTabCollectionItem.SetImageIndex(const Value: Integer);
begin
  FImageIndex := Value;
  if Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
  begin
    TOfficeTabCollection(Collection).AdvOfficeTabSet.InitializeAndUpdateButtons;
    TOfficeTabCollection(Collection).AdvOfficeTabSet.UpdateTabScroller;
  end;
  Refresh;
end;

//------------------------------------------------------------------------------
function TOfficeTabCollectionItem.GetDisplayName: string;
begin
  Result := 'Tab '+IntToStr(Index)+' : '+ Caption;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollectionItem.SetEnabled(const Value: boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    Refresh;
  end;
end;

//------------------------------------------------------------------------------
procedure TOfficeTabCollectionItem.SetVisible(const Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    if Value then
    begin

    end
    else
    begin
    end;
    
    if Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
    begin
      TOfficeTabCollection(Collection).AdvOfficeTabSet.InitializeAndUpdateButtons;
      TOfficeTabCollection(Collection).AdvOfficeTabSet.UpdateTabScroller;
    end;
    Refresh;
  end;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollectionItem.SetIndex(Value: Integer);
begin
  Inherited SetIndex(Value);
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollectionItem.SetDisabledPicture(
  const Value: TGDIPPicture);
begin
  FIDisabledPicture.Assign(Value);
  Refresh;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollectionItem.SetPicture(const Value: TGDIPPicture);
begin
  FIPicture.Assign(Value);
  Refresh;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollectionItem.TimerProc(Sender: TObject);
var
  P: TPoint;
begin
  case FGlowState of
    gsHover:
    begin
      FStepHover := FStepHover + FTimeInc;
      if ((FStepHover > 100) and (FTimeInc > 0))
         or ((FStepHover < 0) and (FTimeInc < 0)) then
      begin
        if (FStepHover > 100) and (FTimeInc > 0) and Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
        begin
          FStepHover := 120;
          GetCursorPos(P);
          P := TOfficeTabCollection(Collection).AdvOfficeTabSet.ScreenToClient(P);
          if not PtInRect(TOfficeTabCollection(Collection).AdvOfficeTabSet.GetTabRect(Self.Index), P) then
          begin
            FTimeInc := -20;
            FGlowState := gsHover;
            TOfficeTabCollection(Collection).AdvOfficeTabSet.FHotTabIndex := -1;
            Exit;
          end;
        end
        else if ((FStepHover < 0) and (FTimeInc < 0)) then
        begin
          FreeAndNil(FTimer);
          FGlowState := gsNone;
          if Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
            TOfficeTabCollection(Collection).AdvOfficeTabSet.InvalidateTab(Index);
        end;

        FStepPush := 0;
        if (FStepHover > 100) then
          FStepHover := 120;
        if (FStepHover < 0) then
          FStepHover := -20;
      end
      else if Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
        TOfficeTabCollection(Collection).AdvOfficeTabSet.InvalidateTab(Index);
    end;
    gsPush:
    begin
      FStepPush := FStepPush + FTimeInc;
      if ((FStepPush > 100) and (FTimeInc > 0))
         or ((FStepPush < 0) and (FTimeInc < 0)) then
      begin
        FreeAndNil(FTimer);
        FGlowState := gsNone;
        FStepPush := 0;
      end
      else if Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
        TOfficeTabCollection(Collection).AdvOfficeTabSet.InvalidateTab(Index);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollectionItem.PictureChanged(Sender: TObject);
begin
  Refresh;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollectionItem.Refresh;
begin
  if Assigned(TOfficeTabCollection(Collection).AdvOfficeTabSet) then
    TOfficeTabCollection(Collection).AdvOfficeTabSet.Invalidate;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollectionItem.SetOfficeHint(
  const Value: TAdvHintInfo);
begin
  FOfficeHint.Assign(Value);
end;

//------------------------------------------------------------------------------

{ TOfficeTabCollection }

function TOfficeTabCollection.Add: TOfficeTabCollectionItem;
begin
  Result := TOfficeTabCollectionItem(inherited Add);
end;

//------------------------------------------------------------------------------

constructor TOfficeTabCollection.Create(AOwner: TAdvCustomOfficeTabSet);
begin
  inherited Create(TOfficeTabCollectionItem);
  FOwner := AOwner;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollection.Delete(Index: Integer);
var
  ActItem: TOfficeTabCollectionItem;
begin
  if not Assigned(AdvOfficeTabSet) then
    Exit;
    
  if (Index = AdvOfficeTabSet.ActiveTabIndex) then
  begin
    AdvOfficeTabSet.SelectNextTab(True);
  end;

  ActItem := nil;
  if (AdvOfficeTabSet.ActiveTabIndex >= 0) then
  begin
    ActItem := Items[AdvOfficeTabSet.ActiveTabIndex];
    if (ActItem = Items[Index])then
      ActItem := nil;
  end;

  inherited Delete(Index);
  
  if (ActItem <> nil) then
  begin
    AdvOfficeTabSet.FActiveTabIndex := -1;
    AdvOfficeTabSet.ActiveTabIndex := ActItem.Index;
  end
  else
  begin
    AdvOfficeTabSet.ActiveTabIndex := -1;
  end;

  AdvOfficeTabSet.UpdateTabScroller;
  AdvOfficeTabSet.Invalidate;
end;

//------------------------------------------------------------------------------

function TOfficeTabCollection.GetItem(Index: Integer): TOfficeTabCollectionItem;
begin
  Result := TOfficeTabCollectionItem(inherited Items[Index]);
end;

//------------------------------------------------------------------------------
function TOfficeTabCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

//------------------------------------------------------------------------------

function TOfficeTabCollection.Insert(Index: Integer): TOfficeTabCollectionItem;
begin
  Result := TOfficeTabCollectionItem(inherited Insert(Index));
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollection.Move(CurIndex, NewIndex: integer);
begin
  if (CurIndex >= 0) and (CurIndex < Count) and (NewIndex >= 0) and (NewIndex < Count) and (CurIndex <> NewIndex) then
  begin
    Items[CurIndex].SetIndex(NewIndex);
    if Assigned(AdvOfficeTabSet) then
    begin
      AdvOfficeTabSet.UpdateTabScroller;
      AdvOfficeTabSet.Invalidate;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TOfficeTabCollection.SetItem(Index: Integer; const Value: TOfficeTabCollectionItem);
begin
  inherited Items[Index] := Value;
end;

//------------------------------------------------------------------------------

{ TAdvCustomOfficeTabSet }

constructor TAdvCustomOfficeTabSet.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle - [csOpaque];

  FInternalOfficeTabSetStyler := TCustomAdvOfficeTabSetStyler.Create(self);
  FInternalOfficeTabSetStyler.Name := 'InternalStyler';

  FOfficeTabSetStyler := nil;
  FCurrentOfficeTabSetStyler := FInternalOfficeTabSetStyler;
  FCurrentOfficeTabSetStyler.AddControl(self);
  {$IFDEF DELPHI6_LVL}
  FInternalOfficeTabSetStyler.SetSubComponent(True);
  {$ENDIF}

  FOffSetX := 0;
  FOffSetY := 0;

  FTabOffSet := 4;

  FTabPosition := tpTop;

  FAntiAlias := aaClearType;

  FAdvOfficeTabs := TOfficeTabCollection.Create(Self);

  FTabScroller := TTabSetTabScroller.Create;

  FTabSettings := TTabSetTabSettings.Create;
  FTabSettings.OnChange := OnTabSettingsChanged;

  FActiveTabIndex := -1;
  FHotTabIndex := -1;
  FOldHotTabIndex := -1;
  FDownTabIndex := -1;

  FShowTabHint := false;
  FHintTabIndex := -1;
  ShowHint := false;

  FButtonSettings := TTabSetButtonSettings.Create;
  FButtonSettings.OnChange := OnButtonSettingChanged;
  FTabListMenu := nil;
  FRotateTabLeftRight := true;
  FCloseOnTab := false;

  DoubleBuffered := true;
  Height := 27;
  Width := 200;
  FOldCapRightIndent := 0;

  TabRearrange := False;

  FOfficeHint := TAdvHintInfo.Create;
  FDummyHintControl := TDummyHintControl.Create(Self);
  FDummyHintControl.Visible := False;

  FCloseButton := nil;
  FTabListButton := nil;
  FScrollPrevButton := nil;
  FScrollNextButton := nil;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CreateParams(var Params: TCreateParams);
begin
  inherited;
end;

//------------------------------------------------------------------------------

destructor TAdvCustomOfficeTabSet.Destroy;
begin
  FInternalOfficeTabSetStyler.Free;
  FAdvOfficeTabs.Free;
  FTabSettings.Free;
  FTabScroller.Free;
  FOfficeHint.Free;
  FDummyHintControl.Free;
  FButtonSettings.Free;
  if (FCloseButton <> nil) then
    FCloseButton.Free;
  if (FTabListButton <> nil) then
    FTabListButton.Free;
  if (FScrollPrevButton <> nil) then
    FScrollPrevButton.Free;
  if (FScrollNextButton <> nil) then
    FScrollNextButton.Free;
  inherited;
end;

//------------------------------------------------------------------------------
(*
procedure TAdvCustomOfficeTabSet.MoveAdvOfficeTab(CurIndex, NewIndex: Integer);
var
  OldActiveTab: Integer;
begin
  if (CurIndex >= 0) and (CurIndex < FAdvOfficeTabs.Count) and
     (NewIndex >= 0) and (NewIndex < FAdvOfficeTabs.Count) then
  begin
    OldActiveTab := ActiveTabIndex;
    FAdvOfficeTabs.Move(CurIndex, NewIndex);
    ActiveTabIndex := OldActiveTab;
    UpdateTabScroller;
  end;
end;

*)
//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.AlignControls(AControl: TControl;
  var ARect: TRect);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.Loaded;
begin
  inherited;
  FPropertiesLoaded := True;
  InitializeAndUpdateButtons;
  UpdateTabScroller;  
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;

  if not (csDestroying in ComponentState) and (Operation = opRemove) then
  begin
    if AComponent = AdvOfficeTabSetStyler then
      AdvOfficeTabSetStyler := nil;
    if (AComponent = PopupMenu) then
      PopupMenu := nil;
    if (AComponent = Images) then
      Images := nil;
    if (AComponent = DisabledImages) then
      DisabledImages := nil;
    if (AComponent = TabListMenu) then
      TabListMenu := nil;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.AdjustClientRect(var Rect: TRect);
begin
  inherited AdjustClientRect(Rect);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.DrawTab(TabIndex: Integer);
var
  GradColor: TColor;
  GradColorTo: TColor;
  GradColorMirror: TColor;
  GradColorMirrorTo: TColor;
  PenColor: TColor;
  GradB, GradU: TGDIPGradient;
  ImgList: TCustomImageList;
  Pic: TGDIPPicture;
  ImgEnabled: Boolean;
  R, CapR: TRect;
  ImgX, ImgY, ImgTxtSp: Integer;
  ImgW, ImgH: Integer;
  DCaption: string;
  DoRepaint: Boolean;
  TxtClr: TColor;
  TabAppearance: TCustomTabAppearance;
  tf: TFont;
  lf: TLogFont;
  bmp: TBitMap;
  R2: TRect;

begin
  if (TabIndex < 0) or (TabIndex >= FAdvOfficeTabs.Count) then
    Exit;

  ImgTxtSp := IMG_SPACE;
  GradColor := clNone;
  GradColorTo := clNone;
  GradColorMirror := clNone;
  GradColorMirrorTo := clNone;
  PenColor := clNone;
  TxtClr := clNone;
  GradB := ggRadial;
  GradU := ggRadial;
  
  ImgList := nil;
  DoRepaint := True;

  R := GetTabRect(TabIndex);

  if (R.Left <= -1) and (R.Right <= -1) then
    Exit;

  TabAppearance := FCurrentOfficeTabSetStyler.TabAppearance;

  with TabAppearance do
  begin
    if not(FAdvOfficeTabs.Items[TabIndex].Enabled) and ShowNonSelectedTabs then
    begin
      if ShowNonSelectedTabs then
      begin
        GradColor := ColorDisabled;
        GradColorTo := ColorDisabledTo;
        GradColorMirror := ColorMirrorDisabled;
        GradColorMirrorTo := ColorMirrorDisabledTo;
        PenColor := BorderColorDisabled;
        GradU := GradientDisabled;
        GradB := GradientMirrorDisabled;
        TxtClr := TextColorDisabled;
      end
      else
      begin

      end;
    end
    else
    if (TabIndex = ActiveTabIndex) then
    begin
      GradColor := ColorSelected;
      GradColorTo := ColorSelectedTo;
      GradColorMirror := ColorMirrorSelected;
      GradColorMirrorTo := ColorMirrorSelectedTo;
      PenColor := BorderColorSelected;
      GradU := GradientSelected;
      GradB := GradientMirrorSelected;
      TxtClr := TextColorSelected;

      if (TabIndex = FHotTabIndex) then
        PenColor := BorderColorSelectedHot;

      if Assigned(FAdvOfficeTabs.Items[TabIndex].FTimer) then
      begin
        if (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsPush) then
        begin
          GradColor := BlendColor(GradColor, FColorHot, FAdvOfficeTabs.Items[TabIndex].FStepPush);
          GradColorTo := BlendColor(GradColorTo, FColorHotTo, FAdvOfficeTabs.Items[TabIndex].FStepPush);
          GradColorMirror := BlendColor(GradColorMirror, FColorMirrorHot, FAdvOfficeTabs.Items[TabIndex].FStepPush);
          GradColorMirrorTo := BlendColor(GradColorMirrorTo, FColorMirrorHotTo, FAdvOfficeTabs.Items[TabIndex].FStepPush);
          PenColor := BlendColor(PenColor, BorderColorHot, FAdvOfficeTabs.Items[TabIndex].FStepPush);
        end
        else if (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsHover) then
          PenColor := BlendColor(BorderColorSelectedHot, BorderColorSelected, FAdvOfficeTabs.Items[TabIndex].FStepHover);
      end;

      if (FDownTabIndex = TabIndex) and not (csDesigning in ComponentState) then
        PenColor := BorderColorDown;
    end
    else //if State = absUp then
    begin
      if (TabIndex = FHotTabIndex) then
      begin
        GradColor := ColorHot;
        GradColorTo := ColorHotTo;
        GradColorMirror := ColorMirrorHot;
        GradColorMirrorTo := ColorMirrorHotTo;
        PenColor := BorderColorHot;
        GradU := GradientHot;
        GradB := GradientMirrorHot;
        TxtClr := TextColorHot;
        if Assigned(FAdvOfficeTabs.Items[TabIndex].FTimer) and (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsHover) then
        begin
          if ShowNonSelectedTabs then
          begin
            GradColor := BlendColor(FColorHot, FColor, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorTo := BlendColor(FColorHotTo, FColorTo, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorMirror := BlendColor(FColorMirrorHot, FColorMirror, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorMirrorTo := BlendColor(FColorMirrorHotTo, FColorMirrorTo, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            PenColor := BlendColor(BorderColorHot, BorderColor, FAdvOfficeTabs.Items[TabIndex].FStepHover);
          end
          else
          begin
            GradColor := BlendColor(FColorHot, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            if (FCurrentOfficeTabSetStyler.TabAppearance.BackGround.ColorTo <> clNone) then
              GradColorTo := BlendColor(FColorHotTo, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.ColorTo, FAdvOfficeTabs.Items[TabIndex].FStepHover)
            else
              GradColorTo := BlendColor(FColorHotTo, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorMirror := BlendColor(FColorMirrorHot, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorMirrorTo := BlendColor(FColorMirrorHotTo, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            PenColor := BlendColor(BorderColorHot, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
          end;
        end;
      end
      else // Normal draw
      begin
        if ShowNonSelectedTabs then
        begin
          GradColor := Color;
          GradColorTo := ColorTo;
          GradColorMirror := ColorMirror;
          GradColorMirrorTo := ColorMirrorTo;
          PenColor := BorderColor;
          GradU := Gradient;
          GradB := GradientMirror;
          TxtClr := TextColor;
          if Assigned(FAdvOfficeTabs.Items[TabIndex].FTimer) and (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsHover) {and (TabIndex = FOldHotTabIndex)} then
          begin
            GradColor := BlendColor(FColorHot, FColor, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorTo := BlendColor(FColorHotTo, FColorTo, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorMirror := BlendColor(FColorMirrorHot, FColorMirror, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorMirrorTo := BlendColor(FColorMirrorHotTo, FColorMirrorTo, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            PenColor := BlendColor(BorderColorHot, BorderColor, FAdvOfficeTabs.Items[TabIndex].FStepHover);
          end;
        end
        else
        begin
          DoRepaint := False;
          TxtClr := TextColor;
          GradU := GradientHot;
          GradB := GradientMirrorHot;

          if not FAdvOfficeTabs.Items[TabIndex].Enabled then
           TxtClr := TextColorDisabled;


          if Assigned(FAdvOfficeTabs.Items[TabIndex].FTimer) and (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsHover){ and (TabIndex = FOldHotTabIndex)} then
          begin
            GradColor := BlendColor(FColorHot, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            if (FCurrentOfficeTabSetStyler.TabAppearance.BackGround.ColorTo <> clNone) then
              GradColorTo := BlendColor(FColorHotTo, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.ColorTo, FAdvOfficeTabs.Items[TabIndex].FStepHover)
            else
              GradColorTo := BlendColor(FColorHotTo, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorMirror := BlendColor(FColorMirrorHot, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            GradColorMirrorTo := BlendColor(FColorMirrorHotTo, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            PenColor := BlendColor(BorderColorHot, FCurrentOfficeTabSetStyler.TabAppearance.BackGround.Color, FAdvOfficeTabs.Items[TabIndex].FStepHover);
            DoRepaint := True;
          end;
        end;
      end;
    end;

    DCaption := FAdvOfficeTabs.Items[TabIndex].Caption;
    Canvas.Font.Assign(TabAppearance.Font);
    Canvas.Font.Color := TxtClr;

    if DoRepaint then
    begin
      if (ActiveTabIndex = TabIndex) and (CloseOnTab) and (ButtonSettings.CloseButton) and false then
      begin
        bmp := TBitMap.Create;
        bmp.Height := (R.Bottom - R.Top) - 4;
        bmp.Width := R.Right - R.Left;
        DrawVistaGradient(bmp.Canvas, Rect(0, 0, R.Right - R.Left, R.Bottom-R.Top),GradColor, GradColorTo, GradColorMirror, GradColorMirrorTo, PenColor,
          GradU, GradB, '', {Canvas.}Font, Enabled, False, FAntiAlias, True{FCurrentOfficeTabSetStyler.RoundEdges}, TabPosition);
        Canvas.Draw(R.Left, R.Top, bmp);
        bmp.Free;
      end
      else
      begin
        //DrawVistaGradient(Canvas, R,GradColor, GradColorTo, GradColorMirror, GradColorMirrorTo, PenColor,
         //GradU, GradB, '', {Canvas.}Font, Enabled, False, FAntiAlias, True{FCurrentOfficeTabSetStyler.RoundEdges}, TabPosition);
        bmp := TBitMap.Create;
        if (TabPosition = tpTop) then
        begin
          bmp.Height := (R.Bottom - R.Top) - 4;
          bmp.Width := R.Right - R.Left;
          R2 := Rect(0, 0, R.Right - R.Left, R.Bottom-R.Top);
        end
        else if (TabPosition = tpBottom) then
        begin
          bmp.Height := (R.Bottom - R.Top){- 4};
          bmp.Width := R.Right - R.Left;
          R2 := Rect(0, 0, R.Right - R.Left, R.Bottom-R.Top);
        end
        else if (TabPosition = tpLeft) then
        begin
          bmp.Height := (R.Bottom - R.Top);
          bmp.Width := (R.Right - R.Left) - 4;
          R2 := Rect(0, 0, R.Right - R.Left, R.Bottom-R.Top);
        end
        else if (TabPosition = tpRight) then
        begin
          bmp.Height := (R.Bottom - R.Top);
          bmp.Width := (R.Right - R.Left);
          R2 := Rect(-4, 0, (R.Right - R.Left), R.Bottom-R.Top);
          //R.Left := R.Left+2;
        end;
        DrawVistaGradient(bmp.Canvas, R2,GradColor, GradColorTo, GradColorMirror, GradColorMirrorTo, PenColor,
          GradU, GradB, '', {Canvas.}Font, Enabled, False, FAntiAlias, True{FCurrentOfficeTabSetStyler.RoundEdges}, TabPosition);
        Canvas.Draw(R.Left, R.Top, bmp);
        bmp.Free;
       end;
       
      case TabPosition of
        tpTop:
        begin
          if True{FCurrentOfficeTabSetStyler.RoundEdges} then
          begin
            Canvas.Pixels[R.Left, R.Top] := Canvas.Pixels[R.Left - 1, R.Top - 1];
            Canvas.Pixels[R.Left + 1, R.Top] := Canvas.Pixels[R.Left + 1, R.Top - 1];
            Canvas.Pixels[R.Left, R.Top + 1] := Canvas.Pixels[R.Left - 1, R.Top];

            Canvas.Pixels[R.Right - 1, R.Top] := Canvas.Pixels[R.Right + 1, R.Top];
            Canvas.Pixels[R.Right - 2, R.Top] := Canvas.Pixels[R.Right + 1, R.Top];
            Canvas.Pixels[R.Right - 1, R.Top + 1] := Canvas.Pixels[R.Right + 1, R.Top];
          end;

          //--- Draw 3D effect
          if not Assigned(FAdvOfficeTabs.Items[TabIndex].FTimer) then
          begin
            Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
            Canvas.MoveTo(R.Left+3, R.Top + 3);
            Canvas.LineTo(R.Right-3, R.Top+3);
          end
          else
          begin
            if (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsHover) then
              Canvas.Pen.Color := BlendColor(clWhite, GradColor, Min(20, FAdvOfficeTabs.Items[TabIndex].FStepHover))
            else
              Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
            Canvas.MoveTo(R.Left+3, R.Top + 3);
            Canvas.LineTo(R.Right-3, R.Top+3);
          end;
          //if not Assigned(AdvPages[PageIndex].FTimer) then
          begin
            Canvas.Pen.Color := BlendColor(GradColor, PenColor, 80);
            Canvas.MoveTo(R.Left+3, R.Top+1);
            Canvas.LineTo(R.Right-3, R.Top+1);
            Canvas.Pen.Color := BlendColor(GradColor, PenColor, FCurrentOfficeTabSetStyler.BlendFactor);
            Canvas.MoveTo(R.Left+1, R.Top + 3);
            Canvas.LineTo(R.Left+1, R.Bottom-5);
            Canvas.MoveTo(R.Right-2, R.Top + 3);
            Canvas.LineTo(R.Right-2, R.Bottom-5);
          end;
        end;
        tpBottom:
        begin
          if True{FCurrentOfficeTabSetStyler.RoundEdges} then
          begin
            Canvas.Pixels[R.Left, R.Bottom-2] := Canvas.Pixels[R.Left - 1, R.Bottom - 1];
            Canvas.Pixels[R.Left + 1, R.Bottom-1] := Canvas.Pixels[R.Left - 1, R.Bottom - 1];
            Canvas.Pixels[R.Left, R.Bottom - 1] := Canvas.Pixels[R.Left - 1, R.Bottom -1];

            Canvas.Pixels[R.Right - 1, R.Bottom-1] := Canvas.Pixels[R.Right + 1, R.Bottom];
            Canvas.Pixels[R.Right - 2, R.Bottom-1] := Canvas.Pixels[R.Right + 1, R.Bottom];
            Canvas.Pixels[R.Right - 1, R.Bottom - 2] := Canvas.Pixels[R.Right + 1, R.Bottom];
          end;

          //--- Draw 3D effect
          if not Assigned(FAdvOfficeTabs.Items[TabIndex].FTimer) then
          begin
            Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
            Canvas.MoveTo(R.Left+3, R.Bottom - 4);
            Canvas.LineTo(R.Right-3, R.Bottom - 4);
          end
          else
          begin
            if (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsHover) then
              Canvas.Pen.Color := BlendColor(clWhite, GradColor, Min(20, FAdvOfficeTabs.Items[TabIndex].FStepHover))
            else
              Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
            Canvas.MoveTo(R.Left+3, R.Bottom - 4);
            Canvas.LineTo(R.Right-3, R.Bottom - 4);
          end;
          //if not Assigned(AdvPages[PageIndex].FTimer) then
          begin
            Canvas.Pen.Color := BlendColor(GradColor, PenColor, 80);
            Canvas.MoveTo(R.Left+3, R.Bottom -2);
            Canvas.LineTo(R.Right-3, R.Bottom -2);
            Canvas.Pen.Color := BlendColor(GradColor, PenColor, FCurrentOfficeTabSetStyler.BlendFactor);
            Canvas.MoveTo(R.Left+1, R.Bottom - 3);
            Canvas.LineTo(R.Left+1, R.Top + 5);
            Canvas.MoveTo(R.Right-2, R.Bottom - 3);
            Canvas.LineTo(R.Right-2, R.Top + 5);
          end; 
        end;
        tpLeft:
        begin
          if True{FCurrentOfficeTabSetStyler.RoundEdges} then
          begin
            Canvas.Pixels[R.Left, R.Top] := Canvas.Pixels[R.Left - 1, R.Top - 1];
            Canvas.Pixels[R.Left + 1, R.Top] := Canvas.Pixels[R.Left + 1, R.Top - 1];
            Canvas.Pixels[R.Left, R.Top + 1] := Canvas.Pixels[R.Left - 1, R.Top];

            Canvas.Pixels[R.Left, R.Bottom-1] := Canvas.Pixels[R.Left - 1, R.Bottom];
            Canvas.Pixels[R.Left + 1, R.Bottom-1] := Canvas.Pixels[R.Left - 1, R.Bottom];
            Canvas.Pixels[R.Left, R.Bottom - 2] := Canvas.Pixels[R.Left - 1, R.Bottom];
          end;

          //--- Draw 3D effect
          if not Assigned(FAdvOfficeTabs.Items[TabIndex].FTimer) then
          begin
            Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
            Canvas.MoveTo(R.Left+3, R.Top + 3);
            Canvas.LineTo(R.Left+3, R.Bottom - 3);
          end
          else
          begin
            if (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsHover) then
              Canvas.Pen.Color := BlendColor(clWhite, GradColor, Min(20, FAdvOfficeTabs.Items[TabIndex].FStepHover))
            else
              Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
            Canvas.MoveTo(R.Left+3, R.Top + 3);
            Canvas.LineTo(R.Left+3, R.Bottom - 3);
          end;
          //if not Assigned(AdvPages[PageIndex].FTimer) then
          begin
            Canvas.Pen.Color := BlendColor(GradColor, PenColor, 80);
            Canvas.MoveTo(R.Left+1, R.Top+3);
            Canvas.LineTo(R.Left+1, R.Bottom-3);
            Canvas.Pen.Color := BlendColor(GradColor, PenColor, FCurrentOfficeTabSetStyler.BlendFactor);
            Canvas.MoveTo(R.Left+3, R.Top + 1);
            Canvas.LineTo(R.Right-5, R.Top+1);
            Canvas.MoveTo(R.Left+3, R.Bottom-2);
            Canvas.LineTo(R.Right-5, R.Bottom-2);
          end;
        end;
        tpRight:
        begin
          if True{FCurrentOfficeTabSetStyler.RoundEdges} then
          begin
            Canvas.Pixels[R.Right, R.Top] := Canvas.Pixels[R.Right + 1, R.Top - 1];
            Canvas.Pixels[R.Right - 1, R.Top] := Canvas.Pixels[R.Right + 1, R.Top - 1];
            Canvas.Pixels[R.Right, R.Top + 1] := Canvas.Pixels[R.Right + 1, R.Top];

            Canvas.Pixels[R.Right, R.Bottom-1] := Canvas.Pixels[R.Right + 1, R.Bottom];
            Canvas.Pixels[R.Right - 1, R.Bottom-1] := Canvas.Pixels[R.Right + 1, R.Bottom];
            Canvas.Pixels[R.Right, R.Bottom - 2] := Canvas.Pixels[R.Right + 1, R.Bottom];
          end;

          //--- Draw 3D effect
          if not Assigned(FAdvOfficeTabs.Items[TabIndex].FTimer) then
          begin
            Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
            Canvas.MoveTo(R.Right-3, R.Top + 3);
            Canvas.LineTo(R.Right-3, R.Bottom - 3);
          end
          else
          begin
            if (FAdvOfficeTabs.Items[TabIndex].FGlowState = gsHover) then
              Canvas.Pen.Color := BlendColor(clWhite, GradColor, Min(20, FAdvOfficeTabs.Items[TabIndex].FStepHover))
            else
              Canvas.Pen.Color := BlendColor(clWhite, GradColor, 50);
            Canvas.MoveTo(R.Right-3, R.Top + 3);
            Canvas.LineTo(R.Right-3, R.Bottom - 3);
          end;
          //if not Assigned(AdvPages[PageIndex].FTimer) then
          begin
            Canvas.Pen.Color := BlendColor(GradColor, PenColor, 80);
            Canvas.MoveTo(R.Right-2, R.Top+3);
            Canvas.LineTo(R.Right-2, R.Bottom-3);
            Canvas.Pen.Color := BlendColor(GradColor, PenColor, FCurrentOfficeTabSetStyler.BlendFactor);
            Canvas.MoveTo(R.Left+5, R.Top + 1);
            Canvas.LineTo(R.Right-3, R.Top+1);
            Canvas.MoveTo(R.Left+5, R.Bottom-2);
            Canvas.LineTo(R.Right-3, R.Bottom-2);
          end;
        end;
      end;

    end;

    case TabPosition of
      tpTop, tpBottom:
      begin
        CapR := Rect(R.Left + FTabSettings.LeftMargin, R.Top, R.Right, R.Bottom);
        if (ButtonSettings.CloseButton and CloseOnTab and (ActiveTabIndex <> TabIndex)) then
          CapR.Left := CapR.Left + (TabBUTTON_SIZE + 4 ) div 2;
      end;
      tpLeft:
      begin
        if RotateTabLeftRight then
        begin
          CapR := Rect(R.Left, R.Top, R.Right, R.Bottom - FTabSettings.LeftMargin);
          if (ButtonSettings.CloseButton and CloseOnTab and (ActiveTabIndex <> TabIndex)) then
            CapR.Bottom := CapR.Bottom - (TabBUTTON_SIZE + 4) div 2;
        end
        else
        begin
          CapR := Rect(R.Left + FTabSettings.LeftMargin, R.Top, R.Right, R.Bottom);
        end;
      end;
      tpRight:
      begin
        if RotateTabLeftRight then
        begin
          CapR := Rect(R.Left, R.Top + FTabSettings.LeftMargin, R.Right, R.Bottom);
          if (ButtonSettings.CloseButton and CloseOnTab and (ActiveTabIndex <> TabIndex)) then
            CapR.Top := CapR.Top + (TabBUTTON_SIZE + 4) div 2;
        end
        else
        begin
          CapR := Rect(R.Left + FTabSettings.LeftMargin + 3, R.Top, R.Right, R.Bottom);
        end;
      end;
    end;

    if FAdvOfficeTabs.Items[TabIndex].Enabled or FAdvOfficeTabs.Items[TabIndex].DisabledPicture.Empty then
      Pic := FAdvOfficeTabs.Items[TabIndex].Picture
    else
      Pic := FAdvOfficeTabs.Items[TabIndex].DisabledPicture;

    if Assigned(Pic) and not Pic.Empty then
    begin
      Pic.GetImageSizes;
      ImgW := Pic.Width;
      ImgH := Pic.Height;

      ImgY := CapR.Top;
      ImgX := CapR.Left;
      case TabPosition of
        tpTop, tpBottom:
        begin
          ImgX := CapR.Left;
          CapR.Left := CapR.Left + ImgW + ImgTxtSp;
          ImgY := R.Top + ((R.Bottom - R.Top) - ImgH) div 2;
        end;
        tpLeft:
        begin
          if not RotateTabLeftRight then
          begin
            ImgX := CapR.Left;
            CapR.Left := CapR.Left + ImgW + ImgTxtSp;
            ImgY := R.Top + ((R.Bottom - R.Top) - ImgH) div 2;
          end
          else
          begin
            ImgX := R.Left + ((R.Right - R.Left) - ImgW) div 2;
            ImgY := CapR.Bottom - ImgH;
            CapR.Bottom := ImgY - ImgTxtSp;
          end;
        end;
        tpRight:
        begin
          if not RotateTabLeftRight then
          begin
            ImgX := CapR.Left;
            CapR.Left := CapR.Left + ImgW + ImgTxtSp;
            ImgY := R.Top + ((R.Bottom - R.Top) - ImgH) div 2;
          end
          else
          begin
            ImgX := R.Left + ((R.Right - R.Left) - ImgW) div 2;
            ImgY := CapR.Top;
            CapR.Top := CapR.Top + ImgH + ImgTxtSp;
          end;  
        end;
      end;

      Canvas.Draw(ImgX, ImgY, Pic);
    end
    else
    if (Assigned(FImages) or Assigned(DisabledImages)) and (FAdvOfficeTabs.Items[TabIndex].ImageIndex >= 0) then
    begin
      ImgEnabled := True;
      if FAdvOfficeTabs.Items[TabIndex].Enabled then
      begin
        if Assigned(FImages) then
          ImgList := FImages;
      end
      else
      begin
        if Assigned(FDisabledImages) then
          ImgList := FDisabledImages
        else if Assigned(FImages) then
        begin
          ImgList := FImages;
          ImgEnabled := False;
        end;
      end;

      if (ImgList <> nil) then
      begin
        ImgY := CapR.Top;
        ImgX := CapR.Left;
        case TabPosition of
          tpTop, tpBottom:
          begin
            ImgX := CapR.Left;
            CapR.Left := CapR.Left + ImgList.Width + ImgTxtSp;
            ImgY := R.Top + ((R.Bottom - R.Top) - ImgList.Height) div 2;
          end;
          tpLeft:
          begin
            if not RotateTabLeftRight then
            begin
              ImgX := CapR.Left;
              CapR.Left := CapR.Left + ImgList.Width + ImgTxtSp;
              ImgY := R.Top + ((R.Bottom - R.Top) - ImgList.Height) div 2;
            end
            else
            begin
              ImgX := R.Left + ((R.Right - R.Left) - ImgList.Width) div 2;
              ImgY := CapR.Bottom - ImgList.Height;
              CapR.Bottom := ImgY - ImgTxtSp;
            end;
          end;
          tpRight:
          begin
            if not RotateTabLeftRight then
            begin
              ImgX := CapR.Left;
              CapR.Left := CapR.Left + ImgList.Width + ImgTxtSp;
              ImgY := R.Top + ((R.Bottom - R.Top) - ImgList.Height) div 2;
            end
            else
            begin
              ImgX := R.Left + ((R.Right - R.Left) - ImgList.Width) div 2;
              ImgY := CapR.Top;
              CapR.Top := CapR.Top + ImgList.Height + ImgTxtSp;
            end;  
          end;
        end;

        ImgList.Draw(Canvas, ImgX, ImgY, FAdvOfficeTabs.Items[TabIndex].ImageIndex, ImgEnabled);
      end;
    end;

    Canvas.Brush.Style := bsClear;
    if (not RotateTabLeftRight and (TabPosition in [tpLeft, tpRight])) then
    begin
      DrawVistaText(Canvas, taLeftJustify, CapR, DCaption, Canvas.Font, FAdvOfficeTabs.Items[TabIndex].Enabled, True, FAntiAlias, tpTop);
    end
    else
    if (TabPosition = tpLeft) then
    begin
      if (DCaption <> '') then
      begin
        // Make sure to use a truetype font!
        // Font.Name := 'Tahoma';

        tf := TFont.Create;
        try
          if (TabPosition = tpLeft) or (TabPosition = tpRight) then
          begin
{$IFNDEF TMSDOTNET}
            FillChar(lf, SizeOf(lf), 0);
{$ENDIF}
            tf.Assign(Canvas.Font);
{$IFNDEF TMSDOTNET}
            GetObject(tf.Handle, SizeOf(Lf), @Lf);
{$ENDIF}
{$IFDEF TMSDOTNET}
            GetObject(tf.Handle, Marshal.SizeOf(TypeOf(Lf)), Lf);
{$ENDIF}

            if TabPosition = tpLeft then lf.lfEscapement := -2700
            else lf.lfEscapement := -900;
            lf.lfOrientation := 30;

            tf.Handle := CreateFontIndirect(Lf);
            Canvas.Font.Assign(tf);
          end;
        finally
          tf.Free;
        end;
        Canvas.TextOut(CapR.Left + ((CapR.Right - CapR.Left)-Canvas.TextHeight('gh')) div 2, CapR.Bottom, DCaption);
      end;
    end
    else
    begin
      DrawVistaText(Canvas, taLeftJustify, CapR, DCaption, Canvas.Font, FAdvOfficeTabs.Items[TabIndex].Enabled, True, FAntiAlias, TabPosition);
      //DrawText(Canvas.Handle, PChar(DCaption), Length(DCaption), R, DT_SINGLELINE or DT_VCENTER);
    end;  

  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.DrawAllTabs;
var
  i: Integer;
  R: TRect;
begin
  // Draw TabBackGround
  R := GetTabsArea;
  case TabPosition of
    tpTop: R.Bottom := ClientRect.Bottom;
    tpBottom: R.Top := ClientRect.Top;
    tpLeft: R.Right := ClientRect.Right;
    tpRight: R.Left := ClientRect.Left;
  end;

  with FCurrentOfficeTabSetStyler.TabAppearance do
  begin
    if (BackGround.Color <> clNone) and (BackGround.ColorTo <> clNone) then
      DrawGradient(Canvas, BackGround.Color, BackGround.ColorTo, BackGround.Steps, R, BackGround.Direction = gdHorizontal)
    else if (BackGround.Color <> clNone) then
    begin
      Canvas.Brush.Color := BackGround.Color;
      Canvas.Pen.Color := BackGround.Color;
      Canvas.Rectangle(R.Left, R.Top, R.Right, R.Bottom);
    end;
  end;

  for i:= 0 to FAdvOfficeTabs.Count-1 do
    DrawTab(i);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.Paint;
begin
  inherited;

  DrawAllTabs;
  DrawTabScrollButtons;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetOfficeTabSetStyler(
  const Value: TCustomAdvOfficeTabSetStyler);
begin
  if (FOfficeTabSetStyler <> Value) or (Value = nil) then
  begin
    if Assigned(FOfficeTabSetStyler) and (FOfficeTabSetStyler <> FInternalOfficeTabSetStyler) then
      FOfficeTabSetStyler.RemoveControl(self);

    FOfficeTabSetStyler := Value;

    if FOfficeTabSetStyler = nil then
    begin
      FCurrentOfficeTabSetStyler := FInternalOfficeTabSetStyler;
    end
    else
    begin
      FCurrentOfficeTabSetStyler := FOfficeTabSetStyler;
      FOfficeTabSetStyler.AddControl(self);
    end;

    UpdateMe(0);
    PopupMenu := PopupMenu;   // Refresh Styler
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;

end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetChildOrder(Child: TComponent; Order: Integer);
begin
  inherited SetChildOrder(Child, Order);
end;

//------------------------------------------------------------------------------


procedure TAdvCustomOfficeTabSet.WMSize(var Message: TWMSize);
begin
  inherited;
  UpdateTabScroller;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetPopupMenuEx(const Value: TPopupMenu);
begin
  Inherited PopupMenu := Value;
  (*if Assigned(PopupMenu) and (PopupMenu is TAdvPopupMenu) and Assigned(FCurrentOfficeTabSetStyler) then
    TAdvPopupMenu(PopupMenu).MenuStyler := FCurrentOfficeTabSetStyler.CurrentAdvMenuStyler; *)
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMShowingChanged(var Message: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetPopupMenuEx: TPopupMenu;
begin
  Result := Inherited PopupMenu;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetShowNonSelectedTabs(const Value: Boolean);
begin
  FShowNonSelectedTabs := Value;
  InvalidateTab(-1);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMControlChange(var Message: TCMControlChange);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMControlListChange(
  var Message: TCMControlListChange);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMMouseEnter(var Msg: TMessage);
begin
  inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMMouseLeave(var Message: TMessage);
var
  P: TPoint;
  R: TRect;
  i: Integer;
begin
  inherited;

  {if FScrollerHoverLeftBtn or FScrollerHoverRightBtn then
  begin
    FScrollerHoverLeftBtn := false;
    FScrollerHoverRightBtn := false;
    DrawTabScrollButtons;
  end;
  }
  FHintTabIndex := -1;

  if (csDesigning in ComponentState) then
    Exit;

  // work around to avoid false call  
  GetCursorPos(P);
  P := ScreenToClient(P);
  R := GetTabsRect;
  case (TabPosition) of
    tpTop: R.Bottom := R.Bottom - 4;
    tpBottom: R.Top := R.Top + 4;
    tpLeft: R.Right := R.Right - 4;
    tpRight: R.Left := R.Left + 4;
  end;

  if PtInRect(R, P) then
    Exit;

  if (FHotTabIndex = FActiveTabIndex) then
  begin
    i := FHotTabIndex;
    FHotTabIndex := -1;
    InvalidateTab(i);
  end
  else if (FHotTabIndex >= 0) then
  begin
    if (FHotTabIndex < FAdvOfficeTabs.Count) then
    begin
      if not Assigned(FAdvOfficeTabs.Items[FHotTabIndex].FTimer) then
      begin
        FAdvOfficeTabs.Items[FHotTabIndex].FTimer := TTimer.Create(self);
        FAdvOfficeTabs.Items[FHotTabIndex].FTimer.OnTimer := FAdvOfficeTabs.Items[FHotTabIndex].TimerProc;
        FAdvOfficeTabs.Items[FHotTabIndex].FTimer.Interval := GlowSpeed;
        FAdvOfficeTabs.Items[FHotTabIndex].FTimer.Enabled := true;
      end;

      FAdvOfficeTabs.Items[FHotTabIndex].FTimeInc := -20;
      FAdvOfficeTabs.Items[FHotTabIndex].FGlowState := gsHover;
    end;
    i := FHotTabIndex;
    FHotTabIndex := -1;
    InvalidateTab(i);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  Tab, OldSelTab: Integer;
begin
  inherited;
  P := Point(X, Y);

  FDownTabIndex := -1;

  if PtInRect(GetTabsArea, p) then
  begin
    Tab := PTOnTab(X, Y);
    if (Tab >= 0) then
    begin
      if (Tab <> ActiveTabIndex) and FAdvOfficeTabs.Items[Tab].Enabled then
      begin
        // Select Tab
        OldSelTab := ActiveTabIndex;
        ChangeActiveTab(Tab);
        if not (csDesigning in ComponentState) then
        begin
          if not Assigned(FAdvOfficeTabs.Items[Tab].FTimer) then
          begin
            FAdvOfficeTabs.Items[Tab].FTimer := TTimer.Create(self);
            FAdvOfficeTabs.Items[Tab].FTimer.OnTimer := FAdvOfficeTabs.Items[Tab].TimerProc;
            FAdvOfficeTabs.Items[Tab].FTimer.Interval := GlowSpeed;
            FAdvOfficeTabs.Items[Tab].FTimer.Enabled := true;
          end;
          FAdvOfficeTabs.Items[Tab].FTimeInc := +20;
          FAdvOfficeTabs.Items[Tab].FGlowState := gsPush;
        end;
        //Invalidate;
        InvalidateTab(OldSelTab);        
      end
      else
      begin
        FDownTabIndex := Tab;
        InvalidateTab(-1);
      end;

      if FTabRearrange then
        BeginDrag(false,6);
        
    end
    else
    begin
      {if PtOnTabScrollLeftBtn(X, Y) then
      begin
        FScrollerDownLeftBtn := true;
        DrawTabScrollBtnLeft;
      end;
      if PtOnTabScrollRightBtn(X, Y) then
      begin
        FScrollerDownRightBtn := true;
        DrawTabScrollBtnRight;
      end;  }
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
  Tab: Integer;
begin
  inherited;

  if (csDesigning in ComponentState) then
    Exit;

  P := Point(X, Y);

  if PtInRect(GetTabsArea, p) then
  begin
    Tab := PTOnTab(X, Y);
    if (Tab >= 0) and (Tab <> FHotTabIndex) then
    begin
      if (FDownTabIndex >= 0) then
      begin
        FDownTabIndex := -1;
        InvalidateTab(-1);
      end;

      if (FHotTabIndex >= 0) then
      begin
        OnExitTab(FHotTabIndex);
        begin
          if (FHotTabIndex < FAdvOfficeTabs.Count) then
          begin
            if not Assigned(FAdvOfficeTabs.Items[FHotTabIndex].FTimer) then
            begin
              FAdvOfficeTabs.Items[FHotTabIndex].FTimer := TTimer.Create(self);
              FAdvOfficeTabs.Items[FHotTabIndex].FTimer.OnTimer := FAdvOfficeTabs.Items[FHotTabIndex].TimerProc;
              FAdvOfficeTabs.Items[FHotTabIndex].FTimer.Interval := GlowSpeed;
              FAdvOfficeTabs.Items[FHotTabIndex].FTimer.Enabled := true;
            end;
            FAdvOfficeTabs.Items[FHotTabIndex].FTimeInc := -20;

            FAdvOfficeTabs.Items[FHotTabIndex].FGlowState := gsHover;
          end;
          FHotTabIndex := -1;
          InvalidateTab(-1);
        end;
      end;

      // Hot Tab
      OnEnterTab(Tab);

      //InvalidateTab(-1);
      //if (Tab <> FActiveTabIndex) then
      if FAdvOfficeTabs.Items[Tab].Enabled then
      begin
        FHotTabIndex := Tab;
        FOldHotTabIndex := FHotTabIndex;
        if not Assigned(FAdvOfficeTabs.Items[FHotTabIndex].FTimer) then
        begin
          FAdvOfficeTabs.Items[FHotTabIndex].FTimer := TTimer.Create(self);
          FAdvOfficeTabs.Items[FHotTabIndex].FTimer.OnTimer := FAdvOfficeTabs.Items[FHotTabIndex].TimerProc;
          FAdvOfficeTabs.Items[FHotTabIndex].FTimer.Interval := GlowSpeed;
          FAdvOfficeTabs.Items[FHotTabIndex].FTimer.Enabled := true;
        end;

        FAdvOfficeTabs.Items[FHotTabIndex].FTimeInc := 20;
        InvalidateTab(FHotTabIndex);// Invalidate;
        FAdvOfficeTabs.Items[FHotTabIndex].FGlowState := gsHover;
      end;

      if (FHintTabIndex <> Tab) then
      begin
        FHintTabIndex := Tab;
        Application.CancelHint;
      end;
    end
    else if (Tab < 0) and (FHotTabIndex >= 0) then
    begin
      if (FDownTabIndex >= 0) then
      begin
        FDownTabIndex := -1;
        InvalidateTab(-1);
      end;
      OnExitTab(FHotTabIndex);
      if (FHotTabIndex = FActiveTabIndex) and false then
      begin
        FHotTabIndex := -1;
        Invalidate;
      end
      else
      begin
        if (FHotTabIndex < FAdvOfficeTabs.Count) then
        begin
          if not Assigned(FAdvOfficeTabs.Items[FHotTabIndex].FTimer) then
          begin
            FAdvOfficeTabs.Items[FHotTabIndex].FTimer := TTimer.Create(self);
            FAdvOfficeTabs.Items[FHotTabIndex].FTimer.OnTimer := FAdvOfficeTabs.Items[FHotTabIndex].TimerProc;
            FAdvOfficeTabs.Items[FHotTabIndex].FTimer.Interval := GlowSpeed;
            FAdvOfficeTabs.Items[FHotTabIndex].FTimer.Enabled := true;
          end;
          FAdvOfficeTabs.Items[FHotTabIndex].FTimeInc := -20;

          FAdvOfficeTabs.Items[FHotTabIndex].FGlowState := gsHover;
        end;
        FHotTabIndex := -1;
        InvalidateTab(-1);
      end;
    end;

    if (Tab < 0) then
    begin
      FHintTabIndex := -1;
      Application.CancelHint;
    end;

    {// Checking for TabScrollButtons
    if PtOnTabScrollLeftBtn(X, Y) then
    begin
      if not FScrollerHoverLeftBtn then
      begin
        FScrollerHoverLeftBtn := true;
        DrawTabScrollBtnLeft;
      end;
    end
    else if FScrollerHoverLeftBtn then
    begin
      FScrollerHoverLeftBtn := false;
      DrawTabScrollBtnLeft;
    end;

    if PtOnTabScrollRightBtn(X, Y) then
    begin
      if not FScrollerHoverRightBtn then
      begin
        FScrollerHoverRightBtn := true;
        DrawTabScrollBtnRight;
      end;
    end
    else if FScrollerHoverRightBtn then
    begin
      FScrollerHoverRightBtn := false;
      DrawTabScrollBtnRight;
    end;
    }
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  P: TPoint;
begin
  inherited;
  P := Point(X, Y);

  if (FDownTabIndex >= 0) then
  begin
    FDownTabIndex := -1;
    InvalidateTab(-1);
  end;

  if PtInRect(GetTabsArea, p) then
  begin
    {if PtOnTabScrollLeftBtn(X, Y) then
    begin
      FScrollerDownLeftBtn := false;
      DrawTabScrollBtnLeft;
      ScrollLeftBtnClick;
    end
    else if PtOnTabScrollRightBtn(X, Y) then
    begin
      FScrollerDownRightBtn := false;
      DrawTabScrollBtnRight;
      ScrollRightBtnClick;
    end; }
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.FindNextTab(TabIndex: Integer; GoForward,
  CheckTabVisible: Boolean): Integer;
var
  i, j: Integer;
begin
  Result := -1;
  if (TabIndex >= 0) and (TabIndex < FAdvOfficeTabs.Count) then
    Exit;
    
  if GoForward then
  begin
    i := TabIndex;
    j := 1;
    while (j < FAdvOfficeTabs.Count) do
    begin
      Inc(i);    
      if (i >= FAdvOfficeTabs.Count) then
        i := 0;
      if (CheckTabVisible and FAdvOfficeTabs.Items[i].Visible) or not CheckTabVisible then
      begin
        Result := i;
        Break;
      end;
      Inc(j);
    end;
  end
  else  // BackWard
  begin
    i := TabIndex;
    j := 1;
    while (j < FAdvOfficeTabs.Count) do
    begin
      dec(i);
      if (i >= FAdvOfficeTabs.Count) then
        i := 0;
      if (i < 0) then
        i := FAdvOfficeTabs.Count-1;
      if (CheckTabVisible and FAdvOfficeTabs.Items[i].Visible) or not CheckTabVisible then
      begin
        Result := i;
        Break;
      end;
      Inc(j);
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetActiveTabIndex: Integer;
begin
  Result := FActiveTabIndex;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SelectNextTab(GoForward: Boolean);
var
  i, j: Integer;
begin
  if (ActiveTabIndex < 0) then
    Exit;

  if GoForward then
  begin
    i := ActiveTabIndex;
    j := 1;
    while (j < FAdvOfficeTabs.Count) do
    begin
      Inc(i);
      if (i >= FAdvOfficeTabs.Count) then
        i := 0;
      if (ActiveTabIndex <> i) and FAdvOfficeTabs.Items[i].Visible and FAdvOfficeTabs.Items[i].Enabled then
      begin
        ActiveTabIndex := i;
        Break;
      end;
      Inc(j);
    end;
  end
  else  // BackWard
  begin
    i := ActiveTabIndex;
    j := 1;
    while (j < FAdvOfficeTabs.Count) do
    begin
      dec(i);
      if (i >= FAdvOfficeTabs.Count) then
        i := 0;
      if (i < 0) then
        i := FAdvOfficeTabs.Count-1;
      if (ActiveTabIndex <> i) and FAdvOfficeTabs.Items[i].Visible and FAdvOfficeTabs.Items[i].Enabled then
      begin
        ActiveTabIndex := i;
        Break;
      end;
      Inc(j);
    end;
  end;
end;

//------------------------------------------------------------------------------
{
function TAdvCustomOfficeTabSet.IndexOfPage(AdvPage: TAdvOfficePage): Integer;
begin
  Result := FAdvOfficeTabs.IndexOf(AdvPage);
end;
}

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.ChangeActiveTab(TabIndex: Integer);
var
  aForm: TCustomForm;
  AllowChange: Boolean;
begin
  if (TabIndex >= 0) and (TabIndex < FAdvOfficeTabs.Count) and (TabIndex <> ActiveTabIndex) then
  begin
    AllowChange := True;
    if Assigned(FOnChanging) then
      FOnChanging(Self, ActiveTabIndex, TabIndex, AllowChange);

    if not AllowChange then
      Exit;


    FActiveTabIndex := TabIndex;

    if Assigned(FOnChange) then
      FOnChange(Self);

    if (csDesigning in ComponentState) and not (csLoading in ComponentState) then
    begin
      aForm := GetParentForm(Self);
      if (aForm <> nil) and (aForm.Designer <> nil) then
        aForm.Designer.Modified;
    end;

    InitializeAndUpdateButtons;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetActiveTabIndex(const Value: Integer);
var
  R: TRect;
  i, j: Integer;
begin
  R := GetTabRect(Value);

  if (R.Left = -1) and (Value >= 0) and (Value < FAdvOfficeTabs.Count) then // force activated tab to be visible
  begin
    //FTabScroller.Position := Value;
    j := 0;
    for i:= 0 to Value - 1 do
    begin
      if FAdvOfficeTabs.Items[i].Visible then
        inc(j);
    end;

    FTabScroller.Position := Min(j, FTabScroller.Max);
  end;

  ChangeActiveTab(Value);
  R := GetTabsArea;
  InvalidateRect(Handle, @R, True);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetTabSettings(const Value: TTabSetTabSettings);
begin
  FTabSettings.Assign(Value);
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.PTOnTab(X, Y: Integer): Integer;
var
  i: Integer;
  P: TPoint;
  TabR: TRect;
begin
  Result := -1;
  P := Point(X, Y);
  for i:= 0 to FAdvOfficeTabs.Count-1 do
  begin
    TabR := GetTabRect(i);
    if PtInRect(TabR, P) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetButtonsRect: TRect;
var
  Spc: Integer;
begin
  Result := ClientRect;
  Spc := 3;
  case TabPosition of
    tpTop:
    begin
      Result.Top := Result.Top + FTabOffSet;
      Result.Bottom := Result.Top + FTabSettings.Height;
      Result.Right := Result.Right - FTabSettings.EndMargin - ADVPAGE_OFFSET - 3;
      Result.Left := Result.Right-3;
      if FTabScroller.Visible then
        Result.Left := Result.Left -(TabBUTTON_SIZE * 2 + 2 + 3);
      if (ButtonSettings.TabListButton) then
        Result.Left := Result.Left - TabBUTTON_SIZE - Spc;
      if (ButtonSettings.CloseButton and not CloseOnTab) then
        Result.Left := Result.Left - TabBUTTON_SIZE - Spc;
    end;
    tpBottom:
    begin
      Result.Top := Result.Bottom - FTabSettings.Height - FTabOffSet;
      Result.Bottom := Result.Bottom - FTabOffSet;
      Result.Right := Result.Right - FTabSettings.EndMargin - ADVPAGE_OFFSET-3;
      Result.Left := Result.Right -3;
      if FTabScroller.Visible then
        Result.Left := Result.Left -(TabBUTTON_SIZE*2 + 2 + 3);
      if (ButtonSettings.TabListButton) then
        Result.Left := Result.Left - TabBUTTON_SIZE - Spc;
      if (ButtonSettings.CloseButton and not CloseOnTab) then
        Result.Left := Result.Left - TabBUTTON_SIZE - Spc;
    end;
    tpLeft:
    begin
      Result.Bottom := Result.Bottom - FTabSettings.EndMargin - ADVPAGE_OFFSET-3;
      Result.Top := Result.Bottom -3;
      Result.Left := Result.Left + FTabOffSet;
      Result.Right := Result.Left + FTabSettings.Height;
      if FTabScroller.Visible then
        Result.Top := Result.Top -(TabBUTTON_SIZE * 2 + 2 + 3);
      if (ButtonSettings.TabListButton) then
        Result.Top := Result.Top - TabBUTTON_SIZE - Spc;
      if (ButtonSettings.CloseButton and not CloseOnTab) then
        Result.Top := Result.Top - TabBUTTON_SIZE - Spc;

      if not RotateTabLeftRight then
        Result.Left := Result.Right - 5 - TabBUTTON_SIZE - 3;
    end;
    tpRight:
    begin
      Result.Bottom := Result.Bottom - FTabSettings.EndMargin - ADVPAGE_OFFSET-3;
      Result.Top := Result.Bottom -3;
      Result.Left := Result.Right - TabSettings.Height - FTabOffSet;
      Result.Right := Result.Right - FTabOffSet;
      if FTabScroller.Visible then
        Result.Top := Result.Top -(TabBUTTON_SIZE*2 + 2 + 3);
      if (ButtonSettings.TabListButton) then
        Result.Top := Result.Top - TabBUTTON_SIZE - Spc;
      if (ButtonSettings.CloseButton and not CloseOnTab) then
        Result.Top := Result.Top - TabBUTTON_SIZE - Spc;

      if not RotateTabLeftRight then
        Result.Right := Result.Left + 5 + TabBUTTON_SIZE + 3;
    end;
  end;
end;

//------------------------------------------------------------------------------

// Independent to Start/End Margins and Scroller
function TAdvCustomOfficeTabSet.GetTabsArea: TRect;
begin
  Result := ClientRect;
  case TabPosition of
    tpTop: Result.Bottom := Result.Top + FTabSettings.Height;
    tpBottom: Result.Top := Result.Bottom - FTabSettings.Height;
    tpLeft: Result.Right := Result.Left + FTabSettings.Height;
    tpRight: Result.Left := Result.Right - FTabSettings.Height;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetTabsRect: TRect;
begin
  Result := ClientRect;
  case TabPosition of
    tpTop:
    begin
      Result.Top := Result.Top + FTabOffSet;
      Result.Bottom := Result.Top + FTabSettings.Height;
      Result.Left := Result.Left + FTabSettings.StartMargin;
      Result.Right := GetButtonsRect.Left; //Result.Right - FTabSettings.EndMargin;
    end;
    tpBottom:
    begin
      Result.Top := Result.Bottom - FTabSettings.Height - FTabOffSet;
      Result.Bottom := Result.Bottom - FTabOffSet;
      Result.Left := Result.Left + FTabSettings.StartMargin;
      Result.Right := GetButtonsRect.Left; //Result.Right - FTabSettings.EndMargin;
    end;
    tpLeft:
    begin
      Result.Top := Result.Top + FTabSettings.StartMargin;
      Result.Bottom := GetButtonsRect.Top; // Result.Bottom - FTabSettings.EndMargin;
      Result.Left := Result.Left + FTabOffSet;
      Result.Right := Result.Left + FTabSettings.Height;
    end;
    tpRight:
    begin
      Result.Top := Result.Top + FTabSettings.StartMargin;
      Result.Bottom := GetButtonsRect.Top; //Result.Bottom - FTabSettings.EndMargin;
      Result.Left := Result.Right - TabSettings.Height - FTabOffSet;
      Result.Right := Result.Right - FTabOffSet;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetTabRect(TabIndex: Integer): TRect;
begin
  Result := GetTabRect(0, TabIndex, True);
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetTabRect(StartIndex, TabIndex: Integer; ConsiderTabScroller: Boolean): TRect;
var
  i, TbW, TbH, j, Sp, fdW, ImgTxtSp: Integer;
  R, CR, R2: TRect;
  TabAppearance: TCustomTabAppearance;
  Pic: TGDIPPicture;
begin
  Result := Rect(-1, -1, -1, -1);
  Sp := FTabSettings.Spacing; //0;
  fdW := 5;
  ImgTxtSp := IMG_SPACE;

  if (TabIndex >= 0) and (TabIndex < FAdvOfficeTabs.Count) then
  begin
    if not FAdvOfficeTabs.Items[TabIndex].Visible then
      Exit;

    CR := GetTabsRect; // ClientRect;
    //if Align in [daTop, daBottom] then
    begin
      j := 0;
      for i:= StartIndex to TabIndex do
      begin
        if not FAdvOfficeTabs.Items[i].Visible then
          Continue;

        TabAppearance := FCurrentOfficeTabSetStyler.TabAppearance;

        Canvas.Font.Assign(TabAppearance.Font);

        if (TabPosition in [tpTop, tpBottom]) then
        begin
          if FUseMaxSpace then
            CR.Right := GetTabsArea.Right;
            
          if (FAdvOfficeTabs.Items[i].Caption <> '') then
          begin
            R2 := Rect(0,0, 1000, 100);
            DrawText(Canvas.Handle,PChar(FAdvOfficeTabs.Items[i].Caption),Length(FAdvOfficeTabs.Items[i].Caption), R2, DT_CALCRECT or DT_LEFT or DT_SINGlELINE);
          end
          else
            R2 := Rect(0, 0, 0, 0);
          //R2 := DrawVistaText(Canvas, R2, FAdvOfficeTabs.Items[i].Caption, Canvas.Font, FAdvOfficeTabs.Items[PageIndex].Enabled, False);
          TbW := TabSettings.LeftMargin + R2.Right+ fdW + TabSettings.RightMargin;

          if FAdvOfficeTabs.Items[i].Enabled or FAdvOfficeTabs.Items[i].DisabledPicture.Empty then
            Pic := FAdvOfficeTabs.Items[i].Picture
          else
            Pic := FAdvOfficeTabs.Items[i].DisabledPicture;

          if Assigned(Pic) and not Pic.Empty then
          begin
            Pic.GetImageSizes;
            TbW := TbW + Pic.Width + ImgTxtSp;
          end
          else
          if (Assigned(FImages) or Assigned(DisabledImages)) and (FAdvOfficeTabs.Items[i].ImageIndex >= 0) then
          begin
            if FAdvOfficeTabs.Items[i].Enabled then
            begin
              if Assigned(FImages) then
                TbW := TbW + FImages.Width + ImgTxtSp;
            end
            else
            begin
              if Assigned(FDisabledImages) then
                TbW := TbW + FDisabledImages.Width + ImgTxtSp
              else if Assigned(FImages) then
                TbW := TbW + FImages.Width + ImgTxtSp;
            end;
          end;

          if (ButtonSettings.CloseButton and CloseOnTab) then
            TbW := Tbw + TabBUTTON_SIZE + 4;

          if ((CR.Left + TbW) > (CR.Right - ADVPAGE_OFFSET)) and (not ConsiderTabScroller or (FTabScroller.Visible and(i = TabIndex) and (FTabScroller.Position <> TabIndex))) then
            Break;

          if FTabScroller.Visible and ConsiderTabScroller then
          begin
            if (j >= FTabScroller.Position) then
            begin
              R := Rect(CR.Left, CR.Top, CR.Left + TbW, CR.Bottom);
              if (i = TabIndex) then
                Result := R;
              CR.Left := CR.Left + TbW + Sp;
            end;
          end
          else
          begin
            R := Rect(CR.Left, CR.Top, CR.Left + TbW, CR.Bottom);
            if (i = TabIndex) then
              Result := R;
            CR.Left := CR.Left + TbW + Sp;
          end;
        end
        else // TabPosition in [tpLeft, tpRight]
        begin
          if FUseMaxSpace then
            CR.Bottom := GetTabsArea.Bottom;

          if (FAdvOfficeTabs.Items[i].Caption <> '') then
          begin
            R2 := Rect(0,0, 1000, 100);
            DrawText(Canvas.Handle,PChar(FAdvOfficeTabs.Items[i].Caption),Length(FAdvOfficeTabs.Items[i].Caption), R2, DT_CALCRECT or DT_LEFT or DT_SINGlELINE);
          end
          else
            R2 := Rect(0, 0, 0, 0);
          //R2 := DrawVistaText(Canvas, R2, FAdvOfficeTabs.Items[i].Caption, Canvas.Font, FAdvOfficeTabs.Items[PageIndex].Enabled, False);
          TbW := TabSettings.LeftMargin + R2.Right+ fdW + TabSettings.RightMargin;
          TbH := R2.Bottom;

          if FAdvOfficeTabs.Items[i].Enabled or FAdvOfficeTabs.Items[i].DisabledPicture.Empty then
            Pic := FAdvOfficeTabs.Items[i].Picture
          else
            Pic := FAdvOfficeTabs.Items[i].DisabledPicture;

          if Assigned(Pic) and not Pic.Empty then
          begin
            Pic.GetImageSizes;
            TbW := TbW + Pic.Height + ImgTxtSp;
            TbH := Max(TbH, Pic.Height);
          end
          else
          if (Assigned(FImages) or Assigned(DisabledImages)) and (FAdvOfficeTabs.Items[i].ImageIndex >= 0) then
          begin
            if FAdvOfficeTabs.Items[i].Enabled then
            begin
              if Assigned(FImages) then
              begin
                TbW := TbW + FImages.Height + ImgTxtSp;
                TbH := Max(TbH, FImages.Height);
              end;  
            end
            else
            begin
              if Assigned(FDisabledImages) then
              begin
                TbW := TbW + FDisabledImages.Height + ImgTxtSp;
                TbH := Max(TbH, FDisabledImages.Height);
              end
              else if Assigned(FImages) then
              begin
                TbW := TbW + FImages.Height + ImgTxtSp;
                TbH := Max(TbH, FImages.Height);
              end;
            end;
          end;

          TbH := TbH + 12; //TabSettings.RightMargin;

          if not RotateTabLeftRight then
          begin
            if ((CR.Top + TbH) > (CR.Bottom - ADVPAGE_OFFSET)) and (not ConsiderTabScroller or (FTabScroller.Visible and(i = TabIndex) and (FTabScroller.Position <> TabIndex))) then
              Break;

            if FTabScroller.Visible and ConsiderTabScroller then
            begin
              if (j >= FTabScroller.Position) then
              begin
                R := Rect(CR.Left, CR.Top, CR.Right, CR.Top + TbH);
                if (i = TabIndex) then
                  Result := R;
                CR.Top := CR.Top + TbH + Sp;
              end;
            end
            else
            begin
              R := Rect(CR.Left, CR.Top, CR.Right, CR.Top + TbH);
              if (i = TabIndex) then
                Result := R;
              CR.Top := CR.Top + TbH + Sp;
            end;
          end
          else
          begin
            if (ButtonSettings.CloseButton and CloseOnTab) then
              TbW := Tbw + TabBUTTON_SIZE + 4;

            if ((CR.Top + TbW) > (CR.Bottom - ADVPAGE_OFFSET)) and (not ConsiderTabScroller or (FTabScroller.Visible and(i = TabIndex) and (FTabScroller.Position <> TabIndex))) then
              Break;

            if FTabScroller.Visible and ConsiderTabScroller then
            begin
              if (j >= FTabScroller.Position) then
              begin
                R := Rect(CR.Left, CR.Top, CR.Right, CR.Top + TbW);
                if (i = TabIndex) then
                  Result := R;
                CR.Top := CR.Top + TbW + Sp;
              end;
            end
            else
            begin
              R := Rect(CR.Left, CR.Top, CR.Right, CR.Top + TbW);
              if (i = TabIndex) then
                Result := R;
              CR.Top := CR.Top + TbW + Sp;
            end;
          end;
        end;
        Inc(j);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMDesignHitTest(var Msg: TCMDesignHitTest);
var
  p: TPoint;
  Tab: Integer;
begin
  Tab := -1;
  if (csDesigning in ComponentState) then
  begin
    GetCursorPos(P);
    P := ScreenToClient(P);

    if PtInRect(GetTabsRect, p) and (GetAsyncKeyState(VK_LBUTTON) <> 0) then
    begin
      Tab := PTOnTab(P.X, P.Y);
      if (Tab >= 0) then
      begin
        Msg.Result := 1;
      end;
    end;

  end;

  if (Tab = -1) then
    inherited;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetImages(const Value: TCustomImageList);
begin
  FImages := Value;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.InvalidateTab(TabIndex: Integer);
var
  R, CloseBtnR: TRect;
  rgn1, rgn2: HRGN;
begin
  if (TabIndex >= 0) and (TabIndex < FAdvOfficeTabs.Count) then
  begin
    R := GetTabRect(TabIndex);
    if (TabIndex = ActiveTabIndex) and (ActiveTabIndex >= 0) and CloseOnTab then
    begin
      CloseBtnR := GetCloseButtonRect;
      if (TabPosition in [tpTop, tpBottom]) or not RotateTabLeftRight then
      begin
        rgn1 := CreateRectRgn(R.Left, R.Top, CloseBtnR.Left, R.Bottom);
        rgn2 := CreateRectRgn(CloseBtnR.Left, R.Top, CloseBtnR.Right, CloseBtnR.Top);
        CombineRgn(rgn1, rgn1, rgn2, RGN_OR);
        DeleteObject(rgn2);
        rgn2 := CreateRectRgn(CloseBtnR.Left, CloseBtnR.Bottom, CloseBtnR.Right, R.Bottom);
        CombineRgn(rgn1, rgn1, rgn2, RGN_OR);
        DeleteObject(rgn2);

        rgn2 := CreateRectRgn(CloseBtnR.Right, R.Top, R.Right, R.Bottom);
        CombineRgn(rgn1, rgn1, rgn2, RGN_OR);
        InvalidateRgn(Handle, Rgn1, True);
        DeleteObject(rgn2);
        DeleteObject(rgn1);
      end
      else if (TabPosition in [tpLeft, tpRight]) then
      begin
        rgn1 := CreateRectRgn(R.Left, R.Top, R.Right, CloseBtnR.Top);
        rgn2 := CreateRectRgn(R.Left, R.Top, CloseBtnR.Left, CloseBtnR.Bottom);
        CombineRgn(rgn1, rgn1, rgn2, RGN_OR);
        DeleteObject(rgn2);
        rgn2 := CreateRectRgn(CloseBtnR.Right, R.Top, R.Right, CloseBtnR.Bottom);
        CombineRgn(rgn1, rgn1, rgn2, RGN_OR);
        DeleteObject(rgn2);

        rgn2 := CreateRectRgn(R.Left, CloseBtnR.Bottom, R.Right, R.Bottom);
        CombineRgn(rgn1, rgn1, rgn2, RGN_OR);
        InvalidateRgn(Handle, Rgn1, True);
        DeleteObject(rgn2);
        DeleteObject(rgn1);
      end;
    end
    else
      InvalidateRect(Handle, @R, True);
  end
  else
  begin
    R := GetTabsRect; //Area;
    InvalidateRect(Handle, @R, True);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnEnterTab(TabIndex: Integer);
begin

end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnExitTab(TabIndex: Integer);
begin

end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetDisabledImages(
  const Value: TCustomImageList);
begin
  FDisabledImages := Value;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.UpdateTabScroller;
var
  AnyTabVisible: Boolean;
  i, j: Integer;
  
  function GetScrollMax: Integer;
  var
    i, j, LastVisTab: Integer;
    R: TRect;
  begin
    Result := 0;
    LastVisTab := 0;
    for i:= FAdvOfficeTabs.Count -1 downto 0 do
    begin
      if FAdvOfficeTabs.Items[i].Visible then
      begin
        LastVisTab := i;
        Break;
      end;
    end;

    if (LastVisTab <= 0) then
      Exit;

    i := 0;
    j := 0;
    while (i < FAdvOfficeTabs.Count) do
    begin
      R := GetTabRect(i, LastVisTab, False);
      if (R.Left > -1) and (R.Right > -1) then
      begin
        Result := j; //i;
        AnyTabVisible := True;
        Break;
      end;
      inc(i);
      if (i >= FAdvOfficeTabs.Count) then
        Break;

      if FAdvOfficeTabs.Items[i].Visible then
        inc(j);
      FTabScroller.Visible := True;  // just to be counted in calculation
    end;
  end;

begin
  AnyTabVisible := False;
  FUseMaxSpace := False;
  FTabScroller.Visible := False;
  FTabScroller.Min := 0;
  FTabScroller.Max := GetScrollMax;
  if (FTabScroller.Max = 0) and not AnyTabVisible then
  begin
    FUseMaxSpace := True;
    FTabScroller.Max := GetScrollMax;
    if (FTabScroller.Max = 0) then
    begin
      //FUseMaxSpace := False;
      FTabScroller.Max := max(0, GetVisibleTabCount-1);
    end;
  end
  else
  if (AnyTabVisible) then
  begin
    if (FTabScroller.Position > FTabScroller.Max) then
      FTabScroller.Position := FTabScroller.Max;

    j := 0;
    for i:= 0 to FAdvOfficeTabs.Count -1 do
    begin
      if FAdvOfficeTabs.Items[i].Visible then
      begin
        inc(j);
        if (j >= FTabScroller.Position) then
          Break;
      end;
    end;

    if (GetTabRect(j).Right = -1) then
    begin
      FUseMaxSpace := True;
      FTabScroller.Max := GetScrollMax;
      if (FTabScroller.Max = 0) then
        FUseMaxSpace := False;
    end;
  end;
  FTabScroller.Visible := FTabScroller.Min < FTabScroller.Max;
  if (FTabScroller.Position > FTabScroller.Max) then
    FTabScroller.Position := FTabScroller.Max;

  InitializeAndUpdateButtons;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.PtOnTabScrollLeftBtn(X, Y: integer): Boolean;
var
  P: TPoint;
begin
  P := Point(X, Y);
  Result := PtInRect(GetTabScrollerLeftRect, P);
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.PtOnTabScrollRightBtn(X, Y: integer): Boolean;
var
  P: TPoint;
begin
  P := Point(X, Y);
  Result := PtInRect(GetTabScrollerRightRect, P);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.DrawTabScrollButtons;
var
  R: TRect;
begin
  if (FTabScroller.Visible or (ButtonSettings.CloseButton and not CloseOnTab) or ButtonSettings.TabListButton)
    and (FCurrentOfficeTabSetStyler.ButtonBorderColor <> clNone) then
  begin
    R := GetButtonsRect;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := FCurrentOfficeTabSetStyler.ButtonBorderColor;
    Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 5, 5);
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.ScrollLeftBtnClick;
begin
  if FTabScroller.Visible then
  begin
    if FTabScroller.CanGoBack then
    begin
      FTabScroller.Position := FTabScroller.Position - 1;
      if not FUseMaxSpace then
        InvalidateTab(-1)
      else
        Invalidate;  
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.ScrollRightBtnClick;
begin
  if FTabScroller.Visible then
  begin
    if FTabScroller.CanGoForward then
    begin
      FTabScroller.Position := FTabScroller.Position + 1;
      if not FUseMaxSpace then
        InvalidateTab(-1)
      else
        Invalidate;  
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetTabScrollerLeftRect: TRect;
begin
  Result := Rect(-1, -1, -1, -1);
  if FTabScroller.Visible then
  begin
    Result := GetTabScrollerRect;
    case TabPosition of
      tpTop, tpBottom:
      begin
        Result.Left := Result.Left + 3;
        Result.Right := Result.Left + TabBUTTON_SIZE; // (Result.Right - Result.Left) div 2 - 1;
      end;
      tpLeft, tpRight:
      begin
        //Result.Bottom := Result.Top + (Result.Bottom - Result.Top) div 2 - 1;
        Result.Top := Result.Top + 3;
        Result.Bottom := Result.Top + TabBUTTON_SIZE;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetCloseButtonRect: TRect;
var
  i: Integer;
begin
  Result := Rect(-1, -1, -1, -1);
  if ButtonSettings.CloseButton then
  begin
    if CloseOnTab then
    begin
      if (ActiveTabIndex >= 0) then
      begin
        case TabPosition of
          tpTop:
          begin
            Result := GetTabRect(ActiveTabIndex);
            Result.Left := Result.Right - TabBUTTON_SIZE - 4;
            Result.Right := Result.Left + TabBUTTON_SIZE;
            Result.Bottom := Result.Bottom - 5;
            Result.Top := Result.Bottom - TabBUTTON_SIZE;
          end;
          tpBottom:
          begin
            Result := GetTabRect(ActiveTabIndex);
            Result.Left := Result.Right - TabBUTTON_SIZE - 4;
            Result.Right := Result.Left + TabBUTTON_SIZE;
            Result.Top := Result.Top + 5;
            Result.Bottom := Result.Top + TabBUTTON_SIZE;
          end;
          tpLeft:
          begin
            if RotateTabLeftRight then
            begin
              Result := GetTabRect(ActiveTabIndex);
              Result.Right := Result.Right - 5;
              Result.Left := Result.Right - TabBUTTON_SIZE;
              Result.Top := Result.Top + 4;
              Result.Bottom := Result.Top + TabBUTTON_SIZE;
            end
            else
            begin
              Result := GetTabRect(ActiveTabIndex);
              i := (Result.Bottom - Result.Top - TabBUTTON_SIZE) div 2;
              Result.Left := Result.Right - TabBUTTON_SIZE - 5;
              Result.Right := Result.Left + TabBUTTON_SIZE;
              Result.Top := Result.Top + i;
              Result.Bottom := Result.Top + TabBUTTON_SIZE;
            end;
          end;
          tpRight:
          begin
            if RotateTabLeftRight then
            begin
              Result := GetTabRect(ActiveTabIndex);
              Result.Left := Result.Left + 5;
              Result.Right := Result.Left + TabBUTTON_SIZE;
              Result.Bottom := Result.Bottom - 4;
              Result.Top := Result.Bottom - TabBUTTON_SIZE;
            end
            else
            begin
              Result := GetTabRect(ActiveTabIndex);
              i := (Result.Bottom - Result.Top - TabBUTTON_SIZE) div 2;
              Result.Left := Result.Right - TabBUTTON_SIZE - 3;
              Result.Right := Result.Left + TabBUTTON_SIZE;
              Result.Top := Result.Top + i;
              Result.Bottom := Result.Top + TabBUTTON_SIZE;
            end;
          end;
        end;
      end;
    end
    else
    begin
      case TabPosition of
        tpTop:
        begin
          if ButtonSettings.TabListButton then
          begin
            Result := GetTabListRect;
            Result.Left := Result.Right + 2;
            Result.Right := Result.Left + TabBUTTON_SIZE;
          end
          else if FTabScroller.Visible then
          begin
            Result := GetTabScrollerRightRect;
            Result.Left := Result.Right + 3;
            Result.Right := Result.Left + TabBUTTON_SIZE;
          end
          else
          begin
            Result := GetButtonsRect; // GetTabsRect;
            Result.Left := Result.Left + 3;
            Result.Right := Result.Left + TabBUTTON_SIZE;
            Result.Bottom := Result.Bottom - 5;
            Result.Top := Result.Bottom - TabBUTTON_SIZE;
          end;
        end;
        tpBottom:
        begin
          if ButtonSettings.TabListButton then
          begin
            Result := GetTabListRect;
            Result.Left := Result.Right + 2;
            Result.Right := Result.Left + TabBUTTON_SIZE;
          end
          else if FTabScroller.Visible then
          begin
            Result := GetTabScrollerRightRect;
            Result.Left := Result.Right + 3;
            Result.Right := Result.Left + TabBUTTON_SIZE;
          end
          else
          begin
            Result := GetButtonsRect; // GetTabsRect;
            Result.Left := Result.Left + 3;
            Result.Right := Result.Left + TabBUTTON_SIZE;
            Result.Top := Result.Top + 5;
            Result.Bottom := Result.Top + TabBUTTON_SIZE;
          end;
        end;
        tpLeft:
        begin
          if ButtonSettings.TabListButton then
          begin
            Result := GetTabListRect;
            Result.Top := Result.Bottom + 2;
            Result.Bottom := Result.Top + TabBUTTON_SIZE;
          end
          else if FTabScroller.Visible then
          begin
            Result := GetTabScrollerRightRect;
            Result.Top := Result.Bottom + 3;
            Result.Bottom := Result.Top + TabBUTTON_SIZE;
          end
          else
          begin
            Result := GetButtonsRect; // GetTabsRect;
            Result.Top := Result.Top + 3;
            Result.Bottom := Result.Top + TabBUTTON_SIZE;
            Result.Right := Result.Right - 5;
            Result.Left := Result.Right - TabBUTTON_SIZE;
          end;
        end;
        tpRight:
        begin
          if ButtonSettings.TabListButton then
          begin
            Result := GetTabListRect;
            Result.Top := Result.Bottom + 2;
            Result.Bottom := Result.Top + TabBUTTON_SIZE;
          end
          else if FTabScroller.Visible then
          begin
            Result := GetTabScrollerRightRect;
            Result.Top := Result.Bottom + 3;
            Result.Bottom := Result.Top + TabBUTTON_SIZE;
          end
          else
          begin
            Result := GetButtonsRect; // GetTabsRect;
            Result.Top := Result.Top + 3;
            Result.Bottom := Result.Top + TabBUTTON_SIZE;
            Result.Left := Result.Left + 5;
            Result.Right := Result.Left + TabBUTTON_SIZE;
          end;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetTabListRect: TRect;
begin
  Result := Rect(-1, -1, -1, -1);
  if ButtonSettings.TabListButton then
  begin
    case TabPosition of
      tpTop:
      begin
        if FTabScroller.Visible then
        begin
          Result := GetTabScrollerRightRect; // GetTabScrollerRect;
          Result.Left := Result.Right + 3;
          Result.Right := Result.Left + TabBUTTON_SIZE;
        end
        else
        begin
          Result := GetButtonsRect; // GetTabsRect;
          Result.Left := Result.Left + 3;
          Result.Right := Result.Left + TabBUTTON_SIZE;
          Result.Bottom := Result.Bottom - 5;
          Result.Top := Result.Bottom - TabBUTTON_SIZE;
        end;
      end;
      tpBottom:
      begin
        if FTabScroller.Visible then
        begin
          Result := GetTabScrollerRightRect;
          Result.Left := Result.Right + 3;
          Result.Right := Result.Left + TabBUTTON_SIZE;
        end
        else
        begin
          Result := GetButtonsRect;
          Result.Left := Result.Left + 3;
          Result.Right := Result.Left + TabBUTTON_SIZE;
          Result.Top := Result.Top + 5;
          Result.Bottom := Result.Top + TabBUTTON_SIZE;
        end;
      end;
      tpLeft:
      begin
        if FTabScroller.Visible then
        begin
          Result := GetTabScrollerRightRect;
          Result.Top := Result.Bottom + 3;
          Result.Bottom := Result.Top + TabBUTTON_SIZE;
        end
        else
        begin
          Result := GetButtonsRect;
          Result.Top := Result.Top + 3;
          Result.Bottom := Result.Top + TabBUTTON_SIZE;
          Result.Right := Result.Right - 5;
          Result.Left := Result.Right - TabBUTTON_SIZE;
        end;
      end;
      tpRight:
      begin
        if FTabScroller.Visible then
        begin
          Result := GetTabScrollerRightRect;
          Result.Top := Result.Bottom + 3;
          Result.Bottom := Result.Top + TabBUTTON_SIZE;
        end
        else
        begin
          Result := GetButtonsRect;
          Result.Top := Result.Top + 3;
          Result.Bottom := Result.Top + TabBUTTON_SIZE;
          Result.Left := Result.Left + 5;
          Result.Right := Result.Left + TabBUTTON_SIZE;
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetTabScrollerRect: TRect;
begin
  Result := Rect(-1, -1, -1, -1);
  if FTabScroller.Visible then
  begin
    Result := GetButtonsRect;
    case TabPosition of
      tpTop:
      begin
        Result.Right := Result.Left + 3 +(TabBUTTON_SIZE*2 + 2+ 3);// SCROLLER_SIZE;
        Result.Bottom := Result.Bottom - 5;
        Result.Top := Result.Bottom - TabBUTTON_SIZE;
      end;
      tpBottom:
      begin
        Result.Right := Result.Left + 3 +(TabBUTTON_SIZE*2 + 2+ 3);// SCROLLER_SIZE;
        Result.Top := Result.Top + 5;
        Result.Bottom := Result.Top + TabBUTTON_SIZE;
      end;
      tpLeft:
      begin
        Result.Bottom := Result.Top + 3 +(TabBUTTON_SIZE*2 + 2+ 3);
        Result.Right := Result.Right - 5;
        Result.Left := Result.Right - TabBUTTON_SIZE;
      end;
      tpRight:
      begin
        Result.Bottom := Result.Top + 3 +(TabBUTTON_SIZE*2 + 2+ 3);
        Result.Left := Result.Left + 5;
        Result.Right := Result.Left + TabBUTTON_SIZE;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetTabScrollerRightRect: TRect;
begin
  Result := Rect(-1, -1, -1, -1);
  if FTabScroller.Visible then
  begin
    Result := GetTabScrollerLeftRect;// GetTabScrollerRect;
    case TabPosition of
      tpTop, tpBottom:
      begin
        Result.Left := Result.Right + 2;
        Result.Right := Result.Left + TabBUTTON_SIZE; // ((Result.Right - Result.Left) div 2);
      end;
      tpLeft, tpRight:
      begin
        //Result.Top := Result.Top + ((Result.Bottom - Result.Top) div 2);
        Result.Top := Result.Bottom + 2;
        Result.Bottom := Result.Top + TabBUTTON_SIZE;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMHintShow(var Message: TMessage);
var
  PHI: PHintInfo;
begin
  PHI := TCMHintShow(Message).HintInfo;
  if ShowTabHint then
  begin
    if (FHintTabIndex >= 0) then
    begin
      //PHI^.HintStr := FAdvOfficeTabs.Items[FHintTabIndex].OfficeHint.Hint;
      FDummyHintControl.OfficeHint.Assign(FAdvOfficeTabs.Items[FHintTabIndex].OfficeHint);
      PHI^.HintControl := FDummyHintControl;
    end;
  end
  else
    PHI^.HintStr := '';
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnTabSettingsChanged(Sender: TObject);
begin
  InitializeAndUpdateButtons;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.UpdateMe(PropID: integer);
begin
  Invalidate;

  case PropID of
    4: InitializeAndUpdateButtons;
  end;

  if Assigned(AdvOfficeTabSetStyler) then
  begin
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetVersion: string;
var
  vn: Integer;
begin
  vn := GetVersionNr;
  Result := IntToStr(Hi(Hiword(vn)))+'.'+IntToStr(Lo(Hiword(vn)))+'.'+IntToStr(Hi(Loword(vn)))+'.'+IntToStr(Lo(Loword(vn)));
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetVersion(const Value: string);
begin

end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetVersionNr: integer;
begin
  Result := MakeLong(MakeWord(BLD_VER,REL_VER),MakeWord(MIN_VER,MAJ_VER));
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetOfficeHint(const Value: TAdvHintInfo);
begin
  FOfficeHint.Assign(Value);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetTabPosition(const Value: TTabPosition);
begin
  if (FTabPosition <> Value) then
  begin
    FTabPosition := Value;
    UpdateTabScroller;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.CMDialogChar(var Message: TCMDialogChar);
var
  I: Integer;
begin
  for I:= 0 to FAdvOfficeTabs.Count-1 do
    if IsAccel(Message.CharCode, FAdvOfficeTabs.Items[I].Caption) and CanShowTab(I) and CanFocus then
    begin
      Message.Result := 1;
      ActiveTabIndex := I;
      Exit;
    end;
  inherited;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.CanShowTab(TabIndex: Integer): Boolean;
begin
  Result := (TabIndex >= 0) and (TabIndex < FAdvOfficeTabs.Count) and (FAdvOfficeTabs.Items[TabIndex].visible);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetAntiAlias(const Value: TAntiAlias);
begin
  FAntiAlias := Value;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetButtonSettings(
  const Value: TTabSetButtonSettings);
begin
  FButtonSettings.Assign(Value);
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnButtonSettingChanged(Sender: TObject);
begin
  UpdateTabScroller;
  Invalidate;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetTabListMenu(const Value: TPopupMenu);
begin
  FTabListMenu := Value;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetCloseOnTab(const Value: Boolean);
begin
  if (FCloseOnTab <> Value) then
  begin
    FCloseOnTab := Value;
    UpdateTabScroller;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetRotateTabLeftRight(const Value: Boolean);
begin
  if (FRotateTabLeftRight <> Value) then
  begin
    FRotateTabLeftRight := Value;
    UpdateTabScroller;
    Invalidate;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.SetAdvOfficeTabs(Value: TOfficeTabCollection);
begin
  FAdvOfficeTabs.Assign(Value);
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.GetVisibleTabCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FAdvOfficeTabs.Count-1 do
  begin
    if (FAdvOfficeTabs.Items[I].visible) then
      Result := Result + 1;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.InitializeAndUpdateButtons;
var
  R: TRect;
begin
  if (not FPropertiesLoaded) and not (csDesigning in ComponentState) then
    Exit;

  if ButtonSettings.CloseButton{ and not CloseOnTab} then
  begin
    if (FCloseButton = nil) then
    begin
      FCloseButton := TAdvGlowButton.Create(Self);
      FCloseButton.Parent := Self;
      FCloseButton.OnClick := OnCloseButtonClick;
    end;

    R := GetCloseButtonRect;
    FCloseButton.Left := R.Left;
    FCloseButton.Top := R.Top;
    FCloseButton.Width := R.Right - R.Left;
    FCloseButton.Height := R.Bottom - R.Top;
    if Assigned(FCurrentOfficeTabSetStyler) then
      FCloseButton.Appearance.Assign(FCurrentOfficeTabSetStyler.GlowButtonAppearance);
    FCloseButton.Picture.Assign(ButtonSettings.CloseButtonPicture);
    FCloseButton.Hint := ButtonSettings.CloseButtonHint;
    FCloseButton.ShowHint := True;
    FCloseButton.Enabled := GetVisibleTabCount > 0; //(ActivePage <> nil);
  end
  else
  if (FCloseButton <> nil) then
  begin
    FCloseButton.Free;
    FCloseButton := nil;
  end;

  if ButtonSettings.TabListButton then
  begin
    if (FTabListButton = nil) then
    begin
      FTabListButton := TAdvGlowButton.Create(Self);
      FTabListButton.Parent := Self;
      FTabListButton.OnClick := OnTabListButtonClick;
    end;

    R := GetTabListRect;
    FTabListButton.Left := R.Left;
    FTabListButton.Top := R.Top;
    FTabListButton.Width := R.Right - R.Left;
    FTabListButton.Height := R.Bottom - R.Top;
    if Assigned(FCurrentOfficeTabSetStyler) then
      FTabListButton.Appearance.Assign(FCurrentOfficeTabSetStyler.GlowButtonAppearance);
    FTabListButton.Picture.Assign(ButtonSettings.TabListButtonPicture);
    FTabListButton.Hint := ButtonSettings.TabListButtonHint;
    FTabListButton.ShowHint := True;
    FTabListButton.Enabled := GetVisibleTabCount > 0; //(AdvPageCount > 0);
  end
  else
  if (FTabListButton <> nil) then
  begin
    FTabListButton.Free;
    FTabListButton := nil;
  end;

  if (FTabScroller.Visible) then
  begin
    if (FScrollPrevButton = nil) then
    begin
      FScrollPrevButton := TAdvGlowButton.Create(Self);
      FScrollPrevButton.Parent := Self;
      FScrollPrevButton.OnClick := OnScrollPrevButtonClick;
    end;
    R := GetTabScrollerLeftRect;
    FScrollPrevButton.Left := R.Left;
    FScrollPrevButton.Top := R.Top;
    FScrollPrevButton.Width := R.Right - R.Left;
    FScrollPrevButton.Height := R.Bottom - R.Top;
    if Assigned(FCurrentOfficeTabSetStyler) then
      FScrollPrevButton.Appearance.Assign(FCurrentOfficeTabSetStyler.GlowButtonAppearance);
    FScrollPrevButton.Picture.Assign(ButtonSettings.ScrollButtonPrevPicture);
    FScrollPrevButton.Hint := ButtonSettings.ScrollButtonPrevHint;
    FScrollPrevButton.ShowHint := True;
    FScrollPrevButton.Enabled := FTabScroller.CanGoBack;

    if (FScrollNextButton = nil) then
    begin
      FScrollNextButton := TAdvGlowButton.Create(Self);
      FScrollNextButton.Parent := Self;
      FScrollNextButton.OnClick := OnScrollNextButtonClick;
    end;
    R := GetTabScrollerRightRect;
    FScrollNextButton.Left := R.Left;
    FScrollNextButton.Top := R.Top;
    FScrollNextButton.Width := R.Right - R.Left;
    FScrollNextButton.Height := R.Bottom - R.Top;
    if Assigned(FCurrentOfficeTabSetStyler) then
      FScrollNextButton.Appearance.Assign(FCurrentOfficeTabSetStyler.GlowButtonAppearance);
    FScrollNextButton.Picture.Assign(ButtonSettings.ScrollButtonNextPicture);
    FScrollNextButton.Hint := ButtonSettings.ScrollButtonNextHint;
    FScrollNextButton.ShowHint := True;
    FScrollNextButton.Enabled := FTabScroller.CanGoForward;
  end
  else
  begin
    if (FScrollPrevButton <> nil) then
    begin
      FScrollPrevButton.Free;
      FScrollPrevButton := nil;
    end;

    if (FScrollNextButton <> nil) then
    begin
      FScrollNextButton.Free;
      FScrollNextButton := nil;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnCloseButtonClick(Sender: TObject);
var
  Allow: Boolean;
  ActTabIndex: Integer;
  ActItem: TOfficeTabCollectionItem;
begin
  if (ActiveTabIndex >= 0) then
  begin
    Allow := True;
    if Assigned(FOnTabClose) then
      FOnTabClose(Self, ActiveTabIndex, Allow);

    if Allow then
    begin
      ActTabIndex := ActiveTabIndex;
      SelectNextTab(True);
      ActItem := FAdvOfficeTabs.Items[ActiveTabIndex];
      InvalidateTab(-1);

      BeforeCloseTab(FAdvOfficeTabs.Items[ActTabIndex]);

      if FreeOnClose then
      begin
        if Assigned(ActItem) and (ActItem <> FAdvOfficeTabs.Items[ActTabIndex]) then
        begin
          FAdvOfficeTabs.Items[ActTabIndex].Free;
          FActiveTabIndex := -1;
          ActiveTabIndex := ActItem.Index;
        end
        else
        begin
          FAdvOfficeTabs.Items[ActTabIndex].Free;
          ActiveTabIndex := -1;
        end;  
      end
      else
        FAdvOfficeTabs.Items[ActTabIndex].visible := False;

      UpdateTabScroller;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnTabListMenuClick(Sender: TObject);
begin
  if (Sender is TMenuItem) and ((TMenuItem(Sender).Tag >= 0) and (TMenuItem(Sender).Tag < FAdvOfficeTabs.Count)) then
  begin
    ActiveTabIndex := TMenuItem(Sender).Tag;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnTabListButtonClick(Sender: TObject);
var
  I: Integer;
  MenuItem: TMenuItem;
  P: TPoint;
  R: TRect;
begin
  if Assigned(TabListMenu) and (ButtonSettings.TabListButton) then
  begin
    TabListMenu.Items.Clear;
    for I := 0 to FAdvOfficeTabs.Count-1 do
    begin
      if FAdvOfficeTabs.Items[I].visible then
      begin
        MenuItem := TMenuItem.Create(self);
        MenuItem.Caption := FAdvOfficeTabs.Items[I].Caption;
        MenuItem.RadioItem := True;
        MenuItem.Checked := ActiveTabIndex = I;
        MenuItem.Tag := I;
        MenuItem.OnClick := OnTabListMenuClick;
        TabListMenu.Items.Add(MenuItem);
      end;
    end;

    if (FTabListButton <> nil) then
    begin
      case (TabPosition) of
        tpTop:
        begin
          R := GetTabListRect;
          P.X := R.Left + self.Left;
          P.Y := R.Bottom + self.Top;

          p := Parent.ClientToScreen(p);
        end;
        tpBottom:
        begin
          R := GetTabListRect;
          P.X := R.Left + self.Left;
          P.Y := R.Bottom + self.Top;
          p := Parent.ClientToScreen(p);
          if (GetSystemMetrics(SM_CYMENU) * TabListMenu.Items.Count) + P.Y + 10 >
          {$IFDEF DELPHI6_LVL}
            Screen.MonitorFromPoint(P).Height then
          {$ELSE}
            Screen.Height then
          {$ENDIF}
          begin
            if (FTabListButton <> nil) then
              Dec(P.Y, (GetSystemMetrics(SM_CYMENU) * TabListMenu.Items.Count) + (FTabListButton.Height) + 4);
          end;
        end;
        tpLeft:
        begin
          R := GetTabListRect;
          P.X := R.Right + self.Left;
          P.Y := R.Top + self.Top;
          p := Parent.ClientToScreen(p);
        end;
        tpRight:
        begin
          R := GetTabListRect;
          P.X := R.Right + self.Left;
          P.Y := R.Top + self.Top;
          p := Parent.ClientToScreen(p);
        end;
      end;

      if Assigned(FOnTabListClick) then
        FOnTabListClick(Self, P.X, P.Y)
      else
        TabListMenu.Popup(P.X, P.Y);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnScrollPrevButtonClick(Sender: TObject);
begin
  ScrollLeftBtnClick;
  InitializeAndUpdateButtons;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.OnScrollNextButtonClick(Sender: TObject);
begin
  ScrollRightBtnClick;
  InitializeAndUpdateButtons;
end;

//------------------------------------------------------------------------------

function TAdvCustomOfficeTabSet.AnyButtonVisible: Boolean;
begin
  Result := (FTabScroller.Visible or (ButtonSettings.CloseButton and not CloseOnTab) or ButtonSettings.TabListButton);
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.BeforeCloseTab(Tab: TOfficeTabCollectionItem);
begin

end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  P: TPoint;
  i: integer;
begin
  inherited;
  Accept := False;
  if Source = self then
  begin
    P.X:= X;
    P.Y:= Y;
    if PtInRect(GetTabsArea, p) then
    begin
      i := PTOnTab(X, Y);
      if (i >= 0) then
        Accept:= true;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvCustomOfficeTabSet.DragDrop(Source: TObject; X, Y: Integer);
var
  i, OldIndex: integer;
  P: TPoint;
  aItem: TOfficeTabCollectionItem;
begin
  inherited;
  P.X := X;
  P.Y := Y;
  i := PTOnTab(X, Y);

  if (i >= 0) and (i <> ActiveTabIndex) and (ActiveTabIndex >= 0) and (AdvOfficeTabs.Count > 0) then
  begin
    aItem := AdvOfficeTabs.Items[ActiveTabIndex];
    OldIndex := aItem.Index;
    AdvOfficeTabs.Move(aItem.Index, i);
    ActiveTabIndex := aItem.Index;
    if Assigned(FOnTabMoved) then
      FOnTabMoved(self, OldIndex, i);
  end;
end;

//------------------------------------------------------------------------------

{ TTabSetButtonSettings }

constructor TTabSetButtonSettings.Create;
begin
  inherited;
  FTabListButton := False;
  FCloseButton := False;
  FScrollButtonNextPicture := TGDIPPicture.Create;

  FScrollButtonNextPicture.LoadFromResourceName(hinstance,'TMSTSNEXT');

  FScrollButtonNextPicture.OnChange := OnPictureChanged;
  FScrollButtonPrevPicture := TGDIPPicture.Create;
  FScrollButtonPrevPicture.LoadFromResourceName(hinstance,'TMSTSPREV');

  FScrollButtonPrevPicture.OnChange := OnPictureChanged;
  FTabListButtonPicture := TGDIPPicture.Create;
  FTabListButtonPicture.LoadFromResourceName(hinstance,'TMSTSLIST');

  FTabListButtonPicture.OnChange := OnPictureChanged;
  FCloseButtonPicture := TGDIPPicture.Create;
  FCloseButtonPicture.LoadFromResourceName(hinstance,'TMSTSCLOSE');

  FCloseButtonPicture.OnChange := OnPictureChanged;
  FScrollButtonPrevHint := 'Previous';
  FScrollButtonNextHint := 'Next';
  FCloseButtonHint := 'Close';;
  FTabListButtonHint := 'TabList';
end;

//------------------------------------------------------------------------------

destructor TTabSetButtonSettings.Destroy;
begin
  FScrollButtonNextPicture.Free;
  FScrollButtonPrevPicture.Free;
  FTabListButtonPicture.Free;
  FCloseButtonPicture.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.Assign(Source: TPersistent);
begin
  if (Source is TTabSetButtonSettings) then
  begin
    FTabListButton := (Source as TTabSetButtonSettings).FTabListButton;
    FCloseButton := (Source as TTabSetButtonSettings).FCloseButton;
    FScrollButtonNextPicture.Assign((Source as TTabSetButtonSettings).FScrollButtonNextPicture);
    FScrollButtonPrevPicture.Assign((Source as TTabSetButtonSettings).FScrollButtonPrevPicture);
    FTabListButtonPicture.Assign((Source as TTabSetButtonSettings).FTabListButtonPicture);
    FCloseButtonPicture.Assign((Source as TTabSetButtonSettings).FCloseButtonPicture);
  end
  else
    inherited Assign(Source);
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.OnPictureChanged(Sender: TObject);
begin
  Changed;
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.SetCloseButton(const Value: Boolean);
begin
  if (FCloseButton <> Value) then
  begin
    FCloseButton := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.SetCloseButtonPicture(
  const Value: TGDIPPicture);
begin
  FCloseButtonPicture.Assign(Value);
  Changed;
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.SetTabListButton(const Value: boolean);
begin
  if (FTabListButton <> Value) then
  begin
    FTabListButton := Value;
    Changed;
  end;
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.SetTabListButtonPicture(
  const Value: TGDIPPicture);
begin
  FTabListButtonPicture.Assign(Value);
  Changed;
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.SetScrollButtonNextPicture(
  const Value: TGDIPPicture);
begin
  FScrollButtonNextPicture.Assign(Value);
  Changed;
end;

//------------------------------------------------------------------------------

procedure TTabSetButtonSettings.SetScrollButtonPrevPicture(
  const Value: TGDIPPicture);
begin
  FScrollButtonPrevPicture.Assign(Value);
  Changed;
end;

//------------------------------------------------------------------------------

{ TDummyHintControl }

constructor TDummyHintControl.Create(AOwner: TComponent);
begin
  inherited;
  FOfficeHint := TAdvHintInfo.Create;
end;

//------------------------------------------------------------------------------

destructor TDummyHintControl.Destroy;
begin
  FOfficeHint.Free;
  inherited;
end;

//------------------------------------------------------------------------------

procedure TDummyHintControl.SetOfficeHint(const Value: TAdvHintInfo);
begin
  FOfficeHint.Assign(Value);
end;

//------------------------------------------------------------------------------

{ TAdvOfficeMDITabSet }

constructor TAdvOfficeMDITabSet.Create(AOwner: TComponent);
var
  i: Integer;
begin
  if not(AOwner is TForm) then
  begin
    raise exception.create('AdvOfficeMDITabSet can only be placed on a Form.');
  end
  else if TForm(AOwner).FormStyle <> fsMDIForm then
  begin
    raise exception.create('AdvOfficeMDITabSet can only be placed on a MDIForm.');
  end;

  for i:= 0 to AOwner.ComponentCount-1 do
  begin
    if (AOwner.Components[i] is TAdvOfficeMDITabSet) and (AOwner.Components[i] <> Self) then
    begin
      raise exception.create('Only one instance of AdvOfficeMDITabSet can be placed on a MDIForm.');
    end;
  end;

  inherited;
  FreeOnClose := True;
end;

//------------------------------------------------------------------------------

destructor TAdvOfficeMDITabSet.Destroy;
begin

  inherited;
end;

//------------------------------------------------------------------------------

function TAdvOfficeMDITabSet.AddTab(
  ChildForm: TForm): TOfficeTabCollectionItem;
var
  i: Integer;
begin
  Result := nil;

  if not Assigned(ChildForm) then
    Exit;

  for i:= 0 to FAdvOfficeTabs.Count-1 do
  begin
    if (FAdvOfficeTabs.Items[i].FChildForm = ChildForm) then
    begin
      Exit;
    end;
  end;

  Result := FAdvOfficeTabs.Add;
  Result.Caption := ChildForm.Caption;
  Result.FChildForm := ChildForm;
  Result.FOnActivateForm := ChildForm.OnActivate;
  Result.FOnDestroyForm := ChildForm.OnDestroy;

  ChildForm.OnActivate := OnChildFormActivate;
  ChildForm.OnDestroy := OnChildFormDestroy;

  ActiveTabIndex := Result.Index;
  if not (csLoading in ComponentState) then
    InitializeAndUpdateButtons;
end;

//------------------------------------------------------------------------------

procedure TAdvOfficeMDITabSet.ChangeActiveTab(TabIndex: Integer);
var
  OldActiveTabIndex: Integer;
begin
  OldActiveTabIndex := ActiveTabIndex;
  inherited;

  if (TabIndex >= 0) and (TabIndex < FAdvOfficeTabs.Count) and (TabIndex <> OldActiveTabIndex) then
  begin
    Change;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvOfficeMDITabSet.Change;
begin
  if (ActiveTabIndex < 0) or (ActiveTabIndex >= FAdvOfficeTabs.Count) then
    Exit;

  if Assigned(FAdvOfficeTabs[ActiveTabIndex].FChildForm) then
  begin
    SendMessage(FAdvOfficeTabs[ActiveTabIndex].FChildForm.Handle, WM_NCActivate, wa_Active, 0);
    FAdvOfficeTabs[ActiveTabIndex].FChildForm.SetFocus;
    FAdvOfficeTabs[ActiveTabIndex].FChildForm.BringToFront;

    if FAdvOfficeTabs[ActiveTabIndex].FChildForm.Windowstate = WSMinimized then
       FAdvOfficeTabs[ActiveTabIndex].FChildForm.WindowState := WSNormal;

    FAdvOfficeTabs[ActiveTabIndex].FChildForm.visible:=true;
  end;
end;

//------------------------------------------------------------------------------

function TAdvOfficeMDITabSet.GetAdvOfficeTabCount: integer;
begin
  Result := FAdvOfficeTabs.Count;
end;

//------------------------------------------------------------------------------

function TAdvOfficeMDITabSet.GetAdvOfficeTabs(
  index: integer): TOfficeTabCollectionItem;
begin
  Result := nil;
  if (Index >= 0) and (Index < FAdvOfficeTabs.Count) then
  begin
    Result := FAdvOfficeTabs[Index];
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvOfficeMDITabSet.OnChildFormActivate(Sender: TObject);
var
  i :integer;
begin
  if (Sender is TForm) and (TForm(Sender).FormStyle = fsMDIChild) then
  begin
    for i:= 0 to FAdvOfficeTabs.count-1 do
    begin
      if (FAdvOfficeTabs[i].FChildForm = Sender) then
      begin
        if not FAdvOfficeTabs[i].Visible then
        begin
          FAdvOfficeTabs[i].Visible := True;
        end;
        ActiveTabIndex := i;
        break;
      end;
    end;

    if (ActiveTabIndex >= 0) and Assigned(FAdvOfficeTabs[FActiveTabIndex]) and Assigned(FAdvOfficeTabs[FActiveTabIndex].FOnActivateForm)
       and Assigned(FAdvOfficeTabs[FActiveTabIndex].FChildForm) then
    begin
      FAdvOfficeTabs[FActiveTabIndex].FOnActivateForm(FAdvOfficeTabs[FActiveTabIndex].FChildForm);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvOfficeMDITabSet.OnChildFormDestroy(Sender: TObject);
var
  i, j :integer;
begin
  if not (csDestroying in ComponentState) and not FInternalDelete and (Sender is TForm) and (TForm(Sender).FormStyle = fsMDIChild) then
  begin
    j := -1;
    for i:= 0 to FAdvOfficeTabs.count-1 do
    begin
      if (FAdvOfficeTabs[i].FChildForm = Sender) then
      begin
        j := i;
        break;
      end;
    end;

    if (j >= 0) and Assigned(FAdvOfficeTabs[j]) and Assigned(FAdvOfficeTabs[j].FOnDestroyForm)
       and Assigned(FAdvOfficeTabs[j].FChildForm) then
    begin
      FAdvOfficeTabs[j].FOnDestroyForm(FAdvOfficeTabs[j].FChildForm);
    end;

    if (j >= 0) then
      FAdvOfficeTabs.Delete(j);
  end;
end;

//------------------------------------------------------------------------------

function TAdvOfficeMDITabSet.GetChildForm(
  Tab: TOfficeTabCollectionItem): TForm;
begin
  Result := nil;
  if Assigned(Tab) then
  begin
    Result := Tab.FChildForm;
  end;
end;

//------------------------------------------------------------------------------

procedure TAdvOfficeMDITabSet.BeforeCloseTab(
  Tab: TOfficeTabCollectionItem);
begin
  inherited;
  if not Assigned(Tab) or not Assigned(Tab.FChildForm) then
    Exit;

  if FreeOnClose then
  begin
    FInternalDelete := True;
    Tab.FChildForm.Free;
    FInternalDelete := False;
  end
  else
  begin
    Tab.FChildForm.visible := False;
  end;  
end;

{$IFDEF FREEWARE}
{$I TRIAL.INC}
{$ENDIF}


end.
