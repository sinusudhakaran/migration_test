unit WPCTRPrint;
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// Many Thanks to Richard Diamond for his mods and testing
//******************************************************************************
// WPCTRPrint - WPTools 5 print utility. Helps to print booklets
// and labels using WPTools 5
//******************************************************************************

// 25.10.2004: Experimental!

{$I WPINC.INC}

interface

uses
{$IFDEF CLR}
  System.Text,
  System.Runtime.InteropServices, // for PasteFromClipboard
{$ENDIF}
  Windows, Forms, Menus, SysUtils, StdCtrls, ExtCtrls, Messages,
  Classes, Controls, Graphics, Dialogs, WPRTEDefs, WPRTEPaint,
  Printers, WinSpool, ClipBrd, WPIO, WPCTRMemo;

type

  TWPSuperPrintImageModes = set of (
    wpImgTile, wpImgStretch,
    wpImagMultiPage,
    wpImgStretchAspectRatio,
    wpImgHCenter, wpImgVCenter, wpImgRight, wpImgBottom);

  TWPSuperPrintMode = (
    wpprMultiPage,  // works like wpprLabels but does not create copies fo same page. Used to save paper
    wpprLabels,     // Simple printing mode. The property 'Copies' will create multiple copies of the same page
    wpprPageColRows,// The page height/width is calculated using col*row the page size
    wpprBooklet     // wpprPageColRows + special swaping of page order
    );


  {:: This event will be triggered for all rectangles in the order top-left to bottom-right.
     For booklet printing you can add code to automatically calculate the
     text page number which should be used for a certain rectangle. }
  TWPSuperPrintCalcPageNumber = procedure(
    Sender: TObject;
    RectangleNr: Integer;
    OnPageNr: Integer;
    var TextPageNr: Integer;
    var Rotated: Boolean) of object;

  TWPSuperPrintLandscape =
    (wpprLandscapeOff, // do not swap page width and height
    wpprLandscapeAuto, // swap page width and height if column count is even
    wpprLandscapeOn // always swap page width and height
    );

  TWPSuperPrintBookletModes = set of (
    wpprBindAtTop // set to true for "top binding", otherwise it defaults to "side binding" (not yet implemented)
    );

  TWPSuperPrintOption = set of
    (wpPrintFrame,
     wpDoNotScalePage,
     wpOutputToWPDF  // Should be used with wPDF so embedded JPEG images are printed correctly
     );

  {:: Component to print multiple pages on one (virtual) paper sheet.
  It does not use actual code to do the printing so you need to add some
  code to call the 'Paint' procedure:

  <code>
  procedure TForm1.PrintIt(Sender: TObject);
var n : Integer;
begin
   Printer.Title := 'superprint-' + WPRichText1.LastFileName;
   Printer.BeginDoc;
   n := 0;
   try
     while n<WPRichText1.PageCount do
     begin
       n := WPSuperPrint1.Paint(
         Printer.Canvas, 0,0,
         Printer.Canvas.Font.PixelsPerInch/1440,
         [],
         n, Printer.PageNumber );
       if n<WPRichText1.PageCount then Printer.NewPage;
     end;
   finally
     Printer.EndDoc;
   end;
end;
</code>

This code is used in the label printer example to print a lable:
<code>
  WPSuperPrint1.Paint(
      Printer.Canvas,
      - GetDeviceCaps(Printer.Handle,PHYSICALOFFSETX	),// Offset in pixels
      - GetDeviceCaps(Printer.Handle,PHYSICALOFFSETy	),// Offset in pixels
      GetDeviceCaps(Printer.Handle,LOGPIXELSY	)/1440,   // Multiplicator for Parameters (twips->Canvas)
      [wpDoNotScalePage] );                             // Options
</code>

 }



  TWPSuperPrint = class(TComponent)
  private
    //FWidthTW, FHeightTW: Integer;
    FPrintLandscape  : Boolean;
    // Page definition (twips values)
    FPageWidth: Integer;
    FPageHeight: Integer;
    // Booklet/Label definition
    FMode: TWPSuperPrintMode;
    FLandscape: TWPSuperPrintLandscape;
    FColumns: Integer;
    FRows: Integer;
    FCopies: Integer;
    FMarginLeft: Integer;
    FMarginRight: Integer;
    FMarginTop: Integer;
    FMarginBottom: Integer;
    FInbetweenHorz: Integer;
    FInbetweenVert: Integer;
    FPrintTopDown: Boolean;
    // For label printing only
    FLabelStartRow    : Integer;
    FLabelStartColumn : Integer;
    // Background Image
    FBackgroundImageModes: TWPSuperPrintImageModes;
    FBackgroundImage: TPicture;
    FBackgroundImageName: string;
    FBGMarginLeft: Integer;
    FBGMarginRight: Integer;
    FBGMarginTop: Integer;
    FBGMarginBottom: Integer;
    // Source, Dest
    FEditBox: TWPCustomRtfEdit;
    FPreview: TPaintBox;
    FLockPreview: Boolean;
    FOnCalcPageNumber: TWPSuperPrintCalcPageNumber;
    FOnUpdate : TNotifyEvent;
    FBookletModes: TWPSuperPrintBookletModes; {rd} 
    iSavPageHeight : integer;
    iSavPageWidth  : integer;
    bSavLandscape  : boolean;
    mMode : TWPSuperPrintMode;
    mLand : TWPSuperPrintLandscape;
    bSaved : boolean;
    // --------------------------------
    procedure SetPageWidth(x: Integer);
    procedure SetPageHeight(x: Integer);
    procedure SetColumns(x: Integer);
    procedure SetRows(x: Integer);
    procedure SetCopies(x: Integer);
    procedure SetMarginLeft(x: Integer);
    procedure SetMarginRight(x: Integer);
    procedure SetMarginTop(x: Integer);
    procedure SetMarginBottom(x: Integer);
    procedure SetInbetweenHorz(x: Integer);
    procedure SetInbetweenVert(x: Integer);
    procedure SetBackgroundImageModes(x: TWPSuperPrintImageModes);
    procedure SetBackgroundImage(x: TPicture);
    procedure SetBGMarginLeft(x: Integer);
    procedure SetBGMarginRight(x: Integer);
    procedure SetBGMarginTop(x: Integer);
    procedure SetBGMarginBottom(x: Integer);
    procedure SetEditBox(x: TWPCustomRtfEdit);
    procedure SetPreview(x: TPaintBox);
    function  GetWidthTW : Integer;
    function  GetHeightTW : Integer;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure GetWH(var w, h: Integer);
    procedure PrintTiledBackground(toCanvas: TCanvas;
      PageRect: TRect; Mult: Double; bit: TGraphic; imagemode: TWPDrawImageMode);
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Update;
    procedure PaintPreview;
    procedure SetTwoUpBooklet(Enabled : Boolean; PageWidth, PageHeight : Integer);
    function Paint(Canvas: TCanvas; prxoff, pryoff: Integer; prmult: Extended;
        Options : TWPSuperPrintOption; startrectnr: Integer = 0; sheetnr: Integer = 0): Integer;
    //:: This is the text width of a single rectangle in twips. Ready to be used with TWPRichTrext.Header.PageWidth
    property Width: Integer read GetWidthTW;
    //:: This is the text width of a single rectangle in twips. Ready to be used with TWPRichTrext.Header.PageHeight
    property Height: Integer read GetHeightTW;
    //:: If this property is true the printer shoulöd be switched to landscape
    property PrintLandscape : Boolean read FPrintLandscape;
    property LockPreview: Boolean read FLockPreview write FLockPreview;
  published
    // Page definition (twips values)
    property PageWidth: Integer read FPageWidth write SetPageWidth default 0;
    property PageHeight: Integer read FPageHeight write SetPageHeight default 0;
    // Booklet/Label definition
    property Mode: TWPSuperPrintMode read FMode write FMode;
    property Landscape: TWPSuperPrintLandscape read FLandscape write FLandscape;
    property Columns: Integer read FColumns write SetColumns default 1;
    property Rows: Integer read FRows write SetRows default 1;
    property Copies: Integer read FCopies write SetCopies default 1;
    property MarginLeft: Integer read FMarginLeft write SetMarginLeft default 0;
    property MarginRight: Integer read FMarginRight write SetMarginRight default 0;
    property MarginTop: Integer read FMarginTop write SetMarginTop default 0;
    property MarginBottom: Integer read FMarginBottom write SetMarginBottom default 0;
    property InbetweenHorz: Integer read FInbetweenHorz write SetInbetweenHorz default 0;
    property InbetweenVert: Integer read FInbetweenVert write SetInbetweenVert default 0;
    //:: use top-down order instead of left-right order
    property PrintTopDown: Boolean read FPrintTopDown write FPrintTopDown default FALSE;
    // Background Image
    property BackgroundImageModes: TWPSuperPrintImageModes read FBackgroundImageModes write SetBackgroundImageModes;
    property BackgroundImage: TPicture read FBackgroundImage write SetBackgroundImage;
    property BackgroundImageName: string read FBackgroundImageName write FBackgroundImageName;
    property BGMarginLeft: Integer read FBGMarginLeft write SetBGMarginLeft default 0;
    property BGMarginRight: Integer read FBGMarginRight write SetBGMarginRight default 0;
    property BGMarginTop: Integer read FBGMarginTop write SetBGMarginTop default 0;
    property BGMarginBottom: Integer read FBGMarginBottom write SetBGMarginBottom default 0;
    // For label printing
    property LabelStartRow    : Integer read FLabelStartRow write FLabelStartRow;
    property LabelStartColumn : Integer read FLabelStartColumn write FLabelStartColumn;
    // Booklet mode
    property BookletMode: TWPSuperPrintBookletModes read FBookletModes write FBookletModes default [];
    // Source, Dest
    property EditBox: TWPCustomRtfEdit read FEditBox write SetEditBox;
    property Preview: TPaintBox read FPreview write SetPreview;

    property OnCalcPageNumber: TWPSuperPrintCalcPageNumber read FOnCalcPageNumber write FOnCalcPageNumber;
    property OnUpdate : TNotifyEvent read FOnUpdate write FOnUpdate;
  end;



implementation

constructor TWPSuperPrint.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FCopies := 1;
  FColumns := 1;
  FRows := 1;
  FBackgroundImage := TPicture.Create;
end;

destructor TWPSuperPrint.Destroy;
begin
  FBackgroundImage.Free;
  inherited Destroy;
end;

procedure TWPSuperPrint.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent = FEditBox) then FEditBox := nil;
    if (AComponent = FPreview) then FPreview := nil;
  end;
end;

procedure TWPSuperPrint.GetWH(var w, h: Integer);
var r: Integer;
begin
  w := FPageWidth;
  h := FPageHeight;

  if FEditBox <> nil then
  begin
    if FPageWidth = 0 then w := FEditBox.Header.PageWidth;
    if FPageHeight = 0 then h := FEditBox.Header.PageHeight;
    if Mode in [wpprPageColRows, wpprBooklet] then
    begin
      w := w * Columns;
      h := h * Rows;
    end;
  end;

  if (Landscape = wpprLandscapeOn) or
    ((Landscape = wpprLandscapeAuto) and ((Columns and 1) = 0)) then
  begin
    r := w;
    w := h;
    h := r;
  end;
end;

procedure TWPSuperPrint.Update;
var w, h : Integer;
begin
  GetWH(w, h);
  if not FLockPreview and (FPreview <> nil) then FPreview.Invalidate;
  FPrintLandscape := w>h;
  if assigned(FOnUpdate) then FOnUpdate(Self);
end;

function  TWPSuperPrint.GetWidthTW : Integer;
var w, h: Integer;
begin
  GetWH(w, h);
  Result := (w - FMarginLeft - FMarginRight - (FColumns - 1) * FInbetweenHorz) div FColumns;
end;

function  TWPSuperPrint.GetHeightTW : Integer;
var w, h: Integer;
begin
  GetWH(w, h);
  Result := (h - FMarginTop - FMarginBottom - (FRows - 1) * FInbetweenVert) div FRows;
end;

procedure TWPSuperPrint.PaintPreview;
var w, h, prxoff, pryoff: Integer;
  d, prmult: Extended;
begin
  if (FPreview <> nil) and not FLockPreview then
  begin
    GetWH(w, h);
    d := FPreview.Width / w;
    prmult := FPreview.Height / h;
    if d < prmult then prmult := d;
    prxoff := (FPreview.Width - Round(w * prmult)) div 2;
    pryoff := (FPreview.Height - Round(h * prmult)) div 2;

    Paint(FPreview.Canvas, prxoff, pryoff, prmult, [wpPrintFrame]);
  end;
end;

procedure TWPSuperPrint.PrintTiledBackground(toCanvas: TCanvas;
  PageRect: TRect; Mult: Double; bit: TGraphic; imagemode: TWPDrawImageMode);
var x, y: Integer;
  saveddc: Cardinal;
begin
  x := PageRect.Left;
  saveddc := SaveDC(toCanvas.Handle);
  try
    IntersectClipRect(toCanvas.Handle, PageRect.Left, PageRect.Top,
      PageRect.Right, PageRect.Bottom);
    if Abs(Mult - 1) < 0.01 then
      while x < PageRect.Right do
      begin
        y := PageRect.Top;
        while y < PageRect.Bottom do
        begin
          toCanvas.Draw(x, y, bit);
          inc(y, bit.Height);
        end;
        inc(x, bit.Width);
      end else
      while x < PageRect.Right do
      begin
        y := PageRect.Top;
        while y < PageRect.Bottom do
        begin
          // toCanvas.StretchDraw(Rect(x, y, Round(x + bit.Width * mult), Round(y + bit.Height * mult)), bit);
          WPDrawImage(toCanvas, bit, x, y, Round(bit.Width * mult), Round(bit.Height * mult), imagemode);

          inc(y, Round(bit.Height * mult));
        end;
        inc(x, Round(bit.Width * mult));
      end;
  finally
    RestoreDC(toCanvas.Handle, saveddc);
  end;
end;

function TWPSuperPrint.Paint(Canvas: TCanvas; prxoff, pryoff: Integer;
  prmult: Extended; Options : TWPSuperPrintOption;
  startrectnr: Integer = 0; sheetnr: Integer = 0): Integer;
var page, pxx, pyy, px, py, ppw, pph, w, h, pw, ph, r, c, copy: Integer;
  back: TGraphic;
  mmh, mmw, srcmlt: Extended;
  picw, pich, picx, picy: Integer;
  rotated: Boolean;
  imagemode: TWPDrawImageMode;
  procedure PrintRect;
  var paintmode: TWPRTFEnginePaintPagesModes;
      modes : TWPPaintModes;
  begin
    pw := (w - FMarginLeft - FMarginRight - (FColumns - 1) * FInbetweenHorz) div FColumns;
    ph := (h - FMarginTop - FMarginBottom - (FRows - 1) * FInbetweenVert) div FRows;
    modes := [wppNoPageBackground, wppWhiteIsTransparent];
    if wpOutputToWPDF in Options then include(modes,wppInPaintForwPDF);

    // {rd} moved this from below the px and py calculations so I could check sheetnr in the if() test below
    rotated := FALSE;
    if assigned(FOnCalcPageNumber) then
      FOnCalcPageNumber(Self, startrectnr, sheetnr, page, rotated);

    //------------------ {rd} ----------------------------
    // if doing booklet printing, only need to swap page ordering on the sheet for even
    // numbered (i.e., the "backs" of) sheets
    if (FMode <> wpprBooklet) or  Odd(sheetnr)  then
      px := FMarginLeft + (c - 1) * (FInbetweenHorz + pw)
    else
      px := FMarginLeft + Abs(c - 2) * (FInbetweenHorz + pw);
    //------------------- {rd} end -----------------------
    py := FMarginTop + (r - 1) * (FInbetweenVert + ph);

    pxx := prxoff + Round(px * prmult);
    pyy := pryoff + Round(py * prmult);
    // -------------------------------------------------------------------------
    if (back <> nil) and (wpImagMultiPage in BackgroundImageModes) then
    begin
      imagemode := [];
      if rotated then include(imagemode, wpDrawIRotate180);
      WPDrawImage(Canvas, back, pxx + Round(picx * prmult),
        pyy + Round(picy * prmult),
        Round((picw * mmw) * prmult),
        Round((pich * mmh) * prmult),
        imagemode);
    end;
    // -------------------------------------------------------------------------
    if wpPrintFrame in Options then
    begin
      Canvas.Brush.Color := clNone;
      Canvas.Brush.Style := bsClear;
      Canvas.Pen.Color := clBlack;
      Canvas.Pen.Style := psDot;
      Canvas.Rectangle(
        pxx,
        pyy,
        pxx + Round(pw * prmult),
        pyy + Round(ph * prmult)
        );
    end;
    // -------------------------------------------------------------------------
    if FEditBox <> nil then
    begin
      if wpDoNotScalePage in Options then
         paintmode := []
      else
      begin
      paintmode := [wpUseProvidedWidthHeight];

      if Rotated then
        paintmode := paintmode + [wpUseWorldScaling, wpUpsideDownPrinting];
      end;

      FEditBox.PaintPageOnCanvas(page,
        pxx,
        pyy,
        Round(pw * prmult),
        Round(ph * prmult),
        Canvas,
        Modes,
        0, //  Round(Screen.PixelsPerInch * prmult),
        0, // Round(Screen.PixelsPerInch * prmult),
        -1, -1,
        paintmode
        );
    end;
    // -------------------------------------------------------------------------
    if FMode <> wpprLabels then inc(page)
    else
    begin
      dec(Copy);
      if Copy <= 0 then
      begin
        Copy := Copies;
        inc(page);
      end;
    end;
    inc(startrectnr);
  end; // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

begin
  page := 0;
  GetWH(w, h);

  pw := (w - FMarginLeft - FMarginRight - (FColumns - 1) * FInbetweenHorz) div FColumns;
  ph := (h - FMarginTop - FMarginBottom - (FRows - 1) * FInbetweenVert) div FRows;

  back := FBackgroundImage.Graphic;

  rotated := FALSE;

  { Without this check, the effect is to have only half
    the pages printed,  since sheetnr is calculated twice each page. }
  if ((FColumns>1) or (FRows>1)) and assigned(FOnCalcPageNumber) then
           FOnCalcPageNumber(Self, startrectnr, sheetnr, page, rotated);

  imagemode := [];
  if rotated then include(imagemode, wpDrawIRotate180);
  if (back <> nil) and (wpImgTile in BackgroundImageModes) then
  begin
    PrintTiledBackground(Canvas,
      Rect(prxoff + Round(FBGMarginLeft * prmult),
      pryoff + Round(FBGMarginTop * prmult),
      prxoff + Round((w - FBGMarginRight) * prmult),
      pryoff + Round((h - FBGMarginBottom) * prmult)), prmult * 1440 / Screen.PixelsPerInch, back,
      imagemode);

  end else
    if back <> nil then
    begin
      picw := back.Width;
      pich := back.Height;
      srcmlt := 1440 / Screen.PixelsPerInch;
      if wpImagMultiPage in BackgroundImageModes then
      begin
        ppw := pw;
        pph := ph;
      end else
      begin
        ppw := w;
        pph := h;
      end;

      mmw := (ppw - FBGMarginLeft - FBGMarginRight) / picw;
      mmh := (pph - FBGMarginTop - FBGMarginBottom) / pich;

         // Stretch aspect ratio
      if (wpImgStretchAspectRatio in BackgroundImageModes) then
      begin
        if mmw > mmh then mmw := mmh
        else mmh := mmw;
      end else
         // no stretch (always reduce size!)
        if not (wpImgStretch in BackgroundImageModes) and
          (mmw > srcmlt) and (mmh > srcmlt) then
        begin
          mmw := srcmlt;
          mmh := srcmlt;
        end;

      if wpImgRight in BackgroundImageModes then
        picx := (ppw - FBGMarginRight - Round(picw * mmw))
      else if wpImgHCenter in BackgroundImageModes then
        picx := (ppw - FBGMarginRight - FBGMarginLeft - Round(picw * mmw)) div 2 + FBGMarginLeft
      else picx := FBGMarginLeft;
      if wpImgBottom in BackgroundImageModes then
        picy := (pph - FBGMarginBottom - Round(pich * mmh))
      else if wpImgVCenter in BackgroundImageModes then
        picy := (pph - FBGMarginBottom - FBGMarginTop - Round(pich * mmh)) div 2 + FBGMarginTop
      else picy := FBGMarginTop;

      if not (wpImagMultiPage in BackgroundImageModes) then
      begin
        WPDrawImage(Canvas, back, prxoff + Round(picx * prmult),
          pryoff + Round(picy * prmult), Round((picw * mmw) * prmult), Round((pich * mmh) * prmult), imagemode);
      end;
    end;

  copy := Copies;

  if Mode=wpprLabels then
  begin
    c := LabelStartColumn;
    if c>FColumns then c := FColumns;
    if c<=0 then c := 1;
    r := LabelStartRow;
    if r>FRows then r := FRows;
    if r<=0 then r := 1
    else
  end else
  begin
    c := 1;
    r := 1;
  end;

  if PrintTopDown then
  begin
    c := 1;
    while c<=FColumns do
    begin
      while r<=FRows do
      begin
         PrintRect;
         inc(r);
      end;
      r :=1;
      inc(c);
    end;
  end else
  begin
    while r<=FRows do
    begin
      while c<=FColumns do
      begin
         PrintRect;
         inc(c);
      end;
      c := 1;
      inc(r);
    end;
  end;

  Result := startrectnr;

  if wpPrintFrame in Options then
  begin
    Canvas.Brush.Color := clNone;
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 0;
    Canvas.Rectangle(
      prxoff,
      pryoff,
      prxoff + Round(w * prmult),
      pryoff + Round(h * prmult)
      );
  end;
end;


procedure TWPSuperPrint.SetPageWidth(x: Integer);
begin
  if x <> FPageWidth then
  begin
    FPageWidth := x;
    Update;
  end;
end;

procedure TWPSuperPrint.SetPageHeight(x: Integer);
begin
  if x <> FPageHeight then
  begin
    FPageHeight := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetColumns(x: Integer);
begin
  if x <= 0 then x := 1;
  if x <> FColumns then
  begin
    FColumns := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetRows(x: Integer);
begin
  if x <= 0 then x := 1;
  if x <> FRows then
  begin
    FRows := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetCopies(x: Integer);
begin
  if x <= 0 then x := 1;
  if x <> FCopies then
  begin
    FCopies := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetMarginLeft(x: Integer);
begin
  if x <> FMarginLeft then
  begin
    FMarginLeft := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetMarginRight(x: Integer);
begin
  if x <> FMarginRight then
  begin
    FMarginRight := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetMarginTop(x: Integer);
begin
  if x <> FMarginTop then
  begin
    FMarginTop := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetMarginBottom(x: Integer);
begin
  if x <> FMarginBottom then
  begin
    FMarginBottom := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetInbetweenHorz(x: Integer);
begin
  if x <> FInbetweenHorz then
  begin
    FInbetweenHorz := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetInbetweenVert(x: Integer);
begin
  if x <> FInbetweenVert then
  begin
    FInbetweenVert := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetBackgroundImageModes(x: TWPSuperPrintImageModes);
begin
  if x <> FBackgroundImageModes then
  begin
    FBackgroundImageModes := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetBackgroundImage(x: TPicture);
begin
  FBackgroundImage.Assign(x);
  Update;
end;


procedure TWPSuperPrint.SetBGMarginLeft(x: Integer);
begin
  if x <> FBGMarginLeft then
  begin
    FBGMarginLeft := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetBGMarginRight(x: Integer);
begin
  if x <> FBGMarginRight then
  begin
    FBGMarginRight := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetBGMarginTop(x: Integer);
begin
  if x <> FBGMarginTop then
  begin
    FBGMarginTop := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetBGMarginBottom(x: Integer);
begin
  if x <> FBGMarginBottom then
  begin
    FBGMarginBottom := x;
    Update;
  end;
end;


procedure TWPSuperPrint.SetEditBox(x: TWPCustomRtfEdit);
begin
  if x <> FEditBox then
  begin
    FEditBox := x;
    if FEditBox <> nil then FEditBox.FreeNotification(Self);
    Update;
  end;
end;

procedure TWPSuperPrint.SetPreview(x: TPaintBox);
begin
  if x <> FPreview then
  begin
    FPreview := x;
    if FPreview <> nil then FPreview.FreeNotification(Self);
    Update;
  end;
end;

procedure TWPSuperPrint.SetTwoUpBooklet(Enabled : Boolean; PageWidth, PageHeight : Integer);
var
  pap_w, pap_h: Integer;
begin
  if bSaved then
  begin
        if (FEditBox <> nil) then
        begin
          FEditBox.Header.PageWidth := iSavPageWidth;
          FEditBox.Header.PageHeight := iSavPageHeight;
          FEditBox.Header.Landscape := bSavLandscape;
        end;
        Mode := mMode;
        bSaved := FALSE;
        FLandscape := mLand;
  end;

  if Enabled then
  begin
    if (not (wpprBindAtTop in FBookletModes)) then
    begin
       // Text properties
      if (FEditBox <> nil) then
      begin
        pap_w := PageWidth;
        pap_h := PageHeight;  
        iSavPageHeight := FEditBox.Header.PageHeight;
        iSavPageWidth  := FEditBox.Header.PageWidth;
        bSavLandscape  := FEditBox.Header.Landscape;

        bSaved := TRUE;
        FEditBox.Header.PageWidth := pap_w div 2;
        FEditBox.Header.PageHeight := pap_h;
        FEditBox.Header.Landscape := FALSE;
      end;

       // Printer Props:
      Printer.Orientation := poLandscape;

       // SuperPrint Props
      FRows := 1;
      FColumns := 2;

          // page size
      mMode := Mode;
      mLand := FLandscape;
      FLandscape := wpprLandscapeAuto;
      FMode      := wpprBooklet;
    end; (* if( FBindType = wpprBindAtSide ) *)

    // no margins, already have them in the text
    FMarginLeft := 0;
    FMarginRight := 0;
    FMarginTop := 0;
    FMarginBottom := 0;

    Update;
  end; (* if( FTwoUpBooklet ) *)
end;

end.

