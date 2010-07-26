unit wppdfRAVE;
{ -----------------------------------------------------------------------------
    RAVE Renderer for wPDF - (C) wpCubed GmbH - www.wptools.de

    Initially Written by Julian Ziersch, 07. May, 2003

    To use this filter place place it on your form (or create it using code)
    and assign the property PDFPrinter to an instance of a TWPDFPrinter
    component. Once you set the 'Active' property to true you can select
    the file format created by this renderer when you save a report from preview

    In contrast to the default PDF renderer included in PDF this enhanced
    product will export metafiles as vectors, not as bitmaps. This will create
    smaller files if the metafiles are big and result in better preview and
    print quality.  You can also use the enhanced security options of wPDF
  ----------------------------------------------------------------------------- }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, RpRave, RpDefine, RpBase, RpSystem, RPRenderCanvas, RpRender, WPPDFR1;

type


  TRvRenderWPDF = class(TRvRenderCanvas)
  private
    FCurrentPage: Integer;
    FResolutionX, FResolutionY: Integer;
    FWPPDFPrinter: TWPCustomPDFExport;
    FPageOpen: Boolean;
    FCloseDoc: Boolean;
    procedure SetPDFPrinter(x: TWPCustomPDFExport);
  protected
    procedure DocBegin; override;
    procedure DocEnd; override;
    procedure PageBegin; override;
    procedure PageEnd; override;
    function GetCanvas: TCanvas; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner: TComponent); override;
    procedure PrintRender(NDStream: TStream; OutputFileName: TFileName); override;
    procedure RenderPage(PageNum: Integer); override;
    procedure Render(ANDRStream: TStream = nil); override;
    function XI2D(Pos: Double): Integer; override;
    function YI2D(Pos: Double): Integer; override;
    property CurrentPage: Integer read FCurrentPage;
  published
    property PDFPrinter: TWPCustomPDFExport read FWPPDFPrinter write SetPDFPrinter;
    property Active;
  end;

const TRvRenderWPDF_FILTER = 'Portable Document Format';

procedure Register;

implementation

const PROPERROR = 'Property PDFPrinter has not been assigned';

procedure Register;
begin
  RegisterComponents('wPDF', [TRvRenderWPDF]);
end;

procedure TRvRenderWPDF.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FWPPDFPrinter) then
    FWPPDFPrinter := nil;
  inherited Notification(AComponent, Operation);
end;

procedure TRvRenderWPDF.SetPDFPrinter(x: TWPCustomPDFExport);
begin
  FWPPDFPrinter := x;
  if FWPPDFPrinter <> nil then FWPPDFPrinter.FreeNotification(Self);
end;

constructor TRvRenderWPDF.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  Version := 'wPDF Rave Renderer - (C) 2003 by wpCubed GmbH, www.wptools.de';
  DisplayName := 'Portable Document Format';
  FileExtension := '*.PDF';
  FResolutionX := 72;
  FResolutionY := 72;
end;

procedure TRvRenderWPDF.PrintRender(NDStream: TStream; OutputFileName: TFileName);
begin
  if FWPPDFPrinter = nil then raise Exception.Create(PROPERROR);
  OutputStream := nil;
  Self.OutputFileName := OutputFileName;
  DocBegin;
  try
    NDRStream := NDStream;
    Render(NDRStream);
  finally
    DocEnd;
  end;
end;

function TRvRenderWPDF.GetCanvas: TCanvas;
begin
  if (FWPPDFPrinter = nil) or not FPageOpen then Result := nil
  else Result := FWPPDFPrinter.Canvas;
end;

procedure TRvRenderWPDF.Render(ANDRStream: TStream = nil);
begin
  if FWPPDFPrinter = nil then raise Exception.Create(PROPERROR);
  if FResolutionX = 0 then FResolutionX := 72;
  if FResolutionY = 0 then FResolutionY := 72;
  inherited Render(ANDRStream);
end;

procedure TRvRenderWPDF.DocBegin;
begin
  if not FWPPDFPrinter.Printing then 
  begin
    if OutputStream <> nil then
    begin
      FWPPDFPrinter.Stream := OutputStream;
      FWPPDFPrinter.InMemoryMode := TRUE;
      FWPPDFPrinter.FileName := '';
    end else
    begin
      FWPPDFPrinter.Stream := nil;
      FWPPDFPrinter.InMemoryMode := FALSE;
      FWPPDFPrinter.FileName := OutputFileName;
    end;
    FWPPDFPrinter.BeginDoc;
    FCloseDoc := TRUE;
  end;
  inherited DocBegin;
end;

procedure TRvRenderWPDF.DocEnd;
begin
  inherited DocEnd;
  if FCloseDoc then
  begin
    FWPPDFPrinter.EndDoc;
    FWPPDFPrinter.Stream := nil;
    FCloseDoc := FALSE;
  end;
end;

function TRvRenderWPDF.XI2D(Pos: Double): Integer;
begin
  Result := Round(Pos * FResolutionX);
end;

function TRvRenderWPDF.YI2D(Pos: Double): Integer;
begin
  Result := Round(Pos * FResolutionY);
end;

procedure TRvRenderWPDF.PageBegin;
begin
  FResolutionX := GetXDPI;
  FResolutionY := GetYDPI;
  FWPPDFPrinter.StartPage(Round(PaperWidth * FResolutionX), Round(PaperHeight * FResolutionY),
    FResolutionX, FResolutionY, 0);
  FWPPDFPrinter.Canvas;
  FPageOpen := TRUE;
  inherited PageBegin;
end;

procedure TRvRenderWPDF.PageEnd;
begin
  inherited PageEnd;
  FWPPDFPrinter.EndPage;
  FPageOpen := FALSE;
end;

procedure TRvRenderWPDF.RenderPage(PageNum: Integer);
begin
  FCurrentPage := PageNum;
  inherited RenderPage(PageNum);
end;

end.

