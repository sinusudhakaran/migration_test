unit PageNavigation;

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, ImgList, Contnrs, Graphics,
  StdCtrls, Forms, Variants;
type
  {Colour types used to active and inactive pages - Gray for inactive and purple for active}
  TColourType = (ctGray, ctPurple);

  TOnArrowMouseMove = procedure(Sender:TObject;Shift: TShiftState;X,Y: Integer) of object;

  {This class creates a set of pages (basically using image controls to fake page navigation)
  }
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
    //procedure CopyImage(aSource,aDestination : TImage);
    procedure LayoutPages;

    procedure SetPageImageColour(aImage : TImage;aColour : TColourType);
    procedure SetAllPagesToGrey;

    procedure lblRightArrowClick(Sender: TObject);
    procedure lblLeftArrowClick(Sender: TObject);
    procedure ImageClick(Sender: TObject);
    procedure OnArrowMove(Sender:TObject;Shift: TShiftState;X,Y: Integer);
    procedure OnArrowLeave(Sender : TObject);

  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);reintroduce;
    destructor Destroy;override;
    property Page[Index:Integer] : TImage read GetPage;
  published
    { Published declarations }
    property NoOfPages : Integer read FNoOfPages write SetNoOfPages;
    {Image list is a list of grey and purple bullet images that can be shown for pages.
    This should be assigned from the calling place}
    property ImageList : TImageList read FImageList write FImageList;
    property LeftArrow : TLabel read FLeftArrow;
    property RightArrow : TLabel read FRightArrow;

    property CurrentPage : Integer read FCurrentPage write FCurrentPage;
    property PageControlMargin : Integer read FPageControlMargin write FPageControlMargin;
    property PageControlWidth : Integer read FPageControlWidth write FPageControlWidth;

    property OnLeftArrowClick : TNotifyEvent read FOnLeftArrowClick write FOnLeftArrowClick;
    property OnRightArrowClick : TNotifyEvent read FOnRightArrowClick write FOnRightArrowClick;
    property OnImageClick : TNotifyEvent read FOnImageClick write FOnImageClick;
    {Once show all frames, reassign the top of the navigation controls}
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

(*procedure TPageNavigation.CopyImage(aSource, aDestination: TImage);
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
*)

constructor TPageNavigation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  //Globals
  FOnImageClick := Nil;
  FOnLeftArrowClick := Nil;
  FOnRightArrowClick := Nil;
  FCurrentPage := 1;
  FPageControlMargin := 4;
  FPageControlWidth := 20;

  // Layot and settings of main panel
  Self.Height := 44;
  Self.Width := 600;
  Self.Align := alBottom;
  Self.BevelInner := bvNone;
  Self.BevelKind := bkNone;
  Self.BevelOuter := bvNone;
  Self.BorderStyle := bsNone;

  // Layout of left arrow
  FLeftArrow := TLabel.Create(Self);
  FLeftArrow.ParentColor := False;
  FLeftArrow.Color := clRed;
  FLeftArrow.Parent := Self;

  FLeftArrow.OnClick := lblLeftArrowClick;
  FLeftArrow.OnMouseMove := OnArrowMove;
  FLeftArrow.OnMouseLeave := OnArrowLeave;
  FLeftArrow.Caption := '<';
  FLeftArrow.AutoSize := True;
  FLeftArrow.Alignment := taCenter;
  FLeftArrow.Height := Self.Height;
  FLeftArrow.Width := FPageControlWidth;
  FLeftArrow.Font.Size := 20;
  FLeftArrow.Font.Style := [fsBold];

  // Layout of right arrow
  FRightArrow := TLabel.Create(Self);
  FRightArrow.ParentColor := False;
  FRightArrow.Color := clRed;
  FRightArrow.Parent := Self;
  FRightArrow.OnClick := lblRightArrowClick;
  FRightArrow.OnMouseMove := OnArrowMove;
  FRightArrow.OnMouseLeave := OnArrowLeave;
  FRightArrow.Caption := '>';
  FRightArrow.Alignment := FLeftArrow.Alignment;
  FRightArrow.Height := FLeftArrow.Height;
  FRightArrow.AutoSize := FLeftArrow.AutoSize;
  FRightArrow.Width := FPageControlWidth;
  FRightArrow.Font.Size := FLeftArrow.Font.Size;
  FRightArrow.Font.Style := FLeftArrow.Font.Style;

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
      Page.Height := FPageControlWidth;
      Page.Width := FPageControlWidth;
      Page.Visible := True;
      Page.Center := True;

      LeftStart := LeftStart + FPageControlWidth + FPageControlMargin;
    end;
  end;

  FRightArrow.Left := LeftStart;
  FLeftArrow.Visible := True;
  FLeftArrow.ParentColor := False;
  FLeftArrow.ParentFont := False;
  FRightArrow.Visible := True;
  FRightArrow.Top := FLeftArrow.Top;
  FRightArrow.ParentColor := FLeftArrow.ParentColor;
  FRightArrow.ParentFont := FLeftArrow.ParentFont;
  FRightArrow.AutoSize := FLeftArrow.AutoSize;
end;

procedure TPageNavigation.lblLeftArrowClick(Sender: TObject);
begin
  if FCurrentPage <= 1 then
    Exit;

  if FCurrentPage <> 1 then
    Dec(FCurrentPage);

  SetAllPagesToGrey;
  SetPageImageColour(TImage(FPages.Items[FCurrentPage-1]), ctPurple);

  if Assigned(OnLeftArrowClick) then
    OnLeftArrowClick(Sender);
end;

procedure TPageNavigation.lblRightArrowClick(Sender: TObject);
begin
  if FCurrentPage >= FNoOfPages then
    Exit;

  if FCurrentPage < FNoOfPages then
    Inc(FCurrentPage);

  SetAllPagesToGrey;

  SetPageImageColour(TImage(FPages.Items[FCurrentPage-1]), ctPurple);

  if Assigned(OnRightArrowClick) then
    OnRightArrowClick(Sender);
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
      Image.Top := Position+1;
    end;
  end;
end;

procedure TPageNavigation.SetAllPagesToGrey;
var
  i : Integer;
begin
  for i := 0 to FPages.Count - 1 do
    SetPageImageColour(TImage(FPages.Items[i]),ctGray);
end;

procedure TPageNavigation.SetNoOfPages(Value : Integer);
var
  i : Integer;
  PageImage : TImage;
begin
  FPages.Clear;
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
    PageImage.Tag := i;
    PageImage.OnClick := ImageClick;

    if i = 1  then
      SetPageImageColour(PageImage, ctPurple)
    else
      SetPageImageColour(PageImage, ctGray);

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
      ctGray: FImageList.GetBitmap(1, Bitmap);
      ctPurple: FImageList.GetBitmap(0, Bitmap);
    end;

    if Assigned(Bitmap) then
      aImage.Picture.Assign(Bitmap);

  finally
    FreeAndNil(Bitmap);
  end;
end;

end.
