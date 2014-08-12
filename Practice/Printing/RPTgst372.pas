unit RPTgst372;

interface

uses
  clObj32,
  PrintMgrObj,
  reportDefs,
  GSTWorkRec,
  gst372frm,
  rptGST101,
  RptParams;


type
  TGST372Report = class(TGST101Report)
  private
    FGst372: TFrmGST372;
    procedure SetGst372(const Value: TFrmGST372);
  protected
  public
    procedure BKPrint;  override;
    property Gst372 : TFrmGST372 read FGst372 write SetGst372;
  end;

function DoGST372Report(ForForm : TFrmGST372; Destination : TReportDest; Params : TRptParameters = nil) : boolean;

//*************
implementation
//*************

uses
   ReportTypes,
   repcols,
   Classes,
   SysUtils,
   StdCtrls,
   Graphics,
   Globals, bkConst, NewReportUtils;


function DoGST372Report(ForForm : TFrmGST372; Destination : TReportDest; Params: TRptParameters) : boolean;

var
   Job : TGST372Report;
begin
   Job := TGST372Report.Create(RptGst);
   try
      Job.ReportTypeParams.ClearUserHeaderFooter;
      Job.Gst372 := ForForm;
      Job.WasPrinted := false;
      Job.LoadReportSettings(ForForm.UserPrintSettings,Report_List_Names[Report_GST372]);
      //Job.Figures := @ForForm.GSTRec;
      Job.FileFormats := [ ffPDF, ffAcclipse];

      AddCommonFooter(Job);


      if Destination in [rdScreen, rdPrinter, rdFile, rdEmail] then
         Job.Generate( Destination, Params);

      result := Job.WasPrinted;
   finally
      Job.Free;
   end;
end;

{ TGST372Report }

const
   {columns specs in 0.1mm ie. 10=1mm}
   BoxMargin            = 20;
   Col0                 = 100;
   ColTitle             = 750;
   ColTopFill           = 200;
   ColOwnDetails1       = Col0 + 450;
   ColTextInBox         = Col0 + BoxMargin;
   ColCenterTextRight   = Col0 + 1350;
   ColArrowLeft         = ColCenterTextRight + 100;
   ColAmountsRight      = Col0 + 1800;
   ColBoxRight          = ColAmountsRight    + BoxMargin;



procedure TGST372Report.BKPrint;
var
   myCanvas : TCanvas;
   BoxTop : integer;
   BaseFontSize : integer;


   procedure RenderAmountLine(Title: string; isBold: boolean; ArrowNo: integer; Value: Double);
   var
     WrappedLines : integer;
   begin
      if isBold then
         CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsBold]
      else
         CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];

      WrappedLines := RenderTextWrapped(Title,Rect(ColTextInBox,CurrYPos,ColCenterTextRight,CurrYPos+CurrLineSize));
      if ArrowNo <> 0 then
        if ArrowNo > 0 then
           DrawBlackArrow(CanvasRenderEng.OutputBuilder.Canvas,intTostr(ArrowNo),MakeArrowRect(ColArrowLeft,CurrYPos,CurrLineSize div 10 * 9))
        else
           DrawGrayArrow(CanvasRenderEng.OutputBuilder.Canvas,intToStr(-ArrowNo),false,MakeArrowRect(ColArrowLeft,CurrYPos,CurrLineSize div 10 * 9));

      //CanvasRenderEng.OutputBuilder.Canvas.font.Style := []; Keep the money bold as well
      RenderText(FormatFloat('$#,##0.00;$(#,##0.00)',Value),Rect(ColCenterTextRight,CurrYPos,ColAmountsRight,CurrYPos+CurrLineSize),jtRight);
      NewLine(WrappedLines);

   end;

   procedure DoBox;
   begin
      DrawBox(XYSizeRect(Col0,BoxTop,ColBoxRight,CurrYPos));
   end;

   procedure DoRadio (XPos : Integer; value : tRadioButton);
   var Space : Integer;
   begin
     Space := CurrLineSize Div 4;
     DrawRadio(MyCanvas,XYSizeRect(XPos,CurrYPos + Space,
                                   Xpos+ 450,
                                   CurrYPos +  CurrLineSize - Space ),Value.Caption,true,  value.Checked)
   end;

   procedure DoLine;
   var Space : Integer;
   begin
      Space := CurrLineSize Div 4;
      RenderLine(ColTextInBox,CurrYPos+ Space, ColAmountsRight-ColTextInBox);
      Inc(CurrYPos , Space + space);
   end;

begin
   {assume we have a canvas of A4 proportions}
   myCanvas     := CanvasRenderEng.OutputBuilder.Canvas;
   BaseFontSize := 8;
   //ReportStyle.Items[siNormal].AssignTo(MyCanvas.Font);
   myCanvas.Font.Name := 'Arial';
   myCanvas.Font.Size := 14;
   myCanvas.Font.Style := [fsbold];
   CurrLineSize := GetCurrLineSize;

   //<title>
   CurrYPos := 100 ;

   RenderText('Inland Revenue',   Rect(Col0,    CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   RenderText('GST adjustments',  Rect(ColTitle,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   RenderText('IR 372',           Rect(Col0,    CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtRight);

   NewLine;
   RenderText('Calculation Sheet',Rect(ColTitle,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   //</title>


   CurrYPos := 300;
   myCanvas.Font.Size := BASEFONTSIZE;
   myCanvas.Font.Style := [fsbold];
   CurrLineSize := GetCurrLineSize;

   //<Top Fill>
   BoxTop := CurrYPos;
   RenderText('Use this sheet to calculate the GST on your adjustments for your GST return.',
        Rect(ColTopFill,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;

   RenderText('Please use the GST guide (IR 375) to help you work out your adjustments.',
        Rect(ColTopFill,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;
   RenderText('Attach this sheet to your copy of the return and keep full details on how these items have been calculated.',
        Rect(ColTopFill,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;
   DoBox;
   //</Top Fill>

   //<Own Details>
   Inc(CurrYPos,CurrLineSize);
   BoxTop := CurrYPos;
   myCanvas.Font.Style := [];
   // GstNo
   RenderText(GST372.Label1.Caption,
        Rect(ColTextInBox,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   myCanvas.Font.Style := [fsbold];
   RenderText(GST372.stGSTNumber.Caption,
        Rect(ColOwnDetails1,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);

   Inc(CurrYPos,CurrLineSize * 3 Div 2);
   // name
   myCanvas.Font.Style := [];
   RenderText(GST372.Label2.Caption,
        Rect(ColTextInBox,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   myCanvas.Font.Style := [fsbold];
   RenderText(GST372.stname.Caption,
        Rect(ColOwnDetails1,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);

   Inc(CurrYPos,CurrLineSize * 3 Div 2);
   // Period
   myCanvas.Font.Style := [];
   RenderText(GST372.Label3.Caption,
        Rect(ColTextInBox,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);

   DoRadio( ColOwnDetails1,GST372.RbMonth);
   DoRadio( 900,GST372.Rb2Months);
   DoRadio(1350,GST372.RB6Months);
   NewLine;
   //From
   RenderText(GST372.Label4.Caption,
        Rect(ColTextInBox,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   myCanvas.Font.Style := [fsbold];
   RenderText(GST372.stFrom.Caption,
        Rect(ColOwnDetails1,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   //To
   myCanvas.Font.Style := [];
   RenderText(GST372.Label5.Caption,
        Rect(900,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   myCanvas.Font.Style := [fsbold];
   RenderText(GST372.stTo.Caption,
        Rect(1000,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);

   Inc(CurrYPos,CurrLineSize * 3 Div 2);

   DoBox;
   //</Own Details>

   NewLine;
   //<adjustments>
   BoxTop := CurrYPos;
   myCanvas.Font.Style := [fsbold];
   RenderText('Include GST on adjustments in Box 9.',
        Rect(ColTextInBox,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;

   RenderAmountLine(GST372.Label7.Caption,false,0, GST372.NPrivate.AsFloat);
   RenderAmountLine(GST372.Label8.Caption,false,0, GST372.NBusiness.AsFloat);
   RenderAmountLine(GST372.Label9.Caption,false,0, GST372.NAssets.AsFloat);
   RenderAmountLine(GST372.Label10.Caption,false,0,GST372.NEnterTainment.AsFloat);
   RenderAmountLine(GST372.Label11.Caption,false,0,GST372.NChange.AsFloat);
   RenderAmountLine(GST372.Label12.Caption,false,0,GST372.NGSTExempt.AsFloat);
   RenderAmountLine(GST372.Label13.Caption
                   +GST372.Label14.Caption,false,0,GST372.NOther.AsFloat);
   DoLine;
   RenderAmountLine(GST372.Label15.Caption,True,-9,GST372.TotalAdjustment);
   DoBox;
   //</adjustments>


   NewLine;
   //<Credits>
   BoxTop := CurrYPos;
   myCanvas.Font.Style := [fsbold];
   RenderText('Include GST on credit adjustments in Box 13.',
        Rect(ColTextInBox,CurrYPos,ColBoxRight,CurrYPos+CurrLineSize),jtLeft);
   NewLine;

   RenderAmountLine(GST372.Label17.Caption,false,0, GST372.NCBusiness.AsFloat);
   RenderAmountLine(GST372.Label18.Caption,false,0, GST372.NcPrivate.AsFloat);
   RenderAmountLine(GST372.Label19.Caption,false,0, GST372.NcChange.AsFloat);
   RenderAmountLine(GST372.Label6.Caption,false,0, GST372.CustomsGSTAmount);
   RenderAmountLine(GST372.Label20.Caption,false,0, GST372.NcOther.AsFloat);

   DoLine;
   RenderAmountLine(GST372.Label24.Caption,True,-13,GST372.CreditAdjustment);
   DoBox;
   //</Credits>

end;


procedure TGST372Report.SetGst372(const Value: TFrmGST372);
begin
  FGst372 := Value;
end;

end.
