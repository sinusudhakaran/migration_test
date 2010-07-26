{******************************************************************************}
{                                                                              }
{                               GmPageList.pas                                 }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmPageList;

interface

uses Windows, Classes, Controls, Graphics, GmClasses, GmTypes, GmCanvas,
  GmPrinter, GmResource, StdCtrls;

type
  TGmHeaderFooter = class;

  TGmScrollingPageControl = class(TGmCanvasWinControl);

  TGmPageList = class;

  TGmBeforeLoadEvent       = procedure(Sender: TObject; FileVersion: Extended; var LoadFile: Boolean) of object;
  TGmObjectMouseEvent      = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: TGmValue; AGmObject: TGmVisibleObject) of object;
  TGmPrintProgressEvent    = procedure(Sender: TObject; Printed, Total: integer) of object;

  //----------------------------------------------------------------------------

  // *** TGmHeaderFooterCaption ***

  TGmHeaderFooterCaption = class(TPersistent)
  private
    FCaption: string;
    FFont: TFont;
    FHeaderFooter: TGmHeaderFooter;
    // events...
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure DrawToCanvas(ACanvas: TCanvas; ARect: TRect; PpiX, PpiY: integer; AAlign: TGmCaptionAlign; PageNum, NumPages: integer);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure SetCaption(Value: string);
    procedure SetFont(Value: TFont);
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(AHeaderFooter: TGmHeaderFooter; const ChangeEvent: TNotifyEvent = nil);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Caption: string read FCaption write SetCaption;
    property Font: TFont read FFont write SetFont;
  end;
  //----------------------------------------------------------------------------

  // *** TGmHeaderFooter ***

  TGmHeaderFooter = class(TPersistent)
  private
    FCaptions: array[gmLeft..gmRight] of TGmHeaderFooterCaption;
    FHeight: TGmValue;
    FPen: TPen;
    FShowLine: Boolean;
    FVisible: Boolean;
    // events...
    FOnChange: TNotifyEvent;
    function GetCaptionIndex(index: integer): TGmHeaderFooterCaption;
    function GetHeight(Measurement: TGmMeasurement): Extended;
    function GetLargestFont: TFont;
    procedure Changed(Sender: TObject);
    procedure DrawToCanvas(ACanvas: TCanvas; AMargins: TGmMargins; APageSize: TGmSize;
      PpiX, PpiY: integer; Page, NumPages: integer); virtual; abstract;
    procedure SetCaptionIndex(index: integer; Value: TGmHeaderFooterCaption);
    procedure SetHeight(Measurement: TGmMeasurement; Value: Extended);
    procedure SetPen(Value: TPen);
    procedure SetShowLine(Value: Boolean);
    procedure SetVisible(Value: Boolean);
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create(const ChangeEvent: TNotifyEvent = nil);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Height[Measurement: TGmMeasurement]: Extended read GetHeight write SetHeight;
  published
    property CaptionLeft: TGmHeaderFooterCaption index 0 read GetCaptionIndex write SetCaptionIndex;
    property CaptionCenter: TGmHeaderFooterCaption index 1 read GetCaptionIndex write SetCaptionIndex;
    property CaptionRight: TGmHeaderFooterCaption index 2 read GetCaptionIndex write SetCaptionIndex;
    property Pen: TPen read FPen write SetPen;
    property ShowLine: Boolean read FShowLine write SetShowLine default True;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  //----------------------------------------------------------------------------

  // *** TGmHeader ***

  TGmHeader = class(TGmHeaderFooter)
  public
    procedure DrawToCanvas(ACanvas: TCanvas; AMargins: TGmMargins; APageSize: TGmSize;
      PpiX, PpiY: integer; Page, NumPages: integer); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmFooter ***

  TGmFooter = class(TGmHeaderFooter)
  public
    procedure DrawToCanvas(ACanvas: TCanvas; AMargins: TGmMargins; APageSize: TGmSize;
      PpiX, PpiY: integer; Page, NumPages: integer); override;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPage ***

  TGmPage = class(TObject)
  private
    FObjects: TGmBaseObjectList;
    FOrientation: TGmOrientation;
    FPageList: TGmPageList;
    FPageSizeInch: TGmSize;
    FRtfInfo: TGmPageRtfInfo;
    FShowFooter: Boolean;
    FShowHeader: Boolean;
    // events...
    FOnChange: TNotifyEvent;
    FOnChangeOrientation: TNotifyEvent;
    function AddObject(AObject: TGmBaseObject): TGmBaseObject;
    function CreateGmObject(ObjectID: integer): TGmBaseObject;
    function GetCount: integer;
    function GetGmObject(index: integer): TGmBaseObject;
    function GetPageNum: integer;
    function GetPageSize(Measurement: TGmMeasurement): TGmSize;
    procedure Changed(Sender: TObject);
    procedure DrawRichText(ACanvas: TCanvas; PpiX, PpiY: integer; WrapRichText: Boolean);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure SetOrientation(Value: TGmOrientation);
    procedure SetPageSize(AWidth, AHeight: Extended);
    procedure SetShowFooter(Value: Boolean);
    procedure SetShowHeader(Value: Boolean);
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChangeOrientation: TNotifyEvent read FOnChangeOrientation write FOnChangeOrientation;
  public
    constructor Create(APageList: TGmPageList);
    destructor Destroy; override;
    function ObjectAtPos(x, y: Extended; Measurement: TGmMeasurement; var AObject: TGmVisibleObject): Boolean;
    procedure Clear;
    procedure DeleteGmObject(AObject: TGmBaseObject);
    procedure DeleteLastGmObject;
    procedure DrawToCanvas(ACanvas: TCanvas; PpiX, PpiY: integer; FastDraw: Boolean);
    property Count: integer read GetCount;
    property GmObject[index: integer]: TGmBaseObject read GetGmObject;
    property Orientation: TGmOrientation read FOrientation write SetOrientation default gmPortrait;
    property PageNum: integer read GetPageNum;
    property PageSize[Measurement: TGmMeasurement]: TGmSize read GetPageSize;
    property RtfInfo: TGmPageRtfInfo read FRtfInfo write FRtfInfo;
    property ShowFooter: Boolean read FShowFooter write SetShowFooter default True;
    property ShowHeader: Boolean read FShowHeader write SetShowHeader default True;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPageList ***

  TGmPageList = class(TGmObjectList)
  private
    FCanvas: TGmCanvas;
    FCurrentPage: integer;
    FFooter: TGmFooter;
    FHeader: TGmHeader;
    FMargins: TGmMargins;
    FOrientation: TGmOrientation;
    FPagesPerSheet: TGmPagesPerSheet;
    FPaperSize: TGmPaperSize;
    FPaperSizeInch: TGmSize;
    FPrinter: TGmPrinter;
    FResourceTable: TGmResourceTable;
    FUpdateCount: integer;
    FValueRect: TGmValueRect;
    FValueSize: TGmValueSize;
    // events...
    FBeforeLoad: TGmBeforeLoadEvent;
    FOnClear: TNotifyEvent;
    FOnHeaderFooterChanged: TNotifyEvent;
    FOnNeedRichEdit: TGmNeedRichEditEvent;
    FOnNewPage: TNotifyEvent;
    FOnOrientationChanged: TNotifyEvent;
    FOnPageChanged: TNotifyEvent;
    FOnPageMarginsChanged: TNotifyEvent;
    FOnPageNumChanging: TNotifyEvent;
    FOnPageCountChanged: TNotifyEvent;
    FOnPageNumChanged: TNotifyEvent;
    FOnPaperSizeChanged: TNotifyEvent;
    FOnPrintProgress: TGmPrintProgressEvent;
    function GetPage(index: integer): TGmPage;
    function GetUpdating: Boolean;
    procedure ChangeObjectLevel(Sender: TObject; LevelChange: TGmArrangeObject);
    procedure DoPrintProgress(Printed, Total: integer);
    procedure InitPaperSize;
    procedure HeaderFooterChanged(Sender: TObject);
    procedure PageChanged(Sender: TObject);
    procedure PageCountChanged(Sender: TObject);
    procedure PageMarginsChanged(Sender: TObject);
    //procedure PageSizeChanged(Sender: TObject);
    procedure SetCurrentPage(Value: integer);
    procedure SetOrientation(Value: TGmOrientation);
    procedure SetPage(index: integer; APage: TGmPage);
    procedure SetPaperSize(Value: TGmPaperSize);
  public
    constructor Create;
    destructor Destroy; override;
    function AddObject(AObject: TGmBaseObject; AOrigin: TGmCoordsRelative): TGmBaseObject;
    function AddPage: TGmPage;
    function InsertPage(index: integer): TGmPage;
    function AvailablePageRect: TGmValueRect;
    function FooterRect: TGmValueRect;
    function HeaderRect: TGmValueRect;
    procedure BeginUpdate;
    procedure ClearPages(const FreeAll: Boolean = False; const FreeResources: Boolean = True);
    procedure DeletePage(index: integer);
    procedure EndUpdate;
    procedure FindText(AText: string; CaseSensative: Boolean; AList: TList);
    procedure LoadFromStream(Stream: TStream);
    procedure NeedRichEdit(Sender: TObject; var ARichEdit: TCustomMemo);
    procedure Print;
    procedure PrintPages(Pages: array of integer);
    procedure PrintRange(AFromPage, AToPage: integer);
    procedure PrintToFile(AFileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SetPageSize(AWidth, AHeight: Extended; Measurement: TGmMeasurement);
    procedure UsePrinterPageSize;
    property Canvas: TGmCanvas read FCanvas;
    property CurrentPage: integer read FCurrentPage write SetCurrentPage;
    property Footer: TGmFooter read FFooter;
    property GmPrinter: TGmPrinter read FPrinter write FPrinter;
    property Header: TGmHeader read FHeader;
    property Margins: TGmMargins read FMargins write FMargins;
    property Orientation: TGmOrientation read FOrientation write SetOrientation default gmPortrait;
    property Page[index: integer]: TGmPage read GetPage write SetPage; default;
    property PagesPerSheet: TGmPagesPerSheet read FPagesPerSheet write FPagesPerSheet default gmOnePage;
    property PageSizeInch: TGmSize read FPaperSizeInch;
    property PaperSize: TGmPaperSize read FPaperSize write SetPaperSize default A4;
    property ResourceTable: TGmResourceTable read FResourceTable;
    property Updating: Boolean read GetUpdating;
    // event...
    property BeforeLoad: TGmBeforeLoadEvent read FBeforeLoad write FBeforeLoad;
    property OnClear: TNotifyEvent read FOnClear write FOnClear;
    property OnHeaderFooterChanged: TNotifyEvent read FOnHeaderFooterChanged write FOnHeaderFooterChanged;
    property OnNeedRichEdit: TGmNeedRichEditEvent read FOnNeedRichEdit write FOnNeedRichEdit;
    property OnNewPage: TNotifyEvent read FOnNewPage write FOnNewPage;
    property OnOrientationChanged: TNotifyEvent read FOnOrientationChanged write FOnOrientationChanged;
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;
    property OnPageNumChanging: TNotifyEvent read FOnPageNumChanging write FOnPageNumChanging;
    property OnPageNumChanged: TNotifyEvent read FOnPageNumChanged write FOnPageNumChanged;
    property OnPageCountChanged: TNotifyEvent read FOnPageCountChanged write FOnPageCountChanged;
    property OnPageMarginsChanged: TNotifyEvent read FOnPageMarginsChanged write FOnPageMarginsChanged;
    property OnPaperSizeChanged: TNotifyEvent read FOnPaperSizeChanged write FOnPaperSizeChanged;
    property OnPrintProgress: TGmPrintProgressEvent read FOnPrintProgress write FOnPrintProgress;
  end;

implementation

uses GmFuncs, GmObjects, SysUtils, GmConst, GmStream, RichEdit, Math, Forms;

//------------------------------------------------------------------------------

// *** TGmHeaderFooterCaption ***

constructor TGmHeaderFooterCaption.Create(AHeaderFooter: TGmHeaderFooter; const ChangeEvent: TNotifyEvent = nil);
begin
  inherited Create;
  FHeaderFooter := AHeaderFooter;
  FFont := TFont.Create;
  FFont.Size := 12;
  FFont.Name := 'Arial';
  FFont.OnChange := ChangeEvent;
  OnChange := ChangeEvent;
end;

destructor TGmHeaderFooterCaption.Destroy;
begin
  FFont.Free;
  inherited Destroy;
end;

procedure TGmHeaderFooterCaption.Assign(Source: TPersistent);
begin
  if (Source is TGmHeaderFooterCaption) then
  begin
    FCaption := (Source as TGmHeaderFooterCaption).Caption;
    FFont.Assign((Source as TGmHeaderFooterCaption).Font);
  end
  else
    inherited Assign(Source);
end;

procedure TGmHeaderFooterCaption.DrawToCanvas(ACanvas: TCanvas; ARect: TRect; PpiX, PpiY: integer; AAlign: TGmCaptionAlign; PageNum, NumPages: integer);
var
  CaptionExtent: TGmSize;
  XPos: integer;
  ACaption: string;
  Ppi: integer;
begin
  ACaption := Tokenize(FCaption, PageNum, NumPages, GlobalDateTokenFormat, GlobalTimeTokenFormat);
  ACanvas.Font.PixelsPerInch := PpiX;
  ACanvas.Font.Assign(FFont);
  CaptionExtent := GmFontMapper.TextExtent(ACanvas, ACaption);

  Ppi := ACanvas.Font.PixelsPerInch;
  XPos := ARect.Left;
  case AAlign of
    gmCenter: XPos := ((ARect.Right+ARect.Left) - (Round(CaptionExtent.Width * Ppi))) div 2;
    gmRight : XPos := ARect.Right - Round(CaptionExtent.Width * Ppi);
  end;
  if FHeaderFooter is TGmHeader then
    GmFontMapper.TextOut(ACanvas, XPos, ARect.Bottom-Round(CaptionExtent.Height * Ppi), nil, ACaption)
  else
    GmFontMapper.TextOut(ACanvas, XPos, ARect.Top, nil, ACaption);
end;

procedure TGmHeaderFooterCaption.LoadFromStream(Stream: TStream);
var
  AValues: TGmValueList;
  AFont: TGmFont;
begin
  AValues := TGmValueList.Create;
  try
    AValues.LoadFromStream(Stream);
    FCaption := AValues.ReadStringValue(C_T, '');
  finally
    AValues.Free;
  end;
  AFont := TGmFont.Create;
  try
    AFont.LoadFromStream(Stream);
    AFont.AssignToFont(FFont);
  finally
    AFont.Free;
  end;
end;

procedure TGmHeaderFooterCaption.SaveToStream(Stream: TStream);
var
  AValues: TGmValueList;
  AFont: TGmFont;
begin
  AValues := TGmValueList.Create;
  try
    AValues.WriteStringValue(C_T, FCaption);
    AValues.SaveToStream(Stream);
  finally
    AValues.Free;
  end;
  AFont := TGmFont.Create;
  try
    AFont.Assign(FFont);
    AFont.SaveToStream(Stream);
  finally
    AFont.Free;
  end;
end;

procedure TGmHeaderFooterCaption.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmHeaderFooterCaption.SetCaption(Value: string);
begin
  if FCaption = Value then Exit;
  FCaption := Value;
  Changed;
end;

procedure TGmHeaderFooterCaption.SetFont(Value: TFont);
begin
  FFont.Assign(Value);
  Changed;
end;

//------------------------------------------------------------------------------

// *** TGmHeaderFooter ***

constructor TGmHeaderFooter.Create(const ChangeEvent: TNotifyEvent = nil);
begin
  inherited Create;
  FPen := TPen.Create;
  FHeight := TGmValue.Create(Changed);
  FHeight.AsInches := 0;
  FVisible := False;
  FCaptions[gmLeft]   := TGmHeaderFooterCaption.Create(Self, Changed);
  FCaptions[gmCenter] := TGmHeaderFooterCaption.Create(Self, Changed);
  FCaptions[gmRight]  := TGmHeaderFooterCaption.Create(Self, Changed);
  FShowLine := True;
  OnChange := ChangeEvent;
end;

destructor TGmHeaderFooter.Destroy;
begin
  FPen.Free;
  FHeight.Free;
  FCaptions[gmLeft].Free;
  FCaptions[gmCenter].Free;
  FCaptions[gmRight].Free;
  inherited Destroy;
end;

function TGmHeaderFooter.GetLargestFont: TFont;
var
  F1, F2, F3: TFont;
begin
  F1 := FCaptions[gmLeft].Font;
  F2 := FCaptions[gmCenter].Font;
  F3 := FCaptions[gmRight].Font;
  Result := F1;
  if F2.Size > Result.Size then Result := F2;
  if F3.Size > Result.Size then Result := F3;
end;

procedure TGmHeaderFooter.Assign(Source: TPersistent);
begin
  if (Source is TGmHeaderFooter) then
  begin
    FCaptions[gmLeft].Assign((Source as TGmHeaderFooter).CaptionLeft);
    FCaptions[gmCenter].Assign((Source as TGmHeaderFooter).CaptionCenter);
    FCaptions[gmRight].Assign((Source as TGmHeaderFooter).CaptionRight);
  end
  else
    inherited Assign(Source);
end;

procedure TGmHeaderFooter.LoadFromStream(Stream: TStream);
var
  AValues: TGmValueList;
  APen: TGmPen;
begin
  FCaptions[gmLeft].LoadFromStream(Stream);
  FCaptions[gmCenter].LoadFromStream(Stream);
  FCaptions[gmRight].LoadFromStream(Stream);
  AValues := TGmValueList.Create;
  try
    AValues.LoadFromStream(Stream);
    FVisible := AValues.ReadBoolValue(C_VS, True);
    FShowLine := AValues.ReadBoolValue(C_SL, True);
    FHeight.AsInches := AValues.ReadExtValue(C_HT, -1);
  finally
    AValues.Free;
  end;
  APen := TGmPen.Create;
  try
    APen.LoadFromStream(Stream);
     
    //APen.AssignToPen(FPen, -1);

  finally
    APen.Free;
  end;
end;

procedure TGmHeaderFooter.SaveToStream(Stream: TStream);
var
  AValues: TGmValueList;
  APen: TGmPen;
begin
  FCaptions[gmLeft].SaveToStream(Stream);
  FCaptions[gmCenter].SaveToStream(Stream);
  FCaptions[gmRight].SaveToStream(Stream);
  AValues := TGmValueList.Create;
  try
    AValues.WriteBoolValue(C_VS, FVisible);
    AValues.WriteBoolValue(C_SL, FShowLine);
    AValues.WriteExtValue(C_HT, FHeight.AsInches);
    AValues.SaveToStream(Stream);
  finally
    AValues.Free;
  end;
  APen := TGmPen.Create;
  try
    APen.Assign(FPen);
    APen.SaveToStream(Stream);
  finally
    APen.Free;
  end;
end;

function TGmHeaderFooter.GetCaptionIndex(index: integer): TGmHeaderFooterCaption;
begin
  Result := FCaptions[TGmCaptionAlign(index)];
end;

function TGmHeaderFooter.GetHeight(Measurement: TGmMeasurement): Extended;
begin
  if FHeight.AsInches = 0 then
    Result := ConvertValue(GetFontHeightInch(GetLargestFont), gmInches, Measurement)
  else
    Result := FHeight.AsGmValue[Measurement];
end;

procedure TGmHeaderFooter.Changed(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmHeaderFooter.SetCaptionIndex(index: integer; Value: TGmHeaderFooterCaption);
begin
  FCaptions[TGmCaptionAlign(index)] := Value;
end;

procedure TGmHeaderFooter.SetHeight(Measurement: TGmMeasurement; Value: Extended);
begin
  FHeight.AsInches := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmHeaderFooter.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TGmHeaderFooter.SetShowLine(Value: Boolean);
begin
  if FShowLine = Value then Exit;
  FShowLine := Value;
  Changed(Self);
end;

procedure TGmHeaderFooter.SetVisible(Value: Boolean);
begin
  if FVisible = Value then Exit;
  FVisible := Value;
  Changed(Self);
end;

//------------------------------------------------------------------------------

// *** TGmHeader ***

procedure TGmHeader.DrawToCanvas(ACanvas: TCanvas; AMargins: TGmMargins; APageSize: TGmSize;
  PpiX, PpiY: integer; Page, NumPages: integer);
var
  ValueRect: TGmValueRect;
  HeaderRect: TRect;
  HeaderHeight: Extended;

begin
  if not FVisible then Exit;
  //ACanvas.Font.PixelsPerInch := PpiX;
  ValueRect := TGmValueRect.Create;
  try
  HeaderHeight := Height[gmInches];
  HeaderRect := Rect(Round(AMargins.Left.AsInches * PpiX),
                     Round((AMargins.Top.AsInches) * PpiY),
                     Round((APageSize.Width - AMargins.Right.AsInches) * PpiX),
                     Round((AMargins.Top.AsInches + HeaderHeight) * PpiY));

    HeaderHeight := Height[gmInches]; //GetFontHeightInch(GetLargestFont);
    ValueRect.Left.AsPixels[PpiX]   := Round(AMargins.Left.AsInches * PpiX);
    ValueRect.Top.AsPixels[PpiY]    := Round(AMargins.Top.AsInches * PpiY);
    ValueRect.Right.AsPixels[PpiX]  := Round((APageSize.Width - AMargins.Right.AsInches) * PpiX);
    ValueRect.Bottom.AsPixels[PpiY] := Round((AMargins.Top.AsInches + HeaderHeight) * PpiY);


    //HeaderRect := GmRectToRect(ScaleGmRect(ValueRect.AsInchRect, Ppi));
  finally
    ValueRect.Free;
  end;

  FCaptions[gmLeft].DrawToCanvas(ACanvas, HeaderRect, PpiX, PpiY, gmLeft, Page, NumPages);
  FCaptions[gmCenter].DrawToCanvas(ACanvas, HeaderRect, PpiX, PpiY, gmCenter, Page, NumPages);
  FCaptions[gmRight].DrawToCanvas(ACanvas, HeaderRect, PpiX, PpiY, gmRight, Page, NumPages);
  if FShowLine then
  begin
    ACanvas.Pen.Assign(FPen);
    ACanvas.MoveTo(HeaderRect.Left, HeaderRect.Bottom);
    ACanvas.LineTo(HeaderRect.Right, HeaderRect.Bottom);
  end;
end;

//------------------------------------------------------------------------------

// *** TGmFooter ***

procedure TGmFooter.DrawToCanvas(ACanvas: TCanvas; AMargins: TGmMargins; APageSize: TGmSize;
  PpiX, PpiY: integer; Page, NumPages: integer);
var
  FooterRect: TRect;
  FooterHeight: Extended;
begin
  if not FVisible then Exit;
  FooterHeight := Height[gmInches]; //GetFontHeightInch(GetLargestFont);
  FooterRect := Rect(Round(AMargins.Left.AsInches * PpiX),
                     Round(((APageSize.Height-AMargins.Bottom.AsInches) - FooterHeight) * PpiY),
                     Round((APageSize.Width - AMargins.Right.AsInches) * PpiX),
                     Round(((APageSize.Height-AMargins.Bottom.AsInches)) * PpiY));
  FCaptions[gmLeft].DrawToCanvas(ACanvas, FooterRect, PpiX, PpiY, gmLeft, Page, NumPages);
  FCaptions[gmCenter].DrawToCanvas(ACanvas, FooterRect, PpiX, PpiY, gmCenter, Page, NumPages);
  FCaptions[gmRight].DrawToCanvas(ACanvas, FooterRect, PpiX, PpiY, gmRight, Page, NumPages);
  if FShowLine then
  begin
    ACanvas.Pen.Assign(FPen);
    ACanvas.MoveTo(FooterRect.Left, FooterRect.Top);
    ACanvas.LineTo(FooterRect.Right, FooterRect.Top);
  end;
end;


//------------------------------------------------------------------------------

// *** TGmPage ***

constructor TGmPage.Create(APageList: TGmPageList);
begin
  inherited Create;
  FObjects := TGmBaseObjectList.Create;
  FRtfInfo := TGmPageRtfInfo.Create(APageList.ResourceTable);
  FPageList := APageList;
  FPageSizeInch.Width := 8.26;
  FPageSizeInch.Height := 11.69;
  FOrientation := gmPortrait;
  FObjects.OnChanged := Changed;
  FShowFooter := True;
  FShowHeader := True;
end;

destructor TGmPage.Destroy;
begin
  FObjects.Free;
  FRtfInfo.Free;
  inherited Destroy;
end;

function TGmPage.ObjectAtPos(x, y: Extended; Measurement: TGmMeasurement; var AObject: TGmVisibleObject): Boolean;
var
  ICount: integer;
  Mf: TMetafile;
  Mfc: TMetafileCanvas;
  ObjectRgn: HRGN;
 // Ppi: integer;
  xInch, yInch: Extended;
  DrawObject: TGmVisibleObject;
  DrawData: TGmObjectDrawData;
begin
  Result := False;
  AObject := nil;
  xInch := ConvertValue(x, Measurement, gmInches);
  yInch := ConvertValue(y, Measurement, gmInches);

  DrawData.PpiX := 600;
  DrawData.PpiY := 600;

  Mf := TMetafile.Create;
  //DrawData.Metafile := Mf;
  try
    Mfc := TMetafileCanvas.Create(Mf, 0);
    try
      Mfc.Font.PixelsPerInch := 600;

      for ICount := 0 to FObjects.Count-1 do
      begin

        if (FObjects.GmObject[ICount] is TGmVisibleObject) then
        begin
          DrawObject := TGmVisibleObject(FObjects.GmObject[ICount]);
          ObjectRgn := CreateRectRgnIndirect(GmRectPointsToRect(DrawObject.BoundingRect(DrawData)));
          try
            if PtInRegion(ObjectRgn, Round(xInch*600), Round(yInch*600)) then
            begin
              Result := True;
              AObject := TGmVisibleObject(FObjects.GmObject[ICount]);
            end;
          finally
            Windows.DeleteObject(ObjectRgn);
          end;
        end;
      end;
    finally
      Mfc.Free;
    end;
  finally
    Mf.Free;
  end;
end;

function TGmPage.AddObject(AObject: TGmBaseObject): TGmBaseObject;
begin
  Result := AObject;
  FObjects.AddObject(AObject);
  Changed(Self);
end;

function TGmPage.CreateGmObject(ObjectID: integer): TGmBaseObject;
begin
  Result := nil;
  case ObjectID of
    GM_TEXT_OBJECT_ID         : Result := TGmTextObject.Create(FPageList.ResourceTable);
    GM_TEXTBOX_OBJECT_ID      : Result := TGmTextBoxObject.Create(FPageList.ResourceTable);
    GM_LINE_OBJECT_ID         : Result := TGmLineObject.Create(FPageList.ResourceTable);
    GM_RECTANGLE_OBJECT_ID    : Result := TGmRectangleShape.Create(FPageList.ResourceTable);
    GM_ELLIPSE_OBJECT_ID      : Result := TGmEllipseShape.Create(FPageList.ResourceTable);
    GM_ROUNDRECT_OBJECT_ID    : Result := TGmRoundRectShape.Create(FPageList.ResourceTable);
    GM_GRAPHIC_OBJECT_ID      : Result := TGmGraphicObject.Create(FPageList.ResourceTable);
    GM_ARC_ID                 : Result := TGmArcShape.Create(FPageList.ResourceTable);
    GM_CHORD_ID               : Result := TGmChordShape.Create(FPageList.ResourceTable);
    GM_PIE_ID                 : Result := TGmPieShape.Create(FPageList.ResourceTable);
    GM_PATH_OBJECT_ID         : Result := TGmPathObject.Create(FPageList.ResourceTable);
    GM_CLIPRECT_OBJECT_ID     : Result := TGmClipRectObject.Create(FPageList.ResourceTable);
    GM_CLIPROUNDRECT_OBJECT_ID: Result := TGmClipRoundRectObject.Create(FPageList.ResourceTable);
    GM_CLIPELLIPSE_OBJECT_ID  : Result := TGmClipEllipseObject.Create(FPageList.ResourceTable);
    GM_REMOVE_CLIP_OBJECT_ID  : Result := TGmRemoveClipObject.Create(FPageList.ResourceTable);
    GM_POLYGON_OBJECT_ID      : Result := TGmPolygonObject.Create(FPageList.ResourceTable);
    GM_POLYLINE_OBJECT_ID     : Result := TGmPolylineObject.Create(FPageList.ResourceTable);
    GM_POLYBEZIER_OBJECT_ID   : Result := TGmPolyBezierObject.Create(FPageList.ResourceTable);
    GM_POLYLINETO_OBJECT_ID   : Result := TGmPolylineToObject.Create(FPageList.ResourceTable);
    GM_POLYBEZIERTO_OBJECT_ID : Result := TGmPolyBezierToObject.Create(FPageList.ResourceTable);
  end;
end;

function TGmPage.GetCount: integer;
begin
  Result := FObjects.Count;
end;

function TGmPage.GetGmObject(index: integer): TGmBaseObject;
begin
  Result := FObjects.GmObject[index];
end;

function TGmPage.GetPageNum: integer;
begin
  Result := 0;
  if Assigned(FPageList) then Result := FPageList.IndexOf(Self)+1;
end;

function TGmPage.GetPageSize(Measurement: TGmMeasurement): TGmSize;
begin
  Result := ConvertGmSize(FPageSizeInch, gmInches, Measurement);
end;

procedure TGmPage.Clear;
begin
  FObjects.Clear;
  Changed(Self);
end;

procedure TGmPage.DeleteGmObject(AObject: TGmBaseObject);
var
  ObjectIndex: integer;
begin
  ObjectIndex := FObjects.IndexOf(AObject);
  if ObjectIndex > -1 then
    FObjects.Delete(ObjectIndex);
  Changed(Self);
end;

procedure TGmPage.DeleteLastGmObject;
begin
  DeleteGmObject(FObjects.GmObject[FObjects.Count-1]);
end;

procedure TGmPage.Changed(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmPage.DrawRichText(ACanvas: TCanvas; PpiX, PpiY: integer; WrapRichText: Boolean);
var
  Range: TFormatRange;
  TextLenEx: TGetTextLengthEx;
  Mf: TMetafile;
  Mfc: TMetafileCanvas;
begin
  if not Assigned(FRtfInfo) then Exit;
  if not Assigned(FRtfInfo.RichEdit) then Exit;
  FillChar(Range, SizeOf(TFormatRange), 0);
  with Range do
  begin
    hdc := ACanvas.Handle;
    hdcTarget := FPageList.FPrinter.Handle;
    rc.Left := 0;
    rc.Top := 0;
    rcPage.Right := Round(FPageSizeInch.Width * 1440);
    rcPage.Bottom := Round(FPageSizeInch.Height * 1440);
    rc := rcPage;
    rc.Left := FRtfInfo.Margins.Left.AsTwips;
    rc.Top := FRtfInfo.Margins.Top.AsTwips;
    rc.Right := FRtfInfo.Margins.Right.AsTwips;
    rc.Bottom := FRtfInfo.Margins.Bottom.AsTwips+1;
    chrg.cpMax := -1;

    if not WrapRichText then rc.Right := (rc.Right * 10);
    
    with TextLenEx do
    begin
      flags := GTL_DEFAULT;
      codepage := CP_ACP;
    end;
    chrg.cpMin := FRtfInfo.Offset.X;
    chrg.cpMax := FRtfInfo.Offset.Y;

    if not IsPrinterCanvas(ACanvas) then
    begin
      Mf := TMetafile.Create;
      try
        Mfc := TMetafileCanvas.Create(Mf, FPageList.FPrinter.Handle);
        try
          hdc := Mfc.Handle;
          Mfc.Font.PixelsPerInch := PpiX;
          SetMapMode(Mfc.Handle, MM_ANISOTROPIC);
          SetWindowExtEx(Mfc.Handle, rcPage.Right, rcPage.Bottom, nil);
          SetViewPortExtEx(Mfc.Handle, rcPage.Right, rcPage.Bottom, nil);
          ScaleViewportExtEx(Mfc.Handle,
                             PpiX,
                             FPageList.FPrinter.PrinterInfo.PpiX,
                             PpiY,
                             FPageList.FPrinter.PrinterInfo.PpiY,
                             nil);
          SendMessage(FRtfInfo.RichEdit.Handle, EM_FORMATRANGE, 1, Longint(@Range));

        finally
          Mfc.Free;
        end;
        ACanvas.Draw(0,0,Mf);
      finally
        Mf.Free;
      end;
    end
    else
      SendMessage(FRtfInfo.RichEdit.Handle, EM_FORMATRANGE, 1, Longint(@Range));
  end;
end;

procedure TGmPage.SetOrientation(Value: TGmOrientation);
var
  NewW, NewH: Extended;
begin
  if Value = gmPortrait then
  begin
    NewW := MinFloat(FPageSizeInch.Width, FPageSizeInch.Height);
    NewH := MaxFloat(FPageSizeInch.Width, FPageSizeInch.Height);
  end
  else
  begin
    NewW := MaxFloat(FPageSizeInch.Width, FPageSizeInch.Height);
    NewH := MinFloat(FPageSizeInch.Width, FPageSizeInch.Height);
  end;
  FPageSizeInch := GmSize(NewW, NewH);
  FOrientation := Value;
  //Changed(Self);
  if Assigned(FOnChangeOrientation) then FOnChangeOrientation(Self);
end;

procedure TGmPage.DrawToCanvas(ACanvas: TCanvas; PpiX, PpiY: integer; FastDraw: Boolean);
var
  ICount: integer;
  AObject: TGmBaseObject;
  DrawData: TGmObjectDrawData;
begin
  DrawRichText(ACanvas, PpiX, PpiY, FRtfInfo.WrapText);
  DrawData.PpiX := PpiX;
  DrawData.PpiY := PpiY;
  DrawData.Page := PageNum;
  DrawData.FastDraw := FastDraw;
  DrawData.NumPages := FPageList.Count;
  for ICount := 0 to FObjects.Count-1 do
  begin
    AObject := FObjects.GmObject[ICount];
    AObject.Draw(ACanvas, DrawData);
  end;
  with FPageList do
  begin
    if FShowHeader then Header.DrawToCanvas(ACanvas, Margins, FPageSizeInch, PpiX, PpiY, PageNum, Count);
    if FShowFooter then Footer.DrawToCanvas(ACanvas, Margins, FPageSizeInch, PpiX, PpiY, PageNum, Count);
  end;
end;

procedure TGmPage.LoadFromStream(Stream: TStream);
var
  AValues: TGmValueList;
  ICount, NumObjects: integer;
  ObjectID: integer;
  NewObject: TGmBaseObject;
begin
  AValues := TGmValueList.Create;
  try
    AValues.LoadFromStream(Stream);
    FRtfInfo.LoadFromValueList(AValues);
    FOrientation         := TGmOrientation(AValues.ReadIntValue(C_O, 0));
    FPageSizeInch.Width  := AValues.ReadExtValue(C_PW, 8.26);
    FPageSizeInch.Height := AValues.ReadExtValue(C_PH, 11.69);
    NumObjects           := AValues.ReadIntValue(C_NO, 0);
    FShowHeader          := AValues.ReadBoolValue(C_SH, True);
    FShowFooter          := AValues.ReadBoolValue(C_SF, True);
    for ICount := 1 to NumObjects do
    begin
      Stream.ReadBuffer(ObjectID, SizeOf(ObjectID));
      NewObject := CreateGmObject(ObjectID);
      if Assigned(NewObject) then
      begin
        NewObject.LoadFromStream(Stream);
        AddObject(NewObject);
      end
      else
        AValues.LoadFromStream(Stream);
    end;
  finally
    AValues.Free;
  end;
end;

procedure TGmPage.SaveToStream(Stream: TStream);
var
  AValues: TGmValueList;
  ICount: integer;
begin
  AValues := TGmValueList.Create;
  try
    FRtfInfo.SaveToValueList(AValues);
    AValues.WriteIntValue(C_O, Ord(FOrientation));
    AValues.WriteExtValue(C_PW, FPageSizeInch.Width);
    AValues.WriteExtValue(C_PH, FPageSizeInch.Height);
    AValues.WriteIntValue(C_NO, Count);
    if FShowHeader = False then AValues.WriteBoolValue(C_SH, False);
    if FShowFooter = False then AValues.WriteBoolValue(C_SF, False);
    AValues.SaveToStream(Stream);
  finally
    AValues.Free;
  end;
  for ICount := 0 to Count-1 do
    GmObject[ICount].SaveToStream(Stream);
end;

procedure TGmPage.SetPageSize(AWidth, AHeight: Extended);
begin
  FPageSizeInch.Width := AWidth;
  FPageSizeInch.Height := AHeight;
  Changed(Self);
end;

procedure TGmPage.SetShowFooter(Value: Boolean);
begin
  if FShowFooter = Value then Exit;
  FShowFooter := Value;
  Changed(Self);
end;

procedure TGmPage.SetShowHeader(Value: Boolean);
begin
  if FShowHeader = Value then Exit;
  FShowHeader := Value;
  Changed(Self);
end;

//------------------------------------------------------------------------------

// *** TGmPageList ***

constructor TGmPageList.Create;
begin
  inherited Create;
  FResourceTable := TGmResourceTable.Create;
  FCanvas := TGmCanvas.Create(Self);
  FFooter := TGmFooter.Create(HeaderFooterChanged);
  FHeader := TGmHeader.Create(HeaderFooterChanged);
  FPrinter := TGmPrinter.Create;
  FMargins := TGmMargins.Create(FPrinter);
  FValueSize := TGmValueSize.Create;
  FValueRect := TGmValueRect.Create;
  FPaperSize := A4;
  FOrientation := gmPortrait;
  FPagesPerSheet := gmOnePage;
  FResourceTable.CustomMemoList.OnNeedRichEdit := NeedRichEdit;
  FMargins.OnChange := PageMarginsChanged;
end;

destructor TGmPageList.Destroy;
begin
  Clear;
  FResourceTable.Free;
  FCanvas.Free;
  FFooter.Free;
  FHeader.Free;
  FMargins.Free;
  FPrinter.Free;
  FValueSize.Free;
  FValueRect.Free;
  inherited Destroy;
end;

function TGmPageList.AddObject(AObject: TGmBaseObject; AOrigin: TGmCoordsRelative): TGmBaseObject;
var
  APrintMargins: TGmRect;
begin
  case AOrigin of
    gmFromPrinterMargins:
    begin
      APrintMargins := FPrinter.PrinterInfo.MarginsInches[FOrientation];
      AObject.OffsetObject(APrintMargins.Left,
                           APrintMargins.Top,
                           gmInches);

    end;
    gmFromUserMargins:
    begin
      AObject.OffsetObject(Margins.Left.AsInches,
                           Margins.Top.AsInches,
                           gmInches);
    end;
    gmFromHeaderLine:
    begin
      AObject.OffsetObject(Margins.Left.AsInches,
                           Margins.Top.AsInches + FHeader.Height[gmInches],
                           gmInches);
    end;
  end;
  Result := Page[FCurrentPage].AddObject(AObject);
  if (AObject is TGmVisibleObject) then
    (Result as TGmVisibleObject).OnLevelChange := ChangeObjectLevel;
end;

function TGmPageList.AddPage: TGmPage;
begin
  Result := InsertPage(-1);
end;

function TGmPageList.InsertPage(index: integer): TGmPage;
begin
  Result := TGmPage.Create(Self);
  Result.Orientation := FOrientation;
  InitPaperSize;
  Result.SetPageSize(FPaperSizeInch.Width, FPaperSizeInch.Height);
  Result.OnChange := PageChanged;
  Result.OnChangeOrientation := PageChanged;
  if index = -1 then
    Add(Result)
  else
    Insert(index, Result);
  PageCountChanged(Self);
  PageChanged(Self);
  CurrentPage := Count;
  if Assigned(FOnNewPage) then FOnNewPage(Self);
end;

function TGmPageList.AvailablePageRect: TGmValueRect;
var
  APage: TGmPage;
begin
  Result := FValueRect;
  APage := Page[CurrentPage];
  if Margins.UsePrinterMargins then
  begin
    Result.Left.AsInches   := FPrinter.PrinterInfo.MarginsInches[APage.Orientation].Left;
    Result.Top.AsInches    := FPrinter.PrinterInfo.MarginsInches[APage.Orientation].Top + FHeader.Height[gmInches];
    Result.Right.AsInches  := APage.PageSize[gmInches].Width - FPrinter.PrinterInfo.MarginsInches[APage.Orientation].Right;
    Result.Bottom.AsInches := APage.PageSize[gmInches].Height - (FPrinter.PrinterInfo.MarginsInches[APage.Orientation].Bottom + FFooter.Height[gmInches]);
  end
  else
  begin
    Result.Left.AsInches   := FMargins.Left.AsInches;
    Result.Top.AsInches    := FMargins.Top.AsInches + FHeader.Height[gmInches];
    Result.Right.AsInches  := APage.PageSize[gmInches].Width - FMargins.Right.AsInches;
    Result.Bottom.AsInches := APage.PageSize[gmInches].Height - (FMargins.Bottom.AsInches + FFooter.Height[gmInches]);
  end;
end;

function TGmPageList.FooterRect: TGmValueRect;
var
  APage: TGmPage;
begin
  Result := FValueRect;
  APage := Page[CurrentPage];
  Result.Left.AsInches   := FMargins.Left.AsInches;
  Result.Bottom.AsInches := APage.PageSize[gmInches].Height - FMargins.Bottom.AsInches;
  Result.Right.AsInches  := APage.PageSize[gmInches].Width - FMargins.Right.AsInches;
  Result.Top.AsInches    := Result.Bottom.AsInches - FFooter.Height[gmInches];
end;

function TGmPageList.HeaderRect: TGmValueRect;
var
  APage: TGmPage;
begin
  Result := FValueRect;
  APage := Page[CurrentPage];
  Result.Left.AsInches   := FMargins.Left.AsInches;
  Result.Top.AsInches    := FMargins.Top.AsInches;
  Result.Right.AsInches  := APage.PageSize[gmInches].Width - FMargins.Right.AsInches;
  Result.Bottom.AsInches := FMargins.Top.AsInches + FHeader.Height[gmInches];
end;

procedure TGmPageList.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGmPageList.ClearPages(const FreeAll: Boolean = False; const FreeResources: Boolean = True);
begin
  Clear;
  if FreeResources then
    FResourceTable.Clear;
  if not FreeAll then
  begin
    FCurrentPage := 1;
    AddPage;
  end;
  if Assigned(FOnClear) then FOnClear(Self);
end;

procedure TGmPageList.DeletePage(index: integer);
begin
  if (index <0) or (index > Count-1) then Exit;
  if (index = Count-1) then Dec(FCurrentPage);
  Delete(index);
  if FCurrentPage = 0 then
  begin
    FCurrentPage := 1;
    AddPage;
  end;
  PageCountChanged(Self);
  PageChanged(Self);
end;

procedure TGmPageList.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    Dec(FUpdateCount);
    if FUpdateCount = 0 then
    begin
      PageCountChanged(Self);
      PageChanged(Self);
    end;
  end;
end;

procedure TGmPageList.FindText(AText: string; CaseSensative: Boolean; AList: TList);

  function ObjectContainsText(AObject: TGmTextObject; AText: string; CaseSensative: Boolean): Boolean;
  begin
    if CaseSensative then
      Result := Pos(AText, AObject.Caption) <> 0
    else
      Result := Pos(LowerCase(AText), LowerCase(AObject.Caption)) <> 0
  end;

var
  ICount: Integer;
  IObjCount: integer;
  APage: TGmPage;
  AObject: TGmBaseObject;
begin
  // find any TGmTextObjects which exist in the TGmPreview and add them to the
  // AList list paramater...
  for ICount := 1 to Count do    // Iterate
  begin
    APage := Page[ICount];
    for IObjCount := 1 to APage.Count do    // Iterate
    begin
      AObject := APage.GmObject[IObjCount];
      if (AObject is TGmTextObject) or (AObject is TGmTextBoxObject) then
      begin
        if ObjectContainsText((AObject as TGmTextObject), AText, CaseSensative) then
        begin
          AList.Add(AObject);
        end;
      end;
    end;
  end;
end;

procedure TGmPageList.LoadFromStream(Stream: TStream);
var
  AValues: TGmValueList;
  AVersion: Extended;
  ICount,
  NumPages: integer;
  LoadStream: Boolean;
begin
  AValues := TGmValueList.Create;
  try
    AValues.LoadFromStream(Stream);
    LoadStream := True;
    AVersion              := AValues.ReadExtValue(C_V, 0);
    if Assigned(FBeforeLoad) then FBeforeLoad(Self, AVersion, LoadStream);
    if not LoadStream then Exit;
    FOrientation          := TGmOrientation(AValues.ReadIntValue(C_O, 0));
    FPaperSize            := StrToPaperSize(AValues.ReadStringValue(C_PS, 'A4'));
    FPaperSizeInch.Width  := AValues.ReadExtValue(C_PW, 8.26);
    FPaperSizeInch.Height := AValues.ReadExtValue(C_PH, 11.69);
    NumPages              := AValues.ReadIntValue(C_NP, 0);
  finally
    AValues.Free;
  end;
  FResourceTable.LoadFromStream(Stream);
  BeginUpdate;
  FHeader.LoadFromStream(Stream);
  FFooter.LoadFromStream(Stream);
  FMargins.LoadFromStream(Stream);
  ClearPages(True, False);
  for ICount := 1 to NumPages do
    AddPage.LoadFromStream(Stream);
  FCurrentPage := 1;
  EndUpdate;
end;

procedure TGmPageList.NeedRichEdit(Sender: TObject; var ARichEdit: TCustomMemo);
begin
  if Assigned(FOnNeedRichEdit) then FOnNeedRichEdit(Self, ARichEdit);
end;

procedure TGmPageList.Print;
begin
  PrintRange(1, Count);
end;

procedure TGmPageList.PrintPages(Pages: array of integer);
var
  ICount: integer;
  APageNum: integer;
  PpiX: integer;
  PpiY: integer;
  ClipRect: TRect;
  ClipRgn: HRGN;
begin
  FPrinter.Orientation := Page[Pages[0]].Orientation;
  FPrinter.PagesPerSheet := FPagesPerSheet;
  FPrinter.PrinterPaperSize := FPaperSize;
  FPrinter.BeginDoc('');
  if (FPrinter.Aborted) or (not FPrinter.Printing) then Exit;
  for ICount := 0 to High(Pages) do
  begin

    APageNum := Pages[ICount];
    PpiX := FPrinter.PrinterInfo.PpiX;
    PpiY := FPrinter.PrinterInfo.PpiY;

    if FMargins.ClipMargins then
    begin
      // clip the margins...
      ClipRect.Left   := FMargins.Left.AsPixels[PpiX];
      ClipRect.Top    := FMargins.Left.AsPixels[PpiY];
      ClipRect.Right  := Round((Page[APageNum].PageSize[gmInches].Width - FMargins.Right.AsInches) * PpiX);
      ClipRect.Bottom := Round((Page[APageNum].PageSize[gmInches].Height - FMargins.Bottom.AsInches) * PpiY);
    end
    else
    begin
      // Clip to the page...
      ClipRect.Left   := 0;
      ClipRect.Top    := 0;
      ClipRect.Right  := Round(Page[APageNum].PageSize[gmInches].Width * PpiX);
      ClipRect.Bottom := Round(Page[APageNum].PageSize[gmInches].Height * PpiY);
    end;
    ClipRgn := CreateRectRgnIndirect(ClipRect);
    try
      BeginPath(FPrinter.Canvas.Handle);
      with ClipRect do
        FPrinter.Canvas.Rectangle(Left, Top, Right, Bottom);
      EndPath(FPrinter.Canvas.Handle);
      ClipRgn := PathToRegion(FPrinter.Canvas.Handle);
      SelectClipRgn(FPrinter.Canvas.Handle, ClipRgn);
    finally
      DeleteObject(ClipRgn);
    end;

    Page[APageNum].DrawToCanvas(FPrinter.Canvas, PpiX, PpiY, False);
    if ICount < High(Pages) then
    begin
      FPrinter.Orientation := Page[Pages[ICount+1]].Orientation;
      FPrinter.NewPage;
    end;
    DoPrintProgress(ICount+1, High(Pages)+1);
    if FPrinter.Aborted then Exit;
  end;
  FPrinter.EndDoc;
end;

procedure TGmPageList.PrintRange(AFromPage, AToPage: integer);
var
  APages: array of integer;
  ICount: integer;
begin
  SetLength(APages, MaxInt(AFromPage, AToPage)-MinInt(AFromPage, AToPage)+1);
  if AFromPage < AToPage then
    for ICount := 0 to High(APages) do
      APages[ICount] := AFromPage + ICount;

  if AFromPage >= AToPage then
    for ICount := 0 to High(APages) do
      APages[ICount] := AFromPage - ICount;
  PrintPages(APages);
end;

procedure TGmPageList.PrintToFile(AFileName: string);
begin
  // to do
end;

procedure TGmPageList.SaveToStream(Stream: TStream);
var
  AValues: TGmValueList;
  ICount: integer;
begin
  AValues := TGmValueList.Create;
  try
    AValues.WriteExtValue(C_V, GMPS_VERSION);
    AValues.WriteIntValue(C_O, Ord(FOrientation));
    AValues.WriteStringValue(C_PS, PaperSizeToStr(FPaperSize));
    AValues.WriteExtValue(C_PW, FPaperSizeInch.Width);
    AValues.WriteExtValue(C_PH, FPaperSizeInch.Height);
    AValues.WriteIntValue(C_NP, Count);
    AValues.SaveToStream(Stream);
  finally
    AValues.Free;
  end;
  FResourceTable.SaveToStream(Stream);
  FHeader.SaveToStream(Stream);
  FFooter.SaveToStream(Stream);
  FMargins.SaveToStream(Stream);
  for ICount := 1 to Count do
    Page[ICount].SaveToStream(Stream);
end;

procedure TGmPageList.SetPageSize(AWidth, AHeight: Extended; Measurement: TGmMeasurement);
var
  ICount: integer;
begin
  FPaperSizeInch.Width := ConvertValue(AWidth, Measurement, gmInches);
  FPaperSizeInch.Height := ConvertValue(AHeight, Measurement, gmInches);
  FPaperSize := Custom;
  for ICount := 1 to Count do
    Page[ICount].SetPageSize(FPaperSizeInch.Width, FPaperSizeInch.Height);
  if Assigned(FOnPaperSizeChanged) then FOnPaperSizeChanged(Self);
end;

procedure TGmPageList.UsePrinterPageSize;
var
  ASize: TGmSize;
begin
  BeginUpdate;
  PaperSize := FPrinter.PrinterPaperSize;
  if PaperSize = Custom then
  begin
    ASize := FPrinter.GetPaperDimensions(gmInches);
    SetPageSize(ASize.Width, ASize.Height, gmInches);
  end;
  Orientation := FPrinter.PrinterInfo.Orientation;
  EndUpdate;
end;

function TGmPageList.GetPage(index: integer): TGmPage;
begin
  Result := TGmPage(Items[index-1]);
end;

function TGmPageList.GetUpdating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

procedure TGmPageList.ChangeObjectLevel(Sender: TObject; LevelChange: TGmArrangeObject);
var
  APage: TGmPage;
  ObjectIndex: integer;
begin
  APage := Page[FCurrentPage];
  ObjectIndex := APage.FObjects.IndexOf(Sender);
  if ObjectIndex = -1 then Exit;
  APage.FObjects.Extract(Sender);
  case LevelChange of
    gmToFront:  APage.FObjects.AddObject(TGmBaseObject(Sender));
    gmForward:  APage.FObjects.InsertObject(ObjectIndex+1, TGmBaseObject(Sender));
    gmBackword: APage.FObjects.InsertObject(ObjectIndex-1, TGmBaseObject(Sender));
    gmToBack:   APage.FObjects.InsertObject(0, TGmBaseObject(Sender));
  end;
  APage.Changed(Self);
end;

procedure TGmPageList.DoPrintProgress(Printed, Total: integer);
begin
  if Assigned(FOnPrintProgress) then FOnPrintProgress(Self, Printed, Total);
end;

procedure TGmPageList.InitPaperSize;
begin
  if FPaperSize = Custom then Exit;
  FPaperSizeInch := GetPaperSizeInch(FPaperSize);
  if FOrientation = gmLandscape then
    SwapExtValues(FPaperSizeInch.Height, FPaperSizeInch.Width);
end;

procedure TGmPageList.HeaderFooterChanged(Sender: TObject);
begin
  if FUpdateCount > 0 then Exit;
  
  if Assigned(FOnHeaderFooterChanged) then FOnHeaderFooterChanged(Self);
end;

procedure TGmPageList.PageChanged(Sender: TObject);
begin
  if FUpdateCount > 0 then Exit;
  if Assigned(FOnPageChanged) then FOnPageChanged(Self);
end;

procedure TGmPageList.PageCountChanged(Sender: TObject);
begin
  if FUpdateCount > 0 then Exit;
  if Assigned(FOnPageCountChanged) then FOnPageCountChanged(Self);
end;

procedure TGmPageList.PageMarginsChanged(Sender: TObject);
begin
  if FUpdateCount > 0 then Exit;
  if Assigned(FOnPageMarginsChanged) then FOnPageMarginsChanged(Self);
end;

procedure TGmPageList.SetCurrentPage(Value: integer);
begin
  if Value = FCurrentPage then Exit;
  if (Value < 1) or (Value > Count) then Exit;
  if Assigned(FOnPageNumChanging) then FOnPageNumChanging(Self);
  FCurrentPage := Value;
  if Assigned(FOnPageNumChanged) then FOnPageNumChanged(Self);
end;

procedure TGmPageList.SetOrientation(Value: TGmOrientation);
var
  ICount: integer;
begin
  BeginUpdate;
  try
    for ICount := 1 to Count do
      Page[ICount].Orientation := Value;
    FOrientation := Value;
    FPaperSizeInch := Page[1].PageSize[gmInches];
  finally
    EndUpdate;
    if Assigned(FOnOrientationChanged) then FOnOrientationChanged(Self);
  end;
end;

procedure TGmPageList.SetPage(index: integer; APage: TGmPage);
begin
  Items[index-1] := APage;
end;

procedure TGmPageList.SetPaperSize(Value: TGmPaperSize);
var
  ICount: integer;
begin
  if FPaperSize = Value then Exit;
  BeginUpdate;
  try
    FPaperSize := Value;
    InitPaperSize;
    for ICount := 1 to Count do
      Page[ICount].SetPageSize(FPaperSizeInch.Width, FPaperSizeInch.Height);
  finally
    EndUpdate;
  end;
  if Assigned(FOnPaperSizeChanged) then FOnPaperSizeChanged(Self);
end;

end.
