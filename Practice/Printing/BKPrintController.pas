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
  classes,
  Forms, bkQRPrntr, Printers , Windows, Dialogs, Prevform, Controls,
  SysUtils, prDiag, Graphics, FaxParametersObj;

type
  TReportMargins = record
                 mtop,
                 mleft,
                 mbottom,
                 mright : longint;
  end;

  TBKPrintEvent  = procedure(Sender : TObject);
  TBKMethodEvent = procedure ( Sender : TObject) of object;

  TBKPrintController = class (TPersistent)
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
    FFontScaleFactor: double;
    fPrintFromPreview, FShowPreviewForm : boolean;
    FUseHeaderFooter: Boolean;
    FUseStyle: Boolean;
    FHasStyle: Boolean;
    FHasHeaderFooter: Boolean;
    procedure   CustomPreview(Sender: TObject);
    procedure   DoPreview;
    procedure   DoPrint;
    function    DoPDF(Filename : String) : Boolean;
    function    DoFax(FaxParam : TFaxParameters): Boolean;
    Function    DoPrinterSetup(DisablePrinterChange,PrePrintSetup: Boolean): TModalresult;
    procedure   DoPrinterSetupHandler;
    procedure   SetBKPrinterIndex(index : integer);
    function    GetBKPrinterIndex : integer;
    procedure   SetReportTitle(const Value: string);
    function    GetReportTitle : string;
    procedure   SetFontScaleFactor(const Value: double);
    {function    DoFaxViaCOM(FaxParam : TFaxParameters): Boolean;}
    function    ResizeFaxForBannerSpace(H, DPI: Integer): Integer;
    //function    SetFaxOrientation(o: TPrinterOrientation): Integer; moved to PaxPrametersObj
    function    GetTempPrinter(FromPtr :TQRPrinter):TPrinter;
    procedure SetUseHeaderFooter(const Value: Boolean);
    procedure SetUseStyle(const Value: Boolean);
    procedure SetHasStyle(const Value: Boolean);
    procedure SetHasHeaderFooter(const Value: Boolean);
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
    function    PrintPDF(Filename : String) : Boolean;
    function    PrintToFax(FaxParam : TFaxParameters) : boolean;
    procedure   ReportSetup(HideJobPage : boolean; DisablePrinterChange: Boolean);

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
    property    ShowPreviewForm  : Boolean read FShowPreviewForm write FShowPreviewForm;

    //this setting allows the default font to be scaled automatically
    //when columns widths are too small to use the default font.  This is
    //done in the financial reports such as Cash flow
    property    FontScaleFactor : double read FFontScaleFactor write SetFontScaleFactor;

    property    ReportSettingsChanged : boolean read SaveRequired;
    property UseStyle: Boolean read FUseStyle write SetUseStyle;
    property UseHeaderFooter: Boolean read FUseHeaderFooter write SetUseHeaderFooter;
    property HasStyle: Boolean read FHasStyle write SetHasStyle;
    property HasHeaderFooter: Boolean read FHasHeaderFooter write SetHasHeaderFooter;
  end;

//******************************************************************************
implementation

uses
   PrntInfo,  // provides printer names, paper names etc for specified printer
   WPPDFR1, WPPDFR2, ssRenderFax,
   ErrorMoreFrm,
   LogUtil,
//   FaxComLib_TLB,
   Globals,
   ReportDefs,
   WinSpool;

const
   UnitName = 'BKPrintController';

   LS_NONE = 0;
   LS_PRINTER = 1;
   LS_SCREEN = 2;

var
  DebugMe : boolean;

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
   TempPrinter := GetTempPrinter( AQRPrinter);
   try
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
            TempPrinter := GetTempPrinter(AQRPrinter);
            try
               XFactor := GetDeviceCaps(TempPrinter.Handle, LogPixelsX) / 254;
               YFactor := GetDeviceCaps(TempPrinter.Handle, LogPixelsY) / 254;
               FLastSetCanvas := LS_PRINTER;
            finally
              TempPrinter.Free;
            end;
          end;
       end;
     end;        { with }
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.DoPrint;
var
   OutputPrinter   : TQRPrinter;
   LPreview : Boolean;
   StatusText,
   DriverName,
   Location : String;

   Function CheckPrintOptions : Boolean;
   Begin  // See if we need to display the print options first
      result := true;
      if fPrintFromPreview then exit;//just been there.
      if Not Assigned( CurrUser ) then exit; // nothing to check against
      if CurrUser.ShowPrinterDialog then
         Case DoPrinterSetup(False,True) of
         mrPrint :; //Ok to move on..
         mrPreview : begin
              Result := false; // Don't want to print.
              if Not assigned(fPrevForm) then
                 DoPreview;
           end
         else Result := false; // canceled
         end;
   end;
begin

   If Not CheckPrintOptions then exit;

   LPreview := fReview;
   if LPreview then begin
      fReview := False;
      Application.ProcessMessages;
   end;

   if Not CheckPrinterStatus (fPrinter.GetTPrinter,StatusText,DriverName,Location ) then begin
       if  MessageDlg('Printer Not ready:'#13
          + StatusText + #13'Print job may fail', mtWarning
                     , [mbOk , mbcancel], 0) <> mrok
       then exit;
   end;

   OutputPrinter := TQRPrinter.create;
   try  try
     {use devmode of internal printer object - this will mean that any extra settings
        in the printer setup will be retained}
     if OutputPrinter.PrinterOK then // Just 'We have printers'
     begin


       OutputPrinter.Destination  := qrdPrinter;
       OutputPrinter.PrinterIndex := FPrinter.PrinterIndex;  {will cause the reset}
       OutputPrinter.CopyDevMode(FPrinter.GetDevMode, OutputPrinter.GetDevMode);
       FPrinterSettings.ApplySettings(OutputPrinter);
       FLastSetCanvas := LS_NONE;

       CreateOutput(OutputPrinter);
     end;
   except // Don't need to 'Crash out' just because of a print error..
       on e :exception  do
          HelpfulErrorMsg(E.Message, 0);
   end;
   finally
     OutputPrinter.Free;
     if LPreview then
        DoPreview;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.CustomPreview(Sender: TObject);
begin
  FPrevForm := TPreviewForm.Create(Application.MainForm);
  fPrevForm.BKPrintController := Self;

  if Assigned( CurrUser ) then
     if CurrUser.ShowPrinterDialog then
       FPrevForm.NoSetup := True;
  
  FPrevForm.bkQRPreview1.QRPrinter := TQRPrinter(Sender);
  FPrevForm.Caption := FPrinterSettings.Title;
  FPrevForm.UpdateStatus('Loading Report Details...');
end;

procedure TBKPrintController.UpdatePreviewProgress(msg : string);
begin
  if Assigned(FPrevForm)then
     FPrevForm.UpdateStatus(msg);
end;        {  }

procedure TBKPrintController.UpdatePrintProgress(msg : string);
begin
  if Assigned(FPrevForm)then
     FPrevForm.UpdateStatus(msg);
end;        {  }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.DoPrinterSetupHandler;
begin  // Called from the Preview
  case DoPrinterSetup(False,False) of
  mrPrint : begin
        fPrintFromPreview := true;
        try
           DoPrint;
        finally
           fPrintFromPreview := false;
        end;
     end;
  end;//case
end;

Function TBKPrintController.DoPrinterSetup(DisablePrinterChange: Boolean; PrePrintSetup: Boolean): tModalresult;
var
   PDiag2 : TPrnDialog;
   RePreviewNeeded : boolean;

   wasOrient : TPrinterOrientation;
   wasPaperSize : integer;
   wasPrinterIndex :integer;
   MarginChange,
   FontChange : boolean;
begin
   //Result := mrCancel; // Safe...
   RePreviewNeeded := false;

   PDiag2 := TPrnDialog.Create(application.MainForm);
   try
    pDiag2.DlgPrinter  := FPrinter.GetTPrinter;

    PDiag2.PageMin     := 1;
    PDiag2.PageMax     := FPrinter.PageCount;
    PDiag2.PaperSize   := FPrinterSettings.PaperSize2;
    PDiag2.bin         := FPrinterSettings.outputBin;
    PDiag2.Copies      := FPrinterSettings.Copies;

    PDiag2.PageFrom    := FPrinterSettings.FirstPage;
    PDiag2.PageTo      := FPrinterSettings.LastPage;

    if PrePrintSetup then begin
       pDiag2.caption     :='Print ' +UpperCase(FPrinterSettings.Title)+' Report';
    end else begin
       pDiag2.caption     :='Setup ' +UpperCase(FPrinterSettings.Title)+' Report';
    end;

    if (FPrinterSettings.Title = REPORT_LIST_NAMES[Report_CAF]) or
       (FPrinterSettings.Title = REPORT_LIST_NAMES[Report_TPA]) then
    begin
      pDiag2.cmbSize.Enabled := False;
      pDiag2.btnSetMargins.Enabled := False;
      pDiag2.rbPortrait.Enabled := False;
      pDiag2.rbLandscape.Enabled := False;
    end;
    pDiag2.DisablePrinterChange := DisablePrinterChange;

    PDiag2.DefFontName   := FUserFontName;
    PDiag2.DefFontSize   := FUserFontSize;
    PDiag2.DefFontStyle  := FUserFontStyle;

    PDiag2.Margins.Top   := UserMargins.mtop;
    PDiag2.Margins.Left  := UserMargins.mleft;
    PDiag2.Margins.Bottom:= UserMargins.mbottom;
    PDiag2.Margins.Right := UserMargins.mright;

    PDiag2.UseDefPrinter := (FUserPrinter = -1);
    PDiag2.SetupOnly     := HideJobPageInSetup;
    PDiag2.PrePrintSetup := PrePrintSetup;

    wasOrient := FPrinterSettings.Orientation;
    wasPaperSize := FPrinterSettings.paperSize2;
    wasPrinterIndex := FPrinter.PrinterIndex;




    if FPrinterSettings.Orientation = poPortrait then
       PDiag2.Orientation := DMORIENT_PORTRAIT
    else
       PDiag2.Orientation := DMORIENT_LANDSCAPE;

    pDiag2.SaveClicked := SaveRequired;

    //****************************
    Result := PDiag2.Execute;
    //****************************

    if (Result in [mrOK,mrPrint,mrPreview]) Then begin

       { now set values}
       SaveRequired := pDiag2.SaveClicked;

       FPrinterSettings.PrinterIndex := pDiag2.dlgPrinter.PrinterIndex;
       if pDiag2.UseDefPrinter then
           FUserPrinter := -1
       else
           FUserPrinter := pDiag2.dlgPrinter.Printerindex;

       FPrinterSettings.Copies := pDiag2.copies;
       FPrinterSettings.OutputBin := pDiag2.Bin;

       if pdiag2.rbFrom.Checked then
       begin
         if  (pdiag2.opFrom.AsInteger >= 1)
         and (pdiag2.opFrom.AsInteger <= FPrinter.PageCount) then
            FPrinterSettings.FirstPage := pdiag2.opFrom.AsInteger
         else
            FPrinterSettings.FirstPage := 1;

         if (pdiag2.opTo.AsInteger >= 1)
         and (pdiag2.opTo.AsInteger <= FPrinter.PageCount) then
            FPrinterSettings.LastPage  := pdiag2.opTo.AsInteger
         else  FPrinterSettings.LastPage := FPrinter.PageCount;

       end else begin
          FPrinterSettings.FirstPage := 0;
          FPrinterSettings.LastPage := 0;
       end;

       
       if  (pDiag2.Orientation = DMORIENT_LANDSCAPE)
       and (FPrinterSettings.Title <> REPORT_LIST_NAMES[REPORT_CAF])
       and (FPrinterSettings.Title <> REPORT_LIST_NAMES[REPORT_TPA]) then
          FPrinterSettings.Orientation := poLandscape
       else
          FPrinterSettings.Orientation := poPortrait;

       {paper size}
       FPrinterSettings.PaperSize2 := pDiag2.PaperSize;

       {base font}
       with PDiag2 do
       begin
          FontChange := (FUserFontName <> DefFontName)
                     or (FUserFontSize <> DefFontSize)
                     or (FUserFontStyle <> DefFontStyle);

          FUserFontName   := DefFontName;
          FUserFontSize   := DefFontSize;
          FUserFontStyle  := DefFontStyle;
       end;

       {user margins}
       with PDiag2.Margins, UserMargins do
         MarginChange := (Top <> mTop)
                      or (Left <> mLeft)
                      or (Bottom <> mBottom)
                      or (Right <> mRight);

       UserMargins.mtop    := PDiag2.Margins.Top;
       UserMargins.mleft   := PDiag2.Margins.Left;
       UserMargins.mbottom := PDiag2.Margins.Bottom;
       UserMargins.mright  := PDiag2.Margins.Right;

       {check for repreview}
       RePreviewNeeded := (wasOrient <>FPrinterSettings.Orientation)
           or (wasPaperSize <> FPrinterSettings.paperSize2)
           or (wasPrinterIndex <> FPrinter.PrinterIndex)
           or MarginChange or FontChange;
    end;
   finally
     PDiag2.Free;
   end;

   if  RePreviewNeeded
   and Assigned(FPrevForm) then
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
         if ShowPreviewForm then
         begin
           FPrevForm.Hide;
           FPrevForm.ShowModal;
         end;

         FReview := FPrevForm.Repreview;
         FPrinter.Cleanup;   {delete current pages}
      finally
         FPrevForm.Free;
         FPrevForm := nil;
       end;
   end;  { while }
end;

function TBKPrintController.DoPDF(Filename : String) : Boolean;
const
  ThisMethodName = 'TBKPrintController.DoPDF';
var
  FPDF : TWpPDFPrinter;
  i, xs, ys : Integer;
  xf,yf : Integer;
  Orientation : Integer;
  lPage: tMetaFile;
begin
  Result := True;
  FReview   := false;

  FPrinterSettings.ApplySettings(FPrinter);

  FLastSetCanvas := LS_NONE;
  //Create the output
  CreateOutput(FPrinter);
  UpdatePreviewProgress('Page 1 of ' + inttostr(FPrinter.PageNumber));

  WPDF_Start('BankLink','A1h7afT4526dra7h77hb');
  FPDF := TWpPDFPrinter.Create( nil );
  try
    try
      FPDF.Filename := Filename;
      FPDF.CompressStreamMethod := wpCompressFastFlate;
      FPDF.FontMode := wpEmbedSymbolTrueTypeFonts;
      FPDF.BeginDoc;

      if (FPrinter.Orientation = poPortrait) then
         Orientation := 0
      else
         Orientation := 1;
      xs := Trunc(FPrinter.PaperWidthValue2 * FPrinter.XFactor);
      ys := Trunc(FPrinter.PaperLengthValue2 * FPrinter.YFactor);
      xf := Round(FPrinter.XFactor * 254);
      yf := Round(FPrinter.YFactor * 254);

      for i := 1 to FPrinter.PageCount do
      begin
        lPage := FPrinter.GetPage(i);

        if Assigned(lPage) then try

           FPDF.StartPage(xs, ys, xf, yf, Orientation);
           FPDF.DrawMetafileEx(0, 0, xs, ys, lPage.Handle, 0, 0);
           FPDF.EndPage;
        finally
           lPage.free;
        end;


      end;

      FPDF.EndDoc;

    except
      on e : Exception do begin
        LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + E.Message );
        Result := False;
      end;
    end;
  finally
    FPDF.Free;
  end;
  FPrinter.Cleanup;   {delete current pages}
end;
(*
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Sets the GLOBAL orientation for the Fax printer.
// Note we cannot just set it locally (i.e. just for this app) because it doesnt
// take any notice of it!!
// Returns the current setting so we can switch back when we're finished.
function TBKPrintController.SetFaxOrientation(o: TPrinterOrientation): Integer;
var
  HPrinter: THandle;
  BytesNeeded: Cardinal;
  PI2: PPrinterInfo2;
  PrinterDefaults: TPrinterDefaults;
begin
  Result := -1; // No change
  try
    with PrinterDefaults do
    begin
      DesiredAccess := PRINTER_ACCESS_USE;
      pDatatype := nil;
      pDevMode := nil;
    end;
    if OpenPrinter(PChar(FPrinter.Printers[FPrinter.PrinterIndex]), HPrinter, @PrinterDefaults) then
    try
      SetLastError(0);
      //Determine the number of bytes to allocate for the PRINTER_INFO_2 construct...
      if not GetPrinter(HPrinter, 2, nil, 0, @BytesNeeded) then
      begin
        //Allocate memory space for the PRINTER_INFO_2 pointer (PrinterInfo2)...
        PI2 := AllocMem(BytesNeeded);
        try
          // Get the global PI2 info
          if GetPrinter(HPrinter, 2, PI2, BytesNeeded, @BytesNeeded) then
          begin
            // Set the global orientation
            Result := PI2.pDevMode.dmOrientation;
            if o = poLandscape then
              PI2.pDevMode.dmOrientation := DMORIENT_LANDSCAPE
            else
              PI2.pDevMode.dmOrientation := DMORIENT_PORTRAIT;
            if DocumentProperties(0, hPrinter, PChar(FPrinter.Printers[FPrinter.PrinterIndex]),
                   PI2.pDevMode^, PI2.pDevMode^, DM_IN_BUFFER or DM_OUT_BUFFER) = IDOK then
              SetPrinter(HPrinter, 2, PI2, 0);
          end;
        finally
          FreeMem(PI2, BytesNeeded);
        end;
      end;
    finally
      ClosePrinter(HPrinter);
      FPrinter.GetTPrinter.Orientation := FPrinterSettings.Orientation;
    end;
  except
    LogUtil.LogMsg( lminfo, unitname, 'failed to set orientation for fax');
  end;
{
  This would set it for the local app only, but it gets ignored!
var
  hDevMode: THANDLE;
  MydevMode: PDevMode;
  Device, Driver, Port: Array [0..255] of Char;
begin
  FPrinter.GetTPrinter.GetPrinter(device, driver, port, hDevMode);
  if hDevMode <> 0 then
  begin
    // Lock the memory
    MyDevMode := GlobalLock(hDevMode);
    try
      if o = poLandscape then
        MyDevMode^.dmOrientation := DMORIENT_LANDSCAPE
      else
        MyDevMode^.dmOrientation := DMORIENT_PORTRAIT;
        MyDevMode^.dmFields := MyDevMode^.dmFields or dm_Orientation;
    finally
//      FPrinter.GetTPrinter.SetPrinter(device, driver, port, hDevMode);
      ResetDC(Printer.Handle, MyDevMode^);
      GlobalUnlock(hDevMode);
    end;
  end;}
end;
 *)
function TBKPrintController.DoFax(FaxParam : TFaxParameters) : Boolean;
const
  ThisMethodName = 'TBKPrintController.DoFax';
var
  FaxPrinter : TSSRenderFax;
  aCanvas : TCanvas;
  PageNum : integer;

  PageW, PageH : integer;

  ClipRect : TRect;
  ClipRgn : HRgn;
  HasBanner: Boolean;
  SavedOrient: Integer;
  lPage: TMetaFile;
begin
  Result := False;
  FReview   := false;
  HasBanner := True;

  SavedOrient := SetFaxOrientation(FPrinter.Printers[FPrinter.PrinterIndex],FPrinterSettings.Orientation);

  FPrinterSettings.ApplySettings(FPrinter);

  FLastSetCanvas := LS_NONE;
  UpdatePreviewProgress('Page 1 of ' + inttostr(FPrinter.PageNumber));

  FaxPrinter := TssRenderFax.Create(Application.MainForm);
  try
    FaxPrinter.FaxPrinterName := FPrinter.Printers[FPrinter.PrinterIndex];
    FaxPrinter.ConnectFax;
    HasBanner := FaxPrinter.IsBanner;
    if Globals.PRACINI_SuppressBanner then // Force no banner
      FaxPrinter.SetFaxBanner(False);
    FaxPrinter.PagesToPrint := FPrinter.PageCount;

    if Assigned(FaxParam) then
    begin
      FaxParam.AssignTo(FaxPrinter);
    end
    else
    begin
      //no parameters passed, implement this when asked for
      raise ESSRenderFaxError.Create( 'No fax details passed');
    end;
    LogUtil.LogMsg( lminfo, unitname, 'Generating fax for ' + FaxPrinter.RecipientInfo.FaxNumber);
    FaxPrinter.DocBegin;
    try
      LogUtil.LogMsg( lminfo, unitname, 'FID:' + IntToStr(FaxPrinter.FaxJobID));
      // As long as we have the correct printer selected we can just take the
      // page dimensions, then resize to account for banner space if required
      PageW := FPrinter.GetTPrinter.PageWidth;
      PageH := FPrinter.GetTPrinter.PageHeight;
      if HasBanner and ((not Globals.PRACINI_SuppressBanner) or FaxPrinter.IsRemote) then
      begin
        if FPrinter.GetTPrinter.Orientation = poPortrait then
          PageH := ResizeFaxForBannerSpace(PageH, FaxPrinter.GetYDPI)
        else if FPrinter.GetTPrinter.Orientation = poLandscape then
          UserMargins.mleft := UserMargins.mleft + (Globals.PRACINI_mmFaxBannerHeight * 10);
      end;

      //#2047 extra debug info requested by Steve Agnew
      if DebugMe then
      begin
        LogUtil.LogMsg( lmDebug, Unitname, 'DocumentName = ' + FaxPrinter.DocumentName);
        LogUtil.LogMsg( lmDebug, Unitname, 'FaxPrinterName = ' + FaxPrinter.FaxPrinterName);
        LogUtil.LogMsg( lmDebug, Unitname, 'PageW = ' + IntToStr( PageW));
        LogUtil.LogMsg( lmDebug, Unitname, 'PageH = ' + IntToStr( PageH));
        LogUtil.LogMsg( lmDebug, Unitname, 'GetYDPI = ' + IntToStr( FaxPrinter.GetYDPI));
        LogUtil.LogMsg( lmDebug, Unitname, 'GetXDPI = ' + IntToStr( FaxPrinter.GetXDPI));
        if HasBanner then
          LogUtil.LogMsg( lmDebug, Unitname, 'HasBanner = true');
        if FaxPrinter.IsRemote then
          LogUtil.LogMsg( lmDebug, Unitname, 'FaxPrinter.IsRemote = true');
        if FPrinter.GetTPrinter.Orientation = poLandscape then
          LogUtil.LogMsg( lmDebug, Unitname, 'FaxPrinter.Orientation = Landscape');
      end;

      //Create the output
      CreateOutput(FPrinter);

      ACanvas := FaxPrinter.GetCanvas;

      FaxPrinter.DoCoverPage(FPrinter.PageCount);
      //figure out to size of the page in pixels
      ClipRect.Top := 0;
      ClipRect.Left := 0;
      ClipRect.Bottom := PageH;
      ClipRect.Right := PageW;



      for PageNum := 1 to FPrinter.PageCount do begin
         lPage := FPrinter.GetPage(PageNum);
         if Assigned(LPage) then try
            //draw the metafile for this page onto the fax canvas
            FaxPrinter.PageBegin;
            // Probably only need this once..
            ClipRgn := CreateRectRgnIndirect( ClipRect);
            try
               BeginPath( aCanvas.Handle);
               ACanvas.Rectangle( ClipRect);
               EndPath( aCanvas.Handle);
               ClipRgn := PathToRegion( aCanvas.Handle);
               SelectClipRgn( aCanvas.Handle, ClipRgn);
            finally
               DeleteObject( ClipRgn);
            end;
            aCanvas.StretchDraw( ClipRect, lPage);
            FaxPrinter.PageEnd;
         finally
            LPage.Free;
         end;
      end;
    finally
      FaxPrinter.DocEnd;
    end;
    Result := true;
  finally
    if Globals.PRACINI_SuppressBanner then // Re-instate original banner setting
      FaxPrinter.SetFaxBanner(HasBanner);
    FaxPrinter.Free;
    if SavedOrient = DMORIENT_LANDSCAPE then begin
       SetFaxOrientation(FPrinter.Printers[FPrinter.PrinterIndex],poLandscape);
       FPrinter.GetTPrinter.Orientation := poLandscape;
    end else if SavedOrient = DMORIENT_PORTRAIT then begin
       SetFaxOrientation(FPrinter.Printers[FPrinter.PrinterIndex],poPortrait);
       FPrinter.GetTPrinter.Orientation := poPortrait;
    end;
  end;

  FPrinter.Cleanup;   {delete current pages}
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
function TBKPrintController.PrintPDF(Filename : String) : Boolean;
begin
  Result := DoPDF(Filename);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintController.PrintToFax( FaxParam : TFaxParameters) : boolean;
begin
  result := DoFax( FaxParam);
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
    FPrinter.OnPrintSetup        := Self.DoPrinterSetupHandler;

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
    FShowPreviewForm             := True;
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

procedure TBKPrintController.ReportSetup(HideJobPage :boolean; DisablePrinterChange: Boolean);
begin
  {apply settings loaded for job}
  HideJobPageInSetup := HideJobPage;

  FPrinterSettings.ApplySettings(FPrinter);
  DoPrinterSetup(DisablePrinterChange,False);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.SetReportTitle(const Value: string);
begin
  FPrinterSettings.Title := value;
end;

procedure TBKPrintController.SetUseHeaderFooter(const Value: Boolean);
begin
  FUseHeaderFooter := Value;
end;

procedure TBKPrintController.SetUseStyle(const Value: Boolean);
begin
  FUseStyle := Value;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintController.GetReportTitle : string;
begin
  result := FPrinterSettings.Title;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBKPrintController.GetTempPrinter(FromPtr: TQRPrinter): TPrinter;
var Device, Name, Port: array[0..255] of Char;
    DevMode: THandle;
begin
   result := TPrinter.Create;
   if Result.PrinterIndex <> fromPtr.PrinterIndex then begin
      Result.PrinterIndex := fromPtr.PrinterIndex;
      // Need to reset the DevMode see case 5174
      Result.GetPrinter( Device, Name, Port , DevMode );
      Result.SetPrinter( Device, Name, Port , 0 );
   end;
   result.orientation := FromPtr.Orientation;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBKPrintController.SetFontScaleFactor(const Value: double);
begin
  FFontScaleFactor := Value;
end;

procedure TBKPrintController.SetHasHeaderFooter(const Value: Boolean);
begin
  FHasHeaderFooter := Value;
end;

procedure TBKPrintController.SetHasStyle(const Value: Boolean);
begin
  FHasStyle := Value;
end;

// Return new fax page height after banner height has been removed
function TBKPrintController.ResizeFaxForBannerSpace(H, DPI: Integer): Integer;
var
  Hnew: Extended;
begin
  {
    height in pixels / fax printer dpi = height in inches
    height in inches * 2.54 (inches per cm) * 10 (mm per cm) = height in mm
    height in mm - 15 (banner takes approx 15mm - but can be configured) = new page height
  }
  Hnew := ((H / DPI) * 2.54 * 10) - Globals.PRACINI_mmFaxBannerHeight;
  // Now convert new mm page height back to pixels
  Result := Round(((Hnew / 10) / 2.54) * DPI);
end;

{function TBKPrintController.DoFaxViaCOM(FaxParam : TFaxParameters) : boolean;
var
  FaxServer : TFaxServer;
  FaxDoc : OleVariant;
  fname : string;
  g : TGUID;
begin
  result := false;
  CreateGuid( g);
  fname := GuidToString( g) + '.pdf';
  LogUtil.LogMsg( lminfo, unitname, 'Generating fax for ' + FaxParam.FaxNumber + ' ' + fname);
  fname := GetTempDir(ExtractFilePath(Application.ExeName)) + fname;     //<<- use windows temp folder... no point putting on server
  try
    //produce the pdf first, then fax that document
    DoPDF( fname);

    FaxServer := TFaxServer.Create( Application);
    try
      FaxServer.Connect1(''); //null = default fax server
      try
        FaxDoc := FaxServer.CreateDocument( fname);

        FaxDoc.Displayname := FaxParam.DocumentName;
        FaxDoc.FaxNumber := FaxParam.FaxNumber;
        FaxDoc.RecipientCompany := FaxParam.ToName;
        FaxDoc.RecipientName := FaxParam.Contact;
        FaxDoc.DiscountSend := 0;  //not implemented yet

        if FaxParam.CoverPageFilename <> '' then
        begin
          FaxDoc.CoverpageName := FaxParam.CoverPageFilename;
          FaxDoc.CoverpageSubject := FaxParam.CoverPageSubject;
          FaxDoc.CoverpageNote := FaxParam.CoverPageText;
          FaxDoc.SendCoverPage := True;
          FaxDoc.ServerCoverpage := 0;  //only local pages are supported
        end
        else
          FaxDoc.SendCoverPage := False;
        //------------------------------------------------
        FaxDoc.Send;
        Application.ProcessMessages;
        //------------------------------------------------
        result := true;
        LogUtil.LogMsg( lminfo, unitname, 'GenerateFax completed');
      finally
        FaxServer.Disconnect1;
      end;
    finally
      FaxServer.Free;
    end;
  finally
    DeleteFile( fname);
  end;
end;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);

end.
