unit RecommendedMemorisationsFrm;

interface

uses
  Windows,
  Messages,
  ovctcedt,
  ovcbase,
  ovctcmmn,
  ovctcell,
  ovctcstr,
  ovctchdr,
  ImgList,
  Controls,
  ovctable,
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
  SuggMemSortedList;

type
  //----------------------------------------------------------------------------
  TRecommendedMemorisationsFrm = class(TForm)
    pnlButtons: TPanel;
    btnClose: TButton;
    Panel1: TPanel;
    lblBankAccount: TLabel;
    Images: TImageList;
    btnCreate: TButton;
    chkAllowSuggMemPopup: TCheckBox;
    btnHide: TButton;
    pnlLayout1: TPanel;
    pnlLayout2: TPanel;
    tblSuggMems: TOvcTable;
    hdrSuggMems: TOvcTCColHead;
    cntSuggMems: TOvcController;
    colStatementDetails: TOvcTCString;
    colCodedMatch: TOvcTCString;
    colCode: TOvcTCString;
    colEntryType: TOvcTCString;
    coUnCodedMatch: TOvcTCString;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tblSuggMemsGetCellData(Sender: TObject; RowNum, ColNum: Integer;
      var Data: Pointer; Purpose: TOvcCellDataPurpose);
    procedure colCodeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure colEntryTypeOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure colStatementDetailsOwnerDraw(Sender: TObject;
      TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure colCodedMatchOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure coUnCodedMatchOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure tblSuggMemsActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure hdrSuggMemsClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure tblSuggMemsDblClick(Sender: TObject);
  private
    fLoading : boolean;
    fBankAccount: TBank_Account;
    fSuggMemSortedList: TSuggMemSortedList;

    fTempByte : Byte;
    fTempInteger : integer;
    fTempString : string;

    procedure DrawEntryTypeOnCell(TableCanvas: TCanvas;
                                  const CellRect: TRect;
                                  RowNum, ColNum: Integer;
                                  const CellAttr: TOvcCellAttributes;
                                  aValue : byte;
                                  var DoneIt: Boolean);

    procedure DrawNumberOnCell(TableCanvas: TCanvas;
                               const CellRect: TRect;
                               RowNum, ColNum: Integer;
                               const CellAttr: TOvcCellAttributes;
                               aValue : integer;
                               var DoneIt: Boolean);

    procedure DrawTextOnCell(TableCanvas: TCanvas;
                             const CellRect: TRect;
                             RowNum, ColNum: Integer;
                             const CellAttr: TOvcCellAttributes;
                             aValue : string;
                             var DoneIt: Boolean);

    procedure FillSortedList();
    procedure Refresh();

    procedure ReadCellforPaint(RowNum,ColNum : integer;var Data : pointer);
    procedure RefreshMemControls(aRow: integer);
    procedure DoCreateNewMemorisation(aRow: integer);
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
  ccCodedMatch       = 3;
  ccUnCodedMatch     = 4;

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

  bkBranding.StyleOvcTableGrid(tblSuggMems);
  bkBranding.StyleTableHeading(hdrSuggMems);

  UserRec := AdminSystem.fdSystem_User_List.FindCode(CurrUser.Code);
  chkAllowSuggMemPopup.Checked := UserRec^.usAllow_Suggested_Mems_Popup;

  fSuggMemSortedList := TSuggMemSortedList.create;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormShow(Sender: TObject);
begin
  inherited;

  Caption := 'Suggested Memorisations for ' + MyClient.clFields.clCode;

  lblBankAccount.Caption := 'Account ' +
    fBankAccount.baFields.baBank_Account_Number + ' ' +
    fBankAccount.baFields.baBank_Account_Name;

  lblBankAccount.Caption := StringReplace(lblBankAccount.Caption, '&', '&&', [rfReplaceAll]);

  Refresh();
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.hdrSuggMemsClick(Sender: TObject);
begin
  case tblSuggMems.ActiveCol of
    ccEntryType        : fSuggMemSortedList.ColSortOrder := csType;
    ccStatementDetails : fSuggMemSortedList.ColSortOrder := csPhrase;
    ccCode             : fSuggMemSortedList.ColSortOrder := csAccount;
    ccCodedMatch       : fSuggMemSortedList.ColSortOrder := csCodedMatch;
    ccUnCodedMatch     : fSuggMemSortedList.ColSortOrder := csUncodedMatch;
  end;
  tblSuggMems.Invalidate;
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
procedure TRecommendedMemorisationsFrm.tblSuggMemsActiveCellChanged(
  Sender: TObject; RowNum, ColNum: Integer);
begin
  RefreshMemControls(RowNum);

  tblSuggMems.Invalidate;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.tblSuggMemsDblClick(Sender: TObject);
begin
  if fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow)^.Id = BLANK_LINE then
    Exit;

  DoCreateNewMemorisation(tblSuggMems.ActiveRow);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.tblSuggMemsGetCellData(Sender: TObject;
  RowNum, ColNum: Integer; var Data: Pointer; Purpose: TOvcCellDataPurpose);
begin
  if fLoading = true then
    Exit;

  if RowNum = 0 then
    Exit;

  ReadCellforPaint(RowNum, ColNum, Data);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.colEntryTypeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  DrawEntryTypeOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, Byte(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.colStatementDetailsOwnerDraw(
  Sender: TObject; TableCanvas: TCanvas; const CellRect: TRect; RowNum,
  ColNum: Integer; const CellAttr: TOvcCellAttributes; Data: Pointer;
  var DoneIt: Boolean);
begin
  DrawTextOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, String(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.colCodeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  DrawTextOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, String(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.coUnCodedMatchOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  DrawNumberOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, Integer(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.btnCreateClick(Sender: TObject);
begin
  DoCreateNewMemorisation(tblSuggMems.ActiveRow);

  tblSuggMems.Invalidate;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.btnHideClick(Sender: TObject);
var
  Hide : boolean;
begin
  if fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow)^.Id = BLANK_LINE then
    Exit;

  Hide := not fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow)^.IsHidden;

  SuggestedMem.UpdateSuggestion(fBankAccount, fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow)^.Id, Hide, false);

  Refresh();
  tblSuggMems.Invalidate;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.colCodedMatchOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  DrawNumberOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, Integer(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.DrawEntryTypeOnCell(TableCanvas: TCanvas;
                                                           const CellRect: TRect;
                                                           RowNum, ColNum: Integer;
                                                           const CellAttr: TOvcCellAttributes;
                                                           aValue: byte;
                                                           var DoneIt: Boolean);
var
  CellText : string;
begin
  CellText := Format('%d:%s', [aValue, MyClient.clFields.clShort_Name[aValue]]);
  DrawTextOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, CellText, DoneIt);
end;

procedure TRecommendedMemorisationsFrm.DrawNumberOnCell(TableCanvas: TCanvas;
                                                        const CellRect: TRect;
                                                        RowNum, ColNum: Integer;
                                                        const CellAttr: TOvcCellAttributes;
                                                        aValue: integer;
                                                        var DoneIt: Boolean);
begin
  DrawTextOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, IntToStr(aValue), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.DrawTextOnCell(TableCanvas: TCanvas;
                                                      const CellRect: TRect;
                                                      RowNum, ColNum: Integer;
                                                      const CellAttr: TOvcCellAttributes;
                                                      aValue: string;
                                                      var DoneIt: Boolean);
var
  DataRect : TRect;
begin
  TableCanvas.Font             := CellAttr.caFont;
  TableCanvas.Font.Color       := CellAttr.caFontColor;
  TableCanvas.Brush.Color      := CellAttr.caColor;

  if tblSuggMems.ActiveRow = RowNum then
  begin
    TableCanvas.Font.Color  := clWhite;
    TableCanvas.Brush.Color := bkBranding.SelectionColor;
  end;

  TableCanvas.FillRect( CellRect );

  if fSuggMemSortedList.GetPRec(RowNum)^.Id = BLANK_LINE then
  begin
    DoneIt := true;
    Exit;
  end;

  DataRect := CellRect;
  InflateRect( DataRect, -2, -2 );

  DrawText( TableCanvas.Handle, PChar( aValue ), StrLen( PChar( aValue ) ), DataRect, DT_OPTIONS_STR );

  DoneIt := true;
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
begin
  FillSortedList();

  tblSuggMems.RowLimit := fSuggMemSortedList.ItemCount;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.RefreshMemControls(aRow: integer);
var
  pData: pSuggMemSortedListRec;
begin
  if fLoading then
    Exit;

  if aRow < 0 then
  begin
    btnHide.Enabled := false;
    btnCreate.Enabled := false;

    btnHide.Caption := 'Hide';
    btnCreate.Default := false;
    Exit;
  end;

  if fSuggMemSortedList.GetPRec(aRow)^.Id = BLANK_LINE then
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
    if fSuggMemSortedList.GetPRec(aRow)^.IsHidden then
      btnHide.Caption := 'Un-hide'
    else
      btnHide.Caption := 'Hide';
  end;
  self.Repaint;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.ReadCellforPaint(RowNum, ColNum: integer; var Data: pointer);
begin
  case ColNum of
    ccEntryType : begin
      fTempByte := fSuggMemSortedList.GetPRec(RowNum)^.AccType;
      Data := @fTempByte;
    end;
    ccStatementDetails : begin
      fTempString := fSuggMemSortedList.GetPRec(RowNum)^.MatchedPhrase;
      Data := @fTempString;
    end;
    ccCode : begin
      fTempString := fSuggMemSortedList.GetPRec(RowNum)^.Account;
      Data := @fTempString;
    end;
    ccCodedMatch: begin
      fTempInteger := fSuggMemSortedList.GetPRec(RowNum)^.ManualCount;
      Data := @fTempInteger;
    end;
    ccUnCodedMatch: begin
      fTempInteger := fSuggMemSortedList.GetPRec(RowNum)^.UnCodedCount;
      Data := @fTempInteger;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.DoCreateNewMemorisation(aRow: integer);
var
  pData: pSuggMemSortedListRec;
  Mems: TMemorisations_List;
  Mem: TMemorisation;
  MemLine: pMemorisation_Line_Rec;
  i: integer;
begin
  pData := fSuggMemSortedList.GetPRec(aRow);

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

      RefreshMemControls(aRow);
      tblSuggMems.SetFocus;
    end
    else
    begin
      RefreshMemControls(aRow);
      tblSuggMems.SetFocus;
    end;
  finally
    FreeAndNil(Mem);
  end;
end;

end.
