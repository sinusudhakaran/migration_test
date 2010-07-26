unit rptGST101;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   GST 101 Report

  Written:
  Authors: Matthew

  Purpose: Prints the GST 101 form.

  Notes:   The GST 101 report work quite differently to other reports in that it
           prints directly to the canvas of the current document, rather than using
           the normal Render routines of the Rendering Engine.  This means that it
           can only be sent to the printer.

           The main reason for printing directly to that canvas it because this
           report has a very different structure to all of the other reports, which
           are columnar reports.

           A number of helper routines have been added to allow rendering of the
           IRD arrow and for wrapping text in boxes.

           The reason the normal BK Report object is used is because this handles
           all of the report settings and printer selection.  An alternative
           would have been to decend the GST101Report object directly from the
           TBKPrintController object.
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
   GSTWorkRec,
   NewReportObj,
   Graphics,
   Types,
   classes,
   RepCols,
   UBatchBase,
   ReportToCanvas,
   gst101frm,
   RptParams,
   ReportTypes,
   ReportDefs,
   NewReportUtils;


type
   TGST101Report = class(TBKReport)

   Protected
     CurrYPos,
     CurrLineSize: integer;
     GSTForm: TfrmGST101;
     WasPrinted: boolean;

     function GetCurrLineSize :integer;
     function MakeArrowRect(ALeft,ATop,ASize: integer; Long: Boolean = false) : TRect;
     function XYSizeRect(ALeft,ATop,ARight,ABottom:integer):TRect;

     procedure RenderText(textValue: string; textRect: TRect; Justify: TJustifyType);
     procedure RenderLine(x, y, width: integer);
     procedure DrawBox(XYRect : TRect);
     procedure RenderAmountLine(Title: string; isBold, isBlack, islong: boolean; ID:string; Value: Double);
     procedure RenderUnderline;
     function  RenderTextWrapped(text: string; aRect:TRect) : integer;
     //New line procedure is overloaded so that it can be called with or without parameters
     procedure NewLine; overload;
     procedure NewLine(Count : integer); overload;
     //Type casts the TCustomRenderEngine object to a Canvas Rendering Engine object
     function  GetCanvasRE: TRenderToCanvasEng;


     Procedure DrawRadio(Canvas : TCanvas; aRect : TRect; Caption : string; Left,Checked : boolean);

     procedure DrawBlackArrow(Canvas: TCanvas;
                              ID: string;
                              Rect: TRect);

     procedure DrawGrayArrow(Canvas: TCanvas;
                             ID: string;
                             HasTriangle: boolean;
                             Rect: TRect);

     procedure DrawIRDArrow(Canvas: TCanvas;
                            ArrowRect: TRect;
                            FillColor: TColor;
                            HasTriangle: Boolean;
                            ID: string;
                            numberColor: TColor);

     function makeWidthRect(x, y, width, height: Integer): TRect;
     function RenderWrapText(Canvas: TCanvas; Text: string; Bounds: TRect;
                             Paint: boolean): integer;
     procedure SplitWrapText(Canvas: TCanvas; Text: string; Width: integer;
                             StringList: TStrings);

     property  CanvasRenderEng : TRenderToCanvasEng read GetCanvasRE;
   public
     constructor Create (RptType: TReportType); override;
     procedure BKPrint;  override;
   end;


   function DoGST101Report( Destination: TReportDest;
                            ForGSTForm: TfrmGST101;
                            Params: TRptParameters = nil ): boolean;

//******************************************************************************
implementation
uses
   ReportImages,
   Windows,
   sysutils,
   bkdefs,
   globals,
   PDDATES32,
   bkDateUtils,
   stDateSt,
   bkconst,
   moneyDef;


{ TGST101Report }
const
   {columns specs in 0.1mm ie. 10=1mm}
   Col0                 = 100;
   ColBoxLeft           = Col0;
   ColLeftText          = ColBoxLeft         + 20;
   ColLeftTextRight     = ColLeftText        + 400;
   ColOfficeBoxLeft     = ColLeftText;
   ColOfficeBoxRight    = ColOfficeBoxLeft   + 450;
   ColCenterTextLeft    = ColBoxLeft         + 600;
   ColCenterTextRight   = ColCenterTextLeft  + 650;
   ColArrowLeft         = ColCenterTextRight + 50;
   ColAmountsRight      = ColCenterTextLeft  + 1200;
   ColBoxRight          = ColAmountsRight    + 30;
   ColRegBoxLeft        = Col0               + 800;
   ColRegBoxRight       = ColBoxRight;
   ColRegText1          = ColRegBoxLeft      + 30;
   ColRegText2          = ColRegBoxLeft      + 240;
   ColRegArrowLeft      = ColRegBoxLeft      + 550;
   ColRegText3          = ColRegBoxLeft      + 700;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.DrawRadio(Canvas : TCanvas; aRect : TRect; Caption : string; Left,Checked : boolean);
var
  Width, Height : integer;
  wasBrush : TColor;
  margin,tw,th : integer;
begin
  Width := aRect.Right - aRect.Left;
  Height := aRect.Bottom - aRect.Top;
  Margin := Height div 10 * 3;

  {draw outside circle}
  wasBrush := Canvas.Brush.color;
  Canvas.Brush.Color := clWhite;
  if left then
    Canvas.Ellipse(aRect.Left,aRect.Top,aRect.Left + Height,aRect.Bottom)
  else
    Canvas.Ellipse(aRect.Right-Height,aRect.Top,aRect.Right,aRect.Bottom);

  {draw inside circle}
  if checked then
  begin
    Canvas.Brush.Color := clBlack;
    if left then
    Canvas.Ellipse((aRect.Left)+(margin div 2),
                    aRect.Top+(margin div 2),
                    aRect.Left + Height-(margin div 2),
                    aRect.Bottom-(margin div 2))
    else
    Canvas.Ellipse((aRect.Right-Height)+(margin div 2),
                    aRect.Top+(margin div 2),
                    aRect.Right-(margin div 2),
                    aRect.Bottom-(margin div 2));

  end;
  Canvas.Brush.Color := wasBrush;

  tw := Canvas.TextWidth(Caption);
  th := Canvas.TextHeight(caption);
  if tw> (width - height) then  tw := (width - height - 2);
  Margin := (height - th) div 2;
  if left then 
     Canvas.TextRect(rect(aRect.left+ Height,
                          aRect.top+Margin,
                          aRect.left + tw + Height,
                          aRect.Bottom-Margin),aRect.left+ Height, aRect.top+margin,caption)
  else
     Canvas.TextRect(rect(aRect.left ,aRect.top+Margin,aRect.left + tw,aRect.Bottom-Margin),aRect.left, aRect.top+margin,caption);    
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.DrawIRDArrow(Canvas: TCanvas;
                            ArrowRect: TRect;
                            FillColor: TColor;
                            HasTriangle: Boolean;
                            ID: string;
                            numberColor: TColor);
var
   p1,p2,p3 : TPoint;
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
   if not Odd(AHeight) then
      Inc(AHeight);//Force a centre

   TriMargin := AHeight div 6;
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

   Canvas.Rectangle(x, y, x+AWIDTH, {Pred(}y+AHEIGHT{)});

   Canvas.Ellipse(x+AWIDTH-(AHEIGHT div 2),y,x+AWIDTH+(AHEIGHT div 2),y+AHEIGHT);
   {internal rectangle to blank out half of circle}

   Canvas.pen.color := FillColor;
   Canvas.Rectangle(x+1, y+1, X+AWIDTH, y+AHEIGHT - 2);

   {arrow}
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

   {number}
   Canvas.Font.Height := AHEIGHT-(trimargin*2);
   Canvas.Font.Color  := numberColor;
   Canvas.Brush.color := fillcolor;

   RenderRect.Top := y+trimargin;
   RenderRect.Bottom := y+aheight-trimargin;
   RenderRect.Left := x+trimargin;
   RenderRect.Right := x+awidth-trimargin;
   Canvas.TextRect(RenderRect,RenderRect.Left, RenderRect.top, ID);

   {restore settings}
   Canvas.Pen.Color := WasPenColor;
   Canvas.Brush.Color := WasBrushColor;
   Canvas.Font.Color := WasFontColor;
   Canvas.Font.Size :=  WasFontSize;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.DrawBlackArrow(Canvas: TCanvas;
                              ID: string;
                              Rect: TRect);
begin
   DrawIRDArrow(Canvas,Rect,clBlack,false,ID,clwhite);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.DrawGrayArrow(Canvas: TCanvas;
                             ID: string;
                             HasTriangle: boolean;
                             Rect: TRect);
begin
   DrawIRDArrow(Canvas,Rect,clGray,HasTriangle,ID,clBlack);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TGST101Report.RenderWrapText(Canvas : TCanvas; Text:string; Bounds : TRect; Paint : boolean) : integer;
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
procedure TGST101Report.SplitWrapText(Canvas : TCanvas; Text:string; Width : integer; StringList: TStrings);
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
function TGST101Report.makeWidthRect( x, y, width, height : longint) : TRect;
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
function TGST101Report.MakeArrowRect(ALeft,ATop,ASize: integer; Long: Boolean = false) : TRect;
begin
   with CanvasRenderEng.OutputBuilder do begin
       Result.TopLeft := ConvertToDC( Point( ALeft, ATop));
       if Long then
          Result.BottomRight := ConvertToDC( Point( ALeft + (ASize * 3 div 2) , ATop + ASize))
       else
          //Square
          Result.BottomRight := ConvertToDC( Point( ALeft + ASize, ATop + ASize));
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.BKPrint;
var
   myCanvas : TCanvas;
   RegBoxTop,
   RegBoxBottom : integer;

   Box1Top,
   Box1Bottom : integer;
   Box2Top,
   Box2Bottom : integer;
   OfficeBoxTop,
   OfficeBoxBottom : integer;
   LeftTextTop,
   LeftTextBot     : integer;
   LongIDs: Boolean;
   BaseFontSize : integer;

   IncludesJMsg : string;
   JType        : integer;

   S: string;

   procedure DoTitle;
   begin
      CurrYPos := 100;
      myCanvas.Font.Size := 14;
      myCanvas.Font.Style := [fsbold];
      CurrLineSize := GetCurrLineSize;

      S := GSTForm.lMain1.Caption;
      if GSTForm.chkDraft.Checked then
          S := S + ' - WORK PAPER';
      RenderText(S,Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);

      RenderText(GSTForm.LSmall1.Caption ,Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtRight);
   end;



begin
   //assume we have a canvas of A4 proportions

   myCanvas     := CanvasRenderEng.OutputBuilder.Canvas;
   //BaseFontSize := UserReportSettings.s7Base_Font_Size;

   BaseFontSize := 8;
   //ReportStyle.Items[siNormal].AssignTo(MyCanvas.Font);
   myCanvas.Font.Name := 'Arial';

   DoTitle;

   CurrYPos := 230;
   myCanvas.Font.Size := BASEFONTSIZE;
   myCanvas.Font.Style := [fsbold];
   CurrLineSize := GetCurrLineSize;

   {Client details}
   with MyClient.clFields, GSTForm, Figures^, formA do begin
      RenderText(clName,Rect(ColLeftText,CurrYPos,ColRegBoxLeft,CurrYPos+CurrLineSize),jtLeft);
      NewLine;
      RenderText(clAddress_L1,Rect(ColLeftText,CurrYPos,ColRegBoxLeft,CurrYPos+CurrLineSize),jtLeft);
      NewLine;
      RenderText(clAddress_L2,Rect(ColLeftText,CurrYPos,ColRegBoxLeft,CurrYPos+CurrLineSize),jtLeft);
      NewLine;
      RenderText(clAddress_L3,Rect(ColLeftText,CurrYPos,ColRegBoxLeft,CurrYPos+CurrLineSize),jtLeft);

      myCanvas.Font.Style := [];
      //Registration and Return details
      CurrYPos := 230;
      RegBoxTop := CurrYPos - 30;
      RenderText('Registration number',Rect(ColRegText1,CurrYPos,ColRegArrowLeft,CurrYPos+CurrLineSize),jtLeft);
      DrawGrayArrow(myCanvas,'1',True,MakeArrowRect(ColRegArrowLeft,CurrYPos,CurrLineSize div 10 * 8));
      myCanvas.Font.Style := [fsBold];
      RenderText(clGST_Number,Rect(ColRegText3,CurrYPos,ColRegBoxRight,CurrYPos+CurrLineSize),jtLeft);
      NewLine;

      myCanvas.Font.Style := [];
      RenderText('Period covered',Rect(ColRegText1,CurrYPos,ColRegArrowLeft,CurrYPos+CurrLineSize),jtLeft);
      myCanvas.Font.Style := [fsBold];

      case GetPeriodMonths(Figures.rFromDate,Figures.rToDate) of
      1 : RenderText(gpNames[gpMonthly],Rect(ColRegText3,CurrYPos,ColRegBoxRight,CurrYPos+CurrLineSize),jtLeft);
      2 : RenderText(gpNames[gp2Monthly],Rect(ColRegText3,CurrYPos,ColRegBoxRight,CurrYPos+CurrLineSize),jtLeft);
      6 : RenderText(gpNames[gp6Monthly],Rect(ColRegText3,CurrYPos,ColRegBoxRight,CurrYPos+CurrLineSize),jtLeft);
      end;

      NewLine;

      myCanvas.Font.Style := [];
      RenderText('from',Rect(ColRegText1,CurrYPos,ColRegArrowLeft,CurrYPos+CurrLineSize),jtLeft);
      myCanvas.Font.Style := [fsbold];
      RenderText(bkDate2Str(Figures.rFromDate),Rect(ColRegText2,CurrYPos,ColRegBoxRight,CurrYPos+CurrLineSize),jtLeft);
      RenderText(bkDate2Str(Figures.rToDate),Rect(ColRegText3+40,CurrYPos,ColRegBoxRight,CurrYPos+CurrLineSize),jtLeft);
      myCanvas.Font.Style := [];
      RenderText('to',Rect(ColRegText3,CurrYPos,ColRegText3+30,CurrYPos+CurrLineSize),jtLeft);
      DrawGrayArrow(myCanvas,'2',True,MakeArrowRect(ColRegArrowLeft,CurrYPos,CurrLineSize div 10 * 8));
      NewLine;

      RenderText('This return and any payment are due',   Rect( ColRegText1, CurrYPos, ColRegText3, CurrYPos + CurrLineSize), jtLeft);
      myCanvas.Font.Style := [fsBold];
      RenderText( StDateToDateString( 'dd NNN yyyy', Figures.rDueDate, true), Rect( ColRegText3, CurrYPos, ColRegBoxRight - 20, CurrYPos + CurrLineSize), jtLeft);
      myCanvas.Font.Style := [];
      NewLine;

      RegBoxBottom := CurrYPos+CurrLineSize div 2;
      DrawBox(XYSizeRect(ColRegBoxLeft,RegBoxTop,ColRegBoxRight,RegBoxBottom));
      NewLine(2);

      //address details and phone number
      Box1Top := CurrYPos - CurrLineSize div 2;
      DrawGrayArrow(myCanvas,'3',true,MakeArrowRect(ColCenterTextLeft,CurrYPos,CurrLineSize div 10*8));
      MyCanvas.Font.Size := 6;
      RenderWrapText(myCanvas,'If your correct postal address for GST is not shown above, print it in Box 3.',XYSizeRect(ColLeftText,CurrYPos,ColLeftTextRight,CurrYPos+CurrLineSize*3),true);
      DrawBox(XYSizeRect(ColCenterTextLeft+CurrLineSize*2,CurrYPos, ColAmountsRight,CurrYPos+CurrLineSize*2-CurrLineSize div 2));
      NewLine(2);

      MyCanvas.Font.Size := BASEFONTSIZE;
      myCanvas.Font.Style := [ fsBold];
      RenderText( lblBasis.caption,
                 Rect( ColLeftText, CurrYPos, ColLeftTextRight, CurrYPos + CurrLineSize), jtLeft);

      MyCanvas.Font.Size := 6;
      myCanvas.Font.Style := [];
      RenderWrapText(myCanvas,'If your correct daytime phone number is not shown here, print it in Box 4',XYSizeRect(ColCenterTextLeft,CurrYPos,ColCenterTextRight-100,CurrYPos+CurrLineSize*2),true);
      MyCanvas.Font.Size := BASEFONTSIZE;
      RenderText(clPhone_No,Rect(ColCenterTextRight-80,CurrYPos,ColArrowLeft+100,CurrYPos+CurrLineSize),jtLeft);
      DrawGrayArrow(myCanvas,'4',True,MakeArrowRect(ColArrowLeft+100,CurrYPos,CurrLineSize div 10*8));
      DrawBox(XYSizeRect(ColArrowLeft+100 + CurrLineSize * 2,CurrYPos, ColAmountsRight,CurrYPos+CurrLineSize+CurrLineSize div 2));
      NewLine(2);

      Box1Bottom := CurrYPos+CurrLineSize div 2;
      DrawBox(XYSizeRect(ColBoxLeft,Box1Top,ColBoxRight,Box1Bottom));
      NewLine;

      LongIDs := GSTForm.FormPeriod = Transitional;

      //banklink Income from ledger section
      if rDraftModePrinting then begin
         RenderAmountLine('Income from Ledger',true,false,LongIDs, '',rIncome_Ledger);
         RenderAmountLine('Plus Closing Debtors',false,false,LongIDs, '',rClosing_Debtors);
         RenderText(gbNames[clGST_Basis],Rect(ColBoxLeft,CurrYPos,ColRegBoxLeft,CurrYPos+CurrLineSize),jtLeft);
         RenderAmountLine('Less Opening Debtors',false,false,LongIDs, '',rOpening_Debtors );
      end;
      NewLine;

      //GST INCOME
      Box1Top := CurrYPos - CurrLineSize div 2;
      LeftTextTop := CurrYPos;
      RenderAmountLine(L5.Caption, true, false, LongIDs, LI5.Caption, rBox_5);
      RenderAmountLine(L6.Caption, false, false, LongIDs, LI6.Caption, rZ_Rated_Sup);
      RenderUnderline;
      RenderAmountLine(L7.Caption, false, true, LongIDs, LI7.Caption, rBox_7);
      LeftTextBot := CurrYPos;
      OfficeBoxTop := CurrYPos + currLinesize div 2;
      RenderUnderline;

      RenderAmountLine(L8.Caption, false, true, LongIDs, LI8.Caption, rBox_8);

      //mh apr 2002 - new GST 101 form does not have FBT, only show if non zero
      if rFBT_Adjust <> 0 then begin
        RenderAmountLine('Adjustment for fringe benefits',false,false,LongIDs, '',rFBT_Adjust);
      end;

      //Adjustments
      RenderAmountLine(L9.Caption,false,false,LongIDs, LI9.Caption,rOther_Adjust);
      RenderUnderLine;
      OfficeBoxBottom := CurrYPos - currLinesize div 2;

      RenderAmountLine(L10.Caption,true,true,LongIDs, LI10.Caption,rGST_Collected);

      Box1Bottom := CurrYPos + CurrLineSize div 2;
      DrawBox(XYSizeRect(ColBoxLeft,Box1Top,ColBoxRight,Box1Bottom));
      DrawBox(XYSizeRect(ColOfficeBoxLeft,OfficeBoxTop,ColOfficeBoxRight,OfficeBoxBottom));

      //left side text
      RenderWrapText(myCanvas,'Goods and services tax on your sales and income.',XYSizeRect(ColOfficeBoxLeft,LeftTextTop,ColOfficeBoxRight,LeftTextBot),true);
      myCanvas.Font.Size := 6;
      myCanvas.Font.Style := [fsItalic];
      LeftTextTop := OfficeBoxTop + (CurrLineSize div 2);
      RenderText('OFFICE USE ONLY',Rect(ColOfficeBoxLeft+20,LeftTextTop,ColOfficeBoxRight,LeftTextTop+CurrLineSize),jtLeft);
      myCanvas.Font.Size := BASEFONTSIZE;
      myCanvas.Font.Style := [];
      LeftTextTop := LeftTextTop + CurrLineSize;
      DrawBlackArrow(myCanvas,'',MakeArrowRect(ColOfficeBoxLeft+20,LeftTextTop,CurrLineSize div 10 * 8));

      //Banklink purchases Section
      NewLine;
      if rDraftModePrinting then begin
         RenderAmountLine('Purchases from Ledger',true,false,LongIDs, '',rExendature_Ledger);
         RenderAmountLine('Plus Closing Creditors',false,false,LongIDs, '',rClosing_Creditors);
         RenderAmountLine('Less Opening Creditors',false,false,LongIDs, '',rOpening_Creditors);
         NewLine;
      end;


      //GST Purchases
      Box2Top := CurrYPos - CurrLineSize div 2;
      LeftTextTop := CurrYPos;
      RenderAmountLine(L11.Caption,true,false,LongIDs, LI11.Caption,rTotal_Purch);
      RenderUnderLine;
      RenderAmountLine(L12.Caption,true,true,LongIDs, LI12.Caption,rTotal_Purch_GST);

      LeftTextBot := CurrYPos;
      RenderAmountLine(L13.Caption,false,false,LongIDs, LI13.Caption,rCredit_Adjust);
      RenderUnderLine;
      RenderAmountLine(L14.Caption,true,true,LongIDs, LI14.Caption,rGST_Credit);
      NewLine;
      if FormPeriod <> Transitional then begin
         RenderAmountLine(L15.Caption,true,false, LongIDs, LI15.Caption,abs(rGST_To_Pay));
         DrawRadio(myCanvas,XYSizeRect(ColArrowLeft,CurrYPos,ColArrowLeft+(ColAmountsRight-ColArrowLeft) div 10*4,CurrYPos+CurrLineSize),'Refund',false,rGST_To_Pay <=0);
         DrawRadio(myCanvas,XYSizeRect(ColAmountsRight - (ColAmountsRight-ColArrowLeft) div 2,CurrYPos,ColAmountsRight,CurrYPos+CurrLineSize),'GST to pay',false,rGST_To_Pay >0);
         NewLine(2);
      end;
      Box2Bottom := CurrYPos;
      DrawBox(XYSizeRect(ColBoxLeft,Box2Top,ColBoxRight,Box2Bottom));

      NewLine(2);
   end; //with myclient, figures

   RenderText(format('** Transfer these amounts to your official IRD %s form.',[GSTForm.LSmall1.Caption]),
              Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;

   //left side text
   RenderWrapText(myCanvas,'Goods and services tax on your purchases and expenses.',XYSizeRect(ColOfficeBoxLeft,LeftTextTop,ColOfficeBoxRight,LeftTextBot),true);
   LeftTextTop := LeftTextBot+CurrLineSize;
   RenderText('Declaration',Rect(ColOfficeBoxLeft,LeftTextTop,ColOfficeBoxRight,LeftTextTop+CurrLineSize),jtLeft);
   LeftTextTop := LeftTextTop+CurrLineSize;
   LeftTextBot := LeftTextTop+CurrLineSize*2;
   myCanvas.Font.Size := 5;
   myCanvas.Font.Style := [fsItalic];
   RenderWrapText(myCanvas,'I declare that the information given in this return is true and correct.',XYSizeRect(ColOfficeBoxLeft,LeftTextTop,ColOfficeBoxRight,LeftTextBot),true);

   //bottom text
   CurrLineSize := GetCurrLineSize;
   myCanvas.Font.Size := 6;
   myCanvas.Font.Style := [fsItalic];
   NewLine;

   RenderText('NOTES:',Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;

   If MyClient.clFields.clGST_on_Presentation_Date then
     RenderText('The '+SHORTAPPNAME+' entries were selected by DATE OF PRESENTATION.' ,Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft)
   else
      RenderText('The '+SHORTAPPNAME+' entries were selected by EFFECTIVE DATE.' ,Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;

   RenderText('The GST Basis is ' + gbNames[MyClient.clFields.clGST_Basis], Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;

   if GSTForm.Figures.HasJournals then begin
      RenderText('The Income and Purchases figures from '+SHORTAPPNAME+' are the cash '+
                  'movements from the Bank Accounts and the following Journal Accounts:',
                     Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
      NewLine;

      //build message with journal type names
      IncludesJMsg := '';
      for jType := btBank+1 to btMax do
        if GSTForm.Figures.HasWhichJournals[jType] then
          IncludesJMsg := ' '+ IncludesJMsg + btNames[jType] + ',';

      //remove last comma
      if IncludesJMsg <> '' then
          IncludesJMsg[length(IncludesJMsg)] := ' ';

      RenderText(IncludesJMsg,Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   end else Begin
      RenderText('The Income and Purchases figures from '+SHORTAPPNAME+' are the cash '+
                  'movements from the Bank Accounts only. No Journal figures were found in this period.',Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   end;
   NewLine;

   If GSTForm.Figures^.HasUncodes then begin
     RenderText('There are some UNCODED entries in the '+SHORTAPPNAME+' ledger which WILL affect these figures.' ,Rect(Col0,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
     NewLine;
   end;

   if GSTForm.FormPeriod = Transitional then with GSTForm, Figures^, FormB do begin
      //********************   Do Part 1B **************************************
      CanvasRenderEng.ReportNewPage;
      myCanvas.Font.Name := 'Arial';

      DoTitle;

      CurrYPos := 230;

      myCanvas.Font.Size := BASEFONTSIZE;
      myCanvas.Font.Style := [fsbold];
      CurrLineSize := GetCurrLineSize;

      if rDraftModePrinting then begin
         RenderAmountLine('Income from Ledger',true,false,LongIDs, '',rIncome_Ledger);
         RenderAmountLine('Plus Closing Debtors',false,false,LongIDs, '',rClosing_Debtors);
         //RenderText(gbNames[clGST_Basis],Rect(ColBoxLeft,CurrYPos,ColRegBoxLeft,CurrYPos+CurrLineSize),jtLeft);
         RenderAmountLine('Less Opening Debtors',false,false,LongIDs, '',rOpening_Debtors );
      end;
      NewLine;

      //GST INCOME
      Box1Top := CurrYPos - CurrLineSize div 2;
      LeftTextTop := CurrYPos;
      RenderAmountLine(L5B.Caption, true,  false, LongIDs, LI5B.Caption, rBox_5);
      RenderAmountLine(L6B.Caption, false, false, LongIDs, LI6B.Caption, rZ_Rated_Sup);
      RenderUnderline;
      RenderAmountLine(L7B.Caption, false, true, LongIDs, LI7B.Caption, rBox_7);
      LeftTextBot := CurrYPos;
      OfficeBoxTop := CurrYPos + currLinesize div 2;
      RenderUnderline;

      RenderAmountLine(L8B.Caption, false, true, LongIDs, LI8B.Caption, rBox_8);

      //mh apr 2002 - new GST 101 form does not have FBT, only show if non zero
      if rFBT_Adjust <> 0 then begin
        RenderAmountLine('Adjustment for fringe benefits',false,false,LongIDs, '',rFBT_Adjust);
      end;

      //Adjustments
      RenderAmountLine(L9B.Caption,false,false,LongIDs, LI9B.Caption,rOther_Adjust);
      RenderUnderLine;
      OfficeBoxBottom := CurrYPos - currLinesize div 2;

      RenderAmountLine(L10B.Caption,true,true,LongIDs, LI10B.Caption,rGST_Collected);

      Box1Bottom := CurrYPos + CurrLineSize div 2;
      DrawBox(XYSizeRect(ColBoxLeft,Box1Top,ColBoxRight,Box1Bottom));
      DrawBox(XYSizeRect(ColOfficeBoxLeft,OfficeBoxTop,ColOfficeBoxRight,OfficeBoxBottom));

      //left side text
      RenderWrapText(myCanvas,'Goods and services tax on your sales and income.',XYSizeRect(ColOfficeBoxLeft,LeftTextTop,ColOfficeBoxRight,LeftTextBot),true);


       //Banklink purchases Section
      NewLine;
      if rDraftModePrinting then begin
         RenderAmountLine('Purchases from Ledger',true,false,LongIDs, '',rExendature_Ledger);
         RenderAmountLine('Plus Closing Creditors',false,false,LongIDs, '',rClosing_Creditors);
         RenderAmountLine('Less Opening Creditors',false,false,LongIDs, '',rOpening_Creditors);
         NewLine;
      end;

      //GST Purchases
      Box2Top := CurrYPos - CurrLineSize div 2;
      LeftTextTop := CurrYPos;
      RenderAmountLine(L11B.Caption,true,false,LongIDs, LI11B.Caption,rTotal_Purch);
      RenderUnderLine;
      RenderAmountLine(L12B.Caption,true,true,LongIDs, LI12B.Caption,rTotal_Purch_GST);

      LeftTextBot := CurrYPos;
      RenderAmountLine(L13B.Caption,false,false,LongIDs, LI13B.Caption,rCredit_Adjust);
      RenderUnderLine;
      RenderAmountLine(L14B.Caption,true,true,LongIDs, LI14B.Caption,rGST_Credit);

      NewLine;
      RenderAmountLine(L15B.Caption,true,true, LongIDs, LI15B.Caption,rGST_Collected + FormA.rGST_Collected);
      RenderAmountLine(L16B.Caption,true,true, LongIDs, LI16B.Caption,rGST_Credit + FormA.rGST_Credit);
      RenderUnderLine;
      RenderAmountLine(L17B.Caption,true,true, LongIDs, LI17B.Caption,rGST_To_Pay);
      NewLine;
      DrawRadio(myCanvas,XYSizeRect(ColArrowLeft,CurrYPos,ColArrowLeft+(ColAmountsRight-ColArrowLeft) div 10*4,CurrYPos+CurrLineSize),'Refund',false,rGST_To_Pay <=0);
      DrawRadio(myCanvas,XYSizeRect(ColAmountsRight - (ColAmountsRight-ColArrowLeft) div 2,CurrYPos,ColAmountsRight,CurrYPos+CurrLineSize),'GST to pay',false,rGST_To_Pay >0);

      Box2Bottom := CurrYPos + CurrLineSize *2;
      DrawBox(XYSizeRect(ColBoxLeft,Box2Top,ColBoxRight,Box2Bottom));

      RenderWrapText(myCanvas,'Goods and services tax on your purchases and expenses.',XYSizeRect(ColOfficeBoxLeft,LeftTextTop,ColOfficeBoxRight,LeftTextBot),true);


   end;


   if GSTForm.Figures.rFormType > GST101A then with GSTForm do begin
      // Do Part 2 and 3.
      CanvasRenderEng.ReportNewPage;
      myCanvas.Font.Name := 'Arial';

      DoTitle;

      CurrYPos := 230;

      myCanvas.Font.Size := BASEFONTSIZE;
      myCanvas.Font.Style := [fsbold];
      CurrLineSize := GetCurrLineSize;

      //left side text
      Box1Top := CurrYPos - CurrLineSize div 2;

      RenderText('Part 2 –',Rect(ColLeftText,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
      NewLine;
      RenderText('Provisional tax',Rect(ColLeftText,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
      NewLine;
      RenderText('calculation when',Rect(ColLeftText,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
      NewLine;
      RenderText('using the ratio',Rect(ColLeftText,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
      NewLine;
      RenderText('option',Rect(ColLeftText,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);

      CurrYPos := 230;
      myCanvas.Font.Style := [];
      RenderAmountLine(L16.Caption,false,True,LongIDs, LI16.Caption,Figures.FormA.rBox_5);
      RenderUnderline;
      if P17.Visible then begin
         RenderAmountLine('Total sales and income from last month',false,false,LongIDs, '17',Figures.rpt_LastMonthIncome);
         RenderUnderline;
         RenderAmountLine('Add Box 16 and Box 17',false,True,LongIDs, '18',Figures.FormA.rBox_5 + Figures.rpt_LastMonthIncome);
         RenderUnderline;
      end;
      RenderAmountLine('Total sales and income from Branches',false,false,LongIDs, '19',Figures.rpt_BranchIncome);
      RenderUnderline;
      RenderAmountLine('Add Box 18 and Box 19',false,true,LongIDs, '20',Figures.FormA.rBox_5 + Figures.rpt_LastMonthIncome + Figures.rpt_BranchIncome);
      RenderUnderline;
      RenderAmountLine('Adjustments for asset''s worth',false,false,LongIDs, '21',Figures.rpt_Assets);
      RenderUnderline;
      RenderAmountLine('Subtract Box 21 from Box 20',false,true,LongIDs, '22',
              Figures.FormA.rBox_5 + Figures.rpt_LastMonthIncome
              + Figures.rpt_BranchIncome - Figures.rpt_Assets );
      RenderUnderline;
      RenderAmountLine('Compulsory provisional tax period',True,false,LongIDs, '23',Figures.rpt_Tax);

      Box1Bottom := CurrYPos + CurrLineSize div 2;

      DrawBox(XYSizeRect(ColBoxLeft,Box1Top,ColBoxRight,Box1Bottom));


      // Part 3
      Box1Top := Box1Bottom + CurrLineSize;

      CurrYPos :=  Box1Top + CurrLineSize div 2;
      myCanvas.Font.Style := [fsbold];
      RenderText('Part 3 –',Rect(ColLeftText,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
      NewLine;
      RenderText('Payment calculation',Rect(ColLeftText,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);

      CurrYPos :=  Box1Top + CurrLineSize div 2;
      myCanvas.Font.Style := [];
      RenderAmountLine('Provisional Tax',false,false,LongIDs, '24',Figures.rpt_Tax);
      RenderUnderline;
      if figures.rGST_To_Pay < 0 then begin
         RenderAmountLine('Refund transfered',false,false,LongIDs, '25',Figures.rpt_RefundUsed );
         RenderUnderline;
         RenderAmountLine('Subtract Box 25 from Box 24',false,true,LongIDs, '26',Figures.rpt_Tax - Figures.rpt_RefundUsed);
         RenderUnderline;
         RenderAmountLine('GST to pay',false,true,LongIDs, '27',0);
         RenderUnderline;
         RenderAmountLine('GST and/or provisional tax to pay',false,true,LongIDs, '28',Figures.rpt_Tax - Figures.rpt_RefundUsed);
      end else begin
         RenderAmountLine('Refund transfered',false,true,LongIDs, '25',0 );
         RenderUnderline;
         RenderAmountLine('Subtract Box 25 from Box 24',false,false,LongIDs, '26',Figures.rpt_Tax);
         RenderUnderline;
         RenderAmountLine('GST to pay',false,false,LongIDs, '27',Figures.rGST_to_Pay);
         RenderUnderline;
         RenderAmountLine('GST and/or provisional tax to pay',false,false,LongIDs, '28',Figures.rpt_Tax + Figures.rGST_to_Pay);
      end;


      Box1Bottom := CurrYPos + CurrLineSize div 2;

      DrawBox(XYSizeRect(ColBoxLeft,Box1Top,ColBoxRight,Box1Bottom));

   end;

   //Was printed is set here so that it will pickup the document being printed
   //even if the user selected preview first, and then selected print from the
   //preview screen
   wasPrinted := (CanvasRenderEng.OutputBuilder.CurrentDestination = 0)//0 = printer; 1 = screen
              or (Self.OriginalDestination = rdFile); //PDF
end;
constructor TGST101Report.Create(RptType: TReportType);
begin
  inherited create(RptType);
  // Cannot have a Style or Header Footer info
  ReportTypeParams.ClearUserHeaderFooter;
  if Assigned(FReportStyle) then begin
     FReportStyle.Name := '';
     FReportStyle.Reset;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.DrawBox(XYRect: TRect);
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
function TGST101Report.GetCurrLineSize: integer;
const
   //line size inflation allows for a gap between each line.  Height of text alone
   //would not give us any spacing
   LINE_SIZE_INFLATION = 1.4;
begin
   result := Round(CanvasRenderEng.OutputBuilder.HeightOfText('A') * LINE_SIZE_INFLATION);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoGST101Report( Destination: TReportDest;
                            ForGSTForm: TfrmGST101;
                            Params: TRptParameters = nil ): boolean;
//returns true if the report was printed
var
   Job : TGST101Report;
begin
   result := false;
   if not assigned(ForGSTForm) then
      exit;
   CreateReportImageList;
   Job := TGST101Report.Create(rptGST); // Dont need that..
   try
     Job.WasPrinted := false;
     Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_GST101]);
     Job.GSTForm := ForGSTForm;
     Job.FileFormats := [ffPDF, ffAcclipse];

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
procedure TGST101Report.NewLine;
begin
   CurrYPos := CurrYPos + CurrLineSize;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.NewLine(Count: integer);
begin
   CurrYPos := CurrYPos + CurrLineSize *  Count;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.RenderText(textValue: string; textRect: TRect; Justify: TJustifyType);
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
procedure TGST101Report.RenderAmountLine(Title: string; isBold, isBlack, islong: boolean; ID:string; Value: Double);
var
   WrappedLines : integer;
begin
   if isBold then
      CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsBold]
   else
      CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];

   WrappedLines := RenderTextWrapped(Title,Rect(ColCenterTextLeft,CurrYPos,ColCenterTextRight,CurrYPos+CurrLineSize));

   if ID > '' then
      if isblack then
         DrawBlackArrow(CanvasRenderEng.OutputBuilder.Canvas,ID,MakeArrowRect(ColArrowLeft,CurrYPos,CurrLineSize div 10 * 9,islong))
      else
         DrawGrayArrow(CanvasRenderEng.OutputBuilder.Canvas,ID,True,MakeArrowRect(ColArrowLeft,CurrYPos,CurrLineSize div 10 * 9,islong));

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];
   RenderText(FormatFloat('$#,##0.00;$(#,##0.00)',Value),Rect(ColCenterTextRight,CurrYPos,ColAmountsRight,CurrYPos+CurrLineSize),jtRight);
   NewLine(WrappedLines);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TGST101Report.RenderTextWrapped(text: string; aRect:TRect) : integer;
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
procedure TGST101Report.RenderLine(x, y, width: integer);
begin
   with CanvasRenderEng.OutputBuilder do begin
      Canvas.Polyline([ ConvertToDC( Point(x,y)),ConvertToDC( Point(x+width,y))]);
   end;        { with }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGST101Report.RenderUnderline;
begin
   RenderLine(ColCenterTextLeft,CurrYPos+CurrLineSize div 2,ColAmountsRight-ColCenterTextLeft);
   NewLine;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TGST101Report.XYSizeRect(ALeft, ATop, ARight,
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
function TGST101Report.GetCanvasRE: TRenderToCanvasEng;
begin
   result := TRenderToCanvasEng( RenderEngine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
