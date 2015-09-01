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
  VirtualTrees;
type
  //----------------------------------------------------------------------------
  TRecommendedMemorisationsFrm = class(TForm)
    pnlButtons: TPanel;
    btnClose: TButton;
    pnlTop: TPanel;
    lblBankAccount: TLabel;
    Images: TImageList;
    btnCreate: TButton;
    chkAllowSuggMemPopup: TCheckBox;
    btnHide: TButton;
    vstTree: TVirtualStringTree;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vstTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: WideString);
    procedure FormResize(Sender: TObject);
    procedure vstTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure vstTreeFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure btnHideClick(Sender: TObject);
    procedure vstTreeDblClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
  private
    fLoading : boolean;
    fBankAccount: TBank_Account;
    fSuggMemSortedList: TSuggMemSortedList;

    fTempByte : Byte;
    fTempInteger : integer;
    fTempString : string;

    function GetSuggIdFromNode(aNode: PVirtualNode) : integer;
    procedure RefreshMemControls(aNodeIndex : integer);
    procedure FillSortedList();
    procedure RefreshGrid();
    procedure DoCreateNewMemorisation();
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
  bkBranding;

const
  ccEntryType        = 0;
  ccStatementDetails = 1;
  ccCode             = 2;
  ccTotal            = 3;

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

  bkbranding.StyleSelectionColor(vstTree);

  fSuggMemSortedList := TSuggMemSortedList.create;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormShow(Sender: TObject);
begin
  vstTree.Header.Font.Size := Font.Size;

  Caption := 'Suggested Memorisations for ' + MyClient.clFields.clCode;

  lblBankAccount.Caption := 'Account ' +
    fBankAccount.baFields.baBank_Account_Number + ' ' +
    fBankAccount.baFields.baBank_Account_Name;

  lblBankAccount.Caption := StringReplace(lblBankAccount.Caption, '&', '&&', [rfReplaceAll]);

  RefreshGrid();

  RefreshMemControls(vstTree.GetFirstSelected.Index);
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
procedure TRecommendedMemorisationsFrm.vstTreeDblClick(Sender: TObject);
begin
  DoCreateNewMemorisation();
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeFocusChanged(
  Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex);
begin
  RefreshMemControls(Node.Index);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.vstTreeGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: WideString);
var
  pData: pSuggMemSortedListRec;
  iTotal: integer;
begin
  CellText := '';

  pData := fSuggMemSortedList.GetPRec(Node.Index);

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

    // Total #
    3:
    begin
      iTotal := pData^.TotalCount;
      CellText := IntToStr(iTotal);
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
    ccTotal            : fSuggMemSortedList.ColSortOrder := csTotal;
  end;
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
end;

//------------------------------------------------------------------------------
function TRecommendedMemorisationsFrm.GetSuggIdFromNode(aNode: PVirtualNode): integer;
var
  pData : pSuggMemSortedListRec;
begin
  pData := fSuggMemSortedList.GetPRec(aNode.Index);
  Result := pData^.id;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.RefreshMemControls(aNodeIndex : integer);
var
  pData: pSuggMemSortedListRec;
begin
  if fLoading then
    Exit;

  pData := fSuggMemSortedList.GetPRec(aNodeIndex);

  if pData^.Id = BLANK_LINE then
  begin
    btnCreate.Default := false;
    btnCreate.Enabled := false;

    btnHide.Enabled := false;
    btnHide.Caption := 'Hide';
  end
  else
  begin
    btnCreate.Enabled := true;
    btnCreate.Default := true;

    btnHide.Enabled := true;
    if pData^.IsHidden then
      btnHide.Caption := 'Un-hide'
    else
      btnHide.Caption := 'Hide';
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.btnCreateClick(Sender: TObject);
begin
  DoCreateNewMemorisation();
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
    pData := fSuggMemSortedList.GetPRec(Node.Index);
    Hide := not pData^.IsHidden;

    Node := vstTree.GetFirst();
    while assigned(Node) do
    begin
      if vstTree.Selected[Node]then
      begin
        pData := fSuggMemSortedList.GetPRec(Node.Index);

        if pData^.Id > BLANK_LINE then
          SuggestedMem.UpdateSuggestion(fBankAccount, pData^.Id, Hide, false);
      end;
      Node := Node.NextSibling;
    end;

    RefreshGrid;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.DoCreateNewMemorisation();
{var
  pData: PTreeData;

  Mems: TMemorisations_List;
  Mem: TMemorisation;
  MemLine: pMemorisation_Line_Rec;

  i: integer;
  Recommended: TRecommended_Mem_List;}
begin
  {pData := PTreeData(vstTree.GetNodeData(aNode));

  // Create memorisation
  Mems := fBankAccount.baMemorisations_List;
  Mem := TMemorisation.Create(Mems.AuditMgr);

  try
    Mem.mdFields.mdMatch_On_Statement_Details := true;
    Mem.mdFields.mdStatement_Details := pData.SuggestedMem.smMatchedPhrase;
    Mem.mdFields.mdType := pData.SuggestedMem.smType;

    // Create memorisation line
    MemLine := New_Memorisation_Line_Rec;
    MemLine.mlAccount := pData.SuggestedMem.smAccount;
    MemLine.mlGST_Class := MyClient.clChart.GSTClass(
      pData.SuggestedMem.smAccount);
    MemLine.mlPercentage := 100 * 10000; // Use 10000 for percentages
    Mem.mdLines.Insert(MemLine);

    // OK pressed, and insert mem?
    if CreateMemorisation(fBankAccount, Mems, Mem) then
    begin
      BuildData;

      // Repopulate the recommended mems list from scratch (just the rec mems,
      // not the unscanned transactions or candidate mems)
      // Note: RepopulateRecommendedMems removed, see note in PopulateTree
      RedrawTree; // if we don't do this, the recommendation we just accepted will still be in the list
      fAdded := true;
    end
    else
    begin
      // Note: RepopulateRecommendedMems removed, see note in PopulateTree
      RedrawTree;
    end;
  finally
    FreeAndNil(Mem);
  end;  }
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
procedure TRecommendedMemorisationsFrm.RefreshGrid;
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
  SelectionDone := false;
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
      NewNode := vstTree.AddChild(nil);

      if IsNodeInArray(NewData^.Id) then
      begin
        vstTree.Selected[NewNode] := True;

        if not SelectionDone then
          vstTree.FocusedNode := NewNode;

        SelectionDone := true;
      end;
    end;

    if not SelectionDone then
    begin
      vstTree.Selected[vstTree.GetFirst] := true;
      vstTree.FocusedNode := NewNode;
    end;
  finally
    vstTree.EndUpdate;
    fLoading := false;
  end;
end;

end.
