unit RecommendedMemorisationsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, VirtualTrees, ovcbase, ovctcmmn, ovctable, ExtCtrls, StdCtrls,
  dxGDIPlusClasses, ImgList,

  baObj32,
  rmObj32,
  rmList32,

  OSFont,

  ImagesFrm;

type
  PTreeData = ^TTreeData;
  TTreeData = record
    RecommendedMem: TRecommended_Mem;
  end;

  //----------------------------------------------------------------------------
  // TRecommendedMemorisationsFrm
  //----------------------------------------------------------------------------
  TRecommendedMemorisationsFrm = class(TForm)
    vstTree: TVirtualStringTree;
    pnlButtons: TPanel;
    btnClose: TButton;
    Panel1: TPanel;
    lblBankAccount: TLabel;
    lblStatus: TLabel;
    Images: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure vstTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure vstTreeGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure vstTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstTreeFocusChanging(Sender: TBaseVirtualTree; OldNode,
      NewNode: PVirtualNode; OldColumn, NewColumn: TColumnIndex;
      var Allowed: Boolean);
    procedure vstTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vstTreeAfterCellPaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
      CellRect: TRect);
    procedure FormResize(Sender: TObject);
    procedure vstTreeCompareNodes(Sender: TBaseVirtualTree; Node1,
      Node2: PVirtualNode; Column: TColumnIndex; var CompareResult: Integer);
    procedure vstTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure vstTreeBeforePaint(Sender: TBaseVirtualTree;
      TargetCanvas: TCanvas);
  private
    fBankAccount: TBank_Account;
    fData: array of TRecommended_Mem;

    function  DetermineStatus: string;
    procedure BuildData;
    procedure PopulateTree;
    function  GetButtonRect(const aCellRect: TRect): TRect;
    procedure DoCreateNewMemorisation(const aNode: PVirtualNode);
    procedure RedrawTree;
    procedure ResortTree;
  public
    { Public declarations }
    constructor CreateEx(const aOwner: TComponent;
                  const aBankAccount: TBank_Account);
  end;

  function  ShowRecommendedMemorisations(const aOwner: TComponent;
              const aBankAccount: TBank_Account): boolean;


implementation

{$R *.dfm}

uses
  Globals,
  MemorisationsObj,
  MemoriseDlg,
  bkXPThemes,
  BKMLIO,
  BKDefs,
  UpdateMF,
  CodingFormCommands,
  GenUtils,
  bkhelp,
  Math;

const
  ICON_BUTTON = 0;
  COL_STATEMENTS_DETAILS = 1;
  MSG_STILL_PROCESSING = 'Practice is still scanning for suggestions, please try again later';
  MSG_NO_MEMORISATIONS = 'There are no Suggested Memorisations at this time';
  ccEntryType = 0;
  ccStatementDetails = 1;
  ccCode = 2;
  ccTotal = 3;
  ccPlus = 4;
  LAST_COLUMN = 4;

//------------------------------------------------------------------------------
// ShowRecommendedMemorisations
//------------------------------------------------------------------------------
function ShowRecommendedMemorisations(const aOwner: TComponent;
  const aBankAccount: TBank_Account): boolean;
var
  varForm: TRecommendedMemorisationsFrm;
  mrResult: TModalResult;
begin
  varForm := TRecommendedMemorisationsFrm.CreateEx(aOwner, aBankAccount);
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
constructor TRecommendedMemorisationsFrm.CreateEx(const aOwner: TComponent;
  const aBankAccount: TBank_Account);
begin
  inherited Create(aOwner);

  fBankAccount := aBankAccount;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(self);
  Self.HelpContext := BKH_Suggested_memorisations;

  vstTree.Header.Font.Size := Font.Size;

  Caption := 'Suggested Memorisations for ' + MyClient.clFields.clCode;

  lblBankAccount.Caption := 'Account ' +
    fBankAccount.baFields.baBank_Account_Number + ' ' +
    fBankAccount.baFields.baBank_Account_Name;

  lblBankAccount.Caption := StringReplace(lblBankAccount.Caption, '&', '&&', [rfReplaceAll]);

  lblStatus.Caption := DetermineStatus;

  PopulateTree;
  vstTree.Header.SortColumn := ccEntryType;
end;

procedure TRecommendedMemorisationsFrm.RedrawTree;
var
  OldScrollPos: integer;
begin
  OldScrollPos := vstTree.OffsetY;
  vstTree.BeginUpdate;
  PopulateTree;
  vstTree.SortTree(vstTree.Header.SortColumn, vstTree.Header.SortDirection);
  vstTree.EndUpdate;
  vstTree.OffsetY := OldScrollPos;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormResize(Sender: TObject);
var
  Widths: array of integer;
  iTotal: integer;
  i: integer;
  iDetails: integer;
begin
  SetLength(Widths, vstTree.Header.Columns.Count);
  iTotal := 0;

  for i := 0 to vstTree.Header.Columns.Count-1 do
  begin
    Widths[i] := vstTree.Header.Columns[i].Width;

    if (i = COL_STATEMENTS_DETAILS) then
      continue;

    iTotal := iTotal + Widths[i];
  end;

  iDetails := vstTree.Width - iTotal - 25 - 10;
  vstTree.Header.Columns[COL_STATEMENTS_DETAILS].Width := iDetails;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeGetNodeDataSize(
  Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TTreeData);
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

  case Column of
    // Entry type
    0:
    begin
      CellText := Format('%d:%s', [
        pData.RecommendedMem.rmFields.rmType,
        MyClient.clFields.clShort_Name[pData.RecommendedMem.rmFields.rmType]
        ]);
    end;

    // Statement details
    1: CellText := pData.RecommendedMem.rmFields.rmStatement_Details;

    // Code
    2: CellText := pData.RecommendedMem.rmFields.rmAccount;

    // Total #
    3:
    begin
      iTotal := pData.RecommendedMem.rmFields.rmManual_Count +
        pData.RecommendedMem.rmFields.rmUncoded_Count;
      CellText := IntToStr(iTotal);
    end;
  end;
end;

procedure TRecommendedMemorisationsFrm.vstTreeHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if vstTree.Header.SortColumn = Column then begin
    if vstTree.Header.SortDirection = sdAscending then
      vstTree.Header.SortDirection := sdDescending
    else
      vstTree.Header.SortDirection := sdAscending;
  end
  else
  begin
    vstTree.Header.SortColumn := Column;
    vstTree.Header.SortDirection := sdAscending;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeAfterCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellRect: TRect);
var
  ButtonRect: TRect;
begin
  if (Column <> LAST_COLUMN) then
    exit;

  ButtonRect := GetButtonRect(CellRect);

  Images.Draw(TargetCanvas, ButtonRect.Left, ButtonRect.Top, ICON_BUTTON);
end;

procedure TRecommendedMemorisationsFrm.vstTreeBeforePaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas);
begin
  ResortTree;
end;

procedure TRecommendedMemorisationsFrm.ResortTree;
begin
  vstTree.SortTree(vstTree.Header.SortColumn, vstTree.Header.SortDirection);
end;

procedure TRecommendedMemorisationsFrm.vstTreeCompareNodes(
  Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode; Column: TColumnIndex;
  var CompareResult: Integer);
var
  pData1, pData2: PTreeData;

  function CompareEntryType: integer;
  var
    EntryType1, EntryType2: integer;
  begin
    EntryType1 := pData1.RecommendedMem.rmFields.rmType;
    EntryType2 := pData2.RecommendedMem.rmFields.rmType;
    Result := CompareValue(EntryType1, EntryType2);
  end;

  function CompareStatementDetails: integer;
  begin
    Result := CompareText(pData1.RecommendedMem.rmFields.rmStatement_Details,
                          pData2.RecommendedMem.rmFields.rmStatement_Details);
  end;

  function CompareAccountCode: integer;
  begin
    Result := CompareText(pData1.RecommendedMem.rmFields.rmAccount,
                          pData2.RecommendedMem.rmFields.rmAccount);
  end;

  function CompareTotal: integer;
  var
    Total1, Total2: integer;
  begin
    Total1 := pData1.RecommendedMem.rmFields.rmManual_Count +
              pData1.RecommendedMem.rmFields.rmUncoded_Count;
    Total2 := pData2.RecommendedMem.rmFields.rmManual_Count +
              pData2.RecommendedMem.rmFields.rmUncoded_Count;
    Result := CompareValue(Total1, Total2);
  end;

begin
  pData1 := PTreeData(vstTree.GetNodeData(Node1));
  pData2 := PTreeData(vstTree.GetNodeData(Node2));

  if not Assigned(pData1.RecommendedMem) then
    CompareResult := 1
  else if not Assigned(pData2.RecommendedMem) then
    CompareResult := -1
  else
  begin
    case column of
      ccEntryType         : CompareResult := CompareEntryType;
      ccStatementDetails  : CompareResult := CompareStatementDetails;
      ccCode              : CompareResult := CompareAccountCode;
      ccTotal             : CompareResult := CompareTotal;
    end;

    // First inner sort: statement details
    if (CompareResult = 0) and (column <> ccStatementDetails) then
      CompareResult := CompareStatementDetails;

    // Second inner sort: entry type
    if (CompareResult = 0) and (column <> ccEntryType) then
      CompareResult := CompareEntryType;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitInfo: THitInfo;
  CellRect: TRect;
  ButtonRect: TRect;
  MousePt: TPoint;
begin
  vstTree.GetHitTestInfoAt(X, Y, true, HitInfo);
  if not assigned(HitInfo.HitNode) then
    exit;
  if (HitInfo.HitColumn < 0) then // Can be -2
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
function TRecommendedMemorisationsFrm.DetermineStatus: string;
var
  AccountHasRecMems           : boolean;
  i                           : integer;
begin
  result := '';

  with MyClient.clRecommended_Mems, Candidate.cpFields do
  begin
    if (cpCandidate_ID_To_Process >= cpNext_Candidate_ID) and
       (cpNext_Candidate_ID <> 1) then
    begin
      AccountHasRecMems := False;
      for i := 0 to Recommended.ItemCount - 1 do
      begin
        if (Recommended.Recommended_Mem_At(i).rmFields.rmBank_Account_Number = 
        fBankAccount.baFields.baBank_Account_Number) then
        begin
          AccountHasRecMems := True;
          break;
        end;            
      end;
      if not AccountHasRecMems then
        result := MSG_NO_MEMORISATIONS;
    end
    else
    begin
      result := MSG_STILL_PROCESSING;
    end;
  end
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.BuildData;
var
  Mems: TRecommended_Mem_List;
  i: integer;
  Mem: TRecommended_Mem;
  iCount: integer;
begin
  Mems := MyClient.clRecommended_Mems.Recommended;
  fData := nil;
  { Note: The RepopulateRecommendedMems has been removed because with large
    client files or with Mems V2 this would have taken a long time. It would
    have affected the startup of the form (FormCreate) and clicking of the "+"
    button, and leaving the Memorisation edit form. }
  for i := 0 to Mems.ItemCount-1 do
  begin
    Mem := Mems.Recommended_Mem_At(i);

    // Only include our bank account entries
    if (fBankAccount.baFields.baBank_Account_Number <>
      Mem.rmFields.rmBank_Account_Number) then
      continue;

    // Add
    iCount := Length(fData);
    SetLength(fData, iCount+1);
    fData[iCount] := Mem;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.PopulateTree;
var
  i: integer;
  pNode: PVirtualNode;
  pData: PTreeData;
begin
  // Build temporary structure against BankAccount
  BuildData;
  vstTree.Clear;

  // Add nodes
  for i := 0 to High(fData) do
  begin
    // Data
    pNode := vstTree.AddChild(nil);
    pData := PTreeData(vstTree.GetNodeData(pNode));
    pData.RecommendedMem := fData[i];
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
    if not Images.GetBitmap(ICON_BUTTON, TempBitmap) then
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

  Mems: TMemorisations_List;
  Mem: TMemorisation;
  MemLine: pMemorisation_Line_Rec;
begin
  pData := PTreeData(vstTree.GetNodeData(aNode));

  // Create memorisation
  Mems := fBankAccount.baMemorisations_List;
  Mem := TMemorisation.Create(Mems.AuditMgr);
  Mem.mdFields.mdMatch_On_Statement_Details := true;
  Mem.mdFields.mdStatement_Details := pData.RecommendedMem.rmFields.rmStatement_Details;
  Mem.mdFields.mdType := pData.RecommendedMem.rmFields.rmType;

  // Create memorisation line
  MemLine := New_Memorisation_Line_Rec;
  MemLine.mlAccount := pData.RecommendedMem.rmFields.rmAccount;
  MemLine.mlGST_Class := MyClient.clChart.GSTClass(
    pData.RecommendedMem.rmFields.rmAccount);
  MemLine.mlPercentage := 100 * 10000; // Use 10000 for percentages
  Mem.mdLines.Insert(MemLine);

  // OK pressed, and insert mem?
  if CreateMemorisation(fBankAccount, Mems, Mem) then
  begin
    // Repopulate the recommended mems list from scratch (just the rec mems,
    // not the unscanned transactions or candidate mems)
    // Note: RepopulateRecommendedMems removed, see note in PopulateTree
    RedrawTree; // if we don't do this, the recommendation we just accepted will still be in the list
    SendCmdToAllCodingWindows( ecRecodeTrans);
  end
  else
  begin
    FreeAndNil(Mem);
    // Note: RepopulateRecommendedMems removed, see note in PopulateTree
    RedrawTree;
  end;
end;


end.
