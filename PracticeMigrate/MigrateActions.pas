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
  TMigratestatus = (Running, Success, Failed);

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
    FWarning: Boolean;
    FRunSize: Int64;
    FTotSize: Int64;
    fTargetTime : tDateTime;
    fSpeed: Double;
    procedure SetItem(const Value: TGuidObject);
    procedure SetStatus(const Value: TMigratestatus);
    procedure Changed;
    procedure SetError(const Value: string);
    procedure ShowMe;
    procedure SetTarget(const Value: Integer);
    procedure SetCounter(const Value: Integer);
    function AddAction(Title: string; Insert: Boolean; AItem: TGuidObject = nil):TMigrateAction;
    procedure SetWarning(const Value: Boolean);
    procedure propagateWarning(FromNode:PVirtualNode);
    procedure SetRunSize(const Value: Int64);
    procedure SetTotSize(const Value: Int64);
    procedure SetCount(const Value: Integer);
    procedure SetSpeed(const Value: Double);
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
     property Warning: Boolean read FWarning write SetWarning;
     procedure AddCount(value: Integer = 1);
     procedure SkipCount(Value: Integer = 1);

     property TotSize: Int64 read FTotSize write SetTotSize;
     property RunSize: Int64 read FRunSize write SetRunSize;
     property Speed: Double read FSpeed write SetSpeed;
     procedure AddRunSize(value: Int64);

     property Error: string read FError write SetError;
     function NewAction(Title: string; AItem: TGuidObject = nil):TMigrateAction;
     function InsertAction(Title: string; AItem: TGuidObject = nil):TMigrateAction;
     procedure AddWarining(E: Exception);
     // Uesed for simple Actions, to create a sub action
     function Exception(E: Exception; Action: string = ''):TMigrateAction;
     function GetImageindex: Integer;

     function CheckCanceled: Boolean;
     procedure LogMessage(const Value: string);
  end;

var

   Statustime: TDateTime;

   procedure ClearMigrationCanceled;
   procedure SetMigrationCanceled;

   procedure LogMessage(Value1,Value: string);

implementation

uses
   Logutil,
   Windows,
   Forms;


const
   tag_Title = 0;
   tag_status = 1;
   tag_count = 2;
   tag_Time = 3;
   tag_Error = 4;
   tag_TimeLeft = 5;

   img_Processing = 0;
   img_success = 0;

   YeildCount = 50;
   StepSize = 200;

var
   ActionCount: Integer;
   FMigrationCanceled: Boolean;

procedure ClearMigrationCanceled;
begin
   FMigrationCanceled := False;
end;

procedure SetMigrationCanceled;
begin
   FMigrationCanceled := True;
   logutil.LogError('MigrateActions','User Canceled');
end;


procedure LogMessage(Value1,Value: string);
begin
  Logutil.LogMsg(lmInfo,Value1,Value );
end;

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

procedure TMigrateAction.AddRunSize(value: Int64);
begin
   if Value <= 0 then
     Exit;
   RunSize := fRunsize + Value;  
end;

procedure TMigrateAction.AddWarining(E: Exception);
begin
   Error := E.Message;
   Warning := True;
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

function TMigrateAction.CheckCanceled: Boolean;
begin
  if FMigrationCanceled then begin
     Error := 'Canceled';
     Result := True;
  end else
     Result := False;
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

function TMigrateAction.Exception(E: Exception; Action: string =''): TMigrateAction;
begin
   Result := InsertAction(Format ('Error %s', [Action]));
   Result.Error := E.Message;
end;

function TMigrateAction.GetImageindex: Integer;
begin
   Result := ord(Status);
   if Warning  then
      Result := 3; 
end;



function TMigrateAction.GetTagText(const Tag: Integer): string;

  function TimeToText(ForTime: tDateTime): string;
  var h,m,s,ms: word;
  begin
    result := '';
    if ForTime < 0  then
       Exit;
    
    DecodeTime(ForTime,h,m,s,ms);

    if h > 0 then begin
       Result := format('%dh %dm %ds',[h,m,s]);
    end else if m > 0 then begin
       Result := format('%dm %ds',[m,s]);

    end else if s > 1 then begin
       Result := format('%d.%.3ds',[s,ms]);

    end;
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

   tag_count : if Status = Running then begin
                  if fCounter > 0 then
                     Result := IntToStr(fCounter)
               end else if fCount > 0 then
                  Result := IntToStr(fCount)
               else if fTarget> 0 then
                  Result := IntToStr(fTarget);


   tag_Time :  if Status = Running then
                   Result := TimeTotext(Statustime - fstartTime)
               else
                   Result := TimeTotext(fstoptime - fstartTime);

   tag_TimeLeft : if Status = Running then
                   Result :=  TimeToText(fTargetTime - StatusTime);

   tag_Error : Result := Error;
  end;
end;

function TMigrateAction.InsertAction(Title: string;
  AItem: TGuidObject): TMigrateAction;
begin
   Result := AddAction(Title, True, AItem);
end;


procedure TMigrateAction.LogMessage(const Value: string);
begin
   MigrateActions.LogMessage(Title, Value);
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

procedure TMigrateAction.propagateWarning(FromNode: PVirtualNode);
var pn: PVirtualNode;
begin
   pn := FromNode.Parent;
   while Assigned(pn)
   and (Parentlist.Tree.RootNode <> pn) do begin
      TMigrateAction(ParentList.GetNodeItem(pn)).FWarning := True;
      pn := pn.Parent;
   end;
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
  if Value > '' then begin

     if FError > ''  then
        FError := FError + '; ';

     Logutil.LogError(Title, Value);

     FError := FError + Value;
  end;

  Status := Failed;//??
  Changed;
end;

procedure TMigrateAction.SetItem(const Value: TGuidObject);
begin
  FItem := Value;
  Changed;
end;



procedure TMigrateAction.SetRunSize(const Value: Int64);
begin
  if FRunSize <> Value then begin
     StatusTime := now;

     FRunSize := Value;

     if (FRunSize  < FTotSize)
     and (FRunSize > 0) then begin
        Speed := (StatusTime - fstartTime) / FRunSize;

        fTargetTime := (Speed * (fTotSize - FRunSize)) + StatuStime;
     end;
  end;
end;

procedure TMigrateAction.SetSpeed(const Value: Double);
begin
  FSpeed := Value;
  LogMessage(Format('%s speed %e',[title,fSpeed]));
end;

procedure TMigrateAction.SetStatus(const Value: TMigratestatus);

begin
  if Status = Value then
     Exit; // same...

  // Check the new value against the old one..
  try
     case Value of
     Running: ;
     Failed:  begin
                fStopTime := now;
                ShowMe;
                // Let all the parents know..
                propagateWarning(Self.Node);
             end;
     Success: begin
                fStopTime := now;
                if (Fstatus in [Failed]) then
                   Exit // Failed overwrites success
                else
                   ParentList.Tree.Expanded[Node] := Warning;
             end;
     end;
     FStatus := Value;
  finally
     Changed;
  end;
end;

procedure TMigrateAction.SetTarget(const Value: Integer);
begin
   FNextCountStep := 0;
   FTarget := Value;
   Changed;
end;

procedure TMigrateAction.SetTotSize(const Value: Int64);
begin
  FTotSize := Value;
  fTargetTime := 0;
end;

procedure TMigrateAction.SetWarning(const Value: Boolean);
begin
   FWarning := Value;
   if FWarning then
      propagateWarning(Self.Node);
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
   FMigrationCanceled := false;
end.
