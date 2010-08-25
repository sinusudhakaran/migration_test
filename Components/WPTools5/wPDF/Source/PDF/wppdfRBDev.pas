{ ----------------------------------------------------------------------------
  ReportBuilder Device for PDF Export with wPDF, the generic PDF printer

  based on unit ppPrnDev.pas (Regular Printer Device)

       Copyright (c) 1996-2002
       Digital Metaphors
       16775 Addison Road, Suite 613
       Dallas, Texas 75248
       www.digital-metaphors.com

  Used with Permissions.
  ----------------------------------------------------------------------------
  adapted by Julian Ziersch, WPCubed GmbH, Munich, Germany, 8. May 2003
  http://www.wptools.de
  ----------------------------------------------------------------------------
  Advantage of this PDF export class:
     Metafiles will be exported as vector graphics, this can reduce file size
     and avoids loss of information. If you are using embedded controls which
     are rendered as images instead of draw commands you will notice a
     big improvement since text will remain *text* in the PDF file.

  wPDF is a universal PDF creation library which support ReportBuilder, the
  word processor WPTools, WPForm, HTMLView etc etc.
  ---------------------------------------------------------------------------- }

// 2.6.2003 JZ: added font.size to DrawText
// 5.7.2003 JZ: added function DrawRotatedText
// 24.1.2005 JZ: added option WPREFPRINTER and fixed DrawBitmap
// 16.3.2005 JZ: added support for ReportBuilder 9

unit wppdfRBDev;

{$DEFINE WPREFPRINTER} // Use Printer as reference for PDF creation Canvas

interface

{$I ppIfDef.pas}
{$I wpdf_inc.inc}

{$DEFINE REPBUILD9} // Define this symbol for ReportBuilder 9 support

uses
  Windows, Classes, ExtCtrls, Graphics, SysUtils, Dialogs, Forms,
  ppDevice, ppTypes, ppUtils, ppFilDev, ppForms, ppDrwCmd,
  ComCtrls, RichEdit
{$IFDEF WPDF_SOURCE}, WPPDFR1_src{$ELSE}, WPPDFR1{$ENDIF}
{$IFDEF REPBUILD9} ,ppBarCod, ppBarCodDrwCmd, ppRichTxDrwCmd {$ENDIF};

type
  TppwPDFDevice = class(TppFileDevice)
  private
    Resolution: Integer;
    FCollatedCopies: Integer;
    FFirstPage: Boolean;
    FEndPrintJob: Boolean;
    FLocked: Boolean;
    FUseGlobal: Boolean;
    FOffset: TPoint;
    FOnEndPage: TppPageEvent;
    FOnStartPage: TppPageEvent;
    FDefaultProducer: string;
    FPDFPrinter: TWPCustomPDFExport;
    function GetCanvas: TCanvas;
    function GetPDFPrinter: TWPCustomPDFExport;
  protected
    procedure DisplayMessage(aPage: TppPage);
    procedure StartPage(aPage: TppPage);
    procedure EndPage(apage: TppPage);
    function SubstituteFont(aFontName: string): string;
    procedure DrawShape(aDrawShape: TppDrawShape); virtual;
    procedure DrawBarCode(aDrawBarCode: TppDrawBarCode); virtual;
    procedure DrawRichEdit(aDrawRichEdit: TppDrawRichText); virtual;
    procedure DrawLine(aDrawLine: TppDrawLine); virtual;
    procedure DrawImage(aDrawImage: TppDrawImage); virtual;
    procedure DrawText(aDrawText: TppDrawText); virtual;
    procedure DrawBMP(aDrawImage: TppDrawImage); virtual;
    procedure DrawGraphic(aDrawImage: TppDrawImage); virtual;
    procedure DirectDrawImage(aDrawImage: TppDrawImage); virtual;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreatePrinter;
    class function DeviceName: string; override;
    class function DefaultExt: string; override;
    class function DefaultExtFilter: string; override;
    class function DeviceDescription(aLanguageIndex: Longint): string; override;
    procedure CancelJob; override;
    function Draw(aDrawCommand: TppDrawCommand): Boolean; override;
    procedure DrawRotatedText(const Text: string;
      Angle, Left, Top, Width, Height: Integer;
      Alignment: TAlignment;
      const Font: TFont);
    procedure EndJob; override;
    procedure ReceivePage(aPage: TppPage); override;
    procedure Reset; override;
    procedure StartJob; override;
    procedure CalcDrawPosition(aDrawCommand: TppDrawCommand);
    procedure ScaleRect(aRect: TRect);
    property Canvas: TCanvas read GetCanvas;
    property EndPrintJob: Boolean read FEndPrintJob write FEndPrintJob;
    property Offset: TPoint read FOffset write FOffset;
    property PDFPrinter: TWPCustomPDFExport read GetPDFPrinter;
    property OnEndPage: TppPageEvent read FOnEndPage write FOnEndPage;
    property OnStartPage: TppPageEvent read FOnStartPage write FOnStartPage;
  end; {class, TppwPDFDevice}


var
  // This is the source for all parameters
  ppReferencePDFPrinter: TWPCustomPDFExport;
  // This will be used instead of the local to create multiple documents in one PDF file
  ppGlobalPDFPrinter: TWPCustomPDFExport;

implementation

uses
  ppPlainText;

const
  cPROGRESS_STRING = 'PDF Export';
  cFileExtension = 'pdf';
  cFileFilter = 'Portable Document Format (*.pdf)|*.pdf';
  cDeviceDescription = 'PDF Export (wpCubed GmbH)';
  cDeviceName = 'dtPDFile'; // portable document file

{******************************************************************************
 *
 ** wPDF D E V I C E        (wPDF: PDF Export by wpCubed GmbH, www.wptools.de)
 *
{******************************************************************************}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.Create }

constructor TppwPDFDevice.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FCollatedCopies := 1;
  FEndPrintJob := True;
  FFirstPage := True;
  FOnEndPage := nil;
  FOnStartPage := nil;
  CreatePrinter;
  Resolution := Screen.PixelsPerInch;
end; {constructor, Create}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.Destroy }

destructor TppwPDFDevice.Destroy;
begin
  FPDFPrinter.Free;
  inherited Destroy;
end; {destructor, Destroy}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.CreatePrinter }

procedure TppwPDFDevice.CreatePrinter;
begin
  if FPDFPrinter <> nil then
  begin
    FPDFPrinter.FRee;
    FPDFPrinter := nil;
  end;
  FPDFPrinter := TWPCustomPDFExport.Create(nil);

  // FPDFPrinter.DebugMode := TRUE;

  FDefaultProducer := FPDFPrinter.Info.Producer;
  FPDFPrinter.Info.Producer := 'wpCubed RB Export Device';
end;

{------------------------------------------------------------------------------}
{ TppwPDFDevice.Reset }

procedure TppwPDFDevice.Reset;
begin
  inherited Reset;
  CreatePrinter;
end;

{------------------------------------------------------------------------------}
{ TppwPDFDevice.DeviceName }

class function TppwPDFDevice.DeviceName: string;
begin
  Result := cDeviceName;
end; {class function, DeviceName}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.DefaultExt }

class function TppwPDFDevice.DefaultExt: string;
begin
  Result := cFileExtension;
end; {class function, DefaultExt}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.DefaultExtFilter }

class function TppwPDFDevice.DefaultExtFilter: string;
begin
  Result := cFileFilter;
end; {class function, DefaultExtFilter}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.DeviceDescription }

class function TppwPDFDevice.DeviceDescription(aLanguageIndex: Longint): string;
begin
  Result := cDeviceDescription;
end; {class function, DeviceDescription}


{------------------------------------------------------------------------------}
{ TppwPDFDevice.GetCanvas }

function TppwPDFDevice.GetCanvas: TCanvas;
begin
  Result := PDFPrinter.Canvas;
end;

{------------------------------------------------------------------------------}
{ TppwPDFDevice.GetPDFPrinter }

function TppwPDFDevice.GetPDFPrinter: TWPCustomPDFExport;
begin
  if FUseGlobal then Result := ppGlobalPDFPrinter
  else Result := FPDFPrinter;
end;

{------------------------------------------------------------------------------}
{ TppwPDFDevice.StartJob }

procedure TppwPDFDevice.StartJob;
var s: string;
begin
  {if we're busy, a print job has already started}
  if (Busy) then Exit;
  SetAutoOpen(FALSE);
  inherited StartJob;
  if ppReferencePDFPrinter <> nil then
  begin
        // Copy all relevant information except for
        // FileName, Stream and 'InMemoryMode'
        // Preserve the 'producer'
    s := FPDFPrinter.Info.Producer;
    FPDFPrinter.Assign(ppReferencePDFPrinter);
    if FDefaultProducer = FPDFPrinter.Info.Producer then
      FPDFPrinter.Info.Producer := s;
  end;
  FPDFPrinter.FileName := FileName;

  FUseGlobal := (ppGlobalPDFPrinter <> nil) and ppGlobalPDFPrinter.Printing;

  if not FUseGlobal then
  try
    {$IFDEF WPREFPRINTER}
    FPDFPrinter.CanvasReference := wprefPrinter;
    {$ENDIF}
    FPDFPrinter.BeginDoc;
    {$IFDEF WPREFPRINTER}
    if FPDFPrinter.ReferenceDC<>0 then
       Resolution := GetDeviceCaps(FPDFPrinter.ReferenceDC, LOGPIXELSY);
    {$ENDIF}
  except
    raise;
  end;
  FFirstPage := True;
end; {procedure, StartJob}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.EndJob }

procedure TppwPDFDevice.EndJob;
begin

  {if we're not busy, there is no print job to end}
  if not (Busy) then Exit;

  {end print job }
  if not FUseGlobal and EndPrintJob then
    FPDFPrinter.EndDoc;

  inherited EndJob;
end; {procedure, EndJob}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.CancelJob }

procedure TppwPDFDevice.CancelJob;
begin
  if not FUseGlobal then FPDFPrinter.EndDoc;
  inherited CancelJob;
end; {procedure, CancelJob}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.ReceivePage }

procedure TppwPDFDevice.ReceivePage(aPage: TppPage);
var
  liCommand: Integer;
  liCommands: Integer;
  lDrawCommand: TppDrawCommand;
begin
  {are we receiving a page we requested?}
  inherited ReceivePage(aPage);

  {have we started the print job?}
  if not (Busy) then Exit;

  if IsRequestedPage then
  begin
    DisplayMessage(aPage);
    if (IsMessagePage) then Exit;

    StartPage(aPage);
    try
      liCommand := 0;
      liCommands := aPage.DrawCommandCount;

      while (liCommand <= liCommands - 1) do
      begin
        lDrawCommand := aPage.DrawCommands[liCommand];

        if (lDrawCommand.Left <= aPage.PageDef.mmWidth) and
          (lDrawCommand.Top <= aPage.PageDef.mmHeight) then

          Draw(lDrawCommand);
      // in contrast to "lDrawCommand.Draw(Self);" which is the standard implementation
      // Some components only work with Screen and Printer devices - we have to get hold of them here


        Inc(liCommand);
      end; {while, each print object}



    finally
      EndPage(aPage);
    end;
  end;
end; {procedure, ReceivePage}


{------------------------------------------------------------------------------}
{ TppwPDFDevice.DisplayMessage }

procedure TppwPDFDevice.DisplayMessage(aPage: TppPage);
var
  lsMessage: string;
  lbReportCompleted: Boolean;
begin

  if (Publisher <> nil) then
    lbReportCompleted := Publisher.ReportCompleted
  else
    lbReportCompleted := True;

  if (aPage = nil) then
  begin
      {message: Accessing data...}
    lsMessage := ppLoadStr(2);
  end

  else if IsMessagePage and not (lbReportCompleted) then
  begin
    if (CancelDialog <> nil) then
      lsMessage := CancelDialog.PrintProgress
    else
      lsMessage := '';
  end

  else if not (lbReportCompleted) then
  begin
      {message: Printing page 1 for <documentname> on <printername>}
    lsMessage := ppLoadStr(27);
    lsMessage := ppSetMessageParameters(lsMessage);
    lsMessage := Format(lsMessage, [IntToStr(aPage.AbsolutePageNo), aPage.DocumentName, cPROGRESS_STRING]);
  end

  else
  begin
      {message: Printing page 1 of 15 for <documentname> on <printername>}
    lsMessage := ppLoadStr(28);
    lsMessage := ppSetMessageParameters(lsMessage);
    lsMessage := Format(lsMessage, [IntToStr(aPage.AbsolutePageNo), IntToStr(aPage.AbsolutePageCount),
      aPage.DocumentName, cPROGRESS_STRING]);

  end;


  if (CancelDialog <> nil) and (CancelDialog.PrintProgress <> lsMessage) then
  begin
    CancelDialog.PrintProgress := lsMessage;

    Application.ProcessMessages;
  end;

end; {procedure, DisplayMessage}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.StartPage }

procedure TppwPDFDevice.StartPage(aPage: TppPage);
begin
  if FFirstPage then FFirstPage := False;
  PDFPrinter.StartPage(Round(aPage.GetScaledWidth(100, utMMThousandths) / 25400 * Resolution),
    Round(aPage.GetScaledHeight(100, utMMThousandths) / 25400 * Resolution), Resolution, Resolution, 0);
  FOffSet.X := 0;
  FOffSet.Y := 0;
  if Assigned(FOnStartPage) then FOnStartPage(Self, aPage);
end; {procedure, StartPage}


{------------------------------------------------------------------------------}
{ TppwPDFDevice.EndPage }

procedure TppwPDFDevice.EndPage(aPage: TppPage);
begin
  PDFPrinter.EndPage;
  if Assigned(FOnEndPage) then FOnEndPage(Self, aPage);
end; {procedure, EndPage}


{------------------------------------------------------------------------------}
{ TppPrinterDevice.ScaleRect}

procedure TppwPDFDevice.ScaleRect(aRect: TRect);
begin
end;

{------------------------------------------------------------------------------}
{ TppwPDFDevice.SubstituteFont (PDF does not allow this fonts) }

function TppwPDFDevice.SubstituteFont(aFontName: string): string;
begin

  if aFontName = 'Courier' then
    Result := 'Courier New'

  else if aFontName = 'Fixedsys' then
    Result := 'Arial'

  else if aFontName = 'Modern' then
    Result := 'Arial'

  else if aFontName = 'MS Sans Serif' then
    Result := 'Arial'

  else if aFontName = 'MS Serif' then
    Result := 'Courier New'

  else if aFontName = 'Small Fonts' then
    Result := 'Arial'

  else if aFontName = 'System' then
    Result := 'Arial'

  else if aFontName = 'Terminal' then
    Result := 'Arial'

  else
    Result := aFontName;

end; {function, SubstituteFont}

{------------------------------------------------------------------------------}
{ TppPrinterDevice.CalcDrawPosition}

procedure TppwPDFDevice.CalcDrawPosition(aDrawCommand: TppDrawCommand);
begin
  aDrawCommand.DrawLeft := FOffset.X + MulDiv(aDrawCommand.Left, Resolution, 25400);
  aDrawCommand.DrawTop := FOffset.Y + MulDiv(aDrawCommand.Top, Resolution, 25400);
  aDrawCommand.DrawRight := FOffset.X + MulDiv(aDrawCommand.Left + aDrawCommand.Width, Resolution, 25400);
  aDrawCommand.DrawBottom := FOffset.Y + MulDiv(aDrawCommand.Top + aDrawCommand.Height, Resolution, 25400);
end;

{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawRotatedText }

procedure TppwPDFDevice.DrawRotatedText(const Text: string;
  Angle, Left, Top, Width, Height: Integer;
  Alignment: TAlignment;
  const Font: TFont);
begin
  PDFPrinter.DrawRotatedText(Text,
    Angle, Left, Top, Width, Height,
    Alignment, Font);
end;

{------------------------------------------------------------------------------}
{ TppwPDFDevice.Draw }

function TppwPDFDevice.Draw(aDrawCommand: TppDrawCommand): Boolean;
begin
  Result := True;

  CalcDrawPosition(aDrawCommand);

  if (aDrawCommand is TppDrawText) then
    DrawText(TppDrawText(aDrawCommand))

  else if (aDrawCommand is TppDrawShape) then
    DrawShape(TppDrawShape(aDrawCommand))

  else if (aDrawCommand is TppDrawBarCode) then
    DrawBarCode(TppDrawBarCode(aDrawCommand))

  else if (aDrawCommand is TppDrawLine) then
    DrawLine(TppDrawLine(aDrawCommand))

  else if (aDrawCommand is TppDrawImage) then
    DrawImage(TppDrawImage(aDrawCommand))

  else if (aDrawCommand is TppDrawRichText) then
    DrawRichEdit(TppDrawRichText(aDrawCommand))

  else if not FLocked then try FLocked := TRUE;
    Result := aDrawCommand.Draw(Self);
  finally FLocked := FALSE; end;
end; {function, Draw}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawLine }

procedure TppwPDFDevice.DrawLine(aDrawLine: TppDrawLine);
var
  liOffset: Integer;
  liLines: Integer;
  liLine: Integer;
  llSize: Longint;
  llPosition: Longint;
  FCanvas: TCanvas;
begin
  FCanvas := Canvas;

  { if (aDrawLine.LinePosition = lpLeft) or (aDrawLine.LinePosition = lpRight) then
    lResolution := pprtVertical
  else
    lResolution := pprtHorizontal; }


  if (aDrawLine.LinePosition = lpLeft) or (aDrawLine.LinePosition = lpRight) then
    llSize := Round(aDrawLine.Weight * Resolution / 72)
  else
    llSize := Round(aDrawLine.Weight * Resolution / 72);


  {if pen width is zero, print a hairline}
  if llSize = 0 then
    llSize := 1;

 {  if (aDrawLine.Pen.Width = 0) then
    llSize := 1
  else
    llSize := Trunc(ppFromScreenPixels(aDrawLine.Pen.Width, utPrinterPixels, lResolution, FPrinter));
 }

  {how many lines to draw?}
  if aDrawLine.LineStyle = lsSingle then
    liLines := 1
  else
    liLines := 2;

  {set actual pen width to one, to honor Pen.Style for wide lines}
  FCanvas.Pen := aDrawLine.Pen;
  FCanvas.Pen.Width := 1;

  for liLine := 1 to liLines do

  begin

    if (liLine = 1) then
      liOffset := 0

    else if (aDrawLine.Pen.Width = 0) then

      liOffset := MulDiv(2, Resolution, Screen.PixelsPerInch)
    else
      liOffset := llSize * 2;

    for llPosition := 0 to llSize - 1 do

      {set print object moveto/lineto positions}
      case aDrawLine.LinePosition of
        lpTop:
          begin
            FCanvas.MoveTo(aDrawLine.DrawLeft, aDrawLine.DrawTop + liOffset + llPosition);
            FCanvas.LineTo(aDrawLine.DrawRight, aDrawLine.DrawTop + liOffset + llPosition);
          end;

        lpBottom:
          begin
            FCanvas.MoveTo(aDrawLine.DrawLeft, aDrawLine.DrawBottom - liOffset - llPosition);
            FCanvas.LineTo(aDrawLine.DrawRight, aDrawLine.DrawBottom - liOffset - llPosition);
          end;

        lpLeft:
          begin
            FCanvas.MoveTo(aDrawLine.DrawLeft + liOffset + llPosition, aDrawLine.DrawTop);
            FCanvas.LineTo(aDrawLine.DrawLeft + liOffset + llPosition, aDrawLine.DrawBottom);
          end;

        lpRight:
          begin
            FCanvas.MoveTo(aDrawLine.DrawRight - liOffset - llPosition, aDrawLine.DrawTop);
            FCanvas.LineTo(aDrawLine.DrawRight - liOffset - llPosition, aDrawLine.DrawBottom);
          end;

      end; {case, line style}

  end; {for, each line}

end; {procedure, DrawLine}


{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawShape }

procedure TppwPDFDevice.DrawShape(aDrawShape: TppDrawShape);
var
  liXCornerRound: Integer;
  liYCornerRound: Integer;
  FCanvas: TCanvas;
begin
  FCanvas := Canvas;

  {assign pen and brush}
  FCanvas.Pen := aDrawShape.Pen;
  FCanvas.Brush := aDrawShape.Brush;

  {get pen width}
  if (aDrawShape.Pen.Width = 0) then
    {if pen width is zero, print a hairline}
    FCanvas.Pen.Width := 1
  else
    {convert pen width to printer pixels}
    FCanvas.Pen.Width :=
      MulDiv(aDrawShape.Pen.Width, Resolution, Screen.PixelsPerInch);

  {draw shape}
  case aDrawShape.ShapeType of

    stRectangle:
      {since most printers cannot handle transparency, use PolyLine when applicable}
      if (aDrawShape.Brush.Style = bsClear) then
        FCanvas.PolyLine([Point(aDrawShape.DrawLeft, aDrawShape.DrawTop),
          Point(aDrawShape.DrawRight, aDrawShape.DrawTop),
            Point(aDrawShape.DrawRight, aDrawShape.DrawBottom),
            Point(aDrawShape.DrawLeft, aDrawShape.DrawBottom),
            Point(aDrawShape.DrawLeft, aDrawShape.DrawTop)])
      else
        FCanvas.Rectangle(aDrawShape.DrawLeft, aDrawShape.DrawTop,
          aDrawShape.DrawRight, aDrawShape.DrawBottom);

    stEllipse:
      FCanvas.Ellipse(aDrawShape.DrawLeft, aDrawShape.DrawTop,
        aDrawShape.DrawRight, aDrawShape.DrawBottom);

    stRoundRect:
      begin
        liXCornerRound := Trunc(aDrawShape.XCornerRound / 25400 * Resolution);
        liYCornerRound := Trunc(aDrawShape.YCornerRound / 25400 * Resolution);

        FCanvas.RoundRect(aDrawShape.DrawLeft, aDrawShape.DrawTop,
          aDrawShape.DrawRight, aDrawShape.DrawBottom,
          liXCornerRound, liYCornerRound);

      end; {case, RoundRect}

  end; {case, ShapeType}

end; {procedure, DrawShape}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawBarCode }

procedure TppwPDFDevice.DrawBarCode(aDrawBarCode: TppDrawBarCode);
var
  FCanvas: TCanvas;
begin
  FCanvas := Canvas;
  aDrawBarcode.CalcBarCodeSize(FCanvas);
  aDrawBarcode.DrawBarCode(
    FCanvas,
    aDrawBarcode.DrawLeft, aDrawBarcode.DrawTop,
    Point(Resolution, Resolution), {aRender=} True);
end;


{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawRichEdit }

procedure TppwPDFDevice.DrawRichEdit(aDrawRichEdit: TppDrawRichText);
var
  FCanvas: TCanvas;
  lCharRange: TCharRange;
  lRichEdit: TCustomRichEdit;
  lSaveFont: TFont;
begin
  FCanvas := Canvas;
  lSaveFont := TFont.Create;
  lRichEdit := ppCreateRichEdit(nil);
  try
  {transfer the RTF data to the global ppRichEdit object }
    aDrawRichEdit.RichTextStream.Position := 0;
    ppGetRichEditLines(lRichEdit).LoadFromStream(aDrawRichEdit.RichTextStream);
    lCharRange.cpMin := aDrawRichEdit.StartCharPos;
    lCharRange.cpMax := aDrawRichEdit.EndCharPos;
    lSaveFont.Assign(FCanvas.Font);
    if not aDrawRichEdit.Transparent then
    begin
      FCanvas.CopyMode := cmSrcCopy;
      FCanvas.Brush.Style := bsSolid;
      FCanvas.Brush.Color := aDrawRichEdit.Color;
      FCanvas.FillRect(aDrawRichEdit.DrawRect);
    end;
    FCanvas.Brush.Style := bsClear;
    TppRTFEngine.DrawRichText(lRichEdit, FCanvas.Handle, FCanvas.Handle, aDrawRichEdit.DrawRect, lCharRange);
    FCanvas.Font.Assign(lSaveFont);
  finally
    lSaveFont.Free;
    lRichEdit.Free;
  end;
end;
{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawImage }

procedure TppwPDFDevice.DrawImage(aDrawImage: TppDrawImage);
begin
  if (aDrawImage = nil) or (aDrawImage.Picture = nil) or
    (aDrawImage.Picture.Graphic = nil) or (aDrawImage.Picture.Graphic.Empty) then Exit;

  if aDrawImage.Picture.Graphic is TBitmap then
  begin
    if aDrawImage.AsBitmap.Monochrome and aDrawImage.DirectDraw then
      DirectDrawImage(aDrawImage)
    else
      DrawBMP(aDrawImage);
  end

  else if aDrawImage.DirectDraw then
    DirectDrawImage(aDrawImage)

  else if (aDrawImage.AsBitmap <> nil) then
    DrawBMP(aDrawImage)

  else
    DrawGraphic(aDrawImage);

end; {procedure, DrawImage}
{------------------------------------------------------------------------------}
{ TppwPDFDevice.DirectDrawImage }


{$DEFINE USEOFFSETCODE}  // OFF (works but does not work better)
{--$DEFINE NOCLIPP} // OFF!

procedure TppwPDFDevice.DirectDrawImage(aDrawImage: TppDrawImage);
var
  FCanvas: TCanvas;
  lDrawRect: TRect;
  liImageWidth: Integer;
  liImageHeight: Integer;
  liControlWidth: Integer;
  liControlHeight: Integer;
  lfScale: Single;
  liScaledWidth: Integer;
  liScaledHeight: Integer;
  savedDC: Integer;
  off: TPoint;
begin
  FCanvas := Canvas;

  if aDrawImage.Transparent then
    FCanvas.CopyMode := cmSrcAnd
  else
    FCanvas.CopyMode := cmSrcCopy;


  {initialize}
  lDrawRect := aDrawImage.DrawRect;

{$IFDEF USEOFFSETCODE}
  savedDC := SaveDC(FCanvas.Handle);
  GetViewportOrgEx(FCanvas.Handle, off);
  inc(off.X, lDrawRect.Left);
  inc(off.Y, lDrawRect.Top);
  lDrawRect.Right := lDrawRect.Right - lDrawRect.Left;
  lDrawRect.Bottom := lDrawRect.Bottom - lDrawRect.Top;
  lDrawRect.Left := 0;
  lDrawRect.Top := 0;
  SetViewportOrgEx(FCanvas.Handle, off.x, off.y, nil);
{$ENDIF}

  {compute control dimensions in printer pixels}
  liControlWidth := lDrawRect.Right - lDrawRect.Left;
  liControlHeight := lDrawRect.Bottom - lDrawRect.Top;


  {compute image dimensions in printer pixels}
  liImageWidth := MulDiv(aDrawImage.Picture.Graphic.Width, Resolution, Screen.PixelsPerInch);
  liImageHeight := MulDiv(aDrawImage.Picture.Graphic.Height, Resolution, Screen.PixelsPerInch);


  if aDrawImage.Stretch then
  begin

      {scale the draw rect to maintain aspect ratio, if needed }
    if aDrawImage.MaintainAspectRatio then
    begin
      lfScale := ppCalcAspectRatio(liImageWidth, liImageHeight, liControlWidth, liControlHeight);

      liScaledWidth := Trunc(liImageWidth * lfScale);
      liScaledHeight := Trunc(liImageHeight * lfScale);

      if aDrawImage.Center then
      begin
        lDrawRect.Left := lDrawRect.Left + ((liControlWidth - liScaledWidth) div 2);
        lDrawRect.Top := lDrawRect.Top + ((liControlHeight - liScaledHeight) div 2);
      end;

      lDrawRect.Right := lDrawRect.Left + liScaledWidth;
      lDrawRect.Bottom := lDrawRect.Top + liScaledHeight;

    end;

      {draw image}
    FCanvas.StretchDraw(lDrawRect, aDrawImage.Picture.Graphic);

  end

  else
  begin


{$IFNDEF NOCLIPP}
{$IFDEF USEOFFSETCODE}
      {set clipping region - SaveDC!}
    SelectClipRgn(FCanvas.Handle, 0);
    IntersectClipRect(FCanvas.Handle, lDrawRect.Left,
       lDrawRect.Top, lDrawRect.Right, lDrawRect.Bottom);
{$ELSE}
    GetClipRgn(FCanvas.Handle, lSaveClipRgn);
      {set clipping region}
    lNewClipRgn := CreateRectRgnIndirect(lDrawRect);
    SelectClipRgn(FCanvas.Handle, lNewClipRgn);
{$ENDIF}
{$ELSE}
    SelectClipRgn(FCanvas.Handle, 0);
{$ENDIF}


    if aDrawImage.Center then
    begin
      lDrawRect.Left := lDrawRect.Left + ((liControlWidth - liImageWidth) div 2);
      lDrawRect.Top := lDrawRect.Top + ((liControlHeight - liImageHeight) div 2);
    end;

    lDrawRect.Right := lDrawRect.Left + liImageWidth;
    lDrawRect.Bottom := lDrawRect.Top + liImageHeight;

    FCanvas.StretchDraw(lDrawRect, aDrawImage.Picture.Graphic);

      {restore clipping region}
{$IFNDEF NOCLIPP}
{$IFNDEF USEOFFSETCODE}
    SelectClipRgn(FCanvas.Handle, lSaveClipRgn);
    DeleteObject(lNewClipRgn);
{$ENDIF}
{$ENDIF}

  end;

{$IFDEF USEOFFSETCODE}
  RestoreDC(FCanvas.Handle, saveddc);
{$ENDIF}

end; {procedure, DirectDrawImage}
{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawBMP }

procedure TppwPDFDevice.DrawBMP(aDrawImage: TppDrawImage);
var
  lSaveClipRgn: HRGN;
  lNewClipRgn: HRGN;
  lDrawRect: TRect;
  liImageWidth: Integer;
  liImageHeight: Integer;
  liControlWidth: Integer;
  liControlHeight: Integer;
  lfScale: Single;
  liScaledWidth: Integer;
  liScaledHeight: Integer;
  FCanvas: TCanvas;
begin
  FCanvas := Canvas;

  if aDrawImage.Transparent then
    FCanvas.CopyMode := cmSrcAnd
  else
    FCanvas.CopyMode := cmSrcCopy;


  {initialize}
  lDrawRect := aDrawImage.DrawRect;

  {compute control dimensions in printer pixels}
  liControlWidth := lDrawRect.Right - lDrawRect.Left;
  liControlHeight := lDrawRect.Bottom - lDrawRect.Top;

  {compute image dimensions in printer pixels}
  liImageWidth := MulDiv(aDrawImage.Picture.Graphic.Width, Resolution, Screen.PixelsPerInch);
  liImageHeight := MulDiv(aDrawImage.Picture.Graphic.Height, Resolution, Screen.PixelsPerInch);

  if aDrawImage.Stretch then
  begin

      {scale the draw rect to maintain aspect ration, if needed }
    if aDrawImage.MaintainAspectRatio then
    begin

      lfScale := ppCalcAspectRatio(liImageWidth, liImageHeight, liControlWidth, liControlHeight);

      liScaledWidth := Trunc(liImageWidth * lfScale);
      liScaledHeight := Trunc(liImageHeight * lfScale);

      if aDrawImage.Center then
      begin
        lDrawRect.Left := lDrawRect.Left + ((liControlWidth - liScaledWidth) div 2);
        lDrawRect.Top := lDrawRect.Top + ((liControlHeight - liScaledHeight) div 2);
      end;

      lDrawRect.Right := lDrawRect.Left + liScaledWidth;
      lDrawRect.Bottom := lDrawRect.Top + liScaledHeight;

    end;

      {draw the bmp to the device}
   { if aDrawImage.Transparent then
      ppDrawTransparentDIBitmap(FCanvas, lDrawRect, aDrawImage.AsBitmap, cmSrcCopy)
    else
      ppDrawDIBitmap(FCanvas, lDrawRect, aDrawImage.AsBitmap, cmSrcCopy);  }

    FCanvas.StretchDraw(lDrawRect, aDrawImage.AsBitmap);


  end

  else
  begin

    lSaveClipRgn := 0;
    GetClipRgn(FCanvas.Handle, lSaveClipRgn);

      {set clipping region}
    lNewClipRgn := CreateRectRgnIndirect(aDrawImage.DrawRect);
    SelectClipRgn(FCanvas.Handle, lNewClipRgn);


    if aDrawImage.Center then
    begin
      lDrawRect.Left := lDrawRect.Left + ((liControlWidth - liImageWidth) div 2);
      lDrawRect.Top := lDrawRect.Top + ((liControlHeight - liImageHeight) div 2);
    end;

    lDrawRect.Right := lDrawRect.Left + liImageWidth;
    lDrawRect.Bottom := lDrawRect.Top + liImageHeight;

      {draw the clipped bmp to the device}
    if aDrawImage.Transparent then
      ppDrawTransparentDIBitmap(FCanvas, lDrawRect, aDrawImage.AsBitmap, cmSrcCopy)
    else
      ppDrawDIBitmap(FCanvas, lDrawRect, aDrawImage.AsBitmap, cmSrcCopy);

      {restore clipping region}
    SelectClipRgn(FCanvas.Handle, lSaveClipRgn);

    DeleteObject(lNewClipRgn);

  end;

end; {procedure, DrawBMP}


{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawGraphic }

procedure TppwPDFDevice.DrawGraphic(aDrawImage: TppDrawImage);
var
  lClipRect: TRect;
  liPictureWidth, liPictureHeight: Longint;
  liDrawWidth, liDrawHeight: Longint;
  lfScale: Single;
  liScaledWidth: Integer;
  liScaledHeight: Integer;
  FCanvas: TCanvas;
begin
  FCanvas := Canvas;

  {calc size of image in PrinterPixels}
  liPictureWidth := MulDiv(aDrawImage.Picture.Width, Resolution, Screen.PixelsPerInch);
  liPictureHeight := MulDiv(aDrawImage.Picture.Height, Resolution, Screen.PixelsPerInch);

  {calc size of draw command in PrinterPixels}
  liDrawWidth := aDrawImage.DrawRight - aDrawImage.DrawLeft;
  liDrawHeight := aDrawImage.DrawBottom - aDrawImage.DrawTop;

  {compute clipping rect based on control size & picture size }
  if aDrawImage.Stretch and aDrawImage.MaintainAspectRatio then
  begin

    lClipRect := Rect(0, 0, liDrawWidth, liDrawHeight);

    lfScale := ppCalcAspectRatio(liPictureWidth, liPictureHeight, liDrawWidth, liDrawHeight);

    liScaledWidth := Trunc(liPictureWidth * lfScale);
    liScaledHeight := Trunc(liPictureHeight * lfScale);

    if aDrawImage.Center then
    begin
      lClipRect.Left := lClipRect.Left + ((liDrawWidth - liScaledWidth) div 2);
      lClipRect.Top := lClipRect.Top + ((liDrawHeight - liScaledHeight) div 2);
    end;

    lClipRect.Right := lClipRect.Left + liScaledWidth;
    lClipRect.Bottom := lClipRect.Top + liScaledHeight;


  end
  else if aDrawImage.Stretch then
    lClipRect := Rect(0, 0, liDrawWidth, liDrawHeight)

  else if aDrawImage.Center then
    lClipRect := Bounds((liDrawWidth - liPictureWidth) div 2, (liDrawHeight - liPictureHeight) div 2,
      liPictureWidth, liPictureHeight)
  else
    lClipRect := Rect(0, 0, liPictureWidth, liPictureHeight);

  FCanvas.StretchDraw(aDrawImage.DrawRect, aDrawImage.Picture.Graphic);
  (* This all we don't need with wPDF

   {create a device compatible canvas in memory - with the required dimensions}
  lMemCanvas := TppDeviceCompatibleCanvas.Create(FCanvas.Handle, liDrawWidth, liDrawHeight, aDrawImage.Picture.Graphic.Palette);

  {draw the graphic to the temp canvas and clip}
  if (aDrawImage.Picture.Graphic is TBitmap) then

    ppDrawDIBitmap(lMemCanvas, lClipRect, aDrawImage.Picture.Bitmap, cmSrcCopy)
  else
    lMemCanvas.StretchDraw(lClipRect, aDrawImage.Picture.Graphic);

  if aDrawImage.Transparent then
    lCopyMode := cmSrcAnd
  else
    lCopyMode := cmSrcCopy;

  {render the graphic to the device canvas}
  lMemCanvas.RenderToDevice(aDrawImage.DrawRect, aDrawImage.Picture.Graphic.Palette, lCopyMode);


  lMemCanvas.Free;   *)

end; {procedure, DrawGraphic}

{------------------------------------------------------------------------------}
{ TppwPDFDevice.DrawText }

procedure TppwPDFDevice.DrawText(aDrawText: TppDrawText);
var
  liLineHeight: Integer;
  liLineSpaceUsed: Integer;
  liLines: Integer;
  liLine: Integer;
  lDrawRect: TRect;
  lRect: TRect;
  lCalcRect: TRect;
  liRectWidth: Integer;
  liTextWidth: Integer;
  lSourceText: TStringList;
  lsLine: string;
  liStart: Integer;
  liLeading: Integer;
  lLineBuf: PChar;
  lTextMetric: TTextMetric;
  llRectHeight: Longint;
  llCalcHeight: Longint;
  liTabStopCount: Integer;
  lTabStopArray: TppTabStopPos;
  liTop: Integer;
  liMaxWidth: Integer;
  lbFullJustification: Boolean;
  FCanvas: TCanvas;
begin
  FCanvas := Canvas;
  liTabStopCount := 0;

  {convert memo tab stop positions to printer units, if needed }
 //TODO if aDrawText.IsMemo and (aDrawText.TabStopPositions.Count > 0) then
 //TODO   TppPlainText.ConvertTabStopPos(utPrinterPixels, aDrawText.TabStopPositions, lTabStopArray, liTabStopCount, FPrinter);

  if (FCanvas.Font.CharSet <> aDrawText.Font.CharSet) or
    (FCanvas.Font.Color <> aDrawText.Font.Color) or
    (FCanvas.Font.Pitch <> aDrawText.Font.Pitch) or
    (FCanvas.Font.Size <> aDrawText.Font.Size) or
    (FCanvas.Font.Style <> aDrawText.Font.Style) or
    (FCanvas.Font.Name <> aDrawText.Font.Name) then


    FCanvas.Font.Color := aDrawText.Font.Color;

  {maybe we can't use the selected font}
  FCanvas.Font.Charset := aDrawText.Font.Charset;
  FCanvas.Font.Name := SubstituteFont(aDrawText.Font.Name);


  // Set font size etc...
  FCanvas.Font.Size := aDrawText.Font.Size;
  FCanvas.Font.Style := aDrawText.Font.Style;

  {calc line height}
  GetTextMetrics(FCanvas.Handle, lTextMetric);

  {use default leading for this font}
  if not (aDrawText.IsMemo) then
    liLeading := lTextMetric.tmExternalLeading

  else
    {scale leading specified by user for printer }
    liLeading := Trunc(aDrawText.Leading / 25400 * Resolution);

  liLineHeight := lTextMetric.tmHeight + liLeading;

  lDrawRect := Rect(aDrawText.DrawLeft, aDrawText.DrawTop, aDrawText.DrawRight, aDrawText.DrawBottom);

  {adjust bounding rect height}
  if aDrawText.AutoSize and not (aDrawText.WordWrap) and (Length(aDrawText.Text) > 0) then
  begin
    llRectHeight := lDrawRect.Bottom - lDrawRect.Top;
    llCalcHeight := liLineHeight;

    if (llCalcHeight > llRectHeight) then
      lDrawRect.Bottom := lDrawRect.Top + llCalcHeight;

  end;

  liLines := aDrawText.WrappedText.Count - 1;

  lSourceText := TStringList.Create;

  if aDrawText.WordWrap then
    lSourceText.Assign(aDrawText.WrappedText)

  else if (Length(aDrawText.Text) > 0) then
  begin
    lSourceText.Add(aDrawText.Text);

    liLines := 0;
  end;

  {set rectangle to original value}
  lCalcRect := lDrawRect;

  {calculate rectangle width based on longest text}
  if aDrawText.AutoSize then
  begin

    liMaxWidth := 0;

      {calc max line width}
    for liLine := 0 to liLines do
    begin
      lsLine := lSourceText[liLine];

      liTextWidth := TppPlainText.GetTabbedTextWidth(FCanvas, lsLine, liTabStopCount, lTabStopArray);

      if liTextWidth > liMaxWidth then
        liMaxWidth := liTextWidth;
    end;

    liRectWidth := (lCalcRect.Right - lCalcRect.Left);

      {if text wider than rectangle, adjust rectangle}
    if (liMaxWidth <> liRectWidth) then
    begin

          {adjust rectangle}
      if aDrawText.Alignment = taLeftJustify then
        lCalcRect.Right := lCalcRect.Left + liMaxWidth

      else if aDrawText.Alignment = taRightJustify then
        lCalcRect.Left := lCalcRect.Right - liMaxWidth

      else if aDrawText.Alignment = taCenter then
      begin
        lCalcRect.Left := lCalcRect.Left + Round((liRectWidth - liMaxWidth) / 2);
        lCalcRect.Right := lCalcRect.Left + liMaxWidth;
      end;

    end; {text wider than rectangle}

  end; {if, AutoSize}

  {fill rectangle with background color}
  if not (aDrawText.Transparent) then
  begin
    FCanvas.Brush.Color := aDrawText.Color;
    FCanvas.Brush.Style := bsSolid;
    FCanvas.FillRect(lCalcRect);
  end;

  FCanvas.Brush.Style := bsClear;

  FCanvas.TextFlags := 0;

  liLineSpaceUsed := 0;

  lbFullJustification := False;

  for liLine := 0 to liLines do
  begin
    lsLine := lSourceText[liLine];

    liRectWidth := (lCalcRect.Right - lCalcRect.Left);

      {reset rectangle to original value}
    lRect := lCalcRect;

    lRect.Top := lRect.Top + liLineSpaceUsed;

    liTop := lRect.Top;

      {justify text}
    if (aDrawText.TextAlignment = taFullJustified) then
    begin
      liStart := lRect.Left;

      if aDrawText.ForceJustifyLastLine or (Pos(TppTextMarkups.EOP, lsLine) = 0) then
      begin
        if (Pos(TppTextMarkups.EOP, lsLine) <> 0) and (Pos(TppTextMarkups.Space, Trim(lsLine)) = 0) then
        begin
          lbFullJustification := False;
          SetTextJustification(FCanvas.Handle, 0, 0);
          lsLine := TppPlainText.StringStrip(lsLine, TppTextMarkups.EOP);
        end
        else
        begin
          lbFullJustification := True;
          TppPlainText.SetCanvasToJustify(FCanvas, lRect, lsLine, liTabStopCount, lTabStopArray);
          lsLine := TppPlainText.StringStrip(lsLine, TppTextMarkups.EOP);
        end;
      end

      else
      begin
        lbFullJustification := False;
        SetTextJustification(FCanvas.Handle, 0, 0);
        lsLine := TppPlainText.StringStrip(lsLine, TppTextMarkups.EOP);
      end;
    end

    else
    begin
      liTextWidth := TppPlainText.GetTabbedTextWidth(FCanvas, lsLine, liTabStopCount, lTabStopArray);

      if aDrawText.TextAlignment = taLeftJustified then
        liStart := lRect.Left

      else if aDrawText.TextAlignment = taRightJustified then
        liStart := lRect.Right - liTextWidth

      else if aDrawText.TextAlignment = taCentered then
        liStart := lRect.Left + Round(((liRectWidth - liTextWidth) / 2) - 0.5)

      else
        liStart := 0;
    end;


      {draw the text}
    if aDrawText.IsMemo then
    begin
      lLineBuf := StrAlloc(Length(lsLine) + 1);
      StrPCopy(lLineBuf, lsLine);
      TabbedTextOut(FCanvas.Handle, liStart, liTop, lLineBuf, StrLen(lLineBuf), liTabStopCount, lTabStopArray, liStart);
      StrDispose(lLineBuf);
    end

    else
      FCanvas.TextRect(lRect, liStart, liTop, lsLine);

      {goto next line}
    Inc(liLineSpaceUsed, liLineHeight);
  end; {for, each line of text}

  {must clear full justification mode or GetTabbedTextWidth will fail next time.}
  if (lbFullJustification) then
    SetTextJustification(FCanvas.Handle, 0, 0);

  lSourceText.Free;

  {update size of draw rect}
  if aDrawText.AutoSize then
  begin
    aDrawText.DrawLeft := lCalcRect.Left;
    aDrawText.DrawRight := lCalcRect.Right;
    aDrawText.DrawBottom := aDrawText.DrawTop + liLineSpaceUsed;
  end;

end; {procedure, DrawText}

{******************************************************************************
 *
 ** I N I T I A L I Z A T I O N   /   F I N A L I Z A T I O N
 *
{******************************************************************************}

initialization

  ppRegisterDevice(TppwPDFDevice);

finalization

  ppUnRegisterDevice(TppwPDFDevice);

end.

