unit wppdfQR;
{ -----------------------------------------------------------------------------
   Export filter for Quickreport.
   Originally written by Timo Hartmann <timo@thsd.de>, Author of QRDesign
   Please visit the page www.thsd.de if you need a powerful add-on for
   QuickReport which makes it nota only possible to design reports at
   runtime but also helps with some other quick report problems.
  ----------------------------------------------------------------------------- }

interface

uses
  QRPrntr, Graphics, Forms, Classes, WPPDFR2;

{.$DEFINE ALT2}

type
 TQRwPDFExportFilter = class(TQRExportFilter)
  private
  protected
    function GetFilterName : string; override;
    function GetDescription : string; override;
    function GetExtension : string; override;
  public
    procedure Finish; override;
  end;

  TQRwPDFFilter = class(TComponent)
  private
    function GetPDFPrinter : TWPPDFPrinter;
    procedure SetPDFPrinter(x : TWPPDFPrinter);
    function GetResolution : Integer;
    procedure SetResolution(x : Integer);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
  published
    property Resolution : Integer read GetResolution write SetResolution;
    property PDFPrinter : TWPPDFPrinter read GetPDFPrinter write SetPDFPrinter;
  end;

implementation

uses
  Quickrpt;

var FWPPDFPrinter : TWPPDFPrinter;
    FDefaultResolution : Integer = 72;

function TQRwPDFExportFilter.GetDescription : string;
begin
  result := 'wPDF Export filter';
end;

function TQRwPDFExportFilter.GetFilterName : string;
begin
  result := 'Portable Document (PDF)';
end;

function TQRwPDFExportFilter.GetExtension : string;
begin
  result := 'PDF';
end;

procedure TQRwPDFExportFilter.Finish;
var
  i: integer;
  aMetaFile: TMetaFile;
  WPPDFPrinter1, FreePDF: TWPPDFPrinter;
  papw, paph : Integer;
begin
  FreePDF := nil;
  if not (Owner is TCustomQuickRep) then Exit;
  with TCustomQuickRep(Owner) do
    if OriginalQRPrinter <> nil then
      with OriginalQRPrinter do
        begin
          if FWPPDFPrinter<>nil then
             WPPDFPrinter1 := FWPPDFPrinter else
          begin
             FreePDF:=TWPPDFPrinter.Create(Owner);
             WPPDFPrinter1 := FreePDF;
          end;
          try
           WPPDFPrinter1.FileName:=FileName;
           WPPDFPrinter1.BeginDoc;
           for i := 1 to PageNumber do
            begin
              aMetaFile := GetPage(i);
              {$IFDEF ALT2}
              if Assigned(aMetaFile) then
                begin
                  papw := Round(PaperWidthValue * FDefaultResolution / 254);
                  paph := Round(PaperLengthValue * FDefaultResolution / 254);
                  WPPDFPrinter1.StartPage(papw,paph, FDefaultResolution, FDefaultResolution,0);
                  try
                    WPPDFPrinter1.DrawMetafileEx(0,0,0,0,aMetaFile.Handle, Screen.PixelsPerInch, Screen.PixelsPerInch);
                  finally
                    aMetaFile.Free;
                    WPPDFPrinter1.EndPage;
                  end;
                end;
              {$ELSE}
                if Assigned(aMetaFile) then
                begin
                  papw := Round(PaperWidthValue * FDefaultResolution / 254);
                  paph := Round(PaperLengthValue * FDefaultResolution / 254);
                  try
                  WPPDFPrinter1.DrawMetafile(0,0,aMetaFile.Handle);
                  finally
                    aMetaFile.Free;
                    WPPDFPrinter1.EndPage;
                  end;
                end;
              {$ENDIF}

            end;
           WPPDFPrinter1.EndDoc;
          finally
            if FreePDF<>nil then FreePDF.Free;
          end;
        end;
end;

constructor TQRwPDFFilter.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  QRExportFilterLibrary.AddFilter(TQRwPDFExportFilter);
  FDefaultResolution := Screen.PixelsPerInch;
end;

destructor TQRwPDFFilter.Destroy;
begin
  QRExportFilterLibrary.RemoveFilter(TQRwPDFExportFilter);
  inherited Destroy;
end;

procedure TQRwPDFFilter.Notification(AComponent: TComponent; Operation: TOperation);
begin
   if (Operation=opRemove) and (AComponent=FWPPDFPrinter) then
       FWPPDFPrinter := nil;
end;

function TQRwPDFFilter.GetPDFPrinter : TWPPDFPrinter;
begin
   Result := FWPPDFPrinter;
end;

procedure TQRwPDFFilter.SetPDFPrinter(x : TWPPDFPrinter);
begin
   FWPPDFPrinter := x;
end;

function TQRwPDFFilter.GetResolution : Integer;
begin
   Result := FDefaultResolution;
end;

procedure TQRwPDFFilter.SetResolution(x : Integer);
begin
   FDefaultResolution := x;
end;


end.

