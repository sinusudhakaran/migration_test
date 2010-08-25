{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars Customization Form                              }
{                                                                   }
{       Copyright (c) 1998-2009 Developer Express Inc.              }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE    }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS   }
{   LICENSED TO DISTRIBUTE THE EXPRESSBARS AND ALL ACCOMPANYING VCL }
{   CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.                 }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT  }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                      }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit dxBarCustForm;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, Buttons, cxClasses, dxBar, ActnList,
  ToolWin, ImgList, Contnrs, dxBarCustomCustomizationForm;

type
  TdxBarPermissiveProc = function (Sender: TComponent): Boolean of object;

  TdxBarCustomizationForm = class(TdxBarCustomCustomizationForm)
    aAddGroup: TAction;
    aAddGroupItem: TAction;
    aDeleteGroup: TAction;
    aDeleteGroupItem: TAction;
    alGroupCustomize: TActionList;
    aMoveDownGroup: TAction;
    aMoveDownGroupItem: TAction;
    aMoveUpGroup: TAction;
    aMoveUpGroupItem: TAction;
    BBarDelete: TButton;
    BBarNew: TButton;
    BBarRename: TButton;
    BBarReset: TButton;
    BClose: TButton;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    BHelp: TBitBtn;
    BResetUsageData: TButton;
    btnAddGroup: TToolButton;
    btnAddGroupItem: TToolButton;
    btnDeleteGroup: TToolButton;
    btnDeleteGroupItem: TToolButton;
    btnMoveDownGroup: TToolButton;
    btnMoveDownGroupItem: TToolButton;
    btnMoveUpGroup: TToolButton;
    btnMoveUpGroupItem: TToolButton;
    CategoriesPopupButtonPlace: TSpeedButton;
    CBHint1: TCheckBox;
    CBHint1Ex: TCheckBox;
    CBHint2: TCheckBox;
    CBHint2Ex: TCheckBox;
    CBLargeIcons: TCheckBox;
    CBLargeIconsEx: TCheckBox;
    CBMenusShowRecentItemsFirst: TCheckBox;
    CBShowCommandsWithShortCut: TCheckBox;
    CBShowFullMenusAfterDelay: TCheckBox;
    ComboBoxMenuAnimations: TComboBox;
    ComboBoxMenuAnimationsEx: TComboBox;
    CommandsPopupButtonPlace: TSpeedButton;
    DescriptionLabel: TLabel;
    EnhancedOptionsPanel: TPanel;
    gbGroups: TGroupBox;
    gpGroupItems: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LabelCategories: TLabel;
    LabelCommands: TLabel;
    LabelDescription: TLabel;
    LabelMenuAnimations: TLabel;
    LabelToobars: TLabel;
    LAllCommands: TListBox;
    lbBarsList: TListBox;
    lbCategories: TListBox;
    lbGroupItems: TListBox;
    lbGroups: TListBox;
    lbItems: TListBox;
    PageControl: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    StandardOptionsPanel: TPanel;
    TabSheet1: TTabSheet;
    tbGroupItems: TToolBar;
    tbGroups: TToolBar;
    ToolButton3: TToolButton;
    ToolButton8: TToolButton;
    tsCommands: TTabSheet;
    tsGroups: TTabSheet;
    tsItems: TTabSheet;
    tsOptions: TTabSheet;
    tsToolbars: TTabSheet;
    tvKeyTips: TTreeView;
    procedure aAddGroupExecute(Sender: TObject);
    procedure aAddGroupItemExecute(Sender: TObject);
    procedure aDeleteGroupExecute(Sender: TObject);
    procedure aDeleteGroupItemExecute(Sender: TObject);
    procedure aMoveGroupExecute(Sender: TObject);
    procedure aMoveGroupItemExecute(Sender: TObject);
    procedure BResetUsageDataClick(Sender: TObject);
    procedure CBHint1Click(Sender: TObject);
    procedure CBHint1ExClick(Sender: TObject);
    procedure CBHint2Click(Sender: TObject);
    procedure CBLargeIconsClick(Sender: TObject);
    procedure CBMenusShowRecentItemsFirstClick(Sender: TObject);
    procedure CBShowCommandsWithShortCutClick(Sender: TObject);
    procedure CBShowFullMenusAfterDelayClick(Sender: TObject);
    procedure ComboBoxMenuAnimationsClick(Sender: TObject);
    procedure LAllCommandsClick(Sender: TObject);
    procedure LAllCommandsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure LAllCommandsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lbGroupItemsClick(Sender: TObject);
    procedure lbGroupItemsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lbGroupItemsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbGroupsClick(Sender: TObject);
    procedure lbGroupsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure lbGroupsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbGroupsMeasureItem(Control: TWinControl; Index: Integer;  var Height: Integer);
    procedure lbItemsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure BCloseClick(Sender: TObject);
    procedure BHelpClick(Sender: TObject);
  private
    FAllCommandsCaptionWidth: Integer;
    FAllCommandsNameWidth: Integer;
    FAllCommandsLinksCountWidth: Integer;
    FAllCommandsShortCutWidth: Integer;
    FAllCommandListBoxOldWndProc: TWndMethod;
    
    FGroupItemListBoxOldWndProc: TWndMethod;
    FGroupListBoxOldWndProc: TWndMethod;
    FGroupsOldChangeEvent: TcxComponentListChangeEvent;
    FSelectedGroupItems: TdxBarComponentList;

    //AllCommandList
    procedure AllCommandListBoxWndProc(var Message: TMessage);
    function GetAllCommandList(Index: Integer): TdxBarItem;
    procedure RefreshAllCommandListBox;
    procedure OnItemLinkChange(Sender: TdxBarManager; AItemLink: TdxBarItemLink);

    //GroupList
    function GetSelectedGroup: TdxBarGroup;
    procedure GroupListBoxWndProc(var Message: TMessage);
    procedure GroupsChange(Sender: TObject; AComponent: TComponent;
      AAction: TcxComponentCollectionNotification);
    procedure MoveGroup(ADirection: Integer);
    procedure RememberSelectedList;

    //GroupItemList
    procedure GroupItemListBoxWndProc(var Message: TMessage);
    procedure GroupStuctureChange;
    procedure DeleteGroupItem(AGroupItem: TObject);
    procedure MoveGroupItem(ADirection: Integer);
    procedure UpdateGroupItemEvents;

    property AllCommandList[Index: Integer]: TdxBarItem read GetAllCommandList;

    property SelectedGroup: TdxBarGroup read GetSelectedGroup;
  protected
    function GetBarListBox: TListBox; override;
    function GetCategoriesList: TListBox; override;
    function GetItemsListBox: TListBox; override;
    procedure ItemsChange(Sender: TObject; AComponent: TComponent;
      AAction: TcxComponentCollectionNotification); override;
    procedure PrepareControls; override;
    procedure RestoreOldEvents; override;
    procedure SynchronizeListBoxes; override;
    procedure UpdateItemDesciption(const AText: string); override;
  public
    constructor CreateEx(ABarManager: TdxBarManager); override;
    destructor Destroy; override;
    procedure DesignSelectionChanged(Sender: TObject); override;
    procedure SelectPage(APageIndex: Integer); override;
    procedure SwitchToItemsPage; override;
    procedure UpdateHelpButton; override;
    procedure UpdateOptions; override;
  end;

implementation

{$R *.DFM}

uses
{$IFDEF DELPHI8}
  Types,
{$ENDIF}
  dxBarNameEd, dxBarPopupMenuEd, dxBarItemEd, dxBarStrs, dxBarAddGroupItemsEd,
  TypInfo, dxUxTheme, dxThemeManager, dxThemeConsts, dxOffice11, cxContainer,
  cxControls, cxGraphics, Math, cxLookAndFeelPainters;

const
  AllCommandsIndent = 5;

type
  TdxBarGroupAccess = class(TdxBarGroup);
  TdxBarItemAccess = class(TdxBarItem);
  TdxBarManagerAccess = class(TdxBarManager);

{ TdxBarCustomizingForm }

constructor TdxBarCustomizationForm.CreateEx(ABarManager: TdxBarManager);

{$IFDEF DELPHI7}
  procedure SetupBevelSize(ALabel: TLabel; ABevel: TBevel);
  begin
    with ABevel, BoundsRect do
      BoundsRect := Rect(ALabel.BoundsRect.Right, Top, Right, Bottom);
  end;
{$ENDIF}

begin
  FSelectedGroupItems := TdxBarComponentList.Create(False);
  inherited CreateEx(ABarManager);
{$IFDEF DELPHI7}
  SetupBevelSize(LabelDescription, Bevel1);
  SetupBevelSize(Label3, Bevel3);
  SetupBevelSize(Label2, Bevel2);
{$ENDIF}
  if tsCommands.TabVisible then
  begin
    ABarManager.OnItemLinkAdd := OnItemLinkChange;
    ABarManager.OnItemLinkChange := OnItemLinkChange;
    ABarManager.OnItemLinkDelete := OnItemLinkChange;
  end;
end;

destructor TdxBarCustomizationForm.Destroy;
begin
  if tsCommands.TabVisible then
  begin
    BarManager.OnItemLinkAdd := nil;
    BarManager.OnItemLinkChange := nil;
    BarManager.OnItemLinkDelete := nil;
  end;
  FreeAndNil(FSelectedGroupItems);
  inherited Destroy;
end;

procedure TdxBarCustomizationForm.PrepareControls;

  procedure PrepareMenuAnimationsLabel(ALabel: TLabel; ComboBox: TComboBox);
  begin
    with ALabel do
    begin
      Caption := cxGetResourceString(@dxSBAR_MENUANIMATIONS);
      if Left + Width + 10 > ComboBox.Left then
        ComboBox.Left := Left + Width + 10;
    end;
  end;

  procedure PrepareToolBarsSheet;
  begin
    BBarReset.Visible := not BarManager.Designing and TdxBarManagerAccess(BarManager).CanReset;
    LabelToobars.Caption := cxGetResourceString(@dxSBAR_TOOLBARS);
    LabelToobars.FocusControl := lbBarsList;
    tsToolbars.Caption := cxGetResourceString(@dxSBAR_TABSHEET1);
  end;

  procedure PrepareItemsSheet;
  begin
    tsItems.Caption := cxGetResourceString(@dxSBAR_TABSHEET2);
    LabelCommands.FocusControl := lbItems;

    ReplaceByCheckableButton(cxGetResourceString(@dxSBAR_MODIFY),
      CategoriesPopupButtonPlace, LabelCategories, CategoriesPopupMenu);
    ReplaceByCheckableButton(cxGetResourceString(@dxSBAR_MODIFY),
      CommandsPopupButtonPlace, LabelCommands, CommandsPopupMenu);

    LabelCategories.Caption := cxGetResourceString(@dxSBAR_CATEGORIES);
    LabelCommands.Caption := cxGetResourceString(@dxSBAR_COMMANDS);
    LabelDescription.Caption := cxGetResourceString(@dxSBAR_DESCRIPTION);
  end;

  procedure PrepareOptionsSheet;
  begin
    tsOptions.Caption := cxGetResourceString(@dxSBAR_TABSHEET3);

    if BarManager.GetPaintStyle = bmsStandard then
    begin
      CBLargeIcons.Caption := cxGetResourceString(@dxSBAR_LARGEICONS);
      CBHint1.Caption := cxGetResourceString(@dxSBAR_HINTOPT1);
      CBHint2.Caption := cxGetResourceString(@dxSBAR_HINTOPT2);
      PrepareMenuAnimationsLabel(LabelMenuAnimations, ComboBoxMenuAnimations);
      with ComboBoxMenuAnimations do
        Width := PrepareMenuAnimationsComboBox(Font, Items);
    end
    else
    begin
      Label3.Caption := cxGetResourceString(@dxSBAR_PERSMENUSANDTOOLBARS);
      CBMenusShowRecentItemsFirst.Caption := cxGetResourceString(@dxSBAR_MENUSSHOWRECENTITEMS);
      CBShowFullMenusAfterDelay.Caption := cxGetResourceString(@dxSBAR_SHOWFULLMENUSAFTERDELAY);
      with BResetUsageData do
      begin
        Caption := cxGetResourceString(@dxSBAR_RESETUSAGEDATA);
        Width := cxTextWidth(Font, GetTextOf(Caption)) + 17;
      end;
      Label2.Caption := cxGetResourceString(@dxSBAR_OTHEROPTIONS);
      CBLargeIconsEx.Caption := cxGetResourceString(@dxSBAR_LARGEICONS);
      CBHint1Ex.Caption := cxGetResourceString(@dxSBAR_HINTOPT1);
      CBHint2Ex.Caption := cxGetResourceString(@dxSBAR_HINTOPT2);
      PrepareMenuAnimationsLabel(Label1, ComboBoxMenuAnimationsEx);
      with ComboBoxMenuAnimationsEx do
        Width := PrepareMenuAnimationsComboBox(Font, Items);
    end;
  end;

  procedure PrepareCommandsSheet;
  begin
    tsCommands.TabVisible := BarManager.Designing;
    SetNewWindowProc(LAllCommands, AllCommandListBoxWndProc, FAllCommandListBoxOldWndProc);
  end;

  procedure PrepareGroupsSheet;
  begin
    tsGroups.TabVisible := BarManager.Designing;
    SetNewWindowProc(lbGroups, GroupListBoxWndProc, FGroupListBoxOldWndProc);
    SetNewWindowProc(lbGroupItems, GroupItemListBoxWndProc, FGroupItemListBoxOldWndProc);
    FGroupsOldChangeEvent := TdxBarManagerAccess(BarManager).GroupList.OnComponentListChanged;
    TdxBarManagerAccess(BarManager).GroupList.OnComponentListChanged := GroupsChange;
  end;

  procedure PrepareKeyTipsSheet;

    procedure GetKeyTipsTree(AContainer: IdxBarAccessibilityHelper;
      ANodes: TTreeNodes; AParentNode: TTreeNode);
    var
      AChild, AContainerHelper: TdxBarAccessibilityHelper;
      I: Integer;
    begin
      AContainerHelper := AContainer.GetBarHelper;
      if AContainerHelper.Selectable then
        AParentNode := ANodes.AddChild(AParentNode, AContainerHelper.OwnerObject.ClassName);
      for I := 0 to AContainerHelper.ChildCount - 1 do
      begin
        AChild := AContainerHelper.Childs[I];
        GetKeyTipsTree(AChild, ANodes, AParentNode);
      end;
    end;

  var
    AKeyTipWindowsManager: IdxBarKeyTipWindowsManager;
    ARootAccessibleObject: IdxBarAccessibilityHelper;
  begin
    ARootAccessibleObject := GetRootAccessibleObject(BarManager.Owner.Handle);
    if (ARootAccessibleObject <> nil) and ARootAccessibleObject.AreKeyTipsSupported(AKeyTipWindowsManager) then
    begin
      GetKeyTipsTree(ARootAccessibleObject, tvKeyTips.Items, nil);
    end;
  end;

  procedure PrepareButtons;
  begin
    BResetUsageData.Enabled := not BarManager.Designing;
    with BClose do
    begin
      Caption := cxGetResourceString(@dxSBAR_CLOSE);
      Width := cxTextWidth(Font, GetTextOf(Caption)) + 49;
      Left := Parent.Width - Panel3.Width - Width;
    end;
    UpdateHelpButton;
  end;

begin
  PrepareButtons;
  PrepareToolBarsSheet;
  PrepareItemsSheet;
  PrepareOptionsSheet;
  PrepareCommandsSheet;
  PrepareGroupsSheet;
  PrepareKeyTipsSheet;
end;

procedure TdxBarCustomizationForm.RestoreOldEvents;
begin
  inherited RestoreOldEvents;
  TdxBarManagerAccess(BarManager).GroupList.OnComponentListChanged := FGroupsOldChangeEvent;
end;

procedure TdxBarCustomizationForm.SynchronizeListBoxes;
begin
  SynchronizeListBox(lbBarsList);
  SynchronizeListBox(lbCategories);
  SynchronizeListBox(lbItems);
  SynchronizeListBox(LAllCommands);
  SynchronizeListBox(lbGroups);
end;

procedure TdxBarCustomizationForm.UpdateItemDesciption(const AText: String);
begin
  DescriptionLabel.Caption := AText;
end;

procedure TdxBarCustomizationForm.ItemsChange(Sender: TObject;
  AComponent: TComponent; AAction: TcxComponentCollectionNotification);
begin
  inherited ItemsChange(Sender, AComponent, AAction);
  SynchronizeListBox(LAllCommands, AComponent, AAction);
  SynchronizeListBox(lbGroupItems, AComponent, AAction);
end;

procedure TdxBarCustomizationForm.AllCommandListBoxWndProc(var Message: TMessage);

  procedure SynchronizeCommandList;
  var
    I: Integer;
    AItem: TdxBarItem;
  begin
    AItem := TdxBarItem(Message.WParam);
    if AItem = nil then
    begin
      SendMessage(LAllCommands.Handle, WM_SETREDRAW, WPARAM(False), 0);
      try
        for I := 0 to BarManager.ItemCount - 1 do
          if (BarManager.Items[I].Category >= 0) and
            (not CBShowCommandsWithShortCut.Checked or
             (GetPropInfo(BarManager.Items[I].ClassInfo, 'ShortCut') <> nil)) then
            LAllCommands.Items.AddObject('', BarManager.Items[I]);
      finally
        SendMessage(LAllCommands.Handle, WM_SETREDRAW, WPARAM(True), 0);
      end;
    end;
    RefreshAllCommandListBox;
  end;

begin
  if Message.Msg = dxWM_LB_SYNCHRONIZE then
    SynchronizeCommandList;
  if Message.Msg = dxWM_LB_SYNCHRONIZESELECTION then
    SynchronizeListBoxSelection(LAllCommands);
  FAllCommandListBoxOldWndProc(Message);
end;

function TdxBarCustomizationForm.GetAllCommandList(Index: Integer): TdxBarItem;
begin
  Result := TdxBarItem(GetObjectFromListBox(LAllCommands, Index));
end;

procedure TdxBarCustomizationForm.RefreshAllCommandListBox;
var
  I: Integer;
  AScrollWidth: Integer;
  ACanvas: TCanvas;
begin
  FAllCommandsNameWidth := 0;
  FAllCommandsCaptionWidth := 0;
  FAllCommandsLinksCountWidth := 0;
  FAllCommandsShortCutWidth := 0;
  LAllCommands.Canvas.Font := LAllCommands.Font;
  ACanvas := LAllCommands.Canvas;
  for I := 0 to LAllCommands.Items.Count - 1 do
    with AllCommandList[I] do
    begin
      FAllCommandsNameWidth := Max(FAllCommandsNameWidth, ACanvas.TextWidth(Name));
      FAllCommandsCaptionWidth := Max(FAllCommandsCaptionWidth, ACanvas.TextWidth(Caption));
      FAllCommandsLinksCountWidth := Max(FAllCommandsLinksCountWidth, ACanvas.TextWidth(IntToStr(LinkCount) + ' link(s)'));
      FAllCommandsShortCutWidth := Max(FAllCommandsShortCutWidth, ACanvas.TextWidth(ShortCutToText(ShortCut)));
    end;
  LAllCommands.Invalidate;

  AScrollWidth :=
    AllCommandsIndent + FAllCommandsNameWidth + AllCommandsIndent +
    AllCommandsIndent + FAllCommandsCaptionWidth + AllCommandsIndent +
    AllCommandsIndent + FAllCommandsLinksCountWidth + AllCommandsIndent +
    AllCommandsIndent + FAllCommandsShortCutWidth + AllCommandsIndent;
  SendMessage(LAllCommands.Handle, LB_SETHORIZONTALEXTENT, AScrollWidth, 0);
end;

procedure TdxBarCustomizationForm.OnItemLinkChange(Sender: TdxBarManager; AItemLink: TdxBarItemLink);
begin
  DeferredCallSynchronizationListBox(LAllCommands);
end;

function TdxBarCustomizationForm.GetSelectedGroup: TdxBarGroup;
begin
  Result := TdxBarGroup(GetExclusiveObject(lbGroups));
end;

procedure TdxBarCustomizationForm.GroupListBoxWndProc(var Message: TMessage);

  procedure SynchronizeGroupList;
  var
    I: Integer;
    AGroup: TdxBarGroup;
  begin
    AGroup := TdxBarGroup(Message.WParam);
    if AGroup = nil then
      for I := 0 to BarManager.GroupCount - 1 do
      begin
        AGroup := BarManager.Groups[I];
        lbGroups.Items.AddObject(AGroup.Name, AGroup);
      end
    else
      lbGroups.Items[Message.LParam] := AGroup.Name;
  end;

  procedure UpdateGroupEvents;
  begin
    SynchronizeListBox(lbGroupItems);

    UpdateCommonEvents(lbGroups, aAddGroup, aDeleteGroup, aMoveUpGroup, aMoveDownGroup);
  end;

begin
  if Message.Msg = dxWM_LB_SYNCHRONIZE then
    SynchronizeGroupList;
  if Message.Msg = dxWM_LB_SYNCHRONIZESELECTION then
    SynchronizeListBoxSelection(lbGroups);
  if Message.Msg = dxWM_LB_UPDATEEVENTS then
    UpdateGroupEvents;
  FGroupListBoxOldWndProc(Message);
end;

procedure TdxBarCustomizationForm.GroupsChange(Sender: TObject;
  AComponent: TComponent; AAction: TcxComponentCollectionNotification);
begin
  if Assigned(FGroupsOldChangeEvent) then
    FGroupsOldChangeEvent(Sender, AComponent, AAction);
  SynchronizeListBox(lbGroups, AComponent, AAction);
end;

procedure TdxBarCustomizationForm.MoveGroup(ADirection: Integer);
begin
  MoveItems(lbGroups, TdxBarManagerAccess(BarManager).GroupList, ADirection);
end;

procedure TdxBarCustomizationForm.RememberSelectedList;
begin
  FSelectedGroupItems.Clear;
  GetSelection(lbGroupItems, FSelectedGroupItems);
end;

procedure TdxBarCustomizationForm.GroupItemListBoxWndProc(var Message: TMessage);

  procedure SynchronizeGroupItemList;
  var
    I: Integer;
    AGroup: TdxBarGroup;
    AItem: TComponent;
  begin
    AItem := TComponent(Message.WParam);
    if AItem = nil then
    begin
      AGroup := SelectedGroup;
      if AGroup <> nil then
        for I := 0 to AGroup.Count - 1 do
        begin
          AItem := AGroup[I];
          lbGroupItems.Items.AddObject(AItem.Name, AItem);
        end;
    end
    else
      lbGroupItems.Items[Message.LParam] := AItem.Name;
  end;

  procedure SynchronizeGroupListSelection;
  begin
    SetSelection(lbGroupItems, FSelectedGroupItems);
    UpdateGroupItemEvents;
  end;

begin
  if Message.Msg = dxWM_LB_SYNCHRONIZE then
    SynchronizeGroupItemList;
  if Message.Msg = dxWM_LB_SYNCHRONIZESELECTION then
    SynchronizeGroupListSelection;
  if Message.Msg = dxWM_LB_UPDATEEVENTS then
    UpdateGroupItemEvents;
  FGroupItemListBoxOldWndProc(Message);
end;

procedure TdxBarCustomizationForm.GroupStuctureChange;
begin
  SynchronizeListBox(lbGroupItems);
end;

procedure TdxBarCustomizationForm.DeleteGroupItem(AGroupItem: TObject);
begin
  SelectedGroup.Remove(TdxBarComponent(AGroupItem));
end;

procedure TdxBarCustomizationForm.MoveGroupItem(ADirection: Integer);
begin
  MoveItems(lbGroupItems, TdxBarGroupAccess(SelectedGroup).ItemList, ADirection);
end;

procedure TdxBarCustomizationForm.UpdateGroupItemEvents;
begin
  aAddGroupItem.Enabled := SelectedGroup <> nil;
  UpdateCommonEvents(lbGroupItems, nil, aDeleteGroupItem, aMoveUpGroupItem, aMoveDownGroupItem);
end;

function TdxBarCustomizationForm.GetBarListBox: TListBox;
begin
  Result := lbBarsList;
end;

function TdxBarCustomizationForm.GetItemsListBox: TListBox;
begin
  Result := lbItems;
end;

function TdxBarCustomizationForm.GetCategoriesList: TListBox;
begin
  Result := lbCategories;
end;

procedure TdxBarCustomizationForm.DesignSelectionChanged(Sender: TObject);
begin
  if not (csDestroying in (Application.ComponentState + ComponentState)) then
  begin
    SynchronizeListBoxSelection(lbBarsList);
    SynchronizeListBoxSelection(lbItems);
    SynchronizeListBoxSelection(LAllCommands);
    SynchronizeListBoxSelection(lbGroups);
  end;
end;

procedure TdxBarCustomizationForm.SelectPage(APageIndex: Integer);
begin
  PageControl.ActivePageIndex := APageIndex;
end;

procedure TdxBarCustomizationForm.SwitchToItemsPage;
begin
  PageControl.ActivePage := tsItems;
end;

procedure TdxBarCustomizationForm.UpdateHelpButton;
begin
  BHelp.Glyph := BarManager.HelpButtonGlyph;
  BHelp.Visible := BarManager.ShowHelpButton;
end;

procedure TdxBarCustomizationForm.UpdateOptions;
begin
  StandardOptionsPanel.Visible := BarManager.GetPaintStyle = bmsStandard;
  EnhancedOptionsPanel.Visible := BarManager.GetPaintStyle <> bmsStandard;

  CBMenusShowRecentItemsFirst.Checked := BarManager.MenusShowRecentItemsFirst;
  CBShowFullMenusAfterDelay.Checked := BarManager.ShowFullMenusAfterDelay;
  CBShowFullMenusAfterDelay.Enabled := CBMenusShowRecentItemsFirst.Checked;

  CBLargeIcons.Checked := BarManager.LargeIcons;
  CBLargeIconsEx.Checked := BarManager.LargeIcons;
  CBHint1.Checked := BarManager.ShowHint;
  CBHint1Ex.Checked := BarManager.ShowHint;
  CBHint2.Checked := BarManager.ShowShortcutInHint;
  CBHint2Ex.Checked := BarManager.ShowShortcutInHint;
  CBHint2Ex.Enabled := CBHint1Ex.Checked;
  ComboBoxMenuAnimations.ItemIndex := Ord(BarManager.MenuAnimations);
  ComboBoxMenuAnimationsEx.ItemIndex := Ord(BarManager.MenuAnimations);
end;

procedure TdxBarCustomizationForm.lbItemsDrawItem(
  Control: TWinControl; Index: Integer; Rect: TRect;
  State: TOwnerDrawState);

  function BrushColors(AItem: TdxBarItem; ASelected: Boolean): TColor;
  begin
    Result := PainterClass.BrushColors(ASelected, AItem);
  end;

var
  AItem: TdxBarItem;
  R: TRect;
begin
  AItem := ItemList[Index];
  if AItem = nil then
    Exit;

  TdxBarItemAccess(AItem).DrawCustomizingImage(lbItems.Canvas, Rect, State);
  R := Rect;
  if Index = lbItems.Items.Count - 1 then
  begin
    R := Rect;
    R.Top := R.Bottom;
    R.Bottom := ClientHeight;
    lbItems.Canvas.Brush.Color := BrushColors(AItem, False);
    lbItems.Canvas.FillRect(R);
  end;

  if odFocused in State then
    PainterClass.DrawFocusedRect(lbItems.Canvas, Rect, AItem);
end;

procedure TdxBarCustomizationForm.CBMenusShowRecentItemsFirstClick(Sender: TObject);
begin
  CBShowFullMenusAfterDelay.Enabled := CBMenusShowRecentItemsFirst.Checked;
  BarManager.MenusShowRecentItemsFirst := CBMenusShowRecentItemsFirst.Checked;
end;

procedure TdxBarCustomizationForm.CBShowFullMenusAfterDelayClick(Sender: TObject);
begin
  BarManager.ShowFullMenusAfterDelay := CBShowFullMenusAfterDelay.Checked;
end;

procedure TdxBarCustomizationForm.BResetUsageDataClick(Sender: TObject);
begin
  BarManager.ResetUsageDataWithConfirmation;
end;

procedure TdxBarCustomizationForm.CBLargeIconsClick(Sender: TObject);
begin
  BarManager.LargeIcons := TCheckBox(Sender).Checked;
end;

procedure TdxBarCustomizationForm.CBHint1Click(Sender: TObject);
begin
  BarManager.ShowHint := TCheckBox(Sender).Checked;
end;

procedure TdxBarCustomizationForm.CBHint1ExClick(Sender: TObject);
begin
  CBHint2Ex.Enabled := CBHint1Ex.Checked;
  CBHint1Click(Sender);
end;

procedure TdxBarCustomizationForm.CBHint2Click(Sender: TObject);
begin
  BarManager.ShowShortCutInHint := TCheckBox(Sender).Checked;
end;

procedure TdxBarCustomizationForm.ComboBoxMenuAnimationsClick(Sender: TObject);
begin
  BarManager.MenuAnimations := TdxBarMenuAnimations(TComboBox(Sender).ItemIndex);
end;

procedure TdxBarCustomizationForm.LAllCommandsClick(Sender: TObject);
begin
  SynchronizeDesigner(LAllCommands);
end;

procedure TdxBarCustomizationForm.LAllCommandsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);

  procedure DrawSeparator(ACanvas: TCanvas; AColor: TColor; APos, ATop, ABottom: Integer);
  begin
    ACanvas.Pen.Color := AColor;
    ACanvas.MoveTo(APos, ATop);
    ACanvas.LineTo(APos, ABottom);
  end;

  procedure DrawColumn(ACanvas: TCanvas; const AText: string; ATextWidth: Integer; var AColumnPos: Integer; ANeedDrawSeparator, ALastRow: Boolean);
  begin
    ACanvas.TextOut(AColumnPos + AllCommandsIndent, Rect.Top, AText);
    Inc(AColumnPos, AllCommandsIndent + ATextWidth + AllCommandsIndent);
    if ANeedDrawSeparator then
    begin
      DrawSeparator(ACanvas, ACanvas.Font.Color, AColumnPos, Rect.Top, Rect.Bottom);
      if ALastRow then
        DrawSeparator(ACanvas, clWindowText, AColumnPos, Rect.Bottom, Control.ClientHeight);
    end;
  end;

var
  W: Integer;
  ALastRow: Boolean;
begin
  TListBox(Control).Canvas.FillRect(Rect);

  W := 0;
  ALastRow := Index = TListBox(Control).Items.Count - 1;
  with AllCommandList[Index] do
  begin
    DrawColumn(TListBox(Control).Canvas, Name, FAllCommandsNameWidth, W, True, ALastRow);
    DrawColumn(TListBox(Control).Canvas, Caption, FAllCommandsCaptionWidth, W, True, ALastRow);
    DrawColumn(TListBox(Control).Canvas, IntToStr(LinkCount) + ' link(s)', FAllCommandsLinksCountWidth, W, True, ALastRow);
    DrawColumn(TListBox(Control).Canvas, ShortCutToText(ShortCut), FAllCommandsShortCutWidth, W, False, ALastRow);
  end;
end;

procedure TdxBarCustomizationForm.LAllCommandsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  I: Integer;
  AList: TObjectList;
begin
  if Key = VK_DELETE then
  begin
    AList := TObjectList.Create;
    try
      for I := 0 to LAllCommands.Items.Count - 1 do
        if LAllCommands.Selected[I] then
          AList.Add(AllCommandList[I]);
    finally
      AList.Free;
    end;
  end;
end;

procedure TdxBarCustomizationForm.CBShowCommandsWithShortCutClick(Sender: TObject);
begin
  SynchronizeListBox(LAllCommands);
end;

procedure TdxBarCustomizationForm.lbGroupsClick(Sender: TObject);
begin
  SynchronizeDesigner(lbGroups);
end;

procedure TdxBarCustomizationForm.lbGroupsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with TListBox(Control) do
  begin
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];
    cxExtTextOut(Canvas.Handle, Items[Index], Point(Rect.Left + 2, Rect.Top + 1),
      Rect, ETO_OPAQUE);
  end;
end;

procedure TdxBarCustomizationForm.lbGroupsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_INSERT:
      aAddGroup.Execute;
    VK_DELETE:
      aDeleteGroup.Execute;
    VK_UP:
      if Shift = [ssCtrl] then
      begin
        aMoveUpGroup.Execute;
        Key := 0;
      end;
    VK_DOWN:
      if Shift = [ssCtrl] then
      begin
        aMoveDownGroup.Execute;
        Key := 0;
      end;
  end;
end;

procedure TdxBarCustomizationForm.lbGroupsMeasureItem(Control: TWinControl;
  Index: Integer; var Height: Integer);
begin
  with TListBox(Control) do
    Canvas.Font := Font;
  Height := TListBox(Control).Canvas.TextHeight('Qq') + 2;
end;

procedure TdxBarCustomizationForm.lbGroupItemsClick(Sender: TObject);
begin
  RememberSelectedList;
  UpdateGroupItemEvents;
end;

procedure TdxBarCustomizationForm.lbGroupItemsDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  with TListBox(Control) do
  begin
    if Items.Objects[Index] is TdxBarGroup then
      Canvas.Font.Style := Canvas.Font.Style + [fsBold];
    cxExtTextOut(Canvas.Handle, Items[Index], Point(Rect.Left + 2, Rect.Top + 1), Rect, ETO_OPAQUE);
  end;
end;

procedure TdxBarCustomizationForm.lbGroupItemsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_INSERT:
      aAddGroupItem.Execute;
    VK_DELETE:
      aDeleteGroupItem.Execute;
    VK_UP:
      if Shift = [ssCtrl] then
      begin
        aMoveUpGroupItem.Execute;
        Key := 0;
      end;
    VK_DOWN:
      if Shift = [ssCtrl] then
      begin
        aMoveDownGroupItem.Execute;
        Key := 0;
      end;
  end;
end;

procedure TdxBarCustomizationForm.aAddGroupItemExecute(Sender: TObject);
var
  Group: TdxBarGroup;
  AGroupItems: TdxObjectList;
  I: Integer;
begin
  Group := SelectedGroup;
  AGroupItems := TdxObjectList.Create;
  try
    if dxBarChooseGroupItem(Group, AGroupItems) then
    begin
      TdxBarGroupAccess(Group).ItemList.BeginUpdate;
      try
        for I := 0 to AGroupItems.Count - 1 do
          Group.Add(TdxBarComponent(AGroupItems[I]));
      finally
        TdxBarGroupAccess(Group).ItemList.EndUpdate;
      end;
      AGroupItems.CopyTo(FSelectedGroupItems);
      GroupStuctureChange;
    end;
  finally
    AGroupItems.Free;
  end;
  TdxBarManagerAccess(BarManager).DesignerModified;
end;

procedure TdxBarCustomizationForm.aDeleteGroupItemExecute(Sender: TObject);
//#DGvar
//#DG  AGroup: TdxBarGroup;
begin
//#DG  AGroup := SelectedGroup;
//#DG  TdxBarGroupAccess(AGroup).ItemList.BeginUpdate;
  try
    DeleteSelectedObjects(lbGroupItems, DeleteGroupItem, False);
    RememberSelectedList;
  finally
//#DG    TdxBarGroupAccess(AGroup).ItemList.EndUpdate;
  end;
  GroupStuctureChange;
end;

procedure TdxBarCustomizationForm.aAddGroupExecute(Sender: TObject);
var
  AGroup: TdxBarGroup;
begin
  TdxBarManagerAccess(BarManager).GroupList.BeginUpdate;
  try
    AGroup := BarManager.CreateGroup;
    AGroup.Name := (BarManager as IdxBarDesigner).UniqueName('dxBarGroup');
    SynchronizeDesigner(AGroup);
  finally
    TdxBarManagerAccess(BarManager).GroupList.EndUpdate;
  end;
  TdxBarManagerAccess(BarManager).DesignerModified;
end;

procedure TdxBarCustomizationForm.aDeleteGroupExecute(Sender: TObject);
begin
  DeleteSelectedObjects(lbGroups);
end;

procedure TdxBarCustomizationForm.aMoveGroupExecute(Sender: TObject);
begin
  MoveGroup(TAction(Sender).Tag);
end;

procedure TdxBarCustomizationForm.aMoveGroupItemExecute(Sender: TObject);
begin
  MoveGroupItem(TAction(Sender).Tag);
  GroupStuctureChange;
end;

procedure TdxBarCustomizationForm.BCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TdxBarCustomizationForm.BHelpClick(Sender: TObject);
begin
  DoShowHelp;
end;

end.
