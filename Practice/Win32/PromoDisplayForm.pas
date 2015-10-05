unit PromoDisplayForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PromoWindowObj, PromoContentFme, StdCtrls, Buttons, ExtCtrls,
  dxGDIPlusClasses, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, OSFont, ImgList, Contnrs, PageNavigation;

type
  {This is the main promo screen where all content types will be displayed.
  Each content type is a frame will be added on the fly based on the content type selected
  or the time of firing}
  TPromoDisplayFrm = class(TForm)
    pnlControls: TPanel;
    ShapeBotBorder: TShape;
    btnClose: TBitBtn;
    cbHidePromo: TCheckBox;
    PageImages: TImageList;
    pnlFrames: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    PurpleImageIndex : Integer;
    {Each fram added to the form will be saved in this list so that it can be freed later}
    FrameList : TObjectList;
    {Page navigation component which has left arrow, right arrow and circle images
    equal to the no of pages. This is visible only if the no of pages > 1.}
    PageNavigation : TPageNavigation;
    procedure SetSize;
    procedure lblRightArrowClick(Sender: TObject);
    procedure lblLeftArrowClick(Sender: TObject);
    procedure PageImageClick(Sender: TObject);

    { Private declarations }
    function CalculatePagesRequired: Integer;
    procedure DisplayPage(aPageIndex : Integer);

    procedure OnURLMouseEnter(Sender : TObject);
    procedure OnURLMouseLeave(Sender : TObject);
    procedure OnURLClick(Sender : TObject);
    procedure FreeAllExistingFrames;
  public
    { Public declarations }
  protected
    procedure WndProc (var Msg: TMessage);override;
  end;


var
  PromoDisplayFrm: TPromoDisplayFrm;

implementation

uses ipshttps, ShellApi, Globals, math,cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMemo, cxRichEdit,
  RichEdit;

{$R *.dfm}

procedure TPromoDisplayFrm.WndProc (var Msg: TMessage);
var
  p: TENLink;
  sURL: string;
  reDesc: TcxRichEdit;
begin
  if (Msg.Msg = WM_NOTIFY) then
  begin
    if (PNMHDR (Msg.lParam). code = EN_LINK) then
    begin
      p := TENLink (Pointer (TWMNotify (Msg). NMHdr) ^);
      if (p.Msg = WM_LBUTTONDOWN) then
      begin
        try
          reDesc := TcxRichEdit(self.ActiveControl);
          SendMessage (reDesc.Handle, EM_EXSETSEL, 0, Longint (@ (p.chrg)));
          sURL := reDesc.SelText;
          ShellExecute (Handle, 'open', PChar (sURL), 0, 0, SW_SHOWNORMAL);
        except

        end;
      end;
    end;
  end;
  inherited;
end;

procedure TPromoDisplayFrm.btnCloseClick(Sender: TObject);
begin
  //UserINI_Show_Promo_Window := (not cbHidePromo.Checked);
  ShowedPromoWindow := True;
  Close;
end;

function TPromoDisplayFrm.CalculatePagesRequired: Integer;
var
  i : Integer;
  Content : TContentfulObj;
  TotalHeight : Integer;
  PageIndex : Integer;
  NewFrame: TPromoContentFrame;
begin
  TotalHeight := 0;
  Result := 1;
  for i := 0 to DisplayPromoContents.Count - 1  do
  begin
    Content := TContentfulObj(DisplayPromoContents.Item[i]);
    if Assigned(Content) then
    begin
      NewFrame := TPromoContentFrame.Create(Self,Content);
      try
        NewFrame.Parent := pnlFrames;
        NewFrame.TabOrder := i;

        TotalHeight := TotalHeight + NewFrame.Height+5;
        Content.FrameHeightRequired := NewFrame.Height+5;
      finally
        FreeAndNil(NewFrame);
      end;
    end;
  end;

  if DisplayPromoContents.PromoMainWindowHeight <> 0 then
    Result := Ceil(TotalHeight/DisplayPromoContents.PromoMainWindowHeight);
  DisplayPromoContents.NoOfPagesRequired := Result;

  PageIndex := 1;
  TotalHeight := 0;
  DisplayPromoContents.SortContentfulData;

  for i := 0 to DisplayPromoContents.Count - 1 do
  begin
    Content := TContentfulObj(DisplayPromoContents.Item[i]);
    if Assigned(Content) then
    begin
      TotalHeight := TotalHeight + Content.FrameHeightRequired;

      if (TotalHeight < DisplayPromoContents.PromoMainWindowHeight) then
        Content.PageIndexWhereToDisplay := PageIndex
      else
      begin
        Inc(PageIndex);
        if PageIndex > CONTENT_MAX_PAGES_TODISPLAY then
          PageIndex := 0;

        Content.PageIndexWhereToDisplay := PageIndex;
        TotalHeight := Content.FrameHeightRequired;
      end;
    end;
  end;
end;

procedure TPromoDisplayFrm.DisplayPage(aPageIndex: Integer);
var
  i : Integer;
  Content : TContentfulObj;
  NewFrame: TPromoContentFrame;
begin
  FreeAllExistingFrames;
  if not Assigned(DisplayPromoContents) then
    Exit;

  DisplayPromoContents.SortContentfulData;
  for i := 0 to DisplayPromoContents.Count - 1  do
  begin
    Content := TContentfulObj(DisplayPromoContents.Item[i]);
    if Assigned(Content) then
    begin
      if Content.PageIndexWhereToDisplay = aPageIndex then
      begin
        {Frame is created and the contents will be assigned}
        NewFrame := TPromoContentFrame.Create(Self, Content);

        NewFrame.Parent := pnlFrames;//Self;
        NewFrame.Name := NewFrame.Name + IntToStr(aPageIndex) +  IntToStr(i);
        NewFrame.lblURL.OnMouseEnter := OnURLMouseEnter;
        NewFrame.lblURL.OnMouseLeave := OnURLMouseLeave;
        NewFrame.lblURL.OnClick := OnURLClick;
        NewFrame.TabOrder := i;

        FrameList.Add(NewFrame);
      end;
    end;
  end;

  if DisplayPromoContents.NoOfPagesRequired > 1 then
  begin
    //pnlMoveControls.Visible := True;
    PageNavigation.Visible := True;
    PageNavigation.Align := alBottom;
  end;
  pnlFrames.Align := alClient;

  for i := 0 to FrameList.Count - 1 do
  begin
    NewFrame := TPromoContentFrame(FrameList.Items[i]);
    NewFrame.Align :=  alBottom;
    NewFrame.Align :=  alTop;
  end;

  PageNavigation.ResetTop;
end;

procedure TPromoDisplayFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DisplayPromoContents.DisplayTypes := [ctUpgrade, ctMarketing, ctTechnical];
  DisplayPromoContents.ListValidContents;
end;

procedure TPromoDisplayFrm.FormCreate(Sender: TObject);
begin
  FrameList := TObjectList.Create;
  PageNavigation := TPageNavigation.Create(self);
  SetSize;
  PageNavigation.Visible := False;
  PageNavigation.Parent := Self;//pnlMoveControls;
  PageNavigation.Height := 40;
  PageNavigation.Width := Self.Width;
  PageNavigation.ImageList := PageImages;
  PageNavigation.OnLeftArrowClick := lblRightArrowClick;
  PageNavigation.OnRightArrowClick := lblLeftArrowClick;
  PageNavigation.OnImageClick := PageImageClick;

  PageNavigation.PageControlMargin := 4;
  PageNavigation.PageControlWidth := 20;
end;

procedure TPromoDisplayFrm.FormDestroy(Sender: TObject);
begin
  FrameList.Clear;
  FreeAndNil(FrameList);
  FreeAndNil(PageNavigation);
end;

procedure TPromoDisplayFrm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 27 then
    Close;
end;

procedure TPromoDisplayFrm.FormShow(Sender: TObject);
begin
  SetSize;
  if Assigned(DisplayPromoContents) then
  begin
    DisplayPromoContents.SortContentfulData;
    DisplayPromoContents.PromoMainWindowHeight := Self.ClientHeight - pnlControls.Height - PageNavigation.Height ;//pnlMoveControls.Height;
    DisplayPromoContents.NoOfPagesRequired := CalculatePagesRequired;
    DisplayPromoContents.SortContentfulData;
    PageNavigation.NoOfPages := DisplayPromoContents.NoOfPagesRequired;
  end;
  PurpleImageIndex := 1;

  DisplayPage(1);
end;

procedure TPromoDisplayFrm.FreeAllExistingFrames;
begin
  FrameList.Clear;
end;

procedure TPromoDisplayFrm.lblLeftArrowClick(Sender: TObject);
begin
  inherited;
  DisplayPage(PageNavigation.CurrentPage);
end;

procedure TPromoDisplayFrm.lblRightArrowClick(Sender: TObject);
begin
  inherited;
  DisplayPage(PageNavigation.CurrentPage);
end;

procedure TPromoDisplayFrm.OnURLClick(Sender: TObject);
var
  sURL : string;
begin
  sURL := TLabel(Sender).Caption;
  ShellExecute(0, 'OPEN', PChar(sURL), '', '', SW_SHOWNORMAL);
end;

procedure TPromoDisplayFrm.OnURLMouseEnter(Sender: TObject);
begin
  SetHyperlinkFont(TLabel(Sender).Font);
  Screen.Cursor := crHandPoint;
end;

procedure TPromoDisplayFrm.OnURLMouseLeave(Sender: TObject);
begin
  TLabel(Sender).Font.Style := [];
  Screen.Cursor := crDefault;
end;

procedure TPromoDisplayFrm.PageImageClick(Sender: TObject);
begin
  inherited;
  DisplayPage(PageNavigation.CurrentPage);
end;

procedure TPromoDisplayFrm.SetSize;
begin
  Self.Width := Screen.Width * 1 div 3;
  Self.Height := Screen.Height * 3 div 4;
end;

end.
