
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl main components                     }
{                                                                    }
{           Copyright (c) 2001-2009 Developer Express Inc.           }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSLAYOUTCONTROL AND ALL          }
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

unit dxLayoutControl;

{$I cxVer.inc}

interface

uses
  Messages, Windows, SysUtils, Classes, Controls, Graphics, Forms, StdCtrls, ExtCtrls, IniFiles,
  dxCore, cxClasses, cxGraphics, cxControls, cxLookAndFeels,
  dxLayoutLookAndFeels, cxLibraryConsts, dxLayoutCommon;

const
  htError = -1;
  htNone = 0;
  htCustomizeForm = 1;
  htItem = 10;
  htGroup = 20;
  htClientArea = 30;

  dxLayoutItemControlDefaultMinHeight = 20;
  dxLayoutItemControlDefaultMinWidth = 20;

//  CM_FREEITEM = WM_DX + 25;
  CM_PLACECONTROLS = WM_DX + 26;

type
  TdxCustomLayoutItem = class;
  TdxLayoutItem = class;
  TdxLayoutGroupClass = class of TdxLayoutGroup;
  TdxLayoutGroup = class;
  TdxLayoutAlignmentConstraint = class;
  TdxCustomLayoutControl = class;
  TdxCustomLayoutHitTest = class;

  TdxLayoutItemPainterClass = class of TdxLayoutItemPainter;
  TdxLayoutItemPainter = class;
  TdxLayoutGroupPainterClass = class of TdxLayoutGroupPainter;
  TdxLayoutGroupPainter = class;
  TdxLayoutControlPainterClass = class of TdxLayoutControlPainter;
  TdxLayoutControlPainter = class;

  TdxCustomLayoutItemElementViewInfo = class;
  TdxCustomLayoutItemCaptionViewInfo = class;
  TdxCustomLayoutItemViewInfoClass = class of TdxCustomLayoutItemViewInfo;
  TdxCustomLayoutItemViewInfo = class;
  TdxLayoutItemControlViewInfo = class;
  TdxLayoutItemViewInfoClass = class of TdxLayoutItemViewInfo;
  TdxLayoutItemViewInfo = class;
  TdxLayoutGroupViewInfoClass = class of TdxLayoutGroupViewInfo;
  TdxLayoutGroupViewInfo = class;
  TdxLayoutGroupStandardViewInfo = class;
  TdxLayoutGroupWebViewInfo = class;
  TdxLayoutControlViewInfoClass = class of TdxLayoutControlViewInfo;
  TdxLayoutControlViewInfo = class;

  // custom item

  TdxLayoutAlignHorz = (ahLeft, ahCenter, ahRight, ahClient);
  TdxLayoutAlignVert = (avTop, avCenter, avBottom, avClient);
  TdxLayoutAutoAlign = (aaHorizontal, aaVertical);
  TdxLayoutAutoAligns = set of TdxLayoutAutoAlign;
  TdxLayoutDirection = (ldHorizontal, ldVertical);

  TdxCustomLayoutItemOptions = class(TPersistent)
  private
    FItem: TdxCustomLayoutItem;
  protected
    procedure Changed; virtual;
    property Item: TdxCustomLayoutItem read FItem;
  public
    constructor Create(AItem: TdxCustomLayoutItem); virtual;
  end;

  TdxCustomLayoutItemCaptionOptionsClass = class of TdxCustomLayoutItemCaptionOptions;

  TdxCustomLayoutItemCaptionOptions = class(TdxCustomLayoutItemOptions)
  private
    FAlignHorz: TAlignment;
    FShowAccelChar: Boolean;
    procedure SetAlignHorz(Value: TAlignment);
    procedure SetShowAccelChar(Value: Boolean);
  public
    constructor Create(AItem: TdxCustomLayoutItem); override;
  published
    property AlignHorz: TAlignment read FAlignHorz write SetAlignHorz default taLeftJustify;
    property ShowAccelChar: Boolean read FShowAccelChar write SetShowAccelChar default True;
  end;

  TdxLayoutOffsets = class(TdxCustomLayoutItemOptions)
  private
    FBottom: Integer;
    FLeft: Integer;
    FRight: Integer;
    FTop: Integer;
    function GetValue(Index: Integer): Integer;
    procedure SetValue(Index: Integer; Value: Integer);
  published
    property Bottom: Integer index 1 read GetValue write SetValue default 0;
    property Left: Integer index 2 read GetValue write SetValue default 0;
    property Right: Integer index 3 read GetValue write SetValue default 0;
    property Top: Integer index 4 read GetValue write SetValue default 0;
  end;

  TdxCustomLayoutItemClass = class of TdxCustomLayoutItem;

  TdxCustomLayoutItem = class(TComponent, IdxLayoutLookAndFeelUser)
  private
    FAlignHorz: TdxLayoutAlignHorz;
    FAlignmentConstraint: TdxLayoutAlignmentConstraint;
    FAlignVert: TdxLayoutAlignVert;
    FAllowRemove: Boolean;
    FAutoAligns: TdxLayoutAutoAligns;
    FCachedTextHeight: Integer;
    FCaption: string;
    FCaptionOptions: TdxCustomLayoutItemCaptionOptions;
    FContainer: TdxCustomLayoutControl;
    FEnabled: Boolean;
    FLookAndFeel: TdxCustomLayoutLookAndFeel;
    FOffsets: TdxLayoutOffsets;
    FParent: TdxLayoutGroup;
    FShowCaption: Boolean;
    FViewInfo: TdxCustomLayoutItemViewInfo;
    FVisible: Boolean;

    FOnCaptionClick: TNotifyEvent;

    function GetActuallyVisible: Boolean;
    function GetAlignHorz: TdxLayoutAlignHorz;
    function GetAlignVert: TdxLayoutAlignVert;
    function GetCaptionForCustomizeForm: string;
    function GetHasMouse: Boolean;
    function GetIndex: Integer;
    function GetIsDesigning: Boolean;
    function GetIsDestroying: Boolean;
    function GetIsLoading: Boolean;
    function GetIsRoot: Boolean;
    function GetVisibleIndex: Integer;
    procedure SetAlignHorz(Value: TdxLayoutAlignHorz);
    procedure SetAlignmentConstraint(Value: TdxLayoutAlignmentConstraint);
    procedure SetAlignVert(Value: TdxLayoutAlignVert);
    procedure SetAutoAligns(Value: TdxLayoutAutoAligns);
    procedure SetCaption(const Value: string);
    procedure SetContainer(Value: TdxCustomLayoutControl);
    procedure SetEnabled(Value: Boolean);
    procedure SetLookAndFeel(Value: TdxCustomLayoutLookAndFeel);
    procedure SetHasMouse(Value: Boolean);
    procedure SetIndex(Value: Integer);
    procedure SetParent(Value: TdxLayoutGroup);
    procedure SetShowCaption(Value: Boolean);
    procedure SetVisible(Value: Boolean);
    procedure SetVisibleIndex(Value: Integer);

    procedure CheckActuallyVisible(APrevActuallyVisible: Boolean);
    function IsAlignHorzStored: Boolean;
    function IsAlignVertStored: Boolean;
  protected
    procedure SetName(const Value: TComponentName); override;
    procedure SetParentComponent(Value: TComponent); override;

    procedure LookAndFeelChanged; virtual;
    procedure LookAndFeelChanging; virtual;
    // IdxLayoutLookAndFeelUser
    procedure BeginLookAndFeelDestroying; stdcall;
    procedure EndLookAndFeelDestroying; stdcall;
    procedure IdxLayoutLookAndFeelUser.LookAndFeelChanged = LookAndFeelChangedImpl;
    procedure LookAndFeelChangedImpl; stdcall;
    procedure LookAndFeelDestroyed; stdcall;

    procedure ActuallyVisibleChanged; virtual;
    function CanProcessAccel(out AItem: TdxCustomLayoutItem): Boolean; virtual; abstract;
    function CanRemove: Boolean; virtual;
    procedure DoCaptionClick; dynamic;
    function DoProcessAccel: Boolean; dynamic;
    procedure EnabledChanged; virtual;
    function GetAutoAlignHorz: TdxLayoutAlignHorz; virtual; abstract;
    function GetAutoAlignVert: TdxLayoutAlignVert; virtual; abstract;
    function GetBaseName: string; virtual;
    function GetCursor(X, Y: Integer): TCursor; virtual;
    function GetEnabledForWork: Boolean; virtual;
    function GetLookAndFeel: TdxCustomLayoutLookAndFeel;
    function GetShowCaption: Boolean; virtual;
    function GetViewInfoClass: TdxCustomLayoutItemViewInfoClass; virtual; abstract;
    function GetVisible: Boolean;
    function HasAsParent(AGroup: TdxLayoutGroup): Boolean;
    function HasCaption: Boolean; virtual;
    procedure Init; virtual;
    procedure MouseEnter; dynamic;
    procedure MouseLeave; dynamic;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;
    procedure ParentChanged(APrevParent: TdxLayoutGroup); virtual;
    procedure ProcessAccel; dynamic;
    function ProcessDialogChar(ACharCode: Word): Boolean; virtual;
    procedure RestoreItemControlSize; virtual; abstract;
    procedure SelectionChanged; virtual;
    procedure VisibleChanged; virtual;

    function GetCaptionOptionsClass: TdxCustomLayoutItemCaptionOptionsClass; virtual;

    procedure ResetCachedTextHeight;
    property CachedTextHeight: Integer read FCachedTextHeight write FCachedTextHeight;

    property EnabledForWork: Boolean read GetEnabledForWork;
    property HasMouse: Boolean read GetHasMouse write SetHasMouse;
    property IsDesigning: Boolean read GetIsDesigning;
    property IsDestroying: Boolean read GetIsDestroying;
    property IsLoading: Boolean read GetIsLoading;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeforeDestruction; override;
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;

    procedure Changed(AHardRefresh: Boolean = True); virtual;

    function CanMoveTo(AParent: TdxCustomLayoutItem): Boolean; virtual;
    procedure MakeVisible;
    function Move(AParent: TdxLayoutGroup; AIndex: Integer; APack: Boolean = False): Boolean;
    function MoveTo(AParent: TdxLayoutGroup; AVisibleIndex: Integer; APack: Boolean = False): Boolean;
    procedure Pack; virtual;
    function PutIntoHiddenGroup(ALayoutDirection: TdxLayoutDirection): TdxLayoutGroup;

    property ActuallyVisible: Boolean read GetActuallyVisible;
    property CaptionForCustomizeForm: string read GetCaptionForCustomizeForm;
    property Container: TdxCustomLayoutControl read FContainer write SetContainer;
    property Index: Integer read GetIndex write SetIndex;
    property IsRoot: Boolean read GetIsRoot;
    property Parent: TdxLayoutGroup read FParent write SetParent;
    property ViewInfo: TdxCustomLayoutItemViewInfo read FViewInfo;
    property VisibleIndex: Integer read GetVisibleIndex write SetVisibleIndex;
  published
    property AutoAligns: TdxLayoutAutoAligns read FAutoAligns write SetAutoAligns
      default [aaHorizontal, aaVertical];  // must be loaded before AlignHorz/Vert
    property AlignHorz: TdxLayoutAlignHorz read GetAlignHorz write SetAlignHorz
      stored IsAlignHorzStored;
    property AlignmentConstraint: TdxLayoutAlignmentConstraint read FAlignmentConstraint
      write SetAlignmentConstraint;
    property AlignVert: TdxLayoutAlignVert read GetAlignVert write SetAlignVert
      stored IsAlignVertStored;
    property AllowRemove: Boolean read FAllowRemove write FAllowRemove default True;
    property Caption: string read FCaption write SetCaption;
    property CaptionOptions: TdxCustomLayoutItemCaptionOptions read FCaptionOptions
      write FCaptionOptions;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property LookAndFeel: TdxCustomLayoutLookAndFeel read FLookAndFeel
      write SetLookAndFeel;
    property Offsets: TdxLayoutOffsets read FOffsets write FOffsets;
    property ShowCaption: Boolean read GetShowCaption write SetShowCaption default True;
    property Visible: Boolean read FVisible write SetVisible default True;

    property OnCaptionClick: TNotifyEvent read FOnCaptionClick write FOnCaptionClick;
  end;

  // item

  TdxCustomLayoutControlAdapterClass = class of TdxCustomLayoutControlAdapter;

  TdxCustomLayoutControlAdapter = class
  private
    FItem: TdxLayoutItem;
    function GetControl: TControl;
    function GetLookAndFeel: TdxCustomLayoutLookAndFeel;
  protected
    function AllowCheckSize: Boolean; virtual;
    procedure HideControlBorder; virtual;
    procedure Init; virtual;
    function ShowBorder: Boolean; virtual;
    function ShowItemCaption: Boolean; virtual;
    function UseItemColor: Boolean; virtual;

    property Control: TControl read GetControl;
    property Item: TdxLayoutItem read FItem;
    property LookAndFeel: TdxCustomLayoutLookAndFeel read GetLookAndFeel;
  public
    constructor Create(AItem: TdxLayoutItem); virtual;
    procedure LookAndFeelChanged; virtual;
    class procedure Register(AControlClass: TControlClass);
    class procedure Unregister(AControlClass: TControlClass);
  end;

  TdxCaptionLayout = (clLeft, clTop, clRight, clBottom);

  TdxAlignmentVert = (tavTop, tavCenter, tavBottom);

  TdxLayoutItemCaptionOptions = class(TdxCustomLayoutItemCaptionOptions)
  private
    FAlignVert: TdxAlignmentVert;
    FLayout: TdxCaptionLayout;
    FWidth: Integer;
    procedure SetAlignVert(Value: TdxAlignmentVert);
    procedure SetLayout(Value: TdxCaptionLayout);
    procedure SetWidth(Value: Integer);
  published
    constructor Create(AItem: TdxCustomLayoutItem); override;
    property AlignVert: TdxAlignmentVert read FAlignVert write SetAlignVert default tavCenter;
    property Layout: TdxCaptionLayout read FLayout write SetLayout default clLeft;
    property Width: Integer read FWidth write SetWidth default 0;
  end;

  TdxLayoutItemControlOptionsClass = class of TdxLayoutItemControlOptions;

  TdxLayoutItemControlOptions = class(TdxCustomLayoutItemOptions)
  private
    FAutoAlignment: Boolean;
    FAutoColor: Boolean;
    FFixedSize: Boolean;
    FMinHeight: Integer;
    FMinWidth: Integer;
    FOpaque: Boolean;
    FShowBorder: Boolean;
    procedure SetAutoAlignment(Value: Boolean);
    procedure SetAutoColor(Value: Boolean);
    procedure SetFixedSize(Value: Boolean);
    procedure SetMinHeight(Value: Integer);
    procedure SetMinWidth(Value: Integer);
    procedure SetOpaque(Value: Boolean);
    procedure SetShowBorder(Value: Boolean);
  public
    constructor Create(AItem: TdxCustomLayoutItem); override;
  published
    property AutoAlignment: Boolean read FAutoAlignment write SetAutoAlignment default True;
    property AutoColor: Boolean read FAutoColor write SetAutoColor default False;
    property FixedSize: Boolean read FFixedSize write SetFixedSize default False;
    property MinHeight: Integer read FMinHeight write SetMinHeight default dxLayoutItemControlDefaultMinHeight;
    property MinWidth: Integer read FMinWidth write SetMinWidth default dxLayoutItemControlDefaultMinWidth;
    property Opaque: Boolean read FOpaque write SetOpaque default False;
    property ShowBorder: Boolean read FShowBorder write SetShowBorder default True;
  end;

  TdxLayoutItemClass = class of TdxLayoutItem;

  TdxLayoutItem = class(TdxCustomLayoutItem)
  private
    FControl: TControl;
    FControlAdapter: TdxCustomLayoutControlAdapter;
    FControlOptions: TdxLayoutItemControlOptions;
    FControlSizeBeforeDestruction: TPoint;
    FOriginalControlSize: TPoint;
    FPrevControlWndProc: TWndMethod;

    function GetCaptionOptions: TdxLayoutItemCaptionOptions;
    function GetViewInfo: TdxLayoutItemViewInfo;
    procedure SetCaptionOptions(Value: TdxLayoutItemCaptionOptions);
    procedure SetControl(Value: TControl);

    procedure CreateControlAdapter;
    //procedure PostFree;
  protected
    procedure ActuallyVisibleChanged; override;
    function CanProcessAccel(out AItem: TdxCustomLayoutItem): Boolean; override;
    procedure EnabledChanged; override;
    function GetAutoAlignHorz: TdxLayoutAlignHorz; override;
    function GetAutoAlignVert: TdxLayoutAlignVert; override;
    function GetBaseName: string; override;
    function GetViewInfoClass: TdxCustomLayoutItemViewInfoClass; override;
    function HasCaption: Boolean; override;
    procedure Init; override;
    procedure Loaded; override;
    procedure LookAndFeelChanged; override;
    //procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure ParentChanged(APrevParent: TdxLayoutGroup); override;
    procedure ProcessAccel; override;
    procedure RestoreItemControlSize; override;

    function GetCaptionOptionsClass: TdxCustomLayoutItemCaptionOptionsClass; override;
    function GetControlOptionsClass: TdxLayoutItemControlOptionsClass; virtual;

    function CanFocusControl: Boolean; virtual;
    procedure ControlWndProc(var Message: TMessage); virtual;
    function HasControl: Boolean;
    function HasWinControl: Boolean;
    procedure SaveControlSizeBeforeDestruction;
    procedure SaveOriginalControlSize;
    procedure SetControlEnablement;
    procedure SetControlVisibility;

    property ControlAdapter: TdxCustomLayoutControlAdapter read FControlAdapter;
    property ControlSizeBeforeDestruction: TPoint read FControlSizeBeforeDestruction; 
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property OriginalControlSize: TPoint read FOriginalControlSize write FOriginalControlSize;
    property ViewInfo: TdxLayoutItemViewInfo read GetViewInfo;
  published
    property CaptionOptions: TdxLayoutItemCaptionOptions read GetCaptionOptions
      write SetCaptionOptions;
    property Control: TControl read FControl write SetControl;
    property ControlOptions: TdxLayoutItemControlOptions read FControlOptions
      write FControlOptions;
  end;

  // group

  TdxLayoutGroup = class(TdxCustomLayoutItem)
  private
    FHidden: Boolean;
    FIsPacking: Boolean;
    FIsUserDefined: Boolean;
    FItems: TList;
    FLayoutDirection: TdxLayoutDirection;
    FLocked: Boolean;
    FLookAndFeelException: Boolean;
    FShowBorder: Boolean;
    FUseIndent: Boolean;
    FVisibleItems: TList;

    function GetCount: Integer;
    function GetItem(Index: Integer): TdxCustomLayoutItem;
    function GetShowBorder: Boolean;
    function GetViewInfo: TdxLayoutGroupViewInfo;
    function GetVisibleCount: Integer;
    function GetVisibleItem(Index: Integer): TdxCustomLayoutItem;
    procedure SetHidden(Value: Boolean);
    procedure SetLayoutDirection(Value: TdxLayoutDirection);
    procedure SetLocked(Value: Boolean);
    procedure SetLookAndFeelException(Value: Boolean);
    procedure SetShowBorder(Value: Boolean);
    procedure SetUseIndent(Value: Boolean);

    procedure AddItem(AItem: TdxCustomLayoutItem);
    procedure RemoveItem(AItem: TdxCustomLayoutItem);
    procedure DestroyItems;
  protected
    procedure ActuallyVisibleChanged; override;
    function CanProcessAccel(out AItem: TdxCustomLayoutItem): Boolean; override;
    function CanRemove: Boolean; override;
    procedure EnabledChanged; override;
    function GetAutoAlignHorz: TdxLayoutAlignHorz; override;
    function GetAutoAlignVert: TdxLayoutAlignVert; override;
    function GetBaseName: string; override;
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    function GetShowCaption: Boolean; override;
    function GetViewInfoClass: TdxCustomLayoutItemViewInfoClass; override;
    procedure Loaded; override;
    procedure LookAndFeelChanged; override;
    procedure LookAndFeelChanging; override;
    function ProcessDialogChar(ACharCode: Word): Boolean; override;
    procedure RestoreItemControlSize; override;
    procedure SelectionChanged; override;
    procedure SetChildOrder(Child: TComponent; Order: Integer); override;
    procedure SetParentComponent(Value: TComponent); override;

    function CanDestroy: Boolean; virtual;
    procedure BuildVisibleItemsList;
    function GetLookAndFeelAsParent: TdxCustomLayoutLookAndFeel;

    procedure ChangeItemIndex(AItem: TdxCustomLayoutItem; Value: Integer);
    procedure ChangeItemVisibleIndex(AItem: TdxCustomLayoutItem; Value: Integer);
    function GetItemIndex(AItemVisibleIndex: Integer): Integer;
    function IndexOf(AItem: TdxCustomLayoutItem): Integer;
    function VisibleIndexOf(AItem: TdxCustomLayoutItem): Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CreateGroup(AGroupClass: TdxLayoutGroupClass = nil): TdxLayoutGroup;
    function CreateItem(AItemClass: TdxCustomLayoutItemClass = nil): TdxCustomLayoutItem;
    function CreateItemForControl(AControl: TControl): TdxLayoutItem;

    function CanMoveTo(AParent: TdxCustomLayoutItem): Boolean; override;
    procedure MoveChildrenToParent;
    procedure Pack; override;
    function PutChildrenIntoHiddenGroup: TdxLayoutGroup;

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TdxCustomLayoutItem read GetItem; default;
    property IsUserDefined: Boolean read FIsUserDefined;
    property ViewInfo: TdxLayoutGroupViewInfo read GetViewInfo;
    property VisibleCount: Integer read GetVisibleCount;
    property VisibleItems[Index: Integer]: TdxCustomLayoutItem read GetVisibleItem;
  published
    property Hidden: Boolean read FHidden write SetHidden default False;
    property LayoutDirection: TdxLayoutDirection read FLayoutDirection
      write SetLayoutDirection default ldVertical;
    property Locked: Boolean read FLocked write SetLocked default False;
    property LookAndFeelException: Boolean read FLookAndFeelException
      write SetLookAndFeelException default False; 
    property ShowBorder: Boolean read GetShowBorder write SetShowBorder default True;
    property UseIndent: Boolean read FUseIndent write SetUseIndent default True;
  end;

  // alignment constraint

  TdxLayoutAlignmentConstraintKind = (ackLeft, ackTop, ackRight, ackBottom);

  TdxLayoutAlignmentConstraintClass = class of TdxLayoutAlignmentConstraint;

  TdxLayoutAlignmentConstraint = class(TComponent)
  private
    FControl: TdxCustomLayoutControl;
    FItems: TList;
    FKind: TdxLayoutAlignmentConstraintKind;
    function GetCount: Integer;
    function GetItem(Index: Integer): TdxCustomLayoutItem;
    procedure SetKind(Value: TdxLayoutAlignmentConstraintKind);
    procedure CreateItems;
    procedure DestroyItems;
  protected
    procedure SetParentComponent(Value: TComponent); override;

    procedure BeginUpdate;
    function CanAddItem(AItem: TdxCustomLayoutItem): Boolean; virtual;
    procedure Changed; virtual;
    procedure EndUpdate;

    property Control: TdxCustomLayoutControl read FControl;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;

    procedure AddItem(AItem: TdxCustomLayoutItem);
    procedure RemoveItem(AItem: TdxCustomLayoutItem);

    property Count: Integer read GetCount;
    property Items[Index: Integer]: TdxCustomLayoutItem read GetItem;
  published
    property Kind: TdxLayoutAlignmentConstraintKind read FKind write SetKind default ackLeft;
  end;

  { controls }

  TdxLayoutAreaPart = (apNone, apLeft, apTop, apRight, apBottom, apCenter,
    apBeforeContent, apAfterContent);
  TdxLayoutDragSource = (dsControl, dsCustomizeForm);

  TdxLayoutControlDragAndDropObject = class(TcxDragAndDropObject)
  private
    FAreaPart: TdxLayoutAreaPart;
    FDestItem: TdxCustomLayoutItem;
    FSource: TdxLayoutDragSource;
    FSourceItem: TdxCustomLayoutItem;
    FSourceItemBounds: TRect;

    function GetControl: TdxCustomLayoutControl;
    procedure SetAreaPart(Value: TdxLayoutAreaPart);
    procedure SetDestItem(Value: TdxCustomLayoutItem);
    procedure SetSourceItem(Value: TdxCustomLayoutItem);

    procedure HideSourceItemMark;
    procedure ShowSourceItemMark;
  protected
    procedure DirtyChanged; override;
    function GetDragAndDropCursor(Accepted: Boolean): TCursor; override;

    function GetCenterAreaBounds(const AItemBounds: TRect): TRect;
    property Control: TdxCustomLayoutControl read GetControl;

    property AreaPart: TdxLayoutAreaPart read FAreaPart write SetAreaPart;
    property DestItem: TdxCustomLayoutItem read FDestItem write SetDestItem;
    property Source: TdxLayoutDragSource read FSource write FSource;
    property SourceItemBounds: TRect read FSourceItemBounds;
  public
    destructor Destroy; override;
    procedure BeginDragAndDrop; override;
    procedure DragAndDrop(const P: TPoint; var Accepted: Boolean); override;
    procedure EndDragAndDrop(Accepted: Boolean); override;
    procedure Init(ASource: TdxLayoutDragSource; ASourceItem: TdxCustomLayoutItem); virtual;
    property SourceItem: TdxCustomLayoutItem read FSourceItem write SetSourceItem;
  end;

  TdxLayoutAutoContentSize = (acsWidth, acsHeight);
  TdxLayoutAutoContentSizes = set of TdxLayoutAutoContentSize;

  TdxCustomLayoutControl = class(TcxControl, IdxLayoutLookAndFeelUser, IdxLayoutComponent, IdxSkinSupport)
  private
    FAbsoluteItems: TList;
    FAlignmentConstraints: TList;
    FAutoContentSizes: TdxLayoutAutoContentSizes;
    FAutoControlAlignment: Boolean;
    FAutoControlTabOrders: Boolean;
    FAvailableItems: TList;
    FBoldFont: TFont;
    FCustomization: Boolean;
    FCustomizeForm: TCustomForm;
    FCustomizeFormBounds: TRect;
    FCustomizeFormClass: TFormClass;
    FDesignFormBounds: TRect;
    FIniFileName: string;
    FItems: TdxLayoutGroup;
    FIsPlaceControlsNeeded: Boolean;
    FIsPlacingControls: Boolean;
    FItemWithMouse: TdxCustomLayoutItem;
    FLeftPos: Integer;
    FLookAndFeel: TdxCustomLayoutLookAndFeel;
    FMayPack: Boolean;
    FPainter: TdxLayoutControlPainter;
    FRegistryPath: string;
    FRightButtonPressed: Boolean;
    FShowHiddenGroupsBounds: Boolean;
    FStoreInIniFile: Boolean;
    FStoreInRegistry: Boolean;
    FTopPos: Integer;
    FUpdateLockCount: Integer;
    FViewInfo: TdxLayoutControlViewInfo;

    FOnCustomization: TNotifyEvent;

    function GetAbsoluteItem(Index: Integer): TdxCustomLayoutItem;
    function GetAbsoluteItemCount: Integer;
    function GetAlignmentConstraint(Index: Integer): TdxLayoutAlignmentConstraint;
    function GetAlignmentConstraintCount: Integer;
    function GetAvailableItem(Index: Integer): TdxCustomLayoutItem;
    function GetAvailableItemCount: Integer;
    function GetIsCustomizationMode: Boolean;
    function GetContentBounds: TRect;
    function GetOccupiedClientWidth: Integer;
    function GetOccupiedClientHeight: Integer;
    function GetLayoutDirection: TdxLayoutDirection;
    procedure SetAutoContentSizes(Value: TdxLayoutAutoContentSizes);
    procedure SetAutoControlAlignment(Value: Boolean);
    procedure SetAutoControlTabOrders(Value: Boolean);
    procedure SetCustomization(Value: Boolean);
    procedure SetCustomizationModeForm(Value: TCustomForm);
    procedure SetIsCustomizationMode(Value: Boolean);
    procedure SetIsPlaceControlsNeeded(Value: Boolean);
    procedure SetItems(Value: TdxLayoutGroup);
    procedure SetItemWithMouse(Value: TdxCustomLayoutItem);
    procedure SetLayoutDirection(Value: TdxLayoutDirection);
    procedure SetLeftPos(Value: Integer);
    procedure SetLookAndFeel(Value: TdxCustomLayoutLookAndFeel);
    procedure SetShowHiddenGroupsBounds(Value: Boolean);
    procedure SetTopPos(Value: Integer);

    procedure CreateHandlers;
    procedure DestroyHandlers;

    procedure CreateConstraints;
    procedure DestroyConstraints;
    procedure AddAlignmentConstraint(AConstraint: TdxLayoutAlignmentConstraint);
    procedure RemoveAlignmentConstraint(AConstraint: TdxLayoutAlignmentConstraint);

    procedure RefreshBoldFont;

    procedure AddAbsoluteItem(AItem: TdxCustomLayoutItem);
    procedure RemoveAbsoluteItem(AItem: TdxCustomLayoutItem);

    procedure AddAvailableItem(AItem: TdxCustomLayoutItem);
    procedure RemoveAvailableItem(AItem: TdxCustomLayoutItem);
    procedure DestroyAvailableItems;

    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
  {$IFNDEF DELPHI7}
    procedure WMPrintClient(var Message: TWMPrintClient); message WM_PRINTCLIENT;
  {$ENDIF}
    procedure CMControlChange(var Message: TCMControlChange); message CM_CONTROLCHANGE;
    procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;
    //procedure CMFreeItem(var Message: TMessage); message CM_FREEITEM;
    procedure CMPlaceControls(var Message: TMessage); message CM_PLACECONTROLS;
  protected
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    function AllowAutoDragAndDropAtDesignTime(X, Y: Integer;
      Shift: TShiftState): Boolean; override;
    function AllowDragAndDropWithoutFocus: Boolean; override;
    procedure BoundsChanged; override;
    function CanDrag(X, Y: Integer): Boolean; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure FontChanged; override;
  {$IFNDEF DELPHI12}
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  {$ENDIF}
    function GetCursor(X, Y: Integer): TCursor; override;
    function GetDesignHitTest(X, Y: Integer; Shift: TShiftState): Boolean; override;
    function HasBackground: Boolean; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure SetName(const Value: TComponentName); override;
  {$IFDEF DELPHI7}
    procedure SetParentBackground(Value: Boolean); override;
  {$ENDIF}
    procedure WndProc(var Message: TMessage); override;
    procedure WriteState(Writer: TWriter); override;

    procedure InitScrollBarsParameters; override;
    function NeedsToBringInternalControlsToFront: Boolean; override;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); override;

    function CanDragAndDrop: Boolean;
    function GetDragAndDropObjectClass: TcxDragAndDropObjectClass; override;
    function StartDragAndDrop(const P: TPoint): Boolean; override;

    function GetLookAndFeel: TdxCustomLayoutLookAndFeel;
    // IdxLayoutLookAndFeelUser
    procedure BeginLookAndFeelDestroying; stdcall;
    procedure EndLookAndFeelDestroying; stdcall;
    procedure LookAndFeelChanged; reintroduce; stdcall;
    procedure LookAndFeelDestroyed; stdcall;

    // IdxLayoutComponent
    procedure SelectionChanged; stdcall;

    function GetPainterClass: TdxLayoutControlPainterClass; virtual;
    function GetViewInfoClass: TdxLayoutControlViewInfoClass; virtual;

    procedure AssignItemWithMouse(X, Y: Integer);
    procedure AvailableItemListChanged(AItem: TdxCustomLayoutItem;
      AIsItemAdded: Boolean); dynamic;
    function CalculateCustomizeFormBounds(const AFormBounds: TRect): TRect;
    function CanMultiSelect: Boolean; virtual;
    function CanShowSelection: Boolean; virtual;
    procedure CheckLeftPos(var Value: Integer);
    procedure CheckPositions;
    procedure CheckTopPos(var Value: Integer);
    procedure DoCustomization; dynamic;
    procedure DragAndDropBegan; dynamic;
    function GetAlignmentConstraintClass: TdxLayoutAlignmentConstraintClass; dynamic;
    function GetDefaultGroupClass: TdxLayoutGroupClass; virtual;
    function GetDefaultItemClass: TdxLayoutItemClass; virtual;
    function IsCustomization: Boolean;
    function IsUpdateLocked: Boolean;
    procedure LayoutChanged; virtual;
    //procedure PostFree(AObject: TObject);
    procedure ScrollContent(APrevPos, ACurPos: Integer; AHorzScrolling: Boolean);
    procedure UpdateLookAndFeelSkinName;

    procedure LoadFromCustomIniFile(AIniFile: TCustomIniFile; const ARootSection: string); virtual;
    procedure SaveToCustomIniFile(AIniFile: TCustomIniFile; const ARootSection: string); virtual;

    property BoldFont: TFont read FBoldFont;
    property CustomizationModeForm: TCustomForm write SetCustomizationModeForm;
    property DesignFormBounds: TRect read FDesignFormBounds write FDesignFormBounds;
    property IsCustomizationMode: Boolean read GetIsCustomizationMode
      write SetIsCustomizationMode;
    property IsPlaceControlsNeeded: Boolean read FIsPlaceControlsNeeded write SetIsPlaceControlsNeeded;
    property ItemWithMouse: TdxCustomLayoutItem read FItemWithMouse
      write SetItemWithMouse;
    property MayPack: Boolean read FMayPack write FMayPack;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    function CreateAlignmentConstraint: TdxLayoutAlignmentConstraint;
    function FindItem(AControl: TControl): TdxLayoutItem; overload;
    function FindItem(const AName: string): TdxCustomLayoutItem; overload;
  {$IFDEF DELPHI12}
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
  {$ENDIF}
    function GetHitTest(const P: TPoint): TdxCustomLayoutHitTest; overload;
    function GetHitTest(X, Y: Integer): TdxCustomLayoutHitTest; overload;

    procedure BeginUpdate;
    procedure EndUpdate;

    function CreateGroup(AGroupClass: TdxLayoutGroupClass = nil;
      AParent: TdxLayoutGroup = nil): TdxLayoutGroup;
    function CreateItem(AItemClass: TdxCustomLayoutItemClass = nil;
      AParent: TdxLayoutGroup = nil): TdxCustomLayoutItem;
    function CreateItemForControl(AControl: TControl;
      AParent: TdxLayoutGroup = nil): TdxLayoutItem;

    procedure LoadFromIniFile(const AFileName: string);
    procedure LoadFromRegistry(const ARegistryPath: string);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToIniFile(const AFileName: string);
    procedure SaveToRegistry(const ARegistryPath: string);
    procedure SaveToStream(AStream: TStream);

    property AbsoluteItemCount: Integer read GetAbsoluteItemCount;
    property AbsoluteItems[Index: Integer]: TdxCustomLayoutItem read GetAbsoluteItem;
    property AlignmentConstraintCount: Integer read GetAlignmentConstraintCount;
    property AlignmentConstraints[Index: Integer]: TdxLayoutAlignmentConstraint
      read GetAlignmentConstraint;
    property AutoContentSizes: TdxLayoutAutoContentSizes read FAutoContentSizes
      write SetAutoContentSizes default [];
    property AutoControlAlignment: Boolean read FAutoControlAlignment
      write SetAutoControlAlignment default True;
    property AutoControlTabOrders: Boolean read FAutoControlTabOrders
      write SetAutoControlTabOrders default True;
    property AvailableItemCount: Integer read GetAvailableItemCount;
    property AvailableItems[Index: Integer]: TdxCustomLayoutItem read GetAvailableItem;
    property Customization: Boolean read FCustomization write SetCustomization;
    property CustomizeForm: TCustomForm read FCustomizeForm;
    property CustomizeFormBounds: TRect read FCustomizeFormBounds
      write FCustomizeFormBounds;
    property CustomizeFormClass: TFormClass read FCustomizeFormClass write FCustomizeFormClass;  // must be descendant of TLayoutCustomizeForm
    property Items: TdxLayoutGroup read FItems;
    property IsPlacingControls: Boolean read FIsPlacingControls;
    property LayoutDirection: TdxLayoutDirection read GetLayoutDirection
      write SetLayoutDirection;
    property LeftPos: Integer read FLeftPos write SetLeftPos;
    property LookAndFeel: TdxCustomLayoutLookAndFeel read FLookAndFeel
      write SetLookAndFeel;
    property ShowHiddenGroupsBounds: Boolean read FShowHiddenGroupsBounds
      write SetShowHiddenGroupsBounds;
    property TopPos: Integer read FTopPos write SetTopPos;

    property ContentBounds: TRect read GetContentBounds;
    property OccupiedClientWidth: Integer read GetOccupiedClientWidth;
    property OccupiedClientHeight: Integer read GetOccupiedClientHeight;

    property IniFileName: string read FIniFileName write FIniFileName;
    property RegistryPath: string read FRegistryPath write FRegistryPath;
    property StoreInIniFile: Boolean read FStoreInIniFile write FStoreInIniFile default False;
    property StoreInRegistry: Boolean read FStoreInRegistry write FStoreInRegistry default False;

    property Painter: TdxLayoutControlPainter read FPainter;
    property ViewInfo: TdxLayoutControlViewInfo read FViewInfo;

    property OnCustomization: TNotifyEvent read FOnCustomization write FOnCustomization;
  end;

  TdxLayoutControl = class(TdxCustomLayoutControl)
  published
    property Align;
    property Anchors;
  {$IFDEF DELPHI6}
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property BorderWidth;
  {$ENDIF}
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FocusOnClick;
    property Font;
  {$IFDEF DELPHI7}
    property ParentBackground default False;
  {$ENDIF}
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;

    property OnClick;
    property OnContextPopup;
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
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;

    property AutoContentSizes;
    property AutoControlAlignment;
    property AutoControlTabOrders;
    property IniFileName;
    property LayoutDirection stored False;
    property LookAndFeel;
    property RegistryPath;
    property StoreInIniFile;
    property StoreInRegistry;

    property OnCustomization;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

  { hit tests }

  TdxCustomLayoutHitTestClass = class of TdxCustomLayoutHitTest;

  TdxCustomLayoutHitTest = class
  public
    function Cursor: TCursor; dynamic;
    class function HitTestCode: Integer; virtual;
    class function Instance: TdxCustomLayoutHitTest;
  end;

  TdxLayoutNoneHitTest = class(TdxCustomLayoutHitTest)
  public
    class function HitTestCode: Integer; override;
  end;

  TdxCustomLayoutItemHitTestClass = class of TdxCustomLayoutItemHitTest;

  TdxCustomLayoutItemHitTest = class(TdxCustomLayoutHitTest)
  private
    FItem: TdxCustomLayoutItem;
  public
    property Item: TdxCustomLayoutItem read FItem write FItem;
  end;

  TdxLayoutItemHitTest = class(TdxCustomLayoutItemHitTest)
  private
    function GetItem: TdxLayoutItem;
    procedure SetItem(Value: TdxLayoutItem);
  public
    class function HitTestCode: Integer; override;
    property Item: TdxLayoutItem read GetItem write SetItem;
  end;

  TdxLayoutGroupHitTest = class(TdxCustomLayoutItemHitTest)
  private
    function GetItem: TdxLayoutGroup;
    procedure SetItem(Value: TdxLayoutGroup);
  public
    class function HitTestCode: Integer; override;
    property Item: TdxLayoutGroup read GetItem write SetItem;
  end;

  TdxLayoutCustomizeFormHitTest = class(TdxCustomLayoutHitTest)
  public
    class function HitTestCode: Integer; override;
  end;

  TdxLayoutClientAreaHitTest = class(TdxCustomLayoutHitTest)
  private
    FControl: TdxCustomLayoutControl;
  public
    class function HitTestCode: Integer; override;
    property Control: TdxCustomLayoutControl read FControl write FControl;
  end;

  { custom handler }

  TdxCustomLayoutControlHandler = class
  private
    FControl: TdxCustomLayoutControl;
    function GetViewInfo: TdxLayoutControlViewInfo;
  protected
    property Control: TdxCustomLayoutControl read FControl;
    property ViewInfo: TdxLayoutControlViewInfo read GetViewInfo;
  public
    constructor Create(AControl: TdxCustomLayoutControl); virtual;
  end;

  { painters }

  // custom

  TdxCustomLayoutItemElementPainter = class
  private
    FCanvas: TcxCanvas;
    FViewInfo: TdxCustomLayoutItemElementViewInfo;
    function GetLookAndFeel: TdxCustomLayoutLookAndFeel;
  protected
    property Canvas: TcxCanvas read FCanvas;
    property LookAndFeel: TdxCustomLayoutLookAndFeel read GetLookAndFeel;
    property ViewInfo: TdxCustomLayoutItemElementViewInfo read FViewInfo;
  public
    constructor Create(ACanvas: TcxCanvas;
      AViewInfo: TdxCustomLayoutItemElementViewInfo); virtual;
    procedure Paint; virtual; abstract;
  end;

  TdxCustomLayoutItemCaptionPainterClass = class of TdxCustomLayoutItemCaptionPainter;

  TdxCustomLayoutItemCaptionPainter = class(TdxCustomLayoutItemElementPainter)
  private
    function GetViewInfo: TdxCustomLayoutItemCaptionViewInfo;
  protected
    procedure AfterDrawText; virtual;
    procedure BeforeDrawText; virtual;
    procedure DrawBackground; virtual;
    procedure DrawText; virtual;
    property ViewInfo: TdxCustomLayoutItemCaptionViewInfo read GetViewInfo;
  public
    procedure Paint; override;
  end;

  TdxCustomLayoutItemPainterClass = class of TdxCustomLayoutItemPainter;

  TdxCustomLayoutItemPainter = class
  private
    FCanvas: TcxCanvas;
    FViewInfo: TdxCustomLayoutItemViewInfo;
    function GetLookAndFeel: TdxCustomLayoutLookAndFeel;
  protected
    function GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass; virtual; abstract;
    procedure DrawCaption; virtual;
    procedure DrawSelection; virtual;
    procedure InternalDrawSelection;

    property Canvas: TcxCanvas read FCanvas;
    property LookAndFeel: TdxCustomLayoutLookAndFeel read GetLookAndFeel;
    property ViewInfo: TdxCustomLayoutItemViewInfo read FViewInfo;
  public
    constructor Create(ACanvas: TcxCanvas; AViewInfo: TdxCustomLayoutItemViewInfo); virtual;
    procedure DrawSelections; virtual;
    procedure Paint; virtual;
  end;

  // item

  TdxLayoutItemCaptionPainter = class(TdxCustomLayoutItemCaptionPainter);

  TdxLayoutItemControlPainterClass = class of TdxLayoutItemControlPainter;

  TdxLayoutItemControlPainter = class(TdxCustomLayoutItemElementPainter)
  private
    function GetViewInfo: TdxLayoutItemControlViewInfo;
  protected
    procedure DrawBorders; virtual;
    property ViewInfo: TdxLayoutItemControlViewInfo read GetViewInfo;
  public
    procedure Paint; override;
  end;

  TdxLayoutItemPainter = class(TdxCustomLayoutItemPainter)
  private
    function GetViewInfo: TdxLayoutItemViewInfo;
  protected
    function GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass; override;
    function GetControlPainterClass: TdxLayoutItemControlPainterClass; virtual;

    procedure DrawControl; virtual;

    property ViewInfo: TdxLayoutItemViewInfo read GetViewInfo;
  public
    procedure Paint; override;
  end;

  // group

  TdxLayoutGroupCaptionPainter = class(TdxCustomLayoutItemCaptionPainter);

  TdxLayoutGroupPainter = class(TdxCustomLayoutItemPainter)
  private
    function GetViewInfo: TdxLayoutGroupViewInfo;
  protected
    function GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass; override;

    procedure DrawBorders; virtual;
    procedure DrawBoundsFrame; virtual;
    procedure DrawItems; virtual;
    procedure DrawItemsArea; virtual;

    property ViewInfo: TdxLayoutGroupViewInfo read GetViewInfo;
  public
    procedure DrawSelections; override;
    procedure Paint; override;
  end;

  TdxLayoutGroupCaptionStandardPainter = class(TdxLayoutGroupCaptionPainter)
  protected
    procedure DrawText; override;
  end;

  TdxLayoutGroupStandardPainter = class(TdxLayoutGroupPainter)
  private
    function GetViewInfo: TdxLayoutGroupStandardViewInfo;
  protected
    function GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass; override;
    procedure DrawBorders; override;
    procedure DrawFrame; virtual;
    property ViewInfo: TdxLayoutGroupStandardViewInfo read GetViewInfo;
  end;

  TdxLayoutGroupOfficePainter = class(TdxLayoutGroupStandardPainter)
  protected
    function GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass; override;
    procedure DrawFrame; override;
  end;

  TdxLayoutGroupWebPainter = class(TdxLayoutGroupPainter)
  private
    function GetLookAndFeel: TdxLayoutWebLookAndFeel;
    function GetViewInfo: TdxLayoutGroupWebViewInfo;
  protected
    procedure DrawBorders; override;
    procedure DrawCaptionSeparator; virtual;
    procedure DrawFrame; virtual;
    property LookAndFeel: TdxLayoutWebLookAndFeel read GetLookAndFeel;
    property ViewInfo: TdxLayoutGroupWebViewInfo read GetViewInfo;
  end;

  // control

  TdxLayoutControlPainter = class(TdxCustomLayoutControlHandler)
  private
    FCanvas: TcxCanvas;
  protected
    function GetInternalCanvas: TcxCanvas; virtual;
    procedure MakeCanvasClipped(ACanvas: TcxCanvas);

    procedure DrawEmptyArea; virtual;
    procedure DrawItems; virtual;
    procedure PlaceControls; virtual;

    property InternalCanvas: TcxCanvas read GetInternalCanvas;
    property Canvas: TcxCanvas read FCanvas;
  public
    function GetCanvas: TcxCanvas; virtual;
    function GetCustomizationCanvas: TcxCanvas;
    procedure DrawSelections; virtual;
    procedure Paint; virtual;
  end;

  { view infos }

  // custom item

  TdxCustomLayoutItemElementViewInfo = class
  private
    FItemViewInfo: TdxCustomLayoutItemViewInfo;
    FHeight: Integer;
    FPressed: Boolean;
    FWidth: Integer;
    function GetHeight: Integer;
    function GetItem: TdxCustomLayoutItem;
    function GetLookAndFeel: TdxCustomLayoutLookAndFeel;
    function GetWidth: Integer;
    procedure SetHeight(Value: Integer);
    procedure SetWidth(Value: Integer);
  protected
    function GetEnabled: Boolean; virtual;
    function GetEnabledForWork: Boolean; virtual;
    function GetCursor(X, Y: Integer): TCursor; virtual;
    function GetVisible: Boolean; virtual;
    procedure Invalidate(const ABounds: TRect); virtual;
    procedure MouseEnter; dynamic;
    procedure MouseLeave; dynamic;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;
    function WantsMouse(X, Y: Integer): Boolean;

    property Item: TdxCustomLayoutItem read GetItem;
    property ItemViewInfo: TdxCustomLayoutItemViewInfo read FItemViewInfo;
    property LookAndFeel: TdxCustomLayoutLookAndFeel read GetLookAndFeel;
    property Pressed: Boolean read FPressed write FPressed;
    property Visible: Boolean read GetVisible;
  public
    Bounds: TRect;
    constructor Create(AItemViewInfo: TdxCustomLayoutItemViewInfo); virtual;
    procedure Calculate(const ABounds: TRect); virtual;
    function CalculateHeight: Integer; virtual; abstract;
    function CalculateWidth: Integer; virtual; abstract;

    property Enabled: Boolean read GetEnabled;
    property EnabledForWork: Boolean read GetEnabledForWork;
    property Height: Integer read GetHeight write SetHeight;
    property Width: Integer read GetWidth write SetWidth;
  end;

  TdxCustomLayoutItemCaptionViewInfoClass = class of TdxCustomLayoutItemCaptionViewInfo;

  TdxCustomLayoutItemCaptionViewInfo = class(TdxCustomLayoutItemElementViewInfo)
  private
    FHotTracked: Boolean;
    function GetCanvas: TcxCanvas;
    function GetIsCustomization: Boolean;
    function GetTextHeight: Integer;
    function GetTextWidth: Integer;
    procedure SetHotTracked(Value: Boolean);
  protected
    function GetCursor(X, Y: Integer): TCursor; override;
    function GetVisible: Boolean; override;
    procedure MouseLeave; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

    function CalculateTextFlags: Integer; virtual;
    function CanDoCaptionClick(X, Y: Integer): Boolean; virtual;
    function GetAlignHorz: TAlignment; virtual;
    function GetAlignVert: TdxAlignmentVert; virtual; abstract;
    function GetColor: TColor; virtual;
    function GetFont: TFont; virtual;
    function GetHotTrackBounds: TRect; virtual;
    function GetHotTrackStyles: TdxLayoutHotTrackStyles; virtual;
    function GetIsDefaultColor: Boolean; virtual;
    function GetIsHotTrackable: Boolean; virtual;
    function GetIsTextUnderlined: Boolean; virtual;
    function GetIsTransparent: Boolean; virtual;
    function GetMultiLine: Boolean; virtual; abstract;
    function GetOptions: TdxLayoutLookAndFeelCaptionOptions; virtual;
    function GetText: string; virtual;
    function GetTextAreaBounds: TRect; virtual;
    function GetTextColor: TColor; virtual;
    function GetTextHotColor: TColor; virtual;
    function GetTextNormalColor: TColor; virtual;
    function GetVisibleText: string; virtual;
    function IsPointInHotTrackBounds(const P: TPoint): Boolean; virtual;
    procedure PrepareCanvas; virtual;

    property AlignHorz: TAlignment read GetAlignHorz;
    property AlignVert: TdxAlignmentVert read GetAlignVert;
    property Canvas: TcxCanvas read GetCanvas;
    property HotTrackBounds: TRect read GetHotTrackBounds;
    property HotTrackStyles: TdxLayoutHotTrackStyles read GetHotTrackStyles;
    property IsCustomization: Boolean read GetIsCustomization;
    property IsDefaultColor: Boolean read GetIsDefaultColor;
    property IsHotTrackable: Boolean read GetIsHotTrackable;
    property IsTransparent: Boolean read GetIsTransparent;
    property MultiLine: Boolean read GetMultiLine;
    property Options: TdxLayoutLookAndFeelCaptionOptions read GetOptions;
    property TextHeight: Integer read GetTextHeight;
    property TextWidth: Integer read GetTextWidth;
  public
    function CalculateHeight: Integer; override;
    function CalculateWidth: Integer; override;

    property Color: TColor read GetColor;
    property Font: TFont read GetFont;
    property HotTracked: Boolean read FHotTracked write SetHotTracked;
    property IsTextUnderlined: Boolean read GetIsTextUnderlined;
    property Text: string read GetText;
    property TextAreaBounds: TRect read GetTextAreaBounds;
    property TextColor: TColor read GetTextColor;
    property VisibleText: string read GetVisibleText;
  end;

  TdxCustomLayoutItemViewInfo = class
  private
    FCaptionViewInfo: TdxCustomLayoutItemCaptionViewInfo;
    FContainerViewInfo: TdxLayoutControlViewInfo;
    FElementWithMouse: TdxCustomLayoutItemElementViewInfo;
    FItem: TdxCustomLayoutItem;
    FOffsets: array[TdxLayoutSide] of Integer;
    FParentViewInfo: TdxLayoutGroupViewInfo;

    function GetAlignHorz: TdxLayoutAlignHorz;
    function GetAlignVert: TdxLayoutAlignVert;
    function GetIsCustomization: Boolean;
    function GetIsParentLocked: Boolean;
    function GetLookAndFeel: TdxCustomLayoutLookAndFeel;
    function GetMinHeight: Integer;
    function GetMinWidth: Integer;
    function GetOffset(ASide: TdxLayoutSide): Integer;
    function GetOffsetsHeight: Integer;
    function GetOffsetsWidth: Integer;
    function GetSelected: Boolean;
    procedure SetElementWithMouse(Value: TdxCustomLayoutItemElementViewInfo);
    procedure SetOffset(ASide: TdxLayoutSide; Value: Integer);
  protected
    procedure CreateViewInfos; virtual;
    procedure DestroyViewInfos; virtual;

    function GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass; virtual; abstract;
    function GetHitTestClass: TdxCustomLayoutItemHitTestClass; virtual; abstract;
    function GetPainterClass: TdxCustomLayoutItemPainterClass; virtual; abstract;

    function CalculateMinHeight: Integer;
    function CalculateMinWidth: Integer;
    function CalculateOffset(ASide: TdxLayoutSide): Integer; virtual;
    function DoCalculateHeight(AIsMinHeight: Boolean = False): Integer; virtual;
    function DoCalculateWidth(AIsMinWidth: Boolean = False): Integer; virtual;
    function GetColor: TColor; virtual; abstract;
    function GetCursor(X, Y: Integer): TCursor; virtual;
    function GetElement(Index: Integer): TdxCustomLayoutItemElementViewInfo; virtual;
    function GetElementCount: Integer; virtual;
    function GetEnabled: Boolean; virtual;
    function GetEnabledForWork: Boolean; virtual;
    function GetIsDefaultColor: Boolean; virtual; abstract;
    function GetIsTransparent: Boolean; virtual;
    function GetOptions: TdxCustomLayoutLookAndFeelOptions; virtual; abstract;
    function GetSelectionAreaBounds(Index: Integer): TRect; virtual;
    function GetSelectionAreaCount: Integer; virtual;
    function HasCaption: Boolean; virtual;
    procedure MouseEnter; dynamic;
    procedure MouseLeave; dynamic;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); dynamic;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); dynamic;

    property ContainerViewInfo: TdxLayoutControlViewInfo read FContainerViewInfo;
    property ElementCount: Integer read GetElementCount;
    property Elements[Index: Integer]: TdxCustomLayoutItemElementViewInfo read GetElement;
    property ElementWithMouse: TdxCustomLayoutItemElementViewInfo read FElementWithMouse
      write SetElementWithMouse;
    property IsCustomization: Boolean read GetIsCustomization;
    property IsDefaultColor: Boolean read GetIsDefaultColor;
    property IsParentLocked: Boolean read GetIsParentLocked;
    property IsTransparent: Boolean read GetIsTransparent;
    property Item: TdxCustomLayoutItem read FItem;
    property LookAndFeel: TdxCustomLayoutLookAndFeel read GetLookAndFeel;
    property OffsetsHeight: Integer read GetOffsetsHeight;
    property OffsetsWidth: Integer read GetOffsetsWidth;
    property Options: TdxCustomLayoutLookAndFeelOptions read GetOptions;
    property ParentViewInfo: TdxLayoutGroupViewInfo read FParentViewInfo;
  public
    Bounds: TRect;
    constructor Create(AContainerViewInfo: TdxLayoutControlViewInfo;
      AParentViewInfo: TdxLayoutGroupViewInfo; AItem: TdxCustomLayoutItem); virtual;
    destructor Destroy; override;
    procedure Calculate(const ABounds: TRect); virtual;
    function CalculateHeight: Integer;
    function CalculateWidth: Integer;
    procedure CalculateTabOrders(var AAvailTabOrder: Integer); virtual; abstract;
    function GetHitTest(const P: TPoint): TdxCustomLayoutHitTest; virtual;
    procedure ResetOffset(ASide: TdxLayoutSide);

    property AlignHorz: TdxLayoutAlignHorz read GetAlignHorz;
    property AlignVert: TdxLayoutAlignVert read GetAlignVert;
    property CaptionViewInfo: TdxCustomLayoutItemCaptionViewInfo read FCaptionViewInfo;
    property Color: TColor read GetColor;
    property Enabled: Boolean read GetEnabled;
    property EnabledForWork: Boolean read GetEnabledForWork;
    property MinWidth: Integer read GetMinWidth;
    property MinHeight: Integer read GetMinHeight;
    property Offsets[ASide: TdxLayoutSide]: Integer read GetOffset write SetOffset;
    property Selected: Boolean read GetSelected;
    property SelectionAreaBounds[Index: Integer]: TRect read GetSelectionAreaBounds;
    property SelectionAreaCount: Integer read GetSelectionAreaCount;
  end;

  // item

  TdxLayoutItemCaptionViewInfo = class(TdxCustomLayoutItemCaptionViewInfo)
  private
    function GetItem: TdxLayoutItem;
    function GetItemViewInfo: TdxLayoutItemViewInfo;
  protected
    function GetAlignVert: TdxAlignmentVert; override;
    function GetIsFixedWidth: Boolean; virtual;
    function GetMinWidth: Integer; virtual;
    function GetMultiLine: Boolean; override;
    function GetTextAreaBounds: TRect; override;

    property IsFixedWidth: Boolean read GetIsFixedWidth;
    property Item: TdxLayoutItem read GetItem;
    property ItemViewInfo: TdxLayoutItemViewInfo read GetItemViewInfo;
  public
    function CalculateWidth: Integer; override;
    property MinWidth: Integer read GetMinWidth;
  end;

  TdxLayoutItemControlViewInfoClass = class of TdxLayoutItemControlViewInfo;

  TdxLayoutItemControlViewInfo = class(TdxCustomLayoutItemElementViewInfo)
  private
    FControlBounds: TRect;
    function GetBorderColor: TColor;
    function GetBorderStyle: TdxLayoutBorderStyle;
    function GetControl: TControl;
    function GetHasBorder: Boolean;
    function GetItem: TdxLayoutItem;
    function GetItemViewInfo: TdxLayoutItemViewInfo;
    function GetOpaqueControl: Boolean;
  protected
    function GetVisible: Boolean; override;

    function CalculateControlBounds: TRect; virtual;
    function GetBorderWidth(ASide: TdxLayoutSide): Integer; virtual;
    function GetHeight(AControlHeight: Integer): Integer; virtual;
    function GetWidth(AControlWidth: Integer): Integer; virtual;

    property BorderWidths[ASide: TdxLayoutSide]: Integer read GetBorderWidth;
    property Item: TdxLayoutItem read GetItem;
    property ItemViewInfo: TdxLayoutItemViewInfo read GetItemViewInfo;
  public
    procedure Calculate(const ABounds: TRect); override;
    function CalculateHeight: Integer; override;
    function CalculateWidth: Integer; override;
    function CalculateMinHeight: Integer; virtual;
    function CalculateMinWidth: Integer; virtual;
    procedure CalculateTabOrder(var AAvailTabOrder: Integer); virtual;

    property BorderColor: TColor read GetBorderColor;
    property BorderStyle: TdxLayoutBorderStyle read GetBorderStyle;
    property Control: TControl read GetControl;
    property ControlBounds: TRect read FControlBounds;
    property HasBorder: Boolean read GetHasBorder;
    property OpaqueControl: Boolean read GetOpaqueControl;
  end;

  TdxLayoutItemViewInfo = class(TdxCustomLayoutItemViewInfo)
  private
    FControlViewInfo: TdxLayoutItemControlViewInfo;
    function GetCaptionViewInfo: TdxLayoutItemCaptionViewInfo;
    function GetItem: TdxLayoutItem;
    function GetOptionsEx: TdxLayoutLookAndFeelItemOptions;
  protected
    procedure CreateViewInfos; override;
    procedure DestroyViewInfos; override;

    function GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass; override;
    function GetControlViewInfoClass: TdxLayoutItemControlViewInfoClass; virtual;
    function GetHitTestClass: TdxCustomLayoutItemHitTestClass; override;
    function GetPainterClass: TdxCustomLayoutItemPainterClass; override;

    procedure CalculateViewInfosBounds(var ACaptionBounds, AControlBounds: TRect); virtual;
    function DoCalculateHeight(AIsMinHeight: Boolean = False): Integer; override;
    function DoCalculateWidth(AIsMinWidth: Boolean = False): Integer; override;
    function GetAutoControlAlignment: Boolean; virtual;
    function GetCaptionLayout: TdxCaptionLayout; virtual;
    function GetColor: TColor; override;
    function GetContentBounds: TRect; virtual;
    function GetControlOffsetHorz: Integer; virtual;
    function GetControlOffsetVert: Integer; virtual;
    function GetElement(Index: Integer): TdxCustomLayoutItemElementViewInfo; override;
    function GetElementCount: Integer; override;
    function GetIsDefaultColor: Boolean; override;
    function GetOptions: TdxCustomLayoutLookAndFeelOptions; override;
    function HasControl: Boolean; virtual;

    property ControlOffsetHorz: Integer read GetControlOffsetHorz;
    property ControlOffsetVert: Integer read GetControlOffsetVert;
    property Item: TdxLayoutItem read GetItem;
    property Options: TdxLayoutLookAndFeelItemOptions read GetOptionsEx;
  public
    procedure Calculate(const ABounds: TRect); override;
    procedure CalculateTabOrders(var AAvailTabOrder: Integer); override;

    property AutoControlAlignment: Boolean read GetAutoControlAlignment;
    property CaptionLayout: TdxCaptionLayout read GetCaptionLayout;
    property CaptionViewInfo: TdxLayoutItemCaptionViewInfo read GetCaptionViewInfo;
    property ContentBounds: TRect read GetContentBounds;
    property ControlViewInfo: TdxLayoutItemControlViewInfo read FControlViewInfo;
  end;

  // group

  TdxLayoutGroupCaptionViewInfo = class(TdxCustomLayoutItemCaptionViewInfo)
  protected
    function GetAlignVert: TdxAlignmentVert; override;
    function GetMultiLine: Boolean; override;

    function GetMinWidth: Integer; virtual;
  public
    property MinWidth: Integer read GetMinWidth;
  end;

  TdxLayoutGroupViewInfoGetItemSizeEvent =
    function(AViewInfo: TdxCustomLayoutItemViewInfo): Integer of object;

  TdxLayoutGroupViewInfoSpecificClass = class of TdxLayoutGroupViewInfoSpecific;

  TdxLayoutGroupViewInfoSpecific = class
  private
    FGroupViewInfo: TdxLayoutGroupViewInfo;
    function GetItemOffset: Integer;
    function GetItemViewInfo(Index: Integer): TdxCustomLayoutItemViewInfo;
    function GetItemViewInfoCount: Integer;
    function GetLayoutDirection: TdxLayoutDirection;
  protected
    function DoCalculateHeight: Integer;
    function DoCalculateWidth: Integer;
    function DoCalculateMinHeight: Integer;
    function DoCalculateMinWidth: Integer;
    function GetCustomHeight(AGetItemCustomHeight: TdxLayoutGroupViewInfoGetItemSizeEvent): Integer;
    function GetCustomWidth(AGetItemCustomWidth: TdxLayoutGroupViewInfoGetItemSizeEvent): Integer;

    procedure ConvertCoords(var R: TRect); virtual;
    function GetItemAlignHorz(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignHorz; virtual; abstract;
    function GetItemAlignVert(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignVert; virtual; abstract;
    function GetItemHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; virtual; abstract;
    function GetItemMinHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; virtual; abstract;
    function GetItemMinWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; virtual; abstract;
    function GetItemWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; virtual; abstract;

    property GroupViewInfo: TdxLayoutGroupViewInfo read FGroupViewInfo;
    property ItemOffset: Integer read GetItemOffset;
    property ItemViewInfoCount: Integer read GetItemViewInfoCount;
    property ItemViewInfos[Index: Integer]: TdxCustomLayoutItemViewInfo read GetItemViewInfo;
    property LayoutDirection: TdxLayoutDirection read GetLayoutDirection;
  public
    constructor Create(AGroupViewInfo: TdxLayoutGroupViewInfo); virtual;
    procedure CalculateItemsBounds(AItemsAreaBounds: TRect);
    function CalculateHeight(AIsMinHeight: Boolean = False): Integer; virtual;
    function CalculateWidth(AIsMinWidth: Boolean = False): Integer; virtual;
    function IsAtInsertionPos(const R: TRect; const P: TPoint): Boolean; virtual; abstract;
  end;

  TdxLayoutGroupViewInfoHorizontalSpecific = class(TdxLayoutGroupViewInfoSpecific)
  protected
    function GetItemAlignHorz(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignHorz; override;
    function GetItemAlignVert(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignVert; override;
    function GetItemHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; override;
    function GetItemMinHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; override;
    function GetItemMinWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; override;
    function GetItemWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; override;
  public
    function IsAtInsertionPos(const R: TRect; const P: TPoint): Boolean; override;
  end;

  TdxLayoutGroupViewInfoVerticalSpecific = class(TdxLayoutGroupViewInfoSpecific)
  protected
    procedure ConvertCoords(var R: TRect); override;
    function GetItemAlignHorz(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignHorz; override;
    function GetItemAlignVert(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignVert; override;
    function GetItemHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; override;
    function GetItemMinHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; override;
    function GetItemMinWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; override;
    function GetItemWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer; override;
  public
    function CalculateHeight(AIsMinHeight: Boolean = False): Integer; override;
    function CalculateWidth(AIsMinWidth: Boolean = False): Integer; override;
    function IsAtInsertionPos(const R: TRect; const P: TPoint): Boolean; override;
  end;

  TdxLayoutGroupViewInfo = class(TdxCustomLayoutItemViewInfo)
  private
    FConstsCalculated: Boolean;
    FItemOffset: Integer;
    FItemsAreaBounds: TRect;
    FItemsAreaOffsetHorz: Integer;
    FItemsAreaOffsetVert: Integer;
    FItemViewInfos: TList;
    FSpecific: TdxLayoutGroupViewInfoSpecific;

    function GetBorderBounds(ASide: TdxLayoutSide): TRect;
    function GetBorderRestSpaceBounds(ASide: TdxLayoutSide): TRect;
    function GetBordersHeight: Integer;
    function GetBordersWidth: Integer;
    function GetCaptionViewInfo: TdxLayoutGroupCaptionViewInfo;
    function GetGroup: TdxLayoutGroup;
    function GetIsLocked: Boolean;
    function GetItemViewInfo(Index: Integer): TdxCustomLayoutItemViewInfo;
    function GetItemViewInfoCount: Integer;
    function GetLayoutDirection: TdxLayoutDirection;
    function GetOptionsEx: TdxLayoutLookAndFeelGroupOptions;

    procedure CreateItemViewInfos;
    procedure CreateSpecific;
    procedure DestroyItemViewInfos;
    procedure DestroySpecific;
  protected
    function GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass; override;
    function GetHitTestClass: TdxCustomLayoutItemHitTestClass; override;
    function GetPainterClass: TdxCustomLayoutItemPainterClass; override;

    function DoCalculateHeight(AIsMinHeight: Boolean = False): Integer; override;
    function DoCalculateWidth(AIsMinWidth: Boolean = False): Integer; override;

    function CalculateCaptionViewInfoBounds: TRect; virtual;
    function CalculateItemsAreaBounds: TRect; virtual;
    procedure CalculateConsts; virtual;
    function GetBorderWidth(ASide: TdxLayoutSide): Integer; virtual;
    function GetClientBounds: TRect; virtual;
    function GetColor: TColor; override;
    function GetConst(Index: Integer): Integer; virtual;
    function GetHeight(AItemsAreaHeight: Integer): Integer; virtual;
    function GetIsDefaultColor: Boolean; override;
    function GetItemViewInfoClass(AItem: TdxCustomLayoutItem): TdxCustomLayoutItemViewInfoClass; virtual;
    function GetMinVisibleWidth: Integer; virtual;
    function GetOptions: TdxCustomLayoutLookAndFeelOptions; override;
    function GetRestSpaceBounds: TRect; virtual;
    function GetSpecificClass: TdxLayoutGroupViewInfoSpecificClass; virtual;
    function GetWidth(AItemsAreaWidth: Integer): Integer; virtual;
    function HasBorder: Boolean; virtual;
    function HasBoundsFrame: Boolean; virtual;
    function UseItemOffset: Boolean; virtual;
    function UseItemsAreaOffsets: Boolean; virtual;

    property ItemOffset: Integer index 2 read GetConst write FItemOffset;
    property ItemsAreaOffsetHorz: Integer index 3 read GetConst write FItemsAreaOffsetHorz;
    property ItemsAreaOffsetVert: Integer index 4 read GetConst write FItemsAreaOffsetVert;
    property MinVisibleWidth: Integer read GetMinVisibleWidth;
    property RestSpaceBounds: TRect read GetRestSpaceBounds;

    property Group: TdxLayoutGroup read GetGroup;
    property LayoutDirection: TdxLayoutDirection read GetLayoutDirection;
    property Options: TdxLayoutLookAndFeelGroupOptions read GetOptionsEx;
    property Specific: TdxLayoutGroupViewInfoSpecific read FSpecific;
  public
    constructor Create(AControlViewInfo: TdxLayoutControlViewInfo;
      AParentViewInfo: TdxLayoutGroupViewInfo; AItem: TdxCustomLayoutItem); override;
    destructor Destroy; override;
    procedure Calculate(const ABounds: TRect); override;
    procedure CalculateTabOrders(var AAvailTabOrder: Integer); override;
    function GetHitTest(const P: TPoint): TdxCustomLayoutHitTest; override;
    function GetInsertionPos(const P: TPoint): Integer; virtual;

    property BorderBounds[ASide: TdxLayoutSide]: TRect read GetBorderBounds;
    property BorderRestSpaceBounds[ASide: TdxLayoutSide]: TRect read GetBorderRestSpaceBounds;
    property BorderWidths[ASide: TdxLayoutSide]: Integer read GetBorderWidth;
    property BordersHeight: Integer read GetBordersHeight;
    property BordersWidth: Integer read GetBordersWidth;
    property CaptionViewInfo: TdxLayoutGroupCaptionViewInfo read GetCaptionViewInfo;
    property ClientBounds: TRect read GetClientBounds;
    property IsLocked: Boolean read GetIsLocked;
    property ItemsAreaBounds: TRect read FItemsAreaBounds;
    property ItemViewInfoCount: Integer read GetItemViewInfoCount;
    property ItemViewInfos[Index: Integer]: TdxCustomLayoutItemViewInfo read GetItemViewInfo;
  end;

  // standard

  TdxLayoutGroupStandardCaptionViewInfo = class(TdxLayoutGroupCaptionViewInfo)
  private
    function GetItemViewInfo: TdxLayoutGroupStandardViewInfo;
  protected
    function GetAlignHorz: TAlignment; override;
    property ItemViewInfo: TdxLayoutGroupStandardViewInfo read GetItemViewInfo;
  public
    function CalculateWidth: Integer; override;
  end;

  TdxLayoutGroupStandardViewInfo = class(TdxLayoutGroupViewInfo)
  private
    function GetLookAndFeel: TdxLayoutStandardLookAndFeel;
  protected
    function CalculateCaptionViewInfoBounds: TRect; override;
    function GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass; override;
    function GetMinVisibleWidth: Integer; override;

    function GetCaptionViewInfoOffset: Integer; virtual;
    function GetFrameBounds: TRect; virtual;

    property CaptionViewInfoOffset: Integer read GetCaptionViewInfoOffset;
    property LookAndFeel: TdxLayoutStandardLookAndFeel read GetLookAndFeel;
  public
    property FrameBounds: TRect read GetFrameBounds;
  end;

  // office

  TdxLayoutGroupOfficeCaptionViewInfo = class(TdxLayoutGroupCaptionViewInfo)
  public
    function CalculateWidth: Integer; override;
  end;

  TdxLayoutGroupOfficeViewInfo = class(TdxLayoutGroupStandardViewInfo)
  protected
    function GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass; override;
    function GetCaptionViewInfoOffset: Integer; override;
    function GetFrameBounds: TRect; override;
    function GetMinVisibleWidth: Integer; override;
  end;

  // web

  TdxLayoutGroupWebCaptionViewInfo = class(TdxLayoutGroupCaptionViewInfo)
  private
    function GetItemViewInfo: TdxLayoutGroupWebViewInfo;
    function GetLookAndFeel: TdxLayoutWebLookAndFeel;
    function GetOptionsEx: TdxLayoutWebLookAndFeelGroupCaptionOptions;
    function GetSeparatorWidth: Integer;
  protected
    function GetAlignVert: TdxAlignmentVert; override;
    function GetColor: TColor; override;
    function GetIsDefaultColor: Boolean; override;
    function GetMinWidth: Integer; override;
    function GetTextAreaBounds: TRect; override;

    function GetTextOffset: Integer; virtual;

    property ItemViewInfo: TdxLayoutGroupWebViewInfo read GetItemViewInfo;
    property LookAndFeel: TdxLayoutWebLookAndFeel read GetLookAndFeel;
    property Options: TdxLayoutWebLookAndFeelGroupCaptionOptions read GetOptionsEx;
    property TextOffset: Integer read GetTextOffset;
  public
    function CalculateHeight: Integer; override;
    property SeparatorWidth: Integer read GetSeparatorWidth;
  end;

  TdxLayoutGroupWebViewInfo = class(TdxLayoutGroupViewInfo)
  private
    function GetCaptionViewInfo: TdxLayoutGroupWebCaptionViewInfo;
    function GetInsideFrameBounds: TRect;
    function GetLookAndFeel: TdxLayoutWebLookAndFeel;
    function GetOptionsEx: TdxLayoutWebLookAndFeelGroupOptions;
  protected
    function CalculateCaptionViewInfoBounds: TRect; override;
    function GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass; override;
    function GetMinVisibleWidth: Integer; override;
    function GetRestSpaceBounds: TRect; override;

    function GetCaptionSeparatorAreaBounds: TRect; virtual;
    function GetCaptionSeparatorBounds: TRect; virtual;

    property LookAndFeel: TdxLayoutWebLookAndFeel read GetLookAndFeel;
    property InsideFrameBounds: TRect read GetInsideFrameBounds;
    property Options: TdxLayoutWebLookAndFeelGroupOptions read GetOptionsEx;
  public
    property CaptionSeparatorAreaBounds: TRect read GetCaptionSeparatorAreaBounds;
    property CaptionSeparatorBounds: TRect read GetCaptionSeparatorBounds;
    property CaptionViewInfo: TdxLayoutGroupWebCaptionViewInfo read GetCaptionViewInfo;
  end;

  // control

  TdxLayoutControlViewInfo = class(TdxCustomLayoutControlHandler)
  private
    FCanvas: TcxCanvas;
    FContentBounds: TRect;
    FHideHiddenGroupsFromHitTest: Boolean;
    FItemsViewInfo: TdxLayoutGroupViewInfo;
    function GetClientHeight: Integer;
    function GetClientWidth: Integer;
    function GetContentHeight: Integer;
    function GetContentWidth: Integer;
    function GetLookAndFeel: TdxCustomLayoutLookAndFeel;
  protected
    procedure CreateViewInfos; virtual;
    procedure DestroyViewInfos; virtual;
    function GetItemsViewInfoClass: TdxLayoutGroupViewInfoClass; virtual;
    procedure RecreateViewInfos;

    procedure AlignItems; virtual;
    procedure AutoAlignControls; virtual;
    procedure CalculateItemsViewInfo; virtual;
    procedure CalculateTabOrders; virtual;
    function GetIsTransparent: Boolean; virtual;
    function HasBackground: Boolean;
    procedure PrepareData; virtual;
    procedure ResetContentBounds;

    function GetCanvas: TcxCanvas; virtual;
    function GetClientBounds: TRect; virtual;
    function GetContentBounds: TRect; virtual;

    property Canvas: TcxCanvas read GetCanvas;
    property IsTransparent: Boolean read GetIsTransparent;
  public
    constructor Create(AControl: TdxCustomLayoutControl); override;
    destructor Destroy; override;
    procedure Calculate; virtual;
    procedure DoCalculateTabOrders; virtual;
    function GetHitTest(const P: TPoint): TdxCustomLayoutHitTest; overload; virtual;
    function GetHitTest(X, Y: Integer): TdxCustomLayoutHitTest; overload;

    property ClientBounds: TRect read GetClientBounds;
    property ClientHeight: Integer read GetClientHeight;
    property ClientWidth: Integer read GetClientWidth;
    property ContentBounds: TRect read GetContentBounds;
    property ContentHeight: Integer read GetContentHeight;
    property ContentWidth: Integer read GetContentWidth;
    property HideHiddenGroupsFromHitTest: Boolean read FHideHiddenGroupsFromHitTest
      write FHideHiddenGroupsFromHitTest;
    property ItemsViewInfo: TdxLayoutGroupViewInfo read FItemsViewInfo;
    property LookAndFeel: TdxCustomLayoutLookAndFeel read GetLookAndFeel;
  end;

  { other }

  TdxLayoutCustomizeListBox = class(TcxCustomizeListBox)
  private
    FControl: TdxCustomLayoutControl;
    function GetDragAndDropItemObject: TdxCustomLayoutItem;
  protected
    procedure BeginDragAndDrop; override;
    property DragAndDropItemObject: TdxCustomLayoutItem read GetDragAndDropItemObject;
  public
    property Control: TdxCustomLayoutControl read FControl write FControl;
  end;

implementation

{$R *.res}

uses
  TypInfo, Menus, Registry,
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
{$IFDEF DELPHI7}
  UxTheme, Themes,
{$ENDIF}
  dxLayoutControlAdapters, dxLayoutCustomizeForm;

const
  ScrollStep = 10;

type
  TControlAccess = class(TControl);
  TLookAndFeelAccess = class(TdxCustomLayoutLookAndFeel);

resourcestring
  sContainerCannotBeControl = 'Container cannot be a control for its item.';
  sControlIsUsed = 'The %s control is already used by %s item.';

function GetOrthogonalDirection(ADirection: TdxLayoutDirection): TdxLayoutDirection;
begin
  if ADirection = ldHorizontal then
    Result := ldVertical
  else
    Result := ldHorizontal;
end;

{ TCustomizationCanvas }

type
  TCustomizationCanvas = class(TCanvas)
  private
    FControl: TcxControl;
    procedure FreeHandle;
  protected
    procedure CreateHandle; override;
  public
    constructor Create(AControl: TcxControl); reintroduce;
    destructor Destroy; override;
  end;

constructor TCustomizationCanvas.Create(AControl: TcxControl);
begin
  inherited Create;
  FControl := AControl;
end;

destructor TCustomizationCanvas.Destroy;
begin
  FreeHandle;
  inherited;
end;

procedure TCustomizationCanvas.FreeHandle;
begin
  ReleaseDC(FControl.Handle, Handle);
  Handle := 0;
end;

procedure TCustomizationCanvas.CreateHandle;
begin
  Handle := GetDCEx(FControl.Handle, 0, DCX_CACHE or DCX_CLIPSIBLINGS);
end;

{ TcxCustomizationCanvas }

type
  TcxCustomizationCanvas = class(TcxCanvas)
  public
    constructor Create(AControl: TcxControl); reintroduce;
    destructor Destroy; override;
  end;

constructor TcxCustomizationCanvas.Create(AControl: TcxControl);
begin
  inherited Create(TCustomizationCanvas.Create(AControl));
end;

destructor TcxCustomizationCanvas.Destroy;
begin
  Canvas.Free;
  inherited;
end;

{ TdxCustomLayoutItemOptions }

constructor TdxCustomLayoutItemOptions.Create(AItem: TdxCustomLayoutItem);
begin
  inherited Create;
  FItem := AItem;
end;

procedure TdxCustomLayoutItemOptions.Changed;
begin
  FItem.Changed;
end;

{ TdxCustomLayoutItemCaptionOptions }

constructor TdxCustomLayoutItemCaptionOptions.Create(AItem: TdxCustomLayoutItem);
begin
  inherited;
  FShowAccelChar := True;
end;

procedure TdxCustomLayoutItemCaptionOptions.SetAlignHorz(Value: TAlignment);
begin
  if FAlignHorz <> Value then
  begin
    FAlignHorz := Value;
    Changed;
  end;
end;

procedure TdxCustomLayoutItemCaptionOptions.SetShowAccelChar(Value: Boolean);
begin
  if FShowAccelChar <> Value then
  begin
    FShowAccelChar := Value;
    Changed;
  end;
end;

{ TdxLayoutOffsets }

function TdxLayoutOffsets.GetValue(Index: Integer): Integer;
begin
  case Index of
    1: Result := FBottom;
    2: Result := FLeft;
    3: Result := FRight;
    4: Result := FTop;
  else
    Result := 0;
  end;
end;

procedure TdxLayoutOffsets.SetValue(Index: Integer; Value: Integer);
begin
  if Value < 0 then Value := 0;
  if GetValue(Index) <> Value then
  begin
    case Index of
      1: FBottom := Value;
      2: FLeft := Value;
      3: FRight := Value;
      4: FTop := Value;
    end;
    Changed;
  end;
end;

{ TdxCustomLayoutItem }

constructor TdxCustomLayoutItem.Create(AOwner: TComponent);
begin
  inherited;
  FAllowRemove := True;
  FAutoAligns := [aaHorizontal, aaVertical];
  FCaptionOptions := GetCaptionOptionsClass.Create(Self);
  FEnabled := True;
  FOffsets := TdxLayoutOffsets.Create(Self);
  FShowCaption := True;
  FVisible := True;
end;

destructor TdxCustomLayoutItem.Destroy;
begin
  HasMouse := False;
  Parent := nil;
  FContainer.RemoveAvailableItem(Self);
  FContainer.RemoveAbsoluteItem(Self);
  LookAndFeel := nil;
  FOffsets.Free;
  FCaptionOptions.Free;
  inherited;
end;

function TdxCustomLayoutItem.GetActuallyVisible: Boolean;
begin
  Result := GetVisible and (IsRoot or (FParent <> nil) and FParent.ActuallyVisible);
end;

function TdxCustomLayoutItem.GetAlignHorz: TdxLayoutAlignHorz;
begin
  if aaHorizontal in FAutoAligns then
    Result := GetAutoAlignHorz
  else
    Result := FAlignHorz;
end;

function TdxCustomLayoutItem.GetAlignVert: TdxLayoutAlignVert;
begin
  if aaVertical in FAutoAligns then
    Result := GetAutoAlignVert
  else
    Result := FAlignVert;
end;

function TdxCustomLayoutItem.GetCaptionForCustomizeForm: string;
begin
  Result := StripHotKey(FCaption);
end;

function TdxCustomLayoutItem.GetHasMouse: Boolean;
begin
  Result := FContainer.ItemWithMouse = Self;
end;

function TdxCustomLayoutItem.GetIndex: Integer;
begin
  if FParent = nil then
    Result := -1
  else
    Result := FParent.IndexOf(Self);
end;

function TdxCustomLayoutItem.GetIsDesigning: Boolean;
begin
  Result := csDesigning in ComponentState;
end;

function TdxCustomLayoutItem.GetIsDestroying: Boolean;
begin
  Result := csDestroying in ComponentState;
end;

function TdxCustomLayoutItem.GetIsLoading: Boolean;
begin
  Result := csLoading in ComponentState;
end;

function TdxCustomLayoutItem.GetIsRoot: Boolean;
begin
  Result := (FContainer <> nil) and (FContainer.Items = Self);
end;

function TdxCustomLayoutItem.GetVisibleIndex: Integer;
begin
  if FParent = nil then
    Result := -1
  else
    Result := FParent.VisibleIndexOf(Self);
end;

procedure TdxCustomLayoutItem.SetAlignHorz(Value: TdxLayoutAlignHorz);
begin
  if AlignHorz <> Value then
  begin
    FAlignHorz := Value;
    Exclude(FAutoAligns, aaHorizontal);
    Changed;
  end;
end;

procedure TdxCustomLayoutItem.SetAlignmentConstraint(Value: TdxLayoutAlignmentConstraint);
begin
  if FAlignmentConstraint <> Value then
  begin
    if FAlignmentConstraint <> nil then
      FAlignmentConstraint.RemoveItem(Self);
    if Value <> nil then
      Value.AddItem(Self);
  end;
end;

procedure TdxCustomLayoutItem.SetAlignVert(Value: TdxLayoutAlignVert);
begin
  if AlignVert <> Value then
  begin
    FAlignVert := Value;
    Exclude(FAutoAligns, aaVertical);
    Changed;
  end;
end;

procedure TdxCustomLayoutItem.SetAutoAligns(Value: TdxLayoutAutoAligns);
begin
  if FAutoAligns <> Value then
  begin
    FAutoAligns := Value;
    Changed;
  end;
end;

procedure TdxCustomLayoutItem.SetCaption(const Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    ResetCachedTextHeight;
    Changed;
  end;
end;

procedure TdxCustomLayoutItem.SetContainer(Value: TdxCustomLayoutControl);
begin
  if FContainer <> Value then
  begin
    if not IsRoot and (FContainer <> nil) then
      FContainer.RemoveAbsoluteItem(Self);
    FContainer := Value;
    if not IsRoot then
    begin
      if FContainer <> nil then
        FContainer.AddAbsoluteItem(Self);
      SetComponentName(Self, GetBaseName, IsDesigning, IsLoading);
    end
    else
      Name := GetValidName(Self, GetBaseName + '_Root');
  end;    
end;

procedure TdxCustomLayoutItem.SetEnabled(Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    EnabledChanged;
  end;
end;

procedure TdxCustomLayoutItem.SetLookAndFeel(Value: TdxCustomLayoutLookAndFeel);
begin
  if FLookAndFeel <> Value then
  begin
    if FLookAndFeel <> nil then
      FLookAndFeel.RemoveUser(Self);
    FLookAndFeel := Value;
    if FLookAndFeel <> nil then
      FLookAndFeel.AddUser(Self);
    LookAndFeelChangedImpl;
  end;
end;

procedure TdxCustomLayoutItem.SetHasMouse(Value: Boolean);
begin
  if HasMouse <> Value then
    if Value then
      FContainer.ItemWithMouse := Self
    else
      FContainer.ItemWithMouse := nil;
end;

procedure TdxCustomLayoutItem.SetIndex(Value: Integer);
begin
  if FParent <> nil then
    FParent.ChangeItemIndex(Self, Value);
end;

procedure TdxCustomLayoutItem.SetParent(Value: TdxLayoutGroup);
var
  APrevParent: TdxLayoutGroup;
  APrevActuallyVisible: Boolean;
begin
  if (FParent <> Value) and CanMoveTo(Value) then
  begin
    APrevParent := FParent;
    APrevActuallyVisible := ActuallyVisible;
    if FParent <> nil then
      FParent.RemoveItem(Self)
    else
      if FContainer <> nil then
        FContainer.RemoveAvailableItem(Self);
    if Value <> nil then
      Value.AddItem(Self)
    else
      FContainer.AddAvailableItem(Self);
    CheckActuallyVisible(APrevActuallyVisible);
    ParentChanged(APrevParent);
  end;
end;

procedure TdxCustomLayoutItem.SetShowCaption(Value: Boolean);
begin
  if FShowCaption <> Value then
  begin
    FShowCaption := Value;
    Changed;
  end;
end;

procedure TdxCustomLayoutItem.SetVisible(Value: Boolean);
var
  APrevActuallyVisible: Boolean;
begin
  if FVisible <> Value then
  begin
    APrevActuallyVisible := ActuallyVisible;
    FVisible := Value;
    FContainer.BeginUpdate;
    try
      VisibleChanged;
      CheckActuallyVisible(APrevActuallyVisible);
    finally
      FContainer.EndUpdate;
    end;
  end;
end;

procedure TdxCustomLayoutItem.SetVisibleIndex(Value: Integer);
begin
  if FParent <> nil then
    FParent.ChangeItemVisibleIndex(Self, Value);
end;

procedure TdxCustomLayoutItem.CheckActuallyVisible(APrevActuallyVisible: Boolean);
begin
  if not IsDestroying and (ActuallyVisible <> APrevActuallyVisible) then
    ActuallyVisibleChanged;
end;

function TdxCustomLayoutItem.IsAlignHorzStored: Boolean;
begin
  Result := not (aaHorizontal in FAutoAligns) and (FAlignHorz <> ahLeft);
end;

function TdxCustomLayoutItem.IsAlignVertStored: Boolean;
begin
  Result := not (aaVertical in FAutoAligns) and (FAlignVert <> avTop);
end;

procedure TdxCustomLayoutItem.SetName(const Value: TComponentName);
begin
  inherited;
  if IsDesigning and not IsRoot then
    dxLayoutDesigner.ItemsChanged(FContainer);
end;

procedure TdxCustomLayoutItem.SetParentComponent(Value: TComponent);
begin
  inherited;
  if Value is TdxLayoutGroup then
    Parent := TdxLayoutGroup(Value)
  else
    if Value is TdxCustomLayoutControl then
      TdxCustomLayoutControl(Value).AddAvailableItem(Self);
end;

procedure TdxCustomLayoutItem.LookAndFeelChanged;
begin
end;

procedure TdxCustomLayoutItem.LookAndFeelChanging;
begin
  ResetCachedTextHeight;
end;

procedure TdxCustomLayoutItem.BeginLookAndFeelDestroying;
begin
  FContainer.BeginUpdate;
end;

procedure TdxCustomLayoutItem.EndLookAndFeelDestroying;
begin
  FContainer.EndUpdate;
end;

procedure TdxCustomLayoutItem.LookAndFeelChangedImpl;
begin
  if IsDestroying or not ActuallyVisible then Exit;
  LookAndFeelChanging;
  Changed;
  LookAndFeelChanged;
end;

procedure TdxCustomLayoutItem.LookAndFeelDestroyed;
begin
  LookAndFeel := nil;
end;

procedure TdxCustomLayoutItem.ActuallyVisibleChanged;
begin
  if not ActuallyVisible then HasMouse := False;
  LookAndFeelChangedImpl;
  if IsDesigning then
    dxLayoutDesigner.ItemsChanged(FContainer);
end;

function TdxCustomLayoutItem.CanRemove: Boolean;
begin
  Result := FAllowRemove;
end;

procedure TdxCustomLayoutItem.DoCaptionClick;
begin
  if Assigned(FOnCaptionClick) then FOnCaptionClick(Self);
end;

function TdxCustomLayoutItem.DoProcessAccel: Boolean;
var
  AItem: TdxCustomLayoutItem;
begin
  Result := CanProcessAccel(AItem);
  if Result then AItem.ProcessAccel;
end;

procedure TdxCustomLayoutItem.EnabledChanged;
begin
  Changed(False);
end;

function TdxCustomLayoutItem.GetBaseName: string;
begin
  Result := FContainer.Name;
end;

function TdxCustomLayoutItem.GetCursor(X, Y: Integer): TCursor;
begin
  Result := ViewInfo.GetCursor(X, Y);
end;

function TdxCustomLayoutItem.GetEnabledForWork: Boolean;
begin
  Result := FEnabled and ((FParent = nil) or FParent.EnabledForWork);
end;

function TdxCustomLayoutItem.GetLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  Result := FLookAndFeel;
  if Result = nil then
    if FParent <> nil then
      Result := FParent.GetLookAndFeelAsParent
    else
      if IsRoot then
        Result := FContainer.GetLookAndFeel;
end;

function TdxCustomLayoutItem.GetShowCaption: Boolean;
begin
  Result := FShowCaption;
end;

function TdxCustomLayoutItem.GetVisible: Boolean;
begin
  Result := FVisible or IsDesigning;
end;

function TdxCustomLayoutItem.HasAsParent(AGroup: TdxLayoutGroup): Boolean;
var
  AParent: TdxLayoutGroup;
begin
  AParent := FParent;
  repeat
    Result := AParent = AGroup;
    if Result or (AParent = nil) then Break;
    AParent := AParent.Parent;
  until False;
end;

function TdxCustomLayoutItem.HasCaption: Boolean;
begin
  Result := ShowCaption;
end;

procedure TdxCustomLayoutItem.Init;
begin
  if GetLookAndFeel <> nil then LookAndFeelChanged;
end;

procedure TdxCustomLayoutItem.MouseEnter;
begin
  ViewInfo.MouseEnter;
end;

procedure TdxCustomLayoutItem.MouseLeave;
begin
  if FViewInfo <> nil then FViewInfo.MouseLeave;
end;

procedure TdxCustomLayoutItem.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  ViewInfo.MouseDown(Button, Shift, X, Y);
  if IsDesigning and not IsRoot then
    dxLayoutDesigner.SelectComponent(Container, Self,
      (ssShift in Shift) and Container.CanMultiSelect);
end;

procedure TdxCustomLayoutItem.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  ViewInfo.MouseMove(Shift, X, Y);
end;

procedure TdxCustomLayoutItem.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  ViewInfo.MouseUp(Button, Shift, X, Y);
end;

procedure TdxCustomLayoutItem.ParentChanged(APrevParent: TdxLayoutGroup);
begin
  if not IsLoading and (APrevParent <> nil) and not APrevParent.IsDestroying then
    FContainer.Items.Pack;
end;

procedure TdxCustomLayoutItem.ProcessAccel;
begin
end;

function TdxCustomLayoutItem.ProcessDialogChar(ACharCode: Word): Boolean;
begin
  Result := HasCaption and FCaptionOptions.ShowAccelChar and
    IsAccel(ACharCode, Caption) and DoProcessAccel;
end;

procedure TdxCustomLayoutItem.SelectionChanged;
var
  I: Integer;
  R: TRect;
begin
  if ViewInfo <> nil then
    for I := 0 to ViewInfo.SelectionAreaCount - 1 do
    begin
      R := ViewInfo.SelectionAreaBounds[I];
      RedrawWindow(FContainer.Handle, @R, 0,
        RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
    end;  
end;

procedure TdxCustomLayoutItem.VisibleChanged;
begin
  if FParent <> nil then
    with FParent do
    begin
      BuildVisibleItemsList;
      Changed;
    end;
end;

function TdxCustomLayoutItem.GetCaptionOptionsClass: TdxCustomLayoutItemCaptionOptionsClass;
begin
  Result := TdxCustomLayoutItemCaptionOptions;
end;

procedure TdxCustomLayoutItem.ResetCachedTextHeight;
begin
  FCachedTextHeight := 0;
end;

procedure TdxCustomLayoutItem.BeforeDestruction;
begin
  inherited;
  Container.FinishDragAndDrop(False);
  AlignmentConstraint := nil;
end;

function TdxCustomLayoutItem.GetParentComponent: TComponent;
begin
  if FParent = nil then
    Result := FContainer
  else
    Result := FParent;
end;

function TdxCustomLayoutItem.HasParent: Boolean;
begin
  Result := True;
end;

procedure TdxCustomLayoutItem.Changed(AHardRefresh: Boolean = True);
begin
  if Container.IsLoading or Container.IsDestroying or
    Container.IsUpdateLocked or not ActuallyVisible then Exit;
  if AHardRefresh then
  begin
    Container.ViewInfo.Calculate;
    Container.Invalidate;
  end
  else
    if ViewInfo <> nil then
      Container.InvalidateRect(ViewInfo.Bounds, False);
end;

function TdxCustomLayoutItem.CanMoveTo(AParent: TdxCustomLayoutItem): Boolean;
begin
  Result := AParent <> Self;
end;

procedure TdxCustomLayoutItem.MakeVisible;
var
  R, AClientR: TRect;

  procedure MakeVisibleInOneDirection(AItemMin, AItemMax,
    AClientMin, AClientMax: Integer; AIsHorizontal: Boolean);
  var
    AOffset: Integer;

    procedure ChangeOffset(ADelta: Integer);
    begin
      Inc(AOffset, ADelta);
      Dec(AItemMin, ADelta);
      Dec(AItemMax, ADelta);
    end;

    procedure ApplyOffset;
    begin
      with FContainer do
        if AIsHorizontal then
          LeftPos := LeftPos + AOffset
        else
          TopPos := TopPos + AOffset;
    end;

  begin
    AOffset := 0;
    if AItemMax > AClientMax then
      ChangeOffset(AItemMax - AClientMax);
    if AItemMin < AClientMin then
      ChangeOffset(-(AClientMin - AItemMin));
    ApplyOffset;  
  end;

begin
  if not ActuallyVisible then Exit;
  R := ViewInfo.Bounds;
  AClientR := FContainer.ClientBounds;
  MakeVisibleInOneDirection(R.Left, R.Right, AClientR.Left, AClientR.Right, True);
  MakeVisibleInOneDirection(R.Top, R.Bottom, AClientR.Top, AClientR.Bottom, False);
end;

function TdxCustomLayoutItem.Move(AParent: TdxLayoutGroup; AIndex: Integer;
  APack: Boolean = False): Boolean;
var
  APrevMayPack: Boolean;
  AContainer: TdxCustomLayoutControl;
begin
  Result := CanMoveTo(AParent);
  if not Result then Exit;
  APrevMayPack := Container.MayPack;
  Container.MayPack := False;
  try
    Parent := AParent;
  finally
    Container.MayPack := APrevMayPack;
  end;
  Index := AIndex;
  AContainer := Container;
  if APack then Container.Items.Pack;
  AContainer.Changed;
end;

function TdxCustomLayoutItem.MoveTo(AParent: TdxLayoutGroup; AVisibleIndex: Integer;
  APack: Boolean = False): Boolean;
var
  AIndex: Integer;
begin
  if AParent = nil then
    AIndex := -1
  else
    AIndex := AParent.GetItemIndex(AVisibleIndex);
  Result := Move(AParent, AIndex, APack);
end;

procedure TdxCustomLayoutItem.Pack;
begin
end;

function TdxCustomLayoutItem.PutIntoHiddenGroup(ALayoutDirection: TdxLayoutDirection): TdxLayoutGroup;
var
  AIndex: Integer;
begin
  if FParent = nil then
    Result := nil
  else
  begin
    AIndex := Index;
    Result := FParent.CreateGroup;
    with Result do
    begin
      Hidden := True;
      LayoutDirection := ALayoutDirection;
      Index := AIndex;
    end;
    Move(Result, 0);
  end;  
end;

{ TdxLayoutControlAdapterDefs }

type
  PControlAdapterRecord = ^TControlAdapterRecord;
  TControlAdapterRecord = record
    ControlClass: TControlClass;
    AdapterClass: TdxCustomLayoutControlAdapterClass;
  end;

  TdxLayoutControlAdapterDefs = class
  private
    FItems: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TControlAdapterRecord;
    procedure ClearItems;
  protected
    procedure Delete(AIndex: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TControlAdapterRecord read GetItem;
  public
    constructor Create;
    destructor Destroy; override;
    function GetAdapterClass(AControl: TControl): TdxCustomLayoutControlAdapterClass;
    procedure Register(AControlClass: TControlClass;
      AAdapterClass: TdxCustomLayoutControlAdapterClass);
    procedure Unregister(AControlClass: TControlClass;
      AAdapterClass: TdxCustomLayoutControlAdapterClass);
  end;

var
  FdxLayoutControlAdapterDefs: TdxLayoutControlAdapterDefs;

function dxLayoutControlAdapterDefs: TdxLayoutControlAdapterDefs;
begin
  if FdxLayoutControlAdapterDefs = nil then
    FdxLayoutControlAdapterDefs := TdxLayoutControlAdapterDefs.Create;
  Result := FdxLayoutControlAdapterDefs;
end;

constructor TdxLayoutControlAdapterDefs.Create;
begin
  inherited;
  FItems := TList.Create;
end;

destructor TdxLayoutControlAdapterDefs.Destroy;
begin
  ClearItems;
  FItems.Free;
  inherited;
end;

function TdxLayoutControlAdapterDefs.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TdxLayoutControlAdapterDefs.GetItem(Index: Integer): TControlAdapterRecord;
begin
  Result := PControlAdapterRecord(FItems[Index])^;
end;

procedure TdxLayoutControlAdapterDefs.ClearItems;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    Delete(I);
end;

procedure TdxLayoutControlAdapterDefs.Delete(AIndex: Integer);
begin
  Dispose(PControlAdapterRecord(FItems[AIndex]));
  FItems.Delete(AIndex);
end;

function TdxLayoutControlAdapterDefs.GetAdapterClass(AControl: TControl): TdxCustomLayoutControlAdapterClass;
var
  I: Integer;
  AControlAdapterRecord: TControlAdapterRecord;
begin
  for I := Count - 1 downto 0 do
  begin
    AControlAdapterRecord := Items[I];
    if AControl.InheritsFrom(AControlAdapterRecord.ControlClass) then
    begin
      Result := AControlAdapterRecord.AdapterClass;
      Exit;
    end;
  end;
  Result := TdxCustomLayoutControlAdapter;
end;

procedure TdxLayoutControlAdapterDefs.Register(AControlClass: TControlClass;
  AAdapterClass: TdxCustomLayoutControlAdapterClass);
var
  AControlAdapterRecord: PControlAdapterRecord;
begin
  New(AControlAdapterRecord);
  with AControlAdapterRecord^ do
  begin
    ControlClass := AControlClass;
    AdapterClass := AAdapterClass;
  end;
  FItems.Add(AControlAdapterRecord);
end;

procedure TdxLayoutControlAdapterDefs.Unregister(AControlClass: TControlClass;
  AAdapterClass: TdxCustomLayoutControlAdapterClass);
var
  I: Integer;
  AControlAdapterRecord: TControlAdapterRecord;
begin
  for I := 0 to Count - 1 do
  begin
    AControlAdapterRecord := Items[I];
    with AControlAdapterRecord do
      if (ControlClass = AControlClass) and (AdapterClass = AAdapterClass) then
      begin
        Delete(I);
        Break;
      end;
  end;
  if Count = 0 then
    FreeAndNil(FdxLayoutControlAdapterDefs);
end;

{ TdxCustomLayoutControlAdapter }

constructor TdxCustomLayoutControlAdapter.Create(AItem: TdxLayoutItem);
begin
  inherited Create;
  FItem := AItem;
  if not FItem.IsLoading then
  begin
    Init;
    if FItem.ActuallyVisible then LookAndFeelChanged;
  end;
end;

function TdxCustomLayoutControlAdapter.GetControl: TControl;
begin
  Result := FItem.Control;
end;

function TdxCustomLayoutControlAdapter.GetLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  Result := FItem.GetLookAndFeel;
end;

function TdxCustomLayoutControlAdapter.AllowCheckSize: Boolean;
begin
  Result := True;
end;

procedure TdxCustomLayoutControlAdapter.HideControlBorder;
begin
  SetEnumProp(Control, 'BorderStyle', 'bsNone');
end;

procedure TdxCustomLayoutControlAdapter.Init;
var
  AHeight: Integer;
begin
  FItem.ControlOptions.AutoColor := UseItemColor;
  if FItem.IsDesigning and (FItem.Caption = '') then
    FItem.Caption := Control.Name;//GetPlainString(TControlAccess(Control).Caption);
  FItem.SetControlEnablement;
  FItem.SetControlVisibility;
  if FItem.IsDesigning then
    FItem.ShowCaption := ShowItemCaption;
  FItem.ControlOptions.ShowBorder := ShowBorder;
  if ShowBorder then
  begin
    AHeight := Control.ClientHeight;
    HideControlBorder;
    Control.Height := AHeight;
  end;
end;

function TdxCustomLayoutControlAdapter.ShowBorder: Boolean;
begin
  Result :=
    IsPublishedProp(Control, 'BorderStyle') and
    (GetPropInfo(Control, 'BorderStyle').PropType^ = TypeInfo(Forms.TBorderStyle));
end;

function TdxCustomLayoutControlAdapter.ShowItemCaption: Boolean;
begin
  Result := not IsPublishedProp(Control, 'Caption');
end;

function TdxCustomLayoutControlAdapter.UseItemColor: Boolean;
begin
  Result :=
    TControlAccess(Control).ParentColor and IsPublishedProp(Control, 'Color');
end;

procedure TdxCustomLayoutControlAdapter.LookAndFeelChanged;
begin
  if Item.ControlOptions.AutoColor and (Item.ViewInfo <> nil) then
    TControlAccess(Control).Color := Item.ViewInfo.Color;
end;

class procedure TdxCustomLayoutControlAdapter.Register(AControlClass: TControlClass);
begin
  dxLayoutControlAdapterDefs.Register(AControlClass, Self);
end;

class procedure TdxCustomLayoutControlAdapter.Unregister(AControlClass: TControlClass);
begin
  dxLayoutControlAdapterDefs.Unregister(AControlClass, Self);
end;

{ TdxLayoutItemCaptionOptions }

constructor TdxLayoutItemCaptionOptions.Create(AItem: TdxCustomLayoutItem);
begin
  inherited;
  FAlignVert := tavCenter;
end;

procedure TdxLayoutItemCaptionOptions.SetAlignVert(Value: TdxAlignmentVert);
begin
  if FAlignVert <> Value then
  begin
    FAlignVert := Value;
    Changed;
  end;
end;

procedure TdxLayoutItemCaptionOptions.SetLayout(Value: TdxCaptionLayout);
begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    Changed;
  end;
end;

procedure TdxLayoutItemCaptionOptions.SetWidth(Value: Integer);
begin
  if Value < 0 then Value := 0;
  if FWidth <> Value then
  begin
    FWidth := Value;
    Item.ResetCachedTextHeight;
    Changed;
  end;
end;

{ TdxLayoutItemControlOptions }

constructor TdxLayoutItemControlOptions.Create(AItem: TdxCustomLayoutItem);
begin
  inherited;
  FAutoAlignment := True;
  FMinHeight := dxLayoutItemControlDefaultMinHeight;
  FMinWidth := dxLayoutItemControlDefaultMinWidth;
  FShowBorder := True;
end;

procedure TdxLayoutItemControlOptions.SetAutoAlignment(Value: Boolean);
begin
  if FAutoAlignment <> Value then
  begin
    FAutoAlignment := Value;
    Changed;
  end;
end;

procedure TdxLayoutItemControlOptions.SetAutoColor(Value: Boolean);
begin
  if FAutoColor <> Value then
  begin
    FAutoColor := Value;
    Item.LookAndFeelChangedImpl;
  end;
end;

procedure TdxLayoutItemControlOptions.SetFixedSize(Value: Boolean);
begin
  if FFixedSize <> Value then
  begin
    FFixedSize := Value;
    Changed;
  end;
end;

procedure TdxLayoutItemControlOptions.SetMinHeight(Value: Integer);
begin
  if Value < 0 then Value := 0;
  if FMinHeight <> Value then
  begin
    FMinHeight := Value;
    Changed;
  end;
end;

procedure TdxLayoutItemControlOptions.SetMinWidth(Value: Integer);
begin
  if Value < 0 then Value := 0;
  if FMinWidth <> Value then
  begin
    FMinWidth := Value;
    Changed;
  end;
end;

procedure TdxLayoutItemControlOptions.SetOpaque(Value: Boolean);
begin
  if FOpaque <> Value then
  begin
    FOpaque := Value;
    Changed;
  end;
end;

procedure TdxLayoutItemControlOptions.SetShowBorder(Value: Boolean);
begin
  if FShowBorder <> Value then
  begin
    FShowBorder := Value;
    Changed;
  end;
end;

{ TdxLayoutItem }

constructor TdxLayoutItem.Create(AOwner: TComponent);
begin
  inherited;
  FControlOptions := GetControlOptionsClass.Create(Self);
end;

destructor TdxLayoutItem.Destroy;
begin
  Control := nil;
  FControlOptions.Free;
  inherited;
end;

function TdxLayoutItem.GetCaptionOptions: TdxLayoutItemCaptionOptions;
begin
  Result := TdxLayoutItemCaptionOptions(inherited CaptionOptions);
end;

function TdxLayoutItem.GetViewInfo: TdxLayoutItemViewInfo;
begin
  Result := TdxLayoutItemViewInfo(inherited ViewInfo);
end;

procedure TdxLayoutItem.SetCaptionOptions(Value: TdxLayoutItemCaptionOptions);
begin
  inherited CaptionOptions := Value;
end;

procedure TdxLayoutItem.SetControl(Value: TControl);

  procedure CheckValue;
  var
    AItem: TdxLayoutItem;
  begin
    if Value <> nil then
    begin
      if Value = Container then
        raise EdxException.Create(sContainerCannotBeControl);
      AItem := FContainer.FindItem(Value);
      if AItem <> nil then
        raise EdxException.Create(Format(sControlIsUsed, [Value.Name, AItem.Name]))
    end;
  end;

  procedure UnprepareControl;
  begin
    FreeAndNil(FControlAdapter);
    if IsDesigning then
      with FControl do
        ControlStyle := ControlStyle - [csNoDesignVisible];
    //FControl.RemoveFreeNotification(Self);
    FControl.WindowProc := FPrevControlWndProc;
    if IsDesigning and not (csDestroying in FControl.ComponentState) then
    begin
      FControl.Left := 0;
      FControl.Top := 0;
    end;
  end;

  procedure PrepareControl;
  begin
    //FPrevControlWndProc := FControl.WindowProc;
    //FControl.WindowProc := ControlWndProc;
    //FControl.FreeNotification(Self);
    if IsDesigning then
      with FControl do
        ControlStyle := ControlStyle + [csNoDesignVisible];
    FControl.Parent := Container;
    SaveOriginalControlSize;
    CreateControlAdapter;
    SaveOriginalControlSize;
    if HasWinControl and not TWinControl(Control).HandleAllocated then
      SaveControlSizeBeforeDestruction;
    FPrevControlWndProc := FControl.WindowProc;
    FControl.WindowProc := ControlWndProc;
  end;

begin
  if FControl <> Value then
  begin
    CheckValue;
    if FControl <> nil then UnprepareControl;
    FControl := Value;
    if FControl <> nil then PrepareControl;
    Changed;
  end;
end;

procedure TdxLayoutItem.CreateControlAdapter;
begin
  FControlAdapter :=
    dxLayoutControlAdapterDefs.GetAdapterClass(FControl).Create(Self);
end;

{procedure TdxLayoutItem.PostFree;
begin
  Container.PostFree(Self);
end;}

procedure TdxLayoutItem.ActuallyVisibleChanged;
begin
  SetControlVisibility;
  inherited;
end;

function TdxLayoutItem.CanProcessAccel(out AItem: TdxCustomLayoutItem): Boolean;
begin
  Result := CanFocusControl;
  if Result then AItem := Self;
end;

procedure TdxLayoutItem.EnabledChanged;
begin
  inherited;
  SetControlEnablement;
end;

function TdxLayoutItem.GetAutoAlignHorz: TdxLayoutAlignHorz;
begin
  if (FParent = nil) or (FParent.LayoutDirection = ldHorizontal) then
    Result := ahLeft
  else
    Result := ahClient;
end;

function TdxLayoutItem.GetAutoAlignVert: TdxLayoutAlignVert;
begin
  Result := avTop;
end;

function TdxLayoutItem.GetBaseName: string;
begin
  Result := inherited GetBaseName + 'Item';
end;

function TdxLayoutItem.GetViewInfoClass: TdxCustomLayoutItemViewInfoClass;
begin
  Result := TdxCustomLayoutItemViewInfoClass(GetLookAndFeel.GetItemViewInfoClass);
end;

function TdxLayoutItem.HasCaption: Boolean;
begin
  Result := inherited HasCaption and (Caption <> '');
end;

procedure TdxLayoutItem.Init;
var
  ACommonValue: Variant;

  function IsCommonValue(AValueIndex: Integer; var ACommonValue: Variant): Boolean;
  var
    I: Integer;
    AValue: Variant;

    function CheckValue(AItem: TdxCustomLayoutItem): Boolean;
    begin
      if AItem <> Self then
        case AValueIndex of
          0..2: Result := AItem is TdxLayoutItem;
          3..4: Result := True;
        else
          Result := False;
        end
      else
        Result := False;
    end;

    function GetValue(AItem: TdxCustomLayoutItem): Variant;
    begin
      case AValueIndex of
        0: Result := TdxLayoutItem(AItem).CaptionOptions.Layout;
        1: Result := TdxLayoutItem(AItem).CaptionOptions.AlignHorz;
        2: Result := TdxLayoutItem(AItem).CaptionOptions.AlignVert;
        3: Result := AItem.AlignHorz;
        4: Result := AItem.AlignVert;
      else
        Result := Null;
      end;
    end;

  begin
    Result := Parent <> nil;
    if not Result then Exit;
    Result := False;
    ACommonValue := Unassigned;
    for I := 0 to Parent.VisibleCount - 1 do
      if CheckValue(Parent.VisibleItems[I]) then
      begin
        AValue := GetValue(Parent.VisibleItems[I]);
        if VarIsEmpty(ACommonValue) then
          ACommonValue := AValue;
        Result := AValue = ACommonValue;
        if not Result then Break;
      end;
  end;

begin
  inherited;
  if IsCommonValue(0, ACommonValue) then
    CaptionOptions.Layout := ACommonValue;
  if IsCommonValue(1, ACommonValue) then
    CaptionOptions.AlignHorz := ACommonValue;
  if IsCommonValue(2, ACommonValue) then
    CaptionOptions.AlignVert := ACommonValue;

  {if IsCommonValue(3, ACommonValue) then
    AlignHorz := ACommonValue; - items lose client alignment}
  {if IsCommonValue(4, ACommonValue) then
    AlignVert := ACommonValue; - because some controls cannot be made client aligned }
end;

procedure TdxLayoutItem.Loaded;
begin
  inherited;
  if HasControl then
  begin
    SaveOriginalControlSize;
    SetControlVisibility;
  end;
end;

procedure TdxLayoutItem.LookAndFeelChanged;
begin
  inherited;
  if FControlAdapter <> nil then
    FControlAdapter.LookAndFeelChanged;
end;

{procedure TdxLayoutItem.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FControl) then
  begin
    Control := nil;
    PostFree;
  end;
end;}

procedure TdxLayoutItem.ParentChanged(APrevParent: TdxLayoutGroup);
begin
  inherited;
  SetControlEnablement;
end;

procedure TdxLayoutItem.ProcessAccel;
begin
  TWinControl(FControl).SetFocus;
end;

procedure TdxLayoutItem.RestoreItemControlSize;
begin
  if HasControl then
    with Control, FOriginalControlSize do
      SetBounds(Left, Top, X, Y);
end;

function TdxLayoutItem.GetCaptionOptionsClass: TdxCustomLayoutItemCaptionOptionsClass;
begin
  Result := TdxLayoutItemCaptionOptions;
end;

function TdxLayoutItem.GetControlOptionsClass: TdxLayoutItemControlOptionsClass;
begin
  Result := TdxLayoutItemControlOptions;
end;

function TdxLayoutItem.CanFocusControl: Boolean;
begin
  Result := HasWinControl and TWinControl(FControl).CanFocus;
end;

procedure TdxLayoutItem.ControlWndProc(var Message: TMessage);

  function IsControlMoved: Boolean;
  begin
    Result := (Message.LParam = 0) or (PWindowPos(Message.LParam)^.flags and SWP_NOMOVE = 0);
  end;

  function IsControlResized: Boolean;
  begin
    Result := (Message.LParam = 0) or (PWindowPos(Message.LParam)^.flags and SWP_NOSIZE = 0);
  end;

  function ControlSizeChanged: Boolean;
  begin
    with Control, FOriginalControlSize do
      Result := (Width <> X) or (Height <> Y);
  end;

begin
  FPrevControlWndProc(Message);
  with Message do
    case Msg of
      WM_CREATE:
        if (Control.Width <> ControlSizeBeforeDestruction.X) or
          (Control.Height <> ControlSizeBeforeDestruction.Y) then
        begin
          SaveOriginalControlSize;
          Changed;
        end;
      WM_DESTROY:
        SaveControlSizeBeforeDestruction;
      WM_PAINT, WM_NCPAINT:
        if IsDesigning and not Container.IsDestroying then
          Container.Painter.DrawSelections;
      WM_SETFOCUS:
        MakeVisible;
      WM_WINDOWPOSCHANGED:
        if not Container.IsPlacingControls and (IsControlMoved or IsControlResized) then
        begin
          if IsControlResized and FControlAdapter.AllowCheckSize and ControlSizeChanged then
            SaveOriginalControlSize;
          Changed;
        end;
      CM_TABSTOPCHANGED:
        Container.ViewInfo.DoCalculateTabOrders;
  end;
end;

function TdxLayoutItem.HasControl: Boolean;
begin
  Result := FControl <> nil;
end;

function TdxLayoutItem.HasWinControl: Boolean;
begin
  Result := HasControl and (FControl is TWinControl);
end;

procedure TdxLayoutItem.SaveControlSizeBeforeDestruction;
begin
  FControlSizeBeforeDestruction := Point(Control.Width, Control.Height);
end;

procedure TdxLayoutItem.SaveOriginalControlSize;
begin
  if HasWinControl and CanAllocateHandle(TWinControl(FControl)) then
    TWinControl(FControl).HandleNeeded;  // for cxEditors
  FOriginalControlSize := Point(FControl.Width, FControl.Height);
end;

procedure TdxLayoutItem.SetControlEnablement;
begin
  if HasControl then Control.Enabled := EnabledForWork;
end;

procedure TdxLayoutItem.SetControlVisibility;
begin
  if HasControl then
    with Control do
    begin
      Visible := ActuallyVisible;
      // to make the control invisible on showing
      if not Visible then
        SetBounds(10000, 10000, FOriginalControlSize.X, FOriginalControlSize.Y);
    end;
end;

{ TdxLayoutGroup }

constructor TdxLayoutGroup.Create(AOwner: TComponent);
begin
  inherited;
  FIsUserDefined := True;
  FItems := TList.Create;
  FLayoutDirection := ldVertical;
  FShowBorder := True;
  FUseIndent := True;
  FVisibleItems := TList.Create;
end;

destructor TdxLayoutGroup.Destroy;
begin
  if IsRoot then Container.FItems := nil;
  DestroyItems;
  FreeAndNil(FVisibleItems);
  FreeAndNil(FItems);
  inherited;
end;

function TdxLayoutGroup.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TdxLayoutGroup.GetItem(Index: Integer): TdxCustomLayoutItem;
begin
  Result := TdxCustomLayoutItem(FItems[Index]);
end;

function TdxLayoutGroup.GetShowBorder: Boolean;
begin
  if FHidden then
    Result := False
  else
    Result := FShowBorder;
end;

function TdxLayoutGroup.GetViewInfo: TdxLayoutGroupViewInfo;
begin
  Result := TdxLayoutGroupViewInfo(inherited ViewInfo);
end;

function TdxLayoutGroup.GetVisibleCount: Integer;
begin
  Result := FVisibleItems.Count;
end;

function TdxLayoutGroup.GetVisibleItem(Index: Integer): TdxCustomLayoutItem;
begin
  Result := TdxCustomLayoutItem(FVisibleItems[Index]);
end;

procedure TdxLayoutGroup.SetHidden(Value: Boolean);
begin
  if FHidden <> Value then
  begin
    FHidden := Value;
    if not IsRoot then
    begin
      Changed;
      if IsDesigning then
        dxLayoutDesigner.ItemsChanged(Container);
    end;    
  end;
end;

procedure TdxLayoutGroup.SetLayoutDirection(Value: TdxLayoutDirection);
begin
  if FLayoutDirection <> Value then
  begin
    FLayoutDirection := Value;
    Changed;
  end;
end;

procedure TdxLayoutGroup.SetLocked(Value: Boolean);
begin
  if FLocked <> Value then
  begin
    FLocked := Value;
  end;
end;

procedure TdxLayoutGroup.SetLookAndFeelException(Value: Boolean);
begin
  if FLookAndFeelException <> Value then
  begin
    FLookAndFeelException := Value;
    LookAndFeelChangedImpl;
  end;
end;

procedure TdxLayoutGroup.SetShowBorder(Value: Boolean);
begin
  if FShowBorder <> Value then
  begin
    FShowBorder := Value;
    Changed;
  end;
end;

procedure TdxLayoutGroup.SetUseIndent(Value: Boolean);
begin
  if FUseIndent <> Value then
  begin
    FUseIndent := Value;
    Changed; 
  end;
end;

procedure TdxLayoutGroup.AddItem(AItem: TdxCustomLayoutItem);
begin
  FItems.Add(AItem);
  AItem.FParent := Self;
  AItem.Container := FContainer;
  if AItem.GetVisible then BuildVisibleItemsList;
  Changed;
  if not IsLoading then AItem.Init;
end;

procedure TdxLayoutGroup.RemoveItem(AItem: TdxCustomLayoutItem);
begin
  FItems.Remove(AItem);
  AItem.FParent := nil;
  if AItem.GetVisible then BuildVisibleItemsList;
  Changed;
end;

procedure TdxLayoutGroup.DestroyItems;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    Items[I].Free;
end;

procedure TdxLayoutGroup.ActuallyVisibleChanged;
var
  I: Integer;
begin
  inherited;
  for I := 0 to VisibleCount - 1 do
    VisibleItems[I].ActuallyVisibleChanged;
end;

function TdxLayoutGroup.CanProcessAccel(out AItem: TdxCustomLayoutItem): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to VisibleCount - 1 do
  begin
    AItem := VisibleItems[I];
    Result := AItem.CanProcessAccel(AItem);
    if Result then Break;
  end;
end;

function TdxLayoutGroup.CanRemove: Boolean;
var
  I: Integer;
begin
  Result := inherited CanRemove;
  if Result then
    for I := 0 to Count - 1 do
    begin
      Result := Items[I].CanRemove;
      if not Result then Break;
    end;
end;

procedure TdxLayoutGroup.EnabledChanged;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].EnabledChanged;
  inherited;
end;

function TdxLayoutGroup.GetAutoAlignHorz: TdxLayoutAlignHorz;
begin
  if IsRoot then
    if acsWidth in Container.AutoContentSizes then
      Result := ahClient
    else
      Result := ahLeft
  else
    if (Parent = nil) or (Parent.LayoutDirection = ldHorizontal) then
      Result := ahLeft
    else
      Result := ahClient;
end;

function TdxLayoutGroup.GetAutoAlignVert: TdxLayoutAlignVert;
begin
  if IsRoot then
    if acsHeight in Container.AutoContentSizes then
      Result := avClient
    else
      Result := avTop
  else
    if (Parent <> nil) and (Parent.LayoutDirection = ldHorizontal) then
      Result := avClient
    else
      Result := avTop;
end;

function TdxLayoutGroup.GetBaseName: string;
begin
  Result := inherited GetBaseName + 'Group';
end;

procedure TdxLayoutGroup.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  inherited;
  for I := 0 to Count - 1 do
    if Items[I].Owner = Root then Proc(Items[I]);
end;

function TdxLayoutGroup.GetShowCaption: Boolean;
begin
  if FHidden then
    Result := False
  else
    Result := ShowBorder and inherited GetShowCaption;
end;

function TdxLayoutGroup.GetViewInfoClass: TdxCustomLayoutItemViewInfoClass;
begin
  Result := TdxCustomLayoutItemViewInfoClass(GetLookAndFeel.GetGroupViewInfoClass);
end;

procedure TdxLayoutGroup.Loaded;
begin
  inherited;
  FIsUserDefined := False;
end;

procedure TdxLayoutGroup.LookAndFeelChanged;
var
  I: Integer;
begin
  inherited;
  for I := 0 to VisibleCount - 1 do
    VisibleItems[I].LookAndFeelChanged;
end;

procedure TdxLayoutGroup.LookAndFeelChanging;
var
  I: Integer;
begin
  inherited;
  for I := 0 to VisibleCount - 1 do
    VisibleItems[I].LookAndFeelChanging;
end;

function TdxLayoutGroup.ProcessDialogChar(ACharCode: Word): Boolean;
var
  I: Integer;
begin
  Result := inherited ProcessDialogChar(ACharCode);
  if not Result then
    for I := 0 to VisibleCount - 1 do
    begin
      Result := VisibleItems[I].ProcessDialogChar(ACharCode);
      if Result then Break;
    end;
end;

procedure TdxLayoutGroup.RestoreItemControlSize;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].RestoreItemControlSize;
end;

procedure TdxLayoutGroup.SelectionChanged;
var
  I: Integer;
begin
  inherited;
  for I := 0 to VisibleCount - 1 do
    VisibleItems[I].SelectionChanged;
end;

procedure TdxLayoutGroup.SetChildOrder(Child: TComponent; Order: Integer);
begin
  inherited;
  (Child as TdxCustomLayoutItem).Index := Order;
end;

procedure TdxLayoutGroup.SetParentComponent(Value: TComponent);
begin
  if Value is TdxCustomLayoutControl and
    not TdxCustomLayoutControl(Value).Items.IsLoading and
    not (csAncestor in ComponentState) then
    TdxCustomLayoutControl(Value).SetItems(Self)
  else
    inherited;
end;

function TdxLayoutGroup.CanDestroy: Boolean;
begin
  Result := Hidden and not IsRoot and not Locked;
end;

procedure TdxLayoutGroup.BuildVisibleItemsList;
var
  I: Integer;
begin
  FVisibleItems.Clear;
  for I := 0 to Count - 1 do
    if Items[I].GetVisible then
      FVisibleItems.Add(Items[I]);
end;

function TdxLayoutGroup.GetLookAndFeelAsParent: TdxCustomLayoutLookAndFeel;
begin
  if FLookAndFeelException and (Parent <> nil) then
    Result := Parent.GetLookAndFeelAsParent
  else
    Result := GetLookAndFeel;
end;

procedure TdxLayoutGroup.ChangeItemIndex(AItem: TdxCustomLayoutItem;
  Value: Integer);
begin
  if AItem.Index <> Value then
  begin
    FItems.Move(AItem.Index, Value);
    if AItem.GetVisible then
    begin
      BuildVisibleItemsList;
      Changed;
    end;
  end;
end;

procedure TdxLayoutGroup.ChangeItemVisibleIndex(AItem: TdxCustomLayoutItem;
  Value: Integer);
begin
  ChangeItemIndex(AItem, GetItemIndex(Value));
end;

function TdxLayoutGroup.GetItemIndex(AItemVisibleIndex: Integer): Integer;
begin
  if (0 <= AItemVisibleIndex) and (AItemVisibleIndex < VisibleCount) then
    Result := VisibleItems[AItemVisibleIndex].Index
  else
    Result := Count;
end;

function TdxLayoutGroup.IndexOf(AItem: TdxCustomLayoutItem): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

function TdxLayoutGroup.VisibleIndexOf(AItem: TdxCustomLayoutItem): Integer;
begin
  Result := FVisibleItems.IndexOf(AItem);
end;

function TdxLayoutGroup.CreateGroup(AGroupClass: TdxLayoutGroupClass = nil): TdxLayoutGroup;
begin
  Result := Container.CreateGroup(AGroupClass, Self);
end;

function TdxLayoutGroup.CreateItem(AItemClass: TdxCustomLayoutItemClass = nil): TdxCustomLayoutItem;
begin
  Result := Container.CreateItem(AItemClass, Self);
end;

function TdxLayoutGroup.CreateItemForControl(AControl: TControl): TdxLayoutItem;
begin
  Result := Container.CreateItemForControl(AControl, Self);
end;

function TdxLayoutGroup.CanMoveTo(AParent: TdxCustomLayoutItem): Boolean;
begin
  Result := (AParent = nil) or
    inherited CanMoveTo(AParent) and not AParent.HasAsParent(Self);
end;

procedure TdxLayoutGroup.MoveChildrenToParent;
var
  AInsertionIndex, I: Integer;
begin
  AInsertionIndex := Index;
  for I := Count - 1 downto 0 do
    Items[I].Move(Parent, AInsertionIndex);
end;

procedure TdxLayoutGroup.Pack;
var
  I: Integer;
  ASomethingDone: Boolean;
  AGroup: TdxLayoutGroup;
begin
  if FIsPacking or not Container.MayPack then Exit;
  FIsPacking := True;
  for I := Count - 1 downto 0 do
    Items[I].Pack;
  repeat
    ASomethingDone := False;
    if (Count = 0) and CanDestroy then
    begin
      Free;
      Exit;
    end;
    if Count = 1 then
    begin
      if Items[0] is TdxLayoutGroup then
      begin
        AGroup := TdxLayoutGroup(Items[0]);
        if AGroup.CanDestroy then
        begin
          LayoutDirection := AGroup.LayoutDirection;
          AGroup.MoveChildrenToParent;
          AGroup.Free;
          ASomethingDone := True;
        end;
      end;
      if not ASomethingDone and CanDestroy then
      begin
        Items[0].Move(Parent, Index);
        ASomethingDone := True;
      end;
    end;
  until not ASomethingDone;
  FIsPacking := False;
end;

function TdxLayoutGroup.PutChildrenIntoHiddenGroup: TdxLayoutGroup;
var
  I: Integer;
begin
  Result := CreateGroup;
  Result.Hidden := True;
  Result.LayoutDirection := LayoutDirection;
  for I := Count - 2 downto 0 do
    Items[I].Move(Result, 0);
end;

{ TdxLayoutAlignmentConstraint }

constructor TdxLayoutAlignmentConstraint.Create(AOwner: TComponent);
begin
  inherited;
  CreateItems;
end;

destructor TdxLayoutAlignmentConstraint.Destroy;
begin
  DestroyItems;
  if FControl <> nil then
    FControl.RemoveAlignmentConstraint(Self);
  inherited;
end;

function TdxLayoutAlignmentConstraint.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TdxLayoutAlignmentConstraint.GetItem(Index: Integer): TdxCustomLayoutItem;
begin
  Result := FItems[Index];
end;

procedure TdxLayoutAlignmentConstraint.SetKind(Value: TdxLayoutAlignmentConstraintKind);
begin
  if FKind <> Value then
  begin
    FKind := Value;
    Changed;
  end;
end;

procedure TdxLayoutAlignmentConstraint.CreateItems;
begin
  FItems := TList.Create;
end;

procedure TdxLayoutAlignmentConstraint.DestroyItems;
var
  I: Integer;
begin
  BeginUpdate;
  try
    for I := Count - 1 downto 0 do
      RemoveItem(Items[I]);
  finally
    EndUpdate;
  end;
  FItems.Free;
end;

procedure TdxLayoutAlignmentConstraint.SetParentComponent(Value: TComponent);
begin
  inherited;
  if Value is TdxCustomLayoutControl then
    TdxCustomLayoutControl(Value).AddAlignmentConstraint(Self);
end;

procedure TdxLayoutAlignmentConstraint.BeginUpdate;
begin
  FControl.BeginUpdate;
end;

function TdxLayoutAlignmentConstraint.CanAddItem(AItem: TdxCustomLayoutItem): Boolean;
begin
  Result := (AItem <> nil) and (AItem.Container = Control);
end;

procedure TdxLayoutAlignmentConstraint.Changed;
begin
  FControl.LayoutChanged;
end;

procedure TdxLayoutAlignmentConstraint.EndUpdate;
begin
  FControl.EndUpdate;
end;

function TdxLayoutAlignmentConstraint.GetParentComponent: TComponent;
begin
  Result := FControl;
end;

function TdxLayoutAlignmentConstraint.HasParent: Boolean;
begin
  Result := FControl <> nil;
end;

procedure TdxLayoutAlignmentConstraint.AddItem(AItem: TdxCustomLayoutItem);
begin
  if not CanAddItem(AItem) then Exit;
  AItem.AlignmentConstraint := nil;
  FItems.Add(AItem);
  AItem.FAlignmentConstraint := Self;
  Changed;
end;

procedure TdxLayoutAlignmentConstraint.RemoveItem(AItem: TdxCustomLayoutItem);
begin
  if (AItem <> nil) and (FItems.Remove(AItem) <> -1) then
  begin
    AItem.FAlignmentConstraint := nil;
    Changed;
    if not (csDestroying in ComponentState) and (Count < 2) then
      Free;
  end;
end;

{ TdxLayoutControlDragAndDropObject }

destructor TdxLayoutControlDragAndDropObject.Destroy;
begin
  SourceItem := nil;
  inherited;
end;

function TdxLayoutControlDragAndDropObject.GetControl: TdxCustomLayoutControl;
begin
  Result := TdxCustomLayoutControl(inherited Control);
end;

procedure TdxLayoutControlDragAndDropObject.SetAreaPart(Value: TdxLayoutAreaPart);
begin
  if FAreaPart <> Value then
  begin
    Dirty := True;
    FAreaPart := Value;
  end;
end;

procedure TdxLayoutControlDragAndDropObject.SetDestItem(Value: TdxCustomLayoutItem);
begin
  if FDestItem <> Value then
  begin
    Dirty := True;
    FDestItem := Value;
  end;
end;

procedure TdxLayoutControlDragAndDropObject.SetSourceItem(Value: TdxCustomLayoutItem);
begin
  if FSourceItem <> Value then
  begin
    if Value = nil then HideSourceItemMark;
    FSourceItem := Value;
    if Value <> nil then ShowSourceItemMark;
  end;
end;

procedure TdxLayoutControlDragAndDropObject.HideSourceItemMark;
begin
  if Control.HandleAllocated and (FSourceItem.ViewInfo <> nil) then
    RedrawWindow(Control.Handle, @FSourceItemBounds, 0,
      RDW_ERASE or RDW_FRAME or RDW_INVALIDATE or RDW_ALLCHILDREN);
end;

procedure TdxLayoutControlDragAndDropObject.ShowSourceItemMark;
var
  AMaskBounds: TRect;
  AMaskBitmap: TBitmap;

  function CreatePatternBitmap: TBitmap;
  var
    I, J: Integer;
  begin
    Result := TBitmap.Create;
    with Result do
    begin
      Monochrome := True;
      Width := 8;
      Height := 8;
      for I := 0 to Width - 1 do
        for J := 0 to Height - 1 do
          Canvas.Pixels[I, J] := clWhite * Byte(Odd(I) xor Odd(J))
    end;
  end;

  function CreateMask: TBitmap;
  begin
    Result := TBitmap.Create;
    Result.Width := AMaskBounds.Right;
    Result.Height := AMaskBounds.Bottom;
    Result.Canvas.Brush.Bitmap := CreatePatternBitmap;
  end;

  function MaskCanvas: TCanvas;
  begin
    Result := AMaskBitmap.Canvas;
  end;

begin
  if SourceItem.ViewInfo = nil then Exit;
  FSourceItemBounds := SourceItem.ViewInfo.Bounds;
  AMaskBounds := FSourceItemBounds;
  OffsetRect(AMaskBounds, -AMaskBounds.Left, -AMaskBounds.Top);
  with Control.Painter.GetCustomizationCanvas do
    try
      AMaskBitmap := CreateMask;
      try
        SetTextColor(MaskCanvas.Handle, 0);
        SetBkColor(MaskCanvas.Handle, $FFFFFF);
        MaskCanvas.FillRect(AMaskBounds);

        CopyMode := cmSrcAnd;
        Draw(FSourceItemBounds.Left, FSourceItemBounds.Top, AMaskBitmap);

        SetTextColor(MaskCanvas.Handle, ColorToRGB(clHighlight));
        SetBkColor(MaskCanvas.Handle, 0);
        MaskCanvas.FillRect(AMaskBounds);

        CopyMode := cmSrcPaint;
        Draw(FSourceItemBounds.Left, FSourceItemBounds.Top, AMaskBitmap);
      finally
        CopyMode := cmSrcCopy;

        MaskCanvas.Brush.Bitmap.Free;
        MaskCanvas.Brush.Bitmap := nil;

        AMaskBitmap.Free;
      end;
    finally
      Free;
    end;
end;

procedure TdxLayoutControlDragAndDropObject.DirtyChanged;

  function GetAreaPartBounds: TRect;

    procedure CalculatePartBounds(AHorizontal, AFirstPart: Boolean);
    var
      AMiddle: Integer;
    begin
      with Result do
        if AHorizontal then
        begin
          AMiddle := (Left + Right) div 2;
          if AFirstPart then
            Right := AMiddle
          else
            Left := AMiddle;
        end    
        else
        begin
          AMiddle := (Top + Bottom) div 2;
          if AFirstPart then
            Bottom := AMiddle
          else
            Top := AMiddle;
        end;
    end;

  begin
    if AreaPart in [apBeforeContent, apAfterContent] then
      with TdxLayoutGroup(DestItem) do
      begin
        Result := ViewInfo.ClientBounds;
        CalculatePartBounds(GetOrthogonalDirection(LayoutDirection) = ldHorizontal,
          AreaPart = apBeforeContent);
      end
    else
    begin
      Result := DestItem.ViewInfo.Bounds;
      if AreaPart = apCenter then
        Result := GetCenterAreaBounds(Result)
      else
        CalculatePartBounds(AreaPart in [apLeft, apRight], AreaPart in [apLeft, apTop]);
    end;
  end;

  procedure ShowAreaPartMark;
  const
    FrameBorderSize = 3;
  begin
    with Control.Painter.GetCustomizationCanvas do
      try
        InvertFrame(GetAreaPartBounds, FrameBorderSize);
      finally
        Free;
      end;
  end;

  procedure HideAreaPartMark;
  begin
    ShowAreaPartMark;
  end;

begin
  inherited;
  if (DestItem = nil) or (AreaPart = apNone) then Exit;
  if Dirty then
    HideAreaPartMark
  else
    ShowAreaPartMark;
end;

function TdxLayoutControlDragAndDropObject.GetDragAndDropCursor(Accepted: Boolean): TCursor;
begin
  if Accepted or
    (Control.ViewInfo.GetHitTest(CurMousePos).HitTestCode = htCustomizeForm) and
    SourceItem.CanRemove then
    Result := crdxLayoutControlDrag
  else
    if (Source = dsCustomizeForm) or not SourceItem.CanRemove then
      Result := crcxNoDrop
    else
      Result := crcxRemove;
end;

function TdxLayoutControlDragAndDropObject.GetCenterAreaBounds(const AItemBounds: TRect): TRect;
begin
  Result := AItemBounds;
  with Result do
    InflateRect(Result, -(Right - Left) div 4, -(Bottom - Top) div 4);
end;

procedure TdxLayoutControlDragAndDropObject.BeginDragAndDrop;
begin
  inherited;
  Control.DragAndDropBegan;
end;

procedure TdxLayoutControlDragAndDropObject.DragAndDrop(const P: TPoint;
  var Accepted: Boolean);
var
  AHitTest: TdxCustomLayoutHitTest;

  function GetAreaPart(AItem: TdxCustomLayoutItem; const P: TPoint): TdxLayoutAreaPart;
  const
    ContentParts: array[Boolean] of TdxLayoutAreaPart =
      (apBeforeContent, apAfterContent);
    Parts: array[Boolean, Boolean] of TdxLayoutAreaPart =
      ((apBottom, apRight), (apLeft, apTop));
  var
    AGroup: TdxLayoutGroup;
    ASign1, ASign2: Integer;

    function GetSign(const P1, P2, P: TPoint): Integer;
    begin
      Result := (P.X - P1.X) * (P2.Y - P1.Y) - (P.Y - P1.Y) * (P2.X - P1.X);
    end;

  begin
    Result := apNone;

    if AItem is TdxLayoutGroup and not TdxLayoutGroup(AItem).ViewInfo.IsLocked then
    begin
      AGroup := TdxLayoutGroup(AItem);
      if AGroup.VisibleCount = 0 then
        if PtInRect(GetCenterAreaBounds(AItem.ViewInfo.Bounds), P) then
          Result := apCenter
        else
      else
        if PtInRect(AGroup.ViewInfo.ClientBounds, P) then
          with AGroup.ViewInfo.ClientBounds do
            if AGroup.LayoutDirection = ldHorizontal then
              Result := ContentParts[P.Y >= (Top + Bottom) div 2]
            else
              Result := ContentParts[P.X >= (Left + Right) div 2];
    end;

    if Result = apNone then
    begin
      with AItem.ViewInfo.Bounds do
      begin
        ASign1 := GetSign(Point(Left, Bottom), Point(Right, Top), P);
        ASign2 := GetSign(TopLeft, BottomRight, P);
      end;
      Result := Parts[ASign1 >= 0, ASign2 >= 0];
    end;
  end;

begin
  if IsWindowVisible(Control.Handle) then
    AHitTest := Control.ViewInfo.GetHitTest(P)
  else
    AHitTest := nil;
  Accepted := AHitTest is TdxCustomLayoutItemHitTest;
  if Accepted then
  begin
    DestItem := TdxCustomLayoutItemHitTest(AHitTest).Item;
    if SourceItem.CanMoveTo(DestItem) then
      AreaPart := GetAreaPart(DestItem, P)
    else
      AreaPart := apNone;
  end
  else
    if (AHitTest <> nil) and (AHitTest.HitTestCode = htClientArea) then
    begin
      Accepted := True;
      DestItem := Control.Items;
      if P.Y >= Control.ViewInfo.ContentBounds.Bottom then
        AreaPart := apBottom
      else
        AreaPart := apRight;
    end
    else
      DestItem := nil;
  inherited;
end;

procedure TdxLayoutControlDragAndDropObject.EndDragAndDrop(Accepted: Boolean);
type
  TActionType = (atNone, atInsert, atCreateGroup, atContentInsert);

  function GetDestParent: TdxLayoutGroup;
  begin
    if AreaPart in [apCenter, apBeforeContent, apAfterContent] then
      Result := TdxLayoutGroup(DestItem)
    else
    begin
      Result := DestItem.Parent;
      if Result = nil then
        Result := DestItem as TdxLayoutGroup;
    end;
  end;

  function GetDestPosition: Integer;
  begin
    case AreaPart of
      apCenter:
        Result := 0;
      apBeforeContent:
        Result := 0;
      apAfterContent:
        Result := 1;
    else
      if DestItem.IsRoot then
        Result := 0
      else
        Result := DestItem.VisibleIndex;
      if AreaPart in [apRight, apBottom] then Inc(Result);
      if (SourceItem.Parent <> nil) and
        (SourceItem.Parent = DestItem.Parent) and
        (SourceItem.VisibleIndex < Result) then
        Dec(Result);
    end;
  end;

  function GetLayoutDirection: TdxLayoutDirection;
  begin
    Result := GetDestParent.LayoutDirection;
  end;

  function IsHorizontalAreaPart: Boolean;
  begin
    Result := AreaPart in [apLeft, apRight];
  end;

  function GetActionType: TActionType;
  begin
    if AreaPart = apNone then
      Result := atNone
    else
      if AreaPart in [apBeforeContent, apAfterContent] then
        Result := atContentInsert
      else
        if (AreaPart = apCenter) or not DestItem.IsRoot and
          ((GetLayoutDirection = ldHorizontal) and IsHorizontalAreaPart or
           (GetLayoutDirection = ldVertical) and not IsHorizontalAreaPart) then
          Result := atInsert
        else
          Result := atCreateGroup;
  end;

  procedure DoInsert;
  begin
    SourceItem.MoveTo(GetDestParent, GetDestPosition, True);
  end;

  procedure DoCreateGroup;
  const
    LayoutDirections: array[Boolean] of TdxLayoutDirection =
      (ldVertical, ldHorizontal);
  var
    AGroup: TdxLayoutGroup;
  begin
    if DestItem.IsRoot then
    begin
      GetDestParent.PutChildrenIntoHiddenGroup;
      GetDestParent.LayoutDirection := LayoutDirections[IsHorizontalAreaPart];
      SourceItem.MoveTo(GetDestParent, GetDestPosition, True);
    end
    else
    begin
      AGroup := DestItem.PutIntoHiddenGroup(GetOrthogonalDirection(GetLayoutDirection));
      SourceItem.MoveTo(AGroup, GetDestPosition, True);
    end;
  end;

  procedure DoContentInsert;
  begin
    GetDestParent.PutChildrenIntoHiddenGroup;
    GetDestParent.LayoutDirection := GetOrthogonalDirection(GetLayoutDirection);
    SourceItem.MoveTo(GetDestParent, GetDestPosition, True);
  end;

begin
  Dirty := True;
  if Accepted then
  begin
    if DestItem <> nil then
      case GetActionType of
        atInsert:
          DoInsert;
        atCreateGroup:
          DoCreateGroup;
        atContentInsert:
          DoContentInsert;
      end
    else
      if (Source = dsControl) and SourceItem.CanRemove then
        SourceItem.Parent := nil;
    Control.Update;
    Control.Modified;
  end;
  inherited;
end;

procedure TdxLayoutControlDragAndDropObject.Init(ASource: TdxLayoutDragSource;
  ASourceItem: TdxCustomLayoutItem);
begin
  Control.Update;  // to update selections
  Source := ASource;
  SourceItem := ASourceItem;
end;

{ TCustomizedControls }

type
  TCustomizedControls = class
  private
    FForms: TList;
    FItems: TList;
    FPrevEnableds: TList;
    function GetCount: Integer;
    function GetForm(Index: Integer): TCustomForm;
    function GetItem(Index: Integer): TdxCustomLayoutControl;
  protected
    function IndexOf(AItem: TdxCustomLayoutControl): Integer;
    procedure InternalAddItem(AItem: TdxCustomLayoutControl);
    procedure InternalRemoveItem(AItem: TdxCustomLayoutControl);
    procedure InternalSetForm(AControl: TdxCustomLayoutControl; AForm: TCustomForm);
    property Count: Integer read GetCount;
    property Forms[Index: Integer]: TCustomForm read GetForm;
    property Items[Index: Integer]: TdxCustomLayoutControl read GetItem;
  public
    constructor Create;
    destructor Destroy; override;
    function ProcessMouseMessage(AMessage: WPARAM; AMessageData: TMouseHookStruct): Boolean;
    procedure ProcessWndProcMessage(AMessageData: TCWPStruct);

    class procedure AddItem(AItem: TdxCustomLayoutControl);
    class procedure RemoveItem(AItem: TdxCustomLayoutControl);
    class procedure SetForm(AControl: TdxCustomLayoutControl; AForm: TCustomForm);
    class function IsCustomized(AControl: TdxCustomLayoutControl): Boolean;
  end;

var
  CustomizedControls: TCustomizedControls;
  MouseHookHandle: HHOOK;
  WndProcHookHandle: HHOOK;

function MouseHookProc(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
var
  AProcessed: Boolean;
begin
  if Code = HC_ACTION then
    AProcessed :=
      CustomizedControls.ProcessMouseMessage(wParam, PMouseHookStruct(lParam)^)
  else
    AProcessed := False;
  Result := CallNextHookEx(MouseHookHandle, Code, wParam, lParam);
  if AProcessed then Result := 1;
end;

function WndProcHookProc(Code: Integer; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  if Code = HC_ACTION then
    CustomizedControls.ProcessWndProcMessage(PCWPStruct(lParam)^);
  Result := CallNextHookEx(WndProcHookHandle, Code, wParam, lParam);
end;

constructor TCustomizedControls.Create;
begin
  inherited;
  FForms := TList.Create;
  FItems := TList.Create;
  FPrevEnableds := TList.Create;
  SetHook(MouseHookHandle, WH_MOUSE, MouseHookProc);
  SetHook(WndProcHookHandle, WH_CALLWNDPROC, WndProcHookProc);
end;

destructor TCustomizedControls.Destroy;
begin
  ReleaseHook(WndProcHookHandle);
  ReleaseHook(MouseHookHandle);
  FPrevEnableds.Free;
  FItems.Free;
  FForms.Free;
  inherited;
end;

function TCustomizedControls.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TCustomizedControls.GetForm(Index: Integer): TCustomForm;
begin
  Result := FForms[Index];
end;

function TCustomizedControls.GetItem(Index: Integer): TdxCustomLayoutControl;
begin
  Result := TdxCustomLayoutControl(FItems[Index]);
end;

function TCustomizedControls.IndexOf(AItem: TdxCustomLayoutControl): Integer;
begin
  Result := FItems.IndexOf(AItem);
end;

procedure TCustomizedControls.InternalAddItem(AItem: TdxCustomLayoutControl);
begin
  FPrevEnableds.Add(Pointer(not EnableWindow(AItem.Handle, False)));
  FItems.Add(AItem);
  FForms.Count := Count;
end;

procedure TCustomizedControls.InternalRemoveItem(AItem: TdxCustomLayoutControl);
var
  AIndex: Integer;
begin
  AIndex := FItems.Remove(AItem);
  if AItem.HandleAllocated then
    EnableWindow(AItem.Handle, Boolean(FPrevEnableds[AIndex]));
  FPrevEnableds.Delete(AIndex);
end;

procedure TCustomizedControls.InternalSetForm(AControl: TdxCustomLayoutControl;
  AForm: TCustomForm);
begin
  FForms[IndexOf(AControl)] := AForm;
end;

function TCustomizedControls.ProcessMouseMessage(AMessage: WPARAM;
  AMessageData: TMouseHookStruct): Boolean;
var
  I: Integer;
  AItem: TdxCustomLayoutControl;
  P: TPoint;
  AControl: TWinControl;
begin
  Result := False;
  for I := 0 to Count - 1 do
  begin
    AItem := Items[I];
    if (AItem.Handle = AMessageData.hwnd) or
      (AItem.Parent.Handle = AMessageData.hwnd) and (GetCapture = 0) and
      PtInRect(AItem.BoundsRect, AItem.Parent.ScreenToClient(AMessageData.pt)) then
    begin
      Result := AMessage <> WM_MOUSEMOVE;  // to provide normal cursor processing (to call WM_SETCURSOR)
      P := AItem.ScreenToClient(AMessageData.pt);
      if GetCapture = AItem.Handle then
        AControl := AItem
      else
        if AItem.HScrollBarVisible and PtInRect(AItem.HScrollBar.BoundsRect, P) then
          AControl := AItem.HScrollBar
        else
          if AItem.VScrollBarVisible and PtInRect(AItem.VScrollBar.BoundsRect, P) then
            AControl := AItem.VScrollBar
          else
            AControl := AItem;
      P := AControl.ScreenToClient(AMessageData.pt);
      AControl.Perform(AMessage, GetMouseKeys, LPARAM(PointToSmallPoint(P)));
      Break;
    end;
  end;
end;

procedure TCustomizedControls.ProcessWndProcMessage(AMessageData: TCWPStruct);
var
  I: Integer;
  AParentForm: TWinControl;
  AHidden: Boolean;

  procedure CheckWindow(AWindow: HWND);
  const
    SetWindowPosParams: array[Boolean] of Integer = (SWP_SHOWWINDOW, SWP_HIDEWINDOW);
  begin
    SetWindowPos(AWindow, 0, 0, 0, 0, 0,
      SWP_NOZORDER or SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or
      SetWindowPosParams[AHidden]);
  end;

begin
  with AMessageData do
    if message = WM_SIZE then
      for I := 0 to Count - 1 do
      begin
        AParentForm := GetParentForm(Items[I]);
        if (AParentForm <> nil) and (Forms[I] <> nil) and Forms[I].Visible then
        begin
          AHidden := IsIconic(AParentForm.Handle) or IsIconic(Application.Handle);
          CheckWindow(Forms[I].Handle);
        end;
      end;
end;

class procedure TCustomizedControls.AddItem(AItem: TdxCustomLayoutControl);
begin
  if CustomizedControls = nil then
    CustomizedControls := Self.Create;
  CustomizedControls.InternalAddItem(AItem);
end;

class procedure TCustomizedControls.RemoveItem(AItem: TdxCustomLayoutControl);
begin
  CustomizedControls.InternalRemoveItem(AItem);
  if CustomizedControls.Count = 0 then
    FreeAndNil(CustomizedControls);
end;

class procedure TCustomizedControls.SetForm(AControl: TdxCustomLayoutControl;
  AForm: TCustomForm);
begin
  CustomizedControls.InternalSetForm(AControl, AForm);
end;

class function TCustomizedControls.IsCustomized(AControl: TdxCustomLayoutControl): Boolean;
begin
  Result :=
    (CustomizedControls <> nil) and (CustomizedControls.IndexOf(AControl) <> -1);
end;

{ TdxCustomLayoutControl }

constructor TdxCustomLayoutControl.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque]; 
{$IFDEF DELPHI7}
  ParentBackground := False;
{$ENDIF}
  with inherited LookAndFeel do
  begin
    Kind := lfStandard;
    NativeStyle := True;
  end;
  TabStop := False;
  Width := 300;
  Height := 250;
  FAbsoluteItems := TList.Create;
  FAutoControlAlignment := True;
  FAutoControlTabOrders := True;
  FAvailableItems := TList.Create;
  FBoldFont := TFont.Create;
  RefreshBoldFont;
  FCustomizeFormClass := TLayoutCustomizeForm;
  GetLookAndFeel.AddUser(Self);
  SetItems(GetDefaultGroupClass.Create(Owner{nil}));
  FItems.Hidden := True;
  FMayPack := True;
  //FGroups.UseIndent := False;
  CreateConstraints;
  if IsDesigning then dxLayoutDesigner.RegisterComponent(Self);
end;

destructor TdxCustomLayoutControl.Destroy;
begin
  if IsDesigning then dxLayoutDesigner.UnregisterComponent(Self);
  Customization := False;
  if not IsDesigning then
  begin
    if FStoreInIniFile then
      SaveToIniFile(FIniFileName);
    if FStoreInRegistry then
      SaveToRegistry(FRegistryPath);
  end;    
  SetItems(nil);
  DestroyAvailableItems;
  FAvailableItems.Free;
  LookAndFeel := nil;
  GetLookAndFeel.RemoveUser(Self);
  DestroyConstraints;
  dxLayoutTextMetrics.Unregister(FBoldFont);
  dxLayoutTextMetrics.Unregister(Font);
  FBoldFont.Free;
  FAbsoluteItems.Free;
  inherited;
end;

function TdxCustomLayoutControl.GetAbsoluteItem(Index: Integer): TdxCustomLayoutItem;
begin
  Result := FAbsoluteItems[Index];
end;

function TdxCustomLayoutControl.GetAbsoluteItemCount: Integer;
begin
  Result := FAbsoluteItems.Count;
end;

function TdxCustomLayoutControl.GetAlignmentConstraint(Index: Integer): TdxLayoutAlignmentConstraint;
begin
  Result := FAlignmentConstraints[Index];
end;

function TdxCustomLayoutControl.GetAlignmentConstraintCount: Integer;
begin
  Result := FAlignmentConstraints.Count;
end;

function TdxCustomLayoutControl.GetAvailableItem(Index: Integer): TdxCustomLayoutItem;
begin
  Result := FAvailableItems[Index];
end;

function TdxCustomLayoutControl.GetAvailableItemCount: Integer;
begin
  Result := FAvailableItems.Count;
end;

function TdxCustomLayoutControl.GetIsCustomizationMode: Boolean;
begin
  Result := TCustomizedControls.IsCustomized(Self);
end;

function TdxCustomLayoutControl.GetContentBounds: TRect;
begin
  Result := ViewInfo.ContentBounds;
end;

function TdxCustomLayoutControl.GetOccupiedClientWidth: Integer;
begin
  Result := ViewInfo.ItemsViewInfo.CalculateWidth;
end;

function TdxCustomLayoutControl.GetOccupiedClientHeight: Integer;
begin
  Result := ViewInfo.ItemsViewInfo.CalculateHeight;
end;

function TdxCustomLayoutControl.GetLayoutDirection: TdxLayoutDirection;
begin
  Result := FItems.LayoutDirection;
end;

procedure TdxCustomLayoutControl.SetAutoContentSizes(Value: TdxLayoutAutoContentSizes);
begin
  if FAutoContentSizes <> Value then
  begin
    FAutoContentSizes := Value;
    LayoutChanged;
  end;
end;

procedure TdxCustomLayoutControl.SetAutoControlAlignment(Value: Boolean);
begin
  if FAutoControlAlignment <> Value then
  begin
    FAutoControlAlignment := Value;
    LayoutChanged;
  end;
end;

procedure TdxCustomLayoutControl.SetAutoControlTabOrders(Value: Boolean);
begin
  if FAutoControlTabOrders <> Value then
  begin
    FAutoControlTabOrders := Value;
    LayoutChanged;
  end;
end;

procedure TdxCustomLayoutControl.SetCustomization(Value: Boolean);
begin
  if (FCustomization <> Value) and (not Value or HandleAllocated) then
  begin
    FCustomization := Value;
    LayoutChanged;
    if FCustomization then
    begin
      IsCustomizationMode := True;
      FCustomizeForm := TLayoutCustomizeFormClass(CustomizeFormClass).Create(Self);
      FCustomizeForm.Show;
      CustomizationModeForm := FCustomizeForm;
    end
    else
    begin
      with FCustomizeForm do
        if not (csDestroying in ComponentState) then
          Free;
      FCustomizeForm := nil;
      IsCustomizationMode := False;
    end;
    DoCustomization;
  end;
end;

procedure TdxCustomLayoutControl.SetCustomizationModeForm(Value: TCustomForm);
begin
  TCustomizedControls.SetForm(Self, Value);
end;

procedure TdxCustomLayoutControl.SetIsCustomizationMode(Value: Boolean);
begin
  if IsCustomizationMode <> Value then
    if Value then
      TCustomizedControls.AddItem(Self)
    else
      TCustomizedControls.RemoveItem(Self);
end;

procedure TdxCustomLayoutControl.SetIsPlaceControlsNeeded(Value: Boolean);
begin
  if FIsPlaceControlsNeeded <> Value then
  begin
    FIsPlaceControlsNeeded := Value;
    if Value then
      if (LookAndFeel <> nil) and TLookAndFeelAccess(LookAndFeel).ForceControlArrangement then
        SendMessage(Handle, CM_PLACECONTROLS, 0, 0)
      else
        PostMessage(Handle, CM_PLACECONTROLS, 0, 0);
  end;
end;

procedure TdxCustomLayoutControl.SetItems(Value: TdxLayoutGroup);
begin
  ItemWithMouse := nil;
  DestroyHandlers;
  FItems.Free;
  FItems := Value;
  if Value = nil then Exit;
  FItems.Container := Self;
  CreateHandlers;
end;

procedure TdxCustomLayoutControl.SetItemWithMouse(Value: TdxCustomLayoutItem);
begin
  if FItemWithMouse <> Value then
  begin
    if FItemWithMouse <> nil then
      FItemWithMouse.MouseLeave;
    FItemWithMouse := Value;
    if FItemWithMouse <> nil then
      FItemWithMouse.MouseEnter;
  end;
end;

procedure TdxCustomLayoutControl.SetLayoutDirection(Value: TdxLayoutDirection);
begin
  FItems.LayoutDirection := Value;
end;

procedure TdxCustomLayoutControl.SetLeftPos(Value: Integer);
var
  APrevLeftPos: Integer;
begin
  CheckLeftPos(Value);
  if FLeftPos <> Value then
  begin
    Update;
    APrevLeftPos := FLeftPos;
    FLeftPos := Value;
    LayoutChanged;
    ScrollContent(APrevLeftPos, FLeftPos, True);
  end;
end;

procedure TdxCustomLayoutControl.SetLookAndFeel(Value: TdxCustomLayoutLookAndFeel);
begin
  if FLookAndFeel <> Value then
  begin
    GetLookAndFeel.RemoveUser(Self);
    FLookAndFeel := Value;
    GetLookAndFeel.AddUser(Self);
    LookAndFeelChanged;
  end;
end;

procedure TdxCustomLayoutControl.SetShowHiddenGroupsBounds(Value: Boolean);
begin
  if FShowHiddenGroupsBounds <> Value then
  begin
    FShowHiddenGroupsBounds := Value;
    LayoutChanged;
  end;
end;

procedure TdxCustomLayoutControl.SetTopPos(Value: Integer);
var
  APrevTopPos: Integer;
begin
  CheckTopPos(Value);
  if FTopPos <> Value then
  begin
    Update;
    APrevTopPos := FTopPos;
    FTopPos := Value;
    LayoutChanged;
    ScrollContent(APrevTopPos, FTopPos, False);
  end;
end;

procedure TdxCustomLayoutControl.CreateHandlers;
begin
  FPainter := GetPainterClass.Create(Self);
  FViewInfo := GetViewInfoClass.Create(Self);
end;

procedure TdxCustomLayoutControl.DestroyHandlers;
begin
  FreeAndNil(FViewInfo);
  FreeAndNil(FPainter);
end;

procedure TdxCustomLayoutControl.CreateConstraints;
begin
  FAlignmentConstraints := TList.Create;
end;

procedure TdxCustomLayoutControl.DestroyConstraints;
var
  I: Integer;
begin
  for I := AlignmentConstraintCount - 1 downto 0 do
    AlignmentConstraints[I].Free;
  FreeAndNil(FAlignmentConstraints);
end;

procedure TdxCustomLayoutControl.AddAlignmentConstraint(AConstraint: TdxLayoutAlignmentConstraint);
begin
  FAlignmentConstraints.Add(AConstraint);
  AConstraint.FControl := Self;
  SetComponentName(AConstraint, Name + 'AlignmentConstraint', IsDesigning, IsLoading);
end;

procedure TdxCustomLayoutControl.RemoveAlignmentConstraint(AConstraint: TdxLayoutAlignmentConstraint);
begin
  FAlignmentConstraints.Remove(AConstraint);
  AConstraint.FControl := nil;
end;

procedure TdxCustomLayoutControl.RefreshBoldFont;
begin
  FBoldFont.Assign(Font);
  with FBoldFont do
    Style := Style + [fsBold];
  dxLayoutTextMetrics.Unregister(FBoldFont);
end;

procedure TdxCustomLayoutControl.AddAbsoluteItem(AItem: TdxCustomLayoutItem);
begin
  FAbsoluteItems.Add(AItem);
end;

procedure TdxCustomLayoutControl.RemoveAbsoluteItem(AItem: TdxCustomLayoutItem);
begin
  FAbsoluteItems.Remove(AItem);
end;

procedure TdxCustomLayoutControl.AddAvailableItem(AItem: TdxCustomLayoutItem);
begin
  FAvailableItems.Add(AItem);
  AItem.Container := Self;
  AvailableItemListChanged(AItem, True);
end;

procedure TdxCustomLayoutControl.RemoveAvailableItem(AItem: TdxCustomLayoutItem);
begin
  FAvailableItems.Remove(AItem);
  AvailableItemListChanged(AItem, False);
end;

procedure TdxCustomLayoutControl.DestroyAvailableItems;
var
  I: Integer;
begin
  for I := AvailableItemCount - 1 downto 0 do
    AvailableItems[I].Free;
end;

procedure TdxCustomLayoutControl.WMNCDestroy(var Message: TWMNCDestroy);
begin
  IsPlaceControlsNeeded := False;
  inherited;
end;

{$IFNDEF DELPHI7}

procedure TdxCustomLayoutControl.WMPrintClient(var Message: TWMPrintClient);
begin
  with Message do
    if Result <> 1 then
      if ((Flags and PRF_CHECKVISIBLE) = 0) or Visible then
        PaintHandler(TWMPaint(Message))
      else
        inherited
    else
      inherited;
end;

{$ENDIF}

procedure TdxCustomLayoutControl.CMControlChange(var Message: TCMControlChange);
var
  AControl: TControl;
  P: TPoint;
  AHitTest: TdxCustomLayoutHitTest;
  AGroup: TdxLayoutGroup;
  AIndex: Integer;
begin
  inherited;
  if not (IsLoading or IsDestroying) then
  begin
    AControl := Message.Control;
    if Message.Inserting then
    begin
      if (csAncestor in AControl.ComponentState) or
        IsInternalControl(AControl) or (FindItem(AControl) <> nil) then
        Exit;
      P := AControl.BoundsRect.TopLeft;
      AHitTest := ViewInfo.GetHitTest(P);
      if AHitTest is TdxCustomLayoutItemHitTest then
        if AHitTest is TdxLayoutGroupHitTest then
          AGroup := TdxLayoutGroupHitTest(AHitTest).Item
        else
          AGroup := TdxCustomLayoutItemHitTest(AHitTest).Item.Parent
      else
        AGroup := Items;
      AIndex := AGroup.ViewInfo.GetInsertionPos(P);
      AGroup.CreateItemForControl(AControl).VisibleIndex := AIndex;
    end
    else
      FindItem(AControl).Free;
  end;
end;

procedure TdxCustomLayoutControl.CMDialogChar(var Message: TCMDialogChar);
begin
  if FItems.ProcessDialogChar(Message.CharCode) then
    Message.Result := 1
  else
    inherited;
end;

{procedure TdxCustomLayoutControl.CMFreeItem(var Message: TMessage);
begin
  TObject(Message.WParam).Free;
end;}

procedure TdxCustomLayoutControl.CMPlaceControls(var Message: TMessage);
begin
  IsPlaceControlsNeeded := False;
  Painter.PlaceControls;
end;

procedure TdxCustomLayoutControl.AlignControls(AControl: TControl; var Rect: TRect);
begin
end;

function TdxCustomLayoutControl.AllowAutoDragAndDropAtDesignTime(X, Y: Integer;
  Shift: TShiftState): Boolean;
begin
  Result := not GetDesignHitTest(X, Y, Shift);
end;

function TdxCustomLayoutControl.AllowDragAndDropWithoutFocus: Boolean;
begin
  Result := FCustomization;
end;

procedure TdxCustomLayoutControl.BoundsChanged;
begin
  inherited;
  LayoutChanged;
end;

function TdxCustomLayoutControl.CanDrag(X, Y: Integer): Boolean;
begin
  Result := inherited CanDrag(X, Y) and not IsDesigning;
end;

procedure TdxCustomLayoutControl.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TdxCustomLayoutControl.FontChanged;
begin
  inherited;
  dxLayoutTextMetrics.Unregister(Font);
  RefreshBoldFont;
  LookAndFeelChanged;
end;

procedure TdxCustomLayoutControl.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  inherited;
  if Owner = Root then
  begin
    Proc(FItems);
    for I := 0 to AvailableItemCount - 1 do
      Proc(AvailableItems[I]);
    for I := 0 to AlignmentConstraintCount - 1 do
      Proc(AlignmentConstraints[I]);
  end;
end;

function TdxCustomLayoutControl.GetCursor(X, Y: Integer): TCursor;
var
  AHitTest: TdxCustomLayoutHitTest;
begin
  AHitTest := ViewInfo.GetHitTest(X, Y);
  if AHitTest is TdxCustomLayoutItemHitTest then
    Result := TdxCustomLayoutItemHitTest(AHitTest).Item.GetCursor(X, Y)
  else
    Result := crDefault;
  if Result = crDefault then
    Result := inherited GetCursor(X, Y);
end;

function TdxCustomLayoutControl.GetDesignHitTest(X, Y: Integer; Shift: TShiftState): Boolean;
var
  AHitTest: TdxCustomLayoutHitTest;
begin
  Result := inherited GetDesignHitTest(X, Y, Shift);
  if not Result then
  begin
    AHitTest := ViewInfo.GetHitTest(X, Y);
    Result :=
      not (ssRight in Shift) and not FRightButtonPressed and
      (AHitTest is TdxCustomLayoutItemHitTest) and
      not TdxCustomLayoutItemHitTest(AHitTest).Item.IsRoot and
      not dxLayoutDesigner.IsToolSelected;
  end;
  FRightButtonPressed := ssRight in Shift;
end;

function TdxCustomLayoutControl.HasBackground: Boolean;
begin
  Result := {$IFDEF DELPHI7}ThemeServices.ThemesEnabled and ParentBackground{$ELSE}inherited HasBackground{$ENDIF};
end;

procedure TdxCustomLayoutControl.Loaded;
begin
  inherited;
  if not IsDesigning then
  begin
    if FStoreInIniFile then
      LoadFromIniFile(FIniFileName);
    if FStoreInRegistry then
      LoadFromRegistry(FRegistryPath);
  end;    
  LookAndFeelChanged;
end;

procedure TdxCustomLayoutControl.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  AssignItemWithMouse(X, Y);
  if ItemWithMouse <> nil then
    ItemWithMouse.MouseDown(Button, Shift, X, Y);
  inherited;
end;

procedure TdxCustomLayoutControl.MouseLeave(AControl: TControl);
begin
  inherited;
  ItemWithMouse := nil;
end;

procedure TdxCustomLayoutControl.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  AssignItemWithMouse(X, Y);
  if ItemWithMouse <> nil then
    ItemWithMouse.MouseMove(Shift, X, Y);
  inherited;
end;

procedure TdxCustomLayoutControl.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  AssignItemWithMouse(X, Y);
  if ItemWithMouse <> nil then
    ItemWithMouse.MouseUp(Button, Shift, X, Y);
end;

procedure TdxCustomLayoutControl.Paint;
begin
  inherited;
  if not IsUpdateLocked then Painter.Paint;
end;

procedure TdxCustomLayoutControl.SetName(const Value: TComponentName);
var
  AOldName: string;

  function GetItem(ACaller: TComponent; Index: Integer): TComponent;
  begin
    with TdxCustomLayoutControl(ACaller) do
      if Index = 0 then
        Result := Items
      else
        Result := AbsoluteItems[Index - 1];
  end;

  function GetAlignmentConstraint(ACaller: TComponent; Index: Integer): TComponent;
  begin
    Result := TdxCustomLayoutControl(ACaller).AlignmentConstraints[Index];
  end;

begin
  AOldName := Name;
  inherited;
  RenameComponents(Self, Owner, Name, AOldName, 1 + AbsoluteItemCount, @GetItem);
  RenameComponents(Self, Owner, Name, AOldName,
    AlignmentConstraintCount, @GetAlignmentConstraint);
  if IsDesigning then
    dxLayoutDesigner.ComponentNameChanged(Self);
end;

{$IFDEF DELPHI7}

procedure TdxCustomLayoutControl.SetParentBackground(Value: Boolean);
begin    
  if Value then
    ControlStyle := ControlStyle - [csOpaque]
  else
    ControlStyle := ControlStyle + [csOpaque];
  inherited;
end;

{$ENDIF}

procedure TdxCustomLayoutControl.WndProc(var Message: TMessage);
begin
  if (WM_MOUSEFIRST <= Message.Msg) and (Message.Msg <= WM_MOUSELAST) and
    IsCustomizationMode then
    Dispatch(Message)
  else
    inherited;
end;

procedure TdxCustomLayoutControl.WriteState(Writer: TWriter);
begin
  if HandleAllocated then
    SendMessage(Handle, WM_SETREDRAW, 0, 0);
  try
    Items.RestoreItemControlSize;
    inherited;
  finally
    if HandleAllocated then
      SendMessage(Handle, WM_SETREDRAW, 1, 0);
    LayoutChanged;
  end;
end;

procedure TdxCustomLayoutControl.InitScrollBarsParameters;
begin
  inherited;
  SetScrollBarInfo(sbHorizontal, 0, ViewInfo.ContentWidth - 1,
    ScrollStep, ViewInfo.ClientWidth, LeftPos, True, True);
  SetScrollBarInfo(sbVertical, 0, ViewInfo.ContentHeight - 1,
    ScrollStep, ViewInfo.ClientHeight, TopPos, True, True);
end;

function TdxCustomLayoutControl.NeedsToBringInternalControlsToFront: Boolean;
begin
  Result := True;
end;

procedure TdxCustomLayoutControl.Scroll(AScrollBarKind: TScrollBarKind;
  AScrollCode: TScrollCode; var AScrollPos: Integer);

  function GetContentPos: Integer;
  begin
    if AScrollBarKind = sbHorizontal then
      Result := LeftPos
    else
      Result := TopPos;
  end;

  procedure SetContentPos(Value: Integer);
  begin
    if AScrollBarKind = sbHorizontal then
      LeftPos := Value
    else
      TopPos := Value;
  end;

  function GetPageScrollStep: Integer;
  begin
    if AScrollBarKind = sbHorizontal then
      Result := ClientWidth
    else
      Result := ClientHeight;
  end;

begin
  inherited;
  case AScrollCode of
    scLineUp:
      SetContentPos(GetContentPos - ScrollStep);
    scLineDown:
      SetContentPos(GetContentPos + ScrollStep);
    scPageUp:
      SetContentPos(GetContentPos - GetPageScrollStep);
    scPageDown:
      SetContentPos(GetContentPos + GetPageScrollStep);
    scTrack:
      SetContentPos(AScrollPos);
  end;
  AScrollPos := GetContentPos;
end;

function TdxCustomLayoutControl.CanDragAndDrop: Boolean;
begin
  Result := not IsDesigning or not (csInline in Owner.ComponentState);
end;

function TdxCustomLayoutControl.GetDragAndDropObjectClass: TcxDragAndDropObjectClass;
begin
  Result := TdxLayoutControlDragAndDropObject;
end;

function TdxCustomLayoutControl.StartDragAndDrop(const P: TPoint): Boolean;
var
  AHideHiddenGroupsFromHitTest: Boolean;
  AHitTest: TdxCustomLayoutHitTest;
  AItem: TdxCustomLayoutItem;
begin
  Result := False;
  if IsCustomization and CanDragAndDrop then
  begin
    AHideHiddenGroupsFromHitTest := ViewInfo.HideHiddenGroupsFromHitTest;
    ViewInfo.HideHiddenGroupsFromHitTest := not IsDesigning;
    try
      AHitTest := ViewInfo.GetHitTest(P);
    finally
      ViewInfo.HideHiddenGroupsFromHitTest := AHideHiddenGroupsFromHitTest;
    end;
    if AHitTest is TdxCustomLayoutItemHitTest then
    begin
      AItem := TdxCustomLayoutItemHitTest(AHitTest).Item;
      if not AItem.IsRoot then
      begin
        (DragAndDropObject as TdxLayoutControlDragAndDropObject).Init(dsControl, AItem);
        Result := True;
      end
    end;
  end;  
end;

function TdxCustomLayoutControl.GetLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  Result := FLookAndFeel;
  if Result = nil then
    Result := dxLayoutDefaultLookAndFeel;
end;

procedure TdxCustomLayoutControl.BeginLookAndFeelDestroying;
begin
  BeginUpdate;
end;

procedure TdxCustomLayoutControl.EndLookAndFeelDestroying;
begin
  EndUpdate;
end;

procedure TdxCustomLayoutControl.LookAndFeelChanged;
begin
  UpdateLookAndFeelSkinName;
  if (LookAndFeel <> nil) and not DoubleBuffered then
    DoubleBuffered := LookAndFeel.NeedDoubleBuffered;
  if (FItems <> nil) and (GetLookAndFeel <> nil) then
    FItems.LookAndFeelChangedImpl;
end;

procedure TdxCustomLayoutControl.LookAndFeelDestroyed;
begin
  LookAndFeel := nil;
end;

procedure TdxCustomLayoutControl.SelectionChanged;
begin
  Items.SelectionChanged;
end;

function TdxCustomLayoutControl.GetPainterClass: TdxLayoutControlPainterClass;
begin
  Result := TdxLayoutControlPainter;
end;

function TdxCustomLayoutControl.GetViewInfoClass: TdxLayoutControlViewInfoClass;
begin
  Result := TdxLayoutControlViewInfo;
end;

procedure TdxCustomLayoutControl.AssignItemWithMouse(X, Y: Integer);
var
  AHitTest: TdxCustomLayoutHitTest;
begin
  AHitTest := ViewInfo.GetHitTest(X, Y);
  if AHitTest is TdxCustomLayoutItemHitTest then
    ItemWithMouse := TdxCustomLayoutItemHitTest(AHitTest).Item
  else
    ItemWithMouse := nil;
end;

procedure TdxCustomLayoutControl.AvailableItemListChanged(AItem: TdxCustomLayoutItem;
  AIsItemAdded: Boolean);
begin
  if FCustomization then
    TLayoutCustomizeForm(FCustomizeForm).AvailableItemListChanged(Aitem, AIsItemAdded);
end;

function TdxCustomLayoutControl.CalculateCustomizeFormBounds(const AFormBounds: TRect): TRect;
var
  AControlBounds, ADesktopBounds: TRect;
begin
  AControlBounds := BoundsRect;
  MapWindowPoints(Parent.Handle, 0, AControlBounds, 2);
  ADesktopBounds := GetDesktopWorkArea(AControlBounds.TopLeft);

  Result := AFormBounds;
  with AControlBounds do
  begin
    if (ADesktopBounds.Right - Right >= Result.Right - Result.Left) or
      (ADesktopBounds.Right - Right >= Left - ADesktopBounds.Left) then
      OffsetRect(Result, Right - Result.Left, 0)
    else
      OffsetRect(Result, Left - Result.Right, 0);
    OffsetRect(Result, 0,
      (Top + Bottom - (Result.Bottom - Result.Top)) div 2 - Result.Top);
  end;
  with ADesktopBounds do
  begin
    if Result.Left < Left then
      OffsetRect(Result, Left - Result.Left, 0);
    if Result.Right > Right then
      OffsetRect(Result, Right - Result.Right, 0);
    if Result.Top < Top then
      OffsetRect(Result, 0, Top - Result.Top);
  end;
end;

function TdxCustomLayoutControl.CanMultiSelect: Boolean;
begin
  Result := dxLayoutDesigner.GetDesigner(Self) <> nil;
end;

function TdxCustomLayoutControl.CanShowSelection: Boolean;
begin
  Result := {$IFDEF DELPHI6}True{$ELSE}CanMultiSelect{$ENDIF};
end;

procedure TdxCustomLayoutControl.CheckLeftPos(var Value: Integer);
begin
  if Value > ViewInfo.ContentWidth - ViewInfo.ClientWidth then
    Value := ViewInfo.ContentWidth - ViewInfo.ClientWidth;
  if Value < 0 then Value := 0;
end;

procedure TdxCustomLayoutControl.CheckPositions;
begin
  LeftPos := LeftPos;
  TopPos := TopPos;
end;

procedure TdxCustomLayoutControl.CheckTopPos(var Value: Integer);
begin
  if Value > ViewInfo.ContentHeight - ViewInfo.ClientHeight then
    Value := ViewInfo.ContentHeight - ViewInfo.ClientHeight;
  if Value < 0 then Value := 0;
end;

procedure TdxCustomLayoutControl.DoCustomization;
begin
  if Assigned(FOnCustomization) then FOnCustomization(Self);
end;

procedure TdxCustomLayoutControl.DragAndDropBegan;
begin
  if FCustomization then
    TLayoutCustomizeForm(FCustomizeForm).DragAndDropBegan;
end;

function TdxCustomLayoutControl.GetAlignmentConstraintClass: TdxLayoutAlignmentConstraintClass;
begin
  Result := TdxLayoutAlignmentConstraint;
end;

function TdxCustomLayoutControl.GetDefaultGroupClass: TdxLayoutGroupClass;
begin
  Result := TdxLayoutGroup;
end;

function TdxCustomLayoutControl.GetDefaultItemClass: TdxLayoutItemClass;
begin
  Result := TdxLayoutItem;
end;

function TdxCustomLayoutControl.IsCustomization: Boolean;
begin
  Result := Customization or IsDesigning;
end;

function TdxCustomLayoutControl.IsUpdateLocked: Boolean;
begin
  Result := FUpdateLockCount <> 0;
end;

procedure TdxCustomLayoutControl.LayoutChanged;
begin
  if FItems <> nil then FItems.Changed;
end;

{procedure TdxCustomLayoutControl.PostFree(AObject: TObject);
begin
  if HandleAllocated then
    PostMessage(Handle, CM_FREEITEM, WParam(AObject), 0);
end;}

procedure TdxCustomLayoutControl.ScrollContent(APrevPos, ACurPos: Integer;
  AHorzScrolling: Boolean);
var
  ADelta: Integer;
  AScrollBounds: TRect;
begin
  if not HandleAllocated then Exit;
  ADelta := -(ACurPos - APrevPos);
  AScrollBounds := ViewInfo.ClientBounds;
  //ValidateRect(Handle, @AScrollBounds);
  ScrollWindowEx(Handle, Ord(AHorzScrolling) * ADelta, Ord(not AHorzScrolling) * ADelta,
    @AScrollBounds, nil, 0, nil, SW_INVALIDATE or SW_ERASE{ or SW_SCROLLCHILDREN bug in WinAPI});
  UpdateWindow(Handle);
end;

procedure TdxCustomLayoutControl.UpdateLookAndFeelSkinName;
var
  ASkinName: string;
begin
  if LookAndFeel = nil then
    ASkinName := ''
  else
    ASkinName := LookAndFeel.InternalName;

  with inherited LookAndFeel do
  begin
    NativeStyle := ASkinName = '';
    SkinName := ASkinName;
  end;
end;

type
  PdxLayoutItemPosition = ^TdxLayoutItemPosition;
  TdxLayoutItemPosition = record
    Item: TdxCustomLayoutItem;
    ParentName: string;
    Index: Integer;
  end;

function ComparePositions(Item1, Item2: Pointer): Integer;
begin
  Result := PdxLayoutItemPosition(Item1).Index - PdxLayoutItemPosition(Item2).Index;
end;

procedure TdxCustomLayoutControl.LoadFromCustomIniFile(AIniFile: TCustomIniFile;
  const ARootSection: string);
var
  AItems: TList;
  APositions: TList;
  AItemCount, I: Integer;

  function CreateItemsList: TList;
  begin
    Result := TList.Create;
    Result.Count := AbsoluteItemCount;
    Move(FAbsoluteItems.List^, Result.List^, Result.Count * SizeOf(Pointer));
  end;

  procedure PrepareItems;
  var
    I: Integer;
  begin
    for I := 0 to AbsoluteItemCount - 1 do
      AbsoluteItems[I].Parent := nil;
  end;

  function GetItemSection(AIndex: Integer): string;
  begin
    Result := 'Item' + IntToStr(AIndex);
    if ARootSection <> '' then
      Result := ARootSection + '\' + Result;
  end;

  procedure AddPosition(AItem: TdxCustomLayoutItem; const AParentName: string;
    AIndex: Integer);
  var
    APosition: PdxLayoutItemPosition;
  begin
    New(APosition);
    with APosition^ do
    begin
      Item := AItem;
      ParentName := AParentName;
      Index := AIndex;
    end;
    APositions.Add(APosition);
  end;

  procedure LoadItem(const ASection: string);
  var
    AName, AParentName: string;
    AItem: TdxCustomLayoutItem;
    AIndex: Integer;
    AGroup: TdxLayoutGroup;
  begin
    AName := AIniFile.ReadString(ASection, 'Name', '');
    if AName = '' then Exit;
    AItem := FindItem(AName);
    AItems.Remove(AItem);
    if AItem = nil then
    begin
      AItem := CreateGroup;
      AItem.Name := AName;
    end;

    AParentName := AIniFile.ReadString(ASection, 'ParentName', '');
    AIndex := AIniFile.ReadInteger(ASection, 'Index', -1);
    AddPosition(AItem, AParentName, AIndex);

    if AItem is TdxLayoutGroup then
    begin
      AGroup := TdxLayoutGroup(AItem);
      AGroup.Hidden := AIniFile.ReadBool(ASection, 'Hidden', False);
      AGroup.LayoutDirection :=
        TdxLayoutDirection(AIniFile.ReadInteger(ASection, 'LayoutDirection', 0));
      if AGroup.IsUserDefined and not AGroup.Hidden then
        AGroup.Caption := AIniFile.ReadString(ASection, 'Caption', '');
    end;
  end;

  procedure DestroyNonLoadedItems;
  var
    I: Integer;

    function CanDestroy(AItem: TdxCustomLayoutItem): Boolean;

      function ItemExists(AItem: Pointer): Boolean;
      var
        I: Integer;
      begin
        for I := 0 to AbsoluteItemCount - 1 do
        begin
          Result := AbsoluteItems[I] = AItem;
          if Result then Exit;
        end;
        Result := False;
      end;

    begin
      Result := ItemExists(AItem) and
        (AItem is TdxLayoutGroup) and TdxLayoutGroup(AItem).CanDestroy;
    end;

  begin
    for I := 0 to AItems.Count - 1 do
      if CanDestroy(AItems[I]) then
        TObject(AItems[I]).Free;
  end;

  procedure UpdatePositions;
  var
    I: Integer;
    APosition: PdxLayoutItemPosition;
  begin
    APositions.Sort(ComparePositions);
    for I := 0 to APositions.Count - 1 do
    begin
      APosition := PdxLayoutItemPosition(APositions[I]);
      with APosition^ do
      begin
        Item.Parent := FindItem(ParentName) as TdxLayoutGroup;
        Item.Index := Index;
      end;
    end;
  end;

begin
  AItems := CreateItemsList;
  APositions := TList.Create;
  try
    AItemCount := AIniFile.ReadInteger(ARootSection, 'ItemCount', -1);
    if AItemCount = -1 then Exit;
    BeginUpdate;
    try
      MayPack := False;
      try
        PrepareItems;
        for I := 0 to AItemCount - 1 do
          LoadItem(GetItemSection(I));
        DestroyNonLoadedItems;
        UpdatePositions;
      finally
        MayPack := True;
        Items.Pack;
      end;
    finally
      EndUpdate;
    end;
  finally
    for I := 0 to APositions.Count - 1 do
      Dispose(PdxLayoutItemPosition(APositions[I]));
    APositions.Free;
    AItems.Free;
  end;
end;

function CompareItemsByIsUserDefined(Item1, Item2: Pointer): Integer;
var
  AItem1, AItem2: TdxCustomLayoutItem;
begin
  AItem1 := TdxCustomLayoutItem(Item1);
  AItem2 := TdxCustomLayoutItem(Item2);
  if (AItem1 is TdxLayoutGroup) and (AItem2 is TdxLayoutGroup) then
    Result :=
      Ord(TdxLayoutGroup(AItem2).IsUserDefined) - Ord(TdxLayoutGroup(AItem1).IsUserDefined)
  else
    Result := Ord(AItem2 is TdxLayoutGroup) - Ord(AItem1 is TdxLayoutGroup);
  if Result = 0 then
    Result := Integer(Item1) - Integer(Item2);
end;

procedure TdxCustomLayoutControl.SaveToCustomIniFile(AIniFile: TCustomIniFile;
  const ARootSection: string);
var
  AItems: TList;
  I: Integer;

  function CreateItemsList: TList;
  begin
    Result := TList.Create;
    Result.Count := AbsoluteItemCount;
    Move(FAbsoluteItems.List^, Result.List^, Result.Count * SizeOf(Pointer));
    Result.Sort(CompareItemsByIsUserDefined);
    Result.Insert(0, Items);
  end;

  function GetItemSection(AIndex: Integer): string;
  begin
    Result := 'Item' + IntToStr(AIndex);
    if ARootSection <> '' then
      Result := ARootSection + '\' + Result;
  end;

  procedure DeletePrevSettings;
  var
    ABaseSectionName: string;
    ASections: TStringList;
    I: Integer;
  begin
    ABaseSectionName := ARootSection;
    if ABaseSectionName <> '' then
      ABaseSectionName := ABaseSectionName + '\';
    ASections := TStringList.Create;
    try
      AIniFile.ReadSections(ASections);
      for I := 0 to ASections.Count - 1 do
        if Copy(ASections[I], 1, Length(ABaseSectionName)) = ABaseSectionName then
          AIniFile.EraseSection(ASections[I]);
    finally
      ASections.Free;
    end;
  end;

  procedure SaveItem(const ASection: string; AItem: TdxCustomLayoutItem);
  var
    AGroup: TdxLayoutGroup;

    function GetParentName: string;
    begin
      if AItem.Parent <> nil then
        Result := AItem.Parent.Name
      else
        Result := '';
    end;

  begin
    AIniFile.WriteString(ASection, 'Name', AItem.Name);
    AIniFile.WriteString(ASection, 'ParentName', GetParentName);
    AIniFile.WriteInteger(ASection, 'Index', AItem.Index);

    if AItem is TdxLayoutGroup then
    begin
      AGroup := TdxLayoutGroup(AItem);
      AIniFile.WriteBool(ASection, 'Hidden', AGroup.Hidden);
      AIniFile.WriteInteger(ASection, 'LayoutDirection', Integer(AGroup.LayoutDirection));
      if AGroup.IsUserDefined and not AGroup.Hidden then
        AIniFile.WriteString(ASection, 'Caption', AItem.Caption);
    end;
  end;

begin
  DeletePrevSettings;
  AItems := CreateItemsList;
  try
    AIniFile.WriteInteger(ARootSection, 'ItemCount', AItems.Count);
    for I := 0 to AItems.Count - 1 do
      SaveItem(GetItemSection(I), AItems[I]);
  finally
    AItems.Free;
  end;
end;

procedure TdxCustomLayoutControl.Clear;
var
  I: Integer;
  AItem: TdxCustomLayoutItem;
begin
  MayPack := False;
  BeginUpdate;
  try
    for I := AbsoluteItemCount - 1 downto 0 do
    begin
      AItem := AbsoluteItems[I];
      if (AItem is TdxLayoutItem) and (TdxLayoutItem(AItem).Control <> nil) then
        TdxLayoutItem(AItem).Control.Free;
    end;

    while AbsoluteItemCount <> 0 do
      AbsoluteItems[0].Free;
  finally
    EndUpdate;
    MayPack := True;
  end;
end;

function TdxCustomLayoutControl.CreateAlignmentConstraint: TdxLayoutAlignmentConstraint;
begin
  Result := GetAlignmentConstraintClass.Create(Owner);
  AddAlignmentConstraint(Result);
end;

function TdxCustomLayoutControl.FindItem(AControl: TControl): TdxLayoutItem;
var
  I: Integer;
  AItem: TdxCustomLayoutItem;
begin
  for I := 0 to AbsoluteItemCount - 1 do
  begin
    AItem := AbsoluteItems[I];
    if AItem is TdxLayoutItem then
    begin
      Result := TdxLayoutItem(AItem);
      if Result.Control = AControl then Exit;
    end;
  end;
  Result := nil;
end;

function TdxCustomLayoutControl.FindItem(const AName: string): TdxCustomLayoutItem;
var
  I: Integer;
begin
  if AName <> '' then
  begin
    Result := Items;
    if SameText(Result.Name, AName) then Exit;
    for I := 0 to AbsoluteItemCount - 1 do
    begin
      Result := AbsoluteItems[I];
      if SameText(Result.Name, AName) then Exit;
    end;
  end;  
  Result := nil;
end;

function TdxCustomLayoutControl.GetHitTest(const P: TPoint): TdxCustomLayoutHitTest;
begin
  Result := ViewInfo.GetHitTest(P);
end;

function TdxCustomLayoutControl.GetHitTest(X, Y: Integer): TdxCustomLayoutHitTest;
begin
  Result := ViewInfo.GetHitTest(X, Y);
end;

procedure TdxCustomLayoutControl.BeginUpdate;
begin
  Inc(FUpdateLockCount);
  if (FUpdateLockCount = 1) and (FViewInfo <> nil) then
    FViewInfo.DestroyViewInfos;
end;

procedure TdxCustomLayoutControl.EndUpdate;
begin
  if FUpdateLockCount <> 0 then
  begin
    Dec(FUpdateLockCount);
    if not IsUpdateLocked then
    begin
      if FViewInfo <> nil then
        FViewInfo.CreateViewInfos;
      LookAndFeelChanged;  //LayoutChanged;
    end;
  end;
end;

function TdxCustomLayoutControl.CreateGroup(AGroupClass: TdxLayoutGroupClass = nil;
  AParent: TdxLayoutGroup = nil): TdxLayoutGroup;
begin
  if AGroupClass = nil then
    AGroupClass := GetDefaultGroupClass;
  Result := TdxLayoutGroup(CreateItem(AGroupClass, AParent));
end;

function TdxCustomLayoutControl.CreateItem(AItemClass: TdxCustomLayoutItemClass = nil;
  AParent: TdxLayoutGroup = nil): TdxCustomLayoutItem;
begin
  if AItemClass = nil then
    AItemClass := GetDefaultItemClass;
  Result := AItemClass.Create(Owner);
  AddAvailableItem(Result);
  Result.Parent := AParent;
  Modified;
  if IsDesigning then
    dxLayoutDesigner.ItemsChanged(Self);
end;

function TdxCustomLayoutControl.CreateItemForControl(AControl: TControl;
  AParent: TdxLayoutGroup = nil): TdxLayoutItem;
begin
  Result := TdxLayoutItem(CreateItem(GetDefaultItemClass, AParent));
  Result.Control := AControl;
end;

procedure TdxCustomLayoutControl.LoadFromIniFile(const AFileName: string);
var
  AIniFile: TMemIniFile;
begin
  if AFileName = '' then Exit;
  AIniFile := TMemIniFile.Create(AFileName);
  try
    LoadFromCustomIniFile(AIniFile, Name);
  finally
    AIniFile.Free;
  end;
end;

procedure TdxCustomLayoutControl.LoadFromRegistry(const ARegistryPath: string);
var
  AIniFile: TRegistryIniFile;
begin
  if ARegistryPath = '' then Exit;
  AIniFile := TRegistryIniFile.Create(ARegistryPath);
  try
    LoadFromCustomIniFile(AIniFile, '');
  finally
    AIniFile.Free;
  end;
end;

procedure TdxCustomLayoutControl.LoadFromStream(AStream: TStream);
var
  AIniFile: TMemIniFile;
  AStrings: TStringList;
begin
  AIniFile := TMemIniFile.Create('');
  AStrings := TStringList.Create;
  try
    AStrings.LoadFromStream(AStream);
    AIniFile.SetStrings(AStrings);
    LoadFromCustomIniFile(AIniFile, '');
  finally
    AStrings.Free;
    AIniFile.Free;
  end;
end;

procedure TdxCustomLayoutControl.SaveToIniFile(const AFileName: string);
var
  AIniFile: TMemIniFile;
begin
  if AFileName = '' then Exit;
  AIniFile := TMemIniFile.Create(AFileName);
  try
    SaveToCustomIniFile(AIniFile, Name);
    AIniFile.UpdateFile;
  finally
    AIniFile.Free;
  end;
end;

procedure TdxCustomLayoutControl.SaveToRegistry(const ARegistryPath: string);
var
  AIniFile: TRegistryIniFile;
begin
  if ARegistryPath = '' then Exit;
  AIniFile := TRegistryIniFile.Create(ARegistryPath);
  try
    SaveToCustomIniFile(AIniFile, '');
  finally
    AIniFile.Free;
  end;
end;

procedure TdxCustomLayoutControl.SaveToStream(AStream: TStream);
var
  AIniFile: TMemIniFile;
  AStrings: TStringList;
begin
  AIniFile := TMemIniFile.Create('');
  AStrings := TStringList.Create;
  try
    SaveToCustomIniFile(AIniFile, '');
    AIniFile.GetStrings(AStrings);
    AStrings.SaveToStream(AStream);
  finally
    AStrings.Free;
    AIniFile.Free;
  end;
end;

{ THitTests }

type
  THitTests = class
  private
    FItems: TList;
    function GetCount: Integer;
    function GetInstance(AClass: TdxCustomLayoutHitTestClass): TdxCustomLayoutHitTest;
    function GetItem(Index: Integer): TdxCustomLayoutHitTest;
  protected
    function GetObjectByClass(AClass: TdxCustomLayoutHitTestClass): TdxCustomLayoutHitTest;
    property Count: Integer read GetCount;
    property Items[Index: Integer]: TdxCustomLayoutHitTest read GetItem;
  public
    constructor Create;
    destructor Destroy; override;
    property Instances[AClass: TdxCustomLayoutHitTestClass]: TdxCustomLayoutHitTest read GetInstance; default;
  end;

var  
  HitTests: THitTests;

constructor THitTests.Create;
begin
  inherited;
  FItems := TList.Create;
end;

destructor THitTests.Destroy;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Items[I].Free;
  FItems.Free;
  inherited;
end;

function THitTests.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function THitTests.GetInstance(AClass: TdxCustomLayoutHitTestClass): TdxCustomLayoutHitTest;
begin
  Result := GetObjectByClass(AClass);
  if Result = nil then
  begin
    Result := AClass.Create;
    FItems.Add(Result);
  end;  
end;

function THitTests.GetItem(Index: Integer): TdxCustomLayoutHitTest;
begin
  Result := FItems[Index];
end;

function THitTests.GetObjectByClass(AClass: TdxCustomLayoutHitTestClass): TdxCustomLayoutHitTest;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := Items[I];
    if Result.ClassType = AClass then Exit;
  end;
  Result := nil;
end;

{ TdxCustomLayoutHitTest }

function TdxCustomLayoutHitTest.Cursor: TCursor;
begin
  Result := crDefault;
end;

class function TdxCustomLayoutHitTest.HitTestCode: Integer;
begin
  Result := htError;
end;

class function TdxCustomLayoutHitTest.Instance: TdxCustomLayoutHitTest;
begin
  Result := HitTests.Instances[Self];
end;

{ TdxLayoutNoneHitTest }

class function TdxLayoutNoneHitTest.HitTestCode: Integer;
begin
  Result := htNone;
end;

{ TdxLayoutItemHitTest }

function TdxLayoutItemHitTest.GetItem: TdxLayoutItem;
begin
  Result := TdxLayoutItem(inherited Item);
end;

procedure TdxLayoutItemHitTest.SetItem(Value: TdxLayoutItem);
begin
  inherited Item := Value;
end;

class function TdxLayoutItemHitTest.HitTestCode: Integer;
begin
  Result := htItem;
end;

{ TdxLayoutGroupHitTest }

function TdxLayoutGroupHitTest.GetItem: TdxLayoutGroup;
begin
  Result := TdxLayoutGroup(inherited Item);
end;

procedure TdxLayoutGroupHitTest.SetItem(Value: TdxLayoutGroup);
begin
  inherited Item := Value;
end;

class function TdxLayoutGroupHitTest.HitTestCode: Integer;
begin
  Result := htGroup;
end;

{ TdxLayoutCustomizeFormHitTest }

class function TdxLayoutCustomizeFormHitTest.HitTestCode: Integer;
begin
  Result := htCustomizeForm;
end;

{ TdxLayoutClientAreaHitTest }

class function TdxLayoutClientAreaHitTest.HitTestCode: Integer;
begin
  Result := htClientArea;
end;

{ TdxCustomLayoutControlHandler }

constructor TdxCustomLayoutControlHandler.Create(AControl: TdxCustomLayoutControl);
begin
  inherited Create;
  FControl := AControl;
end;

function TdxCustomLayoutControlHandler.GetViewInfo: TdxLayoutControlViewInfo;
begin
  Result := FControl.ViewInfo;
end;

{ TdxCustomLayoutItemElementPainter }

constructor TdxCustomLayoutItemElementPainter.Create(ACanvas: TcxCanvas;
  AViewInfo: TdxCustomLayoutItemElementViewInfo);
begin
  inherited Create;
  FCanvas := ACanvas;
  FViewInfo := AViewInfo;
end;

function TdxCustomLayoutItemElementPainter.GetLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  Result := FViewInfo.LookAndFeel;
end;

{ TdxCustomLayoutItemCaptionPainter }

function TdxCustomLayoutItemCaptionPainter.GetViewInfo: TdxCustomLayoutItemCaptionViewInfo;
begin
  Result := TdxCustomLayoutItemCaptionViewInfo(inherited ViewInfo);
end;

procedure TdxCustomLayoutItemCaptionPainter.AfterDrawText;
begin
{$IFDEF DELPHI7}
  with Canvas do
    Brush.Style := bsSolid;
{$ENDIF}
end;

procedure TdxCustomLayoutItemCaptionPainter.BeforeDrawText;
{$IFDEF DELPHI7}
var
  R: TRect;
{$ENDIF}
begin
  with Canvas do
  begin           
  {$IFDEF DELPHI7}
    if ViewInfo.IsTransparent then
    begin
      R := ViewInfo.TextAreaBounds;
      ThemeServices.DrawParentBackground(ViewInfo.Item.Container.Handle,
        Handle, nil, True, @R);
      Brush.Style := bsClear;
    end
    else
      Brush.Color := ViewInfo.Color;
  {$ELSE}
    Brush.Color := ViewInfo.Color;
  {$ENDIF}
    Font := ViewInfo.Font;
    Font.Color := ViewInfo.TextColor;
    if ViewInfo.IsTextUnderlined then
      Font.Style := Font.Style + [fsUnderline];
  end;
end;

procedure TdxCustomLayoutItemCaptionPainter.DrawBackground;
begin
  if not ViewInfo.IsTransparent then 
    with Canvas do
    begin
      Brush.Color := ViewInfo.Color;
      FillRect(ViewInfo.Bounds);
    end;
end;

procedure TdxCustomLayoutItemCaptionPainter.DrawText;
begin
  with ViewInfo do
    Canvas.DrawText(Text, TextAreaBounds, CalculateTextFlags, Enabled);
end;

procedure TdxCustomLayoutItemCaptionPainter.Paint;
begin
  DrawBackground;
  if ViewInfo.Text <> '' then
  begin
    BeforeDrawText;
    DrawText;
    AfterDrawText;
  end;
end;

{ TdxCustomLayoutItemPainter }

constructor TdxCustomLayoutItemPainter.Create(ACanvas: TcxCanvas;
  AViewInfo: TdxCustomLayoutItemViewInfo);
begin
  inherited Create;
  FCanvas := ACanvas;
  FViewInfo := AViewInfo;
end;

function TdxCustomLayoutItemPainter.GetLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  Result := FViewInfo.LookAndFeel;
end;

procedure TdxCustomLayoutItemPainter.DrawCaption;
begin
  with GetCaptionPainterClass.Create(Canvas, ViewInfo.CaptionViewInfo) do
    try
      Paint;
    finally
      Free;
    end;
end;

procedure TdxCustomLayoutItemPainter.DrawSelection;
begin
  with ViewInfo.Item.Container.Painter.GetCustomizationCanvas do
    try
      Brush.Style := bsClear;
      Pen.Color := clHighlight;
      Pen.Style := psDot;
      with ViewInfo.Bounds do
        Polyline([TopLeft, Point(Right - 1, Top), Point(Right - 1, Bottom - 1),
          Point(Left, Bottom - 1), TopLeft]);
      Pen.Style := psSolid;
      Brush.Style := bsSolid;
    finally
      Free;
    end;
end;

procedure TdxCustomLayoutItemPainter.InternalDrawSelection;
begin
  if ViewInfo.Selected and ViewInfo.Item.Container.CanShowSelection then
    DrawSelection;
end;

procedure TdxCustomLayoutItemPainter.DrawSelections;
begin
  InternalDrawSelection;
end;

procedure TdxCustomLayoutItemPainter.Paint;
begin
  if ViewInfo.HasCaption then DrawCaption;
  InternalDrawSelection;
  Canvas.ExcludeClipRect(ViewInfo.Bounds);
end;

{ TdxLayoutItemControlPainter }

function TdxLayoutItemControlPainter.GetViewInfo: TdxLayoutItemControlViewInfo;
begin
  Result := TdxLayoutItemControlViewInfo(inherited ViewInfo);
end;

procedure TdxLayoutItemControlPainter.DrawBorders;
var
  R: TRect;

  procedure DrawSingleBorder;
  begin
    Canvas.FrameRect(ViewInfo.Bounds, ViewInfo.BorderColor);
  end;

  procedure DrawStandardBorder;
  begin
    Canvas.DrawEdge(R, True, True);
    InflateRect(R, -1, -1);
    Canvas.DrawEdge(R, True, False);
  end;

  procedure DrawFlatBorder;
  begin
    Canvas.DrawEdge(R, True, True);
    InflateRect(R, -1, -1);
    Canvas.FrameRect(R, clBtnFace);
  end;

begin
  R := ViewInfo.Bounds;
  case ViewInfo.BorderStyle of
    lbsSingle:
      DrawSingleBorder;
    lbsFlat:
      DrawFlatBorder;
    lbsStandard:
      DrawStandardBorder;
  end;
end;

procedure TdxLayoutItemControlPainter.Paint;
begin
  if ViewInfo.HasBorder then DrawBorders;
end;

{ TdxLayoutItemPainter }

function TdxLayoutItemPainter.GetViewInfo: TdxLayoutItemViewInfo;
begin
  Result := TdxLayoutItemViewInfo(inherited ViewInfo);
end;

function TdxLayoutItemPainter.GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass;
begin
  Result := TdxLayoutItemCaptionPainter;
end;

function TdxLayoutItemPainter.GetControlPainterClass: TdxLayoutItemControlPainterClass;
begin
  Result := TdxLayoutItemControlPainter;
end;

procedure TdxLayoutItemPainter.DrawControl;
begin
  with GetControlPainterClass.Create(Canvas, ViewInfo.ControlViewInfo) do
    try
      Paint;
    finally
      Free;
    end;
end;

procedure TdxLayoutItemPainter.Paint;
begin
  if ViewInfo.HasControl and ViewInfo.ControlViewInfo.OpaqueControl then
    Canvas.ExcludeClipRect(ViewInfo.ControlViewInfo.ControlBounds);
  if not ViewInfo.IsTransparent then
    with Canvas do
    begin
      Brush.Color := ViewInfo.Color;
      FillRect(ViewInfo.Bounds);
    end;
  if ViewInfo.HasControl then DrawControl;
  inherited;
end;

{ TdxLayoutGroupPainter }

function TdxLayoutGroupPainter.GetViewInfo: TdxLayoutGroupViewInfo;
begin
  Result := TdxLayoutGroupViewInfo(inherited ViewInfo);
end;

function TdxLayoutGroupPainter.GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass;
begin
  Result := TdxLayoutGroupCaptionPainter;
end;

procedure TdxLayoutGroupPainter.DrawBorders;
var
  ASide: TdxLayoutSide;
begin
  if not ViewInfo.IsTransparent then  
    with Canvas do
    begin
      Brush.Color := ViewInfo.Color;
      for ASide := Low(ASide) to High(ASide) do
        FillRect(ViewInfo.BorderRestSpaceBounds[ASide]);
    end;
end;

procedure TdxLayoutGroupPainter.DrawBoundsFrame;
var
  R: TRect;
  ARgn1, ARgn2: HRGN;
begin
  Canvas.Pen.Style := psDashDot;
  Canvas.Pen.Color := ViewInfo.CaptionViewInfo.TextColor;
  Canvas.Brush.Style := bsClear;
  with ViewInfo.ClientBounds do
  begin
    R := ViewInfo.ClientBounds;
    ARgn1 := CreateRectRgnIndirect(R);
    InflateRect(R, -1, -1);
    ARgn2 := CreateRectRgnIndirect(R);
    CombineRgn(ARgn1, ARgn1, ARgn2, RGN_DIFF);
    DeleteObject(ARgn2);
    ExtSelectClipRgn(Canvas.Handle, ARgn1, RGN_OR);

    Canvas.Polyline([Point(Left, Top), Point(Right - 1, Top),
      Point(Right - 1, Bottom - 1), Point(Left, Bottom - 1), Point(Left, Top)]);

    ExtSelectClipRgn(Canvas.Handle, ARgn1, RGN_DIFF);
    DeleteObject(ARgn1);
  end;
  Canvas.Brush.Style := bsSolid;
end;

procedure TdxLayoutGroupPainter.DrawItems;
var
  I: Integer;
  AItemViewInfo: TdxCustomLayoutItemViewInfo;
begin
  for I := 0 to ViewInfo.ItemViewInfoCount - 1 do
  begin
    AItemViewInfo := ViewInfo.ItemViewInfos[I];
    with AItemViewInfo.GetPainterClass.Create(Canvas, AItemViewInfo) do
      try
        Paint;
      finally
        Free;
      end;
  end;
end;

procedure TdxLayoutGroupPainter.DrawItemsArea;
begin
  if not ViewInfo.IsTransparent then  
    with Canvas do
    begin
      Brush.Color := ViewInfo.Color;
      FillRect(ViewInfo.ClientBounds);
    end;
end;

procedure TdxLayoutGroupPainter.DrawSelections;
var
  I: Integer;
  AItemViewInfo: TdxCustomLayoutItemViewInfo;
begin
  inherited;
  for I := 0 to ViewInfo.ItemViewInfoCount - 1 do
  begin
    AItemViewInfo := ViewInfo.ItemViewInfos[I];
    with AItemViewInfo.GetPainterClass.Create(Canvas, AItemViewInfo) do
      try
        DrawSelections;
      finally
        Free;
      end;
  end;
end;

procedure TdxLayoutGroupPainter.Paint;
begin
  if ViewInfo.HasBorder then DrawBorders;
  DrawItems;
  DrawItemsArea;
  if ViewInfo.HasBoundsFrame then DrawBoundsFrame;
  inherited;
end;

{ TdxLayoutGroupCaptionStandardPainter }

procedure TdxLayoutGroupCaptionStandardPainter.DrawText;
{$IFDEF DELPHI7}
const
  Enableds: array[Boolean] of Integer = (DTT_GRAYED, 0);
{$ENDIF}
begin
{$IFDEF DELPHI7}
  if ThemeServices.ThemesEnabled then
    with ViewInfo do
      ThemeServices.DrawText(Canvas.Handle, ThemeServices.GetElementDetails(tbGroupBoxNormal),
        Text, TextAreaBounds, cxFlagsToDTFlags(CalculateTextFlags), Enableds[Enabled])
  else
    inherited;
{$ELSE}
  inherited;
{$ENDIF}  
end;

{ TdxLayoutGroupStandardPainter }

function TdxLayoutGroupStandardPainter.GetViewInfo: TdxLayoutGroupStandardViewInfo;
begin
  Result := TdxLayoutGroupStandardViewInfo(inherited ViewInfo);
end;

function TdxLayoutGroupStandardPainter.GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass;
begin
  Result := TdxLayoutGroupCaptionStandardPainter;
end;

procedure TdxLayoutGroupStandardPainter.DrawBorders;
begin
  inherited;
  DrawFrame;
end;

procedure TdxLayoutGroupStandardPainter.DrawFrame;
var
  R: TRect;
begin
{$IFDEF DELPHI7}
  if ThemeServices.ThemesEnabled then
  begin
    ThemeServices.DrawElement(Canvas.Handle, ThemeServices.GetElementDetails(tbGroupBoxNormal),
      ViewInfo.FrameBounds);
    Exit;
  end;  
{$ENDIF}
  R := ViewInfo.FrameBounds;
  with Canvas do
  begin
    DrawEdge(R, True, True);
    InflateRect(R, -1, -1);
    DrawEdge(R, False, False);
  end;
end;

{ TdxLayoutGroupOfficePainter }

function TdxLayoutGroupOfficePainter.GetCaptionPainterClass: TdxCustomLayoutItemCaptionPainterClass;
begin
  Result := TdxLayoutGroupCaptionPainter;
end;

procedure TdxLayoutGroupOfficePainter.DrawFrame;
var
  R: TRect;
begin
  R := ViewInfo.FrameBounds;
  with Canvas do
  begin
    DrawEdge(R, True, True, [bTop]);
    Inc(R.Top);
    DrawEdge(R, False, False, [bTop]);
  end;
end;

{ TdxLayoutGroupWebPainter }

function TdxLayoutGroupWebPainter.GetLookAndFeel: TdxLayoutWebLookAndFeel;
begin
  Result := TdxLayoutWebLookAndFeel(inherited LookAndFeel);
end;

function TdxLayoutGroupWebPainter.GetViewInfo: TdxLayoutGroupWebViewInfo;
begin
  Result := TdxLayoutGroupWebViewInfo(inherited ViewInfo);
end;

procedure TdxLayoutGroupWebPainter.DrawBorders;
begin
  DrawFrame;
  DrawCaptionSeparator;
  inherited;
end;

procedure TdxLayoutGroupWebPainter.DrawCaptionSeparator;
begin
  with Canvas do
  begin
    Brush.Color := ViewInfo.Color;
    FillRect(ViewInfo.CaptionSeparatorAreaBounds);
    Brush.Color := ViewInfo.Options.GetFrameColor;
    FillRect(ViewInfo.CaptionSeparatorBounds);
  end;  
end;

procedure TdxLayoutGroupWebPainter.DrawFrame;
var
  R: TRect;
  I: Integer;
begin
  R := ViewInfo.Bounds;
  for I := 1 to ViewInfo.Options.FrameWidth do
  begin
    Canvas.FrameRect(R, ViewInfo.Options.GetFrameColor);
    InflateRect(R, -1, -1);
  end;
end;

{ TdxLayoutControlPainter }

function TdxLayoutControlPainter.GetInternalCanvas: TcxCanvas;
begin
  Result := FControl.Canvas;
end;

procedure TdxLayoutControlPainter.MakeCanvasClipped(ACanvas: TcxCanvas);
begin
  ACanvas.IntersectClipRect(ViewInfo.ClientBounds);
end;

procedure TdxLayoutControlPainter.DrawEmptyArea;
var
  AContentR, AClientR: TRect;
begin
  if not ViewInfo.IsTransparent then
    with Canvas do
    begin
      Brush.Color := ViewInfo.LookAndFeel.GetEmptyAreaColor;
      AContentR := ViewInfo.ContentBounds;
      AClientR := ViewInfo.ClientBounds;
      FillRect(Rect(AContentR.Right, AClientR.Top, AClientR.Right, AClientR.Bottom));
      FillRect(Rect(AClientR.Left, AContentR.Bottom, AContentR.Right, AClientR.Bottom));
    end;
end;

procedure TdxLayoutControlPainter.DrawItems;
var
  AItemsViewInfo: TdxLayoutGroupViewInfo;
begin
  AItemsViewInfo := ViewInfo.ItemsViewInfo;
  with AItemsViewInfo.GetPainterClass.Create(Canvas, AItemsViewInfo) do
    try
      Paint;
    finally
      Free;
    end;
end;

procedure TdxLayoutControlPainter.PlaceControls;
var
  AControlViewInfos, AWinControlViewInfos: TList;

  procedure RetrieveControlViewInfos(AItemViewInfo: TdxCustomLayoutItemViewInfo);
  var
    I: Integer;
    AControlViewInfo: TdxLayoutItemControlViewInfo;
  begin
    if AItemViewInfo is TdxLayoutGroupViewInfo then
      with TdxLayoutGroupViewInfo(AItemViewInfo) do
        for I := 0 to ItemViewInfoCount - 1 do
          RetrieveControlViewInfos(ItemViewInfos[I])
    else
    begin
      AControlViewInfo := TdxLayoutItemViewInfo(AItemViewInfo).ControlViewInfo;
      if AControlViewInfo.Control <> nil then
        if AControlViewInfo.Control is TWinControl then
          AWinControlViewInfos.Add(AControlViewInfo)
        else
          AControlViewInfos.Add(AControlViewInfo);
    end;
  end;

  procedure ProcessControls;
  var
    I: Integer;
  begin
    for I := 0 to AControlViewInfos.Count - 1 do
      with TdxLayoutItemControlViewInfo(AControlViewInfos[I]) do
      begin
        Control.BoundsRect := ControlBounds;
        //ValidateRect(Self.Control.Handle, @ControlBounds);
      end;
  end;

  procedure ProcessWinControls;
  var
    AWindowsStruct: HDWP;
    I: Integer;
  begin
    AWindowsStruct := BeginDeferWindowPos(AWinControlViewInfos.Count);
    try
      for I := 0 to AWinControlViewInfos.Count - 1 do
        with TdxLayoutItemControlViewInfo(AWinControlViewInfos[I]), ControlBounds do
          DeferWindowPos(AWindowsStruct, (Control as TWinControl).Handle, 0,
            Left, Top, Right - Left, Bottom - Top, SWP_NOZORDER or SWP_NOACTIVATE);
    finally
      EndDeferWindowPos(AWindowsStruct);
    end;
  end;

  function CheckControlSizes(AControlViewInfos: TList): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    for I := 0 to AControlViewInfos.Count - 1 do
      with TdxLayoutItemControlViewInfo(AControlViewInfos[I]) do
      begin
        Result :=
          ((ItemViewInfo.AlignHorz = ahClient) or
             (Control.Width = ControlBounds.Right - ControlBounds.Left)) and
          ((ItemViewInfo.AlignVert = avClient) or
             (Control.Height = ControlBounds.Bottom - ControlBounds.Top));
        if not Result then
        begin
          Item.SaveOriginalControlSize;
          Break;
        end;
      end;
  end;

begin
  AControlViewInfos := TList.Create;
  AWinControlViewInfos := TList.Create;
  try
    Control.FIsPlacingControls := True;
    try
      RetrieveControlViewInfos(ViewInfo.ItemsViewInfo);
      ProcessControls;
      ProcessWinControls;
    finally
      Control.FIsPlacingControls := False;
    end;
    if not CheckControlSizes(AControlViewInfos) or
      not CheckControlSizes(AWinControlViewInfos) then
      Control.LayoutChanged;
  finally
    AWinControlViewInfos.Free;
    AControlViewInfos.Free;
  end;
end;

function TdxLayoutControlPainter.GetCanvas: TcxCanvas;
begin
  Result := InternalCanvas;
  MakeCanvasClipped(Result);
end;

function TdxLayoutControlPainter.GetCustomizationCanvas: TcxCanvas;
begin
  Result := TcxCustomizationCanvas.Create(Control);
  MakeCanvasClipped(Result);
end;

procedure TdxLayoutControlPainter.DrawSelections;
var
  AItemsViewInfo: TdxLayoutGroupViewInfo;
begin
  if Control.IsUpdateLocked then Exit;
  AItemsViewInfo := ViewInfo.ItemsViewInfo;
  with AItemsViewInfo.GetPainterClass.Create(Canvas, AItemsViewInfo) do
    try
      DrawSelections;
    finally
      Free;
    end;
end;

procedure TdxLayoutControlPainter.Paint;
var
  APrevClipRegion: TcxRegion;
begin
  FCanvas := GetCanvas;
  APrevClipRegion := FCanvas.GetClipRegion;
  { moved to TdxLayoutControlViewInfo.Calculate }//PlaceControls;  // because of selection drawing
  DrawItems;
  DrawEmptyArea;
//  PlaceControls;
  FCanvas.SetClipRegion(APrevClipRegion, roSet);
end;

{ TdxCustomLayoutItemElementViewInfo }

constructor TdxCustomLayoutItemElementViewInfo.Create(AItemViewInfo: TdxCustomLayoutItemViewInfo);
begin
  inherited Create;
  FItemViewInfo := AItemViewInfo;
end;

function TdxCustomLayoutItemElementViewInfo.GetHeight: Integer;
begin
  Result := FHeight;
  if Result = 0 then
  begin
    Result := Bounds.Bottom - Bounds.Top;
    if Result = 0 then
      Result := CalculateHeight;
  end;
end;

function TdxCustomLayoutItemElementViewInfo.GetItem: TdxCustomLayoutItem;
begin
  Result := FItemViewInfo.Item;
end;

function TdxCustomLayoutItemElementViewInfo.GetLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  Result := FItemViewInfo.LookAndFeel;
end;

function TdxCustomLayoutItemElementViewInfo.GetWidth: Integer;
begin
  Result := FWidth;
  if Result = 0 then
  begin
    Result := Bounds.Right - Bounds.Left;
    if Result = 0 then
      Result := CalculateWidth;
  end;
end;

procedure TdxCustomLayoutItemElementViewInfo.SetHeight(Value: Integer);
begin
  FHeight := Value;
end;

procedure TdxCustomLayoutItemElementViewInfo.SetWidth(Value: Integer);
begin
  FWidth := Value;
end;

function TdxCustomLayoutItemElementViewInfo.GetEnabled: Boolean;
begin
  Result := FItemViewInfo.Enabled;
end;

function TdxCustomLayoutItemElementViewInfo.GetEnabledForWork: Boolean;
begin
  Result := FItemViewInfo.EnabledForWork;
end;

function TdxCustomLayoutItemElementViewInfo.GetCursor(X, Y: Integer): TCursor;
begin
  Result := crDefault;
end;

function TdxCustomLayoutItemElementViewInfo.GetVisible: Boolean;
begin
  Result := False;
end;

procedure TdxCustomLayoutItemElementViewInfo.Invalidate(const ABounds: TRect);
begin
  Item.Container.InvalidateRect(ABounds, False);
end;

procedure TdxCustomLayoutItemElementViewInfo.MouseEnter;
begin
end;

procedure TdxCustomLayoutItemElementViewInfo.MouseLeave;
begin
  Pressed := False;
end;

procedure TdxCustomLayoutItemElementViewInfo.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Pressed := True;
end;

procedure TdxCustomLayoutItemElementViewInfo.MouseMove(Shift: TShiftState;
  X, Y: Integer);
begin
end;

procedure TdxCustomLayoutItemElementViewInfo.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Pressed := False;
end;

function TdxCustomLayoutItemElementViewInfo.WantsMouse(X, Y: Integer): Boolean;
begin
  Result := Visible and PtInRect(Bounds, Point(X, Y));
end;

procedure TdxCustomLayoutItemElementViewInfo.Calculate(const ABounds: TRect);
begin
  Bounds := ABounds;
end;

{ TdxCustomLayoutItemCaptionViewInfo }

function TdxCustomLayoutItemCaptionViewInfo.GetCanvas: TcxCanvas;
begin
  Result := ItemViewInfo.ContainerViewInfo.Canvas;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetIsCustomization: Boolean;
begin
  Result := FItemViewInfo.IsCustomization;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetTextHeight: Integer;
var
  R: TRect;
begin
  if Item.CachedTextHeight = 0 then
  begin
    PrepareCanvas;
    if MultiLine then
    begin
      R := Rect(0, 0, CalculateWidth - 1 {for disabling}, 0);
      Canvas.TextExtent(Text, R, CalculateTextFlags);
      Result := R.Bottom - R.Top;
    end
    else
      Result := Canvas.TextHeight(Text);
    Item.CachedTextHeight := Result;
  end
  else
    Result := Item.CachedTextHeight;
  if Text <> '' then Inc(Result);  // for disabling
end;

function TdxCustomLayoutItemCaptionViewInfo.GetTextWidth: Integer;
var
  AText: string;
begin
  AText := VisibleText;
  PrepareCanvas;
  Result := Canvas.TextWidth(AText);
  if AText <> '' then Inc(Result);  // for disabling
end;

procedure TdxCustomLayoutItemCaptionViewInfo.SetHotTracked(Value: Boolean);
begin
  if FHotTracked <> Value then
  begin
    FHotTracked := Value;
    Invalidate(HotTrackBounds);
  end;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetCursor(X, Y: Integer): TCursor;
begin
  if HotTracked and (htsHandPoint in HotTrackStyles) then
    Result := crcxHandPoint
  else
    Result := inherited GetCursor(X, Y);
end;

function TdxCustomLayoutItemCaptionViewInfo.GetVisible: Boolean;
begin
  Result := ItemViewInfo.HasCaption;
end;

procedure TdxCustomLayoutItemCaptionViewInfo.MouseLeave;
begin
  inherited;
  HotTracked := False;
end;

procedure TdxCustomLayoutItemCaptionViewInfo.MouseMove(Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if IsHotTrackable then
    HotTracked := IsPointInHotTrackBounds(Point(X, Y));
end;

procedure TdxCustomLayoutItemCaptionViewInfo.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  APressed: Boolean;
begin
  APressed := Pressed;
  inherited;
  if CanDoCaptionClick(X, Y) and APressed then
    Item.DoCaptionClick;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetColor: TColor;
begin
  Result := ItemViewInfo.Color;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetFont: TFont;
begin
  Result := Options.GetFont(Item.Container);
end;

function TdxCustomLayoutItemCaptionViewInfo.GetHotTrackBounds: TRect;
begin
  Result := TextAreaBounds;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetHotTrackStyles: TdxLayoutHotTrackStyles;
begin
  Result := Options.HotTrackStyles;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetIsDefaultColor: Boolean;
begin
  Result := ItemViewInfo.IsDefaultColor;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetIsHotTrackable: Boolean;
begin
  Result := not IsCustomization and EnabledForWork and Options.HotTrack;
end;

function TdxCustomLayoutItemCaptionViewInfo.CalculateTextFlags: Integer;
const
  MultiLines: array[Boolean] of Integer = (cxSingleLine, cxWordBreak);
  AlignsVert: array[TdxAlignmentVert] of Integer =
    (cxAlignTop, cxAlignVCenter, cxAlignBottom);
begin
  Result := MultiLines[MultiLine] or cxAlignmentsHorz[AlignHorz] or AlignsVert[AlignVert];
  if Item.CaptionOptions.ShowAccelChar then
    Inc(Result, cxShowPrefix);
end;

function TdxCustomLayoutItemCaptionViewInfo.CanDoCaptionClick(X, Y: Integer): Boolean;
begin
  Result := EnabledForWork and IsPointInHotTrackBounds(Point(X, Y));
end;

function TdxCustomLayoutItemCaptionViewInfo.GetAlignHorz: TAlignment;
begin
  Result := Item.CaptionOptions.AlignHorz;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetIsTextUnderlined: Boolean;
begin
  Result :=
    IsHotTrackable and not HotTracked and (htsUnderlineCold in HotTrackStyles) or
    HotTracked and (htsUnderlineHot in HotTrackStyles);
end;

function TdxCustomLayoutItemCaptionViewInfo.GetIsTransparent: Boolean;
begin
  Result := ItemViewInfo.ContainerViewInfo.HasBackground and IsDefaultColor;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetOptions: TdxLayoutLookAndFeelCaptionOptions;
begin
  Result := ItemViewInfo.Options.CaptionOptions;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetText: string;
begin
  Result := Item.Caption;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetTextAreaBounds: TRect;
begin
  Result := Bounds;
  if Enabled and (Text <> '') then
    with Result do
    begin
      Dec(Right);
      Dec(Bottom);
    end;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetTextColor: TColor;
begin
  if HotTracked then
    Result := GetTextHotColor
  else
    Result := GetTextNormalColor;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetTextHotColor: TColor;
begin
  Result := Options.GetTextHotColor;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetTextNormalColor: TColor;
begin
  Result := Options.GetTextColor;
end;

function TdxCustomLayoutItemCaptionViewInfo.GetVisibleText: string;
begin
  Result := Text;
  if Item.CaptionOptions.ShowAccelChar then
    Result := StripHotKey(Result);
end;

function TdxCustomLayoutItemCaptionViewInfo.IsPointInHotTrackBounds(const P: TPoint): Boolean;
var
  ABounds: TRectArray;
  I: Integer;
begin
  Result := False;
  PrepareCanvas;
  Canvas.GetTextStringsBounds(Text, TextAreaBounds,
    CalculateTextFlags, Enabled, ABounds);
  try
    for I := 0 to High(ABounds) do
    begin
      Result := PtInRect(ABounds[I], P);
      if Result then Break;
    end;
  finally
    ABounds := nil;
  end;
end;

procedure TdxCustomLayoutItemCaptionViewInfo.PrepareCanvas;
begin
  Canvas.Font := Font;
end;

function TdxCustomLayoutItemCaptionViewInfo.CalculateHeight: Integer;
begin
  if Visible then
    Result := TextHeight
  else
    Result := 0;  
end;

function TdxCustomLayoutItemCaptionViewInfo.CalculateWidth: Integer;
begin
  if Visible then
    Result := TextWidth
  else
    Result := 0;
end;

{ TdxCustomLayoutItemViewInfo }

constructor TdxCustomLayoutItemViewInfo.Create(AContainerViewInfo: TdxLayoutControlViewInfo;
  AParentViewInfo: TdxLayoutGroupViewInfo; AItem: TdxCustomLayoutItem);
begin
  inherited Create;
  FContainerViewInfo := AContainerViewInfo;
  FParentViewInfo := AParentViewInfo;
  FItem := AItem;
  FItem.FViewInfo := Self;
  CreateViewInfos;
end;

destructor TdxCustomLayoutItemViewInfo.Destroy;
begin
  DestroyViewInfos;
  FItem.FViewInfo := nil;
  inherited;
end;

function TdxCustomLayoutItemViewInfo.GetAlignHorz: TdxLayoutAlignHorz;
begin
  Result := Item.AlignHorz;
end;

function TdxCustomLayoutItemViewInfo.GetAlignVert: TdxLayoutAlignVert;
begin
  Result := Item.AlignVert;
end;

function TdxCustomLayoutItemViewInfo.GetIsCustomization: Boolean;
begin
  Result := FItem.Container.IsCustomization;
end;

function TdxCustomLayoutItemViewInfo.GetIsParentLocked: Boolean;
begin
  Result := (ParentViewInfo <> nil) and ParentViewInfo.IsLocked;
end;

function TdxCustomLayoutItemViewInfo.GetLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  Result := Item.GetLookAndFeel;
end;

function TdxCustomLayoutItemViewInfo.GetMinHeight: Integer;
begin
  if AlignVert = avClient then
    Result := CalculateMinHeight
  else
    Result := CalculateHeight;
end;

function TdxCustomLayoutItemViewInfo.GetMinWidth: Integer;
begin
  if AlignHorz = ahClient then
    Result := CalculateMinWidth
  else
    Result := CalculateWidth;
end;

function TdxCustomLayoutItemViewInfo.GetOffset(ASide: TdxLayoutSide): Integer;
begin
  Result := FOffsets[ASide];
  if Result = 0 then
    Result := CalculateOffset(ASide);
end;

function TdxCustomLayoutItemViewInfo.GetOffsetsHeight: Integer;
begin
  Result := Offsets[sdTop] + Offsets[sdBottom];
end;

function TdxCustomLayoutItemViewInfo.GetOffsetsWidth: Integer;
begin
  Result := Offsets[sdLeft] + Offsets[sdRight];
end;

function TdxCustomLayoutItemViewInfo.GetSelected: Boolean;
begin
  Result := Item.IsDesigning and
    dxLayoutDesigner.IsComponentSelected(Item.Container, Item);
end;

procedure TdxCustomLayoutItemViewInfo.SetElementWithMouse(Value: TdxCustomLayoutItemElementViewInfo);
begin
  if FElementWithMouse <> Value then
  begin
    if FElementWithMouse <> nil then
      FElementWithMouse.MouseLeave;
    FElementWithMouse := Value;
    if FElementWithMouse <> nil then
      FElementWithMouse.MouseEnter;
  end;
end;

procedure TdxCustomLayoutItemViewInfo.SetOffset(ASide: TdxLayoutSide; Value: Integer);
begin
  FOffsets[ASide] := Value;
end;

procedure TdxCustomLayoutItemViewInfo.CreateViewInfos;
begin
  FCaptionViewInfo := GetCaptionViewInfoClass.Create(Self);
end;

procedure TdxCustomLayoutItemViewInfo.DestroyViewInfos;
begin
  FreeAndNil(FCaptionViewInfo);
end;

function TdxCustomLayoutItemViewInfo.CalculateMinHeight: Integer;
begin
  Result := DoCalculateHeight(True);
end;

function TdxCustomLayoutItemViewInfo.CalculateMinWidth: Integer;
begin
  Result := DoCalculateWidth(True);
end;

function TdxCustomLayoutItemViewInfo.CalculateOffset(ASide: TdxLayoutSide): Integer;
begin
  case ASide of
    sdLeft:
      Result := Item.Offsets.Left;
    sdRight:
      Result := Item.Offsets.Right;
    sdTop:
      Result := Item.Offsets.Top;
    sdBottom:
      Result := Item.Offsets.Bottom;
  else
    Result := 0;
  end;
end;

function TdxCustomLayoutItemViewInfo.DoCalculateHeight(AIsMinHeight: Boolean = False): Integer;
begin
  Result := OffsetsHeight;
end;

function TdxCustomLayoutItemViewInfo.DoCalculateWidth(AIsMinWidth: Boolean = False): Integer;
begin
  Result := OffsetsWidth;
end;

function TdxCustomLayoutItemViewInfo.GetCursor(X, Y: Integer): TCursor;
var
  I: Integer;
begin
  for I := 0 to ElementCount - 1 do
    if Elements[I].WantsMouse(X, Y) then
    begin
      Result := Elements[I].GetCursor(X, Y);
      Exit;
    end;
  Result := crDefault;
end;

function TdxCustomLayoutItemViewInfo.GetElement(Index: Integer): TdxCustomLayoutItemElementViewInfo;
begin
  if Index = 0 then
    Result := CaptionViewInfo
  else
    Result := nil;
end;

function TdxCustomLayoutItemViewInfo.GetElementCount: Integer;
begin
  Result := 1;
end;

function TdxCustomLayoutItemViewInfo.GetEnabled: Boolean;
begin
  Result := Item.Enabled;
end;

function TdxCustomLayoutItemViewInfo.GetEnabledForWork: Boolean;
begin
  Result := Item.EnabledForWork;
end;

function TdxCustomLayoutItemViewInfo.GetIsTransparent: Boolean;
begin
  Result := ContainerViewInfo.HasBackground and IsDefaultColor;
end;

function TdxCustomLayoutItemViewInfo.GetSelectionAreaBounds(Index: Integer): TRect;
const
  SelectionSize = 2;//1;
begin
  with Bounds do
    case Index of
      0: Result := Rect(Left, Top, Left + SelectionSize, Bottom);
      1: Result := Rect(Left, Top, Right, Top + SelectionSize);
      2: Result := Rect(Right - SelectionSize, Top, Right, Bottom);
      3: Result := Rect(Left, Bottom - SelectionSize, Right, Bottom);
    end;
end;

function TdxCustomLayoutItemViewInfo.GetSelectionAreaCount: Integer;
begin
  Result := 4;
end;

function TdxCustomLayoutItemViewInfo.HasCaption: Boolean;
begin
  Result := Item.HasCaption;
end;

procedure TdxCustomLayoutItemViewInfo.MouseEnter;
begin
end;

procedure TdxCustomLayoutItemViewInfo.MouseLeave;
begin
  ElementWithMouse := nil;
end;

procedure TdxCustomLayoutItemViewInfo.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ElementWithMouse <> nil then
    ElementWithMouse.MouseDown(Button, Shift, X, Y);
end;

procedure TdxCustomLayoutItemViewInfo.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  for I := 0 to ElementCount - 1 do
    if Elements[I].WantsMouse(X, Y) then
    begin
      ElementWithMouse := Elements[I];
      Elements[I].MouseMove(Shift, X, Y);
      Exit;
    end;
  ElementWithMouse := nil;
end;

procedure TdxCustomLayoutItemViewInfo.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if ElementWithMouse <> nil then
    ElementWithMouse.MouseUp(Button, Shift, X, Y);
end;

procedure TdxCustomLayoutItemViewInfo.Calculate(const ABounds: TRect);
begin
  Bounds := ABounds;
  Inc(Bounds.Left, Offsets[sdLeft]);
  Inc(Bounds.Top, Offsets[sdTop]);
  Dec(Bounds.Right, Offsets[sdRight]);
  Dec(Bounds.Bottom, Offsets[sdBottom]);
end;

function TdxCustomLayoutItemViewInfo.CalculateHeight: Integer;
begin
  Result := DoCalculateHeight;
end;

function TdxCustomLayoutItemViewInfo.CalculateWidth: Integer;
begin
  Result := DoCalculateWidth;
end;

function TdxCustomLayoutItemViewInfo.GetHitTest(const P: TPoint): TdxCustomLayoutHitTest;
begin
  if not IsParentLocked and PtInRect(Bounds, P) then
  begin
    Result := GetHitTestClass.Instance;
    TdxCustomLayoutItemHitTest(Result).Item := Item;
  end
  else
    Result := nil;
end;

procedure TdxCustomLayoutItemViewInfo.ResetOffset(ASide: TdxLayoutSide);
begin
  FOffsets[ASide] := 0;
end;

{ TdxLayoutItemCaptionViewInfo }

function TdxLayoutItemCaptionViewInfo.GetItem: TdxLayoutItem;
begin
  Result := TdxLayoutItem(inherited GetItem);
end;

function TdxLayoutItemCaptionViewInfo.GetItemViewInfo: TdxLayoutItemViewInfo;
begin
  Result := TdxLayoutItemViewInfo(inherited ItemViewInfo);
end;

function TdxLayoutItemCaptionViewInfo.GetAlignVert: TdxAlignmentVert;
begin
  Result := Item.CaptionOptions.AlignVert;
end;

function TdxLayoutItemCaptionViewInfo.GetIsFixedWidth: Boolean;
begin
  Result := Item.CaptionOptions.Width <> 0;
end;

function TdxLayoutItemCaptionViewInfo.GetMinWidth: Integer;
begin
  if FWidth = 0 then
    Result := CalculateWidth
  else
    Result := Width;
end;

function TdxLayoutItemCaptionViewInfo.GetMultiLine: Boolean;
begin
  Result := IsFixedWidth;
end;

function TdxLayoutItemCaptionViewInfo.GetTextAreaBounds: TRect;
var
  ADelta: Integer;
begin
  Result := inherited GetTextAreaBounds;
  if IsFixedWidth then
    with Result do
    begin
      ADelta := Width - CalculateWidth;
      case AlignHorz of
        taLeftJustify:
          Dec(Right, ADelta);
        taRightJustify:
          Inc(Left, ADelta);
        taCenter:
          begin
            Inc(Left, ADelta div 2);
            Dec(Right, ADelta - ADelta div 2);
          end;
      end;
    end;
end;

function TdxLayoutItemCaptionViewInfo.CalculateWidth: Integer;
begin
  if Visible and IsFixedWidth then
    Result := Item.CaptionOptions.Width
  else
    Result := inherited CalculateWidth;
end;

{ TdxLayoutItemControlViewInfo }

function TdxLayoutItemControlViewInfo.GetBorderColor: TColor;
begin
  Result := ItemViewInfo.Options.GetControlBorderColor;
end;

function TdxLayoutItemControlViewInfo.GetBorderStyle: TdxLayoutBorderStyle;
begin
  Result := ItemViewInfo.Options.ControlBorderStyle;
end;

function TdxLayoutItemControlViewInfo.GetControl: TControl;
begin
  Result := Item.Control;
end;

function TdxLayoutItemControlViewInfo.GetHasBorder: Boolean;
begin
  Result := Item.ControlOptions.ShowBorder;
end;

function TdxLayoutItemControlViewInfo.GetItem: TdxLayoutItem;
begin
  Result := TdxLayoutItem(inherited Item);
end;

function TdxLayoutItemControlViewInfo.GetItemViewInfo: TdxLayoutItemViewInfo;
begin
  Result := TdxLayoutItemViewInfo(inherited ItemViewInfo);
end;

function TdxLayoutItemControlViewInfo.GetOpaqueControl: Boolean;
begin
  Result := Item.ControlOptions.Opaque;
end;

function TdxLayoutItemControlViewInfo.GetVisible: Boolean;
begin
  Result := ItemViewInfo.HasControl;
end;

function TdxLayoutItemControlViewInfo.CalculateControlBounds: TRect;
begin
  Result := Bounds;
  Inc(Result.Left, BorderWidths[sdLeft]);
  Dec(Result.Right, BorderWidths[sdRight]);
  Inc(Result.Top, BorderWidths[sdTop]);
  Dec(Result.Bottom, BorderWidths[sdBottom]);
end;

function TdxLayoutItemControlViewInfo.GetBorderWidth(ASide: TdxLayoutSide): Integer;
begin
  if HasBorder then
    Result := LookAndFeel.ItemControlBorderWidths[ASide]
  else
    Result := 0
end;

function TdxLayoutItemControlViewInfo.GetHeight(AControlHeight: Integer): Integer;
begin
  Result := BorderWidths[sdTop] + AControlHeight + BorderWidths[sdBottom];
end;

function TdxLayoutItemControlViewInfo.GetWidth(AControlWidth: Integer): Integer;
begin
  Result := BorderWidths[sdLeft] + AControlWidth + BorderWidths[sdRight];
end;

procedure TdxLayoutItemControlViewInfo.Calculate(const ABounds: TRect);
begin
  inherited;
  FControlBounds := CalculateControlBounds;
end;

function TdxLayoutItemControlViewInfo.CalculateHeight: Integer;
begin
  if Visible then
    Result := GetHeight(Item.OriginalControlSize.Y)
  else
    Result := 0;
end;

function TdxLayoutItemControlViewInfo.CalculateWidth: Integer;
begin
  if Visible then
    Result := GetWidth(Item.OriginalControlSize.X)
  else
    Result := 0;
end;

function TdxLayoutItemControlViewInfo.CalculateMinHeight: Integer;
begin
  if Item.ControlOptions.FixedSize then
    Result := CalculateHeight
  else
    if Visible then
      Result := GetHeight(Item.ControlOptions.MinHeight)
    else
      Result := 0;
end;

function TdxLayoutItemControlViewInfo.CalculateMinWidth: Integer;
begin
  if Item.ControlOptions.FixedSize then
    Result := CalculateWidth
  else
    if Visible then
      Result := GetWidth(Item.ControlOptions.MinWidth)
    else
      Result := 0;
end;

procedure TdxLayoutItemControlViewInfo.CalculateTabOrder(var AAvailTabOrder: Integer);
begin
  if Item.HasWinControl then
  begin
    TWinControl(Control).TabOrder := AAvailTabOrder;
    Inc(AAvailTabOrder);
  end;
end;

{ TdxLayoutItemViewInfo }

function TdxLayoutItemViewInfo.GetCaptionViewInfo: TdxLayoutItemCaptionViewInfo;
begin
  Result := TdxLayoutItemCaptionViewInfo(inherited CaptionViewInfo);
end;

function TdxLayoutItemViewInfo.GetItem: TdxLayoutItem;
begin
  Result := TdxLayoutItem(inherited Item);
end;

function TdxLayoutItemViewInfo.GetOptionsEx: TdxLayoutLookAndFeelItemOptions;
begin
  Result := TdxLayoutLookAndFeelItemOptions(inherited Options);
end;

procedure TdxLayoutItemViewInfo.CreateViewInfos;
begin
  inherited;
  FControlViewInfo := GetControlViewInfoClass.Create(Self);
end;

procedure TdxLayoutItemViewInfo.DestroyViewInfos;
begin
  FreeAndNil(FControlViewInfo);
  inherited;
end;

function TdxLayoutItemViewInfo.GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass;
begin
  Result := TdxLayoutItemCaptionViewInfo;
end;

function TdxLayoutItemViewInfo.GetControlViewInfoClass: TdxLayoutItemControlViewInfoClass;
begin
  Result := TdxLayoutItemControlViewInfo;
end;

function TdxLayoutItemViewInfo.GetHitTestClass: TdxCustomLayoutItemHitTestClass;
begin
  Result := TdxLayoutItemHitTest;
end;

function TdxLayoutItemViewInfo.GetPainterClass: TdxCustomLayoutItemPainterClass;
begin
  Result := TdxCustomLayoutItemPainterClass(LookAndFeel.GetItemPainterClass);
end;

procedure TdxLayoutItemViewInfo.CalculateViewInfosBounds(var ACaptionBounds,
  AControlBounds: TRect);
var
  ACaptionSize, AControlSize: TPoint;
  ACaptionVisible, AControlVisible: Boolean;

  procedure CalculateElementViewInfoSize(AElementViewInfo: TdxCustomLayoutItemElementViewInfo;
    var ASize: TPoint; var AVisible: Boolean);
  begin
    AVisible := AElementViewInfo.Visible;
    with ASize do
      if AVisible then
      begin
        X := AElementViewInfo.Width;
        Y := AElementViewInfo.Height;
      end
      else
      begin
        X := 0;
        Y := 0;
      end;
    AVisible := AVisible and ((ASize.X <> 0) or (ASize.Y <> 0));
    //AVisible := AVisible and (ASize.X <> 0) and (ASize.Y <> 0);
  end;

  procedure CalculateMainBounds;

    procedure InitBounds(var ABounds: TRect; const ASize: TPoint; AVisible: Boolean);
    begin
      if AVisible then
        ABounds := ContentBounds
      else
        SetRectEmpty(ABounds);
    end;

    procedure CalculateWithFixedControl;
    begin
      case CaptionLayout of
        clLeft:
          begin
            AControlBounds.Left := AControlBounds.Right - AControlSize.X;
            ACaptionBounds.Right := AControlBounds.Left - ControlOffsetHorz;
          end;
        clTop:
          begin
            AControlBounds.Top := AControlBounds.Bottom - AControlSize.Y;
            ACaptionBounds.Bottom := AControlBounds.Top - ControlOffsetVert;
          end;
        clRight:
          begin
            AControlBounds.Right := AControlBounds.Left + AControlSize.X;
            ACaptionBounds.Left := AControlBounds.Right + ControlOffsetHorz;
          end;
        clBottom:
          begin
            AControlBounds.Bottom := AControlBounds.Top + AControlSize.Y;
            ACaptionBounds.Top := AControlBounds.Bottom + ControlOffsetVert;
          end;
      end
    end;

    procedure CalculateWithFixedCaption;
    begin
      case CaptionLayout of
        clLeft:
          begin
            ACaptionBounds.Right := ACaptionBounds.Left + ACaptionSize.X;
            AControlBounds.Left := ACaptionBounds.Right + ControlOffsetHorz;
          end;
        clTop:
          begin
            ACaptionBounds.Bottom := ACaptionBounds.Top + ACaptionSize.Y;
            AControlBounds.Top := ACaptionBounds.Bottom + ControlOffsetVert;
          end;
        clRight:
          begin
            ACaptionBounds.Left := ACaptionBounds.Right - ACaptionSize.X;
            AControlBounds.Right := ACaptionBounds.Left - ControlOffsetHorz;
          end;
        clBottom:
          begin
            ACaptionBounds.Top := ACaptionBounds.Bottom - ACaptionSize.Y;
            AControlBounds.Bottom := ACaptionBounds.Top - ControlOffsetVert;
          end;
      end;
    end;

  begin
    InitBounds(ACaptionBounds, ACaptionSize, ACaptionVisible);
    InitBounds(AControlBounds, AControlSize, AControlVisible);
    if ACaptionVisible and AControlVisible then
      if Item.ControlOptions.FixedSize then
        CalculateWithFixedControl
      else
        CalculateWithFixedCaption
    else
      if AControlVisible and Item.ControlOptions.FixedSize then
        with AControlBounds, AControlSize do
        begin
          Right := Left + X;
          Bottom := Top + Y;
        end;
  end;

  procedure CalculateRestBounds(var ABounds: TRect; const ASize: TPoint;
    AAlignHorz: TAlignment; AAlignVert: TdxAlignmentVert);
  begin
    with ABounds, ASize do
      case CaptionLayout of
        clLeft, clRight:
          case AAlignVert of
            tavTop:
              Bottom := Top + Y;
            tavCenter:
              begin
                Top := (Top + Bottom - Y) div 2;
                Bottom := Top + Y;
              end;
            tavBottom:
              Top := Bottom - Y;
          end;
        clTop, clBottom:
          case AAlignHorz of
            taLeftJustify:
              Right := Left + X;
            taCenter:
              begin
                Left := (Left + Right - X) div 2;
                Right := Left + X;
              end;
            taRightJustify:
              Left := Right - X;
          end;
      end;
  end;

begin
  CalculateElementViewInfoSize(CaptionViewInfo, ACaptionSize, ACaptionVisible);
  CalculateElementViewInfoSize(ControlViewInfo, AControlSize, AControlVisible);
  CalculateMainBounds;
  if ACaptionVisible then
  begin
    CalculateRestBounds(ACaptionBounds, ACaptionSize,
      Item.CaptionOptions.AlignHorz, Item.CaptionOptions.AlignVert);
    if AControlVisible and
      ((AlignHorz <> ahClient) or (CaptionLayout in [clLeft, clRight])) and
      ((AlignVert <> avClient) or (CaptionLayout in [clTop, clBottom])) then
      CalculateRestBounds(AControlBounds, AControlSize, taLeftJustify, tavTop);
  end;
end;

function TdxLayoutItemViewInfo.DoCalculateHeight(AIsMinHeight: Boolean = False): Integer;
var
  AHeight: Integer;
begin
  Result := CaptionViewInfo.Height;
  if AIsMinHeight then
    AHeight := ControlViewInfo.CalculateMinHeight
  else
    AHeight := ControlViewInfo.CalculateHeight;

  case CaptionLayout of
    clLeft, clRight:
      if AHeight > Result then Result := AHeight;
    clTop, clBottom:
      begin
        if (Result <> 0) and ControlViewInfo.Visible{(AHeight <> 0)} then
          Inc(Result, ControlOffsetVert);
        Inc(Result, AHeight);
      end;
  else
    Result := 0;
  end;

  Inc(Result, inherited DoCalculateHeight(AIsMinHeight));
end;

function TdxLayoutItemViewInfo.DoCalculateWidth(AIsMinWidth: Boolean = False): Integer;
var
  AWidth: Integer;
begin
  if AIsMinWidth then
  begin
    Result := CaptionViewInfo.MinWidth;
    AWidth := ControlViewInfo.CalculateMinWidth;
  end
  else
  begin
    Result := CaptionViewInfo.Width;
    AWidth := ControlViewInfo.CalculateWidth;
  end;

  case CaptionLayout of
    clLeft, clRight:
      begin
        if (Result <> 0) and ControlViewInfo.Visible{(AWidth <> 0)} then
          Inc(Result, ControlOffsetHorz);
        Inc(Result, AWidth);
      end;
    clTop, clBottom:
      if AWidth > Result then Result := AWidth;
  else
    Result := 0;
  end;

  Inc(Result, inherited DoCalculateWidth(AIsMinWidth));
end;

function TdxLayoutItemViewInfo.GetAutoControlAlignment: Boolean;

  function AreAlignmentAndCaptionLayoutLinked: Boolean;
  begin
    case CaptionLayout of
      clLeft:
        Result := AlignHorz in [ahLeft, ahClient];
      clTop:
        Result := AlignVert in [avTop, avClient];
      clRight:
        Result := AlignHorz in [ahRight, ahClient];
      clBottom:
        Result := AlignVert in [avBottom, avClient];
    else
      Result := False;  
    end;
  end;

begin
  Result :=
    Item.ControlOptions.AutoAlignment and HasCaption and HasControl and
    AreAlignmentAndCaptionLayoutLinked;
end;

function TdxLayoutItemViewInfo.GetCaptionLayout: TdxCaptionLayout;
begin
  Result := Item.CaptionOptions.Layout;
end;

function TdxLayoutItemViewInfo.GetColor: TColor;
begin
  Result := ParentViewInfo.GetColor;
end;

function TdxLayoutItemViewInfo.GetContentBounds: TRect;
begin
  Result := Bounds;
end;

function TdxLayoutItemViewInfo.GetControlOffsetHorz: Integer;
begin
  Result := LookAndFeel.GetControlOffsetHorz(Item.Container);
end;

function TdxLayoutItemViewInfo.GetControlOffsetVert: Integer;
begin
  Result := LookAndFeel.GetControlOffsetVert(Item.Container);
end;

function TdxLayoutItemViewInfo.GetElement(Index: Integer): TdxCustomLayoutItemElementViewInfo;
begin
  Result := inherited GetElement(Index);
  if Index - inherited GetElementCount = 0 then
    Result := FControlViewInfo;
end;

function TdxLayoutItemViewInfo.GetElementCount: Integer;
begin
  Result := inherited GetElementCount + 1;
end;

function TdxLayoutItemViewInfo.GetIsDefaultColor: Boolean;
begin
  Result := ParentViewInfo.IsDefaultColor;
end;

function TdxLayoutItemViewInfo.GetOptions: TdxCustomLayoutLookAndFeelOptions;
begin
  Result := LookAndFeel.ItemOptions;
end;

function TdxLayoutItemViewInfo.HasControl: Boolean;
begin
  Result := Item.HasControl;
end;

procedure TdxLayoutItemViewInfo.Calculate(const ABounds: TRect);
var
  ACaptionViewInfoBounds, AControlViewInfoBounds: TRect;
begin
  inherited;
  CalculateViewInfosBounds(ACaptionViewInfoBounds, AControlViewInfoBounds);
  CaptionViewInfo.Calculate(ACaptionViewInfoBounds);
  ControlViewInfo.Calculate(AControlViewInfoBounds);
end;

procedure TdxLayoutItemViewInfo.CalculateTabOrders(var AAvailTabOrder: Integer);
begin
  ControlViewInfo.CalculateTabOrder(AAvailTabOrder);
end;

{ TdxLayoutGroupCaptionViewInfo }

function TdxLayoutGroupCaptionViewInfo.GetAlignVert: TdxAlignmentVert;
begin
  Result := tavTop;
end;

function TdxLayoutGroupCaptionViewInfo.GetMultiLine: Boolean;
begin
  Result := False;
end;

function TdxLayoutGroupCaptionViewInfo.GetMinWidth: Integer;
begin
  Result := CalculateWidth;
end;

{ TdxLayoutGroupViewInfoSpecific }

constructor TdxLayoutGroupViewInfoSpecific.Create(AGroupViewInfo: TdxLayoutGroupViewInfo);
begin
  inherited Create;
  FGroupViewInfo := AGroupViewInfo;
end;

function TdxLayoutGroupViewInfoSpecific.GetItemOffset: Integer;
begin
  Result := FGroupViewInfo.ItemOffset;
end;

function TdxLayoutGroupViewInfoSpecific.GetItemViewInfo(Index: Integer): TdxCustomLayoutItemViewInfo;
begin
  Result := FGroupViewInfo.ItemViewInfos[Index];
end;

function TdxLayoutGroupViewInfoSpecific.GetItemViewInfoCount: Integer;
begin
  Result := FGroupViewInfo.ItemViewInfoCount;
end;

function TdxLayoutGroupViewInfoSpecific.GetLayoutDirection: TdxLayoutDirection;
begin
  Result := FGroupViewInfo.LayoutDirection;
end;

function TdxLayoutGroupViewInfoSpecific.DoCalculateHeight: Integer;
begin
  Result := GetCustomHeight(GetItemHeight);
end;

function TdxLayoutGroupViewInfoSpecific.DoCalculateWidth: Integer;
begin
  Result := GetCustomWidth(GetItemWidth);
end;

function TdxLayoutGroupViewInfoSpecific.DoCalculateMinHeight: Integer;
begin
  Result := GetCustomHeight(GetItemMinHeight);
end;

function TdxLayoutGroupViewInfoSpecific.DoCalculateMinWidth: Integer;
begin
  Result := GetCustomWidth(GetItemMinWidth);
end;

function TdxLayoutGroupViewInfoSpecific.GetCustomHeight(AGetItemCustomHeight: TdxLayoutGroupViewInfoGetItemSizeEvent): Integer;
var
  I, AItemHeight: Integer;
begin
  Result := 0;
  for I := 0 to ItemViewInfoCount - 1 do
  begin
    AItemHeight := AGetItemCustomHeight(ItemViewInfos[I]);
    if AItemHeight > Result then Result := AItemHeight;
  end;
end;

function TdxLayoutGroupViewInfoSpecific.GetCustomWidth(AGetItemCustomWidth: TdxLayoutGroupViewInfoGetItemSizeEvent): Integer;
var
  AIsFirstItem: Boolean;
  I, AItemWidth: Integer;
  AItemViewInfo: TdxCustomLayoutItemViewInfo;
begin
  Result := 0;
  AIsFirstItem := True;
  for I := 0 to ItemViewInfoCount - 1 do
  begin
    AItemViewInfo := ItemViewInfos[I];
    if GetItemAlignHorz(AItemViewInfo) <> ahCenter then
    begin
      if not AIsFirstItem then
        Inc(Result, ItemOffset);
      AItemWidth := AGetItemCustomWidth(AItemViewInfo);
      Inc(Result, AItemWidth);
      AIsFirstItem := False;
    end;
  end;
  for I := 0 to ItemViewInfoCount - 1 do
  begin
    AItemViewInfo := ItemViewInfos[I];
    if GetItemAlignHorz(AItemViewInfo) = ahCenter then
    begin
      AItemWidth := AGetItemCustomWidth(AItemViewInfo);
      if AItemWidth > Result then
        Result := AItemWidth;
    end;
  end;
end;

procedure TdxLayoutGroupViewInfoSpecific.ConvertCoords(var R: TRect);
begin
end;

procedure TdxLayoutGroupViewInfoSpecific.CalculateItemsBounds(AItemsAreaBounds: TRect);
type
  TItemInfo = record
    ViewInfo: TdxCustomLayoutItemViewInfo;
    AlignHorz: TdxLayoutAlignHorz;
    CalculatedWidth, MinWidth, Width, Height: Integer;
    Bounds: TRect;
    Calculated: Boolean;
  end;
  PItemInfos = ^TItemInfos;
  TItemInfos = array[0..MaxInt div SizeOf(TItemInfo) - 1] of TItemInfo;
var
  AItemInfos: PItemInfos;

  procedure PrepareItemInfos;
  var
    I: Integer;
  begin
    for I := 0 to ItemViewInfoCount - 1 do
      with AItemInfos^[I] do
      begin
        ViewInfo := ItemViewInfos[I];
        AlignHorz := GetItemAlignHorz(ViewInfo);
        CalculatedWidth := GetItemWidth(ViewInfo);
        Height := GetItemHeight(ViewInfo);
        MinWidth := GetItemMinWidth(ViewInfo);
        Calculated := False;
      end;
  end;

  procedure CalculateItemsHorizontalBounds;
  var
    ASpace, AAvailableSpace: Integer;

    procedure CalculateSpaces;
    var
      AItemOffsets, I: Integer;
      AIsFirstItem: Boolean;
    begin
      AItemOffsets := 0;
      ASpace := 0;
      AIsFirstItem := True;
      for I := 0 to ItemViewInfoCount - 1 do
        with AItemInfos^[I] do
          if AlignHorz <> ahCenter then
          begin
            if not AIsFirstItem then
              Inc(AItemOffsets, ItemOffset);
            Inc(ASpace, CalculatedWidth);
            AIsFirstItem := False;
          end;
      with AItemsAreaBounds do
        AAvailableSpace := Right - Left - AItemOffsets;
    end;

    procedure RemoveNonClientItemsFromCalculating;
    var
      I: Integer;
    begin
      for I := 0 to ItemViewInfoCount - 1 do
        with AItemInfos^[I] do
          if AlignHorz <> ahClient then
          begin
            Width := CalculatedWidth;
            if AlignHorz <> ahCenter then
            begin
              Dec(ASpace, Width);
              Dec(AAvailableSpace, Width);
            end;
            Calculated := True;
          end;
    end;

    procedure CalculateClientItemsVisibleSizes;
    var
      ANeedRecalculating: Boolean;
      ANextSpace, ANextAvailableSpace, AOffset, I: Integer;
    begin
      repeat
        ANeedRecalculating := False;
        ANextSpace := ASpace;
        ANextAvailableSpace := AAvailableSpace;
        AOffset := 0;

        for I := 0 to ItemViewInfoCount - 1 do
          with AItemInfos^[I] do
            if not Calculated then
            begin
              Width :=
                MulDiv(AAvailableSpace, AOffset + CalculatedWidth, ASpace) -
                MulDiv(AAvailableSpace, AOffset, ASpace);
              if Width < MinWidth then
              begin
                Width := MinWidth;
                Dec(ANextSpace, CalculatedWidth);
                Dec(ANextAvailableSpace, Width);
                Calculated := True;
                ANeedRecalculating := True;
              end;
            end;
            
        ASpace := ANextSpace;
        AAvailableSpace := ANextAvailableSpace;
      until not ANeedRecalculating;
    end;

    procedure CalculateItemsBounds;

      procedure ProcessLeftAlignedItems;
      var
        AOffset, I: Integer;
      begin
        AOffset := AItemsAreaBounds.Left;
        for I := 0 to ItemViewInfoCount - 1 do
          with AItemInfos^[I] do
            case AlignHorz of
              ahLeft, ahClient:
                begin
                  Bounds.Left := AOffset;
                  Bounds.Right := AOffset + Width;
                  Inc(AOffset, Width + ItemOffset);
                end;
              ahCenter:
                begin
                  Bounds.Left :=
                    (AItemsAreaBounds.Left + AItemsAreaBounds.Right - Width) div 2;
                  Bounds.Right := Bounds.Left + Width;
                end;
            end;
      end;

      procedure ProcessRightAlignedItems;
      var
        AOffset, I: Integer;
      begin
        AOffset := AItemsAreaBounds.Right;
        for I := ItemViewInfoCount - 1 downto 0 do
          with AItemInfos^[I] do
            if AlignHorz = ahRight then
            begin
              Bounds.Right := AOffset;
              Bounds.Left := AOffset - Width;
              Dec(AOffset, Width + ItemOffset);
            end;
      end;

    begin
      ProcessLeftAlignedItems;
      ProcessRightAlignedItems;
    end;

  begin
    CalculateSpaces;
    RemoveNonClientItemsFromCalculating;
    CalculateClientItemsVisibleSizes;
    CalculateItemsBounds;
  end;

  procedure CalculateItemsVerticalBounds;
  var
    I: Integer;
  begin
    for I := 0 to ItemViewInfoCount - 1 do
      with AItemInfos^[I] do
        case GetItemAlignVert(ViewInfo) of
          avTop:
            begin
              Bounds.Top := AItemsAreaBounds.Top;
              Bounds.Bottom := Bounds.Top + Height;
            end;
          avCenter:
            begin
              Bounds.Top :=
                (AItemsAreaBounds.Top + AItemsAreaBounds.Bottom - Height) div 2;
              Bounds.Bottom := Bounds.Top + Height;
            end;
          avBottom:
            begin
              Bounds.Bottom := AItemsAreaBounds.Bottom;
              Bounds.Top := Bounds.Bottom - Height;
            end;
          avClient:
            begin
              Bounds.Top := AItemsAreaBounds.Top;
              Bounds.Bottom := AItemsAreaBounds.Bottom;
            end;
        end;
  end;

  procedure CalculateItemViewInfos;
  var
    I: Integer;
  begin
    for I := 0 to ItemViewInfoCount - 1 do
      with AItemInfos^[I] do
      begin
        ConvertCoords(Bounds);
        ViewInfo.Calculate(Bounds);
      end;
  end;

begin
  GetMem(AItemInfos, ItemViewInfoCount * SizeOf(TItemInfo));
  try
    ConvertCoords(AItemsAreaBounds);
    PrepareItemInfos;
    CalculateItemsHorizontalBounds;
    CalculateItemsVerticalBounds;
    CalculateItemViewInfos;
  finally
    FreeMem(AItemInfos);
  end;
end;

function TdxLayoutGroupViewInfoSpecific.CalculateHeight(AIsMinHeight: Boolean = False): Integer;
begin
  if AIsMinHeight then
    Result := DoCalculateMinHeight
  else
    Result := DoCalculateHeight;
end;

function TdxLayoutGroupViewInfoSpecific.CalculateWidth(AIsMinWidth: Boolean = False): Integer;
begin
  if AIsMinWidth then
    Result := DoCalculateMinWidth
  else
    Result := DoCalculateWidth;
end;

{ TdxLayoutGroupHorizontalSpecific }

function TdxLayoutGroupViewInfoHorizontalSpecific.GetItemAlignHorz(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignHorz;
begin
  Result := AViewInfo.AlignHorz;
end;

function TdxLayoutGroupViewInfoHorizontalSpecific.GetItemAlignVert(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignVert;
begin
  Result := AViewInfo.AlignVert;
end;

function TdxLayoutGroupViewInfoHorizontalSpecific.GetItemHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer;
begin
  Result := AViewInfo.CalculateHeight;
end;

function TdxLayoutGroupViewInfoHorizontalSpecific.GetItemMinHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer;
begin
  Result := AViewInfo.MinHeight;
end;

function TdxLayoutGroupViewInfoHorizontalSpecific.GetItemMinWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer;
begin
  Result := AViewInfo.MinWidth;
end;

function TdxLayoutGroupViewInfoHorizontalSpecific.GetItemWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer;
begin
  Result := AViewInfo.CalculateWidth;
end;

function TdxLayoutGroupViewInfoHorizontalSpecific.IsAtInsertionPos(const R: TRect;
  const P: TPoint): Boolean;
begin
  Result := P.X < (R.Left + R.Right) div 2;
end;

{ TdxLayoutGroupViewInfoVerticalSpecific }

procedure TdxLayoutGroupViewInfoVerticalSpecific.ConvertCoords(var R: TRect);
var
  Temp: Integer;
begin
  with R do
  begin
    Temp := Left;
    Left := Top;
    Top := Temp;
    Temp := Right;
    Right := Bottom;
    Bottom := Temp;
  end;
end;

function TdxLayoutGroupViewInfoVerticalSpecific.GetItemAlignHorz(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignHorz;
begin
  Result := TdxLayoutAlignHorz(AViewInfo.AlignVert);
end;

function TdxLayoutGroupViewInfoVerticalSpecific.GetItemAlignVert(AViewInfo: TdxCustomLayoutItemViewInfo): TdxLayoutAlignVert;
begin
  Result := TdxLayoutAlignVert(AViewInfo.AlignHorz);
end;

function TdxLayoutGroupViewInfoVerticalSpecific.GetItemHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer;
begin
  Result := AViewInfo.CalculateWidth;
end;

function TdxLayoutGroupViewInfoVerticalSpecific.GetItemMinHeight(AViewInfo: TdxCustomLayoutItemViewInfo): Integer;
begin
  Result := AViewInfo.MinWidth;
end;

function TdxLayoutGroupViewInfoVerticalSpecific.GetItemMinWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer;
begin
  Result := AViewInfo.MinHeight;
end;

function TdxLayoutGroupViewInfoVerticalSpecific.GetItemWidth(AViewInfo: TdxCustomLayoutItemViewInfo): Integer;
begin
  Result := AViewInfo.CalculateHeight;
end;

function TdxLayoutGroupViewInfoVerticalSpecific.CalculateHeight(AIsMinHeight: Boolean = False): Integer;
begin
  Result := inherited CalculateWidth(AIsMinHeight);
end;

function TdxLayoutGroupViewInfoVerticalSpecific.CalculateWidth(AIsMinWidth: Boolean = False): Integer;
begin
  Result := inherited CalculateHeight(AIsMinWidth);
end;

function TdxLayoutGroupViewInfoVerticalSpecific.IsAtInsertionPos(const R: TRect;
  const P: TPoint): Boolean;
begin
  Result := P.Y < (R.Top + R.Bottom) div 2;
end;

{ TdxLayoutGroupViewInfo }

constructor TdxLayoutGroupViewInfo.Create(AControlViewInfo: TdxLayoutControlViewInfo;
  AParentViewInfo: TdxLayoutGroupViewInfo; AItem: TdxCustomLayoutItem); 
begin
  inherited;
  CreateSpecific;
  CreateItemViewInfos;
end;

destructor TdxLayoutGroupViewInfo.Destroy;
begin
  DestroyItemViewInfos;
  DestroySpecific;
  inherited;
end;

function TdxLayoutGroupViewInfo.GetBorderBounds(ASide: TdxLayoutSide): TRect;
begin
  Result := Bounds;
  with ClientBounds do
    case ASide of
      sdLeft:
        Result.Right := Left;
      sdTop:
        Result.Bottom := Top;
      sdRight:
        Result.Left := Right;
      sdBottom:
        Result.Top := Bottom;
    end;
end;

function TdxLayoutGroupViewInfo.GetBorderRestSpaceBounds(ASide: TdxLayoutSide): TRect;
begin
  Result := RestSpaceBounds;
  with ClientBounds do
    case ASide of
      sdLeft:
        Result.Right := Left;
      sdTop:
        Result.Bottom := Top;
      sdRight:
        Result.Left := Right;
      sdBottom:
        Result.Top := Bottom;
    end;
end;

function TdxLayoutGroupViewInfo.GetBordersHeight: Integer;
begin
  Result := BorderWidths[sdLeft] + BorderWidths[sdRight];
end;

function TdxLayoutGroupViewInfo.GetBordersWidth: Integer;
begin
  Result := BorderWidths[sdTop] + BorderWidths[sdBottom];
end;

function TdxLayoutGroupViewInfo.GetCaptionViewInfo: TdxLayoutGroupCaptionViewInfo;
begin
  Result := TdxLayoutGroupCaptionViewInfo(inherited CaptionViewInfo);
end;

function TdxLayoutGroupViewInfo.GetGroup: TdxLayoutGroup;
begin
  Result := TdxLayoutGroup(inherited Item);
end;

function TdxLayoutGroupViewInfo.GetIsLocked: Boolean;
begin
  Result := Group.Locked and IsCustomization or IsParentLocked;
end;

function TdxLayoutGroupViewInfo.GetItemViewInfo(Index: Integer): TdxCustomLayoutItemViewInfo;
begin
  Result := TdxCustomLayoutItemViewInfo(FItemViewInfos[Index]);
end;

function TdxLayoutGroupViewInfo.GetItemViewInfoCount: Integer;
begin
  Result := FItemViewInfos.Count;
end;

function TdxLayoutGroupViewInfo.GetLayoutDirection: TdxLayoutDirection;
begin
  Result := Group.LayoutDirection;
end;

function TdxLayoutGroupViewInfo.GetOptionsEx: TdxLayoutLookAndFeelGroupOptions;
begin
  Result := TdxLayoutLookAndFeelGroupOptions(inherited Options);
end;

procedure TdxLayoutGroupViewInfo.CreateItemViewInfos;
var
  I: Integer;
  AItem: TdxCustomLayoutItem;
  AItemViewInfo: TdxCustomLayoutItemViewInfo;
begin
  FItemViewInfos := TList.Create;
  for I := 0 to Group.VisibleCount - 1 do
  begin
    AItem := Group.VisibleItems[I];
    AItemViewInfo :=
      GetItemViewInfoClass(AItem).Create(FContainerViewInfo, Self, AItem);
    FItemViewInfos.Add(AItemViewInfo);
  end;
end;

procedure TdxLayoutGroupViewInfo.CreateSpecific;
begin
  FSpecific := GetSpecificClass.Create(Self);
end;

procedure TdxLayoutGroupViewInfo.DestroyItemViewInfos;
var
  I: Integer;
begin
  for I := 0 to ItemViewInfoCount - 1 do
    ItemViewInfos[I].Free;
  FreeAndNil(FItemViewInfos);
end;

procedure TdxLayoutGroupViewInfo.DestroySpecific;
begin
  FreeAndNil(FSpecific);
end;

function TdxLayoutGroupViewInfo.GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass;
begin
  Result := TdxLayoutGroupCaptionViewInfo;
end;

function TdxLayoutGroupViewInfo.GetHitTestClass: TdxCustomLayoutItemHitTestClass;
begin
  Result := TdxLayoutGroupHitTest;
end;

function TdxLayoutGroupViewInfo.GetPainterClass: TdxCustomLayoutItemPainterClass;
begin
  Result := TdxCustomLayoutItemPainterClass(LookAndFeel.GetGroupPainterClass);
end;

function TdxLayoutGroupViewInfo.DoCalculateHeight(AIsMinHeight: Boolean = False): Integer;
begin
  Result := inherited DoCalculateHeight(AIsMinHeight) +
    GetHeight(Specific.CalculateHeight(AIsMinHeight));
end;

function TdxLayoutGroupViewInfo.DoCalculateWidth(AIsMinWidth: Boolean = False): Integer;
begin
  Result := inherited DoCalculateWidth(AIsMinWidth) +
    GetWidth(Specific.CalculateWidth(AIsMinWidth));
end;

function TdxLayoutGroupViewInfo.CalculateCaptionViewInfoBounds: TRect;
begin
  Result := Rect(0, 0, 0, 0);
end;

function TdxLayoutGroupViewInfo.CalculateItemsAreaBounds: TRect;
begin
  Result := Bounds;
  Inc(Result.Left, BorderWidths[sdLeft]);
  Inc(Result.Top, BorderWidths[sdTop]);
  Dec(Result.Right, BorderWidths[sdRight]);
  Dec(Result.Bottom, BorderWidths[sdBottom]);
end;

procedure TdxLayoutGroupViewInfo.CalculateConsts;
begin
  if UseItemsAreaOffsets then
    if Group.IsRoot then
    begin
      ItemsAreaOffsetHorz := LookAndFeel.GetRootItemsAreaOffsetHorz(Item.Container);
      ItemsAreaOffsetVert := LookAndFeel.GetRootItemsAreaOffsetVert(Item.Container);
    end
    else
    begin
      ItemsAreaOffsetHorz := LookAndFeel.GetItemsAreaOffsetHorz(Item.Container);
      ItemsAreaOffsetVert := LookAndFeel.GetItemsAreaOffsetVert(Item.Container);
    end
  else
  begin
    ItemsAreaOffsetHorz := 0;
    ItemsAreaOffsetVert := 0;
  end;

  if UseItemOffset then
    ItemOffset := LookAndFeel.GetItemOffset(Item.Container)
  else
    ItemOffset := 0;
end;

function TdxLayoutGroupViewInfo.GetBorderWidth(ASide: TdxLayoutSide): Integer;
begin
  case ASide of
    sdLeft, sdRight:
      Result := ItemsAreaOffsetHorz;
    sdTop, sdBottom:
      Result := ItemsAreaOffsetVert;
  else
    Result := 0;
  end;
  if HasBorder then
    Inc(Result, LookAndFeel.GetGroupBorderWidth(Item.Container, ASide, HasCaption));
end;

function TdxLayoutGroupViewInfo.GetClientBounds: TRect;
begin
  Result := Bounds;
  if HasBorder then
    with LookAndFeel, Result do
    begin
      Inc(Left, GetGroupBorderWidth(Item.Container, sdLeft, HasCaption));
      Dec(Right, GetGroupBorderWidth(Item.Container, sdRight, HasCaption));
      Inc(Top, GetGroupBorderWidth(Item.Container, sdTop, HasCaption));
      Dec(Bottom, GetGroupBorderWidth(Item.Container, sdBottom, HasCaption));
    end;
end;

function TdxLayoutGroupViewInfo.GetColor: TColor;
begin
  Result := Options.GetColor;
end;

function TdxLayoutGroupViewInfo.GetConst(Index: Integer): Integer;
begin
  if not FConstsCalculated then
  begin
    CalculateConsts;
    FConstsCalculated := True;
  end;
  case Index of
    2: Result := FItemOffset;
    3: Result := FItemsAreaOffsetHorz;
    4: Result := FItemsAreaOffsetVert;
  else
    Result := -1;
  end;
end;

function TdxLayoutGroupViewInfo.GetHeight(AItemsAreaHeight: Integer): Integer;
begin
  Result := BorderWidths[sdTop] + AItemsAreaHeight + BorderWidths[sdBottom];
end;

function TdxLayoutGroupViewInfo.GetIsDefaultColor: Boolean;
begin
  Result := Options.Color = clDefault;
end;

function TdxLayoutGroupViewInfo.GetItemViewInfoClass(AItem: TdxCustomLayoutItem): TdxCustomLayoutItemViewInfoClass;
begin
  Result := AItem.GetViewInfoClass;
end;

function TdxLayoutGroupViewInfo.GetMinVisibleWidth: Integer;
begin
  if HasCaption then
    Result := CaptionViewInfo.MinWidth
  else
    Result := 0;
end;

function TdxLayoutGroupViewInfo.GetOptions: TdxCustomLayoutLookAndFeelOptions;
begin
  Result := LookAndFeel.GroupOptions;
end;

function TdxLayoutGroupViewInfo.GetRestSpaceBounds: TRect;
begin
  Result := Bounds;
end;

function TdxLayoutGroupViewInfo.GetSpecificClass: TdxLayoutGroupViewInfoSpecificClass;
begin
  case LayoutDirection of
    ldHorizontal:
      Result := TdxLayoutGroupViewInfoHorizontalSpecific;
    ldVertical:
      Result := TdxLayoutGroupViewInfoVerticalSpecific;
  else
    Result := nil;
  end;
end;

function TdxLayoutGroupViewInfo.GetWidth(AItemsAreaWidth: Integer): Integer;
begin
  Result := BorderWidths[sdLeft] + AItemsAreaWidth + BorderWidths[sdRight];
  if Result < MinVisibleWidth then Result := MinVisibleWidth;
end;

function TdxLayoutGroupViewInfo.HasBorder: Boolean;
begin
  Result := Group.ShowBorder;
end;

function TdxLayoutGroupViewInfo.HasBoundsFrame: Boolean;
begin
  Result := Group.Hidden and Group.Container.ShowHiddenGroupsBounds;
end;

function TdxLayoutGroupViewInfo.UseItemOffset: Boolean;
begin
  Result := Group.UseIndent;
end;

function TdxLayoutGroupViewInfo.UseItemsAreaOffsets: Boolean;
begin
  Result := Group.ShowBorder or Group.IsRoot;
end;

procedure TdxLayoutGroupViewInfo.Calculate(const ABounds: TRect);
begin
  inherited;
  FItemsAreaBounds := CalculateItemsAreaBounds;
  CaptionViewInfo.Calculate(CalculateCaptionViewInfoBounds);
  Specific.CalculateItemsBounds(ItemsAreaBounds);
end;

procedure TdxLayoutGroupViewInfo.CalculateTabOrders(var AAvailTabOrder: Integer);
var
  I: Integer;
begin
  for I := 0 to ItemViewInfoCount - 1 do
    ItemViewInfos[I].CalculateTabOrders(AAvailTabOrder);
end;

function TdxLayoutGroupViewInfo.GetHitTest(const P: TPoint): TdxCustomLayoutHitTest;
var
  I: Integer;
begin
  for I := 0 to ItemViewInfoCount - 1 do
  begin
    Result := ItemViewInfos[I].GetHitTest(P);
    if Result <> nil then Exit;
  end;
  if ContainerViewInfo.HideHiddenGroupsFromHitTest and
    Group.Hidden and not IsLocked then
    Result := nil
  else
    Result := inherited GetHitTest(P);
end;

function TdxLayoutGroupViewInfo.GetInsertionPos(const P: TPoint): Integer;
var
  R: TRect;
begin
  if PtInRect(Bounds, P) then
    for Result := 0 to ItemViewInfoCount - 1 do
    begin
      R := ItemViewInfos[Result].Bounds;
      if Specific.IsAtInsertionPos(R, P) then Exit;
    end;
  Result := ItemViewInfoCount;
end;

{ TdxLayoutGroupStandardCaptionViewInfo }

function TdxLayoutGroupStandardCaptionViewInfo.GetItemViewInfo: TdxLayoutGroupStandardViewInfo;
begin
  Result := TdxLayoutGroupStandardViewInfo(inherited ItemViewInfo);
end;

function TdxLayoutGroupStandardCaptionViewInfo.GetAlignHorz: TAlignment;
begin
  Result := taCenter;
end;

function TdxLayoutGroupStandardCaptionViewInfo.CalculateWidth: Integer;
begin
  Result := inherited CalculateWidth;
  if Visible then
    Inc(Result, 2 + 2);
end;

{ TdxLayoutGroupStandardViewInfo }

function TdxLayoutGroupStandardViewInfo.GetLookAndFeel: TdxLayoutStandardLookAndFeel;
begin
  Result := TdxLayoutStandardLookAndFeel(inherited LookAndFeel);
end;

function TdxLayoutGroupStandardViewInfo.CalculateCaptionViewInfoBounds: TRect;
var
  ACaptionWidth: Integer;
begin
  Result := BorderBounds[sdTop];
  ACaptionWidth := CaptionViewInfo.CalculateWidth;
  with Result do
  begin
    case Item.CaptionOptions.AlignHorz of
      taLeftJustify:
        begin
          Inc(Left, CaptionViewInfoOffset);
          Right := Left + ACaptionWidth;
        end;
      taRightJustify:
        begin
          Dec(Right, CaptionViewInfoOffset);
          Left := Right - ACaptionWidth;
        end;
      taCenter:
        begin
          Left := (Left + Right - ACaptionWidth) div 2;
          Right := Left + ACaptionWidth;
        end;
    end;
    Bottom := Top + CaptionViewInfo.CalculateHeight;
  end;
end;

function TdxLayoutGroupStandardViewInfo.GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass;
begin
  Result := TdxLayoutGroupStandardCaptionViewInfo;
end;

function TdxLayoutGroupStandardViewInfo.GetMinVisibleWidth: Integer;
begin
  Result := inherited GetMinVisibleWidth;
  if HasCaption then
    Inc(Result, 2 * CaptionViewInfoOffset);
end;

function TdxLayoutGroupStandardViewInfo.GetCaptionViewInfoOffset: Integer;
begin
  Result := LookAndFeel.HDLUToPixels(CaptionViewInfo.Font, 7) - 2;
end;

function TdxLayoutGroupStandardViewInfo.GetFrameBounds: TRect;
begin
  Result := Bounds;
  Inc(Result.Top, LookAndFeel.VDLUToPixels(CaptionViewInfo.Font, 4) -
    LookAndFeel.FrameWidths[sdTop] div 2);
end;

{ TdxLayoutGroupOfficeCaptionViewInfo }

function TdxLayoutGroupOfficeCaptionViewInfo.CalculateWidth: Integer;
var
  AOffset: Integer;
begin
  Result := inherited CalculateWidth;
  if Visible then
  begin
    AOffset := LookAndFeel.HDLUToPixels(Font, 5);
    if AlignHorz = taCenter then
      AOffset := 2 * AOffset;
    Inc(Result, AOffset);  
  end;
end;

{ TdxLayoutGroupOfficeViewInfo }

function TdxLayoutGroupOfficeViewInfo.GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass;
begin
  Result := TdxLayoutGroupOfficeCaptionViewInfo;
end;

function TdxLayoutGroupOfficeViewInfo.GetCaptionViewInfoOffset: Integer;
begin
  Result := 0;
end;

function TdxLayoutGroupOfficeViewInfo.GetFrameBounds: TRect;
begin
  Result := inherited GetFrameBounds;
  with Result do
    Bottom := Top + 2;
end;

function TdxLayoutGroupOfficeViewInfo.GetMinVisibleWidth: Integer;
begin
  Result := inherited GetMinVisibleWidth;
  if HasCaption then Inc(Result, 20);
end;

{ TdxLayoutGroupWebCaptionViewInfo }

function TdxLayoutGroupWebCaptionViewInfo.GetItemViewInfo: TdxLayoutGroupWebViewInfo;
begin
  Result := TdxLayoutGroupWebViewInfo(inherited ItemViewInfo);
end;

function TdxLayoutGroupWebCaptionViewInfo.GetLookAndFeel: TdxLayoutWebLookAndFeel;
begin
  Result := TdxLayoutWebLookAndFeel(inherited LookAndFeel);
end;

function TdxLayoutGroupWebCaptionViewInfo.GetOptionsEx: TdxLayoutWebLookAndFeelGroupCaptionOptions;
begin
  Result := TdxLayoutWebLookAndFeelGroupCaptionOptions(inherited Options);
end;

function TdxLayoutGroupWebCaptionViewInfo.GetSeparatorWidth: Integer;
begin
  Result := Options.SeparatorWidth;
end;

function TdxLayoutGroupWebCaptionViewInfo.GetAlignVert: TdxAlignmentVert;
begin
  Result := tavCenter;
end;

function TdxLayoutGroupWebCaptionViewInfo.GetColor: TColor;
begin
  Result := Options.GetColor;
end;

function TdxLayoutGroupWebCaptionViewInfo.GetIsDefaultColor: Boolean;
begin
  Result := Options.Color = clDefault;
end;

function TdxLayoutGroupWebCaptionViewInfo.GetMinWidth: Integer;
begin
  Result := 2 * TextOffset + inherited GetMinWidth;
end;

function TdxLayoutGroupWebCaptionViewInfo.GetTextAreaBounds: TRect;
begin
  Result := inherited GetTextAreaBounds;
  Inc(Result.Left, TextOffset);
end;

function TdxLayoutGroupWebCaptionViewInfo.GetTextOffset: Integer;
begin
  if ItemViewInfo.Options.OffsetCaption then
    Result := LookAndFeel.VDLUToPixels(Font, 5)
  else
    Result := LookAndFeel.DLUToPixels(Font, 2);
end;

function TdxLayoutGroupWebCaptionViewInfo.CalculateHeight: Integer;
begin
  if Visible then
    Result := LookAndFeel.VDLUToPixels(Font, 11{12})
  else
    Result := inherited CalculateHeight;
end;

{ TdxLayoutGroupWebViewInfo }

function TdxLayoutGroupWebViewInfo.GetCaptionViewInfo: TdxLayoutGroupWebCaptionViewInfo;
begin
  Result := TdxLayoutGroupWebCaptionViewInfo(inherited CaptionViewInfo);
end;

function TdxLayoutGroupWebViewInfo.GetInsideFrameBounds: TRect;
begin
  Result := Bounds;
  with Options do
    InflateRect(Result, -FrameWidth, -FrameWidth);
end;

function TdxLayoutGroupWebViewInfo.GetLookAndFeel: TdxLayoutWebLookAndFeel;
begin
  Result := TdxLayoutWebLookAndFeel(inherited LookAndFeel);
end;

function TdxLayoutGroupWebViewInfo.GetOptionsEx: TdxLayoutWebLookAndFeelGroupOptions;
begin
  Result := TdxLayoutWebLookAndFeelGroupOptions(inherited Options);
end;

function TdxLayoutGroupWebViewInfo.CalculateCaptionViewInfoBounds: TRect;
begin
  Result := InsideFrameBounds;
  Result.Bottom := Result.Top + CaptionViewInfo.CalculateHeight;
end;

function TdxLayoutGroupWebViewInfo.GetCaptionViewInfoClass: TdxCustomLayoutItemCaptionViewInfoClass;
begin
  Result := TdxLayoutGroupWebCaptionViewInfo;
end;

function TdxLayoutGroupWebViewInfo.GetMinVisibleWidth: Integer;
begin
  Result := inherited GetMinVisibleWidth;
  Inc(Result, 2 * Options.FrameWidth);
end;

function TdxLayoutGroupWebViewInfo.GetRestSpaceBounds: TRect;
begin
  Result := inherited GetRestSpaceBounds;
  with Options do
    InflateRect(Result, -FrameWidth, -FrameWidth);
  if HasCaption then
    Result.Top := CaptionViewInfo.Bounds.Bottom;
  if Options.HasCaptionSeparator(HasCaption) then
    Inc(Result.Top, CaptionViewInfo.SeparatorWidth);
end;

function TdxLayoutGroupWebViewInfo.GetCaptionSeparatorAreaBounds: TRect;
begin
  Result := RestSpaceBounds;
  Result.Bottom := Result.Top;
  Dec(Result.Top, CaptionViewInfo.SeparatorWidth);
end;

function TdxLayoutGroupWebViewInfo.GetCaptionSeparatorBounds: TRect;
begin
  Result := CaptionSeparatorAreaBounds;
  if not Options.OffsetCaption and not Options.OffsetItems and
    (Options.FrameWidth = 0) and (CaptionViewInfo.Color = Color) then
    with ClientBounds do
    begin
      Result.Left := Left;
      Result.Right := Right;
    end;
end;

{ TdxLayoutControlViewInfo }

constructor TdxLayoutControlViewInfo.Create(AControl: TdxCustomLayoutControl);
begin
  inherited;
  CreateViewInfos;
end;

destructor TdxLayoutControlViewInfo.Destroy;
begin
  DestroyViewInfos;
  FCanvas.Free;
  inherited;
end;

function TdxLayoutControlViewInfo.GetClientHeight: Integer;
begin
  with ClientBounds do
    Result := Bottom - Top;
end;

function TdxLayoutControlViewInfo.GetClientWidth: Integer;
begin
  with ClientBounds do
    Result := Right - Left;
end;

function TdxLayoutControlViewInfo.GetContentHeight: Integer;
begin
  with ContentBounds do
    Result := Bottom - Top;
end;

function TdxLayoutControlViewInfo.GetContentWidth: Integer;
begin
  with ContentBounds do
    Result := Right - Left;
end;

function TdxLayoutControlViewInfo.GetLookAndFeel: TdxCustomLayoutLookAndFeel;
begin
  Result := FControl.GetLookAndFeel;
end;

procedure TdxLayoutControlViewInfo.CreateViewInfos;
begin
  if LookAndFeel <> nil then
    FItemsViewInfo := GetItemsViewInfoClass.Create(Self, nil, FControl.Items);
end;

procedure TdxLayoutControlViewInfo.DestroyViewInfos;
begin
  FreeAndNil(FItemsViewInfo);
end;

function TdxLayoutControlViewInfo.GetItemsViewInfoClass: TdxLayoutGroupViewInfoClass;
begin
  Result := TdxLayoutGroupViewInfoClass(FControl.Items.GetViewInfoClass);
end;

procedure TdxLayoutControlViewInfo.RecreateViewInfos;
begin
  DestroyViewInfos;
  CreateViewInfos;
end;

procedure TdxLayoutControlViewInfo.AlignItems;
var
  I: Integer;

  procedure ProcessConstraint(AConstraint: TdxLayoutAlignmentConstraint);
  var
    AItemViewInfos: TList;

    procedure RetrieveItemViewInfos;
    var
      I: Integer;
      AViewInfo: TdxCustomLayoutItemViewInfo;
    begin
      for I := 0 to AConstraint.Count - 1 do
      begin
        AViewInfo := AConstraint.Items[I].ViewInfo;
        if AViewInfo <> nil then
          AItemViewInfos.Add(AViewInfo);
      end;
    end;

    function GetSide: TdxLayoutSide;
    begin
      if AConstraint.Kind in [ackLeft, ackRight] then
        Result := sdLeft
      else
        Result := sdTop;
    end;

    function AlignItemViewInfos: Boolean;
    var
      AMaxBorderValue, I: Integer;

      function GetBorderValue(AItemViewInfoIndex: Integer): Integer;
      begin
        with TdxCustomLayoutItemViewInfo(AItemViewInfos[AItemViewInfoIndex]), Bounds do
          case AConstraint.Kind of
            ackLeft:
              Result := Left - CalculateOffset(sdLeft);
            ackTop:
              Result := Top - CalculateOffset(sdTop);
            ackRight:
              Result := Right + CalculateOffset(sdRight);
            ackBottom:
              Result := Bottom + CalculateOffset(sdBottom);
          else
            Result := 0;
          end;
      end;

      function FindMaxBorderValue: Integer;
      var
        I: Integer;
      begin
        Result := -MaxInt;
        for I := 0 to AItemViewInfos.Count - 1 do
          if Result < GetBorderValue(I) then Result := GetBorderValue(I);
      end;

      procedure ChangeOffset(AItemViewInfoIndex, ADelta: Integer);
      begin
        with TdxCustomLayoutItemViewInfo(AItemViewInfos[AItemViewInfoIndex]) do
          Offsets[GetSide] := Offsets[GetSide] + ADelta;
      end;

      function AreItemViewInfosAligned: Boolean;
      var
        I, ABorderValue: Integer;
      begin
        ABorderValue := 0;
        for I := 0 to AItemViewInfos.Count - 1 do
          if I = 0 then
            ABorderValue := GetBorderValue(I)
          else
          begin
            Result := GetBorderValue(I) = ABorderValue;
            if not Result then Exit;
          end;
        Result := True;
      end;

    begin
      AMaxBorderValue := FindMaxBorderValue;
      for I := 0 to AItemViewInfos.Count - 1 do
        ChangeOffset(I, AMaxBorderValue - GetBorderValue(I));
      CalculateItemsViewInfo;
      Result := AreItemViewInfosAligned;
    end;

    procedure ResetOffsets;
    var
      I: Integer;
    begin
      for I := 0 to AItemViewInfos.Count - 1 do
        TdxCustomLayoutItemViewInfo(AItemViewInfos[I]).ResetOffset(GetSide);
      CalculateItemsViewInfo;
    end;

  begin
    AItemViewInfos := TList.Create;
    try
      RetrieveItemViewInfos;
      while not AlignItemViewInfos do  //!!! to think about invisible items if items will be deleted
      begin
        ResetOffsets;
        if AItemViewInfos.Count > 2 then
          AItemViewInfos.Count := AItemViewInfos.Count - 1
        else
          Break;
      end;
    finally
      AItemViewInfos.Free;
    end;
  end;

begin
  for I := 0 to FControl.AlignmentConstraintCount - 1 do
    ProcessConstraint(FControl.AlignmentConstraints[I]);
end;

function CompareAllItemViewInfos(Item1, Item2: TdxLayoutItemViewInfo): Integer;
begin
  Result := Ord(Item2.CaptionLayout) - Ord(Item1.CaptionLayout);
end;

function CompareItemViewInfos(Item1, Item2: TdxLayoutItemViewInfo): Integer;
begin
  case Item1.CaptionLayout of
    clLeft:
      Result := Item1.Bounds.Left - Item2.Bounds.Left;
    clTop:
      Result := Item1.Bounds.Top - Item2.Bounds.Top;
    clRight:
      Result := Item1.Bounds.Right - Item2.Bounds.Right;
    clBottom:
      Result := Item1.Bounds.Bottom - Item2.Bounds.Bottom;
  else
    Result := 0;
  end;
end;

procedure TdxLayoutControlViewInfo.AutoAlignControls;
var
  AAllItemViewInfos: TList;
  ACaptionLayout: TdxCaptionLayout;

  procedure FindAllItemViewInfos(ACustomItemViewInfo: TdxCustomLayoutItemViewInfo);
  var
    I: Integer;
  begin
    if ACustomItemViewInfo is TdxLayoutGroupViewInfo then
      with TdxLayoutGroupViewInfo(ACustomItemViewInfo) do
        for I := 0 to ItemViewInfoCount - 1 do
          FindAllItemViewInfos(ItemViewInfos[I])
    else
      if TdxLayoutItemViewInfo(ACustomItemViewInfo).AutoControlAlignment then
        AAllItemViewInfos.Add(ACustomItemViewInfo);
  end;

  procedure SortAllItemViewInfos;
  begin
    AAllItemViewInfos.Sort(@CompareAllItemViewInfos);
  end;

  procedure ProcessItemViewInfos(ACaptionLayout: TdxCaptionLayout);
  var
    AItemViewInfos: TList;
    AGroupedCount: Integer;

    procedure ExtractItemViewInfos;
    var
      I, ACount: Integer;
    begin
      I := AAllItemViewInfos.Count - 1;
      while (I <> -1) and
        (TdxLayoutItemViewInfo(AAllItemViewInfos[I]).CaptionLayout = ACaptionLayout) do
        Dec(I);
      ACount := AAllItemViewInfos.Count - 1 - I;

      AItemViewInfos.Count := ACount;
      Move(AAllItemViewInfos.List^[I + 1], AItemViewInfos.List^[0],
        ACount * SizeOf(Pointer));

      AAllItemViewInfos.Count := I + 1;
    end;

    procedure SortItemViewInfos;
    begin
      AItemViewInfos.Sort(@CompareItemViewInfos);
    end;

    function FindGroup: Boolean;
    var
      AItemViewInfo1, AItemViewInfo2: TdxLayoutItemViewInfo;
    begin
      AItemViewInfo1 := AItemViewInfos[0];
      AGroupedCount := 1;
      while AGroupedCount < AItemViewInfos.Count do
      begin
        AItemViewInfo2 := AItemViewInfos[AGroupedCount];
        if CompareItemViewInfos(AItemViewInfo1, AItemViewInfo2) <> 0 then
          Break;
        Inc(AGroupedCount);
      end;
      Result := AGroupedCount <> 1;
    end;

    procedure AlignControls;

      function IsCaptionLayoutHorizontal: Boolean;
      begin
        Result := ACaptionLayout in [clLeft, clRight];
      end;

      function GetMaxCaptionSize: Integer;
      var
        I, ACaptionSize: Integer;
      begin
        Result := 0;
        for I := 0 to AGroupedCount - 1 do
        begin
          with TdxLayoutItemViewInfo(AItemViewInfos[I]).CaptionViewInfo do
            if IsCaptionLayoutHorizontal then
              ACaptionSize := Width
            else
              ACaptionSize := Height;
          if Result < ACaptionSize then Result := ACaptionSize;
        end;
      end;

      procedure AssignCaptionSizes(AMaxCaptionSize: Integer);
      var
        I: Integer;
      begin
        for I := 0 to AGroupedCount - 1 do
          with TdxLayoutItemViewInfo(AItemViewInfos[I]).CaptionViewInfo do
            if IsCaptionLayoutHorizontal then
              Width := AMaxCaptionSize
            else
              Height := AMaxCaptionSize;
      end;

    begin
      AssignCaptionSizes(GetMaxCaptionSize);
      CalculateItemsViewInfo;
    end;

    procedure RemoveProcessedItemViewInfos;
    begin
      Move(AItemViewInfos.List^[AGroupedCount], AItemViewInfos.List^[0],
        (AItemViewInfos.Count - AGroupedCount) * SizeOf(Pointer));
      AItemViewInfos.Count := AItemViewInfos.Count - AGroupedCount;
    end;

  begin
    AItemViewInfos := TList.Create;
    try
      ExtractItemViewInfos;
      while AItemViewInfos.Count <> 0 do
      begin
        SortItemViewInfos;
        if FindGroup then AlignControls;
        RemoveProcessedItemViewInfos;
      end;
    finally
      AItemViewInfos.Free;
    end;
  end;

begin
  AAllItemViewInfos := TList.Create;
  try
    FindAllItemViewInfos(ItemsViewInfo);
    SortAllItemViewInfos;
    for ACaptionLayout := Low(ACaptionLayout) to High(ACaptionLayout) do
      ProcessItemViewInfos(ACaptionLayout);
  finally
    AAllItemViewInfos.Free;
  end;
end;

procedure TdxLayoutControlViewInfo.CalculateItemsViewInfo;
begin
  ResetContentBounds;
  ItemsViewInfo.Calculate(ContentBounds);
end;

procedure TdxLayoutControlViewInfo.CalculateTabOrders;
var
  AAvailTabOrder: Integer;
begin
  AAvailTabOrder := 0;
  ItemsViewInfo.CalculateTabOrders(AAvailTabOrder);
end;

function TdxLayoutControlViewInfo.GetIsTransparent: Boolean;
begin
  Result := HasBackground;
end;

function TdxLayoutControlViewInfo.HasBackground: Boolean;
begin  
  Result := Control.HasBackground;
end;

procedure TdxLayoutControlViewInfo.PrepareData;
begin
  RecreateViewInfos;
end;

procedure TdxLayoutControlViewInfo.ResetContentBounds;
begin
  SetRectEmpty(FContentBounds);
end;

function TdxLayoutControlViewInfo.GetCanvas: TcxCanvas;
begin
  if Control.HandleAllocated then
  begin
    if FCanvas <> nil then FreeAndNil(FCanvas);
    Result := Control.Canvas;
  end
  else
  begin
    if FCanvas = nil then
      FCanvas := TcxScreenCanvas.Create;
    Result := FCanvas;
  end;
end;

function TdxLayoutControlViewInfo.GetClientBounds: TRect;
begin
  Result := FControl.ClientBounds;
end;

function TdxLayoutControlViewInfo.GetContentBounds: TRect;

  function CalculateContentWidth: Integer;
  var
    AMinWidth: Integer;
  begin
    if acsWidth in Control.AutoContentSizes then
    begin
      with ClientBounds do
        Result := Right - Left;
      AMinWidth := ItemsViewInfo.MinWidth;
      if Result < AMinWidth then Result := AMinWidth;
    end
    else
      Result := ItemsViewInfo.CalculateWidth;
  end;

  function CalculateContentHeight: Integer;
  var
    AMinHeight: Integer;
  begin
    if acsHeight in Control.AutoContentSizes then
    begin
      with ClientBounds do
        Result := Bottom - Top;
      AMinHeight := ItemsViewInfo.MinHeight;
      if Result < AMinHeight then Result := AMinHeight;
    end
    else
      Result := ItemsViewInfo.CalculateHeight;
  end;

begin
  if IsRectEmpty(FContentBounds) then
    with FContentBounds do
    begin
      Left := -Control.LeftPos;
      Top := -Control.TopPos;
      Right := Left + CalculateContentWidth;
      Bottom := Top + CalculateContentHeight;
    end;
  Result := FContentBounds;
end;

procedure TdxLayoutControlViewInfo.Calculate;
begin
  PrepareData;
  CalculateItemsViewInfo;
  AlignItems;
  if Control.AutoControlAlignment then
  begin
    AutoAlignControls;
    AlignItems;
  end;
  Control.CheckPositions;
  Control.UpdateScrollBars;
  DoCalculateTabOrders;
  if Control.HandleAllocated then
    Control.IsPlaceControlsNeeded := True;
end;

procedure TdxLayoutControlViewInfo.DoCalculateTabOrders;
begin
  if Control.AutoControlTabOrders then CalculateTabOrders;
end;

function TdxLayoutControlViewInfo.GetHitTest(const P: TPoint): TdxCustomLayoutHitTest;
var
  ADesigner: TCustomForm;
begin
  if Control.IsDesigning then
    ADesigner := dxLayoutDesigner.GetDesigner(Control)
  else
    ADesigner := nil;
  if Control.Customization and
    PtInRect(Control.CustomizeForm.BoundsRect, Control.ClientToScreen(P)) or
    (ADesigner <> nil) and PtInRect(ADesigner.BoundsRect, Control.ClientToScreen(P)) then
    Result := TdxLayoutCustomizeFormHitTest.Instance
  else
    if PtInRect(ClientBounds, P) then
    begin
      Result := ItemsViewInfo.GetHitTest(P);
      if Result = nil then
        Result := TdxLayoutClientAreaHitTest.Instance;
    end
    else
      Result := nil;
  if Result = nil then
    Result := TdxLayoutNoneHitTest.Instance;
end;

function TdxLayoutControlViewInfo.GetHitTest(X, Y: Integer): TdxCustomLayoutHitTest;
begin
  Result := GetHitTest(Point(X, Y));
end;

{ TdxLayoutCustomizeListBox }

function TdxLayoutCustomizeListBox.GetDragAndDropItemObject: TdxCustomLayoutItem;
begin
  Result := TdxCustomLayoutItem(inherited DragAndDropItemObject);
end;

procedure TdxLayoutCustomizeListBox.BeginDragAndDrop;
begin
  inherited;
  with Control do
    if CanDragAndDrop then
    begin
      (DragAndDropObject as TdxLayoutControlDragAndDropObject).Init(dsCustomizeForm,
        Self.DragAndDropItemObject);
      BeginDragAndDrop;
    end;
end;

initialization
  Screen.Cursors[crdxLayoutControlDrag] := LoadCursor(HInstance, 'DXLAYOUTCONTROLDRAGCURSOR');

  RegisterClasses([TdxLayoutItem, TdxLayoutGroup, TdxLayoutAlignmentConstraint]);

  HitTests := THitTests.Create;

finalization
  FreeAndNil(HitTests);

end.
