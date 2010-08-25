{******************************************************************************}
{                                                                              }
{                            GmTreeViewPrint.pas                               }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmTreeViewPrint;

interface

uses
  Windows, Messages, SysUtils, Classes, ComCtrls, Forms, GmPreview, Graphics,
  GmTypes, GmClasses;

{$I GMPS.INC}

type
  TGmNewPageEvent       = procedure (Sender: TObject; var ATopMargin, ABottomMargin: TGmValue) of object;

  TGmTreeViewPrint = class(TGmComponent)
  private
    FCurrentXY: TGmPoint;
    FExpandNodes: Boolean;
    FFont: TFont;
    FIndent: TGmValue;
    FItemHeight: TGmValue;
    FMarginBottom: TGmValue;
    FMarginTop: TGmValue;
    FPen: TPen;
    FPreview: TGmPreview;
    FShowImages: Boolean;
    FStartXY: TGmPoint;
    FTreeView: TTreeView;
    // events...
    FOnNewPage: TGmNewPageEvent;
    function GetCutOffInch: Extended;
    function GetNodeRect(ANode: TTreeNode): TGmRect;
    function GetNumLevels(ATreeView: TTreeView): integer;
    procedure DrawOpenPipes(Index: integer; OpenPipes: array of Boolean);
    procedure SetFont(Value: TFont);
    procedure SetIndent(Value: TGmValue);
    procedure SetItemHeight(Value: TGmValue);
    procedure SetMarginBottom(Value: TGmValue);
    procedure SetMarginTop(Value: TGmValue);
    procedure SetPen(Value: TPen);
    procedure SetPreview(Value: TGmPreview);
    { Private declarations }
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure TreeViewToPage(x, y: Extended; Measurement: TGmMeasurement);
    property BottomMargin: TGmValue read FMarginBottom write SetMarginBottom;
    property Indent: TGmValue read FIndent write SetIndent;
    property ItemHeight: TGmValue read FItemHeight write SetItemHeight;
    property TopMargin: TGmValue read FMarginTop write SetMarginTop;
    { Public declarations }
  published
    property ExpandNodes: Boolean read FExpandNodes write FExpandNodes default False;
    property Font: TFont read FFont write SetFont;
    property Preview: TGmPreview read FPreview write SetPreview;
    property LinePen: TPen read FPen write SetPen;
    property ShowImages: Boolean read FShowImages write FShowImages default True;
    property TreeView: TTreeView read FTreeView write FTreeView;
    // events...
    property OnNewPage: TGmNewPageEvent read FOnNewPage write FOnNewPage;
    { Published declarations }
  end;

implementation

uses GmConst, GmErrors, GmFuncs, GmCanvas;

constructor TGmTreeViewPrint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMarginBottom := TGmValue.Create;
  FMarginTop := TGmValue.Create;
  FItemHeight := TGmValue.CreateValue(8, gmMillimeters);
  FIndent := TGmValue.CreateValue(8, gmMillimeters);
  FPen := TPen.Create;
  FPen.Color := clGray;
  FFont := TFont.Create;
  FFont.Name := DEFAULT_FONT;
  FFont.Size := DEFAULT_FONT_SIZE;
  FExpandNodes := False;
  FShowImages := True;
end;

destructor TGmTreeViewPrint.Destroy;
begin
  FItemHeight.Free;
  FIndent.Free;
  FMarginBottom.Free;
  FMarginTop.Free;
  FFont.Free;
  FPen.Free;
  inherited Destroy;
end;



procedure TGmTreeViewPrint.TreeViewToPage(x, y: Extended; Measurement: TGmMeasurement);
var
  ARect: TGmRect;
  ATextRect: TGmRect;
  ANode: TTreeNode;
  ICount: integer;
  Ih: Extended;
  Ind: Extended;
  OpenPipes: array of Boolean;
  ImgW: Extended;
  ImgH: Extended;
  ABitmap: TBitmap;
  Th: Extended;
begin
  FCurrentXY.X := ConvertValue(x, Measurement, gmInches);
  FCurrentXY.Y := ConvertValue(y, Measurement, gmInches);
  FStartXY := FCurrentXY;
  FMarginTop.AsGmValue[gmInches] := FStartXY.Y;
  Ih := FItemHeight.AsInches;
  Ind := FIndent.AsInches;
  SetLength(OpenPipes, GetNumLevels(FTreeView)+1);
  for ICount := 0 to High(OpenPipes) do
    OpenPipes[ICount] := False;
  ANode := FTreeView.Items.GetFirstNode;
  while ANode <> nil do
  begin
    OpenPipes[ANode.Level] := (ANode.GetNextSibling <> nil);
    DrawOpenPipes(ANode.AbsoluteIndex, OpenPipes);
    ARect := GetNodeRect(ANode);
    with FPreview.Canvas do
    begin
      Font.Assign(FFont);
      Pen.Assign(FPen);
      MoveTo(ARect.Left, ARect.Top + (Ih/2), gmInches);
      LineTo(ARect.Left-(Ind/2), ARect.Top + (Ih/2), gmInches);
      if ANode.GetNextSibling = nil then
        LineTo(ARect.Left-(Ind/2), ARect.Top, gmInches);
      ImgW := 0;

      if (Assigned(FTreeView.Images)) and (FShowImages) then
      begin
        ImgW := (FTreeView.Images.Width / 96)+0.05;
        ImgH := (FTreeView.Images.Height / 96);
        ABitmap := TBitmap.Create;
        try
          FTreeView.Images.GetBitmap(ANode.ImageIndex, ABitmap);
          Draw(ARect.Left+0.05, ARect.Top+((GmRectHeight(ARect)-ImgH)/2), ABitmap, 1, gmInches);
        finally
          ABitmap.Free;
        end;
      end;
      
      ATextRect := ARect;
      Th := FPreview.Canvas.TextHeight(' ').AsInches+0.05;
      ATextRect.Bottom := ATextRect.Top + Th;
      OffsetGmRect(ATextRect, 0, (GmRectHeight(ARect)-Th)/2);
      Pen.Style := psClear;
      TextBoxExt(ATextRect.Left+ImgW+0.05, ATextRect.Top, ATextRect.Right+ImgW+0.05, ATextRect.Bottom, 0.025, ANode.Text, taLeftJustify, gmMiddle, gmInches);
    end;
    FCurrentXY.Y := FCurrentXY.Y + FItemHeight.AsInches;
    if FCurrentXY.Y + Ih > GetCutOffInch then
    begin
      if Assigned(FOnNewPage) then FOnNewPage(Self, FMarginTop, FMarginBottom);
      FCurrentXY.X := FStartXY.X;
      FCurrentXY.Y := FMarginTop.AsInches;
      FPreview.NewPage;
    end;
    if FExpandNodes then
      ANode := ANode.GetNext
    else
      ANode := ANode.GetNextVisible;
  end;
end;

function TGmTreeViewPrint.GetCutOffInch: Extended;
var
  AsInches: TGmSize;
begin
  AsInches := FPreview.GetPageSize(gmInches);
  Result := AsInches.Height - (FMarginBottom.AsInches + FPreview.Footer.Height[gmInches]);
end;

function TGmTreeViewPrint.GetNodeRect(ANode: TTreeNode): TGmRect;
begin
  Result.Left  := FStartXY.X + (ANode.Level * FIndent.AsInches);
  Result.Top   := FCurrentXY.Y;
  Result.Right := Result.Left + FPreview.Canvas.TextWidth(ANode.Text).AsInches+0.1;
  Result.Bottom := Result.Top + FItemHeight.AsInches;
  OffsetGmRect(Result, FIndent.AsInches/2, 0);
end;

function TGmTreeViewPrint.GetNumLevels(ATreeView: TTreeView): integer;
var
  CurrentLevel: integer;
  ANode: TTreeNode;
begin
  Result := 0;
  ANode := ATreeView.Items.GetFirstNode;
  while ANode <> nil do
  begin
    CurrentLevel := ANode.Level;
    if CurrentLevel > Result then Result := CurrentLevel;
    if FExpandNodes then
      ANode := ANode.GetNext
    else
      ANode := ANode.GetNextVisible;
  end;
end;

procedure TGmTreeViewPrint.DrawOpenPipes(Index: integer; OpenPipes: array of Boolean);
var
  ICount: integer;
  Ih,
  Ind: Extended;
begin
  Ih  := FItemHeight.AsInches;
  Ind := FIndent.AsInches;
  FPreview.Canvas.Pen.Assign(FPen);
  for ICount := 0 to High(OpenPipes) do
  begin
    if OpenPipes[ICount] = True then
    begin
      if Index = 0 then
        FPreview.Canvas.MoveTo(FCurrentXY.X + (ICount * Ind), FCurrentXY.Y + (Ih/2), gmInches)
      else
        FPreview.Canvas.MoveTo(FCurrentXY.X + (ICount * Ind), FCurrentXY.Y, gmInches);
      FPreview.Canvas.LineTo(FCurrentXY.X + (ICount * Ind), FCurrentXY.Y+Ih+0.05, gmInches);
    end;
  end;
end;

procedure TGmTreeViewPrint.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TGmTreeViewPrint.SetIndent(Value: TGmValue);
begin
  FIndent.Assign(Value);
end;

procedure TGmTreeViewPrint.SetItemHeight(Value: TGmValue);
begin
  FItemHeight.Assign(Value);
end;

procedure TGmTreeViewPrint.SetMarginBottom(Value: TGmValue);
begin
  FMarginBottom.Assign(Value);
end;

procedure TGmTreeViewPrint.SetMarginTop(Value: TGmValue);
begin
  FMarginTop.Assign(Value);
end;

procedure TGmTreeViewPrint.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TGmTreeViewPrint.SetPreview(Value: TGmPreview);
begin
  FPreview := Value;
  if Assigned(FPreview) then
    FMarginBottom.AsInches := (FPreview.Footer.Height[gmInches] + FPreview.Margins.Bottom.AsInches);
end;

procedure TGmTreeViewPrint.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then FPreview := nil;
  if (Operation = opRemove) and (AComponent = FTreeView) then FTreeView := nil;
end;

end.
