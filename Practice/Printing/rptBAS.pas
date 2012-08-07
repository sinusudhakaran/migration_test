unit rptBAS;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   BAS Report

  Written:
  Authors: Neil

  Purpose: Prints the the BAS report both front page and calculation sheet.

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
   extctrls,
   BasCalc,
   rptParams,
   ReportDefs,
   tsGrid;

   function DoBASReport(Destination: TReportDest; BasValues: TBasInfo; Fuel: TtsGrid;
                        Params: TRptParameters = nil) : boolean;

   function DoBasSummary(Destination: TReportDest; BasValues: TBasInfo;
                        Params: TRptParameters = nil) : boolean;

//******************************************************************************
implementation
uses
   Windows,
   Graphics,
   classes,
   ReportTypes,
   NewReportObj,
   repcols,
   ReportToCanvas,
   bkdefs,
   bkconst,
   globals,
   UBatchBase,
   bkDateUtils,
   sysutils,
   imagesfrm,
   PrintDestDlg,
   BASfrm,
   BasUtils,
   stDate,
   NewReportUtils,
   moneyDef, GenUtils;

const
   Gap                 = 5;    //margin used
   FontReductionFactor = 0.7;
   LineSeperatorChar   = '~';  //tilda
   BoldTag             = '<b>';
   ItalicTag           = '<i>';
   BAS_SUMMARY_FORMAT = '#,##0;(#,##0)';

type
   TBASSummaryReport = class(TBKReport)
   private
     Figures      : TBasInfo;
     WasPrinted   : boolean;

     procedure RenderTwoColumn( s1 : string; i1 : Integer; s2 : string; i2 : Integer); overload;
     procedure RenderLine( s1 : string; i1 : Integer); overload;
     procedure RenderLine( s1, s2 : string); overload;
     procedure RenderSummaryLine(FieldID1, Amount1, FieldID2, Amount2: integer;
                                               CheckAmounts : boolean = true);
     function GetCanvasRE: TRenderToCanvasEng;
   protected
     procedure BKPrint;  override;
     property  CanvasRenderEng : TRenderToCanvasEng read GetCanvasRE;
   end;


type
   TBASReport = class(TBKReport)
   private
     CurrYPos,
     CurrLineSize : integer;
     Figures      : TBasInfo;
     FuelSheet    : TtsGrid;
     WasPrinted   : boolean;

     function GetCurrLineSize :integer;
     function XYSizeRect(ALeft,ATop,ARight,ABottom:integer):TRect;

     procedure RenderText(textValue: string; textRect: TRect; Justify: TJustifyType);
     procedure RenderLine(x, y, width: integer);
     procedure DrawBox(XYRect : TRect);
     procedure DrawBlackBox( XYRect : TRect);
     procedure RenderBasBox(Title : string; BoxID : string; Value: Double;
               Location : integer; ExText : string; var WrappedLines : integer);
     function  RenderTextWrapped(text: string; aRect:TRect; Justify: TJustifyType) : integer;
     //New line procedure is overloaded so that it can be called with or without parameters
     procedure NewLine; overload;
     procedure NewLine(Count : integer); overload;
     //Type casts the TCustomRenderEngine object to a Canvas Rendering Engine object
     function  GetCanvasRE: TRenderToCanvasEng;
     procedure RenderOtherBasBox(Title, BoxID: string; Value: Double; DollarSign : Boolean;
               BoxNumber: integer; ExText: string;
               var WrappedLines: integer);
    //procedure PrintBitmap(Canvas: TCanvas; DestRect: TRect;  Bitmap: TBitmap);
   protected
     procedure BKPrint;  override;
     property  CanvasRenderEng: TRenderToCanvasEng read GetCanvasRE;
   end;

{ TBASReport }
 const
   {columns specs in 0.1mm ie. 10=1mm}
   Col0                 = 0;
   ColLeftText          = Col0;
   ColLeftTextRight     = 420;
   ColLeftIDTextRight   = 500;
   ColLeftCurTextRight  = 540;
   ColLeftAmtTextRight  = 965;
   ColRightTextLeft     = 990;
   ColRightTextRight    = 1410;
   ColRightIDTextRight  = 1490;
   ColRightCurTextRight = 1520;
   ColRightAmtTextRight = 1955;
   ColCenterTextLeft     = 450;
   ColCenterTextRight    = 700;
   ColCenterIDTextRight  = 750;
   ColCenterCurTextRight = 790;
   ColCenterAmtTextRight = 1155;
   ColCenterXTextRight   = 1960;
   ColLeftBoxLeft       = 50;
   ColLeftBoxRight      = 1100;
   ColCenterBoxLeft     = 1160;
   ColCenterBoxRight    = 1640;
   ColRightBoxLeft      = 1660;
   ColRightBoxRight     = 1980;

   ColF4AmtRight      = 1615;
   ColT41AmtRight       = 625;
   ColT2T3AmtRight      = 1700;
   ColT2T3XRight        = 1755;
   ColT42AmtRight       = 1650;

{
////////////////////////////////////////////////////////////////////
//
//  Utility routines used to print bitmaps
//
// Based on posting to borland.public.delphi.winapi by Rodney E Geraghty, 8/8/97.
// Used to print bitmap on any Windows printer.

procedure TBASReport.PrintBitmap(Canvas : TCanvas; DestRect : TRect; Bitmap : TBitmap);
//accepts a destrect in 0.1mm units.  Adds margins
var
   BitmapHeader:  pBitmapInfo;
   BitmapImage :  pointer;
   HeaderSize  :  dword;    // Use DWORD for D3-D5 compatibility
   ImageSize   :  dword;
begin
   with CanvasRenderEng.OutputBuilder do
   begin
       //apply offset for left,top margins
       with DestRect do begin
          Inc( Left, OutputAreaLeft);
          Inc( Right, OutputAreaLeft);
          Inc( Top, OutputAreaTop);
          Inc( Bottom, OutputAreaTop);
       end;

       //convert from 0.1mm to pixels
       with DestRect do begin
          TopLeft     := ConvertToDC( TopLeft);
          BottomRight := ConvertToDC( BottomRight);
       end;
   end;
   GetDIBSizes(Bitmap.Handle, HeaderSize, ImageSize);
   GetMem(BitmapHeader, HeaderSize);
   GetMem(BitmapImage,  ImageSize);
   try
      GetDIB(Bitmap.Handle, Bitmap.Palette, BitmapHeader^, BitmapImage^);
      StretchDIBits(Canvas.Handle,
               DestRect.Left, DestRect.Top,     // Destination Origin
               DestRect.Right  - DestRect.Left, // Destination Width
               DestRect.Bottom - DestRect.Top,  // Destination Height
               0, 0,                            // Source Origin
               Bitmap.Width, Bitmap.Height,     // Source Width & Height
               BitmapImage,
               TBitmapInfo(BitmapHeader^),
               DIB_RGB_COLORS,
               SRCCOPY);
   finally
      FreeMem(BitmapHeader);
      FreeMem(BitmapImage);
   end;
end {PrintBitmap;
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.BKPrint;
var
   BasCanvas       : TCanvas;
   S,S2            : string;
   d1,d2,m1,m2,y1,y2,i, Top : integer;
   WrappedLines,

   SectionTop      : integer;
   SectionBottom   : integer;

   GSTOption1Visible,
   ChkGSTOption1Visible,
   GSTOption2Visible,
   GSTOption3Visible,
   GSTVisible        : boolean;
   PAYG_W_Visible    : boolean;
   FBT_Visible       : boolean;
   PAYG_I_Visible    : boolean;
   PAYG_IOpt1_Visible,
   PAYG_IOpt2_Visible,
   PAYG_IOpt3_Visible : boolean;
   Summary_Visible    : boolean;
   Payment_Visible    : boolean;

   PanelsVisible      : integer;
   Page1Full          : boolean;

   iTempValue         : integer;
   AnnualDatesCaption : string;
   CurrXPos : Integer;
   Total: Double;
   FuelRow: Integer;
const
  colCodeWidth = 150;
  colDescWidth = 300;
  colTypeWidth = 225;
  colLitresWidth = 200;
  colUseWidth = 400;
  colPercentWidth = 150;
  colEligibleWidth = 200;
  colRateWidth = 175;
  colTotalWidth = 200;
begin
   AnnualDatesCaption := '';
   {assume we have a canvas of A4 proportions}
   BasCanvas     := CanvasRenderEng.OutputBuilder.Canvas;

   //Printing the front page of BAS form****************************************
   //Header
   CurrYPos := 0;

   BasCanvas.Font.Style := [];
   BasCanvas.Font.Color := clBlack;
   BasCanvas.Font.Name  := 'Arial';
   //ReportStyle.Items[siNormal].AssignTo(BasCanvas.Font);

   BasCanvas.Font.Size := 8;

   CurrLineSize := GetCurrLineSize;

   RenderText( bsNames[ Figures.BasFormType],
               Rect( 50, CurrYPos,200 , CurrYPos + CurrLineSize),
               jtLeft);

   BasCanvas.Font.Size := 10;
   BasCanvas.Font.Style := [fsbold];
   BasCanvas.Font.Color := clBlack;
   CurrLineSize := GetCurrLineSize;

   //Client details
   with MyClient.clFields do begin
      BasCanvas.Font.Size := 12;
      BasCanvas.Font.Style := [fsbold];
      CurrLineSize := GetCurrLineSize;
      S := '<b>' + clName + '~<b>' + clAddress_L1 + '~<b>' + clAddress_L2 + '~<b>' + clAddress_L3 + '~<b>'+ clClient_EMail_Address;
      RenderTextWrapped( S, Rect(155, 50, 1060, 270 + (CurrLineSize * 4)), jtLeft);
      DrawBox( Rect(100, 0, 1100, 600));
   end;


   with figures do begin
      //CurrYPos := 200;
      BasCanvas.Font.Size := 14;
      BasCanvas.Font.Style := [];
      CurrLineSize := GetCurrLineSize;

      if BasUtils.IsBASForm( BasFormType) then
         S := 'Business Activity~Statement'
      else
         S :='Instalment Activity~Statement';

      if BasFormType in [bsH, bsBasZ] then
         S := 'Annual GST return';

      if BasFormType = bsK then
         S := 'Annual GST~information report';

      RenderTextWrapped( S,
                         Rect( 1200, 0, 1950, CurrLineSize * 2),
                         jtLeft);

      StDateToDMY( BasFromDate, d1, m1, y1);
      StDatetoDMY( BasToDate, d2, m2, y2);
      if ( y1 = y2) then begin
         //same year
         S := moNames[ m1] + ' to ' + moNames[ m2] + ' ' + inttostr( y2);
      end
      else begin
         S := moNames[ m1] + ' ' + inttostr( y1) + ' to ' +
                      moNames[ m2] + ' ' + inttostr( y2);
      end;
      AnnualDatesCaption := S;
      BasCanvas.Font.Size := 12;
      RenderTextWrapped( S,
                         Rect( 1200, 120, 1950, 410),
                         jtLeft);
      CurrYPos := 190;
      BasCanvas.Font.Size := 11;
      CurrLineSize := GetCurrLineSize;

      BasCanvas.Font.Size := 8;
      BasCanvas.Font.Style := [];
      RenderText('Document ID ', Rect(1200, CurrYPos, 1520, CurrYPos + CurrLineSize), jtLeft); // Space added here so the D doesn't look truncated
      BasCanvas.Font.Size := 11;
      BasCanvas.Font.Style := [ fsBold];
      RenderText(DocumentID, Rect(1550, CurrYPos, 2000, CurrYPos + CurrLineSize), jtLeft);
      NewLine;
      NewLine;

      BasCanvas.Font.Size := 8;
      BasCanvas.Font.Style := [];
      RenderText('ABN', Rect(1200, CurrYPos, 1500, CurrYPos + CurrLineSize), jtLeft);
      BasCanvas.Font.Size := 11;
      BasCanvas.Font.Style := [ fsBold];
      RenderText(ABN, Rect(1550, CurrYPos, 1850, CurrYPos + CurrLineSize), jtLeft);
      RenderText(ABN_Extra, Rect(1850, CurrYPos, 2000, CurrYPos + CurrLineSize), jtCenter); //Need more information
      NewLine;
      NewLine;

      BasCanvas.Font.Size := 8;
      BasCanvas.Font.Style := [];
      RenderText('Form due on', Rect(1200, CurrYPos, 1500, CurrYPos + CurrLineSize), jtLeft);
      BasCanvas.Font.Size := 11;
      BasCanvas.Font.Style := [ fsBold];
      RenderText(bkDate2Str( DueDate ), Rect(1550, CurrYPos, 1850, CurrYPos + CurrLineSize), jtLeft);
      NewLine;
      NewLine;

      BasCanvas.Font.Size := 8;
      BasCanvas.Font.Style := [];
      RenderText('Payment due on', Rect(1200, CurrYPos, 1500, CurrYPos + CurrLineSize), jtLeft);
      BasCanvas.Font.Size := 11;
      BasCanvas.Font.Style := [ fsBold];
      RenderText(bkDate2Str( PaymentDate ), Rect(1550, CurrYPos, 1850, CurrYPos + CurrLineSize), jtLeft);
      NewLine;
      NewLine;

      BasCanvas.Font.Size := 8;
      BasCanvas.Font.Style := [];
      RenderText('GST accounting method', Rect(1200, CurrYPos, 1520, CurrYPos + CurrLineSize), jtLeft);
      BasCanvas.Font.Size := 11;
      BasCanvas.Font.Style := [ fsBold];
      if MyClient.clFields.clGST_Basis in [ gbMin..gbMax] then
         S := gbaNames[ MyClient.clFields.clGST_Basis]
      else
         S := '';
      RenderText( S, Rect(1550, CurrYPos, 1850, CurrYPos + CurrLineSize), jtLeft);
      NewLine;
      NewLine;
      CurrYPos := 600;

      PanelsVisible := 0;
      Page1Full   := false;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//GST
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      GSTOption1Visible           := FieldVisible( bfG1,  BasFormType) or
                                     FieldVisible( bfG2,  BasFormType) or
                                     FieldVisible( bfG3,  BasFormType) or
                                     FieldVisible( bfG10, BasFormType) or
                                     FieldVisible( bfG11, BasFormType);

      ChkGSTOption1Visible        := FieldVisible( bfGSTOption1, BasFormType);
      GSTOption2Visible           := FieldVisible( bfGSTOption2, BasFormType);
      GSTOption3Visible           := FieldVisible( bfGSTOption3, BasFormType) or
                                     FieldVisible( bfG21, BasFormType, iG21_ATOInstalment) or
                                     FieldVisible( bfG22, BasFormType, iG22_EstimatedNetGST) or
                                     FieldVisible( bfG23, BasFormType, iG23_VariedAmount);
      //see if we were expecting option 3
      if GSTOption3Visible and ( not FieldVisible( bfGSTOption3, BasFormType)) then begin
         //would not normally see option 3, so display opt 1 and 2 to allow user to change
         GSTOption1Visible    := true;
         GSTOption2Visible    := true;
         chkGSTOption1Visible := true;
      end;

      //see if should show tab
      GSTVisible              := GSTOption1Visible or GSTOption3Visible;

      if GSTVisible then begin
         Inc( PanelsVisible);
         //GST heading
         BasCanvas.Font.Color := clWhite;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         BasCanvas.Brush.Color := clBlack;
         CurrLineSize := GetCurrLineSize;
         NewLine;
         DrawBlackBox( Rect( 20, CurrYPos - ( CurrLineSize div 5), 2000, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
         RenderText( 'Goods and services tax (GST)',
                     Rect( 40, CurrYPos, 1950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine;

         BasCanvas.Font.Color := clBlack;
         BasCanvas.Brush.Color := clWhite;
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size  := 8;

         DrawBox( Rect( 20, CurrYPos, 950, CurrYPos + CurrLineSize + 10));
         if not IsAnnualStatement then
            S := BasUtils.DatesCaption( GSTFromDate, GSTToDate)
         else
            S := AnnualDatesCaption;
         RenderText( S,
                     Rect( 40, CurrYPos, 950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine;
         NewLine;

         SectionTop    := CurrYPos;
         SectionBottom := CurrYPos;


         if GSTOption1Visible then begin
            if ChkGSTOption1Visible then begin
               BasCanvas.Font.Style := [];
               BasCanvas.Font.Size  := 8;
               CurrLineSize := GetCurrLineSize;
               RenderText( 'Complete Option 1 OR 2 OR 3 (indicate one choice with an X)',
                           Rect( ColLeftText, CurrYPos, ColLeftAmtTextRight, CurrYPos + CurrLineSize),
                           jtLeft);
               NewLine(2);
            end;

            //GST Option 1

      //      BoxYPos := CurrYPos - ( CurrLineSize div 2);
            SectionTop    := CurrYPos;

            if ChkGSTOption1Visible then begin
               DrawBox( Rect( ColLeftText, CurrYPos, ColLeftText + 50, CurrYPos + CurrLineSize + 10));
               RenderText ( 'Option 1: Calculate GST and report quarterly',
                            Rect( ColLeftText + 100, CurrYPos, ColLeftAmtTextRight, CurrYPos + CurrLineSize),
                            jtLeft);

               if iGSTOptionUsed = 1 then
                  RenderText ( 'X',
                  Rect( ColLeftText, CurrYPos, ColLeftText + 50, CurrYPos + CurrLineSize),
                  jtCenter);

               NewLine(2);
            end;

            if FieldVisible( bfG1, BasFormType) then begin

               if ( iGSTOptionUsed = 1) then iTempValue := iIncome_G1 else iTempValue := 0;
               RenderBasBox( 'Total sales', 'G1', iTempValue, 1, '', wrappedlines);
               NewLine(2);

               BasCanvas.Font.Style := [];
               BasCanvas.Font.Size  := 8;
               CurrLineSize := GetCurrLineSize;
               RenderTextWrapped( 'Does the amount shown~at G1 include GST?',
                                  Rect( ColLeftText + 50, CurrYPos, ColLeftIDTextRight, CurrYPos + ( 2 * CurrLineSize)),
                                  jtRight);

               DrawBox( Rect( ColLeftIDTextRight + 50, CurrYPos - 10, ColLeftIDTextRight + 100, CurrYPos + CurrLineSize + 10));
               RenderText( 'Yes',
                           Rect( ColLeftIDTextRight + 120, CurrYPos, ColLeftIDTextRight + 250, CurrYPos + CurrLineSize), jtLeft);

               DrawBox( Rect( ColLeftIDTextRight + 250, CurrYPos - 10, ColLeftIDTextRight + 300, CurrYPos + CurrLineSize + 10));
               RenderText( 'No',
                           Rect( ColLeftIDTextRight + 320, CurrYPos, ColLeftIDTextRight + 450, CurrYPos + CurrLineSize), jtLeft);

               if( iGSTOptionUsed = 1) then begin
                  if bG1IncludesGST  then
                     RenderText ( 'X',
                                  Rect( ColLeftIDTextRight + 50, CurrYPos, ColLeftIDTextRight + 100, CurrYPos + CurrLineSize),
                                  jtCenter)
                  else
                     RenderText ( 'X',
                                  Rect( ColLeftIDTextRight + 250, CurrYPos, ColLeftIDTextRight + 300, CurrYPos + CurrLineSize),
                                  jtCenter);
               end;
               NewLine(3);
            end
            else
               NewLine;

            if ( iGSTOptionUsed = 1) then iTempValue := iExports_G2 else iTempValue := 0;
            RenderBasBox( 'Export sales', 'G2', iTempValue, 1, '', wrappedLines);
            NewLine(2);

            if ( iGSTOptionUsed = 1) then iTempValue := iGSTFreeSupplies_G3 else iTempValue := 0;
            RenderBasBox( 'Other GST-free sales', 'G3', iTempValue, 1, '', wrappedLines);
            NewLine(2);

            if ( iGSTOptionUsed = 1) then iTempValue := iCapitalAcq_G10 else iTempValue := 0;
            RenderBasBox( 'Capital purchases', 'G10', iTempValue, 1, '', wrappedlines);
            NewLine(2);

            if ( iGSTOptionUsed = 1) then iTempValue := iOtherAcq_G11 else iTempValue := 0;
            RenderBasBox( 'Non-capital purchases', 'G11', iTempValue, 1, '', wrappedLines);
            NewLine(2);

            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            if FieldVisible( bfG1, BasFormType) then begin
               RenderTextWrapped( '<b>Go to the summary to report GST on sales at 1A and~'+
                                  '<b>GST on purchases at 1B',
                                  Rect( ColLeftText + 30, CurrYPos, ColLeftAmtTextRight, CurrYPos + 2*CurrLineSize),
                                  jtLeft);
            end;
            NewLine(2);
            SectionBottom := CurrYPos;

            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
         end;

         //GST Option 2
         if GSTOption2Visible then begin
            CurrYPos := SectionTop;
            DrawBox( Rect( ColRightTextLeft + 50, CurrYPos, ColRightTextLeft + 100, CurrYPos + CurrLineSize + 10));
            RenderText ( 'Option 2: Calculate GST and report annually',
                         Rect( ColRightTextLeft + 120, CurrYPos, ColRightAmtTextRight, CurrYPos + CurrLineSize),
                         jtLeft);
            if iGSTOptionUsed = 2 then
               RenderText ( 'X',
                            Rect( ColRightTextLeft + 50, CurrYPos, ColRightTextLeft + 100, CurrYPos + CurrLineSize),
                            jtCenter);

            NewLine(2);

            if ( iGSTOptionUsed = 2) then iTempValue := iIncome_G1 else iTempValue := 0;
            RenderBasBox( 'Total sales', 'G1', iTempValue, 2, '', wrappedlines);
            NewLine(2);

            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( 'Does the amount shown~at G1 include GST?',
                               Rect( ColRightTextLeft + 50, CurrYPos, ColRightIDTextRight, CurrYPos + ( 2 * CurrLineSize)),
                               jtRight);
            DrawBox( Rect( ColRightIDTextRight + 50, CurrYPos - 10, ColRightIDTextRight + 100, CurrYPos + CurrLineSize + 10));
            RenderText( 'Yes',
                        Rect( ColRightIDTextRight + 120, CurrYPos, ColRightIDTextRight + 250, CurrYPos + CurrLineSize), jtLeft);

            DrawBox( Rect( ColRightIDTextRight + 250, CurrYPos - 10, ColRightIDTextRight + 300, CurrYPos + CurrLineSize + 10));
            RenderText( 'No',
                        Rect( ColRightIDTextRight + 320, CurrYPos, ColRightIDTextRight + 450, CurrYPos + CurrLineSize), jtLeft);

            if( iGSTOptionUsed = 2) then begin
               if bG1IncludesGST  then
                  RenderText ( 'X',
                               Rect( ColRightIDTextRight + 50, CurrYPos, ColRightIDTextRight + 100, CurrYPos + CurrLineSize),
                               jtCenter)
               else
                  RenderText ( 'X',
                               Rect( ColRightIDTextRight + 250, CurrYPos, ColRightIDTextRight + 300, CurrYPos + CurrLineSize),
                               jtCenter);
            end;

            NewLine(3);

            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Go to the summary to report GST on sales at 1A and~'+
                               '<b>GST on purchases at 1B ', // added a space here so that the B doesn't look truncated 
                               Rect( ColRightTextLeft + 30, CurrYPos, ColRightAmtTextRight, CurrYPos + 2*CurrLineSize),
                               jtLeft);
            NewLine(3);
         end;

         if GSTOption3Visible then begin
            //GST Option 3
            NewLine(2);
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            DrawBox( Rect( ColRightTextLeft + 50, CurrYPos - 10, ColRightTextLeft + 100, CurrYPos + CurrLineSize + 10));
            RenderText ( 'Option 3: Pay GST instalment amount',
                         Rect( ColRightTextLeft + 120, CurrYPos, ColRightAmtTextRight, CurrYPos + CurrLineSize),
                         jtLeft);

            if iGSTOptionUsed = 3 then
               RenderText ( 'X',
                            Rect( ColRightTextLeft + 50, CurrYPos, ColRightTextLeft + 100, CurrYPos + CurrLineSize),
                            jtCenter);
            NewLine(2);
            RenderBasBox( 'ATO instalment amount  ', 'G21', iG21_ATOInstalment, 2, '', wrappedLines);
            NewLine(2);
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Write this amount at 1A in summary~'+
                               '<b>OR if varying this amount, complete G22, G23, G24',
                               Rect( ColRightTextLeft + 30, CurrYPos, ColRightAmtTextRight, CurrYPos + CurrLineSize),
                               jtLeft);
            NewLine(3);

            RenderBasBox( 'Estimated net  ~GST for the year  ', 'G22', iG22_EstimatedNetGST, 2,'',wrappedLines);
            NewLine(2);
            RenderBasBox( 'Varied amount for the quarter  ', 'G23', iG23_VariedAmount, 2, '',wrappedLines);
            NewLine(2);

            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Write the G23 amount at 1A in summary',
                               Rect( ColRightTextLeft + 30, CurrYPos, ColRightAmtTextRight, CurrYPos + CurrLineSize),
                               jtLeft);
            NewLine(2);
            RenderOtherBasBox( 'Reason code for variation  ', 'G24', iG24_ReasonVar, false, 6, '', wrappedLines);
            NewLine(2);
         end;

         if CurrYPos < SectionBottom then
            CurrYPos := SectionBottom;
      end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//PAYG Instalment heading
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      PAYG_IOpt1_Visible      := FieldVisible( bfPAYGOption1, BasFormType) or
                              FieldVisible( bfT7, BasFormType, iT7_ATOInstalment) or
                              FieldVisible( bfT8, BasFormType, iT8_EstimatedTax) or
                              FieldVisible( bfT9, BasFormType, iT9_VariedAmount);

      PAYG_IOpt2_Visible      := FieldVisible( bfPAYGOption2, BasFormType) or
                              FieldVisible( bfT1, BasFormType, iTaxInstalmIncome_T1) or
                              FieldVisible( bfT11, BasFormType, iT11_T1x_T2orT3);

      PAYG_IOpt3_Visible      := (FieldVisible( bfPAYGOption3, BasFormType) or
                              FieldVisible( bfT6, BasFormType, iTaxInstalmIncome_T1))
                              and (BasFormType = bsIASN);
      PAYG_I_Visible          := PAYG_IOpt1_Visible or PAYG_IOpt2_Visible or PAYG_IOpt3_Visible;

      if PAYG_I_Visible then begin
         Inc( PanelsVisible);
         BasCanvas.Font.Color := clWhite;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         BasCanvas.Brush.Color := clBlack;
         CurrLineSize := GetCurrLineSize;
         NewLine;
         DrawBlackBox( Rect( 20, CurrYPos - ( CurrLineSize div 5), 2000, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
         RenderText( 'PAYG income tax instalment',
                     Rect( 40, CurrYPos, 1950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine;
         BasCanvas.Font.Color := clBlack;
         BasCanvas.Brush.Color := clWhite;
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size  := 8;
         DrawBox( Rect( 20, CurrYPos, 950, CurrYPos + CurrLineSize + 10));
         RenderText( BasUtils.DatesCaption( PAYG_I_FromDate, PAYG_I_ToDate),
                     Rect( 40, CurrYPos, 950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine;
         NewLine;

         if PAYG_IOPT3_Visible then
         begin
            NewLine(2);
            RenderBasBox( '', 'T5', iBAST5, 1,'',wrappedLines);
            NewLine(2);
         end;

         if (PAYG_IOpt1_Visible or PAYG_IOpt3_Visible) and PAYG_IOpt2_Visible then begin
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderText( 'Complete Option 1 OR 2 (indicate one choice with an X)',
                        Rect( ColLeftText, CurrYPos, ColLeftAmtTextRight, CurrYPos + CurrLineSize),
                        jtLeft);
            NewLine(2);
         end;

         SectionTop := CurrYPos;
         if PAYG_IOpt3_Visible then begin
            DrawBox( Rect( ColLeftText, CurrYPos, ColLeftText + 50, CurrYPos + CurrLineSize + 20));
            RenderText ( 'Option 1: Vary your PAYG instalment amount',
                         Rect( ColLeftText + 100, CurrYPos, ColLeftAmtTextRight, CurrYPos + CurrLineSize),
                         jtLeft);
            if iPAYGInstalmentOptionUsed = 3 then
               RenderText ( 'X',
                            Rect( ColLeftText, CurrYPos, ColLeftText + 50, CurrYPos + CurrLineSize),
                            jtCenter);

            NewLine(2);
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>If you are varying the T5 amount,~' +
                               '<b>complete T6 and T4',
                               Rect( ColLeftText + 30, CurrYPos, ColLeftAmtTextRight, CurrYPos + 2*CurrLineSize),
                               jtLeft);
            NewLine(3);
            RenderBasBox( 'Varied instalment amount', 'T6', iT6_VariedAmount, 1,'',wrappedLines);
            NewLine(2);
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Write the T6 amount at 5A in the summary',
                               Rect( ColLeftText + 30, CurrYPos, ColLeftAmtTextRight, CurrYPos + CurrLineSize),
                               jtLeft);
            NewLine(2);
            if iPAYGInstalmentOptionUsed = 3 then
               iTempValue := iTaxReasonVar_T4
            else
               iTempValue := 0;
            RenderOtherBasBox( 'Reason code for variation', 'T4', iTempValue, false, 4, '', wrappedLines);
            NewLine(2);
         end
         else if PAYG_IOpt1_Visible then begin
            DrawBox( Rect( ColLeftText, CurrYPos, ColLeftText + 50, CurrYPos + CurrLineSize + 20));
            RenderText ( 'Option 1: Pay a PAYG instalment amount',
                         Rect( ColLeftText + 100, CurrYPos, ColLeftAmtTextRight, CurrYPos + CurrLineSize),
                         jtLeft);
            if iPAYGInstalmentOptionUsed = 1 then
               RenderText ( 'X',
                            Rect( ColLeftText, CurrYPos, ColLeftText + 50, CurrYPos + CurrLineSize),
                            jtCenter);

            NewLine(2);
            RenderBasBox( ' ', 'T7', iT7_ATOInstalment, 1, '', wrappedLines);
            NewLine;
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Write this amount at 5A in summary~' +
                               '<b>OR if varying the amount, complete T8, T9, T4',
                               Rect( ColLeftText + 30, CurrYPos, ColLeftAmtTextRight, CurrYPos + 2*CurrLineSize),
                               jtLeft);
            NewLine(3);
            RenderBasBox( 'Estimated tax for the year', 'T8', iT8_EstimatedTax, 1, '', wrappedLines);
            NewLine;
            RenderBasBox( 'Varied amount for the~quarter', 'T9', iT9_VariedAmount, 1,'',wrappedLines);
            NewLine(2);
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Write the T9 amount at 5A in the summary',
                               Rect( ColLeftText + 30, CurrYPos, ColLeftAmtTextRight, CurrYPos + CurrLineSize),
                               jtLeft);
            NewLine(2);
            if iPAYGInstalmentOptionUsed = 1 then
               iTempValue := iTaxReasonVar_T4
            else
               iTempValue := 0;
            RenderOtherBasBox( 'Reason code for variation', 'T4', iTempValue, false, 4, '', wrappedLines);
            NewLine(2);
         end;

         SectionBottom := CurrYPos;

         // PAYG Instalment Option 2
         if PAYG_IOpt2_Visible then begin
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            CurrYPos := SectionTop;

            if PAYG_IOpt1_Visible or PAYG_IOpt3_Visible then begin
               DrawBox( Rect( ColRightTextLeft + 50, CurrYPos, ColRightTextLeft + 100, CurrYPos + CurrLineSize + 20));
               RenderText ( 'Option 2: Calculate PAYG instalment using income x rate',
                            Rect( ColRightTextLeft + 120, CurrYPos, ColRightAmtTextRight, CurrYPos + CurrLineSize),
                            jtLeft);
               if iPAYGInstalmentOptionUsed = 2 then
                  RenderText ( 'X',
                               Rect( ColRightTextLeft + 50, CurrYPos, ColRightTextLeft + 100, CurrYPos + CurrLineSize),
                               jtCenter);
               NewLine(2);
            end;
            RenderBasBox( 'PAYG instalment income', 'T1', iTaxInstalmIncome_T1, 2, '', wrappedLines);
            NewLine;
            RenderOtherBasBox( ' ~ ', 'T2', dTaxInstalmRate_T2, false, 3, '%', wrappedLines);
            NewLine(2);
            if not PAYG_IOpt3_Visible then
            begin
              RenderOtherBasBox( 'New varied rate', 'T3', dTaxVarInstalmRate_T3, false, 3, '%',wrappedLines);
              NewLine(2);
            end;
            RenderBasBox( 'T1 x T2 (or x T3)', 'T11', iT11_T1x_T2orT3, 2, '', wrappedLines);
            NewLine(2);
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Write the T11 amount at 5A in the summary',
                               Rect( ColRightTextLeft + 30, CurrYPos, ColRightAmtTextRight, CurrYPos + CurrLineSize),
                               jtLeft);
            NewLine(2);
            if not PAYG_IOpt3_Visible then
            begin
              if iPAYGInstalmentOptionUsed = 2 then
                 iTempValue := iTaxReasonVar_T4
              else
                 iTempValue := 0;
              RenderOtherBasBox( 'Reason code for variation', 'T4', iTempValue, false, 6, '', wrappedLines);
              NewLine(2);
            end;
            if CurrYPos < SectionBottom then
               CurrYPos := SectionBottom;
         end;
      end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//PAYG Withheld heading, FBT Heading
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      //PAYG Withholding Tab
      PAYG_W_Visible  := FieldVisible( bfW1, BasFormType, iTotalSalary_W1) or
                         FieldVisible( bfW2, BasFormType, iSalaryWithheld_W2) or
                         FieldVisible( bfW3, BasFormType, iInvstmntDist_W3) or
                         FieldVisible( bfW4, BasFormType, iInvoicePymt_W4);

      FBT_Visible     := FieldVisible( bfF1, BasFormType, iFBTInstalm_F1) or
                         FieldVisible( bfF2, BasFormType, iFBTTotalPayable_F2) or
                         FieldVisible( bfF3, BasFormType, iFBTVariedInstalm_F3);

      if PAYG_W_Visible or FBT_Visible then begin
         //Start on a new page if needed
         if ( PanelsVisible > 1) and ( not Page1Full) then begin
            Page1Full := true;
            CanvasRenderEng.ReportNewPage;
            BasCanvas     := CanvasRenderEng.OutputBuilder.Canvas;
            CurrYPos := 150;
         end;
         Inc( PanelsVisible);
         BasCanvas.Font.Color := clWhite;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         BasCanvas.Brush.Color := clBlack;
         CurrLineSize := GetCurrLineSize;
         NewLine;

         if PAYG_W_Visible then begin
            DrawBlackBox( Rect( 20, CurrYPos - ( CurrLineSize div 5), 950, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
            RenderText( 'PAYG tax withheld',
                        Rect( 40, CurrYPos, 950, CurrYPos + CurrLineSize),
                        jtLeft);
         end;

         if FBT_Visible then begin
            DrawBlackBox( Rect( 1000, CurrYPos - ( CurrLineSize div 5), 1950, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
            RenderText( 'Fringe benefits tax (FBT) instalment',
                        Rect( 1020, CurrYPos, 1950, CurrYPos + CurrLineSize),
                        jtLeft);
         end;
         NewLine;
         BasCanvas.Font.Color := clBlack;
         BasCanvas.Brush.Color := clWhite;
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size  := 8;

         if PAYG_W_Visible then begin
            //PAYG W
            DrawBox( Rect( 20, CurrYPos, 950, CurrYPos + CurrLineSize + 10));
            RenderText( BasUtils.DatesCaption( PAYG_W_FromDate, PAYG_W_ToDate),
                        Rect( 40, CurrYPos, 950, CurrYPos + CurrLineSize),
                        jtLeft);
         end;
         //FBT
         if FBT_Visible then begin
            DrawBox( Rect( 1000, CurrYPos, 1950, CurrYPos + CurrLineSize + 10));
            RenderText( BasUtils.DatesCaption( FBT_FromDate, FBT_ToDate),
                        Rect( 1020, CurrYPos, 1950, CurrYPos + CurrLineSize),
                        jtLeft);
         end;
         NewLine;
         NewLine;
         SectionTop := CurrYPos;

         if PAYG_W_Visible then begin
            //PAYG W
            RenderBasBox( 'Total salary, wages and~other payments', 'W1', iTotalSalary_W1, 1, '', wrappedLines);
            NewLine( 2);
            NewLine;
            RenderBasBox( 'Amounts withheld from~payments shown at W1', 'W2', iSalaryWithheld_W2, 1, '', wrappedLines);
            NewLine(2);
            RenderBasBox( 'Amount withheld where~no ABN is quoted', 'W4', iInvoicePymt_W4, 1, '', wrappedlines);
            NewLine(2);
            RenderBasBox( 'Other amounts withheld~(excluding any amount~shown at W2 or W4)', 'W3', iInvstmntDist_W3, 1, '', wrappedLines);
            NewLine(3);
            RenderBasBox( 'Total amounts withheld~(W2 + W4 + W3)~<b>Write at 4 in summary', 'W5', iW5_TotalAmountsWithheld, 1, '', wrappedLines);
            NewLine(3);
            NewLine;
         end;
         SectionBottom := CurrYPos;

         //FBT Boxes
         if FBT_Visible then begin
            CurrYPos := SectionTop;
            RenderBasBox( 'ATO instalment amount', 'F1', iFBTInstalm_F1, 2, '', wrappedlines);
            NewLine;
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Write this amount at 6A in summary~' +
                               '<b>OR if varying the amount, complete F2, F3, F4',
                               Rect( ColRightTextLeft + 30, CurrYPos, ColRightAmtTextRight, CurrYPos + 2*CurrLineSize),
                               jtLeft);
            NewLine(2);
            RenderBasBox( 'Estimated FBT~for the year', 'F2', iFBTTotalPayable_F2, 2, '', wrappedLines);
            NewLine(2);
            RenderBasBox( 'Varied amount for~the quarter', 'F3', iFBTVariedInstalm_F3, 2, '', wrappedLines);
            NewLine(2);
            BasCanvas.Font.Style := [];
            BasCanvas.Font.Size  := 8;
            CurrLineSize := GetCurrLineSize;
            RenderTextWrapped( '<b>Write the F3 amount~' +
                               '<b>at 6A in summary',
                               Rect( ColRightTextLeft + 30, CurrYPos, ColRightAmtTextRight, CurrYPos + 2*CurrLineSize),
                               jtLeft);
            NewLine( 2);
            RenderOtherBasBox('Reason for variation', 'F4', iFBTReasonVar_F4, true, 5, '', WrappedLines); //Need more information
            NewLine;
         end;

         if CurrYPos < SectionBottom then
            CurrYPos := SectionBottom;
      end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Printing the Summary Fields
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      Summary_Visible := FieldVisible( bf1a, BasFormType, iGSTPayable_1A) or
                     FieldVisible( bf1b, BasFormType, iGSTCredit_1B) or
                     FieldVisible( bf1c, BasFormType, iWineEqlPayable_1C) or
                     FieldVisible( bf1d, BasFormType, iWineEqlRefund_1D) or
                     FieldVisible( bf1e, BasFormType, iLuxCarPayable_1E) or
                     FieldVisible( bf1f, BasFormType, iLuxCarRefund_1F) or
                     FieldVisible( bf1g, BasFormType, iSalesTaxCredit_1G) or
                     FieldVisible( bf1h, BasFormType, i1H_GSTInstalment) or
                     FieldVisible( bf2a, BasFormType) or
                     FieldVisible( bf2b, BasFormType) or
                     FieldVisible( bf4,  basFormType, iTotalWithheld_4) or
                     FieldVisible( bf5a, BasFormType, iIncomeTaxInstalm_5A) or
                     FieldVisible( bf5b, BasFormType, iCrAdjPrevIncome_5B) or
                     FieldVisible( bf6a, BasFormType, iFBTInstalm_6A) or
                     FieldVisible( bf6b, BasFormType, iVariationCr_6B) or
                     FieldVisible( bf7,  BasFormType, iDeferredInstalm_7) or
                     FieldVisible( bf7c, BasFormType) or
                     FieldVisible( bf7d, BasFormType) or
                     FieldVisible( bf8a, BasFormType) or
                     FieldVisible( bf8b, BasFormType);

      if Summary_Visible then begin
         //Start on a new page if needed
         if (( GSTVisible) or ( PanelsVisible > 1)) and ( not Page1Full) then begin
            CanvasRenderEng.ReportNewPage;
            BasCanvas     := CanvasRenderEng.OutputBuilder.Canvas;
            CurrYPos := 150;
         end;
         BasCanvas.Font.Color := clWhite;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         BasCanvas.Brush.Color := clBlack;
         CurrLineSize := GetCurrLineSize;
         NewLine;
         DrawBlackBox( Rect( 20, CurrYPos - ( CurrLineSize div 5), 2000, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
         RenderText( 'Summary',
                     Rect( 40, CurrYPos, 1950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine;
         BasCanvas.Font.Color := clBlack;
         BasCanvas.Brush.Color := clWhite;
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size  := 8;
         NewLine;
         NewLine;
         SectionTop := CurrYPos;

         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         // Left Side
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         BasCanvas.Font.Size := 8; //BaseFontSize;
                                   //BasCanvas.Font.Style := [fsbold];
         CurrLineSize := GetCurrLineSize;
         if FieldVisible( bf1a, BasFormType, iGSTPayable_1A) then begin
            RenderBasBox('GST on sales or GST instalment', '1A', iGSTPayable_1A, 1, '', WrappedLines);
            NewLine(1);
         end;
         CurrYPos := CurrYPos + 17; // Need a gap here to match the right hand side, which has a two line label
         if FieldVisible( bf1c, BasFormType, iWineEqlPayable_1C) then begin
            RenderBasBox('Wine equalisation tax', '1C', iWineEqlPayable_1C, 1, '', WrappedLines);
            NewLine(1);
         end;
         CurrYPos := CurrYPos + 17; // Need a gap here to match the right hand side, which has a two line label
         if FieldVisible( bf1e, BasFormType, iLuxCarPayable_1E) then begin
            RenderBasBox('Luxury car tax', '1E', iLuxCarPayable_1E, 1, '', WrappedLines);
            NewLine(1);
         end;
         SectionBottom := CurrYPos;

         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         // Right Side
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

         CurrYPos := SectionTop;
         if FieldVisible( bf1b, BasFormType, iGSTCredit_1B) then begin
            RenderBasBox('GST on purchases', '1B', iGSTCredit_1B, 2, '', WrappedLines);
            NewLine(1);
         end;
         if FieldVisible( bf1d, BasFormType, iWineEqlRefund_1D) then begin
            RenderBasBox('Wine equalisation~tax refundable', '1D', iWineEqlRefund_1D, 2, '', WrappedLines);
            NewLine(2);
         end;
         if FieldVisible( bf1f, BasFormType, iLuxCarRefund_1F) then begin
            RenderBasBox('Luxury car tax refundable', '1F', iLuxCarRefund_1F, 2, '', WrappedLines);
            NewLine(1);
         end;
         if FieldVisible( bf1g, BasFormType, iSalesTaxCredit_1G) then begin
            RenderBasBox('Credit for wholesale~sales tax', '1G', iSalesTaxCredit_1G, 2, '', WrappedLines);
            NewLine(2);
         end;
         if FieldVisible( bf1h, BasFormType, i1H_GSTInstalment) then begin
            RenderBasBox('GST instalment', '1H', i1H_GSTInstalment, 2, '', WrappedLines);
            NewLine(1);
         end;

         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         // Totals
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

         if CurrYPos < SectionBottom then
            CurrYPos := SectionBottom;

         NewLine;
         if FieldVisible( bf2a, BasFormType) then begin
            RenderLine(ColLeftCurTextRight, CurrYPos - ( CurrLineSize), ColLeftAmtTextRight + Gap - ColLeftCurTextRight);
            RenderBasBox('', '2A', iTotalDebit_2A, 1, '', WrappedLines);
         end;
         if FieldVisible( bf2b, BasFormType) then begin
            RenderLine(ColRightCurTextRight, CurrYPos - ( CurrLineSize), ColRightAmtTextRight + Gap - ColRightCurTextRight);
            RenderBasBox('', '2B', iTotalCredit_2B, 2, '', WrappedLines);
         end;
         NewLine;

         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         // Left Side
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         SectionTop := CurrYPos;

         if FieldVisible( bf4,  basFormType, iTotalWithheld_4) then begin
            RenderBasBox('PAYG withheld', '4', iTotalWithheld_4, 1, '', WrappedLines);
            NewLine(1);
         end;
         if FieldVisible( bf5a, BasFormType, iIncomeTaxInstalm_5A) then begin
            RenderBasBox('PAYG income tax~instalment ', '5A', iIncomeTaxInstalm_5A, 1, '', WrappedLines);
            NewLine(2);
         end;
         if FieldVisible( bf6a, BasFormType, iFBTInstalm_6A) then begin
            RenderBasBox('FBT instalment ', '6A', iFBTInstalm_6A, 1, '', WrappedLines);
            NewLine( 2);
         end;
         if FieldVisible( bf7,  BasFormType, iDeferredInstalm_7) then begin
            RenderBasBox('Deferred company/fund~instalment', '7', iDeferredInstalm_7, 1, '', WrappedLines);
            NewLine( 2);
         end;
         if FieldVisible( bf7c,  BasFormType) then begin
            RenderBasBox('Fuel tax credit over claim~(Do not claim in litres)', '7C', iFuelOverClaim_7C, 1, '', WrappedLines);
            NewLine( 2);
         end;
         SectionBottom := CurrYPos;

         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         // Right Side
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         CurrYPos := SectionTop;
         if FieldVisible( bf4,  basFormType, iTotalWithheld_4) then begin
            NewLine(1);
         end;
         if FieldVisible( bf5b, BasFormType, iCrAdjPrevIncome_5B) then begin
            RenderBasBox('Credit from PAYG income~tax instalment variation', '5B', iCrAdjPrevincome_5B, 2, '', WrappedLines);
            NewLine(2);
         end;
         if FieldVisible( bf6b, BasFormType, iVariationCr_6B) then begin
            RenderBasBox('Credit from FBT~instalment variation', '6B', iVariationCr_6B, 2, '', WrappedLines);
            NewLine( 2);
         end;
         if FieldVisible( bf7d,  BasFormType) then begin
            RenderBasBox('Fuel tax credit~(Do not claim in litres)', '7D', iFuelCredit_7D, 2, '', WrappedLines);
            NewLine( 2);
         end;
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         // Totals
         //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

         if CurrYPos < SectionBottom then
            CurrYPos := SectionBottom;
         NewLine;
         if FieldVisible( bf8a, BasFormType) then begin
            RenderLine(ColLeftCurTextRight, CurrYPos - ( CurrLineSize), ColLeftAmtTextRight + Gap - ColLeftCurTextRight);
            RenderBasBox('', '8A', iTaxPayableTotal_8A, 1, '', WrappedLines);
         end;
         if FieldVisible( bf8b, BasFormType) then begin
            RenderLine(ColRightCurTextRight, CurrYPos - ( CurrLineSize), ColRightAmtTextRight + Gap - ColRightCurTextRight);
            RenderBasBox('', '8B', iTaxCreditTotal_8B, 2, '', WrappedLines);
         end;
         NewLine;
      end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Payment or refund heading
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      Payment_Visible := FieldVisible( bf9, BasFormType, iNetTaxObligation_9) and (BasFormType <> bsIASN);
      if Payment_Visible then begin
         BasCanvas.Font.Color := clWhite;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         BasCanvas.Brush.Color := clBlack;
         CurrLineSize := GetCurrLineSize;
         NewLine;
         DrawBlackBox( Rect( 20, CurrYPos - ( CurrLineSize div 5), 2000, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
         RenderText( 'Payment or refund?',
                     Rect( 40, CurrYPos, 1950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine;
         BasCanvas.Font.Color := clBlack;
         BasCanvas.Brush.Color := clWhite;
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size  := 8;
         NewLine;
         NewLine;

         if iTaxCreditTotal_8B > iTaxPayableTotal_8A then begin
            S := 'This amount is~refundable to you';
            S2 := 'REFUND';
         end
         else begin
            S := 'This amount is~payable to the ATO';
            S2 := 'PAYMENT';
         end;
         RenderBasBox( S, '9', iNetTaxObligation_9, 1, '', WrappedLines);
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 8;
         RenderText( S2, Rect( ColLeftAmtTextRight + 50,
                              CurrYPos,
                              ColLeftAmtTextRight + 400,
                              CurrYPos + CurrLineSize), jtLeft);
         NewLine( 2);
      end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//calculation sheet

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if not ( MyClient.clFields.clBAS_Dont_Print_Calc_Sheet or BasUtils.IsIASForm( BasFormType)) then begin
         //Printing Calculation Sheet of the BAS Form*********************************
         CanvasRenderEng.ReportNewPage;
         //Need to re-assign the Canvas for print preview
         BasCanvas     := CanvasRenderEng.OutputBuilder.Canvas;

         CurrYPos := 150;
         //GST heading
         BasCanvas.Font.Color := clWhite;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         BasCanvas.Brush.Color := clBlack;
         CurrLineSize := GetCurrLineSize;
         NewLine;
         DrawBlackBox( Rect( 20, CurrYPos - ( CurrLineSize div 5), 2000, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
         RenderText( 'GST calculation worksheet',
                     Rect( 40, CurrYPos, 1950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine;

         BasCanvas.Font.Color := clBlack;
         BasCanvas.Brush.Color := clWhite;
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size  := 8;

         DrawBox( Rect( 20, CurrYPos, 950, CurrYPos + CurrLineSize + 10));
         if not IsAnnualStatement then
            S := BasUtils.DatesCaption( GSTFromDate, GSTToDate)
         else
            S := AnnualDatesCaption;

         RenderText( S,
                     Rect( 40, CurrYPos, 950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine(3);

         BasCanvas.Font.Color := clWhite;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         BasCanvas.Brush.Color := clBlack;
         CurrLineSize := GetCurrLineSize;
         DrawBlackBox( Rect( 20, CurrYPos - ( CurrLineSize div 5), ColLeftAmtTextRight, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
         RenderText( 'GST amounts you owe the ATO from sales',
                     Rect( 40, CurrYPos,  ColLeftAmtTextRight, CurrYPos + CurrLineSize),
                     jtLeft);

         DrawBlackBox( Rect( ColLeftAmtTextRight + 50, CurrYPos - ( CurrLineSize div 5), ColRightAmtTextRight, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
         RenderText( 'GST amounts the ATO owes you from purchases ',
                     Rect( ColLeftAmtTextRight + 50, CurrYPos, ColRightAmtTextRight, CurrYPos + CurrLineSize),
                     jtRight);
         NewLine(3);

         BasCanvas.Font.Color := clBlack;
         BasCanvas.Brush.Color := clWhite;
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size  := 8;

         //Printing the BoxFields
         RenderBasBox('Total sales', 'G1', iIncome_G1, 1, '', WrappedLines);
         RenderBasBox('Capital purchases', 'G10', iCapitalAcq_G10, 2, '', WrappedLines);
         NewLine( 3);

         RenderBasBox('Non-capital purchases', 'G11', iOtherAcq_G11, 2, '', WrappedLines);
         RenderBasBox('Export sales', 'G2', iExports_G2, 1, '', WrappedLines);
         NewLine(3);

         RenderBasBox('G10 + G11', 'G12', iTotalAcq_G12, 2, '', WrappedLines);
         RenderBasBox('Other GST-free sales', 'G3', iGSTFreeSupplies_G3, 1, '', WrappedLines);
         NewLine(3);

         RenderLine(ColRightCurTextRight, CurrYPos-10, ColRightAmtTextRight + Gap - ColRightCurTextRight);
         RenderBasBox('Input taxed sales~ ', 'G4', iInputTaxedSales_G4, 1, '', WrappedLines);
         RenderBasBox('Purchases for making~input taxed sales', 'G13', iAcqInputTaxedSales_G13, 2, '', WrappedLines);
         NewLine(3);

         RenderLine(ColLeftCurTextRight, CurrYPos-30, ColLeftAmtTextRight + Gap - ColLeftCurTextRight);
         RenderBasBox('G2 + G3 + G4', 'G5', iTotalGSTFree_G5, 1, '', WrappedLines);
         RenderBasBox('GST-free purchases', 'G14', iAcqNoGST_G14, 2, '', WrappedLines);
         NewLine(3);

         RenderLine(ColLeftCurTextRight, CurrYPos-10, ColLeftAmtTextRight + Gap - ColLeftCurTextRight);
         RenderBasBox('Total sales subject to GST~G1 minus G5', 'G6', iTotalTaxableSupp_G6, 1, '', WrappedLines);
         RenderBasBox('Estimated purchases for private~use or not income tax deductible', 'G15', iEstPrivateUse_G15, 2, '', WrappedLines);
         NewLine(3);

         RenderLine(ColRightCurTextRight, CurrYPos-30, ColRightAmtTextRight + Gap - ColRightCurTextRight);
         RenderBasBox('G13 + G14 + G15', 'G16', iTotalNonCreditAcq_G16, 2, '', WrappedLines);
         RenderBasBox('Adjustments', 'G7', iIncAdjustments_G7, 1, '', WrappedLines);
         NewLine(3);

         RenderLine(ColLeftCurTextRight, CurrYPos-10, ColLeftAmtTextRight + Gap - ColLeftCurTextRight);
         RenderLine(ColRightCurTextRight, CurrYPos-10, ColRightAmtTextRight + Gap - ColRightCurTextRight);
         RenderBasBox('Total sales subject to GST~after adjustments~(G6 + G7)', 'G8', iTotalTaxSuppAdj_G8, 1, '', WrappedLines);
         RenderBasBox('Total purchases subject to GST~(G12 minus G16) ', 'G17', iTotalCreditAcq_G17, 2, '', WrappedLines);
         NewLine(3);

         RenderLine(ColLeftCurTextRight, CurrYPos-30, ColLeftAmtTextRight + Gap - ColLeftCurTextRight);
         RenderBasBox('GST on sales~(G8 divided by eleven)~<b>BAS 1A', 'G9', iGSTPayable_G9, 1, '', WrappedLines);
         RenderBasBox('Adjustments', 'G18', iAcqAdjustments_G18, 2, '', WrappedLines);
         NewLine( 3);

         RenderLine(ColRightCurTextRight, CurrYPos-5, ColRightAmtTextRight + Gap - ColRightCurTextRight);
         RenderBasBox('Total purchases subject to GST~after adjustments~(G17 + G18)', 'G19', iTotalCreditAcqAdj_G19, 2, '', WrappedLines);
         NewLine( 3);

         RenderLine(ColRightCurTextRight, CurrYPos-30, ColRightAmtTextRight + Gap - ColRightCurTextRight);
         RenderBasBox('GST on purchases~(G19 divided by eleven)~<b>BAS 1B', 'G20', iGSTCredit_G20, 2, '', WrappedLines);
         NewLine(WrappedLines);
      end;  //dont print calculation sheet

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//fuel calculation sheet

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if (not MyClient.clMoreFields.mcBAS_Dont_Print_Fuel_Sheet) and FieldVisible( bf7d,  BasFormType) then begin
         //Printing Calculation Sheet of the BAS Form*********************************
         CanvasRenderEng.ReportNewPage;
         //Need to re-assign the Canvas for print preview
         BasCanvas     := CanvasRenderEng.OutputBuilder.Canvas;

         CurrYPos := 150;
         //GST heading
         BasCanvas.Font.Color := clWhite;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         BasCanvas.Brush.Color := clBlack;
         CurrLineSize := GetCurrLineSize;
         NewLine;
         DrawBlackBox( Rect( 20, CurrYPos - ( CurrLineSize div 5), 2000, CurrYPos + CurrLineSize + (CurrLineSize div 5)));
         RenderText( 'Fuel tax calculation worksheet',
                     Rect( 40, CurrYPos, 1950, CurrYPos + CurrLineSize),
                     jtLeft);
         NewLine;

         BasCanvas.Font.Color := clBlack;
         BasCanvas.Brush.Color := clWhite;
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size  := 8;

         DrawBox( Rect( 20, CurrYPos, 950, CurrYPos + CurrLineSize + 10));
         if not IsAnnualStatement then
            S := BasUtils.DatesCaption( GSTFromDate, GSTToDate)
         else
            S := AnnualDatesCaption;

         RenderText( S,
                     Rect( 40, CurrYPos, 950, CurrYPos + CurrLineSize),
                     jtLeft);

         BasCanvas.Font.Size  := 6;
         if Figures.iIsFuelPercentMethod then
           RenderText( 'Calculation Method: Representative percentage',
                     Rect( 1000, CurrYPos, 1950, CurrYPos + CurrLineSize),
                     jtLeft)
         else
           RenderText( 'Calculation Method: Eligible fuel (litres)',
                     Rect( 1000, CurrYPos, 1950, CurrYPos + CurrLineSize),
                     jtLeft);
         BasCanvas.Font.Size  := 8;
         NewLine(3);

         // output grid
         Total := 0;
         BasCanvas.Font.Size := 6;
         BasCanvas.Font.Style := [fsbold];
         Top := 300;
         CurrXPos := 1;
         RenderTextWrapped('Account', Rect(CurrXPos, Top, CurrXPos + colCodeWidth, Top + (CurrLineSize * 4)),jtLeft);
         CurrXPos := CurrXPos + colCodeWidth;
         RenderTextWrapped('Account description', Rect(CurrXPos + 1, Top, CurrXPos + colDescWidth, Top + (CurrLineSize * 4)),jtLeft);
         CurrXPos := CurrXPos + colDescWidth;
         RenderTextWrapped('Eligible fuel~type', Rect(CurrXPos + 1, Top, CurrXPos + colTypeWidth, Top + (CurrLineSize * 4)),jtLeft);
         CurrXPos := CurrXPos + colTypeWidth;
         RenderTextWrapped('Total fuel~acquisitions~(litres)', Rect(CurrXPos + 1, Top, CurrXPos + colLitresWidth, Top + (CurrLineSize * 4)),jtLeft);
         CurrXPos := CurrXPos + colLitresWidth;
         RenderTextWrapped('Business fuel use', Rect(CurrXPos + 1, Top, CurrXPos + colUseWidth, Top + (CurrLineSize * 4)),jtLeft);
         CurrXPos := CurrXPos + colUseWidth;
         RenderTextWrapped('Representative~percentage~(%)', Rect(CurrXPos + 1, Top, CurrXPos + colPercentWidth, Top + (CurrLineSize * 4)),jtLeft);
         CurrXPos := CurrXPos + colPercentWidth;
         RenderTextWrapped('Total business~use of eligible~fuel (litres)', Rect(CurrXPos + 1, Top, CurrXPos + colEligibleWidth, Top + (CurrLineSize * 4)),jtLeft);
         CurrXPos := CurrXPos + colEligibleWidth;
         RenderTextWrapped('Credit rate~(cents per~litre)', Rect(CurrXPos + 1, Top, CurrXPos + colRateWidth, Top + (CurrLineSize * 4)),jtLeft);
         CurrXPos := CurrXPos + colRateWidth;
         RenderTextWrapped('Fuel tax~credit amount~($)', Rect(CurrXPos + 1, Top, CurrXPos + colTotalWidth, Top + (CurrLineSize * 4)),jtLeft);
         Top := Top + (CurrLineSize div 2);
         BasCanvas.Font.Style := [];
         BasCanvas.Font.Size := 8;
         for i := 0 to Pred(FuelSheet.Rows) do
         begin
           FuelRow := i + 1;
           
           if (FuelSheet.Cell[colCode, FuelRow] <> '') or (FuelSheet.Cell[colTotal, FuelRow] <> '') then
           begin
             CurrXPos := 1;
             RenderText(FuelSheet.Cell[colCode, FuelRow], Rect(CurrXPos, Top, CurrXPos + colCodeWidth, Top + (CurrLineSize * 4)),jtLeft);
             CurrXPos := CurrXPos + colCodeWidth;
             RenderText(FuelSheet.Cell[colDesc, FuelRow], Rect(CurrXPos + 1, Top, CurrXPos + colDescWidth, Top + (CurrLineSize * 4)),jtLeft);
             CurrXPos := CurrXPos + colDescWidth;
             RenderText(FuelSheet.Cell[colType, FuelRow], Rect(CurrXPos + 1, Top, CurrXPos + colTypeWidth, Top + (CurrLineSize * 4)),jtLeft);
             CurrXPos := CurrXPos + colTypeWidth;
             RenderText(FuelSheet.Cell[colLitres, FuelRow], Rect(CurrXPos + 1, Top, CurrXPos + colLitresWidth, Top + (CurrLineSize * 4)),jtLeft);
             CurrXPos := CurrXPos + colLitresWidth;
             RenderText(FuelSheet.Cell[colUse, FuelRow], Rect(CurrXPos + 1, Top, CurrXPos + colUseWidth, Top + (CurrLineSize * 4)),jtLeft);
             CurrXPos := CurrXPos + colUseWidth;
             RenderText(FuelSheet.Cell[colPercent, FuelRow], Rect(CurrXPos + 1, Top, CurrXPos + colPercentWidth, Top + (CurrLineSize * 4)),jtLeft);
             CurrXPos := CurrXPos + colPercentWidth;
             RenderText(FuelSheet.Cell[colEligible, FuelRow], Rect(CurrXPos + 1, Top, CurrXPos + colEligibleWidth, Top + (CurrLineSize * 4)),jtLeft);
             CurrXPos := CurrXPos + colEligibleWidth;
             RenderText(FuelSheet.Cell[colRate, FuelRow], Rect(CurrXPos + 1, Top, CurrXPos + colRateWidth, Top + (CurrLineSize * 4)),jtLeft);
             CurrXPos := CurrXPos + colRateWidth;
             RenderText(FuelSheet.Cell[colTotal, FuelRow], Rect(CurrXPos + 1, Top, CurrXPos + colTotalWidth, Top + (CurrLineSize * 4)),jtLeft);
             if FuelSheet.Cell[colTotal, FuelRow] <> '' then
               Total := Total + FuelSheet.Cell[colTotal, FuelRow];
             Top := Top + CurrLineSize + 2;
           end;
         end;
         BasCanvas.Font.Style := [ fsBold];
         BasCanvas.Font.Size  := 10;
         RenderText('Total (copied to 7D)  $' + MyRoundTo(Trunc( Total), 0), Rect(1, Top, 1930, Top + (CurrLineSize * 4)), jtRight);
      end;
   end; // with figures

   //Was printed is set here so that it will pickup the document being printed
   //even if the user selected preview first, and then selected print from the
   //preview screen
   wasPrinted := ( Self.OriginalDestination = rdFile) or ( CanvasRenderEng.OutputBuilder.CurrentDestination = 0);    //0 = printer; 1 = screen
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.DrawBox(XYRect: TRect);
//accepts a rect of 0.1mm parameters.  Adds the offset for left,top margin
var
  wasColor : TColor;
begin
    with CanvasRenderEng.OutputBuilder do begin
       //apply offset for left,top margins
       with XYRect do begin
          Inc( Left, OutputAreaLeft);
          Inc( Right, OutputAreaLeft);
          Inc( Top, OutputAreaTop);
          Inc( Bottom, OutputAreaTop);
       end;
       //convert from 0.1mm to pixels
       with XYRect do begin
          TopLeft     := ConvertToDC( TopLeft);
          BottomRight := ConvertToDC( BottomRight);
       end;        { with }
    end;
    with CanvasRenderEng.OutputBuilder.Canvas do begin
       //render box
       wasColor := Brush.Color;
       Brush.Color := clBlack;
       FrameRect(XYRect);
       Brush.Color := wasColor;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.DrawBlackBox(XYRect: TRect);
//accepts a rect of 0.1mm parameters.  Adds the offset for left,top margin
var
  wasBrushColor : TColor;
  wasPenColor   : TColor;
begin
    with CanvasRenderEng.OutputBuilder do begin
       //apply offset for left,top margins
       with XYRect do begin
          Inc( Left, OutputAreaLeft);
          Inc( Right, OutputAreaLeft);
          Inc( Top, OutputAreaTop);
          Inc( Bottom, OutputAreaTop);
       end;
       //convert from 0.1mm to pixels
       with XYRect do begin
          TopLeft     := ConvertToDC( TopLeft);
          BottomRight := ConvertToDC( BottomRight);
       end;        { with }
    end;
    with CanvasRenderEng.OutputBuilder.Canvas do begin
       //render box
       wasBrushColor := Brush.Color;
       wasPenColor   := Pen.Color;

       Brush.Color := clBlack;
       Pen.Color   := clBlack;

       FillRect(XYRect);

       Brush.Color := wasBrushColor;
       Pen.Color   := wasPenColor;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBASReport.GetCurrLineSize: integer;
const
   //line size inflation allows for a gap between each line.  Height of text alone
   //would not give us any spacing

   //**************  The line size returned by windows NT 4,5 seems to be different
   //                to Window 9x.  Quick fix is to remove the inflation factor as this
   //                does not seem to be needed.  More investigation needed.

   LINE_SIZE_INFLATION = 1.1;
begin
   if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then
      result := Round(CanvasRenderEng.OutputBuilder.HeightOfText('Ay'))
   else
      result := Round(CanvasRenderEng.OutputBuilder.HeightOfText('Ay') * LINE_SIZE_INFLATION);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoBASReport(Destination: TReportDest; BasValues: TBasInfo; Fuel: TtsGrid;
                        Params: TRptParameters = nil) : boolean;
//returns true if the report was printed
var
   Job : TBASReport;
begin
   result := false;
   if not assigned(BasValues) then exit;
   Job := TBASReport.Create(RptGST);
   try
     Job.ReportTypeParams.ClearUserHeaderFooter;
     Job.WasPrinted := false;
     Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_BAS]);
     Job.Figures := BasValues;
     Job.FuelSheet := Fuel;
     Job.FileFormats := [ffPDF, ffAcclipse];

     AddCommonFooter(Job);

     if Destination in [rdScreen, rdPrinter, rdFile] then
        Job.Generate(Destination, Params);

     if Assigned(Params) then
     if Params.BatchRunMode = R_Batch then
        Job.WasPrinted := true;

     Result := Job.WasPrinted;
   finally
    Job.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.NewLine;
begin
   CurrYPos := CurrYPos + CurrLineSize;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.NewLine(Count: integer);
begin
   CurrYPos := CurrYPos + CurrLineSize *  Count;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.RenderText(textValue: string; textRect: TRect; Justify: TJustifyType);
{Canvas Font should be set before rendering text}
{Canvas color will be changed to render sytle and then reset}
//Will add the print offsets for margins
//Accepts values in 0.1mm units, converts to device coordinates for output
var
   RenderRect : TRect;
   pixTextWidth, pixTextHeight : longint;
   wasColor   : TColor;
   wasFColor  : TColor;
begin
   {process the text value looking for special markers}
   if TextValue = SKIPFIELD then exit;

   with CanvasRenderEng.OutputBuilder do
   begin
       //apply offset for left,top margins
       with TextRect do begin
          Inc( Left, OutputAreaLeft);
          Inc( Right, OutputAreaLeft);
          Inc( Top, OutputAreaTop);
          Inc( Bottom, OutputAreaTop);
       end;

       {convert from 0.1mm to pixels}
       with TextRect do begin
          TopLeft     := ConvertToDC( TopLeft);
          BottomRight := ConvertToDC( BottomRight);
       end;        { with }
       //Text Rect is now in pixels

       //Check Height of text
       pixTextWidth := Canvas.TextWidth(textValue);  //in pixels
       pixTextHeight := Canvas.TextHeight(textValue) -1; //in pixels, 1 pixel is remove to cope with
                                                         //rounding errors in the CurrLineSize value

       {first sort out top and bottom}
       if pixTextHeight >= (textRect.Bottom - textRect.Top) then begin
          //Height of text is bigger than box so use top
          RenderRect.Top := textRect.Top;
          RenderRect.Bottom := textRect.Bottom;
       end
       else begin
          RenderRect.Top := textRect.Top + ((textRect.Bottom - textRect.top) - pixTextHeight);
          RenderRect.Bottom := textRect.Bottom;
       end;

       {now sortout left right}
       if pixTextWidth >= (textRect.Right - textRect.Left) then  begin
          //width is greater than box so use left
          RenderRect.Left := textRect.Left;
          RenderRect.Right  := textRect.Right;
       end
       else begin
          case Ord(Justify) of
             Ord(jtLeft): begin
                RenderRect.left := textRect.Left;
                RenderRect.Right := RenderRect.Left + pixTextWidth;
             end;
             ord(jtCenter): begin
                RenderRect.Left := textRect.Left + (textRect.Right - textRect.Left) div 2 - pixTextWidth div 2;
                RenderRect.Right := RenderRect.Left + pixTextWidth;
             end;
             ord(jtRight): begin
                RenderRect.Right := textRect.Right;
                RenderRect.Left := RenderRect.Right - pixTextWidth;
             end;
          end;        { case }
       end;             { begin}

       {Store Current Brush Color}
       wasColor := Canvas.Brush.Color;
       wasFColor := Canvas.Font.Color;
       Canvas.TextRect(RenderRect,RenderRect.Left, RenderRect.top, textValue);
       //Debug Code Only
       //Canvas.Brush.Color := clBlack;
       //Canvas.FrameRect( RenderRect);

       Canvas.Brush.Color := wasColor;
       Canvas.Font.Color  := wasFColor;
   end;        { with }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.RenderBasBox(Title : string; BoxID : string; Value: Double;
                                  Location : integer; ExText : string;
                                  var WrappedLines : integer);
var
   TextL            : integer;
   TextR            : integer;
   IDTextR          : integer;
   CurTextR         : integer;
   AmtTextR         : integer;
   XTextR           : integer;
   EndYPos          : integer;
   CenterYPos       : integer;
begin
   XTextR := 0;
   case Location of
      1 : begin //Left
         TextL            := ColLeftText;
         TextR            := ColLeftTextRight;
         IDTextR          := ColLeftIDTextRight;
         CurTextR         := ColLeftCurTextRight;
         AmtTextR         := ColLeftAmtTextRight;
      end;
      2 : begin //Right
         TextL            := ColRightTextLeft;
         TextR            := ColRightTextRight;
         IDTextR          := ColRightIDTextRight;
         CurTextR         := ColRightCurTextRight;
         AmtTextR         := ColRightAmtTextRight;
      end;
      3 : begin //Center
         TextL            := ColCenterTextLeft;
         TextR            := ColCenterTextRight;
         IDTextR          := ColCenterIDTextRight;
         CurTextR         := ColCenterCurTextRight;
         AmtTextR         := ColCenterAmtTextRight;
         XTextR           := ColCenterXTextRight;
      end;
      else begin
         //shouldn't ever get here but include so that dont see warnings
         TextL            := 0;
         TextR            := 0;
         IDTextR          := 0;
         CurTextR         := 0;
         AmtTextR         := 0;
         XTextR           := 0;
      end;
   end;

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];
   CanvasRenderEng.OutputBuilder.Canvas.font.Size := UserReportSettings.s7Base_Font_Size;
   CurrLineSize := GetCurrLineSize;
   WrappedLines := RenderTextWrapped(Title, Rect(TextL, CurrYPos, TextR, CurrYPos + CurrLineSize), jtRight);
   EndYPos      := CurrYPos + ( CurrLineSize * WrappedLines);

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsBold];
   CanvasRenderEng.OutputBuilder.Canvas.font.Size := 11;
   CurrLineSize := GetCurrLineSize;
   CenterYPos   := ((CurrYPos + EndYPos) div 2) - (CurrLineSize div 2);
   RenderText(BoxID, Rect(TextR, CenterYPos, IDTextR, CenterYPos + CurrLineSize), jtCenter);
   RenderText('$',Rect(IDTextR, CenterYPos, CurTextR, CenterYPos + CurrLineSize), jtCenter);

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];
   RenderText(FormatFloat('#,##0;(#,##0)', Value), Rect(CurTextR, CenterYPos, AmtTextR, CenterYPos + CurrLineSize), jtRight);
   DrawBox( Rect(CurTextR, CenterYPos-10, AmtTextR + Gap, CenterYPos + CurrLineSize {- 5}));

   if Location = 3 then begin
      CanvasRenderEng.OutputBuilder.Canvas.font.Size := UserReportSettings.s7Base_Font_Size;
      CurrLineSize := GetCurrLineSize;
      RenderTextWrapped(ExText, Rect(AmtTextR+15, CurrYPos, XTextR, CurrYPos + (CurrLineSize * WrappedLines)), jtLeft);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBASReport.RenderTextWrapped(text : string; aRect : TRect; Justify: TJustifyType) : integer;
//accepts parameters in 0.1mm units
var
   SList        : TStringList;
   i            : integer;
   SizeRect     : TRect;
   s            : string;
   CurrCaption  : string;
begin
   SList := TStringList.Create;
   try
     {split into individual lines, not split takes pixel measurements}
     SizeRect := XYSizeRect(aRect.left, aRect.top, aRect.Right, aRect.bottom);
     s := text;
     //seperate into individual lines
     while Pos( LineSeperatorChar, s ) > 0 do begin
        CurrCaption := Copy( s, 0, Pos( LineSeperatorChar, s) -1);
        if CurrCaption <> '' then
           SList.Add( CurrCaption);
        s := Copy(s, Pos( LineSeperatorChar, s) +1, Length(s));
     end;
     //Add remaining line once no seperators found
     if s <> '' then SList.Add( s);
     //Set caption values, look for bold tag and/or Italic tag
     for i := 0 to Pred( SList.Count ) do begin
        CurrCaption := SList[i];
        if (Pos( BoldTag, CurrCaption) > 0) or (Pos( ItalicTag, CurrCaption) > 0) then begin
           if (Pos( ItalicTag, CurrCaption) > 0) and (Pos( BoldTag, CurrCaption) > 0) then begin
              CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsItalic, fsBold];
              if Pos( ItalicTag, CurrCaption) > 0 then begin
                 CurrCaption  := Copy( CurrCaption, Length( ItalicTag) +1, length( CurrCaption ) );
              end;
              if Pos( BoldTag, CurrCaption) > 0 then begin
                 CurrCaption  := Copy( CurrCaption, Length( BoldTag) +1, length( CurrCaption ) );
              end;
           end
           else if (Pos( BoldTag, CurrCaption) > 0) and (Pos( ItalicTag, CurrCaption) = 0) then begin
              CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsBold];
              CurrCaption  := Copy( CurrCaption, Length( BoldTag) +1, length( CurrCaption ) );
           end
           else if (Pos( ItalicTag, CurrCaption) > 0) and (Pos( BoldTag, CurrCaption) = 0) then begin
              CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsItalic];
              CurrCaption  := Copy( CurrCaption, Length( ItalicTag) +1, length( CurrCaption ) );
           end;
        end
        else begin
           CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];
        end;
        RenderText(CurrCaption, Rect(aRect.Left, aRect.top, aRect.Right, aRect.top + ( (i+1) * CurrLineSize ) ), Justify);
     end;
     result := SList.Count;
   finally
     SList.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.RenderLine(x, y, width: integer);
begin
   with CanvasRenderEng.OutputBuilder do begin
      //add margin offsets
      Inc( x, OutputAreaLeft);
      Inc( y, OutputAreaTop);
      Canvas.Polyline([ ConvertToDC( Point(x,y)),ConvertToDC( Point(x+width,y))]);
   end;        { with }
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBASReport.XYSizeRect(ALeft, ATop, ARight,
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
function TBASReport.GetCanvasRE: TRenderToCanvasEng;
begin
   result := TRenderToCanvasEng( RenderEngine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBASReport.RenderOtherBasBox(Title, BoxID: string; Value: Double;
  DollarSign: Boolean; BoxNumber: integer; ExText: string;
  var WrappedLines: integer);
//This procedure is used for Box fields in Panel 6, T1-T4, and F4 in Panel 7
var
   TextL            : integer;
   TextR            : integer;
   IDTextR          : integer;
   CurTextR         : integer;
   AmtTextR         : integer;
   XTextR           : integer;
   EndYPos          : integer;
   CenterYPos       : integer;
   DollarChar       : string;
   FormatChar       : string;
begin
   DollarChar := '$';
   FormatChar := '#,##0;(#,##0)';
   xTextR     := 0;
   case BoxNumber of
      2,3 : begin //T2, T3 option 3
         TextL            := ColRightTextLeft;
         TextR            := ColRightTextRight;
         IDTextR          := ColRightIDTextRight;
         CurTextR         := ColRightCurTextRight;
         AmtTextR         := ColT2T3AmtRight;
         XTextR           := ColT2T3XRight;
         FormatChar       := '#,##0.00;(#,##0.00)';
      end;
      4 : begin //T4, opt 1
         TextL            := ColLeftText;
         TextR            := ColLeftTextRight;
         IDTextR          := ColLeftIDTextRight;
         CurTextR         := ColLeftCurTextRight;
         AmtTextR         := ColT41AmtRight;
      end;
      5 : begin //F4
         TextL            := ColRightTextLeft;
         TextR            := ColRightTextRight;
         IDTextR          := ColRightIDTextRight;
         CurTextR         := ColRightCurTextRight;
         AmtTextR         := ColF4AmtRight;
         DollarChar       := '';
      end;
      6 : begin //T4 Option 2
         TextL            := ColRightTextLeft;
         TextR            := ColRightTextRight;
         IDTextR          := ColRightIDTextRight;
         CurTextR         := ColRightCurTextRight;
         AmtTextR         := ColT42AmtRight;
         DollarChar       := '';
      end;
      else begin
         TextL            := 0;
         TextR            := 0;
         IDTextR          := 0;
         CurTextR         := 0;
         AmtTextR         := 0;
         XTextR           := 0;
      end;
   end;

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];
   CanvasRenderEng.OutputBuilder.Canvas.font.Size := UserReportSettings.s7Base_Font_Size;
   CurrLineSize := GetCurrLineSize;
   WrappedLines := RenderTextWrapped(Title, Rect(TextL, CurrYPos, TextR, CurrYPos + CurrLineSize), jtRight);
   EndYPos      := CurrYPos + CurrLineSize * WrappedLines;

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsBold];
   CanvasRenderEng.OutputBuilder.Canvas.font.Size := 11;
   CurrLineSize := GetCurrLineSize;
   CenterYPos   := ((CurrYPos + EndYPos) div 2) - (CurrLineSize div 2);
   RenderText(BoxID, Rect(TextR, CenterYPos, IDTextR, CenterYPos + CurrLineSize), jtCenter);

   if DollarSign then
      RenderText(DollarChar, Rect(IDTextR, CenterYPos, CurTextR, CenterYPos + CurrLineSize), jtCenter);

   CanvasRenderEng.OutputBuilder.Canvas.font.Style := [];
   RenderText(FormatFloat(FormatChar, Value), Rect(CurTextR, CenterYPos, AmtTextR, CenterYPos + CurrLineSize), jtRight);
   DrawBox( Rect(CurTextR, CenterYPos-10, AmtTextR + Gap, CenterYPos + CurrLineSize ));

   if (BoxNumber = 2) or (BoxNumber = 3) then begin
      CanvasRenderEng.OutputBuilder.Canvas.font.Style := [fsBold];
      RenderText(ExText, Rect(AmtTextR+5, CenterYPos, XTextR, CenterYPos + CurrLineSize), jtCenter);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DoBasSummary(Destination: TReportDest; BasValues: TBasInfo;
                      Params: TRptParameters = nil) : boolean;
//- - - - - - - - - - - - - - - - - - - -
//
// Purpose:     Produces a summary bas or ias report without the ATO formating
//
// Parameters:  Destination  - where is the report going
//              BasValue     - details of all fields in the bas/ias
//
//- - - - - - - - - - - - - - - - - - - -
var
  Job : TBASSummaryReport;
  CLeft, CGap : double;
  s : string;
begin
   result := false;
   if not assigned(BasValues) then
     exit;

   if not (Destination in [rdScreen, rdPrinter, rdFile]) then
     Exit;

   Job := TBASSummaryReport.Create(rptGST);
   try
     Job.ReportTypeParams.ClearUserHeaderFooter;
     Job.WasPrinted := false;
     Job.LoadReportSettings(UserPrintSettings,Report_List_Names[REPORT_BASSUMMARY]);
     Job.Figures := BasValues;


     //Add Columns: Job,Left Percent, Width Percent, Caption, Alignment
     CLeft := Gcleft;
     CGap  := GcGap;

     //Add Headers
     AddCommonHeader(Job);

     if BasUtils.IsBASForm( BasValues.BasFormType) then
        S := 'Business Activity Statement'
     else
        S :='Instalment Activity Statement';

     if BasValues.BasFormType in [bsH, bsBasZ] then
        S := 'Annual GST return';

     if BasValues.BasFormType = bsK then
        S := 'Annual GST information report';

     AddJobHeader(Job,siTitle, S,true);

     AddColAuto(Job,cleft, 35 ,cGap,'', jtRight);
     AddFormatColAuto(Job, cLeft, 15 , cGap, '',jtRight,BAS_SUMMARY_FORMAT,BAS_SUMMARY_FORMAT,true);
     AddColAuto(Job,cleft, 20 ,cGap,'', jtRight);
     AddFormatColAuto(Job, cLeft, 15 , cGap, '',jtRight,BAS_SUMMARY_FORMAT,BAS_SUMMARY_FORMAT,true);

     //Add Footers
     AddCommonFooter(Job);

     Job.Generate(Destination, Params);

     result := Job.WasPrinted;
   finally
    Job.Free;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{ TBASSummaryReport }
procedure TBASSummaryReport.BKPrint;
//- - - - - - - - - - - - - - - - - - - -
//
// Purpose:     Prints the Summary report
//
// Parameters:  None, All parameters are defined within report object
//
//- - - - - - - - - - - - - - - - - - - -
var
   S, S2 : string;
   GSTOption1Visible,
   GSTOption2Visible,
   GSTOption3Visible,
   GSTVisible        : boolean;
   PAYG_W_Visible    : boolean;
   FBT_Visible       : boolean;
   PAYG_I_Visible    : boolean;
   PAYG_IOpt1_Visible,
   PAYG_IOpt2_Visible,
   PAYG_IOpt3_Visible : boolean;
   Summary_Visible    : boolean;

   d1,m1,y1, d2, m2, y2 : integer;
   AnnualDatesCaption : string;
begin
   AnnualDatesCaption := '';

   with figures do
   begin
      if BasUtils.IsBASForm( BasFormType) then
         S := 'Business Activity Statement'
      else
         S :='Instalment Activity Statement';

      if BasFormType in [bsH, bsBasZ] then
         S := 'Annual GST return';

      if BasFormType = bsK then
         S := 'Annual GST information report';

      StDateToDMY( BasFromDate, d1, m1, y1);
      StDatetoDMY( BasToDate, d2, m2, y2);
      if ( y1 = y2) then
      begin
         //same year
         S2 := moNames[ m1] + ' to ' + moNames[ m2] + ' ' + inttostr( y2);
      end
      else
      begin
         S2 := moNames[ m1] + ' ' + inttostr( y1) + ' to ' +
                      moNames[ m2] + ' ' + inttostr( y2);
      end;
      RenderTitleLine( S + '  ' + S2);
      AnnualDatesCaption := S2;

      RenderLine( 'Form', bsNames[ Figures.BasFormType]);
      RenderLine( 'Document ID ', DocumentID);
      RenderLine( 'ABN ', Trim( ABN + ' ' + ABN_Extra));
      RenderLine( 'Form Due on ', bkDate2Str( PaymentDate));

      if MyClient.clFields.clGST_Basis in [ gbMin..gbMax] then
         S := gbaNames[ MyClient.clFields.clGST_Basis]
      else
         S := '';
      RenderLine( 'GST accounting method ', S);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// GST Panel
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

      GSTOption1Visible           := FieldVisible( bfG1,  BasFormType) or
                                     FieldVisible( bfG2,  BasFormType) or
                                     FieldVisible( bfG3,  BasFormType) or
                                     FieldVisible( bfG10, BasFormType) or
                                     FieldVisible( bfG11, BasFormType);

      GSTOption2Visible           := FieldVisible( bfGSTOption2, BasFormType);
      GSTOption3Visible           := FieldVisible( bfGSTOption3, BasFormType) or
                                     FieldVisible( bfG21, BasFormType, iG21_ATOInstalment) or
                                     FieldVisible( bfG22, BasFormType, iG22_EstimatedNetGST) or
                                     FieldVisible( bfG23, BasFormType, iG23_VariedAmount);

      //see if we were expecting option 3
      if GSTOption3Visible and ( not FieldVisible( bfGSTOption3, BasFormType)) then begin
         //would not normally see option 3, so display opt 1 and 2 to allow user to change
         GSTOption1Visible    := true;
         GSTOption2Visible    := true;
      end;

      //see if should show tab
      GSTVisible              := GSTOption1Visible or GSTOption3Visible;

      if GSTVisible then
      begin
        if not IsAnnualStatement then
            S := BasUtils.DatesCaption( GSTFromDate, GSTToDate)
         else
            S := AnnualDatesCaption;

        RenderTitleLine( 'Goods and services tax (GST)' + S);

        if GSTOption1Visible and (iGSTOptionUsed = 1) then
        begin
          RenderTextLine( bfNames[ bfGSTOption1]);

          RenderLine( bfFieldIDs[ bfG1], iIncome_G1);
          if bG1IncludesGST then
            S := 'YES'
          else
            S := 'NO';
          RenderLine( bfNames[ bfG1IncludesGST], S);
          RenderTextLine('');

          RenderLine( bfFieldIDs[ bfG2], iExports_G2);
          RenderLine( bfFieldIDs[ bfG3], iGSTFreeSupplies_G3);
          RenderLine( bfFieldIDs[ bfG10], iCapitalAcq_G10);
          RenderLine( bfFieldIDs[ bfG11], iOtherAcq_G11);
        end;

        if GSTOption2Visible and ( iGSTOptionUsed = 2) then
        begin
          RenderTextLine( bfNames[ bfGSTOption2]);

          RenderLine( bfFieldIDs[ bfG1], iIncome_G1);
          if bG1IncludesGST then
            S := 'YES'
          else
            S := 'NO';
          RenderLine( bfNames[ bfG2IncludesGST], S);
        end;

        if GSTOption3Visible and ( iGSTOptionUsed = 3) then
        begin
          RenderTextLine( bfNames[ bfGSTOption3]);

          RenderLine( bfFieldIDs[ bfG21], iG21_ATOInstalment);
          RenderLine( bfFieldIDs[ bfG22], iG22_EstimatedNetGST);
          RenderLine( bfFieldIDs[ bfG23], iG23_VariedAmount);
          RenderLine( bfFieldIDs[ bfG24], InttoStr( iG24_ReasonVar));
        end;
      end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// PAYG Instalments
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      PAYG_IOpt1_Visible      := FieldVisible( bfPAYGOption1, BasFormType) or
                              FieldVisible( bfT7, BasFormType, iT7_ATOInstalment) or
                              FieldVisible( bfT8, BasFormType, iT8_EstimatedTax) or
                              FieldVisible( bfT9, BasFormType, iT9_VariedAmount);

      PAYG_IOpt2_Visible      := FieldVisible( bfPAYGOption2, BasFormType) or
                              FieldVisible( bfT1, BasFormType, iTaxInstalmIncome_T1) or
                              FieldVisible( bfT11, BasFormType, iT11_T1x_T2orT3);

      PAYG_IOpt3_Visible      := (FieldVisible( bfPAYGOption3, BasFormType) or
                              FieldVisible( bfT6, BasFormType, iTaxInstalmIncome_T1))
                              and (BasFormType = bsIASN);
      PAYG_I_Visible          := PAYG_IOpt1_Visible or PAYG_IOpt2_Visible or PAYG_IOpt3_Visible;

      if PAYG_I_Visible then
      begin
        RenderTitleLine( 'PAYG income tax instalment ' + DatesCaption( PAYG_I_FromDate, PAYG_I_ToDate));

        if PAYG_IOpt3_Visible then
          RenderLine( bfFieldIDs[ bfT5], iBAST5);

        if PAYG_IOpt3_Visible and ( iPAYGInstalmentOptionUsed = 3) then
        begin
          RenderTextLine( bfNames[ bfPAYGOption3]);

          RenderLine( bfFieldIDs[ bfT6], iT6_VariedAmount);
          RenderLine( bfFieldIDs[ bfT4], inttostr( iTaxReasonVar_T4));
        end;

        if PAYG_IOpt1_Visible and ( iPAYGInstalmentOptionUsed = 1) then
        begin
          RenderTextLine( bfNames[ bfPAYGOption1]);

          RenderLine( bfFieldIDs[ bfT7], iT7_ATOInstalment);
          RenderLine( bfFieldIDs[ bfT8], iT8_EstimatedTax);
          RenderLine( bfFieldIDs[ bfT9], iT9_VariedAmount);
          RenderLine( bfFieldIDs[ bfT4], inttostr( iTaxReasonVar_T4));
        end;

        if PAYG_IOpt2_Visible and ( iPAYGInstalmentOptionUsed = 2) then
        begin
          RenderTextLine( bfNames[ bfpaygOption2]);

          RenderLine( bfFieldIDs[ bfT1], iTaxInstalmIncome_T1);
          RenderLine( bfFieldIDs[ bfT2], FormatFloat( '#,##0.00;(#,##0.00)', dTaxInstalmRate_T2));
          if not PAYG_IOpt3_Visible then
            RenderLine( bfFieldIDs[ bfT3], FormatFloat( '#,##0.00;(#,##0.00)', dTaxVarInstalmRate_T3));
          RenderLine( bfFieldIDs[ bfT11], iT11_T1x_T2orT3);
          if not PAYG_IOpt3_Visible then
            RenderLine( bfFieldIDs[ bfT4], inttostr( iTaxReasonVar_T4));
        end;
      end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// PAYG Withholding and FBT
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      PAYG_W_Visible  := FieldVisible( bfW1, BasFormType, iTotalSalary_W1) or
                         FieldVisible( bfW2, BasFormType, iSalaryWithheld_W2) or
                         FieldVisible( bfW3, BasFormType, iInvstmntDist_W3) or
                         FieldVisible( bfW4, BasFormType, iInvoicePymt_W4);

      FBT_Visible     := FieldVisible( bfF1, BasFormType, iFBTInstalm_F1) or
                         FieldVisible( bfF2, BasFormType, iFBTTotalPayable_F2) or
                         FieldVisible( bfF3, BasFormType, iFBTVariedInstalm_F3);

      if PAYG_W_Visible then
      begin
        RenderTitleLine( 'PAYG tax withheld ' + DatesCaption( PAYG_W_FromDate, PAYG_W_ToDate));

        RenderLine( bfFieldIDs[ bfW1], iTotalSalary_W1);
        RenderLine( bfFieldIDs[ bfW2], iSalaryWithheld_W2);
        RenderLine( bfFieldIDs[ bfW4], iInvoicePymt_W4);
        RenderLine( bfFieldIDs[ bfW3], iInvstmntDist_W3);
        RenderLine( bfFieldIDs[ bfW5], iW5_TotalAmountsWithheld);
      end;

      if FBT_Visible then
      begin
        RenderTitleLine( 'Fringe benefits tax (FBT) instalment' + DatesCaption( FBT_FromDate, FBT_ToDate));

        RenderLine( bfFieldIDs[ bfF1], iFBTInstalm_F1);
        RenderLine( bfFieldIDs[ bfF2], iFBTTotalPayable_F2);
        RenderLine( bfFieldIDs[ bfF3], iFBTVariedInstalm_F3);
        RenderLine( bfFieldIDs[ bfF4], IntToStr( iFBTReasonVar_F4));
      end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Worksheet
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if not ( BasUtils.IsIASForm( BasFormType)) then
      begin
        if not IsAnnualStatement then
            S := BasUtils.DatesCaption( GSTFromDate, GSTToDate)
         else
            S := AnnualDatesCaption;

        RenderTitleLine( 'Worksheet ' + S);

        RenderTwoColumn( bfFieldIDs[ bfG1], iIncome_G1,           bfFieldIDs[ bfG10], iCapitalAcq_G10);
        RenderTwoColumn( bfFieldIDs[ bfG2], iExports_G2,          bfFieldIDs[ bfg11], iOtherAcq_G11);
        RenderTwoColumn( bfFieldIDs[ bfG3], iGSTFreeSupplies_G3,  bfFieldIDs[ bfG12], iTotalAcq_G12);
        RenderTwoColumn( bfFieldIDs[ bfG4], iInputTaxedSales_G4,  bfFieldIDs[ bfG13], iAcqInputTaxedSales_G13);
        RenderTwoColumn( bfFieldIDs[ bfG5], iTotalGSTFree_G5,     bfFieldIDs[ bfG14], iAcqNoGST_G14);
        RenderTwoColumn( bfFieldIDs[ bfG6], iTotalTaxableSupp_G6, bfFieldIDs[ bfG15], iEstPrivateUse_G15);
        RenderTwoColumn( bfFieldIDs[ bfG7], iIncAdjustments_G7,   bfFieldIDs[ bfG16], iTotalNonCreditAcq_G16);
        RenderTwoColumn( bfFieldIDs[ bfG8], iTotalTaxSuppAdj_G8,  bfFieldIDs[ bfG17], iTotalCreditAcq_G17);
        RenderTWoColumn( bfFieldIDs[ bfG9], iGSTPayable_G9,       bfFieldIDs[ bfG18], iAcqAdjustments_G18);
        RenderTwoColumn( '', 0,                                   bfFieldIDs[ bfG19], iTotalCreditAcqAdj_G19);
        RenderTwoColumn( '', 0,                                   bfFieldIDs[ bfG20], iGSTCredit_G20);
      end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Summary
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      Summary_Visible := FieldVisible( bf1a, BasFormType, iGSTPayable_1A) or
                     FieldVisible( bf1b, BasFormType, iGSTCredit_1B) or
                     FieldVisible( bf1c, BasFormType, iWineEqlPayable_1C) or
                     FieldVisible( bf1d, BasFormType, iWineEqlRefund_1D) or
                     FieldVisible( bf1e, BasFormType, iLuxCarPayable_1E) or
                     FieldVisible( bf1f, BasFormType, iLuxCarRefund_1F) or
                     FieldVisible( bf1g, BasFormType, iSalesTaxCredit_1G) or
                     FieldVisible( bf1h, BasFormType, i1H_GSTInstalment) or
                     FieldVisible( bf2a, BasFormType) or
                     FieldVisible( bf2b, BasFormType) or
                     FieldVisible( bf4,  basFormType, iTotalWithheld_4) or
                     FieldVisible( bf5a, BasFormType, iIncomeTaxInstalm_5A) or
                     FieldVisible( bf5b, BasFormType, iCrAdjPrevIncome_5B) or
                     FieldVisible( bf6a, BasFormType, iFBTInstalm_6A) or
                     FieldVisible( bf6b, BasFormType, iVariationCr_6B) or
                     FieldVisible( bf7,  BasFormType, iDeferredInstalm_7) or
                     FieldVisible( bf7c, BasFormType) or
                     FieldVisible( bf7d, BasFormType) or
                     FieldVisible( bf8a, BasFormType) or
                     FieldVisible( bf8b, BasFormType);

      if Summary_Visible then
      begin
        RenderTitleLine( 'Summary');

        RenderSummaryLine( bf1A, iGSTPayable_1A, bf1B, iGSTCredit_1B);
        RenderSummaryLine( bf1C, iWineEqlPayable_1C, bf1D, iWineEqlRefund_1D);
        RenderSummaryLine( bf1E, iLuxCarPayable_1E, bf1F, iLuxCarRefund_1F);
        RenderSummaryLine( 0, 0, bf1H, i1H_GSTInstalment);
        RenderSummaryLine( bf2A, iTotalDebit_2A, bf2b, iTotalCredit_2B, false);  //dont check amounts
        RenderSummaryLine( bf4, iTotalWithheld_4, 0, 0);
        RenderSummaryLine( bf5A, iIncomeTaxInstalm_5A, bf5B, iCrAdjPrevIncome_5B);
        RenderSummaryLine( bf6a, iFBTInstalm_6A, bf6b, iVariationCr_6B);
        RenderSummaryLine( bf7, iDeferredInstalm_7, 0, 0);
        RenderSummaryLine( bf7c, iFuelOverClaim_7C, bf7d, iFuelCredit_7D);
        if not PAYG_IOpt3_Visible then
          RenderSummaryLine( bf8a, iTaxPayableTotal_8A, bf8b, iTaxCreditTotal_8B);

        if FieldVisible( bf9, BasFormType, iNetTaxObligation_9) and (BasFormType <> bsIASN) then
        begin
          RenderTextLine('');
          if iTaxCreditTotal_8B > iTaxPayableTotal_8A then
            S := 'Refund'
          else
            S := 'Payment';
          RenderTwoColumn( '', 0, S + '   ' + bfFieldIDs[ bf9], iNetTaxObligation_9);
        end;
      end;
   end;

   wasPrinted := ( Self.OriginalDestination = rdFile) or ( CanvasRenderEng.OutputBuilder.CurrentDestination = 0);    //0 = printer; 1 = screen
end;

procedure TBASSummaryReport.RenderLine(s1, s2: string);
begin
  PutString( S1);
  PutString( S2);
  SkipColumn;
  SkipColumn;
  RenderDetailLine;
end;

procedure TBASSummaryReport.RenderTwoColumn( s1: string; i1: Integer;
                                             s2: string; i2: Integer);
begin
  if S1 <> '' then
  begin
    PutString( S1);
    PutString( FormatFloat( BAS_SUMMARY_FORMAT, i1));
  end
  else
  begin
    SkipColumn;
    SkipColumn;
  end;

  if S2 <> '' then
  begin
    PutString( S2);
    PutString( FormatFloat( BAS_SUMMARY_FORMAT, i2));
  end
  else
  begin
    SkipColumn;
    SkipColumn;
  end;

  RenderDetailLine;
end;

procedure TBasSummaryReport.RenderSummaryLine( FieldID1 : integer; Amount1 : integer;
                                               FieldID2 : integer; Amount2 : integer;
                                               CheckAmounts : boolean = true);
//- - - - - - - - - - - - - - - - - - - -
//
// Purpose:     To determine if one or both fields should be shown in a summary line
//
// Parameters:  Form Type - Bas or Ias
//              Field1,2  - bas field identifier
//              Amount1,2 - amount
//              CheckAmounts - tells us whether to check the amount when calling
//                             fieldVisible.
//
// Result:
//- - - - - - - - - - - - - - - - - - - -
var
  S1 : string;
  S2 : string;
  i1, i2 : integer;
  v1, v2 : boolean;
begin
  s1 := '';
  s2 := '';
  i1 := 0;
  i2 := 0;

  if CheckAmounts then
  begin
    v1 := FieldVisible( FieldID1, Figures.BasFormType, Amount1);
    v2 := FieldVisible( FieldID2, Figures.BasFormType, Amount2)
  end
  else
  begin
    v1 := FieldVisible( FieldID1, Figures.BasFormType);
    v2 := FieldVisible( FieldID2, Figures.BasFormType);
  end;

  if v1 then
  begin
    s1 := bfFieldIDs[ FieldID1];
    i1 := Amount1;
  end;

  if v2 then
  begin
    s2 := bfFieldIDs[ FieldID2];
    i2 := Amount2;
  end;

  if ( s1 <> '') or ( s2 <> '') then
    RenderTwoColumn( s1, i1, s2, i2);
end;

procedure TBasSummaryReport.RenderLine( s1 : string; i1 : Integer);
begin
  PutString( S1);
  PutString( FormatFloat( BAS_SUMMARY_FORMAT, i1));
  SkipColumn;
  SkipColumn;                
  RenderDetailLine;
end;

function TBasSummaryReport.GetCanvasRE: TRenderToCanvasEng;
begin
   result := TRenderToCanvasEng( RenderEngine);
end;


end.
