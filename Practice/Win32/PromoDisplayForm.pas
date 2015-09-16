unit PromoDisplayForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PromoWindowObj, PromoContentFme, StdCtrls, Buttons, ExtCtrls,
  dxGDIPlusClasses, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdHTTP, OSFont, ImgList, Contnrs, PageNavigation;

type
  TPromoDisplayFrm = class(TForm)
    pnlControls: TPanel;
    ShapeBotBorder: TShape;
    btnClose: TBitBtn;
    cbHidePromo: TCheckBox;
    PageImages: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    PurpleImageIndex : Integer;
    FrameList : TObjectList;
    PageNavigation : TPageNavigation;
    procedure ImageClick(Sender: TObject);
    procedure OnArrowMove(Sender:TObject;Shift: TShiftState;X,Y: Integer);
    procedure OnArrowLeave(Sender : TObject);

    procedure lblRightArrowMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblLeftArrowMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblRightArrowMouseLeave(Sender: TObject);
    procedure lblLeftArrowMouseLeave(Sender: TObject);

    procedure lblRightArrowClick(Sender: TObject);
    procedure lblLeftArrowClick(Sender: TObject);
    procedure PageImageClick(Sender: TObject);
    { Private declarations }
    procedure DisplayPage(aPageIndex : Integer);
    procedure CopyImage(aMoveImg1,aMoveImg2 : TImage);
    procedure OnURLMouseEnter(Sender : TObject);
    procedure OnURLMouseLeave(Sender : TObject);
    procedure OnURLClick(Sender : TObject);
    procedure FreeAllExistingFrames;
  public
    { Public declarations }
  end;


var
  PromoDisplayFrm: TPromoDisplayFrm;

implementation

uses ipshttps, ShellApi, Globals;

{$R *.dfm}


procedure TPromoDisplayFrm.btnCloseClick(Sender: TObject);
begin
  UserINI_Show_Promo_Window := (not cbHidePromo.Checked);
  ShowedPromoWindow := True;
  Close;
end;

procedure TPromoDisplayFrm.CopyImage(aMoveImg1, aMoveImg2: TImage);
var
  tempPic : TPicture;
begin
  tempPic := TPicture.Create;
  try
    tempPic.Assign(aMoveImg2.Picture);
    aMoveImg2.Picture.Assign(aMoveImg1.Picture);
    aMoveImg1.Picture.Assign(tempPic);
  finally
    FreeAndNil(tempPic);
  end;
end;

procedure TPromoDisplayFrm.DisplayPage(aPageIndex: Integer);
var
  i : Integer;
  Content : TContentfulObj;
  NewFrame : TPromoContentFrame;
  Bitmap : TBitmap;
begin
  FreeAllExistingFrames;
  if not Assigned(DisplayPromoContents) then
    Exit;
  //pnlMoveControls.Visible := (DisplayPromoContents.NoOfPagesRequired > 1);
  //pnlMoveControls.Align := alNone;
  //if DisplayPromoContents.NoOfPagesRequired > 1 then
    //pnlMoveControls.Align := alClient;

  for i := 0 to DisplayPromoContents.Count - 1 do
  begin
    Content := TContentfulObj(DisplayPromoContents.Item[i]);
    if Assigned(Content) then
    begin
      if Content.PageIndexWhereToDisplay = aPageIndex then
      begin
        NewFrame := TPromoContentFrame.Create(Self);
        FrameList.Add(NewFrame);
        NewFrame.Parent := Self;
        NewFrame.Name := NewFrame.Name + IntToStr(aPageIndex) +  IntToStr(i);
        NewFrame.TabOrder := i+1;
        NewFrame.Align := alBottom;
        NewFrame.Align := alTop;
        NewFrame.lblTitle.Caption := Content.Title;
        NewFrame.lblTitle.Font.Color := HyperLinkColor;
        NewFrame.lblTitle.Font.Style := [fsBold, fsUnderline];
        NewFrame.reDescription.Lines.Clear;
        NewFrame.reDescription.Lines.Add(Content.Description);
        NewFrame.lblURL.Caption := Content.URL;
        NewFrame.lblURL.Font.Color := HyperLinkColor;
        NewFrame.lblURL.OnMouseEnter := OnURLMouseEnter;
        NewFrame.lblURL.OnMouseLeave := OnURLMouseLeave;
        NewFrame.lblURL.OnClick := OnURLClick;
        NewFrame.ParentFont := True;
        NewFrame.ParentColor := True;
        if Content.IsImageAvilable then
        begin
          NewFrame.imgContainer.Picture.Assign(Content.MainImageBitmap);
          NewFrame.Height := CONTENT_HEIGHT_WITHIMAGE;
        end
        else
          NewFrame.Height := CONTENT_HEIGHT_WITHOUTIMAGE;

        NewFrame.imgContainer.Visible := Content.IsImageAvilable;
        NewFrame.lblURL.Visible := (Trim(Content.URL) <> '');
      end
      else if Content.PageIndexWhereToDisplay > aPageIndex then // no need to process more
        Break; // Break the loop
    end;
  end;

  if DisplayPromoContents.NoOfPagesRequired > 1 then
  begin
    //pnlMoveControls.Visible := True;
    PageNavigation.Visible := True;
    PageNavigation.Align := alBottom;
    PageNavigation.NoOfPages := DisplayPromoContents.NoOfPagesRequired;
  end;

  PageNavigation.ResetTop;
end;

procedure TPromoDisplayFrm.FormCreate(Sender: TObject);
begin
  FrameList := TObjectList.Create;
  PageNavigation := TPageNavigation.Create(self);
  PageNavigation.Visible := False;
  PageNavigation.Parent := Self;//pnlMoveControls;
  PageNavigation.Height := 44;
  PageNavigation.Width := 600;
  PageNavigation.ImageList := PageImages;
  PageNavigation.OnLeftArrowClick := lblRightArrowClick;
  PageNavigation.OnRightArrowClick := lblLeftArrowClick;
  PageNavigation.OnImageClick := PageImageClick;
  
  PageNavigation.PageControlMargin := 4;
  PageNavigation.PageControlWidth := 20;
  if Assigned(DisplayPromoContents) then
  begin
    DisplayPromoContents.PromoMainWindowHeight := 800-pnlControls.Height - PageNavigation.Height ;//pnlMoveControls.Height;
    //pnlMoveControls.Width := 600;
    DisplayPromoContents.SetContentDisplayProperties;// set display properties
    DisplayPage(1);
  end;
  PurpleImageIndex := 1;
end;

procedure TPromoDisplayFrm.FormDestroy(Sender: TObject);
begin
  FrameList.Clear;
  FreeAndNil(FrameList);
  FreeAndNil(PageNavigation);
end;

procedure TPromoDisplayFrm.FreeAllExistingFrames;
begin
  FrameList.Clear;
end;

procedure TPromoDisplayFrm.ImageClick(Sender: TObject);
begin
  inherited;
end;

procedure TPromoDisplayFrm.lblLeftArrowClick(Sender: TObject);
begin
  inherited;
  DisplayPage(PageNavigation.CurrentPage);
end;

procedure TPromoDisplayFrm.lblLeftArrowMouseLeave(Sender: TObject);
begin
  inherited
end;

procedure TPromoDisplayFrm.lblLeftArrowMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TPromoDisplayFrm.lblRightArrowClick(Sender: TObject);
begin
  inherited;
  DisplayPage(PageNavigation.CurrentPage);
end;

procedure TPromoDisplayFrm.lblRightArrowMouseLeave(Sender: TObject);
begin
  inherited;
end;

procedure TPromoDisplayFrm.lblRightArrowMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TPromoDisplayFrm.OnArrowLeave(Sender: TObject);
begin
  inherited;
end;

procedure TPromoDisplayFrm.OnArrowMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
end;

procedure TPromoDisplayFrm.OnURLClick(Sender: TObject);
var
  sURL : string;
  //UrlPosition : Integer;
begin
  sURL := TLabel(Sender).Caption;
  {UrlPosition := Pos('URL: ', sURL);
  if UrlPosition > 0 then
  begin
    // get url by removing URL: from the caption
    sURL := Copy(sURL, UrlPosition+5, Length(sURL));
  end;}
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

end.
