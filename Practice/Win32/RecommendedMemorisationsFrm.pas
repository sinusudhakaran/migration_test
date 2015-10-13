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
  SpinnerFrm,
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
    spi: TOvcTCString;
    pnlMessage: TPanel;
    lblMessage: TLabel;
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
    procedure spiOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure tblSuggMemsActiveCellChanged(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure hdrSuggMemsClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
    procedure tblSuggMemsDblClick(Sender: TObject);
    procedure tblSuggMemsLockedCellClick(Sender: TObject; RowNum,
      ColNum: Integer);
    procedure tblSuggMemsLeavingRow(Sender: TObject; RowNum: Integer);
    procedure FormResize(Sender: TObject);
    procedure tblSuggMemsGetCellAttributes(Sender: TObject; RowNum,
      ColNum: Integer; var CellAttr: TOvcCellAttributes);
    procedure hdrSuggMemsOwnerDraw(Sender: TObject; TableCanvas: TCanvas;
      const CellRect: TRect; RowNum, ColNum: Integer;
      const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    fNeedReCoding : boolean;
    fHeadingClicked : boolean;
    fLoading : boolean;
    fBankAccount: TBank_Account;
    fSuggMemSortedList: TSuggMemSortedList;
    AltLineColor : integer;

    fTempByte : Byte;
    fTempInteger : integer;
    fTempString : string;
    fMemStatus : TSuggMemStatus;
    ffrmSpinner : TfrmSpinner;


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

    procedure DrawHeadingOnCell(TableCanvas: TCanvas;
                                const CellRect: TRect;
                                ColNum: Integer;
                                const CellAttr: TOvcCellAttributes;
                                var DoneIt: Boolean);

    procedure FillSortedList();
    procedure Refresh();
    procedure MainRefresh();
    procedure SetupForMessage();

    procedure ReadCellforPaint(RowNum, ColNum : integer; var Data : pointer);
    procedure RefreshMemControls(aRow: integer);
    procedure DoCreateNewMemorisation(aRow: integer);
    procedure CloseCalculatingSpinner();
  public
    procedure DoSuggestedMemsDoneProcessing();

    property BankAccount: TBank_Account read fBankAccount write fBankAccount;
    property NeedReCoding: boolean read fNeedReCoding;
  end;

  //----------------------------------------------------------------------------
  function  ShowRecommendedMemorisations(const aOwner: TComponent;
              const aBankAccount: TBank_Account; var aNeedReCoding : boolean): boolean;


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
  Imagesfrm,
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
function ShowRecommendedMemorisations(const aOwner: TComponent; const aBankAccount: TBank_Account; var aNeedReCoding : boolean): boolean;
var
  varForm: TRecommendedMemorisationsFrm;
  mrResult: TModalResult;
begin
  varForm := TRecommendedMemorisationsFrm.Create(aOwner);
  try
    varForm.BankAccount := aBankAccount;

    mrResult := varForm.ShowModal;
    result := (mrResult = mrOk);

    aNeedReCoding := varForm.NeedReCoding;

  finally
    FreeAndNil(varForm);
  end;
end;

//------------------------------------------------------------------------------
// TRecommendedMemorisationsFrm
//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  CloseCalculatingSpinner();
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormCreate(Sender: TObject);
var
  UserRec : PUser_Rec;
begin
  inherited;

  fNeedReCoding := false;
  SuggestedMem.DoneProcessingEvent := DoSuggestedMemsDoneProcessing;

  fHeadingClicked := false;
  fLoading := true;

  bkXPThemes.ThemeForm(self);
  Self.HelpContext := BKH_Suggested_memorisations;

  bkBranding.StyleOvcTableGrid(tblSuggMems);
  bkBranding.StyleTableHeading(hdrSuggMems);
  bkBranding.StyleAltRowColor(AltLineColor);

  chkAllowSuggMemPopup.Checked := UserINI_Suggested_Mems_Show_Popup;

  fSuggMemSortedList := TSuggMemSortedList.create;

  ffrmSpinner := TfrmSpinner.Create(self);
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

  MainRefresh();
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

procedure TRecommendedMemorisationsFrm.hdrSuggMemsOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if RowNum = 0 then
  begin
    DrawHeadingOnCell(TableCanvas, CellRect, ColNum, CellAttr, DoneIt);
    Exit;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.MainRefresh;
begin
  fMemStatus := SuggestedMem.GetStatus(BankAccount, MyClient.clChart);
  if fMemStatus = ssFound then
  begin
    Refresh();
    tblSuggMems.Enabled := true;
    RefreshMemControls(tblSuggMems.ActiveRow);
    tblSuggMems.SetFocus;
  end
  else
  begin
    Refresh();
    tblSuggMems.Invalidate;
    SetupForMessage();
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormDestroy(Sender: TObject);
var
  UserRec : PUser_Rec;
begin
  SuggestedMem.DoneProcessingEvent := nil;

  FreeAndNil(fSuggMemSortedList);

  UserINI_Suggested_Mems_Show_Popup := chkAllowSuggMemPopup.Checked;

  FreeAndNil(ffrmSpinner);

  inherited;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FormResize(Sender: TObject);
var
  Widths: array of integer;
  iTotal: integer;
  i: integer;
  iDetails: integer;
begin
  SetLength(Widths, tblSuggMems.ColCount);
  iTotal := 0;

  for i := 0 to tblSuggMems.ColCount-1 do
  begin
    Widths[i] := tblSuggMems.Columns.Width[i];

    if (i = ccStatementDetails) then
      continue;

    iTotal := iTotal + Widths[i];
  end;

  iDetails := tblSuggMems.Width - iTotal - 25 - 10;
  tblSuggMems.Columns.Width[ccStatementDetails] := iDetails;

  ffrmSpinner.UpdateSpinner((Self.Height div 2) - (ffrmSpinner.Height div 2),
                            (Self.Width div 2) - (ffrmSpinner.Width div 2));
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
  if fHeadingClicked then
    Exit;

  if fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow-1)^.Id = BLANK_LINE then
    Exit;

  DoCreateNewMemorisation(tblSuggMems.ActiveRow);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.tblSuggMemsGetCellAttributes(
  Sender: TObject; RowNum, ColNum: Integer; var CellAttr: TOvcCellAttributes);
begin
  if (RowNum = tblSuggMems.LockedRows) then
    Exit;

  if (CellAttr.caColor = tblSuggMems.Color) then
  begin
    if Odd(RowNum) then
      CellAttr.caColor := clwhite
    else
      CellAttr.caColor := AltLineColor;
  end;
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
procedure TRecommendedMemorisationsFrm.tblSuggMemsLeavingRow(Sender: TObject;
  RowNum: Integer);
begin
  fHeadingClicked := false;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.tblSuggMemsLockedCellClick(
  Sender: TObject; RowNum, ColNum: Integer);
begin
  fHeadingClicked := true;
  case ColNum of
    ccEntryType        : fSuggMemSortedList.ColSortOrder := csType;
    ccStatementDetails : fSuggMemSortedList.ColSortOrder := csPhrase;
    ccCode             : fSuggMemSortedList.ColSortOrder := csAccount;
    ccCodedMatch       : fSuggMemSortedList.ColSortOrder := csCodedMatch;
    ccUnCodedMatch     : fSuggMemSortedList.ColSortOrder := csUncodedMatch;
  end;
  Refresh();
  tblSuggMems.Invalidate;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.colEntryTypeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if Data = nil then
    Exit;

  DrawEntryTypeOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, Byte(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.colStatementDetailsOwnerDraw(
  Sender: TObject; TableCanvas: TCanvas; const CellRect: TRect; RowNum,
  ColNum: Integer; const CellAttr: TOvcCellAttributes; Data: Pointer;
  var DoneIt: Boolean);
begin
  if Data = nil then
    Exit;

  DrawTextOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, String(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.colCodedMatchOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if Data = nil then
    Exit;

  DrawNumberOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, Integer(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.colCodeOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if Data = nil then
    Exit;

  DrawTextOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, String(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.spiOwnerDraw(Sender: TObject;
  TableCanvas: TCanvas; const CellRect: TRect; RowNum, ColNum: Integer;
  const CellAttr: TOvcCellAttributes; Data: Pointer; var DoneIt: Boolean);
begin
  if Data=nil then
    Exit;

  DrawNumberOnCell(TableCanvas, CellRect, RowNum, ColNum, CellAttr, Integer(Data^), DoneIt);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.btnCreateClick(Sender: TObject);
begin
  DoCreateNewMemorisation(tblSuggMems.ActiveRow);
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.btnHideClick(Sender: TObject);
var
  Hide : boolean;
begin
  if fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow-1)^.Id = BLANK_LINE then
    Exit;

  Hide := not fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow-1)^.IsHidden;

  SuggestedMem.UpdateSuggestion(fBankAccount, fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow-1)^.Id, Hide);

  Refresh();
  RefreshMemControls(tblSuggMems.ActiveRow);
  tblSuggMems.Invalidate;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.CloseCalculatingSpinner;
begin
  if (Assigned(ffrmSpinner)) and
     (ffrmSpinner.HandleAllocated) then
    ffrmSpinner.CloseSpinner;
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

//------------------------------------------------------------------------------
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

  if fSuggMemSortedList.GetPRec(RowNum-1)^.isHidden then
    TableCanvas.Font.Style := [fsItalic]
  else
    TableCanvas.Font.Style := [];

  if tblSuggMems.ActiveRow = RowNum then
  begin
    TableCanvas.Font.Color  := clWhite;
    TableCanvas.Brush.Color := bkBranding.SelectionColor;
  end
  else
  begin
    if fSuggMemSortedList.GetPRec(RowNum-1)^.isHidden then
      TableCanvas.Font.Color := clInactiveCaptionText;
  end;

  TableCanvas.FillRect( CellRect );

  if fSuggMemSortedList.GetPRec(RowNum-1)^.Id = BLANK_LINE then
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
procedure TRecommendedMemorisationsFrm.DrawHeadingOnCell(TableCanvas: TCanvas;
  const CellRect: TRect; ColNum: Integer; const CellAttr: TOvcCellAttributes;
  var DoneIt: Boolean);
var
  DataRect : TRect;
  SubRect  : TRect;
  SrcRect  : TRect;
  DestRect  : TRect;
  HeadingStr : string;

  //----------------------------------------------------------------------------
  procedure DrawArrow();
  begin
    SrcRect.Left   := 0;
    SrcRect.Top    := 0;
    SrcRect.Right  := 7;
    SrcRect.Bottom := 7;

    DestRect.Left  := DataRect.Left + TableCanvas.TextWidth(HeadingStr) + 5;
    DestRect.Top    := (DataRect.Top + DataRect.Bottom) div 2 - 5;
    DestRect.Right := DataRect.Left + TableCanvas.TextWidth(HeadingStr) + 12;
    DestRect.Bottom := (DataRect.Top + DataRect.Bottom) div 2 + 2;

    TableCanvas.BrushCopy(DestRect, AppImages.imgGridColArrow.Picture.Bitmap, SrcRect, clyellow);
  end;
begin
  TableCanvas.Font             := CellAttr.caFont;
  TableCanvas.Font.Color       := CellAttr.caFontColor;
  TableCanvas.Brush.Color      := CellAttr.caColor;

  TableCanvas.FillRect( CellRect );

  DataRect := CellRect;
  InflateRect( DataRect, -2, -2 );

  case ColNum of
    ccEntryType : begin
      HeadingStr := 'Entry Type';
      DrawText( TableCanvas.Handle, PChar( HeadingStr ), StrLen( PChar( HeadingStr ) ), DataRect, DT_OPTIONS_STR );

      if fSuggMemSortedList.ColSortOrder = csType then
        DrawArrow();
    end;
    ccStatementDetails : begin
      HeadingStr := 'Statement Details';
      DrawText( TableCanvas.Handle, PChar( HeadingStr ), StrLen( PChar( HeadingStr ) ), DataRect, DT_OPTIONS_STR );

      if fSuggMemSortedList.ColSortOrder = csPhrase then
        DrawArrow();
    end;
    ccCode : begin
      HeadingStr := 'Code';
      DrawText( TableCanvas.Handle, PChar( HeadingStr ), StrLen( PChar( HeadingStr ) ), DataRect, DT_OPTIONS_STR );

      if fSuggMemSortedList.ColSortOrder = csAccount then
        DrawArrow();
    end;
    ccCodedMatch : begin
      SubRect := DataRect;
      SubRect.Bottom := (DataRect.Top + DataRect.Bottom) div 2;
      HeadingStr := 'Coded';
      DrawText( TableCanvas.Handle, PChar( HeadingStr ), StrLen( PChar( HeadingStr ) ), SubRect, DT_OPTIONS_STR );

      SubRect := DataRect;
      SubRect.Top := (DataRect.Top + DataRect.Bottom) div 2;
      HeadingStr := 'Matches';
      DrawText( TableCanvas.Handle, PChar( HeadingStr ), StrLen( PChar( HeadingStr ) ), SubRect, DT_OPTIONS_STR );

      if fSuggMemSortedList.ColSortOrder = csCodedMatch then
        DrawArrow();
    end;
    ccUnCodedMatch : begin
      SubRect := DataRect;
      SubRect.Bottom := (DataRect.Top + DataRect.Bottom) div 2;
      HeadingStr := 'Uncoded';
      DrawText( TableCanvas.Handle, PChar( HeadingStr ), StrLen( PChar( HeadingStr ) ), SubRect, DT_OPTIONS_STR );

      SubRect := DataRect;
      SubRect.Top := (DataRect.Top + DataRect.Bottom) div 2;
      HeadingStr := 'Matches';
      DrawText( TableCanvas.Handle, PChar( HeadingStr ), StrLen( PChar( HeadingStr ) ), SubRect, DT_OPTIONS_STR );

      if fSuggMemSortedList.ColSortOrder = csUncodedMatch then
        DrawArrow();
    end;
  end;

  DoneIt := true;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.SetupForMessage;
begin
  tblSuggMems.Enabled := false;
  btnHide.Enabled := false;
  chkAllowSuggMemPopup.Enabled := false;
  btnCreate.Enabled := false;

  case fMemStatus of
    ssNoFound : begin
      pnlMessage.Visible := true;
      lblMessage.Caption := 'There are no Suggested Memorisations at this time.';
    end;
    ssDisabled : begin
      pnlMessage.Visible := true;
      lblMessage.Caption := 'Suggested Memorisations have been disabled, please contact Support.';
    end;
    ssProcessing : begin
      pnlMessage.Visible := false;
      ffrmSpinner.ShowSpinner('Calculating',
                              (Self.Height div 2) - (ffrmSpinner.Height div 2),
                              (Self.Width div 2) - (ffrmSpinner.Width div 2));
      Setfocus();
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.FillSortedList;
var
  BlankItem : TSuggMemSortedListRec;
  ThereIsHidden, ThereIsUnHidden : boolean;
  Index : integer;
  NewData : pSuggMemSortedListRec;
begin
  fSuggMemSortedList.FreeAll();
  SuggestedMem.GetSuggestedMems(fBankAccount, MyClient.clChart, fSuggMemSortedList);

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

  if (ThereIsHidden and ThereIsUnHidden) then
  begin
    BlankItem.Id := BLANK_LINE;
    fSuggMemSortedList.AddItem(BlankItem);
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.Refresh;
var
  ActiveSuggId : integer;
  Index : integer;
  NewData : pSuggMemSortedListRec;
begin
  fLoading := true;
  try
    if fSuggMemSortedList.ItemCount > 0 then
      ActiveSuggId := fSuggMemSortedList.GetPRec(tblSuggMems.ActiveRow-1)^.Id
    else
      ActiveSuggId := NO_DATA;

    tblSuggMems.RowLimit := 0;

    FillSortedList();

    tblSuggMems.RowLimit := fSuggMemSortedList.ItemCount+1;

    for Index := 0 to fSuggMemSortedList.ItemCount-1 do
    begin
      NewData := fSuggMemSortedList.GetPRec(Index);
      if ActiveSuggId > NO_DATA then
      begin
        if NewData^.Id = ActiveSuggId then
        begin
          tblSuggMems.ActiveRow := Index + 1;
          break;
        end;
      end;
    end;

    tblSuggMems.Invalidate;

  finally
    fLoading := false;
  end;
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

  if fSuggMemSortedList.GetPRec(aRow-1)^.Id = BLANK_LINE then
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
    if fSuggMemSortedList.GetPRec(aRow-1)^.IsHidden then
      btnHide.Caption := 'Un-hide'
    else
      btnHide.Caption := 'Hide';
  end;
end;

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.ReadCellforPaint(RowNum, ColNum: integer; var Data: pointer);
begin
  if fSuggMemSortedList.ItemCount < RowNum then
    Exit;

  case ColNum of
    ccEntryType : begin
      fTempByte := fSuggMemSortedList.GetPRec(RowNum-1)^.AccType;
      Data := @fTempByte;
    end;
    ccStatementDetails : begin
      fTempString := fSuggMemSortedList.GetPRec(RowNum-1)^.MatchedPhrase;
      Data := @fTempString;
    end;
    ccCode : begin
      fTempString := fSuggMemSortedList.GetPRec(RowNum-1)^.Account;
      Data := @fTempString;
    end;
    ccCodedMatch: begin
      fTempInteger := fSuggMemSortedList.GetPRec(RowNum-1)^.ManualCount;
      Data := @fTempInteger;
    end;
    ccUnCodedMatch: begin
      fTempInteger := fSuggMemSortedList.GetPRec(RowNum-1)^.UnCodedCount;
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
  pData := fSuggMemSortedList.GetPRec(aRow-1);

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
      fNeedReCoding := true;
      MainRefresh();
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

//------------------------------------------------------------------------------
procedure TRecommendedMemorisationsFrm.DoSuggestedMemsDoneProcessing;
begin
  CloseCalculatingSpinner();
  MainRefresh();
end;

end.

