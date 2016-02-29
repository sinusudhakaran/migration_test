unit ReportToFile;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:  Report Rendering Engine for Text File Output

  Written: Dec 1999
  Authors: Matthew

  Purpose: Generates report output to a text file

  Notes:   The user will be asked

     TRenderToFileBase class contains routines that will be common for output
     in any file format.  The Render_xxx_total routines all build a line which
     is then passed to the RenderDetailLine routine.

     TRenderToFileBase is not intended to be used directly and should be
     decended from.  The decendant MUST implement the RenderDetailLine routine.

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface

uses

   ReportTypes,
   Graphics,
   RenderEngineObj,
   NewReportObj,
   Classes;

type
   TMethodPointer = procedure ( Sender : TObject) of object;

type
  TRenderToFileBase = class( TCustomRenderEngine)
  protected
      FOnAfterGenerate: TMethodPointer;
      FOutputFile : TextFile;
      FOutputFileName : string;
      FileCreatedOK : boolean;
      FOnBeforeGen: TMethodPointer;
      procedure SetOnAfterGenerate(const Value: TMethodPointer);
      function  GetReportOwner : TBKReport;
      procedure NewDetailLine; virtual;
      procedure RenderTotalLine(double: boolean); virtual; abstract;
   public
      constructor Create( aOwner : TObject; fName : string); reintroduce; virtual;
      //Routines to build total and header lines, they call RenderDetailLine
      procedure RenderEmptyLine;                  override;
      procedure RenderDetailHeader;               override;
      procedure RenderDetailSubSectionTotal(const TotalName : string);      override;
      procedure RenderDetailSectionTotal(const TotalName : string);         override;
      procedure RenderDetailSubTotal(const TotalName : string; NewLine: Boolean = True;
        KeepTotals: Boolean = False; TotalSubName: string = ''; Style: TStyleTypes = siSectionTotal); override;
      procedure RenderDetailGrandTotal(const TotalName : string);           override;
      procedure RenderDetailRunningTotal(const TotalName : string);         override;
      //Common routines, UnderLine routines call RenderTotalLine;
      procedure SingleUnderLine;                  override;
      procedure DoubleUnderLine;                  override;
      procedure ReportNewPage;                    override;
      procedure RequireLines(lines :integer);     override;
      function  RenderColumnWidth(ColumnID: Integer; Text : String): Integer; override;
      procedure UseCustomFont( aFontname : string; aFontSize : integer; aFontStyle : TFontStyles; aLineSize : integer); override;
      procedure UseDefaultFont; override;

      procedure Generate;                         override;

      procedure SplitText(const Text: String; ColumnWidth: Integer; var WrappedText: TWrappedText); override;
      
      property  Report : TBKReport read GetReportOwner;
      property  OnBeforeGenerate : TMethodPointer read FOnBeforeGen write FOnBeforeGen;
      property  OnAfterGenerate : TMethodPointer read FOnAfterGenerate write SetOnAfterGenerate;
   end;

type
   TRenderToFileCSV = class( TRenderToFileBase)
   protected
      procedure RenderTotalLine(double: boolean); override;
   public
      procedure RenderDetailLine;                 override;
      procedure RenderTitleLine(Text : string);   override;
      procedure RenderTextLine(Text:string; Underlined : boolean; AddLineIfUnderlined: boolean = True);      override;
      procedure RenderRuledLine;                  overload; override;
      procedure RenderRuledLine(Style : TPenStyle);                  overload; override;
      procedure RenderColumnLine(ColNo: Integer); overload; override;
   end;




   TRenderToFileFixed = class( TRenderToFileBase)
   protected
      procedure RenderTotalLine(double: boolean); override;
      procedure CalculateColWidths( Sender : TObject);

      procedure RenderDetailHeaderWrapped; virtual;
   public
      MaxLineWidth : integer;
      constructor Create( aOwner : TObject; fName : string); override;

      procedure RenderDetailHeader; override;
      procedure RenderDetailLine;                 override;
      procedure RenderTitleLine(Text : string);   override;
      procedure RenderTextLine(Text:string; Underlined : boolean; AddLineIfUnderlined: boolean = True);      override;
      procedure RenderRuledLine;                  overload; override;
      procedure RenderRuledLine(Style : TPenStyle);                  overload; override;
      procedure RenderColumnLine(ColNo: Integer); overload; override;
   end;

//******************************************************************************
implementation
uses
   Math,
   RepCols,
   SysUtils,
   SignUtils;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TRenderToFileBase }
constructor TRenderToFileBase.Create(aOwner: TObject; fName : string);
begin
   inherited Create( aOwner);
   FOutputFileName := fName;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.Generate;
begin
   //Create file
   AssignFile( FOutputFile, FOutputFileName);
   Rewrite( FOutputFile);
   try
      //Call any initialisation routines
      if Assigned( FOnBeforeGen) then
         FOnBeforeGen( Self);
      //Call detail print routine of report that owns this engine
      RenderDetailHeader;
      Report.ClearAllTotals;
      Report.BKPrint;
   finally
      //Close file
      CloseFile( FOutputFile);
      if Assigned( FOnAfterGenerate) then
         FOnAfterGenerate( Self);
   end;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToFileBase.GetReportOwner: TBKReport;
begin
   result := TBKReport(Owner);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.NewDetailLine;
begin
   Report.CurrDetail.Clear;
   Writeln(FOutputFile);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.RenderDetailGrandTotal(const TotalName : string);
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  AmountS : String;
  Value,Quantity,Average : currency;
begin
  RenderTotalLine(false);
  with Report do begin
    for i := 0 to Pred(Columns.ItemCount) do begin
       AmountS := '';
       aCol := Columns.Report_Column_At(i);
       if aCol.isTotalCol then begin
          if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                   else FormatS := aCol.TotalFormat;
          AmountS := FormatFloat(FormatS,aCol.GrandTotal);
       end;
       {averaging cols}
       if (aCol.IsAverageCol) and (aCol.IsTotalCol) then begin
           if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                    else FormatS := aCol.TotalFormat;
           Value    := aCol.ColValue.GrandTotal;
           Quantity := aCol.ColQuantity.GrandTotal;
           if Quantity <> 0.0 then
              Average := Value / Quantity
           else
              Average := 0;
           Average := SetSign_Curr( Average, SignOf( Quantity));
           AmountS := FormatFloat(FormatS,Average);
       end else if Acol.IsPercentageCol then begin
          AmountS := FormatPercentString(aCol.GrandTotal,aCol);
       end;
       //Skip column if nothing to show
       if not( aCol.IsTotalCol or aCol.IsAverageCol) then begin
          if ( i = 0) then
            AmountS := TotalName;
       end;
       if (AmountS = '') then
         SkipColumn
       else
         CurrDetail.Add(AmountS);
    end;
    RenderDetailLine;
    RenderTotalLine(true);
    {reset totals}
    ClearGrandTotals;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.RenderDetailHeader;
//Render the column headers for the detail section of the report
var
  i : integer;
  aCol : TReportColumn;
  DoubleLine : boolean;
begin
   with Report do begin
      doubleLine := Columns.TwoLines;
      CurrDetail.Clear;

      {firstline}
      for i := 0 to Pred(Columns.ItemCount) do begin
         aCol := Columns.Report_Column_At(i);
         CurrDetail.Add( aCol.Caption );
      end;        { for }
      RenderDetailLine;

      if DoubleLine then begin
         {second line}
         for i := 0 to Pred(Columns.ItemCount) do  begin
            aCol := Columns.Report_Column_At(i);
            CurrDetail.Add( aCol.CaptionLine2 );
         end;        { for }
         RenderDetailLine;
      end;
   end;
   NewDetailLine;  //add a blank line before the detail lines
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.RenderDetailSubSectionTotal(
  const TotalName: string);
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  AmountS : String;
  Value, Quantity, Average : currency;
begin
  NewDetailLine;
  RenderTotalLine(false);
  with Report do begin
    for i := 0 to Pred(Columns.ItemCount)  do begin
       AmountS := '';
       aCol := Columns.Report_Column_At(i);
       if aCol.isTotalCol then begin
          if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                   else FormatS := aCol.TotalFormat;
          AmountS := FormatFloat(FormatS,aCol.SubSectionTotal);
       end;

       {averaging cols}
       if (aCol.IsAverageCol) and (aCol.IsTotalCol) then begin
          if aCol.TotalFormat = '' then FormatS := aCol.FormatString
             else FormatS := aCol.TotalFormat;
          Value    := aCol.ColValue.SubSectionTotal;
          Quantity := aCol.ColQuantity.SubSectionTotal;
          if Quantity <> 0.0 then
             Average := Value / Quantity
          else
             Average := 0;
          AmountS := FormatFloat(FormatS,Average);
       end else if Acol.IsPercentageCol then begin
          AmountS := FormatPercentString(aCol.SubSectionTotal, aCol);
       end;


       //Skip column if nothing to show
       if not( aCol.IsTotalCol or aCol.IsAverageCol) then begin
          if ( i = 0) then
            AmountS := TotalName;
       end;
       if (AmountS = '') then
         SkipColumn
       else
         CurrDetail.Add(AmountS);
    end;
              { for }
    RenderDetailLine;
    NewDetailLine;

    {reset SectionTotals}
    ClearSubSectionTotal;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.RenderDetailSectionTotal(const TotalName : string);
var
  i : integer;
  aCol : TReportColumn;
  FormatS : string;
  AmountS : String;
  Value, Quantity, Average : currency;
begin
  NewDetailLine;
  RenderTotalLine(false);
  with Report do begin
    for i := 0 to Pred(Columns.ItemCount)  do begin
       AmountS := '';
       aCol := Columns.Report_Column_At(i);
       if aCol.isTotalCol then begin
          if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                   else FormatS := aCol.TotalFormat;
          AmountS := FormatFloat(FormatS,aCol.SectionTotal);
       end;

       {averaging cols}
       if (aCol.IsAverageCol) and (aCol.IsTotalCol) then begin
          if aCol.TotalFormat = '' then FormatS := aCol.FormatString
             else FormatS := aCol.TotalFormat;
          Value    := aCol.ColValue.SectionTotal;
          Quantity := aCol.ColQuantity.SectionTotal;
          if Quantity <> 0.0 then
             Average := Value / Quantity
          else
             Average := 0;
          AmountS := FormatFloat(FormatS,Average);
       end else if Acol.IsPercentageCol then begin
          AmountS := FormatPercentString(aCol.SectionTotal,aCol);
       end;

       //Skip column if nothing to show
       if not( aCol.IsTotalCol or aCol.IsAverageCol) then begin
          if ( i = 0) then
            AmountS := TotalName;
       end;
       if (AmountS = '') then
         SkipColumn
       else
         CurrDetail.Add(AmountS);
    end;
              { for }
    RenderDetailLine;
    NewDetailLine;

    {reset SectionTotals}
    ClearSectionTotal;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.RenderDetailSubTotal(const TotalName : string; NewLine: Boolean = True;
  KeepTotals: Boolean = False; TotalSubName: string = ''; Style: TStyleTypes = siSectionTotal);
var
   i : integer;
   aCol : TReportColumn;
   FormatS : string;
   AmountS : String;
   Value, Quantity, Average : currency;
begin
   RenderTotalLine(false);
   with Report do begin
      for i := 0 to Pred(Columns.ItemCount)do begin
         AmountS := '';
         aCol := Columns.Report_Column_At(i);
         if aCol.isTotalCol then begin
            if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                     else FormatS := aCol.TotalFormat;
            AmountS := FormatFloat(FormatS,aCol.subTotal);
         end;
         {averaging cols}
         if (aCol.IsAverageCol) and (aCol.IsTotalCol) then begin
            if aCol.TotalFormat = '' then FormatS := aCol.FormatString
               else FormatS := aCol.TotalFormat;
            Value    := aCol.ColValue.SubTotal;
            Quantity := aCol.ColQuantity.SubTotal;
            if Quantity <> 0.0 then
               Average := Value / Quantity
            else
               Average := 0;
           Average := SetSign_Curr( Average, SignOf( Quantity));
           AmountS := FormatFloat(FormatS,Average);
         end else if Acol.IsPercentageCol then begin
            AmountS := FormatPercentString(aCol.subTotal,aCol);
         end;
         //Skip column if nothing to show
         if not( aCol.IsTotalCol or aCol.IsAverageCol) then begin
            if ( i = 0) then
              AmountS := TotalName;
         end;
         if (AmountS = '') then
           SkipColumn
         else
           CurrDetail.Add(AmountS);
      end;
      RenderDetailLine;
      if NewLine then
        NewDetailLine;
      {reset subtotals}
      if not KeepTotals then
        ClearSubTotals;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.RenderEmptyLine;
begin
  inherited;
  NewDetailLine();
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.RenderDetailRunningTotal(const TotalName : string);
var
   i : integer;
   aCol : TReportColumn;
   FormatS : string;
   AmountS : String;
   Value, Quantity, Average : currency;
begin
   RenderTotalLine(false);
   with Report do begin
      for i := 0 to Pred(Columns.ItemCount)do begin
         AmountS := '';
         aCol := Columns.Report_Column_At(i);
         if aCol.isTotalCol then begin
            if aCol.TotalFormat = '' then FormatS := aCol.FormatString
                                     else FormatS := aCol.TotalFormat;
            AmountS := FormatFloat(FormatS,aCol.RunningTotal);
         end;
         {averaging cols}
         if (aCol.IsAverageCol) and (aCol.IsTotalCol) then begin
            if aCol.TotalFormat = '' then FormatS := aCol.FormatString
               else FormatS := aCol.TotalFormat;
            Value    := aCol.ColValue.RunningTotal;
            Quantity := aCol.ColQuantity.RunningTotal;
            if Quantity <> 0.0 then
               Average := Value / Quantity
            else
               Average := 0;
           AmountS := FormatFloat(FormatS,Average);
         end else if Acol.IsPercentageCol then begin
            AmountS := FormatPercentString(aCol.RunningTotal,aCol);
         end;
         //Skip column if nothing to show
         if not( aCol.IsTotalCol or aCol.IsAverageCol) then begin
            if ( i = 0) then
              AmountS := TotalName;
         end;
         if (AmountS = '') then
           SkipColumn
         else
           CurrDetail.Add(AmountS);
      end;
      RenderDetailLine;
      NewDetailLine;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.ReportNewPage;
begin
   //Do nothing as page breaks mean nothing in context of a file
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.SetOnAfterGenerate(const Value: TMethodPointer);
begin
  FOnAfterGenerate := Value;
end;

procedure TRenderToFileBase.SingleUnderLine;
begin
   //draw a single line under each columns that is a total col
   RenderTotalLine( false);
end;

procedure TRenderToFileBase.SplitText(const Text: String; ColumnWidth: Integer; var WrappedText: TWrappedText);

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

    PrintableWidth := ColumnWidth;

    MoreWords := Words.Count > 0;

    Index := 0;
    
    while MoreWords do
    begin             
      Line := Trim(Line + ' ' + Words[Index]);

      if Index < Words.Count -1 then
      begin
        TextLength := Length(Trim(Line + ' ' + Words[Index + 1]));

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

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.DoubleUnderLine;
begin
   //draw a double line under each columns that is a total col
   RenderTotalLine( true);
end;
//******************************************************************************
procedure TRenderToFileBase.RequireLines(lines: integer);
begin
   //Do nothing... not relevant to files
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TRenderToFileBase.RenderColumnWidth(ColumnID: Integer; Text : String): Integer;
begin
  Result := Length(Text);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileBase.UseCustomFont(aFontname: string; aFontSize: integer; aFontStyle: TFontStyles; aLineSize : integer);
begin
  //do nothing
end;

procedure TRenderToFileBase.UseDefaultFont;
begin
  //do nothing
end;

{ TRenderToFileCSV }
procedure TRenderToFileCSV.RenderDetailLine;
const
   Delimiter = ',';
var
   i :integer;
   text : String;
   MaxI : integer;
begin
   with Report do begin
      MaxI := Pred(Columns.ItemCount);
      for i := 0 to MaxI do begin
         if i <= (CurrDetail.Count -1) then
            text := CurrDetail[i]
         else
            text := MISSINGFIELD;
         //check doesnt contain delimiter
         if pos(delimiter, text) > 0 then
            text := '"'+text+'"';
         //add a comma unless this is the last col
         if i < MaxI then
            Text := Text + Delimiter;

         Write( FOutputFile, Text);
      end;
   end;
   NewDetailLine;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileCSV.RenderRuledLine;
begin
   //draw a single line the width of the page
   Write( FoutputFile, '___________________________________________________');
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileCSV.RenderRuledLine(Style : TPenStyle);
var
  Pattern : String;
  i, Len : Integer;
  Line : String;
begin
   //draw a single line the width of the page
   case Style of
     psSolid : Pattern := '_';
     psDash : Pattern := '_ ';
     psDot : Pattern := '. ';
     psDashDot : Pattern := '-.';
     psDashDotDot : Pattern := '-..';
     psClear : Pattern := ' ';
   else
     Pattern := '_';
   end;

   Line := Pattern;
   Len := Length(Line);
   i := Len;
   while (i < 52) do
   begin
     Line := Line + Pattern;
     i := i + Len;
   end;
   Write( FoutputFile, Line);
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileCSV.RenderTextLine(Text: string; Underlined : boolean; AddLineIfUnderlined: boolean);
begin
   //draw text
   Write( FOutputFile, Text);
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileCSV.RenderTitleLine(Text: string);
begin
   //draw the text underlined, leave blank line above and below
   NewDetailLine;
   Write( FOutputFile, Text);
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileCSV.RenderTotalLine( double : boolean);
//underline fields for columns which are total columns or average columns
//line can be single or double
var
   i : integer;
   aCol : TReportColumn;
begin
   // We actualy dont want this as a line..
   Report.CurrDetail.Clear;
   with Report do
      for i := 0 to Pred(Columns.ItemCount) do begin
         aCol := Columns.Report_Column_At(i);
         if (aCol.isTotalCol) then begin
            if not double then
               CurrDetail.Add('----------')
            else
               CurrDetail.Add('==========');
         end
         else
            SkipColumn;
      end;
   RenderDetailLine;
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TRenderToFileCSV.RenderColumnLine(ColNo: Integer);
var
   i : integer;
begin
  with Report do
  begin
    CurrDetail.Clear;
    if ColNo >= Columns.ItemCount then
      Exit;
    for i := 0 to Pred(Columns.ItemCount) do begin
       if (i = ColNo) then begin
         CurrDetail.Add('----------')
       end
       else
          SkipColumn;
    end;
    RenderDetailLine;
    NewDetailLine;
  end;
end;
//******************************************************************************
{ TRenderToFileFixed }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileFixed.CalculateColWidths( Sender : TObject);
//Calculates the column width in characters for each col given the MaxLineWidthv
var
   i : integer;
   WidthAvailable : integer;
   aCol : TReportColumn;
begin
   with Report do begin
      //First subtract one char for each col.  This ensures a space between each col
      WidthAvailable := MaxLineWidth - Columns.ItemCount;
      //Calculate width for each col
      for i := 0 to Pred(Columns.ItemCount) do begin
         aCol := Columns.Report_Column_At(i);
         aCol.Width := Max(8,Round( WidthAvailable * aCol.WidthPercent/100));
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TRenderToFileFixed.Create(aOwner: TObject; fName: string);
begin
   inherited Create( aOwner, fName);
   OnBeforeGenerate := CalculateColWidths;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileFixed.RenderDetailHeader;
begin
  with Report do
  begin
    if Columns.WrapCaptions then
    begin
      RenderDetailHeaderWrapped;
    end
    else
    begin
      inherited;
    end;
  end;
end;

procedure TRenderToFileFixed.RenderDetailHeaderWrapped;

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
  with Report do
  begin
    {Wrap the lines}
    SetLength(WrappedCaptions, Columns.ItemCount);

    for ColumnIndex := 0 to Columns.ItemCount - 1 do
    begin
      Column := Columns.Report_Column_At(ColumnIndex);

      SplitText(Column.Caption, Column.Width, WrappedCaptions[ColumnIndex]);
    end;

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

            CurrDetail.Add(ColumnText); 
          end
          else
          begin
            CurrDetail.Add('');
          end;
        finally
          Style.Free;
        end;
      end;

      RenderDetailLine;
    end;

    NewDetailLine;
  end;
end;

procedure TRenderToFileFixed.RenderDetailLine;
var
   i :integer;
   text : String;
   MaxI : integer;
   ColWidth : integer;
   aCol : TReportColumn;
begin
   with Report do begin
      MaxI := Pred(Columns.ItemCount);
      for i := 0 to MaxI do begin
         //Read col width in characters from col obj
         aCol := Columns.Report_Column_At(i);
         ColWidth := aCol.Width;

         if i <= (CurrDetail.Count -1) then
            text := CurrDetail[i]
         else
            text := MISSINGFIELD;
         //make the text field the correct length
         while Length( Text) < ColWidth do begin
            if aCol.Alignment = jtLeft then
               Text := Text + ' '
            else
               Text := ' '+Text;
         end;
         //Trim field in case too big
         if aCol.Alignment = jtLeft then
            Text := Copy( Text, 1, ColWidth)
         else
            Text := Copy( Text, Succ(Length(Text) - ColWidth), ColWidth);
         //Write out this column plus 1 char seperator
         Write( FOutputFile, Text, ' ');
      end;
   end;
   NewDetailLine;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileFixed.RenderRuledLine;
var
   Line : string;
   i    : integer;
begin
   Line := '';
   for i := 1 to MaxLineWidth do
      Line := Line + '_';
   Write( FOutputFile, Line);
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileFixed.RenderRuledLine(Style : TPenStyle);
var
  Pattern, Line : string;
  i, Len : integer;
begin
   case Style of
     psSolid : Pattern := '_';
     psDash : Pattern := '_ ';
     psDot : Pattern := '. ';
     psDashDot : Pattern := '-.';
     psDashDotDot : Pattern := '-..';
     psClear : Pattern := ' ';
   else
     Pattern := '_';
   end;

   Line := Pattern;
   Len := Length(Line);
   i := Len;
   while (i < MaxLineWidth) do
   begin
     Line := Line + Pattern;
     i := i + Len;
   end;
   Write( FOutputFile, Line);
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileFixed.RenderTextLine(Text: string; Underlined : boolean; AddLineIfUnderlined: boolean);
begin
   //draw text
   Write( FOutputFile, Copy( Text, 1, MaxLineWidth));
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileFixed.RenderTitleLine(Text: string);
begin
   //draw text
   NewDetailLine;
   Write( FOutputFile, Copy( Text, 1, MaxLineWidth));
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileFixed.RenderTotalLine(double: boolean);
//underline fields for columns which are total columns or average columns
//line can be single or double
var
   i,j  : integer;
   aCol : TReportColumn;
   Line : string;
   LineChar : char;
begin
   //Select which character will make up the line
   if not double then
      LineChar := '-'
   else
      LineChar := '=';
   Report.CurrDetail.Clear;
   with Report do
      for i := 0 to Pred(Columns.ItemCount) do begin
         aCol := Columns.Report_Column_At(i);
         if (aCol.isTotalCol) then begin
            Line := '';
            for j := 1 to aCol.Width do
               Line := Line + LineChar;
            CurrDetail.Add(Line);
         end
         else
            SkipColumn;
      end;
   RenderDetailLine;
   NewDetailLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TRenderToFileFixed.RenderColumnLine(ColNo: Integer);
var
   i,j  : integer;
   aCol : TReportColumn;
   Line : string;
   LineChar : char;
begin
  with Report do
  begin
    if ColNo >= Columns.ItemCount then
      Exit;
    Report.CurrDetail.Clear;
    LineChar := '-';
    for i := 0 to Pred(Columns.ItemCount) do
    begin
      aCol := Columns.Report_Column_At(i);
      if (i = ColNo) then
      begin
        Line := '';
        for j := 1 to aCol.Width do
          Line := Line + LineChar;
        CurrDetail.Add(Line);
      end
      else
        SkipColumn;
    end;
    RenderDetailLine;
    NewDetailLine;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
