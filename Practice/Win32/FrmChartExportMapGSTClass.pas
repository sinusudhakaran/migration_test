unit FrmChartExportMapGSTClass;

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
  OSFont,
  VirtualTrees,
  StdCtrls,
  ChartExportToMYOBCashbook,
  VirtualStringTreeCombo;

//------------------------------------------------------------------------------
type
  TFrmChartExportMapGSTClass = class(TForm)
    grpMain: TGroupBox;
    lblGstRemapFile: TLabel;
    edtGstReMapFile: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    btnSave: TButton;
    btnSaveAs: TButton;
    btnBrowse: TButton;
    virGstReMap: TVirtualStringTree;
    SaveDlg: TSaveDialog;
    OpenDlg: TOpenDialog;
    procedure btnBrowseClick(Sender: TObject);
    procedure virGstReMapGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure FormCreate(Sender: TObject);
    procedure virGstReMapCreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure virGstReMapFocusChanged(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex);
    procedure virGstReMapNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: WideString);
    procedure virGstReMapCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
    procedure virGstReMapHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure btnSaveClick(Sender: TObject);
    procedure btnSaveAsClick(Sender: TObject);
    procedure virGstReMapPaintText(Sender: TBaseVirtualTree;
      const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType);
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    fGSTMapCol : TGSTMapCol;
    FLastSortedColumn: Integer;
    FLastSortDirection: TSortDirection;
    fOkPressed : boolean;

    function OverWriteCheck(aFileName: string): Boolean;
    function DoIdColumnCompare(NodeData1, NodeData2: PNodeData) : Integer;
    function DoGstDescColumnCompare(NodeData1, NodeData2: PNodeData) : Integer;
    function DoMYOBGstColumnCompare(NodeData1, NodeData2: PNodeData) : Integer;

    procedure SortAccountStatusList(Column: Integer; Direction: TSortDirection); overload;
    procedure SortAccountStatusList(Column: Integer); overload;

    procedure FocusGrid(Grid: TVirtualStringTree);
    procedure Refesh;
    function Validate() : boolean;
  public
    function Execute : boolean;
    property GSTMapCol : TGSTMapCol read fGSTMapCol write fGSTMapCol;
  end;

  //----------------------------------------------------------------------------
  function ShowMapGSTClass(w_PopupParent: Forms.TForm; aGSTMapCol : TGSTMapCol) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ErrorMoreFrm,
  WarningMoreFrm,
  Globals,
  YesNoDlg;

//------------------------------------------------------------------------------
function ShowMapGSTClass(w_PopupParent: Forms.TForm; aGSTMapCol : TGSTMapCol) : boolean;
var
  MyDlg : TFrmChartExportMapGSTClass;
begin
  result := false;

  MyDlg := TFrmChartExportMapGSTClass.Create(Application.mainForm);
  try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode   := pmExplicit;
    MyDlg.GSTMapCol   := aGSTMapCol;

    //BKHelpSetUp(MyDlg, BKH_Setting_up_BankLink_users);
    Result := MyDlg.Execute;
  finally
    FreeAndNil(MyDlg);
  end;
end;

{ TFrmChartExportMapGSTClass }
//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.btnBrowseClick(Sender: TObject);
var
  FileName : string;
  ErrorStr : string;
begin
  FileName := edtGstReMapFile.Text;

  OpenDlg.FileName := FileName;
  OpenDLG.Filter := 'CSV File *.csv|*.csv';
  OpenDLG.FilterIndex := 0;
  if OpenDlg.Execute then
  begin
    FileName := OpenDlg.FileName;
    if GSTMapCol.LoadGSTFile(FileName, ErrorStr) then
    begin
      edtGstReMapFile.Text := FileName;
      btnSave.Enabled := true;
      Refesh;
    end
    else
      HelpfulErrorMsg(ErrorStr,0);
  end;
  FocusGrid(virGstReMap);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.btnSaveClick(Sender: TObject);
var
  FileName : string;
  ErrorStr : string;
begin
  FileName := edtGstReMapFile.Text;

  if not GSTMapCol.SaveGSTFile(FileName, ErrorStr) then
    HelpfulErrorMsg(ErrorStr,0);

  FocusGrid(virGstReMap);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.btnOkClick(Sender: TObject);
begin
  fOkPressed := true;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.btnSaveAsClick(Sender: TObject);
var
  FileName : string;
  ErrorStr : string;
begin
  FileName := edtGstReMapFile.Text;

  if FileName = '' then
    FileName := Globals.DataDir + MyClient.clFields.clCode + '_'+ MyClient.TaxSystemNameUC + 'Map.csv';

  SaveDlg.FileName := FileName;
  if SaveDlg.Execute then
  begin
    FileName := SaveDlg.FileName;
    if OverWriteCheck(FileName) then
      if GSTMapCol.SaveGSTFile(FileName, ErrorStr) then
        edtGstReMapFile.Text := FileName
      else
        HelpfulErrorMsg(ErrorStr,0);
  end;
  FocusGrid(virGstReMap);
end;

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.OverWriteCheck(aFileName: string): Boolean;
begin
  if FileExists(aFileName) then
    Result :=  AskYesNo('File Exists',
                        format( '%s'#13'already exists, do you want to overwrite?',[aFileName]),
                        dlg_yes, 0) = dlg_yes //overwrite
  else
    Result := True;// does not exist We'r ok..
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.FocusGrid(Grid: TVirtualStringTree);
begin
  if not Assigned(Grid.FocusedNode) then
    Grid.FocusedNode := Grid.RootNode.FirstChild;
  if Grid.FocusedColumn < 0 then
    Grid.FocusedColumn := 0;
  Grid.Selected[Grid.FocusedNode] := true;
  Grid.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.Refesh;
var
  GstIndex : integer;
  NodeData: PNodeData;
begin
  if Assigned(GSTMapCol) then
  begin
    virGstReMap.BeginUpdate;
    virGstReMap.Clear;
    for GstIndex := 0 to GSTMapCol.Count-1 do
    begin
      New(NodeData);

      NodeData.Source := GstIndex;

      virGstReMap.AddChild(nil, NodeData);
    end;
    virGstReMap.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.virGstReMapCreateEditor(Sender: TBaseVirtualTree;
                                                             Node: PVirtualNode;
                                                             Column: TColumnIndex;
                                                             out EditLink: IVTEditLink);
begin
  if Column = 2 then
  begin
    EditLink := TComboEditLink.Create(Sender, fGSTMapCol);
  end
  else
    EditLink := TStringEditLink.Create;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.virGstReMapFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  if Column = 2 then
    virGstReMap.EditNode(Node, Column);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.virGstReMapGetText(Sender: TBaseVirtualTree;
                                                        Node: PVirtualNode;
                                                        Column: TColumnIndex;
                                                        TextType: TVSTTextType;
                                                        var CellText: WideString);
var
  CurrGSTMapItem : TGSTMapItem;
begin
  if GSTMapCol.ItemAtColIndex(PNodeData(Sender.GetNodeData(Node)^).Source, CurrGSTMapItem) then
  begin
    case Column of
      0: CellText := CurrGSTMapItem.PracticeGstCode;
      1: CellText := CurrGSTMapItem.PracticeGstDesc;
      2: CellText := GSTMapCol.GetGSTClassDescUsingClass(CurrGSTMapItem.CashbookGstClass);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.virGstReMapHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  SortAccountStatusList(Column);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.virGstReMapNewText(Sender: TBaseVirtualTree;
                                                        Node: PVirtualNode;
                                                        Column: TColumnIndex;
                                                        NewText: WideString);
var
  CurrGSTMapItem : TGSTMapItem;
begin
  if GSTMapCol.ItemAtColIndex(PNodeData(Sender.GetNodeData(Node)^).Source, CurrGSTMapItem) then
  begin
    if Column = 2 then
    begin
      CurrGSTMapItem.CashbookGstClass := GSTMapCol.GetGSTClassUsingClassDesc(NewText);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.virGstReMapPaintText(
  Sender: TBaseVirtualTree; const TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType);
var
  CurrGSTMapItem : TGSTMapItem;
begin
  if virGstReMap.FocusedNode = Node then
    TargetCanvas.Font.Color := clWhite
  else
    TargetCanvas.Font.Color := clBlack;

  if GSTMapCol.ItemAtColIndex(PNodeData(Sender.GetNodeData(Node)^).Source, CurrGSTMapItem) then
  begin
    if CurrGSTMapItem.CashbookGstClass = cgNone then
    begin
      TargetCanvas.Font.Color := clRed;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.virGstReMapCompareNodes(
  Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex;
  var Result: Integer);
var
  NodeData1: PNodeData;
  NodeData2: PNodeData;
begin
  NodeData1 := PNodeData(Sender.GetNodeData(Node1)^);
  NodeData2 := PNodeData(Sender.GetNodeData(Node2)^);

  case Column of
    0: Result := DoIdColumnCompare(NodeData1, NodeData2);
    1: Result := DoGstDescColumnCompare(NodeData1, NodeData2);
    2: Result := DoMYOBGstColumnCompare(NodeData1, NodeData2);
  end;
end;

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.DoIdColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
var
  CurrGSTMapItem1 : TGSTMapItem;
  CurrGSTMapItem2 : TGSTMapItem;
begin
  Result := 0;
  if GSTMapCol.ItemAtColIndex(NodeData1.Source, CurrGSTMapItem1) then
  begin
    if GSTMapCol.ItemAtColIndex(NodeData2.Source, CurrGSTMapItem2) then
    begin
      Result := CurrGSTMapItem2.GstIndex - CurrGSTMapItem1.GstIndex;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.DoGstDescColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
var
  CurrGSTMapItem1 : TGSTMapItem;
  CurrGSTMapItem2 : TGSTMapItem;
begin
  Result := 0;
  if GSTMapCol.ItemAtColIndex(NodeData1.Source, CurrGSTMapItem1) then
  begin
    if GSTMapCol.ItemAtColIndex(NodeData2.Source, CurrGSTMapItem2) then
    begin
      Result := CompareText(CurrGSTMapItem1.PracticeGstCode + CurrGSTMapItem1.PracticeGstDesc,
                             CurrGSTMapItem2.PracticeGstCode + CurrGSTMapItem2.PracticeGstDesc);
    end;
  end;
end;

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.DoMYOBGstColumnCompare(NodeData1, NodeData2: PNodeData): Integer;
var
  CurrGSTMapItem1 : TGSTMapItem;
  CurrGSTMapItem2 : TGSTMapItem;
begin
  Result := 0;
  if GSTMapCol.ItemAtColIndex(NodeData1.Source, CurrGSTMapItem1) then
  begin
    if GSTMapCol.ItemAtColIndex(NodeData2.Source, CurrGSTMapItem2) then
    begin
      Result := CompareText(GSTMapCol.GetGSTClassDescUsingClass(CurrGSTMapItem1.CashbookGstClass),
                            GSTMapCol.GetGSTClassDescUsingClass(CurrGSTMapItem2.CashbookGstClass));
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.SortAccountStatusList(Column: Integer; Direction: TSortDirection);
begin
  virGstReMap.SortTree(Column, Direction);

  virGstReMap.Header.SortColumn := Column;
  virGstReMap.Header.SortDirection := Direction;

  FLastSortDirection := Direction;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.SortAccountStatusList(Column: Integer);
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

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.Validate: boolean;
var
  GstIndex : integer;
  GSTMapItem : TGSTMapItem;
begin
  Result := true;

  for GstIndex := 0 to GSTMapCol.Count-1 do
  begin
    if GSTMapCol.ItemAtColIndex(GstIndex, GSTMapItem) then
    begin
      if GSTMapItem.CashbookGstClass = cgNone then
      begin
        Result := false;
        HelpfulWarningMsg('Please assign all GST classes',0);
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TFrmChartExportMapGSTClass.Execute: boolean;
begin
  fOkPressed := false;
  Refesh;
  SortAccountStatusList(0);
  Result := (ShowModal = mrOK);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := true;
  if fOkPressed then
  begin
    fOkPressed := false;

    CanClose := Validate();
  end;
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.FormCreate(Sender: TObject);
begin
  virGstReMap.Header.Font := Self.Font;

  virGstReMap.Header.Height := Abs(virGstReMap.Header.Font.Height) * 10 DIV 6;

  virGstReMap.NodeDataSize := SizeOf(TNodeData);
end;

//------------------------------------------------------------------------------
procedure TFrmChartExportMapGSTClass.FormShow(Sender: TObject);
begin
  FocusGrid(virGstReMap);
end;

end.
