{******************************************************************************}
{                                                                              }
{                               GmPrinter.pas                                  }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmPrinter;

interface

uses Windows, GmTypes, Forms, Graphics, Classes, GmClasses,
  GmConst, Dialogs;

type

  //----------------------------------------------------------------------------

  // *** TGmPrinterInfo ***

  TGmPrinterInfo = class
  private
    FDevice, FDriver, FPort: array[0..128] of Char;
    FDeviceMode: THandle;
    FDevMode: PDeviceMode;
    FPhysicalSize: TPoint;
    FPrintableSize: TPoint;
    FGutters: TRect;
    FOrientation: TGmOrientation;
    FPpi: TPoint;
    FRotationDirection: TGmPrinterRotation;
    FScreenPrinterScale: Extended;
    FIsUpdated: Boolean;
    FUseDefaultValues: Boolean;
    function GetAvailableHeight: integer;
    function GetAvailableWidth: integer;
    function GetGutters(AOrientation: TGmOrientation): TRect;
    function GetGuttersInch(AOrientation: TGmOrientation): TGmRect;
    function GetOrientation: TGmOrientation;
    function GetOrientationRotation: TGmPrinterRotation;
    function GetPhysicalSizeX: Extended;
    function GetPhysicalSizeY: Extended;
    function GetPpiX: integer;
    function GetPpiY: integer;
    function GetPrintableSizeX: Extended;
    function GetPrintableSizeY: Extended;
    function GmOpenPrinter: Boolean;
    function GetPrinterAvailable: HDC;
    procedure GmClosePrinter;
    procedure ResetPrinter;
    procedure UpdatePrinter;
    procedure UseDefaultValues;
  public
    constructor Create;
    //property MarginsPixels: TRect read GetGutters[Orientation: TGmOrientation];
    function PrinterAvailable: Boolean;
    property MarginsInches[Orientation: TGmOrientation]: TGmRect read GetGuttersInch;
    property Orientation: TGmOrientation read GetOrientation;
    property PhysicalSizeX: Extended read GetPhysicalSizeX;
    property PhysicalSizeY: Extended read GetPhysicalSizeY;
    property PpiX: integer read GetPpiX;
    property PpiY: integer read GetPpiY;
    property PrintableSizeX: Extended read GetPrintableSizeX;
    property PrintableSizeY: Extended read GetPrintableSizeY;

  end;

  //----------------------------------------------------------------------------

  // *** TGmPrinter ***

  TGmPrinter = class(TPersistent)
  private
    FAborted: Boolean;
    FFileName: string;
    FFont: TFont;
    FInitialized: Boolean;
    FLastOrientation: TGmOrientation;
    FOrientation: TGmOrientation;
    FPagesPerSheet: TGmPagesPerSheet;
    FPaperSizes: TStrings;
    FPrintCount: integer;
    FPrinterBins: TStrings;
    FPrinting: Boolean;
    FPrinterInfo: TGmPrinterInfo;
    FReversePrintOrder: Boolean;
    FTitle: string;
    // events...
    FOnAbortPrint: TNotifyEvent;
    FAfterPrint: TNotifyEvent;
    FBeforePrint: TNotifyEvent;
    FOnChangePrinter: TNotifyEvent;
    function GetAvailableHeight(Measurement: TGmMeasurement): Extended;
    function GetAvailableWidth(Measurement: TGmMeasurement): Extended;
    function GetCanvas: TCanvas;
    function GetCollate: Boolean;
    function GetDuplexType: TGmDuplexType;
    function GetPaperSize: TGmPaperSize;
    function GetPrintCopies: integer;
    function GetHandle: THandle;
    function GetIndexOf(Value: string): integer;
    function GetIsColorPrinter: Boolean;
    function GetPrinterBinIndex: integer;
    function GetPrinterBins: TStrings;
    function GetPrinterHeight(Measurement: TGmMeasurement): Extended;
    function GetPrinterIndex: integer;
    function GetPrinters: TStrings;
    function GetPrinterSelected: Boolean;
    function GetPrinterWidth(Measurement: TGmMeasurement): Extended;
    procedure AlterOrientation;
    procedure SetCollate(Value: Boolean);
    procedure SetDrawingArea(PageNum: integer);
    procedure SetDuplexType(Value: TGmDuplexType);
    procedure SetOrientation(Value: TGmOrientation);
    procedure SetGmPaperSize(Value: TGmPaperSize);
    procedure SetPrinterBinIndex(Value: integer);
    procedure SetPrintCopies(Value: integer);
    procedure SetPrinterIndex(Value: integer);
    function GetDitherType: TGmDitherType;
    function GetPrintColor: TGmPrintColor;
    function GetPrintQuality: TGmPrintQuality;
    procedure SetDitherType(Value: TGmDitherType);
    procedure SetPrintColor(Value: TGmPrintColor);
    procedure SetPrintQuality(Value: TGmPrintQuality);
  public
    constructor Create;
    destructor Destroy; override;
    function GetPaperDimensions(Measurement: TGmMeasurement): TGmSize;
    procedure Abort;
    procedure BeginDoc(FileName: string);
    procedure NewPage;
    procedure EndDoc;
    procedure SetDMPaperSize(APaperSize: integer);
    procedure GetPaperNames(const Papers: TStrings);
    property Aborted: Boolean read FAborted;
    property AvailableHeight[Measurement: TGmMeasurement]: Extended read GetAvailableHeight;
    property AvailableWidth[Measurement: TGmMeasurement]: Extended read GetAvailableWidth;
    property Canvas: TCanvas read GetCanvas;
    property Handle: THandle read GetHandle;
    property IndexOf[Printer: string]: integer read GetIndexOf;
    property IsColorPrinter: Boolean read GetIsColorPrinter;
    property Orientation: TGmOrientation read FOrientation write SetOrientation default gmPortrait;
    property PagesPerSheet: TGmPagesPerSheet read FPagesPerSheet write FPagesPerSheet default gmOnePage;
    property PrinterBinIndex: integer read GetPrinterBinIndex write SetPrinterBinIndex;
    property PrinterBins: TStrings read GetPrinterBins;
    property PrinterHeight[Measurement: TGmMeasurement]: Extended read GetPrinterHeight;
    property PrinterIndex: integer read GetPrinterIndex write SetPrinterIndex;
    property PrinterInfo: TGmPrinterInfo read FPrinterInfo;
    property PrinterPaperSize: TGmPaperSize read GetPaperSize write SetGmPaperSize;
    property Printers: TStrings read GetPrinters;
    property PrinterSelected: Boolean read GetPrinterSelected;
    property PrinterWidth[Measurement: TGmMeasurement]: Extended read GetPrinterWidth;
    property Printing: Boolean read FPrinting;
  published
    property Collate: Boolean read GetCollate write SetCollate;
    property Duplex: TGmDuplexType read GetDuplexType write SetDuplexType;
    property PrintCopies: integer read GetPrintCopies write SetPrintCopies default 1;
    property PrintColor: TGmPrintColor read GetPrintColor write SetPrintColor;
    property DitherType: TGmDitherType read GetDitherType write SetDitherType;
    property PrintQuality: TGmPrintQuality read GetPrintQuality write SetPrintQuality;
    property ReversePrintOrder: Boolean read FReversePrintOrder write FReversePrintOrder default False;
    property Title: string read FTitle write FTitle;
    // events...
    property AfterPrint: TNotifyEvent read FAfterPrint write FAfterPrint;
    property BeforePrint: TNotifyEvent read FBeforePrint write FBeforePrint;
    property OnAbortPrint: TNotifyEvent read FOnAbortPrint write FOnAbortPrint;
    property OnChangePrinter: TNotifyEvent read FOnChangePrinter write FOnChangePrinter;
  end;

  function AsGmPaperSize(dmPaperSize: SmallInt): TGmPaperSize;
  function AsDmPaperSize(APaperSize: TGmPaperSize): SmallInt;
  function IsPrinterCanvas(ACanvas: TCanvas): Boolean;

implementation

uses Printers, WinSpool, GmFuncs, SysUtils, GmErrors;

type
  TGmPrinterDevice = class
    Driver, Device, Port: String;
  end;

//------------------------------------------------------------------------------

function IsPrinterCanvas(ACanvas: TCanvas): Boolean;
begin
  Result := LowerCase(ACanvas.ClassName) = 'tprintercanvas';
end;

//------------------------------------------------------------------------------

function AsGmPaperSize(dmPaperSize: SmallInt): TGmPaperSize;
begin
  case dmPaperSize of
    DMPAPER_LETTER    : Result := Letter;
    DMPAPER_LEGAL     : Result := Legal;
    DMPAPER_A3        : Result := A3;
    DMPAPER_A4        : Result := A4;
    DMPAPER_A5        : Result := A5;
    DMPAPER_A6        : Result := A6;
    DMPAPER_B4        : Result := B4;
    DMPAPER_B5        : Result := B5;
    DMPAPER_ENV_C5    : Result := C5;
    DMPAPER_ENV_9     : Result := Envelope_09;
    DMPAPER_ENV_10    : Result := Envelope_10;
    DMPAPER_ENV_11    : Result := Envelope_11;
    DMPAPER_ENV_12    : Result := Envelope_12;
    DMPAPER_ENV_14    : Result := Envelope_14;
    DMPAPER_EXECUTIVE : Result := Executive;
    DMPAPER_LEDGER    : Result := Ledger;
    DMPAPER_TABLOID   : Result := Tabloid;
  else
    Result := Custom;
  end
end;

function AsDmPaperSize(APaperSize: TGmPaperSize): SmallInt;
begin
  Result := -1;
  case APaperSize of
    A3          : Result := DMPAPER_A3;
    A4          : Result := DMPAPER_A4;
    A5          : Result := DMPAPER_A5;
    A6          : Result := DMPAPER_A6;
    B4          : Result := DMPAPER_B4;
    B5          : Result := DMPAPER_B5;
    C5          : Result := DMPAPER_ENV_C5;
    Envelope_09 : Result := DMPAPER_ENV_9;
    Envelope_10 : Result := DMPAPER_ENV_10;
    Envelope_11 : Result := DMPAPER_ENV_11;
    Envelope_12 : Result := DMPAPER_ENV_12;
    Envelope_14 : Result := DMPAPER_ENV_14;
    Legal       : Result := DMPAPER_LEGAL;
    Letter      : Result := DMPAPER_LETTER;
    Executive   : Result := DMPAPER_EXECUTIVE;
    Ledger      : Result := DMPAPER_LEDGER;
    Tabloid     : Result := DMPAPER_TABLOID;
  end;
end;

function AsPrinterOrientation(GmOrientation: TGmOrientation): TPrinterOrientation;
begin
  Result := poPortrait;
  if GmOrientation = gmLandscape then Result := poLandscape;
end;

function AsGmOrientation(AOrientation: TPrinterOrientation): TGmOrientation;
begin
  Result := gmPortrait;
  if AOrientation = poLandscape then Result := gmLandscape;
end;

//------------------------------------------------------------------------------

// *** TGmPrinterInfo ***

constructor TGmPrinterInfo.Create;
begin
  inherited Create;
  FIsUpdated := False;
  FOrientation := gmPortrait;
  ResetPrinter;
  UpdatePrinter;
  FUseDefaultValues := False;
end;

function TGmPrinterInfo.PrinterAvailable: Boolean;
var
  TestCanvas: HDC;
begin
  TestCanvas := GetPrinterAvailable;
  try
    Result := TestCanvas <> 0;
  finally
    DeleteDC(TestCanvas);
  end;
end;

function TGmPrinterInfo.GetAvailableHeight: integer;
begin
  if not FIsUpdated then UpdatePrinter;
  Result := FPrintableSize.Y;
end;

function TGmPrinterInfo.GetAvailableWidth: integer;
begin
  if not FIsUpdated then UpdatePrinter;
  Result := FPrintableSize.X;
end;

function TGmPrinterInfo.GetGutters(AOrientation: TGmOrientation): TRect;
var
  ATempVal: integer;
begin
  if not FIsUpdated then
    UpdatePrinter;

  Result := FGutters;

  if (AOrientation = gmLandscape) then
  begin
    if FRotationDirection = gmRotate90 then
    begin
      ATempVal := Result.Top;
      Result.Top := Result.Right;
      Result.Right := Result.Bottom;
      Result.Bottom := Result.Left;
      Result.Left := ATempVal;
    end
    else
    begin
      ATempVal := Result.Top;
      Result.Top := Result.Right;
      Result.Right := Result.Bottom;
      Result.Bottom := Result.Left;
      Result.Left := ATempVal;
    end
  end;
end;

function TGmPrinterInfo.GetGuttersInch(AOrientation: TGmOrientation): TGmRect;
var
  AGutters: TRect;
begin
  if not FIsUpdated then
    UpdatePrinter;

  AGutters := GetGutters(AOrientation);
  Result.Left   := AGutters.Left / PpiX;
  Result.Top    := AGutters.Top / PpiY;
  Result.Right  := AGutters.Right / PpiX;
  Result.Bottom := AGutters.Bottom / PpiY;
end;

function TGmPrinterInfo.GetOrientation: TGmOrientation;
begin
  UpdatePrinter;
  Result := AsGmOrientation(Printer.Orientation);
end;

function TGmPrinterInfo.GetOrientationRotation: TGmPrinterRotation;
begin
  Result := gmRotate0;
  if not GmOpenPrinter then Exit;
  try
    case DeviceCapabilities(FDevice, FPort, DC_ORIENTATION, nil, nil) of
      90  : Result := gmRotate90;
      270 : Result := gmRotate270;
    end;
  finally
    GmClosePrinter;
  end;
end;

function TGmPrinterInfo.GetPhysicalSizeX: Extended;
begin
  if not FIsUpdated then UpdatePrinter;
  if Printer.Orientation = poPortrait then
    Result := FPhysicalSize.X / FPpi.X
  else
    Result := FPhysicalSize.Y / FPpi.Y;
end;

function TGmPrinterInfo.GetPhysicalSizeY: Extended;
begin
  if not FIsUpdated then UpdatePrinter;
  if Printer.Orientation = poPortrait then
    Result := FPhysicalSize.Y / FPpi.Y
  else
    Result := FPhysicalSize.X / FPpi.X;
end;

function TGmPrinterInfo.GetPpiX: integer;
begin
  if not FIsUpdated then UpdatePrinter;
  if Printer.Orientation = poPortrait then
    Result := FPpi.X
  else
    Result := FPpi.Y;
end;

function TGmPrinterInfo.GetPpiY: integer;
begin
  if not FIsUpdated then UpdatePrinter;
  if Printer.Orientation = poPortrait then
    Result := FPpi.Y
  else
    Result := FPpi.X;
end;

function TGmPrinterInfo.GetPrintableSizeX: Extended;
begin
  if not FIsUpdated then UpdatePrinter;
  Result := FPrintableSize.X / FPpi.X;
end;

function TGmPrinterInfo.GetPrintableSizeY: Extended;
begin
  if not FIsUpdated then UpdatePrinter;
  Result := FPrintableSize.Y / FPpi.Y;
end;

function TGmPrinterInfo.GmOpenPrinter: Boolean;
begin
  Result := False;
  FDeviceMode := 0;
  if Printer.Printers.Count = 0 then Exit;
  Printer.GetPrinter(FDevice, FDriver, FPort, FDeviceMode);
  if FDeviceMode <> 0 Then
  begin
    FDevMode := GlobalLock(FDeviceMode);
    Result := True;
  end;
end;

function TGmPrinterInfo.GetPrinterAvailable: HDC;
var
	{$IFDEF D4+}
  DevMode: Cardinal;
  {$ELSE}
  DevMode: THandle;
  {$ENDIF}
begin
  Printer.GetPrinter(FDevice, FDriver, FPort, DevMode);
  //Printer.SetPrinter(FDevice, FDriver, FPort, 0);
  with TGmPrinterDevice(Printer.Printers.Objects[Printer.PrinterIndex]) do
    Result := CreateIC(PChar(Driver), PChar(Device), PChar(Port), nil);
end;

procedure TGmPrinterInfo.GmClosePrinter;
begin
  if not Printer.Printing then
  begin
    try
      Printer.SetPrinter(FDevice, FDriver, FPort, FDeviceMode);
    except
      Printer.SetPrinter(FDevice, FDriver, FPort, 0);
    end;
  end;
  GlobalUnlock(FDeviceMode);
  FDevMode := nil;
end;

procedure TGmPrinterInfo.ResetPrinter;
var
  TestPrinter: HDC;
begin
  if Printer.Printers.Count > 0 then
  begin
    TestPrinter := GetPrinterAvailable;
    if TestPrinter = 0 then
      FUseDefaultValues := True
    else
    begin
      FUseDefaultValues := False;
      DeleteDC(TestPrinter);
    end;
  end;
  UpdatePrinter;
end;

procedure TGmPrinterInfo.UseDefaultValues;
begin
  FPhysicalSize       := Point(2481, 3507);
  FPrintableSize      := Point(2358, 3407);
  FGutters            := Rect(65, 50, 58, 50);
  FPrintableSize.X    := FPhysicalSize.X - (FGutters.Left + FGutters.Right);
  FPrintableSize.Y    := FPhysicalSize.Y - (FGutters.Top + FGutters.Bottom);
  FPpi                := Point(300, 300);
  FScreenPrinterScale := Screen.PixelsPerInch / FPpi.x;
  FOrientation        := gmPortrait;
  FRotationDirection  := gmRotate90;
end;

procedure TGmPrinterInfo.UpdatePrinter;
var
  LastOrientation: TPrinterOrientation;
begin
  FIsUpdated := True;
  if (Printer.Printers.Count <= 0) or (FUseDefaultValues) then
  begin
    UseDefaultValues;
    Exit;
  end;
  LastOrientation := Printer.Orientation;
  try
    Printer.Orientation := poPortrait;
    FPhysicalSize.x     := GetDeviceCaps(Printer.Handle, PHYSICALWIDTH);
    FPhysicalSize.y     := GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT);
    FPrintableSize.x    := GetDeviceCaps(Printer.Handle, HORZRES);
    FPrintableSize.y    := GetDeviceCaps(Printer.Handle, VERTRES);
    FOrientation        := AsGmOrientation(Printer.Orientation);
    FGutters.Left       := GetDeviceCaps(Printer.Handle, PhysicalOffsetX);
    FGutters.Top        := GetDeviceCaps(Printer.Handle, PhysicalOffsetY);
    FGutters.Right      := FGutters.Left;//FPhysicalSize.x - (FPrintableSize.x + FGutters.Left);
    FGutters.Bottom     := FPhysicalSize.y - (FPrintableSize.y + FGutters.Top);
    FPpi.x              := GetDeviceCaps(Printer.Handle, LogPixelsX);
    FPpi.y              := GetDeviceCaps(Printer.Handle, LogPixelsY);
    FScreenPrinterScale := Screen.PixelsPerInch / FPpi.x;
    FRotationDirection  := GetOrientationRotation;
  finally
    if not Printer.Printing then
    begin
      Printer.Orientation := LastOrientation;
    end;
  end;
end;

//------------------------------------------------------------------------------

// *** TGmPrinter ***

constructor TGmPrinter.Create;
begin
  inherited Create;
  FPrinterInfo := TGmPrinterInfo.Create;
  FFont := TFont.Create;
  FPrinterBins := TStringList.Create;
  FPaperSizes := TStringList.Create;
  FOrientation := gmPortrait;
  FTitle := DEFAULT_TITLE;
  FFileName := '';
  FInitialized := False;
  FPrinting := False;
  FPagesPerSheet := gmOnePage;
  FReversePrintOrder := False;
  if Printers.Count > 0 then
    FPrinterInfo.ResetPrinter;
end;

destructor TGmPrinter.Destroy;
begin
  FPrinterInfo.Free;
  FFont.Free;
  FPrinterBins.Free;
  FPaperSizes.Free;
  inherited Destroy;
end;

function TGmPrinter.GetPaperDimensions(Measurement: TGmMeasurement): TGmSize;
begin
  with FPrinterInfo do
  begin
    Result.Width := ConvertValue(PhysicalSizeX, gmInches, Measurement);
    Result.Height := ConvertValue(PhysicalSizeY, gmInches, Measurement);
  end;
end;

procedure TGmPrinter.Abort;
begin
  if not FPrinting then Exit;
  if Printer.Printing then Printer.Abort;
  FAborted := True;
  FPrinting := False;
  if Assigned(FOnAbortPrint) then FOnAbortPrint(Self);
end;

function TGmPrinter.GetAvailableHeight(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FPrinterInfo.GetAvailableHeight / FPrinterInfo.PpiY, gmInches, Measurement);
end;

function TGmPrinter.GetAvailableWidth(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FPrinterInfo.GetAvailableWidth / FPrinterInfo.PpiX, gmInches, Measurement);
end;

function TGmPrinter.GetCanvas: TCanvas;
begin
  Result := Printer.Canvas;
end;

function TGmPrinter.GetCollate: Boolean;
begin
  Result := False;
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_COLLATE;
      case FDevMode^.dmCollate of
        DMCOLLATE_TRUE     : Result := True;
        DMCOLLATE_FALSE    : Result := False;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

function TGmPrinter.GetDitherType: TGmDitherType;
begin
  Result := gmNone;
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_DITHERTYPE;
      case FDevMode^.dmDitherType of
        DMDITHER_NONE     : Result := gmNone;
        DMDITHER_COARSE   : Result := gmCourse;
        DMDITHER_FINE     : Result := gmFine;
        DMDITHER_LINEART  : Result := gmLineArt;
        DMDITHER_GRAYSCALE: Result := gmGrayScale;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

function TGmPrinter.GetDuplexType: TGmDuplexType;
begin
  Result := gmSimplex;
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      if DeviceCapabilities(FDevice, FPort, DC_DUPLEX, nil, nil) = 1 then;
      begin
        case FDevMode^.dmDuplex of
          DMDUP_SIMPLEX   : Result := gmSimplex;
          DMDUP_HORIZONTAL: Result := gmHorzDuplex;
          DMDUP_VERTICAL  : Result := gmVertDuplex;
        end;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

function TGmPrinter.GetPaperSize: TGmPaperSize;
begin
  Result := Custom;
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_PAPERSIZE;
      Result := AsGmPaperSize(FDevMode^.dmPaperSize);
    finally
      GmClosePrinter;
    end;
  end;
end;

function TGmPrinter.GetPrintColor: TGmPrintColor;
begin
  Result := gmColor;
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_COLOR;
      case FDevMode^.dmColor of
        DMCOLOR_MONOCHROME: Result := gmMonochrome;
        DMCOLOR_COLOR     : Result := gmColor;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

function TGmPrinter.GetPrintCopies: integer;
begin
  Result := 1;
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_COPIES;
     Result := FDevMode^.dmCopies;
    finally
      GmClosePrinter;
    end;
  end;
end;

function TGmPrinter.GetPrintQuality: TGmPrintQuality;
begin
  Result := gmMedium;
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_PRINTQUALITY;
      case FDevMode^.dmPrintQuality of
        Short(DMRES_DRAFT) : Result := gmDraft;
        Short(DMRES_LOW)   : Result := gmLow;
        Short(DMRES_MEDIUM): Result := gmMedium;
        Short(DMRES_HIGH)  : Result := gmHigh;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

function TGmPrinter.GetHandle: THandle;
begin
  Result := Printer.Handle;
end;

function TGmPrinter.GetIndexOf(Value: string): integer;
begin
  Result := Printers.IndexOf(Value);
end;

function TGmPrinter.GetIsColorPrinter: Boolean;
begin
  with FPrinterInfo do
  begin
    if GmOpenPrinter then
    try
      Result := ((FDevMode^.dmFields and DM_COLOR) = DM_COLOR);
    finally
      GmClosePrinter;
    end
    else
      Result := False;
  end;
end;

function TGmPrinter.GetPrinterBinIndex: integer;
type
  BinNumArray = array[0..MAX_PATH] of Word;
var
  NumBins: integer;
  BinNumList: BinNumArray;
  ICount: integer;
begin
  Result := -1;
  with FPrinterInfo do
  begin
    if GmOpenPrinter then
    try
      NumBins := DeviceCapabilities(FDevice, FPort, DC_BINS, nil, nil);
      DeviceCapabilities(FDevice, FPort, DC_BINS, @BinNumList, nil);
      for ICount := 0 to NumBins-1 do
        if BinNumList[ICount] = Word(FDevMode^.dmDefaultSource) then Result := ICount;
    finally
      GmClosePrinter;
    end;
  end;
end;

function TGmPrinter.GetPrinterBins: TStrings;
var
  ICount : Integer;
  ABin : PChar;
begin
  FPrinterBins.Clear;
  with FPrinterInfo do
  begin
    if GmOpenPrinter then
    try
      GetMem(ABin,24*DeviceCapabilities(FDevice, FPort, DC_BINNAMES, nil, nil));
      try
        with FPrinterBins do
        begin
          for ICount := 1 to DeviceCapabilities(FDevice, FPort, DC_BINNAMES, ABin, nil) do
            Add(ABin+24 * (ICount-1));
        end;
      finally
        FreeMem(ABin);
      end;
    finally
      GmClosePrinter;
    end;
  end;
  Result := FPrinterBins;
end;

function TGmPrinter.GetPrinterHeight(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FPrinterInfo.PhysicalSizeY * FPrinterInfo.PpiY, gmInches, Measurement);
end;

function TGmPrinter.GetPrinterIndex: integer;
begin
  Result := Printer.PrinterIndex;
end;

function TGmPrinter.GetPrinters: TStrings;
begin
  Result := Printer.Printers;
end;

function TGmPrinter.GetPrinterSelected: Boolean;
begin
  Result := Printer.Printers.Count > 0;
end;

function TGmPrinter.GetPrinterWidth(Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FPrinterInfo.PhysicalSizeY * FPrinterInfo.PpiY, gmInches, Measurement);
end;

procedure TGmPrinter.AlterOrientation;
begin
  if FPagesPerSheet = gmTwoPage then
  begin
    case FOrientation of
      gmPortrait : FOrientation := gmLandscape;
      gmLandscape: FOrientation := gmPortrait;
    end;
  end;
end;

procedure TGmPrinter.SetCollate(Value: Boolean);
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_COLLATE;
      case Value of
        True : FDevMode^.dmCollate := DMCOLLATE_TRUE;
        False: FDevMode^.dmCollate := DMCOLLATE_FALSE;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

procedure TGmPrinter.SetDitherType(Value: TGmDitherType);
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_DITHERTYPE;
      case Value of
        gmNone      : FDevMode^.dmDitherType := DMDITHER_NONE;
        gmCourse    : FDevMode^.dmDitherType := DMDITHER_COARSE;
        gmFine      : FDevMode^.dmDitherType := DMDITHER_FINE;
        gmLineArt   : FDevMode^.dmDitherType := DMDITHER_LINEART;
        gmGrayScale : FDevMode^.dmDitherType := DMDITHER_GRAYSCALE;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

procedure TGmPrinter.SetDrawingArea(PageNum: integer);
var
  PW, PH: integer;
  AScale: Integer;
  AOffset: TPoint;
  TopHalf,
  BottomHalf,
  LeftHalf,
  RightHalf,
  TopLeftQuater,
  TopRightQuater,
  BottomLeftQuater,
  BottomRightQuater: TRect;
  ViewportRect: TRect;
begin
  with FPrinterInfo do
  begin
    //UpdatePrinter;
    PW := Round(PhysicalSizeX * PpiX);
    PH := Round(PhysicalSizeY * PpiY);
    AOffset := GetGutters(AsGmOrientation(Printer.Orientation)).TopLeft;
  end;
  // calculate pare areas...
  TopHalf    := Rect(0, 0, PW, PH div 2);
  BottomHalf := Rect(0, PH div 2, PW, PH);
  LeftHalf   := Rect(0, 0, PW div 2, PH);
  RightHalf  := Rect(PW div 2, 0, PW, PH);
  TopLeftQuater     := Rect(0, 0, PW div 2, PH div 2);
  TopRightQuater    := Rect(PW div 2, 0, PW, PH div 2);
  BottomLeftQuater  := Rect(0, PH div 2, PW div 2, PH);
  BottomRightQuater := Rect(PW div 2, PH div 2, PW, PH);
  // initialize viewport and scaling values...
  ViewportRect := Rect(0, 0, PW, PH);
  AScale := 100;
  if FPagesPerSheet = gmTwoPage then
  begin
    if FOrientation = gmPortrait then
    begin
      case PageNum mod 2 of
        1: ViewportRect := TopHalf;
        0: ViewportRect := BottomHalf;
      end;
    end
    else
    begin
      case PageNum mod 2 of
        1: ViewportRect := LeftHalf;
        0: ViewportRect := RightHalf;
      end;
    end;
    AScale := Trunc((MinInt(PW, PH) / MaxInt(PW, PH)) * 100);
  end
  else
  if FPagesPerSheet = gmFourPage then
  begin
    case PageNum mod 4 of
      1: ViewportRect := TopLeftQuater;
      2:ViewportRect := TopRightQuater;
      3:ViewportRect := BottomLeftQuater;
      0:ViewportRect := BottomRightQuater;
    end;
    AScale := 49;
  end;
  // set the custom mapping mode...
  SetMapMode(Printer.Canvas.Handle, MM_ANISOTROPIC);
  SetWindowExtEx(Printer.Canvas.Handle, RectWidth(ViewportRect), RectHeight(ViewportRect), nil);
  SetViewportExtEx(Printer.Canvas.Handle,
                   RectWidth(ViewportRect),
                   RectHeight(ViewportRect),
                   nil);
  ScaleViewportExtEx(Printer.Canvas.Handle, AScale, 100, AScale, 100, nil);
  SetViewportOrgEx(Printer.Canvas.Handle,
                   0-AOffset.X + ViewportRect.Left,
                   0-AOffset.Y + ViewportRect.Top, nil);
end;

procedure TGmPrinter.SetDuplexType(Value: TGmDuplexType);
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      if DeviceCapabilities(FDevice, FPort, DC_DUPLEX, nil, nil) = 1 then;
      begin
        case Value of
          gmSimplex   : FDevMode^.dmDuplex := DMDUP_SIMPLEX;
          gmHorzDuplex: FDevMode^.dmDuplex := DMDUP_HORIZONTAL;
          gmVertDuplex: FDevMode^.dmDuplex := DMDUP_VERTICAL;
        end;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

procedure TGmPrinter.SetOrientation(Value: TGmOrientation);
begin
  if FOrientation = Value then Exit;
  FOrientation := Value;
  FPrinterInfo.FOrientation := FOrientation;
  if not FPrinting then FPrinterInfo.UpdatePrinter;
end;

procedure TGmPrinter.SetGmPaperSize(Value: TGmPaperSize);
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_PAPERSIZE;
      FDevMode^.dmPaperSize := AsDmPaperSize(Value);
    finally
      GmClosePrinter;
    end;
  end;
end;

procedure TGmPrinter.SetPrintColor(Value: TGmPrintColor);
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_COLOR;
      case Value of
        gmColor     : FDevMode^.dmColor := DMCOLOR_COLOR;
        gmMonochrome: FDevMode^.dmColor := DMCOLOR_MONOCHROME;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

procedure TGmPrinter.SetPrinterBinIndex(Value: integer);
type
  BinNumArray = array[0..MAX_PATH] of Word;
var
  BinNumList: BinNumArray;
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      DeviceCapabilities(FDevice, FPort, DC_BINS, @BinNumList, nil);
      FDevMode^.dmDefaultSource := BinNumList[Value];
    finally
      GmClosePrinter;
    end;
  end;
end;

procedure TGmPrinter.SetPrintCopies(Value: integer);
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_COPIES;
      FDevMode^.dmCopies := Value;
    finally
      GmClosePrinter;
    end;
  end;
end;

procedure TGmPrinter.SetPrinterIndex(Value: integer);
var
  FDevice, FDriver, FPort: array[0..80] of Char;
  FDeviceMode: THandle;
begin
  Printer.PrinterIndex := Value;
  Printer.GetPrinter(FDevice, FDriver, FPort, FDeviceMode);
  Printer.SetPrinter(FDevice, FDriver, FPort, 0);
  FPrinterInfo.UpdatePrinter;
  if Assigned(FOnChangePrinter) then FOnChangePrinter(Self);
end;

procedure TGmPrinter.SetPrintQuality(Value: TGmPrintQuality);
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      FDevMode^.dmFields := FDevMode^.dmFields or DM_PRINTQUALITY;
      case Value of
        gmDraft : FDevMode^.dmPrintQuality := Short(DMRES_DRAFT);
        gmLow   : FDevMode^.dmPrintQuality := Short(DMRES_LOW);
        gmMedium: FDevMode^.dmPrintQuality := Short(DMRES_MEDIUM);
        gmHigh  : FDevMode^.dmPrintQuality := Short(DMRES_HIGH);
      end;
    finally
      GmClosePrinter;
    end;
  end;
  FPrinterInfo.UpdatePrinter;
end;

procedure TGmPrinter.BeginDoc(FileName: string);
var
  LastIndex: integer;
  TestCanvas: HDC;
begin
  TestCanvas := FPrinterInfo.GetPrinterAvailable;
  try
    if TestCanvas = 0 then
    begin
      ShowMessage('Unable to print... No Printer available.');
      Exit;
    end;
  finally
    DeleteDC(TestCanvas);
  end;
  if (FPrinting) or (Printer.Printers.Count = 0) then Exit;
  FPrinting := True;
  FAborted := False;
  LastIndex := PrinterIndex;
  if Assigned(FBeforePrint) then FBeforePrint(Self);
  if FAborted then Exit;
  if LastIndex <> PrinterIndex then
    SetPrinterIndex(Printer.PrinterIndex);
  AlterOrientation;
  Printer.Orientation := AsPrinterOrientation(FOrientation);
  FPrinterInfo.UpdatePrinter;
  Printer.Title := FTitle;
  Printer.BeginDoc;
  FPrintCount := 1;
  SetDrawingArea(FPrintCount);
  FLastOrientation := FOrientation;
end;

procedure TGmPrinter.NewPage;
var
  NeedNewPage: Boolean;
begin
  Inc(FPrintCount);
  NeedNewPage := False;
  case FPagesPerSheet of
    gmOnePage : NeedNewPage := True;
    gmTwoPage : NeedNewPage := ((FPrintCount-1) mod 2 = 0);
    gmFourPage: NeedNewPage := ((FPrintCount-1) mod 4 = 0);
  end;
  if NeedNewPage then
  begin
    with FPrinterInfo do
    begin
      // start a new printer page of the desired orientation...
      Printer.GetPrinter(FDevice, FDriver, FPort, FDeviceMode);
      FDevMode := GlobalLock(FDevicemode);
      try
        with FDevMode^ do
        begin
          dmFields := dmFields or DM_ORIENTATION;
          if Self.FOrientation = gmPortrait then
            dmOrientation := DMORIENT_PORTRAIT;
          if Self.FOrientation = gmLandscape then
            dmOrientation := DMORIENT_LANDSCAPE;
        end;
        Windows.EndPage(Printer.Handle);
        if FLastOrientation <> FOrientation then
          ResetDC(Printer.Handle, FDevMode^);
      finally
        GlobalUnlock(FDeviceMode);
        Windows.StartPage(Printer.Handle);
      end;
      Printer.Canvas.Refresh;
    end;
  end;
  SetDrawingArea(FPrintCount);
end;

procedure TGmPrinter.EndDoc;
begin
  if not FPrinting then Exit;
  Printer.EndDoc;
  FPrinting := False;
  if Assigned(FAfterPrint) then FAfterPrint(Self);
end;

procedure TGmPrinter.SetDMPaperSize(APaperSize: integer);
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      with FDevMode^ do
      begin
        dmPapersize := APaperSize;
        dmFields := dmFields or DM_PAPERSIZE;
      end;
    finally
      GmClosePrinter;
    end;
  end;
  FPrinterInfo.UpdatePrinter;
end;

procedure TGmPrinter.GetPaperNames(const Papers: TStrings);
type
	TPaperName = array[0..63] of Char;
  TPaperNameArray = array [1..High(Integer) div Sizeof(TPaperName)] of TPaperName;
  PPapernameArray = ^TPaperNameArray;
  TPaperArray = array [1..High(Integer) div Sizeof(Word)] of Word;
  PPaperArray = ^TPaperArray;
Var
  i, numPaperNames, numPapers, temp: Integer;
  pPaperNames: PPapernameArray;
  pPapers: PPaperArray;
begin
  with FPrinterInfo do
  begin
    if not GmOpenPrinter then Exit;
    try
      numPaperNames := WinSpool.DeviceCapabilities(FDevice, FPort, DC_PAPERNAMES, nil, nil);
      numPapers := WinSpool.DeviceCapabilities(FDevice, FPort, DC_PAPERS, nil, nil);
      if numPaperNames > 0 then
      begin
        GetMem(pPaperNames, numPaperNames * Sizeof(TPapername));
        GetMem(pPapers, numPapers * Sizeof(Word));
        try
          WinSpool.DeviceCapabilities(FDevice, FPort, DC_PAPERNAMES,
      		  Pchar(pPaperNames), nil);
          WinSpool.DeviceCapabilities(FDevice, FPort, DC_PAPERS,
            Pchar(pPapers), nil );
          Papers.clear;
          for i:= 1 to numPaperNames Do
          begin
            temp := pPapers^[i];
            Papers.addObject(pPaperNames^[i], TObject(temp));
          end;
        finally
          FreeMem(pPaperNames);
          if pPapers <> nil then FreeMem(pPapers);
        end;
      end;
    finally
      GmClosePrinter;
    end;
  end;
end;

end.
