
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

unit cxCheckListBox;

interface

{$I cxVer.inc}

uses
  Windows, Messages,
{$IFDEF DELPHI6}
  Types, Variants,
{$ENDIF}
  SysUtils, Classes, Controls, Graphics, StdCtrls, Forms, Math, ImgList,
  dxCore, cxClasses, cxControls, cxContainer, cxGraphics, cxVariants, cxDataUtils,
  cxEdit, cxListBox, cxCheckBox, cxExtEditConsts, cxExtEditUtils, cxScrollBar,
  cxLookAndFeels, cxLookAndFeelPainters;

type
  TcxCustomCheckListBox = class;
  TcxCustomInnerCheckListBox = class;
  TcxCheckListBoxItems = class;

  TcxCheckListBoxImageLayout = (ilBeforeChecks, ilAfterChecks);

  TcxClickCheckEvent = procedure(Sender: TObject; AIndex: Integer;
    APrevState, ANewState: TcxCheckBoxState) of object;

  TcxCheckStatesToEditValueEvent = procedure(Sender: TObject;
    const ACheckStates: TcxCheckStates; out AEditValue: TcxEditValue) of object;
  TcxEditValueToCheckStatesEvent = procedure(Sender: TObject;
    const AEditValue: TcxEditValue; var ACheckStates: TcxCheckStates) of object;

  { TcxCheckListBoxItem }

  TcxCheckListBoxItem = class(TCollectionItem)
  private
    FEnabled: Boolean;
    FImageIndex: TImageIndex;
    FItemObject: TObject;
    FState: TcxCheckBoxState;
    FTag: TcxTag;
    FText: TCaption;
    function GetChecked: Boolean;
    function GetCheckListBox: TcxCustomInnerCheckListBox;
    function GetCollection: TcxCheckListBoxItems;
    function IsTagStored: Boolean;
    procedure SetText(const Value: TCaption);
    procedure SetEnabled(Value: Boolean);
    procedure SetImageIndex(Value: TImageIndex);
    procedure SetState(Value: TcxCheckBoxState);
    procedure SetChecked(Value: Boolean);
  protected
    function GetDisplayName: string; override;
    property CheckListBox: TcxCustomInnerCheckListBox read GetCheckListBox;
    property Collection: TcxCheckListBoxItems read GetCollection;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    property Checked: Boolean read GetChecked write SetChecked;
    property ItemObject: TObject read FItemObject write FItemObject;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property ImageIndex: TImageIndex read FImageIndex write SetImageIndex default -1;
    property State: TcxCheckBoxState read FState write SetState default cbsUnchecked;
    property Tag: TcxTag read FTag write FTag stored IsTagStored;
    property Text: TCaption read FText write SetText;
  end;

  { TcxCheckListBoxItems }

  TcxCheckListBoxItems = class(TcxOwnedInterfacedCollection, IcxCheckItems)
  private
    FChangedLockCount: Integer;
    FCheckListBox: TcxCustomInnerCheckListBox;
    function GetItems(Index: Integer): TcxCheckListBoxItem;
    function GetObjects(Index: Integer): TObject;
    procedure SetItems(Index: Integer; const Value: TcxCheckListBoxItem);
    procedure SetObjects(Index: Integer; Value: TObject);

    // IcxCheckItems
    function IcxCheckItems.GetCaption = CheckItemsGetCaption;
    function IcxCheckItems.GetCount = CheckItemsGetCount;
    function CheckItemsGetCaption(Index: Integer): string;
    function CheckItemsGetCount: Integer;

  protected
    procedure Update(Item: TCollectionItem); override;
    function IsChangedLocked: Boolean;
    procedure LockChanged(ALock: Boolean; AInvokeChangedOnUnlock: Boolean = True);
  public
    constructor Create(AOwner: TcxCustomInnerCheckListBox;
      ItemClass: TCollectionItemClass);
    destructor Destroy; override;
    property CheckListBox: TcxCustomInnerCheckListBox read FCheckListBox;
    property Items[Index: Integer]: TcxCheckListBoxItem read GetItems write SetItems; default;
    function Add: TcxCheckListBoxItem;
    procedure Delete(Index: Integer);
    function IndexOf(const S: TCaption): Integer;
    function IndexOfObject(AObject: TObject): Integer;
    procedure LoadStrings(AStrings: TStrings);
    property Objects[Index: Integer]: TObject read GetObjects write SetObjects;
  end;

  { TcxCustomInnerCheckListBox }

  TcxCheckListBoxMetrics = record
    CheckFrameWidth: Integer;
    ContentOffset: Integer;
    ImageFrameWidth: Integer;
    TextAreaOffset: Integer;
    TextOffset: Integer;
    TextWidthCorrection: Integer;
  end;

  TcxCustomInnerCheckListBox = class(TcxCustomInnerListBox,
    IUnknown, IcxMouseTrackingCaller)
  private
    FAllowGrayed: Boolean;
    FAllowDblClickToggle: Boolean;
    FCapturedCheckIndex: Integer;
    FCheckItems: TcxCheckListBoxItems;
    FGlyph: TBitmap;
    FGlyphCount: Integer;
    FHotCheckIndex: Integer;
    FMetrics: TcxCheckListBoxMetrics;
    FNewPressedCheckIndex: Integer;
    FNewPressedCheckItemFullyVisible: Boolean;
    FPressedCheckIndex: Integer;
    FOnClickCheck: TcxClickCheckEvent;
    function GetContainer: TcxCustomCheckListBox;
    procedure DrawCheck(R: TRect; AState: TcxCheckBoxState;
      ACheckState: TcxEditCheckState);
    function GetGlyph: TBitmap;
    procedure GlyphChanged(Sender: TObject);
    procedure SetGlyph(Value: TBitmap);
    procedure SetGlyphCount(Value: Integer);
    procedure ToggleClickCheck(Index: Integer);
    procedure InvalidateCheck(Index: Integer);
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure CNDrawItem(var Message: TWMDrawItem); message CN_DRAWITEM;
    procedure CNMeasureItem(var Message: TWMMeasureItem); message CN_MEASUREITEM;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    // IcxMouseTrackingCaller
    procedure IcxMouseTrackingCaller.MouseLeave = MouseTrackingMouseLeave;
    procedure MouseTrackingMouseLeave;

    procedure AdjustItemHeight;
    procedure CheckHotTrack;
    procedure Click; override;
    function GetCheckAt(X, Y: Integer): Integer;
    procedure GetCheckMetrics(out ACheckSize: TSize;
      out ACheckBorderOffset: Integer);
    function GetCheckRect(const R: TRect; AReturnFullRect: Boolean): TRect;
    function GetCheckRegionWidth: Integer; virtual;
    function GetMetrics: TcxCheckListBoxMetrics; virtual;
    function GetStandardItemHeight: Integer; virtual;
    procedure InternalMouseMove(Shift: TShiftState; X, Y: Integer);
    procedure FullRepaint; virtual;
    procedure InvalidateItem(Index: Integer); virtual;
    procedure SynchronizeCheckStates(ANewHotCheckIndex, ANewPressedCheckIndex: Integer);
    procedure UpdateCheckStates;
    procedure UpdateEditValue;
    procedure WndProc(var Message: TMessage); override;
    procedure KeyPress(var Key: Char); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure DoClickCheck(const AIndex: Integer;
      const OldState, NewState: TcxCheckBoxState); virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DblClick; override;
    property AllowDblClickToggle: Boolean read FAllowDblClickToggle
      write FAllowDblClickToggle default True;
    property AllowGrayed: Boolean read FAllowGrayed write FAllowGrayed default False;
    property CheckItems: TcxCheckListBoxItems read FCheckItems write FCheckItems;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property GlyphCount: Integer read FGlyphCount write SetGlyphCount default 6;
    property Metrics: TcxCheckListBoxMetrics read FMetrics;
    property OnClickCheck: TcxClickCheckEvent read FOnClickCheck write FOnClickCheck;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    property Container: TcxCustomCheckListBox read GetContainer;
  published
    { Published declarations }
  end;

  TcxCustomInnerCheckListBoxClass = class of TcxCustomInnerCheckListBox;
  
  { TcxCustomCheckListBox }

  TcxCustomCheckListBox = class(TcxContainer)
  private
    FCheckBorderStyle: TcxEditCheckBoxBorderStyle;
    FEditValue: TcxEditValue;
    FEditValueFormat: TcxCheckStatesValueFormat;
    FImages: TCustomImageList;
    FImagesChangeLink: TChangeLink;
    FImageLayout: TcxCheckListBoxImageLayout;
    FInnerCheckListBox: TcxCustomInnerCheckListBox;
    FIntegralHeight: Boolean;
    FIsExitProcessing: Boolean;
    FIsModified: Boolean;
    FItemTextList: TStringList;
    FListStyle: TListBoxStyle;
    FNativeStyle: Boolean;
    FShowChecks: Boolean;
    FSorted: Boolean;
    FOnCheckStatesToEditValue: TcxCheckStatesToEditValueEvent;
    FOnDrawItem: TDrawItemEvent;
    FOnEditValueChanged: TNotifyEvent;
    FOnEditValueToCheckStates: TcxEditValueToCheckStatesEvent;
    FOnMeasureItem: TMeasureItemEvent;
    function GetOnClickCheck: TcxClickCheckEvent;
    function GetAllowGrayed: Boolean;
    function GetAllowDblClickToggle: Boolean;
    function GetAutoComplete: Boolean;
    function GetAutoCompleteDelay: Cardinal;
    function GetGlyph: TBitmap;
    function GetGlyphCount: Integer;
    function GetItemHeight: Integer;
    function GetItems: TcxCheckListBoxItems;
    function GetColumns: Integer;
    function GetCount: Integer;
    function GetItemIndex: Integer;
    function GetScrollWidth: Integer;
    function GetSelected(Index: Integer): Boolean;
    function GetTabWidth: Integer;
    function GetTopIndex: Integer;
    procedure ImagesChanged(Sender: TObject);
    function IsItemHeightStored: Boolean;
    procedure SetOnClickCheck(Value: TcxClickCheckEvent);
    procedure SetAllowGrayed(Value: Boolean);
    procedure SetAllowDblClickToggle(Value: Boolean);
    procedure SetAutoComplete(Value: Boolean);
    procedure SetAutoCompleteDelay(Value: Cardinal);
    procedure SetDataBinding(Value: TcxCustomDataBinding);
    procedure SetEditValueFormat(Value: TcxCheckStatesValueFormat);
    procedure SetGlyph(Value: TBitmap);
    procedure SetGlyphCount(Value: Integer);
    procedure SetItemHeight(Value: Integer);
    procedure SetItems(Value: TcxCheckListBoxItems);
    procedure SetColumns(Value: Integer);
    procedure SetImageLayout(Value: TcxCheckListBoxImageLayout);
    procedure SetIntegralHeight(Value: Boolean);
    procedure SetItemIndex(Value: Integer);
    procedure SetListStyle(Value: TListBoxStyle);
    procedure SetImages(Value: TCustomImageList);
    procedure SetScrollWidth(Value: Integer);
    procedure SetSelected(Index: Integer; Value: Boolean);
    procedure SetShowChecks(Value: Boolean);
    procedure SetSorted(Value: Boolean);
    procedure SetTabWidth(Value: Integer);
    procedure SetTopIndex(Value: Integer);
{$IFDEF DELPHI6}
    procedure SetCount(Value: Integer);
{$ENDIF}
    function GetReadOnly: Boolean;
    procedure SetReadOnly(Value: Boolean);

    procedure CheckEditValueFormat;
    procedure ItemsChanged(Sender: TObject; AItem: TCollectionItem);
  protected
    FDataBinding: TcxCustomDataBinding;
    procedure CalculateDrawCheckParams;
    procedure DoExit; override;
    function IsReadOnly: Boolean; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure Loaded; override;
    procedure LookAndFeelChanged(Sender: TcxLookAndFeel;
      AChangedValues: TcxLookAndFeelValues); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean; override;
    procedure FontChanged; override;
    procedure GetOptimalHeight(var ANewHeight: Integer);
    function IsInternalControl(AControl: TControl): Boolean; override;
    procedure SetSize; override;

    class function GetDataBindingClass: TcxCustomDataBindingClass; virtual;
    procedure DataChange; override;
    procedure UpdateData; override;
    procedure WndProc(var Message: TMessage); override;
    procedure DrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure DoEditValueChanged; virtual;
    function GetInnerCheckListBoxClass: TcxCustomInnerCheckListBoxClass; virtual;
    procedure SetEditValue(const Value: TcxEditValue); virtual;
    function IsValueValid(const AValue: TcxEditValue;
      AAllowEmpty: Boolean): Boolean; virtual;
    property AllowDblClickToggle: Boolean read GetAllowDblClickToggle
      write SetAllowDblClickToggle default True;
    property AllowGrayed: Boolean read GetAllowGrayed write SetAllowGrayed default False;
    property AutoComplete: Boolean read GetAutoComplete write SetAutoComplete
      default True;
    property AutoCompleteDelay: Cardinal read GetAutoCompleteDelay
      write SetAutoCompleteDelay default cxDefaultAutoCompleteDelay;
    property Columns: Integer read GetColumns write SetColumns default 0;
    property DataBinding: TcxCustomDataBinding read FDataBinding write SetDataBinding;
    property EditValue: TcxEditValue read FEditValue write SetEditValue
      stored False;
    property EditValueFormat: TcxCheckStatesValueFormat read FEditValueFormat
      write SetEditValueFormat default cvfInteger;
    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property GlyphCount: Integer read GetGlyphCount write SetGlyphCount default 6;
    property ImageLayout: TcxCheckListBoxImageLayout read FImageLayout
      write SetImageLayout default ilBeforeChecks;
    property IntegralHeight: Boolean read FIntegralHeight write SetIntegralHeight
       default False;
    property ItemHeight: Integer read GetItemHeight write SetItemHeight
      stored IsItemHeightStored;
    property ListStyle: TListBoxStyle read FListStyle write SetListStyle
      default lbStandard;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property ScrollWidth: Integer read GetScrollWidth write SetScrollWidth
      default 0;
    property ShowChecks: Boolean read FShowChecks write SetShowChecks
      default True;
    property Sorted: Boolean read FSorted write SetSorted default False;
    property TabWidth: Integer read GetTabWidth write SetTabWidth default 0;
    property OnCheckStatesToEditValue: TcxCheckStatesToEditValueEvent
      read FOnCheckStatesToEditValue write FOnCheckStatesToEditValue;
    property OnClickCheck: TcxClickCheckEvent read GetOnClickCheck write SetOnClickCheck;
    property OnDrawItem: TDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property OnEditValueChanged: TNotifyEvent read FOnEditValueChanged
      write FOnEditValueChanged;
    property OnEditValueToCheckStates: TcxEditValueToCheckStatesEvent
      read FOnEditValueToCheckStates write FOnEditValueToCheckStates;
    property OnMeasureItem: TMeasureItemEvent read FOnMeasureItem write FOnMeasureItem;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function CheckAtPos(const APos: TPoint): Integer;
    procedure Clear;
    function GetBestFitWidth: Integer;
    function GetHeight(ARowCount: Integer): Integer; virtual;
    function GetItemWidth(AIndex: Integer): Integer; virtual;
    function ItemAtPos(const APos: TPoint; AExisting: Boolean): Integer;
    function ItemRect(Index: Integer): TRect;
    procedure Sort;
{$IFDEF DELPHI6}
    procedure AddItem(AItem: string);
    procedure CopySelection(ADestination: TcxCustomCheckListBox);
    procedure DeleteSelected;
    procedure MoveSelection(ADestination: TcxCustomCheckListBox);
{$ENDIF}
    property InnerCheckListBox: TcxCustomInnerCheckListBox read FInnerCheckListBox write FInnerCheckListBox;
    { cxListBox properties }
    property Count: Integer read GetCount{$IFDEF DELPHI6} write SetCount{$ENDIF};
    property IsModified: Boolean read FIsModified write FIsModified;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property Selected[Index: Integer]: Boolean read GetSelected write SetSelected;
    property TopIndex: Integer read GetTopIndex write SetTopIndex;
// !!!
    property Images: TCustomImageList read FImages write SetImages;
    property Items: TcxCheckListBoxItems read GetItems write SetItems;
    property LookAndFeel;
  end;

  { TcxCheckListBox }

  TcxCheckListBox = class(TcxCustomCheckListBox)
  published
    property Align;
    property AllowDblClickToggle;
    property AllowGrayed;
    property Anchors;
    property AutoComplete;
    property AutoCompleteDelay;
    property BiDiMode;
    property Columns;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property EditValue;
    property EditValueFormat;
    property Enabled;
    property Glyph;
    property GlyphCount;
    property Images;
    property ImageLayout;
    property ImeMode;
    property ImeName;
    property IntegralHeight;
    property Items;
    property ParentBiDiMode;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ScrollWidth;
    property ShowChecks;
    property ShowHint;
    property Sorted;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property TabWidth;
    property Visible;
    property OnCheckStatesToEditValue;
    property OnClick;
    property OnClickCheck;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEditValueChanged;
    property OnEditValueToCheckStates;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem; // deprecated
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
{$IFDEF DELPHI6}
  RTLConsts,
{$ENDIF}
  Consts, cxEditPaintUtils, cxEditUtils, dxThemeManager;

const
  cxCheckListBoxCheckFrameWidth = 1;
  cxCheckListBoxContentOffset = 0;
  cxCheckListBoxImageFrameWidth = 1;
  cxCheckListBoxTextAreaOffset = 1;
  cxCheckListBoxTextOffset = 2;
  cxCheckListBoxTextWidthCorrection = 3;

{ TcxCheckListBoxItem }

constructor TcxCheckListBoxItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEnabled := True;
  FImageIndex := -1;
  FState := cbsUnchecked;
  FText := '';
end;

procedure TcxCheckListBoxItem.Assign(Source: TPersistent);
begin
  if Source is TcxCheckListBoxItem then
  begin
    Text := TcxCheckListBoxItem(Source).Text;
    Enabled := TcxCheckListBoxItem(Source).Enabled;
    ImageIndex := TcxCheckListBoxItem(Source).ImageIndex;
    ItemObject := TcxCheckListBoxItem(Source).ItemObject;
    State := TcxCheckListBoxItem(Source).State;
    Tag := TcxCheckListBoxItem(Source).Tag;
  end
  else
  inherited Assign(Source);
end;

function TcxCheckListBoxItem.GetDisplayName: string;
begin
  Result := Text;
  if Result = '' then
    Result := inherited GetDisplayName;
end;

function TcxCheckListBoxItem.GetChecked: Boolean;
begin
  Result := (State = cbsChecked);
end;

function TcxCheckListBoxItem.GetCheckListBox: TcxCustomInnerCheckListBox;
begin
  if Collection <> nil then
    Result := Collection.CheckListBox
  else
    Result := nil;
end;

function TcxCheckListBoxItem.GetCollection: TcxCheckListBoxItems;
begin
  Result := TcxCheckListBoxItems(inherited Collection);
end;

function TcxCheckListBoxItem.IsTagStored: Boolean;
begin
  Result := FTag <> 0;
end;

procedure TcxCheckListBoxItem.SetText(const Value: TCaption);
begin
  if InternalCompareString(Value, FText, True) then
    Exit;
  FText := Value;
  if (Collection <> nil) and (Collection.UpdateCount = 0) and (CheckListBox <> nil) then
  begin
    CheckListBox.Items[Index] := Value;
    Changed(CheckListBox.Container.Sorted);
  end;
end;

procedure TcxCheckListBoxItem.SetEnabled(Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    Changed(False);
  end;
end;

procedure TcxCheckListBoxItem.SetImageIndex(Value: TImageIndex);
begin
  if FImageIndex <> Value then
  begin
    FImageIndex := Value;
    Changed(False);
  end;
end;

procedure TcxCheckListBoxItem.SetState(Value: TcxCheckBoxState);
begin
  if CheckListBox <> nil then
  begin
    if (Value = cbsGrayed) and (CheckListBox.Container.EditValueFormat = cvfInteger) then
      Value := cbsUnchecked;
    if FState = Value then
      Exit;
    FState := Value;
    CheckListBox.InvalidateCheck(Index);
    if not Collection.IsChangedLocked then
      CheckListBox.UpdateEditValue;
  end
  else
    FState := Value;
end;

procedure TcxCheckListBoxItem.SetChecked(Value: Boolean);
begin
  if Value then
    State := cbsChecked
  else
    State := cbsUnchecked;
end;

{ TcxCheckListBoxItems }

constructor TcxCheckListBoxItems.Create(AOwner: TcxCustomInnerCheckListBox;
  ItemClass: TCollectionItemClass);
begin
  inherited Create(AOwner, ItemClass);
  FCheckListBox := AOwner;
end;

destructor TcxCheckListBoxItems.Destroy;
begin
  FCheckListBox := nil;
  inherited;
end;

function TcxCheckListBoxItems.GetItems(Index: Integer): TcxCheckListBoxItem;
begin
  Result := TcxCheckListBoxItem(inherited Items[Index]);
end;

function TcxCheckListBoxItems.GetObjects(Index: Integer): TObject;
begin
  Result := Items[Index].ItemObject;
end;

procedure TcxCheckListBoxItems.SetItems(Index: Integer;const Value: TcxCheckListBoxItem);
begin
  inherited Items[Index] := Value;
  if Assigned(CheckListBox) then
    CheckListBox.Items[Index] := Value.Text;
end;

procedure TcxCheckListBoxItems.SetObjects(Index: Integer; Value: TObject);
begin
  Items[Index].ItemObject := Value;
end;

// IcxCheckItems
function TcxCheckListBoxItems.CheckItemsGetCaption(Index: Integer): string;
begin
  Result := Items[Index].Text;
end;

function TcxCheckListBoxItems.CheckItemsGetCount: Integer;
begin
  Result := Count;
end;

procedure TcxCheckListBoxItems.Update(Item: TCollectionItem);

  procedure SynchronizeInnerListBoxItems;
  var
    I, ATopIndex, AItemIndex: Integer;
  begin
    CheckListBox.Items.BeginUpdate;
    try
      AItemIndex := CheckListBox.ItemIndex;
      ATopIndex := CheckListBox.TopIndex;

      CheckListBox.Items.Clear;

      for I := 0 to Count - 1 do
        CheckListBox.Items.Add(Items[I].Text);

      CheckListBox.TopIndex := ATopIndex;
      CheckListBox.ItemIndex := AItemIndex;
    finally
      CheckListBox.Items.EndUpdate;
    end;
  end;

begin
  inherited;
  if not Assigned(CheckListBox) then
    Exit;

  if (CheckListBox.Items.Count <> Count) or (Item = nil) then
  begin
    SynchronizeInnerListBoxItems;
    if CheckListBox.Container.Sorted then
      CheckListBox.Container.Sort;
  end
  else
    CheckListBox.InvalidateItem(Item.Index);

  if CheckListBox.Container.IsModified then
    CheckListBox.UpdateEditValue
  else
    CheckListBox.UpdateCheckStates;
end;

function TcxCheckListBoxItems.IsChangedLocked: Boolean;
begin
  Result := FChangedLockCount > 0;
end;

procedure TcxCheckListBoxItems.LockChanged(ALock: Boolean;
  AInvokeChangedOnUnlock: Boolean = True);
begin
  if ALock then
    Inc(FChangedLockCount)
  else
    if FChangedLockCount > 0 then
    begin
      Dec(FChangedLockCount);
      if AInvokeChangedOnUnlock and (FChangedLockCount = 0) then
        Changed;
    end;
end;

function TcxCheckListBoxItems.Add: TcxCheckListBoxItem;
begin
  Result := TcxCheckListBoxItem(inherited Add);
end;

procedure TcxCheckListBoxItems.Delete(Index: Integer);
begin
{$IFDEF DELPHI5}
  inherited Delete(Index);
{$ELSE}
  TcxCheckListBoxItem(Items[Index]).Free;
{$ENDIF}
end;

function TcxCheckListBoxItems.IndexOf(const S: TCaption): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if InternalCompareString(Items[I].Text, S, False) then
    begin
      Result := I;
      Break;
    end;
end;

function TcxCheckListBoxItems.IndexOfObject(AObject: TObject): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Objects[I] = AObject then
    begin
      Result := I;
      Break;
    end;
end;

procedure TcxCheckListBoxItems.LoadStrings(AStrings: TStrings);
var
  I: Integer;
begin
  AStrings.Clear;
  for I := 0 to Count - 1 do
    AStrings.Add(Items[I].Text);
end;

{ TcxCustomInnerCheckListBox }

constructor TcxCustomInnerCheckListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FContainer := TcxCustomCheckListBox(AOwner);
  FAllowGrayed := False;
  FAllowDblClickToggle := True;
  FCapturedCheckIndex := -1;
  FCheckItems := TcxCheckListBoxItems.Create(Self, TcxCheckListBoxItem);
  FGlyphCount := 6;
  FHotCheckIndex := -1;
  FPressedCheckIndex := -1;
  FNewPressedCheckIndex := -1;
  FMetrics := GetMetrics;
end;

destructor TcxCustomInnerCheckListBox.Destroy;
begin
  EndMouseTracking(Self);
  if Assigned(FGlyph) then FreeAndNil(FGlyph);
  FreeAndNil(FCheckItems);
  inherited Destroy;
end;

procedure TcxCustomInnerCheckListBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
    if Style and (LBS_OWNERDRAWFIXED or LBS_OWNERDRAWVARIABLE) = 0 then
      Style := Style or LBS_OWNERDRAWFIXED;
end;

procedure TcxCustomInnerCheckListBox.MouseTrackingMouseLeave;
begin
  InternalMouseMove([], -1, -1);
  EndMouseTracking(Self);
end;

procedure TcxCustomInnerCheckListBox.AdjustItemHeight;
begin
  if HandleAllocated then
  begin
    if Container.FListStyle = lbStandard then
      Perform(LB_SETITEMHEIGHT, 0, GetStandardItemHeight);
    SetExternalScrollBarsParameters;
    FullRepaint;
  end;
end;

procedure TcxCustomInnerCheckListBox.CheckHotTrack;
var
  P: TPoint;
begin
  P := ScreenToClient(InternalGetCursorPos);
  InternalMouseMove(InternalGetShiftState, P.X, P.Y);
end;

procedure TcxCustomInnerCheckListBox.Click;
begin
  if Container.ShowChecks or Container.DataBinding.SetEditMode then
    inherited Click;
end;

function TcxCustomInnerCheckListBox.GetCheckAt(X, Y: Integer): Integer;
var
  P: TPoint;
begin
  P := Point(X, Y);
  Result := ItemAtPos(P, True);
  if Result <> -1 then
    if not PtInRect(GetCheckRect(ItemRect(Result), False), P) then
      Result := -1;
end;

procedure TcxCustomInnerCheckListBox.GetCheckMetrics(out ACheckSize: TSize;
  out ACheckBorderOffset: Integer);
begin
  with Container do
  begin
    ACheckSize := GetEditCheckSize(Self.Canvas, Style.LookAndFeel.NativeStyle,
      Glyph, GlyphCount, Style.LookAndFeel.SkinPainter);
    ACheckBorderOffset := GetEditCheckBorderOffset(Style.LookAndFeel.Kind,
      FNativeStyle, VerifyBitmap(Glyph) and (GlyphCount > 0),
      LookAndFeel.SkinPainter);
  end;
end;

function TcxCustomInnerCheckListBox.GetCheckRect(const R: TRect;
  AReturnFullRect: Boolean): TRect;
var
  ACheckBorderOffset, ACheckOffset: Integer;
  ACheckSize: TSize;
begin
  if not Container.ShowChecks then
  begin
    Result := cxEmptyRect;
    Exit;
  end;

  GetCheckMetrics(ACheckSize, ACheckBorderOffset);
  ACheckSize.cx := ACheckSize.cx - ACheckBorderOffset * 2;
  ACheckSize.cy := ACheckSize.cy - ACheckBorderOffset * 2;

  ACheckOffset := Metrics.ContentOffset + Metrics.CheckFrameWidth;
  if (Container.ImageLayout = ilBeforeChecks) and VerifyImages(Container.Images) then
    Inc(ACheckOffset, Container.Images.Width + Metrics.ImageFrameWidth * 2);

  with R do
  begin
    Result.Top := Top + (Bottom - Top - ACheckSize.cy) div 2;
    Result.Bottom := Result.Top + ACheckSize.cy;
    if UseRightToLeftAlignment then
    begin
      Result.Right := Right - ACheckOffset;
      Result.Left := Result.Right - ACheckSize.cx;
    end
    else
    begin
      Result.Left := Left + ACheckOffset;
      Result.Right := Result.Left + ACheckSize.cx;
    end;
  end;
  if AReturnFullRect then
    InflateRect(Result, ACheckBorderOffset, ACheckBorderOffset);
end;

function TcxCustomInnerCheckListBox.GetCheckRegionWidth: Integer;
var
  ACheckBorderOffset: Integer;
  ACheckSize: TSize;
begin
  with Container do
  begin
    Result := Metrics.ContentOffset;
    if ShowChecks or VerifyImages(Images) then
      Inc(Result, Metrics.TextAreaOffset);
    if ShowChecks then
    begin
      GetCheckMetrics(ACheckSize, ACheckBorderOffset);
      ACheckSize.cx := ACheckSize.cx - ACheckBorderOffset * 2;
      Inc(Result, ACheckSize.cx + Metrics.CheckFrameWidth * 2);
    end;
    if VerifyImages(Images) then
      Inc(Result, Images.Width + Metrics.ImageFrameWidth * 2);
  end;
end;

function TcxCustomInnerCheckListBox.GetMetrics: TcxCheckListBoxMetrics;
begin
  Result.CheckFrameWidth := cxCheckListBoxCheckFrameWidth;
  Result.ContentOffset := cxCheckListBoxContentOffset;
  Result.ImageFrameWidth := cxCheckListBoxImageFrameWidth;
  Result.TextAreaOffset := cxCheckListBoxTextAreaOffset;
  Result.TextOffset := cxCheckListBoxTextOffset;
  Result.TextWidthCorrection := cxCheckListBoxTextWidthCorrection;
end;

function TcxCustomInnerCheckListBox.GetStandardItemHeight: Integer;
var
  ACheckBorderOffset: Integer;
  ACheckSize: TSize;
begin
  Canvas.Font := Font;
  Result := Canvas.TextHeight('Zg');
  with Container do
  begin
    if ShowChecks then
    begin
      GetCheckMetrics(ACheckSize, ACheckBorderOffset);
      ACheckSize.cy := ACheckSize.cy - ACheckBorderOffset * 2;
      if Result < ACheckSize.cy + Metrics.CheckFrameWidth * 2 then
        Result := ACheckSize.cy + Metrics.CheckFrameWidth * 2;
    end;
    if VerifyImages(Images) and (Result < Images.Height + Metrics.ImageFrameWidth * 2) then
      Result := Images.Height + Metrics.ImageFrameWidth * 2;
  end;
end;

procedure TcxCustomInnerCheckListBox.InternalMouseMove(Shift: TShiftState;
  X, Y: Integer);
var
  ANewHotCheckIndex, ANewPressedCheckIndex: Integer;
begin
  if FCapturedCheckIndex = -1 then
  begin
    if Shift = [] then
      ANewHotCheckIndex := GetCheckAt(X, Y)
    else
      ANewHotCheckIndex := FHotCheckIndex;
    ANewPressedCheckIndex := FPressedCheckIndex;
  end
  else
  begin
    ANewHotCheckIndex := -1;
    if GetCheckAt(X, Y) = FCapturedCheckIndex then
      ANewPressedCheckIndex := FCapturedCheckIndex
    else
      ANewPressedCheckIndex := -1;
  end;
  SynchronizeCheckStates(ANewHotCheckIndex, ANewPressedCheckIndex);
end;

procedure TcxCustomInnerCheckListBox.DblClick;
var
  P: TPoint;
begin
  inherited DblClick;
  if (ItemIndex <> -1) and CheckItems[ItemIndex].Enabled then
  begin
    P := ScreenToClient(InternalGetCursorPos);
    if (GetCheckAt(P.X, P.Y) <> -1) or AllowDblClickToggle then
      ToggleClickCheck(ItemIndex);
  end;
end;

function TcxCustomInnerCheckListBox.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    Container.FDataBinding.ExecuteAction(Action);
end;

function TcxCustomInnerCheckListBox.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or
    Container.FDataBinding.UpdateAction(Action);
end;

procedure TcxCustomInnerCheckListBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  AdjustItemHeight;
end;

procedure TcxCustomInnerCheckListBox.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  BeginMouseTracking(Self, GetControlRect(Self), Self);
end;

procedure TcxCustomInnerCheckListBox.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  InternalMouseMove([], -1, -1);
  EndMouseTracking(Self);
end;

function TcxCustomInnerCheckListBox.GetContainer: TcxCustomCheckListBox;
begin
  Result := TcxCustomCheckListBox(Owner);
end;

procedure TcxCustomInnerCheckListBox.FullRepaint;
var
  R: TRect;
begin
  if HandleAllocated then
  begin
    R := GetControlRect(Self);
    InvalidateRect(Handle, @R, True);
  end;
end;

procedure TcxCustomInnerCheckListBox.WMLButtonDown(var Message: TWMLButtonDown);
var
  R: TRect;
begin
  if Container.ShowChecks or Container.DataBinding.SetEditMode then
  begin
    FNewPressedCheckIndex := GetCheckAt(Message.XPos, Message.YPos);
    try
      if FNewPressedCheckIndex <> -1 then
      begin
        R := ItemRect(FNewPressedCheckIndex);
        FNewPressedCheckItemFullyVisible := R.Bottom <= ClientHeight;
        DragMode := dmManual;
      end;
      inherited;
    finally
      FNewPressedCheckIndex := -1;
      DragMode := Container.DragMode;
    end;
  end
  else
  begin
    SetFocus;
    with Message do
      MouseDown(mbLeft, KeysToShiftState(Keys), XPos, YPos);
  end;
end;

procedure TcxCustomInnerCheckListBox.CNDrawItem(var Message: TWMDrawItem);
var
  ADrawItemStruct: PDrawItemStruct;
begin
  if Items.Count = 0 then
    Exit;
  ADrawItemStruct := Message.DrawItemStruct;
  with ADrawItemStruct^ do
    if not UseRightToLeftAlignment then
      rcItem.Left := rcItem.Left + GetCheckRegionWidth
    else
      rcItem.Right := rcItem.Right - GetCheckRegionWidth;
  inherited;
end;

procedure TcxCustomInnerCheckListBox.CNMeasureItem(var Message: TWMMeasureItem);
begin
  if Container.FListStyle = lbStandard then
    Message.MeasureItemStruct.itemHeight := GetStandardItemHeight
  else
    inherited;
end;

procedure TcxCustomInnerCheckListBox.CMColorChanged(var Message: TMessage);
begin
  inherited;
  FullRepaint;
end;

procedure TcxCustomInnerCheckListBox.DrawCheck(R: TRect;
  AState: TcxCheckBoxState; ACheckState: TcxEditCheckState);

  function GetCheckBorderStyle: TcxEditCheckBoxBorderStyle;
  begin
    with Container do
      if not FNativeStyle and (FCheckBorderStyle = ebsFlat) and
          (ACheckState in [ecsHot, ecsPressed]) then
        Result := ebs3D
      else
        Result := FCheckBorderStyle;
  end;

begin
  if R.Top < 0 then
    Exit;    

  DrawEditCheck(Canvas, GetCheckRect(R, True), AState, ACheckState, Glyph,
    GlyphCount, GetCheckBorderStyle, Container.FNativeStyle, clBtnText, Color,
    True, Container.IsDesigning, False, True, LookAndFeel.SkinPainter);
end;

procedure TcxCustomInnerCheckListBox.InvalidateItem(Index: Integer);
var
  R: TRect;
begin
  R := ItemRect(Index);
  InvalidateRect(Handle, @R, True);
end;

procedure TcxCustomInnerCheckListBox.SynchronizeCheckStates(ANewHotCheckIndex,
  ANewPressedCheckIndex: Integer);
begin
  if ANewHotCheckIndex <> FHotCheckIndex then
  begin
    InvalidateCheck(FHotCheckIndex);
    FHotCheckIndex := ANewHotCheckIndex;
    InvalidateCheck(FHotCheckIndex);
  end;
  if ANewPressedCheckIndex <> FPressedCheckIndex then
  begin
    InvalidateCheck(FPressedCheckIndex);
    FPressedCheckIndex := ANewPressedCheckIndex;
    InvalidateCheck(FPressedCheckIndex);
  end;
end;

procedure TcxCustomInnerCheckListBox.UpdateCheckStates;
var
  I: Integer;
begin
  if Assigned(Container.FOnEditValueToCheckStates) then
  begin
    SetLength(CheckStates, Container.Items.Count);
    Container.FOnEditValueToCheckStates(Container, Container.EditValue,
      CheckStates);
  end
  else
    CalculateCheckStates(Container.EditValue, CheckItems,
      Container.EditValueFormat, CheckStates);
  CheckItems.LockChanged(True);
  try
    for I := 0 to CheckItems.Count - 1 do
      CheckItems[I].State := CheckStates[I];
  finally
    CheckItems.LockChanged(False, False);
  end;
end;

procedure TcxCustomInnerCheckListBox.UpdateEditValue;
var
  ANewEditValue: TcxEditValue;
  AEditValueChanged: Boolean;
  I: Integer;
begin
  SetLength(CheckStates, CheckItems.Count);
  for I := 0 to CheckItems.Count - 1 do
    CheckStates[I] := CheckItems[I].State;
  if Assigned(Container.FOnCheckStatesToEditValue) then
    Container.FOnCheckStatesToEditValue(Container, CheckStates, ANewEditValue)
  else
    ANewEditValue := CalculateCheckStatesValue(CheckStates, CheckItems,
      Container.EditValueFormat);

  if Assigned(Container.OnEditValueChanged) then
    AEditValueChanged := not InternalVarEqualsExact(Container.FEditValue, ANewEditValue)
  else
    AEditValueChanged := False;

  Container.FEditValue := ANewEditValue;
  Container.IsModified := True;

  if AEditValueChanged then
    Container.DoEditValueChanged;
end;

procedure TcxCustomInnerCheckListBox.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    WM_HSCROLL,
    WM_MOUSEWHEEL,
    WM_VSCROLL:
      CheckHotTrack;
  end;
end;

procedure TcxCustomInnerCheckListBox.InvalidateCheck(Index: Integer);
var
  R: TRect;
begin
  if not HandleAllocated then
    Exit;
  R := ItemRect(Index);
  R := GetCheckRect(R, False);
  InvalidateRect(Handle, @R, False);
end;

function TcxCustomInnerCheckListBox.GetGlyph: TBitmap;
begin
  if FGlyph = nil then
  begin
    FGlyph := TBitmap.Create;
    FGlyph.OnChange := GlyphChanged;
  end;
  Result := FGlyph;
end;

procedure TcxCustomInnerCheckListBox.GlyphChanged(Sender: TObject);
begin
  AdjustItemHeight;
end;

procedure TcxCustomInnerCheckListBox.SetGlyph(Value: TBitmap);
begin
  if Value = nil then
  begin
    FreeAndNil(FGlyph);
    AdjustItemHeight;
  end
  else
    Glyph.Assign(Value);
end;

procedure TcxCustomInnerCheckListBox.SetGlyphCount(Value: Integer);
begin
  if FGlyphCount <> Value then
  begin
    FGlyphCount := Value;
    if FGlyph <> nil then
      AdjustItemHeight;
  end;
end;

procedure TcxCustomInnerCheckListBox.KeyPress(var Key: Char);
begin
  if (Key = ' ') then
    ToggleClickCheck(ItemIndex);
  inherited KeyPress(Key);
end;

procedure TcxCustomInnerCheckListBox.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  ANewHotCheckIndex, ANewPressedCheckIndex: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    ANewPressedCheckIndex := FNewPressedCheckIndex;
    if (ANewPressedCheckIndex <> -1) and
      ((Container.DragMode = dmAutomatic) or not FNewPressedCheckItemFullyVisible) and
      CheckItems[ANewPressedCheckIndex].Enabled then
    begin
      ToggleClickCheck(ANewPressedCheckIndex);
      ANewPressedCheckIndex := -1;
    end;
  end
  else
    ANewPressedCheckIndex := -1;
  FCapturedCheckIndex := ANewPressedCheckIndex;
  ANewHotCheckIndex := -1;
  SynchronizeCheckStates(ANewHotCheckIndex, ANewPressedCheckIndex);
end;

procedure TcxCustomInnerCheckListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if (Container.DragMode = dmAutomatic) and (GetCaptureControl <> Self) then
  begin
    FCapturedCheckIndex := -1;
    SynchronizeCheckStates(FHotCheckIndex, -1);
  end;
  InternalMouseMove(Shift, X, Y);
  BeginMouseTracking(Self, GetControlRect(Self), Self);
end;

procedure TcxCustomInnerCheckListBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  ACheckIndex: Integer;
  ANewHotCheckIndex, ANewPressedCheckIndex: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  if (Button = mbLeft) and (Container.DragMode <> dmAutomatic) then
  begin
    ACheckIndex := GetCheckAt(X, Y);
    if (ACheckIndex = FPressedCheckIndex) and (ACheckIndex <> -1) and
      CheckItems[ACheckIndex].Enabled then
        ToggleClickCheck(ACheckIndex);
  end;
  FCapturedCheckIndex := -1;
  ANewPressedCheckIndex := -1;
  if Shift = [] then
    ANewHotCheckIndex := GetCheckAt(X, Y)
  else
    ANewHotCheckIndex := -1;
  SynchronizeCheckStates(ANewHotCheckIndex, ANewPressedCheckIndex);
end;

function TcxCustomInnerCheckListBox.DoMouseWheel(Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  CheckHotTrack;
end;

procedure TcxCustomInnerCheckListBox.ToggleClickCheck(Index: Integer);
var
  ANewState, APrevState: TcxCheckBoxState;
begin
  if (Index < 0) or (Index >= CheckItems.Count) or
      not CheckItems[Index].Enabled then
    Exit;
  if Container.Focused and not Container.DataBinding.SetEditMode then
    Exit;

  APrevState := CheckItems[Index].State;
  case APrevState of
    cbsUnchecked:
      if AllowGrayed and (Container.EditValueFormat <> cvfInteger) then
        ANewState := cbsGrayed
      else
        ANewState := cbsChecked;
    cbsGrayed: ANewState := cbsChecked;
    else
      ANewState := cbsUnchecked;
  end;
  CheckItems[Index].State := ANewState;
  DoClickCheck(Index, APrevState, ANewState);
end;

procedure TcxCustomInnerCheckListBox.DoClickCheck(const AIndex: Integer;
  const OldState, NewState: TcxCheckBoxState);
begin
  if Assigned(FOnClickCheck) then
    FOnClickCheck(Container, AIndex, OldState, NewState);
end;

{ TcxCustomCheckListBox }

constructor TcxCustomCheckListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEditValue := VarAsType(0, {$IFDEF DELPHI6}varInt64{$ELSE}varInteger{$ENDIF});
  FEditValueFormat := cvfInteger;

  FDataBinding := GetDataBindingClass.Create(Self, Self);
  FDataBinding.OnDataChange := Self.DataChange;
  FDataBinding.OnDataSetChange := Self.DataSetChange;
  FDataBinding.OnUpdateData := Self.UpdateData;

  FInnerCheckListBox := GetInnerCheckListBoxClass.Create(Self);
  FInnerCheckListBox.AutoSize := False;
  FInnerCheckListBox.BorderStyle := bsNone;
  FInnerCheckListBox.OnDrawItem := DrawItem;
  FInnerCheckListBox.Parent := Self;
  FInnerCheckListBox.LookAndFeel.MasterLookAndFeel := Style.LookAndFeel;
  FInnerCheckListBox.CheckItems.OnChange := ItemsChanged;

  InnerControl := FInnerCheckListBox;
  DataBinding.VisualControl := FInnerCheckListBox;
  Width := 121;
  Height := 97;

  FImageLayout := ilBeforeChecks;
  FIntegralHeight := False;
  FListStyle := lbStandard;
  FInnerCheckListBox.Style := lbOwnerDrawFixed;
  FShowChecks := True;
  CalculateDrawCheckParams;

  FImagesChangeLink := TChangeLink.Create;
  FImagesChangeLink.OnChange := ImagesChanged;
  FItemTextList := TStringList.Create;
end;

destructor TcxCustomCheckListBox.Destroy;
begin
  FreeAndNil(FItemTextList);
  FreeAndNil(FImagesChangeLink);
  FreeAndNil(FInnerCheckListBox);
  FreeAndNil(FDataBinding);
  inherited Destroy;
end;

function TcxCustomCheckListBox.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or
    FDataBinding.ExecuteAction(Action);
end;

function TcxCustomCheckListBox.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or FDataBinding.UpdateAction(Action);
end;

function TcxCustomCheckListBox.CheckAtPos(const APos: TPoint): Integer;
begin
  Result := FInnerCheckListBox.GetCheckAt(APos.X - FInnerCheckListBox.Left,
    APos.Y - FInnerCheckListBox.Top);
end;

procedure TcxCustomCheckListBox.Clear;
begin
  Items.Clear;
end;

function TcxCustomCheckListBox.GetBestFitWidth: Integer;
var
  AItemTextWidth, AMaxItemTextWidth: Integer;
  I: Integer;
begin
  with GetBorderExtent do
    Result := Left + Right;
  Inc(Result, FInnerCheckListBox.GetCheckRegionWidth +
    FInnerCheckListBox.Metrics.TextWidthCorrection);
  AMaxItemTextWidth := 0;
  for I := 0 to Items.Count - 1 do
  begin
    AItemTextWidth := FInnerCheckListBox.Canvas.TextWidth(Items[I].Text);
    if AItemTextWidth > AMaxItemTextWidth then
      AMaxItemTextWidth := AItemTextWidth;
  end;
  Inc(Result, AMaxItemTextWidth);
end;

function TcxCustomCheckListBox.GetHeight(ARowCount: Integer): Integer;
begin
  with GetBorderExtent do
    Result := FInnerCheckListBox.GetStandardItemHeight * ARowCount + Top + Bottom;
end;

function TcxCustomCheckListBox.GetItemWidth(AIndex: Integer): Integer;
begin
  with GetBorderExtent do
    Result := Left + Right;
  Inc(Result, FInnerCheckListBox.GetCheckRegionWidth +
    Canvas.TextWidth(Items[AIndex].Text) + FInnerCheckListBox.Metrics.TextWidthCorrection);
end;

function TcxCustomCheckListBox.ItemAtPos(const APos: TPoint; AExisting: Boolean): Integer;
begin
  Result := FInnerCheckListBox.ItemAtPos(
    Point(APos.X - FInnerCheckListBox.Left, APos.Y - FInnerCheckListBox.Top),
    AExisting);
end;

function TcxCustomCheckListBox.ItemRect(Index: Integer): TRect;
begin
  Result := FInnerCheckListBox.ItemRect(Index);
  OffsetRect(Result, FInnerCheckListBox.Left, FInnerCheckListBox.Top);
end;

procedure TcxCustomCheckListBox.Sort;

  procedure FillItemTextList;
  var
    ACount, I: Integer;
  begin
    ACount := FItemTextList.Count;
    if ACount > Items.Count then
      ACount := Items.Count;

    for I := 0 to ACount - 1 do
    begin
      FItemTextList[I] := Items[I].Text;
      FItemTextList.Objects[I] := Items[I];
    end;

    if ACount < Items.Count then
      for I := ACount to Items.Count - 1 do
        FItemTextList.AddObject(Items[I].Text, Items[I])
    else
      if ACount < FItemTextList.Count then
        for I := 1 to FItemTextList.Count - ACount do
          FItemTextList.Delete(FItemTextList.Count - 1);
  end;

var
  APrevSorted: Boolean;
  I: Integer;
begin
  APrevSorted := Sorted;
  FSorted := False;
  try
    FillItemTextList;
    FItemTextList.Sort;

    Items.BeginUpdate;
    try
      for I := 0 to FItemTextList.Count - 1 do
        TcxCheckListBoxItem(FItemTextList.Objects[I]).Index := I;
    finally
      Items.EndUpdate;
    end;
  finally
    FSorted := APrevSorted;
  end;
  InnerCheckListBox.FullRepaint;
end;

{$IFDEF DELPHI6}
procedure TcxCustomCheckListBox.AddItem(AItem: string);
var
  Item: TcxCheckListBoxItem;
begin
  Item := Items.Add;
  Item.Text := AItem;
end;

procedure TcxCustomCheckListBox.CopySelection(ADestination: TcxCustomCheckListBox);
begin
  if ItemIndex <> -1 then
    ADestination.AddItem(Items[ItemIndex].Text);
end;

procedure TcxCustomCheckListBox.DeleteSelected;
begin
  if ItemIndex <> -1 then
    Items.Delete(ItemIndex);
end;

procedure TcxCustomCheckListBox.MoveSelection(ADestination: TcxCustomCheckListBox);
begin
  CopySelection(ADestination);
  DeleteSelected;
end;

{$ENDIF}

procedure TcxCustomCheckListBox.CalculateDrawCheckParams;
const
  ABorderStyleMap: array[TcxLookAndFeelKind] of TcxEditCheckBoxBorderStyle =
    (ebsFlat, ebs3D, ebsUltraFlat, ebsOffice11);
begin
  with Style.LookAndFeel do
  begin
    FNativeStyle := NativeStyle and AreVisualStylesAvailable([totButton, totComboBox]);
    if not FNativeStyle then
      FCheckBorderStyle := ABorderStyleMap[Kind];
  end;
end;

procedure TcxCustomCheckListBox.DoExit;
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

function TcxCustomCheckListBox.IsReadOnly: Boolean;
begin
  Result := DataBinding.IsControlReadOnly;
end;

procedure TcxCustomCheckListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if not ShowChecks then
    case Key of
      VK_PRIOR, VK_NEXT, VK_END, VK_HOME, VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN:
        if not DataBinding.SetEditMode then
          Key := 0;
    end;
end;

procedure TcxCustomCheckListBox.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if Key = #27 then
    DataBinding.Reset
  else
    if IsTextChar(Key) and not ShowChecks and not DataBinding.SetEditMode then
      Key := #0;
end;

procedure TcxCustomCheckListBox.Loaded;
begin
  inherited Loaded;
  DataBinding.Reset;
  _TWinControlAccess._RecreateWnd(InnerCheckListBox);
end;

procedure TcxCustomCheckListBox.LookAndFeelChanged(Sender: TcxLookAndFeel;
  AChangedValues: TcxLookAndFeelValues);
begin
  CalculateDrawCheckParams;
  inherited LookAndFeelChanged(Sender, AChangedValues);
  if FInnerCheckListBox <> nil then
    FInnerCheckListBox.AdjustItemHeight;
end;

procedure TcxCustomCheckListBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FImages) then
    Images := nil;
end;

function TcxCustomCheckListBox.GetReadOnly: Boolean;
begin
  Result := DataBinding.ReadOnly;
end;

procedure TcxCustomCheckListBox.SetReadOnly(Value: Boolean);
begin
  DataBinding.ReadOnly := Value;
end;

procedure TcxCustomCheckListBox.CheckEditValueFormat;
begin
  if (EditValueFormat = cvfInteger) and (Items.Count > 64) then
    raise EdxException.Create(cxGetResourceString(@cxSCheckControlIncorrectItemCount));
end;

procedure TcxCustomCheckListBox.ItemsChanged(Sender: TObject; AItem: TCollectionItem);
begin
  CheckEditValueFormat;
end;

function TcxCustomCheckListBox.CanResize(var NewWidth, NewHeight: Integer): Boolean;
begin
  Result := inherited CanResize(NewWidth, NewHeight);
  if not Result or not IntegralHeight or IsLoading then
    Exit;
  if Align in [alLeft, alRight, alClient] then
    Exit;
  GetOptimalHeight(NewHeight);
  if NewHeight<20 then Exit;
end;

procedure TcxCustomCheckListBox.FontChanged;
begin
  inherited FontChanged;
  SetSize;
end;

procedure TcxCustomCheckListBox.DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);

  procedure PrepareColors(AIsItemEnabled: Boolean);
  begin
    if (odSelected in State) and not IsDesigning then
    begin
      FInnerCheckListBox.Canvas.Font.Color := clHighlightText;
      FInnerCheckListBox.Canvas.Brush.Color := clHighlight;
    end
    else
    begin
      FInnerCheckListBox.Canvas.Brush.Color := ViewInfo.BackgroundColor;
      FInnerCheckListBox.Canvas.Font.Color := ActiveStyle.GetVisibleFont.Color;
    end;
    if (not AIsItemEnabled) and not(odSelected in State) then
      FInnerCheckListBox.Canvas.Font.Color := StyleDisabled.TextColor;
  end;

  function GetCheckState(AIsItemEnabled: Boolean): TcxEditCheckState;
  begin
    if not AIsItemEnabled then
      Result := ecsDisabled
    else
      if FInnerCheckListBox.FHotCheckIndex = Index then
        Result := ecsHot
      else
        if FInnerCheckListBox.FPressedCheckIndex = Index then
          Result := ecsPressed
        else
          Result := ecsNormal;
  end;

  procedure DrawCheckRegion(const ACheckRegion: TRect; AIsItemEnabled: Boolean);

    function GetGlyphRect: TRect;
    var
      ACheckBorderOffset, AGlyphOffset: Integer;
      ACheckSize: TSize;
    begin
      AGlyphOffset := FInnerCheckListBox.Metrics.ContentOffset +
        FInnerCheckListBox.Metrics.ImageFrameWidth;
      if ShowChecks and (ImageLayout = ilAfterChecks) then
      begin
        FInnerCheckListBox.GetCheckMetrics(ACheckSize, ACheckBorderOffset);
        ACheckSize.cx := ACheckSize.cx - ACheckBorderOffset * 2;
        Inc(AGlyphOffset, ACheckSize.cx + FInnerCheckListBox.Metrics.CheckFrameWidth * 2);
      end;

      with ACheckRegion do
      begin
        Result.Top := Top + (Bottom - Top - Images.Height) div 2;
        Result.Bottom := Result.Top + Images.Height;
        if UseRightToLeftAlignment then
        begin
          Result.Right := Right - AGlyphOffset;
          Result.Left := Result.Right - Images.Width;
        end
        else
        begin
          Result.Left := Left + AGlyphOffset;
          Result.Right := Result.Left + Images.Width;
        end;
      end;
    end;

  var
    AImageIndex: Integer;
  begin
    if ShowChecks then
      FInnerCheckListBox.DrawCheck(ACheckRegion, Items[Index].State,
        GetCheckState(AIsItemEnabled));
    AImageIndex := Items[Index].ImageIndex;
    if VerifyImages(Images) and (AImageIndex <> -1) and (AImageIndex < Images.Count) then
      DrawGlyph(FInnerCheckListBox.Canvas, Images, Items[Index].ImageIndex,
      GetGlyphRect, Color, AIsItemEnabled);
  end;

const
  ADrawTextAlignmentFlags: array[Boolean] of LongWord = (DT_LEFT, DT_RIGHT);
var
  ABaseTestFlag: LongWord;
  ACheckRegion, ATextRect, ADrawEventRect: TRect;
  ADrawTextParams: DrawTextParams;
  AEnabled: Boolean;
  FText: string;
begin
  if Index < Items.Count then
  begin
    FInnerCheckListBox.Canvas.Font.Assign(ActiveStyle.GetVisibleFont);
    ACheckRegion := Rect;
    ATextRect := Rect;
    AEnabled := Enabled and Items[Index].Enabled;
    if not UseRightToLeftAlignment then
    begin
      Dec(ACheckRegion.Left, FInnerCheckListBox.GetCheckRegionWidth);
      Inc(ATextRect.Left, FInnerCheckListBox.Metrics.TextOffset);
    end
    else
    begin
      Inc(ACheckRegion.Right, FInnerCheckListBox.GetCheckRegionWidth);
      Dec(ATextRect.Right, FInnerCheckListBox.Metrics.TextOffset);
    end;
    DrawCheckRegion(ACheckRegion, AEnabled);
    PrepareColors(AEnabled);
    FInnerCheckListBox.Canvas.FillRect(Rect);
    FText := Items[Index].Text;
    SetBkMode(FInnerCheckListBox.Canvas.Handle, TRANSPARENT);
    PrepareColors(AEnabled);
    ABaseTestFlag := DT_NOPREFIX or DT_VCENTER or DT_SINGLELINE or
      ADrawTextAlignmentFlags[UseRightToLeftAlignment];
    if FInnerCheckListBox.TabWidth > 0 then
      ABaseTestFlag := ABaseTestFlag or DT_EXPANDTABS or DT_TABSTOP;
    with ADrawTextParams do
    begin
      cbSize := SizeOf(ADrawTextParams);
      iTabLength := FInnerCheckListBox.TabWidth;
      iLeftMargin := 0;
      iRightMargin := 0;
    end;
    Windows.DrawTextEx(FInnerCheckListBox.Canvas.Handle,
      PChar(FText), Length(FText), ATextRect,
      ABaseTestFlag, @ADrawTextParams);
    if odFocused in State then
      FInnerCheckListBox.Canvas.DrawFocusRect(Rect);
  end;
  ADrawEventRect := Rect;
  if Assigned(FOnDrawItem) then
    FOnDrawItem(Self, Index, ADrawEventRect, State);
end;

procedure TcxCustomCheckListBox.GetOptimalHeight(var ANewHeight: Integer);

  function GetItemHeight(AIndex: Integer): Integer;
  begin
    Result := FInnerCheckListBox.GetStandardItemHeight;
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

function TcxCustomCheckListBox.IsInternalControl(AControl: TControl): Boolean;
begin
  Result := (AControl = FInnerCheckListBox.HScrollBar) or (AControl = FInnerCheckListBox.VScrollBar) or
    inherited IsInternalControl(AControl);
end;

class function TcxCustomCheckListBox.GetDataBindingClass: TcxCustomDataBindingClass;
begin
  Result := TcxCustomDataBinding;
end;

procedure TcxCustomCheckListBox.DataChange;
begin
  if ShowChecks then
    EditValue := DataBinding.GetStoredValue(evsValue, Focused)
  else
    if DataBinding.IsDataSourceLive then
      ItemIndex := Items.IndexOf(VarToStr(DataBinding.GetStoredValue(evsText, Focused)))
    else
      ItemIndex := -1;
end;

procedure TcxCustomCheckListBox.UpdateData;
begin
  if ShowChecks then
    DataBinding.SetStoredValue(evsValue, EditValue)
  else
    if ItemIndex >= 0 then
      DataBinding.SetStoredValue(evsText, Items[ItemIndex].Text)
    else
      DataBinding.SetStoredValue(evsText, '');
end;

procedure TcxCustomCheckListBox.SetSize;
var
  ANewHeight: Integer;
begin
  if IsLoading then
    Exit;
// TODO
//  try
    if not IntegralHeight or (Align in [alLeft, alRight, alClient]) then
    begin
      inherited SetSize;
      Exit;
    end;
    ANewHeight := Height;
    GetOptimalHeight(ANewHeight);
    Height := ANewHeight;
    inherited SetSize;
//  finally
//    if FInnerCheckListBox.HandleAllocated then
//      KillMouseMoveMessages;
//  end;
end;

procedure TcxCustomCheckListBox.WndProc(var Message: TMessage);
begin
  if FInnerCheckListBox <> nil then
    case Message.Msg of
      LB_ADDSTRING .. LB_MSGMAX:
        begin
          with Message do
            Result := SendMessage(FInnerCheckListBox.Handle, Msg, WParam, LParam);
          Exit;
        end;
    end;
  inherited WndProc(Message);
  if (FInnerCheckListBox <> nil) and (Message.Msg = WM_COMMAND) and (Message.WParamHi = LBN_SELCHANGE) then
    FInnerCheckListBox.SetExternalScrollBarsParameters;
end;

function TcxCustomCheckListBox.GetOnClickCheck : TcxClickCheckEvent;
begin
  Result := FInnerCheckListBox.FOnClickCheck;
end;

function TcxCustomCheckListBox.GetAllowGrayed : Boolean;
begin
  Result := FInnerCheckListBox.FAllowGrayed;
end;

function TcxCustomCheckListBox.GetAllowDblClickToggle: Boolean;
begin
  Result := FInnerCheckListBox.AllowDblClickToggle;
end;

function TcxCustomCheckListBox.GetAutoComplete: Boolean;
begin
  Result := FInnerCheckListBox.AutoComplete;
end;

function TcxCustomCheckListBox.GetAutoCompleteDelay: Cardinal;
begin
  Result := FInnerCheckListBox.AutoCompleteDelay;
end;

function TcxCustomCheckListBox.GetGlyph: TBitmap;
begin
  Result := FInnerCheckListBox.Glyph;
end;

function TcxCustomCheckListBox.GetGlyphCount: Integer;
begin
  Result := FInnerCheckListBox.GlyphCount;
end;

function TcxCustomCheckListBox.GetItemHeight: Integer;
begin
  Result := FInnerCheckListBox.ItemHeight;
end;

function TcxCustomCheckListBox.GetItems: TcxCheckListBoxItems;
begin
  Result := FInnerCheckListBox.CheckItems;
end;

function TcxCustomCheckListBox.GetColumns: Integer;
begin
  Result := FInnerCheckListBox.Columns;
end;

function TcxCustomCheckListBox.GetCount: Integer;
begin
  Result := FInnerCheckListBox.Items.Count;
end;

function TcxCustomCheckListBox.GetItemIndex: Integer;
begin
  Result := FInnerCheckListBox.ItemIndex;
end;

function TcxCustomCheckListBox.GetScrollWidth: Integer;
begin
  Result := FInnerCheckListBox.ScrollWidth;
end;

function TcxCustomCheckListBox.GetSelected(Index: Integer): Boolean;
begin
  Result := FInnerCheckListBox.Selected[Index];
end;

function TcxCustomCheckListBox.GetTabWidth: Integer;
begin
  Result := FInnerCheckListBox.TabWidth;
end;

function TcxCustomCheckListBox.GetTopIndex: Integer;
begin
  Result := FInnerCheckListBox.TopIndex;
end;

procedure TcxCustomCheckListBox.ImagesChanged(Sender: TObject);
begin
  if FInnerCheckListBox <> nil then
    FInnerCheckListBox.AdjustItemHeight;
end;

function TcxCustomCheckListBox.IsItemHeightStored: Boolean;
begin
  Result := FListStyle <> lbStandard;
end;

procedure TcxCustomCheckListBox.SetOnClickCheck(Value: TcxClickCheckEvent);
begin
  FInnerCheckListBox.FOnClickCheck := Value;
end;

procedure TcxCustomCheckListBox.SetAllowGrayed(Value: Boolean);
begin
  FInnerCheckListBox.FAllowGrayed := Value;
end;

procedure TcxCustomCheckListBox.SetAllowDblClickToggle(Value: Boolean);
begin
  FInnerCheckListBox.AllowDblClickToggle := Value;
end;

procedure TcxCustomCheckListBox.SetAutoComplete(Value: Boolean);
begin
  FInnerCheckListBox.AutoComplete := Value;
end;

procedure TcxCustomCheckListBox.SetAutoCompleteDelay(Value: Cardinal);
begin
  FInnerCheckListBox.AutoCompleteDelay := Value;
end;

procedure TcxCustomCheckListBox.SetDataBinding(Value: TcxCustomDataBinding);
begin
  FDataBinding.Assign(Value);
end;

procedure TcxCustomCheckListBox.SetEditValueFormat(Value: TcxCheckStatesValueFormat);

  procedure ResetGrayedStates;
  var
    I: Integer;
  begin
    Items.LockChanged(True);
    try
      for I := 0 to Items.Count - 1 do
        if Items[I].State = cbsGrayed then
          Items[I].State := cbsUnchecked;
    finally
      Items.LockChanged(False, False);
    end;
  end;

begin
  if Value <> FEditValueFormat then
  begin
    FEditValueFormat := Value;
    if IsModified then
    begin
      if Value = cvfInteger then
        ResetGrayedStates;
      InnerCheckListBox.UpdateEditValue;
    end
    else
      InnerCheckListBox.UpdateCheckStates;
    CheckEditValueFormat;
  end;
end;

procedure TcxCustomCheckListBox.SetGlyph(Value: TBitmap);
begin
  FInnerCheckListBox.SetGlyph(Value);
end;

procedure TcxCustomCheckListBox.SetGlyphCount(Value: Integer);
begin
  FInnerCheckListBox.SetGlyphCount(Value);
end;

procedure TcxCustomCheckListBox.SetItemHeight(Value: Integer);
begin
  if FListStyle <> lbStandard then
    FInnerCheckListBox.ItemHeight := Value;
end;

procedure TcxCustomCheckListBox.SetItems(Value: TcxCheckListBoxItems);
begin
  FInnerCheckListBox.CheckItems.Assign(Value);
  DataChange;
end;

procedure TcxCustomCheckListBox.SetColumns(Value: Integer);
begin
  FInnerCheckListBox.Columns := Value;
{$IFDEF DELPHI5}
  //FInnerCheckListBox.SetExternalScrollBarsParameters; {<- Release 4.2.1}
{$ENDIF}
end;

procedure TcxCustomCheckListBox.SetImageLayout(Value: TcxCheckListBoxImageLayout);
begin
  if Value <> FImageLayout then
  begin
    FImageLayout := Value;
    FInnerCheckListBox.FullRepaint;
  end;
end;

procedure TcxCustomCheckListBox.SetIntegralHeight(Value: Boolean);
begin
  if Value <> FIntegralHeight then
  begin
    FIntegralHeight := Value;
    SetSize;
  end;
end;

procedure TcxCustomCheckListBox.SetItemIndex(Value: Integer);
begin
  FInnerCheckListBox.ItemIndex := Value;
end;

procedure TcxCustomCheckListBox.SetListStyle(Value: TListBoxStyle);
begin
  if Value <> FListStyle then
  begin
    FListStyle := Value;
    if Value = lbStandard then
      Value := lbOwnerDrawFixed;
    with FInnerCheckListBox do
      if Style = Value then
        RecreateWnd
      else
        Style := Value;
  end;
end;

procedure TcxCustomCheckListBox.SetImages(Value: TCustomImageList);
begin
  cxSetImageList(Value, FImages, FImagesChangeLink, Self);
end;

procedure TcxCustomCheckListBox.SetScrollWidth(Value: Integer);
begin
  FInnerCheckListBox.ScrollWidth := Value;
end;

procedure TcxCustomCheckListBox.SetSelected(Index: Integer; Value: Boolean);
begin
{$IFNDEF DELPHI6}
  if not InnerCheckListBox.MultiSelect then
  begin
    if Selected[Index] <> Value then
      if Value then
        ItemIndex := Index
      else
        ItemIndex := -1;
  end
  else
{$ENDIF}
    InnerCheckListBox.Selected[Index] := Value;
end;

procedure TcxCustomCheckListBox.SetShowChecks(Value: Boolean);
begin
  if Value <> FShowChecks then
  begin
    FShowChecks := Value;
    FInnerCheckListBox.AdjustItemHeight;
    DataBinding.Reset;
  end;
end;

procedure TcxCustomCheckListBox.SetSorted(Value: Boolean);
begin
  if Value <> FSorted then
  begin
    FSorted := Value;
    if Value then
      Sort;
  end;
end;

procedure TcxCustomCheckListBox.SetTabWidth(Value: Integer);
begin
  FInnerCheckListBox.TabWidth := Value;
end;

procedure TcxCustomCheckListBox.SetTopIndex(Value: Integer);
begin
  FInnerCheckListBox.TopIndex := Value;
end;

{$IFDEF DELPHI6}
procedure TcxCustomCheckListBox.SetCount(Value: Integer);
begin
  FInnerCheckListBox.Count := Value;
end;
{$ENDIF}

procedure TcxCustomCheckListBox.DoEditValueChanged;
begin
  if Assigned(FOnEditValueChanged) then
    FOnEditValueChanged(Self);
end;

function TcxCustomCheckListBox.GetInnerCheckListBoxClass: TcxCustomInnerCheckListBoxClass;
begin
  Result := TcxCustomInnerCheckListBox;
end;

function TcxCustomCheckListBox.IsValueValid(const AValue: Variant;
  AAllowEmpty: Boolean): Boolean;
begin
  Result := False;
  if (IsVarEmpty(AValue) and AAllowEmpty) or VarIsNumericEx(AValue) then
    Result := True
  else
    if VarIsStr(AValue) then
      Result := IsValidStringForInt(VarToStr(AValue)) or
        IsValidStringForDouble(VarToStr(AValue));
end;

procedure TcxCustomCheckListBox.SetEditValue(const Value: TcxEditValue);
var
  AEditValueChanged: Boolean;
begin
  IsModified := False;

  if Assigned(FOnEditValueChanged) then
    AEditValueChanged := not InternalVarEqualsExact(Value, FEditValue)
  else
    AEditValueChanged := False;

  FEditValue := Value;
  InnerCheckListBox.UpdateCheckStates;

  if AEditValueChanged then
    FOnEditValueChanged(Self);
end;

end.
