
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

{$DEFINE USETCXSCROLLBAR}

unit cxTreeView;

{$I cxVer.inc}

interface

uses
  Windows, Classes, ComCtrls, CommCtrl, Controls, Forms, ImgList, Menus,
  Messages, StdCtrls, SysUtils, cxClasses, cxContainer, cxControls,
  cxExtEditConsts, cxGraphics, cxLookAndFeels, cxScrollBar;

type
  { TcxCustomInnerTreeView }

  TcxCustomTreeView = class;

  TcxCustomInnerTreeView = class(TTreeView, IUnknown,
    IcxContainerInnerControl)
  private
    FCanvas: TcxCanvas;
    FContainer: TcxCustomTreeView;
    FIsRedrawLocked: Boolean;
    FItemHeight: Integer;
    FLookAndFeel: TcxLookAndFeel;
    function GetControl: TWinControl;
    function GetControlContainer: TcxContainer;
    procedure HScrollHandler(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure SetItemHeight(Value: Integer);
    procedure SetLookAndFeel(Value: TcxLookAndFeel);
    procedure VScrollHandler(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
{$IFNDEF DELPHI6}
    function GetScrollWidth: Integer;
    procedure SetScrollWidth(const Value: Integer);
{$ENDIF}
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetRedraw(var Message: TWMSetRedraw); message WM_SETREDRAW;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure WMFontChange(var Message: TMessage); message WM_FONTCHANGE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
  protected
    procedure Click; override;
    procedure DblClick; override;
    procedure DestroyWindowHandle; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
       MousePos: TPoint): Boolean; override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseEnter(AControl: TControl); dynamic;
    procedure MouseLeave(AControl: TControl); dynamic;
    property Container: TcxCustomTreeView read FContainer;
    property LookAndFeel: TcxLookAndFeel read FLookAndFeel write SetLookAndFeel;
    procedure Expand(Node: TTreeNode); override;
    procedure Change(Node: TTreeNode); override;
    procedure Collapse(Node: TTreeNode); override;
    procedure UpdateItemHeight;
    property IsRedrawLocked: Boolean read FIsRedrawLocked;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DefaultHandler(var Message); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    property Canvas: TcxCanvas read FCanvas;
    property ItemHeight: Integer read FItemHeight write SetItemHeight default -1;
{$IFNDEF DELPHI6}
    property ScrollWidth: Integer read GetScrollWidth write SetScrollWidth default 0;
{$ENDIF}
  end;

  TcxCustomInnerTreeViewClass = class of TcxCustomInnerTreeView;

  { TcxCustomTreeView }

  TcxCustomTreeView = class(TcxContainer)
  private
    FTreeView: TcxCustomInnerTreeView;
    function GetAutoExpand: Boolean;
    function GetChangeDelay: Integer;
    function GetHideSelection: Boolean;
    function GetHotTrack: Boolean;
    function GetImages: TCustomImageList;
    function GetItemHeight: Integer;
    function GetTreeNodes: TTreeNodes;
    function GetIndent: Integer;
{$IFDEF DELPHI6}
    function GetMultiSelect: Boolean;
    function GetMultiSelectStyle: TMultiSelectStyle;
    function GetOnCreateNodeClass: TTVCreateNodeClassEvent;
    procedure SetMultiSelectStyle(Value: TMultiSelectStyle);
    procedure SetOnCreateNodeClass(Value: TTVCreateNodeClassEvent);
    function GetOnAddition: TTVExpandedEvent;
    function GetOnCancelEdit: TTVChangedEvent;
{$ENDIF}
    function GetReadOnly: Boolean;
    function GetRightClickSelect: Boolean;
    function GetRowSelect: Boolean;
    function GetShowButtons: Boolean;
    function GetShowLines: Boolean;
    function GetShowRoot: Boolean;
    function GetSortType: TSortType;
    function GetStateImages: TCustomImageList;
    function GetToolTips: Boolean;
    function GetTreeViewCanvas: TcxCanvas;
{$IFDEF DELPHI5}
    function GetOnAdvancedCustomDraw: TTVAdvancedCustomDrawEvent;
    function GetOnAdvancedCustomDrawItem: TTVAdvancedCustomDrawItemEvent;
{$ENDIF}
    function GetOnChange: TTVChangedEvent;
    function GetOnChanging: TTVChangingEvent;
    function GetOnCollapsed: TTVExpandedEvent;
    function GetOnCollapsing: TTVCollapsingEvent;
    function GetOnCompare: TTVCompareEvent;
    function GetOnCustomDraw: TTVCustomDrawEvent;
    function GetOnCustomDrawItem: TTVCustomDrawItemEvent;
    function GetOnDeletion: TTVExpandedEvent;
    function GetOnEditing: TTVEditingEvent;
    function GetOnEdited: TTVEditedEvent;
    function GetOnExpanding: TTVExpandingEvent;
    function GetOnExpanded: TTVExpandedEvent;
    function GetOnGetImageIndex: TTVExpandedEvent;
    function GetOnGetSelectedIndex: TTVExpandedEvent;
    function GetDropTarget: TTreeNode;
    function GetSelected: TTreeNode;
    function GetTopItem: TTreeNode;
{$IFDEF DELPHI6}
    function GetSelectionCount: Cardinal;
    function GetSelection(Index: Integer): TTreeNode;
    procedure SetMultiSelect(Value: Boolean);
{$ENDIF}
    procedure SetAutoExpand(Value: Boolean);
    procedure SetChangeDelay(Value: Integer);
    procedure SetHideSelection(Value: Boolean);
    procedure SetHotTrack(Value: Boolean);
    procedure SetImages(Value: TCustomImageList);
    procedure SetTreeNodes(Value: TTreeNodes);
    procedure SetIndent(Value: Integer);
    procedure SetItemHeight(Value: Integer);
    procedure SetRightClickSelect(Value: Boolean);
    procedure SetReadOnly(Value: Boolean);
    procedure SetRowSelect(Value: Boolean);
    procedure SetShowButtons(Value: Boolean);
    procedure SetShowLines(Value: Boolean);
    procedure SetShowRoot(Value: Boolean);
    procedure SetSortType(Value: TSortType);
    procedure SetStateImages(Value: TCustomImageList);
    procedure SetToolTips(Value: Boolean);
{$IFDEF DELPHI6}
    procedure SetOnAddition(Value: TTVExpandedEvent);
    procedure SetOnCancelEdit(Value: TTVChangedEvent);
{$ENDIF}
{$IFDEF DELPHI5}
    procedure SetOnAdvancedCustomDraw(Value: TTVAdvancedCustomDrawEvent);
    procedure SetOnAdvancedCustomDrawItem(Value: TTVAdvancedCustomDrawItemEvent);
{$ENDIF}
    procedure SetOnChange(Value: TTVChangedEvent);
    procedure SetOnChanging(Value: TTVChangingEvent);
    procedure SetOnCollapsed(Value: TTVExpandedEvent);
    procedure SetOnCollapsing(Value: TTVCollapsingEvent);
    procedure SetOnCompare(Value: TTVCompareEvent);
    procedure SetOnCustomDraw(Value: TTVCustomDrawEvent);
    procedure SetOnCustomDrawItem(Value: TTVCustomDrawItemEvent);
    procedure SetOnDeletion(Value: TTVExpandedEvent);
    procedure SetOnEditing(Value: TTVEditingEvent);
    procedure SetOnEdited(Value: TTVEditedEvent);
    procedure SetOnExpanding(Value: TTVExpandingEvent);
    procedure SetOnExpanded(Value: TTVExpandedEvent);
    procedure SetOnGetImageIndex(Value: TTVExpandedEvent);
    procedure SetOnGetSelectedIndex(Value: TTVExpandedEvent);
    procedure SetDropTarget(Value: TTreeNode);
    procedure SetSelected(Value: TTreeNode);
    procedure SetTopItem(Value: TTreeNode);
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
  protected
    { Protected declarations }
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure FontChanged; override;
    function IsReadOnly: Boolean; override;
    function NeedsScrollBars: Boolean; override;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); override;
    procedure SetSize; override;
    procedure WriteState(Writer: TWriter); override;

    function GetInnerTreeView: TcxCustomInnerTreeView; virtual;
    class function GetTreeViewClass: TcxCustomInnerTreeViewClass; virtual;
    procedure InternalInitTreeView; virtual;
    {TreeView}
    function CanChange(Node: TTreeNode): Boolean; virtual;
    function CanCollapse(Node: TTreeNode): Boolean; virtual;
    function CanEdit(Node: TTreeNode): Boolean; virtual;
    function CanExpand(Node: TTreeNode): Boolean; virtual;
    procedure Collapse(Node: TTreeNode);
    procedure Expand(Node: TTreeNode);
    //
    property AutoExpand: Boolean read GetAutoExpand write SetAutoExpand;
    property ChangeDelay: Integer read GetChangeDelay write SetChangeDelay default 0;
    property HideSelection: Boolean read GetHideSelection write SetHideSelection default True;
    property HotTrack: Boolean read GetHotTrack write SetHotTrack;
    property Images: TCustomImageList read GetImages write SetImages;
    property ItemHeight: Integer read GetItemHeight write SetItemHeight default -1;
    property Items: TTreeNodes read GetTreeNodes write SetTreeNodes;
    property Indent: Integer read GetIndent write SetIndent default 19;
{$IFDEF DELPHI6}
    property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect;
    property MultiSelectStyle: TMultiSelectStyle read GetMultiSelectStyle
      write SetMultiSelectStyle default [msControlSelect];
{$ENDIF}
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property RightClickSelect: Boolean read GetRightClickSelect write SetRightClickSelect;
    property RowSelect: Boolean read GetRowSelect write SetRowSelect;
    property ShowButtons: Boolean read GetShowButtons write SetShowButtons;
    property ShowLines: Boolean read GetShowLines write SetShowLines;
    property ShowRoot: Boolean read GetShowRoot write SetShowRoot;
    property SortType: TSortType read GetSortType write SetSortType;
    property StateImages: TCustomImageList read GetStateImages write SetStateImages;
    property ToolTips: Boolean read GetToolTips write SetToolTips;
{$IFDEF DELPHI6}
    property OnAddition: TTVExpandedEvent read GetOnAddition write SetOnAddition;
    property OnCancelEdit: TTVChangedEvent read GetOnCancelEdit write SetOnCancelEdit;
{$ENDIF}
{$IFDEF DELPHI5}
    property OnAdvancedCustomDraw: TTVAdvancedCustomDrawEvent read GetOnAdvancedCustomDraw write SetOnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem: TTVAdvancedCustomDrawItemEvent read GetOnAdvancedCustomDrawItem write SetOnAdvancedCustomDrawItem;
{$ENDIF}
    property OnChange: TTVChangedEvent read GetOnChange write SetOnChange;
    property OnChanging: TTVChangingEvent read GetOnChanging write SetOnChanging;
    property OnCollapsed: TTVExpandedEvent read GetOnCollapsed write SetOnCollapsed;
    property OnCollapsing: TTVCollapsingEvent read GetOnCollapsing write SetOnCollapsing;
    property OnCompare: TTVCompareEvent read GetOnCompare write SetOnCompare;
    property OnCustomDraw: TTVCustomDrawEvent read GetOnCustomDraw write SetOnCustomDraw;
    property OnCustomDrawItem: TTVCustomDrawItemEvent read GetOnCustomDrawItem write SetOnCustomDrawItem;
    property OnDeletion: TTVExpandedEvent read GetOnDeletion write SetOnDeletion;
    property OnEditing: TTVEditingEvent read GetOnEditing write SetOnEditing;
    property OnEdited: TTVEditedEvent read GetOnEdited write SetOnEdited;
    property OnExpanding: TTVExpandingEvent read GetOnExpanding write SetOnExpanding;
    property OnExpanded: TTVExpandedEvent read GetOnExpanded write SetOnExpanded;
    property OnGetImageIndex: TTVExpandedEvent read GetOnGetImageIndex write SetOnGetImageIndex;
    property OnGetSelectedIndex: TTVExpandedEvent read GetOnGetSelectedIndex write SetOnGetSelectedIndex;
{$IFDEF DELPHI6}
    property OnCreateNodeClass: TTVCreateNodeClassEvent read GetOnCreateNodeClass write SetOnCreateNodeClass;
{$ENDIF}
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AlphaSort{$IFDEF DELPHI6}(
      ARecurse: Boolean = True){$ENDIF}: Boolean;
    function CustomSort(SortProc: TTVCompare; Data: Longint{$IFDEF DELPHI6};
      ARecurse: Boolean = True{$ENDIF}): Boolean;
    procedure FullCollapse;
    procedure FullExpand;
    function GetHitTestInfoAt(X, Y: Integer): THitTests;
    function GetNodeAt(X, Y: Integer): TTreeNode;
    function IsEditing: Boolean;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SetScrollBarsParameters(AIsScrolling: Boolean = False); override;
    property DropTarget: TTreeNode read GetDropTarget write SetDropTarget;
    property Selected: TTreeNode read GetSelected write SetSelected;
    property TopItem: TTreeNode read GetTopItem write SetTopItem;
    property TreeViewCanvas: TcxCanvas read GetTreeViewCanvas;
{$IFDEF DELPHI6}
    procedure Select(Node: TTreeNode; ShiftState: TShiftState = []); overload; virtual;
    procedure Select(const Nodes: array of TTreeNode); overload; virtual;
    procedure Select(Nodes: TList); overload; virtual;
    procedure Deselect(Node: TTreeNode); virtual;
    procedure Subselect(Node: TTreeNode; Validate: Boolean = False); virtual;
    property SelectionCount: Cardinal read GetSelectionCount;
    property Selections[Index: Integer]: TTreeNode read GetSelection;
    procedure ClearSelection(KeepPrimary: Boolean = False); virtual;
    function GetSelections(AList: TList): TTreeNode;
    function FindNextToSelect: TTreeNode; virtual;
{$ENDIF}
    property InnerTreeView: TcxCustomInnerTreeView read GetInnerTreeView;
  end;

  { TcxTreeView }
  
  TcxTreeView = class(TcxCustomTreeView)
  public
    property TreeViewCanvas;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Height default 100;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Visible;
    property Width default 120;
    property OnClick;
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
    property OnStartDock;
    property OnStartDrag;
{$IFDEF DELPHI5}
    property OnContextPopup;
{$ENDIF}
    property AutoExpand default False;
    property ChangeDelay default 0;
    property HideSelection default True;
    property HotTrack default False;
    property Images;
    property ItemHeight;
    property Items;
    property Indent;
{$IFDEF DELPHI6}
    property MultiSelect default False;
    property MultiSelectStyle;
{$ENDIF}
    property ReadOnly;
    property RightClickSelect default False;
    property RowSelect default False;
    property ShowButtons default True;
    property ShowLines default True;
    property ShowRoot default True;
    property SortType default stNone;
    property StateImages;
    property ToolTips default True;
{$IFDEF DELPHI6}
    property OnAddition;
    property OnCancelEdit;
{$ENDIF}
{$IFDEF DELPHI5}
    property OnAdvancedCustomDraw;
    property OnAdvancedCustomDrawItem;
{$ENDIF}    
    property OnChange;
    property OnChanging;
    property OnCollapsed;
    property OnCollapsing;
    property OnCompare;
    property OnCustomDraw;
    property OnCustomDrawItem;
    property OnDeletion;
    property OnEditing;
    property OnEdited;
    property OnExpanding;
    property OnExpanded;
    property OnGetImageIndex;
    property OnGetSelectedIndex;
{$IFDEF DELPHI6}
    property OnCreateNodeClass;
{$ENDIF}
  end;

implementation

uses
  Graphics;

{ TcxCustomInnerTreeView }

constructor TcxCustomInnerTreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCanvas := TcxCanvas.Create(inherited Canvas);
  FItemHeight := -1;
  FLookAndFeel := TcxLookAndFeel.Create(Self);
  BorderStyle := bsNone;
  ControlStyle := ControlStyle + [csDoubleClicks];
  ParentColor := False;
  ParentFont := True;
end;

destructor TcxCustomInnerTreeView.Destroy;
begin
  FreeAndNil(FLookAndFeel);
  FreeAndNil(FCanvas);
  inherited Destroy;
end;

procedure TcxCustomInnerTreeView.DefaultHandler(var Message);
begin
  if (Container = nil) or
    not Container.InnerControlDefaultHandler(TMessage(Message)) then
      inherited DefaultHandler(Message);
end;

procedure TcxCustomInnerTreeView.DragDrop(Source: TObject; X, Y: Integer);
begin
  if Container <> nil then
    Container.DragDrop(Source, Left + X, Top + Y);
end;

procedure TcxCustomInnerTreeView.Click;
begin
  inherited Click;
  if Container <> nil then
    _TcxContainerAccess.Click(Container);
end;

procedure TcxCustomInnerTreeView.DblClick;
begin
  inherited DblClick;
  if Container <> nil then
    _TcxContainerAccess.DblClick(Container);
end;

procedure TcxCustomInnerTreeView.DestroyWindowHandle;
begin
  FIsRedrawLocked := False;
  inherited DestroyWindowHandle;
end;

function TcxCustomInnerTreeView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
   MousePos: TPoint): Boolean;
begin
  Result := (Container <> nil) and
    _TcxContainerAccess.DoMouseWheel(Container, Shift, WheelDelta, MousePos);
  if not Result then
    inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

procedure TcxCustomInnerTreeView.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Container <> nil then
    _TcxContainerAccess.DragOver(Container, Source, Left + X, Top + Y, State, Accept);
end;

procedure TcxCustomInnerTreeView.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Container <> nil then
    _TcxContainerAccess.KeyDown(Container, Key, Shift);
  if Key <> 0 then
    inherited KeyDown(Key, Shift);
end;

procedure TcxCustomInnerTreeView.KeyPress(var Key: Char);
begin
  if (Key = Char(VK_TAB)) then
    Key := #0;
  if Container <> nil then
    _TcxContainerAccess.KeyPress(Container, Key);
  if Word(Key) = VK_RETURN then
    Key := #0;
  if Key <> #0 then
    inherited KeyPress(Key);
end;

procedure TcxCustomInnerTreeView.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_TAB) then
    Key := 0;
  if Container <> nil then
    _TcxContainerAccess.KeyUp(Container, Key, Shift);
  if Key <> 0 then
    inherited KeyUp(Key, Shift);
end;

procedure TcxCustomInnerTreeView.MouseDown(Button: TMouseButton;
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

procedure TcxCustomInnerTreeView.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if Container <> nil then
    _TcxContainerAccess.MouseMove(Container, Shift, X + Left, Y + Top);
end;

procedure TcxCustomInnerTreeView.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Container <> nil then
    _TcxContainerAccess.MouseUp(Container, Button, Shift, X + Left, Y + Top);
end;

procedure TcxCustomInnerTreeView.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited CreateWindowHandle(Params);
  UpdateItemHeight;
  Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerTreeView.WndProc(var Message: TMessage);
begin
  if (Container <> nil) and Container.InnerControlMenuHandler(Message) then
    Exit;

  if Message.Msg = WM_RBUTTONUP then
  begin
    Container.LockPopupMenu(True);
    try
      inherited WndProc(Message);
    finally
      Container.LockPopupMenu(False);
    end;
    Exit;
  end;

  if ((Message.Msg = WM_LBUTTONDOWN) or (Message.Msg = WM_LBUTTONDBLCLK)) and
    (Container.DragMode = dmAutomatic) and (Container.DragKind = dkDock) and
    not Container.IsDesigning then
  begin
    _TcxContainerAccess.BeginAutoDrag(Container);
    Exit;
  end;

  inherited WndProc(Message);
  case Message.Msg of
    WM_HSCROLL,
    WM_MOUSEWHEEL,
    WM_VSCROLL,
    CM_WININICHANGE,
    TVM_ENSUREVISIBLE,
    TVM_EXPAND,
    TVM_INSERTITEM,
    TVM_SELECTITEM:
      Container.SetScrollBarsParameters;
  end;
end;

procedure TcxCustomInnerTreeView.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  inherited;
  if not Container.ScrollBarsCalculating then
    Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerTreeView.WMFontChange(var Message: TMessage);
begin
  inherited;
  if not Container.ScrollBarsCalculating then
    Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerTreeView.WMLButtonDown(var Message: TWMLButtonDown);
begin
  inherited;
  if Dragging then
  begin
    CancelDrag;
    Container.BeginDrag(False);
  end;
end;

procedure TcxCustomInnerTreeView.MouseEnter(AControl: TControl);
begin
end;

procedure TcxCustomInnerTreeView.MouseLeave(AControl: TControl);
begin
  if Container <> nil then
    Container.ShortRefreshContainer(True);
end;

function TcxCustomInnerTreeView.GetControl: TWinControl;
begin
  Result := Self;
end;

function TcxCustomInnerTreeView.GetControlContainer: TcxContainer;
begin
  Result := FContainer;
end;

procedure TcxCustomInnerTreeView.HScrollHandler(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  CallWindowProc(DefWndProc, Handle, WM_HSCROLL, Word(ScrollCode) +
    Word(ScrollPos) shl 16, Container.HScrollBar.Handle);
  ScrollPos := GetScrollPos(Handle, SB_HORZ);
end;

procedure TcxCustomInnerTreeView.SetItemHeight(Value: Integer);
begin
  if Value <> FItemHeight then
  begin
    FItemHeight := Value;
    UpdateItemHeight;
  end;
end;

procedure TcxCustomInnerTreeView.SetLookAndFeel(Value: TcxLookAndFeel);
begin
  FLookAndFeel.Assign(Value);
end;

procedure TcxCustomInnerTreeView.VScrollHandler(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
var
  AScrollInfo: TScrollInfo;
begin
  if (ScrollCode in [scPosition, scTrack]) and (Win32MajorVersion >= 6) then
  begin
    AScrollInfo.cbSize := SizeOf(AScrollInfo);
    AScrollInfo.fMask := SIF_POS;
    AScrollInfo.nPos := ScrollPos;
    SetScrollInfo(Handle, SB_VERT, AScrollInfo, True);
  end;
  CallWindowProc(DefWndProc, Handle, WM_VSCROLL, Word(ScrollCode) +
    Word(ScrollPos) shl 16, Container.VScrollBar.Handle);
  ScrollPos := GetScrollPos(Handle, SB_VERT);
end;

{$IFNDEF DELPHI6}
function TcxCustomInnerTreeView.GetScrollWidth: Integer;
begin
  Result := SendMessage(Handle, LB_GETHORIZONTALEXTENT, 0, 0);
end;

procedure TcxCustomInnerTreeView.SetScrollWidth(const Value: Integer);
begin
  if Value <> ScrollWidth then
    SendMessage(Handle, LB_SETHORIZONTALEXTENT, Value, 0);
end;
{$ENDIF}

procedure TcxCustomInnerTreeView.WMGetDlgCode(var Message: TWMGetDlgCode);
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

procedure TcxCustomInnerTreeView.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if (Container <> nil) and not Container.IsDestroying then
    Container.FocusChanged;
end;

procedure TcxCustomInnerTreeView.WMNCPaint(var Message: TWMNCPaint);
var
  DC: HDC;
  ABrush: HBRUSH;
begin
  if UsecxScrollBars and Container.HScrollBar.Visible and
    Container.VScrollBar.Visible then
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
  if UsecxScrollBars then
  begin
    if Container.HScrollBar.Visible then
      Container.HScrollBar.Repaint;
    if Container.VScrollBar.Visible then
      Container.VScrollBar.Repaint;
  end;
end;

procedure TcxCustomInnerTreeView.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if (Container <> nil) and not Container.IsDestroying and
    not(csDestroying in ComponentState) and
    (Message.FocusedWnd <> Container.Handle) then
      Container.FocusChanged;
end;

procedure TcxCustomInnerTreeView.WMSetRedraw(var Message: TWMSetRedraw);
begin
  inherited;
  FIsRedrawLocked := Message.Redraw = 0;
  if not (csDestroying in ComponentState) and not FIsRedrawLocked then
    Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerTreeView.WMWindowPosChanged(
  var Message: TWMWindowPosChanged);
var
  ARgn: HRGN;
begin
  inherited;
  if csDestroying in ComponentState then
    Exit;
  Container.SetScrollBarsParameters;
  if Container.HScrollBar.Visible and Container.VScrollBar.Visible then
  begin
    ARgn := CreateRectRgnIndirect(GetSizeGripRect(Self));
    SendMessage(Handle, WM_NCPAINT, ARgn, 0);
    DeleteObject(ARgn);
  end;
end;

procedure TcxCustomInnerTreeView.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseEnter(Self)
  else
    MouseEnter(TControl(Message.lParam));
end;

procedure TcxCustomInnerTreeView.CNNotify(
  var Message: TWMNotify);
begin
  inherited;
  if Message.NMHdr.code = TVN_DELETEITEM then
    Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerTreeView.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseLeave(Self)
  else
    MouseLeave(TControl(Message.lParam));
end;

procedure TcxCustomInnerTreeView.Expand(Node: TTreeNode);
begin
  inherited;
  Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerTreeView.Change(Node: TTreeNode);
begin
  inherited;
  Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerTreeView.Collapse(Node: TTreeNode);
begin
  inherited;
  Container.SetScrollBarsParameters;
end;

procedure TcxCustomInnerTreeView.UpdateItemHeight;
begin
  if HandleAllocated then
    TreeView_SetItemHeight(Handle, ItemHeight);
end;

{ TcxCustomTreeView }

constructor TcxCustomTreeView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InternalInitTreeView;
  InnerTreeView.AutoSize := False;
  InnerTreeView.Align := alClient;
  InnerTreeView.BorderStyle := bsNone;
  InnerTreeView.Parent := Self;
  InnerTreeView.FContainer := Self;
  InnerControl := InnerTreeView;
  InnerTreeView.LookAndFeel.MasterLookAndFeel := Style.LookAndFeel;
  Width := 120;
  Height := 100;
end;

destructor TcxCustomTreeView.Destroy;
begin
  FreeAndNil(FTreeView);
  inherited Destroy;
end;

function TcxCustomTreeView.GetInnerTreeView: TcxCustomInnerTreeView;
begin
  Result := FTreeView;
end;

procedure TcxCustomTreeView.InternalInitTreeView;
begin
  FTreeView := GetTreeViewClass.Create(Self);
end;

class function TcxCustomTreeView.GetTreeViewClass: TcxCustomInnerTreeViewClass;
begin
  Result := TcxCustomInnerTreeView;
end;

function TcxCustomTreeView.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := True;
  if not Result or IsLoading then Exit;
  if Align in [alLeft, alRight, alClient] then Exit;
end;

procedure TcxCustomTreeView.FontChanged;
begin
  inherited FontChanged;
  SetSize;
  InnerTreeView.Invalidate;
end;

function TcxCustomTreeView.IsReadOnly: Boolean;
begin
  Result := ReadOnly;
end;

function TcxCustomTreeView.NeedsScrollBars: Boolean;
begin
  Result := True;
end;

procedure TcxCustomTreeView.Scroll(AScrollBarKind: TScrollBarKind;
  AScrollCode: TScrollCode; var AScrollPos: Integer);
begin
  inherited Scroll(AScrollBarKind, AScrollCode, AScrollPos);
{$IFDEF USETCXSCROLLBAR}
  if AScrollBarKind = sbHorizontal then
    InnerTreeView.HScrollHandler(Self, AScrollCode, AScrollPos)
  else
    InnerTreeView.VScrollHandler(Self, AScrollCode, AScrollPos);
  SetScrollBarsParameters;
{$ENDIF}
end;

procedure TcxCustomTreeView.SetSize;
var
  APrevBoundsRect: TRect;
begin
  if IsLoading then
    Exit;
  APrevBoundsRect := InnerTreeView.BoundsRect;
  inherited SetSize;
  if not EqualRect(APrevBoundsRect, InnerTreeView.BoundsRect) and
    InnerTreeView.HandleAllocated then
      KillMessages(InnerTreeView.Handle, WM_MOUSEMOVE, WM_MOUSEMOVE);
end;

procedure TcxCustomTreeView.WriteState(Writer: TWriter);
begin
  FTreeView.HandleNeeded;
  inherited;  
end;

procedure TcxCustomTreeView.CNNotify(var Message: TWMNotify);
begin
  if InnerTreeView <> nil then
  begin
    InnerTreeView.CNNotify(Message);
    Exit;
  end;
  inherited;
end;

function TcxCustomTreeView.AlphaSort{$IFDEF DELPHI6}(
  ARecurse: Boolean = True){$ENDIF}: Boolean;
begin
  Result := InnerTreeView.AlphaSort({$IFDEF DELPHI6}ARecurse{$ENDIF});
end;

function TcxCustomTreeView.CustomSort(SortProc: TTVCompare;
  Data: Longint{$IFDEF DELPHI6}; ARecurse: Boolean = True{$ENDIF}): Boolean;
begin
  Result := InnerTreeView.CustomSort(SortProc, Data{$IFDEF DELPHI6},
    ARecurse{$ENDIF});
end;

procedure TcxCustomTreeView.FullCollapse;
begin
  InnerTreeView.FullCollapse;
end;

procedure TcxCustomTreeView.FullExpand;
begin
  InnerTreeView.FullExpand;
end;

function TcxCustomTreeView.GetHitTestInfoAt(X, Y: Integer): THitTests;
begin
  Result := InnerTreeView.GetHitTestInfoAt(X - InnerTreeView.Left,
    Y - InnerTreeView.Top);
end;

function TcxCustomTreeView.GetNodeAt(X, Y: Integer): TTreeNode;
begin
  Result := InnerTreeView.GetNodeAt(X - InnerTreeView.Left, Y - InnerTreeView.Top);
end;

function TcxCustomTreeView.IsEditing: Boolean;
begin
  Result := InnerTreeView.IsEditing;
end;

procedure TcxCustomTreeView.LoadFromFile(const FileName: string);
begin
  InnerTreeView.LoadFromFile(FileName);
end;

procedure TcxCustomTreeView.LoadFromStream(Stream: TStream);
begin
  InnerTreeView.LoadFromStream(Stream);
end;

procedure TcxCustomTreeView.SaveToFile(const FileName: string);
begin
  InnerTreeView.SaveToFile(FileName);
end;

procedure TcxCustomTreeView.SaveToStream(Stream: TStream);
begin
  InnerTreeView.SaveToStream(Stream);
end;

procedure TcxCustomTreeView.SetScrollBarsParameters(AIsScrolling: Boolean = False);
begin
  if (InnerTreeView <> nil) and not InnerTreeView.IsRedrawLocked then
    inherited SetScrollBarsParameters(AIsScrolling);
end;

{$IFDEF DELPHI6}
procedure TcxCustomTreeView.Select(Node: TTreeNode; ShiftState: TShiftState = []);
begin
  InnerTreeView.Select(Node, ShiftState);
end;

procedure TcxCustomTreeView.Select(const Nodes: array of TTreeNode);
begin
  InnerTreeView.Select(Nodes);
end;

procedure TcxCustomTreeView.Select(Nodes: TList);
begin
  InnerTreeView.Select(Nodes);
end;

procedure TcxCustomTreeView.Deselect(Node: TTreeNode);
begin
  InnerTreeView.Deselect(Node);
end;

procedure TcxCustomTreeView.Subselect(Node: TTreeNode; Validate: Boolean = False);
begin
  InnerTreeView.Subselect(Node, Validate);
end;

procedure TcxCustomTreeView.ClearSelection(KeepPrimary: Boolean = False);
begin
  InnerTreeView.ClearSelection(KeepPrimary);
end;

function TcxCustomTreeView.GetSelections(AList: TList): TTreeNode;
begin
  Result := InnerTreeView.GetSelections(AList);
end;

function TcxCustomTreeView.FindNextToSelect: TTreeNode;
begin
  Result := InnerTreeView.FindNextToSelect;
end;
{$ENDIF}

function TcxCustomTreeView.GetAutoExpand: Boolean;
begin
  Result := InnerTreeView.AutoExpand;
end;

function TcxCustomTreeView.GetChangeDelay: Integer;
begin
  Result := InnerTreeView.ChangeDelay;
end;

function TcxCustomTreeView.GetHideSelection: Boolean;
begin
  Result := InnerTreeView.HideSelection;
end;

function TcxCustomTreeView.GetHotTrack: Boolean;
begin
  Result := InnerTreeView.HotTrack;
end;

function TcxCustomTreeView.GetImages: TCustomImageList;
begin
  Result := InnerTreeView.Images;
end;

function TcxCustomTreeView.GetItemHeight: Integer;
begin
  Result := InnerTreeView.ItemHeight;
end;

function TcxCustomTreeView.GetTreeNodes: TTreeNodes;
begin
  Result := InnerTreeView.Items;
end;

function TcxCustomTreeView.GetIndent: Integer;
begin
  Result := InnerTreeView.Indent;
end;

{$IFDEF DELPHI6}
function TcxCustomTreeView.GetMultiSelect: Boolean;
begin
  Result := InnerTreeView.MultiSelect;
end;

function TcxCustomTreeView.GetMultiSelectStyle: TMultiSelectStyle;
begin
  Result := InnerTreeView.MultiSelectStyle;
end;
{$ENDIF}

function TcxCustomTreeView.GetReadOnly: Boolean;
begin
  Result := InnerTreeView.ReadOnly;
end;

function TcxCustomTreeView.GetRightClickSelect: Boolean;
begin
  Result := InnerTreeView.RightClickSelect;
end;

function TcxCustomTreeView.GetRowSelect: Boolean;
begin
  Result := InnerTreeView.RowSelect;
end;

function TcxCustomTreeView.GetShowButtons: Boolean;
begin
  Result := InnerTreeView.ShowButtons;
end;

function TcxCustomTreeView.GetShowLines: Boolean;
begin
  Result := InnerTreeView.ShowLines;
end;

function TcxCustomTreeView.GetShowRoot: Boolean;
begin
  Result := InnerTreeView.ShowRoot;
end;

function TcxCustomTreeView.GetSortType: TSortType;
begin
  Result := InnerTreeView.SortType;
end;

function TcxCustomTreeView.GetStateImages: TCustomImageList;
begin
  Result := InnerTreeView.StateImages;
end;

function TcxCustomTreeView.GetToolTips: Boolean;
begin
  Result := InnerTreeView.ToolTips;
end;

function TcxCustomTreeView.GetTreeViewCanvas: TcxCanvas;
begin
  Result := InnerTreeView.Canvas;
end;

{$IFDEF DELPHI6}
function TcxCustomTreeView.GetOnAddition: TTVExpandedEvent;
begin
  Result := InnerTreeView.OnAddition;
end;
{$ENDIF}

{$IFDEF DELPHI5}
function TcxCustomTreeView.GetOnAdvancedCustomDraw: TTVAdvancedCustomDrawEvent;
begin
  Result := InnerTreeView.OnAdvancedCustomDraw;
end;

function TcxCustomTreeView.GetOnAdvancedCustomDrawItem: TTVAdvancedCustomDrawItemEvent;
begin
  Result := InnerTreeView.OnAdvancedCustomDrawItem;
end;
{$ENDIF}

{$IFDEF DELPHI6}
function TcxCustomTreeView.GetOnCancelEdit: TTVChangedEvent;
begin
  Result := InnerTreeView.OnCancelEdit;
end;
{$ENDIF}

function TcxCustomTreeView.GetOnChange: TTVChangedEvent;
begin
  Result := InnerTreeView.OnChange;
end;

function TcxCustomTreeView.GetOnChanging: TTVChangingEvent;
begin
  Result := InnerTreeView.OnChanging;
end;

function TcxCustomTreeView.GetOnCollapsed: TTVExpandedEvent;
begin
  Result := InnerTreeView.OnCollapsed;
end;

function TcxCustomTreeView.GetOnCollapsing: TTVCollapsingEvent;
begin
  Result := InnerTreeView.OnCollapsing;
end;

function TcxCustomTreeView.GetOnCompare: TTVCompareEvent;
begin
  Result := InnerTreeView.OnCompare;
end;

function TcxCustomTreeView.GetOnCustomDraw: TTVCustomDrawEvent;
begin
  Result := InnerTreeView.OnCustomDraw;
end;

function TcxCustomTreeView.GetOnCustomDrawItem: TTVCustomDrawItemEvent;
begin
  Result := InnerTreeView.OnCustomDrawItem;
end;

function TcxCustomTreeView.GetOnDeletion: TTVExpandedEvent;
begin
  Result := InnerTreeView.OnDeletion;
end;

function TcxCustomTreeView.GetOnEditing: TTVEditingEvent;
begin
  Result := InnerTreeView.OnEditing;
end;

function TcxCustomTreeView.GetOnEdited: TTVEditedEvent;
begin
  Result := InnerTreeView.OnEdited;
end;

function TcxCustomTreeView.GetOnExpanding: TTVExpandingEvent;
begin
  Result := InnerTreeView.OnExpanding;
end;

function TcxCustomTreeView.GetOnExpanded: TTVExpandedEvent;
begin
  Result := InnerTreeView.OnExpanded;
end;

function TcxCustomTreeView.GetOnGetImageIndex: TTVExpandedEvent;
begin
  Result := InnerTreeView.OnGetImageIndex;
end;

function TcxCustomTreeView.GetOnGetSelectedIndex: TTVExpandedEvent;
begin
  Result := InnerTreeView.OnGetSelectedIndex;
end;

{$IFDEF DELPHI6}
function TcxCustomTreeView.GetOnCreateNodeClass: TTVCreateNodeClassEvent;
begin
  Result := InnerTreeView.OnCreateNodeClass;
end;
{$ENDIF}

function TcxCustomTreeView.GetDropTarget: TTreeNode;
begin
  Result := InnerTreeView.DropTarget;
end;

function TcxCustomTreeView.GetSelected: TTreeNode;
begin
  Result := InnerTreeView.Selected;
end;

function TcxCustomTreeView.GetTopItem: TTreeNode;
begin
  Result := InnerTreeView.TopItem;
end;

{$IFDEF DELPHI6}
function TcxCustomTreeView.GetSelectionCount: Cardinal;
begin
  Result := InnerTreeView.SelectionCount;
end;

function TcxCustomTreeView.GetSelection(Index: Integer): TTreeNode;
begin
  Result := InnerTreeView.Selections[Index];
end;
{$ENDIF}

procedure TcxCustomTreeView.SetAutoExpand(Value: Boolean);
begin
  InnerTreeView.AutoExpand := Value;
end;

procedure TcxCustomTreeView.SetChangeDelay(Value: Integer);
begin
  InnerTreeView.ChangeDelay := Value;
end;

procedure TcxCustomTreeView.SetHideSelection(Value: Boolean);
begin
  InnerTreeView.HideSelection := Value;
end;

procedure TcxCustomTreeView.SetHotTrack(Value: Boolean);
begin
  InnerTreeView.HotTrack := Value;
end;

procedure TcxCustomTreeView.SetImages(Value: TCustomImageList);
begin
  InnerTreeView.Images := Value;
end;

procedure TcxCustomTreeView.SetTreeNodes(Value: TTreeNodes);
begin
  InnerTreeView.Items := Value;
end;

procedure TcxCustomTreeView.SetIndent(Value: Integer);
begin
  InnerTreeView.Indent := Value;
end;

procedure TcxCustomTreeView.SetItemHeight(Value: Integer);
begin
  InnerTreeView.ItemHeight := Value;
end;

{$IFDEF DELPHI6}
procedure TcxCustomTreeView.SetMultiSelect(Value: Boolean);
begin
  InnerTreeView.MultiSelect := Value;
end;

procedure TcxCustomTreeView.SetMultiSelectStyle(Value: TMultiSelectStyle);
begin
  InnerTreeView.MultiSelectStyle := Value;
end;
{$ENDIF}

procedure TcxCustomTreeView.SetRightClickSelect(Value: Boolean);
begin
  InnerTreeView.RightClickSelect := Value;
end;

procedure TcxCustomTreeView.SetReadOnly(Value: Boolean);
begin
  if Value <> ReadOnly then
  begin
    InnerTreeView.ReadOnly := Value;
    DataSetChange;
  end;
end;

procedure TcxCustomTreeView.SetRowSelect(Value: Boolean);
begin
  InnerTreeView.RowSelect := Value;
end;

procedure TcxCustomTreeView.SetShowButtons(Value: Boolean);
begin
  InnerTreeView.ShowButtons := Value;
end;

procedure TcxCustomTreeView.SetShowLines(Value: Boolean);
begin
  InnerTreeView.ShowLines := Value;
end;

procedure TcxCustomTreeView.SetShowRoot(Value: Boolean);
begin
  InnerTreeView.ShowRoot := Value;
end;

procedure TcxCustomTreeView.SetSortType(Value: TSortType);
begin
  InnerTreeView.SortType := Value;
end;

procedure TcxCustomTreeView.SetStateImages(Value: TCustomImageList);
begin
  InnerTreeView.StateImages := Value;
end;

procedure TcxCustomTreeView.SetToolTips(Value: Boolean);
begin
  InnerTreeView.ToolTips := Value;
end;

{$IFDEF DELPHI6}
procedure TcxCustomTreeView.SetOnAddition(Value: TTVExpandedEvent);
begin
  InnerTreeView.OnAddition := Value;
end;
{$ENDIF}

{$IFDEF DELPHI5}
procedure TcxCustomTreeView.SetOnAdvancedCustomDraw(Value: TTVAdvancedCustomDrawEvent);
begin
  InnerTreeView.OnAdvancedCustomDraw := Value;
end;

procedure TcxCustomTreeView.SetOnAdvancedCustomDrawItem(Value: TTVAdvancedCustomDrawItemEvent);
begin
  InnerTreeView.OnAdvancedCustomDrawItem := Value;
end;
{$ENDIF}

{$IFDEF DELPHI6}
procedure TcxCustomTreeView.SetOnCancelEdit(Value: TTVChangedEvent);
begin
  InnerTreeView.OnCancelEdit := Value;
end;
{$ENDIF}

procedure TcxCustomTreeView.SetOnChange(Value: TTVChangedEvent);
begin
  InnerTreeView.OnChange := Value;
end;

procedure TcxCustomTreeView.SetOnChanging(Value: TTVChangingEvent);
begin
  InnerTreeView.OnChanging := Value;
end;

procedure TcxCustomTreeView.SetOnCollapsed(Value: TTVExpandedEvent);
begin
  InnerTreeView.OnCollapsed := Value;
end;

procedure TcxCustomTreeView.SetOnCollapsing(Value: TTVCollapsingEvent);
begin
  InnerTreeView.OnCollapsing := Value;
end;

procedure TcxCustomTreeView.SetOnCompare(Value: TTVCompareEvent);
begin
  InnerTreeView.OnCompare := Value;
end;

procedure TcxCustomTreeView.SetOnCustomDraw(Value: TTVCustomDrawEvent);
begin
  InnerTreeView.OnCustomDraw := Value;
end;

procedure TcxCustomTreeView.SetOnCustomDrawItem(Value: TTVCustomDrawItemEvent);
begin
  InnerTreeView.OnCustomDrawItem := Value;
end;

procedure TcxCustomTreeView.SetOnDeletion(Value: TTVExpandedEvent);
begin
  InnerTreeView.OnDeletion := Value;
end;

procedure TcxCustomTreeView.SetOnEditing(Value: TTVEditingEvent);
begin
  InnerTreeView.OnEditing := Value;
end;

procedure TcxCustomTreeView.SetOnEdited(Value: TTVEditedEvent);
begin
  InnerTreeView.OnEdited := Value;
end;

procedure TcxCustomTreeView.SetOnExpanding(Value: TTVExpandingEvent);
begin
  InnerTreeView.OnExpanding := Value;
end;

procedure TcxCustomTreeView.SetOnExpanded(Value: TTVExpandedEvent);
begin
  InnerTreeView.OnExpanded := Value;
end;

procedure TcxCustomTreeView.SetOnGetImageIndex(Value: TTVExpandedEvent);
begin
  InnerTreeView.OnGetImageIndex := Value;
end;

procedure TcxCustomTreeView.SetOnGetSelectedIndex(Value: TTVExpandedEvent);
begin
  InnerTreeView.OnGetSelectedIndex := Value;
end;

{$IFDEF DELPHI6}
procedure TcxCustomTreeView.SetOnCreateNodeClass(Value: TTVCreateNodeClassEvent);
begin
  InnerTreeView.OnCreateNodeClass := Value;
end;
{$ENDIF}

procedure TcxCustomTreeView.SetDropTarget(Value: TTreeNode);
begin
  InnerTreeView.DropTarget := Value;
end;

procedure TcxCustomTreeView.SetSelected(Value: TTreeNode);
begin
  InnerTreeView.Selected := Value;
end;

procedure TcxCustomTreeView.SetTopItem(Value: TTreeNode);
begin
  InnerTreeView.TopItem := Value;
end;

function TcxCustomTreeView.CanEdit(Node: TTreeNode): Boolean;
begin
  Result := InnerTreeView.CanEdit(Node);
end;

function TcxCustomTreeView.CanChange(Node: TTreeNode): Boolean;
begin
  Result := InnerTreeView.CanChange(Node);
end;

function TcxCustomTreeView.CanCollapse(Node: TTreeNode): Boolean;
begin
  Result := InnerTreeView.CanCollapse(Node);
end;

function TcxCustomTreeView.CanExpand(Node: TTreeNode): Boolean;
begin
  Result := InnerTreeView.CanExpand(Node);
end;

procedure TcxCustomTreeView.Collapse(Node: TTreeNode);
begin
  InnerTreeView.Collapse(Node);
end;

procedure TcxCustomTreeView.Expand(Node: TTreeNode);
begin
  InnerTreeView.Expand(Node);
end;

end.
