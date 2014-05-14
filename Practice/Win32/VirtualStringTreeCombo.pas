unit VirtualStringTreeCombo;

interface
 
uses
  Classes,
  SysUtils,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  VirtualTrees,
  messages,
  windows,
  StdCtrls,
  ChartExportToMYOBCashbook;

type
  TComboEditLink = class(TInterfacedObject, IVTEditLink)
  private
    fGSTMapCol : TGSTMapCol;
    FComboBox : TComboBox;
    FTree: TVirtualStringTree;
    FNode: PVirtualNode;
    FColumn: Integer;
  protected
    procedure EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ComboBoxCloseUp(Sender: TObject);
  public
    constructor Create(aParent : TWinControl; aGSTMapCol : TGSTMapCol);
    destructor Destroy; override;

    function BeginEdit: Boolean; stdcall;
    function CancelEdit: Boolean; stdcall;
    function EndEdit: Boolean; stdcall;
    function GetBounds: TRect; stdcall;
    function PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean; stdcall;
    procedure ProcessMessage(var Message: TMessage); stdcall;
    procedure SetBounds(R: TRect); stdcall;

    property ComboBox : TComboBox read FComboBox write FComboBox;
  end;

implementation

constructor TComboEditLink.Create(aParent : TWinControl; aGSTMapCol : TGSTMapCol);
begin
  inherited Create;

  fGSTMapCol := aGSTMapCol;

  FComboBox := TComboBox.Create(nil);
  FComboBox.Visible := False;
  FComboBox.Parent := aParent;
  FComboBox.OnKeyDown := EditKeyDown;
  fComboBox.OnCloseUp := ComboBoxCloseUp;
  FComboBox.Style := csDropDownList;
end;

destructor TComboEditLink.Destroy;
begin
  FComboBox.Free;
  inherited;
end;

procedure TComboEditLink.EditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        FTree.CancelEditNode;
        Key := 0;
        FTree.setfocus;
      end;
    VK_RETURN:
      begin
       PostMessage(FTree.Handle, WM_KEYDOWN, VK_DOWN, 0);
       Key := 0;
       FTree.EndEditNode;
       FTree.setfocus;
      end;
  End; //case
end;

function TComboEditLink.BeginEdit: Boolean;
begin
  Result := True;
  FComboBox.Top := FComboBox.Top - 3;
  FComboBox.Show;
  FComboBox.DroppedDown:=false;
  FComboBox.SetFocus;
end;

function TComboEditLink.CancelEdit: Boolean;
begin
  Result := True;
  FComboBox.Hide;
end;

procedure TComboEditLink.ComboBoxCloseUp(Sender: TObject);
begin
  FTree.EndEditNode;
  FTree.setfocus;
end;

function TComboEditLink.EndEdit: Boolean;
var
  S: WideString;
begin
  Result := True;
  S:= FComboBox.Text;
  FTree.Text[FNode, FColumn] := S;

  FTree.InvalidateNode(FNode);
  FComboBox.Hide;
  FTree.SetFocus;
end;
 
function TComboEditLink.GetBounds: TRect;
begin
  Result := FComboBox.BoundsRect;
end;
 
function TComboEditLink.PrepareEdit(Tree: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex): Boolean;
var
  GstClassIndex : integer;
  GstItemIndex : integer;
  CurrGSTMapItem : TGSTMapItem;
begin
  Result := True;
  FTree := Tree as TVirtualStringTree;
  FNode := Node;
  FColumn := Column;

  FComboBox.Visible := true;

  if fGSTMapCol.ItemAtColIndex(PNodeData(Tree.GetNodeData(Node)^).Source, CurrGSTMapItem) then
  begin
    GstItemIndex := -1;
    for GstClassIndex := 0 to length(fGSTMapCol.GetGSTClassMapArr)-1  do
    begin
      FComboBox.AddItem(fGSTMapCol.GetGSTClassMapArr[GstClassIndex].CashbookGstClassDesc,
                        fGSTMapCol.GetGSTClassMapArr[GstClassIndex]);

      if CurrGSTMapItem.CashbookGstClass = fGSTMapCol.GetGSTClassMapArr[GstClassIndex].CashbookGstClass then
        GstItemIndex := GstClassIndex;
    end;
    FComboBox.ItemIndex := GstItemIndex;
  end;
end;

procedure TComboEditLink.ProcessMessage(var Message: TMessage);
begin
  FComboBox.WindowProc(Message);
end;
 
procedure TComboEditLink.SetBounds(R: TRect);
var
  Dummy: Integer;
begin
  FTree.Header.Columns.GetColumnBounds(FColumn, Dummy, R.Right);
  FComboBox.BoundsRect := R;
end;
 
End.
