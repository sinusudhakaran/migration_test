unit ReportToExcel;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:  Report Rendering Engine for Excel

  Written: Dec 1999
  Authors: Matthew

  Purpose: Opens Excel application and populates the sheet with figures

  Notes:

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses
   Graphics,
   OfficeDM, OpExcel,
   ReportToFile, ReportTypes;

type
   TRenderToFileExcel = class( TRenderToFileBase)
   private
      Filename : String;
      CurrentLineNo : integer;
      DetailTopLineNo : integer;
      MyDataModule : TDataModuleOffice;

      ExcelRange   : TOpExcelRange;
      FUseTotalFormat: boolean;
      function ExcelAddress( const Value : integer; Row : integer) : string;
      function FixFormat(const Value: string): string;
   protected
      procedure RenderTotalLine(double: boolean); override;
      procedure NewDetailLine;                    override;
   public
      constructor Create( aOwner : TObject; fName : string); override;
      destructor  Destroy; override;

      procedure RenderPageHeader;
      procedure RenderPageFooter;
      procedure RenderDetailHeader;               override;
      procedure RenderDetailLine;                 override;
      procedure RenderDetailSubTotal(const TotalName : string; NewLine: Boolean = True;
        KeepTotals: Boolean = False; TotalSubName: string = ''; Style: TStyleTypes = siSectionTotal); override;
      procedure RenderTitleLine(Text : string);   override;
      procedure RenderTextLine(Text:string; Underlined : boolean; AddLineIfUnderlined: boolean = True);      override;
      procedure RenderRuledLine;                  overload; override;
      procedure RenderRuledLine(Style : TPenStyle);                  overload; override;
      procedure RenderColumnLine(ColNo: Integer); overload; override;
      
      procedure Generate;                         override;
   end;

//******************************************************************************
implementation

uses
  Globals,
  InfoMoreFrm,
  RepCols,
  NewReportObj,
  OpXL2k,
  SysUtils,
  ComObj;

Const
  PAGE_WIDTH = 225;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TRenderToFileExcel.Create( aOwner : TObject; fName : string);
var
  Path : String;
begin
  Path := ExtractFilePath(fName);

  if (Path = '') then
    Filename := DataDir + fName
  else
    Filename := fName;
  inherited Create(aOwner, fName);
  MyDataModule := TDataModuleOffice.Create( nil);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TRenderToFileExcel.Destroy;
begin
   MyDataModule.Free;
   inherited;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToFileExcel.ExcelAddress(const Value: integer;
  Row: integer): string;
var
  i : integer;
  Col : integer;
begin
  Col := Value + 1;  //value starts at 0 for first col
  i   := 0;
  while Col > 26 do begin
     Inc( i);
     Col := Col - 26
  end;
  if i > 0 then
     result := Chr( 64 + i) + Chr( 64 + Col)
  else
     result := Chr(64 + Col);

  result := result + inttostr( Row);
end;
function TRenderToFileExcel.FixFormat(const Value: string): string;
var P: Integer;
    c: Char;
begin
   Result := Value;
   P := Length(Value);
   if P = 0 then
      Exit;
   if Copy(Value, P - 1, 2) = ';-' then //column has numeric formatting
      Result := Copy(Value, 1, P - 2) + ';0.00';
   // Alow for multiple currencies in the
   c := Value[1];
   if c in ['$', '€', '£'] then
      Result := StringReplace(Value,c,'[$' + c + '-2]',[rfReplaceAll]);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.Generate;
//note: The dvExcel1 component will be disconnected and freed when this report object
//      is destroyed
var
  i : integer;

begin
   //create the data module that contains the Excel component
   with MyDataModule do begin
      with OpExcel1 do begin
         Visible := False;
         Interactive := False; // Don't let the user access it
      end;

      with OpExcel1 do begin
         //connect to Excel
         Connected := true;
         WindowState := xlwsNormal;
         Caption     := ShortAppName + ' Report in Microsoft Excel';
         //Add initial workbook and range
         Workbooks.Add;
         ExcelRange := Workbooks[0].Worksheets[0].Ranges.Add;
      end;
      //set current line to top of sheet
      CurrentLineNo := 2;
      //Render Report Header
      RenderPageHeader;
      DetailTopLineNo := CurrentLineNo;
      //Call detail print routine of report that owns this engine
      RenderDetailHeader;
      //*****
      Report.BKPrint;
      //Render Report Fooer
      RenderPageFooter;
      //autosize columns
      {for i := 0 to Pred(Report.Columns.ItemCount) do begin
         with ExcelRange do begin
            Address := ExcelAddress( 0, DetailTopLineNo) + ':' + ExcelAddress( Pred(Report.Columns.ItemCount), CurrentLineNo);
            AsRange.Columns.AutoFit;
         end;
      end;}
      OpExcel1.Workbooks[0].SaveAs(Filename);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.NewDetailLine;
begin
   Report.CurrDetail.Clear;
   Inc( CurrentLineNo);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderDetailHeader;
//Render the column headers for the detail section of the report
var
  i : integer;
  aCol : TReportColumn;
  DoubleLine : boolean;
begin
   with Report do begin
      doubleLine := Columns.TwoLines;
      CurrDetail.Clear;

      {first line}
      for i := 0 to Pred(Columns.ItemCount) do begin
         with ExcelRange do begin
            Address := ExcelAddress( i, CurrentLineNo);
            //format cell
            aCol := Columns.Report_Column_At(i);
            AsRange.NumberFormat := '@';
            AsRange.Font.Bold    := true;
            //set value after formating so that format is not altered
            Value   := aCol.Caption;
         end;
      end;        { for }
      NewDetailLine;

      if DoubleLine then begin
         {second line}
         for i := 0 to Pred(Columns.ItemCount) do begin
            with ExcelRange do begin
               Address := ExcelAddress( i, CurrentLineNo);
               //format cell
               aCol := Columns.Report_Column_At(i);
               AsRange.NumberFormat := '@';
               AsRange.Font.Bold    := true;
               //set value after formating so that format is not altered
               Value   := aCol.CaptionLine2;
            end;
         end;        { for }
         NewDetailLine;
      end;
   end;
   NewDetailLine;  //add a blank line before the detail lines
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderDetailLine;
var
  ColIndex : integer;
  text : String;
  MaxI : integer;
  aCol : TReportColumn;
  ColumnsToSkip : integer;
  ColumnsToSkipStr : string;
  StringValue : string;
begin
  ColumnsToSkip := 0;

  MaxI := Pred(Report.Columns.ItemCount);
  for ColIndex := 0 to MaxI do
  begin
    if ColumnsToSkip > 0 then
    begin
      dec(ColumnsToSkip);
      text := '';
    end
    else if ColIndex <= (Report.CurrDetail.Count -1) then
      text := Report.CurrDetail[ColIndex]
    else
      text := MISSINGFIELD;

    if (FindValueInData(Text, IMGFIELD, StringValue)) then
      Text := '';

    if (FindValueInData(Text, STRFIELD, StringValue)) and
       (FindValueInData(Text, COLSKIPFIELD, ColumnsToSkipStr)) and
       (trystrtoint(ColumnsToSkipStr, ColumnsToSkip)) then
      Text := StringValue;

    ExcelRange.Address := ExcelAddress(ColIndex, CurrentLineNo);
    //format cell
    aCol := Report.Columns.Report_Column_At(ColIndex);

    if Assigned(aCol.CustomFont) then
    begin
      ExcelRange.AsRange.Font.Name := aCol.CustomFont.Name;
      ExcelRange.AsRange.Font.Size := aCol.CustomFont.Size;
    end;

    if FUseTotalFormat and (aCol.TotalFormat <> '' ) then
    begin
      //cell has numeric formatting
      try
         ExcelRange.AsRange.NumberFormat := FixFormat(aCol.TotalFormat);
      except // at least we tried...
      end;
    end
    else
    if aCol.FormatString <> '' then
    begin
      //cell has numeric formatting
      try
         ExcelRange.AsRange.NumberFormat := FixFormat(aCol.FormatString);
      except // at least we tried...
      end;
    end
    else
      ExcelRange.AsRange.NumberFormat := '@';
    //set cell alignment
    {$WARNINGS OFF}
    case aCol.Alignment of
       jtRight   : ExcelRange.AsRange.HorizontalAlignment := xlchaRight;
       jtCenter  : ExcelRange.AsRange.HorizontalAlignment := xlchaCenter;
    end;
     {$WARNINGS ON}
    //enter value
    ExcelRange.Value := text;
    ExcelRange.ColumnWidth := trunc(PAGE_WIDTH * (aCol.WidthPercent/100));
  end;
  NewDetailLine;
end;

procedure TRenderToFileExcel.RenderDetailSubTotal(const TotalName: string;
  NewLine, KeepTotals: Boolean; TotalSubName: string; Style: TStyleTypes);
begin
  FUseTotalFormat := True;
  try
    inherited RenderDetailSubTotal(TotalName, NewLine, KeepTotals, TotalSubName, Style);
  finally
    FUseTotalFormat := False;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderPageHeader;
var
  i, Pos1 : integer;
  ALine : THeaderFooterLine;
  FSize : integer;
begin
   // Document header
   with ExcelRange do
   begin
     Address := 'A'+ inttostr( CurrentLineNo);
     FSize := 10;
     AsRange.Font.Size := FSize;
     AsRange.Font.Bold := true;
     Value := Report.Sections[hf_HeaderAll].GetText;
   end;
   NewDetailLine;
   NewDetailLine;

   for i := 0 to Pred(Report.Header.ItemCount) do begin
      aLine := Report.Header.HFLine_At(i);
      //Images
      Pos1 := Pos(IMGFIELD,aLine.Text);
      if Pos1 = 0 then
      begin
        //ignore images
        if ( aLine.Alignment = jtCenter) then begin
          //only use text that is centered, other text will be for dates and page no's.
           with ExcelRange do begin
              //place in first column
              Address := 'A'+ inttostr( CurrentLineNo);
              if (aLine.FontFactor = 0) then
                FSize := AsRange.Font.Size
              else
                FSize := Round( AsRange.Font.Size * aLine.FontFactor);
              AsRange.Font.Size := FSize;
              AsRange.Font.Bold := true;
              //format cell
              AsRange.NumberFormat := '@';
              Value   := aLine.Text;
           end;
           NewDetailLine;
        end;
      end;
   end;        { for }
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderPageFooter;
var
  i, Pos1 : integer;
  ALine : THeaderFooterLine;
  FSize : integer;
begin
   for i := 0 to Pred(Report.Footer.ItemCount) do
   begin
     aLine := Report.Footer.HFLine_At(i);
     //Page number
     Pos1 := Pos(PAGEFIELD,aLine.Text);
     if (Pos1 > 0) then
       //don't display page numbers
       Continue;

     //Images
     Pos1 := Pos(IMGFIELD,aLine.Text);
     if Pos1 = 0 then
     begin
       //ignore images
       if ( aLine.Alignment = jtCenter) then begin
         //only use text that is centered, other text will be for dates and page no's.
          with ExcelRange do begin
             //place in first column
             Address := 'A'+ inttostr( CurrentLineNo);
             if (aLine.FontFactor = 0) then
               FSize := AsRange.Font.Size
             else
               FSize := Round( AsRange.Font.Size * aLine.FontFactor);
             AsRange.Font.Size := FSize;
             AsRange.Font.Bold := true;
             //format cell
             AsRange.NumberFormat := '@';
             Value   := aLine.Text;
          end;
          NewDetailLine;
       end;
     end;
   end;        { for }
   NewDetailLine;

   // Document footer
   with ExcelRange do
   begin
     Address := 'A'+ inttostr( CurrentLineNo);
     FSize := 10;
     AsRange.Font.Size := FSize;
     AsRange.Font.Bold := true;
     Value := Report.Sections[hf_FooterAll].GetText;
   end;
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderRuledLine;
//rules a line right across
var
  i : integer;
begin
   with Report do begin
      for i := 0 to Pred(Columns.ItemCount) do begin
         with ExcelRange do begin
            Address := ExcelAddress( i, CurrentLineNo);
            AsRange.Borders.Item[ xlEdgeTop].LineStyle := xlContinuous
         end;
      end;
   end;
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderRuledLine(Style : TPenStyle);
//rules a line right across
var
  i : integer;
  NewStyle : XlLineStyle;
  //OldStyle : XlLineStyle;
begin
   with Report do begin
      for i := 0 to Pred(Columns.ItemCount) do begin
         with ExcelRange do begin
            Address := ExcelAddress( i, CurrentLineNo);
            case Style of
              psSolid : NewStyle := xlContinuous;
              psDash : NewStyle := xlDash;
              psDot : NewStyle := xlDot;
              psDashDot : NewStyle := xlDashDot;
              psDashDotDot : NewStyle := xlDashDotDot;
              psClear : NewStyle := xlLineStyleNone;
            else
              NewStyle := xlContinuous;
            end;
            //OldStyle := AsRange.Borders.Item[ xlEdgeTop].LineStyle;
            AsRange.Borders.Item[ xlEdgeTop].LineStyle := NewStyle;
            //AsRange.Borders.Item[ xlEdgeTop].LineStyle := OldStyle;
         end;
      end;
   end;
   NewDetailLine;
end;

procedure TRenderToFileExcel.RenderTextLine(Text: string; Underlined : boolean; AddLineIfUnderlined: boolean);
begin
   with ExcelRange do begin
      Address := 'A'+ inttostr( CurrentLineNo);
      //format cell
      AsRange.NumberFormat := '@';
      if UnderLined then
        AsRange.Font.Underline  := true;
      Value   := Text;
   end;
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderTitleLine(Text: string);
begin
   NewDetailLine;
   with ExcelRange do begin
      Address := 'A'+ inttostr( CurrentLineNo);
      //format cell
      AsRange.NumberFormat := '@';
      AsRange.Font.Bold    := true;
      AsRange.Font.Underline  := true;
      Value   := Text;
   end;
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderTotalLine(double: boolean);
//underline fields for columns which are total columns or average columns
//line can be single or double
var
   i    : integer;
   aCol : TReportColumn;
begin
   if not double then
     NewDetailLine;

   with Report do begin
      for i := 0 to Pred(Columns.ItemCount) do begin
         aCol := Columns.Report_Column_At(i);
         if (aCol.isTotalCol) then begin
            with ExcelRange do begin
               Address := ExcelAddress( i, CurrentLineNo);
 {$WARNINGS OFF}
               if not Double then
                  AsRange.Borders.Item[ xlEdgeTop].LineStyle := xlContinuous
               else
                  AsRange.Borders.Item[ xlEdgeTop].LineStyle := xlDouble;
 {$WARNINGS ON}
            end;
         end;
      end;
   end;

   if double then
     NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileExcel.RenderColumnLine(ColNo: Integer);
var
   i    : integer;
begin
  with Report do
  begin
    if ColNo >= Columns.ItemCount then
      Exit;
    for i := 0 to Pred(Columns.ItemCount) do
    begin
      if (i = ColNo) then
      begin
        with ExcelRange do
        begin
          Address := ExcelAddress( i, CurrentLineNo);
 {$WARNINGS OFF}
          AsRange.Borders.Item[ xlEdgeTop].LineStyle := xlContinuous
 {$WARNINGS ON}
         end;
      end;
    end;
    NewDetailLine;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
