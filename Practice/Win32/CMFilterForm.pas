// Dialog to select a client manager filter
unit CMFilterForm;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  ExtCtrls,
  ImgList,
  StdCtrls,
  bkConst,
  Menus,
  OsFont;

type
  saFilters = (saAttached, saNew, saDeleted, saInactive, saSecure, saThisYear,
                saPassword, saCharge, saFreqMonth, saFreqWeek, saFreqDay,
                saFreqUnspecified, saProvisional, saOnlineSecure, saSecureAndOnlineSecure);

  saFilter = set of saFilters;

  FiltersTextProc = function (Value: saFilters): string;

  TfrmFilter = class(TForm)
    pnlButton: TPanel;
    tvFilter: TTreeView;
    imStates: TImageList;
    btnApply: TButton;
    btnCancel: TButton;
    btnReset: TButton;
    popFilter: TPopupMenu;
    ExpandAll1: TMenuItem;
    CollapseAll1: TMenuItem;
    N1: TMenuItem;
    ResetFilter1: TMenuItem;
    procedure tvFilterClick(Sender: TObject);
    procedure tvFilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnResetClick(Sender: TObject);
    procedure ExpandAll1Click(Sender: TObject);
    procedure CollapseAll1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure SimplifyFilter;
  end;

  saFilterSet = class(TPersistent)
  private
    procedure SetEmpty(const Value: Boolean);
    function GetEmpty: Boolean;
  public
    Nodes: array [safsTopMin .. safsTopMax] of saFilter;
    NotNodes: array [safsTopMin .. safsTopMax] of saFilter;
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    function IsEqual(Value: saFilterSet): Boolean;
    property Empty: Boolean read GetEmpty write SetEmpty;
    procedure Clear;
    function getFilterText: string;
  end;

function ChooseCMFilter(P: TPoint; W, H: Integer; CurrentFilter: UInt64;
  var FilterName: string; var UserFilter: TStringList; var GroupFilter: TStringList;
  var ClientTypeFilter: TStringList; const ShowForm: Boolean): UInt64;
function ChooseSAFilter(P: TPoint; W, H: Integer; var Include: saFilterSet ): TModalresult;
function FilterText(Value: saFilters): string;
function NotFilterText(Value: saFilters): string;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  UxTheme,
  AuthorityUtils,
  WinUtils,
  Math,
  Globals,
  SyDefs,
  BkHelp,
  bkXPThemes,
  CountryUtils, bkBranding;

const
  // 0 doesn't work so use a dummy image :S
  cFlatUnCheck = 1;
  cFlatChecked = 2;
//  cFlatRadioUnCheck = 3;
//  cFlatRadioChecked = 4;

//------------------------------------------------------------------------------
function FilterText(Value: saFilters): string;
begin
  case Value of
    saAttached : Result := 'attached';
    saNew      : Result := 'new';
    saDeleted  : Result := 'marked as deleted';
    saInactive : Result := 'inactive';
    saSecure   : Result := 'Books Secure';
    saThisYear : Result := 'have transactions this year';
    saPassword : Result := 'password protected';
    saCharge   : Result := 'charged';
    saFreqMonth: Result := 'monthly';
    saFreqWeek : Result := 'weekly';
    saFreqDay  : Result := 'daily';
    saFreqUnspecified: Result := 'unspecified';
    saProvisional    : Result := 'provisional';
    saOnlineSecure   : Result := bkBranding.ProductOnlineName + ' Secure';
  end;
end;

//------------------------------------------------------------------------------
function NotFilterText(Value: saFilters): string;
begin
  case Value of
    saAttached : Result := 'unattached';
    saNew      : Result := 'not new';
    saDeleted  : Result := 'not marked as deleted';
    saInactive : Result := 'active';
    saSecure   : Result := 'Local';
    saThisYear : Result := 'without transactions this year';
    saPassword : Result := 'not password protected';
    saCharge   : Result := 'not charged';
    saFreqMonth: Result := 'not monthly';
    saFreqWeek : Result := 'not weekly';
    saFreqDay  : Result := 'not daily';
    saFreqUnspecified: Result := 'not unspecified';
    saProvisional    : Result := 'not provisional';
    saOnlineSecure   : Result := 'not Online Secure';
    saSecureAndOnlineSecure : Result := 'Local';
  end;
end;

//------------------------------------------------------------------------------
procedure ToggleTreeViewCheckBoxes(Node: TTreeNode);
begin
  if Assigned(Node) then
  begin
    if Node.StateIndex = cFlatUnCheck then // swap
      Node.StateIndex := cFlatChecked
    else if Node.StateIndex = cFlatChecked then // swap
      Node.StateIndex := cFlatUnCheck
  end;
end;

// Reset to show all
//------------------------------------------------------------------------------
procedure TfrmFilter.btnResetClick(Sender: TObject);
var
  topn, n: TTreeNode;
begin
  topn := tvFilter.Items.GetFirstNode;
  while assigned(topn) do begin
     n := topn.GetFirstChild;
     while Assigned(n) do begin
        n.StateIndex := cFlatUnCheck;
         n := n.GetNextSibling;
     end;
     topn := topn.GetNextSibling;
  end;
end;

// Only toggle if clicked on the box itself
//------------------------------------------------------------------------------
procedure TfrmFilter.CollapseAll1Click(Sender: TObject);
begin
  tvFilter.FullCollapse;
end;

//------------------------------------------------------------------------------
procedure TfrmFilter.ExpandAll1Click(Sender: TObject);
begin
  tvFilter.FullExpand;
end;

//------------------------------------------------------------------------------
procedure TfrmFilter.FormCreate(Sender: TObject);
begin
  BKHelpSetUp(Self, BKH_Filtering_files_in_the_Clients_page);
  bkXPThemes.ThemeForm(Self);
  SetVistaTreeView(tvFilter.Handle);
end;

//------------------------------------------------------------------------------
procedure TfrmFilter.FormShow(Sender: TObject);
begin
  btnApply.Setfocus;
end;

//------------------------------------------------------------------------------
procedure TfrmFilter.tvFilterClick(Sender: TObject);
var
  P:TPoint;
begin
  GetCursorPos(P);
  P := tvFilter.ScreenToClient(P);
  if (htOnStateIcon in tvFilter.GetHitTestInfoAt(P.X,P.Y)) then
    ToggleTreeViewCheckBoxes(tvFilter.Selected);
end;

// Allow keyboard control
//------------------------------------------------------------------------------
procedure TfrmFilter.tvFilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_SPACE) and 
     Assigned(tvFilter.Selected) then
       ToggleTreeViewCheckBoxes(tvFilter.Selected);
end;

// Untick everything if all nodes are ticked within a group
//------------------------------------------------------------------------------
procedure TfrmFilter.SimplifyFilter;
var
  topn, n: TTreeNode;
  IsAllChecked: Boolean;

  procedure UnCheckAll;
  begin
    n := topn.GetFirstChild;
    while Assigned(n) do
    begin
      n.StateIndex := cFlatUnCheck;
      n := n.GetNextSibling;
    end;
  end;

begin
  topn := tvFilter.Items.GetFirstNode;
  while Assigned(topn) do
  begin
    n := topn.GetFirstChild;
    IsAllChecked := True;
    while Assigned(n) do
    begin
      if n.StateIndex = cFlatUnCheck then
      begin
        IsAllChecked := False;
        Break;
      end;
      n := n.GetNextSibling;
    end;
    if IsAllChecked then
      UnCheckAll;
    topn := topn.GetNextSibling;
  end;
end;

// P - screen point for top left corner of dialog
// W - width (to match button)
// H - height
// CurrentFilter - current sub filter value
// FilterName - current filter name (button caption)
// UserFilter - current user filter list
// GroupFilter - current user filter list
// ClientTypeFilter - current user filter list
//------------------------------------------------------------------------------
function ChooseCMFilter(P: TPoint; W, H: Integer; CurrentFilter: UInt64; var FilterName: string;
  var UserFilter: TStringList; var GroupFilter: TStringList; var ClientTypeFilter: TStringList; const ShowForm: Boolean): UInt64;
var
  i, j, x, mr: Integer;
  topn, n: TTreeNode;
  u: pUser_Rec;
  g: pGroup_Rec;
  c: pClient_Type_Rec;
  AddedToFilter, Collapse: Boolean;
  NewFilterName, fn: string;
  NewUserFilter, NewGroupFilter, NewClientTypeFilter: TStringList;
begin
  Result := 0;
  NewFilterName := '';
  mr := mrCancel;
  NewUserFilter := TStringList.Create;
  NewGroupFilter := TStringList.Create;
  NewClientTypeFilter := TStringList.Create;
  with TfrmFilter.Create(nil) do
  try
  begin
    // Add all the filter options
    tvFilter.Items.Clear;
    for i := cmfsTopMin to cmfsTopMax do
    begin
      Collapse := True;
      topn := tvFilter.Items.AddObject(nil, Localise(AdminSystem.fdFields.fdCountry, cmfsTopLevel[i]), TObject(i));
      for j := cmfsMin to cmfsMax do
      begin
        if (j = cmfsSCSV) and
           ( (AdminSystem.fdFields.fdCountry <> whAustralia) or
             ((AdminSystem.fdFields.fdCountry = whAustralia) ) and (not Globals.PRACINI_CSVExport) ) then
        begin
           if (CurrentFilter AND cmfsBits[j]) = cmfsBits[j] then
              CurrentFilter := CurrentFilter - cmfsBits[j];
           Continue;
        end;
        if cmfsFilterGroup[j] = i then
        begin
          n := tvFilter.Items.AddChildObject(topn, cmfsNames[j], TObject(j));
          if (CurrentFilter AND cmfsBits[j]) = cmfsBits[j] then
          begin
            Collapse := False;
            n.StateIndex := cFlatChecked;
          end
          else
            n.StateIndex := cFlatUnCheck;
        end;
      end;
      if i = cmfsTopUser then // Add all users to the users group
      begin
        for j := AdminSystem.fdSystem_User_List.First to AdminSystem.fdSystem_User_List.Last do
        begin
          u := AdminSystem.fdSystem_User_List.User_At(j);
          if u.usName <> '' then
            n := tvFilter.Items.AddChildObject(topn, u.usCode + ' - ' + u.usName, nil)
          else
            n := tvFilter.Items.AddChildObject(topn, u.usCode, nil);
          if UserFilter.IndexOf(u.usCode) > -1 then
          begin
            Collapse := False;
            n.StateIndex := cFlatChecked;
          end
          else
            n.StateIndex := cFlatUnCheck
        end;
      end;
      if i = cmfsTopGroup then // Add all groups to the groups group
      begin
        for j := AdminSystem.fdSystem_Group_List.First to AdminSystem.fdSystem_Group_List.Last do
        begin
          g := AdminSystem.fdSystem_Group_List.Group_At(j);
          n := tvFilter.Items.AddChildObject(topn, g.grName, nil);
          if GroupFilter.IndexOf(g.grName) > -1 then
          begin
            Collapse := False;
            n.StateIndex := cFlatChecked;
          end
          else
            n.StateIndex := cFlatUnCheck
        end;
      end;
      if i = cmfsTopClientType then // Add all client types to the client types group
      begin
        for j := AdminSystem.fdSystem_Client_Type_List.First to AdminSystem.fdSystem_Client_Type_List.Last do
        begin
          c := AdminSystem.fdSystem_Client_Type_List.Client_Type_At(j);
          n := tvFilter.Items.AddChildObject(topn, c.ctName, nil);
          if ClientTypeFilter.IndexOf(c.ctName) > -1 then
          begin
            Collapse := False;
            n.StateIndex := cFlatChecked;
          end
          else
            n.StateIndex := cFlatUnCheck
        end;
      end;
      if Collapse then
        topn.Collapse(False)
      else
        topn.Expand(False);
    end;
    // Make it look ok in 265 colour
    if WinUtils.GetScreenColors(Canvas.Handle) <= 256 then
      pnlButton.Color := clGray;
    // Position it next to the button
    Left:= P.X;
    Top := P.Y;
    Width := W;
    Height := H;
    // Default fully expanded if no filter
    if (CurrentFilter = 0) and (UserFilter.Count = 0) and (GroupFilter.Count = 0) and (ClientTypeFilter.Count = 0) then
      tvFilter.FullCollapse;
    // Show the top node if we are scrolling
    tvFilter.Items[0].MakeVisible;
    if ShowForm then
      mr := ShowModal
    else
      mr := mrOk;
    if mr = mrOk then
    begin
      SimplifyFilter;
      // Build new filter and filter name
      topn := tvFilter.Items.GetFirstNode;
      for i := cmfsTopMin to cmfsTopMax do
      begin
        n := topn.GetFirstChild;
        AddedToFilter := False;
        while Assigned(n) do
        begin
          if n.StateIndex = cFlatChecked then
          begin
            if (i = cmfsTopUser) and (n.Text <> cmfsNames[cmfsUnassigned]) then
            begin // Handle users differently
               x := Pos (' - ', n.Text);
               if x > 0 then
                  fn := Copy(n.Text, 1, Pos(' - ', n.Text)-1)
               else
                  fn := n.Text;
               NewUserFilter.Add(fn);
            end else if (i = cmfsTopGroup) and (n.Text <> cmfsNames[cmfsUnassignedGroup]) then begin
               // Handle groups differently
               NewGroupFilter.Add(n.Text);
               fn := n.Text;
            end else if (i = cmfsTopClientType) and (n.Text <> cmfsNames[cmfsUnassignedClientType]) then begin
               // Handle users differently
               NewClientTypeFilter.Add(n.Text);
               fn := n.Text;
            end else begin
               // normal filtering
               x := Integer(n.Data);
               Result := Result OR cmfsBits[x];
               fn := n.Text;
            end;
            if (not AddedToFilter) and (NewFilterName <> '') then
               NewFilterName := NewFilterName + ' AND (';
            if NewFilterName = '' then
               NewFilterName := NewFilterName + 'Filter: (' + fn
            else if AddedToFilter then
               NewFilterName := NewFilterName + ' OR ' + fn
            else
               NewFilterName := NewFilterName + fn;
            AddedToFilter := True;
          end;
          n := n.GetNextSibling;
        end;
        if AddedToFilter then
          NewFilterName := NewFilterName + ')';
        topn := topn.GetNextSibling;
      end;
    end;
  end
  finally
    Free;
    if mr = mrOk then
    begin
      if (Result = 0) and (NewUserFilter.Count = 0) and (NewGroupFilter.Count = 0) and (NewClientTypeFilter.Count = 0) then // reset
      begin
        UserFilter.Clear;
        GroupFilter.Clear;
        ClientTypeFilter.Clear;
        FilterName := FILTER_ALL;
        Result := 0;
      end
      else // changed, Result has been calculated
      begin
        UserFilter.Text := NewUserFilter.Text;
        GroupFilter.Text := NewGroupFilter.Text;
        ClientTypeFilter.Text := NewClientTypeFilter.Text;
        FilterName := NewFilterName;
      end;
    end
    else
      Result := CurrentFilter;
    NewUserFilter.Free;
    NewGroupFilter.Free;
    NewClientTypeFilter.Free;
  end;
end;

//------------------------------------------------------------------------------
function ChooseSAFilter(P: TPoint; W, H: Integer; var Include: saFilterSet ): TModalresult;
var
   I: Integer;
   topn: TTreeNode;
   LInclude: saFilterSet;
   ftNode: array [0..10] of boolean;

   function CheckNode(Node: TTreeNode; Value: Boolean):Boolean;
   begin
      if Value then
         Node.StateIndex := cFlatChecked
      else
         Node.StateIndex := cFlatUnCheck;
      Result := Value;
   end;

   procedure Expand(Node: TTreeNode; Value: Boolean);
   begin
      if Value then
         Node.Expand(True)
      else
         Node.Collapse(False);
   end;

   function GetBoolArray(Value: TTreeNode): Integer;
   var Node: TTReeNode;
   begin // Counts children and fills the ftNode array
      Result := 0;
      FillChar(ftNode,Sizeof(ftNode),0);
      Node := Value.GetFirstChild;
      while Node <> nil do begin
         ftNode[Result] := Node.StateIndex = cFlatChecked;
         Inc(Result);
         Node := Value.GetNextChild(Node);
      end;
   end;

begin
   Result := mrNone;
   LInclude := saFilterSet.Create;
   with TfrmFilter.Create(nil) do
   try
      // Position the form
      SetBounds(P.X,P.Y, W, H);
      // Update the captions and hints..
      Caption := 'Filter Accounts';
      btnReset.Hint := 'Reset the current selected filter to Show All Accounts';
      // Fill inthe tree
      for i := safsTopMin to safsTopMax do begin

         topn := tvFilter.Items.AddObject(nil, Localise(AdminSystem.fdFields.fdCountry, safsTopLevel[i]), TObject(i));
         // Just keep it simple for now..
         {$B+} // Full boolean, in order
         case i  of
         safsTopStatus : Expand(topn,

                          {0}     CheckNode( tvFilter.Items.AddChild(topn,'New'),sanew in Include.Nodes[i])
                          {1}  or CheckNode( tvFilter.Items.AddChild(topn,'Unattached'),saAttached in Include.NotNodes[i])
                          {2}  or CheckNode( tvFilter.Items.AddChild(topn,'Inactive'),saInactive in Include.Nodes[i])
                          {3}  or CheckNode( tvFilter.Items.AddChild(topn,'Attached'),saAttached in Include.Nodes[i])
                          {4  or CheckNode( tvFilter.Items.AddChild(topn,'Not Marked as Deleted'),saDeleted in Include.NotNodes[i])
                          {5  or CheckNode( tvFilter.Items.AddChild(topn,'Marked as Deleted'),saDeleted in Include.Nodes[i])}
                          );

         safsTopDeleted :Expand(topn,
                               CheckNode( tvFilter.Items.AddChild(topn,'Marked as Deleted'),saDeleted in Include.Nodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'Not Marked as Deleted'),saDeleted in Include.NotNodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'Inactive'),saInactive in Include.Nodes[i])
                          );
         safsTopTransactions: Expand(topn,
                               CheckNode( tvFilter.Items.AddChild(topn,'Transactions in the Last 12 Months'),saThisyear in Include.Nodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'No Transactions in the Last 12 Months'),saThisYear in Include.NotNodes[i])
                          );
         safsTopCharges :Expand(topn,
                               CheckNode( tvFilter.Items.AddChild(topn,'Charged'),saCharge in Include.Nodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'Flagged as No Charge'),saCharge in Include.NotNodes[i])
                          );
         safsTopPassword :Expand(topn,
                               CheckNode( tvFilter.Items.AddChild(topn,'Password Protected'),saPassword in Include.Nodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'Not Password Protected'),saPassword in Include.NotNodes[i])
                          );
         safsTopDeliver :Expand(topn,
                               CheckNode( tvFilter.Items.AddChild(topn,'Practice Accounts'), (saSecureAndOnlineSecure in Include.NotNodes[i]))
                            or CheckNode( tvFilter.Items.AddChild(topn,'Provisional Accounts'),saProvisional in Include.Nodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'Books Secure Accounts'),saSecure in Include.Nodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn, bkBranding.ProductOnlineName + ' Secure Accounts'),saOnlineSecure in Include.Nodes[i])

                          );
         safsTopFrequency:Expand(topn,
                               CheckNode( tvFilter.Items.AddChild(topn,'Monthly'),    saFreqMonth in Include.NotNodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'Weekly'),     saFreqWeek in Include.Nodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'Daily'),      saFreqDay in Include.Nodes[i])
                            or CheckNode( tvFilter.Items.AddChild(topn,'Unspecified'),saFreqUnspecified in Include.Nodes[i])
                          );
         end;
         {$B-}
      end;



      //******************************
      if ShowModal = mrOK then begin
      //******************************
          //Build the filter...

          topn := tvFilter.Items.GetFirstNode;
          while assigned(topn) do begin
             I := GetBoolArray(topn);
             case Integer(topn.Data) of
               safsTopStatus: if I = 4 then begin
                     if ftNode[0] then                                                                 
                        LInclude.Nodes[safsTopStatus] := LInclude.Nodes[safsTopStatus] + [sanew];
                     if ftNode[1] and (not ftNode[3]) then
                        LInclude.NotNodes[safsTopStatus] := LInclude.NotNodes[safsTopStatus] +  [saAttached];
                     if ftNode[2] then
                        LInclude.Nodes[safsTopStatus] := LInclude.Nodes[safsTopStatus] + [saInactive];
                     if ftNode[3] and (not ftNode[1]) then
                        LInclude.Nodes[safsTopStatus] := LInclude.Nodes[safsTopStatus] +  [saAttached];
                     {if ftNode[4] and (not ftNode[5]) then
                        LInclude.NotNodes[safsTopStatus] := LInclude.NotNodes[safsTopStatus] +  [saDeleted];
                     if ftNode[5] and (not ftNode[4]) then
                        LInclude.Nodes[safsTopStatus] := LInclude.Nodes[safsTopStatus] +  [saDeleted];}

                  end;
                safsTopDeleted: if I = 3 then begin
                     if ftNode[1] and (not ftNode[0]) then
                        LInclude.NotNodes[safsTopDeleted] := LInclude.NotNodes[safsTopDeleted] +  [saDeleted];
                     if ftNode[0] and (not ftNode[1]) then
                        LInclude.Nodes[safsTopDeleted] := LInclude.Nodes[safsTopDeleted] +  [saDeleted];
                     if ftNode[2] then
                        LInclude.Nodes[safsTopDeleted] := LInclude.Nodes[safsTopDeleted] + [saInactive];
                  end;
                safsTopTransactions: if I = 2 then begin
                     if ftNode[1] and (not ftNode[0]) then
                        LInclude.NotNodes[safsTopTransactions] := LInclude.NotNodes[safsTopTransactions] +  [saThisyear];
                     if ftNode[0] and (not ftNode[1]) then
                        LInclude.Nodes[safsTopTransactions] := LInclude.Nodes[safsTopTransactions] +  [saThisyear];
                  end;
                safsTopCharges: if I = 2 then begin
                     if ftNode[1] and (not ftNode[0]) then
                        LInclude.NotNodes[safsTopCharges] := LInclude.NotNodes[safsTopCharges] +  [saCharge];
                     if ftNode[0] and (not ftNode[1]) then
                        LInclude.Nodes[safsTopCharges] := LInclude.Nodes[safsTopCharges] +  [saCharge];
                  end;
                safsTopPassword: if I = 2 then begin
                     if ftNode[1] and (not ftNode[0]) then
                        LInclude.NotNodes[safsTopPassword] := LInclude.NotNodes[safsTopPassword] +  [saPassword];
                     if ftNode[0] and (not ftNode[1]) then
                        LInclude.Nodes[safsTopPassword] := LInclude.Nodes[safsTopPassword] +  [saPassword];
                  end;
                safsTopDeliver: if I = 4 then begin
                     // if Practice, Books Secure, and BankLink Online Secure Accounts are all selected,
                     // this is equivalent to having nothing selected
                     if not (ftNode[0] and ftNode[2] and ftNode[3]) then
                     begin
                       if ftNode[0] then
                       begin
                         LInclude.NotNodes[safsTopDeliver] := (LInclude.NotNodes[safsTopDeliver] + [saSecureAndOnlineSecure]);
                         if ftNode[2] then
                           LInclude.Nodes[safsTopDeliver] := (LInclude.Nodes[safsTopDeliver] + [saSecure]);
                       end;
                       if ftNode[2] and (not ftNode[0]) then
                          LInclude.Nodes[safsTopDeliver] := LInclude.Nodes[safsTopDeliver] + [saSecure];
                       if ftNode[1] then
                          LInclude.Nodes[safsTopDeliver] := LInclude.Nodes[safsTopDeliver] + [saProvisional];
                       if ftNode[3] then
                          LInclude.Nodes[safsTopDeliver] := LInclude.Nodes[safsTopDeliver] + [saOnlineSecure];
                     end;
                  end;
                safsTopFrequency: if I = 4 then begin
                     if ftNode[0] then
                        LInclude.Nodes[safsTopFrequency] := LInclude.Nodes[safsTopFrequency] +  [saFreqMonth];
                     if ftNode[1] then
                        LInclude.Nodes[safsTopFrequency] := LInclude.Nodes[safsTopFrequency] +  [saFreqWeek];
                     if ftNode[2] then
                        LInclude.Nodes[safsTopFrequency] := LInclude.Nodes[safsTopFrequency] +  [saFreqDay];
                     if ftNode[3] then
                        LInclude.Nodes[safsTopFrequency] := LInclude.Nodes[safsTopFrequency] +  [saFreqUnspecified];
                  end;

             end;
             topn := topn.GetNextSibling;
          end;

          if not Include.IsEqual(LInclude) then begin
             Include.Assign(LInclude);
             Result := mrOK
          end else
             Result := mrCancel; // No Change...

      end;
   finally
      Free;
      LInclude.Free;
   end;
end;

{ saFilterSet }
//------------------------------------------------------------------------------
procedure saFilterSet.Assign(Source: TPersistent);
var n: Integer;
    Sourcefs:saFilterSet;
begin
   if Source is saFilterSet then begin
      Sourcefs := saFilterSet(Source);
      for n := Low(Nodes) to High(Nodes) do begin
        Nodes[n] := Sourcefs.Nodes[n];
        NotNodes[n] := Sourcefs.NotNodes[n];
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure saFilterSet.Clear;
var n: Integer;
begin
   for n := Low(Nodes) to High(Nodes) do begin
      Nodes[n] := [];
      NotNodes[n] := [];
   end;
end;

//------------------------------------------------------------------------------
constructor saFilterSet.Create;
begin
   inherited;
   Clear;
end;

//------------------------------------------------------------------------------
function saFilterSet.GetFilterText: string;
var n: Integer;
   function NodeText: string;
      procedure AddFilter(Filter: saFilter; TextProc: FiltersTextProc);
      var fltr: saFilters;
          procedure Add(Value: string);
          begin
             if Result > '' then
                Result := Result + ' or ';
             Result := Result + Value;
          end;
      begin
         if Filter = [] then
            Exit;
         for fltr in Filter do
             Add(TextProc(fltr));
      end;
   begin
      Result := '';
      AddFilter(Nodes[n],FilterText);
      AddFilter(NotNodes[n],NotFilterText);
   end;

begin
   if Empty then
      Result := 'All accounts'
   else begin
      Result := '';
      for n := Low(Nodes) to High(Nodes) do begin
         if (Nodes[n] <> [])
         or (NotNodes[n] <> []) then begin
            if Result > '' then
               Result := Result + ' and are ';
            Result := Result  + NodeText;
         end;
      end;
      Result := 'Accounts that are ' + Result;

      // There can be cases where we want a different header from what is normally generated,
      // so we override them here
      if (Nodes[safsTopDeliver] = [saSecure]) and
      (NotNodes[safsTopDeliver] = [saSecureAndOnlineSecure]) then
        Result := 'Accounts that are not Online Secure';
   end;
end;

//------------------------------------------------------------------------------
function saFilterSet.GetEmpty: Boolean;
var n: Integer;
begin
   Result := False;
   for n := Low(Nodes) to High(Nodes) do begin
      if Nodes[n] <> [] then
         Exit;
      if NotNodes[n] <> [] then
         Exit;
   end;
   Result := True;
end;

//------------------------------------------------------------------------------
function saFilterSet.IsEqual(Value: saFilterSet): Boolean;
var n: Integer;
begin
   Result := False;
   for n := Low(Nodes) to High(Nodes) do begin
      if Nodes[n] <> Value.Nodes[n] then
         Exit;
      if NotNodes[n] <> Value.NotNodes[n] then
         Exit;
   end;
   Result := True;
end;

//------------------------------------------------------------------------------
procedure saFilterSet.SetEmpty(const Value: Boolean);
begin
   if Value then
      Clear;
end;

end.
