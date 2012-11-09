unit CAFAccountStatusFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, StdCtrls, ComCtrls, OSFont, BankLinkOnlineServices;

type
  TAccountFilterType = (afEverythingElse = 0, afActive = 1, afDeleted = 2);
  
  PNodeData = ^TNodeData;
  TNodeData = record
    Source: Integer;
  end;
  
  TfrmCAFAccountStatus = class(TForm)
    lvAccountStatus: TVirtualStringTree;
    Label1: TLabel;
    StatusBar1: TStatusBar;
    Button1: TButton;
    cmbAccountFilter: TComboBox;
    Label2: TLabel;
    procedure lvAccountStatusCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure FormCreate(Sender: TObject);
    procedure lvAccountStatusGetText(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
      var CellText: WideString);
    procedure cmbAccountFilterSelect(Sender: TObject);
    procedure lvAccountStatusHeaderClick(Sender: TVTHeader;
      Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    FAccountList: TBloArrayOfPracticeBankAccount;

    FLastSortedColumn: Integer;
    FLastSortDirection: TSortDirection;
    
    function Refresh: Boolean;
    
    function CheckFilter(const AccountStatus: String; FilterType: TAccountFilterType): Boolean;
    
    function DoDateColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
    function DoAccountNameColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
    function DoAccountNumberColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
    function DoClientCodeColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
    function DoStatusColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
    function DoAdditionalDetailsColumnCompare(NodeData1, NodeData2: PNodeData): Integer;

    procedure PopulateAccountStatusList;
    procedure SortAccountStatusList(Column: Integer); overload;
    procedure SortAccountStatusList(Column: Integer; Direction: TSortDirection); overload;
  public
    function Execute: Boolean;
    
    class procedure ExecuteModal(Owner: TComponent; PopupParent: TCustomForm); static;
  end;

var
  frmCAFAccountStatus: TfrmCAFAccountStatus;

implementation

{$R *.dfm}

{ TForm1 }

function TfrmCAFAccountStatus.CheckFilter(const AccountStatus: String; FilterType: TAccountFilterType): Boolean;
begin
  case FilterType of
    afEverythingElse: Result := not (CheckFilter(AccountStatus, afActive) or CheckFilter(AccountStatus, afDeleted));
    afActive: Result := CompareText(AccountStatus, 'Active') = 0;
    afDeleted: Result := CompareText(AccountStatus, 'Deleted') = 0;
  end;
end;

procedure TfrmCAFAccountStatus.cmbAccountFilterSelect(Sender: TObject);
begin
  PopulateAccountStatusList;

  if FLastSortedColumn > -1 then
  begin
    SortAccountStatusList(FLastSortedColumn, FLastSortDirection);
  end;
end;

function TfrmCAFAccountStatus.DoAccountNameColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
begin
  Result := CompareText(
    FAccountList[NodeData1.Source].AccountName + FormatDateTime('yyyymmdd', FAccountList[NodeData1.Source].CreatedDate.AsDateTime),
    FAccountList[NodeData2.Source].AccountName + FormatDateTime('yyyymmdd', FAccountList[NodeData2.Source].CreatedDate.AsDateTime));
end;

function TfrmCAFAccountStatus.DoAccountNumberColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
begin
  Result := CompareText(FAccountList[NodeData1.Source].AccountNumber, FAccountList[NodeData2.Source].AccountNumber);
end;

function TfrmCAFAccountStatus.DoAdditionalDetailsColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
begin
  Result := CompareText(
    FAccountList[NodeData1.Source].RejectionReason + FormatDateTime('yyyymmdd', FAccountList[NodeData1.Source].CreatedDate.AsDateTime) + FAccountList[NodeData1.Source].AccountName,
    FAccountList[NodeData2.Source].RejectionReason + FormatDateTime('yyyymmdd', FAccountList[NodeData2.Source].CreatedDate.AsDateTime) + FAccountList[NodeData2.Source].AccountName);
end;

function TfrmCAFAccountStatus.DoClientCodeColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
begin
  Result := CompareText(
    FAccountList[NodeData1.Source].FileNumber + FormatDateTime('yyyymmdd', FAccountList[NodeData1.Source].CreatedDate.AsDateTime) + FAccountList[NodeData1.Source].AccountName,
    FAccountList[NodeData2.Source].FileNumber + FormatDateTime('yyyymmdd', FAccountList[NodeData2.Source].CreatedDate.AsDateTime) + FAccountList[NodeData2.Source].AccountName);
end;

function TfrmCAFAccountStatus.DoDateColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
begin
  Result := CompareText(
    FormatDateTime('yyyymmdd', FAccountList[NodeData1.Source].CreatedDate.AsDateTime) + FAccountList[NodeData1.Source].AccountName,
    FormatDateTime('yyyymmdd', FAccountList[NodeData2.Source].CreatedDate.AsDateTime) + FAccountList[NodeData2.Source].AccountName);
end;

function TfrmCAFAccountStatus.DoStatusColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
begin
  Result := CompareText(
    FAccountList[NodeData1.Source].Status + FormatDateTime('yyyymmdd', FAccountList[NodeData1.Source].CreatedDate.AsDateTime) + FAccountList[NodeData1.Source].AccountName,
    FAccountList[NodeData2.Source].Status + FormatDateTime('yyyymmdd', FAccountList[NodeData2.Source].CreatedDate.AsDateTime) + FAccountList[NodeData2.Source].AccountName);
end;

function TfrmCAFAccountStatus.Execute: Boolean;
begin
  Result := Refresh;

  if Result then
  begin
    SortAccountStatusList(0);
  end;
end;

class procedure TfrmCAFAccountStatus.ExecuteModal(Owner: TComponent; PopupParent: TCustomForm);
var
  AccountStatusForm: TfrmCAFAccountStatus;
begin
  AccountStatusForm := TfrmCAFAccountStatus.Create(Owner);

  try
    AccountStatusForm.PopupParent := PopupParent;

    if AccountStatusForm.Execute then
    begin
      AccountStatusForm.ShowModal;
    end;
  finally
    AccountStatusForm.Free;
  end;
end;

procedure TfrmCAFAccountStatus.FormCreate(Sender: TObject);
begin
  FLastSortedColumn := -1;
  FLastSortDirection := sdAscending;

  lvAccountStatus.Header.Font := Self.Font;

  lvAccountStatus.Header.Height := Abs(lvAccountStatus.Header.Font.Height) * 10 DIV 6;

  lvAccountStatus.NodeDataSize := SizeOf(TNodeData);
  
  cmbAccountFilter.ItemIndex := 0;
end;

procedure TfrmCAFAccountStatus.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Chr(VK_ESCAPE) then
  begin
    Close;
  end;
end;

procedure TfrmCAFAccountStatus.PopulateAccountStatusList;
var
  Index: Integer;
  NodeData: PNodeData;
begin
  lvAccountStatus.Clear;

  for Index := 0 to Length(FAccountList) - 1 do
  begin
    if CheckFilter(FAccountList[Index].Status, TAccountFilterType(cmbAccountFilter.ItemIndex)) then
    begin
      New(NodeData);

      NodeData.Source := Index;

      lvAccountStatus.AddChild(nil, NodeData);
    end;
  end;
end;

function TfrmCAFAccountStatus.Refresh: Boolean;
begin
  FAccountList := ProductConfigService.GetAccountStatusList(Result);

  if Result then
  begin
    PopulateAccountStatusList;

    Result := True;
  end;
end;

procedure TfrmCAFAccountStatus.SortAccountStatusList(Column: Integer; Direction: TSortDirection);
begin
  lvAccountStatus.SortTree(Column, Direction);

  lvAccountStatus.Header.SortColumn := Column;
  lvAccountStatus.Header.SortDirection := Direction;

  FLastSortDirection := Direction;
end;

procedure TfrmCAFAccountStatus.SortAccountStatusList(Column: Integer);
begin
  if Column <> FLastSortedColumn then
  begin
    SortAccountStatusList(Column, sdAscending);
  end
  else
  if FLastSortDirection = sdAscending then
  begin
    SortAccountStatusList(Column, sdDescending);
  end
  else
  begin
    SortAccountStatusList(Column, sdAscending);
  end;

  FLastSortedColumn := Column;
end;

procedure TfrmCAFAccountStatus.lvAccountStatusCompareNodes(Sender: TBaseVirtualTree; Node1,
  Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
  NodeData1: PNodeData;
  NodeData2: PNodeData;
begin
  NodeData1 := PNodeData(Sender.GetNodeData(Node1)^);
  NodeData2 := PNodeData(Sender.GetNodeData(Node2)^);
   
  case Column of
    0: Result := DoDateColumnCompare(NodeData1, NodeData2);
    1: Result := DoAccountNameColumnCompare(NodeData1, NodeData2);
    2: Result := DoAccountNumberColumnCompare(NodeData1, NodeData2);
    3: Result := DoClientCodeColumnCompare(NodeData1, NodeData2);
    4: Result := DoStatusColumnCompare(NodeData1, NodeData2);
    5: Result := DoAdditionalDetailsColumnCompare(NodeData1, NodeData2);
  end;
end;

procedure TfrmCAFAccountStatus.lvAccountStatusGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
begin
  case Column of
    0: CellText := FormatDateTime('dd/mm/yy', FAccountList[PNodeData(Sender.GetNodeData(Node)^).Source].CreatedDate.AsDateTime);
    1: CellText := FAccountList[PNodeData(Sender.GetNodeData(Node)^).Source].AccountName;
    2: CellText := FAccountList[PNodeData(Sender.GetNodeData(Node)^).Source].AccountNumber;
    3: CellText := FAccountList[PNodeData(Sender.GetNodeData(Node)^).Source].FileNumber;
    4: CellText := FAccountList[PNodeData(Sender.GetNodeData(Node)^).Source].Status;
    5: CellText := FAccountList[PNodeData(Sender.GetNodeData(Node)^).Source].RejectionReason;
  end;
end;

procedure TfrmCAFAccountStatus.lvAccountStatusHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  SortAccountStatusList(Column);
end;

end.
