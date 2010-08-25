
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl design-time form                    }
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

unit dxLayoutDesignForm;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  {$IFDEF DELPHI6}DesignIntf, DesignWindows,{$ELSE}DsgnIntf, DsgnWnds,{$ENDIF}
  StdCtrls, Menus, cxControls, dxLayoutControl, dxLayoutLookAndFeels, dxLayoutDesignCommon;

type
  TDesignForm = class(TdxLayoutDesignForm)
    lcMain: TdxLayoutControl;
    lbItems: TListBox;
    dxLayoutControl1Item1: TdxLayoutItem;
    btnAddGroup: TButton;
    dxLayoutControl1Item2: TdxLayoutItem;
    btnAddItem: TButton;
    dxLayoutControl1Item3: TdxLayoutItem;
    btnDelete: TButton;
    dxLayoutControl1Item4: TdxLayoutItem;
    btnClose: TButton;
    dxLayoutControl1Item5: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    lflMain: TdxLayoutLookAndFeelList;
    lfStandard: TdxLayoutStandardLookAndFeel;
    lcMainGroup1: TdxLayoutGroup;
    lcMainItem2: TdxLayoutItem;
    lcMainItem3: TdxLayoutItem;
    lfStandardBtnFace: TdxLayoutStandardLookAndFeel;
    lfStandardBoldItalic: TdxLayoutStandardLookAndFeel;
    lfStandardLegend: TdxLayoutStandardLookAndFeel;
    btnAlign: TButton;
    lcMainItem1: TdxLayoutItem;
    pmAlign: TPopupMenu;
    Left1: TMenuItem;
    Right1: TMenuItem;
    op1: TMenuItem;
    Bottom1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    None1: TMenuItem;
    chbShowHiddenGroupsBounds: TCheckBox;
    lcMainItem4: TdxLayoutItem;
    procedure btnCloseClick(Sender: TObject);
    procedure lbItemsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnAddGroupClick(Sender: TObject);
    procedure btnAddItemClick(Sender: TObject);
    procedure btnAlignClick(Sender: TObject);
    procedure pmAlignItemClick(Sender: TObject);
    procedure chbShowHiddenGroupsBoundsClick(Sender: TObject);
    procedure lcMainItem4CaptionClick(Sender: TObject);
  private
    FOriginalBoundsRect: TRect;
    function GetControl: TdxCustomLayoutControl;
    procedure CalculateBounds;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    function GetAddItemsButton(AIndex: Integer): TButton; override;
    function GetAddItemsButtonCount: Integer; override;
    function GetDeleteItemsButton: TButton; override;
    function GetItemsListBox: TListBox; override;
    function NeedRefreshItemsAfterDeleting(AComponent: TPersistent): Boolean; override;
    procedure SetComponent(Value: TComponent); override;

    procedure RefreshEnableds; override;
    procedure RefreshItemsListBox; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Control: TdxCustomLayoutControl read GetControl;
  end;

implementation

{$R *.DFM}

uses
  cxClasses, dxLayoutCommon, dxLayoutEditForm;

type
  TControlAccess = class(TControl);
  TLayoutControlAccess = class(TdxCustomLayoutControl);

constructor TDesignForm.Create(AOwner: TComponent);
var
  AListBox: TdxLayoutCustomizeListBox;
begin
  inherited;
  AListBox := TdxLayoutCustomizeListBox.Create(Self);
  AListBox.BoundsRect := lbItems.BoundsRect;
  AListBox.MultiSelect := lbItems.MultiSelect;
  AListBox.Style := lbItems.Style;
  AListBox.OnDrawItem := lbItems.OnDrawItem;

  dxLayoutControl1Item1.Control := AListBox;
  lbItems.Free;
  lbItems := AListBox;
  ActiveControl := lbItems;
end;

destructor TDesignForm.Destroy;
var
  R: TRect;
begin
  TLayoutControlAccess(Control).IsCustomizationMode := False;
  R := BoundsRect;
  if not CompareMem(@R, @FOriginalBoundsRect, SizeOf(TRect)) then
    TLayoutControlAccess(Control).DesignFormBounds := R;
  inherited;
end;

function TDesignForm.GetControl: TdxCustomLayoutControl;
begin
  Result := TdxCustomLayoutControl(Component);
end;

procedure TDesignForm.CalculateBounds;
var
  R: TRect;
begin
  R := BoundsRect;
  with TLayoutControlAccess(Control) do
    if IsRectEmpty(DesignFormBounds) then
      R := CalculateCustomizeFormBounds(R)
    else
      R := DesignFormBounds;
  BoundsRect := R;
end;

procedure TDesignForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  if Control <> nil then
    Params.WndParent := Control.Handle;
end;

function TDesignForm.GetAddItemsButton(AIndex: Integer): TButton;
begin
  if AIndex = 0 then
    Result := btnAddGroup
  else
    Result := btnAddItem;
end;

function TDesignForm.GetAddItemsButtonCount: Integer;
begin
  Result := 2;
end;

function TDesignForm.GetDeleteItemsButton: TButton;
begin
  Result := btnDelete;
end;

function TDesignForm.GetItemsListBox: TListBox;
begin
  Result := lbItems;
end;

function TDesignForm.NeedRefreshItemsAfterDeleting(AComponent: TPersistent): Boolean;
begin
  Result := inherited NeedRefreshItemsAfterDeleting(AComponent) and
    (AComponent is TdxCustomLayoutItem) and
    (TdxCustomLayoutItem(AComponent).Container = Control);
end;

procedure TDesignForm.SetComponent(Value: TComponent);
begin
  inherited;
  with TLayoutControlAccess(Control) do
  begin
    IsCustomizationMode := True;
    CustomizationModeForm := Self;
  end;

  TdxLayoutCustomizeListBox(lbItems).Control := Control;
  chbShowHiddenGroupsBounds.Checked := Control.ShowHiddenGroupsBounds;

  CalculateBounds;
  FOriginalBoundsRect := BoundsRect;

  RecreateWnd;
end;

function CompareItems(Item1, Item2: Pointer): Integer;
var
  AName1, AName2: TComponentName;
begin
  AName1 := TComponent(Item1).Name;
  AName2 := TComponent(Item2).Name;
  Result := Length(AName1) - Length(AName2);
  if Result = 0 then
    Result := CompareText(AName1, AName2);
end;

procedure TDesignForm.RefreshEnableds;
var
  ASelections: TDesignerSelectionListAccess;
begin
  inherited;
  ASelections := GetSelectedItems;
  try
    btnAlign.Enabled := CanModify and (ASelections.Count > 1);
  finally
    ASelections.Free;
  end;
end;

procedure TDesignForm.RefreshItemsListBox;
var
  AItems, AGroups: TList;

  procedure ProcessAbsoluteItems;
  var
    I: Integer;
    AItem: TdxCustomLayoutItem;
  begin
    for I := 0 to Control.AbsoluteItemCount - 1 do
    begin
      AItem := Control.AbsoluteItems[I];
      if AItem is TdxLayoutItem then
        AItems.Add(AItem)
      else
        AGroups.Add(AItem);
    end;
  end;

  procedure AddItems(AItems: TList);
  var
    I: Integer;
    AItem: TdxCustomLayoutItem;
  begin
    for I := 0 to AItems.Count - 1 do
    begin
      AItem := TdxCustomLayoutItem(AItems[I]);
      lbItems.Items.AddObject(AItem.Name, AItem);
    end;
  end;

begin
  AItems := TList.Create;
  AGroups := TList.Create;
  try
    ProcessAbsoluteItems;
    AItems.Sort(CompareItems);
    AGroups.Sort(CompareItems);
    with lbItems.Items do
    begin
      BeginUpdate;
      try
        Clear;
        Add('< Groups >');
        AddItems(AGroups);
        Add('< Items >');
        AddItems(AItems);
      finally
        EndUpdate;
      end;
    end;
  finally
    AGroups.Free;
    AItems.Free;
  end;
end;

procedure TDesignForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TDesignForm.lbItemsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  S: string;
  AItem: TdxCustomLayoutItem;
begin
  with Control as TListBox do
  begin
    S := Items[Index];
    AItem := TdxCustomLayoutItem(Items.Objects[Index]);
    if AItem = nil then
    begin
      Canvas.Brush.Color := clBtnFace;
      Canvas.Font.Color := Font.Color;
      Canvas.TextRect(Rect, 
        (Rect.Left + Rect.Right - Canvas.TextWidth(S)) div 2, Rect.Top + 2, S);
      if odFocused in State then
        Canvas.DrawFocusRect(Rect);
    end
    else
    begin
      if AItem is TdxLayoutGroup then
      begin
        Canvas.Font.Style := [fsBold];
        if TdxLayoutGroup(AItem).Hidden then
          Canvas.Font.Style := Canvas.Font.Style + [fsItalic];
      end;
      if not AItem.ActuallyVisible then
        Canvas.Font.Color := clBtnFace;
      Canvas.TextRect(Rect, Rect.Left + 4, Rect.Top + 2, S);
    end;  
  end;
end;

procedure TDesignForm.btnAddGroupClick(Sender: TObject);
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
    Designer.SelectComponent(AGroup);
  end;
end;

procedure TDesignForm.btnAddItemClick(Sender: TObject);
var
  AItemCaption: string;
  AItem: TdxCustomLayoutItem;
begin
  AItemCaption := cxGetResourceString(@dxLayoutNewItemCaption);
  if TLayoutEditForm.Run(cxGetResourceString(@dxLayoutNewItemDialogCaption),
    cxGetResourceString(@dxLayoutNewItemDialogEditCaption), AItemCaption) then
  begin
    AItem := Control.CreateItem;
    AItem.Caption := AItemCaption;
    Designer.SelectComponent(AItem);
  end;
end;

procedure TDesignForm.btnAlignClick(Sender: TObject);
var
  P: TPoint;
begin
  with btnAlign.BoundsRect do
    P := Point(Left, Bottom);
//    P := Point(Right, Top);
  P := btnAlign.Parent.ClientToScreen(P);
  pmAlign.Popup(P.X, P.Y);
end;

procedure TDesignForm.pmAlignItemClick(Sender: TObject);
var
  ASelections: TDesignerSelectionListAccess;
  I: Integer;
begin
  ASelections := GetSelectedItems;
  try
    Control.BeginUpdate;
    try
      if TMenuItem(Sender).Tag = -1 then
        for I := 0 to ASelections.Count - 1 do
          TdxCustomLayoutItem(ASelections[I]).AlignmentConstraint := nil
      else
        with Control.CreateAlignmentConstraint do
        begin
          Kind := TdxLayoutAlignmentConstraintKind(TMenuItem(Sender).Tag);
          for I := 0 to ASelections.Count - 1 do
            AddItem(TdxCustomLayoutItem(ASelections[I]));
        end;
     finally
       Control.EndUpdate;
     end;
  finally
    ASelections.Free;
    Designer.Modified;
  end;
end;

procedure TDesignForm.chbShowHiddenGroupsBoundsClick(Sender: TObject);
begin
  Control.ShowHiddenGroupsBounds := chbShowHiddenGroupsBounds.Checked;
end;

procedure TDesignForm.lcMainItem4CaptionClick(Sender: TObject);
begin
  with chbShowHiddenGroupsBounds do
    Checked := not Checked;
end;

end.
