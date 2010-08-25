
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressCommonLibrary                                         }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSCOMMONLIBRARY AND ALL          }
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

{$DEFINE USETCXSCROLLBAR}

unit cxListView;

{$I cxVer.inc}

interface

uses
  Windows, Forms, Classes, ComCtrls, CommCtrl, Controls, ImgList, Menus,
  Messages, StdCtrls, SysUtils, cxClasses, cxContainer, cxControls, cxCustomData,
  cxExtEditConsts, cxGraphics, cxGeometry, cxLookAndFeels, cxScrollBar, cxHeader;

const
  cxiaTop = TIconArrangement(0);

type
  TcxCustomListView = class;

  { TcxIconOptions }

  TcxIconOptions = class(TPersistent)
  private
    FArrangement: TIconArrangement;
    FAutoArrange: Boolean;
    FWrapText: Boolean;
    FArrangementChange: TNotifyEvent;
    FAutoArrangeChange: TNotifyEvent;
    FWrapTextChange: TNotifyEvent;
    procedure SetArrangement(Value: TIconArrangement);
    procedure SetAutoArrange(Value: Boolean);
    procedure SetWrapText(Value: Boolean);
  public
    constructor Create(AOwner: TPersistent);
  published
    property Arrangement: TIconArrangement read FArrangement write SetArrangement default cxiaTop;
    property AutoArrange: Boolean read FAutoArrange write SetAutoArrange default False;
    property WrapText: Boolean read FWrapText write SetWrapText default True;
  end;

  { TcxCustomInnerListView }

  TcxCustomInnerListView = class(TListView, IUnknown,
    IcxContainerInnerControl)
  private
    FCanvas: TcxCanvas;
    FDefHeaderProc: Pointer;
    FHeaderHandle: HWND;
    FHeaderInstance: Pointer;
    FOldHint: string;
    FOldItem: TListItem;
    FPressedHeaderItemIndex: Integer;

    function GetHeaderHotItemIndex: Integer;
    function GetHeaderItemRect(AItemIndex: Integer): TRect;
    function GetHeaderPressedItemIndex: Integer;
    function HeaderItemIndex(AHeaderItem: Integer): Integer;
    procedure HeaderWndProc(var Message: TMessage);

    procedure HScrollHandler(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure VScrollHandler(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure CMHintShow(var Message: TCMHintShow); message CM_HINTSHOW;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure LVMGetHeaderItemInfo(var Message: TCMHeaderItemInfo); message CM_GETHEADERITEMINFO;

    function GetContainer: TcxCustomListView;
    function GetControl: TWinControl;
    function GetControlContainer: TcxContainer;
  protected
    FContainer: TcxCustomListView;
    procedure Click; override;
    procedure DblClick; override;
    procedure Loaded; override;
    function CanEdit(Item: TListItem): Boolean; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure DoStartDock(var DragObject: TDragObject); override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure WndProc(var Message: TMessage); override;
    procedure DoCancelEdit; virtual;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); virtual;
    procedure MouseEnter(AControl: TControl); dynamic;
    procedure MouseLeave(AControl: TControl); dynamic;

    procedure DrawHeader; virtual;

    property Container: TcxCustomListView read GetContainer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DefaultHandler(var Message); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    property Canvas: TcxCanvas read FCanvas;
    function CanFocus: Boolean; override;
  {$IFDEF DELPHI6}
    procedure DeleteSelected; override;
  {$ENDIF}
  end;

  TcxCustomInnerListViewClass = class of TcxCustomInnerListView;

  { TcxCustomListView }

  TcxCustomListView = class(TcxContainer)
  private
    FInnerListView: TcxCustomInnerListView;
    FIconOptions: TcxIconOptions;
    FOnCancelEdit: TNotifyEvent;
    FOwnerDraw: Boolean;
    function GetReadOnly: Boolean;
    function GetListItems: TListItems;
    function GetListColumns: TListColumns;
    function GetListViewCanvas: TcxCanvas;
    function GetColumnClick: Boolean;
    function GetHideSelection: Boolean;
    function GetIconOptions: TcxIconOptions;
    function GetAllocBy: Integer;
    function GetHoverTime: Integer;
    function GetLargeImages: TCustomImageList;
    function GetMultiSelect: Boolean;
    function GetOwnerData: Boolean;
    function GetOwnerDraw: Boolean;
    function GetOnAdvancedCustomDraw: TLVAdvancedCustomDrawEvent;
    function GetOnAdvancedCustomDrawItem: TLVAdvancedCustomDrawItemEvent;
    function GetOnAdvancedCustomDrawSubItem: TLVAdvancedCustomDrawSubItemEvent;
    function GetOnChange: TLVChangeEvent;
    function GetOnChanging: TLVChangingEvent;
    function GetOnColumnClick: TLVColumnClickEvent;
    function GetOnColumnDragged: TNotifyEvent;
    function GetOnColumnRightClick: TLVColumnRClickEvent;
    function GetOnCompare: TLVCompareEvent;
    function GetOnCustomDraw: TLVCustomDrawEvent;
    function GetOnCustomDrawItem: TLVCustomDrawItemEvent;
    function GetOnCustomDrawSubItem: TLVCustomDrawSubItemEvent;
    function GetOnData: TLVOwnerDataEvent;
    function GetOnDataFind: TLVOwnerDataFindEvent;
    function GetOnDataHint: TLVOwnerDataHintEvent;
    function GetOnDataStateChange: TLVOwnerDataStateChangeEvent;
    function GetOnDeletion: TLVDeletedEvent;
    function GetOnDrawItem: TLVDrawItemEvent;
    function GetOnEdited: TLVEditedEvent;
    function GetOnEditing: TLVEditingEvent;
    function GetOnInfoTip: TLVInfoTipEvent;
    function GetOnInsert: TLVDeletedEvent;
    function GetOnGetImageIndex: TLVNotifyEvent;
    function GetOnGetSubItemImage: TLVSubItemImageEvent;
    function GetShowWorkAreas: Boolean;
    function GetOnSelectItem: TLVSelectItemEvent;
    function GetShowColumnHeaders: Boolean;
    function GetSmallImages: TCustomImageList;
    function GetSortType: TSortType;
    function GetStateImages: TCustomImageList;
    function GetViewStyle: TViewStyle;
  {$IFDEF DELPHI6}
    function GetOnCreateItemClass: TLVCreateItemClassEvent;
  {$ENDIF}
    procedure SetReadOnly(Value: Boolean);
    procedure SetListItems(Value: TListItems);
    procedure SetListColumns(Value: TListColumns);
    procedure SetColumnClick(Value: Boolean);
    procedure SetHideSelection(Value: Boolean);
    procedure SetIconOptions(Value: TcxIconOptions);
    procedure SetAllocBy(Value: Integer);
    procedure SetHoverTime(Value: Integer);
    procedure SetLargeImages(Value: TCustomImageList);
    procedure SetMultiSelect(Value: Boolean);
    procedure SetOwnerData(Value: Boolean);
    procedure SetOwnerDraw(Value: Boolean);
    procedure SetOnAdvancedCustomDraw(Value: TLVAdvancedCustomDrawEvent);
    procedure SetOnAdvancedCustomDrawItem(Value: TLVAdvancedCustomDrawItemEvent);
    procedure SetOnAdvancedCustomDrawSubItem(Value: TLVAdvancedCustomDrawSubItemEvent);
    procedure SetOnChange(Value: TLVChangeEvent);
    procedure SetOnChanging(Value: TLVChangingEvent);
    procedure SetOnColumnClick(Value: TLVColumnClickEvent);
    procedure SetOnColumnDragged(Value: TNotifyEvent);
    procedure SetOnColumnRightClick(Value: TLVColumnRClickEvent);
    procedure SetOnCompare(Value: TLVCompareEvent);
    procedure SetOnCustomDraw(Value: TLVCustomDrawEvent);
    procedure SetOnCustomDrawItem(Value: TLVCustomDrawItemEvent);
    procedure SetOnCustomDrawSubItem(Value: TLVCustomDrawSubItemEvent);
    procedure SetOnData(Value: TLVOwnerDataEvent);
    procedure SetOnDataFind(Value: TLVOwnerDataFindEvent);
    procedure SetOnDataHint(Value: TLVOwnerDataHintEvent);
    procedure SetOnDataStateChange(Value: TLVOwnerDataStateChangeEvent);
    procedure SetOnDeletion(Value: TLVDeletedEvent);
    procedure SetOnDrawItem(Value: TLVDrawItemEvent);
    procedure SetOnEdited(Value: TLVEditedEvent);
    procedure SetOnEditing(Value: TLVEditingEvent);
    procedure SetOnInfoTip(Value: TLVInfoTipEvent);
    procedure SetOnInsert(Value: TLVDeletedEvent);
    procedure SetOnGetImageIndex(Value: TLVNotifyEvent);
    procedure SetOnGetSubItemImage(Value: TLVSubItemImageEvent);
    procedure SetShowWorkAreas(Value: Boolean);
    procedure SetOnSelectItem(Value: TLVSelectItemEvent);
    procedure SetShowColumnHeaders(Value: Boolean);
    procedure SetSmallImages(Value: TCustomImageList);
    procedure SetSortType(Value: TSortType);
    procedure SetStateImages(Value: TCustomImageList);
  {$IFDEF DELPHI6}
    procedure SetOnCreateItemClass(Value: TLVCreateItemClassEvent);
  {$ENDIF}
    function GetCheckBoxes: Boolean;
    function GetColumnFromIndex(Index: Integer): TListColumn;
    function GetDropTarget: TListItem;
    function GetFullDrag: Boolean;
    function GetGridLines: Boolean;
    function GetHotTrack: Boolean;
    function GetHotTrackStyles: TListHotTrackStyles;
    function GetItemFocused: TListItem;
    function GetRowSelect: Boolean;
    function GetSelCount: Integer;
    function GetSelected: TListItem;
    function GetTopItem: TListItem;
    function GetViewOrigin: TPoint;
    function GetVisibleRowCount: Integer;
    function GetBoundingRect: TRect;
    function GetWorkAreas: TWorkAreas;
    procedure SetCheckboxes(Value: Boolean);
    procedure SetDropTarget(Value: TListItem);
    procedure SetFullDrag(Value: Boolean);
    procedure SetGridLines(Value: Boolean);
    procedure SetHotTrack(Value: Boolean);
    procedure SetHotTrackStyles(Value: TListHotTrackStyles);
    procedure SetItemFocused(Value: TListItem);
    procedure SetRowSelect(Value: Boolean);
    procedure SetSelected(Value: TListItem);
    procedure ArrangementChangeHandler(Sender: TObject);
    procedure AutoArrangeChangeHandler(Sender: TObject);
    procedure WrapTextChangeHandler(Sender: TObject);
    procedure UpdateIconOptions;
  protected
    procedure DoExit; override;
    procedure FontChanged; override;
    function IsReadOnly: Boolean; override;
    procedure Loaded; override;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); override;
    function NeedsScrollBars: Boolean; override;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); override;
    procedure WriteState(Writer: TWriter); override;

    class function GetListViewClass: TcxCustomInnerListViewClass; virtual;

    function CanChange(Item: TListItem; Change: Integer): Boolean;
    function CanEdit(Item: TListItem): Boolean;
    procedure ChangeScale(M, D: Integer); override;
    function ColumnsShowing: Boolean;
    function GetCount: Integer;
  {$IFDEF DELPHI6}
    function GetItemIndex: Integer; overload;
    function GetListViewItemIndex: Integer;
    procedure SetItemIndex(Value: Integer);
  {$ENDIF}
    function GetItemIndex(Value: TListItem): Integer; overload;
    procedure SetViewStyle(Value: TViewStyle); virtual;
    procedure UpdateColumn(AnIndex: Integer);
    procedure UpdateColumns;
    
    property Columns: TListColumns read GetListColumns write SetListColumns;
    property ColumnClick: Boolean read GetColumnClick write SetColumnClick default True;
    property HideSelection: Boolean read GetHideSelection write SetHideSelection default True;
    property IconOptions: TcxIconOptions read GetIconOptions write SetIconOptions;
    property Items: TListItems read GetListItems write SetListItems;
    property AllocBy: Integer read GetAllocBy write SetAllocBy default 0;
    property HoverTime: Integer read GetHoverTime write SetHoverTime default -1;
    property ListViewCanvas: TcxCanvas read GetListViewCanvas;
    property LargeImages: TCustomImageList read GetLargeImages write SetLargeImages;
    property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect default False;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property OwnerData: Boolean read GetOwnerData write SetOwnerData default False;
    property OwnerDraw: Boolean read GetOwnerDraw write SetOwnerDraw default False;
    property RowSelect: Boolean read GetRowSelect write SetRowSelect default False;
    property ShowColumnHeaders: Boolean read GetShowColumnHeaders
      write SetShowColumnHeaders default True;
    property ShowWorkAreas: Boolean read GetShowWorkAreas write SetShowWorkAreas default False;
    property SmallImages: TCustomImageList read GetSmallImages write SetSmallImages;
    property SortType: TSortType read GetSortType write SetSortType default stNone;
    property StateImages: TCustomImageList read GetStateImages write SetStateImages;
    property ViewStyle: TViewStyle read GetViewStyle write SetViewStyle default vsIcon;
    property OnAdvancedCustomDraw: TLVAdvancedCustomDrawEvent read GetOnAdvancedCustomDraw
      write SetOnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem: TLVAdvancedCustomDrawItemEvent
      read GetOnAdvancedCustomDrawItem write SetOnAdvancedCustomDrawItem;
    property OnAdvancedCustomDrawSubItem: TLVAdvancedCustomDrawSubItemEvent
      read GetOnAdvancedCustomDrawSubItem write SetOnAdvancedCustomDrawSubItem;
    property OnCancelEdit: TNotifyEvent read FOnCancelEdit write FOnCancelEdit;
    property OnChange: TLVChangeEvent read GetOnChange write SetOnChange;
    property OnChanging: TLVChangingEvent read GetOnChanging write SetOnChanging;
    property OnColumnClick: TLVColumnClickEvent read GetOnColumnClick write SetOnColumnClick;
    property OnColumnDragged: TNotifyEvent read GetOnColumnDragged write SetOnColumnDragged;
    property OnColumnRightClick: TLVColumnRClickEvent read GetOnColumnRightClick
      write SetOnColumnRightClick;
    property OnCompare: TLVCompareEvent read GetOnCompare write SetOnCompare;
    property OnCustomDraw: TLVCustomDrawEvent read GetOnCustomDraw write SetOnCustomDraw;
    property OnCustomDrawItem: TLVCustomDrawItemEvent read GetOnCustomDrawItem
      write SetOnCustomDrawItem;
    property OnCustomDrawSubItem: TLVCustomDrawSubItemEvent read GetOnCustomDrawSubItem
      write SetOnCustomDrawSubItem;
    property OnData: TLVOwnerDataEvent read GetOnData write SetOnData;
    property OnDataFind: TLVOwnerDataFindEvent read GetOnDataFind write SetOnDataFind;
    property OnDataHint: TLVOwnerDataHintEvent read GetOnDataHint write SetOnDataHint;
    property OnDataStateChange: TLVOwnerDataStateChangeEvent read GetOnDataStateChange
      write SetOnDataStateChange;
    property OnDeletion: TLVDeletedEvent read GetOnDeletion write SetOnDeletion;
    property OnDrawItem: TLVDrawItemEvent read GetOnDrawItem write SetOnDrawItem;
    property OnEdited: TLVEditedEvent read GetOnEdited write SetOnEdited;
    property OnEditing: TLVEditingEvent read GetOnEditing write SetOnEditing;
    property OnInfoTip: TLVInfoTipEvent read GetOnInfoTip write SetOnInfoTip;
    property OnInsert: TLVDeletedEvent read GetOnInsert write SetOnInsert;
    property OnGetImageIndex: TLVNotifyEvent read GetOnGetImageIndex write SetOnGetImageIndex;
    property OnGetSubItemImage: TLVSubItemImageEvent read GetOnGetSubItemImage
      write SetOnGetSubItemImage;
    property OnSelectItem: TLVSelectItemEvent read GetOnSelectItem write SetOnSelectItem;
  {$IFDEF DELPHI6}
    property OnCreateItemClass: TLVCreateItemClassEvent read GetOnCreateItemClass
      write SetOnCreateItemClass;
  {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property InnerListView: TcxCustomInnerListView read FInnerListView;
    function AlphaSort: Boolean;
    procedure Arrange(Code: TListArrangement);
    procedure Clear;
  {$IFDEF DELPHI6}
    procedure ClearSelection;
    procedure AddItem(Item: string; AObject: TObject);
    procedure CopySelection(Destination: TCustomListControl);
    procedure DeleteSelected;
    procedure SelectAll;
  {$ENDIF}
    function FindCaption(StartIndex: Integer; Value: string;
      Partial, Inclusive, Wrap: Boolean): TListItem;
    function FindData(StartIndex: Integer; Value: Pointer;
      Inclusive, Wrap: Boolean): TListItem;
    function GetHitTestInfoAt(X, Y: Integer): THitTests;
    function GetItemAt(X, Y: Integer): TListItem;
    function GetNearestItem(Point: TPoint;
      Direction: TSearchDirection): TListItem;
    function GetNextItem(StartItem: TListItem;
      Direction: TSearchDirection; States: TItemStates): TListItem;
    function GetSearchString: string;
    function IsEditing: Boolean;
    function CustomSort(SortProc: TLVCompare; lParam: Longint): Boolean;
    function StringWidth(S: string): Integer;
    procedure UpdateItems(FirstIndex, LastIndex: Integer);

    property Checkboxes: Boolean read GetCheckBoxes write SetCheckboxes default False;
    property Column[Index: Integer]: TListColumn read GetColumnFromIndex;
    property DropTarget: TListItem read GetDropTarget write SetDropTarget;
    property FullDrag: Boolean read GetFullDrag write SetFullDrag default False;
    property GridLines: Boolean read GetGridLines write SetGridLines default False;
    property HotTrack: Boolean read GetHotTrack write SetHotTrack default False;
    property HotTrackStyles: TListHotTrackStyles read GetHotTrackStyles write SetHotTrackStyles default [];
    property ItemFocused: TListItem read GetItemFocused write SetItemFocused;
  {$IFDEF DELPHI6}
    property ItemIndex: Integer read GetListViewItemIndex write SetItemIndex
      default -1;
  {$ENDIF}
    property SelCount: Integer read GetSelCount;
    property Selected: TListItem read GetSelected write SetSelected;
    property TopItem: TListItem read GetTopItem;
    property ViewOrigin: TPoint read GetViewOrigin;
    property VisibleRowCount: Integer read GetVisibleRowCount;
    property BoundingRect: TRect read GetBoundingRect;
    property WorkAreas: TWorkAreas read GetWorkAreas;
  end;

  { TcxListView }

  TcxListView = class(TcxCustomListView)
  public
    property ListViewCanvas;
  published
    property Align;
    property AllocBy default 0;
    property Anchors;
    property BiDiMode;
    property Checkboxes;
    property ColumnClick default True;
    property Columns;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property HideSelection default True;
    property HotTrack default False;
    property HoverTime default -1;
    property IconOptions;
  {$IFDEF DELPHI6}
    property ItemIndex;
  {$ENDIF}
    property Items;
    property LargeImages;
    property MultiSelect default False;
    property OwnerData default False;
    property OwnerDraw default False;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly default False;
    property RowSelect default False;
    property ShowColumnHeaders default True;
    property ShowHint;
    property ShowWorkAreas default False;
    property SmallImages;
    property SortType default stNone;
    property StateImages;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property ViewStyle default vsIcon;
    property Visible;
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
    property OnAdvancedCustomDrawSubItem;
    property OnCancelEdit;
    property OnChange;
    property OnChanging;
    property OnClick;
    property OnColumnClick;
    property OnColumnDragged;
    property OnColumnRightClick;
    property OnCompare;
    property OnContextPopup;
  {$IFDEF DELPHI6}
    property OnCreateItemClass;
  {$ENDIF}
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnCustomDrawSubItem;
    property OnData;
    property OnDataFind;
    property OnDataHint;
    property OnDataStateChange;
    property OnDblClick;
    property OnDeletion;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEdited;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImageIndex;
    property OnGetSubItemImage;
    property OnInfoTip;
    property OnInsert;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnSelectItem;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Graphics, Types, Math, cxLookAndFeelPainters;

{ TcxIconOptions }

constructor TcxIconOptions.Create(AOwner: TPersistent);
begin
  inherited Create;
  Arrangement := cxiaTop;
  AutoArrange := False;
  WrapText := True;
end;

procedure TcxIconOptions.SetArrangement(Value: TIconArrangement);
begin
  if Value <> Arrangement then
  begin;
    FArrangement := Value;
    if Assigned(FArrangementChange) then FArrangementChange(Self);
  end;
end;

procedure TcxIconOptions.SetAutoArrange(Value: Boolean);
begin
  if Value <> AutoArrange then
  begin
    FAutoArrange := Value;
    if Assigned(FAutoArrangeChange) then FAutoArrangeChange(Self);
  end;
end;

procedure TcxIconOptions.SetWrapText(Value: Boolean);
begin
  if Value <> WrapText then
  begin
    FWrapText := Value;
    if Assigned(FWrapTextChange) then FWrapTextChange(Self);
  end;
end;

{ TcxCustomInnerListView }

constructor TcxCustomInnerListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCanvas := TcxCanvas.Create(inherited Canvas);
  BorderStyle := bsNone;
  ControlStyle := ControlStyle + [csDoubleClicks];
  IconOptions.Arrangement := cxiaTop;
  IconOptions.AutoArrange := False;
  IconOptions.WrapText := True;
  ParentColor := False;
  ParentFont := True;
  ShowColumnHeaders := True;
  FPressedHeaderItemIndex := -1;
end;

destructor TcxCustomInnerListView.Destroy;
begin
  FreeAndNil(FCanvas);
  if FHeaderHandle <> 0 then
  begin
    SetWindowLong(FHeaderHandle, GWL_WNDPROC, Integer(FDefHeaderProc));
    FHeaderHandle := 0;
  end;
  FreeObjectInstance(FHeaderInstance);
  inherited Destroy;
end;

procedure TcxCustomInnerListView.DefaultHandler(var Message);
begin
  if (Container = nil) or
    not Container.InnerControlDefaultHandler(TMessage(Message)) then
      inherited DefaultHandler(Message);
end;

procedure TcxCustomInnerListView.Loaded;
begin
  inherited;
  Container.UpdateIconOptions;
  FoldHint := Hint;
end;

procedure TcxCustomInnerListView.DragDrop(Source: TObject; X, Y: Integer);
begin
  if Container <> nil then
    Container.DragDrop(Source, Left + X, Top + Y);
end;

procedure TcxCustomInnerListView.Click;
begin
  inherited Click;
  if Container <> nil then
    _TcxContainerAccess.Click(Container);
end;

procedure TcxCustomInnerListView.DblClick;
begin
  inherited DblClick;
  if Container <> nil then
    _TcxContainerAccess.DblClick(Container);
end;

function TcxCustomInnerListView.CanEdit(Item: TListItem): Boolean;
begin
  if Container <> nil then
  begin
    Result := (not Container.ReadOnly) {and (not OwnerData)}; {<- Prevent bug, when Caption not saved after CreateWnd in "OwnerData" mode}
    if Result then
      Result := inherited CanEdit(Item);
  end
  else
    Result := inherited CanEdit(Item);
end;

function TcxCustomInnerListView.DoMouseWheel(Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := (Container <> nil) and
    _TcxContainerAccess.DoMouseWheel(Container, Shift, WheelDelta, MousePos);
  if not Result then
    inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

procedure TcxCustomInnerListView.DoStartDock(var DragObject: TDragObject);
begin
  _TcxContainerAccess.BeginAutoDrag(Container);
end;

procedure TcxCustomInnerListView.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Container <> nil then
    _TcxContainerAccess.DragOver(Container, Source, Left + X, Top + Y, State, Accept);
end;

procedure TcxCustomInnerListView.DoCancelEdit;
begin
  if IsEditing and Assigned(Container) and not Container.IsDestroying and
    Assigned(Container.OnCancelEdit) then
    Container.OnCancelEdit(Container);
end;

procedure TcxCustomInnerListView.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  if FHeaderHandle <> 0 then
    InvalidateRect(FHeaderHandle, nil, False);
end;

procedure TcxCustomInnerListView.MouseEnter(AControl: TControl);
begin
end;

procedure TcxCustomInnerListView.MouseLeave(AControl: TControl);
begin
  if Container <> nil then
    Container.ShortRefreshContainer(True);
end;

procedure TcxCustomInnerListView.DrawHeader;
var
  I: Integer;
begin
  Canvas.Brush.Color := Container.LookAndFeelPainter.DefaultHeaderColor;
  Canvas.Font := Font;
  Canvas.Font.Color := Container.LookAndFeelPainter.DefaultHeaderTextColor;
  for I := 0 to Columns.Count do
    DrawHeaderSection(FHeaderHandle, I, Canvas, Container.LookAndFeel, SmallImages);
end;

procedure TcxCustomInnerListView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Container <> nil then
    _TcxContainerAccess.KeyDown(Container, Key, Shift);
  if Key <> 0 then
    inherited KeyDown(Key, Shift);
end;

procedure TcxCustomInnerListView.KeyPress(var Key: Char);
begin
  if Key = Char(VK_TAB) then
    Key := #0;
  if Container <> nil then
    _TcxContainerAccess.KeyPress(Container, Key);
  if Word(Key) = VK_RETURN then
    Key := #0;
  if Key <> #0 then
    inherited KeyPress(Key);
end;

procedure TcxCustomInnerListView.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Key = VK_TAB then
    Key := 0;
  if Container <> nil then
    _TcxContainerAccess.KeyUp(Container, Key, Shift);
  if Key <> 0 then
    inherited KeyUp(Key, Shift);
end;

procedure TcxCustomInnerListView.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Container <> nil then
    with Container do
    begin
      InnerControlMouseDown := True;
      try
        MouseDown(Button, Shift, X + Self.Left, Y + Self.Top);
      finally
        InnerControlMouseDown := False;
      end;
    end;
end;

procedure TcxCustomInnerListView.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if (GetItemAt(X, Y) = nil) then
    Hint := FOldHint;
  if Container <> nil then
    _TcxContainerAccess.MouseMove(Container, Shift, X + Left, Y + Top);
end;

procedure TcxCustomInnerListView.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Container <> nil then
    _TcxContainerAccess.MouseUp(Container, Button, Shift, X + Left, Y + Top);
end;

procedure TcxCustomInnerListView.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if Container.IconOptions.AutoArrange then
    Params.Style := Params.Style or LVS_AUTOARRANGE
  else
    Params.Style := Params.Style and not LVS_AUTOARRANGE;
  if not Container.ShowColumnHeaders then
    Params.Style := Params.Style or LVS_NOCOLUMNHEADER;
end;

procedure TcxCustomInnerListView.CreateWnd;
begin
  inherited CreateWnd;
  Container.SetScrollBarsParameters;
  Container.AdjustInnerControl;
end;

procedure TcxCustomInnerListView.WndProc(var Message: TMessage);
var
  AHeaderStyle: Integer;
  S: string;
begin
  if (Container <> nil) and Container.InnerControlMenuHandler(Message) then
    Exit;
  inherited WndProc(Message);
  case Message.Msg of
    WM_PAINT:
      Container.UpdateScrollBarsParameters;
    WM_PARENTNOTIFY:
      if Message.WParamLo = WM_CREATE then
      begin
        SetLength(S, 80);
        SetLength(S, GetClassName(Message.LParam, PChar(S), Length(S)));
        if S = 'SysHeader32' then
        begin
          FHeaderHandle := Message.LParam;
          FHeaderInstance := MakeObjectInstance(HeaderWndProc);
          FDefHeaderProc := Pointer(SetWindowLong(FHeaderHandle, GWL_WNDPROC, Integer(FHeaderInstance)));
          AHeaderStyle := GetWindowLong(FHeaderHandle, GWL_STYLE);
          SetWindowLong(FHeaderHandle, GWL_STYLE, AHeaderStyle or HDS_HOTTRACK);
        end;
      end;
  end;
end;

function TcxCustomInnerListView.CanFocus: Boolean;
begin
  Result := Container.CanFocus;
end;

{$IFDEF DELPHI6}
procedure TcxCustomInnerListView.DeleteSelected;
begin
  if Assigned(Container) and (not Container.ReadOnly) then
    inherited DeleteSelected;
end;
{$ENDIF}

function TcxCustomInnerListView.GetHeaderHotItemIndex: Integer;
var
  AHitTestInfo: THDHitTestInfo;
begin
  if WindowFromPoint(InternalGetCursorPos) <> FHeaderHandle then
  begin
    Result := -1;
    Exit;
  end;

  AHitTestInfo.Point := InternalGetCursorPos;
  Windows.ScreenToClient(FHeaderHandle, AHitTestInfo.Point);
  SendGetStructMessage(FHeaderHandle, HDM_HITTEST, 0, AHitTestInfo);
  Result := AHitTestInfo.Item;
end;

function TcxCustomInnerListView.GetHeaderItemRect(AItemIndex: Integer): TRect;
var
  AHeaderItem: THDItem;
  I: Integer;
  R: TRect;
begin
  if GetComCtlVersion >= ComCtlVersionIE3 then
    SendGetStructMessage(FHeaderHandle, HDM_GETITEMRECT, AItemIndex, Result)
  else
  begin
    Result.Top := 0;
    Result.Left := 0;
    AHeaderItem.Mask := HDI_WIDTH;
    for I := 0 to AItemIndex - 1 do
    begin
      SendGetStructMessage(FHeaderHandle, HDM_GETITEM, I, AHeaderItem);
      Inc(Result.Left, AHeaderItem.cxy);
    end;
    R := cxGetWindowRect(FHeaderHandle);
    Result.Bottom := cxRectWidth(R);
    SendGetStructMessage(FHeaderHandle, HDM_GETITEM, AItemIndex, AHeaderItem);
    Result.Right := Result.Left + AHeaderItem.cxy;
  end;
end;

function TcxCustomInnerListView.GetHeaderPressedItemIndex: Integer;
var
  AHitTestInfo: THDHitTestInfo;
begin
  AHitTestInfo.Point := InternalGetCursorPos;
  Windows.ScreenToClient(FHeaderHandle, AHitTestInfo.Point);
  SendGetStructMessage(FHeaderHandle, HDM_HITTEST, 0, AHitTestInfo);
  if AHitTestInfo.Flags and (HHT_ONDIVIDER or HHT_ONDIVOPEN) <> 0 then
    Result := -1
  else
    Result := AHitTestInfo.Item;
end;

function TcxCustomInnerListView.HeaderItemIndex(AHeaderItem: Integer): Integer;
begin
  Result := AHeaderItem;
  if GetComCtlVersion >= ComCtlVersionIE3 then
    Result := SendMessage(FHeaderHandle, HDM_ORDERTOINDEX, AHeaderItem, 0);
end;

procedure TcxCustomInnerListView.HeaderWndProc(var Message: TMessage);

  procedure CallDefHeaderProc;
  begin
    Message.Result := CallWindowProc(FDefHeaderProc, FHeaderHandle,
      Message.Msg, Message.WParam, Message.LParam);
  end;

var
  ADC: HDC;
  APaintStruct: TPaintStruct;
  R: TRect;
begin
  case Message.Msg of
    WM_ERASEBKGND:
      Message.Result := 1;
    WM_PAINT, WM_PRINTCLIENT:
      begin
        ADC := Message.WParam;
        if ADC = 0 then
          ADC := BeginPaint(FHeaderHandle, APaintStruct);
        try
          Canvas.Canvas.Handle := ADC;
          Canvas.Canvas.Refresh;
          DrawHeader;
        finally
          if Message.WParam = 0 then
            EndPaint(FHeaderHandle, APaintStruct);
        end;
      end;
    WM_LBUTTONDOWN:
    begin
      CallDefHeaderProc;
      if ColumnClick and (GetCapture = FHeaderHandle) then
        FPressedHeaderItemIndex := GetHeaderPressedItemIndex;
    end;
    WM_CAPTURECHANGED:
    begin
      if FPressedHeaderItemIndex <> -1 then
      begin
        R := GetHeaderItemRect(FPressedHeaderItemIndex);
        InvalidateRect(FHeaderHandle, @R, False);
      end;
      FPressedHeaderItemIndex := -1;
      CallDefHeaderProc;
    end;
    CM_GETHEADERITEMINFO:
      Perform(CM_GETHEADERITEMINFO, Message.WParam, Message.LParam);
  else
    CallDefHeaderProc;
  end;
end;

procedure TcxCustomInnerListView.HScrollHandler(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  if ScrollCode = scTrack then
    SendMessage(Handle, LVM_SCROLL, ScrollPos - GetScrollPos(Handle, SB_HORZ), 0)
  else
  begin
    CallWindowProc(DefWndProc, Handle, WM_HSCROLL,
      MakeWParam(Word(ScrollCode), Word(ScrollPos)), Container.HScrollBar.Handle);
    ScrollPos := GetScrollPos(Handle, SB_HORZ);
  end;
end;

procedure TcxCustomInnerListView.VScrollHandler(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);

  function GetLineHeight: Integer;
  var
    AItemRect: TRect;
  begin
    AItemRect := TopItem.DisplayRect(drBounds);
    Result := AItemRect.Bottom - AItemRect.Top;
  end;

var
  P: TPoint;
begin
  if ScrollCode = scTrack then
    case ViewStyle of
      vsReport:
        SendMessage(Handle, LVM_SCROLL, 0, (ScrollPos - ListView_GetTopIndex(Handle)) * GetLineHeight);
      vsIcon, vsSmallIcon:
        begin
          SendGetStructMessage(Handle, LVM_GETORIGIN, 0, P);
          SendMessage(Handle, LVM_SCROLL, 0, ScrollPos - P.Y);
        end;
    end
  else
  begin
    CallWindowProc(DefWndProc, Handle, WM_VSCROLL, Word(ScrollCode) +
      Word(ScrollPos) shl 16, Container.VScrollBar.Handle);
    ScrollPos := GetScrollPos(Handle, SB_VERT);
  end;
end;

procedure TcxCustomInnerListView.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  if Container <> nil then
    with Message do
    begin
      Result := Result or DLGC_WANTCHARS;
      if GetKeyState(VK_CONTROL) >= 0 then
        Result := Result or DLGC_WANTTAB;
    end;
end;

procedure TcxCustomInnerListView.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if (Container <> nil) and not Container.IsDestroying then
    Container.FocusChanged;
end;

procedure TcxCustomInnerListView.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if Dragging then
  begin
    CancelDrag;
    Container.BeginDrag(False);
  end;
end;

procedure TcxCustomInnerListView.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  inherited;
  if not Container.ScrollBarsCalculating then
    Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerListView.WMNCPaint(var Message: TWMNCPaint);
var
  DC: HDC;
  ABrush: HBRUSH;
begin
  if UsecxScrollBars and Container.HScrollBarVisible and
    Container.VScrollBarVisible then
  begin
    DC := GetWindowDC(Handle);
    ABrush := 0;
    try
      with Container.LookAndFeel do
        ABrush := CreateSolidBrush(ColorToRGB(Painter.DefaultSizeGripAreaColor));
      FillRect(DC, GetSizeGripRect(Self), ABrush);
    finally
      if ABrush <> 0 then
        DeleteObject(ABrush);
      ReleaseDC(Handle, DC);
    end;
  end;
end;

procedure TcxCustomInnerListView.WMNotify(var Message: TWMNotify);
begin
  inherited;
  if Message.NMHdr.code = HDN_ITEMCHANGED then
    Container.SetScrollBarsParameters(True);
end;

procedure TcxCustomInnerListView.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if (Container <> nil) and not Container.IsDestroying and
    not(csDestroying in ComponentState) and
    (Message.FocusedWnd <> Container.Handle) then
      Container.FocusChanged;
end;

procedure TcxCustomInnerListView.WMWindowPosChanged(var Message: TWMWindowPosChanged);
var
  ARgn: HRGN;
begin
  if not (csDestroying in ComponentState) then
    Container.SetScrollBarsParameters;
  inherited;
  if csDestroying in ComponentState then
    Exit;
  if Container.HScrollBarVisible and Container.VScrollBarVisible then
  begin
    ARgn := CreateRectRgnIndirect(GetSizeGripRect(Self));
    SendMessage(Handle, WM_NCPAINT, ARgn, 0);
    DeleteObject(ARgn);
  end;
end;

procedure TcxCustomInnerListView.CMHintShow(var Message: TCMHintShow);
var
  AInfoTip: string;
  AItem: TListItem;
  AItemRect: TRect;
  AHintInfo: PHintInfo;
begin
  AItem := GetItemAt(Message.HintInfo.CursorPos.X,
    Message.HintInfo.CursorPos.Y);
  if FOldItem = AItem then
    Exit;

  if not Assigned(OnInfoTip) then
  begin
    FOldHint := Hint;
    inherited;
  end
  else
    if AItem <> nil then
    begin
      AInfoTip := AItem.Caption;
      DoInfoTip(AItem, AInfoTip);

      AItemRect := AItem.DisplayRect(drBounds);
      AItemRect.TopLeft := ClientToScreen(AItemRect.TopLeft);
      AItemRect.BottomRight := ClientToScreen(AItemRect.BottomRight);

      AHintInfo := Message.HintInfo;
      AHintInfo.HintStr := AInfoTip;
      AHintInfo.CursorRect := AItemRect;
      AHintInfo.HintPos := Point(
        AHintInfo.CursorRect.Left + GetSystemMetrics(SM_CXCURSOR),
        AHintInfo.CursorRect.Top + GetSystemMetrics(SM_CYCURSOR));
      AHintInfo.HintMaxWidth := ClientWidth;
      Hint := AInfoTip;
    end;
  FOldItem := AItem;
end;

procedure TcxCustomInnerListView.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseEnter(Self)
  else
    MouseEnter(TControl(Message.lParam));
end;

procedure TcxCustomInnerListView.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseLeave(Self)
  else
    MouseLeave(TControl(Message.lParam));
end;

procedure TcxCustomInnerListView.CNNotify(
  var Message: TWMNotify);
var
  AItem: PLVItem;
  APrevBrushChangeHandler, APrevFontChangeHandler: TNotifyEvent;
begin
  if Message.NMHdr.code = LVN_ENDLABELEDIT then
  begin
    AItem := @PLVDispInfo(Message.NMHdr)^.item;
    if (AItem.iItem <> -1) then
      if (AItem.pszText <> nil) then
      begin
        if CanChange(Items[AItem.iItem], LVIF_TEXT) then
          Edit(AItem^);
      end
      else
        DoCancelEdit;
  end
  else
    if Message.NMHdr.code = NM_CUSTOMDRAW then
    begin
      APrevBrushChangeHandler := Canvas.Brush.OnChange;
      APrevFontChangeHandler := Canvas.Font.OnChange;
      inherited;
      Canvas.Brush.OnChange := APrevBrushChangeHandler;
      Canvas.Font.OnChange := APrevFontChangeHandler;
    end
    else
      inherited;
end;

procedure TcxCustomInnerListView.LVMGetHeaderItemInfo(var Message: TCMHeaderItemInfo);

  function GetItemState: TcxButtonState;

    function CanHotTrack: Boolean;
    var
      I: Integer;
    begin
      Result := ColumnClick;
      if Result then
        for I := 0 to Columns.Count - 1 do
          if Columns[I].ImageIndex <> -1 then
          begin
            Result := False;
            Break;
          end;
    end;

  var
    AHeaderItemIndex: Integer;
  begin
    if not Parent.Enabled then
      Result := cxbsDisabled
    else
    begin
      AHeaderItemIndex := HeaderItemIndex(Message.Index);
      if AHeaderItemIndex = FPressedHeaderItemIndex then
        Result := cxbsPressed
      else
        if CanHotTrack and (AHeaderItemIndex = GetHeaderHotItemIndex) then
          Result := cxbsHot
        else
          Result := cxbsNormal;
    end;
  end;

  function GetItemRect: TRect;
  var
    R: TRect;
  begin
    if Message.Index = Columns.Count then
    begin
      Windows.GetClientRect(FHeaderHandle, Result);
      if Columns.Count > 0 then
      begin
        R := GetHeaderItemRect(HeaderItemIndex(Columns.Count - 1));
        Result.Left := R.Right;
      end;
    end
    else
      Result := GetHeaderItemRect(HeaderItemIndex(Message.Index));
  end;

var
  AIndex: Integer;
  AHeaderItemInfo: PHeaderItemInfo;
begin
  AIndex := Message.Index;
  AHeaderItemInfo := Message.HeaderItemInfo;
  ZeroMemory(AHeaderItemInfo, SizeOf(THeaderItemInfo));
  if AIndex < Columns.Count then
  begin
    AHeaderItemInfo.ImageIndex := Columns[AIndex].ImageIndex;
    AHeaderItemInfo.SectionAlignment := Columns[AIndex].Alignment;
    AHeaderItemInfo.SortOrder := soNone;
    AHeaderItemInfo.Text := Columns[AIndex].Caption;
  end
  else
    AHeaderItemInfo.ImageIndex := -1;
  AHeaderItemInfo.Rect := GetItemRect;
  AHeaderItemInfo.State := GetItemState;
  Message.HeaderItemInfo := AHeaderItemInfo;
end;

function TcxCustomInnerListView.GetContainer: TcxCustomListView;
begin
  Result := TcxCustomListView(FContainer);
end;

function TcxCustomInnerListView.GetControl: TWinControl;
begin
  Result := Self;
end;

function TcxCustomInnerListView.GetControlContainer: TcxContainer;
begin
  Result := FContainer;
end;

{ TcxCustomListView }

constructor TcxCustomListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOwnerDraw := False;
  FIconOptions := TcxIconOptions.Create(Self);
  FIconOptions.FArrangementChange := ArrangementChangeHandler;
  FIconOptions.FAutoArrangeChange := AutoArrangeChangeHandler;
  FIconOptions.FWrapTextChange := WrapTextChangeHandler;
  FInnerListView := GetListViewClass.Create(Self);
  FInnerListView.AutoSize := False;
  FInnerListView.Align := alClient;
  FInnerListView.BorderStyle := bsNone;
  FInnerListView.Parent := Self;
  FInnerListView.FContainer := Self;
  FInnerListView.OwnerDraw := False;
  InnerControl := FInnerListView;
  Width := 121;
  Height := 97;
end;

destructor TcxCustomListView.Destroy;
begin
  FreeAndNil(FInnerListView);
  FreeAndNil(FIconOptions);
  inherited Destroy;
end;

procedure TcxCustomListView.UpdateIconOptions;
begin
  if Assigned(InnerListView) then
  begin
    InnerListView.Items.BeginUpdate;
    try
      InnerListView.IconOptions.Arrangement := FIconOptions.Arrangement;
      InnerListView.IconOptions.AutoArrange := FIconOptions.AutoArrange;
      InnerListView.IconOptions.WrapText := FIconOptions.WrapText;
    finally
      InnerListView.Items.EndUpdate;
    end;
  end;
end;

class function TcxCustomListView.GetListViewClass: TcxCustomInnerListViewClass;
begin
  Result := TcxCustomInnerListView;
end;

{$IFDEF DELPHI6}
procedure TcxCustomListView.AddItem(Item: string; AObject: TObject);
begin
  InnerListView.AddItem(Item, AObject);
end;

procedure TcxCustomListView.ClearSelection;
begin
  InnerListView.ClearSelection;
end;

procedure TcxCustomListView.DeleteSelected;
begin
  InnerListView.DeleteSelected;
end;
{$ENDIF}

procedure TcxCustomListView.Clear;
begin
{$IFDEF DELPHI6}
  InnerListView.Clear;
{$ELSE}
  InnerListView.Items.Clear;
{$ENDIF}
end;

procedure TcxCustomListView.DoExit;
begin
  if IsDestroying then
    Exit;
  try
  except
    SetFocus;
    raise;
  end;
  inherited DoExit;
end;

procedure TcxCustomListView.FontChanged;
begin
  inherited FontChanged;
  SetSize;
end;

function TcxCustomListView.IsReadOnly: Boolean;
begin
  Result := ReadOnly;
end;

procedure TcxCustomListView.Loaded;
begin
  inherited;
  UpdateIconOptions;
  InnerListView.OwnerDraw := FOwnerDraw;
end;

procedure TcxCustomListView.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  inherited LookAndFeelChanged(Sender, AChangedValues);
  if not FIsCreating then
    InnerListView.LookAndFeelChanged(Sender, AChangedValues);
end;

function TcxCustomListView.NeedsScrollBars: Boolean;
begin
  Result := True;
end;

procedure TcxCustomListView.Scroll(AScrollBarKind: TScrollBarKind;
  AScrollCode: TScrollCode; var AScrollPos: Integer);
begin
  inherited Scroll(AScrollBarKind, AScrollCode, AScrollPos);
{$IFDEF USETCXSCROLLBAR}
  if AScrollBarKind = sbHorizontal then
    InnerListView.HScrollHandler(Self, AScrollCode, AScrollPos)
  else
    InnerListView.VScrollHandler(Self, AScrollCode, AScrollPos);
  SetScrollBarsParameters;
{$ENDIF}
end;

procedure TcxCustomListView.WriteState(Writer: TWriter);
begin
  FInnerListView.HandleNeeded;
  inherited;
end;

procedure TcxCustomListView.SetReadOnly(Value: Boolean);
begin
  if Value <> ReadOnly then
  begin
    InnerListView.ReadOnly := Value;
    DataSetChange;
  end;
end;

procedure TcxCustomListView.SetHideSelection(Value: Boolean);
begin
  InnerListView.HideSelection := Value;
end;

procedure TcxCustomListView.SetMultiSelect(Value: Boolean);
begin
  InnerListView.MultiSelect := Value;
end;

procedure TcxCustomListView.SetOwnerData(Value: Boolean);
begin
  InnerListView.OwnerData := Value;
end;

procedure TcxCustomListView.SetOwnerDraw(Value: Boolean);
begin
  FOwnerDraw := Value;
  InnerListView.OwnerDraw := Value;
end;

procedure TcxCustomListView.SetRowSelect(Value: Boolean);
begin
  InnerListView.RowSelect := Value;
end;

procedure TcxCustomListView.SetShowColumnHeaders(Value: Boolean);
begin
  InnerListView.ShowColumnHeaders := Value;
end;

procedure TcxCustomListView.SetColumnClick(Value: Boolean);
begin
  InnerListView.ColumnClick := Value;
end;

function TcxCustomListView.GetReadOnly: Boolean;
begin
  Result := InnerListView.ReadOnly;
end;

function TcxCustomListView.AlphaSort: Boolean;
begin
  Result := InnerListView.AlphaSort;
end;

procedure TcxCustomListView.Arrange(Code: TListArrangement);
begin
  InnerListView.Arrange(Code);
end;

{$IFDEF DELPHI6}
procedure TcxCustomListView.CopySelection(Destination: TCustomListControl);
begin
  InnerListView.CopySelection(Destination);
end;
{$ENDIF}

function TcxCustomListView.FindCaption(StartIndex: Integer; Value: string;
  Partial, Inclusive, Wrap: Boolean): TListItem;
begin
  Result := InnerListView.FindCaption(StartIndex, Value, Partial, Inclusive, Wrap);
end;

function TcxCustomListView.FindData(StartIndex: Integer; Value: Pointer;
  Inclusive, Wrap: Boolean): TListItem;
begin
  Result := InnerListView.FindData(StartIndex, Value, Inclusive, Wrap);
end;

function TcxCustomListView.GetHitTestInfoAt(X, Y: Integer): THitTests;
begin
  Result := InnerListView.GetHitTestInfoAt(X, Y);
end;

function TcxCustomListView.GetItemAt(X, Y: Integer): TListItem;
begin
  Result := InnerListView.GetItemAt(X, Y);
end;

function TcxCustomListView.GetNearestItem(Point: TPoint; Direction: TSearchDirection): TListItem;
begin
  Result := InnerListView.GetNearestItem(Point, Direction);
end;

function TcxCustomListView.GetNextItem(StartItem: TListItem;
  Direction: TSearchDirection; States: TItemStates): TListItem;
begin
  Result := InnerListView.GetNextItem(StartItem, Direction, States);
end;

function TcxCustomListView.GetSearchString: string;
begin
  Result := InnerListView.GetSearchString;
end;

function TcxCustomListView.IsEditing: Boolean;
begin
  Result := InnerListView.IsEditing;
end;

{$IFDEF DELPHI6}
procedure TcxCustomListView.SelectAll;
begin
  InnerListView.SelectAll;
end;
{$ENDIF}

function TcxCustomListView.CustomSort(SortProc: TLVCompare;
  lParam: Longint): Boolean;
begin
  Result := InnerListView.CustomSort(SortProc, lParam);
end;

function TcxCustomListView.StringWidth(S: string): Integer;
begin
  Result := InnerListView.StringWidth(S);
end;

procedure TcxCustomListView.UpdateItems(FirstIndex, LastIndex: Integer);
begin
  InnerListView.UpdateItems(FirstIndex, LastIndex);
end;

function TcxCustomListView.GetListItems: TListItems;
begin
  Result := InnerListView.Items;
end;

procedure TcxCustomListView.SetListItems(Value: TListItems);
begin
  InnerListView.Items := Value;
end;

function TcxCustomListView.CanChange(Item: TListItem; Change: Integer): Boolean;
begin
  Result := InnerListView.CanChange(Item, Change);
end;

function TcxCustomListView.CanEdit(Item: TListItem): Boolean;
begin
  Result := InnerListView.CanEdit(Item);
end;

procedure TcxCustomListView.ChangeScale(M, D: Integer);
begin
  inherited ChangeScale(M, D);
  InnerListView.ChangeScale(M, D);
end;

function TcxCustomListView.ColumnsShowing: Boolean;
begin
  Result := InnerListView.ColumnsShowing;
end;

function TcxCustomListView.GetCount: Integer;
begin
{$IFDEF DELPHI6}
  Result := InnerListView.GetCount;
{$ELSE}
  Result := InnerListView.Items.Count;
{$ENDIF}
end;

function TcxCustomListView.GetItemIndex(Value: TListItem): Integer;
begin
  Result := InnerListView.GetItemIndex(Value);
end;

{$IFDEF DELPHI6}
function TcxCustomListView.GetItemIndex: Integer;
begin
  Result := InnerListView.GetItemIndex;
end;

function TcxCustomListView.GetListViewItemIndex: Integer;
begin
  Result := GetItemIndex;
end;
{$ENDIF}

{$IFDEF DELPHI6}
procedure TcxCustomListView.SetItemIndex(Value: Integer);
begin
  InnerListView.SetItemIndex(Value);
end;
{$ENDIF}

procedure TcxCustomListView.SetViewStyle(Value: TViewStyle);
begin
  InnerListView.ViewStyle := Value;
  SetScrollBarsParameters;
end;

procedure TcxCustomListView.UpdateColumn(AnIndex: Integer);
begin
  InnerListView.UpdateColumn(AnIndex);
end;

procedure TcxCustomListView.UpdateColumns;
begin
  InnerListView.UpdateColumns;
end;

function TcxCustomListView.GetListColumns: TListColumns;
begin
  Result := InnerListView.Columns;
end;

function TcxCustomListView.GetListViewCanvas: TcxCanvas;
begin
  Result := InnerListView.Canvas;
end;

procedure TcxCustomListView.SetListColumns(Value: TListColumns);
begin
  InnerListView.Columns := Value;
end;

function TcxCustomListView.GetColumnClick: Boolean;
begin
  Result := InnerListView.ColumnClick;
end;

function TcxCustomListView.GetHideSelection: Boolean;
begin
  Result := InnerListView.HideSelection;
end;

function TcxCustomListView.GetIconOptions: TcxIconOptions;
begin
  Result := FIconOptions;
end;

procedure TcxCustomListView.SetIconOptions(Value: TcxIconOptions);
begin
  FIconOptions := Value;
  UpdateIconOptions;
end;

function TcxCustomListView.GetAllocBy: Integer;
begin
  Result := InnerListView.AllocBy;
end;

procedure TcxCustomListView.SetAllocBy(Value: Integer);
begin
  InnerListView.AllocBy := Value;
end;

function TcxCustomListView.GetHoverTime: Integer;
begin
  Result := InnerListView.HoverTime;
end;

procedure TcxCustomListView.SetHoverTime(Value: Integer);
begin
  InnerListView.HoverTime := Value;
end;

function TcxCustomListView.GetLargeImages: TCustomImageList;
begin
  Result := InnerListView.LargeImages;
end;

procedure TcxCustomListView.SetLargeImages(Value: TCustomImageList);
begin
  InnerListView.LargeImages := Value;
end;

function TcxCustomListView.GetMultiSelect: Boolean;
begin
  Result := InnerListView.MultiSelect;
end;

function TcxCustomListView.GetOwnerData: Boolean;
begin
  Result := InnerListView.OwnerData;
end;

function TcxCustomListView.GetOwnerDraw: Boolean;
begin
  Result := InnerListView.OwnerDraw;
end;

function TcxCustomListView.GetOnAdvancedCustomDraw: TLVAdvancedCustomDrawEvent;
begin
  Result := InnerListView.OnAdvancedCustomDraw;
end;

procedure TcxCustomListView.SetOnAdvancedCustomDraw(Value: TLVAdvancedCustomDrawEvent);
begin
  InnerListView.OnAdvancedCustomDraw := Value;
end;

function TcxCustomListView.GetOnAdvancedCustomDrawItem: TLVAdvancedCustomDrawItemEvent;
begin
  Result := InnerListView.OnAdvancedCustomDrawItem;
end;

procedure TcxCustomListView.SetOnAdvancedCustomDrawItem(Value: TLVAdvancedCustomDrawItemEvent);
begin
  InnerListView.OnAdvancedCustomDrawItem := Value;
end;

function TcxCustomListView.GetOnAdvancedCustomDrawSubItem: TLVAdvancedCustomDrawSubItemEvent;
begin
  Result := InnerListView.OnAdvancedCustomDrawSubItem;
end;

procedure TcxCustomListView.SetOnAdvancedCustomDrawSubItem(Value: TLVAdvancedCustomDrawSubItemEvent);
begin
  InnerListView.OnAdvancedCustomDrawSubItem := Value;
end;

function TcxCustomListView.GetOnChange: TLVChangeEvent;
begin
  Result := InnerListView.OnChange;
end;

procedure TcxCustomListView.SetOnChange(Value: TLVChangeEvent);
begin
  InnerListView.OnChange := Value;
end;

function TcxCustomListView.GetOnChanging: TLVChangingEvent;
begin
  Result := InnerListView.OnChanging;
end;

procedure TcxCustomListView.SetOnChanging(Value: TLVChangingEvent);
begin
  InnerListView.OnChanging := Value;
end;

function TcxCustomListView.GetOnColumnClick: TLVColumnClickEvent;
begin
  Result := InnerListView.OnColumnClick;
end;

procedure TcxCustomListView.SetOnColumnClick(Value: TLVColumnClickEvent);
begin
  InnerListView.OnColumnClick := Value;
end;

function TcxCustomListView.GetOnColumnDragged: TNotifyEvent;
begin
  Result := InnerListView.OnColumnDragged;
end;

procedure TcxCustomListView.SetOnColumnDragged(Value: TNotifyEvent);
begin
  InnerListView.OnColumnDragged := Value;
end;

function TcxCustomListView.GetOnColumnRightClick: TLVColumnRClickEvent;
begin
  Result := InnerListView.OnColumnRightClick;
end;

procedure TcxCustomListView.SetOnColumnRightClick(Value: TLVColumnRClickEvent);
begin
  InnerListView.OnColumnRightClick := Value;
end;

function TcxCustomListView.GetOnCompare: TLVCompareEvent;
begin
  Result := InnerListView.OnCompare;
end;

procedure TcxCustomListView.SetOnCompare(Value: TLVCompareEvent);
begin
  InnerListView.OnCompare := Value;
end;

function TcxCustomListView.GetOnCustomDraw: TLVCustomDrawEvent;
begin
  Result := InnerListView.OnCustomDraw;
end;

procedure TcxCustomListView.SetOnCustomDraw(Value: TLVCustomDrawEvent);
begin
  InnerListView.OnCustomDraw := Value;
end;

function TcxCustomListView.GetOnCustomDrawItem: TLVCustomDrawItemEvent;
begin
  Result := InnerListView.OnCustomDrawItem;
end;

procedure TcxCustomListView.SetOnCustomDrawItem(Value: TLVCustomDrawItemEvent);
begin
  InnerListView.OnCustomDrawItem := Value;
end;

function TcxCustomListView.GetOnCustomDrawSubItem: TLVCustomDrawSubItemEvent;
begin
  Result := InnerListView.OnCustomDrawSubItem;
end;

procedure TcxCustomListView.SetOnCustomDrawSubItem(Value: TLVCustomDrawSubItemEvent);
begin
  InnerListView.OnCustomDrawSubItem := Value;
end;

function TcxCustomListView.GetOnData: TLVOwnerDataEvent;
begin
  Result := InnerListView.OnData;
end;

procedure TcxCustomListView.SetOnData(Value: TLVOwnerDataEvent);
begin
  InnerListView.OnData := Value;
end;

function TcxCustomListView.GetOnDataFind: TLVOwnerDataFindEvent;
begin
  Result := InnerListView.OnDataFind;
end;

procedure TcxCustomListView.SetOnDataFind(Value: TLVOwnerDataFindEvent);
begin
  InnerListView.OnDataFind := Value;
end;

function TcxCustomListView.GetOnDataHint: TLVOwnerDataHintEvent;
begin
  Result := InnerListView.OnDataHint;
end;

procedure TcxCustomListView.SetOnDataHint(Value: TLVOwnerDataHintEvent);
begin
  InnerListView.OnDataHint := Value;
end;

function TcxCustomListView.GetOnDataStateChange: TLVOwnerDataStateChangeEvent;
begin
  Result := InnerListView.OnDataStateChange;
end;

procedure TcxCustomListView.SetOnDataStateChange(Value: TLVOwnerDataStateChangeEvent);
begin
  InnerListView.OnDataStateChange := Value;
end;

function TcxCustomListView.GetOnDeletion: TLVDeletedEvent;
begin
  Result := InnerListView.OnDeletion;
end;

procedure TcxCustomListView.SetOnDeletion(Value: TLVDeletedEvent);
begin
  InnerListView.OnDeletion := Value;
end;

function TcxCustomListView.GetOnDrawItem: TLVDrawItemEvent;
begin
  Result := InnerListView.OnDrawItem;
end;

procedure TcxCustomListView.SetOnDrawItem(Value: TLVDrawItemEvent);
begin
  InnerListView.OnDrawItem := Value;
end;

function TcxCustomListView.GetOnEdited: TLVEditedEvent;
begin
  Result := InnerListView.OnEdited;
end;

procedure TcxCustomListView.SetOnEdited(Value: TLVEditedEvent);
begin
  InnerListView.OnEdited := Value;
end;

function TcxCustomListView.GetOnEditing: TLVEditingEvent;
begin
  Result := InnerListView.OnEditing;
end;

procedure TcxCustomListView.SetOnEditing(Value: TLVEditingEvent);
begin
  InnerListView.OnEditing := Value;
end;

function TcxCustomListView.GetOnInfoTip: TLVInfoTipEvent;
begin
  Result := InnerListView.OnInfoTip;
end;

procedure TcxCustomListView.SetOnInfoTip(Value: TLVInfoTipEvent);
begin
  InnerListView.OnInfoTip := Value;
end;

function TcxCustomListView.GetOnInsert: TLVDeletedEvent;
begin
  Result := InnerListView.OnInsert;
end;

procedure TcxCustomListView.SetOnInsert(Value: TLVDeletedEvent);
begin
  InnerListView.OnInsert := Value;
end;

function TcxCustomListView.GetOnGetImageIndex: TLVNotifyEvent;
begin
  Result := InnerListView.OnGetImageIndex;
end;

procedure TcxCustomListView.SetOnGetImageIndex(Value: TLVNotifyEvent);
begin
  InnerListView.OnGetImageIndex := Value;
end;

function TcxCustomListView.GetOnGetSubItemImage: TLVSubItemImageEvent;
begin
  Result := InnerListView.OnGetSubItemImage;
end;

procedure TcxCustomListView.SetOnGetSubItemImage(Value: TLVSubItemImageEvent);
begin
  InnerListView.OnGetSubItemImage := Value;
end;

function TcxCustomListView.GetOnSelectItem: TLVSelectItemEvent;
begin
  Result := InnerListView.OnSelectItem;
end;

procedure TcxCustomListView.SetOnSelectItem(Value: TLVSelectItemEvent);
begin
  InnerListView.OnSelectItem := Value;
end;

function TcxCustomListView.GetShowColumnHeaders: Boolean;
begin
  Result := InnerListView.ShowColumnHeaders;
end;

function TcxCustomListView.GetShowWorkAreas: Boolean;
begin
  Result := InnerListView.ShowWorkAreas;
end;

procedure TcxCustomListView.SetShowWorkAreas(Value: Boolean);
begin
  InnerListView.ShowWorkAreas := Value;
end;

function TcxCustomListView.GetSmallImages: TCustomImageList;
begin
  Result := InnerListView.SmallImages;
end;

procedure TcxCustomListView.SetSmallImages(Value: TCustomImageList);
begin
  InnerListView.SmallImages := Value;
end;

function TcxCustomListView.GetSortType: TSortType;
begin
  Result := InnerListView.SortType;
end;

procedure TcxCustomListView.SetSortType(Value: TSortType);
begin
  InnerListView.SortType := Value;
end;

function TcxCustomListView.GetStateImages: TCustomImageList;
begin
  Result := InnerListView.StateImages;
end;

procedure TcxCustomListView.SetStateImages(Value: TCustomImageList);
begin
  InnerListView.StateImages := Value;
end;

function TcxCustomListView.GetViewStyle: TViewStyle;
begin
  Result := InnerListView.ViewStyle;
end;

{$IFDEF DELPHI6}
function TcxCustomListView.GetOnCreateItemClass: TLVCreateItemClassEvent;
begin
  Result := InnerListView.OnCreateItemClass;
end;

procedure TcxCustomListView.SetOnCreateItemClass(Value: TLVCreateItemClassEvent);
begin
  InnerListView.OnCreateItemClass := Value;
end;
{$ENDIF}

function TcxCustomListView.GetCheckBoxes: Boolean;
begin
  Result := InnerListView.Checkboxes;
end;

function TcxCustomListView.GetColumnFromIndex(Index: Integer): TListColumn;
begin
  Result := InnerListView.Column[Index];
end;

function TcxCustomListView.GetDropTarget: TListItem;
begin
  Result := InnerListView.DropTarget;
end;

function TcxCustomListView.GetFullDrag: Boolean;
begin
  Result := InnerListView.FullDrag;
end;

function TcxCustomListView.GetGridLines: Boolean;
begin
  Result := InnerListView.GridLines;
end;

function TcxCustomListView.GetHotTrack: Boolean;
begin
  Result := InnerListView.HotTrack;
end;

function TcxCustomListView.GetHotTrackStyles: TListHotTrackStyles;
begin
  Result := InnerListView.HotTrackStyles;
end;

function TcxCustomListView.GetItemFocused: TListItem;
begin
  Result := InnerListView.ItemFocused;
end;

function TcxCustomListView.GetRowSelect: Boolean;
begin
  Result := InnerListView.RowSelect;
end;

function TcxCustomListView.GetSelCount: Integer;
begin
  Result := InnerListView.SelCount;
end;

function TcxCustomListView.GetSelected: TListItem;
begin
  Result := InnerListView.Selected;
end;

function TcxCustomListView.GetTopItem: TListItem;
begin
  Result := InnerListView.TopItem;
end;

function TcxCustomListView.GetViewOrigin: TPoint;
begin
  Result := InnerListView.ViewOrigin;
end;

function TcxCustomListView.GetVisibleRowCount: Integer;
begin
  Result := InnerListView.VisibleRowCount;
end;

function TcxCustomListView.GetBoundingRect: TRect;
begin
  Result := InnerListView.BoundingRect;
end;

function TcxCustomListView.GetWorkAreas: TWorkAreas;
begin
  Result := InnerListView.WorkAreas;
end;

procedure TcxCustomListView.SetCheckboxes(Value: Boolean);
begin
  InnerListView.Checkboxes := value;
end;

procedure TcxCustomListView.SetDropTarget(Value: TListItem);
begin
  InnerListView.DropTarget := Value;
end;

procedure TcxCustomListView.SetFullDrag(Value: Boolean);
begin
  InnerListView.FullDrag := Value;
end;

procedure TcxCustomListView.SetGridLines(Value: Boolean);
begin
  InnerListView.GridLines := Value;
end;

procedure TcxCustomListView.SetHotTrack(Value: Boolean);
begin
  InnerListView.HotTrack := Value;
end;

procedure TcxCustomListView.SetHotTrackStyles(Value: TListHotTrackStyles);
begin
  InnerListView.HotTrackStyles := Value;
end;

procedure TcxCustomListView.SetItemFocused(Value: TListItem);
begin
  InnerListView.ItemFocused := Value;
end;

procedure TcxCustomListView.SetSelected(Value: TListItem);
begin
  InnerListView.Selected := Value;
end;

procedure TcxCustomListView.ArrangementChangeHandler(Sender: TObject);
begin
  if Assigned(InnerListView) then
    InnerListView.IconOptions.Arrangement := FIconOptions.Arrangement;
end;

procedure TcxCustomListView.AutoArrangeChangeHandler(Sender: TObject);
begin
  if Assigned(InnerListView) then
    InnerListView.IconOptions.AutoArrange := FIconOptions.AutoArrange;
end;

procedure TcxCustomListView.WrapTextChangeHandler(Sender: TObject);
begin
  if Assigned(InnerListView) then
    InnerListView.IconOptions.WrapText := FIconOptions.WrapText;
end;
{ TcxCustomListView }

end.
