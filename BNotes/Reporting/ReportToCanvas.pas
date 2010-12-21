unit ReportToCanvas;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Report rendering engine for Canvas output, ie printer or preview form

  Written: Dec 1999
  Authors: Matthew

  Purpose: Provides a Report Rendering Object for printing and previewing
           banklink reports.

  Notes:   Creates a bkprintjob object for handling output ( PrintJob - Printed Document )
           Then sets the PrintJob method pointers to internal methods of this object.
           The methods assigned are

              PrintJob.OnBeforePrint := DoBeforePrintStuff;
              PrintJob.OnNewPage     := DoNewPageStuff;
              PrintJob.OnPrintMethod := CallReportOnPrint;
              PrintJob.OnAfterPrint  := DoAfterPrintStuff;

           All Report measurements are in 0.1mm ie   100 = 10mm.  Measurements
           are converted to pixel before drawing onto the canvas.

           See NewReportObj.pas for an explaination of the whole report process

           Access to the underlying TBKPrinter object is publicly available
           thru the OutputBuilder.  This is to allow full control of the
           Canvas when printing directly to it.  Is used for the GST 101 report.
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   //dialogs,
   classes,
   BKPrintJob,
   //QRPrntr,
   RenderEngineObj,
   ECReportObj,
   repcols,
   graphics,
   windows;

type
   TRenderToCanvasEng = class( TCustomRenderEngine)
   private
      PrintJob           : TBKPrintJob;
      DefaultFont        : TFont;
      DefaultRenderStyle : TRenderStyle;

      FDetailTop         : longint;
      FDetailMax         : longint;
      CurrY              : longint;
      LineSize           : longint;

      CurrSymbol         : string;

      //These routines are passed to the report printer object
      procedure DoNewPageStuff( Sender : TObject);
      procedure DoBeforePrintStuff( Sender : TObject);
      procedure CallReportOnPrint( Sender : TObject);
      procedure PrintFontTooBigPage( Sender: TObject);
      procedure DoAfterPrintStuff( Sender : TObject);

      function  GetReportOwner : TBKReport;
      function  GetDetailMMRect: TRect;
      function  GetDetailPixelRect: TRect;
   protected
//protected
      //RenderText and RenderLine are the only two routines that actually draw onto the canvas
      procedure RenderText(textValue : string; textRect : TRect; Justify : TJustifyType; RenderStyle :TRenderStyle);
      procedure RenderLine(x,y,width : integer);

      procedure NewDetailLine;
      procedure NewLine;

      //These routines call RenderText and RenderLine to do that drawing
      procedure RenderPageHeaderFooter(HF : THeaderFooterCollection);
      function  ReplaceSpecial(textValue : string) : string;
      function  RenderFontHeight(newFont : TFont): integer;
      procedure RenderTotalLine(double: boolean);
      procedure RenderDetail(DataString : TStringList);
      //This property allows us to access the report that owns this Render Engine
      property  Report : TBKReport read GetReportOwner;
   public
//public
      constructor Create( aOwner : TObject); override;
      destructor  Destroy; override;

      procedure RequireLines(lines :integer);             override;
      procedure RenderDetailHeader;                       override;
      procedure RenderDetailLine;                         override;
      procedure RenderDetailSectionTotal;                 override;
      procedure RenderDetailSubTotal;                     override;
      procedure WriteCurrSymbol(LocalCurrSymbol: string); override;
      procedure RenderDetailGrandTotal;                   override;
      procedure RenderTitleLine(Text : string);           override;
      procedure RenderTextLine(Text:string);              override;
      procedure RenderRuledLine;                          override;
      procedure SingleUnderLine;                          override;
      procedure DoubleUnderLine;                          override;
      procedure ReportNewPage;                            override;

      procedure Preview;
      procedure Print;

      //Provides access to the underlying TBKPrinter object so that all of its
      //public methods are available when printing directly to the canvas
      property  OutputBuilder : TBKPrintJob read PrintJob;
      property  DetailMMRect : TRect read GetDetailMMRect;
      property  DetailPixelRect : TRect read GetDetailPixelRect;
   end;

//******************************************************************************
implementation
uses
   Forms,
   SysUtils;

const
     POINT_TO_01MM = 3.514;
     LINE_SIZE_INFLATION = 1.2;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function makeRect( x, y, width, height : longint) : TRect;
{turns parameters into a 0.1mm rect}
begin
  if width < 0 then
  begin {indicated right justified box}
    result.TopLeft := Point(x+width, y);
    result.BottomRight := Point(x,y+height);
  end
  else
  begin {indicates left justified box}
    result.TopLeft := Point(x, y);
    result.BottomRight := Point(x+width,y+height);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TRenderToCanvasEng }
constructor TRenderToCanvasEng.Create(aOwner: TObject);
begin
   inherited Create(aOwner);
   DefaultFont        := TFont.Create;
   DefaultRenderStyle := TRenderStyle.Create;
   PrintJob           := TBKPrintJob.Create;
   //Setup method pointers, OnNewPage and OnPrint will be setup later by BeforePrint
   PrintJob.OnBeforePrint := DoBeforePrintStuff;
   PrintJob.OnAfterPrint  := DoAfterPrintStuff;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TRenderToCanvasEng.Destroy;
begin
   try
      if PrintJob.ReportSettingsChanged then begin
         //Update report settings with values from PrintJob object
//         PrintJob.SaveSettingsTo( Report.ReportSettings);
         //Set save flag
//         Report.ReportSettings.s7Save_Required := true;
      end;
   finally
      PrintJob.Free;
      DefaultRenderStyle.Free;
      DefaultFont.Free;
      inherited Destroy;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.DoubleUnderLine;
begin
   RenderTotalLine(true);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.GetReportOwner: TBKReport;
//allows use to refer to a Report object, rather than having to type case the
//owner object every time.
begin
   result := TBKReport(Owner);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.NewLine;
begin
   //Move current y location down one line size
   CurrY := CurrY + LineSize;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.NewDetailLine;
begin
   //Move current y location down one line, check if new page needed
   //Clear current detail strings
   CurrY := CurrY + LineSize;
   if (CurrY + LineSize)> FDetailMax then
      ReportNewPage;
   Report.CurrDetail.Clear;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.Preview;
begin
   PrintJob.LoadSettingsFrom( Report.ReportSettings );
   PrintJob.Preview;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.Print;
begin
   PrintJob.LoadSettingsFrom( Report.ReportSettings );
   PrintJob.Print;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetail(DataString: TStringList);
var
  i :integer;
  aCol : TReportColumn;
  text : String;
begin
   with Report do
     for i := 0 to Pred(Columns.ItemCount) do begin
        aCol := Columns.Report_Column_At(i);
        if i <= (DataString.Count -1) then
           text := Datastring[i]
        else
           text := MISSINGFIELD;

        RenderText(text,makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,aCol.Style);
     end;        { for }
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RequireLines(lines :integer);
//check if enough space left on the page for x more lines
begin
   if (CurrY + LineSize * lines)> FDetailMax then
      ReportNewPage;
   Report.CurrDetail.Clear;
end;        {  }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailGrandTotal;
{requires 3 lines, draws one line above, 2 below}
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  Value,Quantity,Average : currency;
begin
    RequireLines(3);
    RenderTotalLine(false);
    with Report, PrintJob do begin
       for i := 0 to Pred(Columns.ItemCount) do        { Iterate }
           begin
              aCol := Columns.Report_Column_At(i);
              if aCol.isTotalCol then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                          else FormatS := aCol.TotalFormat;

                 RenderText(FormatFloat(FormatS,aCol.GrandTotal),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
              end;

              {averaging cols}
              if aCol.IsAverageCol then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                          else FormatS := aCol.TotalFormat;

                 Value    := aCol.ColValue.GrandTotal;
                 Quantity := aCol.ColQuantity.GrandTotal;

                 if Quantity <> 0.0 then
                    Average := Value / Quantity
                 else
                    Average := 0;

                 RenderText(FormatFloat(FormatS,Average),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
              end;
           end;
             { for }
       NewDetailLine;
       RenderTotalLine(true);

       {reset totals}
       for i := 0 to Pred(Columns.ItemCount) do with Columns.Report_Column_At(i) do
          GrandTotal := 0;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailHeader;
//Render the column headers for the detail section of the report
var
  i : integer;
  aCol : TReportColumn;
  DoubleLine : boolean;
begin
  with Report, PrintJob do
  begin
    doubleLine := Columns.TwoLines;
    Canvas.Font.Assign(DefaultFont);
    if not Doubleline then {dont underline if there are two lines}
       Canvas.Font.Style  := ([fsUnderLine]);

    {firstline}
    for i := 0 to Pred(Columns.ItemCount)   do        { Iterate }
        begin
           aCol := Columns.Report_Column_At(i);
           RenderText(aCol.Caption,makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
        end;        { for }
    NewDetailLine;

    if DoubleLine then
    begin
      Canvas.Font.Style  := ([fsUnderLine]);

      {second line}
      for i := 0 to Pred(Columns.ItemCount)   do        { Iterate }
         begin
            aCol := Columns.Report_Column_At(i);
            RenderText(aCol.CaptionLine2,makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
         end;        { for }
       NewDetailLine;
    end;
    NewDetailLine;  //add a blank line before the detail lines

    Canvas.Font.Assign(DefaultFont);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailLine;
begin
   RenderDetail(Report.CurrDetail);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailSectionTotal;
{requires 3 lines, draws one line above}
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  Value, Quantity, Average : currency;
begin
    RequireLines(3);
    RenderTotalLine(false);
    with Report, PrintJob do begin
       for i := 0 to Pred(Columns.ItemCount)  do        { Iterate }
           begin
              aCol := Columns.Report_Column_At(i);
              if aCol.isTotalCol then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                          else FormatS := aCol.TotalFormat;
                 RenderText(FormatFloat(FormatS,aCol.SectionTotal),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
              end;

              {averaging cols}
              if aCol.IsAverageCol then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                    else FormatS := aCol.TotalFormat;

                 Value    := aCol.ColValue.SectionTotal;
                 Quantity := aCol.ColQuantity.SectionTotal;

                 if Quantity <> 0.0 then
                    Average := Value / Quantity
                 else
                    Average := 0;

                 RenderText(FormatFloat(FormatS,Average),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
              end;
           end;
                { for }
       NewDetailLine;
       NewDetailLine;

       {reset SectionTotals}
      for i := 0 to Pred(Columns.ItemCount) do with Columns.Report_Column_At(i) do
         SectionTotal := 0;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailSubTotal;
{requires 3 lines, draws one line above}
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  Value, Quantity, Average : currency;
begin
    RequireLines(3);
    RenderTotalLine(false);
    with Report, PrintJob do begin
       for i := 0 to Pred(Columns.ItemCount)  do        { Iterate }
           begin
              aCol := Columns.Report_Column_At(i);
              if aCol.isTotalCol then
              begin
                if CurrSymbol = '' then
                begin
                  if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                           else FormatS := aCol.TotalFormat;
                end else
                  FormatS := CurrSymbol + aCol.FormatString;
                RenderText(FormatFloat(FormatS,aCol.subTotal),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
              end;

              {averaging cols}
              if aCol.IsAverageCol then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                    else FormatS := aCol.TotalFormat;

                 Value    := aCol.ColValue.SubTotal;
                 Quantity := aCol.ColQuantity.SubTotal;

                 if Quantity <> 0.0 then
                    Average := Value / Quantity
                 else
                    Average := 0;

                 RenderText(FormatFloat(FormatS,Average),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
              end;
           end;
                { for }
       NewDetailLine;
       NewDetailLine;

       {reset subtotals}
      for i := 0 to Pred(Columns.ItemCount) do with Columns.Report_Column_At(i) do
         SubTotal := 0;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderRuledLine;
begin
   with PrintJob do
      RenderLine(OutputAreaLeft, CurrY + LineSize div 2,OutputAreaLeft + OutputAreaWidth);
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderTextLine(Text: string);
begin
   with PrintJob do
      RenderText(Text,makeRect(OutputAreaLeft,CurrY,OutputAreaWidth,LineSize),jtLeft,DefaultRenderStyle);
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderTitleLine(Text: string);
begin
   RequireLines(3);
   with PrintJob do begin
     Canvas.Font.Style  := ([fsUnderLine]);

     NewDetailLine;
     RenderText(Text,makeRect(OutputAreaLeft,CurrY,OutputAreaWidth,LineSize),jtLeft,DefaultRenderStyle);
     NewDetailLine;
     NewDetailLine;

     Canvas.Font.Assign(DefaultFont);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderTotalLine(double: boolean);
var
   i : integer;
   aCol : TReportColumn;
begin
   with Report do
    for i := 0 to Pred(Columns.ItemCount)  do        { Iterate }
    begin
       aCol := Columns.Report_Column_At(i);
       if (aCol.isTotalCol) or (aCol.IsAverageCol) then
          if not double then
             RenderLine(aCol.Left, CurrY + LineSize div 2,aCol.Width)                  {1/2}
          else
          begin
             RenderLine(aCol.Left, CurrY + LineSize div 3,aCol.Width);      {1/3}
             RenderLine(aCol.Left, CurrY + LineSize div 3 * 2,aCol.Width);  {2/3}
          end;
    end;
    NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.ReportNewPage;
begin
   //Call process messages so that cancel click can be detected
   Application.ProcessMessages;
   //Set current canvas font back to default for new page
   with PrintJob do begin
        Canvas.Font.Assign(DefaultFont);
   end;
   //tell the printer to start a new page, this will in turn call DoNewPageStuff
   PrintJob.StartNewPage;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.SingleUnderLine;
begin
   RequireLines(2);
   RenderTotalLine(false);
end;

procedure TRenderToCanvasEng.WriteCurrSymbol(LocalCurrSymbol: string);
begin
  CurrSymbol := LocalCurrSymbol;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.DoNewPageStuff(Sender: TObject);
begin
    {Print Page Header}
    CurrY := PrintJob.OutputAreaTop;
    RenderPageHeaderFooter(Report.Header);

    {Print Page Footer}
    CurrY := FDetailMax;
    RenderPageHeaderFooter(Report.Footer);

    {Print Detail Header}
    CurrY := FDetailTop;
    RenderDetailHeader;

    {Set Line size by looking a size of current font on canvas}
    LineSize := round( PrintJob.HeightOfText('A') * LINE_SIZE_INFLATION);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.DoBeforePrintStuff(Sender: TObject);
//Recalculate the column widths and available area given page specifications
var
   i : integer;
   DetailHeight : integer;
   Perc         : Double;
begin
   with PrintJob, Report do begin
      //set the default font from the currently selected report font
      //reason for setting here is that user may have changed the default font
      //in the setup dlg
      with DefaultFont do begin
         Size := PrintJob.UserFontSize;
         Name := PrintJob.UserFontName;
         Style:= PrintJob.UserFontStyle;
      end;
      //Rebuild Headers and Columns
      //alter font details = set font to be same as base font
      //recalculate column left, width etc to accomodate paper and font size
      For i := 0 to Pred(Columns.ItemCount) do
         with Columns.Report_Column_At(i) do begin
         if LeftPercent <> 0.0 then
           Left := OutputAreaLeft + Round(OutputAreaWidth * LeftPercent/100);
         if WidthPercent <> 0.0 then
           Width := Round(OutputAreaWidth * WidthPercent/100);
      end;
      //header
      For i := 0 to Pred(Header.ItemCount) do
         with Header.HFLine_At(i) do begin
           Font.Name := DefaultFont.Name;
           if FontFactor <> 0 then
             Font.Size := Round(DefaultFont.Size * FontFactor);
           if AutoLineSize then
             SetAutoLineSize := Round(Font.Size * POINT_TO_01MM * 1.5);
         end;
      //footer
      For i := 0 to Pred(Footer.ItemCount) do
         with Footer.HFLine_At(i) do begin
            Font.Name := DefaultFont.Name;
            if FontFactor <> 0 then
               Font.Size := Round(DefaultFont.Size * FontFactor);
            if AutoLineSize then
               SetAutoLineSize := Round(Font.Size * POINT_TO_01MM * 1.5);
         end;
      //Setup Dimensions
      FDetailTop := OutputAreaTop + Header.Height;
      FDetailMax := OutputAreaTop + OutputAreaHeight - Footer.Height;
      //Move current Y position on the page to the top of the page
      CurrY      := OutputAreaTop;

      //*** this code is designed to handle the case where the user has selected
      //*** a font size that is too large for the selected paper size

      //check the size of the detail section to determine if font size selected is
      //too big.  Work out percentage of page that can be used for detail
      DetailHeight :=( FDetailMax - FDetailTop);
      if OutputAreaHeight > 0 then
         perc         := DetailHeight / OutputAreaHeight
      else
         perc         := 0;
      //Font is too big if DetailTop > DetailMax or if detail is less than 60% of
      //the page height
      if (DetailHeight < 0) or (perc < 0.6) then begin
         //Current font would not fit.  Redirect the NewPage on OnPrint methods
         PrintJob.OnNewPage     := nil;
         PrintJob.OnPrintMethod := PrintFontTooBigPage;
      end
      else begin
         //Selected Font is OK, Set NewPage and OnPrint methods
         PrintJob.OnNewPage     := DoNewPageStuff;
         //Assign the on print method of the bkprintjob to callreport on printer
         //This means that the bkprint event of the report will be called
         PrintJob.OnPrintMethod := CallReportOnPrint;
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.CallReportOnPrint(Sender: TObject);
begin
   Report.ECPrint;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.RenderFontHeight(newFont: TFont): integer;
var
   tempFont : TFont;
begin
   with PrintJob do begin
      tempFont := Canvas.Font;
      Canvas.Font.Assign(newFont);
      {Set Line size by looking a size of current font on canvas}
      result := round(PrintJob.HeightOfText('A'));
      Canvas.Font.Assign(tempFont);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderPageHeaderFooter( HF: THeaderFooterCollection);
var
   i : integer;
   ALine : THeaderFooterLine;
   LineWidth : integer;
   Left      : integer;
   DisplayText : string;
begin
   for i := 0 to Pred(HF.ItemCount) do        { Iterate }
   with PrintJob do
       begin
          aLine := HF.HFLine_At(i);
          DisplayText := ReplaceSpecial(aLine.Text);
          Canvas.Font := aLine.Font;

          LineWidth := OutputAreaWidth;

          {work out alignment ... if centered then use width of page }
          left := 0;

          if (aLine.Alignment = jtLeft) or (aLine.Alignment = jtCenter) then
               left := OutputAreaLeft;

          if aLine.Alignment = jtRight then
          begin
             Left := OutputAreaLeft + OutputAreaWidth;
             LineWidth := -LineWidth;
          end;

          LineSize := aLine.LineSize;
          RenderText(DisplayText,makeRect(left,CurrY,lineWidth,aLine.LineSize),aLine.Alignment,aLine.Style);

          if aLine.DoNewLine then
             NewLine;
       end;        { for }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.ReplaceSpecial(textValue: string): string;
var
   markerPos : integer;
   textBefore,textAfter : string;
begin
   markerPos := Pos(DATEFIELD,TextValue);
   if markerPos > 0 then
   begin
     {find the date field and replace it with current date}
     textBefore := Copy(textValue,1,markerPos-1);
     textAfter  := Copy(textValue,markerPos+length(DATEFIELD),length(textValue)-markerPos+length(DATEFIELD));

     TextValue := textBefore+DateToStr(now)+textAfter;
     result := textValue;
     exit;
   end;

   {Page Numbers}
   markerPos := Pos(PAGEFIELD,TextValue);
   if markerPos > 0 then
   begin
     {find the date field and replace it with current date}
     textBefore := Copy(textValue,1,markerPos-1);
     textAfter  := Copy(textValue,markerPos+length(PAGEFIELD),length(textValue)-markerPos+length(PAGEFIELD));

     TextValue := textBefore+inttoStr( PrintJob.CurrentPageNo)+textAfter;
     result := textValue;
     exit;
   end;
   result := textValue;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderLine(x, y, width: integer);
begin
   with PrintJob do begin
      Canvas.Polyline([ ConvertToDC( Point(x,y)),ConvertToDC( Point(x+width,y))]);
   end;        { with }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderText(textValue: string; textRect: TRect;
  Justify: TJustifyType; RenderStyle: TRenderStyle);
{Canvas Font should be set before rendering text}
{Canvas color will be changed to render sytle and then reset}
var
   RenderRect : TRect;
   TextWidth, TextHeight : longint;
   wasColor   : TColor;
   wasFColor  : TColor;
begin
   {process the text value looking for special markers}
   if TextValue = SKIPFIELD then exit;

   with PrintJob do
   begin
       TextWidth := Canvas.TextWidth(textValue);
       TextHeight := Canvas.TextHeight(textValue) * 12 div 10;

       {convert from 0.1mm to pixels}
       with TextRect do  begin
          TopLeft := PrintJob.ConvertToDC( TopLeft);
          BottomRight := PrintJob.ConvertToDC( BottomRight);
       end;        { with }

       {first sort out top and bottom}
       if TextHeight >= (textRect.Bottom - textRect.Top) then
       begin    //Height of text is bigger than box so use top
           RenderRect.Top := textRect.Top;
           RenderRect.Bottom := textRect.Bottom;
       end
       else
       begin
           RenderRect.Top := textRect.Top + ((textRect.Bottom - textRect.top) - TextHeight);
           RenderRect.Bottom := textRect.Bottom;
       end;

       {now sortout left right}
       if TextWidth >= (textRect.Right - textRect.Left) then
       begin     //width is greater than box so use left
            RenderRect.Left := textRect.Left;
            RenderRect.Right  := textRect.Right;
       end
       else
       begin
            case Ord(Justify) of
                Ord(jtLeft):         {left}
                begin
                   RenderRect.left := textRect.Left;
                   RenderRect.Right := RenderRect.Left + textwidth;
                end;

                ord(jtCenter):         {center}
                begin
                   RenderRect.Left := textRect.Left + (textRect.Right - textRect.Left) div 2 - textwidth div 2;
                   RenderRect.Right := RenderRect.Left + textwidth;
                end;

                ord(jtRight):          {right}
                begin
                   RenderRect.Right := textRect.Right;
                   RenderRect.Left := RenderRect.Right - textWidth;
                end;
            end;        { case }
       end;             { begin}

       {Store Current Brush Color}
       wasColor := Canvas.Brush.Color;
       wasFColor := Canvas.Font.Color;

       {fill in background}
       if RenderStyle.BackColor <> clNone then
       begin
          Canvas.Brush.Color := RenderStyle.BackColor;
          Canvas.FillRect(textRect);
          Canvas.Brush.Color := wasColor;
       end;

       {now print text}
       if RenderStyle.BackColor <> clNone then
          Canvas.Brush.Color := RenderStyle.BackColor;

       if RenderStyle.FontColor <> clNone then
          Canvas.Font.Color := RenderStyle.FontColor;

       Canvas.TextRect(RenderRect,RenderRect.Left, RenderRect.top, textValue);
       Canvas.Brush.Color := wasColor;
       Canvas.Font.Color  := wasFColor;

       {now draw a frame}
       if RenderStyle.BorderColor <> clNone then
       begin
          wasColor := Canvas.Pen.Color;
          Canvas.Pen.Color := RenderStyle.BorderColor;
          with textRect do Canvas.Polyline([point(left,top),point(right,top),point(right,bottom),point(left,bottom), point(left,top)]);
          Canvas.Pen.Color := wasColor;
       end;
   end;        { with }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.PrintFontTooBigPage(Sender: TObject);
//This output will be generated when the font size selected would produce
//headers and footers that take up more than 40% of the page
begin
   with PrintJob do begin
      CurrY := OutputAreaTop;
      RenderTextLine('Select Font TOO BIG for this Paper Size.');
      RenderTextLine('Please select a different Font Size.');
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.GetDetailMMRect: TRect;
//returns the bounds of the detail section of the current report. units are 0.1mm
begin
   with PrintJob do begin
      result := Rect( OutputAreaLeft, FDetailTop, OutputAreaWidth + OutputAreaLeft, FDetailMax);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.GetDetailPixelRect: TRect;
//returns to bounds of the detail section of the curent report. units are pixels
var
   MMRect : TRect;
begin
   MMRect := GetDetailMMRect;
   with PrintJob do begin
      result.TopLeft := ConvertToDc( MMRect.TopLeft);
      result.BottomRight := ConvertToDC( MMRect.BottomRight);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.DoAfterPrintStuff(Sender: TObject);
begin
   //
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.


