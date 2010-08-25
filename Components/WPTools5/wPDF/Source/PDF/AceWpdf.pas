unit AceWpdf;
{ --------------------------------------------------------------
  Unit to create a 'Save as PDF' button in the preview dialog.
  utilizes wPDF by wpCubed GmbH - see www.wptools.de

  Written by Steve Tyrakowski, modified by JZ

  --------------------------------------------------------------
  Usage:
    In your application simply execute
      PDFPrinter.Attach to attach a 'Create PDF' button to the
      global preview dialog .
    Use PDFPrinter.Detach to remove it.

  You can create a PDF file from a TACEFile object using
     PDFPrinter.MakePDF(af: TAceFile ; PDFFileName: String);

  You don't need to care about creation and destrcution of PDFPrinter!

  if you want to create a PDF file which consists of multiple
  reports attch a TWPPDFPrinter to the property PDFPrinter.PDFPrinter
  and execute the TWPPDFPrinter.BeginDoc/EndDoc procedures.

  -------------------------------------------------------------- }


interface
uses windows, Messages, SysUtils, Forms, WPPDFR1, WPPDFR2, acefile, aceview;

type
  TACEwPDF = class
  private
    FNoMessage : Boolean;
    FPDFPrinter : TWPPDFPrinter;
  private
    procedure CreatePDFButtonClick(Sender: TObject);
    procedure InternSendPDFPage(af: TAceFile ; pdf: TWPPDFPrinter ; pageno: integer);
  public
     constructor Create;
     destructor Destroy; override;
     class procedure Attach;
     class procedure Detach;
     procedure MakePDF(af: TAceFile ; PDFFileName: String);
     procedure SendPDFPage(af: TAceFile ; pdf: TWPPDFPrinter ; pageno: integer);
     property  PDFPrinter : TWPPDFPrinter read FPDFPrinter write FPDFPrinter;
     property  NoMessage : Boolean read FNoMessage write FNoMessage;
  end;


procedure Install; // For compatibility only

function PDFPrinter : TACEwPDF;

const cMakePDF = 'Make PDF';
      cMakePDFHint = 'Create a PDF file from this report';
      cPDFFilter = 'PDF Files |*.PDF|All Files|*.*';

var   cPDFMessage : string = 'PDF saved to "%s"';


implementation

uses stdctrls, dialogs, acesetup;

var MainPDFPrinter : TACEwPDF;

procedure Install;
begin
  PDFPrinter.Attach;
end;

function PDFPrinter : TACEwPDF;
begin
   if MainPDFPrinter=nil then TACEwPDF.Create;
   Result := MainPDFPrinter;
end;

constructor TACEwPDF.Create;
begin
  if MainPDFPrinter=nil then
     Inherited Create
  else raise Exception.Create('Only one instance of TACEwPDF possible');
  MainPDFPrinter := self;
end;

destructor TACEwPDF.Destroy;
begin
  MainPDFPrinter := nil;
  inherited Destroy;
end;

var
  FIsAttached : Boolean;

type
  TPDFButton = class(TButton)
  protected
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  end;

  procedure TPDFButton.WMPaint(var Message: TWMPaint); 
  begin
     Visible := FIsAttached;
     inherited;
  end;


procedure MyViewEvent(av: TAceViewer);
var
  MyButton: TButton;
begin
  { Note that you have a reference to the form passed as a parameter      }
  { so you can access its controls easily.                                }
  { the following code disables printing from the preview                 }
  { Use this event only for changes that should apply to                  }
  { ALL reports.  changes that are specific to one or a few               }
  { reports, see "Modifying the default previewer at runtime" in the help.}
  MyButton := TPDFButton.Create(av);
  MyButton.Parent := av.ToolBar;
  MyButton.Left := 600;
  MyButton.Top := 5;
  MyButton.Caption  := cMakePDF;
  MyButton.Hint     := cMakePDFHint;
  MyButton.ShowHint := True;
  MyButton.OnClick  := PDFPrinter.CreatePDFButtonClick;
end;

class procedure TACEwPDF.Attach;
begin
  FIsAttached := TRUE;
  aceview.aceviewevent := MyViewEvent;
end;

class procedure TACEwPDF.Detach;
begin
  FIsAttached := FALSE;
  aceview.aceviewevent := nil;
end; 

procedure TAceWpdf.CreatePDFButtonClick(Sender: TObject);
var
  av: TAceViewer;
  dlg: TSaveDialog;
begin
  av := TAceViewer(TButton(Sender).Owner);
  dlg := TSaveDialog.Create(av);
  dlg.InitialDir := '.\';
  dlg.DefaultExt := 'PDF';
  dlg.Filter := cPDFFilter;
  if dlg.Execute then
  begin
    MakePdf(av.CurrentPreview.Filer.AceFile,dlg.FileName);
    if not FNoMessage and (cPDFMessage<>'') then
       ShowMessage(Format(cPDFMessage,[dlg.FileName]) );
  end;
  dlg.Free;
end;

procedure TACEwPDF.SendPDFPage(af: TAceFile ; pdf: TWPPDFPrinter ; pageno: integer);
begin
  if FPDFPrinter=nil then
       raise Exception.Create('property PDFPrinter was not assigned')
  else InternSendPDFPage(af, FPDFPrinter, pageno );
end; 

procedure TACEwPDF.InternSendPDFPage(af: TAceFile ; pdf: TWPPDFPrinter ; pageno: integer);
var
  res :integer;
  aps: TAcePrinterSetup;
begin
  aps := TAcePrinterSetup.Create;
  TAceAceFile(af).GetPagePrinterInfo(aps, pageno);
  res := Screen.PixelsPerInch;
  pdf.StartPage(Round(aps.width*res),Round(aps.length * res),
       res, res , Ord((aps.Orientation = DMORIENT_LANDSCAPE)));
  try
    af.PlayPage(pdf.Canvas.Handle,pageno);
  finally
    pdf.EndPage;
    aps.free;
  end;
end;

{ This procedure will create a TWPPDFPrinter or use the one assigned to the class }

procedure TACEwPDF.MakePDF(af: TAceFile ; PDFFileName: String);
var
  TempPDF, FPDF: TWPPDFPrinter;
  FCloseIt : Boolean;
  n,numPages: integer;
begin
  numPages := TAceAceFile(af).AceFileInfo.Pages;
  TempPDF := nil;
  if numPages>0 then
  try
    if FPDFPrinter<>nil then
    begin
       FPDF := FPDFPrinter;
       FCloseIt := not FPDF.Printing;
    end else
    begin
       TempPDF := TWPPDFPrinter.Create(nil);
       FPDF := TempPDF;
       FCloseIt := TRUE;
    end;

    if FCloseIt then
    begin
      FPDF.FileName := PDFFileName;
      FPDF.BeginDoc;
    end;

    try
      for n := 1 to numPages do InternSendPDFPage(af, FPDF, n);
    finally
      if FCloseIt then FPDF.EndDoc;
    end;

  finally
     if TempPDF<>nil then
        TempPDF.Free;
  end;
end;

initialization
  MainPDFPrinter := nil;

finalization
  if MainPDFPrinter<>nil then MainPDFPrinter.Free;
  
end.
