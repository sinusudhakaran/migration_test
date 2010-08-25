unit BKPrintController;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:      Banklink Print Controller

  Written:    Oct 97
  Authors:    Matthew Hopkins

  Purpose:    Wraps up the Quick Report Printer object.  Allows us to
              use a custom preview form.  This object is not expected to
              be used directly, it should be subclassed so that the
              CreateOutput procedure is overriden.

              Allows Printing, Preview, and Printer Setup.

  Notes:
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Forms, bkQRPrntr, Printers , Windows, Dialogs, Prevform, Controls,
  SysUtils, Graphics;

type
  TReportMargins = record
                 mtop,
                 mleft,
                 mbottom,
                 mright : longint;
  end;

  TBKPrintEvent = procedure(Sender : TObject);

  TBKPrintController = class
  private
    FPrinter         : TQRPrinter;
    FPrevForm        : TPreviewForm;
    FPrinterSettings : TQRPrinterSettings;
    FRightWaste      : integer;
    FBottomWaste     : integer;
    FLeftWaste       : integer;
    FTopWaste        : integer;

    FUserPrinter     : integer;  {printer index for storing in settings}
    FUserFontName    : string;
    FUserFontSize    : integer;
    FUserFontStyle   : TFontStyles;
    FBKPrintEvent    : TBKPrintEvent;
    FReview          : boolean;

    FLastSetCanvas   : integer;
    HideJobPageInSetup : boolean;

    procedure   CustomPreview(Sender: TObject);
    procedure   DoPreview;
    procedure   DoPrint;
    procedure   DoPrinterSetup;
    procedure   SetBKPrinterIndex(index : integer);
    function    GetBKPrinterIndex : integer;
    procedure   SetReportTitle(const Value: string);
    function    GetReportTitle : string;
  protected
    UserMargins      : TReportMargins;
    SaveRequired     : boolean;

    property    RightWaste : integer read FRightWaste;
    property    BottomWaste: integer read FBottomWaste;
    property    LeftWaste  : integer read FLeftWaste;
    property    TopWaste   : integer read FTopWaste;

    procedure   CreateOutput(AQRPrinter : TQRPrinter); virtual;
    procedure   GetPrinterMargins(AQRPrinter : TQRPrinter);
    procedure   SetCanvasXYFactors(AQRPrinter: TQRPrinter);

    procedure   BKPrint; virtual;
    property    RedrawPreview : boolean read FReview default false;
  public
    constructor Create; virtual;
    destructor  Destroy; override;
    procedure   Print;
    procedure   Preview;
    procedure   ReportSetup(HideJobPage : boolean);

    procedure   UpdatePreviewProgress( msg :string);
    procedure   UpdatePrintProgress (msg : string);

    property    OnBKPrint    : TBKPrintEvent read FBKPrintEvent write FBKPrintEvent;
    property    ReportTitle : string read GetReportTitle write SetReportTitle;

    property    BKPrinterIndex   : integer read GetBKPrinterIndex write SetBKPrinterIndex;
    property    PrinterSettings  : TQRPrinterSettings read FPrinterSettings write FPrinterSettings;
    property    UserPrinterIndex : integer read FUserPrinter write FUserPrinter;
    property    UserFontName     : string read FUserFontName write FUserFontName;
    property    UserFontSize     : integer read FUserFontSize write FUserFontSize;
    property    UserFontStyle    : TFontStyles read FUserFontStyle write FUserFontStyle;

    property    ReportSettingsChanged : boolean read SaveRequired;
  end;

//******************************************************************************
implementation
uses
   PrntInfo,  // provides printer names, paper names etc for specified printer
   PrinterSettingsFrm;

const
   LS_NONE = 0;
   LS_PRINTER = 1;
   LS_SCREEN = 2;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.SetBKPrinterIndex(index : integer);
begin
   FPrinter.PrinterIndex := index;         {will cause a reset}
   FPrinterSettings.PrinterIndex := index;
end;

function TBKPrintController.GetBKPrinterIndex : integer;
begin
  result := FPrinter.PrinterIndex;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.BKPrint;
begin
   if Assigned(FBKPrintEvent) then
       FBKPrintEvent(Self);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.GetPrinterMargins(AQRPrinter : TQRPrinter);
var
   PageRes       : TPoint;
   PixelsPer_mm_x,
   PixelsPer_mm_y: double;
   OffsetStart   : TPoint;
   PhysPageSize  : TPoint;
   TempPrinter   : TPrinter;
   Rot           : integer;
   Top,Left,Bot,Right : integer;
begin
   TempPrinter := TPrinter.Create;
   try
    TempPrinter.PrinterIndex := AQRPrinter.PrinterIndex;
    TempPrinter.orientation := AQRPrinter.Orientation;

    {default values}
    FRightWaste := 100;
    FBottomWaste:= 100;
    FTopWaste   := 100;
    FLeftWaste  := 100;

    PixelsPer_mm_x := GetDeviceCaps(TempPrinter.handle,LOGPIXELSX) / 254;
    PixelsPer_mm_y := GetDeviceCaps(TempPrinter.handle,LOGPIXELSY) / 254;

    if (PixelsPer_mm_x = 0) or (PixelsPer_mm_y = 0) then exit;

    PhysPageSize.x := GetDeviceCaps(TempPrinter.handle,PHYSICALWIDTH);
    PhysPageSize.y := GetDeviceCaps(TempPrinter.handle,PHYSICALHEIGHT);

    PageRes.x      := TempPrinter.PageWidth;
    PageRes.y      := TempPrinter.PageHeight;

    OffsetStart.x  := GetDeviceCaps(TempPrinter.handle,PHYSICALOFFSETX);
    OffsetStart.y  := GetDeviceCaps(TempPrinter.handle,PHYSICALOFFSETY);

    Left   := round(OffsetStart.x/PixelsPer_mm_x);
    Top    := round(OffsetStart.y/PixelsPer_mm_y);
    Right  := round((PhysPageSize.x - PageRes.x - OffsetStart.x)/PixelsPer_mm_x);
    Bot    := round((PhysPagesize.y - PageRes.y - OffsetStart.y)/PixelsPer_mm_y);

    if TempPrinter.Orientation = poPortrait then
    begin
      FLeftWaste     := left;
      FTopWaste      := top;
      FRightWaste    := right;
      FBottomWaste   := bot;
    end
    else
    begin
      Rot := GetPrinterRotation(TempPrinter);
      if (Rot=90) then
      begin
         FTopWaste    := Right;
         FLeftWaste   := Bot;
         FBottomWaste := Left;
         FRightWaste  := Top;
      end
      else if (Rot=180) then
      begin
         FTopWaste    := Bot;
         FLeftWaste   := Left;
         FBottomWaste := Top;
         FRightWaste  := Right;
      end
      else if (Rot=270) then
      begin
         FTopWaste    := Left;
         FLeftWaste   := Top;
         FBottomWaste := Right;
         FRightWaste  := Bot;
      end;
    end;
   finally
     TempPrinter.Free;
   end;
end;

procedure TBKPrintController.SetCanvasXYFactors(AQRPrinter: TQRPrinter);
var
   CurrentPage : integer;
   TempPrinter : TPrinter;
begin
   TempPrinter := TPrinter.Create;
   try
     TempPrinter.PrinterIndex := AQRPrinter.PrinterIndex;
     TempPrinter.orientation := AQRPrinter.Orientation;

     with AQRPrinter do
     begin
       CurrentPage := PageNumber + 1;
       if (CurrentPage < FirstPage) or (CurrentPage > LastPage) then
       begin
          if FLastSetCanvas = LS_SCREEN then exit
          else
          begin
            YFactor := Screen.PixelsPerInch / 254;
            XFactor := YFactor;
            FLastSetCanvas := LS_SCREEN;
          end;
       end
       else
       begin
          if FLastSetCanvas = LS_PRINTER then exit
          else
          begin
            XFactor := GetDeviceCaps(TempPrinter.Handle, LogPixelsX) / 254;
            YFactor := GetDeviceCaps(TempPrinter.Handle, LogPixelsY) / 254;
            FLastSetCanvas := LS_PRINTER;
          end;
       end;
     end;        { with }
   finally
     TempPrinter.Free;
   end;
end;        {  }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.DoPrint;
var
   OutputPrinter   : TQRPrinter;
begin
   OutputPrinter := TQRPrinter.create;
   try
     {use devmode of internal printer object - this will mean that any extra settings
        in the printer setup will be retained}
     if OutputPrinter.PrinterOK then
     begin
       OutputPrinter.Destination  := qrdPrinter;
       OutputPrinter.PrinterIndex := FPrinter.PrinterIndex;  {will cause the reset}
       OutputPrinter.CopyDevMode(FPrinter.GetDevMode, OutputPrinter.GetDevMode);
       FPrinterSettings.ApplySettings(OutputPrinter);
       FLastSetCanvas := LS_NONE;

       CreateOutput(OutputPrinter);
     end;
   finally
     OutputPrinter.Free;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.CustomPreview(Sender: TObject);
begin
  FPrevForm := TPreviewForm.Create(nil);
  FPrevForm.QRPreview1.QRPrinter := TQRPrinter(Sender);
  FPrevForm.Caption := FPrinterSettings.Title;

  FPrevForm.UpdateStatus('Loading Report Details...');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.UpdatePreviewProgress(msg : string);
begin
  if Assigned(FPrevForm)then
     FPrevForm.UpdateStatus(msg);
end;        {  }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.UpdatePrintProgress(msg : string);
begin
  if Assigned(FPrevForm)then
     FPrevForm.UpdateStatus(msg);
end;        {  }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.DoPrinterSetup;
var
   RePreviewNeeded : boolean;
   wasOrient       : TPrinterOrientation;
   wasPaperSize    : integer;
   wasPrinterIndex : integer;
begin
   RePreviewNeeded := false;
   with TfrmPrinterSettings.Create(application) do begin
      try
         DlgPrinter       := FPrinter.GetTPrinter;
         PaperSize        := FPrinterSettings.PaperSize2;
         bin              := FPrinterSettings.outputBin;
         wasOrient        := FPrinterSettings.Orientation;
         wasPaperSize     := FPrinterSettings.paperSize2;
         wasPrinterIndex  := FPrinter.PrinterIndex;
         if FPrinterSettings.Orientation = poPortrait then
            Orientation := DMORIENT_PORTRAIT
         else
            Orientation := DMORIENT_LANDSCAPE;

         if Execute then begin
            FPrinterSettings.PrinterIndex := dlgPrinter.PrinterIndex;
            FPrinterSettings.OutputBin    := Bin;
            //orientation
            if Orientation = DMORIENT_LANDSCAPE then
               FPrinterSettings.Orientation := poLandscape
            else
               FPrinterSettings.Orientation := poPortrait;
            //paper size
            FPrinterSettings.PaperSize2   := PaperSize;
            //check for repreview
            RePreviewNeeded := (wasOrient <>FPrinterSettings.Orientation)
                               or (wasPaperSize <> FPrinterSettings.paperSize2)
                               or (wasPrinterIndex <> FPrinter.PrinterIndex);
         end;
      finally
         Free;
      end;
   end;

   if RePreviewNeeded and Assigned(FPrevForm) then
       FPrevForm.NewPreview;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.DoPreview;
var
   FirstTime : boolean;
begin
   FirstTime := true;

   while FirstTime or FReview do
   begin
      FPrinter.Preview;  {Creates the preview form}
      try
         FirstTime := false;
         FPrevForm.Repreview := false;
         FReview   := false;
         FPrevForm.Repaint;
         FPrinterSettings.ApplySettings(FPrinter);

         FLastSetCanvas := LS_NONE;
         //Create the output
         CreateOutput(FPrinter);
         UpdatePreviewProgress('Page 1 of ' + inttostr(FPrinter.PageNumber));
         FPrevForm.DefaultDisplay;
         //Hide non-modal form so that can redisplay it as modal
         FPrevForm.Hide;
         FPrevForm.ShowModal;

         FReview := FPrevForm.Repreview;
         FPrinter.Cleanup;   {delete current pages}
      finally
         FPrevForm.Free;
       end;
   end;  { while }
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.CreateOutput(AQRPrinter : TQRPrinter);
{whatever uses this class should fill in this part!}
begin
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.Preview;
begin
    DoPreview;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.Print;
begin
    FPrinter.Print;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TBKPrintController.Create;
begin
    inherited Create;
    FLastSetCanvas               := LS_NONE;
    {init printer}
    FPrinter                     := TQRPrinter.Create;
    FPrinter.OnPreview           := Self.CustomPreview;
    FPrinter.OnGenerateToPrinter := Self.DoPrint;
    FPrinter.OnPrintSetup        := Self.DoPrinterSetup;

    //Load initial settings into the printer.
    //Set to use the default windows printer first. If a different printer is to be used
    //it will be set later
{   FPrinter.PrinterIndex        := 0;  // removed this line because was causing av in Win2000 }
    //Set Priter to the Windows Default Printer
    FPrinter.printerIndex        := -1;
    //Create a printer settings object to hold report settings
    FPrinterSettings             := TQRPrinterSettings.Create;
    FPrinterSettings.Copies      := 1;
    FPrinterSettings.Orientation := poPortrait;
    //Set paper tray to first Available;
    FPrinterSettings.OutputBin   := 1;
    FPrinterSettings.PaperSize2  := DMPAPER_A4;
    FPrinterSettings.Title       := 'Report';

    HideJobPageInSetup           := false;
    FPrinterSettings.ApplySettings(FPrinter);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TBKPrintController.Destroy;
begin
    FPrinter.Free;
    FPrinterSettings.Free;

    inherited Destroy;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TBKPrintController.ReportSetup(HideJobPage :boolean);
begin
  {apply settings loaded for job}
  HideJobPageInSetup := HideJobPage;

  FPrinterSettings.ApplySettings(FPrinter);
  DoPrinterSetup;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.SetReportTitle(const Value: string);
begin
  FPrinterSettings.Title := value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintController.GetReportTitle : string;
begin
  result := FPrinterSettings.Title;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
