unit PageNavigation;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, ImgList, Contnrs, Graphics,
  StdCtrls, Forms, Variants;

type
  TColourType = (ctGrey, ctPurple);

  TPageNavigation = class(TPanel)
  private
    { Private declarations }
    FNoOfPages : Integer;
    FImageList : TImageList;
    FLeftArrow : TLabel;
    FRightArrow : TLabel;
    FPages : TObjectList;
    FCurrentPage : Integer;
    FPageControlMargin : Integer;
    FPageControlWidth : Integer;
    FOnLeftArrowClick : TNotifyEvent;
    FOnRightArrowClick : TNotifyEvent;
    FOnImageClick : TNotifyEvent;

    function GetPage(Index : Integer):TImage;

    procedure SetNoOfPages(Value : Integer);
    procedure CopyImage(aSource,aDestination : TImage);
    procedure LayoutPages;
    procedure OnArrowMove(Sender:TObject;Shift: TShiftState;X,Y: Integer);
    procedure OnArrowLeave(Sender : TObject);

    procedure SetPageImageColour(aImage : TImage;aColour : TColourType);
    procedure SetAllPagesToGrey;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);
    destructor Destroy;override;
    property Page[Index:Integer] : TImage read GetPage;
  published
    { Published declarations }
    property NoOfPages : Integer read FNoOfPages write SetNoOfPages;
    property ImageList : TImageList read FImageList write FImageList;
    property LeftArrow : TLabel read FLeftArrow;
    property RightArrow : TLabel read FRightArrow;

    property CurrentPage : Integer read FCurrentPage write FCurrentPage;
    property PageControlMargin : Integer read FPageControlMargin write FPageControlMargin;
    property PageControlWidth : Integer read FPageControlWidth write FPageControlWidth;

    property OnLeftArrowClick : TNotifyEvent read FOnLeftArrowClick write FOnLeftArrowClick;
    property OnRightArrowClick : TNotifyEvent read FOnRightArrowClick write FOnRightArrowClick;
    property OnImageClick : TNotifyEvent read FOnImageClick write FOnImageClick;

    procedure lblRightArrowMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblLeftArrowMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblRightArrowMouseLeave(Sender: TObject);
    procedure lblLeftArrowMouseLeave(Sender: TObject);

    procedure lblRightArrowClick(Sender: TObject);
    procedure lblLeftArrowClick(Sender: TObject);
    procedure ImageClick(Sender: TObject);

    procedure ResetTop;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  RegisterComponents('myob', [TPageNavigation]);
end;

{ TPageNavigation }

procedure TPageNavigation.CopyImage(aSource, aDestination: TImage);
var
  tempPic : TPicture;
begin
  tempPic := TPicture.Create;
  try
    tempPic.Assign(aDestination.Picture);
    aDestination.Picture.Assign(aSource.Picture);
    aSource.Picture.Assign(tempPic);
  finally
    FreeAndNil(tempPic);
  end;
end;

constructor TPageNavigation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OnLeftArrowClick := Nil;
  OnRightArrowClick := Nil;
  FCurrentPage := 1;
  FPageControlMargin := 4;
  FPageControlWidth := 20;

  Self.Height := 44;
  Self.Height := 600;
  Self.Align := alBottom;
  Self.BevelInner := bvNone;
  Self.BevelKind := bkNone;
  Self.BevelOuter := bvNone;
  Self.BorderStyle := bsNone;

  FLeftArrow := TLabel.Create(Self);
  FLeftArrow.Parent := Self;
  FLeftArrow.OnClick := lblLeftArrowClick;
  FLeftArrow.OnMouseMove := lblLeftArrowMouseMove;
  FLeftArrow.OnMouseLeave := lblLeftArrowMouseLeave;
  //FLeftArrow.Owner := Self;
  FLeftArrow.AutoSize := False;
  FLeftArrow.Caption := '<';
  FLeftArrow.Height := 33;
  FLeftArrow.Width := FPageControlWidth;
  FLeftArrow.Font.Size := 20;
  FLeftArrow.Font.Style := [fsBold];

  FRightArrow := TLabel.Create(Self);
  FRightArrow.Parent := Self;
  FRightArrow.AutoSize := False;
  FRightArrow.OnClick := lblRightArrowClick;
  FRightArrow.OnMouseMove := lblRightArrowMouseMove;
  FRightArrow.OnMouseLeave := lblRightArrowMouseLeave;
  //FRightArrow.Owner := Self;
  FRightArrow.Caption := '>';
  FRightArrow.Height := 33;
  FRightArrow.Width := FPageControlWidth;
  FRightArrow.Font.Size := 20;
  FRightArrow.Font.Style := [fsBold];

  FPages := TObjectList.Create;
  NoOfPages := 2;
end;

destructor TPageNavigation.Destroy;
begin
  FreeAndNil(FLeftArrow);
  FreeAndNil(FRightArrow);

  FPages.Clear;
  FreeAndNil(FPages);
  
  inherited;
end;

function TPageNavigation.GetPage(Index: Integer): TImage;
begin
  Result := Nil;
  if ((Index >= 0) and (Index < FNoOfPages)) then
    Result := TImage(FPages[Index]);
end;

procedure TPageNavigation.ImageClick(Sender: TObject);
begin
  if not (Sender is TImage) then
    Exit;

  FCurrentPage := TImage(Sender).Tag;
  SetAllPagesToGrey;
  SetPageImageColour(TImage(Sender), ctPurple);

  if Assigned(OnImageClick) then
    OnImageClick(Sender);
end;

procedure TPageNavigation.LayoutPages;
var
  NoOfControlsToPlace, HalfControls : Integer;
  CenterPos, LeftStart, i: Integer;
  Page : TImage;
begin
  if FPages.Count <= 0 then
    Exit;

  // no of pages and left arrow and right arrow
  NoOfControlsToPlace := NoOfPages + 2;
  CenterPos := Width div 2;
  HalfControls := Ceil(NoOfControlsToPlace / 2);

  LeftStart := CenterPos - HalfControls* ( FPageControlWidth + FPageControlMargin);
  FLeftArrow.Left := LeftStart;
  LeftStart := LeftStart + FPageControlWidth + FPageControlMargin;

  for i  := 0 to FPages.Count - 1 do
  begin
    Page := GetPage(i);
    if Assigned(Page) then
    begin
      Page.Left := LeftStart;
      Page.Visible := True;
      LeftStart := LeftStart + FPageControlWidth + FPageControlMargin;
    end;
  end;
  FRightArrow.Left := LeftStart;
  LeftStart := LeftStart + FPageControlWidth + FPageControlMargin;
  FLeftArrow.Visible := True;
  FLeftArrow.Top := 6;
  FLeftArrow.ParentColor := False;
  FLeftArrow.ParentFont := False;
  FLeftArrow.AutoSize := True;
  FRightArrow.Visible := True;
  FRightArrow.Top := FLeftArrow.Top;
  FRightArrow.ParentColor := FLeftArrow.ParentColor;
  FRightArrow.ParentFont := FLeftArrow.ParentFont;
  FRightArrow.AutoSize := FLeftArrow.AutoSize;
end;

procedure TPageNavigation.lblLeftArrowClick(Sender: TObject);
var
  SourceImg , DestImg : TImage;
begin
  if FCurrentPage <= 1 then
    Exit;

  SourceImg :=  GetPage(FCurrentPage-2);
  DestImg := GetPage(FCurrentPage-1);
  if (Assigned(SourceImg) and Assigned(DestImg)) then
  begin
    CopyImage(SourceImg, DestImg);
    if FCurrentPage <> 1 then
      Dec(FCurrentPage);
  end;

  if Assigned(OnLeftArrowClick) then
    OnLeftArrowClick(Sender);
end;

procedure TPageNavigation.lblLeftArrowMouseLeave(Sender: TObject);
begin
  OnArrowLeave(Sender);
end;

procedure TPageNavigation.lblLeftArrowMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  OnArrowMove(Sender, Shift, X,Y);
end;

procedure TPageNavigation.lblRightArrowClick(Sender: TObject);
var
  SourceImg , DestImg : TImage;
begin
  if FCurrentPage >= FNoOfPages then
    Exit;

  SourceImg :=  GetPage(FCurrentPage-1);
  DestImg := GetPage(FCurrentPage);
  if (Assigned(SourceImg) and Assigned(DestImg)) then
  begin
    CopyImage(SourceImg, DestImg);

    if FCurrentPage < FNoOfPages then
      Inc(FCurrentPage);
  end;

  if Assigned(OnRightArrowClick) then
    OnRightArrowClick(Sender);
end;

procedure TPageNavigation.lblRightArrowMouseLeave(Sender: TObject);
begin
  OnArrowLeave(Sender);
end;

procedure TPageNavigation.lblRightArrowMouseMove
(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  OnArrowMove(Sender, Shift, X,Y);
end;

procedure TPageNavigation.OnArrowLeave(Sender: TObject);
begin
  if (not (Sender is TLabel)) then
    Exit;
  Screen.Cursor := crDefault;
  TLabel(Sender).Font.Color := clBlack;
end;

procedure TPageNavigation.OnArrowMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (not (Sender is TLabel)) then
    Exit;
  Screen.Cursor := crHandPoint;
  TLabel(Sender).Font.Color := clPurple;
  TLabel(Sender).Font.Color := clBlack;
end;

procedure TPageNavigation.ResetTop;
var
  Position, i : Integer;
  Image : TImage;
begin
  Position := Ceil((Self.Height - LeftArrow.Height) / 2);
  LeftArrow.Top := Position;
  RightArrow.Top := Position;
  for i := 0 to FPages.Count - 1 do
  begin
    Image := TImage(GetPage(i));
    if Assigned(Image) then
    begin
      Position := Ceil((Self.Height - Image.Height) / 2);
      Image.Top := Position;
    end;
  end;
end;

procedure TPageNavigation.SetAllPagesToGrey;
var
  i : Integer;
begin
  for i := 0 to FPages.Count - 1 do
    SetPageImageColour(TImage(FPages.Items[i]),ctGrey);
end;

procedure TPageNavigation.SetNoOfPages(Value : Integer);
var
  i : Integer;
  PageImage : TImage;
begin
  if Value <= 1 then
    Visible := False;

  if not Assigned(ImageList) then
    Exit;

  FNoOfPages := Value;
  for i  := 1 to Value do
  begin
    PageImage := TImage.Create(Self);
    PageImage.Parent := Self;
    PageImage.Visible := True;
    PageImage.Height := FPageControlWidth;
    PageImage.Width := FPageControlWidth;
    PageImage.Tag := i;
    PageImage.Top := 14;
    PageImage.Center := True;
    PageImage.OnClick := ImageClick;
    
    if i = 1  then
      SetPageImageColour(PageImage, ctPurple)
    else
      SetPageImageColour(PageImage, ctGrey);

    FPages.Add(PageImage);
  end;

  LayoutPages;
end;

procedure TPageNavigation.SetPageImageColour(aImage: TImage;
  aColour: TColourType);
var
  Bitmap : TBitmap;
begin
  Bitmap := TBitmap.Create;
  try
    case aColour of
      ctGrey: FImageList.GetBitmap(1, Bitmap);
      ctPurple: FImageList.GetBitmap(0, Bitmap);
    end;

    if Assigned(Bitmap) then
      aImage.Picture.Assign(Bitmap);

  finally
    FreeAndNil(Bitmap);
  end;
end;

end.
