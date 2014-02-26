unit RecommendedMemorisationsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ovcbase, ovctcmmn, ovctable, ExtCtrls, StdCtrls,
  dxGDIPlusClasses, ImgList,

  OSFont;

type
  TDataType = (
    dtBankAccount,
    dtHeader,
    dtData,
    dtDivider
  );

  PTreeData = ^TTreeData;
  TTreeData = record
    DataType: TDataType;
  end;

  //----------------------------------------------------------------------------
  // TRecommendedMemorisationsFrm
  //----------------------------------------------------------------------------
  TRecommendedMemorisationsFrm = class(TForm)
    vstTree: TVirtualStringTree;
    pnlButtons: TPanel;
    btnClose: TButton;
    imgList: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure vstTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure vstTreeAfterItemPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect);
    procedure vstTreeGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure vstTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstTreeBeforeItemPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; ItemRect: TRect;
      var CustomDraw: Boolean);
    procedure vstTreeFocusChanging(Sender: TBaseVirtualTree; OldNode,
      NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
      var Allowed: Boolean);
    procedure vstTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vstTreeAfterCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
  private
    { Private declarations }
    procedure PopulateTree;
    function  GetButtonRect(const aCellRect: TRect): TRect;
    procedure DoCreateNewMemorisation;
  public
    { Public declarations }
  end;

  function  ShowRecommendedMemorisations(const aOwner: TComponent): boolean;


implementation

{$R *.dfm}

uses
  Globals,
  baObj32,
  MemorisationsObj,
  MemoriseDlg,
  bkXPThemes;

//------------------------------------------------------------------------------
// ShowRecommendedMemorisations
//------------------------------------------------------------------------------
function ShowRecommendedMemorisations(const aOwner: TComponent): boolean;
var
  varForm: TRecommendedMemorisationsFrm;
  mrResult: TModalResult;
begin
  varForm := TRecommendedMemorisationsFrm.Create(aOwner);
  try
    // Note: Data to display

    // Show form
    mrResult := varForm.ShowModal;
    result := (mrResult = mrOk);
    if not result then
      exit;

    // Note: Display to data
  finally
    FreeAndNil(varForm);
  end;
end;

//------------------------------------------------------------------------------
// TMemorisationForm
//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormCreate(Sender: TObject);
var
  pNode: PVirtualNode;
  pData: PTreeData;
begin
  bkXPThemes.ThemeForm(self);

  Caption := 'Recommended Memorisations for ' + MyClient.clFields.clCode;

  PopulateTree;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtBankAccount;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtHeader;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtData;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtData;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtDivider;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtBankAccount;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtHeader;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtData;

  pNode := vstTree.AddChild(nil);
  pData := PTreeData(vstTree.GetNodeData(pNode));
  pData.DataType := dtData;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeGetNodeDataSize(
  Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TTreeData);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeAfterItemPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  ItemRect: TRect);
var
  pData: PTreeData;
  HeaderRect: TRect;
  i: integer;
  iLast: integer;
begin
  pData := PTreeData(vstTree.GetNodeData(Node));
  if (pData.DataType <> dtHeader) then
    exit;
  TargetCanvas.Brush.Color := clWindowText;
  HeaderRect := ItemRect;
  HeaderRect.Left := vstTree.Header.Columns[0].Width;

  iLast := ItemRect.Left;
  for i := 0 to vstTree.Header.Columns.Count-2 do
  begin
    iLast := iLast + vstTree.Header.Columns[i].Width;
  end;
  HeaderRect.Right := iLast;

  TargetCanvas.FrameRect(HeaderRect);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeBeforeItemPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  ItemRect: TRect; var CustomDraw: Boolean);
var
  pData: PTreeData;
begin
  pData := PTreeData(vstTree.GetNodeData(Node));
  if (pData.DataType <> dtBankAccount) then
    exit;

  CustomDraw := true;

  TargetCanvas.FillRect(ItemRect);

  TargetCanvas.Font.Color := clWindowText;
  TargetCanvas.Font.Size := Font.Size;
  TargetCanvas.Font.Style := [fsBold];
  TargetCanvas.TextOut(ItemRect.Left+2, ItemRect.Top, 'Bank account 123456');
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  pData: PTreeData;
begin
  CellText := '';

  pData := PTreeData(vstTree.GetNodeData(Node));
  case pData.DataType of
    dtBankAccount:
    begin
      // No text, TreeBeforeItemPaint takes care of that
    end;

    dtHeader:
    begin
      case Column of
        1: CellText := 'Entry Type';
        2: CellText := 'Statement Details';
        3: CellText := 'Code';
        4: CellText := '#Coded';
        5: CellText := 'Total #';
      end;
    end;

    dtData:
    begin
      case Column of
        1: CellText := '06';
        2: CellText := 'Flowers';
        3: CellText := '144';
        4: CellText := '1';
        5: CellText := '1';
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeAfterCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellRect: TRect);
var
  pData: PTreeData;
  ButtonRect: TRect;
begin
  pData := PTreeData(vstTree.GetNodeData(Node));
  if (pData.DataType <> dtData) then
    exit;
  if (Column <> 6) then
    exit;

  ButtonRect := GetButtonRect(CellRect);

  imgList.Draw(TargetCanvas, ButtonRect.Left, ButtonRect.Top, 0);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitInfo: THitInfo;
  pData: PTreeData;
  CellRect: TRect;
  ButtonRect: TRect;
  MousePt: TPoint;
begin
  vstTree.GetHitTestInfoAt(X, Y, true, HitInfo);
  if not assigned(HitInfo.HitNode) then
    exit;
  if (HitInfo.HitColumn < 0) then // Can be -2
    exit;

  pData := PTreeData(vstTree.GetNodeData(HitInfo.HitNode));
  if (pData.DataType <> dtData) then
    exit;

  CellRect := vstTree.GetDisplayRect(HitInfo.HitNode, HitInfo.HitColumn, false);
  ButtonRect := GetButtonRect(CellRect);

  MousePt := Point(X, Y);

  if not PtInRect(ButtonRect, MousePt) then
    exit;

  DoCreateNewMemorisation;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeFocusChanging(
  Sender: TBaseVirtualTree; OldNode, NewNode: PVirtualNode;
  OldColumn, NewColumn: TColumnIndex; var Allowed: Boolean);
begin
  // Prevents selection highlight bar
  Allowed := false;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
begin
  // Note: Free strings and objects here
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.PopulateTree;
begin
  // TODO
end;

//------------------------------------------------------------------------------
function TRecommendedMemorisationsFrm.GetButtonRect(const aCellRect: TRect
  ): TRect;
var
  iCellWidth: integer;
  iCellHeight: integer;
  TempBitmap: TBitmap;
  iImageWidth: integer;
  iImageHeight: integer;
begin
  iCellWidth := aCellRect.Right - aCellRect.Left;
  iCellHeight := aCellRect.Bottom - aCellRect.Top;

  TempBitmap := TBitmap.Create;
  try
    if not imgList.GetBitmap(0, TempBitmap) then
      ASSERT(false);
    iImageWidth := TempBitmap.Width;
    iImageHeight := TempBitmap.Height;
  finally
    FreeAndNil(TempBitmap);
  end;

  result.Left := aCellRect.Left + (iCellWidth div 2) - (iImageWidth div 2);
  result.Right := result.Left + iImageWidth;
  result.Top := aCellRect.Top + (iCellHeight div 2) - (iImageHeight div 2);
  result.Bottom := result.Top + iImageHeight;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.DoCreateNewMemorisation;
var
  BankAccount: TBank_Account;
  Mems: TMemorisations_List;
  Mem: TMemorisation;
  DeleteSelectedMem: boolean;
begin
  BankAccount := MyClient.clBank_Account_List.Bank_Account_At(0);
  Mems := BankAccount.baMemorisations_List;
  Mem := TMemorisation.Create(Mems.AuditMgr);
  Mem.mdFields.mdMatch_On_Statement_Details := true;
  Mem.mdFields.mdStatement_Details := 'Test';
  try
    DeleteSelectedMem := false;
    EditMemorisation(BankAccount, Mems, Mem, DeleteSelectedMem);
  finally
    FreeAndNil(Mem);
  end;
end;


end.
