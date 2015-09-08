unit RecommendedMemorisationsFrm;

interface

uses
  Windows,
  Messages,
  ImgList,
  Controls,
  StdCtrls,
  Classes,
  ExtCtrls,
  SysUtils,
  Forms,
  Dialogs,
  OSFont,
  baObj32,
  Graphics,
  SuggestedMems,
  SuggMemSortedList,
  VirtualTrees,
  Buttons;

type
  //----------------------------------------------------------------------------
  TRecommendedMemorisationsFrm = class(TForm)
    pnlButtons: TPanel;
    pnlTop: TPanel;
    lblBankAccount: TLabel;
    Images: TImageList;
    chkAllowSuggMemPopup: TCheckBox;
    vstTree: TVirtualStringTree;
    btnHide: TBitBtn;
    btnCreate: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vstTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure vstTreeGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure FormResize(Sender: TObject);
    procedure vstTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure vstTreeFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure btnHideClick(Sender: TObject);
    procedure vstTreeDblClick(Sender: TObject);
    procedure vstTreeMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnCreateClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    fLoading : boolean;
    fBankAccount: TBank_Account;
    fSuggMemSortedList: TSuggMemSortedList;
    fMouseDownX : integer;
    fMouseDownY : integer;

    fTempByte : Byte;
    fTempInteger : integer;
    fTempString : string;

    function GetSuggIdFromNode(aNode: PVirtualNode) : integer;
    procedure RefreshMemControls(aNode: PVirtualNode);

    procedure FillSortedList();
    procedure Refresh();

    procedure DoCreateNewMemorisation(const aNode: PVirtualNode);
  public
    property BankAccount: TBank_Account read fBankAccount write fBankAccount;
  end;

  //----------------------------------------------------------------------------
  function  ShowRecommendedMemorisations(const aOwner: TComponent;
              const aBankAccount: TBank_Account): boolean;


//------------------------------------------------------------------------------
implementation
{$R *.DFM}

uses
  Globals,
  InfoMoreFrm,
  SYDefs,
  bkXPThemes,
  bkhelp,
  MemorisationsObj,
  BKDEFS,
  BKMLIO,
  MemoriseDlg,
  bkBranding;

const
  ccEntryType        = 0;
  ccStatementDetails = 1;
  ccCode             = 2;
  ccManual           = 3;
  ccTotal            = 4;

  DT_OPTIONS_STR = DT_LEFT or DT_VCENTER or DT_SINGLELINE;
  DT_OPTIONS_INT = DT_RIGHT or DT_VCENTER or DT_SINGLELINE;

//------------------------------------------------------------------------------
function ShowRecommendedMemorisations(const aOwner: TComponent; const aBankAccount: TBank_Account): boolean;
var
  varForm: TRecommendedMemorisationsFrm;
  mrResult: TModalResult;
  MemStatus : TSuggMemStatus;
begin
  MemStatus := SuggestedMem.GetStatus(aBankAccount, MyClient.clChart);

  if MemStatus in [ssFound, ssProcessing] then
  begin
    varForm := TRecommendedMemorisationsFrm.Create(aOwner);
    try
      varForm.BankAccount := aBankAccount;

      mrResult := varForm.ShowModal;
      result := (mrResult = mrOk);

    finally
      FreeAndNil(varForm);
    end;
  end
  else
  begin
    HelpfulInfoMsg( SuggestedMem.DetermineStatus(aBankAccount, MyClient.clChart), 0 );
  end;
end;

//------------------------------------------------------------------------------
// TRecommendedMemorisationsFrm
//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormCreate(Sender: TObject);
var
  UserRec : PUser_Rec;
begin
  inherited;

  fLoading := true;

  bkXPThemes.ThemeForm(self);
  Self.HelpContext := BKH_Suggested_memorisations;

  UserRec := AdminSystem.fdSystem_User_List.FindCode(CurrUser.Code);
  chkAllowSuggMemPopup.Checked := UserRec^.usAllow_Suggested_Mems_Popup;

  fSuggMemSortedList := TSuggMemSortedList.create;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormShow(Sender: TObject);
begin
  inherited;
  vstTree.Header.Font.Size := Font.Size;

  Caption := 'Suggested Memorisations for ' + MyClient.clFields.clCode;

  lblBankAccount.Caption := 'Account ' +
    fBankAccount.baFields.baBank_Account_Number + ' ' +
    fBankAccount.baFields.baBank_Account_Name;

  lblBankAccount.Caption := StringReplace(lblBankAccount.Caption, '&', '&&', [rfReplaceAll]);

  Refresh();

  RefreshMemControls(vstTree.GetFirstSelected);
  vstTree.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormActivate(Sender: TObject);
begin
  self.repaint;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormDestroy(Sender: TObject);
var
  UserRec : PUser_Rec;
begin
  FreeAndNil(fSuggMemSortedList);

  UserRec := AdminSystem.fdSystem_User_List.FindCode(CurrUser.Code);
  UserRec^.usAllow_Suggested_Mems_Popup := chkAllowSuggMemPopup.Checked;

  inherited;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  RefreshMemControls(vstTree.GetFirstSelected);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeGetNodeDataSize(
  Sender: TBaseVirtualTree; var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TSuggMemSortedListRec);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  pData: pSuggMemSortedListRec;
  Value : integer;
begin
  CellText := '';

  pData := pSuggMemSortedListRec(vstTree.GetNodeData(Node)^);

  if pData^.Id = BLANK_LINE then
    Exit;

  case Column of
    // Entry type
    0:
    begin
      CellText := Format('%d:%s', [
        pData^.AccType,
        MyClient.clFields.clShort_Name[pData^.AccType]
        ]);
    end;

    // Statement details
    1: CellText := pData^.MatchedPhrase;

    // Code
    2: CellText := pData^.Account;

    // Manual #
    3:
    begin
      Value := pData^.ManualCount;
      CellText := IntToStr(Value);
    end;

    // Total #
    4:
    begin
      Value := pData^.TotalCount;
      CellText := IntToStr(Value);
    end;
  end;

  if pData^.IsHidden then
  begin
    vstTree.Font.Style := [fsItalic];
    vstTree.Font.Color := clInactiveCaptionText;
  end
  else
  begin
    vstTree.Font.Style := [];
    vstTree.Font.Color := clblack;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  case Column of
    ccEntryType        : fSuggMemSortedList.ColSortOrder := csType;
    ccStatementDetails : fSuggMemSortedList.ColSortOrder := csPhrase;
    ccCode             : fSuggMemSortedList.ColSortOrder := csAccount;
    ccManual           : fSuggMemSortedList.ColSortOrder := csManual;
    ccTotal            : fSuggMemSortedList.ColSortOrder := csTotal;
  end;
  Refresh();
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeDblClick(Sender: TObject);
var
  Node : PVirtualNode;
begin
  Node := vstTree.GetNodeAt(fMouseDownX, fMouseDownY);

  if Assigned(Node) then
  begin
    DoCreateNewMemorisation(Node);
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fMouseDownX := X;
  fMouseDownY := Y;
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

    if (i = ccStatementDetails) then
      continue;

    iTotal := iTotal + Widths[i];
  end;

  iDetails := vstTree.Width - iTotal - 25 - 10;
  vstTree.Header.Columns[ccStatementDetails].Width := iDetails;

  self.Repaint;
end;

//------------------------------------------------------------------------------
function TRecommendedMemorisationsFrm.GetSuggIdFromNode(aNode: PVirtualNode): integer;
var
  pData : pSuggMemSortedListRec;
begin
  pData := pSuggMemSortedListRec(vstTree.GetNodeData(aNode)^);
  Result := pData^.id;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.RefreshMemControls(aNode: PVirtualNode);
var
  pData: pSuggMemSortedListRec;
begin
  if fLoading then
    Exit;

  if not assigned(aNode) then
  begin
    btnHide.Enabled := false;
    btnCreate.Enabled := false;

    btnHide.Caption := 'Hide';
    btnCreate.Default := false;
    Exit;
  end;

  pData := pSuggMemSortedListRec(vstTree.GetNodeData(aNode)^);

  if pData^.Id = BLANK_LINE then
  begin
    btnHide.Enabled := false;
    btnCreate.Enabled := false;

    btnHide.Caption := 'Hide';
    btnCreate.Default := false;
  end
  else
  begin
    btnHide.Enabled := true;
    btnCreate.Enabled := true;

    btnCreate.Default := true;
    if pData^.IsHidden then
      btnHide.Caption := 'Un-hide'
    else
      btnHide.Caption := 'Hide';
  end;
  self.Repaint;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.btnHideClick(Sender: TObject);
var
  NodeIndex : integer;
  Node : PVirtualNode;
  pData: pSuggMemSortedListRec;
  Hide : boolean;
begin
  Node := vstTree.GetFirstSelected();

  if Assigned(Node) then
  begin
    pData := pSuggMemSortedListRec(vstTree.GetNodeData(Node)^);
    Hide := not pData^.IsHidden;

    Node := vstTree.GetFirst();
    while assigned(Node) do
    begin
      if vstTree.Selected[Node]then
      begin
        pData := pSuggMemSortedListRec(vstTree.GetNodeData(Node)^);

        if pData^.Id > BLANK_LINE then
          SuggestedMem.UpdateSuggestion(fBankAccount, pData^.Id, Hide, false);
      end;
      Node := Node.NextSibling;
    end;

    Refresh;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FillSortedList;
var
  BlankItem : TSuggMemSortedListRec;
begin
  fLoading := true;

  try
    fSuggMemSortedList.FreeAll();
    SuggestedMem.GetSuggestedMems(fBankAccount, MyClient.clChart, fSuggMemSortedList);
    BlankItem.Id := BLANK_LINE;
    fSuggMemSortedList.AddItem(BlankItem);
  finally
    fLoading := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.Refresh;
var
  Index : integer;
  Node : PVirtualNode;
  NewNode : PVirtualNode;
  NewData : pSuggMemSortedListRec;
  ThereIsHidden, ThereIsUnHidden : boolean;
  SelSuggIds : array of integer;
  SelectionDone : boolean;

  //----------------------------------------------------------------------------
  procedure AddSuggToSelected(aSuggId : integer);
  begin
    SetLength(SelSuggIds, Length(SelSuggIds) + 1);
    SelSuggIds[High(SelSuggIds)] := aSuggId;
  end;

  //----------------------------------------------------------------------------
  function IsNodeInArray(NodeSuggId : Integer) : boolean;
  var
    Index : integer;
  begin
    Result := false;
    for Index := 0 to High(SelSuggIds) do
    begin
      if SelSuggIds[Index] = NodeSuggId then
      begin
        Result := true;
        Exit;
      end;
    end;
  end;
begin
  Node := vstTree.GetFirst();
  while assigned(Node) do
  begin
    if vstTree.Selected[Node] then
      AddSuggToSelected(GetSuggIdFromNode(Node));
    Node := Node.NextSibling;
  end;

  FillSortedList();

  // check if there are hidden and unhidden
  ThereIsHidden := false;
  ThereIsUnHidden := false;
  for Index := 0 to fSuggMemSortedList.ItemCount-1 do
  begin
    NewData := fSuggMemSortedList.GetPRec(Index);
    if NewData^.IsHidden then
      ThereIsHidden := true;

    if not NewData^.IsHidden then
      ThereIsUnHidden := true;
  end;

  vstTree.BeginUpdate;
  try
    vstTree.Clear;
    SelectionDone := false;

    // Add nodes
    for Index := 0 to fSuggMemSortedList.ItemCount-1 do
    begin
      NewData := fSuggMemSortedList.GetPRec(Index);
      if NewData^.Id = BLANK_LINE then
      begin
        if (not ThereIsHidden) or (not ThereIsUnHidden) then
          continue;
      end;

      // Add
      NewNode := vstTree.AddChild(nil, NewData);

      if IsNodeInArray(NewData^.Id) then
      begin
        vstTree.Selected[NewNode] := True;

        if not SelectionDone then
        begin
          SelectionDone := true;
          vstTree.FocusedNode := NewNode;
        end;
      end;
    end;

    if not SelectionDone then
    begin
      vstTree.Selected[vstTree.GetFirst] := true;
      vstTree.FocusedNode := vstTree.GetFirst;
    end;

  finally
    vstTree.EndUpdate;
    fLoading := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.btnCreateClick(Sender: TObject);
var
  SelNode : PVirtualNode;
  NextNode : PVirtualNode;
  //NextAccount : string;
  //NextStatement : string;
  SuggId : integer;
begin
  SelNode := vstTree.GetFirstSelected();

  if not assigned(SelNode) then
    Exit;

  NextNode := vstTree.GetNextVisible(SelNode);
  if not Assigned(NextNode) then
    NextNode := vstTree.GetPreviousVisible(SelNode);

  if Assigned(NextNode) then
    SuggId := GetSuggIdFromNode(NextNode);

  DoCreateNewMemorisation(SelNode);

  if Assigned(NextNode) then
  begin
    SelNode := vstTree.GetFirst;
    while Assigned(SelNode) do
    begin
      if SuggId = GetSuggIdFromNode(SelNode) then
      begin
        vstTree.Selected[SelNode] := true;
        vstTree.FocusedNode := SelNode;
        break;
      end;

      SelNode := SelNode.NextSibling;
    end;
  end;
end;

//------------------------------------------------------------------------------
{function TRecommendedMemorisationsFrm.GetButtonRect(const aCellRect: TRect): TRect;
var
  iCellWidth: integer;
  iCellHeight: integer;
  TempBitmap: TBitmap;
  iImageWidth: integer;
  iImageHeight: integer;
begin
  {iCellWidth := aCellRect.Right - aCellRect.Left;
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
end; }


//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.DoCreateNewMemorisation(const aNode: PVirtualNode);
var
  pData: pSuggMemSortedListRec;
  Mems: TMemorisations_List;
  Mem: TMemorisation;
  MemLine: pMemorisation_Line_Rec;
  i: integer;
begin
  pData := pSuggMemSortedListRec(vstTree.GetNodeData(aNode)^);

  // Create memorisation
  Mems := fBankAccount.baMemorisations_List;
  Mem := TMemorisation.Create(Mems.AuditMgr);

  try
    Mem.mdFields.mdMatch_On_Statement_Details := true;
    Mem.mdFields.mdStatement_Details := pData^.MatchedPhrase;
    Mem.mdFields.mdType := pData^.AccType;

    // Create memorisation line
    MemLine := New_Memorisation_Line_Rec;
    MemLine.mlAccount := pData^.Account;
    MemLine.mlGST_Class := MyClient.clChart.GSTClass(
      pData^.Account);
    MemLine.mlPercentage := 100 * 10000; // Use 10000 for percentages
    Mem.mdLines.Insert(MemLine);

    // OK pressed, and insert mem?
    if CreateMemorisation(fBankAccount, Mems, Mem) then
    begin
      Refresh();

      RefreshMemControls(vstTree.GetFirstSelected);
      vstTree.SetFocus;
    end
    else
    begin
      RefreshMemControls(vstTree.GetFirstSelected);
      vstTree.SetFocus;
    end;
  finally
    FreeAndNil(Mem);
  end;
end;

end.
