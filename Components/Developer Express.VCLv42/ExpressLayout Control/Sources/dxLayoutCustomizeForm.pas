
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl customize form                      }
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

unit dxLayoutCustomizeForm;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, dxLayoutControl, StdCtrls, dxLayoutLookAndFeels, cxControls;

type
  TLayoutCustomizeFormClass = class of TLayoutCustomizeForm;

  TLayoutCustomizeForm = class(TForm)
    LayoutControl: TdxLayoutControl;
    pcMain: TPageControl;
    LayoutControlItem1: TdxLayoutItem;
    tshItems: TTabSheet;
    tshGroups: TTabSheet;
    lcItems: TdxLayoutControl;
    lbItems: TListBox;
    lcItemsItem1: TdxLayoutItem;
    lcGroups: TdxLayoutControl;
    lbGroups: TListBox;
    lcGroupsItem1: TdxLayoutItem;
    btnGroupsCreate: TButton;
    lcGroupsItem4: TdxLayoutItem;
    btnGroupsDelete: TButton;
    lcGroupsItem2: TdxLayoutItem;
    lcGroupsGroup1: TdxLayoutGroup;
    LookAndFeels: TdxLayoutLookAndFeelList;
    lfStandard: TdxLayoutStandardLookAndFeel;
    LayoutControlGroup_Root: TdxLayoutGroup;
    lcGroupsGroup_Root: TdxLayoutGroup;
    lcItemsGroup_Root: TdxLayoutGroup;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbGroupsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbGroupsMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure lbItemsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lbItemsMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure lbGroupsClick(Sender: TObject);
    procedure btnGroupsCreateClick(Sender: TObject);
    procedure btnGroupsDeleteClick(Sender: TObject);
  private
    FControl: TdxCustomLayoutControl;
    FOriginalBoundsRect: TRect;
    procedure CalculateBounds;
  protected
    procedure CreateParams(var Params: TCreateParams); override;

    procedure AssignCaptions; virtual;
    procedure CheckGroupsButtons; virtual;
    procedure FillGroupsListBox; virtual;
    procedure FillItemsListBox; virtual;
    procedure FillListBox(AListBox: TCustomListBox; AFillWithGroups: Boolean); virtual;
    function GetGroupsItemHeight: Integer; virtual;
    function GetItemsItemHeight: Integer; virtual;
    function IsItemVisibleInListBox(AItem: TdxCustomLayoutItem): Boolean; virtual;

    property Control: TdxCustomLayoutControl read FControl;
  public
    constructor Create(AControl: TdxCustomLayoutControl); reintroduce; virtual;
    destructor Destroy; override;
    procedure AvailableItemListChanged(AItem: TdxCustomLayoutItem;
      AIsItemAdded: Boolean); virtual;
    procedure DragAndDropBegan; virtual;
  end;

resourcestring
  dxLayoutCustomizeFormCaption = 'Customize';
  dxLayoutCustomizeFormItemsCaption = 'Items';
  dxLayoutCustomizeFormGroupsCaption = 'Groups';
  dxLayoutCustomizeFormGroupsCreateCaption = 'Create...';
  dxLayoutCustomizeFormGroupsDeleteCaption = 'Delete';

implementation

{$R *.DFM}

uses
  cxClasses, dxLayoutCommon, dxLayoutEditForm;

type
  TLayoutControlAccess = class(TdxCustomLayoutControl);

{ TLayoutCustomizeForm }

constructor TLayoutCustomizeForm.Create(AControl: TdxCustomLayoutControl);

  procedure ReplaceListBox(var AControl: TListBox; AItem: TdxLayoutItem);
  var
    AListBox: TListBox;
  begin
    AListBox := TdxLayoutCustomizeListBox.Create(Owner);
    TdxLayoutCustomizeListBox(AListBox).Control := FControl;
    AListBox.Style := AControl.Style;
    AListBox.OnClick := AControl.OnClick;
    AListBox.OnDrawItem := AControl.OnDrawItem;
    AListBox.OnMeasureItem := AControl.OnMeasureItem;

    AItem.Control := AListBox;
    AItem.ControlOptions.AutoColor := True;

    AControl.Free;
    AControl := AListBox;
  end;

begin
  FControl := AControl;
  inherited Create(nil);
{$IFDEF DELPHI7}
  LayoutControl.ParentBackground := True;
  lcItems.ParentBackground := True;
  lcGroups.ParentBackground := True;
{$ENDIF}
  AssignCaptions;

  ReplaceListBox(lbItems, lcItemsItem1);
  lbItems.ItemHeight := GetItemsItemHeight;
  ReplaceListBox(lbGroups, lcGroupsItem1);
  lbGroups.ItemHeight := GetGroupsItemHeight;

  CalculateBounds;
  FOriginalBoundsRect := BoundsRect;

  AvailableItemListChanged(nil, False);
end;

destructor TLayoutCustomizeForm.Destroy;
var
  R: TRect;
begin
  R := BoundsRect;
  if not CompareMem(@R, @FOriginalBoundsRect, SizeOf(TRect)) then
    FControl.CustomizeFormBounds := R;
  FControl.Customization := False;
  inherited;
end;

procedure TLayoutCustomizeForm.CalculateBounds;
var
  R: TRect;
begin
  R := BoundsRect;
  with TLayoutControlAccess(FControl) do
    if IsRectEmpty(CustomizeFormBounds) then
      R := CalculateCustomizeFormBounds(R)
    else
      R := CustomizeFormBounds;
  BoundsRect := R;
end;

procedure TLayoutCustomizeForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := FControl.Handle;
end;

procedure TLayoutCustomizeForm.AssignCaptions;
begin
  Caption := cxGetResourceString(@dxLayoutCustomizeFormCaption);
  tshItems.Caption := cxGetResourceString(@dxLayoutCustomizeFormItemsCaption);
  tshGroups.Caption := cxGetResourceString(@dxLayoutCustomizeFormGroupsCaption);
  btnGroupsCreate.Caption := cxGetResourceString(@dxLayoutCustomizeFormGroupsCreateCaption);
  btnGroupsDelete.Caption := cxGetResourceString(@dxLayoutCustomizeFormGroupsDeleteCaption);
end;

procedure TLayoutCustomizeForm.CheckGroupsButtons;
begin              
  with TdxLayoutCustomizeListBox(lbGroups) do
    btnGroupsDelete.Enabled :=
      (ItemObject <> nil) and TdxLayoutGroup(ItemObject).IsUserDefined;
end;

procedure TLayoutCustomizeForm.FillGroupsListBox;
begin
  FillListBox(lbGroups, True);
  CheckGroupsButtons;
end;

procedure TLayoutCustomizeForm.FillItemsListBox;
begin
  FillListBox(lbItems, False);
end;

procedure TLayoutCustomizeForm.FillListBox(AListBox: TCustomListBox;
  AFillWithGroups: Boolean);
var
  AItemIndex, I: Integer;
  AItem: TdxCustomLayoutItem;
begin
  with AListBox, Items do
  begin
    AItemIndex := ItemIndex;
    BeginUpdate;
    try
      Clear;
      for I := 0 to Control.AvailableItemCount - 1 do
      begin
        AItem := Control.AvailableItems[I];
        if (AFillWithGroups and (AItem is TdxLayoutGroup) or
          not AFillWithGroups and (AItem is TdxLayoutItem)) and
          IsItemVisibleInListBox(AItem) then
          AddObject(AItem.CaptionForCustomizeForm, AItem);
      end;
      if AItemIndex < Count then
        ItemIndex := AItemIndex
      else
        ItemIndex := Count - 1;
    finally
      EndUpdate;
    end;
  end;
end;

function TLayoutCustomizeForm.GetGroupsItemHeight: Integer;
begin
  Result := lbGroups.Canvas.TextHeight('Qq') + 5 + 5;
end;

function TLayoutCustomizeForm.GetItemsItemHeight: Integer;
begin
  Result := lbItems.Canvas.TextHeight('Qq') + 4 + 4;;
end;

type
  TdxCustomLayoutItemAccess = class(TdxCustomLayoutItem);

function TLayoutCustomizeForm.IsItemVisibleInListBox(AItem: TdxCustomLayoutItem): Boolean;
begin
  Result := TdxCustomLayoutItemAccess(AItem).GetVisible;
end;

procedure TLayoutCustomizeForm.AvailableItemListChanged(AItem: TdxCustomLayoutItem;
  AIsItemAdded: Boolean);

  function GetListBox: TListBox;
  begin
    if AItem is TdxLayoutItem then
      Result := lbItems
    else
      Result := lbGroups;
  end;

begin
  if (AItem = nil) or (AItem is TdxLayoutGroup) then
    FillGroupsListBox;
  if (AItem = nil) or (AItem is TdxLayoutItem) then
    FillItemsListBox;
  if AIsItemAdded then
    TdxLayoutCustomizeListBox(GetListBox).ItemObject := AItem;
end;

procedure TLayoutCustomizeForm.DragAndDropBegan;
begin
  if TdxLayoutControlDragAndDropObject(Control.DragAndDropObject).SourceItem is TdxLayoutItem then
    pcMain.ActivePage := tshItems
  else
    pcMain.ActivePage := tshGroups;
end;

procedure TLayoutCustomizeForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TLayoutCustomizeForm.lbGroupsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with TCustomListBox(Control), Canvas do
  begin
    DrawEdge(Handle, Rect, BDR_RAISEDINNER, BF_RECT);
    if odFocused in State then DrawFocusRect(Rect);
    InflateRect(Rect, -1, -1);
    TextRect(Rect, Rect.Left + 4, Rect.Top + 4, Items[Index]);
  end;
end;

procedure TLayoutCustomizeForm.lbGroupsMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  Height := TCustomListBox(Control).Canvas.TextHeight('Qq') + 5 + 5;
end;

procedure TLayoutCustomizeForm.lbItemsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  ABrushColor: TColor;
begin
  with TCustomListBox(Control), Canvas do
  begin
    TextRect(Rect, Rect.Left + 4, Rect.Top + 4, Items[Index]);
    if odFocused in State then DrawFocusRect(Rect);

    Inc(Rect.Left, 4 + TextWidth(Items[Index]));
    InflateRect(Rect, -4, -2);
    if Rect.Right - Rect.Left > 0 then
    begin
      ABrushColor := Brush.Color;
      Brush.Color := Font.Color;
      FrameRect(Rect);
      InflateRect(Rect, -1, -1);
      Brush.Style := bsBDiagonal;
      SetBkColor(Handle, ColorToRGB(ABrushColor));
      FillRect(Rect);
      Brush.Style := bsSolid;
    end;
  end;
end;

procedure TLayoutCustomizeForm.lbItemsMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  Height := TCustomListBox(Control).Canvas.TextHeight('Qq') + 4 + 4;
end;

procedure TLayoutCustomizeForm.lbGroupsClick(Sender: TObject);
begin
  CheckGroupsButtons;
end;

procedure TLayoutCustomizeForm.btnGroupsCreateClick(Sender: TObject);
var
  AGroupCaption: string;
  AGroup: TdxLayoutGroup;
begin
  AGroupCaption := cxGetResourceString(@dxLayoutNewGroupCaption);
  if TLayoutEditForm.Run(cxGetResourceString(@dxLayoutNewGroupDialogCaption),
    cxGetResourceString(@dxLayoutNewGroupDialogEditCaption), AGroupCaption) then
  begin
    AGroup := Control.CreateGroup;
    AGroup.Caption := AGroupCaption;
    FillGroupsListBox;
    TdxLayoutCustomizeListBox(lbGroups).ItemObject := AGroup;
  end;  
end;

procedure TLayoutCustomizeForm.btnGroupsDeleteClick(Sender: TObject);
var
  I: Integer;
begin
  with TdxLayoutGroup(TdxLayoutCustomizeListBox(lbGroups).ItemObject) do
  begin
    for I := Count - 1 downto 0 do
      Items[I].Parent := nil;
    Free;
  end;
end;

end.
