
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

unit cxListBox;

{$I cxVer.inc}

interface

uses
  Windows, Messages,
  Classes, Controls, Forms, Menus, StdCtrls, SysUtils, cxClasses, cxControls,
  cxContainer, cxDataUtils, cxGraphics, cxLookAndFeels, cxScrollBar;

type
  TcxListBox = class;

  { TcxInnerListBox }

  TcxInnerListBox = class(TcxCustomInnerListBox)
  private
    function GetContainer: TcxListBox;
    procedure SetContainer(Value: TcxListBox);
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
  protected
    procedure Click; override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    property Container: TcxListBox read GetContainer write SetContainer;
  public
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function CanFocus: Boolean; override;
  end;

  TcxInnerListBoxClass = class of TcxInnerListBox;

  { TcxListBox }

  TcxListBoxDrawItemEvent = procedure(AControl: TcxListBox; ACanvas: TcxCanvas;
    AIndex: Integer; ARect: TRect; AState: TOwnerDrawState) of object;
  TcxListBoxMeasureItemEvent = procedure(AControl: TcxListBox; AIndex: Integer;
    var Height: Integer) of object;

  TcxListBox = class(TcxContainer)
  private
    FInnerListBox: TcxInnerListBox;
    FIntegralHeight: Boolean;
    FIsExitProcessing: Boolean;
    FOnDrawItem: TcxListBoxDrawItemEvent;
    FOnMeasureItem: TcxListBoxMeasureItemEvent;
    procedure DoMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    function GetAutoComplete: Boolean;
    function GetAutoCompleteDelay: Cardinal;
    function GetColumns: Integer;
    function GetCount: Integer;
    function GetExtendedSelect: Boolean;
    function GetInnerListBox: TListBox;
    function GetItemHeight: Integer;
    function GetItemIndex: Integer;
    function GetItemObject: TObject;
    function GetItems: TStrings;
    function GetListStyle: TListBoxStyle;
    function GetMultiSelect: Boolean;
    function GetReadOnly: Boolean;
    function GetSelCount: Integer;
    function GetSelected(Index: Integer): Boolean;
    function GetSorted: Boolean;
    function GetTopIndex: Integer;
    procedure SetAutoComplete(Value: Boolean);
    procedure SetAutoCompleteDelay(Value: Cardinal);
    procedure SetColumns(Value: Integer);
    procedure SetExtendedSelect(Value: Boolean);
    procedure SetItemHeight(Value: Integer);
    procedure SetItemIndex(Value: Integer);
    procedure SetItemObject(Value: TObject);
    procedure SetItems(Value: TStrings);
    procedure SetListStyle(Value: TListBoxStyle);
    procedure SetMultiSelect(Value: Boolean);
    procedure SetOnMeasureItem(Value: TcxListBoxMeasureItemEvent);
    procedure SetReadOnly(Value: Boolean);
    procedure SetSelected(Index: Integer; Value: Boolean);
    procedure SetSorted(Value: Boolean);
    procedure SetTopIndex(Value: Integer);
  {$IFDEF DELPHI6}
    function GetOnData: TLBGetDataEvent;
    function GetOnDataFind: TLBFindDataEvent;
    function GetOnDataObject: TLBGetDataObjectEvent;
    procedure SetCount(Value: Integer);
    procedure SetOnData(Value: TLBGetDataEvent);
    procedure SetOnDataFind(Value: TLBFindDataEvent);
    procedure SetOnDataObject(Value: TLBGetDataObjectEvent);
  {$ENDIF}
    function GetScrollWidth: Integer;
    function GetTabWidth: Integer;
    procedure SetIntegralHeight(Value: Boolean);
    procedure SetScrollWidth(Value: Integer);
    procedure SetTabWidth(Value: Integer);
  protected
    FDataBinding: TcxCustomDataBinding;
    procedure DataChange; override;
    procedure DoExit; override;
    procedure FontChanged; override;
    function IsInternalControl(AControl: TControl): Boolean; override;
    function IsReadOnly: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure UpdateData; override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure SetSize; override;
    procedure WndProc(var Message: TMessage); override;
    function DrawItem(ACanvas: TcxCanvas; AIndex: Integer; const ARect: TRect;
      AState: TOwnerDrawState): Boolean; virtual;
    function GetDataBindingClass: TcxCustomDataBindingClass; virtual;
    function GetInnerListBoxClass: TcxInnerListBoxClass; virtual;
    procedure GetOptimalHeight(var ANewHeight: Integer);
    property DataBinding: TcxCustomDataBinding read FDataBinding;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
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
    property Count: Integer read GetCount{$IFDEF DELPHI6} write SetCount{$ENDIF};
    property InnerListBox: TListBox read GetInnerListBox;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property ItemObject: TObject read GetItemObject write SetItemObject;
    property SelCount: Integer read GetSelCount;
    property Selected[Index: Integer]: Boolean read GetSelected write SetSelected;
    property TopIndex: Integer read GetTopIndex write SetTopIndex;
  published
    property Align;
    property Anchors;
    property AutoComplete: Boolean read GetAutoComplete write SetAutoComplete
      default True;
    property AutoCompleteDelay: Cardinal read GetAutoCompleteDelay
      write SetAutoCompleteDelay default cxDefaultAutoCompleteDelay;
    property BiDiMode;
    property Columns: Integer read GetColumns write SetColumns default 0;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property ExtendedSelect: Boolean read GetExtendedSelect
      write SetExtendedSelect default True;
    property ImeMode;
    property ImeName;
    property IntegralHeight: Boolean read FIntegralHeight
      write SetIntegralHeight default False;
    property ItemHeight: Integer read GetItemHeight write SetItemHeight;
    property Items: TStrings read GetItems write SetItems;
    property ListStyle: TListBoxStyle read GetListStyle write SetListStyle
      default lbStandard;
    property MultiSelect: Boolean read GetMultiSelect write SetMultiSelect
      default False;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property ScrollWidth: Integer read GetScrollWidth write SetScrollWidth
      default 0;
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
  {$IFDEF DELPHI6}
    property OnData: TLBGetDataEvent read GetOnData write SetOnData;
    property OnDataFind: TLBFindDataEvent read GetOnDataFind write SetOnDataFind;
    property OnDataObject: TLBGetDataObjectEvent read GetOnDataObject
      write SetOnDataObject;
  {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem: TcxListBoxDrawItemEvent read FOnDrawItem
      write FOnDrawItem;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem: TcxListBoxMeasureItemEvent read FOnMeasureItem
      write SetOnMeasureItem;
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
  Graphics, cxEdit;

type
  TWinControlAccess = class(TWinControl);

{ TcxInnerListBox }

function TcxInnerListBox.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    Container.FDataBinding.ExecuteAction(Action);
end;

function TcxInnerListBox.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    Container.FDataBinding.UpdateAction(Action);
end;

function TcxInnerListBox.CanFocus: Boolean;
begin
  Result := Container.CanFocus;
end;

procedure TcxInnerListBox.Click;
begin
  if Container.DataBinding.SetEditMode then
    inherited Click;
end;

procedure TcxInnerListBox.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited CreateWindowHandle(Params);
  SetExternalScrollBarsParameters;
end;

procedure TcxInnerListBox.DrawItem(Index: Integer; Rect: TRect;
  State: TOwnerDrawState);
begin
  if not Container.DrawItem(Canvas, Index, Rect, State) then
    inherited DrawItem(Index, Rect, State);
end;

function TcxInnerListBox.GetContainer: TcxListBox;
begin
  Result := TcxListBox(Owner);
end;

procedure TcxInnerListBox.SetContainer(Value: TcxListBox);
begin
  FContainer := Value;
end;

procedure TcxInnerListBox.WMLButtonDown(var Message: TWMLButtonDown);
begin
  if Container.DataBinding.SetEditMode then
    inherited
  else
  begin
    SetFocus;
    with Message do
      MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
  end;
end;

{ TcxListBox }

constructor TcxListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataBinding := GetDataBindingClass.Create(Self, Self);
  with FDataBinding do
  begin
    OnDataChange := Self.DataChange;
    OnDataSetChange := Self.DataSetChange;
    OnUpdateData := Self.UpdateData;
  end;
  FInnerListBox := GetInnerListBoxClass.Create(Self);
  FInnerListBox.BorderStyle := bsNone;
  FInnerListBox.Parent := Self;
  FInnerListBox.Container := Self;
  InnerControl := FInnerListBox;
  FInnerListBox.LookAndFeel.MasterLookAndFeel := Style.LookAndFeel;
  Width := 121;
  Height := 97;
end;

destructor TcxListBox.Destroy;
begin
  FreeAndNil(FInnerListBox);
  FreeAndNil(FDataBinding);
  inherited Destroy;
end;

function TcxListBox.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    FDataBinding.ExecuteAction(Action);
end;

function TcxListBox.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    FDataBinding.UpdateAction(Action);
end;

procedure TcxListBox.AddItem(AItem: string; AObject: TObject);
begin
  FInnerListBox.AddItem(AItem, AObject);
end;

procedure TcxListBox.Clear;
begin
  FInnerListBox.Clear;
end;

procedure TcxListBox.ClearSelection;
begin
  FInnerListBox.ClearSelection;
end;

procedure TcxListBox.DeleteSelected;
begin
  FInnerListBox.DeleteSelected;
end;

function TcxListBox.ItemAtPos(const APos: TPoint; AExisting: Boolean): Integer;
begin
  with FInnerListBox do
    Result := ItemAtPos(Point(APos.X - Left, APos.Y - Top), AExisting);
end;

function TcxListBox.ItemRect(Index: Integer): TRect;
begin
  Result := FInnerListBox.ItemRect(Index);
  OffsetRect(Result, FInnerListBox.Left, FInnerListBox.Top);
end;

function TcxListBox.ItemVisible(Index: Integer): Boolean;
begin
  Result := FInnerListBox.ItemVisible(Index);
end;

procedure TcxListBox.SelectAll;
begin
  FInnerListBox.SelectAll;
end;

{$IFDEF DELPHI6}
procedure TcxListBox.CopySelection(ADestination: TCustomListControl);
begin
  FInnerListBox.CopySelection(ADestination);
end;

procedure TcxListBox.MoveSelection(ADestination: TCustomListControl);
begin
  FInnerListBox.MoveSelection(ADestination);
end;
{$ENDIF}

procedure TcxListBox.DataChange;
begin
  if DataBinding.IsDataSourceLive then
    ItemIndex := Items.IndexOf(VarToStr(DataBinding.GetStoredValue(evsText, Focused)))
  else
    ItemIndex := -1;
end;

procedure TcxListBox.DoExit;
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

procedure TcxListBox.FontChanged;
begin
  inherited FontChanged;
  SetSize;
  TWinControlAccess(InnerListBox).RecreateWnd;
end;

function TcxListBox.IsInternalControl(AControl: TControl): Boolean;
begin
  if FInnerListBox = nil then
    Result := True
  else
    Result := (AControl = FInnerListBox.HScrollBar) or (AControl = FInnerListBox.VScrollBar);
  Result := Result or inherited IsInternalControl(AControl);
end;

function TcxListBox.IsReadOnly: Boolean;
begin
  Result := DataBinding.IsControlReadOnly;
end;

procedure TcxListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_PRIOR, VK_NEXT, VK_END, VK_HOME, VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN:
      if not DataBinding.SetEditMode then
        Key := 0;
  end;
end;

procedure TcxListBox.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if IsTextChar(Key) then
  begin
    if not DataBinding.SetEditMode then
      Key := #0;
  end
  else
    if Key = #27 then
      DataBinding.Reset;
end;

procedure TcxListBox.UpdateData;
begin
  if ItemIndex >= 0 then
    DataBinding.SetStoredValue(evsText, Items[ItemIndex])
  else
    DataBinding.SetStoredValue(evsText, '');
end;

function TcxListBox.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := inherited CanResize(NewWidth, NewHeight);
  if not Result or not IntegralHeight or IsLoading then
    Exit;
  if Align in [alLeft, alRight, alClient] then
    Exit;
  GetOptimalHeight(NewHeight);
end;

procedure TcxListBox.SetSize;
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
    Height := ANewHeight;
    inherited SetSize;
  finally
    if not EqualRect(APrevBoundsRect, FInnerListBox.BoundsRect) and FInnerListBox.HandleAllocated then
      KillMessages(FInnerListBox.Handle, WM_MOUSEMOVE, WM_MOUSEMOVE);
  end;
end;

procedure TcxListBox.WndProc(var Message: TMessage);
begin
  if FInnerListBox <> nil then
    case Message.Msg of
      LB_ADDSTRING..LB_MSGMAX:
        begin
          with TMessage(Message) do
            Result := SendMessage(FInnerListBox.Handle, Msg, WParam, LParam);
          Exit;
        end;
    end;
  inherited WndProc(Message);
  if (FInnerListBox <> nil) and (Message.Msg = WM_COMMAND) and (Message.WParamHi = LBN_SELCHANGE) then
    FInnerListBox.SetExternalScrollBarsParameters;
end;

function TcxListBox.DrawItem(ACanvas: TcxCanvas; AIndex: Integer;
  const ARect: TRect; AState: TOwnerDrawState): Boolean;
begin
  Result := Assigned(FOnDrawItem);
  if Result then
    FOnDrawItem(Self, ACanvas, AIndex, ARect, AState);
end;

function TcxListBox.GetDataBindingClass: TcxCustomDataBindingClass;
begin
  Result := TcxDataBinding;
end;

function TcxListBox.GetInnerListBoxClass: TcxInnerListBoxClass;
begin
  Result := TcxInnerListBox;
end;

procedure TcxListBox.GetOptimalHeight(var ANewHeight: Integer);

  function GetItemHeight(AIndex: Integer): Integer;
  begin
    case ListStyle of
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
  I := 0;
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

procedure TcxListBox.DoMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  FOnMeasureItem(Self, Index, Height);
end;

function TcxListBox.GetAutoComplete: Boolean;
begin
  Result := FInnerListBox.AutoComplete;
end;

function TcxListBox.GetAutoCompleteDelay: Cardinal;
begin
  Result := FInnerListBox.AutoCompleteDelay;
end;

function TcxListBox.GetColumns: Integer;
begin
  Result := FInnerListBox.Columns;
end;

function TcxListBox.GetCount: Integer;
begin
  Result := FInnerListBox.Items.Count;
end;

function TcxListBox.GetExtendedSelect: Boolean;
begin
  Result := FInnerListBox.ExtendedSelect;
end;

function TcxListBox.GetInnerListBox: TListBox;
begin
  Result := FInnerListBox;
end;

function TcxListBox.GetItemHeight: Integer;
begin
  Result := FInnerListBox.ItemHeight;
end;

function TcxListBox.GetItemIndex: Integer;
begin
  Result := FInnerListBox.ItemIndex;
end;

function TcxListBox.GetItemObject: TObject;
begin
  if ItemIndex <> -1 then
    Result := Items.Objects[ItemIndex]
  else
    Result := nil;
end;

function TcxListBox.GetItems: TStrings;
begin
  Result := FInnerListBox.Items;
end;

function TcxListBox.GetListStyle: TListBoxStyle;
begin
  Result := FInnerListBox.Style;
end;

function TcxListBox.GetMultiSelect: Boolean;
begin
  Result := FInnerListBox.MultiSelect;
end;

function TcxListBox.GetReadOnly: Boolean;
begin
  Result := DataBinding.ReadOnly;
end;

function TcxListBox.GetSelCount: Integer;
begin
  Result := FInnerListBox.SelCount;
end;

function TcxListBox.GetSelected(Index: Integer): Boolean;
begin
  Result := FInnerListBox.Selected[Index];
end;

function TcxListBox.GetSorted: Boolean;
begin
  Result := FInnerListBox.Sorted;
end;

function TcxListBox.GetTopIndex: Integer;
begin
  Result := FInnerListBox.TopIndex;
end;

procedure TcxListBox.SetAutoComplete(Value: Boolean);
begin
  FInnerListBox.AutoComplete := Value;
end;

procedure TcxListBox.SetAutoCompleteDelay(Value: Cardinal);
begin
  FInnerListBox.AutoCompleteDelay := Value;
end;

procedure TcxListBox.SetColumns(Value: Integer);
begin
  FInnerListBox.Columns := Value;
  FInnerListBox.SetExternalScrollBarsParameters;
end;

procedure TcxListBox.SetExtendedSelect(Value: Boolean);
begin
  FInnerListBox.ExtendedSelect := Value;
end;

procedure TcxListBox.SetItemHeight(Value: Integer);
begin
  FInnerListBox.ItemHeight := Value;
end;

procedure TcxListBox.SetItemIndex(Value: Integer);
begin
  FInnerListBox.ItemIndex := Value;
end;

procedure TcxListBox.SetItemObject(Value: TObject);
begin
  ItemIndex := Items.IndexOfObject(Value);
end;

procedure TcxListBox.SetItems(Value: TStrings);
begin
  FInnerListBox.Items := Value;
  DataChange;
end;

procedure TcxListBox.SetListStyle(Value: TListBoxStyle);
begin
  FInnerListBox.Style := Value;
end;

procedure TcxListBox.SetMultiSelect(Value: Boolean);
begin
  FInnerListBox.MultiSelect := Value;
end;

procedure TcxListBox.SetOnMeasureItem(Value: TcxListBoxMeasureItemEvent);
begin
  FOnMeasureItem := Value;
  if Assigned(FOnMeasureItem) then
    FInnerListBox.OnMeasureItem := DoMeasureItem
  else
    FInnerListBox.OnMeasureItem := nil;
end;

procedure TcxListBox.SetReadOnly(Value: Boolean);
begin
  DataBinding.ReadOnly := Value;
end;

procedure TcxListBox.SetSelected(Index: Integer; Value: Boolean);
begin
  FInnerListBox.Selected[Index] := Value;
end;

procedure TcxListBox.SetSorted(Value: Boolean);
begin
  FInnerListBox.Sorted := Value;
end;

procedure TcxListBox.SetTopIndex(Value: Integer);
begin
  FInnerListBox.TopIndex := Value;
end;

  {$IFDEF DELPHI6}
function TcxListBox.GetOnData: TLBGetDataEvent;
begin
  Result := FInnerListBox.OnData;
end;

function TcxListBox.GetOnDataFind: TLBFindDataEvent;
begin
  Result := FInnerListBox.OnDataFind;
end;

function TcxListBox.GetOnDataObject: TLBGetDataObjectEvent;
begin
  Result := FInnerListBox.OnDataObject;
end;

procedure TcxListBox.SetCount(Value: Integer);
begin
  FInnerListBox.Count := Value;
end;

procedure TcxListBox.SetOnData(Value: TLBGetDataEvent);
begin
  FInnerListBox.OnData := Value;
end;

procedure TcxListBox.SetOnDataFind(Value: TLBFindDataEvent);
begin
  FInnerListBox.OnDataFind := Value;
end;

procedure TcxListBox.SetOnDataObject(Value: TLBGetDataObjectEvent);
begin
  FInnerListBox.OnDataObject := Value;
end;
  {$ENDIF}

function TcxListBox.GetScrollWidth: Integer;
begin
  Result := FInnerListBox.ScrollWidth;
end;

function TcxListBox.GetTabWidth: Integer;
begin
  Result := FInnerListBox.TabWidth;
end;

procedure TcxListBox.SetIntegralHeight(Value: Boolean);
begin
  if Value <> FIntegralHeight then
  begin
    FIntegralHeight := Value;
    SetSize;
  end;
end;

procedure TcxListBox.SetScrollWidth(Value: Integer);
begin
  FInnerListBox.ScrollWidth := Value;
end;

procedure TcxListBox.SetTabWidth(Value: Integer);
begin
  FInnerListBox.TabWidth := Value;
end;

end.
