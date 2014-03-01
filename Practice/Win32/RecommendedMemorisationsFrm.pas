unit RecommendedMemorisationsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ovcbase, ovctcmmn, ovctable, ExtCtrls, StdCtrls,
  dxGDIPlusClasses, ImgList,

  baObj32,
  rmObj32,
  rmList32,

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
    BankAccount: TBank_Account;
    RecommendedMem: TRecommended_Mem;
  end;

  TRecommendMems = record
    BankAccount: TBank_Account;
    RecommendedMems: array of TRecommended_Mem;
  end;

  TRecommendedMemArray = array of TRecommendMems;

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
    fData: TRecommendedMemArray;

    function  FindOrAdd(const aBankAccountNumber: string): integer;
    function  BankAccountNumberToBankAcccount(const aBankAccountNumber: string
                ): TBank_Account;
    procedure BuildData;
    procedure PopulateTree;
    function  GetButtonRect(const aCellRect: TRect): TRect;
    procedure DoCreateNewMemorisation(const aNode: PVirtualNode);
  public
    { Public declarations }
  end;

  function  ShowRecommendedMemorisations(const aOwner: TComponent): boolean;


implementation

{$R *.dfm}

uses
  Globals,
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
begin
  bkXPThemes.ThemeForm(self);

  Caption := 'Recommended Memorisations for ' + MyClient.clFields.clCode;

  PopulateTree;
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
  sAccount: string;
begin
  pData := PTreeData(vstTree.GetNodeData(Node));
  if (pData.DataType <> dtBankAccount) then
    exit;

  CustomDraw := true;

  TargetCanvas.FillRect(ItemRect);

  TargetCanvas.Font.Color := clWindowText;
  TargetCanvas.Font.Size := Font.Size;
  TargetCanvas.Font.Style := [fsBold];
  sAccount := 'Account ' + pData.BankAccount.baFields.baBank_Account_Number +
    pData.BankAccount.baFields.baBank_Account_Name;
  TargetCanvas.TextOut(ItemRect.Left+2, ItemRect.Top, sAccount);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  pData: PTreeData;
  iTotal: integer;
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
        // Entry type
        1:
        begin
          CellText := Format('%d:%s', [
            pData.RecommendedMem.rmFields.rmType,
            MyClient.clFields.clShort_Name[pData.RecommendedMem.rmFields.rmType]
            ]);
        end;

        // Statement details
        2: CellText := pData.RecommendedMem.rmFields.rmStatement_Details;

        // Code
        3: CellText := pData.RecommendedMem.rmFields.rmAccount;

        // # Coded
        4: CellText := IntToStr(pData.RecommendedMem.rmFields.rmManual_Count);

        // Total #
        5:
        begin
          iTotal := pData.RecommendedMem.rmFields.rmManual_Count +
            pData.RecommendedMem.rmFields.rmUncoded_Count;
          CellText := IntToStr(iTotal);
        end;
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

  DoCreateNewMemorisation(HitInfo.HitNode);
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
function TRecommendedMemorisationsFrm.FindOrAdd(const aBankAccountNumber: string
  ): integer;
var
  i: integer;
  iCount: integer;
begin
  for i := 0 to High(fData) do
  begin
    // Found?
    if (fData[i].BankAccount.baFields.baBank_Account_Number = aBankAccountNumber) then
    begin
      result := i;
      exit;
    end;
  end;

  // Add
  iCount := Length(fData);
  SetLength(fData, iCount+1);
  fData[iCount].BankAccount := BankAccountNumberToBankAcccount(aBankAccountNumber);

  result := iCount;
end;

//------------------------------------------------------------------------------
function TRecommendedMemorisationsFrm.BankAccountNumberToBankAcccount(
  const aBankAccountNumber: string): TBank_Account;
var
  i: integer;
  BankAccount: TBank_Account;
begin
  for i := 0 to MyClient.clBank_Account_List.ItemCount-1 do
  begin
    BankAccount := MyClient.clBank_Account_List.Bank_Account_At(i);
    if (BankAccount.baFields.baBank_Account_Number = aBankAccountNumber) then
    begin
      result := BankAccount;
      exit;
    end;
  end;

  ASSERT(false, 'Should be in-sync (merged) with Bank Accounts');
  result := nil;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.BuildData;
var
  Mems: TRecommended_Mem_List;
  i: integer;
  Mem: TRecommended_Mem;
  iBankAccount: integer;
  iCount: integer;
begin
  Mems := MyClient.clRecommended_Mems.Recommended;
  for i := 0 to Mems.ItemCount-1 do
  begin
    Mem := Mems.Recommended_Mem_At(i);

    iBankAccount := FindOrAdd(Mem.rmFields.rmBank_Account_Number);

    with fData[iBankAccount] do
    begin
      iCount := Length(RecommendedMems);
      SetLength(RecommendedMems, iCount+1);
      RecommendedMems[iCount] := Mem;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.PopulateTree;
var
  iHigh: integer;
  iBankAccount: integer;

  pNode: PVirtualNode;
  pData: PTreeData;

  iMem: integer;
begin
  // Build temporary structure against BankAccount
  BuildData;

  // Add nodes
  iHigh := High(fData);
  for iBankAccount := 0 to iHigh do
  begin
    // Data
    with fData[iBankAccount] do
    begin
      // Add bank account number
      pNode := vstTree.AddChild(nil);
      pData := PTreeData(vstTree.GetNodeData(pNode));
      pData.DataType := dtBankAccount;
      pData.BankAccount := BankAccount;

      // Header
      pNode := vstTree.AddChild(nil);
      pData := PTreeData(vstTree.GetNodeData(pNode));
      pData.DataType := dtHeader;

      // Data
      for iMem := 0 to High(RecommendedMems) do
      begin
        pNode := vstTree.AddChild(nil);
        pData := PTreeData(vstTree.GetNodeData(pNode));
        pData.DataType := dtData;
        pData.BankAccount := BankAccount; // For Create Mem
        pData.RecommendedMem := RecommendedMems[iMem];
      end;
    end;

    // Not last bank account?
    if (iBankAccount <> iHigh) then
    begin
      /// Divider
      pNode := vstTree.AddChild(nil);
      pData := PTreeData(vstTree.GetNodeData(pNode));
      pData.DataType := dtDivider;
    end;
  end;
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
procedure TRecommendedMemorisationsFrm.DoCreateNewMemorisation(
  const aNode: PVirtualNode);
var
  pData: PTreeData;

  BankAccount: TBank_Account;
  Mems: TMemorisations_List;
  Mem: TMemorisation;
  DeleteSelectedMem: boolean;
begin
  pData := PTreeData(vstTree.GetNodeData(aNode));
  ASSERT(pData.DataType = dtData);

  BankAccount := pData.BankAccount;
  Mems := BankAccount.baMemorisations_List;
  Mem := TMemorisation.Create(Mems.AuditMgr);
  Mem.mdFields.mdMatch_On_Statement_Details := true;
  Mem.mdFields.mdStatement_Details :=
    pData.RecommendedMem.rmFields.rmStatement_Details;
  try
    DeleteSelectedMem := false;
    EditMemorisation(BankAccount, Mems, Mem, DeleteSelectedMem);
  finally
    FreeAndNil(Mem);
  end;
end;


end.
