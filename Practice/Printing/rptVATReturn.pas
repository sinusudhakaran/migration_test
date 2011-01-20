unit rptVATReturn;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
  VATReturn,
  NewReportObj,
  Graphics,
  Types,
  classes,
  RepCols,
  UBatchBase,
  ReportToCanvas,
  RptParams,
  ReportTypes,
  ReportDefs,
  MoneyDef,
  NewReportUtils;

type
   TVATReport = class(TBKReport)

   Protected
     CurrYPos,
     CurrLineSize : integer;
     FData : TVAT_Details;
     WasPrinted   : boolean;

     function GetCurrLineSize :integer;
     function ArrowRect(ALeft,ATop,ASize: integer) : TRect;
     function XYSizeRect(ALeft,ATop,ARight,ABottom:integer):TRect;

     procedure RenderText(textValue: string; textRect: TRect; Justify: TJustifyType);
     procedure RenderLine(x, y, width: integer);
     procedure DrawBox(XYRect : TRect);
     procedure RenderAmountLine( BoxNumber : Byte; Title: string; Amount : Money );
     function  RenderTextWrapped(text: string; aRect:TRect) : integer;
     //New line procedure is overloaded so that it can be called with or without parameters
     procedure NewLine; overload;
     procedure NewLine(Count : integer); overload;
     //Type casts the TCustomRenderEngine object to a Canvas Rendering Engine object
     function  GetCanvasRE: TRenderToCanvasEng;


     procedure DrawBlackArrow(canvas: TCanvas; number: integer;
                              Rect: TRect);
     procedure DrawGrayArrow(canvas: TCanvas; number: integer;HasTriangle : boolean; Rect: TRect);
     procedure DrawIRDArrow(Canvas : TCanvas; ArrowRect : TRect; FillColor : TColor;
                            number : integer; numberColor : TColor);
     function makeWidthRect(x, y, width, height: Integer): TRect;
     function RenderWrapText(Canvas: TCanvas; Text: string; Bounds: TRect;
                             Paint: boolean): integer;
     procedure SplitWrapText(Canvas: TCanvas; Text: string; Width: integer;
                             StringList: TStrings);

     property  CanvasRenderEng : TRenderToCanvasEng read GetCanvasRE;
   public
     procedure BKPrint;  override;
   end;


function DoVATReturn( Destination: TReportDest; Data : TVAT_Details; Params : TRptParameters = nil ) : boolean;

//******************************************************************************

implementation
uses
   ReportImages,
   Windows,
   sysutils,
   bkdefs,
   globals,
//   PDDATES32,
   bkDateUtils,
//   stDateSt,
   bkconst,
   VATConst;

{ TVATReport }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TVATReport.DrawIRDArrow(Canvas : TCanvas; ArrowRect : TRect; FillColor : TColor; number : integer; numberColor : TColor);
var
  // p1,p2,p3 : TPoint;
   RenderRect : TRect;
   AWIDTH,
   AHEIGHT,
   TRIMARGIN : integer;
   x,y : integer;
   WasFontColor,
   WasPenColor,
   WasBrushColor : TColor;
   WasFontSize : integer;
begin
   AWidth  := ArrowRect.Right - ArrowRect.Left;
   AHeight := ArrowRect.Bottom - ArrowRect.Top;
   if Not Odd(AHeight) then
      Inc(AHeight);
   TriMargin := AWidth div 6;
   x := ArrowRect.Left;
   y := ArrowRect.Top;

   WasPenColor := Canvas.Pen.Color;
   WasBrushColor := Canvas.Brush.Color;
   WasFontColor := Canvas.Font.Color;
   WasFontSize := Canvas.Font.Size;

   {rectangle and circle}
   Canvas.Pen.Color := clBlack;
   //canvas.Pen.Width := 1;
   Canvas.Brush.Color := FillColor;

   Canvas.Rectangle(x, y, x+AWIDTH,Pred(y+AHEIGHT));

   //Canvas.Ellipse(x+AWIDTH-(AHEIGHT div 2),y,x+AWIDTH+(AHEIGHT div 2), y+AHEIGHT-2 );
   {internal rectangle to blank out half of circle}

   Canvas.pen.color := FillColor;
   Canvas.Rectangle(x+1, y+1, X+AWIDTH, y+AHEIGHT - 2);

   {arrow}
   (*
   if HasTriangle then begin
      p1.x := X+AWIDTH-TriMargin;
      P1.y := Y+TriMargin;
      p2.x := X+AWIDTH+(AHEIGHT div 2)-TriMargin;
      p2.y := Y+(AHEIGHT div 2);
      p3.x := X+AWIDTH-TriMargin;
      p3.y := Y+AHEIGHT-TriMargin-1;

      Canvas.Pen.Color := FillColor;
      Canvas.Brush.Color := clWhite;
      Canvas.Polygon([p1,p2,p3]);
   end;
   *)

   {number}
   Canvas.Font.Height := AHEIGHT-(trimargin*2);
   Canvas.Font.Color  := numberColor;
   Canvas.Brush.color := fillcolor;

   RenderRect.Top := y+trimargin;
   RenderRect.Bottom := y+aheight-trimargin;
   RenderRect.Left := x+trimargin;
   RenderRect.Right := x+awidth-trimargin;
   Canvas.TextRect(RenderRect,RenderRect.Left, RenderRect.top, inttostr(number));

   {restore settings}
   Canvas.Pen.Color := WasPenColor;
   Canvas.Brush.Color := WasBrushColor;
   Canvas.Font.Color := WasFontColor;
   Canvas.Font.Size :=  WasFontSize;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TVATReport.DrawBlackArrow(canvas: TCanvas; number : integer; Rect : TRect);
begin
   DrawIRDArrow(Canvas,Rect,clBlack,number,clwhite);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TVATReport.DrawGrayArrow(canvas: TCanvas; number : integer;HasTriangle : boolean; Rect : TRect);
begin
   DrawIRDArrow(Canvas,Rect,clGray,number,clBlack);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TVATReport.RenderWrapText(Canvas : TCanvas; Text:string; Bounds : TRect; Paint : boolean) : integer;
{wrap text within a specified area, returns the total height of the text}
var
  theString : PChar;
  StrPointer : PChar;
  DisplayString : PChar;
  MaxChars : Integer;
  StringSize : TSize;
  LineNum : integer;
  width : integer;
  TextTop, TextBot : integer;
begin
  width := Bounds.Right - Bounds.Left;
  theString := PChar(Text);
  LineNum := 0;
  TextTop := 0;
  StrPointer := TheString;
  GetMem(DisplayString, Length(theString));
  try
    while (Length(StrPointer)>0) and (TextTop < Bounds.Bottom) do
    begin
      GetTextExtentExPoint(Canvas.handle,TheString,Length(TheString),width,@MaxChars,nil,StringSize);
      while (Length(StrPointer)>MaxChars) and (StrPointer[MaxChars]<>' ') do Inc(MaxChars,-1);
      StrLCopy(DisplayString,StrPointer,MaxChars);
      if length(StrPointer)>MaxChars then
        StrPointer := @Strpointer[MaxChars+1]
      else
        StrPointer := nil;
      GetTextExtentPoint32(Canvas.Handle,DisplayString,Length(DisplayString),StringSize);

      {paint the text}
      TextTop := Bounds.Top+(LineNum*StringSize.cy);
      TextBot := Bounds.Top+((LineNum+1)*StringSize.cy);
      if TextBot > Bounds.Bottom then TextBot := Bounds.Bottom;
      if Paint and (TextTop < Bounds.Bottom) and (TextBot <= Bounds.Bottom) then
          Canvas.TextRect(Rect(Bounds.left,TextTop,Bounds.Right,TextBot),Bounds.Left,TextTop,DisplayString);
      Inc(lineNum)
    end;
  finally
    FreeMem(DisplayString, Length(theString));
    result := LineNum;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TVATReport.SplitWrapText(Canvas : TCanvas; Text:string; Width : integer; StringList: TStrings);
{wrap text within a specified area, returns the total height of the text}
var
  theString : PChar;
  StrPointer : PChar;
  DisplayString : string;
  MaxChars : Integer;
  StringSize : TSize;
  S : string;
begin
  theString := PChar(Text);
  StrPointer := TheString;
  S := StrPointer;

  StringList.Clear;

  while Length(StrPointer)>0 do
  begin
    GetTextExtentExPoint(Canvas.handle,TheString,Length(TheString),Width,@MaxChars,nil,StringSize);
    while (Length(StrPointer)>MaxChars) and (StrPointer[MaxChars]<>' ') do Inc(MaxChars,-1);

    DisplayString := Copy(S,1,MaxChars);
    if length(StrPointer)>MaxChars then
      StrPointer := @Strpointer[MaxChars+1]
    else
      StrPointer := #0;
    S := StrPointer;  {put pchar into string}
    StringList.Add(DisplayString);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TVATReport.makeWidthRect( x, y, width, height : longint) : TRect;
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

function TVATReport.ArrowRect(ALeft,ATop,ASize: integer) : TRect;
begin
   with CanvasRenderEng.OutputBuilder do begin
       result.TopLeft := ConvertToDC( Point( ALeft, ATop));
       result.BottomRight := ConvertToDC( Point( ALeft + ASize, ATop + ASize));
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TVATReport.BKPrint;
var
   myCanvas : TCanvas;
   BaseFontSize : integer;
   S: string;
   X1, X2 : Integer;
begin
   //assume we have a canvas of A4 proportions

   myCanvas     := CanvasRenderEng.OutputBuilder.Canvas;
   //BaseFontSize := UserReportSettings.s7Base_Font_Size;

   BaseFontSize := 8;
   //ReportStyle.Items[siNormal].AssignTo(MyCanvas.Font);
   myCanvas.Font.Name := 'Arial';

   CurrYPos := 250;
   myCanvas.Font.Size := 14;
   myCanvas.Font.Style := [fsbold];
   CurrLineSize := GetCurrLineSize;
   S := 'Value Added Tax Return';
   RenderText(S,Rect( 250, CurrYPos, 850, CurrYPos+CurrLineSize), jtLeft );

   CurrYPos := 400;
   myCanvas.Font.Size := BASEFONTSIZE;
   myCanvas.Font.Style := [fsbold];
   CurrLineSize := GetCurrLineSize;

   {Client details}
   with MyClient.clFields, FData do
   begin
     X1 := 250; X2 := 950;
     RenderText(clName,Rect( X1, CurrYPos, X2, CurrYPos+CurrLineSize ), jtLeft );       NewLine;
     RenderText(clAddress_L1,Rect( X1, CurrYPos, X2, CurrYPos+CurrLineSize),jtLeft); NewLine;
     RenderText(clAddress_L2,Rect( X1, CurrYPos, X2, CurrYPos+CurrLineSize),jtLeft); NewLine;
     RenderText(clAddress_L3,Rect( X1, CurrYPos, X2, CurrYPos+CurrLineSize),jtLeft); NewLine;

     X1 := 1000; X2 := 1300;

     myCanvas.Font.Style := [];
     //Registration and Return details
     CurrYPos := 400;
     RenderText('Registration Number: ',Rect( X1, CurrYPos, X2, CurrYPos+CurrLineSize),jtLeft);
     myCanvas.Font.Style := [fsBold];
     RenderText(clGST_Number,Rect( X2 + 100, CurrYPos, X2 + 500, CurrYPos+CurrLineSize ), jtLeft );
     NewLine;

     myCanvas.Font.Style := [];
     RenderText('For the period:',Rect( X1, CurrYPos, X2, CurrYPos+CurrLineSize ),jtLeft);
     myCanvas.Font.Style := [fsBold];
     S := Date2Str( FData.From_Date, 'dd nnn YYYY' ) + ' to ' + Date2Str( FData.To_Date, 'dd nnn YYYY' );
     RenderText( S,Rect( X2 + 50, CurrYPos, X2 + 600, CurrYPos+CurrLineSize ),jtLeft);
     NewLine;

     CurrYPos := 700;

     RenderAmountLine( 1, SBox1, FData.VAT1 );
     RenderAmountLine( 2, SBox2, FData.VAT2 );
     RenderAmountLine( 3, SBox3, FData.VAT3 );
     RenderAmountLine( 4, SBox4, FData.VAT4 );

     if FData.VAT5 >= 0 then
       RenderAmountLine( 5, SBox5ToPay, FData.VAT5 )
     else
       RenderAmountLine( 5, SBox5Refund, -FData.VAT5 );

     RenderAmountLine( 6, SBox6, FData.VAT6 );
     RenderAmountLine( 7, SBox7, FData.VAT7 );
     RenderAmountLine( 8, SBox8, FData.VAT8 );
     RenderAmountLine( 9, SBox9, FData.VAT9 );

     X1 := 350;
     if FData.HasUnCodes then
       RenderText(SFinalise, Rect( X1, CurrYPos, X2 + 500, CurrYPos+CurrLineSize ), jtLeft);
   end;

   //Was printed is set here so that it will pickup the document being printed
   //even if the user selected preview first, and then selected print from the
   //preview screen
   wasPrinted := (CanvasRenderEng.OutputBuilder.CurrentDestination = 0)//0 = printer; 1 = screen
              or (Self.OriginalDestination = rdFile); //PDF
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TVATReport.DrawBox(XYRect: TRect);
var
  wasColor : TColor;
begin
   with CanvasRenderEng.OutputBuilder.Canvas do
   begin
     wasColor := Brush.Color;
     Brush.Color := clBlack;
     FrameRect(XYRect);
     Brush.Color := wasColor;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TVATReport.GetCurrLineSize: integer;
const
   //line size inflation allows for a gap between each line.  Height of text alone
   //would not give us any spacing
   LINE_SIZE_INFLATION = 1.4;
begin
   result := Round(CanvasRenderEng.OutputBuilder.HeightOfText('A') * LINE_SIZE_INFLATION);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function DoVATReturn( Destination: TReportDest; Data : TVAT_Details; Params : TRptParameters = nil ) : boolean;

//returns true if the report was printed
var
   Job : TVATReport;
begin
   result := false;
   if not assigned( Data ) then exit;
   CreateReportImageList;
   Job := TVATReport.Create( rptGST ); // Dont need that..
   try
     Job.ReportTypeParams.ClearUserHeaderFooter;
     Job.WasPrinted := false;
     Job.LoadReportSettings( UserPrintSettings,Report_List_Names[REPORT_VAT] );
     Job.FData := Data;
     Job.FileFormats := [ffPDF];

     //AddJobFooter(Job, jtLeft,  0.8, Job.ReportTypeParams.GetClientText,False);
     //AddJobFooter(Job, jtRight, 0.8, Job.ReportTypeParams.GetPrintedText, True);
     AddCommonFooter(Job);
     if Destination in [rdScreen, rdPrinter, rdFile] then
        Job.Generate(Destination, Params);
     if Assigned(Params) then
     if Params.BatchRunMode = R_Batch then
        Job.WasPrinted := true;
     result := Job.WasPrinted;
   finally
    Job.Free;
    DestroyReportImageList;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TVATReport.NewLine;
begin
   CurrYPos := CurrYPos + CurrLineSize;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TVATReport.NewLine(Count: integer);
begin
   CurrYPos := CurrYPos + CurrLineSize *  Count;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TVATReport.RenderText(textValue: string; textRect: TRect; Justify: TJustifyType);
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

   with CanvasRenderEng.OutputBuilder do
   begin
       TextWidth := Canvas.TextWidth(textValue);
       TextHeight := Canvas.TextHeight(textValue) * 12 div 10;

       {convert from 0.1mm to pixels}
       with TextRect do begin
          TopLeft     := ConvertToDC( TopLeft);
          BottomRight := ConvertToDC( BottomRight);
       end;        { with }

       {first sort out top and bottom}
       if TextHeight >= (textRect.Bottom - textRect.Top) then begin
          //Height of text is bigger than box so use top
          RenderRect.Top := textRect.Top;
          RenderRect.Bottom := textRect.Bottom;
       end
       else begin
          RenderRect.Top := textRect.Top + ((textRect.Bottom - textRect.top) - TextHeight);
          RenderRect.Bottom := textRect.Bottom;
       end;

       {now sortout left right}
       if TextWidth >= (textRect.Right - textRect.Left) then  begin
          //width is greater than box so use left
          RenderRect.Left := textRect.Left;
          RenderRect.Right  := textRect.Right;
       end
       else begin
          case Ord(Justify) of
             Ord(jtLeft): begin
                RenderRect.left := textRect.Left;
                RenderRect.Right := RenderRect.Left + textwidth;
             end;
             ord(jtCenter): begin
                RenderRect.Left := textRect.Left + (textRect.Right - textRect.Left) div 2 - textwidth div 2;
                RenderRect.Right := RenderRect.Left + textwidth;
             end;
             ord(jtRight): begin
                RenderRect.Right := textRect.Right;
                RenderRect.Left := RenderRect.Right - textWidth;
             end;
          end;        { case }
       end;             { begin}

       {Store Current Brush Color}
       wasColor := Canvas.Brush.Color;
       wasFColor := Canvas.Font.Color;

       Canvas.TextRect(RenderRect,RenderRect.Left, RenderRect.top, textValue);
       Canvas.Brush.Color := wasColor;
       Canvas.Font.Color  := wasFColor;
   end;        { with }
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TVATReport.RenderAmountLine( BoxNumber : Byte; Title: string; Amount : Money );
Const
  XL = 400;
  XR = 1300;
var
  WrappedLines : integer;
  procedure DrawBox(ARect: TRect);
  begin
     with CanvasRenderEng.OutputBuilder.Canvas, ARect do begin
       MoveTo(Left,  Top);
       LineTo(Right, Top);
       LineTo(Right, Bottom);
       LineTo(Left,  Bottom);
       LineTo(Left, Top);
     end;
  end;
begin
  if ( BoxNumber in [ 3, 5 ] ) then
     CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsBold]
  else
     CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];

   WrappedLines := RenderTextWrapped( Title,Rect(XL, CurrYPos, XR, CurrYPos+CurrLineSize ) );

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsBold];

   DrawBlackArrow( CanvasRenderEng.OutputBuilder.Canvas, BoxNumber, ArrowRect( XR + 10, CurrYPos, CurrLineSize div 10 * 9 ) );

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];

   RenderText( FormatFloat( '£#,##0.00;-£#,##0.00', Amount/100.0 ), Rect( XR + 100, CurrYPos, XR + 400, CurrYPos+CurrLineSize ), jtRight);

   DrawBox(XYSizeRect(XL-50,CurrYPos-10,XR+ 450,  CurrYPos + WrappedLines * CurrLineSize + 10));

   NewLine( WrappedLines + 1 );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TVATReport.RenderTextWrapped(text: string; aRect:TRect) : integer;
var
   SList : TStringList;
   i: integer;
   SizeRect : TRect;
begin
   SList := TStringList.Create;
   try
     {split into individual lines, not split takes pixel measurements}
     SizeRect := XYSizeRect(aRect.left,aRect.top,aRect.Right,aRect.bottom);
     SplitWrapText(CanvasRenderEng.OutputBuilder.Canvas,text,SizeRect.Right - SizeRect.Left,SList);

     {now render each line}
     for i:= 0 to SList.Count -1 do
     begin
        RenderText(SList.Strings[i],Rect(aRect.Left,CurrYPos,aRect.Right,CurrYPos+((i+1)*CurrLineSize)),jtLeft);
     end;
     result := SList.Count;
   finally
     SList.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TVATReport.RenderLine(x, y, width: integer);
begin
   with CanvasRenderEng.OutputBuilder do begin
      Canvas.Polyline([ ConvertToDC( Point(x,y)),ConvertToDC( Point(x+width,y))]);
   end;        { with }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TVATReport.XYSizeRect(ALeft, ATop, ARight,
  ABottom: integer): TRect;
//returns are rect in device coordinates ( pixels). Expects to be passed coords
//in 0.1 mm units
begin
   with CanvasRenderEng.OutputBuilder do begin
       result.TopLeft := ConvertToDC( Point( ALeft, ATop));
       result.BottomRight := ConvertToDC( Point( ARight, ABottom));
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TVATReport.GetCanvasRE: TRenderToCanvasEng;
begin
   result := TRenderToCanvasEng( RenderEngine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

