//------------------------------------------------------------------------------
//  Title:   Rich Text Report bands
//
//  Written: Nov 2009
//
//  Authors: Andre' Joosten
//
//  Purpose: Creates a RTF band that can be painted as a report Header or Footer
//
//  Notes:
//------------------------------------------------------------------------------


unit RTFBands;

interface

uses
   bkqrprntr,
   BKPrintJob,
   LADefs,
   ReportTypes,
   Graphics,
   Windows,
   WPRTEDefs,
   WPRTEPaint,
   WPCTRRich,
   WPCTRMemo;

type
   TRTFBand = class(TObject)
   private
      FRTFLabel: TWPRichText;
      FText: string;
      FPageNum: Integer;
      function GetHeight: Integer;
      function GetRTFLabel: TWPRichText;
      procedure MailMergeGetText(Sender: TObject; const inspname: string; Contents: TWPMMInsertTextContents);
      procedure SetPrinterSettings(Value: TQRPrinterSettings);
   public
      constructor Create(Fromtext: string);
      destructor Destroy; override;

      property Height: Integer read GetHeight;
      function PaintSection(OnPrinter: TBKPrintJob; FromPos: Integer): Integer;
      function IsAvailable: Boolean;
      procedure SetPrintJob(Value: TBKPrintJob);
      procedure Load(FromText: string);
   end;


implementation
uses
   Printers,
   GlobalMergeFields,
   UserReportSettings,
   Forms,
   SysUtils;

{ TRTFBand }

constructor TRTFBand.Create(Fromtext: string);
begin
  inherited Create;
  FRTFLabel := nil;
  load(Fromtext)
end;

destructor TRTFBand.Destroy;
begin
  Freeandnil(FRTFLabel);
  inherited;
end;

function TRTFBand.getHeight: Integer;
var ld: Double;    // mainly for Debugging
    SectionHeightTW: Integer;
begin
   Result := 0;
   if not Assigned(FRTFLabel) then
      Exit;
   SectionHeightTW := MulDiv
       (
       FRtfLabel.Memo.PaintPageTextHeight [0] ,
       FRtfLabel.Header.PageHeight ,
       FRtfLabel.Memo.PaintPageHeight[0]
       );

   ld := WPTwipsToCentimeter(SectionHeightTW) * 100;

   Result := Round(ld);
end;


function TRTFBand.GetRTFLabel: TWPRichText;
begin
   if Assigned(FRTFLabel) then
      ClearRTF(FRTFLabel)
   else
      FRTFLabel := GetDynamicRTF;
   Result := FRTFLabel;
end;

function TRTFBand.IsAvailable: Boolean;
begin
  Result := FText > '';
end;

procedure TRTFBand.Load(Fromtext: string);
begin
   FText := Fromtext;
end;


procedure TRTFBand.MailMergeGetText(Sender: TObject; const inspname: string;
  Contents: TWPMMInsertTextContents);
begin
   if inspname = MergeFieldNames[Document_Page] then
      Contents.StringValue := IntToStr(FPagenum)
   else
      Contents.StringValue := GetGlobalMergeText(inspname);
end;

function TRTFBand.PaintSection(OnPrinter: TBKPrintJob; FromPos: Integer): Integer;
var
  lPen: tPen;
  DestXRes, DestYRes: integer;
begin
   Result := 0;
   if not Assigned(FRTFLabel) then
      Exit;
   FPageNum := OnPrinter.CurrentPageNo;

   try
      FRTFLabel.MergeText( MergeFieldNames[Document_Page] );
      FRTFLabel.Refresh;

      Result := Height;

      Frompos := Round(Frompos * OnPrinter.GetYFactor);
      lPen := TPen.Create;
      try
         // Somhow, undeline stufs up the Pen...
         lPen.Assign (OnPrinter.Canvas.Pen);

         DestXRes := 0;
         DestYRes := 0;
         //If dest is screen and ini setting PreviewDefaultPrinter=1
         if (OnPrinter.CurrentDestination = 1) and BkQrPrntr.UseDefaultPrinter then begin
           DestXRes := Screen.PixelsPerInch;
           DestYRes := Screen.PixelsPerInch;
         end;
         FRTFLabel.PaintPageOnCanvas
         (
            0, //Pagenumber
            0, //X
            FromPos, //Y
            0, //pw
            0, //ph
            OnPrinter.Canvas, //DestCanvas
            [wppOutputToPrinter{Debug,wppShowMargins, wppPrintPageFrame{} ], //PaintMode
            DestXRes,
            DestYRes,
            -1, //ClipY
            -1, //ClipH Seems to be in 'Lines'
            [] //PaintPageMode
         );  

         OnPrinter.Canvas.Pen.Assign(LPen);
      finally
          lPen.Free;
      end;
   except
      Result := 0;
   end;
end;


// wp_Custom, wp_Letter, wp_Legal, wp_Executive, wp_DinA1, wp_DinA2, wp_DinA3, wp_DinA4, wp_DinA5, wp_DinA6


(*
DMPAPER_LETTER 1 US Letter 8 1/2 x 11 in
DMPAPER_LETTERSMALL 2 US Letter Small 8 1/2 x 11 in 
DMPAPER_TABLOID 3 US Tabloid 11 x 17 in 
DMPAPER_LEDGER 4 US Ledger 17 x 11 in  
DMPAPER_LEGAL 5 US Legal 8 1/2 x 14 in
DMPAPER_STATEMENT 6 US Statement 5 1/2 x 8 1/2 in 
DMPAPER_EXECUTIVE 7 US Executive 7 1/4 x 10 1/2 in
DMPAPER_A3 8 A3 297 x 420 mm 
DMPAPER_A4 9 A4 210 x 297 mm 
DMPAPER_A4SMALL 10 A4 Small 210 x 297 mm 
DMPAPER_A5 11 A5 148 x 210 mm 
DMPAPER_B4 12 B4 (JIS) 257 x 364 mm 
DMPAPER_B5 13 B5 (JIS) 182 x 257 mm 
DMPAPER_FOLIO 14 Folio 8 1/2 x 13 in 
DMPAPER_QUARTO 15 Quarto 215 x 275 mm 
DMPAPER_10X14 16 10 x 14 in 
DMPAPER_11X17 17 11 x 17 in 
DMPAPER_NOTE 18 US Note 8 1/2 x 11 in 
DMPAPER_ENV_9 19 US Envelope #9 3 7/8 x 8 7/8 
DMPAPER_ENV_10 20 US Envelope #10 4 1/8 x 9 1/2 
DMPAPER_ENV_11 21 US Envelope #11 4 1/2 x 10 3/8 
DMPAPER_ENV_12 22 US Envelope #12 4 3/4 x 11 in 
DMPAPER_ENV_14 23 US Envelope #14 5 x 11 1/2 
DMPAPER_CSHEET 24 C size sheet 
DMPAPER_DSHEET 25 D size sheet 
DMPAPER_ESHEET 26 E size sheet 
DMPAPER_ENV_DL 27 Envelope DL 110 x 220mm 
DMPAPER_ENV_C5 28 Envelope C5 162 x 229 mm 
DMPAPER_ENV_C3 29 Envelope C3 324 x 458 mm 
DMPAPER_ENV_C4 30 Envelope C4 229 x 324 mm 
DMPAPER_ENV_C6 31 Envelope C6 114 x 162 mm 
DMPAPER_ENV_C65 32 Envelope C65 114 x 229 mm 
DMPAPER_ENV_B4 33 Envelope B4 250 x 353 mm 
DMPAPER_ENV_B5 34 Envelope B5 176 x 250 mm 
DMPAPER_ENV_B6 35 Envelope B6 176 x 125 mm 
DMPAPER_ENV_ITALY 36 Envelope 110 x 230 mm 
DMPAPER_ENV_MONARCH 37 US Envelope Monarch 3.875 x 7.5 in 
DMPAPER_ENV_PERSONAL 38 6 3/4 US Envelope 3 5/8 x 6 1/2 in 
DMPAPER_FANFOLD_US 39 US Std Fanfold 14 7/8 x 11 in 
DMPAPER_FANFOLD_STD_GERMAN 40 German Std Fanfold 8 1/2 x 12 in 
DMPAPER_FANFOLD_LGL_GERMAN 41 German Legal Fanfold 8 1/2 x 13 in 
DMPAPER_ISO_B4 42 B4 (ISO) 250 x 353 mm 
DMPAPER_JAPANESE_POSTCARD 43 Japanese Postcard 100 x 148 mm 
DMPAPER_9X11 44 9 x 11 in 
DMPAPER_10X11 45 10 x 11 in 
DMPAPER_15X11 46 15 x 11 in 
DMPAPER_ENV_INVITE 47 Envelope Invite 220 x 220 mm 
*)

procedure TRTFBand.SetPrinterSettings(Value: TQRPrinterSettings);
begin
   if Assigned(FRTFLabel) then begin
      case Value.PaperSize2 of
       DMPAPER_LETTER    :  FRTFLabel.Header.PageSize := wp_Letter;
       DMPAPER_LEGAL     :  FRTFLabel.Header.PageSize := wp_Legal;
       DMPAPER_A3        :  FRTFLabel.Header.PageSize := wp_DinA3;
       DMPAPER_EXECUTIVE :  FRTFLabel.Header.PageSize := wp_Executive;

       DMPAPER_A4,
       DMPAPER_A4SMALL   :  FRTFLabel.Header.PageSize := wp_DinA4;

       DMPAPER_A5        :  FRTFLabel.Header.PageSize := wp_DinA5;
       // Make as many customs as you like...
      end;

      FRTFLabel.Header.Landscape := (Value.Orientation = poLandscape);
   end;
end;

procedure TRTFBand.SetPrintJob(Value: TBKPrintJob);
begin
   if IsAvailable then begin
      FreeAndNil(FRTFLabel);

      GetRTFLabel;
      FRTFLabel.OnMailMergeGetText := MailMergeGetText;
      FRTFLabel.InsertPointAttr.Hidden := True;

      FRTFLabel.Header.BeginUpdate;
      try
         SetPrinterSettings(Value.PrinterSettings);
         FRTFLabel.Header.TopMargin := 0; // Not handeled by 
         FRTFLabel.Header.BottomMargin := 0;

         FRTFLabel.Header.LeftMargin :=
            WPCentimeterToTwips((Value.OutputAreaLeft) / 100);

         FRTFLabel.Header.RightMargin := FRTFLabel.Header.PageWidth
                                     - FRTFLabel.Header.LeftMargin
                                     -
            WPCentimeterToTwips((Value.OutputAreaWidth ) / 100);

      finally
        FRTFLabel.Header.EndUpdate;
        FRTFLabel.Header.UpdatePageInfo(True);
      end;
      // Dont use AsString, Don't want the paper Size
      FRTFLabel.LoadFromString(fText);
      FRTFLabel.MergeText();
      FRTFLabel.ReformatAll(True,True);

   end;
end;

end.
