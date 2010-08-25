(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is TurboPower OfficePartner
 *
 * The Initial Developer of the Original Code is
 * TurboPower Software
 *
 * Portions created by the Initial Developer are Copyright (C) 2000-2002
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

{$I OPDEFINE.INC}

unit OpColEd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Menus, ComCtrls, OpDesign,
  {$IFDEF DCC6ORLATER}
    DesignIntf, DesignEditors, VCLEditors, RTLConsts,
  {$ELSE}
    DsgnIntf,
  {$ENDIF}
  OpShared,
  {$IFNDEF VERSION3} ImgList,{$ENDIF} ToolWin;

type
  TEditState = set of (esCanUndo, esCanRedo, esCanCut, esCanCopy, esCanPaste,
    esCanDelete, esCanZOrder, esCanAlignGrid, esCanEditOle, esCanTabOrder,
	esCanCreationOrder, esCanPrint, esCanSelectAll);

type
  TEditAction = (eaUndo, eaRedo, eaCut, eaCopy, eaPaste, eaDelete, eaSelectAll,
    eaPrint, eaBringToFront, eaSendToBack, eaAlignToGrid);

type
  TNodeType = (ntCollection,ntItem);

  pNodeData = ^TNodeData;
  TNodeData = record
    NodeType: TNodeType;
    Collection: TCollection;
    Item: TCollectionItem;
    ItemId: integer;
  end;

type
  TfrmCollectionEditor = class(TForm)
    trvCollection: TTreeView;
    pmnuCollection: TPopupMenu;
    AddItem1: TMenuItem;
    DeleteItem1: TMenuItem;
    imglstCollection: TImageList;
    ToolBar1: TToolBar;
    btnNewItem: TToolButton;
    btnDeleteItem: TToolButton;
    btnPrevLevel: TToolButton;
    btnNextLevel: TToolButton;
    ToolButton7: TToolButton;
    ToolButton4: TToolButton;
    stsbrName: TStatusBar;
    pmnuStatusBar: TPopupMenu;
    Copy1: TMenuItem;
    procedure AddItem1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure trvCollectionChange(Sender: TObject; Node: TTreeNode);
    procedure trvCollectionMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DeleteItem1Click(Sender: TObject);
    procedure btnPrevLevelClick(Sender: TObject);
    procedure btnNextLevelClick(Sender: TObject);
    function GetNodeItem(Node: TTreeNode): TOpNestedCollectionItem;
    procedure trvCollectionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
  private
    { Private declarations }
    FCollection: TCollection;
    FComponent: TComponent;
    FOldTreeProc: TWndMethod;
    procedure CustomTreeProc(var Message: TMessage);
    procedure FreeNodeData;
    procedure ClearTree;
    function AddTreeCollection(Node: TTreeNode; Collection: TCollection): TTreeNode;
    procedure AddItem(Collection: TCollection);
    function AddTreeItem(Node: TTreeNode; NewItem: TCollectionItem): TTreeNode;
    procedure PopulateEditor(Node: TTreeNode; Root: TOpNestedCollection);
    procedure SetButtonState;
    function FindNode(Collection : TCollection): TTreeNode;
    procedure CustomItemClick(Sender: TObject);
  protected
    {$IFDEF VERSION3}
    Designer : TDesigner;
    {$ELSE}
    Designer : IDesigner;
    {$ENDIF}
    procedure Activated;
    function UniqueName(Component: TComponent): string;
  public
    { Public declarations }
    destructor Destroy; override;

    {$IFDEF VERSION3}
    class procedure CreateEditor(ADesigner : TFormDesigner; Component: TComponent; Collection: TCollection);
    {$ELSE}
      {$IFDEF DCC6ORLATER}
        class procedure CreateEditor(ADesigner : IDesigner; Component: TComponent; Collection: TCollection);
      {$ELSE}
      class procedure CreateEditor(ADesigner : IFormDesigner; Component: TComponent; Collection: TCollection);
      {$ENDIF}
    {$ENDIF}
    class procedure FreeEditor;

    {$IFDEF VERSION3}
    procedure ComponentDeleted(Component: TComponent);
    {$ELSE}
      {$IFDEF DCC6ORLATER}
        procedure ComponentDeleted(Component: TComponent);
      {$ELSE}
      procedure ComponentDeleted(Component: IPersistent);
      {$ENDIF}
    {$ENDIF}

    function GetEditState: TEditState;
    procedure EditAction(Action: TEditAction);
    procedure FormClosed(AForm: TCustomForm);
    procedure FormModified;
  end;

implementation



uses Dialogs, Commctrl, Clipbrd;

var
  Singleton: TfrmCollectionEditor;

{$R *.DFM}

{ TfrmNestedCollection }

procedure TfrmCollectionEditor.AddItem(Collection : TCollection);
begin
  Collection.Add;
  Designer.Modified;
end;

procedure TfrmCollectionEditor.AddItem1Click(Sender: TObject);
begin
  if assigned(trvCollection.Selected) then begin
      if pNodeData(trvCollection.Selected.Data)^.NodeType = ntCollection then
        AddItem(pNodeData(trvCollection.Selected.Data)^.Collection);
    end
  else
    AddItem(FCollection);
  FormModified;
end;

{$IFDEF VERSION3}
class procedure TfrmCollectionEditor.CreateEditor(ADesigner : TFormDesigner; Component : TComponent; Collection: TCollection);
{$ELSE}
  {$IFDEF DCC6ORLATER}
    class procedure TfrmCollectionEditor.CreateEditor(ADesigner : IDesigner; Component: TComponent; Collection: TCollection);
  {$ELSE}
  class procedure TfrmCollectionEditor.CreateEditor(ADesigner : IFormDesigner; Component : TComponent; Collection: TCollection);
  {$ENDIF}
{$ENDIF}
begin
  if not assigned(Singleton) then
    Singleton := TfrmCollectionEditor.Create(Application);
  Singleton.Designer := ADesigner;
  Singleton.FCollection := (Collection as TOpNestedCollection).RootCollection;
  Singleton.FComponent := Component;
  Singleton.ClearTree;
  Singleton.PopulateEditor(nil,Singleton.FCollection as TOpNestedCollection);
  Singleton.trvCollection.Selected := Singleton.FindNode(Collection);
  Singleton.Caption := Singleton.FCollection.GetNamePath;
  Singleton.Show;
  Singleton.SetButtonState;
  Singleton.BringToFront;
end;

class procedure TfrmCollectionEditor.FreeEditor;
begin
  if assigned(Singleton) then begin
    Singleton.Free;
    Singleton := nil;
  end;
end;

procedure TfrmCollectionEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if FComponent <> nil then
    {$IFDEF VERSION3}
    (Designer as TFormDesigner).SelectComponent((FCollection as TOpNestedCollection).RootComponent);
    {$ELSE}
      {$IFDEF DCC6ORLATER}
       Designer.SelectComponent((FCollection as TOpNestedCollection).RootComponent);
      {$ELSE}
      (Designer as IFormDesigner).SelectComponent((FCollection as TOpNestedCollection).RootComponent);
      {$ENDIF}
    {$ENDIF}
  action := caFree;
  Singleton := nil;
end;

procedure TfrmCollectionEditor.FreeNodeData;
var
  Node : TTreeNode;
begin
  Node := trvCollection.Items.GetFirstNode;
  while assigned(Node) do begin
    dispose(pNodeData(Node.Data));
    Node := Node.GetNext;
  end;
end;

procedure TfrmCollectionEditor.trvCollectionChange(Sender: TObject;
  Node: TTreeNode);
begin
  if assigned(Node) then
  begin
    if pNodeData(Node.Data)^.NodeType = ntItem then begin
        stsbrName.SimpleText := GetNodeItem(Node).GetNamePath;
        {$IFDEF VERSION3}
        (Designer as TFormDesigner).SelectComponent(pNodeData(Node.Data)^.Item);
        {$ELSE}
          {$IFDEF DCC6ORLATER}
            Designer.SelectComponent(pNodeData(Node.Data)^.Item);
          {$ELSE}
          (Designer as IFormDesigner).SelectComponent(pNodeData(Node.Data)^.Item);
          {$ENDIF}
        {$ENDIF}
        ((pNodeData(Node.Data)^.Item) as TOpNestedCollectionItem).Activate;
      end
    else begin
      stsbrName.SimpleText := pNodeData(Node.Data)^.Collection.GetNamePath;
      {$IFDEF VERSION3}
      (Designer as TFormDesigner).SelectComponent(pNodeData(Node.Data)^.Collection);
      {$ELSE}
        {$IFDEF DCC6ORLATER}
          Designer.SelectComponent(pNodeData(Node.Data)^.Collection);
        {$ELSE}
        (Designer as IFormDesigner).SelectComponent(pNodeData(Node.Data)^.Collection);
        {$ENDIF}
      {$ENDIF}
    end;
  end;
  SetButtonState;
end;

//Designer signatures changed in Delphi 4

{$IFDEF VERSION3}
procedure TfrmCollectionEditor.ComponentDeleted(Component: TComponent);
begin
//  inherited ComponentDeleted(Component);   //does nothing.
  if assigned(Component) then
  begin
    if Component = FComponent then
      Singleton.FreeEditor;
  end;
end;
{$ELSE}
  {$IFDEF DCC6ORLATER}
  procedure TfrmCollectionEditor.ComponentDeleted(Component: TComponent);
  begin
    //inherited ComponentDeleted(Component);   //does nothing.
    if assigned(Component) then
    begin
      if Component = FComponent then
        Singleton.FreeEditor;
    end;
  end;

  {$ELSE}

  procedure TfrmCollectionEditor.ComponentDeleted(Component: IPersistent);
  begin
    //inherited ComponentDeleted(Component);   //does nothing.
    if assigned(Component) then
    begin
      if Component.Equals(MakeIPersistent(FComponent)) then
        Singleton.FreeEditor;
    end;
  end;
  {$ENDIF}
{$ENDIF}

procedure TfrmCollectionEditor.EditAction(Action: TEditAction);
begin
end;

procedure TfrmCollectionEditor.FormClosed(AForm: TCustomForm);
begin
  {$IFDEF DCC6ORLATER}
    {???}
    if (AForm.Name = Name) then begin
      FComponent := nil;
      Singleton.FreeEditor;
    end;
  {$ELSE}
    if Designer.Form = AForm then begin
      FComponent := nil;
      Singleton.FreeEditor;
    end;
  {$ENDIF}  
end;

procedure TfrmCollectionEditor.FormModified;
begin
  trvCollection.Items.BeginUpdate;
  trvCollection.Selected := nil;
  ClearTree;
  PopulateEditor(nil,FCollection as TOpNestedCollection);
  trvCollection.FullExpand;
  trvCollection.Items.EndUpdate;
end;

function TfrmCollectionEditor.GetEditState: TEditState;
begin
end;

destructor TfrmCollectionEditor.Destroy;
begin
  ClearTree;
  trvCollection.WindowProc := FOldTreeProc;
  inherited Destroy;
end;

procedure TfrmCollectionEditor.trvCollectionMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ClickNode: TTreeNode;
  CustomItem: TMenuItem;
  i : integer;
begin
  if Button = mbRight then begin
    for i := pmnuCollection.Items.Count - 1 downto 2 do begin
      pmnuCollection.Items[i].Free;
    end;
    ClickNode := trvCollection.GetNodeAt(x,y);
    if not(assigned(ClickNode)) then
      ClickNode := trvCollection.Items.GetFirstNode;
    trvCollection.Selected := ClickNode;
    if (pNodeData(ClickNode.Data)^.NodeType = ntCollection) then begin
        pmnuCollection.Items[0].Caption := '&Add ' + (TOpNestedCollection((pNodeData(ClickNode.Data)^.Collection))).ItemName;
        pmnuCollection.Items[0].Visible := true;
        pmnuCollection.Items[1].Visible := False;
      end
    else begin  // ntItem
      pmnuCollection.Items[1].Caption := '&Delete ' + (TOpNestedCollection((pNodeData(ClickNode.Data)^.Collection))).ItemName;
      pmnuCollection.Items[0].Visible := False;
      pmnuCollection.Items[1].Visible := true;
      // Support for custom menu items, break into separate routine (Add Item).
      if GetNodeItem(ClickNode).VerbCount > 0 then begin
        CustomItem := TMenuItem.Create(pmnuCollection.Items);
        CustomItem.Caption := '-';
        pmnuCollection.Items.Add(CustomItem);
      end;

      for i := 0 to GetNodeItem(ClickNode).VerbCount - 1 do begin
        CustomItem := TMenuItem.Create(pmnuCollection.Items);
        CustomItem.Caption := GetNodeItem(ClickNode).Verb[i];
        CustomItem.OnClick := CustomItemClick;
        pmnuCollection.Items.Add(CustomItem);
      end;
    end;
    pmnuCollection.Popup(trvCollection.ClientToScreen(point(x,y)).x,trvCollection.ClientToScreen(point(x,y)).y);
  end;
end;

procedure TfrmCollectionEditor.PopulateEditor(Node : TTreeNode ; Root : TOpNestedCollection);
var
  i,j : integer;
  CurrentCollection,CurrentItem : TTreeNode;
begin
  CurrentCollection := AddTreeCollection(Node,Root);
  for i := 0 to Root.Count - 1 do
  begin
    CurrentItem := AddTreeItem(CurrentCollection,(Root.Items[i]));
    for j := 0 to (Root.Items[i] as TOpNestedCollectionItem).SubCollectionCount - 1 do
    begin
      PopulateEditor(CurrentItem,((Root.Items[i] as TOpNestedCollectionItem).SubCollection[j]) as TOpNestedCollection);
    end;
  end;
end;

procedure TfrmCollectionEditor.ClearTree;
begin
  trvCollection.Selected := nil;
  FreeNodeData;
  trvCollection.Items.Clear;
end;

function TfrmCollectionEditor.AddTreeCollection(Node: TTreeNode;
  Collection: TCollection): TTreeNode;
var
  NodeData : pNodeData;
begin
  Result := trvCollection.Items.AddChild(Node,(Collection as TOpNestedCollection).PropName);
  new(NodeData);
  NodeData.NodeType := ntCollection;
  NodeData.Collection := Collection;
  result.data := NodeData;
  Result.ImageIndex := 0;
  Result.SelectedIndex := 0;
end;

function TfrmCollectionEditor.AddTreeItem(Node: TTreeNode;
  NewItem: TCollectionItem): TTreeNode;
var
  NodeData : pNodeData;
begin
  Result := trvCollection.Items.AddChild(Node,inttostr(NewItem.Index) + ' - ' + NewItem.DisplayName);
  Result.MakeVisible;
  new(NodeData);
  NodeData.NodeType := ntItem;
  NodeData.Collection := NewItem.Collection;
  NodeData.Item := NewItem;
  NodeData.ItemId := NewItem.Id;
  Result.Data := NodeData;
  Result.ImageIndex := 1;
  Result.SelectedIndex := 1;
end;

procedure TfrmCollectionEditor.DeleteItem1Click(Sender: TObject);
var
  ItemId : Integer;
begin
  ItemId := (pNodeData(trvCollection.Selected.Data)^).ItemId;
  Singleton.trvCollection.Selected := Singleton.FindNode(((pNodeData(trvCollection.Selected.Data)^).Item as TOpNestedCollectionItem).ParentCollection);
  (pNodeData(trvCollection.Selected.Data)^).Collection.FindItemId(ItemID).Free;
  Designer.Modified;
  FormModified;
end;

function TfrmCollectionEditor.UniqueName(Component: TComponent): string;
begin
  Result := Component.Name;
end;


procedure TfrmCollectionEditor.SetButtonState;
var
  SelectedNode : TTreeNode;
begin
  SelectedNode := trvCollection.Selected;
  if assigned(SelectedNode) then
  begin
    btnNewItem.Enabled := pNodeData(SelectedNode.Data)^.NodeType = ntCollection;
    btnDeleteItem.Enabled := pNodeData(SelectedNode.Data)^.NodeType = ntItem;
    btnPrevLevel.Enabled := SelectedNode.GetPrev <> nil;
    btnNextLevel.Enabled := SelectedNode.GetNext <> nil;
  end
  else
  begin
    btnNewItem.Enabled := false;
    btnDeleteItem.Enabled := false;
    btnPrevLevel.Enabled := false;
    btnNextLevel.Enabled := false;
  end;

end;

function TfrmCollectionEditor.FindNode(Collection: TCollection): TTreeNode;
var
  Node: TTreeNode;
begin
  Result := nil;
  with trvCollection.Items do
  begin
    Node := GetFirstNode;
    while assigned(Node) do
    begin
      if pNodeData(Node.Data)^.Collection = Collection then
      begin
        Result := Node;
        exit;
      end;
      Node := Node.GetNext;
    end;
  end;
end;

procedure TfrmCollectionEditor.btnPrevLevelClick(Sender: TObject);
begin
  trvCollection.Selected := trvCollection.Selected.GetPrev;
end;

procedure TfrmCollectionEditor.btnNextLevelClick(Sender: TObject);
begin
  trvCollection.Selected := trvCollection.Selected.GetNext;
end;

procedure TfrmCollectionEditor.CustomItemClick(Sender: TObject);
begin
  GetNodeItem(trvCollection.Selected).ExecuteVerb((Sender as TMenuItem).MenuIndex - 3);
end;

function TfrmCollectionEditor.GetNodeItem(Node: TTreeNode): TOpNestedCollectionItem;
begin
  Result := ((pNodeData(Node.Data)^.Item) as TOpNestedCollectionItem);
end;

procedure TfrmCollectionEditor.Activated;
var
  Msg: TMessage;
begin
  Msg.Msg := WM_Activate;
  Msg.WParam := 1;
  {$IFDEF DCC6ORLATER}
    {!!!}
  {$ELSE}
    Designer.IsDesignMsg(Designer.Form,Msg);
  {$ENDIF}
end;

procedure TfrmCollectionEditor.trvCollectionKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  case Key of
    Vk_Delete: begin
                 if (trvCollection.Selected <> nil) and
                   (pNodeData(trvCollection.Selected.Data).NodeType = ntItem) then
                     DeleteItem1Click(self);
               end;

    Vk_Insert: begin
                 if (trvCollection.Selected <> nil) and
                   (pNodeData(trvCollection.Selected.Data).NodeType = ntCollection) then
                     AddItem1Click(self);
               end;

  end;
end;

procedure TfrmCollectionEditor.FormCreate(Sender: TObject);
begin
  FOldTreeProc := trvCollection.WindowProc;
  trvCollection.WindowProc := CustomTreeProc;
end;

//  Used to circumvent a bug introduced in Delphi 5 where OnMouseUp doesn't
//  fire for the TreeView.

procedure TfrmCollectionEditor.CustomTreeProc(var Message: TMessage);
var
  MousePos: TPoint;
begin
  if (Message.Msg = CN_Notify) then
  begin
    if TWMNotify(Message).NMHdr^.Code = NM_RCLICK then
    begin
      GetCursorPos(MousePos);
      with PointToSmallPoint(trvCollection.ScreenToClient(MousePos)) do
      begin
        trvCollection.Perform(WM_RBUTTONUP, 0, MakeLong(X, Y));
      end;
    end
    else
      FOldTreeProc(Message);
  end
  else
    FOldTreeProc(Message);
end;

procedure TfrmCollectionEditor.Copy1Click(Sender: TObject);
begin
  Clipboard.AsText := stsbrName.SimpleText;
end;

end.
