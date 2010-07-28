
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

unit cxMCListBox;

{$I cxVer.inc}

interface

uses
  Windows, Classes, Controls, ExtCtrls, Forms, Graphics, ImgList, Messages,
  StdCtrls, SysUtils, cxClasses, cxContainer, cxControls, cxDataUtils, cxCustomData,
  cxEdit, cxExtEditConsts, cxExtEditUtils, cxGraphics, cxHeader, cxLookAndFeelPainters,
  cxLookAndFeels, cxScrollBar;

type
  TcxMCInnerHeader = class;
  TcxMCListBox = class;

  { TcxMCInnerHeader }

  TcxMCInnerHeader = class(TcxHeader, IUnknown,
    IcxContainerInnerControl)
  private
    FContainer: TcxContainer;
    function GetControlContainer: TcxContainer;
    function GetControl: TWinControl;
    function GetContainer: TcxMCListBox;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure AdjustSize; override;
    procedure Click; override;
//    procedure DoSectionEndResizeEvent(Section: TcxHeaderSection); override;
    function IsInnerControl: Boolean; override;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
//    procedure AdjustScrollWidth;
    procedure UpdateHeight;
    property Container: TcxMCListBox read GetContainer;
  public
    constructor Create(AOwner: TComponent); override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
  end;

  { TcxMCInnerListBox }

  TcxMCInnerListBox = class(TcxCustomInnerListBox)
  private
    FItems: TStrings;
    FVScrollBarVisible: Boolean;
    function GetContainer: TcxMCListBox;
    function IsVScrollBarVisible: Boolean;
    procedure ItemsChanged(Sender: TStrings; AStartIndex, AEndIndex: Integer);
    procedure SetContainer(Value: TcxMCListBox);
    procedure SetItems(Value: TStrings);
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    property Container: TcxMCListBox read GetContainer write SetContainer;
    procedure Click; override;
    procedure RecalcItemRects(AStartIndex: Integer = -1;
      AEndIndex: Integer = -1); virtual;
    procedure DrawLines; virtual;
    procedure FullRepaint; virtual;
    property VScrollBarVisible: Boolean read FVScrollBarVisible;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CanFocus: Boolean; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
  published
    property Items: TStrings read FItems write SetItems;
  end;

  { TcxMCInnerPanel }

  TcxMCInnerPanel = class(TcxControl)
  private
    function GetMCListBox: TcxMCListBox;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure AdjustChildsPosition;
    procedure BoundsChanged; override;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); override;
    procedure Paint; override;
    property MCListBox: TcxMCListBox read GetMCListBox;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  { TcxMCListBox }

  TcxMCListBox = class(TcxContainer)
  private
    FAlignment: TAlignment;
    FColumnLineColor: TColor;
    FDelimiter: Char;
    FInnerHeader: TcxMCInnerHeader;
    FInnerHeaderSectionRectsWithoutScrollbar: TcxHeaderSectionRects;
    FInnerHeaderSectionRectsWithScrollbar: TcxHeaderSectionRects;
    FInnerListBox:  TcxMCInnerListBox;
    FInnerPanel: TcxMCInnerPanel;
    FIntegralHeight: Boolean;
    FInternalFlagCreatedHeader: Boolean;
    FInternalPaint: Boolean;
    FIsExitProcessing: Boolean;
    FMultiLines: Boolean;
    FOverflowEmptyColumn: Boolean;
    FOverLoadList: TStringList;
    FSavedHScroll: TScrollEvent;
    FSavedIndex: Integer;
    FShowColumnLines: Boolean;
    FShowEndEllipsis: Boolean;
    FShowHeader: Boolean;
    function CalcCellTextRect(AApproximateRect: TRect; AItemIndex, AColumnIndex: Integer): TRect;
    procedure DrawCellTextEx(var ARect: TRect; AFlags, AItemIndex, AColumnIndex: Integer);
    procedure DrawCellText(ARect: TRect; AItemIndex, AColumnIndex: Integer);
    function GetCellRect(AItemIndex, AColumnIndex, ATop, ABottom: Integer;
      AVScrollBarVisible: Boolean): TRect;
    function GetCellTextRect(AItemIndex, AColumnIndex, ATop, ABottom: Integer;
      AVScrollBarVisible: Boolean): TRect;
    function GetDelimiter: Char;
    function GetImages: TCustomImageList;
    procedure SetImages(Value: TCustomImageList);
    function GetHeaderSectionRect(AIndex: Integer;
      AVScrollBarVisible: Boolean): TRect;
    function GetHeaderSections: TcxHeaderSections;
    procedure SetHeaderSections(Value: TcxHeaderSections);
    procedure SectionEndResizeHandler(HeaderControl: TcxCustomHeader;
      Section: TcxHeaderSection);
    procedure SectionTrackHandler(HeaderControl: TcxCustomHeader;
      Section: TcxHeaderSection; Width: Integer; State: TcxSectionTrackState);
    procedure SetMultiLines(Value: Boolean);
    procedure SetAlignment(Value: TAlignment);
    procedure SetShowEndEllipsis(Value: Boolean);
    procedure SetDelimiter(Value: Char);
    function GetHeaderDragReorder: Boolean;
    procedure SetHeaderDragReorder(Value: Boolean);
    procedure SetShowColumnLines(Value: Boolean);
    procedure SetShowHeader(Value: Boolean);
    procedure SetColumnLineColor(Value: TColor);
    procedure SetOverflowEmptyColumn(Value: Boolean);
    function GetTextPart(AItemIndex, AColumnIndex: Integer): string;
    procedure SectionsChangeHandler(Sender: TObject);
    procedure HScrollHandler(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure SectionEndDragHandler(Sender: TObject);
    procedure DrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure MeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
    function GetCount: Integer;
    function GetExtendedSelect: Boolean;
    function GetItemHeight: Integer;
    function GetItemIndex: Integer;
    function GetItems: TStrings;
    function GetMultiSelect: Boolean;
    function GetReadOnly: Boolean;
    function GetSelCount: Integer;
    function GetSelected(Index: Integer): Boolean;
    function GetSorted: Boolean;
    function GetTopIndex: Integer;
    procedure SetExtendedSelect(Value: Boolean);
    procedure SetItemHeight(Value: Integer);
    procedure SetItemIndex(Value: Integer);
    procedure SetItems(Value: TStrings);
    procedure SetMultiSelect(Value: Boolean);
    procedure SetReadOnly(Value: Boolean);
    procedure SetSelected(Index: Integer; Value: Boolean);
    procedure SetSorted(Value: Boolean);
    procedure SetTopIndex(Value: Integer);
    function GetAutoComplete: Boolean;
    function GetAutoCompleteDelay: Cardinal;
    procedure SetAutoComplete(Value: Boolean);
    procedure SetAutoCompleteDelay(Value: Cardinal);
    function GetScrollWidth: Integer;
    function GetTabWidth: Integer;
    procedure SetIntegralHeight(Value: Boolean);
    procedure SetScrollWidth(Value: Integer);
    procedure SetTabWidth(Value: Integer);
  protected
    FDataBinding: TcxCustomDataBinding;
    procedure CreateWnd; override;
    procedure CursorChanged; override;
    procedure FontChanged; override;
    procedure AdjustInnerControl; override;
    procedure DataChange; override;
    procedure DoExit; override;
    function IsInternalControl(AControl: TControl): Boolean; override;
    function IsReadOnly: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    function RefreshContainer(const P: TPoint; Button: TcxMouseButton; Shift: TShiftState;
      AIsMouseEvent: Boolean): Boolean; override;
    procedure UpdateData; override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure SetDragMode(Value: TDragMode); override;
    procedure SetSize; override;
    procedure WndProc(var Message: TMessage); override;

    procedure CalcHeaderSectionRects;
    function CalcItemHeight(AIndex: Integer; AVScrollBarVisible: Boolean): Integer; virtual;
    function GetDataBindingClass: TcxCustomDataBindingClass; virtual;
    procedure GetOptimalHeight(var ANewHeight: Integer);
    procedure FullRepaint;
    procedure SectionSortChangedHandler(Sender: TObject;
      const Section: TcxHeaderSection; const ASortOrder: TcxHeaderSortOrder); virtual;

    property DataBinding: TcxCustomDataBinding read FDataBinding;
    property InnerHeader: TcxMCInnerHeader read FInnerHeader;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property ScrollWidth: Integer read GetScrollWidth write SetScrollWidth default 0;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Focused: Boolean; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    procedure GetTabOrderList(List: TList); override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    procedure AddItem(AItem: string; AObject: TObject);
    procedure Clear;
    procedure ClearSelection;
    procedure DeleteSelected;
    function ItemAtPos(const APos: TPoint; AExisting: Boolean): Integer;
    function ItemRect(Index: Integer): TRect;
    function ItemVisible(Index: Integer): Boolean;
    procedure SelectAll;
  {$IFDEF DELPHI6}
    procedure CopySelection(ADestination: TCustomListControl);
    procedure MoveSelection(ADestination: TCustomListControl);
  {$ENDIF}
    property Count: Integer read GetCount;
    property InnerListBox:  TcxMCInnerListBox read FInnerListBox write FInnerListBox;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property SelCount: Integer read GetSelCount;
    property Selected[Index: Integer]: Boolean read GetSelected write SetSelected;
    property TopIndex: Integer read GetTopIndex write SetTopIndex;
  published
    property Align;
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taLeftJustify;
    property AutoComplete: Boolean read GetAutoComplete write SetAutoComplete
      default True;
    property AutoCompleteDelay: Cardinal read GetAutoCompleteDelay
      write SetAutoCompleteDelay default cxDefaultAutoCompleteDelay;
    property Anchors;
    property BiDiMode;
    property ColumnLineColor: TColor read FColumnLineColor
      write SetColumnLineColor default clBtnShadow;
    property Constraints;
    property Delimiter: Char read GetDelimiter write SetDelimiter default #59;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ExtendedSelect: Boolean read GetExtendedSelect
      write SetExtendedSelect default True;
    property HeaderDragReorder: Boolean read GetHeaderDragReorder
      write SetHeaderDragReorder default False;
    property HeaderSections: TcxHeaderSections read GetHeaderSections
      write SetHeaderSections;
    property Images: TCustomImageList read GetImages write SetImages;
    property ImeMode;
    property ImeName;
    property IntegralHeight: Boolean read FIntegralHeight
      write SetIntegralHeight default False;
    property ItemHeight: Integer read GetItemHeight write SetItemHeight
      default 16;
    property Items: TStrings read GetItems write SetItems;
    property MultiLines: Boolean read FMultiLines write SetMultiLines
      default False;
    property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect
      default False;
    property OverflowEmptyColumn: Boolean read FOverflowEmptyColumn
      write SetOverflowEmptyColumn default True;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowColumnLines: Boolean read FShowColumnLines
      write SetShowColumnLines default True;
    property ShowEndEllipsis: Boolean read FShowEndEllipsis
      write SetShowEndEllipsis default True;
    property ShowHeader: Boolean read FShowHeader write SetShowHeader
      default True;
    property ShowHint;
    property Sorted: Boolean read GetSorted write SetSorted default False;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property TabWidth: Integer read GetTabWidth write SetTabWidth default 0;
    property Visible;
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
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  cxVariants, dxThemeConsts, dxThemeManager, dxUxTheme;

type
  TMCStringList = class(TStringList)
  private
    SortOrder: TcxHeaderSortOrder;
    SortColumn: Integer;
    Delimiter: Char;
  public
{$IFDEF DELPHI5}
    procedure CustomSort(Compare: TStringListSortCompare); override;
{$ENDIF}
  end;

  TStringsChangeEvent = procedure(Sender: TStrings;
    AStartIndex, AEndIndex: Integer) of object;

  TcxMCListBoxStrings = class(TStrings)
  private
    FStorage: TStrings;
    FUpdating: Boolean;
    FOnChange: TStringsChangeEvent;
  protected
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
    function GetObject(Index: Integer): TObject; override;
    procedure Put(Index: Integer; const S: string); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetUpdateState(Updating: Boolean); override;
    procedure Changed(AStartIndex: Integer = -1;
      AEndIndex: Integer = -1); virtual;
    property Storage: TStrings read FStorage;
  public
    constructor Create(AStorage: TStrings); virtual;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Exchange(Index1, Index2: Integer); override;
    function IndexOf(const S: string): Integer; override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure Move(CurIndex, NewIndex: Integer); override;
    property OnChange: TStringsChangeEvent read FOnChange write FOnChange;
  end;

{$IFDEF DELPHI5}
function ListCompare(List: TStringList; Index1, Index2: Integer): Integer;

  function InternalCompareText(const S1, S2: string): Integer;
  begin
    Result := AnsiCompareText(S1, S2);
  end;

var
  s1, s2: string;
  FDelimiter: Char;
begin
  FDelimiter := TMCStringList(List).Delimiter;

  s1 := GetWord(TMCStringList(List).SortColumn, List[Index1], FDelimiter);
  s2 := GetWord(TMCStringList(List).SortColumn, List[Index2], FDelimiter);

  if TMCStringList(List).SortOrder = soAscending then
    Result := InternalCompareText(s1, s2)
  else
    Result := InternalCompareText(s2, s1);
end;

procedure TMCStringList.CustomSort(Compare: TStringListSortCompare);
begin
  inherited CustomSort(ListCompare);
end;
{$ENDIF}

{ TcxMCListBoxStrings }

constructor TcxMCListBoxStrings.Create(AStorage: TStrings);
begin
  inherited Create;
  FStorage := AStorage;
end;

procedure TcxMCListBoxStrings.Clear;
begin
  Storage.Clear;
end;

procedure TcxMCListBoxStrings.Delete(Index: Integer);
begin
  Storage.Delete(Index);
  Changed;
end;

procedure TcxMCListBoxStrings.Exchange(Index1, Index2: Integer);
begin
  Storage.Exchange(Index1, Index2);
end;

function TcxMCListBoxStrings.IndexOf(const S: string): Integer;
begin
  Result := Storage.IndexOf(S);
end;

procedure TcxMCListBoxStrings.Insert(Index: Integer; const S: string);
begin
  Storage.Insert(Index, S);
  Changed(Index, Count - 1);
end;

procedure TcxMCListBoxStrings.Move(CurIndex, NewIndex: Integer);
begin
  Storage.Move(CurIndex, NewIndex);
end;

function TcxMCListBoxStrings.Get(Index: Integer): string;
begin
  Result := Storage[Index];
end;

function TcxMCListBoxStrings.GetCount: Integer;
begin
  Result := Storage.Count;
end;

function TcxMCListBoxStrings.GetObject(Index: Integer): TObject;
begin
  Result := Storage.Objects[Index];
end;

procedure TcxMCListBoxStrings.Put(Index: Integer; const S: string);
begin
  Storage[Index] := S;
end;

procedure TcxMCListBoxStrings.PutObject(Index: Integer; AObject: TObject);
begin
  Storage.Objects[Index] := AObject;
end;

procedure TcxMCListBoxStrings.SetUpdateState(Updating: Boolean);
begin
  FUpdating := Updating;
  if Updating then
    Storage.BeginUpdate
  else
    Storage.EndUpdate;
  if not Updating then
    Changed;
end;

procedure TcxMCListBoxStrings.Changed(AStartIndex: Integer = -1;
  AEndIndex: Integer = -1);
begin
  if not FUpdating and Assigned(FOnChange) then
    FOnChange(Self, AStartIndex, AEndIndex);
end;

{ TcxMCInnerListBox }

constructor TcxMCInnerListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TcxMCListBoxStrings.Create(inherited Items);
  TcxMCListBoxStrings(FItems).OnChange := ItemsChanged;
end;

destructor TcxMCInnerListBox.Destroy;
begin
  FreeAndNil(FItems);
  inherited Destroy;
end;

function TcxMCInnerListBox.CanFocus: Boolean;
begin
  Result := Container.CanFocus;
end;

function TcxMCInnerListBox.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    Container.FDataBinding.ExecuteAction(Action);
end;

function TcxMCInnerListBox.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    Container.FDataBinding.UpdateAction(Action);
end;

procedure TcxMCInnerListBox.Click;
begin
  if Container.DataBinding.SetEditMode then
    inherited Click;
end;

procedure TcxMCInnerListBox.FullRepaint;
begin
  InternalInvalidateRect(Self, GetControlRect(Self), True);
end;

procedure TcxMCInnerListBox.SetItems(Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TcxMCInnerListBox.WMPaint(var Message: TWMPaint);
begin
  inherited;
  if Container.ShowColumnLines then
    DrawLines;
end;

procedure TcxMCInnerListBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  RecalcItemRects;
end;

procedure TcxMCInnerListBox.RecalcItemRects(AStartIndex: Integer = -1;
  AEndIndex: Integer = -1);
var
  AIsWindowRecreationNeeded: Boolean;
  AItemHeight, ANewItemHeight, I: Integer;
  AVScrollBarVisibilityChanged: Boolean;
begin
  Container.CalcHeaderSectionRects;

  if (AStartIndex = -1) and (AEndIndex = -1) then
  begin
    AStartIndex := 0;
    AEndIndex := Items.Count - 1;
  end;

  AIsWindowRecreationNeeded := False;
  AVScrollBarVisibilityChanged := FVScrollBarVisible <> IsVScrollBarVisible;
  if AVScrollBarVisibilityChanged then
  begin
    FVScrollBarVisible := not FVScrollBarVisible;
    (Parent as TcxMCInnerPanel).AdjustChildsPosition;
  end;
  for I := AStartIndex to AEndIndex do
  begin
    AItemHeight := Perform(LB_GETITEMHEIGHT, I, 0);
    ANewItemHeight := Container.CalcItemHeight(I, FVScrollBarVisible);
    if ANewItemHeight <> AItemHeight then
    begin
      AIsWindowRecreationNeeded := True;
      Break;
    end;
  end;
  if AIsWindowRecreationNeeded and HandleAllocated then
  begin
    RecreateWnd;
    Update;
  end;
end;

function TcxMCInnerListBox.GetContainer: TcxMCListBox;
begin
  Result := TcxMCListBox(FContainer);
end;

function TcxMCInnerListBox.IsVScrollBarVisible: Boolean;
var
  AItemsHeight: Integer;
  I: Integer;
begin
  AItemsHeight := 0;
  for I := 0 to Items.Count - 1 do
  begin
    Inc(AItemsHeight, Container.CalcItemHeight(I, False));
    if AItemsHeight > Height then
      Break;
  end;
  Result := AItemsHeight > Height;
end;

procedure TcxMCInnerListBox.ItemsChanged(Sender: TStrings;
  AStartIndex, AEndIndex: Integer);
begin
  RecalcItemRects(AStartIndex, AEndIndex);
end;

procedure TcxMCInnerListBox.SetContainer(Value: TcxMCListBox);
begin
  FContainer := Value;
end;

procedure TcxMCInnerListBox.DrawLines;
var
  AColumnLineTop, I: Integer;
  ALastItemRect: TRect;
begin
  if Items.Count > 0 then
  begin
    ALastItemRect := ItemRect(Items.Count - 1);
    if ALastItemRect.Bottom > Height then
      Exit
    else
      AColumnLineTop := ALastItemRect.Bottom;
  end
  else
    AColumnLineTop := 0;

  Canvas.Pen.Color := Container.ColumnLineColor;
  Canvas.Pen.Width := 1;
  for I := 0 to Container.HeaderSections.Count - 1 do
  begin
    Canvas.MoveTo(Container.HeaderSections[I].Right, AColumnLineTop);
    Canvas.LineTo(Container.HeaderSections[I].Right, Height);
  end;
end;

{ TcxMCInnerHeader }

constructor TcxMCInnerHeader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csNoDesignVisible];
  TabStop := False;
end;

function TcxMCInnerHeader.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    Container.FDataBinding.ExecuteAction(Action);
end;

function TcxMCInnerHeader.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    Container.FDataBinding.UpdateAction(Action);
end;

procedure TcxMCInnerHeader.AdjustSize;
begin
  inherited AdjustSize;
  FitToClientWidth;
end;

procedure TcxMCInnerHeader.Click;
begin
  if Container.DataBinding.SetEditMode then
    inherited Click;
end;

//procedure TcxMCInnerHeader.DoSectionEndResizeEvent(Section: TcxHeaderSection);
//begin
//  inherited DoSectionEndResizeEvent(Section);
//  AdjustScrollWidth;
//end;

function TcxMCInnerHeader.IsInnerControl: Boolean;
begin
  Result := True;
end;

procedure TcxMCInnerHeader.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  inherited LookAndFeelChanged(Sender, AChangedValues);
  if HandleAllocated then
    UpdateHeight;
end;

procedure TcxMCInnerHeader.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  AHeightCalculatingNeeded: Boolean;
begin
  AHeightCalculatingNeeded := (Operation = opRemove) and (AComponent = Images);
  inherited Notification(AComponent, Operation);
  if AHeightCalculatingNeeded then
    UpdateHeight;
end;

procedure TcxMCInnerHeader.UpdateHeight;
var
  APrevHeight: Integer;
begin
  APrevHeight := Height;
  if Container.ShowHeader then
    Height := GetAutoHeight
  else
    Height := 0;
  if Height <> APrevHeight then
  begin
    (Parent as TcxMCInnerPanel).AdjustChildsPosition;
    Container.InnerListBox.RecalcItemRects;
  end;
end;

//procedure TcxMCInnerHeader.AdjustScrollWidth;
//var
//  AScrollWidth, I: Integer;
//begin
//  AScrollWidth := 0;
//  for I := 0 to Sections.Count - 1 do
//    Inc(AScrollWidth, Sections[I].Width);
//  if AScrollWidth < Width then
//    AScrollWidth := Width;
//  Container.InnerListBox.ScrollWidth := AScrollWidth;
//end;

function TcxMCInnerHeader.GetControlContainer: TcxContainer;
begin
  Result := FContainer;
end;

function TcxMCInnerHeader.GetControl: TWinControl;
begin
  Result := Self;
end;

function TcxMCInnerHeader.GetContainer: TcxMCListBox;
begin
  Result := TcxMCListBox(FContainer);
end;

procedure TcxMCInnerHeader.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateHeight;
end;

procedure TcxMCInnerHeader.WMSetFocus(var Message: TWMSetFocus);
begin
  Container.InnerListBox.SetFocus;
end;

{ TcxMCInnerPanel }

constructor TcxMCInnerPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csAcceptsControls];
  TabStop := False;
end;

procedure TcxMCInnerPanel.AdjustChildsPosition;

  function GetInnerHeaderWidth: Integer;
  begin
    Result := ClientWidth;
    if MCListBox.InnerListBox.VScrollBarVisible then
      Dec(Result, GetScrollBarSize.cx);
  end;

begin
  MCListBox.InnerHeader.SetBounds(0, 0, GetInnerHeaderWidth,
    MCListBox.InnerHeader.Height);
  MCListBox.InnerListBox.SetBounds(0, MCListBox.InnerHeader.Height, ClientWidth,
    ClientHeight - MCListBox.InnerHeader.Height);
end;

procedure TcxMCInnerPanel.BoundsChanged;
begin
  inherited BoundsChanged;
  AdjustChildsPosition;
  MCListBox.InnerListBox.RecalcItemRects;
end;

procedure TcxMCInnerPanel.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  inherited LookAndFeelChanged(Sender, AChangedValues);
  Invalidate;
end;

procedure TcxMCInnerPanel.Paint;
var
  R: TRect;
begin
  inherited Paint;
  R := Rect(MCListBox.InnerHeader.Width, 0, ClientWidth, MCListBox.InnerHeader.Height);
  InflateRect(R, 10, 0);
  LookAndFeel.Painter.DrawHeaderControlSection(Canvas, R, cxEmptyRect, [],
    [bTop, bBottom], cxbsNormal, taLeftJustify, vaTop, False, False, '', Canvas.Font,
    clNone, clBtnFace);
end;

function TcxMCInnerPanel.GetMCListBox: TcxMCListBox;
begin
  Result := Parent as TcxMCListBox;
end;

procedure TcxMCInnerPanel.WMSetFocus(var Message: TWMSetFocus);
var
  AInnerListBox: TcxMCInnerListBox;
begin
  AInnerListBox := TcxMCListBox(Parent).InnerListBox;
  if AInnerListBox.CanFocus then
    AInnerListBox.SetFocus;
end;

{ TcxMCListBox }

constructor TcxMCListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAlignment := taLeftJustify;
  FMultiLines := False;
  FShowEndEllipsis := True;
  FDelimiter := ';';
  FOverflowEmptyColumn := True;
  FShowColumnLines := True;
  FColumnLineColor := clBtnShadow;
  FInternalPaint := False;
  FInternalFlagCreatedHeader := False;
  FSavedIndex := -1;
  FShowHeader := True;
  Width := 121;
  Height := 97;
  FOverLoadList := TStringList.Create;

  FDataBinding := GetDataBindingClass.Create(Self, Self);
  FDataBinding.OnDataChange := Self.DataChange;
  FDataBinding.OnDataSetChange := Self.DataSetChange;
  FDataBinding.OnUpdateData := Self.UpdateData;

  FInnerPanel := TcxMCInnerPanel.Create(Self);
  FInnerPanel.Parent := Self;
  FInnerPanel.Align := alClient;
  FInnerPanel.LookAndFeel.MasterLookAndFeel := Style.LookAndFeel;

  FInnerHeader := TcxMCInnerHeader.Create(FInnerPanel);
  InnerControl := FInnerPanel;
  FInnerHeader.Color := clBtnFace;
  FInnerHeader.ParentFont := True;
  FInnerHeader.Parent := FInnerPanel;
  FInnerHeader.FContainer := Self;
  FInnerHeader.LookAndFeel.MasterLookAndFeel := Style.LookAndFeel;
  FInnerHeader.OnSectionEndResize := SectionEndResizeHandler;
  FInnerHeader.OnSectionTrack := SectionTrackHandler;
  FInnerHeader.OnSectionsChange := SectionsChangeHandler;
  FInnerHeader.OnSectionChangedSortOrder := SectionSortChangedHandler;
  FInnerHeader.OnSectionEndDrag := SectionEndDragHandler;
  FInnerHeader.AllowSort := True;
  FInnerHeader.ResizeUpdate := False;

  FInnerListBox := TcxMCInnerListBox.Create(FInnerPanel);
  FInnerListBox.ParentColor := True;
  FInnerListBox.Parent := FInnerPanel;
  FInnerListBox.Cursor := Cursor;
  FInnerListBox.BorderStyle := bsNone;
  FInnerListBox.Container := Self;
  FInnerListBox.LookAndFeel.MasterLookAndFeel := Style.LookAndFeel;
  FInnerListBox.Style := lbOwnerDrawVariable;
  FInnerListBox.OnMeasureItem := MeasureItem;
  FInnerListBox.OnDrawItem := DrawItem;
  FSavedHScroll := FInnerListBox.HScrollBar.OnScroll;
  FInnerListBox.HScrollBar.OnScroll := HScrollHandler;

  DataBinding.VisualControl := FInnerListBox;
end;

destructor TcxMCListBox.Destroy;
begin
  FreeAndNil(FInnerListBox);
  FreeAndNil(FInnerHeader);
  FreeAndNil(FInnerPanel);
  FreeAndNil(FDataBinding);
  FreeAndNil(FOverLoadList);
  inherited Destroy;
end;

function TcxMCListBox.Focused: Boolean;
begin
  Result := inherited Focused or InnerListBox.Focused or FInnerHeader.Focused;
end;

procedure TcxMCListBox.AddItem(AItem: string; AObject: TObject);
begin
  Items.AddObject(AItem, AObject);
end;

procedure TcxMCListBox.Clear;
begin
  Items.Clear;
end;

procedure TcxMCListBox.ClearSelection;
begin
  FInnerListBox.ClearSelection;
end;

procedure TcxMCListBox.DeleteSelected;
begin
  FInnerListBox.DeleteSelected;
end;

function TcxMCListBox.ItemAtPos(const APos: TPoint; AExisting: Boolean): Integer;
begin
  Result := FInnerListBox.ItemAtPos(APos, AExisting);
end;

function TcxMCListBox.ItemRect(Index: Integer): TRect;
begin
  Result := FInnerListBox.ItemRect(Index);
end;

function TcxMCListBox.ItemVisible(Index: Integer): Boolean;
begin
  Result := FInnerListBox.ItemVisible(Index);
end;

procedure TcxMCListBox.SelectAll;
begin
  FInnerListBox.SelectAll;
end;

{$IFDEF DELPHI6}
procedure TcxMCListBox.CopySelection(ADestination: TCustomListControl);
begin
  FInnerListBox.CopySelection(ADestination);
end;

procedure TcxMCListBox.MoveSelection(ADestination: TCustomListControl);
begin
  FInnerListBox.MoveSelection(ADestination);
end;
{$ENDIF}

procedure TcxMCListBox.CreateWnd;
var
  FSection: TcxHeaderSection;
begin
  inherited;
  if not FInternalFlagCreatedHeader then
  begin
    FInternalFlagCreatedHeader := True;
    if (FInnerHeader.Sections.Count = 0) then
    begin
      FSection := FInnerHeader.Sections.Add;
      FSection.Text := 'Section #1';
      FSection.Width := FInnerHeader.Canvas.TextWidth(FSection.Text) + 4;
    end;
  end;
end;

procedure TcxMCListBox.CursorChanged;
begin
  inherited CursorChanged;
  if FInnerListBox <> nil then
    FInnerListBox.Cursor := Cursor;
end;

procedure TcxMCListBox.FontChanged;
begin
  inherited;
  FullRepaint;
  _TWinControlAccess._RecreateWnd(FInnerListBox);
end;

procedure TcxMCListBox.AdjustInnerControl;
var
  AFont: TFont;
begin
  FInnerHeader.Font := ActiveStyle.GetVisibleFont;

  FInnerListBox.Color := ViewInfo.BackgroundColor;
  AFont := TFont.Create;
  try
    AFont.Assign(Style.GetVisibleFont);
    AFont.Color := ActiveStyle.GetVisibleFont.Color;
    FInnerListBox.Font := AFont;
  finally
    AFont.Free;
  end;
end;

procedure TcxMCListBox.DataChange;
begin
  if DataBinding.IsDataSourceLive then
    ItemIndex := Items.IndexOf(VarToStr(DataBinding.GetStoredValue(evsText, Focused)))
  else
    ItemIndex := -1;
end;

procedure TcxMCListBox.DoExit;
begin
  if IsDestroying or FIsExitProcessing then
    Exit;
  FIsExitProcessing := True;
  try
    try
      DataBinding.UpdateDataSource;
    except
      SetFocus;
      raise;
    end;
    inherited DoExit;
  finally
    FIsExitProcessing := False;
  end;
end;

function TcxMCListBox.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    FDataBinding.ExecuteAction(Action);
end;

procedure TcxMCListBox.GetTabOrderList(List: TList);
var
  AActiveControl: TWinControl;
begin
  AActiveControl := GetParentForm(Self).ActiveControl;
  if (AActiveControl <> Self) and CanFocus and (InnerListBox = AActiveControl) then
  begin
    List.Add(InnerListBox);
    List.Remove(Self);
  end;
end;

function TcxMCListBox.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    FDataBinding.UpdateAction(Action);
end;

function TcxMCListBox.IsInternalControl(AControl: TControl): Boolean;
begin
  if FInnerListBox = nil then
    Result := True
  else
    Result := (AControl = FInnerListBox.HScrollBar) or (AControl = FInnerListBox.VScrollBar);
  Result := Result or inherited IsInternalControl(AControl);
end;

function TcxMCListBox.IsReadOnly: Boolean;
begin
  Result := DataBinding.IsControlReadOnly;
end;

procedure TcxMCListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_PRIOR, VK_NEXT, VK_END, VK_HOME, VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN:
      if not DataBinding.SetEditMode then
        Key := 0;
  end;
end;

procedure TcxMCListBox.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if IsTextChar(Key) and not DataBinding.SetEditMode then
    Key := #0
  else
    if Key = Char(VK_ESCAPE) then
      DataBinding.Reset;
end;

procedure TcxMCListBox.Loaded;
begin
  inherited;
  FontChanged;
end;

function TcxMCListBox.RefreshContainer(const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AIsMouseEvent: Boolean): Boolean;
begin
  Result := inherited RefreshContainer(P, Button, Shift, AIsMouseEvent);
end;

procedure TcxMCListBox.UpdateData;
begin
  if ItemIndex >= 0 then
    DataBinding.SetStoredValue(evsText, Items[ItemIndex])
  else
    DataBinding.SetStoredValue(evsText, '');
end;

function TcxMCListBox.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := inherited CanResize(NewWidth, NewHeight);
  if not Result or not IntegralHeight or IsLoading then
    Exit;
  if Align in [alLeft, alRight, alClient] then
    Exit;
  GetOptimalHeight(NewHeight);
end;

procedure TcxMCListBox.SetDragMode(Value: TDragMode);
begin
  inherited;
  FInnerListBox.DragMode := Value;
end;

procedure TcxMCListBox.SetSize;
var
  ANewHeight: Integer;
  APrevBoundsRect: TRect;
begin
  if IsLoading then
    Exit;
  APrevBoundsRect := FInnerListBox.BoundsRect;
  try
    if not IntegralHeight or (Align in [alLeft, alRight, alClient]) then
    begin
      inherited SetSize;
      Exit;
    end;
    ANewHeight := Height;
    GetOptimalHeight(ANewHeight);
    if Height >= (FInnerHeader.Height + 2) then
      Height := ANewHeight
    else
      Height := FInnerHeader.Height + 2;
    inherited SetSize;
  finally
    if not EqualRect(APrevBoundsRect, FInnerListBox.BoundsRect) and
      FInnerListBox.HandleAllocated then
        KillMessages(FInnerListBox.Handle, WM_MOUSEMOVE, WM_MOUSEMOVE);
  end;
end;

procedure TcxMCListBox.WndProc(var Message: TMessage);
begin
  if FInnerListBox <> nil then
    case Message.Msg of
      LB_ADDSTRING .. LB_MSGMAX:
        begin
          with Message do
            Result := SendMessage(FInnerListBox.Handle, Msg, WParam, LParam);
          Exit;
        end;
    end;
  inherited WndProc(Message);
end;

function TcxMCListBox.GetDataBindingClass: TcxCustomDataBindingClass;
begin
  Result := TcxCustomDataBinding;
end;

procedure TcxMCListBox.GetOptimalHeight(var ANewHeight: Integer);

  function GetItemHeight(AIndex: Integer): Integer;
  begin
    case FInnerListBox.Style of
      lbStandard{$IFDEF DELPHI6}, lbVirtual{$ENDIF}:
        Result := Canvas.FontHeight(Font);
      lbOwnerDrawFixed{$IFDEF DELPHI6}, lbVirtualOwnerDraw{$ENDIF}:
        Result := ItemHeight;
      lbOwnerDrawVariable:
        begin
          Result := ItemHeight;
          if (AIndex < Count) and Assigned(FInnerListBox.OnMeasureItem) then
            FInnerListBox.OnMeasureItem(Self, AIndex, Result);
        end;
    end;
  end;

var
  I: Integer;
  ABorderExtent: TRect;
  AItemHeight: Integer;
  AListClientSize, AListSize, AScrollBarSize: TSize;
  AScrollWidth: Integer;
  AVScrollBar: Boolean;
begin
  ABorderExtent := GetBorderExtent;
  AListClientSize.cy := ABorderExtent.Top + ABorderExtent.Bottom;
  AScrollBarSize := GetScrollBarSize;
  AScrollWidth := ScrollWidth;
  if AScrollWidth > 0 then
  Inc(AScrollWidth, 4);
  I := FInnerHeader.Height;
  repeat
    AItemHeight := GetItemHeight(I);
    AListClientSize.cy := AListClientSize.cy + AItemHeight;
    AListSize.cy := AListClientSize.cy;
    AListClientSize.cx := Width - (ABorderExtent.Left + ABorderExtent.Right);
    AVScrollBar := I + 1 < Count;
    if AVScrollBar then
      AListClientSize.cx := AListClientSize.cx - AScrollBarSize.cx;
    if AListClientSize.cx < AScrollWidth then
      AListSize.cy := AListSize.cy + AScrollBarSize.cy;
    if AListSize.cy = ANewHeight then
      Break;
    if AListSize.cy > ANewHeight then
    begin
      if I > 0 then
      begin
        AListClientSize.cy := AListClientSize.cy - AItemHeight;
        AListSize.cy := AListClientSize.cy;
        AListClientSize.cx := Width - (ABorderExtent.Left + ABorderExtent.Right);
        AVScrollBar := I < Count;
        if AVScrollBar then
          AListClientSize.cx := AListClientSize.cx - AScrollBarSize.cx;
        if AListClientSize.cx < AScrollWidth then
          AListSize.cy := AListSize.cy + AScrollBarSize.cy;
      end;
      Break;
    end;
    Inc(I);
  until False;
  ANewHeight := AListSize.cy;
end;

function TcxMCListBox.CalcCellTextRect(AApproximateRect: TRect; AItemIndex, AColumnIndex: Integer): TRect;
begin
  Result := AApproximateRect;
  DrawCellTextEx(Result, DT_CALCRECT or DT_NOPREFIX or DT_VCENTER, AItemIndex, AColumnIndex);
end;

procedure TcxMCListBox.DrawCellTextEx(var ARect: TRect; AFlags, AItemIndex, AColumnIndex: Integer);

  function GetDrawTextParams: TDrawTextParams;
  begin
    Result.cbSize := SizeOf(TDrawTextParams);
    Result.iTabLength := TabWidth;
    Result.iLeftMargin := 0;
    Result.iRightMargin := 0;
  end;

  function GetTextFlag(const AStartFlag: Longint): Longint;
  const
    ShowEndEllipsisArray: array[Boolean] of Integer = (0, DT_END_ELLIPSIS);
    WordWrapArray: array[Boolean] of Integer = (0, DT_WORDBREAK);
  begin
    Result := AStartFlag or
      SystemAlignmentsHorz[HeaderSections[AColumnIndex].Alignment] or
      WordWrapArray[MultiLines] or ShowEndEllipsisArray[ShowEndEllipsis];
    if not MultiLines then
      Result := Result or DT_SINGLELINE;
    if FInnerListBox.TabWidth > 0 then
      Result := Result or DT_EXPANDTABS or DT_TABSTOP;
  end;

var
  ADrawTextParams: TDrawTextParams;
  AText: string;
begin
  ADrawTextParams := GetDrawTextParams;
  AText := GetTextPart(AItemIndex, AColumnIndex);
  DrawTextEx(FInnerListBox.Canvas.Handle, PChar(AText),
    Length(AText), ARect, GetTextFlag(AFlags), @ADrawTextParams);
end;

procedure TcxMCListBox.DrawCellText(ARect: TRect; AItemIndex, AColumnIndex: Integer);
begin
  DrawCellTextEx(ARect, DT_NOPREFIX or DT_VCENTER, AItemIndex, AColumnIndex);
end;

function TcxMCListBox.GetCellRect(AItemIndex, AColumnIndex,
  ATop, ABottom: Integer; AVScrollBarVisible: Boolean): TRect;
var
  AHeaderSectionRect: TRect;
  I: Integer;
begin
  AHeaderSectionRect := GetHeaderSectionRect(AColumnIndex, AVScrollBarVisible);
  Result := Rect(AHeaderSectionRect.Left + 2, ATop, AHeaderSectionRect.Right - 2, ABottom);
  if OverflowEmptyColumn then
    for I := AColumnIndex + 1 to HeaderSections.Count - 1 do
      if GetTextPart(AItemIndex, I) = '' then
        Result.Right := Result.Right + RectWidth(GetHeaderSectionRect(I, AVScrollBarVisible))
      else
        Break;
end;

function TcxMCListBox.GetCellTextRect(AItemIndex, AColumnIndex,
  ATop, ABottom: Integer; AVScrollBarVisible: Boolean): TRect;
begin
  Result := CalcCellTextRect(GetCellRect(AItemIndex, AColumnIndex, ATop, ABottom, AVScrollBarVisible),
    AItemIndex, AColumnIndex);
end;

function TcxMCListBox.GetDelimiter: Char;
begin
  Result := FDelimiter;
end;

function TcxMCListBox.GetImages: TCustomImageList;
begin
  Result := FInnerHeader.Images;
end;

procedure TcxMCListBox.SetImages(Value: TCustomImageList);
begin
  FInnerHeader.Images := Value;
  FInnerHeader.UpdateHeight;
end;

function TcxMCListBox.GetHeaderSectionRect(AIndex: Integer;
  AVScrollBarVisible: Boolean): TRect;
begin
  if AVScrollBarVisible then
    Result := FInnerHeaderSectionRectsWithScrollbar[AIndex]
  else
    Result := FInnerHeaderSectionRectsWithoutScrollbar[AIndex];
end;

function TcxMCListBox.GetHeaderSections: TcxHeaderSections;
begin
  Result := FInnerHeader.Sections;
end;

procedure TcxMCListBox.SetHeaderSections(Value: TcxHeaderSections);
begin
  FInnerHeader.Sections := Value;
end;

procedure TcxMCListBox.SetAlignment(Value: TAlignment);
var
  I: Integer;
begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    for I := 0 to Pred(HeaderSections.Count) do
      HeaderSections[I].Alignment := FAlignment;
    FullRepaint;
  end;
end;

procedure TcxMCListBox.SetMultiLines(Value: Boolean);
begin
  if FMultiLines <> Value then
  begin
    FMultiLines := Value;
    FullRepaint;
  end;
end;

procedure TcxMCListBox.SetShowEndEllipsis(Value: Boolean);
begin
  if FShowEndEllipsis <> Value then
  begin
    FShowEndEllipsis := Value;
    FullRepaint;
  end;
end;

procedure TcxMCListBox.SetDelimiter(Value: Char);
begin
  if FDelimiter <> Value then
  begin
    FDelimiter := Value;
    FullRepaint;
  end;
end;

function TcxMCListBox.GetHeaderDragReorder: Boolean;
begin
  Result := FInnerHeader.DragReorder;
end;

procedure TcxMCListBox.SetHeaderDragReorder(Value: Boolean);
begin
  FInnerHeader.DragReorder := Value;
end;

procedure TcxMCListBox.SetShowColumnLines(Value: Boolean);
begin
  if FShowColumnLines <> Value then
  begin
    FShowColumnLines := Value;
    FullRepaint;
  end;
end;

procedure TcxMCListBox.SetShowHeader(Value: Boolean);
begin
  if Value <> FShowHeader then
  begin
    FShowHeader := Value;
    FInnerHeader.UpdateHeight;
  end;
end;

procedure TcxMCListBox.SetColumnLineColor(Value: TColor);
begin
  if FColumnLineColor <> Value then
  begin
    FColumnLineColor := Value;
    FullRepaint;
  end;
end;

procedure TcxMCListBox.SetOverflowEmptyColumn(Value: Boolean);
begin
  if FOverflowEmptyColumn <> Value then
  begin
    FOverflowEmptyColumn := Value;
    FullRepaint;
  end;
end;

procedure TcxMCListBox.SectionEndResizeHandler(HeaderControl: TcxCustomHeader;
  Section: TcxHeaderSection);
begin
  FullRepaint;
end;

procedure TcxMCListBox.SectionsChangeHandler(Sender: TObject);
begin
  FullRepaint;
end;

procedure TcxMCListBox.HScrollHandler(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  if Assigned(FSavedHScroll) then FSavedHScroll(Sender, ScrollCode, ScrollPos);
end;

procedure TcxMCListBox.SectionEndDragHandler(Sender: TObject);
begin
  FInnerListBox.Invalidate;
end;

procedure TcxMCListBox.SectionTrackHandler(HeaderControl: TcxCustomHeader;
  Section: TcxHeaderSection; Width: Integer; State: TcxSectionTrackState);
begin
  if (State = tsTrackEnd) then
    FullRepaint;
end;

procedure TcxMCListBox.FullRepaint;
begin
  Canvas.Canvas.Lock;
  try
    if Count = 0 then
      FInnerListBox.FullRepaint
    else
    begin
      FSavedIndex := ItemIndex;
      FInternalPaint := True;
      FInnerListBox.RecalcItemRects;
      FInnerListBox.FullRepaint;
      FInnerListBox.ItemIndex := FSavedIndex;
    end;
  finally
    FInternalPaint := False;
    Canvas.Canvas.Unlock;
  end;
end;

procedure TcxMCListBox.SectionSortChangedHandler(Sender: TObject;
  const Section: TcxHeaderSection; const ASortOrder: TcxHeaderSortOrder);
var
  TmpList: TMCStringList;
begin
  if ASortOrder = soNone then
    Exit;

  TmpList := TMCStringList.Create;
  try
    Items.BeginUpdate;
    try
      TmpList.Assign(Items);
      try
        TmpList.Delimiter := FDelimiter;
        TmpList.SortOrder := ASortOrder;

        if ASortOrder = soNone then
          TmpList.SortColumn := -1
        else
          TmpList.SortColumn := Succ(Section.DataIndex);

        TmpList.Sort;
      finally
        Items.Assign(TmpList);
      end;
    finally
      Items.EndUpdate;
    end;
  finally
    TmpList.Free;
  end;
end;

function TcxMCListBox.GetTextPart(AItemIndex, AColumnIndex: Integer): string;
var
  APartIndex: Integer;
begin
  APartIndex := HeaderSections[AColumnIndex].DataIndex;
  if APartIndex < 0 then
    Result := ''
  else
    Result := GetWord(APartIndex + 1, Items[AItemIndex], FDelimiter);
end;

procedure TcxMCListBox.DrawItem(Control: TWinControl; Index: Integer;
  ARect: TRect; State: TOwnerDrawState);

  procedure AdjustCanvasColors;
  var
    ABackgroundColor, ATextColor: TColor;
  begin
    if (not FInternalPaint and (odSelected in State)) or
     (FInternalPaint and (FSavedIndex = Index)) then
    begin
      ABackgroundColor := clHighlight;
      ATextColor := clHighlightText;
    end else
    begin
      ABackgroundColor := ActiveStyle.Color;
      ATextColor := ActiveStyle.GetVisibleFont.Color;
    end;
    FInnerListBox.Canvas.Brush.Color := ABackgroundColor;
    FInnerListBox.Canvas.Font.Color := ATextColor;
  end;

  procedure DrawColumnSectionText(AColumnIndex: Integer);
  var
    ATextRect: TRect;
  begin
    ATextRect := GetCellRect(Index, AColumnIndex, ARect.Top, ARect.Bottom,
      InnerListBox.VScrollBarVisible);
    DrawCellText(ATextRect, Index, AColumnIndex);
    FInnerListBox.Canvas.ExcludeClipRect(ATextRect);
  end;

  procedure DrawColumnSectionLine(AColumnIndex: Integer);
  begin
    FInnerListBox.Canvas.Pen.Color := ColumnLineColor;
    FInnerListBox.Canvas.Pen.Width := 1;
    FInnerListBox.Canvas.MoveTo(GetHeaderSectionRect(AColumnIndex, InnerListBox.VScrollBarVisible).Right, ARect.Top);
    FInnerListBox.Canvas.LineTo(GetHeaderSectionRect(AColumnIndex, InnerListBox.VScrollBarVisible).Right, ARect.Bottom);
  end;

var
  I: Integer;
begin
  AdjustCanvasColors;
  FInnerListBox.Canvas.FillRect(ARect);
  for I := 0 to HeaderSections.Count - 1 do
  begin
    DrawColumnSectionText(I);
    if ShowColumnLines then
      DrawColumnSectionLine(I);
  end;
end;

procedure TcxMCListBox.MeasureItem(Control: TWinControl; Index: Integer; var Height: Integer);
begin
  Height := CalcItemHeight(Index, InnerListBox.VScrollBarVisible);
end;

procedure TcxMCListBox.CalcHeaderSectionRects;

  procedure InternalCalcHeaderSectionRects(AHeaderWidth: Integer;
    out ASectionRects: TcxHeaderSectionRects);
  var
    ASectionWidths: TcxHeaderSectionWidths;
    I: Integer;
  begin
    InnerHeader.CalcSectionWidths(AHeaderWidth, ASectionWidths);
    SetLength(ASectionRects, InnerHeader.Sections.Count);
    for I := 0 to InnerHeader.Sections.Count - 1 do
      ASectionRects[I] := InnerHeader.GetSectionRectBySectionWidths(AHeaderWidth, ASectionWidths, I);
  end;

begin
  InternalCalcHeaderSectionRects(FInnerPanel.ClientWidth, FInnerHeaderSectionRectsWithoutScrollbar);
  InternalCalcHeaderSectionRects(FInnerPanel.ClientWidth - GetScrollBarSize.cx, FInnerHeaderSectionRectsWithScrollbar);
end;

function TcxMCListBox.CalcItemHeight(AIndex: Integer; AVScrollBarVisible: Boolean): Integer;
var
  I, ATextHeight: Integer;
  ACalcRect: TRect;
begin
  Result := GetItemHeight;
  ATextHeight := FInnerListBox.Canvas.TextHeight('Wq');
  if ATextHeight > Result then
    Result := ATextHeight;
  for I := 0 to HeaderSections.Count - 1 do
  begin
    ACalcRect := GetCellTextRect(AIndex, I, 0, Result, AVScrollBarVisible);
    if RectHeight(ACalcRect) > Result then
      Result := RectHeight(ACalcRect);
  end;
end;

function TcxMCListBox.GetCount: Integer;
begin
  Result := FInnerListBox.Items.Count;
end;

function TcxMCListBox.GetExtendedSelect: Boolean;
begin
  Result := FInnerListBox.ExtendedSelect;
end;

function TcxMCListBox.GetItemHeight: Integer;
begin
  Result := FInnerListBox.ItemHeight;
end;

function TcxMCListBox.GetItemIndex: Integer;
begin
  Result := FInnerListBox.ItemIndex;
end;

function TcxMCListBox.GetItems: TStrings;
begin
  Result := FInnerListBox.Items;
end;

function TcxMCListBox.GetMultiSelect: Boolean;
begin
  Result := FInnerListBox.MultiSelect;
end;

function TcxMCListBox.GetReadOnly: Boolean;
begin
  Result := DataBinding.ReadOnly;
end;

function TcxMCListBox.GetSelCount: Integer;
begin
  Result := FInnerListBox.SelCount;
end;

function TcxMCListBox.GetSelected(Index: Integer): Boolean;
begin
  Result := FInnerListBox.Selected[Index];
end;

function TcxMCListBox.GetSorted: Boolean;
begin
  Result := FInnerListBox.Sorted;
end;

function TcxMCListBox.GetTopIndex: Integer;
begin
  Result := FInnerListBox.TopIndex;
end;

procedure TcxMCListBox.SetExtendedSelect(Value: Boolean);
begin
  FInnerListBox.ExtendedSelect := Value;
end;

procedure TcxMCListBox.SetItemHeight(Value: Integer);
begin
  FInnerListBox.ItemHeight := Value;
  FullRepaint;
end;

procedure TcxMCListBox.SetItemIndex(Value: Integer);
begin
  FInnerListBox.ItemIndex := Value;
end;

procedure TcxMCListBox.SetItems(Value: TStrings);
begin
  FInnerListBox.Items.Assign(Value);
  DataChange;
end;

procedure TcxMCListBox.SetMultiSelect(Value: Boolean);
begin
  FInnerListBox.MultiSelect := Value;
end;

procedure TcxMCListBox.SetReadOnly(Value: Boolean);
begin
  DataBinding.ReadOnly := Value;
end;

procedure TcxMCListBox.SetSelected(Index: Integer; Value: Boolean);
begin
  FInnerListBox.Selected[Index] := Value;
end;

procedure TcxMCListBox.SetSorted(Value: Boolean);
begin
  FInnerListBox.Sorted := Value;
end;

procedure TcxMCListBox.SetTopIndex(Value: Integer);
begin
  FInnerListBox.TopIndex := Value;
end;

function TcxMCListBox.GetAutoComplete: Boolean;
begin
  Result := FInnerListBox.AutoComplete;
end;

function TcxMCListBox.GetAutoCompleteDelay: Cardinal;
begin
  Result := FInnerListBox.AutoCompleteDelay;
end;

procedure TcxMCListBox.SetAutoComplete(Value: Boolean);
begin
  FInnerListBox.AutoComplete := Value;
end;

procedure TcxMCListBox.SetAutoCompleteDelay(Value: Cardinal);
begin
  FInnerListBox.AutoCompleteDelay := Value;
end;

function TcxMCListBox.GetScrollWidth: Integer;
begin
  Result := FInnerListBox.ScrollWidth;
end;

function TcxMCListBox.GetTabWidth: Integer;
begin
  Result := FInnerListBox.TabWidth;
end;

procedure TcxMCListBox.SetIntegralHeight(Value: Boolean);
begin
  if Value <> FIntegralHeight then
  begin
    FIntegralHeight := Value;
    SetSize;
  end;
end;

procedure TcxMCListBox.SetScrollWidth(Value: Integer);
begin
  FInnerListBox.ScrollWidth := Value;
end;

procedure TcxMCListBox.SetTabWidth(Value: Integer);
begin
  FInnerListBox.Items.BeginUpdate;
  try
    FInnerListBox.TabWidth := Value;
  finally
    FInnerListBox.Items.EndUpdate;
  end;
end;

end.
