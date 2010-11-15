unit MigrateActions;

interface

uses
  Types,
  Graphics,
  SysUtils,
  VirtualTrees,
  VirtualTreeHandler,
  GuidList;

type
  TMigratestatus = (Running, Success, Failed, Warning);

  TMigrateList = class (TTreeBaseList)
  private
     procedure Paintbackground(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect; var CustomDraw: Boolean) ;
     procedure BeforeErase(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
                           var ItemColor: TColor; var EraseAction: TItemEraseAction);
     procedure GetImageIndex(Sender: TBaseVirtualTree;
                             Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
                             var Ghosted: Boolean; var ImageIndex: Integer);
  public
     function InsertNodeItem(const ToNode: PVirtualNode; aItem: TTreeBaseItem):PVirtualNode;
     procedure Hookup;
  end;

  TMigrateAction = class (TTreeBaseItem)
  private
    FCount: Integer;
    FStatus: TMigratestatus;
    FItem: TGuidObject;
    fStartTime : tDateTime;
    fStopTime : tDateTime;
    FError: string;
    FTarget: Integer;
    FCounter: Integer;
    FNextCountStep: Integer;
    procedure SetCount(const Value: Integer);
    procedure SetItem(const Value: TGuidObject);
    procedure SetStatus(const Value: TMigratestatus);
    procedure Changed;
    procedure SetError(const Value: string);
    procedure ShowMe;
    procedure SetTarget(const Value: Integer);
    procedure SetCounter(const Value: Integer);
    function AddAction(Title: string; Insert: Boolean; AItem: TGuidObject = nil):TMigrateAction;
  protected
    procedure Paintbackground(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; R: TRect;
                               var Handled: Boolean);


  published
  public
     constructor Create(Title: string; AItem: TGuidObject = nil);
     function GetTagText(const Tag: Integer): string; override;

     procedure OnPaintText(const Tag: integer; Canvas: TCanvas;
                             TextType: TVSTTextType); override;

     property Status: TMigratestatus read FStatus write SetStatus;
     property Item: TGuidObject read FItem write SetItem;

     // Count repesents the actual final count
     property Count: Integer read FCount write SetCount;
     // Target repesents the expected final count
     property Target: Integer read FTarget write SetTarget;
      // Counter repesents the current count
     property Counter: Integer read FCounter write SetCounter;
     procedure AddCount(value: Integer = 1);
     procedure SkipCount(Value: Integer = 1);


     property Error: string read FError write SetError;
     function NewAction(Title: string; AItem: TGuidObject = nil):TMigrateAction;
     function InsertAction(Title: string; AItem: TGuidObject = nil):TMigrateAction;
     function Exception(E:Exception):TMigrateAction;
     function GetImageindex: Integer;
  end;

var
   MigrationCanceled: Boolean;
   Statustime: TDateTime;


implementation

uses
   Windows,
   Forms;


const
   tag_Title = 0;
   tag_status = 1;
   tag_count = 2;
   tag_Time = 3;
   tag_Error = 4;

   img_Processing = 0;
   img_success = 0;

   YeildCount = 50;
   StepSize = 200;

var
   ActionCount: Integer;

{ MigrateAction }


function TMigrateAction.AddAction(Title: string; Insert: Boolean; AItem: TGuidObject): TMigrateAction;
begin
   Result := TMigrateAction.Create(Title, AItem);
   if Assigned(ParentList) then begin
      if Insert
      and (ParentList is TMigrateList) then
         Result.Node := TMigrateList(ParentList).InsertNodeItem(Self.Node, Result)
      else
         Result.Node := ParentList.AddNodeItem(Self.Node, Result);
      ParentList.Tree.Expanded[Self.Node] := True;
      ParentList.Tree.ScrollIntoView(Node, False);
   end;
   Changed;
end;

procedure TMigrateAction.AddCount(value: Integer);
begin
   Counter := FCounter + Value;
end;

procedure TMigrateAction.Changed;
var lNode: PVirtualNode;
begin
   if not Assigned(Node) then
      Exit;
   if not Assigned(ParentList) then
      Exit;
   if not Assigned(ParentList.Tree) then
      Exit;

   lNode := Node;
   while Assigned(lNode) do begin
      if Parentlist.Tree.RootNode = LNode then
         Break;
      Parentlist.Tree.InvalidateNode(LNode);
      LNode := LNode.Parent;
   end;

   Parentlist.Tree.Update;
   inc(ActionCount);
   if actionCount > YeildCount then begin
      ActionCount := 0;
      Application.ProcessMessages;
   end;
end;

constructor TMigrateAction.Create(Title: string; AItem: TGuidObject);
begin
   inherited create(Title,0);
   fStartTime := Now;
   FNextCountStep := 0;
   Ftarget := 0;
   FCounter := 0;

   Item := AItem;
end;

function TMigrateAction.Exception(E: Exception): TMigrateAction;
begin
   Result := InsertAction('Error');
   Result.Error := E.Message;
end;

function TMigrateAction.GetImageindex: Integer;
begin
   Result := ord(Status);
end;

function TMigrateAction.GetTagText(const Tag: Integer): string;

  function GetTimeText(ForTime: TDateTime): string;
  var dif: tdatetime;
  begin
     result := '';
     dif := ForTime - fstartTime;
     if dif < (1 / MinsPerDay /60) then

        Exit; // Les than a second...

     if dif > (1/ MinsPerday * 20) then
        // More than 20 min..
        Result := FormatDateTime('hh:nn:ss', dif)
     else
        Result := FormatDateTime('nn:ss.zzz', dif)
  end;

begin
  Result := '';
  case tag of
   tag_Title : Result := Title;
   tag_status : case Status of
          Running : Result := 'Running';
          Failed  : Result := 'Failed';
          Success : Result := 'OK';
     end;
   tag_count : if fCount > 0 then
        Result := IntToStr(fCount);
   tag_Time :  if Status = Running then
                   Result := GetTimeText(Statustime)
               else
                   Result := GetTimeText(fstoptime);

   tag_Error : Result := Error;
  end;
end;

function TMigrateAction.InsertAction(Title: string;
  AItem: TGuidObject): TMigrateAction;
begin
   Result := AddAction(Title, True, AItem);
end;


function TMigrateAction.NewAction(Title: string;
  AItem: TGuidObject): TMigrateAction;
begin
   Result := AddAction(Title, False, AItem);
end;


procedure TMigrateAction.OnPaintText(const Tag: integer; Canvas: TCanvas;
  TextType: TVSTTextType);
begin
    Canvas.TextFlags  := Canvas.TextFlags and (not ETO_OPAQUE);
end;

procedure TMigrateAction.Paintbackground(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; R: TRect;
                               var Handled: Boolean);
begin
    Handled := False;

    TargetCanvas.Brush.Color := clWindow;
    TargetCanvas.FillRect(R);

    if (Status <> Running)
    or (Target = 0)
    or (Counter = 0) then
       Exit; // done...

    // Paint the bar..
    r.Left := TVirtualStringTree(sender).Header.Columns[0].Width;

    r.Right := r.Left + ((R.Right - R.Left) * Counter) div Target;

    TargetCanvas.Brush.Color :=  RGB(195,225,150);
    TargetCanvas.FillRect(R);
end;

procedure TMigrateAction.SetCount(const Value: Integer);
begin
  FCount := Value;
  if Status = Running then
     Status := Success;
  Changed;
end;

procedure TMigrateAction.SetCounter(const Value: Integer);
begin
  FCounter := Value;
  if FCounter >= FNextCountStep then begin
     if FTarget > (StepSize * 2) then
        FNextCountStep := FNextCountStep + FTarget div StepSize;
     Changed;
  end;
end;

procedure TMigrateAction.SetError(const Value: string);
begin
  FError := Value;
  Status := Failed;
  Changed;
end;

procedure TMigrateAction.SetItem(const Value: TGuidObject);
begin
  FItem := Value;
  Changed;
end;

procedure TMigrateAction.SetStatus(const Value: TMigratestatus);

   procedure propagateWarning(FromNode:PVirtualNode);
   var pn: PVirtualNode;
   begin
      pn := FromNode.Parent;
      while assigned(pn)
      and (Parentlist.Tree.RootNode <> pn) do begin
         TMigrateAction(ParentList.GetNodeItem(pn)).Status := Warning;
         pn := pn.Parent;
      end;
   end;


begin
  if Status = Value then
     Exit; // same...

  // Check the new value against the old one..
  case Value of
    Running: ;
    Failed:  begin
                ShowMe;
                propagateWarning(Self.Node.Parent);
             end;
    Success: if (Fstatus in [Warning, Failed]) then
                Exit
             else
                ParentList.Tree.Expanded[Node] := False;
    Warning: begin
                propagateWarning(self.Node);
                if(Fstatus in [Failed]) then
                   Exit;
             end;
             
  end;
  FStatus := Value;

  fStopTime := now;
  Changed;
end;

procedure TMigrateAction.SetTarget(const Value: Integer);
begin
   FNextCountStep := 0;
   FTarget := Value;
   Changed;
end;

procedure TMigrateAction.ShowMe;
var pn: PVirtualNode;
begin
   pn := self.Node;
   while Assigned(pn) do begin
      ParentList.Tree.Expanded[pn] := true;
      pn := pn.Parent;
      if Parentlist.Tree.RootNode = pn then
        Break;
   end;
   Changed;
end;

procedure TMigrateAction.SkipCount(Value: Integer);
begin
   if FTarget > 0 then
      Target := FTarget - Value;
end;

{ TMigrateList }

procedure TMigrateList.BeforeErase(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var ItemColor: TColor; var EraseAction: TItemEraseAction);
begin
   EraseAction := eaNone;
end;

procedure TMigrateList.GetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
  if Kind in [ikNormal, ikSelected] then
   case GetColumnTag(Column) of
   tag_Title: ImageIndex := TMigrateAction(self.GetNodeItem (Node)).GetImageindex;
   end;
end;

function TMigrateList.InsertNodeItem(const ToNode: PVirtualNode; aItem: TTreeBaseItem): PVirtualNode;
begin
   Result := nil;
   if not Assigned (aItem) then
      Exit;
   Result := Tree.InsertNode(ToNode,amAddChildFirst);
   SetNodeItem(Result,aItem);
   AddItem(aItem);

   if not AItem.Refresh then begin// After Parent is Set...
      RemoveItem(AItem);
      Result := nil;
   end;
end;

procedure TMigrateList.Paintbackground(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
  var CustomDraw: Boolean);

var Nodedata : TMigrateAction;
begin
    NodeData := GetNodeItem(Node) as TMigrateAction;
    if Assigned(NodeData) then
       NodeData.Paintbackground(Sender,TargetCanvas,ItemRect,CustomDraw);
end;

procedure TMigrateList.Hookup;
begin
    Tree.OnBeforeItemErase := BeforeErase;
    Tree.OnBeforeItemPaint := Paintbackground;
    Tree.OnGetImageIndex := GetImageIndex;
    Tree.DefaultNodeHeight := 24;
end;

initialization
   ActionCount := 0;
   MigrationCanceled := false;
end.
