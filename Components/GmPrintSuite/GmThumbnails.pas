{******************************************************************************}
{                                                                              }
{                              GmThumbnails.pas                                }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmThumbnails;

interface

uses Windows, Forms, Classes, Messages, Controls, Graphics, GmPageList, GmClasses,
  Menus, GmPreview, GmTypes, GmConst, GmResource;

{$I GMPS.INC}

type
  TGmThumbnails = class;

  TGmThumbnail = class(TGmPaperImage)
  private
    FSelected: Boolean;
    FThumbnails: TGmThumbnails;
    // events...
    procedure SetSelected(Value: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Selected: Boolean read FSelected write SetSelected default False;
  end;

  TGmThumbnails = class(TGmScrollingPageControl)
  private
    FCaptionFont: TFont;
    FCaptions: string;
    FGridWidth: integer;
    FHighlight: Boolean;
    FHighlightStyle: TGmHighlightStyle;
    FItemIndex: integer;
    FLayout: TGmThumbNailLayout;
    FPlainPages: Boolean;
    FPreview: TGmPreview;
    FScrollIntoView: Boolean;
    FSelectedColor: TColor;
    FShadow: TGmShadow;
    FShowCaption: Boolean;
    FThumbnailList: TGmObjectList;
    FThumbPopup: TPopupMenu;
    FThumbSize: integer;
    FThumbSpacing: integer;
    FUpdateCount: integer;
    // events...
    function AddThumbnail: TGmThumbnail;
    function GetThumbnail(index: integer): TGmThumbnail;
    procedure Changed;
    procedure DeleteThumbnail;
    procedure FontChanged(Sender: TObject);
    procedure ResizeThumbList;
    procedure RescaleThumbnails;
    procedure RedrawThumbnails;
    procedure Repaginate;
    procedure SetCaptionFont(Value: TFont);
    procedure SetCaptions(Value: string);
    procedure SetGridWidth(Value: integer);
    procedure SetHighlight(Value: Boolean);
    procedure SetHighlightStyle(Value: TGmHighlightStyle);
    procedure SetItemIndex(Value: integer);
    procedure SetLayout(Value: TGmThumbNailLayout);
    procedure SetPlainPages(Value: Boolean);
    procedure SetPreview(APreview: TGmPreview);
    procedure SetSelectedColor(Value: TColor);
    procedure SetShadow(Value: TGmShadow);
    procedure SetShowCaption(Value: Boolean);
    procedure SetThumbnail(index: integer; const Value: TGmThumbnail);
    procedure SetThumbPopup(Value: TPopupMenu);
    procedure SetThumbSize(Value: integer);
    procedure SetThumbSpacing(Value: integer);
    procedure ThumbMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    property Thumbnail[index: integer]: TGmThumbnail read GetThumbnail write SetThumbnail; default;
  protected
    procedure GmBeginUpdate(var Message: TMessage); message GM_BEGINUPDATE;
    procedure GmEndUpdate(var Message: TMessage); message GM_ENDUPDATE;
    procedure GmHeaderFooterChanged(var Message: TMessage); message GM_HEADERFOOTER_CHANGED;
    procedure GmNumPagesChanged(var Message: TMessage); message GM_PAGE_COUNT_CHANGED;
    procedure GmPageContentChanged(var Message: TMessage); message GM_PAGE_CONTENT_CHANGED;
    procedure GmPageNumChanged(var Message: TMessage); message GM_PAGE_NUM_CHANGED;
    procedure GmPaperSizeChanged(var Message: TMessage); message GM_PAPERSIZE_CHANGED;
    procedure Notification(AComponent: TComponent; Operation: TOperation);  override;
    property ItemIndex: integer read FItemIndex write SetItemIndex;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure UpdateThumbnails;
  published
    property CaptionFont: TFont read FCaptionFont write SetCaptionFont;
    property GridWidth: integer read FGridWidth write SetGridWidth default 4;
    property Highlight: Boolean read FHighlight write SetHighlight default True;
    property HighlightStyle: TGmHighlightStyle read FHighlightStyle write SetHighlightStyle default gmThickLine;
    property Layout: TGmThumbNailLayout read FLayout write SetLayout default gmThumbHorz;
    property PageCaptions: string read FCaptions write SetCaptions;
    property PlainPages: Boolean read FPlainPages write SetPlainPages default False;
    property Preview: TGmPreview read FPreview write SetPreview;
    property ScrollIntoView: Boolean read FScrollIntoView write FScrollIntoView default True;
    property SelectedColor: TColor read FSelectedColor write SetSelectedColor default clBlue;
    property Shadow: TGmShadow read FShadow write SetShadow;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption default True;
    property ThumbPopup: TPopupMenu read FThumbPopup write SetThumbPopup;
    property ThumbSize: integer read FThumbSize write SetThumbSize default 4;
    property ThumbSpacing: integer read FThumbSpacing write SetThumbSpacing default 8;
  end;

implementation

uses GmFuncs, ExtCtrls, SysUtils;

constructor TGmThumbnail.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThumbnails := TGmThumbnails(AOwner);
  FSelected := False;
  FastDraw := True;
end;

procedure TGmThumbnail.SetSelected(Value: Boolean);
begin
  if FSelected = Value then Exit;
  FSelected := Value;
  Invalidate;
end;

procedure TGmThumbnail.Paint;
var
  TextExtent: TSize;
  PageNum: integer;
  ACaption: string;
begin
  if (FThumbnails.FUpdateCount > 0) then Exit;
  if (FThumbnails.HighlightStyle = gmBackground) and (Selected) then
  begin
    Canvas.Pen.Color := clBlack;
    Canvas.Pen.Width := 1;
    Canvas.Brush.Color := FThumbnails.SelectedColor;
    with ClientRect do
      Canvas.Rectangle(Left, Top, Right, Bottom);
  end;
  DrawPage := not FThumbnails.PlainPages;
  inherited Paint;
  Canvas.Font.PixelsPerInch := SCREEN_PPI;
  SetMapMode(Canvas.Handle, MM_TEXT);
  SetWindowOrgEx(Canvas.Handle, Gutters.Left, Gutters.Top, nil);
  if FThumbnails.ShowCaption then
  begin
    PageNum := TGmPage(Page).PageNum;
    ACaption := ReplaceStringFields(FThumbnails.PageCaptions, '#', IntToStr(PageNum));
    Canvas.Font.Assign(FThumbnails.CaptionFont);
    TextExtent := Canvas.TextExtent(ACaption);
    Canvas.Brush.Style := bsClear;
    if Selected then Canvas.Font.Color := FThumbnails.SelectedColor;
    if (Canvas.Font.Color = FThumbnails.SelectedColor) and (FThumbnails.HighlightStyle = gmBackground) then
      Canvas.Font.Color := InvertColor(FThumbnails.SelectedColor);
    Canvas.TextOut((Width - TextExtent.cx) div 2 ,
                   (Height - (Gutters.Bottom)) + 4,
                   ACaption);
    Canvas.Pen.Mode := pmCopy;
  end;
  if (FThumbnails.HighlightStyle <> gmBackground) and (Selected) then
  begin
    Canvas.Pen.Color := FThumbnails.SelectedColor;
    if FThumbnails.HighlightStyle = gmThickLine then Canvas.Pen.Width := 2;
    Canvas.Brush.Style := bsClear;
    GmDrawRect(Canvas, PageRect);
  end;
end;

//------------------------------------------------------------------------------

// *** TGmThumbnails ***

constructor TGmThumbnails.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FThumbnailList := TGmObjectList.Create;
  FShadow := TGmShadow.Create;
  FCaptionFont := TFont.Create;
  FCaptions := '#';
  Width := 240;
  Height := 115;
  FGridWidth := 4;
  FLayout := gmThumbHorz;
  FPlainPages := False;
  FSelectedColor := clBlue;
  FThumbSize := 4;
  FThumbSpacing := 8;
  FShadow.Width := 2;
  FUpdateCount := 0;
  FHighlightStyle := gmThickLine;
  FHighlight := True;
  FScrollIntoView := True;
  FShowCaption := True;
  FCaptionFont.OnChange := FontChanged;
end;

destructor TGmThumbnails.Destroy;
begin
  if Assigned(FPreview) then FPreview.RemoveAssociatedComponent(Self);
  FThumbnailList.Free;
  FShadow.Free;
  FCaptionFont.Free;
  inherited Destroy;
end;

procedure TGmThumbnails.UpdateThumbnails;
begin
  DisableAutoRange;
  FThumbnailList.Clear;
  ResizeThumbList;
  RescaleThumbnails;
  RedrawThumbnails;
  EnableAutoRange;
  if Assigned(FPreview) then
  ItemIndex := FPreview.CurrentPageNum-1;
end;

procedure TGmThumbnails.GmBeginUpdate(var Message: TMessage);
begin
  Inc(FUpdateCount);
end;

procedure TGmThumbnails.GmEndUpdate(var Message: TMessage);
begin
  if FUpdateCount > 0 then Dec(FUpdateCount);
  if FUpdateCount = 0 then UpdateThumbnails;
end;

procedure TGmThumbnails.GmHeaderFooterChanged(var Message: TMessage);
begin
  Invalidate;
end;

procedure TGmThumbnails.GmNumPagesChanged(var Message: TMessage);
begin
  UpdateThumbnails;
end;

procedure TGmThumbnails.GmPageContentChanged(var Message: TMessage);
begin
  ItemIndex := -1;
  ItemIndex := FPreview.CurrentPageNum-1;
end;

procedure TGmThumbnails.GmPageNumChanged(var Message: TMessage);
begin
  ItemIndex := FPreview.CurrentPageNum-1;
end;

procedure TGmThumbnails.GmPaperSizeChanged(var Message: TMessage);
begin
  UpdateThumbnails;
end;

procedure TGmThumbnails.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then
  begin
    FThumbnailList.Clear;
    FPreview := nil;
  end;
end;

function TGmThumbnails.AddThumbnail: TGmThumbnail;
begin
  Result := TGmThumbnail.Create(Self);
  Result.Shadow := FShadow;
  Result.OnMouseDown := ThumbMouseDown;
  FThumbnailList.Add(Result);
end;

function TGmThumbnails.GetThumbnail(index: integer): TGmThumbnail;
begin
  if (index = -1) or (index > FThumbnailList.Count-1) then Result := nil
  else
    Result := TGmThumbnail(FThumbnailList[index]);
end;

procedure TGmThumbnails.Changed;
begin
  UpdateThumbnails;
end;

procedure TGmThumbnails.DeleteThumbnail;
begin
  FThumbnailList.Delete(FThumbnailList.Count-1);
end;

procedure TGmThumbnails.FontChanged(Sender: TObject);
begin
  UpdateThumbnails;
end;

procedure TGmThumbnails.SetCaptionFont(Value: TFont);
begin
  FCaptionFont.Assign(Value);
  UpdateThumbnails;
end;

procedure TGmThumbnails.SetCaptions(Value: string);
begin
  if FCaptions = Value then Exit;
  FCaptions := Value;
  Invalidate;
end;

procedure TGmThumbnails.SetGridWidth(Value: integer);
begin
  if FGridWidth < 0 then
  begin
    //ShowGmError(
  end;
  if FGridWidth = Value then Exit;
  FGridWidth := Value;
  RedrawThumbnails;
end;

procedure TGmThumbnails.SetHighlight(Value: Boolean);
begin
  if FHighlight = Value then Exit;
  FHighlight := Value;
  Invalidate;
end;

procedure TGmThumbnails.SetHighlightStyle(Value: TGmHighlightStyle);
begin
  if FHighlightStyle = Value then Exit;
  FHighlightStyle := Value;
  Invalidate;
end;

procedure TGmThumbnails.SetItemIndex(Value: integer);
begin
  if FItemIndex = Value then Exit;
  if Assigned(Thumbnail[FItemIndex]) then
    Thumbnail[FItemIndex].Selected := False;
  FItemIndex := Value;
  if Assigned(Thumbnail[FItemIndex]) then
    if FHighlight then Thumbnail[FItemIndex].Selected := True;

  if (Assigned(FPreview)) and (FScrollIntoView) then
  begin
    if Assigned(Thumbnail[FItemIndex]) then
      ScrollInView(Thumbnail[FItemIndex]);
  end;
end;

procedure TGmThumbnails.SetLayout(Value: TGmThumbNailLayout);
begin
  if FLayout = Value then Exit;
  FLayout := Value;
  RedrawThumbnails;
end;

procedure TGmThumbnails.SetPlainPages(Value: Boolean);
begin
  if FPlainPages = Value then Exit;
  FPlainPages := Value;
  Invalidate;
end;

procedure TGmThumbnails.ResizeThumbList;
begin
  if not Assigned(FPreview) then Exit;
  if FThumbnailList.Count = FPreview.NumPages then Exit;
  while FThumbnailList.Count < FPreview.NumPages do AddThumbnail;
  while FThumbnailList.Count > FPreview.NumPages do DeleteThumbnail;
  Repaginate;
end;

procedure TGmThumbnails.RescaleThumbnails;
var
  ICount: integer;
  TextHeight: Integer;
begin
  for ICount := 0 to FThumbnailList.Count-1 do
  begin
    with Thumbnail[ICount] do
    begin
      if FShowCaption then
        TextHeight := (0-FCaptionFont.Height)+4
      else
        TextHeight := 0;
      Gutters := Rect(FThumbSpacing, FThumbSpacing, FThumbSpacing, FThumbSpacing + TextHeight);
      Zoom := FThumbSize+2;
      Width := PageExtent[96].cx + (Gutters.Left + Gutters.Right);
      Height := PageExtent[96].cy + (Gutters.Top + Gutters.Bottom);
    end;
  end;
end;

procedure TGmThumbnails.RedrawThumbnails;
var
  ICount: integer;
  CurrentXY: TPoint;
begin
  CurrentXY := Point(0,0);
  for ICount := 0 to FThumbnailList.Count-1 do
  begin
    with Thumbnail[ICount] do
    begin
      Selected := Page = FPreview.CurrentPage;
      SetBounds(CurrentXY.X-HorzScrollBar.Position,
                CurrentXY.Y-VertScrollBar.Position,
                Width,
                Height);
      Parent := Self;
      if FLayout = gmThumbHorz then Inc(CurrentXY.X, Width-1)
      else
      if FLayout = gmThumbVert then Inc(CurrentXY.Y, Height-1)
      else
      begin
        if (ICount+1) mod FGridWidth = 0 then
        begin
          Inc(CurrentXY.Y, Height-1);
          CurrentXY.X := 0;
        end
        else
          Inc(CurrentXY.X, Width-1);
      end;
    end;
  end;
end;

procedure TGmThumbnails.Repaginate;
var
  ICount: integer;
begin
  for ICount := 0 to FThumbnailList.Count-1 do
    Thumbnail[ICount].Page := FPreview.Pages[ICount+1];
end;

procedure TGmThumbnails.SetPreview(APreview: TGmPreview);
begin
  if Assigned(FPreview) then
  begin
    FThumbnailList.Clear;
    FPreview.RemoveAssociatedComponent(Self);
  end;
  FPreview := APreview;
  if Assigned(FPreview) then
  begin
    FPreview.AddAssociatedComponent(Self);
    UpdateThumbnails;
  end;
end;

procedure TGmThumbnails.SetSelectedColor(Value: TColor);
begin
  if FSelectedColor = Value then Exit;
  FSelectedColor := Value;
  Invalidate;
end;

procedure TGmThumbnails.SetShadow(Value: TGmShadow);
begin
  FShadow.Assign(Value);
  Invalidate;
end;

procedure TGmThumbnails.SetShowCaption(Value: Boolean);
begin
  if FShowCaption = Value then Exit;
  FShowCaption := Value;
  UpdateThumbnails;
end;

procedure TGmThumbnails.SetThumbnail(index: integer;
  const Value: TGmThumbnail);
begin
  FThumbnailList[index] := Value;
end;

procedure TGmThumbnails.SetThumbPopup(Value: TPopupMenu);
var
  ICount: integer;
begin
  if FThumbPopup = Value then Exit;
  FThumbPopup := Value;
  for ICount := 0 to FThumbnailList.Count-1 do
    Thumbnail[ICount].PopupMenu := FThumbPopup;
end;

procedure TGmThumbnails.SetThumbSize(Value: integer);
begin
  if FThumbSize = Value then Exit;
  FThumbSize := Value;
  Changed;
end;

procedure TGmThumbnails.SetThumbSpacing(Value: integer);
begin
  if FThumbSpacing = Value then Exit;
  FThumbSpacing := Value;
  UpdateThumbnails;
end;

procedure TGmThumbnails.ThumbMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  LastItemIndex: integer;
begin
  if FUpdateCount > 0 then Exit;
  LastItemIndex := FThumbnailList.IndexOf(Sender);
  //if Assigned(FOnThumbMouseDown) then FOnThumbMouseDown(Self, Button, Shift, TGmPage(TGmThumbnail(Sender).Page));
  if FThumbnailList.IndexOf(Sender) <> -1 then
    ItemIndex := FThumbnailList.IndexOf(Sender)
  else
    ItemIndex := LastItemIndex;
  if Assigned(FPreview) then
    FPreview.CurrentPageNum := ItemIndex+1;
end;

end.
