{******************************************************************************}
{                                                                              }
{                               GmClasses.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmClasses;

interface

uses Windows, Classes, GmTypes, Graphics, ExtCtrls, Forms, Controls,
  GmResource, GmStream, StdCtrls, Messages;

{$I GMPS.INC}

type
  //----------------------------------------------------------------------------

  TGmValue = class;

  // *** TGmComponent ***

  TGmNewPageEvent = procedure (Sender: TObject; var ATopMargin, ABottomMargin: TGmValue) of object;

  TGmComponent = class(TGmCustomComponent)
  private
    function GetAbout: string;
    function GetVersion: Extended;
    procedure SetAbout(const Value: string);
  public
    property Version: Extended read GetVersion;
  published
    property About: string read GetAbout write SetAbout;
  end;

  //----------------------------------------------------------------------------

  // *** TGmScrollingWinControl ***

  TGmScrollingWinControl = class(TGmCustomPageControl)
  private
    FBorderStyle: TBorderStyle;
    function GetAbout: string;
    function GetVersion: Extended;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetAbout(const Value: string);
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Version: Extended read GetVersion;
  published
    property About: string read GetAbout write SetAbout;
    {$IFDEF D4+}
    property Anchors;
    property Constraints;
    property DoubleBuffered default True;
    {$ENDIF}
    property Align;
    property AutoScroll;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Color default $C0C0C0;
    property Ctl3D;
    property Enabled;
    property Hint;
    property ParentColor default False;
    property ShowHint;
    property TabOrder;
    property Tag;
    property Visible;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPanel ***

  TGmWinControl = class(TGmCustomWinControl)
  private
    FBorderStyle: TBorderStyle;
    function GetAbout: string;
    function GetVersion: Extended;
    procedure SetAbout(const Value: string);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Version: Extended read GetVersion;
  published
    property About: string read GetAbout write SetAbout;
    {$IFDEF D4+}
    property Anchors;
    property Constraints;
    {$ENDIF}
    property Align;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle;
    property Color default $C0C0C0;
    property Ctl3D;
    property Hint;
    property ParentColor default False;
    property ShowHint;
    property TabOrder;
    property Visible;
  end;

  //----------------------------------------------------------------------------

  TGmComboBox = class(TGmCustomComboBox)
  private
    function GetAbout: string;
    function GetVersion: Extended;
    procedure SetAbout(const Value: string);
  public
    property Version: Extended read GetVersion;
  published
    property About: string read GetAbout write SetAbout;
    property BevelEdges;
    property BevelInner;
    property BevelKind default bkNone;
    property BevelOuter;
    property Anchors;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    // events...
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDropDown;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    {$IFDEF D7+}
    property OnSelect;
    {$ENDIF}
    property OnStartDock;
    property OnStartDrag;
    property Items;
  end;
  //----------------------------------------------------------------------------

  // forward declarations...

  //TGmHeaderFooter = class;
  TGmMargins = class;
  TGmMarginValues = class;

  TGmPageDragDropEvent     = procedure(Sender, Source: TObject;  X, Y: TGmValue) of object;
  TGmPageDragOverEvent     = procedure(Sender, Source: TObject; X, Y: TGmValue; State: TDragState; var Accept: Boolean) of object;
  TGmPageMouseEvent        = procedure(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: TGmValue) of object;
  TGmPageMouseMoveEvent    = procedure(Sender: TObject; Shift: TShiftState; X, Y: TGmValue) of object;

  //----------------------------------------------------------------------------

  // *** TGmValue ***

  TGmValue = class(TPersistent)
  private
    FInches: Extended;
    // events...
    FOnChange: TNotifyEvent;
    function GetAsCentimeters: Extended;
    function GetAsGmUnits: integer;
    function GetAsMillimeters: Extended;
    function GetAsPixels(Ppi: integer): integer;
    function GetAsTwips: integer;
    function GetGmValue(Measurement: TGmMeasurement): Extended;
    procedure Changed;
    procedure SetAsCentimeters(Value: Extended);
    procedure SetAsGmUnits(Value: integer);
    procedure SetAsInches(Value: Extended);
    procedure SetAsMillimeters(Value: Extended);
    procedure SetAsPixels(Ppi: integer; Value: integer);
    procedure SetAsTwips(Value: integer);
    procedure SetGmValue(Measurement: TGmMeasurement; Value: Extended);
  public
    constructor Create(const AChangeEvent: TNotifyEvent = nil);
    constructor CreateValue(Value: Extended; Measurement: TGmMeasurement);
    procedure Assign(Source: TPersistent); override;
    property AsCentimeters: Extended read GetAsCentimeters write SetAsCentimeters;
    property AsGmValue[Measurement: TGmMeasurement]: Extended read GetGmValue write SetGmValue;
    property AsGmUnits: integer read GetAsGmUnits write SetAsGmUnits;
    property AsInches: Extended read FInches write SetAsInches;
    property AsMillimeters: Extended read GetAsMillimeters write SetAsMillimeters;
    property AsPixels[Ppi: integer]: integer read GetAsPixels write SetAsPixels;
    property AsTwips: integer read GetAsTwips write SetAsTwips;
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TGmCustomValueSize = class(TPersistent)
  protected
    FHeight: TGmValue;
    FWidth: TGmValue;
    // events...
    FOnChange: TNotifyEvent;
    procedure ValueChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TGmValueSize = class(TGmCustomValueSize)
  public
    property Height: TGmValue read FHeight;
    property Width: TGmValue read FWidth;
  end;

  TGmValuePoint = class(TGmCustomValueSize)
  public
    property X: TGmValue read FHeight;
    property Y: TGmValue read FWidth;
  end;

  TGmValueRect = class(TPersistent)
  private
    FTopLeft: TGmValuePoint;
    FBottomRight: TGmValuePoint;
    function GetAsInchRect: TGmRect;
    function GetValue(index: integer): TGmValue;
    procedure SetAsInchRect(Value: TGmRect);
    procedure SetValue(index: integer; Value: TGmValue);
  public
    constructor Create;
    destructor Destroy; override;
    property AsInchRect: TGmRect read GetAsInchRect write SetAsInchRect;
    property Left: TGmValue index 1 read GetValue write SetValue;
    property Top: TGmValue index 2 read GetValue write SetValue;
    property Right: TGmValue index 3 read GetValue write SetValue;
    property Bottom: TGmValue index 4 read GetValue write SetValue;
  end;

  //----------------------------------------------------------------------------

  // *** TGmBaseObject ***

  TGmBaseObject = class(TPersistent)
  private
    FObjectID: integer;
    FPrintThisObject: Boolean;
    FResourceTable: TGmResourceTable;
    FTag: integer;
    FUpdating: Boolean;
    // events...
    FOnChange: TNotifyEvent;
  protected
    function GetObjectID: integer; virtual; abstract;
    procedure AssignTo(Source: TPersistent); override;
    procedure Changed; virtual;
    procedure DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData); virtual;
    procedure LoadFromValueList(Values: TGmValueList); virtual;
    procedure SaveToValueList(Values: TGmValueList); virtual;
  public
    constructor Create(AResourceTable: TGmResourceTable); virtual;
    //procedure Assign(Source: TPersistent); override;
    procedure Draw(ACanvas: TCanvas; var Data: TGmObjectDrawData);
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure OffsetObject(x, y: Extended; Measurement: TGmMeasurement); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    property ObjectID: integer read FObjectID;
    property PrintThisObject: Boolean read FPrintThisObject write FPrintThisObject default True;
    property ResourceTable: TGmResourceTable read FResourceTable;
    property Tag: integer read FTag write FTag default -1;
    property Updating: Boolean read FUpdating write FUpdating default False;
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;


  //----------------------------------------------------------------------------

  // *** TGmVisibleObject ***

  TGmChangeObjectLevel = procedure(Sender: TObject; LevelChange: TGmArrangeObject) of object;

  TGmVisibleObject = class(TGmBaseObject)
  private
    FLevelChange: TGmChangeObjectLevel;
    FAllowDrag: Boolean;
  protected
    procedure AssignTo(Source: TPersistent); override;
  public
    constructor Create(AResourceTable: TGmResourceTable); override;
    function BoundingRect(Data: TGmObjectDrawData): TGmRectPoints; virtual;
    procedure Arrange(ChangeLevel: TGmArrangeObject);
    property AllowDrag: Boolean read FAllowDrag write FAllowDrag default True;
    // events...
    property OnLevelChange: TGmChangeObjectLevel read FLevelChange write FLevelChange;
  end;


  //----------------------------------------------------------------------------

  // *** TGmBaseObjectList ***

  TGmBaseObjectList = class(TGmObjectList)
  private
    FOnChanged: TNotifyEvent;
    function GetObject(index: integer): TGmBaseObject;
    procedure SetObject(index: integer; AObject: TGmBaseObject);
    procedure Changed(Sender: TObject);
  public
    constructor Create;
    procedure AddObject(AObject: TGmBaseObject);
    procedure InsertObject(Index: integer; AObject: TGmBaseObject);
    property GmObject[index: integer]: TGmBaseObject read GetObject write SetObject;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;


  //----------------------------------------------------------------------------

  // *** TGmPageRtfInfo ***

  TGmPageRtfInfo = class(TObject)
  private
    FOffset: TPoint;
    FMargins: TGmValueRect;
    FRichEdit: TCustomMemo;
    FResourceTable: TObject;
    FWrapText: Boolean;
    // events...
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure SetMargins(Value: TGmValueRect);
    procedure SetOffset(Value: TPoint);
    procedure SetRichEdit(ARichEdit: TCustomMemo);
  public
    constructor Create(AResourceTable: TObject);
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromValueList(Values: TGmValueList);
    procedure SaveToValueList(Values: TGmValueList);
    property Margins: TGmValueRect read FMargins write SetMargins;
    property Offset: TPoint read FOffset write SetOffset;
    property ResourceTable: TObject read FResourceTable write FResourceTable;
    property RichEdit: TCustomMemo read FRichEdit write SetRichEdit;
    property WrapText: Boolean read FWrapText write FWrapText;
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  //----------------------------------------------------------------------------

  // *** TGmMargins ***

  TGmMargins = class(TPersistent)
  private
    FClipMargins: Boolean;
    FLeft: TGmValue;
    FTop: TGmValue;
    FRight: TGmValue;
    FBottom: TGmValue;
    FPen: TPen;
    FDrawPpi: integer;
    FPrinter: TObject;
    FPrinterMarginPen: TPen;
    FShowPrinterMargins: Boolean;
    FUpdating: Boolean;
    FUsePrinterMargins: Boolean;
    FValues: TGmMarginValues;
    FVisible: Boolean;
    // events...
    FOnChange: TNotifyEvent;
    function GetAsInches: TGmRect;
    function GetPrinterMargins(Measurement: TGmMeasurement; AOrientation: TGmOrientation): TGmRect;
    procedure Changed(Sender: TObject);
    procedure Clip(APageSize: TGmSize; AOrientation: TGmOrientation; ACanvas: TCanvas; Ppi: integer);
    procedure Draw(APageSize: TGmSize; AOrientation: TGmOrientation; ACanvas: TCanvas; Ppi: integer);
    procedure SetAsInches(ARect: TGmRect);
    procedure SetClipMargins(Value: Boolean);
    procedure SetPen(Value: TPen);
    procedure SetPrinterMarginPen(Value: TPen);
    procedure SetShowPrinterMargins(Value: Boolean);
    procedure SetUsePrinterMargins(Value: Boolean);
    procedure SetVisible(Value: Boolean);
  public
    constructor Create(GmPrinter: TObject);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property AsInches: TGmRect read GetAsInches write SetAsInches;
    property Left: TGmValue read FLeft;
    property Top: TGmValue read FTop;
    property Right: TGmValue read FRight;
    property Bottom: TGmValue read FBottom;
    property PrinterMargins[Measurement: TGmMeasurement; Orientation: TGmOrientation]: TGmRect read GetPrinterMargins;
    property UsePrinterMargins: Boolean read FUsePrinterMargins write SetUsePrinterMargins;
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property ClipMargins: Boolean read FClipMargins write SetClipMargins default False;
    property Pen: TPen read FPen write SetPen;
    property PrinterMarginPen: TPen read FPrinterMarginPen write SetPrinterMarginPen;
    property ShowPrinterMargins: Boolean read FShowPrinterMargins write SetShowPrinterMargins default False;
    property Values: TGmMarginValues read FValues write FValues;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  //----------------------------------------------------------------------------

  // *** TGmMarginValues ***

  TGmMarginValues = class(TPersistent)
  private
    FMargins: TGmMargins;
    FMeasurement: TGmMeasurement;
    function GetValue(index: integer): Single;
    procedure SetMeasurement(Value: TGmMeasurement);
    procedure SetValue(index: integer; Value: Single);
  public
    constructor Create(AMargins: TGmMargins);
  published
    property Left: Single   index 0 read GetValue write SetValue;
    property Top: Single    index 1 read GetValue write SetValue;
    property Right: Single  index 2 read GetValue write SetValue;
    property Bottom: Single index 3 read GetValue write SetValue;
    property ValueMeasurement: TGmMeasurement read FMeasurement write SetMeasurement default gmInches;
  end;

  //----------------------------------------------------------------------------

  // *** TGmShadow ***

  TGmShadow = class(TPersistent)
  private
    FColor: TColor;
    FWidth: integer;
    FVisible: Boolean;
    // events...
    FOnChange: TNotifyEvent;
    procedure Changed;
    procedure Draw(ACanvas: TCanvas; APageRect: TRect);
    procedure SetColor(Value: TColor);
    procedure SetVisible(Value: Boolean);
    procedure SetWidth(Value: integer);
    // events...
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property Color: TColor read FColor write SetColor default clBlack;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Width: integer read FWidth write SetWidth default 3;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPageGrid ***

  TGmPageGrid = class(TPersistent)
  private
    FGridPen: TPen;
    FGridStyle: TGmGridStyle;
    FGridInterval: TGmValue;
    FOnChange: TNotifyEvent;
    procedure Changed(Sender: TObject);
    procedure DrawToCanvas(Canvas: TCanvas; APageSize: TGmSize; Ppi: integer);
    procedure SetGridStyle(const Value: TGmGridStyle);
    procedure SetGridPen(Value: TPen);
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  public
    constructor Create;
    destructor Destroy; override;
    property Interval: TGmValue read FGridInterval;
  published
    property GridStyle: TGmGridStyle read FGridStyle write SetGridStyle default gmNoGrid;
    property GridPen: TPen read FGridPen write SetGridPen;
  end;

  //----------------------------------------------------------------------------

  // *** TGmPaperImage ***

  TGmPaperImage = class(TPaintBox)
  private
    FDragDrawing: Boolean;
    FDragDrawRect: TRect;
    FDragDrawShape: TGmDragDrawing;
    FDrawPage: Boolean;
    FDrawPpi: integer;
    FFastDraw: Boolean;
    FGrid: TGmPageGrid;
    FGutters: TRect;
    FMargins: TGmMargins;
    FPaperSizeInch: TGmSize;
    FPage: TObject;
    FShadow: TGmShadow;
    FUpdateCount: integer;
    FMouseValuePoint: TGmValuePoint;
    FDragValuePoint: TGmValuePoint;
    FZoom: integer;
    // events...
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnPageDragDrop: TGmPageDragDropEvent;
    FOnPageDragOver: TGmPageDragOverEvent;
    FOnPageMouseDown: TGmPageMouseEvent;
    FOnPageMouseMove: TGmPageMouseMoveEvent;
    FOnPageMouseUp: TGmPageMouseEvent;
    FOnPaintPage: TNotifyEvent;
    function CalcCursorPos: TPoint;
    function GetDragDrawInchRect: TGmRect;
    function GetIsUpdating: Boolean;
    function GetPageExtent(Ppi: integer): TSize;
    procedure Changed(Sender: TObject);
    procedure DrawPaper(Ppi: integer; OutlineOnly: Boolean);
    procedure DrawDragOutline;
    procedure SetDrawPpi(Value: integer);
    procedure SetGrid(Value: TGmPageGrid);
    procedure SetGutters(Value: TRect);
    procedure SetMargins(Value: TGmMargins);
    procedure SetPage(Value: TObject);
    procedure SetPaperSizeInch(ASize: TGmSize);
    procedure SetShadow(Value: TGmShadow);
    procedure SetZoom(Value: integer);
    procedure XYtoInchValuePoint(x, y: integer; var Value: TGmValuePoint);
  protected

    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function PageRect: TRect; virtual;
    procedure BeginUpdate;
    procedure ClipPaper;
    procedure DragDrawStop;
    procedure DragDrawStart;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure EndUpdate;
    property CursorPos: TPoint read CalcCursorPos;
    property DragDrawRect: TRect read FDragDrawRect;
    property DragDrawInchRect: TGmRect read GetDragDrawInchRect;
    property DragDrawShape: TGmDragDrawing read FDragDrawShape write FDragDrawShape default gmDragRectangle;
    property DrawPpi: integer read FDrawPpi write SetDrawPpi default 600;
    property DrawPage: Boolean read FDrawPage write FDrawPage default True;
    property FastDraw: Boolean read FFastDraw write FFastDraw default False;
    property IsDragDrawing: Boolean read FDragDrawing;
    property IsUpdating: Boolean read GetIsUpdating;
    property Grid: TGmPageGrid read FGrid write SetGrid;
    property Gutters: TRect read FGutters write SetGutters;
    property Margins: TGmMargins read FMargins write SetMargins;
    property Page: TObject read FPage write SetPage;
    property PageExtent[Ppi: integer]: TSize read GetPageExtent;
    property PaperSizeInch: TGmSize read FPaperSizeInch write SetPaperSizeInch;
    property Shadow: TGmShadow read FShadow write SetShadow;
    property Zoom: integer read FZoom write SetZoom default 20;
    // events...
    property OnDragOver;
    property OnDragDrop;
    property OnMouseDown;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    {$IFDEF D6+}
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    {$ENDIF}
    property OnPageDragDrop: TGmPageDragDropEvent read FOnPageDragDrop write FOnPageDragDrop;
    property OnPageDragOver: TGmPageDragOverEvent read FOnPageDragOver write FOnPageDragOver;
    property OnPageMouseDown: TGmPageMouseEvent read FOnPageMouseDown write FOnPageMouseDown;
    property OnPageMouseMove: TGmPageMouseMoveEvent read FOnPageMouseMove write FOnPageMouseMove;
    property OnPageMouseUp: TGmPageMouseEvent read FOnPageMouseUp write FOnPageMouseUp;
    property OnPaintPage: TNotifyEvent read FOnPaintPage write FOnPaintPage;
  end;

implementation

uses GmFuncs, GmObjects, GmPageList, GmConst, GmPrinter, ComObj, Math,
  SysUtils;

//----------------------------------------------------------------------------

// *** TGmComponent ***

function TGmComponent.GetAbout: string;
begin
  Result := GetStrVersion(Self);
end;

function TGmComponent.GetVersion: Extended;
begin
  Result := GMPS_VERSION;
end;

procedure TGmComponent.SetAbout(const Value: string);
begin
  // does nothing. (needed for published properties)
end;


//----------------------------------------------------------------------------

// *** TGmScrollingWinControl ***

constructor TGmScrollingWinControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csSetCaption, csDoubleClicks];
  ParentColor := False;
  if not ParentColor then
    Color := $C0C0C0;
  FBorderStyle := bsSingle;
  DoubleBuffered := True;
end;

function TGmScrollingWinControl.GetAbout: string;
begin
  Result := GetStrVersion(Self);
end;

function TGmScrollingWinControl.GetVersion: Extended;
begin
  Result := GMPS_VERSION;
end;

procedure TGmScrollingWinControl.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TGmScrollingWinControl.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

procedure TGmScrollingWinControl.SetAbout(const Value: string);
begin
  // does nothing. (needed for published properties)
end;

procedure TGmScrollingWinControl.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

//----------------------------------------------------------------------------

// *** TGmWinControl ***

constructor TGmWinControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csClickEvents, csSetCaption, csDoubleClicks];
  ParentColor := False;
  if not ParentColor then
    Color := $C0C0C0;
  FBorderStyle := bsSingle;
end;

function TGmWinControl.GetAbout: string;
begin
  Result := GetStrVersion(Self);
end;

function TGmWinControl.GetVersion: Extended;
begin
  Result := GMPS_VERSION;
end;

procedure TGmWinControl.SetAbout(const Value: string);
begin
  // does nothing. (needed for published properties)
end;

procedure TGmWinControl.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TGmWinControl.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

procedure TGmWinControl.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle];
    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;
  end;
end;

//----------------------------------------------------------------------------

// *** TGmComboBox ***

function TGmComboBox.GetAbout: string;
begin
  Result := GetStrVersion(Self);
end;

function TGmComboBox.GetVersion: Extended;
begin
  Result := GMPS_VERSION;
end;

procedure TGmComboBox.SetAbout(const Value: string);
begin
  // does nothing. (needed for published properties)
end;

//------------------------------------------------------------------------------

// *** TGmValue ***

constructor TGmValue.Create(const AChangeEvent: TNotifyEvent = nil);
begin
  inherited Create;
  FOnChange := AChangeEvent;
end;

constructor TGmValue.CreateValue(Value: Extended; Measurement: TGmMeasurement);
begin
  Create(nil);
  FInches := ConvertValue(Value, Measurement, gmInches);
end;

procedure TGmValue.Assign(Source: TPersistent);
begin
  if (Source is TGmValue) then
  begin
    FInches := (Source as TGmValue).AsInches;
    Changed;
  end
  else
    inherited Assign(Source);
end;

function TGmValue.GetAsMillimeters: Extended;
begin
  Result := ConvertValue(FInches, gmInches, gmMillimeters);
end;

function TGmValue.GetAsPixels(Ppi: integer): integer;
begin
  Result := Round(FInches * Ppi);
end;

function TGmValue.GetAsCentimeters: Extended;
begin
  Result := ConvertValue(FInches, gmInches, gmCentimeters);
end;

function TGmValue.GetAsGmUnits: integer;
begin
  Result := Round(ConvertValue(FInches, gmInches, gmUnits));
end;

function TGmValue.GetAsTwips: integer;
begin
  Result := Round(ConvertValue(FInches, gmInches, gmTwips));
end;

function TGmValue.GetGmValue(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FInches, gmInches, Measurement);
end;

procedure TGmValue.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmValue.SetAsCentimeters(Value: Extended);
begin
  AsInches := ConvertValue(Value, gmCentimeters, gmInches);
end;

procedure TGmValue.SetAsGmUnits(Value: integer);
begin
  AsInches := ConvertValue(Value, gmUnits, gmInches);
end;

procedure TGmValue.SetAsInches(Value: Extended);
begin
  if FInches = Value then Exit;
  FInches := Value;
  Changed;
end;

procedure TGmValue.SetAsMillimeters(Value: Extended);
begin
  AsInches := ConvertValue(Value, gmMillimeters, gmInches);
end;

procedure TGmValue.SetAsPixels(Ppi: integer; Value: integer);
begin
  SetAsInches(Value * Ppi);
end;

procedure TGmValue.SetAsTwips(Value: integer);
begin
  AsInches := ConvertValue(Value, gmTwips, gmInches);
end;

procedure TGmValue.SetGmValue(Measurement: TGmMeasurement; Value: Extended);
begin
  AsInches := ConvertValue(Value, Measurement, gmInches);
end;

//------------------------------------------------------------------------------

constructor TGmCustomValueSize.Create;
begin
  inherited Create;
  FHeight := TGmValue.Create(ValueChanged);
  FWidth := TGmValue.Create(ValueChanged);
end;

destructor TGmCustomValueSize.Destroy;
begin
  FHeight.Free;
  FWidth.Free;
  inherited Destroy;
end;

procedure TGmCustomValueSize.Assign(Source: TPersistent);
begin
  if (Source is TGmValueSize) then
  begin
    FWidth.AsInches := (Source as TGmValueSize).Width.AsInches;
    FHeight.AsInches := (Source as TGmValueSize).Height.AsInches;
  end
  else
    inherited Assign(Source);
end;

procedure TGmCustomValueSize.ValueChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

//------------------------------------------------------------------------------

// *** TGmValueRect ***

constructor TGmValueRect.Create;
begin
  inherited Create;
  FTopLeft := TGmValuePoint.Create;
  FBottomRight := TGmValuePoint.Create;
end;

destructor TGmValueRect.Destroy;
begin
  FTopLeft.Free;
  FBottomRight.Free;
  inherited Destroy;
end;

function TGmValueRect.GetAsInchRect: TGmRect;
begin
  Result.Left   := FTopLeft.X.AsInches;
  Result.Top    := FTopLeft.Y.AsInches;
  Result.Right  := FBottomRight.X.AsInches;
  Result.Bottom := FBottomRight.Y.AsInches;
end;

function TGmValueRect.GetValue(index: integer): TGmValue;
begin
  Result := nil;
  case Index of
    1: Result := FTopLeft.X;
    2: Result := FTopLeft.Y;
    3: Result := FBottomRight.X;
    4: Result := FBottomRight.Y;
  end;
end;

procedure TGmValueRect.SetAsInchRect(Value: TGmRect);
begin
  FTopLeft.X.AsInches := Value.Left;
  FTopLeft.Y.AsInches := Value.Top;
  FBottomRight.X.AsInches := Value.Right;
  FBottomRight.Y.AsInches := Value.Bottom;
end;

procedure TGmValueRect.SetValue(index: integer; Value: TGmValue);
begin
  case Index of
    1: FTopLeft.X.Assign(Value);
    2: FTopLeft.Y.Assign(Value);
    3: FBottomRight.X.Assign(Value);
    4: FBottomRight.Y.Assign(Value);
  end;
end;

//------------------------------------------------------------------------------

// *** TGmBaseObject ***

constructor TGmBaseObject.Create(AResourceTable: TGmResourceTable);
begin
  inherited Create;
  FResourceTable := AResourceTable;
  FObjectID := GetObjectID;
  FPrintThisObject := True;
  FTag := -1;
end;

procedure TGmBaseObject.Draw(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  if IsPrinterCanvas(ACanvas) then
  begin
    if FPrintThisObject then
      DrawToCanvas(ACanvas, Data);
  end
  else
    DrawToCanvas(ACanvas, Data);
end;

procedure TGmBaseObject.DrawToCanvas(ACanvas: TCanvas; var Data: TGmObjectDrawData);
begin
  // overridden in decendant classes
end;

procedure TGmBaseObject.LoadFromStream(Stream: TStream);
var
  Values: TGmValueList;
begin
  Values := TGmValueList.Create;
  try
    Values.LoadFromStream(Stream);
    LoadFromValueList(Values);
  finally
    Values.Free;
  end;
end;

procedure TGmBaseObject.OffsetObject(x, y: Extended; Measurement: TGmMeasurement);
begin
  // overridden in decendant classes
end;

procedure TGmBaseObject.SaveToStream(Stream: TStream);
var
  Values: TGmValueList;
begin
  Stream.Write(ObjectID, SizeOf(ObjectID));
  Values := TGmValueList.Create;
  try
    SaveToValueList(Values);
    Values.SaveToStream(Stream);
  finally
    Values.Free;
  end;
end;

procedure TGmBaseObject.LoadFromValueList(Values: TGmValueList);
begin
  FTag := Values.ReadIntValue(C_UI, -1);
end;

procedure TGmBaseObject.SaveToValueList(Values: TGmValueList);
begin
  Values.Add('');
  Values.Add('');
  Values.WriteIntValue(C_ID, FObjectID);
  Values.WriteIntValue(C_UI, FTag);
end;

procedure TGmBaseObject.AssignTo(Source: TPersistent);
begin
  FPrintThisObject := (Source as TGmBaseObject).PrintThisObject;
end;

procedure TGmBaseObject.Changed;
begin
  if FUpdating then Exit;
  if Assigned(FOnChange) then FOnChange(Self);
end;

//------------------------------------------------------------------------------

// *** TGmVisibleObject ***

constructor TGmVisibleObject.Create(AResourceTable: TGmResourceTable);
begin
  inherited Create(AResourceTable);
  FAllowDrag := True;
end;


procedure TGmVisibleObject.AssignTo(Source: TPersistent);
begin

end;

function TGmVisibleObject.BoundingRect(Data: TGmObjectDrawData): TGmRectPoints;
var
  Mf: TMetafile;
  Mfc: TMetafileCanvas;
  Rgn: HRGN;
  ARect: TRect;
begin
  Mf := TMetafile.Create;
  try
    Mfc := TMetafileCanvas.Create(Mf, 0);
    try
      BeginPath(Mfc.Handle);
      Draw(Mfc, Data);
      EndPath(Mfc.Handle);
      Rgn := PathToRegion(Mfc.Handle);
      GetRgnBox(Rgn, ARect);
      DeleteObject(Rgn);
    finally
      Mfc.Free;
    end;
  finally
    Mf.Free;
  end;
  Result := RectToGmRectPoints(ARect);
end;

procedure TGmVisibleObject.Arrange(ChangeLevel: TGmArrangeObject);
begin
  if Assigned(FLevelChange) then FLevelChange(Self, ChangeLevel);
end;

//------------------------------------------------------------------------------

// *** TGmObjectList ***

constructor TGmBaseObjectList.Create;
begin
  inherited Create(True);
end;

procedure TGmBaseObjectList.AddObject(AObject: TGmBaseObject);
begin
  Add(AObject);
  AObject.OnChange := Changed;
  Changed(Self);
end;

procedure TGmBaseObjectList.InsertObject(Index: integer; AObject: TGmBaseObject);
begin
  if Index < 0 then Index := 0;
  if Index > Count then Index := Count;
  Insert(Index, AObject);
  AObject.OnChange := Changed;
  Changed(Self);
end;

function TGmBaseObjectList.GetObject(index: integer): TGmBaseObject;
begin
  Result := TGmBaseObject(Items[index]);
end;

procedure TGmBaseObjectList.SetObject(index: integer; AObject: TGmBaseObject);
begin
  Items[index] := AObject;
end;

procedure TGmBaseObjectList.Changed(Sender: TObject);
begin
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

//------------------------------------------------------------------------------

// *** TGmRtfPageInfo ***

constructor TGmPageRtfInfo.Create(AResourceTable: TObject);
begin
  inherited Create;
  FResourceTable := AResourceTable;
  FMargins := TGmValueRect.Create;
end;

destructor TGmPageRtfInfo.Destroy;
begin
  FMargins.Free;
  inherited Destroy;
end;

procedure TGmPageRtfInfo.Clear;
begin
  FOffset := Point(0,0);
  FMargins.AsInchRect := GmRect(0, 0, 0, 0);
  TGmResourceTable(FResourceTable).CustomMemoList.DeleteResource(FRichEdit);
end;

procedure TGmPageRtfInfo.LoadFromValueList(Values: TGmValueList);
var
  ResourceTable: TGmResourceTable;
begin
  ResourceTable := TGmResourceTable(FResourceTable);
  FOffset := Values.ReadPointValue(C_XY, Point(0,0));
  FRichEdit := ResourceTable.CustomMemoList.Memo[Values.ReadIntValue(C_M, -1)];
  FMargins.AsInchRect := Values.ReadGmRectValue(C_MV, GmRect(0, 0, 0, 0));
  FWrapText := Values.ReadBoolValue(C_WRT, True);
end;

procedure TGmPageRtfInfo.SaveToValueList(Values: TGmValueList);
var
  ResourceTable: TGmResourceTable;
begin
  ResourceTable := TGmResourceTable(FResourceTable);
  Values.WritePointValue(C_XY, FOffset);
  Values.WriteIntValue(C_M, ResourceTable.CustomMemoList.IndexOf(FRichEdit));
  Values.WriteGmRectValue(C_MV, FMargins.AsInchRect);
  Values.WriteBoolValue(C_WRT, FWrapText);
end;

{procedure TGmPageRtfInfo.LoadFromStream(Stream: TStream);
var
  MemoIndex: integer;
begin
  FOffset := PointFromStream(Stream);
  MemoIndex := IntFromStream(Stream);
  FRichEdit := TGmResourceTable(FResourceTable).CustomMemoList.Memo[MemoIndex];
  FMargins.LoadFromStream(Stream);
end;

procedure TGmPageRtfInfo.SaveToStream(Stream: TStream);
var
  MemoIndex: integer;
begin
  PointToStream(Stream, FOffset);
  MemoIndex := TGmResourceTable(FResourceTable).CustomMemoList.IndexOf(FRichEdit);
  IntToStream(Stream, MemoIndex);
  FMargins.SaveToStream(Stream);
end;}

procedure TGmPageRtfInfo.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmPageRtfInfo.SetMargins(Value: TGmValueRect);
begin
  FMargins.Assign(Value);
end;

procedure TGmPageRtfInfo.SetOffset(Value: TPoint);
begin
  FOffset := Value;
  Changed;
end;

procedure TGmPageRtfInfo.SetRichEdit(ARichEdit: TCustomMemo);
begin
  if FRichEdit = ARichEdit then Exit;
  if Assigned(FRichEdit) then
    TGmResourceTable(FResourceTable).CustomMemoList.DeleteResource(FRichEdit);
  FRichEdit := ARichEdit;
end;

//------------------------------------------------------------------------------

// *** TGmMargins ***

constructor TGmMargins.Create(GmPrinter: TObject);
begin
  inherited Create;
  FPen := TPen.Create;
  FPrinterMarginPen := TPen.Create;
  FLeft := TGmValue.Create(Changed);
  FTop := TGmValue.Create(Changed);
  FRight := TGmValue.Create(Changed);
  FBottom := TGmValue.Create(Changed);
  FPrinter := GmPrinter;
  FLeft.AsInches := 0.5;
  FTop.AsInches := 0.5;
  FRight.AsInches := 0.5;
  FBottom.AsInches := 0.5;
  FValues := TGmMarginValues.Create(Self);
  FClipMargins := False;
  FPen.Color := clSilver;
  FPen.Style := psDot;
  FPrinterMarginPen.Assign(FPen);
  FVisible := False;
  FShowPrinterMargins := False;
  FUsePrinterMargins := False;
  FUpdating := False;
  FPen.OnChange := Changed;
  FPrinterMarginPen.OnChange := Changed;
end;

destructor TGmMargins.Destroy;
begin
  FLeft.Free;
  FTop.Free;
  FRight.Free;
  FBottom.Free;
  FValues.Free;
  FPen.Free;
  FPrinterMarginPen.Free;
  inherited Destroy;
end;

procedure TGmMargins.Assign(Source: TPersistent);
begin
  if (Source is TGmMargins) then
  begin
    FUpdating := True;
    FLeft.Assign((Source as TGmMargins).Left);
    FTop.Assign((Source as TGmMargins).Top);
    FRight.Assign((Source as TGmMargins).Right);
    FBottom.Assign((Source as TGmMargins).Bottom);
    FPen.Assign((Source as TGmMargins).Pen);
    FPrinterMarginPen.Assign((Source as TGmMargins).PrinterMarginPen);
    FShowPrinterMargins := (Source as TGmMargins).ShowPrinterMargins;
    FVisible := (Source as TGmMargins).Visible;
    FUpdating := False;
    Changed(Self);
  end
  else
    inherited Assign(Source);
end;

procedure TGmMargins.Clip(APageSize: TGmSize; AOrientation: TGmOrientation; ACanvas: TCanvas; Ppi: integer);
var
  ARect: TRect;
  MarginRgn: HRGN;
  APrinterInfo: TGmPrinterInfo;
begin
  FDrawPpi := Ppi;
  if FUsePrinterMargins then
  begin
    APrinterInfo := TGmPrinter(FPrinter).PrinterInfo;
    if FUsePrinterMargins then AsInches := APrinterInfo.MarginsInches[AOrientation];
    ARect := Rect(Round(APrinterInfo.MarginsInches[AOrientation].Left * Ppi),
                  Round(APrinterInfo.MarginsInches[AOrientation].Top * Ppi),
                  Round((APageSize.Width-APrinterInfo.MarginsInches[AOrientation].Right) * Ppi),
                  Round((APageSize.Height-APrinterInfo.MarginsInches[AOrientation].Bottom) * Ppi));
  end
  else
  begin
    ARect := Rect(Round((FLeft.AsInches)*Ppi),
                Round((FTop.AsInches)*Ppi),
                Round((APageSize.Width-(FRight.AsInches))*Ppi),
                Round((APageSize.Height-(FBottom.AsInches))*Ppi));
  end;
  if FClipMargins then
  begin
    if not BeginPath(ACanvas.Handle) then Exit;
    GmDrawRect(ACanvas, ARect);
    EndPath(ACanvas.Handle);
    MarginRgn := PathToRegion(ACanvas.Handle);
    try
      SelectClipRgn(ACanvas.Handle, MarginRgn);
    finally
      DeleteObject(MarginRgn);
    end;
  end;
end;

procedure TGmMargins.Draw(APageSize: TGmSize; AOrientation: TGmOrientation; ACanvas: TCanvas; Ppi: integer);
var
  ARect: TRect;
  APrinterInfo: TGmPrinterInfo;
  APrintMargins: TGmRect;
  Pw, Ph: Extended;
begin
  FDrawPpi := Ppi;
  APrinterInfo := (FPrinter as TGmPrinter).PrinterInfo;
  if FVisible then
  begin
    ACanvas.Brush.Style := bsClear;
    ACanvas.Pen.Assign(FPen);
    ACanvas.Pen.Style;

    if (APrinterInfo.PrinterAvailable) and (FUsePrinterMargins) then
      AsInches := APrinterInfo.MarginsInches[AOrientation];

    ARect := Rect(Round((FLeft.AsInches)*Ppi),
                  Round((FTop.AsInches)*Ppi),
                  Round((APageSize.Width-(FRight.AsInches))*Ppi),
                  Round((APageSize.Height-(FBottom.AsInches))*Ppi));
    ACanvas.Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);

    if (APrinterInfo.PrinterAvailable) and (FShowPrinterMargins) then
    begin
      ACanvas.Brush.Style := bsClear;
      ACanvas.Pen.Assign(FPrinterMarginPen);
      APrintMargins := APrinterInfo.MarginsInches[AOrientation];

      if AOrientation = gmPortrait then
      begin
        Pw := APrinterInfo.PhysicalSizeX;
        Ph := APrinterInfo.PhysicalSizeY;
      end
      else
      begin
        Pw := APrinterInfo.PhysicalSizeY;
        Ph := APrinterInfo.PhysicalSizeX;
      end;
      ARect := Rect(Round((APrintMargins.Left)*Ppi),
                    Round((APrintMargins.Top)*Ppi),
                    Round((Pw-APrintMargins.Right) * Ppi),
                    Round((Ph-APrintMargins.Bottom) * Ppi));
      ACanvas.Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
    end;
  end;
end;

procedure TGmMargins.LoadFromStream(Stream: TStream);
var
  AValues: TGmValueList;
  APen: TGmPen;
begin
  AValues := TGmValueList.Create;
  try
    AValues.LoadFromStream(Stream);
    AsInches     := AValues.ReadGmRectValue(C_MV, GmRect(0,0,0,0));// GmRectFromString(AValues.ReadStringValue(C_MV, ''));
    FClipMargins := AValues.ReadBoolValue(C_CLM, False);
  finally
    AValues.Free;
  end;
  APen := TGmPen.Create;
  try
    APen.LoadFromStream(Stream);
    APen.AssignToPen(FPen);
  finally
    APen.Free;
  end;
end;

procedure TGmMargins.SaveToStream(Stream: TStream);
var
  AValues: TGmValueList;
  APen: TGmPen;
begin
  AValues := TGmValueList.Create;
  try
    AValues.WriteGmRectValue(C_MV, AsInches);
    AValues.WriteBoolValue(C_CLM, FClipMargins);
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

function TGmMargins.GetAsInches: TGmRect;
begin
  Result.Left := FLeft.AsInches;
  Result.Top  := FTop.AsInches;
  Result.Right := FRight.AsInches;
  Result.Bottom := FBottom.AsInches;
end;

function TGmMargins.GetPrinterMargins(Measurement: TGmMeasurement; AOrientation: TGmOrientation): TGmRect;
begin
  Result := ConvertGmRect(TGmPrinter(FPrinter).PrinterInfo.MarginsInches[AOrientation], gmInches, Measurement);
end;

procedure TGmMargins.Changed(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmMargins.SetAsInches(ARect: TGmRect);
begin
  FUpdating := True;
  FLeft.AsInches := ARect.Left;
  FTop.AsInches := ARect.Top;
  FRight.AsInches := ARect.Right;
  FBottom.AsInches := ARect.Bottom;
  FUpdating := False;
end;

procedure TGmMargins.SetClipMargins(Value: Boolean);
begin
  if FClipMargins = Value then Exit;
  FClipMargins := Value;
  Changed(Self);
end;

procedure TGmMargins.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
  Changed(Self);
end;

procedure TGmMargins.SetPrinterMarginPen(Value: TPen);
begin
  FPrinterMarginPen.Assign(Value);
  Changed(Self);
end;

procedure TGmMargins.SetShowPrinterMargins(Value: Boolean);
begin
  if FShowPrinterMargins = Value then Exit;
  FShowPrinterMargins := Value;
  Changed(Self);
end;

procedure TGmMargins.SetUsePrinterMargins(Value: Boolean);
begin
  if FUsePrinterMargins = Value then Exit;
  FUsePrinterMargins := Value;
  Changed(Self);
end;

procedure TGmMargins.SetVisible(Value: Boolean);
begin
  if FVisible = Value then Exit;
  FVisible := Value;
  Changed(Self);
end;

//------------------------------------------------------------------------------

// *** TGmMarginValues ***

constructor TGmMarginValues.Create(AMargins: TGmMargins);
begin
  inherited Create;
  FMargins := AMargins;
  FMeasurement := gmInches;
end;

function TGmMarginValues.GetValue(index: integer): Single;
begin
  Result := 0;
  case index of
    0: Result := FMargins.Left.AsGmValue[FMeasurement];
    1: Result := FMargins.Top.AsGmValue[FMeasurement];
    2: Result := FMargins.Right.AsGmValue[FMeasurement];
    3: Result := FMargins.Bottom.AsGmValue[FMeasurement];
  end
end;

procedure TGmMarginValues.SetMeasurement(Value: TGmMeasurement);
begin
  if FMeasurement = Value then Exit;
  FMeasurement := Value;
end;

procedure TGmMarginValues.SetValue(index: integer; Value: Single);
begin
  case index of
    0: FMargins.Left.AsGmValue[FMeasurement] := Value;
    1: FMargins.Top.AsGmValue[FMeasurement] := Value;
    2: FMargins.Right.AsGmValue[FMeasurement] := Value;
    3: FMargins.Bottom.AsGmValue[FMeasurement] := Value;
  end;
end;

//------------------------------------------------------------------------------

// *** TGmShadow ***

constructor TGmShadow.Create;
begin
  inherited Create;
  FColor := clBlack;
  FWidth := 3;
  FVisible := True;
end;

procedure TGmShadow.Assign(Source: TPersistent);
begin
  if (Source is TGmShadow) then
  begin
    FColor   := (Source as TGmShadow).Color;
    FVisible := (Source as TGmShadow).Visible;
    FWidth   := (Source as TGmShadow).Width;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TGmShadow.Draw(ACanvas: TCanvas; APageRect: TRect);
var
  ARect1: TRect;
  ARect2: TRect;
begin
  if not FVisible then Exit;
  SelectClipRgn(ACanvas.Handle, 0);
  SetMapMode(ACanvas.Handle, MM_TEXT);
  ARect1 := Rect(APageRect.Right,
                 APageRect.Top+FWidth,
                 APageRect.Right+FWidth,
                 APageRect.Bottom);
  OffsetRect(ARect1, 1, 1);
  ARect2 := Rect(APageRect.Left+FWidth,
                 APageRect.Bottom,
                 APageRect.Right+FWidth,
                 APageRect.Bottom+FWidth);
  OffsetRect(ARect2, 1, 1);
  ACanvas.Pen.Width := 1;
  ACanvas.Brush.Color := FColor;
  ACanvas.Pen.Color := FColor;
  ACanvas.Rectangle(ARect1.Left, ARect1.Top, ARect1.Right, ARect1.Bottom);
  ACanvas.Rectangle(ARect2.Left, ARect2.Top, ARect2.Right, ARect2.Bottom);
end;

procedure TGmShadow.Changed;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmShadow.SetColor(Value: TColor);
begin
  if FColor = Value then Exit;
  FColor := Value;
  Changed;
end;

procedure TGmShadow.SetVisible(Value: Boolean);
begin
  if FVisible = Value then Exit;
  FVisible := Value;
  Changed;
end;

procedure TGmShadow.SetWidth(Value: integer);
begin
  if FWidth = Value then Exit;
  FWidth := Value;
  Changed;
end;

//------------------------------------------------------------------------------

// *** TGmPageGrid ***

constructor TGmPageGrid.Create;
begin
  inherited Create;
  FGridPen := TPen.Create;
  FGridStyle := gmNoGrid;
  FGridInterval := TGmValue.CreateValue(10, gmMillimeters);
  FGridPen.Color := clSilver;
  FGridPen.Width := 1;
  FGridInterval.OnChange := Changed;
  FGridPen.OnChange := Changed;
end;

destructor TGmPageGrid.Destroy;
begin
  FGridInterval.Free;
  FGridPen.Free;
  inherited Destroy;
end;

procedure TGmPageGrid.Changed(Sender: TObject);
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TGmPageGrid.DrawToCanvas(Canvas: TCanvas; APageSize: TGmSize; Ppi: integer);
var
  ICount1,
  ICount2: integer;
  Dot: TPoint;
begin
  if FGridStyle = gmNoGrid then Exit;
  Canvas.Pen.Assign(FGridPen);
  if FGridStyle = gmLines then
  begin
    for ICount1 := 1 to Round(APageSize.Width / FGridInterval.AsInches) do
    begin
      Canvas.MoveTo(Round((ICount1 * FGridInterval.AsInches) * Ppi), 0);
      Canvas.LineTo(Round((ICount1 * FGridInterval.AsInches) * Ppi), Round(APageSize.Height * Ppi));
    end;
    for ICount2 := 1 to Round(APageSize.Height / FGridInterval.AsInches) do
    begin
      Canvas.MoveTo(0, Round((ICount2 * FGridInterval.AsInches) * Ppi));
      Canvas.LineTo(Round(APageSize.Width * Ppi), Round((ICount2 * FGridInterval.AsInches) * Ppi));
    end;
  end
  else
  if FGridStyle = gmDots then
  begin
    for ICount1 := 1 to Round(APageSize.Width / FGridInterval.AsInches) do
      for ICount2 := 1 to Round(APageSize.Height / FGridInterval.AsInches) do
      begin
        Dot := Point(Round((ICount1 * FGridInterval.AsInches) * Ppi), Round((ICount2 * FGridInterval.AsInches) * Ppi));
        Canvas.Pixels[Dot.X, Dot.Y] := FGridPen.Color;
      end;
  end;
end;

procedure TGmPageGrid.SetGridStyle(const Value: TGmGridStyle);
begin
  if FGridStyle = Value then Exit;
  FGridStyle := Value;
  Changed(Self);
end;

procedure TGmPageGrid.SetGridPen(Value: TPen);
begin
  FGridPen.Assign(Value);
  Changed(Self);
end;

//------------------------------------------------------------------------------

// *** TGmPaperImage ***

constructor TGmPaperImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMouseValuePoint := TGmValuePoint.Create;
  FDragValuePoint := TGmValuePoint.Create;
  FGutters := Rect(30, 30, 30, 30);
  FZoom := 20;
  FUpdateCount := 0;
  FMargins := nil;
  FShadow := nil;
  FDrawPpi := 600;
  FDragDrawShape := gmDragRectangle;
  FDragDrawing := False;
  FDrawPage := True;
  FFastDraw := False;
end;

destructor TGmPaperImage.Destroy;
begin
  FMouseValuePoint.Free;
  FDragValuePoint.Free;
  inherited Destroy;
end;

procedure TGmPaperImage.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TGmPaperImage.DragDrawStop;
begin
  FDragDrawing := False;
  Invalidate;
end;

procedure TGmPaperImage.DragDrawStart;
begin
  if FDragDrawing then Exit;
  FDragDrawing := True;
  FDragDrawRect.TopLeft := CalcCursorPos;
  FDragDrawRect.BottomRight := FDragDrawRect.TopLeft;
end;

procedure TGmPaperImage.DragDrop(Source: TObject; X, Y: Integer);
begin
  if Assigned(OnDragDrop) then OnDragDrop(Self, Source, X, Y);
  XYtoInchValuePoint(x, y, FDragValuePoint);
  if Assigned(FOnPageDragDrop) then FOnPageDragDrop(Self, Source, FDragValuePoint.X, FDragValuePoint.Y);
end;

procedure TGmPaperImage.EndUpdate;
begin
  if FUpdateCount > 0 then Dec(FUpdateCount);
  if not IsUpdating then Invalidate;
end;

function TGmPaperImage.CalcCursorPos: TPoint;
begin
  GetCursorPos(Result);
  Result := ScreenToClient(Result);
end;

function TGmPaperImage.GetDragDrawInchRect: TGmRect;
var
  APageRect: TRect;
begin
  APageRect := PageRect;

  Result.Left   := ((FDragDrawRect.Left - APageRect.Left)  / SCREEN_PPI) / (FZoom / 100);
  Result.Top    := ((FDragDrawRect.Top - APageRect.Top)  / SCREEN_PPI) / (FZoom / 100);
  Result.Right  := ((FDragDrawRect.Right - APageRect.Left) / SCREEN_PPI) / (FZoom / 100);
  Result.Bottom := ((FDragDrawRect.Bottom - APageRect.Top) / SCREEN_PPI) / (FZoom / 100);
end;

function TGmPaperImage.GetIsUpdating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

function TGmPaperImage.GetPageExtent(Ppi: integer): TSize;
begin
  Result.cx := Round((FPaperSizeInch.Width * Ppi) * (FZoom/100));
  Result.cy := Round((FPaperSizeInch.Height * Ppi) * (FZoom/100));
end;

procedure TGmPaperImage.Changed(Sender: TObject);
begin
  Invalidate;
end;

procedure TGmPaperImage.ClipPaper;
var
  PaperRgn: HRGN;
  ARect: TRect;
begin
  ARect := Rect(0,
                0,
                Round(FPaperSizeInch.Width*DrawPpi),
                Round(FPaperSizeInch.Height*DrawPpi));
  if not BeginPath(Canvas.Handle) then Exit;
  GmDrawRect(Canvas, ARect);
  EndPath(Canvas.Handle);
  PaperRgn := PathToRegion(Canvas.Handle);
  try
    SelectClipRgn(Canvas.Handle, PaperRgn);
  finally
    DeleteObject(PaperRgn);
  end;
end;

procedure TGmPaperImage.DrawPaper(Ppi: integer; OutlineOnly: Boolean);
var
  ARect: TRect;
begin
  ARect := Rect(0,
                0,
                Round(FPaperSizeInch.Width*Ppi),
                Round(FPaperSizeInch.Height*Ppi));
  Canvas.Pen.Width := 0;
  Canvas.Pen.Mode := pmCopy;
  Canvas.Pen.Style := psSolid;
  Canvas.Pen.Color := clBlack;
  Canvas.Brush.Color := clWhite;
  if OutlineOnly then
    Canvas.Brush.Style := bsClear
  else
    Canvas.Brush.Style := bsSolid;
  GmDrawRect(Canvas, ARect);
  ClipPaper;
end;

procedure TGmPaperImage.DrawDragOutline;
begin
  Canvas.Lock;
  try
    Canvas.Pen.Mode := pmNot;
    Canvas.Pen.Style := psDot;
    Canvas.Brush.Style := bsClear;
    GmDrawRect(Canvas, FDragDrawRect);
  finally
    Canvas.Unlock;
  end;
end;
procedure TGmPaperImage.SetDrawPpi(Value: integer);
begin
  if FDrawPpi = Value then Exit;
  FDrawPpi := Value;
  Changed(Self);
end;

procedure TGmPaperImage.SetGrid(Value: TGmPageGrid);
begin
  FGrid := Value;
  if Assigned(FGrid) then
    FGrid.OnChange := Changed;
end;

procedure TGmPaperImage.SetGutters(Value: TRect);
begin
  if EqualRect(FGutters, Value) then Exit;
  FGutters := Value;
  Changed(Self);
end;

procedure TGmPaperImage.SetMargins(Value: TGmMargins);
begin
  FMargins := Value;
end;

procedure TGmPaperImage.SetPage(Value: TObject);
begin
  FPage := Value;
  if Assigned(FPage) then
  begin
    FPaperSizeInch := TGmPage(FPage).PageSize[gmInches];
  end;
  Changed(Self);
end;

procedure TGmPaperImage.SetPaperSizeInch(ASize: TGmSize);
begin
  FPaperSizeInch := ASize;
  Changed(Self);
end;

procedure TGmPaperImage.SetShadow(Value: TGmShadow);
begin
  FShadow := Value;
  if Assigned(FShadow) then FShadow.OnChange := Changed;
end;

procedure TGmPaperImage.SetZoom(Value: integer);
begin
  if FZoom = Value then Exit;
  FZoom := Value;
  Changed(Self);
end;

procedure TGmPaperImage.XYtoInchValuePoint(x, y: integer; var Value: TGmValuePoint);
var
  Origin: TPoint;
begin
  Origin := PageRect.TopLeft;
  x := x - Origin.X;
  y := y - Origin.Y;
  if x = 0 then
    Value.X.AsInches := 0
  else
    Value.X.AsInches := (x / SCREEN_PPI) / (FZoom / 100);
  if y = 0 then
    Value.Y.AsInches := 0
  else
    Value.Y.AsInches := (y / SCREEN_PPI) / (FZoom / 100);
end;

function TGmPaperImage.PageRect: TRect;
var
  OffsetLeft: integer;
  OffsetTop: integer;
begin
  //if Assigned(FPage) then FPaperSizeInch := TGmPage(FPage).PageSize[gmInches];
  Result := Rect(0,
                 0,
                 Round(PageExtent[SCREEN_PPI].cx),
                 Round(PageExtent[SCREEN_PPI].cy));
  OffsetLeft := (((Width - (FGutters.Left + FGutters.Right)) - RectWidth(Result)) div 2);
  OffsetTop  := (((Height - (FGutters.Top + FGutters.Bottom)) - RectHeight(Result)) div 2);

  //if OffsetLeft < FGutters.Left then OffsetLeft := FGutters.Left;
  //if OffsetTop < FGutters.Top then OffsetTop := FGutters.Top;

  OffsetRect(Result, FGutters.Left + OffsetLeft, FGutters.Top + OffsetTop);
end;

procedure TGmPaperImage.DragOver(Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  //if IsUpdating then Exit;
  if Assigned(OnDragOver) then OnDragOver(Self, Source, X, Y, State, Accept);
  XYtoInchValuePoint(x, y, FDragValuePoint);
  if Assigned(FOnPageDragOver) then FOnPageDragOver(Self, Source, FDragValuePoint.X, FDragValuePoint.Y, State, Accept);
end;

procedure TGmPaperImage.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  //if IsUpdating then Exit;
  XYtoInchValuePoint(x, y, FMouseValuePoint);
  if Assigned(OnMouseDown) then OnMouseDown(Self, Button, Shift, X, Y);
  if Assigned(FOnPageMouseDown) then FOnPageMouseDown(Self, Button, Shift, FMouseValuePoint.X, FMouseValuePoint.Y);
end;

procedure TGmPaperImage.CMMouseEnter(var Message: TMessage);
begin
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TGmPaperImage.CMMouseLeave(var Message: TMessage);
begin
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TGmPaperImage.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  AClipRgn: HRGN;
  AClipRect: TRect;
begin
  if IsUpdating then Exit;
  inherited MouseMove(Shift, X, Y);
  if Assigned(OnMouseMove) then OnMouseMove(Self, Shift, X, Y);
  if FDragDrawing then
  begin
    AClipRect := PageRect;
    InflateRect(AClipRect, -1, -1);
    AClipRgn := CreateRectRgnIndirect(AClipRect);
    try
      SelectClipRgn(Canvas.Handle, AClipRgn);
    finally
      DeleteObject(AClipRgn);
    end;
    DrawDragOutline;
    FDragDrawRect.BottomRight := Point(X, Y);
    DrawDragOutline;
  end;
  XYtoInchValuePoint(x, y, FMouseValuePoint);
  if Assigned(FOnPageMouseMove) then FOnPageMouseMove(Self, Shift, FMouseValuePoint.X, FMouseValuePoint.Y);
end;

procedure TGmPaperImage.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if Assigned(OnMouseUp) then OnMouseUp(Self, Button, Shift, X, Y);
  XYtoInchValuePoint(x, y, FMouseValuePoint);
  if Assigned(FOnPageMouseUp) then FOnPageMouseUp(Self, Button, Shift, FMouseValuePoint.X, FMouseValuePoint.Y);
end;

procedure TGmPaperImage.Paint;
var
  APageRect: TRect;
  AOrientation: TGmOrientation;
begin
  if IsUpdating then Exit;
  if (Assigned(FPage)) then
    AOrientation := TGmPage(FPage).Orientation
  else
    AOrientation := gmPortrait;
  Canvas.Brush.Color := clWhite;
  APageRect := PageRect;
  SetMapMode(Canvas.Handle, MM_ANISOTROPIC);
  SetWindowExtEx(Canvas.Handle,
                 Round(FPaperSizeInch.Width*FDrawPpi),
                 Round(FPaperSizeInch.Height*FDrawPpi),
                 nil );
  SetWindowOrgEx(Canvas.Handle, 0, 0, nil);
  SetViewportExtEx(Canvas.Handle,
                   PageExtent[SCREEN_PPI].cx,
                   PageExtent[SCREEN_PPI].cy,
                   nil );
  SetViewportOrgEx(Canvas.Handle, APageRect.Left+Left, PageRect.Top+Top, nil);
  DrawPaper(FDrawPpi, False);
  APageRect := Rect(0, 0, PageExtent[SCREEN_PPI].cx, PageExtent[SCREEN_PPI].cy);
  if Assigned(FMargins) then
    FMargins.Clip(FPaperSizeInch, AOrientation, Canvas, FDrawPpi);
  if (Assigned(FPage)) and (FDrawPage) then
    TGmPage(FPage).DrawToCanvas(Canvas, FDrawPpi, FDrawPpi, FFastDraw);
  if Assigned(FMargins) then FMargins.Draw(FPaperSizeInch, AOrientation, Canvas, FDrawPpi);
  if Assigned(FGrid) then FGrid.DrawToCanvas(Canvas, PaperSizeInch, FDrawPpi);
  SelectClipRgn(Canvas.Handle, 0);

  DrawPaper(FDrawPpi, True);
  if Assigned(FShadow) then FShadow.Draw(Canvas, APageRect);

  if Assigned(FOnPaintPage) then
  begin
    ClipPaper;
    SetMapMode(Canvas.Handle, MM_TEXT);
    SetViewportOrgEx(Canvas.Handle, 0, 0, nil);
    Canvas.Brush.Style := bsClear;
    FOnPaintPage(Self);
  end;
end;

end.
