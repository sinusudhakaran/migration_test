unit BKPrintJob;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:  BankLink Printer Job Object

  Written: Dec 1999
  Authors: Matthew

  Purpose: Allows a printer to be selected for printing, previewing and setup.
           Provides a canvas object for printing on.

  Notes:   There are two procedure pointers than can be used to set which routine
           is called when output needs to be generated.

           For procedural pointers set  OnBKPrint (default)
           For method pointers set      OnPrintMethod

           If the method pointer has not been set then the procedural pointer
           will be tested

           Internal Print settings are set by loading values from a Windows_Report_Settings
           record.  A routine is also provided to update a W_R_S rec with new settings

           The two other important methods are

           OnBeforePrint  - called during initialization
           OnNewPage      - called when a new page is generated - allows headers and
                            footers to be rendered
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
   windows, classes, graphics,
   BKPrintController,
   bkQRPrntr,
   ladefs,
   RepCols;

type
  TMethodPointer = procedure ( Sender : TObject) of object;

type
  TBKPrintJob = class(TBKPrintController)
  private
    FRenderPrinter      : TQRPrinter;
    FOnPrintMethod      : TMethodPointer;
    FOnBeforePrint      : TMethodPointer;
    FOnNewPage          : TMethodPointer;
    FOnPageEnd          : TMethodPointer;
    FOnAfterPrint       : TMethodPointer;
    FOnDocumentEnd      : TMethodPointer;

    PrintableWidth,
    PrintableHeight     : integer;         {printers printable area in 0.1mm }
    displayOffset_X     : integer;
    displayOffset_y     : integer;
    //Additional Margins used. Calculated using the default waste area and user margins
    FMargins            : TReportMargins;
    //Printable area including any user defined margins
    UserPrintableWidth  : integer;
    UserPrintableLeft   : integer;
    UserPrintableTop    : integer;
    UserPrintableHeight : integer;

    procedure Init;
    procedure SetOnPrintMethod(const Value: TMethodPointer);
    function  GetQRPrinterCanvas : TCanvas;
    function  GetQRPrinterPageNo : integer;
    procedure CallNewPage;
    procedure CallPageEnd;
    procedure CallBeforePrint;
    function  CalcAdditionalMargin(waste, user: integer): integer;
    function  GetQRDestination: integer;
    procedure CallAfterPrint;
    procedure CallDocumentEnd;
  protected
    procedure BKPrint; override;
    procedure CreateOutput(AQRPrinter : TQRPrinter); override;
  public
    property  OnPrintMethod : TMethodPointer read FOnPrintMethod write SetOnPrintMethod;
    property  OnBeforePrint : TMethodPointer read FOnBeforePrint write FOnBeforePrint;
    property  OnNewPage     : TMethodPointer read FOnNewPage write FOnNewPage;
    property  OnPageEnd     : TMethodPointer read FOnPageEnd write FOnPageEnd;
    property  OnDocumentEnd : TMethodPointer read FOnDocumentEnd write FOnDocumentEnd;
    property  OnAfterPrint  : TMethodPointer read FOnAfterPrint write FOnAfterPrint;

    property  Canvas        : TCanvas read GetQRPrinterCanvas;
    property  CurrentPageNo : integer read GetQRPrinterPageNo;
    property  CurrentDestination : integer read GetQRDestination;

    //Printable area including any user defined margins
    property  OutputAreaWidth     : integer read UserPrintableWidth;
    property  OutputAreaLeft      : integer read UserPrintableLeft;
    property  OutputAreaHeight    : integer read UserPrintableHeight;
    property  OutputAreaTop       : integer read UserPrintableTop;

    procedure StartNewPage;
    function  ConvertToDC( Pt : TPoint) : TPoint;
    function  ConvertToMM( Pt : TPoint) : TPoint;
    function  HeightOfText( Test : string ) : double;
    procedure LoadSettingsFrom( rptSettings : pWindows_Report_Setting_Rec);
    procedure SaveSettingsTo( const rptSettings : pWindows_Report_Setting_Rec);
    //Setup Report
    procedure SetupReport(DisablePrinterChange: Boolean);

    function GetXFactor : extended;
    function GetYFactor : extended;
  end;

//******************************************************************************
implementation
uses
   UserReportSettings,
   printers,
   BKConst;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TBKPrintJob }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.BKPrint;
begin
   if Assigned( FOnPrintMethod) then
      FOnPrintMethod(Self)
   else
      inherited Bkprint;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.CallAfterPrint;
begin
   if Assigned( FOnAfterPrint) then
      FOnAfterPrint(Self);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.CallDocumentEnd;
begin
  if Assigned( FOnDocumentEnd) then
      FOnDocumentEnd(Self);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.CallBeforePrint;
begin
   if Assigned( FOnBeforePrint) then
      FOnBeforePrint(Self);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.CallNewPage;
begin
   if Assigned( FOnNewPage) then
      FOnNewPage( Self);
end;
procedure TBKPrintJob.CallPageEnd;
begin
   if Assigned(FOnPageEnd) then
      FOnPageEnd(Self);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.ConvertToDC(Pt: TPoint): TPoint;
//Convert from 0.1mm coordinates to Device Coordinates ( pixels)
begin
   result.x := FRenderPrinter.XSize( pt.x);
   result.y := FRenderPrinter.YSize( pt.y);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.ConvertToMM(Pt: TPoint): TPoint;
//Convert from Device Coordinates ( pixels) to 0.1mm coordinates
begin
   result.x := Round(pt.x / FRenderPrinter.XFactor);
   result.y := Round(pt.y / FRenderPrinter.YFactor);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.CreateOutput(AQRPrinter: TQRPrinter);
begin
   //Assign internal printer object
   FRenderPrinter := AQRPrinter;
   //Initialise all settings
   Init;
   //load settings into printer
   with FRenderPrinter do begin
      FirstPage := PrinterSettings.FirstPage;
      LastPage  := Printersettings.LastPage;
      //Start Document
      try
         BeginDoc;
         StartNewPage;
         //Debug code to print X on page
              //with FRenderPrinter do  canvas.Polyline([point(0,0), point(xsize(PrintableWidth), ysize(PrintableHeight)), point(xsize(PrintableWidth), 0), point(0,ysize(PrintableHeight)), point(0,0), point(xsize(PrintableWidth), 0), point(xsize(PrintableWidth), ysize(PrintableHeight)), point(0,ysize(PrintableHeight))]);
         //call bkprint routine
         BKPrint;
         CallDocumentEnd;
      finally
         EndDoc;
      end;
   end;
   CallAfterPrint;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.GetQRPrinterCanvas: TCanvas;
begin
   result := FRenderPrinter.Canvas
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.GetQRPrinterPageNo: integer;
begin
   result := FRenderPrinter.PageNumber;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.HeightOfText(Test: string): double;
begin
   result := FRenderPrinter.Canvas.TextHeight( Test )/FRenderPrinter.YFactor;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.CalcAdditionalMargin(waste : integer; user : integer) : integer;
const
   MIN_MARGIN = 50;
begin
   if (user < MIN_MARGIN) then User := MIN_MARGIN; {force minimum edge}

   if (user < waste) then
      result := 0  {no additional needed}
   else
      result := user - waste;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.Init;
//called by CreateOutput
begin
    {set report margins,  printer + user}
    GetPrinterMargins(FRenderPrinter);

    PrintableHeight := FRenderPrinter.PaperLengthValue2 - (TopWaste + BottomWaste);
    PrintableWidth  := FRenderPrinter.PaperWidthValue2 - (LeftWaste + rightWaste);

    with FMargins do begin
       { 0.1 mm}
       mLeft   := CalcAdditionalMargin(LeftWaste, UserMargins.mLeft);
       mTop    := CalcAdditionalMargin(TopWaste, UserMargins.mTop);
       mRight  := CalcAdditionalMargin(RightWaste, UserMargins.mRight);
       mBottom := CalcAdditionalMargin(BottomWaste, UserMargins.mbottom);
    end;

    if FRenderPrinter.Destination = qrdMetafile then  {screen requires offset to be added}
    begin                                             {this is added automatically for printer}
       displayOffset_x := leftWaste;
       displayOffset_y := topWaste;
    end
    else
    begin
       displayOffset_x := 0;
       displayOffset_y := 0;
    end;

    UserPrintableLeft   := displayOffset_x + FMargins.mleft;
    UserPrintableWidth  := PrintableWidth - ( FMargins.mLeft + FMargins.mRight);
    UserPrintableTop    := displayOffset_y + FMargins.mTop;
    UserPrintableHeight := PrintableHeight - ( FMargins.mTop + FMargins.mBottom);

    CallBeforePrint;
end;        {  }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.LoadSettingsFrom( rptSettings: pWindows_Report_Setting_Rec);
//Load the settings into the BKPrintJob from the Windows Report Settings provided
begin
   with rptSettings^ do begin
      {Printer Settings}
      ReportTitle := s7Report_Name;

      UserPrinterIndex := FindPrinterIndex(s7Printer_Name);
      bkPrinterIndex   := UserPrinterIndex;

      if s7Orientation = BK_PORTRAIT then PrinterSettings.Orientation := poPortrait else
                                  PrinterSettings.Orientation := poLandscape;

      PrinterSettings.OutputBin := s7Bin;
      {a default paper size of A4 is used, we will try to match with KNOWN printer pages}
      {note: custom is not supported YET}
      PrinterSettings.paperSize2 := s7Paper;
      {job Settings - user margins and fonts}
      case s7Base_Font_Style of
        bkfsBoldItalic: UserFontStyle := [fsBold, fsItalic];
        bkfsItalic: UserFontStyle := [fsItalic];
        bkfsBold: UserFontStyle := [fsBold];
        else UserFontStyle := [];
      end;
      UserFontSize        := s7Base_Font_Size;
      UserFontName        := s7Base_Font_Name;
      UserMargins.mTop    := s7Top_Margin;   {1 unit = 0.1mm}
      UserMargins.mLeft   := s7Left_Margin;
      UserMargins.mBottom := s7Bottom_Margin;
      UserMargins.mRight  := s7Right_Margin;

      //this setting allows the default font to be scaled automatically
      //when columns widths are too small to use the default font.  This is
      //done in the financial reports such as Cash flow
      if s7Temp_Font_Scale_Factor = 0 then
        FontScaleFactor := 1.0
      else
        FontScaleFactor := s7Temp_Font_Scale_Factor;
    end; {with}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.SaveSettingsTo( const rptSettings: pWindows_Report_Setting_Rec);
begin
   with rptSettings^ do begin
      //Store text name for printer
      s7Printer_Name   := FindPrinterDeviceName(UserPrinterIndex);
      //Convert orientation variable
      if PrinterSettings.Orientation = poPortrait then
         s7Orientation := BK_PORTRAIT else
         s7Orientation := BK_LANDSCAPE;
      //Update settings
      s7Paper          := PrinterSettings.PaperSize2;
      s7Bin            := PrinterSettings.OutputBin;
      s7Base_Font_Name := UserFontName;
      s7Base_Font_Size := UserFontSize;
      if (fsItalic in UserFontStyle) and
         (fsBold in UserFontStyle) then
        s7Base_Font_Style := bkfsBoldItalic
      else if fsItalic in UserFontStyle then
        s7Base_Font_Style := bkfsItalic
      else if fsBold in UserFontStyle then
        s7Base_Font_Style := bkfsBold
      else
        s7Base_Font_Style := bkfsRegular;
      s7Top_Margin     := UserMargins.mTop;
      s7Left_Margin    := UserMargins.mleft;
      s7Bottom_Margin  := UserMargins.mBottom;
      s7Right_Margin   := UserMargins.mRight;
      //s7Temp_Font_Scale_Factor this is not updated so no need to save
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.SetOnPrintMethod(const Value: TMethodPointer);
begin
  FOnPrintMethod := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.StartNewPage;
begin
   CallPageEnd;
   with FRenderPrinter do begin
      if (Destination = qrdPrinter) and (FirstPage > 0) and (LastPage >0)then begin
         //Determine Canvas X Y Factors.. works around a bug in QuickReport Printer}
         //only needed if document is going to the printer and only a range of pages}
         //has been selected}
         SetCanvasXYFactors(FRenderPrinter);
      end;
      FRenderPrinter.NewPage;
   end;
   CallNewPage;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintJob.SetupReport(DisablePrinterChange: Boolean);
//Setup the report without previewing first.
//This allows us to edit the report settings without actually running the report
begin
   //Call the report setup routine of ancestor.  Set Hide Job Page to true
   //so that properties page for no of copies etc not displayed.
   ReportSetup( true, DisablePrinterChange);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.GetQRDestination: integer;
//used to determine where current output is going
// 0 = printer, 1 = screen, -1 - undefined
begin
   case FRenderPrinter.Destination of
      qrdPrinter  : result := 0;
      qrdMetafile : result := 1;
   else
      result := -1;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.GetXFactor: extended;
//used for debugging
begin
  result := FRenderPrinter.XFactor;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintJob.GetYFactor: extended;
//used for debugging
begin
  result := FRenderPrinter.YFactor;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.


