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
   ReportTypes,
   dialogs,
   classes,
   BKPrintJob,
   bkQRPrntr,
   RenderEngineObj,
   repcols,
   graphics,
   rtfBands,
   windows,
   UserReportSettings,
   Progress,
   FaxParametersObj,
   NewReportObj,
   Contnrs;


type
   TRenderToCanvasEng = class( TCustomRenderEngine)
   private
      PrintJob           : TBKPrintJob;
      DefaultFont        : TFont;
      DefaultRenderStyle : TRenderStyle;
      SmallerDottedLines : Boolean;

      FPageTop,
      FPageBottom        : Longint;
      FBodyTop           : longint;
      FBodyBottom        : longint;
      CurrY              : longint;
      NewPagePending     : Boolean;
      PageEndPending     : Boolean;
      FShowPreviewForm   : Boolean;
      FVertColLineType   : TVertColLineType;

      procedure RenderFooter(Band: TRTFBand; atPos: Integer);
      //These routines are passed to the report printer object
      procedure DoNewPageStuff( Sender : TObject);
      procedure DoPageEndStuff( Sender : TObject);
      procedure DoDocumentEndStuff( Sender : TObject);
      procedure DoBeforePrintStuff( Sender : TObject);
      procedure CallReportOnPrint( Sender : TObject);
      procedure PrintFontTooBigPage( Sender: TObject);
      procedure DoAfterPrintStuff( Sender : TObject);

      function  GetReportOwner : TBKReport;
      function  GetDetailMMRect: TRect;
      function  GetDetailPixelRect: TRect;
      function RebuildHeaderFooter(HFCollection : THeaderFooterCollection): Integer;
      procedure SetHeightFromImage(HFLine : THeaderFooterLine);

      procedure RenderDetailHeaderWrapped;
   protected
      //RenderText and RenderLine are the only two routines that actually draw onto the canvas
      procedure RenderText(TextValue : string; textRect : TRect; Justify : TJustifyType; RenderStyle :TRenderStyle);
      procedure RenderLine(x,y,width : integer);
      procedure RenderVerticalLine(x,y,width : integer);
      procedure RenderImage(TextValue : string; textRect : TRect; Justify : TJustifyType; RenderStyle :TRenderStyle; DoNewLine : boolean; aPercSize : integer = 100);

      procedure NewDetailLine;
      procedure NewLine;

      //These routines call RenderText and RenderLine to do that drawing
      procedure RenderPageHeaderFooter(HF : THeaderFooterCollection; LastPage: Boolean = False);
      function  ReplaceSpecial(textValue : string) : string;
      //function  RenderFontHeight(newFont : TFont): integer;
      procedure RenderTotalLine(double: boolean; TotalType: TTotalType);
      procedure RenderDetail(DataString : TStringList);

      //This property allows us to access the report that owns this Render Engine
      property  Report : TBKReport read GetReportOwner;
   public
      constructor Create( aOwner : TObject); override;
      destructor  Destroy; override;
      function LineSize: longint;
      procedure RequireLines(lines :integer);     override;
      function  RenderColumnWidth(ColumnID: Integer; Text : String): Integer; override;
      procedure RenderDetailHeader;               override;
      procedure RenderDetailLine;                 override;
      procedure RenderDetailSubSectionTotal(const TotalName : string);      override;
      procedure RenderDetailSectionTotal(const TotalName : string);         override;
      procedure RenderDetailSubTotal(const TotalName : string; NewLine: Boolean = True;
        KeepTotals: Boolean = False; TotalSubName: string = ''; Style: TStyleTypes = siSectionTotal); override;
      procedure RenderDetailGrandTotal(const TotalName : string);           override;
      procedure RenderDetailRunningTotal(const TotalName : string);         override;
      procedure RenderTitleLine(Text : string);   override;
      procedure RenderTextLine(Text:string; Underlined : boolean; AddLineIfUnderlined: boolean = True);      override;
      procedure RenderMemo( Text : string);       override;
      procedure RenderRuledLine;                  overload; override;
      procedure RenderRuledLine(Style : TPenStyle);                  overload; override;
      procedure RenderColumnLine(ColNo: Integer); overload; override;
      procedure RenderVerticalColumnLine(ColNo: Integer); override;
      procedure RenderAllVerticalColumnLines; override;
      procedure RenderRuledLineWithColLines(LeaveLines: integer = 0;
        aPenStyle: TPenStyle = psSolid;
        VertColLineType: TVertColLineType = vcFull); override;
      procedure RenderEmptyLine();                override;
      procedure SingleUnderLine;                  override;
      procedure DoubleUnderLine;                  override;
      procedure ReportNewPage;                    override;
      procedure SetItemStyle(const Value: TStyleTypes); override;
      procedure UseCustomFont( aFontname : string; aFontSize : integer; aFontStyle : TFontStyles; aLineSize : integer); override;
      procedure UseDefaultFont; override;
      function GetTextLength(Text: string): Integer; override;
      function GetPrintableWidth: Integer; override;

      procedure Preview;
      procedure Print;
      function  PrintPDF(Filename : String) : Boolean;
      function  PrintToFax( FaxParam : TFaxParameters) : boolean;

      procedure SplitText(const Text: String; ColumnWidth: Integer; var WrappedText: TWrappedText); override;

      //Provides access to the underlying TBKPrinter object so that all of its
      //public methods are available when printing directly to the canvas
      property  OutputBuilder : TBKPrintJob read PrintJob;
      property  DetailMMRect : TRect read GetDetailMMRect;
      property  DetailPixelRect : TRect read GetDetailPixelRect;
      property ShowPreviewForm : Boolean read FShowPreviewForm write FShowPreviewForm;
   end;

function GetAveCharWidth( TestFont : TFont; Text : string) : integer;

//******************************************************************************
implementation

uses
  Forms,
  GenUtils,
  SysUtils,
  NewReportUtils,
  ReportImagesObj,
  Types,
  ECollect,
  SignUtils,
  Math,
  StrUtils;

const
     POINT_TO_01MM = 3.514;
     LINE_SIZE_INFLATION = 1.3;
     HEADER_LINE_SIZE_INFLATION = 1.5;
     CORRECTION_RATIO = 1.166;



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
   DefaultFont.Name   := 'Arial';
   DefaultFont.Size   := 9;
   DefaultRenderStyle := TRenderStyle.Create;
   PrintJob           := TBKPrintJob.Create;

   //Setup method pointers, OnNewPage and OnPrint will be setup later by BeforePrint
   PrintJob.OnBeforePrint := DoBeforePrintStuff;
   PrintJob.OnAfterPrint  := DoAfterPrintStuff;

   SmallerDottedLines := False;
   FShowPreviewForm := True;
   FVertColLineType := vcUnknown;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TRenderToCanvasEng.Destroy;
begin
   try
      if PrintJob.ReportSettingsChanged then begin
         //Update report settings with values from PrintJob object
         PrintJob.SaveSettingsTo( Report.UserReportSettings);
         //Set save flag
         Report.UserReportSettings.s7Save_Required := true;
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
   RenderTotalLine(true, ttNone);
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
   if (CurrY + LineSize)> FBodybottom then
      NewPagePending := True;
   Report.CurrDetail.Clear;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.Preview;
begin
   PrintJob.LoadSettingsFrom( Report.UserReportSettings );
   if Report.ReportStyle.Name > '' then begin
      PrintJob.HasStyle := True;
      PrintJob.UseStyle := True;
   end;
   if Report.ReportTypeParams.HasUserHeaderFooter then begin
      PrintJob.HasHeaderFooter := True;
      PrintJob.UseHeaderFooter := Report.ReportTypeParams.HF_Enabled;
   end;
   PrintJob.ShowPreviewForm := FShowPreviewForm;
   PrintJob.Preview;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.Print;
begin
   PrintJob.LoadSettingsFrom( Report.UserReportSettings );
   if Report.ReportStyle.Name > '' then begin
      PrintJob.HasStyle := True;
      PrintJob.UseStyle := True;
   end;
   if Report.ReportTypeParams.HasUserHeaderFooter then begin
      PrintJob.HasHeaderFooter := True;
      PrintJob.UseHeaderFooter := Report.ReportTypeParams.HF_Enabled;
   end;
   PrintJob.Print;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetail(DataString: TStringList);
var
  i :integer;
  aCol: TReportColumn;
  text: String;
  lStyle: TRenderStyle;
  TextRect: TRect;
  ImageName : string;
  StringValue : string;
  ColumnsToSkip : integer;
  ColumnsToSkipStr : string;
  ImageScale : integer;
  ImageScaleStr : string;
  ColumnIndex : integer;
  TotalColWidth : integer;
begin
  if NewPagePending then
    ReportNewPage;

  ColumnsToSkip := 0;

  with Report do
    for i := 0 to Pred(Columns.ItemCount) do
    begin
      if ColumnsToSkip > 0 then
      begin
        dec(ColumnsToSkip);
        Continue;
      end;

      aCol := Columns.Report_Column_At(i);
      if i <= (DataString.Count -1) then
        text := Datastring[i]
      else
        text := MISSINGFIELD;

      if (FindValueInData(Text, IMGFIELD, ImageName)) and
         (FindValueInData(Text, IMGSCALEFIELD, ImageScaleStr))  and
         (trystrtoint(ImageScaleStr, ImageScale)) then
      begin
        TextRect := MakeRect(aCol.Left, CurrY, ACol.Width, LineSize);

        RenderImage(ImageName, TextRect, jtCenter, aCol.Style, false, ImageScale);
      end
      else
      begin
        if (FindValueInData(Text, STRFIELD, StringValue)) and
           (FindValueInData(Text, COLSKIPFIELD, ColumnsToSkipStr)) and
           (trystrtoint(ColumnsToSkipStr, ColumnsToSkip)) then
        begin
          TotalColWidth := 0;
          for ColumnIndex := i to Pred(Columns.ItemCount) do
          begin
            if ColumnIndex > i+ColumnsToSkip then
              break;

            TotalColWidth := TotalColWidth + Columns.Report_Column_At(ColumnIndex).Width;
          end;

          Text := StringValue;
          TextRect := MakeRect(aCol.Left, CurrY, TotalColWidth, LineSize);
        end
        else
          TextRect := MakeRect(aCol.Left, CurrY, ACol.Width, LineSize);

        if Assigned(aCol.CustomFont) then
          UseCustomFont(aCol.CustomFont.Name, aCol.CustomFont.Size, aCol.CustomFont.Style);

        lStyle :=  MergeStyles(Report.ReportStyle.Items[Report.ItemStyle],aCol.Style);
        try
          // This code does not make sense..
          // but we do not use colums yet..
          if Report.ReportStyle.DetailBlinds then
            if not Report.BlindOn then
              lstyle.BackColor := clNone;

          RenderText(Text, TextRect, aCol.Alignment, lStyle);
        finally
          lStyle.Free;
        end;

        if Assigned(aCol.CustomFont) then
          Report.ReportStyle.Items[Report.ItemStyle].AssignTo(PrintJob);
      end;
    end;        { for }
  NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RequireLines(lines :integer);
//check if enough space left on the page for x more lines
begin
   if (CurrY + LineSize * lines)> FBodyBottom then
     NewPagePending := True;
   Report.CurrDetail.Clear;
end;        {  }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// RenderColumnWidth
//
// Returns the number of characters that can fit into the specified column.
//
(*
function TRenderToCanvasEng.RenderColumnWidth(ColumnID: Integer; Text : String): Integer;
var
  aCol : TReportColumn;
  AvgCharWidthInPixels : Integer;
  PPM : double;
  MMPerChar : double;
begin

   //number of characters that can fit into the column
   aCol := Report.Columns.Report_Column_At(ColumnID);
   //Estimate # of characters for each header line to use for wrapping
   AvgCharWidthInPixels := GetAveCharWidth(DefaultFont, Text);
   //Get Pixels / mm
   PPM := ( Screen.PixelsPerInch / 254); // * CORRECTION_RATIO;
   MMPerChar := AvgCharWidthInPixels / PPM;
   //Max characters per line, use 95% of line incase printout wrong
   Result := Trunc( ( aCol.Width * 0.95) / MMPerChar);
end;
*)

function TRenderToCanvasEng.RenderColumnWidth(ColumnID: Integer; Text : String): Integer;
var
  aCol : TReportColumn;
begin
   Result := Length(Text);
   aCol := Report.Columns.Report_Column_At(ColumnID);
   while GetTextLength(Text) > aCol.Width do begin
      Dec(Result);
      Text := Copy (Text,1,Result);
   end;
end;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailRunningTotal(const TotalName : string);
{requires 3 lines, draws one line above}
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  Value, Quantity, Average : currency;
  lStyle: TRenderStyle;
begin
    Report.ItemStyle := siSectionTotal;
    RequireLines(3);
    RenderTotalLine(false, ttRunning);
    with Report, PrintJob do begin
       for i := 0 to Pred(Columns.ItemCount)  do        { Iterate }
           begin
              aCol := Columns.Report_Column_At(i);
              lStyle := MergeStyles( Report.ReportStyle.Items[Report.ItemStyle],aCol.Style);
              try
              {averaging cols}
              if (aCol.IsAverageCol) and (aCol.isTotalCol) then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                    else FormatS := aCol.TotalFormat;

                 Value    := aCol.ColValue.RunningTotal;
                 Quantity := aCol.ColQuantity.RunningTotal;

                 if Quantity <> 0.0 then
                    Average := Value / Quantity
                 else
                    Average := 0;

                 RenderText(FormatFloat(FormatS,Average),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,lStyle);
              end
              else if aCol.isTotalCol then { total cols }
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                          else FormatS := aCol.TotalFormat;
                 RenderText(FormatFloat(FormatS,aCol.RunningTotal),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,lStyle);
              end else if aCol.IsPercentageCol then begin
                  RenderText(FormatPercentString(aCol.RunningTotal,aCol),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,lStyle);
              end;

              {total title}
              if (i = 0)
              and (TotalName > ' ')
              and ( not ( aCol.isTotalCol or aCol.isAverageCol)) then begin
                 RenderText( TotalName, makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,lStyle);
              end;
              finally
                 LStyle.Free;
              end;
           end;
                { for }
       NewDetailLine;
       NewDetailLine;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailGrandTotal(const TotalName : string);
{requires 3 lines, draws one line above, 2 below}
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  Value,Quantity,Average : currency;
  LStyle: TRenderStyle;
begin
  Report.ItemStyle := siGrandTotal;
  RequireLines(3);
  RenderTotalLine(false, ttGrand);
  with Report, PrintJob do
  begin
    for i := 0 to Pred(Columns.ItemCount) do        { Iterate }
    begin
      aCol := Columns.Report_Column_At(i);
      {averaging cols}
      lStyle :=  MergeStyles(Report.ReportStyle.Items[Report.ItemStyle],aCol.Style);
      try
        if (aCol.IsAverageCol) and (aCol.isTotalCol) and (aCol.isGrandTotalCol) then
        begin
          if aCol.TotalFormat = '' then
            FormatS := aCol.FormatString
          else
            FormatS := aCol.TotalFormat;

          Value    := aCol.ColValue.GrandTotal;
          Quantity := aCol.ColQuantity.GrandTotal;

          if Quantity <> 0.0 then
            Average := Value / Quantity
          else
            Average := 0;

          Report.PutString(FormatFloat(FormatS,Average), true);
        end
        else if aCol.isTotalCol and aCol.isGrandTotalCol then { total cols }
        begin
          if aCol.TotalFormat = '' then
            FormatS := aCol.FormatString
          else
            FormatS := aCol.TotalFormat;

          Report.PutString(FormatFloat(FormatS,aCol.GrandTotal), true);
        end
        else if Acol.IsPercentageCol then
        begin
          Report.PutString(FormatPercentString(aCol.GrandTotal,aCol), true);
        end
        else if ( i = 0) and {total title}
           (TotalName > ' ') and
           ( not ( aCol.isTotalCol or aCol.isAverageCol)) then
        begin
          Report.PutString( TotalName, true);
        end
        else
          Report.SkipColumn;
      finally
        lStyle.Free;
      end;
    end;
    RenderDetailLine;
         { for }
    RenderTotalLine(true, ttGrand);

    {reset totals}
    ClearGrandTotals;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailHeader;
//Render the column headers for the detail section of the report
var
  i: integer;
  aCol: TReportColumn;
  DoubleLine: boolean;
  lStyle: TRenderStyle;
begin
  Report.ItemStyle := siHeading;
  with Report, PrintJob do
  begin
    if Columns.WrapCaptions then
    begin
      RenderDetailHeaderWrapped;
    end
    else
    begin
     DoubleLine := Columns.TwoLines;

     if Doubleline then {dont underline if there are two lines}
        Canvas.Font.Style  := Canvas.Font.Style - [fsUnderLine];

     {firstline}
     for i := 0 to Pred(Columns.ItemCount) do begin { Iterate }
        aCol := Columns.Report_Column_At(i);
        lStyle := MergeStyles(Report.ReportStyle.Items[Report.ItemStyle], aCol.Style);
        try
           RenderText(aCol.Caption,makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
        finally
           LStyle.Free;
        end;
     end;        { for }
     NewDetailLine;

     if DoubleLine then begin
        Report.ReportStyle.Items[siHeading].AssignTo(PrintJob); //turn any underline back on..

        {second line}
        for i := 0 to Pred(Columns.ItemCount) do begin
           aCol := Columns.Report_Column_At(i);
           lStyle := MergeStyles(Report.ReportStyle.Items[Report.ItemStyle], aCol.Style);
           try
              RenderText(aCol.CaptionLine2,makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,DefaultRenderStyle);
           finally
              LStyle.Free;
           end;
        end;
        NewDetailLine;
     end;

     NewDetailLine;  //add a blank line before the detail lines
    end;
  end;
end;

procedure TRenderToCanvasEng.RenderDetailHeaderWrapped;

  function GetMaxLineCount(const WrappedCaptions: array of TWrappedText): Integer;
  var
    Index: Integer;
  begin
    Result := 0;

    for Index := 0 to Length(WrappedCaptions) - 1 do
    begin
      if Result < Length(WrappedCaptions[Index]) then
      begin
        Result := Length(WrappedCaptions[Index]);
      end;
    end;
  end;

var
  ColumnIndex: Integer;
  Column: TReportColumn;
  LineIndex: Integer;
  MaxLineCount: Integer;
  FinalLine: Boolean;
  Style: TRenderStyle;
  ColumnText: String;
  WrappedCaptions: array of TWrappedText;
  WrappedCaption: TWrappedText;
begin
  with Report, PrintJob do
  begin
    {Wrap the lines}
    SetLength(WrappedCaptions, Columns.ItemCount);

    for ColumnIndex := 0 to Columns.ItemCount - 1 do
    begin
      Column := Columns.Report_Column_At(ColumnIndex);

      SplitText(Column.Caption, Column.Width, WrappedCaptions[ColumnIndex]);
    end;

    Canvas.Font.Style  := Canvas.Font.Style + [fsUnderLine];

    MaxLineCount := GetMaxLineCount(WrappedCaptions);

    {Render the lines in reverse order so that the text renders down from the first line}
    for LineIndex := MaxLineCount -1 downto 0 do
    begin
      FinalLine := LineIndex = 0;
      
      for ColumnIndex := 0 to Columns.ItemCount -1 do
      begin
        Column := Columns.Report_Column_At(ColumnIndex);

        WrappedCaption := WrappedCaptions[ColumnIndex];
        
        Style := MergeStyles(Report.ReportStyle.Items[Report.ItemStyle], Column.Style);

        try
          if LineIndex < Length(WrappedCaption) then
          begin
            ColumnText := WrappedCaption[Length(WrappedCaption) - LineIndex - 1];

            RenderText(ColumnText, makeRect(Column.Left, CurrY, Column.Width, LineSize), Column.Alignment,Style);
          end;
        finally
          Style.Free;
        end;
      end;

      NewDetailLine;
    end;

    NewDetailLine;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailLine;
var
  ReportColumn : TReportColumn;
  ColumnIndex : integer;
  WrapIndex : integer;
  WrapMax : integer;
  WrapDetail : TStringList;
begin
  WrapMax := 1;
  // Get Max amount of Li9ne to Wrap
  for ColumnIndex := 0 to Report.Columns.ItemCount-1 do
  begin
    ReportColumn := Report.Columns.Report_Column_At(ColumnIndex);
    if (assigned(ReportColumn)) and
       (ReportColumn.DoWrapStr) and
       (ReportColumn.WrappedStr.Count > WrapMax) then
      WrapMax := ReportColumn.WrappedStr.Count;
  end;

  // Check if we need to Wrap
  if WrapMax > 1 then
  begin
    WrapDetail := TStringList.Create;
    if Assigned(WrapDetail) then
    begin
      try
        // Loop through each wrapped Line
        WrapIndex := 1;
        while (WrapIndex <= WrapMax) do
        begin
          // Build up the current wrapped line
          WrapDetail.Clear;
          for ColumnIndex := 0 to Report.Columns.ItemCount-1 do
          begin
            ReportColumn := Report.Columns.Report_Column_At(ColumnIndex);
            if (ReportColumn.DoWrapStr) and
               (ReportColumn.WrappedStr.Count >= WrapIndex) then
            begin
              WrapDetail.Add(trim(ReportColumn.WrappedStr.Strings[WrapIndex-1]));
            end
            else
            begin
              if (WrapIndex = 1) and (ColumnIndex < Report.CurrDetail.Count) then
                WrapDetail.Add(Report.CurrDetail.Strings[ColumnIndex])
              else
                WrapDetail.Add('');
            end;
          end;
          // Render the current wrapped line
          RenderDetail(WrapDetail);

          inc(WrapIndex);
        end;
      finally
        if Assigned(WrapDetail) then
          FreeAndNil(WrapDetail);
      end;
    end;
  end
  else
    // Do the normal code
    RenderDetail(Report.CurrDetail);

  // Clear Wrap Fields
  for ColumnIndex := 0 to Report.Columns.ItemCount-1 do
  begin
    ReportColumn := Report.Columns.Report_Column_At(ColumnIndex);
    if Assigned(ReportColumn) then
    begin
      ReportColumn.DoWrapStr := false;
      ReportColumn.WrappedStr.Clear;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailSectionTotal(const TotalName : string);
{requires 3 lines, draws one line above}
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  Value, Quantity, Average : currency;
  lStyle: TRenderStyle;
begin
    Report.ItemStyle := siSectionTotal;
    RequireLines(3);
    RenderTotalLine(false, ttSection);
    with Report, PrintJob do begin
       for i := 0 to Pred(Columns.ItemCount)  do        { Iterate }
           begin
              aCol := Columns.Report_Column_At(i);

              lStyle := MergeStyles(Report.ReportStyle.Items[Report.ItemStyle], aCol.Style);
              try

              {averaging cols}
              if (aCol.IsAverageCol) and (aCol.isTotalCol) then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                    else FormatS := aCol.TotalFormat;

                 Value    := aCol.ColValue.SectionTotal;
                 Quantity := aCol.ColQuantity.SectionTotal;

                 if Quantity <> 0.0 then
                    Average := Value / Quantity
                 else
                    Average := 0;

                 RenderText(FormatFloat(FormatS,Average),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,lStyle);
              end
              else if aCol.isTotalCol then { total cols }
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                          else FormatS := aCol.TotalFormat;
                 RenderText(FormatFloat(FormatS,aCol.SectionTotal),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,lStyle);
              end else if Acol.IsPercentageCol then begin
                 RenderText(FormatPercentString(aCol.SectionTotal,aCol),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,lStyle);
              end;


              {total title}
              if ( i = 0)
              and ( not ( aCol.isTotalCol or aCol.isAverageCol or ACol.IsPercentageCol))
              and (TotalName > ' ') then begin // Dont wan't empty blocks
                 RenderText( TotalName, makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,lStyle);
              end;

              finally
                lStyle.Free;
              end;
           end;
                { for }
       NewDetailLine;
       NewDetailLine;

       {reset SectionTotals}
       ClearSectionTotal;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailSubTotal(const TotalName : string; NewLine: Boolean = True;
  KeepTotals: Boolean = False; TotalSubName: string = ''; Style: TStyleTypes = siSectionTotal);
{requires 3 lines, draws one line above}
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  Value, Quantity, Average : currency;
  lStyle: TRenderStyle;
begin
    Report.ItemStyle := Style;
    RequireLines(3);
    RenderTotalLine(false, ttSub);
    with Report, PrintJob do begin
       for i := 0 to Pred(Columns.ItemCount)  do        { Iterate }
           begin
              aCol := Columns.Report_Column_At(i);
              lStyle := MergeStyles( Report.ReportStyle.Items[Report.ItemStyle],aCol.Style);
              try
              {averaging cols}
              if (aCol.IsAverageCol) and (aCol.isTotalCol) then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                    else FormatS := aCol.TotalFormat;

                 Value    := aCol.ColValue.SubTotal;
                 Quantity := aCol.ColQuantity.SubTotal;

                 if Quantity <> 0.0 then
                    Average := Value / Quantity
                 else
                    Average := 0;
                 Average := SetSign_Curr( Average, SignOf( Quantity));

                 RenderText(FormatFloat(FormatS,Average),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end
              else if aCol.isTotalCol then { total cols }
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                          else FormatS := aCol.TotalFormat;
                 RenderText(FormatFloat(FormatS,aCol.subTotal),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end else if Acol.IsPercentageCol then begin
                 RenderText(FormatPercentString(aCol.subTotal,aCol),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end;

              {total title}
              if ( i = 0)
              and (TotalName > ' ')
              and ( not ( aCol.isTotalCol or aCol.isAverageCol)) then begin
                 RenderText( TotalName, makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end;
              {total sub-title}
              if ( i = 1)
              and (TotalSubName <> '')
              and ( not ( aCol.isTotalCol or aCol.isAverageCol or acol.IsPercentageCol)) then begin
                 RenderText( TotalSubName, makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end;
              finally
                 LStyle.Free;
              end;
           end;
                { for }
       NewDetailLine;
       if NewLine then
         NewDetailLine;

       {reset subtotals}
       if not KeepTotals then
         ClearSubTotals;
    end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderEmptyLine;
begin
  NewDetailLine;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderRuledLine;
begin
  if NewPagePending then
     ReportNewPage;
   with PrintJob do
      RenderLine(OutputAreaLeft, CurrY + LineSize div 2,OutputAreaWidth);
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderRuledLine(Style : TPenStyle);
var
  OldStyle : TPenStyle;
begin
  if NewPagePending then
     ReportNewPage;
   with PrintJob do
   begin
     OldStyle := Canvas.Pen.Style;
     Canvas.Pen.Style := Style;
     if (Style = psDot) and SmallerDottedLines then
       Canvas.Pen.Width := Canvas.Pen.Width - 1;
     RenderLine(OutputAreaLeft, CurrY + LineSize div 2,OutputAreaWidth);
     Canvas.Pen.Style := OldStyle;
     if (Style = psDot) and SmallerDottedLines then
       Canvas.Pen.Width := Canvas.Pen.Width + 1;
   end;
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderRuledLineWithColLines(LeaveLines: integer;
  aPenStyle: TPenStyle; VertColLineType: TVertColLineType);
var
  i: integer;
begin
  if FVertColLineType = vcUnknown then
    FVertColLineType := vcBottomHalf //First ruled line on page
  else if (CurrY + (LineSize * 3) + (LineSize * LeaveLines)) > FBodyBottom then
    FVertColLineType := vcTopHalf //Last ruled line on page
  else
    FVertColLineType := VertColLineType;

  //Render all vertical column lines for blank lines between detail lines
  for i := 0 to Pred(Report.Columns.ItemCount) do
    RenderVerticalColumnLine(i);
  RenderRuledLine(aPenStyle);

  FVertColLineType := vcFull;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderTextLine(Text: string; Underlined : boolean;
  AddLineIfUnderlined: boolean);
begin
   if UnderLined then
       RequireLines(2);
   if NewPagePending then
     ReportNewPage;
   Report.ItemStyle := siNormal;
   with PrintJob do begin

      if UnderLined then begin
        if AddLineIfUnderlined then
          NewDetailLine;
        Canvas.Font.Style  :=  Canvas.Font.Style + [fsUnderLine];
      end;

{    //Debug Code

      x := GetXFactor;
      y := GetYFactor;
      t := GetDetailMMRect.Top;
      l := GetDetailMMRect.Left;
      b := GetDetailMMRect.Bottom;
      r := GetDetailMMRect.Right;

      Text := Text + ' :  Line Size = ' + inttostr( LineSize) +
                      ' x factor = ' + formatfloat( '', x) +
                      ' y factor = ' + formatfloat( '', y)+
                      ' Detail Rect = ' + inttostr( t) + ' ' + inttostr( l) + ' ' + inttostr( b) + ' ' + inttostr( r) + ' '+
                      ' FDetailMin = ' + inttostr( FDetailTop) + ' Max = ' + inttostr( FDetailMax) +
                      '  CurrY ' + inttostr( CurrY) + ' ' + inttostr( CurrY - FDetailTop);
}

      RenderText(Text, makeRect(OutputAreaLeft,CurrY,OutputAreaWidth,LineSize),jtLeft,DefaultRenderStyle);

      //if UnderLined then
      //  Canvas.Font.Assign( DefaultFont);
   end;
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderTitleLine(Text: string);
var LStyle: TRenderStyle;
begin
  FVertColLineType := vcUnknown;  //First line of new account

  with PrintJob do begin
     RequireLines(3);
     if NewPagePending then
         ReportNewPage;
     Report.ItemStyle := siSectionTitle;
     NewDetailLine;
     lStyle := MergeStyles( Report.ReportStyle.Items[Report.ItemStyle],DefaultRenderStyle);
     try

        RenderText(Text,makeRect(OutputAreaLeft,CurrY,OutputAreaWidth,LineSize),
           AlignmentToJustification(Report.ReportStyle.Items[siSectionTitle].Alignment)
              ,LStyle);
     finally
        LStyle.Free;
     end;
     NewDetailLine;
     NewDetailLine;

     //Canvas.Font.Assign(DefaultFont);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderTotalLine(double: boolean; TotalType: TTotalType);
var
   i : integer;
   aCol : TReportColumn;
begin // No Text Just 'Lines'
  if NewPagePending then
     ReportNewPage;

  with Report do
    for i := 0 to Pred(Columns.ItemCount)  do        { Iterate }
    begin
       aCol := Columns.Report_Column_At(i);
       if (aCol.isTotalCol)
       or (aCol.IsPercentageCol) and
          ((aCol.isGrandTotalCol and (TotalType = ttGrand)) or (TotalType <> ttGrand)) then
          if not double then
             RenderLine(aCol.Left, CurrY + LineSize div 2,aCol.Width)       {1/2}
          else begin
             RenderLine(aCol.Left, CurrY + LineSize div 3,    aCol.Width);  {1/3}
             RenderLine(aCol.Left, CurrY + LineSize div 3 * 2,aCol.Width);  {2/3}
          end;
    end;
  NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderVerticalColumnLine(ColNo: Integer);
var
  aCol : TReportColumn;
  LineX, LineY: integer;
  LineHeight: integer;
begin
  aCol := Report.Columns.Report_Column_At(ColNo);

  if Report.ReportStyle.Items[siDetail].Background <> clNone then
    Exit;

  LineX := aCol.Left;
  LineY := CurrY;
  case FVertColLineType of
    vcFull       : LineHeight := LineSize;
    vcBottomHalf : begin
                     LineY := CurrY + (LineSize div 2);
                     LineHeight := (LineSize div 2) + 1;
                   end;
    vcTopHalf    : begin
                     LineHeight := (LineSize div 2);
                   end;
    else LineHeight := 0;
  end;
  RenderVerticalLine(LineX, LineY, LineHeight);
  //Right edge of last column
  if ColNo = Pred(Report.Columns.ItemCount) then begin
    LineX := aCol.Left + aCol.Width;
    RenderVerticalLine(LineX, LineY, LineHeight);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderVerticalLine(x, y, width: integer);
begin
  with PrintJob do
    Canvas.Polyline([ ConvertToDC( Point(x,y)),ConvertToDC( Point(x,y+width))]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderAllVerticalColumnLines;
var
  i: integer;
begin
  if NewPagePending then
    ReportNewPage;

  FVertColLineType := vcFull;
  //Render all vertical column lines for blank lines between detail lines
  for i := 0 to Pred(Report.Columns.ItemCount) do
    RenderVerticalColumnLine(i);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Draw a line under a specified column
procedure TRenderToCanvasEng.RenderColumnLine(ColNo: Integer);
var
   aCol : TReportColumn;
begin
  with Report do
  begin
    if ColNo >= Report.Columns.ItemCount then
      exit;
    if NewPagePending then
      ReportNewPage;
    aCol := Columns.Report_Column_At(ColNo);
    RenderLine(aCol.Left, CurrY + LineSize div 2,aCol.Width);
    NewDetailLine;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.ReportNewPage;
var KeepStyle: TStyleTypes;
begin
   //Call process messages so that cancel click can be detected
   Application.ProcessMessages;
   //Keep the current style...
   KeepStyle := Report.ItemStyle;
     //tell the printer to start a new page, this will in turn call DoNewPageStuff
     PrintJob.StartNewPage;
   // set the style back...
   Report.ItemStyle := KeepStyle;

   FVertColLineType := vcUnknown;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.SingleUnderLine;
begin
  RequireLines(2);
  RenderTotalLine(false, ttNone);
end;

procedure TRenderToCanvasEng.SplitText(const Text: String; ColumnWidth: Integer; var WrappedText: TWrappedText);

  procedure AddLine(const Line: String);
  var
    LineCount: Integer;
  begin
    LineCount := Length(WrappedText);

    SetLength(WrappedText, LineCount + 1);

    WrappedText[LineCount] := Line;
  end;

const
  MARGIN_MM: integer = 5; // 0.5mm

var
  Words: TStringList;
  Line: String;
  Index: Integer;
  LastAdded: Boolean;
  TextSize: TSize;
  TextLength: Integer;
  PrintableWidth: Integer;
  MoreWords: Boolean;
begin
  Words := TStringList.Create;

  try
    Words.Delimiter := ' ';
    Words.StrictDelimiter := True;

    Words.DelimitedText := Text;

    LastAdded := False;

    Line := '';

    PrintableWidth := ColumnWidth - (MARGIN_MM * 2);

    MoreWords := Words.Count > 0;

    Index := 0;
    
    while MoreWords do
    begin             
      Line := Trim(Line + ' ' + Words[Index]);

      if Index < Words.Count -1 then
      begin
        TextSize := PrintJob.Canvas.TextExtent(Trim(Line + ' ' + Words[Index + 1]));

        TextLength := PrintJob.ConvertToMM(Point(TextSize.cx, TextSize.cy)).X;

        if TextLength > PrintableWidth then
        begin
          AddLine(Line);

          Line := '';
        end;
      end
      else
      begin
        AddLine(Line);

        Break;
      end;
            
      Inc(Index);

      MoreWords := Index < Words.Count;
    end;
  finally
    Words.Free;
  end;
end;

procedure TRenderToCanvasEng.RenderFooter(Band: TRTFBand; atPos: Integer);
var H: Integer;
begin
   if Band.IsAvailable then begin
      H :=  Band.Height;
      if H > 0 then begin
         Band.PaintSection(PrintJob, atPos);
      end;
      CurrY := atPos + H;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.DoNewPageStuff(Sender: TObject);
var
  SavedDetailList : TStringList;
  //TopLeft, BottomRight : Tpoint;
  //WasColor : TColor;
begin
  //using the point to 01 mm constant and the font point size gives consistent
  //lines per page for both printer and screen

  NewPagePending := False;
  PageEndPending := true;
  SavedDetailList := nil;
  try
    //check to see if we have current detail that need rendering
    if (Report.CurrDetail.Count > 0) then
    begin
      //store the current detail
      SavedDetailList := TStringList.Create;
      SavedDetailList.Text := Report.CurrDetail.Text;
    end;

    //Print RTF Page Header}
    CurrY := PrintJob.OutputAreaTop;
    if PrintJob.UseHeaderFooter then begin
       if (PrintJob.CurrentPageNo = 1)
       and Report.Sections[hf_HeaderFirst].IsAvailable then
          CurrY := CurrY + Report.Sections[hf_HeaderFirst].PaintSection(PrintJob,CurrY)
       else
          CurrY := CurrY + Report.Sections[hf_HeaderAll].PaintSection(PrintJob,CurrY);
    end;
    //Print the normal report headers
    RenderPageHeaderFooter(Report.Header);

    FBodyTop := CurrY;
    {Print Page Footer}
    //CurrY := FPageBottom;
    //RenderPageHeaderFooter(Report.Footer);

    {Print Detail Header}
    CurrY := FBodyTop;
    // The empty sizing reports dont notice that it is out of step..
    Report.ReportStyle.Items[siHeading].AssignTo(PrintJob);
    RenderDetailHeader;

    if (Assigned(FOnAfterNewPage)) then
      FOnAfterNewPage(Sender)
    else
      Report.AfterNewPage( Assigned( SavedDetailList));

    //check to see if there is current detail that needs restoring
    if Assigned( SavedDetailList) then
    begin
      //restore the current detail
      Report.SetCurrDetail( SavedDetailList);
    end;

  (* //debug code, frame the page
   TopLeft := Point( PrintJob.OutputAreaLeft, PrintJob.OutputAreaTop);
   BottomRight := Point( PrintJob.OutputAreaLeft + PrintJob.OutputAreaWidth,
                         PrintJob.OutputAreaTop + PrintJob.OutputAreaHeight);
   TopLeft := PrintJob.ConvertToDC( TopLeft);
   BottomRight := PrintJob.ConvertToDC( BottomRight);
   WasColor := PrintJob.Canvas.Brush.Color;
   PrintJob.Canvas.Brush.Color := clBlack;
   PrintJob.Canvas.FrameRect( Rect( TopLeft.X, TopLeft.Y, BottomRight.X, BottomRight.Y));
   PrintJob.Canvas.Brush.Color := WasColor;
  *)
  finally
    FreeAndNil( SavedDetailList);
  end;
  Report.BlindOn := True;
end;

procedure TRenderToCanvasEng.DoPageEndStuff(Sender: TObject);
begin
   if PageEndPending then begin
      PageEndPending := False;
      CurrY := FBodyBottom;;
      RenderPageHeaderFooter(Report.Footer);
      if PrintJob.UseHeaderFooter then begin
         //TryFooter(Report.Sections[hf_FooterAll],FFooterTop);
      end;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.SetHeightFromImage( HFLine : THeaderFooterLine);
var
  Pos1, Pos2 : Integer;
  Picture : TPicture;
  ImgWidth, ImgHeight : Integer;
  ImageName  : String;
begin
  with HFLine do
  begin
    if AutoLineSize then
    begin
      Pos1 := Pos( IMGFIELD, HFLine.Text) + Length(IMGFIELD) + 1; //<IMG[space]
      Pos2 := Pos1;
      while (Pos2 <= Length(Text))
      and (Text[Pos2] <> '>') do
         Inc(Pos2);
      ImageName := Copy(Text, Pos1, Pos2 - Pos1);
      Picture := ReportImageList.GetImage(ImageName, ImgWidth, ImgHeight);
      if (Assigned(Picture)) then
      begin
        if (ImgHeight > 0) then begin
           SetAutoLineSize := (ImgHeight * 10); //in mm
        end else begin
           SetAutoLineSize := Picture.Height;
        end;
      end;
    end;
  end;
end;

procedure TRenderToCanvasEng.SetItemStyle(const Value: TStyleTypes);
begin
   Report.ReportStyle.Items[Value].AssignTo(PrintJob);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetAveCharWidth( TestFont : TFont; Text : string) : integer;
var
  DC: HDC;
  SaveFont: HFont;
  //Metrics: TTextMetric;
  S: TSize;
  l : integer;
begin
  l := length(Text);
  if ( L = 0) then
    result := 0
  else
  begin
    DC := GetDC( 0 );
    try
      SaveFont := SelectObject( DC, TestFont.Handle );
      //GetTextMetrics( DC, Metrics );
      GetTextExtentPoint32( DC, PChar( Text), Length( Text), S );
      Result := Round( S.cx / Length( Text));
      //result := Metrics.tmAveCharWidth;
      SelectObject( DC, SaveFont );
    finally
      ReleaseDC( 0, DC );
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.RebuildHeaderFooter( HFCollection : THeaderFooterCollection):Integer;
var
  i, j : integer;
  HFLine : THeaderFooterLine;
  NewHFLine : THeaderFooterLine;

  AvgCharWidthInPixels : integer;
  PPM : double;
  MMPerChar : double;
  CharPerLine : integer;
  WrappedText : TStringList;
begin
  Result := 0;
  //remove any presplit hf lines
  for i := HFCollection.Last downto HFCollection.First do
  begin
    HFLine := HFCollection.HFLine_At(i);
    if HFLine.LineType = hftWrapped then
       HFCollection.DelFreeItem(HFLine);
  end;

  //cycle thrue looking for header footer lines to split
  i := HFCollection.First;
  while i < HFCollection.ItemCount do begin
     HFLine := HFCollection.HFLine_At(i);
     //see if header line is an image tag
     if HFLine.UserLine then
        if not PrintJob.UseHeaderFooter then begin
           inc(I); // Still need this..
           Continue;
        end;

     if Pos('<RTFFOOTER>',HFLine.Text) > 0 then begin
        HFLine.LineSize :=  Report.Sections[hf_FooterAll].Height;
        Result := Result + HFLine.LineSize;
     end else if Pos( IMGFIELD, HFLine.Text) > 0 then begin
        SetHeightFromImage(HFLine);
        Result := Result + HFLine.LineSize;
     end else begin
        //header line is text, set default properties
        if not HFLine.UserLine then // Re-aply Style 
           Report.ReportStyle.Items[HFLine.ReportStyle].AssignTo(HFLine);

        if (HFLine.LineType = hftDefault) then
           HFLine.Font.Name := DefaultFont.Name;
        if HFLine.FontFactor <> 0 then
           HFLine.Font.Size := Round(DefaultFont.Size * HFLine.FontFactor);
        if HFLine.AutoLineSize then
           HFLine.SetAutoLineSize := Round(HFLine.Font.Size * POINT_TO_01MM * HEADER_LINE_SIZE_INFLATION);

        if (HFLine.WrapTextOn)
        and (HFLine.Text <> '') then begin
           //Estimate # of characters for each header line to use for wrapping
           AvgCharWidthInPixels := GetAveCharWidth( HFLine.Font, HFLine.Text);
           //Get Pixels / mm
           PPM := ( Screen.PixelsPerInch / 254);// * CORRECTION_RATIO;
           MMPerChar := AvgCharWidthInPixels / PPM;
           //Max characters per line, use 95% of line incase printout wrong
           CharPerLine := Trunc( ( PrintJob.OutputAreaWidth * 0.95) / MMPerChar);

           if length(HFLine.Text) > CharPerLine then begin
              WrappedText := TStringList.Create;
              try
                 WrappedText.Text := GenUtils.WrapText( HFLine.Text, CharPerLine);
                 for j := 0 to WrappedText.Count -1 do  begin
                   //create new header lines and insert into list
                   NewHFLine := THeaderFooterLine.Create;
                   NewHFLine.Assign( HFLine);
                   NewHFLine.Text := WrappedText[j];
                   NewHFLine.WrapTextOn := False;
                   NewHFLine.LineType := hftWrapped;
                   //insert occurs before index so move to next line
                   Inc( i);
                   HFCollection.AtInsert( i, NewHFLine);
                   Result := Result + NewHFLine.LineSize;
                 end;
              finally
                FreeAndNil( WrappedText);
              end;
           end else begin
              //line doesn't need wrapping, but add wrapped line so it will be
              //printed
              NewHFLine := THeaderFooterLine.Create;
              NewHFLine.Assign( HFLine);
              //NewHFLine.Text := HFLine.Text;
              NewHFLine.WrapTextOn := False;
              NewHFLine.LineType := hftWrapped;
              //insert occurs before index so move to next line
              Inc( i);
              HFCollection.AtInsert( i, NewHFLine);
              Result := Result + NewHFLine.LineSize;
           end;

        end else begin
           Result := Result + HFLine.LineSize;
        end;
     end;
    //move to next line
    Inc( i);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.DoBeforePrintStuff(Sender: TObject);
//Recalculate the column widths and available area given page specifications
var
  DetailHeight : integer;
  Perc         : Double;
  i            : integer;
begin
   with PrintJob, Report do begin
      //Update app status
      UpdateAppStatus('Generating Report', ReportTitle, 50);


      //set the default font from the currently selected report font
      //reason for setting here is that user may have changed the default font
      //in the setup dlg
      //Note that the FontScaleFactor is never changed, it is always set automatically

      (*
      NewSize := Round( PrintJob.UserFontSize * PrintJob.FontScaleFactor);
      if NewSize < 2 then
        NewSize := 2;
      with DefaultFont do begin
         Size := NewSize;
         Name := PrintJob.UserFontName;
         Style:= PrintJob.UserFontStyle;
      end;
      *)
      if HasStyle then
         if UseStyle then
            Report.ReportStyle.load
         else
            Report.ReportStyle.Reset;

      Report.ReportStyle.Items[siDetail].AssignTo(DefaultFont);
      //Set column widths
      for i := 0 to Pred(Columns.ItemCount) do
         with Columns.Report_Column_At(i) do begin
            if LeftPercent <> 0.0 then
               Left := OutputAreaLeft + Round(OutputAreaWidth * LeftPercent/100);
            if WidthPercent <> 0.0 then
               Width := Round(OutputAreaWidth * WidthPercent/100);
         end;
      // Make sure they "Right align"
      if Columns.ItemCount > 0 then
         with Columns.Report_Column_At(Pred(Columns.ItemCount)) do begin
            if LeftPercent + WidthPercent > 85 then
               Width := (OutputAreaLeft + OutputAreaWidth - Left);
         end;
      if PrintJob.UseHeaderFooter then begin
         // Pass the job setting to the RTF Bands
         for I := Integer(Low(Sections)) to Integer(High(Sections)) do
            Sections[THFSection(I)].SetPrintJob(PrintJob);
      end;


      //Rebuild Headers and Setup Dimensions
      FPageTop := OutputAreaTop;
      FPageBottom := OutputAreaTop + OutputAreaHeight;

      FbodyTop := FPageTop + RebuildHeaderFooter(Header);

      FBodyBottom := FPageBottom - RebuildHeaderFooter(Footer);

      //Move current Y position on the page to the top of the page
      CurrY      := OutputAreaTop;

      //*** this code is designed to handle the case where the user has selected
      //*** a font size that is too large for the selected paper size

      //check the size of the detail section to determine if font size selected is
      //too big.  Work out percentage of page that can be used for detail
      DetailHeight :=( FBodyBottom - FBodyTop);
      if OutputAreaHeight > 0 then
         perc := DetailHeight / OutputAreaHeight
      else
         perc := 0;
      //Font is too big if DetailTop > DetailMax or if detail is less than 10% of
      //the page height
      if (DetailHeight < 0) or (perc < 0.1) then begin
         //Current font would not fit.  Redirect the NewPage on OnPrint methods
         PrintJob.OnNewPage     := nil;
         PrintJob.OnPrintMethod := PrintFontTooBigPage;
         PrintJob.OnPageEnd     := nil;
         PrintJob.OnDocumentEnd := nil;
      end else begin
         //Selected Font is OK, Set NewPage and OnPrint methods
         PrintJob.OnNewPage     := DoNewPageStuff;
         //Assign the on print method of the bkprintjob to callreport on printer
         //This means that the bkprint event of the report will be called
         PrintJob.OnPrintMethod := CallReportOnPrint;
         PrintJob.OnPageEnd :=  DoPageEndStuff;
         PrintJob.OnDocumentEnd := DoDocumentEndStuff;
      end;
   end;
end;
procedure TRenderToCanvasEng.DoDocumentEndStuff(Sender: TObject);

var H: Integer;
    NeedOneMorePage: Boolean;
    DoLastPage: Boolean;
begin
   NeedOneMorePage := False;
   DoLastPage := (Sender = nil);
   if PageEndPending then begin
      PageEndPending := False;

      if PrintJob.UseHeaderFooter then begin
         // First we have to check which footer to use..
         if Report.Sections[hf_FooterLast].IsAvailable then begin
            H := Report.Sections[hf_FooterLast].Height - Report.Sections[hf_FooterAll].Height;
            if ((CurrY + H) > FBodyBottom) then begin
               // Wont Fit, Go to the next page
               NeedOneMorePage := True;
            end else begin
               DoLastPage := True;
               //Addjust the Height
               FBodyBottom := FBodyBottom - H;
            end;
         end;

      end;
      CurrY := FBodyBottom;
      RenderPageHeaderFooter(Report.Footer, DoLastPage);
   end;
   if NeedOneMorePage
   and Assigned(Sender) then begin
      ReportNewPage;
      PageEndPending := True;
      DoDocumentEndStuff(nil);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.CallReportOnPrint(Sender: TObject);
begin
   Report.ClearAllTotals;
   Report.BKPrint;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//function TRenderToCanvasEng.RenderFontHeight(newFont: TFont): integer;
//var
//   tempFont : TFont;
//begin
//   with PrintJob do begin
//      tempFont := Canvas.Font;
//      Canvas.Font.Assign(newFont);
//      {Set Line size by looking a size of current font on canvas}
//      result := round(PrintJob.HeightOfText('A'));
//      Canvas.Font.Assign(tempFont);
//   end;
//end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderPageHeaderFooter(HF: THeaderFooterCollection; LastPage: Boolean = False);
var
   i, Pos1, Pos2 : integer;
   ALine : THeaderFooterLine;
   LineWidth : integer;
   Left      : integer;
   DisplayText : string;
begin
   for i := 0 to Pred(HF.ItemCount) do        { Iterate }
   with PrintJob do begin
      aLine := HF.HFLine_At(i);
      if (aLine.LineType = hftUnwrapped)
      or (aLine.WrapTextOn) then
         Continue;
      if ALine.UserLine then
         if not PrintJob.UseHeaderFooter then
            Continue;
      //Images
      if FindValueInData(aLine.Text, IMGFIELD, DisplayText) then
      begin
         {work out alignment ... if centered then use width of page }
         left := 0;

         if (aLine.Alignment = jtLeft)
         or (aLine.Alignment = jtCenter) then
              Left := OutputAreaLeft;

         if aLine.Alignment = jtRight then begin
            Left := OutputAreaLeft + OutputAreaWidth;
            LineWidth := -LineWidth;
         end;
         RenderImage(DisplayText,makeRect(left,CurrY,lineWidth,aLine.LineSize),aLine.Alignment,aLine.Style, aLine.DoNewLine);
      end else if Pos('<RTFFOOTER>',aLine.Text) > 0 then begin
         if LastPage then
             RenderFooter(Report.Sections[hf_FooterLast],CurrY)
         else
             RenderFooter(Report.Sections[hf_FooterAll],CurrY);
      end else begin
         //Text
         DisplayText := ReplaceSpecial(aLine.Text);
         Canvas.Font := aLine.Font;

         LineWidth := OutputAreaWidth;

         {work out alignment ... if centered then use width of page }
         left := 0;

         if (aLine.Alignment = jtLeft)
         or (aLine.Alignment = jtCenter) then
            Left := OutputAreaLeft;

         if aLine.Alignment = jtRight then begin
            Left := OutputAreaLeft + OutputAreaWidth;
            LineWidth := -LineWidth;
         end;
         if DisplayText > ' ' then // a bit of a hack for case 8321
            RenderText(DisplayText,makeRect(left,CurrY,lineWidth,aLine.LineSize),aLine.Alignment,aLine.Style);
         if aLine.DoNewLine then
              //NewLine;
            CurrY := CurrY + aLine.LineSize;
      end;

   end;        { for }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.ReplaceSpecial(textValue: string): string;
var
   markerPos : integer;
   textBefore,textAfter : string;
begin
  //date
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

  //date time
  markerPos := Pos(DATETIMEFIELD,TextValue);
  if markerPos > 0 then
  begin
    {find the date field and replace it with current date}
    textBefore := Copy(textValue,1,markerPos-1);
    textAfter  := Copy(textValue,markerPos+length(DATETIMEFIELD),length(textValue)-markerPos+length(DATETIMEFIELD));

    TextValue := textBefore+DateTimeToStr(now)+textAfter;
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
  if NewPagePending then
    ReportNewPage;
   with PrintJob do begin
      Canvas.Polyline([ ConvertToDC( Point(x,y)),ConvertToDC( Point(x+width,y))]);
   end;        { with }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderText(TextValue: string; TextRect: TRect;
  Justify: TJustifyType; RenderStyle: TRenderStyle);
{Canvas Font should be set before rendering text}
{Canvas color will be changed to render sytle and then reset}
procedure LTextRect(Rect: TRect; X, Y: Integer; const Text: string);
var
  Options: Longint;
begin
  //PrintJob.Canvas.RequiredState([csHandleValid, csFontValid, csBrushValid]);
  Options := PrintJob.Canvas.TextFlags;
  if PrintJob.Canvas.Brush.Style <> bsClear then
    Options := Options or ETO_OPAQUE;
  if ((PrintJob.Canvas.TextFlags and ETO_RTLREADING) <> 0) and
     (PrintJob.Canvas.CanvasOrientation = coRightToLeft) then Inc(X, PrintJob.Canvas.TextWidth(Text) + 1);
  Windows.ExtTextOut(PrintJob.Canvas.Handle, X, Y, Options, @Rect, PChar(Text),
    Length(Text), nil);
end;
const
  MARGIN_MM: integer = 5; // 0.5mm
var
  RenderRect: TRect;
  TextSize : TSize;
  wasColor: TColor;
  wasFColor: TColor;
  Margin: integer;
begin
  //process the text value looking for special markers
  if TextValue = SKIPFIELD then
    Exit; // Nothing to do

  TextSize := PrintJob.Canvas.TextExtent(TextValue);

  //left and right margin
  Margin := PrintJob.ConvertToDC(Point(MARGIN_MM, MARGIN_MM)).x;

  //convert from 0.1mm to pixels
  TextRect.TopLeft := PrintJob.ConvertToDC(TextRect.TopLeft);
  TextRect.BottomRight := PrintJob.ConvertToDC(TextRect.BottomRight);

  //first sort out top and bottom
  if TextSize.cy >= (TextRect.Bottom - TextRect.Top) then
    //Height of text is bigger than box so use top
    RenderRect.Top := TextRect.Top
  else
    RenderRect.Top := TextRect.Top +
      (PrintJob.ConvertToDC(Point(0, LineSize)).Y - TextSize.cy) div 2;
  RenderRect.Bottom := TextRect.Bottom;

  //now sort out left and right
  if (TextSize.cx + (2 * Margin)) >= (TextRect.Right - TextRect.Left) then begin
    //width is greater than box so use left
    RenderRect.Left := TextRect.Left + Margin;
    RenderRect.Right := TextRect.Right - Margin;// - ( 2 * Margin);
  end else begin
    // Use the justification
    case Justify of
      jtLeft:
        begin
          RenderRect.left := TextRect.Left + Margin;
          RenderRect.Right := RenderRect.Left + TextSize.cx + Margin;
        end;
      jtCenter:
        begin
          RenderRect.Left := TextRect.Left + (TextRect.Right - TextRect.Left)
                             div 2 - ((TextSize.cx div 2) + ( 2 * Margin));
          RenderRect.Right := RenderRect.Left + (TextSize.cx + ( 2 * Margin));
        end;
      jtRight:
        begin
          RenderRect.Right := TextRect.Right - Margin;
//          RenderRect.Left := RenderRect.Right - (TextSize.cx + ( 2 * Margin));
          RenderRect.Left := RenderRect.Right - (TextSize.cx + Margin);
        end;
    end; // case
  end; // begin

  //Store Current Brush Color
  wasColor := PrintJob.Canvas.Brush.Color;
  wasFColor := PrintJob.Canvas.Font.Color;

  //fill in background
  if RenderStyle.BackColor <> clNone then begin
    PrintJob.Canvas.Brush.Color := RenderStyle.BackColor;
    PrintJob.Canvas.FillRect(TextRect);
  end;

  //now print text
  if RenderStyle.FontColor <> clNone then
    PrintJob.Canvas.Font.Color := RenderStyle.FontColor;

  // Turn the opaque flag off
  PrintJob.Canvas.Brush.Style := bsClear;
  // May need to localise the TextRect  procedure to stop clipping of the last char
  // The problem is that it does not clip at all..
  // So you'd have to shorten the text to almost clip. (With elipses ??)
  PrintJob.Canvas.TextRect(RenderRect,
  //LTextRect(RenderRect,
                           RenderRect.Left,
                           RenderRect.top,
                           TextValue);
  PrintJob.Canvas.Brush.Color := wasColor;
  PrintJob.Canvas.Font.Color  := wasFColor;

  //Test for rendering gridlines like Excel
{  if (RenderStyle.BorderStyle <> []) then begin
    RenderStyle.BorderColor := clBlack;
    wasColor := PrintJob.Canvas.Pen.Color;
    PrintJob.Canvas.Pen.Color := RenderStyle.BorderColor;
    //Left
    if bsLeft in RenderStyle.BorderStyle then
      PrintJob.Canvas.Polyline([point(TextRect.Left, TextRect.Top),
                                point(TextRect.Left, TextRect.Bottom)]);
    //Right
    if bsRight in RenderStyle.BorderStyle then
      PrintJob.Canvas.Polyline([point(TextRect.Right, TextRect.Top),
                                point(TextRect.Right, TextRect.Bottom)]);
    //Top
    if bsTop in RenderStyle.BorderStyle then
      PrintJob.Canvas.Polyline([point(TextRect.Left, TextRect.Top),
                                point(TextRect.Right, TextRect.Top)]);
    //Bottom
    if bsBottom in RenderStyle.BorderStyle then
      PrintJob.Canvas.Polyline([point(TextRect.Left, TextRect.Bottom),
                                point(TextRect.Right, TextRect.Bottom)]);
      PrintJob.Canvas.Pen.Color := wasColor;
  end; }
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure WinGetMem(var P: Pointer; Size: DWord);
begin
  P := VirtualAlloc(nil, Size, MEM_COMMIT or MEM_RESERVE,
                    PAGE_READWRITE);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure WinFreeMem(P: Pointer);
begin
  if not VirtualFree(P, 0, MEM_RELEASE) then
    RaiseLastOSError;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderImage(TextValue : string; textRect : TRect;
  Justify : TJustifyType; RenderStyle :TRenderStyle; DoNewLine : boolean; aPercSize : integer);
var
  ImgLineSize : LongInt;
  Picture : TPicture;
  ImgWidth, ImgHeight : Integer;
  PictureRect : TRect;
  //RenderRect : TRect;
  //BitmapHeader:  pBitmapInfo;
  //BitmapImage :  pointer;
  //HeaderSize : dword;    // Use DWORD for D3-D5 compatibility
  //ImageSize : dword;
  //DIBWidth : longint;
  //DIBHeight : longint;
begin
  if NewPagePending then
    ReportNewPage;

  ImgLineSize := TextRect.Bottom-TextRect.Top;

  with PrintJob do
  begin
    Picture := ReportImageList.GetImage(TextValue, ImgWidth, ImgHeight);

    if (Assigned(Picture)) then begin


      with PictureRect do begin
         Left := 0;
         Top := 0;

         if (ImgWidth > 0) then
            Right := ImgWidth * 10
         else
            Right := Picture.Width;

         if (ImgHeight > 0) then
            Bottom := ImgHeight * 10
         else
            Bottom := Picture.Height;
      end;

      //now sort out Alignment
      if (PictureRect.Right) >= (textRect.Right - textRect.Left) then begin
         //Picture Too wide...
         //RenderRect.Left := textRect.Left;
         //RenderRect.Right  := textRect.Right;
         PictureRect := TextRect;
      end else begin
        case Ord(Justify) of
          Ord(jtLeft):         {left}
            begin
               OffsetRect(PictureRect,textRect.Left,textRect.Top);
            end;
          ord(jtCenter):         {center}
            begin
             OffsetRect(PictureRect,textRect.Left + (textRect.Right - textRect.Left - PictureRect.Right) div 2,textRect.Top);
            end;
          ord(jtRight):          {right}
            begin
             OffsetRect(PictureRect,textRect.Right  - PictureRect.Right,textRect.Top);
            end;
        end;        { case }
      end;             { begin}

      //have the image, know where it is going
      try
        //RenderRect.Bottom := RenderRect.Top + PictureRect.Bottom;

        {convert from 0.1mm to pixels}

        with PictureRect do  begin
          TopLeft := PrintJob.ConvertToDC(TopLeft);
          BottomRight := PrintJob.ConvertToDC(BottomRight);
        end;

        if aPercSize <> 100 then
        begin
          PictureRect.Right   := PictureRect.Left + trunc((PictureRect.Right - PictureRect.Left) * ((aPercSize)/100));
          PictureRect.Bottom := PictureRect.Top + trunc((PictureRect.Bottom - PictureRect.Top) * ((aPercSize)/100));
          //aPercSize
        end;

       //PictureRect := Rect(5,5,100,50);
       (*
       Windows.StretchBlt(Canvas.Handle,
             PictureRect.Left,
             PictureRect.Top,
             PictureRect.Right - PictureRect.Left,
             PictureRect.Bottom - PictureRect.Top,
             Picture.Canvas,
             0,
             0,
             Picture.Graphic.Width,
             Picture.Graphic.Height,
             SRCCOPY );

         *)

       //DestDC: HDC; X, Y, Width, Height: Integer; SrcDC: HDC;
  //XSrc, YSrc, SrcWidth, SrcHeight: Integer; Rop: DWORD


        Canvas.StretchDraw(PictureRect,Picture.Graphic);
        (*
        GetDIBSizes(Picture.Bitmap.Handle, HeaderSize, ImageSize);

        WinGetMem(BitmapImage,  ImageSize);
        try
          GetMem(BitmapHeader, HeaderSize);
          try
            GetDIB(Picture.Bitmap.Handle, Picture.Bitmap.Palette, BitmapHeader^, BitmapImage^);
            with BitmapHeader^.bmiHeader do
            begin
              DIBWidth := biWidth;
              DIBHeight := biHeight;
            end;

//  There is a problem in delphi that causes the bitmap to appear as black rect
//  instead of picture.  Try rendering twice
            Canvas.CopyMode := cmSrcCopy;
            StretchDIBits(Canvas.Handle,
                  RenderRect.Left,    // Destination Origin
                  RenderRect.Top,
                  PictureRect.Right - PictureRect.Left, // Destination Width
                  PictureRect.Bottom - PictureRect.Top,  // Destination Height
                  0,             // Source Origin
                  0,
                  DIBWidth,      //Source Picture.Width,
                  DIBHeight,     //Picture.Height,
                  BitmapImage,
                  BitmapHeader^,
                  DIB_RGB_COLORS,
                  SRCCOPY);
          finally
            FreeMem(BitmapHeader);
          end;
        finally
          WinFreeMem(BitmapImage);
        end;
        *)
      finally
      end;

      if DoNewLine then
        CurrY := CurrY + ImgLineSize;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.PrintFontTooBigPage(Sender: TObject);
//This output will be generated when the font size selected would produce
//headers and footers that take up more than 90% of the page
begin
   with PrintJob do begin
      CurrY := OutputAreaTop;
      RenderTextLine('The headers and footers are too big for the paper size.', False);
      RenderTextLine('Please select smaller font or image sizes.', False);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.GetDetailMMRect: TRect;
//returns the bounds of the detail section of the current report. units are 0.1mm
begin
   with PrintJob do begin
      result := Rect( OutputAreaLeft, FbodyTop, OutputAreaWidth + OutputAreaLeft, FBodyBottom);
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
   ClearStatus;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderMemo(Text: string);
//introduced to support rendering the cover pages notes on the client header
//page during scheduled reports.

//wraps the text provided in to a rect defined by the current y pos, and the
//left, bottom, and right margins
var
   StringPixelWidth       : integer;
   MaxPixelsAvailable     : integer;
   TestChars              : integer;
   DetailPixelRect        : TRect;
   MaxChars               : integer;
   Memo                   : TStringList;
   WrappedText            : string;
   i                      : integer;
begin
   if Trim( Text) = '' then exit;

   StringPixelWidth := 0;
   //determine max no of characters
   TestChars        := 1;
   DetailPixelRect := GetDetailPixelRect;
   MaxPixelsAvailable := DetailPixelRect.Right - DetailPixelRect.Left;
   while StringPixelWidth < MaxPixelsAvailable do begin
      StringPixelWidth := PrintJob.Canvas.TextWidth( ConstStr( 'X', TestChars ));  //returns pixels
      if StringPixelWidth < MaxPixelsAvailable then begin
         Inc( TestChars);
      end;
   end;
   MaxChars := TestChars - 1;

   //wrap the text
   WrappedText := GenUtils.WrapText( Text, MaxChars);
   Memo := TStringList.Create;
   try
      Memo.Text := WrappedText;
      //now render each line until all done or reach bottom of page
      for i := 0 to Pred( Memo.Count) do begin
         RenderTextLine( Memo[ i], false);
         if (CurrY + ( LineSize * 3)) > Fbodybottom then
            Break;
      end;
   finally
      Memo.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.RenderDetailSubSectionTotal(
  const TotalName: string);
{requires 3 lines, draws one line above}
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  Value, Quantity, Average : currency;
  lStyle: TRenderStyle;
begin
    Report.ItemStyle := siSectionTotal;
    RequireLines(3);
    RenderTotalLine(false, ttSubsection);
    with Report, PrintJob do begin
       for i := 0 to Pred(Columns.ItemCount)  do        { Iterate }
           begin
              aCol := Columns.Report_Column_At(i);
              lStyle := MergeStyles(Report.ReportStyle.Items[Report.ItemStyle], aCol.Style);
              try
              if aCol.isTotalCol then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                          else FormatS := aCol.TotalFormat;
                 RenderText(FormatFloat(FormatS,aCol.SubSectionTotal),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end;

              {averaging cols}
              if (aCol.IsAverageCol) and (aCol.isTotalCol) then
              begin
                 if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                    else FormatS := aCol.TotalFormat;

                 Value    := aCol.ColValue.SubSectionTotal;
                 Quantity := aCol.ColQuantity.SubSectionTotal;

                 if Quantity <> 0.0 then
                    Average := Value / Quantity
                 else
                    Average := 0;

                 RenderText(FormatFloat(FormatS,Average),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end else if Acol.IsPercentageCol then begin
                 RenderText(FormatPercentString(aCol.SubSectionTotal, aCol),makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end;

              {total title}
              if ( i = 0)
              and (TotalName > ' ')
              and ( not ( aCol.isTotalCol or aCol.isAverageCol or acol.IsPercentageCol)) then begin
                 RenderText( TotalName, makeRect(aCol.Left,CurrY,ACol.Width,LineSize),aCol.Alignment,LStyle);
              end;
              finally
                 LStyle.Free;
              end;
           end;
                { for }
       NewDetailLine;
       NewDetailLine;

       {reset SectionTotals}
       ClearSubSectionTotal;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.PrintPDF(Filename : String) : Boolean;
begin
  PrintJob.LoadSettingsFrom( Report.UserReportSettings );
  if Report.ReportStyle.Name > '' then begin
     PrintJob.HasStyle := True;
     PrintJob.UseStyle := True;
  end;
  if Report.ReportTypeParams.HasUserHeaderFooter then begin
      PrintJob.HasHeaderFooter := True;
      PrintJob.UseHeaderFooter := Report.ReportTypeParams.HF_Enabled;
  end;
  Result := PrintJob.PrintPDF(Filename);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.PrintToFax(FaxParam : TFaxParameters) : boolean;
begin
  PrintJob.LoadSettingsFrom( Report.UserReportSettings );
  PrintJob.UserFontSize := PrintJob.UserFontSize + 1;
  SmallerDottedLines := True;
  if Report.ReportStyle.Name > '' then begin
     PrintJob.HasStyle := True;
     PrintJob.UseStyle := True;
  end;
  if Report.ReportTypeParams.HasUserHeaderFooter then begin
      PrintJob.HasHeaderFooter := True;
      PrintJob.UseHeaderFooter := Report.ReportTypeParams.HF_Enabled;
  end;
  result := PrintJob.PrintToFax( FaxParam);
  SmallerDottedLines := False;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.UseCustomFont(aFontname: string; aFontSize: integer; aFontStyle: TFontStyles; aLineSize : integer);
begin
  PrintJob.Canvas.Font.Name := aFontName;
  PrintJob.Canvas.Font.Size := aFontSize;
  PrintJob.Canvas.Font.Style := aFontStyle;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToCanvasEng.UseDefaultFont;
begin
  //PrintJob.Canvas.Font.Assign( DefaultFont);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.GetTextLength(Text: string): Integer;
var
  P: TPoint;
  T: tagSIZE;
begin
  T := PrintJob.Canvas.TextExtent(Text);
  P.X := T.cx;
  P.Y := T.cy;
  P := PrintJob.ConvertToMM(P);
  Result := P.X;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToCanvasEng.LineSize: longint;
begin
  Result := Round(int(PrintJob.Canvas.font.Size * POINT_TO_01MM * LINE_SIZE_INFLATION)) + 1;
end;

function TRenderToCanvasEng.GetPrintableWidth: Integer;
begin
  Result := PrintJob.OutputAreaWidth;
end;

end.


