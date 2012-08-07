unit VirtualTreeHandler;

interface
uses
//LogUtil,
menus, Controls ,actnlist,RZGroupbar, VirtualTrees,Classes, Contnrs, windows, Graphics ;

type
 TTreeBaseItem = class;

 // Data record for the TreeNode
 TTreeBaseData = packed record
    BaseItem : TTreeBaseItem;
 end;

 FindProc = function (Item : TTreeBaseItem; var testfor) : Boolean of object;

 TTreeBaseList = class (TObjectList)
 private

 protected   // So you can use it in other units..
    FGroupSortDirection: TSortDirection;
    FTree: TVirtualStringTree;
    FDetailGroup: TRZGroup;
    FNodePopup: TPopupMenu;
    FCurBaseItem: TTreeBaseItem;
    FCurBaseItemChange: TNotifyEvent;
    procedure SetCurBaseItemChange(const Value: TNotifyEvent);
    procedure SetCurBaseItem(const Value: TTreeBaseItem);
    procedure SetNodePopup(const Value: TPopupMenu);
    procedure SetDetailGroup(const Value: TRZGroup);
    procedure SetGroupSortDirection(const Value: TSortDirection);
    procedure SetTree(const Value: TVirtualStringTree);

    // Default Handelers...
    //procedure TreeOnClick(Sender: TObject);
    procedure TreeOnDblClick(Sender: TObject); virtual;
    procedure TreeOnChange(Sender: TBaseVirtualTree;Node: PVirtualNode);
    procedure TreeOnMouseDown (Sender: TObject; Button: TMouseButton;
                               Shift: TShiftState; X, Y: Integer);
    procedure TreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure TreeMeasureItem(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
    procedure TreeAfterCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure TreeBeforeCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect); virtual;
    procedure TreePaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure TreeGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure TreeCompareNodes(Sender: TBaseVirtualTree;
         Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure TreeGetNodePopup (Sender: TBaseVirtualTree;
         Node: PVirtualNode; Column: TColumnIndex; const P: TPoint;
         var AskParent: Boolean; var PopupMenu: TPopupMenu);
    procedure TreeEdited(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
 public
    constructor Create (ATree : TVirtualStringTree);
    destructor Destroy;  override;
    property Tree : TVirtualStringTree read FTree write SetTree;
    property DetailGroup : TRZGroup read FDetailGroup write SetDetailGroup;
    property NodePopup : TPopupMenu read FNodePopup write SetNodePopup;
    property OnCurBaseItemChange : TNotifyEvent read FCurBaseItemChange write SetCurBaseItemChange;
    // Sort Handeling
    property GroupSortDirection :TSortDirection read FGroupSortDirection write SetGroupSortDirection;
    // Find
    function FindItem (Test : FindProc; var TestFor): TTreeBaseItem;
    function TestGroupID (Item : TTreeBaseItem; var testfor) : Boolean;
    function FindGroupID (const Value: Integer) :TTreeBaseItem;
    procedure RemoveItems (Test : FindProc; var TestFor);
    procedure OnKeyDown(var Key: Word; Shift: TShiftState);virtual;
    // Node Handeling
    function GetNodeItem  (const Value: PVirtualNode): TTreeBaseItem;
    procedure SetNodeItem (const Value: PVirtualNode; aItem: TTreeBaseItem);
    function AddNodeItem (const ToNode: PVirtualNode; aItem: TTreeBaseItem):PVirtualNode;
    procedure AddItem (aItem: TTreeBaseItem);
    procedure RemoveItem(aItem :TTreeBaseItem);
    procedure ChangeNode(const Value : PVirtualNode);
    function GetColumnTag (const Column : Integer) : Integer;
    property CurBaseItem : TTreeBaseItem read FCurBaseItem write SetCurBaseItem;
    // Item Handeling
    procedure Refresh;virtual;
    procedure UpdateDetails(const Item: TTreeBaseItem);
 end;


 TTreeBaseItem = class (Tobject)
  private

  protected
    FGroupID: Integer;
    FParentList: TTreeBaseList;
    FNode: PVirtualNode;
    FTitle: string;
    FHint: string;

    procedure SetParentList(const Value: TTreeBaseList);
    procedure SetNode(const Value: PVirtualNode);
    procedure SetTitle(const Value: string);
    procedure SetGroupID(const Value: Integer);


  public
    constructor Create (ATitle : string; AGroupID : Integer);
    // properties
    property Title : string read FTitle write SetTitle;
    property ParentList : TTreeBaseList read FParentList write SetParentList;
    property Node : PVirtualNode read FNode write SetNode;
    property GroupID : Integer read FGroupID write SetGroupID; //Sort within a group
    function NodeSelected : Boolean;
    // Default Tree actions
    procedure DoChange(const value :TVirtualNodeStates);virtual;
    function GetTagText(const Tag: Integer): string; virtual;
    function GetTagHint(const Tag: Integer; Offset : TPoint) : string; virtual;
    procedure ClickTag(const Tag: Integer; Offset: TPoint; Button: TMouseButton; Shift:TShiftstate ); virtual;
    procedure DoubleClickTag(const Tag: Integer; Offset: TPoint); virtual;
    function GetNodeHeight (const Value : Integer) : Integer; virtual;
    procedure AfterPaintCell(const Tag : integer; Canvas: TCanvas; CellRect: TRect);virtual;
    procedure OnPaintText(const Tag : integer; Canvas: TCanvas;TextType: TVSTTextType );virtual;
    function CompareGroup(const Tag : integer; WithItem : TTreeBaseItem; SortDirection : TSortDirection) : Integer; virtual;
    function CompareTagText(const Tag : integer; WithItem : TTreeBaseItem; SortDirection : TSortDirection) : Integer; virtual;
    procedure UpdateDetails(Value: TRZGroup) ;virtual;
    procedure UpdateMenu(const Tag: Integer; Offset: TPoint; Value: TPopupMenu);virtual;
    procedure OnKeyDown (var Key: Word; Shift: TShiftState);virtual;
    // General // Help Bits..
    function Refresh: Boolean;virtual;
    function AddDetail (Value: string; ToGroup : TRZGroup;Action : TNotifyEvent = nil;
                                                          Data  : Pointer = nil ):TRzGroupItem;
    function AddMenuItem (Value: string; ToPopup: TmenuItem ):TmenuItem; overload;
    function AddMenuItem (Value: string; ToPopup: TmenuItem; Action : TNotifyEvent;
                                                        Tag: Integer = 0 ):TmenuItem; overload;
    function AddMenuItem (Value: string; ToPopup: TmenuItem; Action : TAction;
                                                        Tag: Integer = 0 ):TmenuItem;overload;
    procedure AddHint (const Value: string);

  end;


implementation

uses
   Math,
   SysUtils;

{ TTreeBaseList }

procedure TTreeBaseList.TreeBeforeCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);
begin
  if Column = Tree.Header.SortColumn then begin
    CellRect.Right := CellRect.Left + Tree.Header.Columns[ Column].Width;
    TargetCanvas.Brush.Color := $F7F7F7;
    TargetCanvas.FillRect( CellRect);
  end;;
end;

procedure TTreeBaseList.TreeCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);

var Item1, Item2 : TTreeBaseItem;
begin
   Item1 := GetNodeItem  (Node1);
   if not (assigned(Item1)) then Exit;

   Item2 := GetNodeItem  (Node2);
   if not (assigned(Item2)) then Exit;

   // Check the Group First
   Result := Item1.CompareGroup(GetColumnTag(Column),Item2,Tree.Header.SortDirection);

   if Result = 0 then
      Result := Item1.CompareTagText(GetColumnTag(Column),Item2,Tree.Header.SortDirection)
   else
      if FGroupSortDirection <> Tree.Header.SortDirection then
         Result := -Result;
end;

procedure TTreeBaseList.TreeEdited(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex);
begin
   with Tree.Header do
      if Column = SortColumn then
         Tree.SortTree( SortColumn, SortDirection);
end;

procedure TTreeBaseList.TreeGetHint(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);

var LBase : TTreeBaseItem;
    MousePos : TPoint;
    CellRect : TRect;
begin
   try
     lbase := GetNodeItem  (Node);
     if assigned(LBase) then  begin
         // Have something to Hint...
         MousePos := Mouse.CursorPos;
         MousePos := Tree.ScreenToClient(MousePos);
         CellRect := Tree.GetDisplayRect(Node, Column, False );
         dec(MousePos.x, CellRect.Left);
         dec(Mousepos.y, Cellrect.Top );
         CellText := LBase.GetTagHint( GetColumntag(Column), Mousepos)
     end;
   except
   end;
end;

procedure TTreeBaseList.TreeGetNodePopup(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; const P: TPoint;
  var AskParent: Boolean; var PopupMenu: TPopupMenu);

var LBase : TTreeBaseItem;
    C : Integer;
    Offset : TPoint;
begin
   PopupMenu := nil;
   if not assigned(NodePopup) then
      Exit;
   lbase := GetNodeItem(Node);
   if not assigned(LBase) then
      Exit;
   NodePopup.Items.Clear;
   Offset := P;
   for C:= 0 to Tree.Header.Columns.Count - 1 do
      if (Tree.Header.Columns[C].Left <= Offset.x)
      and (Tree.Header.Columns[C].Left
            + Tree.Header.Columns[C].Width  > Offset.x) then begin
           dec(Offset.X, Tree.Header.Columns[C].Left);
           Break;
      end;

   lBase.Updatemenu(GetColumntag(Column),Offset,NodePopup);
   if NodePopup.Items.Count > 0 then begin
      // Somethings been added..
      PopupMenu := NodePopup;
      AskParent := False;
   end;
end;

procedure TTreeBaseList.TreePaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
var LBase : TTreeBaseItem;
begin
  try
     if (Column < 0)
     or (Column >= Tree.Header.Columns.Count)  then
         Exit; // Meaningless outside normal columns..
     lbase := GetNodeItem(Node);
     if assigned(LBase) then
        lBase.OnPaintText (GetColumntag(Column), TargetCanvas,TextType);
   except
   end;
end;

procedure TTreeBaseList.UpdateDetails(const Item: TTreeBaseItem);
begin
  //ClearActions;
  if assigned (FDetailGroup) then begin
     FDetailGroup.Items.BeginUpdate;
     try

         FDetailGroup.Items.Clear;

         if assigned(item) then
            Item.UpdateDetails(FDetailGroup);

     finally
        FDetailGroup.Items.EndUpdate;
     end;
  end;
  

end;

procedure TTreeBaseList.AddItem(aItem: TTreeBaseItem);
begin
   if Not assigned (AItem)  then
      Exit;
   Self.Add(AItem);
   AItem.ParentList := Self;
end;

function TTreeBaseList.AddNodeItem(const ToNode: PVirtualNode;
  aItem: TTreeBaseItem):PVirtualNode;
begin
   Result := nil;
   if Not assigned (aItem)  then
      Exit;
   Result := Tree.AddChild(ToNode);
   SetNodeItem(Result,aItem);
   AddItem(aItem);

   if not AItem.Refresh then begin// After Parent is Set...
      RemoveItem(AItem);
      Result := nil;
   end;
end;

procedure TTreeBaseList.ChangeNode(const Value: PVirtualNode);
begin
  if Assigned(Value) then
     TreeOnChange(Tree, Value);
end;

constructor TTreeBaseList.Create(ATree: TVirtualStringTree);
begin
   inherited Create(True);
   Tree := ATree;
end;

function TTreeBaseList.FindGroupID(const Value: Integer): TTreeBaseItem;
var LV : Integer;
begin
   LV := Value;
   Result := FindItem(TestGroupID,LV);
end;

function TTreeBaseList.FindItem(Test : FindProc; var TestFor): TTreeBaseItem;
var I : Integer;
begin
  Result := nil;
  for I := 0 to (Count - 1) do
    if test(TTreeBaseItem(Items[i]),TestFor) then begin
       Result := TTreeBaseItem(Items[i]);
       Break;
    end;
end;

function TTreeBaseList.GetColumnTag(const Column: Integer): Integer;
begin
   if (Column < 0)
   or (Column >= Tree.Header.Columns.Count) then
      Result := 0
   else
      Result := Tree.Header.Columns.Items[Column].Tag
end;


function TTreeBaseList.GetNodeItem(const Value: PVirtualNode): TTreeBaseItem;
var LTreeData : ^TTreeBaseData;
begin
   Result := nil;
   if value = nil then exit;
   LTreeData := Tree.GetNodeData (Value);
   if not assigned(LTreeData) then exit;   
   Result := LTreeData^.BaseItem;
end;

procedure TTreeBaseList.OnKeyDown(var Key: Word; Shift: TShiftState);
var LBase: TTreeBaseItem;
    lNode: PVirtualNode;
begin
   lNode := Tree.GetFirstSelected;
   while assigned(lNode) do begin

      lBase := GetNodeItem(lNode);
      if assigned(LBase) then
        lBase.OnKeyDown(Key,Shift);

      lNode := Tree.GetNextSelected(LNode);  
   end;
end;

procedure TTreeBaseList.Refresh;
var I : Integer;
begin
   I := 0;
   while I <  Count do begin
      with TTreeBaseItem(Items[I]) do
      if Refresh then begin
         if NodeSelected
         and assigned(FDetailGroup) then
            Self.UpdateDetails(TTreeBaseItem(Items[I]));
         inc(I);
      end else
         RemoveItem(TTreeBaseItem(Items[I]))

   end;
end;

procedure TTreeBaseList.RemoveItem(aItem: TTreeBaseItem);
begin
   if assigned(aItem) then begin
      if aItem.Node <> nil then begin
         if aItem = CurBaseItem then
            CurBaseItem := nil;

         SetNodeItem(aItem.Node,nil);
         Tree.DeleteNode(aItem.Node,false);
      end;
      aItem.ParentList := nil;
      self.Remove(aItem);
   end;
end;

procedure TTreeBaseList.RemoveItems(Test: FindProc; var TestFor);
var LItem: TTreeBaseItem;
begin
   repeat
      LItem := FindItem(Test,TestFor);
      RemoveItem(LItem);
   until (LItem = nil); //Tecnicaly no longer assigned...
end;

procedure TTreeBaseList.SetGroupSortDirection(const Value: TSortDirection);
begin
  FGroupSortDirection := Value;
end;


procedure TTreeBaseList.SetNodeItem(const Value: PVirtualNode;
  aItem: TTreeBaseItem);
var LTreeData : ^TTreeBaseData;
begin
   if Value = nil then exit;
   // Compiler stuffs up the pointer handeling..
   LTreeData := Tree.GetNodeData (Value);
   LTreeData^.BaseItem := aItem;
   if assigned(AItem) then begin
      AItem.Node := Value;
   end;
end;

procedure TTreeBaseList.SetNodePopup(const Value: TPopupMenu);
begin
  FNodePopup := Value;
end;

procedure TTreeBaseList.SetCurBaseItem(const Value: TTreeBaseItem);
begin
  if FCurBaseItem <> Value then begin
     FCurBaseItem := Value;
     if assigned(FCurBaseItemChange) then
       FCurBaseItemChange(Self);
  end;
end;

procedure TTreeBaseList.SetCurBaseItemChange(const Value: TNotifyEvent);
begin
  FCurBaseItemChange := Value;
end;

procedure TTreeBaseList.SetDetailGroup(const Value: TRZGroup);
begin
  FDetailGroup := Value;
end;

procedure TTreeBaseList.SetTree(const Value: TVirtualStringTree);
begin
   FTree := Value;
   if assigned(FTree) then begin
      FTree.NodeDataSize := Sizeof(TTreeBaseData);
      //FTree.OnClick := TreeOnClick;
      FTree.OnMouseDown := TreeOnMouseDown;
      FTree.OnDblClick := TreeOnDblClick;
      FTree.OnAfterCellPaint := TreeAfterCellPaint;
      FTree.OnBeforeCellPaint := TreeBeforeCellPaint;
      FTree.OnGetText := TreeGetText;
      FTree.OnGetHint := TreeGetHint;
      FTree.OnPaintText := TreePaintText;
      FTree.OnMeasureItem := TreeMeasureItem;
      FTree.OnCompareNodes := TreeComparenodes;
      FTree.OnGetPopupMenu := TreeGetNodePopup;
      FTree.OnEdited := TreeEdited;
      FTree.OnChange := TreeOnChange;
   end;
end;

function TTreeBaseList.TestGroupID(Item: TTreeBaseItem; var testfor): Boolean;
begin
   Result := Item.FGroupID = Integer(testfor);
end;

procedure TTreeBaseList.TreeAfterCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  CellRect: TRect);

var LBase : TTreeBaseItem;
begin
   try
     lbase := GetNodeItem  (Node );
     if assigned(LBase) then
        lBase.AfterPaintCell (GetColumntag(Column),TargetCanvas,CellRect);
   except
   end;
end;

procedure TTreeBaseList.TreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);

var LBase : TTreeBaseItem;
begin
   try
     lbase := GetNodeItem (Node);
     if assigned(LBase) then
         CellText:= lbase.getTagText(GetColumntag(Column));
   except
   end;
end;


procedure TTreeBaseList.TreeMeasureItem(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; var NodeHeight: Integer);
var LBase : TTreeBaseItem;
begin
   try
     lbase := GetNodeItem(Node);
     if assigned(LBase) then
        NodeHeight := Lbase.GetNodeHeight(NodeHeight);
   except
   end;
end;


procedure TTreeBaseList.TreeOnChange(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var LBase : TTreeBaseItem;
begin
   try
     lbase := GetNodeItem  (Node);
     if assigned(LBase) then begin
        Lbase.DoChange(Node.States);
        if Lbase.NodeSelected then begin
           if assigned(FDetailGroup) then
             Self.UpdateDetails(Lbase);
        end else begin
           LBase := nil;
           // Removing selections in multi select
           if Assigned(FCurBaseItemChange) then
              FCurBaseItemChange(Self);
        end;
     end;
     CurBaseItem := LBase;
   except
   end;
end;


procedure TTreeBaseList.TreeOnDblClick(Sender: TObject);
var MousePos : TPoint;
    Node: PVirtualNode;
    Column : Integer;
    LItem : TTreeBaseItem;
begin
   MousePos := Mouse.CursorPos;
   MousePos := Tree.ScreenToClient(MousePos);
   Node := Tree.GetNodeAt(MousePos.x, MousePos.y, True,Column);

   if not assigned(Node) then
      Exit;

   LItem := GetNodeItem(node);
   if not assigned(LItem)  then
      Exit;

   for Column := 0 to Tree.Header.Columns.Count - 1 do
      if (Tree.Header.Columns[Column].Left <= MousePos.x)
      and (Tree.Header.Columns[Column].Left
            + Tree.Header.Columns[Column].Width  > MousePos.x) then begin
           dec(MousePos.X, Tree.Header.Columns[Column].Left);
           Break;
      end;
   LItem.DoubleClickTag( GetColumntag(Column), Mousepos );
   { // may not be selected..
   if assigned(FDetailGroup) then
      Self.UpdateDetails(Result);
   }
   //Tree.RepaintNode(Node); // May have been refreshed..
   Tree.Invalidate;
end;

procedure TTreeBaseList.TreeOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
    LItem : TTreeBaseItem;
    Node : PVirtualNode;
    Column : Integer;
begin
   Node := Tree.GetNodeAt(X,Y, True,Column);
   if not assigned(Node) then
      Exit;

   LItem := GetNodeItem  (node);
   if not assigned(LItem)  then
      Exit;

   for Column := 0 to Tree.Header.Columns.Count - 1 do
      if (Tree.Header.Columns[Column].Left <= X )
      and (Tree.Header.Columns[Column].Left
            + Tree.Header.Columns[Column].Width  > X) then begin
           dec(X, Tree.Header.Columns[Column].Left);
           Break;
      end;

   LItem.ClickTag(GetColumntag(Column),Point(X,Y),Button,Shift);
   { // may not be selected..
   if assigned(FDetailGroup) then
      Self.UpdateDetails(Result);
   }
   Tree.RepaintNode(Node); // May have Changed..

end;


destructor TTreeBaseList.Destroy;
begin
   UpdateDetails(nil);// Make sure we have no loose ends
   inherited;
end;

{ TTreeBaseItem }

function  TTreeBaseItem.AddDetail(Value: string; ToGroup : TRZGroup;Action : TNotifyEvent = nil;
                                                          Data  : Pointer = nil ):TRzGroupItem;
begin
 if Value > '' then begin
    Result := ToGroup.Items.Add;
    Result.Caption := Value;
    Result.OnClick := Action;
    Result.Data  := Data;
 end else
    Result := nil;
end;

procedure TTreeBaseItem.AddHint(const Value: string);
begin
   if Value= '' then
      Exit; // Nothing to do..
   if FHint > '' then
      FHint := FHint + #10; // Add New line...
   FHint := FHint + Value;
end;

function TTreeBaseItem.AddMenuItem(Value: string;
  ToPopup: TmenuItem): TmenuItem;
begin
   Result := TmenuItem.Create(ToPopup);
   Result.Caption := Value;
   ToPopup.add(Result);
end;

function TTreeBaseItem.AddMenuItem(Value: string; ToPopup: TmenuItem;
  Action: TNotifyEvent; Tag: Integer): TmenuItem;
begin
   Result := AddMenuItem(Value,ToPopup);
   Result.OnClick := Action;
   Result.Tag := Tag;
end;

function TTreeBaseItem.AddMenuItem(Value: string; ToPopup: TmenuItem;
  Action: TAction; Tag: Integer): TmenuItem;
begin
   Result := AddMenuItem(Value,ToPopup);
   Result.Action := Action;
   Result.Tag := Tag;
end;

procedure TTreeBaseItem.AfterPaintCell(const Tag: integer; Canvas: TCanvas;
  CellRect: TRect);
begin

end;

procedure TTreeBaseItem.ClickTag(const Tag: Integer; Offset: TPoint;
  Button: TMouseButton; Shift:TShiftstate);
begin

end;

function TTreeBaseItem.CompareGroup(const Tag: integer; WithItem: TTreeBaseItem;
  SortDirection: TSortDirection): Integer;
begin // Default..
   Result := CompareValue(GroupID, WithItem.GroupID);
end;

function TTreeBaseItem.CompareTagText(const Tag: integer;
  WithItem: TTreeBaseItem; SortDirection : TSortDirection): Integer;

  function  CompareText (const S1,S2 : string): integer;
  begin
     Result := SysUtils.CompareText(S1,S2);
     if SortDirection = sdAscending then
       if (S1 = '') // Keep the spaces at the bottom
       or (S2 = '') then Result := - Result;
  end;

begin
   if assigned(WithItem) then
      Result := CompareText(GetTagText(Tag),WithItem.GetTagText(Tag))
   else Result := 1;
end;

constructor TTreeBaseItem.Create(ATitle: string; AGroupID: Integer);
begin
   inherited Create;
   Title := ATitle;
   GroupID := AGroupID;
end;

procedure TTreeBaseItem.DoChange(const value: TVirtualNodeStates);
begin

end;

procedure TTreeBaseItem.DoubleClickTag(const Tag: Integer; Offset: TPoint);
begin

end;

function TTreeBaseItem.GetNodeHeight(const Value: Integer): Integer;
begin
   Result := value;
end;

function TTreeBaseItem.GetTagHint(const Tag: Integer; Offset: TPoint): string;
begin
  Result := Title;
end;

function TTreeBaseItem.GetTagText(const Tag: Integer): string;
begin
   Result := Title;
end;

procedure TTreeBaseItem.OnPaintText(const Tag: integer; Canvas: TCanvas;
  TextType: TVSTTextType);
begin

end;

function TTreeBaseItem.Refresh: Boolean;
begin
   Result := True;
end;

function TTreeBaseItem.NodeSelected: Boolean;
begin
  Result := False;
  // Can't be selected if i have no node...
  if Assigned(FNode) then
      Result := vsSelected in FNode.States;
end;

procedure TTreeBaseItem.SetGroupID(const Value: Integer);
begin
  FGroupID := Value;
end;

procedure TTreeBaseItem.SetNode(const Value: PVirtualNode);
begin
  FNode := Value;
end;

procedure TTreeBaseItem.SetParentList(const Value: TTreeBaseList);
begin
  FParentList := Value;
end;

procedure TTreeBaseItem.SetTitle(const Value: string);
begin
  FTitle := Value;
end;

procedure TTreeBaseItem.OnKeyDown(var Key: Word; Shift: TShiftState);
begin

end;

procedure TTreeBaseItem.UpdateDetails(Value: TRZGroup);
begin
    value.Caption := 'Details';
    // Means litle here.. but you can copy..


    AddDetail('ID: ' + IntToStr(GroupId), Value);
    AddDetail('Title: ' + Title, Value);

end;

procedure TTreeBaseItem.UpdateMenu(const Tag: Integer; Offset: TPoint;
  Value: TPopupMenu);
begin

end;

end.
