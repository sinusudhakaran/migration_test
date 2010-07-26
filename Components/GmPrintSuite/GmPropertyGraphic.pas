{******************************************************************************}
{                                                                              }
{                           GmPropertyGraphic.pas                              }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmPropertyGraphic;

interface

uses Windows, Classes, Controls, Graphics, Messages, GmClasses, GmPreview, StdCtrls,
  Buttons, GmTypes, GmConst;

const
  BUTTON_SIZE = 23;
  RES_NAME: array[1..5] of string = ('Portrait',
                                     'Landscape',
                                     'OnePage',
                                     'TwoPage',
                                     'FourPage');
type
  TGmGraphicPropertyType = (gmMultipageGraphic, gmOrientationGraphic);


  // *** TGmPropertyGraphic ***

  TGmPropertyGraphic = class(TGmWinControl)
  private
    FBitmaps: array[1..5] of TBitmap;
    FButtons: array[1..3] of TSpeedButton;
    FButtonSpacing: integer;
    FOrientation: TGmOrientation;
    FPagesPerSheet: TGmPagesPerSheet;
    FPaperImage: TGmPaperImage;
    FPreview: TGmPreview;
    FPropertyType: TGmGraphicPropertyType;
    FShadow: TGmShadow;
    FShowButtons: Boolean;
    procedure ButtonClicked(Sender: TObject);
    procedure PaintPage(Sender: TObject);
    procedure SetButtonSpacing(Value: integer);
    procedure SetOrientation(Value: TGmOrientation; const UpdatePreview: Boolean = False);
    procedure SetPagesPerSheet(Value: TGmPagesPerSheet; const UpdatePreview: Boolean = False);
    procedure SetPreview(Value: TGmPreview);
    procedure SetPropertyType(Value: TGmGraphicPropertyType);
    procedure SetShadow(Value: TGmShadow);
    procedure SetShowButtons(Value: Boolean);
    procedure UpdateButtons;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure PaperSizeChanged(var Message: TMessage); message GM_ORIENTATION_CHANGED;
    procedure PagesPerSheetChanged(var Message: TMessage); message GM_MULTIPAGE_CHANGED;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ButtonSpacing: integer read FButtonSpacing write SetButtonSpacing default 8;
    property Preview: TGmPreview read FPreview write SetPreview;
    property PreviewProperty: TGmGraphicPropertyType read FPropertyType write SetPropertyType default gmOrientationGraphic;
    property Shadow: TGmShadow read FShadow write SetShadow;
    property ShowButtons: Boolean read FShowButtons write SetShowButtons default True;
  end;

implementation

uses GmFuncs, SysUtils;

{$R PropertyGraphicRes.RES}

//------------------------------------------------------------------------------

// *** TGmPropertyGraphic ***

constructor TGmPropertyGraphic.Create(AOwner: TComponent);
var
  ICount: integer;
begin
  inherited Create(AOwner);
  Width := 137;
  Height := 105;
  DoubleBuffered := True;
  FShadow := TGmShadow.Create;
  FPaperImage := TGmPaperImage.Create(Self);
  FPaperImage.Align := alClient;
  FPaperImage.Shadow := FShadow;
  FPaperImage.Gutters := Rect(26,0,0,0);
  FPaperImage.PaperSizeInch := GmSize(8.26, 11.69);
  FPaperImage.Zoom := 6;
  FPaperImage.OnPaintPage := PaintPage;
  FPaperImage.Parent := Self;
  for ICount := 1 to 3 do
  begin
    FButtons[ICount] := TSpeedButton.Create(Self);
    FButtons[ICount].GroupIndex := 1;
    FButtons[ICount].Tag := ICount;
    FButtons[ICount].OnClick := ButtonClicked;
  end;
  for ICount := 1 to 5 do
  begin
    FBitmaps[ICount] := TBitmap.Create;
    FBitmaps[ICount].LoadFromResourceName(HInstance, RES_NAME[ICount]);
  end;
  FButtons[1].Down := True;
  FShadow.Width := 2;
  FButtonSpacing := 8;
  FPropertyType := gmOrientationGraphic;
  FShowButtons := True;
  FOrientation := gmPortrait;
  FPagesPerSheet := gmOnePage;
  UpdateButtons;
end;

destructor TGmPropertyGraphic.Destroy;
var
  ICount: integer;
begin
  if Assigned(FPreview) then FPreview.RemoveAssociatedComponent(Self);
  FPaperImage.Free;
  FShadow.Free;
  for ICount := 1 to 3 do
    FButtons[ICount].Free;
  for ICount := 1 to 5 do
    FBitmaps[ICount].Free;
  inherited Destroy;
end;

procedure TGmPropertyGraphic.ButtonClicked(Sender: TObject);
var
  Index: integer;

begin
  Index := TSpeedButton(Sender).Tag;
  if FPropertyType = gmOrientationGraphic then
  begin
    case Index of
      1: SetOrientation(gmPortrait, True);
      2: SetOrientation(gmLandscape, True);
    end;
  end;
  if FPropertyType = gmMultipageGraphic then
  begin
    case Index of
      1: SetPagesPerSheet(gmOnePage);
      2: SetPagesPerSheet(gmTwoPage);
      3: SetPagesPerSheet(gmFourPage);
    end;
  end;
end;

procedure TGmPropertyGraphic.PaintPage(Sender: TObject);
var
  PageRect: TRect;
  SubRects: array[1..8] of TRect;
  ICount, PW, PH: integer;
  s: string;
begin
  PageRect := FPaperImage.PageRect;
  with FPaperImage.Canvas do
  begin
    Font.Color := clSilver;
    Font.Name := DEFAULT_FONT;
    if FPropertyType = gmOrientationGraphic then
    begin
      Font.Size := 18;
      if FOrientation = gmPortrait then s := 'P' else s := 'L';
      DrawText(Handle, PChar(s), Length(s), PageRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    end;
    if FPropertyType = gmMultipageGraphic then
    begin
      // calculate pare areas...
      PW := RectWidth(PageRect);
      PH := RectHeight(PageRect);
      SubRects[1] := Rect(0, 0, PW, PH div 2);
      SubRects[2] := Rect(0, PH div 2, PW, PH);
      SubRects[3] := Rect(0, 0, PW div 2, PH);
      SubRects[4] := Rect(PW div 2, 0, PW, PH);
      SubRects[5] := Rect(0, 0, PW div 2, PH div 2);
      SubRects[6] := Rect(PW div 2, 0, PW, PH div 2);
      SubRects[7] := Rect(0, PH div 2, PW div 2, PH);
      SubRects[8] := Rect(PW div 2, PH div 2, PW, PH);
      for ICount := 1 to 8 do
        OffsetRect(SubRects[ICount], PageRect.Left+1, PageRect.Top+1);
      Pen.Color := clSilver;
      case FPagesPerSheet of
        gmOnePage:
        begin
          Font.Size := 16;
          S := '1';
          DrawText(Handle, PChar(s), Length(s), PageRect, DT_CENTER or DT_VCENTER or DT_SINGLELINE);
        end;
        gmTwoPage:
        begin
          Font.Size := 12;
          case FOrientation of
            gmPortrait:
            begin
              MoveTo(PageRect.Left+1, PageRect.Top + (RectHeight(PageRect) div 2));
              LineTo(PageRect.Right, PageRect.Top + (RectHeight(PageRect) div 2));
              for ICount := 1 to 2 do
                DrawText(Handle, PChar(IntToStr(ICount)), 1, SubRects[ICount], DT_CENTER or DT_VCENTER or DT_SINGLELINE);
            end;
            gmLandscape:
            begin
              MoveTo(PageRect.Left + (RectWidth(PageRect) div 2), PageRect.Top+1);
              LineTo(PageRect.Left + (RectWidth(PageRect) div 2), PageRect.Bottom);
              for ICount := 3 to 4 do
                DrawText(Handle, PChar(IntToStr(ICount-2)), 1, SubRects[ICount], DT_CENTER or DT_VCENTER or DT_SINGLELINE);
            end;
          end;
        end;
        gmFourPage:
        begin
          Font.Size := 10;
          MoveTo(PageRect.Left+1, PageRect.Top + (RectHeight(PageRect) div 2));
          LineTo(PageRect.Right, PageRect.Top + (RectHeight(PageRect) div 2));
          MoveTo(PageRect.Left + (RectWidth(PageRect) div 2), PageRect.Top+1);
          LineTo(PageRect.Left + (RectWidth(PageRect) div 2), PageRect.Bottom);
          for ICount := 5 to 8 do
            DrawText(Handle, PChar(IntToStr(ICount-4)), 1, SubRects[ICount], DT_CENTER or DT_VCENTER or DT_SINGLELINE);
        end;
      end;
    end;
  end;
end;

procedure TGmPropertyGraphic.SetButtonSpacing(Value: integer);
begin
  if FButtonSpacing = Value then Exit;
  FButtonSpacing := Value;
  UpdateButtons;
end;

procedure TGmPropertyGraphic.SetOrientation(Value: TGmOrientation; const UpdatePreview: Boolean = False);
var
  PW, PH: Extended;
begin
  FOrientation := Value;
  if FPropertyType = gmOrientationGraphic then
  begin
    case FOrientation of
      gmPortrait: FButtons[1].Down := True;
      gmLandscape: FButtons[2].Down := True;
    end;
  end;

  if (FPagesPerSheet = gmTwoPage) and (FPropertyType = gmMultipageGraphic) then
  begin
    case FOrientation of
      gmPortrait: FOrientation := gmLandscape;
      gmLandscape: FOrientation := gmPortrait;
    end;
  end;
  PW := FPaperImage.PaperSizeInch.Width;
  PH := FPaperImage.PaperSizeInch.Height;
  case FOrientation of
    gmPortrait : FPaperImage.PaperSizeInch := GmSize(MinFloat(PW, PH), MaxFloat(PW, PH));
    gmLandscape: FPaperImage.PaperSizeInch := GmSize(MaxFloat(PW, PH), MinFloat(PW, PH));
  end;
  if (Assigned(FPreview)) and (UpdatePreview) then FPreview.Orientation := FOrientation;
  Invalidate;
end;

procedure TGmPropertyGraphic.SetPagesPerSheet(Value: TGmPagesPerSheet; const UpdatePreview: Boolean = False);
begin
  if FPagesPerSheet = Value then Exit;
  FPagesPerSheet := Value;
  if FPropertyType = gmMultiPageGraphic then
  begin
    case FPagesPerSheet of
      gmOnePage: FButtons[1].Down := True;
      gmTwoPage: FButtons[2].Down := True;
      gmFourPage: FButtons[3].Down := True;
    end;
  end;
  if Assigned(FPreview) then
    FOrientation := FPreview.Orientation
  else
    FOrientation := gmPortrait;
  SetOrientation(FOrientation);
  if Assigned(FPreview) then FPreview.PagesPerSheet := FPagesPerSheet;
  Invalidate;
end;

procedure TGmPropertyGraphic.SetPreview(Value: TGmPreview);
begin
  if Assigned(FPreview) then FPreview.RemoveAssociatedComponent(Self);
  FPreview := Value;
  if Assigned(FPreview) then
  begin
    FPreview.AddAssociatedComponent(Self);
    SetOrientation(FPreview.Orientation);
    SetPagesPerSheet(FPreview.PagesPerSheet);
  end;
end;

procedure TGmPropertyGraphic.SetPropertyType(Value: TGmGraphicPropertyType);
begin
  if FPropertyType = Value then Exit;
  FPropertyType := Value;
  UpdateButtons;
end;

procedure TGmPropertyGraphic.SetShadow(Value: TGmShadow);
begin
  FShadow.Assign(Value);
  Invalidate;
end;

procedure TGmPropertyGraphic.SetShowButtons(Value: Boolean);
var
  ICount: integer;
begin
  if FShowButtons = Value then Exit;
  FShowButtons := Value;
  for ICount := 1 to 3 do
    FButtons[ICount].Parent := nil;
  if Value then
    FPaperImage.Gutters := Rect(30,0,0,0)
  else
    FPaperImage.Gutters := Rect(0, 0, 0, 0);
  Realign;
  UpdateButtons;
end;

procedure TGmPropertyGraphic.UpdateButtons;
var
  ICount: integer;
  ButtonRect: TRect;
  TopLeft: TPoint;
begin
  if not FShowButtons then Exit;
  for ICount := 1 to 3 do
    FButtons[ICount].Parent := nil;
  if FPropertyType = gmMultipageGraphic then
  begin
    for ICount := 1 to 3 do
      FButtons[ICount].Glyph := FBitmaps[ICount+2];
    // multipage graphic...
    ButtonRect := Rect(0, 0, BUTTON_SIZE, (BUTTON_SIZE*3) + (2 * FButtonSpacing));
    TopLeft.X := 8;
    TopLeft.Y := (Height - RectHeight(ButtonRect)) div 2;
    for ICount := 0 to 2 do
    begin
      FButtons[ICount+1].Left := TopLeft.X;
      FButtons[ICount+1].Top  := TopLeft.Y + (ICount * (BUTTON_SIZE+FButtonSpacing));
      FButtons[ICount+1].Parent := Self;
    end;
  end
  else
  begin
    // orientation graphic...
    for ICount := 1 to 2 do
      FButtons[ICount].Glyph := FBitmaps[ICount];
    ButtonRect := Rect(0, 0, BUTTON_SIZE, (BUTTON_SIZE*2) + (1 * FButtonSpacing));
    TopLeft.X := 8;
    TopLeft.Y := (Height - RectHeight(ButtonRect)) div 2;
    for ICount := 0 to 1 do
    begin
      FButtons[ICount+1].Left := TopLeft.X;
      FButtons[ICount+1].Top  := TopLeft.Y + (ICount * (BUTTON_SIZE+FButtonSpacing));
      FButtons[ICount+1].Parent := Self;
    end;
  end;
  Invalidate;
end;

procedure TGmPropertyGraphic.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then
  begin
    FPreview := nil;
  end;
end;

procedure TGmPropertyGraphic.PaperSizeChanged(var Message: TMessage);
begin
  SetOrientation(FPreview.Orientation);
end;

procedure TGmPropertyGraphic.PagesPerSheetChanged(var Message: TMessage);
begin
  SetPagesPerSheet(FPreview.PagesPerSheet);
end;

procedure TGmPropertyGraphic.WMSize(var Message: TMessage);
begin
  inherited;
  UpdateButtons;
end;

end.
