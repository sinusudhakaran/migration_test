{******************************************************************************}
{                                                                              }
{                               GmPreview.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmPreview;

interface

uses Windows, Classes, Forms, StdCtrls, GmClasses, GmTypes, GmCanvas, Controls,
  Messages, Graphics, GmPrinter, GmPageList, GmConst, GmResource;

{$I GMPS.INC}

const
  // cursor values...
  crZoomIn   = 101;
  crZoomOut  = 102;

type
  TGmDrawHeaderFooterEvent    = procedure(Sender: TObject; ARect: TGmValueRect; ACanvas: TGmCanvas) of object;

  // *** TGmPreview ***

  TGmPreview = class(TGmScrollingPageControl)
  private
    FDragObjectRect: TRect;
    FDragObjectStart: TGmPoint;
    FDrawSelectedBorder: Boolean;
    FLastObjectRect: TRect;
    FMaxZoom: integer;
    FMinZoom: integer;
    FMouseDownPoint: TPoint;
    FMousePosInch: TGmPoint;
    FObjectDragging: Boolean;
    FPages: TGmPageList;
    FPanning: Boolean;
    FPanningOrigin: TPoint;
    FPageGrid: TGmPageGrid;
    FPaper: TGmPaperImage;
    FRegisteredComponents: TList;
    FPanningScrollOrigin: TPoint;
    FScrollPos: TGmPoint;
    FSelectionPen: TPen;
    FSelectedObject: TGmVisibleObject;
    FShadow: TGmShadow;
    FUpdating: Boolean;
    FZoomIncrement: integer;
    FZoomStyle: TGmZoomStyle;
    // events...
    FAfterPrint: TNotifyEvent;
    FBeforeLoad: TGmBeforeLoadEvent;
    FBeforePrint: TNotifyEvent;
    FOnAbortPrint: TNotifyEvent;
    FOnClear: TNotifyEvent;
    FOnDrawHeader: TGmDrawHeaderFooterEvent;
    FOnDrawFooter: TGmDrawHeaderFooterEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnNeedRichEdit: TGmNeedRichEditEvent;
    FOnNewPage: TNotifyEvent;
    FOnObjectMouseDown: TGmObjectMouseEvent;
    FOnOrientationChanged: TNotifyEvent;
    FOnPageChanged: TNotifyEvent;
    FOnPageDragDrop: TGmPageDragDropEvent;
    FOnPageDragOver: TGmPageDragOverEvent;
    FOnPageMouseDown: TGmPageMouseEvent;
    FOnPageMouseMove: TGmPageMouseMoveEvent;
    FOnPageMouseUp: TGmPageMouseEvent;
    FOnPrintProgress: TGmPrintProgressEvent;
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);
    function GetAvailablePageRect: TGmValueRect;
    function GetAvailablePageGmRect(Measurement: TGmMeasurement): TGmRect;
    function GetAvailablePageHeight(Measurement: TGmMeasurement): Extended;
    function GetAvailablePageWidth(Measurement: TGmMeasurement): Extended;
    function GetCurrentPage: TGmPage;
    function GetCurrentPageNum: integer;
    function GetDateFormat: string;
    function GetDragDrawShape: TGmDragDrawing;
    function GetFitHeightScale: Extended;
    function GetFitWidthScale: Extended;
    function GetFooter: TGmFooter;
    function GetGmPrinter: TGmPrinter;
    function GetGutter: integer;
    function GetHeader: TGmHeader;
    function GetIsUpdating: Boolean;
    function GetMargins: TGmMargins;
    function GetNumPages: integer;
    function GetPagesPerSheet: TGmPagesPerSheet;
    function GetPaperSize: TGmPaperSize;
    function GetOrientation: TGmOrientation;
    function GetPage(index: integer): TGmPage;
    function GetPageHeight(Measurement: TGmMeasurement): Extended;
    function GetPageWidth(Measurement: TGmMeasurement): Extended;
    function GetResourceTable: TObject;
    function GetScratchCanvas: TCanvas;
    function GetTimeFormat: string;
    function GetZoom: integer;
    procedure DoAbortPrint(Sender: TObject);
    procedure DoAfterPrint(Sender: TObject);
    procedure DoBeforeLoad(Sender: TObject; Version: Extended; var LoadFile: Boolean);
    procedure DoBeforePrint(Sender: TObject);
    procedure DoClear(Sender: TObject);
    procedure DoPrintProgress(Sender: TObject; Printed, Total: integer);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    procedure DragGmObjectEnd;
    procedure NewPageEvents(Sender: TObject);
    procedure EnablePaperMouseEvents;
    procedure HeaderFooterChanged(Sender: TObject);
    procedure LoadScrollPos;
    procedure MessageToControls(AMessage: integer; Param1, Param2: integer);
    procedure NeedRichEdit(Sender: TObject; var ARichEdit: TCustomMemo);
    procedure SaveScrollPos;
    procedure SetCurrentPageNum(Value: integer);
    procedure SetDateFormat(Value: string);
    procedure SetDragDrawShape(Value: TGmDragDrawing);
    procedure SetFooter(Value: TGmFooter);
    procedure SetGutter(Value: integer);
    procedure SetHeader(Value: TGmHeader);
    procedure SetMargins(Value: TGmMargins);
    procedure SetMaxZoom(Value: integer);
    procedure SetMinZoom(Value: integer);
    procedure SetOrientation(Value: TGmOrientation);
    procedure SetPagesPerSheet(Value: TGmPagesPerSheet);
    procedure SetPaperSize(Value: TGmPaperSize);
    procedure SetPrinter(APrinter: TGmPrinter);
    procedure SetShadow(Value: TGmShadow);
    procedure SetTimeFormat(Value: string);
    procedure SetZoom(Value: integer);
    procedure UpdateScrollBars;
    procedure ZoomToArea(ARect: TRect);
  protected
    procedure DoVerticalScroll( var Msg: TMessage ) ; message WM_VSCROLL;
    procedure DoHorizontalScroll( var Msg: TMessage ) ; message WM_HSCROLL;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoDragDrop(Sender: TObject; Source: TObject; X, Y: integer);
    procedure DoDragOver(Sender, Source: TObject; X, Y: integer; State: TDragState; var Accept: Boolean);
    procedure DoMarginsChanged(Sender: TObject);
    procedure DoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DoOrientationChanged(Sender: TObject);
    procedure DoPageContentChanged(Sender: TObject);
    procedure DoPageCountChanged(Sender: TObject);
    procedure DoPageNumChanged(Sender: TObject);
    procedure DoPageDragDrop(Sender: TObject; Source: TObject; X, Y: TGmValue);
    procedure DoPageDragOver(Sender, Source: TObject; X, Y: TGmValue; State: TDragState; var Accept: Boolean);
    procedure DoPageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: TGmValue);
    procedure DoPageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: TGmValue);
    procedure DoPageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: TGmValue);
    procedure DoPaperSizeChanged(Sender: TObject);
    procedure DoPrinterChanged(Sender: TObject);
    procedure PaintPage(Sender: TObject);
    procedure WMNCHitTest(var Message: TMessage); message WM_NCHITTEST;
    procedure WMSize(var Message: TMessage); message WM_SIZE;
    {$IFDEF D4+}
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
    {$ENDIF}
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function FooterRect: TGmValueRect;
    function GetFileVersion(AFileName: string): Extended;
    function GetPageSize(Measurement: TGmMeasurement): TGmSize;
    function HeaderRect: TGmValueRect;
    function InsertPage(index: integer): TGmPage;
    function NewPage: TGmPage;
    function GmObjectAtPos(x, y: Extended; Measurement: TGmMeasurement): TGmVisibleObject;
    function GmObjectRect(AObject: TGmVisibleObject): TRect;
    function Tokenize(AText: string; APage: integer): string;
    procedure AddAssociatedComponent(AComponent: TComponent);
    procedure RemoveAssociatedComponent(AComponent: TComponent);
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure CenterOnClick(x, y: integer);
    procedure Clear;
    procedure DeleteCurrentPage;
    procedure DeletePage(index: integer);
    procedure DeleteSelectedGmObject;
    procedure DragDrawCancel;
    procedure DragDrawStart;
    procedure DragDrawToCanvas;
    procedure DragDrawZoom;
    procedure DragGmObjectStart(AObject: TGmVisibleObject);
    procedure EndUpdate;
    procedure FindText(AText: string; CaseSensative: Boolean; AList: TList);
    procedure FirstPage;
    procedure FitHeight;
    procedure FitWholePage;
    procedure FitWidth;
    procedure LastPage;
    procedure LoadFromFile(AFilename: string);
    procedure LoadFromStream(Stream: TStream);
    procedure NextPage;
    procedure PaperSizes(AStrings: TStrings);
    procedure PrevPage;
    procedure Print;
    procedure PrintCurrentPage;
    procedure PrintRange(APageFrom, APageTo: integer);
    procedure PrintToFile(AFileName: string);
    procedure SaveToFile(AFileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure ScrollToPosition(xPercent, yPercent: Extended);
    procedure SelectGmObject(AObject: TGmVisibleObject);
    procedure SetCursor(ACursor: TGmCursor);
    procedure SetCustomPageSize(AWidth, AHeight: Extended; Measurement: TGmMeasurement);
    procedure StartPanning;
    procedure StopPanning;
    procedure UsePrinterPageSize;
    procedure ZoomIn;
    procedure ZoomOut;
    // properties...
    property AvailablePageHeight[Measurement: TGmMeasurement]: Extended read GetAvailablePageHeight;
    property AvailablePageRect[Measurement: TGmMeasurement]: TGmRect read GetAvailablePageGmRect;
    property AvailablePageWidth[Measurement: TGmMeasurement]: Extended read GetAvailablePageWidth;
    property CurrentPage: TGmPage read GetCurrentPage;
    property CurrentPageNum: integer read GetCurrentPageNum write SetCurrentPageNum;
    property DateTokenFormat: string read GetDateFormat write SetDateFormat;
    property DragDrawShape: TGmDragDrawing read GetDragDrawShape write SetDragDrawShape;
    property DrawSelectedBorder: Boolean read FDrawSelectedBorder write FDrawSelectedBorder default True;
    property IsUpdating: Boolean read GetIsUpdating;
    property NumPages: integer read GetNumPages;
    property PageHeight[Measurement: TGmMeasurement]: Extended read GetPageHeight;
    property Pages[index: integer]: TGmPage read GetPage;
    property PageWidth[Measurement: TGmMeasurement]: Extended read GetPageWidth;
    property Panning: Boolean read FPanning;
    property ResourceTable: TObject read GetResourceTable;
    property ScratchCanvas: TCanvas read GetScratchCanvas;
    property TimeTokenFormat: string read GetTimeFormat write SetTimeFormat;
  published
    property Canvas;
    property Footer: TGmFooter read GetFooter write SetFooter;
    property GmPrinter: TGmPrinter read GetGmPrinter write SetPrinter;
    property Gutter: integer read GetGutter write SetGutter default 30;
    property Header: TGmHeader read GetHeader write SetHeader;
    property Margins: TGmMargins read GetMargins write SetMargins;
    property MaxZoom: integer read FMaxZoom write SetMaxZoom default DEFAULT_MAX_ZOOM;
    property MinZoom: integer read FMinZoom write SetMinZoom default DEFAULT_MIN_ZOOM;
    property Orientation: TGmOrientation read GetOrientation write SetOrientation default gmPortrait;
    property PageGrid: TGmPageGrid read FPageGrid write FPageGrid;
    property PagesPerSheet: TGmPagesPerSheet read GetPagesPerSheet write SetPagesPerSheet;
    property PaperSize: TGmPaperSize read GetPaperSize write SetPaperSize default A4;
    property Shadow: TGmShadow read FShadow write SetShadow;
    property Zoom: integer read GetZoom write SetZoom default 20;
    property ZoomIncrement: integer read FZoomIncrement write FZoomIncrement default DEFAULT_ZOOM_INC;
    property ZoomStyle: TGmZoomStyle read FZoomStyle write FZoomStyle default gmVariableZoom;
    // events...
    property AfterPrint: TNotifyEvent read FAfterPrint write FAfterPrint;
    property BeforeLoad: TGmBeforeLoadEvent read FBeforeLoad write FBeforeLoad;
    property BeforePrint: TNotifyEvent read FBeforePrint write FBeforePrint;
    property OnAbortPrint: TNotifyEvent read FOnAbortPrint write FOnAbortPrint;
    property OnClear: TNotifyEvent read FOnClear write FOnClear;
    property OnDragOver;
    property OnDragDrop;
    property OnDrawHeader: TGmDrawHeaderFooterEvent read FOnDrawHeader write FOnDrawHeader;
    property OnDrawFooter: TGmDrawHeaderFooterEvent read FOnDrawFooter write FOnDrawFooter;
    property OnEnter;
    property OnExit;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    {$IFDEF D4+}
    property OnMouseWheel;
    property OnMouseWheelUp;
    property OnMouseWheelDown;
    {$ENDIF}
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnNeedRichEdit: TGmNeedRichEditEvent read FOnNeedRichEdit write FOnNeedRichEdit;
    property OnNewPage: TNotifyEvent read FOnNewPage write FOnNewPage;
    property OnObjectMouseDown: TGmObjectMouseEvent read FOnObjectMouseDown write FOnObjectMouseDown;
    property OnOrientationChanged: TNotifyEvent read FOnOrientationChanged write FOnOrientationChanged;
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;
    property OnPageDragDrop: TGmPageDragDropEvent read FOnPageDragDrop write FOnPageDragDrop;
    property OnPageDragOver: TGmPageDragOverEvent read FOnPageDragOver write FOnPageDragOver;
    property OnPageMouseDown: TGmPageMouseEvent read FOnPageMouseDown write FOnPageMouseDown;
    property OnPageMouseMove: TGmPageMouseMoveEvent read FOnPageMouseMove write FOnPageMouseMove;
    property OnPageMouseUp: TGmPageMouseEvent read FOnPageMouseUp write FOnPageMouseUp;
    property OnPrintProgress: TGmPrintProgressEvent read FOnPrintProgress write FOnPrintProgress;
  end;

implementation

uses SysUtils, GmFuncs, GmObjects, GmStream;

{$R GmCursors.res}

//------------------------------------------------------------------------------

// *** TGmPreview ***

constructor TGmPreview.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPages := TGmPageList.Create;
  FPaper := TGmPaperImage.Create(Self);
  FPageGrid := TGmPageGrid.Create;
  FShadow := TGmShadow.Create;
  FRegisteredComponents := TList.Create;
  FSelectionPen := TPen.Create;
  Screen.Cursors[crZoomIn]  := LoadCursor(HInstance, 'ZoomIn');
  Screen.Cursors[crZoomOut] := LoadCursor(HInstance, 'ZoomOut');
  Width := 240;
  Height := 300;
  FPaper.Align := alClient;
  FPaper.Shadow := FShadow;
  FPaper.Margins := FPages.Margins;
  FPaper.Grid := FPageGrid;
  FPaper.Parent := Self;
  FUpdating := False;
  FPanning := False;
  FDrawSelectedBorder := True;
  FSelectionPen.Width := 1;
  FSelectionPen.Color := clRed;
  FMinZoom := DEFAULT_MIN_ZOOM;
  FMaxZoom := DEFAULT_MAX_ZOOM;
  FObjectDragging := False;
  FZoomIncrement := DEFAULT_ZOOM_INC;
  FZoomStyle := gmVariableZoom;
  FPages.OnNeedRichEdit := NeedRichEdit;
  FPages.OnNewPage := NewPageEvents;
  FPaper.OnPaintPage := PaintPage;
  EnablePaperMouseEvents;
  FPages.AddPage;
  CurrentPageNum := 1;
  FPaper.Page := FPages[1];
  Canvas := FPages.Canvas;
  FPages.OnOrientationChanged := DoOrientationChanged;
  FPages.OnPageChanged := DoPageContentChanged;
  FPages.OnPageCountChanged := DoPageCountChanged;
  FPages.OnPageNumChanged := DoPageNumChanged;
  FPages.OnHeaderFooterChanged := HeaderFooterChanged;
  FPages.GmPrinter.OnAbortPrint := DoAbortPrint;
  FPages.GmPrinter.AfterPrint := DoAfterPrint;
  FPages.GmPrinter.BeforePrint := DoBeforePrint;
  FPages.BeforeLoad := DoBeforeLoad;
  FPages.OnClear := DoClear;
  FPages.OnPageMarginsChanged := DoMarginsChanged;
  FPages.OnPaperSizeChanged := DoPaperSizeChanged;
  FPages.OnPrintProgress := DoPrintProgress;
  FPages.GmPrinter.OnChangePrinter := DoPrinterChanged;
  FPaper.OnMouseEnter := DoMouseEnter;
  FPaper.OnMouseLeave := DoMouseLeave;
end;

destructor TGmPreview.Destroy;
begin
  FPages.Free;
  FPaper.Free;
  FShadow.Free;
  FRegisteredComponents.Free;
  FSelectionPen.Free;
  FPageGrid.Free;
  inherited Destroy;
end;

function TGmPreview.FooterRect: TGmValueRect;
begin
  Result := FPages.FooterRect;
end;

function TGmPreview.GetFileVersion(AFileName: string): Extended;
var
  Values: TGmValueList;
begin
  // return the version of a TGmPreview which created the file referenced by
  // the AFileName paramater...
  Values := TGmValueList.Create;
  try
    Values.LoadFromFile(AFileName);
    Result := Values.ReadExtValue(C_V, 0);
  finally
    Values.Free;
  end;
end;

function TGmPreview.GetPageSize(Measurement: TGmMeasurement): TGmSize;
begin
  Result := ConvertGmSize(FPages.PageSizeInch, gmInches, Measurement);
end;

function TGmPreview.HeaderRect: TGmValueRect;
begin
  Result := FPages.HeaderRect;
end;

function TGmPreview.InsertPage(index: integer): TGmPage;
begin
  Result := FPages.InsertPage(index);
end;

function TGmPreview.NewPage: TGmPage;
begin
  Result := FPages.AddPage;
end;

function TGmPreview.GmObjectAtPos(x, y: Extended; Measurement: TGmMeasurement): TGmVisibleObject;
begin
  CurrentPage.ObjectAtPos(x, y, Measurement, Result);
end;

function TGmPreview.GmObjectRect(AObject: TGmVisibleObject): TRect;
var
  ARect: TRect;
  Data: TGmObjectDrawData;
begin
  if not Assigned(AObject) then Exit;
  Data.Page := CurrentPageNum;
  Data.NumPages := NumPages;
  Data.PpiX := SCREEN_PPI;
  Data.PpiY := SCREEN_PPI;
  ARect := GmRectPointsToRect(AObject.BoundingRect(Data));
  ARect := ScaleRect(ARect, Zoom/100);
  OffsetRect(ARect,
             (FPaper.PageRect.Left - HorzScrollBar.Position),
             (FPaper.PageRect.Top  - VertScrollBar.Position));
  ARect.Left := ARect.Left-1;
  ARect.Top := ARect.Top -1;
  Result := ARect;

end;

function TGmPreview.Tokenize(AText: string; APage: integer): string;
begin
  Result := GmFuncs.Tokenize(AText, APage, NumPages, DateTokenFormat, TimeTokenFormat);
end;

procedure TGmPreview.AddAssociatedComponent(AComponent: TComponent);
begin
  if FRegisteredComponents.IndexOf(AComponent) = -1 then
    FRegisteredComponents.Add(AComponent);
end;

procedure TGmPreview.RemoveAssociatedComponent(AComponent: TComponent);
begin
  if FRegisteredComponents.IndexOf(AComponent) <> -1 then
    FRegisteredComponents.Delete(FRegisteredComponents.IndexOf(AComponent));
end;

procedure TGmPreview.Assign(Source: TPersistent);
begin
  //
end;

procedure TGmPreview.BeginUpdate;
begin
  MessageToControls(GM_BEGINUPDATE, 0, 0);
  FPages.BeginUpdate;
  FPaper.BeginUpdate;
end;

procedure TGmPreview.CenterOnClick(x, y: integer);
var
  CenterPoint: TPoint;
begin
  // center the page on the X,Y coordinates when the scroll bars are visible...
  CenterPoint.X := Width div 2;
  CenterPoint.Y := Height div 2;
  HorzScrollBar.Position := (x - CenterPoint.X);
  VertScrollBar.Position := (y - CenterPoint.y);
end;

procedure TGmPreview.Clear;
begin
  FSelectedObject := nil;
  FPages.ClearPages;
end;

procedure TGmPreview.DeleteCurrentPage;
begin
  DeletePage(CurrentPageNum-1);
end;

procedure TGmPreview.DeletePage(index: integer);
begin
  FPages.DeletePage(index);
end;

procedure TGmPreview.DeleteSelectedGmObject;
var
  AObject: TGmBaseObject;
begin
  if Assigned(FSelectedObject) then
  begin
    AObject := FSelectedObject;
    FSelectedObject := nil;
    CurrentPage.DeleteGmObject(AObject);
  end;
end;

procedure TGmPreview.DragDrawCancel;
begin
  FPaper.DragDrawStop;
end;

procedure TGmPreview.DragDrawStart;
begin
  FPaper.DragDrawStart;
end;

procedure TGmPreview.DragDrawToCanvas;
var
  ARect: TGmRect;
begin
  if not FPaper.IsDragDrawing then Exit;
  DragDrawCancel;
  ARect := FPaper.DragDrawInchRect;
  if EqualGmPoints(ARect.TopLeft, ARect.BottomRight) then Exit;
  case FPaper.DragDrawShape of
    gmDragLine     : Canvas.Line(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, gmInches);
    gmDragEllipse  : Canvas.Ellipse(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, gmInches);
    gmDragRectangle: Canvas.Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom, gmInches);
  end;
end;

procedure TGmPreview.DragDrawZoom;
var
  Area: TRect;
  DragRect: TRect;
begin
  if not FPaper.IsDragDrawing then Exit;
  DragDrawCancel;
  DragRect := FPaper.DragDrawRect;
  Area.Left   := MinInt(DragRect.Left, DragRect.Right);
  Area.Top    := MinInt(DragRect.Top, DragRect.Bottom);
  Area.Right  := MaxInt(DragRect.Left, DragRect.Right);
  Area.Bottom := MaxInt(DragRect.Top, DragRect.Bottom);
  ZoomToArea(Area);
end;

procedure TGmPreview.DragGmObjectStart(AObject: TGmVisibleObject);
begin
  if (not Assigned(AObject)) or (AObject.AllowDrag = False) then Exit;
  FObjectDragging := True;
  FSelectedObject := AObject;
  FDragObjectStart := FMousePosInch;
  FDragObjectRect := GmObjectRect(FSelectedObject);
  FLastObjectRect := Rect(0,0,0,0);
  FPaper.Invalidate;
end;

procedure TGmPreview.DragGmObjectEnd;
var
  Offset: TGmPoint;
begin
  if not FObjectDragging then Exit;
  Offset.X := (FDragObjectStart.X - FMousePosInch.X);
  Offset.Y := (FDragObjectStart.Y - FMousePosInch.Y);
  FObjectDragging := False;
  if not Assigned(FSelectedObject) then Exit;
  FSelectedObject.OffsetObject(0-Offset.X, 0-Offset.Y, gmInches);
  FPaper.Invalidate;
  MessageToControls(GM_PAGE_CONTENT_CHANGED, 0, 0);
end;

procedure TGmPreview.EndUpdate;
begin
  FPages.EndUpdate;
  FPaper.EndUpdate;
  MessageToControls(GM_ENDUPDATE, 0, 0);
end;

procedure TGmPreview.FindText(AText: string; CaseSensative: Boolean; AList: TList);
begin
  FPages.FindText(AText, CaseSensative, AList);
end;

procedure TGmPreview.FirstPage;
begin
  FPages.CurrentPage := 1;
end;

procedure TGmPreview.FitHeight;
begin
  Zoom := Trunc(GetFitHeightScale * 100);
end;

procedure TGmPreview.FitWholePage;
begin
  Zoom := Trunc(MinFloat(GetFitWidthScale, GetFitHeightScale) * 100);
end;

procedure TGmPreview.FitWidth;
begin
  Zoom := Trunc(GetFitWidthScale * 100);
end;

procedure TGmPreview.LastPage;
begin
  FPages.CurrentPage := NumPages;
end;

procedure TGmPreview.LoadFromFile(AFilename: string);
var
  AFileStream: TFileStream;
begin
  try
    AFileStream := TFileStream.Create(AFileName, fmOpenRead);
    try
      LoadFromStream(AFileStream);
    finally
      AFileStream.Free;
    end;
  except
    // display an error!
  end;
end;

procedure TGmPreview.LoadFromStream(Stream: TStream);
begin
  FPages.LoadFromStream(Stream);
end;

procedure TGmPreview.NextPage;
begin
  FPages.CurrentPage := FPages.CurrentPage + 1;
end;

procedure TGmPreview.PaperSizes(AStrings: TStrings);
var
  ICount: TGmPaperSize;
begin
  AStrings.BeginUpdate;
  AStrings.Clear;
  for ICount := Low(TGmPaperSize) to High(TGmPaperSize) do
    AStrings.Add(PaperSizeToStr(ICount));
  AStrings.EndUpdate;
end;

procedure TGmPreview.PrevPage;
begin
  FPages.CurrentPage := FPages.CurrentPage - 1;
end;

procedure TGmPreview.Print;
begin
  PrintRange(1, NumPages);
end;

procedure TGmPreview.PrintCurrentPage;
begin
  FPages.PrintRange(CurrentPageNum, CurrentPageNum);
end;

procedure TGmPreview.PrintRange(APageFrom, APageTo: integer);
begin
  BeginUpdate;
  FPages.PrintRange(APageFrom, APageTo);
  EndUpdate;
end;

procedure TGmPreview.PrintToFile(AFileName: string);
begin
  FPages.PrintToFile(AFileName);
end;

procedure TGmPreview.SaveToFile(AFileName: string);
var
  AFileStream: TFileStream;
begin
  try
    AFileStream := TFileStream.Create(AFileName, fmCreate);
    try
      SaveToStream(AFileStream);
    finally
      AFileStream.Free;
    end;
  except
    // display an error!
  end;
end;

procedure TGmPreview.SaveToStream(Stream: TStream);
begin
  FPages.SaveToStream(Stream);
end;

procedure TGmPreview.ScrollToPosition(xPercent, yPercent: Extended);
begin
  HorzScrollBar.Position := Round((xPercent/100) * (HorzScrollBar.Range - ClientWidth));
  VertScrollBar.Position := Round((yPercent/100) * (VertScrollBar.Range - ClientHeight));
end;

procedure TGmPreview.SelectGmObject(AObject: TGmVisibleObject);
begin
  FSelectedObject := AObject;
  if FDrawSelectedBorder then Invalidate;
end;

procedure TGmPreview.SetCursor(ACursor: TGmCursor);
begin
  // change the preview page cursor...
  case ACursor of
    gmDefault   : Cursor := crDefault;
    gmZoomIn    : Cursor := crZoomIn;
    gmZoomOut   : Cursor := crZoomOut;
  end;
end;

procedure TGmPreview.SetCustomPageSize(AWidth, AHeight: Extended; Measurement: TGmMeasurement);
begin
  FPages.SetPageSize(AWidth, AHeight, Measurement);
end;

procedure TGmPreview.StartPanning;
begin
  if FPanning then Exit;
  FPanning := True;
  GetCursorPos(FPanningOrigin);
  FPanningOrigin := ScreenToClient(FPanningOrigin);
  FPanningScrollOrigin := Point(HorzScrollBar.Position, VertScrollBar.Position);
  Screen.Cursor := crHandPoint;
end;

procedure TGmPreview.StopPanning;
begin
  if not FPanning then Exit;
  FPanning := False;
  Screen.Cursor := crDefault;
end;

procedure TGmPreview.UsePrinterPageSize;
begin
  FPages.UsePrinterPageSize;
end;

procedure TGmPreview.ZoomIn;
var
  ICount: integer;
begin
  if FZoomStyle = gmFixedZoom then
  begin
    Zoom := Zoom + FZoomIncrement;
    Exit;
  end;
  for ICount := 0 to High(GM_VARIABLE_ZOOM) do
    if GM_VARIABLE_ZOOM[ICount] > Zoom then
    begin
      Zoom := GM_VARIABLE_ZOOM[ICount];
      Exit;
    end;
end;

procedure TGmPreview.ZoomOut;
var
  ICount: integer;
begin
  if FZoomStyle = gmFixedZoom then
  begin
    Zoom := Zoom - FZoomIncrement;
    Exit;
  end;
  for ICount := High(GM_VARIABLE_ZOOM) downto 0 do
    if GM_VARIABLE_ZOOM[ICount] < Zoom then
    begin
      Zoom := GM_VARIABLE_ZOOM[ICount];
      Exit;
    end;
end;

procedure TGmPreview.ReadData(Reader: TReader);
var
  AMargins: TStringList;
begin
  AMargins := TStringList.Create;
  try
    AMargins.CommaText := Reader.ReadString;
    FPages.Margins.Left.AsTwips := StrToInt(AMargins[0]);
    FPages.Margins.Top.AsTwips := StrToInt(AMargins[1]);
    FPages.Margins.Right.AsTwips := StrToInt(AMargins[2]);
    FPages.Margins.Bottom.AsTwips := StrToInt(AMargins[3]);
    if AMargins.Count = 4 then Exit;
    PenFromString(FPages.Margins.Pen, AMargins[4]);
    PenFromString(FPages.Margins.PrinterMarginPen, AMargins[5]);
  finally
    AMargins.Free;
  end;
end;

procedure TGmPreview.WriteData(Writer: TWriter);
var
  AMargins: TStringList;
begin
  AMargins := TStringList.Create;
  try
    AMargins.Add(IntToStr(FPages.Margins.Left.AsTwips));
    AMargins.Add(IntToStr(FPages.Margins.Top.AsTwips));
    AMargins.Add(IntToStr(FPages.Margins.Right.AsTwips));
    AMargins.Add(IntToStr(FPages.Margins.Bottom.AsTwips));
    AMargins.Add(PenToString(FPages.Margins.Pen));
    AMargins.Add(PenToString(FPages.Margins.PrinterMarginPen));
    Writer.WriteString(AMargins.CommaText);
  finally
    AMargins.Free;
  end;
end;

function TGmPreview.GetAvailablePageRect: TGmValueRect;
begin
  Result := FPages.AvailablePageRect;

end;

function TGmPreview.GetAvailablePageHeight(Measurement: TGmMeasurement): Extended;
var
  ARect: TGmRect;
begin
  ARect := GetAvailablePageRect.AsInchRect;
  Result := ConvertValue(ARect.Bottom - ARect.Top, gmInches, Measurement);
end;

function TGmPreview.GetAvailablePageGmRect(Measurement: TGmMeasurement): TGmRect;
begin
  Result := ConvertGmRect(GetAvailablePageRect.AsInchRect, gmInches, Measurement);
end;

function TGmPreview.GetAvailablePageWidth(Measurement: TGmMeasurement): Extended;
var
  ARect: TGmRect;
begin
  ARect := GetAvailablePageRect.AsInchRect;
  Result := ConvertValue(ARect.Right - ARect.Left, gmInches, Measurement);
end;

function TGmPreview.GetCurrentPage: TGmPage;
begin
  Result := FPages[CurrentPageNum];
end;

function TGmPreview.GetCurrentPageNum: integer;
begin
  Result := FPages.CurrentPage;
end;

function TGmPreview.GetDateFormat: string;
begin
  Result := GlobalDateTokenFormat;
end;

function TGmPreview.GetDragDrawShape: TGmDragDrawing;
begin
  Result := FPaper.DragDrawShape;
end;

function TGmPreview.GetFitHeightScale: Extended;
begin
  Result := ((Height-(FPaper.Gutters.Top + FPaper.Gutters.Bottom)-20)) / (CurrentPage.PageSize[gmInches].Height * SCREEN_PPI);
end;

function TGmPreview.GetFitWidthScale: Extended;
begin
  Result := ((Width-(FPaper.Gutters.Left + FPaper.Gutters.Right)-20)) / (CurrentPage.PageSize[gmInches].Width * SCREEN_PPI);
end;

function TGmPreview.GetFooter: TGmFooter;
begin
  Result := FPages.Footer;
end;

function TGmPreview.GetGmPrinter: TGmPrinter;
begin
  Result := FPages.GmPrinter;
end;

function TGmPreview.GetGutter: integer;
begin
  Result := FPaper.Gutters.Left;
end;

function TGmPreview.GetHeader: TGmHeader;
begin
  Result := FPages.Header;
end;

function TGmPreview.GetIsUpdating: Boolean;
begin
  Result := FPages.Updating;
end;

function TGmPreview.GetMargins: TGmMargins;
begin
  Result := FPages.Margins;
end;

function TGmPreview.GetNumPages: integer;
begin
  Result := FPages.Count;
end;


function TGmPreview.GetPagesPerSheet: TGmPagesPerSheet;
begin
  Result := FPages.PagesPerSheet;
end;

function TGmPreview.GetOrientation: TGmOrientation;
begin
  Result := FPages.Orientation;
end;

function TGmPreview.GetPage(index: integer): TGmPage;
begin
  Result := FPages[index];
end;

function TGmPreview.GetPageHeight(Measurement: TGmMeasurement): Extended;
begin
  Result := CurrentPage.PageSize[Measurement].Height;
end;

function TGmPreview.GetPageWidth(Measurement: TGmMeasurement): Extended;
begin
  Result := CurrentPage.PageSize[Measurement].Width;
end;

function TGmPreview.GetResourceTable: TObject;
begin
  Result := FPages.ResourceTable;
end;

function TGmPreview.GetScratchCanvas: TCanvas;
begin
  Result := FPaper.Canvas;
  Result.Brush.Style := bsClear;
end;

function TGmPreview.GetTimeFormat: string;
begin
  Result := GlobalTimeTokenFormat;
end;

function TGmPreview.GetZoom: integer;
begin
  Result := FPaper.Zoom;
end;

procedure TGmPreview.DoAbortPrint(Sender: TObject);
begin
  if Assigned(FOnAbortPrint) then FOnAbortPrint(Self);
end;

procedure TGmPreview.DoAfterPrint(Sender: TObject);
begin
  if Assigned(FAfterPrint) then FAfterPrint(Self);
end;

procedure TGmPreview.DoBeforeLoad(Sender: TObject; Version: Extended; var LoadFile: Boolean);
begin
  if Assigned(FBeforeLoad) then FBeforeLoad(Self, Version, LoadFile);
end;

procedure TGmPreview.DoBeforePrint(Sender: TObject);
begin
  if Assigned(FBeforePrint) then FBeforePrint(Self);
end;

procedure TGmPreview.DoClear(Sender: TObject);
begin
  if Assigned(FOnClear) then FOnClear(Self);
end;

procedure TGmPreview.DoPrintProgress(Sender: TObject; Printed, Total: integer);
begin
  if Assigned(FOnPrintProgress) then FOnPrintProgress(Self, Printed, Total);
end;

procedure TGmPreview.DoVerticalScroll(var Msg: TMessage);
begin
  inherited;
  invalidate;
end;

procedure TGmPreview.DoMouseEnter(Sender: TObject);
begin
  if Assigned(OnMouseEnter) then OnMouseEnter(Self);
end;

procedure TGmPreview.DoMouseLeave(Sender: TObject);
begin
  if FPanning then StopPanning;
  if Assigned(OnMouseLeave) then OnMouseLeave(Self);
end;

procedure TGmPreview.NewPageEvents(Sender: TObject);
begin
  if Assigned(FOnNewPage) then FOnNewPage(Self);
  if Assigned(FOnDrawHeader) then FOnDrawHeader(Self, HeaderRect, Canvas);
  if Assigned(FOnDrawFooter) then FOnDrawFooter(Self, FooterRect, Canvas);
end;

procedure TGmPreview.EnablePaperMouseEvents;
begin
  FPaper.OnMouseDown := DoMouseDown;
  FPaper.OnMouseMove := DoMouseMove;
  FPaper.OnMouseUp   := DoMouseUp;
  FPaper.OnPageMouseDown := DoPageMouseDown;
  FPaper.OnPageMouseMove := DoPageMouseMove;
  FPaper.OnPageMouseUp := DoPageMouseUp;

  FPaper.OnPageDragDrop := DoPageDragDrop;
  FPaper.OnPageDragOver := DoPageDragOver;
end;

procedure TGmPreview.HeaderFooterChanged(Sender: TObject);
begin
  Invalidate;
  MessageToControls(GM_HEADERFOOTER_CHANGED, 0, 0);
end;

procedure TGmPreview.LoadScrollPos;
begin
  ScrollToPosition(FScrollPos.X, FScrollPos.Y);
end;

procedure TGmPreview.MessageToControls(AMessage: integer; Param1, Param2: integer);
var
  ICount: integer;
  AComponent: TComponent;
begin
  // broadcast a message to all associated components...
  if (not FPages.Updating) then
  begin
    for ICount := 0 to FRegisteredComponents.Count-1 do
    begin
      AComponent := FRegisteredComponents[ICount];
      if (AComponent is TWinControl) and (AComponent.HasParent) then
        SendMessage((AComponent as TWinControl).Handle, AMessage, Param1, Param2);
    end;
  end;
end;

procedure TGmPreview.NeedRichEdit(Sender: TObject; var ARichEdit: TCustomMemo);
begin
  if Assigned(FOnNeedRichEdit) then FOnNeedRichEdit(Self, ARichEdit);
end;

procedure TGmPreview.SaveScrollPos;
begin
  FScrollPos := GmPoint(0, 0);
  if (HorzScrollBar.Range-ClientWidth) > 0 then
    FScrollPos.X := 100 * (HorzScrollBar.Position / (HorzScrollBar.Range-ClientWidth));
  if (VertScrollBar.Range-ClientHeight) > 0 then
    FScrollPos.Y := 100 * (VertScrollBar.Position / (VertScrollBar.Range-ClientHeight));
end;

procedure TGmPreview.SetCurrentPageNum(Value: integer);
begin
  FPages.CurrentPage := Value;
end;

procedure TGmPreview.SetDateFormat(Value: string);
begin
  GlobalDateTokenFormat := Value;
end;

procedure TGmPreview.SetDragDrawShape(Value: TGmDragDrawing);
begin
  FPaper.DragDrawShape := Value;
end;

procedure TGmPreview.SetFooter(Value: TGmFooter);
begin
  FPages.Footer.Assign(Value);
end;

procedure TGmPreview.SetGutter(Value: integer);
begin
  FPaper.Gutters := Rect(Value, Value, Value, Value);
end;

procedure TGmPreview.SetHeader(Value: TGmHeader);
begin
 FPages.Header.Assign(Value);
end;

procedure TGmPreview.SetMargins(Value: TGmMargins);
begin
  FPages.Margins.Assign(Value);
end;

procedure TGmPreview.SetMaxZoom(Value: integer);
begin
  if FMaxZoom = Value then Exit;
  if FMaxZoom < FMinZoom then
    FMaxZoom := FMinZoom
  else
    FMaxZoom := Value;
  if Zoom > FMaxZoom then Zoom := FMaxZoom;
end;

procedure TGmPreview.SetMinZoom(Value: integer);
begin
  if FMinZoom = Value then Exit;
  if FMinZoom > FMaxZoom then
    FMinZoom := FMaxZoom
  else
    FMinZoom := Value;
  if Zoom < FMinZoom then Zoom := FMinZoom;
end;

procedure TGmPreview.SetOrientation(Value: TGmOrientation);
begin
  FPaper.BeginUpdate;
  FPages.Orientation := Value;
  FPaper.EndUpdate;
  UpdateScrollBars;
end;

procedure TGmPreview.SetPagesPerSheet(Value: TGmPagesPerSheet);
begin
  FPages.PagesPerSheet := Value;
  MessageToControls(GM_MULTIPAGE_CHANGED, 0, 0);
end;

procedure TGmPreview.SetShadow(Value: TGmShadow);
begin
  FShadow.Assign(Value);
end;

procedure TGmPreview.SetTimeFormat(Value: string);
begin
  GlobalTimeTokenFormat := Value;
end;

procedure TGmPreview.SetZoom(Value: integer);
begin
  if (Value > FMaxZoom) then Value := FMaxZoom;
  if (Value < FMinZoom) then Value := FMinZoom;
  if FPaper.Zoom = Value then Exit;
  SaveScrollPos;
  try
    FPaper.Zoom := Value;
    UpdateScrollBars;
    FPaper.BeginUpdate;
    FPaper.EndUpdate;
  finally
    LoadScrollPos;
  end;
end;

procedure TGmPreview.UpdateScrollBars;
begin
  if FUpdating then Exit;
  HorzScrollBar.Range := Round(FPaper.PageExtent[SCREEN_PPI].cx) + (FPaper.Gutters.Left + FPaper.Gutters.Right);
  VertScrollBar.Range := Round(FPaper.PageExtent[SCREEN_PPI].cy) + (FPaper.Gutters.Top + FPaper.Gutters.Bottom);
  Realign;
  Invalidate;
end;

procedure TGmPreview.ZoomToArea(ARect: TRect);
var
  BoxSize: TSize;
  InchBoxOrigin: TGmPoint;
  PercentOfClient: TGmPoint;
  ChangeFraction: Extended;
  ActualChangeFraction: Extended;
  Adjust: TPoint;
  LastZoom: integer;
  CenterPtInch: TGmPoint;
  InchRect: TGmRect;
begin
  BoxSize.cx := ARect.Right - ARect.Left;
  BoxSize.cy := ARect.Bottom - ARect.Top;
  if (BoxSize.cx = 0) or (BoxSize.cy = 0) then Exit;
  InchRect := FPaper.DragDrawInchRect;
  PercentOfClient.x := (BoxSize.cx) / (ClientWidth);
  PercentOfClient.y := (BoxSize.cy) / (ClientHeight);
  ChangeFraction := MaxFloat(PercentOfClient.x, PercentOfClient.y);
  LastZoom := Zoom;
  Zoom := Trunc(Zoom / ChangeFraction);
  ActualChangeFraction := LastZoom / Zoom;
  with InchRect do
  begin
    CenterPtInch.X := (Right + Left) / 2;
    CenterPtInch.Y := (Bottom + Top) / 2;
    InchBoxOrigin.X := MinFloat(Left, Right);
    InchBoxOrigin.Y := MinFloat(Top, Bottom);
  end;
  BoxSize.cx := Round(BoxSize.cx / ActualChangeFraction);
  BoxSize.cy := Round(BoxSize.cy / ActualChangeFraction);
  Adjust.X := (ClientWidth - BoxSize.cx) div 2;
  Adjust.Y := (ClientHeight - BoxSize.cy) div 2;

  HorzScrollBar.Position := FPaper.Gutters.Left + Round((InchBoxOrigin.X * SCREEN_PPI) * (Zoom / 100)) - Adjust.X;
  VertScrollBar.Position := FPaper.Gutters.Top + Round((InchBoxOrigin.Y * SCREEN_PPI) * (Zoom / 100)) - Adjust.Y;
end;

procedure TGmPreview.CMMouseLeave(var Message: TMessage);
begin
  StopPanning;
end;

procedure TGmPreview.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineProperty('MarginValues', ReadData, WriteData, True);
end;

procedure TGmPreview.DoDragDrop(Sender: TObject; Source: TObject; X, Y: integer);
begin
  if Assigned(OnDragDrop) then OnDragDrop(Self, Source, X, Y);
end;

procedure TGmPreview.DoDragOver(Sender, Source: TObject; X, Y: integer; State: TDragState; var Accept: Boolean);
begin
  if Assigned(OnDragOver) then OnDragOver(Self, Source, X, Y, State, Accept);
end;

procedure TGmPreview.DoHorizontalScroll(var Msg: TMessage);
begin
  inherited;
  invalidate;
end;

procedure TGmPreview.DoMarginsChanged(Sender: TObject);
begin
  FPaper.Invalidate;
  MessageToControls(GM_HEADERFOOTER_CHANGED, 0, 0);
end;

procedure TGmPreview.DoMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  SetFocus;
  FMouseDownPoint := Point(X, Y);
  if Assigned(OnMouseDown) then OnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TGmPreview.DoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  XyChange: TPoint;
begin
  if Assigned(OnMouseMove) then OnMouseMove(Self, Shift, X, Y);
  if FPanning then
  begin
    GetCursorPos(XyChange);
    XyChange := ScreenToClient(XyChange);
    XyChange.X := (FPanningOrigin.X - XyChange.X);
    XyChange.Y := (FPanningOrigin.Y - XyChange.Y);
    HorzScrollBar.Position := FPanningScrollOrigin.X + XyChange.X;
    VertScrollBar.Position := FPanningScrollOrigin.Y + XyChange.Y;
  end;
  if (FObjectDragging) and (Assigned(FSelectedObject)) then
  begin
    ScratchCanvas.Brush.Style := bsClear;
    ScratchCanvas.Pen.Mode := pmNot;
    ScratchCanvas.Pen.Style := psDot;
    ScratchCanvas.Pen.Width := 1;
    FDragObjectRect := GmObjectRect(FSelectedObject);
    OffsetRect(FDragObjectRect, HorzScrollBar.Position, VertScrollBar.Position);
    GmDrawRect(ScratchCanvas, FDragObjectRect);
    OffsetRect(FDragObjectRect,
               (X - FMouseDownPoint.X),
               (Y - FMouseDownPoint.Y));

    GmDrawRect(ScratchCanvas, FDragObjectRect);
    FLastObjectRect := FDragObjectRect;
  end;
end;

procedure TGmPreview.DoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FPanning then StopPanning;
  if FObjectDragging then DragGmObjectEnd;
  if Assigned(OnMouseUp) then OnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TGmPreview.DoOrientationChanged(Sender: TObject);
begin
  MessageToControls(GM_ORIENTATION_CHANGED, 0, 0);
  Invalidate;
  if Assigned(FOnOrientationChanged) then FOnOrientationChanged(Self);
end;

procedure TGmPreview.DoPageContentChanged(Sender: TObject);
begin
  FPaper.Page := FPages[FPages.CurrentPage];
  UpdateScrollBars;
  MessageToControls(GM_PAGE_CONTENT_CHANGED, 0, 0);
end;

procedure TGmPreview.DoPageCountChanged(Sender: TObject);
begin
  MessageToControls(GM_PAGE_COUNT_CHANGED, 0, 0);
end;

procedure TGmPreview.DoPageNumChanged(Sender: TObject);
begin
  FPaper.Page := CurrentPage;
  SelectGmObject(nil);
  if Assigned(FOnPageChanged) then FOnPageChanged(Self);
  MessageToControls(GM_PAGE_NUM_CHANGED, 0, 0);
end;

procedure TGmPreview.DoPageDragDrop(Sender: TObject; Source: TObject; X, Y: TGmValue);
begin
  if Assigned(FOnPageDragDrop) then FOnPageDragDrop(Self, Source, X, Y);
end;

procedure TGmPreview.DoPageDragOver(Sender, Source: TObject; X, Y: TGmValue; State: TDragState; var Accept: Boolean);
begin
  if Assigned(FOnPageDragOver) then FOnPageDragOver(Self, Source, X, Y, State, Accept);
end;

procedure TGmPreview.DoPageMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: TGmValue);
var
  AObject: TGmVisibleObject;
begin
  if Assigned(FOnPageMouseDown) then FOnPageMouseDown(Self, Button, Shift, X, Y);
  if Assigned(FOnObjectMouseDown) then
  begin
    AObject := GmObjectAtPos(X.AsInches, Y.AsInches, gmInches);
    if Assigned(AObject) then
      FOnObjectMouseDown(Self, Button, Shift, X, Y, AObject);
  end;
end;

procedure TGmPreview.DoPageMouseMove(Sender: TObject; Shift: TShiftState; X, Y: TGmValue);
begin
  FMousePosInch := GmPoint(X.AsInches, Y.AsInches);
  if Assigned(FOnPageMouseMove) then FOnPageMouseMove(Self, Shift, X, Y);
end;

procedure TGmPreview.DoPageMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: TGmValue);
begin
  if Assigned(FOnPageMouseUp) then FOnPageMouseUp(Self, Button, Shift, X, Y);
end;

procedure TGmPreview.DoPaperSizeChanged(Sender: TObject);
begin
  FPaper.Page := CurrentPage;
  MessageToControls(GM_PAPERSIZE_CHANGED, 0, 0);
end;

procedure TGmPreview.DoPrinterChanged(Sender: TObject);
begin
  MessageToControls(GM_PRINTER_CHANGED, 0, 0);
  Invalidate;
end;

procedure TGmPreview.PaintPage(Sender: TObject);
var
  BoundingRect: TRect;
  ExpandRect: integer;
begin
  if (Assigned(FSelectedObject)) and (FDrawSelectedBorder) then
  begin
    ScratchCanvas.Pen.Assign(FSelectionPen);
    BoundingRect := GmObjectRect(FSelectedObject);
    ExpandRect := Round(10 * (Zoom / 100));
    InflateRect(BoundingRect, ExpandRect, ExpandRect);
    BoundingRect.Right := BoundingRect.Right + 1;
    BoundingRect.Bottom := BoundingRect.Bottom + 1;
    GmDrawRect(ScratchCanvas, BoundingRect);
  end;
end;

procedure TGmPreview.WMNCHitTest(var Message: TMessage);
begin
  DefaultHandler(Message);
end;

procedure TGmPreview.WMSize(var Message: TMessage);
begin
  inherited;
  UpdateScrollBars;
end;

{$IFDEF D4+}

function TGmPreview.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; // Bieringer
  MousePos: TPoint): Boolean;
var
  Scrollbar: TControlScrollBar;
begin
  Scrollbar := nil;
  if VertScrollBar.IsScrollBarVisible then
    Scrollbar := VertScrollBar
  else
  if HorzScrollBar.IsScrollBarVisible then
    Scrollbar := HorzScrollBar;
  if Scrollbar <> nil then
  begin
    if WheelDelta > 0 then
      Scrollbar.Position := Scrollbar.Position - Scrollbar.Increment
    else
      Scrollbar.Position := Scrollbar.Position + Scrollbar.Increment;
  end;
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
end;

{$ENDIF}

procedure TGmPreview.KeyDown(var Key: Word; Shift: TShiftState); // Bieringer
var Scrollbar: TControlScrollBar;
begin
  {$IFDEF D4+}
  if VertScrollBar.IsScrollBarVisible then
    Scrollbar := VertScrollBar
  else
  if HorzScrollBar.IsScrollBarVisible then
    Scrollbar := HorzScrollBar
  else
    Exit;
  {$ELSE}
  if VertScrollBar.Range > ClientHeight then
    Scrollbar := VertScrollBar
  else
  if HorzScrollBar.Range > ClientWidth then
    Scrollbar := HorzScrollBar
  else
    Exit;
  {$ENDIF}
  case Key of
    VK_PRIOR: Scrollbar.Position := Scrollbar.Position - 10 * ScrollBar.Increment;
    VK_NEXT:  Scrollbar.Position := Scrollbar.Position + 10 * ScrollBar.Increment;
    VK_END:   begin  // right-bottom-edge
                Perform(WM_VSCROLL, SB_BOTTOM, 0);
                Perform(WM_HSCROLL, SB_RIGHT, 0);
              end;
    VK_HOME:  begin // left-top-edge
                Perform(WM_VSCROLL, SB_TOP, 0);
                Perform(WM_HSCROLL, SB_LEFT, 0);
              end;
    // The VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT only raised in combination with the key <ALT> or <ALTGR>.
    // By only press the keys (VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT) the focus is changed to the next control.
    VK_UP:    Perform(WM_VSCROLL, SB_LINEUP, 0);
    VK_DOWN:  Perform(WM_VSCROLL, SB_LINEDOWN, 0);
    VK_LEFT:  Perform(WM_HSCROLL, SB_LINELEFT, 0);
    VK_RIGHT: Perform(WM_HSCROLL, SB_LINERIGHT, 0);
  end;
end;

procedure TGmPreview.Loaded;
begin
  NewPageEvents(Self);
  inherited;
end;

function TGmPreview.GetPaperSize: TGmPaperSize;
begin
  Result := FPages.PaperSize;
end;

procedure TGmPreview.SetPaperSize(Value: TGmPaperSize);
begin
  FPages.PaperSize := Value;
end;

procedure TGmPreview.SetPrinter(APrinter: TGmPrinter);
begin

end;

end.
